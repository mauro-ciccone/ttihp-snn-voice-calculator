import os
import random
import torch
import torchaudio
import torchaudio.transforms as T
from torch.utils.data import Dataset, DataLoader

class SwissGermanVoiceDataset(Dataset):
    def __init__(self, file_list, labels_map, n_mels=16, n_fft=512, hop_length=128, is_train=True, train_multiplier=10):
        self.file_list = file_list
        self.labels_map = labels_map
        self.is_train = is_train
        self.train_multiplier = train_multiplier if is_train else 1
        
        self.mel_transform = T.MelSpectrogram(
            sample_rate=16000,
            n_fft=n_fft,
            hop_length=hop_length,
            n_mels=n_mels
        )

    def _augment(self, waveform):
        # 1. Random time roll / shift
        shift = random.randint(-1600, 1600) # +/- 100ms at 16kHz
        waveform = torch.roll(waveform, shifts=shift, dims=-1)
        
        # 2. Add subtle Gaussian noise
        noise = torch.randn_like(waveform) * 0.005
        waveform = waveform + noise
        
        # 3. Random amplitude scaling (volume jitter)
        scale = random.uniform(0.8, 1.2)
        waveform = waveform * scale
        
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

        # Compute log-mel spectrogram: [1, n_mels, time] -> [time, n_mels]
        mel = self.mel_transform(waveform)
        log_mel = torch.log(mel + 1e-6).squeeze(0).transpose(0, 1)

        # Normalize per sample
        log_mel = (log_mel - log_mel.mean()) / (log_mel.std() + 1e-6)

        return log_mel, label


def get_dataloaders(config, data_dir="custom_audio", test_split_pct=0.2):
    """
    Scans data_dir for class subfolders (e.g. data/eis, data/zwoi, ...),
    splits into train and untouched test sets, and returns PyTorch DataLoaders.
    """
    labels = sorted([d for d in os.listdir(data_dir) if os.path.isdir(os.path.join(data_dir, d)) and not d.startswith(".")])
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

    train_dataset = SwissGermanVoiceDataset(
        file_list=train_files,
        labels_map=labels_map,
        n_mels=config.get("n_mels", 16),
        n_fft=config.get("n_fft", 512),
        hop_length=config.get("hop_length", 128),
        is_train=True,
        train_multiplier=config.get("train_multiplier", 10)
    )

    test_dataset = SwissGermanVoiceDataset(
        file_list=test_files,
        labels_map=labels_map,
        n_mels=config.get("n_mels", 16),
        n_fft=config.get("n_fft", 512),
        hop_length=config.get("hop_length", 128),
        is_train=False,
        train_multiplier=1
    )

    batch_size = config.get("batch_size", 32)
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False)

    return train_loader, test_loader, labels_map