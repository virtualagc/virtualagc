// Verilog module auto-generated for AGC module A21 by dumbVerilog.py

module A21 ( 
  rst, ALTM, BMAGXM, BMAGXP, BMAGYM, BMAGYP, BMAGZM, BMAGZP, C24A, C25A,
  C26A, C27A, C30A, C31A, C32A, C33A, C34A, C35A, C36A, C37A, C40A, C41A,
  C50A, C51A, C52A, C53A, C54A, C55A, CA6_, CG13, CG23, CGA21, CT, CXB2_,
  CXB3_, CXB4_, CXB7_, DOSCAL, EMSD, FS17, GNHNC, GOJAM, GYROD, INLNKM, INLNKP,
  MLDCH, MLOAD, MNHNC, MRDCH, MREAD, NISQL_, OCTAD4, OCTAD5, OTLNKM, PHS2_,
  PHS3_, PHS4_, PSEUDO, RNRADM, RNRADP, RQ, RSCT_, ST0_, ST1_, STD2, T02_,
  T07_, T10_, T11_, T12A, T12_, XB0, XB5, XB6, BKTF_, C42A, C43A, C44A, C45A,
  C45M, C45P, C46A, C46M, C46P, C47A, C56A, C57A, C60A, CA4_, CA5_, CG15,
  CG16, CHINC, CHINC_, CTROR_, CXB0_, CXB5_, CXB6_, DINC, INCSET_, INKBT1,
  INOTLD, INOTRD, MINKL, MREQIN, RSSB, SCAS17, d32004K, C42M, C42P, C42R,
  C43M, C43P, C43R, C44M, C44P, C44R, C45R, C46R, C47R, C56R, C57R, C60R,
  CAD1, CAD2, CAD3, CAD4, CAD5, CAD6, CG26, CTROR, DINCNC_, DINC_, FETCH0,
  FETCH0_, FETCH1, INKL, INKL_, MON_, MONpCH, RQ_, SHANC, SHANC_, SHINC,
  SHINC_, STFET1_, STORE1, STORE1_, d30SUM, d50SUM
);

input wire rst, ALTM, BMAGXM, BMAGXP, BMAGYM, BMAGYP, BMAGZM, BMAGZP, C24A,
  C25A, C26A, C27A, C30A, C31A, C32A, C33A, C34A, C35A, C36A, C37A, C40A,
  C41A, C50A, C51A, C52A, C53A, C54A, C55A, CA6_, CG13, CG23, CGA21, CT,
  CXB2_, CXB3_, CXB4_, CXB7_, DOSCAL, EMSD, FS17, GNHNC, GOJAM, GYROD, INLNKM,
  INLNKP, MLDCH, MLOAD, MNHNC, MRDCH, MREAD, NISQL_, OCTAD4, OCTAD5, OTLNKM,
  PHS2_, PHS3_, PHS4_, PSEUDO, RNRADM, RNRADP, RQ, RSCT_, ST0_, ST1_, STD2,
  T02_, T07_, T10_, T11_, T12A, T12_, XB0, XB5, XB6;

inout wire BKTF_, C42A, C43A, C44A, C45A, C45M, C45P, C46A, C46M, C46P, C47A,
  C56A, C57A, C60A, CA4_, CA5_, CG15, CG16, CHINC, CHINC_, CTROR_, CXB0_,
  CXB5_, CXB6_, DINC, INCSET_, INKBT1, INOTLD, INOTRD, MINKL, MREQIN, RSSB,
  SCAS17, d32004K;

output wire C42M, C42P, C42R, C43M, C43P, C43R, C44M, C44P, C44R, C45R, C46R,
  C47R, C56R, C57R, C60R, CAD1, CAD2, CAD3, CAD4, CAD5, CAD6, CG26, CTROR,
  DINCNC_, DINC_, FETCH0, FETCH0_, FETCH1, INKL, INKL_, MON_, MONpCH, RQ_,
  SHANC, SHANC_, SHINC, SHINC_, STFET1_, STORE1, STORE1_, d30SUM, d50SUM;

parameter GATE_DELAY = 20; // This default may be overridden at compile time.
initial $display("Gate delay (A21) will be %f ns.", GATE_DELAY);

// Gate A21-U137A A21-U138A A21-U139B
pullup(g32056);
assign #GATE_DELAY g32056 = rst ? 1'bz : ((0|C46M|C45M|C57A|C60A) ? 1'b0 : 1'bz);
// Gate A21-U137B A21-U138B A21-U135B
pullup(g32068);
assign #GATE_DELAY g32068 = rst ? 1'bz : ((0|C54A|C56A|C55A|C50A|C47A|C31A|C51A|C52A|C53A) ? 1'b0 : 1'bz);
// Gate A21-U139A
pullup(BKTF_);
assign #GATE_DELAY BKTF_ = rst ? 0 : ((0|T10_) ? 1'b0 : 1'bz);
// Gate A21-U132A
pullup(DINC_);
assign #GATE_DELAY DINC_ = rst ? 0 : ((0|DINC) ? 1'b0 : 1'bz);
// Gate A21-U132B
pullup(CHINC_);
assign #GATE_DELAY CHINC_ = rst ? 1'bz : ((0|INOTRD|INOTLD) ? 1'b0 : 1'bz);
// Gate A21-U133A
pullup(g32049);
assign #GATE_DELAY g32049 = rst ? 0 : ((0|INCSET_|g32068) ? 1'b0 : 1'bz);
// Gate A21-U133B
pullup(g32061);
assign #GATE_DELAY g32061 = rst ? 1'bz : ((0|C46P|C45P) ? 1'b0 : 1'bz);
// Gate A21-U134A
pullup(g32062);
assign #GATE_DELAY g32062 = rst ? 0 : ((0|g32061|INCSET_) ? 1'b0 : 1'bz);
// Gate A21-U134B
pullup(DINCNC_);
assign #GATE_DELAY DINCNC_ = rst ? 0 : ((0|DINC|g32049) ? 1'b0 : 1'bz);
// Gate A21-U135A
pullup(SHANC_);
assign #GATE_DELAY SHANC_ = rst ? 1'bz : ((0|g32062|SHANC) ? 1'b0 : 1'bz);
// Gate A21-U136A
pullup(SHANC);
assign #GATE_DELAY SHANC = rst ? 0 : ((0|T12A|SHANC_) ? 1'b0 : 1'bz);
// Gate A21-U136B
pullup(DINC);
assign #GATE_DELAY DINC = rst ? 1'bz : ((0|T12A|DINCNC_) ? 1'b0 : 1'bz);
// Gate A21-U154A A21-U148A A21-U150A A21-U157A A21-U159A A21-U153A
pullup(g32033);
assign #GATE_DELAY g32033 = rst ? 0 : ((0|C44A|C37A|C36A|C57A|C56A|C54A|C55A|C35A|C34A|C27A|C26A|C24A|C25A|C46A|C47A|C45A) ? 1'b0 : 1'bz);
// Gate A21-U154B A21-U156B A21-U158B A21-U147A A21-U153B
pullup(g32022);
assign #GATE_DELAY g32022 = rst ? 1'bz : ((0|C53A|C52A|C47A|C33A|C36A|C37A|C32A|C26A|C27A|C56A|C57A|C46A|C42A|C43A) ? 1'b0 : 1'bz);
// Gate A21-U149A A21-U152A A21-U151A
pullup(g32044);
assign #GATE_DELAY g32044 = rst ? 1'bz : ((0|C56A|C57A|C51A|C50A|C52A|C54A|C55A|C53A) ? 1'b0 : 1'bz);
// Gate A21-U149B A21-U150B A21-U157B A21-U159B A21-U155B
pullup(g32021);
assign #GATE_DELAY g32021 = rst ? 1'bz : ((0|C57A|C55A|C53A|C47A|C51A|C33A|C35A|C37A|C31A|C27A|C25A|C45A|C43A|C41A) ? 1'b0 : 1'bz);
// Gate A21-U148B A21-U152B A21-U147B A21-U151B
pullup(g32016);
assign #GATE_DELAY g32016 = rst ? 1'bz : ((0|d50SUM|C46A|C47A|C40A|C41A|C42A|C60A|C45A|C44A|C43A) ? 1'b0 : 1'bz);
// Gate A21-U156A A21-U158A A21-U155A
pullup(d32004K);
assign #GATE_DELAY d32004K = rst ? 0 : ((0|C36A|C37A|C30A|C31A|C32A|C33A|C34A|C35A) ? 1'b0 : 1'bz);
// Gate A21-U160A A21-U160B A21-U145A
pullup(g32015);
assign #GATE_DELAY g32015 = rst ? 0 : ((0|C24A|C25A|C26A|C60A|d30SUM|C27A) ? 1'b0 : 1'bz);
// Gate A21-U141A
pullup(CAD3);
assign #GATE_DELAY CAD3 = rst ? 0 : ((0|RSCT_|g32033) ? 1'b0 : 1'bz);
// Gate A21-U141B
pullup(g32058);
assign #GATE_DELAY g32058 = rst ? 0 : ((0|g32056|INCSET_) ? 1'b0 : 1'bz);
// Gate A21-U140A
pullup(CAD5);
assign #GATE_DELAY CAD5 = rst ? 0 : ((0|RSCT_|g32015) ? 1'b0 : 1'bz);
// Gate A21-U140B
pullup(CAD6);
assign #GATE_DELAY CAD6 = rst ? 0 : ((0|g32016|RSCT_) ? 1'b0 : 1'bz);
// Gate A21-U143A
pullup(g32007);
assign #GATE_DELAY g32007 = rst ? 0 : ((0|d50SUM|d30SUM) ? 1'b0 : 1'bz);
// Gate A21-U143B
pullup(CAD1);
assign #GATE_DELAY CAD1 = rst ? 0 : ((0|RSCT_|g32021) ? 1'b0 : 1'bz);
// Gate A21-U142A
pullup(g32259);
assign #GATE_DELAY g32259 = rst ? 1'bz : ((0|CHINC|STORE1|FETCH1) ? 1'b0 : 1'bz);
// Gate A21-U142B
pullup(CAD2);
assign #GATE_DELAY CAD2 = rst ? 0 : ((0|RSCT_|g32022) ? 1'b0 : 1'bz);
// Gate A21-U145B
pullup(d50SUM);
assign #GATE_DELAY d50SUM = rst ? 0 : ((0|g32044) ? 1'b0 : 1'bz);
// Gate A21-U144A
pullup(CAD4);
assign #GATE_DELAY CAD4 = rst ? 0 : ((0|g32007|RSCT_) ? 1'b0 : 1'bz);
// Gate A21-U144B
pullup(SHINC);
assign #GATE_DELAY SHINC = rst ? 0 : ((0|SHINC_|T12A) ? 1'b0 : 1'bz);
// Gate A21-U146A
pullup(d30SUM);
assign #GATE_DELAY d30SUM = rst ? 1'bz : ((0|d32004K) ? 1'b0 : 1'bz);
// Gate A21-U146B
pullup(SHINC_);
assign #GATE_DELAY SHINC_ = rst ? 1'bz : ((0|SHINC|g32058) ? 1'b0 : 1'bz);
// Gate A21-U129A A21-U128A
pullup(g32202);
assign #GATE_DELAY g32202 = rst ? 0 : ((0|NISQL_|T12_|PHS4_|PSEUDO|GNHNC) ? 1'b0 : 1'bz);
// Gate A21-U129B
pullup(SCAS17);
assign #GATE_DELAY SCAS17 = rst ? 1'bz : ((0|FS17|DOSCAL) ? 1'b0 : 1'bz);
// Gate A21-U128B
pullup(g32203);
assign #GATE_DELAY g32203 = rst ? 1'bz : ((0|g32202) ? 1'b0 : 1'bz);
// Gate A21-U123A
pullup(g32212);
assign #GATE_DELAY g32212 = rst ? 0 : ((0|g32238|g32211|g32203) ? 1'b0 : 1'bz);
// Gate A21-U123B
pullup(g32213);
assign #GATE_DELAY g32213 = rst ? 1'bz : ((0|g32212|g32214) ? 1'b0 : 1'bz);
// Gate A21-U122A
pullup(MON_);
assign #GATE_DELAY MON_ = rst ? 1'bz : ((0|g32214|g32207) ? 1'b0 : 1'bz);
// Gate A21-U122B
pullup(g32214);
assign #GATE_DELAY g32214 = rst ? 0 : ((0|g32218|g32213|GOJAM) ? 1'b0 : 1'bz);
// Gate A21-U121A
pullup(FETCH1);
assign #GATE_DELAY FETCH1 = rst ? 0 : ((0|g32213|ST1_) ? 1'b0 : 1'bz);
// Gate A21-U121B
pullup(FETCH0);
assign #GATE_DELAY FETCH0 = rst ? 0 : ((0|MON_|ST0_) ? 1'b0 : 1'bz);
// Gate A21-U120A
pullup(g32218);
assign #GATE_DELAY g32218 = rst ? 0 : ((0|g32234|MON_|ST1_) ? 1'b0 : 1'bz);
// Gate A21-U120B
pullup(FETCH0_);
assign #GATE_DELAY FETCH0_ = rst ? 1'bz : ((0|FETCH0) ? 1'b0 : 1'bz);
// Gate A21-U127A
pullup(g32204);
assign #GATE_DELAY g32204 = rst ? 1'bz : ((0|MLOAD) ? 1'b0 : 1'bz);
// Gate A21-U127B
pullup(g32205);
assign #GATE_DELAY g32205 = rst ? 0 : ((0|g32238|g32204|g32203) ? 1'b0 : 1'bz);
// Gate A21-U126A
pullup(g32206);
assign #GATE_DELAY g32206 = rst ? 1'bz : ((0|g32207|g32205) ? 1'b0 : 1'bz);
// Gate A21-U126B
pullup(g32207);
assign #GATE_DELAY g32207 = rst ? 0 : ((0|g32218|g32206|GOJAM) ? 1'b0 : 1'bz);
// Gate A21-U125A
pullup(STORE1);
assign #GATE_DELAY STORE1 = rst ? 0 : ((0|ST1_|g32206) ? 1'b0 : 1'bz);
// Gate A21-U125B
pullup(STFET1_);
assign #GATE_DELAY STFET1_ = rst ? 1'bz : ((0|STORE1|FETCH1) ? 1'b0 : 1'bz);
// Gate A21-U124A
pullup(g32211);
assign #GATE_DELAY g32211 = rst ? 1'bz : ((0|MREAD) ? 1'b0 : 1'bz);
// Gate A21-U124B
pullup(STORE1_);
assign #GATE_DELAY STORE1_ = rst ? 1'bz : ((0|STORE1) ? 1'b0 : 1'bz);
// Gate A21-U108A
pullup(g32244);
assign #GATE_DELAY g32244 = rst ? 1'bz : ((0|g32245|g32240) ? 1'b0 : 1'bz);
// Gate A21-U108B
pullup(g32242);
assign #GATE_DELAY g32242 = rst ? 1'bz : ((0|g32239|CTROR_) ? 1'b0 : 1'bz);
// Gate A21-U105A A21-U102B
pullup(INKL_);
assign #GATE_DELAY INKL_ = rst ? 1'bz : ((0|g32245|MONpCH) ? 1'b0 : 1'bz);
// Gate A21-U105B A21-U106A
pullup(INCSET_);
assign #GATE_DELAY INCSET_ = rst ? 1'bz : ((0|g32246) ? 1'b0 : 1'bz);
// Gate A21-U104A A21-U104B
pullup(INKL);
assign #GATE_DELAY INKL = rst ? 0 : ((0|INKL_) ? 1'b0 : 1'bz);
// Gate A21-U107A
pullup(g32245);
assign #GATE_DELAY g32245 = rst ? 0 : ((0|g32244|g32243|GOJAM) ? 1'b0 : 1'bz);
// Gate A21-U107B
pullup(g32243);
assign #GATE_DELAY g32243 = rst ? 0 : ((0|g32242|PHS3_|T12_) ? 1'b0 : 1'bz);
// Gate A21-U106B
pullup(g32246);
assign #GATE_DELAY g32246 = rst ? 0 : ((0|g32244|T02_) ? 1'b0 : 1'bz);
// Gate A21-U102A
pullup(RSSB);
assign #GATE_DELAY RSSB = rst ? 0 : ((0|g32244|T07_|PHS3_) ? 1'b0 : 1'bz);
// Gate A21-U112A
pullup(g32237);
assign #GATE_DELAY g32237 = rst ? 0 : ((0|g32235|PHS2_) ? 1'b0 : 1'bz);
// Gate A21-U112B
pullup(g32234);
assign #GATE_DELAY g32234 = rst ? 1'bz : ((0|g32233) ? 1'b0 : 1'bz);
// Gate A21-U113A
pullup(g32233);
assign #GATE_DELAY g32233 = rst ? 0 : ((0|PHS2_|CT|T12_) ? 1'b0 : 1'bz);
// Gate A21-U113B
pullup(g32232);
assign #GATE_DELAY g32232 = rst ? 0 : ((0|g32259|T11_) ? 1'b0 : 1'bz);
// Gate A21-U110A A21-U109A
pullup(g32240);
assign #GATE_DELAY g32240 = rst ? 0 : ((0|g32239|CTROR_|g32203|MNHNC) ? 1'b0 : 1'bz);
// Gate A21-U110B
pullup(g32239);
assign #GATE_DELAY g32239 = rst ? 0 : ((0|g32232|GOJAM|g32238) ? 1'b0 : 1'bz);
// Gate A21-U111A
pullup(g32238);
assign #GATE_DELAY g32238 = rst ? 1'bz : ((0|g32239|g32237) ? 1'b0 : 1'bz);
// Gate A21-U111B A21-U109B
pullup(g32235);
assign #GATE_DELAY g32235 = rst ? 1'bz : ((0|MREAD|MLOAD|MLDCH|MRDCH) ? 1'b0 : 1'bz);
// Gate A21-U116A
pullup(g32226);
assign #GATE_DELAY g32226 = rst ? 1'bz : ((0|g32225|INOTRD) ? 1'b0 : 1'bz);
// Gate A21-U116B
pullup(INOTRD);
assign #GATE_DELAY INOTRD = rst ? 0 : ((0|g32233|g32226) ? 1'b0 : 1'bz);
// Gate A21-U117A
pullup(g32225);
assign #GATE_DELAY g32225 = rst ? 0 : ((0|g32238|g32224|g32203) ? 1'b0 : 1'bz);
// Gate A21-U117B
pullup(g32224);
assign #GATE_DELAY g32224 = rst ? 1'bz : ((0|MRDCH) ? 1'b0 : 1'bz);
// Gate A21-U114A
pullup(MONpCH);
assign #GATE_DELAY MONpCH = rst ? 0 : ((0|g32229) ? 1'b0 : 1'bz);
// Gate A21-U114B A21-U115B
pullup(g32229);
assign #GATE_DELAY g32229 = rst ? 1'bz : ((0|g32214|g32207|INOTLD|INOTRD) ? 1'b0 : 1'bz);
// Gate A21-U118A
pullup(g32222);
assign #GATE_DELAY g32222 = rst ? 1'bz : ((0|g32221|INOTLD) ? 1'b0 : 1'bz);
// Gate A21-U118B
pullup(INOTLD);
assign #GATE_DELAY INOTLD = rst ? 0 : ((0|g32233|g32222) ? 1'b0 : 1'bz);
// Gate A21-U119A
pullup(g32221);
assign #GATE_DELAY g32221 = rst ? 0 : ((0|g32238|g32220|g32203) ? 1'b0 : 1'bz);
// Gate A21-U119B
pullup(g32220);
assign #GATE_DELAY g32220 = rst ? 1'bz : ((0|MLDCH) ? 1'b0 : 1'bz);
// Gate A21-U103A
pullup(MINKL);
assign #GATE_DELAY MINKL = rst ? 0 : ((0|INKL_) ? 1'b0 : 1'bz);
// Gate A21-U103B
pullup(INKBT1);
assign #GATE_DELAY INKBT1 = rst ? 0 : ((0|STD2) ? 1'b0 : 1'bz);
// Gate A21-U115A
pullup(MREQIN);
assign #GATE_DELAY MREQIN = rst ? 0 : ((0|g32229) ? 1'b0 : 1'bz);
// Gate A21-U229A
pullup(g32603);
assign #GATE_DELAY g32603 = rst ? 0 : ((0|C44R|g32602) ? 1'b0 : 1'bz);
// Gate A21-U229B
pullup(g32629);
assign #GATE_DELAY g32629 = rst ? 1'bz : ((0|g32630|RNRADP) ? 1'b0 : 1'bz);
// Gate A21-U228A
pullup(g32604);
assign #GATE_DELAY g32604 = rst ? 1'bz : ((0|g32610|g32603) ? 1'b0 : 1'bz);
// Gate A21-U228B
pullup(g32633);
assign #GATE_DELAY g32633 = rst ? 0 : ((0|g32632|C46R) ? 1'b0 : 1'bz);
// Gate A21-U223A
pullup(g32610);
assign #GATE_DELAY g32610 = rst ? 0 : ((0|g32609|C44R) ? 1'b0 : 1'bz);
// Gate A21-U223B
pullup(g32637);
assign #GATE_DELAY g32637 = rst ? 0 : ((0|g32636|C46R) ? 1'b0 : 1'bz);
// Gate A21-U222A
pullup(g32609);
assign #GATE_DELAY g32609 = rst ? 1'bz : ((0|g32610|BMAGZM) ? 1'b0 : 1'bz);
// Gate A21-U222B
pullup(g32636);
assign #GATE_DELAY g32636 = rst ? 1'bz : ((0|g32637|RNRADM) ? 1'b0 : 1'bz);
// Gate A21-U221A
pullup(C44M);
assign #GATE_DELAY C44M = rst ? 0 : ((0|g32609|CA4_|CXB4_) ? 1'b0 : 1'bz);
// Gate A21-U221B
pullup(g32638);
assign #GATE_DELAY g32638 = rst ? 1'bz : ((0|g32637|g32630) ? 1'b0 : 1'bz);
// Gate A21-U220A
pullup(C44R);
assign #GATE_DELAY C44R = rst ? 0 : ((0|g32611|CA4_|CXB4_) ? 1'b0 : 1'bz);
// Gate A21-U220B
pullup(C46P);
assign #GATE_DELAY C46P = rst ? 0 : ((0|CA4_|CXB6_|g32629) ? 1'b0 : 1'bz);
// Gate A21-U227A
pullup(g32605);
assign #GATE_DELAY g32605 = rst ? 0 : ((0|g32601|g32604) ? 1'b0 : 1'bz);
// Gate A21-U227B
pullup(g32632);
assign #GATE_DELAY g32632 = rst ? 1'bz : ((0|g32633|g32631) ? 1'b0 : 1'bz);
// Gate A21-U226A
pullup(g32606);
assign #GATE_DELAY g32606 = rst ? 1'bz : ((0|g32607|g32605) ? 1'b0 : 1'bz);
// Gate A21-U226B
pullup(C46A);
assign #GATE_DELAY C46A = rst ? 0 : ((0|g32632|CG16) ? 1'b0 : 1'bz);
// Gate A21-U225A
pullup(C44A);
assign #GATE_DELAY C44A = rst ? 0 : ((0|g32606|CG15) ? 1'b0 : 1'bz);
// Gate A21-U225B
pullup(g32631);
assign #GATE_DELAY g32631 = rst ? 0 : ((0|g32601|g32638) ? 1'b0 : 1'bz);
// Gate A21-U224A
pullup(g32607);
assign #GATE_DELAY g32607 = rst ? 0 : ((0|C44R|g32606) ? 1'b0 : 1'bz);
// Gate A21-U224B
pullup(C46R);
assign #GATE_DELAY C46R = rst ? 0 : ((0|CA4_|CXB6_|g32611) ? 1'b0 : 1'bz);
// Gate A21-U238A
pullup(g32537);
assign #GATE_DELAY g32537 = rst ? 0 : ((0|C57R|g32536) ? 1'b0 : 1'bz);
// Gate A21-U238B
pullup(g32510);
assign #GATE_DELAY g32510 = rst ? 0 : ((0|g32509|C42R) ? 1'b0 : 1'bz);
// Gate A21-U239A
pullup(g32536);
assign #GATE_DELAY g32536 = rst ? 1'bz : ((0|OTLNKM|g32537) ? 1'b0 : 1'bz);
// Gate A21-U239B
pullup(g32509);
assign #GATE_DELAY g32509 = rst ? 1'bz : ((0|g32510|BMAGXM) ? 1'b0 : 1'bz);
// Gate A21-U230A
pullup(g32602);
assign #GATE_DELAY g32602 = rst ? 1'bz : ((0|g32603|BMAGZP) ? 1'b0 : 1'bz);
// Gate A21-U230B
pullup(g32630);
assign #GATE_DELAY g32630 = rst ? 0 : ((0|C46R|g32629) ? 1'b0 : 1'bz);
// Gate A21-U231A
pullup(g32530);
assign #GATE_DELAY g32530 = rst ? 0 : ((0|g32529|C56R) ? 1'b0 : 1'bz);
// Gate A21-U231B
pullup(g32502);
assign #GATE_DELAY g32502 = rst ? 1'bz : ((0|g32503|BMAGXP) ? 1'b0 : 1'bz);
// Gate A21-U232A
pullup(g32529);
assign #GATE_DELAY g32529 = rst ? 1'bz : ((0|EMSD|g32530) ? 1'b0 : 1'bz);
// Gate A21-U232B
pullup(g32503);
assign #GATE_DELAY g32503 = rst ? 0 : ((0|g32502|C42R) ? 1'b0 : 1'bz);
// Gate A21-U233A
pullup(g32531);
assign #GATE_DELAY g32531 = rst ? 0 : ((0|g32529|g32501) ? 1'b0 : 1'bz);
// Gate A21-U233B
pullup(g32504);
assign #GATE_DELAY g32504 = rst ? 1'bz : ((0|g32510|g32503) ? 1'b0 : 1'bz);
// Gate A21-U234A
pullup(g32532);
assign #GATE_DELAY g32532 = rst ? 1'bz : ((0|g32531|g32533) ? 1'b0 : 1'bz);
// Gate A21-U234B
pullup(g32505);
assign #GATE_DELAY g32505 = rst ? 0 : ((0|g32504|g32501) ? 1'b0 : 1'bz);
// Gate A21-U235A
pullup(C56A);
assign #GATE_DELAY C56A = rst ? 0 : ((0|g32532|CG23) ? 1'b0 : 1'bz);
// Gate A21-U235B
pullup(g32506);
assign #GATE_DELAY g32506 = rst ? 1'bz : ((0|g32505|g32507) ? 1'b0 : 1'bz);
// Gate A21-U236A
pullup(g32533);
assign #GATE_DELAY g32533 = rst ? 0 : ((0|g32532|C56R) ? 1'b0 : 1'bz);
// Gate A21-U236B
pullup(C42A);
assign #GATE_DELAY C42A = rst ? 0 : ((0|g32506|CG13) ? 1'b0 : 1'bz);
// Gate A21-U237A
pullup(C56R);
assign #GATE_DELAY C56R = rst ? 0 : ((0|g32511|CA5_|CXB6_) ? 1'b0 : 1'bz);
// Gate A21-U237B
pullup(g32507);
assign #GATE_DELAY g32507 = rst ? 0 : ((0|g32506|C42R) ? 1'b0 : 1'bz);
// Gate A21-U209A
pullup(C45A);
assign #GATE_DELAY C45A = rst ? 0 : ((0|g32619|CG15|g32607) ? 1'b0 : 1'bz);
// Gate A21-U209B
pullup(C47A);
assign #GATE_DELAY C47A = rst ? 0 : ((0|g32633|CG16|g32646) ? 1'b0 : 1'bz);
// Gate A21-U208A
pullup(g32620);
assign #GATE_DELAY g32620 = rst ? 0 : ((0|g32619|C45R) ? 1'b0 : 1'bz);
// Gate A21-U208B
pullup(g32650);
assign #GATE_DELAY g32650 = rst ? 0 : ((0|g32647|CG16|g32633) ? 1'b0 : 1'bz);
// Gate A21-U205A
pullup(CG16);
assign #GATE_DELAY CG16 = rst ? 1'bz : ((0|g32622) ? 1'b0 : 1'bz);
// Gate A21-U205B A21-U204B
pullup(CXB0_);
assign #GATE_DELAY CXB0_ = rst ? 1'bz : ((0|XB0) ? 1'b0 : 1'bz);
// Gate A21-U204A
pullup(g32624);
assign #GATE_DELAY g32624 = rst ? 1'bz : ((0|g32625|INLNKM) ? 1'b0 : 1'bz);
// Gate A21-U207A
pullup(g32622);
assign #GATE_DELAY g32622 = rst ? 0 : ((0|g32620|CG15|g32607) ? 1'b0 : 1'bz);
// Gate A21-U207B
pullup(CG26);
assign #GATE_DELAY CG26 = rst ? 1'bz : ((0|g32650) ? 1'b0 : 1'bz);
// Gate A21-U206A
pullup(g32659);
assign #GATE_DELAY g32659 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A21-U206B
pullup(CA4_);
assign #GATE_DELAY CA4_ = rst ? 1'bz : ((0|OCTAD4) ? 1'b0 : 1'bz);
// Gate A21-U201A
pullup(C45M);
assign #GATE_DELAY C45M = rst ? 0 : ((0|CXB5_|CA4_|g32624) ? 1'b0 : 1'bz);
// Gate A21-U201B
pullup(RQ_);
assign #GATE_DELAY RQ_ = rst ? 1'bz : ((0|RQ) ? 1'b0 : 1'bz);
// Gate A21-U203A
pullup(g32625);
assign #GATE_DELAY g32625 = rst ? 0 : ((0|g32624|C45R) ? 1'b0 : 1'bz);
// Gate A21-U203B A21-U202B
pullup(CXB6_);
assign #GATE_DELAY CXB6_ = rst ? 1'bz : ((0|XB6) ? 1'b0 : 1'bz);
// Gate A21-U202A
pullup(C45R);
assign #GATE_DELAY C45R = rst ? 0 : ((0|CXB5_|CA4_|g32611) ? 1'b0 : 1'bz);
// Gate A21-U255A A21-U253A
pullup(CTROR_);
assign #GATE_DELAY CTROR_ = rst ? 0 : ((0|g32547|g32540|g32533|CG23) ? 1'b0 : 1'bz);
// Gate A21-U255B
pullup(g32559);
assign #GATE_DELAY g32559 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A21-U251A A21-U252A
pullup(C60A);
assign #GATE_DELAY C60A = rst ? 0 : ((0|g32533|CG23|g32546|g32540) ? 1'b0 : 1'bz);
// Gate A21-U212A
pullup(C45P);
assign #GATE_DELAY C45P = rst ? 0 : ((0|CA4_|g32615|CXB5_) ? 1'b0 : 1'bz);
// Gate A21-U212B
pullup(g32646);
assign #GATE_DELAY g32646 = rst ? 1'bz : ((0|g32647|g32645) ? 1'b0 : 1'bz);
// Gate A21-U213A
pullup(g32618);
assign #GATE_DELAY g32618 = rst ? 0 : ((0|g32601|g32617) ? 1'b0 : 1'bz);
// Gate A21-U213B
pullup(g32645);
assign #GATE_DELAY g32645 = rst ? 0 : ((0|g32643|g32601) ? 1'b0 : 1'bz);
// Gate A21-U210B
pullup(g32647);
assign #GATE_DELAY g32647 = rst ? 0 : ((0|g32646|C47R) ? 1'b0 : 1'bz);
// Gate A21-U211A
pullup(g32619);
assign #GATE_DELAY g32619 = rst ? 1'bz : ((0|g32620|g32618) ? 1'b0 : 1'bz);
// Gate A21-U211B
pullup(g32648);
assign #GATE_DELAY g32648 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A21-U216A
pullup(g32615);
assign #GATE_DELAY g32615 = rst ? 1'bz : ((0|g32616|INLNKP) ? 1'b0 : 1'bz);
// Gate A21-U216B
pullup(g32644);
assign #GATE_DELAY g32644 = rst ? 0 : ((0|g32643|C47R) ? 1'b0 : 1'bz);
// Gate A21-U217A
pullup(g32611);
assign #GATE_DELAY g32611 = rst ? 1'bz : ((0|RSSB) ? 1'b0 : 1'bz);
// Gate A21-U217B
pullup(g32601);
assign #GATE_DELAY g32601 = rst ? 1'bz : ((0|BKTF_) ? 1'b0 : 1'bz);
// Gate A21-U214A
pullup(g32617);
assign #GATE_DELAY g32617 = rst ? 1'bz : ((0|g32616|g32625) ? 1'b0 : 1'bz);
// Gate A21-U214B
pullup(C47R);
assign #GATE_DELAY C47R = rst ? 0 : ((0|g32611|CXB7_|CA4_) ? 1'b0 : 1'bz);
// Gate A21-U215A
pullup(g32616);
assign #GATE_DELAY g32616 = rst ? 0 : ((0|C45R|g32615) ? 1'b0 : 1'bz);
// Gate A21-U215B
pullup(g32643);
assign #GATE_DELAY g32643 = rst ? 1'bz : ((0|g32644|GYROD) ? 1'b0 : 1'bz);
// Gate A21-U219A
pullup(C44P);
assign #GATE_DELAY C44P = rst ? 0 : ((0|g32602|CA4_|CXB4_) ? 1'b0 : 1'bz);
// Gate A21-U219B
pullup(g32641);
assign #GATE_DELAY g32641 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A21-U260A
pullup(CHINC);
assign #GATE_DELAY CHINC = rst ? 0 : ((0|CHINC_) ? 1'b0 : 1'bz);
// Gate A21-U260B
pullup(C43R);
assign #GATE_DELAY C43R = rst ? 0 : ((0|CXB3_|CA4_|g32511) ? 1'b0 : 1'bz);
// Gate A21-U218B
pullup(C46M);
assign #GATE_DELAY C46M = rst ? 0 : ((0|CA4_|CXB6_|g32636) ? 1'b0 : 1'bz);
// Gate A21-U249A
pullup(g32546);
assign #GATE_DELAY g32546 = rst ? 1'bz : ((0|g32545|g32547) ? 1'b0 : 1'bz);
// Gate A21-U249B
pullup(C43P);
assign #GATE_DELAY C43P = rst ? 0 : ((0|CXB3_|g32515|CA4_) ? 1'b0 : 1'bz);
// Gate A21-U248A
pullup(C60R);
assign #GATE_DELAY C60R = rst ? 0 : ((0|g32511|CXB0_|CA6_) ? 1'b0 : 1'bz);
// Gate A21-U248B
pullup(g32517);
assign #GATE_DELAY g32517 = rst ? 1'bz : ((0|g32516|g32525) ? 1'b0 : 1'bz);
// Gate A21-U241A
pullup(g32539);
assign #GATE_DELAY g32539 = rst ? 1'bz : ((0|g32538|g32540) ? 1'b0 : 1'bz);
// Gate A21-U241B
pullup(C42R);
assign #GATE_DELAY C42R = rst ? 0 : ((0|g32511|CA4_|CXB2_) ? 1'b0 : 1'bz);
// Gate A21-U240A
pullup(g32538);
assign #GATE_DELAY g32538 = rst ? 0 : ((0|g32536|g32501) ? 1'b0 : 1'bz);
// Gate A21-U240B
pullup(C42M);
assign #GATE_DELAY C42M = rst ? 0 : ((0|g32509|CA4_|CXB2_) ? 1'b0 : 1'bz);
// Gate A21-U243A
pullup(g32540);
assign #GATE_DELAY g32540 = rst ? 0 : ((0|g32539|C57R) ? 1'b0 : 1'bz);
// Gate A21-U243B
pullup(g32501);
assign #GATE_DELAY g32501 = rst ? 1'bz : ((0|BKTF_) ? 1'b0 : 1'bz);
// Gate A21-U242A
pullup(C57A);
assign #GATE_DELAY C57A = rst ? 0 : ((0|g32533|g32539|CG23) ? 1'b0 : 1'bz);
// Gate A21-U242B
pullup(C42P);
assign #GATE_DELAY C42P = rst ? 0 : ((0|g32502|CXB2_|CA4_) ? 1'b0 : 1'bz);
// Gate A21-U245A
pullup(g32544);
assign #GATE_DELAY g32544 = rst ? 0 : ((0|C60R|g32543) ? 1'b0 : 1'bz);
// Gate A21-U245B
pullup(g32515);
assign #GATE_DELAY g32515 = rst ? 1'bz : ((0|g32516|BMAGYP) ? 1'b0 : 1'bz);
// Gate A21-U244A
pullup(g32511);
assign #GATE_DELAY g32511 = rst ? 1'bz : ((0|RSSB) ? 1'b0 : 1'bz);
// Gate A21-U244B
pullup(C57R);
assign #GATE_DELAY C57R = rst ? 0 : ((0|CXB7_|g32511|CA5_) ? 1'b0 : 1'bz);
// Gate A21-U247A
pullup(g32545);
assign #GATE_DELAY g32545 = rst ? 0 : ((0|g32543|g32501) ? 1'b0 : 1'bz);
// Gate A21-U247B
pullup(g32518);
assign #GATE_DELAY g32518 = rst ? 0 : ((0|g32517|g32501) ? 1'b0 : 1'bz);
// Gate A21-U246A
pullup(g32543);
assign #GATE_DELAY g32543 = rst ? 1'bz : ((0|ALTM|g32544) ? 1'b0 : 1'bz);
// Gate A21-U246B
pullup(g32516);
assign #GATE_DELAY g32516 = rst ? 0 : ((0|g32515|C43R) ? 1'b0 : 1'bz);
// Gate A21-U258A A21-U259A
pullup(CXB5_);
assign #GATE_DELAY CXB5_ = rst ? 1'bz : ((0|XB5) ? 1'b0 : 1'bz);
// Gate A21-U258B
pullup(g32525);
assign #GATE_DELAY g32525 = rst ? 0 : ((0|g32524|C43R) ? 1'b0 : 1'bz);
// Gate A21-U259B
pullup(C43M);
assign #GATE_DELAY C43M = rst ? 0 : ((0|g32524|CA4_|CXB3_) ? 1'b0 : 1'bz);
// Gate A21-U256A A21-U257A
pullup(CA5_);
assign #GATE_DELAY CA5_ = rst ? 1'bz : ((0|OCTAD5) ? 1'b0 : 1'bz);
// Gate A21-U256B
pullup(CG15);
assign #GATE_DELAY CG15 = rst ? 1'bz : ((0|g32522) ? 1'b0 : 1'bz);
// Gate A21-U257B
pullup(g32524);
assign #GATE_DELAY g32524 = rst ? 1'bz : ((0|g32525|BMAGYM) ? 1'b0 : 1'bz);
// Gate A21-U254A
pullup(CTROR);
assign #GATE_DELAY CTROR = rst ? 1'bz : ((0|CTROR_) ? 1'b0 : 1'bz);
// Gate A21-U254B
pullup(g32522);
assign #GATE_DELAY g32522 = rst ? 0 : ((0|g32520|CG13|g32507) ? 1'b0 : 1'bz);
// Gate A21-U252B
pullup(C43A);
assign #GATE_DELAY C43A = rst ? 0 : ((0|CG13|g32519|g32507) ? 1'b0 : 1'bz);
// Gate A21-U253B
pullup(g32520);
assign #GATE_DELAY g32520 = rst ? 0 : ((0|g32519|C43R) ? 1'b0 : 1'bz);
// Gate A21-U250A
pullup(g32547);
assign #GATE_DELAY g32547 = rst ? 0 : ((0|g32546|C60R) ? 1'b0 : 1'bz);
// Gate A21-U250B
pullup(g32519);
assign #GATE_DELAY g32519 = rst ? 1'bz : ((0|g32518|g32520) ? 1'b0 : 1'bz);
// End of NOR gates


endmodule
