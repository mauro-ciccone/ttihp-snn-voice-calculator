`default_nettype none
module cochlea (
    input  wire       clk_1mhz,    
    input  wire       rst_n,      
    input  wire       pdm_in,     
    output reg  [5:0] spikes_out, // Strictly 6 channels
    output reg        tick_1ms    
);

    reg [9:0] tick_cnt;
    reg [5:0] sticky;

    reg [11:0] mem_0, mem_1, mem_2, mem_3, mem_4, mem_5;

    wire [11:0] next_v_0 = mem_0 - (mem_0 >> 5) + (pdm_in ? 12'd32 : 12'd0);
    wire [11:0] next_v_1 = mem_1 - (mem_1 >> 4) + (mem_1 >> 6) + (pdm_in ? 12'd64 : 12'd0);
    wire [11:0] next_v_2 = mem_2 - (mem_2 >> 6) + (pdm_in ? 12'd64 : 12'd0);
    wire [11:0] next_v_3 = mem_3 - (mem_3 >> 5) + (pdm_in ? 12'd32 : 12'd0);
    wire [11:0] next_v_4 = mem_4 - (mem_4 >> 5) + (pdm_in ? 12'd32 : 12'd0);
    wire [11:0] next_v_5 = mem_5 - (mem_5 >> 1) - (mem_5 >> 1) + (mem_5 >> 4) + (pdm_in ? 12'd16 : 12'd0);

    wire fired_0 = (next_v_0 >= 12'd552);  // 17.25 * 32
    wire fired_1 = (next_v_1 >= 12'd752);  // 11.75 * 64
    wire fired_2 = (next_v_2 >= 12'd2144); // 33.50 * 64
    wire fired_3 = (next_v_3 >= 12'd536);  // 16.75 * 32
    wire fired_4 = (next_v_4 >= 12'd560);  // 17.50 * 32
    wire fired_5 = (next_v_5 >= 12'd18);   // 1.125 * 16

    wire [5:0] current_fired = {fired_5, fired_4, fired_3, fired_2, fired_1, fired_0};

    always @(posedge clk_1mhz or negedge rst_n) begin
        if (!rst_n) begin
            tick_cnt   <= 10'd0;
            sticky     <= 6'd0;
            spikes_out <= 6'd0;
            tick_1ms   <= 1'b0;
            mem_0 <= 0; mem_1 <= 0; mem_2 <= 0; mem_3 <= 0; mem_4 <= 0; mem_5 <= 0;
        end else begin
            mem_0 <= fired_0 ? 12'd0 : next_v_0;
            mem_1 <= fired_1 ? 12'd0 : next_v_1;
            mem_2 <= fired_2 ? 12'd0 : next_v_2;
            mem_3 <= fired_3 ? 12'd0 : next_v_3;
            mem_4 <= fired_4 ? 12'd0 : next_v_4;
            mem_5 <= fired_5 ? 12'd0 : next_v_5;

            if (tick_cnt == 10'd999) begin
                tick_cnt   <= 10'd0;
                spikes_out <= sticky | current_fired;
                sticky     <= 6'd0;
                tick_1ms   <= 1'b1;
            end else begin
                tick_cnt   <= tick_cnt + 10'd1;
                sticky     <= sticky | current_fired;
                tick_1ms   <= 1'b0;
            end
        end
    end
endmodule