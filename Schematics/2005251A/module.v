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

assign #0.2  SQ1_ = rst ? 0 : ~(0|U151Pad9);
assign #0.2  NDX0_ = rst ? 0 : ~(0|NDX0);
assign #0.2  NISQL_ = rst ? 0 : ~(0|U159Pad2);
assign #0.2  U121Pad8 = rst ? 0 : ~(0|U122Pad7|U119Pad8);
assign #0.2  SQ5 = rst ? 0 : ~(0|U133Pad9|U144Pad7|U143Pad7);
assign #0.2  IC12_ = rst ? 0 : ~(0|MSU0|CCS0);
assign #0.2  IC16 = rst ? 0 : ~(0|IC16_);
assign #0.2  J2Pad267 = rst ? 0 : ~(0);
assign #0.2  CSQG = rst ? 0 : ~(0|T12_|U150Pad4|CT_);
assign #0.2  MP1_ = rst ? 0 : ~(0|MP1);
assign #0.2  U129Pad8 = rst ? 0 : ~(0|GOJAM|MTCSAI);
assign #0.2  DAS0 = rst ? 0 : ~(0|QC0_|SQ2_|NEXST0_);
assign #0.2  IIP_ = rst ? 0 : ~(0|KRPT|IIP);
assign #0.2  U215Pad8 = rst ? 0 : ~(0|U217Pad8|NEXST0);
assign #0.2  IC5_ = rst ? 0 : ~(0|IC5);
assign #0.2  LXCH0 = rst ? 0 : ~(0|SQ2_|NEXST0_|QC1_);
assign #0.2  IC12 = rst ? 0 : ~(0|IC12_);
assign #0.2  QC3_ = rst ? 0 : ~(0|U102Pad2);
assign #0.2  TCSAJ3 = rst ? 0 : ~(0|SQ0_|SQEXT|ST3_);
assign #0.2  SCAS10 = rst ? 0 : ~(0|FS10|CON2);
assign #0.2  U256Pad1 = rst ? 0 : ~(0|BR2_|BZF0_);
assign #0.2  NDXX1 = rst ? 0 : ~(0|SQEXT_|SQ5_|ST1_);
assign #0.2  EXST1_ = rst ? 0 : ~(0|U217Pad8);
assign #0.2  NDX0 = rst ? 0 : ~(0|NEXST0_|SQ5_|QC0_);
assign #0.2  SQ0_ = rst ? 0 : ~(0|U146Pad9);
assign #0.2  U133Pad1 = rst ? 0 : ~(0|U132Pad2|INKL);
assign #0.2  INCR0 = rst ? 0 : ~(0|SQ2_|NEXST0_|QC2_);
assign #0.2  BZF0_ = rst ? 0 : ~(0|BZF0);
assign #0.2  U133Pad9 = rst ? 0 : ~(0|U133Pad1);
assign #0.2  T07 = rst ? 0 : ~(0|T07DC_|ODDSET_);
assign #0.2  U103Pad8 = rst ? 0 : ~(0|RPTSET|U105Pad9);
assign #0.2  IC13_ = rst ? 0 : ~(0|IC11|IC6|IC7|DCS0|IC1|DCA0);
assign #0.2  SQR10_ = rst ? 0 : ~(0|U123Pad2);
assign #0.2  SQR10 = rst ? 0 : ~(0|U124Pad2);
assign #0.2  SQR11 = rst ? 0 : ~(0|CSQG|U101Pad1);
assign #0.2  SQR12 = rst ? 0 : ~(0|U104Pad2|CSQG);
assign #0.2  SQR13 = rst ? 0 : ~(0|CSQG|U101Pad2|U144Pad7);
assign #0.2  SQR14 = rst ? 0 : ~(0|U134Pad7|U101Pad2|CSQG);
assign #0.2  SQR16 = rst ? 0 : ~(0|U101Pad2|U132Pad2|CSQG);
assign #0.2  RPTSET = rst ? 0 : ~(0|T12_|NISQL_|FUTEXT|OVNHRP|INHINT|IIP|PHS2_|MNHRPT|RUPTOR_);
assign #0.2  CON1 = rst ? 0 : ~(0|DBLTST);
assign #0.2  CON2 = rst ? 0 : ~(0|FS09|CON1);
assign #0.2  U117Pad8 = rst ? 0 : ~(0|U116Pad8|U119Pad9);
assign #0.2  U150Pad4 = rst ? 0 : ~(0|U156Pad2|STRTFC);
assign #0.2  U104Pad2 = rst ? 0 : ~(0|SQR12|U112Pad3|U101Pad2);
assign #0.2  J1Pad163 = rst ? 0 : ~(0);
assign #0.2  RSM3 = rst ? 0 : ~(0|SQEXT|ST3_|SQ5QC0_);
assign #0.2  U203Pad7 = rst ? 0 : ~(0|U204Pad7|U204Pad8);
assign #0.2  U115Pad2 = rst ? 0 : ~(0|U101Pad1|SQR12);
assign #0.2  TS0_ = rst ? 0 : ~(0|TS0);
assign #0.2  U119Pad8 = rst ? 0 : ~(0|STRTFC|U128Pad8);
assign #0.2  U151Pad9 = rst ? 0 : ~(0|U131Pad9|U143Pad7|U144Pad7);
assign #0.2  GOJ1 = rst ? 0 : ~(0|SQEXT|SQ0_|ST1_);
assign #0.2  QC2_ = rst ? 0 : ~(0|U105Pad2);
assign #0.2  U159Pad2 = rst ? 0 : ~(0|STRTFC|INKBT1|U158Pad2);
assign #0.2  SQR12_ = rst ? 0 : ~(0|SQR12);
assign #0.2  MINHL = rst ? 0 : ~(0|U113Pad2);
assign #0.2  IC10_ = rst ? 0 : ~(0|DXCH0|DAS0|IC4);
assign #0.2  SQEXT_ = rst ? 0 : ~(0|U117Pad8);
assign #0.2  U112Pad3 = rst ? 0 : ~(0|WSQG_|WL12_);
assign #0.2  MP0 = rst ? 0 : ~(0|SQ7_|SQEXT_|ST0_);
assign #0.2  MP1 = rst ? 0 : ~(0|ST1_|SQEXT_|SQ7_);
assign #0.2  IC4_ = rst ? 0 : ~(0|DCA0|DCS0);
assign #0.2  MIIP = rst ? 0 : ~(0|IIP_);
assign #0.2  TCF0 = rst ? 0 : ~(0|QC0|SQ1_|NEXST0_);
assign #0.2  MP0_ = rst ? 0 : ~(0|MP0);
assign #0.2  U131Pad1 = rst ? 0 : ~(0|INKL|SQR16);
assign #0.2  U131Pad9 = rst ? 0 : ~(0|U131Pad1);
assign #0.2  RPTFRC = rst ? 0 : ~(0|U103Pad8);
assign #0.2  U102Pad2 = rst ? 0 : ~(0|U104Pad2|U101Pad1);
assign #0.2  SQ3_ = rst ? 0 : ~(0|U155Pad9);
assign #0.2  U119Pad9 = rst ? 0 : ~(0|FUTEXT|U119Pad8);
assign #0.2  U113Pad2 = rst ? 0 : ~(0|INHPLS|INHINT);
assign #0.2  SQ2_ = rst ? 0 : ~(0|U136Pad9);
assign #0.2  U231Pad9 = rst ? 0 : ~(0|MASK0|RXOR0|MP0);
assign #0.2  U156Pad2 = rst ? 0 : ~(0|U158Pad2|U101Pad2|T12_);
assign #0.2  TC0 = rst ? 0 : ~(0|SQ0_|NEXST0_);
assign #0.2  DIM0_ = rst ? 0 : ~(0|DIM0);
assign #0.2  U116Pad8 = rst ? 0 : ~(0|RPTFRC|U117Pad8|U121Pad8);
assign #0.2  SQEXT = rst ? 0 : ~(0|U116Pad8);
assign #0.2  U157Pad9 = rst ? 0 : ~(0|U134Pad7|U133Pad9|U144Pad7);
assign #0.2  J3Pad334 = rst ? 0 : ~(0);
assign #0.2  U128Pad8 = rst ? 0 : ~(0|NISQL_|T12_);
assign #0.2  U138Pad1 = rst ? 0 : ~(0|WL14_|WSQG_);
assign #0.2  U146Pad9 = rst ? 0 : ~(0|U131Pad9|U143Pad7|U134Pad6);
assign #0.2  GOJ1_ = rst ? 0 : ~(0|GOJ1);
assign #0.2  MSU0 = rst ? 0 : ~(0|SQ2_|QC0_|EXST0_);
assign #0.2  U136Pad2 = rst ? 0 : ~(0|WL16_|WSQG_);
assign #0.2  IC7 = rst ? 0 : ~(0|SQ4_|U215Pad8);
assign #0.2  DAS1 = rst ? 0 : ~(0|DAS1_);
assign #0.2  U136Pad9 = rst ? 0 : ~(0|U134Pad6|U131Pad9|U134Pad7);
assign #0.2  TS0 = rst ? 0 : ~(0|SQ5_|QC2_|NEXST0_);
assign #0.2  U144Pad7 = rst ? 0 : ~(0|U143Pad1|SQR13);
assign #0.2  MASK0_ = rst ? 0 : ~(0|MASK0);
assign #0.2  IC9_ = rst ? 0 : ~(0|IC5|TS0|LXCH0|QXCH0);
assign #0.2  FUTEXT = rst ? 0 : ~(0|STRTFC|INKBT1|U122Pad7);
assign #0.2  IC16_ = rst ? 0 : ~(0|U256Pad1|U256Pad9);
assign #0.2  IC3 = rst ? 0 : ~(0|IC3_);
assign #0.2  MP3_ = rst ? 0 : ~(0|MP3);
assign #0.2  U123Pad2 = rst ? 0 : ~(0|U124Pad2|CSQG);
assign #0.2  QXCH0 = rst ? 0 : ~(0|QC1_|SQ2_|EXST0_);
assign #0.2  U204Pad8 = rst ? 0 : ~(0|ST0_|QC3_);
assign #0.2  RSM3_ = rst ? 0 : ~(0|RSM3);
assign #0.2  AD0 = rst ? 0 : ~(0|NEXST0_|SQ6_);
assign #0.2  AUG0_ = rst ? 0 : ~(0|AUG0);
assign #0.2  NDXX1_ = rst ? 0 : ~(0|NDXX1);
assign #0.2  DXCH0 = rst ? 0 : ~(0|NEXST0_|QC1_|SQ5_);
assign #0.2  U204Pad7 = rst ? 0 : ~(0|QC1_|ST1_);
assign #0.2  MSQ16 = rst ? 0 : ~(0|U132Pad2);
assign #0.2  DIM0 = rst ? 0 : ~(0|SQ2_|EXST0_|QC3_);
assign #0.2  MSQ14 = rst ? 0 : ~(0|U134Pad7);
assign #0.2  MSQ13 = rst ? 0 : ~(0|U144Pad7);
assign #0.2  MSQ12 = rst ? 0 : ~(0|U104Pad2);
assign #0.2  MSQ11 = rst ? 0 : ~(0|U101Pad1);
assign #0.2  MSQ10 = rst ? 0 : ~(0|U124Pad2);
assign #0.2  U101Pad2 = rst ? 0 : ~(0|U103Pad8);
assign #0.2  U101Pad3 = rst ? 0 : ~(0|WSQG_|WL11_);
assign #0.2  U101Pad1 = rst ? 0 : ~(0|U101Pad2|U101Pad3|SQR11);
assign #0.2  SQ5_ = rst ? 0 : ~(0|SQ5);
assign #0.2  MP3 = rst ? 0 : ~(0|SQ7_|ST3_|SQEXT_);
assign #0.2  U245Pad2 = rst ? 0 : ~(0|SQ2_|QC0_|ST1_|SQEXT);
assign #0.2  NEXST0 = rst ? 0 : ~(0|ST0_|SQEXT);
assign #0.2  IC8_ = rst ? 0 : ~(0|DXCH0|LXCH0);
assign #0.2  INHINT = rst ? 0 : ~(0|RELPLS|U113Pad2|GOJAM);
assign #0.2  MASK0 = rst ? 0 : ~(0|NEXST0_|SQ7_);
assign #0.2  TCSAJ3_ = rst ? 0 : ~(0|TCSAJ3);
assign #0.2  STRTFC = rst ? 0 : ~(0|U129Pad8);
assign #0.2  U227Pad7 = rst ? 0 : ~(0|SQ5_|QC0_);
assign #0.2  CCS0 = rst ? 0 : ~(0|SQ1_|NEXST0_|QC0_);
assign #0.2  IC17 = rst ? 0 : ~(0|IC16|IC15_);
assign #0.2  U219Pad7 = rst ? 0 : ~(0|ST0_|SQEXT_);
assign #0.2  IC15 = rst ? 0 : ~(0|IC15_);
assign #0.2  IC14 = rst ? 0 : ~(0|U231Pad9);
assign #0.2  IC13 = rst ? 0 : ~(0|IC13_);
assign #0.2  U227Pad8 = rst ? 0 : ~(0|SQ5_|SQEXT_);
assign #0.2  IC11 = rst ? 0 : ~(0|ST0_|U223Pad3|SQ6_);
assign #0.2  IC10 = rst ? 0 : ~(0|IC10_);
assign #0.2  WSQG_ = rst ? 0 : ~(0|U152Pad2);
assign #0.2  AUG0 = rst ? 0 : ~(0|EXST0_|QC2_|SQ2_);
assign #0.2  ADS0 = rst ? 0 : ~(0|QC3_|SQ2_|NEXST0_);
assign #0.2  MSQEXT = rst ? 0 : ~(0|U116Pad8);
assign #0.2  DCS0 = rst ? 0 : ~(0|SQ4_|EXST0_);
assign #0.2  J1Pad122 = rst ? 0 : ~(0);
assign #0.2  U134Pad9 = rst ? 0 : ~(0|U134Pad6|U134Pad7|U133Pad9);
assign #0.2  U154Pad2 = rst ? 0 : ~(0|U156Pad2);
assign #0.2  SU0 = rst ? 0 : ~(0|SQ6_|EXST0_|QC0_);
assign #0.2  RBSQ = rst ? 0 : ~(0|U154Pad2|RT_);
assign #0.2  U134Pad6 = rst ? 0 : ~(0|U144Pad7);
assign #0.2  U134Pad7 = rst ? 0 : ~(0|SQR14|U138Pad1);
assign #0.2  SQ4_ = rst ? 0 : ~(0|U143Pad9);
assign #0.2  BMF0 = rst ? 0 : ~(0|QC0|SQ6_|EXST0_);
assign #0.2  BZF0 = rst ? 0 : ~(0|EXST0_|QC0|SQ1_);
assign #0.2  QXCH0_ = rst ? 0 : ~(0|QXCH0);
assign #0.2  EXST0_ = rst ? 0 : ~(0|U219Pad7);
assign #0.2  BMF0_ = rst ? 0 : ~(0|BMF0);
assign #0.2  U105Pad9 = rst ? 0 : ~(0|T02|U103Pad8|STRTFC);
assign #0.2  NEXST0_ = rst ? 0 : ~(0|NEXST0);
assign #0.2  MTCSA_ = rst ? 0 : ~(0|TCSAJ3);
assign #0.2  U105Pad2 = rst ? 0 : ~(0|SQR11|U104Pad2);
assign #0.2  INKBT1 = rst ? 0 : ~(0|INKL|T01_);
assign #0.2  CCS0_ = rst ? 0 : ~(0|CCS0);
assign #0.2  IIP = rst ? 0 : ~(0|d5XP4|GOJAM|IIP_);
assign #0.2  U152Pad2 = rst ? 0 : ~(0|U154Pad2|WT_);
assign #0.2  IC6 = rst ? 0 : ~(0|SQ3_|U215Pad8);
assign #0.2  IC3_ = rst ? 0 : ~(0|TC0|STD2|TCF0);
assign #0.2  DAS1_ = rst ? 0 : ~(0|U245Pad2|ADS0);
assign #0.2  DCA0 = rst ? 0 : ~(0|SQ3_|EXST0_);
assign #0.2  IC9 = rst ? 0 : ~(0|IC9_);
assign #0.2  U143Pad7 = rst ? 0 : ~(0|U134Pad7);
assign #0.2  U143Pad1 = rst ? 0 : ~(0|WL13_|WSQG_);
assign #0.2  SQ7_ = rst ? 0 : ~(0|U157Pad9);
assign #0.2  QC1_ = rst ? 0 : ~(0|U115Pad2);
assign #0.2  IC2 = rst ? 0 : ~(0|ST1_|U223Pad8);
assign #0.2  IC1 = rst ? 0 : ~(0|ST0_|U223Pad8);
assign #0.2  U155Pad9 = rst ? 0 : ~(0|U131Pad9|U134Pad7|U144Pad7);
assign #0.2  U143Pad9 = rst ? 0 : ~(0|U133Pad9|U143Pad7|U134Pad6);
assign #0.2  IC5 = rst ? 0 : ~(0|SQEXT|U203Pad7|SQ5_);
assign #0.2  IC4 = rst ? 0 : ~(0|IC4_);
assign #0.2  IC15_ = rst ? 0 : ~(0|BMF0|BZF0);
assign #0.2  U223Pad3 = rst ? 0 : ~(0|QC0|SQEXT_);
assign #0.2  U132Pad2 = rst ? 0 : ~(0|U136Pad2|SQR16);
assign #0.2  U223Pad8 = rst ? 0 : ~(0|U227Pad7|U227Pad8);
assign #0.2  MSU0_ = rst ? 0 : ~(0|MSU0);
assign #0.2  DAS0_ = rst ? 0 : ~(0|DAS0);
assign #0.2  U122Pad7 = rst ? 0 : ~(0|FUTEXT|EXT|EXTPLS);
assign #0.2  SQ5QC0_ = rst ? 0 : ~(0|U227Pad7);
assign #0.2  QC0 = rst ? 0 : ~(0|SQR11|SQR12);
assign #0.2  U125Pad3 = rst ? 0 : ~(0|WSQG_|WL10_);
assign #0.2  U158Pad2 = rst ? 0 : ~(0|U159Pad2|NISQ);
assign #0.2  U217Pad8 = rst ? 0 : ~(0|ST1_|SQEXT_);
assign #0.2  SQ6_ = rst ? 0 : ~(0|U134Pad9);
assign #0.2  U124Pad2 = rst ? 0 : ~(0|U123Pad2|U125Pad3|U101Pad2);
assign #0.2  U256Pad9 = rst ? 0 : ~(0|BMF0_|BR1B2B);
assign #0.2  IC2_ = rst ? 0 : ~(0|IC2);
assign #0.2  QC0_ = rst ? 0 : ~(0|QC0);
assign #0.2  TC0_ = rst ? 0 : ~(0|TC0);

endmodule
