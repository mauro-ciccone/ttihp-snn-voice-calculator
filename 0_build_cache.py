import os
import torch
import torchaudio
import random
from tqdm import tqdm

# --- SILICON HARDWARE CONFIG ---
MIC_MHZ = 1000000        # 1 MHz PDM Microphone
SNN_CLOCK_HZ = 1000      # Running the main SNN at 1 kHz (1000 ticks) saves massive GPU memory for BPTT while preserving speech frequencies.
WINDOW_TICKS = MIC_MHZ // SNN_CLOCK_HZ

# Hardware Channel Tuning (High freq -> Low freq)
# Fast leaks get low thresholds, slow leaks get high thresholds
BETAS = torch.tensor([0.75, 0.80, 0.85, 0.90, 0.95, 0.97, 0.98, 0.99])
THRESHOLDS = torch.tensor([15.0, 20.0, 30.0, 45.0, 60.0, 75.0, 85.0, 95.0])
TRAIN_MULTIPLIER = 10  # Your 10x dataset expansion

def _augment(waveform):
    # Your exact original analog augmentation logic
    shift = random.randint(-800, 800)
    waveform = torch.roll(waveform, shifts=shift, dims=-1)
    
    scale = random.uniform(0.7, 1.3)
    waveform = waveform * scale
    
    noise = torch.randn_like(waveform) * 0.02
    waveform = waveform + noise
    return waveform

def simulate_silicon_cochlea(waveform, device):
    """Perfectly emulates the digital logic of the 8 time-multiplexed LIF neurons and SR Latches."""
    # 1. Digital PDM Generation (1 MHz)
    wave_1m = torch.nn.functional.interpolate(waveform.view(1, 1, -1), size=MIC_MHZ, mode='linear', align_corners=False).squeeze()
    wave_norm = (wave_1m + 1.0) / 2.0
    pdm_bits = torch.bernoulli(wave_norm.clamp(0.0, 1.0)).to(device)
    
    # Bipolar integration: +1 for 1, -1 for 0 (prevents DC silence drift)
    pdm_bipolar = (pdm_bits * 2.0) - 1.0 
    
    # 2. Reshape into SNN Clock Windows
    # Shape: [1000 SNN ticks, 1000 PDM ticks per window]
    pdm_windows = pdm_bipolar.view(SNN_CLOCK_HZ, WINDOW_TICKS)
    
    betas = BETAS.to(device)
    v_ths = THRESHOLDS.to(device)
    mem = torch.zeros(8, device=device)
    
    snn_input_spikes = torch.zeros(SNN_CLOCK_HZ, 8, dtype=torch.float32, device=device)
    
    # 3. The Digital Hardware Loop
    for w in range(SNN_CLOCK_HZ):
        sticky_latches = torch.zeros(8, dtype=torch.bool, device=device)
        
        for t in range(WINDOW_TICKS):
            # ALU: V = V * beta + PDM_In
            mem = (mem * betas) + pdm_windows[w, t]
            
            # Comparator: Did it cross threshold?
            fired = mem >= v_ths
            mem[fired] = 0.0 # Reset
            
            # SR Latch: Set the sticky bit if ANY spike occurred in this window
            sticky_latches = sticky_latches | fired
            
        # At the end of the window, pass the latches to the SNN and clear them
        snn_input_spikes[w, :] = sticky_latches.float()
        
    return snn_input_spikes

def main():
    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    raw_audio_dir = "custom_audio" 
    cache_dir = "data_cache"
    
    labels = [d for d in os.listdir(raw_audio_dir) if not d.startswith(".")]
    
    print("=== Fabricating Augmented Silicon Cache ===")
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
                
            # Generate the 10x variations
            for i in range(TRAIN_MULTIPLIER):
                pt_path = os.path.join(out_dir, f.replace(".wav", f"_aug{i}.pt"))
                if os.path.exists(pt_path):
                    continue
                
                # The first one (i=0) is always the clean, untouched original (for testing)
                if i == 0:
                    aug_wave = waveform
                else:
                    aug_wave = _augment(waveform)
                    
                spikes = simulate_silicon_cochlea(aug_wave, device)
                torch.save(spikes.cpu(), pt_path)

if __name__ == "__main__":
    main()