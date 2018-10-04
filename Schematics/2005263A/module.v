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
pullup(A6U232Pad1);
assign (highz1,strong0) #0.2  A6U232Pad1 = rst ? 1 : ~(0|A6P10|d10XP8|d7XP4|d8XP6);
// Gate A6-U103B
pullup(DVXP1);
assign (highz1,strong0) #0.2  DVXP1 = rst ? 0 : ~(0|A6U102Pad1);
// Gate A6-U254A A6-U248B
pullup(ST2_);
assign (highz1,strong0) #0.2  ST2_ = rst ? 1 : ~(0|A6U242Pad1|A6P4|RADRZ);
// Gate A6-U160B
pullup(RB1F);
assign (highz1,strong0) #0.2  RB1F = rst ? 0 : ~(0|PHS4_|TSGU_|BR1_);
// Gate A6-U119B
pullup(WL_);
assign (highz1,strong0) #0.2  WL_ = rst ? 1 : ~(0|d5XP12|A6J1Pad104);
// Gate A6-U103A
pullup(A6U102Pad2);
assign (highz1,strong0) #0.2  A6U102Pad2 = rst ? 0 : ~(0|T04_|DV4_);
// Gate A6-U102B
pullup(A6U102Pad3);
assign (highz1,strong0) #0.2  A6U102Pad3 = rst ? 0 : ~(0|T01_|DV1376_);
// Gate A6-U102A
pullup(A6U102Pad1);
assign (highz1,strong0) #0.2  A6U102Pad1 = rst ? 1 : ~(0|A6U102Pad2|A6U102Pad3|A6U101Pad1);
// Gate A6-U228A A6-U253A A6-U253B
pullup(d8PP4);
assign (highz1,strong0) #0.2  d8PP4 = rst ? 1 : ~(0|MSU0|DAS1|RUPT1|IC6|IC9|IC7|MASK0|IC11|IC17);
// Gate A6-U222B
pullup(WOVR);
assign (highz1,strong0) #0.2  WOVR = rst ? 0 : ~(0|MONpCH|T07_|A6U222Pad1);
// Gate A6-U235B
pullup(EXT);
assign (highz1,strong0) #0.2  EXT = rst ? 0 : ~(0|NDXX1_|T10_);
// Gate A6-U127B
pullup(A6U124Pad2);
assign (highz1,strong0) #0.2  A6U124Pad2 = rst ? 1 : ~(0|T03|T01);
// Gate A6-U124A
pullup(A6U124Pad1);
assign (highz1,strong0) #0.2  A6U124Pad1 = rst ? 0 : ~(0|A6U124Pad2|MP3_);
// Gate A6-U144A A6-U144B
pullup(A6U144Pad1);
assign (highz1,strong0) #0.2  A6U144Pad1 = rst ? 0 : ~(0|RSTK_);
// Gate A6-U116A
pullup(A6U116Pad1);
assign (highz1,strong0) #0.2  A6U116Pad1 = rst ? 0 : ~(0|A6U105Pad2|A6U114Pad9);
// Gate A6-U137A
pullup(IL02_);
assign (highz1,strong0) #0.2  IL02_ = rst ? 1 : ~(0|S02_);
// Gate A6-U124B
pullup(A6U124Pad9);
assign (highz1,strong0) #0.2  A6U124Pad9 = rst ? 1 : ~(0|A6U123Pad1|DIVSTG);
// Gate A6-U151B
pullup(A6U151Pad2);
assign (highz1,strong0) #0.2  A6U151Pad2 = rst ? 1 : ~(0|MONEX|PTWOX);
// Gate A6-U149B
pullup(A6U148Pad3);
assign (highz1,strong0) #0.2  A6U148Pad3 = rst ? 0 : ~(0|A6U149Pad1|P01);
// Gate A6-U134B
pullup(A6U133Pad8);
assign (highz1,strong0) #0.2  A6U133Pad8 = rst ? 0 : ~(0|A6U134Pad8);
// Gate A6-U157A
pullup(TOV_);
assign (highz1,strong0) #0.2  TOV_ = rst ? 1 : ~(0|d6XP5|d3XP2|d9XP5);
// Gate A6-U259A
pullup(A6U223Pad7);
assign (highz1,strong0) #0.2  A6U223Pad7 = rst ? 0 : ~(0|DAS1_|T03_|ADS0);
// Gate A6-U242A
pullup(A6U242Pad1);
assign (highz1,strong0) #0.2  A6U242Pad1 = rst ? 0 : ~(0|MP1_|T10_);
// Gate A6-U153A
pullup(A6U153Pad1);
assign (highz1,strong0) #0.2  A6U153Pad1 = rst ? 0 : ~(0|A6U118Pad9);
// Gate A6-U202A A6-U204B
pullup(A6U202Pad1);
assign (highz1,strong0) #0.2  A6U202Pad1 = rst ? 1 : ~(0|A6U202Pad2|INCR0|A6U201Pad1|A6U204Pad7|PINC);
// Gate A6-U158B
pullup(WZ_);
assign (highz1,strong0) #0.2  WZ_ = rst ? 1 : ~(0|d5XP4|RRPA);
// Gate A6-U229B
pullup(A6U228Pad7);
assign (highz1,strong0) #0.2  A6U228Pad7 = rst ? 0 : ~(0|BR2_|DAS1_);
// Gate A6-U111B
pullup(A6U111Pad9);
assign (highz1,strong0) #0.2  A6U111Pad9 = rst ? 0 : ~(0|A6U110Pad1|A6U111Pad7|A6U111Pad1);
// Gate A6-U105A
pullup(ZIP);
assign (highz1,strong0) #0.2  ZIP = rst ? 0 : ~(0|A6U105Pad2);
// Gate A6-U208B
pullup(A6U207Pad4);
assign (highz1,strong0) #0.2  A6U207Pad4 = rst ? 0 : ~(0|DINC_|BR1B2B_);
// Gate A6-U111A
pullup(A6U111Pad1);
assign (highz1,strong0) #0.2  A6U111Pad1 = rst ? 1 : ~(0|L02A_);
// Gate A6-U228B A6-U229A
pullup(A6U228Pad9);
assign (highz1,strong0) #0.2  A6U228Pad9 = rst ? 1 : ~(0|IC11|A6U228Pad7|ADS0|CCS0|A6U227Pad1);
// Gate A6-U112B
pullup(A6U111Pad7);
assign (highz1,strong0) #0.2  A6U111Pad7 = rst ? 0 : ~(0|L15A_);
// Gate A6-U209B
pullup(A6U207Pad2);
assign (highz1,strong0) #0.2  A6U207Pad2 = rst ? 0 : ~(0|DIM0_|BR1B2B_);
// Gate A6-U208A
pullup(A6U207Pad3);
assign (highz1,strong0) #0.2  A6U207Pad3 = rst ? 0 : ~(0|BR1_|AUG0_);
// Gate A6-U239B
pullup(A6U238Pad3);
assign (highz1,strong0) #0.2  A6U238Pad3 = rst ? 1 : ~(0|IC6|IC7);
// Gate A6-U211A
pullup(ZOUT);
assign (highz1,strong0) #0.2  ZOUT = rst ? 0 : ~(0|BR2_|DINC_|CDUSTB_);
// Gate A6-U238A
pullup(A6U238Pad1);
assign (highz1,strong0) #0.2  A6U238Pad1 = rst ? 0 : ~(0|T10_|A6U238Pad3);
// Gate A6-U133B
pullup(A6U133Pad2);
assign (highz1,strong0) #0.2  A6U133Pad2 = rst ? 1 : ~(0|A6U133Pad8);
// Gate A6-U133A
pullup(A6U133Pad1);
assign (highz1,strong0) #0.2  A6U133Pad1 = rst ? 0 : ~(0|A6U133Pad2);
// Gate A6-U249A
pullup(R1C_);
assign (highz1,strong0) #0.2  R1C_ = rst ? 1 : ~(0|A6U219Pad1);
// Gate A6-U211B
pullup(MOUT);
assign (highz1,strong0) #0.2  MOUT = rst ? 0 : ~(0|CDUSTB_|DINC_|BR12B_);
// Gate A6-U132A
pullup(IL03_);
assign (highz1,strong0) #0.2  IL03_ = rst ? 1 : ~(0|S03_);
// Gate A6-U123A
pullup(A6U123Pad1);
assign (highz1,strong0) #0.2  A6U123Pad1 = rst ? 0 : ~(0|A6U121Pad9|T12USE_|DV376_);
// Gate A6-U251A
pullup(NEAC);
assign (highz1,strong0) #0.2  NEAC = rst ? 0 : ~(0|TL15|A6U251Pad3|GOJAM);
// Gate A6-U153B
pullup(MONEX);
assign (highz1,strong0) #0.2  MONEX = rst ? 0 : ~(0|MONEX_);
// Gate A6-U206A
pullup(A6U206Pad1);
assign (highz1,strong0) #0.2  A6U206Pad1 = rst ? 0 : ~(0|T06_|A6U205Pad1);
// Gate A6-U245B
pullup(RPTSET);
assign (highz1,strong0) #0.2  RPTSET = rst ? 0 : ~(0|PSEUDO);
// Gate A6-U151A
pullup(TWOX);
assign (highz1,strong0) #0.2  TWOX = rst ? 0 : ~(0|A6U151Pad2);
// Gate A6-U219A
pullup(A6U219Pad1);
assign (highz1,strong0) #0.2  A6U219Pad1 = rst ? 0 : ~(0|DAS1_|T07_|BR12B_);
// Gate A6-U117B
pullup(A6U117Pad9);
assign (highz1,strong0) #0.2  A6U117Pad9 = rst ? 0 : ~(0|DV1376_|T02_);
// Gate A6-U129B
pullup(ZAP);
assign (highz1,strong0) #0.2  ZAP = rst ? 0 : ~(0|ZAP_);
// Gate A6-U216B
pullup(d7XP14);
assign (highz1,strong0) #0.2  d7XP14 = rst ? 0 : ~(0|T07_|A6U216Pad8);
// Gate A6-U209A
pullup(A6U209Pad1);
assign (highz1,strong0) #0.2  A6U209Pad1 = rst ? 0 : ~(0|A6U209Pad2|T06_);
// Gate A6-U127A
pullup(MCRO_);
assign (highz1,strong0) #0.2  MCRO_ = rst ? 1 : ~(0|A6U116Pad1);
// Gate A6-U128A
pullup(A6U128Pad1);
assign (highz1,strong0) #0.2  A6U128Pad1 = rst ? 0 : ~(0|MP1_|A6U120Pad9);
// Gate A6-U235A
pullup(A6U235Pad1);
assign (highz1,strong0) #0.2  A6U235Pad1 = rst ? 0 : ~(0|CCS0_|BR12B_);
// Gate A6-U120A A6-U121A
pullup(RG_);
assign (highz1,strong0) #0.2  RG_ = rst ? 1 : ~(0|d5XP4|RADRG|d5XP28|A6J1Pad104);
// Gate A6-U154A
pullup(A6U154Pad1);
assign (highz1,strong0) #0.2  A6U154Pad1 = rst ? 0 : ~(0|PIFL_|T02|A6U153Pad1);
// Gate A6-U155B A6-U224B
pullup(WSC_);
assign (highz1,strong0) #0.2  WSC_ = rst ? 1 : ~(0|d6XP8|d9XP5|WOVR|A6U217Pad9|A6U223Pad3);
// Gate A6-U134A
pullup(A6U134Pad1);
assign (highz1,strong0) #0.2  A6U134Pad1 = rst ? 1 : ~(0|A6U133Pad1);
// Gate A6-U220A A6-U221A
pullup(A6U219Pad8);
assign (highz1,strong0) #0.2  A6U219Pad8 = rst ? 1 : ~(0|PRINC|PINC|MINC|DINC);
// Gate A6-U131B
pullup(IL07_);
assign (highz1,strong0) #0.2  IL07_ = rst ? 1 : ~(0|S07_);
// Gate A6-U150B
pullup(A6U150Pad2);
assign (highz1,strong0) #0.2  A6U150Pad2 = rst ? 1 : ~(0|B15X|A6U150Pad8);
// Gate A6-U210A
pullup(POUT);
assign (highz1,strong0) #0.2  POUT = rst ? 0 : ~(0|CDUSTB_|BR1B2B_|DINC_);
// Gate A6-U135B
pullup(A6U134Pad8);
assign (highz1,strong0) #0.2  A6U134Pad8 = rst ? 1 : ~(0|A6U135Pad8);
// Gate A6-U152A A6-U152B
pullup(A6U150Pad8);
assign (highz1,strong0) #0.2  A6U150Pad8 = rst ? 0 : ~(0|MONEX_);
// Gate A6-U250B
pullup(RUS_);
assign (highz1,strong0) #0.2  RUS_ = rst ? 1 : ~(0|A6U220Pad9|d7XP9|d11XP2);
// Gate A6-U122B
pullup(A6U122Pad2);
assign (highz1,strong0) #0.2  A6U122Pad2 = rst ? 0 : ~(0|DV376_|A6U118Pad9);
// Gate A6-U214A
pullup(A6U214Pad1);
assign (highz1,strong0) #0.2  A6U214Pad1 = rst ? 0 : ~(0|DV4_|BR1B2B);
// Gate A6-U240A
pullup(A6U236Pad2);
assign (highz1,strong0) #0.2  A6U236Pad2 = rst ? 0 : ~(0|CCS0_|BR1B2B_);
// Gate A6-U236B A6-U240B
pullup(A6U236Pad9);
assign (highz1,strong0) #0.2  A6U236Pad9 = rst ? 1 : ~(0|DV4B1B|A6U235Pad1|DCS0|IC7|SU0);
// Gate A6-U139A
pullup(IL01_);
assign (highz1,strong0) #0.2  IL01_ = rst ? 0 : ~(0|S01_);
// Gate A6-U155A A6-U223A
pullup(WG_);
assign (highz1,strong0) #0.2  WG_ = rst ? 1 : ~(0|d6XP8|A6U223Pad3|WOVR);
// Gate A6-U117A
pullup(RCH_);
assign (highz1,strong0) #0.2  RCH_ = rst ? 1 : ~(0|d4XP11|d5XP21|d3XP7);
// Gate A6-U107A
pullup(A6U105Pad2);
assign (highz1,strong0) #0.2  A6U105Pad2 = rst ? 1 : ~(0|A6U106Pad1|d2XP7);
// Gate A6-U146A A6-U146B
pullup(TIMR);
assign (highz1,strong0) #0.2  TIMR = rst ? 1 : ~(0|A6U146Pad2);
// Gate A6-U213A
pullup(A6U213Pad1);
assign (highz1,strong0) #0.2  A6U213Pad1 = rst ? 1 : ~(0|DAS1|MSU0|DAS0);
// Gate A6-U142A
pullup(A6U142Pad1);
assign (highz1,strong0) #0.2  A6U142Pad1 = rst ? 1 : ~(0|A6U141Pad8|CGMC);
// Gate A6-U213B
pullup(A6U213Pad9);
assign (highz1,strong0) #0.2  A6U213Pad9 = rst ? 0 : ~(0|A6U213Pad1|T07_);
// Gate A6-U149A
pullup(A6U149Pad1);
assign (highz1,strong0) #0.2  A6U149Pad1 = rst ? 1 : ~(0|STOP_|A6U148Pad3);
// Gate A6-U143B
pullup(A6U142Pad8);
assign (highz1,strong0) #0.2  A6U142Pad8 = rst ? 1 : ~(0|d1XP10|STBF|STBE);
// Gate A6-U238B
pullup(A6J4Pad419);
assign (highz1,strong0) #0.2  A6J4Pad419 = rst ? 1 : ~(0);
// Gate A6-U205A A6-U207A
pullup(A6U205Pad1);
assign (highz1,strong0) #0.2  A6U205Pad1 = rst ? 1 : ~(0|MCDU|MINC|A6U207Pad2|A6U207Pad3|A6U207Pad4);
// Gate A6-U105B
pullup(L2GD_);
assign (highz1,strong0) #0.2  L2GD_ = rst ? 1 : ~(0|ZIP|DVXP1);
// Gate A6-U141A
pullup(A6U135Pad8);
assign (highz1,strong0) #0.2  A6U135Pad8 = rst ? 0 : ~(0|A6U141Pad2);
// Gate A6-U214B
pullup(A6U214Pad9);
assign (highz1,strong0) #0.2  A6U214Pad9 = rst ? 1 : ~(0|A6U214Pad1|RAND0|WAND0);
// Gate A6-U108A
pullup(WY_);
assign (highz1,strong0) #0.2  WY_ = rst ? 1 : ~(0|A6U108Pad2);
// Gate A6-U135A
pullup(A6U135Pad1);
assign (highz1,strong0) #0.2  A6U135Pad1 = rst ? 0 : ~(0|A6U134Pad1);
// Gate A6-U249B
pullup(PSEUDO);
assign (highz1,strong0) #0.2  PSEUDO = rst ? 0 : ~(0|RADRG|A6U249Pad7|GOJAM);
// Gate A6-U230A
pullup(A6U215Pad8);
assign (highz1,strong0) #0.2  A6U215Pad8 = rst ? 0 : ~(0|T11_|A6U228Pad9);
// Gate A6-U225B
pullup(A6U223Pad3);
assign (highz1,strong0) #0.2  A6U223Pad3 = rst ? 0 : ~(0|T07_|A6U225Pad1);
// Gate A6-U218A
pullup(A6U218Pad1);
assign (highz1,strong0) #0.2  A6U218Pad1 = rst ? 0 : ~(0|T07_|DAS1_|BR1B2_);
// Gate A6-U241B
pullup(A6U241Pad9);
assign (highz1,strong0) #0.2  A6U241Pad9 = rst ? 0 : ~(0|A6U236Pad9|T10_);
// Gate A6-U218B
pullup(A6U218Pad9);
assign (highz1,strong0) #0.2  A6U218Pad9 = rst ? 1 : ~(0|PCDU|MCDU|SHIFT);
// Gate A6-U138A
pullup(IL05_);
assign (highz1,strong0) #0.2  IL05_ = rst ? 1 : ~(0|S05_);
// Gate A6-U205B
pullup(A6U204Pad7);
assign (highz1,strong0) #0.2  A6U204Pad7 = rst ? 0 : ~(0|DINC_|BR12B_);
// Gate A6-U206B
pullup(MONEX_);
assign (highz1,strong0) #0.2  MONEX_ = rst ? 1 : ~(0|A6U206Pad1);
// Gate A6-U110B
pullup(A6U106Pad8);
assign (highz1,strong0) #0.2  A6U106Pad8 = rst ? 0 : ~(0|A6U109Pad9|A6U105Pad2);
// Gate A6-U116B
pullup(A6U104Pad3);
assign (highz1,strong0) #0.2  A6U104Pad3 = rst ? 0 : ~(0|A6U114Pad1|A6U111Pad9|A6U105Pad2);
// Gate A6-U154B
pullup(PIFL_);
assign (highz1,strong0) #0.2  PIFL_ = rst ? 1 : ~(0|DVXP1|A6U154Pad1);
// Gate A6-U145A
pullup(RSTKY_);
assign (highz1,strong0) #0.2  RSTKY_ = rst ? 1 : ~(0|A6U144Pad1);
// Gate A6-U118B
pullup(A6U118Pad9);
assign (highz1,strong0) #0.2  A6U118Pad9 = rst ? 1 : ~(0|T11|T05|T08);
// Gate A6-U106A
pullup(A6U106Pad1);
assign (highz1,strong0) #0.2  A6U106Pad1 = rst ? 0 : ~(0|MP1_|A6U106Pad3);
// Gate A6-U225A
pullup(A6U225Pad1);
assign (highz1,strong0) #0.2  A6U225Pad1 = rst ? 1 : ~(0|DXCH0|IC9);
// Gate A6-U120B A6-U123B
pullup(A6U120Pad9);
assign (highz1,strong0) #0.2  A6U120Pad9 = rst ? 1 : ~(0|T08|T10|T06|T04|T02);
// Gate A6-U141B
pullup(A6U141Pad2);
assign (highz1,strong0) #0.2  A6U141Pad2 = rst ? 1 : ~(0|A6U141Pad8);
// Gate A6-U109A
pullup(A6U108Pad2);
assign (highz1,strong0) #0.2  A6U108Pad2 = rst ? 0 : ~(0|A6U105Pad2|A6U109Pad3|A6U109Pad4);
// Gate A6-U142B
pullup(A6U141Pad8);
assign (highz1,strong0) #0.2  A6U141Pad8 = rst ? 0 : ~(0|A6U142Pad1|A6U142Pad8);
// Gate A6-U148A A6-U147B
pullup(A6U147Pad3);
assign (highz1,strong0) #0.2  A6U147Pad3 = rst ? 0 : ~(0|STOP_|A6U148Pad3|P04|P05_);
// Gate A6-U125A
pullup(A6U125Pad1);
assign (highz1,strong0) #0.2  A6U125Pad1 = rst ? 0 : ~(0|A6U124Pad9);
// Gate A6-U254B
pullup(d2PP1);
assign (highz1,strong0) #0.2  d2PP1 = rst ? 1 : ~(0|IC15|DV0|DV1376);
// Gate A6-U157B
pullup(WQ_);
assign (highz1,strong0) #0.2  WQ_ = rst ? 1 : ~(0|d3XP6|d5XP15);
// Gate A6-U136B
pullup(IL06_);
assign (highz1,strong0) #0.2  IL06_ = rst ? 0 : ~(0|S06_);
// Gate A6-U128B
pullup(ZAP_);
assign (highz1,strong0) #0.2  ZAP_ = rst ? 1 : ~(0|A6U124Pad1|A6U128Pad1);
// Gate A6-U210B
pullup(A6U209Pad2);
assign (highz1,strong0) #0.2  A6U209Pad2 = rst ? 1 : ~(0|MCDU|PCDU);
// Gate A6-U106B
pullup(WYD_);
assign (highz1,strong0) #0.2  WYD_ = rst ? 1 : ~(0|DVXP1|A6U106Pad8);
// Gate A6-U107B A6-U108B
pullup(A6U106Pad3);
assign (highz1,strong0) #0.2  A6U106Pad3 = rst ? 1 : ~(0|T01|T03|T05|T07|T11|T09);
// Gate A6-U256A A6-U246A
pullup(A6U246Pad1);
assign (highz1,strong0) #0.2  A6U246Pad1 = rst ? 1 : ~(0|d2XP8|d10XP1|MP0T10|A6U242Pad1);
// Gate A6-U143A
pullup(CGMC);
assign (highz1,strong0) #0.2  CGMC = rst ? 0 : ~(0|A6U142Pad8|A6U135Pad1);
// Gate A6-U129A A6-U126B A6-U223B A6-U204A
pullup(RU_);
assign (highz1,strong0) #0.2  RU_ = rst ? 1 : ~(0|ZAP|A6U125Pad1|d6XP5|d5XP12|A6U219Pad9|A6U223Pad7|A6U215Pad8|RDBANK);
// Gate A6-U145B
pullup(RSTKX_);
assign (highz1,strong0) #0.2  RSTKX_ = rst ? 1 : ~(0|A6U144Pad1);
// Gate A6-U122A
pullup(A6U118Pad2);
assign (highz1,strong0) #0.2  A6U118Pad2 = rst ? 1 : ~(0|A6U122Pad2|A6U117Pad9);
// Gate A6-U160A A6-U159A A6-U159B
pullup(CLXC);
assign (highz1,strong0) #0.2  CLXC = rst ? 0 : ~(0|TSGU_|BR1|PHS4_);
// Gate A6-U115A A6-U245A
pullup(RC_);
assign (highz1,strong0) #0.2  RC_ = rst ? 1 : ~(0|ZIPCI|d3XP7|A6P7|A6U241Pad9);
// Gate A6-U101A
pullup(A6U101Pad1);
assign (highz1,strong0) #0.2  A6U101Pad1 = rst ? 0 : ~(0|DV376_|A6U101Pad3);
// Gate A6-U125B A6-U126A
pullup(WB_);
assign (highz1,strong0) #0.2  WB_ = rst ? 1 : ~(0|d5XP28|d1XP10|A6U125Pad1|d2XP3);
// Gate A6-U101B
pullup(A6U101Pad3);
assign (highz1,strong0) #0.2  A6U101Pad3 = rst ? 1 : ~(0|T07|T04|T10);
// Gate A6-U147A
pullup(A6U146Pad2);
assign (highz1,strong0) #0.2  A6U146Pad2 = rst ? 0 : ~(0|STRT2|A6U147Pad3);
// Gate A6-U202B
pullup(A6U202Pad2);
assign (highz1,strong0) #0.2  A6U202Pad2 = rst ? 0 : ~(0|DIM0_|BR12B_);
// Gate A6-U251B
pullup(A6U251Pad3);
assign (highz1,strong0) #0.2  A6U251Pad3 = rst ? 1 : ~(0|MP0T10|NEAC);
// Gate A6-U140A
pullup(IL04_);
assign (highz1,strong0) #0.2  IL04_ = rst ? 1 : ~(0|S04_);
// Gate A6-U239A
pullup(CI_);
assign (highz1,strong0) #0.2  CI_ = rst ? 1 : ~(0|A6U209Pad1|ZIPCI);
// Gate A6-U257A
pullup(WS_);
assign (highz1,strong0) #0.2  WS_ = rst ? 1 : ~(0|A6P10|R15|R6);
// Gate A6-U227A
pullup(A6U227Pad1);
assign (highz1,strong0) #0.2  A6U227Pad1 = rst ? 0 : ~(0|MP3_|BR1_);
// Gate A6-U230B
pullup(RDBANK);
assign (highz1,strong0) #0.2  RDBANK = rst ? 0 : ~(0|T06_|STFET1_);
// Gate A6-U250A
pullup(A6U249Pad7);
assign (highz1,strong0) #0.2  A6U249Pad7 = rst ? 1 : ~(0|PSEUDO|RADRZ);
// Gate A6-U115B
pullup(ZIPCI);
assign (highz1,strong0) #0.2  ZIPCI = rst ? 0 : ~(0|A6U113Pad1|A6U114Pad9|A6U105Pad2);
// Gate A6-U138B
pullup(IL02);
assign (highz1,strong0) #0.2  IL02 = rst ? 0 : ~(0|S02);
// Gate A6-U140B
pullup(IL01);
assign (highz1,strong0) #0.2  IL01 = rst ? 1 : ~(0|S01);
// Gate A6-U132B
pullup(IL07);
assign (highz1,strong0) #0.2  IL07 = rst ? 0 : ~(0|S07);
// Gate A6-U137B
pullup(IL06);
assign (highz1,strong0) #0.2  IL06 = rst ? 1 : ~(0|S06);
// Gate A6-U139B
pullup(IL05);
assign (highz1,strong0) #0.2  IL05 = rst ? 0 : ~(0|S05);
// Gate A6-U131A
pullup(IL04);
assign (highz1,strong0) #0.2  IL04 = rst ? 0 : ~(0|S04);
// Gate A6-U113A
pullup(A6U113Pad1);
assign (highz1,strong0) #0.2  A6U113Pad1 = rst ? 0 : ~(0|L02A_|L01_|L15A_);
// Gate A6-U247B
pullup(ST1);
assign (highz1,strong0) #0.2  ST1 = rst ? 0 : ~(0|A6U246Pad1);
// Gate A6-U248A
pullup(ST2);
assign (highz1,strong0) #0.2  ST2 = rst ? 0 : ~(0|ST2_);
// Gate A6-U104B
pullup(A2X_);
assign (highz1,strong0) #0.2  A2X_ = rst ? 1 : ~(0|DVXP1|ZIP|d7XP19);
// Gate A6-U217A
pullup(A6U216Pad8);
assign (highz1,strong0) #0.2  A6U216Pad8 = rst ? 0 : ~(0|INOTLD|WAND0);
// Gate A6-U104A A6-U224A
pullup(RB_);
assign (highz1,strong0) #0.2  RB_ = rst ? 1 : ~(0|RBSQ|A6U104Pad3|DVXP1|A6U223Pad3|A6XP9);
// Gate A6-U219B
pullup(A6U219Pad9);
assign (highz1,strong0) #0.2  A6U219Pad9 = rst ? 0 : ~(0|T07_|A6U219Pad8);
// Gate A6-U227B A6-U203B A6-U256B
pullup(A6P10);
assign (highz1,strong0) #0.2  A6P10 = rst ? 0 : ~(0|RUPT0|T08_|DAS0|A6U202Pad1|T06_|DV1376|MP1);
// Gate A6-U121B
pullup(A6U121Pad9);
assign (highz1,strong0) #0.2  A6U121Pad9 = rst ? 1 : ~(0|T09|T12|T06);
// Gate A6-U236A A6-U234B
pullup(A6U234Pad2);
assign (highz1,strong0) #0.2  A6U234Pad2 = rst ? 1 : ~(0|A6U236Pad2|AD0|DCA0|IC6);
// Gate A6-U222A
pullup(A6U222Pad1);
assign (highz1,strong0) #0.2  A6U222Pad1 = rst ? 0 : ~(0|PRINC|INKL);
// Gate A6-U233B
pullup(PONEX);
assign (highz1,strong0) #0.2  PONEX = rst ? 0 : ~(0|A6U232Pad1);
// Gate A6-U242B
pullup(RZ_);
assign (highz1,strong0) #0.2  RZ_ = rst ? 1 : ~(0|A6P4|d9XP1|RADRZ);
// Gate A6-U226B
pullup(A6P4);
assign (highz1,strong0) #0.2  A6P4 = rst ? 0 : ~(0|d8PP4|T08_);
// Gate A6-U216A
pullup(A6P7);
assign (highz1,strong0) #0.2  A6P7 = rst ? 0 : ~(0|T07_|A6U214Pad9);
// Gate A6-U110A
pullup(A6U110Pad1);
assign (highz1,strong0) #0.2  A6U110Pad1 = rst ? 0 : ~(0|L01_);
// Gate A6-U241A A6-U215B
pullup(WA_);
assign (highz1,strong0) #0.2  WA_ = rst ? 1 : ~(0|A6U223Pad7|A6U238Pad1|d2XP5|A6P7|A6U213Pad9|A6U215Pad8);
// Gate A6-U112A
pullup(A6U109Pad3);
assign (highz1,strong0) #0.2  A6U109Pad3 = rst ? 1 : ~(0|A6U111Pad7|L02A_|A6U110Pad1);
// Gate A6-U201A
pullup(A6U201Pad1);
assign (highz1,strong0) #0.2  A6U201Pad1 = rst ? 0 : ~(0|AUG0_|BR1);
// Gate A6-U220B
pullup(A6U220Pad9);
assign (highz1,strong0) #0.2  A6U220Pad9 = rst ? 0 : ~(0|A6U218Pad9|T07_);
// Gate A6-U113B
pullup(A6U109Pad4);
assign (highz1,strong0) #0.2  A6U109Pad4 = rst ? 0 : ~(0|A6U111Pad1|L15A_|L01_);
// Gate A6-U109B
pullup(A6U109Pad9);
assign (highz1,strong0) #0.2  A6U109Pad9 = rst ? 0 : ~(0|A6U109Pad4|A6U109Pad3);
// Gate A6-U136A
pullup(IL03);
assign (highz1,strong0) #0.2  IL03 = rst ? 0 : ~(0|S03);
// Gate A6-U234A
pullup(A6XP9);
assign (highz1,strong0) #0.2  A6XP9 = rst ? 0 : ~(0|A6U234Pad2|T10_);
// Gate A6-U217B
pullup(A6U217Pad9);
assign (highz1,strong0) #0.2  A6U217Pad9 = rst ? 0 : ~(0|MON_|T04_|FETCH1);
// Gate A6-U114B
pullup(A6U114Pad9);
assign (highz1,strong0) #0.2  A6U114Pad9 = rst ? 1 : ~(0|A6U114Pad1);
// Gate A6-U150A
pullup(BXVX);
assign (highz1,strong0) #0.2  BXVX = rst ? 0 : ~(0|A6U150Pad2);
// Gate A6-U118A
pullup(A6J1Pad104);
assign (highz1,strong0) #0.2  A6J1Pad104 = rst ? 0 : ~(0|A6U118Pad2);
// Gate A6-U119A A6-U158A
pullup(TSGU_);
assign (highz1,strong0) #0.2  TSGU_ = rst ? 1 : ~(0|d5XP28|A6J1Pad104);
// Gate A6-U114A
pullup(A6U114Pad1);
assign (highz1,strong0) #0.2  A6U114Pad1 = rst ? 0 : ~(0|L02A_|A6U109Pad4|A6U109Pad3);
// Gate A6-U247A
pullup(RB1_);
assign (highz1,strong0) #0.2  RB1_ = rst ? 1 : ~(0|A6U218Pad1);

endmodule
