`timescale 100ns/1ns
`default_nettype none

module RAM (
	E_, W_, G_, UB_, LB_, A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, 
	DQL0, DQL1, DQL2, DQL3, DQL4, DQL5, DQL6, DQL7, DQU8, DQU9, DQU10, DQU11, DQU12, DQU13, DQU14, DQU15
);
    localparam delay = 0.3;

    input wire E_;
    input wire G_;
    input wire W_;
    input wire LB_;
    input wire UB_;

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

    wire [10:0] addr;
    assign addr = {A10, A9, A8, A7, A6, A5, A4, A3, A2, A1, A0};

    wire [15:0] sensed_word;
    wire [15:0] write_word;

    pullup(DQL0);
    pullup(DQL1);
    pullup(DQL2);
    pullup(DQL3);
    pullup(DQL4);
    pullup(DQL5);
    pullup(DQL6);
    pullup(DQL7);
    pullup(DQU8);
    pullup(DQU9);
    pullup(DQU10);
    pullup(DQU11);
    pullup(DQU12);
    pullup(DQU13);
    pullup(DQU14);
    pullup(DQU15);
    
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

    reg [15:0] ram[0:2047];
    assign #delay write_word = {DQU15, DQU14, DQU13, DQU12, DQU11, DQU10, DQU9, DQU8, DQL7, DQL6, DQL5, DQL4, DQL3, DQL2, DQL1, DQL0};
    assign #delay sensed_word = (!E_ && !G_) ? ram[addr] : 16'bZ;

    reg [11:0] i;
    initial begin
        for (i = 0; i < 2048; i = i + 1)
        begin
            ram[i] = 16'o40000;
        end
    end

    always @(E_ or W_ or G_) begin
        if (!E_ && G_ && !W_) begin
            ram[addr] = write_word;
        end else if (!E_ && !G_ && !W_) begin
            $display("ERROR: Write and read on RAM");
            $finish;
        end
    end
    
endmodule
