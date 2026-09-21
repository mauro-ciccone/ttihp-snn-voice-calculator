`default_nettype none
module spike_arbiter (
    input  wire       clk_1mhz,
    input  wire       rst_n,
    input  wire       tick_1ms,
    input  wire [5:0] base_spikes,    // 0=eis, 1=zwoi, 2=dru, 3=plus, 4=minus, 5=noise
    output reg  [4:0] fsm_strobe,     // One-hot output passed to FSM
    output wire       blink_50ms      // High for first 50ms of every 1s window
);

    reg [9:0] ms_timer;
    reg [7:0] counts [0:5];

    // Export the 50ms blink prompt for the user
    assign blink_50ms = (ms_timer < 10'd50);

    // Combinational block to find Max and Second Max
    reg [7:0] max_val;
    reg [2:0] max_idx;
    reg [7:0] sec_max;
    integer i;

    always @(*) begin
        max_val = 0;
        max_idx = 0;
        sec_max = 0;
        for (i = 0; i < 6; i = i + 1) begin
            if (counts[i] > max_val) begin
                sec_max = max_val;
                max_val = counts[i];
                max_idx = i[2:0];
            end else if (counts[i] > sec_max) begin
                sec_max = counts[i];
            end
        end
    end

    always @(posedge clk_1mhz or negedge rst_n) begin
        if (!rst_n) begin
            ms_timer <= 0;
            fsm_strobe <= 5'd0;
            counts[0] <= 0; counts[1] <= 0; counts[2] <= 0;
            counts[3] <= 0; counts[4] <= 0; counts[5] <= 0;
        end else if (tick_1ms) begin
            // Default: strobe is only high for exactly one 1ms tick
            fsm_strobe <= 5'd0;

            if (ms_timer == 10'd999) begin
                ms_timer <= 0;
                
                // Hardware execution of Phase 6 logic: >40 spikes AND margin >= 2 AND not noise(5)
                if ((max_val >= 8'd40) && ((max_val - sec_max) >= 8'd2) && (max_idx < 3'd5)) begin
                    fsm_strobe[max_idx] <= 1'b1;
                end

                // Reset all counters for the next 1-second window
                counts[0] <= 0; counts[1] <= 0; counts[2] <= 0;
                counts[3] <= 0; counts[4] <= 0; counts[5] <= 0;
            end else begin
                ms_timer <= ms_timer + 1;
                // Accumulate spikes (bounded safely below 255)
                if (base_spikes[0] && counts[0] < 255) counts[0] <= counts[0] + 1;
                if (base_spikes[1] && counts[1] < 255) counts[1] <= counts[1] + 1;
                if (base_spikes[2] && counts[2] < 255) counts[2] <= counts[2] + 1;
                if (base_spikes[3] && counts[3] < 255) counts[3] <= counts[3] + 1;
                if (base_spikes[4] && counts[4] < 255) counts[4] <= counts[4] + 1;
                if (base_spikes[5] && counts[5] < 255) counts[5] <= counts[5] + 1;
            end
        end
    end
endmodule