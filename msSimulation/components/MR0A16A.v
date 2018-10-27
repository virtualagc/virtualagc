`timescale 1ns/1ps
`default_nettype none

module MR0A16A (A0, A1, A2, A3, A4, E_n, DQL0, DQL1, DQL2, DQL3, VDD1, VSS1, DQL4, DQL5, DQL6, DQL7, W_n, A5, A6, A7, A8, A9, A10, A11, A12, VSS2, VDD2, DC, DQU8, DQU9, DQU10, DQU11, VDD3, VSS3, DQU12, DQU13, DQU14, DQU15, LB_n, UB_n, G_n, A13, A14, A15, SIM_RST, SIM_CLK
`ifdef TARGET_FPGA
, DQL0_in, DQL1_in, DQL2_in, DQL3_in, DQL4_in, DQL5_in, DQL6_in, DQL7_in, DQU8_in, DQU9_in, DQU10_in, DQU11_in, DQU12_in, DQU13_in, DQU14_in, DQU15_in
`endif
);
    localparam delay = 30;

    input wire SIM_RST;
    input wire SIM_CLK;

    input wire VDD1;
    input wire VDD2;
    input wire VDD3;
    input wire VSS1;
    input wire VSS2;
    input wire VSS3;

    input wire E_n;
    input wire G_n;
    input wire W_n;
    input wire LB_n;
    input wire UB_n;

    input wire A0;
    input wire A1;
    input wire A2;
    input wire A3;
    input wire A4;
    input wire A5;
    input wire A6;
    input wire A7;
    input wire A8;
    input wire A9;
    input wire A10;
    input wire A11;
    input wire A12;
    input wire A13;
    input wire A14;
    input wire A15;

    inout wire DQL0;
    inout wire DQL1;
    inout wire DQL2;
    inout wire DQL3;
    inout wire DQL4;
    inout wire DQL5;
    inout wire DQL6;
    inout wire DQL7;
    inout wire DQU8;
    inout wire DQU9;
    inout wire DQU10;
    inout wire DQU11;
    inout wire DQU12;
    inout wire DQU13;
    inout wire DQU14;
    inout wire DQU15;

    input wire DC;

`ifdef TARGET_FPGA
    input wire DQL0_in;
    input wire DQL1_in;
    input wire DQL2_in;
    input wire DQL3_in;
    input wire DQL4_in;
    input wire DQL5_in;
    input wire DQL6_in;
    input wire DQL7_in;
    input wire DQU8_in;
    input wire DQU9_in;
    input wire DQU10_in;
    input wire DQU11_in;
    input wire DQU12_in;
    input wire DQU13_in;
    input wire DQU14_in;
    input wire DQU15_in;
`endif

    wire [10:0] addr;
    assign addr = {A10, A9, A8, A7, A6, A5, A4, A3, A2, A1, A0};

    wire [15:0] sensed_word;
    wire [15:0] write_word;

    assign DQL0 = sensed_word[0];
    assign DQL1 = sensed_word[1];
    assign DQL2 = sensed_word[2];
    assign DQL3 = sensed_word[3];
    assign DQL4 = sensed_word[4];
    assign DQL5 = sensed_word[5];
    assign DQL6 = sensed_word[6];
    assign DQL7 = sensed_word[7];
    assign DQU8 = sensed_word[8];
    assign DQU9 = sensed_word[9];
    assign DQU10 = sensed_word[10];
    assign DQU11 = sensed_word[11];
    assign DQU12 = sensed_word[12];
    assign DQU13 = sensed_word[13];
    assign DQU14 = sensed_word[14];
    assign DQU15 = sensed_word[15];

`ifdef TARGET_FPGA
	wire wren;
	assign wren = !W_n;
	wire [15:0] read_word;
	assign sensed_word = (!E_n && !G_n) ? read_word : 16'b0;
	assign write_word = {DQU15_in, DQU14_in, DQU13_in, DQU12_in, DQU11_in, DQU10_in, DQU9_in, DQU8_in, DQL7_in, DQL6_in, DQL5_in, DQL4_in, DQL3_in, DQL2_in, DQL1_in, DQL0_in};
    
	core_memory ram(addr, SIM_CLK, write_word, wren, read_word);
`else
    reg [15:0] ram[0:2047];
    assign #delay write_word = {DQU15, DQU14, DQU13, DQU12, DQU11, DQU10, DQU9, DQU8, DQL7, DQL6, DQL5, DQL4, DQL3, DQL2, DQL1, DQL0};
    assign #delay sensed_word = (!E_n && !G_n) ? ram[addr] : 16'bZ;

    reg [11:0] i;
    initial begin
        for (i = 0; i < 2048; i = i + 1)
        begin
            ram[i] = 16'o40000;
        end
    end

    always @(E_n or W_n or G_n) begin
        if (!E_n && G_n && !W_n) begin
            ram[addr] = write_word;
        end else if (!E_n && !G_n && !W_n) begin
            $display("ERROR: Write and read on MRAM");
            $finish;
        end
    end
`endif
endmodule
