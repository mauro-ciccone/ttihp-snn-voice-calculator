/*
 * Tiny Tapeout Top-Level Integration: 7-Channel Cochlea + 24-Neuron SNN Core
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs:  ui_in[0] = PDM mic input
    output wire [7:0] uo_out,   // Dedicated outputs: uo_out[4:0] = SNN classification spikes
    input  wire [7:0] uio_in,   // IOs: Input path (unused)
    output wire [7:0] uio_out,  // IOs: Output path: [0] = 1ms tick, [7:1] = Cochlea spikes
    output wire [7:0] uio_oe,   // IOs: Enable path (all 1 = configured as outputs)
    input  wire       ena,      // Tiny Tapeout power enable (ignored)
    input  wire       clk,      // 1 MHz Master Clock
    input  wire       rst_n     // Active-low asynchronous reset
);

    // Internal inter-module buses
    wire       tick_1ms_wire;
    wire [6:0] cochlea_spikes;
    wire [4:0] snn_class_spikes;

    // 1. Dedicated Outputs: Route the 5 keyword classes out
    // uo_out[0] = drü, uo_out[1] = eis, uo_out[2] = vier, uo_out[3] = zwoi, uo_out[4] = noise
    assign uo_out = {3'b000, snn_class_spikes};

    // 2. Bidirectional IOs: Hardware Debug Bus
    // Pin 0: 1ms framing clock
    // Pins 1-7: Real-time spike activity of the 7 acoustic channels
    assign uio_out = {cochlea_spikes, tick_1ms_wire};
    assign uio_oe  = 8'hFF; // All 8 pins enabled as outputs

    // Suppress unused pin warnings during synthesis
    wire _unused = &{ena, ui_in[7:1], uio_in, 1'b0};

    // 3. Frontend: Standalone 7-Channel Silicon Cochlea
    cochlea cochlea_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .pdm_in     (ui_in[0]),
        .spikes_out (cochlea_spikes),
        .tick_1ms   (tick_1ms_wire)
    );

    // 4. Backend: Fully Unrolled 1-to-1 Asynchronous SNN Core
    snn_core snn_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .tick_1ms   (tick_1ms_wire),
        .in_spikes  (cochlea_spikes),
        .out_spikes (snn_class_spikes)
    );

endmodule