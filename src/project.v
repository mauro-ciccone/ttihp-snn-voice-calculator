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
    reg [9:0] neuron_30;
    reg [9:0] neuron_31;
    reg [9:0] neuron_32;
    reg [9:0] neuron_33;
    reg [9:0] neuron_34;
    reg [9:0] neuron_35;
    reg [9:0] neuron_36;
    reg [9:0] neuron_37;
    reg [9:0] neuron_38;
    reg [9:0] neuron_39;
    reg [9:0] neuron_40;
    reg [9:0] neuron_41;
    reg [9:0] neuron_42;
    reg [9:0] neuron_43;
    reg [9:0] neuron_44;
    reg [9:0] neuron_45;
    reg [9:0] neuron_46;
    reg [9:0] neuron_47;
    reg [9:0] neuron_48;
    reg [9:0] neuron_49;
    reg [9:0] neuron_50;
    reg [9:0] neuron_51;
    reg [9:0] neuron_52;
    reg [9:0] neuron_53;
    reg [9:0] neuron_54;

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
            neuron_30 <= 10'd0;
            neuron_31 <= 10'd0;
            neuron_32 <= 10'd0;
            neuron_33 <= 10'd0;
            neuron_34 <= 10'd0;
            neuron_35 <= 10'd0;
            neuron_36 <= 10'd0;
            neuron_37 <= 10'd0;
            neuron_38 <= 10'd0;
            neuron_39 <= 10'd0;
            neuron_40 <= 10'd0;
            neuron_41 <= 10'd0;
            neuron_42 <= 10'd0;
            neuron_43 <= 10'd0;
            neuron_44 <= 10'd0;
            neuron_45 <= 10'd0;
            neuron_46 <= 10'd0;
            neuron_47 <= 10'd0;
            neuron_48 <= 10'd0;
            neuron_49 <= 10'd0;
            neuron_50 <= 10'd0;
            neuron_51 <= 10'd0;
            neuron_52 <= 10'd0;
            neuron_53 <= 10'd0;
            neuron_54 <= 10'd0;
        end else begin
            neuron_0 <= (neuron_0 >> 3) + (neuron_20 << 1) + (neuron_7 >> 1);
            neuron_1 <= (neuron_1 >> 3) + (neuron_39 << 1) + (neuron_13 << 1);
            neuron_2 <= (neuron_2 >> 3) + (neuron_31 >> 2) + (neuron_12 << 1);
            neuron_3 <= (neuron_3 >> 3) + (neuron_5 << 1) + (neuron_54 << 1);
            neuron_4 <= (neuron_4 >> 3) + (neuron_26 >> 2) + (neuron_20 >> 1);
            neuron_5 <= (neuron_5 >> 3) + (neuron_14 << 1) + (neuron_21 << 1);
            neuron_6 <= (neuron_6 >> 3) + (neuron_47 >> 1) + (neuron_23 >> 2);
            neuron_7 <= (neuron_7 >> 3) + (neuron_6 >> 1) + (neuron_13 << 1);
            neuron_8 <= (neuron_8 >> 3) + (neuron_35 >> 1) + (neuron_34 >> 2);
            neuron_9 <= (neuron_9 >> 3) + (neuron_2 >> 2) + (neuron_38 >> 1);
            neuron_10 <= (neuron_10 >> 3) + (neuron_17 << 1) + (neuron_23 << 1);
            neuron_11 <= (neuron_11 >> 3) + (neuron_34 >> 2) + (neuron_21 >> 2);
            neuron_12 <= (neuron_12 >> 3) + (neuron_33 >> 2) + (neuron_44 << 1);
            neuron_13 <= (neuron_13 >> 3) + (neuron_3 >> 1) + (neuron_49 << 1);
            neuron_14 <= (neuron_14 >> 3) + (neuron_10 >> 2) + (neuron_34 >> 1);
            neuron_15 <= (neuron_15 >> 3) + (neuron_42 >> 1) + (neuron_53 << 1);
            neuron_16 <= (neuron_16 >> 3) + (neuron_36 >> 2) + (neuron_29 >> 2);
            neuron_17 <= (neuron_17 >> 3) + (neuron_47 << 1) + (neuron_34 >> 1);
            neuron_18 <= (neuron_18 >> 3) + (neuron_11 << 1) + (neuron_51 << 1);
            neuron_19 <= (neuron_19 >> 3) + (neuron_50 << 1) + (neuron_42 >> 2);
            neuron_20 <= (neuron_20 >> 3) + (neuron_29 >> 2) + (neuron_40 >> 1);
            neuron_21 <= (neuron_21 >> 3) + (neuron_45 << 1) + (neuron_0 >> 1);
            neuron_22 <= (neuron_22 >> 3) + (neuron_24 >> 1) + (neuron_6 >> 2);
            neuron_23 <= (neuron_23 >> 3) + (neuron_45 >> 1) + (neuron_43 >> 2);
            neuron_24 <= (neuron_24 >> 3) + (neuron_31 >> 2) + (neuron_29 >> 1);
            neuron_25 <= (neuron_25 >> 3) + (neuron_5 >> 1) + (neuron_0 << 1);
            neuron_26 <= (neuron_26 >> 3) + (neuron_34 << 1) + (neuron_2 >> 2);
            neuron_27 <= (neuron_27 >> 3) + (neuron_52 >> 2) + (neuron_52 << 1);
            neuron_28 <= (neuron_28 >> 3) + (neuron_38 << 1) + (neuron_29 >> 2);
            neuron_29 <= (neuron_29 >> 3) + (neuron_33 << 1) + (neuron_38 >> 1);
            neuron_30 <= (neuron_30 >> 3) + (neuron_6 >> 1) + (neuron_19 << 1);
            neuron_31 <= (neuron_31 >> 3) + (neuron_9 >> 2) + (neuron_52 >> 1);
            neuron_32 <= (neuron_32 >> 3) + (neuron_23 << 1) + (neuron_10 >> 1);
            neuron_33 <= (neuron_33 >> 3) + (neuron_7 >> 1) + (neuron_42 << 1);
            neuron_34 <= (neuron_34 >> 3) + (neuron_10 >> 2) + (neuron_15 >> 1);
            neuron_35 <= (neuron_35 >> 3) + (neuron_8 >> 1) + (neuron_11 >> 2);
            neuron_36 <= (neuron_36 >> 3) + (neuron_0 >> 1) + (neuron_24 >> 1);
            neuron_37 <= (neuron_37 >> 3) + (neuron_20 >> 2) + (neuron_9 << 1);
            neuron_38 <= (neuron_38 >> 3) + (neuron_36 >> 2) + (neuron_53 >> 2);
            neuron_39 <= (neuron_39 >> 3) + (neuron_49 << 1) + (neuron_39 >> 1);
            neuron_40 <= (neuron_40 >> 3) + (neuron_21 >> 2) + (neuron_23 >> 2);
            neuron_41 <= (neuron_41 >> 3) + (neuron_34 << 1) + (neuron_38 >> 2);
            neuron_42 <= (neuron_42 >> 3) + (neuron_5 << 1) + (neuron_48 << 1);
            neuron_43 <= (neuron_43 >> 3) + (neuron_16 << 1) + (neuron_48 >> 2);
            neuron_44 <= (neuron_44 >> 3) + (neuron_12 >> 2) + (neuron_35 >> 2);
            neuron_45 <= (neuron_45 >> 3) + (neuron_5 >> 2) + (neuron_45 >> 2);
            neuron_46 <= (neuron_46 >> 3) + (neuron_19 >> 2) + (neuron_23 >> 1);
            neuron_47 <= (neuron_47 >> 3) + (neuron_36 >> 1) + (neuron_2 >> 1);
            neuron_48 <= (neuron_48 >> 3) + (neuron_10 >> 1) + (neuron_43 >> 1);
            neuron_49 <= (neuron_49 >> 3) + (neuron_37 << 1) + (neuron_49 >> 2);
            neuron_50 <= (neuron_50 >> 3) + (neuron_37 << 1) + (neuron_8 >> 1);
            neuron_51 <= (neuron_51 >> 3) + (neuron_1 >> 2) + (neuron_37 << 1);
            neuron_52 <= (neuron_52 >> 3) + (neuron_17 >> 1) + (neuron_7 >> 2);
            neuron_53 <= (neuron_53 >> 3) + (neuron_17 >> 1) + (neuron_49 << 1);
            neuron_54 <= (neuron_54 >> 3) + (neuron_19 << 1) + (neuron_29 >> 2);
        end
    end

    assign uo_out = {neuron_0[9], neuron_1[9], neuron_2[9], neuron_3[9], neuron_4[9], neuron_5[9], neuron_6[9], neuron_7[9]};
endmodule
