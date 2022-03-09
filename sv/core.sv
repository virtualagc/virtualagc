`default_nettype none

module Core
  (input logic clock, reset_n,
   input logic [14:0] ROM_read_data, RAM_read_data, IO_read_data,
   output logic [14:0] ROM_write_data, RAM_read_data, IO_write_data,
   output logic [14:0] ROM_address, RAM_read_address, RAM_write_address,
   output logic [2:0] IO_read_sel, IO_write_sel,
   output logic RAM_write_en, stall);


endmodule : Core
