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

parameter GATE_DELAY = 0.2; // This default may be overridden at compile time.
initial $display("Gate delay (A16) will be %f ns.", GATE_DELAY*100);

// Gate A16-U247A
pullup(g43434);
assign #GATE_DELAY g43434 = rst ? 1'bz : ((0|g43432|g43433) ? 1'b0 : 1'bz);
// Gate A16-U247B
pullup(g43433);
assign #GATE_DELAY g43433 = rst ? 0 : ((0|g43434|CCH11) ? 1'b0 : 1'bz);
// Gate A16-U138A
pullup(g43116);
assign #GATE_DELAY g43116 = rst ? 0 : ((0|g43114|RCH05_) ? 1'b0 : 1'bz);
// Gate A16-U159B
pullup(g43158);
assign #GATE_DELAY g43158 = rst ? 0 : ((0|g43157|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U147A
pullup(g43134);
assign #GATE_DELAY g43134 = rst ? 0 : ((0|RCH05_|g43132) ? 1'b0 : 1'bz);
// Gate A16-U159A
pullup(g43157);
assign #GATE_DELAY g43157 = rst ? 1'bz : ((0|g43156|g43158) ? 1'b0 : 1'bz);
// Gate A16-U106B
pullup(RCmZmR);
assign #GATE_DELAY RCmZmR = rst ? 0 : ((0|g43251) ? 1'b0 : 1'bz);
// Gate A16-U135A
pullup(g43110);
assign #GATE_DELAY g43110 = rst ? 0 : ((0|g43108|RCH05_) ? 1'b0 : 1'bz);
// Gate A16-U110A
pullup(g43242);
assign #GATE_DELAY g43242 = rst ? 0 : ((0|g43241|CCH06) ? 1'b0 : 1'bz);
// Gate A16-U154B
pullup(g43145);
assign #GATE_DELAY g43145 = rst ? 0 : ((0|CCH05|g43144) ? 1'b0 : 1'bz);
// Gate A16-U139B
pullup(RCmXpP);
assign #GATE_DELAY RCmXpP = rst ? 0 : ((0|g43114) ? 1'b0 : 1'bz);
// Gate A16-U226B
pullup(S4BSEQ);
assign #GATE_DELAY S4BSEQ = rst ? 0 : ((0|g43454) ? 1'b0 : 1'bz);
// Gate A16-U152B A16-U252B
pullup(CHOR07_);
assign #GATE_DELAY CHOR07_ = rst ? 1'bz : ((0|g43140|g43222|CH3207|g43442|CH1207|CH0707) ? 1'b0 : 1'bz);
// Gate A16-U255B
pullup(g43350);
assign #GATE_DELAY g43350 = rst ? 0 : ((0|CCHG_|XT1_|XB2_) ? 1'b0 : 1'bz);
// Gate A16-U230B
pullup(g43458);
assign #GATE_DELAY g43458 = rst ? 0 : ((0|g43457|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U123B A16-U124B
pullup(RCH06_);
assign #GATE_DELAY RCH06_ = rst ? 1'bz : ((0|g43213) ? 1'b0 : 1'bz);
// Gate A16-U201A
pullup(g43305);
assign #GATE_DELAY g43305 = rst ? 0 : ((0|CHWL01_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U208B
pullup(g43314);
assign #GATE_DELAY g43314 = rst ? 0 : ((0|g43313|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U117B
pullup(CH1207);
assign #GATE_DELAY CH1207 = rst ? 0 : ((0|RCH12_|g43225) ? 1'b0 : 1'bz);
// Gate A16-U160B
pullup(CH1208);
assign #GATE_DELAY CH1208 = rst ? 0 : ((0|RCH12_|g43157) ? 1'b0 : 1'bz);
// Gate A16-U217A
pullup(CH1209);
assign #GATE_DELAY CH1209 = rst ? 0 : ((0|RCH12_|g43333) ? 1'b0 : 1'bz);
// Gate A16-U207A
pullup(g43311);
assign #GATE_DELAY g43311 = rst ? 0 : ((0|RCH12_|g43313) ? 1'b0 : 1'bz);
// Gate A16-U121B
pullup(g43222);
assign #GATE_DELAY g43222 = rst ? 0 : ((0|RCH06_|g43220) ? 1'b0 : 1'bz);
// Gate A16-U145A
pullup(g43131);
assign #GATE_DELAY g43131 = rst ? 0 : ((0|CHWL06_|WCH05_) ? 1'b0 : 1'bz);
// Gate A16-U124A
pullup(g43213);
assign #GATE_DELAY g43213 = rst ? 0 : ((0|XT0_|XB6_) ? 1'b0 : 1'bz);
// Gate A16-U258B
pullup(g43360);
assign #GATE_DELAY g43360 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A16-U141A
pullup(g43122);
assign #GATE_DELAY g43122 = rst ? 0 : ((0|g43120|RCH05_) ? 1'b0 : 1'bz);
// Gate A16-U254B
pullup(g43349);
assign #GATE_DELAY g43349 = rst ? 0 : ((0|WCHG_|XT1_|XB2_) ? 1'b0 : 1'bz);
// Gate A16-U235A
pullup(g43411);
assign #GATE_DELAY g43411 = rst ? 0 : ((0|g43409|RCH11_) ? 1'b0 : 1'bz);
// Gate A16-U147B
pullup(RCmXmY);
assign #GATE_DELAY RCmXmY = rst ? 0 : ((0|g43132) ? 1'b0 : 1'bz);
// Gate A16-U221A
pullup(CH1211);
assign #GATE_DELAY CH1211 = rst ? 0 : ((0|RCH12_|g43343) ? 1'b0 : 1'bz);
// Gate A16-U207B
pullup(g43313);
assign #GATE_DELAY g43313 = rst ? 1'bz : ((0|g43315|g43314) ? 1'b0 : 1'bz);
// Gate A16-U151B
pullup(RCmXpY);
assign #GATE_DELAY RCmXpY = rst ? 0 : ((0|g43138) ? 1'b0 : 1'bz);
// Gate A16-U110B
pullup(g43243);
assign #GATE_DELAY g43243 = rst ? 0 : ((0|RCH06_|g43241) ? 1'b0 : 1'bz);
// Gate A16-U130A
pullup(g43203);
assign #GATE_DELAY g43203 = rst ? 0 : ((0|g43202|CCH06) ? 1'b0 : 1'bz);
// Gate A16-U129B
pullup(g43201);
assign #GATE_DELAY g43201 = rst ? 0 : ((0|WCH06_|CHWL08_) ? 1'b0 : 1'bz);
// Gate A16-U144B
pullup(g43127);
assign #GATE_DELAY g43127 = rst ? 0 : ((0|CCH05|g43126) ? 1'b0 : 1'bz);
// Gate A16-U120A
pullup(g43220);
assign #GATE_DELAY g43220 = rst ? 1'bz : ((0|g43219|g43221) ? 1'b0 : 1'bz);
// Gate A16-U224A
pullup(CH1212);
assign #GATE_DELAY CH1212 = rst ? 0 : ((0|RCH12_|g43447) ? 1'b0 : 1'bz);
// Gate A16-U113B
pullup(g43238);
assign #GATE_DELAY g43238 = rst ? 0 : ((0|RCH06_|g43236) ? 1'b0 : 1'bz);
// Gate A16-U143A
pullup(g43125);
assign #GATE_DELAY g43125 = rst ? 0 : ((0|CHWL05_|WCH05_) ? 1'b0 : 1'bz);
// Gate A16-U146B A16-U249A
pullup(CHOR06_);
assign #GATE_DELAY CHOR06_ = rst ? 1'bz : ((0|CH3206|g43233|g43134|g43329|CH0706|g43436) ? 1'b0 : 1'bz);
// Gate A16-U203A
pullup(g43306);
assign #GATE_DELAY g43306 = rst ? 0 : ((0|CHWL02_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U242B
pullup(g43422);
assign #GATE_DELAY g43422 = rst ? 0 : ((0|g43421|CCH11) ? 1'b0 : 1'bz);
// Gate A16-U143B
pullup(g43126);
assign #GATE_DELAY g43126 = rst ? 1'bz : ((0|g43127|g43125) ? 1'b0 : 1'bz);
// Gate A16-U157B
pullup(g43152);
assign #GATE_DELAY g43152 = rst ? 0 : ((0|XB5_|CCHG_|XT0_) ? 1'b0 : 1'bz);
// Gate A16-U141B
pullup(RCpXmP);
assign #GATE_DELAY RCpXmP = rst ? 0 : ((0|g43120) ? 1'b0 : 1'bz);
// Gate A16-U220A
pullup(CH1210);
assign #GATE_DELAY CH1210 = rst ? 0 : ((0|RCH12_|g43337) ? 1'b0 : 1'bz);
// Gate A16-U154A
pullup(g43144);
assign #GATE_DELAY g43144 = rst ? 1'bz : ((0|g43143|g43145) ? 1'b0 : 1'bz);
// Gate A16-U223A
pullup(g43446);
assign #GATE_DELAY g43446 = rst ? 0 : ((0|CHWL12_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U156B
pullup(g43153);
assign #GATE_DELAY g43153 = rst ? 0 : ((0|GOJAM|g43152) ? 1'b0 : 1'bz);
// Gate A16-U127A A16-U126A
pullup(CCH06);
assign #GATE_DELAY CCH06 = rst ? 1'bz : ((0|g43210) ? 1'b0 : 1'bz);
// Gate A16-U158A A16-U157A
pullup(CCH05);
assign #GATE_DELAY CCH05 = rst ? 1'bz : ((0|g43153) ? 1'b0 : 1'bz);
// Gate A16-U133A
pullup(g43107);
assign #GATE_DELAY g43107 = rst ? 0 : ((0|CHWL02_|WCH05_) ? 1'b0 : 1'bz);
// Gate A16-U153B
pullup(RCpXmY);
assign #GATE_DELAY RCpXmY = rst ? 0 : ((0|g43144) ? 1'b0 : 1'bz);
// Gate A16-U238A
pullup(g43414);
assign #GATE_DELAY g43414 = rst ? 0 : ((0|g43416|RCH11_) ? 1'b0 : 1'bz);
// Gate A16-U229B
pullup(g43457);
assign #GATE_DELAY g43457 = rst ? 1'bz : ((0|g43456|g43458) ? 1'b0 : 1'bz);
// Gate A16-U236A
pullup(g43409);
assign #GATE_DELAY g43409 = rst ? 1'bz : ((0|g43406|g43410) ? 1'b0 : 1'bz);
// Gate A16-U251A
pullup(g43442);
assign #GATE_DELAY g43442 = rst ? 0 : ((0|RCH11_|g43444) ? 1'b0 : 1'bz);
// Gate A16-U205A
pullup(ENEROP);
assign #GATE_DELAY ENEROP = rst ? 0 : ((0|g43307) ? 1'b0 : 1'bz);
// Gate A16-U219A
pullup(g43336);
assign #GATE_DELAY g43336 = rst ? 0 : ((0|CHWL10_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U226A
pullup(CH1213);
assign #GATE_DELAY CH1213 = rst ? 0 : ((0|RCH12_|g43454) ? 1'b0 : 1'bz);
// Gate A16-U158B
pullup(g43156);
assign #GATE_DELAY g43156 = rst ? 0 : ((0|CHWL08_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U211A
pullup(g43325);
assign #GATE_DELAY g43325 = rst ? 0 : ((0|CHWL05_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U225B
pullup(g43448);
assign #GATE_DELAY g43448 = rst ? 0 : ((0|g43447|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U123A
pullup(g43216);
assign #GATE_DELAY g43216 = rst ? 0 : ((0|XB5_|XT0_) ? 1'b0 : 1'bz);
// Gate A16-U244B
pullup(g43430);
assign #GATE_DELAY g43430 = rst ? 1'bz : ((0|g43429|g43431) ? 1'b0 : 1'bz);
// Gate A16-U214B
pullup(g43327);
assign #GATE_DELAY g43327 = rst ? 1'bz : ((0|g43326|g43328) ? 1'b0 : 1'bz);
// Gate A16-U224B
pullup(g43447);
assign #GATE_DELAY g43447 = rst ? 1'bz : ((0|g43446|g43448) ? 1'b0 : 1'bz);
// Gate A16-U228A
pullup(g43456);
assign #GATE_DELAY g43456 = rst ? 0 : ((0|CHWL14_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U146A A16-U245B
pullup(CHOR05_);
assign #GATE_DELAY CHOR05_ = rst ? 1'bz : ((0|g43128|g43238|CH3205|CH0705|g43321|g43428) ? 1'b0 : 1'bz);
// Gate A16-U219B
pullup(g43337);
assign #GATE_DELAY g43337 = rst ? 1'bz : ((0|g43338|g43336) ? 1'b0 : 1'bz);
// Gate A16-U119B
pullup(RCmYpR);
assign #GATE_DELAY RCmYpR = rst ? 0 : ((0|g43220) ? 1'b0 : 1'bz);
// Gate A16-U239B
pullup(UPLACT);
assign #GATE_DELAY UPLACT = rst ? 0 : ((0|g43416) ? 1'b0 : 1'bz);
// Gate A16-U148B
pullup(g43133);
assign #GATE_DELAY g43133 = rst ? 0 : ((0|CCH05|g43132) ? 1'b0 : 1'bz);
// Gate A16-U144A
pullup(g43128);
assign #GATE_DELAY g43128 = rst ? 0 : ((0|g43126|RCH05_) ? 1'b0 : 1'bz);
// Gate A16-U244A
pullup(g43431);
assign #GATE_DELAY g43431 = rst ? 0 : ((0|CHWL05_|WCH11_) ? 1'b0 : 1'bz);
// Gate A16-U107B
pullup(g43245);
assign #GATE_DELAY g43245 = rst ? 0 : ((0|WCH06_|CHWL03_) ? 1'b0 : 1'bz);
// Gate A16-U120B
pullup(g43219);
assign #GATE_DELAY g43219 = rst ? 0 : ((0|CHWL07_|WCH06_) ? 1'b0 : 1'bz);
// Gate A16-U233A
pullup(g43406);
assign #GATE_DELAY g43406 = rst ? 0 : ((0|CHWL02_|WCH11_) ? 1'b0 : 1'bz);
// Gate A16-U142A
pullup(g43120);
assign #GATE_DELAY g43120 = rst ? 1'bz : ((0|g43119|g43121) ? 1'b0 : 1'bz);
// Gate A16-U218A
pullup(g43335);
assign #GATE_DELAY g43335 = rst ? 0 : ((0|CHWL09_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U105B
pullup(g43253);
assign #GATE_DELAY g43253 = rst ? 0 : ((0|RCH06_|g43251) ? 1'b0 : 1'bz);
// Gate A16-U112B
pullup(g43235);
assign #GATE_DELAY g43235 = rst ? 0 : ((0|WCH06_|CHWL05_) ? 1'b0 : 1'bz);
// Gate A16-U113A
pullup(g43237);
assign #GATE_DELAY g43237 = rst ? 0 : ((0|g43236|CCH06) ? 1'b0 : 1'bz);
// Gate A16-U128A
pullup(g43206);
assign #GATE_DELAY g43206 = rst ? 0 : ((0|XT0_|WCHG_|XB6_) ? 1'b0 : 1'bz);
// Gate A16-U160A
pullup(TVCNAB);
assign #GATE_DELAY TVCNAB = rst ? 0 : ((0|g43157) ? 1'b0 : 1'bz);
// Gate A16-U211B
pullup(ZIMCDU);
assign #GATE_DELAY ZIMCDU = rst ? 0 : ((0|g43323) ? 1'b0 : 1'bz);
// Gate A16-U215A
pullup(g43329);
assign #GATE_DELAY g43329 = rst ? 0 : ((0|RCH12_|g43327) ? 1'b0 : 1'bz);
// Gate A16-U148A
pullup(g43132);
assign #GATE_DELAY g43132 = rst ? 1'bz : ((0|g43131|g43133) ? 1'b0 : 1'bz);
// Gate A16-U241B
pullup(TMPOUT);
assign #GATE_DELAY TMPOUT = rst ? 0 : ((0|g43421) ? 1'b0 : 1'bz);
// Gate A16-U125B
pullup(g43209);
assign #GATE_DELAY g43209 = rst ? 0 : ((0|CCHG_|XT0_|XB6_) ? 1'b0 : 1'bz);
// Gate A16-U125A
pullup(g43210);
assign #GATE_DELAY g43210 = rst ? 0 : ((0|g43209|GOJAM) ? 1'b0 : 1'bz);
// Gate A16-U223B
pullup(g43344);
assign #GATE_DELAY g43344 = rst ? 0 : ((0|g43343|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U140A A16-U240A
pullup(CHOR04_);
assign #GATE_DELAY CHOR04_ = rst ? 1'bz : ((0|CH3204|g43122|g43243|g43319|g43423|CH1504) ? 1'b0 : 1'bz);
// Gate A16-U203B
pullup(g43304);
assign #GATE_DELAY g43304 = rst ? 0 : ((0|g43303|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U213A
pullup(ENERIM);
assign #GATE_DELAY ENERIM = rst ? 0 : ((0|g43327) ? 1'b0 : 1'bz);
// Gate A16-U132A
pullup(g43104);
assign #GATE_DELAY g43104 = rst ? 0 : ((0|g43102|RCH05_) ? 1'b0 : 1'bz);
// Gate A16-U128B
pullup(RCpYmR);
assign #GATE_DELAY RCpYmR = rst ? 0 : ((0|g43202) ? 1'b0 : 1'bz);
// Gate A16-U246A
pullup(g43432);
assign #GATE_DELAY g43432 = rst ? 0 : ((0|CHWL06_|WCH11_) ? 1'b0 : 1'bz);
// Gate A16-U239A
pullup(g43418);
assign #GATE_DELAY g43418 = rst ? 0 : ((0|CHWL04_|WCH11_) ? 1'b0 : 1'bz);
// Gate A16-U139A
pullup(g43119);
assign #GATE_DELAY g43119 = rst ? 0 : ((0|CHWL04_|WCH05_) ? 1'b0 : 1'bz);
// Gate A16-U245A A16-U246B
pullup(KYRLS);
assign #GATE_DELAY KYRLS = rst ? 0 : ((0|FLASH|g43430) ? 1'b0 : 1'bz);
// Gate A16-U150B
pullup(g43139);
assign #GATE_DELAY g43139 = rst ? 0 : ((0|CCH05|g43138) ? 1'b0 : 1'bz);
// Gate A16-U149A
pullup(g43137);
assign #GATE_DELAY g43137 = rst ? 0 : ((0|CHWL07_|WCH05_) ? 1'b0 : 1'bz);
// Gate A16-U242A
pullup(g43421);
assign #GATE_DELAY g43421 = rst ? 1'bz : ((0|g43418|g43422) ? 1'b0 : 1'bz);
// Gate A16-U118B
pullup(g43226);
assign #GATE_DELAY g43226 = rst ? 0 : ((0|g43225|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U149B
pullup(g43138);
assign #GATE_DELAY g43138 = rst ? 1'bz : ((0|g43139|g43137) ? 1'b0 : 1'bz);
// Gate A16-U117A
pullup(OT1207);
assign #GATE_DELAY OT1207 = rst ? 0 : ((0|g43225) ? 1'b0 : 1'bz);
// Gate A16-U109A
pullup(g43241);
assign #GATE_DELAY g43241 = rst ? 1'bz : ((0|g43240|g43242) ? 1'b0 : 1'bz);
// Gate A16-U109B
pullup(g43240);
assign #GATE_DELAY g43240 = rst ? 0 : ((0|WCH06_|CHWL04_) ? 1'b0 : 1'bz);
// Gate A16-U135B
pullup(RCmXmP);
assign #GATE_DELAY RCmXmP = rst ? 0 : ((0|g43108) ? 1'b0 : 1'bz);
// Gate A16-U104A
pullup(g43251);
assign #GATE_DELAY g43251 = rst ? 1'bz : ((0|g43250|g43252) ? 1'b0 : 1'bz);
// Gate A16-U105A
pullup(g43252);
assign #GATE_DELAY g43252 = rst ? 0 : ((0|g43251|CCH06) ? 1'b0 : 1'bz);
// Gate A16-U104B
pullup(g43250);
assign #GATE_DELAY g43250 = rst ? 0 : ((0|WCH06_|CHWL02_) ? 1'b0 : 1'bz);
// Gate A16-U115B
pullup(g43233);
assign #GATE_DELAY g43233 = rst ? 0 : ((0|RCH06_|g43231) ? 1'b0 : 1'bz);
// Gate A16-U129A
pullup(g43202);
assign #GATE_DELAY g43202 = rst ? 1'bz : ((0|g43203|g43201) ? 1'b0 : 1'bz);
// Gate A16-U118A
pullup(g43225);
assign #GATE_DELAY g43225 = rst ? 1'bz : ((0|g43224|g43226) ? 1'b0 : 1'bz);
// Gate A16-U150A
pullup(g43140);
assign #GATE_DELAY g43140 = rst ? 0 : ((0|g43138|RCH05_) ? 1'b0 : 1'bz);
// Gate A16-U201B
pullup(ZOPCDU);
assign #GATE_DELAY ZOPCDU = rst ? 0 : ((0|g43303) ? 1'b0 : 1'bz);
// Gate A16-U103A
pullup(g43257);
assign #GATE_DELAY g43257 = rst ? 0 : ((0|g43256|CCH06) ? 1'b0 : 1'bz);
// Gate A16-U102B
pullup(g43255);
assign #GATE_DELAY g43255 = rst ? 0 : ((0|WCH06_|CHWL01_) ? 1'b0 : 1'bz);
// Gate A16-U119A
pullup(g43224);
assign #GATE_DELAY g43224 = rst ? 0 : ((0|WCH12_|CHWL07_) ? 1'b0 : 1'bz);
// Gate A16-U243A
pullup(g43428);
assign #GATE_DELAY g43428 = rst ? 0 : ((0|g43430|RCH11_) ? 1'b0 : 1'bz);
// Gate A16-U140B A16-U240B
pullup(CHOR03_);
assign #GATE_DELAY CHOR03_ = rst ? 1'bz : ((0|g43116|g43248|CH3203|g43414|g43311|CH1503) ? 1'b0 : 1'bz);
// Gate A16-U225A
pullup(MROLGT);
assign #GATE_DELAY MROLGT = rst ? 0 : ((0|g43447) ? 1'b0 : 1'bz);
// Gate A16-U243B
pullup(g43429);
assign #GATE_DELAY g43429 = rst ? 0 : ((0|g43430|CCH11) ? 1'b0 : 1'bz);
// Gate A16-U222A
pullup(g43345);
assign #GATE_DELAY g43345 = rst ? 0 : ((0|CHWL11_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U250A
pullup(g43445);
assign #GATE_DELAY g43445 = rst ? 0 : ((0|WCH11_|CHWL07_) ? 1'b0 : 1'bz);
// Gate A16-U107A
pullup(g43246);
assign #GATE_DELAY g43246 = rst ? 1'bz : ((0|g43245|g43247) ? 1'b0 : 1'bz);
// Gate A16-U111A
pullup(RCpYpR);
assign #GATE_DELAY RCpYpR = rst ? 0 : ((0|g43236) ? 1'b0 : 1'bz);
// Gate A16-U145B
pullup(RCpXpY);
assign #GATE_DELAY RCpXpY = rst ? 0 : ((0|g43126) ? 1'b0 : 1'bz);
// Gate A16-U227B
pullup(g43454);
assign #GATE_DELAY g43454 = rst ? 1'bz : ((0|g43455|g43453) ? 1'b0 : 1'bz);
// Gate A16-U249B A16-U248B
pullup(VNFLSH);
assign #GATE_DELAY VNFLSH = rst ? 0 : ((0|FLASH_|g43434) ? 1'b0 : 1'bz);
// Gate A16-U101B
pullup(g43260);
assign #GATE_DELAY g43260 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A16-U133B
pullup(RCpXpP);
assign #GATE_DELAY RCpXpP = rst ? 0 : ((0|g43102) ? 1'b0 : 1'bz);
// Gate A16-U112A
pullup(g43236);
assign #GATE_DELAY g43236 = rst ? 1'bz : ((0|g43235|g43237) ? 1'b0 : 1'bz);
// Gate A16-U233B
pullup(ISSWAR);
assign #GATE_DELAY ISSWAR = rst ? 0 : ((0|g43404) ? 1'b0 : 1'bz);
// Gate A16-U251B
pullup(g43443);
assign #GATE_DELAY g43443 = rst ? 0 : ((0|g43444|CCH11) ? 1'b0 : 1'bz);
// Gate A16-U260A
pullup(g43355);
assign #GATE_DELAY g43355 = rst ? 0 : ((0|XT1_|XB2_) ? 1'b0 : 1'bz);
// Gate A16-U131A
pullup(g43102);
assign #GATE_DELAY g43102 = rst ? 1'bz : ((0|g43103|g43101) ? 1'b0 : 1'bz);
// Gate A16-U131B
pullup(g43101);
assign #GATE_DELAY g43101 = rst ? 0 : ((0|CHWL01_|WCH05_) ? 1'b0 : 1'bz);
// Gate A16-U132B
pullup(g43103);
assign #GATE_DELAY g43103 = rst ? 0 : ((0|CCH05|g43102) ? 1'b0 : 1'bz);
// Gate A16-U101A
pullup(RCpZpR);
assign #GATE_DELAY RCpZpR = rst ? 0 : ((0|g43256) ? 1'b0 : 1'bz);
// Gate A16-U204B
pullup(g43307);
assign #GATE_DELAY g43307 = rst ? 1'bz : ((0|g43306|g43308) ? 1'b0 : 1'bz);
// Gate A16-U204A
pullup(g43309);
assign #GATE_DELAY g43309 = rst ? 0 : ((0|RCH12_|g43307) ? 1'b0 : 1'bz);
// Gate A16-U212A
pullup(g43321);
assign #GATE_DELAY g43321 = rst ? 0 : ((0|RCH12_|g43323) ? 1'b0 : 1'bz);
// Gate A16-U137A
pullup(g43113);
assign #GATE_DELAY g43113 = rst ? 0 : ((0|CHWL03_|WCH05_) ? 1'b0 : 1'bz);
// Gate A16-U134B A16-U234A
pullup(CHOR02_);
assign #GATE_DELAY CHOR02_ = rst ? 1'bz : ((0|CH3202|g43253|g43110|CH1502|g43309|g43411) ? 1'b0 : 1'bz);
// Gate A16-U138B
pullup(g43115);
assign #GATE_DELAY g43115 = rst ? 0 : ((0|CCH05|g43114) ? 1'b0 : 1'bz);
// Gate A16-U221B
pullup(DISDAC);
assign #GATE_DELAY DISDAC = rst ? 0 : ((0|g43343) ? 1'b0 : 1'bz);
// Gate A16-U103B
pullup(g43258);
assign #GATE_DELAY g43258 = rst ? 0 : ((0|RCH06_|g43256) ? 1'b0 : 1'bz);
// Gate A16-U137B
pullup(g43114);
assign #GATE_DELAY g43114 = rst ? 1'bz : ((0|g43115|g43113) ? 1'b0 : 1'bz);
// Gate A16-U202B
pullup(g43303);
assign #GATE_DELAY g43303 = rst ? 1'bz : ((0|g43305|g43304) ? 1'b0 : 1'bz);
// Gate A16-U256A A16-U257A A16-U257B
pullup(CCH12);
assign #GATE_DELAY CCH12 = rst ? 1'bz : ((0|g43351) ? 1'b0 : 1'bz);
// Gate A16-U215B
pullup(g43328);
assign #GATE_DELAY g43328 = rst ? 0 : ((0|g43327|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U231A
pullup(g43405);
assign #GATE_DELAY g43405 = rst ? 0 : ((0|CHWL01_|WCH11_) ? 1'b0 : 1'bz);
// Gate A16-U232B
pullup(g43403);
assign #GATE_DELAY g43403 = rst ? 0 : ((0|g43404|CCH11) ? 1'b0 : 1'bz);
// Gate A16-U206B
pullup(STARON);
assign #GATE_DELAY STARON = rst ? 0 : ((0|g43313) ? 1'b0 : 1'bz);
// Gate A16-U106A
pullup(RCmZpR);
assign #GATE_DELAY RCmZpR = rst ? 0 : ((0|g43246) ? 1'b0 : 1'bz);
// Gate A16-U231B
pullup(g43404);
assign #GATE_DELAY g43404 = rst ? 1'bz : ((0|g43403|g43405) ? 1'b0 : 1'bz);
// Gate A16-U122A A16-U122B
pullup(RCH05_);
assign #GATE_DELAY RCH05_ = rst ? 1'bz : ((0|g43216) ? 1'b0 : 1'bz);
// Gate A16-U229A
pullup(S4BOFF);
assign #GATE_DELAY S4BOFF = rst ? 0 : ((0|g43457) ? 1'b0 : 1'bz);
// Gate A16-U136A
pullup(g43108);
assign #GATE_DELAY g43108 = rst ? 1'bz : ((0|g43107|g43109) ? 1'b0 : 1'bz);
// Gate A16-U210A
pullup(COARSE);
assign #GATE_DELAY COARSE = rst ? 0 : ((0|g43317) ? 1'b0 : 1'bz);
// Gate A16-U227A
pullup(g43455);
assign #GATE_DELAY g43455 = rst ? 0 : ((0|CHWL13_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U142B
pullup(g43121);
assign #GATE_DELAY g43121 = rst ? 0 : ((0|CCH05|g43120) ? 1'b0 : 1'bz);
// Gate A16-U127B A16-U126B
pullup(WCH06_);
assign #GATE_DELAY WCH06_ = rst ? 1'bz : ((0|g43206) ? 1'b0 : 1'bz);
// Gate A16-U228B
pullup(g43453);
assign #GATE_DELAY g43453 = rst ? 0 : ((0|g43454|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U202A
pullup(g43301);
assign #GATE_DELAY g43301 = rst ? 0 : ((0|RCH12_|g43303) ? 1'b0 : 1'bz);
// Gate A16-U114B
pullup(g43230);
assign #GATE_DELAY g43230 = rst ? 0 : ((0|WCH06_|CHWL06_) ? 1'b0 : 1'bz);
// Gate A16-U115A
pullup(g43232);
assign #GATE_DELAY g43232 = rst ? 0 : ((0|g43231|CCH06) ? 1'b0 : 1'bz);
// Gate A16-U114A
pullup(g43231);
assign #GATE_DELAY g43231 = rst ? 1'bz : ((0|g43230|g43232) ? 1'b0 : 1'bz);
// Gate A16-U134A A16-U234B
pullup(CHOR01_);
assign #GATE_DELAY CHOR01_ = rst ? 1'bz : ((0|g43258|CH3201|g43104|g43402|g43301|CH1501) ? 1'b0 : 1'bz);
// Gate A16-U209B
pullup(g43317);
assign #GATE_DELAY g43317 = rst ? 1'bz : ((0|g43316|g43318) ? 1'b0 : 1'bz);
// Gate A16-U136B
pullup(g43109);
assign #GATE_DELAY g43109 = rst ? 0 : ((0|CCH05|g43108) ? 1'b0 : 1'bz);
// Gate A16-U209A
pullup(g43319);
assign #GATE_DELAY g43319 = rst ? 0 : ((0|RCH12_|g43317) ? 1'b0 : 1'bz);
// Gate A16-U116A
pullup(RCmYmR);
assign #GATE_DELAY RCmYmR = rst ? 0 : ((0|g43231) ? 1'b0 : 1'bz);
// Gate A16-U235B
pullup(COMACT);
assign #GATE_DELAY COMACT = rst ? 0 : ((0|g43409) ? 1'b0 : 1'bz);
// Gate A16-U216B
pullup(g43334);
assign #GATE_DELAY g43334 = rst ? 0 : ((0|g43333|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U206A
pullup(g43315);
assign #GATE_DELAY g43315 = rst ? 0 : ((0|CHWL03_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U210B
pullup(g43318);
assign #GATE_DELAY g43318 = rst ? 0 : ((0|g43317|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U216A
pullup(g43333);
assign #GATE_DELAY g43333 = rst ? 1'bz : ((0|g43335|g43334) ? 1'b0 : 1'bz);
// Gate A16-U256B
pullup(g43351);
assign #GATE_DELAY g43351 = rst ? 0 : ((0|g43350|GOJAM) ? 1'b0 : 1'bz);
// Gate A16-U220B
pullup(ZEROPT);
assign #GATE_DELAY ZEROPT = rst ? 0 : ((0|g43337) ? 1'b0 : 1'bz);
// Gate A16-U213B
pullup(g43324);
assign #GATE_DELAY g43324 = rst ? 0 : ((0|g43323|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U205B
pullup(g43308);
assign #GATE_DELAY g43308 = rst ? 0 : ((0|g43307|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U217B
pullup(S4BTAK);
assign #GATE_DELAY S4BTAK = rst ? 0 : ((0|g43333) ? 1'b0 : 1'bz);
// Gate A16-U248A
pullup(g43436);
assign #GATE_DELAY g43436 = rst ? 0 : ((0|g43434|RCH11_) ? 1'b0 : 1'bz);
// Gate A16-U241A
pullup(g43423);
assign #GATE_DELAY g43423 = rst ? 0 : ((0|g43421|RCH11_) ? 1'b0 : 1'bz);
// Gate A16-U156A A16-U155A
pullup(WCH05_);
assign #GATE_DELAY WCH05_ = rst ? 1'bz : ((0|g43151) ? 1'b0 : 1'bz);
// Gate A16-U212B
pullup(g43323);
assign #GATE_DELAY g43323 = rst ? 1'bz : ((0|g43325|g43324) ? 1'b0 : 1'bz);
// Gate A16-U254A A16-U255A A16-U253B
pullup(WCH12_);
assign #GATE_DELAY WCH12_ = rst ? 1'bz : ((0|g43349) ? 1'b0 : 1'bz);
// Gate A16-U222B
pullup(g43343);
assign #GATE_DELAY g43343 = rst ? 1'bz : ((0|g43344|g43345) ? 1'b0 : 1'bz);
// Gate A16-U232A
pullup(g43402);
assign #GATE_DELAY g43402 = rst ? 0 : ((0|g43404|RCH11_) ? 1'b0 : 1'bz);
// Gate A16-U151A
pullup(g43143);
assign #GATE_DELAY g43143 = rst ? 0 : ((0|CHWL08_|WCH05_) ? 1'b0 : 1'bz);
// Gate A16-U237B
pullup(g43416);
assign #GATE_DELAY g43416 = rst ? 1'bz : ((0|g43415|g43417) ? 1'b0 : 1'bz);
// Gate A16-U238B
pullup(g43415);
assign #GATE_DELAY g43415 = rst ? 0 : ((0|g43416|CCH11) ? 1'b0 : 1'bz);
// Gate A16-U153A
pullup(g43146);
assign #GATE_DELAY g43146 = rst ? 0 : ((0|RCH05_|g43144) ? 1'b0 : 1'bz);
// Gate A16-U237A
pullup(g43417);
assign #GATE_DELAY g43417 = rst ? 0 : ((0|CHWL03_|WCH11_) ? 1'b0 : 1'bz);
// Gate A16-U218B
pullup(g43338);
assign #GATE_DELAY g43338 = rst ? 0 : ((0|g43337|CCH12) ? 1'b0 : 1'bz);
// Gate A16-U108B
pullup(g43248);
assign #GATE_DELAY g43248 = rst ? 0 : ((0|RCH06_|g43246) ? 1'b0 : 1'bz);
// Gate A16-U208A
pullup(g43316);
assign #GATE_DELAY g43316 = rst ? 0 : ((0|CHWL04_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U236B
pullup(g43410);
assign #GATE_DELAY g43410 = rst ? 0 : ((0|g43409|CCH11) ? 1'b0 : 1'bz);
// Gate A16-U260B
pullup(g43359);
assign #GATE_DELAY g43359 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A16-U121A
pullup(g43221);
assign #GATE_DELAY g43221 = rst ? 0 : ((0|g43220|CCH06) ? 1'b0 : 1'bz);
// Gate A16-U102A
pullup(g43256);
assign #GATE_DELAY g43256 = rst ? 1'bz : ((0|g43255|g43257) ? 1'b0 : 1'bz);
// Gate A16-U252A A16-U253A
pullup(OPEROR);
assign #GATE_DELAY OPEROR = rst ? 0 : ((0|FLASH|g43444) ? 1'b0 : 1'bz);
// Gate A16-U108A
pullup(g43247);
assign #GATE_DELAY g43247 = rst ? 0 : ((0|g43246|CCH06) ? 1'b0 : 1'bz);
// Gate A16-U214A
pullup(g43326);
assign #GATE_DELAY g43326 = rst ? 0 : ((0|CHWL06_|WCH12_) ? 1'b0 : 1'bz);
// Gate A16-U250B
pullup(g43444);
assign #GATE_DELAY g43444 = rst ? 1'bz : ((0|g43445|g43443) ? 1'b0 : 1'bz);
// Gate A16-U230A
pullup(CH1214);
assign #GATE_DELAY CH1214 = rst ? 0 : ((0|RCH12_|g43457) ? 1'b0 : 1'bz);
// Gate A16-U116B
pullup(OT1207_);
assign #GATE_DELAY OT1207_ = rst ? 1'bz : ((0|g43226) ? 1'b0 : 1'bz);
// Gate A16-U111B
pullup(RCpZmR);
assign #GATE_DELAY RCpZmR = rst ? 0 : ((0|g43241) ? 1'b0 : 1'bz);
// Gate A16-U152A
pullup(CHOR08_);
assign #GATE_DELAY CHOR08_ = rst ? 1'bz : ((0|CH3208|g43204|g43146) ? 1'b0 : 1'bz);
// Gate A16-U258A A16-U259A A16-U259B
pullup(RCH12_);
assign #GATE_DELAY RCH12_ = rst ? 1'bz : ((0|g43355) ? 1'b0 : 1'bz);
// Gate A16-U130B
pullup(g43204);
assign #GATE_DELAY g43204 = rst ? 0 : ((0|RCH06_|g43202) ? 1'b0 : 1'bz);
// Gate A16-U155B
pullup(g43151);
assign #GATE_DELAY g43151 = rst ? 0 : ((0|XB5_|XT0_|WCHG_) ? 1'b0 : 1'bz);
// End of NOR gates


endmodule
