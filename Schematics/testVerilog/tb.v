// Include-file used by module_tb.py for automating testbench generation.

reg rst = 1;
initial begin
  // Assumes compilation with -fst switch.
  $dumpfile("module.fst");
  $dumpvars(0, agc);
  
  # 2000 rst = 0;
  # 500000 $finish;
end

reg FS01_ = 0;
always #4882.8125 FS01_ = !FS01_;
  
initial
  $timeformat(-6, 0, " us", 10);
initial
  $monitor("At time %t, rst=%d, FS01_=%d, F02B=%d, FS02=%d, FS02A=%d, FS02A=%d", $time, rst, FS01_, F02B, FS02, F02A, FS02A);
 