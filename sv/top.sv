module TB;
  logic clock, reset_n;

  initial begin
    clock = 1'b0;
    reset_n = 1'b1;
    reset_n <= 1'b0;
    resetN <= #1 1'b1;
    forever #5 clock = ~clock;
  end

  //TODO instantiate ROM, and IO
  //data is input data

  logic clock, reset_n,
  logic [14:0] ROM_pc_data, ROM_constant_data, RAM_read_data, IO_read_data;
  logic [14:0] RAM_write_data, IO_write_data;
  logic [14:0] ROM_pc_address, ROM_constant_address, RAM_read_address, RAM_write_address;
  logic [2:0] IO_read_sel, IO_write_sel;
  logic RAM_write_en, stall, halt;

  agc_ram ram(.aclr(~reset_n), .clock, .data(RAM_write_data), .rd_addressstall(stall), .wraddress, .wren, .q(RAM_read_data));
  
  Core core(.clock, .reset_n, .ROM_pc_data, .ROM_constant_data, .RAM_read_data, .IO_read_data, .RAM_write_data, 
            .IO_write_data, .ROM_pc_address, .ROM_constant_address, .RAM_read_address, .RAM_write_address,
            .IO_read_sel, .IO_write_sel, .RAM_write_en, .stall, .halt);




  initial begin
    wait(halt);
    #finish;
  end
  

  initial begin
    #100000
    $display("time = %d, ans = %h, state %s" , dut.count, dut.finalSum, dut.s1.f1.state);
    $display("@%0t: Error timeout!", $time);
    $finish;
  end
endmodule : TB
