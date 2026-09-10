`default_nettype none
module snn_core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tick_1ms,
    input  wire [6:0]  in_spikes,
    output reg  [4:0] out_spikes
);

    reg [8:0] state;  // SHRUNK TO 9 BITS to dramatically reduce fanout logic
    reg signed [9:0] mem [0:28];
    reg [23:0] hid_spikes;

    // --- 10-BIT COMPACT ALU CONTROL ---
    reg [4:0] alu_tgt;
    reg [4:0] alu_src;
    reg alu_is_hid_src;
    reg signed [9:0] alu_w;
    reg [2:0] alu_shift;
    reg alu_is_leak, alu_is_syn, alu_is_thresh;

    always @(*) begin
        alu_tgt = 5'd0; alu_src = 5'd0; alu_is_hid_src = 1'b0; alu_w = 10'sd0;
        alu_shift = 3'd1; alu_is_leak = 1'b0; alu_is_syn = 1'b0; alu_is_thresh = 1'b0;

        if (state < 9'd29) begin
            alu_is_leak = 1'b1;
            alu_tgt = state[4:0];
            case(state)
                9'd0: alu_shift = 3'd2;
                9'd1: alu_shift = 3'd2;
                9'd2: alu_shift = 3'd2;
                9'd3: alu_shift = 3'd2;
                9'd4: alu_shift = 3'd2;
                9'd5: alu_shift = 3'd2;
                9'd6: alu_shift = 3'd2;
                9'd7: alu_shift = 3'd2;
                9'd8: alu_shift = 3'd2;
                9'd9: alu_shift = 3'd2;
                9'd10: alu_shift = 3'd2;
                9'd11: alu_shift = 3'd2;
                9'd12: alu_shift = 3'd2;
                9'd13: alu_shift = 3'd2;
                9'd14: alu_shift = 3'd2;
                9'd15: alu_shift = 3'd2;
                9'd16: alu_shift = 3'd2;
                9'd17: alu_shift = 3'd2;
                9'd18: alu_shift = 3'd2;
                9'd19: alu_shift = 3'd2;
                9'd20: alu_shift = 3'd2;
                9'd21: alu_shift = 3'd2;
                9'd22: alu_shift = 3'd2;
                9'd23: alu_shift = 3'd2;
                9'd24: alu_shift = 3'd2;
                9'd25: alu_shift = 3'd2;
                9'd26: alu_shift = 3'd2;
                9'd27: alu_shift = 3'd2;
                9'd28: alu_shift = 3'd2;
            endcase
        end else if (state < 9'd278) begin
            alu_is_syn = 1'b1;
            case(state)
                9'd29: begin alu_tgt = 5'd0; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd43; end
                9'd30: begin alu_tgt = 5'd0; alu_src = 5'd0; alu_is_hid_src = 1'b1; alu_w = -10'sd81; end
                9'd31: begin alu_tgt = 5'd0; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd51; end
                9'd32: begin alu_tgt = 5'd0; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd53; end
                9'd33: begin alu_tgt = 5'd0; alu_src = 5'd5; alu_is_hid_src = 1'b1; alu_w = -10'sd41; end
                9'd34: begin alu_tgt = 5'd0; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd57; end
                9'd35: begin alu_tgt = 5'd0; alu_src = 5'd7; alu_is_hid_src = 1'b1; alu_w = -10'sd51; end
                9'd36: begin alu_tgt = 5'd0; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = -10'sd43; end
                9'd37: begin alu_tgt = 5'd0; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd93; end
                9'd38: begin alu_tgt = 5'd0; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd110; end
                9'd39: begin alu_tgt = 5'd0; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = -10'sd44; end
                9'd40: begin alu_tgt = 5'd0; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd107; end
                9'd41: begin alu_tgt = 5'd0; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd71; end
                9'd42: begin alu_tgt = 5'd0; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd82; end
                9'd43: begin alu_tgt = 5'd0; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd45; end
                9'd44: begin alu_tgt = 5'd1; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd44; end
                9'd45: begin alu_tgt = 5'd1; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = 10'sd46; end
                9'd46: begin alu_tgt = 5'd1; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = -10'sd58; end
                9'd47: begin alu_tgt = 5'd1; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd43; end
                9'd48: begin alu_tgt = 5'd1; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd50; end
                9'd49: begin alu_tgt = 5'd2; alu_src = 5'd6; alu_is_hid_src = 1'b0; alu_w = 10'sd50; end
                9'd50: begin alu_tgt = 5'd2; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = 10'sd88; end
                9'd51: begin alu_tgt = 5'd2; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                9'd52: begin alu_tgt = 5'd2; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = 10'sd41; end
                9'd53: begin alu_tgt = 5'd2; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd49; end
                9'd54: begin alu_tgt = 5'd3; alu_src = 5'd0; alu_is_hid_src = 1'b1; alu_w = 10'sd51; end
                9'd55: begin alu_tgt = 5'd3; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd76; end
                9'd56: begin alu_tgt = 5'd3; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd71; end
                9'd57: begin alu_tgt = 5'd3; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = 10'sd47; end
                9'd58: begin alu_tgt = 5'd3; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd46; end
                9'd59: begin alu_tgt = 5'd3; alu_src = 5'd7; alu_is_hid_src = 1'b1; alu_w = 10'sd48; end
                9'd60: begin alu_tgt = 5'd3; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd126; end
                9'd61: begin alu_tgt = 5'd3; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd52; end
                9'd62: begin alu_tgt = 5'd3; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd116; end
                9'd63: begin alu_tgt = 5'd3; alu_src = 5'd19; alu_is_hid_src = 1'b1; alu_w = 10'sd67; end
                9'd64: begin alu_tgt = 5'd4; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd55; end
                9'd65: begin alu_tgt = 5'd4; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd44; end
                9'd66: begin alu_tgt = 5'd4; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = -10'sd87; end
                9'd67: begin alu_tgt = 5'd4; alu_src = 5'd5; alu_is_hid_src = 1'b1; alu_w = -10'sd43; end
                9'd68: begin alu_tgt = 5'd4; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd105; end
                9'd69: begin alu_tgt = 5'd4; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd47; end
                9'd70: begin alu_tgt = 5'd4; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd68; end
                9'd71: begin alu_tgt = 5'd4; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                9'd72: begin alu_tgt = 5'd4; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = -10'sd55; end
                9'd73: begin alu_tgt = 5'd4; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd127; end
                9'd74: begin alu_tgt = 5'd4; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd44; end
                9'd75: begin alu_tgt = 5'd4; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = -10'sd43; end
                9'd76: begin alu_tgt = 5'd4; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd86; end
                9'd77: begin alu_tgt = 5'd4; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd41; end
                9'd78: begin alu_tgt = 5'd5; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd41; end
                9'd79: begin alu_tgt = 5'd5; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd47; end
                9'd80: begin alu_tgt = 5'd5; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd44; end
                9'd81: begin alu_tgt = 5'd5; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd84; end
                9'd82: begin alu_tgt = 5'd5; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd102; end
                9'd83: begin alu_tgt = 5'd5; alu_src = 5'd19; alu_is_hid_src = 1'b1; alu_w = -10'sd43; end
                9'd84: begin alu_tgt = 5'd5; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd63; end
                9'd85: begin alu_tgt = 5'd5; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd55; end
                9'd86: begin alu_tgt = 5'd6; alu_src = 5'd5; alu_is_hid_src = 1'b1; alu_w = -10'sd65; end
                9'd87: begin alu_tgt = 5'd6; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd81; end
                9'd88: begin alu_tgt = 5'd6; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd65; end
                9'd89: begin alu_tgt = 5'd6; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd105; end
                9'd90: begin alu_tgt = 5'd6; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd76; end
                9'd91: begin alu_tgt = 5'd6; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd58; end
                9'd92: begin alu_tgt = 5'd7; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd41; end
                9'd93: begin alu_tgt = 5'd7; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd45; end
                9'd94: begin alu_tgt = 5'd7; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd46; end
                9'd95: begin alu_tgt = 5'd7; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = -10'sd64; end
                9'd96: begin alu_tgt = 5'd7; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd49; end
                9'd97: begin alu_tgt = 5'd7; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd73; end
                9'd98: begin alu_tgt = 5'd7; alu_src = 5'd11; alu_is_hid_src = 1'b1; alu_w = -10'sd46; end
                9'd99: begin alu_tgt = 5'd7; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = -10'sd78; end
                9'd100: begin alu_tgt = 5'd7; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd127; end
                9'd101: begin alu_tgt = 5'd7; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd52; end
                9'd102: begin alu_tgt = 5'd7; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd84; end
                9'd103: begin alu_tgt = 5'd7; alu_src = 5'd19; alu_is_hid_src = 1'b1; alu_w = -10'sd93; end
                9'd104: begin alu_tgt = 5'd8; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd54; end
                9'd105: begin alu_tgt = 5'd8; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd92; end
                9'd106: begin alu_tgt = 5'd8; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd71; end
                9'd107: begin alu_tgt = 5'd8; alu_src = 5'd5; alu_is_hid_src = 1'b1; alu_w = -10'sd45; end
                9'd108: begin alu_tgt = 5'd8; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd82; end
                9'd109: begin alu_tgt = 5'd8; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = -10'sd127; end
                9'd110: begin alu_tgt = 5'd8; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = -10'sd99; end
                9'd111: begin alu_tgt = 5'd8; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd90; end
                9'd112: begin alu_tgt = 5'd8; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = -10'sd93; end
                9'd113: begin alu_tgt = 5'd8; alu_src = 5'd19; alu_is_hid_src = 1'b1; alu_w = -10'sd89; end
                9'd114: begin alu_tgt = 5'd8; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd119; end
                9'd115: begin alu_tgt = 5'd8; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                9'd116: begin alu_tgt = 5'd9; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = -10'sd45; end
                9'd117: begin alu_tgt = 5'd9; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd83; end
                9'd118: begin alu_tgt = 5'd9; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd43; end
                9'd119: begin alu_tgt = 5'd9; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = 10'sd50; end
                9'd120: begin alu_tgt = 5'd9; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd69; end
                9'd121: begin alu_tgt = 5'd9; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd67; end
                9'd122: begin alu_tgt = 5'd9; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd49; end
                9'd123: begin alu_tgt = 5'd9; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd49; end
                9'd124: begin alu_tgt = 5'd9; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd43; end
                9'd125: begin alu_tgt = 5'd10; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd53; end
                9'd126: begin alu_tgt = 5'd10; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd110; end
                9'd127: begin alu_tgt = 5'd10; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = 10'sd51; end
                9'd128: begin alu_tgt = 5'd10; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd127; end
                9'd129: begin alu_tgt = 5'd10; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd78; end
                9'd130: begin alu_tgt = 5'd10; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd49; end
                9'd131: begin alu_tgt = 5'd10; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd109; end
                9'd132: begin alu_tgt = 5'd10; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = -10'sd59; end
                9'd133: begin alu_tgt = 5'd10; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                9'd134: begin alu_tgt = 5'd11; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = -10'sd63; end
                9'd135: begin alu_tgt = 5'd11; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd80; end
                9'd136: begin alu_tgt = 5'd11; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = 10'sd47; end
                9'd137: begin alu_tgt = 5'd11; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = -10'sd66; end
                9'd138: begin alu_tgt = 5'd11; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd56; end
                9'd139: begin alu_tgt = 5'd11; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = -10'sd53; end
                9'd140: begin alu_tgt = 5'd11; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd49; end
                9'd141: begin alu_tgt = 5'd11; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                9'd142: begin alu_tgt = 5'd11; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd56; end
                9'd143: begin alu_tgt = 5'd11; alu_src = 5'd19; alu_is_hid_src = 1'b1; alu_w = -10'sd67; end
                9'd144: begin alu_tgt = 5'd11; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd63; end
                9'd145: begin alu_tgt = 5'd11; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd122; end
                9'd146: begin alu_tgt = 5'd12; alu_src = 5'd0; alu_is_hid_src = 1'b1; alu_w = 10'sd75; end
                9'd147: begin alu_tgt = 5'd12; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd106; end
                9'd148: begin alu_tgt = 5'd12; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = 10'sd110; end
                9'd149: begin alu_tgt = 5'd12; alu_src = 5'd7; alu_is_hid_src = 1'b1; alu_w = 10'sd54; end
                9'd150: begin alu_tgt = 5'd12; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = -10'sd127; end
                9'd151: begin alu_tgt = 5'd12; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd77; end
                9'd152: begin alu_tgt = 5'd12; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = 10'sd44; end
                9'd153: begin alu_tgt = 5'd12; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = 10'sd77; end
                9'd154: begin alu_tgt = 5'd12; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd92; end
                9'd155: begin alu_tgt = 5'd13; alu_src = 5'd0; alu_is_hid_src = 1'b0; alu_w = -10'sd127; end
                9'd156: begin alu_tgt = 5'd13; alu_src = 5'd1; alu_is_hid_src = 1'b0; alu_w = -10'sd127; end
                9'd157: begin alu_tgt = 5'd13; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd43; end
                9'd158: begin alu_tgt = 5'd13; alu_src = 5'd6; alu_is_hid_src = 1'b0; alu_w = 10'sd45; end
                9'd159: begin alu_tgt = 5'd13; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = 10'sd47; end
                9'd160: begin alu_tgt = 5'd13; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd55; end
                9'd161: begin alu_tgt = 5'd13; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd72; end
                9'd162: begin alu_tgt = 5'd13; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = 10'sd62; end
                9'd163: begin alu_tgt = 5'd13; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = -10'sd53; end
                9'd164: begin alu_tgt = 5'd13; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd89; end
                9'd165: begin alu_tgt = 5'd14; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd69; end
                9'd166: begin alu_tgt = 5'd14; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd85; end
                9'd167: begin alu_tgt = 5'd14; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd54; end
                9'd168: begin alu_tgt = 5'd14; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd43; end
                9'd169: begin alu_tgt = 5'd14; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd91; end
                9'd170: begin alu_tgt = 5'd14; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd55; end
                9'd171: begin alu_tgt = 5'd15; alu_src = 5'd1; alu_is_hid_src = 1'b0; alu_w = -10'sd127; end
                9'd172: begin alu_tgt = 5'd15; alu_src = 5'd6; alu_is_hid_src = 1'b0; alu_w = -10'sd58; end
                9'd173: begin alu_tgt = 5'd15; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd65; end
                9'd174: begin alu_tgt = 5'd15; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd81; end
                9'd175: begin alu_tgt = 5'd15; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd51; end
                9'd176: begin alu_tgt = 5'd15; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd46; end
                9'd177: begin alu_tgt = 5'd15; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = -10'sd67; end
                9'd178: begin alu_tgt = 5'd15; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = 10'sd65; end
                9'd179: begin alu_tgt = 5'd15; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd127; end
                9'd180: begin alu_tgt = 5'd15; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd103; end
                9'd181: begin alu_tgt = 5'd16; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd61; end
                9'd182: begin alu_tgt = 5'd16; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd62; end
                9'd183: begin alu_tgt = 5'd16; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd55; end
                9'd184: begin alu_tgt = 5'd16; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd127; end
                9'd185: begin alu_tgt = 5'd16; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd88; end
                9'd186: begin alu_tgt = 5'd16; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd51; end
                9'd187: begin alu_tgt = 5'd16; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd67; end
                9'd188: begin alu_tgt = 5'd16; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = -10'sd46; end
                9'd189: begin alu_tgt = 5'd16; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd127; end
                9'd190: begin alu_tgt = 5'd16; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                9'd191: begin alu_tgt = 5'd17; alu_src = 5'd2; alu_is_hid_src = 1'b0; alu_w = 10'sd74; end
                9'd192: begin alu_tgt = 5'd17; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd54; end
                9'd193: begin alu_tgt = 5'd17; alu_src = 5'd6; alu_is_hid_src = 1'b0; alu_w = -10'sd127; end
                9'd194: begin alu_tgt = 5'd17; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd44; end
                9'd195: begin alu_tgt = 5'd17; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = 10'sd101; end
                9'd196: begin alu_tgt = 5'd17; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd56; end
                9'd197: begin alu_tgt = 5'd17; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd71; end
                9'd198: begin alu_tgt = 5'd17; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd60; end
                9'd199: begin alu_tgt = 5'd17; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd66; end
                9'd200: begin alu_tgt = 5'd18; alu_src = 5'd0; alu_is_hid_src = 1'b1; alu_w = 10'sd43; end
                9'd201: begin alu_tgt = 5'd18; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd63; end
                9'd202: begin alu_tgt = 5'd18; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd52; end
                9'd203: begin alu_tgt = 5'd18; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd52; end
                9'd204: begin alu_tgt = 5'd18; alu_src = 5'd7; alu_is_hid_src = 1'b1; alu_w = 10'sd45; end
                9'd205: begin alu_tgt = 5'd18; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd77; end
                9'd206: begin alu_tgt = 5'd18; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd41; end
                9'd207: begin alu_tgt = 5'd18; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd66; end
                9'd208: begin alu_tgt = 5'd18; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd127; end
                9'd209: begin alu_tgt = 5'd18; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd72; end
                9'd210: begin alu_tgt = 5'd18; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd41; end
                9'd211: begin alu_tgt = 5'd19; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd59; end
                9'd212: begin alu_tgt = 5'd19; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd53; end
                9'd213: begin alu_tgt = 5'd19; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd90; end
                9'd214: begin alu_tgt = 5'd19; alu_src = 5'd11; alu_is_hid_src = 1'b1; alu_w = -10'sd54; end
                9'd215: begin alu_tgt = 5'd19; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd46; end
                9'd216: begin alu_tgt = 5'd19; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd63; end
                9'd217: begin alu_tgt = 5'd19; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd68; end
                9'd218: begin alu_tgt = 5'd19; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd80; end
                9'd219: begin alu_tgt = 5'd19; alu_src = 5'd19; alu_is_hid_src = 1'b1; alu_w = -10'sd61; end
                9'd220: begin alu_tgt = 5'd19; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd87; end
                9'd221: begin alu_tgt = 5'd20; alu_src = 5'd0; alu_is_hid_src = 1'b1; alu_w = 10'sd109; end
                9'd222: begin alu_tgt = 5'd20; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd88; end
                9'd223: begin alu_tgt = 5'd20; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = 10'sd55; end
                9'd224: begin alu_tgt = 5'd20; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd81; end
                9'd225: begin alu_tgt = 5'd20; alu_src = 5'd5; alu_is_hid_src = 1'b1; alu_w = 10'sd42; end
                9'd226: begin alu_tgt = 5'd20; alu_src = 5'd7; alu_is_hid_src = 1'b1; alu_w = 10'sd41; end
                9'd227: begin alu_tgt = 5'd20; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd97; end
                9'd228: begin alu_tgt = 5'd20; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd102; end
                9'd229: begin alu_tgt = 5'd20; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = 10'sd60; end
                9'd230: begin alu_tgt = 5'd20; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd66; end
                9'd231: begin alu_tgt = 5'd20; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd127; end
                9'd232: begin alu_tgt = 5'd20; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = 10'sd60; end
                9'd233: begin alu_tgt = 5'd20; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = 10'sd67; end
                9'd234: begin alu_tgt = 5'd20; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd98; end
                9'd235: begin alu_tgt = 5'd21; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd49; end
                9'd236: begin alu_tgt = 5'd21; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd48; end
                9'd237: begin alu_tgt = 5'd21; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd109; end
                9'd238: begin alu_tgt = 5'd22; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = -10'sd51; end
                9'd239: begin alu_tgt = 5'd22; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd56; end
                9'd240: begin alu_tgt = 5'd22; alu_src = 5'd7; alu_is_hid_src = 1'b1; alu_w = 10'sd48; end
                9'd241: begin alu_tgt = 5'd22; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = -10'sd99; end
                9'd242: begin alu_tgt = 5'd22; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd48; end
                9'd243: begin alu_tgt = 5'd22; alu_src = 5'd11; alu_is_hid_src = 1'b1; alu_w = -10'sd59; end
                9'd244: begin alu_tgt = 5'd22; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd60; end
                9'd245: begin alu_tgt = 5'd22; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd49; end
                9'd246: begin alu_tgt = 5'd22; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd51; end
                9'd247: begin alu_tgt = 5'd22; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd59; end
                9'd248: begin alu_tgt = 5'd22; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd112; end
                9'd249: begin alu_tgt = 5'd22; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd54; end
                9'd250: begin alu_tgt = 5'd23; alu_src = 5'd6; alu_is_hid_src = 1'b0; alu_w = 10'sd43; end
                9'd251: begin alu_tgt = 5'd23; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = 10'sd62; end
                9'd252: begin alu_tgt = 5'd23; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd56; end
                9'd253: begin alu_tgt = 5'd24; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd78; end
                9'd254: begin alu_tgt = 5'd24; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = 10'sd58; end
                9'd255: begin alu_tgt = 5'd24; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd67; end
                9'd256: begin alu_tgt = 5'd24; alu_src = 5'd11; alu_is_hid_src = 1'b1; alu_w = -10'sd85; end
                9'd257: begin alu_tgt = 5'd24; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd46; end
                9'd258: begin alu_tgt = 5'd24; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd79; end
                9'd259: begin alu_tgt = 5'd24; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                9'd260: begin alu_tgt = 5'd25; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd50; end
                9'd261: begin alu_tgt = 5'd25; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                9'd262: begin alu_tgt = 5'd25; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd66; end
                9'd263: begin alu_tgt = 5'd25; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = 10'sd48; end
                9'd264: begin alu_tgt = 5'd25; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd83; end
                9'd265: begin alu_tgt = 5'd25; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                9'd266: begin alu_tgt = 5'd25; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = 10'sd44; end
                9'd267: begin alu_tgt = 5'd25; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd127; end
                9'd268: begin alu_tgt = 5'd26; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd76; end
                9'd269: begin alu_tgt = 5'd26; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd107; end
                9'd270: begin alu_tgt = 5'd26; alu_src = 5'd11; alu_is_hid_src = 1'b1; alu_w = 10'sd51; end
                9'd271: begin alu_tgt = 5'd26; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd127; end
                9'd272: begin alu_tgt = 5'd27; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd61; end
                9'd273: begin alu_tgt = 5'd27; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd67; end
                9'd274: begin alu_tgt = 5'd28; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = 10'sd63; end
                9'd275: begin alu_tgt = 5'd28; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd107; end
                9'd276: begin alu_tgt = 5'd28; alu_src = 5'd11; alu_is_hid_src = 1'b1; alu_w = -10'sd46; end
                9'd277: begin alu_tgt = 5'd28; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd127; end
            endcase
        end else if (state < 9'd307) begin
            alu_is_thresh = 1'b1;
            alu_tgt = state[4:0] - 5'd22;
        end
    end

    // Single external spike multiplexer
    wire spike_active = alu_is_hid_src ? hid_spikes[alu_src] : in_spikes[alu_src[2:0]];
    wire signed [9:0] current_v = mem[alu_tgt];
    wire signed [9:0] thresh_val = (alu_tgt < 24) ? 10'sd87 : 10'sd88;
    wire is_spike = (current_v >= thresh_val);

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 9'h1FF;
            hid_spikes <= 24'd0;
            out_spikes <= 5'd0;
            for (i = 0; i < 29; i = i + 1) mem[i] <= 10'sd0;
        end else if (tick_1ms) begin
            state <= 9'd0;
        end else if (state != 9'h1FF) begin
            if (alu_is_leak) mem[alu_tgt] <= current_v - (current_v >>> alu_shift);
            else if (alu_is_thresh) begin
                mem[alu_tgt] <= is_spike ? 10'sd0 : current_v;
                if (alu_tgt < 24) hid_spikes[alu_tgt] <= is_spike;
                else out_spikes[alu_tgt - 24] <= is_spike;
            end else if (alu_is_syn && spike_active) begin
                mem[alu_tgt] <= current_v + alu_w;
            end

            if (state == 9'd306) state <= 9'h1FF;
            else state <= state + 9'd1;
        end
    end
endmodule