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

assign ST2_ = rst ? 0 : ~(0|U114Pad1|U103Pad9);
assign WL_ = rst ? 0 : ~(0|U210Pad8|U205Pad1|U201Pad1|P13);
assign OCTAD3 = rst ? 0 : ~(0|XT3_|NDR100_);
assign OCTAD2 = rst ? 0 : ~(0|XT2_|NDR100_);
assign OCTAD5 = rst ? 0 : ~(0|XT5_|NDR100_);
assign OCTAD4 = rst ? 0 : ~(0|XT4_|NDR100_);
assign OCTAD6 = rst ? 0 : ~(0|XT6_|NDR100_);
assign U140Pad1 = rst ? 0 : ~(0|IC2_|T04_);
assign U215Pad3 = rst ? 0 : ~(0|U225Pad2);
assign RAD = rst ? 0 : ~(0|TSUDO_|T08_);
assign RQ = rst ? 0 : ~(0|QXCH0_|T03_);
assign U206Pad1 = rst ? 0 : ~(0|T10_|U206Pad3);
assign U215Pad9 = rst ? 0 : ~(0|T09_|DAS1_);
assign U141Pad6 = rst ? 0 : ~(0|IC2_|T05_);
assign U236Pad2 = rst ? 0 : ~(0|MP0|IC5|DAS0|MASK0|TS0);
assign U236Pad1 = rst ? 0 : ~(0|U236Pad2|T03_);
assign RA_ = rst ? 0 : ~(0|U118Pad9|U120Pad3|U140Pad1|U139Pad9|P2|U236Pad1);
assign NDR100_ = rst ? 0 : ~(0|U258Pad2|U257Pad2);
assign XP7 = rst ? 0 : ~(0|U116Pad7|T10_);
assign XP6 = rst ? 0 : ~(0|DV1_|T11_);
assign WZ_ = rst ? 0 : ~(0|U109Pad3|U110Pad7|U103Pad9|U216Pad2);
assign R6 = rst ? 0 : ~(0|FETCH0_|T01_);
assign PARTC = rst ? 0 : ~(0|SHIFT|MONpCH|INKL_);
assign U133Pad1 = rst ? 0 : ~(0|T01_|U133Pad3);
assign U133Pad3 = rst ? 0 : ~(0|IC2|IC10|IC3);
assign U221Pad2 = rst ? 0 : ~(0|U224Pad7|T05_);
assign U133Pad9 = rst ? 0 : ~(0|STD2|IC2);
assign U238Pad7 = rst ? 0 : ~(0|DV1_|T04_);
assign U150Pad3 = rst ? 0 : ~(0|RSM3_|T06_);
assign DV1B1B = rst ? 0 : ~(0|DV1_|BR1);
assign U109Pad3 = rst ? 0 : ~(0|CCS0_|T08_);
assign U117Pad8 = rst ? 0 : ~(0|BR12B_|DAS0_);
assign U104Pad2 = rst ? 0 : ~(0|IC2|IC4|DXCH0);
assign U104Pad1 = rst ? 0 : ~(0|U104Pad2|T08_);
assign U150Pad7 = rst ? 0 : ~(0|T07_|DAS0_);
assign U224Pad7 = rst ? 0 : ~(0|RAND0|WAND0|U225Pad2);
assign U115Pad4 = rst ? 0 : ~(0|U123Pad2|T11_);
assign P03 = rst ? 0 : ~(0|EDSET);
assign U258Pad2 = rst ? 0 : ~(0|YB0_|YT0_);
assign U102Pad7 = rst ? 0 : ~(0|DAS0|DXCH0|GOJ1);
assign U102Pad9 = rst ? 0 : ~(0|U102Pad7|T08_);
assign Z16_ = rst ? 0 : ~(0|U223Pad9);
assign U216Pad2 = rst ? 0 : ~(0|T06_|U218Pad9);
assign U118Pad9 = rst ? 0 : ~(0|U116Pad1|T10_);
assign U257Pad2 = rst ? 0 : ~(0|S11|S12);
assign SCAD_ = rst ? 0 : ~(0|SCAD);
assign U222Pad2 = rst ? 0 : ~(0|U222Pad9|T05_);
assign WYD_ = rst ? 0 : ~(0|P9|XP6);
assign U107Pad1 = rst ? 0 : ~(0|IC16);
assign U120Pad3 = rst ? 0 : ~(0|MASK0_|T09_);
assign U120Pad2 = rst ? 0 : ~(0|MASK0_|T11_);
assign U222Pad8 = rst ? 0 : ~(0|TS0_|BRDIF_);
assign U222Pad9 = rst ? 0 : ~(0|IC2|READ0|IC5|DV4|U222Pad8);
assign RL10BB = rst ? 0 : ~(0|T01_|U231Pad9);
assign RG_ = rst ? 0 : ~(0|U149Pad6|U149Pad7|U143Pad3|d5XP15|U245Pad3|P13|U240Pad3|U245Pad7|P9|U209Pad1|U211Pad7|U203Pad1);
assign RSCT = rst ? 0 : ~(0|T01_|INKL_|MONpCH);
assign U112Pad1 = rst ? 0 : ~(0|IC1|MP0);
assign DV4B1B = rst ? 0 : ~(0|DV4_|BR1);
assign PINC_ = rst ? 0 : ~(0|U124Pad9|PINC);
assign U131Pad2 = rst ? 0 : ~(0|TC0|TCF0|IC4);
assign U131Pad1 = rst ? 0 : ~(0|U131Pad2|T01_);
assign NISQ_ = rst ? 0 : ~(0|d2XP7|U136Pad1|P15);
assign TSGN_ = rst ? 0 : ~(0|U139Pad9|d7XP9|U143Pad3|P9|RSTSTG);
assign P12 = rst ? 0 : ~(0|DAS0_|T08_);
assign P13 = rst ? 0 : ~(0|T05_|IC8_);
assign P15 = rst ? 0 : ~(0|U107Pad1|T08_);
assign U119Pad3 = rst ? 0 : ~(0|DV1B1B|IC2);
assign P19 = rst ? 0 : ~(0|U225Pad7|T05_);
assign U203Pad1 = rst ? 0 : ~(0|RXOR0_|T11_);
assign U113Pad3 = rst ? 0 : ~(0|IC1|RUPT0|IC10);
assign U243Pad2 = rst ? 0 : ~(0|DAS1|PRINC|PARTC);
assign P2 = rst ? 0 : ~(0|INOUT_|RXOR0|T06_);
assign P3 = rst ? 0 : ~(0|U112Pad1|T08_);
assign U153Pad1 = rst ? 0 : ~(0|MSU0_|T06_);
assign U231Pad4 = rst ? 0 : ~(0|CHINC_|T01_);
assign P7 = rst ? 0 : ~(0|T06_|DV4_);
assign DVST = rst ? 0 : ~(0|STD2|T02_|DIV_);
assign U231Pad9 = rst ? 0 : ~(0|DXCH0|IC9|PRINC|INOUT|DAS1|DAS0|IC12);
assign P9 = rst ? 0 : ~(0|SHIFT_|T05_);
assign U149Pad6 = rst ? 0 : ~(0|IC2_|T07_);
assign U149Pad7 = rst ? 0 : ~(0|T06_|DAS0_);
assign U116Pad1 = rst ? 0 : ~(0|U116Pad2|DAS0);
assign U116Pad7 = rst ? 0 : ~(0|U116Pad2|U117Pad8);
assign U157Pad1 = rst ? 0 : ~(0|CCS0_|T07_);
assign U241Pad2 = rst ? 0 : ~(0|INOUT|IC2|DV1);
assign TSUDO_ = rst ? 0 : ~(0|RSM3|IC3|MP3|IC16);
assign WG_ = rst ? 0 : ~(0|U139Pad9|U150Pad3|d9XP5);
assign MONEX_ = rst ? 0 : ~(0|U132Pad6|d10XP6|XP7);
assign U206Pad3 = rst ? 0 : ~(0|IC2|IC14|DV1);
assign U116Pad2 = rst ? 0 : ~(0|MSU0_|BR1_);
assign TRSM = rst ? 0 : ~(0|NDX0_|T05_);
assign U138Pad1 = rst ? 0 : ~(0|T10_|MP3_);
assign U114Pad1 = rst ? 0 : ~(0|CCS0_|T10_);
assign d3XP6 = rst ? 0 : ~(0|T03_|TC0_);
assign U209Pad1 = rst ? 0 : ~(0|T07_|U207Pad9);
assign U136Pad1 = rst ? 0 : ~(0|U136Pad2|T02_);
assign d10XP1 = rst ? 0 : ~(0|T10_|U113Pad3);
assign d10XP6 = rst ? 0 : ~(0|T10_|BR2|CCS0_);
assign d10XP8 = rst ? 0 : ~(0|BR1B2_|T10_|DAS0_);
assign TMZ_ = rst ? 0 : ~(0|U139Pad9|U143Pad3|U215Pad9);
assign Z15_ = rst ? 0 : ~(0|U210Pad2);
assign WY_ = rst ? 0 : ~(0|U114Pad1|U120Pad3|U118Pad9|U149Pad7|U153Pad1|U149Pad6|XP10|U243Pad1|d2XP8);
assign U144Pad9 = rst ? 0 : ~(0|T04_|DAS0_);
assign WY12_ = rst ? 0 : ~(0|U133Pad1|d4XP5|U157Pad1|U247Pad2|U247Pad3);
assign U123Pad2 = rst ? 0 : ~(0|MSU0|IC14);
assign J4Pad404 = rst ? 0 : ~(0);
assign U207Pad9 = rst ? 0 : ~(0|DV1|IC14|IC13);
assign U204Pad4 = rst ? 0 : ~(0|BR2|ADS0|DAS1_);
assign d5XP21 = rst ? 0 : ~(0|CHINC_|T05_);
assign U204Pad1 = rst ? 0 : ~(0|DV4B1B|IC4|U204Pad4);
assign U218Pad9 = rst ? 0 : ~(0|IC2|TS0|IC3|IC16|MP3);
assign RSTRT = rst ? 0 : ~(0|GOJ1_|T08_);
assign XP10 = rst ? 0 : ~(0|T10_|IC11_);
assign U248Pad2 = rst ? 0 : ~(0|T05_|SHANC_);
assign U245Pad3 = rst ? 0 : ~(0|IC5_|T05_);
assign d6XP8 = rst ? 0 : ~(0|T06_|DAS1_);
assign TOV_ = rst ? 0 : ~(0|P7|d6XP8);
assign U139Pad9 = rst ? 0 : ~(0|IC15_|T01_);
assign GNHNC = rst ? 0 : ~(0|U101Pad2|T01);
assign SCAD = rst ? 0 : ~(0|S12|S11|XT0_|YT0_|YB0_);
assign WA_ = rst ? 0 : ~(0|U145Pad2|U144Pad9|U110Pad2|d5XP11|U115Pad4|U222Pad2|U210Pad2);
assign U101Pad2 = rst ? 0 : ~(0|GOJAM|GNHNC);
assign d9XP5 = rst ? 0 : ~(0|T09_|DAS0_);
assign U211Pad7 = rst ? 0 : ~(0|T07_|STFET1_);
assign d5XP12 = rst ? 0 : ~(0|T05_|DAS0_);
assign U201Pad1 = rst ? 0 : ~(0|T12_|T12USE_|DV1_);
assign d5XP15 = rst ? 0 : ~(0|T05_|QXCH0_);
assign PINC = rst ? 0 : ~(0|T12|PINC_);
assign RL_ = rst ? 0 : ~(0|U144Pad9|U138Pad1|P12|XP6|U238Pad7|U238Pad8);
assign RU_ = rst ? 0 : ~(0|d9XP5|U109Pad3|U104Pad1|U201Pad1|U210Pad8|U206Pad1|U216Pad2|d6XP8|d5XP11);
assign U243Pad1 = rst ? 0 : ~(0|U243Pad2|T05_);
assign U134Pad1 = rst ? 0 : ~(0|T01_|U133Pad9);
assign U251Pad2 = rst ? 0 : ~(0|MP3);
assign RC_ = rst ? 0 : ~(0|U120Pad2|U120Pad3|U145Pad2|U153Pad1|U221Pad2|U210Pad2|U215Pad9|U203Pad1);
assign U238Pad8 = rst ? 0 : ~(0|IC8_|T03_);
assign WB_ = rst ? 0 : ~(0|U102Pad9|RAD|U240Pad2|U240Pad3|P2|U236Pad1|U238Pad8|RQ|U209Pad1|U206Pad1|U210Pad8);
assign RSTSTG = rst ? 0 : ~(0|T08_|DV4_);
assign TPZG_ = rst ? 0 : ~(0|U143Pad2|U143Pad3);
assign d7XP4 = rst ? 0 : ~(0|CCS0_|BR2_|T07_);
assign U240Pad2 = rst ? 0 : ~(0|U241Pad2|T04_);
assign U240Pad3 = rst ? 0 : ~(0|IC12_|T05_);
assign U110Pad7 = rst ? 0 : ~(0|IC2_|T03_);
assign CI_ = rst ? 0 : ~(0|U133Pad1|d10XP6|U153Pad1|U248Pad2|U247Pad2|U247Pad3);
assign d7XP9 = rst ? 0 : ~(0|T07_|MSU0_);
assign U110Pad2 = rst ? 0 : ~(0|T09_|U119Pad3);
assign U110Pad3 = rst ? 0 : ~(0|FETCH0|T08_|INKL_);
assign U147Pad2 = rst ? 0 : ~(0|PRINC|PARTC|CCS0);
assign U245Pad7 = rst ? 0 : ~(0|T05_|DAS1_);
assign U136Pad2 = rst ? 0 : ~(0|IC2|IC3|RSM3);
assign d2XP7 = rst ? 0 : ~(0|T02_|MP3_);
assign WS_ = rst ? 0 : ~(0|RL10BB|RSCT|U231Pad4);
assign U143Pad2 = rst ? 0 : ~(0|IC15_|T02_);
assign U143Pad3 = rst ? 0 : ~(0|U147Pad2|T05_);
assign U103Pad9 = rst ? 0 : ~(0|TCSAJ3_|T08_);
assign A2X_ = rst ? 0 : ~(0|U149Pad6|U153Pad1|U149Pad7|U245Pad7|XP10);
assign d11XP2 = rst ? 0 : ~(0|T11_|MSU0_);
assign d2XP8 = rst ? 0 : ~(0|FETCH0_|T02_);
assign RB_ = rst ? 0 : ~(0|U110Pad7|U131Pad1|U150Pad7|U150Pad3|U110Pad2|U110Pad3|P19|U247Pad2);
assign U132Pad6 = rst ? 0 : ~(0|IC10_|T01_);
assign U210Pad8 = rst ? 0 : ~(0|T09_|DV4_);
assign U223Pad9 = rst ? 0 : ~(0|U215Pad3|T05_);
assign U2BBK = rst ? 0 : ~(0|T08_|MONWBK|STFET1_);
assign U210Pad2 = rst ? 0 : ~(0|T09_|U215Pad3);
assign RZ_ = rst ? 0 : ~(0|U157Pad1|d4XP5|P3|U141Pad6|U134Pad1|d3XP6|U247Pad3|P7);
assign U247Pad3 = rst ? 0 : ~(0|U251Pad2|T05_);
assign U247Pad2 = rst ? 0 : ~(0|IC16_|T05_);
assign PTWOX = rst ? 0 : ~(0|BR1_|T07_|CCS0_);
assign U145Pad2 = rst ? 0 : ~(0|MASK0_|T04_);
assign U205Pad1 = rst ? 0 : ~(0|T10_|U204Pad1);
assign U225Pad7 = rst ? 0 : ~(0|DV1B1B|ROR0|WOR0);
assign U225Pad2 = rst ? 0 : ~(0|DV1_|BR1_);
assign U124Pad7 = rst ? 0 : ~(0|C37P|C40P|C41P|C44P|C43P|C42P|C26A|C25A|C24A|C27A|C30A);
assign U124Pad9 = rst ? 0 : ~(0|U124Pad7|INCSET_);

endmodule
