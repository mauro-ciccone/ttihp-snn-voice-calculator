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

# Hardware Channel Tuning (High freq -> Low freq)
BETAS = torch.tensor([0.75, 0.80, 0.85, 0.90, 0.95, 0.97, 0.98, 0.99])

# Tuned to ~65% of the raw, unnormalized PDM voltage ceilings
THRESHOLDS = torch.tensor([3.95, 4.85, 6.20, 7.5, 9.0, 12.5, 16.0, 23.0])
TRAIN_MULTIPLIER = 10  

def diagnostic_cochlea(waveform, device):
    # NO NORMALIZATION. Raw audio only.
    wave_1m = torch.nn.functional.interpolate(waveform.view(1, 1, -1), size=MIC_MHZ, mode='linear', align_corners=False).squeeze()
    wave_norm = (wave_1m + 1.0) / 2.0
    pdm_bits = torch.bernoulli(wave_norm.clamp(0.0, 1.0)).to(device)
    pdm_bipolar = (pdm_bits * 2.0) - 1.0 
    
    pdm_windows = pdm_bipolar.view(SNN_CLOCK_HZ, WINDOW_TICKS).unsqueeze(-1)
    
    betas = BETAS.to(device).view(1, 8)
    mem = torch.zeros(SNN_CLOCK_HZ, 8, device=device)
    
    max_voltages = torch.zeros(8, device=device)
    
    for t in range(WINDOW_TICKS):
        mem = (mem * betas) + pdm_windows[:, t, :]
        # Track the highest voltage ever reached by each channel across the whole file
        current_max, _ = mem.max(dim=0)
        max_voltages = torch.maximum(max_voltages, current_max)
        
    print(f"Max achieved voltages per channel: {max_voltages}")
    return max_voltages

def _augment(waveform):
    shift = random.randint(-800, 800)
    waveform = torch.roll(waveform, shifts=shift, dims=-1)
    scale = random.uniform(0.7, 1.3)
    waveform = waveform * scale
    noise = torch.randn_like(waveform) * 0.02
    waveform = waveform + noise
    return waveform

def simulate_silicon_cochlea(waveform, device):
    """Perfectly emulates the hardware using extreme PyTorch vectorization."""
    # 1. Digital PDM Generation (1 MHz)
    wave_1m = torch.nn.functional.interpolate(waveform.view(1, 1, -1), size=MIC_MHZ, mode='linear', align_corners=False).squeeze()
    wave_norm = (wave_1m + 1.0) / 2.0
    pdm_bits = torch.bernoulli(wave_norm.clamp(0.0, 1.0)).to(device)
    
    # Bipolar integration: +1 for 1, -1 for 0
    pdm_bipolar = (pdm_bits * 2.0) - 1.0 
    
    # 2. Reshape into SNN Clock Windows
    # Shape: [1000 windows, 1000 ticks_per_window, 1] 
    # We add a dummy channel dimension so it broadcasts across our 8 beta channels
    pdm_windows = pdm_bipolar.view(SNN_CLOCK_HZ, WINDOW_TICKS).unsqueeze(-1)
    
    betas = BETAS.to(device).view(1, 8)
    v_ths = THRESHOLDS.to(device).view(1, 8)
    
    # mem shape: [1000 windows, 8 channels]
    # By stacking the windows, we simulate all 1000 milliseconds simultaneously!
    mem = torch.zeros(SNN_CLOCK_HZ, 8, device=device)
    sticky_latches = torch.zeros(SNN_CLOCK_HZ, 8, dtype=torch.bool, device=device)
    
    # 3. The Vectorized Loop (Only runs 1,000 times instead of 1,000,000)
    for t in range(WINDOW_TICKS):
        # ALU: V = V * beta + PDM_In
        mem = (mem * betas) + pdm_windows[:, t, :]
        
        # Comparator
        fired = mem >= v_ths
        mem[fired] = 0.0 
        
        # SR Latch
        sticky_latches = sticky_latches | fired
        
    return sticky_latches.float()

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

    """wav_path = "custom_audio/eis/eis_5.wav"
    waveform, sr = torchaudio.load(wav_path)
    diagnostic_cochlea(waveform, "cpu")
    wav_path = "custom_audio/zwoi/zwoi_5.wav"
    waveform, sr = torchaudio.load(wav_path)
    diagnostic_cochlea(waveform, "cpu")
    wav_path = "custom_audio/drü/drü_5.wav"
    waveform, sr = torchaudio.load(wav_path)
    diagnostic_cochlea(waveform, "cpu")
    wav_path = "custom_audio/vier/vier_5.wav"
    waveform, sr = torchaudio.load(wav_path)
    diagnostic_cochlea(waveform, "cpu")
    wav_path = "custom_audio/foif/foif_5.wav"
    waveform, sr = torchaudio.load(wav_path)
    diagnostic_cochlea(waveform, "cpu")
    wav_path = "custom_audio/sächs/sächs_5.wav"
    waveform, sr = torchaudio.load(wav_path)
    diagnostic_cochlea(waveform, "cpu")
    wav_path = "custom_audio/plus/plus_5.wav"
    waveform, sr = torchaudio.load(wav_path)
    diagnostic_cochlea(waveform, "cpu")
    wav_path = "custom_audio/minus/minus_5.wav"
    waveform, sr = torchaudio.load(wav_path)
    diagnostic_cochlea(waveform, "cpu")
    wav_path = "custom_audio/noise/noise_54.wav"
    waveform, sr = torchaudio.load(wav_path)
    diagnostic_cochlea(waveform, "cpu") """