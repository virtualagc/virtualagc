// Verilog testbench created by dumbTestbench.py
`timescale 100ns / 1ns

module testVerilog;

`include "testVerilog/tb.v"

wire F02A, F02B, FS02, FS02A;

A1 iA1 (
  rst, FS01_, F02A, F02B, FS02, FS02A
);

endmodule
