`default_nettype none

module tt_snn_voice_calculator_mauro_ciccone (
    input  wire [7:0] ui_in,    // Dedicated inputs: [0] = PDM mic, [6:1] = Dynamic WTA stimulus
    output wire [7:0] uo_out,   // Dedicated outputs: 7-segment display {dp, g, f, e, d, c, b, a}
    input  wire [7:0] uio_in,   // IOs: Input path (unused)
    output wire [7:0] uio_out,  // IOs: Output path: Cochlea debug & 1ms CE monitor
    output wire [7:0] uio_oe,   // IOs: Enable path (all 1 = configured as outputs)
    input  wire       ena,      // Tiny Tapeout power enable (ignored)
    input  wire       clk,      // 1 MHz Master Clock
    input  wire       rst_n     // Active-low asynchronous reset
);

    // --- Internal Routing Interconnects ---
    wire       tick_1ms_wire;
    wire [7:0] cochlea_spikes;
    wire [4:0] fsm_state_wire;
    wire [7:0] led_segments;

    // --- 1. Master Acoustic Front-End (Cochlea) ---
    cochlea u_cochlea (
        .clk_1mhz   (clk),
        .rst_n      (rst_n),
        .pdm_in     (ui_in[0]),
        .spikes_out (cochlea_spikes),
        .tick_1ms   (tick_1ms_wire)
    );

    // --- 2. Post-WTA Control & Arithmetic Core (FSM) ---
    // ui_in[6:1] injects dynamic input to ensure Yosys preserves every branch & state
    fsm_calculator u_fsm (
        .clk_1mhz   (clk),
        .rst_n      (rst_n),
        .tick_1ms   (tick_1ms_wire),
        .wta_spikes (ui_in[6:1]),
        .fsm_out    (fsm_state_wire)
    );

    // --- 3. Output Display Interface (LED Decoder) ---
    led_decoder u_led_decoder (
        .fsm_state  (fsm_state_wire),
        .segments   (led_segments)
    );

    // --- Hardware Pin Mappings ---
    // Primary outputs: LED 7-segment display bus
    assign uo_out = led_segments;

    // Secondary debug outputs: Expose all 8 cochlea channels + tick_1ms
    // Bit 7 is XORed with tick_1ms so both signals actively drive physical silicon pins
    assign uio_out[6:0] = cochlea_spikes[6:0];
    assign uio_out[7]   = cochlea_spikes[7] ^ tick_1ms_wire;
    assign uio_oe       = 8'hFF; // Configure all uio pins as active outputs

    // Suppress unused pin warnings cleanly
    wire _unused = &{ena, ui_in[7], uio_in, 1'b0};

endmodule