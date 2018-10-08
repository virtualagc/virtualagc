// Include-file used by dumbTestbench.py for automating testbench generation.

reg rst = 1;
initial begin
  $dumpfile("testVerilog.vcd");
  $dumpvars(0, testVerilog);
  
  # 2 rst = 0;
  # 500 $finish;
end

reg FS01_ = 0;
always #4.8828125 FS01_ = !FS01_;
  
initial
  $timeformat(-6, 0, " us", 10);
initial
  $monitor("At time %t, rst=%d, FS01_=%d, F02B=%d, FS02=%d, FS02A=%d, FS02A=%d", $time, rst, FS01_, F02B, FS02, F02A, FS02A);
 