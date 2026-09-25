import os
import torch
import torch.nn as nn
from tqdm import tqdm
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger, get_latest_commit, append_commit

import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="torchaudio._backend.utils")

# --- SETUP ---
# Update this to match your newly created folder from 0_init.py!
TARGET_FOLDER = "experiments/0924_1200_64_neuron_model" 
MODEL_NAME = "model_00_init.pth"
EPOCHS_TO_RUN = 300
# -------------

def run_evaluation(model, data_loader, device, idx_noise, idx_silence):
    model.eval()
    val_correct, val_total = 0, 0
    all_preds, all_targets, all_spikes = [], [], []
    all_in_spikes, all_hidden_spikes = [], []
    
    with torch.no_grad():
        for x, y in data_loader:
            x, y = x.to(device), y.to(device)
            spk_out, spk_hidden = model(x)
            spike_counts = spk_out.sum(dim=1)
            
            # Dynamic hardware inference: silence if under 10 spikes
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
    acc = (val_correct / val_total) * 100 if val_total > 0 else 0.0
    
    return acc, all_preds, all_targets, spike_counts, input_counts, hidden_counts

def main():
    device = torch.device("cpu")
    FINE_TUNING = False
    
    # 1. Load Ledger
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    latest_commit = get_latest_commit(TARGET_FOLDER)
    
    print(f"\n=== Training Pipeline (Phase 1: FP Sandbox) ===")
    print(f"Target: {TARGET_FOLDER}")
    print(f"Commit {latest_commit['commit_id']} -> {latest_commit['model_file']}") # type: ignore
    
    train_loader, test_loader, labels_map = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    
    # FIXED: Re-included all labels (removed 'if k != minus')
    inv_labels = {v: k for k, v in labels_map.items()}
    idx_noise = labels_map.get("noise", 6)
    idx_silence = labels_map.get("silence", 7)
    num_classes = config["num_outputs"]
    
    # 2. Model Setup
    model = FastSpikingNet(
        num_inputs=config["num_inputs"],
        num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"],
        beta=config["beta"]
    ).to(device)
    
    # Separate parameters
    beta_params = [p for n, p in model.named_parameters() if 'beta' in n]
    weight_params = [p for n, p in model.named_parameters() if 'beta' not in n]

    optimizer = torch.optim.Adam([
        {'params': weight_params, 'lr': config["lr"]},       # e.g., 0.002
        {'params': beta_params, 'lr': config["lr"] * 0.1}    # e.g., 0.0002
    ])
    
    best_test_acc = 0.0
    best_combined_acc = 0.0
    start_epoch = 0
    checkpoint = {}  # FIXED: Default dictionary prevents UnboundLocalError

    model_path = os.path.join(TARGET_FOLDER, MODEL_NAME)
    if os.path.exists(model_path):
        raw_data = torch.load(model_path, map_location=device)
        if isinstance(raw_data, dict) and "model_state_dict" in raw_data:
            checkpoint = raw_data
            model.load_state_dict(checkpoint["model_state_dict"])
            optimizer.load_state_dict(checkpoint["optimizer_state_dict"])
            best_test_acc = checkpoint.get("best_test_acc", 0.0)
            start_epoch = checkpoint.get("epoch", 0) + 1
            print(f">>> Resuming from Epoch {start_epoch-1} | Best Acc: {best_test_acc:.1f}%")
        else:
            model.load_state_dict(raw_data)
            checkpoint = {"epoch": 0, "best_test_acc": 0.0}
            print(">>> Loaded initial model weights.")

    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='min', factor=0.9, patience=5, min_lr=1e-7)
    
    # 3. Training Loop
    for epoch in range(start_epoch, start_epoch + EPOCHS_TO_RUN):
        model.train()
        total_loss, correct, total = 0.0, 0, 0
        batches = 0
        
        pbar = tqdm(train_loader, desc=f"Epoch {epoch+1:02d}", leave=False)
        for x, y in pbar:
            x, y = x.to(device), y.to(device)
            optimizer.zero_grad()
            batches += 1
            
            spk_out, spk_hidden = model(x)
            spike_counts = spk_out.sum(dim=1)   # Shape: [batch_size, 7]
            hidden_counts = spk_hidden.sum(dim=1)
            
            # Route Data: Active (0-6) vs Silence (7)
            active_mask = y < config["num_outputs"] 
            silence_mask = y == idx_silence         
    
            loss = torch.tensor(0.0, device=device, requires_grad=True)
    
            if active_mask.any():
                active_spikes = spike_counts[active_mask]
                active_targets = y[active_mask]
                target_spike_vals = active_spikes[torch.arange(len(active_targets)), active_targets]

                # 1. Target Volume (Aim for 40-50 spikes)

                loss = loss + 0.0002 * ((target_spike_vals - 45.0) ** 4).mean()

                # 2. HOMEOSTASIS: Windowed Hidden Spike Penalty
                # hidden_counts shape: [batch_size, num_hidden]
                # Sum across all 80 neurons to get total network activity per sample
                total_hidden_spikes = hidden_counts.sum(dim=1) 

                loss = loss + 1.0 * (((torch.abs(total_hidden_spikes - 400.0) / 100.0)) ** 3).mean()

                # 3. Margin Penalty (Target must lead by >= 15 spikes)
                other_mask = torch.ones_like(active_spikes, dtype=torch.bool)
                other_mask[torch.arange(len(active_targets)), active_targets] = False
                other_spikes_2d = active_spikes[other_mask].view(len(active_targets), -1)
                max_competitor_vals, _ = other_spikes_2d.max(dim=1)

                # A) Margin Penalty (STILL INCLUDES NOISE)

                margin = target_spike_vals - max_competitor_vals
                loss = loss + 0.2 * (torch.nn.functional.softplus((40.0 - margin) / 5.0) ** 3).mean()

                # B) Gravity Well (EXEMPTS NOISE)
                gravity_spikes = active_spikes.clone()
                # Zero out the target pin (so we don't penalize the correct answer)
                gravity_spikes[torch.arange(len(active_targets)), active_targets] = 0.0
                # Zero out the noise pin (exempting it from absolute energy suppression)
                gravity_spikes[:, idx_noise] = 0.0  
                
                # Sum the wasted energy across only the false keyword pins
                loss = loss + 0.005 * (gravity_spikes ** 2).sum(dim=1).mean()
        
            if silence_mask.any():
                # 4. Silence Penalty

                loss = loss + 0.0025 * (spike_counts[silence_mask] ** 3).mean()
    
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=0.5) 
            optimizer.step()

            with torch.no_grad():
                model.lif_hidden.beta.clamp_(0.0, 0.99)
                model.lif_out.beta.clamp_(0.0, 0.99)

            total_loss += loss.item()
    
            max_spikes, raw_preds = spike_counts.max(dim=1)
            preds = torch.where(max_spikes < 10, torch.tensor(idx_silence, device=device), raw_preds)
            correct += (preds == y).sum().item()
            total += y.size(0)
    
            pbar.set_postfix({"Loss": f"{loss.item():.2f}", "Acc": f"{(correct/total)*100:.1f}%"})

        train_acc = (correct / total) * 100 if total > 0 else 0.0
        epoch_loss = total_loss / batches if batches > 0 else 0.0
        
        test_acc, _, _, _, _, _ = run_evaluation(model, test_loader, device, idx_noise, idx_silence)
        average_perf = (test_acc + train_acc) / 2.0
        scheduler.step(epoch_loss) 
        current_lr = optimizer.param_groups[0]['lr']

        print(f"Epoch {epoch+1:02d}/{start_epoch + EPOCHS_TO_RUN} | Train: {train_acc:.1f}% | Test: {test_acc:.1f}% | LR: {current_lr:.6f} | Loss: {epoch_loss:.2f}")

        if train_acc > best_combined_acc:
            best_combined_acc = train_acc
            best_model_path = os.path.join(TARGET_FOLDER, "model_best.pth")
            
            saved_checkpoint = {
                "epoch": epoch,
                "model_state_dict": model.state_dict(),
                "optimizer_state_dict": optimizer.state_dict(),
                "scheduler_state_dict": scheduler.state_dict(),
                "best_combined_acc": best_combined_acc,
                "train_acc": train_acc,
                "test_acc": test_acc
            }
            torch.save(saved_checkpoint, best_model_path)
            print(f"   🌟 New Best Combined Score! Saved {best_model_path}")

    # 4. Final Diagnostics
    print("\nRunning Final Diagnostics...")
    final_test_acc, preds, targets, spike_counts, input_counts, hidden_counts = run_evaluation(model, test_loader, device, idx_noise, idx_silence)
    
    target_tensor_arr = torch.tensor(targets)
    pred_tensor_arr = torch.tensor(preds)
    
    # --- 1. Average Input Spikes per Target Class ---
    print("\n--- Average Input Spikes per Target Class ---")
    num_inputs = config["num_inputs"]
    header_in = f"{'Target Class':<13} | " + " | ".join([f"Ch{i:<4}" for i in range(num_inputs)]) + " || TOTAL"
    print(header_in)
    print("-" * len(header_in))
    for i in range(len(inv_labels)): 
        class_mask = target_tensor_arr == i
        if class_mask.sum() > 0:
            mean_in = input_counts[class_mask].float().mean(dim=0)
            total_in = mean_in.sum().item()
            row = f"{inv_labels[i]:<13} | " + " | ".join([f"{val:>6.1f}" for val in mean_in]) + f" || {total_in:>6.1f}"
            print(row)

    # --- 2. Average Hidden Spikes per Target Class ---
    print("\n--- Average Hidden Spikes per Target Class ---")
    header_hid = f"{'Target Class':<13} | {'Total Layer':>11} | {'Avg/Neuron':>10} | {'Max Neuron':>10}"
    print(header_hid)
    print("-" * len(header_hid))
    for i in range(len(inv_labels)): 
        class_mask = target_tensor_arr == i
        if class_mask.sum() > 0:
            mean_hid = hidden_counts[class_mask].float().mean(dim=0)
            total_hid = mean_hid.sum().item()
            avg_per_n = mean_hid.mean().item()
            max_n = mean_hid.max().item()
            print(f"{inv_labels[i]:<13} | {total_hid:>11.1f} | {avg_per_n:>10.1f} | {max_n:>10.1f}")

    # --- 3. Average Output Spikes per Target Class ---
    print("\n--- Average Output Spikes per Target Class ---")
    header_spikes = f"{'Target Class':<13} | " + " | ".join([f"{inv_labels[i]:>6}" for i in range(num_classes)])
    print(header_spikes)
    print("-" * len(header_spikes))
    for i in range(len(inv_labels)): 
        class_mask = target_tensor_arr == i
        if class_mask.sum() > 0:
            mean_spikes = spike_counts[class_mask].float().mean(dim=0)
            print(f"{inv_labels[i]:<13} | " + " | ".join([f"{val:>6.1f}" for val in mean_spikes]))

    # --- 4. Network Health & Sparsity Audit (The Pruning Radar) ---
    print("\n--- Network Health & Sparsity Audit ---")
    
    # 1. Activity Checks
    total_spikes_per_neuron = hidden_counts.sum(dim=0)
    avg_spikes_per_neuron = hidden_counts.mean(dim=0)
    
    dead_neurons = (total_spikes_per_neuron == 0).nonzero(as_tuple=True)[0].tolist()
    hyper_neurons = (avg_spikes_per_neuron > 40).nonzero(as_tuple=True)[0].tolist()
    
    # 2. Structural Checks (Using 1e-4 as the "zero" threshold for floating point)
    # fc_in shape: [num_hidden, num_inputs] -> Check max input weight per hidden neuron
    max_in_w = model.fc_in.weight.data.abs().max(dim=1)[0]
    severed_in = (max_in_w < 1e-4).nonzero(as_tuple=True)[0].tolist()
    
    # fc_out shape: [num_outputs, num_hidden] -> Check max output weight per hidden neuron
    max_out_w = model.fc_out.weight.data.abs().max(dim=0)[0]
    weak_out = (max_out_w < 1.0).nonzero(as_tuple=True)[0].tolist()
    
    # fc_rec shape: [num_hidden, num_hidden] -> Check max recurrent weight per hidden neuron
    max_rec_w = model.fc_rec.weight.data.abs().max(dim=1)[0]
    severed_rec = (max_rec_w < 1e-4).nonzero(as_tuple=True)[0].tolist()
    
    # 3. Temporal Checks
    fast_leakers = (model.lif_hidden.beta.data <= 0.5).nonzero(as_tuple=True)[0].tolist()
    
    # 4. Synthesize: The "Useless" Set (Dead AND Weak Output)
    useless_set = set(dead_neurons) & set(weak_out)
    
    print(f"Total Hidden Neurons: {config['num_hidden']}")
    print(f"Dead Neurons (0 spikes on test set) : {len(dead_neurons):>3}  {dead_neurons if dead_neurons else ''}")
    print(f"Hyperactive (>40 spikes per sample): {len(hyper_neurons):>3}  {hyper_neurons if hyper_neurons else ''}")
    print(f"Severed Inputs (Max In W < 0.0001)  : {len(severed_in):>3}  {severed_in if severed_in else ''}")
    print(f"Severed Recurrents (Max Rec W < 0)  : {len(severed_rec):>3}  {severed_rec if severed_rec else ''}")
    print(f"Weak Output Drivers (Max W < 1.0)   : {len(weak_out):>3}") # List hidden if too long
    print(f"Fast Leakers (Beta <= 0.5)          : {len(fast_leakers):>3}")
    print(f"--> Prime Pruning Candidates        : {len(useless_set):>3}  {list(useless_set) if useless_set else ''}")

    # --- 5. Hardware Precision Matrix (%) ---
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

    # --- 6. ACTIONABLE KEYWORD MARGIN REPORT ---
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
        "epoch": checkpoint.get("epoch", 0) + EPOCHS_TO_RUN,
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
        metrics={"best_test_acc": round(final_test_acc, 2)}
    )
    print(f"\n>>> Best model saved to {new_model_filename}")
    print(f">>> Committed metrics to ledger.json\n")

if __name__ == "__main__":
    main()