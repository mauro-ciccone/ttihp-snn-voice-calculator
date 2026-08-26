import torch
import torchaudio
import matplotlib.pyplot as plt
import importlib
train_module = importlib.import_module("1_train")

# 1. Load one clean keyword file
waveform, sample_rate = torchaudio.load("custom_audio/foif/foif_1.wav") 
waveform = waveform.view(1, -1) # Batch of 1

# 2. Run your PDM simulation
pdm_bits = train_module.simulate_pdm_cochlea_batched(waveform) # Shape: [1, 500, 8]

# 3. Plot it to see if there is visual structure, or if it's just static
plt.figure(figsize=(10, 4))
plt.imshow(pdm_bits[0].cpu().numpy().T, aspect='auto', cmap='hot')
plt.title("PDM Spike Stream (Is there a pattern?)")
plt.ylabel("Cochlea Channels")
plt.xlabel("Timesteps")
plt.show()