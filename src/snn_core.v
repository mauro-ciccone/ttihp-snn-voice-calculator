`default_nettype none
module snn_core (
    input  wire       clk_1mhz,
    input  wire       rst_n,
    input  wire       tick_1ms,
    input  wire [5:0] cochlea_spikes,
    output wire [4:0] wta_spikes
);

    // ==========================================
    // HIDDEN LAYER (OR-Gate Bitwise Synthesis)
    // ==========================================
    wire [127:0] hid_spikes;
    assign hid_spikes[127:64] = 0;

    reg signed [11:0] mem_hid_0;
    wire signed [11:0] pos_in_0 = ((cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 3)
        + ((hid_spikes[0] | hid_spikes[14] | hid_spikes[17] | hid_spikes[46]) << 0)
        + ((hid_spikes[3] | hid_spikes[14] | hid_spikes[24] | hid_spikes[33] | hid_spikes[35] | hid_spikes[41] | hid_spikes[46]) << 1)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[17] | hid_spikes[24] | hid_spikes[33] | hid_spikes[35] | hid_spikes[46] | hid_spikes[61]) << 2)
        + ((hid_spikes[61]) << 3);
    wire signed [11:0] neg_in_0 = ((cochlea_spikes[4] | cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 4)
        + ((cochlea_spikes[4]) << 5)
        + ((cochlea_spikes[1]) << 6)
        + ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[2]) << 5)
        + ((hid_spikes[4] | hid_spikes[6] | hid_spikes[8] | hid_spikes[9] | hid_spikes[13] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[20] | hid_spikes[25] | hid_spikes[27] | hid_spikes[28] | hid_spikes[34] | hid_spikes[37] | hid_spikes[40] | hid_spikes[42] | hid_spikes[44] | hid_spikes[45] | hid_spikes[48] | hid_spikes[50] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[58] | hid_spikes[59] | hid_spikes[63]) << 0)
        + ((hid_spikes[2] | hid_spikes[4] | hid_spikes[6] | hid_spikes[7] | hid_spikes[8] | hid_spikes[11] | hid_spikes[12] | hid_spikes[15] | hid_spikes[20] | hid_spikes[23] | hid_spikes[25] | hid_spikes[26] | hid_spikes[28] | hid_spikes[34] | hid_spikes[40] | hid_spikes[44] | hid_spikes[45] | hid_spikes[49] | hid_spikes[52] | hid_spikes[58] | hid_spikes[59] | hid_spikes[60] | hid_spikes[62]) << 1)
        + ((hid_spikes[4] | hid_spikes[9] | hid_spikes[12] | hid_spikes[13] | hid_spikes[16] | hid_spikes[19] | hid_spikes[20] | hid_spikes[23] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[32] | hid_spikes[34] | hid_spikes[37] | hid_spikes[40] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[58] | hid_spikes[59] | hid_spikes[60] | hid_spikes[62]) << 2)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[4] | hid_spikes[6] | hid_spikes[7] | hid_spikes[9] | hid_spikes[12] | hid_spikes[15] | hid_spikes[31] | hid_spikes[36] | hid_spikes[43] | hid_spikes[45] | hid_spikes[49] | hid_spikes[52] | hid_spikes[56] | hid_spikes[63]) << 3)
        + ((hid_spikes[7] | hid_spikes[10] | hid_spikes[27] | hid_spikes[32] | hid_spikes[42] | hid_spikes[55]) << 4);
    wire signed [11:0] sum_hid_0 = pos_in_0 - neg_in_0;
    assign hid_spikes[0] = (mem_hid_0 >= 10);
    wire signed [11:0] next_hid_0 = mem_hid_0 - (mem_hid_0 >>> 5) + sum_hid_0;

    reg signed [11:0] mem_hid_1;
    wire signed [11:0] pos_in_1 = ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2]) << 3)
        + ((hid_spikes[2] | hid_spikes[10] | hid_spikes[22] | hid_spikes[26] | hid_spikes[28] | hid_spikes[33] | hid_spikes[38] | hid_spikes[40] | hid_spikes[41]) << 0)
        + ((hid_spikes[10] | hid_spikes[15] | hid_spikes[22] | hid_spikes[26] | hid_spikes[28] | hid_spikes[33] | hid_spikes[38] | hid_spikes[41] | hid_spikes[43] | hid_spikes[45] | hid_spikes[50] | hid_spikes[56]) << 1)
        + ((hid_spikes[2] | hid_spikes[10] | hid_spikes[13] | hid_spikes[15] | hid_spikes[20] | hid_spikes[26] | hid_spikes[28] | hid_spikes[33] | hid_spikes[38] | hid_spikes[43] | hid_spikes[47] | hid_spikes[50]) << 2)
        + ((hid_spikes[20] | hid_spikes[22] | hid_spikes[40] | hid_spikes[45] | hid_spikes[56] | hid_spikes[60]) << 3)
        + ((hid_spikes[25]) << 4);
    wire signed [11:0] neg_in_1 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[1]) << 4)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((hid_spikes[9] | hid_spikes[11] | hid_spikes[18] | hid_spikes[24] | hid_spikes[30] | hid_spikes[34] | hid_spikes[53] | hid_spikes[54] | hid_spikes[59] | hid_spikes[63]) << 0)
        + ((hid_spikes[3] | hid_spikes[9] | hid_spikes[11] | hid_spikes[12] | hid_spikes[14] | hid_spikes[16] | hid_spikes[17] | hid_spikes[18] | hid_spikes[24] | hid_spikes[30] | hid_spikes[34] | hid_spikes[39] | hid_spikes[44] | hid_spikes[54] | hid_spikes[55] | hid_spikes[59] | hid_spikes[63]) << 1)
        + ((hid_spikes[1] | hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[11] | hid_spikes[12] | hid_spikes[17] | hid_spikes[21] | hid_spikes[34] | hid_spikes[36] | hid_spikes[44] | hid_spikes[52] | hid_spikes[55]) << 2)
        + ((hid_spikes[3] | hid_spikes[7] | hid_spikes[8] | hid_spikes[14] | hid_spikes[16] | hid_spikes[19] | hid_spikes[24] | hid_spikes[36] | hid_spikes[39] | hid_spikes[53] | hid_spikes[54] | hid_spikes[62]) << 3)
        + ((hid_spikes[8] | hid_spikes[29]) << 4)
        + ((hid_spikes[14]) << 5);
    wire signed [11:0] sum_hid_1 = pos_in_1 - neg_in_1;
    assign hid_spikes[1] = (mem_hid_1 >= 10);
    wire signed [11:0] next_hid_1 = mem_hid_1 - (mem_hid_1 >>> 5) + sum_hid_1;

    reg signed [11:0] mem_hid_2;
    wire signed [11:0] pos_in_2 = ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[4]) << 5)
        + ((hid_spikes[4] | hid_spikes[7] | hid_spikes[9] | hid_spikes[33] | hid_spikes[34] | hid_spikes[38] | hid_spikes[50] | hid_spikes[58] | hid_spikes[59] | hid_spikes[61] | hid_spikes[63]) << 0)
        + ((hid_spikes[4] | hid_spikes[19] | hid_spikes[33] | hid_spikes[42] | hid_spikes[51] | hid_spikes[54] | hid_spikes[61] | hid_spikes[63]) << 1)
        + ((hid_spikes[7] | hid_spikes[9] | hid_spikes[33] | hid_spikes[34] | hid_spikes[38] | hid_spikes[42] | hid_spikes[56]) << 2)
        + ((hid_spikes[7] | hid_spikes[54] | hid_spikes[58] | hid_spikes[59]) << 3)
        + ((hid_spikes[50] | hid_spikes[55]) << 4);
    wire signed [11:0] neg_in_2 = ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0] | cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[0]) << 4)
        + ((cochlea_spikes[3]) << 7)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[1] | cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2]) << 6)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[5] | hid_spikes[8] | hid_spikes[12] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[23] | hid_spikes[24] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[29] | hid_spikes[31] | hid_spikes[35] | hid_spikes[41] | hid_spikes[43] | hid_spikes[45] | hid_spikes[47] | hid_spikes[49] | hid_spikes[52] | hid_spikes[57]) << 0)
        + ((hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[12] | hid_spikes[15] | hid_spikes[20] | hid_spikes[21] | hid_spikes[24] | hid_spikes[29] | hid_spikes[35] | hid_spikes[36] | hid_spikes[37] | hid_spikes[39] | hid_spikes[40] | hid_spikes[41] | hid_spikes[44] | hid_spikes[45] | hid_spikes[47] | hid_spikes[53] | hid_spikes[57] | hid_spikes[60]) << 1)
        + ((hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[10] | hid_spikes[12] | hid_spikes[16] | hid_spikes[18] | hid_spikes[20] | hid_spikes[23] | hid_spikes[24] | hid_spikes[25] | hid_spikes[27] | hid_spikes[28] | hid_spikes[31] | hid_spikes[35] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[47] | hid_spikes[49] | hid_spikes[53] | hid_spikes[57]) << 2)
        + ((hid_spikes[1] | hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[12] | hid_spikes[15] | hid_spikes[16] | hid_spikes[18] | hid_spikes[24] | hid_spikes[26] | hid_spikes[27] | hid_spikes[29] | hid_spikes[32] | hid_spikes[40] | hid_spikes[41] | hid_spikes[43] | hid_spikes[44] | hid_spikes[48] | hid_spikes[52]) << 3)
        + ((hid_spikes[0] | hid_spikes[13] | hid_spikes[14] | hid_spikes[35] | hid_spikes[36] | hid_spikes[39] | hid_spikes[62]) << 4);
    wire signed [11:0] sum_hid_2 = pos_in_2 - neg_in_2;
    assign hid_spikes[2] = (mem_hid_2 >= 10);
    wire signed [11:0] next_hid_2 = mem_hid_2 - (mem_hid_2 >>> 6) + sum_hid_2;

    reg signed [11:0] mem_hid_3;
    wire signed [11:0] pos_in_3 = ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 5)
        + ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 4)
        + ((hid_spikes[22] | hid_spikes[36] | hid_spikes[42] | hid_spikes[43]) << 0)
        + ((hid_spikes[10] | hid_spikes[31] | hid_spikes[40] | hid_spikes[43] | hid_spikes[50] | hid_spikes[60]) << 1)
        + ((hid_spikes[10] | hid_spikes[26] | hid_spikes[36] | hid_spikes[38] | hid_spikes[47] | hid_spikes[60]) << 2)
        + ((hid_spikes[22] | hid_spikes[36] | hid_spikes[42]) << 3);
    wire signed [11:0] neg_in_3 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[0] | cochlea_spikes[1]) << 5)
        + ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2]) << 5)
        + ((hid_spikes[3] | hid_spikes[6] | hid_spikes[8] | hid_spikes[9] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[18] | hid_spikes[23] | hid_spikes[27] | hid_spikes[30] | hid_spikes[33] | hid_spikes[35] | hid_spikes[45] | hid_spikes[49] | hid_spikes[52] | hid_spikes[54] | hid_spikes[59]) << 0)
        + ((hid_spikes[3] | hid_spikes[4] | hid_spikes[8] | hid_spikes[11] | hid_spikes[13] | hid_spikes[15] | hid_spikes[17] | hid_spikes[18] | hid_spikes[20] | hid_spikes[23] | hid_spikes[24] | hid_spikes[30] | hid_spikes[32] | hid_spikes[48] | hid_spikes[57] | hid_spikes[59] | hid_spikes[61]) << 1)
        + ((hid_spikes[1] | hid_spikes[3] | hid_spikes[8] | hid_spikes[15] | hid_spikes[17] | hid_spikes[18] | hid_spikes[20] | hid_spikes[24] | hid_spikes[28] | hid_spikes[32] | hid_spikes[39] | hid_spikes[45] | hid_spikes[48] | hid_spikes[49] | hid_spikes[51] | hid_spikes[52] | hid_spikes[57] | hid_spikes[58]) << 2)
        + ((hid_spikes[6] | hid_spikes[9] | hid_spikes[13] | hid_spikes[14] | hid_spikes[16] | hid_spikes[17] | hid_spikes[19] | hid_spikes[23] | hid_spikes[27] | hid_spikes[32] | hid_spikes[33] | hid_spikes[37] | hid_spikes[44] | hid_spikes[45] | hid_spikes[54] | hid_spikes[61]) << 3)
        + ((hid_spikes[11] | hid_spikes[35] | hid_spikes[39] | hid_spikes[41] | hid_spikes[55]) << 4)
        + ((hid_spikes[46]) << 5);
    wire signed [11:0] sum_hid_3 = pos_in_3 - neg_in_3;
    assign hid_spikes[3] = (mem_hid_3 >= 10);
    wire signed [11:0] next_hid_3 = mem_hid_3 - (mem_hid_3 >>> 5) + sum_hid_3;

    reg signed [11:0] mem_hid_4;
    wire signed [11:0] pos_in_4 = ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 3)
        + ((hid_spikes[4] | hid_spikes[8] | hid_spikes[11] | hid_spikes[12] | hid_spikes[22] | hid_spikes[26] | hid_spikes[31] | hid_spikes[40] | hid_spikes[46] | hid_spikes[52] | hid_spikes[57]) << 0)
        + ((hid_spikes[7] | hid_spikes[9] | hid_spikes[12] | hid_spikes[21] | hid_spikes[22] | hid_spikes[26] | hid_spikes[34] | hid_spikes[37] | hid_spikes[38] | hid_spikes[42] | hid_spikes[46] | hid_spikes[52] | hid_spikes[55] | hid_spikes[56] | hid_spikes[59] | hid_spikes[60] | hid_spikes[62]) << 1)
        + ((hid_spikes[4] | hid_spikes[9] | hid_spikes[11] | hid_spikes[12] | hid_spikes[20] | hid_spikes[21] | hid_spikes[22] | hid_spikes[26] | hid_spikes[31] | hid_spikes[34] | hid_spikes[35] | hid_spikes[37] | hid_spikes[40] | hid_spikes[42] | hid_spikes[46] | hid_spikes[47] | hid_spikes[55] | hid_spikes[56] | hid_spikes[57] | hid_spikes[60] | hid_spikes[62]) << 2)
        + ((hid_spikes[4] | hid_spikes[6] | hid_spikes[8] | hid_spikes[20] | hid_spikes[26] | hid_spikes[35] | hid_spikes[38] | hid_spikes[40] | hid_spikes[47] | hid_spikes[56] | hid_spikes[59]) << 3)
        + ((hid_spikes[7]) << 4);
    wire signed [11:0] neg_in_4 = ((cochlea_spikes[0] | cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[0] | cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[0] | cochlea_spikes[1]) << 4)
        + ((cochlea_spikes[0]) << 6)
        + ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[4] | cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[4] | cochlea_spikes[5]) << 5)
        + ((hid_spikes[2] | hid_spikes[14] | hid_spikes[18] | hid_spikes[23] | hid_spikes[24] | hid_spikes[36] | hid_spikes[44] | hid_spikes[45] | hid_spikes[48] | hid_spikes[49] | hid_spikes[51] | hid_spikes[61]) << 0)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[5] | hid_spikes[14] | hid_spikes[18] | hid_spikes[19] | hid_spikes[28] | hid_spikes[49] | hid_spikes[61]) << 1)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[5] | hid_spikes[16] | hid_spikes[18] | hid_spikes[19] | hid_spikes[24] | hid_spikes[36] | hid_spikes[39] | hid_spikes[41] | hid_spikes[44]) << 2)
        + ((hid_spikes[0] | hid_spikes[5] | hid_spikes[14] | hid_spikes[15] | hid_spikes[23] | hid_spikes[33] | hid_spikes[36] | hid_spikes[39] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[51]) << 3)
        + ((hid_spikes[45]) << 4);
    wire signed [11:0] sum_hid_4 = pos_in_4 - neg_in_4;
    assign hid_spikes[4] = (mem_hid_4 >= 10);
    wire signed [11:0] next_hid_4 = mem_hid_4 - (mem_hid_4 >>> 6) + sum_hid_4;

    reg signed [11:0] mem_hid_5;
    wire signed [11:0] pos_in_5 = ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 4)
        + ((cochlea_spikes[0]) << 5)
        + ((hid_spikes[0] | hid_spikes[7] | hid_spikes[11] | hid_spikes[14] | hid_spikes[22] | hid_spikes[25] | hid_spikes[29] | hid_spikes[30] | hid_spikes[45] | hid_spikes[58] | hid_spikes[60]) << 0)
        + ((hid_spikes[7] | hid_spikes[14] | hid_spikes[17] | hid_spikes[20] | hid_spikes[22] | hid_spikes[25] | hid_spikes[30] | hid_spikes[34] | hid_spikes[44] | hid_spikes[58]) << 1)
        + ((hid_spikes[0] | hid_spikes[17] | hid_spikes[21] | hid_spikes[24] | hid_spikes[29] | hid_spikes[45] | hid_spikes[58]) << 2)
        + ((hid_spikes[9] | hid_spikes[11] | hid_spikes[17] | hid_spikes[20] | hid_spikes[21] | hid_spikes[25] | hid_spikes[29] | hid_spikes[38] | hid_spikes[60]) << 3);
    wire signed [11:0] neg_in_5 = ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[1]) << 4)
        + ((cochlea_spikes[1]) << 6)
        + ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[3] | cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[3] | cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[5]) << 5)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[4] | hid_spikes[6] | hid_spikes[15] | hid_spikes[16] | hid_spikes[31] | hid_spikes[32] | hid_spikes[33] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[52] | hid_spikes[54] | hid_spikes[57] | hid_spikes[62]) << 0)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[3] | hid_spikes[4] | hid_spikes[6] | hid_spikes[15] | hid_spikes[26] | hid_spikes[31] | hid_spikes[35] | hid_spikes[36] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[54] | hid_spikes[55] | hid_spikes[57]) << 1)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[4] | hid_spikes[5] | hid_spikes[6] | hid_spikes[12] | hid_spikes[16] | hid_spikes[18] | hid_spikes[31] | hid_spikes[32] | hid_spikes[33] | hid_spikes[37] | hid_spikes[39] | hid_spikes[41] | hid_spikes[42] | hid_spikes[47] | hid_spikes[49] | hid_spikes[57] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63]) << 2)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[8] | hid_spikes[18] | hid_spikes[28] | hid_spikes[41] | hid_spikes[48] | hid_spikes[52] | hid_spikes[63]) << 3)
        + ((hid_spikes[19] | hid_spikes[51]) << 4);
    wire signed [11:0] sum_hid_5 = pos_in_5 - neg_in_5;
    assign hid_spikes[5] = (mem_hid_5 >= 10);
    wire signed [11:0] next_hid_5 = mem_hid_5 - (mem_hid_5 >>> 6) + sum_hid_5;

    reg signed [11:0] mem_hid_6;
    wire signed [11:0] pos_in_6 = ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[3]) << 3)
        + ((hid_spikes[15] | hid_spikes[18] | hid_spikes[21] | hid_spikes[22] | hid_spikes[23] | hid_spikes[27] | hid_spikes[41] | hid_spikes[43]) << 0)
        + ((hid_spikes[4] | hid_spikes[15] | hid_spikes[21] | hid_spikes[22] | hid_spikes[23] | hid_spikes[41] | hid_spikes[43] | hid_spikes[56] | hid_spikes[57]) << 1)
        + ((hid_spikes[4] | hid_spikes[11] | hid_spikes[15] | hid_spikes[35] | hid_spikes[41] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60]) << 2)
        + ((hid_spikes[4] | hid_spikes[18] | hid_spikes[21] | hid_spikes[22] | hid_spikes[27] | hid_spikes[35]) << 3);
    wire signed [11:0] neg_in_6 = ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 5)
        + ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[1]) << 3)
        + ((hid_spikes[1] | hid_spikes[3] | hid_spikes[6] | hid_spikes[8] | hid_spikes[10] | hid_spikes[26] | hid_spikes[29] | hid_spikes[33] | hid_spikes[37] | hid_spikes[51] | hid_spikes[53] | hid_spikes[61]) << 0)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[3] | hid_spikes[6] | hid_spikes[7] | hid_spikes[17] | hid_spikes[24] | hid_spikes[25] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[37] | hid_spikes[38] | hid_spikes[45] | hid_spikes[49] | hid_spikes[50] | hid_spikes[51] | hid_spikes[52] | hid_spikes[61]) << 1)
        + ((hid_spikes[0] | hid_spikes[2] | hid_spikes[8] | hid_spikes[10] | hid_spikes[12] | hid_spikes[17] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[29] | hid_spikes[33] | hid_spikes[44] | hid_spikes[45] | hid_spikes[48] | hid_spikes[50] | hid_spikes[51] | hid_spikes[59] | hid_spikes[61] | hid_spikes[62]) << 2)
        + ((hid_spikes[8] | hid_spikes[16] | hid_spikes[29] | hid_spikes[33] | hid_spikes[45] | hid_spikes[52] | hid_spikes[55]) << 3)
        + ((hid_spikes[5] | hid_spikes[14] | hid_spikes[53]) << 4)
        + ((hid_spikes[19]) << 5);
    wire signed [11:0] sum_hid_6 = pos_in_6 - neg_in_6;
    assign hid_spikes[6] = (mem_hid_6 >= 10);
    wire signed [11:0] next_hid_6 = mem_hid_6 - (mem_hid_6 >>> 6) + sum_hid_6;

    reg signed [11:0] mem_hid_7;
    wire signed [11:0] pos_in_7 = ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 2)
        + ((hid_spikes[11] | hid_spikes[15] | hid_spikes[19] | hid_spikes[20] | hid_spikes[23] | hid_spikes[46] | hid_spikes[60]) << 0)
        + ((hid_spikes[20] | hid_spikes[23] | hid_spikes[39] | hid_spikes[60]) << 1)
        + ((hid_spikes[19] | hid_spikes[34] | hid_spikes[46] | hid_spikes[59]) << 2)
        + ((hid_spikes[4] | hid_spikes[11] | hid_spikes[15] | hid_spikes[31] | hid_spikes[38] | hid_spikes[44] | hid_spikes[46]) << 3);
    wire signed [11:0] neg_in_7 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[1]) << 5)
        + ((cochlea_spikes[4]) << 7)
        + ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[0] | cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2]) << 5)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[2] | hid_spikes[3] | hid_spikes[5] | hid_spikes[8] | hid_spikes[10] | hid_spikes[12] | hid_spikes[13] | hid_spikes[21] | hid_spikes[22] | hid_spikes[24] | hid_spikes[26] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[42] | hid_spikes[43] | hid_spikes[48] | hid_spikes[52] | hid_spikes[54] | hid_spikes[57] | hid_spikes[58]) << 0)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[2] | hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[9] | hid_spikes[12] | hid_spikes[13] | hid_spikes[17] | hid_spikes[18] | hid_spikes[21] | hid_spikes[22] | hid_spikes[24] | hid_spikes[26] | hid_spikes[28] | hid_spikes[30] | hid_spikes[32] | hid_spikes[33] | hid_spikes[40] | hid_spikes[41] | hid_spikes[47] | hid_spikes[49] | hid_spikes[52] | hid_spikes[54] | hid_spikes[57] | hid_spikes[58]) << 1)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[3] | hid_spikes[8] | hid_spikes[12] | hid_spikes[13] | hid_spikes[21] | hid_spikes[22] | hid_spikes[24] | hid_spikes[29] | hid_spikes[30] | hid_spikes[36] | hid_spikes[47] | hid_spikes[48] | hid_spikes[51] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[58] | hid_spikes[62] | hid_spikes[63]) << 2)
        + ((hid_spikes[6] | hid_spikes[8] | hid_spikes[10] | hid_spikes[12] | hid_spikes[21] | hid_spikes[26] | hid_spikes[28] | hid_spikes[32] | hid_spikes[41] | hid_spikes[42] | hid_spikes[43] | hid_spikes[48] | hid_spikes[51] | hid_spikes[58] | hid_spikes[61] | hid_spikes[62]) << 3)
        + ((hid_spikes[55]) << 4);
    wire signed [11:0] sum_hid_7 = pos_in_7 - neg_in_7;
    assign hid_spikes[7] = (mem_hid_7 >= 10);
    wire signed [11:0] next_hid_7 = mem_hid_7 - (mem_hid_7 >>> 6) + sum_hid_7;

    reg signed [11:0] mem_hid_8;
    wire signed [11:0] pos_in_8 = ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((hid_spikes[2] | hid_spikes[4] | hid_spikes[9] | hid_spikes[17] | hid_spikes[28] | hid_spikes[52] | hid_spikes[61]) << 0)
        + ((hid_spikes[4] | hid_spikes[9] | hid_spikes[15] | hid_spikes[17] | hid_spikes[22] | hid_spikes[26] | hid_spikes[28] | hid_spikes[37] | hid_spikes[46] | hid_spikes[47] | hid_spikes[50] | hid_spikes[52] | hid_spikes[56] | hid_spikes[60]) << 1)
        + ((hid_spikes[2] | hid_spikes[13] | hid_spikes[22] | hid_spikes[23] | hid_spikes[26] | hid_spikes[36] | hid_spikes[51] | hid_spikes[56] | hid_spikes[60] | hid_spikes[61] | hid_spikes[63]) << 2)
        + ((hid_spikes[8] | hid_spikes[22] | hid_spikes[32] | hid_spikes[34] | hid_spikes[51] | hid_spikes[59]) << 3)
        + ((hid_spikes[4]) << 4);
    wire signed [11:0] neg_in_8 = ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[3]) << 2)
        + ((hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[16] | hid_spikes[19] | hid_spikes[21] | hid_spikes[24] | hid_spikes[25] | hid_spikes[31] | hid_spikes[33] | hid_spikes[39] | hid_spikes[49] | hid_spikes[53]) << 0)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[6] | hid_spikes[7] | hid_spikes[10] | hid_spikes[14] | hid_spikes[20] | hid_spikes[25] | hid_spikes[31] | hid_spikes[33] | hid_spikes[43] | hid_spikes[44] | hid_spikes[53] | hid_spikes[55] | hid_spikes[57] | hid_spikes[58]) << 1)
        + ((hid_spikes[1] | hid_spikes[3] | hid_spikes[6] | hid_spikes[12] | hid_spikes[14] | hid_spikes[16] | hid_spikes[18] | hid_spikes[19] | hid_spikes[24] | hid_spikes[35] | hid_spikes[45] | hid_spikes[49] | hid_spikes[58]) << 2)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[6] | hid_spikes[7] | hid_spikes[10] | hid_spikes[11] | hid_spikes[14] | hid_spikes[16] | hid_spikes[18] | hid_spikes[19] | hid_spikes[25] | hid_spikes[29] | hid_spikes[38] | hid_spikes[39] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[49]) << 3)
        + ((hid_spikes[5] | hid_spikes[21] | hid_spikes[35] | hid_spikes[45] | hid_spikes[55]) << 4);
    wire signed [11:0] sum_hid_8 = pos_in_8 - neg_in_8;
    assign hid_spikes[8] = (mem_hid_8 >= 10);
    wire signed [11:0] next_hid_8 = mem_hid_8 - (mem_hid_8 >>> 6) + sum_hid_8;

    reg signed [11:0] mem_hid_9;
    wire signed [11:0] pos_in_9 = ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 4)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[4] | hid_spikes[6] | hid_spikes[11] | hid_spikes[12] | hid_spikes[20] | hid_spikes[22] | hid_spikes[29] | hid_spikes[37] | hid_spikes[38] | hid_spikes[59]) << 0)
        + ((hid_spikes[3] | hid_spikes[4] | hid_spikes[10] | hid_spikes[12] | hid_spikes[17] | hid_spikes[22] | hid_spikes[24] | hid_spikes[29] | hid_spikes[37] | hid_spikes[38] | hid_spikes[40] | hid_spikes[42] | hid_spikes[49] | hid_spikes[52] | hid_spikes[56]) << 1)
        + ((hid_spikes[10] | hid_spikes[12] | hid_spikes[20] | hid_spikes[22] | hid_spikes[23] | hid_spikes[26] | hid_spikes[37] | hid_spikes[40] | hid_spikes[43] | hid_spikes[51] | hid_spikes[58] | hid_spikes[59]) << 2)
        + ((hid_spikes[2] | hid_spikes[4] | hid_spikes[6] | hid_spikes[10] | hid_spikes[11] | hid_spikes[32] | hid_spikes[38] | hid_spikes[40] | hid_spikes[45] | hid_spikes[51] | hid_spikes[56] | hid_spikes[58] | hid_spikes[59] | hid_spikes[62]) << 3)
        + ((hid_spikes[22] | hid_spikes[49]) << 4);
    wire signed [11:0] neg_in_9 = ((cochlea_spikes[0] | cochlea_spikes[2] | cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[0] | cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[4]) << 6)
        + ((cochlea_spikes[1] | cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[1] | cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[1]) << 5)
        + ((hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[30] | hid_spikes[36] | hid_spikes[46] | hid_spikes[47] | hid_spikes[54] | hid_spikes[57] | hid_spikes[60]) << 0)
        + ((hid_spikes[8] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[30] | hid_spikes[36] | hid_spikes[41] | hid_spikes[44] | hid_spikes[50] | hid_spikes[54] | hid_spikes[55] | hid_spikes[57] | hid_spikes[61] | hid_spikes[63]) << 1)
        + ((hid_spikes[1] | hid_spikes[5] | hid_spikes[9] | hid_spikes[13] | hid_spikes[19] | hid_spikes[25] | hid_spikes[41] | hid_spikes[44] | hid_spikes[46] | hid_spikes[47] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55]) << 2)
        + ((hid_spikes[8] | hid_spikes[13] | hid_spikes[16] | hid_spikes[19] | hid_spikes[25] | hid_spikes[28] | hid_spikes[30] | hid_spikes[41] | hid_spikes[44] | hid_spikes[60] | hid_spikes[61] | hid_spikes[63]) << 3)
        + ((hid_spikes[0]) << 4);
    wire signed [11:0] sum_hid_9 = pos_in_9 - neg_in_9;
    assign hid_spikes[9] = (mem_hid_9 >= 10);
    wire signed [11:0] next_hid_9 = mem_hid_9 - (mem_hid_9 >>> 6) + sum_hid_9;

    reg signed [11:0] mem_hid_10;
    wire signed [11:0] pos_in_10 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[1]) << 6)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[5]) << 5)
        + ((hid_spikes[3] | hid_spikes[7] | hid_spikes[11] | hid_spikes[16] | hid_spikes[18] | hid_spikes[22] | hid_spikes[40] | hid_spikes[42] | hid_spikes[47] | hid_spikes[49] | hid_spikes[61]) << 0)
        + ((hid_spikes[3] | hid_spikes[4] | hid_spikes[10] | hid_spikes[11] | hid_spikes[19] | hid_spikes[20] | hid_spikes[24] | hid_spikes[30] | hid_spikes[35] | hid_spikes[40] | hid_spikes[42] | hid_spikes[46] | hid_spikes[47] | hid_spikes[57] | hid_spikes[58] | hid_spikes[61]) << 1)
        + ((hid_spikes[4] | hid_spikes[10] | hid_spikes[11] | hid_spikes[16] | hid_spikes[19] | hid_spikes[22] | hid_spikes[30] | hid_spikes[38] | hid_spikes[40] | hid_spikes[42] | hid_spikes[47] | hid_spikes[49] | hid_spikes[57]) << 2)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[7] | hid_spikes[11] | hid_spikes[38]) << 3)
        + ((hid_spikes[18] | hid_spikes[22]) << 4);
    wire signed [11:0] neg_in_10 = ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[3] | cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[3] | cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[3]) << 6)
        + ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[0]) << 5)
        + ((hid_spikes[6] | hid_spikes[8] | hid_spikes[12] | hid_spikes[23] | hid_spikes[26] | hid_spikes[29] | hid_spikes[37] | hid_spikes[41] | hid_spikes[48] | hid_spikes[50] | hid_spikes[54] | hid_spikes[60] | hid_spikes[62]) << 0)
        + ((hid_spikes[5] | hid_spikes[6] | hid_spikes[12] | hid_spikes[17] | hid_spikes[23] | hid_spikes[26] | hid_spikes[28] | hid_spikes[29] | hid_spikes[31] | hid_spikes[32] | hid_spikes[36] | hid_spikes[39] | hid_spikes[43] | hid_spikes[44] | hid_spikes[48] | hid_spikes[50] | hid_spikes[51] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[62]) << 1)
        + ((hid_spikes[12] | hid_spikes[27] | hid_spikes[28] | hid_spikes[36] | hid_spikes[41] | hid_spikes[48] | hid_spikes[55] | hid_spikes[59] | hid_spikes[60] | hid_spikes[62]) << 2)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[5] | hid_spikes[8] | hid_spikes[23] | hid_spikes[27] | hid_spikes[29] | hid_spikes[31] | hid_spikes[37] | hid_spikes[51] | hid_spikes[54] | hid_spikes[62]) << 3);
    wire signed [11:0] sum_hid_10 = pos_in_10 - neg_in_10;
    assign hid_spikes[10] = (mem_hid_10 >= 10);
    wire signed [11:0] next_hid_10 = mem_hid_10 - (mem_hid_10 >>> 3) + sum_hid_10;

    reg signed [11:0] mem_hid_11;
    wire signed [11:0] pos_in_11 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[4]) << 5)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 3)
        + ((hid_spikes[0] | hid_spikes[5] | hid_spikes[20] | hid_spikes[28] | hid_spikes[32] | hid_spikes[35] | hid_spikes[38] | hid_spikes[39]) << 0)
        + ((hid_spikes[5] | hid_spikes[23] | hid_spikes[24] | hid_spikes[26] | hid_spikes[31] | hid_spikes[34] | hid_spikes[38]) << 1)
        + ((hid_spikes[22] | hid_spikes[23] | hid_spikes[28] | hid_spikes[35] | hid_spikes[38] | hid_spikes[39] | hid_spikes[47] | hid_spikes[56]) << 2)
        + ((hid_spikes[0] | hid_spikes[4] | hid_spikes[26] | hid_spikes[32] | hid_spikes[34] | hid_spikes[35] | hid_spikes[39] | hid_spikes[40] | hid_spikes[48]) << 3)
        + ((hid_spikes[10] | hid_spikes[20]) << 4);
    wire signed [11:0] neg_in_11 = ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[3] | cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[3] | cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((hid_spikes[2] | hid_spikes[9] | hid_spikes[14] | hid_spikes[17] | hid_spikes[19] | hid_spikes[21] | hid_spikes[37] | hid_spikes[42] | hid_spikes[44] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[58] | hid_spikes[62]) << 0)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[9] | hid_spikes[14] | hid_spikes[15] | hid_spikes[17] | hid_spikes[19] | hid_spikes[21] | hid_spikes[33] | hid_spikes[36] | hid_spikes[44] | hid_spikes[45] | hid_spikes[49] | hid_spikes[53] | hid_spikes[54] | hid_spikes[58] | hid_spikes[59] | hid_spikes[60] | hid_spikes[62]) << 1)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[8] | hid_spikes[11] | hid_spikes[25] | hid_spikes[29] | hid_spikes[33] | hid_spikes[42] | hid_spikes[45] | hid_spikes[46] | hid_spikes[49] | hid_spikes[50] | hid_spikes[52] | hid_spikes[58] | hid_spikes[59]) << 2)
        + ((hid_spikes[8] | hid_spikes[9] | hid_spikes[11] | hid_spikes[25] | hid_spikes[36] | hid_spikes[42] | hid_spikes[43] | hid_spikes[49] | hid_spikes[52] | hid_spikes[55] | hid_spikes[63]) << 3)
        + ((hid_spikes[14] | hid_spikes[37] | hid_spikes[61]) << 4);
    wire signed [11:0] sum_hid_11 = pos_in_11 - neg_in_11;
    assign hid_spikes[11] = (mem_hid_11 >= 10);
    wire signed [11:0] next_hid_11 = mem_hid_11 - (mem_hid_11 >>> 3) + sum_hid_11;

    reg signed [11:0] mem_hid_12;
    wire signed [11:0] pos_in_12 = ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2] | cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[2] | cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[1] | cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 4)
        + ((hid_spikes[6] | hid_spikes[7] | hid_spikes[16] | hid_spikes[18] | hid_spikes[20] | hid_spikes[22] | hid_spikes[25] | hid_spikes[27] | hid_spikes[38] | hid_spikes[53] | hid_spikes[59] | hid_spikes[60]) << 0)
        + ((hid_spikes[6] | hid_spikes[15] | hid_spikes[16] | hid_spikes[22] | hid_spikes[34] | hid_spikes[35] | hid_spikes[38] | hid_spikes[44] | hid_spikes[53] | hid_spikes[59] | hid_spikes[60] | hid_spikes[63]) << 1)
        + ((hid_spikes[4] | hid_spikes[6] | hid_spikes[15] | hid_spikes[18] | hid_spikes[25] | hid_spikes[27] | hid_spikes[34] | hid_spikes[35] | hid_spikes[38] | hid_spikes[40] | hid_spikes[53] | hid_spikes[63]) << 2)
        + ((hid_spikes[7] | hid_spikes[15] | hid_spikes[20] | hid_spikes[22] | hid_spikes[25] | hid_spikes[32] | hid_spikes[38]) << 3)
        + ((hid_spikes[22] | hid_spikes[44]) << 4);
    wire signed [11:0] neg_in_12 = ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[3]) << 5)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[0]) << 4)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[8] | hid_spikes[19] | hid_spikes[31] | hid_spikes[33] | hid_spikes[45] | hid_spikes[47] | hid_spikes[51] | hid_spikes[58] | hid_spikes[61] | hid_spikes[62]) << 0)
        + ((hid_spikes[13] | hid_spikes[14] | hid_spikes[19] | hid_spikes[23] | hid_spikes[24] | hid_spikes[26] | hid_spikes[31] | hid_spikes[33] | hid_spikes[36] | hid_spikes[42] | hid_spikes[43] | hid_spikes[54] | hid_spikes[57] | hid_spikes[58]) << 1)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[2] | hid_spikes[10] | hid_spikes[14] | hid_spikes[19] | hid_spikes[23] | hid_spikes[24] | hid_spikes[30] | hid_spikes[31] | hid_spikes[33] | hid_spikes[36] | hid_spikes[37] | hid_spikes[45] | hid_spikes[49] | hid_spikes[51] | hid_spikes[54] | hid_spikes[57] | hid_spikes[62]) << 2)
        + ((hid_spikes[8] | hid_spikes[11] | hid_spikes[14] | hid_spikes[17] | hid_spikes[19] | hid_spikes[37] | hid_spikes[42] | hid_spikes[47] | hid_spikes[49] | hid_spikes[50] | hid_spikes[51] | hid_spikes[58] | hid_spikes[62]) << 3)
        + ((hid_spikes[45] | hid_spikes[61]) << 4);
    wire signed [11:0] sum_hid_12 = pos_in_12 - neg_in_12;
    assign hid_spikes[12] = (mem_hid_12 >= 10);
    wire signed [11:0] next_hid_12 = mem_hid_12 - (mem_hid_12 >>> 3) + sum_hid_12;

    reg signed [11:0] mem_hid_13;
    wire signed [11:0] pos_in_13 = ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 4)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 3)
        + ((hid_spikes[36] | hid_spikes[41] | hid_spikes[42] | hid_spikes[55] | hid_spikes[60] | hid_spikes[62]) << 0)
        + ((hid_spikes[5] | hid_spikes[35] | hid_spikes[36] | hid_spikes[52] | hid_spikes[55] | hid_spikes[62]) << 1)
        + ((hid_spikes[4] | hid_spikes[15] | hid_spikes[20] | hid_spikes[28] | hid_spikes[32] | hid_spikes[41] | hid_spikes[42] | hid_spikes[50] | hid_spikes[62]) << 2)
        + ((hid_spikes[2] | hid_spikes[15] | hid_spikes[32] | hid_spikes[35] | hid_spikes[39] | hid_spikes[55] | hid_spikes[56] | hid_spikes[60]) << 3);
    wire signed [11:0] neg_in_13 = ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[4]) << 6)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((hid_spikes[1] | hid_spikes[3] | hid_spikes[7] | hid_spikes[8] | hid_spikes[13] | hid_spikes[22] | hid_spikes[23] | hid_spikes[27] | hid_spikes[30] | hid_spikes[34] | hid_spikes[44] | hid_spikes[45] | hid_spikes[48] | hid_spikes[49] | hid_spikes[54] | hid_spikes[63]) << 0)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[3] | hid_spikes[7] | hid_spikes[8] | hid_spikes[11] | hid_spikes[14] | hid_spikes[16] | hid_spikes[18] | hid_spikes[19] | hid_spikes[23] | hid_spikes[25] | hid_spikes[26] | hid_spikes[27] | hid_spikes[29] | hid_spikes[30] | hid_spikes[40] | hid_spikes[44] | hid_spikes[45] | hid_spikes[47] | hid_spikes[51] | hid_spikes[59]) << 1)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[8] | hid_spikes[13] | hid_spikes[16] | hid_spikes[21] | hid_spikes[24] | hid_spikes[34] | hid_spikes[38] | hid_spikes[44] | hid_spikes[46] | hid_spikes[48] | hid_spikes[49] | hid_spikes[54] | hid_spikes[63]) << 2)
        + ((hid_spikes[13] | hid_spikes[19] | hid_spikes[22] | hid_spikes[37] | hid_spikes[44] | hid_spikes[46] | hid_spikes[48] | hid_spikes[49] | hid_spikes[58]) << 3)
        + ((hid_spikes[1] | hid_spikes[14] | hid_spikes[26]) << 4);
    wire signed [11:0] sum_hid_13 = pos_in_13 - neg_in_13;
    assign hid_spikes[13] = (mem_hid_13 >= 10);
    wire signed [11:0] next_hid_13 = mem_hid_13 - (mem_hid_13 >>> 5) + sum_hid_13;

    reg signed [11:0] mem_hid_14;
    wire signed [11:0] pos_in_14 = ((hid_spikes[1] | hid_spikes[8] | hid_spikes[11] | hid_spikes[31] | hid_spikes[34] | hid_spikes[39] | hid_spikes[45]) << 0)
        + ((hid_spikes[11] | hid_spikes[14] | hid_spikes[29] | hid_spikes[33] | hid_spikes[45] | hid_spikes[48]) << 1)
        + ((hid_spikes[1] | hid_spikes[8] | hid_spikes[11] | hid_spikes[13] | hid_spikes[14] | hid_spikes[29] | hid_spikes[30] | hid_spikes[33] | hid_spikes[34] | hid_spikes[39]) << 2)
        + ((hid_spikes[31]) << 3);
    wire signed [11:0] neg_in_14 = ((hid_spikes[3] | hid_spikes[5] | hid_spikes[17] | hid_spikes[32] | hid_spikes[43] | hid_spikes[52] | hid_spikes[56] | hid_spikes[58]) << 0)
        + ((hid_spikes[3] | hid_spikes[5] | hid_spikes[12] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[22] | hid_spikes[24] | hid_spikes[32] | hid_spikes[38] | hid_spikes[52] | hid_spikes[56] | hid_spikes[63]) << 1)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[7] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[22] | hid_spikes[23] | hid_spikes[24] | hid_spikes[28] | hid_spikes[35] | hid_spikes[36] | hid_spikes[38] | hid_spikes[41] | hid_spikes[43] | hid_spikes[56] | hid_spikes[58] | hid_spikes[63]) << 2)
        + ((hid_spikes[2] | hid_spikes[7] | hid_spikes[12] | hid_spikes[15] | hid_spikes[16] | hid_spikes[17] | hid_spikes[22] | hid_spikes[23] | hid_spikes[24] | hid_spikes[26] | hid_spikes[32] | hid_spikes[38]) << 3)
        + ((hid_spikes[41] | hid_spikes[43] | hid_spikes[50]) << 4);
    wire signed [11:0] sum_hid_14 = pos_in_14 - neg_in_14;
    assign hid_spikes[14] = (mem_hid_14 >= 10);
    wire signed [11:0] next_hid_14 = mem_hid_14 - (mem_hid_14 >>> 4) + sum_hid_14;

    reg signed [11:0] mem_hid_15;
    wire signed [11:0] pos_in_15 = ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 5)
        + ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 3)
        + ((hid_spikes[3] | hid_spikes[22] | hid_spikes[24] | hid_spikes[31] | hid_spikes[50] | hid_spikes[56]) << 0)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[22] | hid_spikes[25] | hid_spikes[31] | hid_spikes[56] | hid_spikes[58]) << 1)
        + ((hid_spikes[7] | hid_spikes[18] | hid_spikes[20] | hid_spikes[24] | hid_spikes[31] | hid_spikes[32] | hid_spikes[40] | hid_spikes[50]) << 2)
        + ((hid_spikes[3] | hid_spikes[4] | hid_spikes[12] | hid_spikes[20] | hid_spikes[22] | hid_spikes[23] | hid_spikes[25] | hid_spikes[32] | hid_spikes[40] | hid_spikes[46]) << 3)
        + ((hid_spikes[17]) << 4);
    wire signed [11:0] neg_in_15 = ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[3] | cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[3] | cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[1]) << 3)
        + ((hid_spikes[1] | hid_spikes[8] | hid_spikes[11] | hid_spikes[15] | hid_spikes[16] | hid_spikes[21] | hid_spikes[27] | hid_spikes[29] | hid_spikes[33] | hid_spikes[34] | hid_spikes[36] | hid_spikes[37] | hid_spikes[41] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[51] | hid_spikes[57] | hid_spikes[63]) << 0)
        + ((hid_spikes[1] | hid_spikes[5] | hid_spikes[6] | hid_spikes[21] | hid_spikes[27] | hid_spikes[28] | hid_spikes[33] | hid_spikes[34] | hid_spikes[37] | hid_spikes[41] | hid_spikes[43] | hid_spikes[44] | hid_spikes[47] | hid_spikes[49]) << 1)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[11] | hid_spikes[21] | hid_spikes[30] | hid_spikes[36] | hid_spikes[37] | hid_spikes[41] | hid_spikes[45] | hid_spikes[48] | hid_spikes[49] | hid_spikes[63]) << 2)
        + ((hid_spikes[1] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[28] | hid_spikes[29] | hid_spikes[37] | hid_spikes[41] | hid_spikes[48] | hid_spikes[51] | hid_spikes[53] | hid_spikes[57] | hid_spikes[63]) << 3)
        + ((hid_spikes[8] | hid_spikes[33]) << 4);
    wire signed [11:0] sum_hid_15 = pos_in_15 - neg_in_15;
    assign hid_spikes[15] = (mem_hid_15 >= 10);
    wire signed [11:0] next_hid_15 = mem_hid_15 - (mem_hid_15 >>> 3) + sum_hid_15;

    reg signed [11:0] mem_hid_16;
    wire signed [11:0] pos_in_16 = ((hid_spikes[2] | hid_spikes[12] | hid_spikes[18] | hid_spikes[22] | hid_spikes[26] | hid_spikes[33] | hid_spikes[36] | hid_spikes[38] | hid_spikes[46] | hid_spikes[54] | hid_spikes[60] | hid_spikes[61]) << 0)
        + ((hid_spikes[2] | hid_spikes[10] | hid_spikes[12] | hid_spikes[21] | hid_spikes[22] | hid_spikes[25] | hid_spikes[33] | hid_spikes[34] | hid_spikes[36] | hid_spikes[38] | hid_spikes[51] | hid_spikes[56] | hid_spikes[60]) << 1)
        + ((hid_spikes[18] | hid_spikes[25] | hid_spikes[34] | hid_spikes[38] | hid_spikes[50] | hid_spikes[51] | hid_spikes[54] | hid_spikes[56] | hid_spikes[61]) << 2)
        + ((hid_spikes[7] | hid_spikes[12] | hid_spikes[22] | hid_spikes[34] | hid_spikes[46] | hid_spikes[50] | hid_spikes[61]) << 3)
        + ((hid_spikes[26] | hid_spikes[34] | hid_spikes[36]) << 4);
    wire signed [11:0] neg_in_16 = ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[2]) << 5)
        + ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[1]) << 4)
        + ((hid_spikes[0] | hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[9] | hid_spikes[14] | hid_spikes[16] | hid_spikes[17] | hid_spikes[24] | hid_spikes[28] | hid_spikes[31] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[47] | hid_spikes[49] | hid_spikes[52] | hid_spikes[53] | hid_spikes[55] | hid_spikes[58]) << 0)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[5] | hid_spikes[8] | hid_spikes[27] | hid_spikes[28] | hid_spikes[39] | hid_spikes[40] | hid_spikes[41] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[52] | hid_spikes[58]) << 1)
        + ((hid_spikes[1] | hid_spikes[8] | hid_spikes[14] | hid_spikes[16] | hid_spikes[37] | hid_spikes[40] | hid_spikes[44] | hid_spikes[47] | hid_spikes[49] | hid_spikes[52] | hid_spikes[53] | hid_spikes[55] | hid_spikes[57] | hid_spikes[59]) << 2)
        + ((hid_spikes[5] | hid_spikes[6] | hid_spikes[9] | hid_spikes[14] | hid_spikes[17] | hid_spikes[24] | hid_spikes[27] | hid_spikes[31] | hid_spikes[40] | hid_spikes[41] | hid_spikes[42] | hid_spikes[49] | hid_spikes[55] | hid_spikes[58]) << 3)
        + ((hid_spikes[8] | hid_spikes[13] | hid_spikes[39] | hid_spikes[52] | hid_spikes[53]) << 4);
    wire signed [11:0] sum_hid_16 = pos_in_16 - neg_in_16;
    assign hid_spikes[16] = (mem_hid_16 >= 10);
    wire signed [11:0] next_hid_16 = mem_hid_16 - (mem_hid_16 >>> 5) + sum_hid_16;

    reg signed [11:0] mem_hid_17;
    wire signed [11:0] pos_in_17 = ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 3)
        + ((hid_spikes[6] | hid_spikes[29] | hid_spikes[38]) << 0)
        + ((hid_spikes[0] | hid_spikes[7] | hid_spikes[16] | hid_spikes[17] | hid_spikes[18] | hid_spikes[20] | hid_spikes[27] | hid_spikes[29] | hid_spikes[34] | hid_spikes[38] | hid_spikes[56] | hid_spikes[58] | hid_spikes[63]) << 1)
        + ((hid_spikes[2] | hid_spikes[5] | hid_spikes[6] | hid_spikes[16] | hid_spikes[18] | hid_spikes[20] | hid_spikes[34] | hid_spikes[38] | hid_spikes[46] | hid_spikes[61]) << 2)
        + ((hid_spikes[22] | hid_spikes[33] | hid_spikes[34] | hid_spikes[38] | hid_spikes[46] | hid_spikes[61]) << 3);
    wire signed [11:0] neg_in_17 = ((cochlea_spikes[1] | cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[1]) << 4)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[5]) << 3)
        + ((hid_spikes[8] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[25] | hid_spikes[45] | hid_spikes[47] | hid_spikes[48] | hid_spikes[55] | hid_spikes[57] | hid_spikes[59]) << 0)
        + ((hid_spikes[14] | hid_spikes[23] | hid_spikes[25] | hid_spikes[26] | hid_spikes[35] | hid_spikes[37] | hid_spikes[41] | hid_spikes[45] | hid_spikes[47] | hid_spikes[49] | hid_spikes[55] | hid_spikes[57] | hid_spikes[59] | hid_spikes[60]) << 1)
        + ((hid_spikes[8] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[21] | hid_spikes[25] | hid_spikes[26] | hid_spikes[45] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[51] | hid_spikes[52] | hid_spikes[57] | hid_spikes[59]) << 2)
        + ((hid_spikes[9] | hid_spikes[12] | hid_spikes[13] | hid_spikes[23] | hid_spikes[25] | hid_spikes[26] | hid_spikes[37] | hid_spikes[42] | hid_spikes[44] | hid_spikes[51] | hid_spikes[53] | hid_spikes[60]) << 3)
        + ((hid_spikes[1] | hid_spikes[45] | hid_spikes[49]) << 4);
    wire signed [11:0] sum_hid_17 = pos_in_17 - neg_in_17;
    assign hid_spikes[17] = (mem_hid_17 >= 10);
    wire signed [11:0] next_hid_17 = mem_hid_17 - (mem_hid_17 >>> 4) + sum_hid_17;

    reg signed [11:0] mem_hid_18;
    wire signed [11:0] pos_in_18 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[1]) << 4)
        + ((cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[3]) << 3)
        + ((hid_spikes[12] | hid_spikes[17] | hid_spikes[21] | hid_spikes[33] | hid_spikes[46] | hid_spikes[49] | hid_spikes[58] | hid_spikes[59]) << 0)
        + ((hid_spikes[3] | hid_spikes[9] | hid_spikes[12] | hid_spikes[15] | hid_spikes[17] | hid_spikes[21] | hid_spikes[38] | hid_spikes[46] | hid_spikes[49] | hid_spikes[58] | hid_spikes[59] | hid_spikes[61]) << 1)
        + ((hid_spikes[9] | hid_spikes[15] | hid_spikes[17] | hid_spikes[21] | hid_spikes[32] | hid_spikes[49] | hid_spikes[58] | hid_spikes[61]) << 2)
        + ((hid_spikes[46] | hid_spikes[57]) << 3)
        + ((hid_spikes[12]) << 4);
    wire signed [11:0] neg_in_18 = ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[4]) << 5)
        + ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2] | cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2] | cochlea_spikes[5]) << 4)
        + ((hid_spikes[2] | hid_spikes[5] | hid_spikes[6] | hid_spikes[11] | hid_spikes[13] | hid_spikes[18] | hid_spikes[22] | hid_spikes[23] | hid_spikes[24] | hid_spikes[35] | hid_spikes[39] | hid_spikes[40] | hid_spikes[44] | hid_spikes[48] | hid_spikes[50] | hid_spikes[51] | hid_spikes[54] | hid_spikes[55] | hid_spikes[62]) << 0)
        + ((hid_spikes[2] | hid_spikes[4] | hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[14] | hid_spikes[18] | hid_spikes[19] | hid_spikes[23] | hid_spikes[24] | hid_spikes[25] | hid_spikes[35] | hid_spikes[40] | hid_spikes[51] | hid_spikes[52] | hid_spikes[53] | hid_spikes[54] | hid_spikes[56] | hid_spikes[63]) << 1)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[4] | hid_spikes[10] | hid_spikes[13] | hid_spikes[16] | hid_spikes[18] | hid_spikes[23] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[29] | hid_spikes[34] | hid_spikes[36] | hid_spikes[42] | hid_spikes[45] | hid_spikes[47] | hid_spikes[48] | hid_spikes[50] | hid_spikes[52]) << 2)
        + ((hid_spikes[5] | hid_spikes[11] | hid_spikes[19] | hid_spikes[22] | hid_spikes[25] | hid_spikes[35] | hid_spikes[39] | hid_spikes[40] | hid_spikes[44] | hid_spikes[45] | hid_spikes[47] | hid_spikes[48] | hid_spikes[50] | hid_spikes[52] | hid_spikes[62]) << 3)
        + ((hid_spikes[4] | hid_spikes[6] | hid_spikes[7] | hid_spikes[14] | hid_spikes[39] | hid_spikes[55]) << 4);
    wire signed [11:0] sum_hid_18 = pos_in_18 - neg_in_18;
    assign hid_spikes[18] = (mem_hid_18 >= 10);
    wire signed [11:0] next_hid_18 = mem_hid_18 - (mem_hid_18 >>> 5) + sum_hid_18;

    reg signed [11:0] mem_hid_19;
    wire signed [11:0] pos_in_19 = ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[1]) << 2)
        + ((hid_spikes[4] | hid_spikes[8] | hid_spikes[19] | hid_spikes[24] | hid_spikes[30] | hid_spikes[34] | hid_spikes[40] | hid_spikes[47] | hid_spikes[59]) << 0)
        + ((hid_spikes[9] | hid_spikes[19] | hid_spikes[24] | hid_spikes[34]) << 1)
        + ((hid_spikes[8] | hid_spikes[30] | hid_spikes[34] | hid_spikes[47]) << 2)
        + ((hid_spikes[2] | hid_spikes[4] | hid_spikes[9] | hid_spikes[21] | hid_spikes[34] | hid_spikes[40] | hid_spikes[59]) << 3);
    wire signed [11:0] neg_in_19 = ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2]) << 6)
        + ((hid_spikes[5] | hid_spikes[6] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[18] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[33] | hid_spikes[36] | hid_spikes[39] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[48] | hid_spikes[49] | hid_spikes[53] | hid_spikes[55] | hid_spikes[56] | hid_spikes[58] | hid_spikes[61] | hid_spikes[62]) << 0)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[6] | hid_spikes[10] | hid_spikes[12] | hid_spikes[13] | hid_spikes[15] | hid_spikes[16] | hid_spikes[18] | hid_spikes[26] | hid_spikes[28] | hid_spikes[31] | hid_spikes[36] | hid_spikes[37] | hid_spikes[45] | hid_spikes[46] | hid_spikes[50] | hid_spikes[51] | hid_spikes[53] | hid_spikes[56] | hid_spikes[61]) << 1)
        + ((hid_spikes[3] | hid_spikes[5] | hid_spikes[16] | hid_spikes[23] | hid_spikes[28] | hid_spikes[31] | hid_spikes[33] | hid_spikes[37] | hid_spikes[41] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[54] | hid_spikes[55] | hid_spikes[57] | hid_spikes[62] | hid_spikes[63]) << 2)
        + ((hid_spikes[3] | hid_spikes[6] | hid_spikes[11] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[17] | hid_spikes[18] | hid_spikes[27] | hid_spikes[36] | hid_spikes[39] | hid_spikes[43] | hid_spikes[45] | hid_spikes[49] | hid_spikes[52] | hid_spikes[53] | hid_spikes[58] | hid_spikes[62]) << 3)
        + ((hid_spikes[1] | hid_spikes[12] | hid_spikes[18] | hid_spikes[23] | hid_spikes[25] | hid_spikes[51]) << 4);
    wire signed [11:0] sum_hid_19 = pos_in_19 - neg_in_19;
    assign hid_spikes[19] = (mem_hid_19 >= 10);
    wire signed [11:0] next_hid_19 = mem_hid_19 - (mem_hid_19 >>> 5) + sum_hid_19;

    reg signed [11:0] mem_hid_20;
    wire signed [11:0] pos_in_20 = ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[5]) << 6)
        + ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 4)
        + ((hid_spikes[4] | hid_spikes[36] | hid_spikes[50] | hid_spikes[60] | hid_spikes[62]) << 0)
        + ((hid_spikes[22] | hid_spikes[32] | hid_spikes[56] | hid_spikes[60] | hid_spikes[62]) << 1)
        + ((hid_spikes[4] | hid_spikes[32] | hid_spikes[36] | hid_spikes[38] | hid_spikes[42] | hid_spikes[50] | hid_spikes[53]) << 2)
        + ((hid_spikes[22] | hid_spikes[40] | hid_spikes[42] | hid_spikes[59]) << 3);
    wire signed [11:0] neg_in_20 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[1] | cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[2]) << 5)
        + ((cochlea_spikes[1]) << 6)
        + ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[3]) << 4)
        + ((cochlea_spikes[3]) << 5)
        + ((cochlea_spikes[0]) << 6)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[6] | hid_spikes[10] | hid_spikes[12] | hid_spikes[14] | hid_spikes[17] | hid_spikes[18] | hid_spikes[23] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[35] | hid_spikes[37] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[46] | hid_spikes[47] | hid_spikes[49] | hid_spikes[54] | hid_spikes[55] | hid_spikes[57] | hid_spikes[61] | hid_spikes[63]) << 0)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[6] | hid_spikes[9] | hid_spikes[10] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[17] | hid_spikes[18] | hid_spikes[23] | hid_spikes[26] | hid_spikes[29] | hid_spikes[35] | hid_spikes[37] | hid_spikes[41] | hid_spikes[45] | hid_spikes[46] | hid_spikes[51] | hid_spikes[54] | hid_spikes[61] | hid_spikes[63]) << 1)
        + ((hid_spikes[2] | hid_spikes[7] | hid_spikes[9] | hid_spikes[16] | hid_spikes[17] | hid_spikes[19] | hid_spikes[21] | hid_spikes[24] | hid_spikes[29] | hid_spikes[33] | hid_spikes[37] | hid_spikes[39] | hid_spikes[43] | hid_spikes[44] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[54] | hid_spikes[55] | hid_spikes[57] | hid_spikes[58] | hid_spikes[61] | hid_spikes[63]) << 2)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[3] | hid_spikes[8] | hid_spikes[9] | hid_spikes[12] | hid_spikes[17] | hid_spikes[28] | hid_spikes[39] | hid_spikes[41] | hid_spikes[43] | hid_spikes[44] | hid_spikes[46] | hid_spikes[48] | hid_spikes[51] | hid_spikes[52] | hid_spikes[57]) << 3)
        + ((hid_spikes[13] | hid_spikes[14] | hid_spikes[24] | hid_spikes[30] | hid_spikes[57]) << 4);
    wire signed [11:0] sum_hid_20 = pos_in_20 - neg_in_20;
    assign hid_spikes[20] = (mem_hid_20 >= 10);
    wire signed [11:0] next_hid_20 = mem_hid_20 - (mem_hid_20 >>> 5) + sum_hid_20;

    reg signed [11:0] mem_hid_21;
    wire signed [11:0] pos_in_21 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 4)
        + ((cochlea_spikes[1]) << 5)
        + ((cochlea_spikes[2]) << 3)
        + ((hid_spikes[4] | hid_spikes[21] | hid_spikes[32] | hid_spikes[33] | hid_spikes[34] | hid_spikes[40] | hid_spikes[42] | hid_spikes[46] | hid_spikes[50] | hid_spikes[56] | hid_spikes[63]) << 0)
        + ((hid_spikes[0] | hid_spikes[7] | hid_spikes[32] | hid_spikes[34] | hid_spikes[42] | hid_spikes[46] | hid_spikes[50] | hid_spikes[56] | hid_spikes[63]) << 1)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[21] | hid_spikes[40] | hid_spikes[42]) << 2)
        + ((hid_spikes[0] | hid_spikes[2] | hid_spikes[3] | hid_spikes[4] | hid_spikes[33] | hid_spikes[35] | hid_spikes[40] | hid_spikes[41] | hid_spikes[42] | hid_spikes[47] | hid_spikes[61] | hid_spikes[63]) << 3)
        + ((hid_spikes[7] | hid_spikes[20] | hid_spikes[32] | hid_spikes[46]) << 4);
    wire signed [11:0] neg_in_21 = ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[4]) << 5)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[3]) << 3)
        + ((cochlea_spikes[3]) << 4)
        + ((hid_spikes[1] | hid_spikes[6] | hid_spikes[12] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[39] | hid_spikes[43] | hid_spikes[48] | hid_spikes[49] | hid_spikes[52] | hid_spikes[53] | hid_spikes[55]) << 0)
        + ((hid_spikes[9] | hid_spikes[10] | hid_spikes[14] | hid_spikes[16] | hid_spikes[18] | hid_spikes[19] | hid_spikes[22] | hid_spikes[26] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[36] | hid_spikes[44] | hid_spikes[49] | hid_spikes[59] | hid_spikes[62]) << 1)
        + ((hid_spikes[1] | hid_spikes[5] | hid_spikes[10] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[23] | hid_spikes[25] | hid_spikes[26] | hid_spikes[30] | hid_spikes[36] | hid_spikes[37] | hid_spikes[39] | hid_spikes[43] | hid_spikes[44] | hid_spikes[49] | hid_spikes[51] | hid_spikes[53] | hid_spikes[54] | hid_spikes[58]) << 2)
        + ((hid_spikes[6] | hid_spikes[12] | hid_spikes[15] | hid_spikes[17] | hid_spikes[24] | hid_spikes[48] | hid_spikes[49] | hid_spikes[52] | hid_spikes[55] | hid_spikes[58] | hid_spikes[59]) << 3)
        + ((hid_spikes[5] | hid_spikes[8] | hid_spikes[9] | hid_spikes[51] | hid_spikes[55]) << 4);
    wire signed [11:0] sum_hid_21 = pos_in_21 - neg_in_21;
    assign hid_spikes[21] = (mem_hid_21 >= 10);
    wire signed [11:0] next_hid_21 = mem_hid_21 - (mem_hid_21 >>> 3) + sum_hid_21;

    reg signed [11:0] mem_hid_22;
    wire signed [11:0] pos_in_22 = ((hid_spikes[3] | hid_spikes[7] | hid_spikes[10] | hid_spikes[20] | hid_spikes[21] | hid_spikes[26] | hid_spikes[27] | hid_spikes[32] | hid_spikes[38] | hid_spikes[39] | hid_spikes[41] | hid_spikes[46] | hid_spikes[56] | hid_spikes[59]) << 0)
        + ((hid_spikes[3] | hid_spikes[7] | hid_spikes[10] | hid_spikes[21] | hid_spikes[25] | hid_spikes[26] | hid_spikes[35] | hid_spikes[39] | hid_spikes[40] | hid_spikes[59]) << 1)
        + ((hid_spikes[7] | hid_spikes[20] | hid_spikes[21] | hid_spikes[22] | hid_spikes[25] | hid_spikes[26] | hid_spikes[27] | hid_spikes[31] | hid_spikes[35] | hid_spikes[40] | hid_spikes[41]) << 2)
        + ((hid_spikes[3] | hid_spikes[7] | hid_spikes[39] | hid_spikes[46] | hid_spikes[56] | hid_spikes[59]) << 3)
        + ((hid_spikes[20] | hid_spikes[32] | hid_spikes[35] | hid_spikes[38] | hid_spikes[39] | hid_spikes[40] | hid_spikes[42]) << 4);
    wire signed [11:0] neg_in_22 = ((cochlea_spikes[3] | cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[3] | cochlea_spikes[4] | cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[3] | cochlea_spikes[4] | cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[3] | cochlea_spikes[5]) << 5)
        + ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0] | cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[1] | cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[0] | cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 4)
        + ((cochlea_spikes[0] | cochlea_spikes[2]) << 5)
        + ((hid_spikes[12] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[18] | hid_spikes[30] | hid_spikes[45] | hid_spikes[47] | hid_spikes[49] | hid_spikes[51] | hid_spikes[60] | hid_spikes[61] | hid_spikes[62]) << 0)
        + ((hid_spikes[4] | hid_spikes[9] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[18] | hid_spikes[28] | hid_spikes[30] | hid_spikes[33] | hid_spikes[45] | hid_spikes[47] | hid_spikes[49] | hid_spikes[51] | hid_spikes[53] | hid_spikes[54] | hid_spikes[58] | hid_spikes[60] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63]) << 1)
        + ((hid_spikes[0] | hid_spikes[2] | hid_spikes[8] | hid_spikes[12] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[45] | hid_spikes[47] | hid_spikes[48] | hid_spikes[51] | hid_spikes[52] | hid_spikes[53] | hid_spikes[58] | hid_spikes[62] | hid_spikes[63]) << 2)
        + ((hid_spikes[2] | hid_spikes[5] | hid_spikes[8] | hid_spikes[12] | hid_spikes[13] | hid_spikes[16] | hid_spikes[18] | hid_spikes[19] | hid_spikes[30] | hid_spikes[37] | hid_spikes[54] | hid_spikes[57] | hid_spikes[61]) << 3)
        + ((hid_spikes[1] | hid_spikes[63]) << 4);
    wire signed [11:0] sum_hid_22 = pos_in_22 - neg_in_22;
    assign hid_spikes[22] = (mem_hid_22 >= 10);
    wire signed [11:0] next_hid_22 = mem_hid_22 - (mem_hid_22 >>> 6) + sum_hid_22;

    reg signed [11:0] mem_hid_23;
    wire signed [11:0] pos_in_23 = ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[1] | cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[1]) << 5)
        + ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[5]) << 4)
        + ((hid_spikes[1] | hid_spikes[4] | hid_spikes[6] | hid_spikes[20] | hid_spikes[22] | hid_spikes[23] | hid_spikes[25] | hid_spikes[31] | hid_spikes[34] | hid_spikes[35] | hid_spikes[47] | hid_spikes[58] | hid_spikes[63]) << 0)
        + ((hid_spikes[1] | hid_spikes[6] | hid_spikes[7] | hid_spikes[22] | hid_spikes[25] | hid_spikes[31] | hid_spikes[33] | hid_spikes[34] | hid_spikes[38] | hid_spikes[40] | hid_spikes[41] | hid_spikes[47] | hid_spikes[50] | hid_spikes[58] | hid_spikes[61]) << 1)
        + ((hid_spikes[4] | hid_spikes[7] | hid_spikes[22] | hid_spikes[23] | hid_spikes[25] | hid_spikes[31] | hid_spikes[41] | hid_spikes[63]) << 2)
        + ((hid_spikes[4] | hid_spikes[20] | hid_spikes[33] | hid_spikes[34] | hid_spikes[35] | hid_spikes[38] | hid_spikes[40] | hid_spikes[47] | hid_spikes[63]) << 3);
    wire signed [11:0] neg_in_23 = ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[0]) << 6)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[3]) << 4)
        + ((hid_spikes[0] | hid_spikes[2] | hid_spikes[5] | hid_spikes[9] | hid_spikes[11] | hid_spikes[14] | hid_spikes[17] | hid_spikes[19] | hid_spikes[24] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[52] | hid_spikes[53] | hid_spikes[57] | hid_spikes[59]) << 0)
        + ((hid_spikes[0] | hid_spikes[2] | hid_spikes[3] | hid_spikes[8] | hid_spikes[11] | hid_spikes[14] | hid_spikes[16] | hid_spikes[19] | hid_spikes[24] | hid_spikes[28] | hid_spikes[30] | hid_spikes[37] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[48] | hid_spikes[49] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[62]) << 1)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[5] | hid_spikes[9] | hid_spikes[11] | hid_spikes[17] | hid_spikes[18] | hid_spikes[24] | hid_spikes[27] | hid_spikes[32] | hid_spikes[46] | hid_spikes[52] | hid_spikes[53] | hid_spikes[55] | hid_spikes[57] | hid_spikes[62]) << 2)
        + ((hid_spikes[8] | hid_spikes[10] | hid_spikes[14] | hid_spikes[16] | hid_spikes[17] | hid_spikes[19] | hid_spikes[29] | hid_spikes[30] | hid_spikes[44] | hid_spikes[48] | hid_spikes[52] | hid_spikes[54] | hid_spikes[59]) << 3)
        + ((hid_spikes[29] | hid_spikes[49] | hid_spikes[53]) << 4);
    wire signed [11:0] sum_hid_23 = pos_in_23 - neg_in_23;
    assign hid_spikes[23] = (mem_hid_23 >= 10);
    wire signed [11:0] next_hid_23 = mem_hid_23 - (mem_hid_23 >>> 3) + sum_hid_23;

    reg signed [11:0] mem_hid_24;
    wire signed [11:0] pos_in_24 = ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0] | cochlea_spikes[1]) << 3)
        + ((hid_spikes[13] | hid_spikes[16] | hid_spikes[17] | hid_spikes[32] | hid_spikes[34] | hid_spikes[38] | hid_spikes[39] | hid_spikes[44] | hid_spikes[50] | hid_spikes[52] | hid_spikes[57] | hid_spikes[63]) << 0)
        + ((hid_spikes[4] | hid_spikes[7] | hid_spikes[8] | hid_spikes[13] | hid_spikes[16] | hid_spikes[17] | hid_spikes[22] | hid_spikes[34] | hid_spikes[46] | hid_spikes[49] | hid_spikes[52] | hid_spikes[57] | hid_spikes[63]) << 1)
        + ((hid_spikes[13] | hid_spikes[17] | hid_spikes[20] | hid_spikes[44] | hid_spikes[50] | hid_spikes[57] | hid_spikes[63]) << 2)
        + ((hid_spikes[17] | hid_spikes[22] | hid_spikes[32] | hid_spikes[37] | hid_spikes[38] | hid_spikes[39] | hid_spikes[44] | hid_spikes[46]) << 3)
        + ((hid_spikes[7]) << 4);
    wire signed [11:0] neg_in_24 = ((cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3] | cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[3] | cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[5]) << 5)
        + ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 5)
        + ((hid_spikes[0] | hid_spikes[2] | hid_spikes[3] | hid_spikes[9] | hid_spikes[11] | hid_spikes[15] | hid_spikes[18] | hid_spikes[19] | hid_spikes[21] | hid_spikes[23] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[35] | hid_spikes[43] | hid_spikes[45] | hid_spikes[56] | hid_spikes[61]) << 0)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[5] | hid_spikes[10] | hid_spikes[12] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[21] | hid_spikes[24] | hid_spikes[26] | hid_spikes[27] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[35] | hid_spikes[43] | hid_spikes[45] | hid_spikes[48] | hid_spikes[51] | hid_spikes[55] | hid_spikes[60]) << 1)
        + ((hid_spikes[0] | hid_spikes[2] | hid_spikes[3] | hid_spikes[6] | hid_spikes[10] | hid_spikes[11] | hid_spikes[12] | hid_spikes[18] | hid_spikes[19] | hid_spikes[21] | hid_spikes[25] | hid_spikes[26] | hid_spikes[28] | hid_spikes[31] | hid_spikes[43] | hid_spikes[45] | hid_spikes[47] | hid_spikes[48] | hid_spikes[54] | hid_spikes[55] | hid_spikes[56] | hid_spikes[58] | hid_spikes[61]) << 2)
        + ((hid_spikes[0] | hid_spikes[9] | hid_spikes[11] | hid_spikes[23] | hid_spikes[24] | hid_spikes[26] | hid_spikes[28] | hid_spikes[31] | hid_spikes[47] | hid_spikes[53] | hid_spikes[59]) << 3)
        + ((hid_spikes[43]) << 4);
    wire signed [11:0] sum_hid_24 = pos_in_24 - neg_in_24;
    assign hid_spikes[24] = (mem_hid_24 >= 10);
    wire signed [11:0] next_hid_24 = mem_hid_24 - (mem_hid_24 >>> 3) + sum_hid_24;

    reg signed [11:0] mem_hid_25;
    wire signed [11:0] pos_in_25 = ((cochlea_spikes[0] | cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 5)
        + ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[5]) << 4)
        + ((hid_spikes[4] | hid_spikes[7] | hid_spikes[8] | hid_spikes[22] | hid_spikes[28] | hid_spikes[44] | hid_spikes[56] | hid_spikes[59] | hid_spikes[61]) << 0)
        + ((hid_spikes[8] | hid_spikes[28] | hid_spikes[32] | hid_spikes[38] | hid_spikes[46] | hid_spikes[59] | hid_spikes[63]) << 1)
        + ((hid_spikes[4] | hid_spikes[7] | hid_spikes[22] | hid_spikes[38] | hid_spikes[41] | hid_spikes[44] | hid_spikes[46] | hid_spikes[56] | hid_spikes[61]) << 2)
        + ((hid_spikes[32]) << 3)
        + ((hid_spikes[8]) << 4);
    wire signed [11:0] neg_in_25 = ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[2]) << 6)
        + ((cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[3]) << 3)
        + ((cochlea_spikes[3]) << 4)
        + ((cochlea_spikes[4]) << 5)
        + ((hid_spikes[11] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[18] | hid_spikes[27] | hid_spikes[35] | hid_spikes[42] | hid_spikes[43] | hid_spikes[47] | hid_spikes[49] | hid_spikes[54]) << 0)
        + ((hid_spikes[11] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[18] | hid_spikes[20] | hid_spikes[23] | hid_spikes[25] | hid_spikes[36] | hid_spikes[42] | hid_spikes[43] | hid_spikes[48] | hid_spikes[50] | hid_spikes[51] | hid_spikes[54] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60] | hid_spikes[62]) << 1)
        + ((hid_spikes[0] | hid_spikes[6] | hid_spikes[11] | hid_spikes[14] | hid_spikes[15] | hid_spikes[18] | hid_spikes[20] | hid_spikes[31] | hid_spikes[39] | hid_spikes[40] | hid_spikes[43] | hid_spikes[45] | hid_spikes[48] | hid_spikes[51] | hid_spikes[52] | hid_spikes[53] | hid_spikes[55] | hid_spikes[57] | hid_spikes[62]) << 2)
        + ((hid_spikes[11] | hid_spikes[12] | hid_spikes[13] | hid_spikes[17] | hid_spikes[19] | hid_spikes[35] | hid_spikes[42] | hid_spikes[47] | hid_spikes[52] | hid_spikes[54]) << 3)
        + ((hid_spikes[25] | hid_spikes[27] | hid_spikes[45] | hid_spikes[49]) << 4);
    wire signed [11:0] sum_hid_25 = pos_in_25 - neg_in_25;
    assign hid_spikes[25] = (mem_hid_25 >= 10);
    wire signed [11:0] next_hid_25 = mem_hid_25 - (mem_hid_25 >>> 5) + sum_hid_25;

    reg signed [11:0] mem_hid_26;
    wire signed [11:0] pos_in_26 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 5)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2]) << 4)
        + ((hid_spikes[17] | hid_spikes[21] | hid_spikes[33] | hid_spikes[34] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[46] | hid_spikes[52] | hid_spikes[62]) << 0)
        + ((hid_spikes[7] | hid_spikes[21] | hid_spikes[33] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[46] | hid_spikes[47] | hid_spikes[52]) << 1)
        + ((hid_spikes[21] | hid_spikes[34] | hid_spikes[39] | hid_spikes[47] | hid_spikes[60] | hid_spikes[62]) << 2)
        + ((hid_spikes[17] | hid_spikes[19] | hid_spikes[38] | hid_spikes[39] | hid_spikes[40] | hid_spikes[43] | hid_spikes[60]) << 3)
        + ((hid_spikes[7] | hid_spikes[21] | hid_spikes[22] | hid_spikes[42] | hid_spikes[52]) << 4);
    wire signed [11:0] neg_in_26 = ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[0] | cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[0]) << 5)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[3]) << 4)
        + ((hid_spikes[2] | hid_spikes[5] | hid_spikes[10] | hid_spikes[12] | hid_spikes[16] | hid_spikes[18] | hid_spikes[20] | hid_spikes[24] | hid_spikes[28] | hid_spikes[35] | hid_spikes[41] | hid_spikes[44] | hid_spikes[45] | hid_spikes[49] | hid_spikes[50] | hid_spikes[53] | hid_spikes[54] | hid_spikes[57]) << 0)
        + ((hid_spikes[0] | hid_spikes[2] | hid_spikes[6] | hid_spikes[8] | hid_spikes[10] | hid_spikes[13] | hid_spikes[16] | hid_spikes[18] | hid_spikes[20] | hid_spikes[24] | hid_spikes[30] | hid_spikes[31] | hid_spikes[35] | hid_spikes[37] | hid_spikes[48] | hid_spikes[49] | hid_spikes[51] | hid_spikes[56] | hid_spikes[63]) << 1)
        + ((hid_spikes[3] | hid_spikes[5] | hid_spikes[8] | hid_spikes[18] | hid_spikes[25] | hid_spikes[26] | hid_spikes[41] | hid_spikes[50] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[56] | hid_spikes[57] | hid_spikes[59] | hid_spikes[61]) << 2)
        + ((hid_spikes[2] | hid_spikes[10] | hid_spikes[12] | hid_spikes[13] | hid_spikes[14] | hid_spikes[16] | hid_spikes[20] | hid_spikes[24] | hid_spikes[25] | hid_spikes[27] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[36] | hid_spikes[37] | hid_spikes[41] | hid_spikes[44] | hid_spikes[45] | hid_spikes[48] | hid_spikes[51] | hid_spikes[54] | hid_spikes[55] | hid_spikes[58] | hid_spikes[61]) << 3)
        + ((hid_spikes[0] | hid_spikes[5] | hid_spikes[14] | hid_spikes[53] | hid_spikes[57] | hid_spikes[63]) << 4);
    wire signed [11:0] sum_hid_26 = pos_in_26 - neg_in_26;
    assign hid_spikes[26] = (mem_hid_26 >= 10);
    wire signed [11:0] next_hid_26 = mem_hid_26 - (mem_hid_26 >>> 5) + sum_hid_26;

    reg signed [11:0] mem_hid_27;
    wire signed [11:0] pos_in_27 = ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 5)
        + ((cochlea_spikes[1]) << 6)
        + ((hid_spikes[28] | hid_spikes[34] | hid_spikes[35] | hid_spikes[37] | hid_spikes[39] | hid_spikes[52] | hid_spikes[56]) << 0)
        + ((hid_spikes[3] | hid_spikes[23] | hid_spikes[25] | hid_spikes[26] | hid_spikes[29] | hid_spikes[35] | hid_spikes[37] | hid_spikes[41] | hid_spikes[42] | hid_spikes[52] | hid_spikes[56]) << 1)
        + ((hid_spikes[4] | hid_spikes[7] | hid_spikes[23] | hid_spikes[28] | hid_spikes[34] | hid_spikes[39]) << 2)
        + ((hid_spikes[28] | hid_spikes[29] | hid_spikes[34] | hid_spikes[38] | hid_spikes[42]) << 3)
        + ((hid_spikes[20]) << 4);
    wire signed [11:0] neg_in_27 = ((cochlea_spikes[2] | cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[3]) << 5)
        + ((cochlea_spikes[3]) << 6)
        + ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 4)
        + ((cochlea_spikes[0]) << 5)
        + ((hid_spikes[2] | hid_spikes[8] | hid_spikes[10] | hid_spikes[11] | hid_spikes[18] | hid_spikes[27] | hid_spikes[40] | hid_spikes[51] | hid_spikes[53] | hid_spikes[54] | hid_spikes[57] | hid_spikes[62] | hid_spikes[63]) << 0)
        + ((hid_spikes[6] | hid_spikes[18] | hid_spikes[45] | hid_spikes[49] | hid_spikes[53] | hid_spikes[54] | hid_spikes[59] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63]) << 1)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[13] | hid_spikes[24] | hid_spikes[27] | hid_spikes[30] | hid_spikes[33] | hid_spikes[40] | hid_spikes[49] | hid_spikes[51] | hid_spikes[53] | hid_spikes[55] | hid_spikes[58] | hid_spikes[60]) << 2)
        + ((hid_spikes[0] | hid_spikes[6] | hid_spikes[8] | hid_spikes[9] | hid_spikes[10] | hid_spikes[11] | hid_spikes[14] | hid_spikes[18] | hid_spikes[32] | hid_spikes[44] | hid_spikes[45] | hid_spikes[46] | hid_spikes[55] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60]) << 3)
        + ((hid_spikes[0] | hid_spikes[16] | hid_spikes[19] | hid_spikes[51]) << 4);
    wire signed [11:0] sum_hid_27 = pos_in_27 - neg_in_27;
    assign hid_spikes[27] = (mem_hid_27 >= 10);
    wire signed [11:0] next_hid_27 = mem_hid_27 - (mem_hid_27 >>> 3) + sum_hid_27;

    reg signed [11:0] mem_hid_28;
    wire signed [11:0] pos_in_28 = ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[5]) << 4)
        + ((hid_spikes[9] | hid_spikes[10] | hid_spikes[12] | hid_spikes[20] | hid_spikes[24] | hid_spikes[28] | hid_spikes[31] | hid_spikes[45] | hid_spikes[47] | hid_spikes[54]) << 0)
        + ((hid_spikes[9] | hid_spikes[12] | hid_spikes[18] | hid_spikes[19] | hid_spikes[20] | hid_spikes[24] | hid_spikes[28] | hid_spikes[31] | hid_spikes[38] | hid_spikes[40] | hid_spikes[47] | hid_spikes[54] | hid_spikes[59]) << 1)
        + ((hid_spikes[5] | hid_spikes[10] | hid_spikes[14] | hid_spikes[18] | hid_spikes[28] | hid_spikes[32] | hid_spikes[38] | hid_spikes[40] | hid_spikes[44] | hid_spikes[47] | hid_spikes[54]) << 2)
        + ((hid_spikes[9] | hid_spikes[13] | hid_spikes[20] | hid_spikes[32] | hid_spikes[45] | hid_spikes[59]) << 3)
        + ((hid_spikes[17] | hid_spikes[22]) << 4);
    wire signed [11:0] neg_in_28 = ((cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[2] | cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[2] | cochlea_spikes[3]) << 3)
        + ((cochlea_spikes[3]) << 4)
        + ((cochlea_spikes[2]) << 5)
        + ((cochlea_spikes[1] | cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[1] | cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[0] | cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[1]) << 5)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[4] | hid_spikes[6] | hid_spikes[8] | hid_spikes[11] | hid_spikes[15] | hid_spikes[21] | hid_spikes[27] | hid_spikes[29] | hid_spikes[30] | hid_spikes[34] | hid_spikes[37] | hid_spikes[51] | hid_spikes[55] | hid_spikes[60] | hid_spikes[61] | hid_spikes[62]) << 0)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[3] | hid_spikes[7] | hid_spikes[11] | hid_spikes[15] | hid_spikes[21] | hid_spikes[30] | hid_spikes[33] | hid_spikes[34] | hid_spikes[37] | hid_spikes[49] | hid_spikes[55] | hid_spikes[57] | hid_spikes[58] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63]) << 1)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[4] | hid_spikes[6] | hid_spikes[27] | hid_spikes[37] | hid_spikes[39] | hid_spikes[48] | hid_spikes[49] | hid_spikes[52] | hid_spikes[53] | hid_spikes[58] | hid_spikes[62]) << 2)
        + ((hid_spikes[7] | hid_spikes[8] | hid_spikes[15] | hid_spikes[21] | hid_spikes[29] | hid_spikes[30] | hid_spikes[36] | hid_spikes[37] | hid_spikes[39] | hid_spikes[41] | hid_spikes[49] | hid_spikes[51] | hid_spikes[52] | hid_spikes[55] | hid_spikes[60] | hid_spikes[61] | hid_spikes[63]) << 3)
        + ((hid_spikes[46]) << 4);
    wire signed [11:0] sum_hid_28 = pos_in_28 - neg_in_28;
    assign hid_spikes[28] = (mem_hid_28 >= 10);
    wire signed [11:0] next_hid_28 = mem_hid_28 - (mem_hid_28 >>> 3) + sum_hid_28;

    reg signed [11:0] mem_hid_29;
    wire signed [11:0] pos_in_29 = ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 4)
        + ((hid_spikes[4] | hid_spikes[5] | hid_spikes[12] | hid_spikes[24] | hid_spikes[29] | hid_spikes[31] | hid_spikes[45]) << 0)
        + ((hid_spikes[5] | hid_spikes[26] | hid_spikes[29] | hid_spikes[31] | hid_spikes[53]) << 1)
        + ((hid_spikes[3] | hid_spikes[4] | hid_spikes[7] | hid_spikes[24] | hid_spikes[31] | hid_spikes[45] | hid_spikes[47] | hid_spikes[58] | hid_spikes[59]) << 2)
        + ((hid_spikes[4] | hid_spikes[12] | hid_spikes[13] | hid_spikes[15] | hid_spikes[45] | hid_spikes[46]) << 3)
        + ((hid_spikes[7]) << 4);
    wire signed [11:0] neg_in_29 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[2] | cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[1] | cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[3]) << 4)
        + ((cochlea_spikes[1] | cochlea_spikes[2]) << 5)
        + ((cochlea_spikes[1]) << 6)
        + ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[4] | cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[4] | cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[5]) << 5)
        + ((hid_spikes[0] | hid_spikes[2] | hid_spikes[6] | hid_spikes[8] | hid_spikes[18] | hid_spikes[27] | hid_spikes[28] | hid_spikes[32] | hid_spikes[34] | hid_spikes[37] | hid_spikes[41] | hid_spikes[43] | hid_spikes[49] | hid_spikes[50] | hid_spikes[51] | hid_spikes[54] | hid_spikes[61] | hid_spikes[62]) << 0)
        + ((hid_spikes[0] | hid_spikes[8] | hid_spikes[11] | hid_spikes[14] | hid_spikes[16] | hid_spikes[18] | hid_spikes[21] | hid_spikes[23] | hid_spikes[32] | hid_spikes[33] | hid_spikes[34] | hid_spikes[36] | hid_spikes[37] | hid_spikes[38] | hid_spikes[41] | hid_spikes[43] | hid_spikes[50] | hid_spikes[51] | hid_spikes[55] | hid_spikes[56] | hid_spikes[61] | hid_spikes[63]) << 1)
        + ((hid_spikes[2] | hid_spikes[6] | hid_spikes[16] | hid_spikes[19] | hid_spikes[21] | hid_spikes[22] | hid_spikes[23] | hid_spikes[27] | hid_spikes[30] | hid_spikes[33] | hid_spikes[36] | hid_spikes[37] | hid_spikes[38] | hid_spikes[48] | hid_spikes[50] | hid_spikes[55] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63]) << 2)
        + ((hid_spikes[19] | hid_spikes[23] | hid_spikes[33] | hid_spikes[35] | hid_spikes[40] | hid_spikes[50] | hid_spikes[54] | hid_spikes[61]) << 3)
        + ((hid_spikes[28] | hid_spikes[35] | hid_spikes[44] | hid_spikes[49] | hid_spikes[51] | hid_spikes[56] | hid_spikes[61]) << 4);
    wire signed [11:0] sum_hid_29 = pos_in_29 - neg_in_29;
    assign hid_spikes[29] = (mem_hid_29 >= 10);
    wire signed [11:0] next_hid_29 = mem_hid_29 - (mem_hid_29 >>> 3) + sum_hid_29;

    reg signed [11:0] mem_hid_30;
    wire signed [11:0] pos_in_30 = ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[4]) << 2)
        + ((hid_spikes[4] | hid_spikes[22] | hid_spikes[33] | hid_spikes[37] | hid_spikes[40] | hid_spikes[42] | hid_spikes[47] | hid_spikes[50] | hid_spikes[57]) << 0)
        + ((hid_spikes[9] | hid_spikes[13] | hid_spikes[17] | hid_spikes[33] | hid_spikes[37] | hid_spikes[38] | hid_spikes[40] | hid_spikes[57]) << 1)
        + ((hid_spikes[3] | hid_spikes[4] | hid_spikes[38] | hid_spikes[40] | hid_spikes[42] | hid_spikes[59]) << 2)
        + ((hid_spikes[4] | hid_spikes[5] | hid_spikes[9] | hid_spikes[13] | hid_spikes[22] | hid_spikes[32] | hid_spikes[34] | hid_spikes[42] | hid_spikes[43] | hid_spikes[47] | hid_spikes[50] | hid_spikes[56] | hid_spikes[59]) << 3)
        + ((hid_spikes[17]) << 4);
    wire signed [11:0] neg_in_30 = ((cochlea_spikes[1]) << 7)
        + ((cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[3]) << 2)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[6] | hid_spikes[7] | hid_spikes[14] | hid_spikes[16] | hid_spikes[19] | hid_spikes[20] | hid_spikes[27] | hid_spikes[31] | hid_spikes[39] | hid_spikes[41] | hid_spikes[52] | hid_spikes[55] | hid_spikes[58]) << 0)
        + ((hid_spikes[1] | hid_spikes[6] | hid_spikes[7] | hid_spikes[10] | hid_spikes[19] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[39] | hid_spikes[41] | hid_spikes[46] | hid_spikes[48] | hid_spikes[49] | hid_spikes[52] | hid_spikes[54] | hid_spikes[58] | hid_spikes[62]) << 1)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[7] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[20] | hid_spikes[21] | hid_spikes[24] | hid_spikes[25] | hid_spikes[27] | hid_spikes[31] | hid_spikes[39] | hid_spikes[41] | hid_spikes[44] | hid_spikes[46] | hid_spikes[53] | hid_spikes[55] | hid_spikes[63]) << 2)
        + ((hid_spikes[10] | hid_spikes[15] | hid_spikes[16] | hid_spikes[18] | hid_spikes[21] | hid_spikes[24] | hid_spikes[30] | hid_spikes[39] | hid_spikes[44] | hid_spikes[45] | hid_spikes[52] | hid_spikes[62]) << 3)
        + ((hid_spikes[0] | hid_spikes[7] | hid_spikes[14] | hid_spikes[26] | hid_spikes[44] | hid_spikes[49] | hid_spikes[54] | hid_spikes[55]) << 4)
        + ((hid_spikes[19]) << 5);
    wire signed [11:0] sum_hid_30 = pos_in_30 - neg_in_30;
    assign hid_spikes[30] = (mem_hid_30 >= 10);
    wire signed [11:0] next_hid_30 = mem_hid_30 - (mem_hid_30 >>> 6) + sum_hid_30;

    reg signed [11:0] mem_hid_31;
    wire signed [11:0] pos_in_31 = ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[3] | cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((hid_spikes[13] | hid_spikes[15] | hid_spikes[22] | hid_spikes[26] | hid_spikes[38] | hid_spikes[50] | hid_spikes[52] | hid_spikes[54]) << 0)
        + ((hid_spikes[4] | hid_spikes[13] | hid_spikes[15] | hid_spikes[39] | hid_spikes[46] | hid_spikes[52] | hid_spikes[54] | hid_spikes[56] | hid_spikes[59]) << 1)
        + ((hid_spikes[4] | hid_spikes[12] | hid_spikes[13] | hid_spikes[15] | hid_spikes[26] | hid_spikes[38] | hid_spikes[54] | hid_spikes[56]) << 2)
        + ((hid_spikes[4] | hid_spikes[12] | hid_spikes[20] | hid_spikes[39] | hid_spikes[42]) << 3)
        + ((hid_spikes[22] | hid_spikes[50] | hid_spikes[56]) << 4);
    wire signed [11:0] neg_in_31 = ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[1] | cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[1]) << 5)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[5]) << 4)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[2] | hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[10] | hid_spikes[14] | hid_spikes[16] | hid_spikes[17] | hid_spikes[24] | hid_spikes[27] | hid_spikes[30] | hid_spikes[31] | hid_spikes[34] | hid_spikes[36] | hid_spikes[37] | hid_spikes[40] | hid_spikes[41] | hid_spikes[43] | hid_spikes[48] | hid_spikes[53]) << 0)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[2] | hid_spikes[3] | hid_spikes[6] | hid_spikes[8] | hid_spikes[10] | hid_spikes[14] | hid_spikes[18] | hid_spikes[19] | hid_spikes[25] | hid_spikes[27] | hid_spikes[30] | hid_spikes[31] | hid_spikes[37] | hid_spikes[40] | hid_spikes[43] | hid_spikes[45] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[51] | hid_spikes[57]) << 1)
        + ((hid_spikes[0] | hid_spikes[5] | hid_spikes[6] | hid_spikes[7] | hid_spikes[16] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[25] | hid_spikes[33] | hid_spikes[34] | hid_spikes[36] | hid_spikes[37] | hid_spikes[41] | hid_spikes[43] | hid_spikes[55] | hid_spikes[57] | hid_spikes[61]) << 2)
        + ((hid_spikes[1] | hid_spikes[5] | hid_spikes[11] | hid_spikes[16] | hid_spikes[17] | hid_spikes[19] | hid_spikes[23] | hid_spikes[24] | hid_spikes[36] | hid_spikes[41] | hid_spikes[44] | hid_spikes[48] | hid_spikes[49] | hid_spikes[53] | hid_spikes[55] | hid_spikes[61] | hid_spikes[63]) << 3)
        + ((hid_spikes[6] | hid_spikes[8] | hid_spikes[14] | hid_spikes[31] | hid_spikes[45]) << 4);
    wire signed [11:0] sum_hid_31 = pos_in_31 - neg_in_31;
    assign hid_spikes[31] = (mem_hid_31 >= 10);
    wire signed [11:0] next_hid_31 = mem_hid_31 - (mem_hid_31 >>> 6) + sum_hid_31;

    reg signed [11:0] mem_hid_32;
    wire signed [11:0] pos_in_32 = ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 3)
        + ((hid_spikes[2] | hid_spikes[4] | hid_spikes[20]) << 0)
        + ((hid_spikes[4] | hid_spikes[7] | hid_spikes[15] | hid_spikes[20] | hid_spikes[28] | hid_spikes[30] | hid_spikes[34] | hid_spikes[36] | hid_spikes[38] | hid_spikes[42]) << 1)
        + ((hid_spikes[2] | hid_spikes[9] | hid_spikes[11] | hid_spikes[15] | hid_spikes[20] | hid_spikes[34] | hid_spikes[36] | hid_spikes[38] | hid_spikes[50] | hid_spikes[55]) << 2)
        + ((hid_spikes[2] | hid_spikes[11] | hid_spikes[15] | hid_spikes[28] | hid_spikes[38]) << 3);
    wire signed [11:0] neg_in_32 = ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[0]) << 5)
        + ((cochlea_spikes[1]) << 7)
        + ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[2] | cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[2]) << 5)
        + ((hid_spikes[0] | hid_spikes[6] | hid_spikes[10] | hid_spikes[14] | hid_spikes[16] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[22] | hid_spikes[24] | hid_spikes[25] | hid_spikes[31] | hid_spikes[33] | hid_spikes[45] | hid_spikes[47] | hid_spikes[49] | hid_spikes[52] | hid_spikes[54] | hid_spikes[62]) << 0)
        + ((hid_spikes[0] | hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[13] | hid_spikes[16] | hid_spikes[17] | hid_spikes[18] | hid_spikes[23] | hid_spikes[24] | hid_spikes[26] | hid_spikes[31] | hid_spikes[32] | hid_spikes[33] | hid_spikes[41]) << 1)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[10] | hid_spikes[13] | hid_spikes[16] | hid_spikes[19] | hid_spikes[26] | hid_spikes[31] | hid_spikes[32] | hid_spikes[33] | hid_spikes[37] | hid_spikes[39] | hid_spikes[41] | hid_spikes[44] | hid_spikes[47] | hid_spikes[49] | hid_spikes[51] | hid_spikes[58] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63]) << 2)
        + ((hid_spikes[14] | hid_spikes[18] | hid_spikes[22] | hid_spikes[25] | hid_spikes[26] | hid_spikes[32] | hid_spikes[33] | hid_spikes[40] | hid_spikes[41] | hid_spikes[44] | hid_spikes[45] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[53] | hid_spikes[54] | hid_spikes[57] | hid_spikes[62]) << 3)
        + ((hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[17] | hid_spikes[19] | hid_spikes[52] | hid_spikes[63]) << 4);
    wire signed [11:0] sum_hid_32 = pos_in_32 - neg_in_32;
    assign hid_spikes[32] = (mem_hid_32 >= 10);
    wire signed [11:0] next_hid_32 = mem_hid_32 - (mem_hid_32 >>> 6) + sum_hid_32;

    reg signed [11:0] mem_hid_33;
    wire signed [11:0] pos_in_33 = ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((hid_spikes[0] | hid_spikes[4] | hid_spikes[22] | hid_spikes[23] | hid_spikes[35] | hid_spikes[42] | hid_spikes[45] | hid_spikes[61]) << 0)
        + ((hid_spikes[0] | hid_spikes[4] | hid_spikes[23] | hid_spikes[24] | hid_spikes[27] | hid_spikes[35] | hid_spikes[50]) << 1)
        + ((hid_spikes[4] | hid_spikes[10] | hid_spikes[22] | hid_spikes[24] | hid_spikes[38] | hid_spikes[42] | hid_spikes[45] | hid_spikes[51] | hid_spikes[56] | hid_spikes[61]) << 2)
        + ((hid_spikes[56]) << 3)
        + ((hid_spikes[35]) << 4);
    wire signed [11:0] neg_in_33 = ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((hid_spikes[5] | hid_spikes[7] | hid_spikes[8] | hid_spikes[13] | hid_spikes[15] | hid_spikes[17] | hid_spikes[18] | hid_spikes[20] | hid_spikes[26] | hid_spikes[29] | hid_spikes[32] | hid_spikes[33] | hid_spikes[34] | hid_spikes[49] | hid_spikes[57] | hid_spikes[58] | hid_spikes[59]) << 0)
        + ((hid_spikes[3] | hid_spikes[5] | hid_spikes[8] | hid_spikes[9] | hid_spikes[13] | hid_spikes[14] | hid_spikes[17] | hid_spikes[20] | hid_spikes[21] | hid_spikes[29] | hid_spikes[33] | hid_spikes[34] | hid_spikes[36] | hid_spikes[39] | hid_spikes[41] | hid_spikes[44] | hid_spikes[48] | hid_spikes[49] | hid_spikes[53] | hid_spikes[54] | hid_spikes[58] | hid_spikes[62]) << 1)
        + ((hid_spikes[1] | hid_spikes[5] | hid_spikes[12] | hid_spikes[14] | hid_spikes[16] | hid_spikes[18] | hid_spikes[21] | hid_spikes[26] | hid_spikes[28] | hid_spikes[30] | hid_spikes[31] | hid_spikes[32] | hid_spikes[44] | hid_spikes[49] | hid_spikes[55] | hid_spikes[57] | hid_spikes[59] | hid_spikes[60]) << 2)
        + ((hid_spikes[1] | hid_spikes[5] | hid_spikes[7] | hid_spikes[12] | hid_spikes[18] | hid_spikes[19] | hid_spikes[20] | hid_spikes[25] | hid_spikes[29] | hid_spikes[34] | hid_spikes[36] | hid_spikes[39] | hid_spikes[47] | hid_spikes[48] | hid_spikes[53] | hid_spikes[55] | hid_spikes[62]) << 3)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[6] | hid_spikes[14] | hid_spikes[40] | hid_spikes[44] | hid_spikes[49]) << 4)
        + ((hid_spikes[15] | hid_spikes[63]) << 5);
    wire signed [11:0] sum_hid_33 = pos_in_33 - neg_in_33;
    assign hid_spikes[33] = (mem_hid_33 >= 10);
    wire signed [11:0] next_hid_33 = mem_hid_33 - (mem_hid_33 >>> 6) + sum_hid_33;

    reg signed [11:0] mem_hid_34;
    wire signed [11:0] pos_in_34 = ((hid_spikes[9] | hid_spikes[17] | hid_spikes[31] | hid_spikes[42] | hid_spikes[45] | hid_spikes[47] | hid_spikes[50] | hid_spikes[52] | hid_spikes[54] | hid_spikes[56]) << 0)
        + ((hid_spikes[7] | hid_spikes[17] | hid_spikes[19] | hid_spikes[22] | hid_spikes[31] | hid_spikes[34] | hid_spikes[38] | hid_spikes[50] | hid_spikes[56] | hid_spikes[58] | hid_spikes[59]) << 1)
        + ((hid_spikes[2] | hid_spikes[4] | hid_spikes[19] | hid_spikes[22] | hid_spikes[31] | hid_spikes[38] | hid_spikes[47] | hid_spikes[50] | hid_spikes[52] | hid_spikes[54] | hid_spikes[59]) << 2)
        + ((hid_spikes[9] | hid_spikes[29] | hid_spikes[30] | hid_spikes[33] | hid_spikes[38] | hid_spikes[45] | hid_spikes[47] | hid_spikes[56]) << 3)
        + ((hid_spikes[42]) << 4);
    wire signed [11:0] neg_in_34 = ((cochlea_spikes[4] | cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[5]) << 5)
        + ((cochlea_spikes[4] | cochlea_spikes[5]) << 6)
        + ((cochlea_spikes[0]) << 7)
        + ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[1] | cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[2]) << 5)
        + ((cochlea_spikes[1] | cochlea_spikes[2]) << 6)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[12] | hid_spikes[13] | hid_spikes[15] | hid_spikes[16] | hid_spikes[18] | hid_spikes[26] | hid_spikes[27] | hid_spikes[32] | hid_spikes[39] | hid_spikes[48] | hid_spikes[49] | hid_spikes[57] | hid_spikes[61] | hid_spikes[63]) << 0)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[8] | hid_spikes[13] | hid_spikes[16] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[40] | hid_spikes[41] | hid_spikes[46] | hid_spikes[49] | hid_spikes[51] | hid_spikes[55] | hid_spikes[61]) << 1)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[3] | hid_spikes[6] | hid_spikes[8] | hid_spikes[13] | hid_spikes[15] | hid_spikes[23] | hid_spikes[27] | hid_spikes[28] | hid_spikes[32] | hid_spikes[39] | hid_spikes[49] | hid_spikes[51] | hid_spikes[55] | hid_spikes[63]) << 2)
        + ((hid_spikes[1] | hid_spikes[3] | hid_spikes[5] | hid_spikes[12] | hid_spikes[18] | hid_spikes[27] | hid_spikes[36] | hid_spikes[39] | hid_spikes[46]) << 3)
        + ((hid_spikes[6] | hid_spikes[14] | hid_spikes[16] | hid_spikes[43] | hid_spikes[48] | hid_spikes[55] | hid_spikes[57] | hid_spikes[62]) << 4);
    wire signed [11:0] sum_hid_34 = pos_in_34 - neg_in_34;
    assign hid_spikes[34] = (mem_hid_34 >= 10);
    wire signed [11:0] next_hid_34 = mem_hid_34 - (mem_hid_34 >>> 4) + sum_hid_34;

    reg signed [11:0] mem_hid_35;
    wire signed [11:0] pos_in_35 = ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 4)
        + ((hid_spikes[2] | hid_spikes[17] | hid_spikes[21] | hid_spikes[24] | hid_spikes[28] | hid_spikes[37] | hid_spikes[38] | hid_spikes[40] | hid_spikes[42] | hid_spikes[46] | hid_spikes[48] | hid_spikes[53] | hid_spikes[61]) << 0)
        + ((hid_spikes[2] | hid_spikes[17] | hid_spikes[24] | hid_spikes[28] | hid_spikes[40] | hid_spikes[42] | hid_spikes[46] | hid_spikes[48] | hid_spikes[58]) << 1)
        + ((hid_spikes[27] | hid_spikes[37] | hid_spikes[38] | hid_spikes[42] | hid_spikes[46] | hid_spikes[48] | hid_spikes[53] | hid_spikes[61]) << 2)
        + ((hid_spikes[2] | hid_spikes[21] | hid_spikes[24] | hid_spikes[58] | hid_spikes[61]) << 3);
    wire signed [11:0] neg_in_35 = ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2]) << 6)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[0]) << 5)
        + ((hid_spikes[1] | hid_spikes[4] | hid_spikes[8] | hid_spikes[10] | hid_spikes[18] | hid_spikes[19] | hid_spikes[22] | hid_spikes[26] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[32] | hid_spikes[34] | hid_spikes[35] | hid_spikes[49] | hid_spikes[54] | hid_spikes[55] | hid_spikes[57] | hid_spikes[62]) << 0)
        + ((hid_spikes[1] | hid_spikes[8] | hid_spikes[10] | hid_spikes[11] | hid_spikes[13] | hid_spikes[22] | hid_spikes[23] | hid_spikes[25] | hid_spikes[29] | hid_spikes[30] | hid_spikes[32] | hid_spikes[33] | hid_spikes[34] | hid_spikes[39] | hid_spikes[45] | hid_spikes[50] | hid_spikes[55] | hid_spikes[57] | hid_spikes[60] | hid_spikes[62]) << 1)
        + ((hid_spikes[4] | hid_spikes[9] | hid_spikes[13] | hid_spikes[14] | hid_spikes[18] | hid_spikes[22] | hid_spikes[23] | hid_spikes[26] | hid_spikes[30] | hid_spikes[31] | hid_spikes[33] | hid_spikes[35] | hid_spikes[36] | hid_spikes[41] | hid_spikes[43] | hid_spikes[45] | hid_spikes[54] | hid_spikes[55] | hid_spikes[56] | hid_spikes[60]) << 2)
        + ((hid_spikes[6] | hid_spikes[9] | hid_spikes[10] | hid_spikes[25] | hid_spikes[26] | hid_spikes[29] | hid_spikes[31] | hid_spikes[36] | hid_spikes[39] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[49] | hid_spikes[52] | hid_spikes[60] | hid_spikes[62]) << 3)
        + ((hid_spikes[3] | hid_spikes[6] | hid_spikes[9] | hid_spikes[13] | hid_spikes[14] | hid_spikes[19]) << 4)
        + ((hid_spikes[63]) << 5);
    wire signed [11:0] sum_hid_35 = pos_in_35 - neg_in_35;
    assign hid_spikes[35] = (mem_hid_35 >= 10);
    wire signed [11:0] next_hid_35 = mem_hid_35 - (mem_hid_35 >>> 6) + sum_hid_35;

    reg signed [11:0] mem_hid_36;
    wire signed [11:0] pos_in_36 = ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 3)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[32] | hid_spikes[33] | hid_spikes[35] | hid_spikes[45] | hid_spikes[58] | hid_spikes[60]) << 0)
        + ((hid_spikes[2] | hid_spikes[7] | hid_spikes[8] | hid_spikes[17] | hid_spikes[20] | hid_spikes[22] | hid_spikes[27] | hid_spikes[34] | hid_spikes[36] | hid_spikes[38] | hid_spikes[40] | hid_spikes[41] | hid_spikes[46] | hid_spikes[56] | hid_spikes[60]) << 1)
        + ((hid_spikes[7] | hid_spikes[8] | hid_spikes[11] | hid_spikes[17] | hid_spikes[20] | hid_spikes[22] | hid_spikes[27] | hid_spikes[32] | hid_spikes[34] | hid_spikes[41] | hid_spikes[42] | hid_spikes[45] | hid_spikes[58]) << 2)
        + ((hid_spikes[3] | hid_spikes[22] | hid_spikes[32] | hid_spikes[33] | hid_spikes[35] | hid_spikes[46] | hid_spikes[56]) << 3)
        + ((hid_spikes[40]) << 4);
    wire signed [11:0] neg_in_36 = ((cochlea_spikes[1] | cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1] | cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 4)
        + ((hid_spikes[6] | hid_spikes[18] | hid_spikes[19] | hid_spikes[25] | hid_spikes[26] | hid_spikes[30] | hid_spikes[47] | hid_spikes[54] | hid_spikes[61] | hid_spikes[62]) << 0)
        + ((hid_spikes[1] | hid_spikes[5] | hid_spikes[9] | hid_spikes[13] | hid_spikes[18] | hid_spikes[19] | hid_spikes[25] | hid_spikes[30] | hid_spikes[31] | hid_spikes[44] | hid_spikes[48] | hid_spikes[50] | hid_spikes[53] | hid_spikes[54] | hid_spikes[61] | hid_spikes[62]) << 1)
        + ((hid_spikes[1] | hid_spikes[4] | hid_spikes[6] | hid_spikes[10] | hid_spikes[14] | hid_spikes[18] | hid_spikes[25] | hid_spikes[26] | hid_spikes[31] | hid_spikes[37] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[57]) << 2)
        + ((hid_spikes[9] | hid_spikes[13] | hid_spikes[16] | hid_spikes[18] | hid_spikes[23] | hid_spikes[30] | hid_spikes[37] | hid_spikes[43] | hid_spikes[44] | hid_spikes[49] | hid_spikes[52] | hid_spikes[55] | hid_spikes[62]) << 3)
        + ((hid_spikes[53] | hid_spikes[61]) << 4);
    wire signed [11:0] sum_hid_36 = pos_in_36 - neg_in_36;
    assign hid_spikes[36] = (mem_hid_36 >= 10);
    wire signed [11:0] next_hid_36 = mem_hid_36 - (mem_hid_36 >>> 3) + sum_hid_36;

    reg signed [11:0] mem_hid_37;
    wire signed [11:0] pos_in_37 = ((hid_spikes[7] | hid_spikes[46] | hid_spikes[50]) << 0)
        + ((hid_spikes[4] | hid_spikes[11] | hid_spikes[17] | hid_spikes[38] | hid_spikes[41] | hid_spikes[50] | hid_spikes[58] | hid_spikes[59]) << 1)
        + ((hid_spikes[4] | hid_spikes[7] | hid_spikes[9] | hid_spikes[13] | hid_spikes[17] | hid_spikes[33] | hid_spikes[38] | hid_spikes[41] | hid_spikes[46] | hid_spikes[50] | hid_spikes[56] | hid_spikes[59]) << 2)
        + ((hid_spikes[21] | hid_spikes[38] | hid_spikes[41] | hid_spikes[50] | hid_spikes[56] | hid_spikes[58] | hid_spikes[59]) << 3)
        + ((hid_spikes[47]) << 4);
    wire signed [11:0] neg_in_37 = ((hid_spikes[2] | hid_spikes[6] | hid_spikes[8] | hid_spikes[10] | hid_spikes[14] | hid_spikes[23] | hid_spikes[24] | hid_spikes[28] | hid_spikes[31] | hid_spikes[39] | hid_spikes[42] | hid_spikes[44] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[60]) << 0)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[3] | hid_spikes[8] | hid_spikes[10] | hid_spikes[12] | hid_spikes[14] | hid_spikes[15] | hid_spikes[23] | hid_spikes[26] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[32] | hid_spikes[34] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[53] | hid_spikes[57] | hid_spikes[61] | hid_spikes[62]) << 1)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[3] | hid_spikes[6] | hid_spikes[12] | hid_spikes[18] | hid_spikes[24] | hid_spikes[29] | hid_spikes[30] | hid_spikes[32] | hid_spikes[36] | hid_spikes[39] | hid_spikes[44] | hid_spikes[49] | hid_spikes[54] | hid_spikes[55] | hid_spikes[60] | hid_spikes[63]) << 2)
        + ((hid_spikes[5] | hid_spikes[12] | hid_spikes[16] | hid_spikes[19] | hid_spikes[23] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[32] | hid_spikes[34] | hid_spikes[35] | hid_spikes[44] | hid_spikes[49] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[63]) << 3)
        + ((hid_spikes[14] | hid_spikes[15] | hid_spikes[57] | hid_spikes[61]) << 4);
    wire signed [11:0] sum_hid_37 = pos_in_37 - neg_in_37;
    assign hid_spikes[37] = (mem_hid_37 >= 10);
    wire signed [11:0] next_hid_37 = mem_hid_37 - (mem_hid_37 >>> 6) + sum_hid_37;

    reg signed [11:0] mem_hid_38;
    wire signed [11:0] pos_in_38 = ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 6)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 5)
        + ((hid_spikes[0] | hid_spikes[4] | hid_spikes[18] | hid_spikes[20] | hid_spikes[35] | hid_spikes[38] | hid_spikes[49] | hid_spikes[51] | hid_spikes[54] | hid_spikes[55] | hid_spikes[58] | hid_spikes[59] | hid_spikes[60]) << 0)
        + ((hid_spikes[4] | hid_spikes[9] | hid_spikes[17] | hid_spikes[20] | hid_spikes[21] | hid_spikes[22] | hid_spikes[31] | hid_spikes[35] | hid_spikes[38] | hid_spikes[42] | hid_spikes[49] | hid_spikes[51] | hid_spikes[53] | hid_spikes[58] | hid_spikes[59] | hid_spikes[60]) << 1)
        + ((hid_spikes[0] | hid_spikes[4] | hid_spikes[18] | hid_spikes[34] | hid_spikes[42] | hid_spikes[46] | hid_spikes[49] | hid_spikes[51] | hid_spikes[53] | hid_spikes[54]) << 2)
        + ((hid_spikes[21] | hid_spikes[25] | hid_spikes[35] | hid_spikes[46] | hid_spikes[54] | hid_spikes[55]) << 3)
        + ((hid_spikes[7] | hid_spikes[31] | hid_spikes[46]) << 4);
    wire signed [11:0] neg_in_38 = ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[2]) << 5)
        + ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0] | cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[0]) << 4)
        + ((cochlea_spikes[5]) << 5)
        + ((hid_spikes[3] | hid_spikes[6] | hid_spikes[11] | hid_spikes[14] | hid_spikes[15] | hid_spikes[16] | hid_spikes[26] | hid_spikes[36] | hid_spikes[39] | hid_spikes[40] | hid_spikes[41] | hid_spikes[44] | hid_spikes[45] | hid_spikes[47] | hid_spikes[57] | hid_spikes[61] | hid_spikes[62]) << 0)
        + ((hid_spikes[1] | hid_spikes[5] | hid_spikes[8] | hid_spikes[15] | hid_spikes[19] | hid_spikes[26] | hid_spikes[27] | hid_spikes[29] | hid_spikes[30] | hid_spikes[33] | hid_spikes[37] | hid_spikes[39] | hid_spikes[41] | hid_spikes[44] | hid_spikes[62] | hid_spikes[63]) << 1)
        + ((hid_spikes[1] | hid_spikes[6] | hid_spikes[10] | hid_spikes[24] | hid_spikes[26] | hid_spikes[30] | hid_spikes[33] | hid_spikes[36] | hid_spikes[37] | hid_spikes[39] | hid_spikes[48] | hid_spikes[50] | hid_spikes[52] | hid_spikes[61]) << 2)
        + ((hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[10] | hid_spikes[11] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[30] | hid_spikes[36] | hid_spikes[39] | hid_spikes[43] | hid_spikes[45] | hid_spikes[47] | hid_spikes[50] | hid_spikes[57] | hid_spikes[62] | hid_spikes[63]) << 3)
        + ((hid_spikes[3] | hid_spikes[8] | hid_spikes[14] | hid_spikes[40] | hid_spikes[57]) << 4);
    wire signed [11:0] sum_hid_38 = pos_in_38 - neg_in_38;
    assign hid_spikes[38] = (mem_hid_38 >= 10);
    wire signed [11:0] next_hid_38 = mem_hid_38 - (mem_hid_38 >>> 4) + sum_hid_38;

    reg signed [11:0] mem_hid_39;
    wire signed [11:0] pos_in_39 = ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[5]) << 3)
        + ((hid_spikes[6] | hid_spikes[15] | hid_spikes[25] | hid_spikes[30] | hid_spikes[34] | hid_spikes[35] | hid_spikes[41] | hid_spikes[54] | hid_spikes[58]) << 0)
        + ((hid_spikes[3] | hid_spikes[4] | hid_spikes[6] | hid_spikes[7] | hid_spikes[15] | hid_spikes[20] | hid_spikes[25] | hid_spikes[29] | hid_spikes[30] | hid_spikes[35] | hid_spikes[46] | hid_spikes[54] | hid_spikes[56] | hid_spikes[58] | hid_spikes[60]) << 1)
        + ((hid_spikes[7] | hid_spikes[16] | hid_spikes[25] | hid_spikes[30] | hid_spikes[34] | hid_spikes[41] | hid_spikes[46] | hid_spikes[60] | hid_spikes[63]) << 2)
        + ((hid_spikes[20] | hid_spikes[21] | hid_spikes[29] | hid_spikes[35] | hid_spikes[36] | hid_spikes[46] | hid_spikes[54]) << 3)
        + ((hid_spikes[2] | hid_spikes[15]) << 4);
    wire signed [11:0] neg_in_39 = ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 4)
        + ((cochlea_spikes[2]) << 5)
        + ((cochlea_spikes[2]) << 6)
        + ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 4)
        + ((hid_spikes[5] | hid_spikes[8] | hid_spikes[19] | hid_spikes[23] | hid_spikes[26] | hid_spikes[44] | hid_spikes[45] | hid_spikes[48] | hid_spikes[52] | hid_spikes[55] | hid_spikes[59] | hid_spikes[61]) << 0)
        + ((hid_spikes[0] | hid_spikes[5] | hid_spikes[11] | hid_spikes[12] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[22] | hid_spikes[23] | hid_spikes[27] | hid_spikes[32] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[50] | hid_spikes[51] | hid_spikes[55] | hid_spikes[61] | hid_spikes[62]) << 1)
        + ((hid_spikes[1] | hid_spikes[17] | hid_spikes[18] | hid_spikes[37] | hid_spikes[43] | hid_spikes[45] | hid_spikes[48] | hid_spikes[51] | hid_spikes[57] | hid_spikes[59] | hid_spikes[62]) << 2)
        + ((hid_spikes[8] | hid_spikes[13] | hid_spikes[26] | hid_spikes[31] | hid_spikes[48] | hid_spikes[50] | hid_spikes[52] | hid_spikes[55] | hid_spikes[57]) << 3)
        + ((hid_spikes[55] | hid_spikes[62]) << 4);
    wire signed [11:0] sum_hid_39 = pos_in_39 - neg_in_39;
    assign hid_spikes[39] = (mem_hid_39 >= 10);
    wire signed [11:0] next_hid_39 = mem_hid_39 - (mem_hid_39 >>> 6) + sum_hid_39;

    reg signed [11:0] mem_hid_40;
    wire signed [11:0] pos_in_40 = ((cochlea_spikes[1] | cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 4)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[5]) << 3)
        + ((hid_spikes[4] | hid_spikes[11] | hid_spikes[13] | hid_spikes[18] | hid_spikes[32] | hid_spikes[38] | hid_spikes[46] | hid_spikes[49] | hid_spikes[50] | hid_spikes[58] | hid_spikes[60]) << 0)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[10] | hid_spikes[11] | hid_spikes[21] | hid_spikes[30] | hid_spikes[31] | hid_spikes[32] | hid_spikes[37] | hid_spikes[50] | hid_spikes[56] | hid_spikes[57]) << 1)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[4] | hid_spikes[13] | hid_spikes[18] | hid_spikes[30] | hid_spikes[31] | hid_spikes[37] | hid_spikes[38] | hid_spikes[43] | hid_spikes[46] | hid_spikes[50] | hid_spikes[56] | hid_spikes[59]) << 2)
        + ((hid_spikes[4] | hid_spikes[10] | hid_spikes[11] | hid_spikes[49] | hid_spikes[58]) << 3)
        + ((hid_spikes[21] | hid_spikes[32] | hid_spikes[60] | hid_spikes[61]) << 4);
    wire signed [11:0] neg_in_40 = ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[0]) << 6)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[4]) << 4)
        + ((hid_spikes[6] | hid_spikes[8] | hid_spikes[14] | hid_spikes[15] | hid_spikes[20] | hid_spikes[23] | hid_spikes[25] | hid_spikes[26] | hid_spikes[33] | hid_spikes[45] | hid_spikes[47] | hid_spikes[48] | hid_spikes[51] | hid_spikes[53] | hid_spikes[62]) << 0)
        + ((hid_spikes[6] | hid_spikes[7] | hid_spikes[15] | hid_spikes[16] | hid_spikes[19] | hid_spikes[23] | hid_spikes[24] | hid_spikes[33] | hid_spikes[36] | hid_spikes[40] | hid_spikes[44] | hid_spikes[45] | hid_spikes[47] | hid_spikes[51] | hid_spikes[52] | hid_spikes[53]) << 1)
        + ((hid_spikes[5] | hid_spikes[8] | hid_spikes[9] | hid_spikes[14] | hid_spikes[15] | hid_spikes[17] | hid_spikes[19] | hid_spikes[20] | hid_spikes[24] | hid_spikes[39] | hid_spikes[40] | hid_spikes[47] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55]) << 2)
        + ((hid_spikes[5] | hid_spikes[6] | hid_spikes[9] | hid_spikes[14] | hid_spikes[19] | hid_spikes[24] | hid_spikes[26] | hid_spikes[36] | hid_spikes[39] | hid_spikes[42] | hid_spikes[44] | hid_spikes[48] | hid_spikes[52] | hid_spikes[55] | hid_spikes[63]) << 3)
        + ((hid_spikes[25] | hid_spikes[62]) << 4);
    wire signed [11:0] sum_hid_40 = pos_in_40 - neg_in_40;
    assign hid_spikes[40] = (mem_hid_40 >= 10);
    wire signed [11:0] next_hid_40 = mem_hid_40 - (mem_hid_40 >>> 6) + sum_hid_40;

    reg signed [11:0] mem_hid_41;
    wire signed [11:0] pos_in_41 = ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 4)
        + ((cochlea_spikes[3]) << 2)
        + ((hid_spikes[16] | hid_spikes[40] | hid_spikes[54]) << 0)
        + ((hid_spikes[0] | hid_spikes[23] | hid_spikes[28] | hid_spikes[40] | hid_spikes[54] | hid_spikes[58]) << 1)
        + ((hid_spikes[2] | hid_spikes[16] | hid_spikes[56]) << 2)
        + ((hid_spikes[42]) << 3);
    wire signed [11:0] neg_in_41 = ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[1]) << 5)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[5]) << 4)
        + ((hid_spikes[8] | hid_spikes[15] | hid_spikes[18] | hid_spikes[20] | hid_spikes[21] | hid_spikes[29] | hid_spikes[30] | hid_spikes[33] | hid_spikes[36] | hid_spikes[39] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[47] | hid_spikes[50] | hid_spikes[52] | hid_spikes[53] | hid_spikes[59] | hid_spikes[60]) << 0)
        + ((hid_spikes[1] | hid_spikes[5] | hid_spikes[8] | hid_spikes[9] | hid_spikes[11] | hid_spikes[12] | hid_spikes[14] | hid_spikes[21] | hid_spikes[25] | hid_spikes[26] | hid_spikes[29] | hid_spikes[31] | hid_spikes[32] | hid_spikes[35] | hid_spikes[36] | hid_spikes[43] | hid_spikes[44] | hid_spikes[48] | hid_spikes[52] | hid_spikes[59] | hid_spikes[62]) << 1)
        + ((hid_spikes[1] | hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[11] | hid_spikes[12] | hid_spikes[13] | hid_spikes[15] | hid_spikes[18] | hid_spikes[19] | hid_spikes[20] | hid_spikes[21] | hid_spikes[24] | hid_spikes[25] | hid_spikes[27] | hid_spikes[30] | hid_spikes[31] | hid_spikes[33] | hid_spikes[38] | hid_spikes[41] | hid_spikes[47] | hid_spikes[48] | hid_spikes[50] | hid_spikes[55] | hid_spikes[60]) << 2)
        + ((hid_spikes[1] | hid_spikes[5] | hid_spikes[13] | hid_spikes[14] | hid_spikes[25] | hid_spikes[26] | hid_spikes[31] | hid_spikes[32] | hid_spikes[39] | hid_spikes[44] | hid_spikes[49] | hid_spikes[53] | hid_spikes[55] | hid_spikes[57] | hid_spikes[62]) << 3)
        + ((hid_spikes[6] | hid_spikes[14] | hid_spikes[24] | hid_spikes[29] | hid_spikes[36] | hid_spikes[41] | hid_spikes[45] | hid_spikes[48]) << 4);
    wire signed [11:0] sum_hid_41 = pos_in_41 - neg_in_41;
    assign hid_spikes[41] = (mem_hid_41 >= 10);
    wire signed [11:0] next_hid_41 = mem_hid_41 - (mem_hid_41 >>> 5) + sum_hid_41;

    reg signed [11:0] mem_hid_42;
    wire signed [11:0] pos_in_42 = ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[6] | hid_spikes[7] | hid_spikes[8] | hid_spikes[9] | hid_spikes[22] | hid_spikes[34] | hid_spikes[35] | hid_spikes[39] | hid_spikes[40] | hid_spikes[45] | hid_spikes[46] | hid_spikes[52] | hid_spikes[56]) << 0)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[6] | hid_spikes[9] | hid_spikes[22] | hid_spikes[24] | hid_spikes[30] | hid_spikes[34] | hid_spikes[38] | hid_spikes[39] | hid_spikes[45] | hid_spikes[48] | hid_spikes[54] | hid_spikes[56]) << 1)
        + ((hid_spikes[6] | hid_spikes[10] | hid_spikes[22] | hid_spikes[24] | hid_spikes[35] | hid_spikes[38] | hid_spikes[39] | hid_spikes[46] | hid_spikes[48] | hid_spikes[52] | hid_spikes[54]) << 2)
        + ((hid_spikes[0] | hid_spikes[8] | hid_spikes[10] | hid_spikes[20] | hid_spikes[34] | hid_spikes[37] | hid_spikes[39] | hid_spikes[40] | hid_spikes[46] | hid_spikes[56]) << 3)
        + ((hid_spikes[7] | hid_spikes[21] | hid_spikes[52]) << 4);
    wire signed [11:0] neg_in_42 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[3]) << 4)
        + ((cochlea_spikes[5]) << 3)
        + ((hid_spikes[1] | hid_spikes[4] | hid_spikes[5] | hid_spikes[14] | hid_spikes[18] | hid_spikes[27] | hid_spikes[33] | hid_spikes[41] | hid_spikes[43]) << 0)
        + ((hid_spikes[11] | hid_spikes[13] | hid_spikes[17] | hid_spikes[23] | hid_spikes[28] | hid_spikes[29] | hid_spikes[33] | hid_spikes[42] | hid_spikes[44] | hid_spikes[57] | hid_spikes[62]) << 1)
        + ((hid_spikes[1] | hid_spikes[5] | hid_spikes[17] | hid_spikes[19] | hid_spikes[29] | hid_spikes[31] | hid_spikes[32] | hid_spikes[41] | hid_spikes[43] | hid_spikes[49] | hid_spikes[50] | hid_spikes[53] | hid_spikes[61] | hid_spikes[63]) << 2)
        + ((hid_spikes[2] | hid_spikes[4] | hid_spikes[5] | hid_spikes[18] | hid_spikes[19] | hid_spikes[27] | hid_spikes[41] | hid_spikes[42] | hid_spikes[44] | hid_spikes[53] | hid_spikes[57] | hid_spikes[59] | hid_spikes[62] | hid_spikes[63]) << 3)
        + ((hid_spikes[5] | hid_spikes[11] | hid_spikes[13] | hid_spikes[19] | hid_spikes[61]) << 4)
        + ((hid_spikes[14]) << 5);
    wire signed [11:0] sum_hid_42 = pos_in_42 - neg_in_42;
    assign hid_spikes[42] = (mem_hid_42 >= 10);
    wire signed [11:0] next_hid_42 = mem_hid_42 - (mem_hid_42 >>> 6) + sum_hid_42;

    reg signed [11:0] mem_hid_43;
    wire signed [11:0] pos_in_43 = ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 5)
        + ((cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[3]) << 3)
        + ((cochlea_spikes[0]) << 4)
        + ((hid_spikes[16] | hid_spikes[17] | hid_spikes[22] | hid_spikes[34] | hid_spikes[38] | hid_spikes[59] | hid_spikes[61]) << 0)
        + ((hid_spikes[17] | hid_spikes[22] | hid_spikes[28] | hid_spikes[32] | hid_spikes[34] | hid_spikes[38] | hid_spikes[50] | hid_spikes[55]) << 1)
        + ((hid_spikes[7] | hid_spikes[12] | hid_spikes[20] | hid_spikes[22] | hid_spikes[28] | hid_spikes[32] | hid_spikes[34] | hid_spikes[40] | hid_spikes[56] | hid_spikes[61] | hid_spikes[63]) << 2)
        + ((hid_spikes[16] | hid_spikes[59]) << 3)
        + ((hid_spikes[38]) << 4);
    wire signed [11:0] neg_in_43 = ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[2] | cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[5]) << 4)
        + ((hid_spikes[1] | hid_spikes[6] | hid_spikes[8] | hid_spikes[11] | hid_spikes[13] | hid_spikes[14] | hid_spikes[19] | hid_spikes[24] | hid_spikes[29] | hid_spikes[30] | hid_spikes[35] | hid_spikes[36] | hid_spikes[39] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[49] | hid_spikes[51] | hid_spikes[52] | hid_spikes[53] | hid_spikes[54] | hid_spikes[60]) << 0)
        + ((hid_spikes[1] | hid_spikes[5] | hid_spikes[8] | hid_spikes[11] | hid_spikes[19] | hid_spikes[24] | hid_spikes[27] | hid_spikes[29] | hid_spikes[30] | hid_spikes[31] | hid_spikes[41] | hid_spikes[43] | hid_spikes[44] | hid_spikes[46] | hid_spikes[51] | hid_spikes[52] | hid_spikes[53] | hid_spikes[54] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60]) << 1)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[4] | hid_spikes[5] | hid_spikes[11] | hid_spikes[23] | hid_spikes[24] | hid_spikes[25] | hid_spikes[29] | hid_spikes[31] | hid_spikes[33] | hid_spikes[36] | hid_spikes[42] | hid_spikes[44] | hid_spikes[45] | hid_spikes[48] | hid_spikes[51] | hid_spikes[52] | hid_spikes[57] | hid_spikes[60]) << 2)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[4] | hid_spikes[6] | hid_spikes[13] | hid_spikes[14] | hid_spikes[19] | hid_spikes[26] | hid_spikes[27] | hid_spikes[31] | hid_spikes[41] | hid_spikes[43] | hid_spikes[44] | hid_spikes[47] | hid_spikes[49] | hid_spikes[54] | hid_spikes[57] | hid_spikes[62]) << 3)
        + ((hid_spikes[8] | hid_spikes[35] | hid_spikes[39] | hid_spikes[46]) << 4);
    wire signed [11:0] sum_hid_43 = pos_in_43 - neg_in_43;
    assign hid_spikes[43] = (mem_hid_43 >= 10);
    wire signed [11:0] next_hid_43 = mem_hid_43 - (mem_hid_43 >>> 4) + sum_hid_43;

    reg signed [11:0] mem_hid_44;
    wire signed [11:0] pos_in_44 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[1]) << 3)
        + ((hid_spikes[16] | hid_spikes[22] | hid_spikes[23] | hid_spikes[28]) << 0)
        + ((hid_spikes[16] | hid_spikes[22] | hid_spikes[28] | hid_spikes[29] | hid_spikes[47]) << 1)
        + ((hid_spikes[1] | hid_spikes[16] | hid_spikes[23] | hid_spikes[33] | hid_spikes[40]) << 2)
        + ((hid_spikes[9] | hid_spikes[22] | hid_spikes[23] | hid_spikes[40]) << 3);
    wire signed [11:0] neg_in_44 = ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 2)
        + ((hid_spikes[5] | hid_spikes[6] | hid_spikes[12] | hid_spikes[24] | hid_spikes[25] | hid_spikes[30] | hid_spikes[32] | hid_spikes[34] | hid_spikes[38] | hid_spikes[39] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[49] | hid_spikes[52] | hid_spikes[54] | hid_spikes[61]) << 0)
        + ((hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[10] | hid_spikes[11] | hid_spikes[14] | hid_spikes[15] | hid_spikes[18] | hid_spikes[25] | hid_spikes[31] | hid_spikes[34] | hid_spikes[39] | hid_spikes[43] | hid_spikes[48] | hid_spikes[49] | hid_spikes[50] | hid_spikes[51] | hid_spikes[52] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[58] | hid_spikes[61]) << 1)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[11] | hid_spikes[15] | hid_spikes[18] | hid_spikes[19] | hid_spikes[20] | hid_spikes[24] | hid_spikes[26] | hid_spikes[30] | hid_spikes[31] | hid_spikes[32] | hid_spikes[35] | hid_spikes[38] | hid_spikes[39] | hid_spikes[43] | hid_spikes[46] | hid_spikes[49] | hid_spikes[52] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[58]) << 2)
        + ((hid_spikes[6] | hid_spikes[8] | hid_spikes[12] | hid_spikes[14] | hid_spikes[20] | hid_spikes[21] | hid_spikes[26] | hid_spikes[30] | hid_spikes[35] | hid_spikes[38] | hid_spikes[41] | hid_spikes[46] | hid_spikes[50] | hid_spikes[63]) << 3)
        + ((hid_spikes[42] | hid_spikes[44] | hid_spikes[59]) << 4);
    wire signed [11:0] sum_hid_44 = pos_in_44 - neg_in_44;
    assign hid_spikes[44] = (mem_hid_44 >= 10);
    wire signed [11:0] next_hid_44 = mem_hid_44 - (mem_hid_44 >>> 5) + sum_hid_44;

    reg signed [11:0] mem_hid_45;
    wire signed [11:0] pos_in_45 = ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[0]) << 4)
        + ((cochlea_spikes[3]) << 3)
        + ((hid_spikes[10] | hid_spikes[33] | hid_spikes[43] | hid_spikes[45] | hid_spikes[53] | hid_spikes[56]) << 0)
        + ((hid_spikes[10] | hid_spikes[18] | hid_spikes[26] | hid_spikes[33] | hid_spikes[43] | hid_spikes[45] | hid_spikes[49] | hid_spikes[53] | hid_spikes[56]) << 1)
        + ((hid_spikes[26] | hid_spikes[33] | hid_spikes[45] | hid_spikes[49]) << 2)
        + ((hid_spikes[10] | hid_spikes[13] | hid_spikes[24] | hid_spikes[35] | hid_spikes[43]) << 3)
        + ((hid_spikes[54]) << 4);
    wire signed [11:0] neg_in_45 = ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[5]) << 5)
        + ((cochlea_spikes[2]) << 7)
        + ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[1] | cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[1] | cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[1]) << 4)
        + ((cochlea_spikes[4]) << 5)
        + ((hid_spikes[6] | hid_spikes[8] | hid_spikes[9] | hid_spikes[16] | hid_spikes[17] | hid_spikes[22] | hid_spikes[23] | hid_spikes[27] | hid_spikes[28] | hid_spikes[34] | hid_spikes[39] | hid_spikes[44] | hid_spikes[50] | hid_spikes[55] | hid_spikes[59] | hid_spikes[60] | hid_spikes[61]) << 0)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[9] | hid_spikes[15] | hid_spikes[16] | hid_spikes[17] | hid_spikes[27] | hid_spikes[29] | hid_spikes[31] | hid_spikes[34] | hid_spikes[36] | hid_spikes[38] | hid_spikes[39] | hid_spikes[44] | hid_spikes[57] | hid_spikes[58] | hid_spikes[59] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63]) << 1)
        + ((hid_spikes[2] | hid_spikes[5] | hid_spikes[6] | hid_spikes[15] | hid_spikes[22] | hid_spikes[23] | hid_spikes[28] | hid_spikes[29] | hid_spikes[34] | hid_spikes[39] | hid_spikes[41] | hid_spikes[44] | hid_spikes[48] | hid_spikes[50] | hid_spikes[51] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60] | hid_spikes[61]) << 2)
        + ((hid_spikes[14] | hid_spikes[17] | hid_spikes[21] | hid_spikes[23] | hid_spikes[27] | hid_spikes[32] | hid_spikes[42] | hid_spikes[51] | hid_spikes[55]) << 3)
        + ((hid_spikes[8] | hid_spikes[14] | hid_spikes[31] | hid_spikes[58] | hid_spikes[61]) << 4);
    wire signed [11:0] sum_hid_45 = pos_in_45 - neg_in_45;
    assign hid_spikes[45] = (mem_hid_45 >= 10);
    wire signed [11:0] next_hid_45 = mem_hid_45 - (mem_hid_45 >>> 5) + sum_hid_45;

    reg signed [11:0] mem_hid_46;
    wire signed [11:0] pos_in_46 = ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 2)
        + ((hid_spikes[28] | hid_spikes[33] | hid_spikes[37]) << 0)
        + ((hid_spikes[28] | hid_spikes[37] | hid_spikes[59]) << 1)
        + ((hid_spikes[0] | hid_spikes[12] | hid_spikes[33] | hid_spikes[46]) << 2)
        + ((hid_spikes[45]) << 3);
    wire signed [11:0] neg_in_46 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[0] | cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2]) << 2)
        + ((hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[13] | hid_spikes[14] | hid_spikes[20] | hid_spikes[21] | hid_spikes[22] | hid_spikes[23] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[30] | hid_spikes[32] | hid_spikes[36] | hid_spikes[39] | hid_spikes[40] | hid_spikes[42] | hid_spikes[44] | hid_spikes[52] | hid_spikes[54] | hid_spikes[55] | hid_spikes[56] | hid_spikes[60]) << 0)
        + ((hid_spikes[2] | hid_spikes[5] | hid_spikes[6] | hid_spikes[11] | hid_spikes[13] | hid_spikes[17] | hid_spikes[19] | hid_spikes[21] | hid_spikes[23] | hid_spikes[30] | hid_spikes[32] | hid_spikes[38] | hid_spikes[41] | hid_spikes[43] | hid_spikes[53] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[60] | hid_spikes[61]) << 1)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[8] | hid_spikes[11] | hid_spikes[14] | hid_spikes[18] | hid_spikes[19] | hid_spikes[21] | hid_spikes[22] | hid_spikes[23] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[32] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[44] | hid_spikes[47] | hid_spikes[48] | hid_spikes[53] | hid_spikes[55] | hid_spikes[56] | hid_spikes[58] | hid_spikes[60]) << 2)
        + ((hid_spikes[6] | hid_spikes[11] | hid_spikes[14] | hid_spikes[16] | hid_spikes[18] | hid_spikes[20] | hid_spikes[23] | hid_spikes[25] | hid_spikes[26] | hid_spikes[29] | hid_spikes[36] | hid_spikes[40] | hid_spikes[41] | hid_spikes[44] | hid_spikes[52] | hid_spikes[54] | hid_spikes[55] | hid_spikes[56] | hid_spikes[61] | hid_spikes[63]) << 3)
        + ((hid_spikes[3] | hid_spikes[7] | hid_spikes[19] | hid_spikes[39] | hid_spikes[52] | hid_spikes[57]) << 4);
    wire signed [11:0] sum_hid_46 = pos_in_46 - neg_in_46;
    assign hid_spikes[46] = (mem_hid_46 >= 10);
    wire signed [11:0] next_hid_46 = mem_hid_46 - (mem_hid_46 >>> 6) + sum_hid_46;

    reg signed [11:0] mem_hid_47;
    wire signed [11:0] pos_in_47 = ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[0]) << 4)
        + ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[3]) << 4)
        + ((hid_spikes[0] | hid_spikes[16] | hid_spikes[17] | hid_spikes[22] | hid_spikes[24] | hid_spikes[27] | hid_spikes[35] | hid_spikes[37] | hid_spikes[41] | hid_spikes[50] | hid_spikes[54] | hid_spikes[61]) << 0)
        + ((hid_spikes[0] | hid_spikes[16] | hid_spikes[20] | hid_spikes[22] | hid_spikes[24] | hid_spikes[35] | hid_spikes[36] | hid_spikes[41] | hid_spikes[52] | hid_spikes[53] | hid_spikes[54] | hid_spikes[61]) << 1)
        + ((hid_spikes[0] | hid_spikes[17] | hid_spikes[20] | hid_spikes[27] | hid_spikes[35] | hid_spikes[37] | hid_spikes[38] | hid_spikes[41] | hid_spikes[46] | hid_spikes[50]) << 2)
        + ((hid_spikes[24] | hid_spikes[27] | hid_spikes[53]) << 3)
        + ((hid_spikes[35] | hid_spikes[38]) << 4);
    wire signed [11:0] neg_in_47 = ((cochlea_spikes[1] | cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[2] | cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[1] | cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[2]) << 6)
        + ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[5]) << 5)
        + ((hid_spikes[1] | hid_spikes[3] | hid_spikes[4] | hid_spikes[9] | hid_spikes[12] | hid_spikes[21] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[34] | hid_spikes[40] | hid_spikes[42] | hid_spikes[47] | hid_spikes[49] | hid_spikes[51] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60] | hid_spikes[63]) << 0)
        + ((hid_spikes[3] | hid_spikes[4] | hid_spikes[6] | hid_spikes[8] | hid_spikes[11] | hid_spikes[12] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[21] | hid_spikes[25] | hid_spikes[26] | hid_spikes[32] | hid_spikes[34] | hid_spikes[40] | hid_spikes[42] | hid_spikes[44] | hid_spikes[47] | hid_spikes[51]) << 1)
        + ((hid_spikes[6] | hid_spikes[7] | hid_spikes[8] | hid_spikes[9] | hid_spikes[23] | hid_spikes[28] | hid_spikes[30] | hid_spikes[32] | hid_spikes[51] | hid_spikes[57] | hid_spikes[58] | hid_spikes[63]) << 2)
        + ((hid_spikes[1] | hid_spikes[3] | hid_spikes[7] | hid_spikes[8] | hid_spikes[9] | hid_spikes[14] | hid_spikes[19] | hid_spikes[26] | hid_spikes[29] | hid_spikes[32] | hid_spikes[34] | hid_spikes[51] | hid_spikes[57] | hid_spikes[63]) << 3)
        + ((hid_spikes[12] | hid_spikes[49] | hid_spikes[55] | hid_spikes[60]) << 4);
    wire signed [11:0] sum_hid_47 = pos_in_47 - neg_in_47;
    assign hid_spikes[47] = (mem_hid_47 >= 10);
    wire signed [11:0] next_hid_47 = mem_hid_47 - (mem_hid_47 >>> 6) + sum_hid_47;

    reg signed [11:0] mem_hid_48;
    wire signed [11:0] pos_in_48 = ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2] | cochlea_spikes[3]) << 3)
        + ((cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[0]) << 3)
        + ((hid_spikes[8] | hid_spikes[20] | hid_spikes[37] | hid_spikes[50] | hid_spikes[52]) << 0)
        + ((hid_spikes[8] | hid_spikes[22] | hid_spikes[36] | hid_spikes[37] | hid_spikes[52]) << 1)
        + ((hid_spikes[20] | hid_spikes[22] | hid_spikes[37] | hid_spikes[39] | hid_spikes[50]) << 2)
        + ((hid_spikes[22] | hid_spikes[36] | hid_spikes[41]) << 3)
        + ((hid_spikes[10]) << 4);
    wire signed [11:0] neg_in_48 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[1]) << 5)
        + ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[5]) << 4)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[6] | hid_spikes[11] | hid_spikes[13] | hid_spikes[15] | hid_spikes[21] | hid_spikes[23] | hid_spikes[24] | hid_spikes[25] | hid_spikes[30] | hid_spikes[31] | hid_spikes[32] | hid_spikes[33] | hid_spikes[44] | hid_spikes[45] | hid_spikes[48] | hid_spikes[49] | hid_spikes[54] | hid_spikes[58]) << 0)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[6] | hid_spikes[7] | hid_spikes[14] | hid_spikes[23] | hid_spikes[24] | hid_spikes[26] | hid_spikes[32] | hid_spikes[33] | hid_spikes[35] | hid_spikes[42] | hid_spikes[45] | hid_spikes[46] | hid_spikes[51] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57]) << 1)
        + ((hid_spikes[2] | hid_spikes[7] | hid_spikes[11] | hid_spikes[15] | hid_spikes[16] | hid_spikes[21] | hid_spikes[25] | hid_spikes[31] | hid_spikes[32] | hid_spikes[33] | hid_spikes[35] | hid_spikes[44] | hid_spikes[45] | hid_spikes[49] | hid_spikes[51] | hid_spikes[53] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[58] | hid_spikes[59] | hid_spikes[61] | hid_spikes[63]) << 2)
        + ((hid_spikes[3] | hid_spikes[7] | hid_spikes[9] | hid_spikes[13] | hid_spikes[15] | hid_spikes[16] | hid_spikes[17] | hid_spikes[21] | hid_spikes[23] | hid_spikes[26] | hid_spikes[27] | hid_spikes[30] | hid_spikes[33] | hid_spikes[42] | hid_spikes[44] | hid_spikes[48] | hid_spikes[59] | hid_spikes[61] | hid_spikes[63]) << 3)
        + ((hid_spikes[14] | hid_spikes[18] | hid_spikes[25] | hid_spikes[27] | hid_spikes[30] | hid_spikes[40] | hid_spikes[55]) << 4);
    wire signed [11:0] sum_hid_48 = pos_in_48 - neg_in_48;
    assign hid_spikes[48] = (mem_hid_48 >= 10);
    wire signed [11:0] next_hid_48 = mem_hid_48 - (mem_hid_48 >>> 4) + sum_hid_48;

    reg signed [11:0] mem_hid_49;
    wire signed [11:0] pos_in_49 = ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2] | cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 5)
        + ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 3)
        + ((hid_spikes[0] | hid_spikes[7] | hid_spikes[20] | hid_spikes[32] | hid_spikes[33] | hid_spikes[35] | hid_spikes[38] | hid_spikes[42] | hid_spikes[45] | hid_spikes[46] | hid_spikes[56]) << 0)
        + ((hid_spikes[0] | hid_spikes[8] | hid_spikes[20] | hid_spikes[22] | hid_spikes[32] | hid_spikes[35] | hid_spikes[38] | hid_spikes[45] | hid_spikes[46] | hid_spikes[56]) << 1)
        + ((hid_spikes[0] | hid_spikes[8] | hid_spikes[20] | hid_spikes[22] | hid_spikes[34] | hid_spikes[35] | hid_spikes[40] | hid_spikes[42] | hid_spikes[45] | hid_spikes[46]) << 2)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[7] | hid_spikes[8] | hid_spikes[32] | hid_spikes[33] | hid_spikes[34] | hid_spikes[38] | hid_spikes[56]) << 3)
        + ((hid_spikes[40]) << 4);
    wire signed [11:0] neg_in_49 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[1] | cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[1]) << 6)
        + ((cochlea_spikes[3]) << 3)
        + ((cochlea_spikes[3]) << 4)
        + ((hid_spikes[1] | hid_spikes[6] | hid_spikes[14] | hid_spikes[17] | hid_spikes[19] | hid_spikes[21] | hid_spikes[23] | hid_spikes[25] | hid_spikes[27] | hid_spikes[28] | hid_spikes[44] | hid_spikes[48] | hid_spikes[50] | hid_spikes[59]) << 0)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[6] | hid_spikes[10] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[21] | hid_spikes[23] | hid_spikes[24] | hid_spikes[28] | hid_spikes[31] | hid_spikes[36] | hid_spikes[39] | hid_spikes[43] | hid_spikes[44] | hid_spikes[48] | hid_spikes[50] | hid_spikes[55] | hid_spikes[57] | hid_spikes[59] | hid_spikes[60] | hid_spikes[62] | hid_spikes[63]) << 1)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[4] | hid_spikes[6] | hid_spikes[11] | hid_spikes[12] | hid_spikes[14] | hid_spikes[15] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[24] | hid_spikes[25] | hid_spikes[28] | hid_spikes[31] | hid_spikes[41] | hid_spikes[43] | hid_spikes[48] | hid_spikes[49] | hid_spikes[52] | hid_spikes[53] | hid_spikes[54] | hid_spikes[57] | hid_spikes[62]) << 2)
        + ((hid_spikes[2] | hid_spikes[5] | hid_spikes[13] | hid_spikes[15] | hid_spikes[25] | hid_spikes[26] | hid_spikes[29] | hid_spikes[36] | hid_spikes[41] | hid_spikes[43] | hid_spikes[48] | hid_spikes[50] | hid_spikes[52] | hid_spikes[53] | hid_spikes[61] | hid_spikes[63]) << 3)
        + ((hid_spikes[1] | hid_spikes[27] | hid_spikes[49] | hid_spikes[55] | hid_spikes[60]) << 4);
    wire signed [11:0] sum_hid_49 = pos_in_49 - neg_in_49;
    assign hid_spikes[49] = (mem_hid_49 >= 10);
    wire signed [11:0] next_hid_49 = mem_hid_49 - (mem_hid_49 >>> 3) + sum_hid_49;

    reg signed [11:0] mem_hid_50;
    wire signed [11:0] pos_in_50 = ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 6)
        + ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 4)
        + ((hid_spikes[4] | hid_spikes[9] | hid_spikes[18] | hid_spikes[20] | hid_spikes[21] | hid_spikes[28] | hid_spikes[30] | hid_spikes[31] | hid_spikes[38] | hid_spikes[42] | hid_spikes[44] | hid_spikes[46] | hid_spikes[49] | hid_spikes[56]) << 0)
        + ((hid_spikes[20] | hid_spikes[21] | hid_spikes[22] | hid_spikes[38] | hid_spikes[42] | hid_spikes[43] | hid_spikes[49] | hid_spikes[50] | hid_spikes[59]) << 1)
        + ((hid_spikes[7] | hid_spikes[9] | hid_spikes[18] | hid_spikes[21] | hid_spikes[22] | hid_spikes[28] | hid_spikes[30] | hid_spikes[35] | hid_spikes[38] | hid_spikes[40] | hid_spikes[41] | hid_spikes[42] | hid_spikes[44] | hid_spikes[54] | hid_spikes[59]) << 2)
        + ((hid_spikes[1] | hid_spikes[7] | hid_spikes[20] | hid_spikes[22] | hid_spikes[31] | hid_spikes[38] | hid_spikes[56]) << 3)
        + ((hid_spikes[4] | hid_spikes[35] | hid_spikes[46]) << 4);
    wire signed [11:0] neg_in_50 = ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[0] | cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[0]) << 4)
        + ((cochlea_spikes[5]) << 5)
        + ((cochlea_spikes[0]) << 6)
        + ((cochlea_spikes[2] | cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[2] | cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[2]) << 5)
        + ((hid_spikes[14] | hid_spikes[16] | hid_spikes[24] | hid_spikes[29] | hid_spikes[34] | hid_spikes[45] | hid_spikes[47] | hid_spikes[48] | hid_spikes[52] | hid_spikes[55] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60] | hid_spikes[61]) << 0)
        + ((hid_spikes[2] | hid_spikes[6] | hid_spikes[8] | hid_spikes[12] | hid_spikes[13] | hid_spikes[15] | hid_spikes[24] | hid_spikes[25] | hid_spikes[27] | hid_spikes[47] | hid_spikes[48] | hid_spikes[58] | hid_spikes[60]) << 1)
        + ((hid_spikes[2] | hid_spikes[5] | hid_spikes[10] | hid_spikes[12] | hid_spikes[14] | hid_spikes[25] | hid_spikes[34] | hid_spikes[36] | hid_spikes[51] | hid_spikes[55] | hid_spikes[57] | hid_spikes[58] | hid_spikes[61]) << 2)
        + ((hid_spikes[2] | hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[27] | hid_spikes[47] | hid_spikes[52] | hid_spikes[53] | hid_spikes[60] | hid_spikes[61]) << 3)
        + ((hid_spikes[11] | hid_spikes[16] | hid_spikes[29] | hid_spikes[45] | hid_spikes[57]) << 4);
    wire signed [11:0] sum_hid_50 = pos_in_50 - neg_in_50;
    assign hid_spikes[50] = (mem_hid_50 >= 10);
    wire signed [11:0] next_hid_50 = mem_hid_50 - (mem_hid_50 >>> 6) + sum_hid_50;

    reg signed [11:0] mem_hid_51;
    wire signed [11:0] pos_in_51 = ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[2] | cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((hid_spikes[0] | hid_spikes[7] | hid_spikes[16] | hid_spikes[20] | hid_spikes[36] | hid_spikes[38] | hid_spikes[50] | hid_spikes[62]) << 0)
        + ((hid_spikes[16] | hid_spikes[20] | hid_spikes[29] | hid_spikes[36] | hid_spikes[38] | hid_spikes[54] | hid_spikes[56] | hid_spikes[62]) << 1)
        + ((hid_spikes[0] | hid_spikes[7] | hid_spikes[22] | hid_spikes[29] | hid_spikes[36] | hid_spikes[50] | hid_spikes[54] | hid_spikes[56] | hid_spikes[59] | hid_spikes[62]) << 2)
        + ((hid_spikes[38] | hid_spikes[56]) << 3)
        + ((hid_spikes[22]) << 4);
    wire signed [11:0] neg_in_51 = ((cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 3)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 3)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[8] | hid_spikes[14] | hid_spikes[15] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[27] | hid_spikes[31] | hid_spikes[32] | hid_spikes[35] | hid_spikes[37] | hid_spikes[40] | hid_spikes[41] | hid_spikes[42] | hid_spikes[44] | hid_spikes[46] | hid_spikes[47] | hid_spikes[48] | hid_spikes[51] | hid_spikes[55] | hid_spikes[57] | hid_spikes[58] | hid_spikes[63]) << 0)
        + ((hid_spikes[1] | hid_spikes[3] | hid_spikes[10] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[23] | hid_spikes[27] | hid_spikes[30] | hid_spikes[32] | hid_spikes[34] | hid_spikes[37] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[47] | hid_spikes[49] | hid_spikes[51] | hid_spikes[52] | hid_spikes[53] | hid_spikes[55] | hid_spikes[57] | hid_spikes[63]) << 1)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[3] | hid_spikes[4] | hid_spikes[10] | hid_spikes[13] | hid_spikes[14] | hid_spikes[18] | hid_spikes[19] | hid_spikes[24] | hid_spikes[26] | hid_spikes[27] | hid_spikes[31] | hid_spikes[32] | hid_spikes[33] | hid_spikes[40] | hid_spikes[44] | hid_spikes[46] | hid_spikes[52] | hid_spikes[57] | hid_spikes[58] | hid_spikes[61] | hid_spikes[63]) << 2)
        + ((hid_spikes[2] | hid_spikes[11] | hid_spikes[12] | hid_spikes[14] | hid_spikes[15] | hid_spikes[25] | hid_spikes[30] | hid_spikes[31] | hid_spikes[32] | hid_spikes[33] | hid_spikes[37] | hid_spikes[41] | hid_spikes[44] | hid_spikes[48] | hid_spikes[49] | hid_spikes[51] | hid_spikes[52] | hid_spikes[55] | hid_spikes[61]) << 3)
        + ((hid_spikes[6] | hid_spikes[8] | hid_spikes[13] | hid_spikes[14] | hid_spikes[35] | hid_spikes[37] | hid_spikes[42] | hid_spikes[45] | hid_spikes[51] | hid_spikes[53] | hid_spikes[61]) << 4);
    wire signed [11:0] sum_hid_51 = pos_in_51 - neg_in_51;
    assign hid_spikes[51] = (mem_hid_51 >= 10);
    wire signed [11:0] next_hid_51 = mem_hid_51 - (mem_hid_51 >>> 6) + sum_hid_51;

    reg signed [11:0] mem_hid_52;
    wire signed [11:0] pos_in_52 = ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1] | cochlea_spikes[3]) << 4)
        + ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[5]) << 4)
        + ((hid_spikes[3] | hid_spikes[4] | hid_spikes[10] | hid_spikes[15] | hid_spikes[20] | hid_spikes[21] | hid_spikes[56] | hid_spikes[58] | hid_spikes[59]) << 0)
        + ((hid_spikes[3] | hid_spikes[9] | hid_spikes[10] | hid_spikes[15] | hid_spikes[26] | hid_spikes[34] | hid_spikes[46] | hid_spikes[47] | hid_spikes[56] | hid_spikes[58]) << 1)
        + ((hid_spikes[4] | hid_spikes[7] | hid_spikes[9] | hid_spikes[10] | hid_spikes[15] | hid_spikes[16] | hid_spikes[20] | hid_spikes[21] | hid_spikes[22] | hid_spikes[26] | hid_spikes[31] | hid_spikes[32] | hid_spikes[34] | hid_spikes[35] | hid_spikes[36] | hid_spikes[38] | hid_spikes[39] | hid_spikes[46] | hid_spikes[55] | hid_spikes[56]) << 2)
        + ((hid_spikes[21] | hid_spikes[22] | hid_spikes[42] | hid_spikes[58] | hid_spikes[59]) << 3);
    wire signed [11:0] neg_in_52 = ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 4)
        + ((cochlea_spikes[0]) << 6)
        + ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[4]) << 5)
        + ((hid_spikes[5] | hid_spikes[25] | hid_spikes[33] | hid_spikes[37] | hid_spikes[48] | hid_spikes[49] | hid_spikes[51] | hid_spikes[53] | hid_spikes[61] | hid_spikes[63]) << 0)
        + ((hid_spikes[2] | hid_spikes[5] | hid_spikes[6] | hid_spikes[13] | hid_spikes[17] | hid_spikes[27] | hid_spikes[28] | hid_spikes[37] | hid_spikes[41] | hid_spikes[48] | hid_spikes[50] | hid_spikes[51] | hid_spikes[53] | hid_spikes[61]) << 1)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[11] | hid_spikes[12] | hid_spikes[24] | hid_spikes[30] | hid_spikes[33] | hid_spikes[41] | hid_spikes[45] | hid_spikes[49] | hid_spikes[52] | hid_spikes[53] | hid_spikes[54] | hid_spikes[57] | hid_spikes[63]) << 2)
        + ((hid_spikes[1] | hid_spikes[6] | hid_spikes[24] | hid_spikes[25] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[52] | hid_spikes[63]) << 3)
        + ((hid_spikes[0] | hid_spikes[19]) << 4);
    wire signed [11:0] sum_hid_52 = pos_in_52 - neg_in_52;
    assign hid_spikes[52] = (mem_hid_52 >= 10);
    wire signed [11:0] next_hid_52 = mem_hid_52 - (mem_hid_52 >>> 6) + sum_hid_52;

    reg signed [11:0] mem_hid_53;
    wire signed [11:0] pos_in_53 = ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 2)
        + ((hid_spikes[0] | hid_spikes[7] | hid_spikes[26] | hid_spikes[32] | hid_spikes[34] | hid_spikes[38] | hid_spikes[46] | hid_spikes[56]) << 0)
        + ((hid_spikes[0] | hid_spikes[2] | hid_spikes[10] | hid_spikes[21] | hid_spikes[26] | hid_spikes[35] | hid_spikes[46] | hid_spikes[56] | hid_spikes[61]) << 1)
        + ((hid_spikes[7] | hid_spikes[25] | hid_spikes[26] | hid_spikes[27] | hid_spikes[32] | hid_spikes[34] | hid_spikes[38] | hid_spikes[56] | hid_spikes[59]) << 2)
        + ((hid_spikes[21] | hid_spikes[25] | hid_spikes[34] | hid_spikes[38] | hid_spikes[55] | hid_spikes[56]) << 3)
        + ((hid_spikes[46]) << 4);
    wire signed [11:0] neg_in_53 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 5)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[4]) << 4)
        + ((hid_spikes[6] | hid_spikes[9] | hid_spikes[13] | hid_spikes[14] | hid_spikes[16] | hid_spikes[18] | hid_spikes[28] | hid_spikes[30] | hid_spikes[36] | hid_spikes[39] | hid_spikes[41] | hid_spikes[43] | hid_spikes[47] | hid_spikes[51] | hid_spikes[52] | hid_spikes[60] | hid_spikes[63]) << 0)
        + ((hid_spikes[6] | hid_spikes[9] | hid_spikes[11] | hid_spikes[14] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[28] | hid_spikes[36] | hid_spikes[37] | hid_spikes[39] | hid_spikes[40] | hid_spikes[41] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[49] | hid_spikes[51] | hid_spikes[52] | hid_spikes[57] | hid_spikes[60] | hid_spikes[62] | hid_spikes[63]) << 1)
        + ((hid_spikes[6] | hid_spikes[8] | hid_spikes[13] | hid_spikes[14] | hid_spikes[16] | hid_spikes[17] | hid_spikes[19] | hid_spikes[30] | hid_spikes[31] | hid_spikes[40] | hid_spikes[42] | hid_spikes[45] | hid_spikes[47] | hid_spikes[48] | hid_spikes[50] | hid_spikes[53] | hid_spikes[58] | hid_spikes[62]) << 2)
        + ((hid_spikes[5] | hid_spikes[6] | hid_spikes[9] | hid_spikes[11] | hid_spikes[13] | hid_spikes[18] | hid_spikes[30] | hid_spikes[31] | hid_spikes[37] | hid_spikes[39] | hid_spikes[44] | hid_spikes[45] | hid_spikes[48] | hid_spikes[50] | hid_spikes[51] | hid_spikes[52] | hid_spikes[57] | hid_spikes[60] | hid_spikes[63]) << 3)
        + ((hid_spikes[14] | hid_spikes[24] | hid_spikes[52] | hid_spikes[62]) << 4);
    wire signed [11:0] sum_hid_53 = pos_in_53 - neg_in_53;
    assign hid_spikes[53] = (mem_hid_53 >= 10);
    wire signed [11:0] next_hid_53 = mem_hid_53 - (mem_hid_53 >>> 6) + sum_hid_53;

    reg signed [11:0] mem_hid_54;
    wire signed [11:0] pos_in_54 = ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 4)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[3]) << 3)
        + ((hid_spikes[10] | hid_spikes[20] | hid_spikes[23] | hid_spikes[27] | hid_spikes[31] | hid_spikes[38] | hid_spikes[50]) << 0)
        + ((hid_spikes[12] | hid_spikes[27] | hid_spikes[31] | hid_spikes[38] | hid_spikes[56]) << 1)
        + ((hid_spikes[2] | hid_spikes[10] | hid_spikes[12] | hid_spikes[20] | hid_spikes[22] | hid_spikes[29] | hid_spikes[34] | hid_spikes[48]) << 2)
        + ((hid_spikes[10] | hid_spikes[23] | hid_spikes[31] | hid_spikes[34] | hid_spikes[40] | hid_spikes[50] | hid_spikes[56] | hid_spikes[58]) << 3)
        + ((hid_spikes[20] | hid_spikes[22] | hid_spikes[38]) << 4);
    wire signed [11:0] neg_in_54 = ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2]) << 5)
        + ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[5]) << 3)
        + ((hid_spikes[9] | hid_spikes[14] | hid_spikes[17] | hid_spikes[19] | hid_spikes[25] | hid_spikes[26] | hid_spikes[35] | hid_spikes[36] | hid_spikes[37] | hid_spikes[41] | hid_spikes[45] | hid_spikes[51] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[62]) << 0)
        + ((hid_spikes[5] | hid_spikes[9] | hid_spikes[16] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[24] | hid_spikes[25] | hid_spikes[26] | hid_spikes[33] | hid_spikes[35] | hid_spikes[36] | hid_spikes[37] | hid_spikes[41] | hid_spikes[46] | hid_spikes[53] | hid_spikes[54] | hid_spikes[55] | hid_spikes[61] | hid_spikes[62]) << 1)
        + ((hid_spikes[0] | hid_spikes[5] | hid_spikes[8] | hid_spikes[24] | hid_spikes[30] | hid_spikes[32] | hid_spikes[33] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[53] | hid_spikes[54]) << 2)
        + ((hid_spikes[14] | hid_spikes[17] | hid_spikes[19] | hid_spikes[28] | hid_spikes[30] | hid_spikes[33] | hid_spikes[42] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[51] | hid_spikes[53] | hid_spikes[55] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63]) << 3)
        + ((hid_spikes[37] | hid_spikes[41]) << 4);
    wire signed [11:0] sum_hid_54 = pos_in_54 - neg_in_54;
    assign hid_spikes[54] = (mem_hid_54 >= 10);
    wire signed [11:0] next_hid_54 = mem_hid_54 - (mem_hid_54 >>> 6) + sum_hid_54;

    reg signed [11:0] mem_hid_55;
    wire signed [11:0] pos_in_55 = ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[1] | cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[4]) << 5)
        + ((cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 2)
        + ((hid_spikes[32] | hid_spikes[33] | hid_spikes[44] | hid_spikes[60] | hid_spikes[62]) << 0)
        + ((hid_spikes[7] | hid_spikes[15] | hid_spikes[21] | hid_spikes[33] | hid_spikes[44] | hid_spikes[60]) << 1)
        + ((hid_spikes[10] | hid_spikes[32] | hid_spikes[33] | hid_spikes[60] | hid_spikes[62]) << 2);
    wire signed [11:0] neg_in_55 = ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[2]) << 5)
        + ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 2)
        + ((hid_spikes[5] | hid_spikes[13] | hid_spikes[16] | hid_spikes[23] | hid_spikes[26] | hid_spikes[29] | hid_spikes[31] | hid_spikes[34] | hid_spikes[35] | hid_spikes[39] | hid_spikes[42] | hid_spikes[48] | hid_spikes[51] | hid_spikes[58] | hid_spikes[59]) << 0)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[5] | hid_spikes[8] | hid_spikes[12] | hid_spikes[13] | hid_spikes[14] | hid_spikes[18] | hid_spikes[25] | hid_spikes[26] | hid_spikes[28] | hid_spikes[34] | hid_spikes[41] | hid_spikes[42] | hid_spikes[43] | hid_spikes[47] | hid_spikes[48] | hid_spikes[51] | hid_spikes[53] | hid_spikes[61] | hid_spikes[63]) << 1)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[5] | hid_spikes[8] | hid_spikes[17] | hid_spikes[26] | hid_spikes[27] | hid_spikes[29] | hid_spikes[31] | hid_spikes[36] | hid_spikes[37] | hid_spikes[39] | hid_spikes[45] | hid_spikes[46] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[51] | hid_spikes[53] | hid_spikes[55] | hid_spikes[57]) << 2)
        + ((hid_spikes[2] | hid_spikes[5] | hid_spikes[6] | hid_spikes[13] | hid_spikes[16] | hid_spikes[20] | hid_spikes[22] | hid_spikes[23] | hid_spikes[34] | hid_spikes[42] | hid_spikes[45] | hid_spikes[53] | hid_spikes[58] | hid_spikes[59] | hid_spikes[61] | hid_spikes[63]) << 3)
        + ((hid_spikes[1] | hid_spikes[8] | hid_spikes[12] | hid_spikes[14] | hid_spikes[18] | hid_spikes[28] | hid_spikes[29] | hid_spikes[35] | hid_spikes[41] | hid_spikes[48] | hid_spikes[50] | hid_spikes[61] | hid_spikes[63]) << 4);
    wire signed [11:0] sum_hid_55 = pos_in_55 - neg_in_55;
    assign hid_spikes[55] = (mem_hid_55 >= 10);
    wire signed [11:0] next_hid_55 = mem_hid_55 - (mem_hid_55 >>> 6) + sum_hid_55;

    reg signed [11:0] mem_hid_56;
    wire signed [11:0] pos_in_56 = ((cochlea_spikes[1]) << 3)
        + ((cochlea_spikes[1]) << 5)
        + ((cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[3]) << 3)
        + ((cochlea_spikes[3]) << 4)
        + ((hid_spikes[1] | hid_spikes[7] | hid_spikes[10] | hid_spikes[16] | hid_spikes[22] | hid_spikes[24] | hid_spikes[26] | hid_spikes[34] | hid_spikes[42] | hid_spikes[46] | hid_spikes[56]) << 0)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[26] | hid_spikes[38] | hid_spikes[45] | hid_spikes[56]) << 1)
        + ((hid_spikes[1] | hid_spikes[4] | hid_spikes[7] | hid_spikes[16] | hid_spikes[24] | hid_spikes[26] | hid_spikes[33] | hid_spikes[34] | hid_spikes[35] | hid_spikes[42] | hid_spikes[46] | hid_spikes[47] | hid_spikes[49] | hid_spikes[56]) << 2)
        + ((hid_spikes[2] | hid_spikes[4] | hid_spikes[10] | hid_spikes[18] | hid_spikes[22] | hid_spikes[35]) << 3)
        + ((hid_spikes[22] | hid_spikes[38]) << 4);
    wire signed [11:0] neg_in_56 = ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[0] | cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[0]) << 4)
        + ((cochlea_spikes[0]) << 5)
        + ((cochlea_spikes[0] | cochlea_spikes[5]) << 6)
        + ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2] | cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2] | cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[4]) << 5)
        + ((cochlea_spikes[2]) << 6)
        + ((hid_spikes[3] | hid_spikes[8] | hid_spikes[9] | hid_spikes[11] | hid_spikes[17] | hid_spikes[23] | hid_spikes[36] | hid_spikes[43] | hid_spikes[44] | hid_spikes[50] | hid_spikes[51] | hid_spikes[59] | hid_spikes[60]) << 0)
        + ((hid_spikes[8] | hid_spikes[9] | hid_spikes[11] | hid_spikes[12] | hid_spikes[17] | hid_spikes[19] | hid_spikes[28] | hid_spikes[40] | hid_spikes[41] | hid_spikes[48] | hid_spikes[55] | hid_spikes[58] | hid_spikes[60] | hid_spikes[61] | hid_spikes[63]) << 1)
        + ((hid_spikes[0] | hid_spikes[3] | hid_spikes[8] | hid_spikes[12] | hid_spikes[13] | hid_spikes[14] | hid_spikes[19] | hid_spikes[23] | hid_spikes[29] | hid_spikes[36] | hid_spikes[41] | hid_spikes[43] | hid_spikes[44] | hid_spikes[50] | hid_spikes[51] | hid_spikes[55] | hid_spikes[60] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63]) << 2)
        + ((hid_spikes[15] | hid_spikes[17] | hid_spikes[19] | hid_spikes[20] | hid_spikes[28] | hid_spikes[29] | hid_spikes[36] | hid_spikes[43] | hid_spikes[48] | hid_spikes[59] | hid_spikes[62]) << 3)
        + ((hid_spikes[12] | hid_spikes[25] | hid_spikes[50]) << 4);
    wire signed [11:0] sum_hid_56 = pos_in_56 - neg_in_56;
    assign hid_spikes[56] = (mem_hid_56 >= 10);
    wire signed [11:0] next_hid_56 = mem_hid_56 - (mem_hid_56 >>> 5) + sum_hid_56;

    reg signed [11:0] mem_hid_57;
    wire signed [11:0] pos_in_57 = ((cochlea_spikes[5]) << 2)
        + ((hid_spikes[15] | hid_spikes[37] | hid_spikes[53] | hid_spikes[54] | hid_spikes[56] | hid_spikes[61]) << 0)
        + ((hid_spikes[15] | hid_spikes[42] | hid_spikes[48] | hid_spikes[53] | hid_spikes[54] | hid_spikes[58] | hid_spikes[61]) << 1)
        + ((hid_spikes[37] | hid_spikes[42] | hid_spikes[46] | hid_spikes[48] | hid_spikes[51] | hid_spikes[56] | hid_spikes[59] | hid_spikes[61]) << 2)
        + ((hid_spikes[37] | hid_spikes[42] | hid_spikes[48] | hid_spikes[51]) << 3);
    wire signed [11:0] neg_in_57 = ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[4]) << 5)
        + ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[1] | cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[1]) << 5)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[2] | hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[7] | hid_spikes[10] | hid_spikes[13] | hid_spikes[14] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[21] | hid_spikes[27] | hid_spikes[29] | hid_spikes[31] | hid_spikes[35] | hid_spikes[36] | hid_spikes[39] | hid_spikes[40] | hid_spikes[43] | hid_spikes[47] | hid_spikes[49] | hid_spikes[50] | hid_spikes[63]) << 0)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[4] | hid_spikes[5] | hid_spikes[7] | hid_spikes[13] | hid_spikes[16] | hid_spikes[18] | hid_spikes[23] | hid_spikes[29] | hid_spikes[31] | hid_spikes[32] | hid_spikes[35] | hid_spikes[39] | hid_spikes[49] | hid_spikes[52] | hid_spikes[55] | hid_spikes[57]) << 1)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[2] | hid_spikes[5] | hid_spikes[6] | hid_spikes[13] | hid_spikes[17] | hid_spikes[24] | hid_spikes[27] | hid_spikes[30] | hid_spikes[34] | hid_spikes[39] | hid_spikes[41] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[52] | hid_spikes[55]) << 2)
        + ((hid_spikes[3] | hid_spikes[6] | hid_spikes[8] | hid_spikes[9] | hid_spikes[10] | hid_spikes[14] | hid_spikes[16] | hid_spikes[20] | hid_spikes[21] | hid_spikes[24] | hid_spikes[31] | hid_spikes[34] | hid_spikes[35] | hid_spikes[40] | hid_spikes[45] | hid_spikes[47] | hid_spikes[49] | hid_spikes[50] | hid_spikes[63]) << 3)
        + ((hid_spikes[4] | hid_spikes[7] | hid_spikes[19] | hid_spikes[32] | hid_spikes[36] | hid_spikes[39] | hid_spikes[44]) << 4);
    wire signed [11:0] sum_hid_57 = pos_in_57 - neg_in_57;
    assign hid_spikes[57] = (mem_hid_57 >= 10);
    wire signed [11:0] next_hid_57 = mem_hid_57 - (mem_hid_57 >>> 3) + sum_hid_57;

    reg signed [11:0] mem_hid_58;
    wire signed [11:0] pos_in_58 = ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2]) << 5)
        + ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 4)
        + ((hid_spikes[7] | hid_spikes[13] | hid_spikes[17] | hid_spikes[20] | hid_spikes[23] | hid_spikes[36] | hid_spikes[41] | hid_spikes[47] | hid_spikes[56] | hid_spikes[61] | hid_spikes[63]) << 0)
        + ((hid_spikes[2] | hid_spikes[13] | hid_spikes[17] | hid_spikes[21] | hid_spikes[23] | hid_spikes[24] | hid_spikes[36] | hid_spikes[38] | hid_spikes[47] | hid_spikes[61] | hid_spikes[63]) << 1)
        + ((hid_spikes[1] | hid_spikes[2] | hid_spikes[7] | hid_spikes[13] | hid_spikes[16] | hid_spikes[23] | hid_spikes[33] | hid_spikes[37] | hid_spikes[46] | hid_spikes[48] | hid_spikes[61]) << 2)
        + ((hid_spikes[38] | hid_spikes[39] | hid_spikes[41] | hid_spikes[56]) << 3)
        + ((hid_spikes[3] | hid_spikes[13] | hid_spikes[20] | hid_spikes[27]) << 4);
    wire signed [11:0] neg_in_58 = ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 3)
        + ((cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[5]) << 5)
        + ((cochlea_spikes[0] | cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[0]) << 5)
        + ((hid_spikes[9] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[35] | hid_spikes[49] | hid_spikes[52] | hid_spikes[57]) << 0)
        + ((hid_spikes[5] | hid_spikes[8] | hid_spikes[15] | hid_spikes[19] | hid_spikes[30] | hid_spikes[31] | hid_spikes[40] | hid_spikes[44] | hid_spikes[45] | hid_spikes[54] | hid_spikes[60] | hid_spikes[62]) << 1)
        + ((hid_spikes[8] | hid_spikes[35] | hid_spikes[40] | hid_spikes[45] | hid_spikes[49] | hid_spikes[54] | hid_spikes[62]) << 2)
        + ((hid_spikes[5] | hid_spikes[6] | hid_spikes[9] | hid_spikes[14] | hid_spikes[26] | hid_spikes[30] | hid_spikes[52] | hid_spikes[53] | hid_spikes[57] | hid_spikes[59]) << 3)
        + ((hid_spikes[62]) << 4);
    wire signed [11:0] sum_hid_58 = pos_in_58 - neg_in_58;
    assign hid_spikes[58] = (mem_hid_58 >= 10);
    wire signed [11:0] next_hid_58 = mem_hid_58 - (mem_hid_58 >>> 3) + sum_hid_58;

    reg signed [11:0] mem_hid_59;
    wire signed [11:0] pos_in_59 = ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 2)
        + ((hid_spikes[4] | hid_spikes[5] | hid_spikes[9] | hid_spikes[13] | hid_spikes[16] | hid_spikes[17] | hid_spikes[20] | hid_spikes[23] | hid_spikes[31] | hid_spikes[33] | hid_spikes[38] | hid_spikes[43] | hid_spikes[45] | hid_spikes[50] | hid_spikes[59]) << 0)
        + ((hid_spikes[5] | hid_spikes[9] | hid_spikes[13] | hid_spikes[16] | hid_spikes[22] | hid_spikes[23] | hid_spikes[33] | hid_spikes[35] | hid_spikes[36] | hid_spikes[40] | hid_spikes[42] | hid_spikes[43] | hid_spikes[50] | hid_spikes[59]) << 1)
        + ((hid_spikes[0] | hid_spikes[1] | hid_spikes[4] | hid_spikes[9] | hid_spikes[20] | hid_spikes[23] | hid_spikes[31] | hid_spikes[35] | hid_spikes[36] | hid_spikes[45]) << 2)
        + ((hid_spikes[4] | hid_spikes[9] | hid_spikes[20] | hid_spikes[23] | hid_spikes[33] | hid_spikes[35] | hid_spikes[38] | hid_spikes[40] | hid_spikes[45] | hid_spikes[46] | hid_spikes[56] | hid_spikes[59]) << 3)
        + ((hid_spikes[17] | hid_spikes[22] | hid_spikes[50]) << 4);
    wire signed [11:0] neg_in_59 = ((cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[5]) << 4)
        + ((cochlea_spikes[0] | cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[6] | hid_spikes[8] | hid_spikes[11] | hid_spikes[14] | hid_spikes[19] | hid_spikes[24] | hid_spikes[25] | hid_spikes[28] | hid_spikes[29] | hid_spikes[30] | hid_spikes[34] | hid_spikes[39] | hid_spikes[48] | hid_spikes[55] | hid_spikes[58] | hid_spikes[61]) << 0)
        + ((hid_spikes[7] | hid_spikes[8] | hid_spikes[14] | hid_spikes[19] | hid_spikes[21] | hid_spikes[25] | hid_spikes[28] | hid_spikes[53] | hid_spikes[54] | hid_spikes[57] | hid_spikes[58] | hid_spikes[60] | hid_spikes[61] | hid_spikes[62]) << 1)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[6] | hid_spikes[14] | hid_spikes[21] | hid_spikes[24] | hid_spikes[26] | hid_spikes[27] | hid_spikes[28] | hid_spikes[30] | hid_spikes[34] | hid_spikes[39] | hid_spikes[54] | hid_spikes[55] | hid_spikes[57] | hid_spikes[60] | hid_spikes[61]) << 2)
        + ((hid_spikes[8] | hid_spikes[11] | hid_spikes[14] | hid_spikes[18] | hid_spikes[19] | hid_spikes[25] | hid_spikes[29] | hid_spikes[32] | hid_spikes[37] | hid_spikes[48] | hid_spikes[52] | hid_spikes[54] | hid_spikes[57] | hid_spikes[58] | hid_spikes[61]) << 3)
        + ((hid_spikes[2] | hid_spikes[6] | hid_spikes[28] | hid_spikes[32] | hid_spikes[34] | hid_spikes[44] | hid_spikes[48] | hid_spikes[49] | hid_spikes[51]) << 4);
    wire signed [11:0] sum_hid_59 = pos_in_59 - neg_in_59;
    assign hid_spikes[59] = (mem_hid_59 >= 10);
    wire signed [11:0] next_hid_59 = mem_hid_59 - (mem_hid_59 >>> 6) + sum_hid_59;

    reg signed [11:0] mem_hid_60;
    wire signed [11:0] pos_in_60 = ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[3]) << 4)
        + ((cochlea_spikes[4]) << 5)
        + ((cochlea_spikes[1]) << 0)
        + ((cochlea_spikes[1]) << 5)
        + ((hid_spikes[5] | hid_spikes[20] | hid_spikes[22] | hid_spikes[23] | hid_spikes[31] | hid_spikes[32] | hid_spikes[42] | hid_spikes[47] | hid_spikes[52] | hid_spikes[56]) << 0)
        + ((hid_spikes[7] | hid_spikes[20] | hid_spikes[23] | hid_spikes[24] | hid_spikes[32] | hid_spikes[35] | hid_spikes[38] | hid_spikes[47] | hid_spikes[52] | hid_spikes[54]) << 1)
        + ((hid_spikes[4] | hid_spikes[5] | hid_spikes[7] | hid_spikes[20] | hid_spikes[22] | hid_spikes[23] | hid_spikes[24] | hid_spikes[32] | hid_spikes[35] | hid_spikes[42] | hid_spikes[47] | hid_spikes[48] | hid_spikes[54] | hid_spikes[56] | hid_spikes[57] | hid_spikes[59]) << 2)
        + ((hid_spikes[0] | hid_spikes[12] | hid_spikes[20] | hid_spikes[31] | hid_spikes[35] | hid_spikes[38] | hid_spikes[56] | hid_spikes[57]) << 3)
        + ((hid_spikes[3] | hid_spikes[4] | hid_spikes[5] | hid_spikes[21]) << 4);
    wire signed [11:0] neg_in_60 = ((cochlea_spikes[0] | cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[5]) << 3)
        + ((cochlea_spikes[0]) << 4)
        + ((cochlea_spikes[5]) << 5)
        + ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[2]) << 1)
        + ((cochlea_spikes[2]) << 5)
        + ((hid_spikes[6] | hid_spikes[8] | hid_spikes[9] | hid_spikes[19] | hid_spikes[25] | hid_spikes[30] | hid_spikes[39] | hid_spikes[41] | hid_spikes[43] | hid_spikes[45] | hid_spikes[49] | hid_spikes[53]) << 0)
        + ((hid_spikes[6] | hid_spikes[8] | hid_spikes[10] | hid_spikes[17] | hid_spikes[18] | hid_spikes[19] | hid_spikes[25] | hid_spikes[36] | hid_spikes[41] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[49] | hid_spikes[53]) << 1)
        + ((hid_spikes[2] | hid_spikes[8] | hid_spikes[9] | hid_spikes[10] | hid_spikes[14] | hid_spikes[25] | hid_spikes[26] | hid_spikes[29] | hid_spikes[36] | hid_spikes[39] | hid_spikes[41] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[49] | hid_spikes[53] | hid_spikes[63]) << 2)
        + ((hid_spikes[16] | hid_spikes[19] | hid_spikes[30] | hid_spikes[46] | hid_spikes[50] | hid_spikes[53]) << 3)
        + ((hid_spikes[49] | hid_spikes[50] | hid_spikes[63]) << 4);
    wire signed [11:0] sum_hid_60 = pos_in_60 - neg_in_60;
    assign hid_spikes[60] = (mem_hid_60 >= 10);
    wire signed [11:0] next_hid_60 = mem_hid_60 - (mem_hid_60 >>> 6) + sum_hid_60;

    reg signed [11:0] mem_hid_61;
    wire signed [11:0] pos_in_61 = ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[0] | cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[1] | cochlea_spikes[5]) << 3)
        + ((hid_spikes[7] | hid_spikes[20] | hid_spikes[27] | hid_spikes[42] | hid_spikes[56]) << 0)
        + ((hid_spikes[7] | hid_spikes[17] | hid_spikes[20] | hid_spikes[21] | hid_spikes[27] | hid_spikes[29] | hid_spikes[31] | hid_spikes[42] | hid_spikes[46] | hid_spikes[59]) << 1)
        + ((hid_spikes[1] | hid_spikes[7] | hid_spikes[20] | hid_spikes[23] | hid_spikes[24] | hid_spikes[38] | hid_spikes[46] | hid_spikes[50] | hid_spikes[59]) << 2)
        + ((hid_spikes[16] | hid_spikes[38] | hid_spikes[56]) << 3);
    wire signed [11:0] neg_in_61 = ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[4]) << 4)
        + ((cochlea_spikes[4]) << 6)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 4)
        + ((hid_spikes[8] | hid_spikes[10] | hid_spikes[12] | hid_spikes[13] | hid_spikes[18] | hid_spikes[22] | hid_spikes[25] | hid_spikes[30] | hid_spikes[32] | hid_spikes[34] | hid_spikes[35] | hid_spikes[36] | hid_spikes[40] | hid_spikes[43] | hid_spikes[44] | hid_spikes[48] | hid_spikes[49] | hid_spikes[57] | hid_spikes[62]) << 0)
        + ((hid_spikes[3] | hid_spikes[5] | hid_spikes[9] | hid_spikes[10] | hid_spikes[12] | hid_spikes[14] | hid_spikes[18] | hid_spikes[19] | hid_spikes[22] | hid_spikes[28] | hid_spikes[32] | hid_spikes[36] | hid_spikes[40] | hid_spikes[41] | hid_spikes[45] | hid_spikes[47] | hid_spikes[48] | hid_spikes[49] | hid_spikes[51] | hid_spikes[57] | hid_spikes[58] | hid_spikes[62]) << 1)
        + ((hid_spikes[2] | hid_spikes[6] | hid_spikes[13] | hid_spikes[14] | hid_spikes[18] | hid_spikes[22] | hid_spikes[25] | hid_spikes[26] | hid_spikes[30] | hid_spikes[32] | hid_spikes[34] | hid_spikes[36] | hid_spikes[39] | hid_spikes[43] | hid_spikes[44] | hid_spikes[45] | hid_spikes[47] | hid_spikes[49] | hid_spikes[53] | hid_spikes[58] | hid_spikes[61] | hid_spikes[62] | hid_spikes[63]) << 2)
        + ((hid_spikes[2] | hid_spikes[3] | hid_spikes[5] | hid_spikes[6] | hid_spikes[8] | hid_spikes[10] | hid_spikes[19] | hid_spikes[26] | hid_spikes[33] | hid_spikes[35] | hid_spikes[36] | hid_spikes[39] | hid_spikes[40] | hid_spikes[43] | hid_spikes[48] | hid_spikes[57] | hid_spikes[63]) << 3)
        + ((hid_spikes[14] | hid_spikes[19] | hid_spikes[28] | hid_spikes[41] | hid_spikes[51] | hid_spikes[61] | hid_spikes[62]) << 4);
    wire signed [11:0] sum_hid_61 = pos_in_61 - neg_in_61;
    assign hid_spikes[61] = (mem_hid_61 >= 10);
    wire signed [11:0] next_hid_61 = mem_hid_61 - (mem_hid_61 >>> 6) + sum_hid_61;

    reg signed [11:0] mem_hid_62;
    wire signed [11:0] pos_in_62 = ((cochlea_spikes[0]) << 1)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[0]) << 4)
        + ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[5]) << 2)
        + ((hid_spikes[3] | hid_spikes[4] | hid_spikes[10] | hid_spikes[31] | hid_spikes[38] | hid_spikes[42] | hid_spikes[59]) << 0)
        + ((hid_spikes[7] | hid_spikes[11] | hid_spikes[22] | hid_spikes[26] | hid_spikes[34] | hid_spikes[38] | hid_spikes[40] | hid_spikes[42] | hid_spikes[54]) << 1)
        + ((hid_spikes[0] | hid_spikes[4] | hid_spikes[15] | hid_spikes[18] | hid_spikes[22] | hid_spikes[29] | hid_spikes[31] | hid_spikes[34] | hid_spikes[38] | hid_spikes[40] | hid_spikes[42] | hid_spikes[47] | hid_spikes[54] | hid_spikes[56] | hid_spikes[63]) << 2)
        + ((hid_spikes[3] | hid_spikes[4] | hid_spikes[10] | hid_spikes[18] | hid_spikes[20] | hid_spikes[22] | hid_spikes[26] | hid_spikes[30] | hid_spikes[31] | hid_spikes[34] | hid_spikes[42] | hid_spikes[47] | hid_spikes[56] | hid_spikes[59]) << 3)
        + ((hid_spikes[11]) << 4);
    wire signed [11:0] neg_in_62 = ((cochlea_spikes[2]) << 0)
        + ((cochlea_spikes[1]) << 1)
        + ((cochlea_spikes[1]) << 2)
        + ((cochlea_spikes[1] | cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[1] | cochlea_spikes[2]) << 4)
        + ((cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[3]) << 2)
        + ((cochlea_spikes[3] | cochlea_spikes[4]) << 3)
        + ((cochlea_spikes[3]) << 4)
        + ((hid_spikes[5] | hid_spikes[6] | hid_spikes[13] | hid_spikes[16] | hid_spikes[17] | hid_spikes[23] | hid_spikes[24] | hid_spikes[37] | hid_spikes[41] | hid_spikes[44] | hid_spikes[45] | hid_spikes[50] | hid_spikes[55] | hid_spikes[61]) << 0)
        + ((hid_spikes[5] | hid_spikes[6] | hid_spikes[13] | hid_spikes[21] | hid_spikes[25] | hid_spikes[28] | hid_spikes[35] | hid_spikes[36] | hid_spikes[39] | hid_spikes[44] | hid_spikes[48] | hid_spikes[52] | hid_spikes[53] | hid_spikes[57] | hid_spikes[61] | hid_spikes[62]) << 1)
        + ((hid_spikes[1] | hid_spikes[6] | hid_spikes[13] | hid_spikes[14] | hid_spikes[16] | hid_spikes[23] | hid_spikes[24] | hid_spikes[25] | hid_spikes[27] | hid_spikes[35] | hid_spikes[37] | hid_spikes[43] | hid_spikes[44] | hid_spikes[46] | hid_spikes[48] | hid_spikes[52] | hid_spikes[53] | hid_spikes[55] | hid_spikes[62]) << 2)
        + ((hid_spikes[8] | hid_spikes[16] | hid_spikes[17] | hid_spikes[19] | hid_spikes[24] | hid_spikes[25] | hid_spikes[28] | hid_spikes[33] | hid_spikes[37] | hid_spikes[44] | hid_spikes[50] | hid_spikes[55] | hid_spikes[57]) << 3)
        + ((hid_spikes[5] | hid_spikes[14] | hid_spikes[24] | hid_spikes[41] | hid_spikes[45]) << 4);
    wire signed [11:0] sum_hid_62 = pos_in_62 - neg_in_62;
    assign hid_spikes[62] = (mem_hid_62 >= 10);
    wire signed [11:0] next_hid_62 = mem_hid_62 - (mem_hid_62 >>> 5) + sum_hid_62;

    reg signed [11:0] mem_hid_63;
    wire signed [11:0] pos_in_63 = ((cochlea_spikes[0]) << 0)
        + ((cochlea_spikes[0]) << 2)
        + ((cochlea_spikes[0]) << 3)
        + ((cochlea_spikes[0]) << 4)
        + ((cochlea_spikes[3]) << 0)
        + ((cochlea_spikes[3]) << 1)
        + ((cochlea_spikes[3]) << 3)
        + ((hid_spikes[3] | hid_spikes[4] | hid_spikes[10] | hid_spikes[16] | hid_spikes[18] | hid_spikes[27] | hid_spikes[31] | hid_spikes[40] | hid_spikes[52]) << 0)
        + ((hid_spikes[16] | hid_spikes[22] | hid_spikes[47] | hid_spikes[52]) << 1)
        + ((hid_spikes[3] | hid_spikes[4] | hid_spikes[10] | hid_spikes[18] | hid_spikes[22] | hid_spikes[27] | hid_spikes[31] | hid_spikes[35] | hid_spikes[38] | hid_spikes[44] | hid_spikes[47] | hid_spikes[56]) << 2)
        + ((hid_spikes[4] | hid_spikes[40] | hid_spikes[42]) << 3)
        + ((hid_spikes[30]) << 4);
    wire signed [11:0] neg_in_63 = ((cochlea_spikes[5]) << 0)
        + ((cochlea_spikes[2] | cochlea_spikes[5]) << 1)
        + ((cochlea_spikes[2] | cochlea_spikes[5]) << 2)
        + ((cochlea_spikes[2]) << 3)
        + ((cochlea_spikes[5]) << 5)
        + ((cochlea_spikes[4]) << 0)
        + ((cochlea_spikes[1] | cochlea_spikes[4]) << 1)
        + ((cochlea_spikes[4]) << 2)
        + ((cochlea_spikes[1] | cochlea_spikes[4]) << 3)
        + ((hid_spikes[0] | hid_spikes[6] | hid_spikes[7] | hid_spikes[8] | hid_spikes[11] | hid_spikes[13] | hid_spikes[19] | hid_spikes[23] | hid_spikes[24] | hid_spikes[26] | hid_spikes[28] | hid_spikes[29] | hid_spikes[33] | hid_spikes[43] | hid_spikes[49] | hid_spikes[59] | hid_spikes[61] | hid_spikes[63]) << 0)
        + ((hid_spikes[2] | hid_spikes[7] | hid_spikes[8] | hid_spikes[11] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[23] | hid_spikes[24] | hid_spikes[26] | hid_spikes[33] | hid_spikes[43] | hid_spikes[45] | hid_spikes[46] | hid_spikes[48] | hid_spikes[55] | hid_spikes[58] | hid_spikes[61] | hid_spikes[63]) << 1)
        + ((hid_spikes[0] | hid_spikes[5] | hid_spikes[6] | hid_spikes[13] | hid_spikes[14] | hid_spikes[17] | hid_spikes[19] | hid_spikes[23] | hid_spikes[24] | hid_spikes[29] | hid_spikes[32] | hid_spikes[36] | hid_spikes[45] | hid_spikes[46] | hid_spikes[48] | hid_spikes[49] | hid_spikes[60]) << 2)
        + ((hid_spikes[0] | hid_spikes[2] | hid_spikes[11] | hid_spikes[13] | hid_spikes[14] | hid_spikes[15] | hid_spikes[19] | hid_spikes[25] | hid_spikes[28] | hid_spikes[36] | hid_spikes[41] | hid_spikes[43] | hid_spikes[53] | hid_spikes[55] | hid_spikes[57] | hid_spikes[59] | hid_spikes[62]) << 3)
        + ((hid_spikes[29] | hid_spikes[33]) << 4);
    wire signed [11:0] sum_hid_63 = pos_in_63 - neg_in_63;
    assign hid_spikes[63] = (mem_hid_63 >= 10);
    wire signed [11:0] next_hid_63 = mem_hid_63 - (mem_hid_63 >>> 6) + sum_hid_63;

    // ==========================================
    // BASE OUTPUT LAYER (Time-Multiplexed Accumulation)
    // ==========================================
    wire [5:0] base_spikes;

    reg [6:0] base_cycle;
    reg signed [11:0] mem_base_0;
    reg signed [11:0] sum_acc_0;
    reg signed [11:0] curr_w_out_0;
    reg signed [11:0] mem_base_1;
    reg signed [11:0] sum_acc_1;
    reg signed [11:0] curr_w_out_1;
    reg signed [11:0] mem_base_2;
    reg signed [11:0] sum_acc_2;
    reg signed [11:0] curr_w_out_2;
    reg signed [11:0] mem_base_3;
    reg signed [11:0] sum_acc_3;
    reg signed [11:0] curr_w_out_3;
    reg signed [11:0] mem_base_4;
    reg signed [11:0] sum_acc_4;
    reg signed [11:0] curr_w_out_4;
    reg signed [11:0] mem_base_5;
    reg signed [11:0] sum_acc_5;
    reg signed [11:0] curr_w_out_5;

    // Weight ROM for Time-Multiplexing
    always @(*) begin
        case (base_cycle)
            7'd0: begin
                curr_w_out_0 = 51;
                curr_w_out_1 = -68;
                curr_w_out_2 = -41;
                curr_w_out_3 = 55;
                curr_w_out_4 = 35;
                curr_w_out_5 = -5;
            end
            7'd1: begin
                curr_w_out_0 = -33;
                curr_w_out_1 = 5;
                curr_w_out_2 = 17;
                curr_w_out_3 = 26;
                curr_w_out_4 = 6;
                curr_w_out_5 = 0;
            end
            7'd2: begin
                curr_w_out_0 = 22;
                curr_w_out_1 = 44;
                curr_w_out_2 = -82;
                curr_w_out_3 = -45;
                curr_w_out_4 = -75;
                curr_w_out_5 = 68;
            end
            7'd3: begin
                curr_w_out_0 = -46;
                curr_w_out_1 = 36;
                curr_w_out_2 = 72;
                curr_w_out_3 = -90;
                curr_w_out_4 = -66;
                curr_w_out_5 = 14;
            end
            7'd4: begin
                curr_w_out_0 = -28;
                curr_w_out_1 = -21;
                curr_w_out_2 = 37;
                curr_w_out_3 = 66;
                curr_w_out_4 = -41;
                curr_w_out_5 = -61;
            end
            7'd5: begin
                curr_w_out_0 = 0;
                curr_w_out_1 = 17;
                curr_w_out_2 = -12;
                curr_w_out_3 = -37;
                curr_w_out_4 = 43;
                curr_w_out_5 = 20;
            end
            7'd6: begin
                curr_w_out_0 = 97;
                curr_w_out_1 = 0;
                curr_w_out_2 = -9;
                curr_w_out_3 = 14;
                curr_w_out_4 = 29;
                curr_w_out_5 = 77;
            end
            7'd7: begin
                curr_w_out_0 = -120;
                curr_w_out_1 = 84;
                curr_w_out_2 = -128;
                curr_w_out_3 = 0;
                curr_w_out_4 = 0;
                curr_w_out_5 = 22;
            end
            7'd8: begin
                curr_w_out_0 = -10;
                curr_w_out_1 = 5;
                curr_w_out_2 = 16;
                curr_w_out_3 = -119;
                curr_w_out_4 = 25;
                curr_w_out_5 = 0;
            end
            7'd9: begin
                curr_w_out_0 = -7;
                curr_w_out_1 = -61;
                curr_w_out_2 = -40;
                curr_w_out_3 = -48;
                curr_w_out_4 = -24;
                curr_w_out_5 = -13;
            end
            7'd10: begin
                curr_w_out_0 = 38;
                curr_w_out_1 = -9;
                curr_w_out_2 = 22;
                curr_w_out_3 = 0;
                curr_w_out_4 = 0;
                curr_w_out_5 = 25;
            end
            7'd11: begin
                curr_w_out_0 = -15;
                curr_w_out_1 = -39;
                curr_w_out_2 = 24;
                curr_w_out_3 = -48;
                curr_w_out_4 = -50;
                curr_w_out_5 = 0;
            end
            7'd12: begin
                curr_w_out_0 = 0;
                curr_w_out_1 = -52;
                curr_w_out_2 = -76;
                curr_w_out_3 = -60;
                curr_w_out_4 = -24;
                curr_w_out_5 = 0;
            end
            7'd13: begin
                curr_w_out_0 = 69;
                curr_w_out_1 = 69;
                curr_w_out_2 = 0;
                curr_w_out_3 = -62;
                curr_w_out_4 = 38;
                curr_w_out_5 = 0;
            end
            7'd14: begin
                curr_w_out_0 = -38;
                curr_w_out_1 = -91;
                curr_w_out_2 = -102;
                curr_w_out_3 = -128;
                curr_w_out_4 = -49;
                curr_w_out_5 = 15;
            end
            7'd15: begin
                curr_w_out_0 = 60;
                curr_w_out_1 = -72;
                curr_w_out_2 = 57;
                curr_w_out_3 = 0;
                curr_w_out_4 = 54;
                curr_w_out_5 = 22;
            end
            7'd16: begin
                curr_w_out_0 = 0;
                curr_w_out_1 = 42;
                curr_w_out_2 = -48;
                curr_w_out_3 = -37;
                curr_w_out_4 = 48;
                curr_w_out_5 = -30;
            end
            7'd17: begin
                curr_w_out_0 = 23;
                curr_w_out_1 = 108;
                curr_w_out_2 = 49;
                curr_w_out_3 = 27;
                curr_w_out_4 = 0;
                curr_w_out_5 = 0;
            end
            7'd18: begin
                curr_w_out_0 = 17;
                curr_w_out_1 = -9;
                curr_w_out_2 = 57;
                curr_w_out_3 = 27;
                curr_w_out_4 = 8;
                curr_w_out_5 = 18;
            end
            7'd19: begin
                curr_w_out_0 = 35;
                curr_w_out_1 = 12;
                curr_w_out_2 = -128;
                curr_w_out_3 = 40;
                curr_w_out_4 = 43;
                curr_w_out_5 = -11;
            end
            7'd20: begin
                curr_w_out_0 = 77;
                curr_w_out_1 = 37;
                curr_w_out_2 = -14;
                curr_w_out_3 = -24;
                curr_w_out_4 = -55;
                curr_w_out_5 = 29;
            end
            7'd21: begin
                curr_w_out_0 = 0;
                curr_w_out_1 = -9;
                curr_w_out_2 = 25;
                curr_w_out_3 = 21;
                curr_w_out_4 = -50;
                curr_w_out_5 = 25;
            end
            7'd22: begin
                curr_w_out_0 = -18;
                curr_w_out_1 = -128;
                curr_w_out_2 = 0;
                curr_w_out_3 = 0;
                curr_w_out_4 = 0;
                curr_w_out_5 = -48;
            end
            7'd23: begin
                curr_w_out_0 = 14;
                curr_w_out_1 = 38;
                curr_w_out_2 = 22;
                curr_w_out_3 = -10;
                curr_w_out_4 = 18;
                curr_w_out_5 = 68;
            end
            7'd24: begin
                curr_w_out_0 = -37;
                curr_w_out_1 = 87;
                curr_w_out_2 = 0;
                curr_w_out_3 = 58;
                curr_w_out_4 = 89;
                curr_w_out_5 = 64;
            end
            7'd25: begin
                curr_w_out_0 = 29;
                curr_w_out_1 = 79;
                curr_w_out_2 = -120;
                curr_w_out_3 = 25;
                curr_w_out_4 = 35;
                curr_w_out_5 = 6;
            end
            7'd26: begin
                curr_w_out_0 = -52;
                curr_w_out_1 = -102;
                curr_w_out_2 = -65;
                curr_w_out_3 = 0;
                curr_w_out_4 = 0;
                curr_w_out_5 = 0;
            end
            7'd27: begin
                curr_w_out_0 = -20;
                curr_w_out_1 = 50;
                curr_w_out_2 = -15;
                curr_w_out_3 = -37;
                curr_w_out_4 = 0;
                curr_w_out_5 = 21;
            end
            7'd28: begin
                curr_w_out_0 = -100;
                curr_w_out_1 = 75;
                curr_w_out_2 = -42;
                curr_w_out_3 = -66;
                curr_w_out_4 = -78;
                curr_w_out_5 = 0;
            end
            7'd29: begin
                curr_w_out_0 = -128;
                curr_w_out_1 = 0;
                curr_w_out_2 = 37;
                curr_w_out_3 = -20;
                curr_w_out_4 = -87;
                curr_w_out_5 = 38;
            end
            7'd30: begin
                curr_w_out_0 = -17;
                curr_w_out_1 = -76;
                curr_w_out_2 = 9;
                curr_w_out_3 = -62;
                curr_w_out_4 = 50;
                curr_w_out_5 = 18;
            end
            7'd31: begin
                curr_w_out_0 = 24;
                curr_w_out_1 = 52;
                curr_w_out_2 = 0;
                curr_w_out_3 = 41;
                curr_w_out_4 = 40;
                curr_w_out_5 = 18;
            end
            7'd32: begin
                curr_w_out_0 = 0;
                curr_w_out_1 = -11;
                curr_w_out_2 = -33;
                curr_w_out_3 = 62;
                curr_w_out_4 = 13;
                curr_w_out_5 = 58;
            end
            7'd33: begin
                curr_w_out_0 = 36;
                curr_w_out_1 = 7;
                curr_w_out_2 = 0;
                curr_w_out_3 = -34;
                curr_w_out_4 = 0;
                curr_w_out_5 = 23;
            end
            7'd34: begin
                curr_w_out_0 = -54;
                curr_w_out_1 = -81;
                curr_w_out_2 = 96;
                curr_w_out_3 = 0;
                curr_w_out_4 = -73;
                curr_w_out_5 = -68;
            end
            7'd35: begin
                curr_w_out_0 = 41;
                curr_w_out_1 = -45;
                curr_w_out_2 = 37;
                curr_w_out_3 = 67;
                curr_w_out_4 = 69;
                curr_w_out_5 = 55;
            end
            7'd36: begin
                curr_w_out_0 = 0;
                curr_w_out_1 = 43;
                curr_w_out_2 = 31;
                curr_w_out_3 = 27;
                curr_w_out_4 = 62;
                curr_w_out_5 = 26;
            end
            7'd37: begin
                curr_w_out_0 = 34;
                curr_w_out_1 = 47;
                curr_w_out_2 = 22;
                curr_w_out_3 = 0;
                curr_w_out_4 = -25;
                curr_w_out_5 = 13;
            end
            7'd38: begin
                curr_w_out_0 = 17;
                curr_w_out_1 = -84;
                curr_w_out_2 = 91;
                curr_w_out_3 = 24;
                curr_w_out_4 = -29;
                curr_w_out_5 = -48;
            end
            7'd39: begin
                curr_w_out_0 = -92;
                curr_w_out_1 = 26;
                curr_w_out_2 = -26;
                curr_w_out_3 = 68;
                curr_w_out_4 = 39;
                curr_w_out_5 = -72;
            end
            7'd40: begin
                curr_w_out_0 = 47;
                curr_w_out_1 = 61;
                curr_w_out_2 = 19;
                curr_w_out_3 = 45;
                curr_w_out_4 = 87;
                curr_w_out_5 = 34;
            end
            7'd41: begin
                curr_w_out_0 = 38;
                curr_w_out_1 = 19;
                curr_w_out_2 = 47;
                curr_w_out_3 = -14;
                curr_w_out_4 = 70;
                curr_w_out_5 = 57;
            end
            7'd42: begin
                curr_w_out_0 = -67;
                curr_w_out_1 = -128;
                curr_w_out_2 = 0;
                curr_w_out_3 = 19;
                curr_w_out_4 = 0;
                curr_w_out_5 = 0;
            end
            7'd43: begin
                curr_w_out_0 = 11;
                curr_w_out_1 = 0;
                curr_w_out_2 = 9;
                curr_w_out_3 = 43;
                curr_w_out_4 = 0;
                curr_w_out_5 = 24;
            end
            7'd44: begin
                curr_w_out_0 = -53;
                curr_w_out_1 = -23;
                curr_w_out_2 = 18;
                curr_w_out_3 = -47;
                curr_w_out_4 = -40;
                curr_w_out_5 = 30;
            end
            7'd45: begin
                curr_w_out_0 = 0;
                curr_w_out_1 = -47;
                curr_w_out_2 = 0;
                curr_w_out_3 = 0;
                curr_w_out_4 = -83;
                curr_w_out_5 = -21;
            end
            7'd46: begin
                curr_w_out_0 = 31;
                curr_w_out_1 = -23;
                curr_w_out_2 = -24;
                curr_w_out_3 = -44;
                curr_w_out_4 = 12;
                curr_w_out_5 = 14;
            end
            7'd47: begin
                curr_w_out_0 = -28;
                curr_w_out_1 = 26;
                curr_w_out_2 = 47;
                curr_w_out_3 = -7;
                curr_w_out_4 = 0;
                curr_w_out_5 = 0;
            end
            7'd48: begin
                curr_w_out_0 = 35;
                curr_w_out_1 = 5;
                curr_w_out_2 = 22;
                curr_w_out_3 = 0;
                curr_w_out_4 = 0;
                curr_w_out_5 = 0;
            end
            7'd49: begin
                curr_w_out_0 = -32;
                curr_w_out_1 = 64;
                curr_w_out_2 = 33;
                curr_w_out_3 = 58;
                curr_w_out_4 = -98;
                curr_w_out_5 = 77;
            end
            7'd50: begin
                curr_w_out_0 = -9;
                curr_w_out_1 = -36;
                curr_w_out_2 = -69;
                curr_w_out_3 = 42;
                curr_w_out_4 = 10;
                curr_w_out_5 = -30;
            end
            7'd51: begin
                curr_w_out_0 = 95;
                curr_w_out_1 = 94;
                curr_w_out_2 = 42;
                curr_w_out_3 = 0;
                curr_w_out_4 = 8;
                curr_w_out_5 = 52;
            end
            7'd52: begin
                curr_w_out_0 = -43;
                curr_w_out_1 = 25;
                curr_w_out_2 = -29;
                curr_w_out_3 = -27;
                curr_w_out_4 = -11;
                curr_w_out_5 = 3;
            end
            7'd53: begin
                curr_w_out_0 = 0;
                curr_w_out_1 = -27;
                curr_w_out_2 = 24;
                curr_w_out_3 = -24;
                curr_w_out_4 = -9;
                curr_w_out_5 = -13;
            end
            7'd54: begin
                curr_w_out_0 = -8;
                curr_w_out_1 = -24;
                curr_w_out_2 = 0;
                curr_w_out_3 = -25;
                curr_w_out_4 = 7;
                curr_w_out_5 = 0;
            end
            7'd55: begin
                curr_w_out_0 = -128;
                curr_w_out_1 = -62;
                curr_w_out_2 = -53;
                curr_w_out_3 = -102;
                curr_w_out_4 = -76;
                curr_w_out_5 = 16;
            end
            7'd56: begin
                curr_w_out_0 = -15;
                curr_w_out_1 = -33;
                curr_w_out_2 = -11;
                curr_w_out_3 = 40;
                curr_w_out_4 = 51;
                curr_w_out_5 = 58;
            end
            7'd57: begin
                curr_w_out_0 = -38;
                curr_w_out_1 = -10;
                curr_w_out_2 = 9;
                curr_w_out_3 = 47;
                curr_w_out_4 = 22;
                curr_w_out_5 = 11;
            end
            7'd58: begin
                curr_w_out_0 = -86;
                curr_w_out_1 = 33;
                curr_w_out_2 = 89;
                curr_w_out_3 = 108;
                curr_w_out_4 = 104;
                curr_w_out_5 = 60;
            end
            7'd59: begin
                curr_w_out_0 = -18;
                curr_w_out_1 = -23;
                curr_w_out_2 = 12;
                curr_w_out_3 = 22;
                curr_w_out_4 = -28;
                curr_w_out_5 = -66;
            end
            7'd60: begin
                curr_w_out_0 = 34;
                curr_w_out_1 = 52;
                curr_w_out_2 = 22;
                curr_w_out_3 = 0;
                curr_w_out_4 = 0;
                curr_w_out_5 = 0;
            end
            7'd61: begin
                curr_w_out_0 = -39;
                curr_w_out_1 = 10;
                curr_w_out_2 = 8;
                curr_w_out_3 = 41;
                curr_w_out_4 = 7;
                curr_w_out_5 = 12;
            end
            7'd62: begin
                curr_w_out_0 = -13;
                curr_w_out_1 = 27;
                curr_w_out_2 = 26;
                curr_w_out_3 = 5;
                curr_w_out_4 = 0;
                curr_w_out_5 = 4;
            end
            7'd63: begin
                curr_w_out_0 = 9;
                curr_w_out_1 = 11;
                curr_w_out_2 = -26;
                curr_w_out_3 = 0;
                curr_w_out_4 = -39;
                curr_w_out_5 = -47;
            end
            default: begin
                curr_w_out_0 = 0;
                curr_w_out_1 = 0;
                curr_w_out_2 = 0;
                curr_w_out_3 = 0;
                curr_w_out_4 = 0;
                curr_w_out_5 = 0;
            end
        endcase
    end

    // Synchronous Accumulator
    always @(posedge clk_1mhz or negedge rst_n) begin
        if (!rst_n) begin
            base_cycle <= 0;
            sum_acc_0 <= 0;
            sum_acc_1 <= 0;
            sum_acc_2 <= 0;
            sum_acc_3 <= 0;
            sum_acc_4 <= 0;
            sum_acc_5 <= 0;
        end else if (tick_1ms) begin
            // Reset counters for the new 1ms frame
            base_cycle <= 0;
            sum_acc_0 <= 0;
            sum_acc_1 <= 0;
            sum_acc_2 <= 0;
            sum_acc_3 <= 0;
            sum_acc_4 <= 0;
            sum_acc_5 <= 0;
        end else if (base_cycle < 64) begin
            // Accumulate weights if the hidden neuron spiked
            if (hid_spikes[base_cycle]) begin
                sum_acc_0 <= sum_acc_0 + curr_w_out_0;
                sum_acc_1 <= sum_acc_1 + curr_w_out_1;
                sum_acc_2 <= sum_acc_2 + curr_w_out_2;
                sum_acc_3 <= sum_acc_3 + curr_w_out_3;
                sum_acc_4 <= sum_acc_4 + curr_w_out_4;
                sum_acc_5 <= sum_acc_5 + curr_w_out_5;
            end
            base_cycle <= base_cycle + 1;
        end
    end

    // Membrane Updates
    assign base_spikes[0] = (mem_base_0 >= 67);
    wire signed [11:0] next_base_0 = mem_base_0 - (mem_base_0 >>> 6) + sum_acc_0;

    assign base_spikes[1] = (mem_base_1 >= 67);
    wire signed [11:0] next_base_1 = mem_base_1 - (mem_base_1 >>> 6) + sum_acc_1;

    assign base_spikes[2] = (mem_base_2 >= 67);
    wire signed [11:0] next_base_2 = mem_base_2 - (mem_base_2 >>> 6) + sum_acc_2;

    assign base_spikes[3] = (mem_base_3 >= 67);
    wire signed [11:0] next_base_3 = mem_base_3 - (mem_base_3 >>> 6) + sum_acc_3;

    assign base_spikes[4] = (mem_base_4 >= 67);
    wire signed [11:0] next_base_4 = mem_base_4 - (mem_base_4 >>> 6) + sum_acc_4;

    assign base_spikes[5] = (mem_base_5 >= 67);
    wire signed [11:0] next_base_5 = mem_base_5 - (mem_base_5 >>> 6) + sum_acc_5;

    // ==========================================
    // WTA RACE-LATCH LAYER (Asymmetric Logic)
    // ==========================================
    reg signed [11:0] mem_wta_0;
    wire signed [11:0] sum_wta_0 = 0
        + (base_spikes[0] ? 4 : 0)
        - (base_spikes[5] ? 3 : 0)
        - (wta_spikes[1] ? 128 : 0)
        - (wta_spikes[2] ? 109 : 0)
        - (wta_spikes[3] ? 107 : 0)
        - (wta_spikes[4] ? 117 : 0);
    assign wta_spikes[0] = (mem_wta_0 >= 100);
    wire signed [11:0] next_wta_0 = mem_wta_0 + sum_wta_0;

    reg signed [11:0] mem_wta_1;
    wire signed [11:0] sum_wta_1 = 0
        + (base_spikes[1] ? 4 : 0)
        - (base_spikes[5] ? 2 : 0)
        - (wta_spikes[0] ? 122 : 0)
        - (wta_spikes[2] ? 128 : 0)
        - (wta_spikes[3] ? 76 : 0)
        - (wta_spikes[4] ? 126 : 0);
    assign wta_spikes[1] = (mem_wta_1 >= 100);
    wire signed [11:0] next_wta_1 = mem_wta_1 + sum_wta_1;

    reg signed [11:0] mem_wta_2;
    wire signed [11:0] sum_wta_2 = 0
        + (base_spikes[1] ? 2 : 0)
        + (base_spikes[2] ? 3 : 0)
        - (base_spikes[5] ? 3 : 0)
        - (wta_spikes[0] ? 118 : 0)
        - (wta_spikes[1] ? 120 : 0)
        - (wta_spikes[3] ? 118 : 0)
        - (wta_spikes[4] ? 128 : 0);
    assign wta_spikes[2] = (mem_wta_2 >= 100);
    wire signed [11:0] next_wta_2 = mem_wta_2 + sum_wta_2;

    reg signed [11:0] mem_wta_3;
    wire signed [11:0] sum_wta_3 = 0
        + (base_spikes[3] ? 2 : 0)
        + (base_spikes[4] ? 1 : 0)
        - (wta_spikes[0] ? 110 : 0)
        - (wta_spikes[1] ? 113 : 0)
        - (wta_spikes[2] ? 128 : 0)
        - (wta_spikes[4] ? 126 : 0);
    assign wta_spikes[3] = (mem_wta_3 >= 100);
    wire signed [11:0] next_wta_3 = mem_wta_3 + sum_wta_3;

    reg signed [11:0] mem_wta_4;
    wire signed [11:0] sum_wta_4 = 0
        + (base_spikes[4] ? 3 : 0)
        - (base_spikes[5] ? 1 : 0)
        - (wta_spikes[0] ? 128 : 0)
        - (wta_spikes[1] ? 122 : 0)
        - (wta_spikes[2] ? 128 : 0)
        - (wta_spikes[3] ? 121 : 0);
    assign wta_spikes[4] = (mem_wta_4 >= 100);
    wire signed [11:0] next_wta_4 = mem_wta_4 + sum_wta_4;

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
            mem_base_0 <= 0;
            mem_base_1 <= 0;
            mem_base_2 <= 0;
            mem_base_3 <= 0;
            mem_base_4 <= 0;
            mem_base_5 <= 0;
            mem_wta_0 <= 0;
            mem_wta_1 <= 0;
            mem_wta_2 <= 0;
            mem_wta_3 <= 0;
            mem_wta_4 <= 0;
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
            mem_base_0 <= base_spikes[0] ? 0 : next_base_0;
            mem_base_1 <= base_spikes[1] ? 0 : next_base_1;
            mem_base_2 <= base_spikes[2] ? 0 : next_base_2;
            mem_base_3 <= base_spikes[3] ? 0 : next_base_3;
            mem_base_4 <= base_spikes[4] ? 0 : next_base_4;
            mem_base_5 <= base_spikes[5] ? 0 : next_base_5;
            mem_wta_0 <= wta_spikes[0] ? 0 : next_wta_0;
            mem_wta_1 <= wta_spikes[1] ? 0 : next_wta_1;
            mem_wta_2 <= wta_spikes[2] ? 0 : next_wta_2;
            mem_wta_3 <= wta_spikes[3] ? 0 : next_wta_3;
            mem_wta_4 <= wta_spikes[4] ? 0 : next_wta_4;
        end
    end
endmodule
