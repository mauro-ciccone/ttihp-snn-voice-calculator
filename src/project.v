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
    reg [9:0] neuron_20;
    reg [9:0] neuron_21;
    reg [9:0] neuron_22;
    reg [9:0] neuron_23;
    reg [9:0] neuron_24;
    reg [9:0] neuron_25;
    reg [9:0] neuron_26;
    reg [9:0] neuron_27;
    reg [9:0] neuron_28;
    reg [9:0] neuron_29;

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
            neuron_20 <= 10'd0;
            neuron_21 <= 10'd0;
            neuron_22 <= 10'd0;
            neuron_23 <= 10'd0;
            neuron_24 <= 10'd0;
            neuron_25 <= 10'd0;
            neuron_26 <= 10'd0;
            neuron_27 <= 10'd0;
            neuron_28 <= 10'd0;
            neuron_29 <= 10'd0;
        end else begin
            neuron_0 <= (neuron_0 >> 3) + (neuron_19 << 1) + (neuron_15 >> 2);
            neuron_1 <= (neuron_1 >> 3) + (neuron_17 >> 2) + (neuron_26 >> 1);
            neuron_2 <= (neuron_2 >> 3) + (neuron_1 >> 1) + (neuron_17 >> 1);
            neuron_3 <= (neuron_3 >> 3) + (neuron_1 << 1) + (neuron_26 >> 2);
            neuron_4 <= (neuron_4 >> 3) + (neuron_3 << 1) + (neuron_19 << 1);
            neuron_5 <= (neuron_5 >> 3) + (neuron_27 << 1) + (neuron_2 >> 1);
            neuron_6 <= (neuron_6 >> 3) + (neuron_5 >> 1) + (neuron_8 << 1);
            neuron_7 <= (neuron_7 >> 3) + (neuron_19 >> 1) + (neuron_23 >> 2);
            neuron_8 <= (neuron_8 >> 3) + (neuron_13 >> 1) + (neuron_10 << 1);
            neuron_9 <= (neuron_9 >> 3) + (neuron_18 >> 2) + (neuron_23 << 1);
            neuron_10 <= (neuron_10 >> 3) + (neuron_11 >> 2) + (neuron_14 >> 1);
            neuron_11 <= (neuron_11 >> 3) + (neuron_20 >> 1) + (neuron_21 >> 2);
            neuron_12 <= (neuron_12 >> 3) + (neuron_28 >> 2) + (neuron_18 << 1);
            neuron_13 <= (neuron_13 >> 3) + (neuron_24 >> 2) + (neuron_4 >> 2);
            neuron_14 <= (neuron_14 >> 3) + (neuron_1 >> 2) + (neuron_21 >> 1);
            neuron_15 <= (neuron_15 >> 3) + (neuron_28 >> 2) + (neuron_19 >> 1);
            neuron_16 <= (neuron_16 >> 3) + (neuron_8 >> 1) + (neuron_26 >> 1);
            neuron_17 <= (neuron_17 >> 3) + (neuron_1 >> 1) + (neuron_8 >> 2);
            neuron_18 <= (neuron_18 >> 3) + (neuron_17 >> 1) + (neuron_27 >> 1);
            neuron_19 <= (neuron_19 >> 3) + (neuron_2 >> 2) + (neuron_13 << 1);
            neuron_20 <= (neuron_20 >> 3) + (neuron_0 >> 1) + (neuron_9 >> 2);
            neuron_21 <= (neuron_21 >> 3) + (neuron_11 << 1) + (neuron_21 >> 2);
            neuron_22 <= (neuron_22 >> 3) + (neuron_26 << 1) + (neuron_8 << 1);
            neuron_23 <= (neuron_23 >> 3) + (neuron_12 << 1) + (neuron_21 << 1);
            neuron_24 <= (neuron_24 >> 3) + (neuron_8 >> 2) + (neuron_25 >> 1);
            neuron_25 <= (neuron_25 >> 3) + (neuron_4 >> 1) + (neuron_28 >> 1);
            neuron_26 <= (neuron_26 >> 3) + (neuron_7 >> 2) + (neuron_28 << 1);
            neuron_27 <= (neuron_27 >> 3) + (neuron_7 << 1) + (neuron_7 >> 2);
            neuron_28 <= (neuron_28 >> 3) + (neuron_11 << 1) + (neuron_16 >> 1);
            neuron_29 <= (neuron_29 >> 3) + (neuron_7 >> 2) + (neuron_14 << 1);
        end
    end

    assign uo_out = {neuron_0[9], neuron_1[9], neuron_2[9], neuron_3[9], neuron_4[9], neuron_5[9], neuron_6[9], neuron_7[9]};
endmodule
