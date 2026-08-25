import os
import torchaudio

def slice_background_noise(input_dir, output_dir, chunk_duration_sec=1.0):
    # Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)

    processed_count = 0

    for filename in os.listdir(input_dir):
        if not filename.endswith(".wav"):
            continue

        filepath = os.path.join(input_dir, filename)
        waveform, sample_rate = torchaudio.load(filepath)

        # Calculate exact frame count for 1 second of audio
        chunk_size = int(sample_rate * chunk_duration_sec)
        total_frames = waveform.shape[1]

        chunk_idx = 0
        # Slide through the audio, stepping exactly 1 second at a time
        for start_frame in range(0, total_frames - chunk_size + 1, chunk_size):
            chunk = waveform[:, start_frame : start_frame + chunk_size]
            
            # Format: originalname_chunk0.wav
            out_name = f"{filename.split('.')[0]}_chunk{chunk_idx}.wav"
            out_path = os.path.join(output_dir, out_name)
            
            torchaudio.save(out_path, chunk, sample_rate)
            chunk_idx += 1
            processed_count += 1
            
    print(f"Done. Generated {processed_count} discrete 1-second noise chunks in '{output_dir}'.")

if __name__ == "__main__":
    # Point this to wherever you unzipped the long background files
    RAW_NOISE_FOLDER = "raw_background_noise"
    
    # Point this to your actual dataset's noise folder
    TARGET_NOISE_FOLDER = "custom_audio/noise"
    
    slice_background_noise(RAW_NOISE_FOLDER, TARGET_NOISE_FOLDER)