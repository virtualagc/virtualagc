// Verilog module auto-generated for AGC module A23 by dumbVerilog.py

module A23 ( 
  rst, BOTHZ, CCH11, CCH12, CCH13, CCH14, CCH33, CCHG_, CGA23, CH1109, CH1110,
  CH1208, CH1209, CH1210, CH1505, CH1601, CH1602, CH1603, CH1604, CH1605,
  CH1606, CH1607, CH3209, CH3210, CHAT01, CHAT02, CHAT03, CHAT04, CHAT05,
  CHAT06, CHAT07, CHAT08, CHAT09, CHAT10, CHBT01, CHBT02, CHBT03, CHBT04,
  CHBT05, CHBT06, CHBT07, CHBT08, CHBT09, CHBT10, CHOR01_, CHOR02_, CHOR03_,
  CHOR04_, CHOR05_, CHOR06_, CHOR07_, CHOR08_, CHOR09_, CHOR10_, CHWL01_,
  CHWL05_, CHWL06_, CHWL07_, CHWL08_, CHWL10_, CHWL11_, CHWL12_, CHWL13_,
  CHWL14_, CHWL16_, F18AX, F18B, F5ASB0_, F5ASB2, F5ASB2_, FUTEXT, GOJAM,
  HIGH3_, LOW6_, LOW7_, MISSZ, MOUT, NOZM, NOZP, OCTAD5, PC15_, PHS4_, PIPGXm,
  PIPGXp, PIPGYm, PIPGYp, POUT, RCH11_, RCH12_, RCH13_, RCH14_, RCHG_, T07_,
  T6RPT, WCH11_, WCH12_, WCH13_, WCH14_, WCHG_, XB0_, XB1_, XB2_, XB3_, XB4_,
  XB5_, XB7_, XT0_, XT3_, ZOUT, BOTHX, BOTHY, CH1108, DATA_, F18B_, MISSX,
  MISSY, MOUT_, NOXM, NOXP, NOYM, NOYP, POUT_, T7PHS4, ZOUT_, ALTEST, CCH07,
  CCH34, CCH35, CDUXD, CDUXDM, CDUXDP, CDUYD, CDUYDM, CDUYDP, CDUZD, CDUZDM,
  CDUZDP, CH01, CH02, CH03, CH04, CH05, CH06, CH07, CH0705, CH0706, CH0707,
  CH08, CH09, CH10, CH1113, CH1114, CH1116, CH1216, CH1310, CH1316, CH1411,
  CH1412, CH1413, CH1414, CH1416, E5, E6, E7_, ISSTDC, OT1108, OT1113, OT1114,
  OT1116, PIPAFL, PIPXM, PIPXP, PIPYM, PIPYP, RCH07_, SHAFTD, SHFTDM, SHFTDP,
  T6ON_, T7PHS4_, TRNDM, TRNDP, TRUND, WCH07_, WCH34_, WCH35_
);

input wire rst, BOTHZ, CCH11, CCH12, CCH13, CCH14, CCH33, CCHG_, CGA23, CH1109,
  CH1110, CH1208, CH1209, CH1210, CH1505, CH1601, CH1602, CH1603, CH1604,
  CH1605, CH1606, CH1607, CH3209, CH3210, CHAT01, CHAT02, CHAT03, CHAT04,
  CHAT05, CHAT06, CHAT07, CHAT08, CHAT09, CHAT10, CHBT01, CHBT02, CHBT03,
  CHBT04, CHBT05, CHBT06, CHBT07, CHBT08, CHBT09, CHBT10, CHOR01_, CHOR02_,
  CHOR03_, CHOR04_, CHOR05_, CHOR06_, CHOR07_, CHOR08_, CHOR09_, CHOR10_,
  CHWL01_, CHWL05_, CHWL06_, CHWL07_, CHWL08_, CHWL10_, CHWL11_, CHWL12_,
  CHWL13_, CHWL14_, CHWL16_, F18AX, F18B, F5ASB0_, F5ASB2, F5ASB2_, FUTEXT,
  GOJAM, HIGH3_, LOW6_, LOW7_, MISSZ, MOUT, NOZM, NOZP, OCTAD5, PC15_, PHS4_,
  PIPGXm, PIPGXp, PIPGYm, PIPGYp, POUT, RCH11_, RCH12_, RCH13_, RCH14_, RCHG_,
  T07_, T6RPT, WCH11_, WCH12_, WCH13_, WCH14_, WCHG_, XB0_, XB1_, XB2_, XB3_,
  XB4_, XB5_, XB7_, XT0_, XT3_, ZOUT;

inout wire BOTHX, BOTHY, CH1108, DATA_, F18B_, MISSX, MISSY, MOUT_, NOXM,
  NOXP, NOYM, NOYP, POUT_, T7PHS4, ZOUT_;

output wire ALTEST, CCH07, CCH34, CCH35, CDUXD, CDUXDM, CDUXDP, CDUYD, CDUYDM,
  CDUYDP, CDUZD, CDUZDM, CDUZDP, CH01, CH02, CH03, CH04, CH05, CH06, CH07,
  CH0705, CH0706, CH0707, CH08, CH09, CH10, CH1113, CH1114, CH1116, CH1216,
  CH1310, CH1316, CH1411, CH1412, CH1413, CH1414, CH1416, E5, E6, E7_, ISSTDC,
  OT1108, OT1113, OT1114, OT1116, PIPAFL, PIPXM, PIPXP, PIPYM, PIPYP, RCH07_,
  SHAFTD, SHFTDM, SHFTDP, T6ON_, T7PHS4_, TRNDM, TRNDP, TRUND, WCH07_, WCH34_,
  WCH35_;

parameter GATE_DELAY = 0.2; // This default may be overridden at compile time.
initial $display("Gate delay (A23) will be %f ns.", GATE_DELAY*100);

// Gate A23-U131A
pullup(g48110);
assign #GATE_DELAY g48110 = rst ? 0 : ((0|WCH35_|PC15_) ? 1'b0 : 1'bz);
// Gate A23-U207B
pullup(g48346);
assign #GATE_DELAY g48346 = rst ? 0 : ((0|g48357|XB4_) ? 1'b0 : 1'bz);
// Gate A23-U131B
pullup(g48109);
assign #GATE_DELAY g48109 = rst ? 0 : ((0|CHWL01_|WCH35_) ? 1'b0 : 1'bz);
// Gate A23-U243A
pullup(g48424);
assign #GATE_DELAY g48424 = rst ? 1'bz : ((0|g48425|g48423) ? 1'b0 : 1'bz);
// Gate A23-U139A
pullup(g48103);
assign #GATE_DELAY g48103 = rst ? 0 : ((0|g48102|F18B_) ? 1'b0 : 1'bz);
// Gate A23-U138A A23-U137A
pullup(g48107);
assign #GATE_DELAY g48107 = rst ? 1'bz : ((0|BOTHX|BOTHY|BOTHZ|g48105|g48103|PIPAFL) ? 1'b0 : 1'bz);
// Gate A23-U257B
pullup(CH1310);
assign #GATE_DELAY CH1310 = rst ? 0 : ((0|g48451|RCH13_) ? 1'b0 : 1'bz);
// Gate A23-U103A
pullup(CHOR07_);
assign #GATE_DELAY CHOR07_ = rst ? 1'bz : ((0|CHAT07|CHBT07|CH1607) ? 1'b0 : 1'bz);
// Gate A23-U119B
pullup(g48233);
assign #GATE_DELAY g48233 = rst ? 0 : ((0|g48249|g48238|g48230) ? 1'b0 : 1'bz);
// Gate A23-U231B
pullup(g48401);
assign #GATE_DELAY g48401 = rst ? 0 : ((0|WCH07_|CHWL05_) ? 1'b0 : 1'bz);
// Gate A23-U153A
pullup(g48135);
assign #GATE_DELAY g48135 = rst ? 0 : ((0|g48133|g48128) ? 1'b0 : 1'bz);
// Gate A23-U116A A23-U116B A23-U115B
pullup(CCH34);
assign #GATE_DELAY CCH34 = rst ? 1'bz : ((0|g48224) ? 1'b0 : 1'bz);
// Gate A23-U145A A23-U144A A23-U144B
pullup(CCH35);
assign #GATE_DELAY CCH35 = rst ? 1'bz : ((0|g48123) ? 1'b0 : 1'bz);
// Gate A23-U133B
pullup(g48113);
assign #GATE_DELAY g48113 = rst ? 1'bz : ((0|g48110|g48114) ? 1'b0 : 1'bz);
// Gate A23-U133A
pullup(g48114);
assign #GATE_DELAY g48114 = rst ? 0 : ((0|CCH35|g48113) ? 1'b0 : 1'bz);
// Gate A23-U153B
pullup(g48136);
assign #GATE_DELAY g48136 = rst ? 0 : ((0|g48134|g48128) ? 1'b0 : 1'bz);
// Gate A23-U253A
pullup(g48446);
assign #GATE_DELAY g48446 = rst ? 0 : ((0|CHWL16_|WCH13_) ? 1'b0 : 1'bz);
// Gate A23-U130A
pullup(NOYM);
assign #GATE_DELAY NOYM = rst ? 0 : ((0|PIPGYm|g48253) ? 1'b0 : 1'bz);
// Gate A23-U160A
pullup(g48147);
assign #GATE_DELAY g48147 = rst ? 0 : ((0|g48145|g48148) ? 1'b0 : 1'bz);
// Gate A23-U256B
pullup(g48451);
assign #GATE_DELAY g48451 = rst ? 1'bz : ((0|g48452|g48450) ? 1'b0 : 1'bz);
// Gate A23-U230A
pullup(g48302);
assign #GATE_DELAY g48302 = rst ? 1'bz : ((0|g48303|g48301) ? 1'b0 : 1'bz);
// Gate A23-U233A
pullup(CH0706);
assign #GATE_DELAY CH0706 = rst ? 0 : ((0|g48406|RCH07_) ? 1'b0 : 1'bz);
// Gate A23-U129A
pullup(NOYP);
assign #GATE_DELAY NOYP = rst ? 0 : ((0|PIPGYp|g48255) ? 1'b0 : 1'bz);
// Gate A23-U242A
pullup(CH1113);
assign #GATE_DELAY CH1113 = rst ? 0 : ((0|g48424|RCH11_) ? 1'b0 : 1'bz);
// Gate A23-U256A
pullup(g48452);
assign #GATE_DELAY g48452 = rst ? 0 : ((0|g48451|CCH13) ? 1'b0 : 1'bz);
// Gate A23-U249A
pullup(CH1116);
assign #GATE_DELAY CH1116 = rst ? 0 : ((0|g48434|RCH11_) ? 1'b0 : 1'bz);
// Gate A23-U235B
pullup(g48409);
assign #GATE_DELAY g48409 = rst ? 0 : ((0|WCH07_|CHWL07_) ? 1'b0 : 1'bz);
// Gate A23-U250A A23-U250B
pullup(CHOR09_);
assign #GATE_DELAY CHOR09_ = rst ? 1'bz : ((0|CHBT09|CHAT09|CH3209|CH1209|CH1109) ? 1'b0 : 1'bz);
// Gate A23-U202A
pullup(g48350);
assign #GATE_DELAY g48350 = rst ? 0 : ((0|g48347|ZOUT_) ? 1'b0 : 1'bz);
// Gate A23-U204B
pullup(g48347);
assign #GATE_DELAY g48347 = rst ? 1'bz : ((0|g48346) ? 1'b0 : 1'bz);
// Gate A23-U123B
pullup(g48235);
assign #GATE_DELAY g48235 = rst ? 1'bz : ((0|g48233|g48234) ? 1'b0 : 1'bz);
// Gate A23-U155B
pullup(g48138);
assign #GATE_DELAY g48138 = rst ? 1'bz : ((0|g48136|g48137) ? 1'b0 : 1'bz);
// Gate A23-U160B
pullup(g48148);
assign #GATE_DELAY g48148 = rst ? 1'bz : ((0|g48146|g48147) ? 1'b0 : 1'bz);
// Gate A23-U123A
pullup(g48234);
assign #GATE_DELAY g48234 = rst ? 0 : ((0|g48232|g48235) ? 1'b0 : 1'bz);
// Gate A23-U212B
pullup(g48357);
assign #GATE_DELAY g48357 = rst ? 1'bz : ((0|OCTAD5) ? 1'b0 : 1'bz);
// Gate A23-U150B
pullup(g48131);
assign #GATE_DELAY g48131 = rst ? 0 : ((0|g48148|g48138|g48130) ? 1'b0 : 1'bz);
// Gate A23-U246B
pullup(CH1114);
assign #GATE_DELAY CH1114 = rst ? 0 : ((0|g48429|RCH11_) ? 1'b0 : 1'bz);
// Gate A23-U215A
pullup(g48332);
assign #GATE_DELAY g48332 = rst ? 1'bz : ((0|g48333|g48331) ? 1'b0 : 1'bz);
// Gate A23-U251B
pullup(g48441);
assign #GATE_DELAY g48441 = rst ? 0 : ((0|CHWL16_|WCH12_) ? 1'b0 : 1'bz);
// Gate A23-U112B A23-U113A A23-U113B
pullup(WCH34_);
assign #GATE_DELAY WCH34_ = rst ? 1'bz : ((0|g48219) ? 1'b0 : 1'bz);
// Gate A23-U214A
pullup(TRUND);
assign #GATE_DELAY TRUND = rst ? 0 : ((0|g48332|F5ASB2_) ? 1'b0 : 1'bz);
// Gate A23-U136A
pullup(g48104);
assign #GATE_DELAY g48104 = rst ? 1'bz : ((0|MISSX|MISSZ|MISSY) ? 1'b0 : 1'bz);
// Gate A23-U125A
pullup(CHOR06_);
assign #GATE_DELAY CHOR06_ = rst ? 1'bz : ((0|CH1606|CHBT06|CHAT06) ? 1'b0 : 1'bz);
// Gate A23-U237A
pullup(CCH07);
assign #GATE_DELAY CCH07 = rst ? 0 : ((0|CCHG_|XB7_|XT0_) ? 1'b0 : 1'bz);
// Gate A23-U136B
pullup(g48105);
assign #GATE_DELAY g48105 = rst ? 0 : ((0|F5ASB0_|g48104) ? 1'b0 : 1'bz);
// Gate A23-U232B
pullup(CH0705);
assign #GATE_DELAY CH0705 = rst ? 0 : ((0|g48402|RCH07_) ? 1'b0 : 1'bz);
// Gate A23-U148B
pullup(g48152);
assign #GATE_DELAY g48152 = rst ? 1'bz : ((0|NOXP|F18AX) ? 1'b0 : 1'bz);
// Gate A23-U235A
pullup(CH0707);
assign #GATE_DELAY CH0707 = rst ? 0 : ((0|RCH07_|E7_) ? 1'b0 : 1'bz);
// Gate A23-U108A
pullup(g48242);
assign #GATE_DELAY g48242 = rst ? 0 : ((0|g48239|g48248|g48231) ? 1'b0 : 1'bz);
// Gate A23-U239A
pullup(RCH07_);
assign #GATE_DELAY RCH07_ = rst ? 1'bz : ((0|g48416) ? 1'b0 : 1'bz);
// Gate A23-U109B
pullup(g48241);
assign #GATE_DELAY g48241 = rst ? 0 : ((0|g48249|g48238|g48231) ? 1'b0 : 1'bz);
// Gate A23-U109A
pullup(g48240);
assign #GATE_DELAY g48240 = rst ? 0 : ((0|g48230|g48239|g48249) ? 1'b0 : 1'bz);
// Gate A23-U244A
pullup(OT1113);
assign #GATE_DELAY OT1113 = rst ? 0 : ((0|g48424) ? 1'b0 : 1'bz);
// Gate A23-U234A
pullup(g48406);
assign #GATE_DELAY g48406 = rst ? 1'bz : ((0|g48405|E6) ? 1'b0 : 1'bz);
// Gate A23-U252B
pullup(CH1216);
assign #GATE_DELAY CH1216 = rst ? 0 : ((0|g48442|RCH12_) ? 1'b0 : 1'bz);
// Gate A23-U108B
pullup(g48243);
assign #GATE_DELAY g48243 = rst ? 0 : ((0|g48248|g48238|g48230) ? 1'b0 : 1'bz);
// Gate A23-U210B
pullup(TRNDM);
assign #GATE_DELAY TRNDM = rst ? 0 : ((0|g48338|MOUT_) ? 1'b0 : 1'bz);
// Gate A23-U241A
pullup(CH1108);
assign #GATE_DELAY CH1108 = rst ? 0 : ((0|g48419|RCH11_) ? 1'b0 : 1'bz);
// Gate A23-U150A
pullup(BOTHX);
assign #GATE_DELAY BOTHX = rst ? 0 : ((0|g48130|g48129) ? 1'b0 : 1'bz);
// Gate A23-U120B
pullup(BOTHY);
assign #GATE_DELAY BOTHY = rst ? 0 : ((0|g48230|g48231) ? 1'b0 : 1'bz);
// Gate A23-U236B
pullup(E7_);
assign #GATE_DELAY E7_ = rst ? 1'bz : ((0|g48409|g48411) ? 1'b0 : 1'bz);
// Gate A23-U234B
pullup(g48405);
assign #GATE_DELAY g48405 = rst ? 0 : ((0|WCH07_|CHWL06_) ? 1'b0 : 1'bz);
// Gate A23-U244B
pullup(g48428);
assign #GATE_DELAY g48428 = rst ? 0 : ((0|WCH11_|CHWL14_) ? 1'b0 : 1'bz);
// Gate A23-U152B
pullup(g48128);
assign #GATE_DELAY g48128 = rst ? 1'bz : ((0|F5ASB2) ? 1'b0 : 1'bz);
// Gate A23-U227B
pullup(CDUXD);
assign #GATE_DELAY CDUXD = rst ? 0 : ((0|g48302|F5ASB2_) ? 1'b0 : 1'bz);
// Gate A23-U245B
pullup(OT1114);
assign #GATE_DELAY OT1114 = rst ? 0 : ((0|g48429) ? 1'b0 : 1'bz);
// Gate A23-U118A
pullup(CH01);
assign #GATE_DELAY CH01 = rst ? 0 : ((0|CHOR01_|RCHG_) ? 1'b0 : 1'bz);
// Gate A23-U220A
pullup(g48327);
assign #GATE_DELAY g48327 = rst ? 0 : ((0|g48357|XB2_) ? 1'b0 : 1'bz);
// Gate A23-U127A A23-U127B
pullup(CHOR05_);
assign #GATE_DELAY CHOR05_ = rst ? 1'bz : ((0|CHAT05|CHBT05|CH1505|CH1605) ? 1'b0 : 1'bz);
// Gate A23-U135B
pullup(DATA_);
assign #GATE_DELAY DATA_ = rst ? 1'bz : ((0|g48116|g48115) ? 1'b0 : 1'bz);
// Gate A23-U121B
pullup(g48239);
assign #GATE_DELAY g48239 = rst ? 1'bz : ((0|g48238|g48237) ? 1'b0 : 1'bz);
// Gate A23-U236A
pullup(g48411);
assign #GATE_DELAY g48411 = rst ? 0 : ((0|E7_|CCH07) ? 1'b0 : 1'bz);
// Gate A23-U218B
pullup(g48328);
assign #GATE_DELAY g48328 = rst ? 1'bz : ((0|g48327) ? 1'b0 : 1'bz);
// Gate A23-U239B
pullup(g48418);
assign #GATE_DELAY g48418 = rst ? 0 : ((0|CHWL08_|WCH11_) ? 1'b0 : 1'bz);
// Gate A23-U125B A23-U201B
pullup(T7PHS4);
assign #GATE_DELAY T7PHS4 = rst ? 0 : ((0|FUTEXT|T07_|PHS4_) ? 1'b0 : 1'bz);
// Gate A23-U149B
pullup(g48154);
assign #GATE_DELAY g48154 = rst ? 1'bz : ((0|MISSX|F5ASB2) ? 1'b0 : 1'bz);
// Gate A23-U232A
pullup(E5);
assign #GATE_DELAY E5 = rst ? 0 : ((0|g48402|CCH07) ? 1'b0 : 1'bz);
// Gate A23-U233B
pullup(E6);
assign #GATE_DELAY E6 = rst ? 0 : ((0|g48406|CCH07) ? 1'b0 : 1'bz);
// Gate A23-U229A
pullup(CH1416);
assign #GATE_DELAY CH1416 = rst ? 0 : ((0|g48302|RCH14_) ? 1'b0 : 1'bz);
// Gate A23-U105A
pullup(g48248);
assign #GATE_DELAY g48248 = rst ? 0 : ((0|g48249|g48246) ? 1'b0 : 1'bz);
// Gate A23-U247A
pullup(g48434);
assign #GATE_DELAY g48434 = rst ? 1'bz : ((0|g48435|g48433) ? 1'b0 : 1'bz);
// Gate A23-U247B
pullup(g48433);
assign #GATE_DELAY g48433 = rst ? 0 : ((0|WCH11_|CHWL16_) ? 1'b0 : 1'bz);
// Gate A23-U146A
pullup(g48130);
assign #GATE_DELAY g48130 = rst ? 1'bz : ((0|PIPGXm) ? 1'b0 : 1'bz);
// Gate A23-U242B
pullup(g48425);
assign #GATE_DELAY g48425 = rst ? 0 : ((0|CCH11|g48424) ? 1'b0 : 1'bz);
// Gate A23-U126B
pullup(g48231);
assign #GATE_DELAY g48231 = rst ? 1'bz : ((0|PIPGYm) ? 1'b0 : 1'bz);
// Gate A23-U121A
pullup(g48238);
assign #GATE_DELAY g48238 = rst ? 0 : ((0|g48239|g48236) ? 1'b0 : 1'bz);
// Gate A23-U138B A23-U139B
pullup(g48102);
assign #GATE_DELAY g48102 = rst ? 0 : ((0|NOXM|NOXP|NOYP|NOZM|NOZP|NOYM) ? 1'b0 : 1'bz);
// Gate A23-U146B
pullup(g48129);
assign #GATE_DELAY g48129 = rst ? 1'bz : ((0|PIPGXp) ? 1'b0 : 1'bz);
// Gate A23-U126A
pullup(g48230);
assign #GATE_DELAY g48230 = rst ? 1'bz : ((0|PIPGYp) ? 1'b0 : 1'bz);
// Gate A23-U231A
pullup(g48402);
assign #GATE_DELAY g48402 = rst ? 1'bz : ((0|g48401|E5) ? 1'b0 : 1'bz);
// Gate A23-U202B
pullup(T7PHS4_);
assign #GATE_DELAY T7PHS4_ = rst ? 1'bz : ((0|T7PHS4) ? 1'b0 : 1'bz);
// Gate A23-U134B
pullup(g48116);
assign #GATE_DELAY g48116 = rst ? 0 : ((0|g48113|HIGH3_|LOW7_) ? 1'b0 : 1'bz);
// Gate A23-U217B
pullup(g48322);
assign #GATE_DELAY g48322 = rst ? 1'bz : ((0|g48321|g48324) ? 1'b0 : 1'bz);
// Gate A23-U220B
pullup(g48324);
assign #GATE_DELAY g48324 = rst ? 0 : ((0|g48322|g48330|CCH14) ? 1'b0 : 1'bz);
// Gate A23-U128A
pullup(MISSY);
assign #GATE_DELAY MISSY = rst ? 0 : ((0|PIPGYp|PIPGYm|g48257) ? 1'b0 : 1'bz);
// Gate A23-U149A
pullup(MISSX);
assign #GATE_DELAY MISSX = rst ? 0 : ((0|PIPGXp|PIPGXm|g48154) ? 1'b0 : 1'bz);
// Gate A23-U243B
pullup(g48423);
assign #GATE_DELAY g48423 = rst ? 0 : ((0|WCH11_|CHWL13_) ? 1'b0 : 1'bz);
// Gate A23-U134A
pullup(g48115);
assign #GATE_DELAY g48115 = rst ? 0 : ((0|HIGH3_|g48111|LOW6_) ? 1'b0 : 1'bz);
// Gate A23-U258B A23-U257A
pullup(ALTEST);
assign #GATE_DELAY ALTEST = rst ? 0 : ((0|g48451) ? 1'b0 : 1'bz);
// Gate A23-U217A
pullup(g48330);
assign #GATE_DELAY g48330 = rst ? 0 : ((0|g48328|ZOUT_) ? 1'b0 : 1'bz);
// Gate A23-U219B
pullup(g48321);
assign #GATE_DELAY g48321 = rst ? 0 : ((0|WCH14_|CHWL13_) ? 1'b0 : 1'bz);
// Gate A23-U111B
pullup(CHOR04_);
assign #GATE_DELAY CHOR04_ = rst ? 1'bz : ((0|CH1604|CHBT04|CHAT04) ? 1'b0 : 1'bz);
// Gate A23-U218A
pullup(CDUZD);
assign #GATE_DELAY CDUZD = rst ? 0 : ((0|g48322|F5ASB2_) ? 1'b0 : 1'bz);
// Gate A23-U223B
pullup(g48316);
assign #GATE_DELAY g48316 = rst ? 0 : ((0|g48357|XB1_) ? 1'b0 : 1'bz);
// Gate A23-U147A
pullup(NOXM);
assign #GATE_DELAY NOXM = rst ? 1'bz : ((0|PIPGXm|g48150) ? 1'b0 : 1'bz);
// Gate A23-U148A
pullup(NOXP);
assign #GATE_DELAY NOXP = rst ? 0 : ((0|PIPGXp|g48152) ? 1'b0 : 1'bz);
// Gate A23-U216A
pullup(CDUZDP);
assign #GATE_DELAY CDUZDP = rst ? 0 : ((0|POUT_|g48328) ? 1'b0 : 1'bz);
// Gate A23-U157B
pullup(g48144);
assign #GATE_DELAY g48144 = rst ? 1'bz : ((0|g48143|g48142|g48141) ? 1'b0 : 1'bz);
// Gate A23-U254A
pullup(g48448);
assign #GATE_DELAY g48448 = rst ? 0 : ((0|T6ON_|CCH13|T6RPT) ? 1'b0 : 1'bz);
// Gate A23-U212A
pullup(g48338);
assign #GATE_DELAY g48338 = rst ? 1'bz : ((0|g48337) ? 1'b0 : 1'bz);
// Gate A23-U147B
pullup(g48150);
assign #GATE_DELAY g48150 = rst ? 0 : ((0|NOXM|F18AX) ? 1'b0 : 1'bz);
// Gate A23-U201A
pullup(g48360);
assign #GATE_DELAY g48360 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A23-U129B
pullup(g48255);
assign #GATE_DELAY g48255 = rst ? 1'bz : ((0|NOYP|F18AX) ? 1'b0 : 1'bz);
// Gate A23-U254B
pullup(T6ON_);
assign #GATE_DELAY T6ON_ = rst ? 1'bz : ((0|g48448|g48446) ? 1'b0 : 1'bz);
// Gate A23-U251A
pullup(g48442);
assign #GATE_DELAY g48442 = rst ? 1'bz : ((0|g48443|g48441) ? 1'b0 : 1'bz);
// Gate A23-U205A A23-U205B
pullup(ZOUT_);
assign #GATE_DELAY ZOUT_ = rst ? 1'bz : ((0|ZOUT) ? 1'b0 : 1'bz);
// Gate A23-U252A
pullup(g48443);
assign #GATE_DELAY g48443 = rst ? 0 : ((0|g48442|CCH12) ? 1'b0 : 1'bz);
// Gate A23-U215B
pullup(g48331);
assign #GATE_DELAY g48331 = rst ? 0 : ((0|WCH14_|CHWL12_) ? 1'b0 : 1'bz);
// Gate A23-U248B
pullup(OT1116);
assign #GATE_DELAY OT1116 = rst ? 0 : ((0|g48434) ? 1'b0 : 1'bz);
// Gate A23-U143A
pullup(g48123);
assign #GATE_DELAY g48123 = rst ? 0 : ((0|g48119|GOJAM) ? 1'b0 : 1'bz);
// Gate A23-U111A
pullup(CHOR03_);
assign #GATE_DELAY CHOR03_ = rst ? 1'bz : ((0|CHAT03|CH1603|CHBT03) ? 1'b0 : 1'bz);
// Gate A23-U258A
pullup(CH10);
assign #GATE_DELAY CH10 = rst ? 0 : ((0|CHOR10_|RCHG_) ? 1'b0 : 1'bz);
// Gate A23-U249B
pullup(CH09);
assign #GATE_DELAY CH09 = rst ? 0 : ((0|RCHG_|CHOR09_) ? 1'b0 : 1'bz);
// Gate A23-U255B
pullup(g48450);
assign #GATE_DELAY g48450 = rst ? 0 : ((0|WCH13_|CHWL10_) ? 1'b0 : 1'bz);
// Gate A23-U238A
pullup(g48416);
assign #GATE_DELAY g48416 = rst ? 0 : ((0|XT0_|XB7_) ? 1'b0 : 1'bz);
// Gate A23-U223A
pullup(CDUYD);
assign #GATE_DELAY CDUYD = rst ? 0 : ((0|g48312|F5ASB2_) ? 1'b0 : 1'bz);
// Gate A23-U104B
pullup(PIPYP);
assign #GATE_DELAY PIPYP = rst ? 0 : ((0|g48248|g48239|g48230) ? 1'b0 : 1'bz);
// Gate A23-U104A
pullup(PIPYM);
assign #GATE_DELAY PIPYM = rst ? 0 : ((0|g48248|g48238|g48231) ? 1'b0 : 1'bz);
// Gate A23-U225A
pullup(g48312);
assign #GATE_DELAY g48312 = rst ? 1'bz : ((0|g48313|g48311) ? 1'b0 : 1'bz);
// Gate A23-U238B
pullup(WCH07_);
assign #GATE_DELAY WCH07_ = rst ? 1'bz : ((0|g48414) ? 1'b0 : 1'bz);
// Gate A23-U221A
pullup(g48320);
assign #GATE_DELAY g48320 = rst ? 0 : ((0|g48317|ZOUT_) ? 1'b0 : 1'bz);
// Gate A23-U222B
pullup(g48317);
assign #GATE_DELAY g48317 = rst ? 1'bz : ((0|g48316) ? 1'b0 : 1'bz);
// Gate A23-U224B
pullup(g48313);
assign #GATE_DELAY g48313 = rst ? 0 : ((0|g48312|g48320|CCH14) ? 1'b0 : 1'bz);
// Gate A23-U137B
pullup(PIPAFL);
assign #GATE_DELAY PIPAFL = rst ? 0 : ((0|CCH33|g48107) ? 1'b0 : 1'bz);
// Gate A23-U145B
pullup(F18B_);
assign #GATE_DELAY F18B_ = rst ? 1'bz : ((0|F18B) ? 1'b0 : 1'bz);
// Gate A23-U114A
pullup(g48220);
assign #GATE_DELAY g48220 = rst ? 0 : ((0|CCHG_|XB4_|XT3_) ? 1'b0 : 1'bz);
// Gate A23-U211B
pullup(g48337);
assign #GATE_DELAY g48337 = rst ? 0 : ((0|g48357|XB3_) ? 1'b0 : 1'bz);
// Gate A23-U213B
pullup(TRNDP);
assign #GATE_DELAY TRNDP = rst ? 0 : ((0|g48338|POUT_) ? 1'b0 : 1'bz);
// Gate A23-U210A
pullup(g48341);
assign #GATE_DELAY g48341 = rst ? 0 : ((0|WCH14_|CHWL11_) ? 1'b0 : 1'bz);
// Gate A23-U209B
pullup(g48343);
assign #GATE_DELAY g48343 = rst ? 0 : ((0|g48342|g48350|CCH14) ? 1'b0 : 1'bz);
// Gate A23-U117B
pullup(CHOR02_);
assign #GATE_DELAY CHOR02_ = rst ? 1'bz : ((0|CHAT02|CH1602|CHBT02) ? 1'b0 : 1'bz);
// Gate A23-U228B
pullup(g48311);
assign #GATE_DELAY g48311 = rst ? 0 : ((0|WCH14_|CHWL14_) ? 1'b0 : 1'bz);
// Gate A23-U241B
pullup(OT1108);
assign #GATE_DELAY OT1108 = rst ? 0 : ((0|g48419) ? 1'b0 : 1'bz);
// Gate A23-U228A
pullup(g48306);
assign #GATE_DELAY g48306 = rst ? 0 : ((0|g48357|XB0_) ? 1'b0 : 1'bz);
// Gate A23-U225B
pullup(g48307);
assign #GATE_DELAY g48307 = rst ? 1'bz : ((0|g48306) ? 1'b0 : 1'bz);
// Gate A23-U204A A23-U206A
pullup(POUT_);
assign #GATE_DELAY POUT_ = rst ? 1'bz : ((0|POUT) ? 1'b0 : 1'bz);
// Gate A23-U122A
pullup(g48236);
assign #GATE_DELAY g48236 = rst ? 0 : ((0|g48229|g48234) ? 1'b0 : 1'bz);
// Gate A23-U230B
pullup(g48301);
assign #GATE_DELAY g48301 = rst ? 0 : ((0|CHWL16_|WCH14_) ? 1'b0 : 1'bz);
// Gate A23-U141B
pullup(g48118);
assign #GATE_DELAY g48118 = rst ? 0 : ((0|WCHG_|XB5_|XT3_) ? 1'b0 : 1'bz);
// Gate A23-U101B
pullup(CH08);
assign #GATE_DELAY CH08 = rst ? 0 : ((0|CHOR08_|RCHG_) ? 1'b0 : 1'bz);
// Gate A23-U120A
pullup(g48232);
assign #GATE_DELAY g48232 = rst ? 0 : ((0|g48249|g48239|g48231) ? 1'b0 : 1'bz);
// Gate A23-U124A
pullup(CH05);
assign #GATE_DELAY CH05 = rst ? 0 : ((0|RCHG_|CHOR05_) ? 1'b0 : 1'bz);
// Gate A23-U110B
pullup(CH04);
assign #GATE_DELAY CH04 = rst ? 0 : ((0|CHOR04_|RCHG_) ? 1'b0 : 1'bz);
// Gate A23-U101A
pullup(CH07);
assign #GATE_DELAY CH07 = rst ? 0 : ((0|RCHG_|CHOR07_) ? 1'b0 : 1'bz);
// Gate A23-U124B
pullup(CH06);
assign #GATE_DELAY CH06 = rst ? 0 : ((0|RCHG_|CHOR06_) ? 1'b0 : 1'bz);
// Gate A23-U141A
pullup(g48119);
assign #GATE_DELAY g48119 = rst ? 0 : ((0|XB5_|XT3_|CCHG_) ? 1'b0 : 1'bz);
// Gate A23-U110A
pullup(CH03);
assign #GATE_DELAY CH03 = rst ? 0 : ((0|RCHG_|CHOR03_) ? 1'b0 : 1'bz);
// Gate A23-U118B
pullup(CH02);
assign #GATE_DELAY CH02 = rst ? 0 : ((0|CHOR02_|RCHG_) ? 1'b0 : 1'bz);
// Gate A23-U219A
pullup(CH1413);
assign #GATE_DELAY CH1413 = rst ? 0 : ((0|g48322|RCH14_) ? 1'b0 : 1'bz);
// Gate A23-U213A
pullup(CH1412);
assign #GATE_DELAY CH1412 = rst ? 0 : ((0|g48332|RCH14_) ? 1'b0 : 1'bz);
// Gate A23-U208B
pullup(CH1411);
assign #GATE_DELAY CH1411 = rst ? 0 : ((0|RCH14_|g48342) ? 1'b0 : 1'bz);
// Gate A23-U240B
pullup(g48419);
assign #GATE_DELAY g48419 = rst ? 1'bz : ((0|g48418|g48420) ? 1'b0 : 1'bz);
// Gate A23-U106B
pullup(g48247);
assign #GATE_DELAY g48247 = rst ? 0 : ((0|g48229|g48245) ? 1'b0 : 1'bz);
// Gate A23-U240A
pullup(g48420);
assign #GATE_DELAY g48420 = rst ? 0 : ((0|g48419|CCH11) ? 1'b0 : 1'bz);
// Gate A23-U224A
pullup(CH1414);
assign #GATE_DELAY CH1414 = rst ? 0 : ((0|g48312|RCH14_) ? 1'b0 : 1'bz);
// Gate A23-U114B
pullup(g48219);
assign #GATE_DELAY g48219 = rst ? 0 : ((0|XT3_|WCHG_|XB4_) ? 1'b0 : 1'bz);
// Gate A23-U105B
pullup(g48249);
assign #GATE_DELAY g48249 = rst ? 1'bz : ((0|g48248|g48247) ? 1'b0 : 1'bz);
// Gate A23-U106A
pullup(g48246);
assign #GATE_DELAY g48246 = rst ? 0 : ((0|g48229|g48244) ? 1'b0 : 1'bz);
// Gate A23-U155A
pullup(g48137);
assign #GATE_DELAY g48137 = rst ? 0 : ((0|g48135|g48138) ? 1'b0 : 1'bz);
// Gate A23-U151A
pullup(g48132);
assign #GATE_DELAY g48132 = rst ? 0 : ((0|g48148|g48137|g48129) ? 1'b0 : 1'bz);
// Gate A23-U237B
pullup(g48414);
assign #GATE_DELAY g48414 = rst ? 0 : ((0|XB7_|XT0_|WCHG_) ? 1'b0 : 1'bz);
// Gate A23-U152A
pullup(g48134);
assign #GATE_DELAY g48134 = rst ? 1'bz : ((0|g48132|g48133) ? 1'b0 : 1'bz);
// Gate A23-U151B
pullup(g48133);
assign #GATE_DELAY g48133 = rst ? 0 : ((0|g48131|g48134) ? 1'b0 : 1'bz);
// Gate A23-U117A
pullup(CHOR01_);
assign #GATE_DELAY CHOR01_ = rst ? 1'bz : ((0|CH1601|CHAT01|CHBT01) ? 1'b0 : 1'bz);
// Gate A23-U208A
pullup(SHAFTD);
assign #GATE_DELAY SHAFTD = rst ? 0 : ((0|F5ASB2_|g48342) ? 1'b0 : 1'bz);
// Gate A23-U209A
pullup(g48342);
assign #GATE_DELAY g48342 = rst ? 1'bz : ((0|g48343|g48341) ? 1'b0 : 1'bz);
// Gate A23-U259A A23-U259B
pullup(CHOR10_);
assign #GATE_DELAY CHOR10_ = rst ? 1'bz : ((0|CH1110|CH1210|CH3210|CHAT10|CHBT10) ? 1'b0 : 1'bz);
// Gate A23-U156B
pullup(PIPXP);
assign #GATE_DELAY PIPXP = rst ? 0 : ((0|g48138|g48129|g48147) ? 1'b0 : 1'bz);
// Gate A23-U248A
pullup(g48435);
assign #GATE_DELAY g48435 = rst ? 0 : ((0|g48434|CCH11) ? 1'b0 : 1'bz);
// Gate A23-U211A
pullup(g48340);
assign #GATE_DELAY g48340 = rst ? 0 : ((0|g48338|ZOUT_) ? 1'b0 : 1'bz);
// Gate A23-U227A
pullup(CDUXDP);
assign #GATE_DELAY CDUXDP = rst ? 0 : ((0|g48307|POUT_) ? 1'b0 : 1'bz);
// Gate A23-U143B A23-U142A A23-U142B
pullup(WCH35_);
assign #GATE_DELAY WCH35_ = rst ? 1'bz : ((0|g48118) ? 1'b0 : 1'bz);
// Gate A23-U246A
pullup(g48429);
assign #GATE_DELAY g48429 = rst ? 1'bz : ((0|g48430|g48428) ? 1'b0 : 1'bz);
// Gate A23-U245A
pullup(g48430);
assign #GATE_DELAY g48430 = rst ? 0 : ((0|g48429|CCH11) ? 1'b0 : 1'bz);
// Gate A23-U132B
pullup(g48111);
assign #GATE_DELAY g48111 = rst ? 1'bz : ((0|g48109|g48112) ? 1'b0 : 1'bz);
// Gate A23-U132A
pullup(g48112);
assign #GATE_DELAY g48112 = rst ? 0 : ((0|CCH35|g48111) ? 1'b0 : 1'bz);
// Gate A23-U158B
pullup(g48142);
assign #GATE_DELAY g48142 = rst ? 0 : ((0|g48129|g48137|g48147) ? 1'b0 : 1'bz);
// Gate A23-U157A
pullup(g48143);
assign #GATE_DELAY g48143 = rst ? 0 : ((0|g48140|g48139|g48144) ? 1'b0 : 1'bz);
// Gate A23-U115A
pullup(g48224);
assign #GATE_DELAY g48224 = rst ? 0 : ((0|GOJAM|g48220) ? 1'b0 : 1'bz);
// Gate A23-U158A
pullup(g48141);
assign #GATE_DELAY g48141 = rst ? 0 : ((0|g48138|g48130|g48147) ? 1'b0 : 1'bz);
// Gate A23-U226B
pullup(CDUXDM);
assign #GATE_DELAY CDUXDM = rst ? 0 : ((0|g48307|MOUT_) ? 1'b0 : 1'bz);
// Gate A23-U130B
pullup(g48253);
assign #GATE_DELAY g48253 = rst ? 1'bz : ((0|F18AX|NOYM) ? 1'b0 : 1'bz);
// Gate A23-U159B
pullup(g48146);
assign #GATE_DELAY g48146 = rst ? 0 : ((0|g48144|g48128) ? 1'b0 : 1'bz);
// Gate A23-U203A
pullup(SHFTDM);
assign #GATE_DELAY SHFTDM = rst ? 0 : ((0|g48347|MOUT_) ? 1'b0 : 1'bz);
// Gate A23-U159A
pullup(g48145);
assign #GATE_DELAY g48145 = rst ? 0 : ((0|g48143|g48128) ? 1'b0 : 1'bz);
// Gate A23-U128B
pullup(g48257);
assign #GATE_DELAY g48257 = rst ? 1'bz : ((0|F5ASB2|MISSY) ? 1'b0 : 1'bz);
// Gate A23-U154A
pullup(g48140);
assign #GATE_DELAY g48140 = rst ? 0 : ((0|g48148|g48130|g48137) ? 1'b0 : 1'bz);
// Gate A23-U206B
pullup(SHFTDP);
assign #GATE_DELAY SHFTDP = rst ? 0 : ((0|g48347|POUT_) ? 1'b0 : 1'bz);
// Gate A23-U255A
pullup(CH1316);
assign #GATE_DELAY CH1316 = rst ? 0 : ((0|T6ON_|RCH13_) ? 1'b0 : 1'bz);
// Gate A23-U154B
pullup(g48139);
assign #GATE_DELAY g48139 = rst ? 0 : ((0|g48148|g48138|g48129) ? 1'b0 : 1'bz);
// Gate A23-U229B
pullup(g48303);
assign #GATE_DELAY g48303 = rst ? 0 : ((0|g48310|g48302|CCH14) ? 1'b0 : 1'bz);
// Gate A23-U207A A23-U203B
pullup(MOUT_);
assign #GATE_DELAY MOUT_ = rst ? 1'bz : ((0|MOUT) ? 1'b0 : 1'bz);
// Gate A23-U107A
pullup(g48244);
assign #GATE_DELAY g48244 = rst ? 1'bz : ((0|g48245|g48241|g48240) ? 1'b0 : 1'bz);
// Gate A23-U119A
pullup(g48229);
assign #GATE_DELAY g48229 = rst ? 1'bz : ((0|F5ASB2) ? 1'b0 : 1'bz);
// Gate A23-U214B
pullup(g48333);
assign #GATE_DELAY g48333 = rst ? 0 : ((0|g48340|g48332|CCH14) ? 1'b0 : 1'bz);
// Gate A23-U222A
pullup(CDUYDP);
assign #GATE_DELAY CDUYDP = rst ? 0 : ((0|g48317|POUT_) ? 1'b0 : 1'bz);
// Gate A23-U107B
pullup(g48245);
assign #GATE_DELAY g48245 = rst ? 0 : ((0|g48244|g48242|g48243) ? 1'b0 : 1'bz);
// Gate A23-U122B
pullup(g48237);
assign #GATE_DELAY g48237 = rst ? 0 : ((0|g48235|g48229) ? 1'b0 : 1'bz);
// Gate A23-U221B
pullup(CDUYDM);
assign #GATE_DELAY CDUYDM = rst ? 0 : ((0|g48317|MOUT_) ? 1'b0 : 1'bz);
// Gate A23-U103B A23-U102B
pullup(CHOR08_);
assign #GATE_DELAY CHOR08_ = rst ? 1'bz : ((0|CHBT08|CHAT08|CH1208|CH1108) ? 1'b0 : 1'bz);
// Gate A23-U156A
pullup(PIPXM);
assign #GATE_DELAY PIPXM = rst ? 0 : ((0|g48137|g48147|g48130) ? 1'b0 : 1'bz);
// Gate A23-U226A
pullup(g48310);
assign #GATE_DELAY g48310 = rst ? 0 : ((0|g48307|ZOUT_) ? 1'b0 : 1'bz);
// Gate A23-U253B
pullup(ISSTDC);
assign #GATE_DELAY ISSTDC = rst ? 0 : ((0|g48442) ? 1'b0 : 1'bz);
// Gate A23-U216B
pullup(CDUZDM);
assign #GATE_DELAY CDUZDM = rst ? 0 : ((0|g48328|MOUT_) ? 1'b0 : 1'bz);
// End of NOR gates


endmodule
