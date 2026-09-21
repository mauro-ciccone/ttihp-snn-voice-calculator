`default_nettype none
module snn_core (
    input  wire       clk_1mhz,
    input  wire       rst_n,
    input  wire       tick_1ms,
    input  wire [5:0] cochlea_spikes,
    output wire [5:0] base_spikes // Directly exporting the 6 classes
);

    // ==========================================
    // HIDDEN LAYER (OR-Gate Bitwise Synthesis)
    // ==========================================
    wire [79:0] hid_spikes;

    reg signed [11:0] mem_hid_0;
    wire signed [11:0] pos_in_hid_0 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[3]) << 2
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[4] | cochlea_spikes[5]) << 1
        + (cochlea_spikes[4]) << 3
        + (hid_spikes[9] | hid_spikes[12] | hid_spikes[20] | hid_spikes[22] | hid_spikes[26] | hid_spikes[39] | hid_spikes[42] | hid_spikes[46] | hid_spikes[56] | hid_spikes[71]) << 0
        + (hid_spikes[9] | hid_spikes[26] | hid_spikes[39] | hid_spikes[42] | hid_spikes[67] | hid_spikes[71]) << 1
        + (hid_spikes[6] | hid_spikes[12] | hid_spikes[22] | hid_spikes[37] | hid_spikes[42] | hid_spikes[46]) << 2
        + (hid_spikes[7] | hid_spikes[20] | hid_spikes[56]) << 3;
    wire signed [11:0] neg_in_hid_0 = (cochlea_spikes[2]) << 2
        + (cochlea_spikes[2]) << 5
        + (cochlea_spikes[0]) << 3
        + (hid_spikes[2] | hid_spikes[3] | hid_spikes[8] | hid_spikes[10] | hid_spikes[11] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[25] | hid_spikes[29] | hid_spikes[31] | hid_spikes[32] | hid_spikes[34] | hid_spikes[35] | hid_spikes[36] | hid_spikes[38] | hid_spikes[41] | hid_spikes[44] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[52] | hid_spikes[53] | hid_spikes[60] | hid_spikes[63] | hid_spikes[65] | hid_spikes[68] | hid_spikes[69] | hid_spikes[70] | hid_spikes[73] | hid_spikes[76]) << 0
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[8] | hid_spikes[14] | hid_spikes[23] | hid_spikes[28] | hid_spikes[33] | hid_spikes[34] | hid_spikes[47] | hid_spikes[48] | hid_spikes[52] | hid_spikes[54] | hid_spikes[55] | hid_spikes[58] | hid_spikes[64] | hid_spikes[68] | hid_spikes[72] | hid_spikes[73] | hid_spikes[74] | hid_spikes[75]) << 1
        + (hid_spikes[2] | hid_spikes[4] | hid_spikes[5] | hid_spikes[8] | hid_spikes[13] | hid_spikes[14] | hid_spikes[18] | hid_spikes[25] | hid_spikes[27] | hid_spikes[32] | hid_spikes[33] | hid_spikes[35] | hid_spikes[36] | hid_spikes[38] | hid_spikes[41] | hid_spikes[49] | hid_spikes[51] | hid_spikes[52] | hid_spikes[53] | hid_spikes[54] | hid_spikes[59] | hid_spikes[60] | hid_spikes[69] | hid_spikes[70] | hid_spikes[73] | hid_spikes[74] | hid_spikes[76] | hid_spikes[79]) << 2
        + (hid_spikes[10] | hid_spikes[11] | hid_spikes[15] | hid_spikes[16] | hid_spikes[18] | hid_spikes[29] | hid_spikes[31] | hid_spikes[32] | hid_spikes[36] | hid_spikes[40] | hid_spikes[44] | hid_spikes[50] | hid_spikes[57] | hid_spikes[63] | hid_spikes[73] | hid_spikes[74] | hid_spikes[75]) << 3
        + (hid_spikes[19] | hid_spikes[28] | hid_spikes[41] | hid_spikes[47] | hid_spikes[55] | hid_spikes[57] | hid_spikes[68] | hid_spikes[75] | hid_spikes[76]) << 4
        + (hid_spikes[64] | hid_spikes[65]) << 5;
    wire signed [11:0] sum_hid_0 = pos_in_hid_0 - neg_in_hid_0;
    assign hid_spikes[0] = (mem_hid_0 >= 10);
    wire signed [11:0] next_hid_0 = mem_hid_0 - (mem_hid_0 >>> 6) + sum_hid_0;

    reg signed [11:0] mem_hid_1;
    wire signed [11:0] pos_in_hid_1 = (hid_spikes[0] | hid_spikes[2] | hid_spikes[14] | hid_spikes[28] | hid_spikes[38] | hid_spikes[44] | hid_spikes[46] | hid_spikes[49] | hid_spikes[51] | hid_spikes[56] | hid_spikes[59] | hid_spikes[66] | hid_spikes[70] | hid_spikes[76] | hid_spikes[77] | hid_spikes[79]) << 0
        + (hid_spikes[15] | hid_spikes[22] | hid_spikes[28] | hid_spikes[38] | hid_spikes[46] | hid_spikes[49] | hid_spikes[56] | hid_spikes[59] | hid_spikes[66] | hid_spikes[69] | hid_spikes[76] | hid_spikes[77] | hid_spikes[79]) << 1
        + (hid_spikes[12] | hid_spikes[15] | hid_spikes[16] | hid_spikes[22] | hid_spikes[26] | hid_spikes[30] | hid_spikes[31] | hid_spikes[34] | hid_spikes[45] | hid_spikes[49] | hid_spikes[56] | hid_spikes[59] | hid_spikes[77]) << 2
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[14] | hid_spikes[15] | hid_spikes[27] | hid_spikes[44] | hid_spikes[46] | hid_spikes[51] | hid_spikes[62] | hid_spikes[69] | hid_spikes[70] | hid_spikes[78]) << 3
        + (hid_spikes[19]) << 4;
    wire signed [11:0] neg_in_hid_1 = (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0] | cochlea_spikes[2]) << 1
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[2]) << 4
        + (cochlea_spikes[3] | cochlea_spikes[5]) << 0
        + (cochlea_spikes[3] | cochlea_spikes[5]) << 1
        + (cochlea_spikes[3]) << 2
        + (cochlea_spikes[3]) << 3
        + (hid_spikes[5] | hid_spikes[20] | hid_spikes[21] | hid_spikes[25] | hid_spikes[29] | hid_spikes[42] | hid_spikes[48] | hid_spikes[55] | hid_spikes[57] | hid_spikes[61] | hid_spikes[63] | hid_spikes[64] | hid_spikes[67] | hid_spikes[73]) << 0
        + (hid_spikes[6] | hid_spikes[7] | hid_spikes[9] | hid_spikes[13] | hid_spikes[20] | hid_spikes[21] | hid_spikes[39] | hid_spikes[41] | hid_spikes[43] | hid_spikes[48] | hid_spikes[50] | hid_spikes[53] | hid_spikes[55] | hid_spikes[57] | hid_spikes[58] | hid_spikes[61] | hid_spikes[63] | hid_spikes[64] | hid_spikes[68] | hid_spikes[73]) << 1
        + (hid_spikes[5] | hid_spikes[7] | hid_spikes[9] | hid_spikes[20] | hid_spikes[29] | hid_spikes[36] | hid_spikes[39] | hid_spikes[42] | hid_spikes[50] | hid_spikes[53] | hid_spikes[55] | hid_spikes[57] | hid_spikes[58] | hid_spikes[61] | hid_spikes[65] | hid_spikes[68] | hid_spikes[73]) << 2
        + (hid_spikes[3] | hid_spikes[11] | hid_spikes[13] | hid_spikes[18] | hid_spikes[21] | hid_spikes[24] | hid_spikes[25] | hid_spikes[33] | hid_spikes[40] | hid_spikes[41] | hid_spikes[42] | hid_spikes[61] | hid_spikes[64] | hid_spikes[67] | hid_spikes[71] | hid_spikes[75]) << 3;
    wire signed [11:0] sum_hid_1 = pos_in_hid_1 - neg_in_hid_1;
    assign hid_spikes[1] = (mem_hid_1 >= 10);
    wire signed [11:0] next_hid_1 = mem_hid_1 - (mem_hid_1 >>> 6) + sum_hid_1;

    reg signed [11:0] mem_hid_2;
    wire signed [11:0] pos_in_hid_2 = (cochlea_spikes[5]) << 1
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[5]) << 3
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 2
        + (hid_spikes[8] | hid_spikes[18] | hid_spikes[23] | hid_spikes[31] | hid_spikes[32] | hid_spikes[36] | hid_spikes[37] | hid_spikes[45] | hid_spikes[52] | hid_spikes[65] | hid_spikes[68] | hid_spikes[70] | hid_spikes[74] | hid_spikes[76] | hid_spikes[79]) << 0
        + (hid_spikes[1] | hid_spikes[3] | hid_spikes[4] | hid_spikes[19] | hid_spikes[29] | hid_spikes[31] | hid_spikes[32] | hid_spikes[36] | hid_spikes[45] | hid_spikes[46] | hid_spikes[50] | hid_spikes[52] | hid_spikes[56] | hid_spikes[59] | hid_spikes[65] | hid_spikes[68] | hid_spikes[69] | hid_spikes[70] | hid_spikes[72] | hid_spikes[79]) << 1
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[3] | hid_spikes[4] | hid_spikes[10] | hid_spikes[23] | hid_spikes[30] | hid_spikes[34] | hid_spikes[36] | hid_spikes[37] | hid_spikes[50] | hid_spikes[56] | hid_spikes[62] | hid_spikes[68] | hid_spikes[69] | hid_spikes[70] | hid_spikes[72] | hid_spikes[74] | hid_spikes[76]) << 2
        + (hid_spikes[8] | hid_spikes[18] | hid_spikes[19] | hid_spikes[37] | hid_spikes[55] | hid_spikes[60]) << 3;
    wire signed [11:0] neg_in_hid_2 = (cochlea_spikes[1] | cochlea_spikes[3]) << 0
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[1] | cochlea_spikes[3]) << 3
        + (cochlea_spikes[3]) << 4
        + (cochlea_spikes[0] | cochlea_spikes[2]) << 0
        + (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0] | cochlea_spikes[2]) << 2
        + (cochlea_spikes[0] | cochlea_spikes[2]) << 3
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[9] | hid_spikes[11] | hid_spikes[14] | hid_spikes[17] | hid_spikes[21] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[28] | hid_spikes[43] | hid_spikes[53] | hid_spikes[54] | hid_spikes[58] | hid_spikes[61] | hid_spikes[67] | hid_spikes[71] | hid_spikes[78]) << 0
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[7] | hid_spikes[9] | hid_spikes[11] | hid_spikes[21] | hid_spikes[28] | hid_spikes[33] | hid_spikes[38] | hid_spikes[39] | hid_spikes[43] | hid_spikes[44] | hid_spikes[54] | hid_spikes[58] | hid_spikes[61] | hid_spikes[64] | hid_spikes[67] | hid_spikes[71] | hid_spikes[75]) << 1
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[7] | hid_spikes[9] | hid_spikes[14] | hid_spikes[17] | hid_spikes[20] | hid_spikes[21] | hid_spikes[24] | hid_spikes[25] | hid_spikes[33] | hid_spikes[40] | hid_spikes[43] | hid_spikes[54] | hid_spikes[57] | hid_spikes[58] | hid_spikes[71] | hid_spikes[75]) << 2
        + (hid_spikes[13] | hid_spikes[17] | hid_spikes[20] | hid_spikes[25] | hid_spikes[39] | hid_spikes[53] | hid_spikes[64] | hid_spikes[67] | hid_spikes[78]) << 3
        + (hid_spikes[21] | hid_spikes[26] | hid_spikes[28] | hid_spikes[38] | hid_spikes[42] | hid_spikes[77]) << 4;
    wire signed [11:0] sum_hid_2 = pos_in_hid_2 - neg_in_hid_2;
    assign hid_spikes[2] = (mem_hid_2 >= 10);
    wire signed [11:0] next_hid_2 = mem_hid_2 - (mem_hid_2 >>> 3) + sum_hid_2;

    reg signed [11:0] mem_hid_3;
    wire signed [11:0] pos_in_hid_3 = (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[1]) << 2
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[8] | hid_spikes[16] | hid_spikes[18] | hid_spikes[44] | hid_spikes[47] | hid_spikes[55] | hid_spikes[59] | hid_spikes[62] | hid_spikes[68] | hid_spikes[79]) << 0
        + (hid_spikes[1] | hid_spikes[13] | hid_spikes[14] | hid_spikes[16] | hid_spikes[18] | hid_spikes[44] | hid_spikes[47] | hid_spikes[55] | hid_spikes[59] | hid_spikes[66] | hid_spikes[68] | hid_spikes[79]) << 1
        + (hid_spikes[0] | hid_spikes[8] | hid_spikes[12] | hid_spikes[13] | hid_spikes[16] | hid_spikes[59] | hid_spikes[62] | hid_spikes[70]) << 2
        + (hid_spikes[0] | hid_spikes[34] | hid_spikes[40] | hid_spikes[55] | hid_spikes[62] | hid_spikes[72] | hid_spikes[79]) << 3;
    wire signed [11:0] neg_in_hid_3 = (cochlea_spikes[3]) << 1
        + (cochlea_spikes[3]) << 2
        + (cochlea_spikes[3]) << 4
        + (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 2
        + (hid_spikes[5] | hid_spikes[7] | hid_spikes[20] | hid_spikes[23] | hid_spikes[27] | hid_spikes[50] | hid_spikes[51] | hid_spikes[54] | hid_spikes[63] | hid_spikes[65] | hid_spikes[78]) << 0
        + (hid_spikes[7] | hid_spikes[20] | hid_spikes[27] | hid_spikes[28] | hid_spikes[29] | hid_spikes[35] | hid_spikes[37] | hid_spikes[43] | hid_spikes[51] | hid_spikes[63] | hid_spikes[65] | hid_spikes[77] | hid_spikes[78]) << 1
        + (hid_spikes[5] | hid_spikes[9] | hid_spikes[11] | hid_spikes[21] | hid_spikes[33] | hid_spikes[39] | hid_spikes[41] | hid_spikes[46] | hid_spikes[48] | hid_spikes[50] | hid_spikes[53] | hid_spikes[54] | hid_spikes[65] | hid_spikes[67] | hid_spikes[73] | hid_spikes[77]) << 2
        + (hid_spikes[11] | hid_spikes[17] | hid_spikes[20] | hid_spikes[23] | hid_spikes[43] | hid_spikes[63] | hid_spikes[74]) << 3
        + (hid_spikes[26] | hid_spikes[38]) << 4;
    wire signed [11:0] sum_hid_3 = pos_in_hid_3 - neg_in_hid_3;
    assign hid_spikes[3] = (mem_hid_3 >= 10);
    wire signed [11:0] next_hid_3 = mem_hid_3 - (mem_hid_3 >>> 6) + sum_hid_3;

    reg signed [11:0] mem_hid_4;
    wire signed [11:0] pos_in_hid_4 = (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 3
        + (hid_spikes[2] | hid_spikes[28] | hid_spikes[30] | hid_spikes[47] | hid_spikes[55] | hid_spikes[60] | hid_spikes[74]) << 0
        + (hid_spikes[2] | hid_spikes[28] | hid_spikes[47] | hid_spikes[54] | hid_spikes[59] | hid_spikes[73]) << 1
        + (hid_spikes[0] | hid_spikes[23] | hid_spikes[30] | hid_spikes[54] | hid_spikes[60] | hid_spikes[75]) << 2
        + (hid_spikes[0] | hid_spikes[28] | hid_spikes[47] | hid_spikes[55] | hid_spikes[60] | hid_spikes[74]) << 3;
    wire signed [11:0] neg_in_hid_4 = (cochlea_spikes[2]) << 2
        + (cochlea_spikes[2]) << 4
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[5]) << 3
        + (hid_spikes[1] | hid_spikes[19] | hid_spikes[26] | hid_spikes[31] | hid_spikes[36] | hid_spikes[38] | hid_spikes[39] | hid_spikes[40] | hid_spikes[45] | hid_spikes[46] | hid_spikes[52] | hid_spikes[53] | hid_spikes[56] | hid_spikes[58] | hid_spikes[61] | hid_spikes[65] | hid_spikes[78]) << 0
        + (hid_spikes[3] | hid_spikes[6] | hid_spikes[15] | hid_spikes[17] | hid_spikes[19] | hid_spikes[31] | hid_spikes[35] | hid_spikes[36] | hid_spikes[39] | hid_spikes[45] | hid_spikes[46] | hid_spikes[49] | hid_spikes[52] | hid_spikes[53] | hid_spikes[58] | hid_spikes[64] | hid_spikes[65] | hid_spikes[66] | hid_spikes[71] | hid_spikes[78]) << 1
        + (hid_spikes[1] | hid_spikes[4] | hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[9] | hid_spikes[14] | hid_spikes[17] | hid_spikes[19] | hid_spikes[26] | hid_spikes[35] | hid_spikes[38] | hid_spikes[39] | hid_spikes[40] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[49] | hid_spikes[58] | hid_spikes[61] | hid_spikes[63] | hid_spikes[65] | hid_spikes[70]) << 2
        + (hid_spikes[11] | hid_spikes[15] | hid_spikes[24] | hid_spikes[26] | hid_spikes[27] | hid_spikes[38] | hid_spikes[43] | hid_spikes[46] | hid_spikes[56] | hid_spikes[57] | hid_spikes[58] | hid_spikes[61] | hid_spikes[70] | hid_spikes[77]) << 3
        + (hid_spikes[14] | hid_spikes[20] | hid_spikes[26] | hid_spikes[35] | hid_spikes[48] | hid_spikes[67] | hid_spikes[71]) << 4;
    wire signed [11:0] sum_hid_4 = pos_in_hid_4 - neg_in_hid_4;
    assign hid_spikes[4] = (mem_hid_4 >= 10);
    wire signed [11:0] next_hid_4 = mem_hid_4 - (mem_hid_4 >>> 3) + sum_hid_4;

    reg signed [11:0] mem_hid_5;
    wire signed [11:0] pos_in_hid_5 = (cochlea_spikes[2]) << 3
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (hid_spikes[7] | hid_spikes[10] | hid_spikes[12] | hid_spikes[20] | hid_spikes[22] | hid_spikes[26] | hid_spikes[31] | hid_spikes[33] | hid_spikes[41] | hid_spikes[50] | hid_spikes[53] | hid_spikes[57] | hid_spikes[63] | hid_spikes[68] | hid_spikes[69] | hid_spikes[72] | hid_spikes[76]) << 0
        + (hid_spikes[7] | hid_spikes[10] | hid_spikes[18] | hid_spikes[20] | hid_spikes[22] | hid_spikes[31] | hid_spikes[41] | hid_spikes[53] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63] | hid_spikes[72] | hid_spikes[76]) << 1
        + (hid_spikes[10] | hid_spikes[12] | hid_spikes[16] | hid_spikes[26] | hid_spikes[50] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60] | hid_spikes[62] | hid_spikes[68] | hid_spikes[70]) << 2
        + (hid_spikes[19] | hid_spikes[20] | hid_spikes[33] | hid_spikes[69]) << 3;
    wire signed [11:0] neg_in_hid_5 = (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[1]) << 2
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[3] | hid_spikes[4] | hid_spikes[5] | hid_spikes[8] | hid_spikes[11] | hid_spikes[14] | hid_spikes[23] | hid_spikes[32] | hid_spikes[36] | hid_spikes[37] | hid_spikes[40] | hid_spikes[51] | hid_spikes[52] | hid_spikes[54] | hid_spikes[55] | hid_spikes[56] | hid_spikes[66] | hid_spikes[67] | hid_spikes[73] | hid_spikes[74] | hid_spikes[77]) << 0
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[5] | hid_spikes[8] | hid_spikes[9] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[21] | hid_spikes[23] | hid_spikes[30] | hid_spikes[37] | hid_spikes[38] | hid_spikes[39] | hid_spikes[40] | hid_spikes[45] | hid_spikes[47] | hid_spikes[52] | hid_spikes[56] | hid_spikes[59] | hid_spikes[65] | hid_spikes[66] | hid_spikes[67] | hid_spikes[77]) << 1
        + (hid_spikes[1] | hid_spikes[4] | hid_spikes[5] | hid_spikes[14] | hid_spikes[24] | hid_spikes[32] | hid_spikes[37] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[47] | hid_spikes[51] | hid_spikes[56] | hid_spikes[59] | hid_spikes[65] | hid_spikes[66] | hid_spikes[75]) << 2
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[6] | hid_spikes[11] | hid_spikes[13] | hid_spikes[30] | hid_spikes[36] | hid_spikes[38] | hid_spikes[39] | hid_spikes[46] | hid_spikes[54] | hid_spikes[55] | hid_spikes[65] | hid_spikes[66] | hid_spikes[73] | hid_spikes[74] | hid_spikes[78]) << 3
        + (hid_spikes[9] | hid_spikes[11] | hid_spikes[30] | hid_spikes[37] | hid_spikes[46] | hid_spikes[54] | hid_spikes[56]) << 4;
    wire signed [11:0] sum_hid_5 = pos_in_hid_5 - neg_in_hid_5;
    assign hid_spikes[5] = (mem_hid_5 >= 10);
    wire signed [11:0] next_hid_5 = mem_hid_5 - (mem_hid_5 >>> 6) + sum_hid_5;

    reg signed [11:0] mem_hid_6;
    wire signed [11:0] pos_in_hid_6 = (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 2
        + (hid_spikes[13] | hid_spikes[22] | hid_spikes[39] | hid_spikes[71]) << 0
        + (hid_spikes[22] | hid_spikes[27] | hid_spikes[39] | hid_spikes[45] | hid_spikes[76]) << 1
        + (hid_spikes[21] | hid_spikes[27] | hid_spikes[39] | hid_spikes[45] | hid_spikes[55] | hid_spikes[71]) << 2
        + (hid_spikes[13] | hid_spikes[17] | hid_spikes[22]) << 3;
    wire signed [11:0] neg_in_hid_6 = (cochlea_spikes[2]) << 2
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (hid_spikes[0] | hid_spikes[4] | hid_spikes[9] | hid_spikes[15] | hid_spikes[18] | hid_spikes[19] | hid_spikes[24] | hid_spikes[28] | hid_spikes[30] | hid_spikes[35] | hid_spikes[36] | hid_spikes[40] | hid_spikes[42] | hid_spikes[44] | hid_spikes[47] | hid_spikes[50] | hid_spikes[52] | hid_spikes[54] | hid_spikes[59] | hid_spikes[63] | hid_spikes[65] | hid_spikes[67] | hid_spikes[68]) << 0
        + (hid_spikes[2] | hid_spikes[3] | hid_spikes[6] | hid_spikes[8] | hid_spikes[11] | hid_spikes[15] | hid_spikes[24] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[32] | hid_spikes[35] | hid_spikes[36] | hid_spikes[40] | hid_spikes[41] | hid_spikes[42] | hid_spikes[44] | hid_spikes[46] | hid_spikes[47] | hid_spikes[48] | hid_spikes[50] | hid_spikes[51] | hid_spikes[52] | hid_spikes[58] | hid_spikes[59] | hid_spikes[61] | hid_spikes[63] | hid_spikes[68] | hid_spikes[69] | hid_spikes[72] | hid_spikes[74]) << 1
        + (hid_spikes[0] | hid_spikes[4] | hid_spikes[8] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[31] | hid_spikes[32] | hid_spikes[33] | hid_spikes[35] | hid_spikes[41] | hid_spikes[42] | hid_spikes[43] | hid_spikes[47] | hid_spikes[52] | hid_spikes[58] | hid_spikes[62] | hid_spikes[63] | hid_spikes[65] | hid_spikes[66] | hid_spikes[67] | hid_spikes[68] | hid_spikes[69] | hid_spikes[73] | hid_spikes[74] | hid_spikes[75] | hid_spikes[79]) << 2
        + (hid_spikes[2] | hid_spikes[9] | hid_spikes[10] | hid_spikes[23] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[36] | hid_spikes[38] | hid_spikes[42] | hid_spikes[47] | hid_spikes[53] | hid_spikes[54] | hid_spikes[59] | hid_spikes[65] | hid_spikes[67] | hid_spikes[68] | hid_spikes[69] | hid_spikes[70] | hid_spikes[73] | hid_spikes[74] | hid_spikes[77] | hid_spikes[78] | hid_spikes[79]) << 3
        + (hid_spikes[3] | hid_spikes[18] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[46] | hid_spikes[50] | hid_spikes[56] | hid_spikes[66]) << 4;
    wire signed [11:0] sum_hid_6 = pos_in_hid_6 - neg_in_hid_6;
    assign hid_spikes[6] = (mem_hid_6 >= 10);
    wire signed [11:0] next_hid_6 = mem_hid_6 - (mem_hid_6 >>> 6) + sum_hid_6;

    reg signed [11:0] mem_hid_7;
    wire signed [11:0] pos_in_hid_7 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 4
        + (hid_spikes[2] | hid_spikes[14] | hid_spikes[18] | hid_spikes[21] | hid_spikes[22] | hid_spikes[32] | hid_spikes[39] | hid_spikes[48] | hid_spikes[64]) << 0
        + (hid_spikes[18] | hid_spikes[19] | hid_spikes[21] | hid_spikes[22] | hid_spikes[26] | hid_spikes[32] | hid_spikes[36] | hid_spikes[39] | hid_spikes[40] | hid_spikes[48] | hid_spikes[51] | hid_spikes[62] | hid_spikes[76]) << 1
        + (hid_spikes[2] | hid_spikes[4] | hid_spikes[6] | hid_spikes[12] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[18] | hid_spikes[21] | hid_spikes[22] | hid_spikes[25] | hid_spikes[26] | hid_spikes[36] | hid_spikes[37] | hid_spikes[59] | hid_spikes[60]) << 2
        + (hid_spikes[15] | hid_spikes[57]) << 3
        + (hid_spikes[0] | hid_spikes[64]) << 4;
    wire signed [11:0] neg_in_hid_7 = (cochlea_spikes[3]) << 0
        + (cochlea_spikes[0] | cochlea_spikes[3]) << 1
        + (cochlea_spikes[0] | cochlea_spikes[3]) << 2
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[5]) << 3
        + (hid_spikes[8] | hid_spikes[10] | hid_spikes[30] | hid_spikes[38] | hid_spikes[43] | hid_spikes[45] | hid_spikes[47] | hid_spikes[54] | hid_spikes[63] | hid_spikes[65] | hid_spikes[67] | hid_spikes[71] | hid_spikes[73] | hid_spikes[74] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 0
        + (hid_spikes[9] | hid_spikes[11] | hid_spikes[17] | hid_spikes[43] | hid_spikes[45] | hid_spikes[47] | hid_spikes[54] | hid_spikes[61] | hid_spikes[63] | hid_spikes[67] | hid_spikes[71] | hid_spikes[73] | hid_spikes[74] | hid_spikes[79]) << 1
        + (hid_spikes[7] | hid_spikes[8] | hid_spikes[10] | hid_spikes[11] | hid_spikes[17] | hid_spikes[30] | hid_spikes[43] | hid_spikes[47] | hid_spikes[49] | hid_spikes[58] | hid_spikes[61] | hid_spikes[69] | hid_spikes[70] | hid_spikes[72] | hid_spikes[74] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 2
        + (hid_spikes[63] | hid_spikes[65] | hid_spikes[73]) << 3
        + (hid_spikes[38] | hid_spikes[77]) << 4;
    wire signed [11:0] sum_hid_7 = pos_in_hid_7 - neg_in_hid_7;
    assign hid_spikes[7] = (mem_hid_7 >= 10);
    wire signed [11:0] next_hid_7 = mem_hid_7 - (mem_hid_7 >>> 6) + sum_hid_7;

    reg signed [11:0] mem_hid_8;
    wire signed [11:0] pos_in_hid_8 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[5]) << 3
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[32] | hid_spikes[40] | hid_spikes[49] | hid_spikes[52] | hid_spikes[56] | hid_spikes[74] | hid_spikes[79]) << 0
        + (hid_spikes[2] | hid_spikes[9] | hid_spikes[18] | hid_spikes[25] | hid_spikes[34] | hid_spikes[40] | hid_spikes[45] | hid_spikes[49] | hid_spikes[52] | hid_spikes[53] | hid_spikes[56] | hid_spikes[74]) << 1
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[2] | hid_spikes[9] | hid_spikes[18] | hid_spikes[20] | hid_spikes[32] | hid_spikes[34] | hid_spikes[65] | hid_spikes[70] | hid_spikes[79]) << 2
        + (hid_spikes[20] | hid_spikes[23] | hid_spikes[40] | hid_spikes[45] | hid_spikes[52] | hid_spikes[53]) << 3;
    wire signed [11:0] neg_in_hid_8 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[2]) << 3
        + (cochlea_spikes[3]) << 2
        + (cochlea_spikes[3]) << 3
        + (hid_spikes[3] | hid_spikes[4] | hid_spikes[6] | hid_spikes[14] | hid_spikes[19] | hid_spikes[22] | hid_spikes[26] | hid_spikes[28] | hid_spikes[30] | hid_spikes[31] | hid_spikes[39] | hid_spikes[43] | hid_spikes[47] | hid_spikes[48] | hid_spikes[50] | hid_spikes[55] | hid_spikes[59] | hid_spikes[62] | hid_spikes[67] | hid_spikes[68] | hid_spikes[71] | hid_spikes[73] | hid_spikes[77]) << 0
        + (hid_spikes[4] | hid_spikes[6] | hid_spikes[13] | hid_spikes[14] | hid_spikes[16] | hid_spikes[22] | hid_spikes[30] | hid_spikes[31] | hid_spikes[39] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[48] | hid_spikes[50] | hid_spikes[55] | hid_spikes[57] | hid_spikes[60] | hid_spikes[62] | hid_spikes[64] | hid_spikes[67] | hid_spikes[69] | hid_spikes[71] | hid_spikes[73] | hid_spikes[76]) << 1
        + (hid_spikes[3] | hid_spikes[4] | hid_spikes[13] | hid_spikes[16] | hid_spikes[19] | hid_spikes[24] | hid_spikes[26] | hid_spikes[28] | hid_spikes[31] | hid_spikes[36] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[47] | hid_spikes[59] | hid_spikes[62] | hid_spikes[63] | hid_spikes[69] | hid_spikes[75] | hid_spikes[76] | hid_spikes[77]) << 2
        + (hid_spikes[5] | hid_spikes[21] | hid_spikes[27] | hid_spikes[28] | hid_spikes[33] | hid_spikes[39] | hid_spikes[50] | hid_spikes[57] | hid_spikes[67] | hid_spikes[68] | hid_spikes[75]) << 3;
    wire signed [11:0] sum_hid_8 = pos_in_hid_8 - neg_in_hid_8;
    assign hid_spikes[8] = (mem_hid_8 >= 10);
    wire signed [11:0] next_hid_8 = mem_hid_8 - (mem_hid_8 >>> 3) + sum_hid_8;

    reg signed [11:0] mem_hid_9;
    wire signed [11:0] pos_in_hid_9 = (hid_spikes[6] | hid_spikes[8] | hid_spikes[16] | hid_spikes[59] | hid_spikes[69] | hid_spikes[70] | hid_spikes[76] | hid_spikes[79]) << 0
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[6] | hid_spikes[11] | hid_spikes[47] | hid_spikes[55] | hid_spikes[59] | hid_spikes[63] | hid_spikes[69] | hid_spikes[70] | hid_spikes[76] | hid_spikes[79]) << 1
        + (hid_spikes[2] | hid_spikes[8] | hid_spikes[13] | hid_spikes[16] | hid_spikes[17] | hid_spikes[47] | hid_spikes[55] | hid_spikes[69] | hid_spikes[72]) << 2
        + (hid_spikes[47]) << 3;
    wire signed [11:0] neg_in_hid_9 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (hid_spikes[3] | hid_spikes[9] | hid_spikes[18] | hid_spikes[19] | hid_spikes[23] | hid_spikes[24] | hid_spikes[29] | hid_spikes[30] | hid_spikes[37] | hid_spikes[42] | hid_spikes[49] | hid_spikes[54] | hid_spikes[62] | hid_spikes[66] | hid_spikes[68] | hid_spikes[71] | hid_spikes[78]) << 0
        + (hid_spikes[10] | hid_spikes[19] | hid_spikes[22] | hid_spikes[24] | hid_spikes[26] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[32] | hid_spikes[42] | hid_spikes[49] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[66] | hid_spikes[71] | hid_spikes[73] | hid_spikes[77]) << 1
        + (hid_spikes[3] | hid_spikes[12] | hid_spikes[14] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[32] | hid_spikes[36] | hid_spikes[37] | hid_spikes[42] | hid_spikes[49] | hid_spikes[62] | hid_spikes[64] | hid_spikes[74] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 2
        + (hid_spikes[9] | hid_spikes[23] | hid_spikes[29] | hid_spikes[32] | hid_spikes[34] | hid_spikes[50] | hid_spikes[54] | hid_spikes[68] | hid_spikes[73]) << 3
        + (hid_spikes[18] | hid_spikes[28] | hid_spikes[54] | hid_spikes[78]) << 4;
    wire signed [11:0] sum_hid_9 = pos_in_hid_9 - neg_in_hid_9;
    assign hid_spikes[9] = (mem_hid_9 >= 10);
    wire signed [11:0] next_hid_9 = mem_hid_9 - (mem_hid_9 >>> 4) + sum_hid_9;

    reg signed [11:0] mem_hid_10;
    wire signed [11:0] pos_in_hid_10 = (cochlea_spikes[1] | cochlea_spikes[2]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[2]) << 3
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[4] | cochlea_spikes[5]) << 1
        + (cochlea_spikes[4]) << 2
        + (hid_spikes[6] | hid_spikes[21] | hid_spikes[25] | hid_spikes[33] | hid_spikes[34] | hid_spikes[36] | hid_spikes[40] | hid_spikes[42] | hid_spikes[46] | hid_spikes[53] | hid_spikes[56] | hid_spikes[57] | hid_spikes[59] | hid_spikes[72] | hid_spikes[76] | hid_spikes[78] | hid_spikes[79]) << 0
        + (hid_spikes[6] | hid_spikes[25] | hid_spikes[33] | hid_spikes[36] | hid_spikes[40] | hid_spikes[42] | hid_spikes[53] | hid_spikes[56] | hid_spikes[63] | hid_spikes[66] | hid_spikes[71] | hid_spikes[72] | hid_spikes[79]) << 1
        + (hid_spikes[0] | hid_spikes[10] | hid_spikes[21] | hid_spikes[23] | hid_spikes[31] | hid_spikes[33] | hid_spikes[37] | hid_spikes[41] | hid_spikes[42] | hid_spikes[46] | hid_spikes[53] | hid_spikes[57] | hid_spikes[62] | hid_spikes[63] | hid_spikes[66] | hid_spikes[68]) << 2
        + (hid_spikes[6] | hid_spikes[24] | hid_spikes[34] | hid_spikes[36] | hid_spikes[37] | hid_spikes[52] | hid_spikes[59] | hid_spikes[72] | hid_spikes[76] | hid_spikes[77] | hid_spikes[78]) << 3;
    wire signed [11:0] neg_in_hid_10 = (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0]) << 4
        + (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 4
        + (hid_spikes[1] | hid_spikes[7] | hid_spikes[9] | hid_spikes[11] | hid_spikes[19] | hid_spikes[22] | hid_spikes[29] | hid_spikes[48] | hid_spikes[54] | hid_spikes[61] | hid_spikes[67] | hid_spikes[70] | hid_spikes[74] | hid_spikes[75]) << 0
        + (hid_spikes[1] | hid_spikes[8] | hid_spikes[9] | hid_spikes[17] | hid_spikes[19] | hid_spikes[20] | hid_spikes[22] | hid_spikes[29] | hid_spikes[32] | hid_spikes[39] | hid_spikes[43] | hid_spikes[45] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[54] | hid_spikes[60] | hid_spikes[61] | hid_spikes[64] | hid_spikes[67] | hid_spikes[69] | hid_spikes[74]) << 1
        + (hid_spikes[7] | hid_spikes[8] | hid_spikes[11] | hid_spikes[17] | hid_spikes[20] | hid_spikes[22] | hid_spikes[30] | hid_spikes[35] | hid_spikes[39] | hid_spikes[45] | hid_spikes[47] | hid_spikes[48] | hid_spikes[64] | hid_spikes[70] | hid_spikes[73] | hid_spikes[75]) << 2
        + (hid_spikes[11] | hid_spikes[20] | hid_spikes[28] | hid_spikes[30] | hid_spikes[49] | hid_spikes[51] | hid_spikes[58] | hid_spikes[64] | hid_spikes[73]) << 3;
    wire signed [11:0] sum_hid_10 = pos_in_hid_10 - neg_in_hid_10;
    assign hid_spikes[10] = (mem_hid_10 >= 10);
    wire signed [11:0] next_hid_10 = mem_hid_10 - (mem_hid_10 >>> 4) + sum_hid_10;

    reg signed [11:0] mem_hid_11;
    wire signed [11:0] pos_in_hid_11 = (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[1] | cochlea_spikes[4]) << 2
        + (cochlea_spikes[0]) << 2
        + (hid_spikes[45] | hid_spikes[54] | hid_spikes[74]) << 0
        + (hid_spikes[28] | hid_spikes[32] | hid_spikes[45] | hid_spikes[47] | hid_spikes[51] | hid_spikes[74]) << 1
        + (hid_spikes[32] | hid_spikes[51] | hid_spikes[54]) << 2
        + (hid_spikes[1] | hid_spikes[8] | hid_spikes[32] | hid_spikes[37] | hid_spikes[47]) << 3;
    wire signed [11:0] neg_in_hid_11 = (cochlea_spikes[3]) << 1
        + (cochlea_spikes[3]) << 2
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (hid_spikes[3] | hid_spikes[4] | hid_spikes[9] | hid_spikes[11] | hid_spikes[16] | hid_spikes[17] | hid_spikes[19] | hid_spikes[20] | hid_spikes[26] | hid_spikes[34] | hid_spikes[35] | hid_spikes[38] | hid_spikes[39] | hid_spikes[50] | hid_spikes[52] | hid_spikes[53] | hid_spikes[55] | hid_spikes[59] | hid_spikes[66] | hid_spikes[67] | hid_spikes[68] | hid_spikes[70] | hid_spikes[78]) << 0
        + (hid_spikes[4] | hid_spikes[9] | hid_spikes[14] | hid_spikes[15] | hid_spikes[17] | hid_spikes[19] | hid_spikes[21] | hid_spikes[24] | hid_spikes[29] | hid_spikes[33] | hid_spikes[36] | hid_spikes[38] | hid_spikes[40] | hid_spikes[41] | hid_spikes[42] | hid_spikes[44] | hid_spikes[50] | hid_spikes[52] | hid_spikes[53] | hid_spikes[57] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63] | hid_spikes[65] | hid_spikes[67] | hid_spikes[68] | hid_spikes[70] | hid_spikes[71] | hid_spikes[75] | hid_spikes[76] | hid_spikes[78]) << 1
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[9] | hid_spikes[11] | hid_spikes[13] | hid_spikes[15] | hid_spikes[16] | hid_spikes[17] | hid_spikes[19] | hid_spikes[20] | hid_spikes[23] | hid_spikes[25] | hid_spikes[26] | hid_spikes[29] | hid_spikes[33] | hid_spikes[36] | hid_spikes[42] | hid_spikes[43] | hid_spikes[46] | hid_spikes[53] | hid_spikes[55] | hid_spikes[57] | hid_spikes[58] | hid_spikes[59] | hid_spikes[62] | hid_spikes[66] | hid_spikes[67] | hid_spikes[71] | hid_spikes[72] | hid_spikes[77] | hid_spikes[78]) << 2
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[10] | hid_spikes[16] | hid_spikes[20] | hid_spikes[21] | hid_spikes[25] | hid_spikes[34] | hid_spikes[38] | hid_spikes[39] | hid_spikes[41] | hid_spikes[43] | hid_spikes[48] | hid_spikes[50] | hid_spikes[52] | hid_spikes[53] | hid_spikes[55] | hid_spikes[56] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60] | hid_spikes[62] | hid_spikes[63] | hid_spikes[64] | hid_spikes[65] | hid_spikes[69] | hid_spikes[75] | hid_spikes[76] | hid_spikes[77] | hid_spikes[78]) << 3
        + (hid_spikes[0] | hid_spikes[5] | hid_spikes[13] | hid_spikes[14] | hid_spikes[16] | hid_spikes[20] | hid_spikes[26] | hid_spikes[27] | hid_spikes[31] | hid_spikes[35] | hid_spikes[44] | hid_spikes[61]) << 4;
    wire signed [11:0] sum_hid_11 = pos_in_hid_11 - neg_in_hid_11;
    assign hid_spikes[11] = (mem_hid_11 >= 10);
    wire signed [11:0] next_hid_11 = mem_hid_11 - (mem_hid_11 >>> 6) + sum_hid_11;

    reg signed [11:0] mem_hid_12;
    wire signed [11:0] pos_in_hid_12 = (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 2
        + (hid_spikes[11] | hid_spikes[23] | hid_spikes[25] | hid_spikes[26] | hid_spikes[31] | hid_spikes[35] | hid_spikes[46] | hid_spikes[51] | hid_spikes[52] | hid_spikes[64] | hid_spikes[73] | hid_spikes[79]) << 0
        + (hid_spikes[10] | hid_spikes[11] | hid_spikes[34] | hid_spikes[35] | hid_spikes[36] | hid_spikes[38] | hid_spikes[46] | hid_spikes[52] | hid_spikes[64] | hid_spikes[68] | hid_spikes[73] | hid_spikes[76] | hid_spikes[79]) << 1
        + (hid_spikes[2] | hid_spikes[5] | hid_spikes[10] | hid_spikes[23] | hid_spikes[25] | hid_spikes[31] | hid_spikes[34] | hid_spikes[36] | hid_spikes[52] | hid_spikes[57] | hid_spikes[63] | hid_spikes[68] | hid_spikes[76] | hid_spikes[78] | hid_spikes[79]) << 2
        + (hid_spikes[11] | hid_spikes[26] | hid_spikes[51] | hid_spikes[64] | hid_spikes[72]) << 3;
    wire signed [11:0] neg_in_hid_12 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[2]) << 3
        + (cochlea_spikes[2]) << 4
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[4] | cochlea_spikes[5]) << 1
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[4]) << 3
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[4] | hid_spikes[6] | hid_spikes[16] | hid_spikes[17] | hid_spikes[20] | hid_spikes[27] | hid_spikes[28] | hid_spikes[29] | hid_spikes[32] | hid_spikes[33] | hid_spikes[37] | hid_spikes[41] | hid_spikes[43] | hid_spikes[50] | hid_spikes[56] | hid_spikes[59] | hid_spikes[65] | hid_spikes[67] | hid_spikes[69] | hid_spikes[71] | hid_spikes[75] | hid_spikes[77]) << 0
        + (hid_spikes[1] | hid_spikes[4] | hid_spikes[7] | hid_spikes[18] | hid_spikes[20] | hid_spikes[28] | hid_spikes[30] | hid_spikes[37] | hid_spikes[40] | hid_spikes[41] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[49] | hid_spikes[50] | hid_spikes[66] | hid_spikes[67] | hid_spikes[69]) << 1
        + (hid_spikes[0] | hid_spikes[6] | hid_spikes[9] | hid_spikes[13] | hid_spikes[16] | hid_spikes[17] | hid_spikes[21] | hid_spikes[27] | hid_spikes[29] | hid_spikes[30] | hid_spikes[32] | hid_spikes[33] | hid_spikes[50] | hid_spikes[54] | hid_spikes[56] | hid_spikes[59] | hid_spikes[60] | hid_spikes[65] | hid_spikes[75]) << 2
        + (hid_spikes[7] | hid_spikes[12] | hid_spikes[13] | hid_spikes[15] | hid_spikes[22] | hid_spikes[32] | hid_spikes[37] | hid_spikes[39] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[48] | hid_spikes[53] | hid_spikes[55] | hid_spikes[58] | hid_spikes[71]) << 3
        + (hid_spikes[67] | hid_spikes[77]) << 4;
    wire signed [11:0] sum_hid_12 = pos_in_hid_12 - neg_in_hid_12;
    assign hid_spikes[12] = (mem_hid_12 >= 10);
    wire signed [11:0] next_hid_12 = mem_hid_12 - (mem_hid_12 >>> 6) + sum_hid_12;

    reg signed [11:0] mem_hid_13;
    wire signed [11:0] pos_in_hid_13 = (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 1
        + (cochlea_spikes[3]) << 2
        + (cochlea_spikes[3]) << 3
        + (hid_spikes[8] | hid_spikes[17] | hid_spikes[21] | hid_spikes[23] | hid_spikes[25] | hid_spikes[31] | hid_spikes[47]) << 0
        + (hid_spikes[6] | hid_spikes[8] | hid_spikes[17] | hid_spikes[21] | hid_spikes[23] | hid_spikes[31]) << 1
        + (hid_spikes[6] | hid_spikes[17] | hid_spikes[23] | hid_spikes[25] | hid_spikes[30] | hid_spikes[47] | hid_spikes[57]) << 2
        + (hid_spikes[21] | hid_spikes[28]) << 3;
    wire signed [11:0] neg_in_hid_13 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (cochlea_spikes[4]) << 3
        + (cochlea_spikes[5]) << 4
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[5] | hid_spikes[11] | hid_spikes[12] | hid_spikes[14] | hid_spikes[15] | hid_spikes[18] | hid_spikes[20] | hid_spikes[24] | hid_spikes[26] | hid_spikes[36] | hid_spikes[39] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[53] | hid_spikes[54] | hid_spikes[56] | hid_spikes[59] | hid_spikes[61] | hid_spikes[65] | hid_spikes[67] | hid_spikes[71] | hid_spikes[73] | hid_spikes[78]) << 0
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[2] | hid_spikes[9] | hid_spikes[11] | hid_spikes[15] | hid_spikes[22] | hid_spikes[24] | hid_spikes[32] | hid_spikes[41] | hid_spikes[42] | hid_spikes[44] | hid_spikes[53] | hid_spikes[58] | hid_spikes[61] | hid_spikes[65] | hid_spikes[67] | hid_spikes[68] | hid_spikes[70] | hid_spikes[72] | hid_spikes[73] | hid_spikes[75]) << 1
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[5] | hid_spikes[12] | hid_spikes[14] | hid_spikes[20] | hid_spikes[22] | hid_spikes[34] | hid_spikes[36] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[51] | hid_spikes[54] | hid_spikes[58] | hid_spikes[59] | hid_spikes[61] | hid_spikes[68] | hid_spikes[71] | hid_spikes[72] | hid_spikes[73] | hid_spikes[74]) << 2
        + (hid_spikes[0] | hid_spikes[4] | hid_spikes[9] | hid_spikes[15] | hid_spikes[18] | hid_spikes[24] | hid_spikes[26] | hid_spikes[29] | hid_spikes[32] | hid_spikes[33] | hid_spikes[34] | hid_spikes[41] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[50] | hid_spikes[54] | hid_spikes[56] | hid_spikes[58] | hid_spikes[60] | hid_spikes[62] | hid_spikes[65] | hid_spikes[67] | hid_spikes[70] | hid_spikes[74] | hid_spikes[77] | hid_spikes[78] | hid_spikes[79]) << 3
        + (hid_spikes[13] | hid_spikes[37] | hid_spikes[39] | hid_spikes[66]) << 4;
    wire signed [11:0] sum_hid_13 = pos_in_hid_13 - neg_in_hid_13;
    assign hid_spikes[13] = (mem_hid_13 >= 10);
    wire signed [11:0] next_hid_13 = mem_hid_13 - (mem_hid_13 >>> 6) + sum_hid_13;

    reg signed [11:0] mem_hid_14;
    wire signed [11:0] pos_in_hid_14 = (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 2
        + (hid_spikes[6] | hid_spikes[16] | hid_spikes[29] | hid_spikes[33] | hid_spikes[35] | hid_spikes[37] | hid_spikes[52] | hid_spikes[55] | hid_spikes[58] | hid_spikes[70] | hid_spikes[71] | hid_spikes[76]) << 0
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[16] | hid_spikes[20] | hid_spikes[22] | hid_spikes[33] | hid_spikes[35] | hid_spikes[37] | hid_spikes[42] | hid_spikes[52] | hid_spikes[63] | hid_spikes[76]) << 1
        + (hid_spikes[6] | hid_spikes[20] | hid_spikes[29] | hid_spikes[42] | hid_spikes[48] | hid_spikes[55] | hid_spikes[71]) << 2
        + (hid_spikes[58] | hid_spikes[70]) << 3
        + (hid_spikes[12]) << 4;
    wire signed [11:0] neg_in_hid_14 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[1]) << 5
        + (cochlea_spikes[2]) << 7
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[4]) << 7
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[7] | hid_spikes[10] | hid_spikes[15] | hid_spikes[18] | hid_spikes[19] | hid_spikes[23] | hid_spikes[24] | hid_spikes[27] | hid_spikes[30] | hid_spikes[32] | hid_spikes[34] | hid_spikes[36] | hid_spikes[38] | hid_spikes[46] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[65] | hid_spikes[66] | hid_spikes[67] | hid_spikes[69] | hid_spikes[78]) << 0
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[4] | hid_spikes[18] | hid_spikes[19] | hid_spikes[23] | hid_spikes[27] | hid_spikes[28] | hid_spikes[36] | hid_spikes[39] | hid_spikes[40] | hid_spikes[46] | hid_spikes[47] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[59] | hid_spikes[64] | hid_spikes[66] | hid_spikes[77]) << 1
        + (hid_spikes[0] | hid_spikes[4] | hid_spikes[5] | hid_spikes[15] | hid_spikes[24] | hid_spikes[27] | hid_spikes[28] | hid_spikes[30] | hid_spikes[32] | hid_spikes[34] | hid_spikes[39] | hid_spikes[45] | hid_spikes[46] | hid_spikes[51] | hid_spikes[54] | hid_spikes[59] | hid_spikes[65] | hid_spikes[67] | hid_spikes[73] | hid_spikes[79]) << 2
        + (hid_spikes[4] | hid_spikes[7] | hid_spikes[9] | hid_spikes[10] | hid_spikes[24] | hid_spikes[30] | hid_spikes[32] | hid_spikes[36] | hid_spikes[38] | hid_spikes[46] | hid_spikes[50] | hid_spikes[53] | hid_spikes[54] | hid_spikes[64] | hid_spikes[67] | hid_spikes[69] | hid_spikes[77] | hid_spikes[78]) << 3
        + (hid_spikes[30] | hid_spikes[45] | hid_spikes[47] | hid_spikes[56] | hid_spikes[59] | hid_spikes[64]) << 4;
    wire signed [11:0] sum_hid_14 = pos_in_hid_14 - neg_in_hid_14;
    assign hid_spikes[14] = (mem_hid_14 >= 10);
    wire signed [11:0] next_hid_14 = mem_hid_14 - (mem_hid_14 >>> 6) + sum_hid_14;

    reg signed [11:0] mem_hid_15;
    wire signed [11:0] pos_in_hid_15 = (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (hid_spikes[22] | hid_spikes[27] | hid_spikes[34] | hid_spikes[35] | hid_spikes[37] | hid_spikes[40] | hid_spikes[44] | hid_spikes[48]) << 0
        + (hid_spikes[1] | hid_spikes[11] | hid_spikes[14] | hid_spikes[22] | hid_spikes[27] | hid_spikes[35] | hid_spikes[37] | hid_spikes[39] | hid_spikes[40] | hid_spikes[48] | hid_spikes[69]) << 1
        + (hid_spikes[11] | hid_spikes[14] | hid_spikes[17] | hid_spikes[26] | hid_spikes[44] | hid_spikes[51] | hid_spikes[79]) << 2
        + (hid_spikes[11] | hid_spikes[34]) << 3;
    wire signed [11:0] neg_in_hid_15 = (cochlea_spikes[2]) << 3
        + (cochlea_spikes[4]) << 7
        + (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[1]) << 6
        + (hid_spikes[0] | hid_spikes[4] | hid_spikes[10] | hid_spikes[12] | hid_spikes[13] | hid_spikes[16] | hid_spikes[18] | hid_spikes[20] | hid_spikes[29] | hid_spikes[31] | hid_spikes[42] | hid_spikes[45] | hid_spikes[53] | hid_spikes[55] | hid_spikes[56] | hid_spikes[63] | hid_spikes[64] | hid_spikes[67] | hid_spikes[68] | hid_spikes[70] | hid_spikes[72] | hid_spikes[78]) << 0
        + (hid_spikes[0] | hid_spikes[5] | hid_spikes[7] | hid_spikes[8] | hid_spikes[12] | hid_spikes[15] | hid_spikes[16] | hid_spikes[18] | hid_spikes[19] | hid_spikes[20] | hid_spikes[21] | hid_spikes[23] | hid_spikes[24] | hid_spikes[31] | hid_spikes[33] | hid_spikes[42] | hid_spikes[46] | hid_spikes[47] | hid_spikes[50] | hid_spikes[53] | hid_spikes[58] | hid_spikes[60] | hid_spikes[63] | hid_spikes[64] | hid_spikes[65] | hid_spikes[67] | hid_spikes[68] | hid_spikes[70] | hid_spikes[72] | hid_spikes[73]) << 1
        + (hid_spikes[6] | hid_spikes[10] | hid_spikes[12] | hid_spikes[13] | hid_spikes[16] | hid_spikes[21] | hid_spikes[23] | hid_spikes[31] | hid_spikes[33] | hid_spikes[41] | hid_spikes[42] | hid_spikes[46] | hid_spikes[47] | hid_spikes[50] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[56] | hid_spikes[59] | hid_spikes[63] | hid_spikes[64] | hid_spikes[72] | hid_spikes[73] | hid_spikes[77]) << 2
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[7] | hid_spikes[8] | hid_spikes[19] | hid_spikes[20] | hid_spikes[23] | hid_spikes[24] | hid_spikes[25] | hid_spikes[29] | hid_spikes[33] | hid_spikes[38] | hid_spikes[41] | hid_spikes[45] | hid_spikes[52] | hid_spikes[59] | hid_spikes[60] | hid_spikes[62] | hid_spikes[64] | hid_spikes[65] | hid_spikes[71] | hid_spikes[73] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 3
        + (hid_spikes[9] | hid_spikes[13] | hid_spikes[21] | hid_spikes[46] | hid_spikes[73]) << 4
        + (hid_spikes[54]) << 5;
    wire signed [11:0] sum_hid_15 = pos_in_hid_15 - neg_in_hid_15;
    assign hid_spikes[15] = (mem_hid_15 >= 10);
    wire signed [11:0] next_hid_15 = mem_hid_15 - (mem_hid_15 >>> 6) + sum_hid_15;

    reg signed [11:0] mem_hid_16;
    wire signed [11:0] pos_in_hid_16 = (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 2
        + (hid_spikes[18] | hid_spikes[21] | hid_spikes[31] | hid_spikes[33] | hid_spikes[35] | hid_spikes[55] | hid_spikes[57] | hid_spikes[60] | hid_spikes[62] | hid_spikes[63]) << 0
        + (hid_spikes[5] | hid_spikes[7] | hid_spikes[10] | hid_spikes[18] | hid_spikes[21] | hid_spikes[29] | hid_spikes[35] | hid_spikes[39] | hid_spikes[48] | hid_spikes[49] | hid_spikes[55] | hid_spikes[60] | hid_spikes[63] | hid_spikes[74]) << 1
        + (hid_spikes[10] | hid_spikes[14] | hid_spikes[31] | hid_spikes[33] | hid_spikes[39] | hid_spikes[48] | hid_spikes[49] | hid_spikes[57] | hid_spikes[74] | hid_spikes[76]) << 2
        + (hid_spikes[33] | hid_spikes[39] | hid_spikes[62] | hid_spikes[76]) << 3
        + (hid_spikes[6]) << 4;
    wire signed [11:0] neg_in_hid_16 = (cochlea_spikes[1] | cochlea_spikes[5]) << 1
        + (cochlea_spikes[5]) << 3
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[1]) << 5
        + (cochlea_spikes[2]) << 7
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[0]) << 4
        + (cochlea_spikes[4]) << 7
        + (hid_spikes[4] | hid_spikes[9] | hid_spikes[11] | hid_spikes[13] | hid_spikes[17] | hid_spikes[24] | hid_spikes[36] | hid_spikes[40] | hid_spikes[47] | hid_spikes[59] | hid_spikes[64] | hid_spikes[66] | hid_spikes[71] | hid_spikes[75] | hid_spikes[77]) << 0
        + (hid_spikes[4] | hid_spikes[9] | hid_spikes[13] | hid_spikes[19] | hid_spikes[24] | hid_spikes[34] | hid_spikes[38] | hid_spikes[40] | hid_spikes[46] | hid_spikes[47] | hid_spikes[59] | hid_spikes[64] | hid_spikes[65] | hid_spikes[67] | hid_spikes[75] | hid_spikes[77]) << 1
        + (hid_spikes[4] | hid_spikes[8] | hid_spikes[16] | hid_spikes[17] | hid_spikes[24] | hid_spikes[25] | hid_spikes[27] | hid_spikes[34] | hid_spikes[37] | hid_spikes[40] | hid_spikes[45] | hid_spikes[50] | hid_spikes[54] | hid_spikes[64] | hid_spikes[65] | hid_spikes[66] | hid_spikes[67] | hid_spikes[69]) << 2
        + (hid_spikes[3] | hid_spikes[8] | hid_spikes[9] | hid_spikes[11] | hid_spikes[12] | hid_spikes[17] | hid_spikes[19] | hid_spikes[20] | hid_spikes[30] | hid_spikes[34] | hid_spikes[45] | hid_spikes[46] | hid_spikes[50] | hid_spikes[54] | hid_spikes[64] | hid_spikes[66] | hid_spikes[71] | hid_spikes[75]) << 3
        + (hid_spikes[30] | hid_spikes[36] | hid_spikes[38] | hid_spikes[46] | hid_spikes[59] | hid_spikes[67] | hid_spikes[73]) << 4;
    wire signed [11:0] sum_hid_16 = pos_in_hid_16 - neg_in_hid_16;
    assign hid_spikes[16] = (mem_hid_16 >= 10);
    wire signed [11:0] next_hid_16 = mem_hid_16 - (mem_hid_16 >>> 5) + sum_hid_16;

    reg signed [11:0] mem_hid_17;
    wire signed [11:0] pos_in_hid_17 = (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[5]) << 2
        + (hid_spikes[2] | hid_spikes[8] | hid_spikes[10] | hid_spikes[18] | hid_spikes[28] | hid_spikes[31] | hid_spikes[40] | hid_spikes[52] | hid_spikes[55] | hid_spikes[76]) << 0
        + (hid_spikes[2] | hid_spikes[3] | hid_spikes[8] | hid_spikes[10] | hid_spikes[18] | hid_spikes[23] | hid_spikes[28] | hid_spikes[31] | hid_spikes[40] | hid_spikes[75] | hid_spikes[76]) << 1
        + (hid_spikes[2] | hid_spikes[5] | hid_spikes[16] | hid_spikes[22] | hid_spikes[40] | hid_spikes[52] | hid_spikes[72]) << 2
        + (hid_spikes[32] | hid_spikes[55]) << 3;
    wire signed [11:0] neg_in_hid_17 = (cochlea_spikes[2]) << 2
        + (cochlea_spikes[0]) << 1
        + (hid_spikes[7] | hid_spikes[12] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[25] | hid_spikes[26] | hid_spikes[34] | hid_spikes[37] | hid_spikes[49] | hid_spikes[54] | hid_spikes[56] | hid_spikes[58] | hid_spikes[59] | hid_spikes[62] | hid_spikes[63] | hid_spikes[66] | hid_spikes[67] | hid_spikes[68] | hid_spikes[69] | hid_spikes[73] | hid_spikes[74] | hid_spikes[79]) << 0
        + (hid_spikes[0] | hid_spikes[7] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[20] | hid_spikes[25] | hid_spikes[26] | hid_spikes[34] | hid_spikes[35] | hid_spikes[38] | hid_spikes[39] | hid_spikes[42] | hid_spikes[46] | hid_spikes[49] | hid_spikes[51] | hid_spikes[54] | hid_spikes[58] | hid_spikes[65] | hid_spikes[66] | hid_spikes[68] | hid_spikes[73] | hid_spikes[74] | hid_spikes[77] | hid_spikes[79]) << 1
        + (hid_spikes[0] | hid_spikes[7] | hid_spikes[9] | hid_spikes[11] | hid_spikes[12] | hid_spikes[13] | hid_spikes[15] | hid_spikes[20] | hid_spikes[24] | hid_spikes[25] | hid_spikes[33] | hid_spikes[35] | hid_spikes[37] | hid_spikes[38] | hid_spikes[44] | hid_spikes[45] | hid_spikes[46] | hid_spikes[47] | hid_spikes[50] | hid_spikes[54] | hid_spikes[56] | hid_spikes[59] | hid_spikes[64] | hid_spikes[65] | hid_spikes[66] | hid_spikes[67] | hid_spikes[69] | hid_spikes[70] | hid_spikes[71] | hid_spikes[77] | hid_spikes[78]) << 2
        + (hid_spikes[7] | hid_spikes[11] | hid_spikes[13] | hid_spikes[21] | hid_spikes[24] | hid_spikes[35] | hid_spikes[37] | hid_spikes[38] | hid_spikes[39] | hid_spikes[43] | hid_spikes[46] | hid_spikes[47] | hid_spikes[53] | hid_spikes[62] | hid_spikes[69] | hid_spikes[71] | hid_spikes[73] | hid_spikes[77]) << 3
        + (hid_spikes[0] | hid_spikes[4] | hid_spikes[46] | hid_spikes[47] | hid_spikes[54] | hid_spikes[63] | hid_spikes[67]) << 4
        + (hid_spikes[11]) << 5;
    wire signed [11:0] sum_hid_17 = pos_in_hid_17 - neg_in_hid_17;
    assign hid_spikes[17] = (mem_hid_17 >= 10);
    wire signed [11:0] next_hid_17 = mem_hid_17 - (mem_hid_17 >>> 5) + sum_hid_17;

    reg signed [11:0] mem_hid_18;
    wire signed [11:0] pos_in_hid_18 = (hid_spikes[0] | hid_spikes[10] | hid_spikes[19] | hid_spikes[31] | hid_spikes[46] | hid_spikes[51] | hid_spikes[52] | hid_spikes[63] | hid_spikes[67] | hid_spikes[74] | hid_spikes[76]) << 0
        + (hid_spikes[10] | hid_spikes[15] | hid_spikes[26] | hid_spikes[31] | hid_spikes[35] | hid_spikes[36] | hid_spikes[48] | hid_spikes[52] | hid_spikes[61] | hid_spikes[74] | hid_spikes[78]) << 1
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[10] | hid_spikes[19] | hid_spikes[23] | hid_spikes[26] | hid_spikes[27] | hid_spikes[31] | hid_spikes[35] | hid_spikes[46] | hid_spikes[51] | hid_spikes[52] | hid_spikes[55] | hid_spikes[63] | hid_spikes[66] | hid_spikes[67] | hid_spikes[72]) << 2
        + (hid_spikes[0] | hid_spikes[5] | hid_spikes[34] | hid_spikes[36] | hid_spikes[44] | hid_spikes[48] | hid_spikes[72] | hid_spikes[76] | hid_spikes[78]) << 3;
    wire signed [11:0] neg_in_hid_18 = (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0] | cochlea_spikes[2] | cochlea_spikes[4]) << 1
        + (cochlea_spikes[2] | cochlea_spikes[4]) << 2
        + (cochlea_spikes[2] | cochlea_spikes[4]) << 3
        + (cochlea_spikes[4]) << 4
        + (cochlea_spikes[0] | cochlea_spikes[2]) << 5
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[1] | cochlea_spikes[5]) << 1
        + (cochlea_spikes[1] | cochlea_spikes[3] | cochlea_spikes[5]) << 2
        + (cochlea_spikes[3]) << 3
        + (cochlea_spikes[5]) << 4
        + (cochlea_spikes[1] | cochlea_spikes[3]) << 5
        + (hid_spikes[7] | hid_spikes[12] | hid_spikes[13] | hid_spikes[17] | hid_spikes[21] | hid_spikes[28] | hid_spikes[32] | hid_spikes[38] | hid_spikes[39] | hid_spikes[41] | hid_spikes[54] | hid_spikes[56] | hid_spikes[58] | hid_spikes[64] | hid_spikes[65] | hid_spikes[68] | hid_spikes[69] | hid_spikes[75] | hid_spikes[77] | hid_spikes[79]) << 0
        + (hid_spikes[4] | hid_spikes[11] | hid_spikes[12] | hid_spikes[13] | hid_spikes[20] | hid_spikes[21] | hid_spikes[28] | hid_spikes[32] | hid_spikes[37] | hid_spikes[38] | hid_spikes[41] | hid_spikes[47] | hid_spikes[56] | hid_spikes[57] | hid_spikes[62] | hid_spikes[65] | hid_spikes[75] | hid_spikes[77]) << 1
        + (hid_spikes[8] | hid_spikes[9] | hid_spikes[11] | hid_spikes[18] | hid_spikes[24] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[32] | hid_spikes[38] | hid_spikes[39] | hid_spikes[57] | hid_spikes[58] | hid_spikes[62] | hid_spikes[64] | hid_spikes[69] | hid_spikes[70] | hid_spikes[75] | hid_spikes[79]) << 2
        + (hid_spikes[7] | hid_spikes[11] | hid_spikes[17] | hid_spikes[20] | hid_spikes[38] | hid_spikes[42] | hid_spikes[45] | hid_spikes[50] | hid_spikes[54] | hid_spikes[64] | hid_spikes[65] | hid_spikes[68]) << 3
        + (hid_spikes[4] | hid_spikes[43]) << 4;
    wire signed [11:0] sum_hid_18 = pos_in_hid_18 - neg_in_hid_18;
    assign hid_spikes[18] = (mem_hid_18 >= 10);
    wire signed [11:0] next_hid_18 = mem_hid_18 - (mem_hid_18 >>> 6) + sum_hid_18;

    reg signed [11:0] mem_hid_19;
    wire signed [11:0] pos_in_hid_19 = (hid_spikes[3] | hid_spikes[10] | hid_spikes[12] | hid_spikes[23] | hid_spikes[26] | hid_spikes[27] | hid_spikes[29] | hid_spikes[34] | hid_spikes[36] | hid_spikes[39] | hid_spikes[41] | hid_spikes[46] | hid_spikes[47] | hid_spikes[52] | hid_spikes[72] | hid_spikes[73]) << 0
        + (hid_spikes[1] | hid_spikes[3] | hid_spikes[6] | hid_spikes[10] | hid_spikes[12] | hid_spikes[18] | hid_spikes[20] | hid_spikes[23] | hid_spikes[29] | hid_spikes[31] | hid_spikes[33] | hid_spikes[36] | hid_spikes[44] | hid_spikes[46] | hid_spikes[47] | hid_spikes[51] | hid_spikes[52] | hid_spikes[55] | hid_spikes[61] | hid_spikes[62] | hid_spikes[67] | hid_spikes[68] | hid_spikes[70] | hid_spikes[72] | hid_spikes[79]) << 1
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[12] | hid_spikes[15] | hid_spikes[16] | hid_spikes[23] | hid_spikes[26] | hid_spikes[29] | hid_spikes[33] | hid_spikes[41] | hid_spikes[42] | hid_spikes[51] | hid_spikes[52] | hid_spikes[61] | hid_spikes[68] | hid_spikes[70] | hid_spikes[73] | hid_spikes[79]) << 2
        + (hid_spikes[1] | hid_spikes[15] | hid_spikes[19] | hid_spikes[26] | hid_spikes[27] | hid_spikes[31] | hid_spikes[34] | hid_spikes[39] | hid_spikes[42] | hid_spikes[62] | hid_spikes[66]) << 3
        + (hid_spikes[0] | hid_spikes[47] | hid_spikes[62]) << 4;
    wire signed [11:0] neg_in_hid_19 = (cochlea_spikes[5]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[1] | cochlea_spikes[2]) << 3
        + (cochlea_spikes[2] | cochlea_spikes[5]) << 4
        + (cochlea_spikes[2]) << 5
        + (cochlea_spikes[1] | cochlea_spikes[2]) << 6
        + (cochlea_spikes[3] | cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[3]) << 2
        + (cochlea_spikes[3] | cochlea_spikes[4]) << 3
        + (cochlea_spikes[0]) << 4
        + (cochlea_spikes[0] | cochlea_spikes[4]) << 5
        + (cochlea_spikes[4]) << 6
        + (hid_spikes[9] | hid_spikes[13] | hid_spikes[17] | hid_spikes[22] | hid_spikes[25] | hid_spikes[32] | hid_spikes[38] | hid_spikes[50] | hid_spikes[56] | hid_spikes[71] | hid_spikes[74] | hid_spikes[75]) << 0
        + (hid_spikes[4] | hid_spikes[9] | hid_spikes[17] | hid_spikes[22] | hid_spikes[25] | hid_spikes[28] | hid_spikes[30] | hid_spikes[32] | hid_spikes[49] | hid_spikes[59] | hid_spikes[64] | hid_spikes[65] | hid_spikes[69] | hid_spikes[74] | hid_spikes[76] | hid_spikes[77]) << 1
        + (hid_spikes[13] | hid_spikes[28] | hid_spikes[32] | hid_spikes[38] | hid_spikes[49] | hid_spikes[50] | hid_spikes[54] | hid_spikes[71]) << 2
        + (hid_spikes[13] | hid_spikes[21] | hid_spikes[30] | hid_spikes[32] | hid_spikes[38] | hid_spikes[45] | hid_spikes[57] | hid_spikes[69] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 3
        + (hid_spikes[56]) << 4;
    wire signed [11:0] sum_hid_19 = pos_in_hid_19 - neg_in_hid_19;
    assign hid_spikes[19] = (mem_hid_19 >= 10);
    wire signed [11:0] next_hid_19 = mem_hid_19 - (mem_hid_19 >>> 6) + sum_hid_19;

    reg signed [11:0] mem_hid_20;
    wire signed [11:0] pos_in_hid_20 = (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 1
        + (cochlea_spikes[3]) << 3
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 3
        + (hid_spikes[29] | hid_spikes[46] | hid_spikes[53] | hid_spikes[73] | hid_spikes[78]) << 0
        + (hid_spikes[32] | hid_spikes[34] | hid_spikes[39] | hid_spikes[44] | hid_spikes[46] | hid_spikes[53] | hid_spikes[54] | hid_spikes[78]) << 1
        + (hid_spikes[1] | hid_spikes[29] | hid_spikes[34] | hid_spikes[46] | hid_spikes[54] | hid_spikes[73]) << 2
        + (hid_spikes[11] | hid_spikes[46] | hid_spikes[61]) << 3;
    wire signed [11:0] neg_in_hid_20 = (cochlea_spikes[0] | cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[5]) << 3
        + (hid_spikes[0] | hid_spikes[4] | hid_spikes[5] | hid_spikes[6] | hid_spikes[13] | hid_spikes[16] | hid_spikes[20] | hid_spikes[21] | hid_spikes[22] | hid_spikes[23] | hid_spikes[26] | hid_spikes[28] | hid_spikes[31] | hid_spikes[36] | hid_spikes[47] | hid_spikes[48] | hid_spikes[51] | hid_spikes[59] | hid_spikes[67] | hid_spikes[70] | hid_spikes[72] | hid_spikes[75] | hid_spikes[76]) << 0
        + (hid_spikes[0] | hid_spikes[4] | hid_spikes[5] | hid_spikes[7] | hid_spikes[10] | hid_spikes[13] | hid_spikes[20] | hid_spikes[21] | hid_spikes[23] | hid_spikes[24] | hid_spikes[26] | hid_spikes[28] | hid_spikes[33] | hid_spikes[43] | hid_spikes[47] | hid_spikes[48] | hid_spikes[51] | hid_spikes[52] | hid_spikes[56] | hid_spikes[57] | hid_spikes[62] | hid_spikes[63] | hid_spikes[65] | hid_spikes[72]) << 1
        + (hid_spikes[0] | hid_spikes[4] | hid_spikes[10] | hid_spikes[12] | hid_spikes[13] | hid_spikes[14] | hid_spikes[18] | hid_spikes[20] | hid_spikes[21] | hid_spikes[22] | hid_spikes[23] | hid_spikes[24] | hid_spikes[27] | hid_spikes[28] | hid_spikes[31] | hid_spikes[33] | hid_spikes[41] | hid_spikes[43] | hid_spikes[49] | hid_spikes[58] | hid_spikes[62] | hid_spikes[66] | hid_spikes[68] | hid_spikes[74] | hid_spikes[75]) << 2
        + (hid_spikes[3] | hid_spikes[6] | hid_spikes[16] | hid_spikes[18] | hid_spikes[22] | hid_spikes[30] | hid_spikes[33] | hid_spikes[36] | hid_spikes[38] | hid_spikes[50] | hid_spikes[52] | hid_spikes[55] | hid_spikes[58] | hid_spikes[65] | hid_spikes[66] | hid_spikes[67] | hid_spikes[68] | hid_spikes[76]) << 3
        + (hid_spikes[9] | hid_spikes[47] | hid_spikes[56] | hid_spikes[59] | hid_spikes[70] | hid_spikes[77]) << 4;
    wire signed [11:0] sum_hid_20 = pos_in_hid_20 - neg_in_hid_20;
    assign hid_spikes[20] = (mem_hid_20 >= 10);
    wire signed [11:0] next_hid_20 = mem_hid_20 - (mem_hid_20 >>> 5) + sum_hid_20;

    reg signed [11:0] mem_hid_21;
    wire signed [11:0] pos_in_hid_21 = (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 1
        + (cochlea_spikes[2]) << 1
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[17] | hid_spikes[25] | hid_spikes[33] | hid_spikes[68]) << 0
        + (hid_spikes[3] | hid_spikes[13] | hid_spikes[17] | hid_spikes[25] | hid_spikes[33]) << 1
        + (hid_spikes[5] | hid_spikes[21] | hid_spikes[24] | hid_spikes[25] | hid_spikes[44] | hid_spikes[58] | hid_spikes[68] | hid_spikes[70]) << 2
        + (hid_spikes[2] | hid_spikes[6] | hid_spikes[68]) << 3;
    wire signed [11:0] neg_in_hid_21 = (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 2
        + (hid_spikes[1] | hid_spikes[8] | hid_spikes[9] | hid_spikes[10] | hid_spikes[12] | hid_spikes[15] | hid_spikes[16] | hid_spikes[18] | hid_spikes[20] | hid_spikes[22] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[34] | hid_spikes[38] | hid_spikes[41] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[52] | hid_spikes[55] | hid_spikes[56] | hid_spikes[62] | hid_spikes[63] | hid_spikes[65] | hid_spikes[67] | hid_spikes[69] | hid_spikes[71] | hid_spikes[72] | hid_spikes[73] | hid_spikes[76] | hid_spikes[77] | hid_spikes[78]) << 0
        + (hid_spikes[1] | hid_spikes[8] | hid_spikes[9] | hid_spikes[10] | hid_spikes[15] | hid_spikes[16] | hid_spikes[22] | hid_spikes[30] | hid_spikes[31] | hid_spikes[32] | hid_spikes[34] | hid_spikes[35] | hid_spikes[38] | hid_spikes[39] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[50] | hid_spikes[52] | hid_spikes[54] | hid_spikes[59] | hid_spikes[62] | hid_spikes[71] | hid_spikes[73] | hid_spikes[74] | hid_spikes[75]) << 1
        + (hid_spikes[0] | hid_spikes[8] | hid_spikes[11] | hid_spikes[12] | hid_spikes[19] | hid_spikes[22] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[35] | hid_spikes[43] | hid_spikes[45] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[54] | hid_spikes[55] | hid_spikes[56] | hid_spikes[59] | hid_spikes[65] | hid_spikes[67] | hid_spikes[71] | hid_spikes[73] | hid_spikes[74] | hid_spikes[76] | hid_spikes[77] | hid_spikes[78] | hid_spikes[79]) << 2
        + (hid_spikes[4] | hid_spikes[14] | hid_spikes[18] | hid_spikes[19] | hid_spikes[26] | hid_spikes[27] | hid_spikes[31] | hid_spikes[32] | hid_spikes[34] | hid_spikes[35] | hid_spikes[36] | hid_spikes[38] | hid_spikes[39] | hid_spikes[40] | hid_spikes[41] | hid_spikes[42] | hid_spikes[46] | hid_spikes[47] | hid_spikes[50] | hid_spikes[52] | hid_spikes[54] | hid_spikes[61] | hid_spikes[63] | hid_spikes[65] | hid_spikes[66] | hid_spikes[69] | hid_spikes[72] | hid_spikes[79]) << 3
        + (hid_spikes[20] | hid_spikes[26] | hid_spikes[38] | hid_spikes[46] | hid_spikes[61] | hid_spikes[63] | hid_spikes[65] | hid_spikes[73] | hid_spikes[76]) << 4
        + (hid_spikes[11] | hid_spikes[75]) << 5;
    wire signed [11:0] sum_hid_21 = pos_in_hid_21 - neg_in_hid_21;
    assign hid_spikes[21] = (mem_hid_21 >= 10);
    wire signed [11:0] next_hid_21 = mem_hid_21 - (mem_hid_21 >>> 6) + sum_hid_21;

    reg signed [11:0] mem_hid_22;
    wire signed [11:0] pos_in_hid_22 = (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 2
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[10] | hid_spikes[12] | hid_spikes[19] | hid_spikes[33] | hid_spikes[43] | hid_spikes[45] | hid_spikes[79]) << 0
        + (hid_spikes[3] | hid_spikes[8] | hid_spikes[10] | hid_spikes[11] | hid_spikes[19] | hid_spikes[29] | hid_spikes[33] | hid_spikes[43] | hid_spikes[63] | hid_spikes[77] | hid_spikes[79]) << 1
        + (hid_spikes[7] | hid_spikes[8] | hid_spikes[11] | hid_spikes[29] | hid_spikes[33] | hid_spikes[41] | hid_spikes[45] | hid_spikes[54] | hid_spikes[63] | hid_spikes[64] | hid_spikes[74] | hid_spikes[79]) << 2
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[6] | hid_spikes[12] | hid_spikes[51] | hid_spikes[64]) << 3;
    wire signed [11:0] neg_in_hid_22 = (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[2]) << 3
        + (cochlea_spikes[0]) << 4
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 4
        + (hid_spikes[0] | hid_spikes[5] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[21] | hid_spikes[26] | hid_spikes[30] | hid_spikes[31] | hid_spikes[37] | hid_spikes[40] | hid_spikes[47] | hid_spikes[50] | hid_spikes[57] | hid_spikes[69] | hid_spikes[72]) << 0
        + (hid_spikes[4] | hid_spikes[16] | hid_spikes[21] | hid_spikes[26] | hid_spikes[31] | hid_spikes[34] | hid_spikes[38] | hid_spikes[40] | hid_spikes[46] | hid_spikes[49] | hid_spikes[50] | hid_spikes[57] | hid_spikes[58] | hid_spikes[69] | hid_spikes[71] | hid_spikes[73] | hid_spikes[78]) << 1
        + (hid_spikes[5] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[20] | hid_spikes[23] | hid_spikes[25] | hid_spikes[30] | hid_spikes[31] | hid_spikes[32] | hid_spikes[36] | hid_spikes[37] | hid_spikes[44] | hid_spikes[46] | hid_spikes[47] | hid_spikes[53] | hid_spikes[58] | hid_spikes[59] | hid_spikes[62] | hid_spikes[67] | hid_spikes[71] | hid_spikes[72] | hid_spikes[75]) << 2
        + (hid_spikes[13] | hid_spikes[20] | hid_spikes[24] | hid_spikes[25] | hid_spikes[36] | hid_spikes[38] | hid_spikes[53] | hid_spikes[73] | hid_spikes[78]) << 3
        + (hid_spikes[0] | hid_spikes[61] | hid_spikes[67]) << 4;
    wire signed [11:0] sum_hid_22 = pos_in_hid_22 - neg_in_hid_22;
    assign hid_spikes[22] = (mem_hid_22 >= 10);
    wire signed [11:0] next_hid_22 = mem_hid_22 - (mem_hid_22 >>> 6) + sum_hid_22;

    reg signed [11:0] mem_hid_23;
    wire signed [11:0] pos_in_hid_23 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[1]) << 3
        + (hid_spikes[3] | hid_spikes[11] | hid_spikes[15] | hid_spikes[22] | hid_spikes[27] | hid_spikes[30] | hid_spikes[51] | hid_spikes[52] | hid_spikes[59] | hid_spikes[66] | hid_spikes[68] | hid_spikes[72]) << 0
        + (hid_spikes[3] | hid_spikes[11] | hid_spikes[14] | hid_spikes[15] | hid_spikes[18] | hid_spikes[19] | hid_spikes[22] | hid_spikes[23] | hid_spikes[27] | hid_spikes[30] | hid_spikes[51] | hid_spikes[56] | hid_spikes[59] | hid_spikes[66] | hid_spikes[68] | hid_spikes[69]) << 1
        + (hid_spikes[12] | hid_spikes[14] | hid_spikes[17] | hid_spikes[22] | hid_spikes[23] | hid_spikes[27] | hid_spikes[52] | hid_spikes[56] | hid_spikes[69]) << 2
        + (hid_spikes[3] | hid_spikes[12] | hid_spikes[16] | hid_spikes[22] | hid_spikes[26] | hid_spikes[56] | hid_spikes[59] | hid_spikes[62] | hid_spikes[66] | hid_spikes[72]) << 3
        + (hid_spikes[0]) << 4;
    wire signed [11:0] neg_in_hid_23 = (cochlea_spikes[4]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[4]) << 5
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[3]) << 1
        + (cochlea_spikes[3] | cochlea_spikes[5]) << 2
        + (cochlea_spikes[5]) << 4
        + (hid_spikes[4] | hid_spikes[10] | hid_spikes[13] | hid_spikes[20] | hid_spikes[33] | hid_spikes[41] | hid_spikes[42] | hid_spikes[45] | hid_spikes[47] | hid_spikes[53] | hid_spikes[55] | hid_spikes[64] | hid_spikes[65] | hid_spikes[67] | hid_spikes[71] | hid_spikes[74] | hid_spikes[75] | hid_spikes[76]) << 0
        + (hid_spikes[7] | hid_spikes[10] | hid_spikes[20] | hid_spikes[33] | hid_spikes[41] | hid_spikes[47] | hid_spikes[50] | hid_spikes[53] | hid_spikes[55] | hid_spikes[64] | hid_spikes[74] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 1
        + (hid_spikes[4] | hid_spikes[13] | hid_spikes[21] | hid_spikes[32] | hid_spikes[39] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[46] | hid_spikes[53] | hid_spikes[67] | hid_spikes[70] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 2
        + (hid_spikes[7] | hid_spikes[20] | hid_spikes[21] | hid_spikes[37] | hid_spikes[38] | hid_spikes[43] | hid_spikes[45] | hid_spikes[60] | hid_spikes[71] | hid_spikes[75] | hid_spikes[76]) << 3
        + (hid_spikes[63] | hid_spikes[64] | hid_spikes[65]) << 4;
    wire signed [11:0] sum_hid_23 = pos_in_hid_23 - neg_in_hid_23;
    assign hid_spikes[23] = (mem_hid_23 >= 10);
    wire signed [11:0] next_hid_23 = mem_hid_23 - (mem_hid_23 >>> 4) + sum_hid_23;

    reg signed [11:0] mem_hid_24;
    wire signed [11:0] pos_in_hid_24 = (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[4]) << 4
        + (hid_spikes[7] | hid_spikes[19] | hid_spikes[50] | hid_spikes[59] | hid_spikes[60] | hid_spikes[62] | hid_spikes[63] | hid_spikes[72]) << 0
        + (hid_spikes[7] | hid_spikes[26] | hid_spikes[45] | hid_spikes[50] | hid_spikes[59] | hid_spikes[60] | hid_spikes[63] | hid_spikes[79]) << 1
        + (hid_spikes[45] | hid_spikes[60] | hid_spikes[62] | hid_spikes[72]) << 2
        + (hid_spikes[18] | hid_spikes[19] | hid_spikes[23] | hid_spikes[62]) << 3
        + (hid_spikes[0]) << 4;
    wire signed [11:0] neg_in_hid_24 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[3]) << 2
        + (cochlea_spikes[1] | cochlea_spikes[2]) << 3
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[5]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[5]) << 4
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[12] | hid_spikes[13] | hid_spikes[14] | hid_spikes[21] | hid_spikes[25] | hid_spikes[27] | hid_spikes[28] | hid_spikes[30] | hid_spikes[36] | hid_spikes[41] | hid_spikes[43] | hid_spikes[54] | hid_spikes[55] | hid_spikes[64] | hid_spikes[66] | hid_spikes[67] | hid_spikes[68] | hid_spikes[75] | hid_spikes[78]) << 0
        + (hid_spikes[2] | hid_spikes[5] | hid_spikes[6] | hid_spikes[13] | hid_spikes[17] | hid_spikes[25] | hid_spikes[27] | hid_spikes[28] | hid_spikes[30] | hid_spikes[36] | hid_spikes[41] | hid_spikes[42] | hid_spikes[46] | hid_spikes[48] | hid_spikes[53] | hid_spikes[55] | hid_spikes[57] | hid_spikes[58] | hid_spikes[61] | hid_spikes[64] | hid_spikes[65] | hid_spikes[67] | hid_spikes[68] | hid_spikes[73]) << 1
        + (hid_spikes[5] | hid_spikes[9] | hid_spikes[10] | hid_spikes[11] | hid_spikes[12] | hid_spikes[13] | hid_spikes[16] | hid_spikes[21] | hid_spikes[32] | hid_spikes[33] | hid_spikes[40] | hid_spikes[43] | hid_spikes[44] | hid_spikes[46] | hid_spikes[49] | hid_spikes[52] | hid_spikes[54] | hid_spikes[57] | hid_spikes[58] | hid_spikes[66] | hid_spikes[71] | hid_spikes[75] | hid_spikes[78]) << 2
        + (hid_spikes[3] | hid_spikes[9] | hid_spikes[14] | hid_spikes[22] | hid_spikes[36] | hid_spikes[37] | hid_spikes[38] | hid_spikes[44] | hid_spikes[47] | hid_spikes[53] | hid_spikes[54] | hid_spikes[57] | hid_spikes[58] | hid_spikes[61] | hid_spikes[64] | hid_spikes[73] | hid_spikes[75] | hid_spikes[76] | hid_spikes[78]) << 3
        + (hid_spikes[17] | hid_spikes[20] | hid_spikes[24]) << 4;
    wire signed [11:0] sum_hid_24 = pos_in_hid_24 - neg_in_hid_24;
    assign hid_spikes[24] = (mem_hid_24 >= 10);
    wire signed [11:0] next_hid_24 = mem_hid_24 - (mem_hid_24 >>> 4) + sum_hid_24;

    reg signed [11:0] mem_hid_25;
    wire signed [11:0] pos_in_hid_25 = (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 3
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[8] | hid_spikes[19] | hid_spikes[22] | hid_spikes[23] | hid_spikes[24] | hid_spikes[26] | hid_spikes[41] | hid_spikes[48] | hid_spikes[55] | hid_spikes[57] | hid_spikes[62] | hid_spikes[66] | hid_spikes[69] | hid_spikes[72] | hid_spikes[76]) << 0
        + (hid_spikes[1] | hid_spikes[14] | hid_spikes[19] | hid_spikes[24] | hid_spikes[26] | hid_spikes[34] | hid_spikes[39] | hid_spikes[41] | hid_spikes[49] | hid_spikes[52] | hid_spikes[57] | hid_spikes[63] | hid_spikes[69] | hid_spikes[72] | hid_spikes[76] | hid_spikes[78]) << 1
        + (hid_spikes[2] | hid_spikes[14] | hid_spikes[19] | hid_spikes[22] | hid_spikes[23] | hid_spikes[33] | hid_spikes[34] | hid_spikes[41] | hid_spikes[48] | hid_spikes[49] | hid_spikes[51] | hid_spikes[55] | hid_spikes[63] | hid_spikes[66] | hid_spikes[69] | hid_spikes[72] | hid_spikes[78]) << 2
        + (hid_spikes[8] | hid_spikes[14] | hid_spikes[16] | hid_spikes[23] | hid_spikes[34] | hid_spikes[52] | hid_spikes[55]) << 3
        + (hid_spikes[62]) << 4;
    wire signed [11:0] neg_in_hid_25 = (cochlea_spikes[0] | cochlea_spikes[3]) << 0
        + (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[3]) << 3
        + (cochlea_spikes[3]) << 4
        + (cochlea_spikes[0]) << 5
        + (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[2] | cochlea_spikes[4]) << 2
        + (cochlea_spikes[2] | cochlea_spikes[4]) << 3
        + (cochlea_spikes[4]) << 4
        + (hid_spikes[5] | hid_spikes[7] | hid_spikes[10] | hid_spikes[11] | hid_spikes[25] | hid_spikes[28] | hid_spikes[36] | hid_spikes[38] | hid_spikes[40] | hid_spikes[43] | hid_spikes[44] | hid_spikes[50] | hid_spikes[53] | hid_spikes[54] | hid_spikes[58] | hid_spikes[60] | hid_spikes[64] | hid_spikes[70]) << 0
        + (hid_spikes[5] | hid_spikes[7] | hid_spikes[10] | hid_spikes[11] | hid_spikes[12] | hid_spikes[15] | hid_spikes[17] | hid_spikes[18] | hid_spikes[25] | hid_spikes[31] | hid_spikes[32] | hid_spikes[43] | hid_spikes[44] | hid_spikes[50] | hid_spikes[53] | hid_spikes[58] | hid_spikes[60] | hid_spikes[61] | hid_spikes[64] | hid_spikes[67] | hid_spikes[70] | hid_spikes[71] | hid_spikes[73] | hid_spikes[74] | hid_spikes[75]) << 1
        + (hid_spikes[5] | hid_spikes[12] | hid_spikes[13] | hid_spikes[17] | hid_spikes[28] | hid_spikes[29] | hid_spikes[36] | hid_spikes[40] | hid_spikes[42] | hid_spikes[44] | hid_spikes[47] | hid_spikes[53] | hid_spikes[58] | hid_spikes[60] | hid_spikes[70] | hid_spikes[75] | hid_spikes[77]) << 2
        + (hid_spikes[4] | hid_spikes[32] | hid_spikes[38] | hid_spikes[53] | hid_spikes[54] | hid_spikes[61] | hid_spikes[73]) << 3
        + (hid_spikes[13] | hid_spikes[30] | hid_spikes[38] | hid_spikes[64] | hid_spikes[65] | hid_spikes[67] | hid_spikes[71]) << 4;
    wire signed [11:0] sum_hid_25 = pos_in_hid_25 - neg_in_hid_25;
    assign hid_spikes[25] = (mem_hid_25 >= 10);
    wire signed [11:0] next_hid_25 = mem_hid_25 - (mem_hid_25 >>> 4) + sum_hid_25;

    reg signed [11:0] mem_hid_26;
    wire signed [11:0] pos_in_hid_26 = (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 1
        + (hid_spikes[1] | hid_spikes[17] | hid_spikes[39] | hid_spikes[45] | hid_spikes[55] | hid_spikes[65] | hid_spikes[67]) << 0
        + (hid_spikes[2] | hid_spikes[17] | hid_spikes[40] | hid_spikes[45] | hid_spikes[55] | hid_spikes[67] | hid_spikes[70] | hid_spikes[73]) << 1
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[20] | hid_spikes[39] | hid_spikes[42] | hid_spikes[43] | hid_spikes[73] | hid_spikes[76]) << 2
        + (hid_spikes[65] | hid_spikes[70]) << 3;
    wire signed [11:0] neg_in_hid_26 = (cochlea_spikes[1] | cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[4]) << 6
        + (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[0] | cochlea_spikes[2]) << 3
        + (cochlea_spikes[2]) << 5
        + (hid_spikes[4] | hid_spikes[8] | hid_spikes[9] | hid_spikes[11] | hid_spikes[12] | hid_spikes[13] | hid_spikes[15] | hid_spikes[16] | hid_spikes[18] | hid_spikes[19] | hid_spikes[21] | hid_spikes[23] | hid_spikes[24] | hid_spikes[27] | hid_spikes[34] | hid_spikes[37] | hid_spikes[38] | hid_spikes[47] | hid_spikes[49] | hid_spikes[51] | hid_spikes[62] | hid_spikes[69] | hid_spikes[75]) << 0
        + (hid_spikes[3] | hid_spikes[8] | hid_spikes[9] | hid_spikes[12] | hid_spikes[13] | hid_spikes[18] | hid_spikes[23] | hid_spikes[24] | hid_spikes[34] | hid_spikes[36] | hid_spikes[38] | hid_spikes[44] | hid_spikes[47] | hid_spikes[48] | hid_spikes[51] | hid_spikes[61] | hid_spikes[69] | hid_spikes[74] | hid_spikes[77] | hid_spikes[78] | hid_spikes[79]) << 1
        + (hid_spikes[3] | hid_spikes[4] | hid_spikes[5] | hid_spikes[8] | hid_spikes[11] | hid_spikes[15] | hid_spikes[19] | hid_spikes[24] | hid_spikes[25] | hid_spikes[27] | hid_spikes[34] | hid_spikes[44] | hid_spikes[47] | hid_spikes[51] | hid_spikes[53] | hid_spikes[54] | hid_spikes[58] | hid_spikes[61] | hid_spikes[62] | hid_spikes[72] | hid_spikes[74] | hid_spikes[77]) << 2
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[4] | hid_spikes[11] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[21] | hid_spikes[23] | hid_spikes[25] | hid_spikes[30] | hid_spikes[36] | hid_spikes[37] | hid_spikes[41] | hid_spikes[47] | hid_spikes[49] | hid_spikes[58] | hid_spikes[60] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78] | hid_spikes[79]) << 3
        + (hid_spikes[16] | hid_spikes[51] | hid_spikes[59] | hid_spikes[62] | hid_spikes[66] | hid_spikes[78] | hid_spikes[79]) << 4
        + (hid_spikes[11] | hid_spikes[54]) << 5;
    wire signed [11:0] sum_hid_26 = pos_in_hid_26 - neg_in_hid_26;
    assign hid_spikes[26] = (mem_hid_26 >= 10);
    wire signed [11:0] next_hid_26 = mem_hid_26 - (mem_hid_26 >>> 5) + sum_hid_26;

    reg signed [11:0] mem_hid_27;
    wire signed [11:0] pos_in_hid_27 = (cochlea_spikes[5]) << 3
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[8] | hid_spikes[31] | hid_spikes[33] | hid_spikes[44] | hid_spikes[55] | hid_spikes[57] | hid_spikes[72]) << 0
        + (hid_spikes[3] | hid_spikes[10] | hid_spikes[16] | hid_spikes[20] | hid_spikes[31] | hid_spikes[33] | hid_spikes[44] | hid_spikes[55] | hid_spikes[57]) << 1
        + (hid_spikes[8] | hid_spikes[10] | hid_spikes[16] | hid_spikes[17] | hid_spikes[20] | hid_spikes[33] | hid_spikes[57] | hid_spikes[69]) << 2
        + (hid_spikes[5] | hid_spikes[61] | hid_spikes[68] | hid_spikes[72]) << 3;
    wire signed [11:0] neg_in_hid_27 = (cochlea_spikes[4]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[2]) << 3
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[0]) << 3
        + (hid_spikes[1] | hid_spikes[6] | hid_spikes[12] | hid_spikes[24] | hid_spikes[29] | hid_spikes[30] | hid_spikes[34] | hid_spikes[35] | hid_spikes[38] | hid_spikes[39] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[48] | hid_spikes[53] | hid_spikes[54] | hid_spikes[59] | hid_spikes[60] | hid_spikes[62] | hid_spikes[64] | hid_spikes[66] | hid_spikes[70] | hid_spikes[75] | hid_spikes[76] | hid_spikes[79]) << 0
        + (hid_spikes[7] | hid_spikes[11] | hid_spikes[14] | hid_spikes[22] | hid_spikes[23] | hid_spikes[27] | hid_spikes[30] | hid_spikes[34] | hid_spikes[35] | hid_spikes[37] | hid_spikes[38] | hid_spikes[45] | hid_spikes[51] | hid_spikes[54] | hid_spikes[56] | hid_spikes[58] | hid_spikes[60] | hid_spikes[62] | hid_spikes[64] | hid_spikes[66] | hid_spikes[73] | hid_spikes[75] | hid_spikes[77] | hid_spikes[79]) << 1
        + (hid_spikes[1] | hid_spikes[4] | hid_spikes[6] | hid_spikes[7] | hid_spikes[11] | hid_spikes[12] | hid_spikes[13] | hid_spikes[14] | hid_spikes[22] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[29] | hid_spikes[30] | hid_spikes[34] | hid_spikes[36] | hid_spikes[37] | hid_spikes[42] | hid_spikes[45] | hid_spikes[48] | hid_spikes[53] | hid_spikes[54] | hid_spikes[59] | hid_spikes[62] | hid_spikes[63] | hid_spikes[64] | hid_spikes[66] | hid_spikes[67] | hid_spikes[73] | hid_spikes[76] | hid_spikes[77] | hid_spikes[79]) << 2
        + (hid_spikes[6] | hid_spikes[18] | hid_spikes[21] | hid_spikes[30] | hid_spikes[38] | hid_spikes[40] | hid_spikes[43] | hid_spikes[46] | hid_spikes[48] | hid_spikes[50] | hid_spikes[53] | hid_spikes[56] | hid_spikes[60] | hid_spikes[63] | hid_spikes[70]) << 3
        + (hid_spikes[0] | hid_spikes[28] | hid_spikes[39] | hid_spikes[49] | hid_spikes[65] | hid_spikes[75]) << 4;
    wire signed [11:0] sum_hid_27 = pos_in_hid_27 - neg_in_hid_27;
    assign hid_spikes[27] = (mem_hid_27 >= 10);
    wire signed [11:0] next_hid_27 = mem_hid_27 - (mem_hid_27 >>> 6) + sum_hid_27;

    reg signed [11:0] mem_hid_28;
    wire signed [11:0] pos_in_hid_28 = (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[4]) << 3
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0]) << 3
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[5] | hid_spikes[6] | hid_spikes[7] | hid_spikes[8] | hid_spikes[10] | hid_spikes[12] | hid_spikes[17] | hid_spikes[33] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[60] | hid_spikes[70]) << 0
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[7] | hid_spikes[12] | hid_spikes[29] | hid_spikes[33] | hid_spikes[44] | hid_spikes[48] | hid_spikes[70]) << 1
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[8] | hid_spikes[12] | hid_spikes[14] | hid_spikes[29] | hid_spikes[44] | hid_spikes[70]) << 2
        + (hid_spikes[5] | hid_spikes[10] | hid_spikes[17] | hid_spikes[47] | hid_spikes[49] | hid_spikes[60]) << 3;
    wire signed [11:0] neg_in_hid_28 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[1]) << 7
        + (cochlea_spikes[3] | cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (cochlea_spikes[3]) << 3
        + (hid_spikes[15] | hid_spikes[18] | hid_spikes[20] | hid_spikes[22] | hid_spikes[23] | hid_spikes[30] | hid_spikes[32] | hid_spikes[34] | hid_spikes[39] | hid_spikes[40] | hid_spikes[42] | hid_spikes[45] | hid_spikes[51] | hid_spikes[56] | hid_spikes[58] | hid_spikes[61] | hid_spikes[66] | hid_spikes[67] | hid_spikes[68] | hid_spikes[73] | hid_spikes[74] | hid_spikes[78] | hid_spikes[79]) << 0
        + (hid_spikes[13] | hid_spikes[15] | hid_spikes[20] | hid_spikes[21] | hid_spikes[26] | hid_spikes[30] | hid_spikes[34] | hid_spikes[40] | hid_spikes[51] | hid_spikes[53] | hid_spikes[56] | hid_spikes[57] | hid_spikes[58] | hid_spikes[61] | hid_spikes[66] | hid_spikes[67] | hid_spikes[71] | hid_spikes[73] | hid_spikes[74] | hid_spikes[78]) << 1
        + (hid_spikes[11] | hid_spikes[18] | hid_spikes[20] | hid_spikes[23] | hid_spikes[26] | hid_spikes[32] | hid_spikes[39] | hid_spikes[40] | hid_spikes[45] | hid_spikes[50] | hid_spikes[53] | hid_spikes[56] | hid_spikes[59] | hid_spikes[64] | hid_spikes[66] | hid_spikes[67] | hid_spikes[68] | hid_spikes[69] | hid_spikes[71] | hid_spikes[73] | hid_spikes[78] | hid_spikes[79]) << 2
        + (hid_spikes[11] | hid_spikes[22] | hid_spikes[30] | hid_spikes[38] | hid_spikes[40] | hid_spikes[42] | hid_spikes[56] | hid_spikes[67] | hid_spikes[68] | hid_spikes[71]) << 3
        + (hid_spikes[11] | hid_spikes[30] | hid_spikes[37] | hid_spikes[54] | hid_spikes[77]) << 4;
    wire signed [11:0] sum_hid_28 = pos_in_hid_28 - neg_in_hid_28;
    assign hid_spikes[28] = (mem_hid_28 >= 10);
    wire signed [11:0] next_hid_28 = mem_hid_28 - (mem_hid_28 >>> 4) + sum_hid_28;

    reg signed [11:0] mem_hid_29;
    wire signed [11:0] pos_in_hid_29 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 3
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[3] | hid_spikes[5] | hid_spikes[10] | hid_spikes[16] | hid_spikes[23] | hid_spikes[31] | hid_spikes[50] | hid_spikes[55] | hid_spikes[58] | hid_spikes[62] | hid_spikes[63] | hid_spikes[66] | hid_spikes[74] | hid_spikes[79]) << 0
        + (hid_spikes[5] | hid_spikes[17] | hid_spikes[25] | hid_spikes[26] | hid_spikes[31] | hid_spikes[46] | hid_spikes[50] | hid_spikes[52] | hid_spikes[55] | hid_spikes[56] | hid_spikes[59] | hid_spikes[62] | hid_spikes[63] | hid_spikes[64] | hid_spikes[66] | hid_spikes[72] | hid_spikes[79]) << 1
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[16] | hid_spikes[20] | hid_spikes[23] | hid_spikes[35] | hid_spikes[44] | hid_spikes[46] | hid_spikes[52] | hid_spikes[56] | hid_spikes[58] | hid_spikes[59] | hid_spikes[62] | hid_spikes[64] | hid_spikes[74]) << 2
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[10] | hid_spikes[17] | hid_spikes[51] | hid_spikes[55] | hid_spikes[56] | hid_spikes[72] | hid_spikes[77] | hid_spikes[79]) << 3;
    wire signed [11:0] neg_in_hid_29 = (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3] | cochlea_spikes[5]) << 1
        + (cochlea_spikes[5]) << 3
        + (cochlea_spikes[5]) << 4
        + (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0]) << 3
        + (hid_spikes[7] | hid_spikes[8] | hid_spikes[18] | hid_spikes[27] | hid_spikes[28] | hid_spikes[29] | hid_spikes[36] | hid_spikes[38] | hid_spikes[47] | hid_spikes[75]) << 0
        + (hid_spikes[9] | hid_spikes[11] | hid_spikes[18] | hid_spikes[19] | hid_spikes[21] | hid_spikes[27] | hid_spikes[38] | hid_spikes[42] | hid_spikes[47] | hid_spikes[67] | hid_spikes[70] | hid_spikes[75]) << 1
        + (hid_spikes[4] | hid_spikes[7] | hid_spikes[8] | hid_spikes[9] | hid_spikes[11] | hid_spikes[19] | hid_spikes[27] | hid_spikes[28] | hid_spikes[29] | hid_spikes[32] | hid_spikes[36] | hid_spikes[39] | hid_spikes[42] | hid_spikes[43] | hid_spikes[53] | hid_spikes[54] | hid_spikes[67]) << 2
        + (hid_spikes[4] | hid_spikes[13] | hid_spikes[29] | hid_spikes[30] | hid_spikes[43] | hid_spikes[45] | hid_spikes[47] | hid_spikes[75]) << 3
        + (hid_spikes[30] | hid_spikes[38] | hid_spikes[49]) << 4;
    wire signed [11:0] sum_hid_29 = pos_in_hid_29 - neg_in_hid_29;
    assign hid_spikes[29] = (mem_hid_29 >= 10);
    wire signed [11:0] next_hid_29 = mem_hid_29 - (mem_hid_29 >>> 4) + sum_hid_29;

    reg signed [11:0] mem_hid_30;
    wire signed [11:0] pos_in_hid_30 = (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[3]) << 2
        + (hid_spikes[8] | hid_spikes[9] | hid_spikes[46] | hid_spikes[48] | hid_spikes[74]) << 0
        + (hid_spikes[4] | hid_spikes[8] | hid_spikes[15] | hid_spikes[32] | hid_spikes[37] | hid_spikes[48] | hid_spikes[61]) << 1
        + (hid_spikes[9] | hid_spikes[12] | hid_spikes[30] | hid_spikes[37] | hid_spikes[46] | hid_spikes[74]) << 2
        + (hid_spikes[32]) << 3;
    wire signed [11:0] neg_in_hid_30 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0] | cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 2
        + (hid_spikes[6] | hid_spikes[11] | hid_spikes[13] | hid_spikes[18] | hid_spikes[21] | hid_spikes[23] | hid_spikes[28] | hid_spikes[29] | hid_spikes[31] | hid_spikes[39] | hid_spikes[40] | hid_spikes[49] | hid_spikes[53] | hid_spikes[55] | hid_spikes[56] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60] | hid_spikes[62] | hid_spikes[63] | hid_spikes[66] | hid_spikes[70] | hid_spikes[71] | hid_spikes[72] | hid_spikes[73] | hid_spikes[76]) << 0
        + (hid_spikes[6] | hid_spikes[10] | hid_spikes[11] | hid_spikes[13] | hid_spikes[16] | hid_spikes[18] | hid_spikes[22] | hid_spikes[23] | hid_spikes[28] | hid_spikes[29] | hid_spikes[31] | hid_spikes[39] | hid_spikes[40] | hid_spikes[45] | hid_spikes[49] | hid_spikes[50] | hid_spikes[52] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60] | hid_spikes[63] | hid_spikes[64] | hid_spikes[66] | hid_spikes[71] | hid_spikes[72] | hid_spikes[77]) << 1
        + (hid_spikes[0] | hid_spikes[6] | hid_spikes[14] | hid_spikes[16] | hid_spikes[18] | hid_spikes[19] | hid_spikes[21] | hid_spikes[22] | hid_spikes[28] | hid_spikes[40] | hid_spikes[43] | hid_spikes[45] | hid_spikes[53] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[60] | hid_spikes[64] | hid_spikes[66] | hid_spikes[68] | hid_spikes[69] | hid_spikes[70] | hid_spikes[71] | hid_spikes[75]) << 2
        + (hid_spikes[0] | hid_spikes[6] | hid_spikes[7] | hid_spikes[10] | hid_spikes[11] | hid_spikes[28] | hid_spikes[33] | hid_spikes[39] | hid_spikes[41] | hid_spikes[43] | hid_spikes[44] | hid_spikes[55] | hid_spikes[62] | hid_spikes[68] | hid_spikes[72] | hid_spikes[73] | hid_spikes[75] | hid_spikes[77]) << 3
        + (hid_spikes[76]) << 4;
    wire signed [11:0] sum_hid_30 = pos_in_hid_30 - neg_in_hid_30;
    assign hid_spikes[30] = (mem_hid_30 >= 10);
    wire signed [11:0] next_hid_30 = mem_hid_30 - (mem_hid_30 >>> 3) + sum_hid_30;

    reg signed [11:0] mem_hid_31;
    wire signed [11:0] pos_in_hid_31 = (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 3
        + (hid_spikes[0] | hid_spikes[5] | hid_spikes[6] | hid_spikes[7] | hid_spikes[10] | hid_spikes[14] | hid_spikes[16] | hid_spikes[21] | hid_spikes[26] | hid_spikes[39] | hid_spikes[44] | hid_spikes[55] | hid_spikes[60] | hid_spikes[72] | hid_spikes[77]) << 0
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[6] | hid_spikes[7] | hid_spikes[11] | hid_spikes[14] | hid_spikes[19] | hid_spikes[20] | hid_spikes[22] | hid_spikes[26] | hid_spikes[44] | hid_spikes[52] | hid_spikes[60] | hid_spikes[62] | hid_spikes[67] | hid_spikes[72] | hid_spikes[76] | hid_spikes[77]) << 1
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[10] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[20] | hid_spikes[21] | hid_spikes[22] | hid_spikes[44] | hid_spikes[52] | hid_spikes[67]) << 2
        + (hid_spikes[2] | hid_spikes[15] | hid_spikes[39] | hid_spikes[52] | hid_spikes[55] | hid_spikes[62] | hid_spikes[72] | hid_spikes[76]) << 3;
    wire signed [11:0] neg_in_hid_31 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0] | cochlea_spikes[3]) << 3
        + (cochlea_spikes[2]) << 4
        + (cochlea_spikes[2]) << 5
        + (cochlea_spikes[1] | cochlea_spikes[4]) << 0
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[4]) << 4
        + (cochlea_spikes[4]) << 5
        + (hid_spikes[1] | hid_spikes[4] | hid_spikes[8] | hid_spikes[12] | hid_spikes[18] | hid_spikes[30] | hid_spikes[36] | hid_spikes[38] | hid_spikes[41] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[47] | hid_spikes[51] | hid_spikes[75] | hid_spikes[79]) << 0
        + (hid_spikes[1] | hid_spikes[8] | hid_spikes[13] | hid_spikes[27] | hid_spikes[36] | hid_spikes[37] | hid_spikes[41] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[47] | hid_spikes[48] | hid_spikes[58] | hid_spikes[64] | hid_spikes[65] | hid_spikes[66] | hid_spikes[69] | hid_spikes[75]) << 1
        + (hid_spikes[1] | hid_spikes[4] | hid_spikes[8] | hid_spikes[9] | hid_spikes[12] | hid_spikes[13] | hid_spikes[17] | hid_spikes[24] | hid_spikes[27] | hid_spikes[37] | hid_spikes[38] | hid_spikes[42] | hid_spikes[45] | hid_spikes[46] | hid_spikes[50] | hid_spikes[51] | hid_spikes[53] | hid_spikes[65] | hid_spikes[66] | hid_spikes[69] | hid_spikes[78]) << 2
        + (hid_spikes[4] | hid_spikes[9] | hid_spikes[17] | hid_spikes[18] | hid_spikes[30] | hid_spikes[36] | hid_spikes[37] | hid_spikes[41] | hid_spikes[48] | hid_spikes[53] | hid_spikes[59] | hid_spikes[61] | hid_spikes[69] | hid_spikes[79]) << 3
        + (hid_spikes[30] | hid_spikes[38] | hid_spikes[49]) << 4
        + (hid_spikes[64] | hid_spikes[73]) << 5;
    wire signed [11:0] sum_hid_31 = pos_in_hid_31 - neg_in_hid_31;
    assign hid_spikes[31] = (mem_hid_31 >= 10);
    wire signed [11:0] next_hid_31 = mem_hid_31 - (mem_hid_31 >>> 4) + sum_hid_31;

    reg signed [11:0] mem_hid_32;
    wire signed [11:0] pos_in_hid_32 = (cochlea_spikes[2]) << 2
        + (hid_spikes[15] | hid_spikes[18] | hid_spikes[24] | hid_spikes[25] | hid_spikes[31] | hid_spikes[75] | hid_spikes[76] | hid_spikes[79]) << 0
        + (hid_spikes[15] | hid_spikes[18] | hid_spikes[25] | hid_spikes[51] | hid_spikes[66] | hid_spikes[69]) << 1
        + (hid_spikes[18] | hid_spikes[22] | hid_spikes[24] | hid_spikes[25] | hid_spikes[31] | hid_spikes[66] | hid_spikes[75] | hid_spikes[76] | hid_spikes[79]) << 2
        + (hid_spikes[17] | hid_spikes[35] | hid_spikes[57] | hid_spikes[62] | hid_spikes[69] | hid_spikes[72]) << 3
        + (hid_spikes[59]) << 4;
    wire signed [11:0] neg_in_hid_32 = (cochlea_spikes[0] | cochlea_spikes[1]) << 0
        + (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0] | cochlea_spikes[1]) << 2
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[0]) << 5
        + (cochlea_spikes[3]) << 1
        + (cochlea_spikes[3] | cochlea_spikes[4]) << 2
        + (cochlea_spikes[4] | cochlea_spikes[5]) << 3
        + (cochlea_spikes[4]) << 4
        + (hid_spikes[7] | hid_spikes[10] | hid_spikes[12] | hid_spikes[26] | hid_spikes[33] | hid_spikes[39] | hid_spikes[41] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[55] | hid_spikes[60] | hid_spikes[63] | hid_spikes[67]) << 0
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[7] | hid_spikes[12] | hid_spikes[20] | hid_spikes[26] | hid_spikes[30] | hid_spikes[33] | hid_spikes[39] | hid_spikes[42] | hid_spikes[55] | hid_spikes[60] | hid_spikes[63] | hid_spikes[78]) << 1
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[6] | hid_spikes[7] | hid_spikes[10] | hid_spikes[19] | hid_spikes[20] | hid_spikes[21] | hid_spikes[27] | hid_spikes[29] | hid_spikes[30] | hid_spikes[34] | hid_spikes[39] | hid_spikes[41] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[67] | hid_spikes[77]) << 2
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[20] | hid_spikes[21] | hid_spikes[26] | hid_spikes[28] | hid_spikes[44] | hid_spikes[64] | hid_spikes[71] | hid_spikes[77]) << 3
        + (hid_spikes[53] | hid_spikes[67]) << 4
        + (hid_spikes[64]) << 5;
    wire signed [11:0] sum_hid_32 = pos_in_hid_32 - neg_in_hid_32;
    assign hid_spikes[32] = (mem_hid_32 >= 10);
    wire signed [11:0] next_hid_32 = mem_hid_32 - (mem_hid_32 >>> 4) + sum_hid_32;

    reg signed [11:0] mem_hid_33;
    wire signed [11:0] pos_in_hid_33 = (hid_spikes[2] | hid_spikes[4] | hid_spikes[10] | hid_spikes[14] | hid_spikes[16] | hid_spikes[20] | hid_spikes[22] | hid_spikes[33] | hid_spikes[46] | hid_spikes[49]) << 0
        + (hid_spikes[2] | hid_spikes[4] | hid_spikes[10] | hid_spikes[19] | hid_spikes[22] | hid_spikes[33] | hid_spikes[35] | hid_spikes[46] | hid_spikes[52] | hid_spikes[54] | hid_spikes[61] | hid_spikes[62]) << 1
        + (hid_spikes[0] | hid_spikes[6] | hid_spikes[10] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[36] | hid_spikes[42] | hid_spikes[45] | hid_spikes[46] | hid_spikes[49] | hid_spikes[52] | hid_spikes[54] | hid_spikes[62]) << 2
        + (hid_spikes[6] | hid_spikes[16] | hid_spikes[20] | hid_spikes[31] | hid_spikes[72] | hid_spikes[79]) << 3;
    wire signed [11:0] neg_in_hid_33 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[1] | cochlea_spikes[2]) << 3
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[2] | cochlea_spikes[5]) << 5
        + (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0] | cochlea_spikes[4]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0] | cochlea_spikes[3]) << 3
        + (cochlea_spikes[0]) << 4
        + (cochlea_spikes[4]) << 5
        + (hid_spikes[1] | hid_spikes[7] | hid_spikes[8] | hid_spikes[11] | hid_spikes[26] | hid_spikes[30] | hid_spikes[41] | hid_spikes[43] | hid_spikes[48] | hid_spikes[53] | hid_spikes[58] | hid_spikes[64] | hid_spikes[65] | hid_spikes[67] | hid_spikes[73] | hid_spikes[78]) << 0
        + (hid_spikes[5] | hid_spikes[7] | hid_spikes[8] | hid_spikes[11] | hid_spikes[30] | hid_spikes[32] | hid_spikes[39] | hid_spikes[40] | hid_spikes[44] | hid_spikes[53] | hid_spikes[56] | hid_spikes[57] | hid_spikes[58] | hid_spikes[59] | hid_spikes[63] | hid_spikes[67] | hid_spikes[68] | hid_spikes[70] | hid_spikes[71] | hid_spikes[73]) << 1
        + (hid_spikes[1] | hid_spikes[5] | hid_spikes[12] | hid_spikes[23] | hid_spikes[26] | hid_spikes[32] | hid_spikes[34] | hid_spikes[37] | hid_spikes[40] | hid_spikes[43] | hid_spikes[47] | hid_spikes[48] | hid_spikes[56] | hid_spikes[57] | hid_spikes[64] | hid_spikes[67] | hid_spikes[68] | hid_spikes[75] | hid_spikes[78]) << 2
        + (hid_spikes[9] | hid_spikes[41] | hid_spikes[59] | hid_spikes[67] | hid_spikes[70] | hid_spikes[73]) << 3
        + (hid_spikes[28] | hid_spikes[39] | hid_spikes[65]) << 4;
    wire signed [11:0] sum_hid_33 = pos_in_hid_33 - neg_in_hid_33;
    assign hid_spikes[33] = (mem_hid_33 >= 10);
    wire signed [11:0] next_hid_33 = mem_hid_33 - (mem_hid_33 >>> 4) + sum_hid_33;

    reg signed [11:0] mem_hid_34;
    wire signed [11:0] pos_in_hid_34 = (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 2
        + (hid_spikes[3] | hid_spikes[10] | hid_spikes[16] | hid_spikes[19] | hid_spikes[23] | hid_spikes[44] | hid_spikes[51] | hid_spikes[59] | hid_spikes[60] | hid_spikes[61] | hid_spikes[62] | hid_spikes[66]) << 0
        + (hid_spikes[14] | hid_spikes[16] | hid_spikes[22] | hid_spikes[23] | hid_spikes[31] | hid_spikes[51] | hid_spikes[58] | hid_spikes[59] | hid_spikes[60] | hid_spikes[61] | hid_spikes[64] | hid_spikes[66]) << 1
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[10] | hid_spikes[19] | hid_spikes[26] | hid_spikes[31] | hid_spikes[38] | hid_spikes[51] | hid_spikes[62] | hid_spikes[64] | hid_spikes[66] | hid_spikes[69]) << 2
        + (hid_spikes[14] | hid_spikes[15] | hid_spikes[26] | hid_spikes[31] | hid_spikes[44]) << 3;
    wire signed [11:0] neg_in_hid_34 = (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 3
        + (cochlea_spikes[2] | cochlea_spikes[4]) << 4
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (cochlea_spikes[0] | cochlea_spikes[5]) << 3
        + (cochlea_spikes[0]) << 4
        + (hid_spikes[2] | hid_spikes[12] | hid_spikes[20] | hid_spikes[28] | hid_spikes[29] | hid_spikes[34] | hid_spikes[35] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[47] | hid_spikes[52] | hid_spikes[54] | hid_spikes[57] | hid_spikes[68] | hid_spikes[74] | hid_spikes[77]) << 0
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[5] | hid_spikes[8] | hid_spikes[11] | hid_spikes[12] | hid_spikes[18] | hid_spikes[20] | hid_spikes[21] | hid_spikes[25] | hid_spikes[27] | hid_spikes[29] | hid_spikes[30] | hid_spikes[37] | hid_spikes[40] | hid_spikes[43] | hid_spikes[45] | hid_spikes[47] | hid_spikes[54] | hid_spikes[67] | hid_spikes[70] | hid_spikes[71] | hid_spikes[74] | hid_spikes[76] | hid_spikes[78] | hid_spikes[79]) << 1
        + (hid_spikes[5] | hid_spikes[7] | hid_spikes[11] | hid_spikes[13] | hid_spikes[20] | hid_spikes[25] | hid_spikes[27] | hid_spikes[28] | hid_spikes[30] | hid_spikes[34] | hid_spikes[35] | hid_spikes[37] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[52] | hid_spikes[54] | hid_spikes[57] | hid_spikes[68] | hid_spikes[75] | hid_spikes[76] | hid_spikes[77] | hid_spikes[78] | hid_spikes[79]) << 2
        + (hid_spikes[1] | hid_spikes[4] | hid_spikes[7] | hid_spikes[18] | hid_spikes[21] | hid_spikes[36] | hid_spikes[46] | hid_spikes[67] | hid_spikes[70] | hid_spikes[74] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 3;
    wire signed [11:0] sum_hid_34 = pos_in_hid_34 - neg_in_hid_34;
    assign hid_spikes[34] = (mem_hid_34 >= 10);
    wire signed [11:0] next_hid_34 = mem_hid_34 - (mem_hid_34 >>> 6) + sum_hid_34;

    reg signed [11:0] mem_hid_35;
    wire signed [11:0] pos_in_hid_35 = (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 2
        + (hid_spikes[1] | hid_spikes[14] | hid_spikes[22] | hid_spikes[23] | hid_spikes[26] | hid_spikes[38] | hid_spikes[42] | hid_spikes[47] | hid_spikes[53] | hid_spikes[60] | hid_spikes[67] | hid_spikes[69]) << 0
        + (hid_spikes[1] | hid_spikes[23] | hid_spikes[38] | hid_spikes[45] | hid_spikes[47] | hid_spikes[53] | hid_spikes[60] | hid_spikes[63] | hid_spikes[64] | hid_spikes[65] | hid_spikes[67] | hid_spikes[69] | hid_spikes[71] | hid_spikes[74]) << 1
        + (hid_spikes[1] | hid_spikes[14] | hid_spikes[22] | hid_spikes[39] | hid_spikes[45] | hid_spikes[46] | hid_spikes[47] | hid_spikes[60] | hid_spikes[65] | hid_spikes[69] | hid_spikes[71]) << 2
        + (hid_spikes[10] | hid_spikes[26] | hid_spikes[42] | hid_spikes[63] | hid_spikes[64]) << 3
        + (hid_spikes[67]) << 4;
    wire signed [11:0] neg_in_hid_35 = (cochlea_spikes[3]) << 0
        + (cochlea_spikes[2] | cochlea_spikes[3]) << 1
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 2
        + (hid_spikes[3] | hid_spikes[4] | hid_spikes[5] | hid_spikes[18] | hid_spikes[21] | hid_spikes[30] | hid_spikes[31] | hid_spikes[34] | hid_spikes[36] | hid_spikes[40] | hid_spikes[49] | hid_spikes[52] | hid_spikes[55] | hid_spikes[57] | hid_spikes[61] | hid_spikes[62] | hid_spikes[72] | hid_spikes[73]) << 0
        + (hid_spikes[2] | hid_spikes[3] | hid_spikes[5] | hid_spikes[18] | hid_spikes[24] | hid_spikes[27] | hid_spikes[28] | hid_spikes[34] | hid_spikes[36] | hid_spikes[49] | hid_spikes[57]) << 1
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[4] | hid_spikes[11] | hid_spikes[19] | hid_spikes[30] | hid_spikes[31] | hid_spikes[40] | hid_spikes[55] | hid_spikes[57] | hid_spikes[72] | hid_spikes[78]) << 2
        + (hid_spikes[11] | hid_spikes[13] | hid_spikes[18] | hid_spikes[21] | hid_spikes[24] | hid_spikes[27] | hid_spikes[28] | hid_spikes[30] | hid_spikes[33] | hid_spikes[37] | hid_spikes[52] | hid_spikes[61] | hid_spikes[62] | hid_spikes[68] | hid_spikes[72] | hid_spikes[73] | hid_spikes[78]) << 3
        + (hid_spikes[19]) << 4;
    wire signed [11:0] sum_hid_35 = pos_in_hid_35 - neg_in_hid_35;
    assign hid_spikes[35] = (mem_hid_35 >= 10);
    wire signed [11:0] next_hid_35 = mem_hid_35 - (mem_hid_35 >>> 6) + sum_hid_35;

    reg signed [11:0] mem_hid_36;
    wire signed [11:0] pos_in_hid_36 = (cochlea_spikes[5]) << 1
        + (cochlea_spikes[5]) << 2
        + (hid_spikes[17] | hid_spikes[30] | hid_spikes[44] | hid_spikes[47] | hid_spikes[62] | hid_spikes[64]) << 0
        + (hid_spikes[17] | hid_spikes[20] | hid_spikes[22] | hid_spikes[25] | hid_spikes[44] | hid_spikes[47] | hid_spikes[61] | hid_spikes[69]) << 1
        + (hid_spikes[16] | hid_spikes[20] | hid_spikes[22] | hid_spikes[25] | hid_spikes[33] | hid_spikes[55] | hid_spikes[64] | hid_spikes[72]) << 2
        + (hid_spikes[30] | hid_spikes[33] | hid_spikes[47] | hid_spikes[54] | hid_spikes[74]) << 3
        + (hid_spikes[62]) << 4;
    wire signed [11:0] neg_in_hid_36 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[2]) << 5
        + (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[1]) << 5
        + (hid_spikes[9] | hid_spikes[11] | hid_spikes[18] | hid_spikes[24] | hid_spikes[32] | hid_spikes[39] | hid_spikes[40] | hid_spikes[42] | hid_spikes[48] | hid_spikes[49] | hid_spikes[51] | hid_spikes[58] | hid_spikes[65] | hid_spikes[66] | hid_spikes[71] | hid_spikes[75]) << 0
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[9] | hid_spikes[10] | hid_spikes[11] | hid_spikes[12] | hid_spikes[13] | hid_spikes[21] | hid_spikes[23] | hid_spikes[32] | hid_spikes[39] | hid_spikes[43] | hid_spikes[48] | hid_spikes[49] | hid_spikes[58] | hid_spikes[65] | hid_spikes[66] | hid_spikes[71] | hid_spikes[73] | hid_spikes[75]) << 1
        + (hid_spikes[1] | hid_spikes[6] | hid_spikes[8] | hid_spikes[13] | hid_spikes[18] | hid_spikes[21] | hid_spikes[29] | hid_spikes[31] | hid_spikes[32] | hid_spikes[37] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[46] | hid_spikes[48] | hid_spikes[53] | hid_spikes[57] | hid_spikes[67] | hid_spikes[68] | hid_spikes[75]) << 2
        + (hid_spikes[9] | hid_spikes[11] | hid_spikes[13] | hid_spikes[24] | hid_spikes[39] | hid_spikes[43] | hid_spikes[45] | hid_spikes[51] | hid_spikes[65] | hid_spikes[73]) << 3
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[67]) << 4;
    wire signed [11:0] sum_hid_36 = pos_in_hid_36 - neg_in_hid_36;
    assign hid_spikes[36] = (mem_hid_36 >= 10);
    wire signed [11:0] next_hid_36 = mem_hid_36 - (mem_hid_36 >>> 3) + sum_hid_36;

    reg signed [11:0] mem_hid_37;
    wire signed [11:0] pos_in_hid_37 = (cochlea_spikes[3]) << 2
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[9] | hid_spikes[34] | hid_spikes[51] | hid_spikes[57] | hid_spikes[64] | hid_spikes[74] | hid_spikes[79]) << 0
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[27] | hid_spikes[57] | hid_spikes[60]) << 1
        + (hid_spikes[9] | hid_spikes[21] | hid_spikes[51] | hid_spikes[64] | hid_spikes[69]) << 2
        + (hid_spikes[1] | hid_spikes[9] | hid_spikes[18] | hid_spikes[21] | hid_spikes[32] | hid_spikes[34] | hid_spikes[54] | hid_spikes[74] | hid_spikes[79]) << 3;
    wire signed [11:0] neg_in_hid_37 = (cochlea_spikes[0] | cochlea_spikes[5]) << 0
        + (cochlea_spikes[1] | cochlea_spikes[5]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[0] | cochlea_spikes[5]) << 4
        + (cochlea_spikes[2] | cochlea_spikes[4]) << 0
        + (cochlea_spikes[2] | cochlea_spikes[4]) << 1
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[2]) << 4
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[13] | hid_spikes[16] | hid_spikes[17] | hid_spikes[22] | hid_spikes[24] | hid_spikes[31] | hid_spikes[33] | hid_spikes[38] | hid_spikes[39] | hid_spikes[46] | hid_spikes[59] | hid_spikes[62] | hid_spikes[63] | hid_spikes[67] | hid_spikes[77] | hid_spikes[78]) << 0
        + (hid_spikes[3] | hid_spikes[4] | hid_spikes[5] | hid_spikes[13] | hid_spikes[22] | hid_spikes[24] | hid_spikes[30] | hid_spikes[31] | hid_spikes[33] | hid_spikes[35] | hid_spikes[43] | hid_spikes[59] | hid_spikes[62] | hid_spikes[65] | hid_spikes[66] | hid_spikes[67] | hid_spikes[75]) << 1
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[12] | hid_spikes[22] | hid_spikes[25] | hid_spikes[30] | hid_spikes[33] | hid_spikes[35] | hid_spikes[39] | hid_spikes[46] | hid_spikes[55] | hid_spikes[63] | hid_spikes[66] | hid_spikes[73] | hid_spikes[76] | hid_spikes[77] | hid_spikes[78]) << 2
        + (hid_spikes[4] | hid_spikes[6] | hid_spikes[16] | hid_spikes[17] | hid_spikes[30] | hid_spikes[38] | hid_spikes[49] | hid_spikes[52] | hid_spikes[58] | hid_spikes[65] | hid_spikes[67] | hid_spikes[73] | hid_spikes[76]) << 3
        + (hid_spikes[26] | hid_spikes[42] | hid_spikes[43] | hid_spikes[71]) << 4;
    wire signed [11:0] sum_hid_37 = pos_in_hid_37 - neg_in_hid_37;
    assign hid_spikes[37] = (mem_hid_37 >= 10);
    wire signed [11:0] next_hid_37 = mem_hid_37 - (mem_hid_37 >>> 6) + sum_hid_37;

    reg signed [11:0] mem_hid_38;
    wire signed [11:0] pos_in_hid_38 = (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (hid_spikes[11] | hid_spikes[64] | hid_spikes[68] | hid_spikes[71]) << 0
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[38] | hid_spikes[44] | hid_spikes[47] | hid_spikes[51] | hid_spikes[60] | hid_spikes[68]) << 1
        + (hid_spikes[6] | hid_spikes[11] | hid_spikes[38] | hid_spikes[60] | hid_spikes[64] | hid_spikes[71] | hid_spikes[74]) << 2
        + (hid_spikes[5]) << 3;
    wire signed [11:0] neg_in_hid_38 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[2]) << 3
        + (cochlea_spikes[4]) << 6
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[1]) << 5
        + (hid_spikes[4] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[18] | hid_spikes[19] | hid_spikes[34] | hid_spikes[35] | hid_spikes[36] | hid_spikes[39] | hid_spikes[43] | hid_spikes[46] | hid_spikes[48] | hid_spikes[49] | hid_spikes[53] | hid_spikes[54] | hid_spikes[58] | hid_spikes[59] | hid_spikes[63] | hid_spikes[67] | hid_spikes[77]) << 0
        + (hid_spikes[4] | hid_spikes[9] | hid_spikes[10] | hid_spikes[13] | hid_spikes[15] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[23] | hid_spikes[24] | hid_spikes[30] | hid_spikes[35] | hid_spikes[36] | hid_spikes[37] | hid_spikes[39] | hid_spikes[42] | hid_spikes[46] | hid_spikes[50] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[58] | hid_spikes[59] | hid_spikes[62] | hid_spikes[65] | hid_spikes[67] | hid_spikes[73] | hid_spikes[75] | hid_spikes[76] | hid_spikes[78]) << 1
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[4] | hid_spikes[7] | hid_spikes[9] | hid_spikes[15] | hid_spikes[16] | hid_spikes[23] | hid_spikes[26] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[32] | hid_spikes[36] | hid_spikes[37] | hid_spikes[39] | hid_spikes[43] | hid_spikes[45] | hid_spikes[48] | hid_spikes[52] | hid_spikes[54] | hid_spikes[55] | hid_spikes[58] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63] | hid_spikes[65] | hid_spikes[66] | hid_spikes[67] | hid_spikes[72] | hid_spikes[76] | hid_spikes[77] | hid_spikes[78]) << 2
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[4] | hid_spikes[14] | hid_spikes[16] | hid_spikes[18] | hid_spikes[19] | hid_spikes[24] | hid_spikes[34] | hid_spikes[35] | hid_spikes[43] | hid_spikes[49] | hid_spikes[50] | hid_spikes[54] | hid_spikes[59] | hid_spikes[66] | hid_spikes[72] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 3
        + (hid_spikes[1] | hid_spikes[14]) << 4;
    wire signed [11:0] sum_hid_38 = pos_in_hid_38 - neg_in_hid_38;
    assign hid_spikes[38] = (mem_hid_38 >= 10);
    wire signed [11:0] next_hid_38 = mem_hid_38 - (mem_hid_38 >>> 6) + sum_hid_38;

    reg signed [11:0] mem_hid_39;
    wire signed [11:0] pos_in_hid_39 = (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 3
        + (hid_spikes[2] | hid_spikes[16] | hid_spikes[29]) << 0
        + (hid_spikes[16] | hid_spikes[29] | hid_spikes[31] | hid_spikes[34]) << 1
        + (hid_spikes[2] | hid_spikes[31]) << 2
        + (hid_spikes[28] | hid_spikes[29] | hid_spikes[75]) << 3;
    wire signed [11:0] neg_in_hid_39 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2] | cochlea_spikes[5]) << 2
        + (cochlea_spikes[2]) << 3
        + (cochlea_spikes[2]) << 5
        + (cochlea_spikes[4]) << 0
        + (cochlea_spikes[1] | cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[1] | cochlea_spikes[4]) << 3
        + (cochlea_spikes[4]) << 4
        + (cochlea_spikes[1]) << 5
        + (hid_spikes[1] | hid_spikes[6] | hid_spikes[7] | hid_spikes[8] | hid_spikes[11] | hid_spikes[12] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[17] | hid_spikes[19] | hid_spikes[21] | hid_spikes[22] | hid_spikes[26] | hid_spikes[27] | hid_spikes[42] | hid_spikes[44] | hid_spikes[49] | hid_spikes[50] | hid_spikes[55] | hid_spikes[56] | hid_spikes[57] | hid_spikes[58] | hid_spikes[59] | hid_spikes[60] | hid_spikes[64] | hid_spikes[66] | hid_spikes[67] | hid_spikes[70] | hid_spikes[71] | hid_spikes[73] | hid_spikes[74] | hid_spikes[76] | hid_spikes[77] | hid_spikes[79]) << 0
        + (hid_spikes[3] | hid_spikes[6] | hid_spikes[8] | hid_spikes[11] | hid_spikes[12] | hid_spikes[13] | hid_spikes[15] | hid_spikes[17] | hid_spikes[19] | hid_spikes[20] | hid_spikes[22] | hid_spikes[25] | hid_spikes[27] | hid_spikes[38] | hid_spikes[40] | hid_spikes[48] | hid_spikes[51] | hid_spikes[60] | hid_spikes[62] | hid_spikes[64] | hid_spikes[66] | hid_spikes[67] | hid_spikes[70] | hid_spikes[73] | hid_spikes[74] | hid_spikes[76] | hid_spikes[78] | hid_spikes[79]) << 1
        + (hid_spikes[7] | hid_spikes[9] | hid_spikes[11] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[20] | hid_spikes[26] | hid_spikes[27] | hid_spikes[37] | hid_spikes[38] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[49] | hid_spikes[50] | hid_spikes[53] | hid_spikes[55] | hid_spikes[56] | hid_spikes[57] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63] | hid_spikes[64] | hid_spikes[71] | hid_spikes[72] | hid_spikes[73] | hid_spikes[76] | hid_spikes[77] | hid_spikes[78]) << 2
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[6] | hid_spikes[9] | hid_spikes[15] | hid_spikes[17] | hid_spikes[20] | hid_spikes[21] | hid_spikes[22] | hid_spikes[24] | hid_spikes[38] | hid_spikes[42] | hid_spikes[44] | hid_spikes[47] | hid_spikes[50] | hid_spikes[53] | hid_spikes[54] | hid_spikes[56] | hid_spikes[58] | hid_spikes[59] | hid_spikes[61] | hid_spikes[64] | hid_spikes[65] | hid_spikes[66]) << 3
        + (hid_spikes[0] | hid_spikes[4] | hid_spikes[30] | hid_spikes[36] | hid_spikes[59] | hid_spikes[78]) << 4;
    wire signed [11:0] sum_hid_39 = pos_in_hid_39 - neg_in_hid_39;
    assign hid_spikes[39] = (mem_hid_39 >= 10);
    wire signed [11:0] next_hid_39 = mem_hid_39 - (mem_hid_39 >>> 6) + sum_hid_39;

    reg signed [11:0] mem_hid_40;
    wire signed [11:0] pos_in_hid_40 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 2
        + (hid_spikes[17] | hid_spikes[18] | hid_spikes[47] | hid_spikes[53] | hid_spikes[57] | hid_spikes[64] | hid_spikes[76] | hid_spikes[79]) << 0
        + (hid_spikes[8] | hid_spikes[17] | hid_spikes[18] | hid_spikes[47] | hid_spikes[53] | hid_spikes[57] | hid_spikes[64]) << 1
        + (hid_spikes[19] | hid_spikes[33] | hid_spikes[47] | hid_spikes[57] | hid_spikes[72] | hid_spikes[76] | hid_spikes[79]) << 2
        + (hid_spikes[1] | hid_spikes[8]) << 3;
    wire signed [11:0] neg_in_hid_40 = (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[4]) << 3
        + (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 1
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[9] | hid_spikes[10] | hid_spikes[26] | hid_spikes[27] | hid_spikes[30] | hid_spikes[32] | hid_spikes[35] | hid_spikes[36] | hid_spikes[37] | hid_spikes[39] | hid_spikes[41] | hid_spikes[42] | hid_spikes[45] | hid_spikes[46] | hid_spikes[50] | hid_spikes[52] | hid_spikes[54] | hid_spikes[60] | hid_spikes[62] | hid_spikes[66] | hid_spikes[68] | hid_spikes[75] | hid_spikes[78]) << 0
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[6] | hid_spikes[10] | hid_spikes[13] | hid_spikes[21] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[30] | hid_spikes[32] | hid_spikes[37] | hid_spikes[40] | hid_spikes[41] | hid_spikes[42] | hid_spikes[44] | hid_spikes[46] | hid_spikes[48] | hid_spikes[52] | hid_spikes[58] | hid_spikes[60] | hid_spikes[61] | hid_spikes[62] | hid_spikes[67] | hid_spikes[68] | hid_spikes[71] | hid_spikes[73] | hid_spikes[77]) << 1
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[7] | hid_spikes[13] | hid_spikes[23] | hid_spikes[27] | hid_spikes[29] | hid_spikes[38] | hid_spikes[44] | hid_spikes[45] | hid_spikes[48] | hid_spikes[56] | hid_spikes[58] | hid_spikes[60] | hid_spikes[73] | hid_spikes[74] | hid_spikes[75]) << 2
        + (hid_spikes[0] | hid_spikes[5] | hid_spikes[6] | hid_spikes[7] | hid_spikes[15] | hid_spikes[30] | hid_spikes[34] | hid_spikes[35] | hid_spikes[39] | hid_spikes[42] | hid_spikes[43] | hid_spikes[46] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[56] | hid_spikes[59] | hid_spikes[66] | hid_spikes[67] | hid_spikes[71] | hid_spikes[77] | hid_spikes[78]) << 3
        + (hid_spikes[9] | hid_spikes[20] | hid_spikes[36] | hid_spikes[38] | hid_spikes[40] | hid_spikes[54] | hid_spikes[61] | hid_spikes[62] | hid_spikes[65]) << 4;
    wire signed [11:0] sum_hid_40 = pos_in_hid_40 - neg_in_hid_40;
    assign hid_spikes[40] = (mem_hid_40 >= 10);
    wire signed [11:0] next_hid_40 = mem_hid_40 - (mem_hid_40 >>> 3) + sum_hid_40;

    reg signed [11:0] mem_hid_41;
    wire signed [11:0] pos_in_hid_41 = (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[2]) << 2
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[19] | hid_spikes[25] | hid_spikes[31] | hid_spikes[32] | hid_spikes[33] | hid_spikes[45] | hid_spikes[71] | hid_spikes[72] | hid_spikes[79]) << 0
        + (hid_spikes[0] | hid_spikes[7] | hid_spikes[14] | hid_spikes[16] | hid_spikes[19] | hid_spikes[25] | hid_spikes[28] | hid_spikes[29] | hid_spikes[31] | hid_spikes[32] | hid_spikes[39] | hid_spikes[41] | hid_spikes[44] | hid_spikes[51] | hid_spikes[69] | hid_spikes[71]) << 1
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[2] | hid_spikes[13] | hid_spikes[19] | hid_spikes[25] | hid_spikes[29] | hid_spikes[33] | hid_spikes[41] | hid_spikes[44] | hid_spikes[45] | hid_spikes[51] | hid_spikes[69] | hid_spikes[72] | hid_spikes[74] | hid_spikes[75] | hid_spikes[76] | hid_spikes[79]) << 2
        + (hid_spikes[0] | hid_spikes[16] | hid_spikes[19] | hid_spikes[25] | hid_spikes[28] | hid_spikes[39] | hid_spikes[55]) << 3
        + (hid_spikes[62] | hid_spikes[72]) << 4;
    wire signed [11:0] neg_in_hid_41 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[1]) << 5
        + (cochlea_spikes[1]) << 6
        + (cochlea_spikes[4]) << 0
        + (cochlea_spikes[3] | cochlea_spikes[4]) << 1
        + (cochlea_spikes[3]) << 2
        + (cochlea_spikes[4]) << 5
        + (hid_spikes[11] | hid_spikes[12] | hid_spikes[17] | hid_spikes[20] | hid_spikes[26] | hid_spikes[27] | hid_spikes[30] | hid_spikes[34] | hid_spikes[36] | hid_spikes[38] | hid_spikes[43] | hid_spikes[46] | hid_spikes[50] | hid_spikes[54] | hid_spikes[64] | hid_spikes[66] | hid_spikes[67] | hid_spikes[77]) << 0
        + (hid_spikes[11] | hid_spikes[17] | hid_spikes[20] | hid_spikes[21] | hid_spikes[26] | hid_spikes[34] | hid_spikes[36] | hid_spikes[42] | hid_spikes[46] | hid_spikes[53] | hid_spikes[56] | hid_spikes[64] | hid_spikes[66]) << 1
        + (hid_spikes[9] | hid_spikes[12] | hid_spikes[17] | hid_spikes[20] | hid_spikes[21] | hid_spikes[22] | hid_spikes[30] | hid_spikes[37] | hid_spikes[40] | hid_spikes[43] | hid_spikes[53] | hid_spikes[54] | hid_spikes[64] | hid_spikes[66] | hid_spikes[78]) << 2
        + (hid_spikes[9] | hid_spikes[12] | hid_spikes[18] | hid_spikes[26] | hid_spikes[27] | hid_spikes[30] | hid_spikes[36] | hid_spikes[38] | hid_spikes[42] | hid_spikes[46] | hid_spikes[50] | hid_spikes[56] | hid_spikes[67] | hid_spikes[77]) << 3
        + (hid_spikes[43] | hid_spikes[54] | hid_spikes[64] | hid_spikes[67]) << 4;
    wire signed [11:0] sum_hid_41 = pos_in_hid_41 - neg_in_hid_41;
    assign hid_spikes[41] = (mem_hid_41 >= 10);
    wire signed [11:0] next_hid_41 = mem_hid_41 - (mem_hid_41 >>> 6) + sum_hid_41;

    reg signed [11:0] mem_hid_42;
    wire signed [11:0] pos_in_hid_42 = (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 1
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[17] | hid_spikes[31] | hid_spikes[32] | hid_spikes[65] | hid_spikes[68] | hid_spikes[72] | hid_spikes[73]) << 0
        + (hid_spikes[0] | hid_spikes[6] | hid_spikes[12] | hid_spikes[32] | hid_spikes[41] | hid_spikes[68] | hid_spikes[73]) << 1
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[12] | hid_spikes[17] | hid_spikes[41] | hid_spikes[43] | hid_spikes[49] | hid_spikes[56] | hid_spikes[65] | hid_spikes[68]) << 2
        + (hid_spikes[6] | hid_spikes[18] | hid_spikes[31] | hid_spikes[39] | hid_spikes[49] | hid_spikes[52] | hid_spikes[64] | hid_spikes[72] | hid_spikes[73]) << 3;
    wire signed [11:0] neg_in_hid_42 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1] | cochlea_spikes[4]) << 2
        + (cochlea_spikes[1] | cochlea_spikes[4]) << 3
        + (cochlea_spikes[4]) << 4
        + (cochlea_spikes[4]) << 5
        + (cochlea_spikes[2]) << 0
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0] | cochlea_spikes[2]) << 3
        + (cochlea_spikes[2]) << 4
        + (cochlea_spikes[2]) << 5
        + (hid_spikes[4] | hid_spikes[7] | hid_spikes[8] | hid_spikes[9] | hid_spikes[10] | hid_spikes[13] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[20] | hid_spikes[25] | hid_spikes[29] | hid_spikes[33] | hid_spikes[40] | hid_spikes[44] | hid_spikes[50] | hid_spikes[51] | hid_spikes[53] | hid_spikes[54] | hid_spikes[58] | hid_spikes[60] | hid_spikes[71] | hid_spikes[75] | hid_spikes[79]) << 0
        + (hid_spikes[9] | hid_spikes[14] | hid_spikes[19] | hid_spikes[27] | hid_spikes[29] | hid_spikes[30] | hid_spikes[33] | hid_spikes[40] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[58] | hid_spikes[60] | hid_spikes[69] | hid_spikes[70] | hid_spikes[75] | hid_spikes[78] | hid_spikes[79]) << 1
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[7] | hid_spikes[8] | hid_spikes[10] | hid_spikes[13] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[25] | hid_spikes[27] | hid_spikes[28] | hid_spikes[37] | hid_spikes[38] | hid_spikes[42] | hid_spikes[44] | hid_spikes[50] | hid_spikes[59] | hid_spikes[71]) << 2
        + (hid_spikes[9] | hid_spikes[30] | hid_spikes[34] | hid_spikes[51] | hid_spikes[53] | hid_spikes[59] | hid_spikes[61] | hid_spikes[75] | hid_spikes[78]) << 3
        + (hid_spikes[11] | hid_spikes[14] | hid_spikes[20] | hid_spikes[30] | hid_spikes[36] | hid_spikes[66]) << 4;
    wire signed [11:0] sum_hid_42 = pos_in_hid_42 - neg_in_hid_42;
    assign hid_spikes[42] = (mem_hid_42 >= 10);
    wire signed [11:0] next_hid_42 = mem_hid_42 - (mem_hid_42 >>> 5) + sum_hid_42;

    reg signed [11:0] mem_hid_43;
    wire signed [11:0] pos_in_hid_43 = (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 1
        + (hid_spikes[1] | hid_spikes[21] | hid_spikes[30] | hid_spikes[38] | hid_spikes[46] | hid_spikes[51] | hid_spikes[64]) << 0
        + (hid_spikes[22] | hid_spikes[30] | hid_spikes[38] | hid_spikes[51] | hid_spikes[56] | hid_spikes[64]) << 1
        + (hid_spikes[21] | hid_spikes[22] | hid_spikes[30] | hid_spikes[46] | hid_spikes[56] | hid_spikes[64]) << 2
        + (hid_spikes[1]) << 3;
    wire signed [11:0] neg_in_hid_43 = (cochlea_spikes[0] | cochlea_spikes[2]) << 0
        + (cochlea_spikes[0]) << 1
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 2
        + (hid_spikes[0] | hid_spikes[8] | hid_spikes[10] | hid_spikes[11] | hid_spikes[15] | hid_spikes[18] | hid_spikes[24] | hid_spikes[34] | hid_spikes[42] | hid_spikes[44] | hid_spikes[45] | hid_spikes[50] | hid_spikes[52] | hid_spikes[53] | hid_spikes[55] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60] | hid_spikes[62] | hid_spikes[63] | hid_spikes[67] | hid_spikes[68] | hid_spikes[73] | hid_spikes[74] | hid_spikes[76]) << 0
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[7] | hid_spikes[8] | hid_spikes[9] | hid_spikes[10] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[20] | hid_spikes[24] | hid_spikes[25] | hid_spikes[32] | hid_spikes[33] | hid_spikes[34] | hid_spikes[37] | hid_spikes[42] | hid_spikes[45] | hid_spikes[47] | hid_spikes[52] | hid_spikes[55] | hid_spikes[57] | hid_spikes[59] | hid_spikes[62] | hid_spikes[63] | hid_spikes[65] | hid_spikes[67] | hid_spikes[68] | hid_spikes[72] | hid_spikes[73] | hid_spikes[74] | hid_spikes[76] | hid_spikes[77]) << 1
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[8] | hid_spikes[9] | hid_spikes[10] | hid_spikes[11] | hid_spikes[15] | hid_spikes[18] | hid_spikes[20] | hid_spikes[23] | hid_spikes[24] | hid_spikes[33] | hid_spikes[37] | hid_spikes[41] | hid_spikes[44] | hid_spikes[50] | hid_spikes[53] | hid_spikes[55] | hid_spikes[57] | hid_spikes[60] | hid_spikes[63] | hid_spikes[65] | hid_spikes[67] | hid_spikes[70] | hid_spikes[72] | hid_spikes[75] | hid_spikes[76] | hid_spikes[78]) << 2
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[7] | hid_spikes[8] | hid_spikes[10] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[23] | hid_spikes[25] | hid_spikes[44] | hid_spikes[47] | hid_spikes[49] | hid_spikes[50] | hid_spikes[55] | hid_spikes[59] | hid_spikes[60] | hid_spikes[68] | hid_spikes[70] | hid_spikes[73] | hid_spikes[74] | hid_spikes[75] | hid_spikes[76]) << 3
        + (hid_spikes[11] | hid_spikes[16] | hid_spikes[18] | hid_spikes[19] | hid_spikes[29] | hid_spikes[31] | hid_spikes[33] | hid_spikes[34] | hid_spikes[41] | hid_spikes[52] | hid_spikes[58] | hid_spikes[61] | hid_spikes[62] | hid_spikes[69] | hid_spikes[72]) << 4
        + (hid_spikes[19] | hid_spikes[75]) << 5;
    wire signed [11:0] sum_hid_43 = pos_in_hid_43 - neg_in_hid_43;
    assign hid_spikes[43] = (mem_hid_43 >= 10);
    wire signed [11:0] next_hid_43 = mem_hid_43 - (mem_hid_43 >>> 6) + sum_hid_43;

    reg signed [11:0] mem_hid_44;
    wire signed [11:0] pos_in_hid_44 = (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 1
        + (hid_spikes[17] | hid_spikes[18] | hid_spikes[20] | hid_spikes[24] | hid_spikes[32] | hid_spikes[33] | hid_spikes[44] | hid_spikes[53] | hid_spikes[60] | hid_spikes[72]) << 0
        + (hid_spikes[13] | hid_spikes[17] | hid_spikes[18] | hid_spikes[23] | hid_spikes[24] | hid_spikes[31] | hid_spikes[33] | hid_spikes[34] | hid_spikes[52] | hid_spikes[57] | hid_spikes[66] | hid_spikes[72]) << 1
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[13] | hid_spikes[20] | hid_spikes[31] | hid_spikes[32] | hid_spikes[44] | hid_spikes[53] | hid_spikes[57] | hid_spikes[63] | hid_spikes[66] | hid_spikes[70] | hid_spikes[72] | hid_spikes[74]) << 2
        + (hid_spikes[16] | hid_spikes[31] | hid_spikes[39] | hid_spikes[60] | hid_spikes[61] | hid_spikes[72]) << 3;
    wire signed [11:0] neg_in_hid_44 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 2
        + (hid_spikes[6] | hid_spikes[8] | hid_spikes[9] | hid_spikes[11] | hid_spikes[12] | hid_spikes[21] | hid_spikes[22] | hid_spikes[30] | hid_spikes[36] | hid_spikes[38] | hid_spikes[40] | hid_spikes[47] | hid_spikes[51] | hid_spikes[54] | hid_spikes[56] | hid_spikes[58] | hid_spikes[59] | hid_spikes[62] | hid_spikes[64] | hid_spikes[68] | hid_spikes[69] | hid_spikes[79]) << 0
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[4] | hid_spikes[6] | hid_spikes[9] | hid_spikes[11] | hid_spikes[21] | hid_spikes[22] | hid_spikes[26] | hid_spikes[30] | hid_spikes[35] | hid_spikes[38] | hid_spikes[40] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[47] | hid_spikes[50] | hid_spikes[51] | hid_spikes[54] | hid_spikes[55] | hid_spikes[59] | hid_spikes[62] | hid_spikes[67] | hid_spikes[68] | hid_spikes[69] | hid_spikes[71] | hid_spikes[76] | hid_spikes[78]) << 1
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[4] | hid_spikes[8] | hid_spikes[9] | hid_spikes[21] | hid_spikes[27] | hid_spikes[38] | hid_spikes[43] | hid_spikes[45] | hid_spikes[47] | hid_spikes[54] | hid_spikes[58] | hid_spikes[65] | hid_spikes[67] | hid_spikes[71] | hid_spikes[76] | hid_spikes[78] | hid_spikes[79]) << 2
        + (hid_spikes[4] | hid_spikes[8] | hid_spikes[9] | hid_spikes[12] | hid_spikes[26] | hid_spikes[35] | hid_spikes[36] | hid_spikes[40] | hid_spikes[45] | hid_spikes[46] | hid_spikes[47] | hid_spikes[48] | hid_spikes[50] | hid_spikes[51] | hid_spikes[55] | hid_spikes[56] | hid_spikes[59] | hid_spikes[65] | hid_spikes[67] | hid_spikes[69] | hid_spikes[77] | hid_spikes[78]) << 3
        + (hid_spikes[11] | hid_spikes[28] | hid_spikes[46] | hid_spikes[54] | hid_spikes[56] | hid_spikes[64] | hid_spikes[67]) << 4
        + (hid_spikes[30]) << 5;
    wire signed [11:0] sum_hid_44 = pos_in_hid_44 - neg_in_hid_44;
    assign hid_spikes[44] = (mem_hid_44 >= 10);
    wire signed [11:0] next_hid_44 = mem_hid_44 - (mem_hid_44 >>> 6) + sum_hid_44;

    reg signed [11:0] mem_hid_45;
    wire signed [11:0] pos_in_hid_45 = (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 2
        + (hid_spikes[5] | hid_spikes[10] | hid_spikes[15] | hid_spikes[31] | hid_spikes[32] | hid_spikes[39] | hid_spikes[79]) << 0
        + (hid_spikes[2] | hid_spikes[12] | hid_spikes[15] | hid_spikes[31] | hid_spikes[32] | hid_spikes[39] | hid_spikes[70] | hid_spikes[77] | hid_spikes[79]) << 1
        + (hid_spikes[2] | hid_spikes[5] | hid_spikes[12] | hid_spikes[18] | hid_spikes[53] | hid_spikes[70] | hid_spikes[77] | hid_spikes[79]) << 2
        + (hid_spikes[5] | hid_spikes[10] | hid_spikes[79]) << 3;
    wire signed [11:0] neg_in_hid_45 = (cochlea_spikes[1] | cochlea_spikes[5]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[1]) << 5
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[4]) << 3
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[6] | hid_spikes[13] | hid_spikes[14] | hid_spikes[17] | hid_spikes[19] | hid_spikes[20] | hid_spikes[22] | hid_spikes[27] | hid_spikes[28] | hid_spikes[34] | hid_spikes[35] | hid_spikes[36] | hid_spikes[41] | hid_spikes[42] | hid_spikes[44] | hid_spikes[46] | hid_spikes[47] | hid_spikes[51] | hid_spikes[54] | hid_spikes[55] | hid_spikes[58] | hid_spikes[60] | hid_spikes[64] | hid_spikes[66] | hid_spikes[67] | hid_spikes[68] | hid_spikes[71] | hid_spikes[73]) << 0
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[13] | hid_spikes[14] | hid_spikes[21] | hid_spikes[27] | hid_spikes[28] | hid_spikes[30] | hid_spikes[33] | hid_spikes[34] | hid_spikes[35] | hid_spikes[38] | hid_spikes[41] | hid_spikes[42] | hid_spikes[45] | hid_spikes[46] | hid_spikes[50] | hid_spikes[51] | hid_spikes[52] | hid_spikes[54] | hid_spikes[55] | hid_spikes[56] | hid_spikes[58] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63] | hid_spikes[64] | hid_spikes[66] | hid_spikes[67] | hid_spikes[68] | hid_spikes[71] | hid_spikes[72] | hid_spikes[76] | hid_spikes[78]) << 1
        + (hid_spikes[3] | hid_spikes[6] | hid_spikes[7] | hid_spikes[13] | hid_spikes[16] | hid_spikes[17] | hid_spikes[19] | hid_spikes[21] | hid_spikes[22] | hid_spikes[27] | hid_spikes[30] | hid_spikes[36] | hid_spikes[37] | hid_spikes[38] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[47] | hid_spikes[49] | hid_spikes[54] | hid_spikes[56] | hid_spikes[58] | hid_spikes[59] | hid_spikes[61] | hid_spikes[62] | hid_spikes[68] | hid_spikes[71] | hid_spikes[72] | hid_spikes[73] | hid_spikes[74] | hid_spikes[75] | hid_spikes[78]) << 2
        + (hid_spikes[14] | hid_spikes[17] | hid_spikes[20] | hid_spikes[26] | hid_spikes[30] | hid_spikes[33] | hid_spikes[40] | hid_spikes[44] | hid_spikes[45] | hid_spikes[48] | hid_spikes[55] | hid_spikes[60] | hid_spikes[61] | hid_spikes[63] | hid_spikes[64] | hid_spikes[66] | hid_spikes[73] | hid_spikes[75] | hid_spikes[76]) << 3
        + (hid_spikes[9] | hid_spikes[26] | hid_spikes[42] | hid_spikes[43]) << 4
        + (hid_spikes[67]) << 5;
    wire signed [11:0] sum_hid_45 = pos_in_hid_45 - neg_in_hid_45;
    assign hid_spikes[45] = (mem_hid_45 >= 10);
    wire signed [11:0] next_hid_45 = mem_hid_45 - (mem_hid_45 >>> 3) + sum_hid_45;

    reg signed [11:0] mem_hid_46;
    wire signed [11:0] pos_in_hid_46 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[5]) << 1
        + (hid_spikes[25] | hid_spikes[39] | hid_spikes[59] | hid_spikes[68] | hid_spikes[77] | hid_spikes[79]) << 0
        + (hid_spikes[8] | hid_spikes[26] | hid_spikes[35] | hid_spikes[39] | hid_spikes[40] | hid_spikes[43] | hid_spikes[59] | hid_spikes[65] | hid_spikes[68] | hid_spikes[71]) << 1
        + (hid_spikes[8] | hid_spikes[21] | hid_spikes[24] | hid_spikes[25] | hid_spikes[40] | hid_spikes[52] | hid_spikes[59] | hid_spikes[77]) << 2
        + (hid_spikes[8] | hid_spikes[73] | hid_spikes[79]) << 3;
    wire signed [11:0] neg_in_hid_46 = (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 1
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[4]) << 2
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[2] | hid_spikes[7] | hid_spikes[10] | hid_spikes[11] | hid_spikes[12] | hid_spikes[14] | hid_spikes[17] | hid_spikes[19] | hid_spikes[20] | hid_spikes[23] | hid_spikes[30] | hid_spikes[32] | hid_spikes[36] | hid_spikes[42] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[51] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[60] | hid_spikes[62] | hid_spikes[63] | hid_spikes[66] | hid_spikes[69] | hid_spikes[70] | hid_spikes[76] | hid_spikes[78]) << 0
        + (hid_spikes[1] | hid_spikes[6] | hid_spikes[11] | hid_spikes[12] | hid_spikes[13] | hid_spikes[17] | hid_spikes[20] | hid_spikes[23] | hid_spikes[32] | hid_spikes[34] | hid_spikes[36] | hid_spikes[41] | hid_spikes[42] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60] | hid_spikes[62] | hid_spikes[63] | hid_spikes[66] | hid_spikes[69] | hid_spikes[70] | hid_spikes[75] | hid_spikes[76]) << 1
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[7] | hid_spikes[10] | hid_spikes[13] | hid_spikes[14] | hid_spikes[27] | hid_spikes[30] | hid_spikes[44] | hid_spikes[46] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[58] | hid_spikes[60] | hid_spikes[66] | hid_spikes[72] | hid_spikes[75] | hid_spikes[76] | hid_spikes[78]) << 2
        + (hid_spikes[0] | hid_spikes[6] | hid_spikes[9] | hid_spikes[11] | hid_spikes[15] | hid_spikes[19] | hid_spikes[20] | hid_spikes[29] | hid_spikes[31] | hid_spikes[32] | hid_spikes[34] | hid_spikes[41] | hid_spikes[46] | hid_spikes[51] | hid_spikes[61] | hid_spikes[62] | hid_spikes[69] | hid_spikes[70] | hid_spikes[72] | hid_spikes[76] | hid_spikes[78]) << 3
        + (hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[78]) << 4;
    wire signed [11:0] sum_hid_46 = pos_in_hid_46 - neg_in_hid_46;
    assign hid_spikes[46] = (mem_hid_46 >= 10);
    wire signed [11:0] next_hid_46 = mem_hid_46 - (mem_hid_46 >>> 5) + sum_hid_46;

    reg signed [11:0] mem_hid_47;
    wire signed [11:0] pos_in_hid_47 = (hid_spikes[0] | hid_spikes[7] | hid_spikes[12] | hid_spikes[22] | hid_spikes[25] | hid_spikes[32] | hid_spikes[33] | hid_spikes[41] | hid_spikes[60] | hid_spikes[62] | hid_spikes[66] | hid_spikes[72] | hid_spikes[79]) << 0
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[12] | hid_spikes[17] | hid_spikes[20] | hid_spikes[22] | hid_spikes[24] | hid_spikes[32] | hid_spikes[34] | hid_spikes[40] | hid_spikes[41] | hid_spikes[46] | hid_spikes[48] | hid_spikes[59] | hid_spikes[60] | hid_spikes[62] | hid_spikes[66] | hid_spikes[72] | hid_spikes[79]) << 1
        + (hid_spikes[0] | hid_spikes[7] | hid_spikes[17] | hid_spikes[22] | hid_spikes[29] | hid_spikes[33] | hid_spikes[59] | hid_spikes[72] | hid_spikes[76]) << 2
        + (hid_spikes[0] | hid_spikes[22] | hid_spikes[25] | hid_spikes[35] | hid_spikes[40] | hid_spikes[46] | hid_spikes[60] | hid_spikes[62]) << 3;
    wire signed [11:0] neg_in_hid_47 = (cochlea_spikes[5]) << 0
        + (cochlea_spikes[0] | cochlea_spikes[1]) << 1
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[5]) << 3
        + (cochlea_spikes[0] | cochlea_spikes[5]) << 4
        + (cochlea_spikes[0]) << 5
        + (cochlea_spikes[2] | cochlea_spikes[3]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[3]) << 2
        + (cochlea_spikes[2] | cochlea_spikes[3]) << 3
        + (cochlea_spikes[3]) << 4
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[15] | hid_spikes[16] | hid_spikes[18] | hid_spikes[30] | hid_spikes[36] | hid_spikes[42] | hid_spikes[43] | hid_spikes[50] | hid_spikes[55] | hid_spikes[58] | hid_spikes[61] | hid_spikes[64] | hid_spikes[68] | hid_spikes[77]) << 0
        + (hid_spikes[6] | hid_spikes[11] | hid_spikes[14] | hid_spikes[18] | hid_spikes[30] | hid_spikes[31] | hid_spikes[38] | hid_spikes[39] | hid_spikes[42] | hid_spikes[43] | hid_spikes[47] | hid_spikes[53] | hid_spikes[55] | hid_spikes[58] | hid_spikes[63] | hid_spikes[64] | hid_spikes[67] | hid_spikes[71] | hid_spikes[78]) << 1
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[6] | hid_spikes[10] | hid_spikes[11] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[36] | hid_spikes[38] | hid_spikes[39] | hid_spikes[42] | hid_spikes[43] | hid_spikes[47] | hid_spikes[55] | hid_spikes[56] | hid_spikes[58] | hid_spikes[64] | hid_spikes[65] | hid_spikes[67] | hid_spikes[68] | hid_spikes[70] | hid_spikes[71] | hid_spikes[77] | hid_spikes[78]) << 2
        + (hid_spikes[14] | hid_spikes[18] | hid_spikes[30] | hid_spikes[39] | hid_spikes[42] | hid_spikes[44] | hid_spikes[50] | hid_spikes[53] | hid_spikes[58] | hid_spikes[61] | hid_spikes[69] | hid_spikes[77]) << 3
        + (hid_spikes[64] | hid_spikes[78]) << 4;
    wire signed [11:0] sum_hid_47 = pos_in_hid_47 - neg_in_hid_47;
    assign hid_spikes[47] = (mem_hid_47 >= 10);
    wire signed [11:0] next_hid_47 = mem_hid_47 - (mem_hid_47 >>> 6) + sum_hid_47;

    reg signed [11:0] mem_hid_48;
    wire signed [11:0] pos_in_hid_48 = (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 3
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (cochlea_spikes[5]) << 2
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[18] | hid_spikes[33] | hid_spikes[44]) << 0
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[17] | hid_spikes[29] | hid_spikes[31] | hid_spikes[39] | hid_spikes[44]) << 1
        + (hid_spikes[17] | hid_spikes[29] | hid_spikes[31] | hid_spikes[33] | hid_spikes[57]) << 2
        + (hid_spikes[18] | hid_spikes[25] | hid_spikes[41] | hid_spikes[44] | hid_spikes[55]) << 3;
    wire signed [11:0] neg_in_hid_48 = (cochlea_spikes[0] | cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[2]) << 5
        + (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 2
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[6] | hid_spikes[12] | hid_spikes[14] | hid_spikes[16] | hid_spikes[19] | hid_spikes[22] | hid_spikes[24] | hid_spikes[26] | hid_spikes[30] | hid_spikes[35] | hid_spikes[36] | hid_spikes[43] | hid_spikes[47] | hid_spikes[49] | hid_spikes[56] | hid_spikes[59] | hid_spikes[60] | hid_spikes[67] | hid_spikes[71] | hid_spikes[76] | hid_spikes[77] | hid_spikes[78] | hid_spikes[79]) << 0
        + (hid_spikes[0] | hid_spikes[6] | hid_spikes[15] | hid_spikes[23] | hid_spikes[24] | hid_spikes[26] | hid_spikes[30] | hid_spikes[38] | hid_spikes[42] | hid_spikes[43] | hid_spikes[47] | hid_spikes[53] | hid_spikes[54] | hid_spikes[56] | hid_spikes[59] | hid_spikes[60] | hid_spikes[67] | hid_spikes[68] | hid_spikes[73] | hid_spikes[74] | hid_spikes[75] | hid_spikes[76] | hid_spikes[77] | hid_spikes[78] | hid_spikes[79]) << 1
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[6] | hid_spikes[11] | hid_spikes[12] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[22] | hid_spikes[24] | hid_spikes[26] | hid_spikes[27] | hid_spikes[30] | hid_spikes[35] | hid_spikes[36] | hid_spikes[47] | hid_spikes[49] | hid_spikes[50] | hid_spikes[59] | hid_spikes[60] | hid_spikes[61] | hid_spikes[68] | hid_spikes[70] | hid_spikes[74] | hid_spikes[75] | hid_spikes[76] | hid_spikes[77]) << 2
        + (hid_spikes[0] | hid_spikes[11] | hid_spikes[19] | hid_spikes[20] | hid_spikes[23] | hid_spikes[26] | hid_spikes[40] | hid_spikes[43] | hid_spikes[46] | hid_spikes[50] | hid_spikes[53] | hid_spikes[56] | hid_spikes[62] | hid_spikes[71] | hid_spikes[72] | hid_spikes[74] | hid_spikes[75]) << 3
        + (hid_spikes[66] | hid_spikes[67] | hid_spikes[78]) << 4;
    wire signed [11:0] sum_hid_48 = pos_in_hid_48 - neg_in_hid_48;
    assign hid_spikes[48] = (mem_hid_48 >= 10);
    wire signed [11:0] next_hid_48 = mem_hid_48 - (mem_hid_48 >>> 6) + sum_hid_48;

    reg signed [11:0] mem_hid_49;
    wire signed [11:0] pos_in_hid_49 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 1
        + (hid_spikes[1] | hid_spikes[9] | hid_spikes[10] | hid_spikes[18] | hid_spikes[39] | hid_spikes[40] | hid_spikes[55] | hid_spikes[57] | hid_spikes[70] | hid_spikes[72]) << 0
        + (hid_spikes[8] | hid_spikes[10] | hid_spikes[18] | hid_spikes[23] | hid_spikes[39] | hid_spikes[55] | hid_spikes[57] | hid_spikes[65] | hid_spikes[78]) << 1
        + (hid_spikes[1] | hid_spikes[9] | hid_spikes[18] | hid_spikes[39] | hid_spikes[48] | hid_spikes[55] | hid_spikes[64] | hid_spikes[70] | hid_spikes[72] | hid_spikes[78]) << 2
        + (hid_spikes[9] | hid_spikes[33] | hid_spikes[40] | hid_spikes[44]) << 3;
    wire signed [11:0] neg_in_hid_49 = (cochlea_spikes[0]) << 2
        + (hid_spikes[0] | hid_spikes[5] | hid_spikes[16] | hid_spikes[20] | hid_spikes[21] | hid_spikes[22] | hid_spikes[26] | hid_spikes[35] | hid_spikes[43] | hid_spikes[50] | hid_spikes[60] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63] | hid_spikes[71] | hid_spikes[74]) << 0
        + (hid_spikes[20] | hid_spikes[22] | hid_spikes[26] | hid_spikes[27] | hid_spikes[50] | hid_spikes[53] | hid_spikes[54] | hid_spikes[59] | hid_spikes[60] | hid_spikes[68] | hid_spikes[71] | hid_spikes[74] | hid_spikes[77]) << 1
        + (hid_spikes[0] | hid_spikes[5] | hid_spikes[13] | hid_spikes[15] | hid_spikes[16] | hid_spikes[24] | hid_spikes[27] | hid_spikes[28] | hid_spikes[35] | hid_spikes[41] | hid_spikes[47] | hid_spikes[50] | hid_spikes[53] | hid_spikes[54] | hid_spikes[63] | hid_spikes[69] | hid_spikes[74] | hid_spikes[76] | hid_spikes[77]) << 2
        + (hid_spikes[0] | hid_spikes[11] | hid_spikes[16] | hid_spikes[21] | hid_spikes[31] | hid_spikes[37] | hid_spikes[56] | hid_spikes[61] | hid_spikes[62] | hid_spikes[76]) << 3
        + (hid_spikes[4] | hid_spikes[6] | hid_spikes[13] | hid_spikes[43] | hid_spikes[67]) << 4;
    wire signed [11:0] sum_hid_49 = pos_in_hid_49 - neg_in_hid_49;
    assign hid_spikes[49] = (mem_hid_49 >= 10);
    wire signed [11:0] next_hid_49 = mem_hid_49 - (mem_hid_49 >>> 3) + sum_hid_49;

    reg signed [11:0] mem_hid_50;
    wire signed [11:0] pos_in_hid_50 = (hid_spikes[18] | hid_spikes[25] | hid_spikes[32] | hid_spikes[33] | hid_spikes[40] | hid_spikes[41] | hid_spikes[47] | hid_spikes[59] | hid_spikes[79]) << 0
        + (hid_spikes[12] | hid_spikes[18] | hid_spikes[25] | hid_spikes[28] | hid_spikes[32] | hid_spikes[33] | hid_spikes[40] | hid_spikes[41] | hid_spikes[47] | hid_spikes[48] | hid_spikes[52] | hid_spikes[60] | hid_spikes[68] | hid_spikes[79]) << 1
        + (hid_spikes[1] | hid_spikes[18] | hid_spikes[28] | hid_spikes[40] | hid_spikes[52] | hid_spikes[59] | hid_spikes[64] | hid_spikes[68] | hid_spikes[72]) << 2
        + (hid_spikes[18] | hid_spikes[25] | hid_spikes[29] | hid_spikes[48] | hid_spikes[60] | hid_spikes[72]) << 3;
    wire signed [11:0] neg_in_hid_50 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[2] | cochlea_spikes[4]) << 4
        + (cochlea_spikes[1]) << 0
        + (cochlea_spikes[0] | cochlea_spikes[1]) << 1
        + (cochlea_spikes[0]) << 4
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[20] | hid_spikes[23] | hid_spikes[24] | hid_spikes[35] | hid_spikes[36] | hid_spikes[39] | hid_spikes[45] | hid_spikes[50] | hid_spikes[63] | hid_spikes[66] | hid_spikes[67] | hid_spikes[75] | hid_spikes[78]) << 0
        + (hid_spikes[8] | hid_spikes[9] | hid_spikes[10] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[20] | hid_spikes[23] | hid_spikes[24] | hid_spikes[27] | hid_spikes[31] | hid_spikes[34] | hid_spikes[35] | hid_spikes[36] | hid_spikes[37] | hid_spikes[38] | hid_spikes[39] | hid_spikes[45] | hid_spikes[50] | hid_spikes[53] | hid_spikes[56] | hid_spikes[61] | hid_spikes[63] | hid_spikes[65] | hid_spikes[66] | hid_spikes[73] | hid_spikes[75] | hid_spikes[77]) << 1
        + (hid_spikes[3] | hid_spikes[7] | hid_spikes[8] | hid_spikes[9] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[23] | hid_spikes[24] | hid_spikes[35] | hid_spikes[37] | hid_spikes[38] | hid_spikes[46] | hid_spikes[51] | hid_spikes[56] | hid_spikes[61] | hid_spikes[75]) << 2
        + (hid_spikes[5] | hid_spikes[14] | hid_spikes[30] | hid_spikes[31] | hid_spikes[58] | hid_spikes[67] | hid_spikes[75] | hid_spikes[78]) << 3
        + (hid_spikes[77]) << 4;
    wire signed [11:0] sum_hid_50 = pos_in_hid_50 - neg_in_hid_50;
    assign hid_spikes[50] = (mem_hid_50 >= 10);
    wire signed [11:0] next_hid_50 = mem_hid_50 - (mem_hid_50 >>> 6) + sum_hid_50;

    reg signed [11:0] mem_hid_51;
    wire signed [11:0] pos_in_hid_51 = (cochlea_spikes[5]) << 1
        + (cochlea_spikes[5]) << 3
        + (cochlea_spikes[5]) << 4
        + (cochlea_spikes[1]) << 2
        + (hid_spikes[8] | hid_spikes[17] | hid_spikes[24] | hid_spikes[25] | hid_spikes[33] | hid_spikes[36] | hid_spikes[47] | hid_spikes[52] | hid_spikes[55] | hid_spikes[56] | hid_spikes[59] | hid_spikes[70]) << 0
        + (hid_spikes[8] | hid_spikes[9] | hid_spikes[17] | hid_spikes[24] | hid_spikes[25] | hid_spikes[38] | hid_spikes[40] | hid_spikes[54] | hid_spikes[59] | hid_spikes[68]) << 1
        + (hid_spikes[12] | hid_spikes[21] | hid_spikes[22] | hid_spikes[24] | hid_spikes[25] | hid_spikes[33] | hid_spikes[35] | hid_spikes[36] | hid_spikes[40] | hid_spikes[45] | hid_spikes[47] | hid_spikes[54] | hid_spikes[55] | hid_spikes[56] | hid_spikes[68] | hid_spikes[70]) << 2
        + (hid_spikes[1] | hid_spikes[4] | hid_spikes[43] | hid_spikes[52] | hid_spikes[55]) << 3
        + (hid_spikes[6]) << 4;
    wire signed [11:0] neg_in_hid_51 = (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0]) << 5
        + (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 1
        + (cochlea_spikes[3]) << 4
        + (hid_spikes[2] | hid_spikes[5] | hid_spikes[7] | hid_spikes[14] | hid_spikes[15] | hid_spikes[20] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[37] | hid_spikes[42] | hid_spikes[44] | hid_spikes[46] | hid_spikes[48] | hid_spikes[50] | hid_spikes[53] | hid_spikes[63] | hid_spikes[64] | hid_spikes[65] | hid_spikes[67] | hid_spikes[77] | hid_spikes[78]) << 0
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[5] | hid_spikes[7] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[20] | hid_spikes[26] | hid_spikes[27] | hid_spikes[30] | hid_spikes[31] | hid_spikes[37] | hid_spikes[39] | hid_spikes[42] | hid_spikes[44] | hid_spikes[46] | hid_spikes[49] | hid_spikes[51] | hid_spikes[53] | hid_spikes[61] | hid_spikes[62] | hid_spikes[64] | hid_spikes[67] | hid_spikes[69] | hid_spikes[71] | hid_spikes[78]) << 1
        + (hid_spikes[0] | hid_spikes[7] | hid_spikes[10] | hid_spikes[18] | hid_spikes[19] | hid_spikes[26] | hid_spikes[28] | hid_spikes[30] | hid_spikes[31] | hid_spikes[34] | hid_spikes[49] | hid_spikes[57] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63] | hid_spikes[69] | hid_spikes[71] | hid_spikes[72] | hid_spikes[77] | hid_spikes[78]) << 2
        + (hid_spikes[0] | hid_spikes[5] | hid_spikes[15] | hid_spikes[26] | hid_spikes[41] | hid_spikes[48] | hid_spikes[51] | hid_spikes[57] | hid_spikes[61] | hid_spikes[62] | hid_spikes[64] | hid_spikes[65] | hid_spikes[67]) << 3
        + (hid_spikes[20] | hid_spikes[50] | hid_spikes[53] | hid_spikes[64] | hid_spikes[67]) << 4;
    wire signed [11:0] sum_hid_51 = pos_in_hid_51 - neg_in_hid_51;
    assign hid_spikes[51] = (mem_hid_51 >= 10);
    wire signed [11:0] next_hid_51 = mem_hid_51 - (mem_hid_51 >>> 3) + sum_hid_51;

    reg signed [11:0] mem_hid_52;
    wire signed [11:0] pos_in_hid_52 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 2
        + (hid_spikes[0] | hid_spikes[25] | hid_spikes[26] | hid_spikes[34] | hid_spikes[44] | hid_spikes[46] | hid_spikes[48] | hid_spikes[52] | hid_spikes[57] | hid_spikes[58] | hid_spikes[59] | hid_spikes[62] | hid_spikes[63] | hid_spikes[66] | hid_spikes[70] | hid_spikes[72]) << 0
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[8] | hid_spikes[22] | hid_spikes[32] | hid_spikes[40] | hid_spikes[46] | hid_spikes[50] | hid_spikes[52] | hid_spikes[63] | hid_spikes[72] | hid_spikes[77]) << 1
        + (hid_spikes[3] | hid_spikes[14] | hid_spikes[22] | hid_spikes[25] | hid_spikes[27] | hid_spikes[32] | hid_spikes[34] | hid_spikes[40] | hid_spikes[48] | hid_spikes[50] | hid_spikes[52] | hid_spikes[57] | hid_spikes[58] | hid_spikes[59] | hid_spikes[62] | hid_spikes[70] | hid_spikes[72]) << 2
        + (hid_spikes[1] | hid_spikes[8] | hid_spikes[26] | hid_spikes[34] | hid_spikes[44] | hid_spikes[46] | hid_spikes[51] | hid_spikes[62] | hid_spikes[76]) << 3
        + (hid_spikes[66]) << 4;
    wire signed [11:0] neg_in_hid_52 = (cochlea_spikes[3] | cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (cochlea_spikes[3]) << 2
        + (cochlea_spikes[3]) << 3
        + (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[2] | cochlea_spikes[4]) << 2
        + (cochlea_spikes[2]) << 3
        + (hid_spikes[4] | hid_spikes[7] | hid_spikes[12] | hid_spikes[13] | hid_spikes[15] | hid_spikes[17] | hid_spikes[18] | hid_spikes[23] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[35] | hid_spikes[37] | hid_spikes[39] | hid_spikes[42] | hid_spikes[45] | hid_spikes[61] | hid_spikes[64] | hid_spikes[65] | hid_spikes[73]) << 0
        + (hid_spikes[2] | hid_spikes[4] | hid_spikes[7] | hid_spikes[10] | hid_spikes[11] | hid_spikes[12] | hid_spikes[15] | hid_spikes[16] | hid_spikes[17] | hid_spikes[18] | hid_spikes[23] | hid_spikes[24] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[38] | hid_spikes[39] | hid_spikes[42] | hid_spikes[47] | hid_spikes[55] | hid_spikes[60] | hid_spikes[64] | hid_spikes[68] | hid_spikes[75]) << 1
        + (hid_spikes[7] | hid_spikes[9] | hid_spikes[10] | hid_spikes[11] | hid_spikes[12] | hid_spikes[13] | hid_spikes[16] | hid_spikes[18] | hid_spikes[20] | hid_spikes[24] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[35] | hid_spikes[45] | hid_spikes[47] | hid_spikes[49] | hid_spikes[55] | hid_spikes[61] | hid_spikes[71] | hid_spikes[73]) << 2
        + (hid_spikes[9] | hid_spikes[30] | hid_spikes[37] | hid_spikes[43] | hid_spikes[49] | hid_spikes[60] | hid_spikes[64] | hid_spikes[65] | hid_spikes[73] | hid_spikes[74] | hid_spikes[75]) << 3
        + (hid_spikes[38]) << 4;
    wire signed [11:0] sum_hid_52 = pos_in_hid_52 - neg_in_hid_52;
    assign hid_spikes[52] = (mem_hid_52 >= 10);
    wire signed [11:0] next_hid_52 = mem_hid_52 - (mem_hid_52 >>> 6) + sum_hid_52;

    reg signed [11:0] mem_hid_53;
    wire signed [11:0] pos_in_hid_53 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 4
        + (cochlea_spikes[0]) << 2
        + (hid_spikes[10] | hid_spikes[14] | hid_spikes[15] | hid_spikes[23] | hid_spikes[43] | hid_spikes[52] | hid_spikes[74]) << 0
        + (hid_spikes[10] | hid_spikes[14] | hid_spikes[15] | hid_spikes[18] | hid_spikes[43] | hid_spikes[67] | hid_spikes[73]) << 1
        + (hid_spikes[13] | hid_spikes[15] | hid_spikes[17] | hid_spikes[48] | hid_spikes[52] | hid_spikes[62] | hid_spikes[74] | hid_spikes[78]) << 2
        + (hid_spikes[10] | hid_spikes[23] | hid_spikes[28]) << 3;
    wire signed [11:0] neg_in_hid_53 = (cochlea_spikes[1]) << 2
        + (cochlea_spikes[1] | cochlea_spikes[5]) << 3
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 3
        + (hid_spikes[1] | hid_spikes[16] | hid_spikes[20] | hid_spikes[22] | hid_spikes[34] | hid_spikes[35] | hid_spikes[36] | hid_spikes[37] | hid_spikes[46] | hid_spikes[47] | hid_spikes[49] | hid_spikes[51] | hid_spikes[54] | hid_spikes[55] | hid_spikes[56] | hid_spikes[58] | hid_spikes[59] | hid_spikes[60] | hid_spikes[61] | hid_spikes[66] | hid_spikes[71] | hid_spikes[76] | hid_spikes[77] | hid_spikes[79]) << 0
        + (hid_spikes[1] | hid_spikes[4] | hid_spikes[6] | hid_spikes[12] | hid_spikes[16] | hid_spikes[19] | hid_spikes[20] | hid_spikes[30] | hid_spikes[31] | hid_spikes[34] | hid_spikes[35] | hid_spikes[37] | hid_spikes[38] | hid_spikes[39] | hid_spikes[40] | hid_spikes[46] | hid_spikes[47] | hid_spikes[51] | hid_spikes[57] | hid_spikes[58] | hid_spikes[59] | hid_spikes[60] | hid_spikes[61] | hid_spikes[63] | hid_spikes[64] | hid_spikes[65] | hid_spikes[66] | hid_spikes[68] | hid_spikes[71] | hid_spikes[75] | hid_spikes[76] | hid_spikes[79]) << 1
        + (hid_spikes[4] | hid_spikes[6] | hid_spikes[8] | hid_spikes[9] | hid_spikes[11] | hid_spikes[19] | hid_spikes[22] | hid_spikes[30] | hid_spikes[31] | hid_spikes[35] | hid_spikes[40] | hid_spikes[47] | hid_spikes[49] | hid_spikes[51] | hid_spikes[55] | hid_spikes[57] | hid_spikes[63] | hid_spikes[65] | hid_spikes[69] | hid_spikes[70] | hid_spikes[71] | hid_spikes[77]) << 2
        + (hid_spikes[4] | hid_spikes[6] | hid_spikes[9] | hid_spikes[11] | hid_spikes[12] | hid_spikes[20] | hid_spikes[25] | hid_spikes[27] | hid_spikes[36] | hid_spikes[38] | hid_spikes[41] | hid_spikes[46] | hid_spikes[51] | hid_spikes[53] | hid_spikes[56] | hid_spikes[58] | hid_spikes[64]) << 3
        + (hid_spikes[54] | hid_spikes[64]) << 4;
    wire signed [11:0] sum_hid_53 = pos_in_hid_53 - neg_in_hid_53;
    assign hid_spikes[53] = (mem_hid_53 >= 10);
    wire signed [11:0] next_hid_53 = mem_hid_53 - (mem_hid_53 >>> 4) + sum_hid_53;

    reg signed [11:0] mem_hid_54;
    wire signed [11:0] pos_in_hid_54 = (cochlea_spikes[1]) << 1
        + (cochlea_spikes[5]) << 1
        + (hid_spikes[4] | hid_spikes[9] | hid_spikes[12] | hid_spikes[30] | hid_spikes[32] | hid_spikes[43] | hid_spikes[46] | hid_spikes[64] | hid_spikes[65]) << 0
        + (hid_spikes[4] | hid_spikes[9] | hid_spikes[12] | hid_spikes[23] | hid_spikes[32] | hid_spikes[35] | hid_spikes[43] | hid_spikes[46] | hid_spikes[51] | hid_spikes[64] | hid_spikes[65] | hid_spikes[70]) << 1
        + (hid_spikes[10] | hid_spikes[23] | hid_spikes[25] | hid_spikes[30] | hid_spikes[34] | hid_spikes[35] | hid_spikes[51] | hid_spikes[54] | hid_spikes[60]) << 2
        + (hid_spikes[47] | hid_spikes[52]) << 3;
    wire signed [11:0] neg_in_hid_54 = (hid_spikes[6] | hid_spikes[7] | hid_spikes[11] | hid_spikes[22] | hid_spikes[26] | hid_spikes[33] | hid_spikes[39] | hid_spikes[41] | hid_spikes[42] | hid_spikes[48] | hid_spikes[50] | hid_spikes[61] | hid_spikes[66] | hid_spikes[69] | hid_spikes[75] | hid_spikes[76]) << 0
        + (hid_spikes[6] | hid_spikes[13] | hid_spikes[15] | hid_spikes[16] | hid_spikes[20] | hid_spikes[24] | hid_spikes[26] | hid_spikes[39] | hid_spikes[41] | hid_spikes[42] | hid_spikes[48] | hid_spikes[49] | hid_spikes[56] | hid_spikes[58] | hid_spikes[62] | hid_spikes[63] | hid_spikes[69] | hid_spikes[75] | hid_spikes[78]) << 1
        + (hid_spikes[6] | hid_spikes[14] | hid_spikes[18] | hid_spikes[20] | hid_spikes[24] | hid_spikes[26] | hid_spikes[39] | hid_spikes[50] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63] | hid_spikes[66] | hid_spikes[75] | hid_spikes[76]) << 2
        + (hid_spikes[7] | hid_spikes[14] | hid_spikes[20] | hid_spikes[22] | hid_spikes[26] | hid_spikes[29] | hid_spikes[36] | hid_spikes[42] | hid_spikes[50] | hid_spikes[58] | hid_spikes[69] | hid_spikes[78]) << 3
        + (hid_spikes[11] | hid_spikes[16] | hid_spikes[33] | hid_spikes[61]) << 4;
    wire signed [11:0] sum_hid_54 = pos_in_hid_54 - neg_in_hid_54;
    assign hid_spikes[54] = (mem_hid_54 >= 10);
    wire signed [11:0] next_hid_54 = mem_hid_54 - (mem_hid_54 >>> 5) + sum_hid_54;

    reg signed [11:0] mem_hid_55;
    wire signed [11:0] pos_in_hid_55 = (cochlea_spikes[0]) << 4
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[3] | hid_spikes[8] | hid_spikes[14] | hid_spikes[20] | hid_spikes[23] | hid_spikes[24] | hid_spikes[41] | hid_spikes[45] | hid_spikes[68] | hid_spikes[69] | hid_spikes[70] | hid_spikes[72] | hid_spikes[76] | hid_spikes[77]) << 0
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[14] | hid_spikes[20] | hid_spikes[23] | hid_spikes[24] | hid_spikes[31] | hid_spikes[41] | hid_spikes[46] | hid_spikes[48] | hid_spikes[51] | hid_spikes[53] | hid_spikes[54] | hid_spikes[62] | hid_spikes[68] | hid_spikes[69] | hid_spikes[70] | hid_spikes[71] | hid_spikes[74] | hid_spikes[79]) << 1
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[8] | hid_spikes[14] | hid_spikes[19] | hid_spikes[20] | hid_spikes[42] | hid_spikes[45] | hid_spikes[53] | hid_spikes[54] | hid_spikes[57] | hid_spikes[62] | hid_spikes[69] | hid_spikes[72] | hid_spikes[77] | hid_spikes[79]) << 2
        + (hid_spikes[1] | hid_spikes[3] | hid_spikes[10] | hid_spikes[14] | hid_spikes[34] | hid_spikes[46] | hid_spikes[48] | hid_spikes[51] | hid_spikes[72] | hid_spikes[76]) << 3;
    wire signed [11:0] neg_in_hid_55 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[1] | cochlea_spikes[2]) << 1
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[2]) << 3
        + (cochlea_spikes[2]) << 5
        + (cochlea_spikes[4]) << 0
        + (cochlea_spikes[5]) << 1
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[4]) << 3
        + (cochlea_spikes[5]) << 5
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[9] | hid_spikes[13] | hid_spikes[15] | hid_spikes[21] | hid_spikes[22] | hid_spikes[25] | hid_spikes[32] | hid_spikes[35] | hid_spikes[38] | hid_spikes[43] | hid_spikes[47] | hid_spikes[49] | hid_spikes[50] | hid_spikes[56] | hid_spikes[58] | hid_spikes[61] | hid_spikes[64] | hid_spikes[73] | hid_spikes[75] | hid_spikes[78]) << 0
        + (hid_spikes[6] | hid_spikes[7] | hid_spikes[15] | hid_spikes[16] | hid_spikes[22] | hid_spikes[32] | hid_spikes[33] | hid_spikes[35] | hid_spikes[38] | hid_spikes[43] | hid_spikes[47] | hid_spikes[56] | hid_spikes[63] | hid_spikes[65] | hid_spikes[73] | hid_spikes[78]) << 1
        + (hid_spikes[4] | hid_spikes[6] | hid_spikes[7] | hid_spikes[9] | hid_spikes[13] | hid_spikes[17] | hid_spikes[21] | hid_spikes[22] | hid_spikes[25] | hid_spikes[28] | hid_spikes[33] | hid_spikes[36] | hid_spikes[58] | hid_spikes[63] | hid_spikes[64] | hid_spikes[73]) << 2
        + (hid_spikes[5] | hid_spikes[11] | hid_spikes[16] | hid_spikes[37] | hid_spikes[38] | hid_spikes[47] | hid_spikes[49] | hid_spikes[50] | hid_spikes[55] | hid_spikes[61] | hid_spikes[63] | hid_spikes[65] | hid_spikes[67] | hid_spikes[75]) << 3
        + (hid_spikes[29] | hid_spikes[39] | hid_spikes[43] | hid_spikes[67]) << 4;
    wire signed [11:0] sum_hid_55 = pos_in_hid_55 - neg_in_hid_55;
    assign hid_spikes[55] = (mem_hid_55 >= 10);
    wire signed [11:0] next_hid_55 = mem_hid_55 - (mem_hid_55 >>> 5) + sum_hid_55;

    reg signed [11:0] mem_hid_56;
    wire signed [11:0] pos_in_hid_56 = (cochlea_spikes[1]) << 2
        + (hid_spikes[3] | hid_spikes[8] | hid_spikes[10] | hid_spikes[26] | hid_spikes[28] | hid_spikes[39] | hid_spikes[42] | hid_spikes[52] | hid_spikes[64] | hid_spikes[70] | hid_spikes[76]) << 0
        + (hid_spikes[2] | hid_spikes[10] | hid_spikes[26] | hid_spikes[28] | hid_spikes[42] | hid_spikes[43] | hid_spikes[52] | hid_spikes[70] | hid_spikes[76]) << 1
        + (hid_spikes[2] | hid_spikes[3] | hid_spikes[28] | hid_spikes[30] | hid_spikes[39] | hid_spikes[40] | hid_spikes[52]) << 2
        + (hid_spikes[8] | hid_spikes[46] | hid_spikes[52] | hid_spikes[64]) << 3;
    wire signed [11:0] neg_in_hid_56 = (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 3
        + (cochlea_spikes[4]) << 5
        + (cochlea_spikes[2]) << 3
        + (cochlea_spikes[2]) << 5
        + (hid_spikes[5] | hid_spikes[13] | hid_spikes[14] | hid_spikes[17] | hid_spikes[19] | hid_spikes[20] | hid_spikes[23] | hid_spikes[24] | hid_spikes[25] | hid_spikes[27] | hid_spikes[29] | hid_spikes[33] | hid_spikes[36] | hid_spikes[41] | hid_spikes[45] | hid_spikes[48] | hid_spikes[49] | hid_spikes[58] | hid_spikes[65] | hid_spikes[66] | hid_spikes[69] | hid_spikes[71] | hid_spikes[72] | hid_spikes[73] | hid_spikes[77] | hid_spikes[78]) << 0
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[6] | hid_spikes[7] | hid_spikes[9] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[20] | hid_spikes[21] | hid_spikes[24] | hid_spikes[25] | hid_spikes[27] | hid_spikes[31] | hid_spikes[34] | hid_spikes[41] | hid_spikes[44] | hid_spikes[45] | hid_spikes[49] | hid_spikes[54] | hid_spikes[55] | hid_spikes[60] | hid_spikes[65] | hid_spikes[66] | hid_spikes[69] | hid_spikes[72] | hid_spikes[73] | hid_spikes[75]) << 1
        + (hid_spikes[0] | hid_spikes[6] | hid_spikes[13] | hid_spikes[16] | hid_spikes[17] | hid_spikes[19] | hid_spikes[20] | hid_spikes[29] | hid_spikes[33] | hid_spikes[36] | hid_spikes[37] | hid_spikes[38] | hid_spikes[48] | hid_spikes[54] | hid_spikes[57] | hid_spikes[60] | hid_spikes[71] | hid_spikes[77] | hid_spikes[78]) << 2
        + (hid_spikes[5] | hid_spikes[7] | hid_spikes[14] | hid_spikes[17] | hid_spikes[19] | hid_spikes[20] | hid_spikes[21] | hid_spikes[23] | hid_spikes[33] | hid_spikes[34] | hid_spikes[36] | hid_spikes[37] | hid_spikes[44] | hid_spikes[49] | hid_spikes[53] | hid_spikes[58] | hid_spikes[66] | hid_spikes[75]) << 3
        + (hid_spikes[61] | hid_spikes[62]) << 4;
    wire signed [11:0] sum_hid_56 = pos_in_hid_56 - neg_in_hid_56;
    assign hid_spikes[56] = (mem_hid_56 >= 10);
    wire signed [11:0] next_hid_56 = mem_hid_56 - (mem_hid_56 >>> 3) + sum_hid_56;

    reg signed [11:0] mem_hid_57;
    wire signed [11:0] pos_in_hid_57 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 2
        + (hid_spikes[10] | hid_spikes[19] | hid_spikes[20] | hid_spikes[31] | hid_spikes[51] | hid_spikes[55] | hid_spikes[60] | hid_spikes[69] | hid_spikes[79]) << 0
        + (hid_spikes[10] | hid_spikes[16] | hid_spikes[25] | hid_spikes[31] | hid_spikes[34] | hid_spikes[45] | hid_spikes[51] | hid_spikes[60] | hid_spikes[63] | hid_spikes[66] | hid_spikes[72] | hid_spikes[76]) << 1
        + (hid_spikes[19] | hid_spikes[20] | hid_spikes[25] | hid_spikes[34] | hid_spikes[51] | hid_spikes[52] | hid_spikes[55] | hid_spikes[72] | hid_spikes[76] | hid_spikes[79]) << 2
        + (hid_spikes[16] | hid_spikes[31] | hid_spikes[69]) << 3;
    wire signed [11:0] neg_in_hid_57 = (hid_spikes[1] | hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[9] | hid_spikes[11] | hid_spikes[14] | hid_spikes[15] | hid_spikes[22] | hid_spikes[26] | hid_spikes[27] | hid_spikes[30] | hid_spikes[32] | hid_spikes[39] | hid_spikes[42] | hid_spikes[44] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[58] | hid_spikes[59] | hid_spikes[62] | hid_spikes[70] | hid_spikes[71] | hid_spikes[78]) << 0
        + (hid_spikes[2] | hid_spikes[5] | hid_spikes[7] | hid_spikes[8] | hid_spikes[9] | hid_spikes[12] | hid_spikes[17] | hid_spikes[21] | hid_spikes[26] | hid_spikes[37] | hid_spikes[38] | hid_spikes[39] | hid_spikes[40] | hid_spikes[42] | hid_spikes[44] | hid_spikes[47] | hid_spikes[49] | hid_spikes[54] | hid_spikes[58] | hid_spikes[62] | hid_spikes[68] | hid_spikes[70] | hid_spikes[71]) << 1
        + (hid_spikes[1] | hid_spikes[4] | hid_spikes[7] | hid_spikes[8] | hid_spikes[12] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[18] | hid_spikes[21] | hid_spikes[27] | hid_spikes[38] | hid_spikes[46] | hid_spikes[48] | hid_spikes[56] | hid_spikes[57] | hid_spikes[61] | hid_spikes[68] | hid_spikes[78]) << 2
        + (hid_spikes[2] | hid_spikes[6] | hid_spikes[7] | hid_spikes[11] | hid_spikes[21] | hid_spikes[22] | hid_spikes[30] | hid_spikes[32] | hid_spikes[40] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[57] | hid_spikes[59] | hid_spikes[70] | hid_spikes[71] | hid_spikes[73]) << 3
        + (hid_spikes[9] | hid_spikes[13] | hid_spikes[54]) << 4;
    wire signed [11:0] sum_hid_57 = pos_in_hid_57 - neg_in_hid_57;
    assign hid_spikes[57] = (mem_hid_57 >= 10);
    wire signed [11:0] next_hid_57 = mem_hid_57 - (mem_hid_57 >>> 5) + sum_hid_57;

    reg signed [11:0] mem_hid_58;
    wire signed [11:0] pos_in_hid_58 = (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[3]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1] | cochlea_spikes[3]) << 2
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[45] | hid_spikes[56] | hid_spikes[65] | hid_spikes[68]) << 0
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[7] | hid_spikes[23] | hid_spikes[34] | hid_spikes[41] | hid_spikes[45] | hid_spikes[46] | hid_spikes[47] | hid_spikes[55] | hid_spikes[56] | hid_spikes[68]) << 1
        + (hid_spikes[1] | hid_spikes[10] | hid_spikes[25] | hid_spikes[47] | hid_spikes[52] | hid_spikes[76]) << 2
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[14] | hid_spikes[20] | hid_spikes[65]) << 3;
    wire signed [11:0] neg_in_hid_58 = (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[5]) << 3
        + (cochlea_spikes[5]) << 4
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[2]) << 3
        + (cochlea_spikes[2]) << 4
        + (hid_spikes[4] | hid_spikes[6] | hid_spikes[11] | hid_spikes[13] | hid_spikes[17] | hid_spikes[22] | hid_spikes[24] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[29] | hid_spikes[33] | hid_spikes[36] | hid_spikes[38] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[50] | hid_spikes[51] | hid_spikes[54] | hid_spikes[57] | hid_spikes[59] | hid_spikes[61] | hid_spikes[63] | hid_spikes[64] | hid_spikes[73]) << 0
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[19] | hid_spikes[22] | hid_spikes[24] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[29] | hid_spikes[31] | hid_spikes[33] | hid_spikes[35] | hid_spikes[38] | hid_spikes[40] | hid_spikes[43] | hid_spikes[44] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[51] | hid_spikes[57] | hid_spikes[60] | hid_spikes[62] | hid_spikes[63] | hid_spikes[74]) << 1
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[11] | hid_spikes[15] | hid_spikes[16] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[22] | hid_spikes[27] | hid_spikes[28] | hid_spikes[29] | hid_spikes[31] | hid_spikes[32] | hid_spikes[35] | hid_spikes[36] | hid_spikes[38] | hid_spikes[42] | hid_spikes[44] | hid_spikes[50] | hid_spikes[51] | hid_spikes[54] | hid_spikes[57] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63] | hid_spikes[70] | hid_spikes[75] | hid_spikes[77]) << 2
        + (hid_spikes[4] | hid_spikes[6] | hid_spikes[13] | hid_spikes[18] | hid_spikes[35] | hid_spikes[36] | hid_spikes[38] | hid_spikes[40] | hid_spikes[48] | hid_spikes[59] | hid_spikes[64] | hid_spikes[73] | hid_spikes[74]) << 3
        + (hid_spikes[28] | hid_spikes[64]) << 4;
    wire signed [11:0] sum_hid_58 = pos_in_hid_58 - neg_in_hid_58;
    assign hid_spikes[58] = (mem_hid_58 >= 10);
    wire signed [11:0] next_hid_58 = mem_hid_58 - (mem_hid_58 >>> 6) + sum_hid_58;

    reg signed [11:0] mem_hid_59;
    wire signed [11:0] pos_in_hid_59 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[2]) << 3
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 2
        + (hid_spikes[1] | hid_spikes[19] | hid_spikes[20] | hid_spikes[23] | hid_spikes[49] | hid_spikes[50] | hid_spikes[60]) << 0
        + (hid_spikes[1] | hid_spikes[15] | hid_spikes[19] | hid_spikes[20] | hid_spikes[23] | hid_spikes[49] | hid_spikes[50] | hid_spikes[52] | hid_spikes[60] | hid_spikes[64] | hid_spikes[72]) << 1
        + (hid_spikes[19] | hid_spikes[20] | hid_spikes[23] | hid_spikes[33] | hid_spikes[52] | hid_spikes[60] | hid_spikes[79]) << 2
        + (hid_spikes[33] | hid_spikes[72] | hid_spikes[79]) << 3;
    wire signed [11:0] neg_in_hid_59 = (cochlea_spikes[1]) << 2
        + (cochlea_spikes[0] | cochlea_spikes[1]) << 3
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 3
        + (hid_spikes[2] | hid_spikes[10] | hid_spikes[16] | hid_spikes[24] | hid_spikes[25] | hid_spikes[31] | hid_spikes[35] | hid_spikes[37] | hid_spikes[38] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[53] | hid_spikes[71] | hid_spikes[77]) << 0
        + (hid_spikes[0] | hid_spikes[11] | hid_spikes[14] | hid_spikes[16] | hid_spikes[17] | hid_spikes[21] | hid_spikes[25] | hid_spikes[28] | hid_spikes[29] | hid_spikes[31] | hid_spikes[38] | hid_spikes[40] | hid_spikes[43] | hid_spikes[45] | hid_spikes[47] | hid_spikes[54] | hid_spikes[58] | hid_spikes[63] | hid_spikes[65] | hid_spikes[66] | hid_spikes[71] | hid_spikes[75] | hid_spikes[78]) << 1
        + (hid_spikes[2] | hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[10] | hid_spikes[11] | hid_spikes[13] | hid_spikes[14] | hid_spikes[17] | hid_spikes[29] | hid_spikes[35] | hid_spikes[39] | hid_spikes[40] | hid_spikes[42] | hid_spikes[44] | hid_spikes[45] | hid_spikes[54] | hid_spikes[58] | hid_spikes[62] | hid_spikes[65] | hid_spikes[67] | hid_spikes[71] | hid_spikes[77]) << 2
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[7] | hid_spikes[9] | hid_spikes[12] | hid_spikes[13] | hid_spikes[14] | hid_spikes[16] | hid_spikes[24] | hid_spikes[30] | hid_spikes[37] | hid_spikes[39] | hid_spikes[46] | hid_spikes[53] | hid_spikes[56] | hid_spikes[65] | hid_spikes[75]) << 3;
    wire signed [11:0] sum_hid_59 = pos_in_hid_59 - neg_in_hid_59;
    assign hid_spikes[59] = (mem_hid_59 >= 10);
    wire signed [11:0] next_hid_59 = mem_hid_59 - (mem_hid_59 >>> 3) + sum_hid_59;

    reg signed [11:0] mem_hid_60;
    wire signed [11:0] pos_in_hid_60 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[2]) << 4
        + (hid_spikes[6] | hid_spikes[7] | hid_spikes[24] | hid_spikes[33] | hid_spikes[36] | hid_spikes[44] | hid_spikes[47] | hid_spikes[55] | hid_spikes[57] | hid_spikes[62] | hid_spikes[64]) << 0
        + (hid_spikes[7] | hid_spikes[14] | hid_spikes[16] | hid_spikes[23] | hid_spikes[25] | hid_spikes[44] | hid_spikes[47] | hid_spikes[52] | hid_spikes[64] | hid_spikes[70]) << 1
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[21] | hid_spikes[24] | hid_spikes[31] | hid_spikes[33] | hid_spikes[40] | hid_spikes[44] | hid_spikes[52] | hid_spikes[55] | hid_spikes[57] | hid_spikes[62] | hid_spikes[67] | hid_spikes[70] | hid_spikes[71]) << 2
        + (hid_spikes[15] | hid_spikes[25] | hid_spikes[34] | hid_spikes[35] | hid_spikes[36] | hid_spikes[55] | hid_spikes[64] | hid_spikes[72]) << 3;
    wire signed [11:0] neg_in_hid_60 = (cochlea_spikes[4]) << 0
        + (cochlea_spikes[3]) << 1
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[4]) << 3
        + (cochlea_spikes[3]) << 4
        + (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[5]) << 4
        + (hid_spikes[3] | hid_spikes[11] | hid_spikes[22] | hid_spikes[39] | hid_spikes[43] | hid_spikes[49] | hid_spikes[50] | hid_spikes[56] | hid_spikes[66] | hid_spikes[74] | hid_spikes[78]) << 0
        + (hid_spikes[8] | hid_spikes[11] | hid_spikes[19] | hid_spikes[20] | hid_spikes[30] | hid_spikes[38] | hid_spikes[39] | hid_spikes[43] | hid_spikes[51] | hid_spikes[56] | hid_spikes[60] | hid_spikes[66] | hid_spikes[69] | hid_spikes[74]) << 1
        + (hid_spikes[1] | hid_spikes[3] | hid_spikes[11] | hid_spikes[19] | hid_spikes[22] | hid_spikes[28] | hid_spikes[37] | hid_spikes[38] | hid_spikes[39] | hid_spikes[41] | hid_spikes[46] | hid_spikes[50] | hid_spikes[56] | hid_spikes[60] | hid_spikes[66] | hid_spikes[69] | hid_spikes[73] | hid_spikes[77] | hid_spikes[78] | hid_spikes[79]) << 2
        + (hid_spikes[3] | hid_spikes[11] | hid_spikes[20] | hid_spikes[28] | hid_spikes[30] | hid_spikes[38] | hid_spikes[41] | hid_spikes[43] | hid_spikes[49] | hid_spikes[51] | hid_spikes[65] | hid_spikes[73] | hid_spikes[77]) << 3
        + (hid_spikes[30] | hid_spikes[54]) << 4;
    wire signed [11:0] sum_hid_60 = pos_in_hid_60 - neg_in_hid_60;
    assign hid_spikes[60] = (mem_hid_60 >= 10);
    wire signed [11:0] next_hid_60 = mem_hid_60 - (mem_hid_60 >>> 4) + sum_hid_60;

    reg signed [11:0] mem_hid_61;
    wire signed [11:0] pos_in_hid_61 = (cochlea_spikes[3]) << 2
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[13] | hid_spikes[16] | hid_spikes[23] | hid_spikes[32] | hid_spikes[33] | hid_spikes[34] | hid_spikes[57] | hid_spikes[66] | hid_spikes[68] | hid_spikes[71] | hid_spikes[74] | hid_spikes[75] | hid_spikes[76]) << 0
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[10] | hid_spikes[13] | hid_spikes[14] | hid_spikes[16] | hid_spikes[17] | hid_spikes[18] | hid_spikes[31] | hid_spikes[33] | hid_spikes[34] | hid_spikes[42] | hid_spikes[66] | hid_spikes[71] | hid_spikes[76]) << 1
        + (hid_spikes[14] | hid_spikes[16] | hid_spikes[18] | hid_spikes[20] | hid_spikes[29] | hid_spikes[32] | hid_spikes[33] | hid_spikes[51] | hid_spikes[53] | hid_spikes[57] | hid_spikes[66] | hid_spikes[68] | hid_spikes[71] | hid_spikes[74] | hid_spikes[79]) << 2
        + (hid_spikes[23] | hid_spikes[31] | hid_spikes[57] | hid_spikes[75] | hid_spikes[76] | hid_spikes[79]) << 3
        + (hid_spikes[16] | hid_spikes[72]) << 4;
    wire signed [11:0] neg_in_hid_61 = (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0] | cochlea_spikes[2]) << 2
        + (cochlea_spikes[2]) << 4
        + (cochlea_spikes[2]) << 5
        + (cochlea_spikes[2]) << 6
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[4]) << 3
        + (cochlea_spikes[1] | cochlea_spikes[4]) << 4
        + (cochlea_spikes[1]) << 5
        + (cochlea_spikes[4]) << 6
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[2] | hid_spikes[7] | hid_spikes[8] | hid_spikes[19] | hid_spikes[21] | hid_spikes[22] | hid_spikes[27] | hid_spikes[30] | hid_spikes[37] | hid_spikes[38] | hid_spikes[39] | hid_spikes[43] | hid_spikes[48] | hid_spikes[49] | hid_spikes[54] | hid_spikes[55] | hid_spikes[58] | hid_spikes[61] | hid_spikes[63] | hid_spikes[64] | hid_spikes[65] | hid_spikes[67] | hid_spikes[70] | hid_spikes[73]) << 0
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[7] | hid_spikes[8] | hid_spikes[9] | hid_spikes[19] | hid_spikes[22] | hid_spikes[24] | hid_spikes[27] | hid_spikes[28] | hid_spikes[35] | hid_spikes[38] | hid_spikes[39] | hid_spikes[43] | hid_spikes[46] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[55] | hid_spikes[56] | hid_spikes[58] | hid_spikes[61] | hid_spikes[63] | hid_spikes[64] | hid_spikes[67]) << 1
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[8] | hid_spikes[9] | hid_spikes[15] | hid_spikes[21] | hid_spikes[22] | hid_spikes[24] | hid_spikes[26] | hid_spikes[28] | hid_spikes[30] | hid_spikes[35] | hid_spikes[40] | hid_spikes[43] | hid_spikes[49] | hid_spikes[54] | hid_spikes[63] | hid_spikes[64] | hid_spikes[65] | hid_spikes[67] | hid_spikes[70]) << 2
        + (hid_spikes[4] | hid_spikes[6] | hid_spikes[11] | hid_spikes[25] | hid_spikes[28] | hid_spikes[37] | hid_spikes[46] | hid_spikes[54] | hid_spikes[58] | hid_spikes[67] | hid_spikes[73]) << 3
        + (hid_spikes[0] | hid_spikes[21] | hid_spikes[47] | hid_spikes[56] | hid_spikes[62]) << 4;
    wire signed [11:0] sum_hid_61 = pos_in_hid_61 - neg_in_hid_61;
    assign hid_spikes[61] = (mem_hid_61 >= 10);
    wire signed [11:0] next_hid_61 = mem_hid_61 - (mem_hid_61 >>> 6) + sum_hid_61;

    reg signed [11:0] mem_hid_62;
    wire signed [11:0] pos_in_hid_62 = (cochlea_spikes[3]) << 1
        + (cochlea_spikes[3]) << 2
        + (cochlea_spikes[5]) << 2
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[6] | hid_spikes[31] | hid_spikes[32] | hid_spikes[34] | hid_spikes[39] | hid_spikes[42] | hid_spikes[43] | hid_spikes[58] | hid_spikes[61] | hid_spikes[64] | hid_spikes[72] | hid_spikes[78]) << 0
        + (hid_spikes[3] | hid_spikes[16] | hid_spikes[23] | hid_spikes[24] | hid_spikes[31] | hid_spikes[34] | hid_spikes[39] | hid_spikes[42] | hid_spikes[51] | hid_spikes[58] | hid_spikes[64] | hid_spikes[78]) << 1
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[20] | hid_spikes[24] | hid_spikes[31] | hid_spikes[32] | hid_spikes[34] | hid_spikes[39] | hid_spikes[42] | hid_spikes[43] | hid_spikes[54] | hid_spikes[57] | hid_spikes[61] | hid_spikes[64] | hid_spikes[72]) << 2
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[6] | hid_spikes[20] | hid_spikes[32]) << 3
        + (hid_spikes[1]) << 4;
    wire signed [11:0] neg_in_hid_62 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[1] | cochlea_spikes[2]) << 1
        + (cochlea_spikes[1] | cochlea_spikes[2]) << 2
        + (cochlea_spikes[2]) << 4
        + (cochlea_spikes[1]) << 5
        + (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 5
        + (hid_spikes[8] | hid_spikes[9] | hid_spikes[13] | hid_spikes[18] | hid_spikes[22] | hid_spikes[28] | hid_spikes[36] | hid_spikes[38] | hid_spikes[47] | hid_spikes[48] | hid_spikes[50] | hid_spikes[63] | hid_spikes[67] | hid_spikes[68] | hid_spikes[76] | hid_spikes[77]) << 0
        + (hid_spikes[8] | hid_spikes[9] | hid_spikes[13] | hid_spikes[14] | hid_spikes[18] | hid_spikes[35] | hid_spikes[36] | hid_spikes[38] | hid_spikes[44] | hid_spikes[46] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[59] | hid_spikes[60] | hid_spikes[67] | hid_spikes[68]) << 1
        + (hid_spikes[4] | hid_spikes[14] | hid_spikes[22] | hid_spikes[28] | hid_spikes[29] | hid_spikes[35] | hid_spikes[50] | hid_spikes[59] | hid_spikes[63] | hid_spikes[67] | hid_spikes[68] | hid_spikes[71] | hid_spikes[75] | hid_spikes[76] | hid_spikes[77]) << 2
        + (hid_spikes[9] | hid_spikes[12] | hid_spikes[26] | hid_spikes[35] | hid_spikes[46] | hid_spikes[49] | hid_spikes[56] | hid_spikes[67]) << 3;
    wire signed [11:0] sum_hid_62 = pos_in_hid_62 - neg_in_hid_62;
    assign hid_spikes[62] = (mem_hid_62 >= 10);
    wire signed [11:0] next_hid_62 = mem_hid_62 - (mem_hid_62 >>> 6) + sum_hid_62;

    reg signed [11:0] mem_hid_63;
    wire signed [11:0] pos_in_hid_63 = (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[3]) << 1
        + (hid_spikes[6] | hid_spikes[13] | hid_spikes[16] | hid_spikes[25] | hid_spikes[34] | hid_spikes[42] | hid_spikes[50] | hid_spikes[60]) << 0
        + (hid_spikes[6] | hid_spikes[13] | hid_spikes[16] | hid_spikes[17] | hid_spikes[25] | hid_spikes[34] | hid_spikes[39] | hid_spikes[42] | hid_spikes[50] | hid_spikes[60] | hid_spikes[67]) << 1
        + (hid_spikes[6] | hid_spikes[13] | hid_spikes[17] | hid_spikes[25] | hid_spikes[39] | hid_spikes[44] | hid_spikes[60] | hid_spikes[74]) << 2
        + (hid_spikes[6] | hid_spikes[35] | hid_spikes[40] | hid_spikes[47] | hid_spikes[74]) << 3;
    wire signed [11:0] neg_in_hid_63 = (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4] | cochlea_spikes[5]) << 3
        + (cochlea_spikes[4]) << 4
        + (cochlea_spikes[4]) << 5
        + (cochlea_spikes[4]) << 6
        + (cochlea_spikes[1] | cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[1] | cochlea_spikes[2]) << 4
        + (cochlea_spikes[1]) << 6
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[3] | hid_spikes[4] | hid_spikes[7] | hid_spikes[9] | hid_spikes[14] | hid_spikes[19] | hid_spikes[26] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[36] | hid_spikes[37] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[49] | hid_spikes[53] | hid_spikes[56] | hid_spikes[59] | hid_spikes[62] | hid_spikes[69] | hid_spikes[70] | hid_spikes[73] | hid_spikes[75] | hid_spikes[76] | hid_spikes[78] | hid_spikes[79]) << 0
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[4] | hid_spikes[7] | hid_spikes[9] | hid_spikes[10] | hid_spikes[12] | hid_spikes[14] | hid_spikes[15] | hid_spikes[18] | hid_spikes[19] | hid_spikes[22] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[29] | hid_spikes[37] | hid_spikes[43] | hid_spikes[51] | hid_spikes[53] | hid_spikes[54] | hid_spikes[62] | hid_spikes[66] | hid_spikes[69] | hid_spikes[71] | hid_spikes[72] | hid_spikes[76] | hid_spikes[77]) << 1
        + (hid_spikes[0] | hid_spikes[3] | hid_spikes[7] | hid_spikes[9] | hid_spikes[10] | hid_spikes[11] | hid_spikes[14] | hid_spikes[20] | hid_spikes[22] | hid_spikes[27] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[36] | hid_spikes[38] | hid_spikes[41] | hid_spikes[43] | hid_spikes[46] | hid_spikes[51] | hid_spikes[54] | hid_spikes[56] | hid_spikes[58] | hid_spikes[68] | hid_spikes[72] | hid_spikes[73] | hid_spikes[78] | hid_spikes[79]) << 2
        + (hid_spikes[3] | hid_spikes[11] | hid_spikes[12] | hid_spikes[18] | hid_spikes[32] | hid_spikes[33] | hid_spikes[36] | hid_spikes[37] | hid_spikes[38] | hid_spikes[45] | hid_spikes[49] | hid_spikes[53] | hid_spikes[58] | hid_spikes[63] | hid_spikes[66] | hid_spikes[70] | hid_spikes[73] | hid_spikes[77] | hid_spikes[78]) << 3
        + (hid_spikes[30] | hid_spikes[56] | hid_spikes[59] | hid_spikes[75]) << 4;
    wire signed [11:0] sum_hid_63 = pos_in_hid_63 - neg_in_hid_63;
    assign hid_spikes[63] = (mem_hid_63 >= 10);
    wire signed [11:0] next_hid_63 = mem_hid_63 - (mem_hid_63 >>> 5) + sum_hid_63;

    reg signed [11:0] mem_hid_64;
    wire signed [11:0] pos_in_hid_64 = (cochlea_spikes[2] | cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 1
        + (hid_spikes[2] | hid_spikes[5] | hid_spikes[6] | hid_spikes[21] | hid_spikes[33] | hid_spikes[50] | hid_spikes[60]) << 0
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[6] | hid_spikes[21] | hid_spikes[45] | hid_spikes[60]) << 1
        + (hid_spikes[2] | hid_spikes[5] | hid_spikes[10] | hid_spikes[33] | hid_spikes[45] | hid_spikes[50] | hid_spikes[62] | hid_spikes[64] | hid_spikes[72]) << 2
        + (hid_spikes[0] | hid_spikes[28]) << 3;
    wire signed [11:0] neg_in_hid_64 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 1
        + (hid_spikes[3] | hid_spikes[4] | hid_spikes[9] | hid_spikes[11] | hid_spikes[12] | hid_spikes[14] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[27] | hid_spikes[30] | hid_spikes[35] | hid_spikes[36] | hid_spikes[37] | hid_spikes[38] | hid_spikes[43] | hid_spikes[44] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[56] | hid_spikes[58] | hid_spikes[59] | hid_spikes[61] | hid_spikes[69] | hid_spikes[70] | hid_spikes[73] | hid_spikes[75]) << 0
        + (hid_spikes[1] | hid_spikes[3] | hid_spikes[4] | hid_spikes[7] | hid_spikes[12] | hid_spikes[15] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[22] | hid_spikes[24] | hid_spikes[27] | hid_spikes[31] | hid_spikes[34] | hid_spikes[35] | hid_spikes[36] | hid_spikes[38] | hid_spikes[40] | hid_spikes[43] | hid_spikes[44] | hid_spikes[54] | hid_spikes[55] | hid_spikes[56] | hid_spikes[59] | hid_spikes[68] | hid_spikes[69] | hid_spikes[70] | hid_spikes[71] | hid_spikes[73] | hid_spikes[74] | hid_spikes[77] | hid_spikes[79]) << 1
        + (hid_spikes[9] | hid_spikes[15] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[20] | hid_spikes[22] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[29] | hid_spikes[35] | hid_spikes[39] | hid_spikes[42] | hid_spikes[43] | hid_spikes[46] | hid_spikes[47] | hid_spikes[58] | hid_spikes[59] | hid_spikes[61] | hid_spikes[68] | hid_spikes[71] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78] | hid_spikes[79]) << 2
        + (hid_spikes[1] | hid_spikes[4] | hid_spikes[7] | hid_spikes[11] | hid_spikes[15] | hid_spikes[25] | hid_spikes[27] | hid_spikes[30] | hid_spikes[34] | hid_spikes[36] | hid_spikes[37] | hid_spikes[47] | hid_spikes[48] | hid_spikes[53] | hid_spikes[55] | hid_spikes[58] | hid_spikes[59] | hid_spikes[61] | hid_spikes[67] | hid_spikes[70] | hid_spikes[71] | hid_spikes[75] | hid_spikes[78]) << 3
        + (hid_spikes[11] | hid_spikes[19] | hid_spikes[20] | hid_spikes[30] | hid_spikes[54] | hid_spikes[56] | hid_spikes[61] | hid_spikes[66] | hid_spikes[77]) << 4
        + (hid_spikes[14] | hid_spikes[36] | hid_spikes[39]) << 5;
    wire signed [11:0] sum_hid_64 = pos_in_hid_64 - neg_in_hid_64;
    assign hid_spikes[64] = (mem_hid_64 >= 10);
    wire signed [11:0] next_hid_64 = mem_hid_64 - (mem_hid_64 >>> 6) + sum_hid_64;

    reg signed [11:0] mem_hid_65;
    wire signed [11:0] pos_in_hid_65 = (cochlea_spikes[2]) << 3
        + (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 2
        + (hid_spikes[1] | hid_spikes[4] | hid_spikes[21] | hid_spikes[29] | hid_spikes[31] | hid_spikes[35] | hid_spikes[44] | hid_spikes[69] | hid_spikes[70]) << 0
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[29] | hid_spikes[31] | hid_spikes[40] | hid_spikes[69]) << 1
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[16] | hid_spikes[17] | hid_spikes[21] | hid_spikes[35] | hid_spikes[41] | hid_spikes[43] | hid_spikes[44] | hid_spikes[51] | hid_spikes[55] | hid_spikes[70]) << 2
        + (hid_spikes[16]) << 3;
    wire signed [11:0] neg_in_hid_65 = (cochlea_spikes[3] | cochlea_spikes[4]) << 1
        + (cochlea_spikes[3]) << 2
        + (cochlea_spikes[4]) << 5
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[1]) << 3
        + (hid_spikes[11] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[20] | hid_spikes[22] | hid_spikes[25] | hid_spikes[26] | hid_spikes[27] | hid_spikes[36] | hid_spikes[39] | hid_spikes[45] | hid_spikes[46] | hid_spikes[49] | hid_spikes[54] | hid_spikes[59] | hid_spikes[65] | hid_spikes[67] | hid_spikes[68] | hid_spikes[76] | hid_spikes[79]) << 0
        + (hid_spikes[0] | hid_spikes[11] | hid_spikes[22] | hid_spikes[25] | hid_spikes[30] | hid_spikes[33] | hid_spikes[36] | hid_spikes[42] | hid_spikes[45] | hid_spikes[49] | hid_spikes[54] | hid_spikes[60] | hid_spikes[61] | hid_spikes[68] | hid_spikes[76]) << 1
        + (hid_spikes[0] | hid_spikes[7] | hid_spikes[10] | hid_spikes[12] | hid_spikes[14] | hid_spikes[15] | hid_spikes[18] | hid_spikes[19] | hid_spikes[20] | hid_spikes[22] | hid_spikes[25] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[30] | hid_spikes[33] | hid_spikes[34] | hid_spikes[36] | hid_spikes[37] | hid_spikes[39] | hid_spikes[42] | hid_spikes[45] | hid_spikes[46] | hid_spikes[53] | hid_spikes[56] | hid_spikes[59] | hid_spikes[60] | hid_spikes[64] | hid_spikes[67] | hid_spikes[68] | hid_spikes[72] | hid_spikes[77] | hid_spikes[79]) << 2
        + (hid_spikes[0] | hid_spikes[7] | hid_spikes[13] | hid_spikes[20] | hid_spikes[36] | hid_spikes[45] | hid_spikes[53] | hid_spikes[54] | hid_spikes[61] | hid_spikes[65] | hid_spikes[71] | hid_spikes[77] | hid_spikes[78]) << 3;
    wire signed [11:0] sum_hid_65 = pos_in_hid_65 - neg_in_hid_65;
    assign hid_spikes[65] = (mem_hid_65 >= 10);
    wire signed [11:0] next_hid_65 = mem_hid_65 - (mem_hid_65 >>> 3) + sum_hid_65;

    reg signed [11:0] mem_hid_66;
    wire signed [11:0] pos_in_hid_66 = (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 2
        + (cochlea_spikes[5]) << 2
        + (hid_spikes[14] | hid_spikes[20] | hid_spikes[31] | hid_spikes[32] | hid_spikes[40] | hid_spikes[59] | hid_spikes[75]) << 0
        + (hid_spikes[8] | hid_spikes[14] | hid_spikes[20] | hid_spikes[32] | hid_spikes[40] | hid_spikes[59] | hid_spikes[70] | hid_spikes[72] | hid_spikes[73] | hid_spikes[75]) << 1
        + (hid_spikes[3] | hid_spikes[8] | hid_spikes[10] | hid_spikes[14] | hid_spikes[26] | hid_spikes[31] | hid_spikes[37] | hid_spikes[42] | hid_spikes[70] | hid_spikes[72] | hid_spikes[77]) << 2
        + (hid_spikes[8] | hid_spikes[18]) << 3;
    wire signed [11:0] neg_in_hid_66 = (cochlea_spikes[0]) << 0
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[0]) << 5
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 4
        + (hid_spikes[5] | hid_spikes[7] | hid_spikes[9] | hid_spikes[11] | hid_spikes[13] | hid_spikes[21] | hid_spikes[24] | hid_spikes[27] | hid_spikes[28] | hid_spikes[30] | hid_spikes[33] | hid_spikes[36] | hid_spikes[39] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[50] | hid_spikes[53] | hid_spikes[55] | hid_spikes[61] | hid_spikes[66] | hid_spikes[67] | hid_spikes[69] | hid_spikes[76] | hid_spikes[79]) << 0
        + (hid_spikes[0] | hid_spikes[4] | hid_spikes[11] | hid_spikes[13] | hid_spikes[19] | hid_spikes[21] | hid_spikes[22] | hid_spikes[27] | hid_spikes[30] | hid_spikes[36] | hid_spikes[47] | hid_spikes[50] | hid_spikes[53] | hid_spikes[55] | hid_spikes[58] | hid_spikes[61] | hid_spikes[63] | hid_spikes[66] | hid_spikes[69] | hid_spikes[78] | hid_spikes[79]) << 1
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[6] | hid_spikes[7] | hid_spikes[9] | hid_spikes[11] | hid_spikes[23] | hid_spikes[24] | hid_spikes[27] | hid_spikes[28] | hid_spikes[30] | hid_spikes[33] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[47] | hid_spikes[50] | hid_spikes[54] | hid_spikes[57] | hid_spikes[61] | hid_spikes[63] | hid_spikes[64] | hid_spikes[65] | hid_spikes[71] | hid_spikes[74] | hid_spikes[76] | hid_spikes[79]) << 2
        + (hid_spikes[13] | hid_spikes[21] | hid_spikes[38] | hid_spikes[39] | hid_spikes[44] | hid_spikes[56] | hid_spikes[67] | hid_spikes[71] | hid_spikes[78]) << 3
        + (hid_spikes[17] | hid_spikes[36] | hid_spikes[64]) << 4;
    wire signed [11:0] sum_hid_66 = pos_in_hid_66 - neg_in_hid_66;
    assign hid_spikes[66] = (mem_hid_66 >= 10);
    wire signed [11:0] next_hid_66 = mem_hid_66 - (mem_hid_66 >>> 6) + sum_hid_66;

    reg signed [11:0] mem_hid_67;
    wire signed [11:0] pos_in_hid_67 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 1
        + (cochlea_spikes[3]) << 2
        + (hid_spikes[3] | hid_spikes[8] | hid_spikes[12] | hid_spikes[29] | hid_spikes[45] | hid_spikes[46] | hid_spikes[58] | hid_spikes[61] | hid_spikes[62]) << 0
        + (hid_spikes[3] | hid_spikes[8] | hid_spikes[12] | hid_spikes[22] | hid_spikes[29] | hid_spikes[46] | hid_spikes[58] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63] | hid_spikes[66] | hid_spikes[67] | hid_spikes[71]) << 1
        + (hid_spikes[3] | hid_spikes[4] | hid_spikes[22] | hid_spikes[40] | hid_spikes[43] | hid_spikes[45] | hid_spikes[63] | hid_spikes[67] | hid_spikes[71] | hid_spikes[73]) << 2
        + (hid_spikes[4] | hid_spikes[11] | hid_spikes[73]) << 3;
    wire signed [11:0] neg_in_hid_67 = (cochlea_spikes[5]) << 2
        + (cochlea_spikes[5]) << 3
        + (cochlea_spikes[4]) << 4
        + (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[2]) << 3
        + (hid_spikes[7] | hid_spikes[9] | hid_spikes[15] | hid_spikes[18] | hid_spikes[19] | hid_spikes[21] | hid_spikes[25] | hid_spikes[33] | hid_spikes[34] | hid_spikes[35] | hid_spikes[36] | hid_spikes[47] | hid_spikes[48] | hid_spikes[52] | hid_spikes[55] | hid_spikes[64] | hid_spikes[69] | hid_spikes[70] | hid_spikes[75] | hid_spikes[78]) << 0
        + (hid_spikes[1] | hid_spikes[16] | hid_spikes[19] | hid_spikes[21] | hid_spikes[23] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[30] | hid_spikes[33] | hid_spikes[34] | hid_spikes[35] | hid_spikes[44] | hid_spikes[47] | hid_spikes[52] | hid_spikes[53] | hid_spikes[59] | hid_spikes[60] | hid_spikes[65] | hid_spikes[69] | hid_spikes[72] | hid_spikes[74] | hid_spikes[75] | hid_spikes[78]) << 1
        + (hid_spikes[0] | hid_spikes[7] | hid_spikes[13] | hid_spikes[15] | hid_spikes[16] | hid_spikes[21] | hid_spikes[27] | hid_spikes[28] | hid_spikes[33] | hid_spikes[34] | hid_spikes[35] | hid_spikes[36] | hid_spikes[41] | hid_spikes[44] | hid_spikes[48] | hid_spikes[55] | hid_spikes[60] | hid_spikes[64] | hid_spikes[65] | hid_spikes[69] | hid_spikes[70] | hid_spikes[75] | hid_spikes[78] | hid_spikes[79]) << 2
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[9] | hid_spikes[16] | hid_spikes[18] | hid_spikes[24] | hid_spikes[25] | hid_spikes[31] | hid_spikes[32] | hid_spikes[33] | hid_spikes[36] | hid_spikes[44] | hid_spikes[48] | hid_spikes[53] | hid_spikes[55] | hid_spikes[59] | hid_spikes[60] | hid_spikes[64] | hid_spikes[70] | hid_spikes[72] | hid_spikes[75]) << 3
        + (hid_spikes[14] | hid_spikes[16] | hid_spikes[19] | hid_spikes[20] | hid_spikes[55] | hid_spikes[57] | hid_spikes[79]) << 4;
    wire signed [11:0] sum_hid_67 = pos_in_hid_67 - neg_in_hid_67;
    assign hid_spikes[67] = (mem_hid_67 >= 10);
    wire signed [11:0] next_hid_67 = mem_hid_67 - (mem_hid_67 >>> 5) + sum_hid_67;

    reg signed [11:0] mem_hid_68;
    wire signed [11:0] pos_in_hid_68 = (cochlea_spikes[0] | cochlea_spikes[2]) << 2
        + (cochlea_spikes[2]) << 3
        + (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4] | cochlea_spikes[5]) << 2
        + (hid_spikes[12] | hid_spikes[17] | hid_spikes[19] | hid_spikes[24] | hid_spikes[25] | hid_spikes[32] | hid_spikes[36] | hid_spikes[46] | hid_spikes[48] | hid_spikes[49] | hid_spikes[51] | hid_spikes[52] | hid_spikes[57] | hid_spikes[62] | hid_spikes[64] | hid_spikes[65] | hid_spikes[70] | hid_spikes[71]) << 0
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[12] | hid_spikes[15] | hid_spikes[19] | hid_spikes[24] | hid_spikes[31] | hid_spikes[32] | hid_spikes[46] | hid_spikes[48] | hid_spikes[49] | hid_spikes[57] | hid_spikes[65] | hid_spikes[70] | hid_spikes[76] | hid_spikes[79]) << 1
        + (hid_spikes[0] | hid_spikes[7] | hid_spikes[12] | hid_spikes[14] | hid_spikes[15] | hid_spikes[17] | hid_spikes[31] | hid_spikes[34] | hid_spikes[46] | hid_spikes[51] | hid_spikes[52] | hid_spikes[61] | hid_spikes[62] | hid_spikes[64] | hid_spikes[65] | hid_spikes[66] | hid_spikes[71] | hid_spikes[76]) << 2
        + (hid_spikes[0] | hid_spikes[6] | hid_spikes[25] | hid_spikes[36] | hid_spikes[59] | hid_spikes[72]) << 3;
    wire signed [11:0] neg_in_hid_68 = (cochlea_spikes[3]) << 1
        + (cochlea_spikes[3]) << 3
        + (cochlea_spikes[3]) << 4
        + (hid_spikes[1] | hid_spikes[3] | hid_spikes[4] | hid_spikes[11] | hid_spikes[21] | hid_spikes[28] | hid_spikes[30] | hid_spikes[38] | hid_spikes[39] | hid_spikes[54] | hid_spikes[68] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 0
        + (hid_spikes[3] | hid_spikes[20] | hid_spikes[21] | hid_spikes[26] | hid_spikes[38] | hid_spikes[41] | hid_spikes[42] | hid_spikes[43] | hid_spikes[50] | hid_spikes[53] | hid_spikes[54] | hid_spikes[63] | hid_spikes[67] | hid_spikes[68] | hid_spikes[74] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 1
        + (hid_spikes[1] | hid_spikes[4] | hid_spikes[8] | hid_spikes[11] | hid_spikes[20] | hid_spikes[26] | hid_spikes[28] | hid_spikes[30] | hid_spikes[33] | hid_spikes[39] | hid_spikes[40] | hid_spikes[42] | hid_spikes[47] | hid_spikes[54] | hid_spikes[63] | hid_spikes[67] | hid_spikes[68] | hid_spikes[74] | hid_spikes[78]) << 2
        + (hid_spikes[11] | hid_spikes[30] | hid_spikes[38] | hid_spikes[42] | hid_spikes[43] | hid_spikes[67] | hid_spikes[69] | hid_spikes[77] | hid_spikes[78]) << 3
        + (hid_spikes[20] | hid_spikes[58]) << 4;
    wire signed [11:0] sum_hid_68 = pos_in_hid_68 - neg_in_hid_68;
    assign hid_spikes[68] = (mem_hid_68 >= 10);
    wire signed [11:0] next_hid_68 = mem_hid_68 - (mem_hid_68 >>> 6) + sum_hid_68;

    reg signed [11:0] mem_hid_69;
    wire signed [11:0] pos_in_hid_69 = (cochlea_spikes[5]) << 1
        + (cochlea_spikes[5]) << 3
        + (hid_spikes[16] | hid_spikes[22] | hid_spikes[25] | hid_spikes[26] | hid_spikes[27] | hid_spikes[29] | hid_spikes[31] | hid_spikes[33] | hid_spikes[45] | hid_spikes[52] | hid_spikes[56] | hid_spikes[59] | hid_spikes[67] | hid_spikes[70] | hid_spikes[73] | hid_spikes[74] | hid_spikes[75] | hid_spikes[77]) << 0
        + (hid_spikes[10] | hid_spikes[13] | hid_spikes[19] | hid_spikes[23] | hid_spikes[25] | hid_spikes[27] | hid_spikes[29] | hid_spikes[31] | hid_spikes[32] | hid_spikes[34] | hid_spikes[35] | hid_spikes[45] | hid_spikes[51] | hid_spikes[52] | hid_spikes[59] | hid_spikes[68] | hid_spikes[70] | hid_spikes[72] | hid_spikes[73] | hid_spikes[75] | hid_spikes[77]) << 1
        + (hid_spikes[10] | hid_spikes[11] | hid_spikes[16] | hid_spikes[18] | hid_spikes[19] | hid_spikes[23] | hid_spikes[27] | hid_spikes[31] | hid_spikes[32] | hid_spikes[33] | hid_spikes[34] | hid_spikes[35] | hid_spikes[40] | hid_spikes[45] | hid_spikes[56] | hid_spikes[63] | hid_spikes[72] | hid_spikes[74] | hid_spikes[77]) << 2
        + (hid_spikes[22] | hid_spikes[25] | hid_spikes[26] | hid_spikes[31] | hid_spikes[34] | hid_spikes[51] | hid_spikes[59] | hid_spikes[63] | hid_spikes[67] | hid_spikes[68] | hid_spikes[77]) << 3;
    wire signed [11:0] neg_in_hid_69 = (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[2] | cochlea_spikes[4]) << 3
        + (cochlea_spikes[3]) << 0
        + (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[3]) << 3
        + (hid_spikes[3] | hid_spikes[30] | hid_spikes[44] | hid_spikes[46] | hid_spikes[48] | hid_spikes[53] | hid_spikes[60] | hid_spikes[65] | hid_spikes[66] | hid_spikes[69] | hid_spikes[78]) << 0
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[12] | hid_spikes[20] | hid_spikes[21] | hid_spikes[28] | hid_spikes[38] | hid_spikes[41] | hid_spikes[43] | hid_spikes[48] | hid_spikes[53] | hid_spikes[60] | hid_spikes[64] | hid_spikes[66] | hid_spikes[69]) << 1
        + (hid_spikes[0] | hid_spikes[1] | hid_spikes[5] | hid_spikes[6] | hid_spikes[7] | hid_spikes[17] | hid_spikes[21] | hid_spikes[30] | hid_spikes[43] | hid_spikes[46] | hid_spikes[53] | hid_spikes[55] | hid_spikes[64] | hid_spikes[66] | hid_spikes[76]) << 2
        + (hid_spikes[17] | hid_spikes[21] | hid_spikes[38] | hid_spikes[42] | hid_spikes[44] | hid_spikes[55] | hid_spikes[60] | hid_spikes[65] | hid_spikes[78]) << 3
        + (hid_spikes[28] | hid_spikes[30] | hid_spikes[61]) << 4
        + (hid_spikes[64]) << 5;
    wire signed [11:0] sum_hid_69 = pos_in_hid_69 - neg_in_hid_69;
    assign hid_spikes[69] = (mem_hid_69 >= 10);
    wire signed [11:0] next_hid_69 = mem_hid_69 - (mem_hid_69 >>> 6) + sum_hid_69;

    reg signed [11:0] mem_hid_70;
    wire signed [11:0] pos_in_hid_70 = (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (cochlea_spikes[5]) << 2
        + (hid_spikes[6] | hid_spikes[14] | hid_spikes[15] | hid_spikes[24] | hid_spikes[28] | hid_spikes[32] | hid_spikes[46] | hid_spikes[52] | hid_spikes[62] | hid_spikes[63] | hid_spikes[67] | hid_spikes[72] | hid_spikes[76] | hid_spikes[77]) << 0
        + (hid_spikes[6] | hid_spikes[14] | hid_spikes[15] | hid_spikes[28] | hid_spikes[41] | hid_spikes[45] | hid_spikes[46] | hid_spikes[60] | hid_spikes[62] | hid_spikes[63] | hid_spikes[66] | hid_spikes[67]) << 1
        + (hid_spikes[0] | hid_spikes[6] | hid_spikes[9] | hid_spikes[15] | hid_spikes[24] | hid_spikes[32] | hid_spikes[40] | hid_spikes[52] | hid_spikes[56] | hid_spikes[60] | hid_spikes[66] | hid_spikes[76] | hid_spikes[77]) << 2
        + (hid_spikes[0] | hid_spikes[40] | hid_spikes[59] | hid_spikes[60] | hid_spikes[62] | hid_spikes[72]) << 3;
    wire signed [11:0] neg_in_hid_70 = (cochlea_spikes[3] | cochlea_spikes[4]) << 2
        + (cochlea_spikes[3]) << 5
        + (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[0]) << 4
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[4] | hid_spikes[7] | hid_spikes[8] | hid_spikes[19] | hid_spikes[29] | hid_spikes[42] | hid_spikes[47] | hid_spikes[49] | hid_spikes[53] | hid_spikes[57] | hid_spikes[64] | hid_spikes[69]) << 0
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[4] | hid_spikes[7] | hid_spikes[11] | hid_spikes[13] | hid_spikes[19] | hid_spikes[21] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[37] | hid_spikes[39] | hid_spikes[42] | hid_spikes[47] | hid_spikes[49] | hid_spikes[64] | hid_spikes[65] | hid_spikes[69] | hid_spikes[70] | hid_spikes[71]) << 1
        + (hid_spikes[8] | hid_spikes[10] | hid_spikes[13] | hid_spikes[26] | hid_spikes[30] | hid_spikes[37] | hid_spikes[43] | hid_spikes[54] | hid_spikes[65] | hid_spikes[74] | hid_spikes[75]) << 2
        + (hid_spikes[20] | hid_spikes[21] | hid_spikes[31] | hid_spikes[39] | hid_spikes[44] | hid_spikes[53] | hid_spikes[57] | hid_spikes[64] | hid_spikes[65] | hid_spikes[78]) << 3
        + (hid_spikes[21] | hid_spikes[38] | hid_spikes[64]) << 4;
    wire signed [11:0] sum_hid_70 = pos_in_hid_70 - neg_in_hid_70;
    assign hid_spikes[70] = (mem_hid_70 >= 10);
    wire signed [11:0] next_hid_70 = mem_hid_70 - (mem_hid_70 >>> 4) + sum_hid_70;

    reg signed [11:0] mem_hid_71;
    wire signed [11:0] pos_in_hid_71 = (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 1
        + (cochlea_spikes[4]) << 2
        + (hid_spikes[2] | hid_spikes[8] | hid_spikes[16] | hid_spikes[17] | hid_spikes[20] | hid_spikes[31] | hid_spikes[33] | hid_spikes[37] | hid_spikes[61]) << 0
        + (hid_spikes[2] | hid_spikes[8] | hid_spikes[16] | hid_spikes[21] | hid_spikes[33] | hid_spikes[61]) << 1
        + (hid_spikes[2] | hid_spikes[3] | hid_spikes[17] | hid_spikes[21] | hid_spikes[25] | hid_spikes[31] | hid_spikes[33] | hid_spikes[37] | hid_spikes[47]) << 2
        + (hid_spikes[20]) << 3;
    wire signed [11:0] neg_in_hid_71 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[2]) << 3
        + (cochlea_spikes[2]) << 4
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[5]) << 3
        + (cochlea_spikes[1]) << 4
        + (hid_spikes[11] | hid_spikes[12] | hid_spikes[14] | hid_spikes[18] | hid_spikes[29] | hid_spikes[30] | hid_spikes[34] | hid_spikes[35] | hid_spikes[36] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[49] | hid_spikes[53] | hid_spikes[56] | hid_spikes[59] | hid_spikes[63] | hid_spikes[64] | hid_spikes[65] | hid_spikes[66] | hid_spikes[67] | hid_spikes[69] | hid_spikes[71] | hid_spikes[72] | hid_spikes[73] | hid_spikes[75] | hid_spikes[76] | hid_spikes[77] | hid_spikes[78] | hid_spikes[79]) << 0
        + (hid_spikes[0] | hid_spikes[10] | hid_spikes[11] | hid_spikes[15] | hid_spikes[22] | hid_spikes[27] | hid_spikes[32] | hid_spikes[35] | hid_spikes[36] | hid_spikes[43] | hid_spikes[56] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60] | hid_spikes[63] | hid_spikes[65] | hid_spikes[66] | hid_spikes[69] | hid_spikes[75] | hid_spikes[78]) << 1
        + (hid_spikes[6] | hid_spikes[10] | hid_spikes[14] | hid_spikes[18] | hid_spikes[19] | hid_spikes[27] | hid_spikes[29] | hid_spikes[30] | hid_spikes[32] | hid_spikes[34] | hid_spikes[35] | hid_spikes[38] | hid_spikes[41] | hid_spikes[42] | hid_spikes[46] | hid_spikes[53] | hid_spikes[56] | hid_spikes[57] | hid_spikes[59] | hid_spikes[64] | hid_spikes[67] | hid_spikes[69] | hid_spikes[71] | hid_spikes[72] | hid_spikes[75] | hid_spikes[79]) << 2
        + (hid_spikes[0] | hid_spikes[4] | hid_spikes[6] | hid_spikes[22] | hid_spikes[29] | hid_spikes[38] | hid_spikes[40] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[49] | hid_spikes[54] | hid_spikes[65] | hid_spikes[73] | hid_spikes[76] | hid_spikes[77] | hid_spikes[78]) << 3
        + (hid_spikes[12] | hid_spikes[15] | hid_spikes[64]) << 4;
    wire signed [11:0] sum_hid_71 = pos_in_hid_71 - neg_in_hid_71;
    assign hid_spikes[71] = (mem_hid_71 >= 10);
    wire signed [11:0] next_hid_71 = mem_hid_71 - (mem_hid_71 >>> 6) + sum_hid_71;

    reg signed [11:0] mem_hid_72;
    wire signed [11:0] pos_in_hid_72 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[2]) << 3
        + (cochlea_spikes[2]) << 4
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[4]) << 4
        + (hid_spikes[1] | hid_spikes[7] | hid_spikes[12] | hid_spikes[14] | hid_spikes[31] | hid_spikes[36] | hid_spikes[41] | hid_spikes[42] | hid_spikes[59] | hid_spikes[62] | hid_spikes[66] | hid_spikes[70] | hid_spikes[79]) << 0
        + (hid_spikes[1] | hid_spikes[14] | hid_spikes[17] | hid_spikes[29] | hid_spikes[32] | hid_spikes[33] | hid_spikes[35] | hid_spikes[36] | hid_spikes[41] | hid_spikes[42] | hid_spikes[59] | hid_spikes[62] | hid_spikes[72] | hid_spikes[76]) << 1
        + (hid_spikes[1] | hid_spikes[6] | hid_spikes[10] | hid_spikes[12] | hid_spikes[14] | hid_spikes[17] | hid_spikes[20] | hid_spikes[26] | hid_spikes[29] | hid_spikes[32] | hid_spikes[33] | hid_spikes[34] | hid_spikes[42] | hid_spikes[62] | hid_spikes[63] | hid_spikes[70] | hid_spikes[76] | hid_spikes[79]) << 2
        + (hid_spikes[1] | hid_spikes[7] | hid_spikes[20] | hid_spikes[31] | hid_spikes[42] | hid_spikes[52] | hid_spikes[62] | hid_spikes[66]) << 3
        + (hid_spikes[0] | hid_spikes[16]) << 4;
    wire signed [11:0] neg_in_hid_72 = (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[0]) << 4
        + (cochlea_spikes[0]) << 5
        + (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[3]) << 4
        + (hid_spikes[4] | hid_spikes[13] | hid_spikes[21] | hid_spikes[25] | hid_spikes[28] | hid_spikes[40] | hid_spikes[43] | hid_spikes[44] | hid_spikes[47] | hid_spikes[49] | hid_spikes[53] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[58] | hid_spikes[64] | hid_spikes[68] | hid_spikes[75]) << 0
        + (hid_spikes[2] | hid_spikes[4] | hid_spikes[13] | hid_spikes[21] | hid_spikes[28] | hid_spikes[40] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[54] | hid_spikes[57] | hid_spikes[58] | hid_spikes[64] | hid_spikes[65] | hid_spikes[67] | hid_spikes[73] | hid_spikes[74] | hid_spikes[75] | hid_spikes[78]) << 1
        + (hid_spikes[13] | hid_spikes[18] | hid_spikes[25] | hid_spikes[28] | hid_spikes[30] | hid_spikes[38] | hid_spikes[40] | hid_spikes[53] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60] | hid_spikes[65] | hid_spikes[71] | hid_spikes[74] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 2
        + (hid_spikes[13] | hid_spikes[30] | hid_spikes[37] | hid_spikes[38] | hid_spikes[45] | hid_spikes[47] | hid_spikes[49] | hid_spikes[67] | hid_spikes[68] | hid_spikes[71]) << 3;
    wire signed [11:0] sum_hid_72 = pos_in_hid_72 - neg_in_hid_72;
    assign hid_spikes[72] = (mem_hid_72 >= 10);
    wire signed [11:0] next_hid_72 = mem_hid_72 - (mem_hid_72 >>> 6) + sum_hid_72;

    reg signed [11:0] mem_hid_73;
    wire signed [11:0] pos_in_hid_73 = (cochlea_spikes[4]) << 0
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[4]) << 3
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 3
        + (hid_spikes[0] | hid_spikes[5] | hid_spikes[17] | hid_spikes[28] | hid_spikes[33] | hid_spikes[51] | hid_spikes[68]) << 0
        + (hid_spikes[9] | hid_spikes[17] | hid_spikes[23] | hid_spikes[28] | hid_spikes[33] | hid_spikes[49] | hid_spikes[51] | hid_spikes[63] | hid_spikes[64] | hid_spikes[65] | hid_spikes[68] | hid_spikes[72] | hid_spikes[73]) << 1
        + (hid_spikes[0] | hid_spikes[8] | hid_spikes[16] | hid_spikes[21] | hid_spikes[26] | hid_spikes[33] | hid_spikes[52] | hid_spikes[65] | hid_spikes[73] | hid_spikes[79]) << 2
        + (hid_spikes[2] | hid_spikes[5] | hid_spikes[9] | hid_spikes[17] | hid_spikes[55] | hid_spikes[64]) << 3
        + (hid_spikes[28]) << 4;
    wire signed [11:0] neg_in_hid_73 = (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 3
        + (hid_spikes[1] | hid_spikes[3] | hid_spikes[15] | hid_spikes[20] | hid_spikes[25] | hid_spikes[27] | hid_spikes[37] | hid_spikes[41] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[54] | hid_spikes[58] | hid_spikes[59] | hid_spikes[60] | hid_spikes[67] | hid_spikes[69] | hid_spikes[71] | hid_spikes[76]) << 0
        + (hid_spikes[3] | hid_spikes[4] | hid_spikes[7] | hid_spikes[10] | hid_spikes[11] | hid_spikes[13] | hid_spikes[15] | hid_spikes[24] | hid_spikes[25] | hid_spikes[30] | hid_spikes[36] | hid_spikes[40] | hid_spikes[41] | hid_spikes[43] | hid_spikes[47] | hid_spikes[59] | hid_spikes[60] | hid_spikes[69] | hid_spikes[76] | hid_spikes[77] | hid_spikes[78]) << 1
        + (hid_spikes[1] | hid_spikes[4] | hid_spikes[6] | hid_spikes[7] | hid_spikes[10] | hid_spikes[11] | hid_spikes[13] | hid_spikes[15] | hid_spikes[20] | hid_spikes[34] | hid_spikes[36] | hid_spikes[37] | hid_spikes[41] | hid_spikes[42] | hid_spikes[45] | hid_spikes[46] | hid_spikes[54] | hid_spikes[58] | hid_spikes[59] | hid_spikes[71] | hid_spikes[77] | hid_spikes[78]) << 2
        + (hid_spikes[11] | hid_spikes[20] | hid_spikes[22] | hid_spikes[27] | hid_spikes[39] | hid_spikes[40] | hid_spikes[48] | hid_spikes[54] | hid_spikes[67] | hid_spikes[69] | hid_spikes[71] | hid_spikes[75] | hid_spikes[78]) << 3
        + (hid_spikes[11] | hid_spikes[61]) << 4;
    wire signed [11:0] sum_hid_73 = pos_in_hid_73 - neg_in_hid_73;
    assign hid_spikes[73] = (mem_hid_73 >= 10);
    wire signed [11:0] next_hid_73 = mem_hid_73 - (mem_hid_73 >>> 5) + sum_hid_73;

    reg signed [11:0] mem_hid_74;
    wire signed [11:0] pos_in_hid_74 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 3
        + (hid_spikes[3] | hid_spikes[6] | hid_spikes[13] | hid_spikes[16] | hid_spikes[38] | hid_spikes[46] | hid_spikes[47] | hid_spikes[50] | hid_spikes[52] | hid_spikes[62] | hid_spikes[63] | hid_spikes[71] | hid_spikes[74] | hid_spikes[76] | hid_spikes[79]) << 0
        + (hid_spikes[6] | hid_spikes[13] | hid_spikes[14] | hid_spikes[16] | hid_spikes[25] | hid_spikes[46] | hid_spikes[50] | hid_spikes[51] | hid_spikes[52] | hid_spikes[59] | hid_spikes[63] | hid_spikes[79]) << 1
        + (hid_spikes[3] | hid_spikes[8] | hid_spikes[9] | hid_spikes[14] | hid_spikes[35] | hid_spikes[38] | hid_spikes[45] | hid_spikes[47] | hid_spikes[52] | hid_spikes[56] | hid_spikes[62] | hid_spikes[74] | hid_spikes[76]) << 2
        + (hid_spikes[8] | hid_spikes[13] | hid_spikes[45] | hid_spikes[46] | hid_spikes[52] | hid_spikes[60] | hid_spikes[62] | hid_spikes[63] | hid_spikes[71] | hid_spikes[76]) << 3;
    wire signed [11:0] neg_in_hid_74 = (cochlea_spikes[3]) << 0
        + (cochlea_spikes[3]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[3]) << 4
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[5]) << 3
        + (hid_spikes[4] | hid_spikes[11] | hid_spikes[20] | hid_spikes[23] | hid_spikes[24] | hid_spikes[26] | hid_spikes[27] | hid_spikes[32] | hid_spikes[36] | hid_spikes[53] | hid_spikes[57] | hid_spikes[78]) << 0
        + (hid_spikes[17] | hid_spikes[20] | hid_spikes[24] | hid_spikes[26] | hid_spikes[27] | hid_spikes[30] | hid_spikes[36] | hid_spikes[40] | hid_spikes[43] | hid_spikes[49] | hid_spikes[53] | hid_spikes[54] | hid_spikes[57] | hid_spikes[61] | hid_spikes[66] | hid_spikes[73] | hid_spikes[75]) << 1
        + (hid_spikes[4] | hid_spikes[11] | hid_spikes[17] | hid_spikes[23] | hid_spikes[30] | hid_spikes[32] | hid_spikes[36] | hid_spikes[39] | hid_spikes[40] | hid_spikes[49] | hid_spikes[53] | hid_spikes[57] | hid_spikes[78]) << 2
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[23] | hid_spikes[29] | hid_spikes[37] | hid_spikes[39] | hid_spikes[43] | hid_spikes[54] | hid_spikes[61] | hid_spikes[65] | hid_spikes[69] | hid_spikes[73] | hid_spikes[75]) << 3
        + (hid_spikes[0]) << 4;
    wire signed [11:0] sum_hid_74 = pos_in_hid_74 - neg_in_hid_74;
    assign hid_spikes[74] = (mem_hid_74 >= 10);
    wire signed [11:0] next_hid_74 = mem_hid_74 - (mem_hid_74 >>> 4) + sum_hid_74;

    reg signed [11:0] mem_hid_75;
    wire signed [11:0] pos_in_hid_75 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[1]) << 4
        + (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[0]) << 3
        + (hid_spikes[3] | hid_spikes[15] | hid_spikes[22] | hid_spikes[25] | hid_spikes[31] | hid_spikes[35] | hid_spikes[41] | hid_spikes[76] | hid_spikes[79]) << 0
        + (hid_spikes[3] | hid_spikes[10] | hid_spikes[15] | hid_spikes[16] | hid_spikes[21] | hid_spikes[22] | hid_spikes[33] | hid_spikes[35] | hid_spikes[39] | hid_spikes[41] | hid_spikes[60] | hid_spikes[72] | hid_spikes[74] | hid_spikes[75] | hid_spikes[76]) << 1
        + (hid_spikes[9] | hid_spikes[10] | hid_spikes[31] | hid_spikes[32] | hid_spikes[47] | hid_spikes[49] | hid_spikes[52] | hid_spikes[56] | hid_spikes[70] | hid_spikes[74] | hid_spikes[76] | hid_spikes[79]) << 2
        + (hid_spikes[14] | hid_spikes[25] | hid_spikes[39] | hid_spikes[41] | hid_spikes[46] | hid_spikes[61] | hid_spikes[76] | hid_spikes[79]) << 3
        + (hid_spikes[16]) << 4;
    wire signed [11:0] neg_in_hid_75 = (cochlea_spikes[3] | cochlea_spikes[4]) << 0
        + (cochlea_spikes[3]) << 4
        + (cochlea_spikes[4]) << 5
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[5]) << 3
        + (cochlea_spikes[5]) << 4
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[13] | hid_spikes[17] | hid_spikes[19] | hid_spikes[23] | hid_spikes[27] | hid_spikes[29] | hid_spikes[30] | hid_spikes[38] | hid_spikes[42] | hid_spikes[43] | hid_spikes[58] | hid_spikes[59] | hid_spikes[62] | hid_spikes[66] | hid_spikes[68] | hid_spikes[69] | hid_spikes[77] | hid_spikes[78]) << 0
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[5] | hid_spikes[13] | hid_spikes[17] | hid_spikes[18] | hid_spikes[23] | hid_spikes[24] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[36] | hid_spikes[38] | hid_spikes[43] | hid_spikes[50] | hid_spikes[58] | hid_spikes[66] | hid_spikes[67] | hid_spikes[68] | hid_spikes[69] | hid_spikes[73] | hid_spikes[77] | hid_spikes[78]) << 1
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[11] | hid_spikes[13] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[30] | hid_spikes[36] | hid_spikes[37] | hid_spikes[38] | hid_spikes[42] | hid_spikes[43] | hid_spikes[48] | hid_spikes[50] | hid_spikes[58] | hid_spikes[64] | hid_spikes[65] | hid_spikes[69] | hid_spikes[73]) << 2
        + (hid_spikes[5] | hid_spikes[11] | hid_spikes[17] | hid_spikes[19] | hid_spikes[24] | hid_spikes[40] | hid_spikes[48] | hid_spikes[59] | hid_spikes[62] | hid_spikes[67] | hid_spikes[71]) << 3
        + (hid_spikes[64]) << 4;
    wire signed [11:0] sum_hid_75 = pos_in_hid_75 - neg_in_hid_75;
    assign hid_spikes[75] = (mem_hid_75 >= 10);
    wire signed [11:0] next_hid_75 = mem_hid_75 - (mem_hid_75 >>> 6) + sum_hid_75;

    reg signed [11:0] mem_hid_76;
    wire signed [11:0] pos_in_hid_76 = (hid_spikes[2] | hid_spikes[3] | hid_spikes[10] | hid_spikes[16] | hid_spikes[29] | hid_spikes[33] | hid_spikes[39] | hid_spikes[47] | hid_spikes[76]) << 0
        + (hid_spikes[2] | hid_spikes[3] | hid_spikes[10] | hid_spikes[21] | hid_spikes[31] | hid_spikes[33] | hid_spikes[37] | hid_spikes[39] | hid_spikes[44] | hid_spikes[48] | hid_spikes[52] | hid_spikes[53] | hid_spikes[63]) << 1
        + (hid_spikes[3] | hid_spikes[10] | hid_spikes[14] | hid_spikes[16] | hid_spikes[18] | hid_spikes[29] | hid_spikes[31] | hid_spikes[32] | hid_spikes[49] | hid_spikes[53] | hid_spikes[61] | hid_spikes[63] | hid_spikes[70] | hid_spikes[76]) << 2
        + (hid_spikes[18] | hid_spikes[21] | hid_spikes[31] | hid_spikes[39] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[52]) << 3
        + (hid_spikes[6]) << 4;
    wire signed [11:0] neg_in_hid_76 = (cochlea_spikes[5]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[5]) << 2
        + (cochlea_spikes[2]) << 6
        + (cochlea_spikes[4]) << 7
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[1]) << 6
        + (hid_spikes[5] | hid_spikes[8] | hid_spikes[9] | hid_spikes[15] | hid_spikes[19] | hid_spikes[30] | hid_spikes[34] | hid_spikes[36] | hid_spikes[38] | hid_spikes[59] | hid_spikes[67] | hid_spikes[68] | hid_spikes[73] | hid_spikes[75] | hid_spikes[79]) << 0
        + (hid_spikes[0] | hid_spikes[5] | hid_spikes[7] | hid_spikes[15] | hid_spikes[17] | hid_spikes[20] | hid_spikes[26] | hid_spikes[35] | hid_spikes[45] | hid_spikes[46] | hid_spikes[50] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[59] | hid_spikes[65] | hid_spikes[66] | hid_spikes[68] | hid_spikes[73] | hid_spikes[77]) << 1
        + (hid_spikes[0] | hid_spikes[4] | hid_spikes[7] | hid_spikes[8] | hid_spikes[11] | hid_spikes[22] | hid_spikes[26] | hid_spikes[34] | hid_spikes[35] | hid_spikes[38] | hid_spikes[43] | hid_spikes[45] | hid_spikes[55] | hid_spikes[56] | hid_spikes[57] | hid_spikes[59] | hid_spikes[60] | hid_spikes[67] | hid_spikes[72] | hid_spikes[73] | hid_spikes[75] | hid_spikes[77] | hid_spikes[79]) << 2
        + (hid_spikes[0] | hid_spikes[9] | hid_spikes[11] | hid_spikes[24] | hid_spikes[27] | hid_spikes[30] | hid_spikes[34] | hid_spikes[36] | hid_spikes[38] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[54] | hid_spikes[65] | hid_spikes[66] | hid_spikes[68] | hid_spikes[77]) << 3
        + (hid_spikes[19] | hid_spikes[30] | hid_spikes[46] | hid_spikes[67]) << 4;
    wire signed [11:0] sum_hid_76 = pos_in_hid_76 - neg_in_hid_76;
    assign hid_spikes[76] = (mem_hid_76 >= 10);
    wire signed [11:0] next_hid_76 = mem_hid_76 - (mem_hid_76 >>> 6) + sum_hid_76;

    reg signed [11:0] mem_hid_77;
    wire signed [11:0] pos_in_hid_77 = (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 2
        + (cochlea_spikes[3]) << 2
        + (hid_spikes[12] | hid_spikes[41] | hid_spikes[47] | hid_spikes[63] | hid_spikes[74]) << 0
        + (hid_spikes[41] | hid_spikes[53] | hid_spikes[76]) << 1
        + (hid_spikes[12] | hid_spikes[15] | hid_spikes[34] | hid_spikes[35] | hid_spikes[41] | hid_spikes[47] | hid_spikes[63] | hid_spikes[74] | hid_spikes[76]) << 2
        + (hid_spikes[53]) << 3;
    wire signed [11:0] neg_in_hid_77 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 4
        + (cochlea_spikes[2]) << 5
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 3
        + (cochlea_spikes[1]) << 4
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[7] | hid_spikes[9] | hid_spikes[11] | hid_spikes[14] | hid_spikes[17] | hid_spikes[23] | hid_spikes[25] | hid_spikes[26] | hid_spikes[27] | hid_spikes[31] | hid_spikes[36] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[46] | hid_spikes[51] | hid_spikes[52] | hid_spikes[54] | hid_spikes[55] | hid_spikes[60] | hid_spikes[61] | hid_spikes[62] | hid_spikes[64] | hid_spikes[65] | hid_spikes[66] | hid_spikes[67] | hid_spikes[69] | hid_spikes[70] | hid_spikes[71] | hid_spikes[72] | hid_spikes[73] | hid_spikes[75]) << 0
        + (hid_spikes[6] | hid_spikes[7] | hid_spikes[14] | hid_spikes[16] | hid_spikes[17] | hid_spikes[20] | hid_spikes[24] | hid_spikes[26] | hid_spikes[28] | hid_spikes[32] | hid_spikes[36] | hid_spikes[43] | hid_spikes[50] | hid_spikes[52] | hid_spikes[54] | hid_spikes[58] | hid_spikes[60] | hid_spikes[62] | hid_spikes[64] | hid_spikes[66] | hid_spikes[67] | hid_spikes[68] | hid_spikes[71] | hid_spikes[72] | hid_spikes[73] | hid_spikes[75] | hid_spikes[78] | hid_spikes[79]) << 1
        + (hid_spikes[0] | hid_spikes[7] | hid_spikes[10] | hid_spikes[11] | hid_spikes[16] | hid_spikes[18] | hid_spikes[19] | hid_spikes[20] | hid_spikes[21] | hid_spikes[22] | hid_spikes[25] | hid_spikes[29] | hid_spikes[31] | hid_spikes[32] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[46] | hid_spikes[50] | hid_spikes[51] | hid_spikes[55] | hid_spikes[58] | hid_spikes[61] | hid_spikes[62] | hid_spikes[67] | hid_spikes[70] | hid_spikes[73] | hid_spikes[79]) << 2
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[9] | hid_spikes[14] | hid_spikes[23] | hid_spikes[24] | hid_spikes[27] | hid_spikes[36] | hid_spikes[46] | hid_spikes[50] | hid_spikes[54] | hid_spikes[60] | hid_spikes[61] | hid_spikes[65] | hid_spikes[66] | hid_spikes[68] | hid_spikes[69] | hid_spikes[72] | hid_spikes[75]) << 3
        + (hid_spikes[30] | hid_spikes[64]) << 4;
    wire signed [11:0] sum_hid_77 = pos_in_hid_77 - neg_in_hid_77;
    assign hid_spikes[77] = (mem_hid_77 >= 10);
    wire signed [11:0] next_hid_77 = mem_hid_77 - (mem_hid_77 >>> 5) + sum_hid_77;

    reg signed [11:0] mem_hid_78;
    wire signed [11:0] pos_in_hid_78 = (cochlea_spikes[1]) << 0
        + (cochlea_spikes[1]) << 1
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 1
        + (cochlea_spikes[0]) << 2
        + (hid_spikes[8] | hid_spikes[11] | hid_spikes[30] | hid_spikes[32]) << 0
        + (hid_spikes[11] | hid_spikes[29] | hid_spikes[32] | hid_spikes[38] | hid_spikes[49]) << 1
        + (hid_spikes[11] | hid_spikes[22] | hid_spikes[29] | hid_spikes[49] | hid_spikes[61] | hid_spikes[70] | hid_spikes[77]) << 2
        + (hid_spikes[8] | hid_spikes[30]) << 3;
    wire signed [11:0] neg_in_hid_78 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[2]) << 1
        + (cochlea_spikes[2]) << 2
        + (cochlea_spikes[2]) << 5
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[4] | cochlea_spikes[5]) << 1
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[4]) << 3
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[13] | hid_spikes[21] | hid_spikes[24] | hid_spikes[26] | hid_spikes[27] | hid_spikes[33] | hid_spikes[34] | hid_spikes[35] | hid_spikes[37] | hid_spikes[42] | hid_spikes[43] | hid_spikes[46] | hid_spikes[50] | hid_spikes[52] | hid_spikes[55] | hid_spikes[62] | hid_spikes[67] | hid_spikes[72] | hid_spikes[73] | hid_spikes[75] | hid_spikes[76]) << 0
        + (hid_spikes[10] | hid_spikes[17] | hid_spikes[18] | hid_spikes[21] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[27] | hid_spikes[33] | hid_spikes[40] | hid_spikes[43] | hid_spikes[46] | hid_spikes[55] | hid_spikes[56] | hid_spikes[60] | hid_spikes[62] | hid_spikes[64] | hid_spikes[66] | hid_spikes[68] | hid_spikes[72] | hid_spikes[76]) << 1
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[7] | hid_spikes[9] | hid_spikes[10] | hid_spikes[18] | hid_spikes[23] | hid_spikes[25] | hid_spikes[31] | hid_spikes[37] | hid_spikes[40] | hid_spikes[41] | hid_spikes[42] | hid_spikes[46] | hid_spikes[50] | hid_spikes[57] | hid_spikes[59] | hid_spikes[60] | hid_spikes[65] | hid_spikes[66] | hid_spikes[67] | hid_spikes[69] | hid_spikes[73] | hid_spikes[75]) << 2
        + (hid_spikes[3] | hid_spikes[6] | hid_spikes[13] | hid_spikes[16] | hid_spikes[21] | hid_spikes[24] | hid_spikes[26] | hid_spikes[34] | hid_spikes[35] | hid_spikes[41] | hid_spikes[42] | hid_spikes[48] | hid_spikes[52] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[64] | hid_spikes[66] | hid_spikes[72] | hid_spikes[74] | hid_spikes[75]) << 3
        + (hid_spikes[19] | hid_spikes[39] | hid_spikes[64] | hid_spikes[65]) << 4;
    wire signed [11:0] sum_hid_78 = pos_in_hid_78 - neg_in_hid_78;
    assign hid_spikes[78] = (mem_hid_78 >= 10);
    wire signed [11:0] next_hid_78 = mem_hid_78 - (mem_hid_78 >>> 6) + sum_hid_78;

    reg signed [11:0] mem_hid_79;
    wire signed [11:0] pos_in_hid_79 = (cochlea_spikes[2]) << 0
        + (cochlea_spikes[1] | cochlea_spikes[2]) << 1
        + (cochlea_spikes[1]) << 2
        + (cochlea_spikes[1]) << 3
        + (cochlea_spikes[5]) << 0
        + (cochlea_spikes[5]) << 1
        + (cochlea_spikes[5]) << 3
        + (hid_spikes[1] | hid_spikes[2] | hid_spikes[4] | hid_spikes[18] | hid_spikes[23] | hid_spikes[50] | hid_spikes[60] | hid_spikes[62] | hid_spikes[72]) << 0
        + (hid_spikes[2] | hid_spikes[4] | hid_spikes[23] | hid_spikes[52] | hid_spikes[58] | hid_spikes[59] | hid_spikes[60] | hid_spikes[72] | hid_spikes[76]) << 1
        + (hid_spikes[1] | hid_spikes[10] | hid_spikes[16] | hid_spikes[18] | hid_spikes[33] | hid_spikes[50] | hid_spikes[52] | hid_spikes[63] | hid_spikes[72] | hid_spikes[74]) << 2
        + (hid_spikes[62] | hid_spikes[72]) << 3;
    wire signed [11:0] neg_in_hid_79 = (cochlea_spikes[4]) << 0
        + (cochlea_spikes[3] | cochlea_spikes[4]) << 1
        + (cochlea_spikes[4]) << 2
        + (cochlea_spikes[3]) << 5
        + (cochlea_spikes[0]) << 0
        + (cochlea_spikes[0]) << 3
        + (cochlea_spikes[0]) << 4
        + (hid_spikes[3] | hid_spikes[6] | hid_spikes[7] | hid_spikes[8] | hid_spikes[9] | hid_spikes[11] | hid_spikes[13] | hid_spikes[17] | hid_spikes[20] | hid_spikes[21] | hid_spikes[24] | hid_spikes[26] | hid_spikes[29] | hid_spikes[31] | hid_spikes[37] | hid_spikes[39] | hid_spikes[40] | hid_spikes[41] | hid_spikes[43] | hid_spikes[44] | hid_spikes[57] | hid_spikes[64] | hid_spikes[67] | hid_spikes[70] | hid_spikes[71] | hid_spikes[73]) << 0
        + (hid_spikes[5] | hid_spikes[6] | hid_spikes[7] | hid_spikes[9] | hid_spikes[14] | hid_spikes[17] | hid_spikes[20] | hid_spikes[24] | hid_spikes[26] | hid_spikes[28] | hid_spikes[29] | hid_spikes[37] | hid_spikes[38] | hid_spikes[39] | hid_spikes[40] | hid_spikes[43] | hid_spikes[44] | hid_spikes[54] | hid_spikes[56] | hid_spikes[67] | hid_spikes[71] | hid_spikes[73]) << 1
        + (hid_spikes[3] | hid_spikes[7] | hid_spikes[8] | hid_spikes[14] | hid_spikes[21] | hid_spikes[31] | hid_spikes[38] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[47] | hid_spikes[56] | hid_spikes[64] | hid_spikes[67] | hid_spikes[70] | hid_spikes[71] | hid_spikes[73]) << 2
        + (hid_spikes[3] | hid_spikes[5] | hid_spikes[9] | hid_spikes[11] | hid_spikes[13] | hid_spikes[28] | hid_spikes[30] | hid_spikes[37] | hid_spikes[41] | hid_spikes[43] | hid_spikes[47] | hid_spikes[53] | hid_spikes[57] | hid_spikes[64] | hid_spikes[67] | hid_spikes[69]) << 3
        + (hid_spikes[17] | hid_spikes[38] | hid_spikes[54] | hid_spikes[64] | hid_spikes[65] | hid_spikes[73]) << 4;
    wire signed [11:0] sum_hid_79 = pos_in_hid_79 - neg_in_hid_79;
    assign hid_spikes[79] = (mem_hid_79 >= 10);
    wire signed [11:0] next_hid_79 = mem_hid_79 - (mem_hid_79 >>> 3) + sum_hid_79;

    // ==========================================
    // BASE OUTPUT LAYER (OR-Gate Bitwise Synthesis)
    // ==========================================
    reg signed [11:0] mem_base_0;
    wire signed [11:0] pos_in_base_0 = (hid_spikes[13] | hid_spikes[40] | hid_spikes[43] | hid_spikes[49] | hid_spikes[50]) << 0
        + (hid_spikes[40] | hid_spikes[49] | hid_spikes[50] | hid_spikes[58]) << 1
        + (hid_spikes[13] | hid_spikes[27] | hid_spikes[43] | hid_spikes[44] | hid_spikes[49] | hid_spikes[50] | hid_spikes[58] | hid_spikes[77]) << 2
        + (hid_spikes[13] | hid_spikes[43] | hid_spikes[58]) << 3
        + (hid_spikes[13] | hid_spikes[27] | hid_spikes[40] | hid_spikes[44] | hid_spikes[50]) << 4
        + (hid_spikes[27] | hid_spikes[40] | hid_spikes[49] | hid_spikes[77]) << 5
        + (hid_spikes[43]) << 6
        + (hid_spikes[23] | hid_spikes[52] | hid_spikes[56] | hid_spikes[59]) << 0
        + (hid_spikes[6] | hid_spikes[26] | hid_spikes[51] | hid_spikes[52] | hid_spikes[59]) << 1
        + (hid_spikes[1] | hid_spikes[6] | hid_spikes[23] | hid_spikes[52] | hid_spikes[56]) << 2
        + (hid_spikes[1] | hid_spikes[17] | hid_spikes[23]) << 3
        + (hid_spikes[1] | hid_spikes[6] | hid_spikes[26] | hid_spikes[56] | hid_spikes[59]) << 4
        + (hid_spikes[26] | hid_spikes[51] | hid_spikes[52] | hid_spikes[56]) << 5
        + (hid_spikes[17]) << 6
        + (hid_spikes[8] | hid_spikes[20] | hid_spikes[22] | hid_spikes[39] | hid_spikes[48]) << 0
        + (hid_spikes[20] | hid_spikes[45] | hid_spikes[48]) << 1
        + (hid_spikes[20] | hid_spikes[22] | hid_spikes[45]) << 2
        + (hid_spikes[39] | hid_spikes[48]) << 3
        + (hid_spikes[3] | hid_spikes[20] | hid_spikes[34] | hid_spikes[45] | hid_spikes[48]) << 4
        + (hid_spikes[3] | hid_spikes[8] | hid_spikes[20] | hid_spikes[22] | hid_spikes[39]) << 5
        + (hid_spikes[21] | hid_spikes[42] | hid_spikes[46]) << 0
        + (hid_spikes[9] | hid_spikes[21] | hid_spikes[35] | hid_spikes[46]) << 1
        + (hid_spikes[21] | hid_spikes[29] | hid_spikes[42] | hid_spikes[46]) << 2
        + (hid_spikes[9] | hid_spikes[35]) << 3
        + (hid_spikes[9] | hid_spikes[21] | hid_spikes[29] | hid_spikes[71]) << 4
        + (hid_spikes[5] | hid_spikes[21] | hid_spikes[35] | hid_spikes[42] | hid_spikes[46]) << 5;
    wire signed [11:0] neg_in_base_0 = (hid_spikes[54] | hid_spikes[63] | hid_spikes[67] | hid_spikes[68]) << 0
        + (hid_spikes[63] | hid_spikes[67]) << 1
        + (hid_spikes[66] | hid_spikes[67] | hid_spikes[79]) << 2
        + (hid_spikes[79]) << 3
        + (hid_spikes[66] | hid_spikes[67] | hid_spikes[68]) << 4
        + (hid_spikes[54] | hid_spikes[79]) << 5
        + (hid_spikes[63]) << 6
        + (hid_spikes[11]) << 7
        + (hid_spikes[10] | hid_spikes[18] | hid_spikes[24] | hid_spikes[60] | hid_spikes[62] | hid_spikes[70]) << 0
        + (hid_spikes[24] | hid_spikes[60]) << 1
        + (hid_spikes[10] | hid_spikes[18] | hid_spikes[24] | hid_spikes[70]) << 2
        + (hid_spikes[18] | hid_spikes[24] | hid_spikes[62]) << 3
        + (hid_spikes[10] | hid_spikes[24] | hid_spikes[60] | hid_spikes[62]) << 4
        + (hid_spikes[62] | hid_spikes[70]) << 5
        + (hid_spikes[30]) << 7
        + (hid_spikes[25] | hid_spikes[36] | hid_spikes[64] | hid_spikes[65]) << 0
        + (hid_spikes[36] | hid_spikes[64] | hid_spikes[65]) << 1
        + (hid_spikes[4] | hid_spikes[25]) << 2
        + (hid_spikes[4] | hid_spikes[65]) << 3
        + (hid_spikes[25] | hid_spikes[64] | hid_spikes[65]) << 4
        + (hid_spikes[4] | hid_spikes[36]) << 5
        + (hid_spikes[73]) << 7
        + (hid_spikes[69] | hid_spikes[74]) << 0
        + (hid_spikes[15] | hid_spikes[69] | hid_spikes[74]) << 1
        + (hid_spikes[37] | hid_spikes[69] | hid_spikes[74]) << 2
        + (hid_spikes[38] | hid_spikes[47]) << 3
        + (hid_spikes[15] | hid_spikes[37] | hid_spikes[47] | hid_spikes[74]) << 4
        + (hid_spikes[38] | hid_spikes[69]) << 5
        + (hid_spikes[47]) << 6;
    wire signed [11:0] sum_base_0 = pos_in_base_0 - neg_in_base_0;
    assign base_spikes[0] = (mem_base_0 >= 85);
    wire signed [11:0] next_base_0 = mem_base_0 - (mem_base_0 >>> 6) + sum_base_0;

    reg signed [11:0] mem_base_1;
    wire signed [11:0] pos_in_base_1 = (hid_spikes[5] | hid_spikes[17] | hid_spikes[21] | hid_spikes[48] | hid_spikes[59]) << 0
        + (hid_spikes[45] | hid_spikes[48]) << 1
        + (hid_spikes[5] | hid_spikes[17] | hid_spikes[21] | hid_spikes[45]) << 2
        + (hid_spikes[21] | hid_spikes[48] | hid_spikes[52] | hid_spikes[59]) << 3
        + (hid_spikes[3] | hid_spikes[45] | hid_spikes[48] | hid_spikes[52] | hid_spikes[59]) << 4
        + (hid_spikes[5] | hid_spikes[21] | hid_spikes[45] | hid_spikes[48] | hid_spikes[59]) << 5
        + (hid_spikes[17] | hid_spikes[48]) << 6
        + (hid_spikes[8] | hid_spikes[30] | hid_spikes[40] | hid_spikes[53] | hid_spikes[60]) << 0
        + (hid_spikes[30] | hid_spikes[35] | hid_spikes[40] | hid_spikes[78]) << 1
        + (hid_spikes[8] | hid_spikes[27] | hid_spikes[60] | hid_spikes[78]) << 2
        + (hid_spikes[27] | hid_spikes[30] | hid_spikes[60] | hid_spikes[78]) << 3
        + (hid_spikes[8] | hid_spikes[27] | hid_spikes[40] | hid_spikes[53] | hid_spikes[60]) << 4
        + (hid_spikes[30] | hid_spikes[35] | hid_spikes[53] | hid_spikes[60]) << 5
        + (hid_spikes[27] | hid_spikes[40]) << 6
        + (hid_spikes[13] | hid_spikes[65] | hid_spikes[74]) << 0
        + (hid_spikes[39] | hid_spikes[61] | hid_spikes[74]) << 1
        + (hid_spikes[57] | hid_spikes[63] | hid_spikes[65]) << 2
        + (hid_spikes[36] | hid_spikes[57] | hid_spikes[61] | hid_spikes[65] | hid_spikes[74]) << 3
        + (hid_spikes[13] | hid_spikes[36] | hid_spikes[57]) << 4
        + (hid_spikes[39] | hid_spikes[57] | hid_spikes[61]) << 5
        + (hid_spikes[36] | hid_spikes[63] | hid_spikes[74]) << 6
        + (hid_spikes[20] | hid_spikes[49] | hid_spikes[67] | hid_spikes[71]) << 0
        + (hid_spikes[49]) << 1
        + (hid_spikes[15] | hid_spikes[20]) << 2
        + (hid_spikes[12] | hid_spikes[15] | hid_spikes[49] | hid_spikes[67] | hid_spikes[71]) << 3
        + (hid_spikes[1] | hid_spikes[15] | hid_spikes[20] | hid_spikes[49] | hid_spikes[67]) << 4
        + (hid_spikes[12] | hid_spikes[15] | hid_spikes[49]) << 5
        + (hid_spikes[20] | hid_spikes[71]) << 6;
    wire signed [11:0] neg_in_base_1 = (hid_spikes[0]) << 0
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[19] | hid_spikes[73]) << 1
        + (hid_spikes[19] | hid_spikes[29]) << 2
        + (hid_spikes[0] | hid_spikes[29] | hid_spikes[73]) << 3
        + (hid_spikes[2] | hid_spikes[29] | hid_spikes[33] | hid_spikes[50]) << 4
        + (hid_spikes[0] | hid_spikes[33] | hid_spikes[68] | hid_spikes[73]) << 5
        + (hid_spikes[0] | hid_spikes[2] | hid_spikes[19]) << 6
        + (hid_spikes[11]) << 7
        + (hid_spikes[56] | hid_spikes[66] | hid_spikes[75] | hid_spikes[76] | hid_spikes[79]) << 0
        + (hid_spikes[44] | hid_spikes[56] | hid_spikes[66] | hid_spikes[75]) << 1
        + (hid_spikes[24] | hid_spikes[44] | hid_spikes[56] | hid_spikes[75] | hid_spikes[79]) << 2
        + (hid_spikes[24] | hid_spikes[44] | hid_spikes[56] | hid_spikes[66] | hid_spikes[75] | hid_spikes[76] | hid_spikes[79]) << 3
        + (hid_spikes[44] | hid_spikes[56] | hid_spikes[66] | hid_spikes[72] | hid_spikes[75] | hid_spikes[79]) << 4
        + (hid_spikes[44] | hid_spikes[72] | hid_spikes[76] | hid_spikes[79]) << 5
        + (hid_spikes[75]) << 6
        + (hid_spikes[47]) << 7
        + (hid_spikes[14] | hid_spikes[22] | hid_spikes[26] | hid_spikes[43] | hid_spikes[54]) << 0
        + (hid_spikes[14] | hid_spikes[18] | hid_spikes[23] | hid_spikes[43] | hid_spikes[51]) << 1
        + (hid_spikes[18] | hid_spikes[22] | hid_spikes[26] | hid_spikes[43] | hid_spikes[51] | hid_spikes[54]) << 2
        + (hid_spikes[14] | hid_spikes[26] | hid_spikes[43] | hid_spikes[51] | hid_spikes[54]) << 3
        + (hid_spikes[18] | hid_spikes[22] | hid_spikes[26] | hid_spikes[43] | hid_spikes[51]) << 4
        + (hid_spikes[18] | hid_spikes[23] | hid_spikes[43] | hid_spikes[51] | hid_spikes[54]) << 5
        + (hid_spikes[14] | hid_spikes[43]) << 6
        + (hid_spikes[6] | hid_spikes[31] | hid_spikes[32] | hid_spikes[70]) << 0
        + (hid_spikes[4] | hid_spikes[6] | hid_spikes[42] | hid_spikes[46] | hid_spikes[62] | hid_spikes[70]) << 1
        + (hid_spikes[31] | hid_spikes[62]) << 2
        + (hid_spikes[4] | hid_spikes[6] | hid_spikes[31]) << 3
        + (hid_spikes[4] | hid_spikes[31] | hid_spikes[32] | hid_spikes[46] | hid_spikes[62] | hid_spikes[70]) << 4
        + (hid_spikes[6] | hid_spikes[42] | hid_spikes[62] | hid_spikes[70]) << 5
        + (hid_spikes[4] | hid_spikes[32] | hid_spikes[62]) << 6;
    wire signed [11:0] sum_base_1 = pos_in_base_1 - neg_in_base_1;
    assign base_spikes[1] = (mem_base_1 >= 85);
    wire signed [11:0] next_base_1 = mem_base_1 - (mem_base_1 >>> 6) + sum_base_1;

    reg signed [11:0] mem_base_2;
    wire signed [11:0] pos_in_base_2 = (hid_spikes[40] | hid_spikes[63] | hid_spikes[66] | hid_spikes[77]) << 0
        + (hid_spikes[1] | hid_spikes[40] | hid_spikes[61] | hid_spikes[63] | hid_spikes[69] | hid_spikes[73]) << 1
        + (hid_spikes[40] | hid_spikes[61] | hid_spikes[63] | hid_spikes[77]) << 2
        + (hid_spikes[40] | hid_spikes[61] | hid_spikes[69]) << 3
        + (hid_spikes[1] | hid_spikes[40] | hid_spikes[66] | hid_spikes[69] | hid_spikes[77]) << 4
        + (hid_spikes[63] | hid_spikes[66] | hid_spikes[73] | hid_spikes[77]) << 5
        + (hid_spikes[73]) << 6
        + (hid_spikes[13] | hid_spikes[19] | hid_spikes[51] | hid_spikes[52]) << 0
        + (hid_spikes[8] | hid_spikes[52]) << 1
        + (hid_spikes[8] | hid_spikes[46] | hid_spikes[49] | hid_spikes[51]) << 2
        + (hid_spikes[13] | hid_spikes[46] | hid_spikes[49] | hid_spikes[51] | hid_spikes[52]) << 3
        + (hid_spikes[13] | hid_spikes[19] | hid_spikes[27] | hid_spikes[46] | hid_spikes[52]) << 4
        + (hid_spikes[8] | hid_spikes[27] | hid_spikes[52]) << 5
        + (hid_spikes[49]) << 6
        + (hid_spikes[65] | hid_spikes[71]) << 0
        + (hid_spikes[5] | hid_spikes[35] | hid_spikes[39] | hid_spikes[58] | hid_spikes[71]) << 1
        + (hid_spikes[35] | hid_spikes[45] | hid_spikes[58] | hid_spikes[74]) << 2
        + (hid_spikes[45] | hid_spikes[58] | hid_spikes[71] | hid_spikes[74]) << 3
        + (hid_spikes[35] | hid_spikes[65] | hid_spikes[71] | hid_spikes[74]) << 4
        + (hid_spikes[5] | hid_spikes[58] | hid_spikes[71]) << 5
        + (hid_spikes[39]) << 6
        + (hid_spikes[10] | hid_spikes[31] | hid_spikes[44] | hid_spikes[53] | hid_spikes[64] | hid_spikes[67]) << 0
        + (hid_spikes[18] | hid_spikes[20] | hid_spikes[31] | hid_spikes[44] | hid_spikes[64]) << 1
        + (hid_spikes[18] | hid_spikes[44]) << 2
        + (hid_spikes[18] | hid_spikes[20] | hid_spikes[31] | hid_spikes[44]) << 3
        + (hid_spikes[20] | hid_spikes[53] | hid_spikes[64]) << 4
        + (hid_spikes[10] | hid_spikes[44] | hid_spikes[53]) << 5
        + (hid_spikes[67]) << 6;
    wire signed [11:0] neg_in_base_2 = (hid_spikes[3] | hid_spikes[14] | hid_spikes[15] | hid_spikes[37] | hid_spikes[43]) << 0
        + (hid_spikes[3] | hid_spikes[6] | hid_spikes[43]) << 1
        + (hid_spikes[3] | hid_spikes[11] | hid_spikes[14] | hid_spikes[37] | hid_spikes[54]) << 2
        + (hid_spikes[14] | hid_spikes[37] | hid_spikes[54]) << 3
        + (hid_spikes[3] | hid_spikes[6] | hid_spikes[11] | hid_spikes[43]) << 4
        + (hid_spikes[11] | hid_spikes[15] | hid_spikes[37] | hid_spikes[54]) << 5
        + (hid_spikes[43] | hid_spikes[54]) << 6
        + (hid_spikes[0]) << 7
        + (hid_spikes[24] | hid_spikes[28] | hid_spikes[72]) << 0
        + (hid_spikes[24] | hid_spikes[28] | hid_spikes[33] | hid_spikes[60]) << 1
        + (hid_spikes[24] | hid_spikes[28] | hid_spikes[42] | hid_spikes[56] | hid_spikes[60]) << 2
        + (hid_spikes[24] | hid_spikes[28] | hid_spikes[41] | hid_spikes[42] | hid_spikes[72]) << 3
        + (hid_spikes[24] | hid_spikes[33] | hid_spikes[60] | hid_spikes[72]) << 4
        + (hid_spikes[28] | hid_spikes[41] | hid_spikes[56] | hid_spikes[72]) << 5
        + (hid_spikes[56]) << 6
        + (hid_spikes[4]) << 7
        + (hid_spikes[26] | hid_spikes[34] | hid_spikes[76] | hid_spikes[79]) << 0
        + (hid_spikes[12] | hid_spikes[21] | hid_spikes[36] | hid_spikes[68] | hid_spikes[76]) << 1
        + (hid_spikes[12] | hid_spikes[21] | hid_spikes[26] | hid_spikes[34] | hid_spikes[68] | hid_spikes[79]) << 2
        + (hid_spikes[12] | hid_spikes[21] | hid_spikes[36] | hid_spikes[76]) << 3
        + (hid_spikes[12] | hid_spikes[26] | hid_spikes[36] | hid_spikes[68]) << 4
        + (hid_spikes[26] | hid_spikes[79]) << 5
        + (hid_spikes[34] | hid_spikes[36]) << 6
        + (hid_spikes[30]) << 7
        + (hid_spikes[7] | hid_spikes[17] | hid_spikes[22] | hid_spikes[25] | hid_spikes[62] | hid_spikes[78]) << 0
        + (hid_spikes[17] | hid_spikes[25] | hid_spikes[62]) << 1
        + (hid_spikes[7] | hid_spikes[22] | hid_spikes[47] | hid_spikes[62] | hid_spikes[78]) << 2
        + (hid_spikes[7] | hid_spikes[16] | hid_spikes[22]) << 3
        + (hid_spikes[16] | hid_spikes[17] | hid_spikes[62] | hid_spikes[78]) << 4
        + (hid_spikes[22] | hid_spikes[25] | hid_spikes[62] | hid_spikes[78]) << 5
        + (hid_spikes[47] | hid_spikes[78]) << 6;
    wire signed [11:0] sum_base_2 = pos_in_base_2 - neg_in_base_2;
    assign base_spikes[2] = (mem_base_2 >= 85);
    wire signed [11:0] next_base_2 = mem_base_2 - (mem_base_2 >>> 6) + sum_base_2;

    reg signed [11:0] mem_base_3;
    wire signed [11:0] pos_in_base_3 = (hid_spikes[5] | hid_spikes[10] | hid_spikes[71] | hid_spikes[73]) << 0
        + (hid_spikes[10] | hid_spikes[14] | hid_spikes[73]) << 1
        + (hid_spikes[5] | hid_spikes[10] | hid_spikes[73]) << 2
        + (hid_spikes[5] | hid_spikes[10] | hid_spikes[44] | hid_spikes[66] | hid_spikes[71] | hid_spikes[73]) << 3
        + (hid_spikes[10] | hid_spikes[44] | hid_spikes[73]) << 4
        + (hid_spikes[14] | hid_spikes[71] | hid_spikes[73]) << 5
        + (hid_spikes[26] | hid_spikes[66] | hid_spikes[73]) << 6
        + (hid_spikes[7] | hid_spikes[30] | hid_spikes[49] | hid_spikes[51]) << 0
        + (hid_spikes[0] | hid_spikes[22] | hid_spikes[60]) << 1
        + (hid_spikes[7] | hid_spikes[30] | hid_spikes[38] | hid_spikes[49] | hid_spikes[51] | hid_spikes[60]) << 2
        + (hid_spikes[38] | hid_spikes[49] | hid_spikes[51] | hid_spikes[60]) << 3
        + (hid_spikes[0] | hid_spikes[30] | hid_spikes[38] | hid_spikes[60]) << 4
        + (hid_spikes[0] | hid_spikes[7] | hid_spikes[22]) << 5
        + (hid_spikes[38] | hid_spikes[49]) << 6
        + (hid_spikes[39] | hid_spikes[42] | hid_spikes[61] | hid_spikes[63]) << 0
        + (hid_spikes[2] | hid_spikes[39] | hid_spikes[42] | hid_spikes[48]) << 1
        + (hid_spikes[19] | hid_spikes[42] | hid_spikes[61] | hid_spikes[63]) << 2
        + (hid_spikes[2] | hid_spikes[19] | hid_spikes[39]) << 3
        + (hid_spikes[2] | hid_spikes[27] | hid_spikes[39] | hid_spikes[61]) << 4
        + (hid_spikes[27] | hid_spikes[48] | hid_spikes[63]) << 5
        + (hid_spikes[39] | hid_spikes[42]) << 6
        + (hid_spikes[24] | hid_spikes[53]) << 0
        + (hid_spikes[4] | hid_spikes[8] | hid_spikes[50] | hid_spikes[53] | hid_spikes[56] | hid_spikes[74]) << 1
        + (hid_spikes[53] | hid_spikes[74]) << 2
        + (hid_spikes[50] | hid_spikes[56] | hid_spikes[74]) << 3
        + (hid_spikes[4] | hid_spikes[53] | hid_spikes[56]) << 4
        + (hid_spikes[8] | hid_spikes[24] | hid_spikes[74]) << 5
        + (hid_spikes[50] | hid_spikes[53]) << 6;
    wire signed [11:0] neg_in_base_3 = (hid_spikes[9] | hid_spikes[33] | hid_spikes[36] | hid_spikes[37] | hid_spikes[70] | hid_spikes[72]) << 0
        + (hid_spikes[33] | hid_spikes[68] | hid_spikes[70]) << 1
        + (hid_spikes[33] | hid_spikes[45] | hid_spikes[72]) << 2
        + (hid_spikes[45] | hid_spikes[70] | hid_spikes[72]) << 3
        + (hid_spikes[9] | hid_spikes[37] | hid_spikes[70] | hid_spikes[72]) << 4
        + (hid_spikes[9] | hid_spikes[33] | hid_spikes[36]) << 5
        + (hid_spikes[68] | hid_spikes[72]) << 6
        + (hid_spikes[11]) << 7
        + (hid_spikes[21] | hid_spikes[43] | hid_spikes[59]) << 0
        + (hid_spikes[21] | hid_spikes[35] | hid_spikes[40] | hid_spikes[59]) << 1
        + (hid_spikes[35] | hid_spikes[40] | hid_spikes[43] | hid_spikes[59]) << 2
        + (hid_spikes[21] | hid_spikes[43]) << 3
        + (hid_spikes[21] | hid_spikes[32] | hid_spikes[35] | hid_spikes[40] | hid_spikes[43]) << 4
        + (hid_spikes[40] | hid_spikes[59]) << 5
        + (hid_spikes[1] | hid_spikes[21]) << 6
        + (hid_spikes[54]) << 7
        + (hid_spikes[16] | hid_spikes[28] | hid_spikes[52] | hid_spikes[55] | hid_spikes[76]) << 0
        + (hid_spikes[16] | hid_spikes[17] | hid_spikes[55] | hid_spikes[65] | hid_spikes[76]) << 1
        + (hid_spikes[17] | hid_spikes[52] | hid_spikes[55] | hid_spikes[65] | hid_spikes[76]) << 2
        + (hid_spikes[16] | hid_spikes[17] | hid_spikes[28] | hid_spikes[55]) << 3
        + (hid_spikes[16] | hid_spikes[52] | hid_spikes[65]) << 4
        + (hid_spikes[55] | hid_spikes[76]) << 5
        + (hid_spikes[28] | hid_spikes[65]) << 6
        + (hid_spikes[64]) << 7
        + (hid_spikes[41] | hid_spikes[47] | hid_spikes[57] | hid_spikes[58] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 0
        + (hid_spikes[41] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 1
        + (hid_spikes[6] | hid_spikes[57] | hid_spikes[58] | hid_spikes[75]) << 2
        + (hid_spikes[41] | hid_spikes[58] | hid_spikes[77]) << 3
        + (hid_spikes[6] | hid_spikes[41] | hid_spikes[75]) << 4
        + (hid_spikes[57] | hid_spikes[75] | hid_spikes[77] | hid_spikes[78]) << 5
        + (hid_spikes[47] | hid_spikes[78]) << 6;
    wire signed [11:0] sum_base_3 = pos_in_base_3 - neg_in_base_3;
    assign base_spikes[3] = (mem_base_3 >= 85);
    wire signed [11:0] next_base_3 = mem_base_3 - (mem_base_3 >>> 6) + sum_base_3;

    reg signed [11:0] mem_base_4;
    wire signed [11:0] pos_in_base_4 = (hid_spikes[28] | hid_spikes[37] | hid_spikes[59] | hid_spikes[68]) << 0
        + (hid_spikes[17] | hid_spikes[28] | hid_spikes[37] | hid_spikes[60] | hid_spikes[68]) << 1
        + (hid_spikes[40] | hid_spikes[53] | hid_spikes[59] | hid_spikes[68]) << 2
        + (hid_spikes[28] | hid_spikes[40] | hid_spikes[53] | hid_spikes[60]) << 3
        + (hid_spikes[17] | hid_spikes[23] | hid_spikes[28] | hid_spikes[37] | hid_spikes[40] | hid_spikes[59]) << 4
        + (hid_spikes[17] | hid_spikes[37] | hid_spikes[60] | hid_spikes[68]) << 5
        + (hid_spikes[28] | hid_spikes[53]) << 6
        + (hid_spikes[4] | hid_spikes[10] | hid_spikes[18] | hid_spikes[35] | hid_spikes[50]) << 0
        + (hid_spikes[0] | hid_spikes[4] | hid_spikes[50]) << 1
        + (hid_spikes[0] | hid_spikes[33] | hid_spikes[50]) << 2
        + (hid_spikes[10] | hid_spikes[50] | hid_spikes[74]) << 3
        + (hid_spikes[0] | hid_spikes[10] | hid_spikes[33] | hid_spikes[35] | hid_spikes[50] | hid_spikes[62]) << 4
        + (hid_spikes[4] | hid_spikes[35] | hid_spikes[50] | hid_spikes[74]) << 5
        + (hid_spikes[0] | hid_spikes[18]) << 6
        + (hid_spikes[2] | hid_spikes[7] | hid_spikes[29] | hid_spikes[39] | hid_spikes[65] | hid_spikes[66]) << 0
        + (hid_spikes[2] | hid_spikes[7] | hid_spikes[29] | hid_spikes[39]) << 1
        + (hid_spikes[2] | hid_spikes[7] | hid_spikes[43]) << 2
        + (hid_spikes[2] | hid_spikes[43] | hid_spikes[45]) << 3
        + (hid_spikes[29] | hid_spikes[39] | hid_spikes[41] | hid_spikes[45]) << 4
        + (hid_spikes[7] | hid_spikes[29] | hid_spikes[65]) << 5
        + (hid_spikes[41] | hid_spikes[43] | hid_spikes[66]) << 6
        + (hid_spikes[6] | hid_spikes[20] | hid_spikes[56] | hid_spikes[70]) << 0
        + (hid_spikes[8] | hid_spikes[20] | hid_spikes[26] | hid_spikes[56] | hid_spikes[70]) << 1
        + (hid_spikes[6] | hid_spikes[20] | hid_spikes[26] | hid_spikes[56] | hid_spikes[71]) << 2
        + (hid_spikes[6] | hid_spikes[8] | hid_spikes[20] | hid_spikes[26] | hid_spikes[64] | hid_spikes[71]) << 3
        + (hid_spikes[6] | hid_spikes[26] | hid_spikes[64] | hid_spikes[70]) << 4
        + (hid_spikes[8] | hid_spikes[26] | hid_spikes[56]) << 5
        + (hid_spikes[20] | hid_spikes[57]) << 6;
    wire signed [11:0] neg_in_base_4 = (hid_spikes[1] | hid_spikes[31] | hid_spikes[32] | hid_spikes[46] | hid_spikes[58]) << 0
        + (hid_spikes[15] | hid_spikes[31] | hid_spikes[32] | hid_spikes[34] | hid_spikes[46]) << 1
        + (hid_spikes[1] | hid_spikes[31] | hid_spikes[32] | hid_spikes[34] | hid_spikes[46]) << 2
        + (hid_spikes[32] | hid_spikes[34]) << 3
        + (hid_spikes[1] | hid_spikes[46]) << 4
        + (hid_spikes[15] | hid_spikes[31] | hid_spikes[58]) << 5
        + (hid_spikes[1] | hid_spikes[15] | hid_spikes[34]) << 6
        + (hid_spikes[11]) << 7
        + (hid_spikes[14] | hid_spikes[47] | hid_spikes[63]) << 0
        + (hid_spikes[14] | hid_spikes[21] | hid_spikes[47] | hid_spikes[51]) << 1
        + (hid_spikes[14] | hid_spikes[21] | hid_spikes[30] | hid_spikes[47] | hid_spikes[51] | hid_spikes[63]) << 2
        + (hid_spikes[14] | hid_spikes[63]) << 3
        + (hid_spikes[14] | hid_spikes[30] | hid_spikes[47]) << 4
        + (hid_spikes[30] | hid_spikes[48] | hid_spikes[51]) << 5
        + (hid_spikes[14] | hid_spikes[21]) << 6
        + (hid_spikes[78]) << 7
        + (hid_spikes[19] | hid_spikes[54] | hid_spikes[69] | hid_spikes[75] | hid_spikes[76]) << 0
        + (hid_spikes[19] | hid_spikes[54]) << 1
        + (hid_spikes[54] | hid_spikes[55] | hid_spikes[76] | hid_spikes[79]) << 2
        + (hid_spikes[19] | hid_spikes[54] | hid_spikes[55] | hid_spikes[69] | hid_spikes[75] | hid_spikes[76]) << 3
        + (hid_spikes[55] | hid_spikes[67] | hid_spikes[69]) << 4
        + (hid_spikes[19] | hid_spikes[69] | hid_spikes[75] | hid_spikes[79]) << 5
        + (hid_spikes[19] | hid_spikes[54]) << 6
        + (hid_spikes[22] | hid_spikes[27] | hid_spikes[61] | hid_spikes[73]) << 0
        + (hid_spikes[22] | hid_spikes[25] | hid_spikes[27] | hid_spikes[36] | hid_spikes[61]) << 1
        + (hid_spikes[25] | hid_spikes[27]) << 2
        + (hid_spikes[22] | hid_spikes[27] | hid_spikes[36] | hid_spikes[72]) << 3
        + (hid_spikes[22] | hid_spikes[36]) << 4
        + (hid_spikes[25] | hid_spikes[61] | hid_spikes[72]) << 5
        + (hid_spikes[25] | hid_spikes[36] | hid_spikes[73]) << 6;
    wire signed [11:0] sum_base_4 = pos_in_base_4 - neg_in_base_4;
    assign base_spikes[4] = (mem_base_4 >= 85);
    wire signed [11:0] next_base_4 = mem_base_4 - (mem_base_4 >>> 6) + sum_base_4;

    reg signed [11:0] mem_base_5;
    wire signed [11:0] pos_in_base_5 = (hid_spikes[0] | hid_spikes[24] | hid_spikes[50] | hid_spikes[71]) << 0
        + (hid_spikes[0] | hid_spikes[6] | hid_spikes[22] | hid_spikes[47] | hid_spikes[50] | hid_spikes[71]) << 1
        + (hid_spikes[6] | hid_spikes[34] | hid_spikes[47] | hid_spikes[50] | hid_spikes[71]) << 2
        + (hid_spikes[22] | hid_spikes[24] | hid_spikes[34] | hid_spikes[47] | hid_spikes[71]) << 3
        + (hid_spikes[0] | hid_spikes[6] | hid_spikes[34] | hid_spikes[50]) << 4
        + (hid_spikes[6] | hid_spikes[20] | hid_spikes[24]) << 5
        + (hid_spikes[20] | hid_spikes[22]) << 6
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[9]) << 0
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[23] | hid_spikes[28] | hid_spikes[40] | hid_spikes[61] | hid_spikes[67]) << 1
        + (hid_spikes[4] | hid_spikes[9] | hid_spikes[28] | hid_spikes[40] | hid_spikes[61] | hid_spikes[67]) << 2
        + (hid_spikes[4] | hid_spikes[28] | hid_spikes[43] | hid_spikes[61] | hid_spikes[67]) << 3
        + (hid_spikes[9] | hid_spikes[23] | hid_spikes[40] | hid_spikes[43] | hid_spikes[67]) << 4
        + (hid_spikes[4] | hid_spikes[5] | hid_spikes[40]) << 5
        + (hid_spikes[67]) << 6
        + (hid_spikes[12] | hid_spikes[13] | hid_spikes[30] | hid_spikes[62] | hid_spikes[78]) << 0
        + (hid_spikes[12] | hid_spikes[30] | hid_spikes[32] | hid_spikes[37] | hid_spikes[62] | hid_spikes[73]) << 1
        + (hid_spikes[12] | hid_spikes[15] | hid_spikes[30] | hid_spikes[32] | hid_spikes[62] | hid_spikes[73] | hid_spikes[78]) << 2
        + (hid_spikes[12] | hid_spikes[13] | hid_spikes[32] | hid_spikes[78]) << 3
        + (hid_spikes[12] | hid_spikes[13] | hid_spikes[15] | hid_spikes[30] | hid_spikes[37] | hid_spikes[62]) << 4
        + (hid_spikes[62] | hid_spikes[73]) << 5
        + (hid_spikes[13]) << 6
        + (hid_spikes[2] | hid_spikes[46] | hid_spikes[51] | hid_spikes[54] | hid_spikes[57]) << 0
        + (hid_spikes[39] | hid_spikes[45] | hid_spikes[46] | hid_spikes[51] | hid_spikes[54]) << 1
        + (hid_spikes[2] | hid_spikes[38] | hid_spikes[45] | hid_spikes[46] | hid_spikes[51] | hid_spikes[57]) << 2
        + (hid_spikes[45] | hid_spikes[54] | hid_spikes[57]) << 3
        + (hid_spikes[2] | hid_spikes[38] | hid_spikes[39] | hid_spikes[46] | hid_spikes[51] | hid_spikes[57]) << 4
        + (hid_spikes[2] | hid_spikes[54]) << 5
        + (hid_spikes[51]) << 6;
    wire signed [11:0] neg_in_base_5 = (hid_spikes[19] | hid_spikes[26] | hid_spikes[36] | hid_spikes[79]) << 0
        + (hid_spikes[68] | hid_spikes[79]) << 1
        + (hid_spikes[26] | hid_spikes[36]) << 2
        + (hid_spikes[26] | hid_spikes[36] | hid_spikes[68] | hid_spikes[79]) << 3
        + (hid_spikes[26] | hid_spikes[63] | hid_spikes[68]) << 4
        + (hid_spikes[19] | hid_spikes[26] | hid_spikes[36]) << 5
        + (hid_spikes[79]) << 6
        + (hid_spikes[18]) << 7
        + (hid_spikes[1] | hid_spikes[49] | hid_spikes[76]) << 0
        + (hid_spikes[16] | hid_spikes[49]) << 1
        + (hid_spikes[1] | hid_spikes[16] | hid_spikes[17] | hid_spikes[49]) << 2
        + (hid_spikes[16] | hid_spikes[49] | hid_spikes[76]) << 3
        + (hid_spikes[16] | hid_spikes[17]) << 4
        + (hid_spikes[1] | hid_spikes[16] | hid_spikes[70]) << 5
        + (hid_spikes[76]) << 6
        + (hid_spikes[75]) << 7
        + (hid_spikes[3] | hid_spikes[25] | hid_spikes[52] | hid_spikes[64]) << 0
        + (hid_spikes[3] | hid_spikes[25] | hid_spikes[60] | hid_spikes[64]) << 1
        + (hid_spikes[42] | hid_spikes[52] | hid_spikes[64] | hid_spikes[74]) << 2
        + (hid_spikes[52] | hid_spikes[60] | hid_spikes[64] | hid_spikes[74]) << 3
        + (hid_spikes[3] | hid_spikes[25] | hid_spikes[52] | hid_spikes[60] | hid_spikes[74]) << 4
        + (hid_spikes[3] | hid_spikes[42] | hid_spikes[60] | hid_spikes[74]) << 5
        + (hid_spikes[74]) << 6
        + (hid_spikes[11] | hid_spikes[53] | hid_spikes[66]) << 0
        + (hid_spikes[55]) << 1
        + (hid_spikes[53] | hid_spikes[66] | hid_spikes[69]) << 2
        + (hid_spikes[53] | hid_spikes[55] | hid_spikes[58] | hid_spikes[69]) << 3
        + (hid_spikes[11] | hid_spikes[55] | hid_spikes[69]) << 4
        + (hid_spikes[33] | hid_spikes[55]) << 5
        + (hid_spikes[33] | hid_spikes[58] | hid_spikes[66]) << 6;
    wire signed [11:0] sum_base_5 = pos_in_base_5 - neg_in_base_5;
    assign base_spikes[5] = (mem_base_5 >= 85);
    wire signed [11:0] next_base_5 = mem_base_5 - (mem_base_5 >>> 6) + sum_base_5;

    // ==========================================
    // SYNCHRONOUS MEMBRANE UPDATES
    // ==========================================
    always @(posedge clk_1mhz or negedge rst_n) begin
        if (!rst_n) begin
            mem_hid_0 <= 0;
            mem_hid_1 <= 0;
            mem_hid_2 <= 0;
            mem_hid_3 <= 0;
            mem_hid_4 <= 0;
            mem_hid_5 <= 0;
            mem_hid_6 <= 0;
            mem_hid_7 <= 0;
            mem_hid_8 <= 0;
            mem_hid_9 <= 0;
            mem_hid_10 <= 0;
            mem_hid_11 <= 0;
            mem_hid_12 <= 0;
            mem_hid_13 <= 0;
            mem_hid_14 <= 0;
            mem_hid_15 <= 0;
            mem_hid_16 <= 0;
            mem_hid_17 <= 0;
            mem_hid_18 <= 0;
            mem_hid_19 <= 0;
            mem_hid_20 <= 0;
            mem_hid_21 <= 0;
            mem_hid_22 <= 0;
            mem_hid_23 <= 0;
            mem_hid_24 <= 0;
            mem_hid_25 <= 0;
            mem_hid_26 <= 0;
            mem_hid_27 <= 0;
            mem_hid_28 <= 0;
            mem_hid_29 <= 0;
            mem_hid_30 <= 0;
            mem_hid_31 <= 0;
            mem_hid_32 <= 0;
            mem_hid_33 <= 0;
            mem_hid_34 <= 0;
            mem_hid_35 <= 0;
            mem_hid_36 <= 0;
            mem_hid_37 <= 0;
            mem_hid_38 <= 0;
            mem_hid_39 <= 0;
            mem_hid_40 <= 0;
            mem_hid_41 <= 0;
            mem_hid_42 <= 0;
            mem_hid_43 <= 0;
            mem_hid_44 <= 0;
            mem_hid_45 <= 0;
            mem_hid_46 <= 0;
            mem_hid_47 <= 0;
            mem_hid_48 <= 0;
            mem_hid_49 <= 0;
            mem_hid_50 <= 0;
            mem_hid_51 <= 0;
            mem_hid_52 <= 0;
            mem_hid_53 <= 0;
            mem_hid_54 <= 0;
            mem_hid_55 <= 0;
            mem_hid_56 <= 0;
            mem_hid_57 <= 0;
            mem_hid_58 <= 0;
            mem_hid_59 <= 0;
            mem_hid_60 <= 0;
            mem_hid_61 <= 0;
            mem_hid_62 <= 0;
            mem_hid_63 <= 0;
            mem_hid_64 <= 0;
            mem_hid_65 <= 0;
            mem_hid_66 <= 0;
            mem_hid_67 <= 0;
            mem_hid_68 <= 0;
            mem_hid_69 <= 0;
            mem_hid_70 <= 0;
            mem_hid_71 <= 0;
            mem_hid_72 <= 0;
            mem_hid_73 <= 0;
            mem_hid_74 <= 0;
            mem_hid_75 <= 0;
            mem_hid_76 <= 0;
            mem_hid_77 <= 0;
            mem_hid_78 <= 0;
            mem_hid_79 <= 0;
            mem_base_0 <= 0;
            mem_base_1 <= 0;
            mem_base_2 <= 0;
            mem_base_3 <= 0;
            mem_base_4 <= 0;
            mem_base_5 <= 0;
        end else if (tick_1ms) begin
            mem_hid_0 <= hid_spikes[0] ? 0 : next_hid_0;
            mem_hid_1 <= hid_spikes[1] ? 0 : next_hid_1;
            mem_hid_2 <= hid_spikes[2] ? 0 : next_hid_2;
            mem_hid_3 <= hid_spikes[3] ? 0 : next_hid_3;
            mem_hid_4 <= hid_spikes[4] ? 0 : next_hid_4;
            mem_hid_5 <= hid_spikes[5] ? 0 : next_hid_5;
            mem_hid_6 <= hid_spikes[6] ? 0 : next_hid_6;
            mem_hid_7 <= hid_spikes[7] ? 0 : next_hid_7;
            mem_hid_8 <= hid_spikes[8] ? 0 : next_hid_8;
            mem_hid_9 <= hid_spikes[9] ? 0 : next_hid_9;
            mem_hid_10 <= hid_spikes[10] ? 0 : next_hid_10;
            mem_hid_11 <= hid_spikes[11] ? 0 : next_hid_11;
            mem_hid_12 <= hid_spikes[12] ? 0 : next_hid_12;
            mem_hid_13 <= hid_spikes[13] ? 0 : next_hid_13;
            mem_hid_14 <= hid_spikes[14] ? 0 : next_hid_14;
            mem_hid_15 <= hid_spikes[15] ? 0 : next_hid_15;
            mem_hid_16 <= hid_spikes[16] ? 0 : next_hid_16;
            mem_hid_17 <= hid_spikes[17] ? 0 : next_hid_17;
            mem_hid_18 <= hid_spikes[18] ? 0 : next_hid_18;
            mem_hid_19 <= hid_spikes[19] ? 0 : next_hid_19;
            mem_hid_20 <= hid_spikes[20] ? 0 : next_hid_20;
            mem_hid_21 <= hid_spikes[21] ? 0 : next_hid_21;
            mem_hid_22 <= hid_spikes[22] ? 0 : next_hid_22;
            mem_hid_23 <= hid_spikes[23] ? 0 : next_hid_23;
            mem_hid_24 <= hid_spikes[24] ? 0 : next_hid_24;
            mem_hid_25 <= hid_spikes[25] ? 0 : next_hid_25;
            mem_hid_26 <= hid_spikes[26] ? 0 : next_hid_26;
            mem_hid_27 <= hid_spikes[27] ? 0 : next_hid_27;
            mem_hid_28 <= hid_spikes[28] ? 0 : next_hid_28;
            mem_hid_29 <= hid_spikes[29] ? 0 : next_hid_29;
            mem_hid_30 <= hid_spikes[30] ? 0 : next_hid_30;
            mem_hid_31 <= hid_spikes[31] ? 0 : next_hid_31;
            mem_hid_32 <= hid_spikes[32] ? 0 : next_hid_32;
            mem_hid_33 <= hid_spikes[33] ? 0 : next_hid_33;
            mem_hid_34 <= hid_spikes[34] ? 0 : next_hid_34;
            mem_hid_35 <= hid_spikes[35] ? 0 : next_hid_35;
            mem_hid_36 <= hid_spikes[36] ? 0 : next_hid_36;
            mem_hid_37 <= hid_spikes[37] ? 0 : next_hid_37;
            mem_hid_38 <= hid_spikes[38] ? 0 : next_hid_38;
            mem_hid_39 <= hid_spikes[39] ? 0 : next_hid_39;
            mem_hid_40 <= hid_spikes[40] ? 0 : next_hid_40;
            mem_hid_41 <= hid_spikes[41] ? 0 : next_hid_41;
            mem_hid_42 <= hid_spikes[42] ? 0 : next_hid_42;
            mem_hid_43 <= hid_spikes[43] ? 0 : next_hid_43;
            mem_hid_44 <= hid_spikes[44] ? 0 : next_hid_44;
            mem_hid_45 <= hid_spikes[45] ? 0 : next_hid_45;
            mem_hid_46 <= hid_spikes[46] ? 0 : next_hid_46;
            mem_hid_47 <= hid_spikes[47] ? 0 : next_hid_47;
            mem_hid_48 <= hid_spikes[48] ? 0 : next_hid_48;
            mem_hid_49 <= hid_spikes[49] ? 0 : next_hid_49;
            mem_hid_50 <= hid_spikes[50] ? 0 : next_hid_50;
            mem_hid_51 <= hid_spikes[51] ? 0 : next_hid_51;
            mem_hid_52 <= hid_spikes[52] ? 0 : next_hid_52;
            mem_hid_53 <= hid_spikes[53] ? 0 : next_hid_53;
            mem_hid_54 <= hid_spikes[54] ? 0 : next_hid_54;
            mem_hid_55 <= hid_spikes[55] ? 0 : next_hid_55;
            mem_hid_56 <= hid_spikes[56] ? 0 : next_hid_56;
            mem_hid_57 <= hid_spikes[57] ? 0 : next_hid_57;
            mem_hid_58 <= hid_spikes[58] ? 0 : next_hid_58;
            mem_hid_59 <= hid_spikes[59] ? 0 : next_hid_59;
            mem_hid_60 <= hid_spikes[60] ? 0 : next_hid_60;
            mem_hid_61 <= hid_spikes[61] ? 0 : next_hid_61;
            mem_hid_62 <= hid_spikes[62] ? 0 : next_hid_62;
            mem_hid_63 <= hid_spikes[63] ? 0 : next_hid_63;
            mem_hid_64 <= hid_spikes[64] ? 0 : next_hid_64;
            mem_hid_65 <= hid_spikes[65] ? 0 : next_hid_65;
            mem_hid_66 <= hid_spikes[66] ? 0 : next_hid_66;
            mem_hid_67 <= hid_spikes[67] ? 0 : next_hid_67;
            mem_hid_68 <= hid_spikes[68] ? 0 : next_hid_68;
            mem_hid_69 <= hid_spikes[69] ? 0 : next_hid_69;
            mem_hid_70 <= hid_spikes[70] ? 0 : next_hid_70;
            mem_hid_71 <= hid_spikes[71] ? 0 : next_hid_71;
            mem_hid_72 <= hid_spikes[72] ? 0 : next_hid_72;
            mem_hid_73 <= hid_spikes[73] ? 0 : next_hid_73;
            mem_hid_74 <= hid_spikes[74] ? 0 : next_hid_74;
            mem_hid_75 <= hid_spikes[75] ? 0 : next_hid_75;
            mem_hid_76 <= hid_spikes[76] ? 0 : next_hid_76;
            mem_hid_77 <= hid_spikes[77] ? 0 : next_hid_77;
            mem_hid_78 <= hid_spikes[78] ? 0 : next_hid_78;
            mem_hid_79 <= hid_spikes[79] ? 0 : next_hid_79;
            mem_base_0 <= base_spikes[0] ? 0 : next_base_0;
            mem_base_1 <= base_spikes[1] ? 0 : next_base_1;
            mem_base_2 <= base_spikes[2] ? 0 : next_base_2;
            mem_base_3 <= base_spikes[3] ? 0 : next_base_3;
            mem_base_4 <= base_spikes[4] ? 0 : next_base_4;
            mem_base_5 <= base_spikes[5] ? 0 : next_base_5;
        end
    end
endmodule
