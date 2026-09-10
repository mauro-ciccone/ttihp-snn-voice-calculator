import os
import torch
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0910_1301_24_neurons"
PRUNE_MARGIN = 30  # Weights with absolute value <= 30 are destroyed

def snap_beta_to_shift(beta_float):
    best_diff, best_shift = float("inf"), 1
    for k in range(1, 8):
        diff = abs(beta_float - (1.0 - (1.0 / (2**k))))
        if diff < best_diff:
            best_diff, best_shift = diff, k
    return best_shift

def main():
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    model = FastSpikingNet(
        num_inputs=config["num_inputs"],
        num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"],
        beta=config["beta"]
    )
    ckpt = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location="cpu")
    state_dict = ckpt["model_state_dict"] if "model_state_dict" in ckpt else ckpt
    
    # --- HOTFIX FOR OLD SCALAR BETAS ---
    # If the checkpoint has the old 0-d beta, expand it to match the new 1D model architecture
    if "lif_hidden.beta" in state_dict and state_dict["lif_hidden.beta"].ndim == 0:
        state_dict["lif_hidden.beta"] = state_dict["lif_hidden.beta"].expand(config["num_hidden"])
    
    if "lif_out.beta" in state_dict and state_dict["lif_out.beta"].ndim == 0:
        state_dict["lif_out.beta"] = state_dict["lif_out.beta"].expand(config["num_outputs"])
        
    model.load_state_dict(state_dict)
    
    with torch.no_grad():
        w_in_float = model.fc_in.weight.data
        w_rec_float = model.fc_rec.weight.data
        w_out_float = model.fc_out.weight.data

        # --- 1. Percentile Scaling & Quantization ---
        flat_hidden = torch.cat([w_in_float.flatten(), w_rec_float.flatten()]).abs()
        q_max_hid = torch.quantile(flat_hidden, 0.9815)
        scale_hid = 127.0 / q_max_hid

        w_in_q = torch.clamp(torch.round(w_in_float * scale_hid), -127, 127)
        w_rec_q = torch.clamp(torch.round(w_rec_float * scale_hid), -127, 127)
        thresh_hid = int(round(1.0 * scale_hid.item()))

        flat_out = w_out_float.abs().flatten()
        q_max_out = torch.quantile(flat_out, 0.9815)
        scale_out = 127.0 / q_max_out

        w_out_q = torch.clamp(torch.round(w_out_float * scale_out), -127, 127)
        thresh_out = int(round(1.0 * scale_out.item()))

        # --- 2. Brutal Magnitude Pruning ---
        w_in_q[w_in_q.abs() <= PRUNE_MARGIN] = 0
        w_rec_q[w_rec_q.abs() <= PRUNE_MARGIN] = 0
        w_out_q[w_out_q.abs() <= PRUNE_MARGIN] = 0

        # Hardware report
        total_w = w_in_q.numel() + w_rec_q.numel() + w_out_q.numel()
        surviving_w = int((w_in_q != 0).sum() + (w_rec_q != 0).sum() + (w_out_q != 0).sum())
        print(f"--- SILICON PRUNING REPORT (Margin: {PRUNE_MARGIN}) ---")
        print(f"Total Weights: {total_w}")
        print(f"Surviving Weights (Adders): {surviving_w} ({(surviving_w/total_w)*100:.1f}%)")
        print(f"Deleted Adders: {total_w - surviving_w}")
        print(f"Hidden Threshold: {thresh_hid} | Output Threshold: {thresh_out}\n")

        w_in = w_in_q.int().numpy()
        w_rec = w_rec_q.int().numpy()
        w_out = w_out_q.int().numpy()

        # Extract Betas
        hidden_betas = torch.sigmoid(model.lif_hidden.beta).detach().cpu()
        out_betas = torch.sigmoid(model.lif_out.beta).detach().cpu()

        if hidden_betas.ndim == 0: h_shifts = [snap_beta_to_shift(hidden_betas.item())] * config["num_hidden"]
        else: h_shifts = [snap_beta_to_shift(b.item()) for b in hidden_betas]
            
        if out_betas.ndim == 0: o_shifts = [snap_beta_to_shift(out_betas.item())] * config["num_outputs"]
        else: o_shifts = [snap_beta_to_shift(b.item()) for b in out_betas]

    # --- 3. Generate Unrolled Verilog ---
    v = []
    v.append("`default_nettype none")
    v.append("module snn_core (")
    v.append("    input  wire        clk,")
    v.append("    input  wire        rst_n,")
    v.append("    input  wire        tick_1ms,")
    v.append(f"    input  wire [{config['num_inputs']-1}:0]  in_spikes,")
    v.append(f"    output reg  [{config['num_outputs']-1}:0] out_spikes")
    v.append(");")
    v.append("")
    v.append("    // Membrane registers (16-bit signed)")
    v.append(f"    reg signed [15:0] mem_hidden [0:{config['num_hidden']-1}];")
    v.append(f"    reg signed [15:0] mem_out [0:{config['num_outputs']-1}];")
    v.append(f"    reg [{config['num_hidden']-1}:0] spk_hidden;")
    v.append("")
    
    v.append("    integer i;")
    v.append("    always @(posedge clk or negedge rst_n) begin")
    v.append("        if (!rst_n) begin")
    v.append(f"            spk_hidden <= {config['num_hidden']}'b0;")
    v.append(f"            out_spikes <= {config['num_outputs']}'b0;")
    v.append(f"            for (i = 0; i < {config['num_hidden']}; i = i + 1) mem_hidden[i] <= 16'sd0;")
    v.append(f"            for (i = 0; i < {config['num_outputs']}; i = i + 1) mem_out[i] <= 16'sd0;")
    v.append("        end else if (tick_1ms) begin")
    
    # Hidden Neurons
    for n in range(config['num_hidden']):
        k = h_shifts[n]
        v.append(f"            // --- Hidden Neuron {n} (Shift: {k}) ---")
        v.append(f"            if (spk_hidden[{n}]) mem_hidden[{n}] <= 16'sd0;")
        v.append("            else begin")
        
        terms = [f"(mem_hidden[{n}] - (mem_hidden[{n}] >>> {k}))"]
        for inp in range(config["num_inputs"]):
            wt = w_in[n, inp]
            if wt > 0: terms.append(f"(in_spikes[{inp}] ? 16'sd{wt} : 16'sd0)")
            elif wt < 0: terms.append(f"(in_spikes[{inp}] ? -16'sd{abs(wt)} : 16'sd0)")
        for rec in range(config['num_hidden']):
            wt = w_rec[n, rec]
            if wt > 0: terms.append(f"(spk_hidden[{rec}] ? 16'sd{wt} : 16'sd0)")
            elif wt < 0: terms.append(f"(spk_hidden[{rec}] ? -16'sd{abs(wt)} : 16'sd0)")
        
        sum_expr = " + ".join(terms)
        v.append(f"                mem_hidden[{n}] <= {sum_expr};")
        v.append("            end")
        v.append(f"            spk_hidden[{n}] <= (mem_hidden[{n}] >= 16'sd{thresh_hid});")
        v.append("")
        
    # Output Neurons
    for o in range(config["num_outputs"]):
        k = o_shifts[o]
        v.append(f"            // --- Output Neuron {o} (Shift: {k}) ---")
        v.append(f"            if (out_spikes[{o}]) mem_out[{o}] <= 16'sd0;")
        v.append("            else begin")
        terms = [f"(mem_out[{o}] - (mem_out[{o}] >>> {k}))"]
        for hid in range(config['num_hidden']):
            wt = w_out[o, hid]
            if wt > 0: terms.append(f"(spk_hidden[{hid}] ? 16'sd{wt} : 16'sd0)")
            elif wt < 0: terms.append(f"(spk_hidden[{hid}] ? -16'sd{abs(wt)} : 16'sd0)")
        sum_expr = " + ".join(terms)
        v.append(f"                mem_out[{o}] <= {sum_expr};")
        v.append("            end")
        v.append(f"            out_spikes[{o}] <= (mem_out[{o}] >= 16'sd{thresh_out});")
        v.append("")
        
    v.append("        end")
    v.append("    end")
    v.append("endmodule")
    
    with open("snn_core.v", "w") as f:
        f.write("\n".join(v))
    print("Generated snn_core.v")

if __name__ == "__main__":
    main()