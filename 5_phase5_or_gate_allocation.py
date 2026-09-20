import os
import torch
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
    
    print("\n=== Phase 5: Flawless Integer Extraction & Routing ===")
    
    ckpt_path = os.path.join(TARGET_FOLDER, SPARSE_CHECKPOINT)
    ckpt = torch.load(ckpt_path, map_location=device)
    w_in = ckpt["model_state_dict"]["w_in"] * ckpt["mask_in"]
    w_rec = ckpt["model_state_dict"]["w_rec"] * ckpt["mask_rec"]
    w_out = ckpt["model_state_dict"]["w_out"] * ckpt["mask_out"]

    pareto_cfg = torch.load(os.path.join(TARGET_FOLDER, "pareto_config_84.0.pt"), map_location=device)

    with torch.no_grad():
        # Extract the exact same way Phase 4 did!
        raw_delta_in = (torch.quantile(torch.abs(ckpt["model_state_dict"]["w_in"]), 0.985) + 1e-8) / 127.0
        raw_delta_rec = (torch.quantile(torch.abs(ckpt["model_state_dict"]["w_rec"]), 0.985) + 1e-8) / 127.0
        
        global_delta = max(raw_delta_in, raw_delta_rec)
        delta_out = (torch.quantile(torch.abs(ckpt["model_state_dict"]["w_out"]), 0.985) + 1e-8) / 127.0
        
        # Single direct quantization (No double-rounding)
        w_in_int = torch.clamp(torch.round(w_in / global_delta).int(), -128, 127)
        w_rec_int = torch.clamp(torch.round(w_rec / global_delta).int(), -128, 127)
        w_out_int = torch.clamp(torch.round(w_out / delta_out).int(), -128, 127)

    num_hidden = config["num_hidden"]
    num_inputs = config["num_inputs"]
    
    rec_active = [(w_rec_int[i] != 0).sum().item() for i in range(num_hidden)]
    p90_rec = torch.quantile(torch.tensor(rec_active, dtype=torch.float32), 0.90).item()
    p50_rec = torch.quantile(torch.tensor(rec_active, dtype=torch.float32), 0.50).item()
    
    pos_masks_in = torch.zeros(1, num_hidden, num_inputs, dtype=torch.int32)
    neg_masks_in = torch.zeros(1, num_hidden, num_inputs, dtype=torch.int32)
    pos_masks_rec = torch.zeros(3, num_hidden, num_hidden, dtype=torch.int32)
    neg_masks_rec = torch.zeros(3, num_hidden, num_hidden, dtype=torch.int32)
    
    for i in range(num_hidden):
        # Input Gates
        in_p = [(w, 'in', idx) for idx, w in enumerate(w_in_int[i].tolist()) if w > 0]
        in_n = [(abs(w), 'in', idx) for idx, w in enumerate(w_in_int[i].tolist()) if w < 0]
        
        _, p_assign_in = assign_to_or_gates(in_p, 1 if in_p else 0)
        _, n_assign_in = assign_to_or_gates(in_n, 1 if in_n else 0)
        
        if p_assign_in:
            for _, idx in p_assign_in[0]: pos_masks_in[0, i, idx] = 1
        if n_assign_in:
            for _, idx in n_assign_in[0]: neg_masks_in[0, i, idx] = 1
            
        # Recurrent Gates
        rec_p = [(w, 'rec', idx) for idx, w in enumerate(w_rec_int[i].tolist()) if w > 0]
        rec_n = [(abs(w), 'rec', idx) for idx, w in enumerate(w_rec_int[i].tolist()) if w < 0]
        
        def get_g_rec(lst):
            if len(lst) >= p90_rec / 2: return 3
            if len(lst) >= p50_rec / 2: return 2
            return 1 if len(lst) > 0 else 0
            
        _, p_assign_rec = assign_to_or_gates(rec_p, get_g_rec(rec_p))
        _, n_assign_rec = assign_to_or_gates(rec_n, get_g_rec(rec_n))
        
        for g, g_list in enumerate(p_assign_rec):
            for _, idx in g_list: pos_masks_rec[g, i, idx] = 1
        for g, g_list in enumerate(n_assign_rec):
            for _, idx in g_list: neg_masks_rec[g, i, idx] = 1

    manifest = {
        "delta_in": global_delta, # Passed to Phase 6 as global
        "delta_rec": global_delta, # Passed to Phase 6 as global
        "delta_out": delta_out,
        "w_in_int": w_in_int,
        "w_rec_int": w_rec_int,
        "w_out_int": w_out_int,
        "pos_masks_in": pos_masks_in,
        "neg_masks_in": neg_masks_in,
        "pos_masks_rec": pos_masks_rec,
        "neg_masks_rec": neg_masks_rec,
        "int_bits_hid": pareto_cfg["int_bits_hid"],
        "int_bits_out": pareto_cfg["int_bits_out"]
    }

    save_path = os.path.join(TARGET_FOLDER, "pure_integer_model.pt")
    torch.save(manifest, save_path)
    
    print(f"💾 Flawless Integer Blueprint saved to: {save_path}")

if __name__ == "__main__":
    main()