import os
import torch
import torch.nn as nn
from tqdm import tqdm
from dataset_cached import get_cached_dataloaders
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier" 
SPARSE_CHECKPOINT = "acc86.3_sparsity22.5.pth" # Update to your exact phase 4 filename

def bit_count(n):
    return bin(n).count('1')

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

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    print("\n=== Phase 5: DATA-DRIVEN OR-GATE DIAGNOSTIC ===")
    
    ckpt_path = os.path.join(TARGET_FOLDER, SPARSE_CHECKPOINT)
    ckpt = torch.load(ckpt_path, map_location=device)
    w_in = ckpt["model_state_dict"]["w_in"] * ckpt["mask_in"]
    w_rec = ckpt["model_state_dict"]["w_rec"] * ckpt["mask_rec"]

    # 1. Extract Unified Integers
    with torch.no_grad():
        raw_delta_in = (torch.quantile(torch.abs(ckpt["model_state_dict"]["w_in"]), 0.985) + 1e-8) / 127.0
        raw_delta_rec = (torch.quantile(torch.abs(ckpt["model_state_dict"]["w_rec"]), 0.985) + 1e-8) / 127.0
        global_delta = max(raw_delta_in, raw_delta_rec)
        
        w_in_int = torch.clamp(torch.round((w_in / global_delta) * global_delta / global_delta).int(), -128, 127)
        w_rec_int = torch.clamp(torch.round((w_rec / global_delta) * global_delta / global_delta).int(), -128, 127)

    num_hidden = config["num_hidden"]
    num_inputs = config["num_inputs"]
    
    # 2. Gate Allocation
    pos_masks_in = torch.zeros(1, num_hidden, num_inputs, dtype=torch.int32)
    neg_masks_in = torch.zeros(1, num_hidden, num_inputs, dtype=torch.int32)
    pos_masks_rec = torch.zeros(3, num_hidden, num_hidden, dtype=torch.int32)
    neg_masks_rec = torch.zeros(3, num_hidden, num_hidden, dtype=torch.int32)

    for i in range(num_hidden):
        # Input Gates (Fixed 1)
        in_p = [(w, 'in', idx) for idx, w in enumerate(w_in_int[i].tolist()) if w > 0]
        in_n = [(abs(w), 'in', idx) for idx, w in enumerate(w_in_int[i].tolist()) if w < 0]
        
        _, p_assign_in = assign_to_or_gates(in_p, 1 if in_p else 0)
        _, n_assign_in = assign_to_or_gates(in_n, 1 if in_n else 0)
        
        if p_assign_in:
            for _, idx in p_assign_in[0]: pos_masks_in[0, i, idx] = 1
        if n_assign_in:
            for _, idx in n_assign_in[0]: neg_masks_in[0, i, idx] = 1
            
        # Recurrent Gates (Fixed 3 for maximum bandwidth)
        rec_p = [(w, 'rec', idx) for idx, w in enumerate(w_rec_int[i].tolist()) if w > 0]
        rec_n = [(abs(w), 'rec', idx) for idx, w in enumerate(w_rec_int[i].tolist()) if w < 0]
        
        _, p_assign_rec = assign_to_or_gates(rec_p, 3 if rec_p else 0)
        _, n_assign_rec = assign_to_or_gates(rec_n, 3 if rec_n else 0)
        
        for g, g_list in enumerate(p_assign_rec):
            for _, idx in g_list: pos_masks_rec[g, i, idx] = 1
        for g, g_list in enumerate(n_assign_rec):
            for _, idx in g_list: neg_masks_rec[g, i, idx] = 1

    # 3. REAL DATA TWIN-ENGINE SIMULATION
    print("\n>>> Simulating Real Audio Batch through OR-Gates...")
    train_loader, _, _ = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    x_batch, y_batch = next(iter(train_loader))
    batch_size, time_steps, _ = x_batch.shape

    w_in_abs = torch.abs(w_in_int)
    w_rec_abs = torch.abs(w_rec_int)

    def _build_mats(gate_masks, w_abs, num_gates, in_dim):
        mats = []
        for g in range(num_gates):
            w_gate = w_abs * gate_masks[g]
            bits = [((w_gate & (1 << b)) != 0).float().t() for b in range(8)]
            mats.append(torch.stack(bits, dim=0))
        return torch.stack(mats, dim=0).view(num_gates * 8, in_dim, num_hidden)

    pos_mat_in = _build_mats(pos_masks_in, w_in_abs, 1, num_inputs)
    neg_mat_in = _build_mats(neg_masks_in, w_in_abs, 1, num_inputs)
    pos_mat_rec = _build_mats(pos_masks_rec, w_rec_abs, 3, num_hidden)
    neg_mat_rec = _build_mats(neg_masks_rec, w_rec_abs, 3, num_hidden)
    
    bit_shifts = torch.tensor([1<<i for i in range(8)], dtype=torch.int32).view(1, 8, 1, num_hidden)

    total_ideal_in_pos, total_ideal_in_neg = 0, 0
    total_hw_in_pos, total_hw_in_neg = 0, 0
    
    total_ideal_rec_pos, total_ideal_rec_neg = 0, 0
    total_hw_rec_pos, total_hw_rec_neg = 0, 0

    spk_ideal = torch.zeros(batch_size, num_hidden)
    
    for step in tqdm(range(time_steps), desc="Timesteps"):
        x_step = x_batch[:, step, :]
        
        # --- IDEAL MATH ---
        w_in_pos_ideal = torch.relu(w_in_int.float())
        w_in_neg_ideal = torch.relu(-w_in_int.float())
        ideal_in_pos = torch.matmul(x_step, w_in_pos_ideal.t())
        ideal_in_neg = torch.matmul(x_step, w_in_neg_ideal.t())
        
        w_rec_pos_ideal = torch.relu(w_rec_int.float())
        w_rec_neg_ideal = torch.relu(-w_rec_int.float())
        ideal_rec_pos = torch.matmul(spk_ideal, w_rec_pos_ideal.t())
        ideal_rec_neg = torch.matmul(spk_ideal, w_rec_neg_ideal.t())
        
        # --- HARDWARE SIMULATION ---
        x_batched = x_step.unsqueeze(0)
        spk_batched = spk_ideal.unsqueeze(0)
        
        hw_in_pos = ((torch.matmul(x_batched, pos_mat_in) > 0).int().view(1, 8, batch_size, num_hidden) * bit_shifts).sum(dim=(0,1))
        hw_in_neg = ((torch.matmul(x_batched, neg_mat_in) > 0).int().view(1, 8, batch_size, num_hidden) * bit_shifts).sum(dim=(0,1))
        
        hw_rec_pos = ((torch.matmul(spk_batched, pos_mat_rec) > 0).int().view(3, 8, batch_size, num_hidden) * bit_shifts).sum(dim=(0,1))
        hw_rec_neg = ((torch.matmul(spk_batched, neg_mat_rec) > 0).int().view(3, 8, batch_size, num_hidden) * bit_shifts).sum(dim=(0,1))
        
        # Track Cumulative Sums
        total_ideal_in_pos += ideal_in_pos.sum().item()
        total_ideal_in_neg += ideal_in_neg.sum().item()
        total_hw_in_pos += hw_in_pos.sum().item()
        total_hw_in_neg += hw_in_neg.sum().item()
        
        total_ideal_rec_pos += ideal_rec_pos.sum().item()
        total_ideal_rec_neg += ideal_rec_neg.sum().item()
        total_hw_rec_pos += hw_rec_pos.sum().item()
        total_hw_rec_neg += hw_rec_neg.sum().item()
        
        # Dummy trigger for next step
        spk_ideal = ((ideal_in_pos - ideal_in_neg) + (ideal_rec_pos - ideal_rec_neg) > 10).float()

    print("\n==================================================")
    print("      REAL DATA BIT-COLLISION ANALYSIS            ")
    print("==================================================")
    
    in_pos_loss = 100 * (1 - (total_hw_in_pos / (total_ideal_in_pos + 1e-5)))
    in_neg_loss = 100 * (1 - (total_hw_in_neg / (total_ideal_in_neg + 1e-5)))
    
    rec_pos_loss = 100 * (1 - (total_hw_rec_pos / (total_ideal_rec_pos + 1e-5)))
    rec_neg_loss = 100 * (1 - (total_hw_rec_neg / (total_ideal_rec_neg + 1e-5)))

    print("\n--- COCHLEA INPUT BUS (1 Gate per polarity) ---")
    print(f"Excitatory (+) Math vs HW : {int(total_ideal_in_pos)} vs {int(total_hw_in_pos)} (Lost {in_pos_loss:.1f}%)")
    print(f"Inhibitory (-) Math vs HW : {int(total_ideal_in_neg)} vs {int(total_hw_in_neg)} (Lost {in_neg_loss:.1f}%)")
    
    print("\n--- RECURRENT BUS (3 Gates per polarity) ---")
    print(f"Excitatory (+) Math vs HW : {int(total_ideal_rec_pos)} vs {int(total_hw_rec_pos)} (Lost {rec_pos_loss:.1f}%)")
    print(f"Inhibitory (-) Math vs HW : {int(total_ideal_rec_neg)} vs {int(total_hw_rec_neg)} (Lost {rec_neg_loss:.1f}%)")
    
    print("\n==================================================")
    if rec_neg_loss > rec_pos_loss * 1.5:
        print("🚨 DIAGNOSIS CONFIRMED: FATAL LOSS OF INHIBITION")
        print("The network is colliding heavily on the Recurrent Negative weights.")
        print("This deletes the network's brakes, causing the hyperactivity (52% Acc).")
        print("SOLUTION: We must scale up the number of negative recurrent OR-gates.")
    else:
        print("The loss is symmetrical. The problem may lie in integer thresholds.")

if __name__ == "__main__":
    main()