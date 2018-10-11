// Verilog module auto-generated for AGC module A6 by dumbVerilog.py

module A6 ( 
  rst, AD0, ADS0, AUG0_, B15X, BR1, BR12B_, BR1B2B, BR1B2B_, BR1B2_, BR1_,
  BR2_, CCS0, CCS0_, CDUSTB_, CGA6, DAS0, DAS1, DAS1_, DCA0, DCS0, DIM0_,
  DINC, DINC_, DIVSTG, DV0, DV1376, DV1376_, DV376_, DV4B1B, DV4_, DXCH0,
  FETCH1, GOJAM, IC11, IC15, IC17, IC6, IC7, IC9, INCR0, INKL, INOTLD, L01_,
  L02A_, L15A_, MASK0, MCDU, MINC, MON_, MONpCH, MP0T10, MP1, MP1_, MP3_,
  MSU0, NDXX1_, P01, P04, P05_, PCDU, PHS4_, PINC, PRINC, PTWOX, R15, R6,
  RADRG, RADRZ, RAND0, RBSQ, RRPA, RSTK_, RUPT0, RUPT1, S01, S01_, S02, S02_,
  S03, S03_, S04, S04_, S05, S05_, S06, S06_, S07, S07_, SHIFT, STBE, STBF,
  STFET1_, STOP_, STRT2, SU0, T01, T01_, T02, T02_, T03, T03_, T04, T04_,
  T05, T06, T06_, T07, T07_, T08, T08_, T09, T10, T10_, T11, T11_, T12, T12USE_,
  TL15, WAND0, d10XP1, d10XP8, d11XP2, d1XP10, d2XP3, d2XP5, d2XP7, d2XP8,
  d3XP2, d3XP6, d3XP7, d4XP11, d5XP12, d5XP15, d5XP21, d5XP28, d5XP4, d6XP5,
  d6XP8, d7XP19, d7XP4, d7XP9, d8PP4, d8XP6, d9XP1, d9XP5, IL01, IL01_, IL02,
  IL02_, IL03, IL03_, IL04, IL04_, IL05, IL05_, IL06, IL06_, IL07, IL07_,
  MONEX_, RB_, RC_, RDBANK, RPTSET, RSTKX_, RSTKY_, RU_, ST2_, WG_, WSC_,
  WY_, ZIPCI, d2PP1, A2X_, BXVX, CGMC, CI_, CLXC, DVXP1, EXT, L2GD_, MCRO_,
  MONEX, MOUT, NEAC, PIFL_, PONEX, POUT, PSEUDO, R1C_, RB1F, RB1_, RCH_,
  RG_, RUS_, RZ_, ST1, ST2, TIMR, TOV_, TSGU_, TWOX, WA_, WB_, WL_, WOVR,
  WQ_, WS_, WYD_, WZ_, ZAP, ZAP_, ZIP, ZOUT, d7XP14
);

input wire rst, AD0, ADS0, AUG0_, B15X, BR1, BR12B_, BR1B2B, BR1B2B_, BR1B2_,
  BR1_, BR2_, CCS0, CCS0_, CDUSTB_, CGA6, DAS0, DAS1, DAS1_, DCA0, DCS0,
  DIM0_, DINC, DINC_, DIVSTG, DV0, DV1376, DV1376_, DV376_, DV4B1B, DV4_,
  DXCH0, FETCH1, GOJAM, IC11, IC15, IC17, IC6, IC7, IC9, INCR0, INKL, INOTLD,
  L01_, L02A_, L15A_, MASK0, MCDU, MINC, MON_, MONpCH, MP0T10, MP1, MP1_,
  MP3_, MSU0, NDXX1_, P01, P04, P05_, PCDU, PHS4_, PINC, PRINC, PTWOX, R15,
  R6, RADRG, RADRZ, RAND0, RBSQ, RRPA, RSTK_, RUPT0, RUPT1, S01, S01_, S02,
  S02_, S03, S03_, S04, S04_, S05, S05_, S06, S06_, S07, S07_, SHIFT, STBE,
  STBF, STFET1_, STOP_, STRT2, SU0, T01, T01_, T02, T02_, T03, T03_, T04,
  T04_, T05, T06, T06_, T07, T07_, T08, T08_, T09, T10, T10_, T11, T11_,
  T12, T12USE_, TL15, WAND0, d10XP1, d10XP8, d11XP2, d1XP10, d2XP3, d2XP5,
  d2XP7, d2XP8, d3XP2, d3XP6, d3XP7, d4XP11, d5XP12, d5XP15, d5XP21, d5XP28,
  d5XP4, d6XP5, d6XP8, d7XP19, d7XP4, d7XP9, d8PP4, d8XP6, d9XP1, d9XP5;

inout wire IL01, IL01_, IL02, IL02_, IL03, IL03_, IL04, IL04_, IL05, IL05_,
  IL06, IL06_, IL07, IL07_, MONEX_, RB_, RC_, RDBANK, RPTSET, RSTKX_, RSTKY_,
  RU_, ST2_, WG_, WSC_, WY_, ZIPCI, d2PP1;

output wire A2X_, BXVX, CGMC, CI_, CLXC, DVXP1, EXT, L2GD_, MCRO_, MONEX,
  MOUT, NEAC, PIFL_, PONEX, POUT, PSEUDO, R1C_, RB1F, RB1_, RCH_, RG_, RUS_,
  RZ_, ST1, ST2, TIMR, TOV_, TSGU_, TWOX, WA_, WB_, WL_, WOVR, WQ_, WS_,
  WYD_, WZ_, ZAP, ZAP_, ZIP, ZOUT, d7XP14;

// Gate A6-U232A A6-U233A
pullup(g40432);
assign #0.2  g40432 = rst ? 1'bz : ((0|A66XP10|d10XP8|d7XP4|d8XP6) ? 1'b0 : 1'bz);
// Gate A6-U103B
pullup(DVXP1);
assign #0.2  DVXP1 = rst ? 0 : ((0|g40105) ? 1'b0 : 1'bz);
// Gate A6-U254A A6-U248B
pullup(ST2_);
assign #0.2  ST2_ = rst ? 1'bz : ((0|g40413|A68XP4|RADRZ) ? 1'b0 : 1'bz);
// Gate A6-U160B
pullup(RB1F);
assign #0.2  RB1F = rst ? 0 : ((0|PHS4_|TSGU_|BR1_) ? 1'b0 : 1'bz);
// Gate A6-U119B
pullup(WL_);
assign #0.2  WL_ = rst ? 1'bz : ((0|d5XP12|g40138) ? 1'b0 : 1'bz);
// Gate A6-U103A
pullup(g40104);
assign #0.2  g40104 = rst ? 0 : ((0|T04_|DV4_) ? 1'b0 : 1'bz);
// Gate A6-U102B
pullup(g40103);
assign #0.2  g40103 = rst ? 0 : ((0|T01_|DV1376_) ? 1'b0 : 1'bz);
// Gate A6-U102A
pullup(g40105);
assign #0.2  g40105 = rst ? 1'bz : ((0|g40104|g40103|g40102) ? 1'b0 : 1'bz);
// Gate A6-U228A A6-U253A A6-U253B
pullup(d8PP4);
assign #0.2  d8PP4 = rst ? 1'bz : ((0|MSU0|DAS1|RUPT1|IC6|IC9|IC7|MASK0|IC11|IC17) ? 1'b0 : 1'bz);
// Gate A6-U222B
pullup(WOVR);
assign #0.2  WOVR = rst ? 0 : ((0|MONpCH|T07_|g40340) ? 1'b0 : 1'bz);
// Gate A6-U235B
pullup(EXT);
assign #0.2  EXT = rst ? 0 : ((0|NDXX1_|T10_) ? 1'b0 : 1'bz);
// Gate A6-U127B
pullup(g40149);
assign #0.2  g40149 = rst ? 1'bz : ((0|T03|T01) ? 1'b0 : 1'bz);
// Gate A6-U124A
pullup(g40151);
assign #0.2  g40151 = rst ? 0 : ((0|g40149|MP3_) ? 1'b0 : 1'bz);
// Gate A6-U144A A6-U144B
pullup(g40223);
assign #0.2  g40223 = rst ? 0 : ((0|RSTK_) ? 1'b0 : 1'bz);
// Gate A6-U116A
pullup(g40129);
assign #0.2  g40129 = rst ? 0 : ((0|g40114|g40127) ? 1'b0 : 1'bz);
// Gate A6-U137A
pullup(IL02_);
assign #0.2  IL02_ = rst ? 0 : ((0|S02_) ? 1'b0 : 1'bz);
// Gate A6-U124B
pullup(g40144);
assign #0.2  g40144 = rst ? 1'bz : ((0|g40143|DIVSTG) ? 1'b0 : 1'bz);
// Gate A6-U151B
pullup(g40213);
assign #0.2  g40213 = rst ? 1'bz : ((0|MONEX|PTWOX) ? 1'b0 : 1'bz);
// Gate A6-U149B
pullup(g40246);
assign #0.2  g40246 = rst ? 0 : ((0|g40247|P01) ? 1'b0 : 1'bz);
// Gate A6-U134B
pullup(g40254);
assign #0.2  g40254 = rst ? 0 : ((0|g40253) ? 1'b0 : 1'bz);
// Gate A6-U157A
pullup(TOV_);
assign #0.2  TOV_ = rst ? 1'bz : ((0|d6XP5|d3XP2|d9XP5) ? 1'b0 : 1'bz);
// Gate A6-U259A
pullup(g40438);
assign #0.2  g40438 = rst ? 0 : ((0|DAS1_|T03_|ADS0) ? 1'b0 : 1'bz);
// Gate A6-U242A
pullup(g40413);
assign #0.2  g40413 = rst ? 0 : ((0|MP1_|T10_) ? 1'b0 : 1'bz);
// Gate A6-U153A
pullup(g40217);
assign #0.2  g40217 = rst ? 0 : ((0|g40134) ? 1'b0 : 1'bz);
// Gate A6-U202A A6-U204B
pullup(g40306);
assign #0.2  g40306 = rst ? 1'bz : ((0|g40303|INCR0|g40302|g40307|PINC) ? 1'b0 : 1'bz);
// Gate A6-U158B
pullup(WZ_);
assign #0.2  WZ_ = rst ? 1'bz : ((0|d5XP4|RRPA) ? 1'b0 : 1'bz);
// Gate A6-U229B
pullup(g40355);
assign #0.2  g40355 = rst ? 0 : ((0|BR2_|DAS1_) ? 1'b0 : 1'bz);
// Gate A6-U111B
pullup(g40124);
assign #0.2  g40124 = rst ? 0 : ((0|g40120|g40122|g40121) ? 1'b0 : 1'bz);
// Gate A6-U105A
pullup(ZIP);
assign #0.2  ZIP = rst ? 0 : ((0|g40114) ? 1'b0 : 1'bz);
// Gate A6-U216A
pullup(A67XP7);
assign #0.2  A67XP7 = rst ? 0 : ((0|T07_|g40325) ? 1'b0 : 1'bz);
// Gate A6-U208B
pullup(g40314);
assign #0.2  g40314 = rst ? 0 : ((0|DINC_|BR1B2B_) ? 1'b0 : 1'bz);
// Gate A6-U111A
pullup(g40121);
assign #0.2  g40121 = rst ? 1'bz : ((0|L02A_) ? 1'b0 : 1'bz);
// Gate A6-U228B A6-U229A
pullup(g40353);
assign #0.2  g40353 = rst ? 1'bz : ((0|IC11|g40355|ADS0|CCS0|g40352) ? 1'b0 : 1'bz);
// Gate A6-U112B
pullup(g40122);
assign #0.2  g40122 = rst ? 1'bz : ((0|L15A_) ? 1'b0 : 1'bz);
// Gate A6-U209B
pullup(g40313);
assign #0.2  g40313 = rst ? 0 : ((0|DIM0_|BR1B2B_) ? 1'b0 : 1'bz);
// Gate A6-U208A
pullup(g40312);
assign #0.2  g40312 = rst ? 0 : ((0|BR1_|AUG0_) ? 1'b0 : 1'bz);
// Gate A6-U239B
pullup(g40407);
assign #0.2  g40407 = rst ? 1'bz : ((0|IC6|IC7) ? 1'b0 : 1'bz);
// Gate A6-U211A
pullup(ZOUT);
assign #0.2  ZOUT = rst ? 0 : ((0|BR2_|DINC_|CDUSTB_) ? 1'b0 : 1'bz);
// Gate A6-U238A
pullup(g40408);
assign #0.2  g40408 = rst ? 0 : ((0|T10_|g40407) ? 1'b0 : 1'bz);
// Gate A6-U133B
pullup(g40255);
assign #0.2  g40255 = rst ? 1'bz : ((0|g40254) ? 1'b0 : 1'bz);
// Gate A6-U133A
pullup(g40256);
assign #0.2  g40256 = rst ? 0 : ((0|g40255) ? 1'b0 : 1'bz);
// Gate A6-U249A
pullup(R1C_);
assign #0.2  R1C_ = rst ? 1'bz : ((0|g40334) ? 1'b0 : 1'bz);
// Gate A6-U211B
pullup(MOUT);
assign #0.2  MOUT = rst ? 0 : ((0|CDUSTB_|DINC_|BR12B_) ? 1'b0 : 1'bz);
// Gate A6-U132A
pullup(IL03_);
assign #0.2  IL03_ = rst ? 1'bz : ((0|S03_) ? 1'b0 : 1'bz);
// Gate A6-U123A
pullup(g40143);
assign #0.2  g40143 = rst ? 0 : ((0|g40142|T12USE_|DV376_) ? 1'b0 : 1'bz);
// Gate A6-U251A
pullup(NEAC);
assign #0.2  NEAC = rst ? 0 : ((0|TL15|g40426|GOJAM) ? 1'b0 : 1'bz);
// Gate A6-U153B
pullup(MONEX);
assign #0.2  MONEX = rst ? 0 : ((0|MONEX_) ? 1'b0 : 1'bz);
// Gate A6-U206A
pullup(g40310);
assign #0.2  g40310 = rst ? 0 : ((0|T06_|g40315) ? 1'b0 : 1'bz);
// Gate A6-U245B
pullup(RPTSET);
assign #0.2  RPTSET = rst ? 0 : ((0|PSEUDO) ? 1'b0 : 1'bz);
// Gate A6-U151A
pullup(TWOX);
assign #0.2  TWOX = rst ? 0 : ((0|g40213) ? 1'b0 : 1'bz);
// Gate A6-U219A
pullup(g40334);
assign #0.2  g40334 = rst ? 0 : ((0|DAS1_|T07_|BR12B_) ? 1'b0 : 1'bz);
// Gate A6-U117B
pullup(g40136);
assign #0.2  g40136 = rst ? 0 : ((0|DV1376_|T02_) ? 1'b0 : 1'bz);
// Gate A6-U129B
pullup(ZAP);
assign #0.2  ZAP = rst ? 0 : ((0|ZAP_) ? 1'b0 : 1'bz);
// Gate A6-U216B
pullup(d7XP14);
assign #0.2  d7XP14 = rst ? 0 : ((0|T07_|g40329) ? 1'b0 : 1'bz);
// Gate A6-U209A
pullup(g40317);
assign #0.2  g40317 = rst ? 0 : ((0|g40318|T06_) ? 1'b0 : 1'bz);
// Gate A6-U127A
pullup(MCRO_);
assign #0.2  MCRO_ = rst ? 1'bz : ((0|g40129) ? 1'b0 : 1'bz);
// Gate A6-U128A
pullup(g40150);
assign #0.2  g40150 = rst ? 0 : ((0|MP1_|g40147) ? 1'b0 : 1'bz);
// Gate A6-U235A
pullup(g40411);
assign #0.2  g40411 = rst ? 0 : ((0|CCS0_|BR12B_) ? 1'b0 : 1'bz);
// Gate A6-U120A A6-U121A
pullup(RG_);
assign #0.2  RG_ = rst ? 1'bz : ((0|d5XP4|RADRG|d5XP28|g40138) ? 1'b0 : 1'bz);
// Gate A6-U154A
pullup(g40221);
assign #0.2  g40221 = rst ? 1'bz : ((0|PIFL_|T02|g40217) ? 1'b0 : 1'bz);
// Gate A6-U155B A6-U224B
pullup(WSC_);
assign #0.2  WSC_ = rst ? 1'bz : ((0|d6XP8|d9XP5|WOVR|g40330|g40346) ? 1'b0 : 1'bz);
// Gate A6-U134A
pullup(g40257);
assign #0.2  g40257 = rst ? 1'bz : ((0|g40256) ? 1'b0 : 1'bz);
// Gate A6-U220A A6-U221A
pullup(g40339);
assign #0.2  g40339 = rst ? 1'bz : ((0|PRINC|PINC|MINC|DINC) ? 1'b0 : 1'bz);
// Gate A6-U131B
pullup(IL07_);
assign #0.2  IL07_ = rst ? 1'bz : ((0|S07_) ? 1'b0 : 1'bz);
// Gate A6-U150B
pullup(g40215);
assign #0.2  g40215 = rst ? 1'bz : ((0|B15X|g40212) ? 1'b0 : 1'bz);
// Gate A6-U210A
pullup(POUT);
assign #0.2  POUT = rst ? 0 : ((0|CDUSTB_|BR1B2B_|DINC_) ? 1'b0 : 1'bz);
// Gate A6-U135B
pullup(g40253);
assign #0.2  g40253 = rst ? 1'bz : ((0|g40245) ? 1'b0 : 1'bz);
// Gate A6-U227B A6-U256B
pullup(A68XP10);
assign #0.2  A68XP10 = rst ? 0 : ((0|RUPT0|T08_|DAS0|DV1376|MP1) ? 1'b0 : 1'bz);
// Gate A6-U152A A6-U152B
pullup(g40212);
assign #0.2  g40212 = rst ? 0 : ((0|MONEX_) ? 1'b0 : 1'bz);
// Gate A6-U250B
pullup(RUS_);
assign #0.2  RUS_ = rst ? 1'bz : ((0|g40337|d7XP9|d11XP2) ? 1'b0 : 1'bz);
// Gate A6-U122B
pullup(g40135);
assign #0.2  g40135 = rst ? 0 : ((0|DV376_|g40134) ? 1'b0 : 1'bz);
// Gate A6-U214A
pullup(g40324);
assign #0.2  g40324 = rst ? 0 : ((0|DV4_|BR1B2B) ? 1'b0 : 1'bz);
// Gate A6-U240A
pullup(g40405);
assign #0.2  g40405 = rst ? 0 : ((0|CCS0_|BR1B2B_) ? 1'b0 : 1'bz);
// Gate A6-U236B A6-U240B
pullup(g40409);
assign #0.2  g40409 = rst ? 1'bz : ((0|DV4B1B|g40411|DCS0|IC7|SU0) ? 1'b0 : 1'bz);
// Gate A6-U139A
pullup(IL01_);
assign #0.2  IL01_ = rst ? 1'bz : ((0|S01_) ? 1'b0 : 1'bz);
// Gate A6-U155A A6-U223A
pullup(WG_);
assign #0.2  WG_ = rst ? 1'bz : ((0|d6XP8|g40346|WOVR) ? 1'b0 : 1'bz);
// Gate A6-U117A
pullup(RCH_);
assign #0.2  RCH_ = rst ? 1'bz : ((0|d4XP11|d5XP21|d3XP7) ? 1'b0 : 1'bz);
// Gate A6-U107A
pullup(g40114);
assign #0.2  g40114 = rst ? 1'bz : ((0|g40113|d2XP7) ? 1'b0 : 1'bz);
// Gate A6-U146A A6-U146B
pullup(TIMR);
assign #0.2  TIMR = rst ? 1'bz : ((0|g40250) ? 1'b0 : 1'bz);
// Gate A6-U213A
pullup(g40323);
assign #0.2  g40323 = rst ? 1'bz : ((0|DAS1|MSU0|DAS0) ? 1'b0 : 1'bz);
// Gate A6-U142A
pullup(g40242);
assign #0.2  g40242 = rst ? 1'bz : ((0|g40243|CGMC) ? 1'b0 : 1'bz);
// Gate A6-U234A
pullup(A610XP9);
assign #0.2  A610XP9 = rst ? 0 : ((0|g40401|T10_) ? 1'b0 : 1'bz);
// Gate A6-U213B
pullup(g40326);
assign #0.2  g40326 = rst ? 0 : ((0|g40323|T07_) ? 1'b0 : 1'bz);
// Gate A6-U149A
pullup(g40247);
assign #0.2  g40247 = rst ? 1'bz : ((0|STOP_|g40246) ? 1'b0 : 1'bz);
// Gate A6-U143B
pullup(g40240);
assign #0.2  g40240 = rst ? 1'bz : ((0|d1XP10|STBF|STBE) ? 1'b0 : 1'bz);
// Gate A6-U238B
pullup(g40437);
assign #0.2  g40437 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A6-U205A A6-U207A
pullup(g40315);
assign #0.2  g40315 = rst ? 1'bz : ((0|MCDU|MINC|g40313|g40312|g40314) ? 1'b0 : 1'bz);
// Gate A6-U105B
pullup(L2GD_);
assign #0.2  L2GD_ = rst ? 1'bz : ((0|ZIP|DVXP1) ? 1'b0 : 1'bz);
// Gate A6-U141A
pullup(g40245);
assign #0.2  g40245 = rst ? 0 : ((0|g40244) ? 1'b0 : 1'bz);
// Gate A6-U214B
pullup(g40325);
assign #0.2  g40325 = rst ? 1'bz : ((0|g40324|RAND0|WAND0) ? 1'b0 : 1'bz);
// Gate A6-U108A
pullup(WY_);
assign #0.2  WY_ = rst ? 1'bz : ((0|g40115) ? 1'b0 : 1'bz);
// Gate A6-U135A
pullup(g40258);
assign #0.2  g40258 = rst ? 0 : ((0|g40257) ? 1'b0 : 1'bz);
// Gate A6-U249B
pullup(PSEUDO);
assign #0.2  PSEUDO = rst ? 0 : ((0|RADRG|g40439|GOJAM) ? 1'b0 : 1'bz);
// Gate A6-U230A
pullup(g40354);
assign #0.2  g40354 = rst ? 0 : ((0|T11_|g40353) ? 1'b0 : 1'bz);
// Gate A6-U225B
pullup(g40346);
assign #0.2  g40346 = rst ? 0 : ((0|T07_|g40345) ? 1'b0 : 1'bz);
// Gate A6-U218A
pullup(g40333);
assign #0.2  g40333 = rst ? 0 : ((0|T07_|DAS1_|BR1B2_) ? 1'b0 : 1'bz);
// Gate A6-U241B
pullup(g40410);
assign #0.2  g40410 = rst ? 0 : ((0|g40409|T10_) ? 1'b0 : 1'bz);
// Gate A6-U218B
pullup(g40335);
assign #0.2  g40335 = rst ? 1'bz : ((0|PCDU|MCDU|SHIFT) ? 1'b0 : 1'bz);
// Gate A6-U138A
pullup(IL05_);
assign #0.2  IL05_ = rst ? 1'bz : ((0|S05_) ? 1'b0 : 1'bz);
// Gate A6-U205B
pullup(g40307);
assign #0.2  g40307 = rst ? 0 : ((0|DINC_|BR12B_) ? 1'b0 : 1'bz);
// Gate A6-U206B
pullup(MONEX_);
assign #0.2  MONEX_ = rst ? 1'bz : ((0|g40310) ? 1'b0 : 1'bz);
// Gate A6-U110B
pullup(g40118);
assign #0.2  g40118 = rst ? 0 : ((0|g40116|g40114) ? 1'b0 : 1'bz);
// Gate A6-U116B
pullup(g40128);
assign #0.2  g40128 = rst ? 0 : ((0|g40123|g40124|g40114) ? 1'b0 : 1'bz);
// Gate A6-U154B
pullup(PIFL_);
assign #0.2  PIFL_ = rst ? 0 : ((0|DVXP1|g40221) ? 1'b0 : 1'bz);
// Gate A6-U145A
pullup(RSTKY_);
assign #0.2  RSTKY_ = rst ? 1'bz : ((0|g40223) ? 1'b0 : 1'bz);
// Gate A6-U118B
pullup(g40134);
assign #0.2  g40134 = rst ? 1'bz : ((0|T11|T05|T08) ? 1'b0 : 1'bz);
// Gate A6-U106A
pullup(g40113);
assign #0.2  g40113 = rst ? 0 : ((0|MP1_|g40112) ? 1'b0 : 1'bz);
// Gate A6-U225A
pullup(g40345);
assign #0.2  g40345 = rst ? 1'bz : ((0|DXCH0|IC9) ? 1'b0 : 1'bz);
// Gate A6-U120B A6-U123B
pullup(g40147);
assign #0.2  g40147 = rst ? 1'bz : ((0|T08|T10|T06|T04|T02) ? 1'b0 : 1'bz);
// Gate A6-U141B
pullup(g40244);
assign #0.2  g40244 = rst ? 1'bz : ((0|g40243) ? 1'b0 : 1'bz);
// Gate A6-U109A
pullup(g40115);
assign #0.2  g40115 = rst ? 0 : ((0|g40114|g40125|g40126) ? 1'b0 : 1'bz);
// Gate A6-U226B
pullup(A68XP4);
assign #0.2  A68XP4 = rst ? 0 : ((0|d8PP4|T08_) ? 1'b0 : 1'bz);
// Gate A6-U142B
pullup(g40243);
assign #0.2  g40243 = rst ? 0 : ((0|g40242|g40240) ? 1'b0 : 1'bz);
// Gate A6-U148A A6-U147B
pullup(g40248);
assign #0.2  g40248 = rst ? 0 : ((0|STOP_|g40246|P04|P05_) ? 1'b0 : 1'bz);
// Gate A6-U125A
pullup(g40145);
assign #0.2  g40145 = rst ? 0 : ((0|g40144) ? 1'b0 : 1'bz);
// Gate A6-U254B
pullup(d2PP1);
assign #0.2  d2PP1 = rst ? 1'bz : ((0|IC15|DV0|DV1376) ? 1'b0 : 1'bz);
// Gate A6-U157B
pullup(WQ_);
assign #0.2  WQ_ = rst ? 1'bz : ((0|d3XP6|d5XP15) ? 1'b0 : 1'bz);
// Gate A6-U136B
pullup(IL06_);
assign #0.2  IL06_ = rst ? 1'bz : ((0|S06_) ? 1'b0 : 1'bz);
// Gate A6-U128B
pullup(ZAP_);
assign #0.2  ZAP_ = rst ? 1'bz : ((0|g40151|g40150) ? 1'b0 : 1'bz);
// Gate A6-U210B
pullup(g40318);
assign #0.2  g40318 = rst ? 1'bz : ((0|MCDU|PCDU) ? 1'b0 : 1'bz);
// Gate A6-U106B
pullup(WYD_);
assign #0.2  WYD_ = rst ? 1'bz : ((0|DVXP1|g40118) ? 1'b0 : 1'bz);
// Gate A6-U107B A6-U108B
pullup(g40112);
assign #0.2  g40112 = rst ? 1'bz : ((0|T01|T03|T05|T07|T11|T09) ? 1'b0 : 1'bz);
// Gate A6-U256A A6-U246A
pullup(g40422);
assign #0.2  g40422 = rst ? 1'bz : ((0|d2XP8|d10XP1|MP0T10|g40413) ? 1'b0 : 1'bz);
// Gate A6-U143A
pullup(CGMC);
assign #0.2  CGMC = rst ? 0 : ((0|g40240|g40258) ? 1'b0 : 1'bz);
// Gate A6-U129A A6-U126B A6-U223B A6-U204A
pullup(RU_);
assign #0.2  RU_ = rst ? 1'bz : ((0|ZAP|g40145|d6XP5|d5XP12|g40338|g40438|g40354|RDBANK) ? 1'b0 : 1'bz);
// Gate A6-U203B
pullup(A66XP10);
assign #0.2  A66XP10 = rst ? 0 : ((0|g40306|T06_) ? 1'b0 : 1'bz);
// Gate A6-U145B
pullup(RSTKX_);
assign #0.2  RSTKX_ = rst ? 1'bz : ((0|g40223) ? 1'b0 : 1'bz);
// Gate A6-U122A
pullup(g40137);
assign #0.2  g40137 = rst ? 1'bz : ((0|g40135|g40136) ? 1'b0 : 1'bz);
// Gate A6-U160A A6-U159A A6-U159B
pullup(CLXC);
assign #0.2  CLXC = rst ? 0 : ((0|TSGU_|BR1|PHS4_) ? 1'b0 : 1'bz);
// Gate A6-U115A A6-U245A
pullup(RC_);
assign #0.2  RC_ = rst ? 1'bz : ((0|ZIPCI|d3XP7|A67XP7|g40410) ? 1'b0 : 1'bz);
// Gate A6-U101A
pullup(g40102);
assign #0.2  g40102 = rst ? 0 : ((0|DV376_|g40101) ? 1'b0 : 1'bz);
// Gate A6-U125B A6-U126A
pullup(WB_);
assign #0.2  WB_ = rst ? 1'bz : ((0|d5XP28|d1XP10|g40145|d2XP3) ? 1'b0 : 1'bz);
// Gate A6-U101B
pullup(g40101);
assign #0.2  g40101 = rst ? 1'bz : ((0|T07|T04|T10) ? 1'b0 : 1'bz);
// Gate A6-U147A
pullup(g40250);
assign #0.2  g40250 = rst ? 0 : ((0|STRT2|g40248) ? 1'b0 : 1'bz);
// Gate A6-U202B
pullup(g40303);
assign #0.2  g40303 = rst ? 0 : ((0|DIM0_|BR12B_) ? 1'b0 : 1'bz);
// Gate A6-U251B
pullup(g40426);
assign #0.2  g40426 = rst ? 1'bz : ((0|MP0T10|NEAC) ? 1'b0 : 1'bz);
// Gate A6-U140A
pullup(IL04_);
assign #0.2  IL04_ = rst ? 1'bz : ((0|S04_) ? 1'b0 : 1'bz);
// Gate A6-U239A
pullup(CI_);
assign #0.2  CI_ = rst ? 1'bz : ((0|g40317|ZIPCI) ? 1'b0 : 1'bz);
// Gate A6-U257A
pullup(WS_);
assign #0.2  WS_ = rst ? 1'bz : ((0|A68XP10|R15|R6) ? 1'b0 : 1'bz);
// Gate A6-U227A
pullup(g40352);
assign #0.2  g40352 = rst ? 0 : ((0|MP3_|BR1_) ? 1'b0 : 1'bz);
// Gate A6-U230B
pullup(RDBANK);
assign #0.2  RDBANK = rst ? 0 : ((0|T06_|STFET1_) ? 1'b0 : 1'bz);
// Gate A6-U250A
pullup(g40439);
assign #0.2  g40439 = rst ? 1'bz : ((0|PSEUDO|RADRZ) ? 1'b0 : 1'bz);
// Gate A6-U115B
pullup(ZIPCI);
assign #0.2  ZIPCI = rst ? 0 : ((0|g40133|g40127|g40114) ? 1'b0 : 1'bz);
// Gate A6-U138B
pullup(IL02);
assign #0.2  IL02 = rst ? 1'bz : ((0|S02) ? 1'b0 : 1'bz);
// Gate A6-U140B
pullup(IL01);
assign #0.2  IL01 = rst ? 0 : ((0|S01) ? 1'b0 : 1'bz);
// Gate A6-U132B
pullup(IL07);
assign #0.2  IL07 = rst ? 0 : ((0|S07) ? 1'b0 : 1'bz);
// Gate A6-U137B
pullup(IL06);
assign #0.2  IL06 = rst ? 0 : ((0|S06) ? 1'b0 : 1'bz);
// Gate A6-U139B
pullup(IL05);
assign #0.2  IL05 = rst ? 0 : ((0|S05) ? 1'b0 : 1'bz);
// Gate A6-U131A
pullup(IL04);
assign #0.2  IL04 = rst ? 0 : ((0|S04) ? 1'b0 : 1'bz);
// Gate A6-U113A
pullup(g40133);
assign #0.2  g40133 = rst ? 1'bz : ((0|L02A_|L01_|L15A_) ? 1'b0 : 1'bz);
// Gate A6-U247B
pullup(ST1);
assign #0.2  ST1 = rst ? 0 : ((0|g40422) ? 1'b0 : 1'bz);
// Gate A6-U248A
pullup(ST2);
assign #0.2  ST2 = rst ? 0 : ((0|ST2_) ? 1'b0 : 1'bz);
// Gate A6-U104B
pullup(A2X_);
assign #0.2  A2X_ = rst ? 1'bz : ((0|DVXP1|ZIP|d7XP19) ? 1'b0 : 1'bz);
// Gate A6-U217A
pullup(g40329);
assign #0.2  g40329 = rst ? 1'bz : ((0|INOTLD|WAND0) ? 1'b0 : 1'bz);
// Gate A6-U104A A6-U224A
pullup(RB_);
assign #0.2  RB_ = rst ? 1'bz : ((0|RBSQ|g40128|DVXP1|g40346|A610XP9) ? 1'b0 : 1'bz);
// Gate A6-U219B
pullup(g40338);
assign #0.2  g40338 = rst ? 0 : ((0|T07_|g40339) ? 1'b0 : 1'bz);
// Gate A6-U121B
pullup(g40142);
assign #0.2  g40142 = rst ? 0 : ((0|T09|T12|T06) ? 1'b0 : 1'bz);
// Gate A6-U236A A6-U234B
pullup(g40401);
assign #0.2  g40401 = rst ? 1'bz : ((0|g40405|AD0|DCA0|IC6) ? 1'b0 : 1'bz);
// Gate A6-U222A
pullup(g40340);
assign #0.2  g40340 = rst ? 0 : ((0|PRINC|INKL) ? 1'b0 : 1'bz);
// Gate A6-U233B
pullup(PONEX);
assign #0.2  PONEX = rst ? 0 : ((0|g40432) ? 1'b0 : 1'bz);
// Gate A6-U242B
pullup(RZ_);
assign #0.2  RZ_ = rst ? 1'bz : ((0|A68XP4|d9XP1|RADRZ) ? 1'b0 : 1'bz);
// Gate A6-U110A
pullup(g40120);
assign #0.2  g40120 = rst ? 1'bz : ((0|L01_) ? 1'b0 : 1'bz);
// Gate A6-U241A A6-U215B
pullup(WA_);
assign #0.2  WA_ = rst ? 1'bz : ((0|g40438|g40408|d2XP5|A67XP7|g40326|g40354) ? 1'b0 : 1'bz);
// Gate A6-U112A
pullup(g40125);
assign #0.2  g40125 = rst ? 0 : ((0|g40122|L02A_|g40120) ? 1'b0 : 1'bz);
// Gate A6-U201A
pullup(g40302);
assign #0.2  g40302 = rst ? 0 : ((0|AUG0_|BR1) ? 1'b0 : 1'bz);
// Gate A6-U220B
pullup(g40337);
assign #0.2  g40337 = rst ? 0 : ((0|g40335|T07_) ? 1'b0 : 1'bz);
// Gate A6-U113B
pullup(g40126);
assign #0.2  g40126 = rst ? 0 : ((0|g40121|L15A_|L01_) ? 1'b0 : 1'bz);
// Gate A6-U109B
pullup(g40116);
assign #0.2  g40116 = rst ? 1'bz : ((0|g40126|g40125) ? 1'b0 : 1'bz);
// Gate A6-U136A
pullup(IL03);
assign #0.2  IL03 = rst ? 0 : ((0|S03) ? 1'b0 : 1'bz);
// Gate A6-U217B
pullup(g40330);
assign #0.2  g40330 = rst ? 0 : ((0|MON_|T04_|FETCH1) ? 1'b0 : 1'bz);
// Gate A6-U114B
pullup(g40127);
assign #0.2  g40127 = rst ? 0 : ((0|g40123) ? 1'b0 : 1'bz);
// Gate A6-U150A
pullup(BXVX);
assign #0.2  BXVX = rst ? 0 : ((0|g40215) ? 1'b0 : 1'bz);
// Gate A6-U118A
pullup(g40138);
assign #0.2  g40138 = rst ? 0 : ((0|g40137) ? 1'b0 : 1'bz);
// Gate A6-U119A A6-U158A
pullup(TSGU_);
assign #0.2  TSGU_ = rst ? 1'bz : ((0|d5XP28|g40138) ? 1'b0 : 1'bz);
// Gate A6-U114A
pullup(g40123);
assign #0.2  g40123 = rst ? 1'bz : ((0|L02A_|g40126|g40125) ? 1'b0 : 1'bz);
// Gate A6-U247A
pullup(RB1_);
assign #0.2  RB1_ = rst ? 1'bz : ((0|g40333) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
