import os
import random
import torch
import torch.nn as nn
import torchaudio
import torchaudio.transforms as T
from torch.utils.data import DataLoader, Dataset
import snntorch as snn
from snntorch import surrogate
from tqdm import tqdm

LABELS = ["eis", "zwoi", "drü", "vier", "foif", "sächs", "plus", "minus", "noise"]
LABEL_TO_IDX = {lbl: i for i, lbl in enumerate(LABELS)}

class SplitVoiceDataset(Dataset):
    def __init__(self, data_dir, split="train", multiplier=1):
        self.split = split
        self.multiplier = multiplier
        self.files = []
        
        # Enforce strict file split: 1-40 train, 41-50 test
        for label in LABELS:
            folder = os.path.join(data_dir, label)
            if not os.path.isdir(folder):
                continue
            all_wavs = sorted([f for f in os.listdir(folder) if f.endswith(".wav")])
            
            if split == "train":
                selected = all_wavs[:40] # First 40 recordings
            else:
                selected = all_wavs[40:] # Last 10 recordings (pure hold-out test)
                
            for f in selected:
                self.files.append((os.path.join(folder, f), label))
                
        self.mel_transform = T.MelSpectrogram(sample_rate=16000, n_fft=1024, hop_length=512, n_mels=16)
        self.freq_mask = T.FrequencyMasking(freq_mask_param=3)

    def __len__(self):
        return len(self.files) * self.multiplier

    def _augment(self, wav):
        shift = random.randint(-2400, 2400)
        wav = torch.roll(wav, shifts=shift, dims=1)
        wav = wav * random.uniform(0.5, 1.2)
        wav = wav + torch.randn_like(wav) * random.uniform(0.001, 0.015)
        return wav

    def __getitem__(self, idx):
        file_path, label = self.files[idx % len(self.files)]
        wav, _ = torchaudio.load(file_path)
        
        if wav.shape[1] < 16000:
            wav = torch.nn.functional.pad(wav, (0, 16000 - wav.shape[1]))
        else:
            wav = wav[:, :16000]
            
        if self.split == "train":
            wav = self._augment(wav)
            
        mel = self.mel_transform(wav).squeeze(0)
        if self.split == "train" and random.random() > 0.5:
            mel = self.freq_mask(mel)
            
        mel = (mel - mel.mean()) / (mel.std() + 1e-6)
        return mel.T, LABEL_TO_IDX[label]

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

def run():
    train_ds = SplitVoiceDataset("./custom_audio", split="train", multiplier=10)
    test_ds = SplitVoiceDataset("./custom_audio", split="test", multiplier=1)
    
    train_loader = DataLoader(train_ds, batch_size=32, shuffle=True)
    test_loader = DataLoader(test_ds, batch_size=32, shuffle=False)
    
    print(f"Train samples per epoch: {len(train_ds)} | Untouched Test samples: {len(test_ds)}")
    
    model = SpikingNet()
    optimizer = torch.optim.Adam(model.parameters(), lr=8e-4)
    loss_fn = nn.CrossEntropyLoss()
    
    for epoch in range(150):
        model.train()
        total_loss, correct, total = 0, 0, 0
        for x, y in train_loader:
            optimizer.zero_grad()
            out = model(x).sum(dim=1)
            loss = loss_fn(out, y)
            loss.backward()
            optimizer.step()
            total_loss += loss.item()
            correct += (out.argmax(dim=1) == y).sum().item()
            total += y.size(0)
            
        if (epoch + 1) % 10 == 0 or epoch == 149:
            model.eval()
            val_correct, val_total = 0, 0
            with torch.no_grad():
                for x, y in test_loader:
                    out = model(x).sum(dim=1)
                    val_correct += (out.argmax(dim=1) == y).sum().item()
                    val_total += y.size(0)
            print(f"Epoch {epoch+1:02d} | Train Acc: {(correct/total)*100:5.1f}% | Untouched Test Acc: {(val_correct/val_total)*100:5.1f}% | Loss: {total_loss/len(train_loader):.3f}")

    # Final Evaluation Matrix on Test Set
    confusion = torch.zeros(9, 9, dtype=torch.int32)
    model.eval()
    with torch.no_grad():
        for x, y in test_loader:
            preds = model(x).sum(dim=1).argmax(dim=1)
            for true_l, pred_l in zip(y, preds):
                confusion[true_l.item(), pred_l.item()] += 1

    print("\n--- Final Confusion Matrix on Untouched Test Audio ---")
    header = f"{'':>7} | " + " ".join([f"{lbl:>5}" for lbl in LABELS])
    print(header)
    print("-" * len(header))
    for i in range(9):
        row = f"{LABELS[i]:>7} | " + " ".join([f"{confusion[i, j].item():>5}" for j in range(9)])
        print(row)

if __name__ == "__main__":
    run()