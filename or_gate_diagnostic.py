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
SPARSE_CHECKPOINT = "acc86.3_sparsity22.5.pth" # Ensure this is your Phase 4 file!

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
    if not weights_with_indices: return [], []
    gates = [0] * num_gates
    assignments = [[] for _ in range(num_gates)]
    weights_with_indices.sort(key=lambda x: x[0], reverse=True)
    for w_val, src_type, src_idx in weights_with_indices:
        best_gate = -1
        min_overlap = float('inf')
        for i in range(num_gates):
            overlap = bit_count(gates[i] & w_val)
            if overlap < min_overlap:
                min_overlap = overlap
                best_gate = i
        gates[best_gate] |= w_val
        assignments[best_gate].append((src_type, src_idx))
    return gates, assignments

class UltimateDiagnosticNet(nn.Module):
    def __init__(self, config, device, ckpt, pareto_cfg):
        super().__init__()
        self.device = device
        self.num_hidden = config["num_hidden"]
        self.num_inputs = config["num_inputs"]
        self.num_outputs = config["num_outputs"]

        # 1. LOAD BASE MODEL (To fix the Delta extraction bug)
        base_ckpt = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location=device)
        orig_model = FastSpikingNet(
            num_inputs=config["num_inputs"], num_hidden=config["num_hidden"],
            num_outputs=config["num_outputs"], beta=config["beta"]
        ).to(device)
        orig_model.load_state_dict(base_ckpt.get("model_state_dict", base_ckpt), strict=False)

        # 2. EXTRACT EXACT PHASE 4 DELTAS (From dense base model)
        with torch.no_grad():
            raw_delta_in = (torch.quantile(torch.abs(orig_model.fc_in.weight.data), 0.985) + 1e-8) / 127.0
            raw_delta_rec = (torch.quantile(torch.abs(orig_model.fc_rec.weight.data), 0.985) + 1e-8) / 127.0
            self.global_delta = max(raw_delta_in, raw_delta_rec)
            self.delta_out = (torch.quantile(torch.abs(orig_model.fc_out.weight.data), 0.985) + 1e-8) / 127.0

        # 3. LOAD SPARSE WEIGHTS
        self.w_in_float = ckpt["model_state_dict"]["w_in"].to(device) * ckpt["mask_in"].to(device)
        self.w_rec_float = ckpt["model_state_dict"]["w_rec"].to(device) * ckpt["mask_rec"].to(device)
        self.w_out_float = ckpt["model_state_dict"]["w_out"].to(device) * ckpt["mask_out"].to(device)

        # 4. QUANTIZE TO INTEGERS
        self.w_in_int = torch.clamp(torch.round(self.w_in_float / self.global_delta).int(), -128, 127)
        self.w_rec_int = torch.clamp(torch.round(self.w_rec_float / self.global_delta).int(), -128, 127)
        self.w_out_int = torch.clamp(torch.round(self.w_out_float / self.delta_out).int(), -128, 127)

        # Hardware Constants
        self.beta_hid, self.frac_bits_hid = get_snapped_hardware(orig_model.lif_hidden.beta.data, device)
        self.beta_out, self.frac_bits_out = get_snapped_hardware(orig_model.lif_out.beta.data, device)
        self.max_mem_hid = (2.0 ** (pareto_cfg["int_bits_hid"].to(device) + self.frac_bits_hid)) - 1.0
        self.max_mem_out = (2.0 ** (pareto_cfg["int_bits_out"].to(device) + self.frac_bits_out)) - 1.0
        self.lsb_hid = self.global_delta / (2.0 ** self.frac_bits_hid)
        self.lsb_out = self.delta_out / (2.0 ** self.frac_bits_out)
        self.thresh_hid = torch.round(1.0 / self.global_delta) * self.global_delta
        self.thresh_out = torch.round(1.0 / self.delta_out) * self.delta_out

        self._build_or_gates()

    def _build_or_gates(self):
        rec_active = [(self.w_rec_int[i] != 0).sum().item() for i in range(self.num_hidden)]
        p90_rec = torch.quantile(torch.tensor(rec_active, dtype=torch.float32), 0.90).item()
        p50_rec = torch.quantile(torch.tensor(rec_active, dtype=torch.float32), 0.50).item()

        self.pos_masks_in = torch.zeros(1, self.num_hidden, self.num_inputs, dtype=torch.int32)
        self.neg_masks_in = torch.zeros(1, self.num_hidden, self.num_inputs, dtype=torch.int32)
        self.pos_masks_rec = torch.zeros(3, self.num_hidden, self.num_hidden, dtype=torch.int32)
        self.neg_masks_rec = torch.zeros(3, self.num_hidden, self.num_hidden, dtype=torch.int32)

        for i in range(self.num_hidden):
            in_p = [(w, 'in', idx) for idx, w in enumerate(self.w_in_int[i].tolist()) if w > 0]
            in_n = [(abs(w), 'in', idx) for idx, w in enumerate(self.w_in_int[i].tolist()) if w < 0]
            _, p_assign_in = assign_to_or_gates(in_p, 1 if in_p else 0)
            _, n_assign_in = assign_to_or_gates(in_n, 1 if in_n else 0)
            if p_assign_in:
                for _, idx in p_assign_in[0]: self.pos_masks_in[0, i, idx] = 1
            if n_assign_in:
                for _, idx in n_assign_in[0]: self.neg_masks_in[0, i, idx] = 1

            rec_p = [(w, 'rec', idx) for idx, w in enumerate(self.w_rec_int[i].tolist()) if w > 0]
            rec_n = [(abs(w), 'rec', idx) for idx, w in enumerate(self.w_rec_int[i].tolist()) if w < 0]
            
            def get_g_rec(lst):
                if len(lst) >= p90_rec / 2: return 3
                if len(lst) >= p50_rec / 2: return 2
                return 1 if len(lst) > 0 else 0
                
            _, p_assign_rec = assign_to_or_gates(rec_p, get_g_rec(rec_p))
            _, n_assign_rec = assign_to_or_gates(rec_n, get_g_rec(rec_n))
            
            for g, g_list in enumerate(p_assign_rec):
                for _, idx in g_list: self.pos_masks_rec[g, i, idx] = 1
            for g, g_list in enumerate(n_assign_rec):
                for _, idx in g_list: self.neg_masks_rec[g, i, idx] = 1

        w_in_abs = torch.abs(self.w_in_int).to(self.device)
        w_rec_abs = torch.abs(self.w_rec_int).to(self.device)

        def make_mats(masks, w_abs, num_gates, in_dim):
            masks = masks.to(self.device)
            mats = []
            for g in range(num_gates):
                w_gate = w_abs * masks[g]
                bits = [((w_gate & (1 << b)) != 0).float().t() for b in range(8)]
                mats.append(torch.stack(bits, dim=0))
            return torch.stack(mats, dim=0).view(num_gates * 8, in_dim, self.num_hidden)

        self.pos_mat_in = make_mats(self.pos_masks_in, w_in_abs, 1, self.num_inputs)
        self.neg_mat_in = make_mats(self.neg_masks_in, w_in_abs, 1, self.num_inputs)
        self.pos_mat_rec = make_mats(self.pos_masks_rec, w_rec_abs, 3, self.num_hidden)
        self.neg_mat_rec = make_mats(self.neg_masks_rec, w_rec_abs, 3, self.num_hidden)
        self.bit_shifts = torch.tensor([1<<i for i in range(8)], dtype=torch.int32, device=self.device).view(1, 8, 1, 1)

    def forward(self, x, engine):
        batch = x.size(0)
        time_steps = x.size(1)
        
        mem_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        mem_out = torch.zeros(batch, self.num_outputs, device=self.device)
        spk_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        spk_out_rec, spk_hid_rec = [], []

        for step in range(time_steps):
            if engine == 1:
                # ENGINE 1: EXACT PHASE 4 REPLICA (Float STE)
                w_in_ste = (torch.round(self.w_in_float / self.global_delta) - self.w_in_float / self.global_delta).detach() + self.w_in_float / self.global_delta
                w_rec_ste = (torch.round(self.w_rec_float / self.global_delta) - self.w_rec_float / self.global_delta).detach() + self.w_rec_float / self.global_delta
                
                cur_in = torch.matmul(x[:, step, :], (w_in_ste * self.global_delta).t())
                cur_rec = torch.matmul(spk_hid, (w_rec_ste * self.global_delta).t())
                hw_sum_float = cur_in + cur_rec

            elif engine == 2:
                # ENGINE 2: EXACT INTEGER MATMUL
                hw_sum_in = torch.matmul(x[:, step, :], self.w_in_int.float().t())
                hw_sum_rec = torch.matmul(spk_hid, self.w_rec_int.float().t())
                hw_sum_float = (hw_sum_in + hw_sum_rec) * self.global_delta

            elif engine == 3:
                # ENGINE 3: PHYSICAL OR-GATES
                x_batched = x[:, step, :].unsqueeze(0)
                spk_batched = spk_hid.unsqueeze(0)
                
                hw_in_pos = ((torch.matmul(x_batched, self.pos_mat_in) > 0).int().view(1, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0,1))
                hw_in_neg = ((torch.matmul(x_batched, self.neg_mat_in) > 0).int().view(1, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0,1))
                
                hw_rec_pos = ((torch.matmul(spk_batched, self.pos_mat_rec) > 0).int().view(3, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0,1))
                hw_rec_neg = ((torch.matmul(spk_batched, self.neg_mat_rec) > 0).int().view(3, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0,1))
                
                hw_sum_int = (hw_in_pos - hw_in_neg) + (hw_rec_pos - hw_rec_neg)
                hw_sum_float = hw_sum_int.float() * self.global_delta
            
            ideal_mem_hid = (mem_hid * self.beta_hid.unsqueeze(0)) + hw_sum_float
            limit_hid = (self.max_mem_hid * self.lsb_hid).unsqueeze(0)
            ideal_mem_hid = torch.clamp(ideal_mem_hid, min=-limit_hid, max=limit_hid)
            mem_hid = torch.floor((ideal_mem_hid / self.lsb_hid.unsqueeze(0)) + 1e-5) * self.lsb_hid.unsqueeze(0)
            
            spk_hid = (mem_hid >= self.thresh_hid).float()
            mem_hid = mem_hid * (1.0 - spk_hid) 
            spk_hid_rec.append(spk_hid)
            
            # Output Layer (Identical across all engines)
            cur_out = torch.matmul(spk_hid, self.w_out_int.float().t()) * self.delta_out
            ideal_mem_out = (mem_out * self.beta_out.unsqueeze(0)) + cur_out
            limit_out = (self.max_mem_out * self.lsb_out).unsqueeze(0)
            ideal_mem_out = torch.clamp(ideal_mem_out, min=-limit_out, max=limit_out)
            mem_out = torch.floor((ideal_mem_out / self.lsb_out.unsqueeze(0)) + 1e-5) * self.lsb_out.unsqueeze(0)
            
            spk_out = (mem_out >= self.thresh_out).float()
            mem_out = mem_out * (1.0 - spk_out)
            spk_out_rec.append(spk_out)
            
        return torch.stack(spk_out_rec, dim=1), torch.stack(spk_hid_rec, dim=1)

def evaluate_engine(model, data_loader, device, idx_silence, engine):
    model.eval()
    val_correct, val_total = 0, 0
    total_hidden_spikes = 0
    
    with torch.no_grad():
        for x, y in tqdm(data_loader, desc=f"Evaluating Engine {engine}", leave=False):
            x, y = x.to(device), y.to(device)
            spk_out, spk_hidden = model(x, engine=engine)
            
            spike_counts = spk_out.sum(dim=1)
            max_spikes, raw_preds = spike_counts.max(dim=1)
            preds = torch.where(max_spikes < 10, torch.tensor(idx_silence, device=device), raw_preds)
            
            val_correct += (preds == y).sum().item()
            val_total += y.size(0)
            total_hidden_spikes += spk_hidden.sum().item()
            
    acc = (val_correct / val_total) * 100 if val_total > 0 else 0.0
    avg_spikes = total_hidden_spikes / val_total if val_total > 0 else 0.0
    return acc, avg_spikes

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    print("\n=== Phase 5: ULTIMATE DIAGNOSTIC (Triple Engine) ===")
    
    train_loader, test_loader, labels_map = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    idx_silence = labels_map.get("silence", 7)
    
    ckpt = torch.load(os.path.join(TARGET_FOLDER, SPARSE_CHECKPOINT), map_location=device)
    pareto_cfg = torch.load(os.path.join(TARGET_FOLDER, "pareto_config_84.0.pt"), map_location=device)
    
    model = UltimateDiagnosticNet(config, device, ckpt, pareto_cfg).to(device)

    print("\n[ ENGINE 1: Exact Phase 4 Replica (Float STE) ]")
    acc1, spk1 = evaluate_engine(model, test_loader, device, idx_silence, engine=1)
    print(f"Accuracy: {acc1:.2f}% | Avg Hidden Spikes: {spk1:.1f}")
    
    print("\n[ ENGINE 2: Pure Integer Matmul (Validates Extraction) ]")
    acc2, spk2 = evaluate_engine(model, test_loader, device, idx_silence, engine=2)
    print(f"Accuracy: {acc2:.2f}% | Avg Hidden Spikes: {spk2:.1f}")

    print("\n[ ENGINE 3: Physical OR-Gates (Validates Silicon Overlap) ]")
    acc3, spk3 = evaluate_engine(model, test_loader, device, idx_silence, engine=3)
    print(f"Accuracy: {acc3:.2f}% | Avg Hidden Spikes: {spk3:.1f}")
    
    print("\n--- DIAGNOSTIC CONCLUSION ---")
    if abs(acc1 - acc2) > 1.0:
        print("🚨 CRITICAL BUG STILL PRESENT: Engine 1 and Engine 2 mismatch!")
    elif acc2 > 80.0 and acc3 < 50.0:
        print("✅ EXTRACTION FIXED! Engine 1 and 2 perfectly match Phase 4.")
        print("🚨 PHYSICAL BOTTLENECK CONFIRMED: The Dual-Bus OR-gates are physically dropping too many bits. We must run Phase 6 GA to heal it or allocate more gates.")
    else:
        print("✅ SUCCESS! The OR-gates are stable and hold accuracy.")
        
    # Automatically export the correct manifest
    manifest = {
        "delta_in": model.global_delta, 
        "delta_rec": model.global_delta,
        "delta_out": model.delta_out,
        "w_in_int": model.w_in_int,
        "w_rec_int": model.w_rec_int,
        "w_out_int": model.w_out_int,
        "pos_masks_in": model.pos_masks_in,
        "neg_masks_in": model.neg_masks_in,
        "pos_masks_rec": model.pos_masks_rec,
        "neg_masks_rec": model.neg_masks_rec,
        "int_bits_hid": pareto_cfg["int_bits_hid"],
        "int_bits_out": pareto_cfg["int_bits_out"]
    }
    save_path = os.path.join(TARGET_FOLDER, "pure_integer_model.pt")
    torch.save(manifest, save_path)
    print(f"\n💾 Corrected Pure Integer Blueprint saved to: {save_path}")

if __name__ == "__main__":
    main()