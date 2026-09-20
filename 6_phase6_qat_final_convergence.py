import os
import torch
import torch.nn as nn
from tqdm import tqdm
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger
from snntorch import surrogate

import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="torchaudio._backend.utils")

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier" 
SPARSE_CHECKPOINT = "acc86.3_sparsity22.5.pth" # Update to your chosen sparse model!
EPOCHS_TO_RUN = 0

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

FRAC_BITS = torch.tensor([
    0.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 
    3.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 
    2.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 
    3.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 
    1.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 
    3.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 
    2.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 
    3.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 0.0
])

def get_snapped_hardware(beta_tensor, device):
    valid_betas = VALID_BETAS.to(device)
    frac_bits = FRAC_BITS.to(device)
    dists = (beta_tensor.unsqueeze(1) - valid_betas.unsqueeze(0)) ** 2
    best_indices = dists.argmin(dim=1)
    return valid_betas[best_indices], frac_bits[best_indices]

# ======================================================================
# Phase 6: Full Verilog Physical Simulation
# ======================================================================
class Phase6QATFinalNet(nn.Module):
    def __init__(self, orig_model, config, device):
        super().__init__()
        self.device = device
        self.num_hidden = config["num_hidden"]
        self.num_outputs = config["num_outputs"]
        
        self.spike_grad = surrogate.fast_sigmoid(slope=100)

        # 1. Weights
        self.w_in = nn.Parameter(orig_model.fc_in.weight.data.clone())
        self.w_rec = nn.Parameter(orig_model.fc_rec.weight.data.clone())
        self.w_out = nn.Parameter(orig_model.fc_out.weight.data.clone())
        
        # 2. Topology Masks
        self.mask_in = nn.Parameter(torch.ones_like(self.w_in), requires_grad=False)
        self.mask_rec = nn.Parameter(torch.ones_like(self.w_rec), requires_grad=False)
        self.mask_out = nn.Parameter(torch.ones_like(self.w_out), requires_grad=False)

        # 3. Hardware ALU Extraction
        with torch.no_grad():
            def calc_delta(w): return (torch.quantile(torch.abs(w), 0.985) + 1e-8) / 127.0
            
            self.delta_in = calc_delta(self.w_in)
            self.delta_rec = calc_delta(self.w_rec)
            self.delta_out = calc_delta(self.w_out)
            self.delta_hid = min(self.delta_in, self.delta_rec)

            beta_hid_raw = orig_model.lif_hidden.beta.data.clone()
            beta_out_raw = orig_model.lif_out.beta.data.clone()
            self.beta_hid, self.frac_bits_hid = get_snapped_hardware(beta_hid_raw, device)
            self.beta_out, self.frac_bits_out = get_snapped_hardware(beta_out_raw, device)
            
            self.lsb_hid = self.delta_hid / (2.0 ** self.frac_bits_hid)
            self.lsb_out = self.delta_out / (2.0 ** self.frac_bits_out)

            self.thresh_hid = torch.round(1.0 / self.delta_hid) * self.delta_hid
            self.thresh_out = torch.round(1.0 / self.delta_out) * self.delta_out

            # 4. Pareto Register Caps
            pareto_path = os.path.join(TARGET_FOLDER, "pareto_config_84.0.pt")
            pareto_cfg = torch.load(pareto_path, map_location=device)
            int_bits_hid = pareto_cfg["int_bits_hid"].to(device)
            int_bits_out = pareto_cfg["int_bits_out"].to(device)
            self.max_mem_hid = (2.0 ** (int_bits_hid + self.frac_bits_hid)) - 1.0
            self.max_mem_out = (2.0 ** (int_bits_out + self.frac_bits_out)) - 1.0

            # 5. OR-Gate Hardware Wiring Manifest
            manifest_path = os.path.join(TARGET_FOLDER, "hardware_wiring.pt")
            manifest = torch.load(manifest_path, map_location=device)
            
            num_all_inputs = config["num_inputs"] + config["num_hidden"]
            self.pos_masks = nn.Parameter(torch.zeros(3, self.num_hidden, num_all_inputs), requires_grad=False)
            self.neg_masks = nn.Parameter(torch.zeros(3, self.num_hidden, num_all_inputs), requires_grad=False)
            
            for i in range(self.num_hidden):
                neuron_data = manifest["hidden_neurons"].get(i, {"pos_gates":[], "neg_gates":[]})
                for g, gate_list in enumerate(neuron_data["pos_gates"]):
                    if g >= 3: continue
                    for src_type, src_idx in gate_list:
                        global_idx = src_idx if src_type == 'in' else src_idx + config["num_inputs"]
                        self.pos_masks[g, i, global_idx] = 1.0
                for g, gate_list in enumerate(neuron_data["neg_gates"]):
                    if g >= 3: continue
                    for src_type, src_idx in gate_list:
                        global_idx = src_idx if src_type == 'in' else src_idx + config["num_inputs"]
                        self.neg_masks[g, i, global_idx] = 1.0
            print(">>> Physical OR-Gate Routing Matrices Loaded.")

    def simulate_or_buses(self, all_spikes, w_all_abs_int, gate_masks):
        """Simulates parallel 8-bit bitwise OR gates across unipolar active synapses."""
        batch = all_spikes.size(0)
        num_gates = gate_masks.size(0)
        total_sum = torch.zeros(batch, self.num_hidden, dtype=torch.int32, device=self.device)
        
        for g in range(num_gates):
            # Mask isolates the specific connections physically routed to this OR-gate
            w_gate = w_all_abs_int * gate_masks[g] 
            active_w = all_spikes.unsqueeze(1).int() * w_gate.unsqueeze(0).int()
            
            gate_out = torch.zeros(batch, self.num_hidden, dtype=torch.int32, device=self.device)
            for bit in range(8): # Simulate 8 physical OR-wires
                bit_mask = 1 << bit
                bit_present = ((active_w & bit_mask) != 0).any(dim=-1)
                gate_out += bit_present.int() << bit
                
            total_sum += gate_out
        return total_sum

    def forward(self, x):
        batch = x.size(0)
        time_steps = x.size(1)
        
        # --- STE Weight Quantization ---
        w_in_masked = self.w_in * self.mask_in
        w_rec_masked = self.w_rec * self.mask_rec
        w_out_masked = self.w_out * self.mask_out

        w_in_ste = (torch.round(w_in_masked / self.delta_in) - w_in_masked / self.delta_in).detach() + w_in_masked / self.delta_in
        w_rec_ste = (torch.round(w_rec_masked / self.delta_rec) - w_rec_masked / self.delta_rec).detach() + w_rec_masked / self.delta_rec
        w_out_ste = (torch.round(w_out_masked / self.delta_out) - w_out_masked / self.delta_out).detach() + w_out_masked / self.delta_out
        
        w_in_eff = w_in_ste * self.delta_in
        w_rec_eff = w_rec_ste * self.delta_rec
        w_out_eff = w_out_ste * self.delta_out

        # Hardware Integer Arrays (Pre-Calculated for OR buses)
        w_in_int = torch.round(w_in_ste).int()
        w_rec_int = torch.round(w_rec_ste).int()
        w_all_int = torch.cat([w_in_int, w_rec_int], dim=1)
        w_all_abs_int = torch.abs(w_all_int)

        mem_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        mem_out = torch.zeros(batch, self.num_outputs, device=self.device)
        spk_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        spk_out_rec, spk_hid_rec = [], []

        for step in range(time_steps):
            
            # --- 1. HIDDEN LAYER: OR-GATE SIMULATION ---
            # Ideal Math (for gradients)
            ideal_sum = torch.matmul(x[:, step, :], w_in_eff.t()) + torch.matmul(spk_hid, w_rec_eff.t())
            
            # Physical Hardware Math
            all_spikes = torch.cat([x[:, step, :], spk_hid], dim=1)
            pos_int = self.simulate_or_buses(all_spikes, w_all_abs_int, self.pos_masks)
            neg_int = self.simulate_or_buses(all_spikes, w_all_abs_int, self.neg_masks)
            
            hw_sum_int = pos_int - neg_int
            hw_sum_float = hw_sum_int.float() * self.delta_hid
            
            # Straight-Through Estimator: Use Physical Sum, Backprop Ideal Sum
            hw_sum_ste = (hw_sum_float - ideal_sum).detach() + ideal_sum
            
            ideal_mem_hid = (mem_hid * self.beta_hid.unsqueeze(0)) + hw_sum_ste
            
            # Pareto Clamps & Sub-integer truncation
            limit_hid = (self.max_mem_hid * self.lsb_hid).unsqueeze(0)
            ideal_mem_hid = torch.clamp(ideal_mem_hid, min=-limit_hid, max=limit_hid)
            
            hw_mem_hid = torch.floor((ideal_mem_hid / self.lsb_hid.unsqueeze(0)) + 1e-5) * self.lsb_hid.unsqueeze(0)
            mem_hid = (hw_mem_hid - ideal_mem_hid).detach() + ideal_mem_hid
            
            spk_hid = self.spike_grad(mem_hid - self.thresh_hid)
            mem_hid = mem_hid * (1.0 - spk_hid.detach()) 
            spk_hid_rec.append(spk_hid)
            
            # --- 2. OUTPUT LAYER (Standard Matrix Additions) ---
            cur_out = torch.matmul(spk_hid, w_out_eff.t())
            ideal_mem_out = (mem_out * self.beta_out.unsqueeze(0)) + cur_out
            
            limit_out = (self.max_mem_out * self.lsb_out).unsqueeze(0)
            ideal_mem_out = torch.clamp(ideal_mem_out, min=-limit_out, max=limit_out)
            
            hw_mem_out = torch.floor((ideal_mem_out / self.lsb_out.unsqueeze(0)) + 1e-5) * self.lsb_out.unsqueeze(0)
            mem_out = (hw_mem_out - ideal_mem_out).detach() + ideal_mem_out
            
            spk_out = self.spike_grad(mem_out - self.thresh_out)
            mem_out = mem_out * (1.0 - spk_out.detach())
            spk_out_rec.append(spk_out)
            
        return torch.stack(spk_out_rec, dim=1), torch.stack(spk_hid_rec, dim=1)

def run_evaluation(model, data_loader, device, idx_noise, idx_silence):
    model.eval()
    val_correct, val_total = 0, 0
    all_preds, all_targets, all_spikes = [], [], []
    all_in_spikes, all_hidden_spikes = [], []
    
    with torch.no_grad():
        for x, y in data_loader:
            x, y = x.to(device), y.to(device)
            spk_out, spk_hidden = model(x)
            spike_counts = spk_out.sum(dim=1)
            
            max_spikes, raw_preds = spike_counts.max(dim=1)
            preds = torch.where(max_spikes < 10, torch.tensor(idx_silence, device=device), raw_preds)
            
            val_correct += (preds == y).sum().item()
            val_total += y.size(0)
            
            all_preds.extend(preds.cpu().tolist())
            all_targets.extend(y.cpu().tolist())
            all_spikes.append(spike_counts.cpu())
            all_in_spikes.append(x.sum(dim=1).cpu())
            all_hidden_spikes.append(spk_hidden.sum(dim=1).cpu())
            
    spike_counts = torch.cat(all_spikes, dim=0)
    input_counts = torch.cat(all_in_spikes, dim=0)
    hidden_counts = torch.cat(all_hidden_spikes, dim=0)
    acc = (val_correct / val_total) * 100 if val_total > 0 else 0.0
    
    return acc, all_preds, all_targets, spike_counts, input_counts, hidden_counts

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    print(f"\n=== Training Pipeline (Phase 6: Final Hardware OR-Bus Simulation) ===")
    
    train_loader, test_loader, labels_map = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    idx_noise = labels_map.get("noise", 6)
    idx_silence = labels_map.get("silence", 7)
    inv_labels = {v: k for k, v in labels_map.items()}
    num_classes = config["num_outputs"]
    
    orig_model = FastSpikingNet(
        num_inputs=config["num_inputs"], num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"], beta=config["beta"]
    ).to(device)
    
    base_ckpt = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location=device)
    orig_model.load_state_dict(base_ckpt.get("model_state_dict", base_ckpt), strict=False)

    model = Phase6QATFinalNet(orig_model, config, device).to(device)
    
    # Load Phase 4 Checkpoint for Weights and Masks
    target_ckpt_path = os.path.join(TARGET_FOLDER, SPARSE_CHECKPOINT)
    if os.path.exists(target_ckpt_path):
        p4_ckpt = torch.load(target_ckpt_path, map_location=device)
        model.w_in.data.copy_(p4_ckpt["model_state_dict"]["w_in"])
        model.w_rec.data.copy_(p4_ckpt["model_state_dict"]["w_rec"])
        model.w_out.data.copy_(p4_ckpt["model_state_dict"]["w_out"])
        model.mask_in.data.copy_(p4_ckpt["mask_in"])
        model.mask_rec.data.copy_(p4_ckpt["mask_rec"])
        model.mask_out.data.copy_(p4_ckpt["mask_out"])
        print(f">>> Resumed {SPARSE_CHECKPOINT} weights and sparsity masks.")
    
    # Small learning rate to heal any minor collision losses without destroying the weights
    optimizer = torch.optim.Adam(model.parameters(), lr=5e-7)
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='min', factor=0.9, patience=3, min_lr=1e-7)
    
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
                loss = loss + 0.4 * (torch.nn.functional.softplus((40.0 - margin) / 5.0) ** 3).mean()

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
        
        test_acc = run_evaluation(model, test_loader, device, idx_noise, idx_silence)[0]

        if test_acc >= best_test_acc:
            best_test_acc = test_acc
            torch.save(model.state_dict(), os.path.join(TARGET_FOLDER, "phase6_final_hardware_model.pth"))
            print(f"   🌟 Saved phase6_final_hardware_model.pth")

        scheduler.step(epoch_loss) 
        current_lr = optimizer.param_groups[0]['lr']

        print(f"Epoch {epoch+1:02d}/{EPOCHS_TO_RUN} | Train: {train_acc:.1f}% | Test: {test_acc:.1f}% | LR: {current_lr:.6f} | Loss: {epoch_loss:.2f}")


    # ======================================================================
    # FINAL DIAGNOSTICS BLOCK
    # ======================================================================
    print("\nRunning Final Hardware Diagnostics...")
    final_test_acc, preds, targets, spike_counts, input_counts, hidden_counts = run_evaluation(model, test_loader, device, idx_noise, idx_silence)
    
    target_tensor_arr = torch.tensor(targets)
    pred_tensor_arr = torch.tensor(preds)
    
    print("\n--- Average Input Spikes per Target Class ---")
    num_inputs = config["num_inputs"]
    header_in = f"{'Target Class':<13} | " + " | ".join([f"Ch{i:<4}" for i in range(num_inputs)]) + " || TOTAL"
    print(header_in)
    print("-" * len(header_in))
    for i in range(len(inv_labels)): 
        class_mask = target_tensor_arr == i
        if class_mask.sum() > 0:
            mean_in = input_counts[class_mask].float().mean(dim=0)
            total_in = mean_in.sum().item()
            row = f"{inv_labels[i]:<13} | " + " | ".join([f"{val:>6.1f}" for val in mean_in]) + f" || {total_in:>6.1f}"
            print(row)

    print("\n--- Average Hidden Spikes per Target Class ---")
    header_hid = f"{'Target Class':<13} | {'Total Layer':>11} | {'Avg/Neuron':>10} | {'Max Neuron':>10}"
    print(header_hid)
    print("-" * len(header_hid))
    for i in range(len(inv_labels)): 
        class_mask = target_tensor_arr == i
        if class_mask.sum() > 0:
            mean_hid = hidden_counts[class_mask].float().mean(dim=0)
            total_hid = mean_hid.sum().item()
            avg_per_n = mean_hid.mean().item()
            max_n = mean_hid.max().item()
            print(f"{inv_labels[i]:<13} | {total_hid:>11.1f} | {avg_per_n:>10.1f} | {max_n:>10.1f}")

    print("\n--- Average Output Spikes per Target Class ---")
    header_spikes = f"{'Target Class':<13} | " + " | ".join([f"{inv_labels[i]:>6}" for i in range(num_classes)])
    print(header_spikes)
    print("-" * len(header_spikes))
    for i in range(len(inv_labels)): 
        class_mask = target_tensor_arr == i
        if class_mask.sum() > 0:
            mean_spikes = spike_counts[class_mask].float().mean(dim=0)
            print(f"{inv_labels[i]:<13} | " + " | ".join([f"{val:>6.1f}" for val in mean_spikes]))

    print("\n--- Network Health & Sparsity Audit ---")
    total_spikes_per_neuron = hidden_counts.sum(dim=0)
    avg_spikes_per_neuron = hidden_counts.mean(dim=0)
    dead_neurons = (total_spikes_per_neuron == 0).nonzero(as_tuple=True)[0].tolist()
    hyper_neurons = (avg_spikes_per_neuron > 40).nonzero(as_tuple=True)[0].tolist()
    
    max_in_w = model.w_in.data.abs().max(dim=1)[0]
    severed_in = (max_in_w < 1e-4).nonzero(as_tuple=True)[0].tolist()
    max_out_w = model.w_out.data.abs().max(dim=0)[0]
    weak_out = (max_out_w < 1.0).nonzero(as_tuple=True)[0].tolist()
    max_rec_w = model.w_rec.data.abs().max(dim=1)[0]
    severed_rec = (max_rec_w < 1e-4).nonzero(as_tuple=True)[0].tolist()
    
    print(f"Total Hidden Neurons: {config['num_hidden']}")
    print(f"Dead Neurons (0 spikes)         : {len(dead_neurons):>3}  {dead_neurons if dead_neurons else ''}")
    print(f"Severed Inputs (Max In W < 0.0001): {len(severed_in):>3}  {severed_in if severed_in else ''}")
    print(f"Severed Recurrents (Max Rec W < 0): {len(severed_rec):>3}  {severed_rec if severed_rec else ''}")

    print("\n--- Hardware Precision Matrix (%) ---")
    keyword_idx = [i for i in range(num_classes) if i not in (idx_noise, idx_silence)]
    header = f"{'Target / Pred':<13} | " + " | ".join([f"{inv_labels[i]:>6}" for i in keyword_idx]) + " || Retention"
    print(header)
    print("-" * len(header))
    
    for t_idx in keyword_idx:
        t_mask = target_tensor_arr == t_idx
        total_samples = t_mask.sum().item()
        if total_samples > 0:
            preds_for_target = pred_tensor_arr[t_mask]
            active_preds = preds_for_target[(preds_for_target != idx_noise) & (preds_for_target != idx_silence)]
            retained = active_preds.size(0)
            ret_pct = (retained / total_samples) * 100
            
            row_str = f"{inv_labels[t_idx]:<13} | "
            for p_idx in keyword_idx:
                count = (active_preds == p_idx).sum().item()
                pct = (count / retained * 100) if retained > 0 else 0.0
                row_str += f"{pct:>6.1f} | "
            row_str += f"|| {ret_pct:>6.1f}%"
            print(row_str)

    sorted_spikes, _ = torch.sort(spike_counts, dim=1, descending=True)
    margin_diffs = sorted_spikes[:, 0] - sorted_spikes[:, 1]
    is_keyword_target = (target_tensor_arr != idx_noise) & (target_tensor_arr != idx_silence)
    total_real_keywords = is_keyword_target.sum().item()

    print(f"\n--- Spike Margin Threshold Report (Base: {total_real_keywords} Real Keywords) ---")
    for margin in [0, 1, 2, 3, 4, 5, 10, 15]:
        margin_met = margin_diffs >= margin
        is_keyword_pred = (pred_tensor_arr != idx_noise) & (pred_tensor_arr != idx_silence)
        attempt_mask = margin_met & is_keyword_pred
        total_attempts = attempt_mask.sum().item()
        
        correct_attempts = (pred_tensor_arr[attempt_mask] == target_tensor_arr[attempt_mask]).sum().item()
        precision = (correct_attempts / total_attempts * 100) if total_attempts > 0 else 0.0
        
        keywords_attempted = (attempt_mask & is_keyword_target).sum().item()
        retention_pct = (keywords_attempted / total_real_keywords * 100) if total_real_keywords > 0 else 0.0

        print(f">= {margin:2d} spikes diff | Prec (Acc): {precision:5.1f}% | Retention: {keywords_attempted:3d}/{total_real_keywords:3d} ({retention_pct:5.1f}%) | Total Triggers: {total_attempts}")

if __name__ == "__main__":
    main()