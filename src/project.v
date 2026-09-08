/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire tick_1ms_wire;

    // Configure uio_out[0] as output for the 1ms tick
    assign uio_out = {7'b0000000, tick_1ms_wire};
    assign uio_oe  = 8'b00000001;

    wire _unused = &{ena, ui_in[7:1], uio_in, 1'b0};

    // Instantiate Standalone Silicon Cochlea
    cochlea cochlea_inst (
        .clk(clk),
        .rst_n(rst_n),
        .pdm_in(ui_in[0]),
        .spikes_out(uo_out),
        .tick_1ms(tick_1ms_wire)
    );

endmodule
