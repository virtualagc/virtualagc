// Verilog module auto-generated for AGC module A14 by dumbVerilog.py

module A14 ( 
  rst, BR12B, CGA14, CHINC, CLEARA, CLEARB, CLEARC, CLEARD, DV3764, GOJ1,
  GOJAM, INOUT, MAMU, MNHSBF, MP1, NISQL_, PHS2_, PHS3_, PHS4_, PSEUDO, R1C_,
  RB1_, RSC_, RT_, S01, S01_, S02, S02_, S03, S03_, S04, S04_, S05, S05_,
  S06, S06_, S07, S07_, S08, S08_, S09, S09_, S11, S12, SBY, SCAD, SCAD_,
  STRT2, T01, T01_, T02_, T03, T03_, T04_, T05, T05_, T06, T06_, T07, T07_,
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
  GOJ1, GOJAM, INOUT, MAMU, MNHSBF, MP1, NISQL_, PHS2_, PHS3_, PHS4_, PSEUDO,
  R1C_, RB1_, RSC_, RT_, S01, S01_, S02, S02_, S03, S03_, S04, S04_, S05,
  S05_, S06, S06_, S07, S07_, S08, S08_, S09, S09_, S11, S12, SBY, SCAD,
  SCAD_, STRT2, T01, T01_, T02_, T03, T03_, T04_, T05, T05_, T06, T06_, T07,
  T07_, T08, T08_, T09, T10, T10_, T11, T12A, T12_, TCSAJ3, TIMR, WHOMP_,
  WL11, WL16, WSC_;

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

parameter GATE_DELAY = 20; // This default may be overridden at compile time.
initial $display("Gate delay (A14) will be %f ns.", GATE_DELAY);

// Gate A14-U129A
pullup(g42201);
assign #GATE_DELAY g42201 = rst ? 0 : ((0|PHS3_|T12_) ? 1'b0 : 1'bz);
// Gate A14-U129B
pullup(g42204);
assign #GATE_DELAY g42204 = rst ? 0 : ((0|g42202|T12A) ? 1'b0 : 1'bz);
// Gate A14-U128A
pullup(g42205);
assign #GATE_DELAY g42205 = rst ? 0 : ((0|TIMR|g42206|g42204) ? 1'b0 : 1'bz);
// Gate A14-U128B
pullup(g42206);
assign #GATE_DELAY g42206 = rst ? 1'bz : ((0|g42211|g42205) ? 1'b0 : 1'bz);
// Gate A14-U123A
pullup(g42215);
assign #GATE_DELAY g42215 = rst ? 0 : ((0|T02_|PHS4_) ? 1'b0 : 1'bz);
// Gate A14-U123B
pullup(g42216);
assign #GATE_DELAY g42216 = rst ? 0 : ((0|FNERAS_|PHS3_|T10_) ? 1'b0 : 1'bz);
// Gate A14-U122A
pullup(g42217);
assign #GATE_DELAY g42217 = rst ? 0 : ((0|T10_|FNERAS_) ? 1'b0 : 1'bz);
// Gate A14-U122B
pullup(NOTEST_);
assign #GATE_DELAY NOTEST_ = rst ? 0 : ((0|PSEUDO|NISQL_) ? 1'b0 : 1'bz);
// Gate A14-U121A
pullup(RSTK_);
assign #GATE_DELAY RSTK_ = rst ? 1'bz : ((0|g42218|g42216) ? 1'b0 : 1'bz);
// Gate A14-U121B
pullup(g42218);
assign #GATE_DELAY g42218 = rst ? 0 : ((0|g42215|TIMR|RSTK_) ? 1'b0 : 1'bz);
// Gate A14-U120A
pullup(g42221);
assign #GATE_DELAY g42221 = rst ? 1'bz : ((0|g42220|g42217) ? 1'b0 : 1'bz);
// Gate A14-U120B
pullup(g42220);
assign #GATE_DELAY g42220 = rst ? 0 : ((0|g42221|T01|TIMR) ? 1'b0 : 1'bz);
// Gate A14-U127A
pullup(g42209);
assign #GATE_DELAY g42209 = rst ? 1'bz : ((0|g42210|g42214) ? 1'b0 : 1'bz);
// Gate A14-U127B
pullup(g42210);
assign #GATE_DELAY g42210 = rst ? 0 : ((0|g42204|g42209|TIMR) ? 1'b0 : 1'bz);
// Gate A14-U125A
pullup(g42211);
assign #GATE_DELAY g42211 = rst ? 0 : ((0|g42212|T10) ? 1'b0 : 1'bz);
// Gate A14-U125B
pullup(g42212);
assign #GATE_DELAY g42212 = rst ? 1'bz : ((0|g42216|g42213) ? 1'b0 : 1'bz);
// Gate A14-U124A
pullup(g42213);
assign #GATE_DELAY g42213 = rst ? 0 : ((0|g42212|TIMR|T11) ? 1'b0 : 1'bz);
// Gate A14-U124B
pullup(g42214);
assign #GATE_DELAY g42214 = rst ? 0 : ((0|T10_|FNERAS_|PHS4_) ? 1'b0 : 1'bz);
// Gate A14-U138A
pullup(g42144);
assign #GATE_DELAY g42144 = rst ? 0 : ((0|T02_|ROP_) ? 1'b0 : 1'bz);
// Gate A14-U138B
pullup(g42145);
assign #GATE_DELAY g42145 = rst ? 1'bz : ((0|STRGAT|g42144) ? 1'b0 : 1'bz);
// Gate A14-U139A
pullup(g42138);
assign #GATE_DELAY g42138 = rst ? 1'bz : ((0|CLEARD|g42137) ? 1'b0 : 1'bz);
// Gate A14-U139B A14-U140A A14-U140B
pullup(TPGF);
assign #GATE_DELAY TPGF = rst ? 0 : ((0|T08_|DV3764|ROP_|GOJ1|GOJAM|TCSAJ3|PHS2_|MP1) ? 1'b0 : 1'bz);
// Gate A14-U130A
pullup(g42202);
assign #GATE_DELAY g42202 = rst ? 0 : ((0|g42201|g42203) ? 1'b0 : 1'bz);
// Gate A14-U130B
pullup(g42203);
assign #GATE_DELAY g42203 = rst ? 1'bz : ((0|g42202|T01) ? 1'b0 : 1'bz);
// Gate A14-U132A
pullup(g42155);
assign #GATE_DELAY g42155 = rst ? 1'bz : ((0|g42154|g42156) ? 1'b0 : 1'bz);
// Gate A14-U132B
pullup(g42154);
assign #GATE_DELAY g42154 = rst ? 0 : ((0|ROP_|T10_) ? 1'b0 : 1'bz);
// Gate A14-U133A
pullup(WHOMPA);
assign #GATE_DELAY WHOMPA = rst ? 0 : ((0|WHOMP_) ? 1'b0 : 1'bz);
// Gate A14-U133B
pullup(g42156);
assign #GATE_DELAY g42156 = rst ? 0 : ((0|g42155|GOJAM|T03) ? 1'b0 : 1'bz);
// Gate A14-U135A A14-U135B
pullup(g42149);
assign #GATE_DELAY g42149 = rst ? 1'bz : ((0|g42148|g42151) ? 1'b0 : 1'bz);
// Gate A14-U136A
pullup(g42151);
assign #GATE_DELAY g42151 = rst ? 0 : ((0|g42149|T07|GOJAM) ? 1'b0 : 1'bz);
// Gate A14-U136B
pullup(g42148);
assign #GATE_DELAY g42148 = rst ? 0 : ((0|g42155|g42147|T02_) ? 1'b0 : 1'bz);
// Gate A14-U137A
pullup(g42147);
assign #GATE_DELAY g42147 = rst ? 1'bz : ((0|ROP_) ? 1'b0 : 1'bz);
// Gate A14-U137B
pullup(STRGAT);
assign #GATE_DELAY STRGAT = rst ? 0 : ((0|g42145|T08|GOJAM) ? 1'b0 : 1'bz);
// Gate A14-U156A
pullup(IHENV);
assign #GATE_DELAY IHENV = rst ? 0 : ((0|g42107) ? 1'b0 : 1'bz);
// Gate A14-U156B
pullup(g42158);
assign #GATE_DELAY g42158 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A14-U151A
pullup(SETCD);
assign #GATE_DELAY SETCD = rst ? 0 : ((0|SETCD_) ? 1'b0 : 1'bz);
// Gate A14-U151B
pullup(SETAB);
assign #GATE_DELAY SETAB = rst ? 0 : ((0|SETAB_) ? 1'b0 : 1'bz);
// Gate A14-U126A
pullup(WEX);
assign #GATE_DELAY WEX = rst ? 0 : ((0|g42206) ? 1'b0 : 1'bz);
// Gate A14-U126B
pullup(WEY);
assign #GATE_DELAY WEY = rst ? 0 : ((0|g42209) ? 1'b0 : 1'bz);
// Gate A14-U108A
pullup(SBESET);
assign #GATE_DELAY SBESET = rst ? 0 : ((0|SCAD|ERAS_|T04_) ? 1'b0 : 1'bz);
// Gate A14-U108B
pullup(g42243);
assign #GATE_DELAY g42243 = rst ? 0 : ((0|g42242|T06) ? 1'b0 : 1'bz);
// Gate A14-U104A A14-U104B
pullup(ERAS_);
assign #GATE_DELAY ERAS_ = rst ? 1'bz : ((0|ERAS) ? 1'b0 : 1'bz);
// Gate A14-U107A A14-U105A
pullup(TPGE);
assign #GATE_DELAY TPGE = rst ? 0 : ((0|ERAS_|GOJAM|SCAD|T05_|PHS3_) ? 1'b0 : 1'bz);
// Gate A14-U107B
pullup(g42246);
assign #GATE_DELAY g42246 = rst ? 1'bz : ((0|STBE|SBESET) ? 1'b0 : 1'bz);
// Gate A14-U106A
pullup(TPARG_);
assign #GATE_DELAY TPARG_ = rst ? 1'bz : ((0|TPGF|TPGE) ? 1'b0 : 1'bz);
// Gate A14-U106B
pullup(STBE);
assign #GATE_DELAY STBE = rst ? 0 : ((0|g42246|GOJAM|T05) ? 1'b0 : 1'bz);
// Gate A14-U101A
pullup(g42244);
assign #GATE_DELAY g42244 = rst ? 0 : ((0|T05_|PHS3_) ? 1'b0 : 1'bz);
// Gate A14-U101B
pullup(g42242);
assign #GATE_DELAY g42242 = rst ? 1'bz : ((0|g42243|g42244) ? 1'b0 : 1'bz);
// Gate A14-U103B A14-U109A A14-U102B
pullup(ERAS);
assign #GATE_DELAY ERAS = rst ? 0 : ((0|S12|S11|TCSAJ3|MP1|MAMU|INOUT|GOJ1|CHINC) ? 1'b0 : 1'bz);
// Gate A14-U150A A14-U149A
pullup(SBFSET);
assign #GATE_DELAY SBFSET = rst ? 0 : ((0|ROP_|DV3764|T06_|MP1|MNHSBF|PHS4_) ? 1'b0 : 1'bz);
// Gate A14-U150B
pullup(SBF);
assign #GATE_DELAY SBF = rst ? 0 : ((0|g42123) ? 1'b0 : 1'bz);
// Gate A14-U112A
pullup(g42238);
assign #GATE_DELAY g42238 = rst ? 1'bz : ((0|g42240|g42239) ? 1'b0 : 1'bz);
// Gate A14-U112B
pullup(g42239);
assign #GATE_DELAY g42239 = rst ? 0 : ((0|GOJAM|REDRST|g42238) ? 1'b0 : 1'bz);
// Gate A14-U113A
pullup(g42235);
assign #GATE_DELAY g42235 = rst ? 0 : ((0|REDRST|g42234|GOJAM) ? 1'b0 : 1'bz);
// Gate A14-U113B
pullup(g42234);
assign #GATE_DELAY g42234 = rst ? 1'bz : ((0|g42235|g42233) ? 1'b0 : 1'bz);
// Gate A14-U110A
pullup(REDRST);
assign #GATE_DELAY REDRST = rst ? 0 : ((0|g42242|T05) ? 1'b0 : 1'bz);
// Gate A14-U110B
pullup(g42240);
assign #GATE_DELAY g42240 = rst ? 0 : ((0|ERAS_|PHS4_|T03_) ? 1'b0 : 1'bz);
// Gate A14-U116A
pullup(g42229);
assign #GATE_DELAY g42229 = rst ? 0 : ((0|g42232|g42228|GOJAM) ? 1'b0 : 1'bz);
// Gate A14-U116B
pullup(g42228);
assign #GATE_DELAY g42228 = rst ? 1'bz : ((0|g42229|g42227) ? 1'b0 : 1'bz);
// Gate A14-U117A
pullup(g42227);
assign #GATE_DELAY g42227 = rst ? 0 : ((0|ERAS_|T03_) ? 1'b0 : 1'bz);
// Gate A14-U117B
pullup(g42224);
assign #GATE_DELAY g42224 = rst ? 0 : ((0|T05_|ERAS_) ? 1'b0 : 1'bz);
// Gate A14-U115A
pullup(g42233);
assign #GATE_DELAY g42233 = rst ? 0 : ((0|T03_|ERAS_|PHS3_) ? 1'b0 : 1'bz);
// Gate A14-U115B
pullup(g42232);
assign #GATE_DELAY g42232 = rst ? 0 : ((0|PHS3_|T06_) ? 1'b0 : 1'bz);
// Gate A14-U118A
pullup(FNERAS_);
assign #GATE_DELAY FNERAS_ = rst ? 1'bz : ((0|g42226|g42224) ? 1'b0 : 1'bz);
// Gate A14-U118B
pullup(g42226);
assign #GATE_DELAY g42226 = rst ? 0 : ((0|FNERAS_|GOJAM|T12A) ? 1'b0 : 1'bz);
// Gate A14-U144A
pullup(RESETB);
assign #GATE_DELAY RESETB = rst ? 0 : ((0|g42132) ? 1'b0 : 1'bz);
// Gate A14-U144B
pullup(RESETA);
assign #GATE_DELAY RESETA = rst ? 0 : ((0|g42130) ? 1'b0 : 1'bz);
// Gate A14-U111A
pullup(REX);
assign #GATE_DELAY REX = rst ? 0 : ((0|g42238) ? 1'b0 : 1'bz);
// Gate A14-U111B
pullup(REY);
assign #GATE_DELAY REY = rst ? 0 : ((0|g42234) ? 1'b0 : 1'bz);
// Gate A14-U141A
pullup(RESETD);
assign #GATE_DELAY RESETD = rst ? 0 : ((0|g42138) ? 1'b0 : 1'bz);
// Gate A14-U141B
pullup(RESETC);
assign #GATE_DELAY RESETC = rst ? 0 : ((0|g42136) ? 1'b0 : 1'bz);
// Gate A14-U160A A14-U160B
pullup(ROP_);
assign #GATE_DELAY ROP_ = rst ? 0 : ((0|S12|S11) ? 1'b0 : 1'bz);
// Gate A14-U114A A14-U114B
pullup(SETEK);
assign #GATE_DELAY SETEK = rst ? 0 : ((0|STRT2|g42228) ? 1'b0 : 1'bz);
// Gate A14-U149B
pullup(g42123);
assign #GATE_DELAY g42123 = rst ? 1'bz : ((0|STBF|SBFSET) ? 1'b0 : 1'bz);
// Gate A14-U148A
pullup(g42125);
assign #GATE_DELAY g42125 = rst ? 0 : ((0|PHS3_|T07_) ? 1'b0 : 1'bz);
// Gate A14-U148B
pullup(STBF);
assign #GATE_DELAY STBF = rst ? 0 : ((0|GOJAM|g42125|g42123) ? 1'b0 : 1'bz);
// Gate A14-U134A A14-U134B
pullup(CLROPE);
assign #GATE_DELAY CLROPE = rst ? 0 : ((0|g42149) ? 1'b0 : 1'bz);
// Gate A14-U143A
pullup(g42132);
assign #GATE_DELAY g42132 = rst ? 1'bz : ((0|CLEARB|g42131) ? 1'b0 : 1'bz);
// Gate A14-U143B
pullup(g42135);
assign #GATE_DELAY g42135 = rst ? 0 : ((0|S09_|g42127|S08) ? 1'b0 : 1'bz);
// Gate A14-U142A
pullup(g42136);
assign #GATE_DELAY g42136 = rst ? 1'bz : ((0|CLEARC|g42135) ? 1'b0 : 1'bz);
// Gate A14-U142B
pullup(g42137);
assign #GATE_DELAY g42137 = rst ? 0 : ((0|g42127|S09_|S08_) ? 1'b0 : 1'bz);
// Gate A14-U145A
pullup(g42131);
assign #GATE_DELAY g42131 = rst ? 0 : ((0|g42127|S08_|S09) ? 1'b0 : 1'bz);
// Gate A14-U145B
pullup(g42130);
assign #GATE_DELAY g42130 = rst ? 1'bz : ((0|CLEARA|g42129) ? 1'b0 : 1'bz);
// Gate A14-U147A
pullup(g42126);
assign #GATE_DELAY g42126 = rst ? 0 : ((0|g42127|GOJAM|T08) ? 1'b0 : 1'bz);
// Gate A14-U147B
pullup(g42127);
assign #GATE_DELAY g42127 = rst ? 1'bz : ((0|g42128|g42126) ? 1'b0 : 1'bz);
// Gate A14-U146A
pullup(g42128);
assign #GATE_DELAY g42128 = rst ? 0 : ((0|ROP_|T05_|PHS3_) ? 1'b0 : 1'bz);
// Gate A14-U146B
pullup(g42129);
assign #GATE_DELAY g42129 = rst ? 0 : ((0|S08|g42127|S09) ? 1'b0 : 1'bz);
// Gate A14-U105B
pullup(SBE);
assign #GATE_DELAY SBE = rst ? 0 : ((0|g42246) ? 1'b0 : 1'bz);
// Gate A14-U119A A14-U119B
pullup(ZID);
assign #GATE_DELAY ZID = rst ? 0 : ((0|STRT2|g42221) ? 1'b0 : 1'bz);
// Gate A14-U158A
pullup(g42106);
assign #GATE_DELAY g42106 = rst ? 0 : ((0|g42104|ROP_|T08) ? 1'b0 : 1'bz);
// Gate A14-U158B
pullup(g42105);
assign #GATE_DELAY g42105 = rst ? 0 : ((0|g42104|T09|GOJAM) ? 1'b0 : 1'bz);
// Gate A14-U159A
pullup(g42104);
assign #GATE_DELAY g42104 = rst ? 1'bz : ((0|g42105|g42103) ? 1'b0 : 1'bz);
// Gate A14-U159B
pullup(g42103);
assign #GATE_DELAY g42103 = rst ? 0 : ((0|PHS3_|T08_) ? 1'b0 : 1'bz);
// Gate A14-U157A
pullup(g42109);
assign #GATE_DELAY g42109 = rst ? 0 : ((0|g42107|TIMR|g42110) ? 1'b0 : 1'bz);
// Gate A14-U157B
pullup(g42107);
assign #GATE_DELAY g42107 = rst ? 1'bz : ((0|g42109|g42106) ? 1'b0 : 1'bz);
// Gate A14-U154A
pullup(g42112);
assign #GATE_DELAY g42112 = rst ? 1'bz : ((0|g42113|g42111) ? 1'b0 : 1'bz);
// Gate A14-U154B
pullup(g42113);
assign #GATE_DELAY g42113 = rst ? 0 : ((0|ROP_|PHS4_|T10_) ? 1'b0 : 1'bz);
// Gate A14-U155A
pullup(g42110);
assign #GATE_DELAY g42110 = rst ? 0 : ((0|T01_) ? 1'b0 : 1'bz);
// Gate A14-U155B
pullup(g42111);
assign #GATE_DELAY g42111 = rst ? 0 : ((0|g42112|g42110|TIMR) ? 1'b0 : 1'bz);
// Gate A14-U152A
pullup(SETAB_);
assign #GATE_DELAY SETAB_ = rst ? 1'bz : ((0|g42114) ? 1'b0 : 1'bz);
// Gate A14-U152B
pullup(SETCD_);
assign #GATE_DELAY SETCD_ = rst ? 1'bz : ((0|g42115) ? 1'b0 : 1'bz);
// Gate A14-U153A
pullup(g42114);
assign #GATE_DELAY g42114 = rst ? 0 : ((0|g42112|S09) ? 1'b0 : 1'bz);
// Gate A14-U153B
pullup(g42115);
assign #GATE_DELAY g42115 = rst ? 0 : ((0|g42112|S09_) ? 1'b0 : 1'bz);
// Gate A14-U227A
pullup(XB1E);
assign #GATE_DELAY XB1E = rst ? 0 : ((0|XB1_) ? 1'b0 : 1'bz);
// Gate A14-U227B
pullup(XB0E);
assign #GATE_DELAY XB0E = rst ? 0 : ((0|XB0_) ? 1'b0 : 1'bz);
// Gate A14-U222A
pullup(XB2E);
assign #GATE_DELAY XB2E = rst ? 0 : ((0|XB2_) ? 1'b0 : 1'bz);
// Gate A14-U222B
pullup(XB3E);
assign #GATE_DELAY XB3E = rst ? 0 : ((0|XB3_) ? 1'b0 : 1'bz);
// Gate A14-U229A A14-U229B A14-U228A A14-U230A
pullup(XB0_);
assign #GATE_DELAY XB0_ = rst ? 1'bz : ((0|XB0) ? 1'b0 : 1'bz);
// Gate A14-U228B
pullup(XB1);
assign #GATE_DELAY XB1 = rst ? 0 : ((0|S01_|S02|S03) ? 1'b0 : 1'bz);
// Gate A14-U223A
pullup(XB3);
assign #GATE_DELAY XB3 = rst ? 0 : ((0|S02_|S01_|S03) ? 1'b0 : 1'bz);
// Gate A14-U223B A14-U224A A14-U224B
pullup(XB2_);
assign #GATE_DELAY XB2_ = rst ? 1'bz : ((0|XB2) ? 1'b0 : 1'bz);
// Gate A14-U221A A14-U221B A14-U220B
pullup(XB3_);
assign #GATE_DELAY XB3_ = rst ? 1'bz : ((0|XB3) ? 1'b0 : 1'bz);
// Gate A14-U220A
pullup(XB4);
assign #GATE_DELAY XB4 = rst ? 0 : ((0|S03_|S02|S01) ? 1'b0 : 1'bz);
// Gate A14-U226A A14-U226B A14-U225B
pullup(XB1_);
assign #GATE_DELAY XB1_ = rst ? 1'bz : ((0|XB1) ? 1'b0 : 1'bz);
// Gate A14-U225A
pullup(XB2);
assign #GATE_DELAY XB2 = rst ? 0 : ((0|S02_|S03|S01) ? 1'b0 : 1'bz);
// Gate A14-U238A
pullup(ILP);
assign #GATE_DELAY ILP = rst ? 0 : ((0|g42445) ? 1'b0 : 1'bz);
// Gate A14-U238B
pullup(SBYREL_);
assign #GATE_DELAY SBYREL_ = rst ? 1'bz : ((0|SBY) ? 1'b0 : 1'bz);
// Gate A14-U239A A14-U237B
pullup(g42443);
assign #GATE_DELAY g42443 = rst ? 0 : ((0|g42438|g42439|g42436|g43437) ? 1'b0 : 1'bz);
// Gate A14-U239B
pullup(ILP_);
assign #GATE_DELAY ILP_ = rst ? 1'bz : ((0|g42443) ? 1'b0 : 1'bz);
// Gate A14-U230B
pullup(XB0);
assign #GATE_DELAY XB0 = rst ? 0 : ((0|S03|S02|S01) ? 1'b0 : 1'bz);
// Gate A14-U231A
pullup(CXB1_);
assign #GATE_DELAY CXB1_ = rst ? 1'bz : ((0|XB1) ? 1'b0 : 1'bz);
// Gate A14-U231B
pullup(NOTEST);
assign #GATE_DELAY NOTEST = rst ? 1'bz : ((0|NOTEST_) ? 1'b0 : 1'bz);
// Gate A14-U232A A14-U233A A14-U233B
pullup(R1C);
assign #GATE_DELAY R1C = rst ? 0 : ((0|R1C_) ? 1'b0 : 1'bz);
// Gate A14-U232B
pullup(BR12B_);
assign #GATE_DELAY BR12B_ = rst ? 0 : ((0|BR12B) ? 1'b0 : 1'bz);
// Gate A14-U234A
pullup(g42448);
assign #GATE_DELAY g42448 = rst ? 0 : ((0|RT_|SCAD_|RSC_) ? 1'b0 : 1'bz);
// Gate A14-U234B A14-U235B
pullup(WSCG_);
assign #GATE_DELAY WSCG_ = rst ? 1'bz : ((0|g42451) ? 1'b0 : 1'bz);
// Gate A14-U235A A14-U236A
pullup(RSCG_);
assign #GATE_DELAY RSCG_ = rst ? 1'bz : ((0|g42448) ? 1'b0 : 1'bz);
// Gate A14-U236B
pullup(g42451);
assign #GATE_DELAY g42451 = rst ? 0 : ((0|SCAD_|WSC_) ? 1'b0 : 1'bz);
// Gate A14-U237A
pullup(g42445);
assign #GATE_DELAY g42445 = rst ? 1'bz : ((0|g42443) ? 1'b0 : 1'bz);
// Gate A14-U246A
pullup(XT6E);
assign #GATE_DELAY XT6E = rst ? 0 : ((0|XT6_) ? 1'b0 : 1'bz);
// Gate A14-U246B
pullup(XT7E);
assign #GATE_DELAY XT7E = rst ? 1'bz : ((0|XT7_) ? 1'b0 : 1'bz);
// Gate A14-U243A A14-U244B
pullup(g42433);
assign #GATE_DELAY g42433 = rst ? 1'bz : ((0|XT5|XT6|XT0|XT3) ? 1'b0 : 1'bz);
// Gate A14-U243B A14-U241A
pullup(g42440);
assign #GATE_DELAY g42440 = rst ? 1'bz : ((0|XB6|XB5|XB0|XB3) ? 1'b0 : 1'bz);
// Gate A14-U249A
pullup(XT4E);
assign #GATE_DELAY XT4E = rst ? 0 : ((0|XT4_) ? 1'b0 : 1'bz);
// Gate A14-U249B
pullup(XT5E);
assign #GATE_DELAY XT5E = rst ? 0 : ((0|XT5_) ? 1'b0 : 1'bz);
// Gate A14-U209A
pullup(YB0);
assign #GATE_DELAY YB0 = rst ? 0 : ((0|S08|S07) ? 1'b0 : 1'bz);
// Gate A14-U209B
pullup(YB0_);
assign #GATE_DELAY YB0_ = rst ? 1'bz : ((0|YB0) ? 1'b0 : 1'bz);
// Gate A14-U205A
pullup(RILP1);
assign #GATE_DELAY RILP1 = rst ? 0 : ((0|YB3|YB0) ? 1'b0 : 1'bz);
// Gate A14-U205B
pullup(YB2_);
assign #GATE_DELAY YB2_ = rst ? 1'bz : ((0|YB2) ? 1'b0 : 1'bz);
// Gate A14-U204A
pullup(YB3_);
assign #GATE_DELAY YB3_ = rst ? 0 : ((0|YB3) ? 1'b0 : 1'bz);
// Gate A14-U204B
pullup(YB3);
assign #GATE_DELAY YB3 = rst ? 1'bz : ((0|S08_|S07_) ? 1'b0 : 1'bz);
// Gate A14-U207B
pullup(YB1_);
assign #GATE_DELAY YB1_ = rst ? 1'bz : ((0|YB1) ? 1'b0 : 1'bz);
// Gate A14-U206A
pullup(YB1);
assign #GATE_DELAY YB1 = rst ? 0 : ((0|S08|S07_) ? 1'b0 : 1'bz);
// Gate A14-U206B
pullup(YB2);
assign #GATE_DELAY YB2 = rst ? 0 : ((0|S07|S08_) ? 1'b0 : 1'bz);
// Gate A14-U202B
pullup(RILP1_);
assign #GATE_DELAY RILP1_ = rst ? 1'bz : ((0|RILP1) ? 1'b0 : 1'bz);
// Gate A14-U254A
pullup(XT2E);
assign #GATE_DELAY XT2E = rst ? 0 : ((0|XT2_) ? 1'b0 : 1'bz);
// Gate A14-U254B
pullup(XT3E);
assign #GATE_DELAY XT3E = rst ? 0 : ((0|XT3_) ? 1'b0 : 1'bz);
// Gate A14-U258A
pullup(XT0E);
assign #GATE_DELAY XT0E = rst ? 0 : ((0|XT0_) ? 1'b0 : 1'bz);
// Gate A14-U258B
pullup(XT1E);
assign #GATE_DELAY XT1E = rst ? 0 : ((0|XT1_) ? 1'b0 : 1'bz);
// Gate A14-U213A
pullup(XB7);
assign #GATE_DELAY XB7 = rst ? 1'bz : ((0|S01_|S02_|S03_) ? 1'b0 : 1'bz);
// Gate A14-U213B A14-U214A A14-U214B
pullup(XB6_);
assign #GATE_DELAY XB6_ = rst ? 1'bz : ((0|XB6) ? 1'b0 : 1'bz);
// Gate A14-U210A A14-U211B
pullup(XB7_);
assign #GATE_DELAY XB7_ = rst ? 0 : ((0|XB7) ? 1'b0 : 1'bz);
// Gate A14-U210B
pullup(WL11_);
assign #GATE_DELAY WL11_ = rst ? 1'bz : ((0|WL11) ? 1'b0 : 1'bz);
// Gate A14-U217A A14-U215A A14-U218B
pullup(XB5_);
assign #GATE_DELAY XB5_ = rst ? 1'bz : ((0|XB5) ? 1'b0 : 1'bz);
// Gate A14-U217B A14-U219A A14-U219B
pullup(XB4_);
assign #GATE_DELAY XB4_ = rst ? 1'bz : ((0|XB4) ? 1'b0 : 1'bz);
// Gate A14-U215B
pullup(XB6);
assign #GATE_DELAY XB6 = rst ? 0 : ((0|S02_|S03_|S01) ? 1'b0 : 1'bz);
// Gate A14-U260A A14-U259B
pullup(XT0_);
assign #GATE_DELAY XT0_ = rst ? 1'bz : ((0|XT0) ? 1'b0 : 1'bz);
// Gate A14-U260B
pullup(XT0);
assign #GATE_DELAY XT0 = rst ? 0 : ((0|S04|S06|S05) ? 1'b0 : 1'bz);
// Gate A14-U218A
pullup(XB5);
assign #GATE_DELAY XB5 = rst ? 0 : ((0|S03_|S01_|S02) ? 1'b0 : 1'bz);
// Gate A14-U208A
pullup(YB1E);
assign #GATE_DELAY YB1E = rst ? 0 : ((0|YB1_) ? 1'b0 : 1'bz);
// Gate A14-U208B
pullup(YB0E);
assign #GATE_DELAY YB0E = rst ? 0 : ((0|YB0_) ? 1'b0 : 1'bz);
// Gate A14-U203A
pullup(YB3E);
assign #GATE_DELAY YB3E = rst ? 1'bz : ((0|YB3_) ? 1'b0 : 1'bz);
// Gate A14-U203B
pullup(YB2E);
assign #GATE_DELAY YB2E = rst ? 0 : ((0|YB2_) ? 1'b0 : 1'bz);
// Gate A14-U248A
pullup(RB1);
assign #GATE_DELAY RB1 = rst ? 0 : ((0|RB1_) ? 1'b0 : 1'bz);
// Gate A14-U248B
pullup(XT6);
assign #GATE_DELAY XT6 = rst ? 0 : ((0|S05_|S06_|S04) ? 1'b0 : 1'bz);
// Gate A14-U241B
pullup(g42439);
assign #GATE_DELAY g42439 = rst ? 0 : ((0|g42440|g42435|RILP1_) ? 1'b0 : 1'bz);
// Gate A14-U240A
pullup(g42435);
assign #GATE_DELAY g42435 = rst ? 0 : ((0|g42433) ? 1'b0 : 1'bz);
// Gate A14-U240B
pullup(g42442);
assign #GATE_DELAY g42442 = rst ? 0 : ((0|g42440) ? 1'b0 : 1'bz);
// Gate A14-U242A
pullup(g43437);
assign #GATE_DELAY g43437 = rst ? 1'bz : ((0|g42435|g42442|RILP1) ? 1'b0 : 1'bz);
// Gate A14-U242B
pullup(g42438);
assign #GATE_DELAY g42438 = rst ? 0 : ((0|g42442|g42433|RILP1_) ? 1'b0 : 1'bz);
// Gate A14-U245A
pullup(XT7_);
assign #GATE_DELAY XT7_ = rst ? 0 : ((0|XT7) ? 1'b0 : 1'bz);
// Gate A14-U245B
pullup(WL16_);
assign #GATE_DELAY WL16_ = rst ? 1'bz : ((0|WL16) ? 1'b0 : 1'bz);
// Gate A14-U244A
pullup(g42436);
assign #GATE_DELAY g42436 = rst ? 0 : ((0|g42433|RILP1|g42440) ? 1'b0 : 1'bz);
// Gate A14-U247A
pullup(XT6_);
assign #GATE_DELAY XT6_ = rst ? 1'bz : ((0|XT6) ? 1'b0 : 1'bz);
// Gate A14-U247B
pullup(XT7);
assign #GATE_DELAY XT7 = rst ? 1'bz : ((0|S04_|S06_|S05_) ? 1'b0 : 1'bz);
// Gate A14-U212A
pullup(XB6E);
assign #GATE_DELAY XB6E = rst ? 0 : ((0|XB6_) ? 1'b0 : 1'bz);
// Gate A14-U212B
pullup(XB7E);
assign #GATE_DELAY XB7E = rst ? 1'bz : ((0|XB7_) ? 1'b0 : 1'bz);
// Gate A14-U216A
pullup(XB4E);
assign #GATE_DELAY XB4E = rst ? 0 : ((0|XB4_) ? 1'b0 : 1'bz);
// Gate A14-U216B
pullup(XB5E);
assign #GATE_DELAY XB5E = rst ? 0 : ((0|XB5_) ? 1'b0 : 1'bz);
// Gate A14-U259A
pullup(XT1);
assign #GATE_DELAY XT1 = rst ? 0 : ((0|S04_|S06|S05) ? 1'b0 : 1'bz);
// Gate A14-U256A A14-U255A
pullup(XT2_);
assign #GATE_DELAY XT2_ = rst ? 1'bz : ((0|XT2) ? 1'b0 : 1'bz);
// Gate A14-U256B
pullup(XT2);
assign #GATE_DELAY XT2 = rst ? 0 : ((0|S05_|S06|S04) ? 1'b0 : 1'bz);
// Gate A14-U257A A14-U257B
pullup(XT1_);
assign #GATE_DELAY XT1_ = rst ? 1'bz : ((0|XT1) ? 1'b0 : 1'bz);
// Gate A14-U255B
pullup(XT3);
assign #GATE_DELAY XT3 = rst ? 0 : ((0|S04_|S05_|S06) ? 1'b0 : 1'bz);
// Gate A14-U252A
pullup(XT4);
assign #GATE_DELAY XT4 = rst ? 0 : ((0|S06_|S04|S05) ? 1'b0 : 1'bz);
// Gate A14-U252B A14-U251A
pullup(XT4_);
assign #GATE_DELAY XT4_ = rst ? 1'bz : ((0|XT4) ? 1'b0 : 1'bz);
// Gate A14-U253A A14-U253B A14-U250A
pullup(XT3_);
assign #GATE_DELAY XT3_ = rst ? 1'bz : ((0|XT3) ? 1'b0 : 1'bz);
// Gate A14-U250B
pullup(XT5_);
assign #GATE_DELAY XT5_ = rst ? 1'bz : ((0|XT5) ? 1'b0 : 1'bz);
// Gate A14-U251B
pullup(XT5);
assign #GATE_DELAY XT5 = rst ? 0 : ((0|S05|S06_|S04_) ? 1'b0 : 1'bz);
// End of NOR gates


endmodule
