import os
import torch
import torch.nn as nn
from tqdm import tqdm
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger

import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="torchaudio._backend.utils")

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier" 
MODEL_NAME = "phase3_84.6acc.pth" # Ensure this points to your 87.1% weights

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

class ParetoProfilerNet(nn.Module):
    def __init__(self, orig_model, config, device):
        super().__init__()
        self.device = device
        self.num_hidden = config["num_hidden"]
        self.num_outputs = config["num_outputs"]

        self.w_in = nn.Parameter(orig_model.fc_in.weight.data.clone())
        self.w_rec = nn.Parameter(orig_model.fc_rec.weight.data.clone())
        self.w_out = nn.Parameter(orig_model.fc_out.weight.data.clone())
        
        with torch.no_grad():
            def calc_delta(w):
                return (torch.quantile(torch.abs(w), 0.985) + 1e-8) / 127.0
            
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

            # Dynamic Register Limits (Set via algorithm)
            self.max_mem_hid = torch.full((self.num_hidden,), float('inf'), device=device)
            self.max_mem_out = torch.full((self.num_outputs,), float('inf'), device=device)
            
            # Profiling Buffers
            self.profile_mode = False
            self.max_abs_hid = torch.zeros(self.num_hidden, device=device)
            self.max_abs_out = torch.zeros(self.num_outputs, device=device)

    def set_register_limits(self, int_bits_hid, int_bits_out):
        """Dynamically clamps the hardware registers based on the provided integer bits."""
        self.max_mem_hid = (2.0 ** (int_bits_hid + self.frac_bits_hid)) - 1.0
        self.max_mem_out = (2.0 ** (int_bits_out + self.frac_bits_out)) - 1.0

    def forward(self, x):
        batch = x.size(0)
        time_steps = x.size(1)
        
        # Exact Hardware Weights
        w_in_ste = torch.round(self.w_in / self.delta_in) * self.delta_in
        w_rec_ste = torch.round(self.w_rec / self.delta_rec) * self.delta_rec
        w_out_ste = torch.round(self.w_out / self.delta_out) * self.delta_out

        mem_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        mem_out = torch.zeros(batch, self.num_outputs, device=self.device)
        spk_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        spk_out_rec = []

        # Convert limits from register multipliers to physical LSB voltages
        limit_hid = (self.max_mem_hid * self.lsb_hid).unsqueeze(0)
        limit_out = (self.max_mem_out * self.lsb_out).unsqueeze(0)

        for step in range(time_steps):
            
            cur_in = torch.matmul(x[:, step, :], w_in_ste.t())
            cur_rec = torch.matmul(spk_hid, w_rec_ste.t())
            
            # 1. HIDDEN LAYER
            ideal_mem_hid = (mem_hid * self.beta_hid.unsqueeze(0)) + cur_in + cur_rec
            
            if self.profile_mode:
                self.max_abs_hid = torch.maximum(self.max_abs_hid, torch.abs(ideal_mem_hid).max(dim=0)[0])
            else:
                ideal_mem_hid = torch.clamp(ideal_mem_hid, min=-limit_hid, max=limit_hid)

            mem_hid = torch.floor((ideal_mem_hid / self.lsb_hid.unsqueeze(0)) + 1e-5) * self.lsb_hid.unsqueeze(0)
            
            # Hard threshold evaluation
            spk_hid = (mem_hid >= self.thresh_hid).float()
            mem_hid = mem_hid * (1.0 - spk_hid) 
            
            # 2. OUTPUT LAYER
            cur_out = torch.matmul(spk_hid, w_out_ste.t())
            ideal_mem_out = (mem_out * self.beta_out.unsqueeze(0)) + cur_out
            
            if self.profile_mode:
                self.max_abs_out = torch.maximum(self.max_abs_out, torch.abs(ideal_mem_out).max(dim=0)[0])
            else:
                ideal_mem_out = torch.clamp(ideal_mem_out, min=-limit_out, max=limit_out)

            mem_out = torch.floor((ideal_mem_out / self.lsb_out.unsqueeze(0)) + 1e-5) * self.lsb_out.unsqueeze(0)
            
            spk_out = (mem_out >= self.thresh_out).float()
            mem_out = mem_out * (1.0 - spk_out)
            spk_out_rec.append(spk_out)
            
        return torch.stack(spk_out_rec, dim=1)

def run_evaluation(model, data_loader, device, idx_silence):
    model.eval()
    val_correct, val_total = 0, 0
    with torch.no_grad():
        for x, y in data_loader:
            x, y = x.to(device), y.to(device)
            spk_out = model(x)
            spike_counts = spk_out.sum(dim=1)
            
            max_spikes, raw_preds = spike_counts.max(dim=1)
            preds = torch.where(max_spikes < 10, torch.tensor(idx_silence, device=device), raw_preds)
            
            val_correct += (preds == y).sum().item()
            val_total += y.size(0)
            
    return (val_correct / val_total) * 100 if val_total > 0 else 0.0

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    print(f"\n=== Pareto Profiler: Design Space Exploration ===")
    
    _, test_loader, labels_map = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    idx_silence = labels_map.get("silence", 7)
    
    # Initialize and load model
    orig_model = FastSpikingNet(
        num_inputs=config["num_inputs"], num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"], beta=config["beta"]
    ).to(device)
    
    base_ckpt = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location=device)
    orig_model.load_state_dict(base_ckpt.get("model_state_dict", base_ckpt), strict=False)

    model = ParetoProfilerNet(orig_model, config, device).to(device)
    
    p3_ckpt = torch.load(os.path.join(TARGET_FOLDER, MODEL_NAME), map_location=device)
    p3_state = p3_ckpt.get("model_state_dict", p3_ckpt)
    model.w_in.data.copy_(p3_state["w_in"])
    model.w_rec.data.copy_(p3_state["w_rec"])
    model.w_out.data.copy_(p3_state["w_out"])

    print(">>> 1. Profiling Safe Maximums (Infinite Registers)...")
    model.profile_mode = True
    run_evaluation(model, test_loader, device, idx_silence)
    model.profile_mode = False

    # --- CALCULATE BOUNDARIES (Corrected for pure Integer Bits) ---
    # 1. The Ceiling: Empirical Maximums (Integer bits to hold the highest voltage ever seen)
    max_int_hid = torch.ceil(model.max_abs_hid / model.delta_hid)
    max_int_out = torch.ceil(model.max_abs_out / model.delta_out)
    
    max_bits_hid = torch.ceil(torch.log2(max_int_hid + 1.0)) + 1.0 # +1 for sign bit
    max_bits_out = torch.ceil(torch.log2(max_int_out + 1.0)) + 1.0
    
    # 2. The Floor: The Firing Threshold (Absolute minimum to reach 1.0)
    min_int_bits_hid = torch.ceil(torch.clamp(torch.log2((1.0 / model.delta_hid) + 1.0), min=1.0)) + 1.0
    min_int_bits_out = torch.ceil(torch.clamp(torch.log2((1.0 / model.delta_out) + 1.0), min=1.0)) + 1.0
    
    # Expand scalar floors to match layer dimensions for heterogeneous interpolation
    min_bits_hid = min_int_bits_hid.expand(config["num_hidden"])
    min_bits_out = min_int_bits_out.expand(config["num_outputs"])

    print(f"   Max Int Bits Cap: {max_bits_hid.max().item():.0f} | Min Int Bits Floor: {min_bits_hid[0].item():.0f}")

    print(">>> 2. Sweeping the Design Space (Alpha Interpolation)...")
    results = []
    
    # Micro-Sweep: Zooming in on the 1480 -> 1300 bit cliff
    alphas = torch.linspace(0.66, 0.32, steps=30)
    
    for alpha in alphas:
        # Interpolate heterogeneous bit widths
        test_int_bits_hid = min_bits_hid + torch.round(alpha * (max_bits_hid - min_bits_hid))
        test_int_bits_out = min_bits_out + torch.round(alpha * (max_bits_out - min_bits_out))
        
        # Enforce physical hardware max limits
        model.set_register_limits(test_int_bits_hid, test_int_bits_out)
        
        # Measure accuracy
        acc = run_evaluation(model, test_loader, device, idx_silence)
        
        # Calculate Total Flip-Flops Area Cost (Integer + Fractional Bits)
        total_dffs_hid = (test_int_bits_hid + model.frac_bits_hid).sum().item()
        total_dffs_out = (test_int_bits_out + model.frac_bits_out).sum().item()
        total_dffs = total_dffs_hid + total_dffs_out
        
        results.append({
            "alpha": alpha.item(),
            "acc": acc,
            "dffs": total_dffs,
            "bits_hid": test_int_bits_hid.clone(),
            "bits_out": test_int_bits_out.clone()
        })
        
        print(f"   Alpha: {alpha.item():.2f} | Bits: {total_dffs:4.0f} | Acc: {acc:.1f}%")

    print("\n=======================================================")
    print("               PARETO OPTIMAL FRONTIER                   ")
    print("=======================================================")
    
    # Target thresholds: 86%, 85%, 84%, 82%, 80%
    targets = [86.0, 85.0, 84.0, 82.0, 80.0]
    best_configs = {}
    
    for target in targets:
        # Find all configs that meet the target accuracy
        valid_configs = [r for r in results if r["acc"] >= target]
        if valid_configs:
            # Pick the one with the lowest total DFF cost
            best = min(valid_configs, key=lambda x: x["dffs"])
            best_configs[f"target_{target}"] = best
            
            print(f"Target >= {target}% | Achieved: {best['acc']:.1f}% | Total Bits: {best['dffs']:.0f} (Alpha {best['alpha']:.2f})")
            
            # Save the specific tensor configurations to disk
            torch.save({
                "int_bits_hid": best["bits_hid"],
                "int_bits_out": best["bits_out"]
            }, os.path.join(TARGET_FOLDER, f"pareto_config_{target}.pt"))
            
    print("=======================================================")
    print(">>> All Pareto configurations saved to disk.")
    print(">>> Pick your favorite and we will load it into the final QAT script!")

if __name__ == "__main__":
    main()