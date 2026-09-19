import os
import torch
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier" 
SPARSE_CHECKPOINT = "sparsity_training/acc83.3_sparsity16.9.pth" # Update if exact name differs

def bit_count(n):
    return bin(n).count('1')

def assign_to_or_gates(weights_list, num_gates):
    if not weights_list:
        return [], []
        
    gates = [0] * num_gates
    assignments = [[] for _ in range(num_gates)]
    
    # Sort descending to place the largest, most bit-heavy weights first
    weights_list.sort(reverse=True)
    
    for w in weights_list:
        best_gate = -1
        min_overlap = float('inf')
        
        for i in range(num_gates):
            # Calculate how many 1s would collide if we put w in gate i
            overlap = bit_count(gates[i] & w)
            if overlap < min_overlap:
                min_overlap = overlap
                best_gate = i
                
        # Assign to the gate with the least collision
        gates[best_gate] |= w
        assignments[best_gate].append(w)
        
    return gates, assignments

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    print("\n=== Bit-Orthogonal OR-Gate Allocation ===")
    
    # 1. Load the pruned checkpoint
    ckpt_path = os.path.join(TARGET_FOLDER, SPARSE_CHECKPOINT)
    if not os.path.exists(ckpt_path):
        raise FileNotFoundError(f"Cannot find {ckpt_path}")
    
    ckpt = torch.load(ckpt_path, map_location=device)
    w_in = ckpt["model_state_dict"]["fc_in.weight"] * ckpt["mask_in"]
    w_rec = ckpt["model_state_dict"]["fc_rec.weight"] * ckpt["mask_rec"]
    w_out = ckpt["model_state_dict"]["fc_out.weight"] * ckpt["mask_out"]

    # 2. Extract Hardware Deltas
    with torch.no_grad():
        delta_in = (torch.quantile(torch.abs(ckpt["model_state_dict"]["fc_in.weight"]), 0.985) + 1e-8) / 127.0
        delta_rec = (torch.quantile(torch.abs(ckpt["model_state_dict"]["fc_rec.weight"]), 0.985) + 1e-8) / 127.0
        delta_out = (torch.quantile(torch.abs(ckpt["model_state_dict"]["fc_out.weight"]), 0.985) + 1e-8) / 127.0
        
    # Convert active floating weights directly to Verilog Integers
    w_in_int = torch.round(w_in / delta_in).int()
    w_rec_int = torch.round(w_rec / delta_rec).int()
    
    num_hidden = config["num_hidden"]
    
    # 3. Calculate 90th Percentile for Heterogeneous Gate Scaling
    active_counts = []
    for i in range(num_hidden):
        active_in = (w_in_int[i] != 0).sum().item()
        active_rec = (w_rec_int[i] != 0).sum().item()
        active_counts.append(active_in + active_rec)
        
    active_counts_tensor = torch.tensor(active_counts, dtype=torch.float32)
    p90_density = torch.quantile(active_counts_tensor, 0.90).item()
    p50_density = torch.quantile(active_counts_tensor, 0.50).item()
    
    print(f"Layer Active Synapse Density | 50th pctl: {p50_density:.0f} | 90th pctl: {p90_density:.0f}")
    
    total_collisions_avoided = 0
    total_theoretical_loss = 0
    
    # 4. Allocate Hidden Layer
    for i in range(num_hidden):
        weights_in = w_in_int[i].tolist()
        weights_rec = w_rec_int[i].tolist()
        all_weights = [w for w in weights_in + weights_rec if w != 0]
        
        if not all_weights:
            continue
            
        pos_weights = [w for w in all_weights if w > 0]
        neg_weights = [abs(w) for w in all_weights if w < 0] # Absolute value flip!
        
        # Heterogeneous scaling based on percentile
        def get_gate_count(weight_list):
            if len(weight_list) >= (p90_density / 2): return 3
            if len(weight_list) >= (p50_density / 2): return 2
            return 1

        num_pos_gates = get_gate_count(pos_weights)
        num_neg_gates = get_gate_count(neg_weights)
        
        pos_gates, pos_assignments = assign_to_or_gates(pos_weights, num_pos_gates)
        neg_gates, neg_assignments = assign_to_or_gates(neg_weights, num_neg_gates)
        
        # Calculate theoretical worst-case loss (if every synapse fired at once)
        true_pos_sum = sum(pos_weights)
        or_pos_sum = sum(pos_gates)
        true_neg_sum = sum(neg_weights)
        or_neg_sum = sum(neg_gates)
        
        total_theoretical_loss += (true_pos_sum - or_pos_sum) + (true_neg_sum - or_neg_sum)
        
        # Only print a few interesting neurons to avoid terminal spam
        if i in [0, 10, 40, 79]:
            print(f"\n--- Neuron {i} (Active Synapses: {len(all_weights)}) ---")
            print(f"  Excitatory (+) | Allocated {num_pos_gates} OR-Gates")
            for g_idx, gate_val in enumerate(pos_gates):
                print(f"    Gate {g_idx}: {bin(gate_val)[2:]:>8} | Contains: {pos_assignments[g_idx]}")
                
            print(f"  Inhibitory (-) | Allocated {num_neg_gates} OR-Gates (Absolute Values)")
            for g_idx, gate_val in enumerate(neg_gates):
                print(f"    Gate {g_idx}: {bin(gate_val)[2:]:>8} | Contains: {neg_assignments[g_idx]}")

    print(f"\n==========================================")
    print(f"Worst-Case Collision Loss (All Neurons Firing at Once): {total_theoretical_loss} integer units")
    print(f"Algorithm successfully isolated positive and absolute-negative integers.")

if __name__ == "__main__":
    main()