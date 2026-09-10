`default_nettype none
module snn_core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tick_1ms,
    input  wire [6:0]  in_spikes,
    output reg  [4:0] out_spikes
);

    reg [9:0] state; // 10-bit state counter
    reg signed [15:0] mem [0:28];
    reg [23:0] hid_spikes;

    // --- SINGLE GLOBAL ALU ---
    reg [4:0] alu_addr;
    reg signed [15:0] alu_add_val;
    reg alu_do_add;
    reg [2:0] alu_shift;
    reg alu_is_leak, alu_is_thresh;

    always @(*) begin
        alu_addr = 5'd0; alu_add_val = 16'sd0; alu_do_add = 1'b0;
        alu_shift = 3'd1; alu_is_leak = 1'b0; alu_is_thresh = 1'b0;

        if (state < 10'd29) begin
            alu_is_leak = 1'b1;
            alu_addr = state[4:0];
            case(state)
                10'd0: alu_shift = 3'd2;
                10'd1: alu_shift = 3'd2;
                10'd2: alu_shift = 3'd2;
                10'd3: alu_shift = 3'd2;
                10'd4: alu_shift = 3'd2;
                10'd5: alu_shift = 3'd2;
                10'd6: alu_shift = 3'd2;
                10'd7: alu_shift = 3'd2;
                10'd8: alu_shift = 3'd2;
                10'd9: alu_shift = 3'd2;
                10'd10: alu_shift = 3'd2;
                10'd11: alu_shift = 3'd2;
                10'd12: alu_shift = 3'd2;
                10'd13: alu_shift = 3'd2;
                10'd14: alu_shift = 3'd2;
                10'd15: alu_shift = 3'd2;
                10'd16: alu_shift = 3'd2;
                10'd17: alu_shift = 3'd2;
                10'd18: alu_shift = 3'd2;
                10'd19: alu_shift = 3'd2;
                10'd20: alu_shift = 3'd2;
                10'd21: alu_shift = 3'd2;
                10'd22: alu_shift = 3'd2;
                10'd23: alu_shift = 3'd2;
                10'd24: alu_shift = 3'd2;
                10'd25: alu_shift = 3'd2;
                10'd26: alu_shift = 3'd2;
                10'd27: alu_shift = 3'd2;
                10'd28: alu_shift = 3'd2;
            endcase
        end else if (state < 10'd359) begin
            case(state)
                10'd29: begin alu_addr = 5'd0; alu_add_val = 16'sd43; alu_do_add = in_spikes[3]; end
                10'd30: begin alu_addr = 5'd0; alu_add_val = -16'sd81; alu_do_add = hid_spikes[0]; end
                10'd31: begin alu_addr = 5'd0; alu_add_val = -16'sd51; alu_do_add = hid_spikes[1]; end
                10'd32: begin alu_addr = 5'd0; alu_add_val = 16'sd53; alu_do_add = hid_spikes[4]; end
                10'd33: begin alu_addr = 5'd0; alu_add_val = -16'sd41; alu_do_add = hid_spikes[5]; end
                10'd34: begin alu_addr = 5'd0; alu_add_val = -16'sd57; alu_do_add = hid_spikes[6]; end
                10'd35: begin alu_addr = 5'd0; alu_add_val = -16'sd51; alu_do_add = hid_spikes[7]; end
                10'd36: begin alu_addr = 5'd0; alu_add_val = -16'sd43; alu_do_add = hid_spikes[8]; end
                10'd37: begin alu_addr = 5'd0; alu_add_val = 16'sd93; alu_do_add = hid_spikes[9]; end
                10'd38: begin alu_addr = 5'd0; alu_add_val = 16'sd110; alu_do_add = hid_spikes[10]; end
                10'd39: begin alu_addr = 5'd0; alu_add_val = -16'sd32; alu_do_add = hid_spikes[11]; end
                10'd40: begin alu_addr = 5'd0; alu_add_val = -16'sd34; alu_do_add = hid_spikes[12]; end
                10'd41: begin alu_addr = 5'd0; alu_add_val = -16'sd44; alu_do_add = hid_spikes[14]; end
                10'd42: begin alu_addr = 5'd0; alu_add_val = 16'sd107; alu_do_add = hid_spikes[16]; end
                10'd43: begin alu_addr = 5'd0; alu_add_val = -16'sd71; alu_do_add = hid_spikes[17]; end
                10'd44: begin alu_addr = 5'd0; alu_add_val = -16'sd82; alu_do_add = hid_spikes[18]; end
                10'd45: begin alu_addr = 5'd0; alu_add_val = 16'sd45; alu_do_add = hid_spikes[22]; end
                10'd46: begin alu_addr = 5'd1; alu_add_val = 16'sd44; alu_do_add = in_spikes[3]; end
                10'd47: begin alu_addr = 5'd1; alu_add_val = 16'sd46; alu_do_add = hid_spikes[1]; end
                10'd48: begin alu_addr = 5'd1; alu_add_val = -16'sd58; alu_do_add = hid_spikes[9]; end
                10'd49: begin alu_addr = 5'd1; alu_add_val = 16'sd43; alu_do_add = hid_spikes[10]; end
                10'd50: begin alu_addr = 5'd1; alu_add_val = -16'sd35; alu_do_add = hid_spikes[12]; end
                10'd51: begin alu_addr = 5'd1; alu_add_val = -16'sd32; alu_do_add = hid_spikes[17]; end
                10'd52: begin alu_addr = 5'd1; alu_add_val = -16'sd50; alu_do_add = hid_spikes[23]; end
                10'd53: begin alu_addr = 5'd2; alu_add_val = 16'sd50; alu_do_add = in_spikes[6]; end
                10'd54: begin alu_addr = 5'd2; alu_add_val = 16'sd88; alu_do_add = hid_spikes[2]; end
                10'd55: begin alu_addr = 5'd2; alu_add_val = -16'sd42; alu_do_add = hid_spikes[12]; end
                10'd56: begin alu_addr = 5'd2; alu_add_val = 16'sd41; alu_do_add = hid_spikes[15]; end
                10'd57: begin alu_addr = 5'd2; alu_add_val = -16'sd49; alu_do_add = hid_spikes[23]; end
                10'd58: begin alu_addr = 5'd3; alu_add_val = 16'sd51; alu_do_add = hid_spikes[0]; end
                10'd59: begin alu_addr = 5'd3; alu_add_val = -16'sd76; alu_do_add = hid_spikes[1]; end
                10'd60: begin alu_addr = 5'd3; alu_add_val = -16'sd71; alu_do_add = hid_spikes[2]; end
                10'd61: begin alu_addr = 5'd3; alu_add_val = 16'sd47; alu_do_add = hid_spikes[3]; end
                10'd62: begin alu_addr = 5'd3; alu_add_val = 16'sd46; alu_do_add = hid_spikes[4]; end
                10'd63: begin alu_addr = 5'd3; alu_add_val = 16'sd48; alu_do_add = hid_spikes[7]; end
                10'd64: begin alu_addr = 5'd3; alu_add_val = 16'sd35; alu_do_add = hid_spikes[9]; end
                10'd65: begin alu_addr = 5'd3; alu_add_val = 16'sd126; alu_do_add = hid_spikes[10]; end
                10'd66: begin alu_addr = 5'd3; alu_add_val = -16'sd52; alu_do_add = hid_spikes[15]; end
                10'd67: begin alu_addr = 5'd3; alu_add_val = 16'sd116; alu_do_add = hid_spikes[16]; end
                10'd68: begin alu_addr = 5'd3; alu_add_val = -16'sd35; alu_do_add = hid_spikes[17]; end
                10'd69: begin alu_addr = 5'd3; alu_add_val = 16'sd67; alu_do_add = hid_spikes[19]; end
                10'd70: begin alu_addr = 5'd3; alu_add_val = -16'sd31; alu_do_add = hid_spikes[23]; end
                10'd71: begin alu_addr = 5'd4; alu_add_val = 16'sd55; alu_do_add = in_spikes[3]; end
                10'd72: begin alu_addr = 5'd4; alu_add_val = -16'sd44; alu_do_add = hid_spikes[2]; end
                10'd73: begin alu_addr = 5'd4; alu_add_val = -16'sd87; alu_do_add = hid_spikes[4]; end
                10'd74: begin alu_addr = 5'd4; alu_add_val = -16'sd43; alu_do_add = hid_spikes[5]; end
                10'd75: begin alu_addr = 5'd4; alu_add_val = -16'sd105; alu_do_add = hid_spikes[6]; end
                10'd76: begin alu_addr = 5'd4; alu_add_val = 16'sd47; alu_do_add = hid_spikes[10]; end
                10'd77: begin alu_addr = 5'd4; alu_add_val = -16'sd68; alu_do_add = hid_spikes[12]; end
                10'd78: begin alu_addr = 5'd4; alu_add_val = -16'sd42; alu_do_add = hid_spikes[13]; end
                10'd79: begin alu_addr = 5'd4; alu_add_val = -16'sd55; alu_do_add = hid_spikes[14]; end
                10'd80: begin alu_addr = 5'd4; alu_add_val = -16'sd31; alu_do_add = hid_spikes[15]; end
                10'd81: begin alu_addr = 5'd4; alu_add_val = -16'sd127; alu_do_add = hid_spikes[17]; end
                10'd82: begin alu_addr = 5'd4; alu_add_val = -16'sd31; alu_do_add = hid_spikes[19]; end
                10'd83: begin alu_addr = 5'd4; alu_add_val = -16'sd44; alu_do_add = hid_spikes[20]; end
                10'd84: begin alu_addr = 5'd4; alu_add_val = -16'sd43; alu_do_add = hid_spikes[21]; end
                10'd85: begin alu_addr = 5'd4; alu_add_val = -16'sd86; alu_do_add = hid_spikes[22]; end
                10'd86: begin alu_addr = 5'd4; alu_add_val = -16'sd41; alu_do_add = hid_spikes[23]; end
                10'd87: begin alu_addr = 5'd5; alu_add_val = 16'sd32; alu_do_add = in_spikes[3]; end
                10'd88: begin alu_addr = 5'd5; alu_add_val = 16'sd38; alu_do_add = hid_spikes[1]; end
                10'd89: begin alu_addr = 5'd5; alu_add_val = 16'sd41; alu_do_add = hid_spikes[4]; end
                10'd90: begin alu_addr = 5'd5; alu_add_val = 16'sd39; alu_do_add = hid_spikes[10]; end
                10'd91: begin alu_addr = 5'd5; alu_add_val = -16'sd47; alu_do_add = hid_spikes[12]; end
                10'd92: begin alu_addr = 5'd5; alu_add_val = 16'sd44; alu_do_add = hid_spikes[16]; end
                10'd93: begin alu_addr = 5'd5; alu_add_val = -16'sd84; alu_do_add = hid_spikes[17]; end
                10'd94: begin alu_addr = 5'd5; alu_add_val = -16'sd102; alu_do_add = hid_spikes[18]; end
                10'd95: begin alu_addr = 5'd5; alu_add_val = -16'sd43; alu_do_add = hid_spikes[19]; end
                10'd96: begin alu_addr = 5'd5; alu_add_val = -16'sd63; alu_do_add = hid_spikes[20]; end
                10'd97: begin alu_addr = 5'd5; alu_add_val = 16'sd55; alu_do_add = hid_spikes[22]; end
                10'd98: begin alu_addr = 5'd5; alu_add_val = -16'sd35; alu_do_add = hid_spikes[23]; end
                10'd99: begin alu_addr = 5'd6; alu_add_val = -16'sd33; alu_do_add = in_spikes[1]; end
                10'd100: begin alu_addr = 5'd6; alu_add_val = -16'sd34; alu_do_add = hid_spikes[2]; end
                10'd101: begin alu_addr = 5'd6; alu_add_val = -16'sd65; alu_do_add = hid_spikes[5]; end
                10'd102: begin alu_addr = 5'd6; alu_add_val = 16'sd81; alu_do_add = hid_spikes[10]; end
                10'd103: begin alu_addr = 5'd6; alu_add_val = -16'sd65; alu_do_add = hid_spikes[13]; end
                10'd104: begin alu_addr = 5'd6; alu_add_val = 16'sd105; alu_do_add = hid_spikes[16]; end
                10'd105: begin alu_addr = 5'd6; alu_add_val = -16'sd76; alu_do_add = hid_spikes[17]; end
                10'd106: begin alu_addr = 5'd6; alu_add_val = -16'sd40; alu_do_add = hid_spikes[18]; end
                10'd107: begin alu_addr = 5'd6; alu_add_val = -16'sd37; alu_do_add = hid_spikes[19]; end
                10'd108: begin alu_addr = 5'd6; alu_add_val = -16'sd37; alu_do_add = hid_spikes[21]; end
                10'd109: begin alu_addr = 5'd6; alu_add_val = 16'sd58; alu_do_add = hid_spikes[22]; end
                10'd110: begin alu_addr = 5'd6; alu_add_val = -16'sd31; alu_do_add = hid_spikes[23]; end
                10'd111: begin alu_addr = 5'd7; alu_add_val = -16'sd34; alu_do_add = in_spikes[0]; end
                10'd112: begin alu_addr = 5'd7; alu_add_val = 16'sd41; alu_do_add = in_spikes[3]; end
                10'd113: begin alu_addr = 5'd7; alu_add_val = -16'sd45; alu_do_add = hid_spikes[1]; end
                10'd114: begin alu_addr = 5'd7; alu_add_val = -16'sd46; alu_do_add = hid_spikes[2]; end
                10'd115: begin alu_addr = 5'd7; alu_add_val = -16'sd64; alu_do_add = hid_spikes[3]; end
                10'd116: begin alu_addr = 5'd7; alu_add_val = 16'sd49; alu_do_add = hid_spikes[4]; end
                10'd117: begin alu_addr = 5'd7; alu_add_val = 16'sd73; alu_do_add = hid_spikes[10]; end
                10'd118: begin alu_addr = 5'd7; alu_add_val = -16'sd46; alu_do_add = hid_spikes[11]; end
                10'd119: begin alu_addr = 5'd7; alu_add_val = -16'sd32; alu_do_add = hid_spikes[12]; end
                10'd120: begin alu_addr = 5'd7; alu_add_val = -16'sd78; alu_do_add = hid_spikes[14]; end
                10'd121: begin alu_addr = 5'd7; alu_add_val = 16'sd127; alu_do_add = hid_spikes[16]; end
                10'd122: begin alu_addr = 5'd7; alu_add_val = -16'sd52; alu_do_add = hid_spikes[17]; end
                10'd123: begin alu_addr = 5'd7; alu_add_val = -16'sd84; alu_do_add = hid_spikes[18]; end
                10'd124: begin alu_addr = 5'd7; alu_add_val = -16'sd93; alu_do_add = hid_spikes[19]; end
                10'd125: begin alu_addr = 5'd7; alu_add_val = -16'sd34; alu_do_add = hid_spikes[21]; end
                10'd126: begin alu_addr = 5'd7; alu_add_val = -16'sd34; alu_do_add = hid_spikes[23]; end
                10'd127: begin alu_addr = 5'd8; alu_add_val = -16'sd33; alu_do_add = in_spikes[1]; end
                10'd128: begin alu_addr = 5'd8; alu_add_val = 16'sd54; alu_do_add = in_spikes[3]; end
                10'd129: begin alu_addr = 5'd8; alu_add_val = -16'sd92; alu_do_add = hid_spikes[1]; end
                10'd130: begin alu_addr = 5'd8; alu_add_val = -16'sd71; alu_do_add = hid_spikes[2]; end
                10'd131: begin alu_addr = 5'd8; alu_add_val = -16'sd45; alu_do_add = hid_spikes[5]; end
                10'd132: begin alu_addr = 5'd8; alu_add_val = -16'sd82; alu_do_add = hid_spikes[6]; end
                10'd133: begin alu_addr = 5'd8; alu_add_val = -16'sd35; alu_do_add = hid_spikes[7]; end
                10'd134: begin alu_addr = 5'd8; alu_add_val = -16'sd127; alu_do_add = hid_spikes[8]; end
                10'd135: begin alu_addr = 5'd8; alu_add_val = -16'sd99; alu_do_add = hid_spikes[9]; end
                10'd136: begin alu_addr = 5'd8; alu_add_val = -16'sd32; alu_do_add = hid_spikes[10]; end
                10'd137: begin alu_addr = 5'd8; alu_add_val = -16'sd90; alu_do_add = hid_spikes[13]; end
                10'd138: begin alu_addr = 5'd8; alu_add_val = -16'sd93; alu_do_add = hid_spikes[14]; end
                10'd139: begin alu_addr = 5'd8; alu_add_val = 16'sd31; alu_do_add = hid_spikes[17]; end
                10'd140: begin alu_addr = 5'd8; alu_add_val = -16'sd89; alu_do_add = hid_spikes[19]; end
                10'd141: begin alu_addr = 5'd8; alu_add_val = -16'sd31; alu_do_add = hid_spikes[21]; end
                10'd142: begin alu_addr = 5'd8; alu_add_val = -16'sd119; alu_do_add = hid_spikes[22]; end
                10'd143: begin alu_addr = 5'd8; alu_add_val = -16'sd42; alu_do_add = hid_spikes[23]; end
                10'd144: begin alu_addr = 5'd9; alu_add_val = -16'sd45; alu_do_add = in_spikes[3]; end
                10'd145: begin alu_addr = 5'd9; alu_add_val = 16'sd83; alu_do_add = hid_spikes[4]; end
                10'd146: begin alu_addr = 5'd9; alu_add_val = -16'sd43; alu_do_add = hid_spikes[6]; end
                10'd147: begin alu_addr = 5'd9; alu_add_val = 16'sd50; alu_do_add = hid_spikes[8]; end
                10'd148: begin alu_addr = 5'd9; alu_add_val = 16'sd69; alu_do_add = hid_spikes[9]; end
                10'd149: begin alu_addr = 5'd9; alu_add_val = 16'sd67; alu_do_add = hid_spikes[10]; end
                10'd150: begin alu_addr = 5'd9; alu_add_val = 16'sd37; alu_do_add = hid_spikes[11]; end
                10'd151: begin alu_addr = 5'd9; alu_add_val = -16'sd49; alu_do_add = hid_spikes[15]; end
                10'd152: begin alu_addr = 5'd9; alu_add_val = 16'sd49; alu_do_add = hid_spikes[16]; end
                10'd153: begin alu_addr = 5'd9; alu_add_val = 16'sd43; alu_do_add = hid_spikes[22]; end
                10'd154: begin alu_addr = 5'd10; alu_add_val = 16'sd53; alu_do_add = in_spikes[3]; end
                10'd155: begin alu_addr = 5'd10; alu_add_val = 16'sd38; alu_do_add = in_spikes[6]; end
                10'd156: begin alu_addr = 5'd10; alu_add_val = -16'sd33; alu_do_add = hid_spikes[4]; end
                10'd157: begin alu_addr = 5'd10; alu_add_val = -16'sd110; alu_do_add = hid_spikes[6]; end
                10'd158: begin alu_addr = 5'd10; alu_add_val = 16'sd51; alu_do_add = hid_spikes[8]; end
                10'd159: begin alu_addr = 5'd10; alu_add_val = 16'sd127; alu_do_add = hid_spikes[9]; end
                10'd160: begin alu_addr = 5'd10; alu_add_val = -16'sd78; alu_do_add = hid_spikes[12]; end
                10'd161: begin alu_addr = 5'd10; alu_add_val = -16'sd38; alu_do_add = hid_spikes[15]; end
                10'd162: begin alu_addr = 5'd10; alu_add_val = 16'sd49; alu_do_add = hid_spikes[16]; end
                10'd163: begin alu_addr = 5'd10; alu_add_val = -16'sd109; alu_do_add = hid_spikes[17]; end
                10'd164: begin alu_addr = 5'd10; alu_add_val = -16'sd59; alu_do_add = hid_spikes[21]; end
                10'd165: begin alu_addr = 5'd10; alu_add_val = -16'sd42; alu_do_add = hid_spikes[23]; end
                10'd166: begin alu_addr = 5'd11; alu_add_val = -16'sd40; alu_do_add = hid_spikes[2]; end
                10'd167: begin alu_addr = 5'd11; alu_add_val = -16'sd63; alu_do_add = hid_spikes[3]; end
                10'd168: begin alu_addr = 5'd11; alu_add_val = -16'sd80; alu_do_add = hid_spikes[6]; end
                10'd169: begin alu_addr = 5'd11; alu_add_val = 16'sd47; alu_do_add = hid_spikes[8]; end
                10'd170: begin alu_addr = 5'd11; alu_add_val = -16'sd66; alu_do_add = hid_spikes[9]; end
                10'd171: begin alu_addr = 5'd11; alu_add_val = -16'sd56; alu_do_add = hid_spikes[12]; end
                10'd172: begin alu_addr = 5'd11; alu_add_val = -16'sd36; alu_do_add = hid_spikes[13]; end
                10'd173: begin alu_addr = 5'd11; alu_add_val = -16'sd53; alu_do_add = hid_spikes[14]; end
                10'd174: begin alu_addr = 5'd11; alu_add_val = -16'sd49; alu_do_add = hid_spikes[15]; end
                10'd175: begin alu_addr = 5'd11; alu_add_val = -16'sd42; alu_do_add = hid_spikes[17]; end
                10'd176: begin alu_addr = 5'd11; alu_add_val = -16'sd56; alu_do_add = hid_spikes[18]; end
                10'd177: begin alu_addr = 5'd11; alu_add_val = -16'sd67; alu_do_add = hid_spikes[19]; end
                10'd178: begin alu_addr = 5'd11; alu_add_val = -16'sd63; alu_do_add = hid_spikes[20]; end
                10'd179: begin alu_addr = 5'd11; alu_add_val = -16'sd122; alu_do_add = hid_spikes[22]; end
                10'd180: begin alu_addr = 5'd12; alu_add_val = 16'sd75; alu_do_add = hid_spikes[0]; end
                10'd181: begin alu_addr = 5'd12; alu_add_val = 16'sd37; alu_do_add = hid_spikes[1]; end
                10'd182: begin alu_addr = 5'd12; alu_add_val = 16'sd106; alu_do_add = hid_spikes[4]; end
                10'd183: begin alu_addr = 5'd12; alu_add_val = 16'sd32; alu_do_add = hid_spikes[5]; end
                10'd184: begin alu_addr = 5'd12; alu_add_val = 16'sd110; alu_do_add = hid_spikes[6]; end
                10'd185: begin alu_addr = 5'd12; alu_add_val = 16'sd54; alu_do_add = hid_spikes[7]; end
                10'd186: begin alu_addr = 5'd12; alu_add_val = -16'sd127; alu_do_add = hid_spikes[8]; end
                10'd187: begin alu_addr = 5'd12; alu_add_val = -16'sd33; alu_do_add = hid_spikes[9]; end
                10'd188: begin alu_addr = 5'd12; alu_add_val = 16'sd77; alu_do_add = hid_spikes[10]; end
                10'd189: begin alu_addr = 5'd12; alu_add_val = 16'sd44; alu_do_add = hid_spikes[14]; end
                10'd190: begin alu_addr = 5'd12; alu_add_val = 16'sd33; alu_do_add = hid_spikes[16]; end
                10'd191: begin alu_addr = 5'd12; alu_add_val = 16'sd36; alu_do_add = hid_spikes[18]; end
                10'd192: begin alu_addr = 5'd12; alu_add_val = 16'sd77; alu_do_add = hid_spikes[21]; end
                10'd193: begin alu_addr = 5'd12; alu_add_val = -16'sd92; alu_do_add = hid_spikes[22]; end
                10'd194: begin alu_addr = 5'd13; alu_add_val = -16'sd127; alu_do_add = in_spikes[0]; end
                10'd195: begin alu_addr = 5'd13; alu_add_val = -16'sd127; alu_do_add = in_spikes[1]; end
                10'd196: begin alu_addr = 5'd13; alu_add_val = 16'sd43; alu_do_add = in_spikes[3]; end
                10'd197: begin alu_addr = 5'd13; alu_add_val = 16'sd45; alu_do_add = in_spikes[6]; end
                10'd198: begin alu_addr = 5'd13; alu_add_val = 16'sd47; alu_do_add = hid_spikes[3]; end
                10'd199: begin alu_addr = 5'd13; alu_add_val = -16'sd55; alu_do_add = hid_spikes[6]; end
                10'd200: begin alu_addr = 5'd13; alu_add_val = 16'sd72; alu_do_add = hid_spikes[9]; end
                10'd201: begin alu_addr = 5'd13; alu_add_val = 16'sd62; alu_do_add = hid_spikes[13]; end
                10'd202: begin alu_addr = 5'd13; alu_add_val = -16'sd53; alu_do_add = hid_spikes[21]; end
                10'd203: begin alu_addr = 5'd13; alu_add_val = -16'sd89; alu_do_add = hid_spikes[22]; end
                10'd204: begin alu_addr = 5'd13; alu_add_val = -16'sd34; alu_do_add = hid_spikes[23]; end
                10'd205: begin alu_addr = 5'd14; alu_add_val = -16'sd69; alu_do_add = hid_spikes[1]; end
                10'd206: begin alu_addr = 5'd14; alu_add_val = -16'sd85; alu_do_add = hid_spikes[2]; end
                10'd207: begin alu_addr = 5'd14; alu_add_val = 16'sd54; alu_do_add = hid_spikes[10]; end
                10'd208: begin alu_addr = 5'd14; alu_add_val = -16'sd43; alu_do_add = hid_spikes[13]; end
                10'd209: begin alu_addr = 5'd14; alu_add_val = 16'sd91; alu_do_add = hid_spikes[16]; end
                10'd210: begin alu_addr = 5'd14; alu_add_val = -16'sd55; alu_do_add = hid_spikes[20]; end
                10'd211: begin alu_addr = 5'd15; alu_add_val = -16'sd127; alu_do_add = in_spikes[1]; end
                10'd212: begin alu_addr = 5'd15; alu_add_val = -16'sd58; alu_do_add = in_spikes[6]; end
                10'd213: begin alu_addr = 5'd15; alu_add_val = -16'sd65; alu_do_add = hid_spikes[1]; end
                10'd214: begin alu_addr = 5'd15; alu_add_val = -16'sd81; alu_do_add = hid_spikes[2]; end
                10'd215: begin alu_addr = 5'd15; alu_add_val = 16'sd51; alu_do_add = hid_spikes[4]; end
                10'd216: begin alu_addr = 5'd15; alu_add_val = -16'sd46; alu_do_add = hid_spikes[6]; end
                10'd217: begin alu_addr = 5'd15; alu_add_val = -16'sd67; alu_do_add = hid_spikes[9]; end
                10'd218: begin alu_addr = 5'd15; alu_add_val = 16'sd36; alu_do_add = hid_spikes[10]; end
                10'd219: begin alu_addr = 5'd15; alu_add_val = 16'sd65; alu_do_add = hid_spikes[15]; end
                10'd220: begin alu_addr = 5'd15; alu_add_val = 16'sd32; alu_do_add = hid_spikes[16]; end
                10'd221: begin alu_addr = 5'd15; alu_add_val = -16'sd127; alu_do_add = hid_spikes[17]; end
                10'd222: begin alu_addr = 5'd15; alu_add_val = -16'sd103; alu_do_add = hid_spikes[22]; end
                10'd223: begin alu_addr = 5'd15; alu_add_val = -16'sd35; alu_do_add = hid_spikes[23]; end
                10'd224: begin alu_addr = 5'd16; alu_add_val = 16'sd61; alu_do_add = in_spikes[3]; end
                10'd225: begin alu_addr = 5'd16; alu_add_val = -16'sd39; alu_do_add = hid_spikes[1]; end
                10'd226: begin alu_addr = 5'd16; alu_add_val = -16'sd62; alu_do_add = hid_spikes[2]; end
                10'd227: begin alu_addr = 5'd16; alu_add_val = -16'sd55; alu_do_add = hid_spikes[6]; end
                10'd228: begin alu_addr = 5'd16; alu_add_val = 16'sd38; alu_do_add = hid_spikes[8]; end
                10'd229: begin alu_addr = 5'd16; alu_add_val = 16'sd127; alu_do_add = hid_spikes[9]; end
                10'd230: begin alu_addr = 5'd16; alu_add_val = -16'sd88; alu_do_add = hid_spikes[12]; end
                10'd231: begin alu_addr = 5'd16; alu_add_val = -16'sd32; alu_do_add = hid_spikes[13]; end
                10'd232: begin alu_addr = 5'd16; alu_add_val = -16'sd51; alu_do_add = hid_spikes[15]; end
                10'd233: begin alu_addr = 5'd16; alu_add_val = -16'sd67; alu_do_add = hid_spikes[17]; end
                10'd234: begin alu_addr = 5'd16; alu_add_val = -16'sd36; alu_do_add = hid_spikes[18]; end
                10'd235: begin alu_addr = 5'd16; alu_add_val = -16'sd38; alu_do_add = hid_spikes[20]; end
                10'd236: begin alu_addr = 5'd16; alu_add_val = -16'sd46; alu_do_add = hid_spikes[21]; end
                10'd237: begin alu_addr = 5'd16; alu_add_val = 16'sd127; alu_do_add = hid_spikes[22]; end
                10'd238: begin alu_addr = 5'd16; alu_add_val = -16'sd42; alu_do_add = hid_spikes[23]; end
                10'd239: begin alu_addr = 5'd17; alu_add_val = -16'sd32; alu_do_add = in_spikes[1]; end
                10'd240: begin alu_addr = 5'd17; alu_add_val = 16'sd74; alu_do_add = in_spikes[2]; end
                10'd241: begin alu_addr = 5'd17; alu_add_val = 16'sd54; alu_do_add = in_spikes[3]; end
                10'd242: begin alu_addr = 5'd17; alu_add_val = -16'sd127; alu_do_add = in_spikes[6]; end
                10'd243: begin alu_addr = 5'd17; alu_add_val = 16'sd40; alu_do_add = hid_spikes[3]; end
                10'd244: begin alu_addr = 5'd17; alu_add_val = -16'sd40; alu_do_add = hid_spikes[5]; end
                10'd245: begin alu_addr = 5'd17; alu_add_val = -16'sd34; alu_do_add = hid_spikes[9]; end
                10'd246: begin alu_addr = 5'd17; alu_add_val = -16'sd44; alu_do_add = hid_spikes[13]; end
                10'd247: begin alu_addr = 5'd17; alu_add_val = 16'sd33; alu_do_add = hid_spikes[14]; end
                10'd248: begin alu_addr = 5'd17; alu_add_val = 16'sd101; alu_do_add = hid_spikes[17]; end
                10'd249: begin alu_addr = 5'd17; alu_add_val = -16'sd56; alu_do_add = hid_spikes[18]; end
                10'd250: begin alu_addr = 5'd17; alu_add_val = -16'sd71; alu_do_add = hid_spikes[20]; end
                10'd251: begin alu_addr = 5'd17; alu_add_val = -16'sd60; alu_do_add = hid_spikes[22]; end
                10'd252: begin alu_addr = 5'd17; alu_add_val = -16'sd66; alu_do_add = hid_spikes[23]; end
                10'd253: begin alu_addr = 5'd18; alu_add_val = 16'sd36; alu_do_add = in_spikes[1]; end
                10'd254: begin alu_addr = 5'd18; alu_add_val = 16'sd43; alu_do_add = hid_spikes[0]; end
                10'd255: begin alu_addr = 5'd18; alu_add_val = -16'sd63; alu_do_add = hid_spikes[1]; end
                10'd256: begin alu_addr = 5'd18; alu_add_val = -16'sd52; alu_do_add = hid_spikes[2]; end
                10'd257: begin alu_addr = 5'd18; alu_add_val = 16'sd52; alu_do_add = hid_spikes[4]; end
                10'd258: begin alu_addr = 5'd18; alu_add_val = 16'sd45; alu_do_add = hid_spikes[7]; end
                10'd259: begin alu_addr = 5'd18; alu_add_val = 16'sd32; alu_do_add = hid_spikes[8]; end
                10'd260: begin alu_addr = 5'd18; alu_add_val = 16'sd77; alu_do_add = hid_spikes[10]; end
                10'd261: begin alu_addr = 5'd18; alu_add_val = -16'sd41; alu_do_add = hid_spikes[15]; end
                10'd262: begin alu_addr = 5'd18; alu_add_val = 16'sd66; alu_do_add = hid_spikes[16]; end
                10'd263: begin alu_addr = 5'd18; alu_add_val = -16'sd127; alu_do_add = hid_spikes[17]; end
                10'd264: begin alu_addr = 5'd18; alu_add_val = -16'sd72; alu_do_add = hid_spikes[18]; end
                10'd265: begin alu_addr = 5'd18; alu_add_val = -16'sd41; alu_do_add = hid_spikes[20]; end
                10'd266: begin alu_addr = 5'd19; alu_add_val = -16'sd34; alu_do_add = hid_spikes[3]; end
                10'd267: begin alu_addr = 5'd19; alu_add_val = 16'sd59; alu_do_add = hid_spikes[4]; end
                10'd268: begin alu_addr = 5'd19; alu_add_val = -16'sd32; alu_do_add = hid_spikes[7]; end
                10'd269: begin alu_addr = 5'd19; alu_add_val = 16'sd53; alu_do_add = hid_spikes[9]; end
                10'd270: begin alu_addr = 5'd19; alu_add_val = 16'sd90; alu_do_add = hid_spikes[10]; end
                10'd271: begin alu_addr = 5'd19; alu_add_val = -16'sd54; alu_do_add = hid_spikes[11]; end
                10'd272: begin alu_addr = 5'd19; alu_add_val = -16'sd46; alu_do_add = hid_spikes[12]; end
                10'd273: begin alu_addr = 5'd19; alu_add_val = -16'sd63; alu_do_add = hid_spikes[15]; end
                10'd274: begin alu_addr = 5'd19; alu_add_val = 16'sd68; alu_do_add = hid_spikes[16]; end
                10'd275: begin alu_addr = 5'd19; alu_add_val = -16'sd80; alu_do_add = hid_spikes[18]; end
                10'd276: begin alu_addr = 5'd19; alu_add_val = -16'sd61; alu_do_add = hid_spikes[19]; end
                10'd277: begin alu_addr = 5'd19; alu_add_val = -16'sd87; alu_do_add = hid_spikes[20]; end
                10'd278: begin alu_addr = 5'd20; alu_add_val = 16'sd109; alu_do_add = hid_spikes[0]; end
                10'd279: begin alu_addr = 5'd20; alu_add_val = -16'sd88; alu_do_add = hid_spikes[2]; end
                10'd280: begin alu_addr = 5'd20; alu_add_val = 16'sd55; alu_do_add = hid_spikes[3]; end
                10'd281: begin alu_addr = 5'd20; alu_add_val = 16'sd81; alu_do_add = hid_spikes[4]; end
                10'd282: begin alu_addr = 5'd20; alu_add_val = 16'sd42; alu_do_add = hid_spikes[5]; end
                10'd283: begin alu_addr = 5'd20; alu_add_val = 16'sd41; alu_do_add = hid_spikes[7]; end
                10'd284: begin alu_addr = 5'd20; alu_add_val = 16'sd97; alu_do_add = hid_spikes[9]; end
                10'd285: begin alu_addr = 5'd20; alu_add_val = 16'sd102; alu_do_add = hid_spikes[10]; end
                10'd286: begin alu_addr = 5'd20; alu_add_val = 16'sd32; alu_do_add = hid_spikes[12]; end
                10'd287: begin alu_addr = 5'd20; alu_add_val = 16'sd34; alu_do_add = hid_spikes[14]; end
                10'd288: begin alu_addr = 5'd20; alu_add_val = 16'sd60; alu_do_add = hid_spikes[15]; end
                10'd289: begin alu_addr = 5'd20; alu_add_val = 16'sd66; alu_do_add = hid_spikes[16]; end
                10'd290: begin alu_addr = 5'd20; alu_add_val = -16'sd127; alu_do_add = hid_spikes[17]; end
                10'd291: begin alu_addr = 5'd20; alu_add_val = 16'sd31; alu_do_add = hid_spikes[19]; end
                10'd292: begin alu_addr = 5'd20; alu_add_val = 16'sd60; alu_do_add = hid_spikes[20]; end
                10'd293: begin alu_addr = 5'd20; alu_add_val = 16'sd67; alu_do_add = hid_spikes[21]; end
                10'd294: begin alu_addr = 5'd20; alu_add_val = 16'sd98; alu_do_add = hid_spikes[22]; end
                10'd295: begin alu_addr = 5'd21; alu_add_val = 16'sd49; alu_do_add = in_spikes[3]; end
                10'd296: begin alu_addr = 5'd21; alu_add_val = 16'sd32; alu_do_add = hid_spikes[0]; end
                10'd297: begin alu_addr = 5'd21; alu_add_val = 16'sd48; alu_do_add = hid_spikes[10]; end
                10'd298: begin alu_addr = 5'd21; alu_add_val = 16'sd36; alu_do_add = hid_spikes[14]; end
                10'd299: begin alu_addr = 5'd21; alu_add_val = -16'sd109; alu_do_add = hid_spikes[17]; end
                10'd300: begin alu_addr = 5'd21; alu_add_val = 16'sd39; alu_do_add = hid_spikes[21]; end
                10'd301: begin alu_addr = 5'd21; alu_add_val = 16'sd34; alu_do_add = hid_spikes[22]; end
                10'd302: begin alu_addr = 5'd22; alu_add_val = -16'sd51; alu_do_add = hid_spikes[3]; end
                10'd303: begin alu_addr = 5'd22; alu_add_val = 16'sd56; alu_do_add = hid_spikes[4]; end
                10'd304: begin alu_addr = 5'd22; alu_add_val = 16'sd48; alu_do_add = hid_spikes[7]; end
                10'd305: begin alu_addr = 5'd22; alu_add_val = -16'sd99; alu_do_add = hid_spikes[9]; end
                10'd306: begin alu_addr = 5'd22; alu_add_val = 16'sd48; alu_do_add = hid_spikes[10]; end
                10'd307: begin alu_addr = 5'd22; alu_add_val = -16'sd59; alu_do_add = hid_spikes[11]; end
                10'd308: begin alu_addr = 5'd22; alu_add_val = -16'sd60; alu_do_add = hid_spikes[12]; end
                10'd309: begin alu_addr = 5'd22; alu_add_val = -16'sd49; alu_do_add = hid_spikes[13]; end
                10'd310: begin alu_addr = 5'd22; alu_add_val = -16'sd51; alu_do_add = hid_spikes[17]; end
                10'd311: begin alu_addr = 5'd22; alu_add_val = -16'sd59; alu_do_add = hid_spikes[18]; end
                10'd312: begin alu_addr = 5'd22; alu_add_val = -16'sd112; alu_do_add = hid_spikes[20]; end
                10'd313: begin alu_addr = 5'd22; alu_add_val = -16'sd38; alu_do_add = hid_spikes[22]; end
                10'd314: begin alu_addr = 5'd22; alu_add_val = -16'sd54; alu_do_add = hid_spikes[23]; end
                10'd315: begin alu_addr = 5'd23; alu_add_val = 16'sd38; alu_do_add = in_spikes[3]; end
                10'd316: begin alu_addr = 5'd23; alu_add_val = 16'sd43; alu_do_add = in_spikes[6]; end
                10'd317: begin alu_addr = 5'd23; alu_add_val = 16'sd34; alu_do_add = hid_spikes[3]; end
                10'd318: begin alu_addr = 5'd23; alu_add_val = 16'sd62; alu_do_add = hid_spikes[6]; end
                10'd319: begin alu_addr = 5'd23; alu_add_val = 16'sd37; alu_do_add = hid_spikes[7]; end
                10'd320: begin alu_addr = 5'd23; alu_add_val = -16'sd56; alu_do_add = hid_spikes[15]; end
                10'd321: begin alu_addr = 5'd23; alu_add_val = 16'sd34; alu_do_add = hid_spikes[17]; end
                10'd322: begin alu_addr = 5'd23; alu_add_val = 16'sd34; alu_do_add = hid_spikes[23]; end
                10'd323: begin alu_addr = 5'd24; alu_add_val = -16'sd78; alu_do_add = hid_spikes[1]; end
                10'd324: begin alu_addr = 5'd24; alu_add_val = -16'sd38; alu_do_add = hid_spikes[2]; end
                10'd325: begin alu_addr = 5'd24; alu_add_val = 16'sd35; alu_do_add = hid_spikes[4]; end
                10'd326: begin alu_addr = 5'd24; alu_add_val = 16'sd58; alu_do_add = hid_spikes[8]; end
                10'd327: begin alu_addr = 5'd24; alu_add_val = 16'sd67; alu_do_add = hid_spikes[10]; end
                10'd328: begin alu_addr = 5'd24; alu_add_val = -16'sd85; alu_do_add = hid_spikes[11]; end
                10'd329: begin alu_addr = 5'd24; alu_add_val = 16'sd46; alu_do_add = hid_spikes[16]; end
                10'd330: begin alu_addr = 5'd24; alu_add_val = -16'sd79; alu_do_add = hid_spikes[17]; end
                10'd331: begin alu_addr = 5'd24; alu_add_val = -16'sd42; alu_do_add = hid_spikes[21]; end
                10'd332: begin alu_addr = 5'd25; alu_add_val = 16'sd35; alu_do_add = hid_spikes[1]; end
                10'd333: begin alu_addr = 5'd25; alu_add_val = -16'sd50; alu_do_add = hid_spikes[2]; end
                10'd334: begin alu_addr = 5'd25; alu_add_val = 16'sd35; alu_do_add = hid_spikes[5]; end
                10'd335: begin alu_addr = 5'd25; alu_add_val = -16'sd42; alu_do_add = hid_spikes[8]; end
                10'd336: begin alu_addr = 5'd25; alu_add_val = -16'sd32; alu_do_add = hid_spikes[11]; end
                10'd337: begin alu_addr = 5'd25; alu_add_val = -16'sd66; alu_do_add = hid_spikes[13]; end
                10'd338: begin alu_addr = 5'd25; alu_add_val = 16'sd48; alu_do_add = hid_spikes[14]; end
                10'd339: begin alu_addr = 5'd25; alu_add_val = 16'sd34; alu_do_add = hid_spikes[15]; end
                10'd340: begin alu_addr = 5'd25; alu_add_val = -16'sd83; alu_do_add = hid_spikes[17]; end
                10'd341: begin alu_addr = 5'd25; alu_add_val = -16'sd42; alu_do_add = hid_spikes[18]; end
                10'd342: begin alu_addr = 5'd25; alu_add_val = 16'sd44; alu_do_add = hid_spikes[21]; end
                10'd343: begin alu_addr = 5'd25; alu_add_val = 16'sd127; alu_do_add = hid_spikes[22]; end
                10'd344: begin alu_addr = 5'd26; alu_add_val = -16'sd76; alu_do_add = hid_spikes[2]; end
                10'd345: begin alu_addr = 5'd26; alu_add_val = -16'sd31; alu_do_add = hid_spikes[6]; end
                10'd346: begin alu_addr = 5'd26; alu_add_val = 16'sd32; alu_do_add = hid_spikes[8]; end
                10'd347: begin alu_addr = 5'd26; alu_add_val = 16'sd107; alu_do_add = hid_spikes[9]; end
                10'd348: begin alu_addr = 5'd26; alu_add_val = 16'sd51; alu_do_add = hid_spikes[11]; end
                10'd349: begin alu_addr = 5'd26; alu_add_val = 16'sd34; alu_do_add = hid_spikes[13]; end
                10'd350: begin alu_addr = 5'd26; alu_add_val = -16'sd127; alu_do_add = hid_spikes[17]; end
                10'd351: begin alu_addr = 5'd27; alu_add_val = -16'sd61; alu_do_add = hid_spikes[2]; end
                10'd352: begin alu_addr = 5'd27; alu_add_val = -16'sd33; alu_do_add = hid_spikes[6]; end
                10'd353: begin alu_addr = 5'd27; alu_add_val = 16'sd67; alu_do_add = hid_spikes[9]; end
                10'd354: begin alu_addr = 5'd28; alu_add_val = 16'sd63; alu_do_add = hid_spikes[8]; end
                10'd355: begin alu_addr = 5'd28; alu_add_val = 16'sd107; alu_do_add = hid_spikes[9]; end
                10'd356: begin alu_addr = 5'd28; alu_add_val = -16'sd46; alu_do_add = hid_spikes[11]; end
                10'd357: begin alu_addr = 5'd28; alu_add_val = 16'sd35; alu_do_add = hid_spikes[15]; end
                10'd358: begin alu_addr = 5'd28; alu_add_val = 16'sd127; alu_do_add = hid_spikes[22]; end
            endcase
        end else if (state < 10'd388) begin
            alu_is_thresh = 1'b1;
            alu_addr = state - 10'd359;
        end
    end

    wire signed [15:0] current_v = mem[alu_addr];
    wire signed [15:0] thresh_val = (alu_addr < 24) ? 16'sd87 : 16'sd88;
    wire is_spike = (current_v >= thresh_val);

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 10'h3FF;
            hid_spikes <= 24'd0;
            out_spikes <= 5'd0;
            for (i = 0; i < 29; i = i + 1) mem[i] <= 16'sd0;
        end else if (tick_1ms) begin
            state <= 10'd0;
        end else if (state != 10'h3FF) begin
            if (alu_is_leak) mem[alu_addr] <= current_v - (current_v >>> alu_shift);
            else if (alu_is_thresh) begin
                mem[alu_addr] <= is_spike ? 16'sd0 : current_v;
                if (alu_addr < 24) hid_spikes[alu_addr] <= is_spike;
                else out_spikes[alu_addr - 24] <= is_spike;
            end else if (alu_do_add) begin
                mem[alu_addr] <= current_v + alu_add_val;
            end

            if (state == 10'd387) state <= 10'h3FF;
            else state <= state + 1;
        end
    end
endmodule