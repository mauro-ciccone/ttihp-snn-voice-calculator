`default_nettype none

module cochlea (
    input  wire       clk,        // 1 MHz master clock
    input  wire       rst_n,      // Active-low reset
    input  wire       pdm_in,     // 1-bit PDM microphone input
    output reg  [7:0] spikes_out, // 8-channel latched spikes for the SNN
    output reg        tick_1ms    // High for 1 clock cycle at the end of each 1ms frame
);

    // 10-bit window counter (counts 0 to 999 ticks = 1ms at 1MHz)
    reg [9:0] tick_cnt;

    // 8-Channel 16-bit Q6.10 Membrane Potentials (Max threshold 51.15 fits in 16-bit)
    reg [15:0] mem_0, mem_1, mem_2, mem_3, mem_4, mem_5, mem_6, mem_7;

    // Sticky accumulator latches within the 1ms frame
    reg [7:0] sticky;

    // PDM pulse value scaled to Q6.10: 1.0 * 1024 = 1024
    wire [15:0] pdm_val = pdm_in ? 16'd1024 : 16'd0;

    // --- CHANNEL LEAK MULTIPLICATION & ADDITION ---
    // Product is 16-bit * 10-bit = 26-bit. [25:10] extracts division by 1024.
    wire [15:0] next_v_0 = ((mem_0 * 10'd768)  >> 10) + pdm_val;
    wire [15:0] next_v_1 = ((mem_1 * 10'd819)  >> 10) + pdm_val;
    wire [15:0] next_v_2 = ((mem_2 * 10'd870)  >> 10) + pdm_val;
    wire [15:0] next_v_3 = ((mem_3 * 10'd922)  >> 10) + pdm_val;
    wire [15:0] next_v_4 = ((mem_4 * 10'd973)  >> 10) + pdm_val;
    wire [15:0] next_v_5 = ((mem_5 * 10'd993)  >> 10) + pdm_val;
    wire [15:0] next_v_6 = ((mem_6 * 10'd1004) >> 10) + pdm_val;
    wire [15:0] next_v_7 = ((mem_7 * 10'd1014) >> 10) + pdm_val;

    // --- THRESHOLD COMPARATORS ---
    wire fired_0 = (next_v_0 >= 16'd2785);
    wire fired_1 = (next_v_1 >= 16'd3313);
    wire fired_2 = (next_v_2 >= 16'd4183);
    wire fired_3 = (next_v_3 >= 16'd5875);
    wire fired_4 = (next_v_4 >= 16'd11008);
    wire fired_5 = (next_v_5 >= 16'd17869);
    wire fired_6 = (next_v_6 >= 16'd26573);
    wire fired_7 = (next_v_7 >= 16'd52378);

    wire [7:0] current_fired = {fired_7, fired_6, fired_5, fired_4, fired_3, fired_2, fired_1, fired_0};

    always @(posedge clk) begin
        if (!rst_n) begin
            tick_cnt   <= 10'd0;
            sticky     <= 8'd0;
            spikes_out <= 8'd0;
            tick_1ms   <= 1'b0;
            mem_0 <= 16'd0; mem_1 <= 16'd0; mem_2 <= 16'd0; mem_3 <= 16'd0;
            mem_4 <= 16'd0; mem_5 <= 16'd0; mem_6 <= 16'd0; mem_7 <= 16'd0;
        end else begin
            // 1. Membrane integration & reset-to-zero upon fire
            mem_0 <= fired_0 ? 16'd0 : next_v_0;
            mem_1 <= fired_1 ? 16'd0 : next_v_1;
            mem_2 <= fired_2 ? 16'd0 : next_v_2;
            mem_3 <= fired_3 ? 16'd0 : next_v_3;
            mem_4 <= fired_4 ? 16'd0 : next_v_4;
            mem_5 <= fired_5 ? 16'd0 : next_v_5;
            mem_6 <= fired_6 ? 16'd0 : next_v_6;
            mem_7 <= fired_7 ? 16'd0 : next_v_7;

            // 2. Window Framing Logic
            if (tick_cnt == 10'd999) begin
                tick_cnt   <= 10'd0;
                spikes_out <= sticky | current_fired; // Export full 1ms frame spikes
                sticky     <= 8'd0;                   // Clear sticky register
                tick_1ms   <= 1'b1;                   // Trigger SNN evaluation
            end else begin
                tick_cnt   <= tick_cnt + 10'd1;
                sticky     <= sticky | current_fired;
                tick_1ms   <= 1'b0;
            end
        end
    end

endmodule