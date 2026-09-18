import os
import torch
import torch.nn as nn
from tqdm import tqdm
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger, get_latest_commit, append_commit
import snntorch as snn
from snntorch import surrogate

import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="torchaudio._backend.utils")

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier" 
MODEL_NAME = "model_best.pth"
EPOCHS_TO_RUN = 50

# --- HARDWARE CONSTANTS ---
VALID_BETAS = torch.tensor([
    0.0000, 0.0156, 0.0312, 0.0469, 0.0625, 0.0781, 0.0938, 0.1094, 
    0.1250, 0.1406, 0.1562, 0.1719, 0.1875, 0.2031, 0.2188, 0.2344, 
    0.2500, 0.2656, 0.2812, 0.2969, 0.3125, 0.3281, 0.3438, 0.3594, 
    0.3750, 0.3906, 0.4062, 0.4219, 0.4375, 0.4531, 0.4688, 0.4844, 
    0.5000, 0.5156, 0.5312, 0.5469, 0.5625, 0.5781, 0.5938, 0.6094, 
    0.6250, 0.6406, 0.6562, 0.6719, 0.6875, 0.7031, 0.7188, 0.7344, 
    0.7500, 0.7656, 0.7812, 0.7969, 0.8125, 0.8281, 0.8438, 0.8594, 
    0.8750, 0.8906, 0.9062, 0.9219, 0.9375, 0.9531, 0.9688, 0.9844, 1.0000
])

def get_snapped_hardware(beta_tensor, device):
    valid_betas = VALID_BETAS.to(device)
    dists = (beta_tensor.unsqueeze(1) - valid_betas.unsqueeze(0)) ** 2
    best_indices = dists.argmin(dim=1)
    return valid_betas[best_indices]

# ======================================================================
# Phase 3 QAT: Pure Integer Weights & Hardware Betas (No Custom Math)
# ======================================================================
class Phase3QATNet(nn.Module):
    def __init__(self, orig_model, config, device):
        super().__init__()
        self.device = device
        self.num_hidden = config["num_hidden"]
        self.num_outputs = config["num_outputs"]
        
        self.spike_grad = surrogate.fast_sigmoid(slope=75)

        # 1. Learnable Floating-Point Shadows
        self.w_in = nn.Parameter(orig_model.fc_in.weight.data.clone())
        self.w_rec = nn.Parameter(orig_model.fc_rec.weight.data.clone())
        self.w_out = nn.Parameter(orig_model.fc_out.weight.data.clone())
        
        # 2. Extract Static Phase 2 Deltas
        with torch.no_grad():
            def calc_delta(w):
                return (torch.quantile(torch.abs(w), 0.985) + 1e-8) / 127.0
            
            self.delta_in = calc_delta(self.w_in)
            self.delta_rec = calc_delta(self.w_rec)
            self.delta_out = calc_delta(self.w_out)

            # Snap betas to hardware limits
            beta_hid_raw = orig_model.lif_hidden.beta.data.clone()
            beta_out_raw = orig_model.lif_out.beta.data.clone()
            self.beta_hid = get_snapped_hardware(beta_hid_raw, device)
            self.beta_out = get_snapped_hardware(beta_out_raw, device)
            
        # 3. Native snnTorch Neurons (Guaranteeing bug-free integration math)
        self.lif_hidden = snn.Leaky(beta=self.beta_hid, spike_grad=self.spike_grad, reset_mechanism="zero")
        self.lif_out = snn.Leaky(beta=self.beta_out, spike_grad=self.spike_grad, reset_mechanism="zero")

    def forward(self, x):
        batch = x.size(0)
        time_steps = x.size(1)
        
        # --- STE Weight Quantization ---
        # The torch.round function natively severs anything between -0.49 and 0.49!
        w_in_ste = (torch.round(self.w_in / self.delta_in) - self.w_in / self.delta_in).detach() + self.w_in / self.delta_in
        w_rec_ste = (torch.round(self.w_rec / self.delta_rec) - self.w_rec / self.delta_rec).detach() + self.w_rec / self.delta_rec
        w_out_ste = (torch.round(self.w_out / self.delta_out) - self.w_out / self.delta_out).detach() + self.w_out / self.delta_out
        
        # Scale back to floating point for integration
        w_in_eff = w_in_ste * self.delta_in
        w_rec_eff = w_rec_ste * self.delta_rec
        w_out_eff = w_out_ste * self.delta_out

        mem_hid = self.lif_hidden.init_leaky()
        mem_out = self.lif_out.init_leaky()
        spk_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        
        spk_out_rec, spk_hid_rec = [], []

        for step in range(time_steps):
            
            # Standard Dense MAC (But strictly using integer-rounded weights)
            cur_in = torch.matmul(x[:, step, :], w_in_eff.t())
            cur_rec = torch.matmul(spk_hid, w_rec_eff.t())
            
            spk_hid, mem_hid = self.lif_hidden(cur_in + cur_rec, mem_hid)
            spk_hid_rec.append(spk_hid)
            
            cur_out = torch.matmul(spk_hid, w_out_eff.t())
            spk_out, mem_out = self.lif_out(cur_out, mem_out)
            spk_out_rec.append(spk_out)
            
        return torch.stack(spk_out_rec, dim=1), torch.stack(spk_hid_rec, dim=1)

def run_evaluation(model, data_loader, device, idx_noise, idx_silence):
    model.eval()
    val_correct, val_total = 0, 0
    
    with torch.no_grad():
        for x, y in data_loader:
            x, y = x.to(device), y.to(device)
            spk_out, spk_hidden = model(x)
            spike_counts = spk_out.sum(dim=1)
            
            max_spikes, raw_preds = spike_counts.max(dim=1)
            preds = torch.where(max_spikes < 10, torch.tensor(idx_silence, device=device), raw_preds)
            
            val_correct += (preds == y).sum().item()
            val_total += y.size(0)
            
    acc = (val_correct / val_total) * 100 if val_total > 0 else 0.0
    return acc

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    print(f"\n=== Training Pipeline (Phase 3: Progressive Quantization-Aware Training) ===")
    
    train_loader, test_loader, labels_map = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    idx_noise = labels_map.get("noise", 6)
    idx_silence = labels_map.get("silence", 7)
    
    orig_model = FastSpikingNet(
        num_inputs=config["num_inputs"], num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"], beta=config["beta"]
    ).to(device)
    
    checkpoint = torch.load(os.path.join(TARGET_FOLDER, MODEL_NAME), map_location=device)
    orig_model.load_state_dict(checkpoint["model_state_dict"])
    
    model = Phase3QATNet(orig_model, config, device).to(device)
    
    # 1e-4 LR provides a soft landing into strict integers
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='min', factor=0.9, patience=3, min_lr=1e-6)
    
    best_test_acc = 0.0
    
    for epoch in range(EPOCHS_TO_RUN):
        model.train()
        total_loss, correct, total = 0.0, 0, 0
        batches = 0
        
        pbar = tqdm(train_loader, desc=f"Epoch {epoch+1:02d}", leave=False)
        for x, y in pbar:
            x, y = x.to(device), y.to(device)
            optimizer.zero_grad()
            batches += 1
            
            spk_out, spk_hidden = model(x)
            spike_counts = spk_out.sum(dim=1)
            hidden_counts = spk_hidden.sum(dim=1)
            
            active_mask = y < config["num_outputs"] 
            silence_mask = y == idx_silence         
            loss = torch.tensor(0.0, device=device, requires_grad=True)
    
            if active_mask.any():
                active_spikes = spike_counts[active_mask]
                active_targets = y[active_mask]
                target_spike_vals = active_spikes[torch.arange(len(active_targets)), active_targets]

                loss = loss + 0.0002 * ((target_spike_vals - 45.0) ** 4).mean()

                total_hidden_spikes = hidden_counts.sum(dim=1) 
                loss = loss + 1.0 * (((torch.abs(total_hidden_spikes - 400.0) / 100.0)) ** 3).mean()

                other_mask = torch.ones_like(active_spikes, dtype=torch.bool)
                other_mask[torch.arange(len(active_targets)), active_targets] = False
                other_spikes_2d = active_spikes[other_mask].view(len(active_targets), -1)
                max_competitor_vals, _ = other_spikes_2d.max(dim=1)
                margin = target_spike_vals - max_competitor_vals
                loss = loss + 0.2 * (torch.nn.functional.softplus((40.0 - margin) / 5.0) ** 3).mean()

                gravity_spikes = active_spikes.clone()
                gravity_spikes[torch.arange(len(active_targets)), active_targets] = 0.0
                gravity_spikes[:, idx_noise] = 0.0  
                loss = loss + 0.005 * (gravity_spikes ** 2).sum(dim=1).mean()
        
            if silence_mask.any():
                loss = loss + 0.0025 * (spike_counts[silence_mask] ** 3).mean()
    
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=0.5) 
            optimizer.step()
            total_loss += loss.item()
    
            max_spikes, raw_preds = spike_counts.max(dim=1)
            preds = torch.where(max_spikes < 10, torch.tensor(idx_silence, device=device), raw_preds)
            correct += (preds == y).sum().item()
            total += y.size(0)
    
            pbar.set_postfix({"Loss": f"{loss.item():.2f}", "Acc": f"{(correct/total)*100:.1f}%"})

        train_acc = (correct / total) * 100 if total > 0 else 0.0
        epoch_loss = total_loss / batches if batches > 0 else 0.0
        
        test_acc = run_evaluation(model, test_loader, device, idx_noise, idx_silence)
        scheduler.step(epoch_loss) 
        current_lr = optimizer.param_groups[0]['lr']

        print(f"Epoch {epoch+1:02d}/{EPOCHS_TO_RUN} | Train: {train_acc:.1f}% | Test: {test_acc:.1f}% | LR: {current_lr:.6f} | Loss: {epoch_loss:.2f}")

        if train_acc >= best_test_acc:
            best_test_acc = train_acc
            torch.save({"model_state_dict": model.state_dict()}, os.path.join(TARGET_FOLDER, "phase3_model_best.pth"))
            print(f"   🌟 New Best Phase 3 Acc! Saved phase3_model_best.pth")

if __name__ == "__main__":
    main()