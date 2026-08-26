import torch
import torch.nn as nn
from tqdm import tqdm
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet

def main():
    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    
    print("Loading Cached Dataset...")
    train_loader, test_loader, labels_map = get_cached_dataloaders("data_cache")
    idx_noise = labels_map.get("noise", 8)
    
    model = FastSpikingNet().to(device)
    optimizer = torch.optim.Adam(model.parameters(), lr=0.005) # Hotter start to break initial deadzone
    
    target_spikes = 50
    epochs = 20
    
    print("Starting Lightning Training...")
    for epoch in range(epochs):
        model.train()
        total_loss, correct, total = 0.0, 0, 0
        
        pbar = tqdm(train_loader, desc=f"Epoch {epoch+1:02d}", leave=False)
        for x, y in pbar:
            x, y = x.to(device), y.to(device)
            optimizer.zero_grad()
            
            spk_out = model(x)
            spike_counts = spk_out.sum(dim=1)
            
            # --- The Asymmetric Loss ---
            target_counts = torch.zeros_like(spike_counts)
            for b in range(len(y)):
                label = y[b].item()
                if label != idx_noise: 
                    target_counts[b, label] = target_spikes
            
            base_mse = nn.functional.mse_loss(spike_counts, target_counts, reduction='none')
            
            weights = torch.ones_like(y, dtype=torch.float32, device=device)
            weights[y != idx_noise] = 5.0 # 5x penalty for missing keywords
            weighted_mse = (base_mse.mean(dim=1) * weights).mean()
            
            # Cross-talk Penalty
            cross_talk_loss = torch.tensor(0.0, device=device)
            for b in range(len(y)):
                label = y[b].item()
                if label != idx_noise and label < 8:
                    wrong_mask = torch.ones(8, dtype=torch.bool, device=device)
                    wrong_mask[label] = False
                    cross_talk_loss = cross_talk_loss + torch.sum(spike_counts[b, wrong_mask] ** 2)
            cross_talk_loss = cross_talk_loss / len(y) * 0.1
            
            loss = weighted_mse + cross_talk_loss
            loss.backward()
            optimizer.step()
            
            total_loss += loss.item()
            
            # Dynamic Inference (Threshold dropped to 5 for early training)
            max_spikes, raw_preds = spike_counts.max(dim=1)
            preds = torch.where(max_spikes < 5, torch.tensor(idx_noise, device=device), raw_preds)
            
            correct += (preds == y).sum().item()
            total += y.size(0)
            
            pbar.set_postfix({"Loss": f"{loss.item():.2f}", "Acc": f"{(correct/total)*100:.1f}%"})
            
        print(f"Epoch {epoch+1:02d} | Train Acc: {(correct/total)*100:.1f}% | Loss: {total_loss/len(train_loader):.2f}")

if __name__ == "__main__":
    main()