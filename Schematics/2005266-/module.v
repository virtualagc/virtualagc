// Verilog module auto-generated for AGC module A16 by dumbVerilog.py

module A16 ( 
  rst, CCH11, CCHG_, CGA16, CH0705, CH0706, CH0707, CH1501, CH1502, CH1503,
  CH1504, CH3201, CH3202, CH3203, CH3204, CH3205, CH3206, CH3207, CH3208,
  CHWL01_, CHWL02_, CHWL03_, CHWL04_, CHWL05_, CHWL06_, CHWL07_, CHWL08_,
  CHWL09_, CHWL10_, CHWL11_, CHWL12_, CHWL13_, CHWL14_, FLASH, FLASH_, GOJAM,
  RCH11_, WCH11_, WCHG_, XB2_, XB5_, XB6_, XT0_, XT1_, CCH12, CH1207, CHOR01_,
  CHOR02_, CHOR03_, CHOR04_, CHOR05_, CHOR06_, CHOR07_, CHOR08_, RCH12_,
  WCH12_, CCH05, CCH06, CH1208, CH1209, CH1210, CH1211, CH1212, CH1213, CH1214,
  COARSE, COMACT, DISDAC, ENERIM, ENEROP, ISSWAR, KYRLS, MROLGT, OPEROR,
  OT1207, OT1207_, RCH05_, RCH06_, RCmXmP, RCmXmY, RCmXpP, RCmXpY, RCmYmR,
  RCmYpR, RCmZmR, RCmZpR, RCpXmP, RCpXmY, RCpXpP, RCpXpY, RCpYmR, RCpYpR,
  RCpZmR, RCpZpR, S4BOFF, S4BSEQ, S4BTAK, STARON, TMPOUT, TVCNAB, UPLACT,
  VNFLSH, WCH05_, WCH06_, ZEROPT, ZIMCDU, ZOPCDU
);

input wire rst, CCH11, CCHG_, CGA16, CH0705, CH0706, CH0707, CH1501, CH1502,
  CH1503, CH1504, CH3201, CH3202, CH3203, CH3204, CH3205, CH3206, CH3207,
  CH3208, CHWL01_, CHWL02_, CHWL03_, CHWL04_, CHWL05_, CHWL06_, CHWL07_,
  CHWL08_, CHWL09_, CHWL10_, CHWL11_, CHWL12_, CHWL13_, CHWL14_, FLASH, FLASH_,
  GOJAM, RCH11_, WCH11_, WCHG_, XB2_, XB5_, XB6_, XT0_, XT1_;

inout wire CCH12, CH1207, CHOR01_, CHOR02_, CHOR03_, CHOR04_, CHOR05_, CHOR06_,
  CHOR07_, CHOR08_, RCH12_, WCH12_;

output wire CCH05, CCH06, CH1208, CH1209, CH1210, CH1211, CH1212, CH1213,
  CH1214, COARSE, COMACT, DISDAC, ENERIM, ENEROP, ISSWAR, KYRLS, MROLGT,
  OPEROR, OT1207, OT1207_, RCH05_, RCH06_, RCmXmP, RCmXmY, RCmXpP, RCmXpY,
  RCmYmR, RCmYpR, RCmZmR, RCmZpR, RCpXmP, RCpXmY, RCpXpP, RCpXpY, RCpYmR,
  RCpYpR, RCpZmR, RCpZpR, S4BOFF, S4BSEQ, S4BTAK, STARON, TMPOUT, TVCNAB,
  UPLACT, VNFLSH, WCH05_, WCH06_, ZEROPT, ZIMCDU, ZOPCDU;

assign U242Pad2 = rst ? 0 : ~(0|U241Pad3|CCH11);
assign U229Pad8 = rst ? 0 : ~(0|U229Pad2|CCH12);
assign S4BSEQ = rst ? 0 : ~(0|U226Pad2);
assign CH1210 = rst ? 0 : ~(0|U218Pad7|RCH12_);
assign U229Pad2 = rst ? 0 : ~(0|U228Pad1|U229Pad8);
assign U121Pad9 = rst ? 0 : ~(0|RCH06_|U119Pad7);
assign RCmZmR = rst ? 0 : ~(0|U104Pad1);
assign RCmXpY = rst ? 0 : ~(0|U149Pad9);
assign RCmYpR = rst ? 0 : ~(0|U119Pad7);
assign U140Pad3 = rst ? 0 : ~(0|RCH05_|U141Pad3);
assign U226Pad2 = rst ? 0 : ~(0|U227Pad1|U227Pad8);
assign RCmXpP = rst ? 0 : ~(0|U137Pad9);
assign J2Pad271 = rst ? 0 : ~(0);
assign U111Pad2 = rst ? 0 : ~(0|U112Pad2|U112Pad3);
assign U206Pad7 = rst ? 0 : ~(0|U206Pad1|U207Pad8);
assign RCH06_ = rst ? 0 : ~(0|U123Pad8);
assign U215Pad1 = rst ? 0 : ~(0|U213Pad2|RCH12_);
assign CH1207 = rst ? 0 : ~(0|RCH12_|U117Pad2);
assign U206Pad1 = rst ? 0 : ~(0|WCH12_|CHWL03_);
assign CH1208 = rst ? 0 : ~(0|RCH12_|U159Pad1);
assign CH1209 = rst ? 0 : ~(0|U216Pad1|RCH12_);
assign U212Pad1 = rst ? 0 : ~(0|U211Pad7|RCH12_);
assign ZOPCDU = rst ? 0 : ~(0|U201Pad7);
assign U129Pad2 = rst ? 0 : ~(0|WCH06_|CHWL08_);
assign U129Pad3 = rst ? 0 : ~(0|CCH06|U128Pad7);
assign U208Pad1 = rst ? 0 : ~(0|WCH12_|CHWL04_);
assign U108Pad9 = rst ? 0 : ~(0|RCH06_|U106Pad2);
assign U251Pad1 = rst ? 0 : ~(0|U250Pad9|RCH11_);
assign U236Pad2 = rst ? 0 : ~(0|U235Pad3|CCH11);
assign U253Pad8 = rst ? 0 : ~(0|WCHG_|XT1_|XB2_);
assign U109Pad2 = rst ? 0 : ~(0|CCH06|U109Pad1);
assign U233Pad1 = rst ? 0 : ~(0|WCH11_|CHWL02_);
assign U133Pad1 = rst ? 0 : ~(0|WCH05_|CHWL02_);
assign U150Pad1 = rst ? 0 : ~(0|RCH05_|U149Pad9);
assign U238Pad1 = rst ? 0 : ~(0|RCH11_|U237Pad9);
assign CH1212 = rst ? 0 : ~(0|U224Pad2|RCH12_);
assign U244Pad1 = rst ? 0 : ~(0|WCH11_|CHWL05_);
assign U235Pad3 = rst ? 0 : ~(0|U236Pad2|U233Pad1);
assign CHOR06_ = rst ? 0 : ~(0|CH3206|U115Pad9|U146Pad8|U248Pad1|CH0706|U215Pad1);
assign U203Pad1 = rst ? 0 : ~(0|WCH12_|CHWL02_);
assign CCH06 = rst ? 0 : ~(0|U125Pad1);
assign U115Pad9 = rst ? 0 : ~(0|RCH06_|U114Pad1);
assign U109Pad3 = rst ? 0 : ~(0|WCH06_|CHWL04_);
assign CH1213 = rst ? 0 : ~(0|U226Pad2|RCH12_);
assign U109Pad1 = rst ? 0 : ~(0|U109Pad2|U109Pad3);
assign U104Pad3 = rst ? 0 : ~(0|WCH06_|CHWL02_);
assign U104Pad2 = rst ? 0 : ~(0|CCH06|U104Pad1);
assign U104Pad1 = rst ? 0 : ~(0|U104Pad2|U104Pad3);
assign U117Pad2 = rst ? 0 : ~(0|U116Pad7|U118Pad3);
assign U224Pad2 = rst ? 0 : ~(0|U223Pad1|U224Pad8);
assign U159Pad1 = rst ? 0 : ~(0|U159Pad2|U158Pad9);
assign U102Pad3 = rst ? 0 : ~(0|WCH06_|CHWL01_);
assign U102Pad2 = rst ? 0 : ~(0|CCH06|U101Pad2);
assign U258Pad2 = rst ? 0 : ~(0|XB2_|XT1_);
assign U118Pad3 = rst ? 0 : ~(0|CHWL07_|WCH12_);
assign U216Pad1 = rst ? 0 : ~(0|U216Pad2|U216Pad3);
assign U216Pad3 = rst ? 0 : ~(0|WCH12_|CHWL09_);
assign ENEROP = rst ? 0 : ~(0|U204Pad2);
assign CH1214 = rst ? 0 : ~(0|U229Pad2|RCH12_);
assign U222Pad1 = rst ? 0 : ~(0|WCH12_|CHWL11_);
assign U120Pad3 = rst ? 0 : ~(0|CHWL07_|WCH06_);
assign U120Pad2 = rst ? 0 : ~(0|CCH06|U119Pad7);
assign U207Pad8 = rst ? 0 : ~(0|U206Pad7|CCH12);
assign U207Pad1 = rst ? 0 : ~(0|U206Pad7|RCH12_);
assign CHOR05_ = rst ? 0 : ~(0|CH3205|U113Pad9|U144Pad1|CH0705|U212Pad1|U243Pad1);
assign U112Pad2 = rst ? 0 : ~(0|CCH06|U111Pad2);
assign U112Pad3 = rst ? 0 : ~(0|WCH06_|CHWL05_);
assign U126Pad8 = rst ? 0 : ~(0|XB6_|WCHG_|XT0_);
assign UPLACT = rst ? 0 : ~(0|U237Pad9);
assign U232Pad1 = rst ? 0 : ~(0|RCH11_|U231Pad9);
assign CHOR07_ = rst ? 0 : ~(0|U150Pad1|U121Pad9|CH3207|U251Pad1|CH1207|CH0707);
assign U131Pad3 = rst ? 0 : ~(0|CCH05|U131Pad1);
assign U131Pad2 = rst ? 0 : ~(0|CHWL01_|WCH05_);
assign U131Pad1 = rst ? 0 : ~(0|U131Pad2|U131Pad3);
assign U237Pad9 = rst ? 0 : ~(0|U237Pad7|U237Pad1);
assign U237Pad7 = rst ? 0 : ~(0|U237Pad9|CCH11);
assign U231Pad7 = rst ? 0 : ~(0|U231Pad9|CCH11);
assign S4BOFF = rst ? 0 : ~(0|U229Pad2);
assign CCH12 = rst ? 0 : ~(0|U256Pad2);
assign U237Pad1 = rst ? 0 : ~(0|WCH11_|CHWL03_);
assign RCpXmY = rst ? 0 : ~(0|U153Pad2);
assign U119Pad7 = rst ? 0 : ~(0|U120Pad2|U120Pad3);
assign U113Pad9 = rst ? 0 : ~(0|RCH06_|U111Pad2);
assign U231Pad9 = rst ? 0 : ~(0|U231Pad7|U231Pad1);
assign TVCNAB = rst ? 0 : ~(0|U159Pad1);
assign U153Pad2 = rst ? 0 : ~(0|U154Pad2|U151Pad1);
assign U250Pad9 = rst ? 0 : ~(0|U250Pad1|U250Pad8);
assign U250Pad8 = rst ? 0 : ~(0|U250Pad9|CCH11);
assign U243Pad1 = rst ? 0 : ~(0|RCH11_|U243Pad3);
assign U156Pad8 = rst ? 0 : ~(0|XB5_|CCHG_|XT0_);
assign U156Pad9 = rst ? 0 : ~(0|GOJAM|U156Pad8);
assign U239Pad1 = rst ? 0 : ~(0|WCH11_|CHWL04_);
assign U250Pad1 = rst ? 0 : ~(0|CHWL07_|WCH11_);
assign ENERIM = rst ? 0 : ~(0|U213Pad2);
assign U149Pad7 = rst ? 0 : ~(0|CCH05|U149Pad9);
assign U116Pad7 = rst ? 0 : ~(0|U117Pad2|CCH12);
assign U241Pad3 = rst ? 0 : ~(0|U242Pad2|U239Pad1);
assign U130Pad9 = rst ? 0 : ~(0|RCH06_|U128Pad7);
assign J3Pad370 = rst ? 0 : ~(0);
assign CCH05 = rst ? 0 : ~(0|U156Pad9);
assign CHOR04_ = rst ? 0 : ~(0|U110Pad9|U140Pad3|CH3204|CH1504|U240Pad3|U209Pad1);
assign U149Pad9 = rst ? 0 : ~(0|U149Pad7|U149Pad1);
assign U202Pad1 = rst ? 0 : ~(0|U201Pad7|RCH12_);
assign U138Pad1 = rst ? 0 : ~(0|RCH05_|U137Pad9);
assign U114Pad1 = rst ? 0 : ~(0|U114Pad2|U114Pad3);
assign U114Pad2 = rst ? 0 : ~(0|CCH06|U114Pad1);
assign U114Pad3 = rst ? 0 : ~(0|WCH06_|CHWL06_);
assign U212Pad8 = rst ? 0 : ~(0|U211Pad7|CCH12);
assign WCH06_ = rst ? 0 : ~(0|U126Pad8);
assign KYRLS = rst ? 0 : ~(0|FLASH|U243Pad3);
assign U136Pad2 = rst ? 0 : ~(0|CCH05|U135Pad3);
assign U209Pad2 = rst ? 0 : ~(0|U208Pad1|U209Pad8);
assign WCH12_ = rst ? 0 : ~(0|U253Pad8);
assign U209Pad8 = rst ? 0 : ~(0|U209Pad2|CCH12);
assign U255Pad9 = rst ? 0 : ~(0|CCHG_|XT1_|XB2_);
assign OT1207 = rst ? 0 : ~(0|U117Pad2);
assign RCpXmP = rst ? 0 : ~(0|U141Pad3);
assign RCpYmR = rst ? 0 : ~(0|U128Pad7);
assign U144Pad1 = rst ? 0 : ~(0|RCH05_|U143Pad9);
assign RCmXmP = rst ? 0 : ~(0|U135Pad3);
assign COMACT = rst ? 0 : ~(0|U235Pad3);
assign U106Pad2 = rst ? 0 : ~(0|U107Pad2|U107Pad3);
assign RCmXmY = rst ? 0 : ~(0|U147Pad2);
assign U149Pad1 = rst ? 0 : ~(0|WCH05_|CHWL07_);
assign U141Pad3 = rst ? 0 : ~(0|U142Pad2|U139Pad1);
assign U218Pad9 = rst ? 0 : ~(0|U218Pad7|CCH12);
assign U123Pad8 = rst ? 0 : ~(0|XB6_|XT0_);
assign CHOR03_ = rst ? 0 : ~(0|U138Pad1|U108Pad9|CH3203|U238Pad1|U207Pad1|CH1503);
assign U218Pad7 = rst ? 0 : ~(0|U218Pad9|U219Pad1);
assign U204Pad8 = rst ? 0 : ~(0|U204Pad2|CCH12);
assign U107Pad2 = rst ? 0 : ~(0|CCH06|U106Pad2);
assign U247Pad2 = rst ? 0 : ~(0|U247Pad1|CCH11);
assign U107Pad3 = rst ? 0 : ~(0|WCH06_|CHWL03_);
assign U204Pad1 = rst ? 0 : ~(0|U204Pad2|RCH12_);
assign U204Pad2 = rst ? 0 : ~(0|U203Pad1|U204Pad8);
assign RCpYpR = rst ? 0 : ~(0|U111Pad2);
assign U125Pad1 = rst ? 0 : ~(0|GOJAM|U125Pad3);
assign RCpXpY = rst ? 0 : ~(0|U143Pad9);
assign U125Pad3 = rst ? 0 : ~(0|CCHG_|XT0_|XB6_);
assign U240Pad3 = rst ? 0 : ~(0|RCH11_|U241Pad3);
assign U101Pad2 = rst ? 0 : ~(0|U102Pad2|U102Pad3);
assign RCpXpP = rst ? 0 : ~(0|U131Pad1);
assign ISSWAR = rst ? 0 : ~(0|U231Pad9);
assign U201Pad7 = rst ? 0 : ~(0|U201Pad1|U202Pad8);
assign U216Pad2 = rst ? 0 : ~(0|U216Pad1|CCH12);
assign U221Pad2 = rst ? 0 : ~(0|U222Pad7|U222Pad1);
assign RCpZpR = rst ? 0 : ~(0|U101Pad2);
assign U139Pad1 = rst ? 0 : ~(0|WCH05_|CHWL04_);
assign U135Pad3 = rst ? 0 : ~(0|U136Pad2|U133Pad1);
assign U201Pad1 = rst ? 0 : ~(0|WCH12_|CHWL01_);
assign U202Pad8 = rst ? 0 : ~(0|U201Pad7|CCH12);
assign CH1211 = rst ? 0 : ~(0|U221Pad2|RCH12_);
assign CHOR02_ = rst ? 0 : ~(0|CH3202|U105Pad9|U134Pad8|U234Pad2|U204Pad1|CH1502);
assign DISDAC = rst ? 0 : ~(0|U221Pad2);
assign U227Pad8 = rst ? 0 : ~(0|U226Pad2|CCH12);
assign U219Pad1 = rst ? 0 : ~(0|WCH12_|CHWL10_);
assign U211Pad7 = rst ? 0 : ~(0|U211Pad1|U212Pad8);
assign STARON = rst ? 0 : ~(0|U206Pad7);
assign U211Pad1 = rst ? 0 : ~(0|WCH12_|CHWL05_);
assign RCmZpR = rst ? 0 : ~(0|U106Pad2);
assign U159Pad2 = rst ? 0 : ~(0|U159Pad1|CCH12);
assign U222Pad7 = rst ? 0 : ~(0|U221Pad2|CCH12);
assign U224Pad8 = rst ? 0 : ~(0|U224Pad2|CCH12);
assign U213Pad2 = rst ? 0 : ~(0|U214Pad1|U214Pad8);
assign U248Pad1 = rst ? 0 : ~(0|RCH11_|U247Pad1);
assign U134Pad8 = rst ? 0 : ~(0|RCH05_|U135Pad3);
assign U243Pad3 = rst ? 0 : ~(0|U243Pad9|U244Pad1);
assign COARSE = rst ? 0 : ~(0|U209Pad2);
assign U154Pad2 = rst ? 0 : ~(0|CCH05|U153Pad2);
assign U146Pad8 = rst ? 0 : ~(0|U147Pad2|RCH05_);
assign J3Pad368 = rst ? 0 : ~(0);
assign U128Pad7 = rst ? 0 : ~(0|U129Pad2|U129Pad3);
assign U243Pad9 = rst ? 0 : ~(0|U243Pad3|CCH11);
assign TMPOUT = rst ? 0 : ~(0|U241Pad3);
assign VNFLSH = rst ? 0 : ~(0|FLASH_|U247Pad1);
assign U234Pad2 = rst ? 0 : ~(0|RCH11_|U235Pad3);
assign CHOR01_ = rst ? 0 : ~(0|U132Pad1|CH3201|U103Pad9|U232Pad1|U202Pad1|CH1501);
assign RCH05_ = rst ? 0 : ~(0|U122Pad2);
assign RCmYmR = rst ? 0 : ~(0|U114Pad1);
assign U110Pad9 = rst ? 0 : ~(0|RCH06_|U109Pad1);
assign U105Pad9 = rst ? 0 : ~(0|RCH06_|U104Pad1);
assign U151Pad1 = rst ? 0 : ~(0|WCH05_|CHWL08_);
assign U209Pad1 = rst ? 0 : ~(0|U209Pad2|RCH12_);
assign U147Pad2 = rst ? 0 : ~(0|U148Pad2|U145Pad1);
assign ZEROPT = rst ? 0 : ~(0|U218Pad7);
assign U152Pad2 = rst ? 0 : ~(0|U153Pad2|RCH05_);
assign S4BTAK = rst ? 0 : ~(0|U216Pad1);
assign U137Pad1 = rst ? 0 : ~(0|WCH05_|CHWL03_);
assign U143Pad7 = rst ? 0 : ~(0|CCH05|U143Pad9);
assign WCH05_ = rst ? 0 : ~(0|U155Pad2);
assign U143Pad1 = rst ? 0 : ~(0|WCH05_|CHWL05_);
assign U137Pad7 = rst ? 0 : ~(0|CCH05|U137Pad9);
assign U155Pad2 = rst ? 0 : ~(0|XB5_|XT0_|WCHG_);
assign U137Pad9 = rst ? 0 : ~(0|U137Pad7|U137Pad1);
assign U103Pad9 = rst ? 0 : ~(0|RCH06_|U101Pad2);
assign U246Pad1 = rst ? 0 : ~(0|WCH11_|CHWL06_);
assign ZIMCDU = rst ? 0 : ~(0|U211Pad7);
assign U143Pad9 = rst ? 0 : ~(0|U143Pad7|U143Pad1);
assign U223Pad1 = rst ? 0 : ~(0|WCH12_|CHWL12_);
assign MROLGT = rst ? 0 : ~(0|U224Pad2);
assign U132Pad1 = rst ? 0 : ~(0|RCH05_|U131Pad1);
assign RCH12_ = rst ? 0 : ~(0|U258Pad2);
assign OPEROR = rst ? 0 : ~(0|FLASH|U250Pad9);
assign U158Pad9 = rst ? 0 : ~(0|CHWL08_|WCH12_);
assign U247Pad1 = rst ? 0 : ~(0|U247Pad2|U246Pad1);
assign U122Pad2 = rst ? 0 : ~(0|XT0_|XB5_);
assign OT1207_ = rst ? 0 : ~(0|U116Pad7);
assign U145Pad1 = rst ? 0 : ~(0|WCH05_|CHWL06_);
assign RCpZmR = rst ? 0 : ~(0|U109Pad1);
assign U148Pad2 = rst ? 0 : ~(0|CCH05|U147Pad2);
assign CHOR08_ = rst ? 0 : ~(0|U152Pad2|U130Pad9|CH3208);
assign U228Pad1 = rst ? 0 : ~(0|WCH12_|CHWL14_);
assign U231Pad1 = rst ? 0 : ~(0|WCH11_|CHWL01_);
assign U142Pad2 = rst ? 0 : ~(0|CCH05|U141Pad3);
assign U227Pad1 = rst ? 0 : ~(0|WCH12_|CHWL13_);
assign U214Pad1 = rst ? 0 : ~(0|WCH12_|CHWL06_);
assign U214Pad8 = rst ? 0 : ~(0|U213Pad2|CCH12);
assign U256Pad2 = rst ? 0 : ~(0|U255Pad9|GOJAM);

endmodule
