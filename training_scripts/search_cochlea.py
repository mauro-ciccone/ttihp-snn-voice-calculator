import os
import torch
import torchaudio
from tqdm import tqdm

# --- 1. THE IDEAL TARGETS (From Table 2) ---
IDEAL_BETAS = torch.tensor([0.75, 0.80, 0.85, 0.90, 0.95, 0.97, 0.98, 0.99])
IDEAL_THRESHOLDS = torch.tensor([2.72, 3.235, 4.085, 5.737, 10.75, 17.45, 25.95, 51.15])

MIC_MHZ = 1000000
SNN_CLOCK_HZ = 1000
WINDOW = MIC_MHZ // SNN_CLOCK_HZ

# --- 2. EXPANDED HARDWARE SEARCH SPACE ---
HW_BETAS = []
# 1 Shift
for i in range(1, 10):
    HW_BETAS.append((1.0 - (1.0 / (2**i)), 1, f"V - (V>>{i})"))
# 2 Shifts
for i in range(1, 10):
    for j in range(i+1, 11):
        HW_BETAS.append((1.0 - (1.0 / (2**i)) + (1.0 / (2**j)), 2, f"V - (V>>{i}) + (V>>{j})"))
        HW_BETAS.append((1.0 - (1.0 / (2**i)) - (1.0 / (2**j)), 2, f"V - (V>>{i}) - (V>>{j})"))
# 3 Shifts
for i in range(1, 8):
    for j in range(i+1, 10):
        for k in range(j+1, 11):
            HW_BETAS.append((1.0 - (1.0/(2**i)) - (1.0/(2**j)) - (1.0/(2**k)), 3, f"V - (V>>{i}) - (V>>{j}) - (V>>{k})"))
            HW_BETAS.append((1.0 - (1.0/(2**i)) + (1.0/(2**j)) - (1.0/(2**k)), 3, f"V - (V>>{i}) + (V>>{j}) - (V>>{k})"))
# 4 Shifts
for i in range(1, 7):
    for j in range(i+1, 9):
        for k in range(j+1, 10):
            for m in range(k+1, 11):
                HW_BETAS.append((1.0 - (1.0/(2**i)) + (1.0/(2**j)) - (1.0/(2**k)) + (1.0/(2**m)), 4, f"V - (V>>{i}) + (V>>{j}) - (V>>{k}) + (V>>{m})"))

# Deduplicate Betas
unique_betas = {}
for val, cost, eq in HW_BETAS:
    if val not in unique_betas or cost < unique_betas[val][0]:
        unique_betas[val] = (cost, eq)
HW_BETAS = [(v, c, eq) for v, (c, eq) in unique_betas.items()]

# Generate Thresholds with up to 4 bits set, stepping by 256 (0.25 in Q6.10).
# This gives ultra-fine precision at the high end without exploding gate count.
HW_THRESHS = []
for val in range(1024, 65536, 256): 
    bit_count = bin(val).count('1')
    if bit_count <= 4:
        HW_THRESHS.append((val / 1024.0, bit_count))

def get_test_waves():
    waves = []
    for lbl in ["drü", "eis", "zwoi", "vier"]:
        lbl_dir = os.path.join("custom_audio", lbl)
        if not os.path.exists(lbl_dir): continue
        files = [f for f in os.listdir(lbl_dir) if f.endswith(".wav")][:3] 
        for f in files:
            wav, sr = torchaudio.load(os.path.join(lbl_dir, f))
            if wav.shape[-1] < sr: wav = torch.nn.functional.pad(wav, (0, sr - wav.shape[-1]))
            else: wav = wav[:, :sr]
            
            wave_1m = torch.nn.functional.interpolate(wav.view(1, 1, -1), size=MIC_MHZ, mode='linear', align_corners=False).squeeze()
            wave_unipolar = ((wave_1m + 1.0) / 2.0).clamp(0.0, 1.0)
            integral = torch.cumsum(wave_unipolar, dim=-1)
            pdm_bits = torch.diff(torch.floor(integral), prepend=torch.zeros(1)).view(SNN_CLOCK_HZ, WINDOW)
            waves.append(pdm_bits)
    return waves

def simulate_channel(pdm_windows, beta, thresh):
    mem = torch.zeros(SNN_CLOCK_HZ)
    sticky = torch.zeros(SNN_CLOCK_HZ, dtype=torch.bool)
    for t in range(WINDOW):
        mem = (mem * beta) + pdm_windows[:, t]
        fired = mem >= thresh
        mem[fired] = 0.0
        sticky = sticky | fired
    return sticky.float()

def main():
    print("Loading audio subset for hardware evaluation...")
    waves = get_test_waves()
    if not waves: 
        print("Error: No audio found. Check your custom_audio path.")
        return
        
    print(f"Loaded {len(waves)} audio samples. Booting Global Resource Search...\n")
    
    best_hw_betas = []
    best_hw_threshs = []
    total_sub_cost = 0
    total_gate_cost = 0
    
    for ch in range(4, 8):
        ideal_b = IDEAL_BETAS[ch].item()
        ideal_t = IDEAL_THRESHOLDS[ch].item()
        
        # Target Physics
        target_spikes = []
        for w in waves: target_spikes.append(simulate_channel(w, ideal_b, ideal_t))
        target_spikes = torch.stack(target_spikes)
        
        # Pre-filter valid candidates to give tqdm an accurate target
        candidates = []
        for b_val, b_cost, b_str in HW_BETAS:
            for t_val, t_cost in HW_THRESHS:
                # Fast heuristic bounds
                if t_val > ideal_t * 2 or t_val < ideal_t / 2: continue
                candidates.append((b_val, b_cost, b_str, t_val, t_cost))
                
        best_score = float('inf')
        best_b = None
        best_t = None
        
        # TQDM Progress Bar explicitly on the valid combinations
        for b_val, b_cost, b_str, t_val, t_cost in tqdm(candidates, desc=f"Optimizing Ch {ch}", leave=False, dynamic_ncols=True):
            
            hw_spikes = []
            for w in waves: hw_spikes.append(simulate_channel(w, b_val, t_val))
            hw_spikes = torch.stack(hw_spikes)
            
            mse = torch.nn.functional.mse_loss(hw_spikes, target_spikes).item()
            
            # The Global Penalty Weighting
            cost_penalty = (b_cost * 0.0015) + (t_cost * 0.0005) 
            score = mse + cost_penalty
            
            if score < best_score:
                best_score = score
                best_b = (b_val, b_cost, b_str)
                best_t = (t_val, t_cost)
                    
        total_sub_cost += best_b[1]
        total_gate_cost += best_t[1]
                    
        print(f"--- Channel {ch} (Ideal: B={ideal_b:.4f}, T={ideal_t:.2f}) ---")
        print(f"HW Match     : Beta = {best_b[0]:.4f}  |  Thresh = {best_t[0]:.2f}")
        print(f"Verilog Leak : {best_b[2]} ({best_b[1]} shifts)")
        print(f"Verilog Comp : V >= 16'd{int(best_t[0]*1024)} ({best_t[1]} set bits)")
        print(f"MSE Score    : {best_score:.6f}\n")
        
        best_hw_betas.append(best_b[0])
        best_hw_threshs.append(best_t[0])
        
    print("=== GLOBAL RESOURCE USAGE ===")
    print(f"Total Shift-Subtractors : {total_sub_cost} (Target: <= 20)")
    print(f"Total Comparator Bits   : {total_gate_cost} (Negligible area footprint)\n")
    
    print("=== FINAL PYTHON CONSTANTS FOR build_cache.py ===")
    print(f"BETAS = torch.tensor({[round(b, 4) for b in best_hw_betas]})")
    print(f"THRESHOLDS = torch.tensor({[round(t, 2) for t in best_hw_threshs]})")

if __name__ == "__main__":
    main()



    """
    Loaded 12 audio samples. Booting Global Resource Search...

--- Channel 0 (Ideal: B=0.7500, T=2.72) ---                                                                                                                             
HW Match     : Beta = 0.8809  |  Thresh = 5.00
Verilog Leak : V - (V>>3) + (V>>7) - (V>>9) (3 shifts)
Verilog Comp : V >= 16'd5120 (2 set bits)
MSE Score    : 0.005667

--- Channel 1 (Ideal: B=0.8000, T=3.23) ---                                                                                                                             
HW Match     : Beta = 0.8809  |  Thresh = 5.00
Verilog Leak : V - (V>>3) + (V>>7) - (V>>9) (3 shifts)
Verilog Comp : V >= 16'd5120 (2 set bits)
MSE Score    : 0.005750

--- Channel 2 (Ideal: B=0.8500, T=4.09) ---                                                                                                                             
HW Match     : Beta = 0.9297  |  Thresh = 8.00
Verilog Leak : V - (V>>4) - (V>>7) (2 shifts)
Verilog Comp : V >= 16'd8192 (1 set bits)
MSE Score    : 0.005917

--- Channel 3 (Ideal: B=0.9000, T=5.74) ---                                                                                                                             
HW Match     : Beta = 0.9512  |  Thresh = 11.00
Verilog Leak : V - (V>>4) + (V>>6) - (V>>9) (3 shifts)
Verilog Comp : V >= 16'd11264 (3 set bits)
MSE Score    : 0.020250

--- Channel 4 (Ideal: B=0.9500, T=10.75) ---                                                                                                                            
HW Match     : Beta = 0.9600  |  Thresh = 13.25
Verilog Leak : V - (V>>5) - (V>>7) - (V>>10) (3 shifts)
Verilog Comp : V >= 16'd13568 (4 set bits)
MSE Score    : 0.012083

--- Channel 5 (Ideal: B=0.9700, T=17.45) ---                                                                                                                            
HW Match     : Beta = 0.9746  |  Thresh = 20.50
Verilog Leak : V - (V>>5) + (V>>7) - (V>>9) (3 shifts)
Verilog Comp : V >= 16'd20992 (3 set bits)
MSE Score    : 0.011250

--- Channel 6 (Ideal: B=0.9800, T=25.95) ---                                                                                                                            
HW Match     : Beta = 0.9766  |  Thresh = 22.25
Verilog Leak : V - (V>>5) + (V>>7) (2 shifts)
Verilog Comp : V >= 16'd22784 (4 set bits)
MSE Score    : 0.010167

--- Channel 7 (Ideal: B=0.9900, T=51.15) ---                                                                                                                            
HW Match     : Beta = 0.9912  |  Thresh = 58.00
Verilog Leak : V - (V>>7) - (V>>10) (2 shifts)
Verilog Comp : V >= 16'd59392 (4 set bits)
MSE Score    : 0.012667

=== GLOBAL RESOURCE USAGE ===
Total Shift-Subtractors : 21 (Target: <= 20)
Total Comparator Bits   : 23 (Negligible area footprint)

    """