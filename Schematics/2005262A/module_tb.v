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

reg CGA4 = 0, DVST = 0, EXST0_ = 0, EXST1_ = 0, GEQZRO_ = 0, GOJAM = 0,
  IC12 = 0, IC13 = 0, INKL = 0, L15_ = 0, MP0_ = 0, MP1 = 0, MP3_ = 0,
  MTCSAI = 0, NDR100_ = 0, OVF_ = 0, PHS2_ = 0, PHS3_ = 0, PHS4 = 0, PHS4_ = 0,
  QC0_ = 0, QC1_ = 0, QC2_ = 0, QC3_ = 0, RSM3 = 0, RSM3_ = 0, RSTSTG = 0,
  SQ0_ = 0, SQ1_ = 0, SQ2_ = 0, SQEXT = 0, SQEXT_ = 0, SQR10 = 0, SQR10_ = 0,
  SQR12_ = 0, ST1 = 0, ST2 = 0, STORE1_ = 0, STRTFC = 0, SUMA16_ = 0, SUMB16_ = 0,
  T01 = 0, T01_ = 0, T02_ = 0, T03_ = 0, T04_ = 0, T05_ = 0, T06_ = 0,
  T07_ = 0, T08_ = 0, T09_ = 0, T10_ = 0, T11_ = 0, T12_ = 0, TOV_ = 0,
  TPZG_ = 0, TRSM = 0, TS0_ = 0, TSGU_ = 0, UNF_ = 0, WL01_ = 0, WL02_ = 0,
  WL03_ = 0, WL04_ = 0, WL05_ = 0, WL06_ = 0, WL07_ = 0, WL08_ = 0, WL09_ = 0,
  WL10_ = 0, WL11_ = 0, WL12_ = 0, WL13_ = 0, WL14_ = 0, WL15_ = 0, WL16_ = 0,
  XB7_ = 0, XT1_ = 0, d7XP14 = 0;

wire B15X, BR1, BR12B, BR12B_, BR1B2, BR1B2B, BR1B2B_, BR1B2_, BR1_, BR2,
  BR2_, BRDIF_, CI_, DIVSTG, DIV_, DV0, DV0_, DV1, DV1376, DV1376_, DV1_,
  DV376, DV3764, DV376_, DV4, DV4_, DVST_, INOUT, INOUT_, KRPT, L16_, MBR1,
  MBR2, MP0T10, MP3A, MRSC, MST1, MST2, MST3, PRINC, R15, R1C_, RAND0,
  RA_, RB1_, RB2, RB_, RC_, READ0, READ0_, ROR0, RRPA, RSC_, RUPT0, RUPT0_,
  RUPT1, RUPT1_, RXOR0, RXOR0_, SGUM, ST0_, ST1376_, ST1D, ST1_, ST376,
  ST376_, ST3_, ST4_, STD2, STG1, STG2, STG3, T12USE_, TL15, TMZ_, TRSM_,
  TSGN2, TSGN_, WAND0, WCH_, WG_, WL_, WOR0, WOR0_, WRITE0, WRITE0_, WY_,
  d1XP10, d2PP1, d2XP3, d2XP5, d3XP2, d3XP7, d4XP11, d4XP5, d5XP11, d5XP28,
  d5XP4, d6XP5, d7XP19, d8PP4, d8XP5, d8XP6, d9XP1;

A4 iA4 (
  rst, CGA4, DVST, EXST0_, EXST1_, GEQZRO_, GOJAM, IC12, IC13, INKL, L15_,
  MP0_, MP1, MP3_, MTCSAI, NDR100_, OVF_, PHS2_, PHS3_, PHS4, PHS4_, QC0_,
  QC1_, QC2_, QC3_, RSM3, RSM3_, RSTSTG, SQ0_, SQ1_, SQ2_, SQEXT, SQEXT_,
  SQR10, SQR10_, SQR12_, ST1, ST2, STORE1_, STRTFC, SUMA16_, SUMB16_, T01,
  T01_, T02_, T03_, T04_, T05_, T06_, T07_, T08_, T09_, T10_, T11_, T12_,
  TOV_, TPZG_, TRSM, TS0_, TSGU_, UNF_, WL01_, WL02_, WL03_, WL04_, WL05_,
  WL06_, WL07_, WL08_, WL09_, WL10_, WL11_, WL12_, WL13_, WL14_, WL15_, WL16_,
  XB7_, XT1_, d7XP14, BR1, BR1_, BR2, BR2_, CI_, DV0_, DV1_, DV4, DVST_,
  L16_, MBR1, MBR2, MP3A, MRSC, MST1, MST2, MST3, R1C_, RA_, RB1_, RB_, RC_,
  ST0_, TL15, TMZ_, TRSM_, TSGN2, TSGN_, WG_, WL_, WY_, d2PP1, B15X, BR12B,
  BR12B_, BR1B2, BR1B2B, BR1B2B_, BR1B2_, BRDIF_, DIVSTG, DIV_, DV0, DV1,
  DV1376, DV1376_, DV376, DV3764, DV376_, DV4_, INOUT, INOUT_, KRPT, MP0T10,
  PRINC, R15, RAND0, RB2, READ0, READ0_, ROR0, RRPA, RSC_, RUPT0, RUPT0_,
  RUPT1, RUPT1_, RXOR0, RXOR0_, SGUM, ST1376_, ST1D, ST1_, ST376, ST376_,
  ST3_, ST4_, STD2, STG1, STG2, STG3, T12USE_, WAND0, WCH_, WOR0, WOR0_,
  WRITE0, WRITE0_, d1XP10, d2XP3, d2XP5, d3XP2, d3XP7, d4XP11, d4XP5, d5XP11,
  d5XP28, d5XP4, d6XP5, d7XP19, d8PP4, d8XP5, d8XP6, d9XP1
);

initial $timeformat(-9, 0, " ns", 10);
initial $monitor("%t: %d", $time, CLOCK);

endmodule
