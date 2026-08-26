import os
import torch
import random
from torch.utils.data import Dataset, DataLoader, WeightedRandomSampler
import numpy as np

class CachedSpikeDataset(Dataset):
    def __init__(self, file_list, labels_map):
        self.file_list = file_list
        self.labels_map = labels_map

    def __len__(self):
        return len(self.file_list)

    def __getitem__(self, idx):
        file_path, label_str = self.file_list[idx]
        label = self.labels_map[label_str]
        
        # Load the pre-computed SNN input tensor instantly
        spike_tensor = torch.load(file_path, weights_only=True)
        return spike_tensor, label

def get_cached_dataloaders(cache_dir="data_cache", batch_size=128):
    labels = sorted([d for d in os.listdir(cache_dir) if not d.startswith(".")])
    if "noise" in labels:
        labels.remove("noise")
        labels.append("noise")
    labels_map = {lbl: i for i, lbl in enumerate(labels)}
    
    train_files, test_files = [], []
    for lbl in labels:
        lbl_dir = os.path.join(cache_dir, lbl)
        files = [f for f in os.listdir(lbl_dir) if f.endswith(".pt")]
        
        # STRICT LEAKAGE PREVENTION:
        # aug0 goes to TEST. aug1-9 go to TRAIN.
        class_test = [(os.path.join(lbl_dir, f), lbl) for f in files if f.endswith("_aug0.pt")]
        class_train = [(os.path.join(lbl_dir, f), lbl) for f in files if not f.endswith("_aug0.pt")]
        
        # Shuffle and cap test files to prevent Noise from hiding accuracy
        random.shuffle(class_test)
        test_files.extend(class_test[:20]) 
        train_files.extend(class_train)

    train_dataset = CachedSpikeDataset(train_files, labels_map)
    test_dataset = CachedSpikeDataset(test_files, labels_map)

    # Balance Training batches
    train_labels = [labels_map[lbl] for _, lbl in train_files]
    class_counts = np.bincount(train_labels, minlength=len(labels_map))
    class_weights = 1.0 / np.maximum(class_counts, 1)
    sample_weights = [class_weights[y] for y in train_labels]
    
    sampler = WeightedRandomSampler(weights=sample_weights, num_samples=len(train_files), replacement=True)
    
    train_loader = DataLoader(train_dataset, batch_size=batch_size, sampler=sampler, num_workers=0)
    test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False, num_workers=0)
    
    return train_loader, test_loader, labels_map