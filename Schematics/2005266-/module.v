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

// Gate A16-U247A
pullup(A16U247Pad1);
assign (highz1,strong0) #0.2  A16U247Pad1 = rst ? 1 : ~(0|A16U247Pad2|A16U246Pad1);
// Gate A16-U247B
pullup(A16U247Pad2);
assign (highz1,strong0) #0.2  A16U247Pad2 = rst ? 0 : ~(0|A16U247Pad1|CCH11);
// Gate A16-U138A
pullup(A16U138Pad1);
assign (highz1,strong0) #0.2  A16U138Pad1 = rst ? 0 : ~(0|RCH05_|A16U137Pad9);
// Gate A16-U159B
pullup(A16U159Pad2);
assign (highz1,strong0) #0.2  A16U159Pad2 = rst ? 0 : ~(0|A16U159Pad1|CCH12);
// Gate A16-U147A
pullup(A16U146Pad8);
assign (highz1,strong0) #0.2  A16U146Pad8 = rst ? 0 : ~(0|A16U147Pad2|RCH05_);
// Gate A16-U159A
pullup(A16U159Pad1);
assign (highz1,strong0) #0.2  A16U159Pad1 = rst ? 1 : ~(0|A16U159Pad2|A16U158Pad9);
// Gate A16-U106B
pullup(RCmZmR);
assign (highz1,strong0) #0.2  RCmZmR = rst ? 0 : ~(0|A16U104Pad1);
// Gate A16-U135A
pullup(A16U134Pad8);
assign (highz1,strong0) #0.2  A16U134Pad8 = rst ? 0 : ~(0|RCH05_|A16U135Pad3);
// Gate A16-U110A
pullup(A16U109Pad2);
assign (highz1,strong0) #0.2  A16U109Pad2 = rst ? 0 : ~(0|CCH06|A16U109Pad1);
// Gate A16-U154B
pullup(A16U154Pad2);
assign (highz1,strong0) #0.2  A16U154Pad2 = rst ? 0 : ~(0|CCH05|A16U153Pad2);
// Gate A16-U139B
pullup(RCmXpP);
assign (highz1,strong0) #0.2  RCmXpP = rst ? 0 : ~(0|A16U137Pad9);
// Gate A16-U226B
pullup(S4BSEQ);
assign (highz1,strong0) #0.2  S4BSEQ = rst ? 0 : ~(0|A16U226Pad2);
// Gate A16-U152B A16-U252B
pullup(CHOR07_);
assign (highz1,strong0) #0.2  CHOR07_ = rst ? 1 : ~(0|A16U150Pad1|A16U121Pad9|CH3207|A16U251Pad1|CH1207|CH0707);
// Gate A16-U255B
pullup(A16U255Pad9);
assign (highz1,strong0) #0.2  A16U255Pad9 = rst ? 0 : ~(0|CCHG_|XT1_|XB2_);
// Gate A16-U230B
pullup(A16U229Pad8);
assign (highz1,strong0) #0.2  A16U229Pad8 = rst ? 0 : ~(0|A16U229Pad2|CCH12);
// Gate A16-U123B A16-U124B
pullup(RCH06_);
assign (highz1,strong0) #0.2  RCH06_ = rst ? 1 : ~(0|A16U123Pad8);
// Gate A16-U201A
pullup(A16U201Pad1);
assign (highz1,strong0) #0.2  A16U201Pad1 = rst ? 0 : ~(0|WCH12_|CHWL01_);
// Gate A16-U208B
pullup(A16U207Pad8);
assign (highz1,strong0) #0.2  A16U207Pad8 = rst ? 0 : ~(0|A16U206Pad7|CCH12);
// Gate A16-U117B
pullup(CH1207);
assign (highz1,strong0) #0.2  CH1207 = rst ? 0 : ~(0|RCH12_|A16U117Pad2);
// Gate A16-U160B
pullup(CH1208);
assign (highz1,strong0) #0.2  CH1208 = rst ? 0 : ~(0|RCH12_|A16U159Pad1);
// Gate A16-U217A
pullup(CH1209);
assign (highz1,strong0) #0.2  CH1209 = rst ? 0 : ~(0|A16U216Pad1|RCH12_);
// Gate A16-U207A
pullup(A16U207Pad1);
assign (highz1,strong0) #0.2  A16U207Pad1 = rst ? 0 : ~(0|A16U206Pad7|RCH12_);
// Gate A16-U121B
pullup(A16U121Pad9);
assign (highz1,strong0) #0.2  A16U121Pad9 = rst ? 0 : ~(0|RCH06_|A16U119Pad7);
// Gate A16-U145A
pullup(A16U145Pad1);
assign (highz1,strong0) #0.2  A16U145Pad1 = rst ? 0 : ~(0|WCH05_|CHWL06_);
// Gate A16-U124A
pullup(A16U123Pad8);
assign (highz1,strong0) #0.2  A16U123Pad8 = rst ? 0 : ~(0|XB6_|XT0_);
// Gate A16-U258B
pullup(A16J3Pad368);
assign (highz1,strong0) #0.2  A16J3Pad368 = rst ? 1 : ~(0);
// Gate A16-U141A
pullup(A16U140Pad3);
assign (highz1,strong0) #0.2  A16U140Pad3 = rst ? 0 : ~(0|RCH05_|A16U141Pad3);
// Gate A16-U254B
pullup(A16U253Pad8);
assign (highz1,strong0) #0.2  A16U253Pad8 = rst ? 0 : ~(0|WCHG_|XT1_|XB2_);
// Gate A16-U235A
pullup(A16U234Pad2);
assign (highz1,strong0) #0.2  A16U234Pad2 = rst ? 0 : ~(0|RCH11_|A16U235Pad3);
// Gate A16-U147B
pullup(RCmXmY);
assign (highz1,strong0) #0.2  RCmXmY = rst ? 0 : ~(0|A16U147Pad2);
// Gate A16-U221A
pullup(CH1211);
assign (highz1,strong0) #0.2  CH1211 = rst ? 0 : ~(0|A16U221Pad2|RCH12_);
// Gate A16-U207B
pullup(A16U206Pad7);
assign (highz1,strong0) #0.2  A16U206Pad7 = rst ? 1 : ~(0|A16U206Pad1|A16U207Pad8);
// Gate A16-U151B
pullup(RCmXpY);
assign (highz1,strong0) #0.2  RCmXpY = rst ? 0 : ~(0|A16U149Pad9);
// Gate A16-U110B
pullup(A16U110Pad9);
assign (highz1,strong0) #0.2  A16U110Pad9 = rst ? 0 : ~(0|RCH06_|A16U109Pad1);
// Gate A16-U130A
pullup(A16U129Pad3);
assign (highz1,strong0) #0.2  A16U129Pad3 = rst ? 0 : ~(0|CCH06|A16U128Pad7);
// Gate A16-U129B
pullup(A16U129Pad2);
assign (highz1,strong0) #0.2  A16U129Pad2 = rst ? 0 : ~(0|WCH06_|CHWL08_);
// Gate A16-U144B
pullup(A16U143Pad7);
assign (highz1,strong0) #0.2  A16U143Pad7 = rst ? 0 : ~(0|CCH05|A16U143Pad9);
// Gate A16-U120A
pullup(A16U119Pad7);
assign (highz1,strong0) #0.2  A16U119Pad7 = rst ? 1 : ~(0|A16U120Pad2|A16U120Pad3);
// Gate A16-U224A
pullup(CH1212);
assign (highz1,strong0) #0.2  CH1212 = rst ? 0 : ~(0|A16U224Pad2|RCH12_);
// Gate A16-U113B
pullup(A16U113Pad9);
assign (highz1,strong0) #0.2  A16U113Pad9 = rst ? 0 : ~(0|RCH06_|A16U111Pad2);
// Gate A16-U143A
pullup(A16U143Pad1);
assign (highz1,strong0) #0.2  A16U143Pad1 = rst ? 0 : ~(0|WCH05_|CHWL05_);
// Gate A16-U146B A16-U249A
pullup(CHOR06_);
assign (highz1,strong0) #0.2  CHOR06_ = rst ? 1 : ~(0|CH3206|A16U115Pad9|A16U146Pad8|A16U248Pad1|CH0706|A16U215Pad1);
// Gate A16-U203A
pullup(A16U203Pad1);
assign (highz1,strong0) #0.2  A16U203Pad1 = rst ? 0 : ~(0|WCH12_|CHWL02_);
// Gate A16-U242B
pullup(A16U242Pad2);
assign (highz1,strong0) #0.2  A16U242Pad2 = rst ? 0 : ~(0|A16U241Pad3|CCH11);
// Gate A16-U143B
pullup(A16U143Pad9);
assign (highz1,strong0) #0.2  A16U143Pad9 = rst ? 1 : ~(0|A16U143Pad7|A16U143Pad1);
// Gate A16-U157B
pullup(A16U156Pad8);
assign (highz1,strong0) #0.2  A16U156Pad8 = rst ? 0 : ~(0|XB5_|CCHG_|XT0_);
// Gate A16-U141B
pullup(RCpXmP);
assign (highz1,strong0) #0.2  RCpXmP = rst ? 0 : ~(0|A16U141Pad3);
// Gate A16-U220A
pullup(CH1210);
assign (highz1,strong0) #0.2  CH1210 = rst ? 0 : ~(0|A16U218Pad7|RCH12_);
// Gate A16-U154A
pullup(A16U153Pad2);
assign (highz1,strong0) #0.2  A16U153Pad2 = rst ? 1 : ~(0|A16U154Pad2|A16U151Pad1);
// Gate A16-U223A
pullup(A16U223Pad1);
assign (highz1,strong0) #0.2  A16U223Pad1 = rst ? 0 : ~(0|WCH12_|CHWL12_);
// Gate A16-U156B
pullup(A16U156Pad9);
assign (highz1,strong0) #0.2  A16U156Pad9 = rst ? 0 : ~(0|GOJAM|A16U156Pad8);
// Gate A16-U127A A16-U126A
pullup(CCH06);
assign (highz1,strong0) #0.2  CCH06 = rst ? 1 : ~(0|A16U125Pad1);
// Gate A16-U158A A16-U157A
pullup(CCH05);
assign (highz1,strong0) #0.2  CCH05 = rst ? 1 : ~(0|A16U156Pad9);
// Gate A16-U133A
pullup(A16U133Pad1);
assign (highz1,strong0) #0.2  A16U133Pad1 = rst ? 0 : ~(0|WCH05_|CHWL02_);
// Gate A16-U153B
pullup(RCpXmY);
assign (highz1,strong0) #0.2  RCpXmY = rst ? 0 : ~(0|A16U153Pad2);
// Gate A16-U238A
pullup(A16U238Pad1);
assign (highz1,strong0) #0.2  A16U238Pad1 = rst ? 0 : ~(0|RCH11_|A16U237Pad9);
// Gate A16-U229B
pullup(A16U229Pad2);
assign (highz1,strong0) #0.2  A16U229Pad2 = rst ? 1 : ~(0|A16U228Pad1|A16U229Pad8);
// Gate A16-U236A
pullup(A16U235Pad3);
assign (highz1,strong0) #0.2  A16U235Pad3 = rst ? 1 : ~(0|A16U236Pad2|A16U233Pad1);
// Gate A16-U251A
pullup(A16U251Pad1);
assign (highz1,strong0) #0.2  A16U251Pad1 = rst ? 0 : ~(0|A16U250Pad9|RCH11_);
// Gate A16-U205A
pullup(ENEROP);
assign (highz1,strong0) #0.2  ENEROP = rst ? 0 : ~(0|A16U204Pad2);
// Gate A16-U219A
pullup(A16U219Pad1);
assign (highz1,strong0) #0.2  A16U219Pad1 = rst ? 0 : ~(0|WCH12_|CHWL10_);
// Gate A16-U226A
pullup(CH1213);
assign (highz1,strong0) #0.2  CH1213 = rst ? 0 : ~(0|A16U226Pad2|RCH12_);
// Gate A16-U158B
pullup(A16U158Pad9);
assign (highz1,strong0) #0.2  A16U158Pad9 = rst ? 0 : ~(0|CHWL08_|WCH12_);
// Gate A16-U211A
pullup(A16U211Pad1);
assign (highz1,strong0) #0.2  A16U211Pad1 = rst ? 0 : ~(0|WCH12_|CHWL05_);
// Gate A16-U225B
pullup(A16U224Pad8);
assign (highz1,strong0) #0.2  A16U224Pad8 = rst ? 0 : ~(0|A16U224Pad2|CCH12);
// Gate A16-U123A
pullup(A16U122Pad2);
assign (highz1,strong0) #0.2  A16U122Pad2 = rst ? 0 : ~(0|XT0_|XB5_);
// Gate A16-U244B
pullup(A16U243Pad3);
assign (highz1,strong0) #0.2  A16U243Pad3 = rst ? 1 : ~(0|A16U243Pad9|A16U244Pad1);
// Gate A16-U214B
pullup(A16U213Pad2);
assign (highz1,strong0) #0.2  A16U213Pad2 = rst ? 1 : ~(0|A16U214Pad1|A16U214Pad8);
// Gate A16-U224B
pullup(A16U224Pad2);
assign (highz1,strong0) #0.2  A16U224Pad2 = rst ? 1 : ~(0|A16U223Pad1|A16U224Pad8);
// Gate A16-U228A
pullup(A16U228Pad1);
assign (highz1,strong0) #0.2  A16U228Pad1 = rst ? 0 : ~(0|WCH12_|CHWL14_);
// Gate A16-U146A A16-U245B
pullup(CHOR05_);
assign (highz1,strong0) #0.2  CHOR05_ = rst ? 1 : ~(0|CH3205|A16U113Pad9|A16U144Pad1|CH0705|A16U212Pad1|A16U243Pad1);
// Gate A16-U219B
pullup(A16U218Pad7);
assign (highz1,strong0) #0.2  A16U218Pad7 = rst ? 1 : ~(0|A16U218Pad9|A16U219Pad1);
// Gate A16-U119B
pullup(RCmYpR);
assign (highz1,strong0) #0.2  RCmYpR = rst ? 0 : ~(0|A16U119Pad7);
// Gate A16-U239B
pullup(UPLACT);
assign (highz1,strong0) #0.2  UPLACT = rst ? 0 : ~(0|A16U237Pad9);
// Gate A16-U148B
pullup(A16U148Pad2);
assign (highz1,strong0) #0.2  A16U148Pad2 = rst ? 0 : ~(0|CCH05|A16U147Pad2);
// Gate A16-U144A
pullup(A16U144Pad1);
assign (highz1,strong0) #0.2  A16U144Pad1 = rst ? 0 : ~(0|RCH05_|A16U143Pad9);
// Gate A16-U244A
pullup(A16U244Pad1);
assign (highz1,strong0) #0.2  A16U244Pad1 = rst ? 0 : ~(0|WCH11_|CHWL05_);
// Gate A16-U107B
pullup(A16U107Pad3);
assign (highz1,strong0) #0.2  A16U107Pad3 = rst ? 0 : ~(0|WCH06_|CHWL03_);
// Gate A16-U120B
pullup(A16U120Pad3);
assign (highz1,strong0) #0.2  A16U120Pad3 = rst ? 0 : ~(0|CHWL07_|WCH06_);
// Gate A16-U233A
pullup(A16U233Pad1);
assign (highz1,strong0) #0.2  A16U233Pad1 = rst ? 0 : ~(0|WCH11_|CHWL02_);
// Gate A16-U142A
pullup(A16U141Pad3);
assign (highz1,strong0) #0.2  A16U141Pad3 = rst ? 1 : ~(0|A16U142Pad2|A16U139Pad1);
// Gate A16-U218A
pullup(A16U216Pad3);
assign (highz1,strong0) #0.2  A16U216Pad3 = rst ? 0 : ~(0|WCH12_|CHWL09_);
// Gate A16-U105B
pullup(A16U105Pad9);
assign (highz1,strong0) #0.2  A16U105Pad9 = rst ? 0 : ~(0|RCH06_|A16U104Pad1);
// Gate A16-U112B
pullup(A16U112Pad3);
assign (highz1,strong0) #0.2  A16U112Pad3 = rst ? 0 : ~(0|WCH06_|CHWL05_);
// Gate A16-U113A
pullup(A16U112Pad2);
assign (highz1,strong0) #0.2  A16U112Pad2 = rst ? 0 : ~(0|CCH06|A16U111Pad2);
// Gate A16-U128A
pullup(A16U126Pad8);
assign (highz1,strong0) #0.2  A16U126Pad8 = rst ? 0 : ~(0|XB6_|WCHG_|XT0_);
// Gate A16-U160A
pullup(TVCNAB);
assign (highz1,strong0) #0.2  TVCNAB = rst ? 0 : ~(0|A16U159Pad1);
// Gate A16-U211B
pullup(ZIMCDU);
assign (highz1,strong0) #0.2  ZIMCDU = rst ? 0 : ~(0|A16U211Pad7);
// Gate A16-U215A
pullup(A16U215Pad1);
assign (highz1,strong0) #0.2  A16U215Pad1 = rst ? 0 : ~(0|A16U213Pad2|RCH12_);
// Gate A16-U148A
pullup(A16U147Pad2);
assign (highz1,strong0) #0.2  A16U147Pad2 = rst ? 1 : ~(0|A16U148Pad2|A16U145Pad1);
// Gate A16-U241B
pullup(TMPOUT);
assign (highz1,strong0) #0.2  TMPOUT = rst ? 0 : ~(0|A16U241Pad3);
// Gate A16-U125B
pullup(A16U125Pad3);
assign (highz1,strong0) #0.2  A16U125Pad3 = rst ? 0 : ~(0|CCHG_|XT0_|XB6_);
// Gate A16-U125A
pullup(A16U125Pad1);
assign (highz1,strong0) #0.2  A16U125Pad1 = rst ? 0 : ~(0|GOJAM|A16U125Pad3);
// Gate A16-U223B
pullup(A16U222Pad7);
assign (highz1,strong0) #0.2  A16U222Pad7 = rst ? 0 : ~(0|A16U221Pad2|CCH12);
// Gate A16-U140A A16-U240A
pullup(CHOR04_);
assign (highz1,strong0) #0.2  CHOR04_ = rst ? 1 : ~(0|A16U110Pad9|A16U140Pad3|CH3204|CH1504|A16U240Pad3|A16U209Pad1);
// Gate A16-U203B
pullup(A16U202Pad8);
assign (highz1,strong0) #0.2  A16U202Pad8 = rst ? 0 : ~(0|A16U201Pad7|CCH12);
// Gate A16-U213A
pullup(ENERIM);
assign (highz1,strong0) #0.2  ENERIM = rst ? 0 : ~(0|A16U213Pad2);
// Gate A16-U132A
pullup(A16U132Pad1);
assign (highz1,strong0) #0.2  A16U132Pad1 = rst ? 0 : ~(0|RCH05_|A16U131Pad1);
// Gate A16-U128B
pullup(RCpYmR);
assign (highz1,strong0) #0.2  RCpYmR = rst ? 0 : ~(0|A16U128Pad7);
// Gate A16-U246A
pullup(A16U246Pad1);
assign (highz1,strong0) #0.2  A16U246Pad1 = rst ? 0 : ~(0|WCH11_|CHWL06_);
// Gate A16-U239A
pullup(A16U239Pad1);
assign (highz1,strong0) #0.2  A16U239Pad1 = rst ? 0 : ~(0|WCH11_|CHWL04_);
// Gate A16-U139A
pullup(A16U139Pad1);
assign (highz1,strong0) #0.2  A16U139Pad1 = rst ? 0 : ~(0|WCH05_|CHWL04_);
// Gate A16-U245A A16-U246B
pullup(KYRLS);
assign (highz1,strong0) #0.2  KYRLS = rst ? 0 : ~(0|FLASH|A16U243Pad3);
// Gate A16-U150B
pullup(A16U149Pad7);
assign (highz1,strong0) #0.2  A16U149Pad7 = rst ? 0 : ~(0|CCH05|A16U149Pad9);
// Gate A16-U149A
pullup(A16U149Pad1);
assign (highz1,strong0) #0.2  A16U149Pad1 = rst ? 0 : ~(0|WCH05_|CHWL07_);
// Gate A16-U242A
pullup(A16U241Pad3);
assign (highz1,strong0) #0.2  A16U241Pad3 = rst ? 1 : ~(0|A16U242Pad2|A16U239Pad1);
// Gate A16-U118B
pullup(A16U116Pad7);
assign (highz1,strong0) #0.2  A16U116Pad7 = rst ? 0 : ~(0|A16U117Pad2|CCH12);
// Gate A16-U149B
pullup(A16U149Pad9);
assign (highz1,strong0) #0.2  A16U149Pad9 = rst ? 1 : ~(0|A16U149Pad7|A16U149Pad1);
// Gate A16-U117A
pullup(OT1207);
assign (highz1,strong0) #0.2  OT1207 = rst ? 0 : ~(0|A16U117Pad2);
// Gate A16-U109A
pullup(A16U109Pad1);
assign (highz1,strong0) #0.2  A16U109Pad1 = rst ? 1 : ~(0|A16U109Pad2|A16U109Pad3);
// Gate A16-U109B
pullup(A16U109Pad3);
assign (highz1,strong0) #0.2  A16U109Pad3 = rst ? 0 : ~(0|WCH06_|CHWL04_);
// Gate A16-U135B
pullup(RCmXmP);
assign (highz1,strong0) #0.2  RCmXmP = rst ? 0 : ~(0|A16U135Pad3);
// Gate A16-U104A
pullup(A16U104Pad1);
assign (highz1,strong0) #0.2  A16U104Pad1 = rst ? 1 : ~(0|A16U104Pad2|A16U104Pad3);
// Gate A16-U105A
pullup(A16U104Pad2);
assign (highz1,strong0) #0.2  A16U104Pad2 = rst ? 0 : ~(0|CCH06|A16U104Pad1);
// Gate A16-U104B
pullup(A16U104Pad3);
assign (highz1,strong0) #0.2  A16U104Pad3 = rst ? 0 : ~(0|WCH06_|CHWL02_);
// Gate A16-U115B
pullup(A16U115Pad9);
assign (highz1,strong0) #0.2  A16U115Pad9 = rst ? 0 : ~(0|RCH06_|A16U114Pad1);
// Gate A16-U129A
pullup(A16U128Pad7);
assign (highz1,strong0) #0.2  A16U128Pad7 = rst ? 1 : ~(0|A16U129Pad2|A16U129Pad3);
// Gate A16-U118A
pullup(A16U117Pad2);
assign (highz1,strong0) #0.2  A16U117Pad2 = rst ? 1 : ~(0|A16U116Pad7|A16U118Pad3);
// Gate A16-U150A
pullup(A16U150Pad1);
assign (highz1,strong0) #0.2  A16U150Pad1 = rst ? 0 : ~(0|RCH05_|A16U149Pad9);
// Gate A16-U201B
pullup(ZOPCDU);
assign (highz1,strong0) #0.2  ZOPCDU = rst ? 0 : ~(0|A16U201Pad7);
// Gate A16-U103A
pullup(A16U102Pad2);
assign (highz1,strong0) #0.2  A16U102Pad2 = rst ? 0 : ~(0|CCH06|A16U101Pad2);
// Gate A16-U102B
pullup(A16U102Pad3);
assign (highz1,strong0) #0.2  A16U102Pad3 = rst ? 0 : ~(0|WCH06_|CHWL01_);
// Gate A16-U119A
pullup(A16U118Pad3);
assign (highz1,strong0) #0.2  A16U118Pad3 = rst ? 0 : ~(0|CHWL07_|WCH12_);
// Gate A16-U243A
pullup(A16U243Pad1);
assign (highz1,strong0) #0.2  A16U243Pad1 = rst ? 0 : ~(0|RCH11_|A16U243Pad3);
// Gate A16-U140B A16-U240B
pullup(CHOR03_);
assign (highz1,strong0) #0.2  CHOR03_ = rst ? 1 : ~(0|A16U138Pad1|A16U108Pad9|CH3203|A16U238Pad1|A16U207Pad1|CH1503);
// Gate A16-U225A
pullup(MROLGT);
assign (highz1,strong0) #0.2  MROLGT = rst ? 0 : ~(0|A16U224Pad2);
// Gate A16-U243B
pullup(A16U243Pad9);
assign (highz1,strong0) #0.2  A16U243Pad9 = rst ? 0 : ~(0|A16U243Pad3|CCH11);
// Gate A16-U222A
pullup(A16U222Pad1);
assign (highz1,strong0) #0.2  A16U222Pad1 = rst ? 0 : ~(0|WCH12_|CHWL11_);
// Gate A16-U250A
pullup(A16U250Pad1);
assign (highz1,strong0) #0.2  A16U250Pad1 = rst ? 0 : ~(0|CHWL07_|WCH11_);
// Gate A16-U107A
pullup(A16U106Pad2);
assign (highz1,strong0) #0.2  A16U106Pad2 = rst ? 1 : ~(0|A16U107Pad2|A16U107Pad3);
// Gate A16-U111A
pullup(RCpYpR);
assign (highz1,strong0) #0.2  RCpYpR = rst ? 0 : ~(0|A16U111Pad2);
// Gate A16-U145B
pullup(RCpXpY);
assign (highz1,strong0) #0.2  RCpXpY = rst ? 0 : ~(0|A16U143Pad9);
// Gate A16-U227B
pullup(A16U226Pad2);
assign (highz1,strong0) #0.2  A16U226Pad2 = rst ? 1 : ~(0|A16U227Pad1|A16U227Pad8);
// Gate A16-U249B A16-U248B
pullup(VNFLSH);
assign (highz1,strong0) #0.2  VNFLSH = rst ? 0 : ~(0|FLASH_|A16U247Pad1);
// Gate A16-U101B
pullup(A16J2Pad271);
assign (highz1,strong0) #0.2  A16J2Pad271 = rst ? 1 : ~(0);
// Gate A16-U133B
pullup(RCpXpP);
assign (highz1,strong0) #0.2  RCpXpP = rst ? 0 : ~(0|A16U131Pad1);
// Gate A16-U112A
pullup(A16U111Pad2);
assign (highz1,strong0) #0.2  A16U111Pad2 = rst ? 1 : ~(0|A16U112Pad2|A16U112Pad3);
// Gate A16-U233B
pullup(ISSWAR);
assign (highz1,strong0) #0.2  ISSWAR = rst ? 0 : ~(0|A16U231Pad9);
// Gate A16-U251B
pullup(A16U250Pad8);
assign (highz1,strong0) #0.2  A16U250Pad8 = rst ? 0 : ~(0|A16U250Pad9|CCH11);
// Gate A16-U260A
pullup(A16U258Pad2);
assign (highz1,strong0) #0.2  A16U258Pad2 = rst ? 0 : ~(0|XB2_|XT1_);
// Gate A16-U131A
pullup(A16U131Pad1);
assign (highz1,strong0) #0.2  A16U131Pad1 = rst ? 1 : ~(0|A16U131Pad2|A16U131Pad3);
// Gate A16-U131B
pullup(A16U131Pad2);
assign (highz1,strong0) #0.2  A16U131Pad2 = rst ? 0 : ~(0|CHWL01_|WCH05_);
// Gate A16-U132B
pullup(A16U131Pad3);
assign (highz1,strong0) #0.2  A16U131Pad3 = rst ? 0 : ~(0|CCH05|A16U131Pad1);
// Gate A16-U101A
pullup(RCpZpR);
assign (highz1,strong0) #0.2  RCpZpR = rst ? 0 : ~(0|A16U101Pad2);
// Gate A16-U204B
pullup(A16U204Pad2);
assign (highz1,strong0) #0.2  A16U204Pad2 = rst ? 1 : ~(0|A16U203Pad1|A16U204Pad8);
// Gate A16-U204A
pullup(A16U204Pad1);
assign (highz1,strong0) #0.2  A16U204Pad1 = rst ? 0 : ~(0|A16U204Pad2|RCH12_);
// Gate A16-U212A
pullup(A16U212Pad1);
assign (highz1,strong0) #0.2  A16U212Pad1 = rst ? 0 : ~(0|A16U211Pad7|RCH12_);
// Gate A16-U137A
pullup(A16U137Pad1);
assign (highz1,strong0) #0.2  A16U137Pad1 = rst ? 0 : ~(0|WCH05_|CHWL03_);
// Gate A16-U134B A16-U234A
pullup(CHOR02_);
assign (highz1,strong0) #0.2  CHOR02_ = rst ? 1 : ~(0|CH3202|A16U105Pad9|A16U134Pad8|A16U234Pad2|A16U204Pad1|CH1502);
// Gate A16-U138B
pullup(A16U137Pad7);
assign (highz1,strong0) #0.2  A16U137Pad7 = rst ? 0 : ~(0|CCH05|A16U137Pad9);
// Gate A16-U221B
pullup(DISDAC);
assign (highz1,strong0) #0.2  DISDAC = rst ? 0 : ~(0|A16U221Pad2);
// Gate A16-U103B
pullup(A16U103Pad9);
assign (highz1,strong0) #0.2  A16U103Pad9 = rst ? 0 : ~(0|RCH06_|A16U101Pad2);
// Gate A16-U137B
pullup(A16U137Pad9);
assign (highz1,strong0) #0.2  A16U137Pad9 = rst ? 1 : ~(0|A16U137Pad7|A16U137Pad1);
// Gate A16-U202B
pullup(A16U201Pad7);
assign (highz1,strong0) #0.2  A16U201Pad7 = rst ? 1 : ~(0|A16U201Pad1|A16U202Pad8);
// Gate A16-U256A A16-U257A A16-U257B
pullup(CCH12);
assign (highz1,strong0) #0.2  CCH12 = rst ? 1 : ~(0|A16U256Pad2);
// Gate A16-U215B
pullup(A16U214Pad8);
assign (highz1,strong0) #0.2  A16U214Pad8 = rst ? 0 : ~(0|A16U213Pad2|CCH12);
// Gate A16-U231A
pullup(A16U231Pad1);
assign (highz1,strong0) #0.2  A16U231Pad1 = rst ? 0 : ~(0|WCH11_|CHWL01_);
// Gate A16-U232B
pullup(A16U231Pad7);
assign (highz1,strong0) #0.2  A16U231Pad7 = rst ? 0 : ~(0|A16U231Pad9|CCH11);
// Gate A16-U206B
pullup(STARON);
assign (highz1,strong0) #0.2  STARON = rst ? 0 : ~(0|A16U206Pad7);
// Gate A16-U106A
pullup(RCmZpR);
assign (highz1,strong0) #0.2  RCmZpR = rst ? 0 : ~(0|A16U106Pad2);
// Gate A16-U231B
pullup(A16U231Pad9);
assign (highz1,strong0) #0.2  A16U231Pad9 = rst ? 1 : ~(0|A16U231Pad7|A16U231Pad1);
// Gate A16-U122A A16-U122B
pullup(RCH05_);
assign (highz1,strong0) #0.2  RCH05_ = rst ? 1 : ~(0|A16U122Pad2);
// Gate A16-U229A
pullup(S4BOFF);
assign (highz1,strong0) #0.2  S4BOFF = rst ? 0 : ~(0|A16U229Pad2);
// Gate A16-U136A
pullup(A16U135Pad3);
assign (highz1,strong0) #0.2  A16U135Pad3 = rst ? 1 : ~(0|A16U136Pad2|A16U133Pad1);
// Gate A16-U210A
pullup(COARSE);
assign (highz1,strong0) #0.2  COARSE = rst ? 0 : ~(0|A16U209Pad2);
// Gate A16-U227A
pullup(A16U227Pad1);
assign (highz1,strong0) #0.2  A16U227Pad1 = rst ? 0 : ~(0|WCH12_|CHWL13_);
// Gate A16-U142B
pullup(A16U142Pad2);
assign (highz1,strong0) #0.2  A16U142Pad2 = rst ? 0 : ~(0|CCH05|A16U141Pad3);
// Gate A16-U127B A16-U126B
pullup(WCH06_);
assign (highz1,strong0) #0.2  WCH06_ = rst ? 1 : ~(0|A16U126Pad8);
// Gate A16-U228B
pullup(A16U227Pad8);
assign (highz1,strong0) #0.2  A16U227Pad8 = rst ? 0 : ~(0|A16U226Pad2|CCH12);
// Gate A16-U202A
pullup(A16U202Pad1);
assign (highz1,strong0) #0.2  A16U202Pad1 = rst ? 0 : ~(0|A16U201Pad7|RCH12_);
// Gate A16-U114B
pullup(A16U114Pad3);
assign (highz1,strong0) #0.2  A16U114Pad3 = rst ? 0 : ~(0|WCH06_|CHWL06_);
// Gate A16-U115A
pullup(A16U114Pad2);
assign (highz1,strong0) #0.2  A16U114Pad2 = rst ? 0 : ~(0|CCH06|A16U114Pad1);
// Gate A16-U114A
pullup(A16U114Pad1);
assign (highz1,strong0) #0.2  A16U114Pad1 = rst ? 1 : ~(0|A16U114Pad2|A16U114Pad3);
// Gate A16-U134A A16-U234B
pullup(CHOR01_);
assign (highz1,strong0) #0.2  CHOR01_ = rst ? 1 : ~(0|A16U132Pad1|CH3201|A16U103Pad9|A16U232Pad1|A16U202Pad1|CH1501);
// Gate A16-U209B
pullup(A16U209Pad2);
assign (highz1,strong0) #0.2  A16U209Pad2 = rst ? 1 : ~(0|A16U208Pad1|A16U209Pad8);
// Gate A16-U136B
pullup(A16U136Pad2);
assign (highz1,strong0) #0.2  A16U136Pad2 = rst ? 0 : ~(0|CCH05|A16U135Pad3);
// Gate A16-U209A
pullup(A16U209Pad1);
assign (highz1,strong0) #0.2  A16U209Pad1 = rst ? 0 : ~(0|A16U209Pad2|RCH12_);
// Gate A16-U116A
pullup(RCmYmR);
assign (highz1,strong0) #0.2  RCmYmR = rst ? 0 : ~(0|A16U114Pad1);
// Gate A16-U235B
pullup(COMACT);
assign (highz1,strong0) #0.2  COMACT = rst ? 0 : ~(0|A16U235Pad3);
// Gate A16-U216B
pullup(A16U216Pad2);
assign (highz1,strong0) #0.2  A16U216Pad2 = rst ? 0 : ~(0|A16U216Pad1|CCH12);
// Gate A16-U206A
pullup(A16U206Pad1);
assign (highz1,strong0) #0.2  A16U206Pad1 = rst ? 0 : ~(0|WCH12_|CHWL03_);
// Gate A16-U210B
pullup(A16U209Pad8);
assign (highz1,strong0) #0.2  A16U209Pad8 = rst ? 0 : ~(0|A16U209Pad2|CCH12);
// Gate A16-U216A
pullup(A16U216Pad1);
assign (highz1,strong0) #0.2  A16U216Pad1 = rst ? 1 : ~(0|A16U216Pad2|A16U216Pad3);
// Gate A16-U256B
pullup(A16U256Pad2);
assign (highz1,strong0) #0.2  A16U256Pad2 = rst ? 0 : ~(0|A16U255Pad9|GOJAM);
// Gate A16-U220B
pullup(ZEROPT);
assign (highz1,strong0) #0.2  ZEROPT = rst ? 0 : ~(0|A16U218Pad7);
// Gate A16-U213B
pullup(A16U212Pad8);
assign (highz1,strong0) #0.2  A16U212Pad8 = rst ? 0 : ~(0|A16U211Pad7|CCH12);
// Gate A16-U205B
pullup(A16U204Pad8);
assign (highz1,strong0) #0.2  A16U204Pad8 = rst ? 0 : ~(0|A16U204Pad2|CCH12);
// Gate A16-U217B
pullup(S4BTAK);
assign (highz1,strong0) #0.2  S4BTAK = rst ? 0 : ~(0|A16U216Pad1);
// Gate A16-U248A
pullup(A16U248Pad1);
assign (highz1,strong0) #0.2  A16U248Pad1 = rst ? 0 : ~(0|RCH11_|A16U247Pad1);
// Gate A16-U241A
pullup(A16U240Pad3);
assign (highz1,strong0) #0.2  A16U240Pad3 = rst ? 0 : ~(0|RCH11_|A16U241Pad3);
// Gate A16-U156A A16-U155A
pullup(WCH05_);
assign (highz1,strong0) #0.2  WCH05_ = rst ? 1 : ~(0|A16U155Pad2);
// Gate A16-U212B
pullup(A16U211Pad7);
assign (highz1,strong0) #0.2  A16U211Pad7 = rst ? 1 : ~(0|A16U211Pad1|A16U212Pad8);
// Gate A16-U254A A16-U255A A16-U253B
pullup(WCH12_);
assign (highz1,strong0) #0.2  WCH12_ = rst ? 1 : ~(0|A16U253Pad8);
// Gate A16-U222B
pullup(A16U221Pad2);
assign (highz1,strong0) #0.2  A16U221Pad2 = rst ? 1 : ~(0|A16U222Pad7|A16U222Pad1);
// Gate A16-U232A
pullup(A16U232Pad1);
assign (highz1,strong0) #0.2  A16U232Pad1 = rst ? 0 : ~(0|RCH11_|A16U231Pad9);
// Gate A16-U151A
pullup(A16U151Pad1);
assign (highz1,strong0) #0.2  A16U151Pad1 = rst ? 0 : ~(0|WCH05_|CHWL08_);
// Gate A16-U237B
pullup(A16U237Pad9);
assign (highz1,strong0) #0.2  A16U237Pad9 = rst ? 1 : ~(0|A16U237Pad7|A16U237Pad1);
// Gate A16-U238B
pullup(A16U237Pad7);
assign (highz1,strong0) #0.2  A16U237Pad7 = rst ? 0 : ~(0|A16U237Pad9|CCH11);
// Gate A16-U153A
pullup(A16U152Pad2);
assign (highz1,strong0) #0.2  A16U152Pad2 = rst ? 0 : ~(0|A16U153Pad2|RCH05_);
// Gate A16-U237A
pullup(A16U237Pad1);
assign (highz1,strong0) #0.2  A16U237Pad1 = rst ? 0 : ~(0|WCH11_|CHWL03_);
// Gate A16-U218B
pullup(A16U218Pad9);
assign (highz1,strong0) #0.2  A16U218Pad9 = rst ? 0 : ~(0|A16U218Pad7|CCH12);
// Gate A16-U108B
pullup(A16U108Pad9);
assign (highz1,strong0) #0.2  A16U108Pad9 = rst ? 0 : ~(0|RCH06_|A16U106Pad2);
// Gate A16-U208A
pullup(A16U208Pad1);
assign (highz1,strong0) #0.2  A16U208Pad1 = rst ? 0 : ~(0|WCH12_|CHWL04_);
// Gate A16-U236B
pullup(A16U236Pad2);
assign (highz1,strong0) #0.2  A16U236Pad2 = rst ? 0 : ~(0|A16U235Pad3|CCH11);
// Gate A16-U260B
pullup(A16J3Pad370);
assign (highz1,strong0) #0.2  A16J3Pad370 = rst ? 1 : ~(0);
// Gate A16-U121A
pullup(A16U120Pad2);
assign (highz1,strong0) #0.2  A16U120Pad2 = rst ? 0 : ~(0|CCH06|A16U119Pad7);
// Gate A16-U102A
pullup(A16U101Pad2);
assign (highz1,strong0) #0.2  A16U101Pad2 = rst ? 1 : ~(0|A16U102Pad2|A16U102Pad3);
// Gate A16-U252A A16-U253A
pullup(OPEROR);
assign (highz1,strong0) #0.2  OPEROR = rst ? 0 : ~(0|FLASH|A16U250Pad9);
// Gate A16-U108A
pullup(A16U107Pad2);
assign (highz1,strong0) #0.2  A16U107Pad2 = rst ? 0 : ~(0|CCH06|A16U106Pad2);
// Gate A16-U214A
pullup(A16U214Pad1);
assign (highz1,strong0) #0.2  A16U214Pad1 = rst ? 0 : ~(0|WCH12_|CHWL06_);
// Gate A16-U250B
pullup(A16U250Pad9);
assign (highz1,strong0) #0.2  A16U250Pad9 = rst ? 1 : ~(0|A16U250Pad1|A16U250Pad8);
// Gate A16-U230A
pullup(CH1214);
assign (highz1,strong0) #0.2  CH1214 = rst ? 0 : ~(0|A16U229Pad2|RCH12_);
// Gate A16-U116B
pullup(OT1207_);
assign (highz1,strong0) #0.2  OT1207_ = rst ? 1 : ~(0|A16U116Pad7);
// Gate A16-U111B
pullup(RCpZmR);
assign (highz1,strong0) #0.2  RCpZmR = rst ? 0 : ~(0|A16U109Pad1);
// Gate A16-U152A
pullup(CHOR08_);
assign (highz1,strong0) #0.2  CHOR08_ = rst ? 1 : ~(0|A16U152Pad2|A16U130Pad9|CH3208);
// Gate A16-U258A A16-U259A A16-U259B
pullup(RCH12_);
assign (highz1,strong0) #0.2  RCH12_ = rst ? 1 : ~(0|A16U258Pad2);
// Gate A16-U130B
pullup(A16U130Pad9);
assign (highz1,strong0) #0.2  A16U130Pad9 = rst ? 0 : ~(0|RCH06_|A16U128Pad7);
// Gate A16-U155B
pullup(A16U155Pad2);
assign (highz1,strong0) #0.2  A16U155Pad2 = rst ? 0 : ~(0|XB5_|XT0_|WCHG_);

endmodule
