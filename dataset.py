import os
import random
import torch
import torchaudio
import torchaudio.transforms as T
from torch.utils.data import Dataset, DataLoader
from torch.utils.data import WeightedRandomSampler
import numpy as np

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

        return waveform.squeeze(0), label


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
    
    # 1. Calculate inverse weights for balanced sampling based on actual file counts
    train_labels = [labels_map[lbl] for _, lbl in train_files]
    class_counts = np.bincount(train_labels, minlength=len(labels_map))
    class_weights = 1.0 / np.maximum(class_counts, 1) # Prevent divide-by-zero
    
    # 2. Assign the appropriate weight to every file in the training list
    sample_weights = [class_weights[y] for y in train_labels]
    
    # 3. Create the sampler
    # We multiply by train_multiplier here so the epoch length remains the same as before
    total_epoch_samples = len(train_files) * config.get("train_multiplier", 10)
    sampler = WeightedRandomSampler(
        weights=sample_weights, 
        num_samples=total_epoch_samples, 
        replacement=True
    )

    # 4. Plug the sampler into the train_loader (shuffle=True MUST be removed)
    train_loader = DataLoader(
        train_dataset, 
        batch_size=batch_size, 
        sampler=sampler, 
        num_workers=4
    )
    
    test_loader = DataLoader(
        test_dataset, 
        batch_size=batch_size, 
        shuffle=False, 
        num_workers=4
    )
    

    return train_loader, test_loader, labels_map