// Verilog module auto-generated for AGC module A24 by dumbVerilog.py

module A24 ( 
  rst, A15_, A16_, BMAGXM, BMAGXP, BMAGYM, BMAGYP, BMAGZP, CA6_, CDUXM, CDUXP,
  CDUYM, CDUYP, CDUZM, CDUZP, CGA24, CI_, CT, CT_, DKCTR4, DKCTR4_, DKCTR5,
  DKCTR5_, F01A, F01B, F02B, F03B_, F04B, F05A, F05B, F06B_, F07A_, F07B,
  F08B_, F09A, F17A, F17B, F18AX, F5ASB0, F5ASB2, FF1109_, FF1110_, FF1111_,
  FF1112_, FS02, FS03, FS04, FS05, FS06, FS06_, FS07A, FS07_, FS08, FS08_,
  FS09, FS16, FS17, GOJAM_, IC11, MP3, NISQ_, OCTAD2, OCTAD3, ODDSET_, PIPGZm,
  PIPGZp, PIPXM, PIPXP, PIPYM, PIPYP, RCH_, RSCT, RT_, RUSG_, SB0, SB1, SB2,
  SB4, SHAFTM, SHAFTP, SUMA15_, SUMB15_, T01DC_, T02, T06, T08, T09DC_, T1P,
  T2P, T3P, T4P, T5P, T6P, TRNM, TRNP, U2BBK, WCH_, WL01, WL02, WL03, WL04,
  WL05, WL06, WL07, WL08, WL09, WL10, WL11, WL12, WL13, WL14, WL16, WT_,
  XB3_, XB4_, XB7_, XT0_, CA2_, CA3_, CTPLS_, F05A_, F05B_, F07B_, F5ASB0_,
  F5ASB2_, FS05_, GOJAM, MNISQ, MON800, MRCH, MWATCH_, MWCH, OUTCOM, PIPZM,
  PIPZP, SB0_, SB1_, SB2_, T01, T02_, T09, BOTHZ, CCHG_, CDUCLK, CDUSTB_,
  CHWL01_, CHWL02_, CHWL03_, CHWL04_, CHWL05_, CHWL06_, CHWL07_, CHWL08_,
  CHWL09_, CHWL10_, CHWL11_, CHWL12_, CHWL13_, CHWL14_, CHWL16_, CI, CNTRSB_,
  ELSNCM, ELSNCN, F04B_, F05D, F07C_, F07D_, F09A_, F09D, F7CSB1_, FLASH,
  FLASH_, FS09_, GTONE, GTRST, GTSET, GTSET_, HIGH0_, HIGH1_, HIGH2_, HIGH3_,
  IC11_, LRRST, MISSZ, NISQ, NOZM, NOZP, ONE, OT1110, OT1111, OT1112, OVNHRP,
  PHS3_, PIPASW, PIPDAT, PIPINT, PIPPLS_, RCHAT_, RCHBT_, RCHG_, RRRST, RSCT_,
  U2BBKG_, US2SG, WATCH, WATCHP, WATCH_, WCHG_, d12KPPS, d25KPPS, d3200A,
  d3200B, d3200C, d3200D, d800RST, d800SET
);

input wire rst, A15_, A16_, BMAGXM, BMAGXP, BMAGYM, BMAGYP, BMAGZP, CA6_,
  CDUXM, CDUXP, CDUYM, CDUYP, CDUZM, CDUZP, CGA24, CI_, CT, CT_, DKCTR4,
  DKCTR4_, DKCTR5, DKCTR5_, F01A, F01B, F02B, F03B_, F04B, F05A, F05B, F06B_,
  F07A_, F07B, F08B_, F09A, F17A, F17B, F18AX, F5ASB0, F5ASB2, FF1109_, FF1110_,
  FF1111_, FF1112_, FS02, FS03, FS04, FS05, FS06, FS06_, FS07A, FS07_, FS08,
  FS08_, FS09, FS16, FS17, GOJAM_, IC11, MP3, NISQ_, OCTAD2, OCTAD3, ODDSET_,
  PIPGZm, PIPGZp, PIPXM, PIPXP, PIPYM, PIPYP, RCH_, RSCT, RT_, RUSG_, SB0,
  SB1, SB2, SB4, SHAFTM, SHAFTP, SUMA15_, SUMB15_, T01DC_, T02, T06, T08,
  T09DC_, T1P, T2P, T3P, T4P, T5P, T6P, TRNM, TRNP, U2BBK, WCH_, WL01, WL02,
  WL03, WL04, WL05, WL06, WL07, WL08, WL09, WL10, WL11, WL12, WL13, WL14,
  WL16, WT_, XB3_, XB4_, XB7_, XT0_;

inout wire CA2_, CA3_, CTPLS_, F05A_, F05B_, F07B_, F5ASB0_, F5ASB2_, FS05_,
  GOJAM, MNISQ, MON800, MRCH, MWATCH_, MWCH, OUTCOM, PIPZM, PIPZP, SB0_,
  SB1_, SB2_, T01, T02_, T09;

output wire BOTHZ, CCHG_, CDUCLK, CDUSTB_, CHWL01_, CHWL02_, CHWL03_, CHWL04_,
  CHWL05_, CHWL06_, CHWL07_, CHWL08_, CHWL09_, CHWL10_, CHWL11_, CHWL12_,
  CHWL13_, CHWL14_, CHWL16_, CI, CNTRSB_, ELSNCM, ELSNCN, F04B_, F05D, F07C_,
  F07D_, F09A_, F09D, F7CSB1_, FLASH, FLASH_, FS09_, GTONE, GTRST, GTSET,
  GTSET_, HIGH0_, HIGH1_, HIGH2_, HIGH3_, IC11_, LRRST, MISSZ, NISQ, NOZM,
  NOZP, ONE, OT1110, OT1111, OT1112, OVNHRP, PHS3_, PIPASW, PIPDAT, PIPINT,
  PIPPLS_, RCHAT_, RCHBT_, RCHG_, RRRST, RSCT_, U2BBKG_, US2SG, WATCH, WATCHP,
  WATCH_, WCHG_, d12KPPS, d25KPPS, d3200A, d3200B, d3200C, d3200D, d800RST,
  d800SET;

// Gate A24-U210A
pullup(g49325);
assign #0.2  g49325 = rst ? 0 : ((0|g49323|g49318) ? 1'b0 : 1'bz);
// Gate A24-U209B
pullup(g49321);
assign #0.2  g49321 = rst ? 0 : ((0|g49327|g49317|g49302) ? 1'b0 : 1'bz);
// Gate A24-U244A
pullup(T01);
assign #0.2  T01 = rst ? 0 : ((0|ODDSET_|T01DC_) ? 1'b0 : 1'bz);
// Gate A24-U247A
pullup(F04B_);
assign #0.2  F04B_ = rst ? 1'bz : ((0|F04B) ? 1'b0 : 1'bz);
// Gate A24-U207B
pullup(PIPZM);
assign #0.2  PIPZM = rst ? 0 : ((0|g49316|g49327|g49302) ? 1'b0 : 1'bz);
// Gate A24-U209A
pullup(g49322);
assign #0.2  g49322 = rst ? 0 : ((0|g49301|g49316|g49327) ? 1'b0 : 1'bz);
// Gate A24-U204A
pullup(GTSET);
assign #0.2  GTSET = rst ? 0 : ((0|FS06_|F05B_|g49342) ? 1'b0 : 1'bz);
// Gate A24-U205A
pullup(g49341);
assign #0.2  g49341 = rst ? 0 : ((0|FS08_|FS07_|FS09_) ? 1'b0 : 1'bz);
// Gate A24-U250A
pullup(MRCH);
assign #0.2  MRCH = rst ? 0 : ((0|RCH_) ? 1'b0 : 1'bz);
// Gate A24-U130A A24-U130B
pullup(CHWL09_);
assign #0.2  CHWL09_ = rst ? 1'bz : ((0|WL09) ? 1'b0 : 1'bz);
// Gate A24-U102B
pullup(g49104);
assign #0.2  g49104 = rst ? 0 : ((0|A16_|g49102) ? 1'b0 : 1'bz);
// Gate A24-U139A
pullup(LRRST);
assign #0.2  LRRST = rst ? 0 : ((0|F05B_|SB1_) ? 1'b0 : 1'bz);
// Gate A24-U102A
pullup(g49103);
assign #0.2  g49103 = rst ? 0 : ((0|g49101|A15_) ? 1'b0 : 1'bz);
// Gate A24-U139B
pullup(RRRST);
assign #0.2  RRRST = rst ? 0 : ((0|F05B_|SB1_) ? 1'b0 : 1'bz);
// Gate A24-U123A A24-U123B
pullup(CHWL02_);
assign #0.2  CHWL02_ = rst ? 1'bz : ((0|WL02) ? 1'b0 : 1'bz);
// Gate A24-U104A
pullup(g49107);
assign #0.2  g49107 = rst ? 0 : ((0|NISQ_|g49104|g49103) ? 1'b0 : 1'bz);
// Gate A24-U250B
pullup(MWCH);
assign #0.2  MWCH = rst ? 0 : ((0|WCH_) ? 1'b0 : 1'bz);
// Gate A24-U247B
pullup(F05D);
assign #0.2  F05D = rst ? 0 : ((0|FS05_|F04B_) ? 1'b0 : 1'bz);
// Gate A24-U104B
pullup(g49108);
assign #0.2  g49108 = rst ? 0 : ((0|g49106|OVNHRP) ? 1'b0 : 1'bz);
// Gate A24-U228A
pullup(g49304);
assign #0.2  g49304 = rst ? 0 : ((0|NOZM|F18AX) ? 1'b0 : 1'bz);
// Gate A24-U110A A24-U110B
pullup(HIGH0_);
assign #0.2  HIGH0_ = rst ? 0 : ((0|g49120) ? 1'b0 : 1'bz);
// Gate A24-U202B A24-U201A
pullup(GTONE);
assign #0.2  GTONE = rst ? 0 : ((0|F05B_|FS06|FS07A|FS09|FS08) ? 1'b0 : 1'bz);
// Gate A24-U149A
pullup(PIPINT);
assign #0.2  PIPINT = rst ? 0 : ((0|g49207|PIPPLS_) ? 1'b0 : 1'bz);
// Gate A24-U237A
pullup(g49412);
assign #0.2  g49412 = rst ? 1'bz : ((0|CDUSTB_|T08) ? 1'b0 : 1'bz);
// Gate A24-U227A
pullup(NOZP);
assign #0.2  NOZP = rst ? 1'bz : ((0|PIPGZp|g49306) ? 1'b0 : 1'bz);
// Gate A24-U129A A24-U129B
pullup(CHWL08_);
assign #0.2  CHWL08_ = rst ? 1'bz : ((0|WL08) ? 1'b0 : 1'bz);
// Gate A24-U229A
pullup(NOZM);
assign #0.2  NOZM = rst ? 1'bz : ((0|PIPGZm|g49304) ? 1'b0 : 1'bz);
// Gate A24-U151B
pullup(PIPASW);
assign #0.2  PIPASW = rst ? 0 : ((0|PIPPLS_|SB1_) ? 1'b0 : 1'bz);
// Gate A24-U244B
pullup(T09);
assign #0.2  T09 = rst ? 0 : ((0|ODDSET_|T09DC_) ? 1'b0 : 1'bz);
// Gate A24-U141A
pullup(d3200C);
assign #0.2  d3200C = rst ? 0 : ((0|SB0_|g49214|FS05) ? 1'b0 : 1'bz);
// Gate A24-U215A
pullup(CA2_);
assign #0.2  CA2_ = rst ? 1'bz : ((0|OCTAD2) ? 1'b0 : 1'bz);
// Gate A24-U142B
pullup(d3200B);
assign #0.2  d3200B = rst ? 0 : ((0|F05B_|SB0_) ? 1'b0 : 1'bz);
// Gate A24-U213A
pullup(g49319);
assign #0.2  g49319 = rst ? 0 : ((0|g49301|g49317|g49328) ? 1'b0 : 1'bz);
// Gate A24-U212A
pullup(g49320);
assign #0.2  g49320 = rst ? 0 : ((0|g49302|g49328|g49316) ? 1'b0 : 1'bz);
// Gate A24-U122A A24-U122B
pullup(CHWL01_);
assign #0.2  CHWL01_ = rst ? 1'bz : ((0|WL01) ? 1'b0 : 1'bz);
// Gate A24-U142A
pullup(d3200A);
assign #0.2  d3200A = rst ? 0 : ((0|F05A_|SB0_) ? 1'b0 : 1'bz);
// Gate A24-U214A
pullup(BOTHZ);
assign #0.2  BOTHZ = rst ? 0 : ((0|g49302|g49301) ? 1'b0 : 1'bz);
// Gate A24-U157A
pullup(g49244);
assign #0.2  g49244 = rst ? 0 : ((0|XB3_|XT0_) ? 1'b0 : 1'bz);
// Gate A24-U112B
pullup(g49126);
assign #0.2  g49126 = rst ? 0 : ((0|DKCTR5_|DKCTR4) ? 1'b0 : 1'bz);
// Gate A24-U207A
pullup(PIPZP);
assign #0.2  PIPZP = rst ? 0 : ((0|g49301|g49327|g49317) ? 1'b0 : 1'bz);
// Gate A24-U112A
pullup(g49123);
assign #0.2  g49123 = rst ? 0 : ((0|DKCTR4_|DKCTR5) ? 1'b0 : 1'bz);
// Gate A24-U253A
pullup(CNTRSB_);
assign #0.2  CNTRSB_ = rst ? 1'bz : ((0|SB2) ? 1'b0 : 1'bz);
// Gate A24-U154A
pullup(ELSNCN);
assign #0.2  ELSNCN = rst ? 0 : ((0|g49248) ? 1'b0 : 1'bz);
// Gate A24-U154B
pullup(ELSNCM);
assign #0.2  ELSNCM = rst ? 0 : ((0|g49248) ? 1'b0 : 1'bz);
// Gate A24-U147B
pullup(d800SET);
assign #0.2  d800SET = rst ? 0 : ((0|SB1_|F07A_) ? 1'b0 : 1'bz);
// Gate A24-U135A
pullup(MON800);
assign #0.2  MON800 = rst ? 1'bz : ((0|FS07A) ? 1'b0 : 1'bz);
// Gate A24-U224B
pullup(g49359);
assign #0.2  g49359 = rst ? 0 : ((0|F07C_|SB1_) ? 1'b0 : 1'bz);
// Gate A24-U217B
pullup(g49315);
assign #0.2  g49315 = rst ? 0 : ((0|g49313|g49318) ? 1'b0 : 1'bz);
// Gate A24-U146B
pullup(CDUCLK);
assign #0.2  CDUCLK = rst ? 0 : ((0|SB0_|g49222) ? 1'b0 : 1'bz);
// Gate A24-U217A
pullup(g49314);
assign #0.2  g49314 = rst ? 0 : ((0|g49312|g49318) ? 1'b0 : 1'bz);
// Gate A24-U116B A24-U117B A24-U118B
pullup(RCHG_);
assign #0.2  RCHG_ = rst ? 1'bz : ((0|g49132) ? 1'b0 : 1'bz);
// Gate A24-U153B
pullup(g49201);
assign #0.2  g49201 = rst ? 1'bz : ((0|FS04) ? 1'b0 : 1'bz);
// Gate A24-U125A A24-U125B
pullup(CHWL04_);
assign #0.2  CHWL04_ = rst ? 1'bz : ((0|WL04) ? 1'b0 : 1'bz);
// Gate A24-U111B
pullup(MWATCH_);
assign #0.2  MWATCH_ = rst ? 0 : ((0|WATCH) ? 1'b0 : 1'bz);
// Gate A24-U248A A24-U248B
pullup(U2BBKG_);
assign #0.2  U2BBKG_ = rst ? 1'bz : ((0|U2BBK) ? 1'b0 : 1'bz);
// Gate A24-U239A A24-U239B
pullup(CHWL12_);
assign #0.2  CHWL12_ = rst ? 1'bz : ((0|WL12) ? 1'b0 : 1'bz);
// Gate A24-U141B
pullup(g49214);
assign #0.2  g49214 = rst ? 1'bz : ((0|F04B) ? 1'b0 : 1'bz);
// Gate A24-U113B A24-U114B
pullup(HIGH2_);
assign #0.2  HIGH2_ = rst ? 1'bz : ((0|g49126) ? 1'b0 : 1'bz);
// Gate A24-U203B
pullup(GTSET_);
assign #0.2  GTSET_ = rst ? 1'bz : ((0|GTSET) ? 1'b0 : 1'bz);
// Gate A24-U218B
pullup(g49313);
assign #0.2  g49313 = rst ? 1'bz : ((0|g49312|g49311) ? 1'b0 : 1'bz);
// Gate A24-U218A
pullup(g49312);
assign #0.2  g49312 = rst ? 0 : ((0|g49310|g49313) ? 1'b0 : 1'bz);
// Gate A24-U226B
pullup(F07D_);
assign #0.2  F07D_ = rst ? 1'bz : ((0|g49355) ? 1'b0 : 1'bz);
// Gate A24-U213B
pullup(F09A_);
assign #0.2  F09A_ = rst ? 1'bz : ((0|F09A) ? 1'b0 : 1'bz);
// Gate A24-U236A
pullup(IC11_);
assign #0.2  IC11_ = rst ? 1'bz : ((0|IC11) ? 1'b0 : 1'bz);
// Gate A24-U134A
pullup(d25KPPS);
assign #0.2  d25KPPS = rst ? 1'bz : ((0|FS02|SB0_|g49221) ? 1'b0 : 1'bz);
// Gate A24-U224A
pullup(MISSZ);
assign #0.2  MISSZ = rst ? 0 : ((0|PIPGZp|PIPGZm|g49308) ? 1'b0 : 1'bz);
// Gate A24-U240A A24-U240B
pullup(T02_);
assign #0.2  T02_ = rst ? 1'bz : ((0|T02) ? 1'b0 : 1'bz);
// Gate A24-U215B
pullup(CA3_);
assign #0.2  CA3_ = rst ? 1'bz : ((0|OCTAD3) ? 1'b0 : 1'bz);
// Gate A24-U245A A24-U245B A24-U246A A24-U246B
pullup(PHS3_);
assign #0.2  PHS3_ = rst ? 1'bz : ((0|CT) ? 1'b0 : 1'bz);
// Gate A24-U242A A24-U242B
pullup(CHWL14_);
assign #0.2  CHWL14_ = rst ? 1'bz : ((0|WL14) ? 1'b0 : 1'bz);
// Gate A24-U152B
pullup(FS05_);
assign #0.2  FS05_ = rst ? 1'bz : ((0|FS05) ? 1'b0 : 1'bz);
// Gate A24-U124A A24-U124B
pullup(CHWL03_);
assign #0.2  CHWL03_ = rst ? 1'bz : ((0|WL03) ? 1'b0 : 1'bz);
// Gate A24-U103A
pullup(g49106);
assign #0.2  g49106 = rst ? 0 : ((0|g49105|NISQ_) ? 1'b0 : 1'bz);
// Gate A24-U103B
pullup(g49105);
assign #0.2  g49105 = rst ? 1'bz : ((0|g49103|g49104) ? 1'b0 : 1'bz);
// Gate A24-U214B
pullup(g49318);
assign #0.2  g49318 = rst ? 1'bz : ((0|F5ASB2) ? 1'b0 : 1'bz);
// Gate A24-U211A
pullup(g49323);
assign #0.2  g49323 = rst ? 0 : ((0|g49319|g49320|g49324) ? 1'b0 : 1'bz);
// Gate A24-U211B
pullup(g49324);
assign #0.2  g49324 = rst ? 1'bz : ((0|g49322|g49323|g49321) ? 1'b0 : 1'bz);
// Gate A24-U106B
pullup(g49110);
assign #0.2  g49110 = rst ? 0 : ((0|XB7_|CA6_|T02_) ? 1'b0 : 1'bz);
// Gate A24-U106A
pullup(g49112);
assign #0.2  g49112 = rst ? 1'bz : ((0|g49111|F17B) ? 1'b0 : 1'bz);
// Gate A24-U145A A24-U145B
pullup(F05A_);
assign #0.2  F05A_ = rst ? 1'bz : ((0|F05A) ? 1'b0 : 1'bz);
// Gate A24-U105A
pullup(g49111);
assign #0.2  g49111 = rst ? 0 : ((0|g49110|g49112) ? 1'b0 : 1'bz);
// Gate A24-U225B
pullup(F7CSB1_);
assign #0.2  F7CSB1_ = rst ? 1'bz : ((0|g49359) ? 1'b0 : 1'bz);
// Gate A24-U113A A24-U114A
pullup(HIGH1_);
assign #0.2  HIGH1_ = rst ? 1'bz : ((0|g49123) ? 1'b0 : 1'bz);
// Gate A24-U159A
pullup(g49240);
assign #0.2  g49240 = rst ? 0 : ((0|XB4_|XT0_) ? 1'b0 : 1'bz);
// Gate A24-U151A
pullup(PIPDAT);
assign #0.2  PIPDAT = rst ? 0 : ((0|PIPPLS_|SB2_) ? 1'b0 : 1'bz);
// Gate A24-U132B
pullup(F07B_);
assign #0.2  F07B_ = rst ? 1'bz : ((0|F07B) ? 1'b0 : 1'bz);
// Gate A24-U225A
pullup(g49308);
assign #0.2  g49308 = rst ? 1'bz : ((0|MISSZ|F5ASB2) ? 1'b0 : 1'bz);
// Gate A24-U133B
pullup(OT1112);
assign #0.2  OT1112 = rst ? 0 : ((0|FF1112_) ? 1'b0 : 1'bz);
// Gate A24-U158A A24-U158B A24-U159B
pullup(RCHAT_);
assign #0.2  RCHAT_ = rst ? 1'bz : ((0|g49240) ? 1'b0 : 1'bz);
// Gate A24-U136A
pullup(OT1110);
assign #0.2  OT1110 = rst ? 0 : ((0|FF1110_) ? 1'b0 : 1'bz);
// Gate A24-U133A
pullup(OT1111);
assign #0.2  OT1111 = rst ? 0 : ((0|FF1111_) ? 1'b0 : 1'bz);
// Gate A24-U228B
pullup(g49356);
assign #0.2  g49356 = rst ? 0 : ((0|FS07A|F06B_) ? 1'b0 : 1'bz);
// Gate A24-U208B
pullup(g49328);
assign #0.2  g49328 = rst ? 0 : ((0|g49326|g49327) ? 1'b0 : 1'bz);
// Gate A24-U140A
pullup(d3200D);
assign #0.2  d3200D = rst ? 0 : ((0|SB0_|FS05_|g49214) ? 1'b0 : 1'bz);
// Gate A24-U138A A24-U138B
pullup(SB0_);
assign #0.2  SB0_ = rst ? 0 : ((0|SB0) ? 1'b0 : 1'bz);
// Gate A24-U212B
pullup(F5ASB0_);
assign #0.2  F5ASB0_ = rst ? 1'bz : ((0|F5ASB0) ? 1'b0 : 1'bz);
// Gate A24-U153A
pullup(g49202);
assign #0.2  g49202 = rst ? 0 : ((0|g49201|F03B_|FS05) ? 1'b0 : 1'bz);
// Gate A24-U160A A24-U160B
pullup(CHWL10_);
assign #0.2  CHWL10_ = rst ? 1'bz : ((0|WL10) ? 1'b0 : 1'bz);
// Gate A24-U230B
pullup(g49302);
assign #0.2  g49302 = rst ? 1'bz : ((0|PIPGZm) ? 1'b0 : 1'bz);
// Gate A24-U208A
pullup(g49327);
assign #0.2  g49327 = rst ? 1'bz : ((0|g49328|g49325) ? 1'b0 : 1'bz);
// Gate A24-U230A
pullup(g49301);
assign #0.2  g49301 = rst ? 1'bz : ((0|PIPGZp) ? 1'b0 : 1'bz);
// Gate A24-U143A A24-U144A A24-U144B
pullup(F05B_);
assign #0.2  F05B_ = rst ? 1'bz : ((0|F05B) ? 1'b0 : 1'bz);
// Gate A24-U216A
pullup(g49316);
assign #0.2  g49316 = rst ? 1'bz : ((0|g49317|g49314) ? 1'b0 : 1'bz);
// Gate A24-U108A
pullup(g49115);
assign #0.2  g49115 = rst ? 0 : ((0|SB1_|g49113) ? 1'b0 : 1'bz);
// Gate A24-U234A A24-U234B A24-U235A A24-U235B A24-U236B
pullup(GOJAM);
assign #0.2  GOJAM = rst ? 1'bz : ((0|GOJAM_) ? 1'b0 : 1'bz);
// Gate A24-U137B
pullup(d12KPPS);
assign #0.2  d12KPPS = rst ? 0 : ((0|FS03|g49216|SB0_) ? 1'b0 : 1'bz);
// Gate A24-U111A
pullup(g49119);
assign #0.2  g49119 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A24-U202A
pullup(FS09_);
assign #0.2  FS09_ = rst ? 1'bz : ((0|FS09) ? 1'b0 : 1'bz);
// Gate A24-U121A A24-U120A A24-U119A
pullup(WCHG_);
assign #0.2  WCHG_ = rst ? 1'bz : ((0|g49136) ? 1'b0 : 1'bz);
// Gate A24-U152A
pullup(PIPPLS_);
assign #0.2  PIPPLS_ = rst ? 1'bz : ((0|g49202) ? 1'b0 : 1'bz);
// Gate A24-U233B
pullup(FLASH);
assign #0.2  FLASH = rst ? 1'bz : ((0|FS17|FS16) ? 1'b0 : 1'bz);
// Gate A24-U227B
pullup(F07C_);
assign #0.2  F07C_ = rst ? 1'bz : ((0|g49356) ? 1'b0 : 1'bz);
// Gate A24-U260A A24-U260B A24-U249A A24-U249B A24-U254B A24-U256A A24-U256B A24-U252A A24-U252B
pullup(CTPLS_);
assign #0.2  CTPLS_ = rst ? 1'bz : ((0|BMAGXM|BMAGXP|PIPZM|BMAGYP|BMAGYM|BMAGZP|T4P|T6P|T5P|T1P|T2P|T3P|TRNP|TRNM|SHAFTP|PIPZP|PIPYM|PIPYP|SHAFTM|PIPXP|PIPXM|CDUZM|CDUZP|CDUYM|CDUXP|CDUXM|CDUYP) ? 1'b0 : 1'bz);
// Gate A24-U146A
pullup(g49222);
assign #0.2  g49222 = rst ? 1'bz : ((0|F01A) ? 1'b0 : 1'bz);
// Gate A24-U147A
pullup(d800RST);
assign #0.2  d800RST = rst ? 0 : ((0|SB1_|F07B_) ? 1'b0 : 1'bz);
// Gate A24-U156A A24-U156B A24-U157B
pullup(RCHBT_);
assign #0.2  RCHBT_ = rst ? 1'bz : ((0|g49244) ? 1'b0 : 1'bz);
// Gate A24-U148A A24-U148B
pullup(SB1_);
assign #0.2  SB1_ = rst ? 1'bz : ((0|SB1) ? 1'b0 : 1'bz);
// Gate A24-U149B
pullup(g49207);
assign #0.2  g49207 = rst ? 1'bz : ((0|SB4) ? 1'b0 : 1'bz);
// Gate A24-U237B
pullup(CDUSTB_);
assign #0.2  CDUSTB_ = rst ? 0 : ((0|T06|g49412) ? 1'b0 : 1'bz);
// Gate A24-U115A
pullup(g49129);
assign #0.2  g49129 = rst ? 0 : ((0|DKCTR5_|DKCTR4_) ? 1'b0 : 1'bz);
// Gate A24-U126A A24-U126B
pullup(CHWL05_);
assign #0.2  CHWL05_ = rst ? 1'bz : ((0|WL05) ? 1'b0 : 1'bz);
// Gate A24-U155B
pullup(g49251);
assign #0.2  g49251 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A24-U155A
pullup(g49248);
assign #0.2  g49248 = rst ? 1'bz : ((0|FS07A) ? 1'b0 : 1'bz);
// Gate A24-U219B
pullup(g49311);
assign #0.2  g49311 = rst ? 0 : ((0|g49316|g49328|g49301) ? 1'b0 : 1'bz);
// Gate A24-U115B
pullup(g49132);
assign #0.2  g49132 = rst ? 0 : ((0|RCH_|RT_) ? 1'b0 : 1'bz);
// Gate A24-U107B
pullup(g49113);
assign #0.2  g49113 = rst ? 1'bz : ((0|F17A) ? 1'b0 : 1'bz);
// Gate A24-U238A A24-U238B
pullup(CHWL11_);
assign #0.2  CHWL11_ = rst ? 1'bz : ((0|WL11) ? 1'b0 : 1'bz);
// Gate A24-U204B
pullup(GTRST);
assign #0.2  GTRST = rst ? 0 : ((0|FS06|g49342|F05B_) ? 1'b0 : 1'bz);
// Gate A24-U233A
pullup(FLASH_);
assign #0.2  FLASH_ = rst ? 0 : ((0|FLASH) ? 1'b0 : 1'bz);
// Gate A24-U116A A24-U117A
pullup(HIGH3_);
assign #0.2  HIGH3_ = rst ? 1'bz : ((0|g49129) ? 1'b0 : 1'bz);
// Gate A24-U201B
pullup(OUTCOM);
assign #0.2  OUTCOM = rst ? 0 : ((0|FF1109_) ? 1'b0 : 1'bz);
// Gate A24-U101A
pullup(g49102);
assign #0.2  g49102 = rst ? 1'bz : ((0|A15_) ? 1'b0 : 1'bz);
// Gate A24-U210B
pullup(g49326);
assign #0.2  g49326 = rst ? 0 : ((0|g49324|g49318) ? 1'b0 : 1'bz);
// Gate A24-U229B
pullup(g49355);
assign #0.2  g49355 = rst ? 0 : ((0|FS07_|F06B_) ? 1'b0 : 1'bz);
// Gate A24-U203A
pullup(CI);
assign #0.2  CI = rst ? 0 : ((0|CI_) ? 1'b0 : 1'bz);
// Gate A24-U101B
pullup(g49101);
assign #0.2  g49101 = rst ? 1'bz : ((0|A16_) ? 1'b0 : 1'bz);
// Gate A24-U253B
pullup(US2SG);
assign #0.2  US2SG = rst ? 0 : ((0|SUMB15_|SUMA15_|RUSG_) ? 1'b0 : 1'bz);
// Gate A24-U150A A24-U150B
pullup(SB2_);
assign #0.2  SB2_ = rst ? 1'bz : ((0|SB2) ? 1'b0 : 1'bz);
// Gate A24-U121B A24-U120B
pullup(CCHG_);
assign #0.2  CCHG_ = rst ? 1'bz : ((0|g49140) ? 1'b0 : 1'bz);
// Gate A24-U128A A24-U128B
pullup(CHWL07_);
assign #0.2  CHWL07_ = rst ? 1'bz : ((0|WL07) ? 1'b0 : 1'bz);
// Gate A24-U137A
pullup(g49216);
assign #0.2  g49216 = rst ? 1'bz : ((0|F02B) ? 1'b0 : 1'bz);
// Gate A24-U108B
pullup(WATCH_);
assign #0.2  WATCH_ = rst ? 0 : ((0|WATCHP|WATCH) ? 1'b0 : 1'bz);
// Gate A24-U231A A24-U231B A24-U232B
pullup(F5ASB2_);
assign #0.2  F5ASB2_ = rst ? 1'bz : ((0|F5ASB2) ? 1'b0 : 1'bz);
// Gate A24-U105B
pullup(OVNHRP);
assign #0.2  OVNHRP = rst ? 1'bz : ((0|g49107|g49108|MP3) ? 1'b0 : 1'bz);
// Gate A24-U206A
pullup(g49351);
assign #0.2  g49351 = rst ? 0 : ((0|F08B_) ? 1'b0 : 1'bz);
// Gate A24-U205B
pullup(g49342);
assign #0.2  g49342 = rst ? 1'bz : ((0|g49341) ? 1'b0 : 1'bz);
// Gate A24-U107A
pullup(WATCHP);
assign #0.2  WATCHP = rst ? 0 : ((0|g49113|SB2_|g49112) ? 1'b0 : 1'bz);
// Gate A24-U232A
pullup(ONE);
assign #0.2  ONE = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A24-U136B
pullup(NISQ);
assign #0.2  NISQ = rst ? 0 : ((0|NISQ_) ? 1'b0 : 1'bz);
// Gate A24-U216B
pullup(g49317);
assign #0.2  g49317 = rst ? 0 : ((0|g49315|g49316) ? 1'b0 : 1'bz);
// Gate A24-U241A A24-U241B
pullup(CHWL13_);
assign #0.2  CHWL13_ = rst ? 1'bz : ((0|WL13) ? 1'b0 : 1'bz);
// Gate A24-U118A
pullup(g49136);
assign #0.2  g49136 = rst ? 0 : ((0|WCH_|WT_) ? 1'b0 : 1'bz);
// Gate A24-U127A A24-U127B
pullup(CHWL06_);
assign #0.2  CHWL06_ = rst ? 1'bz : ((0|WL06) ? 1'b0 : 1'bz);
// Gate A24-U135B
pullup(MNISQ);
assign #0.2  MNISQ = rst ? 0 : ((0|NISQ_) ? 1'b0 : 1'bz);
// Gate A24-U206B
pullup(F09D);
assign #0.2  F09D = rst ? 0 : ((0|g49351|FS09_) ? 1'b0 : 1'bz);
// Gate A24-U219A
pullup(g49310);
assign #0.2  g49310 = rst ? 0 : ((0|g49302|g49328|g49317) ? 1'b0 : 1'bz);
// Gate A24-U226A
pullup(g49306);
assign #0.2  g49306 = rst ? 0 : ((0|F18AX|NOZP) ? 1'b0 : 1'bz);
// Gate A24-U251A A24-U251B
pullup(RSCT_);
assign #0.2  RSCT_ = rst ? 1'bz : ((0|RSCT) ? 1'b0 : 1'bz);
// Gate A24-U243A A24-U243B
pullup(CHWL16_);
assign #0.2  CHWL16_ = rst ? 1'bz : ((0|WL16) ? 1'b0 : 1'bz);
// Gate A24-U109B
pullup(WATCH);
assign #0.2  WATCH = rst ? 1'bz : ((0|WATCH_|g49115) ? 1'b0 : 1'bz);
// Gate A24-U109A
pullup(g49120);
assign #0.2  g49120 = rst ? 1'bz : ((0|DKCTR5|DKCTR4) ? 1'b0 : 1'bz);
// Gate A24-U119B
pullup(g49140);
assign #0.2  g49140 = rst ? 0 : ((0|CT_|WCH_) ? 1'b0 : 1'bz);
// Gate A24-U134B
pullup(g49221);
assign #0.2  g49221 = rst ? 0 : ((0|F01B) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
