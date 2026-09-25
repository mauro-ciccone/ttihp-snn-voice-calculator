import os
import torch
import torch.nn as nn
from tqdm import tqdm
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger
from snntorch import surrogate

# --- UPDATE THESE TO MATCH YOUR LATEST RUN ---
TARGET_FOLDER = "experiments/0924_1200_64_neuron_model"
SPARSE_CHECKPOINT = "acc76.5_sparsity20.0.pth" 
# ---------------------------------------------

# --- HARDWARE CONSTANTS ---
VALID_BETAS = torch.tensor([
    0.0000, 0.0156, 0.0312, 0.0469, 0.0625, 0.0781, 0.0938, 0.1094, 
    0.1250, 0.1406, 0.1562, 0.1719, 0.1875, 0.2031, 0.2188, 0.2344, 
    0.2500, 0.2656, 0.2812, 0.2969, 0.3125, 0.3281, 0.3438, 0.3594, 
    0.3750, 0.3906, 0.4062, 0.4219, 0.4375, 0.4531, 0.4688, 0.4844, 
    0.5000, 0.5156, 0.5312, 0.5469, 0.5625, 0.5781, 0.5938, 0.6094, 
    0.6250, 0.6406, 0.6562, 0.6719, 0.6875, 0.7031, 0.7188, 0.7344, 
    0.7500, 0.7656, 0.7812, 0.7969, 0.8125, 0.8281, 0.8438, 0.8594, 
    0.8750, 0.8906, 0.9062, 0.9219, 0.9375, 0.9531, 0.9688, 1.0000
])

FRAC_BITS = torch.tensor([
    0.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 3.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 
    2.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 3.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 
    1.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 3.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 
    2.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 3.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 0.0
])

def get_snapped_hardware(beta_tensor, device):
    valid_betas = VALID_BETAS.to(device)
    frac_bits = FRAC_BITS.to(device)
    dists = (beta_tensor.unsqueeze(1) - valid_betas.unsqueeze(0)) ** 2
    best_indices = dists.argmin(dim=1)
    return valid_betas[best_indices], frac_bits[best_indices]

class Phase4QATSparseNet(nn.Module):
    def __init__(self, orig_model, config, device):
        super().__init__()
        self.device = device
        self.num_hidden = config["num_hidden"]
        self.num_outputs = config["num_outputs"]
        self.spike_grad = surrogate.fast_sigmoid(slope=100)

        self.w_in = nn.Parameter(orig_model.fc_in.weight.data.clone())
        self.w_rec = nn.Parameter(orig_model.fc_rec.weight.data.clone())
        self.w_out = nn.Parameter(orig_model.fc_out.weight.data.clone())
        
        self.mask_in = nn.Parameter(torch.ones_like(self.w_in), requires_grad=False)
        self.mask_rec = nn.Parameter(torch.ones_like(self.w_rec), requires_grad=False)
        self.mask_out = nn.Parameter(torch.ones_like(self.w_out), requires_grad=False)

        with torch.no_grad():
            def calc_delta(w):
                return (torch.quantile(torch.abs(w), 0.985) + 1e-8) / 127.0
            
            raw_delta_in = (torch.quantile(torch.abs(self.w_in), 0.985) + 1e-8) / 127.0
            raw_delta_rec = (torch.quantile(torch.abs(self.w_rec), 0.985) + 1e-8) / 127.0
            self.global_delta = max(raw_delta_in, raw_delta_rec)
            
            self.delta_in = self.global_delta
            self.delta_rec = self.global_delta
            self.delta_hid = self.global_delta
            self.delta_out = calc_delta(self.w_out)

            beta_hid_raw = orig_model.lif_hidden.beta.data.clone()
            beta_out_raw = orig_model.lif_out.beta.data.clone()
            self.beta_hid, self.frac_bits_hid = get_snapped_hardware(beta_hid_raw, device)
            self.beta_out, self.frac_bits_out = get_snapped_hardware(beta_out_raw, device)
            
            self.lsb_hid = self.delta_hid / (2.0 ** self.frac_bits_hid)
            self.lsb_out = self.delta_out / (2.0 ** self.frac_bits_out)

            self.thresh_hid = torch.round(1.0 / self.delta_hid) * self.delta_hid
            self.thresh_out = torch.round(1.0 / self.delta_out) * self.delta_out

            pareto_cfg = torch.load(os.path.join(TARGET_FOLDER, "pareto_config_65.0.pt"), map_location=device)
            int_bits_hid = pareto_cfg["int_bits_hid"].to(device)
            int_bits_out = pareto_cfg["int_bits_out"].to(device)

            self.max_mem_hid = (2.0 ** (int_bits_hid + self.frac_bits_hid)) - 1.0
            self.max_mem_out = (2.0 ** (int_bits_out + self.frac_bits_out)) - 1.0

    def forward(self, x):
        batch = x.size(0)
        time_steps = x.size(1)
        
        w_in_masked = self.w_in * self.mask_in
        w_rec_masked = self.w_rec * self.mask_rec
        w_out_masked = self.w_out * self.mask_out

        w_in_ste = (torch.round(w_in_masked / self.delta_in) - w_in_masked / self.delta_in).detach() + w_in_masked / self.delta_in
        w_rec_ste = (torch.round(w_rec_masked / self.delta_rec) - w_rec_masked / self.delta_rec).detach() + w_rec_masked / self.delta_rec
        w_out_ste = (torch.round(w_out_masked / self.delta_out) - w_out_masked / self.delta_out).detach() + w_out_masked / self.delta_out
        
        w_in_eff = w_in_ste * self.delta_in
        w_rec_eff = w_rec_ste * self.delta_rec
        w_out_eff = w_out_ste * self.delta_out

        mem_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        mem_out = torch.zeros(batch, self.num_outputs, device=self.device)
        spk_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        
        spk_out_rec, spk_hid_rec = [], []

        for step in range(time_steps):
            cur_in = torch.matmul(x[:, step, :], w_in_eff.t())
            cur_rec = torch.matmul(spk_hid, w_rec_eff.t())
            
            ideal_mem_hid = (mem_hid * self.beta_hid.unsqueeze(0)) + cur_in + cur_rec
            limit_hid = (self.max_mem_hid * self.lsb_hid).unsqueeze(0)
            ideal_mem_hid = torch.clamp(ideal_mem_hid, min=-limit_hid, max=limit_hid)
            
            hw_mem_hid = torch.floor((ideal_mem_hid / self.lsb_hid.unsqueeze(0)) + 1e-5) * self.lsb_hid.unsqueeze(0)
            mem_hid = (hw_mem_hid - ideal_mem_hid).detach() + ideal_mem_hid
            
            spk_hid = self.spike_grad(mem_hid - self.thresh_hid)
            mem_hid = mem_hid * (1.0 - spk_hid.detach()) 
            spk_hid_rec.append(spk_hid)
            
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

def main():
    device = torch.device("cpu")
    print("\n=== Phase 6: Generating Hardware-Accurate Base Spikes Cache ===")
    
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    train_loader, _, _ = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    
    # 1. Initialize Base Model
    orig_model = FastSpikingNet(
        num_inputs=config["num_inputs"], num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"], beta=config["beta"]
    ).to(device)
    base_ckpt = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location=device)
    orig_model.load_state_dict(base_ckpt.get("model_state_dict", base_ckpt), strict=False)

    # 2. Wrap in the Phase 4 hardware simulator and load pruned weights
    model = Phase4QATSparseNet(orig_model, config, device).to(device)
    sparsity_dir = os.path.join(TARGET_FOLDER, "sparsity_training")
    
    # Fallback to the main folder if sparsity_training directory isn't used
    sparse_path = os.path.join(sparsity_dir, SPARSE_CHECKPOINT)
    if not os.path.exists(sparse_path):
        sparse_path = os.path.join(TARGET_FOLDER, SPARSE_CHECKPOINT)
        
    sparse_ckpt = torch.load(sparse_path, map_location=device)
    model.w_in.data.copy_(sparse_ckpt["model_state_dict"]["w_in"])
    model.w_rec.data.copy_(sparse_ckpt["model_state_dict"]["w_rec"])
    model.w_out.data.copy_(sparse_ckpt["model_state_dict"]["w_out"])
    model.mask_in.data.copy_(sparse_ckpt["mask_in"])
    model.mask_rec.data.copy_(sparse_ckpt["mask_rec"])
    model.mask_out.data.copy_(sparse_ckpt["mask_out"])
    
    model.eval()
    all_spikes, all_targets = [], []
    
    # 3. Process the entire training set to map the exact physical timings
    print(">>> Processing dataset to generate physical spike cache...")
    with torch.no_grad():
        for x, y in tqdm(train_loader, desc="Caching Spikes"):
            x = x.to(device)
            spk_out, _ = model(x)
            all_spikes.append(spk_out.cpu())
            all_targets.append(y.cpu())
            
    final_spikes = torch.cat(all_spikes, dim=0)
    final_targets = torch.cat(all_targets, dim=0)
    
    # 4. Save Cache
    cache_path = os.path.join(TARGET_FOLDER, "base_spikes_cache.pt")
    torch.save({"spikes": final_spikes, "targets": final_targets}, cache_path)
    
    print(f"✅ Successfully cached {final_spikes.size(0)} samples to {cache_path}")
    print(">>> You can now run 7_wta_layer_ga.py")

if __name__ == "__main__":
    main()