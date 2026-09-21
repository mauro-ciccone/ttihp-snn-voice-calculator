import os
import torch

TARGET_FOLDER = "experiments/0916_2317_6_neuron_cochlea_no_vier"

def get_array(val, expected_len):
    if isinstance(val, torch.Tensor):
        if val.numel() == 1: return [int(val.item())] * expected_len
        return val.int().tolist()
    return [int(val)] * expected_len

def main():
    print("=== Phase 8: ASIC Verilog Compiler (NO WTA - BASE SPIKE EXPORT) ===")
    
    base_model = torch.load(os.path.join(TARGET_FOLDER, "pure_integer_model.pt"), map_location="cpu")
    
    w_in_int = base_model["w_in_int"].numpy()     
    w_rec_int = base_model["w_rec_int"].numpy()   
    w_out_int = base_model["w_out_int"].numpy()  
    
    num_hidden, num_inputs = w_in_int.shape
    num_outputs = w_out_int.shape[0] # Should be 6
    
    g_in = base_model.get("g_in")
    g_rec = base_model.get("g_rec")
    g_out = base_model.get("g_out")
    
    pos_masks_in = base_model["pos_masks_in"].numpy()
    neg_masks_in = base_model["neg_masks_in"].numpy()
    pos_masks_rec = base_model["pos_masks_rec"].numpy()
    neg_masks_rec = base_model["neg_masks_rec"].numpy()
    pos_masks_out = base_model["pos_masks_out"].numpy()
    neg_masks_out = base_model["neg_masks_out"].numpy()
    
    thresh_hid = int(round(1.0 / base_model["delta_in"].item()))
    thresh_out = int(round(1.0 / base_model["delta_out"].item()))
    
    fb_hid = get_array(base_model["frac_bits_hid"], num_hidden)
    fb_out = get_array(base_model["frac_bits_out"], num_outputs)
    
    v_path = "snn_core.v"
    with open(v_path, "w") as f:
        f.write("`default_nettype none\n")
        f.write("module snn_core (\n")
        f.write("    input  wire       clk_1mhz,\n")
        f.write("    input  wire       rst_n,\n")
        f.write("    input  wire       tick_1ms,\n")
        f.write(f"    input  wire [{num_inputs-1}:0] cochlea_spikes,\n") 
        f.write("    output wire [5:0] base_spikes // Directly exporting the 6 classes\n")
        f.write(");\n\n")
        
        # --- HIDDEN LAYER ---
        f.write("    // ==========================================\n")
        f.write("    // HIDDEN LAYER (OR-Gate Bitwise Synthesis)\n")
        f.write("    // ==========================================\n")
        f.write(f"    wire [{num_hidden-1}:0] hid_spikes;\n\n")
        
        for i in range(num_hidden):
            f.write(f"    reg signed [11:0] mem_hid_{i};\n")
            pos_terms, neg_terms = [], []
            for g in range(g_in):
                for b in range(8):
                    j_pos = [j for j in range(num_inputs) if pos_masks_in[g, i, j] and (abs(int(w_in_int[i, j])) & (1 << b))]
                    if j_pos: pos_terms.append("(" + " | ".join([f"cochlea_spikes[{j}]" for j in j_pos]) + f") << {b}")
                    j_neg = [j for j in range(num_inputs) if neg_masks_in[g, i, j] and (abs(int(w_in_int[i, j])) & (1 << b))]
                    if j_neg: neg_terms.append("(" + " | ".join([f"cochlea_spikes[{j}]" for j in j_neg]) + f") << {b}")
            
            for g in range(g_rec):
                for b in range(8):
                    j_pos = [j for j in range(num_hidden) if pos_masks_rec[g, i, j] and (abs(int(w_rec_int[i, j])) & (1 << b))]
                    if j_pos: pos_terms.append("(" + " | ".join([f"hid_spikes[{j}]" for j in j_pos]) + f") << {b}")
                    j_neg = [j for j in range(num_hidden) if neg_masks_rec[g, i, j] and (abs(int(w_rec_int[i, j])) & (1 << b))]
                    if j_neg: neg_terms.append("(" + " | ".join([f"hid_spikes[{j}]" for j in j_neg]) + f") << {b}")
            
            pos_expr = "\n        + ".join(pos_terms) if pos_terms else "0"
            neg_expr = "\n        + ".join(neg_terms) if neg_terms else "0"
            f.write(f"    wire signed [11:0] pos_in_hid_{i} = {pos_expr};\n")
            f.write(f"    wire signed [11:0] neg_in_hid_{i} = {neg_expr};\n")
            f.write(f"    wire signed [11:0] sum_hid_{i} = pos_in_hid_{i} - neg_in_hid_{i};\n")
            f.write(f"    assign hid_spikes[{i}] = (mem_hid_{i} >= {thresh_hid});\n")
            f.write(f"    wire signed [11:0] next_hid_{i} = mem_hid_{i} - (mem_hid_{i} >>> {fb_hid[i]}) + sum_hid_{i};\n\n")

        # --- BASE OUTPUT LAYER ---
        f.write("    // ==========================================\n")
        f.write("    // BASE OUTPUT LAYER (OR-Gate Bitwise Synthesis)\n")
        f.write("    // ==========================================\n")
        
        for i in range(num_outputs):
            f.write(f"    reg signed [11:0] mem_base_{i};\n")
            pos_terms, neg_terms = [], []
            for g in range(g_out):
                for b in range(8):
                    j_pos = [j for j in range(num_hidden) if pos_masks_out[g, i, j] and (abs(int(w_out_int[i, j])) & (1 << b))]
                    if j_pos: pos_terms.append("(" + " | ".join([f"hid_spikes[{j}]" for j in j_pos]) + f") << {b}")
                    j_neg = [j for j in range(num_hidden) if neg_masks_out[g, i, j] and (abs(int(w_out_int[i, j])) & (1 << b))]
                    if j_neg: neg_terms.append("(" + " | ".join([f"hid_spikes[{j}]" for j in j_neg]) + f") << {b}")
            
            pos_expr = "\n        + ".join(pos_terms) if pos_terms else "0"
            neg_expr = "\n        + ".join(neg_terms) if neg_terms else "0"
            f.write(f"    wire signed [11:0] pos_in_base_{i} = {pos_expr};\n")
            f.write(f"    wire signed [11:0] neg_in_base_{i} = {neg_expr};\n")
            f.write(f"    wire signed [11:0] sum_base_{i} = pos_in_base_{i} - neg_in_base_{i};\n")
            f.write(f"    assign base_spikes[{i}] = (mem_base_{i} >= {thresh_out});\n")
            f.write(f"    wire signed [11:0] next_base_{i} = mem_base_{i} - (mem_base_{i} >>> {fb_out[i]}) + sum_base_{i};\n\n")

        # --- UPDATES ---
        f.write("    // ==========================================\n")
        f.write("    // SYNCHRONOUS MEMBRANE UPDATES\n")
        f.write("    // ==========================================\n")
        f.write("    always @(posedge clk_1mhz or negedge rst_n) begin\n")
        f.write("        if (!rst_n) begin\n")
        for i in range(num_hidden): f.write(f"            mem_hid_{i} <= 0;\n")
        for i in range(num_outputs): f.write(f"            mem_base_{i} <= 0;\n")
        f.write("        end else if (tick_1ms) begin\n")
        for i in range(num_hidden): f.write(f"            mem_hid_{i} <= hid_spikes[{i}] ? 0 : next_hid_{i};\n")
        for i in range(num_outputs): f.write(f"            mem_base_{i} <= base_spikes[{i}] ? 0 : next_base_{i};\n")
        f.write("        end\n    end\n")
        f.write("endmodule\n")

    print(f"✅ Successfully compiled descriptive silicon RTL to {v_path}")

if __name__ == "__main__":
    main()