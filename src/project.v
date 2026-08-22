`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;
    wire _unused = &{ena, ui_in, uio_in, 1'b0};

    reg [9:0] neuron_0;
    reg [9:0] neuron_1;
    reg [9:0] neuron_2;
    reg [9:0] neuron_3;
    reg [9:0] neuron_4;
    reg [9:0] neuron_5;
    reg [9:0] neuron_6;
    reg [9:0] neuron_7;
    reg [9:0] neuron_8;
    reg [9:0] neuron_9;
    reg [9:0] neuron_10;
    reg [9:0] neuron_11;
    reg [9:0] neuron_12;
    reg [9:0] neuron_13;
    reg [9:0] neuron_14;
    reg [9:0] neuron_15;
    reg [9:0] neuron_16;
    reg [9:0] neuron_17;
    reg [9:0] neuron_18;
    reg [9:0] neuron_19;

    always @(posedge clk) begin
        if (!rst_n) begin
            neuron_0 <= 10'd0;
            neuron_1 <= 10'd0;
            neuron_2 <= 10'd0;
            neuron_3 <= 10'd0;
            neuron_4 <= 10'd0;
            neuron_5 <= 10'd0;
            neuron_6 <= 10'd0;
            neuron_7 <= 10'd0;
            neuron_8 <= 10'd0;
            neuron_9 <= 10'd0;
            neuron_10 <= 10'd0;
            neuron_11 <= 10'd0;
            neuron_12 <= 10'd0;
            neuron_13 <= 10'd0;
            neuron_14 <= 10'd0;
            neuron_15 <= 10'd0;
            neuron_16 <= 10'd0;
            neuron_17 <= 10'd0;
            neuron_18 <= 10'd0;
            neuron_19 <= 10'd0;
        end else begin
            neuron_0 <= (neuron_0 >> 3) + (neuron_6 >> 2) + (neuron_5 >> 2);
            neuron_1 <= (neuron_1 >> 3) + (neuron_18 >> 2) + (neuron_11 >> 2);
            neuron_2 <= (neuron_2 >> 3) + (neuron_13 << 1) + (neuron_6 << 1);
            neuron_3 <= (neuron_3 >> 3) + (neuron_19 << 1) + (neuron_14 << 1);
            neuron_4 <= (neuron_4 >> 3) + (neuron_1 >> 2) + (neuron_13 << 1);
            neuron_5 <= (neuron_5 >> 3) + (neuron_5 >> 2) + (neuron_17 << 1);
            neuron_6 <= (neuron_6 >> 3) + (neuron_16 >> 2) + (neuron_7 >> 1);
            neuron_7 <= (neuron_7 >> 3) + (neuron_11 >> 1) + (neuron_12 >> 1);
            neuron_8 <= (neuron_8 >> 3) + (neuron_2 >> 1) + (neuron_11 >> 1);
            neuron_9 <= (neuron_9 >> 3) + (neuron_14 >> 2) + (neuron_0 >> 1);
            neuron_10 <= (neuron_10 >> 3) + (neuron_8 >> 2) + (neuron_19 << 1);
            neuron_11 <= (neuron_11 >> 3) + (neuron_3 >> 1) + (neuron_12 >> 2);
            neuron_12 <= (neuron_12 >> 3) + (neuron_0 >> 1) + (neuron_17 << 1);
            neuron_13 <= (neuron_13 >> 3) + (neuron_15 >> 2) + (neuron_13 >> 2);
            neuron_14 <= (neuron_14 >> 3) + (neuron_19 >> 1) + (neuron_3 >> 2);
            neuron_15 <= (neuron_15 >> 3) + (neuron_6 >> 2) + (neuron_11 >> 1);
            neuron_16 <= (neuron_16 >> 3) + (neuron_7 >> 1) + (neuron_7 >> 2);
            neuron_17 <= (neuron_17 >> 3) + (neuron_11 << 1) + (neuron_1 << 1);
            neuron_18 <= (neuron_18 >> 3) + (neuron_7 >> 2) + (neuron_10 >> 1);
            neuron_19 <= (neuron_19 >> 3) + (neuron_8 >> 2) + (neuron_8 >> 1);
        end
    end

    assign uo_out = {neuron_0[9], neuron_1[9], neuron_2[9], neuron_3[9], neuron_4[9], neuron_5[9], neuron_6[9], neuron_7[9]};
endmodule
