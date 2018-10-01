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

assign U229Pad9 = rst ? 0 : ~(0|U226Pad1|U227Pad7|CCH14);
assign U230Pad2 = rst ? 0 : ~(0|CHWL16_|WCH14_);
assign U121Pad2 = rst ? 0 : ~(0|U122Pad2|U106Pad3);
assign U244Pad9 = rst ? 0 : ~(0|WCH11_|CHWL14_);
assign U121Pad8 = rst ? 0 : ~(0|U122Pad7|U106Pad3);
assign U226Pad1 = rst ? 0 : ~(0|ZOUT_|U225Pad9);
assign CHOR07_ = rst ? 0 : ~(0|CH1607|CHBT07|CHAT07);
assign U254Pad1 = rst ? 0 : ~(0|T6RPT|CCH13|T6ON_);
assign U215Pad2 = rst ? 0 : ~(0|WCH14_|CHWL12_);
assign U251Pad2 = rst ? 0 : ~(0|CHWL16_|WCH12_);
assign CCH34 = rst ? 0 : ~(0|U115Pad1);
assign CCH35 = rst ? 0 : ~(0|U143Pad1);
assign ISSTDC = rst ? 0 : ~(0|U251Pad1);
assign U106Pad2 = rst ? 0 : ~(0|U107Pad2|U107Pad3|U106Pad8);
assign U129Pad2 = rst ? 0 : ~(0|NOYP|F18AX);
assign U235Pad9 = rst ? 0 : ~(0|WCH07_|CHWL07_);
assign U208Pad2 = rst ? 0 : ~(0|U209Pad2|U209Pad3);
assign NOYP = rst ? 0 : ~(0|U129Pad2|PIPGYp);
assign CH1113 = rst ? 0 : ~(0|RCH11_|U242Pad3);
assign CH1116 = rst ? 0 : ~(0|RCH11_|U247Pad1);
assign CH1114 = rst ? 0 : ~(0|U245Pad3|RCH11_);
assign CHOR09_ = rst ? 0 : ~(0|CHAT09|CHBT09|CH3209|CH1209|CH1109);
assign U221Pad3 = rst ? 0 : ~(0|U222Pad8);
assign U133Pad1 = rst ? 0 : ~(0|U133Pad2|CCH35);
assign U133Pad2 = rst ? 0 : ~(0|U131Pad1|U133Pad1);
assign U238Pad1 = rst ? 0 : ~(0|XB7_|XT0_);
assign U253Pad1 = rst ? 0 : ~(0|WCH13_|CHWL16_);
assign WCH34_ = rst ? 0 : ~(0|U112Pad8);
assign TRUND = rst ? 0 : ~(0|F5ASB2_|U213Pad3);
assign CH1108 = rst ? 0 : ~(0|RCH11_|U240Pad3);
assign CHOR06_ = rst ? 0 : ~(0|CHAT06|CHBT06|CH1606);
assign CCH07 = rst ? 0 : ~(0|XT0_|XB7_|CCHG_);
assign CH0705 = rst ? 0 : ~(0|U231Pad1|RCH07_);
assign CH0706 = rst ? 0 : ~(0|RCH07_|U233Pad3);
assign CH0707 = rst ? 0 : ~(0|E7_|RCH07_);
assign U104Pad7 = rst ? 0 : ~(0|U104Pad3|U121Pad8);
assign RCH07_ = rst ? 0 : ~(0|U238Pad1);
assign U221Pad1 = rst ? 0 : ~(0|ZOUT_|U221Pad3);
assign U104Pad4 = rst ? 0 : ~(0|U105Pad2|U105Pad3);
assign U104Pad3 = rst ? 0 : ~(0|U121Pad2|U104Pad7);
assign U104Pad2 = rst ? 0 : ~(0|PIPGYm);
assign U150Pad6 = rst ? 0 : ~(0|U159Pad9|U156Pad3);
assign U150Pad7 = rst ? 0 : ~(0|U153Pad9|U151Pad3);
assign U115Pad1 = rst ? 0 : ~(0|U114Pad1|GOJAM);
assign U150Pad9 = rst ? 0 : ~(0|U150Pad6|U150Pad7|U146Pad1);
assign U224Pad9 = rst ? 0 : ~(0|U223Pad3|U221Pad1|CCH14);
assign U104Pad8 = rst ? 0 : ~(0|PIPGYp);
assign U159Pad1 = rst ? 0 : ~(0|U152Pad9|U157Pad1);
assign BOTHX = rst ? 0 : ~(0|U146Pad9|U146Pad1);
assign BOTHY = rst ? 0 : ~(0|U104Pad8|U104Pad2);
assign E7_ = rst ? 0 : ~(0|U235Pad9|U236Pad1);
assign U256Pad3 = rst ? 0 : ~(0|U256Pad1|U255Pad9);
assign U216Pad2 = rst ? 0 : ~(0|U218Pad8);
assign CH1316 = rst ? 0 : ~(0|RCH13_|T6ON_);
assign T6ON_ = rst ? 0 : ~(0|U254Pad1|U253Pad1);
assign U107Pad7 = rst ? 0 : ~(0|U104Pad2|U104Pad4|U104Pad7);
assign U120Pad1 = rst ? 0 : ~(0|U104Pad2|U104Pad7|U105Pad3);
assign U107Pad2 = rst ? 0 : ~(0|U105Pad3|U104Pad7|U104Pad8);
assign U107Pad3 = rst ? 0 : ~(0|U105Pad3|U104Pad3|U104Pad2);
assign U222Pad8 = rst ? 0 : ~(0|U207Pad7|XB1_);
assign CH1310 = rst ? 0 : ~(0|U256Pad3|RCH13_);
assign U107Pad8 = rst ? 0 : ~(0|U104Pad4|U104Pad3|U104Pad8);
assign CHOR05_ = rst ? 0 : ~(0|CHBT05|CHAT05|CH1505|CH1605);
assign DATA_ = rst ? 0 : ~(0|U134Pad9|U134Pad1);
assign U211Pad9 = rst ? 0 : ~(0|U207Pad7|XB3_);
assign U112Pad8 = rst ? 0 : ~(0|XT3_|WCHG_|XB4_);
assign U131Pad1 = rst ? 0 : ~(0|PC15_|WCH35_);
assign U237Pad9 = rst ? 0 : ~(0|XB7_|XT0_|WCHG_);
assign U131Pad9 = rst ? 0 : ~(0|CHWL01_|WCH35_);
assign T7PHS4 = rst ? 0 : ~(0|FUTEXT|T07_|PHS4_);
assign E5 = rst ? 0 : ~(0|CCH07|U231Pad1);
assign E6 = rst ? 0 : ~(0|U233Pad3|CCH07);
assign U119Pad9 = rst ? 0 : ~(0|U105Pad3|U104Pad3|U104Pad8);
assign CH1416 = rst ? 0 : ~(0|RCH14_|U227Pad7);
assign U239Pad9 = rst ? 0 : ~(0|CHWL08_|WCH11_);
assign U153Pad1 = rst ? 0 : ~(0|U152Pad9|U151Pad9);
assign U231Pad3 = rst ? 0 : ~(0|WCH07_|CHWL05_);
assign U153Pad9 = rst ? 0 : ~(0|U151Pad8|U152Pad9);
assign U156Pad3 = rst ? 0 : ~(0|U150Pad6|U159Pad1);
assign T7PHS4_ = rst ? 0 : ~(0|T7PHS4);
assign U157Pad7 = rst ? 0 : ~(0|U146Pad9|U151Pad3|U156Pad3);
assign U149Pad2 = rst ? 0 : ~(0|MISSX|F5ASB2);
assign MISSX = rst ? 0 : ~(0|U149Pad2|PIPGXm|PIPGXp);
assign U157Pad1 = rst ? 0 : ~(0|U157Pad2|U154Pad9|U154Pad1);
assign ZOUT_ = rst ? 0 : ~(0|ZOUT);
assign ALTEST = rst ? 0 : ~(0|U256Pad3);
assign U130Pad2 = rst ? 0 : ~(0|F18AX|NOYM);
assign CHOR04_ = rst ? 0 : ~(0|CH1604|CHBT04|CHAT04);
assign U157Pad8 = rst ? 0 : ~(0|U156Pad3|U146Pad1|U150Pad7);
assign U146Pad1 = rst ? 0 : ~(0|PIPGXm);
assign U202Pad3 = rst ? 0 : ~(0|U204Pad8);
assign U202Pad1 = rst ? 0 : ~(0|ZOUT_|U202Pad3);
assign CDUZD = rst ? 0 : ~(0|F5ASB2_|U217Pad9);
assign U146Pad9 = rst ? 0 : ~(0|PIPGXp);
assign U114Pad1 = rst ? 0 : ~(0|XT3_|XB4_|CCHG_);
assign CDUZDM = rst ? 0 : ~(0|U216Pad2|MOUT_);
assign NOXM = rst ? 0 : ~(0|U147Pad2|PIPGXm);
assign U138Pad9 = rst ? 0 : ~(0|NOXM|NOXP|NOYP|NOZM|NOZP|NOYM);
assign NOXP = rst ? 0 : ~(0|U148Pad2|PIPGXp);
assign U209Pad3 = rst ? 0 : ~(0|U208Pad2|U202Pad1|CCH14);
assign U209Pad2 = rst ? 0 : ~(0|CHWL11_|WCH14_);
assign CDUZDP = rst ? 0 : ~(0|U216Pad2|POUT_);
assign MISSY = rst ? 0 : ~(0|U128Pad2|PIPGYm|PIPGYp);
assign U255Pad9 = rst ? 0 : ~(0|WCH13_|CHWL10_);
assign U148Pad2 = rst ? 0 : ~(0|NOXP|F18AX);
assign U157Pad2 = rst ? 0 : ~(0|U157Pad1|U157Pad7|U157Pad8);
assign NOYM = rst ? 0 : ~(0|U130Pad2|PIPGYm);
assign U106Pad3 = rst ? 0 : ~(0|F5ASB2);
assign U141Pad9 = rst ? 0 : ~(0|WCHG_|XB5_|XT3_);
assign U233Pad3 = rst ? 0 : ~(0|E6|U234Pad3);
assign U231Pad1 = rst ? 0 : ~(0|E5|U231Pad3);
assign U106Pad8 = rst ? 0 : ~(0|U106Pad2|U107Pad7|U107Pad8);
assign U141Pad1 = rst ? 0 : ~(0|CCHG_|XT3_|XB5_);
assign OT1113 = rst ? 0 : ~(0|U242Pad3);
assign OT1116 = rst ? 0 : ~(0|U247Pad1);
assign OT1114 = rst ? 0 : ~(0|U245Pad3);
assign CHOR03_ = rst ? 0 : ~(0|CHBT03|CH1603|CHAT03);
assign CH10 = rst ? 0 : ~(0|RCHG_|CHOR10_);
assign U204Pad8 = rst ? 0 : ~(0|U207Pad7|XB4_);
assign CDUYD = rst ? 0 : ~(0|F5ASB2_|U223Pad3);
assign PIPYP = rst ? 0 : ~(0|U104Pad4|U104Pad7|U104Pad8);
assign U218Pad8 = rst ? 0 : ~(0|XB2_|U207Pad7);
assign PIPYM = rst ? 0 : ~(0|U104Pad2|U104Pad3|U104Pad4);
assign U207Pad7 = rst ? 0 : ~(0|OCTAD5);
assign U213Pad3 = rst ? 0 : ~(0|U215Pad2|U214Pad9);
assign WCH07_ = rst ? 0 : ~(0|U237Pad9);
assign U245Pad1 = rst ? 0 : ~(0|CCH11|U245Pad3);
assign U247Pad3 = rst ? 0 : ~(0|CCH11|U247Pad1);
assign U245Pad3 = rst ? 0 : ~(0|U244Pad9|U245Pad1);
assign CHOR10_ = rst ? 0 : ~(0|CH3210|CH1210|CH1110|CHAT10|CHBT10);
assign U236Pad1 = rst ? 0 : ~(0|CCH07|E7_);
assign PIPAFL = rst ? 0 : ~(0|CCH33|U137Pad1);
assign F18B_ = rst ? 0 : ~(0|F18B);
assign TRNDP = rst ? 0 : ~(0|U210Pad7|POUT_);
assign TRNDM = rst ? 0 : ~(0|U210Pad7|MOUT_);
assign U227Pad7 = rst ? 0 : ~(0|U230Pad2|U229Pad9);
assign CHOR02_ = rst ? 0 : ~(0|CHAT02|CH1602|CHBT02);
assign OT1108 = rst ? 0 : ~(0|U240Pad3);
assign POUT_ = rst ? 0 : ~(0|POUT);
assign U159Pad9 = rst ? 0 : ~(0|U157Pad2|U152Pad9);
assign CH09 = rst ? 0 : ~(0|RCHG_|CHOR09_);
assign CH08 = rst ? 0 : ~(0|CHOR08_|RCHG_);
assign U211Pad1 = rst ? 0 : ~(0|ZOUT_|U210Pad7);
assign CH05 = rst ? 0 : ~(0|CHOR05_|RCHG_);
assign CH04 = rst ? 0 : ~(0|CHOR04_|RCHG_);
assign CH07 = rst ? 0 : ~(0|CHOR07_|RCHG_);
assign CH06 = rst ? 0 : ~(0|RCHG_|CHOR06_);
assign CH01 = rst ? 0 : ~(0|RCHG_|CHOR01_);
assign CH1216 = rst ? 0 : ~(0|U251Pad1|RCH12_);
assign CH03 = rst ? 0 : ~(0|CHOR03_|RCHG_);
assign CH02 = rst ? 0 : ~(0|CHOR02_|RCHG_);
assign CH1413 = rst ? 0 : ~(0|RCH14_|U217Pad9);
assign CH1412 = rst ? 0 : ~(0|RCH14_|U213Pad3);
assign CH1411 = rst ? 0 : ~(0|RCH14_|U208Pad2);
assign U134Pad9 = rst ? 0 : ~(0|U133Pad2|HIGH3_|LOW7_);
assign U154Pad1 = rst ? 0 : ~(0|U151Pad3|U146Pad1|U150Pad6);
assign CH1414 = rst ? 0 : ~(0|RCH14_|U223Pad3);
assign U134Pad1 = rst ? 0 : ~(0|LOW6_|U132Pad2|HIGH3_);
assign U154Pad9 = rst ? 0 : ~(0|U150Pad6|U150Pad7|U146Pad9);
assign CDUXDM = rst ? 0 : ~(0|U225Pad9|MOUT_);
assign U234Pad3 = rst ? 0 : ~(0|WCH07_|CHWL06_);
assign U243Pad2 = rst ? 0 : ~(0|WCH11_|CHWL13_);
assign CHOR01_ = rst ? 0 : ~(0|CHBT01|CHAT01|CH1601);
assign SHAFTD = rst ? 0 : ~(0|U208Pad2|F5ASB2_);
assign U242Pad3 = rst ? 0 : ~(0|U243Pad2|U242Pad9);
assign U240Pad1 = rst ? 0 : ~(0|CCH11|U240Pad3);
assign U105Pad8 = rst ? 0 : ~(0|U106Pad3|U106Pad8);
assign U240Pad3 = rst ? 0 : ~(0|U239Pad9|U240Pad1);
assign U128Pad2 = rst ? 0 : ~(0|F5ASB2|MISSY);
assign U105Pad2 = rst ? 0 : ~(0|U106Pad2|U106Pad3);
assign U105Pad3 = rst ? 0 : ~(0|U104Pad4|U105Pad8);
assign WCH35_ = rst ? 0 : ~(0|U141Pad9);
assign U151Pad1 = rst ? 0 : ~(0|U146Pad9|U151Pad3|U150Pad6);
assign U217Pad8 = rst ? 0 : ~(0|U217Pad9|U217Pad1|CCH14);
assign U147Pad2 = rst ? 0 : ~(0|NOXM|F18AX);
assign U152Pad9 = rst ? 0 : ~(0|F5ASB2);
assign U136Pad1 = rst ? 0 : ~(0|MISSY|MISSZ|MISSX);
assign U151Pad9 = rst ? 0 : ~(0|U150Pad9|U151Pad8);
assign U151Pad8 = rst ? 0 : ~(0|U151Pad9|U151Pad1);
assign U214Pad9 = rst ? 0 : ~(0|U211Pad1|U213Pad3|CCH14);
assign U137Pad1 = rst ? 0 : ~(0|BOTHZ|BOTHY|BOTHX|PIPAFL|U137Pad3|U136Pad9);
assign U251Pad3 = rst ? 0 : ~(0|CCH12|U251Pad1);
assign U137Pad3 = rst ? 0 : ~(0|F18B_|U138Pad9);
assign U251Pad1 = rst ? 0 : ~(0|U251Pad2|U251Pad3);
assign U143Pad1 = rst ? 0 : ~(0|GOJAM|U141Pad1);
assign U223Pad3 = rst ? 0 : ~(0|U225Pad2|U224Pad9);
assign SHFTDM = rst ? 0 : ~(0|MOUT_|U202Pad3);
assign U132Pad1 = rst ? 0 : ~(0|U132Pad2|CCH35);
assign U132Pad2 = rst ? 0 : ~(0|U131Pad9|U132Pad1);
assign U210Pad7 = rst ? 0 : ~(0|U211Pad9);
assign U151Pad3 = rst ? 0 : ~(0|U150Pad7|U153Pad1);
assign U136Pad9 = rst ? 0 : ~(0|F5ASB0_|U136Pad1);
assign SHFTDP = rst ? 0 : ~(0|U202Pad3|POUT_);
assign CDUXD = rst ? 0 : ~(0|U227Pad7|F5ASB2_);
assign U122Pad7 = rst ? 0 : ~(0|U119Pad9|U122Pad2);
assign U247Pad2 = rst ? 0 : ~(0|WCH11_|CHWL16_);
assign U247Pad1 = rst ? 0 : ~(0|U247Pad2|U247Pad3);
assign MOUT_ = rst ? 0 : ~(0|MOUT);
assign U122Pad2 = rst ? 0 : ~(0|U122Pad7|U120Pad1);
assign U242Pad9 = rst ? 0 : ~(0|CCH11|U242Pad3);
assign CDUXDP = rst ? 0 : ~(0|POUT_|U225Pad9);
assign CDUYDP = rst ? 0 : ~(0|POUT_|U221Pad3);
assign PIPXP = rst ? 0 : ~(0|U150Pad7|U146Pad9|U156Pad3);
assign CDUYDM = rst ? 0 : ~(0|U221Pad3|MOUT_);
assign U217Pad9 = rst ? 0 : ~(0|U217Pad7|U217Pad8);
assign CHOR08_ = rst ? 0 : ~(0|CHBT08|CHAT08|CH1208|CH1108);
assign PIPXM = rst ? 0 : ~(0|U146Pad1|U156Pad3|U151Pad3);
assign U225Pad2 = rst ? 0 : ~(0|WCH14_|CHWL14_);
assign J3Pad302 = rst ? 0 : ~(0);
assign U217Pad1 = rst ? 0 : ~(0|ZOUT_|U216Pad2);
assign U217Pad7 = rst ? 0 : ~(0|WCH14_|CHWL13_);
assign U256Pad1 = rst ? 0 : ~(0|CCH13|U256Pad3);
assign U225Pad9 = rst ? 0 : ~(0|U225Pad8);
assign U225Pad8 = rst ? 0 : ~(0|XB0_|U207Pad7);

endmodule
