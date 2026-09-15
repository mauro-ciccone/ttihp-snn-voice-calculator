`default_nettype none

module cochlea (
    input  wire       clk_1mhz,        // 1 MHz master clock
    input  wire       rst_n,      // Active-low reset
    input  wire       pdm_in,     // 1-bit PDM microphone input
    output reg  [7:0] spikes_out, // 8-channel latched spikes for the SNN
    output reg        tick_1ms    // High for 1 clock cycle at end of 1ms frame
);

    // 10-bit window counter (counts 0 to 999 ticks = 1ms at 1MHz)
    reg [9:0] tick_cnt;

    // Heterogeneous Membrane Potentials (Total: 99 Flip-Flops)
    reg [6:0]  mem_0; // 7-bit  (4 frac, 3 int)
    reg [11:0] mem_1; // 12-bit (9 frac, 3 int)
    reg [10:0] mem_2; // 11-bit (7 frac, 4 int)
    reg [12:0] mem_3; // 13-bit (9 frac, 4 int)
    reg [13:0] mem_4; // 14-bit (10 frac, 4 int)
    reg [13:0] mem_5; // 14-bit (9 frac, 5 int)
    reg [11:0] mem_6; // 12-bit (7 frac, 5 int)
    reg [15:0] mem_7; // 16-bit (10 frac, 6 int)

    // Sticky accumulator latches within the 1ms frame
    reg [7:0] sticky;

    // --- 8-CHANNEL HETEROGENEOUS SHIFT-SUBTRACTORS & UNIPOLAR PDM ---
    // Ch 0: Beta = 0.8125 | PDM Add = 16
    wire [6:0]  next_v_0 = mem_0 - (mem_0 >> 2) + (mem_0 >> 4) + (pdm_in ? 7'd16 : 7'd0);
    // Ch 1: Beta = 0.8809 | PDM Add = 512
    wire [11:0] next_v_1 = mem_1 - (mem_1 >> 3) + (mem_1 >> 7) - (mem_1 >> 9) + (pdm_in ? 12'd512 : 12'd0);
    // Ch 2: Beta = 0.9297 | PDM Add = 128
    wire [10:0] next_v_2 = mem_2 - (mem_2 >> 4) - (mem_2 >> 7) + (pdm_in ? 11'd128 : 11'd0);
    // Ch 3: Beta = 0.9512 | PDM Add = 512
    wire [12:0] next_v_3 = mem_3 - (mem_3 >> 4) + (mem_3 >> 6) - (mem_3 >> 9) + (pdm_in ? 13'd512 : 13'd0);
    // Ch 4: Beta = 0.7539 | PDM Add = 1024
    wire [13:0] next_v_4 = mem_4 - (mem_4 >> 2) + (mem_4 >> 8) + (pdm_in ? 14'd1024 : 14'd0);
    // Ch 5: Beta = 0.9746 | PDM Add = 512
    wire [13:0] next_v_5 = mem_5 - (mem_5 >> 5) + (mem_5 >> 7) - (mem_5 >> 9) + (pdm_in ? 14'd512 : 14'd0);
    // Ch 6: Beta = 0.9766 | PDM Add = 128
    wire [11:0] next_v_6 = mem_6 - (mem_6 >> 5) + (mem_6 >> 7) + (pdm_in ? 12'd128 : 12'd0);
    // Ch 7: Beta = 0.9912 | PDM Add = 1024
    wire [15:0] next_v_7 = mem_7 - (mem_7 >> 7) - (mem_7 >> 10) + (pdm_in ? 16'd1024 : 16'd0);

    // --- ALIGNED THRESHOLD COMPARATORS ---
    wire fired_0 = (next_v_0 >= 7'd56);      // 3.50 * 16
    wire fired_1 = (next_v_1 >= 12'd2560);   // 5.00 * 512
    wire fired_2 = (next_v_2 >= 11'd1024);   // 8.00 * 128
    wire fired_3 = (next_v_3 >= 13'd5632);   // 11.00 * 512
    wire fired_4 = (next_v_4 >= 14'd2816);   // 2.75 * 1024
    wire fired_5 = (next_v_5 >= 14'd10752);  // 21.00 * 512
    wire fired_6 = (next_v_6 >= 12'd2848);   // 22.25 * 128
    wire fired_7 = (next_v_7 >= 16'd59904);  // 58.50 * 1024

    wire [7:0] current_fired = {fired_7, fired_6, fired_5, fired_4, fired_3, fired_2, fired_1, fired_0};

    always @(posedge clk_1mhz or negedge rst_n) begin
        if (!rst_n) begin
            tick_cnt   <= 10'd0;
            sticky     <= 8'd0;
            spikes_out <= 8'd0;
            tick_1ms   <= 1'b0;
            mem_0 <= 7'd0;  mem_1 <= 12'd0; mem_2 <= 11'd0; mem_3 <= 13'd0;
            mem_4 <= 14'd0; mem_5 <= 14'd0; mem_6 <= 12'd0; mem_7 <= 16'd0;
        end else begin
            // 1. Membrane update with reset-to-zero upon spike
            mem_0 <= fired_0 ? 7'd0  : next_v_0;
            mem_1 <= fired_1 ? 12'd0 : next_v_1;
            mem_2 <= fired_2 ? 11'd0 : next_v_2;
            mem_3 <= fired_3 ? 13'd0 : next_v_3;
            mem_4 <= fired_4 ? 14'd0 : next_v_4;
            mem_5 <= fired_5 ? 14'd0 : next_v_5;
            mem_6 <= fired_6 ? 12'd0 : next_v_6;
            mem_7 <= fired_7 ? 16'd0 : next_v_7;

            // 2. 1ms Window Framing (Read-Before-Clear Latches)
            if (tick_cnt == 10'd999) begin
                tick_cnt   <= 10'd0;
                spikes_out <= sticky | current_fired;
                sticky     <= 8'd0;
                tick_1ms   <= 1'b1;
            end else begin
                tick_cnt   <= tick_cnt + 10'd1;
                sticky     <= sticky | current_fired;
                tick_1ms   <= 1'b0;
            end
        end
    end

endmodule