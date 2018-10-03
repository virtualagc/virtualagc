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

// Gate A23-U131A
assign #0.2  A23U131Pad1 = rst ? 0 : ~(0|PC15_|WCH35_);
// Gate A23-U207B
assign #0.2  A23U204Pad8 = rst ? 0 : ~(0|A23U207Pad7|XB4_);
// Gate A23-U131B
assign #0.2  A23U131Pad9 = rst ? 0 : ~(0|CHWL01_|WCH35_);
// Gate A23-U243A
assign #0.2  A23U242Pad3 = rst ? 1 : ~(0|A23U243Pad2|A23U242Pad9);
// Gate A23-U139A
assign #0.2  A23U137Pad3 = rst ? 0 : ~(0|F18B_|A23U138Pad9);
// Gate A23-U138A A23-U137A
assign #0.2  A23U137Pad1 = rst ? 0 : ~(0|BOTHZ|BOTHY|BOTHX|PIPAFL|A23U137Pad3|A23U136Pad9);
// Gate A23-U257B
assign #0.2  CH1310 = rst ? 0 : ~(0|A23U256Pad3|RCH13_);
// Gate A23-U103A
assign #0.2  CHOR07_ = rst ? 1 : ~(0|CH1607|CHBT07|CHAT07);
// Gate A23-U119B
assign #0.2  A23U119Pad9 = rst ? 0 : ~(0|A23U105Pad3|A23U104Pad3|A23U104Pad8);
// Gate A23-U231B
assign #0.2  A23U231Pad3 = rst ? 0 : ~(0|WCH07_|CHWL05_);
// Gate A23-U153A
assign #0.2  A23U153Pad1 = rst ? 0 : ~(0|A23U152Pad9|A23U151Pad9);
// Gate A23-U116A A23-U116B A23-U115B
assign #0.2  CCH34 = rst ? 1 : ~(0|A23U115Pad1);
// Gate A23-U145A A23-U144A A23-U144B
assign #0.2  CCH35 = rst ? 1 : ~(0|A23U143Pad1);
// Gate A23-U133B
assign #0.2  A23U133Pad2 = rst ? 1 : ~(0|A23U131Pad1|A23U133Pad1);
// Gate A23-U133A
assign #0.2  A23U133Pad1 = rst ? 0 : ~(0|A23U133Pad2|CCH35);
// Gate A23-U153B
assign #0.2  A23U153Pad9 = rst ? 0 : ~(0|A23U151Pad8|A23U152Pad9);
// Gate A23-U253A
assign #0.2  A23U253Pad1 = rst ? 0 : ~(0|WCH13_|CHWL16_);
// Gate A23-U130A
assign #0.2  NOYM = rst ? 1 : ~(0|A23U130Pad2|PIPGYm);
// Gate A23-U160A
assign #0.2  A23U156Pad3 = rst ? 0 : ~(0|A23U150Pad6|A23U159Pad1);
// Gate A23-U256B
assign #0.2  A23U256Pad3 = rst ? 1 : ~(0|A23U256Pad1|A23U255Pad9);
// Gate A23-U230A
assign #0.2  A23U227Pad7 = rst ? 1 : ~(0|A23U230Pad2|A23U229Pad9);
// Gate A23-U233A
assign #0.2  CH0706 = rst ? 0 : ~(0|RCH07_|A23U233Pad3);
// Gate A23-U129A
assign #0.2  NOYP = rst ? 1 : ~(0|A23U129Pad2|PIPGYp);
// Gate A23-U242A
assign #0.2  CH1113 = rst ? 0 : ~(0|RCH11_|A23U242Pad3);
// Gate A23-U256A
assign #0.2  A23U256Pad1 = rst ? 0 : ~(0|CCH13|A23U256Pad3);
// Gate A23-U249A
assign #0.2  CH1116 = rst ? 0 : ~(0|RCH11_|A23U247Pad1);
// Gate A23-U235B
assign #0.2  A23U235Pad9 = rst ? 0 : ~(0|WCH07_|CHWL07_);
// Gate A23-U250A A23-U250B
assign #0.2  CHOR09_ = rst ? 1 : ~(0|CHAT09|CHBT09|CH3209|CH1209|CH1109);
// Gate A23-U202A
assign #0.2  A23U202Pad1 = rst ? 0 : ~(0|ZOUT_|A23U202Pad3);
// Gate A23-U204B
assign #0.2  A23U202Pad3 = rst ? 1 : ~(0|A23U204Pad8);
// Gate A23-U123B
assign #0.2  A23U122Pad7 = rst ? 0 : ~(0|A23U119Pad9|A23U122Pad2);
// Gate A23-U155B
assign #0.2  A23U150Pad7 = rst ? 0 : ~(0|A23U153Pad9|A23U151Pad3);
// Gate A23-U160B
assign #0.2  A23U150Pad6 = rst ? 1 : ~(0|A23U159Pad9|A23U156Pad3);
// Gate A23-U123A
assign #0.2  A23U122Pad2 = rst ? 1 : ~(0|A23U122Pad7|A23U120Pad1);
// Gate A23-U212B
assign #0.2  A23U207Pad7 = rst ? 1 : ~(0|OCTAD5);
// Gate A23-U150B
assign #0.2  A23U150Pad9 = rst ? 0 : ~(0|A23U150Pad6|A23U150Pad7|A23U146Pad1);
// Gate A23-U246B
assign #0.2  CH1114 = rst ? 0 : ~(0|A23U245Pad3|RCH11_);
// Gate A23-U215A
assign #0.2  A23U213Pad3 = rst ? 1 : ~(0|A23U215Pad2|A23U214Pad9);
// Gate A23-U251B
assign #0.2  A23U251Pad2 = rst ? 0 : ~(0|CHWL16_|WCH12_);
// Gate A23-U112B A23-U113A A23-U113B
assign #0.2  WCH34_ = rst ? 1 : ~(0|A23U112Pad8);
// Gate A23-U214A
assign #0.2  TRUND = rst ? 0 : ~(0|F5ASB2_|A23U213Pad3);
// Gate A23-U136A
assign #0.2  A23U136Pad1 = rst ? 0 : ~(0|MISSY|MISSZ|MISSX);
// Gate A23-U125A
assign #0.2  CHOR06_ = rst ? 1 : ~(0|CHAT06|CHBT06|CH1606);
// Gate A23-U237A
assign #0.2  CCH07 = rst ? 0 : ~(0|XT0_|XB7_|CCHG_);
// Gate A23-U136B
assign #0.2  A23U136Pad9 = rst ? 0 : ~(0|F5ASB0_|A23U136Pad1);
// Gate A23-U232B
assign #0.2  CH0705 = rst ? 0 : ~(0|A23U231Pad1|RCH07_);
// Gate A23-U148B
assign #0.2  A23U148Pad2 = rst ? 0 : ~(0|NOXP|F18AX);
// Gate A23-U235A
assign #0.2  CH0707 = rst ? 0 : ~(0|E7_|RCH07_);
// Gate A23-U108A
assign #0.2  A23U107Pad7 = rst ? 0 : ~(0|A23U104Pad2|A23U104Pad4|A23U104Pad7);
// Gate A23-U239A
assign #0.2  RCH07_ = rst ? 1 : ~(0|A23U238Pad1);
// Gate A23-U109B
assign #0.2  A23U107Pad3 = rst ? 0 : ~(0|A23U105Pad3|A23U104Pad3|A23U104Pad2);
// Gate A23-U109A
assign #0.2  A23U107Pad2 = rst ? 0 : ~(0|A23U105Pad3|A23U104Pad7|A23U104Pad8);
// Gate A23-U244A
assign #0.2  OT1113 = rst ? 0 : ~(0|A23U242Pad3);
// Gate A23-U234A
assign #0.2  A23U233Pad3 = rst ? 0 : ~(0|E6|A23U234Pad3);
// Gate A23-U252B
assign #0.2  CH1216 = rst ? 0 : ~(0|A23U251Pad1|RCH12_);
// Gate A23-U108B
assign #0.2  A23U107Pad8 = rst ? 0 : ~(0|A23U104Pad4|A23U104Pad3|A23U104Pad8);
// Gate A23-U210B
assign #0.2  TRNDM = rst ? 0 : ~(0|A23U210Pad7|MOUT_);
// Gate A23-U241A
assign #0.2  CH1108 = rst ? 0 : ~(0|RCH11_|A23U240Pad3);
// Gate A23-U150A
assign #0.2  BOTHX = rst ? 0 : ~(0|A23U146Pad9|A23U146Pad1);
// Gate A23-U120B
assign #0.2  BOTHY = rst ? 0 : ~(0|A23U104Pad8|A23U104Pad2);
// Gate A23-U236B
assign #0.2  E7_ = rst ? 0 : ~(0|A23U235Pad9|A23U236Pad1);
// Gate A23-U234B
assign #0.2  A23U234Pad3 = rst ? 0 : ~(0|WCH07_|CHWL06_);
// Gate A23-U244B
assign #0.2  A23U244Pad9 = rst ? 0 : ~(0|WCH11_|CHWL14_);
// Gate A23-U152B
assign #0.2  A23U152Pad9 = rst ? 1 : ~(0|F5ASB2);
// Gate A23-U227B
assign #0.2  CDUXD = rst ? 0 : ~(0|A23U227Pad7|F5ASB2_);
// Gate A23-U245B
assign #0.2  OT1114 = rst ? 0 : ~(0|A23U245Pad3);
// Gate A23-U118A
assign #0.2  CH01 = rst ? 0 : ~(0|RCHG_|CHOR01_);
// Gate A23-U220A
assign #0.2  A23U218Pad8 = rst ? 0 : ~(0|XB2_|A23U207Pad7);
// Gate A23-U127A A23-U127B
assign #0.2  CHOR05_ = rst ? 1 : ~(0|CHBT05|CHAT05|CH1505|CH1605);
// Gate A23-U135B
assign #0.2  DATA_ = rst ? 1 : ~(0|A23U134Pad9|A23U134Pad1);
// Gate A23-U121B
assign #0.2  A23U104Pad7 = rst ? 0 : ~(0|A23U104Pad3|A23U121Pad8);
// Gate A23-U236A
assign #0.2  A23U236Pad1 = rst ? 1 : ~(0|CCH07|E7_);
// Gate A23-U218B
assign #0.2  A23U216Pad2 = rst ? 1 : ~(0|A23U218Pad8);
// Gate A23-U239B
assign #0.2  A23U239Pad9 = rst ? 0 : ~(0|CHWL08_|WCH11_);
// Gate A23-U125B A23-U201B
assign #0.2  T7PHS4 = rst ? 0 : ~(0|FUTEXT|T07_|PHS4_);
// Gate A23-U149B
assign #0.2  A23U149Pad2 = rst ? 0 : ~(0|MISSX|F5ASB2);
// Gate A23-U232A
assign #0.2  E5 = rst ? 0 : ~(0|CCH07|A23U231Pad1);
// Gate A23-U233B
assign #0.2  E6 = rst ? 1 : ~(0|A23U233Pad3|CCH07);
// Gate A23-U229A
assign #0.2  CH1416 = rst ? 0 : ~(0|RCH14_|A23U227Pad7);
// Gate A23-U105A
assign #0.2  A23U104Pad4 = rst ? 1 : ~(0|A23U105Pad2|A23U105Pad3);
// Gate A23-U247A
assign #0.2  A23U247Pad1 = rst ? 1 : ~(0|A23U247Pad2|A23U247Pad3);
// Gate A23-U247B
assign #0.2  A23U247Pad2 = rst ? 0 : ~(0|WCH11_|CHWL16_);
// Gate A23-U146A
assign #0.2  A23U146Pad1 = rst ? 1 : ~(0|PIPGXm);
// Gate A23-U242B
assign #0.2  A23U242Pad9 = rst ? 0 : ~(0|CCH11|A23U242Pad3);
// Gate A23-U126B
assign #0.2  A23U104Pad2 = rst ? 1 : ~(0|PIPGYm);
// Gate A23-U121A
assign #0.2  A23U104Pad3 = rst ? 1 : ~(0|A23U121Pad2|A23U104Pad7);
// Gate A23-U138B A23-U139B
assign #0.2  A23U138Pad9 = rst ? 0 : ~(0|NOXM|NOXP|NOYP|NOZM|NOZP|NOYM);
// Gate A23-U146B
assign #0.2  A23U146Pad9 = rst ? 1 : ~(0|PIPGXp);
// Gate A23-U126A
assign #0.2  A23U104Pad8 = rst ? 1 : ~(0|PIPGYp);
// Gate A23-U231A
assign #0.2  A23U231Pad1 = rst ? 1 : ~(0|E5|A23U231Pad3);
// Gate A23-U202B
assign #0.2  T7PHS4_ = rst ? 1 : ~(0|T7PHS4);
// Gate A23-U134B
assign #0.2  A23U134Pad9 = rst ? 0 : ~(0|A23U133Pad2|HIGH3_|LOW7_);
// Gate A23-U217B
assign #0.2  A23U217Pad9 = rst ? 1 : ~(0|A23U217Pad7|A23U217Pad8);
// Gate A23-U220B
assign #0.2  A23U217Pad8 = rst ? 0 : ~(0|A23U217Pad9|A23U217Pad1|CCH14);
// Gate A23-U128A
assign #0.2  MISSY = rst ? 1 : ~(0|A23U128Pad2|PIPGYm|PIPGYp);
// Gate A23-U149A
assign #0.2  MISSX = rst ? 1 : ~(0|A23U149Pad2|PIPGXm|PIPGXp);
// Gate A23-U243B
assign #0.2  A23U243Pad2 = rst ? 0 : ~(0|WCH11_|CHWL13_);
// Gate A23-U134A
assign #0.2  A23U134Pad1 = rst ? 0 : ~(0|LOW6_|A23U132Pad2|HIGH3_);
// Gate A23-U258B A23-U257A
assign #0.2  ALTEST = rst ? 0 : ~(0|A23U256Pad3);
// Gate A23-U217A
assign #0.2  A23U217Pad1 = rst ? 0 : ~(0|ZOUT_|A23U216Pad2);
// Gate A23-U219B
assign #0.2  A23U217Pad7 = rst ? 0 : ~(0|WCH14_|CHWL13_);
// Gate A23-U111B
assign #0.2  CHOR04_ = rst ? 1 : ~(0|CH1604|CHBT04|CHAT04);
// Gate A23-U218A
assign #0.2  CDUZD = rst ? 0 : ~(0|F5ASB2_|A23U217Pad9);
// Gate A23-U223B
assign #0.2  A23U222Pad8 = rst ? 0 : ~(0|A23U207Pad7|XB1_);
// Gate A23-U147A
assign #0.2  NOXM = rst ? 1 : ~(0|A23U147Pad2|PIPGXm);
// Gate A23-U148A
assign #0.2  NOXP = rst ? 1 : ~(0|A23U148Pad2|PIPGXp);
// Gate A23-U216A
assign #0.2  CDUZDP = rst ? 0 : ~(0|A23U216Pad2|POUT_);
// Gate A23-U157B
assign #0.2  A23U157Pad2 = rst ? 0 : ~(0|A23U157Pad1|A23U157Pad7|A23U157Pad8);
// Gate A23-U254A
assign #0.2  A23U254Pad1 = rst ? 0 : ~(0|T6RPT|CCH13|T6ON_);
// Gate A23-U212A
assign #0.2  A23U210Pad7 = rst ? 1 : ~(0|A23U211Pad9);
// Gate A23-U147B
assign #0.2  A23U147Pad2 = rst ? 0 : ~(0|NOXM|F18AX);
// Gate A23-U201A
assign #0.2  A23J3Pad302 = rst ? 1 : ~(0);
// Gate A23-U129B
assign #0.2  A23U129Pad2 = rst ? 0 : ~(0|NOYP|F18AX);
// Gate A23-U254B
assign #0.2  T6ON_ = rst ? 1 : ~(0|A23U254Pad1|A23U253Pad1);
// Gate A23-U251A
assign #0.2  A23U251Pad1 = rst ? 1 : ~(0|A23U251Pad2|A23U251Pad3);
// Gate A23-U205A A23-U205B
assign #0.2  ZOUT_ = rst ? 1 : ~(0|ZOUT);
// Gate A23-U252A
assign #0.2  A23U251Pad3 = rst ? 0 : ~(0|CCH12|A23U251Pad1);
// Gate A23-U215B
assign #0.2  A23U215Pad2 = rst ? 0 : ~(0|WCH14_|CHWL12_);
// Gate A23-U248B
assign #0.2  OT1116 = rst ? 0 : ~(0|A23U247Pad1);
// Gate A23-U143A
assign #0.2  A23U143Pad1 = rst ? 0 : ~(0|GOJAM|A23U141Pad1);
// Gate A23-U111A
assign #0.2  CHOR03_ = rst ? 1 : ~(0|CHBT03|CH1603|CHAT03);
// Gate A23-U258A
assign #0.2  CH10 = rst ? 0 : ~(0|RCHG_|CHOR10_);
// Gate A23-U249B
assign #0.2  CH09 = rst ? 0 : ~(0|RCHG_|CHOR09_);
// Gate A23-U255B
assign #0.2  A23U255Pad9 = rst ? 0 : ~(0|WCH13_|CHWL10_);
// Gate A23-U238A
assign #0.2  A23U238Pad1 = rst ? 0 : ~(0|XB7_|XT0_);
// Gate A23-U223A
assign #0.2  CDUYD = rst ? 0 : ~(0|F5ASB2_|A23U223Pad3);
// Gate A23-U104B
assign #0.2  PIPYP = rst ? 0 : ~(0|A23U104Pad4|A23U104Pad7|A23U104Pad8);
// Gate A23-U104A
assign #0.2  PIPYM = rst ? 0 : ~(0|A23U104Pad2|A23U104Pad3|A23U104Pad4);
// Gate A23-U225A
assign #0.2  A23U223Pad3 = rst ? 1 : ~(0|A23U225Pad2|A23U224Pad9);
// Gate A23-U238B
assign #0.2  WCH07_ = rst ? 1 : ~(0|A23U237Pad9);
// Gate A23-U221A
assign #0.2  A23U221Pad1 = rst ? 0 : ~(0|ZOUT_|A23U221Pad3);
// Gate A23-U222B
assign #0.2  A23U221Pad3 = rst ? 1 : ~(0|A23U222Pad8);
// Gate A23-U224B
assign #0.2  A23U224Pad9 = rst ? 0 : ~(0|A23U223Pad3|A23U221Pad1|CCH14);
// Gate A23-U137B
assign #0.2  PIPAFL = rst ? 1 : ~(0|CCH33|A23U137Pad1);
// Gate A23-U145B
assign #0.2  F18B_ = rst ? 1 : ~(0|F18B);
// Gate A23-U114A
assign #0.2  A23U114Pad1 = rst ? 0 : ~(0|XT3_|XB4_|CCHG_);
// Gate A23-U211B
assign #0.2  A23U211Pad9 = rst ? 0 : ~(0|A23U207Pad7|XB3_);
// Gate A23-U213B
assign #0.2  TRNDP = rst ? 0 : ~(0|A23U210Pad7|POUT_);
// Gate A23-U210A
assign #0.2  A23U209Pad2 = rst ? 0 : ~(0|CHWL11_|WCH14_);
// Gate A23-U209B
assign #0.2  A23U209Pad3 = rst ? 0 : ~(0|A23U208Pad2|A23U202Pad1|CCH14);
// Gate A23-U117B
assign #0.2  CHOR02_ = rst ? 1 : ~(0|CHAT02|CH1602|CHBT02);
// Gate A23-U228B
assign #0.2  A23U225Pad2 = rst ? 0 : ~(0|WCH14_|CHWL14_);
// Gate A23-U241B
assign #0.2  OT1108 = rst ? 0 : ~(0|A23U240Pad3);
// Gate A23-U228A
assign #0.2  A23U225Pad8 = rst ? 0 : ~(0|XB0_|A23U207Pad7);
// Gate A23-U225B
assign #0.2  A23U225Pad9 = rst ? 1 : ~(0|A23U225Pad8);
// Gate A23-U204A A23-U206A
assign #0.2  POUT_ = rst ? 1 : ~(0|POUT);
// Gate A23-U122A
assign #0.2  A23U121Pad2 = rst ? 0 : ~(0|A23U122Pad2|A23U106Pad3);
// Gate A23-U230B
assign #0.2  A23U230Pad2 = rst ? 0 : ~(0|CHWL16_|WCH14_);
// Gate A23-U141B
assign #0.2  A23U141Pad9 = rst ? 0 : ~(0|WCHG_|XB5_|XT3_);
// Gate A23-U101B
assign #0.2  CH08 = rst ? 0 : ~(0|CHOR08_|RCHG_);
// Gate A23-U120A
assign #0.2  A23U120Pad1 = rst ? 0 : ~(0|A23U104Pad2|A23U104Pad7|A23U105Pad3);
// Gate A23-U124A
assign #0.2  CH05 = rst ? 0 : ~(0|CHOR05_|RCHG_);
// Gate A23-U110B
assign #0.2  CH04 = rst ? 0 : ~(0|CHOR04_|RCHG_);
// Gate A23-U101A
assign #0.2  CH07 = rst ? 0 : ~(0|CHOR07_|RCHG_);
// Gate A23-U124B
assign #0.2  CH06 = rst ? 0 : ~(0|RCHG_|CHOR06_);
// Gate A23-U141A
assign #0.2  A23U141Pad1 = rst ? 0 : ~(0|CCHG_|XT3_|XB5_);
// Gate A23-U110A
assign #0.2  CH03 = rst ? 0 : ~(0|CHOR03_|RCHG_);
// Gate A23-U118B
assign #0.2  CH02 = rst ? 0 : ~(0|CHOR02_|RCHG_);
// Gate A23-U219A
assign #0.2  CH1413 = rst ? 0 : ~(0|RCH14_|A23U217Pad9);
// Gate A23-U213A
assign #0.2  CH1412 = rst ? 0 : ~(0|RCH14_|A23U213Pad3);
// Gate A23-U208B
assign #0.2  CH1411 = rst ? 0 : ~(0|RCH14_|A23U208Pad2);
// Gate A23-U240B
assign #0.2  A23U240Pad3 = rst ? 1 : ~(0|A23U239Pad9|A23U240Pad1);
// Gate A23-U106B
assign #0.2  A23U105Pad8 = rst ? 0 : ~(0|A23U106Pad3|A23U106Pad8);
// Gate A23-U240A
assign #0.2  A23U240Pad1 = rst ? 0 : ~(0|CCH11|A23U240Pad3);
// Gate A23-U224A
assign #0.2  CH1414 = rst ? 0 : ~(0|RCH14_|A23U223Pad3);
// Gate A23-U114B
assign #0.2  A23U112Pad8 = rst ? 0 : ~(0|XT3_|WCHG_|XB4_);
// Gate A23-U105B
assign #0.2  A23U105Pad3 = rst ? 0 : ~(0|A23U104Pad4|A23U105Pad8);
// Gate A23-U106A
assign #0.2  A23U105Pad2 = rst ? 0 : ~(0|A23U106Pad2|A23U106Pad3);
// Gate A23-U155A
assign #0.2  A23U151Pad3 = rst ? 1 : ~(0|A23U150Pad7|A23U153Pad1);
// Gate A23-U151A
assign #0.2  A23U151Pad1 = rst ? 0 : ~(0|A23U146Pad9|A23U151Pad3|A23U150Pad6);
// Gate A23-U237B
assign #0.2  A23U237Pad9 = rst ? 0 : ~(0|XB7_|XT0_|WCHG_);
// Gate A23-U152A
assign #0.2  A23U151Pad8 = rst ? 0 : ~(0|A23U151Pad9|A23U151Pad1);
// Gate A23-U151B
assign #0.2  A23U151Pad9 = rst ? 1 : ~(0|A23U150Pad9|A23U151Pad8);
// Gate A23-U117A
assign #0.2  CHOR01_ = rst ? 1 : ~(0|CHBT01|CHAT01|CH1601);
// Gate A23-U208A
assign #0.2  SHAFTD = rst ? 0 : ~(0|A23U208Pad2|F5ASB2_);
// Gate A23-U209A
assign #0.2  A23U208Pad2 = rst ? 1 : ~(0|A23U209Pad2|A23U209Pad3);
// Gate A23-U259A A23-U259B
assign #0.2  CHOR10_ = rst ? 1 : ~(0|CH3210|CH1210|CH1110|CHAT10|CHBT10);
// Gate A23-U156B
assign #0.2  PIPXP = rst ? 0 : ~(0|A23U150Pad7|A23U146Pad9|A23U156Pad3);
// Gate A23-U248A
assign #0.2  A23U247Pad3 = rst ? 0 : ~(0|CCH11|A23U247Pad1);
// Gate A23-U211A
assign #0.2  A23U211Pad1 = rst ? 0 : ~(0|ZOUT_|A23U210Pad7);
// Gate A23-U227A
assign #0.2  CDUXDP = rst ? 0 : ~(0|POUT_|A23U225Pad9);
// Gate A23-U143B A23-U142A A23-U142B
assign #0.2  WCH35_ = rst ? 1 : ~(0|A23U141Pad9);
// Gate A23-U246A
assign #0.2  A23U245Pad3 = rst ? 1 : ~(0|A23U244Pad9|A23U245Pad1);
// Gate A23-U245A
assign #0.2  A23U245Pad1 = rst ? 0 : ~(0|CCH11|A23U245Pad3);
// Gate A23-U132B
assign #0.2  A23U132Pad2 = rst ? 1 : ~(0|A23U131Pad9|A23U132Pad1);
// Gate A23-U132A
assign #0.2  A23U132Pad1 = rst ? 0 : ~(0|A23U132Pad2|CCH35);
// Gate A23-U158B
assign #0.2  A23U157Pad7 = rst ? 0 : ~(0|A23U146Pad9|A23U151Pad3|A23U156Pad3);
// Gate A23-U157A
assign #0.2  A23U157Pad1 = rst ? 1 : ~(0|A23U157Pad2|A23U154Pad9|A23U154Pad1);
// Gate A23-U115A
assign #0.2  A23U115Pad1 = rst ? 0 : ~(0|A23U114Pad1|GOJAM);
// Gate A23-U158A
assign #0.2  A23U157Pad8 = rst ? 0 : ~(0|A23U156Pad3|A23U146Pad1|A23U150Pad7);
// Gate A23-U226B
assign #0.2  CDUXDM = rst ? 0 : ~(0|A23U225Pad9|MOUT_);
// Gate A23-U130B
assign #0.2  A23U130Pad2 = rst ? 0 : ~(0|F18AX|NOYM);
// Gate A23-U159B
assign #0.2  A23U159Pad9 = rst ? 0 : ~(0|A23U157Pad2|A23U152Pad9);
// Gate A23-U203A
assign #0.2  SHFTDM = rst ? 0 : ~(0|MOUT_|A23U202Pad3);
// Gate A23-U159A
assign #0.2  A23U159Pad1 = rst ? 0 : ~(0|A23U152Pad9|A23U157Pad1);
// Gate A23-U128B
assign #0.2  A23U128Pad2 = rst ? 0 : ~(0|F5ASB2|MISSY);
// Gate A23-U154A
assign #0.2  A23U154Pad1 = rst ? 0 : ~(0|A23U151Pad3|A23U146Pad1|A23U150Pad6);
// Gate A23-U206B
assign #0.2  SHFTDP = rst ? 0 : ~(0|A23U202Pad3|POUT_);
// Gate A23-U255A
assign #0.2  CH1316 = rst ? 0 : ~(0|RCH13_|T6ON_);
// Gate A23-U154B
assign #0.2  A23U154Pad9 = rst ? 0 : ~(0|A23U150Pad6|A23U150Pad7|A23U146Pad9);
// Gate A23-U229B
assign #0.2  A23U229Pad9 = rst ? 0 : ~(0|A23U226Pad1|A23U227Pad7|CCH14);
// Gate A23-U207A A23-U203B
assign #0.2  MOUT_ = rst ? 1 : ~(0|MOUT);
// Gate A23-U107A
assign #0.2  A23U106Pad2 = rst ? 1 : ~(0|A23U107Pad2|A23U107Pad3|A23U106Pad8);
// Gate A23-U119A
assign #0.2  A23U106Pad3 = rst ? 1 : ~(0|F5ASB2);
// Gate A23-U214B
assign #0.2  A23U214Pad9 = rst ? 0 : ~(0|A23U211Pad1|A23U213Pad3|CCH14);
// Gate A23-U222A
assign #0.2  CDUYDP = rst ? 0 : ~(0|POUT_|A23U221Pad3);
// Gate A23-U107B
assign #0.2  A23U106Pad8 = rst ? 0 : ~(0|A23U106Pad2|A23U107Pad7|A23U107Pad8);
// Gate A23-U122B
assign #0.2  A23U121Pad8 = rst ? 0 : ~(0|A23U122Pad7|A23U106Pad3);
// Gate A23-U221B
assign #0.2  CDUYDM = rst ? 0 : ~(0|A23U221Pad3|MOUT_);
// Gate A23-U103B A23-U102B
assign #0.2  CHOR08_ = rst ? 1 : ~(0|CHBT08|CHAT08|CH1208|CH1108);
// Gate A23-U156A
assign #0.2  PIPXM = rst ? 0 : ~(0|A23U146Pad1|A23U156Pad3|A23U151Pad3);
// Gate A23-U226A
assign #0.2  A23U226Pad1 = rst ? 0 : ~(0|ZOUT_|A23U225Pad9);
// Gate A23-U253B
assign #0.2  ISSTDC = rst ? 0 : ~(0|A23U251Pad1);
// Gate A23-U216B
assign #0.2  CDUZDM = rst ? 0 : ~(0|A23U216Pad2|MOUT_);

endmodule
