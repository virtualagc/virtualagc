`timescale 1ns/1ps
`default_nettype none

module U74LVC06(a1, y1, a2, y2, a3, y3, gnd, y4, a4, y5, a5, y6, a6, vcc, rst, clk);
    localparam delay = 2;
    localparam od_value = 1'b0;
    input wire vcc, gnd, rst, clk;
    input wire a1, a2, a3, a4, a5, a6;
    output wire y1, y2, y3, y4, y5, y6;

    od_buf #(delay, od_value) A(y1, a1);
    od_buf #(delay, od_value) B(y2, a2);
    od_buf #(delay, od_value) C(y3, a3);
    od_buf #(delay, od_value) D(y4, a4);
    od_buf #(delay, od_value) E(y5, a5);
    od_buf #(delay, od_value) F(y6, a6);
endmodule
