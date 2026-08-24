import os
import random
import torch
import torch.nn as nn
import torchaudio
import torchaudio.transforms as T
from torch.utils.data import DataLoader, Dataset, random_split
import snntorch as snn
from snntorch import surrogate
from tqdm import tqdm

# --- 1. Custom Dataset & Hardware Augmentation ---
class CustomVoiceDataset(Dataset):
    # ADDED: multiplier parameter to virtually expand the dataset
    def __init__(self, data_dir, augment=False, n_mels=16, multiplier=1):
        self.data_dir = data_dir
        self.augment = augment
        self.multiplier = multiplier # Multiplies dataset size
        
        # Updated Swiss German Labels
        self.labels = ["eis", "zwoi", "drü", "vier", "foif", "sächs", "plus", "minus", "noise"]
        self.label_to_idx = {lbl: i for i, lbl in enumerate(self.labels)}
        
        self.files = []
        for label in self.labels:
            folder_path = os.path.join(data_dir, label)
            if os.path.isdir(folder_path):
                for f in os.listdir(folder_path):
                    if f.endswith(".wav"):
                        self.files.append((os.path.join(folder_path, f), label))
                        
        print(f"Loaded {len(self.files)} physical audio files. Virtual dataset size: {len(self.files) * self.multiplier}.")

        self.mel_transform = T.MelSpectrogram(
            sample_rate=16000, n_fft=1024, hop_length=512, n_mels=n_mels
        )
        self.freq_mask = T.FrequencyMasking(freq_mask_param=3) 

    def __len__(self):
        # Virtually expand the dataset length
        return len(self.files) * self.multiplier

    def _augment_waveform(self, waveform):
        shift_amt = random.randint(-2400, 2400)
        waveform = torch.roll(waveform, shifts=shift_amt, dims=1)
        
        vol_scale = random.uniform(0.4, 1.2)
        waveform = waveform * vol_scale
        
        noise_amp = random.uniform(0.001, 0.015)
        noise = torch.randn_like(waveform) * noise_amp
        waveform = waveform + noise
        return waveform

    def __getitem__(self, idx):
        # Modulo arithmetic wraps the index back around to the physical files
        actual_idx = idx % len(self.files)
        file_path, label_str = self.files[actual_idx]
        
        waveform, _ = torchaudio.load(file_path)
        
        if waveform.shape[1] < 16000:
            waveform = torch.nn.functional.pad(waveform, (0, 16000 - waveform.shape[1]))
        else:
            waveform = waveform[:, :16000]

        if self.augment:
            waveform = self._augment_waveform(waveform)
            
        mel_spec = self.mel_transform(waveform).squeeze(0)
        
        if self.augment and random.random() > 0.5:
            mel_spec = self.freq_mask(mel_spec)
            
        mel_spec = (mel_spec - mel_spec.mean()) / (mel_spec.std() + 1e-6)
        
        return mel_spec.T, self.label_to_idx[label_str]


# --- 2. 40-Neuron Architecture ---
class CustomSpikingNet(nn.Module):
    def __init__(self, num_inputs=16, num_hidden=40, num_outputs=9):
        super().__init__()
        spike_grad = surrogate.fast_sigmoid(slope=25)
        
        self.fc1 = nn.Linear(num_inputs, num_hidden)
        self.lif1 = snn.Leaky(beta=0.85, spike_grad=spike_grad)
        
        self.fc2 = nn.Linear(num_hidden, num_outputs)
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


# --- 3. Training Loop & Diagnostics ---
def train_custom():
    device = torch.device("cpu")
    
    # Enable heavy augmentation for training, disable for pure validation
    # Multiply training data by 10. Keep validation at 1 to evaluate pure unaugmented performance.
    full_dataset = CustomVoiceDataset("./custom_audio", augment=True, multiplier=10)
    val_dataset = CustomVoiceDataset("./custom_audio", augment=False, multiplier=1)
    
    train_size = int(0.85 * len(full_dataset))
    val_size = len(full_dataset) - train_size
    
    # Ensure same split indices for both
    generator = torch.Generator().manual_seed(42)
    train_indices, val_indices = random_split(range(len(full_dataset)), [train_size, val_size], generator=generator)
    
    train_set = torch.utils.data.Subset(full_dataset, train_indices)
    val_set = torch.utils.data.Subset(val_dataset, val_indices)

    train_loader = DataLoader(train_set, batch_size=32, shuffle=True)
    val_loader = DataLoader(val_set, batch_size=32, shuffle=False)

    model = CustomSpikingNet().to(device)
    # Lower the learning rate from 1e-3 to 5e-4
    optimizer = torch.optim.Adam(model.parameters(), lr=5e-4)
    loss_fn = nn.CrossEntropyLoss()

    print("\nTraining on heavily augmented custom data (100 Epochs)...")
    for epoch in range(100):  # Bump to 100 epochs
        model.train()
        total_loss, correct, total = 0, 0, 0
        for x, y in tqdm(train_loader, desc=f"Epoch {epoch+1}/50", leave=False):
            x, y = x.to(device), y.to(device)
            optimizer.zero_grad()
            spk_out = model(x)
            spike_counts = spk_out.sum(dim=1)
            loss = loss_fn(spike_counts, y)
            loss.backward()
            optimizer.step()
            
            total_loss += loss.item()
            correct += (spike_counts.argmax(dim=1) == y).sum().item()
            total += y.size(0)
            
        train_acc = (correct / total) * 100
        
        # Quick validation check
        model.eval()
        val_correct, val_total = 0, 0
        with torch.no_grad():
            for x, y in val_loader:
                x, y = x.to(device), y.to(device)
                spk_out = model(x)
                val_correct += (spk_out.sum(dim=1).argmax(dim=1) == y).sum().item()
                val_total += y.size(0)
        
        print(f"Epoch {epoch+1} | Train: {train_acc:.1f}% | Val: {(val_correct/val_total)*100:.1f}% | Loss: {total_loss/len(train_loader):.3f}")

    print("\n--- Final Validation Confusion Matrix ---")
    model.eval()
    confusion = torch.zeros(9, 9, dtype=torch.int32)
    with torch.no_grad():
        for x, y in val_loader:
            x, y = x.to(device), y.to(device)
            pred = model(x).sum(dim=1).argmax(dim=1)
            for i in range(len(y)):
                confusion[y[i].item(), pred[i].item()] += 1

    labels = full_dataset.labels
    header = f"{'':>7} | " + " ".join([f"{lbl:>5}" for lbl in labels])
    print(header)
    print("-" * len(header))
    for i in range(9):
        row_str = f"{labels[i]:>7} | "
        for j in range(9):
            row_str += f"{confusion[i, j].item():>5} "
        print(row_str)

    torch.save(model.state_dict(), "custom_calculator_snn.pth")
    print("\nModel saved to 'custom_calculator_snn.pth'.")

if __name__ == "__main__":
    train_custom()