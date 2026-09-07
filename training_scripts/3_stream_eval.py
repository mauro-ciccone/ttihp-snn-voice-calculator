import os
import torch
import random
from tqdm import tqdm
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0906_2022_without_minus" # Update if needed

# --- OPTIMIZED HARDWARE TRIGGER LOGIC ---
MIN_SPIKES = 14
MARGIN_THRESHOLD = 3
LOCKOUT_MS = 800
CONSENSUS_FRAMES = 4
STRIDE_MS = 65
N_ITERATIONS = 100       # Number of full streams to simulate
# ----------------------------------------

def get_random_sample(samples_dict, class_name, duration_ms=1000):
    x = random.choice(samples_dict[class_name])
    if duration_ms < x.size(1):
        start = random.randint(0, x.size(1) - duration_ms)
        x = x[:, start:start+duration_ms, :]
    return x

def evaluate_stream(expected_sequence, triggered_sequence):
    """Calculates how well the hardware retained the spoken words in order."""
    correct = 0
    match_idx = 0
    for t in triggered_sequence:
        if match_idx < len(expected_sequence) and t == expected_sequence[match_idx]:
            correct += 1
            match_idx += 1
    return correct

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    # 1. Load Data Bank
    _, test_loader, labels_map = get_cached_dataloaders("data_cache", batch_size=1)
    inv_labels = {v: k for k, v in labels_map.items() if k != "minus"}
    
    print("\nGathering full test cache for statistical stream evaluation...")
    sample_bank = {lbl: [] for lbl in inv_labels.values()}
    for x, y in test_loader:
        sample_bank[inv_labels[y.item()]].append(x)
            
    # 2. Load Model
    model = FastSpikingNet(
        num_inputs=config["num_inputs"], 
        num_hidden=config["num_hidden"], 
        num_outputs=config["num_outputs"], 
        beta=config["beta"]
    ).to(device)
    checkpoint = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location=device)
    model.load_state_dict(checkpoint.get("model_state_dict", checkpoint))
    model.eval()

    numbers = ["drü", "eis", "vier", "zwoi"]
    
    total_spoken_words = 0
    total_hardware_triggers = 0
    total_correct_triggers = 0
    perfect_streams = 0

    print(f"\n--- Running {N_ITERATIONS} Continuous Hardware Simulations ---")
    
    # 3. Fast Evaluation Loop
    with torch.no_grad():
        for _ in tqdm(range(N_ITERATIONS), desc="Simulating Hardware"):
            # Build Math Phrase
            w1_lbl = random.choice(numbers)
            w2_lbl = "plus"
            w3_lbl = random.choice(numbers)
            expected_sequence = [w1_lbl, w2_lbl, w3_lbl]
            
            pre_len = random.randint(300, 600)
            p1_len = random.randint(300, 600)
            p2_len = random.randint(300, 600)
            post_len = random.randint(500, 800)
            
            pre = get_random_sample(sample_bank, "silence", duration_ms=pre_len)
            t1 = get_random_sample(sample_bank, w1_lbl)
            p1 = get_random_sample(sample_bank, "silence", duration_ms=p1_len)
            t2 = get_random_sample(sample_bank, w2_lbl)
            p2 = get_random_sample(sample_bank, "silence", duration_ms=p2_len)
            t3 = get_random_sample(sample_bank, w3_lbl)
            post = get_random_sample(sample_bank, "silence", duration_ms=post_len)
            
            continuous_x = torch.cat([pre, t1, p1, t2, p2, t3, post], dim=1).to(device)
            total_steps = continuous_x.size(1)
            
            # Hardware State Reset
            mem_hidden = model.lif_hidden.init_leaky()
            mem_out = model.lif_out.init_leaky()
            spk_hidden = torch.zeros(1, model.fc_rec.in_features, device=device)
            spike_buffer = torch.zeros(1000, model.fc_out.out_features)
            
            lockout_timer = 0
            prediction_history = []
            next_eval_step = 1000 
            triggered_sequence = []
            
            # Sub-millisecond pipeline
            for step in range(total_steps):
                cur_in = model.fc_in(continuous_x[:, step, :])
                cur_rec = model.fc_rec(spk_hidden)
                spk_hidden, mem_hidden = model.lif_hidden(cur_in + cur_rec, mem_hidden)
                cur_out = model.fc_out(spk_hidden)
                spk_out_step, mem_out = model.lif_out(cur_out, mem_out)
                
                spike_buffer[step % 1000] = spk_out_step[0]
                
                if lockout_timer > 0:
                    lockout_timer -= 1
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
                    
                    if has_consensus and is_actionable:
                        triggered_sequence.append(current_pred)
                        lockout_timer = LOCKOUT_MS
                        next_eval_step = step + LOCKOUT_MS 
                        mem_hidden = model.lif_hidden.init_leaky()
                        mem_out = model.lif_out.init_leaky()
                        spk_hidden = torch.zeros(1, model.fc_rec.in_features, device=device)
                        spike_buffer.zero_()
                        prediction_history.clear()

            # Tally metrics for this stream
            correct_in_stream = evaluate_stream(expected_sequence, triggered_sequence)
            
            total_spoken_words += 3
            total_hardware_triggers += len(triggered_sequence)
            total_correct_triggers += correct_in_stream
            
            if correct_in_stream == 3 and len(triggered_sequence) == 3:
                perfect_streams += 1

    # 4. Final Statistical Output
    retention_pct = (total_correct_triggers / total_spoken_words) * 100
    precision_pct = (total_correct_triggers / total_hardware_triggers) * 100 if total_hardware_triggers > 0 else 0
    perfect_stream_pct = (perfect_streams / N_ITERATIONS) * 100

    print("\n========================================================")
    print("      SILICON STREAMING DIAGNOSTICS (200 PHRASES)       ")
    print("========================================================")
    print(f"Total Words Spoken:         {total_spoken_words}")
    print(f"Total Hardware Triggers:    {total_hardware_triggers}")
    print(f"Total Correct Actions:      {total_correct_triggers}")
    print("-" * 56)
    print(f"Hardware Precision:         {precision_pct:.1f}%  (Are the triggers right?)")
    print(f"Hardware Retention:         {retention_pct:.1f}%  (Did it catch the words?)")
    print(f"Perfect Sentences Heard:    {perfect_stream_pct:.1f}%  ({perfect_streams}/{N_ITERATIONS} streams flawless)")
    print("========================================================\n")

if __name__ == "__main__":
    main()