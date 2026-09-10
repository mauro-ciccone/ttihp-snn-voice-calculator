`default_nettype none
module snn_core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tick_1ms,
    input  wire [6:0]  in_spikes,
    output reg  [4:0] out_spikes
);

    reg [9:0] state;
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

        if (state < 10'd29) begin
            alu_is_leak = 1'b1;
            alu_tgt = state[4:0];
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
        end else if (state < 10'd336) begin
            alu_is_syn = 1'b1;
            case(state)
                10'd29: begin alu_tgt = 5'd0; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd43; end
                10'd30: begin alu_tgt = 5'd0; alu_src = 5'd0; alu_is_hid_src = 1'b1; alu_w = -10'sd81; end
                10'd31: begin alu_tgt = 5'd0; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd51; end
                10'd32: begin alu_tgt = 5'd0; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd53; end
                10'd33: begin alu_tgt = 5'd0; alu_src = 5'd5; alu_is_hid_src = 1'b1; alu_w = -10'sd41; end
                10'd34: begin alu_tgt = 5'd0; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd57; end
                10'd35: begin alu_tgt = 5'd0; alu_src = 5'd7; alu_is_hid_src = 1'b1; alu_w = -10'sd51; end
                10'd36: begin alu_tgt = 5'd0; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = -10'sd43; end
                10'd37: begin alu_tgt = 5'd0; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd93; end
                10'd38: begin alu_tgt = 5'd0; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd110; end
                10'd39: begin alu_tgt = 5'd0; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd34; end
                10'd40: begin alu_tgt = 5'd0; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = -10'sd44; end
                10'd41: begin alu_tgt = 5'd0; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd107; end
                10'd42: begin alu_tgt = 5'd0; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd71; end
                10'd43: begin alu_tgt = 5'd0; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd82; end
                10'd44: begin alu_tgt = 5'd0; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd45; end
                10'd45: begin alu_tgt = 5'd1; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd44; end
                10'd46: begin alu_tgt = 5'd1; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = 10'sd46; end
                10'd47: begin alu_tgt = 5'd1; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = -10'sd58; end
                10'd48: begin alu_tgt = 5'd1; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd43; end
                10'd49: begin alu_tgt = 5'd1; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd35; end
                10'd50: begin alu_tgt = 5'd1; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd50; end
                10'd51: begin alu_tgt = 5'd2; alu_src = 5'd6; alu_is_hid_src = 1'b0; alu_w = 10'sd50; end
                10'd52: begin alu_tgt = 5'd2; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = 10'sd88; end
                10'd53: begin alu_tgt = 5'd2; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                10'd54: begin alu_tgt = 5'd2; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = 10'sd41; end
                10'd55: begin alu_tgt = 5'd2; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd49; end
                10'd56: begin alu_tgt = 5'd3; alu_src = 5'd0; alu_is_hid_src = 1'b1; alu_w = 10'sd51; end
                10'd57: begin alu_tgt = 5'd3; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd76; end
                10'd58: begin alu_tgt = 5'd3; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd71; end
                10'd59: begin alu_tgt = 5'd3; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = 10'sd47; end
                10'd60: begin alu_tgt = 5'd3; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd46; end
                10'd61: begin alu_tgt = 5'd3; alu_src = 5'd7; alu_is_hid_src = 1'b1; alu_w = 10'sd48; end
                10'd62: begin alu_tgt = 5'd3; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd35; end
                10'd63: begin alu_tgt = 5'd3; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd126; end
                10'd64: begin alu_tgt = 5'd3; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd52; end
                10'd65: begin alu_tgt = 5'd3; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd116; end
                10'd66: begin alu_tgt = 5'd3; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd35; end
                10'd67: begin alu_tgt = 5'd3; alu_src = 5'd19; alu_is_hid_src = 1'b1; alu_w = 10'sd67; end
                10'd68: begin alu_tgt = 5'd4; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd55; end
                10'd69: begin alu_tgt = 5'd4; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd44; end
                10'd70: begin alu_tgt = 5'd4; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = -10'sd87; end
                10'd71: begin alu_tgt = 5'd4; alu_src = 5'd5; alu_is_hid_src = 1'b1; alu_w = -10'sd43; end
                10'd72: begin alu_tgt = 5'd4; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd105; end
                10'd73: begin alu_tgt = 5'd4; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd47; end
                10'd74: begin alu_tgt = 5'd4; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd68; end
                10'd75: begin alu_tgt = 5'd4; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                10'd76: begin alu_tgt = 5'd4; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = -10'sd55; end
                10'd77: begin alu_tgt = 5'd4; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd127; end
                10'd78: begin alu_tgt = 5'd4; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd44; end
                10'd79: begin alu_tgt = 5'd4; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = -10'sd43; end
                10'd80: begin alu_tgt = 5'd4; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd86; end
                10'd81: begin alu_tgt = 5'd4; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd41; end
                10'd82: begin alu_tgt = 5'd5; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = 10'sd38; end
                10'd83: begin alu_tgt = 5'd5; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd41; end
                10'd84: begin alu_tgt = 5'd5; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd39; end
                10'd85: begin alu_tgt = 5'd5; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd47; end
                10'd86: begin alu_tgt = 5'd5; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd44; end
                10'd87: begin alu_tgt = 5'd5; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd84; end
                10'd88: begin alu_tgt = 5'd5; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd102; end
                10'd89: begin alu_tgt = 5'd5; alu_src = 5'd19; alu_is_hid_src = 1'b1; alu_w = -10'sd43; end
                10'd90: begin alu_tgt = 5'd5; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd63; end
                10'd91: begin alu_tgt = 5'd5; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd55; end
                10'd92: begin alu_tgt = 5'd5; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd35; end
                10'd93: begin alu_tgt = 5'd6; alu_src = 5'd1; alu_is_hid_src = 1'b0; alu_w = -10'sd33; end
                10'd94: begin alu_tgt = 5'd6; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd34; end
                10'd95: begin alu_tgt = 5'd6; alu_src = 5'd5; alu_is_hid_src = 1'b1; alu_w = -10'sd65; end
                10'd96: begin alu_tgt = 5'd6; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd81; end
                10'd97: begin alu_tgt = 5'd6; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd65; end
                10'd98: begin alu_tgt = 5'd6; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd105; end
                10'd99: begin alu_tgt = 5'd6; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd76; end
                10'd100: begin alu_tgt = 5'd6; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd40; end
                10'd101: begin alu_tgt = 5'd6; alu_src = 5'd19; alu_is_hid_src = 1'b1; alu_w = -10'sd37; end
                10'd102: begin alu_tgt = 5'd6; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = -10'sd37; end
                10'd103: begin alu_tgt = 5'd6; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd58; end
                10'd104: begin alu_tgt = 5'd7; alu_src = 5'd0; alu_is_hid_src = 1'b0; alu_w = -10'sd34; end
                10'd105: begin alu_tgt = 5'd7; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd41; end
                10'd106: begin alu_tgt = 5'd7; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd45; end
                10'd107: begin alu_tgt = 5'd7; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd46; end
                10'd108: begin alu_tgt = 5'd7; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = -10'sd64; end
                10'd109: begin alu_tgt = 5'd7; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd49; end
                10'd110: begin alu_tgt = 5'd7; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd73; end
                10'd111: begin alu_tgt = 5'd7; alu_src = 5'd11; alu_is_hid_src = 1'b1; alu_w = -10'sd46; end
                10'd112: begin alu_tgt = 5'd7; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = -10'sd78; end
                10'd113: begin alu_tgt = 5'd7; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd127; end
                10'd114: begin alu_tgt = 5'd7; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd52; end
                10'd115: begin alu_tgt = 5'd7; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd84; end
                10'd116: begin alu_tgt = 5'd7; alu_src = 5'd19; alu_is_hid_src = 1'b1; alu_w = -10'sd93; end
                10'd117: begin alu_tgt = 5'd7; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = -10'sd34; end
                10'd118: begin alu_tgt = 5'd7; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd34; end
                10'd119: begin alu_tgt = 5'd8; alu_src = 5'd1; alu_is_hid_src = 1'b0; alu_w = -10'sd33; end
                10'd120: begin alu_tgt = 5'd8; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd54; end
                10'd121: begin alu_tgt = 5'd8; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd92; end
                10'd122: begin alu_tgt = 5'd8; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd71; end
                10'd123: begin alu_tgt = 5'd8; alu_src = 5'd5; alu_is_hid_src = 1'b1; alu_w = -10'sd45; end
                10'd124: begin alu_tgt = 5'd8; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd82; end
                10'd125: begin alu_tgt = 5'd8; alu_src = 5'd7; alu_is_hid_src = 1'b1; alu_w = -10'sd35; end
                10'd126: begin alu_tgt = 5'd8; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = -10'sd127; end
                10'd127: begin alu_tgt = 5'd8; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = -10'sd99; end
                10'd128: begin alu_tgt = 5'd8; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd90; end
                10'd129: begin alu_tgt = 5'd8; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = -10'sd93; end
                10'd130: begin alu_tgt = 5'd8; alu_src = 5'd19; alu_is_hid_src = 1'b1; alu_w = -10'sd89; end
                10'd131: begin alu_tgt = 5'd8; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd119; end
                10'd132: begin alu_tgt = 5'd8; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                10'd133: begin alu_tgt = 5'd9; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = -10'sd45; end
                10'd134: begin alu_tgt = 5'd9; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd83; end
                10'd135: begin alu_tgt = 5'd9; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd43; end
                10'd136: begin alu_tgt = 5'd9; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = 10'sd50; end
                10'd137: begin alu_tgt = 5'd9; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd69; end
                10'd138: begin alu_tgt = 5'd9; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd67; end
                10'd139: begin alu_tgt = 5'd9; alu_src = 5'd11; alu_is_hid_src = 1'b1; alu_w = 10'sd37; end
                10'd140: begin alu_tgt = 5'd9; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd49; end
                10'd141: begin alu_tgt = 5'd9; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd49; end
                10'd142: begin alu_tgt = 5'd9; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd43; end
                10'd143: begin alu_tgt = 5'd10; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd53; end
                10'd144: begin alu_tgt = 5'd10; alu_src = 5'd6; alu_is_hid_src = 1'b0; alu_w = 10'sd38; end
                10'd145: begin alu_tgt = 5'd10; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = -10'sd33; end
                10'd146: begin alu_tgt = 5'd10; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd110; end
                10'd147: begin alu_tgt = 5'd10; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = 10'sd51; end
                10'd148: begin alu_tgt = 5'd10; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd127; end
                10'd149: begin alu_tgt = 5'd10; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd78; end
                10'd150: begin alu_tgt = 5'd10; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd38; end
                10'd151: begin alu_tgt = 5'd10; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd49; end
                10'd152: begin alu_tgt = 5'd10; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd109; end
                10'd153: begin alu_tgt = 5'd10; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = -10'sd59; end
                10'd154: begin alu_tgt = 5'd10; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                10'd155: begin alu_tgt = 5'd11; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd40; end
                10'd156: begin alu_tgt = 5'd11; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = -10'sd63; end
                10'd157: begin alu_tgt = 5'd11; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd80; end
                10'd158: begin alu_tgt = 5'd11; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = 10'sd47; end
                10'd159: begin alu_tgt = 5'd11; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = -10'sd66; end
                10'd160: begin alu_tgt = 5'd11; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd56; end
                10'd161: begin alu_tgt = 5'd11; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd36; end
                10'd162: begin alu_tgt = 5'd11; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = -10'sd53; end
                10'd163: begin alu_tgt = 5'd11; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd49; end
                10'd164: begin alu_tgt = 5'd11; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                10'd165: begin alu_tgt = 5'd11; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd56; end
                10'd166: begin alu_tgt = 5'd11; alu_src = 5'd19; alu_is_hid_src = 1'b1; alu_w = -10'sd67; end
                10'd167: begin alu_tgt = 5'd11; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd63; end
                10'd168: begin alu_tgt = 5'd11; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd122; end
                10'd169: begin alu_tgt = 5'd12; alu_src = 5'd0; alu_is_hid_src = 1'b1; alu_w = 10'sd75; end
                10'd170: begin alu_tgt = 5'd12; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = 10'sd37; end
                10'd171: begin alu_tgt = 5'd12; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd106; end
                10'd172: begin alu_tgt = 5'd12; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = 10'sd110; end
                10'd173: begin alu_tgt = 5'd12; alu_src = 5'd7; alu_is_hid_src = 1'b1; alu_w = 10'sd54; end
                10'd174: begin alu_tgt = 5'd12; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = -10'sd127; end
                10'd175: begin alu_tgt = 5'd12; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = -10'sd33; end
                10'd176: begin alu_tgt = 5'd12; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd77; end
                10'd177: begin alu_tgt = 5'd12; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = 10'sd44; end
                10'd178: begin alu_tgt = 5'd12; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd33; end
                10'd179: begin alu_tgt = 5'd12; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = 10'sd36; end
                10'd180: begin alu_tgt = 5'd12; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = 10'sd77; end
                10'd181: begin alu_tgt = 5'd12; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd92; end
                10'd182: begin alu_tgt = 5'd13; alu_src = 5'd0; alu_is_hid_src = 1'b0; alu_w = -10'sd127; end
                10'd183: begin alu_tgt = 5'd13; alu_src = 5'd1; alu_is_hid_src = 1'b0; alu_w = -10'sd127; end
                10'd184: begin alu_tgt = 5'd13; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd43; end
                10'd185: begin alu_tgt = 5'd13; alu_src = 5'd6; alu_is_hid_src = 1'b0; alu_w = 10'sd45; end
                10'd186: begin alu_tgt = 5'd13; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = 10'sd47; end
                10'd187: begin alu_tgt = 5'd13; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd55; end
                10'd188: begin alu_tgt = 5'd13; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd72; end
                10'd189: begin alu_tgt = 5'd13; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = 10'sd62; end
                10'd190: begin alu_tgt = 5'd13; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = -10'sd53; end
                10'd191: begin alu_tgt = 5'd13; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd89; end
                10'd192: begin alu_tgt = 5'd13; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd34; end
                10'd193: begin alu_tgt = 5'd14; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd69; end
                10'd194: begin alu_tgt = 5'd14; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd85; end
                10'd195: begin alu_tgt = 5'd14; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd54; end
                10'd196: begin alu_tgt = 5'd14; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd43; end
                10'd197: begin alu_tgt = 5'd14; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd91; end
                10'd198: begin alu_tgt = 5'd14; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd55; end
                10'd199: begin alu_tgt = 5'd15; alu_src = 5'd1; alu_is_hid_src = 1'b0; alu_w = -10'sd127; end
                10'd200: begin alu_tgt = 5'd15; alu_src = 5'd6; alu_is_hid_src = 1'b0; alu_w = -10'sd58; end
                10'd201: begin alu_tgt = 5'd15; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd65; end
                10'd202: begin alu_tgt = 5'd15; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd81; end
                10'd203: begin alu_tgt = 5'd15; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd51; end
                10'd204: begin alu_tgt = 5'd15; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd46; end
                10'd205: begin alu_tgt = 5'd15; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = -10'sd67; end
                10'd206: begin alu_tgt = 5'd15; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd36; end
                10'd207: begin alu_tgt = 5'd15; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = 10'sd65; end
                10'd208: begin alu_tgt = 5'd15; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd127; end
                10'd209: begin alu_tgt = 5'd15; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd103; end
                10'd210: begin alu_tgt = 5'd15; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd35; end
                10'd211: begin alu_tgt = 5'd16; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd61; end
                10'd212: begin alu_tgt = 5'd16; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd39; end
                10'd213: begin alu_tgt = 5'd16; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd62; end
                10'd214: begin alu_tgt = 5'd16; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd55; end
                10'd215: begin alu_tgt = 5'd16; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = 10'sd38; end
                10'd216: begin alu_tgt = 5'd16; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd127; end
                10'd217: begin alu_tgt = 5'd16; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd88; end
                10'd218: begin alu_tgt = 5'd16; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd51; end
                10'd219: begin alu_tgt = 5'd16; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd67; end
                10'd220: begin alu_tgt = 5'd16; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd36; end
                10'd221: begin alu_tgt = 5'd16; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd38; end
                10'd222: begin alu_tgt = 5'd16; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = -10'sd46; end
                10'd223: begin alu_tgt = 5'd16; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd127; end
                10'd224: begin alu_tgt = 5'd16; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                10'd225: begin alu_tgt = 5'd17; alu_src = 5'd2; alu_is_hid_src = 1'b0; alu_w = 10'sd74; end
                10'd226: begin alu_tgt = 5'd17; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd54; end
                10'd227: begin alu_tgt = 5'd17; alu_src = 5'd6; alu_is_hid_src = 1'b0; alu_w = -10'sd127; end
                10'd228: begin alu_tgt = 5'd17; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = 10'sd40; end
                10'd229: begin alu_tgt = 5'd17; alu_src = 5'd5; alu_is_hid_src = 1'b1; alu_w = -10'sd40; end
                10'd230: begin alu_tgt = 5'd17; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = -10'sd34; end
                10'd231: begin alu_tgt = 5'd17; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd44; end
                10'd232: begin alu_tgt = 5'd17; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = 10'sd33; end
                10'd233: begin alu_tgt = 5'd17; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = 10'sd101; end
                10'd234: begin alu_tgt = 5'd17; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd56; end
                10'd235: begin alu_tgt = 5'd17; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd71; end
                10'd236: begin alu_tgt = 5'd17; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd60; end
                10'd237: begin alu_tgt = 5'd17; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd66; end
                10'd238: begin alu_tgt = 5'd18; alu_src = 5'd1; alu_is_hid_src = 1'b0; alu_w = 10'sd36; end
                10'd239: begin alu_tgt = 5'd18; alu_src = 5'd0; alu_is_hid_src = 1'b1; alu_w = 10'sd43; end
                10'd240: begin alu_tgt = 5'd18; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd63; end
                10'd241: begin alu_tgt = 5'd18; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd52; end
                10'd242: begin alu_tgt = 5'd18; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd52; end
                10'd243: begin alu_tgt = 5'd18; alu_src = 5'd7; alu_is_hid_src = 1'b1; alu_w = 10'sd45; end
                10'd244: begin alu_tgt = 5'd18; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd77; end
                10'd245: begin alu_tgt = 5'd18; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd41; end
                10'd246: begin alu_tgt = 5'd18; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd66; end
                10'd247: begin alu_tgt = 5'd18; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd127; end
                10'd248: begin alu_tgt = 5'd18; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd72; end
                10'd249: begin alu_tgt = 5'd18; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd41; end
                10'd250: begin alu_tgt = 5'd19; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = -10'sd34; end
                10'd251: begin alu_tgt = 5'd19; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd59; end
                10'd252: begin alu_tgt = 5'd19; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd53; end
                10'd253: begin alu_tgt = 5'd19; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd90; end
                10'd254: begin alu_tgt = 5'd19; alu_src = 5'd11; alu_is_hid_src = 1'b1; alu_w = -10'sd54; end
                10'd255: begin alu_tgt = 5'd19; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd46; end
                10'd256: begin alu_tgt = 5'd19; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd63; end
                10'd257: begin alu_tgt = 5'd19; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd68; end
                10'd258: begin alu_tgt = 5'd19; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd80; end
                10'd259: begin alu_tgt = 5'd19; alu_src = 5'd19; alu_is_hid_src = 1'b1; alu_w = -10'sd61; end
                10'd260: begin alu_tgt = 5'd19; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd87; end
                10'd261: begin alu_tgt = 5'd20; alu_src = 5'd0; alu_is_hid_src = 1'b1; alu_w = 10'sd109; end
                10'd262: begin alu_tgt = 5'd20; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd88; end
                10'd263: begin alu_tgt = 5'd20; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = 10'sd55; end
                10'd264: begin alu_tgt = 5'd20; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd81; end
                10'd265: begin alu_tgt = 5'd20; alu_src = 5'd5; alu_is_hid_src = 1'b1; alu_w = 10'sd42; end
                10'd266: begin alu_tgt = 5'd20; alu_src = 5'd7; alu_is_hid_src = 1'b1; alu_w = 10'sd41; end
                10'd267: begin alu_tgt = 5'd20; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd97; end
                10'd268: begin alu_tgt = 5'd20; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd102; end
                10'd269: begin alu_tgt = 5'd20; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = 10'sd34; end
                10'd270: begin alu_tgt = 5'd20; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = 10'sd60; end
                10'd271: begin alu_tgt = 5'd20; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd66; end
                10'd272: begin alu_tgt = 5'd20; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd127; end
                10'd273: begin alu_tgt = 5'd20; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = 10'sd60; end
                10'd274: begin alu_tgt = 5'd20; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = 10'sd67; end
                10'd275: begin alu_tgt = 5'd20; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd98; end
                10'd276: begin alu_tgt = 5'd21; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd49; end
                10'd277: begin alu_tgt = 5'd21; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd48; end
                10'd278: begin alu_tgt = 5'd21; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = 10'sd36; end
                10'd279: begin alu_tgt = 5'd21; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd109; end
                10'd280: begin alu_tgt = 5'd21; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = 10'sd39; end
                10'd281: begin alu_tgt = 5'd21; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd34; end
                10'd282: begin alu_tgt = 5'd22; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = -10'sd51; end
                10'd283: begin alu_tgt = 5'd22; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd56; end
                10'd284: begin alu_tgt = 5'd22; alu_src = 5'd7; alu_is_hid_src = 1'b1; alu_w = 10'sd48; end
                10'd285: begin alu_tgt = 5'd22; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = -10'sd99; end
                10'd286: begin alu_tgt = 5'd22; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd48; end
                10'd287: begin alu_tgt = 5'd22; alu_src = 5'd11; alu_is_hid_src = 1'b1; alu_w = -10'sd59; end
                10'd288: begin alu_tgt = 5'd22; alu_src = 5'd12; alu_is_hid_src = 1'b1; alu_w = -10'sd60; end
                10'd289: begin alu_tgt = 5'd22; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd49; end
                10'd290: begin alu_tgt = 5'd22; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd51; end
                10'd291: begin alu_tgt = 5'd22; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd59; end
                10'd292: begin alu_tgt = 5'd22; alu_src = 5'd20; alu_is_hid_src = 1'b1; alu_w = -10'sd112; end
                10'd293: begin alu_tgt = 5'd22; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = -10'sd38; end
                10'd294: begin alu_tgt = 5'd22; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = -10'sd54; end
                10'd295: begin alu_tgt = 5'd23; alu_src = 5'd3; alu_is_hid_src = 1'b0; alu_w = 10'sd38; end
                10'd296: begin alu_tgt = 5'd23; alu_src = 5'd6; alu_is_hid_src = 1'b0; alu_w = 10'sd43; end
                10'd297: begin alu_tgt = 5'd23; alu_src = 5'd3; alu_is_hid_src = 1'b1; alu_w = 10'sd34; end
                10'd298: begin alu_tgt = 5'd23; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = 10'sd62; end
                10'd299: begin alu_tgt = 5'd23; alu_src = 5'd7; alu_is_hid_src = 1'b1; alu_w = 10'sd37; end
                10'd300: begin alu_tgt = 5'd23; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = -10'sd56; end
                10'd301: begin alu_tgt = 5'd23; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = 10'sd34; end
                10'd302: begin alu_tgt = 5'd23; alu_src = 5'd23; alu_is_hid_src = 1'b1; alu_w = 10'sd34; end
                10'd303: begin alu_tgt = 5'd24; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = -10'sd78; end
                10'd304: begin alu_tgt = 5'd24; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd38; end
                10'd305: begin alu_tgt = 5'd24; alu_src = 5'd4; alu_is_hid_src = 1'b1; alu_w = 10'sd35; end
                10'd306: begin alu_tgt = 5'd24; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = 10'sd58; end
                10'd307: begin alu_tgt = 5'd24; alu_src = 5'd10; alu_is_hid_src = 1'b1; alu_w = 10'sd67; end
                10'd308: begin alu_tgt = 5'd24; alu_src = 5'd11; alu_is_hid_src = 1'b1; alu_w = -10'sd85; end
                10'd309: begin alu_tgt = 5'd24; alu_src = 5'd16; alu_is_hid_src = 1'b1; alu_w = 10'sd46; end
                10'd310: begin alu_tgt = 5'd24; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd79; end
                10'd311: begin alu_tgt = 5'd24; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                10'd312: begin alu_tgt = 5'd25; alu_src = 5'd1; alu_is_hid_src = 1'b1; alu_w = 10'sd35; end
                10'd313: begin alu_tgt = 5'd25; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd50; end
                10'd314: begin alu_tgt = 5'd25; alu_src = 5'd5; alu_is_hid_src = 1'b1; alu_w = 10'sd35; end
                10'd315: begin alu_tgt = 5'd25; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                10'd316: begin alu_tgt = 5'd25; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = -10'sd66; end
                10'd317: begin alu_tgt = 5'd25; alu_src = 5'd14; alu_is_hid_src = 1'b1; alu_w = 10'sd48; end
                10'd318: begin alu_tgt = 5'd25; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = 10'sd34; end
                10'd319: begin alu_tgt = 5'd25; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd83; end
                10'd320: begin alu_tgt = 5'd25; alu_src = 5'd18; alu_is_hid_src = 1'b1; alu_w = -10'sd42; end
                10'd321: begin alu_tgt = 5'd25; alu_src = 5'd21; alu_is_hid_src = 1'b1; alu_w = 10'sd44; end
                10'd322: begin alu_tgt = 5'd25; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd127; end
                10'd323: begin alu_tgt = 5'd26; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd76; end
                10'd324: begin alu_tgt = 5'd26; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd107; end
                10'd325: begin alu_tgt = 5'd26; alu_src = 5'd11; alu_is_hid_src = 1'b1; alu_w = 10'sd51; end
                10'd326: begin alu_tgt = 5'd26; alu_src = 5'd13; alu_is_hid_src = 1'b1; alu_w = 10'sd34; end
                10'd327: begin alu_tgt = 5'd26; alu_src = 5'd17; alu_is_hid_src = 1'b1; alu_w = -10'sd127; end
                10'd328: begin alu_tgt = 5'd27; alu_src = 5'd2; alu_is_hid_src = 1'b1; alu_w = -10'sd61; end
                10'd329: begin alu_tgt = 5'd27; alu_src = 5'd6; alu_is_hid_src = 1'b1; alu_w = -10'sd33; end
                10'd330: begin alu_tgt = 5'd27; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd67; end
                10'd331: begin alu_tgt = 5'd28; alu_src = 5'd8; alu_is_hid_src = 1'b1; alu_w = 10'sd63; end
                10'd332: begin alu_tgt = 5'd28; alu_src = 5'd9; alu_is_hid_src = 1'b1; alu_w = 10'sd107; end
                10'd333: begin alu_tgt = 5'd28; alu_src = 5'd11; alu_is_hid_src = 1'b1; alu_w = -10'sd46; end
                10'd334: begin alu_tgt = 5'd28; alu_src = 5'd15; alu_is_hid_src = 1'b1; alu_w = 10'sd35; end
                10'd335: begin alu_tgt = 5'd28; alu_src = 5'd22; alu_is_hid_src = 1'b1; alu_w = 10'sd127; end
            endcase
        end else if (state < 10'd365) begin
            alu_is_thresh = 1'b1;
            alu_tgt = state[4:0] - 5'd16;
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
            state <= 10'h3FF;
            hid_spikes <= 24'd0;
            out_spikes <= 5'd0;
            for (i = 0; i < 29; i = i + 1) mem[i] <= 10'sd0;
        end else if (tick_1ms) begin
            state <= 10'd0;
        end else if (state != 10'h3FF) begin
            if (alu_is_leak) mem[alu_tgt] <= current_v - (current_v >>> alu_shift);
            else if (alu_is_thresh) begin
                mem[alu_tgt] <= is_spike ? 10'sd0 : current_v;
                if (alu_tgt < 24) hid_spikes[alu_tgt] <= is_spike;
                else out_spikes[alu_tgt - 24] <= is_spike;
            end else if (alu_is_syn && spike_active) begin
                mem[alu_tgt] <= current_v + alu_w;
            end

            if (state == 10'd364) state <= 10'h3FF;
            else state <= state + 10'd1;
        end
    end
endmodule