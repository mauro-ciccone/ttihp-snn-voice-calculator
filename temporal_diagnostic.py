import os
import torch
import torchaudio
import numpy as np
from numba import njit
from build_cache import simulate_silicon_cochlea
from build_cache import THRESHOLDS

import warnings
warnings.filterwarnings("ignore", category=UserWarning)

# --- CONFIGURATION ---
RAW_DATA_DIR = "custom_audio" # Ensure this points to your raw audio folders
NUM_SAMPLES = 25         # Number of audio files to average per class
BIN_SIZE_MS = 50         # 50ms chunks (creates 20 time sectors across 1 sec)
MIC_MHZ = 1000000
SNN_CLOCK_HZ = 1000
WINDOW_TICKS = 1000

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