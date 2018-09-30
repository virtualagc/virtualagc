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

assign SQ1_ = rst ? 0 : ~(0|U151Pad9);
assign NDX0_ = rst ? 0 : ~(0|NDX0);
assign NISQL_ = rst ? 0 : ~(0|U159Pad2);
assign U121Pad8 = rst ? 0 : ~(0|U122Pad7|U119Pad8);
assign SQ5 = rst ? 0 : ~(0|U133Pad9|U144Pad7|U143Pad7);
assign IC12_ = rst ? 0 : ~(0|MSU0|CCS0);
assign IC16 = rst ? 0 : ~(0|IC16_);
assign J2Pad267 = rst ? 0 : ~(0);
assign CSQG = rst ? 0 : ~(0|T12_|U150Pad4|CT_);
assign MP1_ = rst ? 0 : ~(0|MP1);
assign U129Pad8 = rst ? 0 : ~(0|GOJAM|MTCSAI);
assign DAS0 = rst ? 0 : ~(0|QC0_|SQ2_|NEXST0_);
assign IIP_ = rst ? 0 : ~(0|KRPT|IIP);
assign U215Pad8 = rst ? 0 : ~(0|U217Pad8|NEXST0);
assign IC5_ = rst ? 0 : ~(0|IC5);
assign LXCH0 = rst ? 0 : ~(0|SQ2_|NEXST0_|QC1_);
assign IC12 = rst ? 0 : ~(0|IC12_);
assign QC3_ = rst ? 0 : ~(0|U102Pad2);
assign TCSAJ3 = rst ? 0 : ~(0|SQ0_|SQEXT|ST3_);
assign SCAS10 = rst ? 0 : ~(0|FS10|CON2);
assign U256Pad1 = rst ? 0 : ~(0|BR2_|BZF0_);
assign NDXX1 = rst ? 0 : ~(0|SQEXT_|SQ5_|ST1_);
assign EXST1_ = rst ? 0 : ~(0|U217Pad8);
assign NDX0 = rst ? 0 : ~(0|NEXST0_|SQ5_|QC0_);
assign SQ0_ = rst ? 0 : ~(0|U146Pad9);
assign U133Pad1 = rst ? 0 : ~(0|U132Pad2|INKL);
assign INCR0 = rst ? 0 : ~(0|SQ2_|NEXST0_|QC2_);
assign BZF0_ = rst ? 0 : ~(0|BZF0);
assign U133Pad9 = rst ? 0 : ~(0|U133Pad1);
assign T07 = rst ? 0 : ~(0|T07DC_|ODDSET_);
assign U103Pad8 = rst ? 0 : ~(0|RPTSET|U105Pad9);
assign IC13_ = rst ? 0 : ~(0|IC11|IC6|IC7|DCS0|IC1|DCA0);
assign SQR10_ = rst ? 0 : ~(0|U123Pad2);
assign SQR10 = rst ? 0 : ~(0|U124Pad2);
assign SQR11 = rst ? 0 : ~(0|CSQG|U101Pad1);
assign SQR12 = rst ? 0 : ~(0|U104Pad2|CSQG);
assign SQR13 = rst ? 0 : ~(0|CSQG|U101Pad2|U144Pad7);
assign SQR14 = rst ? 0 : ~(0|U134Pad7|U101Pad2|CSQG);
assign SQR16 = rst ? 0 : ~(0|U101Pad2|U132Pad2|CSQG);
assign RPTSET = rst ? 0 : ~(0|T12_|NISQL_|FUTEXT|OVNHRP|INHINT|IIP|PHS2_|MNHRPT|RUPTOR_);
assign CON1 = rst ? 0 : ~(0|DBLTST);
assign CON2 = rst ? 0 : ~(0|FS09|CON1);
assign U117Pad8 = rst ? 0 : ~(0|U116Pad8|U119Pad9);
assign U150Pad4 = rst ? 0 : ~(0|U156Pad2|STRTFC);
assign U104Pad2 = rst ? 0 : ~(0|SQR12|U112Pad3|U101Pad2);
assign J1Pad163 = rst ? 0 : ~(0);
assign RSM3 = rst ? 0 : ~(0|SQEXT|ST3_|SQ5QC0_);
assign U203Pad7 = rst ? 0 : ~(0|U204Pad7|U204Pad8);
assign U115Pad2 = rst ? 0 : ~(0|U101Pad1|SQR12);
assign TS0_ = rst ? 0 : ~(0|TS0);
assign U119Pad8 = rst ? 0 : ~(0|STRTFC|U128Pad8);
assign U151Pad9 = rst ? 0 : ~(0|U131Pad9|U143Pad7|U144Pad7);
assign GOJ1 = rst ? 0 : ~(0|SQEXT|SQ0_|ST1_);
assign QC2_ = rst ? 0 : ~(0|U105Pad2);
assign U159Pad2 = rst ? 0 : ~(0|STRTFC|INKBT1|U158Pad2);
assign SQR12_ = rst ? 0 : ~(0|SQR12);
assign MINHL = rst ? 0 : ~(0|U113Pad2);
assign IC10_ = rst ? 0 : ~(0|DXCH0|DAS0|IC4);
assign SQEXT_ = rst ? 0 : ~(0|U117Pad8);
assign U112Pad3 = rst ? 0 : ~(0|WSQG_|WL12_);
assign MP0 = rst ? 0 : ~(0|SQ7_|SQEXT_|ST0_);
assign MP1 = rst ? 0 : ~(0|ST1_|SQEXT_|SQ7_);
assign IC4_ = rst ? 0 : ~(0|DCA0|DCS0);
assign MIIP = rst ? 0 : ~(0|IIP_);
assign TCF0 = rst ? 0 : ~(0|QC0|SQ1_|NEXST0_);
assign MP0_ = rst ? 0 : ~(0|MP0);
assign U131Pad1 = rst ? 0 : ~(0|INKL|SQR16);
assign U131Pad9 = rst ? 0 : ~(0|U131Pad1);
assign RPTFRC = rst ? 0 : ~(0|U103Pad8);
assign U102Pad2 = rst ? 0 : ~(0|U104Pad2|U101Pad1);
assign SQ3_ = rst ? 0 : ~(0|U155Pad9);
assign U119Pad9 = rst ? 0 : ~(0|FUTEXT|U119Pad8);
assign U113Pad2 = rst ? 0 : ~(0|INHPLS|INHINT);
assign SQ2_ = rst ? 0 : ~(0|U136Pad9);
assign U231Pad9 = rst ? 0 : ~(0|MASK0|RXOR0|MP0);
assign U156Pad2 = rst ? 0 : ~(0|U158Pad2|U101Pad2|T12_);
assign TC0 = rst ? 0 : ~(0|SQ0_|NEXST0_);
assign DIM0_ = rst ? 0 : ~(0|DIM0);
assign U116Pad8 = rst ? 0 : ~(0|RPTFRC|U117Pad8|U121Pad8);
assign SQEXT = rst ? 0 : ~(0|U116Pad8);
assign U157Pad9 = rst ? 0 : ~(0|U134Pad7|U133Pad9|U144Pad7);
assign J3Pad334 = rst ? 0 : ~(0);
assign U128Pad8 = rst ? 0 : ~(0|NISQL_|T12_);
assign U138Pad1 = rst ? 0 : ~(0|WL14_|WSQG_);
assign U146Pad9 = rst ? 0 : ~(0|U131Pad9|U143Pad7|U134Pad6);
assign GOJ1_ = rst ? 0 : ~(0|GOJ1);
assign MSU0 = rst ? 0 : ~(0|SQ2_|QC0_|EXST0_);
assign U136Pad2 = rst ? 0 : ~(0|WL16_|WSQG_);
assign IC7 = rst ? 0 : ~(0|SQ4_|U215Pad8);
assign DAS1 = rst ? 0 : ~(0|DAS1_);
assign U136Pad9 = rst ? 0 : ~(0|U134Pad6|U131Pad9|U134Pad7);
assign TS0 = rst ? 0 : ~(0|SQ5_|QC2_|NEXST0_);
assign U144Pad7 = rst ? 0 : ~(0|U143Pad1|SQR13);
assign MASK0_ = rst ? 0 : ~(0|MASK0);
assign IC9_ = rst ? 0 : ~(0|IC5|TS0|LXCH0|QXCH0);
assign FUTEXT = rst ? 0 : ~(0|STRTFC|INKBT1|U122Pad7);
assign IC16_ = rst ? 0 : ~(0|U256Pad1|U256Pad9);
assign IC3 = rst ? 0 : ~(0|IC3_);
assign MP3_ = rst ? 0 : ~(0|MP3);
assign U123Pad2 = rst ? 0 : ~(0|U124Pad2|CSQG);
assign QXCH0 = rst ? 0 : ~(0|QC1_|SQ2_|EXST0_);
assign U204Pad8 = rst ? 0 : ~(0|ST0_|QC3_);
assign RSM3_ = rst ? 0 : ~(0|RSM3);
assign AD0 = rst ? 0 : ~(0|NEXST0_|SQ6_);
assign AUG0_ = rst ? 0 : ~(0|AUG0);
assign NDXX1_ = rst ? 0 : ~(0|NDXX1);
assign DXCH0 = rst ? 0 : ~(0|NEXST0_|QC1_|SQ5_);
assign U204Pad7 = rst ? 0 : ~(0|QC1_|ST1_);
assign MSQ16 = rst ? 0 : ~(0|U132Pad2);
assign DIM0 = rst ? 0 : ~(0|SQ2_|EXST0_|QC3_);
assign MSQ14 = rst ? 0 : ~(0|U134Pad7);
assign MSQ13 = rst ? 0 : ~(0|U144Pad7);
assign MSQ12 = rst ? 0 : ~(0|U104Pad2);
assign MSQ11 = rst ? 0 : ~(0|U101Pad1);
assign MSQ10 = rst ? 0 : ~(0|U124Pad2);
assign U101Pad2 = rst ? 0 : ~(0|U103Pad8);
assign U101Pad3 = rst ? 0 : ~(0|WSQG_|WL11_);
assign U101Pad1 = rst ? 0 : ~(0|U101Pad2|U101Pad3|SQR11);
assign SQ5_ = rst ? 0 : ~(0|SQ5);
assign MP3 = rst ? 0 : ~(0|SQ7_|ST3_|SQEXT_);
assign U245Pad2 = rst ? 0 : ~(0|SQ2_|QC0_|ST1_|SQEXT);
assign NEXST0 = rst ? 0 : ~(0|ST0_|SQEXT);
assign IC8_ = rst ? 0 : ~(0|DXCH0|LXCH0);
assign INHINT = rst ? 0 : ~(0|RELPLS|U113Pad2|GOJAM);
assign MASK0 = rst ? 0 : ~(0|NEXST0_|SQ7_);
assign TCSAJ3_ = rst ? 0 : ~(0|TCSAJ3);
assign STRTFC = rst ? 0 : ~(0|U129Pad8);
assign U227Pad7 = rst ? 0 : ~(0|SQ5_|QC0_);
assign CCS0 = rst ? 0 : ~(0|SQ1_|NEXST0_|QC0_);
assign IC17 = rst ? 0 : ~(0|IC16|IC15_);
assign U219Pad7 = rst ? 0 : ~(0|ST0_|SQEXT_);
assign IC15 = rst ? 0 : ~(0|IC15_);
assign IC14 = rst ? 0 : ~(0|U231Pad9);
assign IC13 = rst ? 0 : ~(0|IC13_);
assign U227Pad8 = rst ? 0 : ~(0|SQ5_|SQEXT_);
assign IC11 = rst ? 0 : ~(0|ST0_|U223Pad3|SQ6_);
assign IC10 = rst ? 0 : ~(0|IC10_);
assign WSQG_ = rst ? 0 : ~(0|U152Pad2);
assign AUG0 = rst ? 0 : ~(0|EXST0_|QC2_|SQ2_);
assign ADS0 = rst ? 0 : ~(0|QC3_|SQ2_|NEXST0_);
assign MSQEXT = rst ? 0 : ~(0|U116Pad8);
assign DCS0 = rst ? 0 : ~(0|SQ4_|EXST0_);
assign J1Pad122 = rst ? 0 : ~(0);
assign U134Pad9 = rst ? 0 : ~(0|U134Pad6|U134Pad7|U133Pad9);
assign U154Pad2 = rst ? 0 : ~(0|U156Pad2);
assign SU0 = rst ? 0 : ~(0|SQ6_|EXST0_|QC0_);
assign RBSQ = rst ? 0 : ~(0|U154Pad2|RT_);
assign U134Pad6 = rst ? 0 : ~(0|U144Pad7);
assign U134Pad7 = rst ? 0 : ~(0|SQR14|U138Pad1);
assign SQ4_ = rst ? 0 : ~(0|U143Pad9);
assign BMF0 = rst ? 0 : ~(0|QC0|SQ6_|EXST0_);
assign BZF0 = rst ? 0 : ~(0|EXST0_|QC0|SQ1_);
assign QXCH0_ = rst ? 0 : ~(0|QXCH0);
assign EXST0_ = rst ? 0 : ~(0|U219Pad7);
assign BMF0_ = rst ? 0 : ~(0|BMF0);
assign U105Pad9 = rst ? 0 : ~(0|T02|U103Pad8|STRTFC);
assign NEXST0_ = rst ? 0 : ~(0|NEXST0);
assign MTCSA_ = rst ? 0 : ~(0|TCSAJ3);
assign U105Pad2 = rst ? 0 : ~(0|SQR11|U104Pad2);
assign INKBT1 = rst ? 0 : ~(0|INKL|T01_);
assign CCS0_ = rst ? 0 : ~(0|CCS0);
assign IIP = rst ? 0 : ~(0|d5XP4|GOJAM|IIP_);
assign U152Pad2 = rst ? 0 : ~(0|U154Pad2|WT_);
assign IC6 = rst ? 0 : ~(0|SQ3_|U215Pad8);
assign IC3_ = rst ? 0 : ~(0|TC0|STD2|TCF0);
assign DAS1_ = rst ? 0 : ~(0|U245Pad2|ADS0);
assign DCA0 = rst ? 0 : ~(0|SQ3_|EXST0_);
assign IC9 = rst ? 0 : ~(0|IC9_);
assign U143Pad7 = rst ? 0 : ~(0|U134Pad7);
assign U143Pad1 = rst ? 0 : ~(0|WL13_|WSQG_);
assign SQ7_ = rst ? 0 : ~(0|U157Pad9);
assign QC1_ = rst ? 0 : ~(0|U115Pad2);
assign IC2 = rst ? 0 : ~(0|ST1_|U223Pad8);
assign IC1 = rst ? 0 : ~(0|ST0_|U223Pad8);
assign U155Pad9 = rst ? 0 : ~(0|U131Pad9|U134Pad7|U144Pad7);
assign U143Pad9 = rst ? 0 : ~(0|U133Pad9|U143Pad7|U134Pad6);
assign IC5 = rst ? 0 : ~(0|SQEXT|U203Pad7|SQ5_);
assign IC4 = rst ? 0 : ~(0|IC4_);
assign IC15_ = rst ? 0 : ~(0|BMF0|BZF0);
assign U223Pad3 = rst ? 0 : ~(0|QC0|SQEXT_);
assign U132Pad2 = rst ? 0 : ~(0|U136Pad2|SQR16);
assign U223Pad8 = rst ? 0 : ~(0|U227Pad7|U227Pad8);
assign MSU0_ = rst ? 0 : ~(0|MSU0);
assign DAS0_ = rst ? 0 : ~(0|DAS0);
assign U122Pad7 = rst ? 0 : ~(0|FUTEXT|EXT|EXTPLS);
assign SQ5QC0_ = rst ? 0 : ~(0|U227Pad7);
assign QC0 = rst ? 0 : ~(0|SQR11|SQR12);
assign U125Pad3 = rst ? 0 : ~(0|WSQG_|WL10_);
assign U158Pad2 = rst ? 0 : ~(0|U159Pad2|NISQ);
assign U217Pad8 = rst ? 0 : ~(0|ST1_|SQEXT_);
assign SQ6_ = rst ? 0 : ~(0|U134Pad9);
assign U124Pad2 = rst ? 0 : ~(0|U123Pad2|U125Pad3|U101Pad2);
assign U256Pad9 = rst ? 0 : ~(0|BMF0_|BR1B2B);
assign IC2_ = rst ? 0 : ~(0|IC2);
assign QC0_ = rst ? 0 : ~(0|QC0);
assign TC0_ = rst ? 0 : ~(0|TC0);

endmodule
