import os
import torch
import copy
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0906_2022_without_minus"

def quantize_to_8bit(model, prune_margin=35): # MASSIVE PRUNE: Delete any weight between -30 and +30
    q_model = copy.deepcopy(model)
    max_int = 127.0 
    with torch.no_grad():
        # Hidden Layer
        flat_hidden = torch.cat([q_model.fc_in.weight.data.flatten(), q_model.fc_rec.weight.data.flatten()]).abs()
        scale_in = max_int / torch.quantile(flat_hidden, 0.9815) 
        q_model.fc_in.weight.data = torch.clamp(torch.round(q_model.fc_in.weight.data * scale_in), min=-max_int, max=max_int)
        q_model.fc_rec.weight.data = torch.clamp(torch.round(q_model.fc_rec.weight.data * scale_in), min=-max_int, max=max_int)
        
        # Prune Hidden
        q_model.fc_in.weight.data[q_model.fc_in.weight.data.abs() < prune_margin] = 0
        q_model.fc_rec.weight.data[q_model.fc_rec.weight.data.abs() < prune_margin] = 0
        q_model.lif_hidden.threshold.data = q_model.lif_hidden.threshold.data * scale_in
        
        # Output Layer
        flat_out = q_model.fc_out.weight.data.abs().flatten()
        scale_out = max_int / torch.quantile(flat_out, 0.9815)
        q_model.fc_out.weight.data = torch.clamp(torch.round(q_model.fc_out.weight.data * scale_out), min=-max_int, max=max_int)
        
        # Prune Output
        q_model.fc_out.weight.data[q_model.fc_out.weight.data.abs() < prune_margin] = 0
        q_model.lif_out.threshold.data = q_model.lif_out.threshold.data * scale_out

        # --- SILICON PRUNING REPORT ---
        total_w = 320 + 1600 + 240
        surviving_w = int((q_model.fc_in.weight.data != 0).sum() + 
                          (q_model.fc_rec.weight.data != 0).sum() + 
                          (q_model.fc_out.weight.data != 0).sum())
        
        print(f"\n--- FAIL-FAST SILICON CHECK ---")
        print(f"Margin: {prune_margin}")
        print(f"Surviving Weights (Adders): {surviving_w} / {total_w} ({(surviving_w/total_w)*100:.1f}%)")
        print(f"Deleted Wires: {total_w - surviving_w}\n")

    return q_model

def generate_fsm_verilog(model, filename="tt_um_snn_fsm.v"):
    w_in = model.fc_in.weight.data.cpu().numpy().astype(int)
    w_rec = model.fc_rec.weight.data.cpu().numpy().astype(int)
    w_out = model.fc_out.weight.data.cpu().numpy().astype(int)
    th_hid = int(model.lif_hidden.threshold.item())
    th_out = int(model.lif_out.threshold.item())
    
    def v_const(val): return f"-10'sd{abs(val)}" if val < 0 else f"10'sd{val}"
    
    with open(filename, "w") as f:
        f.write("`default_nettype none\n\n")
        f.write("module tt_um_snn_fsm (\n")
        f.write("    input  wire [7:0] ui_in,\n")
        f.write("    output wire [7:0] uo_out,\n")
        f.write("    input  wire       clk,\n")
        f.write("    input  wire       rst_n,\n")
        f.write("    input  wire       tick_1ms  // High for 1 cycle every 1ms\n")
        f.write(");\n\n")
        
        f.write("    reg [5:0] state;\n")
        f.write("    reg signed [9:0] mem [0:45];\n")
        f.write("    reg [39:0] hid_spikes;\n")
        f.write("    reg [5:0]  out_spikes;\n\n")
        f.write("    assign uo_out = {2'b00, out_spikes};\n\n")
        
        f.write("    wire signed [9:0] current_v = mem[state];\n")
        f.write("    wire signed [9:0] leaked_v = current_v - (current_v >>> 3);\n")
        f.write("    reg signed [9:0] weight_sum;\n")
        f.write("    wire signed [9:0] active_thresh = (state < 40) ? 10'sd%d : 10'sd%d;\n\n" % (th_hid, th_out))
        
        # Combinatorial Weight Lookup
        f.write("    always @(*) begin\n")
        f.write("        weight_sum = 10'sd0;\n")
        f.write("        case (state)\n")
        
        for i in range(40):
            f.write(f"            6'd{i}: weight_sum = 0")
            for j in range(8):
                if w_in[i, j] != 0: f.write(f" + (ui_in[{j}] ? {v_const(w_in[i, j])} : 0)")
            for j in range(40):
                if w_rec[i, j] != 0: f.write(f" + (hid_spikes[{j}] ? {v_const(w_rec[i, j])} : 0)")
            f.write(";\n")
            
        for i in range(6):
            f.write(f"            6'd{i+40}: weight_sum = 0")
            for j in range(40):
                if w_out[i, j] != 0: f.write(f" + (hid_spikes[{j}] ? {v_const(w_out[i, j])} : 0)")
            f.write(";\n")
            
        f.write("            default: weight_sum = 10'sd0;\n")
        f.write("        endcase\n")
        f.write("    end\n\n")
        
        # Sequential State Machine
        f.write("    wire signed [9:0] next_v = leaked_v + weight_sum;\n")
        f.write("    wire is_spike = (next_v >= active_thresh);\n\n")
        
        f.write("    integer i;\n")
        f.write("    always @(posedge clk) begin\n")
        f.write("        if (!rst_n) begin\n")
        f.write("            state <= 6'd63;\n")
        f.write("            hid_spikes <= 0;\n")
        f.write("            out_spikes <= 0;\n")
        f.write("            for (i = 0; i < 46; i = i + 1) mem[i] <= 0;\n")
        f.write("        end else begin\n")
        f.write("            if (state == 6'd63) begin\n")
        f.write("                if (tick_1ms) state <= 6'd0;\n")
        f.write("            end else if (state < 6'd46) begin\n")
        f.write("                mem[state] <= is_spike ? (next_v - active_thresh) : next_v;\n")
        f.write("                if (state < 40) hid_spikes[state] <= is_spike;\n")
        f.write("                else out_spikes[state - 40] <= is_spike;\n")
        f.write("                if (state == 6'd45) state <= 6'd63;\n")
        f.write("                else state <= state + 1;\n")
        f.write("            end\n")
        f.write("        end\n")
        f.write("    end\n")
        f.write("endmodule\n")

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    model = FastSpikingNet(num_inputs=config["num_inputs"], num_hidden=config["num_hidden"], num_outputs=config["num_outputs"], beta=config["beta"]).to(device)
    checkpoint = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location=device)
    model.load_state_dict(checkpoint.get("model_state_dict", checkpoint))
    generate_fsm_verilog(quantize_to_8bit(model))

if __name__ == "__main__": main()