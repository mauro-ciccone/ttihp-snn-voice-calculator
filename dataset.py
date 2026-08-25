import os
import random
import torch
import torchaudio
import torchaudio.transforms as T
from torch.utils.data import Dataset, DataLoader

class PDMCochleaDataset(Dataset):
    def __init__(self, file_list, labels_map, is_train=True, train_multiplier=10):
        self.file_list = file_list
        self.labels_map = labels_map
        self.is_train = is_train
        self.train_multiplier = train_multiplier if is_train else 1
        
        # We define 8 different decay rates (tau) for the Silicon Cochlea
        # Fast leaks (high freq) to Slow leaks (low freq/envelope)
        self.decays = torch.tensor([0.1, 0.2, 0.4, 0.6, 0.8, 0.9, 0.95, 0.99])
        
    def _augment(self, waveform):
        # Time shift +/- 5%
        shift = random.randint(-800, 800)
        waveform = torch.roll(waveform, shifts=shift, dims=-1)
        
        # Volume jitter
        scale = random.uniform(0.7, 1.3)
        waveform = waveform * scale
        
        # Subtle Gaussian noise
        noise = torch.randn_like(waveform) * 0.02
        waveform = waveform + noise
        
        return waveform

    def _simulate_pdm_cochlea(self, waveform):
        wave_1m = torch.nn.functional.interpolate(
            waveform.unsqueeze(0), size=1000000, mode='linear', align_corners=False
        ).squeeze()
        
        wave_norm = (wave_1m + 1.0) / 2.0  
        pdm_bits = torch.bernoulli(wave_norm.clamp(0.0, 1.0))
        
        timesteps = 500
        pdm_chunks = pdm_bits.view(timesteps, 2000)
        
        # Up/Down counter per chunk: PDM 1 adds +1, PDM 0 subtracts -1 (removes DC bias)
        chunk_energy = (pdm_chunks.sum(dim=1) - 1000.0).clamp(min=0.0)
        
        cochlea_spikes = torch.zeros((timesteps, 8))
        membrane = torch.zeros(8)
        
        # 8 distinct hardware leak rates and thresholds for frequency bands
        decays = torch.tensor([0.1, 0.3, 0.5, 0.7, 0.8, 0.9, 0.95, 0.99])
        thresholds = torch.tensor([50.0, 100.0, 200.0, 400.0, 600.0, 800.0, 1000.0, 1200.0])
        
        for t in range(timesteps):
            # Accumulate energy into membrane with individual channel leaks
            membrane = (membrane * decays) + chunk_energy[t]
            
            # Fire condition
            fired = membrane >= thresholds
            cochlea_spikes[t, fired] = 1.0
            
            # HARD RESET: Subtract threshold (or reset to 0) upon firing
            membrane[fired] -= thresholds[fired] 
            
        return cochlea_spikes

    def __len__(self):
        return len(self.file_list) * self.train_multiplier

    def __getitem__(self, idx):
        real_idx = idx % len(self.file_list)
        file_path, label_str = self.file_list[real_idx]
        label = self.labels_map[label_str]

        waveform, sr = torchaudio.load(file_path)
        
        # Resample to 16kHz if needed
        if sr != 16000:
            resampler = T.Resample(sr, 16000)
            waveform = resampler(waveform)

        # Force mono
        if waveform.shape[0] > 1:
            waveform = torch.mean(waveform, dim=0, keepdim=True)

        # Pad / crop to exactly 1 second (16000 samples)
        if waveform.shape[-1] < 16000:
            pad_amount = 16000 - waveform.shape[-1]
            waveform = torch.nn.functional.pad(waveform, (0, pad_amount))
        else:
            waveform = waveform[:, :16000]

        if self.is_train:
            waveform = self._augment(waveform)

        # Run the hardware simulation
        # Returns a tensor of shape [1000, 8] containing pure 1s and 0s
        cochlea_spikes = self._simulate_pdm_cochlea(waveform)

        return cochlea_spikes, label


def get_dataloaders(config, data_dir="data", test_split_pct=0.2):
    labels = sorted([d for d in os.listdir(data_dir) if os.path.isdir(os.path.join(data_dir, d)) and not d.startswith(".")])
    if "noise" in labels:
        labels.remove("noise")
        labels.append("noise")
    labels_map = {lbl: i for i, lbl in enumerate(labels)}

    train_files = []
    test_files = []

    for lbl in labels:
        lbl_dir = os.path.join(data_dir, lbl)
        files = [os.path.join(lbl_dir, f) for f in os.listdir(lbl_dir) if f.endswith(".wav")]
        random.shuffle(files)
        
        split_idx = int(len(files) * (1.0 - test_split_pct))
        train_files.extend([(f, lbl) for f in files[:split_idx]])
        test_files.extend([(f, lbl) for f in files[split_idx:]])

    train_dataset = PDMCochleaDataset(
        file_list=train_files,
        labels_map=labels_map,
        is_train=True,
        train_multiplier=config.get("train_multiplier", 10)
    )

    test_dataset = PDMCochleaDataset(
        file_list=test_files,
        labels_map=labels_map,
        is_train=False,
        train_multiplier=1
    )

    batch_size = config.get("batch_size", 32)
    
    # Num_workers=4 will utilize your M4 cores to generate the PDM streams in parallel
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True, num_workers=4)
    test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False, num_workers=4)

    return train_loader, test_loader, labels_map