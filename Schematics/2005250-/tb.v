// Custom stuff for inclusion in auto-generated testbenches.
// Edit this file, not module_tb.v.

reg rst = 1;
reg STRT2 = 1;
initial
  begin
    $dumpfile("module.lxt2");
    $dumpvars(0, agc);
    # 100 rst = 0;
    # 5000 STRT2 = 0;
    # 100000 $finish;
  end

reg CLOCK = 0;
always #244.140625 CLOCK = !CLOCK;

initial $timeformat(-9, 0, " ns", 10);
initial $monitor("%t: %d", $time, CLOCK);

