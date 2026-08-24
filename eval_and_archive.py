import os
import json
import datetime
import torch
import torch.nn as nn
import torchaudio
import torchaudio.transforms as T
from torch.utils.data import DataLoader, Dataset
import snntorch as snn
from snntorch import surrogate

# --- Configuration ---
LABELS = ["eis", "zwoi", "drü", "vier", "foif", "sächs", "plus", "minus", "noise"]
LABEL_TO_IDX = {lbl: i for i, lbl in enumerate(LABELS)}
MODEL_PATH = "custom_calculator_snn.pth"

# --- 1. Untouched Test Dataset ---
class SplitVoiceDataset(Dataset):
    def __init__(self, data_dir):
        self.files = []
        for label in LABELS:
            folder = os.path.join(data_dir, label)
            if not os.path.isdir(folder): continue
            all_wavs = sorted([f for f in os.listdir(folder) if f.endswith(".wav")])
            # Strictly the last 10 unseen files
            for f in all_wavs[40:]:
                self.files.append((os.path.join(folder, f), label))
                
        self.mel_transform = T.MelSpectrogram(sample_rate=16000, n_fft=1024, hop_length=512, n_mels=16)

    def __len__(self): return len(self.files)

    def __getitem__(self, idx):
        file_path, label = self.files[idx]
        wav, _ = torchaudio.load(file_path)
        if wav.shape[1] < 16000:
            wav = torch.nn.functional.pad(wav, (0, 16000 - wav.shape[1]))
        else:
            wav = wav[:, :16000]
        mel = self.mel_transform(wav).squeeze(0)
        mel = (mel - mel.mean()) / (mel.std() + 1e-6)
        return mel.T, LABEL_TO_IDX[label]

# --- 2. SNN Architecture ---
class SpikingNet(nn.Module):
    def __init__(self):
        super().__init__()
        sg = surrogate.fast_sigmoid(slope=25)
        self.fc1 = nn.Linear(16, 40)
        self.lif1 = snn.Leaky(beta=0.85, spike_grad=sg)
        self.fc2 = nn.Linear(40, 9)
        self.lif2 = snn.Leaky(beta=0.85, spike_grad=sg)

    def forward(self, x):
        m1, m2 = self.lif1.init_leaky(), self.lif2.init_leaky()
        spk_rec = []
        for t in range(x.size(1)):
            s1, m1 = self.lif1(self.fc1(x[:, t, :]), m1)
            s2, m2 = self.lif2(self.fc2(s1), m2)
            spk_rec.append(s2)
        return torch.stack(spk_rec, dim=1)

def run_diagnostics():
    test_ds = SplitVoiceDataset("./custom_audio")
    test_loader = DataLoader(test_ds, batch_size=32, shuffle=False)
    
    model = SpikingNet()
    model.load_state_dict(torch.load(MODEL_PATH))
    model.eval()
    
    confusion = torch.zeros(9, 9, dtype=torch.int32)
    confidence_data = []
    
    print("Running deep margin diagnostics on untouched test set...")
    with torch.no_grad():
        for x, y in test_loader:
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
                confusion[true_lbl, pred_lbl] += 1
                
                confidence_data.append({
                    'true_label': LABELS[true_lbl],
                    'pred_label': LABELS[pred_lbl],
                    'correct': true_lbl == pred_lbl,
                    'top_spikes': top1_spikes[i].item(),
                    'margin': margins[i].item()
                })

    # --- Print & Log Thresholds ---
    print("\n[CONFIDENCE THRESHOLDING (Spike Margin)]")
    print(f"{'Required Margin':<18} | {'Retention (Not Rejected)':<25} | {'Accuracy on Retained':<20}")
    print("-" * 70)
    
    threshold_logs = {}
    total_val = len(confidence_data)
    
    for margin_thresh in range(0, 7):
        retained = [d for d in confidence_data if d['margin'] >= margin_thresh]
        if not retained: break
            
        correct_retained = sum(1 for d in retained if d['correct'])
        retention_rate = (len(retained) / total_val) * 100
        acc_retained = (correct_retained / len(retained)) * 100
        
        print(f">= {margin_thresh} spikes diff   | {len(retained):>3}/{total_val} retained ({retention_rate:>5.1f}%) | {acc_retained:>5.1f}%")
        
        threshold_logs[f"margin_{margin_thresh}"] = {
            "retention_pct": round(retention_rate, 2),
            "accuracy_pct": round(acc_retained, 2)
        }

    # --- Archive to JSON ---
    os.makedirs("experiments", exist_ok=True)
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    base_acc = threshold_logs["margin_0"]["accuracy_pct"]
    log_filename = f"experiments/eval_{timestamp}_acc{int(base_acc)}.json"
    
    experiment_data = {
        "timestamp": timestamp,
        "model": MODEL_PATH,
        "base_accuracy": base_acc,
        "confusion_matrix": confusion.tolist(),
        "labels": LABELS,
        "thresholds": threshold_logs
    }
    
    with open(log_filename, 'w') as f:
        json.dump(experiment_data, f, indent=4)
        
    print(f"\nExperiment archived to: {log_filename}")

if __name__ == "__main__":
    run_diagnostics()