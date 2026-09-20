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

# Optimal 6-Channel SNN Config
BETAS = torch.tensor([0.9688, 0.9531, 0.9844, 0.9688, 0.9688, 0.0625])
THRESHOLDS = torch.tensor([17.25, 11.75, 33.5, 16.75, 17.5, 1.125])
TRAIN_MULTIPLIER = 10  

def _augment(waveform):
    shift = random.randint(-800, 800)
    waveform = torch.roll(waveform, shifts=shift, dims=-1)
    scale = random.uniform(0.9, 1.1)
    waveform = waveform * scale
    return waveform

# Compiles directly to raw LLVM machine code. Runs in <2ms.
@njit
def run_1mhz_silicon_loop(pdm_bits, v_ths, pdm_adds):
    # Reduced to 6 physical hardware channels
    spikes_out = np.zeros((1000, 6), dtype=np.float32)
    mem = np.zeros(6, dtype=np.int32)
    next_v = np.zeros(6, dtype=np.int32) 
    sticky = np.zeros(6, dtype=np.bool_)
    
    window_idx = 0
    tick_cnt = 0
    
    for t in range(len(pdm_bits)):
        pdm_in = pdm_bits[t]
        
        # 1. Exact Hardware Shift-Subtractors for the NEW 6-Channel Layout
        next_v[0] = mem[0] - (mem[0] >> 5)
        next_v[1] = mem[1] - (mem[1] >> 4) + (mem[1] >> 6)
        next_v[2] = mem[2] - (mem[2] >> 6)
        next_v[3] = mem[3] - (mem[3] >> 5)
        next_v[4] = mem[4] - (mem[4] >> 5)
        next_v[5] = mem[5] - (mem[5] >> 1) - (mem[5] >> 1) + (mem[5] >> 4)
        
        # 2. Integration & Thresholding
        for c in range(6):
            mem[c] = next_v[c] + (pdm_in * pdm_adds[c])
            if mem[c] >= v_ths[c]:
                mem[c] = 0
                sticky[c] = True
        
        # 3. 1ms Window Framing
        tick_cnt += 1
        if tick_cnt == 1000:
            if window_idx < 1000:
                for c in range(6):
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
    
    # DYNAMIC HARDWARE LINKING: True 6-channel physical truncation constants
    pdm_adds = np.array([32, 64, 64, 32, 32, 16], dtype=np.int32)
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