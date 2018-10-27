`timescale 1ns/1ps
`default_nettype none

module od_buf(y, a);
    parameter delay = 2;
    parameter od_value = 1'b1;
    input wire a;
    output wire y;

`ifdef TARGET_FPGA
    assign y = (od_value == 1'b1) ? a : ~a;
`else
    assign #delay y = (a == od_value) ? 1'bZ : 1'b0;
`endif
endmodule
