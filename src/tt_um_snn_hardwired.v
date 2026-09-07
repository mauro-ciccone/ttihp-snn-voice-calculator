`default_nettype none

module tt_um_snn_hardwired (
    input  wire [7:0] ui_in,    // 8-bit Cochlea Spikes
    output wire [7:0] uo_out,   // 6-bit Output Spikes + 2 unused
    input  wire       clk,
    input  wire       rst_n
);

    // Membrane Voltages (16-bit to prevent overflow)
    reg signed [15:0] hid_mem_0;
    reg signed [15:0] hid_mem_1;
    reg signed [15:0] hid_mem_2;
    reg signed [15:0] hid_mem_3;
    reg signed [15:0] hid_mem_4;
    reg signed [15:0] hid_mem_5;
    reg signed [15:0] hid_mem_6;
    reg signed [15:0] hid_mem_7;
    reg signed [15:0] hid_mem_8;
    reg signed [15:0] hid_mem_9;
    reg signed [15:0] hid_mem_10;
    reg signed [15:0] hid_mem_11;
    reg signed [15:0] hid_mem_12;
    reg signed [15:0] hid_mem_13;
    reg signed [15:0] hid_mem_14;
    reg signed [15:0] hid_mem_15;
    reg signed [15:0] hid_mem_16;
    reg signed [15:0] hid_mem_17;
    reg signed [15:0] hid_mem_18;
    reg signed [15:0] hid_mem_19;
    reg signed [15:0] hid_mem_20;
    reg signed [15:0] hid_mem_21;
    reg signed [15:0] hid_mem_22;
    reg signed [15:0] hid_mem_23;
    reg signed [15:0] hid_mem_24;
    reg signed [15:0] hid_mem_25;
    reg signed [15:0] hid_mem_26;
    reg signed [15:0] hid_mem_27;
    reg signed [15:0] hid_mem_28;
    reg signed [15:0] hid_mem_29;
    reg signed [15:0] hid_mem_30;
    reg signed [15:0] hid_mem_31;
    reg signed [15:0] hid_mem_32;
    reg signed [15:0] hid_mem_33;
    reg signed [15:0] hid_mem_34;
    reg signed [15:0] hid_mem_35;
    reg signed [15:0] hid_mem_36;
    reg signed [15:0] hid_mem_37;
    reg signed [15:0] hid_mem_38;
    reg signed [15:0] hid_mem_39;
    reg signed [15:0] out_mem_0;
    reg signed [15:0] out_mem_1;
    reg signed [15:0] out_mem_2;
    reg signed [15:0] out_mem_3;
    reg signed [15:0] out_mem_4;
    reg signed [15:0] out_mem_5;

    // Spike Registers
    reg [39:0] hid_spikes;
    reg [5:0]  out_spikes;

    assign uo_out = {2'b00, out_spikes};

    always @(posedge clk) begin
        if (!rst_n) begin
            hid_spikes <= 0;
            out_spikes <= 0;
            hid_mem_0 <= 0;
            hid_mem_1 <= 0;
            hid_mem_2 <= 0;
            hid_mem_3 <= 0;
            hid_mem_4 <= 0;
            hid_mem_5 <= 0;
            hid_mem_6 <= 0;
            hid_mem_7 <= 0;
            hid_mem_8 <= 0;
            hid_mem_9 <= 0;
            hid_mem_10 <= 0;
            hid_mem_11 <= 0;
            hid_mem_12 <= 0;
            hid_mem_13 <= 0;
            hid_mem_14 <= 0;
            hid_mem_15 <= 0;
            hid_mem_16 <= 0;
            hid_mem_17 <= 0;
            hid_mem_18 <= 0;
            hid_mem_19 <= 0;
            hid_mem_20 <= 0;
            hid_mem_21 <= 0;
            hid_mem_22 <= 0;
            hid_mem_23 <= 0;
            hid_mem_24 <= 0;
            hid_mem_25 <= 0;
            hid_mem_26 <= 0;
            hid_mem_27 <= 0;
            hid_mem_28 <= 0;
            hid_mem_29 <= 0;
            hid_mem_30 <= 0;
            hid_mem_31 <= 0;
            hid_mem_32 <= 0;
            hid_mem_33 <= 0;
            hid_mem_34 <= 0;
            hid_mem_35 <= 0;
            hid_mem_36 <= 0;
            hid_mem_37 <= 0;
            hid_mem_38 <= 0;
            hid_mem_39 <= 0;
            out_mem_0 <= 0;
            out_mem_1 <= 0;
            out_mem_2 <= 0;
            out_mem_3 <= 0;
            out_mem_4 <= 0;
            out_mem_5 <= 0;
        end else begin
            // --- HIDDEN LAYER ALUs ---
            hid_mem_0 <= hid_mem_0 - (hid_mem_0 >>> 3) + (ui_in[0] ? 16'sd2 : 0) + (ui_in[1] ? 16'sd3 : 0) + (ui_in[2] ? 16'sd24 : 0) + (ui_in[3] ? 16'sd1 : 0) + (ui_in[4] ? 16'sd36 : 0) + (ui_in[5] ? 16'sd39 : 0) + (ui_in[6] ? 16'sd1 : 0) + (ui_in[7] ? 16'sd22 : 0) + (hid_spikes[0] ? 16'sd90 : 0) + (hid_spikes[1] ? -16'sd90 : 0) + (hid_spikes[2] ? -16'sd18 : 0) + (hid_spikes[3] ? -16'sd6 : 0) + (hid_spikes[4] ? 16'sd12 : 0) + (hid_spikes[5] ? -16'sd29 : 0) + (hid_spikes[6] ? 16'sd66 : 0) + (hid_spikes[7] ? -16'sd13 : 0) + (hid_spikes[8] ? 16'sd3 : 0) + (hid_spikes[9] ? -16'sd127 : 0) + (hid_spikes[10] ? -16'sd40 : 0) + (hid_spikes[11] ? -16'sd127 : 0) + (hid_spikes[12] ? 16'sd26 : 0) + (hid_spikes[13] ? -16'sd10 : 0) + (hid_spikes[14] ? -16'sd57 : 0) + (hid_spikes[15] ? -16'sd30 : 0) + (hid_spikes[16] ? -16'sd113 : 0) + (hid_spikes[17] ? -16'sd109 : 0) + (hid_spikes[18] ? -16'sd93 : 0) + (hid_spikes[19] ? 16'sd75 : 0) + (hid_spikes[20] ? -16'sd107 : 0) + (hid_spikes[21] ? -16'sd39 : 0) + (hid_spikes[22] ? -16'sd127 : 0) + (hid_spikes[23] ? -16'sd75 : 0) + (hid_spikes[24] ? 16'sd2 : 0) + (hid_spikes[25] ? 16'sd18 : 0) + (hid_spikes[26] ? 16'sd29 : 0) + (hid_spikes[27] ? -16'sd4 : 0) + (hid_spikes[28] ? 16'sd3 : 0) + (hid_spikes[29] ? -16'sd64 : 0) + (hid_spikes[30] ? -16'sd53 : 0) + (hid_spikes[31] ? 16'sd67 : 0) + (hid_spikes[32] ? -16'sd116 : 0) + (hid_spikes[33] ? -16'sd12 : 0) + (hid_spikes[34] ? -16'sd46 : 0) + (hid_spikes[35] ? 16'sd17 : 0) + (hid_spikes[36] ? 16'sd24 : 0) + (hid_spikes[37] ? 16'sd21 : 0) + (hid_spikes[38] ? -16'sd19 : 0) + (hid_spikes[39] ? -16'sd37 : 0);
            hid_mem_1 <= hid_mem_1 - (hid_mem_1 >>> 3) + (ui_in[0] ? 16'sd26 : 0) + (ui_in[1] ? 16'sd26 : 0) + (ui_in[2] ? 16'sd1 : 0) + (ui_in[3] ? 16'sd34 : 0) + (ui_in[4] ? 16'sd36 : 0) + (ui_in[5] ? 16'sd30 : 0) + (ui_in[6] ? 16'sd15 : 0) + (ui_in[7] ? 16'sd35 : 0) + (hid_spikes[0] ? 16'sd25 : 0) + (hid_spikes[1] ? 16'sd28 : 0) + (hid_spikes[2] ? -16'sd127 : 0) + (hid_spikes[3] ? -16'sd127 : 0) + (hid_spikes[4] ? 16'sd14 : 0) + (hid_spikes[5] ? -16'sd107 : 0) + (hid_spikes[6] ? 16'sd28 : 0) + (hid_spikes[7] ? -16'sd27 : 0) + (hid_spikes[8] ? -16'sd44 : 0) + (hid_spikes[9] ? -16'sd18 : 0) + (hid_spikes[10] ? -16'sd32 : 0) + (hid_spikes[11] ? -16'sd18 : 0) + (hid_spikes[12] ? 16'sd13 : 0) + (hid_spikes[13] ? -16'sd32 : 0) + (hid_spikes[14] ? -16'sd2 : 0) + (hid_spikes[15] ? -16'sd11 : 0) + (hid_spikes[16] ? -16'sd35 : 0) + (hid_spikes[17] ? -16'sd32 : 0) + (hid_spikes[18] ? 16'sd47 : 0) + (hid_spikes[19] ? -16'sd18 : 0) + (hid_spikes[20] ? 16'sd62 : 0) + (hid_spikes[21] ? -16'sd4 : 0) + (hid_spikes[22] ? -16'sd26 : 0) + (hid_spikes[23] ? 16'sd6 : 0) + (hid_spikes[24] ? 16'sd19 : 0) + (hid_spikes[25] ? -16'sd4 : 0) + (hid_spikes[26] ? -16'sd73 : 0) + (hid_spikes[27] ? 16'sd8 : 0) + (hid_spikes[28] ? -16'sd15 : 0) + (hid_spikes[29] ? 16'sd8 : 0) + (hid_spikes[30] ? 16'sd1 : 0) + (hid_spikes[31] ? -16'sd104 : 0) + (hid_spikes[32] ? 16'sd41 : 0) + (hid_spikes[33] ? 16'sd31 : 0) + (hid_spikes[34] ? -16'sd53 : 0) + (hid_spikes[35] ? 16'sd27 : 0) + (hid_spikes[36] ? 16'sd26 : 0) + (hid_spikes[37] ? -16'sd127 : 0) + (hid_spikes[38] ? 16'sd23 : 0) + (hid_spikes[39] ? -16'sd46 : 0);
            hid_mem_2 <= hid_mem_2 - (hid_mem_2 >>> 3) + (ui_in[0] ? 16'sd19 : 0) + (ui_in[1] ? 16'sd20 : 0) + (ui_in[2] ? 16'sd7 : 0) + (ui_in[3] ? 16'sd12 : 0) + (ui_in[4] ? 16'sd8 : 0) + (ui_in[5] ? 16'sd6 : 0) + (ui_in[6] ? 16'sd49 : 0) + (ui_in[7] ? 16'sd33 : 0) + (hid_spikes[0] ? -16'sd12 : 0) + (hid_spikes[1] ? 16'sd4 : 0) + (hid_spikes[2] ? 16'sd85 : 0) + (hid_spikes[3] ? -16'sd71 : 0) + (hid_spikes[4] ? -16'sd31 : 0) + (hid_spikes[5] ? -16'sd6 : 0) + (hid_spikes[6] ? 16'sd31 : 0) + (hid_spikes[7] ? 16'sd4 : 0) + (hid_spikes[8] ? -16'sd71 : 0) + (hid_spikes[9] ? -16'sd8 : 0) + (hid_spikes[10] ? -16'sd55 : 0) + (hid_spikes[11] ? -16'sd8 : 0) + (hid_spikes[12] ? -16'sd28 : 0) + (hid_spikes[13] ? 16'sd10 : 0) + (hid_spikes[14] ? -16'sd18 : 0) + (hid_spikes[15] ? 16'sd4 : 0) + (hid_spikes[16] ? 16'sd10 : 0) + (hid_spikes[17] ? 16'sd1 : 0) + (hid_spikes[18] ? 16'sd32 : 0) + (hid_spikes[19] ? 16'sd14 : 0) + (hid_spikes[20] ? 16'sd15 : 0) + (hid_spikes[21] ? -16'sd8 : 0) + (hid_spikes[22] ? 16'sd4 : 0) + (hid_spikes[23] ? 16'sd24 : 0) + (hid_spikes[24] ? 16'sd16 : 0) + (hid_spikes[25] ? 16'sd7 : 0) + (hid_spikes[26] ? -16'sd25 : 0) + (hid_spikes[27] ? 16'sd3 : 0) + (hid_spikes[28] ? -16'sd5 : 0) + (hid_spikes[29] ? 16'sd2 : 0) + (hid_spikes[30] ? -16'sd26 : 0) + (hid_spikes[31] ? 16'sd4 : 0) + (hid_spikes[32] ? 16'sd10 : 0) + (hid_spikes[33] ? -16'sd13 : 0) + (hid_spikes[34] ? -16'sd34 : 0) + (hid_spikes[35] ? 16'sd27 : 0) + (hid_spikes[36] ? 16'sd2 : 0) + (hid_spikes[37] ? 16'sd7 : 0) + (hid_spikes[38] ? 16'sd25 : 0) + (hid_spikes[39] ? -16'sd27 : 0);
            hid_mem_3 <= hid_mem_3 - (hid_mem_3 >>> 3) + (ui_in[0] ? 16'sd23 : 0) + (ui_in[1] ? 16'sd23 : 0) + (ui_in[2] ? 16'sd9 : 0) + (ui_in[3] ? 16'sd1 : 0) + (ui_in[4] ? 16'sd1 : 0) + (ui_in[5] ? 16'sd2 : 0) + (ui_in[6] ? 16'sd19 : 0) + (ui_in[7] ? 16'sd28 : 0) + (hid_spikes[0] ? 16'sd35 : 0) + (hid_spikes[1] ? -16'sd30 : 0) + (hid_spikes[2] ? -16'sd2 : 0) + (hid_spikes[3] ? 16'sd44 : 0) + (hid_spikes[4] ? -16'sd25 : 0) + (hid_spikes[5] ? 16'sd16 : 0) + (hid_spikes[6] ? -16'sd85 : 0) + (hid_spikes[7] ? -16'sd71 : 0) + (hid_spikes[8] ? -16'sd7 : 0) + (hid_spikes[9] ? -16'sd45 : 0) + (hid_spikes[10] ? -16'sd28 : 0) + (hid_spikes[11] ? -16'sd27 : 0) + (hid_spikes[12] ? -16'sd19 : 0) + (hid_spikes[13] ? 16'sd5 : 0) + (hid_spikes[14] ? 16'sd10 : 0) + (hid_spikes[15] ? -16'sd18 : 0) + (hid_spikes[16] ? 16'sd21 : 0) + (hid_spikes[17] ? -16'sd40 : 0) + (hid_spikes[18] ? -16'sd35 : 0) + (hid_spikes[19] ? 16'sd4 : 0) + (hid_spikes[20] ? -16'sd29 : 0) + (hid_spikes[21] ? -16'sd98 : 0) + (hid_spikes[22] ? -16'sd16 : 0) + (hid_spikes[23] ? -16'sd8 : 0) + (hid_spikes[24] ? -16'sd35 : 0) + (hid_spikes[25] ? 16'sd6 : 0) + (hid_spikes[26] ? 16'sd29 : 0) + (hid_spikes[27] ? 16'sd34 : 0) + (hid_spikes[28] ? -16'sd15 : 0) + (hid_spikes[29] ? -16'sd31 : 0) + (hid_spikes[30] ? 16'sd7 : 0) + (hid_spikes[31] ? -16'sd44 : 0) + (hid_spikes[32] ? 16'sd18 : 0) + (hid_spikes[34] ? -16'sd78 : 0) + (hid_spikes[35] ? -16'sd127 : 0) + (hid_spikes[36] ? 16'sd127 : 0) + (hid_spikes[37] ? -16'sd61 : 0) + (hid_spikes[38] ? 16'sd14 : 0) + (hid_spikes[39] ? 16'sd10 : 0);
            hid_mem_4 <= hid_mem_4 - (hid_mem_4 >>> 3) + (ui_in[0] ? 16'sd1 : 0) + (ui_in[1] ? 16'sd1 : 0) + (ui_in[2] ? 16'sd5 : 0) + (ui_in[3] ? 16'sd29 : 0) + (ui_in[4] ? 16'sd4 : 0) + (ui_in[5] ? 16'sd1 : 0) + (ui_in[6] ? 16'sd41 : 0) + (ui_in[7] ? 16'sd1 : 0) + (hid_spikes[0] ? 16'sd46 : 0) + (hid_spikes[1] ? -16'sd6 : 0) + (hid_spikes[2] ? 16'sd22 : 0) + (hid_spikes[3] ? -16'sd5 : 0) + (hid_spikes[4] ? 16'sd64 : 0) + (hid_spikes[5] ? -16'sd29 : 0) + (hid_spikes[6] ? 16'sd127 : 0) + (hid_spikes[7] ? -16'sd15 : 0) + (hid_spikes[8] ? -16'sd12 : 0) + (hid_spikes[9] ? -16'sd43 : 0) + (hid_spikes[10] ? -16'sd31 : 0) + (hid_spikes[11] ? -16'sd14 : 0) + (hid_spikes[12] ? -16'sd42 : 0) + (hid_spikes[14] ? -16'sd8 : 0) + (hid_spikes[15] ? -16'sd6 : 0) + (hid_spikes[16] ? 16'sd6 : 0) + (hid_spikes[17] ? 16'sd28 : 0) + (hid_spikes[18] ? -16'sd18 : 0) + (hid_spikes[19] ? 16'sd72 : 0) + (hid_spikes[20] ? 16'sd37 : 0) + (hid_spikes[21] ? 16'sd15 : 0) + (hid_spikes[22] ? -16'sd3 : 0) + (hid_spikes[23] ? 16'sd9 : 0) + (hid_spikes[24] ? 16'sd16 : 0) + (hid_spikes[25] ? 16'sd13 : 0) + (hid_spikes[26] ? 16'sd8 : 0) + (hid_spikes[27] ? -16'sd20 : 0) + (hid_spikes[28] ? -16'sd7 : 0) + (hid_spikes[29] ? -16'sd12 : 0) + (hid_spikes[30] ? 16'sd12 : 0) + (hid_spikes[31] ? 16'sd38 : 0) + (hid_spikes[32] ? 16'sd35 : 0) + (hid_spikes[33] ? -16'sd14 : 0) + (hid_spikes[34] ? -16'sd19 : 0) + (hid_spikes[35] ? -16'sd9 : 0) + (hid_spikes[36] ? 16'sd1 : 0) + (hid_spikes[37] ? 16'sd44 : 0) + (hid_spikes[38] ? 16'sd10 : 0) + (hid_spikes[39] ? -16'sd26 : 0);
            hid_mem_5 <= hid_mem_5 - (hid_mem_5 >>> 3) + (ui_in[0] ? 16'sd9 : 0) + (ui_in[1] ? 16'sd10 : 0) + (ui_in[2] ? 16'sd28 : 0) + (ui_in[3] ? 16'sd13 : 0) + (ui_in[4] ? 16'sd15 : 0) + (ui_in[5] ? 16'sd18 : 0) + (ui_in[6] ? 16'sd24 : 0) + (ui_in[7] ? 16'sd31 : 0) + (hid_spikes[0] ? -16'sd63 : 0) + (hid_spikes[1] ? 16'sd3 : 0) + (hid_spikes[2] ? -16'sd46 : 0) + (hid_spikes[3] ? 16'sd17 : 0) + (hid_spikes[4] ? -16'sd7 : 0) + (hid_spikes[5] ? 16'sd30 : 0) + (hid_spikes[6] ? -16'sd127 : 0) + (hid_spikes[7] ? -16'sd7 : 0) + (hid_spikes[8] ? 16'sd13 : 0) + (hid_spikes[9] ? -16'sd117 : 0) + (hid_spikes[10] ? -16'sd4 : 0) + (hid_spikes[11] ? -16'sd28 : 0) + (hid_spikes[12] ? -16'sd127 : 0) + (hid_spikes[13] ? 16'sd5 : 0) + (hid_spikes[14] ? 16'sd19 : 0) + (hid_spikes[15] ? -16'sd29 : 0) + (hid_spikes[16] ? -16'sd4 : 0) + (hid_spikes[17] ? -16'sd77 : 0) + (hid_spikes[18] ? -16'sd27 : 0) + (hid_spikes[19] ? 16'sd78 : 0) + (hid_spikes[20] ? -16'sd31 : 0) + (hid_spikes[21] ? 16'sd14 : 0) + (hid_spikes[22] ? -16'sd8 : 0) + (hid_spikes[23] ? -16'sd23 : 0) + (hid_spikes[24] ? 16'sd34 : 0) + (hid_spikes[25] ? -16'sd39 : 0) + (hid_spikes[26] ? 16'sd1 : 0) + (hid_spikes[27] ? 16'sd24 : 0) + (hid_spikes[28] ? -16'sd26 : 0) + (hid_spikes[29] ? -16'sd78 : 0) + (hid_spikes[30] ? -16'sd87 : 0) + (hid_spikes[31] ? -16'sd82 : 0) + (hid_spikes[32] ? -16'sd48 : 0) + (hid_spikes[33] ? -16'sd94 : 0) + (hid_spikes[34] ? -16'sd28 : 0) + (hid_spikes[35] ? -16'sd125 : 0) + (hid_spikes[36] ? 16'sd127 : 0) + (hid_spikes[37] ? -16'sd5 : 0) + (hid_spikes[38] ? -16'sd80 : 0) + (hid_spikes[39] ? 16'sd5 : 0);
            hid_mem_6 <= hid_mem_6 - (hid_mem_6 >>> 3) + (ui_in[0] ? 16'sd5 : 0) + (ui_in[1] ? 16'sd5 : 0) + (ui_in[2] ? 16'sd25 : 0) + (ui_in[3] ? 16'sd1 : 0) + (ui_in[4] ? 16'sd58 : 0) + (ui_in[5] ? 16'sd18 : 0) + (ui_in[6] ? 16'sd1 : 0) + (ui_in[7] ? 16'sd1 : 0) + (hid_spikes[0] ? -16'sd29 : 0) + (hid_spikes[1] ? -16'sd127 : 0) + (hid_spikes[2] ? -16'sd24 : 0) + (hid_spikes[3] ? -16'sd70 : 0) + (hid_spikes[4] ? 16'sd40 : 0) + (hid_spikes[5] ? -16'sd94 : 0) + (hid_spikes[6] ? 16'sd7 : 0) + (hid_spikes[7] ? -16'sd7 : 0) + (hid_spikes[8] ? -16'sd127 : 0) + (hid_spikes[9] ? -16'sd54 : 0) + (hid_spikes[10] ? -16'sd107 : 0) + (hid_spikes[11] ? -16'sd127 : 0) + (hid_spikes[12] ? -16'sd9 : 0) + (hid_spikes[13] ? 16'sd6 : 0) + (hid_spikes[14] ? -16'sd81 : 0) + (hid_spikes[15] ? -16'sd120 : 0) + (hid_spikes[16] ? -16'sd52 : 0) + (hid_spikes[17] ? 16'sd12 : 0) + (hid_spikes[18] ? -16'sd127 : 0) + (hid_spikes[19] ? 16'sd7 : 0) + (hid_spikes[20] ? -16'sd114 : 0) + (hid_spikes[21] ? 16'sd21 : 0) + (hid_spikes[22] ? -16'sd127 : 0) + (hid_spikes[23] ? -16'sd22 : 0) + (hid_spikes[24] ? -16'sd5 : 0) + (hid_spikes[25] ? 16'sd56 : 0) + (hid_spikes[26] ? 16'sd8 : 0) + (hid_spikes[27] ? 16'sd20 : 0) + (hid_spikes[28] ? 16'sd56 : 0) + (hid_spikes[29] ? 16'sd23 : 0) + (hid_spikes[30] ? -16'sd127 : 0) + (hid_spikes[31] ? 16'sd84 : 0) + (hid_spikes[32] ? -16'sd21 : 0) + (hid_spikes[33] ? -16'sd41 : 0) + (hid_spikes[34] ? -16'sd91 : 0) + (hid_spikes[35] ? -16'sd46 : 0) + (hid_spikes[36] ? -16'sd88 : 0) + (hid_spikes[37] ? 16'sd10 : 0) + (hid_spikes[38] ? -16'sd16 : 0) + (hid_spikes[39] ? -16'sd115 : 0);
            hid_mem_7 <= hid_mem_7 - (hid_mem_7 >>> 3) + (ui_in[0] ? 16'sd14 : 0) + (ui_in[1] ? 16'sd14 : 0) + (ui_in[2] ? 16'sd7 : 0) + (ui_in[3] ? 16'sd4 : 0) + (ui_in[4] ? 16'sd10 : 0) + (ui_in[5] ? 16'sd14 : 0) + (ui_in[6] ? 16'sd26 : 0) + (ui_in[7] ? 16'sd14 : 0) + (hid_spikes[0] ? -16'sd127 : 0) + (hid_spikes[1] ? -16'sd17 : 0) + (hid_spikes[2] ? 16'sd87 : 0) + (hid_spikes[3] ? -16'sd55 : 0) + (hid_spikes[4] ? 16'sd3 : 0) + (hid_spikes[5] ? -16'sd111 : 0) + (hid_spikes[6] ? -16'sd109 : 0) + (hid_spikes[7] ? 16'sd32 : 0) + (hid_spikes[8] ? -16'sd27 : 0) + (hid_spikes[9] ? -16'sd41 : 0) + (hid_spikes[10] ? -16'sd16 : 0) + (hid_spikes[11] ? 16'sd18 : 0) + (hid_spikes[12] ? -16'sd28 : 0) + (hid_spikes[13] ? -16'sd4 : 0) + (hid_spikes[14] ? -16'sd15 : 0) + (hid_spikes[15] ? 16'sd1 : 0) + (hid_spikes[16] ? 16'sd2 : 0) + (hid_spikes[17] ? 16'sd41 : 0) + (hid_spikes[18] ? -16'sd23 : 0) + (hid_spikes[19] ? -16'sd69 : 0) + (hid_spikes[20] ? 16'sd84 : 0) + (hid_spikes[21] ? -16'sd64 : 0) + (hid_spikes[22] ? 16'sd6 : 0) + (hid_spikes[23] ? 16'sd10 : 0) + (hid_spikes[24] ? 16'sd29 : 0) + (hid_spikes[25] ? -16'sd48 : 0) + (hid_spikes[26] ? 16'sd26 : 0) + (hid_spikes[27] ? 16'sd5 : 0) + (hid_spikes[28] ? 16'sd23 : 0) + (hid_spikes[29] ? 16'sd1 : 0) + (hid_spikes[30] ? -16'sd14 : 0) + (hid_spikes[31] ? 16'sd25 : 0) + (hid_spikes[32] ? 16'sd9 : 0) + (hid_spikes[33] ? 16'sd9 : 0) + (hid_spikes[34] ? -16'sd14 : 0) + (hid_spikes[36] ? 16'sd99 : 0) + (hid_spikes[37] ? 16'sd63 : 0) + (hid_spikes[38] ? 16'sd38 : 0) + (hid_spikes[39] ? -16'sd37 : 0);
            hid_mem_8 <= hid_mem_8 - (hid_mem_8 >>> 3) + (ui_in[0] ? 16'sd6 : 0) + (ui_in[1] ? 16'sd5 : 0) + (ui_in[2] ? 16'sd1 : 0) + (ui_in[3] ? 16'sd29 : 0) + (ui_in[4] ? 16'sd47 : 0) + (ui_in[5] ? 16'sd48 : 0) + (ui_in[6] ? 16'sd1 : 0) + (ui_in[7] ? 16'sd12 : 0) + (hid_spikes[0] ? 16'sd88 : 0) + (hid_spikes[1] ? 16'sd2 : 0) + (hid_spikes[2] ? -16'sd14 : 0) + (hid_spikes[3] ? 16'sd50 : 0) + (hid_spikes[4] ? -16'sd3 : 0) + (hid_spikes[5] ? 16'sd10 : 0) + (hid_spikes[6] ? 16'sd62 : 0) + (hid_spikes[7] ? -16'sd14 : 0) + (hid_spikes[8] ? 16'sd40 : 0) + (hid_spikes[9] ? 16'sd1 : 0) + (hid_spikes[10] ? -16'sd16 : 0) + (hid_spikes[11] ? 16'sd14 : 0) + (hid_spikes[12] ? 16'sd8 : 0) + (hid_spikes[13] ? -16'sd70 : 0) + (hid_spikes[14] ? -16'sd9 : 0) + (hid_spikes[15] ? -16'sd19 : 0) + (hid_spikes[16] ? -16'sd10 : 0) + (hid_spikes[17] ? -16'sd13 : 0) + (hid_spikes[18] ? 16'sd6 : 0) + (hid_spikes[19] ? 16'sd70 : 0) + (hid_spikes[20] ? -16'sd3 : 0) + (hid_spikes[21] ? 16'sd46 : 0) + (hid_spikes[22] ? 16'sd15 : 0) + (hid_spikes[23] ? 16'sd5 : 0) + (hid_spikes[24] ? 16'sd1 : 0) + (hid_spikes[25] ? 16'sd7 : 0) + (hid_spikes[26] ? -16'sd5 : 0) + (hid_spikes[27] ? 16'sd85 : 0) + (hid_spikes[28] ? -16'sd12 : 0) + (hid_spikes[30] ? -16'sd13 : 0) + (hid_spikes[31] ? 16'sd6 : 0) + (hid_spikes[32] ? 16'sd9 : 0) + (hid_spikes[33] ? -16'sd46 : 0) + (hid_spikes[34] ? -16'sd5 : 0) + (hid_spikes[35] ? 16'sd16 : 0) + (hid_spikes[36] ? 16'sd24 : 0) + (hid_spikes[37] ? 16'sd20 : 0) + (hid_spikes[38] ? -16'sd10 : 0) + (hid_spikes[39] ? -16'sd13 : 0);
            hid_mem_9 <= hid_mem_9 - (hid_mem_9 >>> 3) + (ui_in[0] ? 16'sd18 : 0) + (ui_in[1] ? 16'sd17 : 0) + (ui_in[2] ? 16'sd2 : 0) + (ui_in[3] ? 16'sd22 : 0) + (ui_in[4] ? 16'sd30 : 0) + (ui_in[5] ? 16'sd35 : 0) + (ui_in[6] ? 16'sd27 : 0) + (ui_in[7] ? 16'sd31 : 0) + (hid_spikes[1] ? 16'sd9 : 0) + (hid_spikes[2] ? -16'sd16 : 0) + (hid_spikes[3] ? 16'sd9 : 0) + (hid_spikes[4] ? -16'sd30 : 0) + (hid_spikes[5] ? -16'sd31 : 0) + (hid_spikes[6] ? -16'sd47 : 0) + (hid_spikes[7] ? -16'sd25 : 0) + (hid_spikes[8] ? -16'sd36 : 0) + (hid_spikes[9] ? 16'sd1 : 0) + (hid_spikes[11] ? 16'sd4 : 0) + (hid_spikes[12] ? -16'sd18 : 0) + (hid_spikes[13] ? -16'sd4 : 0) + (hid_spikes[14] ? -16'sd21 : 0) + (hid_spikes[15] ? -16'sd25 : 0) + (hid_spikes[16] ? 16'sd11 : 0) + (hid_spikes[17] ? -16'sd3 : 0) + (hid_spikes[18] ? 16'sd14 : 0) + (hid_spikes[19] ? 16'sd30 : 0) + (hid_spikes[20] ? -16'sd13 : 0) + (hid_spikes[21] ? 16'sd26 : 0) + (hid_spikes[22] ? -16'sd19 : 0) + (hid_spikes[23] ? 16'sd15 : 0) + (hid_spikes[24] ? -16'sd1 : 0) + (hid_spikes[25] ? -16'sd32 : 0) + (hid_spikes[26] ? 16'sd3 : 0) + (hid_spikes[27] ? 16'sd14 : 0) + (hid_spikes[28] ? 16'sd40 : 0) + (hid_spikes[29] ? -16'sd1 : 0) + (hid_spikes[30] ? 16'sd2 : 0) + (hid_spikes[31] ? -16'sd127 : 0) + (hid_spikes[32] ? 16'sd53 : 0) + (hid_spikes[33] ? -16'sd15 : 0) + (hid_spikes[34] ? -16'sd34 : 0) + (hid_spikes[35] ? -16'sd2 : 0) + (hid_spikes[36] ? 16'sd26 : 0) + (hid_spikes[37] ? -16'sd6 : 0) + (hid_spikes[38] ? 16'sd15 : 0) + (hid_spikes[39] ? -16'sd16 : 0);
            hid_mem_10 <= hid_mem_10 - (hid_mem_10 >>> 3) + (ui_in[0] ? 16'sd7 : 0) + (ui_in[1] ? 16'sd8 : 0) + (ui_in[2] ? 16'sd9 : 0) + (ui_in[3] ? 16'sd23 : 0) + (ui_in[4] ? 16'sd26 : 0) + (ui_in[5] ? 16'sd23 : 0) + (ui_in[6] ? 16'sd6 : 0) + (ui_in[7] ? 16'sd2 : 0) + (hid_spikes[0] ? 16'sd65 : 0) + (hid_spikes[1] ? 16'sd4 : 0) + (hid_spikes[2] ? 16'sd67 : 0) + (hid_spikes[3] ? -16'sd9 : 0) + (hid_spikes[4] ? -16'sd16 : 0) + (hid_spikes[5] ? -16'sd50 : 0) + (hid_spikes[6] ? 16'sd43 : 0) + (hid_spikes[7] ? -16'sd7 : 0) + (hid_spikes[8] ? -16'sd29 : 0) + (hid_spikes[9] ? 16'sd30 : 0) + (hid_spikes[10] ? 16'sd30 : 0) + (hid_spikes[11] ? 16'sd3 : 0) + (hid_spikes[12] ? -16'sd1 : 0) + (hid_spikes[13] ? 16'sd7 : 0) + (hid_spikes[14] ? 16'sd6 : 0) + (hid_spikes[15] ? 16'sd15 : 0) + (hid_spikes[16] ? -16'sd14 : 0) + (hid_spikes[17] ? -16'sd8 : 0) + (hid_spikes[18] ? 16'sd21 : 0) + (hid_spikes[19] ? 16'sd16 : 0) + (hid_spikes[20] ? 16'sd24 : 0) + (hid_spikes[21] ? -16'sd8 : 0) + (hid_spikes[22] ? 16'sd1 : 0) + (hid_spikes[23] ? -16'sd8 : 0) + (hid_spikes[24] ? 16'sd9 : 0) + (hid_spikes[25] ? -16'sd9 : 0) + (hid_spikes[26] ? -16'sd17 : 0) + (hid_spikes[27] ? -16'sd13 : 0) + (hid_spikes[28] ? -16'sd28 : 0) + (hid_spikes[29] ? 16'sd7 : 0) + (hid_spikes[30] ? -16'sd9 : 0) + (hid_spikes[31] ? 16'sd32 : 0) + (hid_spikes[32] ? 16'sd5 : 0) + (hid_spikes[33] ? -16'sd12 : 0) + (hid_spikes[34] ? 16'sd4 : 0) + (hid_spikes[35] ? 16'sd4 : 0) + (hid_spikes[36] ? -16'sd28 : 0) + (hid_spikes[37] ? 16'sd37 : 0) + (hid_spikes[38] ? 16'sd15 : 0) + (hid_spikes[39] ? -16'sd25 : 0);
            hid_mem_11 <= hid_mem_11 - (hid_mem_11 >>> 3) + (ui_in[0] ? 16'sd6 : 0) + (ui_in[1] ? 16'sd6 : 0) + (ui_in[2] ? 16'sd42 : 0) + (ui_in[3] ? 16'sd20 : 0) + (ui_in[4] ? 16'sd17 : 0) + (ui_in[5] ? 16'sd23 : 0) + (ui_in[6] ? 16'sd42 : 0) + (ui_in[7] ? 16'sd4 : 0) + (hid_spikes[0] ? -16'sd49 : 0) + (hid_spikes[1] ? -16'sd15 : 0) + (hid_spikes[2] ? 16'sd9 : 0) + (hid_spikes[3] ? -16'sd22 : 0) + (hid_spikes[4] ? 16'sd31 : 0) + (hid_spikes[5] ? -16'sd70 : 0) + (hid_spikes[6] ? 16'sd37 : 0) + (hid_spikes[7] ? -16'sd20 : 0) + (hid_spikes[8] ? -16'sd39 : 0) + (hid_spikes[9] ? -16'sd19 : 0) + (hid_spikes[10] ? -16'sd42 : 0) + (hid_spikes[11] ? 16'sd35 : 0) + (hid_spikes[12] ? -16'sd3 : 0) + (hid_spikes[13] ? 16'sd2 : 0) + (hid_spikes[14] ? -16'sd8 : 0) + (hid_spikes[15] ? -16'sd22 : 0) + (hid_spikes[16] ? -16'sd2 : 0) + (hid_spikes[17] ? -16'sd6 : 0) + (hid_spikes[18] ? 16'sd9 : 0) + (hid_spikes[19] ? 16'sd13 : 0) + (hid_spikes[20] ? 16'sd4 : 0) + (hid_spikes[21] ? -16'sd18 : 0) + (hid_spikes[22] ? 16'sd10 : 0) + (hid_spikes[23] ? 16'sd3 : 0) + (hid_spikes[24] ? -16'sd13 : 0) + (hid_spikes[25] ? 16'sd11 : 0) + (hid_spikes[26] ? -16'sd7 : 0) + (hid_spikes[27] ? -16'sd11 : 0) + (hid_spikes[28] ? -16'sd5 : 0) + (hid_spikes[29] ? 16'sd13 : 0) + (hid_spikes[30] ? -16'sd8 : 0) + (hid_spikes[31] ? -16'sd30 : 0) + (hid_spikes[32] ? 16'sd20 : 0) + (hid_spikes[33] ? 16'sd19 : 0) + (hid_spikes[34] ? -16'sd24 : 0) + (hid_spikes[35] ? -16'sd3 : 0) + (hid_spikes[36] ? 16'sd12 : 0) + (hid_spikes[37] ? 16'sd25 : 0) + (hid_spikes[38] ? 16'sd21 : 0) + (hid_spikes[39] ? -16'sd42 : 0);
            hid_mem_12 <= hid_mem_12 - (hid_mem_12 >>> 3) + (ui_in[0] ? 16'sd11 : 0) + (ui_in[1] ? 16'sd11 : 0) + (ui_in[2] ? 16'sd76 : 0) + (ui_in[3] ? 16'sd12 : 0) + (ui_in[4] ? 16'sd5 : 0) + (ui_in[5] ? 16'sd6 : 0) + (ui_in[6] ? 16'sd15 : 0) + (ui_in[7] ? 16'sd9 : 0) + (hid_spikes[0] ? -16'sd7 : 0) + (hid_spikes[1] ? -16'sd14 : 0) + (hid_spikes[2] ? 16'sd37 : 0) + (hid_spikes[3] ? -16'sd8 : 0) + (hid_spikes[4] ? 16'sd47 : 0) + (hid_spikes[5] ? 16'sd4 : 0) + (hid_spikes[6] ? -16'sd30 : 0) + (hid_spikes[7] ? -16'sd29 : 0) + (hid_spikes[8] ? -16'sd67 : 0) + (hid_spikes[9] ? -16'sd84 : 0) + (hid_spikes[10] ? -16'sd8 : 0) + (hid_spikes[11] ? 16'sd16 : 0) + (hid_spikes[12] ? 16'sd49 : 0) + (hid_spikes[13] ? -16'sd1 : 0) + (hid_spikes[14] ? 16'sd18 : 0) + (hid_spikes[15] ? 16'sd17 : 0) + (hid_spikes[16] ? 16'sd9 : 0) + (hid_spikes[17] ? -16'sd50 : 0) + (hid_spikes[18] ? -16'sd20 : 0) + (hid_spikes[19] ? 16'sd8 : 0) + (hid_spikes[20] ? -16'sd24 : 0) + (hid_spikes[21] ? 16'sd2 : 0) + (hid_spikes[22] ? -16'sd19 : 0) + (hid_spikes[23] ? 16'sd15 : 0) + (hid_spikes[24] ? -16'sd32 : 0) + (hid_spikes[25] ? 16'sd17 : 0) + (hid_spikes[26] ? -16'sd12 : 0) + (hid_spikes[27] ? -16'sd11 : 0) + (hid_spikes[28] ? 16'sd10 : 0) + (hid_spikes[29] ? 16'sd13 : 0) + (hid_spikes[30] ? 16'sd5 : 0) + (hid_spikes[31] ? 16'sd5 : 0) + (hid_spikes[32] ? -16'sd17 : 0) + (hid_spikes[33] ? 16'sd8 : 0) + (hid_spikes[34] ? -16'sd61 : 0) + (hid_spikes[35] ? -16'sd3 : 0) + (hid_spikes[36] ? 16'sd20 : 0) + (hid_spikes[37] ? -16'sd27 : 0) + (hid_spikes[38] ? -16'sd35 : 0) + (hid_spikes[39] ? -16'sd29 : 0);
            hid_mem_13 <= hid_mem_13 - (hid_mem_13 >>> 3) + (ui_in[0] ? 16'sd1 : 0) + (ui_in[1] ? 16'sd1 : 0) + (ui_in[2] ? 16'sd1 : 0) + (ui_in[3] ? 16'sd1 : 0) + (ui_in[4] ? 16'sd5 : 0) + (ui_in[5] ? 16'sd7 : 0) + (ui_in[6] ? 16'sd12 : 0) + (ui_in[7] ? 16'sd12 : 0) + (hid_spikes[0] ? 16'sd19 : 0) + (hid_spikes[1] ? -16'sd73 : 0) + (hid_spikes[2] ? 16'sd18 : 0) + (hid_spikes[3] ? -16'sd12 : 0) + (hid_spikes[4] ? 16'sd19 : 0) + (hid_spikes[5] ? -16'sd19 : 0) + (hid_spikes[6] ? -16'sd2 : 0) + (hid_spikes[7] ? -16'sd48 : 0) + (hid_spikes[8] ? -16'sd13 : 0) + (hid_spikes[9] ? -16'sd40 : 0) + (hid_spikes[10] ? 16'sd13 : 0) + (hid_spikes[11] ? -16'sd18 : 0) + (hid_spikes[12] ? -16'sd25 : 0) + (hid_spikes[13] ? 16'sd22 : 0) + (hid_spikes[14] ? 16'sd11 : 0) + (hid_spikes[15] ? 16'sd8 : 0) + (hid_spikes[16] ? -16'sd22 : 0) + (hid_spikes[17] ? -16'sd30 : 0) + (hid_spikes[18] ? -16'sd49 : 0) + (hid_spikes[19] ? -16'sd25 : 0) + (hid_spikes[20] ? -16'sd12 : 0) + (hid_spikes[21] ? -16'sd8 : 0) + (hid_spikes[22] ? -16'sd43 : 0) + (hid_spikes[23] ? -16'sd54 : 0) + (hid_spikes[24] ? -16'sd36 : 0) + (hid_spikes[25] ? 16'sd17 : 0) + (hid_spikes[26] ? -16'sd12 : 0) + (hid_spikes[27] ? 16'sd50 : 0) + (hid_spikes[28] ? -16'sd7 : 0) + (hid_spikes[29] ? -16'sd51 : 0) + (hid_spikes[30] ? -16'sd54 : 0) + (hid_spikes[31] ? 16'sd33 : 0) + (hid_spikes[32] ? -16'sd2 : 0) + (hid_spikes[33] ? -16'sd7 : 0) + (hid_spikes[34] ? -16'sd33 : 0) + (hid_spikes[35] ? -16'sd28 : 0) + (hid_spikes[36] ? -16'sd33 : 0) + (hid_spikes[37] ? -16'sd52 : 0) + (hid_spikes[38] ? -16'sd67 : 0) + (hid_spikes[39] ? -16'sd27 : 0);
            hid_mem_14 <= hid_mem_14 - (hid_mem_14 >>> 3) + (ui_in[0] ? 16'sd26 : 0) + (ui_in[1] ? 16'sd25 : 0) + (ui_in[2] ? 16'sd8 : 0) + (ui_in[3] ? 16'sd26 : 0) + (ui_in[4] ? 16'sd28 : 0) + (ui_in[5] ? 16'sd27 : 0) + (ui_in[6] ? 16'sd21 : 0) + (ui_in[7] ? 16'sd15 : 0) + (hid_spikes[0] ? 16'sd3 : 0) + (hid_spikes[1] ? -16'sd8 : 0) + (hid_spikes[2] ? 16'sd31 : 0) + (hid_spikes[3] ? -16'sd17 : 0) + (hid_spikes[4] ? 16'sd46 : 0) + (hid_spikes[5] ? -16'sd127 : 0) + (hid_spikes[6] ? 16'sd127 : 0) + (hid_spikes[7] ? -16'sd55 : 0) + (hid_spikes[8] ? -16'sd23 : 0) + (hid_spikes[9] ? -16'sd86 : 0) + (hid_spikes[10] ? -16'sd8 : 0) + (hid_spikes[11] ? -16'sd12 : 0) + (hid_spikes[12] ? 16'sd13 : 0) + (hid_spikes[13] ? 16'sd5 : 0) + (hid_spikes[14] ? 16'sd46 : 0) + (hid_spikes[15] ? -16'sd12 : 0) + (hid_spikes[16] ? -16'sd57 : 0) + (hid_spikes[17] ? -16'sd67 : 0) + (hid_spikes[18] ? -16'sd19 : 0) + (hid_spikes[19] ? -16'sd16 : 0) + (hid_spikes[20] ? 16'sd10 : 0) + (hid_spikes[21] ? -16'sd52 : 0) + (hid_spikes[22] ? 16'sd34 : 0) + (hid_spikes[23] ? -16'sd1 : 0) + (hid_spikes[24] ? 16'sd6 : 0) + (hid_spikes[25] ? 16'sd52 : 0) + (hid_spikes[26] ? 16'sd4 : 0) + (hid_spikes[27] ? -16'sd23 : 0) + (hid_spikes[28] ? 16'sd12 : 0) + (hid_spikes[29] ? 16'sd9 : 0) + (hid_spikes[30] ? -16'sd18 : 0) + (hid_spikes[31] ? -16'sd26 : 0) + (hid_spikes[32] ? -16'sd2 : 0) + (hid_spikes[33] ? 16'sd24 : 0) + (hid_spikes[34] ? -16'sd30 : 0) + (hid_spikes[35] ? 16'sd4 : 0) + (hid_spikes[36] ? -16'sd71 : 0) + (hid_spikes[37] ? 16'sd21 : 0) + (hid_spikes[38] ? -16'sd5 : 0) + (hid_spikes[39] ? -16'sd31 : 0);
            hid_mem_15 <= hid_mem_15 - (hid_mem_15 >>> 3) + (ui_in[0] ? 16'sd4 : 0) + (ui_in[1] ? 16'sd4 : 0) + (ui_in[2] ? 16'sd3 : 0) + (ui_in[3] ? 16'sd17 : 0) + (ui_in[4] ? 16'sd23 : 0) + (ui_in[5] ? 16'sd27 : 0) + (ui_in[6] ? 16'sd22 : 0) + (ui_in[7] ? 16'sd25 : 0) + (hid_spikes[0] ? -16'sd45 : 0) + (hid_spikes[1] ? 16'sd15 : 0) + (hid_spikes[2] ? 16'sd118 : 0) + (hid_spikes[3] ? 16'sd8 : 0) + (hid_spikes[4] ? 16'sd28 : 0) + (hid_spikes[5] ? -16'sd12 : 0) + (hid_spikes[6] ? 16'sd60 : 0) + (hid_spikes[7] ? 16'sd1 : 0) + (hid_spikes[8] ? -16'sd19 : 0) + (hid_spikes[9] ? -16'sd30 : 0) + (hid_spikes[10] ? 16'sd16 : 0) + (hid_spikes[11] ? 16'sd3 : 0) + (hid_spikes[12] ? 16'sd8 : 0) + (hid_spikes[13] ? -16'sd11 : 0) + (hid_spikes[14] ? -16'sd1 : 0) + (hid_spikes[15] ? 16'sd43 : 0) + (hid_spikes[16] ? 16'sd3 : 0) + (hid_spikes[17] ? -16'sd2 : 0) + (hid_spikes[18] ? 16'sd18 : 0) + (hid_spikes[19] ? 16'sd50 : 0) + (hid_spikes[20] ? 16'sd15 : 0) + (hid_spikes[22] ? -16'sd1 : 0) + (hid_spikes[23] ? 16'sd16 : 0) + (hid_spikes[24] ? -16'sd26 : 0) + (hid_spikes[25] ? 16'sd33 : 0) + (hid_spikes[26] ? -16'sd1 : 0) + (hid_spikes[27] ? 16'sd52 : 0) + (hid_spikes[28] ? -16'sd7 : 0) + (hid_spikes[29] ? -16'sd11 : 0) + (hid_spikes[30] ? -16'sd7 : 0) + (hid_spikes[31] ? 16'sd44 : 0) + (hid_spikes[32] ? 16'sd13 : 0) + (hid_spikes[33] ? -16'sd22 : 0) + (hid_spikes[34] ? -16'sd7 : 0) + (hid_spikes[35] ? -16'sd11 : 0) + (hid_spikes[36] ? -16'sd2 : 0) + (hid_spikes[37] ? 16'sd52 : 0) + (hid_spikes[38] ? 16'sd5 : 0) + (hid_spikes[39] ? -16'sd35 : 0);
            hid_mem_16 <= hid_mem_16 - (hid_mem_16 >>> 3) + (ui_in[0] ? 16'sd2 : 0) + (ui_in[1] ? 16'sd2 : 0) + (ui_in[2] ? 16'sd26 : 0) + (ui_in[3] ? 16'sd5 : 0) + (ui_in[4] ? 16'sd5 : 0) + (ui_in[5] ? 16'sd10 : 0) + (ui_in[6] ? 16'sd2 : 0) + (ui_in[7] ? 16'sd1 : 0) + (hid_spikes[0] ? -16'sd107 : 0) + (hid_spikes[1] ? 16'sd19 : 0) + (hid_spikes[2] ? -16'sd70 : 0) + (hid_spikes[3] ? -16'sd31 : 0) + (hid_spikes[4] ? -16'sd127 : 0) + (hid_spikes[5] ? -16'sd42 : 0) + (hid_spikes[6] ? -16'sd86 : 0) + (hid_spikes[7] ? -16'sd8 : 0) + (hid_spikes[8] ? -16'sd21 : 0) + (hid_spikes[9] ? -16'sd8 : 0) + (hid_spikes[10] ? -16'sd24 : 0) + (hid_spikes[11] ? -16'sd20 : 0) + (hid_spikes[12] ? 16'sd18 : 0) + (hid_spikes[13] ? -16'sd16 : 0) + (hid_spikes[14] ? -16'sd21 : 0) + (hid_spikes[15] ? -16'sd23 : 0) + (hid_spikes[16] ? 16'sd28 : 0) + (hid_spikes[17] ? 16'sd48 : 0) + (hid_spikes[18] ? -16'sd8 : 0) + (hid_spikes[19] ? -16'sd75 : 0) + (hid_spikes[20] ? 16'sd2 : 0) + (hid_spikes[21] ? -16'sd24 : 0) + (hid_spikes[22] ? 16'sd1 : 0) + (hid_spikes[23] ? 16'sd52 : 0) + (hid_spikes[24] ? -16'sd60 : 0) + (hid_spikes[25] ? -16'sd113 : 0) + (hid_spikes[26] ? -16'sd51 : 0) + (hid_spikes[27] ? 16'sd26 : 0) + (hid_spikes[28] ? -16'sd67 : 0) + (hid_spikes[29] ? 16'sd18 : 0) + (hid_spikes[30] ? 16'sd19 : 0) + (hid_spikes[31] ? -16'sd12 : 0) + (hid_spikes[32] ? 16'sd45 : 0) + (hid_spikes[33] ? 16'sd27 : 0) + (hid_spikes[34] ? 16'sd1 : 0) + (hid_spikes[35] ? -16'sd19 : 0) + (hid_spikes[36] ? -16'sd125 : 0) + (hid_spikes[37] ? -16'sd59 : 0) + (hid_spikes[38] ? 16'sd53 : 0) + (hid_spikes[39] ? -16'sd26 : 0);
            hid_mem_17 <= hid_mem_17 - (hid_mem_17 >>> 3) + (ui_in[0] ? 16'sd10 : 0) + (ui_in[1] ? 16'sd10 : 0) + (ui_in[2] ? 16'sd1 : 0) + (ui_in[3] ? 16'sd1 : 0) + (ui_in[4] ? 16'sd25 : 0) + (ui_in[5] ? 16'sd27 : 0) + (ui_in[6] ? 16'sd3 : 0) + (ui_in[7] ? 16'sd20 : 0) + (hid_spikes[0] ? -16'sd5 : 0) + (hid_spikes[1] ? 16'sd15 : 0) + (hid_spikes[2] ? 16'sd81 : 0) + (hid_spikes[3] ? -16'sd71 : 0) + (hid_spikes[4] ? -16'sd71 : 0) + (hid_spikes[5] ? -16'sd16 : 0) + (hid_spikes[6] ? 16'sd42 : 0) + (hid_spikes[7] ? -16'sd21 : 0) + (hid_spikes[8] ? -16'sd38 : 0) + (hid_spikes[9] ? -16'sd1 : 0) + (hid_spikes[10] ? -16'sd15 : 0) + (hid_spikes[11] ? -16'sd41 : 0) + (hid_spikes[12] ? -16'sd69 : 0) + (hid_spikes[13] ? -16'sd31 : 0) + (hid_spikes[14] ? -16'sd122 : 0) + (hid_spikes[15] ? -16'sd22 : 0) + (hid_spikes[16] ? 16'sd23 : 0) + (hid_spikes[17] ? 16'sd12 : 0) + (hid_spikes[18] ? 16'sd36 : 0) + (hid_spikes[19] ? 16'sd65 : 0) + (hid_spikes[20] ? -16'sd34 : 0) + (hid_spikes[21] ? 16'sd28 : 0) + (hid_spikes[22] ? -16'sd61 : 0) + (hid_spikes[23] ? 16'sd28 : 0) + (hid_spikes[24] ? -16'sd16 : 0) + (hid_spikes[25] ? 16'sd5 : 0) + (hid_spikes[26] ? -16'sd48 : 0) + (hid_spikes[27] ? 16'sd39 : 0) + (hid_spikes[29] ? 16'sd26 : 0) + (hid_spikes[30] ? -16'sd3 : 0) + (hid_spikes[31] ? 16'sd32 : 0) + (hid_spikes[32] ? 16'sd17 : 0) + (hid_spikes[33] ? 16'sd5 : 0) + (hid_spikes[34] ? -16'sd2 : 0) + (hid_spikes[35] ? -16'sd1 : 0) + (hid_spikes[36] ? -16'sd70 : 0) + (hid_spikes[37] ? 16'sd38 : 0) + (hid_spikes[38] ? 16'sd67 : 0) + (hid_spikes[39] ? -16'sd31 : 0);
            hid_mem_18 <= hid_mem_18 - (hid_mem_18 >>> 3) + (ui_in[0] ? 16'sd22 : 0) + (ui_in[1] ? 16'sd23 : 0) + (ui_in[2] ? 16'sd23 : 0) + (ui_in[3] ? 16'sd12 : 0) + (ui_in[4] ? 16'sd24 : 0) + (ui_in[5] ? 16'sd18 : 0) + (ui_in[6] ? 16'sd9 : 0) + (ui_in[7] ? 16'sd42 : 0) + (hid_spikes[0] ? 16'sd69 : 0) + (hid_spikes[1] ? -16'sd3 : 0) + (hid_spikes[2] ? -16'sd89 : 0) + (hid_spikes[3] ? -16'sd43 : 0) + (hid_spikes[4] ? -16'sd28 : 0) + (hid_spikes[5] ? -16'sd32 : 0) + (hid_spikes[6] ? -16'sd35 : 0) + (hid_spikes[7] ? 16'sd6 : 0) + (hid_spikes[8] ? -16'sd42 : 0) + (hid_spikes[9] ? -16'sd35 : 0) + (hid_spikes[10] ? -16'sd22 : 0) + (hid_spikes[11] ? -16'sd17 : 0) + (hid_spikes[12] ? -16'sd22 : 0) + (hid_spikes[13] ? -16'sd18 : 0) + (hid_spikes[14] ? -16'sd15 : 0) + (hid_spikes[15] ? 16'sd3 : 0) + (hid_spikes[16] ? 16'sd4 : 0) + (hid_spikes[17] ? -16'sd33 : 0) + (hid_spikes[18] ? -16'sd3 : 0) + (hid_spikes[19] ? 16'sd6 : 0) + (hid_spikes[20] ? -16'sd26 : 0) + (hid_spikes[21] ? -16'sd16 : 0) + (hid_spikes[22] ? -16'sd28 : 0) + (hid_spikes[23] ? -16'sd6 : 0) + (hid_spikes[24] ? 16'sd26 : 0) + (hid_spikes[25] ? -16'sd19 : 0) + (hid_spikes[26] ? -16'sd9 : 0) + (hid_spikes[27] ? -16'sd18 : 0) + (hid_spikes[28] ? -16'sd35 : 0) + (hid_spikes[29] ? -16'sd19 : 0) + (hid_spikes[30] ? 16'sd16 : 0) + (hid_spikes[31] ? -16'sd22 : 0) + (hid_spikes[32] ? 16'sd6 : 0) + (hid_spikes[33] ? 16'sd21 : 0) + (hid_spikes[34] ? -16'sd21 : 0) + (hid_spikes[35] ? 16'sd5 : 0) + (hid_spikes[36] ? 16'sd24 : 0) + (hid_spikes[37] ? -16'sd71 : 0) + (hid_spikes[38] ? -16'sd32 : 0) + (hid_spikes[39] ? -16'sd62 : 0);
            hid_mem_19 <= hid_mem_19 - (hid_mem_19 >>> 3) + (ui_in[0] ? 16'sd1 : 0) + (ui_in[1] ? 16'sd1 : 0) + (ui_in[2] ? 16'sd40 : 0) + (ui_in[3] ? 16'sd39 : 0) + (ui_in[4] ? 16'sd28 : 0) + (ui_in[5] ? 16'sd18 : 0) + (ui_in[6] ? 16'sd9 : 0) + (ui_in[7] ? 16'sd1 : 0) + (hid_spikes[0] ? 16'sd25 : 0) + (hid_spikes[1] ? -16'sd127 : 0) + (hid_spikes[2] ? 16'sd30 : 0) + (hid_spikes[3] ? -16'sd6 : 0) + (hid_spikes[4] ? 16'sd6 : 0) + (hid_spikes[5] ? -16'sd11 : 0) + (hid_spikes[6] ? 16'sd9 : 0) + (hid_spikes[7] ? -16'sd49 : 0) + (hid_spikes[8] ? 16'sd2 : 0) + (hid_spikes[9] ? -16'sd2 : 0) + (hid_spikes[10] ? -16'sd92 : 0) + (hid_spikes[11] ? -16'sd127 : 0) + (hid_spikes[12] ? 16'sd4 : 0) + (hid_spikes[13] ? -16'sd4 : 0) + (hid_spikes[14] ? -16'sd100 : 0) + (hid_spikes[15] ? -16'sd60 : 0) + (hid_spikes[16] ? -16'sd127 : 0) + (hid_spikes[17] ? -16'sd123 : 0) + (hid_spikes[18] ? -16'sd127 : 0) + (hid_spikes[19] ? 16'sd26 : 0) + (hid_spikes[20] ? -16'sd53 : 0) + (hid_spikes[21] ? -16'sd6 : 0) + (hid_spikes[22] ? -16'sd48 : 0) + (hid_spikes[23] ? -16'sd50 : 0) + (hid_spikes[24] ? -16'sd35 : 0) + (hid_spikes[25] ? 16'sd48 : 0) + (hid_spikes[26] ? -16'sd8 : 0) + (hid_spikes[27] ? -16'sd16 : 0) + (hid_spikes[28] ? 16'sd33 : 0) + (hid_spikes[29] ? -16'sd127 : 0) + (hid_spikes[30] ? -16'sd127 : 0) + (hid_spikes[31] ? -16'sd31 : 0) + (hid_spikes[32] ? -16'sd3 : 0) + (hid_spikes[33] ? -16'sd127 : 0) + (hid_spikes[34] ? -16'sd127 : 0) + (hid_spikes[35] ? 16'sd46 : 0) + (hid_spikes[36] ? 16'sd10 : 0) + (hid_spikes[37] ? 16'sd41 : 0) + (hid_spikes[38] ? -16'sd38 : 0) + (hid_spikes[39] ? -16'sd85 : 0);
            hid_mem_20 <= hid_mem_20 - (hid_mem_20 >>> 3) + (ui_in[0] ? 16'sd28 : 0) + (ui_in[1] ? 16'sd28 : 0) + (ui_in[2] ? 16'sd29 : 0) + (ui_in[3] ? 16'sd22 : 0) + (ui_in[4] ? 16'sd24 : 0) + (ui_in[5] ? 16'sd27 : 0) + (ui_in[6] ? 16'sd20 : 0) + (ui_in[7] ? 16'sd29 : 0) + (hid_spikes[0] ? 16'sd40 : 0) + (hid_spikes[1] ? -16'sd10 : 0) + (hid_spikes[2] ? -16'sd30 : 0) + (hid_spikes[3] ? -16'sd55 : 0) + (hid_spikes[4] ? 16'sd18 : 0) + (hid_spikes[5] ? -16'sd73 : 0) + (hid_spikes[6] ? 16'sd38 : 0) + (hid_spikes[7] ? -16'sd20 : 0) + (hid_spikes[8] ? -16'sd43 : 0) + (hid_spikes[9] ? -16'sd72 : 0) + (hid_spikes[10] ? -16'sd33 : 0) + (hid_spikes[11] ? -16'sd17 : 0) + (hid_spikes[12] ? -16'sd24 : 0) + (hid_spikes[13] ? -16'sd2 : 0) + (hid_spikes[14] ? -16'sd3 : 0) + (hid_spikes[15] ? 16'sd4 : 0) + (hid_spikes[16] ? 16'sd5 : 0) + (hid_spikes[17] ? -16'sd62 : 0) + (hid_spikes[18] ? -16'sd34 : 0) + (hid_spikes[19] ? -16'sd14 : 0) + (hid_spikes[20] ? 16'sd11 : 0) + (hid_spikes[21] ? -16'sd48 : 0) + (hid_spikes[22] ? -16'sd18 : 0) + (hid_spikes[23] ? -16'sd14 : 0) + (hid_spikes[25] ? 16'sd5 : 0) + (hid_spikes[26] ? -16'sd39 : 0) + (hid_spikes[27] ? -16'sd19 : 0) + (hid_spikes[28] ? 16'sd11 : 0) + (hid_spikes[29] ? -16'sd15 : 0) + (hid_spikes[30] ? -16'sd3 : 0) + (hid_spikes[31] ? -16'sd14 : 0) + (hid_spikes[32] ? -16'sd14 : 0) + (hid_spikes[33] ? 16'sd13 : 0) + (hid_spikes[34] ? -16'sd25 : 0) + (hid_spikes[35] ? -16'sd3 : 0) + (hid_spikes[36] ? 16'sd25 : 0) + (hid_spikes[37] ? -16'sd21 : 0) + (hid_spikes[38] ? 16'sd3 : 0) + (hid_spikes[39] ? -16'sd70 : 0);
            hid_mem_21 <= hid_mem_21 - (hid_mem_21 >>> 3) + (ui_in[0] ? 16'sd4 : 0) + (ui_in[1] ? 16'sd7 : 0) + (ui_in[2] ? 16'sd39 : 0) + (ui_in[3] ? 16'sd32 : 0) + (ui_in[4] ? 16'sd25 : 0) + (ui_in[5] ? 16'sd13 : 0) + (ui_in[6] ? 16'sd31 : 0) + (ui_in[7] ? 16'sd1 : 0) + (hid_spikes[0] ? -16'sd79 : 0) + (hid_spikes[1] ? -16'sd29 : 0) + (hid_spikes[2] ? -16'sd102 : 0) + (hid_spikes[3] ? -16'sd45 : 0) + (hid_spikes[4] ? -16'sd14 : 0) + (hid_spikes[5] ? -16'sd37 : 0) + (hid_spikes[6] ? 16'sd21 : 0) + (hid_spikes[7] ? -16'sd33 : 0) + (hid_spikes[8] ? 16'sd14 : 0) + (hid_spikes[9] ? -16'sd60 : 0) + (hid_spikes[10] ? -16'sd18 : 0) + (hid_spikes[11] ? -16'sd22 : 0) + (hid_spikes[12] ? -16'sd63 : 0) + (hid_spikes[14] ? -16'sd60 : 0) + (hid_spikes[15] ? -16'sd24 : 0) + (hid_spikes[16] ? 16'sd15 : 0) + (hid_spikes[17] ? -16'sd97 : 0) + (hid_spikes[18] ? -16'sd35 : 0) + (hid_spikes[19] ? 16'sd92 : 0) + (hid_spikes[20] ? -16'sd55 : 0) + (hid_spikes[21] ? -16'sd16 : 0) + (hid_spikes[22] ? 16'sd63 : 0) + (hid_spikes[23] ? -16'sd4 : 0) + (hid_spikes[24] ? 16'sd14 : 0) + (hid_spikes[25] ? -16'sd15 : 0) + (hid_spikes[26] ? -16'sd10 : 0) + (hid_spikes[27] ? -16'sd17 : 0) + (hid_spikes[28] ? 16'sd24 : 0) + (hid_spikes[29] ? -16'sd73 : 0) + (hid_spikes[30] ? -16'sd117 : 0) + (hid_spikes[31] ? -16'sd127 : 0) + (hid_spikes[32] ? 16'sd46 : 0) + (hid_spikes[33] ? -16'sd52 : 0) + (hid_spikes[34] ? -16'sd30 : 0) + (hid_spikes[35] ? -16'sd62 : 0) + (hid_spikes[36] ? -16'sd125 : 0) + (hid_spikes[37] ? -16'sd27 : 0) + (hid_spikes[38] ? -16'sd127 : 0) + (hid_spikes[39] ? -16'sd39 : 0);
            hid_mem_22 <= hid_mem_22 - (hid_mem_22 >>> 3) + (ui_in[0] ? 16'sd23 : 0) + (ui_in[1] ? 16'sd23 : 0) + (ui_in[2] ? 16'sd25 : 0) + (ui_in[3] ? 16'sd22 : 0) + (ui_in[4] ? 16'sd22 : 0) + (ui_in[5] ? 16'sd23 : 0) + (ui_in[6] ? 16'sd21 : 0) + (ui_in[7] ? 16'sd14 : 0) + (hid_spikes[0] ? -16'sd103 : 0) + (hid_spikes[1] ? -16'sd3 : 0) + (hid_spikes[2] ? -16'sd81 : 0) + (hid_spikes[3] ? -16'sd103 : 0) + (hid_spikes[4] ? 16'sd30 : 0) + (hid_spikes[5] ? -16'sd127 : 0) + (hid_spikes[6] ? 16'sd70 : 0) + (hid_spikes[7] ? -16'sd8 : 0) + (hid_spikes[8] ? -16'sd12 : 0) + (hid_spikes[9] ? -16'sd76 : 0) + (hid_spikes[10] ? -16'sd23 : 0) + (hid_spikes[11] ? 16'sd24 : 0) + (hid_spikes[12] ? -16'sd16 : 0) + (hid_spikes[13] ? -16'sd28 : 0) + (hid_spikes[14] ? 16'sd5 : 0) + (hid_spikes[15] ? -16'sd23 : 0) + (hid_spikes[16] ? 16'sd22 : 0) + (hid_spikes[17] ? 16'sd6 : 0) + (hid_spikes[18] ? 16'sd37 : 0) + (hid_spikes[19] ? 16'sd11 : 0) + (hid_spikes[20] ? 16'sd12 : 0) + (hid_spikes[21] ? -16'sd89 : 0) + (hid_spikes[22] ? 16'sd26 : 0) + (hid_spikes[23] ? -16'sd15 : 0) + (hid_spikes[24] ? -16'sd3 : 0) + (hid_spikes[25] ? 16'sd9 : 0) + (hid_spikes[26] ? -16'sd27 : 0) + (hid_spikes[27] ? -16'sd56 : 0) + (hid_spikes[28] ? -16'sd18 : 0) + (hid_spikes[29] ? 16'sd6 : 0) + (hid_spikes[30] ? -16'sd16 : 0) + (hid_spikes[31] ? -16'sd44 : 0) + (hid_spikes[32] ? -16'sd4 : 0) + (hid_spikes[33] ? 16'sd24 : 0) + (hid_spikes[34] ? -16'sd21 : 0) + (hid_spikes[35] ? -16'sd5 : 0) + (hid_spikes[36] ? -16'sd40 : 0) + (hid_spikes[37] ? -16'sd24 : 0) + (hid_spikes[38] ? -16'sd15 : 0) + (hid_spikes[39] ? -16'sd28 : 0);
            hid_mem_23 <= hid_mem_23 - (hid_mem_23 >>> 3) + (ui_in[0] ? 16'sd28 : 0) + (ui_in[1] ? 16'sd29 : 0) + (ui_in[2] ? 16'sd29 : 0) + (ui_in[3] ? 16'sd26 : 0) + (ui_in[4] ? 16'sd29 : 0) + (ui_in[5] ? 16'sd21 : 0) + (ui_in[6] ? 16'sd6 : 0) + (ui_in[7] ? 16'sd11 : 0) + (hid_spikes[0] ? 16'sd20 : 0) + (hid_spikes[1] ? 16'sd3 : 0) + (hid_spikes[2] ? 16'sd19 : 0) + (hid_spikes[3] ? -16'sd46 : 0) + (hid_spikes[4] ? -16'sd28 : 0) + (hid_spikes[5] ? -16'sd47 : 0) + (hid_spikes[6] ? -16'sd57 : 0) + (hid_spikes[7] ? -16'sd26 : 0) + (hid_spikes[8] ? -16'sd42 : 0) + (hid_spikes[9] ? -16'sd69 : 0) + (hid_spikes[10] ? -16'sd19 : 0) + (hid_spikes[11] ? -16'sd2 : 0) + (hid_spikes[12] ? -16'sd19 : 0) + (hid_spikes[13] ? -16'sd23 : 0) + (hid_spikes[14] ? -16'sd13 : 0) + (hid_spikes[15] ? 16'sd8 : 0) + (hid_spikes[16] ? -16'sd29 : 0) + (hid_spikes[17] ? -16'sd11 : 0) + (hid_spikes[18] ? 16'sd9 : 0) + (hid_spikes[19] ? -16'sd74 : 0) + (hid_spikes[20] ? 16'sd57 : 0) + (hid_spikes[21] ? -16'sd28 : 0) + (hid_spikes[22] ? -16'sd17 : 0) + (hid_spikes[24] ? 16'sd30 : 0) + (hid_spikes[25] ? -16'sd5 : 0) + (hid_spikes[26] ? -16'sd36 : 0) + (hid_spikes[27] ? -16'sd25 : 0) + (hid_spikes[28] ? 16'sd7 : 0) + (hid_spikes[29] ? -16'sd1 : 0) + (hid_spikes[30] ? -16'sd49 : 0) + (hid_spikes[31] ? -16'sd17 : 0) + (hid_spikes[32] ? 16'sd45 : 0) + (hid_spikes[33] ? 16'sd29 : 0) + (hid_spikes[34] ? -16'sd6 : 0) + (hid_spikes[35] ? -16'sd20 : 0) + (hid_spikes[36] ? 16'sd24 : 0) + (hid_spikes[37] ? -16'sd3 : 0) + (hid_spikes[38] ? 16'sd6 : 0) + (hid_spikes[39] ? -16'sd70 : 0);
            hid_mem_24 <= hid_mem_24 - (hid_mem_24 >>> 3) + (ui_in[0] ? 16'sd11 : 0) + (ui_in[1] ? 16'sd11 : 0) + (ui_in[2] ? 16'sd22 : 0) + (ui_in[3] ? 16'sd15 : 0) + (ui_in[4] ? 16'sd15 : 0) + (ui_in[5] ? 16'sd12 : 0) + (ui_in[6] ? 16'sd11 : 0) + (ui_in[7] ? 16'sd40 : 0) + (hid_spikes[1] ? 16'sd15 : 0) + (hid_spikes[2] ? -16'sd16 : 0) + (hid_spikes[3] ? -16'sd104 : 0) + (hid_spikes[4] ? -16'sd23 : 0) + (hid_spikes[5] ? -16'sd66 : 0) + (hid_spikes[6] ? 16'sd40 : 0) + (hid_spikes[7] ? -16'sd24 : 0) + (hid_spikes[8] ? -16'sd1 : 0) + (hid_spikes[9] ? -16'sd62 : 0) + (hid_spikes[10] ? -16'sd36 : 0) + (hid_spikes[11] ? -16'sd49 : 0) + (hid_spikes[12] ? -16'sd63 : 0) + (hid_spikes[13] ? -16'sd48 : 0) + (hid_spikes[14] ? -16'sd19 : 0) + (hid_spikes[15] ? 16'sd12 : 0) + (hid_spikes[16] ? -16'sd13 : 0) + (hid_spikes[17] ? 16'sd10 : 0) + (hid_spikes[18] ? -16'sd15 : 0) + (hid_spikes[19] ? 16'sd12 : 0) + (hid_spikes[20] ? 16'sd6 : 0) + (hid_spikes[21] ? -16'sd33 : 0) + (hid_spikes[22] ? -16'sd13 : 0) + (hid_spikes[23] ? 16'sd7 : 0) + (hid_spikes[24] ? 16'sd38 : 0) + (hid_spikes[25] ? -16'sd41 : 0) + (hid_spikes[26] ? -16'sd45 : 0) + (hid_spikes[27] ? -16'sd8 : 0) + (hid_spikes[28] ? 16'sd5 : 0) + (hid_spikes[29] ? -16'sd61 : 0) + (hid_spikes[30] ? -16'sd23 : 0) + (hid_spikes[31] ? -16'sd8 : 0) + (hid_spikes[32] ? -16'sd1 : 0) + (hid_spikes[33] ? 16'sd23 : 0) + (hid_spikes[34] ? -16'sd29 : 0) + (hid_spikes[35] ? 16'sd13 : 0) + (hid_spikes[36] ? 16'sd75 : 0) + (hid_spikes[37] ? 16'sd36 : 0) + (hid_spikes[38] ? 16'sd60 : 0) + (hid_spikes[39] ? -16'sd26 : 0);
            hid_mem_25 <= hid_mem_25 - (hid_mem_25 >>> 3) + (ui_in[0] ? 16'sd1 : 0) + (ui_in[1] ? 16'sd1 : 0) + (ui_in[2] ? 16'sd1 : 0) + (ui_in[3] ? 16'sd12 : 0) + (ui_in[4] ? 16'sd2 : 0) + (ui_in[5] ? 16'sd2 : 0) + (ui_in[6] ? 16'sd1 : 0) + (ui_in[7] ? 16'sd1 : 0) + (hid_spikes[0] ? 16'sd22 : 0) + (hid_spikes[1] ? -16'sd10 : 0) + (hid_spikes[2] ? 16'sd92 : 0) + (hid_spikes[3] ? -16'sd54 : 0) + (hid_spikes[4] ? 16'sd16 : 0) + (hid_spikes[5] ? -16'sd17 : 0) + (hid_spikes[6] ? 16'sd117 : 0) + (hid_spikes[7] ? -16'sd48 : 0) + (hid_spikes[8] ? -16'sd30 : 0) + (hid_spikes[9] ? -16'sd18 : 0) + (hid_spikes[10] ? -16'sd35 : 0) + (hid_spikes[11] ? -16'sd47 : 0) + (hid_spikes[12] ? -16'sd15 : 0) + (hid_spikes[13] ? -16'sd2 : 0) + (hid_spikes[14] ? -16'sd43 : 0) + (hid_spikes[15] ? 16'sd22 : 0) + (hid_spikes[16] ? -16'sd48 : 0) + (hid_spikes[17] ? -16'sd29 : 0) + (hid_spikes[18] ? -16'sd18 : 0) + (hid_spikes[19] ? 16'sd64 : 0) + (hid_spikes[20] ? -16'sd17 : 0) + (hid_spikes[21] ? 16'sd5 : 0) + (hid_spikes[22] ? -16'sd29 : 0) + (hid_spikes[23] ? 16'sd3 : 0) + (hid_spikes[24] ? 16'sd13 : 0) + (hid_spikes[25] ? 16'sd81 : 0) + (hid_spikes[26] ? -16'sd64 : 0) + (hid_spikes[27] ? -16'sd5 : 0) + (hid_spikes[28] ? -16'sd22 : 0) + (hid_spikes[29] ? -16'sd20 : 0) + (hid_spikes[30] ? 16'sd38 : 0) + (hid_spikes[31] ? 16'sd6 : 0) + (hid_spikes[32] ? 16'sd4 : 0) + (hid_spikes[33] ? -16'sd3 : 0) + (hid_spikes[34] ? -16'sd24 : 0) + (hid_spikes[35] ? -16'sd19 : 0) + (hid_spikes[36] ? 16'sd1 : 0) + (hid_spikes[37] ? 16'sd3 : 0) + (hid_spikes[38] ? 16'sd16 : 0) + (hid_spikes[39] ? -16'sd25 : 0);
            hid_mem_26 <= hid_mem_26 - (hid_mem_26 >>> 3) + (ui_in[0] ? 16'sd7 : 0) + (ui_in[1] ? 16'sd7 : 0) + (ui_in[2] ? 16'sd40 : 0) + (ui_in[3] ? 16'sd10 : 0) + (ui_in[4] ? 16'sd10 : 0) + (ui_in[5] ? 16'sd14 : 0) + (ui_in[6] ? 16'sd23 : 0) + (ui_in[7] ? 16'sd1 : 0) + (hid_spikes[0] ? -16'sd100 : 0) + (hid_spikes[1] ? -16'sd6 : 0) + (hid_spikes[2] ? 16'sd13 : 0) + (hid_spikes[3] ? 16'sd25 : 0) + (hid_spikes[4] ? -16'sd57 : 0) + (hid_spikes[5] ? -16'sd14 : 0) + (hid_spikes[6] ? -16'sd42 : 0) + (hid_spikes[7] ? 16'sd4 : 0) + (hid_spikes[8] ? -16'sd29 : 0) + (hid_spikes[9] ? -16'sd17 : 0) + (hid_spikes[10] ? -16'sd20 : 0) + (hid_spikes[11] ? 16'sd21 : 0) + (hid_spikes[12] ? 16'sd23 : 0) + (hid_spikes[13] ? -16'sd9 : 0) + (hid_spikes[14] ? 16'sd2 : 0) + (hid_spikes[15] ? -16'sd4 : 0) + (hid_spikes[16] ? 16'sd14 : 0) + (hid_spikes[17] ? -16'sd19 : 0) + (hid_spikes[18] ? 16'sd16 : 0) + (hid_spikes[19] ? -16'sd32 : 0) + (hid_spikes[20] ? -16'sd33 : 0) + (hid_spikes[21] ? -16'sd1 : 0) + (hid_spikes[23] ? 16'sd7 : 0) + (hid_spikes[24] ? -16'sd70 : 0) + (hid_spikes[25] ? 16'sd6 : 0) + (hid_spikes[26] ? 16'sd23 : 0) + (hid_spikes[27] ? 16'sd51 : 0) + (hid_spikes[28] ? -16'sd15 : 0) + (hid_spikes[29] ? 16'sd18 : 0) + (hid_spikes[30] ? 16'sd1 : 0) + (hid_spikes[31] ? 16'sd11 : 0) + (hid_spikes[32] ? -16'sd12 : 0) + (hid_spikes[33] ? 16'sd4 : 0) + (hid_spikes[34] ? -16'sd29 : 0) + (hid_spikes[35] ? -16'sd4 : 0) + (hid_spikes[36] ? -16'sd80 : 0) + (hid_spikes[37] ? -16'sd3 : 0) + (hid_spikes[38] ? 16'sd3 : 0) + (hid_spikes[39] ? -16'sd93 : 0);
            hid_mem_27 <= hid_mem_27 - (hid_mem_27 >>> 3) + (ui_in[0] ? 16'sd1 : 0) + (ui_in[1] ? 16'sd1 : 0) + (ui_in[2] ? 16'sd1 : 0) + (ui_in[3] ? 16'sd24 : 0) + (ui_in[4] ? 16'sd36 : 0) + (ui_in[5] ? 16'sd38 : 0) + (ui_in[6] ? 16'sd30 : 0) + (ui_in[7] ? 16'sd20 : 0) + (hid_spikes[0] ? 16'sd53 : 0) + (hid_spikes[1] ? -16'sd17 : 0) + (hid_spikes[2] ? -16'sd117 : 0) + (hid_spikes[3] ? -16'sd16 : 0) + (hid_spikes[4] ? -16'sd33 : 0) + (hid_spikes[5] ? -16'sd39 : 0) + (hid_spikes[6] ? 16'sd6 : 0) + (hid_spikes[7] ? -16'sd39 : 0) + (hid_spikes[8] ? -16'sd13 : 0) + (hid_spikes[9] ? -16'sd65 : 0) + (hid_spikes[10] ? -16'sd32 : 0) + (hid_spikes[11] ? -16'sd1 : 0) + (hid_spikes[12] ? -16'sd88 : 0) + (hid_spikes[13] ? -16'sd8 : 0) + (hid_spikes[14] ? -16'sd21 : 0) + (hid_spikes[15] ? 16'sd2 : 0) + (hid_spikes[16] ? -16'sd9 : 0) + (hid_spikes[17] ? -16'sd7 : 0) + (hid_spikes[18] ? -16'sd13 : 0) + (hid_spikes[19] ? -16'sd68 : 0) + (hid_spikes[20] ? -16'sd48 : 0) + (hid_spikes[21] ? -16'sd42 : 0) + (hid_spikes[22] ? -16'sd33 : 0) + (hid_spikes[23] ? -16'sd28 : 0) + (hid_spikes[24] ? -16'sd6 : 0) + (hid_spikes[25] ? -16'sd46 : 0) + (hid_spikes[26] ? 16'sd7 : 0) + (hid_spikes[27] ? 16'sd5 : 0) + (hid_spikes[28] ? 16'sd18 : 0) + (hid_spikes[29] ? 16'sd10 : 0) + (hid_spikes[30] ? 16'sd10 : 0) + (hid_spikes[31] ? -16'sd3 : 0) + (hid_spikes[32] ? 16'sd6 : 0) + (hid_spikes[33] ? 16'sd11 : 0) + (hid_spikes[34] ? -16'sd41 : 0) + (hid_spikes[35] ? -16'sd13 : 0) + (hid_spikes[36] ? 16'sd20 : 0) + (hid_spikes[37] ? 16'sd26 : 0) + (hid_spikes[38] ? 16'sd1 : 0) + (hid_spikes[39] ? -16'sd44 : 0);
            hid_mem_28 <= hid_mem_28 - (hid_mem_28 >>> 3) + (ui_in[0] ? 16'sd23 : 0) + (ui_in[1] ? 16'sd23 : 0) + (ui_in[2] ? 16'sd32 : 0) + (ui_in[3] ? 16'sd24 : 0) + (ui_in[4] ? 16'sd9 : 0) + (ui_in[5] ? 16'sd1 : 0) + (ui_in[6] ? 16'sd1 : 0) + (ui_in[7] ? 16'sd1 : 0) + (hid_spikes[0] ? -16'sd35 : 0) + (hid_spikes[1] ? 16'sd7 : 0) + (hid_spikes[2] ? 16'sd3 : 0) + (hid_spikes[3] ? 16'sd1 : 0) + (hid_spikes[4] ? 16'sd46 : 0) + (hid_spikes[5] ? -16'sd40 : 0) + (hid_spikes[6] ? 16'sd90 : 0) + (hid_spikes[7] ? -16'sd8 : 0) + (hid_spikes[8] ? -16'sd16 : 0) + (hid_spikes[9] ? -16'sd30 : 0) + (hid_spikes[10] ? -16'sd19 : 0) + (hid_spikes[11] ? -16'sd17 : 0) + (hid_spikes[12] ? -16'sd17 : 0) + (hid_spikes[13] ? -16'sd56 : 0) + (hid_spikes[14] ? 16'sd7 : 0) + (hid_spikes[15] ? -16'sd21 : 0) + (hid_spikes[17] ? 16'sd6 : 0) + (hid_spikes[18] ? 16'sd1 : 0) + (hid_spikes[19] ? 16'sd57 : 0) + (hid_spikes[20] ? -16'sd62 : 0) + (hid_spikes[21] ? 16'sd28 : 0) + (hid_spikes[22] ? 16'sd2 : 0) + (hid_spikes[23] ? 16'sd15 : 0) + (hid_spikes[24] ? -16'sd54 : 0) + (hid_spikes[25] ? 16'sd5 : 0) + (hid_spikes[26] ? 16'sd29 : 0) + (hid_spikes[27] ? -16'sd24 : 0) + (hid_spikes[28] ? 16'sd61 : 0) + (hid_spikes[29] ? 16'sd5 : 0) + (hid_spikes[30] ? -16'sd23 : 0) + (hid_spikes[31] ? 16'sd46 : 0) + (hid_spikes[32] ? 16'sd15 : 0) + (hid_spikes[33] ? 16'sd13 : 0) + (hid_spikes[34] ? -16'sd26 : 0) + (hid_spikes[35] ? -16'sd2 : 0) + (hid_spikes[36] ? -16'sd50 : 0) + (hid_spikes[37] ? -16'sd63 : 0) + (hid_spikes[38] ? 16'sd14 : 0) + (hid_spikes[39] ? -16'sd27 : 0);
            hid_mem_29 <= hid_mem_29 - (hid_mem_29 >>> 3) + (ui_in[0] ? 16'sd15 : 0) + (ui_in[1] ? 16'sd15 : 0) + (ui_in[2] ? 16'sd18 : 0) + (ui_in[3] ? 16'sd53 : 0) + (ui_in[4] ? 16'sd33 : 0) + (ui_in[5] ? 16'sd19 : 0) + (ui_in[6] ? 16'sd10 : 0) + (ui_in[7] ? 16'sd1 : 0) + (hid_spikes[1] ? -16'sd23 : 0) + (hid_spikes[2] ? -16'sd15 : 0) + (hid_spikes[3] ? -16'sd26 : 0) + (hid_spikes[4] ? -16'sd39 : 0) + (hid_spikes[5] ? -16'sd41 : 0) + (hid_spikes[6] ? 16'sd118 : 0) + (hid_spikes[7] ? -16'sd9 : 0) + (hid_spikes[8] ? -16'sd55 : 0) + (hid_spikes[9] ? 16'sd14 : 0) + (hid_spikes[10] ? -16'sd6 : 0) + (hid_spikes[11] ? 16'sd8 : 0) + (hid_spikes[12] ? -16'sd21 : 0) + (hid_spikes[13] ? -16'sd65 : 0) + (hid_spikes[14] ? -16'sd11 : 0) + (hid_spikes[15] ? 16'sd5 : 0) + (hid_spikes[16] ? -16'sd47 : 0) + (hid_spikes[17] ? -16'sd55 : 0) + (hid_spikes[18] ? -16'sd27 : 0) + (hid_spikes[19] ? -16'sd9 : 0) + (hid_spikes[20] ? 16'sd17 : 0) + (hid_spikes[21] ? -16'sd77 : 0) + (hid_spikes[22] ? 16'sd14 : 0) + (hid_spikes[23] ? -16'sd20 : 0) + (hid_spikes[24] ? 16'sd35 : 0) + (hid_spikes[25] ? 16'sd9 : 0) + (hid_spikes[26] ? -16'sd32 : 0) + (hid_spikes[27] ? -16'sd105 : 0) + (hid_spikes[28] ? -16'sd7 : 0) + (hid_spikes[29] ? 16'sd2 : 0) + (hid_spikes[30] ? 16'sd2 : 0) + (hid_spikes[31] ? 16'sd21 : 0) + (hid_spikes[32] ? 16'sd26 : 0) + (hid_spikes[33] ? 16'sd35 : 0) + (hid_spikes[34] ? -16'sd18 : 0) + (hid_spikes[35] ? 16'sd2 : 0) + (hid_spikes[36] ? 16'sd80 : 0) + (hid_spikes[37] ? -16'sd17 : 0) + (hid_spikes[38] ? 16'sd2 : 0) + (hid_spikes[39] ? -16'sd92 : 0);
            hid_mem_30 <= hid_mem_30 - (hid_mem_30 >>> 3) + (ui_in[0] ? 16'sd1 : 0) + (ui_in[1] ? 16'sd1 : 0) + (ui_in[2] ? 16'sd36 : 0) + (ui_in[3] ? 16'sd5 : 0) + (ui_in[4] ? 16'sd16 : 0) + (ui_in[5] ? 16'sd27 : 0) + (ui_in[6] ? 16'sd13 : 0) + (ui_in[7] ? 16'sd33 : 0) + (hid_spikes[0] ? 16'sd38 : 0) + (hid_spikes[1] ? 16'sd2 : 0) + (hid_spikes[2] ? 16'sd8 : 0) + (hid_spikes[3] ? 16'sd3 : 0) + (hid_spikes[4] ? 16'sd30 : 0) + (hid_spikes[5] ? -16'sd72 : 0) + (hid_spikes[6] ? 16'sd88 : 0) + (hid_spikes[7] ? -16'sd11 : 0) + (hid_spikes[8] ? -16'sd90 : 0) + (hid_spikes[9] ? 16'sd2 : 0) + (hid_spikes[10] ? -16'sd37 : 0) + (hid_spikes[11] ? 16'sd17 : 0) + (hid_spikes[12] ? -16'sd1 : 0) + (hid_spikes[13] ? 16'sd46 : 0) + (hid_spikes[14] ? 16'sd4 : 0) + (hid_spikes[15] ? -16'sd17 : 0) + (hid_spikes[16] ? -16'sd4 : 0) + (hid_spikes[17] ? 16'sd10 : 0) + (hid_spikes[18] ? 16'sd57 : 0) + (hid_spikes[19] ? 16'sd127 : 0) + (hid_spikes[20] ? 16'sd35 : 0) + (hid_spikes[21] ? 16'sd8 : 0) + (hid_spikes[22] ? 16'sd8 : 0) + (hid_spikes[23] ? 16'sd8 : 0) + (hid_spikes[24] ? 16'sd19 : 0) + (hid_spikes[25] ? 16'sd27 : 0) + (hid_spikes[26] ? -16'sd7 : 0) + (hid_spikes[27] ? 16'sd32 : 0) + (hid_spikes[28] ? -16'sd12 : 0) + (hid_spikes[29] ? 16'sd4 : 0) + (hid_spikes[30] ? 16'sd51 : 0) + (hid_spikes[31] ? 16'sd22 : 0) + (hid_spikes[32] ? 16'sd19 : 0) + (hid_spikes[33] ? 16'sd8 : 0) + (hid_spikes[34] ? 16'sd4 : 0) + (hid_spikes[35] ? 16'sd3 : 0) + (hid_spikes[36] ? -16'sd35 : 0) + (hid_spikes[37] ? 16'sd6 : 0) + (hid_spikes[38] ? 16'sd34 : 0) + (hid_spikes[39] ? -16'sd6 : 0);
            hid_mem_31 <= hid_mem_31 - (hid_mem_31 >>> 3) + (ui_in[0] ? 16'sd8 : 0) + (ui_in[1] ? 16'sd8 : 0) + (ui_in[2] ? 16'sd1 : 0) + (ui_in[3] ? 16'sd22 : 0) + (ui_in[4] ? 16'sd49 : 0) + (ui_in[5] ? 16'sd27 : 0) + (ui_in[6] ? 16'sd1 : 0) + (ui_in[7] ? 16'sd1 : 0) + (hid_spikes[0] ? 16'sd53 : 0) + (hid_spikes[1] ? 16'sd14 : 0) + (hid_spikes[2] ? 16'sd50 : 0) + (hid_spikes[3] ? -16'sd32 : 0) + (hid_spikes[4] ? -16'sd14 : 0) + (hid_spikes[5] ? -16'sd23 : 0) + (hid_spikes[6] ? 16'sd32 : 0) + (hid_spikes[7] ? 16'sd20 : 0) + (hid_spikes[8] ? -16'sd15 : 0) + (hid_spikes[9] ? -16'sd25 : 0) + (hid_spikes[10] ? -16'sd35 : 0) + (hid_spikes[11] ? -16'sd107 : 0) + (hid_spikes[12] ? -16'sd54 : 0) + (hid_spikes[13] ? -16'sd17 : 0) + (hid_spikes[14] ? -16'sd9 : 0) + (hid_spikes[15] ? -16'sd65 : 0) + (hid_spikes[17] ? 16'sd36 : 0) + (hid_spikes[18] ? -16'sd26 : 0) + (hid_spikes[19] ? 16'sd60 : 0) + (hid_spikes[20] ? -16'sd8 : 0) + (hid_spikes[21] ? -16'sd16 : 0) + (hid_spikes[22] ? 16'sd7 : 0) + (hid_spikes[23] ? 16'sd39 : 0) + (hid_spikes[24] ? -16'sd28 : 0) + (hid_spikes[25] ? -16'sd2 : 0) + (hid_spikes[26] ? -16'sd6 : 0) + (hid_spikes[27] ? -16'sd23 : 0) + (hid_spikes[28] ? 16'sd41 : 0) + (hid_spikes[29] ? 16'sd47 : 0) + (hid_spikes[31] ? 16'sd70 : 0) + (hid_spikes[32] ? 16'sd14 : 0) + (hid_spikes[33] ? -16'sd7 : 0) + (hid_spikes[34] ? 16'sd7 : 0) + (hid_spikes[35] ? 16'sd2 : 0) + (hid_spikes[36] ? -16'sd58 : 0) + (hid_spikes[37] ? -16'sd11 : 0) + (hid_spikes[38] ? 16'sd37 : 0) + (hid_spikes[39] ? -16'sd113 : 0);
            hid_mem_32 <= hid_mem_32 - (hid_mem_32 >>> 3) + (ui_in[0] ? 16'sd21 : 0) + (ui_in[1] ? 16'sd21 : 0) + (ui_in[2] ? 16'sd24 : 0) + (ui_in[3] ? 16'sd30 : 0) + (ui_in[4] ? 16'sd30 : 0) + (ui_in[5] ? 16'sd21 : 0) + (ui_in[6] ? 16'sd6 : 0) + (ui_in[7] ? 16'sd1 : 0) + (hid_spikes[0] ? -16'sd21 : 0) + (hid_spikes[1] ? 16'sd16 : 0) + (hid_spikes[2] ? -16'sd93 : 0) + (hid_spikes[3] ? -16'sd15 : 0) + (hid_spikes[4] ? -16'sd24 : 0) + (hid_spikes[5] ? -16'sd38 : 0) + (hid_spikes[6] ? 16'sd2 : 0) + (hid_spikes[7] ? -16'sd46 : 0) + (hid_spikes[8] ? -16'sd24 : 0) + (hid_spikes[9] ? -16'sd44 : 0) + (hid_spikes[10] ? -16'sd27 : 0) + (hid_spikes[11] ? -16'sd11 : 0) + (hid_spikes[12] ? -16'sd35 : 0) + (hid_spikes[13] ? -16'sd52 : 0) + (hid_spikes[14] ? -16'sd9 : 0) + (hid_spikes[15] ? -16'sd8 : 0) + (hid_spikes[16] ? -16'sd24 : 0) + (hid_spikes[17] ? -16'sd22 : 0) + (hid_spikes[18] ? -16'sd28 : 0) + (hid_spikes[19] ? 16'sd28 : 0) + (hid_spikes[20] ? -16'sd10 : 0) + (hid_spikes[21] ? -16'sd10 : 0) + (hid_spikes[22] ? -16'sd15 : 0) + (hid_spikes[23] ? 16'sd34 : 0) + (hid_spikes[24] ? -16'sd27 : 0) + (hid_spikes[25] ? 16'sd68 : 0) + (hid_spikes[26] ? -16'sd8 : 0) + (hid_spikes[27] ? -16'sd55 : 0) + (hid_spikes[28] ? -16'sd53 : 0) + (hid_spikes[29] ? -16'sd8 : 0) + (hid_spikes[30] ? -16'sd15 : 0) + (hid_spikes[31] ? -16'sd127 : 0) + (hid_spikes[32] ? -16'sd23 : 0) + (hid_spikes[33] ? 16'sd26 : 0) + (hid_spikes[34] ? -16'sd7 : 0) + (hid_spikes[35] ? 16'sd8 : 0) + (hid_spikes[36] ? 16'sd17 : 0) + (hid_spikes[37] ? -16'sd26 : 0) + (hid_spikes[38] ? 16'sd31 : 0) + (hid_spikes[39] ? -16'sd49 : 0);
            hid_mem_33 <= hid_mem_33 - (hid_mem_33 >>> 3) + (ui_in[0] ? 16'sd4 : 0) + (ui_in[1] ? 16'sd4 : 0) + (ui_in[2] ? 16'sd1 : 0) + (ui_in[3] ? 16'sd15 : 0) + (ui_in[4] ? 16'sd18 : 0) + (ui_in[5] ? 16'sd18 : 0) + (ui_in[6] ? 16'sd1 : 0) + (ui_in[7] ? 16'sd15 : 0) + (hid_spikes[0] ? 16'sd65 : 0) + (hid_spikes[1] ? 16'sd34 : 0) + (hid_spikes[2] ? 16'sd115 : 0) + (hid_spikes[3] ? -16'sd28 : 0) + (hid_spikes[4] ? -16'sd13 : 0) + (hid_spikes[5] ? -16'sd117 : 0) + (hid_spikes[6] ? 16'sd127 : 0) + (hid_spikes[7] ? 16'sd29 : 0) + (hid_spikes[8] ? -16'sd46 : 0) + (hid_spikes[9] ? 16'sd42 : 0) + (hid_spikes[10] ? -16'sd24 : 0) + (hid_spikes[11] ? -16'sd5 : 0) + (hid_spikes[12] ? 16'sd13 : 0) + (hid_spikes[13] ? -16'sd10 : 0) + (hid_spikes[14] ? 16'sd7 : 0) + (hid_spikes[15] ? 16'sd9 : 0) + (hid_spikes[16] ? -16'sd8 : 0) + (hid_spikes[17] ? 16'sd88 : 0) + (hid_spikes[18] ? 16'sd34 : 0) + (hid_spikes[19] ? 16'sd93 : 0) + (hid_spikes[20] ? 16'sd15 : 0) + (hid_spikes[21] ? -16'sd1 : 0) + (hid_spikes[22] ? 16'sd17 : 0) + (hid_spikes[23] ? 16'sd25 : 0) + (hid_spikes[25] ? 16'sd39 : 0) + (hid_spikes[26] ? -16'sd30 : 0) + (hid_spikes[27] ? 16'sd27 : 0) + (hid_spikes[28] ? 16'sd4 : 0) + (hid_spikes[29] ? 16'sd8 : 0) + (hid_spikes[30] ? 16'sd6 : 0) + (hid_spikes[31] ? 16'sd104 : 0) + (hid_spikes[32] ? 16'sd14 : 0) + (hid_spikes[33] ? 16'sd33 : 0) + (hid_spikes[34] ? -16'sd14 : 0) + (hid_spikes[35] ? 16'sd5 : 0) + (hid_spikes[36] ? 16'sd54 : 0) + (hid_spikes[37] ? -16'sd3 : 0) + (hid_spikes[38] ? 16'sd98 : 0) + (hid_spikes[39] ? -16'sd33 : 0);
            hid_mem_34 <= hid_mem_34 - (hid_mem_34 >>> 3) + (ui_in[0] ? 16'sd5 : 0) + (ui_in[1] ? 16'sd6 : 0) + (ui_in[2] ? 16'sd2 : 0) + (ui_in[3] ? 16'sd25 : 0) + (ui_in[4] ? 16'sd34 : 0) + (ui_in[5] ? 16'sd34 : 0) + (ui_in[6] ? 16'sd1 : 0) + (ui_in[7] ? 16'sd1 : 0) + (hid_spikes[0] ? -16'sd6 : 0) + (hid_spikes[1] ? 16'sd8 : 0) + (hid_spikes[2] ? 16'sd8 : 0) + (hid_spikes[3] ? -16'sd3 : 0) + (hid_spikes[4] ? -16'sd2 : 0) + (hid_spikes[5] ? -16'sd23 : 0) + (hid_spikes[6] ? -16'sd9 : 0) + (hid_spikes[7] ? -16'sd25 : 0) + (hid_spikes[8] ? -16'sd26 : 0) + (hid_spikes[9] ? -16'sd6 : 0) + (hid_spikes[10] ? 16'sd18 : 0) + (hid_spikes[11] ? -16'sd23 : 0) + (hid_spikes[12] ? 16'sd8 : 0) + (hid_spikes[13] ? -16'sd14 : 0) + (hid_spikes[14] ? -16'sd6 : 0) + (hid_spikes[16] ? 16'sd2 : 0) + (hid_spikes[17] ? 16'sd16 : 0) + (hid_spikes[18] ? 16'sd39 : 0) + (hid_spikes[19] ? 16'sd46 : 0) + (hid_spikes[20] ? -16'sd21 : 0) + (hid_spikes[21] ? -16'sd45 : 0) + (hid_spikes[22] ? -16'sd7 : 0) + (hid_spikes[23] ? -16'sd17 : 0) + (hid_spikes[24] ? -16'sd43 : 0) + (hid_spikes[25] ? -16'sd10 : 0) + (hid_spikes[26] ? -16'sd33 : 0) + (hid_spikes[27] ? -16'sd48 : 0) + (hid_spikes[28] ? 16'sd16 : 0) + (hid_spikes[29] ? -16'sd5 : 0) + (hid_spikes[30] ? -16'sd36 : 0) + (hid_spikes[31] ? 16'sd69 : 0) + (hid_spikes[32] ? -16'sd15 : 0) + (hid_spikes[33] ? -16'sd17 : 0) + (hid_spikes[34] ? 16'sd55 : 0) + (hid_spikes[35] ? -16'sd54 : 0) + (hid_spikes[36] ? 16'sd9 : 0) + (hid_spikes[37] ? 16'sd55 : 0) + (hid_spikes[38] ? 16'sd14 : 0) + (hid_spikes[39] ? -16'sd8 : 0);
            hid_mem_35 <= hid_mem_35 - (hid_mem_35 >>> 3) + (ui_in[0] ? 16'sd1 : 0) + (ui_in[1] ? 16'sd1 : 0) + (ui_in[2] ? 16'sd1 : 0) + (ui_in[3] ? 16'sd2 : 0) + (ui_in[4] ? 16'sd1 : 0) + (ui_in[5] ? 16'sd1 : 0) + (ui_in[6] ? 16'sd16 : 0) + (ui_in[7] ? 16'sd48 : 0) + (hid_spikes[0] ? 16'sd36 : 0) + (hid_spikes[1] ? -16'sd34 : 0) + (hid_spikes[2] ? 16'sd55 : 0) + (hid_spikes[3] ? -16'sd36 : 0) + (hid_spikes[4] ? 16'sd17 : 0) + (hid_spikes[5] ? -16'sd34 : 0) + (hid_spikes[6] ? 16'sd88 : 0) + (hid_spikes[7] ? -16'sd21 : 0) + (hid_spikes[8] ? -16'sd48 : 0) + (hid_spikes[9] ? -16'sd26 : 0) + (hid_spikes[10] ? -16'sd31 : 0) + (hid_spikes[11] ? 16'sd6 : 0) + (hid_spikes[12] ? 16'sd4 : 0) + (hid_spikes[13] ? -16'sd25 : 0) + (hid_spikes[14] ? -16'sd12 : 0) + (hid_spikes[15] ? -16'sd16 : 0) + (hid_spikes[16] ? -16'sd51 : 0) + (hid_spikes[17] ? -16'sd38 : 0) + (hid_spikes[18] ? -16'sd3 : 0) + (hid_spikes[19] ? 16'sd9 : 0) + (hid_spikes[20] ? 16'sd11 : 0) + (hid_spikes[21] ? -16'sd15 : 0) + (hid_spikes[22] ? -16'sd14 : 0) + (hid_spikes[23] ? -16'sd47 : 0) + (hid_spikes[24] ? 16'sd44 : 0) + (hid_spikes[25] ? 16'sd48 : 0) + (hid_spikes[26] ? -16'sd60 : 0) + (hid_spikes[27] ? 16'sd22 : 0) + (hid_spikes[28] ? -16'sd40 : 0) + (hid_spikes[29] ? 16'sd14 : 0) + (hid_spikes[30] ? 16'sd47 : 0) + (hid_spikes[31] ? -16'sd20 : 0) + (hid_spikes[32] ? 16'sd10 : 0) + (hid_spikes[33] ? 16'sd37 : 0) + (hid_spikes[34] ? -16'sd78 : 0) + (hid_spikes[35] ? 16'sd41 : 0) + (hid_spikes[36] ? 16'sd33 : 0) + (hid_spikes[37] ? -16'sd61 : 0) + (hid_spikes[39] ? -16'sd80 : 0);
            hid_mem_36 <= hid_mem_36 - (hid_mem_36 >>> 3) + (ui_in[0] ? 16'sd1 : 0) + (ui_in[1] ? 16'sd1 : 0) + (ui_in[2] ? 16'sd1 : 0) + (ui_in[3] ? 16'sd8 : 0) + (ui_in[4] ? 16'sd3 : 0) + (ui_in[5] ? 16'sd10 : 0) + (ui_in[6] ? 16'sd50 : 0) + (ui_in[7] ? 16'sd17 : 0) + (hid_spikes[0] ? 16'sd16 : 0) + (hid_spikes[2] ? 16'sd17 : 0) + (hid_spikes[3] ? -16'sd18 : 0) + (hid_spikes[4] ? 16'sd23 : 0) + (hid_spikes[5] ? -16'sd5 : 0) + (hid_spikes[6] ? 16'sd20 : 0) + (hid_spikes[7] ? -16'sd11 : 0) + (hid_spikes[8] ? 16'sd1 : 0) + (hid_spikes[9] ? -16'sd34 : 0) + (hid_spikes[10] ? -16'sd119 : 0) + (hid_spikes[11] ? 16'sd16 : 0) + (hid_spikes[12] ? 16'sd11 : 0) + (hid_spikes[13] ? -16'sd17 : 0) + (hid_spikes[14] ? -16'sd3 : 0) + (hid_spikes[15] ? -16'sd85 : 0) + (hid_spikes[16] ? -16'sd6 : 0) + (hid_spikes[17] ? 16'sd4 : 0) + (hid_spikes[18] ? 16'sd9 : 0) + (hid_spikes[19] ? 16'sd2 : 0) + (hid_spikes[20] ? 16'sd49 : 0) + (hid_spikes[21] ? -16'sd7 : 0) + (hid_spikes[22] ? 16'sd22 : 0) + (hid_spikes[23] ? 16'sd8 : 0) + (hid_spikes[24] ? 16'sd26 : 0) + (hid_spikes[25] ? 16'sd64 : 0) + (hid_spikes[26] ? 16'sd1 : 0) + (hid_spikes[27] ? -16'sd1 : 0) + (hid_spikes[28] ? -16'sd24 : 0) + (hid_spikes[29] ? 16'sd6 : 0) + (hid_spikes[30] ? -16'sd3 : 0) + (hid_spikes[31] ? -16'sd11 : 0) + (hid_spikes[32] ? 16'sd30 : 0) + (hid_spikes[33] ? -16'sd5 : 0) + (hid_spikes[34] ? -16'sd106 : 0) + (hid_spikes[35] ? 16'sd6 : 0) + (hid_spikes[36] ? 16'sd42 : 0) + (hid_spikes[37] ? -16'sd12 : 0) + (hid_spikes[38] ? 16'sd20 : 0) + (hid_spikes[39] ? -16'sd60 : 0);
            hid_mem_37 <= hid_mem_37 - (hid_mem_37 >>> 3) + (ui_in[0] ? 16'sd31 : 0) + (ui_in[1] ? 16'sd31 : 0) + (ui_in[2] ? 16'sd70 : 0) + (ui_in[3] ? 16'sd12 : 0) + (ui_in[4] ? 16'sd5 : 0) + (ui_in[5] ? 16'sd5 : 0) + (ui_in[6] ? 16'sd53 : 0) + (ui_in[7] ? 16'sd1 : 0) + (hid_spikes[0] ? 16'sd4 : 0) + (hid_spikes[1] ? -16'sd12 : 0) + (hid_spikes[2] ? 16'sd16 : 0) + (hid_spikes[3] ? -16'sd36 : 0) + (hid_spikes[4] ? 16'sd74 : 0) + (hid_spikes[5] ? -16'sd73 : 0) + (hid_spikes[6] ? 16'sd50 : 0) + (hid_spikes[7] ? 16'sd5 : 0) + (hid_spikes[8] ? -16'sd56 : 0) + (hid_spikes[9] ? -16'sd32 : 0) + (hid_spikes[10] ? -16'sd70 : 0) + (hid_spikes[11] ? -16'sd9 : 0) + (hid_spikes[12] ? -16'sd4 : 0) + (hid_spikes[14] ? -16'sd17 : 0) + (hid_spikes[15] ? -16'sd66 : 0) + (hid_spikes[16] ? 16'sd17 : 0) + (hid_spikes[17] ? 16'sd10 : 0) + (hid_spikes[18] ? -16'sd26 : 0) + (hid_spikes[19] ? 16'sd41 : 0) + (hid_spikes[20] ? 16'sd40 : 0) + (hid_spikes[21] ? 16'sd31 : 0) + (hid_spikes[22] ? -16'sd23 : 0) + (hid_spikes[23] ? -16'sd13 : 0) + (hid_spikes[24] ? 16'sd43 : 0) + (hid_spikes[25] ? 16'sd26 : 0) + (hid_spikes[26] ? 16'sd10 : 0) + (hid_spikes[27] ? 16'sd28 : 0) + (hid_spikes[29] ? 16'sd6 : 0) + (hid_spikes[30] ? 16'sd13 : 0) + (hid_spikes[31] ? 16'sd20 : 0) + (hid_spikes[32] ? 16'sd11 : 0) + (hid_spikes[34] ? -16'sd19 : 0) + (hid_spikes[35] ? 16'sd19 : 0) + (hid_spikes[36] ? 16'sd52 : 0) + (hid_spikes[37] ? 16'sd22 : 0) + (hid_spikes[38] ? 16'sd23 : 0) + (hid_spikes[39] ? -16'sd75 : 0);
            hid_mem_38 <= hid_mem_38 - (hid_mem_38 >>> 3) + (ui_in[0] ? 16'sd7 : 0) + (ui_in[1] ? 16'sd7 : 0) + (ui_in[2] ? 16'sd1 : 0) + (ui_in[3] ? 16'sd13 : 0) + (ui_in[4] ? 16'sd39 : 0) + (ui_in[5] ? 16'sd40 : 0) + (ui_in[6] ? 16'sd2 : 0) + (ui_in[7] ? 16'sd26 : 0) + (hid_spikes[0] ? 16'sd20 : 0) + (hid_spikes[1] ? -16'sd17 : 0) + (hid_spikes[2] ? -16'sd100 : 0) + (hid_spikes[3] ? -16'sd11 : 0) + (hid_spikes[4] ? 16'sd13 : 0) + (hid_spikes[5] ? -16'sd7 : 0) + (hid_spikes[6] ? 16'sd58 : 0) + (hid_spikes[7] ? -16'sd17 : 0) + (hid_spikes[8] ? -16'sd36 : 0) + (hid_spikes[9] ? 16'sd2 : 0) + (hid_spikes[10] ? -16'sd38 : 0) + (hid_spikes[11] ? -16'sd21 : 0) + (hid_spikes[12] ? 16'sd1 : 0) + (hid_spikes[13] ? 16'sd26 : 0) + (hid_spikes[14] ? 16'sd2 : 0) + (hid_spikes[15] ? -16'sd30 : 0) + (hid_spikes[16] ? -16'sd12 : 0) + (hid_spikes[17] ? -16'sd8 : 0) + (hid_spikes[18] ? 16'sd13 : 0) + (hid_spikes[19] ? 16'sd1 : 0) + (hid_spikes[20] ? -16'sd37 : 0) + (hid_spikes[21] ? -16'sd50 : 0) + (hid_spikes[22] ? -16'sd9 : 0) + (hid_spikes[23] ? -16'sd32 : 0) + (hid_spikes[24] ? -16'sd1 : 0) + (hid_spikes[25] ? -16'sd47 : 0) + (hid_spikes[26] ? 16'sd10 : 0) + (hid_spikes[27] ? 16'sd13 : 0) + (hid_spikes[28] ? -16'sd38 : 0) + (hid_spikes[29] ? -16'sd1 : 0) + (hid_spikes[30] ? -16'sd23 : 0) + (hid_spikes[31] ? 16'sd12 : 0) + (hid_spikes[32] ? -16'sd19 : 0) + (hid_spikes[33] ? 16'sd13 : 0) + (hid_spikes[34] ? -16'sd69 : 0) + (hid_spikes[35] ? 16'sd9 : 0) + (hid_spikes[36] ? 16'sd32 : 0) + (hid_spikes[37] ? 16'sd26 : 0) + (hid_spikes[38] ? 16'sd40 : 0) + (hid_spikes[39] ? -16'sd28 : 0);
            hid_mem_39 <= hid_mem_39 - (hid_mem_39 >>> 3) + (ui_in[0] ? 16'sd48 : 0) + (ui_in[1] ? 16'sd45 : 0) + (ui_in[2] ? 16'sd1 : 0) + (ui_in[3] ? 16'sd1 : 0) + (ui_in[4] ? 16'sd1 : 0) + (ui_in[5] ? 16'sd7 : 0) + (ui_in[6] ? 16'sd1 : 0) + (ui_in[7] ? 16'sd66 : 0) + (hid_spikes[0] ? 16'sd32 : 0) + (hid_spikes[1] ? 16'sd7 : 0) + (hid_spikes[2] ? 16'sd8 : 0) + (hid_spikes[3] ? -16'sd18 : 0) + (hid_spikes[4] ? 16'sd26 : 0) + (hid_spikes[5] ? -16'sd8 : 0) + (hid_spikes[6] ? -16'sd46 : 0) + (hid_spikes[7] ? 16'sd31 : 0) + (hid_spikes[8] ? -16'sd7 : 0) + (hid_spikes[9] ? 16'sd43 : 0) + (hid_spikes[10] ? -16'sd20 : 0) + (hid_spikes[11] ? -16'sd23 : 0) + (hid_spikes[12] ? -16'sd16 : 0) + (hid_spikes[14] ? -16'sd11 : 0) + (hid_spikes[15] ? -16'sd35 : 0) + (hid_spikes[16] ? -16'sd29 : 0) + (hid_spikes[17] ? 16'sd87 : 0) + (hid_spikes[18] ? -16'sd26 : 0) + (hid_spikes[19] ? 16'sd32 : 0) + (hid_spikes[20] ? -16'sd42 : 0) + (hid_spikes[21] ? -16'sd11 : 0) + (hid_spikes[22] ? 16'sd2 : 0) + (hid_spikes[23] ? 16'sd23 : 0) + (hid_spikes[24] ? 16'sd53 : 0) + (hid_spikes[25] ? 16'sd61 : 0) + (hid_spikes[26] ? 16'sd19 : 0) + (hid_spikes[27] ? -16'sd11 : 0) + (hid_spikes[28] ? -16'sd12 : 0) + (hid_spikes[29] ? -16'sd18 : 0) + (hid_spikes[30] ? 16'sd20 : 0) + (hid_spikes[31] ? -16'sd33 : 0) + (hid_spikes[32] ? -16'sd17 : 0) + (hid_spikes[33] ? -16'sd7 : 0) + (hid_spikes[34] ? -16'sd5 : 0) + (hid_spikes[35] ? -16'sd6 : 0) + (hid_spikes[36] ? -16'sd19 : 0) + (hid_spikes[37] ? 16'sd24 : 0) + (hid_spikes[38] ? 16'sd68 : 0) + (hid_spikes[39] ? 16'sd19 : 0);

            // Hidden Spiking Logic
            if (hid_mem_0 >= 16'sd73) begin
                hid_spikes[0] <= 1'b1;
                hid_mem_0 <= hid_mem_0 - 16'sd73;
            end else begin
                hid_spikes[0] <= 1'b0;
            end
            if (hid_mem_1 >= 16'sd73) begin
                hid_spikes[1] <= 1'b1;
                hid_mem_1 <= hid_mem_1 - 16'sd73;
            end else begin
                hid_spikes[1] <= 1'b0;
            end
            if (hid_mem_2 >= 16'sd73) begin
                hid_spikes[2] <= 1'b1;
                hid_mem_2 <= hid_mem_2 - 16'sd73;
            end else begin
                hid_spikes[2] <= 1'b0;
            end
            if (hid_mem_3 >= 16'sd73) begin
                hid_spikes[3] <= 1'b1;
                hid_mem_3 <= hid_mem_3 - 16'sd73;
            end else begin
                hid_spikes[3] <= 1'b0;
            end
            if (hid_mem_4 >= 16'sd73) begin
                hid_spikes[4] <= 1'b1;
                hid_mem_4 <= hid_mem_4 - 16'sd73;
            end else begin
                hid_spikes[4] <= 1'b0;
            end
            if (hid_mem_5 >= 16'sd73) begin
                hid_spikes[5] <= 1'b1;
                hid_mem_5 <= hid_mem_5 - 16'sd73;
            end else begin
                hid_spikes[5] <= 1'b0;
            end
            if (hid_mem_6 >= 16'sd73) begin
                hid_spikes[6] <= 1'b1;
                hid_mem_6 <= hid_mem_6 - 16'sd73;
            end else begin
                hid_spikes[6] <= 1'b0;
            end
            if (hid_mem_7 >= 16'sd73) begin
                hid_spikes[7] <= 1'b1;
                hid_mem_7 <= hid_mem_7 - 16'sd73;
            end else begin
                hid_spikes[7] <= 1'b0;
            end
            if (hid_mem_8 >= 16'sd73) begin
                hid_spikes[8] <= 1'b1;
                hid_mem_8 <= hid_mem_8 - 16'sd73;
            end else begin
                hid_spikes[8] <= 1'b0;
            end
            if (hid_mem_9 >= 16'sd73) begin
                hid_spikes[9] <= 1'b1;
                hid_mem_9 <= hid_mem_9 - 16'sd73;
            end else begin
                hid_spikes[9] <= 1'b0;
            end
            if (hid_mem_10 >= 16'sd73) begin
                hid_spikes[10] <= 1'b1;
                hid_mem_10 <= hid_mem_10 - 16'sd73;
            end else begin
                hid_spikes[10] <= 1'b0;
            end
            if (hid_mem_11 >= 16'sd73) begin
                hid_spikes[11] <= 1'b1;
                hid_mem_11 <= hid_mem_11 - 16'sd73;
            end else begin
                hid_spikes[11] <= 1'b0;
            end
            if (hid_mem_12 >= 16'sd73) begin
                hid_spikes[12] <= 1'b1;
                hid_mem_12 <= hid_mem_12 - 16'sd73;
            end else begin
                hid_spikes[12] <= 1'b0;
            end
            if (hid_mem_13 >= 16'sd73) begin
                hid_spikes[13] <= 1'b1;
                hid_mem_13 <= hid_mem_13 - 16'sd73;
            end else begin
                hid_spikes[13] <= 1'b0;
            end
            if (hid_mem_14 >= 16'sd73) begin
                hid_spikes[14] <= 1'b1;
                hid_mem_14 <= hid_mem_14 - 16'sd73;
            end else begin
                hid_spikes[14] <= 1'b0;
            end
            if (hid_mem_15 >= 16'sd73) begin
                hid_spikes[15] <= 1'b1;
                hid_mem_15 <= hid_mem_15 - 16'sd73;
            end else begin
                hid_spikes[15] <= 1'b0;
            end
            if (hid_mem_16 >= 16'sd73) begin
                hid_spikes[16] <= 1'b1;
                hid_mem_16 <= hid_mem_16 - 16'sd73;
            end else begin
                hid_spikes[16] <= 1'b0;
            end
            if (hid_mem_17 >= 16'sd73) begin
                hid_spikes[17] <= 1'b1;
                hid_mem_17 <= hid_mem_17 - 16'sd73;
            end else begin
                hid_spikes[17] <= 1'b0;
            end
            if (hid_mem_18 >= 16'sd73) begin
                hid_spikes[18] <= 1'b1;
                hid_mem_18 <= hid_mem_18 - 16'sd73;
            end else begin
                hid_spikes[18] <= 1'b0;
            end
            if (hid_mem_19 >= 16'sd73) begin
                hid_spikes[19] <= 1'b1;
                hid_mem_19 <= hid_mem_19 - 16'sd73;
            end else begin
                hid_spikes[19] <= 1'b0;
            end
            if (hid_mem_20 >= 16'sd73) begin
                hid_spikes[20] <= 1'b1;
                hid_mem_20 <= hid_mem_20 - 16'sd73;
            end else begin
                hid_spikes[20] <= 1'b0;
            end
            if (hid_mem_21 >= 16'sd73) begin
                hid_spikes[21] <= 1'b1;
                hid_mem_21 <= hid_mem_21 - 16'sd73;
            end else begin
                hid_spikes[21] <= 1'b0;
            end
            if (hid_mem_22 >= 16'sd73) begin
                hid_spikes[22] <= 1'b1;
                hid_mem_22 <= hid_mem_22 - 16'sd73;
            end else begin
                hid_spikes[22] <= 1'b0;
            end
            if (hid_mem_23 >= 16'sd73) begin
                hid_spikes[23] <= 1'b1;
                hid_mem_23 <= hid_mem_23 - 16'sd73;
            end else begin
                hid_spikes[23] <= 1'b0;
            end
            if (hid_mem_24 >= 16'sd73) begin
                hid_spikes[24] <= 1'b1;
                hid_mem_24 <= hid_mem_24 - 16'sd73;
            end else begin
                hid_spikes[24] <= 1'b0;
            end
            if (hid_mem_25 >= 16'sd73) begin
                hid_spikes[25] <= 1'b1;
                hid_mem_25 <= hid_mem_25 - 16'sd73;
            end else begin
                hid_spikes[25] <= 1'b0;
            end
            if (hid_mem_26 >= 16'sd73) begin
                hid_spikes[26] <= 1'b1;
                hid_mem_26 <= hid_mem_26 - 16'sd73;
            end else begin
                hid_spikes[26] <= 1'b0;
            end
            if (hid_mem_27 >= 16'sd73) begin
                hid_spikes[27] <= 1'b1;
                hid_mem_27 <= hid_mem_27 - 16'sd73;
            end else begin
                hid_spikes[27] <= 1'b0;
            end
            if (hid_mem_28 >= 16'sd73) begin
                hid_spikes[28] <= 1'b1;
                hid_mem_28 <= hid_mem_28 - 16'sd73;
            end else begin
                hid_spikes[28] <= 1'b0;
            end
            if (hid_mem_29 >= 16'sd73) begin
                hid_spikes[29] <= 1'b1;
                hid_mem_29 <= hid_mem_29 - 16'sd73;
            end else begin
                hid_spikes[29] <= 1'b0;
            end
            if (hid_mem_30 >= 16'sd73) begin
                hid_spikes[30] <= 1'b1;
                hid_mem_30 <= hid_mem_30 - 16'sd73;
            end else begin
                hid_spikes[30] <= 1'b0;
            end
            if (hid_mem_31 >= 16'sd73) begin
                hid_spikes[31] <= 1'b1;
                hid_mem_31 <= hid_mem_31 - 16'sd73;
            end else begin
                hid_spikes[31] <= 1'b0;
            end
            if (hid_mem_32 >= 16'sd73) begin
                hid_spikes[32] <= 1'b1;
                hid_mem_32 <= hid_mem_32 - 16'sd73;
            end else begin
                hid_spikes[32] <= 1'b0;
            end
            if (hid_mem_33 >= 16'sd73) begin
                hid_spikes[33] <= 1'b1;
                hid_mem_33 <= hid_mem_33 - 16'sd73;
            end else begin
                hid_spikes[33] <= 1'b0;
            end
            if (hid_mem_34 >= 16'sd73) begin
                hid_spikes[34] <= 1'b1;
                hid_mem_34 <= hid_mem_34 - 16'sd73;
            end else begin
                hid_spikes[34] <= 1'b0;
            end
            if (hid_mem_35 >= 16'sd73) begin
                hid_spikes[35] <= 1'b1;
                hid_mem_35 <= hid_mem_35 - 16'sd73;
            end else begin
                hid_spikes[35] <= 1'b0;
            end
            if (hid_mem_36 >= 16'sd73) begin
                hid_spikes[36] <= 1'b1;
                hid_mem_36 <= hid_mem_36 - 16'sd73;
            end else begin
                hid_spikes[36] <= 1'b0;
            end
            if (hid_mem_37 >= 16'sd73) begin
                hid_spikes[37] <= 1'b1;
                hid_mem_37 <= hid_mem_37 - 16'sd73;
            end else begin
                hid_spikes[37] <= 1'b0;
            end
            if (hid_mem_38 >= 16'sd73) begin
                hid_spikes[38] <= 1'b1;
                hid_mem_38 <= hid_mem_38 - 16'sd73;
            end else begin
                hid_spikes[38] <= 1'b0;
            end
            if (hid_mem_39 >= 16'sd73) begin
                hid_spikes[39] <= 1'b1;
                hid_mem_39 <= hid_mem_39 - 16'sd73;
            end else begin
                hid_spikes[39] <= 1'b0;
            end

            // --- OUTPUT LAYER ALUs ---
            out_mem_0 <= out_mem_0 - (out_mem_0 >>> 3) + (hid_spikes[0] ? 16'sd13 : 0) + (hid_spikes[1] ? 16'sd30 : 0) + (hid_spikes[2] ? 16'sd50 : 0) + (hid_spikes[3] ? 16'sd2 : 0) + (hid_spikes[4] ? -16'sd9 : 0) + (hid_spikes[5] ? 16'sd22 : 0) + (hid_spikes[6] ? -16'sd106 : 0) + (hid_spikes[7] ? 16'sd55 : 0) + (hid_spikes[8] ? 16'sd4 : 0) + (hid_spikes[9] ? -16'sd21 : 0) + (hid_spikes[11] ? -16'sd25 : 0) + (hid_spikes[12] ? 16'sd19 : 0) + (hid_spikes[13] ? 16'sd30 : 0) + (hid_spikes[14] ? 16'sd22 : 0) + (hid_spikes[15] ? -16'sd2 : 0) + (hid_spikes[16] ? 16'sd48 : 0) + (hid_spikes[17] ? -16'sd49 : 0) + (hid_spikes[18] ? 16'sd36 : 0) + (hid_spikes[19] ? -16'sd59 : 0) + (hid_spikes[20] ? 16'sd116 : 0) + (hid_spikes[21] ? 16'sd1 : 0) + (hid_spikes[22] ? -16'sd10 : 0) + (hid_spikes[23] ? 16'sd71 : 0) + (hid_spikes[24] ? 16'sd17 : 0) + (hid_spikes[25] ? -16'sd2 : 0) + (hid_spikes[26] ? -16'sd27 : 0) + (hid_spikes[27] ? 16'sd13 : 0) + (hid_spikes[28] ? -16'sd23 : 0) + (hid_spikes[29] ? -16'sd1 : 0) + (hid_spikes[30] ? -16'sd8 : 0) + (hid_spikes[31] ? -16'sd88 : 0) + (hid_spikes[32] ? 16'sd32 : 0) + (hid_spikes[33] ? 16'sd11 : 0) + (hid_spikes[34] ? -16'sd39 : 0) + (hid_spikes[35] ? -16'sd22 : 0) + (hid_spikes[36] ? 16'sd48 : 0) + (hid_spikes[38] ? -16'sd40 : 0) + (hid_spikes[39] ? 16'sd8 : 0);
            out_mem_1 <= out_mem_1 - (out_mem_1 >>> 3) + (hid_spikes[0] ? -16'sd11 : 0) + (hid_spikes[1] ? 16'sd27 : 0) + (hid_spikes[2] ? -16'sd127 : 0) + (hid_spikes[3] ? -16'sd24 : 0) + (hid_spikes[4] ? 16'sd42 : 0) + (hid_spikes[5] ? -16'sd8 : 0) + (hid_spikes[6] ? 16'sd121 : 0) + (hid_spikes[7] ? 16'sd16 : 0) + (hid_spikes[8] ? 16'sd32 : 0) + (hid_spikes[9] ? 16'sd35 : 0) + (hid_spikes[10] ? -16'sd8 : 0) + (hid_spikes[11] ? 16'sd72 : 0) + (hid_spikes[12] ? -16'sd5 : 0) + (hid_spikes[13] ? -16'sd2 : 0) + (hid_spikes[14] ? 16'sd20 : 0) + (hid_spikes[15] ? -16'sd36 : 0) + (hid_spikes[16] ? -16'sd3 : 0) + (hid_spikes[17] ? 16'sd13 : 0) + (hid_spikes[18] ? -16'sd63 : 0) + (hid_spikes[19] ? 16'sd59 : 0) + (hid_spikes[20] ? 16'sd17 : 0) + (hid_spikes[21] ? 16'sd26 : 0) + (hid_spikes[22] ? 16'sd38 : 0) + (hid_spikes[23] ? 16'sd36 : 0) + (hid_spikes[24] ? 16'sd14 : 0) + (hid_spikes[25] ? -16'sd16 : 0) + (hid_spikes[26] ? -16'sd2 : 0) + (hid_spikes[27] ? 16'sd18 : 0) + (hid_spikes[28] ? -16'sd15 : 0) + (hid_spikes[29] ? 16'sd36 : 0) + (hid_spikes[30] ? -16'sd26 : 0) + (hid_spikes[31] ? -16'sd112 : 0) + (hid_spikes[32] ? 16'sd78 : 0) + (hid_spikes[33] ? 16'sd17 : 0) + (hid_spikes[34] ? -16'sd5 : 0) + (hid_spikes[35] ? -16'sd24 : 0) + (hid_spikes[36] ? -16'sd7 : 0) + (hid_spikes[37] ? 16'sd127 : 0) + (hid_spikes[38] ? -16'sd30 : 0) + (hid_spikes[39] ? -16'sd42 : 0);
            out_mem_2 <= out_mem_2 - (out_mem_2 >>> 3) + (hid_spikes[0] ? 16'sd60 : 0) + (hid_spikes[1] ? 16'sd54 : 0) + (hid_spikes[2] ? 16'sd17 : 0) + (hid_spikes[3] ? -16'sd123 : 0) + (hid_spikes[4] ? 16'sd31 : 0) + (hid_spikes[5] ? -16'sd113 : 0) + (hid_spikes[6] ? 16'sd127 : 0) + (hid_spikes[7] ? -16'sd43 : 0) + (hid_spikes[8] ? -16'sd38 : 0) + (hid_spikes[9] ? 16'sd27 : 0) + (hid_spikes[10] ? 16'sd23 : 0) + (hid_spikes[11] ? -16'sd19 : 0) + (hid_spikes[12] ? -16'sd3 : 0) + (hid_spikes[13] ? -16'sd12 : 0) + (hid_spikes[14] ? 16'sd7 : 0) + (hid_spikes[15] ? 16'sd18 : 0) + (hid_spikes[16] ? -16'sd16 : 0) + (hid_spikes[17] ? -16'sd21 : 0) + (hid_spikes[18] ? 16'sd18 : 0) + (hid_spikes[19] ? 16'sd104 : 0) + (hid_spikes[20] ? 16'sd40 : 0) + (hid_spikes[21] ? -16'sd25 : 0) + (hid_spikes[22] ? -16'sd20 : 0) + (hid_spikes[23] ? 16'sd54 : 0) + (hid_spikes[24] ? 16'sd38 : 0) + (hid_spikes[25] ? 16'sd52 : 0) + (hid_spikes[26] ? -16'sd72 : 0) + (hid_spikes[27] ? -16'sd15 : 0) + (hid_spikes[28] ? 16'sd5 : 0) + (hid_spikes[29] ? 16'sd15 : 0) + (hid_spikes[30] ? 16'sd4 : 0) + (hid_spikes[31] ? -16'sd1 : 0) + (hid_spikes[32] ? 16'sd47 : 0) + (hid_spikes[33] ? 16'sd2 : 0) + (hid_spikes[34] ? -16'sd34 : 0) + (hid_spikes[35] ? -16'sd15 : 0) + (hid_spikes[36] ? 16'sd106 : 0) + (hid_spikes[37] ? 16'sd45 : 0) + (hid_spikes[38] ? 16'sd4 : 0) + (hid_spikes[39] ? 16'sd13 : 0);
            out_mem_3 <= out_mem_3 - (out_mem_3 >>> 3) + (hid_spikes[0] ? -16'sd23 : 0) + (hid_spikes[1] ? 16'sd8 : 0) + (hid_spikes[2] ? -16'sd127 : 0) + (hid_spikes[3] ? -16'sd39 : 0) + (hid_spikes[4] ? 16'sd25 : 0) + (hid_spikes[5] ? 16'sd6 : 0) + (hid_spikes[6] ? -16'sd84 : 0) + (hid_spikes[7] ? -16'sd72 : 0) + (hid_spikes[8] ? 16'sd25 : 0) + (hid_spikes[9] ? -16'sd44 : 0) + (hid_spikes[10] ? -16'sd33 : 0) + (hid_spikes[11] ? 16'sd27 : 0) + (hid_spikes[12] ? 16'sd32 : 0) + (hid_spikes[13] ? -16'sd12 : 0) + (hid_spikes[14] ? -16'sd5 : 0) + (hid_spikes[15] ? -16'sd15 : 0) + (hid_spikes[16] ? -16'sd11 : 0) + (hid_spikes[17] ? 16'sd8 : 0) + (hid_spikes[18] ? 16'sd59 : 0) + (hid_spikes[19] ? 16'sd19 : 0) + (hid_spikes[20] ? 16'sd42 : 0) + (hid_spikes[21] ? -16'sd27 : 0) + (hid_spikes[22] ? -16'sd7 : 0) + (hid_spikes[23] ? 16'sd39 : 0) + (hid_spikes[24] ? 16'sd72 : 0) + (hid_spikes[25] ? -16'sd9 : 0) + (hid_spikes[26] ? -16'sd13 : 0) + (hid_spikes[27] ? 16'sd22 : 0) + (hid_spikes[28] ? -16'sd61 : 0) + (hid_spikes[29] ? 16'sd16 : 0) + (hid_spikes[30] ? 16'sd35 : 0) + (hid_spikes[31] ? -16'sd38 : 0) + (hid_spikes[32] ? 16'sd25 : 0) + (hid_spikes[33] ? 16'sd8 : 0) + (hid_spikes[34] ? 16'sd9 : 0) + (hid_spikes[35] ? 16'sd27 : 0) + (hid_spikes[36] ? -16'sd15 : 0) + (hid_spikes[37] ? -16'sd124 : 0) + (hid_spikes[38] ? 16'sd60 : 0) + (hid_spikes[39] ? 16'sd5 : 0);
            out_mem_4 <= out_mem_4 - (out_mem_4 >>> 3) + (hid_spikes[0] ? 16'sd45 : 0) + (hid_spikes[1] ? 16'sd24 : 0) + (hid_spikes[2] ? 16'sd59 : 0) + (hid_spikes[3] ? -16'sd17 : 0) + (hid_spikes[4] ? -16'sd44 : 0) + (hid_spikes[5] ? 16'sd9 : 0) + (hid_spikes[6] ? 16'sd39 : 0) + (hid_spikes[7] ? -16'sd52 : 0) + (hid_spikes[8] ? 16'sd17 : 0) + (hid_spikes[9] ? -16'sd17 : 0) + (hid_spikes[10] ? 16'sd1 : 0) + (hid_spikes[11] ? -16'sd10 : 0) + (hid_spikes[12] ? -16'sd21 : 0) + (hid_spikes[13] ? -16'sd11 : 0) + (hid_spikes[14] ? -16'sd4 : 0) + (hid_spikes[15] ? -16'sd4 : 0) + (hid_spikes[16] ? -16'sd5 : 0) + (hid_spikes[17] ? 16'sd6 : 0) + (hid_spikes[18] ? 16'sd3 : 0) + (hid_spikes[19] ? -16'sd44 : 0) + (hid_spikes[20] ? -16'sd65 : 0) + (hid_spikes[21] ? 16'sd25 : 0) + (hid_spikes[22] ? 16'sd8 : 0) + (hid_spikes[23] ? 16'sd13 : 0) + (hid_spikes[24] ? 16'sd24 : 0) + (hid_spikes[25] ? 16'sd57 : 0) + (hid_spikes[26] ? -16'sd18 : 0) + (hid_spikes[27] ? -16'sd24 : 0) + (hid_spikes[28] ? 16'sd52 : 0) + (hid_spikes[29] ? 16'sd30 : 0) + (hid_spikes[30] ? -16'sd9 : 0) + (hid_spikes[31] ? -16'sd10 : 0) + (hid_spikes[32] ? 16'sd18 : 0) + (hid_spikes[33] ? 16'sd26 : 0) + (hid_spikes[34] ? -16'sd6 : 0) + (hid_spikes[35] ? 16'sd23 : 0) + (hid_spikes[36] ? -16'sd12 : 0) + (hid_spikes[37] ? -16'sd44 : 0) + (hid_spikes[38] ? 16'sd10 : 0);
            out_mem_5 <= out_mem_5 - (out_mem_5 >>> 3) + (hid_spikes[0] ? -16'sd14 : 0) + (hid_spikes[1] ? 16'sd32 : 0) + (hid_spikes[2] ? 16'sd26 : 0) + (hid_spikes[3] ? -16'sd13 : 0) + (hid_spikes[4] ? 16'sd14 : 0) + (hid_spikes[5] ? -16'sd1 : 0) + (hid_spikes[6] ? 16'sd127 : 0) + (hid_spikes[7] ? -16'sd25 : 0) + (hid_spikes[8] ? 16'sd17 : 0) + (hid_spikes[9] ? -16'sd3 : 0) + (hid_spikes[10] ? -16'sd5 : 0) + (hid_spikes[12] ? -16'sd38 : 0) + (hid_spikes[14] ? 16'sd34 : 0) + (hid_spikes[15] ? -16'sd1 : 0) + (hid_spikes[16] ? -16'sd12 : 0) + (hid_spikes[17] ? 16'sd47 : 0) + (hid_spikes[18] ? -16'sd14 : 0) + (hid_spikes[19] ? -16'sd10 : 0) + (hid_spikes[20] ? 16'sd9 : 0) + (hid_spikes[21] ? -16'sd28 : 0) + (hid_spikes[22] ? 16'sd36 : 0) + (hid_spikes[23] ? -16'sd16 : 0) + (hid_spikes[24] ? -16'sd2 : 0) + (hid_spikes[25] ? 16'sd22 : 0) + (hid_spikes[26] ? -16'sd17 : 0) + (hid_spikes[27] ? 16'sd1 : 0) + (hid_spikes[28] ? -16'sd3 : 0) + (hid_spikes[29] ? 16'sd3 : 0) + (hid_spikes[30] ? -16'sd10 : 0) + (hid_spikes[31] ? 16'sd11 : 0) + (hid_spikes[32] ? -16'sd6 : 0) + (hid_spikes[33] ? 16'sd8 : 0) + (hid_spikes[34] ? 16'sd1 : 0) + (hid_spikes[35] ? 16'sd16 : 0) + (hid_spikes[36] ? 16'sd40 : 0) + (hid_spikes[37] ? 16'sd30 : 0) + (hid_spikes[38] ? -16'sd2 : 0) + (hid_spikes[39] ? 16'sd2 : 0);

            // Output Spiking Logic
            if (out_mem_0 >= 16'sd100) begin
                out_spikes[0] <= 1'b1;
                out_mem_0 <= out_mem_0 - 16'sd100;
            end else begin
                out_spikes[0] <= 1'b0;
            end
            if (out_mem_1 >= 16'sd100) begin
                out_spikes[1] <= 1'b1;
                out_mem_1 <= out_mem_1 - 16'sd100;
            end else begin
                out_spikes[1] <= 1'b0;
            end
            if (out_mem_2 >= 16'sd100) begin
                out_spikes[2] <= 1'b1;
                out_mem_2 <= out_mem_2 - 16'sd100;
            end else begin
                out_spikes[2] <= 1'b0;
            end
            if (out_mem_3 >= 16'sd100) begin
                out_spikes[3] <= 1'b1;
                out_mem_3 <= out_mem_3 - 16'sd100;
            end else begin
                out_spikes[3] <= 1'b0;
            end
            if (out_mem_4 >= 16'sd100) begin
                out_spikes[4] <= 1'b1;
                out_mem_4 <= out_mem_4 - 16'sd100;
            end else begin
                out_spikes[4] <= 1'b0;
            end
            if (out_mem_5 >= 16'sd100) begin
                out_spikes[5] <= 1'b1;
                out_mem_5 <= out_mem_5 - 16'sd100;
            end else begin
                out_spikes[5] <= 1'b0;
            end
        end
    end
endmodule
