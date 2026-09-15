import os
import torch
import torchaudio
import numpy as np
from numba import njit
from tqdm import tqdm
import warnings

warnings.filterwarnings("ignore", category=UserWarning)

# --- HARDWARE DICTIONARIES ---
VALID_BETAS = np.array([
    0.0156, 0.0312, 0.0469, 0.0625, 0.0781, 0.0938, 0.1094, 
    0.1250, 0.1406, 0.1562, 0.1719, 0.1875, 0.2031, 0.2188, 0.2344, 
    0.2500, 0.2656, 0.2812, 0.2969, 0.3125, 0.3281, 0.3438, 0.3594, 
    0.3750, 0.3906, 0.4062, 0.4219, 0.4375, 0.4531, 0.4688, 0.4844, 
    0.5000, 0.5156, 0.5312, 0.5469, 0.5625, 0.5781, 0.5938, 0.6094, 
    0.6250, 0.6406, 0.6562, 0.6719, 0.6875, 0.7031, 0.7188, 0.7344, 
    0.7500, 0.7656, 0.7812, 0.7969, 0.8125, 0.8281, 0.8438, 0.8594, 
    0.8750, 0.8906, 0.9062, 0.9219, 0.9375, 0.9531, 0.9688, 0.9844, 1.0000
])

FRAC_BITS = np.array([
    0, 6, 5, 6, 4, 6, 5, 6, 3, 6, 5, 6, 4, 6, 5, 6, 
    2, 6, 5, 6, 4, 6, 5, 6, 3, 6, 5, 6, 4, 6, 5, 6, 
    1, 6, 5, 6, 4, 6, 5, 6, 3, 6, 5, 6, 4, 6, 5, 6, 
    2, 6, 5, 6, 4, 6, 5, 6, 3, 6, 5, 6, 4, 6, 5, 6, 0
], dtype=np.int32)

# Sweep matrix: Exploring multiple sensitivity levels
# High-Resolution Sweep Matrix (~200 sensitivity levels)
# 0.125 steps up to 10, 0.25 steps up to 20, 0.5 steps up to 60
THRESH_MULTIPLIERS = np.concatenate([
    np.arange(0.125, 10.0, 0.0625),
    np.arange(10.0, 15.0, 0.125),
    np.arange(15.0, 25.0, 0.25),
    np.arange(25.0, 60.0, 1.0)
])

def build_shift_tables():
    """ Reverse-engineers the exact hardware shifts to maintain 100% truncation accuracy """
    shifts = np.zeros((64, 4), dtype=np.int32)
    signs = np.zeros((64, 4), dtype=np.int32)
    verilog_strs = []
    
    for i, beta in enumerate(VALID_BETAS):
        target_val = int(round(beta * 64))
        best_diff = 999
        best_ops = []
        
        # Brute force up to 4 CSD terms (V +/- V>>1 +/- ...) to match the beta exactly
        for s1 in [1]: 
            for sh1 in [0]:
                for s2 in [0, 1, -1]:
                    for sh2 in range(1, 7):
                        for s3 in [0, 1, -1]:
                            for sh3 in range(1, 7):
                                for s4 in [0, 1, -1]:
                                    for sh4 in range(1, 7):
                                        val = (64 >> sh1)*s1
                                        if s2 != 0: val += (64 >> sh2)*s2
                                        if s3 != 0: val += (64 >> sh3)*s3
                                        if s4 != 0: val += (64 >> sh4)*s4
                                        
                                        if val == target_val:
                                            ops = [(s1, sh1)]
                                            if s2 != 0: ops.append((s2, sh2))
                                            if s3 != 0: ops.append((s3, sh3))
                                            if s4 != 0: ops.append((s4, sh4))
                                            
                                            # Prefer minimal ALUs
                                            if len(ops) < best_diff:
                                                best_diff = len(ops)
                                                best_ops = ops
                                                
        # Populate Numba lookup tables
        v_str = "mem"
        for idx, (s, sh) in enumerate(best_ops):
            shifts[i, idx] = sh
            signs[i, idx] = s
            if idx > 0:
                op = "+" if s == 1 else "-"
                v_str += f" {op} (mem >> {sh})"
        verilog_strs.append(v_str if target_val > 0 else "0")
        
    return shifts, signs, verilog_strs

# The core Numba engine (Simulates 1 neuron perfectly mimicking hardware truncation)
@njit
def sim_neuron(pdm_bits, shift_arr, sign_arr, pdm_add, v_th):
    spikes = np.zeros(1000, dtype=np.float32)
    mem = 0
    tick_cnt = 0
    window_idx = 0
    sticky = False
    
    for t in range(len(pdm_bits)):
        # 1. Hardware Shifts
        next_v = 0
        for i in range(4):
            if sign_arr[i] == 1:
                next_v += (mem >> shift_arr[i])
            elif sign_arr[i] == -1:
                next_v -= (mem >> shift_arr[i])
                
        # 2. Integrate & Threshold
        mem = next_v + (pdm_bits[t] * pdm_add)
        if mem >= v_th:
            mem = 0
            sticky = True
            
        # 3. 1ms Framing
        tick_cnt += 1
        if tick_cnt == 1000:
            if window_idx < 1000:
                if sticky: spikes[window_idx] = 1.0
                sticky = False
            tick_cnt = 0
            window_idx += 1
            
    return spikes

def extract_audio_pdms(audio_dir, samples_per_class=10):
    """ Loads real audio and converts to 1MHz PDM exactly once """
    classes = [d for d in os.listdir(audio_dir) if not d.startswith(".")]
    dataset = []
    
    print("Loading Audio & Generating PDM Physics...")
    for lbl in classes:
        files = [f for f in os.listdir(os.path.join(audio_dir, lbl)) if f.endswith(".wav")]
        np.random.shuffle(files)
        
        for f in files[:samples_per_class]:
            wav_path = os.path.join(audio_dir, lbl, f)
            waveform, sr = torchaudio.load(wav_path)
            
            # Safe Mono Mixdown
            if waveform.shape[0] > 1: waveform = waveform.mean(dim=0, keepdim=True)
            if waveform.shape[-1] < sr: waveform = torch.nn.functional.pad(waveform, (0, sr - waveform.shape[-1]))
            else: waveform = waveform[:, :sr]
                
            wave_1m = torch.nn.functional.interpolate(waveform.view(1, 1, -1), size=1000000, mode='linear').squeeze()
            wave_unipolar = ((wave_1m + 1.0) / 2.0).clamp(0.0, 1.0)
            
            integral = torch.cumsum(wave_unipolar, dim=-1)
            pdm_bits = torch.diff(torch.floor(integral), prepend=torch.zeros(1)).numpy().astype(np.int32)
            dataset.append((lbl, pdm_bits))
            
    return dataset, classes

def main():
    shifts, signs, v_strs = build_shift_tables()
    dataset, classes = extract_audio_pdms("custom_audio")
    
    # Feature vectors: [Neuron ID] -> [Spike Rates per Class]
    candidate_features = []
    candidate_meta = []
    
    print("\nSimulating Hardware Candidate Space...")
    for b_idx in tqdm(range(64), desc="Betas"):
        pdm_add = int(1 << FRAC_BITS[b_idx])
        
        for t_mult in THRESH_MULTIPLIERS:
            v_th = int(t_mult * pdm_add)
            if v_th == 0: continue
            
            # Accumulate temporal footprint across classes
            class_footprints = {c: [] for c in classes}
            for lbl, pdm in dataset:
                spikes = sim_neuron(pdm, shifts[b_idx], signs[b_idx], pdm_add, v_th)
                # Compress 1000ms into 20 bins of 50ms for the feature vector
                binned = spikes.reshape((20, 50)).sum(axis=1)
                class_footprints[lbl].append(binned)
                
            # Average samples and flatten into a single feature vector
            feature_vec = []
            for c in classes:
                feature_vec.extend(np.mean(class_footprints[c], axis=0))
            feature_vec = np.array(feature_vec)
            
            # Filter dead neurons or hyperactive noise generators
            total_spikes = feature_vec.sum()
            if 10 < total_spikes < 4000:
                candidate_features.append(feature_vec)
                candidate_meta.append((b_idx, VALID_BETAS[b_idx], t_mult, v_th, pdm_add, v_strs[b_idx]))

    candidate_features = np.array(candidate_features)
    
    print(f"\nFound {len(candidate_features)} viable acoustic feature extractors.")
    print("Executing Max-Min Orthogonal Diversity Search for best 6 channels...")
    
    selected_indices = []
    
    # 1. Pick the neuron with the highest variance (most descriptive single channel)
    variances = np.var(candidate_features, axis=1)
    selected_indices.append(np.argmax(variances))
    
    # 2. Iteratively pick the neuron furthest away from all currently selected neurons
    for _ in range(5):
        max_min_dist = -1
        best_candidate = -1
        
        for i in range(len(candidate_features)):
            if i in selected_indices: continue
            
            # Find distance to closest selected neuron
            min_dist_to_selected = 999999
            for sel_idx in selected_indices:
                dist = np.linalg.norm(candidate_features[i] - candidate_features[sel_idx])
                if dist < min_dist_to_selected:
                    min_dist_to_selected = dist
                    
            if min_dist_to_selected > max_min_dist:
                max_min_dist = min_dist_to_selected
                best_candidate = i
                
        selected_indices.append(best_candidate)
        
    print("\n=======================================================")
    print("      🏆 OPTIMAL 6-CHANNEL COCHLEA GENERATED 🏆")
    print("=======================================================\n")
    
    final_betas = []
    final_thresh = []
    
    for ch, idx in enumerate(selected_indices):
        b_idx, beta_val, t_mult, v_th, pdm_add, v_str = candidate_meta[idx]
        final_betas.append(beta_val)
        final_thresh.append(t_mult)
        
        reg_size = int(np.ceil(np.log2(v_th + 1)))
        
        print(f"// --- Channel {ch} ---")
        print(f"// Beta: {beta_val:.4f} | Thresh Mult: {t_mult} | Reg Size: {reg_size}-bit (Frac: {FRAC_BITS[b_idx]})")
        print(f"wire [{reg_size-1}:0] next_v_{ch} = {v_str.replace('mem', f'mem_{ch}')} + (pdm_in ? {reg_size}'d{pdm_add} : {reg_size}'d0);")
        print(f"wire fired_{ch} = (next_v_{ch} >= {reg_size}'d{v_th});\n")
        
    print("=== Update PyTorch Config ===")
    print(f"BETAS = torch.tensor([{', '.join(f'{b:.4f}' for b in final_betas)}])")
    print(f"THRESHOLDS = torch.tensor([{', '.join(str(t) for t in final_thresh)}])")

if __name__ == "__main__":
    main()