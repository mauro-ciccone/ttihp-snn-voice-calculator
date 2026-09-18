import os
import torch
from tqdm import tqdm
from dataset_cached import get_cached_dataloaders
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier"
MODEL_NAME = "model_best.pth"
NUM_BUSES_PER_NEURON = 4

def quantize_weights(weight, max_val=127.0):
    w_abs = torch.abs(weight)
    delta = (torch.quantile(w_abs.detach(), 0.985) + 1e-8) / max_val
    # We need strict integers to simulate the hardware bitwise OR
    w_scaled = torch.round(weight / delta).to(torch.int32)
    
    # Apply the same exact L1/Dead-logic mask used in Phase 2
    mask = torch.sigmoid(10.0 * (torch.abs(weight / delta) - 0.5))
    w_scaled = torch.where(mask > 0.5, w_scaled, torch.zeros_like(w_scaled))
    return w_scaled

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    _, test_loader, _ = get_cached_dataloaders("data_cache", batch_size=config["batch_size"])
    
    model = FastSpikingNet(
        num_inputs=config["num_inputs"],
        num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"],
        beta=config["beta"],
        slope=50
    ).to(device)
    
    checkpoint = torch.load(os.path.join(TARGET_FOLDER, MODEL_NAME), map_location=device)
    model.load_state_dict(checkpoint["model_state_dict"])
    model.eval()
    
    print(f"\n=== Decentralized Topological Crossbar Alignment ===")
    
    # 1. Extract Quantized Integer Weights
    w_in = quantize_weights(model.fc_in.weight)
    w_rec = quantize_weights(model.fc_rec.weight)
    w_combined = torch.cat([w_in, w_rec], dim=1)  # Shape: [80, 86]
    
    # 2. Extract Temporal Spikes
    all_spikes = []
    with torch.no_grad():
        for x, _ in tqdm(test_loader, desc="Scanning Temporal Footprints", leave=False):
            spk_out, spk_hidden = model(x.to(device))
            combined = torch.cat([x.to(device), spk_hidden], dim=2)
            all_spikes.append(combined.view(-1, combined.size(2)).to(torch.int32))
            
    total_spikes = torch.cat(all_spikes, dim=0) # [Total_Ticks, 86]
    
    total_system_ideal_sum = 0
    total_system_loss = 0
    max_wires_on_one_bus = 0
    optimal_routing = {}
    
    print("\nCalculating Bit-Accurate Collisions per Neuron...")
    
    # 3. Optimize the 4-Adder Tree for every single Neuron
    for n in tqdm(range(config["num_hidden"]), desc="Optimizing Adder Trees"):
        weights = w_combined[n]
        active_indices = (weights != 0).nonzero(as_tuple=True)[0]
        
        if len(active_indices) == 0:
            optimal_routing[n] = [[] for _ in range(NUM_BUSES_PER_NEURON)]
            continue
            
        weights_active = weights[active_indices]
        
        # Sort wires by activity (place the heaviest trafficked wires first for safety)
        activity = total_spikes[:, active_indices].sum(dim=0)
        sorted_order = torch.argsort(activity, descending=True)
        
        # Count surviving physical wires by sign
        pos_wires = sum(1 for w in weights_active if w > 0)
        neg_wires = len(weights_active) - pos_wires
        
        # Dynamically allocate buses, but guarantee at least 1 bus if that sign exists
        if pos_wires == 0:
            num_pos_buses = 0
        elif neg_wires == 0:
            num_pos_buses = NUM_BUSES_PER_NEURON
        else:
            num_pos_buses = int(round((pos_wires / len(weights_active)) * NUM_BUSES_PER_NEURON))
            # Force at least 1 bus for both signs to prevent the -1 indexing bug
            num_pos_buses = max(1, min(NUM_BUSES_PER_NEURON - 1, num_pos_buses))
            
        num_neg_buses = NUM_BUSES_PER_NEURON - num_pos_buses
        
        valid_pos_buses = list(range(0, num_pos_buses))
        valid_neg_buses = list(range(num_pos_buses, NUM_BUSES_PER_NEURON))

        buses_or_state = [torch.zeros(total_spikes.size(0), dtype=torch.int32, device=device) for _ in range(NUM_BUSES_PER_NEURON)]
        buses_ideal_state = [torch.zeros(total_spikes.size(0), dtype=torch.int64, device=device) for _ in range(NUM_BUSES_PER_NEURON)]
        bus_assignments = [[] for _ in range(NUM_BUSES_PER_NEURON)]
        
        for idx in sorted_order:
            wire_idx = active_indices[idx].item()
            raw_w_val = weights_active[idx].item()
            
            w_val = abs(raw_w_val)
            wire_stream = total_spikes[:, wire_idx] * w_val
            wire_stream_64 = wire_stream.to(torch.int64)
            
            best_bus = -1
            min_loss_increase = float('inf')
            
            # Use the dynamically allocated, guaranteed-safe buses
            valid_buses = valid_pos_buses if raw_w_val > 0 else valid_neg_buses
            
            for b in valid_buses:
                test_or_state = torch.bitwise_or(buses_or_state[b], wire_stream)
                test_ideal_state = buses_ideal_state[b] + wire_stream_64
                
                loss = (test_ideal_state - test_or_state).sum().item()
                current_bus_loss = (buses_ideal_state[b] - buses_or_state[b]).sum().item()
                loss_increase = loss - current_bus_loss
                
                # Tie-breaker: If loss is equal, pick the bus with fewer wires
                if loss_increase < min_loss_increase:
                    min_loss_increase = loss_increase
                    best_bus = b
                elif loss_increase == min_loss_increase and best_bus != -1:
                    if len(bus_assignments[b]) < len(bus_assignments[best_bus]):
                        best_bus = b
            
            bus_assignments[best_bus].append(wire_idx)
            buses_or_state[best_bus] = torch.bitwise_or(buses_or_state[best_bus], wire_stream)
            buses_ideal_state[best_bus] = buses_ideal_state[best_bus] + wire_stream_64
            
            max_wires_on_one_bus = max(max_wires_on_one_bus, len(bus_assignments[best_bus]))
            
        optimal_routing[n] = bus_assignments
        
        # Accumulate the final physical loss for this neuron's optimal layout
        for b in range(NUM_BUSES_PER_NEURON):
            total_system_ideal_sum += buses_ideal_state[b].sum().item()
            total_system_loss += (buses_ideal_state[b] - buses_or_state[b]).sum().item()

    # Save the routing map for Phase 3 so we don't have to re-compute it
    torch.save(optimal_routing, os.path.join(TARGET_FOLDER, "bus_routing_map.pt"))

    if total_system_ideal_sum > 0:
        loss_pct = (total_system_loss / total_system_ideal_sum) * 100
    else:
        loss_pct = 0.0
        
    print(f"\n=== Topological OR-Bus Alignment Complete ===")
    print(f"Total Theoretical Signal Power : {int(total_system_ideal_sum)}")
    print(f"Total Data Lost to Bit Overlap : {int(total_system_loss)}")
    print(f"Hardware Data Loss Rate        : {loss_pct:.5f}%")
    print(f"Max Wires Packed into 1 OR Gate: {max_wires_on_one_bus} (Target was ~20)")
    print(f"\nSaved 'bus_routing_map.pt'. Phase 3 simulator is fully cleared to launch.")

if __name__ == "__main__":
    main()