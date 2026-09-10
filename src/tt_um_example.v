`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    
    output wire [7:0] uo_out,   
    input  wire [7:0] uio_in,   
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,   
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);

    // Map input pins directly to SNN inputs
    wire [6:0] fake_cochlea_spikes = ui_in[6:0];
    wire       fake_tick_1ms       = ui_in[7];
    
    wire [4:0] snn_class_spikes;

    // Route output to pins
    assign uo_out  = {3'b0, snn_class_spikes};
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused = &{ena, uio_in, 1'b0};

    snn_core snn_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .tick_1ms   (fake_tick_1ms),
        .in_spikes  (fake_cochlea_spikes),
        .out_spikes (snn_class_spikes)
    );

endmodule