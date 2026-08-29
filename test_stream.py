import os
import torch
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0829_1530_dynamic_lr" # Update to your folder

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    # 1. Load Data & Model
    _, test_loader, labels_map = get_cached_dataloaders("data_cache", batch_size=1)
    inv_labels = {v: k for k, v in labels_map.items()}
    
    model = FastSpikingNet(
        num_inputs=config["num_inputs"],
        num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"],
        beta=config["beta"]
    ).to(device)
    
    model.load_state_dict(torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location=device))
    model.eval()

    # 2. Build the Continuous Stream
    print("\n--- Stitching Continuous Audio Stream ---")
    stream_tensors = []
    stream_labels = []
    
    # Grab the first 8 samples from the test loader
    iterator = iter(test_loader)
    for _ in range(8):
        x, y = next(iterator)
        stream_tensors.append(x) # Shape: [1, time_steps, features]
        stream_labels.append(inv_labels[y.item()])
        
    # Concatenate along the time dimension (dim=1)
    continuous_x = torch.cat(stream_tensors, dim=1).to(device)
    total_steps = continuous_x.size(1)
    step_size = stream_tensors[0].size(1) # Length of one standard sample
    
    print(f"Stream Sequence: {' -> '.join(stream_labels)}")
    print(f"Total Timesteps: {total_steps}")

    # 3. Feed the Open Microphone
    with torch.no_grad():
        # The model processes the entire stream in one shot without resetting voltages
        spk_out, _ = model(continuous_x) 
    
    # 4. Analyze Rolling Hardware Window
    print("\n--- Hardware Sliding Window Analysis ---")
    window_size = step_size
    stride = int(step_size / 2) # Check every half-second
    
    # Squeeze out the batch dimension so spk_out is [time_steps, 7]
    spk_out = spk_out.squeeze(0)
    
    for start in range(0, total_steps - window_size + 1, stride):
        end = start + window_size
        window_spikes = spk_out[start:end].sum(dim=0)
        
        max_spikes, pred_idx = window_spikes.max(dim=0)
        pred_label = inv_labels[pred_idx.item()]
        
        # Hardware trigger requirement: must hit at least 15 spikes to register
        if max_spikes < 15:
            pred_label = "silence/ignore"
            
        # Figure out what word is actually playing during this window
        actual_word_idx = (start + (window_size//2)) // step_size
        actual_word = stream_labels[actual_word_idx]
            
        print(f"Time {start:4d}-{end:4d} | Playing: {actual_word:>8} | Network Hears: {pred_label:>8} ({max_spikes:2.0f} spikes)")

if __name__ == "__main__":
    main()