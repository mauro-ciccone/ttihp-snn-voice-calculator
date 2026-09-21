import os
import torch
from tqdm import tqdm
from utils_ledger import load_ledger
from dataset_cached import get_cached_dataloaders # Required for building the cache

import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="torchaudio._backend.utils")

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier" 

# GA Hyperparameters
POP_SIZE = 2000
GENERATIONS = 100
MUTATION_RATE = 0.15
ELITE_FRAC = 0.05
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

def generate_cache(device, target_folder, cache_path):
    print("\n>>> Cache missing. Generating Base Spikes Cache with full OR-Gate Physics...")
    train_loader, _, _ = get_cached_dataloaders("data_cache", batch_size=128)
    
    manifest = torch.load(os.path.join(target_folder, "pure_integer_model.pt"), map_location=device)
    
    g_in = manifest.get("g_in", 2)
    g_rec = manifest.get("g_rec", 1)
    g_out = manifest.get("g_out", 4) # Dynamic fetch for new output layer setup
    
    w_in = manifest["w_in_int"].abs().to(device)
    w_rec = manifest["w_rec_int"].abs().to(device)
    w_out = manifest["w_out_int"].abs().to(device)
    
    def build_mats(masks, w_abs, g):
        mats = []
        for i in range(g):
            w_gate = w_abs * masks[i].to(device)
            bits = []
            for b in range(8):
                has_bit = ((w_gate.int() & (1 << b)) != 0).float()
                bits.append(has_bit.t())
            mats.append(torch.stack(bits, dim=0))
        return torch.cat(mats, dim=0)

    p_mats_in = build_mats(manifest["pos_masks_in"], w_in, g_in)
    n_mats_in = build_mats(manifest["neg_masks_in"], w_in, g_in)
    p_mats_rec = build_mats(manifest["pos_masks_rec"], w_rec, g_rec)
    n_mats_rec = build_mats(manifest["neg_masks_rec"], w_rec, g_rec)
    p_mats_out = build_mats(manifest["pos_masks_out"], w_out, g_out)
    n_mats_out = build_mats(manifest["neg_masks_out"], w_out, g_out)
    
    fb_hid_t = manifest["frac_bits_hid"].to(device)
    if fb_hid_t.numel() == 1: fb_hid_t = fb_hid_t.repeat(w_in.size(0))
    fb_hid_t = fb_hid_t.view(1, -1).int()
    
    fb_out_t = manifest["frac_bits_out"].to(device)
    if fb_out_t.numel() == 1: fb_out_t = fb_out_t.repeat(w_out.size(0))
    fb_out_t = fb_out_t.view(1, -1).int()
    
    thresh_hid = int(round(1.0 / manifest["delta_in"].item()))
    thresh_out = int(round(1.0 / manifest["delta_out"].item()))
    
    shifts = torch.tensor([1<<b for b in range(8)], device=device).view(1, 8, 1, 1).float()
    
    all_spikes = []
    all_targets = []
    samples_processed = 0
    
    with torch.no_grad():
        for x, y in tqdm(train_loader, desc="Simulating Hardware OR-Gates"):
            x = x.to(device)
            y = y.to(device)
            batch = x.size(0)
            time_steps = x.size(1)
            
            mem_hid = torch.zeros(batch, w_in.size(0), device=device)
            mem_base = torch.zeros(batch, w_out.size(0), device=device)
            spk_hid = torch.zeros(batch, w_in.size(0), device=device)
            
            batch_base_spikes = []
            
            for t in range(time_steps):
                xt = x[:, t, :].unsqueeze(0) 
                st = spk_hid.unsqueeze(0)    
                
                # Hidden Layer Math (OR-Gate Simulation)
                p_in_cnt = torch.matmul(xt, p_mats_in)
                n_in_cnt = torch.matmul(xt, n_mats_in)
                p_rec_cnt = torch.matmul(st, p_mats_rec)
                n_rec_cnt = torch.matmul(st, n_mats_rec)
                
                pos_in = ((p_in_cnt > 0).float().view(g_in, 8, batch, -1) * shifts).sum(dim=(0,1))
                neg_in = ((n_in_cnt > 0).float().view(g_in, 8, batch, -1) * shifts).sum(dim=(0,1))
                pos_rec = ((p_rec_cnt > 0).float().view(g_rec, 8, batch, -1) * shifts).sum(dim=(0,1))
                neg_rec = ((n_rec_cnt > 0).float().view(g_rec, 8, batch, -1) * shifts).sum(dim=(0,1))
                
                sum_hid = (pos_in - neg_in) + (pos_rec - neg_rec)
                
                mem_hid_leak = torch.bitwise_right_shift(mem_hid.int(), fb_hid_t).float()
                mem_hid = mem_hid - mem_hid_leak + sum_hid
                spk_hid = (mem_hid >= thresh_hid).float()
                mem_hid = mem_hid * (1.0 - spk_hid)
                
                # Base Output Layer Math (OR-Gate Simulation)
                st_base = spk_hid.unsqueeze(0)
                p_out_cnt = torch.matmul(st_base, p_mats_out)
                n_out_cnt = torch.matmul(st_base, n_mats_out)
                
                pos_out = ((p_out_cnt > 0).float().view(g_out, 8, batch, -1) * shifts).sum(dim=(0,1))
                neg_out = ((n_out_cnt > 0).float().view(g_out, 8, batch, -1) * shifts).sum(dim=(0,1))
                
                sum_base = pos_out - neg_out
                
                mem_base_leak = torch.bitwise_right_shift(mem_base.int(), fb_out_t).float()
                mem_base = mem_base - mem_base_leak + sum_base
                spk_base = (mem_base >= thresh_out).float()
                mem_base = mem_base * (1.0 - spk_base)
                
                batch_base_spikes.append(spk_base)
                
            all_spikes.append(torch.stack(batch_base_spikes, dim=1))
            all_targets.append(y)
            
            samples_processed += batch
            if samples_processed >= 1500:
                break
                
    spikes_tensor = torch.cat(all_spikes, dim=0)[:1500]
    targets_tensor = torch.cat(all_targets, dim=0)[:1500]
    
    torch.save({"spikes": spikes_tensor, "targets": targets_tensor}, cache_path)
    print(f"✅ Cache generated and saved to {cache_path}")


def main():
    device = torch.device("cpu") 
    
    print(f"\n=== Phase 7b: ASYMMETRIC WTA GA (Strict 1-Spike) ===")
    
    cache_path = os.path.join(TARGET_FOLDER, "base_spikes_cache.pt")
    if not os.path.exists(cache_path):
        generate_cache(device, TARGET_FOLDER, cache_path)
        
    data = torch.load(cache_path, map_location=device)
    spikes_tensor = data["spikes"]
    targets_tensor = data["targets"]
    
    num_samples = spikes_tensor.size(0)
    time_steps = spikes_tensor.size(1)
    
    # We use a massive arena for ultimate accuracy mapping
    ARENA_SIZE = min(800, num_samples)
    arena_spikes = spikes_tensor[:ARENA_SIZE].to(device)
    arena_targets = targets_tensor[:ARENA_SIZE].to(device)
    print(f">>> Fine-tuning asymmetric weights on {ARENA_SIZE} samples.")
    
    perfect_targets = torch.zeros((ARENA_SIZE, NUM_KEYWORDS), device=device)
    is_keyword = arena_targets < NUM_KEYWORDS
    perfect_targets[torch.arange(ARENA_SIZE)[is_keyword], arena_targets[is_keyword]] = 1.0

    # 1. Initialize Population Tensors (Random limits aligned with discovery)
    pop_w_in = torch.zeros(POP_SIZE, NUM_KEYWORDS, NUM_INPUTS, device=device)
    pop_w_in[:, :, :NUM_KEYWORDS] = torch.randint(0, 12, (POP_SIZE, NUM_KEYWORDS, NUM_KEYWORDS))
    pop_w_in[:, :, NUM_KEYWORDS:] = torch.randint(-8, 1, (POP_SIZE, NUM_KEYWORDS, 1))
    
    pop_w_lat = torch.randint(-128, -64, (POP_SIZE, NUM_KEYWORDS, NUM_KEYWORDS), device=device).float()
    diag_mask = ~torch.eye(NUM_KEYWORDS, device=device).bool()
    pop_w_lat = pop_w_lat * diag_mask
    
    pop_beta_idx = torch.randint(60, 64, (POP_SIZE, NUM_KEYWORDS), device=device)
    
    # --- 2. INJECT GOLDEN SYMMETRIC SEED (Top 50% of population) ---
    seed_count = int(POP_SIZE * 0.80)
    
    # W_exc = +6, W_inh = -1
    ideal_w_in = torch.full((NUM_KEYWORDS, NUM_KEYWORDS), -1.0, device=device)
    ideal_w_in.fill_diagonal_(18.0) 
    
    # Noise = -2
    ideal_w_in = torch.cat([ideal_w_in, torch.full((NUM_KEYWORDS, 1), -2.0, device=device)], dim=-1)
    
    # Lateral WTA = -128
    ideal_w_lat = torch.full((NUM_KEYWORDS, NUM_KEYWORDS), -128.0, device=device) * diag_mask
    
    pop_w_in[:seed_count] = ideal_w_in.unsqueeze(0).repeat(seed_count, 1, 1)
    pop_w_lat[:seed_count] = ideal_w_lat.unsqueeze(0).repeat(seed_count, 1, 1)
    pop_beta_idx[:seed_count] = 62 # 1.000 (No leak)
    
    # Add slight random asymmetric noise to the seeds (+/- 1) to break the symmetry
    if seed_count > 1:
        pop_w_in[1:seed_count] += torch.randint(-1, 2, pop_w_in[1:seed_count].shape, device=device).float()
        pop_w_lat[1:seed_count] += torch.randint(-16, 17, pop_w_lat[1:seed_count].shape, device=device).float() * diag_mask
    
    pop_w_in[:, :, :NUM_KEYWORDS] = torch.clamp(pop_w_in[:, :, :NUM_KEYWORDS], 0, 127)
    pop_w_in[:, :, NUM_KEYWORDS:] = torch.clamp(pop_w_in[:, :, NUM_KEYWORDS:], -128, 0)
    pop_w_lat = torch.clamp(pop_w_lat, -128, 0) * diag_mask
    pop_beta_idx = torch.clamp(pop_beta_idx, 0, 63)

    elite_count = int(POP_SIZE * ELITE_FRAC)
    best_fitness_overall = 0
    
    # 3. Evolution Loop
    pbar = tqdm(range(GENERATIONS), desc="Evolving Asymmetric Logic")
    for gen in pbar:
        mem = torch.zeros(POP_SIZE, ARENA_SIZE, NUM_KEYWORDS, device=device)
        total_spikes = torch.zeros(POP_SIZE, ARENA_SIZE, NUM_KEYWORDS, device=device)
        spk = torch.zeros(POP_SIZE, ARENA_SIZE, NUM_KEYWORDS, device=device) 
        
        betas = VALID_BETAS[pop_beta_idx].unsqueeze(1)
        
        for t in range(time_steps):
            spikes_t = arena_spikes[:, t, :]
            cur_in = torch.matmul(pop_w_in, spikes_t.T).transpose(1, 2)
            
            # TRUE HARDWARE RECURRENCE: Matrix mul against 1-tick delayed spk
            cur_lat = torch.matmul(spk, pop_w_lat)
            
            mem = (mem * betas) + cur_in + cur_lat
            spk = (mem >= THRESH).float()
            mem = mem * (1.0 - spk)
            total_spikes += spk

        # STRICT 1-SPIKE FITNESS
        is_perfect_neuron = (total_spikes == perfect_targets).float()
        is_perfect_sample = (is_perfect_neuron.sum(dim=-1) == NUM_KEYWORDS).float()
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
            
        pbar.set_postfix({
            "Best Acc": f"{(current_best/ARENA_SIZE)*100:.1f}%", 
            "Worst": f"{(sorted_fitness[-1].item()/ARENA_SIZE)*100:.1f}%"
        })
        
        # Breed and Mutate
        elite_w_in = pop_w_in[sorted_idx[:elite_count]]
        elite_w_lat = pop_w_lat[sorted_idx[:elite_count]]
        elite_beta = pop_beta_idx[sorted_idx[:elite_count]]
        
        parent_idx = torch.randint(0, elite_count, (POP_SIZE - elite_count,), device=device)
        offspring_w_in = elite_w_in[parent_idx].clone()
        offspring_w_lat = elite_w_lat[parent_idx].clone()
        offspring_beta = elite_beta[parent_idx].clone()
        
        mut_mask_in = (torch.rand_like(offspring_w_in, dtype=torch.float) < MUTATION_RATE).float()
        offspring_w_in += torch.randint(-2, 3, offspring_w_in.shape, device=device).float() * mut_mask_in
        offspring_w_in[:, :, :NUM_KEYWORDS] = torch.clamp(offspring_w_in[:, :, :NUM_KEYWORDS], 0, 127)
        offspring_w_in[:, :, NUM_KEYWORDS:] = torch.clamp(offspring_w_in[:, :, NUM_KEYWORDS:], -128, 0)
        
        mut_mask_lat = (torch.rand_like(offspring_w_lat, dtype=torch.float) < MUTATION_RATE).float()
        offspring_w_lat += torch.randint(-16, 17, offspring_w_lat.shape, device=device).float() * mut_mask_lat
        offspring_w_lat = torch.clamp(offspring_w_lat, -128, 0)
        offspring_w_lat = offspring_w_lat * diag_mask 
        
        mut_mask_beta = (torch.rand(offspring_beta.shape, device=device) < MUTATION_RATE).int()
        offspring_beta += torch.randint(-1, 2, offspring_beta.shape, device=device) * mut_mask_beta
        offspring_beta = torch.clamp(offspring_beta, 0, 63)
        
        pop_w_in = torch.cat([elite_w_in, offspring_w_in], dim=0)
        pop_w_lat = torch.cat([elite_w_lat, offspring_w_lat], dim=0)
        pop_beta_idx = torch.cat([elite_beta, offspring_beta], dim=0)

    print("\n✅ Asymmetric WTA Hardware Logic Synthesis Complete.")
    print(f"The final tapeout-ready Output Layer is saved as 'wta_ga_best.pt'.")

if __name__ == "__main__":
    main()