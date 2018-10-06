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

input wand rst, BOTHZ, CCH11, CCH12, CCH13, CCH14, CCH33, CCHG_, CGA23, CH1109,
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

inout wand BOTHX, BOTHY, CH1108, DATA_, F18B_, MISSX, MISSY, MOUT_, NOXM,
  NOXP, NOYM, NOYP, POUT_, T7PHS4, ZOUT_;

output wand ALTEST, CCH07, CCH34, CCH35, CDUXD, CDUXDM, CDUXDP, CDUYD, CDUYDM,
  CDUYDP, CDUZD, CDUZDM, CDUZDP, CH01, CH02, CH03, CH04, CH05, CH06, CH07,
  CH0705, CH0706, CH0707, CH08, CH09, CH10, CH1113, CH1114, CH1116, CH1216,
  CH1310, CH1316, CH1411, CH1412, CH1413, CH1414, CH1416, E5, E6, E7_, ISSTDC,
  OT1108, OT1113, OT1114, OT1116, PIPAFL, PIPXM, PIPXP, PIPYM, PIPYP, RCH07_,
  SHAFTD, SHFTDM, SHFTDP, T6ON_, T7PHS4_, TRNDM, TRNDP, TRUND, WCH07_, WCH34_,
  WCH35_;

// Gate A23-U131A
assign #0.2  g48110 = rst ? 0 : ~(0|PC15_|WCH35_);
// Gate A23-U207B
assign #0.2  g48346 = rst ? 0 : ~(0|g48357|XB4_);
// Gate A23-U131B
assign #0.2  g48109 = rst ? 0 : ~(0|CHWL01_|WCH35_);
// Gate A23-U243A
assign #0.2  g48424 = rst ? 1 : ~(0|g48423|g48425);
// Gate A23-U139A
assign #0.2  g48103 = rst ? 0 : ~(0|F18B_|g48102);
// Gate A23-U138A A23-U137A
assign #0.2  g48107 = rst ? 0 : ~(0|BOTHZ|BOTHY|BOTHX|PIPAFL|g48103|g48105);
// Gate A23-U257B
assign #0.2  CH1310 = rst ? 0 : ~(0|g48451|RCH13_);
// Gate A23-U103A
assign #0.2  CHOR07_ = rst ? 1 : ~(0|CH1607|CHBT07|CHAT07);
// Gate A23-U119B
assign #0.2  g48233 = rst ? 0 : ~(0|g48249|g48238|g48230);
// Gate A23-U231B
assign #0.2  g48401 = rst ? 0 : ~(0|WCH07_|CHWL05_);
// Gate A23-U153A
assign #0.2  g48135 = rst ? 0 : ~(0|g48128|g48133);
// Gate A23-U116A A23-U116B A23-U115B
assign #0.2  CCH34 = rst ? 1 : ~(0|g48224);
// Gate A23-U145A A23-U144A A23-U144B
assign #0.2  CCH35 = rst ? 1 : ~(0|g48123);
// Gate A23-U133B
assign #0.2  g48113 = rst ? 1 : ~(0|g48110|g48114);
// Gate A23-U133A
assign #0.2  g48114 = rst ? 0 : ~(0|g48113|CCH35);
// Gate A23-U153B
assign #0.2  g48136 = rst ? 0 : ~(0|g48134|g48128);
// Gate A23-U253A
assign #0.2  g48446 = rst ? 0 : ~(0|WCH13_|CHWL16_);
// Gate A23-U130A
assign #0.2  NOYM = rst ? 1 : ~(0|g48253|PIPGYm);
// Gate A23-U160A
assign #0.2  g48147 = rst ? 1 : ~(0|g48148|g48145);
// Gate A23-U256B
assign #0.2  g48451 = rst ? 1 : ~(0|g48452|g48450);
// Gate A23-U230A
assign #0.2  g48302 = rst ? 1 : ~(0|g48301|g48303);
// Gate A23-U233A
assign #0.2  CH0706 = rst ? 0 : ~(0|RCH07_|g48406);
// Gate A23-U129A
assign #0.2  NOYP = rst ? 1 : ~(0|g48255|PIPGYp);
// Gate A23-U242A
assign #0.2  CH1113 = rst ? 0 : ~(0|RCH11_|g48424);
// Gate A23-U256A
assign #0.2  g48452 = rst ? 0 : ~(0|CCH13|g48451);
// Gate A23-U249A
assign #0.2  CH1116 = rst ? 0 : ~(0|RCH11_|g48434);
// Gate A23-U235B
assign #0.2  g48409 = rst ? 0 : ~(0|WCH07_|CHWL07_);
// Gate A23-U250A A23-U250B
assign #0.2  CHOR09_ = rst ? 1 : ~(0|CHAT09|CHBT09|CH3209|CH1209|CH1109);
// Gate A23-U202A
assign #0.2  g48350 = rst ? 0 : ~(0|ZOUT_|g48347);
// Gate A23-U204B
assign #0.2  g48347 = rst ? 1 : ~(0|g48346);
// Gate A23-U123B
assign #0.2  g48235 = rst ? 0 : ~(0|g48233|g48234);
// Gate A23-U155B
assign #0.2  g48138 = rst ? 1 : ~(0|g48136|g48137);
// Gate A23-U160B
assign #0.2  g48148 = rst ? 0 : ~(0|g48146|g48147);
// Gate A23-U123A
assign #0.2  g48234 = rst ? 1 : ~(0|g48235|g48232);
// Gate A23-U212B
assign #0.2  g48357 = rst ? 1 : ~(0|OCTAD5);
// Gate A23-U150B
assign #0.2  g48131 = rst ? 0 : ~(0|g48148|g48138|g48130);
// Gate A23-U246B
assign #0.2  CH1114 = rst ? 0 : ~(0|g48429|RCH11_);
// Gate A23-U215A
assign #0.2  g48332 = rst ? 1 : ~(0|g48331|g48333);
// Gate A23-U251B
assign #0.2  g48441 = rst ? 0 : ~(0|CHWL16_|WCH12_);
// Gate A23-U112B A23-U113A A23-U113B
assign #0.2  WCH34_ = rst ? 1 : ~(0|g48219);
// Gate A23-U214A
assign #0.2  TRUND = rst ? 0 : ~(0|F5ASB2_|g48332);
// Gate A23-U136A
assign #0.2  g48104 = rst ? 1 : ~(0|MISSY|MISSZ|MISSX);
// Gate A23-U125A
assign #0.2  CHOR06_ = rst ? 1 : ~(0|CHAT06|CHBT06|CH1606);
// Gate A23-U237A
assign #0.2  CCH07 = rst ? 0 : ~(0|XT0_|XB7_|CCHG_);
// Gate A23-U136B
assign #0.2  g48105 = rst ? 0 : ~(0|F5ASB0_|g48104);
// Gate A23-U232B
assign #0.2  CH0705 = rst ? 0 : ~(0|g48402|RCH07_);
// Gate A23-U148B
assign #0.2  g48152 = rst ? 0 : ~(0|NOXP|F18AX);
// Gate A23-U235A
assign #0.2  CH0707 = rst ? 0 : ~(0|E7_|RCH07_);
// Gate A23-U108A
assign #0.2  g48242 = rst ? 0 : ~(0|g48231|g48248|g48239);
// Gate A23-U239A
assign #0.2  RCH07_ = rst ? 1 : ~(0|g48416);
// Gate A23-U109B
assign #0.2  g48241 = rst ? 0 : ~(0|g48249|g48238|g48231);
// Gate A23-U109A
assign #0.2  g48240 = rst ? 0 : ~(0|g48249|g48239|g48230);
// Gate A23-U244A
assign #0.2  OT1113 = rst ? 0 : ~(0|g48424);
// Gate A23-U234A
assign #0.2  g48406 = rst ? 0 : ~(0|E6|g48405);
// Gate A23-U252B
assign #0.2  CH1216 = rst ? 0 : ~(0|g48442|RCH12_);
// Gate A23-U108B
assign #0.2  g48243 = rst ? 0 : ~(0|g48248|g48238|g48230);
// Gate A23-U210B
assign #0.2  TRNDM = rst ? 0 : ~(0|g48338|MOUT_);
// Gate A23-U241A
assign #0.2  CH1108 = rst ? 0 : ~(0|RCH11_|g48419);
// Gate A23-U150A
assign #0.2  BOTHX = rst ? 0 : ~(0|g48129|g48130);
// Gate A23-U120B
assign #0.2  BOTHY = rst ? 0 : ~(0|g48230|g48231);
// Gate A23-U236B
assign #0.2  E7_ = rst ? 0 : ~(0|g48409|g48411);
// Gate A23-U234B
assign #0.2  g48405 = rst ? 0 : ~(0|WCH07_|CHWL06_);
// Gate A23-U244B
assign #0.2  g48428 = rst ? 0 : ~(0|WCH11_|CHWL14_);
// Gate A23-U152B
assign #0.2  g48128 = rst ? 1 : ~(0|F5ASB2);
// Gate A23-U227B
assign #0.2  CDUXD = rst ? 0 : ~(0|g48302|F5ASB2_);
// Gate A23-U245B
assign #0.2  OT1114 = rst ? 0 : ~(0|g48429);
// Gate A23-U118A
assign #0.2  CH01 = rst ? 0 : ~(0|RCHG_|CHOR01_);
// Gate A23-U220A
assign #0.2  g48327 = rst ? 0 : ~(0|XB2_|g48357);
// Gate A23-U127A A23-U127B
assign #0.2  CHOR05_ = rst ? 1 : ~(0|CHBT05|CHAT05|CH1505|CH1605);
// Gate A23-U135B
assign #0.2  DATA_ = rst ? 1 : ~(0|g48116|g48115);
// Gate A23-U121B
assign #0.2  g48239 = rst ? 0 : ~(0|g48238|g48237);
// Gate A23-U236A
assign #0.2  g48411 = rst ? 1 : ~(0|CCH07|E7_);
// Gate A23-U218B
assign #0.2  g48328 = rst ? 1 : ~(0|g48327);
// Gate A23-U239B
assign #0.2  g48418 = rst ? 0 : ~(0|CHWL08_|WCH11_);
// Gate A23-U125B A23-U201B
assign #0.2  T7PHS4 = rst ? 0 : ~(0|FUTEXT|T07_|PHS4_);
// Gate A23-U149B
assign #0.2  g48154 = rst ? 1 : ~(0|MISSX|F5ASB2);
// Gate A23-U232A
assign #0.2  E5 = rst ? 1 : ~(0|CCH07|g48402);
// Gate A23-U233B
assign #0.2  E6 = rst ? 1 : ~(0|g48406|CCH07);
// Gate A23-U229A
assign #0.2  CH1416 = rst ? 0 : ~(0|RCH14_|g48302);
// Gate A23-U105A
assign #0.2  g48248 = rst ? 0 : ~(0|g48246|g48249);
// Gate A23-U247A
assign #0.2  g48434 = rst ? 1 : ~(0|g48433|g48435);
// Gate A23-U247B
assign #0.2  g48433 = rst ? 0 : ~(0|WCH11_|CHWL16_);
// Gate A23-U146A
assign #0.2  g48130 = rst ? 1 : ~(0|PIPGXm);
// Gate A23-U242B
assign #0.2  g48425 = rst ? 0 : ~(0|CCH11|g48424);
// Gate A23-U126B
assign #0.2  g48231 = rst ? 1 : ~(0|PIPGYm);
// Gate A23-U121A
assign #0.2  g48238 = rst ? 1 : ~(0|g48236|g48239);
// Gate A23-U138B A23-U139B
assign #0.2  g48102 = rst ? 0 : ~(0|NOXM|NOXP|NOYP|NOZM|NOZP|NOYM);
// Gate A23-U146B
assign #0.2  g48129 = rst ? 1 : ~(0|PIPGXp);
// Gate A23-U126A
assign #0.2  g48230 = rst ? 1 : ~(0|PIPGYp);
// Gate A23-U231A
assign #0.2  g48402 = rst ? 0 : ~(0|E5|g48401);
// Gate A23-U202B
assign #0.2  T7PHS4_ = rst ? 1 : ~(0|T7PHS4);
// Gate A23-U134B
assign #0.2  g48116 = rst ? 0 : ~(0|g48113|HIGH3_|LOW7_);
// Gate A23-U217B
assign #0.2  g48322 = rst ? 1 : ~(0|g48321|g48324);
// Gate A23-U220B
assign #0.2  g48324 = rst ? 0 : ~(0|g48322|g48330|CCH14);
// Gate A23-U128A
assign #0.2  MISSY = rst ? 0 : ~(0|g48257|PIPGYm|PIPGYp);
// Gate A23-U149A
assign #0.2  MISSX = rst ? 0 : ~(0|g48154|PIPGXm|PIPGXp);
// Gate A23-U243B
assign #0.2  g48423 = rst ? 0 : ~(0|WCH11_|CHWL13_);
// Gate A23-U134A
assign #0.2  g48115 = rst ? 0 : ~(0|LOW6_|g48111|HIGH3_);
// Gate A23-U258B A23-U257A
assign #0.2  ALTEST = rst ? 0 : ~(0|g48451);
// Gate A23-U217A
assign #0.2  g48330 = rst ? 0 : ~(0|ZOUT_|g48328);
// Gate A23-U219B
assign #0.2  g48321 = rst ? 0 : ~(0|WCH14_|CHWL13_);
// Gate A23-U111B
assign #0.2  CHOR04_ = rst ? 1 : ~(0|CH1604|CHBT04|CHAT04);
// Gate A23-U218A
assign #0.2  CDUZD = rst ? 0 : ~(0|F5ASB2_|g48322);
// Gate A23-U223B
assign #0.2  g48316 = rst ? 0 : ~(0|g48357|XB1_);
// Gate A23-U147A
assign #0.2  NOXM = rst ? 1 : ~(0|g48150|PIPGXm);
// Gate A23-U148A
assign #0.2  NOXP = rst ? 1 : ~(0|g48152|PIPGXp);
// Gate A23-U216A
assign #0.2  CDUZDP = rst ? 0 : ~(0|g48328|POUT_);
// Gate A23-U157B
assign #0.2  g48144 = rst ? 1 : ~(0|g48143|g48142|g48141);
// Gate A23-U254A
assign #0.2  g48448 = rst ? 0 : ~(0|T6RPT|CCH13|T6ON_);
// Gate A23-U212A
assign #0.2  g48338 = rst ? 1 : ~(0|g48337);
// Gate A23-U147B
assign #0.2  g48150 = rst ? 0 : ~(0|NOXM|F18AX);
// Gate A23-U201A
assign #0.2  g48360 = rst ? 1 : ~(0);
// Gate A23-U129B
assign #0.2  g48255 = rst ? 0 : ~(0|NOYP|F18AX);
// Gate A23-U254B
assign #0.2  T6ON_ = rst ? 1 : ~(0|g48448|g48446);
// Gate A23-U251A
assign #0.2  g48442 = rst ? 1 : ~(0|g48441|g48443);
// Gate A23-U205A A23-U205B
assign #0.2  ZOUT_ = rst ? 1 : ~(0|ZOUT);
// Gate A23-U252A
assign #0.2  g48443 = rst ? 0 : ~(0|CCH12|g48442);
// Gate A23-U215B
assign #0.2  g48331 = rst ? 0 : ~(0|WCH14_|CHWL12_);
// Gate A23-U248B
assign #0.2  OT1116 = rst ? 0 : ~(0|g48434);
// Gate A23-U143A
assign #0.2  g48123 = rst ? 0 : ~(0|GOJAM|g48119);
// Gate A23-U111A
assign #0.2  CHOR03_ = rst ? 1 : ~(0|CHBT03|CH1603|CHAT03);
// Gate A23-U258A
assign #0.2  CH10 = rst ? 0 : ~(0|RCHG_|CHOR10_);
// Gate A23-U249B
assign #0.2  CH09 = rst ? 0 : ~(0|RCHG_|CHOR09_);
// Gate A23-U255B
assign #0.2  g48450 = rst ? 0 : ~(0|WCH13_|CHWL10_);
// Gate A23-U238A
assign #0.2  g48416 = rst ? 0 : ~(0|XB7_|XT0_);
// Gate A23-U223A
assign #0.2  CDUYD = rst ? 0 : ~(0|F5ASB2_|g48312);
// Gate A23-U104B
assign #0.2  PIPYP = rst ? 0 : ~(0|g48248|g48239|g48230);
// Gate A23-U104A
assign #0.2  PIPYM = rst ? 0 : ~(0|g48231|g48238|g48248);
// Gate A23-U225A
assign #0.2  g48312 = rst ? 1 : ~(0|g48311|g48313);
// Gate A23-U238B
assign #0.2  WCH07_ = rst ? 1 : ~(0|g48414);
// Gate A23-U221A
assign #0.2  g48320 = rst ? 0 : ~(0|ZOUT_|g48317);
// Gate A23-U222B
assign #0.2  g48317 = rst ? 1 : ~(0|g48316);
// Gate A23-U224B
assign #0.2  g48313 = rst ? 0 : ~(0|g48312|g48320|CCH14);
// Gate A23-U137B
assign #0.2  PIPAFL = rst ? 1 : ~(0|CCH33|g48107);
// Gate A23-U145B
assign #0.2  F18B_ = rst ? 1 : ~(0|F18B);
// Gate A23-U114A
assign #0.2  g48220 = rst ? 0 : ~(0|XT3_|XB4_|CCHG_);
// Gate A23-U211B
assign #0.2  g48337 = rst ? 0 : ~(0|g48357|XB3_);
// Gate A23-U213B
assign #0.2  TRNDP = rst ? 0 : ~(0|g48338|POUT_);
// Gate A23-U210A
assign #0.2  g48341 = rst ? 0 : ~(0|CHWL11_|WCH14_);
// Gate A23-U209B
assign #0.2  g48343 = rst ? 0 : ~(0|g48342|g48350|CCH14);
// Gate A23-U117B
assign #0.2  CHOR02_ = rst ? 1 : ~(0|CHAT02|CH1602|CHBT02);
// Gate A23-U228B
assign #0.2  g48311 = rst ? 0 : ~(0|WCH14_|CHWL14_);
// Gate A23-U241B
assign #0.2  OT1108 = rst ? 0 : ~(0|g48419);
// Gate A23-U228A
assign #0.2  g48306 = rst ? 0 : ~(0|XB0_|g48357);
// Gate A23-U225B
assign #0.2  g48307 = rst ? 1 : ~(0|g48306);
// Gate A23-U204A A23-U206A
assign #0.2  POUT_ = rst ? 1 : ~(0|POUT);
// Gate A23-U122A
assign #0.2  g48236 = rst ? 0 : ~(0|g48234|g48229);
// Gate A23-U230B
assign #0.2  g48301 = rst ? 0 : ~(0|CHWL16_|WCH14_);
// Gate A23-U141B
assign #0.2  g48118 = rst ? 0 : ~(0|WCHG_|XB5_|XT3_);
// Gate A23-U101B
assign #0.2  CH08 = rst ? 0 : ~(0|CHOR08_|RCHG_);
// Gate A23-U120A
assign #0.2  g48232 = rst ? 0 : ~(0|g48231|g48239|g48249);
// Gate A23-U124A
assign #0.2  CH05 = rst ? 0 : ~(0|CHOR05_|RCHG_);
// Gate A23-U110B
assign #0.2  CH04 = rst ? 0 : ~(0|CHOR04_|RCHG_);
// Gate A23-U101A
assign #0.2  CH07 = rst ? 0 : ~(0|CHOR07_|RCHG_);
// Gate A23-U124B
assign #0.2  CH06 = rst ? 0 : ~(0|RCHG_|CHOR06_);
// Gate A23-U141A
assign #0.2  g48119 = rst ? 0 : ~(0|CCHG_|XT3_|XB5_);
// Gate A23-U110A
assign #0.2  CH03 = rst ? 0 : ~(0|CHOR03_|RCHG_);
// Gate A23-U118B
assign #0.2  CH02 = rst ? 0 : ~(0|CHOR02_|RCHG_);
// Gate A23-U219A
assign #0.2  CH1413 = rst ? 0 : ~(0|RCH14_|g48322);
// Gate A23-U213A
assign #0.2  CH1412 = rst ? 0 : ~(0|RCH14_|g48332);
// Gate A23-U208B
assign #0.2  CH1411 = rst ? 0 : ~(0|RCH14_|g48342);
// Gate A23-U240B
assign #0.2  g48419 = rst ? 1 : ~(0|g48418|g48420);
// Gate A23-U106B
assign #0.2  g48247 = rst ? 0 : ~(0|g48229|g48245);
// Gate A23-U240A
assign #0.2  g48420 = rst ? 0 : ~(0|CCH11|g48419);
// Gate A23-U224A
assign #0.2  CH1414 = rst ? 0 : ~(0|RCH14_|g48312);
// Gate A23-U114B
assign #0.2  g48219 = rst ? 0 : ~(0|XT3_|WCHG_|XB4_);
// Gate A23-U105B
assign #0.2  g48249 = rst ? 1 : ~(0|g48248|g48247);
// Gate A23-U106A
assign #0.2  g48246 = rst ? 0 : ~(0|g48244|g48229);
// Gate A23-U155A
assign #0.2  g48137 = rst ? 0 : ~(0|g48138|g48135);
// Gate A23-U151A
assign #0.2  g48132 = rst ? 0 : ~(0|g48129|g48137|g48148);
// Gate A23-U237B
assign #0.2  g48414 = rst ? 0 : ~(0|XB7_|XT0_|WCHG_);
// Gate A23-U152A
assign #0.2  g48134 = rst ? 0 : ~(0|g48133|g48132);
// Gate A23-U151B
assign #0.2  g48133 = rst ? 1 : ~(0|g48131|g48134);
// Gate A23-U117A
assign #0.2  CHOR01_ = rst ? 1 : ~(0|CHBT01|CHAT01|CH1601);
// Gate A23-U208A
assign #0.2  SHAFTD = rst ? 0 : ~(0|g48342|F5ASB2_);
// Gate A23-U209A
assign #0.2  g48342 = rst ? 1 : ~(0|g48341|g48343);
// Gate A23-U259A A23-U259B
assign #0.2  CHOR10_ = rst ? 1 : ~(0|CH3210|CH1210|CH1110|CHAT10|CHBT10);
// Gate A23-U156B
assign #0.2  PIPXP = rst ? 0 : ~(0|g48138|g48129|g48147);
// Gate A23-U248A
assign #0.2  g48435 = rst ? 0 : ~(0|CCH11|g48434);
// Gate A23-U211A
assign #0.2  g48340 = rst ? 0 : ~(0|ZOUT_|g48338);
// Gate A23-U227A
assign #0.2  CDUXDP = rst ? 0 : ~(0|POUT_|g48307);
// Gate A23-U143B A23-U142A A23-U142B
assign #0.2  WCH35_ = rst ? 1 : ~(0|g48118);
// Gate A23-U246A
assign #0.2  g48429 = rst ? 1 : ~(0|g48428|g48430);
// Gate A23-U245A
assign #0.2  g48430 = rst ? 0 : ~(0|CCH11|g48429);
// Gate A23-U132B
assign #0.2  g48111 = rst ? 1 : ~(0|g48109|g48112);
// Gate A23-U132A
assign #0.2  g48112 = rst ? 0 : ~(0|g48111|CCH35);
// Gate A23-U158B
assign #0.2  g48142 = rst ? 0 : ~(0|g48129|g48137|g48147);
// Gate A23-U157A
assign #0.2  g48143 = rst ? 0 : ~(0|g48144|g48139|g48140);
// Gate A23-U115A
assign #0.2  g48224 = rst ? 0 : ~(0|g48220|GOJAM);
// Gate A23-U158A
assign #0.2  g48141 = rst ? 0 : ~(0|g48147|g48130|g48138);
// Gate A23-U226B
assign #0.2  CDUXDM = rst ? 0 : ~(0|g48307|MOUT_);
// Gate A23-U130B
assign #0.2  g48253 = rst ? 0 : ~(0|F18AX|NOYM);
// Gate A23-U159B
assign #0.2  g48146 = rst ? 0 : ~(0|g48144|g48128);
// Gate A23-U203A
assign #0.2  SHFTDM = rst ? 0 : ~(0|MOUT_|g48347);
// Gate A23-U159A
assign #0.2  g48145 = rst ? 0 : ~(0|g48128|g48143);
// Gate A23-U128B
assign #0.2  g48257 = rst ? 1 : ~(0|F5ASB2|MISSY);
// Gate A23-U154A
assign #0.2  g48140 = rst ? 0 : ~(0|g48137|g48130|g48148);
// Gate A23-U206B
assign #0.2  SHFTDP = rst ? 0 : ~(0|g48347|POUT_);
// Gate A23-U255A
assign #0.2  CH1316 = rst ? 0 : ~(0|RCH13_|T6ON_);
// Gate A23-U154B
assign #0.2  g48139 = rst ? 0 : ~(0|g48148|g48138|g48129);
// Gate A23-U229B
assign #0.2  g48303 = rst ? 0 : ~(0|g48310|g48302|CCH14);
// Gate A23-U207A A23-U203B
assign #0.2  MOUT_ = rst ? 1 : ~(0|MOUT);
// Gate A23-U107A
assign #0.2  g48244 = rst ? 1 : ~(0|g48240|g48241|g48245);
// Gate A23-U119A
assign #0.2  g48229 = rst ? 1 : ~(0|F5ASB2);
// Gate A23-U214B
assign #0.2  g48333 = rst ? 0 : ~(0|g48340|g48332|CCH14);
// Gate A23-U222A
assign #0.2  CDUYDP = rst ? 0 : ~(0|POUT_|g48317);
// Gate A23-U107B
assign #0.2  g48245 = rst ? 0 : ~(0|g48244|g48242|g48243);
// Gate A23-U122B
assign #0.2  g48237 = rst ? 0 : ~(0|g48235|g48229);
// Gate A23-U221B
assign #0.2  CDUYDM = rst ? 0 : ~(0|g48317|MOUT_);
// Gate A23-U103B A23-U102B
assign #0.2  CHOR08_ = rst ? 1 : ~(0|CHBT08|CHAT08|CH1208|CH1108);
// Gate A23-U156A
assign #0.2  PIPXM = rst ? 0 : ~(0|g48130|g48147|g48137);
// Gate A23-U226A
assign #0.2  g48310 = rst ? 0 : ~(0|ZOUT_|g48307);
// Gate A23-U253B
assign #0.2  ISSTDC = rst ? 0 : ~(0|g48442);
// Gate A23-U216B
assign #0.2  CDUZDM = rst ? 0 : ~(0|g48328|MOUT_);

endmodule
