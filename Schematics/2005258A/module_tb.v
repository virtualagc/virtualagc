// Verilog testbench created by dumbTestbench.py
`timescale 100ns / 1ns

module agc;

reg rst = 1;
initial
  begin
    $dumpfile("agc.lxt2");
    $dumpvars(0, agc);
    # 1 rst = 0;
    # 1000 $finish;
  end

reg CLOCK = 0;
always #4.8828125 CLOCK = !CLOCK;

reg A2XG_ = 0, BXVX = 0, CAG = 0, CBG = 0, CGA11 = 0, CGG = 0, CH13 = 0,
  CH14 = 0, CH16 = 0, CI13_ = 0, CLG1G = 0, CLG2G = 0, CLXC = 0, CO14 = 0,
  CQG = 0, CUG = 0, CZG = 0, DVXP1 = 0, G01_ = 0, G16SW_ = 0, G2LSG_ = 0,
  GOJAM = 0, GTRST = 0, L12_ = 0, L2GDG_ = 0, MDT13 = 0, MDT14 = 0, MDT15 = 0,
  MDT16 = 0, MONEX = 0, NISQ = 0, ONE = 0, PIPAYm = 0, PIPAZm = 0, PIPAZp = 0,
  R1C = 0, RAG_ = 0, RBHG_ = 0, RCG_ = 0, RGG_ = 0, RLG_ = 0, RQG_ = 0,
  RUG_ = 0, RULOG_ = 0, RZG_ = 0, SA13 = 0, SA14 = 0, SA16 = 0, US2SG = 0,
  WAG_ = 0, WALSG_ = 0, WBG_ = 0, WG1G_ = 0, WG2G_ = 0, WG3G_ = 0, WG4G_ = 0,
  WG5G_ = 0, WHOMPA = 0, WL01_ = 0, WL02_ = 0, WL12_ = 0, WLG_ = 0, WQG_ = 0,
  WYDG_ = 0, WYHIG_ = 0, WZG_ = 0, XUY01_ = 0, XUY02_ = 0;

wire A13_, A14_, A15_, A16_, CI14_, CI15_, CI16_, CO02, CO16, EAC_, G13,
  G13_, G14, G14_, G15, G15_, G16, G16_, GEM13, GEM14, GEM16, GTRST_, L13_,
  L14_, L15_, L16_, MWL13, MWL14, MWL15, MWL16, PIPAYm_, PIPAZm_, PIPAZp_,
  RL13_, RL14_, RL15_, RL16, RL16_, SUMA02_, SUMA04_, SUMA07_, SUMA12_,
  SUMA13_, SUMA14_, SUMA15_, SUMA16_, SUMB13_, SUMB14_, SUMB15_, SUMB16_,
  WHOMP, WHOMP_, WL13, WL13_, WL14, WL14_, WL15, WL15_, WL16, WL16_, XUY13_,
  XUY14_, XUY15_, XUY16_, Z13_, Z14_, Z15_, Z16_;

A11 iA11 (
  rst, A2XG_, BXVX, CAG, CBG, CGA11, CGG, CH13, CH14, CH16, CI13_, CLG1G,
  CLG2G, CLXC, CO14, CQG, CUG, CZG, DVXP1, G01_, G16SW_, G2LSG_, GOJAM, GTRST,
  L12_, L2GDG_, MDT13, MDT14, MDT15, MDT16, MONEX, NISQ, ONE, PIPAYm, PIPAZm,
  PIPAZp, R1C, RAG_, RBHG_, RCG_, RGG_, RLG_, RQG_, RUG_, RULOG_, RZG_, SA13,
  SA14, SA16, US2SG, WAG_, WALSG_, WBG_, WG1G_, WG2G_, WG3G_, WG4G_, WG5G_,
  WHOMPA, WL01_, WL02_, WL12_, WLG_, WQG_, WYDG_, WYHIG_, WZG_, XUY01_, XUY02_,
  CI14_, CI15_, CI16_, CO02, CO16, G16_, GEM13, GEM14, GEM16, L13_, L14_,
  L16_, MWL13, MWL14, MWL15, MWL16, RL13_, RL14_, RL15_, RL16, RL16_, SUMA02_,
  SUMA04_, SUMA07_, SUMA12_, SUMA16_, WHOMP, WHOMP_, WL13_, WL14_, WL15_,
  WL16_, XUY15_, XUY16_, Z15_, Z16_, A13_, A14_, A15_, A16_, EAC_, G13, G13_,
  G14, G14_, G15, G15_, G16, GTRST_, L15_, PIPAYm_, PIPAZm_, PIPAZp_, SUMA13_,
  SUMA14_, SUMA15_, SUMB13_, SUMB14_, SUMB15_, SUMB16_, WL13, WL14, WL15,
  WL16, XUY13_, XUY14_, Z13_, Z14_
);

initial $timeformat(-9, 0, " ns", 10);
initial $monitor("%t: %d", $time, CLOCK);

endmodule
