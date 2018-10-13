// Verilog module auto-generated for AGC module A17 by dumbVerilog.py

module A17 ( 
  rst, AGCWAR, CCHG_, CDUFAL, CGA17, CH1113, CH1213, CH1214, CH1301, CH1302,
  CH1303, CH1304, CH1305, CH1306, CH1307, CH1308, CH1309, CH1310, CH1311,
  CH1316, CH1401, CH1402, CH1403, CH1404, CH1405, CH1406, CH1407, CH1408,
  CH1409, CH1410, CH1411, CH1412, CH1413, CH1414, CH1416, CH3310, CH3312,
  CHWL01_, CHWL02_, CHWL03_, CHWL04_, CHWL05_, CHWL06_, CHWL07_, CHWL08_,
  CHWL09_, CHWL10_, CHWL11_, CHWL12_, CHWL13_, CHWL14_, CHWL16_, CTLSAT,
  F05A_, F05B_, F05D, FREFUN, GCAPCL, GOJAM, GUIREL, HOLFUN, IMUCAG, IMUFAL,
  IMUOPR, IN3008, IN3212, IN3213, IN3214, IN3216, IN3301, ISSTOR, LEMATT,
  LFTOFF, LRRLSC, LVDAGD, MANRmP, MANRmR, MANRmY, MANRpP, MANRpR, MANRpY,
  MNIMmP, MNIMmR, MNIMmY, MNIMpP, MNIMpR, MNIMpY, OPCDFL, OPMSW2, OPMSW3,
  OSCALM, PCHGOF, PIPAFL, ROLGOF, RRPONA, RRRLSC, S01, S02, S4BSAB, SMSEPR,
  SPSRDY, STRPRS, TEMPIN, TPOR_, TRANmX, TRANmY, TRANmZ, TRANpX, TRANpY,
  TRANpZ, TRST10, TRST9, ULLTHR, WCH13_, WCHG_, XB0_, XB1_, XB2_, XB3_, XT1_,
  XT3_, ZEROP, CHOR01_, CHOR02_, CHOR03_, CHOR04_, CHOR05_, CHOR06_, CHOR07_,
  CHOR08_, CHOR09_, CHOR10_, CHOR11_, CHOR12_, CHOR13_, CHOR14_, CHOR16_,
  RCH33_, XB0, CCH10, CCH11, CH3201, CH3202, CH3203, CH3204, CH3205, CH3206,
  CH3207, CH3208, CH3209, CH3210, CH3313, CH3314, CH3316, HNDRPT, RCH10_,
  RCH11_, RCH30_, RCH31_, RCH32_, RLYB01, RLYB02, RLYB03, RLYB04, RLYB05,
  RLYB06, RLYB07, RLYB08, RLYB09, RLYB10, RLYB11, RYWD12, RYWD13, RYWD14,
  RYWD16, TRP31A, TRP31B, TRP32, WCH10_, WCH11_
);

input wire rst, AGCWAR, CCHG_, CDUFAL, CGA17, CH1113, CH1213, CH1214, CH1301,
  CH1302, CH1303, CH1304, CH1305, CH1306, CH1307, CH1308, CH1309, CH1310,
  CH1311, CH1316, CH1401, CH1402, CH1403, CH1404, CH1405, CH1406, CH1407,
  CH1408, CH1409, CH1410, CH1411, CH1412, CH1413, CH1414, CH1416, CH3310,
  CH3312, CHWL01_, CHWL02_, CHWL03_, CHWL04_, CHWL05_, CHWL06_, CHWL07_,
  CHWL08_, CHWL09_, CHWL10_, CHWL11_, CHWL12_, CHWL13_, CHWL14_, CHWL16_,
  CTLSAT, F05A_, F05B_, F05D, FREFUN, GCAPCL, GOJAM, GUIREL, HOLFUN, IMUCAG,
  IMUFAL, IMUOPR, IN3008, IN3212, IN3213, IN3214, IN3216, IN3301, ISSTOR,
  LEMATT, LFTOFF, LRRLSC, LVDAGD, MANRmP, MANRmR, MANRmY, MANRpP, MANRpR,
  MANRpY, MNIMmP, MNIMmR, MNIMmY, MNIMpP, MNIMpR, MNIMpY, OPCDFL, OPMSW2,
  OPMSW3, OSCALM, PCHGOF, PIPAFL, ROLGOF, RRPONA, RRRLSC, S01, S02, S4BSAB,
  SMSEPR, SPSRDY, STRPRS, TEMPIN, TPOR_, TRANmX, TRANmY, TRANmZ, TRANpX,
  TRANpY, TRANpZ, TRST10, TRST9, ULLTHR, WCH13_, WCHG_, XB0_, XB1_, XB2_,
  XB3_, XT1_, XT3_, ZEROP;

inout wire CHOR01_, CHOR02_, CHOR03_, CHOR04_, CHOR05_, CHOR06_, CHOR07_,
  CHOR08_, CHOR09_, CHOR10_, CHOR11_, CHOR12_, CHOR13_, CHOR14_, CHOR16_,
  RCH33_, XB0;

output wire CCH10, CCH11, CH3201, CH3202, CH3203, CH3204, CH3205, CH3206,
  CH3207, CH3208, CH3209, CH3210, CH3313, CH3314, CH3316, HNDRPT, RCH10_,
  RCH11_, RCH30_, RCH31_, RCH32_, RLYB01, RLYB02, RLYB03, RLYB04, RLYB05,
  RLYB06, RLYB07, RLYB08, RLYB09, RLYB10, RLYB11, RYWD12, RYWD13, RYWD14,
  RYWD16, TRP31A, TRP31B, TRP32, WCH10_, WCH11_;

parameter GATE_DELAY = 0.2; // This default may be overridden at compile time.
initial $display("Gate delay (A17) will be %f ns.", GATE_DELAY*100);

// Gate A17-U121B
pullup(g44219);
assign #GATE_DELAY g44219 = rst ? 0 : ((0|TRANmY|RCH31_) ? 1'b0 : 1'bz);
// Gate A17-U202A
pullup(g44358);
assign #GATE_DELAY g44358 = rst ? 0 : ((0|RCH10_|g44356) ? 1'b0 : 1'bz);
// Gate A17-U256A A17-U256B A17-U257A
pullup(CCH11);
assign #GATE_DELAY CCH11 = rst ? 1'bz : ((0|g44449) ? 1'b0 : 1'bz);
// Gate A17-U141B
pullup(g44153);
assign #GATE_DELAY g44153 = rst ? 0 : ((0|XT3_|XB2_) ? 1'b0 : 1'bz);
// Gate A17-U248A A17-U247A A17-U247B
pullup(WCH10_);
assign #GATE_DELAY WCH10_ = rst ? 1'bz : ((0|g44431) ? 1'b0 : 1'bz);
// Gate A17-U146A A17-U209A
pullup(CHOR07_);
assign #GATE_DELAY CHOR07_ = rst ? 1'bz : ((0|g44216|g44120|g44119|CH1407|CH1307|g44340) ? 1'b0 : 1'bz);
// Gate A17-U121A
pullup(g44254);
assign #GATE_DELAY g44254 = rst ? 0 : ((0|GOJAM|TRP32|g44255) ? 1'b0 : 1'bz);
// Gate A17-U118B
pullup(g44256);
assign #GATE_DELAY g44256 = rst ? 0 : ((0|WCH13_|CHWL14_) ? 1'b0 : 1'bz);
// Gate A17-U118A
pullup(g44255);
assign #GATE_DELAY g44255 = rst ? 1'bz : ((0|g44254|g44256) ? 1'b0 : 1'bz);
// Gate A17-U214A
pullup(g44334);
assign #GATE_DELAY g44334 = rst ? 0 : ((0|g44332|RCH10_) ? 1'b0 : 1'bz);
// Gate A17-U225A
pullup(g44309);
assign #GATE_DELAY g44309 = rst ? 0 : ((0|g44308|CCH10) ? 1'b0 : 1'bz);
// Gate A17-U123B
pullup(g44205);
assign #GATE_DELAY g44205 = rst ? 0 : ((0|MANRpR|RCH31_) ? 1'b0 : 1'bz);
// Gate A17-U214B
pullup(g44331);
assign #GATE_DELAY g44331 = rst ? 0 : ((0|WCH10_|CHWL06_) ? 1'b0 : 1'bz);
// Gate A17-U102A
pullup(CH3205);
assign #GATE_DELAY CH3205 = rst ? 0 : ((0|MNIMpR|RCH32_) ? 1'b0 : 1'bz);
// Gate A17-U244A
pullup(g44427);
assign #GATE_DELAY g44427 = rst ? 0 : ((0|g44426|CCH10) ? 1'b0 : 1'bz);
// Gate A17-U213B
pullup(g44332);
assign #GATE_DELAY g44332 = rst ? 1'bz : ((0|g44333|g44331) ? 1'b0 : 1'bz);
// Gate A17-U123A
pullup(g44252);
assign #GATE_DELAY g44252 = rst ? 0 : ((0|F05D|g44251|g44247) ? 1'b0 : 1'bz);
// Gate A17-U213A
pullup(g44333);
assign #GATE_DELAY g44333 = rst ? 0 : ((0|g44332|CCH10) ? 1'b0 : 1'bz);
// Gate A17-U243B
pullup(g44425);
assign #GATE_DELAY g44425 = rst ? 0 : ((0|WCH10_|CHWL16_) ? 1'b0 : 1'bz);
// Gate A17-U150B
pullup(g44125);
assign #GATE_DELAY g44125 = rst ? 0 : ((0|RCH30_|IMUOPR) ? 1'b0 : 1'bz);
// Gate A17-U150A
pullup(g44126);
assign #GATE_DELAY g44126 = rst ? 0 : ((0|RCH33_|LRRLSC) ? 1'b0 : 1'bz);
// Gate A17-U205A
pullup(g44351);
assign #GATE_DELAY g44351 = rst ? 0 : ((0|g44350|CCH10) ? 1'b0 : 1'bz);
// Gate A17-U244B
pullup(g44426);
assign #GATE_DELAY g44426 = rst ? 1'bz : ((0|g44425|g44427) ? 1'b0 : 1'bz);
// Gate A17-U206B
pullup(g44349);
assign #GATE_DELAY g44349 = rst ? 0 : ((0|WCH10_|CHWL09_) ? 1'b0 : 1'bz);
// Gate A17-U236B
pullup(g44407);
assign #GATE_DELAY g44407 = rst ? 0 : ((0|WCH10_|CHWL12_) ? 1'b0 : 1'bz);
// Gate A17-U130A
pullup(g44212);
assign #GATE_DELAY g44212 = rst ? 0 : ((0|g44213|GOJAM|TRP31A) ? 1'b0 : 1'bz);
// Gate A17-U124A
pullup(g44251);
assign #GATE_DELAY g44251 = rst ? 1'bz : ((0|g44250|g44252) ? 1'b0 : 1'bz);
// Gate A17-U122B
pullup(g44215);
assign #GATE_DELAY g44215 = rst ? 0 : ((0|MANRmR|RCH31_) ? 1'b0 : 1'bz);
// Gate A17-U138A
pullup(g44140);
assign #GATE_DELAY g44140 = rst ? 0 : ((0|RCH32_|IN3214) ? 1'b0 : 1'bz);
// Gate A17-U137B
pullup(g44139);
assign #GATE_DELAY g44139 = rst ? 0 : ((0|RCH30_|ISSTOR) ? 1'b0 : 1'bz);
// Gate A17-U135B
pullup(g44143);
assign #GATE_DELAY g44143 = rst ? 0 : ((0|RCH32_|IN3216) ? 1'b0 : 1'bz);
// Gate A17-U159B
pullup(g44104);
assign #GATE_DELAY g44104 = rst ? 0 : ((0|RCH30_|SMSEPR) ? 1'b0 : 1'bz);
// Gate A17-U238B
pullup(g44414);
assign #GATE_DELAY g44414 = rst ? 1'bz : ((0|g44413|g44415) ? 1'b0 : 1'bz);
// Gate A17-U217B
pullup(g44326);
assign #GATE_DELAY g44326 = rst ? 1'bz : ((0|g44327|g44325) ? 1'b0 : 1'bz);
// Gate A17-U254B
pullup(g44448);
assign #GATE_DELAY g44448 = rst ? 0 : ((0|CCHG_|XT1_|XB1_) ? 1'b0 : 1'bz);
// Gate A17-U224B
pullup(g44313);
assign #GATE_DELAY g44313 = rst ? 0 : ((0|WCH10_|CHWL03_) ? 1'b0 : 1'bz);
// Gate A17-U158B
pullup(g44105);
assign #GATE_DELAY g44105 = rst ? 0 : ((0|RCH33_|RRPONA) ? 1'b0 : 1'bz);
// Gate A17-U136B
pullup(g44142);
assign #GATE_DELAY g44142 = rst ? 0 : ((0|RCH30_|TEMPIN) ? 1'b0 : 1'bz);
// Gate A17-U152A A17-U215A
pullup(CHOR06_);
assign #GATE_DELAY CHOR06_ = rst ? 1'bz : ((0|g44215|g44117|g44116|CH1406|CH1306|g44334) ? 1'b0 : 1'bz);
// Gate A17-U237B
pullup(g44413);
assign #GATE_DELAY g44413 = rst ? 0 : ((0|WCH10_|CHWL13_) ? 1'b0 : 1'bz);
// Gate A17-U128A
pullup(g44210);
assign #GATE_DELAY g44210 = rst ? 0 : ((0|F05D|g44206|g44209) ? 1'b0 : 1'bz);
// Gate A17-U207A
pullup(g44345);
assign #GATE_DELAY g44345 = rst ? 0 : ((0|g44344|CCH10) ? 1'b0 : 1'bz);
// Gate A17-U110B
pullup(HNDRPT);
assign #GATE_DELAY HNDRPT = rst ? 0 : ((0|g44230|TPOR_) ? 1'b0 : 1'bz);
// Gate A17-U207B
pullup(g44344);
assign #GATE_DELAY g44344 = rst ? 1'bz : ((0|g44345|g44343) ? 1'b0 : 1'bz);
// Gate A17-U208B
pullup(g44343);
assign #GATE_DELAY g44343 = rst ? 0 : ((0|WCH10_|CHWL08_) ? 1'b0 : 1'bz);
// Gate A17-U259B
pullup(XB0);
assign #GATE_DELAY XB0 = rst ? 0 : ((0|S01|S02) ? 1'b0 : 1'bz);
// Gate A17-U254A A17-U255A A17-U253B
pullup(WCH11_);
assign #GATE_DELAY WCH11_ = rst ? 1'bz : ((0|g44444) ? 1'b0 : 1'bz);
// Gate A17-U218B
pullup(g44325);
assign #GATE_DELAY g44325 = rst ? 0 : ((0|WCH10_|CHWL05_) ? 1'b0 : 1'bz);
// Gate A17-U109B
pullup(g44234);
assign #GATE_DELAY g44234 = rst ? 0 : ((0|FREFUN|RCH31_) ? 1'b0 : 1'bz);
// Gate A17-U237A
pullup(RYWD13);
assign #GATE_DELAY RYWD13 = rst ? 0 : ((0|g44414) ? 1'b0 : 1'bz);
// Gate A17-U233B
pullup(RYWD12);
assign #GATE_DELAY RYWD12 = rst ? 0 : ((0|g44408) ? 1'b0 : 1'bz);
// Gate A17-U252B
pullup(g44444);
assign #GATE_DELAY g44444 = rst ? 0 : ((0|XT1_|WCHG_|XB1_) ? 1'b0 : 1'bz);
// Gate A17-U217A
pullup(g44327);
assign #GATE_DELAY g44327 = rst ? 0 : ((0|g44326|CCH10) ? 1'b0 : 1'bz);
// Gate A17-U109A
pullup(g44235);
assign #GATE_DELAY g44235 = rst ? 0 : ((0|GCAPCL|RCH31_) ? 1'b0 : 1'bz);
// Gate A17-U111B
pullup(g44233);
assign #GATE_DELAY g44233 = rst ? 0 : ((0|HOLFUN|RCH31_) ? 1'b0 : 1'bz);
// Gate A17-U135A A17-U240B
pullup(CHOR14_);
assign #GATE_DELAY CHOR14_ = rst ? 1'bz : ((0|g44139|g44140|g44234|CH1414|CH1214|g44422) ? 1'b0 : 1'bz);
// Gate A17-U144A A17-U234A
pullup(CHOR11_);
assign #GATE_DELAY CHOR11_ = rst ? 1'bz : ((0|g44220|g44130|g44131|CH1411|g44404|CH1311) ? 1'b0 : 1'bz);
// Gate A17-U106B A17-U107A A17-U107B A17-U105A
pullup(g44247);
assign #GATE_DELAY g44247 = rst ? 1'bz : ((0|MNIMpY|MNIMmY|MNIMmP|TRST10|ROLGOF|PCHGOF|MNIMpP|MNIMmR|TRST9|MNIMpR) ? 1'b0 : 1'bz);
// Gate A17-U210A
pullup(g44340);
assign #GATE_DELAY g44340 = rst ? 0 : ((0|g44338|RCH10_) ? 1'b0 : 1'bz);
// Gate A17-U160B
pullup(g44101);
assign #GATE_DELAY g44101 = rst ? 0 : ((0|RCH30_|ULLTHR) ? 1'b0 : 1'bz);
// Gate A17-U153A A17-U215B
pullup(CHOR05_);
assign #GATE_DELAY CHOR05_ = rst ? 1'bz : ((0|g44205|g44113|g44114|g44328|CH1405|CH1305) ? 1'b0 : 1'bz);
// Gate A17-U160A
pullup(g44102);
assign #GATE_DELAY g44102 = rst ? 0 : ((0|RCH33_|IN3301) ? 1'b0 : 1'bz);
// Gate A17-U258A A17-U258B A17-U259A
pullup(RCH11_);
assign #GATE_DELAY RCH11_ = rst ? 1'bz : ((0|g44453) ? 1'b0 : 1'bz);
// Gate A17-U117B
pullup(g44217);
assign #GATE_DELAY g44217 = rst ? 0 : ((0|TRANmX|RCH31_) ? 1'b0 : 1'bz);
// Gate A17-U152B
pullup(g44117);
assign #GATE_DELAY g44117 = rst ? 0 : ((0|RCH33_|OPMSW3) ? 1'b0 : 1'bz);
// Gate A17-U201B
pullup(g44355);
assign #GATE_DELAY g44355 = rst ? 0 : ((0|WCH10_|CHWL10_) ? 1'b0 : 1'bz);
// Gate A17-U153B
pullup(g44116);
assign #GATE_DELAY g44116 = rst ? 0 : ((0|RCH30_|GUIREL) ? 1'b0 : 1'bz);
// Gate A17-U145A A17-U145B A17-U146B
pullup(RCH33_);
assign #GATE_DELAY RCH33_ = rst ? 1'bz : ((0|g44157) ? 1'b0 : 1'bz);
// Gate A17-U114B
pullup(g44220);
assign #GATE_DELAY g44220 = rst ? 0 : ((0|TRANpZ|RCH31_) ? 1'b0 : 1'bz);
// Gate A17-U249A A17-U250A A17-U250B
pullup(CCH10);
assign #GATE_DELAY CCH10 = rst ? 1'bz : ((0|g44436) ? 1'b0 : 1'bz);
// Gate A17-U202B
pullup(g44356);
assign #GATE_DELAY g44356 = rst ? 1'bz : ((0|g44357|g44355) ? 1'b0 : 1'bz);
// Gate A17-U201A
pullup(g44357);
assign #GATE_DELAY g44357 = rst ? 0 : ((0|g44356|CCH10) ? 1'b0 : 1'bz);
// Gate A17-U239A
pullup(g44416);
assign #GATE_DELAY g44416 = rst ? 0 : ((0|g44414|RCH10_) ? 1'b0 : 1'bz);
// Gate A17-U103A
pullup(CH3204);
assign #GATE_DELAY CH3204 = rst ? 0 : ((0|MNIMmY|RCH32_) ? 1'b0 : 1'bz);
// Gate A17-U113A
pullup(g44230);
assign #GATE_DELAY g44230 = rst ? 1'bz : ((0|TRP31A|TRP32|TRP31B) ? 1'b0 : 1'bz);
// Gate A17-U106A
pullup(CH3206);
assign #GATE_DELAY CH3206 = rst ? 0 : ((0|MNIMmR|RCH32_) ? 1'b0 : 1'bz);
// Gate A17-U111A
pullup(CH3207);
assign #GATE_DELAY CH3207 = rst ? 0 : ((0|TRST9|RCH32_) ? 1'b0 : 1'bz);
// Gate A17-U242B
pullup(g44419);
assign #GATE_DELAY g44419 = rst ? 0 : ((0|WCH10_|CHWL14_) ? 1'b0 : 1'bz);
// Gate A17-U104B
pullup(CH3201);
assign #GATE_DELAY CH3201 = rst ? 0 : ((0|MNIMpP|RCH32_) ? 1'b0 : 1'bz);
// Gate A17-U104A
pullup(CH3202);
assign #GATE_DELAY CH3202 = rst ? 0 : ((0|MNIMmP|RCH32_) ? 1'b0 : 1'bz);
// Gate A17-U103B
pullup(CH3203);
assign #GATE_DELAY CH3203 = rst ? 0 : ((0|MNIMpY|RCH32_) ? 1'b0 : 1'bz);
// Gate A17-U205B
pullup(g44350);
assign #GATE_DELAY g44350 = rst ? 1'bz : ((0|g44349|g44351) ? 1'b0 : 1'bz);
// Gate A17-U220A
pullup(g44322);
assign #GATE_DELAY g44322 = rst ? 0 : ((0|g44320|RCH10_) ? 1'b0 : 1'bz);
// Gate A17-U223A
pullup(g44315);
assign #GATE_DELAY g44315 = rst ? 0 : ((0|g44314|CCH10) ? 1'b0 : 1'bz);
// Gate A17-U110A
pullup(CH3208);
assign #GATE_DELAY CH3208 = rst ? 0 : ((0|TRST10|RCH32_) ? 1'b0 : 1'bz);
// Gate A17-U108B
pullup(CH3209);
assign #GATE_DELAY CH3209 = rst ? 0 : ((0|PCHGOF|RCH32_) ? 1'b0 : 1'bz);
// Gate A17-U122A
pullup(TRP32);
assign #GATE_DELAY TRP32 = rst ? 0 : ((0|F05B_|g44251) ? 1'b0 : 1'bz);
// Gate A17-U230B
pullup(g44301);
assign #GATE_DELAY g44301 = rst ? 0 : ((0|WCH10_|CHWL01_) ? 1'b0 : 1'bz);
// Gate A17-U144B
pullup(g44130);
assign #GATE_DELAY g44130 = rst ? 0 : ((0|RCH30_|IMUCAG) ? 1'b0 : 1'bz);
// Gate A17-U251B
pullup(g44440);
assign #GATE_DELAY g44440 = rst ? 0 : ((0|XB0_|XT1_) ? 1'b0 : 1'bz);
// Gate A17-U149B
pullup(g44122);
assign #GATE_DELAY g44122 = rst ? 0 : ((0|RCH30_|IN3008) ? 1'b0 : 1'bz);
// Gate A17-U142A
pullup(g44134);
assign #GATE_DELAY g44134 = rst ? 0 : ((0|RCH32_|IN3212) ? 1'b0 : 1'bz);
// Gate A17-U142B
pullup(g44133);
assign #GATE_DELAY g44133 = rst ? 0 : ((0|RCH30_|CDUFAL) ? 1'b0 : 1'bz);
// Gate A17-U242A
pullup(g44422);
assign #GATE_DELAY g44422 = rst ? 0 : ((0|g44420|RCH10_) ? 1'b0 : 1'bz);
// Gate A17-U155A A17-U221A
pullup(CHOR04_);
assign #GATE_DELAY CHOR04_ = rst ? 1'bz : ((0|g44204|g44110|g44111|CH1404|CH1304|g44322) ? 1'b0 : 1'bz);
// Gate A17-U219A
pullup(g44321);
assign #GATE_DELAY g44321 = rst ? 0 : ((0|g44320|CCH10) ? 1'b0 : 1'bz);
// Gate A17-U138B
pullup(g44136);
assign #GATE_DELAY g44136 = rst ? 0 : ((0|RCH30_|IMUFAL) ? 1'b0 : 1'bz);
// Gate A17-U222A
pullup(g44316);
assign #GATE_DELAY g44316 = rst ? 0 : ((0|g44314|RCH10_) ? 1'b0 : 1'bz);
// Gate A17-U139B A17-U140A A17-U140B
pullup(RCH32_);
assign #GATE_DELAY RCH32_ = rst ? 1'bz : ((0|g44153) ? 1'b0 : 1'bz);
// Gate A17-U225B
pullup(g44308);
assign #GATE_DELAY g44308 = rst ? 1'bz : ((0|g44309|g44307) ? 1'b0 : 1'bz);
// Gate A17-U243A
pullup(RYWD16);
assign #GATE_DELAY RYWD16 = rst ? 0 : ((0|g44426) ? 1'b0 : 1'bz);
// Gate A17-U108A
pullup(CH3210);
assign #GATE_DELAY CH3210 = rst ? 0 : ((0|ROLGOF|RCH32_) ? 1'b0 : 1'bz);
// Gate A17-U134A A17-U246A
pullup(CHOR16_);
assign #GATE_DELAY CHOR16_ = rst ? 1'bz : ((0|g44235|g44142|g44143|CH1316|CH1416|g44428) ? 1'b0 : 1'bz);
// Gate A17-U137A
pullup(g44137);
assign #GATE_DELAY g44137 = rst ? 0 : ((0|RCH32_|IN3213) ? 1'b0 : 1'bz);
// Gate A17-U239B
pullup(RYWD14);
assign #GATE_DELAY RYWD14 = rst ? 0 : ((0|g44420) ? 1'b0 : 1'bz);
// Gate A17-U139A A17-U246B A17-U240A
pullup(CHOR13_);
assign #GATE_DELAY CHOR13_ = rst ? 1'bz : ((0|g44233|g44136|g44137|CH1113|CH1413|g44416|CH1213) ? 1'b0 : 1'bz);
// Gate A17-U208A
pullup(g44346);
assign #GATE_DELAY g44346 = rst ? 0 : ((0|g44344|RCH10_) ? 1'b0 : 1'bz);
// Gate A17-U155B
pullup(g44111);
assign #GATE_DELAY g44111 = rst ? 0 : ((0|RCH33_|ZEROP) ? 1'b0 : 1'bz);
// Gate A17-U156B
pullup(g44110);
assign #GATE_DELAY g44110 = rst ? 0 : ((0|RCH30_|S4BSAB) ? 1'b0 : 1'bz);
// Gate A17-U226B
pullup(g44307);
assign #GATE_DELAY g44307 = rst ? 0 : ((0|WCH10_|CHWL02_) ? 1'b0 : 1'bz);
// Gate A17-U156A A17-U221B
pullup(CHOR03_);
assign #GATE_DELAY CHOR03_ = rst ? 1'bz : ((0|g44203|g44107|g44108|g44316|CH1403|CH1303) ? 1'b0 : 1'bz);
// Gate A17-U133A A17-U133B A17-U136A
pullup(RCH31_);
assign #GATE_DELAY RCH31_ = rst ? 1'bz : ((0|g44149) ? 1'b0 : 1'bz);
// Gate A17-U148B
pullup(g44123);
assign #GATE_DELAY g44123 = rst ? 0 : ((0|RCH33_|LVDAGD) ? 1'b0 : 1'bz);
// Gate A17-U119B
pullup(g44218);
assign #GATE_DELAY g44218 = rst ? 0 : ((0|TRANpY|RCH31_) ? 1'b0 : 1'bz);
// Gate A17-U235A
pullup(g44409);
assign #GATE_DELAY g44409 = rst ? 0 : ((0|g44408|CCH10) ? 1'b0 : 1'bz);
// Gate A17-U219B
pullup(g44320);
assign #GATE_DELAY g44320 = rst ? 1'bz : ((0|g44321|g44319) ? 1'b0 : 1'bz);
// Gate A17-U228A
pullup(g44304);
assign #GATE_DELAY g44304 = rst ? 0 : ((0|g44302|RCH10_) ? 1'b0 : 1'bz);
// Gate A17-U131B
pullup(g44145);
assign #GATE_DELAY g44145 = rst ? 0 : ((0|XB0_|XT3_) ? 1'b0 : 1'bz);
// Gate A17-U220B
pullup(g44319);
assign #GATE_DELAY g44319 = rst ? 0 : ((0|WCH10_|CHWL04_) ? 1'b0 : 1'bz);
// Gate A17-U128B
pullup(g44202);
assign #GATE_DELAY g44202 = rst ? 0 : ((0|MANRmP|RCH31_) ? 1'b0 : 1'bz);
// Gate A17-U252A A17-U253A A17-U251A
pullup(RCH10_);
assign #GATE_DELAY RCH10_ = rst ? 1'bz : ((0|g44440) ? 1'b0 : 1'bz);
// Gate A17-U223B
pullup(g44314);
assign #GATE_DELAY g44314 = rst ? 1'bz : ((0|g44315|g44313) ? 1'b0 : 1'bz);
// Gate A17-U249B
pullup(g44436);
assign #GATE_DELAY g44436 = rst ? 0 : ((0|g44435|GOJAM) ? 1'b0 : 1'bz);
// Gate A17-U154B
pullup(g44113);
assign #GATE_DELAY g44113 = rst ? 0 : ((0|RCH30_|LFTOFF) ? 1'b0 : 1'bz);
// Gate A17-U151A A17-U203B
pullup(CHOR10_);
assign #GATE_DELAY CHOR10_ = rst ? 1'bz : ((0|g44219|g44128|CH3310|g44358|CH1410|CH1310) ? 1'b0 : 1'bz);
// Gate A17-U232B
pullup(g44402);
assign #GATE_DELAY g44402 = rst ? 1'bz : ((0|g44401|g44403) ? 1'b0 : 1'bz);
// Gate A17-U154A
pullup(g44114);
assign #GATE_DELAY g44114 = rst ? 0 : ((0|RCH33_|OPMSW2) ? 1'b0 : 1'bz);
// Gate A17-U120B A17-U127B
pullup(g44206);
assign #GATE_DELAY g44206 = rst ? 1'bz : ((0|MANRmR|MANRmY|MANRpR|MANRpY|MANRmP|MANRpP) ? 1'b0 : 1'bz);
// Gate A17-U231B
pullup(g44401);
assign #GATE_DELAY g44401 = rst ? 0 : ((0|WCH10_|CHWL11_) ? 1'b0 : 1'bz);
// Gate A17-U125B
pullup(g44204);
assign #GATE_DELAY g44204 = rst ? 0 : ((0|MANRmY|RCH31_) ? 1'b0 : 1'bz);
// Gate A17-U158A A17-U227A
pullup(CHOR02_);
assign #GATE_DELAY CHOR02_ = rst ? 1'bz : ((0|g44202|g44104|g44105|CH1402|CH1302|g44310) ? 1'b0 : 1'bz);
// Gate A17-U241A
pullup(g44421);
assign #GATE_DELAY g44421 = rst ? 0 : ((0|g44420|CCH10) ? 1'b0 : 1'bz);
// Gate A17-U127A
pullup(g44209);
assign #GATE_DELAY g44209 = rst ? 1'bz : ((0|g44210|g44208) ? 1'b0 : 1'bz);
// Gate A17-U116A
pullup(g44229);
assign #GATE_DELAY g44229 = rst ? 0 : ((0|GOJAM|TRP31B|g44228) ? 1'b0 : 1'bz);
// Gate A17-U117A
pullup(g44227);
assign #GATE_DELAY g44227 = rst ? 0 : ((0|WCH13_|CHWL13_) ? 1'b0 : 1'bz);
// Gate A17-U115A
pullup(g44228);
assign #GATE_DELAY g44228 = rst ? 1'bz : ((0|g44227|g44229) ? 1'b0 : 1'bz);
// Gate A17-U211B
pullup(g44338);
assign #GATE_DELAY g44338 = rst ? 1'bz : ((0|g44339|g44337) ? 1'b0 : 1'bz);
// Gate A17-U115B
pullup(g44216);
assign #GATE_DELAY g44216 = rst ? 0 : ((0|TRANpX|RCH31_) ? 1'b0 : 1'bz);
// Gate A17-U255B
pullup(g44449);
assign #GATE_DELAY g44449 = rst ? 0 : ((0|GOJAM|g44448) ? 1'b0 : 1'bz);
// Gate A17-U131A A17-U132A A17-U132B
pullup(RCH30_);
assign #GATE_DELAY RCH30_ = rst ? 1'bz : ((0|g44145) ? 1'b0 : 1'bz);
// Gate A17-U204B
pullup(RLYB10);
assign #GATE_DELAY RLYB10 = rst ? 0 : ((0|g44356) ? 1'b0 : 1'bz);
// Gate A17-U231A
pullup(RLYB11);
assign #GATE_DELAY RLYB11 = rst ? 0 : ((0|g44402) ? 1'b0 : 1'bz);
// Gate A17-U126A
pullup(g44208);
assign #GATE_DELAY g44208 = rst ? 0 : ((0|F05A_|g44206|g44213) ? 1'b0 : 1'bz);
// Gate A17-U130B
pullup(g44213);
assign #GATE_DELAY g44213 = rst ? 1'bz : ((0|g44214|g44212) ? 1'b0 : 1'bz);
// Gate A17-U245A
pullup(g44428);
assign #GATE_DELAY g44428 = rst ? 0 : ((0|RCH10_|g44426) ? 1'b0 : 1'bz);
// Gate A17-U126B
pullup(g44203);
assign #GATE_DELAY g44203 = rst ? 0 : ((0|MANRpY|RCH31_) ? 1'b0 : 1'bz);
// Gate A17-U159A A17-U227B
pullup(CHOR01_);
assign #GATE_DELAY CHOR01_ = rst ? 1'bz : ((0|g44201|g44101|g44102|g44304|CH1301|CH1401) ? 1'b0 : 1'bz);
// Gate A17-U245B
pullup(g44431);
assign #GATE_DELAY g44431 = rst ? 0 : ((0|XB0_|WCHG_|XT1_) ? 1'b0 : 1'bz);
// Gate A17-U230A
pullup(g44302);
assign #GATE_DELAY g44302 = rst ? 1'bz : ((0|g44301|g44303) ? 1'b0 : 1'bz);
// Gate A17-U125A
pullup(TRP31A);
assign #GATE_DELAY TRP31A = rst ? 0 : ((0|F05B_|g44209) ? 1'b0 : 1'bz);
// Gate A17-U119A
pullup(TRP31B);
assign #GATE_DELAY TRP31B = rst ? 0 : ((0|F05B_|g44224) ? 1'b0 : 1'bz);
// Gate A17-U151B
pullup(g44128);
assign #GATE_DELAY g44128 = rst ? 0 : ((0|RCH30_|CTLSAT) ? 1'b0 : 1'bz);
// Gate A17-U226A
pullup(g44310);
assign #GATE_DELAY g44310 = rst ? 0 : ((0|g44308|RCH10_) ? 1'b0 : 1'bz);
// Gate A17-U204A
pullup(g44352);
assign #GATE_DELAY g44352 = rst ? 0 : ((0|g44350|RCH10_) ? 1'b0 : 1'bz);
// Gate A17-U235B
pullup(g44408);
assign #GATE_DELAY g44408 = rst ? 1'bz : ((0|g44407|g44409) ? 1'b0 : 1'bz);
// Gate A17-U233A
pullup(g44404);
assign #GATE_DELAY g44404 = rst ? 0 : ((0|RCH10_|g44402) ? 1'b0 : 1'bz);
// Gate A17-U129A
pullup(g44214);
assign #GATE_DELAY g44214 = rst ? 0 : ((0|CHWL12_|WCH13_) ? 1'b0 : 1'bz);
// Gate A17-U129B
pullup(g44201);
assign #GATE_DELAY g44201 = rst ? 0 : ((0|RCH31_|MANRpP) ? 1'b0 : 1'bz);
// Gate A17-U206A
pullup(RLYB09);
assign #GATE_DELAY RLYB09 = rst ? 0 : ((0|g44350) ? 1'b0 : 1'bz);
// Gate A17-U210B
pullup(RLYB08);
assign #GATE_DELAY RLYB08 = rst ? 0 : ((0|g44344) ? 1'b0 : 1'bz);
// Gate A17-U248B
pullup(g44435);
assign #GATE_DELAY g44435 = rst ? 0 : ((0|XT1_|XB0_|CCHG_) ? 1'b0 : 1'bz);
// Gate A17-U260A
pullup(g44463);
assign #GATE_DELAY g44463 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A17-U149A A17-U203A
pullup(CHOR09_);
assign #GATE_DELAY CHOR09_ = rst ? 1'bz : ((0|g44218|g44125|g44126|CH1309|CH1409|g44352) ? 1'b0 : 1'bz);
// Gate A17-U229A
pullup(g44303);
assign #GATE_DELAY g44303 = rst ? 0 : ((0|g44302|CCH10) ? 1'b0 : 1'bz);
// Gate A17-U224A
pullup(RLYB03);
assign #GATE_DELAY RLYB03 = rst ? 0 : ((0|g44314) ? 1'b0 : 1'bz);
// Gate A17-U228B
pullup(RLYB02);
assign #GATE_DELAY RLYB02 = rst ? 0 : ((0|g44308) ? 1'b0 : 1'bz);
// Gate A17-U218A
pullup(RLYB05);
assign #GATE_DELAY RLYB05 = rst ? 0 : ((0|g44326) ? 1'b0 : 1'bz);
// Gate A17-U222B
pullup(RLYB04);
assign #GATE_DELAY RLYB04 = rst ? 0 : ((0|g44320) ? 1'b0 : 1'bz);
// Gate A17-U212A
pullup(RLYB07);
assign #GATE_DELAY RLYB07 = rst ? 0 : ((0|g44338) ? 1'b0 : 1'bz);
// Gate A17-U216B
pullup(RLYB06);
assign #GATE_DELAY RLYB06 = rst ? 0 : ((0|g44332) ? 1'b0 : 1'bz);
// Gate A17-U116B
pullup(g44223);
assign #GATE_DELAY g44223 = rst ? 0 : ((0|g44228|F05A_|g44221) ? 1'b0 : 1'bz);
// Gate A17-U229B
pullup(RLYB01);
assign #GATE_DELAY RLYB01 = rst ? 0 : ((0|g44302) ? 1'b0 : 1'bz);
// Gate A17-U212B
pullup(g44337);
assign #GATE_DELAY g44337 = rst ? 0 : ((0|WCH10_|CHWL07_) ? 1'b0 : 1'bz);
// Gate A17-U147B
pullup(g44119);
assign #GATE_DELAY g44119 = rst ? 0 : ((0|RCH30_|OPCDFL) ? 1'b0 : 1'bz);
// Gate A17-U147A
pullup(g44120);
assign #GATE_DELAY g44120 = rst ? 0 : ((0|RCH33_|STRPRS) ? 1'b0 : 1'bz);
// Gate A17-U211A
pullup(g44339);
assign #GATE_DELAY g44339 = rst ? 0 : ((0|g44338|CCH10) ? 1'b0 : 1'bz);
// Gate A17-U257B
pullup(g44453);
assign #GATE_DELAY g44453 = rst ? 0 : ((0|XT1_|XB1_) ? 1'b0 : 1'bz);
// Gate A17-U114A
pullup(g44224);
assign #GATE_DELAY g44224 = rst ? 1'bz : ((0|g44223|g44225) ? 1'b0 : 1'bz);
// Gate A17-U143B
pullup(g44157);
assign #GATE_DELAY g44157 = rst ? 0 : ((0|XT3_|XB3_) ? 1'b0 : 1'bz);
// Gate A17-U112A
pullup(g44225);
assign #GATE_DELAY g44225 = rst ? 0 : ((0|F05D|g44221|g44224) ? 1'b0 : 1'bz);
// Gate A17-U120A A17-U113B
pullup(g44221);
assign #GATE_DELAY g44221 = rst ? 1'bz : ((0|TRANmY|TRANmZ|TRANpZ|TRANpY|TRANpX|TRANmX) ? 1'b0 : 1'bz);
// Gate A17-U124B
pullup(g44250);
assign #GATE_DELAY g44250 = rst ? 0 : ((0|g44255|g44247|F05A_) ? 1'b0 : 1'bz);
// Gate A17-U143A
pullup(g44131);
assign #GATE_DELAY g44131 = rst ? 0 : ((0|RCH32_|LEMATT) ? 1'b0 : 1'bz);
// Gate A17-U232A
pullup(g44403);
assign #GATE_DELAY g44403 = rst ? 0 : ((0|CCH10|g44402) ? 1'b0 : 1'bz);
// Gate A17-U112B
pullup(g44232);
assign #GATE_DELAY g44232 = rst ? 0 : ((0|TRANmZ|RCH31_) ? 1'b0 : 1'bz);
// Gate A17-U260B
pullup(g44464);
assign #GATE_DELAY g44464 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A17-U134B
pullup(g44149);
assign #GATE_DELAY g44149 = rst ? 0 : ((0|XB1_|XT3_) ? 1'b0 : 1'bz);
// Gate A17-U157A
pullup(g44108);
assign #GATE_DELAY g44108 = rst ? 0 : ((0|RCH33_|RRRLSC) ? 1'b0 : 1'bz);
// Gate A17-U238A
pullup(g44415);
assign #GATE_DELAY g44415 = rst ? 0 : ((0|g44414|CCH10) ? 1'b0 : 1'bz);
// Gate A17-U157B
pullup(g44107);
assign #GATE_DELAY g44107 = rst ? 0 : ((0|RCH30_|SPSRDY) ? 1'b0 : 1'bz);
// Gate A17-U148A A17-U209B
pullup(CHOR08_);
assign #GATE_DELAY CHOR08_ = rst ? 1'bz : ((0|g44123|g44122|g44217|CH1408|g44346|CH1308) ? 1'b0 : 1'bz);
// Gate A17-U241B
pullup(g44420);
assign #GATE_DELAY g44420 = rst ? 1'bz : ((0|g44419|g44421) ? 1'b0 : 1'bz);
// Gate A17-U102B
pullup(CH3316);
assign #GATE_DELAY CH3316 = rst ? 0 : ((0|RCH33_|OSCALM) ? 1'b0 : 1'bz);
// Gate A17-U141A A17-U234B
pullup(CHOR12_);
assign #GATE_DELAY CHOR12_ = rst ? 1'bz : ((0|g44232|g44134|g44133|CH3312|CH1412|g44410) ? 1'b0 : 1'bz);
// Gate A17-U101A
pullup(CH3314);
assign #GATE_DELAY CH3314 = rst ? 0 : ((0|AGCWAR|RCH33_) ? 1'b0 : 1'bz);
// Gate A17-U236A
pullup(g44410);
assign #GATE_DELAY g44410 = rst ? 0 : ((0|g44408|RCH10_) ? 1'b0 : 1'bz);
// Gate A17-U101B
pullup(CH3313);
assign #GATE_DELAY CH3313 = rst ? 0 : ((0|RCH33_|PIPAFL) ? 1'b0 : 1'bz);
// Gate A17-U216A
pullup(g44328);
assign #GATE_DELAY g44328 = rst ? 0 : ((0|g44326|RCH10_) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
