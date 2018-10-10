// Verilog module auto-generated for AGC module A14 by dumbVerilog.py

module A14 ( 
  rst, BR12B, CGA14, CHINC, CLEARA, CLEARB, CLEARC, CLEARD, DV3764, GOJ1,
  GOJAM, INOUT, MAMU, MNHSBF, MP1, MYCLMP, NISQL_, PHS2_, PHS3_, PHS4_, PSEUDO,
  R1C_, RB1_, RSC_, RT_, S01, S01_, S02, S02_, S03, S03_, S04, S04_, S05,
  S05_, S06, S06_, S07, S07_, S08, S08_, S09, S09_, S11, S12, SBY, SCAD,
  SCAD_, T01, T01_, T02_, T03, T03_, T04_, T05, T05_, T06, T06_, T07, T07_,
  T08, T08_, T09, T10, T10_, T11, T12A, T12_, TCSAJ3, TIMR, WHOMP_, WL11,
  WL16, WSC_, BR12B_, CLROPE, ERAS, IHENV, ILP, ILP_, NOTEST_, RESETA, RESETB,
  RESETC, RESETD, REX, REY, RILP1, RILP1_, SBE, SBF, SBYREL_, SETAB, SETCD,
  SETEK, WEX, WEY, WL11_, WL16_, XB0, XB0E, XB1, XB1E, XB2E, XB3, XB3E, XB4E,
  XB5, XB5E, XB6, XB6E, XB7E, XT0E, XT1E, XT2E, XT3E, XT4E, XT5E, XT6E, XT7E,
  YB0E, YB1E, YB2E, YB3E, ZID, CXB1_, ERAS_, FNERAS_, NOTEST, R1C, RB1, REDRST,
  ROP_, RSCG_, RSTK_, SBESET, SBFSET, SETAB_, SETCD_, STBE, STBF, STRGAT,
  TPARG_, TPGE, TPGF, WHOMPA, WSCG_, XB0_, XB1_, XB2, XB2_, XB3_, XB4, XB4_,
  XB5_, XB6_, XB7, XB7_, XT0, XT0_, XT1, XT1_, XT2, XT2_, XT3, XT3_, XT4,
  XT4_, XT5, XT5_, XT6, XT6_, XT7, XT7_, YB0, YB0_, YB1, YB1_, YB2, YB2_,
  YB3, YB3_
);

input wire rst, BR12B, CGA14, CHINC, CLEARA, CLEARB, CLEARC, CLEARD, DV3764,
  GOJ1, GOJAM, INOUT, MAMU, MNHSBF, MP1, MYCLMP, NISQL_, PHS2_, PHS3_, PHS4_,
  PSEUDO, R1C_, RB1_, RSC_, RT_, S01, S01_, S02, S02_, S03, S03_, S04, S04_,
  S05, S05_, S06, S06_, S07, S07_, S08, S08_, S09, S09_, S11, S12, SBY, SCAD,
  SCAD_, T01, T01_, T02_, T03, T03_, T04_, T05, T05_, T06, T06_, T07, T07_,
  T08, T08_, T09, T10, T10_, T11, T12A, T12_, TCSAJ3, TIMR, WHOMP_, WL11,
  WL16, WSC_;

inout wire BR12B_, CLROPE, ERAS, IHENV, ILP, ILP_, NOTEST_, RESETA, RESETB,
  RESETC, RESETD, REX, REY, RILP1, RILP1_, SBE, SBF, SBYREL_, SETAB, SETCD,
  SETEK, WEX, WEY, WL11_, WL16_, XB0, XB0E, XB1, XB1E, XB2E, XB3, XB3E, XB4E,
  XB5, XB5E, XB6, XB6E, XB7E, XT0E, XT1E, XT2E, XT3E, XT4E, XT5E, XT6E, XT7E,
  YB0E, YB1E, YB2E, YB3E, ZID;

output wire CXB1_, ERAS_, FNERAS_, NOTEST, R1C, RB1, REDRST, ROP_, RSCG_,
  RSTK_, SBESET, SBFSET, SETAB_, SETCD_, STBE, STBF, STRGAT, TPARG_, TPGE,
  TPGF, WHOMPA, WSCG_, XB0_, XB1_, XB2, XB2_, XB3_, XB4, XB4_, XB5_, XB6_,
  XB7, XB7_, XT0, XT0_, XT1, XT1_, XT2, XT2_, XT3, XT3_, XT4, XT4_, XT5,
  XT5_, XT6, XT6_, XT7, XT7_, YB0, YB0_, YB1, YB1_, YB2, YB2_, YB3, YB3_;

// Gate A14-U147A
pullup(g42126);
assign #0.2  g42126 = rst ? 0 : ((0|T08|GOJAM|g42127) ? 1'b0 : 1'bz);
// Gate A14-U222A
pullup(XB2E);
assign #0.2  XB2E = rst ? 0 : ((0|XB2_) ? 1'b0 : 1'bz);
// Gate A14-U243B
pullup(g42441);
assign #0.2  g42441 = rst ? 1'bz : ((0|XB6|XB5) ? 1'b0 : 1'bz);
// Gate A14-U146B
pullup(g42129);
assign #0.2  g42129 = rst ? 0 : ((0|S08|g42127|S09) ? 1'b0 : 1'bz);
// Gate A14-U235A A14-U236A
pullup(RSCG_);
assign #0.2  RSCG_ = rst ? 1'bz : ((0|g42448) ? 1'b0 : 1'bz);
// Gate A14-U103B A14-U109A A14-U102B
pullup(ERAS);
assign #0.2  ERAS = rst ? 1'bz : ((0|S12|S11|TCSAJ3|MAMU|MP1|INOUT|GOJ1|CHINC) ? 1'b0 : 1'bz);
// Gate A14-U217A A14-U215A A14-U218B
pullup(XB5_);
assign #0.2  XB5_ = rst ? 1'bz : ((0|XB5) ? 1'b0 : 1'bz);
// Gate A14-U223B A14-U224A A14-U224B
pullup(XB2_);
assign #0.2  XB2_ = rst ? 1'bz : ((0|XB2) ? 1'b0 : 1'bz);
// Gate A14-U255B
pullup(g42413);
assign #0.2  g42413 = rst ? 0 : ((0|S04_|S05_|S06) ? 1'b0 : 1'bz);
// Gate A14-U116A
pullup(g42229);
assign #0.2  g42229 = rst ? 0 : ((0|GOJAM|g42228|g42232) ? 1'b0 : 1'bz);
// Gate A14-U239B
pullup(ILP_);
assign #0.2  ILP_ = rst ? 1'bz : ((0|g42443) ? 1'b0 : 1'bz);
// Gate A14-U138A
pullup(g42144);
assign #0.2  g42144 = rst ? 0 : ((0|ROP_|T02_) ? 1'b0 : 1'bz);
// Gate A14-U104A A14-U104B
pullup(ERAS_);
assign #0.2  ERAS_ = rst ? 0 : ((0|ERAS) ? 1'b0 : 1'bz);
// Gate A14-U121B
pullup(g42218);
assign #0.2  g42218 = rst ? 0 : ((0|g42215|TIMR|RSTK_) ? 1'b0 : 1'bz);
// Gate A14-U117A
pullup(g42227);
assign #0.2  g42227 = rst ? 0 : ((0|T03_|ERAS_) ? 1'b0 : 1'bz);
// Gate A14-U258A
pullup(XT0E);
assign #0.2  XT0E = rst ? 1'bz : ((0|XT0_) ? 1'b0 : 1'bz);
// Gate A14-U123A
pullup(g42215);
assign #0.2  g42215 = rst ? 0 : ((0|PHS4_|T02_) ? 1'b0 : 1'bz);
// Gate A14-U127A
pullup(g42209);
assign #0.2  g42209 = rst ? 1'bz : ((0|g42214|g42210) ? 1'b0 : 1'bz);
// Gate A14-U128B
pullup(g42206);
assign #0.2  g42206 = rst ? 1'bz : ((0|g42211|g42205) ? 1'b0 : 1'bz);
// Gate A14-U112B
pullup(g42239);
assign #0.2  g42239 = rst ? 0 : ((0|GOJAM|REDRST|g42238) ? 1'b0 : 1'bz);
// Gate A14-U210B
pullup(WL11_);
assign #0.2  WL11_ = rst ? 1'bz : ((0|WL11) ? 1'b0 : 1'bz);
// Gate A14-U143A
pullup(g42132);
assign #0.2  g42132 = rst ? 1'bz : ((0|g42131|CLEARB) ? 1'b0 : 1'bz);
// Gate A14-U134A A14-U134B
pullup(CLROPE);
assign #0.2  CLROPE = rst ? 0 : ((0|g42149) ? 1'b0 : 1'bz);
// Gate A14-U130B
pullup(g42203);
assign #0.2  g42203 = rst ? 0 : ((0|g42202|T01) ? 1'b0 : 1'bz);
// Gate A14-U129A
pullup(g42201);
assign #0.2  g42201 = rst ? 0 : ((0|T12_|PHS3_) ? 1'b0 : 1'bz);
// Gate A14-U119A A14-U119B
pullup(ZID);
assign #0.2  ZID = rst ? 0 : ((0|MYCLMP|g42221) ? 1'b0 : 1'bz);
// Gate A14-U130A
pullup(g42202);
assign #0.2  g42202 = rst ? 1'bz : ((0|g42203|g42201) ? 1'b0 : 1'bz);
// Gate A14-U136A
pullup(g42151);
assign #0.2  g42151 = rst ? 0 : ((0|GOJAM|T07|g42149) ? 1'b0 : 1'bz);
// Gate A14-U126B
pullup(WEY);
assign #0.2  WEY = rst ? 0 : ((0|g42209) ? 1'b0 : 1'bz);
// Gate A14-U126A
pullup(WEX);
assign #0.2  WEX = rst ? 0 : ((0|g42206) ? 1'b0 : 1'bz);
// Gate A14-U136B
pullup(g42148);
assign #0.2  g42148 = rst ? 0 : ((0|g42155|g42147|T02_) ? 1'b0 : 1'bz);
// Gate A14-U107B
pullup(g42246);
assign #0.2  g42246 = rst ? 1'bz : ((0|STBE|SBESET) ? 1'b0 : 1'bz);
// Gate A14-U151A
pullup(SETCD);
assign #0.2  SETCD = rst ? 0 : ((0|SETCD_) ? 1'b0 : 1'bz);
// Gate A14-U106A
pullup(TPARG_);
assign #0.2  TPARG_ = rst ? 1'bz : ((0|TPGE|TPGF) ? 1'b0 : 1'bz);
// Gate A14-U213A
pullup(XB7);
assign #0.2  XB7 = rst ? 0 : ((0|S03_|S02_|S01_) ? 1'b0 : 1'bz);
// Gate A14-U215B
pullup(XB6);
assign #0.2  XB6 = rst ? 0 : ((0|S02_|S03_|S01) ? 1'b0 : 1'bz);
// Gate A14-U228B
pullup(XB1);
assign #0.2  XB1 = rst ? 1'bz : ((0|S01_|S02|S03) ? 1'b0 : 1'bz);
// Gate A14-U230B
pullup(XB0);
assign #0.2  XB0 = rst ? 0 : ((0|S03|S02|S01) ? 1'b0 : 1'bz);
// Gate A14-U223A
pullup(XB3);
assign #0.2  XB3 = rst ? 0 : ((0|S03|S01_|S02_) ? 1'b0 : 1'bz);
// Gate A14-U116B
pullup(g42228);
assign #0.2  g42228 = rst ? 1'bz : ((0|g42229|g42227) ? 1'b0 : 1'bz);
// Gate A14-U246B
pullup(XT7E);
assign #0.2  XT7E = rst ? 0 : ((0|XT7_) ? 1'b0 : 1'bz);
// Gate A14-U245A
pullup(XT7_);
assign #0.2  XT7_ = rst ? 1'bz : ((0|XT7) ? 1'b0 : 1'bz);
// Gate A14-U113A
pullup(g42235);
assign #0.2  g42235 = rst ? 0 : ((0|GOJAM|g42234|REDRST) ? 1'b0 : 1'bz);
// Gate A14-U205A
pullup(RILP1);
assign #0.2  RILP1 = rst ? 1'bz : ((0|YB0|YB3) ? 1'b0 : 1'bz);
// Gate A14-U115A
pullup(g42233);
assign #0.2  g42233 = rst ? 0 : ((0|PHS3_|ERAS_|T03_) ? 1'b0 : 1'bz);
// Gate A14-U137A
pullup(g42147);
assign #0.2  g42147 = rst ? 0 : ((0|ROP_) ? 1'b0 : 1'bz);
// Gate A14-U227B
pullup(XB0E);
assign #0.2  XB0E = rst ? 0 : ((0|XB0_) ? 1'b0 : 1'bz);
// Gate A14-U229A A14-U229B A14-U228A A14-U230A
pullup(XB0_);
assign #0.2  XB0_ = rst ? 1'bz : ((0|XB0) ? 1'b0 : 1'bz);
// Gate A14-U113B
pullup(g42234);
assign #0.2  g42234 = rst ? 1'bz : ((0|g42235|g42233) ? 1'b0 : 1'bz);
// Gate A14-U112A
pullup(g42238);
assign #0.2  g42238 = rst ? 1'bz : ((0|g42239|g42240) ? 1'b0 : 1'bz);
// Gate A14-U242A
pullup(g43437);
assign #0.2  g43437 = rst ? 0 : ((0|RILP1|g42442|g42435) ? 1'b0 : 1'bz);
// Gate A14-U244A
pullup(g42436);
assign #0.2  g42436 = rst ? 0 : ((0|g42441|RILP1|g42433) ? 1'b0 : 1'bz);
// Gate A14-U225A
pullup(XB2);
assign #0.2  XB2 = rst ? 0 : ((0|S01|S03|S02_) ? 1'b0 : 1'bz);
// Gate A14-U142A
pullup(g42136);
assign #0.2  g42136 = rst ? 1'bz : ((0|g42135|CLEARC) ? 1'b0 : 1'bz);
// Gate A14-U237A
pullup(g42445);
assign #0.2  g42445 = rst ? 1'bz : ((0|g42443) ? 1'b0 : 1'bz);
// Gate A14-U205B
pullup(YB2_);
assign #0.2  YB2_ = rst ? 0 : ((0|YB2) ? 1'b0 : 1'bz);
// Gate A14-U142B
pullup(g42137);
assign #0.2  g42137 = rst ? 0 : ((0|g42127|S09_|S08_) ? 1'b0 : 1'bz);
// Gate A14-U222B
pullup(XB3E);
assign #0.2  XB3E = rst ? 0 : ((0|XB3_) ? 1'b0 : 1'bz);
// Gate A14-U139A
pullup(g42138);
assign #0.2  g42138 = rst ? 1'bz : ((0|g42137|CLEARD) ? 1'b0 : 1'bz);
// Gate A14-U256A A14-U255A
pullup(XT2_);
assign #0.2  XT2_ = rst ? 1'bz : ((0|XT2) ? 1'b0 : 1'bz);
// Gate A14-U160A A14-U160B
pullup(ROP_);
assign #0.2  ROP_ = rst ? 1'bz : ((0|S12|S11) ? 1'b0 : 1'bz);
// Gate A14-U155B
pullup(g42111);
assign #0.2  g42111 = rst ? 0 : ((0|g42112|g42110|TIMR) ? 1'b0 : 1'bz);
// Gate A14-U254A
pullup(XT2E);
assign #0.2  XT2E = rst ? 0 : ((0|XT2_) ? 1'b0 : 1'bz);
// Gate A14-U254B
pullup(XT3E);
assign #0.2  XT3E = rst ? 0 : ((0|XT3_) ? 1'b0 : 1'bz);
// Gate A14-U203B
pullup(YB2E);
assign #0.2  YB2E = rst ? 1'bz : ((0|YB2_) ? 1'b0 : 1'bz);
// Gate A14-U247B
pullup(XT7);
assign #0.2  XT7 = rst ? 0 : ((0|S04_|S06_|S05_) ? 1'b0 : 1'bz);
// Gate A14-U245B
pullup(WL16_);
assign #0.2  WL16_ = rst ? 1'bz : ((0|WL16) ? 1'b0 : 1'bz);
// Gate A14-U110A
pullup(REDRST);
assign #0.2  REDRST = rst ? 1'bz : ((0|T05|g42242) ? 1'b0 : 1'bz);
// Gate A14-U248B
pullup(XT6);
assign #0.2  XT6 = rst ? 0 : ((0|S05_|S06_|S04) ? 1'b0 : 1'bz);
// Gate A14-U145B
pullup(g42130);
assign #0.2  g42130 = rst ? 1'bz : ((0|CLEARA|g42129) ? 1'b0 : 1'bz);
// Gate A14-U148B
pullup(STBF);
assign #0.2  STBF = rst ? 0 : ((0|GOJAM|g42125|g42123) ? 1'b0 : 1'bz);
// Gate A14-U106B
pullup(STBE);
assign #0.2  STBE = rst ? 0 : ((0|g42246|GOJAM|T05) ? 1'b0 : 1'bz);
// Gate A14-U157B
pullup(g42107);
assign #0.2  g42107 = rst ? 1'bz : ((0|g42109|g42106) ? 1'b0 : 1'bz);
// Gate A14-U232A A14-U233A A14-U233B
pullup(R1C);
assign #0.2  R1C = rst ? 0 : ((0|R1C_) ? 1'b0 : 1'bz);
// Gate A14-U234B A14-U235B
pullup(WSCG_);
assign #0.2  WSCG_ = rst ? 1'bz : ((0|g42451) ? 1'b0 : 1'bz);
// Gate A14-U135A A14-U135B
pullup(g42149);
assign #0.2  g42149 = rst ? 1'bz : ((0|g42151|g42148) ? 1'b0 : 1'bz);
// Gate A14-U221A A14-U221B A14-U220B
pullup(XB3_);
assign #0.2  XB3_ = rst ? 1'bz : ((0|XB3) ? 1'b0 : 1'bz);
// Gate A14-U152B
pullup(SETCD_);
assign #0.2  SETCD_ = rst ? 1'bz : ((0|g42115) ? 1'b0 : 1'bz);
// Gate A14-U240B
pullup(g42442);
assign #0.2  g42442 = rst ? 0 : ((0|g42440) ? 1'b0 : 1'bz);
// Gate A14-U114A A14-U114B
pullup(SETEK);
assign #0.2  SETEK = rst ? 0 : ((0|MYCLMP|g42228) ? 1'b0 : 1'bz);
// Gate A14-U204A
pullup(YB3_);
assign #0.2  YB3_ = rst ? 1'bz : ((0|YB3) ? 1'b0 : 1'bz);
// Gate A14-U209A
pullup(YB0);
assign #0.2  YB0 = rst ? 0 : ((0|S07|S08) ? 1'b0 : 1'bz);
// Gate A14-U206A
pullup(YB1);
assign #0.2  YB1 = rst ? 0 : ((0|S07_|S08) ? 1'b0 : 1'bz);
// Gate A14-U206B
pullup(YB2);
assign #0.2  YB2 = rst ? 1'bz : ((0|S07|S08_) ? 1'b0 : 1'bz);
// Gate A14-U243A A14-U244B
pullup(g42433);
assign #0.2  g42433 = rst ? 0 : ((0|XT6|XT5|XT0|XT3) ? 1'b0 : 1'bz);
// Gate A14-U146A
pullup(g42128);
assign #0.2  g42128 = rst ? 0 : ((0|PHS3_|T05_|ROP_) ? 1'b0 : 1'bz);
// Gate A14-U232B
pullup(BR12B_);
assign #0.2  BR12B_ = rst ? 1'bz : ((0|BR12B) ? 1'b0 : 1'bz);
// Gate A14-U226A A14-U226B A14-U225B
pullup(XB1_);
assign #0.2  XB1_ = rst ? 0 : ((0|XB1) ? 1'b0 : 1'bz);
// Gate A14-U203A
pullup(YB3E);
assign #0.2  YB3E = rst ? 0 : ((0|YB3_) ? 1'b0 : 1'bz);
// Gate A14-U111A
pullup(REX);
assign #0.2  REX = rst ? 0 : ((0|g42238) ? 1'b0 : 1'bz);
// Gate A14-U111B
pullup(REY);
assign #0.2  REY = rst ? 0 : ((0|g42234) ? 1'b0 : 1'bz);
// Gate A14-U144B
pullup(RESETA);
assign #0.2  RESETA = rst ? 0 : ((0|g42130) ? 1'b0 : 1'bz);
// Gate A14-U141B
pullup(RESETC);
assign #0.2  RESETC = rst ? 0 : ((0|g42136) ? 1'b0 : 1'bz);
// Gate A14-U144A
pullup(RESETB);
assign #0.2  RESETB = rst ? 0 : ((0|g42132) ? 1'b0 : 1'bz);
// Gate A14-U141A
pullup(RESETD);
assign #0.2  RESETD = rst ? 0 : ((0|g42138) ? 1'b0 : 1'bz);
// Gate A14-U238A
pullup(ILP);
assign #0.2  ILP = rst ? 0 : ((0|g42445) ? 1'b0 : 1'bz);
// Gate A14-U154A
pullup(g42112);
assign #0.2  g42112 = rst ? 1'bz : ((0|g42111|g42113) ? 1'b0 : 1'bz);
// Gate A14-U143B
pullup(g42135);
assign #0.2  g42135 = rst ? 0 : ((0|S09_|g42127|S08) ? 1'b0 : 1'bz);
// Gate A14-U147B
pullup(g42127);
assign #0.2  g42127 = rst ? 1'bz : ((0|g42128|g42126) ? 1'b0 : 1'bz);
// Gate A14-U210A A14-U211B
pullup(XB7_);
assign #0.2  XB7_ = rst ? 1'bz : ((0|XB7) ? 1'b0 : 1'bz);
// Gate A14-U249A
pullup(XT4E);
assign #0.2  XT4E = rst ? 0 : ((0|XT4_) ? 1'b0 : 1'bz);
// Gate A14-U251B
pullup(XT5);
assign #0.2  XT5 = rst ? 0 : ((0|S05|S06_|S04_) ? 1'b0 : 1'bz);
// Gate A14-U252A
pullup(XT4);
assign #0.2  XT4 = rst ? 0 : ((0|S05|S04|S06_) ? 1'b0 : 1'bz);
// Gate A14-U256B
pullup(XT2);
assign #0.2  XT2 = rst ? 0 : ((0|S05_|S06|S04) ? 1'b0 : 1'bz);
// Gate A14-U259A
pullup(XT1);
assign #0.2  XT1 = rst ? 0 : ((0|S05|S06|S04_) ? 1'b0 : 1'bz);
// Gate A14-U202B
pullup(RILP1_);
assign #0.2  RILP1_ = rst ? 0 : ((0|RILP1) ? 1'b0 : 1'bz);
// Gate A14-U133A
pullup(WHOMPA);
assign #0.2  WHOMPA = rst ? 0 : ((0|WHOMP_) ? 1'b0 : 1'bz);
// Gate A14-U123B
pullup(g42216);
assign #0.2  g42216 = rst ? 0 : ((0|FNERAS_|PHS3_|T10_) ? 1'b0 : 1'bz);
// Gate A14-U159B
pullup(g42103);
assign #0.2  g42103 = rst ? 0 : ((0|PHS3_|T08_) ? 1'b0 : 1'bz);
// Gate A14-U121A
pullup(RSTK_);
assign #0.2  RSTK_ = rst ? 1'bz : ((0|g42216|g42218) ? 1'b0 : 1'bz);
// Gate A14-U218A
pullup(XB5);
assign #0.2  XB5 = rst ? 0 : ((0|S02|S01_|S03_) ? 1'b0 : 1'bz);
// Gate A14-U212B
pullup(XB7E);
assign #0.2  XB7E = rst ? 0 : ((0|XB7_) ? 1'b0 : 1'bz);
// Gate A14-U252B A14-U251A
pullup(XT4_);
assign #0.2  XT4_ = rst ? 1'bz : ((0|XT4) ? 1'b0 : 1'bz);
// Gate A14-U231A
pullup(CXB1_);
assign #0.2  CXB1_ = rst ? 0 : ((0|XB1) ? 1'b0 : 1'bz);
// Gate A14-U231B
pullup(NOTEST);
assign #0.2  NOTEST = rst ? 1'bz : ((0|NOTEST_) ? 1'b0 : 1'bz);
// Gate A14-U122A
pullup(g42217);
assign #0.2  g42217 = rst ? 0 : ((0|FNERAS_|T10_) ? 1'b0 : 1'bz);
// Gate A14-U120B
pullup(g42220);
assign #0.2  g42220 = rst ? 0 : ((0|g42221|T01|TIMR) ? 1'b0 : 1'bz);
// Gate A14-U132A
pullup(g42155);
assign #0.2  g42155 = rst ? 1'bz : ((0|g42156|g42154) ? 1'b0 : 1'bz);
// Gate A14-U132B
pullup(g42154);
assign #0.2  g42154 = rst ? 0 : ((0|ROP_|T10_) ? 1'b0 : 1'bz);
// Gate A14-U133B
pullup(g42156);
assign #0.2  g42156 = rst ? 0 : ((0|g42155|GOJAM|T03) ? 1'b0 : 1'bz);
// Gate A14-U260A A14-U259B
pullup(XT0_);
assign #0.2  XT0_ = rst ? 0 : ((0|XT0) ? 1'b0 : 1'bz);
// Gate A14-U125A
pullup(g42211);
assign #0.2  g42211 = rst ? 0 : ((0|T10|g42212) ? 1'b0 : 1'bz);
// Gate A14-U125B
pullup(g42212);
assign #0.2  g42212 = rst ? 1'bz : ((0|g42216|g42213) ? 1'b0 : 1'bz);
// Gate A14-U148A
pullup(g42125);
assign #0.2  g42125 = rst ? 0 : ((0|T07_|PHS3_) ? 1'b0 : 1'bz);
// Gate A14-U124A
pullup(g42213);
assign #0.2  g42213 = rst ? 0 : ((0|T11|TIMR|g42212) ? 1'b0 : 1'bz);
// Gate A14-U118B
pullup(g42226);
assign #0.2  g42226 = rst ? 0 : ((0|FNERAS_|GOJAM|T12A) ? 1'b0 : 1'bz);
// Gate A14-U220A
pullup(XB4);
assign #0.2  XB4 = rst ? 0 : ((0|S01|S02|S03_) ? 1'b0 : 1'bz);
// Gate A14-U153A
pullup(g42114);
assign #0.2  g42114 = rst ? 0 : ((0|S09|g42112) ? 1'b0 : 1'bz);
// Gate A14-U149B
pullup(g42123);
assign #0.2  g42123 = rst ? 1'bz : ((0|STBF|SBFSET) ? 1'b0 : 1'bz);
// Gate A14-U238B
pullup(SBYREL_);
assign #0.2  SBYREL_ = rst ? 1'bz : ((0|SBY) ? 1'b0 : 1'bz);
// Gate A14-U124B
pullup(g42214);
assign #0.2  g42214 = rst ? 0 : ((0|T10_|FNERAS_|PHS4_) ? 1'b0 : 1'bz);
// Gate A14-U138B
pullup(g42145);
assign #0.2  g42145 = rst ? 1'bz : ((0|STRGAT|g42144) ? 1'b0 : 1'bz);
// Gate A14-U213B A14-U214A A14-U214B
pullup(XB6_);
assign #0.2  XB6_ = rst ? 1'bz : ((0|XB6) ? 1'b0 : 1'bz);
// Gate A14-U207B
pullup(YB1_);
assign #0.2  YB1_ = rst ? 1'bz : ((0|YB1) ? 1'b0 : 1'bz);
// Gate A14-U247A
pullup(XT6_);
assign #0.2  XT6_ = rst ? 1'bz : ((0|XT6) ? 1'b0 : 1'bz);
// Gate A14-U117B
pullup(g42224);
assign #0.2  g42224 = rst ? 0 : ((0|T05_|ERAS_) ? 1'b0 : 1'bz);
// Gate A14-U253A A14-U253B A14-U250A
pullup(XT3_);
assign #0.2  XT3_ = rst ? 1'bz : ((0|g42413) ? 1'b0 : 1'bz);
// Gate A14-U108B
pullup(g42243);
assign #0.2  g42243 = rst ? 1'bz : ((0|g42242|T06) ? 1'b0 : 1'bz);
// Gate A14-U240A
pullup(g42435);
assign #0.2  g42435 = rst ? 1'bz : ((0|g42433) ? 1'b0 : 1'bz);
// Gate A14-U241A
pullup(g42440);
assign #0.2  g42440 = rst ? 1'bz : ((0|XB3|XB0) ? 1'b0 : 1'bz);
// Gate A14-U150B
pullup(SBF);
assign #0.2  SBF = rst ? 0 : ((0|g42123) ? 1'b0 : 1'bz);
// Gate A14-U101A
pullup(g42244);
assign #0.2  g42244 = rst ? 0 : ((0|PHS3_|T05_) ? 1'b0 : 1'bz);
// Gate A14-U105B
pullup(SBE);
assign #0.2  SBE = rst ? 0 : ((0|g42246) ? 1'b0 : 1'bz);
// Gate A14-U212A
pullup(XB6E);
assign #0.2  XB6E = rst ? 0 : ((0|XB6_) ? 1'b0 : 1'bz);
// Gate A14-U120A
pullup(g42221);
assign #0.2  g42221 = rst ? 1'bz : ((0|g42217|g42220) ? 1'b0 : 1'bz);
// Gate A14-U156A
pullup(IHENV);
assign #0.2  IHENV = rst ? 0 : ((0|g42107) ? 1'b0 : 1'bz);
// Gate A14-U101B
pullup(g42242);
assign #0.2  g42242 = rst ? 0 : ((0|g42243|g42244) ? 1'b0 : 1'bz);
// Gate A14-U208A
pullup(YB1E);
assign #0.2  YB1E = rst ? 0 : ((0|YB1_) ? 1'b0 : 1'bz);
// Gate A14-U216B
pullup(XB5E);
assign #0.2  XB5E = rst ? 0 : ((0|XB5_) ? 1'b0 : 1'bz);
// Gate A14-U204B
pullup(YB3);
assign #0.2  YB3 = rst ? 0 : ((0|S08_|S07_) ? 1'b0 : 1'bz);
// Gate A14-U110B
pullup(g42240);
assign #0.2  g42240 = rst ? 0 : ((0|ERAS_|PHS4_|T03_) ? 1'b0 : 1'bz);
// Gate A14-U158A
pullup(g42106);
assign #0.2  g42106 = rst ? 0 : ((0|T08|ROP_|g42104) ? 1'b0 : 1'bz);
// Gate A14-U115B
pullup(g42232);
assign #0.2  g42232 = rst ? 0 : ((0|PHS3_|T06_) ? 1'b0 : 1'bz);
// Gate A14-U157A
pullup(g42109);
assign #0.2  g42109 = rst ? 0 : ((0|g42110|TIMR|g42107) ? 1'b0 : 1'bz);
// Gate A14-U145A
pullup(g42131);
assign #0.2  g42131 = rst ? 0 : ((0|S09|S08_|g42127) ? 1'b0 : 1'bz);
// Gate A14-U258B
pullup(XT1E);
assign #0.2  XT1E = rst ? 0 : ((0|XT1_) ? 1'b0 : 1'bz);
// Gate A14-U156B
pullup(g42158);
assign #0.2  g42158 = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A14-U137B
pullup(STRGAT);
assign #0.2  STRGAT = rst ? 0 : ((0|g42145|T08|GOJAM) ? 1'b0 : 1'bz);
// Gate A14-U108A
pullup(SBESET);
assign #0.2  SBESET = rst ? 0 : ((0|T04_|ERAS_|SCAD) ? 1'b0 : 1'bz);
// Gate A14-U241B
pullup(g42439);
assign #0.2  g42439 = rst ? 0 : ((0|g42441|g42435|RILP1_) ? 1'b0 : 1'bz);
// Gate A14-U155A
pullup(g42110);
assign #0.2  g42110 = rst ? 1'bz : ((0|T01_) ? 1'b0 : 1'bz);
// Gate A14-U248A
pullup(RB1);
assign #0.2  RB1 = rst ? 0 : ((0|RB1_) ? 1'b0 : 1'bz);
// Gate A14-U239A A14-U237B
pullup(g42443);
assign #0.2  g42443 = rst ? 0 : ((0|g42439|g42438|g42436|g43437) ? 1'b0 : 1'bz);
// Gate A14-U122B
pullup(NOTEST_);
assign #0.2  NOTEST_ = rst ? 0 : ((0|PSEUDO|NISQL_) ? 1'b0 : 1'bz);
// Gate A14-U236B
pullup(g42451);
assign #0.2  g42451 = rst ? 0 : ((0|SCAD_|WSC_) ? 1'b0 : 1'bz);
// Gate A14-U257A A14-U257B
pullup(XT1_);
assign #0.2  XT1_ = rst ? 1'bz : ((0|XT1) ? 1'b0 : 1'bz);
// Gate A14-U152A
pullup(SETAB_);
assign #0.2  SETAB_ = rst ? 1'bz : ((0|g42114) ? 1'b0 : 1'bz);
// Gate A14-U234A
pullup(g42448);
assign #0.2  g42448 = rst ? 0 : ((0|RSC_|SCAD_|RT_) ? 1'b0 : 1'bz);
// Gate A14-U208B
pullup(YB0E);
assign #0.2  YB0E = rst ? 0 : ((0|YB0_) ? 1'b0 : 1'bz);
// Gate A14-U260B
pullup(XT0);
assign #0.2  XT0 = rst ? 1'bz : ((0|S04|S06|S05) ? 1'b0 : 1'bz);
// Gate A14-U154B
pullup(g42113);
assign #0.2  g42113 = rst ? 0 : ((0|ROP_|PHS4_|T10_) ? 1'b0 : 1'bz);
// Gate A14-U118A
pullup(FNERAS_);
assign #0.2  FNERAS_ = rst ? 1'bz : ((0|g42224|g42226) ? 1'b0 : 1'bz);
// Gate A14-U107A A14-U105A
pullup(TPGE);
assign #0.2  TPGE = rst ? 0 : ((0|SCAD|GOJAM|ERAS_|PHS3_|T05_) ? 1'b0 : 1'bz);
// Gate A14-U227A
pullup(XB1E);
assign #0.2  XB1E = rst ? 1'bz : ((0|XB1_) ? 1'b0 : 1'bz);
// Gate A14-U139B A14-U140A A14-U140B
pullup(TPGF);
assign #0.2  TPGF = rst ? 0 : ((0|T08_|DV3764|ROP_|TCSAJ3|GOJAM|GOJ1|PHS2_|MP1) ? 1'b0 : 1'bz);
// Gate A14-U158B
pullup(g42105);
assign #0.2  g42105 = rst ? 0 : ((0|g42104|T09|GOJAM) ? 1'b0 : 1'bz);
// Gate A14-U209B
pullup(YB0_);
assign #0.2  YB0_ = rst ? 1'bz : ((0|YB0) ? 1'b0 : 1'bz);
// Gate A14-U159A
pullup(g42104);
assign #0.2  g42104 = rst ? 1'bz : ((0|g42103|g42105) ? 1'b0 : 1'bz);
// Gate A14-U249B
pullup(XT5E);
assign #0.2  XT5E = rst ? 0 : ((0|XT5_) ? 1'b0 : 1'bz);
// Gate A14-U151B
pullup(SETAB);
assign #0.2  SETAB = rst ? 0 : ((0|SETAB_) ? 1'b0 : 1'bz);
// Gate A14-U217B A14-U219A A14-U219B
pullup(XB4_);
assign #0.2  XB4_ = rst ? 1'bz : ((0|XB4) ? 1'b0 : 1'bz);
// Gate A14-U150A A14-U149A
pullup(SBFSET);
assign #0.2  SBFSET = rst ? 0 : ((0|T06_|DV3764|ROP_|PHS4_|MNHSBF|MP1) ? 1'b0 : 1'bz);
// Gate A14-U128A
pullup(g42205);
assign #0.2  g42205 = rst ? 0 : ((0|g42204|g42206|TIMR) ? 1'b0 : 1'bz);
// Gate A14-U246A
pullup(XT6E);
assign #0.2  XT6E = rst ? 0 : ((0|XT6_) ? 1'b0 : 1'bz);
// Gate A14-U129B
pullup(g42204);
assign #0.2  g42204 = rst ? 0 : ((0|g42202|T12A) ? 1'b0 : 1'bz);
// Gate A14-U153B
pullup(g42115);
assign #0.2  g42115 = rst ? 0 : ((0|g42112|S09_) ? 1'b0 : 1'bz);
// Gate A14-U127B
pullup(g42210);
assign #0.2  g42210 = rst ? 0 : ((0|g42204|g42209|TIMR) ? 1'b0 : 1'bz);
// Gate A14-U250B
pullup(XT5_);
assign #0.2  XT5_ = rst ? 1'bz : ((0|XT5) ? 1'b0 : 1'bz);
// Gate A14-U242B
pullup(g42438);
assign #0.2  g42438 = rst ? 1'bz : ((0|g42442|g42433|RILP1_) ? 1'b0 : 1'bz);
// Gate A14-U216A
pullup(XB4E);
assign #0.2  XB4E = rst ? 0 : ((0|XB4_) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
