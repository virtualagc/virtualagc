// Verilog module auto-generated for AGC module A3 by dumbVerilog.py

module A3 ( 
  rst, BR1B2B, BR2_, CGA3, CT_, DBLTST, EXT, EXTPLS, FS09, FS10, GOJAM, INHPLS,
  INKL, KRPT, MNHRPT, MTCSAI, NISQ, ODDSET_, OVNHRP, PHS2_, RELPLS, RT_,
  RUPTOR_, RXOR0, ST0_, ST1_, ST3_, STD2, T01_, T02, T07DC_, T12_, WL10_,
  WL11_, WL12_, WL13_, WL14_, WL16_, WT_, d5XP4, CON1, CON2, EXST0_, INKBT1,
  MIIP, MINHL, MSQ10, MSQ11, MSQ12, MSQ13, MSQ14, MSQ16, MSQEXT, MTCSA_,
  NEXST0, QC0, QC0_, QC1_, QC2_, QC3_, RPTSET, SCAS10, SQ0_, SQ1_, SQ2_,
  SQ3_, SQ4_, SQ5, SQ6_, SQ7_, SQEXT, SQEXT_, T07, TCSAJ3, TS0, AD0, ADS0,
  AUG0, AUG0_, BMF0, BMF0_, BZF0, BZF0_, CCS0, CCS0_, CSQG, DAS0, DAS0_,
  DAS1, DAS1_, DCA0, DCS0, DIM0, DIM0_, DXCH0, EXST1_, FUTEXT, GOJ1, GOJ1_,
  IC1, IC10, IC10_, IC11, IC12, IC12_, IC13, IC13_, IC14, IC15, IC15_, IC16,
  IC16_, IC17, IC2, IC2_, IC3, IC3_, IC4, IC4_, IC5, IC5_, IC6, IC7, IC8_,
  IC9, IC9_, IIP, IIP_, INCR0, INHINT, LXCH0, MASK0, MASK0_, MP0, MP0_, MP1,
  MP1_, MP3, MP3_, MSU0, MSU0_, NDX0, NDX0_, NDXX1, NDXX1_, NEXST0_, NISQL_,
  QXCH0, QXCH0_, RBSQ, RPTFRC, RSM3, RSM3_, SQ5QC0_, SQ5_, SQR10, SQR10_,
  SQR11, SQR12, SQR12_, SQR13, SQR14, SQR16, STRTFC, SU0, TC0, TC0_, TCF0,
  TCSAJ3_, TS0_, WSQG_
);

input wire rst, BR1B2B, BR2_, CGA3, CT_, DBLTST, EXT, EXTPLS, FS09, FS10,
  GOJAM, INHPLS, INKL, KRPT, MNHRPT, MTCSAI, NISQ, ODDSET_, OVNHRP, PHS2_,
  RELPLS, RT_, RUPTOR_, RXOR0, ST0_, ST1_, ST3_, STD2, T01_, T02, T07DC_,
  T12_, WL10_, WL11_, WL12_, WL13_, WL14_, WL16_, WT_, d5XP4;

inout wire CON1, CON2, EXST0_, INKBT1, MIIP, MINHL, MSQ10, MSQ11, MSQ12,
  MSQ13, MSQ14, MSQ16, MSQEXT, MTCSA_, NEXST0, QC0, QC0_, QC1_, QC2_, QC3_,
  RPTSET, SCAS10, SQ0_, SQ1_, SQ2_, SQ3_, SQ4_, SQ5, SQ6_, SQ7_, SQEXT, SQEXT_,
  T07, TCSAJ3, TS0;

output wire AD0, ADS0, AUG0, AUG0_, BMF0, BMF0_, BZF0, BZF0_, CCS0, CCS0_,
  CSQG, DAS0, DAS0_, DAS1, DAS1_, DCA0, DCS0, DIM0, DIM0_, DXCH0, EXST1_,
  FUTEXT, GOJ1, GOJ1_, IC1, IC10, IC10_, IC11, IC12, IC12_, IC13, IC13_,
  IC14, IC15, IC15_, IC16, IC16_, IC17, IC2, IC2_, IC3, IC3_, IC4, IC4_,
  IC5, IC5_, IC6, IC7, IC8_, IC9, IC9_, IIP, IIP_, INCR0, INHINT, LXCH0,
  MASK0, MASK0_, MP0, MP0_, MP1, MP1_, MP3, MP3_, MSU0, MSU0_, NDX0, NDX0_,
  NDXX1, NDXX1_, NEXST0_, NISQL_, QXCH0, QXCH0_, RBSQ, RPTFRC, RSM3, RSM3_,
  SQ5QC0_, SQ5_, SQR10, SQR10_, SQR11, SQR12, SQR12_, SQR13, SQR14, SQR16,
  STRTFC, SU0, TC0, TC0_, TCF0, TCSAJ3_, TS0_, WSQG_;

// Gate A3-U153B
pullup(SQ1_);
assign #0.2  SQ1_ = rst ? 1'bz : ((0|g30038) ? 1'b0 : 1'bz);
// Gate A3-U242A
pullup(NDX0_);
assign #0.2  NDX0_ = rst ? 1'bz : ((0|NDX0) ? 1'b0 : 1'bz);
// Gate A3-U159A
pullup(NISQL_);
assign #0.2  NISQL_ = rst ? 1'bz : ((0|g30002) ? 1'b0 : 1'bz);
// Gate A3-U220B
pullup(g30347);
assign #0.2  g30347 = rst ? 0 : ((0|ST0_|SQEXT_) ? 1'b0 : 1'bz);
// Gate A3-U154B
pullup(SQ5);
assign #0.2  SQ5 = rst ? 0 : ((0|g30031|g30020|g30034) ? 1'b0 : 1'bz);
// Gate A3-U252B
pullup(IC12_);
assign #0.2  IC12_ = rst ? 1'bz : ((0|MSU0|CCS0) ? 1'b0 : 1'bz);
// Gate A3-U117A
pullup(g30142);
assign #0.2  g30142 = rst ? 0 : ((0|g30134|SQR12) ? 1'b0 : 1'bz);
// Gate A3-U218B
pullup(g30315);
assign #0.2  g30315 = rst ? 0 : ((0|g30314|NEXST0) ? 1'b0 : 1'bz);
// Gate A3-U104B
pullup(RPTFRC);
assign #0.2  RPTFRC = rst ? 0 : ((0|g30121) ? 1'b0 : 1'bz);
// Gate A3-U154A
pullup(g30010);
assign #0.2  g30010 = rst ? 0 : ((0|g30006|WT_) ? 1'b0 : 1'bz);
// Gate A3-U151A A3-U150A
pullup(CSQG);
assign #0.2  CSQG = rst ? 0 : ((0|T12_|g30005|CT_) ? 1'b0 : 1'bz);
// Gate A3-U137A
pullup(g30013);
assign #0.2  g30013 = rst ? 0 : ((0|WL16_|WSQG_) ? 1'b0 : 1'bz);
// Gate A3-U104A
pullup(g30144);
assign #0.2  g30144 = rst ? 1'bz : ((0|g30132|g30134) ? 1'b0 : 1'bz);
// Gate A3-U101B
pullup(g30059);
assign #0.2  g30059 = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A3-U112B
pullup(IIP_);
assign #0.2  IIP_ = rst ? 1'bz : ((0|KRPT|IIP) ? 1'b0 : 1'bz);
// Gate A3-U103B
pullup(g30128);
assign #0.2  g30128 = rst ? 0 : ((0|g30121) ? 1'b0 : 1'bz);
// Gate A3-U129A
pullup(g30130);
assign #0.2  g30130 = rst ? 0 : ((0|WSQG_|WL11_) ? 1'b0 : 1'bz);
// Gate A3-U202B
pullup(IC5_);
assign #0.2  IC5_ = rst ? 1'bz : ((0|IC5) ? 1'b0 : 1'bz);
// Gate A3-U212B
pullup(LXCH0);
assign #0.2  LXCH0 = rst ? 0 : ((0|SQ2_|NEXST0_|QC1_) ? 1'b0 : 1'bz);
// Gate A3-U103A A3-U102A
pullup(QC3_);
assign #0.2  QC3_ = rst ? 0 : ((0|g30144) ? 1'b0 : 1'bz);
// Gate A3-U136A
pullup(g30016);
assign #0.2  g30016 = rst ? 0 : ((0|g30013|SQR16) ? 1'b0 : 1'bz);
// Gate A3-U132B
pullup(SCAS10);
assign #0.2  SCAS10 = rst ? 1'bz : ((0|FS10|CON2) ? 1'b0 : 1'bz);
// Gate A3-U216A
pullup(g30334);
assign #0.2  g30334 = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A3-U241A
pullup(NDXX1);
assign #0.2  NDXX1 = rst ? 0 : ((0|SQEXT_|SQ5_|ST1_) ? 1'b0 : 1'bz);
// Gate A3-U230B
pullup(g30301);
assign #0.2  g30301 = rst ? 0 : ((0|SQ5_|QC0_) ? 1'b0 : 1'bz);
// Gate A3-U243A
pullup(NDX0);
assign #0.2  NDX0 = rst ? 0 : ((0|NEXST0_|SQ5_|QC0_) ? 1'b0 : 1'bz);
// Gate A3-U150B A3-U149B
pullup(SQ0_);
assign #0.2  SQ0_ = rst ? 1'bz : ((0|g30037) ? 1'b0 : 1'bz);
// Gate A3-U149A
pullup(CON1);
assign #0.2  CON1 = rst ? 1'bz : ((0|DBLTST) ? 1'b0 : 1'bz);
// Gate A3-U254A
pullup(BZF0_);
assign #0.2  BZF0_ = rst ? 1'bz : ((0|BZF0) ? 1'b0 : 1'bz);
// Gate A3-U229B
pullup(g30302);
assign #0.2  g30302 = rst ? 0 : ((0|SQ5_|SQEXT_) ? 1'b0 : 1'bz);
// Gate A3-U102B
pullup(T07);
assign #0.2  T07 = rst ? 0 : ((0|T07DC_|ODDSET_) ? 1'b0 : 1'bz);
// Gate A3-U224A
pullup(IC3);
assign #0.2  IC3 = rst ? 0 : ((0|IC3_) ? 1'b0 : 1'bz);
// Gate A3-U221A A3-U209A
pullup(IC13_);
assign #0.2  IC13_ = rst ? 0 : ((0|IC11|IC6|IC7|DCS0|IC1|DCA0) ? 1'b0 : 1'bz);
// Gate A3-U123A
pullup(SQR10_);
assign #0.2  SQR10_ = rst ? 0 : ((0|g30137) ? 1'b0 : 1'bz);
// Gate A3-U126A
pullup(SQR10);
assign #0.2  SQR10 = rst ? 1'bz : ((0|g30136) ? 1'b0 : 1'bz);
// Gate A3-U109A
pullup(SQR11);
assign #0.2  SQR11 = rst ? 1'bz : ((0|CSQG|g30134) ? 1'b0 : 1'bz);
// Gate A3-U114A
pullup(SQR12);
assign #0.2  SQR12 = rst ? 1'bz : ((0|g30132|CSQG) ? 1'b0 : 1'bz);
// Gate A3-U146A
pullup(SQR13);
assign #0.2  SQR13 = rst ? 0 : ((0|CSQG|g30128|g30020) ? 1'b0 : 1'bz);
// Gate A3-U140A
pullup(SQR14);
assign #0.2  SQR14 = rst ? 1'bz : ((0|g30018|g30128|CSQG) ? 1'b0 : 1'bz);
// Gate A3-U135B
pullup(SQR16);
assign #0.2  SQR16 = rst ? 1'bz : ((0|g30128|g30016|CSQG) ? 1'b0 : 1'bz);
// Gate A3-U111A A3-U111B A3-U109B
pullup(RPTSET);
assign #0.2  RPTSET = rst ? 0 : ((0|T12_|NISQL_|FUTEXT|OVNHRP|INHINT|IIP|PHS2_|MNHRPT|RUPTOR_) ? 1'b0 : 1'bz);
// Gate A3-U128A
pullup(g30131);
assign #0.2  g30131 = rst ? 0 : ((0|WSQG_|WL10_) ? 1'b0 : 1'bz);
// Gate A3-U159B
pullup(CON2);
assign #0.2  CON2 = rst ? 0 : ((0|FS09|CON1) ? 1'b0 : 1'bz);
// Gate A3-U256B
pullup(g30408);
assign #0.2  g30408 = rst ? 0 : ((0|BMF0_|BR1B2B) ? 1'b0 : 1'bz);
// Gate A3-U236B
pullup(RSM3);
assign #0.2  RSM3 = rst ? 0 : ((0|SQEXT|ST3_|SQ5QC0_) ? 1'b0 : 1'bz);
// Gate A3-U219A A3-U220A
pullup(TS0_);
assign #0.2  TS0_ = rst ? 1'bz : ((0|TS0) ? 1'b0 : 1'bz);
// Gate A3-U147B
pullup(g30036);
assign #0.2  g30036 = rst ? 0 : ((0|g30020) ? 1'b0 : 1'bz);
// Gate A3-U142A A3-U141A
pullup(g30018);
assign #0.2  g30018 = rst ? 0 : ((0|SQR14|g30014) ? 1'b0 : 1'bz);
// Gate A3-U134A
pullup(g30060);
assign #0.2  g30060 = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A3-U244A
pullup(DAS1);
assign #0.2  DAS1 = rst ? 0 : ((0|DAS1_) ? 1'b0 : 1'bz);
// Gate A3-U133A
pullup(g30023);
assign #0.2  g30023 = rst ? 1'bz : ((0|g30016|INKL) ? 1'b0 : 1'bz);
// Gate A3-U239B
pullup(GOJ1);
assign #0.2  GOJ1 = rst ? 0 : ((0|SQEXT|SQ0_|ST1_) ? 1'b0 : 1'bz);
// Gate A3-U105A
pullup(QC2_);
assign #0.2  QC2_ = rst ? 1'bz : ((0|g30143) ? 1'b0 : 1'bz);
// Gate A3-U133B
pullup(g30031);
assign #0.2  g30031 = rst ? 0 : ((0|g30023) ? 1'b0 : 1'bz);
// Gate A3-U107B
pullup(SQR12_);
assign #0.2  SQR12_ = rst ? 0 : ((0|SQR12) ? 1'b0 : 1'bz);
// Gate A3-U113A
pullup(MINHL);
assign #0.2  MINHL = rst ? 0 : ((0|g30103) ? 1'b0 : 1'bz);
// Gate A3-U121B
pullup(g30119);
assign #0.2  g30119 = rst ? 1'bz : ((0|RPTFRC|g30120|g30114) ? 1'b0 : 1'bz);
// Gate A3-U212A
pullup(IC10_);
assign #0.2  IC10_ = rst ? 1'bz : ((0|DXCH0|DAS0|IC4) ? 1'b0 : 1'bz);
// Gate A3-U118B A3-U117B
pullup(SQEXT_);
assign #0.2  SQEXT_ = rst ? 1'bz : ((0|g30120) ? 1'b0 : 1'bz);
// Gate A3-U131A
pullup(g30024);
assign #0.2  g30024 = rst ? 0 : ((0|INKL|SQR16) ? 1'b0 : 1'bz);
// Gate A3-U204B
pullup(g30337);
assign #0.2  g30337 = rst ? 0 : ((0|g30335|g30336) ? 1'b0 : 1'bz);
// Gate A3-U130B
pullup(g30101);
assign #0.2  g30101 = rst ? 0 : ((0|GOJAM|MTCSAI) ? 1'b0 : 1'bz);
// Gate A3-U240A
pullup(MP1);
assign #0.2  MP1 = rst ? 0 : ((0|ST1_|SQEXT_|SQ7_) ? 1'b0 : 1'bz);
// Gate A3-U210A
pullup(IC4_);
assign #0.2  IC4_ = rst ? 1'bz : ((0|DCA0|DCS0) ? 1'b0 : 1'bz);
// Gate A3-U131B
pullup(g30032);
assign #0.2  g30032 = rst ? 1'bz : ((0|g30024) ? 1'b0 : 1'bz);
// Gate A3-U113B
pullup(MIIP);
assign #0.2  MIIP = rst ? 0 : ((0|IIP_) ? 1'b0 : 1'bz);
// Gate A3-U225A
pullup(TCF0);
assign #0.2  TCF0 = rst ? 0 : ((0|QC0|SQ1_|NEXST0_) ? 1'b0 : 1'bz);
// Gate A3-U234A A3-U234B
pullup(MP0_);
assign #0.2  MP0_ = rst ? 1'bz : ((0|MP0) ? 1'b0 : 1'bz);
// Gate A3-U119B
pullup(g30115);
assign #0.2  g30115 = rst ? 1'bz : ((0|FUTEXT|g30113) ? 1'b0 : 1'bz);
// Gate A3-U128B
pullup(g30113);
assign #0.2  g30113 = rst ? 0 : ((0|STRTFC|g30108) ? 1'b0 : 1'bz);
// Gate A3-U156B
pullup(SQ3_);
assign #0.2  SQ3_ = rst ? 1'bz : ((0|g30041) ? 1'b0 : 1'bz);
// Gate A3-U140B A3-U138B A3-U137B
pullup(SQ2_);
assign #0.2  SQ2_ = rst ? 1'bz : ((0|g30040) ? 1'b0 : 1'bz);
// Gate A3-U124A
pullup(g30137);
assign #0.2  g30137 = rst ? 1'bz : ((0|g30136|CSQG) ? 1'b0 : 1'bz);
// Gate A3-U248A
pullup(DIM0_);
assign #0.2  DIM0_ = rst ? 1'bz : ((0|DIM0) ? 1'b0 : 1'bz);
// Gate A3-U126B
pullup(g30109);
assign #0.2  g30109 = rst ? 1'bz : ((0|FUTEXT|EXT|EXTPLS) ? 1'b0 : 1'bz);
// Gate A3-U228A
pullup(TC0);
assign #0.2  TC0 = rst ? 0 : ((0|SQ0_|NEXST0_) ? 1'b0 : 1'bz);
// Gate A3-U124B A3-U116B
pullup(SQEXT);
assign #0.2  SQEXT = rst ? 0 : ((0|g30119) ? 1'b0 : 1'bz);
// Gate A3-U241B
pullup(MP1_);
assign #0.2  MP1_ = rst ? 1'bz : ((0|MP1) ? 1'b0 : 1'bz);
// Gate A3-U110A
pullup(g30121);
assign #0.2  g30121 = rst ? 1'bz : ((0|RPTSET|g30122) ? 1'b0 : 1'bz);
// Gate A3-U240B
pullup(GOJ1_);
assign #0.2  GOJ1_ = rst ? 1'bz : ((0|GOJ1) ? 1'b0 : 1'bz);
// Gate A3-U251A
pullup(MSU0);
assign #0.2  MSU0 = rst ? 0 : ((0|SQ2_|QC0_|EXST0_) ? 1'b0 : 1'bz);
// Gate A3-U214B A3-U213B
pullup(DAS0);
assign #0.2  DAS0 = rst ? 0 : ((0|QC0_|SQ2_|NEXST0_) ? 1'b0 : 1'bz);
// Gate A3-U101A
pullup(g30134);
assign #0.2  g30134 = rst ? 0 : ((0|g30128|g30130|SQR11) ? 1'b0 : 1'bz);
// Gate A3-U218A
pullup(TS0);
assign #0.2  TS0 = rst ? 0 : ((0|SQ5_|QC2_|NEXST0_) ? 1'b0 : 1'bz);
// Gate A3-U136B
pullup(g30040);
assign #0.2  g30040 = rst ? 0 : ((0|g30036|g30032|g30018) ? 1'b0 : 1'bz);
// Gate A3-U255B
pullup(BMF0);
assign #0.2  BMF0 = rst ? 0 : ((0|QC0|SQ6_|EXST0_) ? 1'b0 : 1'bz);
// Gate A3-U207B A3-U209B
pullup(IC9_);
assign #0.2  IC9_ = rst ? 1'bz : ((0|IC5|TS0|LXCH0|QXCH0) ? 1'b0 : 1'bz);
// Gate A3-U222A A3-U259A A3-U233A A3-U260A
pullup(gNNNNN);
assign #0.2  gNNNNN = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A3-U125B
pullup(FUTEXT);
assign #0.2  FUTEXT = rst ? 0 : ((0|STRTFC|INKBT1|g30109) ? 1'b0 : 1'bz);
// Gate A3-U257B
pullup(IC16_);
assign #0.2  IC16_ = rst ? 1'bz : ((0|g30407|g30408) ? 1'b0 : 1'bz);
// Gate A3-U23B
pullup(g30108);
assign #0.2  g30108 = rst ? 0 : ((0|NISQL_|T12_) ? 1'b0 : 1'bz);
// Gate A3-U35A A3-U236A
pullup(MP3_);
assign #0.2  MP3_ = rst ? 1'bz : ((0|MP3) ? 1'b0 : 1'bz);
// Gate A3-U256A
pullup(g30407);
assign #0.2  g30407 = rst ? 0 : ((0|BR2_|BZF0_) ? 1'b0 : 1'bz);
// Gate A3-U211B
pullup(QXCH0);
assign #0.2  QXCH0 = rst ? 0 : ((0|QC1_|SQ2_|EXST0_) ? 1'b0 : 1'bz);
// Gate A3-U221B
pullup(g30314);
assign #0.2  g30314 = rst ? 0 : ((0|ST1_|SQEXT_) ? 1'b0 : 1'bz);
// Gate A3-U217A
pullup(DCA0);
assign #0.2  DCA0 = rst ? 0 : ((0|SQ3_|EXST0_) ? 1'b0 : 1'bz);
// Gate A3-U156A
pullup(g30006);
assign #0.2  g30006 = rst ? 1'bz : ((0|g30003) ? 1'b0 : 1'bz);
// Gate A3-U238B
pullup(RSM3_);
assign #0.2  RSM3_ = rst ? 1'bz : ((0|RSM3) ? 1'b0 : 1'bz);
// Gate A3-U243B
pullup(AD0);
assign #0.2  AD0 = rst ? 1'bz : ((0|NEXST0_|SQ6_) ? 1'b0 : 1'bz);
// Gate A3-U249B
pullup(AUG0_);
assign #0.2  AUG0_ = rst ? 1'bz : ((0|AUG0) ? 1'b0 : 1'bz);
// Gate A3-U242B
pullup(NDXX1_);
assign #0.2  NDXX1_ = rst ? 1'bz : ((0|NDXX1) ? 1'b0 : 1'bz);
// Gate A3-U214A A3-U213A
pullup(DXCH0);
assign #0.2  DXCH0 = rst ? 0 : ((0|NEXST0_|QC1_|SQ5_) ? 1'b0 : 1'bz);
// Gate A3-U115B
pullup(g30103);
assign #0.2  g30103 = rst ? 1'bz : ((0|INHPLS|INHINT) ? 1'b0 : 1'bz);
// Gate A3-U132A
pullup(MSQ16);
assign #0.2  MSQ16 = rst ? 1'bz : ((0|g30016) ? 1'b0 : 1'bz);
// Gate A3-U249A
pullup(DIM0);
assign #0.2  DIM0 = rst ? 0 : ((0|SQ2_|EXST0_|QC3_) ? 1'b0 : 1'bz);
// Gate A3-U144A
pullup(MSQ14);
assign #0.2  MSQ14 = rst ? 1'bz : ((0|g30018) ? 1'b0 : 1'bz);
// Gate A3-U144B
pullup(MSQ13);
assign #0.2  MSQ13 = rst ? 0 : ((0|g30020) ? 1'b0 : 1'bz);
// Gate A3-U108B
pullup(MSQ12);
assign #0.2  MSQ12 = rst ? 1'bz : ((0|g30132) ? 1'b0 : 1'bz);
// Gate A3-U108A
pullup(MSQ11);
assign #0.2  MSQ11 = rst ? 1'bz : ((0|g30134) ? 1'b0 : 1'bz);
// Gate A3-U127A
pullup(MSQ10);
assign #0.2  MSQ10 = rst ? 1'bz : ((0|g30136) ? 1'b0 : 1'bz);
// Gate A3-U238A
pullup(TCSAJ3);
assign #0.2  TCSAJ3 = rst ? 0 : ((0|SQ0_|SQEXT|ST3_) ? 1'b0 : 1'bz);
// Gate A3-U250B
pullup(AUG0);
assign #0.2  AUG0 = rst ? 0 : ((0|EXST0_|QC2_|SQ2_) ? 1'b0 : 1'bz);
// Gate A3-U230A A3-U229A
pullup(SQ5_);
assign #0.2  SQ5_ = rst ? 1'bz : ((0|SQ5) ? 1'b0 : 1'bz);
// Gate A3-U158A
pullup(g30003);
assign #0.2  g30003 = rst ? 0 : ((0|g30001|g30128|T12_) ? 1'b0 : 1'bz);
// Gate A3-U232A
pullup(MASK0_);
assign #0.2  MASK0_ = rst ? 1'bz : ((0|MASK0) ? 1'b0 : 1'bz);
// Gate A3-U235B
pullup(MP3);
assign #0.2  MP3 = rst ? 0 : ((0|SQ7_|ST3_|SQEXT_) ? 1'b0 : 1'bz);
// Gate A3-U105B
pullup(g30122);
assign #0.2  g30122 = rst ? 0 : ((0|T02|g30121|STRTFC) ? 1'b0 : 1'bz);
// Gate A3-U203A
pullup(NEXST0);
assign #0.2  NEXST0 = rst ? 1'bz : ((0|ST0_|SQEXT) ? 1'b0 : 1'bz);
// Gate A3-U130A
pullup(g30129);
assign #0.2  g30129 = rst ? 0 : ((0|WSQG_|WL12_) ? 1'b0 : 1'bz);
// Gate A3-U208B
pullup(IC8_);
assign #0.2  IC8_ = rst ? 1'bz : ((0|DXCH0|LXCH0) ? 1'b0 : 1'bz);
// Gate A3-U114B
pullup(INHINT);
assign #0.2  INHINT = rst ? 0 : ((0|RELPLS|g30103|GOJAM) ? 1'b0 : 1'bz);
// Gate A3-U231A
pullup(MASK0);
assign #0.2  MASK0 = rst ? 0 : ((0|NEXST0_|SQ7_) ? 1'b0 : 1'bz);
// Gate A3-U107A
pullup(g30143);
assign #0.2  g30143 = rst ? 0 : ((0|SQR11|g30132) ? 1'b0 : 1'bz);
// Gate A3-U129B
pullup(STRTFC);
assign #0.2  STRTFC = rst ? 1'bz : ((0|g30101) ? 1'b0 : 1'bz);
// Gate A3-U120B
pullup(g30120);
assign #0.2  g30120 = rst ? 0 : ((0|g30119|g30115) ? 1'b0 : 1'bz);
// Gate A3-U253A
pullup(CCS0);
assign #0.2  CCS0 = rst ? 0 : ((0|SQ1_|NEXST0_|QC0_) ? 1'b0 : 1'bz);
// Gate A3-U138A
pullup(g30014);
assign #0.2  g30014 = rst ? 0 : ((0|WL14_|WSQG_) ? 1'b0 : 1'bz);
// Gate A3-U112A
pullup(g30132);
assign #0.2  g30132 = rst ? 0 : ((0|SQR12|g30129|g30128) ? 1'b0 : 1'bz);
// Gate A3-U258A
pullup(IC17);
assign #0.2  IC17 = rst ? 0 : ((0|IC16|IC15_) ? 1'b0 : 1'bz);
// Gate A3-U160B
pullup(g30002);
assign #0.2  g30002 = rst ? 0 : ((0|STRTFC|INKBT1|g30001) ? 1'b0 : 1'bz);
// Gate A3-U259B
pullup(IC15);
assign #0.2  IC15 = rst ? 0 : ((0|IC15_) ? 1'b0 : 1'bz);
// Gate A3-U232B
pullup(IC14);
assign #0.2  IC14 = rst ? 0 : ((0|g30455) ? 1'b0 : 1'bz);
// Gate A3-U207A
pullup(IC13);
assign #0.2  IC13 = rst ? 1'bz : ((0|IC13_) ? 1'b0 : 1'bz);
// Gate A3-U252A
pullup(IC12);
assign #0.2  IC12 = rst ? 0 : ((0|IC12_) ? 1'b0 : 1'bz);
// Gate A3-U223A
pullup(IC11);
assign #0.2  IC11 = rst ? 1'bz : ((0|ST0_|g30360|SQ6_) ? 1'b0 : 1'bz);
// Gate A3-U211A
pullup(IC10);
assign #0.2  IC10 = rst ? 0 : ((0|IC10_) ? 1'b0 : 1'bz);
// Gate A3-U152A A3-U153A
pullup(WSQG_);
assign #0.2  WSQG_ = rst ? 1'bz : ((0|g30010) ? 1'b0 : 1'bz);
// Gate A3-U41B
pullup(g30034);
assign #0.2  g30034 = rst ? 0 : ((0|g30018) ? 1'b0 : 1'bz);
// Gate A3-U231B
pullup(g30455);
assign #0.2  g30455 = rst ? 1'bz : ((0|MASK0|RXOR0|MP0) ? 1'b0 : 1'bz);
// Gate A3-U248B
pullup(ADS0);
assign #0.2  ADS0 = rst ? 0 : ((0|QC3_|SQ2_|NEXST0_) ? 1'b0 : 1'bz);
// Gate A3-U143A
pullup(g30015);
assign #0.2  g30015 = rst ? 0 : ((0|WL13_|WSQG_) ? 1'b0 : 1'bz);
// Gate A3-U127B
pullup(MSQEXT);
assign #0.2  MSQEXT = rst ? 0 : ((0|g30119) ? 1'b0 : 1'bz);
// Gate A3-U215A
pullup(DCS0);
assign #0.2  DCS0 = rst ? 0 : ((0|SQ4_|EXST0_) ? 1'b0 : 1'bz);
// Gate A3-U143B
pullup(g30042);
assign #0.2  g30042 = rst ? 0 : ((0|g30031|g30034|g30036) ? 1'b0 : 1'bz);
// Gate A3-U244B
pullup(SU0);
assign #0.2  SU0 = rst ? 0 : ((0|SQ6_|EXST0_|QC0_) ? 1'b0 : 1'bz);
// Gate A3-U155A
pullup(RBSQ);
assign #0.2  RBSQ = rst ? 0 : ((0|g30006|RT_) ? 1'b0 : 1'bz);
// Gate A3-U152B
pullup(g30047);
assign #0.2  g30047 = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A3-U122B
pullup(g30114);
assign #0.2  g30114 = rst ? 0 : ((0|g30109|g30113) ? 1'b0 : 1'bz);
// Gate A3-U145B
pullup(SQ4_);
assign #0.2  SQ4_ = rst ? 1'bz : ((0|g30042) ? 1'b0 : 1'bz);
// Gate A3-U217B
pullup(EXST1_);
assign #0.2  EXST1_ = rst ? 1'bz : ((0|g30314) ? 1'b0 : 1'bz);
// Gate A3-U254B
pullup(BZF0);
assign #0.2  BZF0 = rst ? 0 : ((0|EXST0_|QC0|SQ1_) ? 1'b0 : 1'bz);
// Gate A3-U233B
pullup(MP0);
assign #0.2  MP0 = rst ? 0 : ((0|SQ7_|SQEXT_|ST0_) ? 1'b0 : 1'bz);
// Gate A3-U157B
pullup(g30044);
assign #0.2  g30044 = rst ? 0 : ((0|g30018|g30031|g30020) ? 1'b0 : 1'bz);
// Gate A3-U219B A3-U260B
pullup(EXST0_);
assign #0.2  EXST0_ = rst ? 1'bz : ((0|g30347) ? 1'b0 : 1'bz);
// Gate A3-U255A
pullup(BMF0_);
assign #0.2  BMF0_ = rst ? 1'bz : ((0|BMF0) ? 1'b0 : 1'bz);
// Gate A3-U205B
pullup(g30336);
assign #0.2  g30336 = rst ? 1'bz : ((0|ST0_|QC3_) ? 1'b0 : 1'bz);
// Gate A3-U210B
pullup(QXCH0_);
assign #0.2  QXCH0_ = rst ? 1'bz : ((0|QXCH0) ? 1'b0 : 1'bz);
// Gate A3-U205A A3-U204A A3-U202A
pullup(NEXST0_);
assign #0.2  NEXST0_ = rst ? 0 : ((0|NEXST0) ? 1'b0 : 1'bz);
// Gate A3-U206A
pullup(g30335);
assign #0.2  g30335 = rst ? 0 : ((0|QC1_|ST1_) ? 1'b0 : 1'bz);
// Gate A3-U151B
pullup(g30038);
assign #0.2  g30038 = rst ? 0 : ((0|g30032|g30034|g30020) ? 1'b0 : 1'bz);
// Gate A3-U246B
pullup(MTCSA_);
assign #0.2  MTCSA_ = rst ? 1'bz : ((0|TCSAJ3) ? 1'b0 : 1'bz);
// Gate A3-U142B
pullup(INKBT1);
assign #0.2  INKBT1 = rst ? 1'bz : ((0|INKL|T01_) ? 1'b0 : 1'bz);
// Gate A3-U253B A3-U247A
pullup(CCS0_);
assign #0.2  CCS0_ = rst ? 1'bz : ((0|CCS0) ? 1'b0 : 1'bz);
// Gate A3-U125A
pullup(g30136);
assign #0.2  g30136 = rst ? 0 : ((0|g30137|g30131|g30128) ? 1'b0 : 1'bz);
// Gate A3-U110B
pullup(IIP);
assign #0.2  IIP = rst ? 0 : ((0|d5XP4|GOJAM|IIP_) ? 1'b0 : 1'bz);
// Gate A3-U226A
pullup(IC3_);
assign #0.2  IC3_ = rst ? 1'bz : ((0|TC0|STD2|TCF0) ? 1'b0 : 1'bz);
// Gate A3-U250A
pullup(INCR0);
assign #0.2  INCR0 = rst ? 0 : ((0|SQ2_|NEXST0_|QC2_) ? 1'b0 : 1'bz);
// Gate A3-U155B
pullup(g30041);
assign #0.2  g30041 = rst ? 0 : ((0|g30032|g30018|g30020) ? 1'b0 : 1'bz);
// Gate A3-U245A A3-U245B
pullup(DAS1_);
assign #0.2  DAS1_ = rst ? 1'bz : ((0|g30418|ADS0) ? 1'b0 : 1'bz);
// Gate A3-U225B
pullup(g30360);
assign #0.2  g30360 = rst ? 0 : ((0|QC0|SQEXT_) ? 1'b0 : 1'bz);
// Gate A3-U247B A3-U246A
pullup(g30418);
assign #0.2  g30418 = rst ? 0 : ((0|SQ2_|QC0_|ST1_|SQEXT) ? 1'b0 : 1'bz);
// Gate A3-U206B
pullup(IC9);
assign #0.2  IC9 = rst ? 0 : ((0|IC9_) ? 1'b0 : 1'bz);
// Gate A3-U158B
pullup(SQ7_);
assign #0.2  SQ7_ = rst ? 1'bz : ((0|g30044) ? 1'b0 : 1'bz);
// Gate A3-U116A A3-U115A
pullup(QC1_);
assign #0.2  QC1_ = rst ? 1'bz : ((0|g30142) ? 1'b0 : 1'bz);
// Gate A3-U224B A3-U223B
pullup(IC2);
assign #0.2  IC2 = rst ? 0 : ((0|ST1_|g30304) ? 1'b0 : 1'bz);
// Gate A3-U226B
pullup(IC1);
assign #0.2  IC1 = rst ? 0 : ((0|ST0_|g30304) ? 1'b0 : 1'bz);
// Gate A3-U227B
pullup(g30304);
assign #0.2  g30304 = rst ? 1'bz : ((0|g30301|g30302) ? 1'b0 : 1'bz);
// Gate A3-U215B
pullup(IC7);
assign #0.2  IC7 = rst ? 0 : ((0|SQ4_|g30315) ? 1'b0 : 1'bz);
// Gate A3-U216B
pullup(IC6);
assign #0.2  IC6 = rst ? 0 : ((0|SQ3_|g30315) ? 1'b0 : 1'bz);
// Gate A3-U203B
pullup(IC5);
assign #0.2  IC5 = rst ? 0 : ((0|SQEXT|g30337|SQ5_) ? 1'b0 : 1'bz);
// Gate A3-U208A
pullup(IC4);
assign #0.2  IC4 = rst ? 0 : ((0|IC4_) ? 1'b0 : 1'bz);
// Gate A3-U257A
pullup(IC15_);
assign #0.2  IC15_ = rst ? 1'bz : ((0|BMF0|BZF0) ? 1'b0 : 1'bz);
// Gate A3-U134B
pullup(g30043);
assign #0.2  g30043 = rst ? 1'bz : ((0|g30036|g30018|g30031) ? 1'b0 : 1'bz);
// Gate A3-U239A
pullup(TCSAJ3_);
assign #0.2  TCSAJ3_ = rst ? 1'bz : ((0|TCSAJ3) ? 1'b0 : 1'bz);
// Gate A3-U157A
pullup(g30005);
assign #0.2  g30005 = rst ? 0 : ((0|g30003|STRTFC) ? 1'b0 : 1'bz);
// Gate A3-U160A
pullup(g30001);
assign #0.2  g30001 = rst ? 1'bz : ((0|g30002|NISQ) ? 1'b0 : 1'bz);
// Gate A3-U146B
pullup(g30037);
assign #0.2  g30037 = rst ? 0 : ((0|g30032|g30034|g30036) ? 1'b0 : 1'bz);
// Gate A3-U251B
pullup(MSU0_);
assign #0.2  MSU0_ = rst ? 1'bz : ((0|MSU0) ? 1'b0 : 1'bz);
// Gate A3-U237A A3-U237B
pullup(DAS0_);
assign #0.2  DAS0_ = rst ? 1'bz : ((0|DAS0) ? 1'b0 : 1'bz);
// Gate A3-U228B
pullup(SQ5QC0_);
assign #0.2  SQ5QC0_ = rst ? 1'bz : ((0|g30301) ? 1'b0 : 1'bz);
// Gate A3-U122A A3-U121A
pullup(QC0);
assign #0.2  QC0 = rst ? 0 : ((0|SQR11|SQR12) ? 1'b0 : 1'bz);
// Gate A3-U258B
pullup(IC16);
assign #0.2  IC16 = rst ? 0 : ((0|IC16_) ? 1'b0 : 1'bz);
// Gate A3-U135A
pullup(SQ6_);
assign #0.2  SQ6_ = rst ? 0 : ((0|g30043) ? 1'b0 : 1'bz);
// Gate A3-U222B
pullup(IC2_);
assign #0.2  IC2_ = rst ? 1'bz : ((0|IC2) ? 1'b0 : 1'bz);
// Gate A3-U147A A3-U145A
pullup(g30020);
assign #0.2  g30020 = rst ? 1'bz : ((0|g30015|SQR13) ? 1'b0 : 1'bz);
// Gate A3-U120A A3-U119A A3-U118A
pullup(QC0_);
assign #0.2  QC0_ = rst ? 1'bz : ((0|QC0) ? 1'b0 : 1'bz);
// Gate A3-U227A
pullup(TC0_);
assign #0.2  TC0_ = rst ? 1'bz : ((0|TC0) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
