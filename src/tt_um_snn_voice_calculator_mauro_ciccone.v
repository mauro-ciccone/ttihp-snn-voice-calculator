`default_nettype none
module tt_um_snn_voice_calculator_mauro_ciccone (
    input  wire [7:0] ui_in,    // Dedicated inputs: [0] = PDM mic
    output wire [7:0] uo_out,   // Dedicated outputs: 7-segment display
    input  wire [7:0] uio_in,   // IOs: Input path (unused)
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);

    wire       tick_1ms_wire;
    wire [7:0] cochlea_spikes;
    wire [4:0] wta_spikes;
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

    // --- 2. Pure Integer SNN Core ---
    snn_core u_snn (
        .clk_1mhz       (clk),
        .rst_n          (rst_n),
        .tick_1ms       (tick_1ms_wire),
        .cochlea_spikes (cochlea_spikes),
        .wta_spikes     (wta_spikes)
    );

    // --- 3. Post-WTA Control & Arithmetic Core ---
    fsm_calculator u_fsm (
        .clk_1mhz   (clk),
        .rst_n      (rst_n),
        .tick_1ms   (tick_1ms_wire),
        .wta_spikes (wta_spikes),
        .fsm_out    (fsm_state_wire)
    );

    // --- 4. Output Display Interface ---
    led_decoder u_led_decoder (
        .fsm_state  (fsm_state_wire),
        .segments   (led_segments)
    );

    assign uo_out = led_segments;
    assign uio_out[6:0] = cochlea_spikes[6:0];
    assign uio_out[7]   = cochlea_spikes[7] ^ tick_1ms_wire;
    assign uio_oe       = 8'hFF; 
    wire _unused = &{ena, ui_in[7:1], uio_in, 1'b0};

endmodule