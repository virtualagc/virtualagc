// For use by dumbTestbench.py in autogenerating an AGC testbench.

parameter DUMPFILE = "agc.lxt2";

// In units of ns.
parameter RUNLENGTH = 250000000; // 0.25 seconds

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
    	agc.SHINC, agc.SHANC, agc.S12, agc.S11, agc.S10, agc.S09, 
    	agc.S08, agc.S07, agc.S06, agc.S05, agc.S04, agc.S03, agc.S02, agc.S01);
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
    	agc.L07_, agc.L06_, agc.L05_, agc.L04_, agc.L03_, agc.L02_, agc.L01_,
    	agc.SA16, agc.SAP, agc.SA14, agc.SA13, agc.SA12, agc.SA11, agc.SA10, agc.SA09, agc.SA08, 
    	agc.SA07, agc.SA06, agc.SA05, agc.SA04, agc.SA03, agc.SA02, agc.SA01
    );
    $display("Dumping helpful signals.");
`endif
    $display("Run length will be %f ms.", RUNLENGTH/1000000.0);
    # 5000 rst = 0;
    //# 1000000000000 $finish; // 100 seconds
    //# 60000000000 $finish; // 60 seconds ... should be enough time for Validation to run.
    //# 10000000000 $finish; // 10 seconds
    //# 1000000000 $finish; // 1 second
    //# 250000000 $finish; // 0.25 second
    //# 10000000 $finish; // 10 ms.
    //# 1000000 $finish; // 1 ms.
    # RUNLENGTH $finish;
  end

reg CLOCK = 0;
always #244.140625 CLOCK = !CLOCK;

// If not commented, turn off parity checking.
//reg NHALGA = 1;

initial $timeformat(-3, 0, " ms", 10);
always #1000000 $display("%t", $time);

///////////////////////////////////////////////////////////////////////////////////////////
// The following stuff was pasted as-is from Mike's testbench.  It pertains to signals from
// the spacecraft that are being fed into the AGC, and isn't necessary for basic operation
// of the computer as a computer.  The Validation AGC program passes without it.  However,
// I'm putting it in as a possible aid to comparing the results of this sim to Mike's sim.
// If/when more of the spacecraft is simulated, it probably won't be usable.

`ifdef SPOOF_SC

    // PIPA spoofing -- simulate 3-3 moding on PIPA inputs, synced with PIPDAT
    // and counting on PIPASW
    reg [2:0] moding_counter = 3'b0;
    always @(posedge PIPASW) begin
        moding_counter = moding_counter + 3'b1;
        if (moding_counter == 3'd6) begin
            moding_counter = 3'b0;
        end
    end

    assign PIPAXm = PIPDAT && (moding_counter >= 3'd3);
    assign PIPAYm = PIPDAT && (moding_counter >= 3'd3);
    assign PIPAZm = PIPDAT && (moding_counter >= 3'd3);
    assign PIPAXp = PIPDAT && (moding_counter < 3'd3);
    assign PIPAYp = PIPDAT && (moding_counter < 3'd3);
    assign PIPAZp = PIPDAT && (moding_counter < 3'd3);

    // PCM simulation
    reg [4:0] pcm_counter = 5'd19;
    reg dlk_clk = 1'b0;
    reg [9:0] dlk_counter = 10'd1023;
    always @(posedge CLK) begin
        if (pcm_counter == 5'd20) begin
            pcm_counter <= 5'b0;
        end else begin
            pcm_counter <= pcm_counter + 5'b1;
            if (pcm_counter == 5'd0) begin
                dlk_clk <= 1'b1;
                dlk_counter <= dlk_counter + 10'b1;
            end else if (pcm_counter == 5'd4) begin
                dlk_clk <= 1'b0;
            end
        end
    end

    assign DKSTRT = dlk_clk && (dlk_counter == 10'd0);
    assign DKBSNC = dlk_clk && (dlk_counter > 10'd0) && (dlk_counter < 10'd41);
    assign DKEND = dlk_clk && (dlk_counter == 10'd41);

`else

reg DKBSNC = 0, DKEND = 0, DKST = 0, PIPAXm = 0, PIPAXp = 0, 
	PIPAYm = 0, PIPAYp = 0, PIPAZm = 0, PIPAZp = 0;

`endif

///////////////////////////////////////////////////////////////////////////////////////////
