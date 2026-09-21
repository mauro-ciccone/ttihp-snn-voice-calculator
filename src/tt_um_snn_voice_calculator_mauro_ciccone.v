`default_nettype none
module tt_um_snn_voice_calculator_mauro_ciccone (
    input  wire [7:0] ui_in,    
    output wire [7:0] uo_out,   
    input  wire [7:0] uio_in,   
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,   
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);

    wire       tick_1ms_wire;
    wire [7:0] cochlea_spikes;
    wire [5:0] base_spikes;
    wire [4:0] fsm_strobe;
    wire       blink_50ms;
    wire [4:0] fsm_state_wire;
    wire [7:0] led_segments;

    // --- 1. Master Acoustic Front-End ---
    cochlea u_cochlea (
        .clk_1mhz   (clk),
        .rst_n      (rst_n),
        .pdm_in     (ui_in[0]),
        .spikes_out (cochlea_spikes),
        .tick_1ms   (tick_1ms_wire)
    );

    // --- 2. Pure Integer SNN Core (No WTA) ---
    snn_core u_snn (
        .clk_1mhz       (clk),
        .rst_n          (rst_n),
        .tick_1ms       (tick_1ms_wire),
        .cochlea_spikes (cochlea_spikes),
        .base_spikes    (base_spikes)
    );

    // --- 3. Spike Arbiter (Margin Verification & User Prompting) ---
    spike_arbiter u_arbiter (
        .clk_1mhz    (clk),
        .rst_n       (rst_n),
        .tick_1ms    (tick_1ms_wire),
        .base_spikes (base_spikes),
        .fsm_strobe  (fsm_strobe),
        .blink_50ms  (blink_50ms)
    );

    // --- 4. Post-Arbiter Control & Arithmetic Core ---
    fsm_calculator u_fsm (
        .clk_1mhz   (clk),
        .rst_n      (rst_n),
        .tick_1ms   (tick_1ms_wire),
        .wta_spikes (fsm_strobe),
        .fsm_out    (fsm_state_wire)
    );

    // --- 5. Output Display Interface ---
    led_decoder u_led_decoder (
        .fsm_state  (fsm_state_wire),
        .segments   (led_segments)
    );

    // OR the generated display with the 50ms prompt blink on the DP (Decimal Point = bit 7)
    assign uo_out = {led_segments[7] | blink_50ms, led_segments[6:0]};
    
    assign uio_out[6:0] = cochlea_spikes[6:0];
    assign uio_out[7]   = cochlea_spikes[7] ^ tick_1ms_wire;
    assign uio_oe       = 8'hFF; 
    wire _unused = &{ena, ui_in[7:1], uio_in, 1'b0};

endmodule