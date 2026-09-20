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
    0.0000, 0.0156, 0.0312, 0.0469, 0.0625, 0.0781, 0.0938, 0.1094, 
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

# High-Resolution Sweep Matrix (~200 sensitivity levels)
THRESH_MULTIPLIERS = np.concatenate([
    np.arange(0.125, 10.0, 0.125),
    np.arange(10.0, 20.0, 0.25),
    np.arange(20.0, 60.5, 0.5)
])

def build_shift_tables():
    num_betas = len(VALID_BETAS)
    shifts = np.zeros((num_betas, 4), dtype=np.int32)
    signs = np.zeros((num_betas, 4), dtype=np.int32)
    verilog_strs = []
    
    for i, beta in enumerate(VALID_BETAS):
        target_val = int(round(beta * 64))
        best_diff = 999
        best_ops = []
        
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
                                            
                                            if len(ops) < best_diff:
                                                best_diff = len(ops)
                                                best_ops = ops
                                                
        v_str = "mem"
        for idx, (s, sh) in enumerate(best_ops):
            shifts[i, idx] = sh
            signs[i, idx] = s
            if idx > 0:
                op = "+" if s == 1 else "-"
                v_str += f" {op} (mem >> {sh})"
        verilog_strs.append(v_str if target_val > 0 else "0")
        
    return shifts, signs, verilog_strs

@njit
def sim_neuron(pdm_bits, shift_arr, sign_arr, pdm_add, v_th):
    spikes = np.zeros(1000, dtype=np.float32)
    mem = 0
    tick_cnt = 0
    window_idx = 0
    sticky = False
    
    for t in range(len(pdm_bits)):
        next_v = 0
        for i in range(4):
            if sign_arr[i] == 1: next_v += (mem >> shift_arr[i])
            elif sign_arr[i] == -1: next_v -= (mem >> shift_arr[i])
                
        mem = next_v + (pdm_bits[t] * pdm_add)
        if mem >= v_th:
            mem = 0
            sticky = True
            
        tick_cnt += 1
        if tick_cnt == 1000:
            if window_idx < 1000:
                if sticky: spikes[window_idx] = 1.0
                sticky = False
            tick_cnt = 0
            window_idx += 1
            
    return spikes

def extract_audio_pdms(audio_dir, samples_per_class=10):
    classes = [d for d in os.listdir(audio_dir) if not d.startswith(".")]
    classes.remove("vier")
    dataset = []
    
    print("Loading Audio & Generating PDM Physics...")
    for lbl in classes:
        files = [f for f in os.listdir(os.path.join(audio_dir, lbl)) if f.endswith(".wav")]
        np.random.shuffle(files)
        
        for f in files[:samples_per_class]:
            wav_path = os.path.join(audio_dir, lbl, f)
            waveform, sr = torchaudio.load(wav_path)
            
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
    
    candidate_meta = []
    candidate_features = [] # Used for correlation (redundancy penalty)
    candidate_fisher_scores = [] # The pure information score
    
    kw_classes = [c for c in classes if c not in ["silence", "noise"]]
    
    print("\nSimulating Hardware Candidate Space and Calculating Fisher Information...")
    for b_idx in tqdm(range(len(VALID_BETAS)), desc="Betas"):
        pdm_add = int(1 << FRAC_BITS[b_idx])
        
        for t_mult in THRESH_MULTIPLIERS:
            v_th = int(t_mult * pdm_add)
            if v_th == 0: continue
            
            # Store footprints: [Class] -> [List of 50 temporal arrays]
            class_footprints = {c: [] for c in classes}
            for lbl, pdm in dataset:
                spikes = sim_neuron(pdm, shifts[b_idx], signs[b_idx], pdm_add, v_th)
                binned = spikes.reshape((20, 50)).sum(axis=1)
                class_footprints[lbl].append(binned)
                
            # Hardware Viability Checks
            class_totals = {c: np.sum(np.mean(class_footprints[c], axis=0)) for c in classes}
            silence_spikes = class_totals.get("silence", 0)
            noise_spikes = class_totals.get("noise", 0)
            avg_kw_spikes = np.mean([class_totals[c] for c in kw_classes]) if kw_classes else 0
            
            if 10 <= avg_kw_spikes <= 450 and silence_spikes <= 50 and noise_spikes <= 700:
                
                # --- LAW 1: FISHER'S LINEAR DISCRIMINANT (J) ---
                # Calculate how mathematically separable the keywords are on this specific channel
                global_mean = np.mean([np.mean(class_footprints[c], axis=0) for c in kw_classes], axis=0)
                
                between_class_variance = 0.0
                within_class_variance = 0.0
                
                for c in kw_classes:
                    class_samples = np.array(class_footprints[c]) # Shape: (num_samples, 20)
                    class_mean = np.mean(class_samples, axis=0)
                    
                    # Distance between this keyword and the global average (We want this MASSIVE)
                    between_class_variance += len(class_samples) * np.sum((class_mean - global_mean) ** 2)
                    
                    # Noise/Variance across the 50 samples of the SAME keyword (We want this TINY)
                    within_class_variance += np.sum((class_samples - class_mean) ** 2)
                
                # J = Between-Class / Within-Class (Adding 1e-5 to prevent division by zero)
                fisher_score = between_class_variance / (within_class_variance + 1e-5)
                
                # Save the candidate
                flattened_mean_shape = np.concatenate([np.mean(class_footprints[c], axis=0) for c in kw_classes])
                candidate_features.append(flattened_mean_shape)
                candidate_fisher_scores.append(fisher_score)
                candidate_meta.append((b_idx, VALID_BETAS[b_idx], t_mult, v_th, pdm_add, v_strs[b_idx]))

    candidate_features = np.array(candidate_features)
    candidate_fisher_scores = np.array(candidate_fisher_scores)
    
    print(f"\nFound {len(candidate_features)} viable acoustic feature extractors.")
    if len(candidate_features) < 6:
        print("Error: Not enough viable configurations found.")
        return
        
    print("Executing Information Theory Search (Fisher Maximize + Correlation Penalty)...")
    selected_indices = []
    
    # 1. Pick the absolute best channel in the entire search space (Highest Fisher Score)
    best_initial = np.argmax(candidate_fisher_scores)
    selected_indices.append(best_initial)
    
    # 2. Greedily pick the next 5 channels
    for step in range(5):
        best_net_score = -1.0
        best_candidate = -1
        
        for i in range(len(candidate_features)):
            if i in selected_indices: continue
            
            # --- LAW 2: MINIMIZE REDUNDANCY ---
            # Calculate the maximum Pearson Correlation between this channel and the ones we already picked
            max_correlation = 0.0
            v_candidate = candidate_features[i]
            
            for sel_idx in selected_indices:
                v_selected = candidate_features[sel_idx]
                
                # Pearson Correlation Coefficient (1.0 = identical shape, 0.0 = completely orthogonal)
                corr = np.corrcoef(v_candidate, v_selected)[0, 1]
                if np.isnan(corr): corr = 1.0 # Penalize flatlines
                max_correlation = max(max_correlation, abs(corr))
            
            # The True Information Metric: High Fisher Score, but heavily penalized if it looks like an existing channel
            net_score = candidate_fisher_scores[i] * (1.0 - max_correlation)
            
            if net_score > best_net_score:
                best_net_score = net_score
                best_candidate = i
                
        selected_indices.append(best_candidate)
        print(f"Step {step+2}/6 | Added Ch {best_candidate} | Fisher Info: {candidate_fisher_scores[best_candidate]:.2f} | Net Score: {best_net_score:.2f}")

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
        print(f"// Fisher Discriminant Ratio (Information): {candidate_fisher_scores[idx]:.2f}")
        print(f"wire [{reg_size-1}:0] next_v_{ch} = {v_str.replace('mem', f'mem_{ch}')} + (pdm_in ? {reg_size}'d{pdm_add} : {reg_size}'d0);")
        print(f"wire fired_{ch} = (next_v_{ch} >= {reg_size}'d{v_th});\n")
        
    print("=== Update PyTorch Config ===")
    print(f"BETAS = torch.tensor([{', '.join(f'{b:.4f}' for b in final_betas)}])")
    print(f"THRESHOLDS = torch.tensor([{', '.join(str(t) for t in final_thresh)}])")

if __name__ == "__main__":
    main()