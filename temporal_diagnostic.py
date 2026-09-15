import os
import torch
import torchaudio
import warnings
import numpy as np
from numba import njit

warnings.filterwarnings("ignore", category=UserWarning)

# --- CONFIGURATION ---
RAW_DATA_DIR = "custom_audio" 
NUM_SAMPLES = 50         
BIN_SIZE_MS = 50         
MIC_MHZ = 1000000
SNN_CLOCK_HZ = 1000

# --- NEW 6-CHANNEL OPTIMAL CONFIG ---
BETAS = torch.tensor([0.9375, 0.9531, 0.8281, 0.9844, 0.9844, 0.9688])
THRESHOLDS = torch.tensor([9.5, 11.75, 3.625, 35.0, 34.5, 18.0])

@njit
def run_1mhz_silicon_loop(pdm_bits, v_ths, pdm_adds):
    # Downsized to 6 channels
    spikes_out = np.zeros((1000, 6), dtype=np.float32)
    mem = np.zeros(6, dtype=np.int32)
    next_v = np.zeros(6, dtype=np.int32)
    sticky = np.zeros(6, dtype=np.bool_)
    
    window_idx = 0
    tick_cnt = 0
    
    for t in range(len(pdm_bits)):
        pdm_in = pdm_bits[t]
        
        # 1. Exact Hardware Shift-Subtractors for the NEW 6-Channel Layout
        next_v[0] = mem[0] - (mem[0] >> 4)
        next_v[1] = mem[1] + (mem[1] >> 6) - (mem[1] >> 4)
        next_v[2] = mem[2] + (mem[2] >> 4) + (mem[2] >> 6) - (mem[2] >> 2)
        next_v[3] = mem[3] - (mem[3] >> 6)
        next_v[4] = mem[4] - (mem[4] >> 6)
        next_v[5] = mem[5] - (mem[5] >> 5)
        
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
    wave_1m = torch.nn.functional.interpolate(waveform.view(1, 1, -1), size=MIC_MHZ, mode='linear', align_corners=False).squeeze()
    wave_unipolar = ((wave_1m + 1.0) / 2.0).clamp(0.0, 1.0)
    
    integral = torch.cumsum(wave_unipolar, dim=-1)
    pdm_bits = torch.diff(torch.floor(integral), prepend=torch.zeros(1, device=waveform.device)).to(torch.int32)
    
    # NEW PDM ADDS: Extracted directly from your generated Verilog strings
    pdm_adds = np.array([16, 64, 64, 64, 64, 32], dtype=np.int32)
    v_ths = (THRESHOLDS.numpy() * pdm_adds).astype(np.int32)
    
    spikes_np = run_1mhz_silicon_loop(pdm_bits.cpu().numpy(), v_ths, pdm_adds)
    spikes = torch.from_numpy(spikes_np).to(device)
    
    return spikes

def main():
    device = torch.device("cpu")
    labels = sorted([d for d in os.listdir(RAW_DATA_DIR) if not d.startswith(".")])
    
    print(f"\nBooting 2D Logic Analyzer...")
    print(f"Testing Thresholds: {THRESHOLDS.tolist()}\n")
    
    for lbl in labels:
        lbl_dir = os.path.join(RAW_DATA_DIR, lbl)
        files = [f for f in os.listdir(lbl_dir) if f.endswith(".wav")]
        
        import random
        random.shuffle(files)
        files = files[:NUM_SAMPLES]
        
        all_binned_spikes = []
        
        for f in files:
            wav_path = os.path.join(lbl_dir, f)
            waveform, sr = torchaudio.load(wav_path)
            
            # Safe Mono Mixdown
            if waveform.shape[0] > 1:
                waveform = waveform.mean(dim=0, keepdim=True)
                
            if waveform.shape[-1] < sr:
                waveform = torch.nn.functional.pad(waveform, (0, sr - waveform.shape[-1]))
            else:
                waveform = waveform[:, :sr]
                
            spikes = simulate_silicon_cochlea(waveform, device)
            
            # Reshape for 6 channels
            num_bins = 1000 // BIN_SIZE_MS
            binned = spikes.t().contiguous().view(6, num_bins, BIN_SIZE_MS).sum(dim=2)
            all_binned_spikes.append(binned)
            
        if not all_binned_spikes:
            continue
            
        avg_binned = torch.stack(all_binned_spikes).float().mean(dim=0)
        
        print(f"=== Audio Class: [{lbl.upper()}] (Averaged over {len(files)} samples) ===")
        
        header = "Ch |"
        for i in range(1000 // BIN_SIZE_MS):
            header += f"{i * BIN_SIZE_MS:>4} |"
        header += " TOTAL |"
        print(header)
        print("-" * len(header))
        
        # Loop strictly over 6 channels
        for ch in range(6):
            row_str = f" {ch} |"
            for bin_idx in range(1000 // BIN_SIZE_MS):
                val = int(round(avg_binned[ch, bin_idx].item()))
                if val == 0:
                    row_str += "  .  |" 
                else:
                    row_str += f"{val:^5d}|"
            
            ch_total = int(round(avg_binned[ch].sum().item()))
            row_str += f"{ch_total:^7d}|"
            
            print(row_str)
        print("\n")

if __name__ == "__main__":
    main()