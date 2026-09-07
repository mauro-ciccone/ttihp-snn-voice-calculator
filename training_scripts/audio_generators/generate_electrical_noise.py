import os
import torch
import torchaudio
import math

def generate_silence_and_noise(num_samples=900, sample_rate=16000, duration_sec=1.0):
    noise_dir = "custom_audio/noise"
    silence_dir = "custom_audio/silence"
    os.makedirs(noise_dir, exist_ok=True)
    os.makedirs(silence_dir, exist_ok=True)
    length = int(sample_rate * duration_sec)
    time = torch.arange(length).float() / sample_rate
    
    # Any peak below this threshold will barely register on the PDM microphone
    SILENCE_THRESHOLD = 0.005 

    for i in range(num_samples):
        # Rotate evenly through the 3 physical noise profiles
        profile = i % 3
        
        if profile == 0:
            # Profile 1: Thermal White Noise
            amp = torch.empty(1).uniform_(0.0001, 0.02).item()
            waveform = torch.randn(1, length) * amp
            
        elif profile == 1:
            # Profile 2: 50Hz Mains Hum
            amp = torch.empty(1).uniform_(0.001, 0.05).item()
            hum = torch.sin(2 * math.pi * 50.0 * time) * amp
            harmonic = torch.sin(2 * math.pi * 100.0 * time) * (amp * 0.3)
            hiss = torch.randn(length) * (amp * 0.1)
            waveform = (hum + harmonic + hiss).unsqueeze(0)
            
        else:
            # Profile 3: Dead Silicon Silence
            waveform = torch.randn(1, length) * 0.000001

        waveform = torch.clamp(waveform, -1.0, 1.0)

        # --- THE FIX: Dynamic Amplitude Routing ---
        if waveform.abs().max().item() < SILENCE_THRESHOLD:
            current_dir = silence_dir
            prefix = "synthetic_silence"
        else:
            current_dir = noise_dir
            prefix = "synthetic_noise"

        out_path = os.path.join(current_dir, f"{prefix}_{i}.wav")
        torchaudio.save(out_path, waveform, sample_rate)

    print(f"Generated {num_samples} electrical/silence samples across '{noise_dir}' and '{silence_dir}'.")

if __name__ == "__main__":
    generate_silence_and_noise()