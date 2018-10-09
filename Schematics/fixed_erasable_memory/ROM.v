`timescale 100ns/1ns
`default_nettype none

module ROM(
	CE_, OE_, WE_, A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16,
	DQ0, DQ1, DQ2, DQ3, DQ4, DQ5, DQ6, DQ7, DQ8, DQ9, DQ10, DQ11, DQ12, DQ13, DQ14, DQ15
);

    localparam delay = 0.4;

    input wire CE_;
    input wire OE_;
    input wire WE_;

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
    input wire A16;

    output wire DQ0;
    output wire DQ1;
    output wire DQ2;
    output wire DQ3;
    output wire DQ4;
    output wire DQ5;
    output wire DQ6;
    output wire DQ7;
    output wire DQ8;
    output wire DQ9;
    output wire DQ10;
    output wire DQ11;
    output wire DQ12;
    output wire DQ13;
    output wire DQ14;
    output wire DQ15;

    reg [15:0] data;
    pullup(DQ0);
    pullup(DQ1);
    pullup(DQ2);
    pullup(DQ3);
    pullup(DQ4);
    pullup(DQ5);
    pullup(DQ6);
    pullup(DQ7);
    pullup(DQ8);
    pullup(DQ9);
    pullup(DQ10);
    pullup(DQ11);
    pullup(DQ12);
    pullup(DQ13);
    pullup(DQ14);
    pullup(DQ15);
    
    assign DQ0 = data[0];
    assign DQ1 = data[1];
    assign DQ2 = data[2];
    assign DQ3 = data[3];
    assign DQ4 = data[4];
    assign DQ5 = data[5];
    assign DQ6 = data[6];
    assign DQ7 = data[7];
    assign DQ8 = data[8];
    assign DQ9 = data[9];
    assign DQ10 = data[10];
    assign DQ11 = data[11];
    assign DQ12 = data[12];
    assign DQ13 = data[13];
    assign DQ14 = data[14];
    assign DQ15 = data[15];

    wire [16:0] addr;
    assign #delay addr = {A16, A15, A14, A13, A12, A11, A10, A9, A8, A7, A6, A5, A4, A3, A2, A1, A0};

    always @(CE_, OE_, addr)
    begin
        if (!CE_ && !OE_)
        begin
            case (addr)
`include "roms/rom.v"
            default: data = 16'hFFFF;
            endcase
        end
        else
        begin
            data = 16'bZ;
        end
    end

endmodule
