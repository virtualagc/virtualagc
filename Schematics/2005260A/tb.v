// Custom stuff for inclusion in auto-generated testbenches.
// Edit this file, not module_tb.v.

parameter DUMPFILE = "moduleA2.lxt2";
parameter RUNLENGTH = 1000;

reg rst = 1;
reg STRT2 = 1;
initial
  begin
    $dumpfile(DUMPFILE);
    $dumpvars(0, agc);
    # 1 rst = 0;
    # 50 STRT2 = 0;
    # RUNLENGTH $finish;
  end

reg CLOCK = 0;
always #2.44140625 CLOCK = !CLOCK;

initial $timeformat(-9, 0, " ns", 10);
initial $monitor("%t: %d", $time, CLOCK);

