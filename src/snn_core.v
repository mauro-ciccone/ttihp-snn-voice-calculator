`default_nettype none
module snn_core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tick_1ms,
    input  wire [6:0]  in_spikes,
    output reg  [4:0] out_spikes
);

    // State machine and counters
    reg [2:0] state; // 0: Idle, 1: Leak/Reset, 2: Sparse Synapse Accumulation
    reg [4:0] neuron_ptr; // 0 to 28
    reg [9:0] syn_ptr;    // 0 to 329

    // Latched inputs for the 1ms frame
    reg [6:0] latched_in_spikes;
    reg [23:0] hid_spikes;
    reg [4:0] latched_out_spikes;

    // Membrane memory for all 29 neurons (24 hidden + 5 output)
    reg signed [15:0] mem [0:28];

    // Single shared adder infrastructure
    reg signed [15:0] adder_a;
    reg signed [15:0] adder_b;
    wire signed [15:0] adder_sum = adder_a + adder_b;

    // Unpacked fields for current ROM entry
    reg         rom_target_type;
    reg [4:0]   rom_target_idx;
    reg         rom_source_type;
    reg [4:0]   rom_source_idx;
    reg signed [15:0] rom_weight;

    always @(*) begin
        rom_target_type = 1'b0;
        rom_target_idx  = 5'd0;
        rom_source_type = 1'b0;
        rom_source_idx  = 5'd0;
        rom_weight      = 16'sd0;
        case (syn_ptr)
            10'd0: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd43;
            end
            10'd1: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd44;
            end
            10'd2: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd2;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd6;
                rom_weight      = 16'sd50;
            end
            10'd3: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd55;
            end
            10'd4: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd5;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd32;
            end
            10'd5: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd6;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd1;
                rom_weight      = -16'sd33;
            end
            10'd6: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd0;
                rom_weight      = -16'sd34;
            end
            10'd7: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd41;
            end
            10'd8: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd1;
                rom_weight      = -16'sd33;
            end
            10'd9: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd54;
            end
            10'd10: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd9;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd3;
                rom_weight      = -16'sd45;
            end
            10'd11: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd10;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd53;
            end
            10'd12: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd10;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd6;
                rom_weight      = 16'sd38;
            end
            10'd13: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd13;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd0;
                rom_weight      = -16'sd127;
            end
            10'd14: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd13;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd1;
                rom_weight      = -16'sd127;
            end
            10'd15: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd13;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd43;
            end
            10'd16: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd13;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd6;
                rom_weight      = 16'sd45;
            end
            10'd17: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd15;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd1;
                rom_weight      = -16'sd127;
            end
            10'd18: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd15;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd6;
                rom_weight      = -16'sd58;
            end
            10'd19: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd61;
            end
            10'd20: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd17;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd1;
                rom_weight      = -16'sd32;
            end
            10'd21: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd17;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd2;
                rom_weight      = 16'sd74;
            end
            10'd22: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd17;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd54;
            end
            10'd23: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd17;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd6;
                rom_weight      = -16'sd127;
            end
            10'd24: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd18;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd1;
                rom_weight      = 16'sd36;
            end
            10'd25: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd21;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd49;
            end
            10'd26: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd23;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd38;
            end
            10'd27: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd23;
                rom_source_type = 1'd0;
                rom_source_idx  = 5'd6;
                rom_weight      = 16'sd43;
            end
            10'd28: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd0;
                rom_weight      = -16'sd81;
            end
            10'd29: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd1;
                rom_weight      = -16'sd51;
            end
            10'd30: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd4;
                rom_weight      = 16'sd53;
            end
            10'd31: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd5;
                rom_weight      = -16'sd41;
            end
            10'd32: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd6;
                rom_weight      = -16'sd57;
            end
            10'd33: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd7;
                rom_weight      = -16'sd51;
            end
            10'd34: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd8;
                rom_weight      = -16'sd43;
            end
            10'd35: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = 16'sd93;
            end
            10'd36: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd110;
            end
            10'd37: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd11;
                rom_weight      = -16'sd32;
            end
            10'd38: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd12;
                rom_weight      = -16'sd34;
            end
            10'd39: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd14;
                rom_weight      = -16'sd44;
            end
            10'd40: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd16;
                rom_weight      = 16'sd107;
            end
            10'd41: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd71;
            end
            10'd42: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd18;
                rom_weight      = -16'sd82;
            end
            10'd43: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = 16'sd45;
            end
            10'd44: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd1;
                rom_weight      = 16'sd46;
            end
            10'd45: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = -16'sd58;
            end
            10'd46: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd43;
            end
            10'd47: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd12;
                rom_weight      = -16'sd35;
            end
            10'd48: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd32;
            end
            10'd49: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = -16'sd50;
            end
            10'd50: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd2;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = 16'sd88;
            end
            10'd51: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd2;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd12;
                rom_weight      = -16'sd42;
            end
            10'd52: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd2;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd15;
                rom_weight      = 16'sd41;
            end
            10'd53: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd2;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = -16'sd49;
            end
            10'd54: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd0;
                rom_weight      = 16'sd51;
            end
            10'd55: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd1;
                rom_weight      = -16'sd76;
            end
            10'd56: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd71;
            end
            10'd57: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd47;
            end
            10'd58: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd4;
                rom_weight      = 16'sd46;
            end
            10'd59: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd7;
                rom_weight      = 16'sd48;
            end
            10'd60: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = 16'sd35;
            end
            10'd61: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd126;
            end
            10'd62: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd15;
                rom_weight      = -16'sd52;
            end
            10'd63: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd16;
                rom_weight      = 16'sd116;
            end
            10'd64: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd35;
            end
            10'd65: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd19;
                rom_weight      = 16'sd67;
            end
            10'd66: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = -16'sd31;
            end
            10'd67: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd44;
            end
            10'd68: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd4;
                rom_weight      = -16'sd87;
            end
            10'd69: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd5;
                rom_weight      = -16'sd43;
            end
            10'd70: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd6;
                rom_weight      = -16'sd105;
            end
            10'd71: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd47;
            end
            10'd72: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd12;
                rom_weight      = -16'sd68;
            end
            10'd73: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd13;
                rom_weight      = -16'sd42;
            end
            10'd74: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd14;
                rom_weight      = -16'sd55;
            end
            10'd75: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd15;
                rom_weight      = -16'sd31;
            end
            10'd76: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd127;
            end
            10'd77: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd19;
                rom_weight      = -16'sd31;
            end
            10'd78: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd20;
                rom_weight      = -16'sd44;
            end
            10'd79: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd21;
                rom_weight      = -16'sd43;
            end
            10'd80: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = -16'sd86;
            end
            10'd81: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = -16'sd41;
            end
            10'd82: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd5;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd1;
                rom_weight      = 16'sd38;
            end
            10'd83: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd5;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd4;
                rom_weight      = 16'sd41;
            end
            10'd84: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd5;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd39;
            end
            10'd85: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd5;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd12;
                rom_weight      = -16'sd47;
            end
            10'd86: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd5;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd16;
                rom_weight      = 16'sd44;
            end
            10'd87: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd5;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd84;
            end
            10'd88: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd5;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd18;
                rom_weight      = -16'sd102;
            end
            10'd89: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd5;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd19;
                rom_weight      = -16'sd43;
            end
            10'd90: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd5;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd20;
                rom_weight      = -16'sd63;
            end
            10'd91: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd5;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = 16'sd55;
            end
            10'd92: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd5;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = -16'sd35;
            end
            10'd93: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd6;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd34;
            end
            10'd94: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd6;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd5;
                rom_weight      = -16'sd65;
            end
            10'd95: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd6;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd81;
            end
            10'd96: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd6;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd13;
                rom_weight      = -16'sd65;
            end
            10'd97: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd6;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd16;
                rom_weight      = 16'sd105;
            end
            10'd98: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd6;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd76;
            end
            10'd99: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd6;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd18;
                rom_weight      = -16'sd40;
            end
            10'd100: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd6;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd19;
                rom_weight      = -16'sd37;
            end
            10'd101: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd6;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd21;
                rom_weight      = -16'sd37;
            end
            10'd102: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd6;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = 16'sd58;
            end
            10'd103: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd6;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = -16'sd31;
            end
            10'd104: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd1;
                rom_weight      = -16'sd45;
            end
            10'd105: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd46;
            end
            10'd106: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd3;
                rom_weight      = -16'sd64;
            end
            10'd107: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd4;
                rom_weight      = 16'sd49;
            end
            10'd108: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd73;
            end
            10'd109: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd11;
                rom_weight      = -16'sd46;
            end
            10'd110: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd12;
                rom_weight      = -16'sd32;
            end
            10'd111: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd14;
                rom_weight      = -16'sd78;
            end
            10'd112: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd16;
                rom_weight      = 16'sd127;
            end
            10'd113: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd52;
            end
            10'd114: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd18;
                rom_weight      = -16'sd84;
            end
            10'd115: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd19;
                rom_weight      = -16'sd93;
            end
            10'd116: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd21;
                rom_weight      = -16'sd34;
            end
            10'd117: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd7;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = -16'sd34;
            end
            10'd118: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd1;
                rom_weight      = -16'sd92;
            end
            10'd119: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd71;
            end
            10'd120: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd5;
                rom_weight      = -16'sd45;
            end
            10'd121: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd6;
                rom_weight      = -16'sd82;
            end
            10'd122: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd7;
                rom_weight      = -16'sd35;
            end
            10'd123: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd8;
                rom_weight      = -16'sd127;
            end
            10'd124: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = -16'sd99;
            end
            10'd125: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = -16'sd32;
            end
            10'd126: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd13;
                rom_weight      = -16'sd90;
            end
            10'd127: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd14;
                rom_weight      = -16'sd93;
            end
            10'd128: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = 16'sd31;
            end
            10'd129: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd19;
                rom_weight      = -16'sd89;
            end
            10'd130: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd21;
                rom_weight      = -16'sd31;
            end
            10'd131: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = -16'sd119;
            end
            10'd132: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd8;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = -16'sd42;
            end
            10'd133: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd9;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd4;
                rom_weight      = 16'sd83;
            end
            10'd134: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd9;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd6;
                rom_weight      = -16'sd43;
            end
            10'd135: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd9;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd8;
                rom_weight      = 16'sd50;
            end
            10'd136: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd9;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = 16'sd69;
            end
            10'd137: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd9;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd67;
            end
            10'd138: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd9;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd11;
                rom_weight      = 16'sd37;
            end
            10'd139: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd9;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd15;
                rom_weight      = -16'sd49;
            end
            10'd140: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd9;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd16;
                rom_weight      = 16'sd49;
            end
            10'd141: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd9;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = 16'sd43;
            end
            10'd142: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd10;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd4;
                rom_weight      = -16'sd33;
            end
            10'd143: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd10;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd6;
                rom_weight      = -16'sd110;
            end
            10'd144: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd10;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd8;
                rom_weight      = 16'sd51;
            end
            10'd145: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd10;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = 16'sd127;
            end
            10'd146: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd10;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd12;
                rom_weight      = -16'sd78;
            end
            10'd147: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd10;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd15;
                rom_weight      = -16'sd38;
            end
            10'd148: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd10;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd16;
                rom_weight      = 16'sd49;
            end
            10'd149: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd10;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd109;
            end
            10'd150: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd10;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd21;
                rom_weight      = -16'sd59;
            end
            10'd151: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd10;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = -16'sd42;
            end
            10'd152: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd11;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd40;
            end
            10'd153: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd11;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd3;
                rom_weight      = -16'sd63;
            end
            10'd154: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd11;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd6;
                rom_weight      = -16'sd80;
            end
            10'd155: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd11;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd8;
                rom_weight      = 16'sd47;
            end
            10'd156: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd11;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = -16'sd66;
            end
            10'd157: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd11;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd12;
                rom_weight      = -16'sd56;
            end
            10'd158: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd11;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd13;
                rom_weight      = -16'sd36;
            end
            10'd159: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd11;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd14;
                rom_weight      = -16'sd53;
            end
            10'd160: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd11;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd15;
                rom_weight      = -16'sd49;
            end
            10'd161: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd11;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd42;
            end
            10'd162: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd11;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd18;
                rom_weight      = -16'sd56;
            end
            10'd163: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd11;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd19;
                rom_weight      = -16'sd67;
            end
            10'd164: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd11;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd20;
                rom_weight      = -16'sd63;
            end
            10'd165: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd11;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = -16'sd122;
            end
            10'd166: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd12;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd0;
                rom_weight      = 16'sd75;
            end
            10'd167: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd12;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd1;
                rom_weight      = 16'sd37;
            end
            10'd168: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd12;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd4;
                rom_weight      = 16'sd106;
            end
            10'd169: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd12;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd5;
                rom_weight      = 16'sd32;
            end
            10'd170: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd12;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd6;
                rom_weight      = 16'sd110;
            end
            10'd171: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd12;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd7;
                rom_weight      = 16'sd54;
            end
            10'd172: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd12;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd8;
                rom_weight      = -16'sd127;
            end
            10'd173: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd12;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = -16'sd33;
            end
            10'd174: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd12;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd77;
            end
            10'd175: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd12;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd14;
                rom_weight      = 16'sd44;
            end
            10'd176: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd12;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd16;
                rom_weight      = 16'sd33;
            end
            10'd177: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd12;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd18;
                rom_weight      = 16'sd36;
            end
            10'd178: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd12;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd21;
                rom_weight      = 16'sd77;
            end
            10'd179: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd12;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = -16'sd92;
            end
            10'd180: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd13;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd47;
            end
            10'd181: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd13;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd6;
                rom_weight      = -16'sd55;
            end
            10'd182: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd13;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = 16'sd72;
            end
            10'd183: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd13;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd13;
                rom_weight      = 16'sd62;
            end
            10'd184: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd13;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd21;
                rom_weight      = -16'sd53;
            end
            10'd185: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd13;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = -16'sd89;
            end
            10'd186: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd13;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = -16'sd34;
            end
            10'd187: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd14;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd1;
                rom_weight      = -16'sd69;
            end
            10'd188: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd14;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd85;
            end
            10'd189: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd14;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd54;
            end
            10'd190: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd14;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd13;
                rom_weight      = -16'sd43;
            end
            10'd191: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd14;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd16;
                rom_weight      = 16'sd91;
            end
            10'd192: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd14;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd20;
                rom_weight      = -16'sd55;
            end
            10'd193: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd15;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd1;
                rom_weight      = -16'sd65;
            end
            10'd194: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd15;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd81;
            end
            10'd195: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd15;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd4;
                rom_weight      = 16'sd51;
            end
            10'd196: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd15;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd6;
                rom_weight      = -16'sd46;
            end
            10'd197: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd15;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = -16'sd67;
            end
            10'd198: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd15;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd36;
            end
            10'd199: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd15;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd15;
                rom_weight      = 16'sd65;
            end
            10'd200: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd15;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd16;
                rom_weight      = 16'sd32;
            end
            10'd201: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd15;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd127;
            end
            10'd202: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd15;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = -16'sd103;
            end
            10'd203: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd15;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = -16'sd35;
            end
            10'd204: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd1;
                rom_weight      = -16'sd39;
            end
            10'd205: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd62;
            end
            10'd206: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd6;
                rom_weight      = -16'sd55;
            end
            10'd207: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd8;
                rom_weight      = 16'sd38;
            end
            10'd208: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = 16'sd127;
            end
            10'd209: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd12;
                rom_weight      = -16'sd88;
            end
            10'd210: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd13;
                rom_weight      = -16'sd32;
            end
            10'd211: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd15;
                rom_weight      = -16'sd51;
            end
            10'd212: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd67;
            end
            10'd213: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd18;
                rom_weight      = -16'sd36;
            end
            10'd214: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd20;
                rom_weight      = -16'sd38;
            end
            10'd215: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd21;
                rom_weight      = -16'sd46;
            end
            10'd216: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = 16'sd127;
            end
            10'd217: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd16;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = -16'sd42;
            end
            10'd218: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd17;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd40;
            end
            10'd219: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd17;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd5;
                rom_weight      = -16'sd40;
            end
            10'd220: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd17;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = -16'sd34;
            end
            10'd221: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd17;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd13;
                rom_weight      = -16'sd44;
            end
            10'd222: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd17;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd14;
                rom_weight      = 16'sd33;
            end
            10'd223: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd17;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = 16'sd101;
            end
            10'd224: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd17;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd18;
                rom_weight      = -16'sd56;
            end
            10'd225: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd17;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd20;
                rom_weight      = -16'sd71;
            end
            10'd226: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd17;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = -16'sd60;
            end
            10'd227: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd17;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = -16'sd66;
            end
            10'd228: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd18;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd0;
                rom_weight      = 16'sd43;
            end
            10'd229: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd18;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd1;
                rom_weight      = -16'sd63;
            end
            10'd230: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd18;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd52;
            end
            10'd231: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd18;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd4;
                rom_weight      = 16'sd52;
            end
            10'd232: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd18;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd7;
                rom_weight      = 16'sd45;
            end
            10'd233: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd18;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd8;
                rom_weight      = 16'sd32;
            end
            10'd234: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd18;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd77;
            end
            10'd235: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd18;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd15;
                rom_weight      = -16'sd41;
            end
            10'd236: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd18;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd16;
                rom_weight      = 16'sd66;
            end
            10'd237: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd18;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd127;
            end
            10'd238: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd18;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd18;
                rom_weight      = -16'sd72;
            end
            10'd239: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd18;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd20;
                rom_weight      = -16'sd41;
            end
            10'd240: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd19;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd3;
                rom_weight      = -16'sd34;
            end
            10'd241: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd19;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd4;
                rom_weight      = 16'sd59;
            end
            10'd242: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd19;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd7;
                rom_weight      = -16'sd32;
            end
            10'd243: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd19;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = 16'sd53;
            end
            10'd244: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd19;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd90;
            end
            10'd245: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd19;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd11;
                rom_weight      = -16'sd54;
            end
            10'd246: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd19;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd12;
                rom_weight      = -16'sd46;
            end
            10'd247: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd19;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd15;
                rom_weight      = -16'sd63;
            end
            10'd248: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd19;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd16;
                rom_weight      = 16'sd68;
            end
            10'd249: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd19;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd18;
                rom_weight      = -16'sd80;
            end
            10'd250: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd19;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd19;
                rom_weight      = -16'sd61;
            end
            10'd251: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd19;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd20;
                rom_weight      = -16'sd87;
            end
            10'd252: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd0;
                rom_weight      = 16'sd109;
            end
            10'd253: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd88;
            end
            10'd254: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd55;
            end
            10'd255: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd4;
                rom_weight      = 16'sd81;
            end
            10'd256: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd5;
                rom_weight      = 16'sd42;
            end
            10'd257: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd7;
                rom_weight      = 16'sd41;
            end
            10'd258: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = 16'sd97;
            end
            10'd259: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd102;
            end
            10'd260: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd12;
                rom_weight      = 16'sd32;
            end
            10'd261: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd14;
                rom_weight      = 16'sd34;
            end
            10'd262: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd15;
                rom_weight      = 16'sd60;
            end
            10'd263: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd16;
                rom_weight      = 16'sd66;
            end
            10'd264: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd127;
            end
            10'd265: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd19;
                rom_weight      = 16'sd31;
            end
            10'd266: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd20;
                rom_weight      = 16'sd60;
            end
            10'd267: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd21;
                rom_weight      = 16'sd67;
            end
            10'd268: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd20;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = 16'sd98;
            end
            10'd269: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd21;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd0;
                rom_weight      = 16'sd32;
            end
            10'd270: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd21;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd48;
            end
            10'd271: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd21;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd14;
                rom_weight      = 16'sd36;
            end
            10'd272: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd21;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd109;
            end
            10'd273: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd21;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd21;
                rom_weight      = 16'sd39;
            end
            10'd274: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd21;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = 16'sd34;
            end
            10'd275: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd22;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd3;
                rom_weight      = -16'sd51;
            end
            10'd276: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd22;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd4;
                rom_weight      = 16'sd56;
            end
            10'd277: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd22;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd7;
                rom_weight      = 16'sd48;
            end
            10'd278: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd22;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = -16'sd99;
            end
            10'd279: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd22;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd48;
            end
            10'd280: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd22;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd11;
                rom_weight      = -16'sd59;
            end
            10'd281: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd22;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd12;
                rom_weight      = -16'sd60;
            end
            10'd282: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd22;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd13;
                rom_weight      = -16'sd49;
            end
            10'd283: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd22;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd51;
            end
            10'd284: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd22;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd18;
                rom_weight      = -16'sd59;
            end
            10'd285: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd22;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd20;
                rom_weight      = -16'sd112;
            end
            10'd286: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd22;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = -16'sd38;
            end
            10'd287: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd22;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = -16'sd54;
            end
            10'd288: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd23;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd3;
                rom_weight      = 16'sd34;
            end
            10'd289: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd23;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd6;
                rom_weight      = 16'sd62;
            end
            10'd290: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd23;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd7;
                rom_weight      = 16'sd37;
            end
            10'd291: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd23;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd15;
                rom_weight      = -16'sd56;
            end
            10'd292: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd23;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = 16'sd34;
            end
            10'd293: begin
                rom_target_type = 1'd0;
                rom_target_idx  = 5'd23;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd23;
                rom_weight      = 16'sd34;
            end
            10'd294: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd1;
                rom_weight      = -16'sd78;
            end
            10'd295: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd38;
            end
            10'd296: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd4;
                rom_weight      = 16'sd35;
            end
            10'd297: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd8;
                rom_weight      = 16'sd58;
            end
            10'd298: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd10;
                rom_weight      = 16'sd67;
            end
            10'd299: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd11;
                rom_weight      = -16'sd85;
            end
            10'd300: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd16;
                rom_weight      = 16'sd46;
            end
            10'd301: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd79;
            end
            10'd302: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd21;
                rom_weight      = -16'sd42;
            end
            10'd303: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd1;
                rom_weight      = 16'sd35;
            end
            10'd304: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd50;
            end
            10'd305: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd5;
                rom_weight      = 16'sd35;
            end
            10'd306: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd8;
                rom_weight      = -16'sd42;
            end
            10'd307: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd11;
                rom_weight      = -16'sd32;
            end
            10'd308: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd13;
                rom_weight      = -16'sd66;
            end
            10'd309: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd14;
                rom_weight      = 16'sd48;
            end
            10'd310: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd15;
                rom_weight      = 16'sd34;
            end
            10'd311: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd83;
            end
            10'd312: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd18;
                rom_weight      = -16'sd42;
            end
            10'd313: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd21;
                rom_weight      = 16'sd44;
            end
            10'd314: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd1;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = 16'sd127;
            end
            10'd315: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd2;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd76;
            end
            10'd316: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd2;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd6;
                rom_weight      = -16'sd31;
            end
            10'd317: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd2;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd8;
                rom_weight      = 16'sd32;
            end
            10'd318: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd2;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = 16'sd107;
            end
            10'd319: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd2;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd11;
                rom_weight      = 16'sd51;
            end
            10'd320: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd2;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd13;
                rom_weight      = 16'sd34;
            end
            10'd321: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd2;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd17;
                rom_weight      = -16'sd127;
            end
            10'd322: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd2;
                rom_weight      = -16'sd61;
            end
            10'd323: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd6;
                rom_weight      = -16'sd33;
            end
            10'd324: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd3;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = 16'sd67;
            end
            10'd325: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd8;
                rom_weight      = 16'sd63;
            end
            10'd326: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd9;
                rom_weight      = 16'sd107;
            end
            10'd327: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd11;
                rom_weight      = -16'sd46;
            end
            10'd328: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd15;
                rom_weight      = 16'sd35;
            end
            10'd329: begin
                rom_target_type = 1'd1;
                rom_target_idx  = 5'd4;
                rom_source_type = 1'd1;
                rom_source_idx  = 5'd22;
                rom_weight      = 16'sd127;
            end
            default: begin
                rom_target_type = 1'b0;
                rom_target_idx  = 5'd0;
                rom_source_type = 1'b0;
                rom_source_idx  = 5'd0;
                rom_weight      = 16'sd0;
            end
        endcase
    end

    reg [2:0] current_shift;
    always @(*) begin
        case (neuron_ptr)
            5'd0: current_shift = 3'd2;
            5'd1: current_shift = 3'd2;
            5'd2: current_shift = 3'd2;
            5'd3: current_shift = 3'd2;
            5'd4: current_shift = 3'd2;
            5'd5: current_shift = 3'd2;
            5'd6: current_shift = 3'd2;
            5'd7: current_shift = 3'd2;
            5'd8: current_shift = 3'd2;
            5'd9: current_shift = 3'd2;
            5'd10: current_shift = 3'd2;
            5'd11: current_shift = 3'd2;
            5'd12: current_shift = 3'd2;
            5'd13: current_shift = 3'd2;
            5'd14: current_shift = 3'd2;
            5'd15: current_shift = 3'd2;
            5'd16: current_shift = 3'd2;
            5'd17: current_shift = 3'd2;
            5'd18: current_shift = 3'd2;
            5'd19: current_shift = 3'd2;
            5'd20: current_shift = 3'd2;
            5'd21: current_shift = 3'd2;
            5'd22: current_shift = 3'd2;
            5'd23: current_shift = 3'd2;
            5'd24: current_shift = 3'd2;
            5'd25: current_shift = 3'd2;
            5'd26: current_shift = 3'd2;
            5'd27: current_shift = 3'd2;
            5'd28: current_shift = 3'd2;
            default: current_shift = 3'd1;
        endcase
    end

    wire signed [15:0] current_v = mem[neuron_ptr];
    wire signed [15:0] leaked_v  = current_v - (current_v >>> current_shift);
    wire signed [15:0] active_th = (neuron_ptr < 5'd24) ? 16'sd87 : 16'sd88;

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state               <= 3'd0;
            neuron_ptr          <= 5'd0;
            syn_ptr             <= 10'd0;
            latched_in_spikes   <= 7'd0;
            hid_spikes          <= 24'd0;
            latched_out_spikes  <= 5'd0;
            out_spikes          <= 5'd0;
            adder_a             <= 16'sd0;
            adder_b             <= 16'sd0;
            for (i = 0; i < 29; i = i + 1) mem[i] <= 16'sd0;
        end else begin
            case (state)
                3'd0: begin // IDLE waiting for 1ms tick
                    if (tick_1ms) begin
                        latched_in_spikes <= in_spikes;
                        hid_spikes        <= 24'd0; // clear transient spikes for new window
                        neuron_ptr        <= 5'd0;
                        state             <= 3'd1;  // Move to Phase 1: Leak & Threshold
                    end
                end

                3'd1: begin // PHASE 1: Apply leak, check threshold for all 29 neurons
                    if (current_v >= active_th) begin
                        mem[neuron_ptr] <= 16'sd0; // Spike reset
                        if (neuron_ptr < 5'd24)
                            hid_spikes[neuron_ptr] <= 1'b1;
                        else
                            latched_out_spikes[neuron_ptr - 5'd24] <= 1'b1;
                    end else begin
                        mem[neuron_ptr] <= leaked_v;
                    end

                    if (neuron_ptr == 5'd28) begin
                        syn_ptr <= 10'd0;
                        state   <= 3'd2; // Move to Phase 2: Sparse Synapse Accumulation
                    end else begin
                        neuron_ptr <= neuron_ptr + 5'd1;
                    end
                end

                3'd2: begin // PHASE 2: Stream through surviving sparse synapses
                    // Check if source spiked
                    if (rom_source_type == 1'b0) begin
                        if (latched_in_spikes[rom_source_idx]) begin
                            // Add weight to target membrane
                            // Actual target index in mem: if target_type==1, offset by 24
                            reg [4:0] actual_target = rom_target_type ? (rom_target_idx + 5'd24) : rom_target_idx;
                            mem[actual_target] <= mem[actual_target] + rom_weight;
                        end
                    end else begin
                        if (hid_spikes[rom_source_idx]) begin
                            reg [4:0] actual_target = rom_target_type ? (rom_target_idx + 5'd24) : rom_target_idx;
                            mem[actual_target] <= mem[actual_target] + rom_weight;
                        end
                    end

                    if (syn_ptr == 10'd329) begin
                        out_spikes <= latched_out_spikes;
                        latched_out_spikes <= 5'd0;
                        state <= 3'd0; // Return to Idle
                    end else begin
                        syn_ptr <= syn_ptr + 10'd1;
                    end
                end

                default: state <= 3'd0;
            endcase
        end
    end
endmodule
