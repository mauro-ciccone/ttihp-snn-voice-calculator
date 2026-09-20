import os
import torch
from dataset_cached import get_cached_dataloaders
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier" 
SPARSE_CHECKPOINT = "acc86.3_sparsity22.5.pth" # Update this to your exact file name

def bit_count(n):
    return bin(n).count('1')

def assign_to_or_gates(weights_with_indices, num_gates):
    if not weights_with_indices:
        return [], []
        
    gates = [0] * num_gates
    assignments = [[] for _ in range(num_gates)]
    
    # Sort descending by absolute integer value
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
        assignments[best_gate].append((src_type, src_idx)) # Store where it came from
        
    return gates, assignments

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    print("\n=== Compiling Hardware Wiring Manifest ===")
    
    # Updated path to point inside the sparsity_training folder
    ckpt_path = os.path.join(TARGET_FOLDER, SPARSE_CHECKPOINT)
    ckpt = torch.load(ckpt_path, map_location=device)
    
    # Updated keys to match Phase4QATSparseNet state_dict
    w_in = ckpt["model_state_dict"]["w_in"] * ckpt["mask_in"]
    w_rec = ckpt["model_state_dict"]["w_rec"] * ckpt["mask_rec"]

    with torch.no_grad():
        delta_in = (torch.quantile(torch.abs(ckpt["model_state_dict"]["w_in"]), 0.985) + 1e-8) / 127.0
        delta_rec = (torch.quantile(torch.abs(ckpt["model_state_dict"]["w_rec"]), 0.985) + 1e-8) / 127.0
        
    w_in_int = torch.round(w_in / delta_in).int()
    w_rec_int = torch.round(w_rec / delta_rec).int()
    
    num_hidden = config["num_hidden"]
    
    active_counts = []
    for i in range(num_hidden):
        active_counts.append((w_in_int[i] != 0).sum().item() + (w_rec_int[i] != 0).sum().item())
        
    p90_density = torch.quantile(torch.tensor(active_counts, dtype=torch.float32), 0.90).item()
    p50_density = torch.quantile(torch.tensor(active_counts, dtype=torch.float32), 0.50).item()
    
    wiring_manifest = {
        "delta_in": delta_in,
        "delta_rec": delta_rec,
        "hidden_neurons": {}
    }
    
    total_theoretical_loss = 0
    
    for i in range(num_hidden):
        # Pack weights with their source identifiers
        all_weights = []
        for src_idx, w in enumerate(w_in_int[i].tolist()):
            if w != 0: all_weights.append((w, 'in', src_idx))
        for src_idx, w in enumerate(w_rec_int[i].tolist()):
            if w != 0: all_weights.append((w, 'rec', src_idx))
            
        pos_weights = [(w, t, idx) for w, t, idx in all_weights if w > 0]
        neg_weights = [(abs(w), t, idx) for w, t, idx in all_weights if w < 0]
        
        def get_gate_count(weight_list):
            if len(weight_list) >= (p90_density / 2): return 3
            if len(weight_list) >= (p50_density / 2): return 2
            return 1 if len(weight_list) > 0 else 0

        num_pos_gates = get_gate_count(pos_weights)
        num_neg_gates = get_gate_count(neg_weights)
        
        pos_gates, pos_assign = assign_to_or_gates(pos_weights, num_pos_gates)
        neg_gates, neg_assign = assign_to_or_gates(neg_weights, num_neg_gates)
        
        true_pos = sum([w for w, _, _ in pos_weights])
        true_neg = sum([w for w, _, _ in neg_weights])
        total_theoretical_loss += (true_pos - sum(pos_gates)) + (true_neg - sum(neg_gates))
        
        # Save to the manifest dictionary
        wiring_manifest["hidden_neurons"][i] = {
            "pos_gates": pos_assign, # List of gates, each containing lists of (src_type, src_idx)
            "neg_gates": neg_assign
        }

    save_path = os.path.join(TARGET_FOLDER, "hardware_wiring.pt")
    torch.save(wiring_manifest, save_path)
    
    print(f"Worst-Case Collision Loss (If every synapse fired at once): {total_theoretical_loss} integer units")
    print(f"💾 Hardware Wiring Manifest saved to: {save_path}")

if __name__ == "__main__":
    main()