module TB;
  logic clock, reset_n;

  initial begin
    clock = 1'b0;
    reset_n = 1'b1;
    reset_n <= 1'b0;
    resetN <= #1 1'b1;
    forever #5 clock = ~clock;
  end

  //TODO instantiate ROM, RAM, core and IO

  

  initial begin
    #100000
    $display("time = %d, ans = %h, state %s" , dut.count, dut.finalSum, dut.s1.f1.state);
    $display("@%0t: Error timeout!", $time);
    $finish;
  end
endmodule : TB
