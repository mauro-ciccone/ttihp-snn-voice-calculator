import os
import torch
import copy
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger
import random

TARGET_FOLDER = "experiments/0906_2022_without_minus"

def evaluate_isolated(model, data_loader, device, idx_noise, idx_silence):
    model.eval()
    all_preds, all_targets, all_spikes = [], [], []
    
    with torch.no_grad():
        for x, y in data_loader:
            x, y = x.to(device), y.to(device)
            spk_out, _ = model(x)
            spike_counts = spk_out.sum(dim=1)
            
            max_spikes, raw_preds = spike_counts.max(dim=1)
            # Soft diagnostic threshold to view the full matrix
            preds = torch.where(max_spikes < 10, torch.tensor(idx_silence, device=device), raw_preds)
            
            all_preds.extend(preds.cpu().tolist())
            all_targets.extend(y.cpu().tolist())
            all_spikes.append(spike_counts.cpu())
            
    return all_preds, all_targets, torch.cat(all_spikes, dim=0)

def quantize_to_8bit(model):
    q_model = copy.deepcopy(model)
    max_int = 127.0 
    
    print("\n--- 8-Bit Hardware Quantization (99th Percentile Clipping) ---")
    with torch.no_grad():
        # 1. Hidden Layer (Shared Scale with Clipping)
        flat_hidden = torch.cat([q_model.fc_in.weight.data.flatten(), q_model.fc_rec.weight.data.flatten()]).abs()
        global_hidden_max = torch.quantile(flat_hidden, 0.9815) # Ignore the top 1% outliers
        
        scale_in = max_int / global_hidden_max
        q_model.fc_in.weight.data = torch.clamp(torch.round(q_model.fc_in.weight.data * scale_in), min=-max_int, max=max_int)
        q_model.fc_rec.weight.data = torch.clamp(torch.round(q_model.fc_rec.weight.data * scale_in), min=-max_int, max=max_int)
        q_model.lif_hidden.threshold.data = q_model.lif_hidden.threshold.data * scale_in
        print(f"Hidden Layer | Scale: {scale_in:7.2f} | 99th Max: {global_hidden_max:.3f} | New Thresh: {q_model.lif_hidden.threshold.item():.0f}")

        # 2. Output Layer (Clipping)
        flat_out = q_model.fc_out.weight.data.abs().flatten()
        w_out_max = torch.quantile(flat_out, 0.9815)
        
        scale_out = max_int / w_out_max
        q_model.fc_out.weight.data = torch.clamp(torch.round(q_model.fc_out.weight.data * scale_out), min=-max_int, max=max_int)
        q_model.lif_out.threshold.data = q_model.lif_out.threshold.data * scale_out
        print(f"Output Layer | Scale: {scale_out:7.2f} | 99th Max: {w_out_max:.3f} | New Thresh: {q_model.lif_out.threshold.item():.0f}")

    return q_model

def main():
    random.seed(42)
    torch.manual_seed(42)


    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    _, test_loader, labels_map = get_cached_dataloaders("data_cache", batch_size=128)
    inv_labels = {v: k for k, v in labels_map.items() if k != "minus"}
    idx_noise = labels_map.get("noise", 5)
    idx_silence = labels_map.get("silence", 6)
    
    model = FastSpikingNet(
        num_inputs=config["num_inputs"],
        num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"],
        beta=config["beta"]
    ).to(device)
    
    checkpoint = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location=device)
    model.load_state_dict(checkpoint.get("model_state_dict", checkpoint))
    
    # Run integer scaling
    q_model = quantize_to_8bit(model)
    
    print("\nRunning Quantized Diagnostics...")
    preds, targets, spike_counts = evaluate_isolated(q_model, test_loader, device, idx_noise, idx_silence)
    
    target_tensor = torch.tensor(targets)
    pred_tensor = torch.tensor(preds)
    sorted_spikes, _ = torch.sort(spike_counts, dim=1, descending=True)
    margin_diffs = sorted_spikes[:, 0] - sorted_spikes[:, 1]
    
    is_keyword_target = (target_tensor != idx_noise) & (target_tensor != idx_silence)
    total_real_keywords = is_keyword_target.sum().item()

    print(f"\n--- 8-Bit Spike Margin Threshold Report (Base: {total_real_keywords} Real Keywords) ---")
    for margin in [0, 1, 2, 3, 4, 5, 10]:
        margin_met = margin_diffs >= margin
        is_keyword_pred = (pred_tensor != idx_noise) & (pred_tensor != idx_silence)
        attempt_mask = margin_met & is_keyword_pred
        total_attempts = attempt_mask.sum().item()
        
        correct_attempts = (pred_tensor[attempt_mask] == target_tensor[attempt_mask]).sum().item()
        precision = (correct_attempts / total_attempts * 100) if total_attempts > 0 else 0.0
        keywords_attempted = (attempt_mask & is_keyword_target).sum().item()
        retention_pct = (keywords_attempted / total_real_keywords * 100) if total_real_keywords > 0 else 0.0

        print(f">= {margin:2d} spikes diff | Prec: {precision:5.1f}% | Retention: {keywords_attempted:3d}/{total_real_keywords:3d} ({retention_pct:5.1f}%)")

if __name__ == "__main__":
    main()