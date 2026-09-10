import os
import torch
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0910_1301_24_neurons"
V_THRESH_INT = 256

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
    model.load_state_dict(ckpt["model_state_dict"] if "model_state_dict" in ckpt else ckpt)
    
    with torch.no_grad():
        w_in = torch.round(model.fc_in.weight.data * V_THRESH_INT).clamp(-128, 127).int().numpy()
        w_rec = torch.round(model.fc_rec.weight.data * V_THRESH_INT).clamp(-128, 127).int().numpy()
        w_out = torch.round(model.fc_out.weight.data * V_THRESH_INT).clamp(-128, 127).int().numpy()

        hidden_betas = torch.sigmoid(model.lif_hidden.beta).detach().cpu()
        out_betas = torch.sigmoid(model.lif_out.beta).detach().cpu()

        if hidden_betas.ndim == 0:
            h_shifts = [snap_beta_to_shift(hidden_betas.item())] * 24
        else:
            h_shifts = [snap_beta_to_shift(b.item()) for b in hidden_betas]
            
        if out_betas.ndim == 0:
            o_shifts = [snap_beta_to_shift(out_betas.item())] * config["num_outputs"]
        else:
            o_shifts = [snap_beta_to_shift(b.item()) for b in out_betas]

    # Generate Unrolled Verilog
    v = []
    v.append("// Fully Unrolled 1-to-1 Asynchronous SNN Core")
    v.append("module snn_core (")
    v.append("    input  wire        clk,")
    v.append("    input  wire        rst_n,")
    v.append(f"    input  wire [{config['num_inputs']-1}:0]  in_spikes,")
    v.append(f"    output reg  [{config['num_outputs']-1}:0] out_spikes")
    v.append(");")
    v.append("")
    v.append("    // Membrane registers (16-bit signed)")
    v.append("    reg signed [15:0] mem_hidden [0:23];")
    v.append(f"    reg signed [15:0] mem_out [0:{config['num_outputs']-1}];")
    v.append("    reg [23:0] spk_hidden;")
    v.append("")
    
    v.append("    integer i;")
    v.append("    always @(posedge clk or negedge rst_n) begin")
    v.append("        if (!rst_n) begin")
    v.append("            spk_hidden <= 24'b0;")
    v.append(f"            out_spikes <= {config['num_outputs']}'b0;")
    v.append("            for (i = 0; i < 24; i = i + 1) mem_hidden[i] <= 16'sd0;")
    v.append(f"            for (i = 0; i < {config['num_outputs']}; i = i + 1) mem_out[i] <= 16'sd0;")
    v.append("        end else begin")
    
    # Hidden Neurons
    for n in range(24):
        k = h_shifts[n]
        v.append(f"            // --- Hidden Neuron {n} (Shift: {k}) ---")
        v.append(f"            if (spk_hidden[{n}]) mem_hidden[{n}] <= 16'sd0;")
        v.append("            else begin")
        
        # Build combinational sum using dead-code elimination (skip 0 weights)
        terms = [f"(mem_hidden[{n}] - (mem_hidden[{n}] >>> {k}))"]
        for inp in range(config["num_inputs"]):
            wt = w_in[n, inp]
            if wt > 0:
                terms.append(f"(in_spikes[{inp}] ? 16'sd{wt} : 16'sd0)")
            elif wt < 0:
                terms.append(f"(in_spikes[{inp}] ? -16'sd{abs(wt)} : 16'sd0)")
        for rec in range(24):
            wt = w_rec[n, rec]
            if wt > 0:
                terms.append(f"(spk_hidden[{rec}] ? 16'sd{wt} : 16'sd0)")
            elif wt < 0:
                terms.append(f"(spk_hidden[{rec}] ? -16'sd{abs(wt)} : 16'sd0)")
        
        sum_expr = " + ".join(terms)
        v.append(f"                mem_hidden[{n}] <= {sum_expr};")
        v.append("            end")
        v.append(f"            spk_hidden[{n}] <= (mem_hidden[{n}] >= 16'sd{V_THRESH_INT});")
        v.append("")
        
    # Output Neurons
    for o in range(config["num_outputs"]):
        k = o_shifts[o]
        v.append(f"            // --- Output Neuron {o} (Shift: {k}) ---")
        v.append(f"            if (out_spikes[{o}]) mem_out[{o}] <= 16'sd0;")
        v.append("            else begin")
        terms = [f"(mem_out[{o}] - (mem_out[{o}] >>> {k}))"]
        for hid in range(24):
            wt = w_out[o, hid]
            if wt > 0:
                terms.append(f"(spk_hidden[{hid}] ? 16'sd{wt} : 16'sd0)")
            elif wt < 0:
                terms.append(f"(spk_hidden[{hid}] ? -16'sd{abs(wt)} : 16'sd0)")
        sum_expr = " + ".join(terms)
        v.append(f"                mem_out[{o}] <= {sum_expr};")
        v.append("            end")
        v.append(f"            out_spikes[{o}] <= (mem_out[{o}] >= 16'sd{V_THRESH_INT});")
        v.append("")
        
    v.append("        end")
    v.append("    end")
    v.append("endmodule")
    
    with open("snn_core.v", "w") as f:
        f.write("\n".join(v))
    print("Generated snn_core.v")

    # Generate Yosys synthesis script
    ys = [
        "read_verilog snn_core.v",
        "hierarchy -check -top snn_core",
        "proc; opt; fsm; opt; memory; opt",
        "techmap; opt",
        "stat"
    ]
    with open("synth.ys", "w") as f:
        f.write("\n".join(ys))
    print("Generated synth.ys")
    print("\nRun: yosys synth.ys to inspect resource and gate counts.")

if __name__ == "__main__":
    main()