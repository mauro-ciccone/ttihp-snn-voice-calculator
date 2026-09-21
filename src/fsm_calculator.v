`default_nettype none
module fsm_calculator (
    input  wire       clk_1mhz,   
    input  wire       rst_n,      
    input  wire       tick_1ms,   
    input  wire [4:0] wta_spikes, // Now receives the safe arbiter strobe
    output reg  [4:0] fsm_out     
);

    localparam WAIT_OP1 = 2'd0;
    localparam WAIT_OPR = 2'd1;
    localparam WAIT_OP2 = 2'd2;
    localparam SHOW_RES = 2'd3;

    localparam DISP_BLANK = 5'd16; 
    localparam DISP_PLUS  = 5'd9;
    localparam DISP_MINUS = 5'd10;

    reg [1:0]  state;
    reg [2:0]  op1;       
    reg        is_plus;   
    reg [13:0] timer;     // Expanded to 14 bits for 10,000ms

    wire num_valid = wta_spikes[0] | wta_spikes[1] | wta_spikes[2];
    wire opr_valid = wta_spikes[3] | wta_spikes[4];
    wire [2:0] num_in = wta_spikes[2] ? 3'd3 :
                        wta_spikes[1] ? 3'd2 :
                        wta_spikes[0] ? 3'd1 : 3'd0;

    wire signed [4:0] signed_op1 = {2'b00, op1};
    wire signed [4:0] signed_op2 = {2'b00, num_in};
    wire signed [4:0] calc_res   = is_plus ? (signed_op1 + signed_op2) : (signed_op1 - signed_op2);

    always @(posedge clk_1mhz or negedge rst_n) begin
        if (!rst_n) begin
            state    <= WAIT_OP1;
            op1      <= 3'd0;
            is_plus  <= 1'b0;
            timer    <= 14'd0;
            fsm_out  <= DISP_BLANK;
        end else if (tick_1ms) begin 
            
            // Cap at 10,000ms (10 seconds)
            if (timer < 14'd10000) begin
                timer <= timer + 1'b1;
            end

            case (state)
                WAIT_OP1: begin
                    if (num_valid) begin
                        op1     <= num_in;
                        fsm_out <= {2'b00, num_in};
                        state   <= WAIT_OPR;
                        timer   <= 14'd0;
                    end else if (timer == 14'd10000) begin
                        fsm_out <= DISP_BLANK;
                    end
                end
                WAIT_OPR: begin
                    if (opr_valid) begin
                        is_plus <= wta_spikes[3]; 
                        fsm_out <= wta_spikes[3] ? DISP_PLUS : DISP_MINUS;
                        state   <= WAIT_OP2;
                        timer   <= 14'd0;
                    end else if (timer == 14'd10000) begin
                        state   <= WAIT_OP1;
                        fsm_out <= DISP_BLANK;
                    end
                end
                WAIT_OP2: begin
                    if (num_valid) begin
                        fsm_out <= calc_res; 
                        state   <= SHOW_RES;
                        timer   <= 14'd0;
                    end else if (timer == 14'd10000) begin
                        state   <= WAIT_OP1;
                        fsm_out <= DISP_BLANK;
                    end
                end
                SHOW_RES: begin
                    if (timer == 14'd10000) begin
                        state   <= WAIT_OP1;
                        fsm_out <= DISP_BLANK;
                        timer   <= 14'd0;
                    end
                end
                default: state <= WAIT_OP1;
            endcase
        end
    end
endmodule