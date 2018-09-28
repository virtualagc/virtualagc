// Test bench for 2005260A/module.v
`timescale 100ns / 1ns

module testbench;

reg rst = 1;
initial
  begin
    $dumpfile("module.vcd");
    $dumpvars(0, testbench);

    # 1 rst = 0;
    # 1000 $finish;
  end

reg CLOCK = 0;
always #4.8828125 CLOCK = !CLOCK;

reg ALGA = 0;
reg CGA2 = 0;
reg GOJ1 = 0;
reg MP3A = 0;
reg MSTP = 0;
reg MSTRTP = 0;
reg SBY = 0;
reg STRT1 = 0;
reg STRT2 = 0;
reg WL15 = 0;
reg WL15_ = 1;
reg WL16 = 0;
reg WL16_ = 1;

wire CINORM;
wire EVNSET;
wire EVNSET_;
wire GOJAM;
wire GOJAM_;
wire MGOJAM;
wire MONWT;
wire MSTPIT_;
wire MT01;
wire MT02;
wire MT03;
wire MT04;
wire MT05;
wire MT06;
wire MT07;
wire MT08;
wire MT09;
wire MT10;
wire MT11;
wire MT12;
wire ODDSET_;
wire OVFSTB_;
wire P01_;
wire P02;
wire P02_;
wire P03;
wire P03_;
wire P04;
wire P05;
wire P05_;
wire PHS4;
wire PHS4_;
wire Q2A;
wire RINGA_;
wire RINGB_;
wire RT;
wire STOP;
wire STOPA;
wire T02;
wire T02DC_;
wire T03;
wire T03DC_;
wire T06;
wire T06DC_;
wire T08;
wire T08DC_;
wire T10;
wire T10DC_;
wire T12DC_;
wire WT;
wire WT_;
wire CLK;
wire CT;
wire CT_;
wire EDSET;
wire F01A;
wire F01B;
wire F01C;
wire F01D;
wire FS01;
wire FS01_;
wire GOSET_;
wire OVF;
wire OVF_;
wire P01;
wire P04_;
wire PHS2;
wire PHS2_;
wire RT_;
wire SB0;
wire SB1;
wire SB2;
wire SB4;
wire STOP_;
wire T01;
wire T01DC_;
wire T01_;
wire T02_;
wire T03_;
wire T04;
wire T04_;
wire T05;
wire T05_;
wire T06_;
wire T07;
wire T07DC_;
wire T07_;
wire T08_;
wire T09;
wire T09DC_;
wire T09_;
wire T10_;
wire T11;
wire T11_;
wire T12;
wire T12SET;
wire T12_;
wire TT_;
wire UNF;
wire UNF_;
A2 A2A( 
  rst,
  ALGA,
  CGA2,
  CLOCK,
  GOJ1,
  MP3A,
  MSTP,
  MSTRTP,
  SBY,
  STRT1,
  STRT2,
  WL15,
  WL15_,
  WL16,
  WL16_,
  CINORM,
  EVNSET,
  EVNSET_,
  GOJAM,
  GOJAM_,
  MGOJAM,
  MONWT,
  MSTPIT_,
  MT01,
  MT02,
  MT03,
  MT04,
  MT05,
  MT06,
  MT07,
  MT08,
  MT09,
  MT10,
  MT11,
  MT12,
  ODDSET_,
  OVFSTB_,
  P01_,
  P02,
  P02_,
  P03,
  P03_,
  P04,
  P05,
  P05_,
  PHS4,
  PHS4_,
  Q2A,
  RINGA_,
  RINGB_,
  RT,
  STOP,
  STOPA,
  T02,
  T02DC_,
  T03,
  T03DC_,
  T06,
  T06DC_,
  T08,
  T08DC_,
  T10,
  T10DC_,
  T12DC_,
  WT,
  WT_,
  CLK,
  CT,
  CT_,
  EDSET,
  F01A,
  F01B,
  F01C,
  F01D,
  FS01,
  FS01_,
  GOSET_,
  OVF,
  OVF_,
  P01,
  P04_,
  PHS2,
  PHS2_,
  RT_,
  SB0,
  SB1,
  SB2,
  SB4,
  STOP_,
  T01,
  T01DC_,
  T01_,
  T02_,
  T03_,
  T04,
  T04_,
  T05,
  T05_,
  T06_,
  T07,
  T07DC_,
  T07_,
  T08_,
  T09,
  T09DC_,
  T09_,
  T10_,
  T11,
  T11_,
  T12,
  T12SET,
  T12_,
  TT_,
  UNF,
  UNF_
);

initial
  $timeformat(-9, 0, " ns", 10);
initial
  $monitor("%t: %d", $time, CLOCK);

endmodule
