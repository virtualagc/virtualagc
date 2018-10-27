`timescale 1ns/1ps
`default_nettype none

module nor_2(y, a, b, rst, clk);
    parameter delay = 9;
    parameter iv = 1'b0;
    input wire a, b, rst, clk;

`ifdef TARGET_FPGA
    output reg y = iv;
    reg next_val = iv;
    reg prev_val = iv;
    wire result;
    
    assign result = ~(a|b);

    always @(posedge clk)
    begin
        prev_val = y;
        y = next_val;
    end

    always @(negedge clk)
    begin
        next_val = ((result == prev_val) && (y == iv)) ? iv : result;
    end
`else
    output wire y;
    assign #delay y = (rst) ? iv : ~(a|b);
`endif
endmodule
