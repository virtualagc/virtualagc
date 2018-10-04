// Verilog module auto-generated for AGC module A15 by dumbVerilog.py

module A15 ( 
  rst, C32M, C32P, C33M, C33P, C34M, C34P, C35M, C35P, C36M, C36P, C37M,
  C40M, C41M, C42M, C43M, C44M, CA2_, CA3_, CAD1, CAD2, CAD3, CEBG, CFBG,
  CGA15, DLKPLS, E5, E6, E7_, GOJAM, HNDRPT, INCSET_, KRPT, KYRPT1, KYRPT2,
  MKRPT, OVF_, R6, RADRPT, RB1F, RBBEG_, REBG_, RFBG_, RRPA, RSTRT, S10,
  S10_, S11_, S12_, STRGAT, SUMA01_, SUMA02_, SUMA03_, SUMA11_, SUMA12_,
  SUMA13_, SUMA14_, SUMA16_, SUMB01_, SUMB02_, SUMB03_, SUMB11_, SUMB12_,
  SUMB13_, SUMB14_, SUMB16_, T10, T12A, U2BBKG_, UPRUPT, WBBEG_, WEBG_, WFBG_,
  WL01_, WL02_, WL03_, WL09_, WL10_, WL11_, WL12_, WL13_, WL14_, WL16_, WOVR,
  XB0_, XB1_, XB4_, XB6_, XB7_, XT0_, XT1_, XT2_, XT3_, XT4_, XT5_, ZOUT_,
  BBK1, BBK2, BBK3, DNRPTA, F11, F11_, F12, F12_, F13, F13_, F14, F14_, F15,
  F15_, F16, F16_, HIMOD, KRPTA_, LOMOD, PRPOR1, PRPOR2, PRPOR3, PRPOR4,
  RL01_, RL02_, RL03_, RL09_, RL10_, RL11_, RL12_, RL13_, RL14_, RL16_, ROPER,
  ROPES, ROPET, RPTA12, RPTAD3, RRPA1_, STR14, STR19, STR210, STR311, STR412,
  STR58, STR912, BK16, DRPRST, EB10, EB10_, EB11, EB11_, EB9, EB9_, FB11,
  FB11_, FB12, FB12_, FB13, FB13_, FB14, FB14_, FB16, FB16_, KY1RST, KY2RST,
  MCDU, MCDU_, MINC, MINC_, PCDU, PCDU_, RPTAD4, RPTAD5, RPTAD6, RUPTOR_,
  T6RPT, WOVR_
);

input wire rst, C32M, C32P, C33M, C33P, C34M, C34P, C35M, C35P, C36M, C36P,
  C37M, C40M, C41M, C42M, C43M, C44M, CA2_, CA3_, CAD1, CAD2, CAD3, CEBG,
  CFBG, CGA15, DLKPLS, E5, E6, E7_, GOJAM, HNDRPT, INCSET_, KRPT, KYRPT1,
  KYRPT2, MKRPT, OVF_, R6, RADRPT, RB1F, RBBEG_, REBG_, RFBG_, RRPA, RSTRT,
  S10, S10_, S11_, S12_, STRGAT, SUMA01_, SUMA02_, SUMA03_, SUMA11_, SUMA12_,
  SUMA13_, SUMA14_, SUMA16_, SUMB01_, SUMB02_, SUMB03_, SUMB11_, SUMB12_,
  SUMB13_, SUMB14_, SUMB16_, T10, T12A, U2BBKG_, UPRUPT, WBBEG_, WEBG_, WFBG_,
  WL01_, WL02_, WL03_, WL09_, WL10_, WL11_, WL12_, WL13_, WL14_, WL16_, WOVR,
  XB0_, XB1_, XB4_, XB6_, XB7_, XT0_, XT1_, XT2_, XT3_, XT4_, XT5_, ZOUT_;

inout wire BBK1, BBK2, BBK3, DNRPTA, F11, F11_, F12, F12_, F13, F13_, F14,
  F14_, F15, F15_, F16, F16_, HIMOD, KRPTA_, LOMOD, PRPOR1, PRPOR2, PRPOR3,
  PRPOR4, RL01_, RL02_, RL03_, RL09_, RL10_, RL11_, RL12_, RL13_, RL14_,
  RL16_, ROPER, ROPES, ROPET, RPTA12, RPTAD3, RRPA1_, STR14, STR19, STR210,
  STR311, STR412, STR58, STR912;

output wire BK16, DRPRST, EB10, EB10_, EB11, EB11_, EB9, EB9_, FB11, FB11_,
  FB12, FB12_, FB13, FB13_, FB14, FB14_, FB16, FB16_, KY1RST, KY2RST, MCDU,
  MCDU_, MINC, MINC_, PCDU, PCDU_, RPTAD4, RPTAD5, RPTAD6, RUPTOR_, T6RPT,
  WOVR_;

// Gate A15-U260B
pullup(A15U259Pad2);
assign (highz1,strong0) #0.2  A15U259Pad2 = rst ? 0 : ~(0|WOVR_|OVF_);
// Gate A15-U121A A15-U124A
pullup(EB9_);
assign (highz1,strong0) #0.2  EB9_ = rst ? 0 : ~(0|A15U121Pad2|A15U123Pad9|A15U122Pad1|EB9);
// Gate A15-U205A
pullup(A15U205Pad1);
assign (highz1,strong0) #0.2  A15U205Pad1 = rst ? 0 : ~(0|F11_);
// Gate A15-U135A
pullup(F16_);
assign (highz1,strong0) #0.2  F16_ = rst ? 1 : ~(0|F16);
// Gate A15-U108A
pullup(FB13_);
assign (highz1,strong0) #0.2  FB13_ = rst ? 0 : ~(0|A15U108Pad2|FB13|A15U107Pad9);
// Gate A15-U147B
pullup(RPTA12);
assign (highz1,strong0) #0.2  RPTA12 = rst ? 0 : ~(0|A15U145Pad1|RRPA1_);
// Gate A15-U131B
pullup(A15U131Pad9);
assign (highz1,strong0) #0.2  A15U131Pad9 = rst ? 0 : ~(0|E7_|FB16_|E5);
// Gate A15-U209B
pullup(A15U209Pad9);
assign (highz1,strong0) #0.2  A15U209Pad9 = rst ? 0 : ~(0|A15U209Pad6|A15U209Pad7|A15U209Pad1);
// Gate A15-U150B A15-U149B
pullup(A15U149Pad2);
assign (highz1,strong0) #0.2  A15U149Pad2 = rst ? 1 : ~(0|C42M|C44M|C43M|C37M|C40M|C41M);
// Gate A15-U149A
pullup(A15U149Pad1);
assign (highz1,strong0) #0.2  A15U149Pad1 = rst ? 0 : ~(0|A15U149Pad2|INCSET_);
// Gate A15-U209A
pullup(A15U209Pad1);
assign (highz1,strong0) #0.2  A15U209Pad1 = rst ? 1 : ~(0|A15U209Pad2|A15U208Pad1|A15U209Pad4);
// Gate A15-U110A
pullup(RL16_);
assign (highz1,strong0) #0.2  RL16_ = rst ? 1 : ~(0|BK16);
// Gate A15-U158B
pullup(PCDU_);
assign (highz1,strong0) #0.2  PCDU_ = rst ? 1 : ~(0|PCDU|A15U158Pad1);
// Gate A15-U228A
pullup(STR912);
assign (highz1,strong0) #0.2  STR912 = rst ? 0 : ~(0|A15U227Pad1);
// Gate A15-U225B
pullup(A15U209Pad7);
assign (highz1,strong0) #0.2  A15U209Pad7 = rst ? 0 : ~(0|A15U219Pad7|A15U213Pad4|A15U209Pad4);
// Gate A15-U214A
pullup(A15U209Pad6);
assign (highz1,strong0) #0.2  A15U209Pad6 = rst ? 0 : ~(0|A15U208Pad1|A15U212Pad4|A15U213Pad4);
// Gate A15-U218A
pullup(STR58);
assign (highz1,strong0) #0.2  STR58 = rst ? 1 : ~(0|A15U218Pad2);
// Gate A15-U106A
pullup(A15U106Pad1);
assign (highz1,strong0) #0.2  A15U106Pad1 = rst ? 0 : ~(0|RFBG_|FB14_);
// Gate A15-U254A
pullup(A15U252Pad3);
assign (highz1,strong0) #0.2  A15U252Pad3 = rst ? 0 : ~(0|XB4_|KRPTA_|XT1_);
// Gate A15-U207A A15-U207B
pullup(STR210);
assign (highz1,strong0) #0.2  STR210 = rst ? 0 : ~(0|A15U201Pad1|A15U202Pad6|A15U205Pad1);
// Gate A15-U220B
pullup(HIMOD);
assign (highz1,strong0) #0.2  HIMOD = rst ? 0 : ~(0|A15U220Pad6);
// Gate A15-U253B
pullup(A15U252Pad8);
assign (highz1,strong0) #0.2  A15U252Pad8 = rst ? 0 : ~(0|CA2_|XB6_|A15U249Pad3);
// Gate A15-U123A
pullup(A15U121Pad8);
assign (highz1,strong0) #0.2  A15U121Pad8 = rst ? 0 : ~(0|REBG_|EB10_);
// Gate A15-U126A A15-U116B
pullup(EB11_);
assign (highz1,strong0) #0.2  EB11_ = rst ? 0 : ~(0|A15U126Pad2|A15U113Pad9|A15U116Pad7|EB11);
// Gate A15-U244A
pullup(KY2RST);
assign (highz1,strong0) #0.2  KY2RST = rst ? 0 : ~(0|XB0_|KRPTA_|XT3_);
// Gate A15-U222B
pullup(A15U220Pad6);
assign (highz1,strong0) #0.2  A15U220Pad6 = rst ? 1 : ~(0|A15U214Pad9|A15U222Pad7|A15U210Pad3);
// Gate A15-U127B
pullup(A15U108Pad2);
assign (highz1,strong0) #0.2  A15U108Pad2 = rst ? 0 : ~(0|U2BBKG_|SUMB13_|SUMA13_);
// Gate A15-U122B
pullup(A15U121Pad2);
assign (highz1,strong0) #0.2  A15U121Pad2 = rst ? 0 : ~(0|U2BBKG_|SUMA01_|SUMB01_);
// Gate A15-U221A
pullup(A15U220Pad2);
assign (highz1,strong0) #0.2  A15U220Pad2 = rst ? 1 : ~(0|A15U221Pad2|A15U215Pad7|A15U209Pad6);
// Gate A15-U248A
pullup(A15U232Pad2);
assign (highz1,strong0) #0.2  A15U232Pad2 = rst ? 0 : ~(0|A15U248Pad2|A15U245Pad2);
// Gate A15-U144B
pullup(PRPOR3);
assign (highz1,strong0) #0.2  PRPOR3 = rst ? 0 : ~(0|A15U142Pad2|DNRPTA|PRPOR1);
// Gate A15-U113A
pullup(A15U112Pad7);
assign (highz1,strong0) #0.2  A15U112Pad7 = rst ? 0 : ~(0|EB11_|REBG_);
// Gate A15-U235A
pullup(RRPA1_);
assign (highz1,strong0) #0.2  RRPA1_ = rst ? 1 : ~(0|RRPA);
// Gate A15-U130B
pullup(A15U112Pad2);
assign (highz1,strong0) #0.2  A15U112Pad2 = rst ? 0 : ~(0|U2BBKG_|SUMA02_|SUMB02_);
// Gate A15-U219A
pullup(A15U212Pad4);
assign (highz1,strong0) #0.2  A15U212Pad4 = rst ? 1 : ~(0|F13);
// Gate A15-U239B
pullup(A15U237Pad2);
assign (highz1,strong0) #0.2  A15U237Pad2 = rst ? 1 : ~(0|A15U239Pad6|A15U239Pad3|A15U239Pad2);
// Gate A15-U250A
pullup(A15U248Pad2);
assign (highz1,strong0) #0.2  A15U248Pad2 = rst ? 1 : ~(0|A15U245Pad3|A15U249Pad1);
// Gate A15-U114A
pullup(A15U112Pad8);
assign (highz1,strong0) #0.2  A15U112Pad8 = rst ? 0 : ~(0|FB11_|RFBG_);
// Gate A15-U208A
pullup(A15U208Pad1);
assign (highz1,strong0) #0.2  A15U208Pad1 = rst ? 0 : ~(0|A15U208Pad2);
// Gate A15-U230B
pullup(A15U229Pad4);
assign (highz1,strong0) #0.2  A15U229Pad4 = rst ? 1 : ~(0|A15U230Pad1);
// Gate A15-U226B
pullup(A15U222Pad7);
assign (highz1,strong0) #0.2  A15U222Pad7 = rst ? 0 : ~(0|A15U214Pad7|F12_);
// Gate A15-U157B A15-U159B
pullup(A15U157Pad9);
assign (highz1,strong0) #0.2  A15U157Pad9 = rst ? 1 : ~(0|C35M|C36M|C32M|C33M|C34M);
// Gate A15-U119A
pullup(EB10);
assign (highz1,strong0) #0.2  EB10 = rst ? 1 : ~(0|CEBG|EB10_);
// Gate A15-U116A
pullup(EB11);
assign (highz1,strong0) #0.2  EB11 = rst ? 1 : ~(0|CEBG|EB11_);
// Gate A15-U249B
pullup(A15U245Pad3);
assign (highz1,strong0) #0.2  A15U245Pad3 = rst ? 0 : ~(0|A15U248Pad9|GOJAM|A15U248Pad2);
// Gate A15-U105B A15-U106B
pullup(FB14_);
assign (highz1,strong0) #0.2  FB14_ = rst ? 0 : ~(0|FB14|A15U105Pad7|A15U105Pad8);
// Gate A15-U234A A15-U235B
pullup(A15U234Pad1);
assign (highz1,strong0) #0.2  A15U234Pad1 = rst ? 1 : ~(0|A15U234Pad2|A15U234Pad3|A15U232Pad3|A15U231Pad2|PRPOR3);
// Gate A15-U227A
pullup(A15U227Pad1);
assign (highz1,strong0) #0.2  A15U227Pad1 = rst ? 1 : ~(0|A15U222Pad7|A15U216Pad2);
// Gate A15-U242A
pullup(A15U239Pad6);
assign (highz1,strong0) #0.2  A15U239Pad6 = rst ? 0 : ~(0|A15U239Pad4|GOJAM|A15U241Pad1);
// Gate A15-U257A
pullup(A15U234Pad2);
assign (highz1,strong0) #0.2  A15U234Pad2 = rst ? 0 : ~(0|A15U257Pad2|A15U257Pad3|GOJAM);
// Gate A15-U243B
pullup(A15U239Pad2);
assign (highz1,strong0) #0.2  A15U239Pad2 = rst ? 0 : ~(0|GOJAM|A15U243Pad3|KY2RST);
// Gate A15-U245B
pullup(A15U239Pad3);
assign (highz1,strong0) #0.2  A15U239Pad3 = rst ? 0 : ~(0|A15U245Pad1);
// Gate A15-U132A
pullup(A15U132Pad1);
assign (highz1,strong0) #0.2  A15U132Pad1 = rst ? 0 : ~(0|E6|FB14_|E7_);
// Gate A15-U102B
pullup(A15U102Pad2);
assign (highz1,strong0) #0.2  A15U102Pad2 = rst ? 0 : ~(0|WL16_|WFBG_);
// Gate A15-U111B
pullup(FB11_);
assign (highz1,strong0) #0.2  FB11_ = rst ? 1 : ~(0|A15U111Pad1|FB11|A15U111Pad8);
// Gate A15-U105A
pullup(A15U102Pad4);
assign (highz1,strong0) #0.2  A15U102Pad4 = rst ? 0 : ~(0|SUMA16_|SUMB16_|U2BBKG_);
// Gate A15-U138B A15-U140B
pullup(A15U132Pad7);
assign (highz1,strong0) #0.2  A15U132Pad7 = rst ? 1 : ~(0|S12_);
// Gate A15-U224B
pullup(A15U224Pad9);
assign (highz1,strong0) #0.2  A15U224Pad9 = rst ? 0 : ~(0|F16|F15_);
// Gate A15-U205B
pullup(A15U203Pad3);
assign (highz1,strong0) #0.2  A15U203Pad3 = rst ? 1 : ~(0|S10_);
// Gate A15-U158A
pullup(A15U158Pad1);
assign (highz1,strong0) #0.2  A15U158Pad1 = rst ? 0 : ~(0|INCSET_|A15U155Pad1);
// Gate A15-U121B
pullup(RL10_);
assign (highz1,strong0) #0.2  RL10_ = rst ? 1 : ~(0|A15U121Pad8);
// Gate A15-U257B
pullup(A15U257Pad2);
assign (highz1,strong0) #0.2  A15U257Pad2 = rst ? 1 : ~(0|T6RPT|A15U234Pad2);
// Gate A15-U258A
pullup(A15U257Pad3);
assign (highz1,strong0) #0.2  A15U257Pad3 = rst ? 0 : ~(0|XT0_|KRPTA_|XB4_);
// Gate A15-U232B
pullup(RL03_);
assign (highz1,strong0) #0.2  RL03_ = rst ? 1 : ~(0|CAD3|RPTAD3|BBK3);
// Gate A15-U236A
pullup(RPTAD3);
assign (highz1,strong0) #0.2  RPTAD3 = rst ? 0 : ~(0|RRPA1_|A15U234Pad1);
// Gate A15-U213B
pullup(A15U209Pad2);
assign (highz1,strong0) #0.2  A15U209Pad2 = rst ? 0 : ~(0|F14_);
// Gate A15-U231B
pullup(RPTAD5);
assign (highz1,strong0) #0.2  RPTAD5 = rst ? 0 : ~(0|RRPA1_|A15U231Pad1);
// Gate A15-U233B
pullup(RPTAD4);
assign (highz1,strong0) #0.2  RPTAD4 = rst ? 0 : ~(0|RRPA1_|A15U233Pad1);
// Gate A15-U210A
pullup(A15U210Pad1);
assign (highz1,strong0) #0.2  A15U210Pad1 = rst ? 1 : ~(0|A15U210Pad2|A15U210Pad3);
// Gate A15-U147A
pullup(RPTAD6);
assign (highz1,strong0) #0.2  RPTAD6 = rst ? 0 : ~(0|A15U146Pad1|RRPA1_);
// Gate A15-U208B
pullup(A15U208Pad2);
assign (highz1,strong0) #0.2  A15U208Pad2 = rst ? 1 : ~(0|F15|F16);
// Gate A15-U215A
pullup(A15U209Pad4);
assign (highz1,strong0) #0.2  A15U209Pad4 = rst ? 0 : ~(0|F13_);
// Gate A15-U146A
pullup(A15U146Pad1);
assign (highz1,strong0) #0.2  A15U146Pad1 = rst ? 1 : ~(0|PRPOR2|PRPOR4|PRPOR3);
// Gate A15-U120B
pullup(A15U119Pad7);
assign (highz1,strong0) #0.2  A15U119Pad7 = rst ? 0 : ~(0|WBBEG_|WL02_);
// Gate A15-U250B
pullup(A15U245Pad2);
assign (highz1,strong0) #0.2  A15U245Pad2 = rst ? 0 : ~(0|A15U250Pad8);
// Gate A15-U113B
pullup(A15U113Pad9);
assign (highz1,strong0) #0.2  A15U113Pad9 = rst ? 0 : ~(0|WL11_|WEBG_);
// Gate A15-U142A
pullup(A15U142Pad1);
assign (highz1,strong0) #0.2  A15U142Pad1 = rst ? 0 : ~(0|A15U142Pad2|GOJAM|A15U141Pad9);
// Gate A15-U213A
pullup(A15U212Pad7);
assign (highz1,strong0) #0.2  A15U212Pad7 = rst ? 0 : ~(0|A15U208Pad1|A15U209Pad4|A15U213Pad4);
// Gate A15-U212A
pullup(A15U212Pad1);
assign (highz1,strong0) #0.2  A15U212Pad1 = rst ? 0 : ~(0|A15U208Pad1|A15U209Pad2|A15U212Pad4);
// Gate A15-U246B
pullup(A15U245Pad4);
assign (highz1,strong0) #0.2  A15U245Pad4 = rst ? 0 : ~(0|A15U246Pad4|GOJAM|KY1RST);
// Gate A15-U217B
pullup(LOMOD);
assign (highz1,strong0) #0.2  LOMOD = rst ? 1 : ~(0|A15U216Pad1);
// Gate A15-U251B
pullup(A15U250Pad8);
assign (highz1,strong0) #0.2  A15U250Pad8 = rst ? 1 : ~(0|A15U251Pad6|A15U251Pad4|A15U234Pad2);
// Gate A15-U260A
pullup(WOVR_);
assign (highz1,strong0) #0.2  WOVR_ = rst ? 1 : ~(0|WOVR);
// Gate A15-U118B
pullup(A15U116Pad7);
assign (highz1,strong0) #0.2  A15U116Pad7 = rst ? 0 : ~(0|WBBEG_|WL03_);
// Gate A15-U203A A15-U203B
pullup(STR311);
assign (highz1,strong0) #0.2  STR311 = rst ? 0 : ~(0|A15U201Pad1|A15U203Pad3|A15U202Pad3);
// Gate A15-U109A
pullup(FB12_);
assign (highz1,strong0) #0.2  FB12_ = rst ? 1 : ~(0|FB12|A15U109Pad3|A15U109Pad4);
// Gate A15-U145A A15-U146B
pullup(A15U145Pad1);
assign (highz1,strong0) #0.2  A15U145Pad1 = rst ? 1 : ~(0|PRPOR1|DNRPTA|A15U142Pad1|A15U142Pad9);
// Gate A15-U227B
pullup(A15U218Pad2);
assign (highz1,strong0) #0.2  A15U218Pad2 = rst ? 0 : ~(0|A15U214Pad9|A15U216Pad3);
// Gate A15-U139B
pullup(F11_);
assign (highz1,strong0) #0.2  F11_ = rst ? 1 : ~(0|A15U138Pad1|A15U139Pad1);
// Gate A15-U148A
pullup(A15U148Pad1);
assign (highz1,strong0) #0.2  A15U148Pad1 = rst ? 0 : ~(0|RUPTOR_|A15U145Pad1);
// Gate A15-U137A
pullup(F12);
assign (highz1,strong0) #0.2  F12 = rst ? 1 : ~(0|F12_);
// Gate A15-U136B
pullup(F13);
assign (highz1,strong0) #0.2  F13 = rst ? 0 : ~(0|FB13_|A15U132Pad7);
// Gate A15-U255B
pullup(A15U253Pad3);
assign (highz1,strong0) #0.2  A15U253Pad3 = rst ? 0 : ~(0|XT1_|XB0_|KRPTA_);
// Gate A15-U140A
pullup(F11);
assign (highz1,strong0) #0.2  F11 = rst ? 0 : ~(0|F11_);
// Gate A15-U135B A15-U134A
pullup(F16);
assign (highz1,strong0) #0.2  F16 = rst ? 0 : ~(0|FB14_|FB16_|E7_|A15U132Pad7);
// Gate A15-U112B
pullup(RL11_);
assign (highz1,strong0) #0.2  RL11_ = rst ? 1 : ~(0|A15U112Pad7|A15U112Pad8);
// Gate A15-U133A
pullup(F15);
assign (highz1,strong0) #0.2  F15 = rst ? 0 : ~(0|A15U132Pad7|FB16_|A15U132Pad1);
// Gate A15-U240A
pullup(RL02_);
assign (highz1,strong0) #0.2  RL02_ = rst ? 1 : ~(0|CAD2|BBK2|R6);
// Gate A15-U258B A15-U259B
pullup(KRPTA_);
assign (highz1,strong0) #0.2  KRPTA_ = rst ? 1 : ~(0|KRPT);
// Gate A15-U142B
pullup(A15U142Pad9);
assign (highz1,strong0) #0.2  A15U142Pad9 = rst ? 0 : ~(0|A15U141Pad1|A15U142Pad7|GOJAM);
// Gate A15-U115B
pullup(A15U110Pad6);
assign (highz1,strong0) #0.2  A15U110Pad6 = rst ? 0 : ~(0|RFBG_|FB12_);
// Gate A15-U202A A15-U202B
pullup(STR412);
assign (highz1,strong0) #0.2  STR412 = rst ? 0 : ~(0|A15U201Pad1|A15U202Pad3|A15U202Pad6);
// Gate A15-U141B
pullup(A15U141Pad9);
assign (highz1,strong0) #0.2  A15U141Pad9 = rst ? 0 : ~(0|KRPTA_|XB4_|XT4_);
// Gate A15-U255A
pullup(A15U255Pad1);
assign (highz1,strong0) #0.2  A15U255Pad1 = rst ? 0 : ~(0|CA3_|XB0_|A15U249Pad3);
// Gate A15-U256A
pullup(A15U253Pad2);
assign (highz1,strong0) #0.2  A15U253Pad2 = rst ? 1 : ~(0|A15U255Pad1|A15U251Pad4);
// Gate A15-U141A
pullup(A15U141Pad1);
assign (highz1,strong0) #0.2  A15U141Pad1 = rst ? 0 : ~(0|XT5_|XB0_|KRPTA_);
// Gate A15-U224A
pullup(A15U213Pad4);
assign (highz1,strong0) #0.2  A15U213Pad4 = rst ? 1 : ~(0|F14);
// Gate A15-U242B
pullup(A15U239Pad4);
assign (highz1,strong0) #0.2  A15U239Pad4 = rst ? 1 : ~(0|UPRUPT|A15U239Pad6);
// Gate A15-U139A
pullup(A15U139Pad1);
assign (highz1,strong0) #0.2  A15U139Pad1 = rst ? 0 : ~(0|S11_|S12_);
// Gate A15-U211A
pullup(STR14);
assign (highz1,strong0) #0.2  STR14 = rst ? 0 : ~(0|A15U210Pad1);
// Gate A15-U136A
pullup(F12_);
assign (highz1,strong0) #0.2  F12_ = rst ? 0 : ~(0|FB12|A15U132Pad7);
// Gate A15-U251A
pullup(A15U234Pad3);
assign (highz1,strong0) #0.2  A15U234Pad3 = rst ? 0 : ~(0|A15U234Pad2|A15U251Pad3|A15U251Pad4);
// Gate A15-U234B A15-U233A
pullup(A15U233Pad1);
assign (highz1,strong0) #0.2  A15U233Pad1 = rst ? 1 : ~(0|A15U231Pad3|A15U234Pad3|A15U234Pad8|PRPOR4|A15U231Pad2);
// Gate A15-U127A
pullup(A15U105Pad7);
assign (highz1,strong0) #0.2  A15U105Pad7 = rst ? 0 : ~(0|U2BBKG_|SUMA14_|SUMB14_);
// Gate A15-U219B
pullup(A15U215Pad7);
assign (highz1,strong0) #0.2  A15U215Pad7 = rst ? 0 : ~(0|A15U209Pad4|A15U219Pad7|A15U209Pad2);
// Gate A15-U206A A15-U206B
pullup(STR19);
assign (highz1,strong0) #0.2  STR19 = rst ? 0 : ~(0|A15U201Pad1|A15U205Pad1|A15U203Pad3);
// Gate A15-U110B
pullup(RL12_);
assign (highz1,strong0) #0.2  RL12_ = rst ? 1 : ~(0|A15U110Pad6|RSTRT|RPTA12);
// Gate A15-U254B
pullup(A15U234Pad8);
assign (highz1,strong0) #0.2  A15U234Pad8 = rst ? 0 : ~(0|A15U253Pad2|A15U234Pad2);
// Gate A15-U204A
pullup(A15U202Pad3);
assign (highz1,strong0) #0.2  A15U202Pad3 = rst ? 1 : ~(0|F11);
// Gate A15-U226A
pullup(A15U215Pad8);
assign (highz1,strong0) #0.2  A15U215Pad8 = rst ? 0 : ~(0|A15U212Pad4|A15U213Pad4|A15U219Pad7);
// Gate A15-U215B
pullup(A15U215Pad9);
assign (highz1,strong0) #0.2  A15U215Pad9 = rst ? 1 : ~(0|A15U212Pad1|A15U215Pad7|A15U215Pad8);
// Gate A15-U204B
pullup(A15U202Pad6);
assign (highz1,strong0) #0.2  A15U202Pad6 = rst ? 0 : ~(0|S10);
// Gate A15-U247A
pullup(KY1RST);
assign (highz1,strong0) #0.2  KY1RST = rst ? 0 : ~(0|KRPTA_|XT2_|XB4_);
// Gate A15-U107A
pullup(A15U105Pad8);
assign (highz1,strong0) #0.2  A15U105Pad8 = rst ? 0 : ~(0|WFBG_|WL14_);
// Gate A15-U212B
pullup(A15U211Pad6);
assign (highz1,strong0) #0.2  A15U211Pad6 = rst ? 0 : ~(0|A15U212Pad1|A15U212Pad7|A15U209Pad1);
// Gate A15-U217A
pullup(RL01_);
assign (highz1,strong0) #0.2  RL01_ = rst ? 1 : ~(0|BBK1|CAD1|RB1F);
// Gate A15-U238A
pullup(A15U236Pad7);
assign (highz1,strong0) #0.2  A15U236Pad7 = rst ? 1 : ~(0|DNRPTA|DLKPLS);
// Gate A15-U232A A15-U231A
pullup(A15U231Pad1);
assign (highz1,strong0) #0.2  A15U231Pad1 = rst ? 1 : ~(0|A15U232Pad2|A15U232Pad3|A15U231Pad2|A15U231Pad3);
// Gate A15-U239A
pullup(A15U231Pad2);
assign (highz1,strong0) #0.2  A15U231Pad2 = rst ? 0 : ~(0|A15U239Pad2|A15U239Pad3|A15U239Pad4);
// Gate A15-U243A
pullup(A15U231Pad3);
assign (highz1,strong0) #0.2  A15U231Pad3 = rst ? 0 : ~(0|A15U239Pad3|A15U243Pad3);
// Gate A15-U126B
pullup(RL09_);
assign (highz1,strong0) #0.2  RL09_ = rst ? 1 : ~(0|A15U125Pad1);
// Gate A15-U241A
pullup(A15U241Pad1);
assign (highz1,strong0) #0.2  A15U241Pad1 = rst ? 0 : ~(0|XT3_|XB4_|KRPTA_);
// Gate A15-U132B
pullup(F14);
assign (highz1,strong0) #0.2  F14 = rst ? 0 : ~(0|A15U131Pad9|A15U132Pad7|FB14_);
// Gate A15-U237B
pullup(DRPRST);
assign (highz1,strong0) #0.2  DRPRST = rst ? 0 : ~(0|KRPTA_|XT4_|XB0_);
// Gate A15-U244B
pullup(A15U243Pad3);
assign (highz1,strong0) #0.2  A15U243Pad3 = rst ? 1 : ~(0|A15U239Pad2|MKRPT|KYRPT2);
// Gate A15-U118A
pullup(A15U101Pad8);
assign (highz1,strong0) #0.2  A15U101Pad8 = rst ? 0 : ~(0|RFBG_|FB13_);
// Gate A15-U123B
pullup(A15U123Pad9);
assign (highz1,strong0) #0.2  A15U123Pad9 = rst ? 0 : ~(0|WEBG_|WL09_);
// Gate A15-U230A
pullup(A15U230Pad1);
assign (highz1,strong0) #0.2  A15U230Pad1 = rst ? 0 : ~(0|F16_|F15);
// Gate A15-U155B
pullup(PCDU);
assign (highz1,strong0) #0.2  PCDU = rst ? 0 : ~(0|T12A|PCDU_);
// Gate A15-U131A
pullup(F14_);
assign (highz1,strong0) #0.2  F14_ = rst ? 1 : ~(0|F14);
// Gate A15-U220A
pullup(ROPES);
assign (highz1,strong0) #0.2  ROPES = rst ? 0 : ~(0|A15U220Pad2);
// Gate A15-U152A
pullup(MINC);
assign (highz1,strong0) #0.2  MINC = rst ? 0 : ~(0|MINC_|T12A);
// Gate A15-U228B
pullup(ROPET);
assign (highz1,strong0) #0.2  ROPET = rst ? 0 : ~(0|A15U228Pad6);
// Gate A15-U223A
pullup(A15U221Pad2);
assign (highz1,strong0) #0.2  A15U221Pad2 = rst ? 0 : ~(0|A15U212Pad4|A15U219Pad7|A15U209Pad2);
// Gate A15-U101B
pullup(RL13_);
assign (highz1,strong0) #0.2  RL13_ = rst ? 1 : ~(0|A15U101Pad8);
// Gate A15-U223B
pullup(A15U214Pad7);
assign (highz1,strong0) #0.2  A15U214Pad7 = rst ? 1 : ~(0|A15U212Pad7|A15U223Pad7|A15U221Pad2);
// Gate A15-U137B
pullup(F13_);
assign (highz1,strong0) #0.2  F13_ = rst ? 1 : ~(0|F13);
// Gate A15-U214B
pullup(A15U214Pad9);
assign (highz1,strong0) #0.2  A15U214Pad9 = rst ? 0 : ~(0|A15U214Pad7|F12);
// Gate A15-U160A
pullup(MCDU_);
assign (highz1,strong0) #0.2  MCDU_ = rst ? 1 : ~(0|MCDU|A15U159Pad1);
// Gate A15-U128B
pullup(A15U111Pad8);
assign (highz1,strong0) #0.2  A15U111Pad8 = rst ? 0 : ~(0|SUMA11_|U2BBKG_|SUMB11_);
// Gate A15-U111A
pullup(A15U111Pad1);
assign (highz1,strong0) #0.2  A15U111Pad1 = rst ? 0 : ~(0|WL11_|WFBG_);
// Gate A15-U256B
pullup(T6RPT);
assign (highz1,strong0) #0.2  T6RPT = rst ? 0 : ~(0|CA3_|ZOUT_|XB1_);
// Gate A15-U245A
pullup(A15U245Pad1);
assign (highz1,strong0) #0.2  A15U245Pad1 = rst ? 1 : ~(0|A15U245Pad2|A15U245Pad3|A15U245Pad4);
// Gate A15-U103B
pullup(FB16);
assign (highz1,strong0) #0.2  FB16 = rst ? 0 : ~(0|CFBG|FB16_);
// Gate A15-U143B
pullup(A15U142Pad7);
assign (highz1,strong0) #0.2  A15U142Pad7 = rst ? 1 : ~(0|A15U142Pad9|HNDRPT);
// Gate A15-U104B
pullup(FB14);
assign (highz1,strong0) #0.2  FB14 = rst ? 1 : ~(0|CFBG|FB14_);
// Gate A15-U108B
pullup(FB13);
assign (highz1,strong0) #0.2  FB13 = rst ? 1 : ~(0|CFBG|FB13_);
// Gate A15-U115A
pullup(FB12);
assign (highz1,strong0) #0.2  FB12 = rst ? 0 : ~(0|CFBG|FB12_);
// Gate A15-U117A
pullup(FB11);
assign (highz1,strong0) #0.2  FB11 = rst ? 0 : ~(0|FB11_|CFBG);
// Gate A15-U143A
pullup(A15U142Pad2);
assign (highz1,strong0) #0.2  A15U142Pad2 = rst ? 1 : ~(0|RADRPT|A15U142Pad1);
// Gate A15-U156B A15-U155A
pullup(A15U155Pad1);
assign (highz1,strong0) #0.2  A15U155Pad1 = rst ? 1 : ~(0|C36P|C35P|C34P|C32P|C33P);
// Gate A15-U248B
pullup(A15U248Pad9);
assign (highz1,strong0) #0.2  A15U248Pad9 = rst ? 0 : ~(0|XT2_|KRPTA_|XB0_);
// Gate A15-U201A A15-U201B
pullup(A15U201Pad1);
assign (highz1,strong0) #0.2  A15U201Pad1 = rst ? 1 : ~(0|STRGAT);
// Gate A15-U229A
pullup(A15U223Pad7);
assign (highz1,strong0) #0.2  A15U223Pad7 = rst ? 0 : ~(0|A15U209Pad2|A15U209Pad4|A15U229Pad4);
// Gate A15-U237A
pullup(PRPOR1);
assign (highz1,strong0) #0.2  PRPOR1 = rst ? 0 : ~(0|A15U237Pad2);
// Gate A15-U225A
pullup(A15U219Pad7);
assign (highz1,strong0) #0.2  A15U219Pad7 = rst ? 1 : ~(0|A15U224Pad9);
// Gate A15-U117B
pullup(A15U117Pad9);
assign (highz1,strong0) #0.2  A15U117Pad9 = rst ? 0 : ~(0|WEBG_|WL10_);
// Gate A15-U236B
pullup(PRPOR2);
assign (highz1,strong0) #0.2  PRPOR2 = rst ? 0 : ~(0|A15U236Pad7|PRPOR1);
// Gate A15-U119B A15-U112A
pullup(EB10_);
assign (highz1,strong0) #0.2  EB10_ = rst ? 0 : ~(0|A15U117Pad9|A15U119Pad7|EB10|A15U112Pad2);
// Gate A15-U145B A15-U144A
pullup(PRPOR4);
assign (highz1,strong0) #0.2  PRPOR4 = rst ? 0 : ~(0|A15U142Pad7|A15U142Pad1|PRPOR1|DNRPTA);
// Gate A15-U247B
pullup(A15U246Pad4);
assign (highz1,strong0) #0.2  A15U246Pad4 = rst ? 1 : ~(0|KYRPT1|A15U245Pad4);
// Gate A15-U138A
pullup(A15U138Pad1);
assign (highz1,strong0) #0.2  A15U138Pad1 = rst ? 0 : ~(0|A15U132Pad7|FB11_);
// Gate A15-U125A
pullup(A15U125Pad1);
assign (highz1,strong0) #0.2  A15U125Pad1 = rst ? 0 : ~(0|REBG_|EB9_);
// Gate A15-U125B
pullup(BBK1);
assign (highz1,strong0) #0.2  BBK1 = rst ? 0 : ~(0|RBBEG_|EB9_);
// Gate A15-U114B
pullup(BBK3);
assign (highz1,strong0) #0.2  BBK3 = rst ? 0 : ~(0|RBBEG_|EB11_);
// Gate A15-U120A
pullup(BBK2);
assign (highz1,strong0) #0.2  BBK2 = rst ? 0 : ~(0|RBBEG_|EB10_);
// Gate A15-U252A
pullup(A15U251Pad6);
assign (highz1,strong0) #0.2  A15U251Pad6 = rst ? 0 : ~(0|A15U251Pad3|A15U252Pad3|GOJAM);
// Gate A15-U124B
pullup(EB9);
assign (highz1,strong0) #0.2  EB9 = rst ? 1 : ~(0|EB9_|CEBG);
// Gate A15-U104A
pullup(BK16);
assign (highz1,strong0) #0.2  BK16 = rst ? 0 : ~(0|FB16_|RFBG_);
// Gate A15-U238B
pullup(DNRPTA);
assign (highz1,strong0) #0.2  DNRPTA = rst ? 0 : ~(0|DRPRST|GOJAM|A15U236Pad7);
// Gate A15-U252B
pullup(A15U251Pad3);
assign (highz1,strong0) #0.2  A15U251Pad3 = rst ? 1 : ~(0|A15U251Pad6|A15U252Pad8);
// Gate A15-U107B
pullup(A15U107Pad9);
assign (highz1,strong0) #0.2  A15U107Pad9 = rst ? 0 : ~(0|WFBG_|WL13_);
// Gate A15-U159A
pullup(A15U159Pad1);
assign (highz1,strong0) #0.2  A15U159Pad1 = rst ? 0 : ~(0|INCSET_|A15U157Pad9);
// Gate A15-U211B
pullup(ROPER);
assign (highz1,strong0) #0.2  ROPER = rst ? 0 : ~(0|A15U211Pad6);
// Gate A15-U103A A15-U102A
pullup(FB16_);
assign (highz1,strong0) #0.2  FB16_ = rst ? 1 : ~(0|A15U102Pad4|FB16|A15U102Pad2);
// Gate A15-U128A
pullup(A15U109Pad3);
assign (highz1,strong0) #0.2  A15U109Pad3 = rst ? 0 : ~(0|SUMB12_|SUMA12_|U2BBKG_);
// Gate A15-U122A
pullup(A15U122Pad1);
assign (highz1,strong0) #0.2  A15U122Pad1 = rst ? 0 : ~(0|WL01_|WBBEG_);
// Gate A15-U109B
pullup(A15U109Pad4);
assign (highz1,strong0) #0.2  A15U109Pad4 = rst ? 0 : ~(0|WFBG_|WL12_);
// Gate A15-U133B
pullup(F15_);
assign (highz1,strong0) #0.2  F15_ = rst ? 1 : ~(0|F15);
// Gate A15-U253A
pullup(A15U251Pad4);
assign (highz1,strong0) #0.2  A15U251Pad4 = rst ? 0 : ~(0|A15U253Pad2|A15U253Pad3|GOJAM);
// Gate A15-U216A
pullup(A15U216Pad1);
assign (highz1,strong0) #0.2  A15U216Pad1 = rst ? 0 : ~(0|A15U216Pad2|A15U216Pad3|A15U210Pad2);
// Gate A15-U216B
pullup(A15U210Pad3);
assign (highz1,strong0) #0.2  A15U210Pad3 = rst ? 0 : ~(0|A15U215Pad9|F12_);
// Gate A15-U221B
pullup(A15U216Pad3);
assign (highz1,strong0) #0.2  A15U216Pad3 = rst ? 1 : ~(0|A15U209Pad9|F12_);
// Gate A15-U222A
pullup(A15U216Pad2);
assign (highz1,strong0) #0.2  A15U216Pad2 = rst ? 0 : ~(0|F12|A15U215Pad9);
// Gate A15-U210B
pullup(A15U210Pad2);
assign (highz1,strong0) #0.2  A15U210Pad2 = rst ? 0 : ~(0|A15U209Pad9|F12);
// Gate A15-U229B
pullup(A15U228Pad6);
assign (highz1,strong0) #0.2  A15U228Pad6 = rst ? 1 : ~(0|A15U209Pad7|A15U215Pad8|A15U223Pad7);
// Gate A15-U150A
pullup(RL14_);
assign (highz1,strong0) #0.2  RL14_ = rst ? 1 : ~(0|A15U106Pad1);
// Gate A15-U160B
pullup(MCDU);
assign (highz1,strong0) #0.2  MCDU = rst ? 0 : ~(0|MCDU_|T12A);
// Gate A15-U249A
pullup(A15U249Pad1);
assign (highz1,strong0) #0.2  A15U249Pad1 = rst ? 0 : ~(0|XB7_|A15U249Pad3|CA2_);
// Gate A15-U259A
pullup(A15U249Pad3);
assign (highz1,strong0) #0.2  A15U249Pad3 = rst ? 1 : ~(0|A15U259Pad2);
// Gate A15-U246A
pullup(A15U232Pad3);
assign (highz1,strong0) #0.2  A15U232Pad3 = rst ? 0 : ~(0|A15U245Pad2|A15U245Pad3|A15U246Pad4);
// Gate A15-U152B
pullup(MINC_);
assign (highz1,strong0) #0.2  MINC_ = rst ? 1 : ~(0|A15U149Pad1|MINC);
// Gate A15-U148B
pullup(RUPTOR_);
assign (highz1,strong0) #0.2  RUPTOR_ = rst ? 1 : ~(0|A15U148Pad1|T10);
// Gate A15-U129B
pullup(A15U126Pad2);
assign (highz1,strong0) #0.2  A15U126Pad2 = rst ? 0 : ~(0|U2BBKG_|SUMB03_|SUMA03_);

endmodule
