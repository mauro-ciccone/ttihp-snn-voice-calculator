import os
import torch
from utils_ledger import load_ledger
from model import FastSpikingNet

TARGET_FOLDER = "experiments/0924_1200_64_neuron_model" 
SPARSE_CHECKPOINT = "acc77.4_sparsity16.8.pth" 

# --- FINAL HARDWARE BUDGET ---
G_IN = 2   
G_REC = 1

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

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    print(f"\n=== FINAL EXPORT: Compiling Tapeout Model (G_IN={G_IN}, G_REC={G_REC}) ===")
    
    ckpt = torch.load(os.path.join(TARGET_FOLDER, SPARSE_CHECKPOINT), map_location=device)
    pareto_cfg = torch.load(os.path.join(TARGET_FOLDER, "pareto_config_65.0.pt"), map_location=device)
    
    # 1. Recover original dense model for correct base deltas
    base_ckpt = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location=device)
    orig_model = FastSpikingNet(
        num_inputs=config["num_inputs"], num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"], beta=config["beta"]
    ).to(device)
    orig_model.load_state_dict(base_ckpt.get("model_state_dict", base_ckpt), strict=False)

    with torch.no_grad():
        raw_delta_in = (torch.quantile(torch.abs(orig_model.fc_in.weight.data), 0.985) + 1e-8) / 127.0
        raw_delta_rec = (torch.quantile(torch.abs(orig_model.fc_rec.weight.data), 0.985) + 1e-8) / 127.0
        global_delta = max(raw_delta_in, raw_delta_rec)
        delta_out = (torch.quantile(torch.abs(orig_model.fc_out.weight.data), 0.985) + 1e-8) / 127.0

    # 2. Extract and clamp integers
    w_in_float = ckpt["model_state_dict"]["w_in"].to(device) * ckpt["mask_in"].to(device)
    w_rec_float = ckpt["model_state_dict"]["w_rec"].to(device) * ckpt["mask_rec"].to(device)
    w_out_float = ckpt["model_state_dict"]["w_out"].to(device) * ckpt["mask_out"].to(device)

    w_in_int = torch.clamp(torch.round(w_in_float / global_delta).int(), -128, 127)
    w_rec_int = torch.clamp(torch.round(w_rec_float / global_delta).int(), -128, 127)
    w_out_int = torch.clamp(torch.round(w_out_float / delta_out).int(), -128, 127)

    num_hidden = config["num_hidden"]
    num_inputs = config["num_inputs"]

    pos_masks_in = torch.zeros(G_IN, num_hidden, num_inputs, dtype=torch.int32)
    neg_masks_in = torch.zeros(G_IN, num_hidden, num_inputs, dtype=torch.int32)
    pos_masks_rec = torch.zeros(G_REC, num_hidden, num_hidden, dtype=torch.int32)
    neg_masks_rec = torch.zeros(G_REC, num_hidden, num_hidden, dtype=torch.int32)

    # 3. Perform Greedy Load-Balanced Allocation
    for i in range(num_hidden):
        in_p = [(w, 'in', idx) for idx, w in enumerate(w_in_int[i].tolist()) if w > 0]
        in_n = [(abs(w), 'in', idx) for idx, w in enumerate(w_in_int[i].tolist()) if w < 0]
        
        _, p_assign_in = assign_to_or_gates(in_p, min(G_IN, len(in_p)))
        _, n_assign_in = assign_to_or_gates(in_n, min(G_IN, len(in_n)))
        
        for g, g_list in enumerate(p_assign_in):
            for _, idx in g_list: pos_masks_in[g, i, idx] = 1
        for g, g_list in enumerate(n_assign_in):
            for _, idx in g_list: neg_masks_in[g, i, idx] = 1

        rec_p = [(w, 'rec', idx) for idx, w in enumerate(w_rec_int[i].tolist()) if w > 0]
        rec_n = [(abs(w), 'rec', idx) for idx, w in enumerate(w_rec_int[i].tolist()) if w < 0]
            
        _, p_assign_rec = assign_to_or_gates(rec_p, min(G_REC, len(rec_p)))
        _, n_assign_rec = assign_to_or_gates(rec_n, min(G_REC, len(rec_n)))
        
        for g, g_list in enumerate(p_assign_rec):
            for _, idx in g_list: pos_masks_rec[g, i, idx] = 1
        for g, g_list in enumerate(n_assign_rec):
            for _, idx in g_list: neg_masks_rec[g, i, idx] = 1

    # 4. Pack final Verilog manifest
    manifest = {
        "delta_in": global_delta, 
        "delta_rec": global_delta,
        "delta_out": delta_out,
        "w_in_int": w_in_int,
        "w_rec_int": w_rec_int,
        "w_out_int": w_out_int,
        "pos_masks_in": pos_masks_in,
        "neg_masks_in": neg_masks_in,
        "pos_masks_rec": pos_masks_rec,
        "neg_masks_rec": neg_masks_rec,
        "int_bits_hid": pareto_cfg["int_bits_hid"],
        "int_bits_out": pareto_cfg["int_bits_out"],
        "g_in": G_IN,
        "g_rec": G_REC
    }
    
    save_path = os.path.join(TARGET_FOLDER, "pure_integer_model.pt")
    torch.save(manifest, save_path)
    print(f"💾 Final Golden Blueprint saved to: {save_path}")

if __name__ == "__main__":
    main()