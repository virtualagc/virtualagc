`timescale 1ns/1ps
`default_nettype none

module nor_1(y, a, rst, clk);
    parameter delay = 9;
    parameter iv = 1'b0;
    input wire a, rst, clk;

`ifdef TARGET_FPGA
    output reg y = iv;
    reg next_val = iv;

    always @(posedge clk)
    begin
        y = next_val;
    end

    always @(negedge clk)
    begin
        next_val = ~a;
    end
`else
    output wire y;
    assign #delay y = (rst) ? iv : ~a;
`endif
endmodule
