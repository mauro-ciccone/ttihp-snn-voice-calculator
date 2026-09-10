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

    wire tick_1ms_wire;
    wire [6:0] cochlea_spikes;

    // Route cochlea directly to output pins so it doesn't get optimized away
    assign uo_out  = {1'b0, cochlea_spikes};
    assign uio_out = {7'b0, tick_1ms_wire};
    assign uio_oe  = 8'hFF;

    wire _unused = &{ena, ui_in[7:1], uio_in, 1'b0};

    cochlea cochlea_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .pdm_in     (ui_in[0]),
        .spikes_out (cochlea_spikes),
        .tick_1ms   (tick_1ms_wire)
    );

endmodule