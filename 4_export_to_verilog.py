import os
import torch
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0910_1301_24_neurons"
PRUNE_MARGIN = 40  # Clean cutoff to shed boundary weights

def snap_beta_to_shift(beta_float):
    best_diff, best_shift = float("inf"), 1
    for k in range(1, 8):
        diff = abs(beta_float - (1.0 - (1.0 / (2**k))))
        if diff < best_diff:
            best_diff, best_shift = diff, k
    return best_shift

def v_const(val): 
    return f"-10'sd{abs(val)}" if val < 0 else f"10'sd{val}"

def main():
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    model = FastSpikingNet(
        num_inputs=config["num_inputs"], num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"], beta=config["beta"]
    )
    
    ckpt = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location="cpu")
    state_dict = ckpt["model_state_dict"] if "model_state_dict" in ckpt else ckpt
    
    if "lif_hidden.beta" in state_dict and state_dict["lif_hidden.beta"].ndim == 0:
        state_dict["lif_hidden.beta"] = state_dict["lif_hidden.beta"].expand(config["num_hidden"])
    if "lif_out.beta" in state_dict and state_dict["lif_out.beta"].ndim == 0:
        state_dict["lif_out.beta"] = state_dict["lif_out.beta"].expand(config["num_outputs"])
    model.load_state_dict(state_dict)

    with torch.no_grad():
        w_in_float, w_rec_float, w_out_float = model.fc_in.weight.data, model.fc_rec.weight.data, model.fc_out.weight.data

        # Scaling
        scale_hid = 127.0 / torch.quantile(torch.cat([w_in_float.flatten(), w_rec_float.flatten()]).abs(), 0.9815)
        w_in_q = torch.clamp(torch.round(w_in_float * scale_hid), -127, 127)
        w_rec_q = torch.clamp(torch.round(w_rec_float * scale_hid), -127, 127)
        thresh_hid = int(round(1.0 * scale_hid.item()))

        scale_out = 127.0 / torch.quantile(w_out_float.abs().flatten(), 0.9815)
        w_out_q = torch.clamp(torch.round(w_out_float * scale_out), -127, 127)
        thresh_out = int(round(1.0 * scale_out.item()))

        # Pruning
        w_in_q[w_in_q.abs() <= PRUNE_MARGIN] = 0
        w_rec_q[w_rec_q.abs() <= PRUNE_MARGIN] = 0
        w_out_q[w_out_q.abs() <= PRUNE_MARGIN] = 0

        w_in, w_rec, w_out = w_in_q.int().numpy(), w_rec_q.int().numpy(), w_out_q.int().numpy()
        h_shifts = [snap_beta_to_shift(b.item()) for b in torch.sigmoid(model.lif_hidden.beta).detach().cpu()]
        o_shifts = [snap_beta_to_shift(b.item()) for b in torch.sigmoid(model.lif_out.beta).detach().cpu()]

    synapses = []
    for n in range(config["num_hidden"]):
        for i in range(config["num_inputs"]):
            if w_in[n, i] != 0: synapses.append((0, i, n, w_in[n, i]))
        for r in range(config["num_hidden"]):
            if w_rec[n, r] != 0: synapses.append((1, r, n, w_rec[n, r]))
    for o in range(config["num_outputs"]):
        for r in range(config["num_hidden"]):
            if w_out[o, r] != 0: synapses.append((1, r, o + config["num_hidden"], w_out[o, r]))

    NUM_SYN = len(synapses)
    print(f"Pruned to {NUM_SYN} synapses. Generating 10-bit Datapath SNN Core...")

    v = [
        "`default_nettype none",
        "module snn_core (",
        "    input  wire        clk,",
        "    input  wire        rst_n,",
        "    input  wire        tick_1ms,",
        f"    input  wire [{config['num_inputs']-1}:0]  in_spikes,",
        f"    output reg  [{config['num_outputs']-1}:0] out_spikes",
        ");",
        "",
        "    reg [8:0] state;  // SHRUNK TO 9 BITS to dramatically reduce fanout logic",
        f"    reg signed [9:0] mem [0:{config['num_hidden'] + config['num_outputs'] - 1}];",
        f"    reg [{config['num_hidden']-1}:0] hid_spikes;",
        "",
        "    // --- 10-BIT COMPACT ALU CONTROL ---",
        "    reg [4:0] alu_tgt;",
        "    reg [4:0] alu_src;",
        "    reg alu_is_hid_src;",
        "    reg signed [9:0] alu_w;",
        "    reg [2:0] alu_shift;",
        "    reg alu_is_leak, alu_is_syn, alu_is_thresh;",
        "",
        "    always @(*) begin",
        "        alu_tgt = 5'd0; alu_src = 5'd0; alu_is_hid_src = 1'b0; alu_w = 10'sd0;",
        "        alu_shift = 3'd1; alu_is_leak = 1'b0; alu_is_syn = 1'b0; alu_is_thresh = 1'b0;",
        "",
        "        if (state < 9'd29) begin",
        "            alu_is_leak = 1'b1;",
        "            alu_tgt = state[4:0];",
        "            case(state)"
    ]

    for i in range(29):
        s = h_shifts[i] if i < 24 else o_shifts[i-24]
        v.append(f"                9'd{i}: alu_shift = 3'd{s};")

    v.extend([
        "            endcase",
        f"        end else if (state < 9'd{29 + NUM_SYN}) begin",
        "            alu_is_syn = 1'b1;",
        "            case(state)"
    ])

    for i, (is_hid, src, tgt, w) in enumerate(synapses):
        v.append(f"                9'd{29 + i}: begin alu_tgt = 5'd{tgt}; alu_src = 5'd{src}; alu_is_hid_src = 1'b{is_hid}; alu_w = {v_const(w)}; end")

    v.extend([
        "            endcase",
        f"        end else if (state < 9'd{58 + NUM_SYN}) begin",
        "            alu_is_thresh = 1'b1;",
        f"            alu_tgt = state[4:0] - 5'd{((29 + NUM_SYN) % 32)};",
        "        end",
        "    end",
        "",
        "    // Single external spike multiplexer",
        "    wire spike_active = alu_is_hid_src ? hid_spikes[alu_src] : in_spikes[alu_src[2:0]];",
        "    wire signed [9:0] current_v = mem[alu_tgt];",
        f"    wire signed [9:0] thresh_val = (alu_tgt < 24) ? 10'sd{thresh_hid} : 10'sd{thresh_out};",
        "    wire is_spike = (current_v >= thresh_val);",
        "",
        "    integer i;",
        "    always @(posedge clk or negedge rst_n) begin",
        "        if (!rst_n) begin",
        "            state <= 9'h1FF;",
        f"            hid_spikes <= {config['num_hidden']}'d0;",
        f"            out_spikes <= {config['num_outputs']}'d0;",
        f"            for (i = 0; i < {config['num_hidden'] + config['num_outputs']}; i = i + 1) mem[i] <= 10'sd0;",
        "        end else if (tick_1ms) begin",
        "            state <= 9'd0;",
        "        end else if (state != 9'h1FF) begin",
        "            if (alu_is_leak) mem[alu_tgt] <= current_v - (current_v >>> alu_shift);",
        "            else if (alu_is_thresh) begin",
        "                mem[alu_tgt] <= is_spike ? 10'sd0 : current_v;",
        "                if (alu_tgt < 24) hid_spikes[alu_tgt] <= is_spike;",
        "                else out_spikes[alu_tgt - 24] <= is_spike;",
        "            end else if (alu_is_syn && spike_active) begin",
        "                mem[alu_tgt] <= current_v + alu_w;",
        "            end",
        "",
        f"            if (state == 9'd{57 + NUM_SYN}) state <= 9'h1FF;",
        "            else state <= state + 9'd1;",
        "        end",
        "    end",
        "endmodule"
    ])

    with open("snn_core.v", "w") as f:
        f.write("\n".join(v))
    print("Generated snn_core.v")

if __name__ == "__main__":
    main()