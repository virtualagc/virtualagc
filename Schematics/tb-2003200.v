// For use by dumbTestbench.py in autogenerating an AGC testbench.

reg rst = 1;
initial
  begin
    $dumpfile("agc.lxt2");
    $dumpvars(0, agc);
    # 50 rst = 0;
    # 200000 $finish;
  end

reg CLOCK = 0;
always #2.44140625 CLOCK = !CLOCK;

//reg NHALGA = 1;

initial $timeformat(-9, 0, " ns", 10);
initial $monitor("%t: %d", $time, CLOCK);

