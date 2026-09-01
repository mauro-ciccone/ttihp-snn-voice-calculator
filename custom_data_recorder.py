import os
import time
import sounddevice as sd
from scipy.io.wavfile import write

# --- Configuration ---
# The 8 Swiss German target words + 1 noise class
custom_set = False
words = ["eis", "drü", "vier", "sächs", "plus", "minus"] if custom_set else ["eis", "zwoi", "drü", "vier", "plus", "minus"]
samples_per_word = 50  # Change this to how many new samples you want to record right now
sample_rate = 16000
duration = 1.0  # 1.0 second per window
base_dir = "./custom_audio"

os.makedirs(base_dir, exist_ok=True)

print("=== SNN Voice Data Collector (Auto-Resume) ===")
print(f"Target: {samples_per_word} new samples per class.")
print("When recording 'noise', include random chatter, TV sounds, typing, or silence.")
time.sleep(2)

for word in words:
    word_dir = os.path.join(base_dir, word)
    os.makedirs(word_dir, exist_ok=True)
    
    print(f"\n==========================================")
    print(f"   RECORDING CLASS: '{word.upper()}'")
    
    # 1. Dynamically calculate the offset to prevent overwriting
    existing_files = [f for f in os.listdir(word_dir) if f.startswith(f"{word}_") and f.endswith(".wav")]
    offset = 0
    for f in existing_files:
        try:
            # Extract the number from "word_12.wav"
            idx_str = f.replace(f"{word}_", "").replace(".wav", "")
            idx = int(idx_str)
            if idx > offset:
                offset = idx
        except ValueError:
            pass # Ignore malformed filenames
            
    print(f"   Found {offset} existing files. Resuming at index {offset + 1}.")
    print(f"==========================================")
    print("Vary your tone, pacing, volume, and distance!")
    time.sleep(1.5)
    
    # 2. Record new samples
    for i in range(samples_per_word):
        current_idx = offset + i + 1
        input(f"[{i+1}/{samples_per_word}] Press ENTER, wait for 'RECORDING...', then speak '{word}' (Saving as {current_idx})...")
        
        print(">>> RECORDING...")
        recording = sd.rec(int(duration * sample_rate), samplerate=sample_rate, channels=1, dtype='int16')
        sd.wait()
        print("Done.")
        
        file_path = os.path.join(word_dir, f"{word}_{current_idx}.wav")
        write(file_path, sample_rate, recording)

print("\nFinished! All new audio safely appended to the './custom_audio/' directory.")