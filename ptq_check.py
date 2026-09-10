import os
import torch
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0910_1301_24_neurons"  # Update if using a different folder

# Hardware Integer Scale
V_THRESH_INT = 256.0  # Equivalent to V_th = 1.0 in float

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
    # 1. Quantize Weights to Int8
    # Find scale factor so max absolute weight maps within [-127, 127]
    with torch.no_grad():
        w_in = model.fc_in.weight.data
        w_rec = model.fc_rec.weight.data
        w_out = model.fc_out.weight.data

        # Scale weights relative to integer membrane threshold
        w_in_q = torch.round(w_in * V_THRESH_INT).clamp(-128, 127)
        w_rec_q = torch.round(w_rec * V_THRESH_INT).clamp(-128, 127)
        w_out_q = torch.round(w_out * V_THRESH_INT).clamp(-128, 127)

        # Extract & snap betas
        hidden_betas = torch.sigmoid(model.lif_hidden.beta).detach().cpu()
        out_betas = torch.sigmoid(model.lif_out.beta).detach().cpu()

        # Fix: Handle 0-D (Shared) vs 1-D (Per-Neuron) Beta Tensors
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

    # 2. Integer Forward Pass Simulation
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
                x_step = x[:, step, :]  # Shape: [batch, 7]

                # Synaptic Additions (pure integer accumulation)
                cur_in = torch.matmul(x_step, w_in_q.t())
                cur_rec = torch.matmul(spk_hidden, w_rec_q.t())

                # Hidden Leak (Shift & Subtract)
                for n in range(24):
                    k = hidden_shifts[n]
                    leak = torch.floor(mem_hidden[:, n] / (2**k))
                    mem_hidden[:, n] = mem_hidden[:, n] - leak + cur_in[:, n] + cur_rec[:, n]

                # Threshold & Reset
                spk_hidden = (mem_hidden >= V_THRESH_INT).float()
                mem_hidden = torch.where(spk_hidden.bool(), torch.zeros_like(mem_hidden), mem_hidden)

                # Output Synapses
                cur_out = torch.matmul(spk_hidden, w_out_q.t())

                # Output Leak
                for o in range(num_classes):
                    k_out = out_shifts[o]
                    leak_o = torch.floor(mem_out[:, o] / (2**k_out))
                    mem_out[:, o] = mem_out[:, o] - leak_o + cur_out[:, o]

                spk_out_step = (mem_out >= V_THRESH_INT).float()
                mem_out = torch.where(spk_out_step.bool(), torch.zeros_like(mem_out), mem_out)
                spk_out_total += spk_out_step

            # Decision
            max_spikes, raw_preds = spk_out_total.max(dim=1)
            preds = torch.where(max_spikes < 10, torch.tensor(idx_silence, device=device), raw_preds)

            correct += (preds == y).sum().item()
            total += y.size(0)

    acc = (correct / total) * 100
    return acc, w_in_q, w_rec_q, w_out_q, hidden_shifts, out_shifts

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
    model.load_state_dict(checkpoint["model_state_dict"] if "model_state_dict" in checkpoint else checkpoint)
    print(f"Loaded {ckpt_path}")
    print(f"FP Baseline Combined Acc: {checkpoint.get('best_combined_acc', 'N/A')}% | Test Acc: {checkpoint.get('test_acc', 'N/A')}%")

    ptq_acc, w_in_q, w_rec_q, w_out_q, h_shifts, o_shifts = run_quantized_inference(
        model, test_loader, device, config["num_outputs"], idx_silence
    )

    print("\n=== PTQ EVALUATION RESULTS ===")
    print(f"Post-Training Quantized (int8) Test Acc: {ptq_acc:.2f}%")
    print(f"Hidden Neuron Leak Shifts (k where beta = 1 - 2^-k): {h_shifts}")
    print(f"Output Neuron Leak Shifts: {o_shifts}")

if __name__ == "__main__":
    main()