import os
import torch
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0910_1301_24_neurons"
PRUNE_MARGIN = 30

def snap_beta_to_shift(beta_float):
    best_diff, best_shift = float("inf"), 1
    for k in range(1, 8):
        diff = abs(beta_float - (1.0 - (1.0 / (2**k))))
        if diff < best_diff:
            best_diff, best_shift = diff, k
    return best_shift

def v_const(val): 
    return f"-16'sd{abs(val)}" if val < 0 else f"16'sd{val}"

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
    
    if "lif_hidden.beta" in state_dict and state_dict["lif_hidden.beta"].ndim == 0:
        state_dict["lif_hidden.beta"] = state_dict["lif_hidden.beta"].expand(config["num_hidden"])
    if "lif_out.beta" in state_dict and state_dict["lif_out.beta"].ndim == 0:
        state_dict["lif_out.beta"] = state_dict["lif_out.beta"].expand(config["num_outputs"])
        
    model.load_state_dict(state_dict)

    with torch.no_grad():
        w_in_float = model.fc_in.weight.data
        w_rec_float = model.fc_rec.weight.data
        w_out_float = model.fc_out.weight.data

        # Scaling
        flat_hidden = torch.cat([w_in_float.flatten(), w_rec_float.flatten()]).abs()
        scale_hid = 127.0 / torch.quantile(flat_hidden, 0.9815)
        w_in_q = torch.clamp(torch.round(w_in_float * scale_hid), -127, 127)
        w_rec_q = torch.clamp(torch.round(w_rec_float * scale_hid), -127, 127)
        thresh_hid = int(round(1.0 * scale_hid.item()))

        flat_out = w_out_float.abs().flatten()
        scale_out = 127.0 / torch.quantile(flat_out, 0.9815)
        w_out_q = torch.clamp(torch.round(w_out_float * scale_out), -127, 127)
        thresh_out = int(round(1.0 * scale_out.item()))

        # Pruning
        w_in_q[w_in_q.abs() <= PRUNE_MARGIN] = 0
        w_rec_q[w_rec_q.abs() <= PRUNE_MARGIN] = 0
        w_out_q[w_out_q.abs() <= PRUNE_MARGIN] = 0

        w_in = w_in_q.int().numpy()
        w_rec = w_rec_q.int().numpy()
        w_out = w_out_q.int().numpy()

        hidden_betas = torch.sigmoid(model.lif_hidden.beta).detach().cpu()
        out_betas = torch.sigmoid(model.lif_out.beta).detach().cpu()
        
        h_shifts = [snap_beta_to_shift(b.item()) for b in hidden_betas]
        o_shifts = [snap_beta_to_shift(b.item()) for b in out_betas]

    # Generate FSM Verilog
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
    v.append("    reg [4:0] state; // 0-23: Hidden, 24-28: Output, 31: Idle")
    v.append(f"    reg signed [15:0] mem [0:{config['num_hidden'] + config['num_outputs'] - 1}];")
    v.append(f"    reg [{config['num_hidden']-1}:0] hid_spikes;")
    v.append("")
    v.append("    wire signed [15:0] current_v = mem[state];")
    v.append("    reg [2:0] current_shift;")
    v.append("    reg signed [15:0] weight_sum;")
    v.append("    wire signed [15:0] leaked_v = current_v - (current_v >>> current_shift);")
    v.append("    wire signed [15:0] next_v = leaked_v + weight_sum;")
    v.append(f"    wire signed [15:0] active_thresh = (state < {config['num_hidden']}) ? 16'sd{thresh_hid} : 16'sd{thresh_out};")
    v.append("    wire is_spike = (next_v >= active_thresh);")
    v.append("")
    
    # Combinational MUX for shifts and weights
    v.append("    always @(*) begin")
    v.append("        weight_sum = 16'sd0;")
    v.append("        current_shift = 3'd1;")
    v.append("        case (state)")
    
    for n in range(config['num_hidden']):
        v.append(f"            5'd{n}: begin")
        v.append(f"                current_shift = 3'd{h_shifts[n]};")
        terms = []
        for inp in range(config["num_inputs"]):
            if w_in[n, inp] != 0: terms.append(f"(in_spikes[{inp}] ? {v_const(w_in[n, inp])} : 16'sd0)")
        for rec in range(config["num_hidden"]):
            if w_rec[n, rec] != 0: terms.append(f"(hid_spikes[{rec}] ? {v_const(w_rec[n, rec])} : 16'sd0)")
        if not terms: terms = ["16'sd0"]
        v.append(f"                weight_sum = {' + '.join(terms)};")
        v.append("            end")
        
    for o in range(config['num_outputs']):
        idx = o + config['num_hidden']
        v.append(f"            5'd{idx}: begin")
        v.append(f"                current_shift = 3'd{o_shifts[o]};")
        terms = []
        for hid in range(config["num_hidden"]):
            if w_out[o, hid] != 0: terms.append(f"(hid_spikes[{hid}] ? {v_const(w_out[o, hid])} : 16'sd0)")
        if not terms: terms = ["16'sd0"]
        v.append(f"                weight_sum = {' + '.join(terms)};")
        v.append("            end")
        
    v.append("            default: begin")
    v.append("                weight_sum = 16'sd0;")
    v.append("                current_shift = 3'd1;")
    v.append("            end")
    v.append("        endcase")
    v.append("    end")
    v.append("")
    
    # Sequential State Update
    v.append("    integer i;")
    v.append("    always @(posedge clk or negedge rst_n) begin")
    v.append("        if (!rst_n) begin")
    v.append("            state <= 5'd31;")
    v.append(f"            hid_spikes <= {config['num_hidden']}'d0;")
    v.append(f"            out_spikes <= {config['num_outputs']}'d0;")
    v.append(f"            for (i = 0; i < {config['num_hidden'] + config['num_outputs']}; i = i + 1) mem[i] <= 16'sd0;")
    v.append("        end else begin")
    v.append("            if (state == 5'd31) begin")
    v.append("                if (tick_1ms) state <= 5'd0;")
    v.append(f"            end else if (state < 5'd{config['num_hidden'] + config['num_outputs']}) begin")
    v.append("                mem[state] <= is_spike ? 16'sd0 : next_v;")
    v.append(f"                if (state < 5'd{config['num_hidden']}) hid_spikes[state] <= is_spike;")
    v.append(f"                else out_spikes[state - 5'd{config['num_hidden']}] <= is_spike;")
    v.append("")
    v.append(f"                if (state == 5'd{config['num_hidden'] + config['num_outputs'] - 1}) state <= 5'd31;")
    v.append("                else state <= state + 1;")
    v.append("            end")
    v.append("        end")
    v.append("    end")
    v.append("endmodule")
    
    with open("snn_core.v", "w") as f:
        f.write("\n".join(v))
    print("Generated FSM-based snn_core.v")

if __name__ == "__main__":
    main()