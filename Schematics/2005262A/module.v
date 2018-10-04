// Verilog module auto-generated for AGC module A4 by dumbVerilog.py

module A4 ( 
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

input wire rst, CGA4, DVST, EXST0_, EXST1_, GEQZRO_, GOJAM, IC12, IC13, INKL,
  L15_, MP0_, MP1, MP3_, MTCSAI, NDR100_, OVF_, PHS2_, PHS3_, PHS4, PHS4_,
  QC0_, QC1_, QC2_, QC3_, RSM3, RSM3_, RSTSTG, SQ0_, SQ1_, SQ2_, SQEXT, SQEXT_,
  SQR10, SQR10_, SQR12_, ST1, ST2, STORE1_, STRTFC, SUMA16_, SUMB16_, T01,
  T01_, T02_, T03_, T04_, T05_, T06_, T07_, T08_, T09_, T10_, T11_, T12_,
  TOV_, TPZG_, TRSM, TS0_, TSGU_, UNF_, WL01_, WL02_, WL03_, WL04_, WL05_,
  WL06_, WL07_, WL08_, WL09_, WL10_, WL11_, WL12_, WL13_, WL14_, WL15_, WL16_,
  XB7_, XT1_, d7XP14;

inout wire BR1, BR1_, BR2, BR2_, CI_, DV0_, DV1_, DV4, DVST_, L16_, MBR1,
  MBR2, MP3A, MRSC, MST1, MST2, MST3, R1C_, RA_, RB1_, RB_, RC_, ST0_, TL15,
  TMZ_, TRSM_, TSGN2, TSGN_, WG_, WL_, WY_, d2PP1;

output wire B15X, BR12B, BR12B_, BR1B2, BR1B2B, BR1B2B_, BR1B2_, BRDIF_,
  DIVSTG, DIV_, DV0, DV1, DV1376, DV1376_, DV376, DV3764, DV376_, DV4_, INOUT,
  INOUT_, KRPT, MP0T10, PRINC, R15, RAND0, RB2, READ0, READ0_, ROR0, RRPA,
  RSC_, RUPT0, RUPT0_, RUPT1, RUPT1_, RXOR0, RXOR0_, SGUM, ST1376_, ST1D,
  ST1_, ST376, ST376_, ST3_, ST4_, STD2, STG1, STG2, STG3, T12USE_, WAND0,
  WCH_, WOR0, WOR0_, WRITE0, WRITE0_, d1XP10, d2XP3, d2XP5, d3XP2, d3XP7,
  d4XP11, d4XP5, d5XP11, d5XP28, d5XP4, d6XP5, d7XP19, d8PP4, d8XP5, d8XP6,
  d9XP1;

// Gate A4-U134B A4-U135B
pullup(A4U134Pad9);
assign (highz1,strong0) #0.2  A4U134Pad9 = rst ? 0 : ~(0|A4U134Pad6|A4U134Pad7|ST1|GOJAM|MTCSAI);
// Gate A4-U239B
pullup(WL_);
assign (highz1,strong0) #0.2  WL_ = rst ? 1 : ~(0|A4U239Pad2|A4U239Pad7|d6XP5);
// Gate A4-U136A
pullup(A4U136Pad1);
assign (highz1,strong0) #0.2  A4U136Pad1 = rst ? 0 : ~(0|A4U134Pad9|A4U133Pad9);
// Gate A4-U220B
pullup(A4U220Pad9);
assign (highz1,strong0) #0.2  A4U220Pad9 = rst ? 0 : ~(0|T05_|RXOR0_);
// Gate A4-U240A
pullup(A4U239Pad2);
assign (highz1,strong0) #0.2  A4U239Pad2 = rst ? 0 : ~(0|BR1|MP0_|T04_);
// Gate A4-U136B
pullup(A4U134Pad7);
assign (highz1,strong0) #0.2  A4U134Pad7 = rst ? 1 : ~(0|A4U134Pad9|T01);
// Gate A4-U144A
pullup(A4U134Pad6);
assign (highz1,strong0) #0.2  A4U134Pad6 = rst ? 0 : ~(0|STG3|DVST_);
// Gate A4-U252B
pullup(A4U239Pad7);
assign (highz1,strong0) #0.2  A4U239Pad7 = rst ? 0 : ~(0|MP0_|T04_|BR1_);
// Gate A4-U250B
pullup(RB2);
assign (highz1,strong0) #0.2  RB2 = rst ? 0 : ~(0|T01_|RUPT1_);
// Gate A4-U204B
pullup(READ0);
assign (highz1,strong0) #0.2  READ0 = rst ? 0 : ~(0|SQR10|A4U201Pad1|QC0_);
// Gate A4-U142B A4-U143B
pullup(A4U139Pad2);
assign (highz1,strong0) #0.2  A4U139Pad2 = rst ? 0 : ~(0|A4U141Pad9|STG2);
// Gate A4-U256A
pullup(RB1_);
assign (highz1,strong0) #0.2  RB1_ = rst ? 1 : ~(0|A4U234Pad9|A4U235Pad3);
// Gate A4-U210B
pullup(A4U210Pad9);
assign (highz1,strong0) #0.2  A4U210Pad9 = rst ? 1 : ~(0|ROR0|WOR0);
// Gate A4-U140B A4-U139B
pullup(A4U139Pad9);
assign (highz1,strong0) #0.2  A4U139Pad9 = rst ? 1 : ~(0|A4U140Pad6|MTCSAI|A4U140Pad1|ST2|A4U101Pad1);
// Gate A4-U248A
pullup(d1XP10);
assign (highz1,strong0) #0.2  d1XP10 = rst ? 0 : ~(0|T01_|DV0_);
// Gate A4-U153B
pullup(DV1376);
assign (highz1,strong0) #0.2  DV1376 = rst ? 0 : ~(0|ST1376_|DIV_);
// Gate A4-U123B
pullup(A4U122Pad2);
assign (highz1,strong0) #0.2  A4U122Pad2 = rst ? 1 : ~(0|TL15);
// Gate A4-U156B
pullup(A4U156Pad9);
assign (highz1,strong0) #0.2  A4U156Pad9 = rst ? 0 : ~(0|STG2|STG1|A4U147Pad1);
// Gate A4-U124A
pullup(A4U115Pad7);
assign (highz1,strong0) #0.2  A4U115Pad7 = rst ? 1 : ~(0|SUMB16_|SUMA16_);
// Gate A4-U249B
pullup(d2PP1);
assign (highz1,strong0) #0.2  d2PP1 = rst ? 1 : ~(0|INOUT|MP1|MP3A);
// Gate A4-U117B
pullup(A4U117Pad9);
assign (highz1,strong0) #0.2  A4U117Pad9 = rst ? 0 : ~(0|WL16_|PHS4_|TSGN_);
// Gate A4-U157B
pullup(A4U156Pad2);
assign (highz1,strong0) #0.2  A4U156Pad2 = rst ? 0 : ~(0|STG1|STG3);
// Gate A4-U211A
pullup(ROR0);
assign (highz1,strong0) #0.2  ROR0 = rst ? 0 : ~(0|A4U201Pad1|QC2_|SQR10);
// Gate A4-U109A A4-U118A A4-U119A
pullup(BR1_);
assign (highz1,strong0) #0.2  BR1_ = rst ? 1 : ~(0|A4U109Pad2);
// Gate A4-U116B A4-U115B
pullup(A4U115Pad9);
assign (highz1,strong0) #0.2  A4U115Pad9 = rst ? 0 : ~(0|PHS4|PHS3_|A4U115Pad7|TSGU_);
// Gate A4-U154A A4-U148A
pullup(STD2);
assign (highz1,strong0) #0.2  STD2 = rst ? 0 : ~(0|STG3|A4U139Pad2|STG1|INKL);
// Gate A4-U101B
pullup(MBR2);
assign (highz1,strong0) #0.2  MBR2 = rst ? 0 : ~(0|A4U101Pad7);
// Gate A4-U113B
pullup(MBR1);
assign (highz1,strong0) #0.2  MBR1 = rst ? 0 : ~(0|A4U113Pad7);
// Gate A4-U240B
pullup(BRDIF_);
assign (highz1,strong0) #0.2  BRDIF_ = rst ? 1 : ~(0|BR12B|BR1B2);
// Gate A4-U155B
pullup(ST3_);
assign (highz1,strong0) #0.2  ST3_ = rst ? 1 : ~(0|A4U155Pad1);
// Gate A4-U228A
pullup(A4U228Pad1);
assign (highz1,strong0) #0.2  A4U228Pad1 = rst ? 0 : ~(0|T09_|RXOR0_);
// Gate A4-U246B
pullup(KRPT);
assign (highz1,strong0) #0.2  KRPT = rst ? 0 : ~(0|T09_|RUPT1_);
// Gate A4-U238B
pullup(BR1B2_);
assign (highz1,strong0) #0.2  BR1B2_ = rst ? 1 : ~(0|BR1B2);
// Gate A4-U121B A4-U120B
pullup(A4U113Pad7);
assign (highz1,strong0) #0.2  A4U113Pad7 = rst ? 1 : ~(0|SGUM|A4U121Pad8|A4U109Pad2|A4U117Pad9|A4U120Pad8);
// Gate A4-U242B
pullup(BR1B2B);
assign (highz1,strong0) #0.2  BR1B2B = rst ? 1 : ~(0|BR2|BR1);
// Gate A4-U132B
pullup(DIVSTG);
assign (highz1,strong0) #0.2  DIVSTG = rst ? 0 : ~(0|T12USE_|T03_);
// Gate A4-U225A
pullup(A4U225Pad1);
assign (highz1,strong0) #0.2  A4U225Pad1 = rst ? 0 : ~(0|SQEXT|QC3_);
// Gate A4-U235A
pullup(R1C_);
assign (highz1,strong0) #0.2  R1C_ = rst ? 1 : ~(0|A4U233Pad9|A4U235Pad3);
// Gate A4-U225B
pullup(A4U225Pad9);
assign (highz1,strong0) #0.2  A4U225Pad9 = rst ? 1 : ~(0|A4U223Pad1);
// Gate A4-U231A
pullup(A4U231Pad1);
assign (highz1,strong0) #0.2  A4U231Pad1 = rst ? 0 : ~(0|T03_|MP0_);
// Gate A4-U215A
pullup(RXOR0);
assign (highz1,strong0) #0.2  RXOR0 = rst ? 0 : ~(0|A4U201Pad1|QC3_|SQR10);
// Gate A4-U234B
pullup(A4U234Pad9);
assign (highz1,strong0) #0.2  A4U234Pad9 = rst ? 0 : ~(0|TS0_|BR1B2_|T05_);
// Gate A4-U125B A4-U126B A4-U127B
pullup(DV1_);
assign (highz1,strong0) #0.2  DV1_ = rst ? 1 : ~(0|DV1);
// Gate A4-U243B
pullup(BR1B2B_);
assign (highz1,strong0) #0.2  BR1B2B_ = rst ? 0 : ~(0|BR1B2B);
// Gate A4-U234A
pullup(A4U234Pad1);
assign (highz1,strong0) #0.2  A4U234Pad1 = rst ? 0 : ~(0|INOUT_|T03_);
// Gate A4-U218A
pullup(RUPT0_);
assign (highz1,strong0) #0.2  RUPT0_ = rst ? 1 : ~(0|RUPT0);
// Gate A4-U247B
pullup(A4U247Pad9);
assign (highz1,strong0) #0.2  A4U247Pad9 = rst ? 0 : ~(0|MP3_|T04_);
// Gate A4-U242A
pullup(BR12B);
assign (highz1,strong0) #0.2  BR12B = rst ? 0 : ~(0|BR1_|BR2);
// Gate A4-U244B
pullup(A4U244Pad9);
assign (highz1,strong0) #0.2  A4U244Pad9 = rst ? 0 : ~(0|DV1_|T04_|BR2_);
// Gate A4-U212B
pullup(RAND0);
assign (highz1,strong0) #0.2  RAND0 = rst ? 0 : ~(0|SQR10|QC1_|A4U201Pad1);
// Gate A4-U158B
pullup(ST376_);
assign (highz1,strong0) #0.2  ST376_ = rst ? 0 : ~(0|ST376);
// Gate A4-U245B
pullup(A4U245Pad9);
assign (highz1,strong0) #0.2  A4U245Pad9 = rst ? 0 : ~(0|BRDIF_|MP0_|T09_);
// Gate A4-U212A
pullup(WAND0);
assign (highz1,strong0) #0.2  WAND0 = rst ? 0 : ~(0|SQR10_|A4U201Pad1|QC1_);
// Gate A4-U116A A4-U124B
pullup(SGUM);
assign (highz1,strong0) #0.2  SGUM = rst ? 0 : ~(0|PHS3_|PHS4|SUMA16_|SUMB16_|TSGU_);
// Gate A4-U137A
pullup(A4U135Pad2);
assign (highz1,strong0) #0.2  A4U135Pad2 = rst ? 1 : ~(0|STG1|A4U136Pad1);
// Gate A4-U222B A4-U220A
pullup(RUPT1);
assign (highz1,strong0) #0.2  RUPT1 = rst ? 0 : ~(0|SQR10_|EXST1_|QC3_|SQ0_);
// Gate A4-U111B
pullup(A4U110Pad3);
assign (highz1,strong0) #0.2  A4U110Pad3 = rst ? 1 : ~(0|TSGN2);
// Gate A4-U219B
pullup(A4U217Pad6);
assign (highz1,strong0) #0.2  A4U217Pad6 = rst ? 0 : ~(0|T05_|WOR0_);
// Gate A4-U228B A4-U226A
pullup(PRINC);
assign (highz1,strong0) #0.2  PRINC = rst ? 0 : ~(0|A4U225Pad9|A4U225Pad1);
// Gate A4-U107A A4-U108A
pullup(A4U101Pad7);
assign (highz1,strong0) #0.2  A4U101Pad7 = rst ? 1 : ~(0|A4U103Pad1|A4U103Pad9|A4U108Pad2|A4U108Pad3|A4U105Pad8);
// Gate A4-U138B A4-U101A
pullup(A4U101Pad1);
assign (highz1,strong0) #0.2  A4U101Pad1 = rst ? 0 : ~(0|XB7_|TRSM_|XT1_|NDR100_);
// Gate A4-U203A
pullup(INOUT);
assign (highz1,strong0) #0.2  INOUT = rst ? 0 : ~(0|RUPT0|SQ0_|EXST0_);
// Gate A4-U252A
pullup(RSC_);
assign (highz1,strong0) #0.2  RSC_ = rst ? 1 : ~(0|A4U237Pad1|A4U247Pad9|A4U250Pad1);
// Gate A4-U226B
pullup(A4U222Pad2);
assign (highz1,strong0) #0.2  A4U222Pad2 = rst ? 0 : ~(0|A4U224Pad1|T09_);
// Gate A4-U227B
pullup(A4U227Pad9);
assign (highz1,strong0) #0.2  A4U227Pad9 = rst ? 0 : ~(0|T09_|STORE1_);
// Gate A4-U211B
pullup(WOR0_);
assign (highz1,strong0) #0.2  WOR0_ = rst ? 1 : ~(0|WOR0);
// Gate A4-U257A A4-U257B
pullup(TSGN_);
assign (highz1,strong0) #0.2  TSGN_ = rst ? 1 : ~(0|A4U231Pad1|A4U244Pad9|A4U237Pad1|MP0T10|d1XP10);
// Gate A4-U214A
pullup(RXOR0_);
assign (highz1,strong0) #0.2  RXOR0_ = rst ? 1 : ~(0|RXOR0);
// Gate A4-U135A
pullup(MST1);
assign (highz1,strong0) #0.2  MST1 = rst ? 0 : ~(0|A4U135Pad2);
// Gate A4-U139A
pullup(MST2);
assign (highz1,strong0) #0.2  MST2 = rst ? 1 : ~(0|A4U139Pad2);
// Gate A4-U148B
pullup(MST3);
assign (highz1,strong0) #0.2  MST3 = rst ? 1 : ~(0|A4U147Pad1);
// Gate A4-U213B
pullup(A4U213Pad9);
assign (highz1,strong0) #0.2  A4U213Pad9 = rst ? 1 : ~(0|RAND0|WAND0);
// Gate A4-U130A
pullup(DV376);
assign (highz1,strong0) #0.2  DV376 = rst ? 0 : ~(0|DIV_|ST376_);
// Gate A4-U206A
pullup(WRITE0_);
assign (highz1,strong0) #0.2  WRITE0_ = rst ? 1 : ~(0|WRITE0);
// Gate A4-U213A
pullup(A4U213Pad1);
assign (highz1,strong0) #0.2  A4U213Pad1 = rst ? 0 : ~(0|A4U210Pad9|T03_);
// Gate A4-U206B
pullup(WRITE0);
assign (highz1,strong0) #0.2  WRITE0 = rst ? 0 : ~(0|QC0_|SQR10_|A4U201Pad1);
// Gate A4-U150B A4-U151B
pullup(ST0_);
assign (highz1,strong0) #0.2  ST0_ = rst ? 1 : ~(0|A4U149Pad9);
// Gate A4-U245A
pullup(A4U245Pad1);
assign (highz1,strong0) #0.2  A4U245Pad1 = rst ? 0 : ~(0|T09_|MP3_);
// Gate A4-U236A
pullup(TSGN2);
assign (highz1,strong0) #0.2  TSGN2 = rst ? 0 : ~(0|T07_|MP0_);
// Gate A4-U205A
pullup(INOUT_);
assign (highz1,strong0) #0.2  INOUT_ = rst ? 1 : ~(0|INOUT);
// Gate A4-U221B
pullup(A4U221Pad9);
assign (highz1,strong0) #0.2  A4U221Pad9 = rst ? 0 : ~(0|T05_|READ0_);
// Gate A4-U251A
pullup(A4U251Pad1);
assign (highz1,strong0) #0.2  A4U251Pad1 = rst ? 1 : ~(0|RUPT1|RSM3|RUPT0);
// Gate A4-U143A
pullup(A4U140Pad6);
assign (highz1,strong0) #0.2  A4U140Pad6 = rst ? 0 : ~(0|A4U135Pad2|DVST_);
// Gate A4-U229A A4-U230A A4-U253A
pullup(WG_);
assign (highz1,strong0) #0.2  WG_ = rst ? 1 : ~(0|d9XP1|A4U228Pad1|A4U220Pad9|A4U223Pad9|A4U222Pad2|A4U227Pad9|A4U250Pad1|A4U247Pad9);
// Gate A4-U207B
pullup(d8PP4);
assign (highz1,strong0) #0.2  d8PP4 = rst ? 1 : ~(0|DV4|INOUT|PRINC);
// Gate A4-U149A
pullup(ST1D);
assign (highz1,strong0) #0.2  ST1D = rst ? 0 : ~(0|A4U135Pad2|STG2|STG3);
// Gate A4-U140A
pullup(A4U140Pad1);
assign (highz1,strong0) #0.2  A4U140Pad1 = rst ? 0 : ~(0|T01|A4U139Pad9|GOJAM);
// Gate A4-U146A
pullup(A4U146Pad1);
assign (highz1,strong0) #0.2  A4U146Pad1 = rst ? 0 : ~(0|A4U133Pad9|A4U144Pad8);
// Gate A4-U145A
pullup(A4U144Pad8);
assign (highz1,strong0) #0.2  A4U144Pad8 = rst ? 1 : ~(0|A4U145Pad2|A4U104Pad9);
// Gate A4-U125A
pullup(DV1);
assign (highz1,strong0) #0.2  DV1 = rst ? 0 : ~(0|DIV_|ST1_);
// Gate A4-U232A
pullup(d3XP2);
assign (highz1,strong0) #0.2  d3XP2 = rst ? 0 : ~(0|T03_|TS0_);
// Gate A4-U146B
pullup(A4U146Pad9);
assign (highz1,strong0) #0.2  A4U146Pad9 = rst ? 0 : ~(0|A4U104Pad9|A4U133Pad9);
// Gate A4-U238A
pullup(BR12B_);
assign (highz1,strong0) #0.2  BR12B_ = rst ? 1 : ~(0|BR12B);
// Gate A4-U121A A4-U120A
pullup(A4U109Pad2);
assign (highz1,strong0) #0.2  A4U109Pad2 = rst ? 0 : ~(0|A4U113Pad7|A4U121Pad3|A4U117Pad1|A4U108Pad7|A4U115Pad9);
// Gate A4-U106B A4-U105B
pullup(BR2_);
assign (highz1,strong0) #0.2  BR2_ = rst ? 1 : ~(0|A4U105Pad8);
// Gate A4-U231B
pullup(d5XP4);
assign (highz1,strong0) #0.2  d5XP4 = rst ? 0 : ~(0|RSM3_|T05_);
// Gate A4-U104A A4-U160A A4-U105A
pullup(A4);
assign (highz1,strong0) #0.2  A4 = rst ? 1 : ~(0);
// Gate A4-U154B
pullup(DV1376_);
assign (highz1,strong0) #0.2  DV1376_ = rst ? 1 : ~(0|DV1376);
// Gate A4-U221A
pullup(RUPT1_);
assign (highz1,strong0) #0.2  RUPT1_ = rst ? 1 : ~(0|RUPT1);
// Gate A4-U254B
pullup(TMZ_);
assign (highz1,strong0) #0.2  TMZ_ = rst ? 1 : ~(0|d2XP5|d1XP10);
// Gate A4-U223B
pullup(A4U223Pad9);
assign (highz1,strong0) #0.2  A4U223Pad9 = rst ? 0 : ~(0|WRITE0_|T02_);
// Gate A4-U152B
pullup(MP3A);
assign (highz1,strong0) #0.2  MP3A = rst ? 0 : ~(0|MP3_);
// Gate A4-U235B A4-U258A
pullup(WY_);
assign (highz1,strong0) #0.2  WY_ = rst ? 1 : ~(0|B15X|d7XP19|A4U234Pad1|d8XP5|A4U239Pad4|A4U246Pad1);
// Gate A4-U223A
pullup(A4U223Pad1);
assign (highz1,strong0) #0.2  A4U223Pad1 = rst ? 0 : ~(0|SQR12_|SQ2_|ST0_);
// Gate A4-U107B A4-U108B
pullup(A4U105Pad8);
assign (highz1,strong0) #0.2  A4U105Pad8 = rst ? 0 : ~(0|A4U101Pad7|A4U107Pad7|A4U108Pad7|A4U108Pad8);
// Gate A4-U106A
pullup(BR2);
assign (highz1,strong0) #0.2  BR2 = rst ? 0 : ~(0|A4U101Pad7);
// Gate A4-U118B A4-U119B A4-U160B
pullup(BR1);
assign (highz1,strong0) #0.2  BR1 = rst ? 0 : ~(0|A4U113Pad7);
// Gate A4-U232B
pullup(d4XP5);
assign (highz1,strong0) #0.2  d4XP5 = rst ? 0 : ~(0|T04_|TS0_);
// Gate A4-U123A
pullup(A4U121Pad8);
assign (highz1,strong0) #0.2  A4U121Pad8 = rst ? 0 : ~(0|UNF_|TOV_);
// Gate A4-U122B
pullup(A4U121Pad3);
assign (highz1,strong0) #0.2  A4U121Pad3 = rst ? 0 : ~(0|PHS3_|A4U122Pad2);
// Gate A4-U215B
pullup(d5XP28);
assign (highz1,strong0) #0.2  d5XP28 = rst ? 0 : ~(0|T05_|DV4_);
// Gate A4-U214B
pullup(A4U214Pad9);
assign (highz1,strong0) #0.2  A4U214Pad9 = rst ? 0 : ~(0|A4U213Pad9|T03_);
// Gate A4-U129B
pullup(A4U128Pad2);
assign (highz1,strong0) #0.2  A4U128Pad2 = rst ? 0 : ~(0|QC0_|SQ1_|SQEXT_);
// Gate A4-U217A
pullup(RUPT0);
assign (highz1,strong0) #0.2  RUPT0 = rst ? 0 : ~(0|A4U201Pad1|SQR10_|QC3_);
// Gate A4-U103A
pullup(A4U103Pad1);
assign (highz1,strong0) #0.2  A4U103Pad1 = rst ? 0 : ~(0|PHS4_|TPZG_|GEQZRO_);
// Gate A4-U249A
pullup(A4U249Pad1);
assign (highz1,strong0) #0.2  A4U249Pad1 = rst ? 0 : ~(0|d2PP1);
// Gate A4-U103B
pullup(A4U103Pad9);
assign (highz1,strong0) #0.2  A4U103Pad9 = rst ? 0 : ~(0|TOV_|OVF_);
// Gate A4-U218B
pullup(A4U217Pad7);
assign (highz1,strong0) #0.2  A4U217Pad7 = rst ? 0 : ~(0|T05_|WRITE0_);
// Gate A4-U210A
pullup(WOR0);
assign (highz1,strong0) #0.2  WOR0 = rst ? 0 : ~(0|QC2_|A4U201Pad1|SQR10_);
// Gate A4-U233A
pullup(d4XP11);
assign (highz1,strong0) #0.2  d4XP11 = rst ? 0 : ~(0|INOUT_|T04_);
// Gate A4-U241B
pullup(d8XP6);
assign (highz1,strong0) #0.2  d8XP6 = rst ? 0 : ~(0|T08_|DV1_|BR2);
// Gate A4-U102B
pullup(TRSM_);
assign (highz1,strong0) #0.2  TRSM_ = rst ? 1 : ~(0|TRSM);
// Gate A4-U255B
pullup(A4U255Pad9);
assign (highz1,strong0) #0.2  A4U255Pad9 = rst ? 0 : ~(0|T04_|BRDIF_|TS0_);
// Gate A4-U147A
pullup(A4U147Pad1);
assign (highz1,strong0) #0.2  A4U147Pad1 = rst ? 0 : ~(0|STG3|A4U146Pad1);
// Gate A4-U128A A4-U128B
pullup(DIV_);
assign (highz1,strong0) #0.2  DIV_ = rst ? 1 : ~(0|A4U128Pad2);
// Gate A4-U102A
pullup(DVST_);
assign (highz1,strong0) #0.2  DVST_ = rst ? 1 : ~(0|DVST);
// Gate A4-U237A
pullup(A4U237Pad1);
assign (highz1,strong0) #0.2  A4U237Pad1 = rst ? 0 : ~(0|DV1_|T07_);
// Gate A4-U229B A4-U259A
pullup(RA_);
assign (highz1,strong0) #0.2  RA_ = rst ? 1 : ~(0|d2XP3|A4U217Pad7|A4U220Pad9|d1XP10|A4U245Pad1|d8XP5);
// Gate A4-U227A
pullup(d9XP1);
assign (highz1,strong0) #0.2  d9XP1 = rst ? 0 : ~(0|T09_|RUPT0_);
// Gate A4-U132A
pullup(A4U132Pad1);
assign (highz1,strong0) #0.2  A4U132Pad1 = rst ? 0 : ~(0|PHS3_|T03_|T12USE_);
// Gate A4-U131B
pullup(T12USE_);
assign (highz1,strong0) #0.2  T12USE_ = rst ? 1 : ~(0|DVST|A4U131Pad1);
// Gate A4-U137B
pullup(A4U137Pad9);
assign (highz1,strong0) #0.2  A4U137Pad9 = rst ? 0 : ~(0|A4U134Pad7|A4U133Pad9);
// Gate A4-U204A
pullup(READ0_);
assign (highz1,strong0) #0.2  READ0_ = rst ? 1 : ~(0|READ0);
// Gate A4-U201B
pullup(A4U201Pad2);
assign (highz1,strong0) #0.2  A4U201Pad2 = rst ? 0 : ~(0|EXST0_|SQ0_);
// Gate A4-U209B A4-U216B
pullup(d5XP11);
assign (highz1,strong0) #0.2  d5XP11 = rst ? 0 : ~(0|T05_|INOUT_|READ0|WRITE0|RXOR0);
// Gate A4-U236B
pullup(B15X);
assign (highz1,strong0) #0.2  B15X = rst ? 0 : ~(0|DV1_|T05_);
// Gate A4-U156A
pullup(ST376);
assign (highz1,strong0) #0.2  ST376 = rst ? 1 : ~(0|A4U156Pad2|A4U139Pad2);
// Gate A4-U138A
pullup(STG1);
assign (highz1,strong0) #0.2  STG1 = rst ? 0 : ~(0|A4U137Pad9|A4U135Pad2);
// Gate A4-U142A
pullup(STG2);
assign (highz1,strong0) #0.2  STG2 = rst ? 1 : ~(0|A4U139Pad2|A4U141Pad1);
// Gate A4-U159B A4-U147B
pullup(STG3);
assign (highz1,strong0) #0.2  STG3 = rst ? 1 : ~(0|A4U146Pad9|A4U147Pad1);
// Gate A4-U129A
pullup(DV4);
assign (highz1,strong0) #0.2  DV4 = rst ? 0 : ~(0|DIV_|ST4_);
// Gate A4-U117A
pullup(A4U117Pad1);
assign (highz1,strong0) #0.2  A4U117Pad1 = rst ? 0 : ~(0|PHS3_|TSGN_);
// Gate A4-U122A
pullup(A4U120Pad8);
assign (highz1,strong0) #0.2  A4U120Pad8 = rst ? 0 : ~(0|A4U122Pad2|L15_);
// Gate A4-U127A
pullup(DV0);
assign (highz1,strong0) #0.2  DV0 = rst ? 0 : ~(0|DIV_|ST0_);
// Gate A4-U259B
pullup(L16_);
assign (highz1,strong0) #0.2  L16_ = rst ? 0 : ~(0|A4U235Pad3);
// Gate A4-U157A
pullup(ST4_);
assign (highz1,strong0) #0.2  ST4_ = rst ? 1 : ~(0|A4U156Pad9);
// Gate A4-U230B A4-U258B
pullup(RC_);
assign (highz1,strong0) #0.2  RC_ = rst ? 1 : ~(0|A4U220Pad9|A4U228Pad1|A4U214Pad9|d2XP5|A4U239Pad7|A4U246Pad1);
// Gate A4-U241A
pullup(A4U239Pad4);
assign (highz1,strong0) #0.2  A4U239Pad4 = rst ? 0 : ~(0|T09_|BR1|MP0_);
// Gate A4-U248B
pullup(d6XP5);
assign (highz1,strong0) #0.2  d6XP5 = rst ? 0 : ~(0|T06_|DV1_);
// Gate A4-U159A
pullup(DV3764);
assign (highz1,strong0) #0.2  DV3764 = rst ? 0 : ~(0|DIV_|A4U158Pad1);
// Gate A4-U203B A4-U202B
pullup(DV4_);
assign (highz1,strong0) #0.2  DV4_ = rst ? 1 : ~(0|DV4);
// Gate A4-U244A
pullup(TL15);
assign (highz1,strong0) #0.2  TL15 = rst ? 0 : ~(0|MP3_|T06_);
// Gate A4-U224A
pullup(A4U224Pad1);
assign (highz1,strong0) #0.2  A4U224Pad1 = rst ? 1 : ~(0|IC13|IC12|RUPT1);
// Gate A4-U250A
pullup(A4U250Pad1);
assign (highz1,strong0) #0.2  A4U250Pad1 = rst ? 0 : ~(0|T02_|A4U249Pad1);
// Gate A4-U243A
pullup(BR1B2);
assign (highz1,strong0) #0.2  BR1B2 = rst ? 0 : ~(0|BR2_|BR1);
// Gate A4-U260A
pullup(d8XP5);
assign (highz1,strong0) #0.2  d8XP5 = rst ? 0 : ~(0|DV1_|T08_);
// Gate A4-U209A
pullup(d3XP7);
assign (highz1,strong0) #0.2  d3XP7 = rst ? 0 : ~(0|T03_|RXOR0_);
// Gate A4-U256B
pullup(CI_);
assign (highz1,strong0) #0.2  CI_ = rst ? 1 : ~(0|A4U245Pad9|A4U255Pad9);
// Gate A4-U126A
pullup(DV0_);
assign (highz1,strong0) #0.2  DV0_ = rst ? 1 : ~(0|DV0);
// Gate A4-U253B
pullup(MRSC);
assign (highz1,strong0) #0.2  MRSC = rst ? 0 : ~(0|RSC_);
// Gate A4-U110A
pullup(A4U107Pad7);
assign (highz1,strong0) #0.2  A4U107Pad7 = rst ? 0 : ~(0|PHS3_|A4U110Pad3);
// Gate A4-U207A
pullup(RRPA);
assign (highz1,strong0) #0.2  RRPA = rst ? 0 : ~(0|RUPT1_|T03_);
// Gate A4-U145B
pullup(A4U145Pad2);
assign (highz1,strong0) #0.2  A4U145Pad2 = rst ? 0 : ~(0|DVST_|A4U139Pad2);
// Gate A4-U255A
pullup(MP0T10);
assign (highz1,strong0) #0.2  MP0T10 = rst ? 0 : ~(0|T10_|MP0_);
// Gate A4-U247A
pullup(d2XP5);
assign (highz1,strong0) #0.2  d2XP5 = rst ? 0 : ~(0|T02_|DV0_|BR1);
// Gate A4-U224B
pullup(d2XP3);
assign (highz1,strong0) #0.2  d2XP3 = rst ? 0 : ~(0|T02_|INOUT_);
// Gate A4-U133A
pullup(A4U133Pad1);
assign (highz1,strong0) #0.2  A4U133Pad1 = rst ? 0 : ~(0|PHS3_|A4U131Pad1|T12_);
// Gate A4-U153A
pullup(ST1376_);
assign (highz1,strong0) #0.2  ST1376_ = rst ? 0 : ~(0|ST376|ST1D);
// Gate A4-U149B
pullup(A4U149Pad9);
assign (highz1,strong0) #0.2  A4U149Pad9 = rst ? 0 : ~(0|STG3|STG1|STG2);
// Gate A4-U133B A4-U134A
pullup(A4U133Pad9);
assign (highz1,strong0) #0.2  A4U133Pad9 = rst ? 1 : ~(0|A4U132Pad1|A4U133Pad1);
// Gate A4-U131A
pullup(A4U131Pad1);
assign (highz1,strong0) #0.2  A4U131Pad1 = rst ? 0 : ~(0|RSTSTG|T12USE_|GOJAM);
// Gate A4-U222A A4-U239A
pullup(RB_);
assign (highz1,strong0) #0.2  RB_ = rst ? 1 : ~(0|A4U222Pad2|A4U213Pad1|A4U221Pad9|A4U239Pad2|d7XP19|A4U239Pad4);
// Gate A4-U260B
pullup(A4U235Pad3);
assign (highz1,strong0) #0.2  A4U235Pad3 = rst ? 0 : ~(0|BR1_|T11_|MP0_);
// Gate A4-U233B
pullup(A4U233Pad9);
assign (highz1,strong0) #0.2  A4U233Pad9 = rst ? 0 : ~(0|T05_|BR12B_|TS0_);
// Gate A4-U144B A4-U104B
pullup(A4U104Pad9);
assign (highz1,strong0) #0.2  A4U104Pad9 = rst ? 0 : ~(0|T01|STRTFC|A4U144Pad8|RSTSTG);
// Gate A4-U237B
pullup(d7XP19);
assign (highz1,strong0) #0.2  d7XP19 = rst ? 0 : ~(0|BR1_|MP3_|T07_);
// Gate A4-U251B
pullup(R15);
assign (highz1,strong0) #0.2  R15 = rst ? 0 : ~(0|T01_|A4U251Pad1);
// Gate A4-U150A A4-U152A A4-U151A
pullup(ST1_);
assign (highz1,strong0) #0.2  ST1_ = rst ? 1 : ~(0|ST1D);
// Gate A4-U155A
pullup(A4U155Pad1);
assign (highz1,strong0) #0.2  A4U155Pad1 = rst ? 0 : ~(0|A4U135Pad2|STG3|A4U139Pad2);
// Gate A4-U158A
pullup(A4U158Pad1);
assign (highz1,strong0) #0.2  A4U158Pad1 = rst ? 0 : ~(0|A4U156Pad9|ST376);
// Gate A4-U201A A4-U202A
pullup(A4U201Pad1);
assign (highz1,strong0) #0.2  A4U201Pad1 = rst ? 1 : ~(0|A4U201Pad2);
// Gate A4-U141B
pullup(A4U141Pad9);
assign (highz1,strong0) #0.2  A4U141Pad9 = rst ? 0 : ~(0|A4U133Pad9|A4U139Pad9);
// Gate A4-U109B
pullup(A4U108Pad8);
assign (highz1,strong0) #0.2  A4U108Pad8 = rst ? 0 : ~(0|TMZ_|PHS3_);
// Gate A4-U115A
pullup(A4U108Pad7);
assign (highz1,strong0) #0.2  A4U108Pad7 = rst ? 0 : ~(0|PHS2_|TOV_);
// Gate A4-U141A
pullup(A4U141Pad1);
assign (highz1,strong0) #0.2  A4U141Pad1 = rst ? 0 : ~(0|A4U133Pad9|A4U140Pad1);
// Gate A4-U130B
pullup(DV376_);
assign (highz1,strong0) #0.2  DV376_ = rst ? 1 : ~(0|DV376);
// Gate A4-U114A A4-U114B A4-U112A A4-U112B A4-U113A A4-U111A
pullup(A4U108Pad2);
assign (highz1,strong0) #0.2  A4U108Pad2 = rst ? 0 : ~(0|WL01_|TMZ_|PHS4_|WL03_|WL04_|WL02_|WL10_|WL08_|WL09_|WL11_|WL12_|WL13_|WL07_|WL06_|WL05_|WL16_|WL15_|WL14_);
// Gate A4-U110B
pullup(A4U108Pad3);
assign (highz1,strong0) #0.2  A4U108Pad3 = rst ? 0 : ~(0|PHS4_|WL16_|A4U110Pad3);
// Gate A4-U246A
pullup(A4U246Pad1);
assign (highz1,strong0) #0.2  A4U246Pad1 = rst ? 0 : ~(0|BR1_|T09_|MP0_);
// Gate A4-U217B
pullup(WCH_);
assign (highz1,strong0) #0.2  WCH_ = rst ? 1 : ~(0|A4U217Pad6|A4U217Pad7|d7XP14);

endmodule
