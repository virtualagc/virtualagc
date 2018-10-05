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

input wand rst, BR1B2B, BR2_, CGA3, CT_, DBLTST, EXT, EXTPLS, FS09, FS10,
  GOJAM, INHPLS, INKL, KRPT, MNHRPT, MTCSAI, NISQ, ODDSET_, OVNHRP, PHS2_,
  RELPLS, RT_, RUPTOR_, RXOR0, ST0_, ST1_, ST3_, STD2, T01_, T02, T07DC_,
  T12_, WL10_, WL11_, WL12_, WL13_, WL14_, WL16_, WT_, d5XP4;

inout wand CON1, CON2, EXST0_, INKBT1, MIIP, MINHL, MSQ10, MSQ11, MSQ12,
  MSQ13, MSQ14, MSQ16, MSQEXT, MTCSA_, NEXST0, QC0, QC0_, QC1_, QC2_, QC3_,
  RPTSET, SCAS10, SQ0_, SQ1_, SQ2_, SQ3_, SQ4_, SQ5, SQ6_, SQ7_, SQEXT, SQEXT_,
  T07, TCSAJ3, TS0;

output wand AD0, ADS0, AUG0, AUG0_, BMF0, BMF0_, BZF0, BZF0_, CCS0, CCS0_,
  CSQG, DAS0, DAS0_, DAS1, DAS1_, DCA0, DCS0, DIM0, DIM0_, DXCH0, EXST1_,
  FUTEXT, GOJ1, GOJ1_, IC1, IC10, IC10_, IC11, IC12, IC12_, IC13, IC13_,
  IC14, IC15, IC15_, IC16, IC16_, IC17, IC2, IC2_, IC3, IC3_, IC4, IC4_,
  IC5, IC5_, IC6, IC7, IC8_, IC9, IC9_, IIP, IIP_, INCR0, INHINT, LXCH0,
  MASK0, MASK0_, MP0, MP0_, MP1, MP1_, MP3, MP3_, MSU0, MSU0_, NDX0, NDX0_,
  NDXX1, NDXX1_, NEXST0_, NISQL_, QXCH0, QXCH0_, RBSQ, RPTFRC, RSM3, RSM3_,
  SQ5QC0_, SQ5_, SQR10, SQR10_, SQR11, SQR12, SQR12_, SQR13, SQR14, SQR16,
  STRTFC, SU0, TC0, TC0_, TCF0, TCSAJ3_, TS0_, WSQG_;

// Gate A3-U153B
assign #0.2  SQ1_ = rst ? 1 : ~(0|A3U151Pad9);
// Gate A3-U242A
assign #0.2  NDX0_ = rst ? 1 : ~(0|NDX0);
// Gate A3-U159A
assign #0.2  NISQL_ = rst ? 1 : ~(0|A3U159Pad2);
// Gate A3-U220B
assign #0.2  A3U219Pad7 = rst ? 0 : ~(0|ST0_|SQEXT_);
// Gate A3-U154B
assign #0.2  SQ5 = rst ? 0 : ~(0|A3U133Pad9|A3U144Pad7|A3U143Pad7);
// Gate A3-U252B
assign #0.2  IC12_ = rst ? 1 : ~(0|MSU0|CCS0);
// Gate A3-U117A
assign #0.2  A3U115Pad2 = rst ? 0 : ~(0|A3U101Pad1|SQR12);
// Gate A3-U218B
assign #0.2  A3U215Pad8 = rst ? 1 : ~(0|A3U217Pad8|NEXST0);
// Gate A3-U104B
assign #0.2  RPTFRC = rst ? 0 : ~(0|A3U103Pad8);
// Gate A3-U154A
assign #0.2  A3U152Pad2 = rst ? 0 : ~(0|A3U154Pad2|WT_);
// Gate A3-U151A A3-U150A
assign #0.2  CSQG = rst ? 0 : ~(0|T12_|A3U150Pad4|CT_);
// Gate A3-U137A
assign #0.2  A3U136Pad2 = rst ? 0 : ~(0|WL16_|WSQG_);
// Gate A3-U104A
assign #0.2  A3U102Pad2 = rst ? 0 : ~(0|A3U104Pad2|A3U101Pad1);
// Gate A3-U101B
assign #0.2  A3J2Pad267 = rst ? 1 : ~(0);
// Gate A3-U112B
assign #0.2  IIP_ = rst ? 1 : ~(0|KRPT|IIP);
// Gate A3-U103B
assign #0.2  A3U101Pad2 = rst ? 0 : ~(0|A3U103Pad8);
// Gate A3-U129A
assign #0.2  A3U101Pad3 = rst ? 0 : ~(0|WSQG_|WL11_);
// Gate A3-U202B
assign #0.2  IC5_ = rst ? 1 : ~(0|IC5);
// Gate A3-U212B
assign #0.2  LXCH0 = rst ? 0 : ~(0|SQ2_|NEXST0_|QC1_);
// Gate A3-U103A A3-U102A
assign #0.2  QC3_ = rst ? 1 : ~(0|A3U102Pad2);
// Gate A3-U136A
assign #0.2  A3U132Pad2 = rst ? 1 : ~(0|A3U136Pad2|SQR16);
// Gate A3-U132B
assign #0.2  SCAS10 = rst ? 1 : ~(0|FS10|CON2);
// Gate A3-U216A
assign #0.2  A3J3Pad334 = rst ? 1 : ~(0);
// Gate A3-U241A
assign #0.2  NDXX1 = rst ? 0 : ~(0|SQEXT_|SQ5_|ST1_);
// Gate A3-U230B
assign #0.2  A3U227Pad7 = rst ? 0 : ~(0|SQ5_|QC0_);
// Gate A3-U243A
assign #0.2  NDX0 = rst ? 0 : ~(0|NEXST0_|SQ5_|QC0_);
// Gate A3-U150B A3-U149B
assign #0.2  SQ0_ = rst ? 1 : ~(0|A3U146Pad9);
// Gate A3-U149A
assign #0.2  CON1 = rst ? 1 : ~(0|DBLTST);
// Gate A3-U254A
assign #0.2  BZF0_ = rst ? 1 : ~(0|BZF0);
// Gate A3-U229B
assign #0.2  A3U227Pad8 = rst ? 0 : ~(0|SQ5_|SQEXT_);
// Gate A3-U102B
assign #0.2  T07 = rst ? 0 : ~(0|T07DC_|ODDSET_);
// Gate A3-U224A
assign #0.2  IC3 = rst ? 0 : ~(0|IC3_);
// Gate A3-U221A A3-U209A
assign #0.2  IC13_ = rst ? 1 : ~(0|IC11|IC6|IC7|DCS0|IC1|DCA0);
// Gate A3-U123A
assign #0.2  SQR10_ = rst ? 0 : ~(0|A3U123Pad2);
// Gate A3-U126A
assign #0.2  SQR10 = rst ? 1 : ~(0|A3U124Pad2);
// Gate A3-U109A
assign #0.2  SQR11 = rst ? 0 : ~(0|CSQG|A3U101Pad1);
// Gate A3-U114A
assign #0.2  SQR12 = rst ? 1 : ~(0|A3U104Pad2|CSQG);
// Gate A3-U146A
assign #0.2  SQR13 = rst ? 0 : ~(0|CSQG|A3U101Pad2|A3U144Pad7);
// Gate A3-U140A
assign #0.2  SQR14 = rst ? 0 : ~(0|A3U134Pad7|A3U101Pad2|CSQG);
// Gate A3-U135B
assign #0.2  SQR16 = rst ? 0 : ~(0|A3U101Pad2|A3U132Pad2|CSQG);
// Gate A3-U111A A3-U111B A3-U109B
assign #0.2  RPTSET = rst ? 0 : ~(0|T12_|NISQL_|FUTEXT|OVNHRP|INHINT|IIP|PHS2_|MNHRPT|RUPTOR_);
// Gate A3-U128A
assign #0.2  A3U125Pad3 = rst ? 0 : ~(0|WSQG_|WL10_);
// Gate A3-U159B
assign #0.2  CON2 = rst ? 0 : ~(0|FS09|CON1);
// Gate A3-U256B
assign #0.2  A3U256Pad9 = rst ? 0 : ~(0|BMF0_|BR1B2B);
// Gate A3-U236B
assign #0.2  RSM3 = rst ? 0 : ~(0|SQEXT|ST3_|SQ5QC0_);
// Gate A3-U219A A3-U220A
assign #0.2  TS0_ = rst ? 1 : ~(0|TS0);
// Gate A3-U147B
assign #0.2  A3U134Pad6 = rst ? 0 : ~(0|A3U144Pad7);
// Gate A3-U142A A3-U141A
assign #0.2  A3U134Pad7 = rst ? 1 : ~(0|SQR14|A3U138Pad1);
// Gate A3-U134A
assign #0.2  A3J1Pad163 = rst ? 1 : ~(0);
// Gate A3-U244A
assign #0.2  DAS1 = rst ? 0 : ~(0|DAS1_);
// Gate A3-U133A
assign #0.2  A3U133Pad1 = rst ? 0 : ~(0|A3U132Pad2|INKL);
// Gate A3-U239B
assign #0.2  GOJ1 = rst ? 0 : ~(0|SQEXT|SQ0_|ST1_);
// Gate A3-U105A
assign #0.2  QC2_ = rst ? 0 : ~(0|A3U105Pad2);
// Gate A3-U133B
assign #0.2  A3U133Pad9 = rst ? 1 : ~(0|A3U133Pad1);
// Gate A3-U107B
assign #0.2  SQR12_ = rst ? 0 : ~(0|SQR12);
// Gate A3-U113A
assign #0.2  MINHL = rst ? 0 : ~(0|A3U113Pad2);
// Gate A3-U121B
assign #0.2  A3U116Pad8 = rst ? 1 : ~(0|RPTFRC|A3U117Pad8|A3U121Pad8);
// Gate A3-U212A
assign #0.2  IC10_ = rst ? 1 : ~(0|DXCH0|DAS0|IC4);
// Gate A3-U118B A3-U117B
assign #0.2  SQEXT_ = rst ? 1 : ~(0|A3U117Pad8);
// Gate A3-U131A
assign #0.2  A3U131Pad1 = rst ? 0 : ~(0|INKL|SQR16);
// Gate A3-U204B
assign #0.2  A3U203Pad7 = rst ? 1 : ~(0|A3U204Pad7|A3U204Pad8);
// Gate A3-U130B
assign #0.2  A3U129Pad8 = rst ? 0 : ~(0|GOJAM|MTCSAI);
// Gate A3-U240A
assign #0.2  MP1 = rst ? 0 : ~(0|ST1_|SQEXT_|SQ7_);
// Gate A3-U210A
assign #0.2  IC4_ = rst ? 1 : ~(0|DCA0|DCS0);
// Gate A3-U131B
assign #0.2  A3U131Pad9 = rst ? 1 : ~(0|A3U131Pad1);
// Gate A3-U113B
assign #0.2  MIIP = rst ? 0 : ~(0|IIP_);
// Gate A3-U225A
assign #0.2  TCF0 = rst ? 0 : ~(0|QC0|SQ1_|NEXST0_);
// Gate A3-U234A A3-U234B
assign #0.2  MP0_ = rst ? 1 : ~(0|MP0);
// Gate A3-U119B
assign #0.2  A3U119Pad9 = rst ? 1 : ~(0|FUTEXT|A3U119Pad8);
// Gate A3-U128B
assign #0.2  A3U119Pad8 = rst ? 0 : ~(0|STRTFC|A3U128Pad8);
// Gate A3-U156B
assign #0.2  SQ3_ = rst ? 1 : ~(0|A3U155Pad9);
// Gate A3-U140B A3-U138B A3-U137B
assign #0.2  SQ2_ = rst ? 1 : ~(0|A3U136Pad9);
// Gate A3-U124A
assign #0.2  A3U123Pad2 = rst ? 1 : ~(0|A3U124Pad2|CSQG);
// Gate A3-U248A
assign #0.2  DIM0_ = rst ? 1 : ~(0|DIM0);
// Gate A3-U126B
assign #0.2  A3U122Pad7 = rst ? 1 : ~(0|FUTEXT|EXT|EXTPLS);
// Gate A3-U228A
assign #0.2  TC0 = rst ? 0 : ~(0|SQ0_|NEXST0_);
// Gate A3-U124B A3-U116B
assign #0.2  SQEXT = rst ? 0 : ~(0|A3U116Pad8);
// Gate A3-U241B
assign #0.2  MP1_ = rst ? 1 : ~(0|MP1);
// Gate A3-U110A
assign #0.2  A3U103Pad8 = rst ? 1 : ~(0|RPTSET|A3U105Pad9);
// Gate A3-U240B
assign #0.2  GOJ1_ = rst ? 1 : ~(0|GOJ1);
// Gate A3-U251A
assign #0.2  MSU0 = rst ? 0 : ~(0|SQ2_|QC0_|EXST0_);
// Gate A3-U214B A3-U213B
assign #0.2  DAS0 = rst ? 0 : ~(0|QC0_|SQ2_|NEXST0_);
// Gate A3-U101A
assign #0.2  A3U101Pad1 = rst ? 1 : ~(0|A3U101Pad2|A3U101Pad3|SQR11);
// Gate A3-U218A
assign #0.2  TS0 = rst ? 0 : ~(0|SQ5_|QC2_|NEXST0_);
// Gate A3-U136B
assign #0.2  A3U136Pad9 = rst ? 0 : ~(0|A3U134Pad6|A3U131Pad9|A3U134Pad7);
// Gate A3-U255B
assign #0.2  BMF0 = rst ? 0 : ~(0|QC0|SQ6_|EXST0_);
// Gate A3-U207B A3-U209B
assign #0.2  IC9_ = rst ? 1 : ~(0|IC5|TS0|LXCH0|QXCH0);
// Gate A3-U222A A3-U259A A3-U233A A3-U260A
assign #0.2  A3 = rst ? 1 : ~(0);
// Gate A3-U125B
assign #0.2  FUTEXT = rst ? 0 : ~(0|STRTFC|INKBT1|A3U122Pad7);
// Gate A3-U257B
assign #0.2  IC16_ = rst ? 1 : ~(0|A3U256Pad1|A3U256Pad9);
// Gate A3-U23B
assign #0.2  A3U128Pad8 = rst ? 0 : ~(0|NISQL_|T12_);
// Gate A3-U35A A3-U236A
assign #0.2  MP3_ = rst ? 1 : ~(0|MP3);
// Gate A3-U256A
assign #0.2  A3U256Pad1 = rst ? 0 : ~(0|BR2_|BZF0_);
// Gate A3-U211B
assign #0.2  QXCH0 = rst ? 0 : ~(0|QC1_|SQ2_|EXST0_);
// Gate A3-U221B
assign #0.2  A3U217Pad8 = rst ? 0 : ~(0|ST1_|SQEXT_);
// Gate A3-U217A
assign #0.2  DCA0 = rst ? 0 : ~(0|SQ3_|EXST0_);
// Gate A3-U156A
assign #0.2  A3U154Pad2 = rst ? 1 : ~(0|A3U156Pad2);
// Gate A3-U238B
assign #0.2  RSM3_ = rst ? 1 : ~(0|RSM3);
// Gate A3-U243B
assign #0.2  AD0 = rst ? 0 : ~(0|NEXST0_|SQ6_);
// Gate A3-U249B
assign #0.2  AUG0_ = rst ? 1 : ~(0|AUG0);
// Gate A3-U242B
assign #0.2  NDXX1_ = rst ? 1 : ~(0|NDXX1);
// Gate A3-U214A A3-U213A
assign #0.2  DXCH0 = rst ? 0 : ~(0|NEXST0_|QC1_|SQ5_);
// Gate A3-U115B
assign #0.2  A3U113Pad2 = rst ? 1 : ~(0|INHPLS|INHINT);
// Gate A3-U132A
assign #0.2  MSQ16 = rst ? 0 : ~(0|A3U132Pad2);
// Gate A3-U249A
assign #0.2  DIM0 = rst ? 0 : ~(0|SQ2_|EXST0_|QC3_);
// Gate A3-U144A
assign #0.2  MSQ14 = rst ? 0 : ~(0|A3U134Pad7);
// Gate A3-U144B
assign #0.2  MSQ13 = rst ? 0 : ~(0|A3U144Pad7);
// Gate A3-U108B
assign #0.2  MSQ12 = rst ? 1 : ~(0|A3U104Pad2);
// Gate A3-U108A
assign #0.2  MSQ11 = rst ? 0 : ~(0|A3U101Pad1);
// Gate A3-U127A
assign #0.2  MSQ10 = rst ? 1 : ~(0|A3U124Pad2);
// Gate A3-U238A
assign #0.2  TCSAJ3 = rst ? 0 : ~(0|SQ0_|SQEXT|ST3_);
// Gate A3-U250B
assign #0.2  AUG0 = rst ? 0 : ~(0|EXST0_|QC2_|SQ2_);
// Gate A3-U230A A3-U229A
assign #0.2  SQ5_ = rst ? 1 : ~(0|SQ5);
// Gate A3-U158A
assign #0.2  A3U156Pad2 = rst ? 0 : ~(0|A3U158Pad2|A3U101Pad2|T12_);
// Gate A3-U232A
assign #0.2  MASK0_ = rst ? 1 : ~(0|MASK0);
// Gate A3-U235B
assign #0.2  MP3 = rst ? 0 : ~(0|SQ7_|ST3_|SQEXT_);
// Gate A3-U105B
assign #0.2  A3U105Pad9 = rst ? 0 : ~(0|T02|A3U103Pad8|STRTFC);
// Gate A3-U203A
assign #0.2  NEXST0 = rst ? 0 : ~(0|ST0_|SQEXT);
// Gate A3-U130A
assign #0.2  A3U112Pad3 = rst ? 0 : ~(0|WSQG_|WL12_);
// Gate A3-U208B
assign #0.2  IC8_ = rst ? 1 : ~(0|DXCH0|LXCH0);
// Gate A3-U114B
assign #0.2  INHINT = rst ? 0 : ~(0|RELPLS|A3U113Pad2|GOJAM);
// Gate A3-U231A
assign #0.2  MASK0 = rst ? 0 : ~(0|NEXST0_|SQ7_);
// Gate A3-U107A
assign #0.2  A3U105Pad2 = rst ? 1 : ~(0|SQR11|A3U104Pad2);
// Gate A3-U129B
assign #0.2  STRTFC = rst ? 1 : ~(0|A3U129Pad8);
// Gate A3-U120B
assign #0.2  A3U117Pad8 = rst ? 0 : ~(0|A3U116Pad8|A3U119Pad9);
// Gate A3-U253A
assign #0.2  CCS0 = rst ? 0 : ~(0|SQ1_|NEXST0_|QC0_);
// Gate A3-U138A
assign #0.2  A3U138Pad1 = rst ? 0 : ~(0|WL14_|WSQG_);
// Gate A3-U112A
assign #0.2  A3U104Pad2 = rst ? 0 : ~(0|SQR12|A3U112Pad3|A3U101Pad2);
// Gate A3-U258A
assign #0.2  IC17 = rst ? 0 : ~(0|IC16|IC15_);
// Gate A3-U160B
assign #0.2  A3U159Pad2 = rst ? 0 : ~(0|STRTFC|INKBT1|A3U158Pad2);
// Gate A3-U259B
assign #0.2  IC15 = rst ? 0 : ~(0|IC15_);
// Gate A3-U232B
assign #0.2  IC14 = rst ? 0 : ~(0|A3U231Pad9);
// Gate A3-U207A
assign #0.2  IC13 = rst ? 0 : ~(0|IC13_);
// Gate A3-U252A
assign #0.2  IC12 = rst ? 0 : ~(0|IC12_);
// Gate A3-U223A
assign #0.2  IC11 = rst ? 0 : ~(0|ST0_|A3U223Pad3|SQ6_);
// Gate A3-U211A
assign #0.2  IC10 = rst ? 0 : ~(0|IC10_);
// Gate A3-U152A A3-U153A
assign #0.2  WSQG_ = rst ? 1 : ~(0|A3U152Pad2);
// Gate A3-U41B
assign #0.2  A3U143Pad7 = rst ? 0 : ~(0|A3U134Pad7);
// Gate A3-U231B
assign #0.2  A3U231Pad9 = rst ? 1 : ~(0|MASK0|RXOR0|MP0);
// Gate A3-U248B
assign #0.2  ADS0 = rst ? 0 : ~(0|QC3_|SQ2_|NEXST0_);
// Gate A3-U143A
assign #0.2  A3U143Pad1 = rst ? 0 : ~(0|WL13_|WSQG_);
// Gate A3-U127B
assign #0.2  MSQEXT = rst ? 0 : ~(0|A3U116Pad8);
// Gate A3-U215A
assign #0.2  DCS0 = rst ? 0 : ~(0|SQ4_|EXST0_);
// Gate A3-U143B
assign #0.2  A3U143Pad9 = rst ? 0 : ~(0|A3U133Pad9|A3U143Pad7|A3U134Pad6);
// Gate A3-U244B
assign #0.2  SU0 = rst ? 0 : ~(0|SQ6_|EXST0_|QC0_);
// Gate A3-U155A
assign #0.2  RBSQ = rst ? 0 : ~(0|A3U154Pad2|RT_);
// Gate A3-U152B
assign #0.2  A3J1Pad122 = rst ? 1 : ~(0);
// Gate A3-U122B
assign #0.2  A3U121Pad8 = rst ? 0 : ~(0|A3U122Pad7|A3U119Pad8);
// Gate A3-U145B
assign #0.2  SQ4_ = rst ? 1 : ~(0|A3U143Pad9);
// Gate A3-U217B
assign #0.2  EXST1_ = rst ? 1 : ~(0|A3U217Pad8);
// Gate A3-U254B
assign #0.2  BZF0 = rst ? 0 : ~(0|EXST0_|QC0|SQ1_);
// Gate A3-U233B
assign #0.2  MP0 = rst ? 0 : ~(0|SQ7_|SQEXT_|ST0_);
// Gate A3-U157B
assign #0.2  A3U157Pad9 = rst ? 0 : ~(0|A3U134Pad7|A3U133Pad9|A3U144Pad7);
// Gate A3-U219B A3-U260B
assign #0.2  EXST0_ = rst ? 1 : ~(0|A3U219Pad7);
// Gate A3-U255A
assign #0.2  BMF0_ = rst ? 1 : ~(0|BMF0);
// Gate A3-U205B
assign #0.2  A3U204Pad8 = rst ? 0 : ~(0|ST0_|QC3_);
// Gate A3-U210B
assign #0.2  QXCH0_ = rst ? 1 : ~(0|QXCH0);
// Gate A3-U205A A3-U204A A3-U202A
assign #0.2  NEXST0_ = rst ? 1 : ~(0|NEXST0);
// Gate A3-U206A
assign #0.2  A3U204Pad7 = rst ? 0 : ~(0|QC1_|ST1_);
// Gate A3-U151B
assign #0.2  A3U151Pad9 = rst ? 0 : ~(0|A3U131Pad9|A3U143Pad7|A3U144Pad7);
// Gate A3-U246B
assign #0.2  MTCSA_ = rst ? 1 : ~(0|TCSAJ3);
// Gate A3-U142B
assign #0.2  INKBT1 = rst ? 0 : ~(0|INKL|T01_);
// Gate A3-U253B A3-U247A
assign #0.2  CCS0_ = rst ? 1 : ~(0|CCS0);
// Gate A3-U125A
assign #0.2  A3U124Pad2 = rst ? 0 : ~(0|A3U123Pad2|A3U125Pad3|A3U101Pad2);
// Gate A3-U110B
assign #0.2  IIP = rst ? 0 : ~(0|d5XP4|GOJAM|IIP_);
// Gate A3-U226A
assign #0.2  IC3_ = rst ? 1 : ~(0|TC0|STD2|TCF0);
// Gate A3-U250A
assign #0.2  INCR0 = rst ? 0 : ~(0|SQ2_|NEXST0_|QC2_);
// Gate A3-U155B
assign #0.2  A3U155Pad9 = rst ? 0 : ~(0|A3U131Pad9|A3U134Pad7|A3U144Pad7);
// Gate A3-U245A A3-U245B
assign #0.2  DAS1_ = rst ? 1 : ~(0|A3U245Pad2|ADS0);
// Gate A3-U225B
assign #0.2  A3U223Pad3 = rst ? 0 : ~(0|QC0|SQEXT_);
// Gate A3-U247B A3-U246A
assign #0.2  A3U245Pad2 = rst ? 0 : ~(0|SQ2_|QC0_|ST1_|SQEXT);
// Gate A3-U206B
assign #0.2  IC9 = rst ? 0 : ~(0|IC9_);
// Gate A3-U158B
assign #0.2  SQ7_ = rst ? 1 : ~(0|A3U157Pad9);
// Gate A3-U116A A3-U115A
assign #0.2  QC1_ = rst ? 1 : ~(0|A3U115Pad2);
// Gate A3-U224B A3-U223B
assign #0.2  IC2 = rst ? 0 : ~(0|ST1_|A3U223Pad8);
// Gate A3-U226B
assign #0.2  IC1 = rst ? 0 : ~(0|ST0_|A3U223Pad8);
// Gate A3-U227B
assign #0.2  A3U223Pad8 = rst ? 1 : ~(0|A3U227Pad7|A3U227Pad8);
// Gate A3-U215B
assign #0.2  IC7 = rst ? 0 : ~(0|SQ4_|A3U215Pad8);
// Gate A3-U216B
assign #0.2  IC6 = rst ? 0 : ~(0|SQ3_|A3U215Pad8);
// Gate A3-U203B
assign #0.2  IC5 = rst ? 0 : ~(0|SQEXT|A3U203Pad7|SQ5_);
// Gate A3-U208A
assign #0.2  IC4 = rst ? 0 : ~(0|IC4_);
// Gate A3-U257A
assign #0.2  IC15_ = rst ? 1 : ~(0|BMF0|BZF0);
// Gate A3-U134B
assign #0.2  A3U134Pad9 = rst ? 0 : ~(0|A3U134Pad6|A3U134Pad7|A3U133Pad9);
// Gate A3-U239A
assign #0.2  TCSAJ3_ = rst ? 1 : ~(0|TCSAJ3);
// Gate A3-U157A
assign #0.2  A3U150Pad4 = rst ? 0 : ~(0|A3U156Pad2|STRTFC);
// Gate A3-U160A
assign #0.2  A3U158Pad2 = rst ? 1 : ~(0|A3U159Pad2|NISQ);
// Gate A3-U146B
assign #0.2  A3U146Pad9 = rst ? 0 : ~(0|A3U131Pad9|A3U143Pad7|A3U134Pad6);
// Gate A3-U251B
assign #0.2  MSU0_ = rst ? 1 : ~(0|MSU0);
// Gate A3-U237A A3-U237B
assign #0.2  DAS0_ = rst ? 1 : ~(0|DAS0);
// Gate A3-U228B
assign #0.2  SQ5QC0_ = rst ? 1 : ~(0|A3U227Pad7);
// Gate A3-U122A A3-U121A
assign #0.2  QC0 = rst ? 0 : ~(0|SQR11|SQR12);
// Gate A3-U258B
assign #0.2  IC16 = rst ? 0 : ~(0|IC16_);
// Gate A3-U135A
assign #0.2  SQ6_ = rst ? 1 : ~(0|A3U134Pad9);
// Gate A3-U222B
assign #0.2  IC2_ = rst ? 1 : ~(0|IC2);
// Gate A3-U147A A3-U145A
assign #0.2  A3U144Pad7 = rst ? 1 : ~(0|A3U143Pad1|SQR13);
// Gate A3-U120A A3-U119A A3-U118A
assign #0.2  QC0_ = rst ? 1 : ~(0|QC0);
// Gate A3-U227A
assign #0.2  TC0_ = rst ? 1 : ~(0|TC0);

endmodule
