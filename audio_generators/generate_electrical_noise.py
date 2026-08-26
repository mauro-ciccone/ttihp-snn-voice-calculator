import os
import torch
import torchaudio
import math

def generate_silence_and_noise(output_dir, num_samples=400, sample_rate=16000, duration_sec=1.0):
    os.makedirs(output_dir, exist_ok=True)
    length = int(sample_rate * duration_sec)
    time = torch.arange(length).float() / sample_rate

    for i in range(num_samples):
        # Rotate evenly through the 3 physical noise profiles
        profile = i % 3
        
        if profile == 0:
            # Profile 1: Thermal White Noise (Random baseline hiss)
            # Amplitude varies wildly between files to simulate different gain levels
            amp = torch.empty(1).uniform_(0.0001, 0.02).item()
            waveform = torch.randn(1, length) * amp
            
        elif profile == 1:
            # Profile 2: 50Hz Mains Hum (Electromagnetic interference)
            amp = torch.empty(1).uniform_(0.001, 0.05).item()
            hum = torch.sin(2 * math.pi * 50.0 * time) * amp
            harmonic = torch.sin(2 * math.pi * 100.0 * time) * (amp * 0.3)
            hiss = torch.randn(length) * (amp * 0.1)
            waveform = (hum + harmonic + hiss).unsqueeze(0)
            
        else:
            # Profile 3: Dead Silicon Silence (Near absolute zero)
            waveform = torch.randn(1, length) * 0.000001

        # Safely clamp to standard audio rails just in case
        waveform = torch.clamp(waveform, -1.0, 1.0)
        
        out_path = os.path.join(output_dir, f"synthetic_noise_{i}.wav")
        torchaudio.save(out_path, waveform, sample_rate)

    print(f"Generated {num_samples} electrical/silence noise samples in '{output_dir}'.")

if __name__ == "__main__":
    TARGET_NOISE_FOLDER = "custom_audio/noise"
    generate_silence_and_noise(TARGET_NOISE_FOLDER)