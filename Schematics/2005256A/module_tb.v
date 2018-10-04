// Verilog testbench created by dumbTestbench.py
`timescale 100ns / 1ns

module agc;

reg rst = 1;
reg STRT2 = 1;
initial
  begin
    $dumpfile("agc.lxt2");
    $dumpvars(0, agc);
    # 1 rst = 0;
    # 50 STRT2 = 0;
    # 1000 $finish;
  end

reg CLOCK = 0;
always #2.44140625 CLOCK = !CLOCK;

reg A2XG_ = 0, CAG = 0, CBG = 0, CGA9 = 0, CGG = 0, CH05 = 0, CH06 = 0,
  CH07 = 0, CH08 = 0, CI05_ = 0, CLG1G = 0, CLXC = 0, CO06 = 0, CQG = 0,
  CUG = 0, CZG = 0, G07ED = 0, G09_ = 0, G10_ = 0, G11_ = 0, G2LSG_ = 0,
  L04_ = 0, L2GDG_ = 0, MDT05 = 0, MDT06 = 0, MDT07 = 0, MDT08 = 0, MONEX = 0,
  PIPAXm_ = 0, PIPAXp_ = 0, PIPAYp_ = 0, PIPSAM = 0, R1C = 0, RAG_ = 0,
  RBLG_ = 0, RCG_ = 0, RGG_ = 0, RL16_ = 0, RLG_ = 0, RQG_ = 0, RULOG_ = 0,
  RZG_ = 0, SA05 = 0, SA06 = 0, SA07 = 0, SA08 = 0, WAG_ = 0, WALSG_ = 0,
  WBG_ = 0, WG1G_ = 0, WG3G_ = 0, WG4G_ = 0, WL04_ = 0, WL09_ = 0, WL10_ = 0,
  WLG_ = 0, WQG_ = 0, WYDG_ = 0, WYLOG_ = 0, WZG_ = 0, XUY09_ = 0, XUY10_ = 0,
  p4SW = 0;

wire A05_, A06_, A07_, A08_, CI06_, CI07_, CI08_, CI09_, CLROPE, CO08,
  CO10, G05, G05_, G06, G06_, G07, G07_, G08, G08_, GEM05, GEM06, GEM07,
  GEM08, L05_, L06_, L07_, L08_, MWL05, MWL06, MWL07, MWL08, PIPGXm, PIPGXp,
  PIPGYp, PIPSAM_, RL05_, RL06_, RL07_, RL08_, ROPER, ROPES, ROPET, SUMA05_,
  SUMA06_, SUMA07_, SUMA08_, SUMB05_, SUMB06_, SUMB07_, SUMB08_, WL05,
  WL05_, WL06, WL06_, WL07, WL07_, WL08, WL08_, WL16, XUY05_, XUY06_, XUY07_,
  XUY08_, Z05_, Z06_, Z07_, Z08_;

A9 iA9 (
  rst, A2XG_, CAG, CBG, CGA9, CGG, CH05, CH06, CH07, CH08, CI05_, CLG1G,
  CLXC, CO06, CQG, CUG, CZG, G07ED, G09_, G10_, G11_, G2LSG_, L04_, L2GDG_,
  MDT05, MDT06, MDT07, MDT08, MONEX, PIPAXm_, PIPAXp_, PIPAYp_, PIPSAM, R1C,
  RAG_, RBLG_, RCG_, RGG_, RL16_, RLG_, RQG_, RULOG_, RZG_, SA05, SA06, SA07,
  SA08, STRT2, WAG_, WALSG_, WBG_, WG1G_, WG3G_, WG4G_, WL04_, WL09_, WL10_,
  WLG_, WQG_, WYDG_, WYLOG_, WZG_, XUY09_, XUY10_, p4SW, CI06_, CI07_, CI08_,
  CLROPE, CO08, CO10, G05_, G06_, G07_, G08_, GEM05, GEM06, GEM07, GEM08,
  L05_, L06_, L07_, MWL05, MWL06, MWL07, MWL08, PIPSAM_, RL05_, RL06_, ROPER,
  ROPES, ROPET, SUMA07_, WL05_, WL06_, WL07_, WL08_, WL16, XUY07_, XUY08_,
  A05_, A06_, A07_, A08_, CI09_, G05, G06, G07, G08, L08_, PIPGXm, PIPGXp,
  PIPGYp, RL07_, RL08_, SUMA05_, SUMA06_, SUMA08_, SUMB05_, SUMB06_, SUMB07_,
  SUMB08_, WL05, WL06, WL07, WL08, XUY05_, XUY06_, Z05_, Z06_, Z07_, Z08_
);

initial $timeformat(-9, 0, " ns", 10);
initial $monitor("%t: %d", $time, CLOCK);

endmodule
