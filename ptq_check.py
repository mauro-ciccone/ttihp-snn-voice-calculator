import os
import torch
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0910_1301_24_neurons"  # Update if using a different folder
PRUNE_MARGIN = 10  # Weights with absolute value <= 30 are destroyed

def snap_beta_to_shift(beta_float):
    """Snaps a continuous float beta to 1 - 2^-k (1 shift-subtractor)."""
    best_diff = float("inf")
    best_shift = 1
    for k in range(1, 8):
        hw_val = 1.0 - (1.0 / (2**k))
        diff = abs(beta_float - hw_val)
        if diff < best_diff:
            best_diff = diff
            best_shift = k
    return best_shift, 1.0 - (1.0 / (2**best_shift))

def run_quantized_inference(model, test_loader, device, num_classes, idx_silence):
    with torch.no_grad():
        w_in_float = model.fc_in.weight.data
        w_rec_float = model.fc_rec.weight.data
        w_out_float = model.fc_out.weight.data

        # --- 1. Percentile Scaling & Quantization ---
        flat_hidden = torch.cat([w_in_float.flatten(), w_rec_float.flatten()]).abs()
        q_max_hid = torch.quantile(flat_hidden, 0.9815)
        scale_hid = 127.0 / q_max_hid

        w_in_q = torch.clamp(torch.round(w_in_float * scale_hid), -127, 127)
        w_rec_q = torch.clamp(torch.round(w_rec_float * scale_hid), -127, 127)
        thresh_hid = int(round(1.0 * scale_hid.item()))

        flat_out = w_out_float.abs().flatten()
        q_max_out = torch.quantile(flat_out, 0.9815)
        scale_out = 127.0 / q_max_out

        w_out_q = torch.clamp(torch.round(w_out_float * scale_out), -127, 127)
        thresh_out = int(round(1.0 * scale_out.item()))

        # --- 2. Brutal Magnitude Pruning ---
        w_in_q[w_in_q.abs() <= PRUNE_MARGIN] = 0
        w_rec_q[w_rec_q.abs() <= PRUNE_MARGIN] = 0
        w_out_q[w_out_q.abs() <= PRUNE_MARGIN] = 0

        # Hardware report
        total_w = w_in_q.numel() + w_rec_q.numel() + w_out_q.numel()
        surviving_w = int((w_in_q != 0).sum() + (w_rec_q != 0).sum() + (w_out_q != 0).sum())
        print(f"\n--- SILICON PRUNING REPORT (Margin: {PRUNE_MARGIN}) ---")
        print(f"Total Weights: {total_w}")
        print(f"Surviving Weights (Adders): {surviving_w} ({(surviving_w/total_w)*100:.1f}%)")
        print(f"Hidden Threshold: {thresh_hid} | Output Threshold: {thresh_out}")

        # Extract & snap betas
        hidden_betas = torch.sigmoid(model.lif_hidden.beta).detach().cpu()
        out_betas = torch.sigmoid(model.lif_out.beta).detach().cpu()

        if hidden_betas.ndim == 0:
            h_shift = snap_beta_to_shift(hidden_betas.item())[0]
            hidden_shifts = [h_shift] * 24
        else:
            hidden_shifts = [snap_beta_to_shift(b.item())[0] for b in hidden_betas]
            
        if out_betas.ndim == 0:
            o_shift = snap_beta_to_shift(out_betas.item())[0]
            out_shifts = [o_shift] * num_classes
        else:
            out_shifts = [snap_beta_to_shift(b.item())[0] for b in out_betas]

    # --- 3. Integer Forward Pass Simulation ---
    correct = 0
    total = 0

    with torch.no_grad():
        for x, y in test_loader:
            x, y = x.to(device), y.to(device)
            batch_size, steps, in_dim = x.shape

            mem_hidden = torch.zeros(batch_size, 24, device=device)
            mem_out = torch.zeros(batch_size, num_classes, device=device)
            spk_hidden = torch.zeros(batch_size, 24, device=device)
            spk_out_total = torch.zeros(batch_size, num_classes, device=device)

            for step in range(steps):
                x_step = x[:, step, :]

                # Synaptic Additions (pure integer accumulation using sparse weights)
                cur_in = torch.matmul(x_step, w_in_q.t())
                cur_rec = torch.matmul(spk_hidden, w_rec_q.t())

                # Hidden Leak (Shift & Subtract)
                for n in range(24):
                    k = hidden_shifts[n]
                    leak = torch.floor(mem_hidden[:, n] / (2**k))
                    mem_hidden[:, n] = mem_hidden[:, n] - leak + cur_in[:, n] + cur_rec[:, n]

                # Threshold & Reset
                spk_hidden = (mem_hidden >= thresh_hid).float()
                mem_hidden = torch.where(spk_hidden.bool(), torch.zeros_like(mem_hidden), mem_hidden)

                # Output Synapses
                cur_out = torch.matmul(spk_hidden, w_out_q.t())

                # Output Leak
                for o in range(num_classes):
                    k_out = out_shifts[o]
                    leak_o = torch.floor(mem_out[:, o] / (2**k_out))
                    mem_out[:, o] = mem_out[:, o] - leak_o + cur_out[:, o]

                spk_out_step = (mem_out >= thresh_out).float()
                mem_out = torch.where(spk_out_step.bool(), torch.zeros_like(mem_out), mem_out)
                spk_out_total += spk_out_step

            # Decision
            max_spikes, raw_preds = spk_out_total.max(dim=1)
            preds = torch.where(max_spikes < 10, torch.tensor(idx_silence, device=device), raw_preds)

            correct += (preds == y).sum().item()
            total += y.size(0)

    acc = (correct / total) * 100
    return acc

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]

    _, test_loader, labels_map = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    idx_silence = labels_map.get("silence", config["num_outputs"] - 1)

    model = FastSpikingNet(
        num_inputs=config["num_inputs"],
        num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"],
        beta=config["beta"]
    ).to(device)

    ckpt_path = os.path.join(TARGET_FOLDER, "model_best.pth")
    checkpoint = torch.load(ckpt_path, map_location=device)
    state_dict = checkpoint["model_state_dict"] if "model_state_dict" in checkpoint else checkpoint
    
    # --- HOTFIX FOR OLD SCALAR BETAS ---
    if "lif_hidden.beta" in state_dict and state_dict["lif_hidden.beta"].ndim == 0:
        state_dict["lif_hidden.beta"] = state_dict["lif_hidden.beta"].expand(config["num_hidden"])
    
    if "lif_out.beta" in state_dict and state_dict["lif_out.beta"].ndim == 0:
        state_dict["lif_out.beta"] = state_dict["lif_out.beta"].expand(config["num_outputs"])

    model.load_state_dict(state_dict)
    
    print(f"Loaded {ckpt_path}")
    print(f"FP Baseline Combined Acc: {checkpoint.get('best_combined_acc', 'N/A')}% | Test Acc: {checkpoint.get('test_acc', 'N/A')}%")

    ptq_acc = run_quantized_inference(
        model, test_loader, device, config["num_outputs"], idx_silence
    )

    print("\n=== PTQ EVALUATION RESULTS ===")
    print(f"Post-Training Quantized + Pruned Test Acc: {ptq_acc:.2f}%")

if __name__ == "__main__":
    main()