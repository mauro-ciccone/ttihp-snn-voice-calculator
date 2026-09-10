`default_nettype none

module cochlea (
    input  wire       clk,        // 1 MHz master clock
    input  wire       rst_n,      // Active-low reset
    input  wire       pdm_in,     // 1-bit PDM microphone input
    output reg  [6:0] spikes_out, // 7-channel latched spikes for the SNN
    output reg        tick_1ms    // High for 1 clock cycle at end of 1ms frame
);

    // 10-bit window counter (counts 0 to 999 ticks = 1ms at 1MHz)
    reg [9:0] tick_cnt;

    // 7-Channel 16-bit Q6.10 Membrane Potentials
    reg [15:0] mem_0, mem_1, mem_2, mem_3, mem_4, mem_5, mem_6;

    // Sticky accumulator latches within the 1ms frame
    reg [6:0] sticky;

    // PDM pulse value: 1.0 * 1024 = 1024
    wire [15:0] pdm_val = pdm_in ? 16'd1024 : 16'd0;

    // --- 7-CHANNEL HARDWARE SHIFT-SUBTRACTORS ---
    // Ch 0: Beta = 0.8809
    wire [15:0] next_v_0 = mem_0 - (mem_0 >> 3) + (mem_0 >> 7) - (mem_0 >> 9) + pdm_val;
    // Ch 1: Beta = 0.9297
    wire [15:0] next_v_1 = mem_1 - (mem_1 >> 4) - (mem_1 >> 7) + pdm_val;
    // Ch 2: Beta = 0.9512
    wire [15:0] next_v_2 = mem_2 - (mem_2 >> 4) + (mem_2 >> 6) - (mem_2 >> 9) + pdm_val;
    // Ch 3: Beta = 0.9600
    wire [15:0] next_v_3 = mem_3 - (mem_3 >> 5) - (mem_3 >> 7) - (mem_3 >> 10) + pdm_val;
    // Ch 4: Beta = 0.9746
    wire [15:0] next_v_4 = mem_4 - (mem_4 >> 5) + (mem_4 >> 7) - (mem_4 >> 9) + pdm_val;
    // Ch 5: Beta = 0.9766
    wire [15:0] next_v_5 = mem_5 - (mem_5 >> 5) + (mem_5 >> 7) + pdm_val;
    // Ch 6: Beta = 0.9912
    wire [15:0] next_v_6 = mem_6 - (mem_6 >> 7) - (mem_6 >> 10) + pdm_val;

    // --- OPTIMIZED GATED THRESHOLD COMPARATORS ---
    wire fired_0 = (next_v_0 >= 16'd5120);
    wire fired_1 = (next_v_1 >= 16'd8192);
    wire fired_2 = (next_v_2 >= 16'd11264);
    wire fired_3 = (next_v_3 >= 16'd13568);
    wire fired_4 = (next_v_4 >= 16'd20992);
    wire fired_5 = (next_v_5 >= 16'd22784);
    wire fired_6 = (next_v_6 >= 16'd59392);

    wire [6:0] current_fired = {fired_6, fired_5, fired_4, fired_3, fired_2, fired_1, fired_0};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick_cnt   <= 10'd0;
            sticky     <= 7'd0;
            spikes_out <= 7'd0;
            tick_1ms   <= 1'b0;
            mem_0 <= 16'd0; mem_1 <= 16'd0; mem_2 <= 16'd0; mem_3 <= 16'd0;
            mem_4 <= 16'd0; mem_5 <= 16'd0; mem_6 <= 16'd0;
        end else begin
            // 1. Membrane update with reset-to-zero upon spike
            mem_0 <= fired_0 ? 16'd0 : next_v_0;
            mem_1 <= fired_1 ? 16'd0 : next_v_1;
            mem_2 <= fired_2 ? 16'd0 : next_v_2;
            mem_3 <= fired_3 ? 16'd0 : next_v_3;
            mem_4 <= fired_4 ? 16'd0 : next_v_4;
            mem_5 <= fired_5 ? 16'd0 : next_v_5;
            mem_6 <= fired_6 ? 16'd0 : next_v_6;

            // 2. 1ms Window Framing
            if (tick_cnt == 10'd999) begin
                tick_cnt   <= 10'd0;
                spikes_out <= sticky | current_fired;
                sticky     <= 7'd0;
                tick_1ms   <= 1'b1;
            end else begin
                tick_cnt   <= tick_cnt + 10'd1;
                sticky     <= sticky | current_fired;
                tick_1ms   <= 1'b0;
            end
        end
    end

endmodule