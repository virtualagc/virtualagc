`timescale 1ns/1ps
`default_nettype none

module BUFFER(OEa_, OEb_, I0a, I1a, I2a, I3a, I0b, I1b, I2b, I3b, O0a, O1a, O2a, O3a, O0b, O1b, O2b, O3b);

    localparam delay = 20;
    input wire OEa_, I0a, I1a, I2a, I3a;
    input wire OEb_, I0b, I1b, I2b, I3b;
    output wire O0a, O1a, O2a, O3a;
    output wire O0b, O1b, O2b, O3b;
    
    assign #delay O0a = (OEa_ == 1'b0) ? I0a : 1'bz;
    assign #delay O1a = (OEa_ == 1'b0) ? I1a : 1'bz;
    assign #delay O2a = (OEa_ == 1'b0) ? I2a : 1'bz;
    assign #delay O3a = (OEa_ == 1'b0) ? I3a : 1'bz;
    
    assign #delay O0b = (OEb_ == 1'b0) ? I0b : 1'bz;
    assign #delay O1b = (OEb_ == 1'b0) ? I1b : 1'bz;
    assign #delay O2b = (OEb_ == 1'b0) ? I2b : 1'bz;
    assign #delay O3b = (OEb_ == 1'b0) ? I3b : 1'bz;
    
endmodule
