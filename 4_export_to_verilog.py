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

    # Collect sparse connections: list of tuples (target_type, target_idx, source_type, source_idx, weight)
    # target_type: 0 = hidden, 1 = output
    # source_type: 0 = input, 1 = hidden
    sparse_connections = []
    
    # Hidden incoming from inputs
    for h in range(config['num_hidden']):
        for i in range(config['num_inputs']):
            wt = w_in[h, i]
            if wt != 0:
                sparse_connections.append((0, h, 0, i, int(wt)))
                
    # Hidden incoming from hidden (recurrent)
    for h in range(config['num_hidden']):
        for prev_h in range(config['num_hidden']):
            wt = w_rec[h, prev_h]
            if wt != 0:
                sparse_connections.append((0, h, 1, prev_h, int(wt)))
                
    # Output incoming from hidden
    for o in range(config['num_outputs']):
        for h in range(config['num_hidden']):
            wt = w_out[o, h]
            if wt != 0:
                sparse_connections.append((1, o, 1, h, int(wt)))

    num_synapses = len(sparse_connections)
    print(f"Total surviving sparse synapses to serialize: {num_synapses}")

    # Generate Sparse ROM FSM Verilog
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
    v.append("    // State machine and counters")
    v.append("    reg [2:0] state; // 0: Idle, 1: Leak/Reset, 2: Sparse Synapse Accumulation")
    v.append("    reg [4:0] neuron_ptr; // 0 to 28")
    v.append(f"    reg [9:0] syn_ptr;    // 0 to {num_synapses - 1}")
    v.append("")
    v.append("    // Latched inputs for the 1ms frame")
    v.append(f"    reg [{config['num_inputs']-1}:0] latched_in_spikes;")
    v.append(f"    reg [{config['num_hidden']-1}:0] hid_spikes;")
    v.append(f"    reg [{config['num_outputs']-1}:0] latched_out_spikes;")
    v.append("")
    v.append("    // Membrane memory for all 29 neurons (24 hidden + 5 output)")
    v.append("    reg signed [15:0] mem [0:28];")
    v.append("")
    v.append("    // Single shared adder infrastructure")
    v.append("    reg signed [15:0] adder_a;")
    v.append("    reg signed [15:0] adder_b;")
    v.append("    wire signed [15:0] adder_sum = adder_a + adder_b;")
    v.append("")
    v.append("    // Unpacked fields for current ROM entry")
    v.append("    reg         rom_target_type;")
    v.append("    reg [4:0]   rom_target_idx;")
    v.append("    reg         rom_source_type;")
    v.append("    reg [4:0]   rom_source_idx;")
    v.append("    reg signed [15:0] rom_weight;")
    v.append("")

    # Sparse ROM Lookup Table via Combinational Logic
    v.append("    always @(*) begin")
    v.append("        rom_target_type = 1'b0;")
    v.append("        rom_target_idx  = 5'd0;")
    v.append("        rom_source_type = 1'b0;")
    v.append("        rom_source_idx  = 5'd0;")
    v.append("        rom_weight      = 16'sd0;")
    v.append("        case (syn_ptr)")
    
    for idx, (t_type, t_idx, s_type, s_idx, wt) in enumerate(sparse_connections):
        v.append(f"            10'd{idx}: begin")
        v.append(f"                rom_target_type = 1'd{t_type};")
        v.append(f"                rom_target_idx  = 5'd{t_idx};")
        v.append(f"                rom_source_type = 1'd{s_type};")
        v.append(f"                rom_source_idx  = 5'd{s_idx};")
        wt_str = f"-16'sd{abs(wt)}" if wt < 0 else f"16'sd{wt}"
        v.append(f"                rom_weight      = {wt_str};")
        v.append("            end")
        
    v.append("            default: begin")
    v.append("                rom_target_type = 1'b0;")
    v.append("                rom_target_idx  = 5'd0;")
    v.append("                rom_source_type = 1'b0;")
    v.append("                rom_source_idx  = 5'd0;")
    v.append("                rom_weight      = 16'sd0;")
    v.append("            end")
    v.append("        endcase")
    v.append("    end")
    v.append("")

    # Per-neuron shift lookup for leaks
    v.append("    reg [2:0] current_shift;")
    v.append("    always @(*) begin")
    v.append("        case (neuron_ptr)")
    for n in range(config['num_hidden']):
        v.append(f"            5'd{n}: current_shift = 3'd{h_shifts[n]};")
    for o in range(config['num_outputs']):
        idx = o + config['num_hidden']
        v.append(f"            5'd{idx}: current_shift = 3'd{o_shifts[o]};")
    v.append("            default: current_shift = 3'd1;")
    v.append("        endcase")
    v.append("    end")
    v.append("")

    # Sequential Controller & Datapath
    v.append("    wire signed [15:0] current_v = mem[neuron_ptr];")
    v.append("    wire signed [15:0] leaked_v  = current_v - (current_v >>> current_shift);")
    v.append(f"    wire signed [15:0] active_th = (neuron_ptr < 5'd{config['num_hidden']}) ? 16'sd{thresh_hid} : 16'sd{thresh_out};")
    v.append("")

    v.append("    integer i;")
    v.append("    always @(posedge clk or negedge rst_n) begin")
    v.append("        if (!rst_n) begin")
    v.append("            state               <= 3'd0;")
    v.append("            neuron_ptr          <= 5'd0;")
    v.append("            syn_ptr             <= 10'd0;")
    v.append("            latched_in_spikes   <= 7'd0;")
    v.append("            hid_spikes          <= 24'd0;")
    v.append("            latched_out_spikes  <= 5'd0;")
    v.append("            out_spikes          <= 5'd0;")
    v.append("            adder_a             <= 16'sd0;")
    v.append("            adder_b             <= 16'sd0;")
    v.append("            for (i = 0; i < 29; i = i + 1) mem[i] <= 16'sd0;")
    v.append("        end else begin")
    v.append("            case (state)")
    v.append("                3'd0: begin // IDLE waiting for 1ms tick")
    v.append("                    if (tick_1ms) begin")
    v.append("                        latched_in_spikes <= in_spikes;")
    v.append("                        hid_spikes        <= 24'd0; // clear transient spikes for new window")
    v.append("                        neuron_ptr        <= 5'd0;")
    v.append("                        state             <= 3'd1;  // Move to Phase 1: Leak & Threshold")
    v.append("                    end")
    v.append("                end")
    v.append("")
    v.append("                3'd1: begin // PHASE 1: Apply leak, check threshold for all 29 neurons")
    v.append(f"                    if (current_v >= active_th) begin")
    v.append("                        mem[neuron_ptr] <= 16'sd0; // Spike reset")
    v.append(f"                        if (neuron_ptr < 5'd{config['num_hidden']})")
    v.append("                            hid_spikes[neuron_ptr] <= 1'b1;")
    v.append("                        else")
    v.append("                            latched_out_spikes[neuron_ptr - 5'd24] <= 1'b1;")
    v.append("                    end else begin")
    v.append("                        mem[neuron_ptr] <= leaked_v;")
    v.append("                    end")
    v.append("")
    v.append("                    if (neuron_ptr == 5'd28) begin")
    v.append("                        syn_ptr <= 10'd0;")
    v.append("                        state   <= 3'd2; // Move to Phase 2: Sparse Synapse Accumulation")
    v.append("                    end else begin")
    v.append("                        neuron_ptr <= neuron_ptr + 5'd1;")
    v.append("                    end")
    v.append("                end")
    v.append("")
    v.append("                3'd2: begin // PHASE 2: Stream through surviving sparse synapses")
    v.append("                    // Check if source spiked")
    v.append("                    if (rom_source_type == 1'b0) begin")
    v.append("                        if (latched_in_spikes[rom_source_idx]) begin")
    v.append("                            // Add weight to target membrane")
    v.append("                            // Actual target index in mem: if target_type==1, offset by 24")
    v.append("                            reg [4:0] actual_target = rom_target_type ? (rom_target_idx + 5'd24) : rom_target_idx;")
    v.append("                            mem[actual_target] <= mem[actual_target] + rom_weight;")
    v.append("                        end")
    v.append("                    end else begin")
    v.append("                        if (hid_spikes[rom_source_idx]) begin")
    v.append("                            reg [4:0] actual_target = rom_target_type ? (rom_target_idx + 5'd24) : rom_target_idx;")
    v.append("                            mem[actual_target] <= mem[actual_target] + rom_weight;")
    v.append("                        end")
    v.append("                    end")
    v.append("")
    v.append(f"                    if (syn_ptr == 10'd{num_synapses - 1}) begin")
    v.append("                        out_spikes <= latched_out_spikes;")
    v.append("                        latched_out_spikes <= 5'd0;")
    v.append("                        state <= 3'd0; // Return to Idle")
    v.append("                    end else begin")
    v.append("                        syn_ptr <= syn_ptr + 10'd1;")
    v.append("                    end")
    v.append("                end")
    v.append("")
    v.append("                default: state <= 3'd0;")
    v.append("            endcase")
    v.append("        end")
    v.append("    end")
    v.append("endmodule")
    v.append("")
    
    with open("snn_core.v", "w") as f:
        f.write("\n".join(v))
    print("Successfully generated sparse ROM FSM snn_core.v")

if __name__ == "__main__":
    main()