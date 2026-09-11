import os
import torch
import datetime
from model import FastSpikingNet
from utils_ledger import create_ledger, append_commit

# --- INITIALIZATION CONFIG ---
EXP_NAME = "80_neurons_advanced"
BASE_CONFIG = {
    "num_inputs": 8,           # 8 hardware LIF channels (7 freq + 1 noise gate)
    "num_hidden": 80,          # Expanded search space for Phase 1
    "num_outputs": 7,          # 4 numbers + 2 operators (+/-) + 1 noise
    "batch_size": 128,
    "beta": 0.88,              # Hot start leak rate
    "lr": 0.002,               
}
# -----------------------------

def main():
    device = torch.device("cpu")
    
    timestamp = datetime.datetime.now().strftime("%m%d_%H%M")
    folder_name = f"{timestamp}_{EXP_NAME}"
    folder_path = os.path.join("experiments", folder_name)
    
    print(f"=== Initializing Voice Calculator Phase 1 ===")
    
    create_ledger(folder_path, EXP_NAME, BASE_CONFIG)
    
    model = FastSpikingNet(
        num_inputs=BASE_CONFIG["num_inputs"],
        num_hidden=BASE_CONFIG["num_hidden"],
        num_outputs=BASE_CONFIG["num_outputs"],
        beta=BASE_CONFIG["beta"]
    ).to(device)
    
    model_filename = "model_00_init.pth"
    torch.save(model.state_dict(), os.path.join(folder_path, model_filename))
    
    append_commit(
        folder_path=folder_path,
        action="init",
        model_filename=model_filename,
        metrics={"status": "initialized_fp_sandbox"}
    )
    
    print(f"Success! Created {folder_path}")
    print(f"Initial model saved as {model_filename}.")

if __name__ == "__main__":
    main()