parameter DUMPFILE = "moduleA1.lxt2";
parameter RUNLENGTH = 1000000;

reg rst = 1;
initial
  begin
    $dumpfile(DUMPFILE);
    $dumpvars(0, agc);

    # 1 rst = 0;
    # RUNLENGTH $finish;
  end

reg FS01_ = 1;
always #4.8828125 FS01_ = !FS01_;

initial
  $timeformat(-6, 0, " us", 10);
initial
  $monitor("%t: %d %d%d%d%d %d%d%d%d %d%d%d%d %d%d%d%d %d%d%d%d %d%d%d%d %d%d%d%d %d%d%d%d", 
  	$time, FS33, FS32, FS31, FS30, FS29, FS28, FS27, FS26, FS25, FS24, FS23, FS22, FS21, FS20, FS19, FS18, FS17, 
  	FS16, FS15, FS14, FS13, FS12, FS11, FS10, FS09, FS08, FS07, FS06, FS05, FS04, FS03, FS02, FS01_);

