import os
import torch
import torchaudio
import warnings
from tqdm import tqdm

warnings.filterwarnings("ignore")
torchaudio.set_audio_backend("soundfile")

dataset = torchaudio.datasets.SPEECHCOMMANDS(
    root="./data",
    url="speech_commands_v0.02",
    folder_in_archive="SpeechCommands",
    download=True
)

# New 8-word constrained vocabulary
target_words = [
    "one", "two", "three", "four", "five", "six", 
    "left", "right"
]

filtered_dataset = []
print("Filtering down to constrained 8-word vocabulary...")

for i in tqdm(range(len(dataset))):
    waveform, sample_rate, label, speaker_id, utterance_number = dataset[i]
    if label in target_words:
        filtered_dataset.append((waveform, sample_rate, label))

print(f"\nFiltered constrained dataset size: {len(filtered_dataset)}")
torch.save(filtered_dataset, "./data/calculator_dataset_constrained.pt")
print("Saved to ./data/calculator_dataset_constrained.pt")