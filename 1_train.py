import os
import copy
import torch
import torch.nn as nn
from tqdm import tqdm
from model import SpikingNet
from dataset import get_dataloaders
from utils_ledger import load_ledger, get_latest_commit, append_commit
import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="torchaudio")

# --- SETUP ---
TARGET_FOLDER = "experiments/0825_1525_dense_teacher"
EPOCHS_TO_RUN = 50
# -------------

def run_evaluation(model, data_loader, device, config, idx_zwoi, idx_foif, ce_loss_fn, epoch):
    model.eval()
    val_correct, val_total, val_loss_sum = 0, 0, 0.0
    all_preds, all_targets, all_spikes = [], [], []
    
    with torch.no_grad():
        for x, y in data_loader:
            x, y = x.to(device), y.to(device)
            spk_out = model(x)
            spike_counts = spk_out.sum(dim=1)
            
            # 1. Losses
            ce_loss = ce_loss_fn(spike_counts, y)
            
            target_counts = torch.zeros_like(spike_counts)
            target_counts.scatter_(1, y.unsqueeze(1), config["target_spikes"])
            reg_loss = nn.functional.mse_loss(spike_counts, target_counts)
            
            spikes_zwoi = spike_counts[:, idx_zwoi]
            spikes_foif = spike_counts[:, idx_foif]
            is_foif = (y == idx_foif).float()
            is_zwoi = (y == idx_zwoi).float()
            conf_loss = torch.mean((spikes_zwoi * is_foif)**2 + (spikes_foif * is_zwoi)**2)
            
            # Inside run_evaluation():
            l1_loss = torch.norm(model.fc_in.weight, p=1) + \
                      torch.norm(model.fc_rec.weight, p=1) + \
                      torch.norm(model.fc_out.weight, p=1)
            
            current_lambda_l1 = config["lambda_l1"] if epoch >= 50 else 0.0
            
            loss = ce_loss + (config["lambda_reg"] * reg_loss) + (config["lambda_confusion"] * conf_loss) + (current_lambda_l1 * l1_loss)
            val_loss_sum += loss.item()

            preds = spike_counts.argmax(dim=1)
            val_correct += (preds == y).sum().item()
            val_total += y.size(0)

            all_preds.extend(preds.cpu().tolist())
            all_targets.extend(y.cpu().tolist())
            all_spikes.append(spike_counts.cpu())

    all_spikes = torch.cat(all_spikes, dim=0)
    avg_loss = val_loss_sum / len(data_loader)
    acc = (val_correct / val_total) * 100
    return avg_loss, acc, all_preds, all_targets, all_spikes


def main():
    device = torch.device("cpu")
    
    # 1. Load Ledger State
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    latest_commit = get_latest_commit(TARGET_FOLDER)
    
    print(f"\n=== Training Pipeline ===")
    print(f"Target: {TARGET_FOLDER}")
    print(f"Commit {latest_commit['commit_id']} -> {latest_commit['model_file']}") # type: ignore
    
    # 2. Data Loaders
    train_loader, test_loader, labels_map = get_dataloaders(
        config=config,
        data_dir="custom_audio",
        test_split_pct=config.get("test_split_pct", 0.2)
    )
    inv_labels = {v: k for k, v in labels_map.items()}
    idx_zwoi = labels_map.get("zwoi", 1)
    idx_foif = labels_map.get("foif", 4)
    num_classes = len(labels_map)

    # 3. Model & Optimizer
    model = SpikingNet(
        n_mels=config["n_mels"],
        num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"],
        beta=config["beta"]
    ).to(device)
    
    model_path = os.path.join(TARGET_FOLDER, latest_commit["model_file"]) # type: ignore
    model.load_state_dict(torch.load(model_path, map_location=device))
    
    optimizer = torch.optim.Adam(model.parameters(), lr=config["lr"])
    ce_loss_fn = nn.CrossEntropyLoss()

    best_test_acc = 0.0
    best_model_state = None
    epoch_history = []

    # 4. Training Loop
    for epoch in range(EPOCHS_TO_RUN):
        model.train()
        total_train_loss, train_correct, train_total = 0.0, 0, 0
        pbar = tqdm(train_loader, desc=f"Epoch {epoch+1:03d}/{EPOCHS_TO_RUN}", leave=False)
        
        for x, y in pbar:
            x, y = x.to(device), y.to(device)
            optimizer.zero_grad()
            
            spk_out = model(x)
            spike_counts = spk_out.sum(dim=1)

            ce_loss = ce_loss_fn(spike_counts, y)
            target_counts = torch.zeros_like(spike_counts)
            target_counts.scatter_(1, y.unsqueeze(1), config["target_spikes"])
            reg_loss = nn.functional.mse_loss(spike_counts, target_counts)

            spikes_zwoi = spike_counts[:, idx_zwoi]
            spikes_foif = spike_counts[:, idx_foif]
            is_foif = (y == idx_foif).float()
            is_zwoi = (y == idx_zwoi).float()
            conf_loss = torch.mean((spikes_zwoi * is_foif)**2 + (spikes_foif * is_zwoi)**2)

            l1_loss = torch.norm(model.fc_in.weight, p=1) + torch.norm(model.fc_rec.weight, p=1) + torch.norm(model.fc_out.weight, p=1)

            current_lambda_l1 = config["lambda_l1"] if epoch >= 50 else 0.0

            loss = ce_loss + (config["lambda_reg"] * reg_loss) + (config["lambda_confusion"] * conf_loss) + (current_lambda_l1 * l1_loss)
            loss.backward()
            optimizer.step()

            total_train_loss += loss.item()
            train_correct += (spike_counts.argmax(dim=1) == y).sum().item()
            train_total += y.size(0)
            pbar.set_postfix({"Loss": f"{loss.item():.2f}", "Acc": f"{(train_correct/train_total)*100:.1f}%"})

        avg_train_loss = total_train_loss / len(train_loader)
        train_acc = (train_correct / train_total) * 100

        # Periodic Evaluation
        avg_test_loss, test_acc, _, _, _ = run_evaluation(
            model, test_loader, device, config, idx_zwoi, idx_foif, ce_loss_fn, epoch
        )

        epoch_history.append({
            "epoch": epoch + 1,
            "train_loss": round(avg_train_loss, 4),
            "test_loss": round(avg_test_loss, 4),
            "train_acc": round(train_acc, 2),
            "test_acc": round(test_acc, 2)
        })

        if test_acc > best_test_acc:
            best_test_acc = test_acc
            best_model_state = copy.deepcopy(model.state_dict())

        if (epoch + 1) % 10 == 0 or epoch == EPOCHS_TO_RUN - 1:
            print(f"Epoch {epoch+1:03d}/{EPOCHS_TO_RUN} -> Train: {train_acc:5.1f}% | Test: {test_acc:5.1f}% | Train Loss: {avg_train_loss:.3f} | Test Loss: {avg_test_loss:.3f}")

    # 5. Final Deep Diagnostic on Best Model State
    if best_model_state is not None:
        model.load_state_dict(best_model_state)
    
    _, final_test_acc, preds, targets, spike_counts = run_evaluation(
        model, test_loader, device, config, idx_zwoi, idx_foif, ce_loss_fn, EPOCHS_TO_RUN
    )

    # Confusion Matrix (Raw & Percentage)
    cm = [[0] * num_classes for _ in range(num_classes)]
    for t, p in zip(targets, preds):
        cm[t][p] += 1

    cm_pct = []
    for row in cm:
        total_row = sum(row)
        cm_pct.append([round((val / total_row) * 100, 1) if total_row > 0 else 0.0 for val in row])

    # Margin Threshold Analysis
    sorted_spikes, _ = torch.sort(spike_counts, dim=1, descending=True)
    margin_diffs = sorted_spikes[:, 0] - sorted_spikes[:, 1]
    target_tensor = torch.tensor(targets)
    pred_tensor = torch.tensor(preds)

    threshold_report = {}
    print("\n--- Spike Margin Threshold Report ---")
    print("Required Margin    | Retention (Not Rejected)  | Accuracy on Retained")
    print("----------------------------------------------------------------------")
    for margin in [0, 1, 2, 3, 4, 5, 10, 15, 20]:
        mask = margin_diffs >= margin
        retained = mask.sum().item()
        total_samples = len(targets)
        ret_pct = (retained / total_samples) * 100
        
        if retained > 0:
            correct_retained = (pred_tensor[mask] == target_tensor[mask]).sum().item()
            acc_retained = (correct_retained / retained) * 100
        else:
            acc_retained = 0.0

        threshold_report[f"margin_{margin}"] = {
            "retained_count": retained,
            "retention_pct": round(ret_pct, 2),
            "accuracy_pct": round(acc_retained, 2)
        }
        print(f">= {margin:2d} spikes diff   | {retained:3d}/{total_samples:3d} retained ({ret_pct:5.1f}%) |  {acc_retained:5.1f}%")

    # 6. Commit to Ledger
    next_id = f"{int(latest_commit['commit_id']) + 1:02d}" # type: ignore
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
        },
        extra_data={
            "epochs_run": EPOCHS_TO_RUN,
            "labels": [inv_labels[i] for i in range(num_classes)],
            "history": epoch_history
        }
    )
    print(f"\n>>> Best model ({final_test_acc:.1f}% test acc) saved to {new_model_filename}")
    print(f">>> Committed metrics & confusion matrix to ledger.json\n")

if __name__ == "__main__":
    main()