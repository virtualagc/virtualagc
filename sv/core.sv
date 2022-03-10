`default_nettype none

`include "internal_defines.vh"
module Core
  (input logic clock, reset_n,
   input logic [14:0] ROM_read_data, RAM_read_data, IO_read_data,
   output logic [14:0] ROM_write_data, RAM_read_data, IO_write_data,
   output logic [14:0] ROM_address, RAM_read_address, RAM_write_address,
   output logic [2:0] IO_read_sel, IO_write_sel,
   output logic RAM_write_en, stall);

  /////////////////////////FETCH STAGE///////////////////////////////
  logic stall_D;
  logic [14:0] pc_F, pc_1_F, next_pc_F;


  adder #($bits(pc_F)) Next_PC_Adder(.A(pc_E), .B('d1), .cin(1'b0),
            .sum(pc_1_F), .cout());


  register #($bits(pc_F), USER_TEXT_START) PC_Register(.clk, .rst_l,
            .en(~stall_D), .clear(1'b0), .D(next_pc_F),
            .Q(pc_F));

  mux #(2, $bits(pc_F)) PC_Mux(.in({pc_E, pc_1_F}),
            .sel(branch_E),
            .out(next_pc_F));

  assign ROM_read_address = pc_F;

  /////////////////////////DECODE STAGE///////////////////////////

endmodule : Core
