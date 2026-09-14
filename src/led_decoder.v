`default_nettype none

module led_decoder (
    input  wire [4:0] fsm_state,  // 5-bit state from your FSM
    output reg  [7:0] segments    // Connect directly to Tiny Tapeout uo_out
);

    /* 
       --- ENCODING MAP ---
       5'd0 to 5'd8  : Displays numbers "0" to "8"
       5'd31 (-1)    : Displays "1" + Decimal Point (Dot)
       5'd30 (-2)    : Displays "2" + Decimal Point
       5'd29 (-3)    : Displays "3" + Decimal Point
       5'd9          : Displays "P" (Plus)
       5'd10         : Displays "-" (Minus)
       All others    : Blank
    */

    reg [6:0] seg_char;
    reg       dp;

    // Unsigned comparison treats -1 (31), -2 (30), -3 (29) as >= 29
    wire       is_negative = fsm_state[4] && (fsm_state >= 5'b11101);
    
    // Quick 2's complement inversion to get the absolute digit (1, 2, or 3)
    wire [3:0] abs_val     = is_negative ? (~fsm_state[3:0] + 1'b1) : fsm_state[3:0];

    always @(*) begin
        dp = is_negative; // Turn on the 8th LED dot for negative numbers
        
        if (is_negative || (fsm_state <= 5'd8)) begin
            // Decode the absolute numerical value
            case (abs_val)
                //            gfedcba
                4'd0: seg_char = 7'b0111111; // 0
                4'd1: seg_char = 7'b0000110; // 1
                4'd2: seg_char = 7'b1011011; // 2
                4'd3: seg_char = 7'b1001111; // 3
                4'd4: seg_char = 7'b1100110; // 4
                4'd5: seg_char = 7'b1101101; // 5
                4'd6: seg_char = 7'b1111101; // 6
                4'd7: seg_char = 7'b0000111; // 7
                4'd8: seg_char = 7'b1111111; // 8
                default: seg_char = 7'b0000000;
            endcase
        end else begin
            // Decode the non-numerical states
            case (fsm_state)
                5'd9:  seg_char = 7'b1110011; // 'P' (Plus)
                5'd10: seg_char = 7'b1000000; // '-' (Minus)
                default: seg_char = 7'b0000000; // Blank (Silence/Off)
            endcase
            dp = 1'b0; 
        end
        
        // Map to Tiny Tapeout array: {dp, g, f, e, d, c, b, a}
        segments = {dp, seg_char};
    end

endmodule