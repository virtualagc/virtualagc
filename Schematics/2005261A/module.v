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

parameter GATE_DELAY = 0.2; // This default may be overridden at compile time.
initial $display("Gate delay (A5) will be %f ns.", GATE_DELAY*100);

// Gate A5-U115B
pullup(ST2_);
assign #GATE_DELAY ST2_ = rst ? 1'bz : ((0|g39227|g39221) ? 1'b0 : 1'bz);
// Gate A5-U241A
pullup(g39320);
assign #GATE_DELAY g39320 = rst ? 0 : ((0|g39318|T04_) ? 1'b0 : 1'bz);
// Gate A5-U121B
pullup(g39237);
assign #GATE_DELAY g39237 = rst ? 0 : ((0|BR12B_|DAS0_) ? 1'b0 : 1'bz);
// Gate A5-U227B
pullup(g39405);
assign #GATE_DELAY g39405 = rst ? 1'bz : ((0|DV1B1B|ROR0|WOR0) ? 1'b0 : 1'bz);
// Gate A5-U257B
pullup(OCTAD3);
assign #GATE_DELAY OCTAD3 = rst ? 0 : ((0|XT3_|NDR100_) ? 1'b0 : 1'bz);
// Gate A5-U158B
pullup(g39145);
assign #GATE_DELAY g39145 = rst ? 0 : ((0|T07_|DAS0_) ? 1'b0 : 1'bz);
// Gate A5-U255A
pullup(OCTAD5);
assign #GATE_DELAY OCTAD5 = rst ? 0 : ((0|XT5_|NDR100_) ? 1'b0 : 1'bz);
// Gate A5-U226A
pullup(g39401);
assign #GATE_DELAY g39401 = rst ? 0 : ((0|DV1_|BR1_) ? 1'b0 : 1'bz);
// Gate A5-U152B
pullup(g39138);
assign #GATE_DELAY g39138 = rst ? 0 : ((0|RSM3_|T06_) ? 1'b0 : 1'bz);
// Gate A5-U131B
pullup(g39108);
assign #GATE_DELAY g39108 = rst ? 1'bz : ((0|TC0|TCF0|IC4) ? 1'b0 : 1'bz);
// Gate A5-U131A
pullup(g39109);
assign #GATE_DELAY g39109 = rst ? 0 : ((0|g39108|T01_) ? 1'b0 : 1'bz);
// Gate A5-U210A
pullup(Z15_);
assign #GATE_DELAY Z15_ = rst ? 0 : ((0|g39432) ? 1'b0 : 1'bz);
// Gate A5-U108B
pullup(RAD);
assign #GATE_DELAY RAD = rst ? 0 : ((0|TSUDO_|T08_) ? 1'b0 : 1'bz);
// Gate A5-U239B
pullup(RQ);
assign #GATE_DELAY RQ = rst ? 0 : ((0|QXCH0_|T03_) ? 1'b0 : 1'bz);
// Gate A5-U209A
pullup(g39428);
assign #GATE_DELAY g39428 = rst ? 0 : ((0|T07_|g39427) ? 1'b0 : 1'bz);
// Gate A5-U123A
pullup(g39243);
assign #GATE_DELAY g39243 = rst ? 0 : ((0|g39245|T11_) ? 1'b0 : 1'bz);
// Gate A5-U144B
pullup(g39127);
assign #GATE_DELAY g39127 = rst ? 0 : ((0|T04_|DAS0_) ? 1'b0 : 1'bz);
// Gate A5-U212A A5-U212B
pullup(WL_);
assign #GATE_DELAY WL_ = rst ? 1'bz : ((0|g39436|g39449|g39452|A55XP13) ? 1'b0 : 1'bz);
// Gate A5-U133A
pullup(g39102);
assign #GATE_DELAY g39102 = rst ? 0 : ((0|T01_|g39101) ? 1'b0 : 1'bz);
// Gate A5-U134B
pullup(g39101);
assign #GATE_DELAY g39101 = rst ? 1'bz : ((0|IC2|IC10|IC3) ? 1'b0 : 1'bz);
// Gate A5-U140A
pullup(g39124);
assign #GATE_DELAY g39124 = rst ? 0 : ((0|IC2_|T04_) ? 1'b0 : 1'bz);
// Gate A5-U133B
pullup(g39105);
assign #GATE_DELAY g39105 = rst ? 1'bz : ((0|STD2|IC2) ? 1'b0 : 1'bz);
// Gate A5-U120B A5-U141A A5-U238A
pullup(RA_);
assign #GATE_DELAY RA_ = rst ? 1'bz : ((0|g39233|g39225|g39124|g29121|A56XP2|g39312) ? 1'b0 : 1'bz);
// Gate A5-U258A A5-U257A
pullup(NDR100_);
assign #GATE_DELAY NDR100_ = rst ? 1'bz : ((0|g39348|g39349) ? 1'b0 : 1'bz);
// Gate A5-U259A
pullup(g39348);
assign #GATE_DELAY g39348 = rst ? 0 : ((0|YB0_|YT0_) ? 1'b0 : 1'bz);
// Gate A5-U110B A5-U218A
pullup(WZ_);
assign #GATE_DELAY WZ_ = rst ? 1'bz : ((0|g39201|g39120|g39221|g39416) ? 1'b0 : 1'bz);
// Gate A5-U233B
pullup(R6);
assign #GATE_DELAY R6 = rst ? 0 : ((0|FETCH0_|T01_) ? 1'b0 : 1'bz);
// Gate A5-U148B
pullup(PARTC);
assign #GATE_DELAY PARTC = rst ? 0 : ((0|SHIFT|MONpCH|INKL_) ? 1'b0 : 1'bz);
// Gate A5-U114A
pullup(g39227);
assign #GATE_DELAY g39227 = rst ? 0 : ((0|CCS0_|T10_) ? 1'b0 : 1'bz);
// Gate A5-U121A
pullup(g39225);
assign #GATE_DELAY g39225 = rst ? 0 : ((0|MASK0_|T09_) ? 1'b0 : 1'bz);
// Gate A5-U124A
pullup(g39241);
assign #GATE_DELAY g39241 = rst ? 0 : ((0|MASK0_|T11_) ? 1'b0 : 1'bz);
// Gate A5-U218B A5-U219B
pullup(g39415);
assign #GATE_DELAY g39415 = rst ? 1'bz : ((0|IC2|TS0|IC3|IC16|MP3) ? 1'b0 : 1'bz);
// Gate A5-U256B
pullup(OCTAD4);
assign #GATE_DELAY OCTAD4 = rst ? 0 : ((0|XT4_|NDR100_) ? 1'b0 : 1'bz);
// Gate A5-U223B
pullup(g39411);
assign #GATE_DELAY g39411 = rst ? 0 : ((0|g39403|T05_) ? 1'b0 : 1'bz);
// Gate A5-U118B
pullup(g39233);
assign #GATE_DELAY g39233 = rst ? 0 : ((0|g39232|T10_) ? 1'b0 : 1'bz);
// Gate A5-U138A
pullup(g39116);
assign #GATE_DELAY g39116 = rst ? 0 : ((0|T10_|MP3_) ? 1'b0 : 1'bz);
// Gate A5-U227A
pullup(g39404);
assign #GATE_DELAY g39404 = rst ? 1'bz : ((0|RAND0|WAND0|g39401) ? 1'b0 : 1'bz);
// Gate A5-U228A
pullup(DV1B1B);
assign #GATE_DELAY DV1B1B = rst ? 0 : ((0|DV1_|BR1) ? 1'b0 : 1'bz);
// Gate A5-U203A
pullup(g39451);
assign #GATE_DELAY g39451 = rst ? 0 : ((0|RXOR0_|T11_) ? 1'b0 : 1'bz);
// Gate A5-U111A
pullup(g39201);
assign #GATE_DELAY g39201 = rst ? 0 : ((0|CCS0_|T08_) ? 1'b0 : 1'bz);
// Gate A5-U106A
pullup(P03);
assign #GATE_DELAY P03 = rst ? 1'bz : ((0|EDSET) ? 1'b0 : 1'bz);
// Gate A5-U123B
pullup(d11XP2);
assign #GATE_DELAY d11XP2 = rst ? 0 : ((0|T11_|MSU0_) ? 1'b0 : 1'bz);
// Gate A5-U129A A5-U129B A5-U126A A5-U128B
pullup(g39251);
assign #GATE_DELAY g39251 = rst ? 1'bz : ((0|C37P|C40P|C41P|C44P|C43P|C42P|C26A|C25A|C24A|C27A|C30A) ? 1'b0 : 1'bz);
// Gate A5-U124B
pullup(g39254);
assign #GATE_DELAY g39254 = rst ? 0 : ((0|g39251|INCSET_) ? 1'b0 : 1'bz);
// Gate A5-U254A
pullup(Z16_);
assign #GATE_DELAY Z16_ = rst ? 0 : ((0|g39411) ? 1'b0 : 1'bz);
// Gate A5-U246B
pullup(A55XP9);
assign #GATE_DELAY A55XP9 = rst ? 0 : ((0|SHIFT_|T05_) ? 1'b0 : 1'bz);
// Gate A5-U215B
pullup(g39439);
assign #GATE_DELAY g39439 = rst ? 0 : ((0|T09_|DAS1_) ? 1'b0 : 1'bz);
// Gate A5-U233A
pullup(g39307);
assign #GATE_DELAY g39307 = rst ? 0 : ((0|CHINC_|T01_) ? 1'b0 : 1'bz);
// Gate A5-U258B
pullup(SCAD_);
assign #GATE_DELAY SCAD_ = rst ? 1'bz : ((0|SCAD) ? 1'b0 : 1'bz);
// Gate A5-U253A
pullup(TRSM);
assign #GATE_DELAY TRSM = rst ? 0 : ((0|NDX0_|T05_) ? 1'b0 : 1'bz);
// Gate A5-U107A
pullup(g39209);
assign #GATE_DELAY g39209 = rst ? 1'bz : ((0|IC16) ? 1'b0 : 1'bz);
// Gate A5-U204B
pullup(g39447);
assign #GATE_DELAY g39447 = rst ? 0 : ((0|BR2|ADS0|DAS1_) ? 1'b0 : 1'bz);
// Gate A5-U232A
pullup(RL10BB);
assign #GATE_DELAY RL10BB = rst ? 0 : ((0|T01_|g39301) ? 1'b0 : 1'bz);
// Gate A5-U231B A5-U237A A5-U232B
pullup(g39301);
assign #GATE_DELAY g39301 = rst ? 1'bz : ((0|DXCH0|IC9|PRINC|INOUT|DAS1|DAS0|IC12) ? 1'b0 : 1'bz);
// Gate A5-U244A
pullup(A55XP13);
assign #GATE_DELAY A55XP13 = rst ? 0 : ((0|T05_|IC8_) ? 1'b0 : 1'bz);
// Gate A5-U149B A5-U245A A5-U245B A5-U211B
pullup(RG_);
assign #GATE_DELAY RG_ = rst ? 1'bz : ((0|g39149|g39140|g39134|d5XP15|g39344|A55XP13|g39324|g39327|A55XP9|g39428|g39425|g39451) ? 1'b0 : 1'bz);
// Gate A5-U158A
pullup(g39149);
assign #GATE_DELAY g39149 = rst ? 0 : ((0|IC2_|T07_) ? 1'b0 : 1'bz);
// Gate A5-U234B
pullup(RSCT);
assign #GATE_DELAY RSCT = rst ? 0 : ((0|T01_|INKL_|MONpCH) ? 1'b0 : 1'bz);
// Gate A5-U209B
pullup(RSTSTG);
assign #GATE_DELAY RSTSTG = rst ? 0 : ((0|T08_|DV4_) ? 1'b0 : 1'bz);
// Gate A5-U228B
pullup(DV4B1B);
assign #GATE_DELAY DV4B1B = rst ? 0 : ((0|DV4_|BR1) ? 1'b0 : 1'bz);
// Gate A5-U252A
pullup(g39342);
assign #GATE_DELAY g39342 = rst ? 1'bz : ((0|MP3) ? 1'b0 : 1'bz);
// Gate A5-U127B
pullup(PINC_);
assign #GATE_DELAY PINC_ = rst ? 1'bz : ((0|g39254|PINC) ? 1'b0 : 1'bz);
// Gate A5-U215A
pullup(g39432);
assign #GATE_DELAY g39432 = rst ? 0 : ((0|T09_|g39403) ? 1'b0 : 1'bz);
// Gate A5-U137A
pullup(NISQ_);
assign #GATE_DELAY NISQ_ = rst ? 1'bz : ((0|d2XP7|g39112|A58XP15) ? 1'b0 : 1'bz);
// Gate A5-U152A A5-U208B
pullup(TSGN_);
assign #GATE_DELAY TSGN_ = rst ? 1'bz : ((0|g29121|d7XP9|g39134|A55XP9|RSTSTG) ? 1'b0 : 1'bz);
// Gate A5-U214A
pullup(g39436);
assign #GATE_DELAY g39436 = rst ? 0 : ((0|T09_|DV4_) ? 1'b0 : 1'bz);
// Gate A5-U201B
pullup(g39461);
assign #GATE_DELAY g39461 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A5-U225A
pullup(g39403);
assign #GATE_DELAY g39403 = rst ? 1'bz : ((0|g39401) ? 1'b0 : 1'bz);
// Gate A5-U217B
pullup(A56XP2);
assign #GATE_DELAY A56XP2 = rst ? 0 : ((0|INOUT_|RXOR0|T06_) ? 1'b0 : 1'bz);
// Gate A5-U219A
pullup(A56XP7);
assign #GATE_DELAY A56XP7 = rst ? 0 : ((0|T06_|DV4_) ? 1'b0 : 1'bz);
// Gate A5-U136B
pullup(DVST);
assign #GATE_DELAY DVST = rst ? 0 : ((0|STD2|T02_|DIV_) ? 1'b0 : 1'bz);
// Gate A5-U103B
pullup(g39221);
assign #GATE_DELAY g39221 = rst ? 0 : ((0|TCSAJ3_|T08_) ? 1'b0 : 1'bz);
// Gate A5-U108A A5-U106B
pullup(TSUDO_);
assign #GATE_DELAY TSUDO_ = rst ? 1'bz : ((0|RSM3|IC3|MP3|IC16) ? 1'b0 : 1'bz);
// Gate A5-U150A
pullup(WG_);
assign #GATE_DELAY WG_ = rst ? 1'bz : ((0|g29121|g39138|d9XP5) ? 1'b0 : 1'bz);
// Gate A5-U243B
pullup(g39329);
assign #GATE_DELAY g39329 = rst ? 1'bz : ((0|DAS1|PRINC|PARTC) ? 1'b0 : 1'bz);
// Gate A5-U135A
pullup(g39103);
assign #GATE_DELAY g39103 = rst ? 0 : ((0|IC10_|T01_) ? 1'b0 : 1'bz);
// Gate A5-U105A
pullup(A58XP12);
assign #GATE_DELAY A58XP12 = rst ? 0 : ((0|DAS0_|T08_) ? 1'b0 : 1'bz);
// Gate A5-U107B
pullup(A58XP15);
assign #GATE_DELAY A58XP15 = rst ? 0 : ((0|g39209|T08_) ? 1'b0 : 1'bz);
// Gate A5-U260A
pullup(g39349);
assign #GATE_DELAY g39349 = rst ? 0 : ((0|S11|S12) ? 1'b0 : 1'bz);
// Gate A5-U140B
pullup(d3XP6);
assign #GATE_DELAY d3XP6 = rst ? 0 : ((0|T03_|TC0_) ? 1'b0 : 1'bz);
// Gate A5-U113A
pullup(d10XP1);
assign #GATE_DELAY d10XP1 = rst ? 0 : ((0|T10_|g39230) ? 1'b0 : 1'bz);
// Gate A5-U114B
pullup(d10XP6);
assign #GATE_DELAY d10XP6 = rst ? 0 : ((0|T10_|BR2|CCS0_) ? 1'b0 : 1'bz);
// Gate A5-U153A
pullup(g39143);
assign #GATE_DELAY g39143 = rst ? 0 : ((0|MSU0_|T06_) ? 1'b0 : 1'bz);
// Gate A5-U117A
pullup(d10XP8);
assign #GATE_DELAY d10XP8 = rst ? 0 : ((0|BR1B2_|T10_|DAS0_) ? 1'b0 : 1'bz);
// Gate A5-U147B
pullup(g39133);
assign #GATE_DELAY g39133 = rst ? 1'bz : ((0|PRINC|PARTC|CCS0) ? 1'b0 : 1'bz);
// Gate A5-U149A A5-U220B
pullup(TMZ_);
assign #GATE_DELAY TMZ_ = rst ? 1'bz : ((0|g29121|g39134|g39439) ? 1'b0 : 1'bz);
// Gate A5-U201A
pullup(g39452);
assign #GATE_DELAY g39452 = rst ? 0 : ((0|T12_|T12USE_|DV1_) ? 1'b0 : 1'bz);
// Gate A5-U147A
pullup(g39134);
assign #GATE_DELAY g39134 = rst ? 0 : ((0|g39133|T05_) ? 1'b0 : 1'bz);
// Gate A5-U112B
pullup(A58XP3);
assign #GATE_DELAY A58XP3 = rst ? 0 : ((0|g39211|T08_) ? 1'b0 : 1'bz);
// Gate A5-U128A A5-U155B A5-U249B
pullup(WY_);
assign #GATE_DELAY WY_ = rst ? 1'bz : ((0|g39227|g39225|g39233|g39140|g39143|g39149|A510XP10|g39330|d2XP8) ? 1'b0 : 1'bz);
// Gate A5-U256A
pullup(OCTAD2);
assign #GATE_DELAY OCTAD2 = rst ? 0 : ((0|XT2_|NDR100_) ? 1'b0 : 1'bz);
// Gate A5-U159A A5-U247A
pullup(WY12_);
assign #GATE_DELAY WY12_ = rst ? 1'bz : ((0|g39102|d4XP5|g39152|g39341|g39343) ? 1'b0 : 1'bz);
// Gate A5-U224A
pullup(g39412);
assign #GATE_DELAY g39412 = rst ? 0 : ((0|g39410|T05_) ? 1'b0 : 1'bz);
// Gate A5-U225B
pullup(A55XP19);
assign #GATE_DELAY A55XP19 = rst ? 0 : ((0|g39405|T05_) ? 1'b0 : 1'bz);
// Gate A5-U111B
pullup(g39203);
assign #GATE_DELAY g39203 = rst ? 0 : ((0|FETCH0|T08_|INKL_) ? 1'b0 : 1'bz);
// Gate A5-U101B
pullup(g39248);
assign #GATE_DELAY g39248 = rst ? 0 : ((0|GOJAM|GNHNC) ? 1'b0 : 1'bz);
// Gate A5-U153B
pullup(g39140);
assign #GATE_DELAY g39140 = rst ? 0 : ((0|T06_|DAS0_) ? 1'b0 : 1'bz);
// Gate A5-U203B
pullup(A511XP6);
assign #GATE_DELAY A511XP6 = rst ? 0 : ((0|DV1_|T11_) ? 1'b0 : 1'bz);
// Gate A5-U251A
pullup(g39343);
assign #GATE_DELAY g39343 = rst ? 0 : ((0|g39342|T05_) ? 1'b0 : 1'bz);
// Gate A5-U251B
pullup(g39341);
assign #GATE_DELAY g39341 = rst ? 0 : ((0|IC16_|T05_) ? 1'b0 : 1'bz);
// Gate A5-U252B
pullup(g39344);
assign #GATE_DELAY g39344 = rst ? 0 : ((0|IC5_|T05_) ? 1'b0 : 1'bz);
// Gate A5-U253B
pullup(d5XP21);
assign #GATE_DELAY d5XP21 = rst ? 0 : ((0|CHINC_|T05_) ? 1'b0 : 1'bz);
// Gate A5-U247B
pullup(g39327);
assign #GATE_DELAY g39327 = rst ? 0 : ((0|T05_|DAS1_) ? 1'b0 : 1'bz);
// Gate A5-U132B
pullup(MONEX_);
assign #GATE_DELAY MONEX_ = rst ? 1'bz : ((0|g39103|d10XP6|A510XP7) ? 1'b0 : 1'bz);
// Gate A5-U223A A5-U222B
pullup(g39410);
assign #GATE_DELAY g39410 = rst ? 1'bz : ((0|IC2|READ0|IC5|DV4|g39409) ? 1'b0 : 1'bz);
// Gate A5-U104B
pullup(RSTRT);
assign #GATE_DELAY RSTRT = rst ? 0 : ((0|GOJ1_|T08_) ? 1'b0 : 1'bz);
// Gate A5-U207A
pullup(g39445);
assign #GATE_DELAY g39445 = rst ? 1'bz : ((0|IC2|IC14|DV1) ? 1'b0 : 1'bz);
// Gate A5-U146A
pullup(g39129);
assign #GATE_DELAY g39129 = rst ? 0 : ((0|MASK0_|T04_) ? 1'b0 : 1'bz);
// Gate A5-U216B
pullup(TOV_);
assign #GATE_DELAY TOV_ = rst ? 1'bz : ((0|A56XP7|d6XP8) ? 1'b0 : 1'bz);
// Gate A5-U117B
pullup(g39235);
assign #GATE_DELAY g39235 = rst ? 1'bz : ((0|g39239|g39237) ? 1'b0 : 1'bz);
// Gate A5-U206A
pullup(g39441);
assign #GATE_DELAY g39441 = rst ? 0 : ((0|T10_|g39445) ? 1'b0 : 1'bz);
// Gate A5-U126B
pullup(g39239);
assign #GATE_DELAY g39239 = rst ? 0 : ((0|MSU0_|BR1_) ? 1'b0 : 1'bz);
// Gate A5-U105B
pullup(g39213);
assign #GATE_DELAY g39213 = rst ? 1'bz : ((0|IC2|IC4|DXCH0) ? 1'b0 : 1'bz);
// Gate A5-U104A
pullup(g39214);
assign #GATE_DELAY g39214 = rst ? 0 : ((0|g39213|T08_) ? 1'b0 : 1'bz);
// Gate A5-U116A
pullup(g39232);
assign #GATE_DELAY g39232 = rst ? 1'bz : ((0|g39239|DAS0) ? 1'b0 : 1'bz);
// Gate A5-U145A A5-U115A A5-U222A
pullup(WA_);
assign #GATE_DELAY WA_ = rst ? 1'bz : ((0|g39129|g39127|g39223|d5XP11|g39243|g39412|g39432) ? 1'b0 : 1'bz);
// Gate A5-U205B
pullup(A510XP10);
assign #GATE_DELAY A510XP10 = rst ? 0 : ((0|T10_|IC11_) ? 1'b0 : 1'bz);
// Gate A5-U244B
pullup(g39324);
assign #GATE_DELAY g39324 = rst ? 0 : ((0|IC12_|T05_) ? 1'b0 : 1'bz);
// Gate A5-U113B
pullup(g39230);
assign #GATE_DELAY g39230 = rst ? 1'bz : ((0|IC1|RUPT0|IC10) ? 1'b0 : 1'bz);
// Gate A5-U224B
pullup(g39406);
assign #GATE_DELAY g39406 = rst ? 0 : ((0|g39404|T05_) ? 1'b0 : 1'bz);
// Gate A5-U118A
pullup(d9XP5);
assign #GATE_DELAY d9XP5 = rst ? 0 : ((0|T09_|DAS0_) ? 1'b0 : 1'bz);
// Gate A5-U156B
pullup(d7XP4);
assign #GATE_DELAY d7XP4 = rst ? 0 : ((0|CCS0_|BR2_|T07_) ? 1'b0 : 1'bz);
// Gate A5-U213A
pullup(g39425);
assign #GATE_DELAY g39425 = rst ? 0 : ((0|T07_|STFET1_) ? 1'b0 : 1'bz);
// Gate A5-U146B
pullup(d5XP12);
assign #GATE_DELAY d5XP12 = rst ? 0 : ((0|T05_|DAS0_) ? 1'b0 : 1'bz);
// Gate A5-U208A
pullup(WYD_);
assign #GATE_DELAY WYD_ = rst ? 1'bz : ((0|A55XP9|A511XP6) ? 1'b0 : 1'bz);
// Gate A5-U246A
pullup(d5XP15);
assign #GATE_DELAY d5XP15 = rst ? 0 : ((0|T05_|QXCH0_) ? 1'b0 : 1'bz);
// Gate A5-U243A
pullup(g39330);
assign #GATE_DELAY g39330 = rst ? 0 : ((0|g39329|T05_) ? 1'b0 : 1'bz);
// Gate A5-U145B A5-U238B
pullup(RL_);
assign #GATE_DELAY RL_ = rst ? 1'bz : ((0|g39127|g39116|A58XP12|A511XP6|g39319|g39313) ? 1'b0 : 1'bz);
// Gate A5-U109A A5-U211A A5-U216A
pullup(RU_);
assign #GATE_DELAY RU_ = rst ? 1'bz : ((0|d9XP5|g39201|g39214|g39452|g39436|g39441|g39416|d6XP8|d5XP11) ? 1'b0 : 1'bz);
// Gate A5-U207B
pullup(g39427);
assign #GATE_DELAY g39427 = rst ? 1'bz : ((0|DV1|IC14|IC13) ? 1'b0 : 1'bz);
// Gate A5-U242A
pullup(g39318);
assign #GATE_DELAY g39318 = rst ? 1'bz : ((0|INOUT|IC2|DV1) ? 1'b0 : 1'bz);
// Gate A5-U204A
pullup(g39448);
assign #GATE_DELAY g39448 = rst ? 1'bz : ((0|DV4B1B|IC4|g39447) ? 1'b0 : 1'bz);
// Gate A5-U119A
pullup(g39223);
assign #GATE_DELAY g39223 = rst ? 0 : ((0|T09_|g39222) ? 1'b0 : 1'bz);
// Gate A5-U120A A5-U154A A5-U221A A5-U221B
pullup(RC_);
assign #GATE_DELAY RC_ = rst ? 1'bz : ((0|g39241|g39225|g39129|g39143|g39406|g39432|g39439|g39451) ? 1'b0 : 1'bz);
// Gate A5-U139A
pullup(g39120);
assign #GATE_DELAY g39120 = rst ? 0 : ((0|IC2_|T03_) ? 1'b0 : 1'bz);
// Gate A5-U226B
pullup(g39409);
assign #GATE_DELAY g39409 = rst ? 0 : ((0|TS0_|BRDIF_) ? 1'b0 : 1'bz);
// Gate A5-U109B A5-U240A A5-U240B A5-U210B
pullup(WB_);
assign #GATE_DELAY WB_ = rst ? 1'bz : ((0|g39217|RAD|g39320|g39324|A56XP2|g39312|g39313|RQ|g39428|g39441|g39436) ? 1'b0 : 1'bz);
// Gate A5-U217A
pullup(d6XP8);
assign #GATE_DELAY d6XP8 = rst ? 0 : ((0|T06_|DAS1_) ? 1'b0 : 1'bz);
// Gate A5-U143A
pullup(TPZG_);
assign #GATE_DELAY TPZG_ = rst ? 1'bz : ((0|g39125|g39134) ? 1'b0 : 1'bz);
// Gate A5-U249A
pullup(g39335);
assign #GATE_DELAY g39335 = rst ? 0 : ((0|T05_|SHANC_) ? 1'b0 : 1'bz);
// Gate A5-U102B
pullup(g39217);
assign #GATE_DELAY g39217 = rst ? 0 : ((0|g39216|T08_) ? 1'b0 : 1'bz);
// Gate A5-U205A
pullup(g39449);
assign #GATE_DELAY g39449 = rst ? 0 : ((0|T10_|g39448) ? 1'b0 : 1'bz);
// Gate A5-U260B A5-U259B
pullup(SCAD);
assign #GATE_DELAY SCAD = rst ? 0 : ((0|S12|S11|XT0_|YT0_|YB0_) ? 1'b0 : 1'bz);
// Gate A5-U237B A5-U236B
pullup(g39310);
assign #GATE_DELAY g39310 = rst ? 1'bz : ((0|MP0|IC5|DAS0|MASK0|TS0) ? 1'b0 : 1'bz);
// Gate A5-U236A
pullup(g39312);
assign #GATE_DELAY g39312 = rst ? 0 : ((0|g39310|T03_) ? 1'b0 : 1'bz);
// Gate A5-U155A A5-U248A
pullup(CI_);
assign #GATE_DELAY CI_ = rst ? 1'bz : ((0|g39102|d10XP6|g39143|g39335|g39341|g39343) ? 1'b0 : 1'bz);
// Gate A5-U156A
pullup(d7XP9);
assign #GATE_DELAY d7XP9 = rst ? 0 : ((0|T07_|MSU0_) ? 1'b0 : 1'bz);
// Gate A5-U103A
pullup(g39216);
assign #GATE_DELAY g39216 = rst ? 1'bz : ((0|DAS0|DXCH0|GOJ1) ? 1'b0 : 1'bz);
// Gate A5-U255B
pullup(OCTAD6);
assign #GATE_DELAY OCTAD6 = rst ? 0 : ((0|XT6_|NDR100_) ? 1'b0 : 1'bz);
// Gate A5-U134A
pullup(g39106);
assign #GATE_DELAY g39106 = rst ? 0 : ((0|T01_|g39105) ? 1'b0 : 1'bz);
// Gate A5-U137B
pullup(d2XP7);
assign #GATE_DELAY d2XP7 = rst ? 0 : ((0|T02_|MP3_) ? 1'b0 : 1'bz);
// Gate A5-U119B
pullup(g39222);
assign #GATE_DELAY g39222 = rst ? 1'bz : ((0|DV1B1B|IC2) ? 1'b0 : 1'bz);
// Gate A5-U231A
pullup(WS_);
assign #GATE_DELAY WS_ = rst ? 1'bz : ((0|RL10BB|RSCT|g39307) ? 1'b0 : 1'bz);
// Gate A5-U101A
pullup(GNHNC);
assign #GATE_DELAY GNHNC = rst ? 1'bz : ((0|g39248|T01) ? 1'b0 : 1'bz);
// Gate A5-U154B A5-U248B
pullup(A2X_);
assign #GATE_DELAY A2X_ = rst ? 1'bz : ((0|g39149|g39143|g39140|g39327|A510XP10) ? 1'b0 : 1'bz);
// Gate A5-U136A
pullup(g39112);
assign #GATE_DELAY g39112 = rst ? 0 : ((0|g39111|T02_) ? 1'b0 : 1'bz);
// Gate A5-U138B
pullup(g39111);
assign #GATE_DELAY g39111 = rst ? 1'bz : ((0|IC2|IC3|RSM3) ? 1'b0 : 1'bz);
// Gate A5-U242B
pullup(d2XP8);
assign #GATE_DELAY d2XP8 = rst ? 0 : ((0|FETCH0_|T02_) ? 1'b0 : 1'bz);
// Gate A5-U132A A5-U150B A5-U110A A5-U250B
pullup(RB_);
assign #GATE_DELAY RB_ = rst ? 1'bz : ((0|g39120|g39109|g39145|g39138|g39223|g39203|A55XP19|g39341) ? 1'b0 : 1'bz);
// Gate A5-U241B
pullup(g39319);
assign #GATE_DELAY g39319 = rst ? 0 : ((0|DV1_|T04_) ? 1'b0 : 1'bz);
// Gate A5-U213B
pullup(U2BBK);
assign #GATE_DELAY U2BBK = rst ? 0 : ((0|T08_|MONWBK|STFET1_) ? 1'b0 : 1'bz);
// Gate A5-U239A
pullup(g39313);
assign #GATE_DELAY g39313 = rst ? 0 : ((0|IC8_|T03_) ? 1'b0 : 1'bz);
// Gate A5-U139B
pullup(g29121);
assign #GATE_DELAY g29121 = rst ? 0 : ((0|IC15_|T01_) ? 1'b0 : 1'bz);
// Gate A5-U143B
pullup(g39125);
assign #GATE_DELAY g39125 = rst ? 0 : ((0|IC15_|T02_) ? 1'b0 : 1'bz);
// Gate A5-U220A
pullup(g39416);
assign #GATE_DELAY g39416 = rst ? 0 : ((0|T06_|g39415) ? 1'b0 : 1'bz);
// Gate A5-U159B A5-U141B A5-U250A
pullup(RZ_);
assign #GATE_DELAY RZ_ = rst ? 1'bz : ((0|g39152|d4XP5|A58XP3|g39131|g39106|d3XP6|g39343|A56XP7) ? 1'b0 : 1'bz);
// Gate A5-U112A
pullup(g39211);
assign #GATE_DELAY g39211 = rst ? 1'bz : ((0|IC1|MP0) ? 1'b0 : 1'bz);
// Gate A5-U157A
pullup(g39152);
assign #GATE_DELAY g39152 = rst ? 0 : ((0|CCS0_|T07_) ? 1'b0 : 1'bz);
// Gate A5-U116B
pullup(A510XP7);
assign #GATE_DELAY A510XP7 = rst ? 0 : ((0|g39235|T10_) ? 1'b0 : 1'bz);
// Gate A5-U125A
pullup(g39245);
assign #GATE_DELAY g39245 = rst ? 1'bz : ((0|MSU0|IC14) ? 1'b0 : 1'bz);
// Gate A5-U157B
pullup(PTWOX);
assign #GATE_DELAY PTWOX = rst ? 0 : ((0|BR1_|T07_|CCS0_) ? 1'b0 : 1'bz);
// Gate A5-U125B
pullup(PINC);
assign #GATE_DELAY PINC = rst ? 0 : ((0|T12|PINC_) ? 1'b0 : 1'bz);
// Gate A5-U144A
pullup(g39131);
assign #GATE_DELAY g39131 = rst ? 0 : ((0|IC2_|T05_) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
