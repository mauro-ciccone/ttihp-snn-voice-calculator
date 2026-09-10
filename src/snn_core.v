`default_nettype none
module snn_core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tick_1ms,
    input  wire [6:0]  in_spikes,
    output reg  [4:0] out_spikes
);

    // Membrane registers (16-bit signed)
    reg signed [15:0] mem_hidden [0:23];
    reg signed [15:0] mem_out [0:4];
    reg [23:0] spk_hidden;

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            spk_hidden <= 24'b0;
            out_spikes <= 5'b0;
            for (i = 0; i < 24; i = i + 1) mem_hidden[i] <= 16'sd0;
            for (i = 0; i < 5; i = i + 1) mem_out[i] <= 16'sd0;
        end else if (tick_1ms) begin
            // --- Hidden Neuron 0 (Shift: 2) ---
            if (spk_hidden[0]) mem_hidden[0] <= 16'sd0;
            else begin
                mem_hidden[0] <= (mem_hidden[0] - (mem_hidden[0] >>> 2)) + (in_spikes[3] ? 16'sd43 : 16'sd0) + (spk_hidden[0] ? -16'sd81 : 16'sd0) + (spk_hidden[1] ? -16'sd51 : 16'sd0) + (spk_hidden[4] ? 16'sd53 : 16'sd0) + (spk_hidden[5] ? -16'sd41 : 16'sd0) + (spk_hidden[6] ? -16'sd57 : 16'sd0) + (spk_hidden[7] ? -16'sd51 : 16'sd0) + (spk_hidden[8] ? -16'sd43 : 16'sd0) + (spk_hidden[9] ? 16'sd93 : 16'sd0) + (spk_hidden[10] ? 16'sd110 : 16'sd0) + (spk_hidden[11] ? -16'sd32 : 16'sd0) + (spk_hidden[12] ? -16'sd34 : 16'sd0) + (spk_hidden[14] ? -16'sd44 : 16'sd0) + (spk_hidden[16] ? 16'sd107 : 16'sd0) + (spk_hidden[17] ? -16'sd71 : 16'sd0) + (spk_hidden[18] ? -16'sd82 : 16'sd0) + (spk_hidden[22] ? 16'sd45 : 16'sd0);
            end
            spk_hidden[0] <= (mem_hidden[0] >= 16'sd87);

            // --- Hidden Neuron 1 (Shift: 2) ---
            if (spk_hidden[1]) mem_hidden[1] <= 16'sd0;
            else begin
                mem_hidden[1] <= (mem_hidden[1] - (mem_hidden[1] >>> 2)) + (in_spikes[3] ? 16'sd44 : 16'sd0) + (spk_hidden[1] ? 16'sd46 : 16'sd0) + (spk_hidden[9] ? -16'sd58 : 16'sd0) + (spk_hidden[10] ? 16'sd43 : 16'sd0) + (spk_hidden[12] ? -16'sd35 : 16'sd0) + (spk_hidden[17] ? -16'sd32 : 16'sd0) + (spk_hidden[23] ? -16'sd50 : 16'sd0);
            end
            spk_hidden[1] <= (mem_hidden[1] >= 16'sd87);

            // --- Hidden Neuron 2 (Shift: 2) ---
            if (spk_hidden[2]) mem_hidden[2] <= 16'sd0;
            else begin
                mem_hidden[2] <= (mem_hidden[2] - (mem_hidden[2] >>> 2)) + (in_spikes[6] ? 16'sd50 : 16'sd0) + (spk_hidden[2] ? 16'sd88 : 16'sd0) + (spk_hidden[12] ? -16'sd42 : 16'sd0) + (spk_hidden[15] ? 16'sd41 : 16'sd0) + (spk_hidden[23] ? -16'sd49 : 16'sd0);
            end
            spk_hidden[2] <= (mem_hidden[2] >= 16'sd87);

            // --- Hidden Neuron 3 (Shift: 2) ---
            if (spk_hidden[3]) mem_hidden[3] <= 16'sd0;
            else begin
                mem_hidden[3] <= (mem_hidden[3] - (mem_hidden[3] >>> 2)) + (spk_hidden[0] ? 16'sd51 : 16'sd0) + (spk_hidden[1] ? -16'sd76 : 16'sd0) + (spk_hidden[2] ? -16'sd71 : 16'sd0) + (spk_hidden[3] ? 16'sd47 : 16'sd0) + (spk_hidden[4] ? 16'sd46 : 16'sd0) + (spk_hidden[7] ? 16'sd48 : 16'sd0) + (spk_hidden[9] ? 16'sd35 : 16'sd0) + (spk_hidden[10] ? 16'sd126 : 16'sd0) + (spk_hidden[15] ? -16'sd52 : 16'sd0) + (spk_hidden[16] ? 16'sd116 : 16'sd0) + (spk_hidden[17] ? -16'sd35 : 16'sd0) + (spk_hidden[19] ? 16'sd67 : 16'sd0) + (spk_hidden[23] ? -16'sd31 : 16'sd0);
            end
            spk_hidden[3] <= (mem_hidden[3] >= 16'sd87);

            // --- Hidden Neuron 4 (Shift: 2) ---
            if (spk_hidden[4]) mem_hidden[4] <= 16'sd0;
            else begin
                mem_hidden[4] <= (mem_hidden[4] - (mem_hidden[4] >>> 2)) + (in_spikes[3] ? 16'sd55 : 16'sd0) + (spk_hidden[2] ? -16'sd44 : 16'sd0) + (spk_hidden[4] ? -16'sd87 : 16'sd0) + (spk_hidden[5] ? -16'sd43 : 16'sd0) + (spk_hidden[6] ? -16'sd105 : 16'sd0) + (spk_hidden[10] ? 16'sd47 : 16'sd0) + (spk_hidden[12] ? -16'sd68 : 16'sd0) + (spk_hidden[13] ? -16'sd42 : 16'sd0) + (spk_hidden[14] ? -16'sd55 : 16'sd0) + (spk_hidden[15] ? -16'sd31 : 16'sd0) + (spk_hidden[17] ? -16'sd127 : 16'sd0) + (spk_hidden[19] ? -16'sd31 : 16'sd0) + (spk_hidden[20] ? -16'sd44 : 16'sd0) + (spk_hidden[21] ? -16'sd43 : 16'sd0) + (spk_hidden[22] ? -16'sd86 : 16'sd0) + (spk_hidden[23] ? -16'sd41 : 16'sd0);
            end
            spk_hidden[4] <= (mem_hidden[4] >= 16'sd87);

            // --- Hidden Neuron 5 (Shift: 2) ---
            if (spk_hidden[5]) mem_hidden[5] <= 16'sd0;
            else begin
                mem_hidden[5] <= (mem_hidden[5] - (mem_hidden[5] >>> 2)) + (in_spikes[3] ? 16'sd32 : 16'sd0) + (spk_hidden[1] ? 16'sd38 : 16'sd0) + (spk_hidden[4] ? 16'sd41 : 16'sd0) + (spk_hidden[10] ? 16'sd39 : 16'sd0) + (spk_hidden[12] ? -16'sd47 : 16'sd0) + (spk_hidden[16] ? 16'sd44 : 16'sd0) + (spk_hidden[17] ? -16'sd84 : 16'sd0) + (spk_hidden[18] ? -16'sd102 : 16'sd0) + (spk_hidden[19] ? -16'sd43 : 16'sd0) + (spk_hidden[20] ? -16'sd63 : 16'sd0) + (spk_hidden[22] ? 16'sd55 : 16'sd0) + (spk_hidden[23] ? -16'sd35 : 16'sd0);
            end
            spk_hidden[5] <= (mem_hidden[5] >= 16'sd87);

            // --- Hidden Neuron 6 (Shift: 2) ---
            if (spk_hidden[6]) mem_hidden[6] <= 16'sd0;
            else begin
                mem_hidden[6] <= (mem_hidden[6] - (mem_hidden[6] >>> 2)) + (in_spikes[1] ? -16'sd33 : 16'sd0) + (spk_hidden[2] ? -16'sd34 : 16'sd0) + (spk_hidden[5] ? -16'sd65 : 16'sd0) + (spk_hidden[10] ? 16'sd81 : 16'sd0) + (spk_hidden[13] ? -16'sd65 : 16'sd0) + (spk_hidden[16] ? 16'sd105 : 16'sd0) + (spk_hidden[17] ? -16'sd76 : 16'sd0) + (spk_hidden[18] ? -16'sd40 : 16'sd0) + (spk_hidden[19] ? -16'sd37 : 16'sd0) + (spk_hidden[21] ? -16'sd37 : 16'sd0) + (spk_hidden[22] ? 16'sd58 : 16'sd0) + (spk_hidden[23] ? -16'sd31 : 16'sd0);
            end
            spk_hidden[6] <= (mem_hidden[6] >= 16'sd87);

            // --- Hidden Neuron 7 (Shift: 2) ---
            if (spk_hidden[7]) mem_hidden[7] <= 16'sd0;
            else begin
                mem_hidden[7] <= (mem_hidden[7] - (mem_hidden[7] >>> 2)) + (in_spikes[0] ? -16'sd34 : 16'sd0) + (in_spikes[3] ? 16'sd41 : 16'sd0) + (spk_hidden[1] ? -16'sd45 : 16'sd0) + (spk_hidden[2] ? -16'sd46 : 16'sd0) + (spk_hidden[3] ? -16'sd64 : 16'sd0) + (spk_hidden[4] ? 16'sd49 : 16'sd0) + (spk_hidden[10] ? 16'sd73 : 16'sd0) + (spk_hidden[11] ? -16'sd46 : 16'sd0) + (spk_hidden[12] ? -16'sd32 : 16'sd0) + (spk_hidden[14] ? -16'sd78 : 16'sd0) + (spk_hidden[16] ? 16'sd127 : 16'sd0) + (spk_hidden[17] ? -16'sd52 : 16'sd0) + (spk_hidden[18] ? -16'sd84 : 16'sd0) + (spk_hidden[19] ? -16'sd93 : 16'sd0) + (spk_hidden[21] ? -16'sd34 : 16'sd0) + (spk_hidden[23] ? -16'sd34 : 16'sd0);
            end
            spk_hidden[7] <= (mem_hidden[7] >= 16'sd87);

            // --- Hidden Neuron 8 (Shift: 2) ---
            if (spk_hidden[8]) mem_hidden[8] <= 16'sd0;
            else begin
                mem_hidden[8] <= (mem_hidden[8] - (mem_hidden[8] >>> 2)) + (in_spikes[1] ? -16'sd33 : 16'sd0) + (in_spikes[3] ? 16'sd54 : 16'sd0) + (spk_hidden[1] ? -16'sd92 : 16'sd0) + (spk_hidden[2] ? -16'sd71 : 16'sd0) + (spk_hidden[5] ? -16'sd45 : 16'sd0) + (spk_hidden[6] ? -16'sd82 : 16'sd0) + (spk_hidden[7] ? -16'sd35 : 16'sd0) + (spk_hidden[8] ? -16'sd127 : 16'sd0) + (spk_hidden[9] ? -16'sd99 : 16'sd0) + (spk_hidden[10] ? -16'sd32 : 16'sd0) + (spk_hidden[13] ? -16'sd90 : 16'sd0) + (spk_hidden[14] ? -16'sd93 : 16'sd0) + (spk_hidden[17] ? 16'sd31 : 16'sd0) + (spk_hidden[19] ? -16'sd89 : 16'sd0) + (spk_hidden[21] ? -16'sd31 : 16'sd0) + (spk_hidden[22] ? -16'sd119 : 16'sd0) + (spk_hidden[23] ? -16'sd42 : 16'sd0);
            end
            spk_hidden[8] <= (mem_hidden[8] >= 16'sd87);

            // --- Hidden Neuron 9 (Shift: 2) ---
            if (spk_hidden[9]) mem_hidden[9] <= 16'sd0;
            else begin
                mem_hidden[9] <= (mem_hidden[9] - (mem_hidden[9] >>> 2)) + (in_spikes[3] ? -16'sd45 : 16'sd0) + (spk_hidden[4] ? 16'sd83 : 16'sd0) + (spk_hidden[6] ? -16'sd43 : 16'sd0) + (spk_hidden[8] ? 16'sd50 : 16'sd0) + (spk_hidden[9] ? 16'sd69 : 16'sd0) + (spk_hidden[10] ? 16'sd67 : 16'sd0) + (spk_hidden[11] ? 16'sd37 : 16'sd0) + (spk_hidden[15] ? -16'sd49 : 16'sd0) + (spk_hidden[16] ? 16'sd49 : 16'sd0) + (spk_hidden[22] ? 16'sd43 : 16'sd0);
            end
            spk_hidden[9] <= (mem_hidden[9] >= 16'sd87);

            // --- Hidden Neuron 10 (Shift: 2) ---
            if (spk_hidden[10]) mem_hidden[10] <= 16'sd0;
            else begin
                mem_hidden[10] <= (mem_hidden[10] - (mem_hidden[10] >>> 2)) + (in_spikes[3] ? 16'sd53 : 16'sd0) + (in_spikes[6] ? 16'sd38 : 16'sd0) + (spk_hidden[4] ? -16'sd33 : 16'sd0) + (spk_hidden[6] ? -16'sd110 : 16'sd0) + (spk_hidden[8] ? 16'sd51 : 16'sd0) + (spk_hidden[9] ? 16'sd127 : 16'sd0) + (spk_hidden[12] ? -16'sd78 : 16'sd0) + (spk_hidden[15] ? -16'sd38 : 16'sd0) + (spk_hidden[16] ? 16'sd49 : 16'sd0) + (spk_hidden[17] ? -16'sd109 : 16'sd0) + (spk_hidden[21] ? -16'sd59 : 16'sd0) + (spk_hidden[23] ? -16'sd42 : 16'sd0);
            end
            spk_hidden[10] <= (mem_hidden[10] >= 16'sd87);

            // --- Hidden Neuron 11 (Shift: 2) ---
            if (spk_hidden[11]) mem_hidden[11] <= 16'sd0;
            else begin
                mem_hidden[11] <= (mem_hidden[11] - (mem_hidden[11] >>> 2)) + (spk_hidden[2] ? -16'sd40 : 16'sd0) + (spk_hidden[3] ? -16'sd63 : 16'sd0) + (spk_hidden[6] ? -16'sd80 : 16'sd0) + (spk_hidden[8] ? 16'sd47 : 16'sd0) + (spk_hidden[9] ? -16'sd66 : 16'sd0) + (spk_hidden[12] ? -16'sd56 : 16'sd0) + (spk_hidden[13] ? -16'sd36 : 16'sd0) + (spk_hidden[14] ? -16'sd53 : 16'sd0) + (spk_hidden[15] ? -16'sd49 : 16'sd0) + (spk_hidden[17] ? -16'sd42 : 16'sd0) + (spk_hidden[18] ? -16'sd56 : 16'sd0) + (spk_hidden[19] ? -16'sd67 : 16'sd0) + (spk_hidden[20] ? -16'sd63 : 16'sd0) + (spk_hidden[22] ? -16'sd122 : 16'sd0);
            end
            spk_hidden[11] <= (mem_hidden[11] >= 16'sd87);

            // --- Hidden Neuron 12 (Shift: 2) ---
            if (spk_hidden[12]) mem_hidden[12] <= 16'sd0;
            else begin
                mem_hidden[12] <= (mem_hidden[12] - (mem_hidden[12] >>> 2)) + (spk_hidden[0] ? 16'sd75 : 16'sd0) + (spk_hidden[1] ? 16'sd37 : 16'sd0) + (spk_hidden[4] ? 16'sd106 : 16'sd0) + (spk_hidden[5] ? 16'sd32 : 16'sd0) + (spk_hidden[6] ? 16'sd110 : 16'sd0) + (spk_hidden[7] ? 16'sd54 : 16'sd0) + (spk_hidden[8] ? -16'sd127 : 16'sd0) + (spk_hidden[9] ? -16'sd33 : 16'sd0) + (spk_hidden[10] ? 16'sd77 : 16'sd0) + (spk_hidden[14] ? 16'sd44 : 16'sd0) + (spk_hidden[16] ? 16'sd33 : 16'sd0) + (spk_hidden[18] ? 16'sd36 : 16'sd0) + (spk_hidden[21] ? 16'sd77 : 16'sd0) + (spk_hidden[22] ? -16'sd92 : 16'sd0);
            end
            spk_hidden[12] <= (mem_hidden[12] >= 16'sd87);

            // --- Hidden Neuron 13 (Shift: 2) ---
            if (spk_hidden[13]) mem_hidden[13] <= 16'sd0;
            else begin
                mem_hidden[13] <= (mem_hidden[13] - (mem_hidden[13] >>> 2)) + (in_spikes[0] ? -16'sd127 : 16'sd0) + (in_spikes[1] ? -16'sd127 : 16'sd0) + (in_spikes[3] ? 16'sd43 : 16'sd0) + (in_spikes[6] ? 16'sd45 : 16'sd0) + (spk_hidden[3] ? 16'sd47 : 16'sd0) + (spk_hidden[6] ? -16'sd55 : 16'sd0) + (spk_hidden[9] ? 16'sd72 : 16'sd0) + (spk_hidden[13] ? 16'sd62 : 16'sd0) + (spk_hidden[21] ? -16'sd53 : 16'sd0) + (spk_hidden[22] ? -16'sd89 : 16'sd0) + (spk_hidden[23] ? -16'sd34 : 16'sd0);
            end
            spk_hidden[13] <= (mem_hidden[13] >= 16'sd87);

            // --- Hidden Neuron 14 (Shift: 2) ---
            if (spk_hidden[14]) mem_hidden[14] <= 16'sd0;
            else begin
                mem_hidden[14] <= (mem_hidden[14] - (mem_hidden[14] >>> 2)) + (spk_hidden[1] ? -16'sd69 : 16'sd0) + (spk_hidden[2] ? -16'sd85 : 16'sd0) + (spk_hidden[10] ? 16'sd54 : 16'sd0) + (spk_hidden[13] ? -16'sd43 : 16'sd0) + (spk_hidden[16] ? 16'sd91 : 16'sd0) + (spk_hidden[20] ? -16'sd55 : 16'sd0);
            end
            spk_hidden[14] <= (mem_hidden[14] >= 16'sd87);

            // --- Hidden Neuron 15 (Shift: 2) ---
            if (spk_hidden[15]) mem_hidden[15] <= 16'sd0;
            else begin
                mem_hidden[15] <= (mem_hidden[15] - (mem_hidden[15] >>> 2)) + (in_spikes[1] ? -16'sd127 : 16'sd0) + (in_spikes[6] ? -16'sd58 : 16'sd0) + (spk_hidden[1] ? -16'sd65 : 16'sd0) + (spk_hidden[2] ? -16'sd81 : 16'sd0) + (spk_hidden[4] ? 16'sd51 : 16'sd0) + (spk_hidden[6] ? -16'sd46 : 16'sd0) + (spk_hidden[9] ? -16'sd67 : 16'sd0) + (spk_hidden[10] ? 16'sd36 : 16'sd0) + (spk_hidden[15] ? 16'sd65 : 16'sd0) + (spk_hidden[16] ? 16'sd32 : 16'sd0) + (spk_hidden[17] ? -16'sd127 : 16'sd0) + (spk_hidden[22] ? -16'sd103 : 16'sd0) + (spk_hidden[23] ? -16'sd35 : 16'sd0);
            end
            spk_hidden[15] <= (mem_hidden[15] >= 16'sd87);

            // --- Hidden Neuron 16 (Shift: 2) ---
            if (spk_hidden[16]) mem_hidden[16] <= 16'sd0;
            else begin
                mem_hidden[16] <= (mem_hidden[16] - (mem_hidden[16] >>> 2)) + (in_spikes[3] ? 16'sd61 : 16'sd0) + (spk_hidden[1] ? -16'sd39 : 16'sd0) + (spk_hidden[2] ? -16'sd62 : 16'sd0) + (spk_hidden[6] ? -16'sd55 : 16'sd0) + (spk_hidden[8] ? 16'sd38 : 16'sd0) + (spk_hidden[9] ? 16'sd127 : 16'sd0) + (spk_hidden[12] ? -16'sd88 : 16'sd0) + (spk_hidden[13] ? -16'sd32 : 16'sd0) + (spk_hidden[15] ? -16'sd51 : 16'sd0) + (spk_hidden[17] ? -16'sd67 : 16'sd0) + (spk_hidden[18] ? -16'sd36 : 16'sd0) + (spk_hidden[20] ? -16'sd38 : 16'sd0) + (spk_hidden[21] ? -16'sd46 : 16'sd0) + (spk_hidden[22] ? 16'sd127 : 16'sd0) + (spk_hidden[23] ? -16'sd42 : 16'sd0);
            end
            spk_hidden[16] <= (mem_hidden[16] >= 16'sd87);

            // --- Hidden Neuron 17 (Shift: 2) ---
            if (spk_hidden[17]) mem_hidden[17] <= 16'sd0;
            else begin
                mem_hidden[17] <= (mem_hidden[17] - (mem_hidden[17] >>> 2)) + (in_spikes[1] ? -16'sd32 : 16'sd0) + (in_spikes[2] ? 16'sd74 : 16'sd0) + (in_spikes[3] ? 16'sd54 : 16'sd0) + (in_spikes[6] ? -16'sd127 : 16'sd0) + (spk_hidden[3] ? 16'sd40 : 16'sd0) + (spk_hidden[5] ? -16'sd40 : 16'sd0) + (spk_hidden[9] ? -16'sd34 : 16'sd0) + (spk_hidden[13] ? -16'sd44 : 16'sd0) + (spk_hidden[14] ? 16'sd33 : 16'sd0) + (spk_hidden[17] ? 16'sd101 : 16'sd0) + (spk_hidden[18] ? -16'sd56 : 16'sd0) + (spk_hidden[20] ? -16'sd71 : 16'sd0) + (spk_hidden[22] ? -16'sd60 : 16'sd0) + (spk_hidden[23] ? -16'sd66 : 16'sd0);
            end
            spk_hidden[17] <= (mem_hidden[17] >= 16'sd87);

            // --- Hidden Neuron 18 (Shift: 2) ---
            if (spk_hidden[18]) mem_hidden[18] <= 16'sd0;
            else begin
                mem_hidden[18] <= (mem_hidden[18] - (mem_hidden[18] >>> 2)) + (in_spikes[1] ? 16'sd36 : 16'sd0) + (spk_hidden[0] ? 16'sd43 : 16'sd0) + (spk_hidden[1] ? -16'sd63 : 16'sd0) + (spk_hidden[2] ? -16'sd52 : 16'sd0) + (spk_hidden[4] ? 16'sd52 : 16'sd0) + (spk_hidden[7] ? 16'sd45 : 16'sd0) + (spk_hidden[8] ? 16'sd32 : 16'sd0) + (spk_hidden[10] ? 16'sd77 : 16'sd0) + (spk_hidden[15] ? -16'sd41 : 16'sd0) + (spk_hidden[16] ? 16'sd66 : 16'sd0) + (spk_hidden[17] ? -16'sd127 : 16'sd0) + (spk_hidden[18] ? -16'sd72 : 16'sd0) + (spk_hidden[20] ? -16'sd41 : 16'sd0);
            end
            spk_hidden[18] <= (mem_hidden[18] >= 16'sd87);

            // --- Hidden Neuron 19 (Shift: 2) ---
            if (spk_hidden[19]) mem_hidden[19] <= 16'sd0;
            else begin
                mem_hidden[19] <= (mem_hidden[19] - (mem_hidden[19] >>> 2)) + (spk_hidden[3] ? -16'sd34 : 16'sd0) + (spk_hidden[4] ? 16'sd59 : 16'sd0) + (spk_hidden[7] ? -16'sd32 : 16'sd0) + (spk_hidden[9] ? 16'sd53 : 16'sd0) + (spk_hidden[10] ? 16'sd90 : 16'sd0) + (spk_hidden[11] ? -16'sd54 : 16'sd0) + (spk_hidden[12] ? -16'sd46 : 16'sd0) + (spk_hidden[15] ? -16'sd63 : 16'sd0) + (spk_hidden[16] ? 16'sd68 : 16'sd0) + (spk_hidden[18] ? -16'sd80 : 16'sd0) + (spk_hidden[19] ? -16'sd61 : 16'sd0) + (spk_hidden[20] ? -16'sd87 : 16'sd0);
            end
            spk_hidden[19] <= (mem_hidden[19] >= 16'sd87);

            // --- Hidden Neuron 20 (Shift: 2) ---
            if (spk_hidden[20]) mem_hidden[20] <= 16'sd0;
            else begin
                mem_hidden[20] <= (mem_hidden[20] - (mem_hidden[20] >>> 2)) + (spk_hidden[0] ? 16'sd109 : 16'sd0) + (spk_hidden[2] ? -16'sd88 : 16'sd0) + (spk_hidden[3] ? 16'sd55 : 16'sd0) + (spk_hidden[4] ? 16'sd81 : 16'sd0) + (spk_hidden[5] ? 16'sd42 : 16'sd0) + (spk_hidden[7] ? 16'sd41 : 16'sd0) + (spk_hidden[9] ? 16'sd97 : 16'sd0) + (spk_hidden[10] ? 16'sd102 : 16'sd0) + (spk_hidden[12] ? 16'sd32 : 16'sd0) + (spk_hidden[14] ? 16'sd34 : 16'sd0) + (spk_hidden[15] ? 16'sd60 : 16'sd0) + (spk_hidden[16] ? 16'sd66 : 16'sd0) + (spk_hidden[17] ? -16'sd127 : 16'sd0) + (spk_hidden[19] ? 16'sd31 : 16'sd0) + (spk_hidden[20] ? 16'sd60 : 16'sd0) + (spk_hidden[21] ? 16'sd67 : 16'sd0) + (spk_hidden[22] ? 16'sd98 : 16'sd0);
            end
            spk_hidden[20] <= (mem_hidden[20] >= 16'sd87);

            // --- Hidden Neuron 21 (Shift: 2) ---
            if (spk_hidden[21]) mem_hidden[21] <= 16'sd0;
            else begin
                mem_hidden[21] <= (mem_hidden[21] - (mem_hidden[21] >>> 2)) + (in_spikes[3] ? 16'sd49 : 16'sd0) + (spk_hidden[0] ? 16'sd32 : 16'sd0) + (spk_hidden[10] ? 16'sd48 : 16'sd0) + (spk_hidden[14] ? 16'sd36 : 16'sd0) + (spk_hidden[17] ? -16'sd109 : 16'sd0) + (spk_hidden[21] ? 16'sd39 : 16'sd0) + (spk_hidden[22] ? 16'sd34 : 16'sd0);
            end
            spk_hidden[21] <= (mem_hidden[21] >= 16'sd87);

            // --- Hidden Neuron 22 (Shift: 2) ---
            if (spk_hidden[22]) mem_hidden[22] <= 16'sd0;
            else begin
                mem_hidden[22] <= (mem_hidden[22] - (mem_hidden[22] >>> 2)) + (spk_hidden[3] ? -16'sd51 : 16'sd0) + (spk_hidden[4] ? 16'sd56 : 16'sd0) + (spk_hidden[7] ? 16'sd48 : 16'sd0) + (spk_hidden[9] ? -16'sd99 : 16'sd0) + (spk_hidden[10] ? 16'sd48 : 16'sd0) + (spk_hidden[11] ? -16'sd59 : 16'sd0) + (spk_hidden[12] ? -16'sd60 : 16'sd0) + (spk_hidden[13] ? -16'sd49 : 16'sd0) + (spk_hidden[17] ? -16'sd51 : 16'sd0) + (spk_hidden[18] ? -16'sd59 : 16'sd0) + (spk_hidden[20] ? -16'sd112 : 16'sd0) + (spk_hidden[22] ? -16'sd38 : 16'sd0) + (spk_hidden[23] ? -16'sd54 : 16'sd0);
            end
            spk_hidden[22] <= (mem_hidden[22] >= 16'sd87);

            // --- Hidden Neuron 23 (Shift: 2) ---
            if (spk_hidden[23]) mem_hidden[23] <= 16'sd0;
            else begin
                mem_hidden[23] <= (mem_hidden[23] - (mem_hidden[23] >>> 2)) + (in_spikes[3] ? 16'sd38 : 16'sd0) + (in_spikes[6] ? 16'sd43 : 16'sd0) + (spk_hidden[3] ? 16'sd34 : 16'sd0) + (spk_hidden[6] ? 16'sd62 : 16'sd0) + (spk_hidden[7] ? 16'sd37 : 16'sd0) + (spk_hidden[15] ? -16'sd56 : 16'sd0) + (spk_hidden[17] ? 16'sd34 : 16'sd0) + (spk_hidden[23] ? 16'sd34 : 16'sd0);
            end
            spk_hidden[23] <= (mem_hidden[23] >= 16'sd87);

            // --- Output Neuron 0 (Shift: 2) ---
            if (out_spikes[0]) mem_out[0] <= 16'sd0;
            else begin
                mem_out[0] <= (mem_out[0] - (mem_out[0] >>> 2)) + (spk_hidden[1] ? -16'sd78 : 16'sd0) + (spk_hidden[2] ? -16'sd38 : 16'sd0) + (spk_hidden[4] ? 16'sd35 : 16'sd0) + (spk_hidden[8] ? 16'sd58 : 16'sd0) + (spk_hidden[10] ? 16'sd67 : 16'sd0) + (spk_hidden[11] ? -16'sd85 : 16'sd0) + (spk_hidden[16] ? 16'sd46 : 16'sd0) + (spk_hidden[17] ? -16'sd79 : 16'sd0) + (spk_hidden[21] ? -16'sd42 : 16'sd0);
            end
            out_spikes[0] <= (mem_out[0] >= 16'sd88);

            // --- Output Neuron 1 (Shift: 2) ---
            if (out_spikes[1]) mem_out[1] <= 16'sd0;
            else begin
                mem_out[1] <= (mem_out[1] - (mem_out[1] >>> 2)) + (spk_hidden[1] ? 16'sd35 : 16'sd0) + (spk_hidden[2] ? -16'sd50 : 16'sd0) + (spk_hidden[5] ? 16'sd35 : 16'sd0) + (spk_hidden[8] ? -16'sd42 : 16'sd0) + (spk_hidden[11] ? -16'sd32 : 16'sd0) + (spk_hidden[13] ? -16'sd66 : 16'sd0) + (spk_hidden[14] ? 16'sd48 : 16'sd0) + (spk_hidden[15] ? 16'sd34 : 16'sd0) + (spk_hidden[17] ? -16'sd83 : 16'sd0) + (spk_hidden[18] ? -16'sd42 : 16'sd0) + (spk_hidden[21] ? 16'sd44 : 16'sd0) + (spk_hidden[22] ? 16'sd127 : 16'sd0);
            end
            out_spikes[1] <= (mem_out[1] >= 16'sd88);

            // --- Output Neuron 2 (Shift: 2) ---
            if (out_spikes[2]) mem_out[2] <= 16'sd0;
            else begin
                mem_out[2] <= (mem_out[2] - (mem_out[2] >>> 2)) + (spk_hidden[2] ? -16'sd76 : 16'sd0) + (spk_hidden[6] ? -16'sd31 : 16'sd0) + (spk_hidden[8] ? 16'sd32 : 16'sd0) + (spk_hidden[9] ? 16'sd107 : 16'sd0) + (spk_hidden[11] ? 16'sd51 : 16'sd0) + (spk_hidden[13] ? 16'sd34 : 16'sd0) + (spk_hidden[17] ? -16'sd127 : 16'sd0);
            end
            out_spikes[2] <= (mem_out[2] >= 16'sd88);

            // --- Output Neuron 3 (Shift: 2) ---
            if (out_spikes[3]) mem_out[3] <= 16'sd0;
            else begin
                mem_out[3] <= (mem_out[3] - (mem_out[3] >>> 2)) + (spk_hidden[2] ? -16'sd61 : 16'sd0) + (spk_hidden[6] ? -16'sd33 : 16'sd0) + (spk_hidden[9] ? 16'sd67 : 16'sd0);
            end
            out_spikes[3] <= (mem_out[3] >= 16'sd88);

            // --- Output Neuron 4 (Shift: 2) ---
            if (out_spikes[4]) mem_out[4] <= 16'sd0;
            else begin
                mem_out[4] <= (mem_out[4] - (mem_out[4] >>> 2)) + (spk_hidden[8] ? 16'sd63 : 16'sd0) + (spk_hidden[9] ? 16'sd107 : 16'sd0) + (spk_hidden[11] ? -16'sd46 : 16'sd0) + (spk_hidden[15] ? 16'sd35 : 16'sd0) + (spk_hidden[22] ? 16'sd127 : 16'sd0);
            end
            out_spikes[4] <= (mem_out[4] >= 16'sd88);

        end
    end
endmodule