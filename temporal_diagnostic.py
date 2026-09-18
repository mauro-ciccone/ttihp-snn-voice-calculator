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

"""

=======================================================
      🏆 OPTIMAL 6-CHANNEL COCHLEA GENERATED 🏆
=======================================================

// --- Channel 0 ---
// Beta: 0.9688 | Thresh Mult: 17.25 | Reg Size: 10-bit (Frac: 5)
// Fisher Discriminant Ratio (Information): 0.49
wire [9:0] next_v_0 = mem_0 - (mem_0 >> 5) + (pdm_in ? 10'd32 : 10'd0);
wire fired_0 = (next_v_0 >= 10'd552);

// --- Channel 1 ---
// Beta: 0.9531 | Thresh Mult: 11.75 | Reg Size: 10-bit (Frac: 6)
// Fisher Discriminant Ratio (Information): 0.15
wire [9:0] next_v_1 = mem_1 + (mem_1 >> 6) - (mem_1 >> 4) + (pdm_in ? 10'd64 : 10'd0);
wire fired_1 = (next_v_1 >= 10'd752);

// --- Channel 2 ---
// Beta: 0.9844 | Thresh Mult: 33.5 | Reg Size: 12-bit (Frac: 6)
// Fisher Discriminant Ratio (Information): 0.35
wire [11:0] next_v_2 = mem_2 - (mem_2 >> 6) + (pdm_in ? 12'd64 : 12'd0);
wire fired_2 = (next_v_2 >= 12'd2144);

// --- Channel 3 ---
// Beta: 0.9688 | Thresh Mult: 16.75 | Reg Size: 10-bit (Frac: 5)
// Fisher Discriminant Ratio (Information): 0.19
wire [9:0] next_v_3 = mem_3 - (mem_3 >> 5) + (pdm_in ? 10'd32 : 10'd0);
wire fired_3 = (next_v_3 >= 10'd536);

// --- Channel 4 ---
// Beta: 0.9688 | Thresh Mult: 17.5 | Reg Size: 10-bit (Frac: 5)
// Fisher Discriminant Ratio (Information): 0.22
wire [9:0] next_v_4 = mem_4 - (mem_4 >> 5) + (pdm_in ? 10'd32 : 10'd0);
wire fired_4 = (next_v_4 >= 10'd560);

// --- Channel 5 ---
// Beta: 0.0625 | Thresh Mult: 1.125 | Reg Size: 5-bit (Frac: 4)
// Fisher Discriminant Ratio (Information): 0.25
wire [4:0] next_v_5 = mem_5 + (mem_5 >> 4) - (mem_5 >> 1) - (mem_5 >> 1) + (pdm_in ? 5'd16 : 5'd0);
wire fired_5 = (next_v_5 >= 5'd18);

=== Update PyTorch Config ===
BETAS = torch.tensor([0.9688, 0.9531, 0.9844, 0.9688, 0.9688, 0.0625])
THRESHOLDS = torch.tensor([17.25, 11.75, 33.5, 16.75, 17.5, 1.125])

"""


# --- NEW 6-CHANNEL OPTIMAL CONFIG ---
BETAS = torch.tensor([0.9688, 0.9531, 0.9844, 0.9688, 0.9688, 0.0625])
THRESHOLDS = torch.tensor([17.25, 11.75, 33.5, 16.75, 17.5, 1.125])

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
    wave_1m = torch.nn.functional.interpolate(waveform.view(1, 1, -1), size=MIC_MHZ, mode='linear', align_corners=False).squeeze()
    wave_unipolar = ((wave_1m + 1.0) / 2.0).clamp(0.0, 1.0)
    
    integral = torch.cumsum(wave_unipolar, dim=-1)
    pdm_bits = torch.diff(torch.floor(integral), prepend=torch.zeros(1, device=waveform.device)).to(torch.int32)
    
    # NEW PDM ADDS: Extracted directly from your generated Verilog strings
    pdm_adds = np.array([32, 64, 64, 32, 32, 16], dtype=np.int32)
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