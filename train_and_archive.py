import os
import json
import datetime
import random
import torch
import torch.nn as nn
import torchaudio
import torchaudio.transforms as T
from torch.utils.data import DataLoader, Dataset
import snntorch as snn
from snntorch import surrogate
from tqdm import tqdm

# ==========================================
# 1. EXPERIMENT HYPERPARAMETERS & CONFIG
# ==========================================
EXP_LABEL = "temporal_125step_beta92"  # Set your experiment tag here

CONFIG = {
    "exp_label": EXP_LABEL,
    "sample_rate": 16000,
    "n_mels": 16,
    "n_fft": 512,
    "hop_length": 128,          # 16000 / 128 = 125 time steps per 1.0s window
    "num_hidden": 40,
    "num_outputs": 9,
    "beta": 0.88,               # Tuned for finer temporal resolution
    "epochs": 80,
    "batch_size": 32,
    "lr": 8e-4,
    "train_multiplier": 10,     # 10x virtual augmentation per epoch
    "train_split_per_class": 40,# Files 1-40 for training
    "test_split_per_class": 10  # Files 41-50 for pure holdout
}

LABELS = ["eis", "zwoi", "drü", "vier", "foif", "sächs", "plus", "minus", "noise"]
LABEL_TO_IDX = {lbl: i for i, lbl in enumerate(LABELS)}

# ==========================================
# 2. DATASET & AUGMENTATION
# ==========================================
class HighResVoiceDataset(Dataset):
    def __init__(self, data_dir, split="train", cfg=CONFIG):
        self.split = split
        self.cfg = cfg
        self.multiplier = cfg["train_multiplier"] if split == "train" else 1
        self.files = []

        for label in LABELS:
            folder = os.path.join(data_dir, label)
            if not os.path.isdir(folder):
                continue
            wavs = sorted([f for f in os.listdir(folder) if f.endswith(".wav")])
            
            if split == "train":
                selected = wavs[:cfg["train_split_per_class"]]
            else:
                selected = wavs[cfg["train_split_per_class"]:]
                
            for f in selected:
                self.files.append((os.path.join(folder, f), label))

        self.mel_transform = T.MelSpectrogram(
            sample_rate=cfg["sample_rate"],
            n_fft=cfg["n_fft"],
            hop_length=cfg["hop_length"],
            n_mels=cfg["n_mels"]
        )
        self.freq_mask = T.FrequencyMasking(freq_mask_param=2)

    def __len__(self):
        return len(self.files) * self.multiplier

    def _augment(self, wav):
        # 1. Random Time Roll (-150ms to +150ms)
        shift = random.randint(-2400, 2400)
        wav = torch.roll(wav, shifts=shift, dims=1)
        
        # 2. Volume Scale
        wav = wav * random.uniform(0.4, 1.2)
        
        # 3. PDM Noise Injection
        wav = wav + torch.randn_like(wav) * random.uniform(0.001, 0.012)
        return wav

    def __getitem__(self, idx):
        file_path, label = self.files[idx % len(self.files)]
        wav, _ = torchaudio.load(file_path)

        if wav.shape[1] < self.cfg["sample_rate"]:
            wav = torch.nn.functional.pad(wav, (0, self.cfg["sample_rate"] - wav.shape[1]))
        else:
            wav = wav[:, :self.cfg["sample_rate"]]

        if self.split == "train":
            wav = self._augment(wav)

        mel = self.mel_transform(wav).squeeze(0)

        if self.split == "train" and random.random() > 0.5:
            mel = self.freq_mask(mel)

        mel = (mel - mel.mean()) / (mel.std() + 1e-6)
        return mel.T, LABEL_TO_IDX[label]

# ==========================================
# 3. SNN ARCHITECTURE
# ==========================================
class SpikingNet(nn.Module):
    def __init__(self, cfg=CONFIG):
        super().__init__()
        sg = surrogate.fast_sigmoid(slope=25)
        self.fc1 = nn.Linear(cfg["n_mels"], cfg["num_hidden"])
        self.lif1 = snn.Leaky(beta=cfg["beta"], spike_grad=sg)
        self.fc2 = nn.Linear(cfg["num_hidden"], cfg["num_outputs"])
        self.lif2 = snn.Leaky(beta=cfg["beta"], spike_grad=sg)

    def forward(self, x):
        m1, m2 = self.lif1.init_leaky(), self.lif2.init_leaky()
        spk_rec = []
        for t in range(x.size(1)):
            s1, m1 = self.lif1(self.fc1(x[:, t, :]), m1)
            s2, m2 = self.lif2(self.fc2(s1), m2)
            spk_rec.append(s2)
        return torch.stack(spk_rec, dim=1)

# ==========================================
# 4. TRAINING & COMPLETE ARCHIVE PIPELINE
# ==========================================
def main():
    device = torch.device("cpu")
    
    # 1. Setup Experiment Directory
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    exp_dir = os.path.join("experiments", f"{timestamp}_{CONFIG['exp_label']}")
    os.makedirs(exp_dir, exist_ok=True)
    
    print(f"=== Initializing Experiment: {CONFIG['exp_label']} ===")
    print(f"Artifact directory: {exp_dir}\n")

    train_ds = HighResVoiceDataset("./custom_audio", split="train")
    test_ds = HighResVoiceDataset("./custom_audio", split="test")

    train_loader = DataLoader(train_ds, batch_size=CONFIG["batch_size"], shuffle=True)
    test_loader = DataLoader(test_ds, batch_size=CONFIG["batch_size"], shuffle=False)

    sample_x, _ = train_ds[0]
    CONFIG["computed_time_steps"] = sample_x.shape[0]
    print(f"Time steps per 1.0s window: {CONFIG['computed_time_steps']}")
    print(f"Train virtual size: {len(train_ds)} | Untouched Test size: {len(test_ds)}")

    model = SpikingNet().to(device)
    optimizer = torch.optim.Adam(model.parameters(), lr=CONFIG["lr"])
    loss_fn = nn.CrossEntropyLoss()

    # 2. Train Loop
    for epoch in range(CONFIG["epochs"]):
        model.train()
        total_loss, correct, total = 0, 0, 0
        for x, y in train_loader:
            x, y = x.to(device), y.to(device)
            optimizer.zero_grad()
            out = model(x).sum(dim=1)
            loss = loss_fn(out, y)
            loss.backward()
            optimizer.step()

            total_loss += loss.item()
            correct += (out.argmax(dim=1) == y).sum().item()
            total += y.size(0)

        if (epoch + 1) % 10 == 0 or epoch == CONFIG["epochs"] - 1:
            model.eval()
            val_correct, val_total = 0, 0
            with torch.no_grad():
                for x, y in test_loader:
                    x, y = x.to(device), y.to(device)
                    out = model(x).sum(dim=1)
                    val_correct += (out.argmax(dim=1) == y).sum().item()
                    val_total += y.size(0)
            print(f"Epoch {epoch+1:02d}/{CONFIG['epochs']} | Train: {(correct/total)*100:5.1f}% | Untouched Test: {(val_correct/val_total)*100:5.1f}% | Loss: {total_loss/len(train_loader):.3f}")

    # 3. Deep Evaluation & Confidence Mapping
    model.eval()
    confusion = torch.zeros(9, 9, dtype=torch.int32)
    confidence_data = []

    with torch.no_grad():
        for x, y in test_loader:
            x, y = x.to(device), y.to(device)
            spk_out = model(x)
            spike_counts = spk_out.sum(dim=1)

            sorted_spikes, indices = torch.sort(spike_counts, dim=1, descending=True)
            top1_spikes = sorted_spikes[:, 0]
            top2_spikes = sorted_spikes[:, 1]
            pred = indices[:, 0]
            margins = top1_spikes - top2_spikes

            for i in range(len(y)):
                true_lbl = y[i].item()
                pred_lbl = pred[i].item()
                confusion[true_lbl, pred_lbl] += 1 # type: ignore
                confidence_data.append({
                    "correct": true_lbl == pred_lbl,
                    "top_spikes": top1_spikes[i].item(),
                    "margin": margins[i].item()
                })

    # 4. Spike Margin Threshold Sweeps (Dynamic Step Scale)
    threshold_results = {}
    total_samples = len(confidence_data)
    
    # Margin sweep increments scaled for higher temporal resolution
    margin_steps = [0, 2, 5, 10, 15, 20, 25, 30]
    
    print("\n--- Spike Margin Threshold Report ---")
    print(f"{'Required Margin':<18} | {'Retention (Not Rejected)':<25} | {'Accuracy on Retained':<20}")
    print("-" * 70)
    for m in margin_steps:
        retained = [d for d in confidence_data if d["margin"] >= m]
        if not retained:
            break
        correct_count = sum(1 for d in retained if d["correct"])
        retention_rate = (len(retained) / total_samples) * 100
        acc_retained = (correct_count / len(retained)) * 100

        print(f">= {m:>2} spikes diff    | {len(retained):>3}/{total_samples} retained ({retention_rate:>5.1f}%) | {acc_retained:>5.1f}%")
        threshold_results[f"margin_{m}"] = {
            "retained_count": len(retained),
            "retention_pct": round(retention_rate, 2),
            "accuracy_pct": round(acc_retained, 2)
        }

    # 5. Archive Checkpoint and JSON Manifest
    model_save_path = os.path.join(exp_dir, "model.pth")
    torch.save(model.state_dict(), model_save_path)

    metrics_payload = {
        "timestamp": timestamp,
        "config": CONFIG,
        "labels": LABELS,
        "base_accuracy": threshold_results["margin_0"]["accuracy_pct"],
        "confusion_matrix": confusion.tolist(),
        "threshold_analysis": threshold_results
    }

    json_save_path = os.path.join(exp_dir, "config_and_metrics.json")
    with open(json_save_path, "w") as f:
        json.dump(metrics_payload, f, indent=4)

    print(f"\nSaved experiment artifacts successfully:")
    print(f" - Model:   {model_save_path}")
    print(f" - Metrics: {json_save_path}")

if __name__ == "__main__":
    main()