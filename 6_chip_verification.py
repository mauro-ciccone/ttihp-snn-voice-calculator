import os
import copy
import torch
import torch.nn as nn
from tqdm import tqdm
from dataset_cached import get_cached_dataloaders
from utils_ledger import load_ledger

import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="torchaudio._backend.utils")

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier" 
GENERATIONS = 0 
POP_SIZE = 10
MUTATION_RATE = 0.05

class PureIntegerHardwareNet(nn.Module):
    def __init__(self, config, device):
        super().__init__()
        self.device = device
        self.num_hidden = config["num_hidden"]
        self.num_inputs = config["num_inputs"]
        self.num_outputs = config["num_outputs"]

        manifest_path = os.path.join(TARGET_FOLDER, "pure_integer_model.pt")
        if not os.path.exists(manifest_path):
            raise FileNotFoundError(f"Missing {manifest_path}. Export from Phase 5 first.")
            
        manifest = torch.load(manifest_path, map_location=device)
        
        self.global_delta = manifest["delta_in"] 
        self.delta_out = manifest["delta_out"]
        self.g_in = manifest.get("g_in", 2)
        self.g_rec = manifest.get("g_rec", 1)
        self.g_out = manifest.get("g_out", 4)
        
        self.w_in_int = nn.Parameter(manifest["w_in_int"], requires_grad=False)
        self.w_rec_int = nn.Parameter(manifest["w_rec_int"], requires_grad=False)
        self.w_out_int = nn.Parameter(manifest["w_out_int"], requires_grad=False)
        
        self.pos_masks_in = nn.Parameter(manifest["pos_masks_in"], requires_grad=False)
        self.neg_masks_in = nn.Parameter(manifest["neg_masks_in"], requires_grad=False)
        self.pos_masks_rec = nn.Parameter(manifest["pos_masks_rec"], requires_grad=False)
        self.neg_masks_rec = nn.Parameter(manifest["neg_masks_rec"], requires_grad=False)
        self.pos_masks_out = nn.Parameter(manifest["pos_masks_out"], requires_grad=False)
        self.neg_masks_out = nn.Parameter(manifest["neg_masks_out"], requires_grad=False)

        self.beta_hid = manifest["beta_hid"].to(device)
        self.frac_bits_hid = manifest["frac_bits_hid"].to(device)
        self.beta_out = manifest["beta_out"].to(device)
        self.frac_bits_out = manifest["frac_bits_out"].to(device)

        self.max_mem_hid = (2.0 ** (manifest["int_bits_hid"].to(device) + self.frac_bits_hid)) - 1.0
        self.max_mem_out = (2.0 ** (manifest["int_bits_out"].to(device) + self.frac_bits_out)) - 1.0

        self.lsb_hid = self.global_delta / (2.0 ** self.frac_bits_hid)
        self.lsb_out = self.delta_out / (2.0 ** self.frac_bits_out)

        self.thresh_hid = torch.round(1.0 / self.global_delta) * self.global_delta
        self.thresh_out = torch.round(1.0 / self.delta_out) * self.delta_out

        self.bit_shifts = nn.Parameter(torch.tensor([1<<i for i in range(8)], dtype=torch.int32, device=device).view(1, 8, 1, 1), requires_grad=False)
        
        self.rebuild_bit_mats()

    def _build_bit_mats(self, gate_masks, w_abs_int, num_gates):
        mats = []
        for g in range(num_gates):
            w_gate = w_abs_int * gate_masks[g]
            bits = []
            for b in range(8):
                has_bit = ((w_gate & (1 << b)) != 0).float()
                bits.append(has_bit.t())
            mats.append(torch.stack(bits, dim=0))
        return torch.stack(mats, dim=0) 

    def rebuild_bit_mats(self):
        w_in_abs = torch.abs(self.w_in_int.data)
        w_rec_abs = torch.abs(self.w_rec_int.data)
        w_out_abs = torch.abs(self.w_out_int.data)
        
        self.pos_bit_mats_in = self._build_bit_mats(self.pos_masks_in, w_in_abs, self.g_in).view(self.g_in * 8, self.num_inputs, self.num_hidden)
        self.neg_bit_mats_in = self._build_bit_mats(self.neg_masks_in, w_in_abs, self.g_in).view(self.g_in * 8, self.num_inputs, self.num_hidden)
        self.pos_bit_mats_rec = self._build_bit_mats(self.pos_masks_rec, w_rec_abs, self.g_rec).view(self.g_rec * 8, self.num_hidden, self.num_hidden)
        self.neg_bit_mats_rec = self._build_bit_mats(self.neg_masks_rec, w_rec_abs, self.g_rec).view(self.g_rec * 8, self.num_hidden, self.num_hidden)
        self.pos_bit_mats_out = self._build_bit_mats(self.pos_masks_out, w_out_abs, self.g_out).view(self.g_out * 8, self.num_hidden, self.num_outputs)
        self.neg_bit_mats_out = self._build_bit_mats(self.neg_masks_out, w_out_abs, self.g_out).view(self.g_out * 8, self.num_hidden, self.num_outputs)

    def forward(self, x):
        batch = x.size(0)
        time_steps = x.size(1)
        
        mem_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        mem_out = torch.zeros(batch, self.num_outputs, device=self.device)
        spk_hid = torch.zeros(batch, self.num_hidden, device=self.device)
        spk_out_rec, spk_hid_rec = [], []

        for step in range(time_steps):
            x_batched = x[:, step, :].unsqueeze(0) 
            spk_batched = spk_hid.unsqueeze(0)     
            
            pos_counts_in = torch.matmul(x_batched, self.pos_bit_mats_in)
            neg_counts_in = torch.matmul(x_batched, self.neg_bit_mats_in)
            pos_int_in = ((pos_counts_in > 0).int().view(self.g_in, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0, 1))
            neg_int_in = ((neg_counts_in > 0).int().view(self.g_in, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0, 1))
            
            pos_counts_rec = torch.matmul(spk_batched, self.pos_bit_mats_rec) 
            neg_counts_rec = torch.matmul(spk_batched, self.neg_bit_mats_rec)
            pos_int_rec = ((pos_counts_rec > 0).int().view(self.g_rec, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0, 1))
            neg_int_rec = ((neg_counts_rec > 0).int().view(self.g_rec, 8, batch, self.num_hidden) * self.bit_shifts).sum(dim=(0, 1))
            
            hw_sum_int = (pos_int_in - neg_int_in) + (pos_int_rec - neg_int_rec)
            hw_sum_float = hw_sum_int.float() * self.global_delta
            
            ideal_mem_hid = (mem_hid * self.beta_hid.unsqueeze(0)) + hw_sum_float
            limit_hid = (self.max_mem_hid * self.lsb_hid).unsqueeze(0)
            ideal_mem_hid = torch.clamp(ideal_mem_hid, min=-limit_hid, max=limit_hid)
            mem_hid = torch.floor((ideal_mem_hid / self.lsb_hid.unsqueeze(0)) + 1e-5) * self.lsb_hid.unsqueeze(0)
            
            spk_hid = (mem_hid >= self.thresh_hid).float()
            mem_hid = mem_hid * (1.0 - spk_hid) 
            spk_hid_rec.append(spk_hid)
            
            pos_counts_out = torch.matmul(spk_batched, self.pos_bit_mats_out)
            neg_counts_out = torch.matmul(spk_batched, self.neg_bit_mats_out)
            pos_int_out = ((pos_counts_out > 0).int().view(self.g_out, 8, batch, self.num_outputs) * self.bit_shifts).sum(dim=(0, 1))
            neg_int_out = ((neg_counts_out > 0).int().view(self.g_out, 8, batch, self.num_outputs) * self.bit_shifts).sum(dim=(0, 1))
            
            hw_sum_out_int = pos_int_out - neg_int_out
            cur_out_float = hw_sum_out_int.float() * self.delta_out
            
            ideal_mem_out = (mem_out * self.beta_out.unsqueeze(0)) + cur_out_float
            limit_out = (self.max_mem_out * self.lsb_out).unsqueeze(0)
            ideal_mem_out = torch.clamp(ideal_mem_out, min=-limit_out, max=limit_out)
            mem_out = torch.floor((ideal_mem_out / self.lsb_out.unsqueeze(0)) + 1e-5) * self.lsb_out.unsqueeze(0)
            
            spk_out = (mem_out >= self.thresh_out).float()
            mem_out = mem_out * (1.0 - spk_out)
            spk_out_rec.append(spk_out)
            
        return torch.stack(spk_out_rec, dim=1), torch.stack(spk_hid_rec, dim=1)

def evaluate_fitness(model, x, y, idx_silence):
    with torch.no_grad():
        spk_out, _ = model(x)
        spike_counts = spk_out.sum(dim=1)
        max_spikes, raw_preds = spike_counts.max(dim=1)
        preds = torch.where(max_spikes < 10, torch.tensor(idx_silence, device=model.device), raw_preds)
        
        correct = (preds == y).sum().item()
        sorted_spikes, _ = torch.sort(spike_counts, dim=1, descending=True)
        margin_diffs = (sorted_spikes[:, 0] - sorted_spikes[:, 1]).sum().item()
        
        return correct, margin_diffs

def run_evaluation(model, data_loader, device, idx_noise, idx_silence):
    model.eval()
    val_correct, val_total = 0, 0
    all_preds, all_targets, all_spikes, all_spk_out_time = [], [], [], []
    all_in_spikes, all_hidden_spikes = [], []
    
    with torch.no_grad():
        for x, y in tqdm(data_loader, desc="Running Hardware Verification", leave=False):
            x, y = x.to(device), y.to(device)
            spk_out, spk_hidden = model(x)
            spike_counts = spk_out.sum(dim=1)
            
            max_spikes, raw_preds = spike_counts.max(dim=1)
            preds = torch.where(max_spikes < 10, torch.tensor(idx_silence, device=device), raw_preds)
            
            val_correct += (preds == y).sum().item()
            val_total += y.size(0)
            
            all_preds.extend(preds.cpu().tolist())
            all_targets.extend(y.cpu().tolist())
            all_spikes.append(spike_counts.cpu())
            all_in_spikes.append(x.sum(dim=1).cpu())
            all_hidden_spikes.append(spk_hidden.sum(dim=1).cpu())
            all_spk_out_time.append(spk_out.cpu())
            
    spike_counts = torch.cat(all_spikes, dim=0)
    input_counts = torch.cat(all_in_spikes, dim=0)
    hidden_counts = torch.cat(all_hidden_spikes, dim=0)
    spk_out_tensor = torch.cat(all_spk_out_time, dim=0)
    acc = (val_correct / val_total) * 100 if val_total > 0 else 0.0
    
    return acc, all_preds, all_targets, spike_counts, input_counts, hidden_counts, spk_out_tensor

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    print("\n=== Phase 6: TRUE OR-GATE HARDWARE VERIFIER ===")
    
    train_loader, test_loader, labels_map = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    idx_noise = labels_map.get("noise", 6)
    idx_silence = labels_map.get("silence", 7)
    inv_labels = {v: k for k, v in labels_map.items()}
    num_classes = config["num_outputs"]

    champion = PureIntegerHardwareNet(config, device).to(device)
    
    print("\n===========================================================")
    print("        FINAL PURE INTEGER HARDWARE CHIP VERIFICATION      ")
    print(f"        Output Gates Allocated: G_OUT = {champion.g_out}")
    print("===========================================================\n")
    
    final_test_acc, preds, targets, spike_counts, input_counts, hidden_counts, spk_out_tensor = run_evaluation(champion, test_loader, device, idx_noise, idx_silence)
    
    target_tensor_arr = torch.tensor(targets)
    pred_tensor_arr = torch.tensor(preds)
    
    print("\n--- Average Output Spikes per Target Class ---")
    header_spikes = f"{'Target Class':<13} | " + " | ".join([f"{inv_labels[i]:>6}" for i in range(num_classes)])
    print(header_spikes)
    print("-" * len(header_spikes))
    for i in range(len(inv_labels)): 
        class_mask = target_tensor_arr == i
        if class_mask.sum() > 0:
            mean_spikes = spike_counts[class_mask].float().mean(dim=0)
            print(f"{inv_labels[i]:<13} | " + " | ".join([f"{val:>6.1f}" for val in mean_spikes]))

    print("\n--- Network Health & Sparsity Audit ---")
    total_spikes_per_neuron = hidden_counts.sum(dim=0)
    avg_spikes_per_neuron = hidden_counts.mean(dim=0)
    dead_neurons = (total_spikes_per_neuron == 0).nonzero(as_tuple=True)[0].tolist()
    
    print(f"Total Hidden Neurons: {config['num_hidden']}")
    print(f"Dead Neurons (0 spikes)         : {len(dead_neurons):>3}  {dead_neurons if dead_neurons else ''}")

    print("\n--- Hardware Precision Matrix (%) ---")
    keyword_idx = [i for i in range(num_classes) if i not in (idx_noise, idx_silence)]
    header = f"{'Target / Pred':<13} | " + " | ".join([f"{inv_labels[i]:>6}" for i in keyword_idx]) + " || Retention"
    print(header)
    print("-" * len(header))
    
    for t_idx in keyword_idx:
        t_mask = target_tensor_arr == t_idx
        total_samples = t_mask.sum().item()
        if total_samples > 0:
            preds_for_target = pred_tensor_arr[t_mask]
            active_preds = preds_for_target[(preds_for_target != idx_noise) & (preds_for_target != idx_silence)]
            retained = active_preds.size(0)
            ret_pct = (retained / total_samples) * 100
            
            row_str = f"{inv_labels[t_idx]:<13} | "
            for p_idx in keyword_idx:
                count = (active_preds == p_idx).sum().item()
                pct = (count / retained * 100) if retained > 0 else 0.0
                row_str += f"{pct:>6.1f} | "
            row_str += f"|| {ret_pct:>6.1f}%"
            print(row_str)
            
    print(f"\n✨ FINAL TRUE HARDWARE TEST ACCURACY (G_OUT={champion.g_out}): {final_test_acc:.2f}%")

    # --- NEW TEMPORAL SPIKE DIAGNOSTIC ---
    print("\n===========================================================")
    print("      TEMPORAL BASE OUTPUT SPIKES (50ms BUCKETS)           ")
    print("===========================================================")
    
    bucket_size = 50
    num_buckets = 1000 // bucket_size
    binned_spikes = spk_out_tensor.view(-1, num_buckets, bucket_size, num_classes).sum(dim=2)
    
    for class_idx in range(len(inv_labels)):
        class_name = inv_labels[class_idx]
        class_mask = target_tensor_arr == class_idx
        
        if class_mask.sum() == 0:
            continue
            
        print(f"\n>>> Target Class: {class_name.upper()}")
        header = f"{'Time (ms)':<10} | " + " | ".join([f"{inv_labels[i]:>6}" for i in range(num_classes)])
        print(header)
        print("-" * len(header))
        
        class_binned_spikes = binned_spikes[class_mask].float().mean(dim=0)
        
        for b in range(num_buckets):
            t_start = b * bucket_size
            t_end = t_start + bucket_size
            row_str = f"{t_start:>3}-{t_end:<3} | "
            row_str += " | ".join([f"{class_binned_spikes[b, i]:>6.1f}" for i in range(num_classes)])
            print(row_str)

if __name__ == "__main__":
    main()