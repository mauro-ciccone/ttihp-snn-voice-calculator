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
SPARSE_CHECKPOINT = "acc86.3_sparsity22.5.pth" 

# Configurations to test: (G_IN, G_REC)
# We test from smallest area footprint to largest.
TEST_CONFIGS = [
    (1, 3),  # Known fail (Phase 6 bug)
    (1, 4),  # Max recurrent, min input
    (2, 1),  # Tight light
    (2, 2),  # Balanced light
    (2, 3),  # Balanced heavy
    (2, 4)   # Known success (Phase 5 fix)
]

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
    dists = (beta_tensor.unsqueeze(1) - VALID_BETAS.to(device).unsqueeze(0)) ** 2
    best_indices = dists.argmin(dim=1)
    return VALID_BETAS.to(device)[best_indices], FRAC_BITS.to(device)[best_indices]

def bit_count(n): return bin(n).count('1')

def assign_to_or_gates(weights_with_indices, num_gates):
    if not weights_with_indices or num_gates == 0: return [], []
    gates = [0] * num_gates
    assignments = [[] for _ in range(num_gates)]
    weights_with_indices.sort(key=lambda x: x[0], reverse=True)
    
    for w_val, src_type, src_idx in weights_with_indices:
        best_gate = -1
        best_score = float('inf')
        for i in range(num_gates):
            overlap = bit_count(gates[i] & w_val)
            score = (overlap * 100) + len(assignments[i])
            if score < best_score:
                best_score = score
                best_gate = i
        gates[best_gate] |= w_val
        assignments[best_gate].append((src_type, src_idx))
    return gates, assignments

class GateSweeperNet(nn.Module):
    def __init__(self, config, device, ckpt, pareto_cfg):
        super().__init__()
        self.device = device
        self.num_hidden = config["num_hidden"]
        self.num_inputs = config["num_inputs"]
        self.num_outputs = config["num_outputs"]

        base_ckpt = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location=device)
        orig_model = FastSpikingNet(
            num_inputs=config["num_inputs"], num_hidden=config["num_hidden"],
            num_outputs=config["num_outputs"], beta=config["beta"]
        ).to(device)
        orig_model.load_state_dict(base_ckpt.get("model_state_dict", base_ckpt), strict=False)

        with torch.no_grad():
            raw_delta_in = (torch.quantile(torch.abs(orig_model.fc_in.weight.data), 0.985) + 1e-8) / 127.0
            raw_delta_rec = (torch.quantile(torch.abs(orig_model.fc_rec.weight.data), 0.985) + 1e-8) / 127.0
            self.global_delta = max(raw_delta_in, raw_delta_rec)
            self.delta_out = (torch.quantile(torch.abs(orig_model.fc_out.weight.data), 0.985) + 1e-8) / 127.0

        w_in_float = ckpt["model_state_dict"]["w_in"].to(device) * ckpt["mask_in"].to(device)
        w_rec_float = ckpt["model_state_dict"]["w_rec"].to(device) * ckpt["mask_rec"].to(device)
        w_out_float = ckpt["model_state_dict"]["w_out"].to(device) * ckpt["mask_out"].to(device)

        self.w_in_int = torch.clamp(torch.round(w_in_float / self.global_delta).int(), -128, 127)
        self.w_rec_int = torch.clamp(torch.round(w_rec_float / self.global_delta).int(), -128, 127)
        self.w_out_int = torch.clamp(torch.round(w_out_float / self.delta_out).int(), -128, 127)

        self.beta_hid, self.frac_bits_hid = get_snapped_hardware(orig_model.lif_hidden.beta.data, device)
        self.beta_out, self.frac_bits_out = get_snapped_hardware(orig_model.lif_out.beta.data, device)
        self.max_mem_hid = (2.0 ** (pareto_cfg["int_bits_hid"].to(device) + self.frac_bits_hid)) - 1.0
        self.max_mem_out = (2.0 ** (pareto_cfg["int_bits_out"].to(device) + self.frac_bits_out)) - 1.0
        self.lsb_hid = self.global_delta / (2.0 ** self.frac_bits_hid)
        self.lsb_out = self.delta_out / (2.0 ** self.frac_bits_out)
        self.thresh_hid = torch.round(1.0 / self.global_delta) * self.global_delta
        self.thresh_out = torch.round(1.0 / self.delta_out) * self.delta_out
        
        self.bit_shifts = torch.tensor([1<<i for i in range(8)], dtype=torch.int32, device=self.device).view(1, 8, 1, 1)

    def configure_gates(self, g_in, g_rec):
        self.g_in = g_in
        self.g_rec = g_rec
        
        pos_masks_in = torch.zeros(g_in, self.num_hidden, self.num_inputs, dtype=torch.int32)
        neg_masks_in = torch.zeros(g_in, self.num_hidden, self.num_inputs, dtype=torch.int32)
        pos_masks_rec = torch.zeros(g_rec, self.num_hidden, self.num_hidden, dtype=torch.int32)
        neg_masks_rec = torch.zeros(g_rec, self.num_hidden, self.num_hidden, dtype=torch.int32)

        for i in range(self.num_hidden):
            in_p = [(w, 'in', idx) for idx, w in enumerate(self.w_in_int[i].tolist()) if w > 0]
            in_n = [(abs(w), 'in', idx) for idx, w in enumerate(self.w_in_int[i].tolist()) if w < 0]
            
            _, p_assign_in = assign_to_or_gates(in_p, min(g_in, len(in_p)))
            _, n_assign_in = assign_to_or_gates(in_n, min(g_in, len(in_n)))
            
            for g, g_list in enumerate(p_assign_in):
                for _, idx in g_list: pos_masks_in[g, i, idx] = 1
            for g, g_list in enumerate(n_assign_in):
                for _, idx in g_list: neg_masks_in[g, i, idx] = 1

            rec_p = [(w, 'rec', idx) for idx, w in enumerate(self.w_rec_int[i].tolist()) if w > 0]
            rec_n = [(abs(w), 'rec', idx) for idx, w in enumerate(self.w_rec_int[i].tolist()) if w < 0]
                
            _, p_assign_rec = assign_to_or_gates(rec_p, min(g_rec, len(rec_p)))
            _, n_assign_rec = assign_to_or_gates(rec_n, min(g_rec, len(rec_n)))
            
            for g, g_list in enumerate(p_assign_rec):
                for _, idx in g_list: pos_masks_rec[g, i, idx] = 1
            for g, g_list in enumerate(n_assign_rec):
                for _, idx in g_list: neg_masks_rec[g, i, idx] = 1

        w_in_abs = torch.abs(self.w_in_int).to(self.device)
        w_rec_abs = torch.abs(self.w_rec_int).to(self.device)

        def make_mats(masks, w_abs, num_gates, in_dim):
            masks = masks.to(self.device)
            if num_gates == 0:
                # Return empty tensor if a layer theoretically drops to 0 gates
                return torch.zeros(0, in_dim, self.num_hidden, device=self.device)
            mats = []
            for g in range(num_gates):
                w_gate = w_abs * masks[g]
                bits = [((w_gate & (1 << b)) != 0).float().t() for b in range(8)]
                mats.append(torch.stack(bits, dim=0))
            return torch.stack(mats, dim=0).view(num_gates * 8, in_dim, self.num_hidden)

        self.pos_mat_in = make_mats(pos_masks_in, w_in_abs, g_in, self.num_inputs)
        self.neg_mat_in = make_mats(neg_masks_in, w_in_abs, g_in, self.num_inputs)
        self.pos_mat_rec = make_mats(pos_masks_rec, w_rec_abs, g_rec, self.num_hidden)
        self.neg_mat_rec = make_mats(neg_masks_rec, w_rec_abs, g_rec, self.num_hidden)

    def forward(self, x):
        batch = x.size(0)
        time_steps = x.size(1)
        
        mem_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        mem_out = torch.zeros(batch, self.num_outputs, device=self.device)
        spk_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        spk_out_rec = []

        for step in range(time_steps):
            x_batched = x[:, step, :].unsqueeze(0)
            spk_batched = spk_hid.unsqueeze(0)
            
            # OR-Gate Evaluation
            hw_in_pos = ((torch.matmul(x_batched, self.pos_mat_in) > 0).int().view(self.g_in, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0,1))
            hw_in_neg = ((torch.matmul(x_batched, self.neg_mat_in) > 0).int().view(self.g_in, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0,1))
            hw_rec_pos = ((torch.matmul(spk_batched, self.pos_mat_rec) > 0).int().view(self.g_rec, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0,1))
            hw_rec_neg = ((torch.matmul(spk_batched, self.neg_mat_rec) > 0).int().view(self.g_rec, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0,1))
            
            hw_sum_int = (hw_in_pos - hw_in_neg) + (hw_rec_pos - hw_rec_neg)
            hw_sum_float = hw_sum_int.float() * self.global_delta
            
            # ALU Integration
            ideal_mem_hid = (mem_hid * self.beta_hid.unsqueeze(0)) + hw_sum_float
            limit_hid = (self.max_mem_hid * self.lsb_hid).unsqueeze(0)
            ideal_mem_hid = torch.clamp(ideal_mem_hid, min=-limit_hid, max=limit_hid)
            mem_hid = torch.floor((ideal_mem_hid / self.lsb_hid.unsqueeze(0)) + 1e-5) * self.lsb_hid.unsqueeze(0)
            
            spk_hid = (mem_hid >= self.thresh_hid).float()
            mem_hid = mem_hid * (1.0 - spk_hid) 
            
            cur_out = torch.matmul(spk_hid, self.w_out_int.float().t()) * self.delta_out
            ideal_mem_out = (mem_out * self.beta_out.unsqueeze(0)) + cur_out
            limit_out = (self.max_mem_out * self.lsb_out).unsqueeze(0)
            ideal_mem_out = torch.clamp(ideal_mem_out, min=-limit_out, max=limit_out)
            mem_out = torch.floor((ideal_mem_out / self.lsb_out.unsqueeze(0)) + 1e-5) * self.lsb_out.unsqueeze(0)
            
            spk_out = (mem_out >= self.thresh_out).float()
            mem_out = mem_out * (1.0 - spk_out)
            spk_out_rec.append(spk_out)
            
        return torch.stack(spk_out_rec, dim=1)

def evaluate_setup(model, data_loader, device, idx_silence):
    model.eval()
    val_correct, val_total = 0, 0
    with torch.no_grad():
        for x, y in tqdm(data_loader, desc=f"Testing G_IN={model.g_in} G_REC={model.g_rec}", leave=False):
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
    
    print("\n=== Phase 5b: HARDWARE AREA SWEEPER (Pareto Search) ===")
    
    train_loader, test_loader, labels_map = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    idx_silence = labels_map.get("silence", 7)
    
    ckpt = torch.load(os.path.join(TARGET_FOLDER, SPARSE_CHECKPOINT), map_location=device)
    pareto_cfg = torch.load(os.path.join(TARGET_FOLDER, "pareto_config_84.0.pt"), map_location=device)
    
    model = GateSweeperNet(config, device, ckpt, pareto_cfg).to(device)

    results = []
    best_acc = 0.0
    optimal_config = None

    print("\nSweeping OR-Gate Configurations...")
    print("-" * 55)
    print(f"| {'G_IN':<4} | {'G_REC':<5} | {'Total Gates/Neuron':<18} | {'Accuracy':<10} |")
    print("-" * 55)

    for g_in, g_rec in TEST_CONFIGS:
        model.configure_gates(g_in, g_rec)
        acc = evaluate_setup(model, test_loader, device, idx_silence)
        
        total_gates = 2 * (g_in + g_rec) # Multiplied by 2 for Pos/Neg polarities
        
        # We will flag it if it's within 1% of the baseline 86.5%
        is_viable = "🌟" if acc >= 85.5 else ""
        print(f"| {g_in:<4} | {g_rec:<5} | {total_gates:<18} | {acc:>6.2f}% {is_viable:<2} |")
        
        results.append((total_gates, acc, g_in, g_rec))
        if acc > best_acc:
            best_acc = acc
            optimal_config = (g_in, g_rec)

    print("-" * 55)
    
    # Pick the smallest architecture that passes the viability threshold (>85.5%)
    viable_configs = [res for res in results if res[1] >= 85.5]
    if viable_configs:
        viable_configs.sort(key=lambda x: x[0]) # Sort by total gates (smallest first)
        best_minimal = viable_configs[0]
        print(f"\n🏆 Optimal Minimal Configuration Found!")
        print(f"   Using G_IN={best_minimal[2]}, G_REC={best_minimal[3]} ({best_minimal[0]} Total Gates/Neuron) achieves {best_minimal[1]:.2f}%")
        print(f"   You can safely use these values in your Phase 5 Ultimate script for final export.")
    else:
        print("\n⚠️ No configuration passed the 85.5% viability threshold.")
        print(f"   Your best option is G_IN={optimal_config[0]}, G_REC={optimal_config[1]} at {best_acc:.2f}%.")

if __name__ == "__main__":
    main()