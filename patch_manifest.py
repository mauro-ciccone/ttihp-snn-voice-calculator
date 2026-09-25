import os
import torch
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0924_1200_64_neuron_model" 

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

def get_snapped_hardware(beta_tensor):
    dists = (beta_tensor.unsqueeze(1) - VALID_BETAS.unsqueeze(0)) ** 2
    best_indices = dists.argmin(dim=1)
    return VALID_BETAS[best_indices], FRAC_BITS[best_indices]

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    orig_model = FastSpikingNet(
        num_inputs=config["num_inputs"], num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"], beta=config["beta"]
    ).to(device)
    base_ckpt = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location=device)
    orig_model.load_state_dict(base_ckpt.get("model_state_dict", base_ckpt), strict=False)

    beta_hid, frac_bits_hid = get_snapped_hardware(orig_model.lif_hidden.beta.data)
    beta_out, frac_bits_out = get_snapped_hardware(orig_model.lif_out.beta.data)

    manifest_path = os.path.join(TARGET_FOLDER, "pure_integer_model.pt")
    manifest = torch.load(manifest_path, map_location=device)
    
    manifest["beta_hid"] = beta_hid
    manifest["frac_bits_hid"] = frac_bits_hid
    manifest["beta_out"] = beta_out
    manifest["frac_bits_out"] = frac_bits_out
    
    torch.save(manifest, manifest_path)
    print("✅ Hardware Betas successfully injected into pure_integer_model.pt")

if __name__ == "__main__":
    main()