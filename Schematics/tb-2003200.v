// For use by dumbTestbench.py in autogenerating an AGC testbench.

parameter DUMPFILE = "agc.lxt2";

// In units of 0.1 us.
parameter RUNLENGTH = 2500000; // 0.25 seconds

reg rst = 1;
initial
  begin
    $dumpfile(DUMPFILE);
`ifdef DUMP_ALL    
    // Dump all of the signals, including those local to individual modules.
    $dumpvars(0,agc);
    $display("Dumping all signals.");
`endif
`ifdef DUMP_BACKPLANE
    // Dump just the backplane signals; this makes the file considerably shorter.
    $dumpvars(1, agc);
    $display("Dumping backplane signals.");
`endif
`ifdef DUMP_DECODER
    // Or, use just the list of variables needed by the instruction decoder.
    $dumpvars(1, agc.MINC, agc.DINC, agc.PINC, agc.INKL, agc.T07, agc.T01, agc.TSUDO_, 
    	agc.G16, agc.G15, agc.G14, agc.G13, agc.G12, agc.G11, agc.G10, agc.G09, agc.G08, 
    	agc.G07, agc.G06, agc.G05, agc.G04, agc.G03, agc.G02, agc.G01, agc.FUTEXT, agc.IC2, 
    	agc.STG3, agc.STG2, agc.STG1, agc.WSQG_, agc.GOJAM, agc.RPTFRC, agc.PCDU, agc.MCDU, 
    	agc.SHINC, agc.SHANC);
    $display("Dumping instruction-decoder signals.");
`endif
`ifdef DUMP_HELPFUL
    // Or, use the list of variables needed by the instruction decoder, plus a few
    // useful things: A, L, Z, S, EB, FB registers.
    $dumpvars(1, agc.MINC, agc.DINC, agc.PINC, agc.INKL, agc.T07, agc.T01, agc.TSUDO_, 
    	agc.G16, agc.G15, agc.G14, agc.G13, agc.G12, agc.G11, agc.G10, agc.G09, agc.G08, 
    	agc.G07, agc.G06, agc.G05, agc.G04, agc.G03, agc.G02, agc.G01, agc.FUTEXT, agc.IC2, 
    	agc.STG3, agc.STG2, agc.STG1, agc.WSQG_, agc.GOJAM, agc.RPTFRC, agc.PCDU, agc.MCDU, 
    	agc.SHINC, agc.SHANC, agc.S12, agc.S11, agc.S10, agc.S09, 
    	agc.S08, agc.S07, agc.S06, agc.S05, agc.S04, agc.S03, agc.S02, agc.S01,
    	agc.Z16_, agc.Z15_, agc.Z14_, agc.Z13_, agc.Z12_, agc.Z11_, agc.Z10_, agc.Z09_, 
    	agc.Z08_, agc.Z07_, agc.Z06_, agc.Z05_, agc.Z04_, agc.Z03_, agc.Z02_, agc.Z01_,
    	agc.A16_, agc.A15_, agc.A14_, agc.A13_, agc.A12_, agc.A11_, agc.A10_, agc.A09_, 
    	agc.A08_, agc.A07_, agc.A06_, agc.A05_, agc.A04_, agc.A03_, agc.A02_, agc.A01_,
    	agc.FB16, agc.FB14, agc.FB13, agc.FB12, agc.FB11, agc.EB9, agc.EB10, agc.EB11,
    	agc.L16_, agc.L15_, agc.L14_, agc.L13_, agc.L12_, agc.L11_, agc.L10_, agc.L09_, agc.L08_, 
    	agc.L07_, agc.L06_, agc.L05_, agc.L04_, agc.L03_, agc.L02_, agc.L01_
    );
    $display("Dumping helpful signals.");
`endif
    $display("Run length will be %f ms.", RUNLENGTH/10000);
    # 50 rst = 0;
    //# 10000000000 $finish; // 100 seconds
    //# 600000000 $finish; // 60 seconds ... should be enough time for Validation to run.
    //# 100000000 $finish; // 10 seconds
    //# 10000000 $finish; // 1 second
    //# 2500000 $finish; // 0.25 second
    //# 100000 $finish; // 10 ms.
    //# 10000 $finish; // 1 ms.
    # RUNLENGTH $finish;
  end

reg CLOCK = 0;
always #2.44140625 CLOCK = !CLOCK;

// Turn off parity checking.
//reg NHALGA = 1;

initial $timeformat(-3, 0, " ms", 10);
always #10000 $display("%t", $time);

