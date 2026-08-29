import os
import torch
import datetime
from model import FastSpikingNet
from utils_ledger import create_ledger, append_commit

# --- INITIALIZATION CONFIG ---
EXP_NAME = "dynamic_lr"
BASE_CONFIG = {
    "num_inputs": 8,           # 8 hardware LIF channels (formerly n_mels)
    "num_hidden": 128,         # Hidden recurrent neurons
    "num_outputs": 7,          # 7 keyword classes
    "batch_size": 128,
    "beta": 0.88,              # Hidden layer leak rate
    "lr": 0.002,               # Hotter start to break the initial deadzone
    #"target_spikes": 50,       # Target threshold for keyword firing
    #"cross_talk_scale": 0.1,   # Penalty weight for silencing wrong neurons
    #"snn_clock_hz": 1000       # Documenting the speed of our hidden layer
}
# -----------------------------

def main():
    # Set mps or cpu
    device = torch.device("cpu")
    
    # 1. Create the experiment folder
    timestamp = datetime.datetime.now().strftime("%m%d_%H%M")
    folder_name = f"{timestamp}_{EXP_NAME}"
    folder_path = os.path.join("experiments", folder_name)
    
    print(f"=== Initializing Experiment: {EXP_NAME} ===")
    
    # 2. Build the JSON Ledger
    create_ledger(folder_path, EXP_NAME, BASE_CONFIG)
    
    # 3. Instantiate the pure Recurrent SNN
    model = FastSpikingNet(
        num_inputs=BASE_CONFIG["num_inputs"],
        num_hidden=BASE_CONFIG["num_hidden"],
        num_outputs=BASE_CONFIG["num_outputs"],
        beta=BASE_CONFIG["beta"]
    ).to(device)
    
    # 4. Save the starting weights
    model_filename = "model_00_init.pth"
    torch.save(model.state_dict(), os.path.join(folder_path, model_filename))
    
    # 5. Commit to the ledger
    append_commit(
        folder_path=folder_path,
        action="init",
        model_filename=model_filename,
        metrics={"status": "initialized_fast_snn"}
    )
    
    print(f"Success! Created {folder_path}")
    print(f"Initial model saved as {model_filename} and ledger initialized.")

if __name__ == "__main__":
    main()