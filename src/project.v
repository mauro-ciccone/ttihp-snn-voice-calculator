`default_nettype none

module tt_um_example #(
    // Adjust this number to test placement limits!
    // e.g., 500, 750, 1000, 1200, 1500
    parameter integer NUM_BITS = 1200
) (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Unused IOs tied off
    assign uio_oe  = 8'b00000000;
    assign uio_out = 8'b00000000;

    // --- Stress Test Register Bank ---
    reg [NUM_BITS-1:0] reg_bank;

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Non-zero initialization pattern to force alternating DFF types
            for (i = 0; i < NUM_BITS; i = i + 1) begin
                reg_bank[i] <= i[0];
            end
        end else if (ena) begin
            // Circular neighbor feedback + external input toggle
            reg_bank[0] <= reg_bank[NUM_BITS-1] ^ ui_in[0];
            for (i = 1; i < NUM_BITS; i = i + 1) begin
                reg_bank[i] <= reg_bank[i] ^ reg_bank[i-1] ^ ui_in[i % 8];
            end
        end
    end

    // --- XOR Reduction Tree to Dedicated Outputs ---
    // Guarantees Yosys cannot prune a single flip-flop
    reg [7:0] out_reduction;
    integer b;
    always @(*) begin
        out_reduction = 8'h00;
        for (b = 0; b < NUM_BITS; b = b + 1) begin
            out_reduction[b % 8] = out_reduction[b % 8] ^ reg_bank[b];
        end
    end

    assign uo_out = out_reduction ^ uio_in;

endmodule