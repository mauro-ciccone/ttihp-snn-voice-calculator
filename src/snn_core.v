`default_nettype none
module snn_core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tick_1ms,
    input  wire [6:0]  in_spikes,
    output reg  [4:0] out_spikes
);

    reg [4:0] state; // 0-23: Hidden, 24-28: Output, 31: Idle
    reg signed [15:0] mem [0:28];
    reg [23:0] hid_spikes;

    wire signed [15:0] current_v = mem[state];
    reg [2:0] current_shift;
    reg signed [15:0] weight_sum;
    wire signed [15:0] leaked_v = current_v - (current_v >>> current_shift);
    wire signed [15:0] next_v = leaked_v + weight_sum;
    wire signed [15:0] active_thresh = (state < 24) ? 16'sd87 : 16'sd88;
    wire is_spike = (next_v >= active_thresh);

    always @(*) begin
        weight_sum = 16'sd0;
        current_shift = 3'd1;
        case (state)
            5'd0: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[3] ? 16'sd43 : 16'sd0) + (hid_spikes[0] ? -16'sd81 : 16'sd0) + (hid_spikes[1] ? -16'sd51 : 16'sd0) + (hid_spikes[4] ? 16'sd53 : 16'sd0) + (hid_spikes[5] ? -16'sd41 : 16'sd0) + (hid_spikes[6] ? -16'sd57 : 16'sd0) + (hid_spikes[7] ? -16'sd51 : 16'sd0) + (hid_spikes[8] ? -16'sd43 : 16'sd0) + (hid_spikes[9] ? 16'sd93 : 16'sd0) + (hid_spikes[10] ? 16'sd110 : 16'sd0) + (hid_spikes[11] ? -16'sd32 : 16'sd0) + (hid_spikes[12] ? -16'sd34 : 16'sd0) + (hid_spikes[14] ? -16'sd44 : 16'sd0) + (hid_spikes[16] ? 16'sd107 : 16'sd0) + (hid_spikes[17] ? -16'sd71 : 16'sd0) + (hid_spikes[18] ? -16'sd82 : 16'sd0) + (hid_spikes[22] ? 16'sd45 : 16'sd0);
            end
            5'd1: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[3] ? 16'sd44 : 16'sd0) + (hid_spikes[1] ? 16'sd46 : 16'sd0) + (hid_spikes[9] ? -16'sd58 : 16'sd0) + (hid_spikes[10] ? 16'sd43 : 16'sd0) + (hid_spikes[12] ? -16'sd35 : 16'sd0) + (hid_spikes[17] ? -16'sd32 : 16'sd0) + (hid_spikes[23] ? -16'sd50 : 16'sd0);
            end
            5'd2: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[6] ? 16'sd50 : 16'sd0) + (hid_spikes[2] ? 16'sd88 : 16'sd0) + (hid_spikes[12] ? -16'sd42 : 16'sd0) + (hid_spikes[15] ? 16'sd41 : 16'sd0) + (hid_spikes[23] ? -16'sd49 : 16'sd0);
            end
            5'd3: begin
                current_shift = 3'd2;
                weight_sum = (hid_spikes[0] ? 16'sd51 : 16'sd0) + (hid_spikes[1] ? -16'sd76 : 16'sd0) + (hid_spikes[2] ? -16'sd71 : 16'sd0) + (hid_spikes[3] ? 16'sd47 : 16'sd0) + (hid_spikes[4] ? 16'sd46 : 16'sd0) + (hid_spikes[7] ? 16'sd48 : 16'sd0) + (hid_spikes[9] ? 16'sd35 : 16'sd0) + (hid_spikes[10] ? 16'sd126 : 16'sd0) + (hid_spikes[15] ? -16'sd52 : 16'sd0) + (hid_spikes[16] ? 16'sd116 : 16'sd0) + (hid_spikes[17] ? -16'sd35 : 16'sd0) + (hid_spikes[19] ? 16'sd67 : 16'sd0) + (hid_spikes[23] ? -16'sd31 : 16'sd0);
            end
            5'd4: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[3] ? 16'sd55 : 16'sd0) + (hid_spikes[2] ? -16'sd44 : 16'sd0) + (hid_spikes[4] ? -16'sd87 : 16'sd0) + (hid_spikes[5] ? -16'sd43 : 16'sd0) + (hid_spikes[6] ? -16'sd105 : 16'sd0) + (hid_spikes[10] ? 16'sd47 : 16'sd0) + (hid_spikes[12] ? -16'sd68 : 16'sd0) + (hid_spikes[13] ? -16'sd42 : 16'sd0) + (hid_spikes[14] ? -16'sd55 : 16'sd0) + (hid_spikes[15] ? -16'sd31 : 16'sd0) + (hid_spikes[17] ? -16'sd127 : 16'sd0) + (hid_spikes[19] ? -16'sd31 : 16'sd0) + (hid_spikes[20] ? -16'sd44 : 16'sd0) + (hid_spikes[21] ? -16'sd43 : 16'sd0) + (hid_spikes[22] ? -16'sd86 : 16'sd0) + (hid_spikes[23] ? -16'sd41 : 16'sd0);
            end
            5'd5: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[3] ? 16'sd32 : 16'sd0) + (hid_spikes[1] ? 16'sd38 : 16'sd0) + (hid_spikes[4] ? 16'sd41 : 16'sd0) + (hid_spikes[10] ? 16'sd39 : 16'sd0) + (hid_spikes[12] ? -16'sd47 : 16'sd0) + (hid_spikes[16] ? 16'sd44 : 16'sd0) + (hid_spikes[17] ? -16'sd84 : 16'sd0) + (hid_spikes[18] ? -16'sd102 : 16'sd0) + (hid_spikes[19] ? -16'sd43 : 16'sd0) + (hid_spikes[20] ? -16'sd63 : 16'sd0) + (hid_spikes[22] ? 16'sd55 : 16'sd0) + (hid_spikes[23] ? -16'sd35 : 16'sd0);
            end
            5'd6: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[1] ? -16'sd33 : 16'sd0) + (hid_spikes[2] ? -16'sd34 : 16'sd0) + (hid_spikes[5] ? -16'sd65 : 16'sd0) + (hid_spikes[10] ? 16'sd81 : 16'sd0) + (hid_spikes[13] ? -16'sd65 : 16'sd0) + (hid_spikes[16] ? 16'sd105 : 16'sd0) + (hid_spikes[17] ? -16'sd76 : 16'sd0) + (hid_spikes[18] ? -16'sd40 : 16'sd0) + (hid_spikes[19] ? -16'sd37 : 16'sd0) + (hid_spikes[21] ? -16'sd37 : 16'sd0) + (hid_spikes[22] ? 16'sd58 : 16'sd0) + (hid_spikes[23] ? -16'sd31 : 16'sd0);
            end
            5'd7: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[0] ? -16'sd34 : 16'sd0) + (in_spikes[3] ? 16'sd41 : 16'sd0) + (hid_spikes[1] ? -16'sd45 : 16'sd0) + (hid_spikes[2] ? -16'sd46 : 16'sd0) + (hid_spikes[3] ? -16'sd64 : 16'sd0) + (hid_spikes[4] ? 16'sd49 : 16'sd0) + (hid_spikes[10] ? 16'sd73 : 16'sd0) + (hid_spikes[11] ? -16'sd46 : 16'sd0) + (hid_spikes[12] ? -16'sd32 : 16'sd0) + (hid_spikes[14] ? -16'sd78 : 16'sd0) + (hid_spikes[16] ? 16'sd127 : 16'sd0) + (hid_spikes[17] ? -16'sd52 : 16'sd0) + (hid_spikes[18] ? -16'sd84 : 16'sd0) + (hid_spikes[19] ? -16'sd93 : 16'sd0) + (hid_spikes[21] ? -16'sd34 : 16'sd0) + (hid_spikes[23] ? -16'sd34 : 16'sd0);
            end
            5'd8: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[1] ? -16'sd33 : 16'sd0) + (in_spikes[3] ? 16'sd54 : 16'sd0) + (hid_spikes[1] ? -16'sd92 : 16'sd0) + (hid_spikes[2] ? -16'sd71 : 16'sd0) + (hid_spikes[5] ? -16'sd45 : 16'sd0) + (hid_spikes[6] ? -16'sd82 : 16'sd0) + (hid_spikes[7] ? -16'sd35 : 16'sd0) + (hid_spikes[8] ? -16'sd127 : 16'sd0) + (hid_spikes[9] ? -16'sd99 : 16'sd0) + (hid_spikes[10] ? -16'sd32 : 16'sd0) + (hid_spikes[13] ? -16'sd90 : 16'sd0) + (hid_spikes[14] ? -16'sd93 : 16'sd0) + (hid_spikes[17] ? 16'sd31 : 16'sd0) + (hid_spikes[19] ? -16'sd89 : 16'sd0) + (hid_spikes[21] ? -16'sd31 : 16'sd0) + (hid_spikes[22] ? -16'sd119 : 16'sd0) + (hid_spikes[23] ? -16'sd42 : 16'sd0);
            end
            5'd9: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[3] ? -16'sd45 : 16'sd0) + (hid_spikes[4] ? 16'sd83 : 16'sd0) + (hid_spikes[6] ? -16'sd43 : 16'sd0) + (hid_spikes[8] ? 16'sd50 : 16'sd0) + (hid_spikes[9] ? 16'sd69 : 16'sd0) + (hid_spikes[10] ? 16'sd67 : 16'sd0) + (hid_spikes[11] ? 16'sd37 : 16'sd0) + (hid_spikes[15] ? -16'sd49 : 16'sd0) + (hid_spikes[16] ? 16'sd49 : 16'sd0) + (hid_spikes[22] ? 16'sd43 : 16'sd0);
            end
            5'd10: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[3] ? 16'sd53 : 16'sd0) + (in_spikes[6] ? 16'sd38 : 16'sd0) + (hid_spikes[4] ? -16'sd33 : 16'sd0) + (hid_spikes[6] ? -16'sd110 : 16'sd0) + (hid_spikes[8] ? 16'sd51 : 16'sd0) + (hid_spikes[9] ? 16'sd127 : 16'sd0) + (hid_spikes[12] ? -16'sd78 : 16'sd0) + (hid_spikes[15] ? -16'sd38 : 16'sd0) + (hid_spikes[16] ? 16'sd49 : 16'sd0) + (hid_spikes[17] ? -16'sd109 : 16'sd0) + (hid_spikes[21] ? -16'sd59 : 16'sd0) + (hid_spikes[23] ? -16'sd42 : 16'sd0);
            end
            5'd11: begin
                current_shift = 3'd2;
                weight_sum = (hid_spikes[2] ? -16'sd40 : 16'sd0) + (hid_spikes[3] ? -16'sd63 : 16'sd0) + (hid_spikes[6] ? -16'sd80 : 16'sd0) + (hid_spikes[8] ? 16'sd47 : 16'sd0) + (hid_spikes[9] ? -16'sd66 : 16'sd0) + (hid_spikes[12] ? -16'sd56 : 16'sd0) + (hid_spikes[13] ? -16'sd36 : 16'sd0) + (hid_spikes[14] ? -16'sd53 : 16'sd0) + (hid_spikes[15] ? -16'sd49 : 16'sd0) + (hid_spikes[17] ? -16'sd42 : 16'sd0) + (hid_spikes[18] ? -16'sd56 : 16'sd0) + (hid_spikes[19] ? -16'sd67 : 16'sd0) + (hid_spikes[20] ? -16'sd63 : 16'sd0) + (hid_spikes[22] ? -16'sd122 : 16'sd0);
            end
            5'd12: begin
                current_shift = 3'd2;
                weight_sum = (hid_spikes[0] ? 16'sd75 : 16'sd0) + (hid_spikes[1] ? 16'sd37 : 16'sd0) + (hid_spikes[4] ? 16'sd106 : 16'sd0) + (hid_spikes[5] ? 16'sd32 : 16'sd0) + (hid_spikes[6] ? 16'sd110 : 16'sd0) + (hid_spikes[7] ? 16'sd54 : 16'sd0) + (hid_spikes[8] ? -16'sd127 : 16'sd0) + (hid_spikes[9] ? -16'sd33 : 16'sd0) + (hid_spikes[10] ? 16'sd77 : 16'sd0) + (hid_spikes[14] ? 16'sd44 : 16'sd0) + (hid_spikes[16] ? 16'sd33 : 16'sd0) + (hid_spikes[18] ? 16'sd36 : 16'sd0) + (hid_spikes[21] ? 16'sd77 : 16'sd0) + (hid_spikes[22] ? -16'sd92 : 16'sd0);
            end
            5'd13: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[0] ? -16'sd127 : 16'sd0) + (in_spikes[1] ? -16'sd127 : 16'sd0) + (in_spikes[3] ? 16'sd43 : 16'sd0) + (in_spikes[6] ? 16'sd45 : 16'sd0) + (hid_spikes[3] ? 16'sd47 : 16'sd0) + (hid_spikes[6] ? -16'sd55 : 16'sd0) + (hid_spikes[9] ? 16'sd72 : 16'sd0) + (hid_spikes[13] ? 16'sd62 : 16'sd0) + (hid_spikes[21] ? -16'sd53 : 16'sd0) + (hid_spikes[22] ? -16'sd89 : 16'sd0) + (hid_spikes[23] ? -16'sd34 : 16'sd0);
            end
            5'd14: begin
                current_shift = 3'd2;
                weight_sum = (hid_spikes[1] ? -16'sd69 : 16'sd0) + (hid_spikes[2] ? -16'sd85 : 16'sd0) + (hid_spikes[10] ? 16'sd54 : 16'sd0) + (hid_spikes[13] ? -16'sd43 : 16'sd0) + (hid_spikes[16] ? 16'sd91 : 16'sd0) + (hid_spikes[20] ? -16'sd55 : 16'sd0);
            end
            5'd15: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[1] ? -16'sd127 : 16'sd0) + (in_spikes[6] ? -16'sd58 : 16'sd0) + (hid_spikes[1] ? -16'sd65 : 16'sd0) + (hid_spikes[2] ? -16'sd81 : 16'sd0) + (hid_spikes[4] ? 16'sd51 : 16'sd0) + (hid_spikes[6] ? -16'sd46 : 16'sd0) + (hid_spikes[9] ? -16'sd67 : 16'sd0) + (hid_spikes[10] ? 16'sd36 : 16'sd0) + (hid_spikes[15] ? 16'sd65 : 16'sd0) + (hid_spikes[16] ? 16'sd32 : 16'sd0) + (hid_spikes[17] ? -16'sd127 : 16'sd0) + (hid_spikes[22] ? -16'sd103 : 16'sd0) + (hid_spikes[23] ? -16'sd35 : 16'sd0);
            end
            5'd16: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[3] ? 16'sd61 : 16'sd0) + (hid_spikes[1] ? -16'sd39 : 16'sd0) + (hid_spikes[2] ? -16'sd62 : 16'sd0) + (hid_spikes[6] ? -16'sd55 : 16'sd0) + (hid_spikes[8] ? 16'sd38 : 16'sd0) + (hid_spikes[9] ? 16'sd127 : 16'sd0) + (hid_spikes[12] ? -16'sd88 : 16'sd0) + (hid_spikes[13] ? -16'sd32 : 16'sd0) + (hid_spikes[15] ? -16'sd51 : 16'sd0) + (hid_spikes[17] ? -16'sd67 : 16'sd0) + (hid_spikes[18] ? -16'sd36 : 16'sd0) + (hid_spikes[20] ? -16'sd38 : 16'sd0) + (hid_spikes[21] ? -16'sd46 : 16'sd0) + (hid_spikes[22] ? 16'sd127 : 16'sd0) + (hid_spikes[23] ? -16'sd42 : 16'sd0);
            end
            5'd17: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[1] ? -16'sd32 : 16'sd0) + (in_spikes[2] ? 16'sd74 : 16'sd0) + (in_spikes[3] ? 16'sd54 : 16'sd0) + (in_spikes[6] ? -16'sd127 : 16'sd0) + (hid_spikes[3] ? 16'sd40 : 16'sd0) + (hid_spikes[5] ? -16'sd40 : 16'sd0) + (hid_spikes[9] ? -16'sd34 : 16'sd0) + (hid_spikes[13] ? -16'sd44 : 16'sd0) + (hid_spikes[14] ? 16'sd33 : 16'sd0) + (hid_spikes[17] ? 16'sd101 : 16'sd0) + (hid_spikes[18] ? -16'sd56 : 16'sd0) + (hid_spikes[20] ? -16'sd71 : 16'sd0) + (hid_spikes[22] ? -16'sd60 : 16'sd0) + (hid_spikes[23] ? -16'sd66 : 16'sd0);
            end
            5'd18: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[1] ? 16'sd36 : 16'sd0) + (hid_spikes[0] ? 16'sd43 : 16'sd0) + (hid_spikes[1] ? -16'sd63 : 16'sd0) + (hid_spikes[2] ? -16'sd52 : 16'sd0) + (hid_spikes[4] ? 16'sd52 : 16'sd0) + (hid_spikes[7] ? 16'sd45 : 16'sd0) + (hid_spikes[8] ? 16'sd32 : 16'sd0) + (hid_spikes[10] ? 16'sd77 : 16'sd0) + (hid_spikes[15] ? -16'sd41 : 16'sd0) + (hid_spikes[16] ? 16'sd66 : 16'sd0) + (hid_spikes[17] ? -16'sd127 : 16'sd0) + (hid_spikes[18] ? -16'sd72 : 16'sd0) + (hid_spikes[20] ? -16'sd41 : 16'sd0);
            end
            5'd19: begin
                current_shift = 3'd2;
                weight_sum = (hid_spikes[3] ? -16'sd34 : 16'sd0) + (hid_spikes[4] ? 16'sd59 : 16'sd0) + (hid_spikes[7] ? -16'sd32 : 16'sd0) + (hid_spikes[9] ? 16'sd53 : 16'sd0) + (hid_spikes[10] ? 16'sd90 : 16'sd0) + (hid_spikes[11] ? -16'sd54 : 16'sd0) + (hid_spikes[12] ? -16'sd46 : 16'sd0) + (hid_spikes[15] ? -16'sd63 : 16'sd0) + (hid_spikes[16] ? 16'sd68 : 16'sd0) + (hid_spikes[18] ? -16'sd80 : 16'sd0) + (hid_spikes[19] ? -16'sd61 : 16'sd0) + (hid_spikes[20] ? -16'sd87 : 16'sd0);
            end
            5'd20: begin
                current_shift = 3'd2;
                weight_sum = (hid_spikes[0] ? 16'sd109 : 16'sd0) + (hid_spikes[2] ? -16'sd88 : 16'sd0) + (hid_spikes[3] ? 16'sd55 : 16'sd0) + (hid_spikes[4] ? 16'sd81 : 16'sd0) + (hid_spikes[5] ? 16'sd42 : 16'sd0) + (hid_spikes[7] ? 16'sd41 : 16'sd0) + (hid_spikes[9] ? 16'sd97 : 16'sd0) + (hid_spikes[10] ? 16'sd102 : 16'sd0) + (hid_spikes[12] ? 16'sd32 : 16'sd0) + (hid_spikes[14] ? 16'sd34 : 16'sd0) + (hid_spikes[15] ? 16'sd60 : 16'sd0) + (hid_spikes[16] ? 16'sd66 : 16'sd0) + (hid_spikes[17] ? -16'sd127 : 16'sd0) + (hid_spikes[19] ? 16'sd31 : 16'sd0) + (hid_spikes[20] ? 16'sd60 : 16'sd0) + (hid_spikes[21] ? 16'sd67 : 16'sd0) + (hid_spikes[22] ? 16'sd98 : 16'sd0);
            end
            5'd21: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[3] ? 16'sd49 : 16'sd0) + (hid_spikes[0] ? 16'sd32 : 16'sd0) + (hid_spikes[10] ? 16'sd48 : 16'sd0) + (hid_spikes[14] ? 16'sd36 : 16'sd0) + (hid_spikes[17] ? -16'sd109 : 16'sd0) + (hid_spikes[21] ? 16'sd39 : 16'sd0) + (hid_spikes[22] ? 16'sd34 : 16'sd0);
            end
            5'd22: begin
                current_shift = 3'd2;
                weight_sum = (hid_spikes[3] ? -16'sd51 : 16'sd0) + (hid_spikes[4] ? 16'sd56 : 16'sd0) + (hid_spikes[7] ? 16'sd48 : 16'sd0) + (hid_spikes[9] ? -16'sd99 : 16'sd0) + (hid_spikes[10] ? 16'sd48 : 16'sd0) + (hid_spikes[11] ? -16'sd59 : 16'sd0) + (hid_spikes[12] ? -16'sd60 : 16'sd0) + (hid_spikes[13] ? -16'sd49 : 16'sd0) + (hid_spikes[17] ? -16'sd51 : 16'sd0) + (hid_spikes[18] ? -16'sd59 : 16'sd0) + (hid_spikes[20] ? -16'sd112 : 16'sd0) + (hid_spikes[22] ? -16'sd38 : 16'sd0) + (hid_spikes[23] ? -16'sd54 : 16'sd0);
            end
            5'd23: begin
                current_shift = 3'd2;
                weight_sum = (in_spikes[3] ? 16'sd38 : 16'sd0) + (in_spikes[6] ? 16'sd43 : 16'sd0) + (hid_spikes[3] ? 16'sd34 : 16'sd0) + (hid_spikes[6] ? 16'sd62 : 16'sd0) + (hid_spikes[7] ? 16'sd37 : 16'sd0) + (hid_spikes[15] ? -16'sd56 : 16'sd0) + (hid_spikes[17] ? 16'sd34 : 16'sd0) + (hid_spikes[23] ? 16'sd34 : 16'sd0);
            end
            5'd24: begin
                current_shift = 3'd2;
                weight_sum = (hid_spikes[1] ? -16'sd78 : 16'sd0) + (hid_spikes[2] ? -16'sd38 : 16'sd0) + (hid_spikes[4] ? 16'sd35 : 16'sd0) + (hid_spikes[8] ? 16'sd58 : 16'sd0) + (hid_spikes[10] ? 16'sd67 : 16'sd0) + (hid_spikes[11] ? -16'sd85 : 16'sd0) + (hid_spikes[16] ? 16'sd46 : 16'sd0) + (hid_spikes[17] ? -16'sd79 : 16'sd0) + (hid_spikes[21] ? -16'sd42 : 16'sd0);
            end
            5'd25: begin
                current_shift = 3'd2;
                weight_sum = (hid_spikes[1] ? 16'sd35 : 16'sd0) + (hid_spikes[2] ? -16'sd50 : 16'sd0) + (hid_spikes[5] ? 16'sd35 : 16'sd0) + (hid_spikes[8] ? -16'sd42 : 16'sd0) + (hid_spikes[11] ? -16'sd32 : 16'sd0) + (hid_spikes[13] ? -16'sd66 : 16'sd0) + (hid_spikes[14] ? 16'sd48 : 16'sd0) + (hid_spikes[15] ? 16'sd34 : 16'sd0) + (hid_spikes[17] ? -16'sd83 : 16'sd0) + (hid_spikes[18] ? -16'sd42 : 16'sd0) + (hid_spikes[21] ? 16'sd44 : 16'sd0) + (hid_spikes[22] ? 16'sd127 : 16'sd0);
            end
            5'd26: begin
                current_shift = 3'd2;
                weight_sum = (hid_spikes[2] ? -16'sd76 : 16'sd0) + (hid_spikes[6] ? -16'sd31 : 16'sd0) + (hid_spikes[8] ? 16'sd32 : 16'sd0) + (hid_spikes[9] ? 16'sd107 : 16'sd0) + (hid_spikes[11] ? 16'sd51 : 16'sd0) + (hid_spikes[13] ? 16'sd34 : 16'sd0) + (hid_spikes[17] ? -16'sd127 : 16'sd0);
            end
            5'd27: begin
                current_shift = 3'd2;
                weight_sum = (hid_spikes[2] ? -16'sd61 : 16'sd0) + (hid_spikes[6] ? -16'sd33 : 16'sd0) + (hid_spikes[9] ? 16'sd67 : 16'sd0);
            end
            5'd28: begin
                current_shift = 3'd2;
                weight_sum = (hid_spikes[8] ? 16'sd63 : 16'sd0) + (hid_spikes[9] ? 16'sd107 : 16'sd0) + (hid_spikes[11] ? -16'sd46 : 16'sd0) + (hid_spikes[15] ? 16'sd35 : 16'sd0) + (hid_spikes[22] ? 16'sd127 : 16'sd0);
            end
            default: begin
                weight_sum = 16'sd0;
                current_shift = 3'd1;
            end
        endcase
    end

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 5'd31;
            hid_spikes <= 24'd0;
            out_spikes <= 5'd0;
            for (i = 0; i < 29; i = i + 1) mem[i] <= 16'sd0;
        end else begin
            if (state == 5'd31) begin
                if (tick_1ms) state <= 5'd0;
            end else if (state < 5'd29) begin
                mem[state] <= is_spike ? 16'sd0 : next_v;
                if (state < 5'd24) hid_spikes[state] <= is_spike;
                else out_spikes[state - 5'd24] <= is_spike;

                if (state == 5'd28) state <= 5'd31;
                else state <= state + 1;
            end
        end
    end
endmodule