
module TB;
  logic clock, reset_n, finish;

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
  logic [14:0] ROM_pc_address, ROM_constant_address, RAM_read_address, RAM_write_address;
  logic [2:0] IO_read_sel, IO_write_sel;
  logic RAM_write_en, stall, halt;

  agc_ram ram(.aclr(~reset_n), .clock, .data(RAM_write_data), .rd_addressstall(stall), .wraddress, .wren, .q(RAM_read_data));
  IO_unit io(.clock, .reset_n, .IO_read_sel, .IO_write_data, .IO_read_data, .IO_write_en, .IO_write_sel); 
  Core core(.clock, .reset_n, .ROM_pc_data, .ROM_constant_data, .RAM_read_data, .IO_read_data, .RAM_write_data, 
            .IO_write_data, .ROM_pc_address, .ROM_constant_address, .RAM_read_address, .RAM_write_address,
            .IO_read_sel, .IO_write_sel, .RAM_write_en, .stall, .halt);




  initial begin
    wait(halt);
    #finish;
  end
  

  initial begin
    #100000
    $finish;
  end
endmodule : TB
