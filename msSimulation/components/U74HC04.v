`timescale 1ns/1ps
`default_nettype none

module U74HC04(a1, y1, a2, y2, a3, y3, gnd, y4, a4, y5, a5, y6, a6, vcc, rst, clk);
    parameter ic1 = 1'b0;
    parameter ic2 = 1'b0;
    parameter ic3 = 1'b0;
    parameter ic4 = 1'b0;
    parameter ic5 = 1'b0;
    parameter ic6 = 1'b0;
    localparam delay = 9;
    input wire vcc, gnd, rst, clk;
    input wire a1, a2, a3, a4, a5, a6;
    output wire y1, y2, y3, y4, y5, y6;

    // Treat loss of power like a reset hold
    wire vrst;
    assign vrst = (rst || !vcc);

    nor_1 #(delay, ic1) A(y1, a1, vrst, clk);
    nor_1 #(delay, ic2) B(y2, a2, vrst, clk);
    nor_1 #(delay, ic3) C(y3, a3, vrst, clk);
    nor_1 #(delay, ic4) D(y4, a4, vrst, clk);
    nor_1 #(delay, ic5) E(y5, a5, vrst, clk);
    nor_1 #(delay, ic6) F(y6, a6, vrst, clk);
endmodule
