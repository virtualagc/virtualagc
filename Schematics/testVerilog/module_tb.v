// Verilog testbench created by dumbTestbench.py
`timescale 1ns / 1ps

module agc;

parameter GATE_DELAY = 20;
`include "testVerilog/tb.v"

wire F02A, F02B, FS02, FS02A;

A1 iA1 (
  rst, FS01_, F02A, F02B, FS02, FS02A
);
defparam iA1.GATE_DELAY = GATE_DELAY;

endmodule
