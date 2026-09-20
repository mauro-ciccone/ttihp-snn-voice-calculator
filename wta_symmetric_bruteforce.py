import os
import torch
from tqdm import tqdm
from utils_ledger import load_ledger

import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="torchaudio._backend.utils")

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier" 

NUM_KEYWORDS = 5
NUM_INPUTS = 6 
THRESH = 100.0  

VALID_BETAS = torch.tensor([
    0.0000, 0.0156, 0.0312, 0.0469, 0.0625, 0.0781, 0.0938, 0.1094, 
    0.1250, 0.1406, 0.1562, 0.1719, 0.1875, 0.2031, 0.2188, 0.2344, 
    0.2500, 0.2656, 0.2812, 0.2969, 0.3125, 0.3281, 0.3438, 0.3594, 
    0.3750, 0.3906, 0.4062, 0.4219, 0.4375, 0.4531, 0.4688, 0.4844, 
    0.5000, 0.5156, 0.5312, 0.5469, 0.5625, 0.5781, 0.5938, 0.6094, 
    0.6250, 0.6406, 0.6562, 0.6719, 0.6875, 0.7031, 0.7188, 0.7344, 
    0.7500, 0.7656, 0.7812, 0.7969, 0.8125, 0.8281, 0.8438, 0.8594, 
    0.8750, 0.8906, 0.9062, 0.9219, 0.9375, 0.9531, 0.9688, 1.0000
])

def main():
    device = torch.device("cpu") 
    
    print(f"\n=== Phase 7a: STRICT 1-SPIKE WTA SOLVER ===")
    
    cache_path = os.path.join(TARGET_FOLDER, "base_spikes_cache.pt")
    if not os.path.exists(cache_path):
        raise FileNotFoundError("Cache missing. Run the previous GA script once to generate it.")
        
    data = torch.load(cache_path, map_location=device)
    spikes_tensor = data["spikes"]
    targets_tensor = data["targets"]
    
    num_samples = spikes_tensor.size(0)
    time_steps = spikes_tensor.size(1)
    
    ARENA_SIZE = min(1500, num_samples) 
    arena_spikes = spikes_tensor[:ARENA_SIZE].to(device)
    arena_targets = targets_tensor[:ARENA_SIZE].to(device)
    
    perfect_targets = torch.zeros((ARENA_SIZE, NUM_KEYWORDS), device=device)
    is_keyword = arena_targets < NUM_KEYWORDS
    perfect_targets[torch.arange(ARENA_SIZE)[is_keyword], arena_targets[is_keyword]] = 1.0

    # 1. Define the Collapsed Search Space
    # To get exactly 1 spike with a threshold of 100 and ~45 inputs, W_exc MUST be between 3 and 5.
    w_exc_vals = torch.arange(0, 20, 1, device=device)         
    w_inh_vals = torch.arange(-20, 0, 1, device=device)        
    w_lat_vals = torch.tensor([-128, -64, -32, 0], device=device) # Hardware signed 8-bit limits
    beta_idx_vals = torch.arange(54, 64, 1, device=device)    # Very slow leaks to perfect integration
    
    # 2. Build the Combinatorial Grid
    grid = torch.cartesian_prod(w_exc_vals, w_inh_vals, w_lat_vals, beta_idx_vals)
    POP_SIZE = grid.size(0)
    print(f">>> Brute-forcing {POP_SIZE} symmetric universes simultaneously...")
    
    # 3. Inflate grid into full population tensors
    pop_w_in = torch.full((POP_SIZE, NUM_KEYWORDS, NUM_INPUTS), 0.0, device=device)
    pop_w_lat = torch.full((POP_SIZE, NUM_KEYWORDS, NUM_KEYWORDS), 0.0, device=device)
    pop_beta_idx = grid[:, 3].long()
    
    diag_mask = torch.eye(NUM_KEYWORDS, device=device).bool()
    off_diag_mask = ~diag_mask
    
    for i in range(POP_SIZE):
        exc, inh, lat, _ = grid[i]
        pop_w_in[i, :NUM_KEYWORDS, :NUM_KEYWORDS][diag_mask] = exc
        pop_w_in[i, :NUM_KEYWORDS, :NUM_KEYWORDS][off_diag_mask] = inh
        pop_w_in[i, :, 5] = inh * 2.0 
        pop_w_lat[i][off_diag_mask] = lat

    # 4. Single Massive Forward Pass Evaluation
    mem = torch.zeros(POP_SIZE, ARENA_SIZE, NUM_KEYWORDS, device=device)
    total_spikes = torch.zeros(POP_SIZE, ARENA_SIZE, NUM_KEYWORDS, device=device)
    
    # Hardware Recurrent specific: instantaneous spike from the previous tick
    spk = torch.zeros(POP_SIZE, ARENA_SIZE, NUM_KEYWORDS, device=device) 
    
    betas = VALID_BETAS[pop_beta_idx].view(-1, 1, 1)
    
    for t in tqdm(range(time_steps), desc="Simulating Universes"):
        spikes_t = arena_spikes[:, t, :]
        cur_in = torch.matmul(pop_w_in, spikes_t.T).transpose(1, 2)
        
        # Hardware uses the 1-tick delayed spike for recurrence, NOT the cumulative total
        cur_lat = torch.matmul(spk, pop_w_lat)
        
        mem = (mem * betas) + cur_in + cur_lat
        spk = (mem >= THRESH).float()
        mem = mem * (1.0 - spk)
        total_spikes += spk

    # 5. STRICT 1-SPIKE SCORING
    is_perfect_neuron = (total_spikes == perfect_targets).float()
    is_perfect_sample = (is_perfect_neuron.sum(dim=-1) == NUM_KEYWORDS).float()
    strict_fitness = is_perfect_sample.sum(dim=-1)
    
    sorted_fitness, sorted_idx = torch.sort(strict_fitness, descending=True)
    best_idx = sorted_idx[0]
    best_acc = (sorted_fitness[0].item() / ARENA_SIZE) * 100
    
    best_exc, best_inh, best_lat, best_beta = grid[best_idx]
    
    print("\n==================================================")
    print("🏆 OPTIMAL STRICT-1-SPIKE ARCHITECTURE FOUND")
    print("==================================================")
    print(f"FSM Compatibility : Exactly 1 spike per keyword")
    print(f"Strict Accuracy   : {best_acc:.2f}%")
    print(f"Excitatory W_IN   : +{int(best_exc.item())}")
    print(f"Inhibitory W_IN   : {int(best_inh.item())}")
    print(f"Noise W_IN        : {int(best_inh.item() * 2)}")
    print(f"Lateral W_REC     : {int(best_lat.item())}")
    print(f"Beta Leak Index   : {int(best_beta.item())} (Value: {VALID_BETAS[int(best_beta.item())]:.4f})")
    print("==================================================")
    
    torch.save({
        "w_in": pop_w_in[best_idx],
        "w_lat": pop_w_lat[best_idx],
        "beta_idx": pop_beta_idx[best_idx].unsqueeze(0).repeat(NUM_KEYWORDS),
        "fitness": sorted_fitness[0].item()
    }, os.path.join(TARGET_FOLDER, "wta_symmetric_best.pt"))
    print("💾 Saved to wta_symmetric_best.pt")

if __name__ == "__main__":
    main()