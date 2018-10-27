`timescale 1ns/1ps
`default_nettype none

module U74HC244(oe1_n, a11, y24, a12, y23, a13, y22, a14, y21, gnd, a21, y14, a22, y13, a23, y12, a24, y11, oe2_n, vcc, rst, clk);
    localparam delay = 18;
    input wire vcc, gnd, rst, clk;
    input wire a11, a12, a13, a14, a21, a22, a23, a24;
    output wire y11, y12, y13, y14, y21, y22, y23, y24;
    input wire oe1_n, oe2_n;

    tri_buf #(delay) A(y11, a11, oe1_n);
    tri_buf #(delay) B(y12, a12, oe1_n);
    tri_buf #(delay) C(y13, a13, oe1_n);
    tri_buf #(delay) D(y14, a14, oe1_n);
    tri_buf #(delay) E(y21, a21, oe2_n);
    tri_buf #(delay) F(y22, a22, oe2_n);
    tri_buf #(delay) G(y23, a23, oe2_n);
    tri_buf #(delay) H(y24, a24, oe2_n);
endmodule
