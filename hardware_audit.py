import os
import torch
import numpy as np
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier"
MODEL_NAME = "model_best.pth"

valid_betas = torch.tensor([
    0.0000, 0.0156, 0.0312, 0.0469, 0.0625, 0.0781, 0.0938, 0.1094, 
    0.1250, 0.1406, 0.1562, 0.1719, 0.1875, 0.2031, 0.2188, 0.2344, 
    0.2500, 0.2656, 0.2812, 0.2969, 0.3125, 0.3281, 0.3438, 0.3594, 
    0.3750, 0.3906, 0.4062, 0.4219, 0.4375, 0.4531, 0.4688, 0.4844, 
    0.5000, 0.5156, 0.5312, 0.5469, 0.5625, 0.5781, 0.5938, 0.6094, 
    0.6250, 0.6406, 0.6562, 0.6719, 0.6875, 0.7031, 0.7188, 0.7344, 
    0.7500, 0.7656, 0.7812, 0.7969, 0.8125, 0.8281, 0.8438, 0.8594, 
    0.8750, 0.8906, 0.9062, 0.9219, 0.9375, 0.9531, 0.9688, 0.9844, 1.0000
])

frac_bits = [
    0, 6, 5, 6, 4, 6, 5, 6, 3, 6, 5, 6, 4, 6, 5, 6, 
    2, 6, 5, 6, 4, 6, 5, 6, 3, 6, 5, 6, 4, 6, 5, 6, 
    1, 6, 5, 6, 4, 6, 5, 6, 3, 6, 5, 6, 4, 6, 5, 6, 
    2, 6, 5, 6, 4, 6, 5, 6, 3, 6, 5, 6, 4, 6, 5, 6, 0
]

def format_weights(weight_tensor):
    # Returns a string of non-zero connections like "[Src 2: +45] [Src 5: -12]"
    non_zeros = torch.nonzero(weight_tensor).view(-1)
    if len(non_zeros) == 0:
        return "None (Severed)"
    return " ".join([f"[Src {i.item():>2}: {weight_tensor[i].item():>4}]" for i in non_zeros])

def format_output_weights(weight_tensor, labels):
    non_zeros = torch.nonzero(weight_tensor).view(-1)
    if len(non_zeros) == 0:
        return "None (Dead Output)"
    return " ".join([f"[{labels[i.item()]}: {weight_tensor[i].item():>4}]" for i in non_zeros])

def main():
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    # Keyword labels based on typical Phase 2 output map
    labels_map = {0: 'eis', 1: 'zwoi', 2: 'drü', 3: 'plus', 4: 'minus', 5: 'noise', 6: 'silence'}
    
    model = FastSpikingNet(
        num_inputs=config["num_inputs"],
        num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"],
        beta=config["beta"]
    )
    
    checkpoint = torch.load(os.path.join(TARGET_FOLDER, MODEL_NAME), map_location="cpu")
    model.load_state_dict(checkpoint["model_state_dict"])
    model.eval()

    # 1. Extract Deltas (The physical scaling step)
    def get_delta(w):
        return (torch.quantile(w.abs().detach(), 0.985) + 1e-8) / 127.0

    delta_in = get_delta(model.fc_in.weight)
    delta_rec = get_delta(model.fc_rec.weight)
    delta_out = get_delta(model.fc_out.weight)

    # 2. Convert to Digital Hardware Integers
    w_in_q = torch.round(model.fc_in.weight / delta_in).int()
    w_rec_q = torch.round(model.fc_rec.weight / delta_rec).int()
    w_out_q = torch.round(model.fc_out.weight / delta_out).int()

    print("==================================================")
    print("           RAW SILICON PARAMETER DUMP             ")
    print("==================================================")
    print(f"Input Delta:     {delta_in.item():.6f}")
    print(f"Recurrent Delta: {delta_rec.item():.6f}")
    print(f"Output Delta:    {delta_out.item():.6f}")
    print("==================================================\n")

    print("--- HIDDEN LAYER NEURONS (80) ---")
    for i in range(config["num_hidden"]):
        # Calculate snapped beta
        raw_beta = model.lif_hidden.beta[i].item()
        nearest_idx = (valid_betas - raw_beta).abs().argmin().item()
        snap_beta = valid_betas[nearest_idx].item()
        shift = frac_bits[nearest_idx]
        
        in_str = format_weights(w_in_q[i])
        rec_str = format_weights(w_rec_q[i])
        out_str = format_output_weights(w_out_q[:, i], labels_map)
        
        is_dead = "DEAD NEURON" if ("None" in out_str) else "ACTIVE"
        
        print(f"Neuron {i:02d} | {is_dead}")
        print(f"  Beta      : {raw_beta:.4f} -> Snapped: {snap_beta:.4f} (Shift >> {shift})")
        print(f"  Inputs    : {in_str}")
        print(f"  Recurrent : {rec_str}")
        print(f"  Drives Out: {out_str}")
        print("-" * 50)

    print("\n--- OUTPUT LAYER NEURONS (7) ---")
    for i in range(config["num_outputs"]):
        raw_beta = model.lif_out.beta[i].item()
        nearest_idx = (valid_betas - raw_beta).abs().argmin().item()
        snap_beta = valid_betas[nearest_idx].item()
        shift = frac_bits[nearest_idx]
        
        print(f"Output Pin: {labels_map[i].upper()}")
        print(f"  Beta      : {raw_beta:.4f} -> Snapped: {snap_beta:.4f} (Shift >> {shift})")
        print("-" * 50)

if __name__ == "__main__":
    main()