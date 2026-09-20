import os
import torch
from tqdm import tqdm
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger

import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="torchaudio._backend.utils")

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier" 
BASE_MODEL_NAME = "phase3_model_best.pth" 

# GA Hyperparameters
POP_SIZE = 2000
GENERATIONS = 100
MUTATION_RATE = 0.15
ELITE_FRAC = 0.05
NUM_KEYWORDS = 5
NUM_INPUTS = 6 # 5 base keywords + 1 noise
THRESH = 32.0  # Hardware integer threshold

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

def cache_base_spikes(base_model, loader, device, target_folder):
    """Loads base spikes from disk if available, otherwise generates and saves them."""
    cache_path = os.path.join(target_folder, "base_spikes_cache.pt")
    
    if os.path.exists(cache_path):
        print(f">>> Found cached spikes on disk! Loading from {cache_path}...")
        data = torch.load(cache_path, map_location=device)
        return data["spikes"], data["targets"]
        
    print(">>> No disk cache found. Running dataset through base model...")
    all_spikes, all_targets = [], []
    with torch.no_grad():
        for x, y in tqdm(loader, desc="Caching Base Spikes"):
            x = x.to(device)
            spk_out_base, _ = base_model(x)
            all_spikes.append(spk_out_base.cpu())
            all_targets.append(y.cpu())
            
    spikes_tensor = torch.cat(all_spikes, dim=0)
    targets_tensor = torch.cat(all_targets, dim=0)
    
    print(f">>> Saving {spikes_tensor.size(0)} samples to disk cache...")
    torch.save({"spikes": spikes_tensor, "targets": targets_tensor}, cache_path)
    
    return spikes_tensor, targets_tensor

def main():
    device = torch.device("cpu") # CPU is often faster for discrete tensor logic if GPU overhead is high
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    print(f"\n=== Massively Parallel Tensor GA (Hierarchical WTA Logic) ===")
    
    train_loader, _, _ = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    
    base_model = FastSpikingNet(
        num_inputs=config["num_inputs"], num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"], beta=config["beta"]
    ).to(device)
    base_model.load_state_dict(torch.load(os.path.join(TARGET_FOLDER, BASE_MODEL_NAME), map_location=device)["model_state_dict"], strict=False)
    base_model.eval()
    
    # 1. Generate RAM Cache
    spikes_tensor, targets_tensor = cache_base_spikes(base_model, train_loader, device, TARGET_FOLDER)
    num_samples = spikes_tensor.size(0)
    time_steps = spikes_tensor.size(1)
    print(f">>> Cached {num_samples} samples. Freeing Base Model from memory.")
    del base_model 
    
    # Pre-calculate exact digital logic targets: Shape (Batch, 5)
    # Target is exactly 1 on the keyword, 0 everywhere else. For noise, entirely 0.
    perfect_targets = torch.zeros((num_samples, NUM_KEYWORDS), device=device)
    is_keyword = targets_tensor < NUM_KEYWORDS
    perfect_targets[torch.arange(num_samples)[is_keyword], targets_tensor[is_keyword]] = 1.0

    # 2. Initialize Population Tensors (Directly as Integers/Indices)
    # w_in: Excitatory [0, 63] for inputs 0-4, Inhibitory [-64, 0] for input 5
    pop_w_in = torch.zeros(POP_SIZE, NUM_KEYWORDS, NUM_INPUTS, device=device)
    pop_w_in[:, :, :NUM_KEYWORDS] = torch.randint(0, 64, (POP_SIZE, NUM_KEYWORDS, NUM_KEYWORDS))
    pop_w_in[:, :, NUM_KEYWORDS:] = torch.randint(-64, 1, (POP_SIZE, NUM_KEYWORDS, 1))
    
    # w_lat: Inhibitory [-64, 0]
    pop_w_lat = torch.randint(-64, 1, (POP_SIZE, NUM_KEYWORDS, NUM_KEYWORDS), device=device)
    # Mask diagonal to 0
    diag_mask = ~torch.eye(NUM_KEYWORDS, device=device).bool()
    pop_w_lat = pop_w_lat * diag_mask
    
    # Beta: Integer indices [0, 63] pointing to VALID_BETAS
    pop_beta_idx = torch.randint(32, 64, (POP_SIZE, NUM_KEYWORDS), device=device) # Start with slower leaks
    
    elite_count = int(POP_SIZE * ELITE_FRAC)
    best_fitness_overall = 0
    
    # 3. Evolution Loop
    for gen in range(GENERATIONS):
        # --- PARALLEL EVALUATION ---
        mem = torch.zeros(POP_SIZE, num_samples, NUM_KEYWORDS, device=device)
        total_spikes = torch.zeros(POP_SIZE, num_samples, NUM_KEYWORDS, device=device)
        
        betas = VALID_BETAS[pop_beta_idx].unsqueeze(1) # Shape: (Pop, 1, 5)
        
        for t in range(time_steps):
            # spikes_tensor[:, t, :] is (Batch, 6)
            # pop_w_in is (Pop, 5, 6)
            # Einsum beautifully multiplies the batch against every network in the population simultaneously
            cur_in = torch.einsum('bi, pji -> pbj', spikes_tensor[:, t, :], pop_w_in)
            
            cur_lat = torch.einsum('pbj, pkj -> pbk', total_spikes, pop_w_lat)
            
            mem = (mem * betas) + cur_in + cur_lat
            
            spk = (mem >= THRESH).float()
            mem = mem * (1.0 - spk)
            total_spikes += spk

        # --- FITNESS CALCULATION ---
        # Did the output perfectly match the strict digital logic requirements?
        is_perfect_neuron = (total_spikes == perfect_targets).float()
        is_perfect_sample = (is_perfect_neuron.sum(dim=-1) == NUM_KEYWORDS).float()
        
        # Fitness is total number of perfectly solved audio samples
        fitness = is_perfect_sample.sum(dim=-1)
        
        sorted_fitness, sorted_idx = torch.sort(fitness, descending=True)
        current_best = sorted_fitness[0].item()
        
        if current_best > best_fitness_overall:
            best_fitness_overall = current_best
            torch.save({
                "w_in": pop_w_in[sorted_idx[0]],
                "w_lat": pop_w_lat[sorted_idx[0]],
                "beta_idx": pop_beta_idx[sorted_idx[0]],
                "fitness": current_best
            }, os.path.join(TARGET_FOLDER, "wta_ga_best.pt"))
            
        print(f"Gen {gen+1:03d} | Best Strict Acc: {(current_best/num_samples)*100:.1f}% | Worst: {(sorted_fitness[-1].item()/num_samples)*100:.1f}%")
        
        # --- BREEDING & MUTATION ---
        # Keep Elites
        elite_w_in = pop_w_in[sorted_idx[:elite_count]]
        elite_w_lat = pop_w_lat[sorted_idx[:elite_count]]
        elite_beta = pop_beta_idx[sorted_idx[:elite_count]]
        
        # Create Offspring via Random Elite Selection
        parent_idx = torch.randint(0, elite_count, (POP_SIZE - elite_count,), device=device)
        offspring_w_in = elite_w_in[parent_idx].clone()
        offspring_w_lat = elite_w_lat[parent_idx].clone()
        offspring_beta = elite_beta[parent_idx].clone()
        
        # Mutate W_IN (+/- 1 to 3)
        mut_mask_in = (torch.rand_like(offspring_w_in, dtype=torch.float) < MUTATION_RATE).float()
        offspring_w_in += torch.randint(-3, 4, offspring_w_in.shape, device=device).float() * mut_mask_in
        offspring_w_in[:, :, :NUM_KEYWORDS] = torch.clamp(offspring_w_in[:, :, :NUM_KEYWORDS], 0, 63)
        offspring_w_in[:, :, NUM_KEYWORDS:] = torch.clamp(offspring_w_in[:, :, NUM_KEYWORDS:], -64, 0)
        
        # Mutate W_LAT (+/- 1 to 3)
        mut_mask_lat = (torch.rand_like(offspring_w_lat, dtype=torch.float) < MUTATION_RATE).float()
        offspring_w_lat += torch.randint(-3, 4, offspring_w_lat.shape, device=device).float() * mut_mask_lat
        offspring_w_lat = torch.clamp(offspring_w_lat, -64, 0)
        offspring_w_lat = offspring_w_lat * diag_mask # Keep diagonal 0
        
        # Mutate Betas (+/- 1 shift)
        mut_mask_beta = (torch.rand(offspring_beta.shape, device=device) < MUTATION_RATE).int()
        offspring_beta += torch.randint(-1, 2, offspring_beta.shape, device=device) * mut_mask_beta
        offspring_beta = torch.clamp(offspring_beta, 0, 63)
        
        # Reassemble Population
        pop_w_in = torch.cat([elite_w_in, offspring_w_in], dim=0)
        pop_w_lat = torch.cat([elite_w_lat, offspring_w_lat], dim=0)
        pop_beta_idx = torch.cat([elite_beta, offspring_beta], dim=0)

if __name__ == "__main__":
    main()