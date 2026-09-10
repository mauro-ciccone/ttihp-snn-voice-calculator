import os
import torch
import torchaudio
import random
from tqdm import tqdm
import warnings

# Suppress the torchaudio backend warning for clean console output
warnings.filterwarnings("ignore", category=UserWarning)

# --- SILICON HARDWARE CONFIG ---
MIC_MHZ = 1000000        
SNN_CLOCK_HZ = 1000      
WINDOW_TICKS = MIC_MHZ // SNN_CLOCK_HZ

# --- 7-CHANNEL HARDWARE COCHLEA ALIGNMENT ---
# Ch 0: 0.8809 [V - (V>>3) + (V>>7) - (V>>9)]  | Thresh: V >= 16'd5120
# Ch 1: 0.9297 [V - (V>>4) - (V>>7)]           | Thresh: V >= 16'd8192
# Ch 2: 0.9512 [V - (V>>4) + (V>>6) - (V>>9)]  | Thresh: V >= 16'd11264
# Ch 3: 0.9600 [V - (V>>5) - (V>>7) - (V>>10)] | Thresh: V >= 16'd13568
# Ch 4: 0.9746 [V - (V>>5) + (V>>7) - (V>>9)]  | Thresh: V >= 16'd20992
# Ch 5: 0.9766 [V - (V>>5) + (V>>7)]           | Thresh: V >= 16'd22784
# Ch 6: 0.9912 [V - (V>>7) - (V>>10)]          | Thresh: V >= 16'd59392

BETAS = torch.tensor([0.8809, 0.9297, 0.9512, 0.9600, 0.9746, 0.9766, 0.9912])
THRESHOLDS = torch.tensor([5.00, 8.00, 11.00, 13.25, 20.50, 22.25, 58.00])
TRAIN_MULTIPLIER = 10  

def _augment(waveform):
    shift = random.randint(-800, 800)
    waveform = torch.roll(waveform, shifts=shift, dims=-1)
    scale = random.uniform(0.9, 1.1)
    waveform = waveform * scale
    return waveform

def simulate_silicon_cochlea(waveform, device):
    # 1. Interpolate to physical clock speed (1 MHz)[cite: 1]
    wave_1m = torch.nn.functional.interpolate(waveform.view(1, 1, -1), size=MIC_MHZ, mode='linear', align_corners=False).squeeze()
    
    # Map raw AC audio (-1.0 to 1.0) to physical unipolar voltages (0.0 to 1.0)
    wave_unipolar = ((wave_1m + 1.0) / 2.0).clamp(0.0, 1.0)
    
    # --- TRUE SIGMA-DELTA MODULATOR ---
    # Mathematically perfect, 100% vectorized 1st-order PDM generation.
    integral = torch.cumsum(wave_unipolar, dim=-1)
    pdm_bits = torch.diff(torch.floor(integral), prepend=torch.zeros(1, device=waveform.device))
    
    # Reshape for the SNN clock domains[cite: 1]
    pdm_windows = pdm_bits.to(device).view(SNN_CLOCK_HZ, WINDOW_TICKS).unsqueeze(-1)
    
    betas = BETAS.to(device).view(1, 7)
    v_ths = THRESHOLDS.to(device).view(1, 7)
    
    mem = torch.zeros(SNN_CLOCK_HZ, 7, device=device)
    sticky_latches = torch.zeros(SNN_CLOCK_HZ, 7, dtype=torch.bool, device=device)
    
    # Hardware Integrator Array (The Silicon)[cite: 1]
    for t in range(WINDOW_TICKS):
        mem = (mem * betas) + pdm_windows[:, t, :]
        fired = mem >= v_ths
        mem[fired] = 0.0
        sticky_latches = sticky_latches | fired
        
    return sticky_latches.float()

def main():
    device = torch.device("cpu")
    raw_audio_dir = "custom_audio" 
    cache_dir = "data_cache"
    
    labels = [d for d in os.listdir(raw_audio_dir) if not d.startswith(".")]
    labels.remove("minus")
    labels.remove("plus")
    
    print("=== Fabricating Vectorized Silicon Cache ===")
    for lbl in labels:
        in_dir = os.path.join(raw_audio_dir, lbl)
        out_dir = os.path.join(cache_dir, lbl)
        os.makedirs(out_dir, exist_ok=True)
        
        files = [f for f in os.listdir(in_dir) if f.endswith(".wav")]
        for f in tqdm(files, desc=f"Processing {lbl}"):
            wav_path = os.path.join(in_dir, f)
            
            waveform, sr = torchaudio.load(wav_path)
            if waveform.shape[-1] < sr:
                waveform = torch.nn.functional.pad(waveform, (0, sr - waveform.shape[-1]))
            else:
                waveform = waveform[:, :sr]

            current_multiplier = 1 if lbl == "noise" else TRAIN_MULTIPLIER
                
            for i in range(TRAIN_MULTIPLIER):
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