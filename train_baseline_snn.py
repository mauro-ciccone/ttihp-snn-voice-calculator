import torch
import torch.nn as nn
import torchaudio.transforms as T
from torch.utils.data import DataLoader, random_split, Dataset
import snntorch as snn
from snntorch import surrogate
from tqdm import tqdm

# --- 1. Dataset & Pre-processing ---
class CalculatorDataset(Dataset):
    def __init__(self, pt_path, n_mels=16):
        self.data = torch.load("./data/calculator_dataset_constrained.pt") # New file
        self.labels = [
            "one", "two", "three", "four", "five", "six", "left", "right" # New labels
        ]
        self.label_to_idx = {word: i for i, word in enumerate(self.labels)}
        
        # 16 Mel bins to mimic a small biological cochlea / filter bank
        self.mel_transform = T.MelSpectrogram(
            sample_rate=16000,
            n_fft=1024,
            hop_length=512,
            n_mels=n_mels
        )

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        waveform, sample_rate, label_str = self.data[idx]
        
        # Normalize audio length to 1 second (16000 samples)
        if waveform.shape[1] < 16000:
            waveform = torch.nn.functional.pad(waveform, (0, 16000 - waveform.shape[1]))
        else:
            waveform = waveform[:, :16000]
            
        # Convert to Mel Spectrogram (Shape: [16, ~32 time steps])
        mel_spec = self.mel_transform(waveform).squeeze(0)
        
        # Normalize energy and transpose to (time_steps, n_mels)
        mel_spec = (mel_spec - mel_spec.mean()) / (mel_spec.std() + 1e-6)
        x = mel_spec.T  # Shape: (T, 16)
        
        y = self.label_to_idx[label_str]
        return x, y

# --- 2. SNN Model Architecture ---
class SpikingVoiceNet(nn.Module):
    def __init__(self, num_inputs=16, num_hidden=40, num_outputs=12, beta=0.85):
        super().__init__()
        spike_grad = surrogate.fast_sigmoid(slope=25)
        
        self.fc1 = nn.Linear(num_inputs, num_hidden)
        self.lif1 = snn.Leaky(beta=beta, spike_grad=spike_grad)
        
        self.fc2 = nn.Linear(num_hidden, num_outputs)
        self.lif2 = snn.Leaky(beta=beta, spike_grad=spike_grad)

    def forward(self, x):
        # x shape: (batch_size, time_steps, num_inputs)
        batch_size, time_steps, _ = x.shape
        mem1 = self.lif1.init_leaky()
        mem2 = self.lif2.init_leaky()
        
        spk2_rec = []
        for t in range(time_steps):
            cur1 = self.fc1(x[:, t, :])
            spk1, mem1 = self.lif1(cur1, mem1)
            cur2 = self.fc2(spk1)
            spk2, mem2 = self.lif2(cur2, mem2)
            spk2_rec.append(spk2)
            
        # Stack spikes over time: (batch_size, time_steps, num_outputs)
        return torch.stack(spk2_rec, dim=1)

# --- 3. Training & Evaluation Pipeline ---
def train():
    #device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    device = torch.device("cpu")
    print(f"Using compute device: {device}")

    dataset = CalculatorDataset("./data/calculator_dataset.pt", n_mels=16)
    train_size = int(0.85 * len(dataset))
    val_size = len(dataset) - train_size
    train_set, val_set = random_split(dataset, [train_size, val_size])

    train_loader = DataLoader(train_set, batch_size=64, shuffle=True)
    val_loader = DataLoader(val_set, batch_size=64, shuffle=False)

    model = SpikingVoiceNet(num_inputs=16, num_hidden=40, num_outputs=8).to(device)
    optimizer = torch.optim.Adam(model.parameters(), lr=2e-3)
    loss_fn = nn.CrossEntropyLoss()

    print(f"Model parameters: {sum(p.numel() for p in model.parameters() if p.requires_grad)}")
    print("Beginning baseline training (5 epochs)...\n")

    for epoch in range(50):
        model.train()
        total_loss = 0
        correct = 0
        total = 0

        for x, y in tqdm(train_loader, desc=f"Epoch {epoch+1}/5"):
            x, y = x.to(device), y.to(device)
            optimizer.zero_grad()

            spk_out = model(x) # (B, T, 12)
            spike_counts = spk_out.sum(dim=1) # Rate coding: total spikes per word

            loss = loss_fn(spike_counts, y)
            loss.backward()
            optimizer.step()

            total_loss += loss.item()
            pred = spike_counts.argmax(dim=1)
            correct += (pred == y).sum().item()
            total += y.size(0)

        train_acc = (correct / total) * 100

        # Validation pass
        model.eval()
        val_correct = 0
        val_total = 0
        with torch.no_grad():
            for x, y in val_loader:
                x, y = x.to(device), y.to(device)
                spk_out = model(x)
                spike_counts = spk_out.sum(dim=1)
                pred = spike_counts.argmax(dim=1)
                val_correct += (pred == y).sum().item()
                val_total += y.size(0)

        val_acc = (val_correct / val_total) * 100
        print(f"Epoch {epoch+1} Summary -> Train Acc: {train_acc:.2f}% | Val Acc: {val_acc:.2f}% | Loss: {total_loss/len(train_loader):.4f}")

if __name__ == "__main__":
    train()