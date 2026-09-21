import os
import torch
import torch.nn as nn
from tqdm import tqdm
from utils_ledger import load_ledger
from dataset_cached import get_cached_dataloaders

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

# FIXED: 65-Element Array (Matches Phase 3)
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
# EXACT PHASE 6 HARDWARE PHYSICS FOR FLAWLESS CACHE GENERATION
# ======================================================================
class PureIntegerHardwareNet(nn.Module):
    def __init__(self, config, device):
        super().__init__()
        self.device = device
        self.num_hidden = config["num_hidden"]
        self.num_inputs = config["num_inputs"]
        self.num_outputs = config["num_outputs"]

        manifest = torch.load(os.path.join(TARGET_FOLDER, "pure_integer_model.pt"), map_location=device)
        self.global_delta = manifest["delta_in"] 
        self.delta_out = manifest["delta_out"]
        self.g_in = manifest.get("g_in", 2)
        self.g_rec = manifest.get("g_rec", 1)
        self.g_out = manifest.get("g_out", 1) 
        
        self.w_in_int = nn.Parameter(manifest["w_in_int"], requires_grad=False)
        self.w_rec_int = nn.Parameter(manifest["w_rec_int"], requires_grad=False)
        self.w_out_int = nn.Parameter(manifest["w_out_int"], requires_grad=False)
        self.pos_masks_in = nn.Parameter(manifest["pos_masks_in"], requires_grad=False)
        self.neg_masks_in = nn.Parameter(manifest["neg_masks_in"], requires_grad=False)
        self.pos_masks_rec = nn.Parameter(manifest["pos_masks_rec"], requires_grad=False)
        self.neg_masks_rec = nn.Parameter(manifest["neg_masks_rec"], requires_grad=False)
        self.pos_masks_out = nn.Parameter(manifest["pos_masks_out"], requires_grad=False)
        self.neg_masks_out = nn.Parameter(manifest["neg_masks_out"], requires_grad=False)

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
        self.pos_bit_mats_in = self._build_bit_mats(self.pos_masks_in, torch.abs(self.w_in_int.data), self.g_in).view(self.g_in * 8, self.num_inputs, self.num_hidden)
        self.neg_bit_mats_in = self._build_bit_mats(self.neg_masks_in, torch.abs(self.w_in_int.data), self.g_in).view(self.g_in * 8, self.num_inputs, self.num_hidden)
        self.pos_bit_mats_rec = self._build_bit_mats(self.pos_masks_rec, torch.abs(self.w_rec_int.data), self.g_rec).view(self.g_rec * 8, self.num_hidden, self.num_hidden)
        self.neg_bit_mats_rec = self._build_bit_mats(self.neg_masks_rec, torch.abs(self.w_rec_int.data), self.g_rec).view(self.g_rec * 8, self.num_hidden, self.num_hidden)
        self.pos_bit_mats_out = self._build_bit_mats(self.pos_masks_out, torch.abs(self.w_out_int.data), self.g_out).view(self.g_out * 8, self.num_hidden, self.num_outputs)
        self.neg_bit_mats_out = self._build_bit_mats(self.neg_masks_out, torch.abs(self.w_out_int.data), self.g_out).view(self.g_out * 8, self.num_hidden, self.num_outputs)

    def forward(self, x):
        batch, time_steps, _ = x.size()
        mem_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        mem_out = torch.zeros(batch, self.num_outputs, device=self.device)
        spk_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        spk_out_rec = []

        for step in range(time_steps):
            x_batched = x[:, step, :].unsqueeze(0) 
            spk_batched = spk_hid.unsqueeze(0)     
            
            # Hidden
            p_in = ((torch.matmul(x_batched, self.pos_bit_mats_in) > 0).int().view(self.g_in, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0, 1))
            n_in = ((torch.matmul(x_batched, self.neg_bit_mats_in) > 0).int().view(self.g_in, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0, 1))
            p_rec = ((torch.matmul(spk_batched, self.pos_bit_mats_rec) > 0).int().view(self.g_rec, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0, 1))
            n_rec = ((torch.matmul(spk_batched, self.neg_bit_mats_rec) > 0).int().view(self.g_rec, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0, 1))
            
            ideal_mem_hid = (mem_hid * self.beta_hid.unsqueeze(0)) + (((p_in - n_in) + (p_rec - n_rec)).float() * self.global_delta)
            limit_hid = (self.max_mem_hid * self.lsb_hid).unsqueeze(0)
            ideal_mem_hid = torch.clamp(ideal_mem_hid, min=-limit_hid, max=limit_hid)
            mem_hid = torch.floor((ideal_mem_hid / self.lsb_hid.unsqueeze(0)) + 1e-5) * self.lsb_hid.unsqueeze(0)
            
            spk_hid = (mem_hid >= self.thresh_hid).float()
            mem_hid = mem_hid * (1.0 - spk_hid) 
            
            # Output
            p_out = ((torch.matmul(spk_hid.unsqueeze(0), self.pos_bit_mats_out) > 0).int().view(self.g_out, 8, batch, self.num_outputs) * self.bit_shifts).sum(dim=(0, 1))
            n_out = ((torch.matmul(spk_hid.unsqueeze(0), self.neg_bit_mats_out) > 0).int().view(self.g_out, 8, batch, self.num_outputs) * self.bit_shifts).sum(dim=(0, 1))
            
            ideal_mem_out = (mem_out * self.beta_out.unsqueeze(0)) + ((p_out - n_out).float() * self.delta_out)
            limit_out = (self.max_mem_out * self.lsb_out).unsqueeze(0)
            ideal_mem_out = torch.clamp(ideal_mem_out, min=-limit_out, max=limit_out)
            mem_out = torch.floor((ideal_mem_out / self.lsb_out.unsqueeze(0)) + 1e-5) * self.lsb_out.unsqueeze(0)
            
            spk_out = (mem_out >= self.thresh_out).float()
            mem_out = mem_out * (1.0 - spk_out)
            spk_out_rec.append(spk_out)
            
        return torch.stack(spk_out_rec, dim=1)

def generate_cache(device, target_folder, cache_path):
    print("\n>>> Cache missing. Generating Base Spikes using EXACT Phase 6 Hardware Verifier...")
    ledger = load_ledger(target_folder)
    train_loader, _, _ = get_cached_dataloaders("data_cache", batch_size=128)
    model = PureIntegerHardwareNet(ledger["base_config"], device).to(device)
    model.eval()

    all_spikes, all_targets = [], []
    samples_processed = 0
    
    with torch.no_grad():
        for x, y in tqdm(train_loader, desc="Simulating True Hardware Physics"):
            x, y = x.to(device), y.to(device)
            spk_out = model(x)
            all_spikes.append(spk_out)
            all_targets.append(y)
            
            samples_processed += x.size(0)
            if samples_processed >= 1500:
                break
                
    spikes_tensor = torch.cat(all_spikes, dim=0)[:1500]
    targets_tensor = torch.cat(all_targets, dim=0)[:1500]
    torch.save({"spikes": spikes_tensor, "targets": targets_tensor}, cache_path)
    print(f"✅ Cache generated and saved to {cache_path}")


def main():
    device = torch.device("cpu") 
    print(f"\n=== Phase 7b: ASYMMETRIC WTA GA (First-Spike Metric) ===")
    
    cache_path = os.path.join(TARGET_FOLDER, "base_spikes_cache.pt")
    if not os.path.exists(cache_path):
        generate_cache(device, TARGET_FOLDER, cache_path)
        
    data = torch.load(cache_path, map_location=device)
    spikes_tensor = data["spikes"]
    targets_tensor = data["targets"]
    
    num_samples = spikes_tensor.size(0)
    time_steps = spikes_tensor.size(1)
    
    ARENA_SIZE = min(1500, num_samples)
    arena_spikes = spikes_tensor[:ARENA_SIZE].to(device)
    arena_targets = targets_tensor[:ARENA_SIZE].to(device)
    print(f">>> Fine-tuning asymmetric weights on {ARENA_SIZE} samples.")
    
    perfect_targets = torch.zeros((ARENA_SIZE, NUM_KEYWORDS), device=device)
    is_keyword = arena_targets < NUM_KEYWORDS
    perfect_targets[torch.arange(ARENA_SIZE)[is_keyword], arena_targets[is_keyword]] = 1.0

    pop_w_in = torch.zeros(POP_SIZE, NUM_KEYWORDS, NUM_INPUTS, device=device)
    pop_w_in[:, :, :NUM_KEYWORDS] = torch.randint(-8, 12, (POP_SIZE, NUM_KEYWORDS, NUM_KEYWORDS))
    pop_w_in[:, :, NUM_KEYWORDS:] = torch.randint(-8, 1, (POP_SIZE, NUM_KEYWORDS, 1))
    
    pop_w_lat = torch.randint(-128, -64, (POP_SIZE, NUM_KEYWORDS, NUM_KEYWORDS), device=device).float()
    diag_mask = ~torch.eye(NUM_KEYWORDS, device=device).bool()
    pop_w_lat = pop_w_lat * diag_mask
    
    pop_beta_idx = torch.randint(60, 65, (POP_SIZE, NUM_KEYWORDS), device=device)
    
    # --- INJECT GOLDEN SYMMETRIC SEED ---
    seed_count = int(POP_SIZE * 0.50)
    
    ideal_w_in = torch.full((NUM_KEYWORDS, NUM_KEYWORDS), -1.0, device=device)
    ideal_w_in.fill_diagonal_(6.0) 
    ideal_w_in = torch.cat([ideal_w_in, torch.full((NUM_KEYWORDS, 1), -2.0, device=device)], dim=-1)
    
    ideal_w_lat = torch.full((NUM_KEYWORDS, NUM_KEYWORDS), -128.0, device=device) * diag_mask
    
    pop_w_in[:seed_count] = ideal_w_in.unsqueeze(0).repeat(seed_count, 1, 1)
    pop_w_lat[:seed_count] = ideal_w_lat.unsqueeze(0).repeat(seed_count, 1, 1)
    pop_beta_idx[:seed_count] = 64 # 1.000 (No leak, correct index)
    
    if seed_count > 1:
        pop_w_in[1:seed_count] += torch.randint(-1, 2, pop_w_in[1:seed_count].shape, device=device).float()
        pop_w_lat[1:seed_count] += torch.randint(-16, 17, pop_w_lat[1:seed_count].shape, device=device).float() * diag_mask
    
    # FIXED CLAMPING: Allow inhibitory weights!
    pop_w_in[:, :, :NUM_KEYWORDS] = torch.clamp(pop_w_in[:, :, :NUM_KEYWORDS], -128, 127)
    pop_w_in[:, :, NUM_KEYWORDS:] = torch.clamp(pop_w_in[:, :, NUM_KEYWORDS:], -128, 0)
    pop_w_lat = torch.clamp(pop_w_lat, -128, 0) * diag_mask
    pop_beta_idx = torch.clamp(pop_beta_idx, 0, 64)

    elite_count = int(POP_SIZE * ELITE_FRAC)
    best_fitness_overall = 0
    
    pbar = tqdm(range(GENERATIONS), desc="Evolving Asymmetric Logic")
    for gen in pbar:
        mem = torch.zeros(POP_SIZE, ARENA_SIZE, NUM_KEYWORDS, device=device)
        total_spikes = torch.zeros(POP_SIZE, ARENA_SIZE, NUM_KEYWORDS, device=device)
        spk = torch.zeros(POP_SIZE, ARENA_SIZE, NUM_KEYWORDS, device=device) 
        
        betas = VALID_BETAS[pop_beta_idx].unsqueeze(1)
        
        for t in range(time_steps):
            spikes_t = arena_spikes[:, t, :]
            cur_in = torch.matmul(pop_w_in, spikes_t.T).transpose(1, 2)
            cur_lat = torch.matmul(spk, pop_w_lat)
            
            mem = (mem * betas) + cur_in + cur_lat
            spk = (mem >= THRESH).float()
            mem = mem * (1.0 - spk)
            total_spikes += spk

        # --- FRIEND'S FIX: TARGET-FIRED METRIC (Ignoring multi-spikes) ---
        target_spikes = total_spikes * perfect_targets.unsqueeze(0)
        other_spikes = total_spikes * (1.0 - perfect_targets.unsqueeze(0))
        
        target_fired = target_spikes.sum(dim=-1) > 0  
        others_fired = other_spikes.sum(dim=-1) > 0   
        
        is_correct = (target_fired & ~others_fired).float()
        fitness = is_correct.sum(dim=1) 
        
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
        offspring_w_in[:, :, :NUM_KEYWORDS] = torch.clamp(offspring_w_in[:, :, :NUM_KEYWORDS], -128, 127)
        offspring_w_in[:, :, NUM_KEYWORDS:] = torch.clamp(offspring_w_in[:, :, NUM_KEYWORDS:], -128, 0)
        
        mut_mask_lat = (torch.rand_like(offspring_w_lat, dtype=torch.float) < MUTATION_RATE).float()
        offspring_w_lat += torch.randint(-16, 17, offspring_w_lat.shape, device=device).float() * mut_mask_lat
        offspring_w_lat = torch.clamp(offspring_w_lat, -128, 0) * diag_mask 
        
        mut_mask_beta = (torch.rand(offspring_beta.shape, device=device) < MUTATION_RATE).int()
        offspring_beta += torch.randint(-1, 2, offspring_beta.shape, device=device) * mut_mask_beta
        offspring_beta = torch.clamp(offspring_beta, 0, 64)
        
        pop_w_in = torch.cat([elite_w_in, offspring_w_in], dim=0)
        pop_w_lat = torch.cat([elite_w_lat, offspring_w_lat], dim=0)
        pop_beta_idx = torch.cat([elite_beta, offspring_beta], dim=0)

    print("\n✅ Asymmetric WTA Hardware Logic Synthesis Complete.")
    print(f"The final tapeout-ready Output Layer is saved as 'wta_ga_best.pt'.")

if __name__ == "__main__":
    main()