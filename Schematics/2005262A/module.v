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

parameter GATE_DELAY = 20; // This default may be overridden at compile time.
initial $display("Gate delay (A4) will be %f ns.", GATE_DELAY);

// Gate A4-U134B A4-U135B
pullup(g36112);
assign #GATE_DELAY g36112 = rst ? 0 : ((0|g36124|g36118|ST1|GOJAM|MTCSAI) ? 1'b0 : 1'bz);
// Gate A4-U239B
pullup(WL_);
assign #GATE_DELAY WL_ = rst ? 1'bz : ((0|g36425|g36427|d6XP5) ? 1'b0 : 1'bz);
// Gate A4-U136A
pullup(g36114);
assign #GATE_DELAY g36114 = rst ? 0 : ((0|g36111|g36112) ? 1'b0 : 1'bz);
// Gate A4-U220B
pullup(g36354);
assign #GATE_DELAY g36354 = rst ? 0 : ((0|T05_|RXOR0_) ? 1'b0 : 1'bz);
// Gate A4-U240A
pullup(g36425);
assign #GATE_DELAY g36425 = rst ? 0 : ((0|T04_|MP0_|BR1) ? 1'b0 : 1'bz);
// Gate A4-U136B
pullup(g36118);
assign #GATE_DELAY g36118 = rst ? 1'bz : ((0|g36112|T01) ? 1'b0 : 1'bz);
// Gate A4-U144A
pullup(g36124);
assign #GATE_DELAY g36124 = rst ? 0 : ((0|DVST_|STG3) ? 1'b0 : 1'bz);
// Gate A4-U252B
pullup(g36427);
assign #GATE_DELAY g36427 = rst ? 0 : ((0|MP0_|T04_|BR1_) ? 1'b0 : 1'bz);
// Gate A4-U250B
pullup(RB2);
assign #GATE_DELAY RB2 = rst ? 0 : ((0|T01_|RUPT1_) ? 1'b0 : 1'bz);
// Gate A4-U204B
pullup(READ0);
assign #GATE_DELAY READ0 = rst ? 0 : ((0|SQR10|g36307|QC0_) ? 1'b0 : 1'bz);
// Gate A4-U142B A4-U143B
pullup(g36133);
assign #GATE_DELAY g36133 = rst ? 0 : ((0|g36131|STG2) ? 1'b0 : 1'bz);
// Gate A4-U256A
pullup(RB1_);
assign #GATE_DELAY RB1_ = rst ? 1'bz : ((0|g36451|g36436) ? 1'b0 : 1'bz);
// Gate A4-U210B
pullup(g36333);
assign #GATE_DELAY g36333 = rst ? 1'bz : ((0|ROR0|WOR0) ? 1'b0 : 1'bz);
// Gate A4-U140B A4-U139B
pullup(g36129);
assign #GATE_DELAY g36129 = rst ? 1'bz : ((0|g36139|MTCSAI|g36135|ST2|g36261) ? 1'b0 : 1'bz);
// Gate A4-U248A
pullup(d1XP10);
assign #GATE_DELAY d1XP10 = rst ? 0 : ((0|DV0_|T01_) ? 1'b0 : 1'bz);
// Gate A4-U153B
pullup(DV1376);
assign #GATE_DELAY DV1376 = rst ? 0 : ((0|ST1376_|DIV_) ? 1'b0 : 1'bz);
// Gate A4-U123B
pullup(g36217);
assign #GATE_DELAY g36217 = rst ? 1'bz : ((0|TL15) ? 1'b0 : 1'bz);
// Gate A4-U156B
pullup(g36144);
assign #GATE_DELAY g36144 = rst ? 0 : ((0|STG2|STG1|g36148) ? 1'b0 : 1'bz);
// Gate A4-U124A
pullup(g36213);
assign #GATE_DELAY g36213 = rst ? 1'bz : ((0|SUMA16_|SUMB16_) ? 1'b0 : 1'bz);
// Gate A4-U249B
pullup(d2PP1);
assign #GATE_DELAY d2PP1 = rst ? 1'bz : ((0|INOUT|MP1|MP3A) ? 1'b0 : 1'bz);
// Gate A4-U117B
pullup(g36221);
assign #GATE_DELAY g36221 = rst ? 0 : ((0|WL16_|PHS4_|TSGN_) ? 1'b0 : 1'bz);
// Gate A4-U157B
pullup(g36152);
assign #GATE_DELAY g36152 = rst ? 0 : ((0|STG1|STG3) ? 1'b0 : 1'bz);
// Gate A4-U211A
pullup(ROR0);
assign #GATE_DELAY ROR0 = rst ? 0 : ((0|SQR10|QC2_|g36307) ? 1'b0 : 1'bz);
// Gate A4-U109A A4-U118A A4-U119A
pullup(BR1_);
assign #GATE_DELAY BR1_ = rst ? 1'bz : ((0|g36228) ? 1'b0 : 1'bz);
// Gate A4-U116B A4-U115B
pullup(g36231);
assign #GATE_DELAY g36231 = rst ? 0 : ((0|PHS4|PHS3_|g36213|TSGU_) ? 1'b0 : 1'bz);
// Gate A4-U154A A4-U148A
pullup(STD2);
assign #GATE_DELAY STD2 = rst ? 0 : ((0|g36133|STG3|INKL|STG1) ? 1'b0 : 1'bz);
// Gate A4-U101B
pullup(MBR2);
assign #GATE_DELAY MBR2 = rst ? 0 : ((0|g36241) ? 1'b0 : 1'bz);
// Gate A4-U113B
pullup(MBR1);
assign #GATE_DELAY MBR1 = rst ? 0 : ((0|g36222) ? 1'b0 : 1'bz);
// Gate A4-U240B
pullup(BRDIF_);
assign #GATE_DELAY BRDIF_ = rst ? 1'bz : ((0|BR12B|BR1B2) ? 1'b0 : 1'bz);
// Gate A4-U155B
pullup(ST3_);
assign #GATE_DELAY ST3_ = rst ? 0 : ((0|g36140) ? 1'b0 : 1'bz);
// Gate A4-U228A
pullup(g36340);
assign #GATE_DELAY g36340 = rst ? 0 : ((0|RXOR0_|T09_) ? 1'b0 : 1'bz);
// Gate A4-U246B
pullup(KRPT);
assign #GATE_DELAY KRPT = rst ? 0 : ((0|T09_|RUPT1_) ? 1'b0 : 1'bz);
// Gate A4-U238B
pullup(BR1B2_);
assign #GATE_DELAY BR1B2_ = rst ? 1'bz : ((0|BR1B2) ? 1'b0 : 1'bz);
// Gate A4-U121B A4-U120B
pullup(g36222);
assign #GATE_DELAY g36222 = rst ? 1'bz : ((0|SGUM|g36216|g36228|g36221|g36218) ? 1'b0 : 1'bz);
// Gate A4-U242B
pullup(BR1B2B);
assign #GATE_DELAY BR1B2B = rst ? 1'bz : ((0|BR2|BR1) ? 1'b0 : 1'bz);
// Gate A4-U132B
pullup(DIVSTG);
assign #GATE_DELAY DIVSTG = rst ? 0 : ((0|T12USE_|T03_) ? 1'b0 : 1'bz);
// Gate A4-U225A
pullup(g36326);
assign #GATE_DELAY g36326 = rst ? 1'bz : ((0|QC3_|SQEXT) ? 1'b0 : 1'bz);
// Gate A4-U235A
pullup(R1C_);
assign #GATE_DELAY R1C_ = rst ? 1'bz : ((0|g36451|g36438) ? 1'b0 : 1'bz);
// Gate A4-U225B
pullup(g36329);
assign #GATE_DELAY g36329 = rst ? 1'bz : ((0|g36328) ? 1'b0 : 1'bz);
// Gate A4-U231A
pullup(g36413);
assign #GATE_DELAY g36413 = rst ? 0 : ((0|MP0_|T03_) ? 1'b0 : 1'bz);
// Gate A4-U215A
pullup(RXOR0);
assign #GATE_DELAY RXOR0 = rst ? 0 : ((0|SQR10|QC3_|g36307) ? 1'b0 : 1'bz);
// Gate A4-U234B
pullup(g36436);
assign #GATE_DELAY g36436 = rst ? 0 : ((0|TS0_|BR1B2_|T05_) ? 1'b0 : 1'bz);
// Gate A4-U125B A4-U126B A4-U127B
pullup(DV1_);
assign #GATE_DELAY DV1_ = rst ? 1'bz : ((0|DV1) ? 1'b0 : 1'bz);
// Gate A4-U243B
pullup(BR1B2B_);
assign #GATE_DELAY BR1B2B_ = rst ? 0 : ((0|BR1B2B) ? 1'b0 : 1'bz);
// Gate A4-U234A
pullup(g36414);
assign #GATE_DELAY g36414 = rst ? 0 : ((0|T03_|INOUT_) ? 1'b0 : 1'bz);
// Gate A4-U218A
pullup(RUPT0_);
assign #GATE_DELAY RUPT0_ = rst ? 1'bz : ((0|RUPT0) ? 1'b0 : 1'bz);
// Gate A4-U247B
pullup(g36435);
assign #GATE_DELAY g36435 = rst ? 0 : ((0|MP3_|T04_) ? 1'b0 : 1'bz);
// Gate A4-U242A
pullup(BR12B);
assign #GATE_DELAY BR12B = rst ? 0 : ((0|BR2|BR1_) ? 1'b0 : 1'bz);
// Gate A4-U244B
pullup(g36431);
assign #GATE_DELAY g36431 = rst ? 0 : ((0|DV1_|T04_|BR2_) ? 1'b0 : 1'bz);
// Gate A4-U212B
pullup(RAND0);
assign #GATE_DELAY RAND0 = rst ? 0 : ((0|SQR10|QC1_|g36307) ? 1'b0 : 1'bz);
// Gate A4-U158B
pullup(ST376_);
assign #GATE_DELAY ST376_ = rst ? 0 : ((0|ST376) ? 1'b0 : 1'bz);
// Gate A4-U245B
pullup(g36444);
assign #GATE_DELAY g36444 = rst ? 0 : ((0|BRDIF_|MP0_|T09_) ? 1'b0 : 1'bz);
// Gate A4-U212A
pullup(WAND0);
assign #GATE_DELAY WAND0 = rst ? 0 : ((0|QC1_|g36307|SQR10_) ? 1'b0 : 1'bz);
// Gate A4-U116A A4-U124B
pullup(SGUM);
assign #GATE_DELAY SGUM = rst ? 0 : ((0|PHS4|PHS3_|SUMA16_|SUMB16_|TSGU_) ? 1'b0 : 1'bz);
// Gate A4-U137A
pullup(g36115);
assign #GATE_DELAY g36115 = rst ? 0 : ((0|g36114|STG1) ? 1'b0 : 1'bz);
// Gate A4-U222B A4-U220A
pullup(RUPT1);
assign #GATE_DELAY RUPT1 = rst ? 0 : ((0|SQR10_|SQ0_|QC3_|EXST1_) ? 1'b0 : 1'bz);
// Gate A4-U111B
pullup(g36239);
assign #GATE_DELAY g36239 = rst ? 1'bz : ((0|TSGN2) ? 1'b0 : 1'bz);
// Gate A4-U219B
pullup(g36353);
assign #GATE_DELAY g36353 = rst ? 0 : ((0|T05_|WOR0_) ? 1'b0 : 1'bz);
// Gate A4-U228B A4-U226A
pullup(PRINC);
assign #GATE_DELAY PRINC = rst ? 0 : ((0|g36329|g36326) ? 1'b0 : 1'bz);
// Gate A4-U107A A4-U108A
pullup(g36241);
assign #GATE_DELAY g36241 = rst ? 1'bz : ((0|g36236|g36233|g36249|g36240|g36243) ? 1'b0 : 1'bz);
// Gate A4-U138B A4-U101A
pullup(g36261);
assign #GATE_DELAY g36261 = rst ? 0 : ((0|XB7_|TRSM_|XT1_|NDR100_) ? 1'b0 : 1'bz);
// Gate A4-U203A
pullup(INOUT);
assign #GATE_DELAY INOUT = rst ? 0 : ((0|EXST0_|SQ0_|RUPT0) ? 1'b0 : 1'bz);
// Gate A4-U252A
pullup(RSC_);
assign #GATE_DELAY RSC_ = rst ? 1'bz : ((0|g36407|g36435|g36456) ? 1'b0 : 1'bz);
// Gate A4-U226B
pullup(g36343);
assign #GATE_DELAY g36343 = rst ? 0 : ((0|g36342|T09_) ? 1'b0 : 1'bz);
// Gate A4-U227B
pullup(g36360);
assign #GATE_DELAY g36360 = rst ? 0 : ((0|T09_|STORE1_) ? 1'b0 : 1'bz);
// Gate A4-U211B
pullup(WOR0_);
assign #GATE_DELAY WOR0_ = rst ? 1'bz : ((0|WOR0) ? 1'b0 : 1'bz);
// Gate A4-U257A A4-U257B
pullup(TSGN_);
assign #GATE_DELAY TSGN_ = rst ? 1'bz : ((0|g36456|g36431|g36413|MP0T10|d1XP10) ? 1'b0 : 1'bz);
// Gate A4-U214A
pullup(RXOR0_);
assign #GATE_DELAY RXOR0_ = rst ? 1'bz : ((0|RXOR0) ? 1'b0 : 1'bz);
// Gate A4-U135A
pullup(MST1);
assign #GATE_DELAY MST1 = rst ? 1'bz : ((0|g36115) ? 1'b0 : 1'bz);
// Gate A4-U139A
pullup(MST2);
assign #GATE_DELAY MST2 = rst ? 1'bz : ((0|g36133) ? 1'b0 : 1'bz);
// Gate A4-U148B
pullup(MST3);
assign #GATE_DELAY MST3 = rst ? 0 : ((0|g36148) ? 1'b0 : 1'bz);
// Gate A4-U213B
pullup(g36337);
assign #GATE_DELAY g36337 = rst ? 1'bz : ((0|RAND0|WAND0) ? 1'b0 : 1'bz);
// Gate A4-U130A
pullup(DV376);
assign #GATE_DELAY DV376 = rst ? 0 : ((0|ST376_|DIV_) ? 1'b0 : 1'bz);
// Gate A4-U206A
pullup(WRITE0_);
assign #GATE_DELAY WRITE0_ = rst ? 1'bz : ((0|WRITE0) ? 1'b0 : 1'bz);
// Gate A4-U213A
pullup(g36334);
assign #GATE_DELAY g36334 = rst ? 0 : ((0|T03_|g36333) ? 1'b0 : 1'bz);
// Gate A4-U206B
pullup(WRITE0);
assign #GATE_DELAY WRITE0 = rst ? 0 : ((0|QC0_|SQR10_|g36307) ? 1'b0 : 1'bz);
// Gate A4-U150B A4-U151B
pullup(ST0_);
assign #GATE_DELAY ST0_ = rst ? 1'bz : ((0|g36105) ? 1'b0 : 1'bz);
// Gate A4-U245A
pullup(g36446);
assign #GATE_DELAY g36446 = rst ? 0 : ((0|MP3_|T09_) ? 1'b0 : 1'bz);
// Gate A4-U236A
pullup(TSGN2);
assign #GATE_DELAY TSGN2 = rst ? 0 : ((0|MP0_|T07_) ? 1'b0 : 1'bz);
// Gate A4-U205A
pullup(INOUT_);
assign #GATE_DELAY INOUT_ = rst ? 1'bz : ((0|INOUT) ? 1'b0 : 1'bz);
// Gate A4-U221B
pullup(g36348);
assign #GATE_DELAY g36348 = rst ? 0 : ((0|T05_|READ0_) ? 1'b0 : 1'bz);
// Gate A4-U251A
pullup(g36401);
assign #GATE_DELAY g36401 = rst ? 1'bz : ((0|RUPT0|RSM3|RUPT1) ? 1'b0 : 1'bz);
// Gate A4-U143A
pullup(g36139);
assign #GATE_DELAY g36139 = rst ? 0 : ((0|DVST_|g36115) ? 1'b0 : 1'bz);
// Gate A4-U229A A4-U230A A4-U253A
pullup(WG_);
assign #GATE_DELAY WG_ = rst ? 1'bz : ((0|g36354|g36340|d9XP1|g36343|g36351|g36435|g36407|g36360) ? 1'b0 : 1'bz);
// Gate A4-U207B
pullup(d8PP4);
assign #GATE_DELAY d8PP4 = rst ? 1'bz : ((0|DV4|INOUT|PRINC) ? 1'b0 : 1'bz);
// Gate A4-U149A
pullup(ST1D);
assign #GATE_DELAY ST1D = rst ? 0 : ((0|STG3|STG2|g36115) ? 1'b0 : 1'bz);
// Gate A4-U140A
pullup(g36135);
assign #GATE_DELAY g36135 = rst ? 0 : ((0|GOJAM|g36129|T01) ? 1'b0 : 1'bz);
// Gate A4-U146A
pullup(g36147);
assign #GATE_DELAY g36147 = rst ? 0 : ((0|g36146|g36111) ? 1'b0 : 1'bz);
// Gate A4-U145A
pullup(g36146);
assign #GATE_DELAY g36146 = rst ? 1'bz : ((0|g36159|g36155) ? 1'b0 : 1'bz);
// Gate A4-U125A
pullup(DV1);
assign #GATE_DELAY DV1 = rst ? 0 : ((0|ST1_|DIV_) ? 1'b0 : 1'bz);
// Gate A4-U232A
pullup(d3XP2);
assign #GATE_DELAY d3XP2 = rst ? 0 : ((0|TS0_|T03_) ? 1'b0 : 1'bz);
// Gate A4-U146B
pullup(g36150);
assign #GATE_DELAY g36150 = rst ? 0 : ((0|g36159|g36111) ? 1'b0 : 1'bz);
// Gate A4-U238A
pullup(BR12B_);
assign #GATE_DELAY BR12B_ = rst ? 1'bz : ((0|BR12B) ? 1'b0 : 1'bz);
// Gate A4-U121A A4-U120A
pullup(g36228);
assign #GATE_DELAY g36228 = rst ? 0 : ((0|g36224|g36227|g36222|g36231|g36230) ? 1'b0 : 1'bz);
// Gate A4-U106B A4-U105B
pullup(BR2_);
assign #GATE_DELAY BR2_ = rst ? 1'bz : ((0|g36249) ? 1'b0 : 1'bz);
// Gate A4-U231B
pullup(d5XP4);
assign #GATE_DELAY d5XP4 = rst ? 0 : ((0|RSM3_|T05_) ? 1'b0 : 1'bz);
// Gate A4-U150A A4-U152A A4-U151A
pullup(ST1_);
assign #GATE_DELAY ST1_ = rst ? 1'bz : ((0|ST1D) ? 1'b0 : 1'bz);
// Gate A4-U154B
pullup(DV1376_);
assign #GATE_DELAY DV1376_ = rst ? 1'bz : ((0|DV1376) ? 1'b0 : 1'bz);
// Gate A4-U221A
pullup(RUPT1_);
assign #GATE_DELAY RUPT1_ = rst ? 1'bz : ((0|RUPT1) ? 1'b0 : 1'bz);
// Gate A4-U254B
pullup(TMZ_);
assign #GATE_DELAY TMZ_ = rst ? 1'bz : ((0|d2XP5|d1XP10) ? 1'b0 : 1'bz);
// Gate A4-U223B
pullup(g36351);
assign #GATE_DELAY g36351 = rst ? 0 : ((0|WRITE0_|T02_) ? 1'b0 : 1'bz);
// Gate A4-U152B
pullup(MP3A);
assign #GATE_DELAY MP3A = rst ? 0 : ((0|MP3_) ? 1'b0 : 1'bz);
// Gate A4-U235B A4-U258A
pullup(WY_);
assign #GATE_DELAY WY_ = rst ? 1'bz : ((0|B15X|d7XP19|g36414|g36439|g36437|d8XP5) ? 1'b0 : 1'bz);
// Gate A4-U223A
pullup(g36328);
assign #GATE_DELAY g36328 = rst ? 0 : ((0|ST0_|SQ2_|SQR12_) ? 1'b0 : 1'bz);
// Gate A4-U107B A4-U108B
pullup(g36249);
assign #GATE_DELAY g36249 = rst ? 0 : ((0|g36241|g36244|g36230|g36252) ? 1'b0 : 1'bz);
// Gate A4-U106A
pullup(BR2);
assign #GATE_DELAY BR2 = rst ? 0 : ((0|g36241) ? 1'b0 : 1'bz);
// Gate A4-U118B A4-U119B A4-U160B
pullup(BR1);
assign #GATE_DELAY BR1 = rst ? 0 : ((0|g36222) ? 1'b0 : 1'bz);
// Gate A4-U232B
pullup(d4XP5);
assign #GATE_DELAY d4XP5 = rst ? 0 : ((0|T04_|TS0_) ? 1'b0 : 1'bz);
// Gate A4-U123A
pullup(g36216);
assign #GATE_DELAY g36216 = rst ? 0 : ((0|TOV_|UNF_) ? 1'b0 : 1'bz);
// Gate A4-U122B
pullup(g36227);
assign #GATE_DELAY g36227 = rst ? 0 : ((0|PHS3_|g36217) ? 1'b0 : 1'bz);
// Gate A4-U215B
pullup(d5XP28);
assign #GATE_DELAY d5XP28 = rst ? 0 : ((0|T05_|DV4_) ? 1'b0 : 1'bz);
// Gate A4-U214B
pullup(g36338);
assign #GATE_DELAY g36338 = rst ? 0 : ((0|g36337|T03_) ? 1'b0 : 1'bz);
// Gate A4-U129B
pullup(g36201);
assign #GATE_DELAY g36201 = rst ? 0 : ((0|QC0_|SQ1_|SQEXT_) ? 1'b0 : 1'bz);
// Gate A4-U217A
pullup(RUPT0);
assign #GATE_DELAY RUPT0 = rst ? 0 : ((0|QC3_|SQR10_|g36307) ? 1'b0 : 1'bz);
// Gate A4-U103A
pullup(g36233);
assign #GATE_DELAY g36233 = rst ? 0 : ((0|GEQZRO_|TPZG_|PHS4_) ? 1'b0 : 1'bz);
// Gate A4-U249A
pullup(g36406);
assign #GATE_DELAY g36406 = rst ? 0 : ((0|d2PP1) ? 1'b0 : 1'bz);
// Gate A4-U103B
pullup(g36236);
assign #GATE_DELAY g36236 = rst ? 0 : ((0|TOV_|OVF_) ? 1'b0 : 1'bz);
// Gate A4-U218B
pullup(g36349);
assign #GATE_DELAY g36349 = rst ? 0 : ((0|T05_|WRITE0_) ? 1'b0 : 1'bz);
// Gate A4-U210A
pullup(WOR0);
assign #GATE_DELAY WOR0 = rst ? 0 : ((0|SQR10_|g36307|QC2_) ? 1'b0 : 1'bz);
// Gate A4-U233A
pullup(d4XP11);
assign #GATE_DELAY d4XP11 = rst ? 0 : ((0|T04_|INOUT_) ? 1'b0 : 1'bz);
// Gate A4-U241B
pullup(d8XP6);
assign #GATE_DELAY d8XP6 = rst ? 0 : ((0|T08_|DV1_|BR2) ? 1'b0 : 1'bz);
// Gate A4-U102B
pullup(TRSM_);
assign #GATE_DELAY TRSM_ = rst ? 1'bz : ((0|TRSM) ? 1'b0 : 1'bz);
// Gate A4-U255B
pullup(g36424);
assign #GATE_DELAY g36424 = rst ? 0 : ((0|T04_|BRDIF_|TS0_) ? 1'b0 : 1'bz);
// Gate A4-U147A
pullup(g36148);
assign #GATE_DELAY g36148 = rst ? 1'bz : ((0|g36147|STG3) ? 1'b0 : 1'bz);
// Gate A4-U128A A4-U128B
pullup(DIV_);
assign #GATE_DELAY DIV_ = rst ? 1'bz : ((0|g36201) ? 1'b0 : 1'bz);
// Gate A4-U102A
pullup(DVST_);
assign #GATE_DELAY DVST_ = rst ? 1'bz : ((0|DVST) ? 1'b0 : 1'bz);
// Gate A4-U237A
pullup(g36456);
assign #GATE_DELAY g36456 = rst ? 0 : ((0|T07_|DV1_) ? 1'b0 : 1'bz);
// Gate A4-U229B A4-U259A
pullup(RA_);
assign #GATE_DELAY RA_ = rst ? 1'bz : ((0|d2XP3|g36349|g36354|d8XP5|g36446|d1XP10) ? 1'b0 : 1'bz);
// Gate A4-U227A
pullup(d9XP1);
assign #GATE_DELAY d9XP1 = rst ? 0 : ((0|RUPT0_|T09_) ? 1'b0 : 1'bz);
// Gate A4-U132A
pullup(g36103);
assign #GATE_DELAY g36103 = rst ? 0 : ((0|T12USE_|T03_|PHS3_) ? 1'b0 : 1'bz);
// Gate A4-U131B
pullup(T12USE_);
assign #GATE_DELAY T12USE_ = rst ? 1'bz : ((0|DVST|g36109) ? 1'b0 : 1'bz);
// Gate A4-U204A
pullup(READ0_);
assign #GATE_DELAY READ0_ = rst ? 1'bz : ((0|READ0) ? 1'b0 : 1'bz);
// Gate A4-U201B
pullup(g36303);
assign #GATE_DELAY g36303 = rst ? 0 : ((0|EXST0_|SQ0_) ? 1'b0 : 1'bz);
// Gate A4-U209B A4-U216B
pullup(d5XP11);
assign #GATE_DELAY d5XP11 = rst ? 0 : ((0|T05_|INOUT_|READ0|WRITE0|RXOR0) ? 1'b0 : 1'bz);
// Gate A4-U236B
pullup(B15X);
assign #GATE_DELAY B15X = rst ? 0 : ((0|DV1_|T05_) ? 1'b0 : 1'bz);
// Gate A4-U156A
pullup(ST376);
assign #GATE_DELAY ST376 = rst ? 1'bz : ((0|g36133|g36152) ? 1'b0 : 1'bz);
// Gate A4-U138A
pullup(STG1);
assign #GATE_DELAY STG1 = rst ? 1'bz : ((0|g36115|g36119) ? 1'b0 : 1'bz);
// Gate A4-U142A
pullup(STG2);
assign #GATE_DELAY STG2 = rst ? 1'bz : ((0|g36136|g36133) ? 1'b0 : 1'bz);
// Gate A4-U159B A4-U147B
pullup(STG3);
assign #GATE_DELAY STG3 = rst ? 0 : ((0|g36150|g36148) ? 1'b0 : 1'bz);
// Gate A4-U129A
pullup(DV4);
assign #GATE_DELAY DV4 = rst ? 0 : ((0|ST4_|DIV_) ? 1'b0 : 1'bz);
// Gate A4-U117A
pullup(g36224);
assign #GATE_DELAY g36224 = rst ? 0 : ((0|TSGN_|PHS3_) ? 1'b0 : 1'bz);
// Gate A4-U122A
pullup(g36218);
assign #GATE_DELAY g36218 = rst ? 0 : ((0|L15_|g36217) ? 1'b0 : 1'bz);
// Gate A4-U127A
pullup(DV0);
assign #GATE_DELAY DV0 = rst ? 0 : ((0|ST0_|DIV_) ? 1'b0 : 1'bz);
// Gate A4-U259B
pullup(L16_);
assign #GATE_DELAY L16_ = rst ? 0 : ((0|g36451) ? 1'b0 : 1'bz);
// Gate A4-U157A
pullup(ST4_);
assign #GATE_DELAY ST4_ = rst ? 1'bz : ((0|g36144) ? 1'b0 : 1'bz);
// Gate A4-U230B A4-U258B
pullup(RC_);
assign #GATE_DELAY RC_ = rst ? 1'bz : ((0|g36354|g36340|g36338|d2XP5|g36427|g36439) ? 1'b0 : 1'bz);
// Gate A4-U241A
pullup(g36437);
assign #GATE_DELAY g36437 = rst ? 0 : ((0|MP0_|BR1|T09_) ? 1'b0 : 1'bz);
// Gate A4-U248B
pullup(d6XP5);
assign #GATE_DELAY d6XP5 = rst ? 0 : ((0|T06_|DV1_) ? 1'b0 : 1'bz);
// Gate A4-U159A
pullup(DV3764);
assign #GATE_DELAY DV3764 = rst ? 0 : ((0|g36156|DIV_) ? 1'b0 : 1'bz);
// Gate A4-U203B A4-U202B
pullup(DV4_);
assign #GATE_DELAY DV4_ = rst ? 1'bz : ((0|DV4) ? 1'b0 : 1'bz);
// Gate A4-U244A
pullup(TL15);
assign #GATE_DELAY TL15 = rst ? 0 : ((0|T06_|MP3_) ? 1'b0 : 1'bz);
// Gate A4-U224A
pullup(g36342);
assign #GATE_DELAY g36342 = rst ? 1'bz : ((0|RUPT1|IC12|IC13) ? 1'b0 : 1'bz);
// Gate A4-U250A
pullup(g36407);
assign #GATE_DELAY g36407 = rst ? 0 : ((0|g36406|T02_) ? 1'b0 : 1'bz);
// Gate A4-U243A
pullup(BR1B2);
assign #GATE_DELAY BR1B2 = rst ? 0 : ((0|BR1|BR2_) ? 1'b0 : 1'bz);
// Gate A4-U260A
pullup(d8XP5);
assign #GATE_DELAY d8XP5 = rst ? 0 : ((0|T08_|DV1_) ? 1'b0 : 1'bz);
// Gate A4-U209A
pullup(d3XP7);
assign #GATE_DELAY d3XP7 = rst ? 0 : ((0|RXOR0_|T03_) ? 1'b0 : 1'bz);
// Gate A4-U256B
pullup(CI_);
assign #GATE_DELAY CI_ = rst ? 1'bz : ((0|g36444|g36424) ? 1'b0 : 1'bz);
// Gate A4-U126A
pullup(DV0_);
assign #GATE_DELAY DV0_ = rst ? 1'bz : ((0|DV0) ? 1'b0 : 1'bz);
// Gate A4-U253B
pullup(MRSC);
assign #GATE_DELAY MRSC = rst ? 0 : ((0|RSC_) ? 1'b0 : 1'bz);
// Gate A4-U110A
pullup(g36244);
assign #GATE_DELAY g36244 = rst ? 0 : ((0|g36239|PHS3_) ? 1'b0 : 1'bz);
// Gate A4-U207A
pullup(RRPA);
assign #GATE_DELAY RRPA = rst ? 0 : ((0|T03_|RUPT1_) ? 1'b0 : 1'bz);
// Gate A4-U145B
pullup(g36155);
assign #GATE_DELAY g36155 = rst ? 0 : ((0|DVST_|g36133) ? 1'b0 : 1'bz);
// Gate A4-U255A
pullup(MP0T10);
assign #GATE_DELAY MP0T10 = rst ? 0 : ((0|MP0_|T10_) ? 1'b0 : 1'bz);
// Gate A4-U247A
pullup(d2XP5);
assign #GATE_DELAY d2XP5 = rst ? 0 : ((0|BR1|DV0_|T02_) ? 1'b0 : 1'bz);
// Gate A4-U224B
pullup(d2XP3);
assign #GATE_DELAY d2XP3 = rst ? 0 : ((0|T02_|INOUT_) ? 1'b0 : 1'bz);
// Gate A4-U133A
pullup(g36110);
assign #GATE_DELAY g36110 = rst ? 0 : ((0|T12_|g36109|PHS3_) ? 1'b0 : 1'bz);
// Gate A4-U153A
pullup(ST1376_);
assign #GATE_DELAY ST1376_ = rst ? 0 : ((0|ST1D|ST376) ? 1'b0 : 1'bz);
// Gate A4-U149B
pullup(g36105);
assign #GATE_DELAY g36105 = rst ? 0 : ((0|STG3|STG1|STG2) ? 1'b0 : 1'bz);
// Gate A4-U133B A4-U134A
pullup(g36111);
assign #GATE_DELAY g36111 = rst ? 1'bz : ((0|g36103|g36110) ? 1'b0 : 1'bz);
// Gate A4-U131A
pullup(g36109);
assign #GATE_DELAY g36109 = rst ? 0 : ((0|GOJAM|T12USE_|RSTSTG) ? 1'b0 : 1'bz);
// Gate A4-U222A A4-U239A
pullup(RB_);
assign #GATE_DELAY RB_ = rst ? 1'bz : ((0|g36348|g36334|g36343|g36437|d7XP19|g36425) ? 1'b0 : 1'bz);
// Gate A4-U260B
pullup(g36451);
assign #GATE_DELAY g36451 = rst ? 0 : ((0|BR1_|T11_|MP0_) ? 1'b0 : 1'bz);
// Gate A4-U233B
pullup(g36438);
assign #GATE_DELAY g36438 = rst ? 0 : ((0|T05_|BR12B_|TS0_) ? 1'b0 : 1'bz);
// Gate A4-U144B A4-U104B
pullup(g36159);
assign #GATE_DELAY g36159 = rst ? 0 : ((0|T01|STRTFC|g36146|RSTSTG) ? 1'b0 : 1'bz);
// Gate A4-U237B
pullup(d7XP19);
assign #GATE_DELAY d7XP19 = rst ? 0 : ((0|BR1_|MP3_|T07_) ? 1'b0 : 1'bz);
// Gate A4-U251B
pullup(R15);
assign #GATE_DELAY R15 = rst ? 0 : ((0|T01_|g36401) ? 1'b0 : 1'bz);
// Gate A4-U137B
pullup(g36119);
assign #GATE_DELAY g36119 = rst ? 0 : ((0|g36118|g36111) ? 1'b0 : 1'bz);
// Gate A4-U155A
pullup(g36140);
assign #GATE_DELAY g36140 = rst ? 1'bz : ((0|g36133|STG3|g36115) ? 1'b0 : 1'bz);
// Gate A4-U158A
pullup(g36156);
assign #GATE_DELAY g36156 = rst ? 0 : ((0|ST376|g36144) ? 1'b0 : 1'bz);
// Gate A4-U201A A4-U202A
pullup(g36307);
assign #GATE_DELAY g36307 = rst ? 1'bz : ((0|g36303) ? 1'b0 : 1'bz);
// Gate A4-U141B
pullup(g36131);
assign #GATE_DELAY g36131 = rst ? 0 : ((0|g36111|g36129) ? 1'b0 : 1'bz);
// Gate A4-U109B
pullup(g36252);
assign #GATE_DELAY g36252 = rst ? 0 : ((0|TMZ_|PHS3_) ? 1'b0 : 1'bz);
// Gate A4-U115A
pullup(g36230);
assign #GATE_DELAY g36230 = rst ? 0 : ((0|TOV_|PHS2_) ? 1'b0 : 1'bz);
// Gate A4-U141A
pullup(g36136);
assign #GATE_DELAY g36136 = rst ? 0 : ((0|g36135|g36111) ? 1'b0 : 1'bz);
// Gate A4-U130B
pullup(DV376_);
assign #GATE_DELAY DV376_ = rst ? 1'bz : ((0|DV376) ? 1'b0 : 1'bz);
// Gate A4-U114A A4-U114B A4-U112A A4-U112B A4-U113A A4-U111A
pullup(g36243);
assign #GATE_DELAY g36243 = rst ? 0 : ((0|PHS4_|TMZ_|WL01_|WL03_|WL04_|WL02_|WL09_|WL08_|WL10_|WL11_|WL12_|WL13_|WL05_|WL06_|WL07_|WL14_|WL15_|WL16_) ? 1'b0 : 1'bz);
// Gate A4-U110B
pullup(g36240);
assign #GATE_DELAY g36240 = rst ? 0 : ((0|PHS4_|WL16_|g36239) ? 1'b0 : 1'bz);
// Gate A4-U246A
pullup(g36439);
assign #GATE_DELAY g36439 = rst ? 0 : ((0|MP0_|T09_|BR1_) ? 1'b0 : 1'bz);
// Gate A4-U217B
pullup(WCH_);
assign #GATE_DELAY WCH_ = rst ? 1'bz : ((0|g36353|g36349|d7XP14) ? 1'b0 : 1'bz);
// End of NOR gates


endmodule
