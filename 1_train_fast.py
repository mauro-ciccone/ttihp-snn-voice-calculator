import os
import torch
import torch.nn as nn
from tqdm import tqdm
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger, get_latest_commit, append_commit

import warnings

# Filter out the specific TorchAudio deprecation warning
warnings.filterwarnings(
    "ignore",
    category=UserWarning,
    module="torchaudio._backend.utils",
)

# --- SETUP ---
TARGET_FOLDER = "experiments/0828_0305_silence_noise_split"
EPOCHS_TO_RUN = 1
# -------------

def run_evaluation(model, data_loader, device, idx_noise, idx_silence):
    model.eval()
    val_correct, val_total = 0, 0
    all_preds, all_targets, all_spikes = [], [], []
    all_in_spikes, all_hidden_spikes = [], []
    
    with torch.no_grad():
        for x, y in data_loader:
            x, y = x.to(device), y.to(device)
            spk_out, spk_hidden = model(x)  # Correctly unpack tuple
            spike_counts = spk_out.sum(dim=1)
            
            # Use threshold of 5 for dynamic hardware inference
            max_spikes, raw_preds = spike_counts.max(dim=1)
            preds = torch.where(max_spikes < 10, torch.tensor(idx_silence, device=device), raw_preds)
            
            val_correct += (preds == y).sum().item()
            val_total += y.size(0)
            
            all_preds.extend(preds.cpu().tolist())
            all_targets.extend(y.cpu().tolist())
            all_spikes.append(spike_counts.cpu())
            all_in_spikes.append(x.sum(dim=1).cpu())
            all_hidden_spikes.append(spk_hidden.sum(dim=1).cpu())
            
    spike_counts = torch.cat(all_spikes, dim=0)
    input_counts = torch.cat(all_in_spikes, dim=0)
    hidden_counts = torch.cat(all_hidden_spikes, dim=0)
    acc = (val_correct / val_total) * 100
    
    return acc, all_preds, all_targets, spike_counts, input_counts, hidden_counts

def main():
    device = torch.device("cpu")
    
    # 1. Load Ledger
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    latest_commit = get_latest_commit(TARGET_FOLDER)
    
    print(f"\n=== Lightning Training Pipeline ===")
    print(f"Target: {TARGET_FOLDER}")
    print(f"Commit {latest_commit['commit_id']} -> {latest_commit['model_file']}") # pyright: ignore[reportOptionalSubscript]
    
    # 2. Data Loaders
    train_loader, test_loader, labels_map = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    inv_labels = {v: k for k, v in labels_map.items()}
    idx_noise = labels_map.get("noise", 6)
    idx_silence = labels_map.get("silence", 7)
    num_classes = len(labels_map)
    
    # 3. Model Setup
    model = FastSpikingNet(
        num_inputs=config["num_inputs"],
        num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"],
        beta=config["beta"]
    ).to(device)
    
    model_path = os.path.join(TARGET_FOLDER, latest_commit["model_file"]) # pyright: ignore[reportOptionalSubscript]
    model.load_state_dict(torch.load(model_path, map_location=device))
    
    optimizer = torch.optim.Adam(model.parameters(), lr=config["lr"])
    
    # 4. Training Loop
    for epoch in range(EPOCHS_TO_RUN):
        model.train()
        total_loss, correct, total = 0.0, 0, 0
        
        pbar = tqdm(train_loader, desc=f"Epoch {epoch+1:02d}", leave=False)
        for x, y in pbar:
            x, y = x.to(device), y.to(device)
            optimizer.zero_grad()
            
            spk_out, _ = model(x)
            spike_counts = spk_out.sum(dim=1)   # Shape: [batch_size, 7]
            
            # 2. Route the Data
            active_mask = y < config["num_outputs"] # Keywords (0-5) and Noise (6)
            silence_mask = y == idx_silence         # Silence (7)
    
            loss = torch.tensor(0.0, device=device, requires_grad=True)
    
            # 3. Calculate Loss
            if active_mask.any():
                active_spikes = spike_counts[active_mask]
                active_targets = y[active_mask]

                target_spike_vals = active_spikes[torch.arange(len(active_targets)), active_targets]
                loss = loss + torch.relu(40.0 - target_spike_vals).mean()
                loss = loss + torch.relu(target_spike_vals - 50).mean()
                target_ideal = torch.full_like(target_spike_vals, 45.0)
                loss = loss + 0.1*nn.functional.smooth_l1_loss(target_spike_vals, target_ideal)
        
                other_mask = torch.ones_like(active_spikes, dtype=torch.bool)
                other_mask[torch.arange(len(active_targets)), active_targets] = False
                other_spikes = active_spikes[other_mask]
                loss = loss + torch.relu(other_spikes - 7.0).mean() # -7 means 8+ triggers penalty
        
            if silence_mask.any():
                # 4. Silence Penalty: Punish if ANY neuron spikes >= 8
                loss = loss + torch.relu(spike_counts[silence_mask] - 7.0).mean()
    
            # 4. Backpropagate
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0) 
            optimizer.step()
            total_loss += loss.item()

            with torch.no_grad():
                model.fc_in.weight.data.clamp_(min=0.01)
                #model.fc_out.weight.data.clamp_(min=0.01)
                #model.fc_rec.weight.data.clamp_(min=-0.05, max=0.05)
    
            # 5. Calculate Accuracy
            max_spikes, raw_preds = spike_counts.max(dim=1)
            preds = torch.where(max_spikes < 10, torch.tensor(idx_silence, device=device), raw_preds)
            correct += (preds == y).sum().item()
            total += y.size(0)
    
            pbar.set_postfix({"Loss": f"{loss.item():.2f}", "Acc": f"{(correct/total)*100:.1f}%"})
            
        # Quick eval
        test_acc, _, _, _, _, _ = run_evaluation(model, test_loader, device, idx_noise, idx_silence)
        print(f"Epoch {epoch+1:02d}/{EPOCHS_TO_RUN} | Train Acc: {(correct/total)*100:.1f}% | Test Acc: {test_acc:.1f}%")

    # 5. Final Deep Diagnostic
    print("\nRunning Final Diagnostics...")
    final_test_acc, preds, targets, spike_counts, input_counts, hidden_counts = run_evaluation(model, test_loader, device, idx_noise, idx_silence)
    
    # Confusion Matrix
    cm = [[0] * num_classes for _ in range(num_classes)]
    for t, p in zip(targets, preds):
        cm[t][p] += 1
    cm_pct = [[round((val / sum(row)) * 100, 1) if sum(row) > 0 else 0.0 for val in row] for row in cm]
    
    print("\n--- Final Confusion Matrix (%) ---")
    label_names = [inv_labels[i] for i in range(num_classes)]
    header = f"{'Target / Pred':<13} | " + " | ".join([f"{lbl:>6}" for lbl in label_names])
    print(header)
    print("-" * len(header))
    for i, row in enumerate(cm_pct):
        print(f"{label_names[i]:<13} | " + " | ".join([f"{val:>6.1f}" for val in row]))

    target_tensor = torch.tensor(targets)

    # --- 2. HIDDEN Layer Activity (128 Neurons) ---
    print("\n--- HIDDEN Layer Activity (128 Neurons) ---")
    print(f"{'Target Class':<13} | Avg Spikes/Neuron | Max Spikes (Hottest Neuron)")
    print("-" * 55)
    for i in range(num_classes):
        class_mask = target_tensor == i
        if class_mask.sum() > 0:
            mean_hidden = hidden_counts[class_mask].float().mean(dim=0)
            avg_all = mean_hidden.mean().item()
            max_hot = mean_hidden.max().item()
            print(f"{label_names[i]:<13} | {avg_all:>17.1f} | {max_hot:>25.1f}")

    # --- 3. Output Spike Counter ---
    print("\n--- Average Output Spikes per Target Class ---")
    neuron_names = [inv_labels[i] for i in range(7)] 
    header_spikes = f"{'Target Class':<13} | " + " | ".join([f"{lbl:>6}" for lbl in neuron_names])
    print(header_spikes)
    print("-" * len(header_spikes))
    
    for i in range(num_classes): 
        class_mask = target_tensor == i
        if class_mask.sum() > 0:
            mean_spikes = spike_counts[class_mask].float().mean(dim=0)
            print(f"{label_names[i]:<13} | " + " | ".join([f"{val:>6.1f}" for val in mean_spikes]))
        else:
            print(f"{label_names[i]:<13} | No samples in test set")
        
    # Margin Threshold Analysis
    sorted_spikes, _ = torch.sort(spike_counts, dim=1, descending=True)
    margin_diffs = sorted_spikes[:, 0] - sorted_spikes[:, 1]
    target_tensor_arr, pred_tensor_arr = torch.tensor(targets), torch.tensor(preds)
    threshold_report = {}
    
    print("\n--- Spike Margin Threshold Report ---")
    for margin in [0, 1, 2, 3, 4, 5, 10, 15]:
        mask = margin_diffs >= margin
        retained = mask.sum().item()
        ret_pct = (retained / len(targets)) * 100
        acc_retained = (pred_tensor_arr[mask] == target_tensor_arr[mask]).sum().item() / retained * 100 if retained > 0 else 0.0
        threshold_report[f"margin_{margin}"] = {"retained": retained, "ret_pct": ret_pct, "acc": acc_retained}
        print(f">= {margin:2d} spikes diff | {retained:3d}/{len(targets):3d} retained ({ret_pct:5.1f}%) | {acc_retained:5.1f}%")

    # 6. Commit to Ledger
    next_id = f"{int(latest_commit['commit_id']) + 1:02d}" # pyright: ignore[reportOptionalSubscript]
    new_model_filename = f"model_{next_id}_train.pth"
    torch.save(model.state_dict(), os.path.join(TARGET_FOLDER, new_model_filename))
    
    append_commit(
        folder_path=TARGET_FOLDER,
        action="train",
        model_filename=new_model_filename,
        metrics={
            "best_test_acc": round(final_test_acc, 2),
            "confusion_matrix_raw": cm,
            "confusion_matrix_pct": cm_pct,
            "threshold_analysis": threshold_report
        }
    )
    print(f"\n>>> Best model saved to {new_model_filename}")
    print(f">>> Committed metrics to ledger.json\n")

if __name__ == "__main__":
    main()