import os
import torch
import torch.nn as nn
from tqdm import tqdm
from dataset_cached import get_cached_dataloaders
from utils_ledger import load_ledger

import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="torchaudio._backend.utils")

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier" 

# GA Hyperparameters
POP_SIZE = 2000
GENERATIONS = 100
MUTATION_RATE = 0.15
ELITE_FRAC = 0.05
NUM_KEYWORDS = 5
NUM_INPUTS = 6 # 5 base keywords + 1 noise
THRESH = 64.0  # Raised to 64 for better integer headroom
FORCE_RECACHE = True # Must be True to delete old PyTorch simulation spikes!

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

# ======================================================================
# SILICON CHIP (Loads strictly from pure_integer_model.pt)
# ======================================================================
class PureIntegerHardwareNet(nn.Module):
    def __init__(self, config, device):
        super().__init__()
        self.device = device
        self.num_hidden = config["num_hidden"]
        self.num_inputs = config["num_inputs"]
        self.num_outputs = config["num_outputs"]

        manifest_path = os.path.join(TARGET_FOLDER, "pure_integer_model.pt")
        if not os.path.exists(manifest_path):
            raise FileNotFoundError(f"Missing {manifest_path}. Run Phase 5 first.")
            
        manifest = torch.load(manifest_path, map_location=device)
        
        self.global_delta = manifest["delta_in"] 
        self.delta_out = manifest["delta_out"]
        self.g_in = manifest.get("g_in", 2)
        self.g_rec = manifest.get("g_rec", 2)
        
        self.w_in_int = nn.Parameter(manifest["w_in_int"], requires_grad=False)
        self.w_rec_int = nn.Parameter(manifest["w_rec_int"], requires_grad=False)
        self.w_out_int = nn.Parameter(manifest["w_out_int"], requires_grad=False)
        
        self.pos_masks_in = nn.Parameter(manifest["pos_masks_in"], requires_grad=False)
        self.neg_masks_in = nn.Parameter(manifest["neg_masks_in"], requires_grad=False)
        self.pos_masks_rec = nn.Parameter(manifest["pos_masks_rec"], requires_grad=False)
        self.neg_masks_rec = nn.Parameter(manifest["neg_masks_rec"], requires_grad=False)

        self.beta_hid = manifest["beta_hid"].to(device)
        self.frac_bits_hid = manifest["frac_bits_hid"].to(device)
        self.beta_out = manifest["beta_out"].to(device)
        self.frac_bits_out = manifest["frac_bits_out"].to(device)

        self.max_mem_hid = (2.0 ** (manifest["int_bits_hid"].to(device) + self.frac_bits_hid)) - 1.0
        self.max_mem_out = (2.0 ** (manifest["int_bits_out"].to(device) + self.frac_bits_out)) - 1.0

        self.lsb_hid = self.global_delta / (2.0 ** self.frac_bits_hid)
        self.lsb_out = self.delta_out / (2.0 ** self.frac_bits_out)

        self.thresh_hid = torch.round(1.0 / self.global_delta) * self.global_delta
        self.thresh_out = torch.round(1.0 / self.delta_out) * self.delta_out

        self.bit_shifts = nn.Parameter(torch.tensor([1<<i for i in range(8)], dtype=torch.int32, device=device).view(1, 8, 1, 1), requires_grad=False)
        
        self.rebuild_bit_mats()

    def _build_bit_mats(self, gate_masks, w_abs_int, num_gates):
        mats = []
        for g in range(num_gates):
            w_gate = w_abs_int * gate_masks[g]
            bits = []
            for b in range(8):
                has_bit = ((w_gate & (1 << b)) != 0).float()
                bits.append(has_bit.t())
            mats.append(torch.stack(bits, dim=0))
        return torch.stack(mats, dim=0) 

    def rebuild_bit_mats(self):
        w_in_abs = torch.abs(self.w_in_int.data)
        w_rec_abs = torch.abs(self.w_rec_int.data)
        
        self.pos_bit_mats_in = self._build_bit_mats(self.pos_masks_in, w_in_abs, self.g_in).view(self.g_in * 8, self.num_inputs, self.num_hidden)
        self.neg_bit_mats_in = self._build_bit_mats(self.neg_masks_in, w_in_abs, self.g_in).view(self.g_in * 8, self.num_inputs, self.num_hidden)
        self.pos_bit_mats_rec = self._build_bit_mats(self.pos_masks_rec, w_rec_abs, self.g_rec).view(self.g_rec * 8, self.num_hidden, self.num_hidden)
        self.neg_bit_mats_rec = self._build_bit_mats(self.neg_masks_rec, w_rec_abs, self.g_rec).view(self.g_rec * 8, self.num_hidden, self.num_hidden)

    def forward(self, x):
        batch = x.size(0)
        time_steps = x.size(1)
        
        mem_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        mem_out = torch.zeros(batch, self.num_outputs, device=self.device)
        spk_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        spk_out_rec = []

        for step in range(time_steps):
            x_batched = x[:, step, :].unsqueeze(0) 
            spk_batched = spk_hid.unsqueeze(0)     
            
            pos_counts_in = torch.matmul(x_batched, self.pos_bit_mats_in)
            neg_counts_in = torch.matmul(x_batched, self.neg_bit_mats_in)
            pos_int_in = ((pos_counts_in > 0).int().view(self.g_in, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0, 1))
            neg_int_in = ((neg_counts_in > 0).int().view(self.g_in, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0, 1))
            
            pos_counts_rec = torch.matmul(spk_batched, self.pos_bit_mats_rec) 
            neg_counts_rec = torch.matmul(spk_batched, self.neg_bit_mats_rec)
            pos_int_rec = ((pos_counts_rec > 0).int().view(self.g_rec, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0, 1))
            neg_int_rec = ((neg_counts_rec > 0).int().view(self.g_rec, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0, 1))
            
            hw_sum_int = (pos_int_in - neg_int_in) + (pos_int_rec - neg_int_rec)
            hw_sum_float = hw_sum_int.float() * self.global_delta
            
            ideal_mem_hid = (mem_hid * self.beta_hid.unsqueeze(0)) + hw_sum_float
            limit_hid = (self.max_mem_hid * self.lsb_hid).unsqueeze(0)
            ideal_mem_hid = torch.clamp(ideal_mem_hid, min=-limit_hid, max=limit_hid)
            mem_hid = torch.floor((ideal_mem_hid / self.lsb_hid.unsqueeze(0)) + 1e-5) * self.lsb_hid.unsqueeze(0)
            
            spk_hid = (mem_hid >= self.thresh_hid).float()
            mem_hid = mem_hid * (1.0 - spk_hid) 
            
            cur_out_int = torch.matmul(spk_hid.int(), self.w_out_int.t())
            cur_out_float = cur_out_int.float() * self.delta_out
            ideal_mem_out = (mem_out * self.beta_out.unsqueeze(0)) + cur_out_float
            limit_out = (self.max_mem_out * self.lsb_out).unsqueeze(0)
            ideal_mem_out = torch.clamp(ideal_mem_out, min=-limit_out, max=limit_out)
            mem_out = torch.floor((ideal_mem_out / self.lsb_out.unsqueeze(0)) + 1e-5) * self.lsb_out.unsqueeze(0)
            
            spk_out = (mem_out >= self.thresh_out).float()
            mem_out = mem_out * (1.0 - spk_out)
            spk_out_rec.append(spk_out)
            
        return torch.stack(spk_out_rec, dim=1), None

def cache_base_spikes(base_model, loader, device, target_folder):
    cache_path = os.path.join(target_folder, "base_spikes_cache.pt")
    
    if os.path.exists(cache_path) and not FORCE_RECACHE:
        print(f">>> Found cached spikes on disk! Loading from {cache_path}...")
        data = torch.load(cache_path, map_location=device)
        return data["spikes"], data["targets"]
        
    print(">>> Generating True Hardware Silicon Spikes...")
    all_spikes, all_targets = [], []
    with torch.no_grad():
        for x, y in tqdm(loader, desc="Caching Hardware Spikes"):
            x = x.to(device)
            spk_out_base, _ = base_model(x)
            all_spikes.append(spk_out_base.cpu())
            all_targets.append(y.cpu())
            
    spikes_tensor = torch.cat(all_spikes, dim=0)
    targets_tensor = torch.cat(all_targets, dim=0)
    
    print(f">>> Saving {spikes_tensor.size(0)} physical hardware samples to disk cache...")
    torch.save({"spikes": spikes_tensor, "targets": targets_tensor}, cache_path)
    
    return spikes_tensor, targets_tensor

def main():
    device = torch.device("cpu") 
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    print(f"\n=== Phase 7: WTA Hardware Logic Synthesis ===")
    
    train_loader, _, _ = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    
    # Intialize purely from pure_integer_model.pt
    base_model = PureIntegerHardwareNet(config, device).to(device)
    base_model.eval()
    
    # 1. Generate RAM Cache directly from the True Hardware Model
    spikes_tensor, targets_tensor = cache_base_spikes(base_model, train_loader, device, TARGET_FOLDER)
    num_samples = spikes_tensor.size(0)
    time_steps = spikes_tensor.size(1)
    print(f">>> Cached {num_samples} samples. Freeing Silicon Blueprint from memory.")
    del base_model 
    
    # --- 1b. FITNESS ARENA ---
    ARENA_SIZE = min(800, num_samples)
    arena_spikes = spikes_tensor[:ARENA_SIZE].to(device)
    arena_targets = targets_tensor[:ARENA_SIZE].to(device)
    print(f">>> GA Arena set to {ARENA_SIZE} samples for rapid evolution.")
    
    perfect_targets = torch.zeros((ARENA_SIZE, NUM_KEYWORDS), device=device)
    is_keyword = arena_targets < NUM_KEYWORDS
    perfect_targets[torch.arange(ARENA_SIZE)[is_keyword], arena_targets[is_keyword]] = 1.0

    # 2. Initialize Population Tensors
    pop_w_in = torch.zeros(POP_SIZE, NUM_KEYWORDS, NUM_INPUTS, device=device)
    pop_w_in[:, :, :NUM_KEYWORDS] = torch.randint(0, 32, (POP_SIZE, NUM_KEYWORDS, NUM_KEYWORDS))
    pop_w_in[:, :, NUM_KEYWORDS:] = torch.randint(-32, 1, (POP_SIZE, NUM_KEYWORDS, 1))
    
    pop_w_lat = torch.randint(-32, 1, (POP_SIZE, NUM_KEYWORDS, NUM_KEYWORDS), device=device).float()
    diag_mask = ~torch.eye(NUM_KEYWORDS, device=device).bool()
    pop_w_lat = pop_w_lat * diag_mask
    
    pop_beta_idx = torch.randint(48, 64, (POP_SIZE, NUM_KEYWORDS), device=device)
    
    # --- INJECT SMART SEEDS (Top 10% of population) ---
    seed_count = int(POP_SIZE * 0.1)
    
    # +16 on the matched keyword channel, -16 on the noise channel
    ideal_w_in = torch.eye(NUM_KEYWORDS, device=device) * 16.0 
    ideal_w_in = torch.cat([ideal_w_in, torch.full((NUM_KEYWORDS, 1), -16.0, device=device)], dim=-1)
    
    # -16 lateral inhibition everywhere except self
    ideal_w_lat = torch.full((NUM_KEYWORDS, NUM_KEYWORDS), -16.0, device=device) * diag_mask
    
    pop_w_in[:seed_count] = ideal_w_in.unsqueeze(0).repeat(seed_count, 1, 1)
    pop_w_lat[:seed_count] = ideal_w_lat.unsqueeze(0).repeat(seed_count, 1, 1)
    pop_beta_idx[:seed_count] = 60 # Set to a healthy, stable beta (~0.9)
    
    # Add slight noise to seeds to create variety
    if seed_count > 1:
        pop_w_in[1:seed_count] += torch.randint(-3, 4, pop_w_in[1:seed_count].shape, device=device).float()
        pop_w_lat[1:seed_count] += torch.randint(-3, 4, pop_w_lat[1:seed_count].shape, device=device).float() * diag_mask
        pop_beta_idx[1:seed_count] += torch.randint(-2, 3, pop_beta_idx[1:seed_count].shape, device=device)
    
    pop_w_in[:, :, :NUM_KEYWORDS] = torch.clamp(pop_w_in[:, :, :NUM_KEYWORDS], 0, 63)
    pop_w_in[:, :, NUM_KEYWORDS:] = torch.clamp(pop_w_in[:, :, NUM_KEYWORDS:], -64, 0)
    pop_w_lat = torch.clamp(pop_w_lat, -64, 0) * diag_mask
    pop_beta_idx = torch.clamp(pop_beta_idx, 0, 63)

    elite_count = int(POP_SIZE * ELITE_FRAC)
    best_fitness_overall = 0
    
    # 3. Evolution Loop
    pbar = tqdm(range(GENERATIONS), desc="Synthesizing WTA Logic")
    for gen in pbar:
        mem = torch.zeros(POP_SIZE, ARENA_SIZE, NUM_KEYWORDS, device=device)
        total_spikes = torch.zeros(POP_SIZE, ARENA_SIZE, NUM_KEYWORDS, device=device)
        betas = VALID_BETAS[pop_beta_idx].unsqueeze(1)
        
        for t in range(time_steps):
            spikes_t = arena_spikes[:, t, :]
            cur_in = torch.matmul(pop_w_in, spikes_t.T).transpose(1, 2)
            cur_lat = torch.matmul(total_spikes, pop_w_lat)
            
            mem = (mem * betas) + cur_in + cur_lat
            spk = (mem >= THRESH).float()
            mem = mem * (1.0 - spk)
            total_spikes += spk

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
        
        elite_w_in = pop_w_in[sorted_idx[:elite_count]]
        elite_w_lat = pop_w_lat[sorted_idx[:elite_count]]
        elite_beta = pop_beta_idx[sorted_idx[:elite_count]]
        
        parent_idx = torch.randint(0, elite_count, (POP_SIZE - elite_count,), device=device)
        offspring_w_in = elite_w_in[parent_idx].clone()
        offspring_w_lat = elite_w_lat[parent_idx].clone()
        offspring_beta = elite_beta[parent_idx].clone()
        
        mut_mask_in = (torch.rand_like(offspring_w_in, dtype=torch.float) < MUTATION_RATE).float()
        offspring_w_in += torch.randint(-3, 4, offspring_w_in.shape, device=device).float() * mut_mask_in
        offspring_w_in[:, :, :NUM_KEYWORDS] = torch.clamp(offspring_w_in[:, :, :NUM_KEYWORDS], 0, 63)
        offspring_w_in[:, :, NUM_KEYWORDS:] = torch.clamp(offspring_w_in[:, :, NUM_KEYWORDS:], -64, 0)
        
        mut_mask_lat = (torch.rand_like(offspring_w_lat, dtype=torch.float) < MUTATION_RATE).float()
        offspring_w_lat += torch.randint(-3, 4, offspring_w_lat.shape, device=device).float() * mut_mask_lat
        offspring_w_lat = torch.clamp(offspring_w_lat, -64, 0)
        offspring_w_lat = offspring_w_lat * diag_mask 
        
        mut_mask_beta = (torch.rand(offspring_beta.shape, device=device) < MUTATION_RATE).int()
        offspring_beta += torch.randint(-1, 2, offspring_beta.shape, device=device) * mut_mask_beta
        offspring_beta = torch.clamp(offspring_beta, 0, 63)
        
        pop_w_in = torch.cat([elite_w_in, offspring_w_in], dim=0)
        pop_w_lat = torch.cat([elite_w_lat, offspring_w_lat], dim=0)
        pop_beta_idx = torch.cat([elite_beta, offspring_beta], dim=0)

    print("\n✅ WTA Hardware Logic Synthesis Complete.")
    print(f"The final tapeout-ready Output Layer is saved as 'wta_ga_best.pt'.")

if __name__ == "__main__":
    main()