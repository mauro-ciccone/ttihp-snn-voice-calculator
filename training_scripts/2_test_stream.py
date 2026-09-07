import os
import torch
import random
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0906_2022_without_minus" # Update to your folder

# --- HARDWARE TRIGGER LOGIC ---
MIN_SPIKES = 30          
MARGIN_THRESHOLD = 3     
LOCKOUT_MS = 800         
CONSENSUS_FRAMES = 3     # 3 frames * 125ms = 375ms of solid agreement
STRIDE_MS = 125          # Check 8 times per second
# ------------------------------

def get_random_sample(samples_dict, class_name, duration_ms=1000):
    x = random.choice(samples_dict[class_name])
    if duration_ms < x.size(1):
        start = random.randint(0, x.size(1) - duration_ms)
        x = x[:, start:start+duration_ms, :]
    return x

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    _, test_loader, labels_map = get_cached_dataloaders("data_cache", batch_size=1)
    inv_labels = {v: k for k, v in labels_map.items() if k != "minus"}
    
    print("\nGathering real ambient audio samples from cache...")
    sample_bank = {lbl: [] for lbl in inv_labels.values()}
    for x, y in test_loader:
        sample_bank[inv_labels[y.item()]].append(x)
        if all(len(v) >= 5 for v in sample_bank.values()): break
            
    model = FastSpikingNet(
        num_inputs=config["num_inputs"], 
        num_hidden=config["num_hidden"], 
        num_outputs=config["num_outputs"], 
        beta=config["beta"]
    ).to(device)
    checkpoint = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location=device)
    model.load_state_dict(checkpoint.get("model_state_dict", checkpoint))
    model.eval()

    # 1. Build Realistic Scenario (With Pre/Post padding)
    numbers = ["drü", "eis", "vier", "zwoi"]
    w1_lbl = random.choice(numbers)
    w2_lbl = "plus"
    w3_lbl = random.choice(numbers)
    
    pre_len = random.randint(400, 600)
    p1_len, p2_len = random.randint(300, 600), random.randint(300, 600)
    post_len = random.randint(600, 800)
    
    pre = get_random_sample(sample_bank, "silence", duration_ms=pre_len)
    t1 = get_random_sample(sample_bank, w1_lbl)
    p1 = get_random_sample(sample_bank, "silence", duration_ms=p1_len)
    t2 = get_random_sample(sample_bank, w2_lbl)
    p2 = get_random_sample(sample_bank, "silence", duration_ms=p2_len)
    t3 = get_random_sample(sample_bank, w3_lbl)
    post = get_random_sample(sample_bank, "silence", duration_ms=post_len)
    
    continuous_x = torch.cat([pre, t1, p1, t2, p2, t3, post], dim=1).to(device)
    total_steps = continuous_x.size(1)
    
    print(f"\n--- Simulated Live Audio Stream ---")
    print(f"Speaking: silence({pre_len}ms) -> [{w1_lbl.upper()}] -> pause({p1_len}ms) -> [{w2_lbl.upper()}] -> pause({p2_len}ms) -> [{w3_lbl.upper()}] -> silence({post_len}ms)")
    
    mem_hidden = model.lif_hidden.init_leaky()
    mem_out = model.lif_out.init_leaky()
    spk_hidden = torch.zeros(1, model.fc_rec.in_features, device=device)
    
    spike_buffer = torch.zeros(1000, model.fc_out.out_features)
    lockout_timer = 0
    prediction_history = []
    
    next_eval_step = 1000 
    
    for step in range(total_steps):
        cur_in = model.fc_in(continuous_x[:, step, :])
        cur_rec = model.fc_rec(spk_hidden)
        spk_hidden, mem_hidden = model.lif_hidden(cur_in + cur_rec, mem_hidden)
        cur_out = model.fc_out(spk_hidden)
        spk_out_step, mem_out = model.lif_out(cur_out, mem_out)
        
        spike_buffer[step % 1000] = spk_out_step[0]
        
        if lockout_timer > 0:
            lockout_timer -= 1
            if lockout_timer == 0:
                print(f"Time {step:4d}      | [Hardware Lockout Released]")
            continue 
            
        if step >= next_eval_step:
            next_eval_step = step + STRIDE_MS 
            
            window_spikes = spike_buffer.sum(dim=0)
            sorted_spikes, sorted_indices = torch.sort(window_spikes, descending=True)
            max_spikes = sorted_spikes[0].item()
            margin = max_spikes - sorted_spikes[1].item()
            raw_top_pred = inv_labels[sorted_indices[0].item()] # type: ignore
            
            if max_spikes >= MIN_SPIKES and margin >= MARGIN_THRESHOLD:
                current_pred = raw_top_pred
            else:
                current_pred = "silence/ignore"
                
            prediction_history.append(current_pred)
            if len(prediction_history) > CONSENSUS_FRAMES:
                prediction_history.pop(0)
                
            is_actionable = current_pred not in ["noise", "silence", "silence/ignore"]
            has_consensus = len(prediction_history) == CONSENSUS_FRAMES and all(p == current_pred for p in prediction_history)
            
            # TRIGGER ONLY IF CONSENSUS IS MET ON AN ACTIONABLE KEYWORD
            if has_consensus and is_actionable:
                print(f"Time {step-1000:4d}-{step:4d} | >>> ACTION EXECUTED: {current_pred.upper()} (Spikes: {max_spikes:2.0f}, Margin: {margin:2.0f}) <<<")
                
                lockout_timer = LOCKOUT_MS
                next_eval_step = step + LOCKOUT_MS 
                
                mem_hidden = model.lif_hidden.init_leaky()
                mem_out = model.lif_out.init_leaky()
                spk_hidden = torch.zeros(1, model.fc_rec.in_features, device=device)
                spike_buffer.zero_()
                prediction_history.clear()
            else:
                if current_pred == "silence/ignore":
                    print(f"Time {step-1000:4d}-{step:4d} | Hears: {current_pred:>15} (Top was: {raw_top_pred.upper():<4} with {max_spikes:2.0f} spikes, margin: {margin:2.0f})")
                else:
                    print(f"Time {step-1000:4d}-{step:4d} | Hears: {current_pred:>15} (Building consensus...)")

if __name__ == "__main__":
    main()
    main()
    main()