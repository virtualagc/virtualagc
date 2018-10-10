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
pullup(g36112);
assign #0.2  g36112 = rst ? 0 : ((0|g36124|g36118|ST1|GOJAM|MTCSAI) ? 1'b0 : 1'bz);
// Gate A4-U239B
pullup(WL_);
assign #0.2  WL_ = rst ? 1'bz : ((0|g36425|g36427|d6XP5) ? 1'b0 : 1'bz);
// Gate A4-U136A
pullup(g36114);
assign #0.2  g36114 = rst ? 0 : ((0|g36112|g36111) ? 1'b0 : 1'bz);
// Gate A4-U220B
pullup(g36354);
assign #0.2  g36354 = rst ? 0 : ((0|T05_|RXOR0_) ? 1'b0 : 1'bz);
// Gate A4-U240A
pullup(g36425);
assign #0.2  g36425 = rst ? 0 : ((0|BR1|MP0_|T04_) ? 1'b0 : 1'bz);
// Gate A4-U136B
pullup(g36118);
assign #0.2  g36118 = rst ? 0 : ((0|g36112|T01) ? 1'b0 : 1'bz);
// Gate A4-U144A
pullup(g36124);
assign #0.2  g36124 = rst ? 0 : ((0|STG3|DVST_) ? 1'b0 : 1'bz);
// Gate A4-U252B
pullup(g36427);
assign #0.2  g36427 = rst ? 0 : ((0|MP0_|T04_|BR1_) ? 1'b0 : 1'bz);
// Gate A4-U250B
pullup(RB2);
assign #0.2  RB2 = rst ? 0 : ((0|T01_|RUPT1_) ? 1'b0 : 1'bz);
// Gate A4-U204B
pullup(READ0);
assign #0.2  READ0 = rst ? 0 : ((0|SQR10|g36307|QC0_) ? 1'b0 : 1'bz);
// Gate A4-U142B A4-U143B
pullup(g36133);
assign #0.2  g36133 = rst ? 1'bz : ((0|g36131|STG2) ? 1'b0 : 1'bz);
// Gate A4-U256A
pullup(RB1_);
assign #0.2  RB1_ = rst ? 1'bz : ((0|g36436|g36451) ? 1'b0 : 1'bz);
// Gate A4-U210B
pullup(g36333);
assign #0.2  g36333 = rst ? 1'bz : ((0|ROR0|WOR0) ? 1'b0 : 1'bz);
// Gate A4-U140B A4-U139B
pullup(g36129);
assign #0.2  g36129 = rst ? 1'bz : ((0|g36139|MTCSAI|g36135|ST2|g36261) ? 1'b0 : 1'bz);
// Gate A4-U248A
pullup(d1XP10);
assign #0.2  d1XP10 = rst ? 0 : ((0|T01_|DV0_) ? 1'b0 : 1'bz);
// Gate A4-U153B
pullup(DV1376);
assign #0.2  DV1376 = rst ? 0 : ((0|ST1376_|DIV_) ? 1'b0 : 1'bz);
// Gate A4-U123B
pullup(g36217);
assign #0.2  g36217 = rst ? 1'bz : ((0|TL15) ? 1'b0 : 1'bz);
// Gate A4-U156B
pullup(g36144);
assign #0.2  g36144 = rst ? 0 : ((0|STG2|STG1|g36148) ? 1'b0 : 1'bz);
// Gate A4-U124A
pullup(g36213);
assign #0.2  g36213 = rst ? 0 : ((0|SUMB16_|SUMA16_) ? 1'b0 : 1'bz);
// Gate A4-U249B
pullup(d2PP1);
assign #0.2  d2PP1 = rst ? 1'bz : ((0|INOUT|MP1|MP3A) ? 1'b0 : 1'bz);
// Gate A4-U117B
pullup(g36221);
assign #0.2  g36221 = rst ? 0 : ((0|WL16_|PHS4_|TSGN_) ? 1'b0 : 1'bz);
// Gate A4-U157B
pullup(g36152);
assign #0.2  g36152 = rst ? 1'bz : ((0|STG1|STG3) ? 1'b0 : 1'bz);
// Gate A4-U211A
pullup(ROR0);
assign #0.2  ROR0 = rst ? 0 : ((0|g36307|QC2_|SQR10) ? 1'b0 : 1'bz);
// Gate A4-U109A A4-U118A A4-U119A
pullup(BR1_);
assign #0.2  BR1_ = rst ? 1'bz : ((0|g36228) ? 1'b0 : 1'bz);
// Gate A4-U116B A4-U115B
pullup(g36231);
assign #0.2  g36231 = rst ? 0 : ((0|PHS4|PHS3_|g36213|TSGU_) ? 1'b0 : 1'bz);
// Gate A4-U154A A4-U148A
pullup(STD2);
assign #0.2  STD2 = rst ? 0 : ((0|STG3|g36133|STG1|INKL) ? 1'b0 : 1'bz);
// Gate A4-U101B
pullup(MBR2);
assign #0.2  MBR2 = rst ? 0 : ((0|g36241) ? 1'b0 : 1'bz);
// Gate A4-U113B
pullup(MBR1);
assign #0.2  MBR1 = rst ? 0 : ((0|g36222) ? 1'b0 : 1'bz);
// Gate A4-U240B
pullup(BRDIF_);
assign #0.2  BRDIF_ = rst ? 1'bz : ((0|BR12B|BR1B2) ? 1'b0 : 1'bz);
// Gate A4-U155B
pullup(ST3_);
assign #0.2  ST3_ = rst ? 1'bz : ((0|g36140) ? 1'b0 : 1'bz);
// Gate A4-U228A
pullup(g36340);
assign #0.2  g36340 = rst ? 0 : ((0|T09_|RXOR0_) ? 1'b0 : 1'bz);
// Gate A4-U246B
pullup(KRPT);
assign #0.2  KRPT = rst ? 0 : ((0|T09_|RUPT1_) ? 1'b0 : 1'bz);
// Gate A4-U238B
pullup(BR1B2_);
assign #0.2  BR1B2_ = rst ? 1'bz : ((0|BR1B2) ? 1'b0 : 1'bz);
// Gate A4-U121B A4-U120B
pullup(g36222);
assign #0.2  g36222 = rst ? 1'bz : ((0|SGUM|g36216|g36228|g36221|g36218) ? 1'b0 : 1'bz);
// Gate A4-U242B
pullup(BR1B2B);
assign #0.2  BR1B2B = rst ? 1'bz : ((0|BR2|BR1) ? 1'b0 : 1'bz);
// Gate A4-U132B
pullup(DIVSTG);
assign #0.2  DIVSTG = rst ? 0 : ((0|T12USE_|T03_) ? 1'b0 : 1'bz);
// Gate A4-U225A
pullup(g36326);
assign #0.2  g36326 = rst ? 1'bz : ((0|SQEXT|QC3_) ? 1'b0 : 1'bz);
// Gate A4-U235A
pullup(R1C_);
assign #0.2  R1C_ = rst ? 1'bz : ((0|g36438|g36451) ? 1'b0 : 1'bz);
// Gate A4-U225B
pullup(g36329);
assign #0.2  g36329 = rst ? 1'bz : ((0|g36328) ? 1'b0 : 1'bz);
// Gate A4-U231A
pullup(g36413);
assign #0.2  g36413 = rst ? 0 : ((0|T03_|MP0_) ? 1'b0 : 1'bz);
// Gate A4-U215A
pullup(RXOR0);
assign #0.2  RXOR0 = rst ? 0 : ((0|g36307|QC3_|SQR10) ? 1'b0 : 1'bz);
// Gate A4-U234B
pullup(g36436);
assign #0.2  g36436 = rst ? 0 : ((0|TS0_|BR1B2_|T05_) ? 1'b0 : 1'bz);
// Gate A4-U125B A4-U126B A4-U127B
pullup(DV1_);
assign #0.2  DV1_ = rst ? 1'bz : ((0|DV1) ? 1'b0 : 1'bz);
// Gate A4-U243B
pullup(BR1B2B_);
assign #0.2  BR1B2B_ = rst ? 0 : ((0|BR1B2B) ? 1'b0 : 1'bz);
// Gate A4-U234A
pullup(g36414);
assign #0.2  g36414 = rst ? 0 : ((0|INOUT_|T03_) ? 1'b0 : 1'bz);
// Gate A4-U218A
pullup(RUPT0_);
assign #0.2  RUPT0_ = rst ? 1'bz : ((0|RUPT0) ? 1'b0 : 1'bz);
// Gate A4-U247B
pullup(g36435);
assign #0.2  g36435 = rst ? 0 : ((0|MP3_|T04_) ? 1'b0 : 1'bz);
// Gate A4-U242A
pullup(BR12B);
assign #0.2  BR12B = rst ? 0 : ((0|BR1_|BR2) ? 1'b0 : 1'bz);
// Gate A4-U244B
pullup(g36431);
assign #0.2  g36431 = rst ? 0 : ((0|DV1_|T04_|BR2_) ? 1'b0 : 1'bz);
// Gate A4-U212B
pullup(RAND0);
assign #0.2  RAND0 = rst ? 0 : ((0|SQR10|QC1_|g36307) ? 1'b0 : 1'bz);
// Gate A4-U158B
pullup(ST376_);
assign #0.2  ST376_ = rst ? 1'bz : ((0|ST376) ? 1'b0 : 1'bz);
// Gate A4-U245B
pullup(g36444);
assign #0.2  g36444 = rst ? 0 : ((0|BRDIF_|MP0_|T09_) ? 1'b0 : 1'bz);
// Gate A4-U212A
pullup(WAND0);
assign #0.2  WAND0 = rst ? 0 : ((0|SQR10_|g36307|QC1_) ? 1'b0 : 1'bz);
// Gate A4-U116A A4-U124B
pullup(SGUM);
assign #0.2  SGUM = rst ? 0 : ((0|PHS3_|PHS4|SUMA16_|SUMB16_|TSGU_) ? 1'b0 : 1'bz);
// Gate A4-U137A
pullup(g36115);
assign #0.2  g36115 = rst ? 1'bz : ((0|STG1|g36114) ? 1'b0 : 1'bz);
// Gate A4-U222B A4-U220A
pullup(RUPT1);
assign #0.2  RUPT1 = rst ? 0 : ((0|SQR10_|EXST1_|QC3_|SQ0_) ? 1'b0 : 1'bz);
// Gate A4-U111B
pullup(g36239);
assign #0.2  g36239 = rst ? 1'bz : ((0|TSGN2) ? 1'b0 : 1'bz);
// Gate A4-U219B
pullup(g36353);
assign #0.2  g36353 = rst ? 0 : ((0|T05_|WOR0_) ? 1'b0 : 1'bz);
// Gate A4-U228B A4-U226A
pullup(PRINC);
assign #0.2  PRINC = rst ? 0 : ((0|g36329|g36326) ? 1'b0 : 1'bz);
// Gate A4-U107A A4-U108A
pullup(g36241);
assign #0.2  g36241 = rst ? 1'bz : ((0|g36233|g36236|g36243|g36240|g36249) ? 1'b0 : 1'bz);
// Gate A4-U138B A4-U101A
pullup(g36261);
assign #0.2  g36261 = rst ? 0 : ((0|XB7_|TRSM_|XT1_|NDR100_) ? 1'b0 : 1'bz);
// Gate A4-U203A
pullup(INOUT);
assign #0.2  INOUT = rst ? 0 : ((0|RUPT0|SQ0_|EXST0_) ? 1'b0 : 1'bz);
// Gate A4-U252A
pullup(RSC_);
assign #0.2  RSC_ = rst ? 1'bz : ((0|g36456|g36435|g36407) ? 1'b0 : 1'bz);
// Gate A4-U226B
pullup(g36343);
assign #0.2  g36343 = rst ? 0 : ((0|g36342|T09_) ? 1'b0 : 1'bz);
// Gate A4-U227B
pullup(g36360);
assign #0.2  g36360 = rst ? 0 : ((0|T09_|STORE1_) ? 1'b0 : 1'bz);
// Gate A4-U211B
pullup(WOR0_);
assign #0.2  WOR0_ = rst ? 1'bz : ((0|WOR0) ? 1'b0 : 1'bz);
// Gate A4-U257A A4-U257B
pullup(TSGN_);
assign #0.2  TSGN_ = rst ? 1'bz : ((0|g36413|g36431|g36456|MP0T10|d1XP10) ? 1'b0 : 1'bz);
// Gate A4-U214A
pullup(RXOR0_);
assign #0.2  RXOR0_ = rst ? 1'bz : ((0|RXOR0) ? 1'b0 : 1'bz);
// Gate A4-U135A
pullup(MST1);
assign #0.2  MST1 = rst ? 0 : ((0|g36115) ? 1'b0 : 1'bz);
// Gate A4-U139A
pullup(MST2);
assign #0.2  MST2 = rst ? 0 : ((0|g36133) ? 1'b0 : 1'bz);
// Gate A4-U148B
pullup(MST3);
assign #0.2  MST3 = rst ? 0 : ((0|g36148) ? 1'b0 : 1'bz);
// Gate A4-U213B
pullup(g36337);
assign #0.2  g36337 = rst ? 1'bz : ((0|RAND0|WAND0) ? 1'b0 : 1'bz);
// Gate A4-U130A
pullup(DV376);
assign #0.2  DV376 = rst ? 0 : ((0|DIV_|ST376_) ? 1'b0 : 1'bz);
// Gate A4-U206A
pullup(WRITE0_);
assign #0.2  WRITE0_ = rst ? 1'bz : ((0|WRITE0) ? 1'b0 : 1'bz);
// Gate A4-U213A
pullup(g36334);
assign #0.2  g36334 = rst ? 0 : ((0|g36333|T03_) ? 1'b0 : 1'bz);
// Gate A4-U206B
pullup(WRITE0);
assign #0.2  WRITE0 = rst ? 0 : ((0|QC0_|SQR10_|g36307) ? 1'b0 : 1'bz);
// Gate A4-U150B A4-U151B
pullup(ST0_);
assign #0.2  ST0_ = rst ? 0 : ((0|g36105) ? 1'b0 : 1'bz);
// Gate A4-U245A
pullup(g36446);
assign #0.2  g36446 = rst ? 0 : ((0|T09_|MP3_) ? 1'b0 : 1'bz);
// Gate A4-U236A
pullup(TSGN2);
assign #0.2  TSGN2 = rst ? 0 : ((0|T07_|MP0_) ? 1'b0 : 1'bz);
// Gate A4-U205A
pullup(INOUT_);
assign #0.2  INOUT_ = rst ? 1'bz : ((0|INOUT) ? 1'b0 : 1'bz);
// Gate A4-U221B
pullup(g36348);
assign #0.2  g36348 = rst ? 0 : ((0|T05_|READ0_) ? 1'b0 : 1'bz);
// Gate A4-U251A
pullup(g36401);
assign #0.2  g36401 = rst ? 1'bz : ((0|RUPT1|RSM3|RUPT0) ? 1'b0 : 1'bz);
// Gate A4-U143A
pullup(g36139);
assign #0.2  g36139 = rst ? 0 : ((0|g36115|DVST_) ? 1'b0 : 1'bz);
// Gate A4-U229A A4-U230A A4-U253A
pullup(WG_);
assign #0.2  WG_ = rst ? 1'bz : ((0|d9XP1|g36340|g36354|g36351|g36343|g36360|g36407|g36435) ? 1'b0 : 1'bz);
// Gate A4-U207B
pullup(d8PP4);
assign #0.2  d8PP4 = rst ? 0 : ((0|DV4|INOUT|PRINC) ? 1'b0 : 1'bz);
// Gate A4-U149A
pullup(ST1D);
assign #0.2  ST1D = rst ? 0 : ((0|g36115|STG2|STG3) ? 1'b0 : 1'bz);
// Gate A4-U140A
pullup(g36135);
assign #0.2  g36135 = rst ? 0 : ((0|T01|g36129|GOJAM) ? 1'b0 : 1'bz);
// Gate A4-U146A
pullup(g36147);
assign #0.2  g36147 = rst ? 0 : ((0|g36111|g36146) ? 1'b0 : 1'bz);
// Gate A4-U145A
pullup(g36146);
assign #0.2  g36146 = rst ? 1'bz : ((0|g36155|g36159) ? 1'b0 : 1'bz);
// Gate A4-U125A
pullup(DV1);
assign #0.2  DV1 = rst ? 0 : ((0|DIV_|ST1_) ? 1'b0 : 1'bz);
// Gate A4-U232A
pullup(d3XP2);
assign #0.2  d3XP2 = rst ? 0 : ((0|T03_|TS0_) ? 1'b0 : 1'bz);
// Gate A4-U146B
pullup(g36150);
assign #0.2  g36150 = rst ? 0 : ((0|g36159|g36111) ? 1'b0 : 1'bz);
// Gate A4-U238A
pullup(BR12B_);
assign #0.2  BR12B_ = rst ? 1'bz : ((0|BR12B) ? 1'b0 : 1'bz);
// Gate A4-U121A A4-U120A
pullup(g36228);
assign #0.2  g36228 = rst ? 0 : ((0|g36222|g36227|g36224|g36230|g36231) ? 1'b0 : 1'bz);
// Gate A4-U106B A4-U105B
pullup(BR2_);
assign #0.2  BR2_ = rst ? 1'bz : ((0|g36249) ? 1'b0 : 1'bz);
// Gate A4-U231B
pullup(d5XP4);
assign #0.2  d5XP4 = rst ? 0 : ((0|RSM3_|T05_) ? 1'b0 : 1'bz);
// Gate A4-U104A A4-U160A A4-U105A
pullup(g);
assign #0.2  g = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A4-U154B
pullup(DV1376_);
assign #0.2  DV1376_ = rst ? 1'bz : ((0|DV1376) ? 1'b0 : 1'bz);
// Gate A4-U221A
pullup(RUPT1_);
assign #0.2  RUPT1_ = rst ? 1'bz : ((0|RUPT1) ? 1'b0 : 1'bz);
// Gate A4-U254B
pullup(TMZ_);
assign #0.2  TMZ_ = rst ? 1'bz : ((0|d2XP5|d1XP10) ? 1'b0 : 1'bz);
// Gate A4-U223B
pullup(g36351);
assign #0.2  g36351 = rst ? 0 : ((0|WRITE0_|T02_) ? 1'b0 : 1'bz);
// Gate A4-U152B
pullup(MP3A);
assign #0.2  MP3A = rst ? 0 : ((0|MP3_) ? 1'b0 : 1'bz);
// Gate A4-U235B A4-U258A
pullup(WY_);
assign #0.2  WY_ = rst ? 1'bz : ((0|B15X|d7XP19|g36414|d8XP5|g36437|g36439) ? 1'b0 : 1'bz);
// Gate A4-U223A
pullup(g36328);
assign #0.2  g36328 = rst ? 0 : ((0|SQR12_|SQ2_|ST0_) ? 1'b0 : 1'bz);
// Gate A4-U107B A4-U108B
pullup(g36249);
assign #0.2  g36249 = rst ? 0 : ((0|g36241|g36244|g36230|g36252) ? 1'b0 : 1'bz);
// Gate A4-U106A
pullup(BR2);
assign #0.2  BR2 = rst ? 0 : ((0|g36241) ? 1'b0 : 1'bz);
// Gate A4-U118B A4-U119B A4-U160B
pullup(BR1);
assign #0.2  BR1 = rst ? 0 : ((0|g36222) ? 1'b0 : 1'bz);
// Gate A4-U232B
pullup(d4XP5);
assign #0.2  d4XP5 = rst ? 0 : ((0|T04_|TS0_) ? 1'b0 : 1'bz);
// Gate A4-U123A
pullup(g36216);
assign #0.2  g36216 = rst ? 0 : ((0|UNF_|TOV_) ? 1'b0 : 1'bz);
// Gate A4-U122B
pullup(g36227);
assign #0.2  g36227 = rst ? 0 : ((0|PHS3_|g36217) ? 1'b0 : 1'bz);
// Gate A4-U215B
pullup(d5XP28);
assign #0.2  d5XP28 = rst ? 0 : ((0|T05_|DV4_) ? 1'b0 : 1'bz);
// Gate A4-U214B
pullup(g36338);
assign #0.2  g36338 = rst ? 0 : ((0|g36337|T03_) ? 1'b0 : 1'bz);
// Gate A4-U129B
pullup(g36201);
assign #0.2  g36201 = rst ? 0 : ((0|QC0_|SQ1_|SQEXT_) ? 1'b0 : 1'bz);
// Gate A4-U217A
pullup(RUPT0);
assign #0.2  RUPT0 = rst ? 0 : ((0|g36307|SQR10_|QC3_) ? 1'b0 : 1'bz);
// Gate A4-U103A
pullup(g36233);
assign #0.2  g36233 = rst ? 0 : ((0|PHS4_|TPZG_|GEQZRO_) ? 1'b0 : 1'bz);
// Gate A4-U249A
pullup(g36406);
assign #0.2  g36406 = rst ? 0 : ((0|d2PP1) ? 1'b0 : 1'bz);
// Gate A4-U103B
pullup(g36236);
assign #0.2  g36236 = rst ? 0 : ((0|TOV_|OVF_) ? 1'b0 : 1'bz);
// Gate A4-U218B
pullup(g36349);
assign #0.2  g36349 = rst ? 0 : ((0|T05_|WRITE0_) ? 1'b0 : 1'bz);
// Gate A4-U210A
pullup(WOR0);
assign #0.2  WOR0 = rst ? 0 : ((0|QC2_|g36307|SQR10_) ? 1'b0 : 1'bz);
// Gate A4-U233A
pullup(d4XP11);
assign #0.2  d4XP11 = rst ? 0 : ((0|INOUT_|T04_) ? 1'b0 : 1'bz);
// Gate A4-U241B
pullup(d8XP6);
assign #0.2  d8XP6 = rst ? 0 : ((0|T08_|DV1_|BR2) ? 1'b0 : 1'bz);
// Gate A4-U102B
pullup(TRSM_);
assign #0.2  TRSM_ = rst ? 1'bz : ((0|TRSM) ? 1'b0 : 1'bz);
// Gate A4-U255B
pullup(g36424);
assign #0.2  g36424 = rst ? 0 : ((0|T04_|BRDIF_|TS0_) ? 1'b0 : 1'bz);
// Gate A4-U147A
pullup(g36148);
assign #0.2  g36148 = rst ? 1'bz : ((0|STG3|g36147) ? 1'b0 : 1'bz);
// Gate A4-U128A A4-U128B
pullup(DIV_);
assign #0.2  DIV_ = rst ? 1'bz : ((0|g36201) ? 1'b0 : 1'bz);
// Gate A4-U102A
pullup(DVST_);
assign #0.2  DVST_ = rst ? 1'bz : ((0|DVST) ? 1'b0 : 1'bz);
// Gate A4-U237A
pullup(g36456);
assign #0.2  g36456 = rst ? 0 : ((0|DV1_|T07_) ? 1'b0 : 1'bz);
// Gate A4-U229B A4-U259A
pullup(RA_);
assign #0.2  RA_ = rst ? 1'bz : ((0|d2XP3|g36349|g36354|d1XP10|g36446|d8XP5) ? 1'b0 : 1'bz);
// Gate A4-U227A
pullup(d9XP1);
assign #0.2  d9XP1 = rst ? 0 : ((0|T09_|RUPT0_) ? 1'b0 : 1'bz);
// Gate A4-U132A
pullup(g36103);
assign #0.2  g36103 = rst ? 0 : ((0|PHS3_|T03_|T12USE_) ? 1'b0 : 1'bz);
// Gate A4-U131B
pullup(T12USE_);
assign #0.2  T12USE_ = rst ? 1'bz : ((0|DVST|g36109) ? 1'b0 : 1'bz);
// Gate A4-U137B
pullup(g36119);
assign #0.2  g36119 = rst ? 0 : ((0|g36118|g36111) ? 1'b0 : 1'bz);
// Gate A4-U204A
pullup(READ0_);
assign #0.2  READ0_ = rst ? 1'bz : ((0|READ0) ? 1'b0 : 1'bz);
// Gate A4-U201B
pullup(g36303);
assign #0.2  g36303 = rst ? 0 : ((0|EXST0_|SQ0_) ? 1'b0 : 1'bz);
// Gate A4-U209B A4-U216B
pullup(d5XP11);
assign #0.2  d5XP11 = rst ? 0 : ((0|T05_|INOUT_|READ0|WRITE0|RXOR0) ? 1'b0 : 1'bz);
// Gate A4-U236B
pullup(B15X);
assign #0.2  B15X = rst ? 0 : ((0|DV1_|T05_) ? 1'b0 : 1'bz);
// Gate A4-U156A
pullup(ST376);
assign #0.2  ST376 = rst ? 0 : ((0|g36152|g36133) ? 1'b0 : 1'bz);
// Gate A4-U138A
pullup(STG1);
assign #0.2  STG1 = rst ? 0 : ((0|g36119|g36115) ? 1'b0 : 1'bz);
// Gate A4-U142A
pullup(STG2);
assign #0.2  STG2 = rst ? 0 : ((0|g36133|g36136) ? 1'b0 : 1'bz);
// Gate A4-U159B A4-U147B
pullup(STG3);
assign #0.2  STG3 = rst ? 0 : ((0|g36150|g36148) ? 1'b0 : 1'bz);
// Gate A4-U129A
pullup(DV4);
assign #0.2  DV4 = rst ? 0 : ((0|DIV_|ST4_) ? 1'b0 : 1'bz);
// Gate A4-U117A
pullup(g36224);
assign #0.2  g36224 = rst ? 0 : ((0|PHS3_|TSGN_) ? 1'b0 : 1'bz);
// Gate A4-U122A
pullup(g36218);
assign #0.2  g36218 = rst ? 0 : ((0|g36217|L15_) ? 1'b0 : 1'bz);
// Gate A4-U127A
pullup(DV0);
assign #0.2  DV0 = rst ? 0 : ((0|DIV_|ST0_) ? 1'b0 : 1'bz);
// Gate A4-U259B
pullup(L16_);
assign #0.2  L16_ = rst ? 1'bz : ((0|g36451) ? 1'b0 : 1'bz);
// Gate A4-U157A
pullup(ST4_);
assign #0.2  ST4_ = rst ? 1'bz : ((0|g36144) ? 1'b0 : 1'bz);
// Gate A4-U230B A4-U258B
pullup(RC_);
assign #0.2  RC_ = rst ? 1'bz : ((0|g36354|g36340|g36338|d2XP5|g36427|g36439) ? 1'b0 : 1'bz);
// Gate A4-U241A
pullup(g36437);
assign #0.2  g36437 = rst ? 0 : ((0|T09_|BR1|MP0_) ? 1'b0 : 1'bz);
// Gate A4-U248B
pullup(d6XP5);
assign #0.2  d6XP5 = rst ? 0 : ((0|T06_|DV1_) ? 1'b0 : 1'bz);
// Gate A4-U159A
pullup(DV3764);
assign #0.2  DV3764 = rst ? 0 : ((0|DIV_|g36156) ? 1'b0 : 1'bz);
// Gate A4-U203B A4-U202B
pullup(DV4_);
assign #0.2  DV4_ = rst ? 1'bz : ((0|DV4) ? 1'b0 : 1'bz);
// Gate A4-U244A
pullup(TL15);
assign #0.2  TL15 = rst ? 0 : ((0|MP3_|T06_) ? 1'b0 : 1'bz);
// Gate A4-U224A
pullup(g36342);
assign #0.2  g36342 = rst ? 0 : ((0|IC13|IC12|RUPT1) ? 1'b0 : 1'bz);
// Gate A4-U250A
pullup(g36407);
assign #0.2  g36407 = rst ? 0 : ((0|T02_|g36406) ? 1'b0 : 1'bz);
// Gate A4-U243A
pullup(BR1B2);
assign #0.2  BR1B2 = rst ? 0 : ((0|BR2_|BR1) ? 1'b0 : 1'bz);
// Gate A4-U260A
pullup(d8XP5);
assign #0.2  d8XP5 = rst ? 0 : ((0|DV1_|T08_) ? 1'b0 : 1'bz);
// Gate A4-U209A
pullup(d3XP7);
assign #0.2  d3XP7 = rst ? 0 : ((0|T03_|RXOR0_) ? 1'b0 : 1'bz);
// Gate A4-U256B
pullup(CI_);
assign #0.2  CI_ = rst ? 1'bz : ((0|g36444|g36424) ? 1'b0 : 1'bz);
// Gate A4-U126A
pullup(DV0_);
assign #0.2  DV0_ = rst ? 1'bz : ((0|DV0) ? 1'b0 : 1'bz);
// Gate A4-U253B
pullup(MRSC);
assign #0.2  MRSC = rst ? 0 : ((0|RSC_) ? 1'b0 : 1'bz);
// Gate A4-U110A
pullup(g36244);
assign #0.2  g36244 = rst ? 0 : ((0|PHS3_|g36239) ? 1'b0 : 1'bz);
// Gate A4-U207A
pullup(RRPA);
assign #0.2  RRPA = rst ? 0 : ((0|RUPT1_|T03_) ? 1'b0 : 1'bz);
// Gate A4-U145B
pullup(g36155);
assign #0.2  g36155 = rst ? 0 : ((0|DVST_|g36133) ? 1'b0 : 1'bz);
// Gate A4-U255A
pullup(MP0T10);
assign #0.2  MP0T10 = rst ? 0 : ((0|T10_|MP0_) ? 1'b0 : 1'bz);
// Gate A4-U247A
pullup(d2XP5);
assign #0.2  d2XP5 = rst ? 0 : ((0|T02_|DV0_|BR1) ? 1'b0 : 1'bz);
// Gate A4-U224B
pullup(d2XP3);
assign #0.2  d2XP3 = rst ? 0 : ((0|T02_|INOUT_) ? 1'b0 : 1'bz);
// Gate A4-U133A
pullup(g36110);
assign #0.2  g36110 = rst ? 0 : ((0|PHS3_|g36109|T12_) ? 1'b0 : 1'bz);
// Gate A4-U153A
pullup(ST1376_);
assign #0.2  ST1376_ = rst ? 1'bz : ((0|ST376|ST1D) ? 1'b0 : 1'bz);
// Gate A4-U149B
pullup(g36105);
assign #0.2  g36105 = rst ? 1'bz : ((0|STG3|STG1|STG2) ? 1'b0 : 1'bz);
// Gate A4-U133B A4-U134A
pullup(g36111);
assign #0.2  g36111 = rst ? 1'bz : ((0|g36103|g36110) ? 1'b0 : 1'bz);
// Gate A4-U131A
pullup(g36109);
assign #0.2  g36109 = rst ? 0 : ((0|RSTSTG|T12USE_|GOJAM) ? 1'b0 : 1'bz);
// Gate A4-U222A A4-U239A
pullup(RB_);
assign #0.2  RB_ = rst ? 1'bz : ((0|g36343|g36334|g36348|g36425|d7XP19|g36437) ? 1'b0 : 1'bz);
// Gate A4-U260B
pullup(g36451);
assign #0.2  g36451 = rst ? 0 : ((0|BR1_|T11_|MP0_) ? 1'b0 : 1'bz);
// Gate A4-U233B
pullup(g36438);
assign #0.2  g36438 = rst ? 0 : ((0|T05_|BR12B_|TS0_) ? 1'b0 : 1'bz);
// Gate A4-U144B A4-U104B
pullup(g36159);
assign #0.2  g36159 = rst ? 0 : ((0|T01|STRTFC|g36146|RSTSTG) ? 1'b0 : 1'bz);
// Gate A4-U237B
pullup(d7XP19);
assign #0.2  d7XP19 = rst ? 0 : ((0|BR1_|MP3_|T07_) ? 1'b0 : 1'bz);
// Gate A4-U251B
pullup(R15);
assign #0.2  R15 = rst ? 0 : ((0|T01_|g36401) ? 1'b0 : 1'bz);
// Gate A4-U150A A4-U152A A4-U151A
pullup(ST1_);
assign #0.2  ST1_ = rst ? 1'bz : ((0|ST1D) ? 1'b0 : 1'bz);
// Gate A4-U155A
pullup(g36140);
assign #0.2  g36140 = rst ? 0 : ((0|g36115|STG3|g36133) ? 1'b0 : 1'bz);
// Gate A4-U158A
pullup(g36156);
assign #0.2  g36156 = rst ? 1'bz : ((0|g36144|ST376) ? 1'b0 : 1'bz);
// Gate A4-U201A A4-U202A
pullup(g36307);
assign #0.2  g36307 = rst ? 1'bz : ((0|g36303) ? 1'b0 : 1'bz);
// Gate A4-U141B
pullup(g36131);
assign #0.2  g36131 = rst ? 0 : ((0|g36111|g36129) ? 1'b0 : 1'bz);
// Gate A4-U109B
pullup(g36252);
assign #0.2  g36252 = rst ? 0 : ((0|TMZ_|PHS3_) ? 1'b0 : 1'bz);
// Gate A4-U115A
pullup(g36230);
assign #0.2  g36230 = rst ? 0 : ((0|PHS2_|TOV_) ? 1'b0 : 1'bz);
// Gate A4-U141A
pullup(g36136);
assign #0.2  g36136 = rst ? 0 : ((0|g36111|g36135) ? 1'b0 : 1'bz);
// Gate A4-U130B
pullup(DV376_);
assign #0.2  DV376_ = rst ? 1'bz : ((0|DV376) ? 1'b0 : 1'bz);
// Gate A4-U114A A4-U114B A4-U112A A4-U112B A4-U113A A4-U111A
pullup(g36243);
assign #0.2  g36243 = rst ? 0 : ((0|WL01_|TMZ_|PHS4_|WL03_|WL04_|WL02_|WL10_|WL08_|WL09_|WL11_|WL12_|WL13_|WL07_|WL06_|WL05_|WL16_|WL15_|WL14_) ? 1'b0 : 1'bz);
// Gate A4-U110B
pullup(g36240);
assign #0.2  g36240 = rst ? 0 : ((0|PHS4_|WL16_|g36239) ? 1'b0 : 1'bz);
// Gate A4-U246A
pullup(g36439);
assign #0.2  g36439 = rst ? 0 : ((0|BR1_|T09_|MP0_) ? 1'b0 : 1'bz);
// Gate A4-U217B
pullup(WCH_);
assign #0.2  WCH_ = rst ? 1'bz : ((0|g36353|g36349|d7XP14) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
