import os
import torch
import torchaudio
import random
from tqdm import tqdm
import warnings
import numpy as np
from numba import njit

# Suppress the torchaudio backend warning for clean console output
warnings.filterwarnings("ignore", category=UserWarning)

# --- SILICON HARDWARE CONFIG ---
MIC_MHZ = 1000000        
SNN_CLOCK_HZ = 1000      
WINDOW_TICKS = MIC_MHZ // SNN_CLOCK_HZ

# You can dynamically change these. The simulation will auto-scale them by 1024.
THRESHOLDS = torch.tensor([3.5, 5.00, 8.00, 15.125, 2.75, 21.0, 22.25, 58.5])
TRAIN_MULTIPLIER = 10  

"""

=======================================================
      🏆 OPTIMAL 6-CHANNEL COCHLEA GENERATED 🏆
=======================================================

// --- Channel 0 ---
// Beta: 0.0625 | Thresh Mult: 1.0625 | Reg Size: 7-bit (Frac: 6)
wire [6:0] next_v_0 = mem_0 + (mem_0 >> 4) - (mem_0 >> 1) - (mem_0 >> 1) + (pdm_in ? 7'd64 : 7'd0);
wire fired_0 = (next_v_0 >= 7'd68);

// --- Channel 1 ---
// Beta: 0.9219 | Thresh Mult: 10.0 | Reg Size: 9-bit (Frac: 5)
wire [8:0] next_v_1 = mem_1 - (mem_1 >> 4) - (mem_1 >> 6) + (pdm_in ? 9'd32 : 9'd0);
wire fired_1 = (next_v_1 >= 9'd320);

// --- Channel 2 ---
// Beta: 0.9688 | Thresh Mult: 17.0 | Reg Size: 11-bit (Frac: 6)
wire [10:0] next_v_2 = mem_2 - (mem_2 >> 5) + (pdm_in ? 11'd64 : 11'd0);
wire fired_2 = (next_v_2 >= 11'd1088);

// --- Channel 3 ---
// Beta: 0.9531 | Thresh Mult: 11.375 | Reg Size: 8-bit (Frac: 4)
wire [7:0] next_v_3 = mem_3 + (mem_3 >> 6) - (mem_3 >> 4) + (pdm_in ? 8'd16 : 8'd0);
wire fired_3 = (next_v_3 >= 8'd182);

// --- Channel 4 ---
// Beta: 0.9219 | Thresh Mult: 7.5 | Reg Size: 8-bit (Frac: 5)
wire [7:0] next_v_4 = mem_4 - (mem_4 >> 4) - (mem_4 >> 6) + (pdm_in ? 8'd32 : 8'd0);
wire fired_4 = (next_v_4 >= 8'd240);

// --- Channel 5 ---
// Beta: 0.9844 | Thresh Mult: 34.0 | Reg Size: 11-bit (Frac: 5)
wire [10:0] next_v_5 = mem_5 - (mem_5 >> 6) + (pdm_in ? 11'd32 : 11'd0);
wire fired_5 = (next_v_5 >= 11'd1088);

=== Update PyTorch Config ===
BETAS = torch.tensor([0.0625, 0.9219, 0.9688, 0.9531, 0.9219, 0.9844])
THRESHOLDS = torch.tensor([1.0625, 10.0, 17.0, 11.375, 7.5, 34.0])

"""

def _augment(waveform):
    shift = random.randint(-800, 800)
    waveform = torch.roll(waveform, shifts=shift, dims=-1)
    scale = random.uniform(0.9, 1.1)
    waveform = waveform * scale
    return waveform

# Compiles directly to raw LLVM machine code. Runs in <2ms.
@njit
def run_1mhz_silicon_loop(pdm_bits, v_ths, pdm_adds):
    spikes_out = np.zeros((1000, 8), dtype=np.float32)
    mem = np.zeros(8, dtype=np.int32)
    next_v = np.zeros(8, dtype=np.int32) 
    sticky = np.zeros(8, dtype=np.bool_)
    
    window_idx = 0
    tick_cnt = 0
    
    for t in range(len(pdm_bits)):
        pdm_in = pdm_bits[t]
        
        # 1. Hardware Shift-Subtractors (In-place array writes)
        next_v[0] = mem[0] - (mem[0] >> 2) + (mem[0] >> 4)
        next_v[1] = mem[1] - (mem[1] >> 3) + (mem[1] >> 7) - (mem[1] >> 9)
        next_v[2] = mem[2] - (mem[2] >> 4) - (mem[2] >> 7)
        next_v[3] = mem[3] - (mem[3] >> 5) - (mem[3] >> 8)
        next_v[4] = mem[4] - (mem[4] >> 2) + (mem[4] >> 8)
        next_v[5] = mem[5] - (mem[5] >> 5) + (mem[5] >> 7) - (mem[5] >> 9)
        next_v[6] = mem[6] - (mem[6] >> 5) + (mem[6] >> 7)
        next_v[7] = mem[7] - (mem[7] >> 7) - (mem[7] >> 10)
        
        # 2. Integration & Thresholding
        for c in range(8):
            mem[c] = next_v[c] + (pdm_in * pdm_adds[c])
            if mem[c] >= v_ths[c]:
                mem[c] = 0
                sticky[c] = True
        
        # 3. 1ms Window Framing
        tick_cnt += 1
        if tick_cnt == 1000:
            if window_idx < 1000:
                for c in range(8):
                    if sticky[c]:
                        spikes_out[window_idx, c] = 1.0
                    sticky[c] = False
            tick_cnt = 0
            window_idx += 1
            
    return spikes_out


def simulate_silicon_cochlea(waveform, device):
    wave_1m = torch.nn.functional.interpolate(waveform.view(1, 1, -1), size=1000000, mode='linear', align_corners=False).squeeze()
    wave_unipolar = ((wave_1m + 1.0) / 2.0).clamp(0.0, 1.0)
    
    integral = torch.cumsum(wave_unipolar, dim=-1)
    pdm_bits = torch.diff(torch.floor(integral), prepend=torch.zeros(1, device=waveform.device)).to(torch.int32)
    
    # DYNAMIC HARDWARE LINKING: True 16-bit physical limits
    # Multiplies the global THRESHOLDS array by 1024 for bit-accurate shifting
    pdm_adds = np.array([16, 512, 128, 512, 1024, 512, 128, 1024], dtype=np.int32)
    v_ths = (THRESHOLDS.numpy() * pdm_adds).astype(np.int32)
    
    
    spikes_np = run_1mhz_silicon_loop(pdm_bits.cpu().numpy(), v_ths, pdm_adds)
    spikes = torch.from_numpy(spikes_np).to(device)
    
    return spikes

def main():
    device = torch.device("cpu")
    raw_audio_dir = "custom_audio" 
    cache_dir = "data_cache"
    
    labels = [d for d in os.listdir(raw_audio_dir) if not d.startswith(".")]
    
    print("=== Fabricating Vectorized Silicon Cache ===")
    for lbl in labels:
        in_dir = os.path.join(raw_audio_dir, lbl)
        out_dir = os.path.join(cache_dir, lbl)
        os.makedirs(out_dir, exist_ok=True)
        
        files = [f for f in os.listdir(in_dir) if f.endswith(".wav")]
        for f in tqdm(files, desc=f"Processing {lbl}"):
            wav_path = os.path.join(in_dir, f)
            
            waveform, sr = torchaudio.load(wav_path)
            
            # --- THE FIX: Safe Mono Downmix ---
            if waveform.shape[0] > 1:
                waveform = waveform.mean(dim=0, keepdim=True)
                
            if waveform.shape[-1] < sr:
                waveform = torch.nn.functional.pad(waveform, (0, sr - waveform.shape[-1]))
            else:
                waveform = waveform[:, :sr]

            current_multiplier = 1 if lbl == "noise" else TRAIN_MULTIPLIER
                
            # --- THE FIX: Obey the current_multiplier ---
            for i in range(current_multiplier):
                pt_path = os.path.join(out_dir, f.replace(".wav", f"_aug{i}.pt"))
                if os.path.exists(pt_path):
                    continue
                
                if i == 0:
                    aug_wave = waveform
                else:
                    aug_wave = _augment(waveform)
                    
                spikes = simulate_silicon_cochlea(aug_wave, device)
                torch.save(spikes.cpu(), pt_path)

if __name__ == "__main__":
    main()