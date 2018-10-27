`timescale 1ns/1ps
`default_nettype none

module U74HC27(a1, b1, a2, b2, c2, y2, gnd, y3, a3, b3, c3, y1, c1, vcc, rst, clk);
    parameter ic1 = 1'b0;
    parameter ic2 = 1'b0;
    parameter ic3 = 1'b0;
    localparam delay = 9;
    input wire vcc, gnd, rst, clk;
    input wire a1, b1, c1, a2, b2, c2, a3, b3, c3;
    output wire y1, y2, y3;

    // Treat loss of power like a reset hold
    wire vrst;
    assign vrst = (rst || !vcc);

    nor_3 #(delay, ic1) A(y1, a1, b1, c1, vrst, clk);
    nor_3 #(delay, ic2) B(y2, a2, b2, c2, vrst, clk);
    nor_3 #(delay, ic3) C(y3, a3, b3, c3, vrst, clk);
endmodule
