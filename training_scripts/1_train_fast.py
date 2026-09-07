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
TARGET_FOLDER = "experiments/0906_2022_without_minus"
EPOCHS_TO_RUN = 0
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
    FINE_TUNING = False
    
    # 1. Load Ledger
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    latest_commit = get_latest_commit(TARGET_FOLDER)
    
    print(f"\n=== Lightning Training Pipeline ===")
    print(f"Target: {TARGET_FOLDER}")
    print(f"Commit {latest_commit['commit_id']} -> {latest_commit['model_file']}") # pyright: ignore[reportOptionalSubscript]
    
    train_loader, test_loader, labels_map = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    inv_labels = {v: k for k, v in labels_map.items() if k != "minus"}
    idx_noise = labels_map.get("noise", 5)
    idx_silence = labels_map.get("silence", 6)
    num_classes = config["num_outputs"]
    
    # 3. Model Setup
    model = FastSpikingNet(
        num_inputs=config["num_inputs"],
        num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"],
        beta=config["beta"]
    ).to(device)
    
    optimizer = torch.optim.Adam(model.parameters(), lr=config["lr"])
    
    best_test_acc = 0.0
    best_combined_acc = 0.0
    start_epoch = 0

    model_path = os.path.join(TARGET_FOLDER, "model_best.pth")
    if os.path.exists(model_path):
        checkpoint = torch.load(model_path, map_location=device)
        # Check if it's a new full checkpoint or old legacy weights
        if "model_state_dict" in checkpoint:
            model.load_state_dict(checkpoint["model_state_dict"])
            optimizer.load_state_dict(checkpoint["optimizer_state_dict"])
            best_test_acc = checkpoint.get("best_test_acc", 0.0)
            start_epoch = checkpoint.get("epoch", 0) + 1
            print(f">>> Resuming from Epoch {start_epoch-1} | Best Acc: {best_test_acc:.1f}%")
        else:
            model.load_state_dict(checkpoint)
            print(">>> Loaded legacy raw model weights.")

    if FINE_TUNING: # type: ignore
            optimizer = torch.optim.Adam(model.parameters(), lr=0.000005)

    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='max', factor=0.9, patience=5, min_lr=1e-6)
    
    # 4. Training Loop
    for epoch in range(start_epoch, start_epoch + EPOCHS_TO_RUN):
        model.train()
        total_loss, correct, total = 0.0, 0, 0
        batches = 0
        
        pbar = tqdm(train_loader, desc=f"Epoch {epoch+1:02d}", leave=False)
        for x, y in pbar:
            x, y = x.to(device), y.to(device)
            optimizer.zero_grad()
            batches += 1
            
            spk_out, _ = model(x)
            spike_counts = spk_out.sum(dim=1)   # Shape: [batch_size, 7]
            
            # 2. Route the Data
            active_mask = y < config["num_outputs"] # Keywords (0-5) and Noise (6)
            silence_mask = y == idx_silence         # Silence (7)
    
            loss = torch.tensor(0.0, device=device, requires_grad=True)
    
            if active_mask.any():
                active_spikes = spike_counts[active_mask]
                active_targets = y[active_mask]

                target_spike_vals = active_spikes[torch.arange(len(active_targets)), active_targets]

                # 1. Target Volume: Keep target firing actively (40-50 spikes)
                loss = loss + 2.0 * torch.relu(40.0 - target_spike_vals).mean()
                loss = loss + torch.relu(target_spike_vals - 50.0).mean()

                # 2. Loudest Competitor Isolation:
                other_mask = torch.ones_like(active_spikes, dtype=torch.bool)
                other_mask[torch.arange(len(active_targets)), active_targets] = False
                other_spikes_2d = active_spikes[other_mask].view(len(active_targets), -1)
                max_competitor_vals, _ = other_spikes_2d.max(dim=1)

                if FINE_TUNING: # type: ignore
                    # --- 4. FINE-TUNING ASYMMETRY ---
                    # Apply a gentle tax to background spikes, but make false keywords 
                    # slightly more painful (0.5) than false noise (0.1).
                    false_noise_mask = active_targets != idx_noise
                    if false_noise_mask.any():
                        # Tax for wrong keyword neurons firing (encourages dropping them)
                        loss = loss + 0.3 * torch.relu(other_spikes_2d[false_noise_mask] - 8.0).sum(dim=1).mean()

                        # Much softer tax for the noise neuron firing (allows it to absorb uncertainty)
                        #loss = loss + 0.1 * torch.relu(active_spikes[false_noise_mask, idx_noise] - 8.0).mean()

                # 3. Margin Penalty: Target must beat the single loudest runner-up by >= 12 spikes
                loss = loss + 1.5 * torch.relu(15.0 - (target_spike_vals - max_competitor_vals)).mean()
        
            if silence_mask.any():
                # 4. Silence Penalty: Punish if ANY neuron spikes >= 8
                loss = loss + 2*torch.relu(spike_counts[silence_mask] - 7.0).mean()
    
            # 4. Backpropagate
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0) 
            optimizer.step()
            total_loss += loss.item()

            with torch.no_grad():
                model.fc_in.weight.data.clamp_(min=0.01)
    
            # 5. Calculate Accuracy
            max_spikes, raw_preds = spike_counts.max(dim=1)
            preds = torch.where(max_spikes < 10, torch.tensor(idx_silence, device=device), raw_preds)
            correct += (preds == y).sum().item()
            total += y.size(0)
    
            pbar.set_postfix({"Loss": f"{loss.item():.2f}", "Acc": f"{(correct/total)*100:.1f}%"})

        train_acc = (correct/total) * 100
            
        # Quick eval
        epoch_loss = total_loss/batches
        test_acc, _, _, _, _, _ = run_evaluation(model, test_loader, device, idx_noise, idx_silence)
        average_perf = (test_acc + train_acc )/ 2
        scheduler.step(average_perf) 
        current_lr = optimizer.param_groups[0]['lr']

        print(f"Epoch {epoch+1:02d}/{EPOCHS_TO_RUN} | Train Acc: {train_acc:.1f}% | Test Acc: {test_acc:.1f}% | LR: {current_lr:.6f} | Loss: {epoch_loss:.2f}")

        if average_perf > best_combined_acc:
            best_combined_acc = average_perf
            best_model_path = os.path.join(TARGET_FOLDER, "model_best.pth")
            
            checkpoint = {
                "epoch": epoch,
                "model_state_dict": model.state_dict(),
                "optimizer_state_dict": optimizer.state_dict(),
                "scheduler_state_dict": scheduler.state_dict(),
                "best_combined_acc": best_combined_acc,
                "train_acc": train_acc,
                "test_acc": test_acc
            }
            torch.save(checkpoint, best_model_path)
            print(f"   🌟 New Best Combined Score! Saved {best_model_path}")

        if current_lr < 0.0001:
                    FINE_TUNING = True

    # 5. Final Deep Diagnostic
    print("\nRunning Final Diagnostics...")
    final_test_acc, preds, targets, spike_counts, input_counts, hidden_counts = run_evaluation(model, test_loader, device, idx_noise, idx_silence)
    
    target_tensor_arr = torch.tensor(targets)
    pred_tensor_arr = torch.tensor(preds)
    
    print("\n--- HIDDEN Layer Activity ---")
    print(f"{'Target Class':<13} | Avg Spikes/Neuron | Max Spikes (Hottest Neuron)")
    print("-" * 55)
    for i in range(len(inv_labels)):
        class_mask = target_tensor_arr == i
        if class_mask.sum() > 0:
            mean_hidden = hidden_counts[class_mask].float().mean(dim=0)
            print(f"{inv_labels[i]:<13} | {mean_hidden.mean().item():>17.1f} | {mean_hidden.max().item():>25.1f}")

    print("\n--- Average Output Spikes per Target Class ---")
    header_spikes = f"{'Target Class':<13} | " + " | ".join([f"{inv_labels[i]:>6}" for i in range(num_classes)])
    print(header_spikes)
    print("-" * len(header_spikes))
    for i in range(len(inv_labels)): 
        class_mask = target_tensor_arr == i
        if class_mask.sum() > 0:
            mean_spikes = spike_counts[class_mask].float().mean(dim=0)
            print(f"{inv_labels[i]:<13} | " + " | ".join([f"{val:>6.1f}" for val in mean_spikes]))

    # --- 3. Hardware Precision Matrix (%) ---
    print("\n--- Hardware Precision Matrix (%) ---")
    print("(Calculated only on active keyword triggers. Noise/Silence = Dropped)")
    keyword_idx = [i for i in range(num_classes) if i not in (idx_noise, idx_silence)]
    header = f"{'Target / Pred':<13} | " + " | ".join([f"{inv_labels[i]:>6}" for i in keyword_idx]) + " || Retention"
    print(header)
    print("-" * len(header))
    
    for t_idx in keyword_idx:
        t_mask = target_tensor_arr == t_idx
        total_samples = t_mask.sum().item()
        
        if total_samples > 0:
            # How many times did it guess a real keyword instead of dropping to noise?
            preds_for_target = pred_tensor_arr[t_mask]
            active_preds = preds_for_target[(preds_for_target != idx_noise) & (preds_for_target != idx_silence)]
            retained = active_preds.size(0)
            ret_pct = (retained / total_samples) * 100
            
            row_str = f"{inv_labels[t_idx]:<13} | "
            for p_idx in keyword_idx:
                count = (active_preds == p_idx).sum().item()
                pct = (count / retained * 100) if retained > 0 else 0.0
                row_str += f"{pct:>6.1f} | "
            row_str += f"|| {ret_pct:>6.1f}%"
            print(row_str)

    # --- 4. ACTIONABLE KEYWORD MARGIN REPORT ---
    sorted_spikes, _ = torch.sort(spike_counts, dim=1, descending=True)
    margin_diffs = sorted_spikes[:, 0] - sorted_spikes[:, 1]
    
    is_keyword_target = (target_tensor_arr != idx_noise) & (target_tensor_arr != idx_silence)
    total_real_keywords = is_keyword_target.sum().item()

    threshold_report = {}
    print(f"\n--- Spike Margin Threshold Report (Base: {total_real_keywords} Real Keywords) ---")
    for margin in [0, 1, 2, 3, 4, 5, 10, 15]:
        margin_met = margin_diffs >= margin
        
        # An "attempt" is when the network confidently outputs an actionable keyword pin
        is_keyword_pred = (pred_tensor_arr != idx_noise) & (pred_tensor_arr != idx_silence)
        attempt_mask = margin_met & is_keyword_pred
        total_attempts = attempt_mask.sum().item()
        
        # Precision: When the physical pin goes HIGH, was it correct?
        correct_attempts = (pred_tensor_arr[attempt_mask] == target_tensor_arr[attempt_mask]).sum().item()
        precision = (correct_attempts / total_attempts * 100) if total_attempts > 0 else 0.0
        
        # Retention: Out of the TRUE spoken words, how many were caught?
        keywords_attempted = (attempt_mask & is_keyword_target).sum().item()
        retention_pct = (keywords_attempted / total_real_keywords * 100) if total_real_keywords > 0 else 0.0

        threshold_report[f"margin_{margin}"] = {"retained": keywords_attempted, "ret_pct": retention_pct, "acc": precision}
        print(f">= {margin:2d} spikes diff | Prec (Acc): {precision:5.1f}% | Retention: {keywords_attempted:3d}/{total_real_keywords:3d} ({retention_pct:5.1f}%) | Total Triggers: {total_attempts}")

    # 6. Commit to Ledger
    next_id = f"{int(latest_commit['commit_id']) + 1:02d}" # type: ignore
    new_model_filename = f"model_{next_id}_train.pth"
    
    final_checkpoint = {
        "epoch": checkpoint.get("epoch", 0) + EPOCHS_TO_RUN, # type: ignore
        "model_state_dict": model.state_dict(),
        "optimizer_state_dict": optimizer.state_dict(),
        "best_test_acc": final_test_acc,
        "scheduler_state_dict": scheduler.state_dict()
    }
    torch.save(final_checkpoint, os.path.join(TARGET_FOLDER, new_model_filename))
    
    append_commit(
        folder_path=TARGET_FOLDER,
        action="train",
        model_filename=new_model_filename,
        metrics={
            "best_test_acc": round(final_test_acc, 2),
            "threshold_analysis": threshold_report
        }
    )
    print(f"\n>>> Best model saved to {new_model_filename}")
    print(f">>> Committed metrics to ledger.json\n")

if __name__ == "__main__":
    main()