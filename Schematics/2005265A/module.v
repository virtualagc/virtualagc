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

parameter GATE_DELAY = 20; // This default may be overridden at compile time.
initial $display("Gate delay (A15) will be %f ns.", GATE_DELAY);

// Gate A15-U260B
pullup(g35302);
assign #GATE_DELAY g35302 = rst ? 0 : ((0|WOVR_|OVF_) ? 1'b0 : 1'bz);
// Gate A15-U121A A15-U124A
pullup(EB9_);
assign #GATE_DELAY EB9_ = rst ? 0 : ((0|g35158|EB9|g35144|g35143) ? 1'b0 : 1'bz);
// Gate A15-U205A
pullup(g35411);
assign #GATE_DELAY g35411 = rst ? 0 : ((0|F11_) ? 1'b0 : 1'bz);
// Gate A15-U135A
pullup(F16_);
assign #GATE_DELAY F16_ = rst ? 1'bz : ((0|F16) ? 1'b0 : 1'bz);
// Gate A15-U108A
pullup(FB13_);
assign #GATE_DELAY FB13_ = rst ? 0 : ((0|g35113|FB13|g35153) ? 1'b0 : 1'bz);
// Gate A15-U147B
pullup(RPTA12);
assign #GATE_DELAY RPTA12 = rst ? 0 : ((0|g35229|RRPA1_) ? 1'b0 : 1'bz);
// Gate A15-U131B
pullup(g35211);
assign #GATE_DELAY g35211 = rst ? 0 : ((0|E7_|FB16_|E5) ? 1'b0 : 1'bz);
// Gate A15-U256B
pullup(T6RPT);
assign #GATE_DELAY T6RPT = rst ? 0 : ((0|CA3_|ZOUT_|XB1_) ? 1'b0 : 1'bz);
// Gate A15-U150B A15-U149B
pullup(g35236);
assign #GATE_DELAY g35236 = rst ? 1'bz : ((0|C42M|C44M|C43M|C37M|C40M|C41M) ? 1'b0 : 1'bz);
// Gate A15-U149A
pullup(g35238);
assign #GATE_DELAY g35238 = rst ? 0 : ((0|INCSET_|g35236) ? 1'b0 : 1'bz);
// Gate A15-U252B
pullup(g35317);
assign #GATE_DELAY g35317 = rst ? 1'bz : ((0|g35318|g35316) ? 1'b0 : 1'bz);
// Gate A15-U110A
pullup(RL16_);
assign #GATE_DELAY RL16_ = rst ? 1'bz : ((0|BK16) ? 1'b0 : 1'bz);
// Gate A15-U158B
pullup(PCDU_);
assign #GATE_DELAY PCDU_ = rst ? 1'bz : ((0|PCDU|g35243) ? 1'b0 : 1'bz);
// Gate A15-U228A
pullup(STR912);
assign #GATE_DELAY STR912 = rst ? 0 : ((0|g25456) ? 1'b0 : 1'bz);
// Gate A15-U218A
pullup(STR58);
assign #GATE_DELAY STR58 = rst ? 1'bz : ((0|g35435) ? 1'b0 : 1'bz);
// Gate A15-U106A
pullup(g35111);
assign #GATE_DELAY g35111 = rst ? 0 : ((0|FB14_|RFBG_) ? 1'b0 : 1'bz);
// Gate A15-U254A
pullup(g35315);
assign #GATE_DELAY g35315 = rst ? 0 : ((0|XT1_|KRPTA_|XB4_) ? 1'b0 : 1'bz);
// Gate A15-U207A A15-U207B
pullup(STR210);
assign #GATE_DELAY STR210 = rst ? 0 : ((0|g35408|g35401|g35411) ? 1'b0 : 1'bz);
// Gate A15-U229B
pullup(_A15_2_NE6710_);
assign #GATE_DELAY _A15_2_NE6710_ = rst ? 1'bz : ((0|_A15_2_NE06|_A15_2_NE07|_A15_2_NE10) ? 1'b0 : 1'bz);
// Gate A15-U253B
pullup(g35316);
assign #GATE_DELAY g35316 = rst ? 0 : ((0|CA2_|XB6_|g35303) ? 1'b0 : 1'bz);
// Gate A15-U123A
pullup(g35139);
assign #GATE_DELAY g35139 = rst ? 0 : ((0|EB10_|REBG_) ? 1'b0 : 1'bz);
// Gate A15-U126A A15-U116B
pullup(EB11_);
assign #GATE_DELAY EB11_ = rst ? 0 : ((0|g35156|g35128|g35129|EB11) ? 1'b0 : 1'bz);
// Gate A15-U244A
pullup(KY2RST);
assign #GATE_DELAY KY2RST = rst ? 0 : ((0|XT3_|KRPTA_|XB0_) ? 1'b0 : 1'bz);
// Gate A15-U222B
pullup(g35448);
assign #GATE_DELAY g35448 = rst ? 1'bz : ((0|_A15_2_2510L|_A15_2_2510H|_A15_2_147H) ? 1'b0 : 1'bz);
// Gate A15-U127B
pullup(g35153);
assign #GATE_DELAY g35153 = rst ? 0 : ((0|U2BBKG_|SUMB13_|SUMA13_) ? 1'b0 : 1'bz);
// Gate A15-U122B
pullup(g35158);
assign #GATE_DELAY g35158 = rst ? 0 : ((0|U2BBKG_|SUMA01_|SUMB01_) ? 1'b0 : 1'bz);
// Gate A15-U246A
pullup(g35330);
assign #GATE_DELAY g35330 = rst ? 0 : ((0|g35328|g35326|g35321) ? 1'b0 : 1'bz);
// Gate A15-U248A
pullup(g35324);
assign #GATE_DELAY g35324 = rst ? 0 : ((0|g35321|g35323) ? 1'b0 : 1'bz);
// Gate A15-U144B
pullup(PRPOR3);
assign #GATE_DELAY PRPOR3 = rst ? 0 : ((0|g35222|DNRPTA|PRPOR1) ? 1'b0 : 1'bz);
// Gate A15-U113A
pullup(g35132);
assign #GATE_DELAY g35132 = rst ? 0 : ((0|REBG_|EB11_) ? 1'b0 : 1'bz);
// Gate A15-U235A
pullup(RRPA1_);
assign #GATE_DELAY RRPA1_ = rst ? 1'bz : ((0|RRPA) ? 1'b0 : 1'bz);
// Gate A15-U130B
pullup(g35157);
assign #GATE_DELAY g35157 = rst ? 0 : ((0|U2BBKG_|SUMA02_|SUMB02_) ? 1'b0 : 1'bz);
// Gate A15-U219A
pullup(g35431);
assign #GATE_DELAY g35431 = rst ? 1'bz : ((0|F13) ? 1'b0 : 1'bz);
// Gate A15-U239B
pullup(g35343);
assign #GATE_DELAY g35343 = rst ? 1'bz : ((0|g35341|g35332|g35335) ? 1'b0 : 1'bz);
// Gate A15-U250A
pullup(g35323);
assign #GATE_DELAY g35323 = rst ? 1'bz : ((0|g35322|g35326) ? 1'b0 : 1'bz);
// Gate A15-U114A
pullup(g35126);
assign #GATE_DELAY g35126 = rst ? 0 : ((0|RFBG_|FB11_) ? 1'b0 : 1'bz);
// Gate A15-U230B
pullup(g35451);
assign #GATE_DELAY g35451 = rst ? 1'bz : ((0|g35450) ? 1'b0 : 1'bz);
// Gate A15-U220A
pullup(ROPES);
assign #GATE_DELAY ROPES = rst ? 0 : ((0|_A15_2_NE345_) ? 1'b0 : 1'bz);
// Gate A15-U157B A15-U159B
pullup(g35246);
assign #GATE_DELAY g35246 = rst ? 1'bz : ((0|C35M|C36M|C32M|C33M|C34M) ? 1'b0 : 1'bz);
// Gate A15-U119A
pullup(EB10);
assign #GATE_DELAY EB10 = rst ? 1'bz : ((0|EB10_|CEBG) ? 1'b0 : 1'bz);
// Gate A15-U116A
pullup(EB11);
assign #GATE_DELAY EB11 = rst ? 1'bz : ((0|EB11_|CEBG) ? 1'b0 : 1'bz);
// Gate A15-U249B
pullup(g35326);
assign #GATE_DELAY g35326 = rst ? 0 : ((0|g35325|GOJAM|g35323) ? 1'b0 : 1'bz);
// Gate A15-U105B A15-U106B
pullup(FB14_);
assign #GATE_DELAY FB14_ = rst ? 0 : ((0|FB14|g35152|g35107) ? 1'b0 : 1'bz);
// Gate A15-U234A A15-U235B
pullup(g35351);
assign #GATE_DELAY g35351 = rst ? 1'bz : ((0|g35319|g35309|g35330|g35342|PRPOR3) ? 1'b0 : 1'bz);
// Gate A15-U227A
pullup(g25456);
assign #GATE_DELAY g25456 = rst ? 1'bz : ((0|_A15_2_147L|_A15_2_2510H) ? 1'b0 : 1'bz);
// Gate A15-U242A
pullup(g35341);
assign #GATE_DELAY g35341 = rst ? 0 : ((0|g35339|GOJAM|g35340) ? 1'b0 : 1'bz);
// Gate A15-U257A
pullup(g35309);
assign #GATE_DELAY g35309 = rst ? 0 : ((0|GOJAM|g35306|g35308) ? 1'b0 : 1'bz);
// Gate A15-U243B
pullup(g35335);
assign #GATE_DELAY g35335 = rst ? 0 : ((0|GOJAM|g35334|KY2RST) ? 1'b0 : 1'bz);
// Gate A15-U245B
pullup(g35332);
assign #GATE_DELAY g35332 = rst ? 0 : ((0|g35331) ? 1'b0 : 1'bz);
// Gate A15-U132A
pullup(g35212);
assign #GATE_DELAY g35212 = rst ? 0 : ((0|E7_|FB14_|E6) ? 1'b0 : 1'bz);
// Gate A15-U211B
pullup(ROPER);
assign #GATE_DELAY ROPER = rst ? 1'bz : ((0|_A15_2_NE012_) ? 1'b0 : 1'bz);
// Gate A15-U102B
pullup(g35101);
assign #GATE_DELAY g35101 = rst ? 0 : ((0|WL16_|WFBG_) ? 1'b0 : 1'bz);
// Gate A15-U111B
pullup(FB11_);
assign #GATE_DELAY FB11_ = rst ? 0 : ((0|g35123|FB11|g35155) ? 1'b0 : 1'bz);
// Gate A15-U105A
pullup(g35151);
assign #GATE_DELAY g35151 = rst ? 0 : ((0|U2BBKG_|SUMB16_|SUMA16_) ? 1'b0 : 1'bz);
// Gate A15-U138B A15-U140B
pullup(g35202);
assign #GATE_DELAY g35202 = rst ? 1'bz : ((0|S12_) ? 1'b0 : 1'bz);
// Gate A15-U224B
pullup(g35442);
assign #GATE_DELAY g35442 = rst ? 0 : ((0|F16|F15_) ? 1'b0 : 1'bz);
// Gate A15-U205B
pullup(g35414);
assign #GATE_DELAY g35414 = rst ? 1'bz : ((0|S10_) ? 1'b0 : 1'bz);
// Gate A15-U158A
pullup(g35243);
assign #GATE_DELAY g35243 = rst ? 0 : ((0|g35241|INCSET_) ? 1'b0 : 1'bz);
// Gate A15-U220B
pullup(HIMOD);
assign #GATE_DELAY HIMOD = rst ? 0 : ((0|g35448) ? 1'b0 : 1'bz);
// Gate A15-U121B
pullup(RL10_);
assign #GATE_DELAY RL10_ = rst ? 1'bz : ((0|g35139) ? 1'b0 : 1'bz);
// Gate A15-U257B
pullup(g35308);
assign #GATE_DELAY g35308 = rst ? 1'bz : ((0|T6RPT|g35309) ? 1'b0 : 1'bz);
// Gate A15-U258A
pullup(g35306);
assign #GATE_DELAY g35306 = rst ? 0 : ((0|XB4_|KRPTA_|XT0_) ? 1'b0 : 1'bz);
// Gate A15-U232B
pullup(RL03_);
assign #GATE_DELAY RL03_ = rst ? 1'bz : ((0|CAD3|RPTAD3|BBK3) ? 1'b0 : 1'bz);
// Gate A15-U236A
pullup(RPTAD3);
assign #GATE_DELAY RPTAD3 = rst ? 0 : ((0|g35351|RRPA1_) ? 1'b0 : 1'bz);
// Gate A15-U213B
pullup(g35423);
assign #GATE_DELAY g35423 = rst ? 0 : ((0|F14_) ? 1'b0 : 1'bz);
// Gate A15-U231B
pullup(RPTAD5);
assign #GATE_DELAY RPTAD5 = rst ? 0 : ((0|RRPA1_|g35357) ? 1'b0 : 1'bz);
// Gate A15-U233B
pullup(RPTAD4);
assign #GATE_DELAY RPTAD4 = rst ? 0 : ((0|RRPA1_|g35354) ? 1'b0 : 1'bz);
// Gate A15-U210A
pullup(g35420);
assign #GATE_DELAY g35420 = rst ? 1'bz : ((0|_A15_2_147H|_A15_2_036L) ? 1'b0 : 1'bz);
// Gate A15-U147A
pullup(RPTAD6);
assign #GATE_DELAY RPTAD6 = rst ? 0 : ((0|RRPA1_|g35231) ? 1'b0 : 1'bz);
// Gate A15-U208B
pullup(g35415);
assign #GATE_DELAY g35415 = rst ? 1'bz : ((0|F15|F16) ? 1'b0 : 1'bz);
// Gate A15-U215A
pullup(g35430);
assign #GATE_DELAY g35430 = rst ? 0 : ((0|F13_) ? 1'b0 : 1'bz);
// Gate A15-U146A
pullup(g35231);
assign #GATE_DELAY g35231 = rst ? 1'bz : ((0|PRPOR3|PRPOR4|PRPOR2) ? 1'b0 : 1'bz);
// Gate A15-U120B
pullup(g35136);
assign #GATE_DELAY g35136 = rst ? 0 : ((0|WBBEG_|WL02_) ? 1'b0 : 1'bz);
// Gate A15-U250B
pullup(g35321);
assign #GATE_DELAY g35321 = rst ? 0 : ((0|g35320) ? 1'b0 : 1'bz);
// Gate A15-U113B
pullup(g35128);
assign #GATE_DELAY g35128 = rst ? 0 : ((0|WL11_|WEBG_) ? 1'b0 : 1'bz);
// Gate A15-U142A
pullup(g35223);
assign #GATE_DELAY g35223 = rst ? 0 : ((0|g35220|GOJAM|g35222) ? 1'b0 : 1'bz);
// Gate A15-U256A
pullup(g35312);
assign #GATE_DELAY g35312 = rst ? 1'bz : ((0|g35313|g35311) ? 1'b0 : 1'bz);
// Gate A15-U246B
pullup(g35329);
assign #GATE_DELAY g35329 = rst ? 0 : ((0|g35328|GOJAM|KY1RST) ? 1'b0 : 1'bz);
// Gate A15-U217B
pullup(LOMOD);
assign #GATE_DELAY LOMOD = rst ? 1'bz : ((0|g35428) ? 1'b0 : 1'bz);
// Gate A15-U221A
pullup(_A15_2_NE345_);
assign #GATE_DELAY _A15_2_NE345_ = rst ? 1'bz : ((0|_A15_2_NE03|_A15_2_NE04|_A15_2_NE05) ? 1'b0 : 1'bz);
// Gate A15-U260A
pullup(WOVR_);
assign #GATE_DELAY WOVR_ = rst ? 1'bz : ((0|WOVR) ? 1'b0 : 1'bz);
// Gate A15-U118B
pullup(g35129);
assign #GATE_DELAY g35129 = rst ? 0 : ((0|WBBEG_|WL03_) ? 1'b0 : 1'bz);
// Gate A15-U203A A15-U203B
pullup(STR311);
assign #GATE_DELAY STR311 = rst ? 0 : ((0|g35414|g35401|g35405) ? 1'b0 : 1'bz);
// Gate A15-U109A
pullup(FB12_);
assign #GATE_DELAY FB12_ = rst ? 0 : ((0|g35118|g35154|FB12) ? 1'b0 : 1'bz);
// Gate A15-U145A A15-U146B
pullup(g35229);
assign #GATE_DELAY g35229 = rst ? 1'bz : ((0|DNRPTA|PRPOR1|g35223|g35225) ? 1'b0 : 1'bz);
// Gate A15-U227B
pullup(g35435);
assign #GATE_DELAY g35435 = rst ? 0 : ((0|_A15_2_2510L|_A15_2_036H) ? 1'b0 : 1'bz);
// Gate A15-U212B
pullup(_A15_2_NE012_);
assign #GATE_DELAY _A15_2_NE012_ = rst ? 0 : ((0|_A15_2_NE01|_A15_2_NE02|_A15_2_NE00) ? 1'b0 : 1'bz);
// Gate A15-U139B
pullup(F11_);
assign #GATE_DELAY F11_ = rst ? 1'bz : ((0|g35203|g35204) ? 1'b0 : 1'bz);
// Gate A15-U148A
pullup(g35234);
assign #GATE_DELAY g35234 = rst ? 0 : ((0|g35229|RUPTOR_) ? 1'b0 : 1'bz);
// Gate A15-U137A
pullup(F12);
assign #GATE_DELAY F12 = rst ? 1'bz : ((0|F12_) ? 1'b0 : 1'bz);
// Gate A15-U136B
pullup(F13);
assign #GATE_DELAY F13 = rst ? 0 : ((0|FB13_|g35202) ? 1'b0 : 1'bz);
// Gate A15-U255B
pullup(g35310);
assign #GATE_DELAY g35310 = rst ? 0 : ((0|XT1_|XB0_|KRPTA_) ? 1'b0 : 1'bz);
// Gate A15-U140A
pullup(F11);
assign #GATE_DELAY F11 = rst ? 0 : ((0|F11_) ? 1'b0 : 1'bz);
// Gate A15-U135B A15-U134A
pullup(F16);
assign #GATE_DELAY F16 = rst ? 0 : ((0|FB14_|FB16_|E7_|g35202) ? 1'b0 : 1'bz);
// Gate A15-U112B
pullup(RL11_);
assign #GATE_DELAY RL11_ = rst ? 1'bz : ((0|g35132|g35126) ? 1'b0 : 1'bz);
// Gate A15-U133A
pullup(F15);
assign #GATE_DELAY F15 = rst ? 0 : ((0|g35212|FB16_|g35202) ? 1'b0 : 1'bz);
// Gate A15-U240A
pullup(RL02_);
assign #GATE_DELAY RL02_ = rst ? 1'bz : ((0|R6|BBK2|CAD2) ? 1'b0 : 1'bz);
// Gate A15-U258B A15-U259B
pullup(KRPTA_);
assign #GATE_DELAY KRPTA_ = rst ? 1'bz : ((0|KRPT) ? 1'b0 : 1'bz);
// Gate A15-U142B
pullup(g35225);
assign #GATE_DELAY g35225 = rst ? 0 : ((0|g35221|g35224|GOJAM) ? 1'b0 : 1'bz);
// Gate A15-U115B
pullup(g35121);
assign #GATE_DELAY g35121 = rst ? 0 : ((0|RFBG_|FB12_) ? 1'b0 : 1'bz);
// Gate A15-U202A A15-U202B
pullup(STR412);
assign #GATE_DELAY STR412 = rst ? 0 : ((0|g35405|g35401|g35408) ? 1'b0 : 1'bz);
// Gate A15-U141B
pullup(g35220);
assign #GATE_DELAY g35220 = rst ? 0 : ((0|KRPTA_|XB4_|XT4_) ? 1'b0 : 1'bz);
// Gate A15-U255A
pullup(g35311);
assign #GATE_DELAY g35311 = rst ? 0 : ((0|g35303|XB0_|CA3_) ? 1'b0 : 1'bz);
// Gate A15-U223B
pullup(_A15_2_NE2510_);
assign #GATE_DELAY _A15_2_NE2510_ = rst ? 1'bz : ((0|_A15_2_NE02|_A15_2_NE10|_A15_2_NE05) ? 1'b0 : 1'bz);
// Gate A15-U141A
pullup(g35221);
assign #GATE_DELAY g35221 = rst ? 0 : ((0|KRPTA_|XB0_|XT5_) ? 1'b0 : 1'bz);
// Gate A15-U224A
pullup(g35437);
assign #GATE_DELAY g35437 = rst ? 1'bz : ((0|F14) ? 1'b0 : 1'bz);
// Gate A15-U242B
pullup(g35340);
assign #GATE_DELAY g35340 = rst ? 1'bz : ((0|UPRUPT|g35341) ? 1'b0 : 1'bz);
// Gate A15-U139A
pullup(g35204);
assign #GATE_DELAY g35204 = rst ? 0 : ((0|S12_|S11_) ? 1'b0 : 1'bz);
// Gate A15-U136A
pullup(F12_);
assign #GATE_DELAY F12_ = rst ? 0 : ((0|g35202|FB12) ? 1'b0 : 1'bz);
// Gate A15-U251A
pullup(g35319);
assign #GATE_DELAY g35319 = rst ? 0 : ((0|g35313|g35317|g35309) ? 1'b0 : 1'bz);
// Gate A15-U213A
pullup(_A15_2_NE02);
assign #GATE_DELAY _A15_2_NE02 = rst ? 0 : ((0|g35437|g35430|_A15_2_FISA16) ? 1'b0 : 1'bz);
// Gate A15-U234B A15-U233A
pullup(g35354);
assign #GATE_DELAY g35354 = rst ? 1'bz : ((0|g35336|g35319|g35314|g35342|PRPOR4) ? 1'b0 : 1'bz);
// Gate A15-U127A
pullup(g35152);
assign #GATE_DELAY g35152 = rst ? 0 : ((0|SUMB14_|SUMA14_|U2BBKG_) ? 1'b0 : 1'bz);
// Gate A15-U206A A15-U206B
pullup(STR19);
assign #GATE_DELAY STR19 = rst ? 0 : ((0|g35411|g35401|g35414) ? 1'b0 : 1'bz);
// Gate A15-U110B
pullup(RL12_);
assign #GATE_DELAY RL12_ = rst ? 1'bz : ((0|g35121|RSTRT|RPTA12) ? 1'b0 : 1'bz);
// Gate A15-U254B
pullup(g35314);
assign #GATE_DELAY g35314 = rst ? 0 : ((0|g35312|g35309) ? 1'b0 : 1'bz);
// Gate A15-U204A
pullup(g35405);
assign #GATE_DELAY g35405 = rst ? 1'bz : ((0|F11) ? 1'b0 : 1'bz);
// Gate A15-U211A
pullup(STR14);
assign #GATE_DELAY STR14 = rst ? 0 : ((0|g35420) ? 1'b0 : 1'bz);
// Gate A15-U204B
pullup(g35408);
assign #GATE_DELAY g35408 = rst ? 0 : ((0|S10) ? 1'b0 : 1'bz);
// Gate A15-U107A
pullup(g35107);
assign #GATE_DELAY g35107 = rst ? 0 : ((0|WL14_|WFBG_) ? 1'b0 : 1'bz);
// Gate A15-U238A
pullup(g35346);
assign #GATE_DELAY g35346 = rst ? 1'bz : ((0|DLKPLS|DNRPTA) ? 1'b0 : 1'bz);
// Gate A15-U214A
pullup(_A15_2_NE03);
assign #GATE_DELAY _A15_2_NE03 = rst ? 0 : ((0|g35437|g35431|_A15_2_FISA16) ? 1'b0 : 1'bz);
// Gate A15-U232A A15-U231A
pullup(g35357);
assign #GATE_DELAY g35357 = rst ? 1'bz : ((0|g35330|g35324|g35336|g35342) ? 1'b0 : 1'bz);
// Gate A15-U239A
pullup(g35342);
assign #GATE_DELAY g35342 = rst ? 0 : ((0|g35340|g35332|g35335) ? 1'b0 : 1'bz);
// Gate A15-U243A
pullup(g35336);
assign #GATE_DELAY g35336 = rst ? 0 : ((0|g35334|g35332) ? 1'b0 : 1'bz);
// Gate A15-U209A
pullup(_A15_2_NE00);
assign #GATE_DELAY _A15_2_NE00 = rst ? 1'bz : ((0|g35430|_A15_2_FISA16|g35423) ? 1'b0 : 1'bz);
// Gate A15-U126B
pullup(RL09_);
assign #GATE_DELAY RL09_ = rst ? 1'bz : ((0|g35147) ? 1'b0 : 1'bz);
// Gate A15-U241A
pullup(g35339);
assign #GATE_DELAY g35339 = rst ? 0 : ((0|KRPTA_|XB4_|XT3_) ? 1'b0 : 1'bz);
// Gate A15-U132B
pullup(F14);
assign #GATE_DELAY F14 = rst ? 0 : ((0|g35211|g35202|FB14_) ? 1'b0 : 1'bz);
// Gate A15-U237B
pullup(DRPRST);
assign #GATE_DELAY DRPRST = rst ? 0 : ((0|KRPTA_|XT4_|XB0_) ? 1'b0 : 1'bz);
// Gate A15-U244B
pullup(g35334);
assign #GATE_DELAY g35334 = rst ? 1'bz : ((0|g35335|MKRPT|KYRPT2) ? 1'b0 : 1'bz);
// Gate A15-U118A
pullup(g35116);
assign #GATE_DELAY g35116 = rst ? 0 : ((0|FB13_|RFBG_) ? 1'b0 : 1'bz);
// Gate A15-U225A
pullup(_A15_2_F15B16);
assign #GATE_DELAY _A15_2_F15B16 = rst ? 1'bz : ((0|g35442) ? 1'b0 : 1'bz);
// Gate A15-U123B
pullup(g35143);
assign #GATE_DELAY g35143 = rst ? 0 : ((0|WEBG_|WL09_) ? 1'b0 : 1'bz);
// Gate A15-U230A
pullup(g35450);
assign #GATE_DELAY g35450 = rst ? 0 : ((0|F15|F16_) ? 1'b0 : 1'bz);
// Gate A15-U155B
pullup(PCDU);
assign #GATE_DELAY PCDU = rst ? 0 : ((0|T12A|PCDU_) ? 1'b0 : 1'bz);
// Gate A15-U131A
pullup(F14_);
assign #GATE_DELAY F14_ = rst ? 1'bz : ((0|F14) ? 1'b0 : 1'bz);
// Gate A15-U219B
pullup(_A15_2_NE04);
assign #GATE_DELAY _A15_2_NE04 = rst ? 0 : ((0|g35430|_A15_2_F15B16|g35423) ? 1'b0 : 1'bz);
// Gate A15-U152A
pullup(MINC);
assign #GATE_DELAY MINC = rst ? 0 : ((0|T12A|MINC_) ? 1'b0 : 1'bz);
// Gate A15-U228B
pullup(ROPET);
assign #GATE_DELAY ROPET = rst ? 0 : ((0|_A15_2_NE6710_) ? 1'b0 : 1'bz);
// Gate A15-U223A
pullup(_A15_2_NE05);
assign #GATE_DELAY _A15_2_NE05 = rst ? 0 : ((0|g35423|_A15_2_F15B16|g35431) ? 1'b0 : 1'bz);
// Gate A15-U101B
pullup(RL13_);
assign #GATE_DELAY RL13_ = rst ? 1'bz : ((0|g35116) ? 1'b0 : 1'bz);
// Gate A15-U137B
pullup(F13_);
assign #GATE_DELAY F13_ = rst ? 1'bz : ((0|F13) ? 1'b0 : 1'bz);
// Gate A15-U160A
pullup(MCDU_);
assign #GATE_DELAY MCDU_ = rst ? 1'bz : ((0|g35248|MCDU) ? 1'b0 : 1'bz);
// Gate A15-U128B
pullup(g35155);
assign #GATE_DELAY g35155 = rst ? 0 : ((0|SUMA11_|U2BBKG_|SUMB11_) ? 1'b0 : 1'bz);
// Gate A15-U111A
pullup(g35123);
assign #GATE_DELAY g35123 = rst ? 0 : ((0|WFBG_|WL11_) ? 1'b0 : 1'bz);
// Gate A15-U245A
pullup(g35331);
assign #GATE_DELAY g35331 = rst ? 1'bz : ((0|g35329|g35326|g35321) ? 1'b0 : 1'bz);
// Gate A15-U103B
pullup(FB16);
assign #GATE_DELAY FB16 = rst ? 0 : ((0|CFBG|FB16_) ? 1'b0 : 1'bz);
// Gate A15-U143B
pullup(g35224);
assign #GATE_DELAY g35224 = rst ? 1'bz : ((0|g35225|HNDRPT) ? 1'b0 : 1'bz);
// Gate A15-U104B
pullup(FB14);
assign #GATE_DELAY FB14 = rst ? 1'bz : ((0|CFBG|FB14_) ? 1'b0 : 1'bz);
// Gate A15-U108B
pullup(FB13);
assign #GATE_DELAY FB13 = rst ? 1'bz : ((0|CFBG|FB13_) ? 1'b0 : 1'bz);
// Gate A15-U115A
pullup(FB12);
assign #GATE_DELAY FB12 = rst ? 1'bz : ((0|FB12_|CFBG) ? 1'b0 : 1'bz);
// Gate A15-U117A
pullup(FB11);
assign #GATE_DELAY FB11 = rst ? 1'bz : ((0|CFBG|FB11_) ? 1'b0 : 1'bz);
// Gate A15-U143A
pullup(g35222);
assign #GATE_DELAY g35222 = rst ? 1'bz : ((0|g35223|RADRPT) ? 1'b0 : 1'bz);
// Gate A15-U156B A15-U155A
pullup(g35241);
assign #GATE_DELAY g35241 = rst ? 1'bz : ((0|C36P|C35P|C33P|C32P|C34P) ? 1'b0 : 1'bz);
// Gate A15-U248B
pullup(g35325);
assign #GATE_DELAY g35325 = rst ? 0 : ((0|XT2_|KRPTA_|XB0_) ? 1'b0 : 1'bz);
// Gate A15-U201A A15-U201B
pullup(g35401);
assign #GATE_DELAY g35401 = rst ? 1'bz : ((0|STRGAT) ? 1'b0 : 1'bz);
// Gate A15-U221B
pullup(_A15_2_036H);
assign #GATE_DELAY _A15_2_036H = rst ? 1'bz : ((0|_A15_2_NE036_|F12_) ? 1'b0 : 1'bz);
// Gate A15-U251B
pullup(g35320);
assign #GATE_DELAY g35320 = rst ? 1'bz : ((0|g35318|g35313|g35309) ? 1'b0 : 1'bz);
// Gate A15-U210B
pullup(_A15_2_036L);
assign #GATE_DELAY _A15_2_036L = rst ? 0 : ((0|_A15_2_NE036_|F12) ? 1'b0 : 1'bz);
// Gate A15-U237A
pullup(PRPOR1);
assign #GATE_DELAY PRPOR1 = rst ? 0 : ((0|g35343) ? 1'b0 : 1'bz);
// Gate A15-U212A
pullup(_A15_2_NE01);
assign #GATE_DELAY _A15_2_NE01 = rst ? 0 : ((0|g35431|g35423|_A15_2_FISA16) ? 1'b0 : 1'bz);
// Gate A15-U117B
pullup(g35135);
assign #GATE_DELAY g35135 = rst ? 0 : ((0|WEBG_|WL10_) ? 1'b0 : 1'bz);
// Gate A15-U236B
pullup(PRPOR2);
assign #GATE_DELAY PRPOR2 = rst ? 0 : ((0|g35346|PRPOR1) ? 1'b0 : 1'bz);
// Gate A15-U119B A15-U112A
pullup(EB10_);
assign #GATE_DELAY EB10_ = rst ? 0 : ((0|g35135|g35136|EB10|g35157) ? 1'b0 : 1'bz);
// Gate A15-U145B A15-U144A
pullup(PRPOR4);
assign #GATE_DELAY PRPOR4 = rst ? 0 : ((0|g35224|g35223|DNRPTA|PRPOR1) ? 1'b0 : 1'bz);
// Gate A15-U225B
pullup(_A15_2_NE06);
assign #GATE_DELAY _A15_2_NE06 = rst ? 0 : ((0|_A15_2_F15B16|g35437|g35430) ? 1'b0 : 1'bz);
// Gate A15-U226A
pullup(_A15_2_NE07);
assign #GATE_DELAY _A15_2_NE07 = rst ? 0 : ((0|_A15_2_F15B16|g35437|g35431) ? 1'b0 : 1'bz);
// Gate A15-U226B
pullup(_A15_2_2510H);
assign #GATE_DELAY _A15_2_2510H = rst ? 0 : ((0|_A15_2_NE2510_|F12_) ? 1'b0 : 1'bz);
// Gate A15-U138A
pullup(g35203);
assign #GATE_DELAY g35203 = rst ? 0 : ((0|FB11_|g35202) ? 1'b0 : 1'bz);
// Gate A15-U214B
pullup(_A15_2_2510L);
assign #GATE_DELAY _A15_2_2510L = rst ? 0 : ((0|_A15_2_NE2510_|F12) ? 1'b0 : 1'bz);
// Gate A15-U125A
pullup(g35147);
assign #GATE_DELAY g35147 = rst ? 0 : ((0|EB9_|REBG_) ? 1'b0 : 1'bz);
// Gate A15-U125B
pullup(BBK1);
assign #GATE_DELAY BBK1 = rst ? 0 : ((0|RBBEG_|EB9_) ? 1'b0 : 1'bz);
// Gate A15-U114B
pullup(BBK3);
assign #GATE_DELAY BBK3 = rst ? 0 : ((0|RBBEG_|EB11_) ? 1'b0 : 1'bz);
// Gate A15-U120A
pullup(BBK2);
assign #GATE_DELAY BBK2 = rst ? 0 : ((0|EB10_|RBBEG_) ? 1'b0 : 1'bz);
// Gate A15-U247B
pullup(g35328);
assign #GATE_DELAY g35328 = rst ? 1'bz : ((0|KYRPT1|g35329) ? 1'b0 : 1'bz);
// Gate A15-U252A
pullup(g35318);
assign #GATE_DELAY g35318 = rst ? 0 : ((0|GOJAM|g35315|g35317) ? 1'b0 : 1'bz);
// Gate A15-U124B
pullup(EB9);
assign #GATE_DELAY EB9 = rst ? 1'bz : ((0|EB9_|CEBG) ? 1'b0 : 1'bz);
// Gate A15-U104A
pullup(BK16);
assign #GATE_DELAY BK16 = rst ? 0 : ((0|RFBG_|FB16_) ? 1'b0 : 1'bz);
// Gate A15-U238B
pullup(DNRPTA);
assign #GATE_DELAY DNRPTA = rst ? 0 : ((0|DRPRST|GOJAM|g35346) ? 1'b0 : 1'bz);
// Gate A15-U107B
pullup(g35113);
assign #GATE_DELAY g35113 = rst ? 0 : ((0|WFBG_|WL13_) ? 1'b0 : 1'bz);
// Gate A15-U159A
pullup(g35248);
assign #GATE_DELAY g35248 = rst ? 0 : ((0|g35246|INCSET_) ? 1'b0 : 1'bz);
// Gate A15-U229A
pullup(_A15_2_NE10);
assign #GATE_DELAY _A15_2_NE10 = rst ? 0 : ((0|g35451|g35430|g35423) ? 1'b0 : 1'bz);
// Gate A15-U103A A15-U102A
pullup(FB16_);
assign #GATE_DELAY FB16_ = rst ? 1'bz : ((0|g35101|FB16|g35151) ? 1'b0 : 1'bz);
// Gate A15-U128A
pullup(g35154);
assign #GATE_DELAY g35154 = rst ? 0 : ((0|U2BBKG_|SUMA12_|SUMB12_) ? 1'b0 : 1'bz);
// Gate A15-U122A
pullup(g35144);
assign #GATE_DELAY g35144 = rst ? 0 : ((0|WBBEG_|WL01_) ? 1'b0 : 1'bz);
// Gate A15-U109B
pullup(g35118);
assign #GATE_DELAY g35118 = rst ? 0 : ((0|WFBG_|WL12_) ? 1'b0 : 1'bz);
// Gate A15-U133B
pullup(F15_);
assign #GATE_DELAY F15_ = rst ? 1'bz : ((0|F15) ? 1'b0 : 1'bz);
// Gate A15-U253A
pullup(g35313);
assign #GATE_DELAY g35313 = rst ? 0 : ((0|GOJAM|g35310|g35312) ? 1'b0 : 1'bz);
// Gate A15-U208A
pullup(_A15_2_FISA16);
assign #GATE_DELAY _A15_2_FISA16 = rst ? 0 : ((0|g35415) ? 1'b0 : 1'bz);
// Gate A15-U216A
pullup(g35428);
assign #GATE_DELAY g35428 = rst ? 0 : ((0|_A15_2_036L|_A15_2_036H|_A15_2_147L) ? 1'b0 : 1'bz);
// Gate A15-U247A
pullup(KY1RST);
assign #GATE_DELAY KY1RST = rst ? 0 : ((0|XB4_|XT2_|KRPTA_) ? 1'b0 : 1'bz);
// Gate A15-U217A
pullup(RL01_);
assign #GATE_DELAY RL01_ = rst ? 1'bz : ((0|RB1F|CAD1|BBK1) ? 1'b0 : 1'bz);
// Gate A15-U150A
pullup(RL14_);
assign #GATE_DELAY RL14_ = rst ? 1'bz : ((0|g35111) ? 1'b0 : 1'bz);
// Gate A15-U215B
pullup(_A15_2_NE147_);
assign #GATE_DELAY _A15_2_NE147_ = rst ? 1'bz : ((0|_A15_2_NE01|_A15_2_NE04|_A15_2_NE07) ? 1'b0 : 1'bz);
// Gate A15-U160B
pullup(MCDU);
assign #GATE_DELAY MCDU = rst ? 0 : ((0|MCDU_|T12A) ? 1'b0 : 1'bz);
// Gate A15-U249A
pullup(g35322);
assign #GATE_DELAY g35322 = rst ? 0 : ((0|CA2_|g35303|XB7_) ? 1'b0 : 1'bz);
// Gate A15-U259A
pullup(g35303);
assign #GATE_DELAY g35303 = rst ? 1'bz : ((0|g35302) ? 1'b0 : 1'bz);
// Gate A15-U209B
pullup(_A15_2_NE036_);
assign #GATE_DELAY _A15_2_NE036_ = rst ? 0 : ((0|_A15_2_NE03|_A15_2_NE06|_A15_2_NE00) ? 1'b0 : 1'bz);
// Gate A15-U216B
pullup(_A15_2_147H);
assign #GATE_DELAY _A15_2_147H = rst ? 0 : ((0|_A15_2_NE147_|F12_) ? 1'b0 : 1'bz);
// Gate A15-U222A
pullup(_A15_2_147L);
assign #GATE_DELAY _A15_2_147L = rst ? 0 : ((0|_A15_2_NE147_|F12) ? 1'b0 : 1'bz);
// Gate A15-U152B
pullup(MINC_);
assign #GATE_DELAY MINC_ = rst ? 1'bz : ((0|g35238|MINC) ? 1'b0 : 1'bz);
// Gate A15-U148B
pullup(RUPTOR_);
assign #GATE_DELAY RUPTOR_ = rst ? 1'bz : ((0|g35234|T10) ? 1'b0 : 1'bz);
// Gate A15-U129B
pullup(g35156);
assign #GATE_DELAY g35156 = rst ? 0 : ((0|U2BBKG_|SUMB03_|SUMA03_) ? 1'b0 : 1'bz);
// End of NOR gates


endmodule
