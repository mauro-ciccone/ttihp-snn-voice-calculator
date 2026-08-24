import torch
import torch.nn as nn
import torchaudio.transforms as T
from torch.utils.data import DataLoader, random_split, Dataset
import snntorch as snn
from snntorch import surrogate
from tqdm import tqdm

# --- 1. Dataset ---
class CalculatorDataset(Dataset):
    def __init__(self):
        self.data = torch.load("./data/calculator_dataset_constrained.pt")
        self.labels = ["one", "two", "three", "four", "five", "six", "left", "right"]
        self.label_to_idx = {word: i for i, word in enumerate(self.labels)}
        self.mel_transform = T.MelSpectrogram(sample_rate=16000, n_fft=1024, hop_length=512, n_mels=16)

    def __len__(self): return len(self.data)

    def __getitem__(self, idx):
        waveform, _, label_str = self.data[idx]
        if waveform.shape[1] < 16000:
            waveform = torch.nn.functional.pad(waveform, (0, 16000 - waveform.shape[1]))
        else:
            waveform = waveform[:, :16000]
            
        mel_spec = self.mel_transform(waveform).squeeze(0)
        mel_spec = (mel_spec - mel_spec.mean()) / (mel_spec.std() + 1e-6)
        return mel_spec.T, self.label_to_idx[label_str]

# --- 2. Model ---
class SpikingVoiceNet(nn.Module):
    def __init__(self):
        super().__init__()
        spike_grad = surrogate.fast_sigmoid(slope=25)
        self.fc1 = nn.Linear(16, 40)
        self.lif1 = snn.Leaky(beta=0.85, spike_grad=spike_grad)
        self.fc2 = nn.Linear(40, 8)
        self.lif2 = snn.Leaky(beta=0.85, spike_grad=spike_grad)

    def forward(self, x):
        mem1 = self.lif1.init_leaky()
        mem2 = self.lif2.init_leaky()
        spk2_rec = []
        for t in range(x.size(1)):
            spk1, mem1 = self.lif1(self.fc1(x[:, t, :]), mem1)
            spk2, mem2 = self.lif2(self.fc2(spk1), mem2)
            spk2_rec.append(spk2)
        return torch.stack(spk2_rec, dim=1)

# --- 3. Training & Deep Diagnostics ---
def run_diagnostics():
    device = torch.device("cpu")
    dataset = CalculatorDataset()
    train_size = int(0.85 * len(dataset))
    val_size = len(dataset) - train_size
    train_set, val_set = random_split(dataset, [train_size, val_size])

    train_loader = DataLoader(train_set, batch_size=64, shuffle=True)
    val_loader = DataLoader(val_set, batch_size=64, shuffle=False)

    model = SpikingVoiceNet().to(device)
    optimizer = torch.optim.Adam(model.parameters(), lr=2e-3)
    loss_fn = nn.CrossEntropyLoss()

    print("Fast-training model to plateau (25 Epochs)...")
    for epoch in range(40):
        model.train()
        for x, y in tqdm(train_loader, desc=f"Epoch {epoch+1}/25", leave=False):
            x, y = x.to(device), y.to(device)
            optimizer.zero_grad()
            spk_out = model(x)
            loss = loss_fn(spk_out.sum(dim=1), y)
            loss.backward()
            optimizer.step()

    print("\n--- Running Deep Diagnostics on Validation Set ---")
    model.eval()
    
    # Trackers
    labels = dataset.labels
    confusion = torch.zeros(8, 8, dtype=torch.int32)
    confidence_data = [] # Stores: (is_correct, max_spikes, margin)

    with torch.no_grad():
        for x, y in val_loader:
            x, y = x.to(device), y.to(device)
            spk_out = model(x)
            spike_counts = spk_out.sum(dim=1) # Total spikes per class
            
            # Find Top 1 and Top 2 spiking neurons to calculate Margin
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
                    'correct': true_lbl == pred_lbl,
                    'spikes': top1_spikes[i].item(),
                    'margin': margins[i].item()
                })

    # 1. Print Confusion Matrix
    print("\n[1] CONFUSION MATRIX (Rows: Actual, Columns: Predicted)")
    header = f"{'':>7} | " + " ".join([f"{lbl:>5}" for lbl in labels])
    print(header)
    print("-" * len(header))
    for i in range(8):
        row_str = f"{labels[i]:>7} | "
        for j in range(8):
            val = confusion[i, j].item()
            row_str += f"{val:>5} "
        print(row_str)

    # 2. Print Confidence / Margin Thresholding
    print("\n[2] CONFIDENCE THRESHOLDING (Spike Margin)")
    print("If we reject inputs where the winner doesn't beat the runner-up by X spikes:")
    print(f"{'Required Margin':<18} | {'Retention (Not Rejected)':<25} | {'Accuracy on Retained':<20}")
    print("-" * 70)
    
    total_val = len(confidence_data)
    for margin_thresh in range(0, 6):
        retained = [d for d in confidence_data if d['margin'] >= margin_thresh]
        if not retained:
            break
            
        correct_retained = sum(1 for d in retained if d['correct'])
        retention_rate = (len(retained) / total_val) * 100
        acc_retained = (correct_retained / len(retained)) * 100
        
        print(f">= {margin_thresh} spikes difference | {len(retained)}/{total_val} retained ({retention_rate:>5.1f}%) | {acc_retained:>5.1f}%")

if __name__ == "__main__":
    run_diagnostics()