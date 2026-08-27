import torch
import torchaudio
import time
import warnings

warnings.filterwarnings(
    "ignore",
    category=UserWarning,
    module="torchaudio._backend.utils",
)

def hardware_sigma_delta(wave_unipolar):
    """
    Literal 1-to-1 physical emulation of the Adafruit PDM microphone.
    This simulates the physical Error Accumulator and DAC feedback loop.
    """
    seq_len = wave_unipolar.shape[0]
    pdm_bits = torch.zeros(seq_len, dtype=torch.float64)
    
    error_accumulator = 0.0
    
    for t in range(seq_len):
        error_accumulator += wave_unipolar[t].item()
        if error_accumulator >= 1.0:
            pdm_bits[t] = 1.0
            error_accumulator -= 1.0
        else:
            pdm_bits[t] = 0.0
            
    return pdm_bits

def vectorized_sigma_delta(wave_unipolar):
    """
    The mathematical shortcut using Cumulative Sum and Floor Derivatives.
    """
    integral = torch.cumsum(wave_unipolar, dim=0)
    pdm_bits = torch.diff(torch.floor(integral), prepend=torch.zeros(1, dtype=torch.float64))
    return pdm_bits

def main():
    print("=== PDM Hardware vs. Vectorized Software Verification ===\n")
    
    # --- LOAD REAL AUDIO ---
    # Point this to any .wav file in your dataset
    WAV_PATH = "custom_audio/vier/vier_11.wav" 
    
    waveform, sr = torchaudio.load(WAV_PATH)
    
    # Standardize to 1 second
    if waveform.shape[-1] < sr:
        waveform = torch.nn.functional.pad(waveform, (0, sr - waveform.shape[-1]))
    else:
        waveform = waveform[:, :sr]
        
    print(f"Loaded: {WAV_PATH}")
    
    # Interpolate to 1 MHz physical clock
    MIC_MHZ = 1000000
    wave_1m = torch.nn.functional.interpolate(waveform.view(1, 1, -1), size=MIC_MHZ, mode='linear', align_corners=False).squeeze()
    
    # Force float64 to prevent accumulation drift in the hardware loop
    wave_1m = wave_1m.to(torch.float64)
    
    # Map to 0.0 - 1.0 physical unipolar voltage
    wave_unipolar = ((wave_1m + 1.0) / 2.0).clamp(0.0, 1.0)
    
    print("Executing literal hardware simulation (1,000,000 physical loop steps)...")
    start_hw = time.time()
    bits_hw = hardware_sigma_delta(wave_unipolar)
    print(f"Hardware Loop Time: {time.time() - start_hw:.4f} seconds\n")
    
    print("Executing vectorized shortcut...")
    start_vec = time.time()
    bits_vec = vectorized_sigma_delta(wave_unipolar)
    print(f"Vectorized Time:    {time.time() - start_vec:.4f} seconds\n")
    
    # --- VERIFICATION ---
    matches = (bits_hw == bits_vec).sum().item()
    total = len(wave_unipolar)
    match_pct = (matches / total) * 100
    
    print("=== VERIFICATION RESULTS ===")
    print(f"Total Bits Generated: {total:,}")
    print(f"Identical Bits:       {matches:,}")
    print(f"Match Accuracy:       {match_pct:.6f}%\n")
    
    if match_pct == 100.0:
        print("RESULT: PERFECT MATCH.")
        print("The vectorized math is mathematically identical to physical silicon, even on real audio.")
    else:
        print("RESULT: MISMATCH DETECTED. DO NOT TAPE OUT.")

if __name__ == "__main__":
    main()