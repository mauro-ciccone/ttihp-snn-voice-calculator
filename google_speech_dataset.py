import os
import torch
import torchaudio
import warnings
from tqdm import tqdm

# Suppress the harmless deprecation warnings
warnings.filterwarnings("ignore")
torchaudio.set_audio_backend("soundfile")

os.makedirs("./data", exist_ok=True)
print("Loading dataset metadata...")
dataset = torchaudio.datasets.SPEECHCOMMANDS(
    root="./data",
    url="speech_commands_v0.02",
    folder_in_archive="SpeechCommands",
    download=True
)

target_words = [
    "zero", "one", "two", "three", "four", 
    "five", "six", "seven", "eight", "nine", 
    "forward", "backward"
]

filtered_dataset = []
print("Filtering down to calculator vocabulary... (This will take 1-3 minutes)")

# The tqdm wrapper adds a live progress bar to the terminal
for i in tqdm(range(len(dataset))):
    waveform, sample_rate, label, speaker_id, utterance_number = dataset[i]
    if label in target_words:
        filtered_dataset.append((waveform, sample_rate, label))

print(f"\nOriginal size: {len(dataset)}")
print(f"Filtered size: {len(filtered_dataset)}")

# Save it to disk so we never have to run this slow loop again
torch.save(filtered_dataset, "./data/calculator_dataset.pt")
print("Saved to ./data/calculator_dataset.pt")