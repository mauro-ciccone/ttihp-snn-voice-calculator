import os
import torch
import torchaudio
#from build_cache import simulate_silicon_cochlea

import warnings
warnings.filterwarnings("ignore", category=UserWarning)

# --- CONFIGURATION ---
RAW_DATA_DIR = "custom_audio" # Ensure this points to your raw audio folders
NUM_SAMPLES = 25         # Number of audio files to average per class
BIN_SIZE_MS = 50         # 50ms chunks (creates 20 time sectors across 1 sec)
MIC_MHZ = 1000000
SNN_CLOCK_HZ = 1000
WINDOW_TICKS = 1000

# --- TWEAK THESE HERE TO TEST NEW HARDWARE LIMITS ---
BETAS = torch.tensor([0.75, 0.80, 0.85, 0.90, 0.95, 0.97, 0.98, 0.99])
THRESHOLDS = torch.tensor([2.72, 3.235, 4.085, 5.737, 10.75, 17.45, 25.95, 51.15])
#THRESHOLDS = torch.tensor([2.72, 3.235, 4.085, 5.737, 10.75, 17.5, 25.95, 51.15])

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
    
    betas = BETAS.to(device).view(1, 8)
    v_ths = THRESHOLDS.to(device).view(1, 8)
    
    mem = torch.zeros(SNN_CLOCK_HZ, 8, device=device)
    sticky_latches = torch.zeros(SNN_CLOCK_HZ, 8, dtype=torch.bool, device=device)
    
    # Hardware Integrator Array (The Silicon)[cite: 1]
    for t in range(WINDOW_TICKS):
        mem = (mem * betas) + pdm_windows[:, t, :]
        fired = mem >= v_ths
        mem[fired] = 0.0
        sticky_latches = sticky_latches | fired
        
    return sticky_latches.float()

def main():
    device = torch.device("cpu")
    
    # Grab all classes (including noise)
    labels = sorted([d for d in os.listdir(RAW_DATA_DIR) if not d.startswith(".")])
    
    print(f"\nBooting 2D Logic Analyzer...")
    print(f"Testing Thresholds: {THRESHOLDS.tolist()}\n")
    
    for lbl in labels:
        lbl_dir = os.path.join(RAW_DATA_DIR, lbl)
        files = [f for f in os.listdir(lbl_dir) if f.endswith(".wav")]
        
        # Shuffle to get a random mix, then take NUM_SAMPLES
        import random
        random.shuffle(files)
        files = files[:NUM_SAMPLES]
        
        all_binned_spikes = []
        
        for f in files:
            wav_path = os.path.join(lbl_dir, f)
            waveform, sr = torchaudio.load(wav_path)
            
            # Standardize to exactly 1 second (same as cache builder)
            if waveform.shape[-1] < sr:
                waveform = torch.nn.functional.pad(waveform, (0, sr - waveform.shape[-1]))
            else:
                waveform = waveform[:, :sr]
                
            # Run the physics simulation
            spikes = simulate_silicon_cochlea(waveform, device)
            
            # --- THE FIX: Transpose BEFORE viewing to keep channels intact ---
            num_bins = 1000 // BIN_SIZE_MS
            binned = spikes.t().contiguous().view(8, num_bins, BIN_SIZE_MS).sum(dim=2)
            all_binned_spikes.append(binned)
            
        if not all_binned_spikes:
            continue
            
        # Average the binned temporal footprints across the samples
        avg_binned = torch.stack(all_binned_spikes).float().mean(dim=0)
        
        # --- RENDER THE LOGIC ANALYZER ASCII UI ---
        print(f"=== Audio Class: [{lbl.upper()}] (Averaged over {len(files)} samples) ===")
        
        # Table Header (Time Sectors + Total)
        header = "Ch |"
        for i in range(1000 // BIN_SIZE_MS):
            header += f"{i * BIN_SIZE_MS:>4} |"
        header += " TOTAL |"
        print(header)
        print("-" * len(header))
        
        # Print each channel row
        for ch in range(8):
            row_str = f" {ch} |"
            for bin_idx in range(1000 // BIN_SIZE_MS):
                val = int(round(avg_binned[ch, bin_idx].item()))
                if val == 0:
                    row_str += "  .  |" # Visually silence dead zones
                else:
                    row_str += f"{val:^5d}|"
            
            # Append the total sum for this channel at the end
            ch_total = int(round(avg_binned[ch].sum().item()))
            row_str += f"{ch_total:^7d}|"
            
            print(row_str)
        print("\n")

if __name__ == "__main__":
    main()