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

input wand rst, CCH11, CCHG_, CGA16, CH0705, CH0706, CH0707, CH1501, CH1502,
  CH1503, CH1504, CH3201, CH3202, CH3203, CH3204, CH3205, CH3206, CH3207,
  CH3208, CHWL01_, CHWL02_, CHWL03_, CHWL04_, CHWL05_, CHWL06_, CHWL07_,
  CHWL08_, CHWL09_, CHWL10_, CHWL11_, CHWL12_, CHWL13_, CHWL14_, FLASH, FLASH_,
  GOJAM, RCH11_, WCH11_, WCHG_, XB2_, XB5_, XB6_, XT0_, XT1_;

inout wand CCH12, CH1207, CHOR01_, CHOR02_, CHOR03_, CHOR04_, CHOR05_, CHOR06_,
  CHOR07_, CHOR08_, RCH12_, WCH12_;

output wand CCH05, CCH06, CH1208, CH1209, CH1210, CH1211, CH1212, CH1213,
  CH1214, COARSE, COMACT, DISDAC, ENERIM, ENEROP, ISSWAR, KYRLS, MROLGT,
  OPEROR, OT1207, OT1207_, RCH05_, RCH06_, RCmXmP, RCmXmY, RCmXpP, RCmXpY,
  RCmYmR, RCmYpR, RCmZmR, RCmZpR, RCpXmP, RCpXmY, RCpXpP, RCpXpY, RCpYmR,
  RCpYpR, RCpZmR, RCpZpR, S4BOFF, S4BSEQ, S4BTAK, STARON, TMPOUT, TVCNAB,
  UPLACT, VNFLSH, WCH05_, WCH06_, ZEROPT, ZIMCDU, ZOPCDU;

// Gate A16-U247A
assign #0.2  g43434 = rst ? 1 : ~(0|g43433|g43432);
// Gate A16-U247B
assign #0.2  g43433 = rst ? 0 : ~(0|g43434|CCH11);
// Gate A16-U138A
assign #0.2  g43116 = rst ? 0 : ~(0|RCH05_|g43114);
// Gate A16-U159B
assign #0.2  g43158 = rst ? 0 : ~(0|g43157|CCH12);
// Gate A16-U147A
assign #0.2  g43134 = rst ? 0 : ~(0|g43132|RCH05_);
// Gate A16-U159A
assign #0.2  g43157 = rst ? 1 : ~(0|g43158|g43156);
// Gate A16-U106B
assign #0.2  RCmZmR = rst ? 0 : ~(0|g43251);
// Gate A16-U135A
assign #0.2  g43110 = rst ? 0 : ~(0|RCH05_|g43108);
// Gate A16-U110A
assign #0.2  g43242 = rst ? 0 : ~(0|CCH06|g43241);
// Gate A16-U154B
assign #0.2  g43145 = rst ? 0 : ~(0|CCH05|g43144);
// Gate A16-U139B
assign #0.2  RCmXpP = rst ? 0 : ~(0|g43114);
// Gate A16-U226B
assign #0.2  S4BSEQ = rst ? 0 : ~(0|g43454);
// Gate A16-U152B A16-U252B
assign #0.2  CHOR07_ = rst ? 1 : ~(0|g43140|g43222|CH3207|g43442|CH1207|CH0707);
// Gate A16-U255B
assign #0.2  g43350 = rst ? 0 : ~(0|CCHG_|XT1_|XB2_);
// Gate A16-U230B
assign #0.2  g43458 = rst ? 0 : ~(0|g43457|CCH12);
// Gate A16-U123B A16-U124B
assign #0.2  RCH06_ = rst ? 1 : ~(0|g43213);
// Gate A16-U201A
assign #0.2  g43305 = rst ? 0 : ~(0|WCH12_|CHWL01_);
// Gate A16-U208B
assign #0.2  g43314 = rst ? 0 : ~(0|g43313|CCH12);
// Gate A16-U117B
assign #0.2  CH1207 = rst ? 0 : ~(0|RCH12_|g43225);
// Gate A16-U160B
assign #0.2  CH1208 = rst ? 0 : ~(0|RCH12_|g43157);
// Gate A16-U217A
assign #0.2  CH1209 = rst ? 0 : ~(0|g43333|RCH12_);
// Gate A16-U207A
assign #0.2  g43311 = rst ? 0 : ~(0|g43313|RCH12_);
// Gate A16-U121B
assign #0.2  g43222 = rst ? 0 : ~(0|RCH06_|g43220);
// Gate A16-U145A
assign #0.2  g43131 = rst ? 0 : ~(0|WCH05_|CHWL06_);
// Gate A16-U124A
assign #0.2  g43213 = rst ? 0 : ~(0|XB6_|XT0_);
// Gate A16-U258B
assign #0.2  g43360 = rst ? 1 : ~(0);
// Gate A16-U141A
assign #0.2  g43122 = rst ? 0 : ~(0|RCH05_|g43120);
// Gate A16-U254B
assign #0.2  g43349 = rst ? 0 : ~(0|WCHG_|XT1_|XB2_);
// Gate A16-U235A
assign #0.2  g43411 = rst ? 0 : ~(0|RCH11_|g43409);
// Gate A16-U147B
assign #0.2  RCmXmY = rst ? 0 : ~(0|g43132);
// Gate A16-U221A
assign #0.2  CH1211 = rst ? 0 : ~(0|g43343|RCH12_);
// Gate A16-U207B
assign #0.2  g43313 = rst ? 1 : ~(0|g43315|g43314);
// Gate A16-U151B
assign #0.2  RCmXpY = rst ? 0 : ~(0|g43138);
// Gate A16-U110B
assign #0.2  g43243 = rst ? 0 : ~(0|RCH06_|g43241);
// Gate A16-U130A
assign #0.2  g43203 = rst ? 0 : ~(0|CCH06|g43202);
// Gate A16-U129B
assign #0.2  g43201 = rst ? 0 : ~(0|WCH06_|CHWL08_);
// Gate A16-U144B
assign #0.2  g43127 = rst ? 0 : ~(0|CCH05|g43126);
// Gate A16-U120A
assign #0.2  g43220 = rst ? 1 : ~(0|g43221|g43219);
// Gate A16-U224A
assign #0.2  CH1212 = rst ? 0 : ~(0|g43447|RCH12_);
// Gate A16-U113B
assign #0.2  g43238 = rst ? 0 : ~(0|RCH06_|g43236);
// Gate A16-U143A
assign #0.2  g43125 = rst ? 0 : ~(0|WCH05_|CHWL05_);
// Gate A16-U146B A16-U249A
assign #0.2  CHOR06_ = rst ? 1 : ~(0|CH3206|g43233|g43134|g43436|CH0706|g43329);
// Gate A16-U203A
assign #0.2  g43306 = rst ? 0 : ~(0|WCH12_|CHWL02_);
// Gate A16-U242B
assign #0.2  g43422 = rst ? 0 : ~(0|g43421|CCH11);
// Gate A16-U143B
assign #0.2  g43126 = rst ? 1 : ~(0|g43127|g43125);
// Gate A16-U157B
assign #0.2  g43152 = rst ? 0 : ~(0|XB5_|CCHG_|XT0_);
// Gate A16-U141B
assign #0.2  RCpXmP = rst ? 0 : ~(0|g43120);
// Gate A16-U220A
assign #0.2  CH1210 = rst ? 0 : ~(0|g43337|RCH12_);
// Gate A16-U154A
assign #0.2  g43144 = rst ? 1 : ~(0|g43145|g43143);
// Gate A16-U223A
assign #0.2  g43446 = rst ? 0 : ~(0|WCH12_|CHWL12_);
// Gate A16-U156B
assign #0.2  g43153 = rst ? 0 : ~(0|GOJAM|g43152);
// Gate A16-U127A A16-U126A
assign #0.2  CCH06 = rst ? 1 : ~(0|g43210);
// Gate A16-U158A A16-U157A
assign #0.2  CCH05 = rst ? 1 : ~(0|g43153);
// Gate A16-U133A
assign #0.2  g43107 = rst ? 0 : ~(0|WCH05_|CHWL02_);
// Gate A16-U153B
assign #0.2  RCpXmY = rst ? 0 : ~(0|g43144);
// Gate A16-U238A
assign #0.2  g43414 = rst ? 0 : ~(0|RCH11_|g43416);
// Gate A16-U229B
assign #0.2  g43457 = rst ? 1 : ~(0|g43456|g43458);
// Gate A16-U236A
assign #0.2  g43409 = rst ? 1 : ~(0|g43410|g43406);
// Gate A16-U251A
assign #0.2  g43442 = rst ? 0 : ~(0|g43444|RCH11_);
// Gate A16-U205A
assign #0.2  ENEROP = rst ? 0 : ~(0|g43307);
// Gate A16-U219A
assign #0.2  g43336 = rst ? 0 : ~(0|WCH12_|CHWL10_);
// Gate A16-U226A
assign #0.2  CH1213 = rst ? 0 : ~(0|g43454|RCH12_);
// Gate A16-U158B
assign #0.2  g43156 = rst ? 0 : ~(0|CHWL08_|WCH12_);
// Gate A16-U211A
assign #0.2  g43325 = rst ? 0 : ~(0|WCH12_|CHWL05_);
// Gate A16-U225B
assign #0.2  g43448 = rst ? 0 : ~(0|g43447|CCH12);
// Gate A16-U123A
assign #0.2  g43216 = rst ? 0 : ~(0|XT0_|XB5_);
// Gate A16-U244B
assign #0.2  g43430 = rst ? 1 : ~(0|g43429|g43431);
// Gate A16-U214B
assign #0.2  g43327 = rst ? 1 : ~(0|g43326|g43328);
// Gate A16-U224B
assign #0.2  g43447 = rst ? 1 : ~(0|g43446|g43448);
// Gate A16-U228A
assign #0.2  g43456 = rst ? 0 : ~(0|WCH12_|CHWL14_);
// Gate A16-U146A A16-U245B
assign #0.2  CHOR05_ = rst ? 1 : ~(0|CH3205|g43238|g43128|CH0705|g43321|g43428);
// Gate A16-U219B
assign #0.2  g43337 = rst ? 1 : ~(0|g43338|g43336);
// Gate A16-U119B
assign #0.2  RCmYpR = rst ? 0 : ~(0|g43220);
// Gate A16-U239B
assign #0.2  UPLACT = rst ? 0 : ~(0|g43416);
// Gate A16-U148B
assign #0.2  g43133 = rst ? 0 : ~(0|CCH05|g43132);
// Gate A16-U144A
assign #0.2  g43128 = rst ? 0 : ~(0|RCH05_|g43126);
// Gate A16-U244A
assign #0.2  g43431 = rst ? 0 : ~(0|WCH11_|CHWL05_);
// Gate A16-U107B
assign #0.2  g43245 = rst ? 0 : ~(0|WCH06_|CHWL03_);
// Gate A16-U120B
assign #0.2  g43219 = rst ? 0 : ~(0|CHWL07_|WCH06_);
// Gate A16-U233A
assign #0.2  g43406 = rst ? 0 : ~(0|WCH11_|CHWL02_);
// Gate A16-U142A
assign #0.2  g43120 = rst ? 1 : ~(0|g43121|g43119);
// Gate A16-U218A
assign #0.2  g43335 = rst ? 0 : ~(0|WCH12_|CHWL09_);
// Gate A16-U105B
assign #0.2  g43253 = rst ? 0 : ~(0|RCH06_|g43251);
// Gate A16-U112B
assign #0.2  g43235 = rst ? 0 : ~(0|WCH06_|CHWL05_);
// Gate A16-U113A
assign #0.2  g43237 = rst ? 0 : ~(0|CCH06|g43236);
// Gate A16-U128A
assign #0.2  g43206 = rst ? 0 : ~(0|XB6_|WCHG_|XT0_);
// Gate A16-U160A
assign #0.2  TVCNAB = rst ? 0 : ~(0|g43157);
// Gate A16-U211B
assign #0.2  ZIMCDU = rst ? 0 : ~(0|g43323);
// Gate A16-U215A
assign #0.2  g43329 = rst ? 0 : ~(0|g43327|RCH12_);
// Gate A16-U148A
assign #0.2  g43132 = rst ? 1 : ~(0|g43133|g43131);
// Gate A16-U241B
assign #0.2  TMPOUT = rst ? 0 : ~(0|g43421);
// Gate A16-U125B
assign #0.2  g43209 = rst ? 0 : ~(0|CCHG_|XT0_|XB6_);
// Gate A16-U125A
assign #0.2  g43210 = rst ? 0 : ~(0|GOJAM|g43209);
// Gate A16-U223B
assign #0.2  g43344 = rst ? 0 : ~(0|g43343|CCH12);
// Gate A16-U140A A16-U240A
assign #0.2  CHOR04_ = rst ? 1 : ~(0|g43243|g43122|CH3204|CH1504|g43423|g43319);
// Gate A16-U203B
assign #0.2  g43304 = rst ? 0 : ~(0|g43303|CCH12);
// Gate A16-U213A
assign #0.2  ENERIM = rst ? 0 : ~(0|g43327);
// Gate A16-U132A
assign #0.2  g43104 = rst ? 0 : ~(0|RCH05_|g43102);
// Gate A16-U128B
assign #0.2  RCpYmR = rst ? 0 : ~(0|g43202);
// Gate A16-U246A
assign #0.2  g43432 = rst ? 0 : ~(0|WCH11_|CHWL06_);
// Gate A16-U239A
assign #0.2  g43418 = rst ? 0 : ~(0|WCH11_|CHWL04_);
// Gate A16-U139A
assign #0.2  g43119 = rst ? 0 : ~(0|WCH05_|CHWL04_);
// Gate A16-U245A A16-U246B
assign #0.2  KYRLS = rst ? 0 : ~(0|FLASH|g43430);
// Gate A16-U150B
assign #0.2  g43139 = rst ? 0 : ~(0|CCH05|g43138);
// Gate A16-U149A
assign #0.2  g43137 = rst ? 0 : ~(0|WCH05_|CHWL07_);
// Gate A16-U242A
assign #0.2  g43421 = rst ? 1 : ~(0|g43422|g43418);
// Gate A16-U118B
assign #0.2  g43226 = rst ? 0 : ~(0|g43225|CCH12);
// Gate A16-U149B
assign #0.2  g43138 = rst ? 1 : ~(0|g43139|g43137);
// Gate A16-U117A
assign #0.2  OT1207 = rst ? 0 : ~(0|g43225);
// Gate A16-U109A
assign #0.2  g43241 = rst ? 1 : ~(0|g43242|g43240);
// Gate A16-U109B
assign #0.2  g43240 = rst ? 0 : ~(0|WCH06_|CHWL04_);
// Gate A16-U135B
assign #0.2  RCmXmP = rst ? 0 : ~(0|g43108);
// Gate A16-U104A
assign #0.2  g43251 = rst ? 1 : ~(0|g43252|g43250);
// Gate A16-U105A
assign #0.2  g43252 = rst ? 0 : ~(0|CCH06|g43251);
// Gate A16-U104B
assign #0.2  g43250 = rst ? 0 : ~(0|WCH06_|CHWL02_);
// Gate A16-U115B
assign #0.2  g43233 = rst ? 0 : ~(0|RCH06_|g43231);
// Gate A16-U129A
assign #0.2  g43202 = rst ? 1 : ~(0|g43201|g43203);
// Gate A16-U118A
assign #0.2  g43225 = rst ? 1 : ~(0|g43226|g43224);
// Gate A16-U150A
assign #0.2  g43140 = rst ? 0 : ~(0|RCH05_|g43138);
// Gate A16-U201B
assign #0.2  ZOPCDU = rst ? 0 : ~(0|g43303);
// Gate A16-U103A
assign #0.2  g43257 = rst ? 0 : ~(0|CCH06|g43256);
// Gate A16-U102B
assign #0.2  g43255 = rst ? 0 : ~(0|WCH06_|CHWL01_);
// Gate A16-U119A
assign #0.2  g43224 = rst ? 0 : ~(0|CHWL07_|WCH12_);
// Gate A16-U243A
assign #0.2  g43428 = rst ? 0 : ~(0|RCH11_|g43430);
// Gate A16-U140B A16-U240B
assign #0.2  CHOR03_ = rst ? 1 : ~(0|g43116|g43248|CH3203|g43414|g43311|CH1503);
// Gate A16-U225A
assign #0.2  MROLGT = rst ? 0 : ~(0|g43447);
// Gate A16-U243B
assign #0.2  g43429 = rst ? 0 : ~(0|g43430|CCH11);
// Gate A16-U222A
assign #0.2  g43345 = rst ? 0 : ~(0|WCH12_|CHWL11_);
// Gate A16-U250A
assign #0.2  g43445 = rst ? 0 : ~(0|CHWL07_|WCH11_);
// Gate A16-U107A
assign #0.2  g43246 = rst ? 1 : ~(0|g43247|g43245);
// Gate A16-U111A
assign #0.2  RCpYpR = rst ? 0 : ~(0|g43236);
// Gate A16-U145B
assign #0.2  RCpXpY = rst ? 0 : ~(0|g43126);
// Gate A16-U227B
assign #0.2  g43454 = rst ? 1 : ~(0|g43455|g43453);
// Gate A16-U249B A16-U248B
assign #0.2  VNFLSH = rst ? 0 : ~(0|FLASH_|g43434);
// Gate A16-U101B
assign #0.2  g43260 = rst ? 1 : ~(0);
// Gate A16-U133B
assign #0.2  RCpXpP = rst ? 0 : ~(0|g43102);
// Gate A16-U112A
assign #0.2  g43236 = rst ? 1 : ~(0|g43237|g43235);
// Gate A16-U233B
assign #0.2  ISSWAR = rst ? 0 : ~(0|g43404);
// Gate A16-U251B
assign #0.2  g43443 = rst ? 0 : ~(0|g43444|CCH11);
// Gate A16-U260A
assign #0.2  g43355 = rst ? 0 : ~(0|XB2_|XT1_);
// Gate A16-U131A
assign #0.2  g43102 = rst ? 1 : ~(0|g43101|g43103);
// Gate A16-U131B
assign #0.2  g43101 = rst ? 0 : ~(0|CHWL01_|WCH05_);
// Gate A16-U132B
assign #0.2  g43103 = rst ? 0 : ~(0|CCH05|g43102);
// Gate A16-U101A
assign #0.2  RCpZpR = rst ? 0 : ~(0|g43256);
// Gate A16-U204B
assign #0.2  g43307 = rst ? 1 : ~(0|g43306|g43308);
// Gate A16-U204A
assign #0.2  g43309 = rst ? 0 : ~(0|g43307|RCH12_);
// Gate A16-U212A
assign #0.2  g43321 = rst ? 0 : ~(0|g43323|RCH12_);
// Gate A16-U137A
assign #0.2  g43113 = rst ? 0 : ~(0|WCH05_|CHWL03_);
// Gate A16-U134B A16-U234A
assign #0.2  CHOR02_ = rst ? 1 : ~(0|CH3202|g43253|g43110|g43411|g43309|CH1502);
// Gate A16-U138B
assign #0.2  g43115 = rst ? 0 : ~(0|CCH05|g43114);
// Gate A16-U221B
assign #0.2  DISDAC = rst ? 0 : ~(0|g43343);
// Gate A16-U103B
assign #0.2  g43258 = rst ? 0 : ~(0|RCH06_|g43256);
// Gate A16-U137B
assign #0.2  g43114 = rst ? 1 : ~(0|g43115|g43113);
// Gate A16-U202B
assign #0.2  g43303 = rst ? 1 : ~(0|g43305|g43304);
// Gate A16-U256A A16-U257A A16-U257B
assign #0.2  CCH12 = rst ? 1 : ~(0|g43351);
// Gate A16-U215B
assign #0.2  g43328 = rst ? 0 : ~(0|g43327|CCH12);
// Gate A16-U231A
assign #0.2  g43405 = rst ? 0 : ~(0|WCH11_|CHWL01_);
// Gate A16-U232B
assign #0.2  g43403 = rst ? 0 : ~(0|g43404|CCH11);
// Gate A16-U206B
assign #0.2  STARON = rst ? 0 : ~(0|g43313);
// Gate A16-U106A
assign #0.2  RCmZpR = rst ? 0 : ~(0|g43246);
// Gate A16-U231B
assign #0.2  g43404 = rst ? 1 : ~(0|g43403|g43405);
// Gate A16-U122A A16-U122B
assign #0.2  RCH05_ = rst ? 1 : ~(0|g43216);
// Gate A16-U229A
assign #0.2  S4BOFF = rst ? 0 : ~(0|g43457);
// Gate A16-U136A
assign #0.2  g43108 = rst ? 1 : ~(0|g43109|g43107);
// Gate A16-U210A
assign #0.2  COARSE = rst ? 0 : ~(0|g43317);
// Gate A16-U227A
assign #0.2  g43455 = rst ? 0 : ~(0|WCH12_|CHWL13_);
// Gate A16-U142B
assign #0.2  g43121 = rst ? 0 : ~(0|CCH05|g43120);
// Gate A16-U127B A16-U126B
assign #0.2  WCH06_ = rst ? 1 : ~(0|g43206);
// Gate A16-U228B
assign #0.2  g43453 = rst ? 0 : ~(0|g43454|CCH12);
// Gate A16-U202A
assign #0.2  g43301 = rst ? 0 : ~(0|g43303|RCH12_);
// Gate A16-U114B
assign #0.2  g43230 = rst ? 0 : ~(0|WCH06_|CHWL06_);
// Gate A16-U115A
assign #0.2  g43232 = rst ? 0 : ~(0|CCH06|g43231);
// Gate A16-U114A
assign #0.2  g43231 = rst ? 1 : ~(0|g43232|g43230);
// Gate A16-U134A A16-U234B
assign #0.2  CHOR01_ = rst ? 1 : ~(0|g43104|CH3201|g43258|g43402|g43301|CH1501);
// Gate A16-U209B
assign #0.2  g43317 = rst ? 1 : ~(0|g43316|g43318);
// Gate A16-U136B
assign #0.2  g43109 = rst ? 0 : ~(0|CCH05|g43108);
// Gate A16-U209A
assign #0.2  g43319 = rst ? 0 : ~(0|g43317|RCH12_);
// Gate A16-U116A
assign #0.2  RCmYmR = rst ? 0 : ~(0|g43231);
// Gate A16-U235B
assign #0.2  COMACT = rst ? 0 : ~(0|g43409);
// Gate A16-U216B
assign #0.2  g43334 = rst ? 0 : ~(0|g43333|CCH12);
// Gate A16-U206A
assign #0.2  g43315 = rst ? 0 : ~(0|WCH12_|CHWL03_);
// Gate A16-U210B
assign #0.2  g43318 = rst ? 0 : ~(0|g43317|CCH12);
// Gate A16-U216A
assign #0.2  g43333 = rst ? 1 : ~(0|g43334|g43335);
// Gate A16-U256B
assign #0.2  g43351 = rst ? 0 : ~(0|g43350|GOJAM);
// Gate A16-U220B
assign #0.2  ZEROPT = rst ? 0 : ~(0|g43337);
// Gate A16-U213B
assign #0.2  g43324 = rst ? 0 : ~(0|g43323|CCH12);
// Gate A16-U205B
assign #0.2  g43308 = rst ? 0 : ~(0|g43307|CCH12);
// Gate A16-U217B
assign #0.2  S4BTAK = rst ? 0 : ~(0|g43333);
// Gate A16-U248A
assign #0.2  g43436 = rst ? 0 : ~(0|RCH11_|g43434);
// Gate A16-U241A
assign #0.2  g43423 = rst ? 0 : ~(0|RCH11_|g43421);
// Gate A16-U156A A16-U155A
assign #0.2  WCH05_ = rst ? 1 : ~(0|g43151);
// Gate A16-U212B
assign #0.2  g43323 = rst ? 1 : ~(0|g43325|g43324);
// Gate A16-U254A A16-U255A A16-U253B
assign #0.2  WCH12_ = rst ? 1 : ~(0|g43349);
// Gate A16-U222B
assign #0.2  g43343 = rst ? 1 : ~(0|g43344|g43345);
// Gate A16-U232A
assign #0.2  g43402 = rst ? 0 : ~(0|RCH11_|g43404);
// Gate A16-U151A
assign #0.2  g43143 = rst ? 0 : ~(0|WCH05_|CHWL08_);
// Gate A16-U237B
assign #0.2  g43416 = rst ? 1 : ~(0|g43415|g43417);
// Gate A16-U238B
assign #0.2  g43415 = rst ? 0 : ~(0|g43416|CCH11);
// Gate A16-U153A
assign #0.2  g43146 = rst ? 0 : ~(0|g43144|RCH05_);
// Gate A16-U237A
assign #0.2  g43417 = rst ? 0 : ~(0|WCH11_|CHWL03_);
// Gate A16-U218B
assign #0.2  g43338 = rst ? 0 : ~(0|g43337|CCH12);
// Gate A16-U108B
assign #0.2  g43248 = rst ? 0 : ~(0|RCH06_|g43246);
// Gate A16-U208A
assign #0.2  g43316 = rst ? 0 : ~(0|WCH12_|CHWL04_);
// Gate A16-U236B
assign #0.2  g43410 = rst ? 0 : ~(0|g43409|CCH11);
// Gate A16-U260B
assign #0.2  g43359 = rst ? 1 : ~(0);
// Gate A16-U121A
assign #0.2  g43221 = rst ? 0 : ~(0|CCH06|g43220);
// Gate A16-U102A
assign #0.2  g43256 = rst ? 1 : ~(0|g43257|g43255);
// Gate A16-U252A A16-U253A
assign #0.2  OPEROR = rst ? 0 : ~(0|FLASH|g43444);
// Gate A16-U108A
assign #0.2  g43247 = rst ? 0 : ~(0|CCH06|g43246);
// Gate A16-U214A
assign #0.2  g43326 = rst ? 0 : ~(0|WCH12_|CHWL06_);
// Gate A16-U250B
assign #0.2  g43444 = rst ? 1 : ~(0|g43445|g43443);
// Gate A16-U230A
assign #0.2  CH1214 = rst ? 0 : ~(0|g43457|RCH12_);
// Gate A16-U116B
assign #0.2  OT1207_ = rst ? 1 : ~(0|g43226);
// Gate A16-U111B
assign #0.2  RCpZmR = rst ? 0 : ~(0|g43241);
// Gate A16-U152A
assign #0.2  CHOR08_ = rst ? 1 : ~(0|g43146|g43204|CH3208);
// Gate A16-U258A A16-U259A A16-U259B
assign #0.2  RCH12_ = rst ? 1 : ~(0|g43355);
// Gate A16-U130B
assign #0.2  g43204 = rst ? 0 : ~(0|RCH06_|g43202);
// Gate A16-U155B
assign #0.2  g43151 = rst ? 0 : ~(0|XB5_|XT0_|WCHG_);

endmodule
