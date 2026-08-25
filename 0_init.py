import os
import torch
import datetime
from model import SpikingNet
from utils_ledger import create_ledger, append_commit

# --- INITIALIZATION CONFIG ---
EXP_NAME = "dense_MSE_loss_pdm"
BASE_CONFIG = {
    "sample_rate": 16000,
    "n_mels": 8,
    "n_fft": 512,
    "hop_length": 128,
    "num_hidden": 128,
    "num_outputs": 8,
    "batch_size": 128,
    "train_multiplier": 10,
    "test_split_pct": 0.2,
    "beta": 0.88,
    "lr": 0.001,
    "lambda_confusion": 0.1,
    "target_spikes": 50,
    "lambda_reg": 0.001,
    "lambda_l1": 0.001      # The new penalty to force sparsity during training
}
# -----------------------------

def main():
    device = torch.device("cpu") # Change to "mps" or "cuda" if needed
    
    # 1. Create the experiment folder (e.g., experiments/0825_1430_dense_teacher_pipeline)
    timestamp = datetime.datetime.now().strftime("%m%d_%H%M")
    folder_name = f"{timestamp}_{EXP_NAME}"
    folder_path = os.path.join("experiments", folder_name)
    
    print(f"=== Initializing Experiment: {EXP_NAME} ===")
    
    # 2. Build the JSON Ledger
    create_ledger(folder_path, EXP_NAME, BASE_CONFIG)
    
    # 3. Instantiate the massive 256-neuron network
    model = SpikingNet(
        n_mels=BASE_CONFIG["n_mels"],
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
        metrics={"sparsity_pct": 0.0}
    )
    
    print(f"Success! Created {folder_path}")
    print(f"Initial model saved as {model_filename} and ledger initialized.")

if __name__ == "__main__":
    main()