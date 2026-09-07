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
    # We removed "minus" from the unique labels list so it isn't assigned an output ID
    labels = ["drü", "eis", "plus", "vier", "zwoi", "noise", "silence"]
    labels_map = {lbl: i for i, lbl in enumerate(labels)}
    
    # Force the string "minus" to map directly to the "noise" index
    labels_map["minus"] = labels_map["noise"]
    
    temp_train = {lbl: [] for lbl in labels}
    temp_test = {lbl: [] for lbl in labels}
    
    folder_names = ["drü", "eis", "minus", "plus", "vier", "zwoi", "noise", "silence"]
    
    # --- PASS 1: Gather all files and separate Test vs Train ---
    for folder in folder_names:
        lbl_dir = os.path.join(cache_dir, folder)
        files = [f for f in os.listdir(lbl_dir) if f.endswith(".pt")]
        
        target_label = folder if folder != "minus" else "noise"
        
        if folder in ["noise", "silence", "minus"]:
            random.shuffle(files)
            # Ambient has no augmentations. Reserve 20% for testing.
            split_idx = int(len(files) * 0.2)
            temp_test[target_label].extend([(os.path.join(lbl_dir, f), folder) for f in files[:split_idx]])
            temp_train[target_label].extend([(os.path.join(lbl_dir, f), folder) for f in files[split_idx:]])
        else:
            # STRICT LEAKAGE PREVENTION: Only raw audio (_aug0) in Test
            temp_test[target_label].extend([(os.path.join(lbl_dir, f), folder) for f in files if f.endswith("_aug0.pt")])
            temp_train[target_label].extend([(os.path.join(lbl_dir, f), folder) for f in files if not f.endswith("_aug0.pt")])
            
    # --- PASS 2: Dynamic Capping for perfect Test Balance ---
    min_test_count = min(len(items) for items in temp_test.values())
    print(f"Dynamically capping Test Set at {min_test_count} samples per class.")
    
    # Find the largest keyword class to define our ideal epoch size
    keyword_labels = ["drü", "eis", "plus", "vier", "zwoi"]
    max_keyword_train = max(len(temp_train[lbl]) for lbl in keyword_labels)
    
    train_files, test_files = [], []
    for lbl in labels:
        # Build perfectly balanced Test Set
        random.shuffle(temp_test[lbl])
        test_files.extend(temp_test[lbl][:min_test_count])
        
        # Build Train Set: Put EVERYTHING in (No capping!)
        train_files.extend(temp_train[lbl])

    train_dataset = CachedSpikeDataset(train_files, labels_map)
    test_dataset = CachedSpikeDataset(test_files, labels_map)

    # --- BALANCING WITH THE SAMPLER ---
    train_labels = [labels_map[lbl] for _, lbl in train_files]
    class_counts = np.bincount(train_labels, minlength=len(labels_map))
    class_weights = 1.0 / np.maximum(class_counts, 1)
    sample_weights = [class_weights[y] for y in train_labels]
    
    # THE FIX: We restrict the length of an epoch, not the dataset!
    # 8 classes * largest keyword size = perfectly sized epoch
    optimal_epoch_size = max_keyword_train * len(labels)

    print(f"Max keyword train size: {max_keyword_train}")
    print(f"Total files in RAM: {len(train_files)}")
    print(f"Optimal epoch size (Sampler limit): {optimal_epoch_size}")
    
    sampler = WeightedRandomSampler(
        weights=sample_weights, 
        num_samples=optimal_epoch_size, # <-- The Sampler dynamically limits the epoch
        replacement=True
    )
    
    train_loader = DataLoader(train_dataset, batch_size=batch_size, sampler=sampler, num_workers=0)
    test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False, num_workers=0)
    
    return train_loader, test_loader, labels_map