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
pullup(g43434);
assign #0.2  g43434 = rst ? 1'bz : ((0|g43433|g43432) ? 1'b0 : 1'bz);
// Gate A16-U247B
pullup(g43433);
assign #0.2  g43433 = rst ? 0 : ((0|g43434|CCH11) ? 1'b0 : 1'bz);
// Gate A16-U138A
pullup(g43116);
assign #0.2  g43116 = rst ? 0 : ((0|RCH05_|g43114) ? 1'b0 : 1'bz);
// Gate A16-U159B
pullup(g43158);
assign #0.2  g43158 = rst ? 0 : ((0|g43157|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U147A
pullup(g43134);
assign #0.2  g43134 = rst ? 0 : ((0|g43132|RCH05_) ? 1'b0 : 1'bz);
// Gate A16-U159A
pullup(g43157);
assign #0.2  g43157 = rst ? 1'bz : ((0|g43158|g43156) ? 1'b0 : 1'bz);
// Gate A16-U106B
pullup(RCmZmR);
assign #0.2  RCmZmR = rst ? 0 : ((0|g43251) ? 1'b0 : 1'bz);
// Gate A16-U135A
pullup(g43110);
assign #0.2  g43110 = rst ? 0 : ((0|RCH05_|g43108) ? 1'b0 : 1'bz);
// Gate A16-U110A
pullup(g43242);
assign #0.2  g43242 = rst ? 0 : ((0|CCH06|g43241) ? 1'b0 : 1'bz);
// Gate A16-U154B
pullup(g43145);
assign #0.2  g43145 = rst ? 0 : ((0|CCH05|g43144) ? 1'b0 : 1'bz);
// Gate A16-U139B
pullup(RCmXpP);
assign #0.2  RCmXpP = rst ? 0 : ((0|g43114) ? 1'b0 : 1'bz);
// Gate A16-U226B
pullup(S4BSEQ);
assign #0.2  S4BSEQ = rst ? 0 : ((0|g43454) ? 1'b0 : 1'bz);
// Gate A16-U152B A16-U252B
pullup(CHOR07_);
assign #0.2  CHOR07_ = rst ? 1'bz : ((0|g43140|g43222|CH3207|g43442|CH1207|CH0707) ? 1'b0 : 1'bz);
// Gate A16-U255B
pullup(g43350);
assign #0.2  g43350 = rst ? 0 : ((0|CCHG_|XT1_|XB2_) ? 1'b0 : 1'bz);
// Gate A16-U230B
pullup(g43458);
assign #0.2  g43458 = rst ? 0 : ((0|g43457|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U123B A16-U124B
pullup(RCH06_);
assign #0.2  RCH06_ = rst ? 1'bz : ((0|g43213) ? 1'b0 : 1'bz);
// Gate A16-U201A
pullup(g43305);
assign #0.2  g43305 = rst ? 0 : ((0|WCH12_|CHWL01_) ? 1'b0 : 1'bz);
// Gate A16-U208B
pullup(g43314);
assign #0.2  g43314 = rst ? 0 : ((0|g43313|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U117B
pullup(CH1207);
assign #0.2  CH1207 = rst ? 0 : ((0|RCH12_|g43225) ? 1'b0 : 1'bz);
// Gate A16-U160B
pullup(CH1208);
assign #0.2  CH1208 = rst ? 0 : ((0|RCH12_|g43157) ? 1'b0 : 1'bz);
// Gate A16-U217A
pullup(CH1209);
assign #0.2  CH1209 = rst ? 0 : ((0|g43333|RCH12_) ? 1'b0 : 1'bz);
// Gate A16-U207A
pullup(g43311);
assign #0.2  g43311 = rst ? 0 : ((0|g43313|RCH12_) ? 1'b0 : 1'bz);
// Gate A16-U121B
pullup(g43222);
assign #0.2  g43222 = rst ? 0 : ((0|RCH06_|g43220) ? 1'b0 : 1'bz);
// Gate A16-U145A
pullup(g43131);
assign #0.2  g43131 = rst ? 0 : ((0|WCH05_|CHWL06_) ? 1'b0 : 1'bz);
// Gate A16-U124A
pullup(g43213);
assign #0.2  g43213 = rst ? 0 : ((0|XB6_|XT0_) ? 1'b0 : 1'bz);
// Gate A16-U258B
pullup(g43360);
assign #0.2  g43360 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A16-U141A
pullup(g43122);
assign #0.2  g43122 = rst ? 0 : ((0|RCH05_|g43120) ? 1'b0 : 1'bz);
// Gate A16-U254B
pullup(g43349);
assign #0.2  g43349 = rst ? 0 : ((0|WCHG_|XT1_|XB2_) ? 1'b0 : 1'bz);
// Gate A16-U235A
pullup(g43411);
assign #0.2  g43411 = rst ? 0 : ((0|RCH11_|g43409) ? 1'b0 : 1'bz);
// Gate A16-U147B
pullup(RCmXmY);
assign #0.2  RCmXmY = rst ? 0 : ((0|g43132) ? 1'b0 : 1'bz);
// Gate A16-U221A
pullup(CH1211);
assign #0.2  CH1211 = rst ? 0 : ((0|g43343|RCH12_) ? 1'b0 : 1'bz);
// Gate A16-U207B
pullup(g43313);
assign #0.2  g43313 = rst ? 1'bz : ((0|g43315|g43314) ? 1'b0 : 1'bz);
// Gate A16-U151B
pullup(RCmXpY);
assign #0.2  RCmXpY = rst ? 0 : ((0|g43138) ? 1'b0 : 1'bz);
// Gate A16-U110B
pullup(g43243);
assign #0.2  g43243 = rst ? 0 : ((0|RCH06_|g43241) ? 1'b0 : 1'bz);
// Gate A16-U130A
pullup(g43203);
assign #0.2  g43203 = rst ? 0 : ((0|CCH06|g43202) ? 1'b0 : 1'bz);
// Gate A16-U129B
pullup(g43201);
assign #0.2  g43201 = rst ? 0 : ((0|WCH06_|CHWL08_) ? 1'b0 : 1'bz);
// Gate A16-U144B
pullup(g43127);
assign #0.2  g43127 = rst ? 0 : ((0|CCH05|g43126) ? 1'b0 : 1'bz);
// Gate A16-U120A
pullup(g43220);
assign #0.2  g43220 = rst ? 1'bz : ((0|g43221|g43219) ? 1'b0 : 1'bz);
// Gate A16-U224A
pullup(CH1212);
assign #0.2  CH1212 = rst ? 0 : ((0|g43447|RCH12_) ? 1'b0 : 1'bz);
// Gate A16-U113B
pullup(g43238);
assign #0.2  g43238 = rst ? 0 : ((0|RCH06_|g43236) ? 1'b0 : 1'bz);
// Gate A16-U143A
pullup(g43125);
assign #0.2  g43125 = rst ? 0 : ((0|WCH05_|CHWL05_) ? 1'b0 : 1'bz);
// Gate A16-U146B A16-U249A
pullup(CHOR06_);
assign #0.2  CHOR06_ = rst ? 1'bz : ((0|CH3206|g43233|g43134|g43436|CH0706|g43329) ? 1'b0 : 1'bz);
// Gate A16-U203A
pullup(g43306);
assign #0.2  g43306 = rst ? 0 : ((0|WCH12_|CHWL02_) ? 1'b0 : 1'bz);
// Gate A16-U242B
pullup(g43422);
assign #0.2  g43422 = rst ? 0 : ((0|g43421|CCH11) ? 1'b0 : 1'bz);
// Gate A16-U143B
pullup(g43126);
assign #0.2  g43126 = rst ? 1'bz : ((0|g43127|g43125) ? 1'b0 : 1'bz);
// Gate A16-U157B
pullup(g43152);
assign #0.2  g43152 = rst ? 0 : ((0|XB5_|CCHG_|XT0_) ? 1'b0 : 1'bz);
// Gate A16-U141B
pullup(RCpXmP);
assign #0.2  RCpXmP = rst ? 0 : ((0|g43120) ? 1'b0 : 1'bz);
// Gate A16-U220A
pullup(CH1210);
assign #0.2  CH1210 = rst ? 0 : ((0|g43337|RCH12_) ? 1'b0 : 1'bz);
// Gate A16-U154A
pullup(g43144);
assign #0.2  g43144 = rst ? 1'bz : ((0|g43145|g43143) ? 1'b0 : 1'bz);
// Gate A16-U223A
pullup(g43446);
assign #0.2  g43446 = rst ? 0 : ((0|WCH12_|CHWL12_) ? 1'b0 : 1'bz);
// Gate A16-U156B
pullup(g43153);
assign #0.2  g43153 = rst ? 0 : ((0|GOJAM|g43152) ? 1'b0 : 1'bz);
// Gate A16-U127A A16-U126A
pullup(CCH06);
assign #0.2  CCH06 = rst ? 1'bz : ((0|g43210) ? 1'b0 : 1'bz);
// Gate A16-U158A A16-U157A
pullup(CCH05);
assign #0.2  CCH05 = rst ? 1'bz : ((0|g43153) ? 1'b0 : 1'bz);
// Gate A16-U133A
pullup(g43107);
assign #0.2  g43107 = rst ? 0 : ((0|WCH05_|CHWL02_) ? 1'b0 : 1'bz);
// Gate A16-U153B
pullup(RCpXmY);
assign #0.2  RCpXmY = rst ? 0 : ((0|g43144) ? 1'b0 : 1'bz);
// Gate A16-U238A
pullup(g43414);
assign #0.2  g43414 = rst ? 0 : ((0|RCH11_|g43416) ? 1'b0 : 1'bz);
// Gate A16-U229B
pullup(g43457);
assign #0.2  g43457 = rst ? 1'bz : ((0|g43456|g43458) ? 1'b0 : 1'bz);
// Gate A16-U236A
pullup(g43409);
assign #0.2  g43409 = rst ? 1'bz : ((0|g43410|g43406) ? 1'b0 : 1'bz);
// Gate A16-U251A
pullup(g43442);
assign #0.2  g43442 = rst ? 0 : ((0|g43444|RCH11_) ? 1'b0 : 1'bz);
// Gate A16-U205A
pullup(ENEROP);
assign #0.2  ENEROP = rst ? 0 : ((0|g43307) ? 1'b0 : 1'bz);
// Gate A16-U219A
pullup(g43336);
assign #0.2  g43336 = rst ? 0 : ((0|WCH12_|CHWL10_) ? 1'b0 : 1'bz);
// Gate A16-U226A
pullup(CH1213);
assign #0.2  CH1213 = rst ? 0 : ((0|g43454|RCH12_) ? 1'b0 : 1'bz);
// Gate A16-U158B
pullup(g43156);
assign #0.2  g43156 = rst ? 0 : ((0|CHWL08_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U211A
pullup(g43325);
assign #0.2  g43325 = rst ? 0 : ((0|WCH12_|CHWL05_) ? 1'b0 : 1'bz);
// Gate A16-U225B
pullup(g43448);
assign #0.2  g43448 = rst ? 0 : ((0|g43447|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U123A
pullup(g43216);
assign #0.2  g43216 = rst ? 0 : ((0|XT0_|XB5_) ? 1'b0 : 1'bz);
// Gate A16-U244B
pullup(g43430);
assign #0.2  g43430 = rst ? 1'bz : ((0|g43429|g43431) ? 1'b0 : 1'bz);
// Gate A16-U214B
pullup(g43327);
assign #0.2  g43327 = rst ? 1'bz : ((0|g43326|g43328) ? 1'b0 : 1'bz);
// Gate A16-U224B
pullup(g43447);
assign #0.2  g43447 = rst ? 1'bz : ((0|g43446|g43448) ? 1'b0 : 1'bz);
// Gate A16-U228A
pullup(g43456);
assign #0.2  g43456 = rst ? 0 : ((0|WCH12_|CHWL14_) ? 1'b0 : 1'bz);
// Gate A16-U146A A16-U245B
pullup(CHOR05_);
assign #0.2  CHOR05_ = rst ? 1'bz : ((0|CH3205|g43238|g43128|CH0705|g43321|g43428) ? 1'b0 : 1'bz);
// Gate A16-U219B
pullup(g43337);
assign #0.2  g43337 = rst ? 1'bz : ((0|g43338|g43336) ? 1'b0 : 1'bz);
// Gate A16-U119B
pullup(RCmYpR);
assign #0.2  RCmYpR = rst ? 0 : ((0|g43220) ? 1'b0 : 1'bz);
// Gate A16-U239B
pullup(UPLACT);
assign #0.2  UPLACT = rst ? 0 : ((0|g43416) ? 1'b0 : 1'bz);
// Gate A16-U148B
pullup(g43133);
assign #0.2  g43133 = rst ? 0 : ((0|CCH05|g43132) ? 1'b0 : 1'bz);
// Gate A16-U144A
pullup(g43128);
assign #0.2  g43128 = rst ? 0 : ((0|RCH05_|g43126) ? 1'b0 : 1'bz);
// Gate A16-U244A
pullup(g43431);
assign #0.2  g43431 = rst ? 0 : ((0|WCH11_|CHWL05_) ? 1'b0 : 1'bz);
// Gate A16-U107B
pullup(g43245);
assign #0.2  g43245 = rst ? 0 : ((0|WCH06_|CHWL03_) ? 1'b0 : 1'bz);
// Gate A16-U120B
pullup(g43219);
assign #0.2  g43219 = rst ? 0 : ((0|CHWL07_|WCH06_) ? 1'b0 : 1'bz);
// Gate A16-U233A
pullup(g43406);
assign #0.2  g43406 = rst ? 0 : ((0|WCH11_|CHWL02_) ? 1'b0 : 1'bz);
// Gate A16-U142A
pullup(g43120);
assign #0.2  g43120 = rst ? 1'bz : ((0|g43121|g43119) ? 1'b0 : 1'bz);
// Gate A16-U218A
pullup(g43335);
assign #0.2  g43335 = rst ? 0 : ((0|WCH12_|CHWL09_) ? 1'b0 : 1'bz);
// Gate A16-U105B
pullup(g43253);
assign #0.2  g43253 = rst ? 0 : ((0|RCH06_|g43251) ? 1'b0 : 1'bz);
// Gate A16-U112B
pullup(g43235);
assign #0.2  g43235 = rst ? 0 : ((0|WCH06_|CHWL05_) ? 1'b0 : 1'bz);
// Gate A16-U113A
pullup(g43237);
assign #0.2  g43237 = rst ? 0 : ((0|CCH06|g43236) ? 1'b0 : 1'bz);
// Gate A16-U128A
pullup(g43206);
assign #0.2  g43206 = rst ? 0 : ((0|XB6_|WCHG_|XT0_) ? 1'b0 : 1'bz);
// Gate A16-U160A
pullup(TVCNAB);
assign #0.2  TVCNAB = rst ? 0 : ((0|g43157) ? 1'b0 : 1'bz);
// Gate A16-U211B
pullup(ZIMCDU);
assign #0.2  ZIMCDU = rst ? 0 : ((0|g43323) ? 1'b0 : 1'bz);
// Gate A16-U215A
pullup(g43329);
assign #0.2  g43329 = rst ? 0 : ((0|g43327|RCH12_) ? 1'b0 : 1'bz);
// Gate A16-U148A
pullup(g43132);
assign #0.2  g43132 = rst ? 1'bz : ((0|g43133|g43131) ? 1'b0 : 1'bz);
// Gate A16-U241B
pullup(TMPOUT);
assign #0.2  TMPOUT = rst ? 0 : ((0|g43421) ? 1'b0 : 1'bz);
// Gate A16-U125B
pullup(g43209);
assign #0.2  g43209 = rst ? 0 : ((0|CCHG_|XT0_|XB6_) ? 1'b0 : 1'bz);
// Gate A16-U125A
pullup(g43210);
assign #0.2  g43210 = rst ? 0 : ((0|GOJAM|g43209) ? 1'b0 : 1'bz);
// Gate A16-U223B
pullup(g43344);
assign #0.2  g43344 = rst ? 0 : ((0|g43343|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U140A A16-U240A
pullup(CHOR04_);
assign #0.2  CHOR04_ = rst ? 1'bz : ((0|g43243|g43122|CH3204|CH1504|g43423|g43319) ? 1'b0 : 1'bz);
// Gate A16-U203B
pullup(g43304);
assign #0.2  g43304 = rst ? 0 : ((0|g43303|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U213A
pullup(ENERIM);
assign #0.2  ENERIM = rst ? 0 : ((0|g43327) ? 1'b0 : 1'bz);
// Gate A16-U132A
pullup(g43104);
assign #0.2  g43104 = rst ? 0 : ((0|RCH05_|g43102) ? 1'b0 : 1'bz);
// Gate A16-U128B
pullup(RCpYmR);
assign #0.2  RCpYmR = rst ? 0 : ((0|g43202) ? 1'b0 : 1'bz);
// Gate A16-U246A
pullup(g43432);
assign #0.2  g43432 = rst ? 0 : ((0|WCH11_|CHWL06_) ? 1'b0 : 1'bz);
// Gate A16-U239A
pullup(g43418);
assign #0.2  g43418 = rst ? 0 : ((0|WCH11_|CHWL04_) ? 1'b0 : 1'bz);
// Gate A16-U139A
pullup(g43119);
assign #0.2  g43119 = rst ? 0 : ((0|WCH05_|CHWL04_) ? 1'b0 : 1'bz);
// Gate A16-U245A A16-U246B
pullup(KYRLS);
assign #0.2  KYRLS = rst ? 0 : ((0|FLASH|g43430) ? 1'b0 : 1'bz);
// Gate A16-U150B
pullup(g43139);
assign #0.2  g43139 = rst ? 0 : ((0|CCH05|g43138) ? 1'b0 : 1'bz);
// Gate A16-U149A
pullup(g43137);
assign #0.2  g43137 = rst ? 0 : ((0|WCH05_|CHWL07_) ? 1'b0 : 1'bz);
// Gate A16-U242A
pullup(g43421);
assign #0.2  g43421 = rst ? 1'bz : ((0|g43422|g43418) ? 1'b0 : 1'bz);
// Gate A16-U118B
pullup(g43226);
assign #0.2  g43226 = rst ? 0 : ((0|g43225|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U149B
pullup(g43138);
assign #0.2  g43138 = rst ? 1'bz : ((0|g43139|g43137) ? 1'b0 : 1'bz);
// Gate A16-U117A
pullup(OT1207);
assign #0.2  OT1207 = rst ? 0 : ((0|g43225) ? 1'b0 : 1'bz);
// Gate A16-U109A
pullup(g43241);
assign #0.2  g43241 = rst ? 1'bz : ((0|g43242|g43240) ? 1'b0 : 1'bz);
// Gate A16-U109B
pullup(g43240);
assign #0.2  g43240 = rst ? 0 : ((0|WCH06_|CHWL04_) ? 1'b0 : 1'bz);
// Gate A16-U135B
pullup(RCmXmP);
assign #0.2  RCmXmP = rst ? 0 : ((0|g43108) ? 1'b0 : 1'bz);
// Gate A16-U104A
pullup(g43251);
assign #0.2  g43251 = rst ? 1'bz : ((0|g43252|g43250) ? 1'b0 : 1'bz);
// Gate A16-U105A
pullup(g43252);
assign #0.2  g43252 = rst ? 0 : ((0|CCH06|g43251) ? 1'b0 : 1'bz);
// Gate A16-U104B
pullup(g43250);
assign #0.2  g43250 = rst ? 0 : ((0|WCH06_|CHWL02_) ? 1'b0 : 1'bz);
// Gate A16-U115B
pullup(g43233);
assign #0.2  g43233 = rst ? 0 : ((0|RCH06_|g43231) ? 1'b0 : 1'bz);
// Gate A16-U129A
pullup(g43202);
assign #0.2  g43202 = rst ? 1'bz : ((0|g43201|g43203) ? 1'b0 : 1'bz);
// Gate A16-U118A
pullup(g43225);
assign #0.2  g43225 = rst ? 1'bz : ((0|g43226|g43224) ? 1'b0 : 1'bz);
// Gate A16-U150A
pullup(g43140);
assign #0.2  g43140 = rst ? 0 : ((0|RCH05_|g43138) ? 1'b0 : 1'bz);
// Gate A16-U201B
pullup(ZOPCDU);
assign #0.2  ZOPCDU = rst ? 0 : ((0|g43303) ? 1'b0 : 1'bz);
// Gate A16-U103A
pullup(g43257);
assign #0.2  g43257 = rst ? 0 : ((0|CCH06|g43256) ? 1'b0 : 1'bz);
// Gate A16-U102B
pullup(g43255);
assign #0.2  g43255 = rst ? 0 : ((0|WCH06_|CHWL01_) ? 1'b0 : 1'bz);
// Gate A16-U119A
pullup(g43224);
assign #0.2  g43224 = rst ? 0 : ((0|CHWL07_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U243A
pullup(g43428);
assign #0.2  g43428 = rst ? 0 : ((0|RCH11_|g43430) ? 1'b0 : 1'bz);
// Gate A16-U140B A16-U240B
pullup(CHOR03_);
assign #0.2  CHOR03_ = rst ? 1'bz : ((0|g43116|g43248|CH3203|g43414|g43311|CH1503) ? 1'b0 : 1'bz);
// Gate A16-U225A
pullup(MROLGT);
assign #0.2  MROLGT = rst ? 0 : ((0|g43447) ? 1'b0 : 1'bz);
// Gate A16-U243B
pullup(g43429);
assign #0.2  g43429 = rst ? 0 : ((0|g43430|CCH11) ? 1'b0 : 1'bz);
// Gate A16-U222A
pullup(g43345);
assign #0.2  g43345 = rst ? 0 : ((0|WCH12_|CHWL11_) ? 1'b0 : 1'bz);
// Gate A16-U250A
pullup(g43445);
assign #0.2  g43445 = rst ? 0 : ((0|CHWL07_|WCH11_) ? 1'b0 : 1'bz);
// Gate A16-U107A
pullup(g43246);
assign #0.2  g43246 = rst ? 1'bz : ((0|g43247|g43245) ? 1'b0 : 1'bz);
// Gate A16-U111A
pullup(RCpYpR);
assign #0.2  RCpYpR = rst ? 0 : ((0|g43236) ? 1'b0 : 1'bz);
// Gate A16-U145B
pullup(RCpXpY);
assign #0.2  RCpXpY = rst ? 0 : ((0|g43126) ? 1'b0 : 1'bz);
// Gate A16-U227B
pullup(g43454);
assign #0.2  g43454 = rst ? 1'bz : ((0|g43455|g43453) ? 1'b0 : 1'bz);
// Gate A16-U249B A16-U248B
pullup(VNFLSH);
assign #0.2  VNFLSH = rst ? 0 : ((0|FLASH_|g43434) ? 1'b0 : 1'bz);
// Gate A16-U101B
pullup(g43260);
assign #0.2  g43260 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A16-U133B
pullup(RCpXpP);
assign #0.2  RCpXpP = rst ? 0 : ((0|g43102) ? 1'b0 : 1'bz);
// Gate A16-U112A
pullup(g43236);
assign #0.2  g43236 = rst ? 1'bz : ((0|g43237|g43235) ? 1'b0 : 1'bz);
// Gate A16-U233B
pullup(ISSWAR);
assign #0.2  ISSWAR = rst ? 0 : ((0|g43404) ? 1'b0 : 1'bz);
// Gate A16-U251B
pullup(g43443);
assign #0.2  g43443 = rst ? 0 : ((0|g43444|CCH11) ? 1'b0 : 1'bz);
// Gate A16-U260A
pullup(g43355);
assign #0.2  g43355 = rst ? 0 : ((0|XB2_|XT1_) ? 1'b0 : 1'bz);
// Gate A16-U131A
pullup(g43102);
assign #0.2  g43102 = rst ? 1'bz : ((0|g43101|g43103) ? 1'b0 : 1'bz);
// Gate A16-U131B
pullup(g43101);
assign #0.2  g43101 = rst ? 0 : ((0|CHWL01_|WCH05_) ? 1'b0 : 1'bz);
// Gate A16-U132B
pullup(g43103);
assign #0.2  g43103 = rst ? 0 : ((0|CCH05|g43102) ? 1'b0 : 1'bz);
// Gate A16-U101A
pullup(RCpZpR);
assign #0.2  RCpZpR = rst ? 0 : ((0|g43256) ? 1'b0 : 1'bz);
// Gate A16-U204B
pullup(g43307);
assign #0.2  g43307 = rst ? 1'bz : ((0|g43306|g43308) ? 1'b0 : 1'bz);
// Gate A16-U204A
pullup(g43309);
assign #0.2  g43309 = rst ? 0 : ((0|g43307|RCH12_) ? 1'b0 : 1'bz);
// Gate A16-U212A
pullup(g43321);
assign #0.2  g43321 = rst ? 0 : ((0|g43323|RCH12_) ? 1'b0 : 1'bz);
// Gate A16-U137A
pullup(g43113);
assign #0.2  g43113 = rst ? 0 : ((0|WCH05_|CHWL03_) ? 1'b0 : 1'bz);
// Gate A16-U134B A16-U234A
pullup(CHOR02_);
assign #0.2  CHOR02_ = rst ? 1'bz : ((0|CH3202|g43253|g43110|g43411|g43309|CH1502) ? 1'b0 : 1'bz);
// Gate A16-U138B
pullup(g43115);
assign #0.2  g43115 = rst ? 0 : ((0|CCH05|g43114) ? 1'b0 : 1'bz);
// Gate A16-U221B
pullup(DISDAC);
assign #0.2  DISDAC = rst ? 0 : ((0|g43343) ? 1'b0 : 1'bz);
// Gate A16-U103B
pullup(g43258);
assign #0.2  g43258 = rst ? 0 : ((0|RCH06_|g43256) ? 1'b0 : 1'bz);
// Gate A16-U137B
pullup(g43114);
assign #0.2  g43114 = rst ? 1'bz : ((0|g43115|g43113) ? 1'b0 : 1'bz);
// Gate A16-U202B
pullup(g43303);
assign #0.2  g43303 = rst ? 1'bz : ((0|g43305|g43304) ? 1'b0 : 1'bz);
// Gate A16-U256A A16-U257A A16-U257B
pullup(CCH12);
assign #0.2  CCH12 = rst ? 1'bz : ((0|g43351) ? 1'b0 : 1'bz);
// Gate A16-U215B
pullup(g43328);
assign #0.2  g43328 = rst ? 0 : ((0|g43327|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U231A
pullup(g43405);
assign #0.2  g43405 = rst ? 0 : ((0|WCH11_|CHWL01_) ? 1'b0 : 1'bz);
// Gate A16-U232B
pullup(g43403);
assign #0.2  g43403 = rst ? 0 : ((0|g43404|CCH11) ? 1'b0 : 1'bz);
// Gate A16-U206B
pullup(STARON);
assign #0.2  STARON = rst ? 0 : ((0|g43313) ? 1'b0 : 1'bz);
// Gate A16-U106A
pullup(RCmZpR);
assign #0.2  RCmZpR = rst ? 0 : ((0|g43246) ? 1'b0 : 1'bz);
// Gate A16-U231B
pullup(g43404);
assign #0.2  g43404 = rst ? 1'bz : ((0|g43403|g43405) ? 1'b0 : 1'bz);
// Gate A16-U122A A16-U122B
pullup(RCH05_);
assign #0.2  RCH05_ = rst ? 1'bz : ((0|g43216) ? 1'b0 : 1'bz);
// Gate A16-U229A
pullup(S4BOFF);
assign #0.2  S4BOFF = rst ? 0 : ((0|g43457) ? 1'b0 : 1'bz);
// Gate A16-U136A
pullup(g43108);
assign #0.2  g43108 = rst ? 1'bz : ((0|g43109|g43107) ? 1'b0 : 1'bz);
// Gate A16-U210A
pullup(COARSE);
assign #0.2  COARSE = rst ? 0 : ((0|g43317) ? 1'b0 : 1'bz);
// Gate A16-U227A
pullup(g43455);
assign #0.2  g43455 = rst ? 0 : ((0|WCH12_|CHWL13_) ? 1'b0 : 1'bz);
// Gate A16-U142B
pullup(g43121);
assign #0.2  g43121 = rst ? 0 : ((0|CCH05|g43120) ? 1'b0 : 1'bz);
// Gate A16-U127B A16-U126B
pullup(WCH06_);
assign #0.2  WCH06_ = rst ? 1'bz : ((0|g43206) ? 1'b0 : 1'bz);
// Gate A16-U228B
pullup(g43453);
assign #0.2  g43453 = rst ? 0 : ((0|g43454|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U202A
pullup(g43301);
assign #0.2  g43301 = rst ? 0 : ((0|g43303|RCH12_) ? 1'b0 : 1'bz);
// Gate A16-U114B
pullup(g43230);
assign #0.2  g43230 = rst ? 0 : ((0|WCH06_|CHWL06_) ? 1'b0 : 1'bz);
// Gate A16-U115A
pullup(g43232);
assign #0.2  g43232 = rst ? 0 : ((0|CCH06|g43231) ? 1'b0 : 1'bz);
// Gate A16-U114A
pullup(g43231);
assign #0.2  g43231 = rst ? 1'bz : ((0|g43232|g43230) ? 1'b0 : 1'bz);
// Gate A16-U134A A16-U234B
pullup(CHOR01_);
assign #0.2  CHOR01_ = rst ? 1'bz : ((0|g43104|CH3201|g43258|g43402|g43301|CH1501) ? 1'b0 : 1'bz);
// Gate A16-U209B
pullup(g43317);
assign #0.2  g43317 = rst ? 1'bz : ((0|g43316|g43318) ? 1'b0 : 1'bz);
// Gate A16-U136B
pullup(g43109);
assign #0.2  g43109 = rst ? 0 : ((0|CCH05|g43108) ? 1'b0 : 1'bz);
// Gate A16-U209A
pullup(g43319);
assign #0.2  g43319 = rst ? 0 : ((0|g43317|RCH12_) ? 1'b0 : 1'bz);
// Gate A16-U116A
pullup(RCmYmR);
assign #0.2  RCmYmR = rst ? 0 : ((0|g43231) ? 1'b0 : 1'bz);
// Gate A16-U235B
pullup(COMACT);
assign #0.2  COMACT = rst ? 0 : ((0|g43409) ? 1'b0 : 1'bz);
// Gate A16-U216B
pullup(g43334);
assign #0.2  g43334 = rst ? 0 : ((0|g43333|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U206A
pullup(g43315);
assign #0.2  g43315 = rst ? 0 : ((0|WCH12_|CHWL03_) ? 1'b0 : 1'bz);
// Gate A16-U210B
pullup(g43318);
assign #0.2  g43318 = rst ? 0 : ((0|g43317|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U216A
pullup(g43333);
assign #0.2  g43333 = rst ? 1'bz : ((0|g43334|g43335) ? 1'b0 : 1'bz);
// Gate A16-U256B
pullup(g43351);
assign #0.2  g43351 = rst ? 0 : ((0|g43350|GOJAM) ? 1'b0 : 1'bz);
// Gate A16-U220B
pullup(ZEROPT);
assign #0.2  ZEROPT = rst ? 0 : ((0|g43337) ? 1'b0 : 1'bz);
// Gate A16-U213B
pullup(g43324);
assign #0.2  g43324 = rst ? 0 : ((0|g43323|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U205B
pullup(g43308);
assign #0.2  g43308 = rst ? 0 : ((0|g43307|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U217B
pullup(S4BTAK);
assign #0.2  S4BTAK = rst ? 0 : ((0|g43333) ? 1'b0 : 1'bz);
// Gate A16-U248A
pullup(g43436);
assign #0.2  g43436 = rst ? 0 : ((0|RCH11_|g43434) ? 1'b0 : 1'bz);
// Gate A16-U241A
pullup(g43423);
assign #0.2  g43423 = rst ? 0 : ((0|RCH11_|g43421) ? 1'b0 : 1'bz);
// Gate A16-U156A A16-U155A
pullup(WCH05_);
assign #0.2  WCH05_ = rst ? 1'bz : ((0|g43151) ? 1'b0 : 1'bz);
// Gate A16-U212B
pullup(g43323);
assign #0.2  g43323 = rst ? 1'bz : ((0|g43325|g43324) ? 1'b0 : 1'bz);
// Gate A16-U254A A16-U255A A16-U253B
pullup(WCH12_);
assign #0.2  WCH12_ = rst ? 1'bz : ((0|g43349) ? 1'b0 : 1'bz);
// Gate A16-U222B
pullup(g43343);
assign #0.2  g43343 = rst ? 1'bz : ((0|g43344|g43345) ? 1'b0 : 1'bz);
// Gate A16-U232A
pullup(g43402);
assign #0.2  g43402 = rst ? 0 : ((0|RCH11_|g43404) ? 1'b0 : 1'bz);
// Gate A16-U151A
pullup(g43143);
assign #0.2  g43143 = rst ? 0 : ((0|WCH05_|CHWL08_) ? 1'b0 : 1'bz);
// Gate A16-U237B
pullup(g43416);
assign #0.2  g43416 = rst ? 1'bz : ((0|g43415|g43417) ? 1'b0 : 1'bz);
// Gate A16-U238B
pullup(g43415);
assign #0.2  g43415 = rst ? 0 : ((0|g43416|CCH11) ? 1'b0 : 1'bz);
// Gate A16-U153A
pullup(g43146);
assign #0.2  g43146 = rst ? 0 : ((0|g43144|RCH05_) ? 1'b0 : 1'bz);
// Gate A16-U237A
pullup(g43417);
assign #0.2  g43417 = rst ? 0 : ((0|WCH11_|CHWL03_) ? 1'b0 : 1'bz);
// Gate A16-U218B
pullup(g43338);
assign #0.2  g43338 = rst ? 0 : ((0|g43337|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U108B
pullup(g43248);
assign #0.2  g43248 = rst ? 0 : ((0|RCH06_|g43246) ? 1'b0 : 1'bz);
// Gate A16-U208A
pullup(g43316);
assign #0.2  g43316 = rst ? 0 : ((0|WCH12_|CHWL04_) ? 1'b0 : 1'bz);
// Gate A16-U236B
pullup(g43410);
assign #0.2  g43410 = rst ? 0 : ((0|g43409|CCH11) ? 1'b0 : 1'bz);
// Gate A16-U260B
pullup(g43359);
assign #0.2  g43359 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A16-U121A
pullup(g43221);
assign #0.2  g43221 = rst ? 0 : ((0|CCH06|g43220) ? 1'b0 : 1'bz);
// Gate A16-U102A
pullup(g43256);
assign #0.2  g43256 = rst ? 1'bz : ((0|g43257|g43255) ? 1'b0 : 1'bz);
// Gate A16-U252A A16-U253A
pullup(OPEROR);
assign #0.2  OPEROR = rst ? 0 : ((0|FLASH|g43444) ? 1'b0 : 1'bz);
// Gate A16-U108A
pullup(g43247);
assign #0.2  g43247 = rst ? 0 : ((0|CCH06|g43246) ? 1'b0 : 1'bz);
// Gate A16-U214A
pullup(g43326);
assign #0.2  g43326 = rst ? 0 : ((0|WCH12_|CHWL06_) ? 1'b0 : 1'bz);
// Gate A16-U250B
pullup(g43444);
assign #0.2  g43444 = rst ? 1'bz : ((0|g43445|g43443) ? 1'b0 : 1'bz);
// Gate A16-U230A
pullup(CH1214);
assign #0.2  CH1214 = rst ? 0 : ((0|g43457|RCH12_) ? 1'b0 : 1'bz);
// Gate A16-U116B
pullup(OT1207_);
assign #0.2  OT1207_ = rst ? 1'bz : ((0|g43226) ? 1'b0 : 1'bz);
// Gate A16-U111B
pullup(RCpZmR);
assign #0.2  RCpZmR = rst ? 0 : ((0|g43241) ? 1'b0 : 1'bz);
// Gate A16-U152A
pullup(CHOR08_);
assign #0.2  CHOR08_ = rst ? 1'bz : ((0|g43146|g43204|CH3208) ? 1'b0 : 1'bz);
// Gate A16-U258A A16-U259A A16-U259B
pullup(RCH12_);
assign #0.2  RCH12_ = rst ? 1'bz : ((0|g43355) ? 1'b0 : 1'bz);
// Gate A16-U130B
pullup(g43204);
assign #0.2  g43204 = rst ? 0 : ((0|RCH06_|g43202) ? 1'b0 : 1'bz);
// Gate A16-U155B
pullup(g43151);
assign #0.2  g43151 = rst ? 0 : ((0|XB5_|XT0_|WCHG_) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
