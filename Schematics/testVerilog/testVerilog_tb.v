// Test bench for testVerilog.v
`timescale 1us / 1ns

module testVerilog;

  reg rst = 1;
  initial begin
    $dumpfile("testVerilog.vcd");
    $dumpvars(0, testVerilog);
    
    # 0 rst = 0;
    # 500 $finish;
  end
  
  reg FS01_ = 0;
  always #4.883 FS01_ = !FS01_;
  
  wire F02B;
  wire FS02;
  wire F02A;
  wire FS02A;
  A1 A1A ( 
    rst,
    FS01_,
    F02A,
    F02B,
    FS02,
    FS02A
  );
  
  initial
    $timeformat(-6, 0, " us", 10);
  initial
    $monitor("At time %t, rst=%d, FS01_=%d, F02B=%d, FS02=%d, FS02A=%d, FS02A=%d", $time, rst, FS01_, F02B, FS02, F02A, FS02A);

endmodule
