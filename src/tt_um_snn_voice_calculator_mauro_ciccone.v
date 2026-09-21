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
    wire [5:0] cochlea_spikes; // Fixed to 6-bit width
    wire [4:0] wta_spikes;
    wire [4:0] fsm_state_wire;
    wire [7:0] led_segments;

    cochlea u_cochlea (
        .clk_1mhz   (clk),
        .rst_n      (rst_n),
        .pdm_in     (ui_in[0]),
        .spikes_out (cochlea_spikes),
        .tick_1ms   (tick_1ms_wire)
    );

    snn_core u_snn (
        .clk_1mhz       (clk),
        .rst_n          (rst_n),
        .tick_1ms       (tick_1ms_wire),
        .cochlea_spikes (cochlea_spikes),
        .wta_spikes     (wta_spikes)
    );

    fsm_calculator u_fsm (
        .clk_1mhz   (clk),
        .rst_n      (rst_n),
        .tick_1ms   (tick_1ms_wire),
        .wta_spikes (wta_spikes),
        .fsm_out    (fsm_state_wire)
    );

    led_decoder u_led_decoder (
        .fsm_state  (fsm_state_wire),
        .segments   (led_segments)
    );

    assign uo_out = led_segments;
    
    // Safely route 6 bits and pad the rest
    assign uio_out[7:0] = 8'b0;
    assign uio_oe       = 8'b0; 
    wire _unused = &{ena, ui_in[7:1], uio_in, 1'b0};

endmodule