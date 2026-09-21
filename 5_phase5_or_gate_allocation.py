import os
import torch
from utils_ledger import load_ledger
from model import FastSpikingNet

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier" 
SPARSE_CHECKPOINT = "acc86.3_sparsity22.5.pth" 

# --- FINAL HARDWARE BUDGET ---
G_IN = 2   
G_REC = 1
G_OUT = 1

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
    0.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 3.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 
    2.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 3.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 
    1.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 3.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 
    2.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 3.0, 6.0, 5.0, 6.0, 4.0, 6.0, 5.0, 6.0, 0.0
])

def bit_count(n): return bin(n).count('1')

def get_snapped_hardware(beta_tensor, device):
    valid_betas = VALID_BETAS.to(device)
    frac_bits = FRAC_BITS.to(device)
    dists = (beta_tensor.unsqueeze(1) - valid_betas.unsqueeze(0)) ** 2
    best_indices = dists.argmin(dim=1)
    return valid_betas[best_indices], frac_bits[best_indices]

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
    
    print(f"\n=== FINAL EXPORT: Tapeout Model (G_IN={G_IN}, G_REC={G_REC}, G_OUT={G_OUT}) ===")
    
    ckpt = torch.load(os.path.join(TARGET_FOLDER, SPARSE_CHECKPOINT), map_location=device)
    pareto_cfg = torch.load(os.path.join(TARGET_FOLDER, "pareto_config_84.0.pt"), map_location=device)
    
    base_ckpt = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location=device)
    orig_model = FastSpikingNet(
        num_inputs=config["num_inputs"], num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"], beta=config["beta"]
    ).to(device)
    orig_model.load_state_dict(base_ckpt.get("model_state_dict", base_ckpt), strict=False)

    # Extract dynamic frac_bits directly from the model exactly as done in training
    beta_hid, frac_bits_hid = get_snapped_hardware(orig_model.lif_hidden.beta.data, device)
    beta_out, frac_bits_out = get_snapped_hardware(orig_model.lif_out.beta.data, device)

    with torch.no_grad():
        raw_delta_in = (torch.quantile(torch.abs(orig_model.fc_in.weight.data), 0.985) + 1e-8) / 127.0
        raw_delta_rec = (torch.quantile(torch.abs(orig_model.fc_rec.weight.data), 0.985) + 1e-8) / 127.0
        global_delta = max(raw_delta_in, raw_delta_rec)
        delta_out = (torch.quantile(torch.abs(orig_model.fc_out.weight.data), 0.985) + 1e-8) / 127.0

    w_in_float = ckpt["model_state_dict"]["w_in"].to(device) * ckpt["mask_in"].to(device)
    w_rec_float = ckpt["model_state_dict"]["w_rec"].to(device) * ckpt["mask_rec"].to(device)
    w_out_float = ckpt["model_state_dict"]["w_out"].to(device) * ckpt["mask_out"].to(device)

    w_in_int = torch.clamp(torch.round(w_in_float / global_delta).int(), -128, 127)
    w_rec_int = torch.clamp(torch.round(w_rec_float / global_delta).int(), -128, 127)
    w_out_int = torch.clamp(torch.round(w_out_float / delta_out).int(), -128, 127)

    num_hidden = config["num_hidden"]
    num_inputs = config["num_inputs"]
    num_outputs = config["num_outputs"]

    pos_masks_in = torch.zeros(G_IN, num_hidden, num_inputs, dtype=torch.int32)
    neg_masks_in = torch.zeros(G_IN, num_hidden, num_inputs, dtype=torch.int32)
    pos_masks_rec = torch.zeros(G_REC, num_hidden, num_hidden, dtype=torch.int32)
    neg_masks_rec = torch.zeros(G_REC, num_hidden, num_hidden, dtype=torch.int32)
    pos_masks_out = torch.zeros(G_OUT, num_outputs, num_hidden, dtype=torch.int32)
    neg_masks_out = torch.zeros(G_OUT, num_outputs, num_hidden, dtype=torch.int32)

    # 1. Hidden Layer Allocation
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

    # 2. Output Layer Allocation
    for i in range(num_outputs):
        out_p = [(w, 'out', idx) for idx, w in enumerate(w_out_int[i].tolist()) if w > 0]
        out_n = [(abs(w), 'out', idx) for idx, w in enumerate(w_out_int[i].tolist()) if w < 0]
        _, p_assign_out = assign_to_or_gates(out_p, min(G_OUT, len(out_p)))
        _, n_assign_out = assign_to_or_gates(out_n, min(G_OUT, len(out_n)))
        for g, g_list in enumerate(p_assign_out):
            for _, idx in g_list: pos_masks_out[g, i, idx] = 1
        for g, g_list in enumerate(n_assign_out):
            for _, idx in g_list: neg_masks_out[g, i, idx] = 1

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
        "pos_masks_out": pos_masks_out,
        "neg_masks_out": neg_masks_out,
        "int_bits_hid": pareto_cfg["int_bits_hid"],
        "int_bits_out": pareto_cfg["int_bits_out"],
        "frac_bits_hid": frac_bits_hid,
        "frac_bits_out": frac_bits_out,
        "beta_hid": beta_hid,
        "beta_out": beta_out,
        "g_in": G_IN,
        "g_rec": G_REC,
        "g_out": G_OUT
    }
    
    save_path = os.path.join(TARGET_FOLDER, "pure_integer_model.pt")
    torch.save(manifest, save_path)
    print(f"💾 Compressed OR-Gate Blueprint saved to: {save_path}")

if __name__ == "__main__":
    main()