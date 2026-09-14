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

# --- 8-CHANNEL HARDWARE COCHLEA ALIGNMENT ---
# Ch 0: 0.8125 [V - (V>>2) + (V>>4)]           | Thresh: V >= 16'd3584
# Ch 1: 0.8809 [V - (V>>3) + (V>>7) - (V>>9)]  | Thresh: V >= 16'd5120
# Ch 2: 0.9297 [V - (V>>4) - (V>>7)]           | Thresh: V >= 16'd8192
# Ch 3: 0.9512 [V - (V>>4) + (V>>6) - (V>>9)]  | Thresh: V >= 16'd11264
# Ch 4: 0.9600 [V - (V>>5) - (V>>7) - (V>>10)] | Thresh: V >= 16'd13568
# Ch 5: 0.9746 [V - (V>>5) + (V>>7) - (V>>9)]  | Thresh: V >= 16'd20992
# Ch 6: 0.9766 [V - (V>>5) + (V>>7)]           | Thresh: V >= 16'd22784
# Ch 7: 0.9912 [V - (V>>7) - (V>>10)]          | Thresh: V >= 16'd59392

BETAS = torch.tensor([0.8125, 0.8809, 0.9297, 0.9512, 0.9600, 0.9746, 0.9766, 0.9912])
THRESHOLDS = torch.tensor([3.5, 5.00, 8.00, 11.00, 13.25, 20.50, 22.25, 58.00])
TRAIN_MULTIPLIER = 10  

def _augment(waveform):
    shift = random.randint(-800, 800)
    waveform = torch.roll(waveform, shifts=shift, dims=-1)
    scale = random.uniform(0.9, 1.1)
    waveform = waveform * scale
    return waveform

@torch.jit.script
def run_1mhz_silicon_loop(pdm_bits: torch.Tensor, v_ths: torch.Tensor, pdm_adds: torch.Tensor) -> torch.Tensor:
    # Pre-allocate the SNN input tensor [1000 ms, 8 channels]
    spikes_out = torch.zeros((1000, 8), dtype=torch.float32)
    
    # Initialize physical registers
    mem = torch.zeros(8, dtype=torch.int32)
    sticky = torch.zeros(8, dtype=torch.bool)
    
    window_idx = 0
    tick_cnt = 0
    
    # The true 1 MHz hardware clock loop (Compiled to C++ for instant execution)
    for t in range(pdm_bits.size(0)):
        pdm_in = pdm_bits[t].to(torch.int32)
        pdm_val = pdm_in * pdm_adds
        
        # 1. Hardware Shift-Subtractors
        next_v = torch.zeros(8, dtype=torch.int32)
        next_v[0] = mem[0] - (mem[0] >> 2) + (mem[0] >> 4)
        next_v[1] = mem[1] - (mem[1] >> 3) + (mem[1] >> 7) - (mem[1] >> 9)
        next_v[2] = mem[2] - (mem[2] >> 4) - (mem[2] >> 7)
        next_v[3] = mem[3] - (mem[3] >> 4) + (mem[3] >> 6) - (mem[3] >> 9)
        next_v[4] = mem[4] - (mem[4] >> 5) - (mem[4] >> 7) - (mem[4] >> 10)
        next_v[5] = mem[5] - (mem[5] >> 5) + (mem[5] >> 7) - (mem[5] >> 9)
        next_v[6] = mem[6] - (mem[6] >> 5) + (mem[6] >> 7)
        next_v[7] = mem[7] - (mem[7] >> 7) - (mem[7] >> 10)
        
        # 2. Integration & Thresholding
        mem = next_v + pdm_val
        fired = mem >= v_ths
        
        # 3. Hardware Latch & Reset
        mem = torch.where(fired, torch.zeros_like(mem), mem)
        sticky = sticky | fired
        
        # 4. 1ms Window Framing
        tick_cnt += 1
        if tick_cnt == 1000:
            spikes_out[window_idx] = sticky.to(torch.float32)
            sticky = torch.zeros(8, dtype=torch.bool)
            tick_cnt = 0
            window_idx += 1
            
    return spikes_out


def simulate_silicon_cochlea(waveform, device):
    # Interpolate to physical clock speed (1 MHz)
    wave_1m = torch.nn.functional.interpolate(waveform.view(1, 1, -1), size=MIC_MHZ, mode='linear', align_corners=False).squeeze()
    
    # Map raw AC audio (-1.0 to 1.0) to physical unipolar voltages (0.0 to 1.0)
    wave_unipolar = ((wave_1m + 1.0) / 2.0).clamp(0.0, 1.0)
    
    # True Sigma-Delta Modulator
    integral = torch.cumsum(wave_unipolar, dim=-1)
    pdm_bits = torch.diff(torch.floor(integral), prepend=torch.zeros(1, device=waveform.device))
    
    # Integer Thresholds & PDM Additions (Locked to cochlea.v)
    v_ths = torch.tensor([56, 2560, 1024, 5632, 13568, 10496, 2848, 59392], dtype=torch.int32, device=device)
    pdm_adds = torch.tensor([16, 512, 128, 512, 1024, 512, 128, 1024], dtype=torch.int32, device=device)
    
    # Execute the compiled 1,000,000 tick simulation
    spikes = run_1mhz_silicon_loop(pdm_bits.to(device), v_ths, pdm_adds)
    
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