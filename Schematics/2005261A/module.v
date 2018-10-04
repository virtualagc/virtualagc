// Verilog module auto-generated for AGC module A5 by dumbVerilog.py

module A5 ( 
  rst, ADS0, BR1, BR12B_, BR1B2_, BR1_, BR2, BR2_, BRDIF_, C24A, C25A, C26A,
  C27A, C30A, C37P, C40P, C41P, C42P, C43P, C44P, CCS0, CCS0_, CGA5, CHINC_,
  DAS0, DAS0_, DAS1, DAS1_, DIV_, DV1, DV1_, DV4, DV4_, DXCH0, EDSET, FETCH0,
  FETCH0_, GOJ1, GOJ1_, GOJAM, IC1, IC10, IC10_, IC11_, IC12, IC12_, IC13,
  IC14, IC15_, IC16, IC16_, IC2, IC2_, IC3, IC4, IC5, IC5_, IC8_, IC9, INCSET_,
  INKL_, INOUT, INOUT_, MASK0, MASK0_, MONWBK, MONpCH, MP0, MP3, MP3_, MSU0,
  MSU0_, NDX0_, PRINC, QXCH0_, RAND0, READ0, ROR0, RSM3, RSM3_, RUPT0, RXOR0,
  RXOR0_, S11, S12, SHANC_, SHIFT, SHIFT_, STD2, STFET1_, T01, T01_, T02_,
  T03_, T04_, T05_, T06_, T07_, T08_, T09_, T10_, T11_, T12, T12USE_, T12_,
  TC0, TC0_, TCF0, TCSAJ3_, TS0, TS0_, WAND0, WOR0, XT0_, XT2_, XT3_, XT4_,
  XT5_, XT6_, YB0_, YT0_, d4XP5, d5XP11, A2X_, CI_, DV1B1B, MONEX_, P03,
  PARTC, RA_, RB_, RC_, RG_, RL_, RU_, RZ_, ST2_, TMZ_, TOV_, TSGN_, WA_,
  WB_, WG_, WL_, WS_, WY12_, WYD_, WY_, WZ_, Z15_, Z16_, d10XP6, DV4B1B,
  DVST, GNHNC, NDR100_, NISQ_, OCTAD2, OCTAD3, OCTAD4, OCTAD5, OCTAD6, PINC,
  PINC_, PTWOX, R6, RAD, RL10BB, RQ, RSCT, RSTRT, RSTSTG, SCAD, SCAD_, TPZG_,
  TRSM, TSUDO_, U2BBK, d10XP1, d10XP8, d11XP2, d2XP7, d2XP8, d3XP6, d5XP12,
  d5XP15, d5XP21, d6XP8, d7XP4, d7XP9, d9XP5
);

input wire rst, ADS0, BR1, BR12B_, BR1B2_, BR1_, BR2, BR2_, BRDIF_, C24A,
  C25A, C26A, C27A, C30A, C37P, C40P, C41P, C42P, C43P, C44P, CCS0, CCS0_,
  CGA5, CHINC_, DAS0, DAS0_, DAS1, DAS1_, DIV_, DV1, DV1_, DV4, DV4_, DXCH0,
  EDSET, FETCH0, FETCH0_, GOJ1, GOJ1_, GOJAM, IC1, IC10, IC10_, IC11_, IC12,
  IC12_, IC13, IC14, IC15_, IC16, IC16_, IC2, IC2_, IC3, IC4, IC5, IC5_,
  IC8_, IC9, INCSET_, INKL_, INOUT, INOUT_, MASK0, MASK0_, MONWBK, MONpCH,
  MP0, MP3, MP3_, MSU0, MSU0_, NDX0_, PRINC, QXCH0_, RAND0, READ0, ROR0,
  RSM3, RSM3_, RUPT0, RXOR0, RXOR0_, S11, S12, SHANC_, SHIFT, SHIFT_, STD2,
  STFET1_, T01, T01_, T02_, T03_, T04_, T05_, T06_, T07_, T08_, T09_, T10_,
  T11_, T12, T12USE_, T12_, TC0, TC0_, TCF0, TCSAJ3_, TS0, TS0_, WAND0, WOR0,
  XT0_, XT2_, XT3_, XT4_, XT5_, XT6_, YB0_, YT0_, d4XP5, d5XP11;

inout wire A2X_, CI_, DV1B1B, MONEX_, P03, PARTC, RA_, RB_, RC_, RG_, RL_,
  RU_, RZ_, ST2_, TMZ_, TOV_, TSGN_, WA_, WB_, WG_, WL_, WS_, WY12_, WYD_,
  WY_, WZ_, Z15_, Z16_, d10XP6;

output wire DV4B1B, DVST, GNHNC, NDR100_, NISQ_, OCTAD2, OCTAD3, OCTAD4,
  OCTAD5, OCTAD6, PINC, PINC_, PTWOX, R6, RAD, RL10BB, RQ, RSCT, RSTRT, RSTSTG,
  SCAD, SCAD_, TPZG_, TRSM, TSUDO_, U2BBK, d10XP1, d10XP8, d11XP2, d2XP7,
  d2XP8, d3XP6, d5XP12, d5XP15, d5XP21, d6XP8, d7XP4, d7XP9, d9XP5;

// Gate A5-U115B
pullup(ST2_);
assign (highz1,strong0) #0.2  ST2_ = rst ? 1 : ~(0|A5U114Pad1|A5U103Pad9);
// Gate A5-U121B
pullup(A5U117Pad8);
assign (highz1,strong0) #0.2  A5U117Pad8 = rst ? 0 : ~(0|BR12B_|DAS0_);
// Gate A5-U227B
pullup(A5U225Pad7);
assign (highz1,strong0) #0.2  A5U225Pad7 = rst ? 1 : ~(0|DV1B1B|ROR0|WOR0);
// Gate A5-U257B
pullup(OCTAD3);
assign (highz1,strong0) #0.2  OCTAD3 = rst ? 0 : ~(0|XT3_|NDR100_);
// Gate A5-U158B
pullup(A5U150Pad7);
assign (highz1,strong0) #0.2  A5U150Pad7 = rst ? 0 : ~(0|T07_|DAS0_);
// Gate A5-U255A
pullup(OCTAD5);
assign (highz1,strong0) #0.2  OCTAD5 = rst ? 0 : ~(0|XT5_|NDR100_);
// Gate A5-U226A
pullup(A5U225Pad2);
assign (highz1,strong0) #0.2  A5U225Pad2 = rst ? 0 : ~(0|DV1_|BR1_);
// Gate A5-U152B
pullup(A5U150Pad3);
assign (highz1,strong0) #0.2  A5U150Pad3 = rst ? 0 : ~(0|RSM3_|T06_);
// Gate A5-U131B
pullup(A5U131Pad2);
assign (highz1,strong0) #0.2  A5U131Pad2 = rst ? 1 : ~(0|TC0|TCF0|IC4);
// Gate A5-U131A
pullup(A5U131Pad1);
assign (highz1,strong0) #0.2  A5U131Pad1 = rst ? 0 : ~(0|A5U131Pad2|T01_);
// Gate A5-U210A
pullup(Z15_);
assign (highz1,strong0) #0.2  Z15_ = rst ? 0 : ~(0|A5U210Pad2);
// Gate A5-U108B
pullup(RAD);
assign (highz1,strong0) #0.2  RAD = rst ? 0 : ~(0|TSUDO_|T08_);
// Gate A5-U239B
pullup(RQ);
assign (highz1,strong0) #0.2  RQ = rst ? 0 : ~(0|QXCH0_|T03_);
// Gate A5-U209A
pullup(A5U209Pad1);
assign (highz1,strong0) #0.2  A5U209Pad1 = rst ? 0 : ~(0|T07_|A5U207Pad9);
// Gate A5-U123A
pullup(A5U115Pad4);
assign (highz1,strong0) #0.2  A5U115Pad4 = rst ? 0 : ~(0|A5U123Pad2|T11_);
// Gate A5-U144B
pullup(A5U144Pad9);
assign (highz1,strong0) #0.2  A5U144Pad9 = rst ? 0 : ~(0|T04_|DAS0_);
// Gate A5-U212A A5-U212B
pullup(WL_);
assign (highz1,strong0) #0.2  WL_ = rst ? 1 : ~(0|A5U210Pad8|A5U205Pad1|A5U201Pad1|A5P13);
// Gate A5-U133A
pullup(A5U133Pad1);
assign (highz1,strong0) #0.2  A5U133Pad1 = rst ? 0 : ~(0|T01_|A5U133Pad3);
// Gate A5-U134B
pullup(A5U133Pad3);
assign (highz1,strong0) #0.2  A5U133Pad3 = rst ? 1 : ~(0|IC2|IC10|IC3);
// Gate A5-U140A
pullup(A5U140Pad1);
assign (highz1,strong0) #0.2  A5U140Pad1 = rst ? 0 : ~(0|IC2_|T04_);
// Gate A5-U133B
pullup(A5U133Pad9);
assign (highz1,strong0) #0.2  A5U133Pad9 = rst ? 1 : ~(0|STD2|IC2);
// Gate A5-U120B A5-U141A A5-U238A
pullup(RA_);
assign (highz1,strong0) #0.2  RA_ = rst ? 1 : ~(0|A5U118Pad9|A5U120Pad3|A5U140Pad1|A5U139Pad9|A5P2|A5U236Pad1);
// Gate A5-U258A A5-U257A
pullup(NDR100_);
assign (highz1,strong0) #0.2  NDR100_ = rst ? 1 : ~(0|A5U258Pad2|A5U257Pad2);
// Gate A5-U259A
pullup(A5U258Pad2);
assign (highz1,strong0) #0.2  A5U258Pad2 = rst ? 0 : ~(0|YB0_|YT0_);
// Gate A5-U110B A5-U218A
pullup(WZ_);
assign (highz1,strong0) #0.2  WZ_ = rst ? 1 : ~(0|A5U109Pad3|A5U110Pad7|A5U103Pad9|A5U216Pad2);
// Gate A5-U233B
pullup(R6);
assign (highz1,strong0) #0.2  R6 = rst ? 0 : ~(0|FETCH0_|T01_);
// Gate A5-U148B
pullup(PARTC);
assign (highz1,strong0) #0.2  PARTC = rst ? 0 : ~(0|SHIFT|MONpCH|INKL_);
// Gate A5-U114A
pullup(A5U114Pad1);
assign (highz1,strong0) #0.2  A5U114Pad1 = rst ? 0 : ~(0|CCS0_|T10_);
// Gate A5-U121A
pullup(A5U120Pad3);
assign (highz1,strong0) #0.2  A5U120Pad3 = rst ? 0 : ~(0|MASK0_|T09_);
// Gate A5-U124A
pullup(A5U120Pad2);
assign (highz1,strong0) #0.2  A5U120Pad2 = rst ? 0 : ~(0|MASK0_|T11_);
// Gate A5-U218B A5-U219B
pullup(A5U218Pad9);
assign (highz1,strong0) #0.2  A5U218Pad9 = rst ? 1 : ~(0|IC2|TS0|IC3|IC16|MP3);
// Gate A5-U256B
pullup(OCTAD4);
assign (highz1,strong0) #0.2  OCTAD4 = rst ? 0 : ~(0|XT4_|NDR100_);
// Gate A5-U223B
pullup(A5U223Pad9);
assign (highz1,strong0) #0.2  A5U223Pad9 = rst ? 0 : ~(0|A5U215Pad3|T05_);
// Gate A5-U118B
pullup(A5U118Pad9);
assign (highz1,strong0) #0.2  A5U118Pad9 = rst ? 0 : ~(0|A5U116Pad1|T10_);
// Gate A5-U138A
pullup(A5U138Pad1);
assign (highz1,strong0) #0.2  A5U138Pad1 = rst ? 0 : ~(0|T10_|MP3_);
// Gate A5-U227A
pullup(A5U224Pad7);
assign (highz1,strong0) #0.2  A5U224Pad7 = rst ? 1 : ~(0|RAND0|WAND0|A5U225Pad2);
// Gate A5-U213A
pullup(A5U211Pad7);
assign (highz1,strong0) #0.2  A5U211Pad7 = rst ? 0 : ~(0|T07_|STFET1_);
// Gate A5-U228A
pullup(DV1B1B);
assign (highz1,strong0) #0.2  DV1B1B = rst ? 0 : ~(0|DV1_|BR1);
// Gate A5-U203A
pullup(A5U203Pad1);
assign (highz1,strong0) #0.2  A5U203Pad1 = rst ? 0 : ~(0|RXOR0_|T11_);
// Gate A5-U111A
pullup(A5U109Pad3);
assign (highz1,strong0) #0.2  A5U109Pad3 = rst ? 0 : ~(0|CCS0_|T08_);
// Gate A5-U106A
pullup(P03);
assign (highz1,strong0) #0.2  P03 = rst ? 1 : ~(0|EDSET);
// Gate A5-U123B
pullup(d11XP2);
assign (highz1,strong0) #0.2  d11XP2 = rst ? 0 : ~(0|T11_|MSU0_);
// Gate A5-U129A A5-U129B A5-U126A A5-U128B
pullup(A5U124Pad7);
assign (highz1,strong0) #0.2  A5U124Pad7 = rst ? 0 : ~(0|C37P|C40P|C41P|C44P|C43P|C42P|C26A|C25A|C24A|C27A|C30A);
// Gate A5-U124B
pullup(A5U124Pad9);
assign (highz1,strong0) #0.2  A5U124Pad9 = rst ? 0 : ~(0|A5U124Pad7|INCSET_);
// Gate A5-U254A
pullup(Z16_);
assign (highz1,strong0) #0.2  Z16_ = rst ? 0 : ~(0|A5U223Pad9);
// Gate A5-U215B
pullup(A5U215Pad9);
assign (highz1,strong0) #0.2  A5U215Pad9 = rst ? 0 : ~(0|T09_|DAS1_);
// Gate A5-U233A
pullup(A5U231Pad4);
assign (highz1,strong0) #0.2  A5U231Pad4 = rst ? 0 : ~(0|CHINC_|T01_);
// Gate A5-U258B
pullup(SCAD_);
assign (highz1,strong0) #0.2  SCAD_ = rst ? 1 : ~(0|SCAD);
// Gate A5-U253A
pullup(TRSM);
assign (highz1,strong0) #0.2  TRSM = rst ? 0 : ~(0|NDX0_|T05_);
// Gate A5-U246B
pullup(A5P9);
assign (highz1,strong0) #0.2  A5P9 = rst ? 0 : ~(0|SHIFT_|T05_);
// Gate A5-U107A
pullup(A5U107Pad1);
assign (highz1,strong0) #0.2  A5U107Pad1 = rst ? 1 : ~(0|IC16);
// Gate A5-U204B
pullup(A5U204Pad4);
assign (highz1,strong0) #0.2  A5U204Pad4 = rst ? 0 : ~(0|BR2|ADS0|DAS1_);
// Gate A5-U232A
pullup(RL10BB);
assign (highz1,strong0) #0.2  RL10BB = rst ? 0 : ~(0|T01_|A5U231Pad9);
// Gate A5-U231B A5-U237A A5-U232B
pullup(A5U231Pad9);
assign (highz1,strong0) #0.2  A5U231Pad9 = rst ? 1 : ~(0|DXCH0|IC9|PRINC|INOUT|DAS1|DAS0|IC12);
// Gate A5-U149B A5-U245A A5-U245B A5-U211B
pullup(RG_);
assign (highz1,strong0) #0.2  RG_ = rst ? 1 : ~(0|A5U149Pad6|A5U149Pad7|A5U143Pad3|d5XP15|A5U245Pad3|A5P13|A5U240Pad3|A5U245Pad7|A5P9|A5U209Pad1|A5U211Pad7|A5U203Pad1);
// Gate A5-U158A
pullup(A5U149Pad6);
assign (highz1,strong0) #0.2  A5U149Pad6 = rst ? 0 : ~(0|IC2_|T07_);
// Gate A5-U234B
pullup(RSCT);
assign (highz1,strong0) #0.2  RSCT = rst ? 0 : ~(0|T01_|INKL_|MONpCH);
// Gate A5-U209B
pullup(RSTSTG);
assign (highz1,strong0) #0.2  RSTSTG = rst ? 0 : ~(0|T08_|DV4_);
// Gate A5-U228B
pullup(DV4B1B);
assign (highz1,strong0) #0.2  DV4B1B = rst ? 0 : ~(0|DV4_|BR1);
// Gate A5-U252A
pullup(A5U251Pad2);
assign (highz1,strong0) #0.2  A5U251Pad2 = rst ? 1 : ~(0|MP3);
// Gate A5-U127B
pullup(PINC_);
assign (highz1,strong0) #0.2  PINC_ = rst ? 1 : ~(0|A5U124Pad9|PINC);
// Gate A5-U215A
pullup(A5U210Pad2);
assign (highz1,strong0) #0.2  A5U210Pad2 = rst ? 0 : ~(0|T09_|A5U215Pad3);
// Gate A5-U137A
pullup(NISQ_);
assign (highz1,strong0) #0.2  NISQ_ = rst ? 1 : ~(0|d2XP7|A5U136Pad1|A58XP15);
// Gate A5-U152A A5-U208B
pullup(TSGN_);
assign (highz1,strong0) #0.2  TSGN_ = rst ? 1 : ~(0|A5U139Pad9|d7XP9|A5U143Pad3|A5P9|RSTSTG);
// Gate A5-U214A
pullup(A5U210Pad8);
assign (highz1,strong0) #0.2  A5U210Pad8 = rst ? 0 : ~(0|T09_|DV4_);
// Gate A5-U213B
pullup(U2BBK);
assign (highz1,strong0) #0.2  U2BBK = rst ? 0 : ~(0|T08_|MONWBK|STFET1_);
// Gate A5-U201B
pullup(A5J4Pad404);
assign (highz1,strong0) #0.2  A5J4Pad404 = rst ? 1 : ~(0);
// Gate A5-U225A
pullup(A5U215Pad3);
assign (highz1,strong0) #0.2  A5U215Pad3 = rst ? 1 : ~(0|A5U225Pad2);
// Gate A5-U136B
pullup(DVST);
assign (highz1,strong0) #0.2  DVST = rst ? 0 : ~(0|STD2|T02_|DIV_);
// Gate A5-U103B
pullup(A5U103Pad9);
assign (highz1,strong0) #0.2  A5U103Pad9 = rst ? 0 : ~(0|TCSAJ3_|T08_);
// Gate A5-U108A A5-U106B
pullup(TSUDO_);
assign (highz1,strong0) #0.2  TSUDO_ = rst ? 1 : ~(0|RSM3|IC3|MP3|IC16);
// Gate A5-U150A
pullup(WG_);
assign (highz1,strong0) #0.2  WG_ = rst ? 1 : ~(0|A5U139Pad9|A5U150Pad3|d9XP5);
// Gate A5-U243B
pullup(A5U243Pad2);
assign (highz1,strong0) #0.2  A5U243Pad2 = rst ? 1 : ~(0|DAS1|PRINC|PARTC);
// Gate A5-U135A
pullup(A5U132Pad6);
assign (highz1,strong0) #0.2  A5U132Pad6 = rst ? 0 : ~(0|IC10_|T01_);
// Gate A5-U105A
pullup(A58XP12);
assign (highz1,strong0) #0.2  A58XP12 = rst ? 0 : ~(0|DAS0_|T08_);
// Gate A5-U107B
pullup(A58XP15);
assign (highz1,strong0) #0.2  A58XP15 = rst ? 0 : ~(0|A5U107Pad1|T08_);
// Gate A5-U260A
pullup(A5U257Pad2);
assign (highz1,strong0) #0.2  A5U257Pad2 = rst ? 0 : ~(0|S11|S12);
// Gate A5-U140B
pullup(d3XP6);
assign (highz1,strong0) #0.2  d3XP6 = rst ? 0 : ~(0|T03_|TC0_);
// Gate A5-U113A
pullup(d10XP1);
assign (highz1,strong0) #0.2  d10XP1 = rst ? 0 : ~(0|T10_|A5U113Pad3);
// Gate A5-U114B
pullup(d10XP6);
assign (highz1,strong0) #0.2  d10XP6 = rst ? 0 : ~(0|T10_|BR2|CCS0_);
// Gate A5-U153A
pullup(A5U153Pad1);
assign (highz1,strong0) #0.2  A5U153Pad1 = rst ? 0 : ~(0|MSU0_|T06_);
// Gate A5-U117A
pullup(d10XP8);
assign (highz1,strong0) #0.2  d10XP8 = rst ? 0 : ~(0|BR1B2_|T10_|DAS0_);
// Gate A5-U147B
pullup(A5U147Pad2);
assign (highz1,strong0) #0.2  A5U147Pad2 = rst ? 1 : ~(0|PRINC|PARTC|CCS0);
// Gate A5-U149A A5-U220B
pullup(TMZ_);
assign (highz1,strong0) #0.2  TMZ_ = rst ? 1 : ~(0|A5U139Pad9|A5U143Pad3|A5U215Pad9);
// Gate A5-U201A
pullup(A5U201Pad1);
assign (highz1,strong0) #0.2  A5U201Pad1 = rst ? 0 : ~(0|T12_|T12USE_|DV1_);
// Gate A5-U147A
pullup(A5U143Pad3);
assign (highz1,strong0) #0.2  A5U143Pad3 = rst ? 0 : ~(0|A5U147Pad2|T05_);
// Gate A5-U112B
pullup(A58XP3);
assign (highz1,strong0) #0.2  A58XP3 = rst ? 0 : ~(0|A5U112Pad1|T08_);
// Gate A5-U128A A5-U155B A5-U249B
pullup(WY_);
assign (highz1,strong0) #0.2  WY_ = rst ? 1 : ~(0|A5U114Pad1|A5U120Pad3|A5U118Pad9|A5U149Pad7|A5U153Pad1|A5U149Pad6|A5XP10|A5U243Pad1|d2XP8);
// Gate A5-U203B
pullup(A5XP6);
assign (highz1,strong0) #0.2  A5XP6 = rst ? 0 : ~(0|DV1_|T11_);
// Gate A5-U205B
pullup(A5XP10);
assign (highz1,strong0) #0.2  A5XP10 = rst ? 0 : ~(0|T10_|IC11_);
// Gate A5-U256A
pullup(OCTAD2);
assign (highz1,strong0) #0.2  OCTAD2 = rst ? 0 : ~(0|XT2_|NDR100_);
// Gate A5-U159A A5-U247A
pullup(WY12_);
assign (highz1,strong0) #0.2  WY12_ = rst ? 1 : ~(0|A5U133Pad1|d4XP5|A5U157Pad1|A5U247Pad2|A5U247Pad3);
// Gate A5-U224A
pullup(A5U222Pad2);
assign (highz1,strong0) #0.2  A5U222Pad2 = rst ? 0 : ~(0|A5U222Pad9|T05_);
// Gate A5-U111B
pullup(A5U110Pad3);
assign (highz1,strong0) #0.2  A5U110Pad3 = rst ? 0 : ~(0|FETCH0|T08_|INKL_);
// Gate A5-U101B
pullup(A5U101Pad2);
assign (highz1,strong0) #0.2  A5U101Pad2 = rst ? 0 : ~(0|GOJAM|GNHNC);
// Gate A5-U153B
pullup(A5U149Pad7);
assign (highz1,strong0) #0.2  A5U149Pad7 = rst ? 0 : ~(0|T06_|DAS0_);
// Gate A5-U251A
pullup(A5U247Pad3);
assign (highz1,strong0) #0.2  A5U247Pad3 = rst ? 0 : ~(0|A5U251Pad2|T05_);
// Gate A5-U251B
pullup(A5U247Pad2);
assign (highz1,strong0) #0.2  A5U247Pad2 = rst ? 0 : ~(0|IC16_|T05_);
// Gate A5-U252B
pullup(A5U245Pad3);
assign (highz1,strong0) #0.2  A5U245Pad3 = rst ? 0 : ~(0|IC5_|T05_);
// Gate A5-U253B
pullup(d5XP21);
assign (highz1,strong0) #0.2  d5XP21 = rst ? 0 : ~(0|CHINC_|T05_);
// Gate A5-U247B
pullup(A5U245Pad7);
assign (highz1,strong0) #0.2  A5U245Pad7 = rst ? 0 : ~(0|T05_|DAS1_);
// Gate A5-U132B
pullup(MONEX_);
assign (highz1,strong0) #0.2  MONEX_ = rst ? 1 : ~(0|A5U132Pad6|d10XP6|A510XP7);
// Gate A5-U223A A5-U222B
pullup(A5U222Pad9);
assign (highz1,strong0) #0.2  A5U222Pad9 = rst ? 1 : ~(0|IC2|READ0|IC5|DV4|A5U222Pad8);
// Gate A5-U104B
pullup(RSTRT);
assign (highz1,strong0) #0.2  RSTRT = rst ? 0 : ~(0|GOJ1_|T08_);
// Gate A5-U207A
pullup(A5U206Pad3);
assign (highz1,strong0) #0.2  A5U206Pad3 = rst ? 1 : ~(0|IC2|IC14|DV1);
// Gate A5-U146A
pullup(A5U145Pad2);
assign (highz1,strong0) #0.2  A5U145Pad2 = rst ? 0 : ~(0|MASK0_|T04_);
// Gate A5-U216B
pullup(TOV_);
assign (highz1,strong0) #0.2  TOV_ = rst ? 1 : ~(0|A5P7|d6XP8);
// Gate A5-U117B
pullup(A5U116Pad7);
assign (highz1,strong0) #0.2  A5U116Pad7 = rst ? 1 : ~(0|A5U116Pad2|A5U117Pad8);
// Gate A5-U206A
pullup(A5U206Pad1);
assign (highz1,strong0) #0.2  A5U206Pad1 = rst ? 0 : ~(0|T10_|A5U206Pad3);
// Gate A5-U126B
pullup(A5U116Pad2);
assign (highz1,strong0) #0.2  A5U116Pad2 = rst ? 0 : ~(0|MSU0_|BR1_);
// Gate A5-U105B
pullup(A5U104Pad2);
assign (highz1,strong0) #0.2  A5U104Pad2 = rst ? 1 : ~(0|IC2|IC4|DXCH0);
// Gate A5-U104A
pullup(A5U104Pad1);
assign (highz1,strong0) #0.2  A5U104Pad1 = rst ? 0 : ~(0|A5U104Pad2|T08_);
// Gate A5-U116A
pullup(A5U116Pad1);
assign (highz1,strong0) #0.2  A5U116Pad1 = rst ? 1 : ~(0|A5U116Pad2|DAS0);
// Gate A5-U145A A5-U115A A5-U222A
pullup(WA_);
assign (highz1,strong0) #0.2  WA_ = rst ? 1 : ~(0|A5U145Pad2|A5U144Pad9|A5U110Pad2|d5XP11|A5U115Pad4|A5U222Pad2|A5U210Pad2);
// Gate A5-U241A
pullup(A5U240Pad2);
assign (highz1,strong0) #0.2  A5U240Pad2 = rst ? 0 : ~(0|A5U241Pad2|T04_);
// Gate A5-U244B
pullup(A5U240Pad3);
assign (highz1,strong0) #0.2  A5U240Pad3 = rst ? 0 : ~(0|IC12_|T05_);
// Gate A5-U113B
pullup(A5U113Pad3);
assign (highz1,strong0) #0.2  A5U113Pad3 = rst ? 1 : ~(0|IC1|RUPT0|IC10);
// Gate A5-U224B
pullup(A5U221Pad2);
assign (highz1,strong0) #0.2  A5U221Pad2 = rst ? 0 : ~(0|A5U224Pad7|T05_);
// Gate A5-U118A
pullup(d9XP5);
assign (highz1,strong0) #0.2  d9XP5 = rst ? 0 : ~(0|T09_|DAS0_);
// Gate A5-U217B
pullup(A5P2);
assign (highz1,strong0) #0.2  A5P2 = rst ? 0 : ~(0|INOUT_|RXOR0|T06_);
// Gate A5-U156B
pullup(d7XP4);
assign (highz1,strong0) #0.2  d7XP4 = rst ? 0 : ~(0|CCS0_|BR2_|T07_);
// Gate A5-U219A
pullup(A5P7);
assign (highz1,strong0) #0.2  A5P7 = rst ? 0 : ~(0|T06_|DV4_);
// Gate A5-U146B
pullup(d5XP12);
assign (highz1,strong0) #0.2  d5XP12 = rst ? 0 : ~(0|T05_|DAS0_);
// Gate A5-U208A
pullup(WYD_);
assign (highz1,strong0) #0.2  WYD_ = rst ? 1 : ~(0|A5P9|A5XP6);
// Gate A5-U246A
pullup(d5XP15);
assign (highz1,strong0) #0.2  d5XP15 = rst ? 0 : ~(0|T05_|QXCH0_);
// Gate A5-U243A
pullup(A5U243Pad1);
assign (highz1,strong0) #0.2  A5U243Pad1 = rst ? 0 : ~(0|A5U243Pad2|T05_);
// Gate A5-U145B A5-U238B
pullup(RL_);
assign (highz1,strong0) #0.2  RL_ = rst ? 1 : ~(0|A5U144Pad9|A5U138Pad1|A58XP12|A5XP6|A5U238Pad7|A5U238Pad8);
// Gate A5-U109A A5-U211A A5-U216A
pullup(RU_);
assign (highz1,strong0) #0.2  RU_ = rst ? 1 : ~(0|d9XP5|A5U109Pad3|A5U104Pad1|A5U201Pad1|A5U210Pad8|A5U206Pad1|A5U216Pad2|d6XP8|d5XP11);
// Gate A5-U207B
pullup(A5U207Pad9);
assign (highz1,strong0) #0.2  A5U207Pad9 = rst ? 1 : ~(0|DV1|IC14|IC13);
// Gate A5-U242A
pullup(A5U241Pad2);
assign (highz1,strong0) #0.2  A5U241Pad2 = rst ? 1 : ~(0|INOUT|IC2|DV1);
// Gate A5-U204A
pullup(A5U204Pad1);
assign (highz1,strong0) #0.2  A5U204Pad1 = rst ? 1 : ~(0|DV4B1B|IC4|A5U204Pad4);
// Gate A5-U119A
pullup(A5U110Pad2);
assign (highz1,strong0) #0.2  A5U110Pad2 = rst ? 0 : ~(0|T09_|A5U119Pad3);
// Gate A5-U120A A5-U154A A5-U221A A5-U221B
pullup(RC_);
assign (highz1,strong0) #0.2  RC_ = rst ? 1 : ~(0|A5U120Pad2|A5U120Pad3|A5U145Pad2|A5U153Pad1|A5U221Pad2|A5U210Pad2|A5U215Pad9|A5U203Pad1);
// Gate A5-U139A
pullup(A5U110Pad7);
assign (highz1,strong0) #0.2  A5U110Pad7 = rst ? 0 : ~(0|IC2_|T03_);
// Gate A5-U226B
pullup(A5U222Pad8);
assign (highz1,strong0) #0.2  A5U222Pad8 = rst ? 0 : ~(0|TS0_|BRDIF_);
// Gate A5-U109B A5-U240A A5-U240B A5-U210B
pullup(WB_);
assign (highz1,strong0) #0.2  WB_ = rst ? 1 : ~(0|A5U102Pad9|RAD|A5U240Pad2|A5U240Pad3|A5P2|A5U236Pad1|A5U238Pad8|RQ|A5U209Pad1|A5U206Pad1|A5U210Pad8);
// Gate A5-U217A
pullup(d6XP8);
assign (highz1,strong0) #0.2  d6XP8 = rst ? 0 : ~(0|T06_|DAS1_);
// Gate A5-U143A
pullup(TPZG_);
assign (highz1,strong0) #0.2  TPZG_ = rst ? 1 : ~(0|A5U143Pad2|A5U143Pad3);
// Gate A5-U249A
pullup(A5U248Pad2);
assign (highz1,strong0) #0.2  A5U248Pad2 = rst ? 0 : ~(0|T05_|SHANC_);
// Gate A5-U102B
pullup(A5U102Pad9);
assign (highz1,strong0) #0.2  A5U102Pad9 = rst ? 0 : ~(0|A5U102Pad7|T08_);
// Gate A5-U205A
pullup(A5U205Pad1);
assign (highz1,strong0) #0.2  A5U205Pad1 = rst ? 0 : ~(0|T10_|A5U204Pad1);
// Gate A5-U260B A5-U259B
pullup(SCAD);
assign (highz1,strong0) #0.2  SCAD = rst ? 0 : ~(0|S12|S11|XT0_|YT0_|YB0_);
// Gate A5-U237B A5-U236B
pullup(A5U236Pad2);
assign (highz1,strong0) #0.2  A5U236Pad2 = rst ? 1 : ~(0|MP0|IC5|DAS0|MASK0|TS0);
// Gate A5-U236A
pullup(A5U236Pad1);
assign (highz1,strong0) #0.2  A5U236Pad1 = rst ? 0 : ~(0|A5U236Pad2|T03_);
// Gate A5-U155A A5-U248A
pullup(CI_);
assign (highz1,strong0) #0.2  CI_ = rst ? 1 : ~(0|A5U133Pad1|d10XP6|A5U153Pad1|A5U248Pad2|A5U247Pad2|A5U247Pad3);
// Gate A5-U156A
pullup(d7XP9);
assign (highz1,strong0) #0.2  d7XP9 = rst ? 0 : ~(0|T07_|MSU0_);
// Gate A5-U103A
pullup(A5U102Pad7);
assign (highz1,strong0) #0.2  A5U102Pad7 = rst ? 1 : ~(0|DAS0|DXCH0|GOJ1);
// Gate A5-U255B
pullup(OCTAD6);
assign (highz1,strong0) #0.2  OCTAD6 = rst ? 0 : ~(0|XT6_|NDR100_);
// Gate A5-U134A
pullup(A5U134Pad1);
assign (highz1,strong0) #0.2  A5U134Pad1 = rst ? 0 : ~(0|T01_|A5U133Pad9);
// Gate A5-U137B
pullup(d2XP7);
assign (highz1,strong0) #0.2  d2XP7 = rst ? 0 : ~(0|T02_|MP3_);
// Gate A5-U119B
pullup(A5U119Pad3);
assign (highz1,strong0) #0.2  A5U119Pad3 = rst ? 1 : ~(0|DV1B1B|IC2);
// Gate A5-U231A
pullup(WS_);
assign (highz1,strong0) #0.2  WS_ = rst ? 1 : ~(0|RL10BB|RSCT|A5U231Pad4);
// Gate A5-U101A
pullup(GNHNC);
assign (highz1,strong0) #0.2  GNHNC = rst ? 1 : ~(0|A5U101Pad2|T01);
// Gate A5-U154B A5-U248B
pullup(A2X_);
assign (highz1,strong0) #0.2  A2X_ = rst ? 1 : ~(0|A5U149Pad6|A5U153Pad1|A5U149Pad7|A5U245Pad7|A5XP10);
// Gate A5-U136A
pullup(A5U136Pad1);
assign (highz1,strong0) #0.2  A5U136Pad1 = rst ? 0 : ~(0|A5U136Pad2|T02_);
// Gate A5-U138B
pullup(A5U136Pad2);
assign (highz1,strong0) #0.2  A5U136Pad2 = rst ? 1 : ~(0|IC2|IC3|RSM3);
// Gate A5-U242B
pullup(d2XP8);
assign (highz1,strong0) #0.2  d2XP8 = rst ? 0 : ~(0|FETCH0_|T02_);
// Gate A5-U132A A5-U150B A5-U110A A5-U250B
pullup(RB_);
assign (highz1,strong0) #0.2  RB_ = rst ? 1 : ~(0|A5U110Pad7|A5U131Pad1|A5U150Pad7|A5U150Pad3|A5U110Pad2|A5U110Pad3|A5P19|A5U247Pad2);
// Gate A5-U241B
pullup(A5U238Pad7);
assign (highz1,strong0) #0.2  A5U238Pad7 = rst ? 0 : ~(0|DV1_|T04_);
// Gate A5-U244A
pullup(A5P13);
assign (highz1,strong0) #0.2  A5P13 = rst ? 0 : ~(0|T05_|IC8_);
// Gate A5-U225B
pullup(A5P19);
assign (highz1,strong0) #0.2  A5P19 = rst ? 0 : ~(0|A5U225Pad7|T05_);
// Gate A5-U239A
pullup(A5U238Pad8);
assign (highz1,strong0) #0.2  A5U238Pad8 = rst ? 0 : ~(0|IC8_|T03_);
// Gate A5-U139B
pullup(A5U139Pad9);
assign (highz1,strong0) #0.2  A5U139Pad9 = rst ? 0 : ~(0|IC15_|T01_);
// Gate A5-U143B
pullup(A5U143Pad2);
assign (highz1,strong0) #0.2  A5U143Pad2 = rst ? 0 : ~(0|IC15_|T02_);
// Gate A5-U220A
pullup(A5U216Pad2);
assign (highz1,strong0) #0.2  A5U216Pad2 = rst ? 0 : ~(0|T06_|A5U218Pad9);
// Gate A5-U159B A5-U141B A5-U250A
pullup(RZ_);
assign (highz1,strong0) #0.2  RZ_ = rst ? 1 : ~(0|A5U157Pad1|d4XP5|A58XP3|A5U141Pad6|A5U134Pad1|d3XP6|A5U247Pad3|A5P7);
// Gate A5-U112A
pullup(A5U112Pad1);
assign (highz1,strong0) #0.2  A5U112Pad1 = rst ? 1 : ~(0|IC1|MP0);
// Gate A5-U157A
pullup(A5U157Pad1);
assign (highz1,strong0) #0.2  A5U157Pad1 = rst ? 0 : ~(0|CCS0_|T07_);
// Gate A5-U116B
pullup(A510XP7);
assign (highz1,strong0) #0.2  A510XP7 = rst ? 0 : ~(0|A5U116Pad7|T10_);
// Gate A5-U125A
pullup(A5U123Pad2);
assign (highz1,strong0) #0.2  A5U123Pad2 = rst ? 1 : ~(0|MSU0|IC14);
// Gate A5-U157B
pullup(PTWOX);
assign (highz1,strong0) #0.2  PTWOX = rst ? 0 : ~(0|BR1_|T07_|CCS0_);
// Gate A5-U125B
pullup(PINC);
assign (highz1,strong0) #0.2  PINC = rst ? 0 : ~(0|T12|PINC_);
// Gate A5-U144A
pullup(A5U141Pad6);
assign (highz1,strong0) #0.2  A5U141Pad6 = rst ? 0 : ~(0|IC2_|T05_);

endmodule
