import random

def build_dummy_verilog(num_neurons, num_synapses, out_path="src/project.v"):
    with open(out_path, "w") as f:
        f.write("`default_nettype none\n\n")
        f.write("module tt_um_example (\n")
        f.write("    input  wire [7:0] ui_in,\n")
        f.write("    output wire [7:0] uo_out,\n")
        f.write("    input  wire [7:0] uio_in,\n")
        f.write("    output wire [7:0] uio_out,\n")
        f.write("    output wire [7:0] uio_oe,\n")
        f.write("    input  wire       ena,\n")
        f.write("    input  wire       clk,\n")
        f.write("    input  wire       rst_n\n")
        f.write(");\n\n")
        
        f.write("    assign uio_out = 8'b0;\n")
        f.write("    assign uio_oe  = 8'b0;\n")
        # Tie off unused inputs to prevent OpenLane warnings
        f.write("    wire _unused = &{ena, ui_in, uio_in, 1'b0};\n\n")
        
        # 1. Instantiate the neuron memory registers
        for i in range(num_neurons):
            f.write(f"    reg [9:0] neuron_{i};\n")
            
        f.write("\n    always @(posedge clk) begin\n")
        f.write("        if (!rst_n) begin\n")
        for i in range(num_neurons):
            f.write(f"            neuron_{i} <= 10'd0;\n")
        f.write("        end else begin\n")
        
        # 2. Generate random hardwired integer math
        synapses_per_neuron = num_synapses // num_neurons
        for i in range(num_neurons):
            terms = [f"(neuron_{i} >> 3)"] # Simulated leak decay
            for _ in range(synapses_per_neuron):
                src = random.randint(0, num_neurons - 1)
                shift = random.choice(["<< 1", ">> 1", ">> 2"])
                terms.append(f"(neuron_{src} {shift})")
            
            expr = " + ".join(terms)
            f.write(f"            neuron_{i} <= {expr};\n")
            
        f.write("        end\n    end\n\n")
        
        # 3. Output assignment to prevent synthesis tools from pruning the logic
        f.write("    assign uo_out = {")
        f.write(", ".join(f"neuron_{i}[9]" for i in range(8)))
        f.write("};\n")
        
        f.write("endmodule\n")

if __name__ == "__main__":
    import sys
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 30
    s = int(sys.argv[2]) if len(sys.argv) > 2 else 80
    build_dummy_verilog(n, s)
    print(f"Generated src/project.v with {n} neurons and {s} synapses.")