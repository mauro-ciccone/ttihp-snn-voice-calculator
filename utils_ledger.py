import os
import json
import datetime

def create_ledger(folder_path, exp_name, base_config):
    os.makedirs(folder_path, exist_ok=True)
    ledger_path = os.path.join(folder_path, "ledger.json")
    
    ledger = {
        "experiment_name": exp_name,
        "base_config": base_config,
        "commits": []
    }
    
    with open(ledger_path, "w") as f:
        json.dump(ledger, f, indent=4)
    return ledger_path

def load_ledger(folder_path):
    ledger_path = os.path.join(folder_path, "ledger.json")
    with open(ledger_path, "r") as f:
        return json.load(f)

def append_commit(folder_path, action, model_filename, metrics=None, extra_data=None):
    ledger_path = os.path.join(folder_path, "ledger.json")
    ledger = load_ledger(folder_path)
    
    commit_id = f"{len(ledger['commits']):02d}"
    timestamp = datetime.datetime.now().strftime("%m%d_%H%M")
    
    commit = {
        "commit_id": commit_id,
        "timestamp": timestamp,
        "action": action,
        "model_file": model_filename
    }
    if metrics: commit["metrics"] = metrics
    if extra_data: commit.update(extra_data)
        
    ledger["commits"].append(commit)
    
    with open(ledger_path, "w") as f:
        json.dump(ledger, f, indent=4)
        
    return commit_id
    
def get_latest_commit(folder_path):
    ledger = load_ledger(folder_path)
    if not ledger["commits"]:
        return None
    return ledger["commits"][-1]