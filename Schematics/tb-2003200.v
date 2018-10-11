// For use by dumbTestbench.py in autogenerating an AGC testbench.

reg rst = 1;
initial
  begin
    $dumpfile("agc-short.lxt");
    // Use 0 to get all of the signals, including those local to individual modules.
    // Use 1 to get just the backplane signals; this makes the file considerably
    // shorter.
    $dumpvars(1, agc);
    # 50 rst = 0;
    //# 10000000 $finish;
    # 10000000 $finish;
  end

reg CLOCK = 0;
always #2.44140625 CLOCK = !CLOCK;

//reg NHALGA = 1;

initial $timeformat(-3, 0, " ms", 10);
always #10000 $display("%t", $time);

