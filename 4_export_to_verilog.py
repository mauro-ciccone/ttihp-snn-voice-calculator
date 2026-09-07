import os
import torch
import copy
from model import FastSpikingNet
from utils_ledger import load_ledger

TARGET_FOLDER = "experiments/0906_2022_without_minus"

def quantize_to_8bit(model):
    q_model = copy.deepcopy(model)
    max_int = 127.0 
    with torch.no_grad():
        flat_hidden = torch.cat([q_model.fc_in.weight.data.flatten(), q_model.fc_rec.weight.data.flatten()]).abs()
        scale_in = max_int / torch.quantile(flat_hidden, 0.9815) 
        q_model.fc_in.weight.data = torch.clamp(torch.round(q_model.fc_in.weight.data * scale_in), min=-max_int, max=max_int)
        q_model.fc_rec.weight.data = torch.clamp(torch.round(q_model.fc_rec.weight.data * scale_in), min=-max_int, max=max_int)
        q_model.lif_hidden.threshold.data = q_model.lif_hidden.threshold.data * scale_in
        
        flat_out = q_model.fc_out.weight.data.abs().flatten()
        scale_out = max_int / torch.quantile(flat_out, 0.9815)
        q_model.fc_out.weight.data = torch.clamp(torch.round(q_model.fc_out.weight.data * scale_out), min=-max_int, max=max_int)
        q_model.lif_out.threshold.data = q_model.lif_out.threshold.data * scale_out
    return q_model

def generate_verilog(model, filename="tt_um_snn_hardwired.v"):
    w_in = model.fc_in.weight.data.cpu().numpy().astype(int)
    w_rec = model.fc_rec.weight.data.cpu().numpy().astype(int)
    w_out = model.fc_out.weight.data.cpu().numpy().astype(int)
    th_hid = int(model.lif_hidden.threshold.item())
    th_out = int(model.lif_out.threshold.item())
    
    with open(filename, "w") as f:
        f.write("`default_nettype none\n\n")
        f.write("module tt_um_snn_hardwired (\n")
        f.write("    input  wire [7:0] ui_in,    // 8-bit Cochlea Spikes\n")
        f.write("    output wire [7:0] uo_out,   // 6-bit Output Spikes + 2 unused\n")
        f.write("    input  wire       clk,\n")
        f.write("    input  wire       rst_n\n")
        f.write(");\n\n")
        
        # 1. Registers
        f.write("    // Membrane Voltages (16-bit to prevent overflow)\n")
        for i in range(40):
            f.write(f"    reg signed [15:0] hid_mem_{i};\n")
        for i in range(6):
            f.write(f"    reg signed [15:0] out_mem_{i};\n")
            
        f.write("\n    // Spike Registers\n")
        f.write("    reg [39:0] hid_spikes;\n")
        f.write("    reg [5:0]  out_spikes;\n\n")
        f.write("    assign uo_out = {2'b00, out_spikes};\n\n")
        
        # 2. Sequential Logic
        f.write("    always @(posedge clk) begin\n")
        f.write("        if (!rst_n) begin\n")
        f.write("            hid_spikes <= 0;\n")
        f.write("            out_spikes <= 0;\n")
        for i in range(40): f.write(f"            hid_mem_{i} <= 0;\n")
        for i in range(6):  f.write(f"            out_mem_{i} <= 0;\n")
        f.write("        end else begin\n")
        
        # Hidden Layer
        f.write("            // --- HIDDEN LAYER ALUs ---\n")
        for i in range(40):
            # Leak: V = V - (V >> 3)
            f.write(f"            hid_mem_{i} <= hid_mem_{i} - (hid_mem_{i} >>> 3)")
            # Add Inputs
            for j in range(8):
                if w_in[i, j] != 0:
                    f.write(f" + (ui_in[{j}] ? 16'sd{w_in[i, j]} : 0)")
            # Add Recurrent
            for j in range(40):
                if w_rec[i, j] != 0:
                    f.write(f" + (hid_spikes[{j}] ? 16'sd{w_rec[i, j]} : 0)")
            f.write(";\n")
            
        f.write("\n            // Hidden Spiking Logic\n")
        for i in range(40):
            f.write(f"            if (hid_mem_{i} >= 16'sd{th_hid}) begin\n")
            f.write(f"                hid_spikes[{i}] <= 1'b1;\n")
            f.write(f"                hid_mem_{i} <= hid_mem_{i} - 16'sd{th_hid};\n")
            f.write("            end else begin\n")
            f.write(f"                hid_spikes[{i}] <= 1'b0;\n")
            f.write("            end\n")

        # Output Layer
        f.write("\n            // --- OUTPUT LAYER ALUs ---\n")
        for i in range(6):
            f.write(f"            out_mem_{i} <= out_mem_{i} - (out_mem_{i} >>> 3)")
            for j in range(40):
                if w_out[i, j] != 0:
                    f.write(f" + (hid_spikes[{j}] ? 16'sd{w_out[i, j]} : 0)")
            f.write(";\n")
            
        f.write("\n            // Output Spiking Logic\n")
        for i in range(6):
            f.write(f"            if (out_mem_{i} >= 16'sd{th_out}) begin\n")
            f.write(f"                out_spikes[{i}] <= 1'b1;\n")
            f.write(f"                out_mem_{i} <= out_mem_{i} - 16'sd{th_out};\n")
            f.write("            end else begin\n")
            f.write(f"                out_spikes[{i}] <= 1'b0;\n")
            f.write("            end\n")
            
        f.write("        end\n")
        f.write("    end\n")
        f.write("endmodule\n")
        print(f"Exported fully hardwired Verilog to {filename}")

def main():
    device = torch.device("cpu")
    ledger = load_ledger(TARGET_FOLDER)
    config = ledger["base_config"]
    
    model = FastSpikingNet(
        num_inputs=config["num_inputs"], num_hidden=config["num_hidden"],
        num_outputs=config["num_outputs"], beta=config["beta"]
    ).to(device)
    
    checkpoint = torch.load(os.path.join(TARGET_FOLDER, "model_best.pth"), map_location=device)
    model.load_state_dict(checkpoint.get("model_state_dict", checkpoint))
    
    q_model = quantize_to_8bit(model)
    generate_verilog(q_model)

if __name__ == "__main__":
    main()