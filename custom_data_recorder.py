import os
import time
import sounddevice as sd
from scipy.io.wavfile import write

# 8 target words + 1 negative rejection class
#words = ["eis", "zwoi", "drü", "vier", "foif", "sächs", "plus", "minus", "noise"]
words = ["zwoi", "foif", "plus", "minus", "noise"]   #select datasize improving
samples_per_word = 50
sample_rate = 16000
duration = 1.0  # 1.0 second per window

base_dir = "./custom_audio"
os.makedirs(base_dir, exist_ok=True)

print("=== SNN Voice Data Collector (v2 - with Rejection Class) ===")
print(f"Target: {samples_per_word} samples per class across {len(words)} classes.")
print("When recording 'unknown', include random words ('hello', 'test'), room noise, or coughs.")
time.sleep(2)

for word in words:
    word_dir = os.path.join(base_dir, word)
    os.makedirs(word_dir, exist_ok=True)
    
    print(f"\n==========================================")
    print(f"   RECORDING CLASS: '{word.upper()}'")
    print(f"==========================================")
    print("Vary your tone, pacing, volume, and distance!")
    time.sleep(1.5)
    
    for i in range(samples_per_word):
        input(f"[{i+1}/{samples_per_word}] Press ENTER, wait for 'RECORDING...', then speak '{word}'...")

        print(">>> RECORDING...")
        recording = sd.rec(int(duration * sample_rate), samplerate=sample_rate, channels=1, dtype='int16')
        sd.wait()
        print("Done.")
        
        file_path = os.path.join(word_dir, f"{word}_{i+51}.wav")    #offset must be the current data count + 1
        write(file_path, sample_rate, recording)

print("\nFinished. Dataset saved in './custom_audio/'.")