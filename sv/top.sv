
`default_nettype none

`include "internal_defines.vh"
`include "core.sv"
`include "agc_rom_new/agc_rom_new.v"
`include "agc_ram/agc_ram.v"
`include "lib.sv"
`include "comp_units.sv"
`include "decode.sv"


module TB;
  logic clock, reset_n;

  initial begin
    clock = 1'b0;
    reset_n = 1'b1;
    reset_n <= #1 1'b1;
    forever #5 clock = ~clock;
  end

  //TODO instantiate ROM, and IO
  //data is input data

  logic [14:0] ROM_pc_data, ROM_constant_data, RAM_read_data, IO_read_data;
  logic [14:0] RAM_write_data, IO_write_data;
  logic [13:0] ROM_pc_address, ROM_constant_address; 
  logic [10:0]RAM_read_address, RAM_write_address;
  logic [2:0] IO_read_sel, IO_write_sel;
  logic RAM_write_en, stall, halt, IO_write_en;

  agc_rom_new rom(.aclr(~reset_n), .address_a(ROM_pc_address), .address_b(ROM_constant_address), .clock, .addressstall_a(stall), .addressstall_b(stall), .q_a(ROM_pc_data), .q_b(ROM_constant_data));
  agc_ram ram(.aclr(~reset_n), .clock, .data(RAM_write_data), .rd_addressstall(stall), .wraddress(RAM_write_address), .wren(RAM_write_en), .q(RAM_read_data), .rdaddress(RAM_read_address), .rden(1'b1));
  //IO_unit io(.clock, .reset_n, .IO_read_sel, .IO_write_data, .IO_read_data, .IO_write_en, .IO_write_sel); 
  Core core(.clock, .reset_n, .ROM_pc_data, .ROM_constant_data, .RAM_read_data, .IO_read_data, .RAM_write_data, 
            .IO_write_data, .ROM_pc_address, .ROM_constant_address, .RAM_read_address, .RAM_write_address,
            .IO_read_sel, .IO_write_sel, .RAM_write_en, .stall, .halt, .IO_write_en);




  initial begin
    wait(halt);
    $finish;
  end
  

  initial begin
    #1000
    $finish;
  end
endmodule : TB
