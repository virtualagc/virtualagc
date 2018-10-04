// Verilog module auto-generated for AGC module A12 by dumbVerilog.py

module A12 ( 
  rst, CAD4, CAD5, CAD6, CGA12, CGG, CSG, EB10, EB11_, EB9, G01, G02, G03,
  G04, G05, G06, G07, G08, G09, G10, G11, G12, G13, G14, G15, G16, GOJAM,
  IC15_, L02_, L15_, MONPAR, OCTAD2, R6, RAD, RPTAD4, RPTAD5, RPTAD6, SAP,
  SCAD, SCADBL, SHANC, SHINC, T02_, T03, T04, T05, T07, T10, T12_, T7PHS4_,
  TPARG_, TSUDO_, WEDOPG_, WL01_, WL02_, WL03_, WL04_, WL05_, WL06_, WL07_,
  WL08_, WL09_, WL10_, WL11_, WL12_, WL13_, WL14_, WSG_, XB0_, XB1_, XB2_,
  XB3_, d8XP5, BRXP3, G01A_, GEMP, GNZRO, MGP_, MPAL_, MSCDBL_, MSP, PA03,
  PA03_, PA06, PA06_, PA09, PA09_, PA12, PA12_, PA15, PA15_, RL03_, RL04_,
  RL05_, RL06_, RSC_, S09_, S10_, T03_, T04_, T05_, T07_, T10_, T12A, WG_,
  CYL_, CYR_, EAD09, EAD09_, EAD10, EAD10_, EAD11, EAD11_, EDOP_, EXTPLS,
  G01A, G01ED, G02ED, G03ED, G04ED, G05ED, G06ED, G07ED, G16A_, GEQZRO_,
  GINH, INHPLS, L02A_, L15A_, PALE, PB09, PB09_, PB15, PB15_, PC15, PC15_,
  RADRG, RADRZ, RELPLS, S01, S01_, S02, S02_, S03, S03_, S04, S04_, S05,
  S05_, S06, S06_, S07, S07_, S08, S08_, S09, S10, S11, S11_, S12, S12_,
  SHIFT, SHIFT_, SR_, WGA_
);

input wire rst, CAD4, CAD5, CAD6, CGA12, CGG, CSG, EB10, EB11_, EB9, G01,
  G02, G03, G04, G05, G06, G07, G08, G09, G10, G11, G12, G13, G14, G15, G16,
  GOJAM, IC15_, L02_, L15_, MONPAR, OCTAD2, R6, RAD, RPTAD4, RPTAD5, RPTAD6,
  SAP, SCAD, SCADBL, SHANC, SHINC, T02_, T03, T04, T05, T07, T10, T12_, T7PHS4_,
  TPARG_, TSUDO_, WEDOPG_, WL01_, WL02_, WL03_, WL04_, WL05_, WL06_, WL07_,
  WL08_, WL09_, WL10_, WL11_, WL12_, WL13_, WL14_, WSG_, XB0_, XB1_, XB2_,
  XB3_, d8XP5;

inout wire BRXP3, G01A_, GEMP, GNZRO, MGP_, MPAL_, MSCDBL_, MSP, PA03, PA03_,
  PA06, PA06_, PA09, PA09_, PA12, PA12_, PA15, PA15_, RL03_, RL04_, RL05_,
  RL06_, RSC_, S09_, S10_, T03_, T04_, T05_, T07_, T10_, T12A, WG_;

output wire CYL_, CYR_, EAD09, EAD09_, EAD10, EAD10_, EAD11, EAD11_, EDOP_,
  EXTPLS, G01A, G01ED, G02ED, G03ED, G04ED, G05ED, G06ED, G07ED, G16A_, GEQZRO_,
  GINH, INHPLS, L02A_, L15A_, PALE, PB09, PB09_, PB15, PB15_, PC15, PC15_,
  RADRG, RADRZ, RELPLS, S01, S01_, S02, S02_, S03, S03_, S04, S04_, S05,
  S05_, S06, S06_, S07, S07_, S08, S08_, S09, S10, S11, S11_, S12, S12_,
  SHIFT, SHIFT_, SR_, WGA_;

// Gate A12-U241A
pullup(A12U240Pad2);
assign (highz1,strong0) #0.2  A12U240Pad2 = rst ? 1 : ~(0|CSG|A12U240Pad1);
// Gate A12-U240A
pullup(A12U240Pad1);
assign (highz1,strong0) #0.2  A12U240Pad1 = rst ? 0 : ~(0|A12U240Pad2|A12U238Pad1);
// Gate A12-U232A
pullup(A12U232Pad1);
assign (highz1,strong0) #0.2  A12U232Pad1 = rst ? 0 : ~(0|WSG_|WL01_);
// Gate A12-U248B
pullup(A12U248Pad2);
assign (highz1,strong0) #0.2  A12U248Pad2 = rst ? 0 : ~(0|A12U247Pad9|A12U248Pad1);
// Gate A12-U248A
pullup(A12U248Pad1);
assign (highz1,strong0) #0.2  A12U248Pad1 = rst ? 1 : ~(0|A12U248Pad2|CSG);
// Gate A12-U139A A12-U141B
pullup(PA06);
assign (highz1,strong0) #0.2  PA06 = rst ? 0 : ~(0|A12U137Pad9|A12U137Pad1|A12U138Pad1|A12U140Pad9);
// Gate A12-U235A
pullup(RL04_);
assign (highz1,strong0) #0.2  RL04_ = rst ? 1 : ~(0|CAD4|RPTAD4);
// Gate A12-U143A
pullup(A12U143Pad1);
assign (highz1,strong0) #0.2  A12U143Pad1 = rst ? 1 : ~(0|G08);
// Gate A12-U135A A12-U159B A12-U160B
pullup(GNZRO);
assign (highz1,strong0) #0.2  GNZRO = rst ? 1 : ~(0|G15|A12U148Pad9|A12U147Pad9|A12U154Pad1|A12U158Pad9);
// Gate A12-U145A
pullup(A12U143Pad7);
assign (highz1,strong0) #0.2  A12U143Pad7 = rst ? 1 : ~(0|G09);
// Gate A12-U107A A12-U106A
pullup(RELPLS);
assign (highz1,strong0) #0.2  RELPLS = rst ? 0 : ~(0|A12G02_|G03|A12U102Pad2|A12U102Pad3|G01A_);
// Gate A12-U213A
pullup(A12U210Pad2);
assign (highz1,strong0) #0.2  A12U210Pad2 = rst ? 1 : ~(0|CSG|A12U211Pad8);
// Gate A12-U114B
pullup(EAD11_);
assign (highz1,strong0) #0.2  EAD11_ = rst ? 1 : ~(0|EAD11);
// Gate A12-U143B
pullup(A12U143Pad9);
assign (highz1,strong0) #0.2  A12U143Pad9 = rst ? 0 : ~(0|G07|A12U143Pad7|A12U143Pad1);
// Gate A12-U216B
pullup(S11);
assign (highz1,strong0) #0.2  S11 = rst ? 0 : ~(0|A12U216Pad8);
// Gate A12-U260B
pullup(G01A);
assign (highz1,strong0) #0.2  G01A = rst ? 0 : ~(0|G01A_);
// Gate A12-U239A A12-U239B
pullup(S02_);
assign (highz1,strong0) #0.2  S02_ = rst ? 0 : ~(0|A12U236Pad2);
// Gate A12-U254A
pullup(A12U254Pad1);
assign (highz1,strong0) #0.2  A12U254Pad1 = rst ? 0 : ~(0|WSG_|WL07_);
// Gate A12-U221A
pullup(A12U217Pad2);
assign (highz1,strong0) #0.2  A12U217Pad2 = rst ? 1 : ~(0|CSG|A12U219Pad2);
// Gate A12-U254B A12-U253B
pullup(S06);
assign (highz1,strong0) #0.2  S06 = rst ? 0 : ~(0|A12U252Pad1);
// Gate A12-U230A
pullup(G01ED);
assign (highz1,strong0) #0.2  G01ED = rst ? 0 : ~(0|WEDOPG_|WL08_);
// Gate A12-U226A
pullup(S08_);
assign (highz1,strong0) #0.2  S08_ = rst ? 0 : ~(0|A12U226Pad2);
// Gate A12-U252B
pullup(A12U251Pad2);
assign (highz1,strong0) #0.2  A12U251Pad2 = rst ? 0 : ~(0|WG_);
// Gate A12-U236A
pullup(A12U236Pad1);
assign (highz1,strong0) #0.2  A12U236Pad1 = rst ? 0 : ~(0|A12U236Pad2|A12U231Pad1);
// Gate A12-U237A
pullup(A12U236Pad2);
assign (highz1,strong0) #0.2  A12U236Pad2 = rst ? 1 : ~(0|CSG|A12U236Pad1);
// Gate A12-U134A
pullup(A12G03_);
assign (highz1,strong0) #0.2  A12G03_ = rst ? 1 : ~(0|G03);
// Gate A12-U219A
pullup(S10);
assign (highz1,strong0) #0.2  S10 = rst ? 1 : ~(0|A12U219Pad2);
// Gate A12-U222A
pullup(G04ED);
assign (highz1,strong0) #0.2  G04ED = rst ? 0 : ~(0|WEDOPG_|WL11_);
// Gate A12-U258A
pullup(A12U257Pad2);
assign (highz1,strong0) #0.2  A12U257Pad2 = rst ? 1 : ~(0|CSG|A12U257Pad1);
// Gate A12-U154B
pullup(A12U154Pad9);
assign (highz1,strong0) #0.2  A12U154Pad9 = rst ? 1 : ~(0|G13);
// Gate A12-U133B
pullup(A12U133Pad9);
assign (highz1,strong0) #0.2  A12U133Pad9 = rst ? 0 : ~(0|G02|A12G03_|G01A_);
// Gate A12-U154A
pullup(A12U154Pad1);
assign (highz1,strong0) #0.2  A12U154Pad1 = rst ? 0 : ~(0|A12U148Pad1);
// Gate A12-U251A A12-U251B
pullup(WGA_);
assign (highz1,strong0) #0.2  WGA_ = rst ? 1 : ~(0|A12U251Pad2);
// Gate A12-U136A
pullup(PA03_);
assign (highz1,strong0) #0.2  PA03_ = rst ? 1 : ~(0|PA03);
// Gate A12-U245A A12-U245B
pullup(S04_);
assign (highz1,strong0) #0.2  S04_ = rst ? 0 : ~(0|A12U243Pad1);
// Gate A12-U257B
pullup(S07);
assign (highz1,strong0) #0.2  S07 = rst ? 1 : ~(0|A12U257Pad1);
// Gate A12-U118A A12-U116A
pullup(PALE);
assign (highz1,strong0) #0.2  PALE = rst ? 0 : ~(0|SCAD|GOJAM|A12U118Pad4|TPARG_|A12U116Pad3|d8XP5);
// Gate A12-U242A A12-U242B
pullup(S03_);
assign (highz1,strong0) #0.2  S03_ = rst ? 0 : ~(0|A12U240Pad2);
// Gate A12-U217A
pullup(S10_);
assign (highz1,strong0) #0.2  S10_ = rst ? 0 : ~(0|A12U217Pad2);
// Gate A12-U104A
pullup(A12U101Pad6);
assign (highz1,strong0) #0.2  A12U101Pad6 = rst ? 0 : ~(0|T12A|A12U101Pad2);
// Gate A12-U103B
pullup(A12U101Pad3);
assign (highz1,strong0) #0.2  A12U101Pad3 = rst ? 1 : ~(0|RAD);
// Gate A12-U107B A12-U105B
pullup(A12U101Pad2);
assign (highz1,strong0) #0.2  A12U101Pad2 = rst ? 1 : ~(0|RELPLS|EXTPLS|A12U101Pad6|INHPLS);
// Gate A12-U206A
pullup(A12U206Pad1);
assign (highz1,strong0) #0.2  A12U206Pad1 = rst ? 0 : ~(0|T12A|SR_);
// Gate A12-U145B
pullup(A12U145Pad9);
assign (highz1,strong0) #0.2  A12U145Pad9 = rst ? 0 : ~(0|A12U143Pad1|A12U142Pad1|G09);
// Gate A12-U137B
pullup(A12U137Pad9);
assign (highz1,strong0) #0.2  A12U137Pad9 = rst ? 1 : ~(0|G06|G04|G05);
// Gate A12-U207A
pullup(A12U206Pad8);
assign (highz1,strong0) #0.2  A12U206Pad8 = rst ? 0 : ~(0|CYR_|T12A);
// Gate A12-U139B
pullup(A12U137Pad2);
assign (highz1,strong0) #0.2  A12U137Pad2 = rst ? 1 : ~(0|G06);
// Gate A12-U138B
pullup(A12U137Pad3);
assign (highz1,strong0) #0.2  A12U137Pad3 = rst ? 1 : ~(0|G05);
// Gate A12-U137A
pullup(A12U137Pad1);
assign (highz1,strong0) #0.2  A12U137Pad1 = rst ? 0 : ~(0|A12U137Pad2|A12U137Pad3|G04);
// Gate A12-U209B
pullup(A12U207Pad8);
assign (highz1,strong0) #0.2  A12U207Pad8 = rst ? 0 : ~(0|T02_|A12U202Pad7|XB0_);
// Gate A12-U220A
pullup(A12U219Pad2);
assign (highz1,strong0) #0.2  A12U219Pad2 = rst ? 0 : ~(0|A12U220Pad2|A12U217Pad2);
// Gate A12-U238B
pullup(A12U238Pad9);
assign (highz1,strong0) #0.2  A12U238Pad9 = rst ? 0 : ~(0|WL04_|WSG_);
// Gate A12-U123A
pullup(PC15);
assign (highz1,strong0) #0.2  PC15 = rst ? 1 : ~(0|A12U123Pad2|A12U123Pad3);
// Gate A12-U122B
pullup(MGP_);
assign (highz1,strong0) #0.2  MGP_ = rst ? 0 : ~(0|PC15);
// Gate A12-U218A
pullup(A12U214Pad8);
assign (highz1,strong0) #0.2  A12U214Pad8 = rst ? 0 : ~(0|A12U216Pad8|CSG);
// Gate A12-U150B
pullup(A12U149Pad3);
assign (highz1,strong0) #0.2  A12U149Pad3 = rst ? 1 : ~(0|G11);
// Gate A12-U238A
pullup(A12U238Pad1);
assign (highz1,strong0) #0.2  A12U238Pad1 = rst ? 0 : ~(0|WSG_|WL03_);
// Gate A12-U111B
pullup(EAD09);
assign (highz1,strong0) #0.2  EAD09 = rst ? 0 : ~(0|A12U110Pad9|S09_);
// Gate A12-U208B
pullup(A12U208Pad2);
assign (highz1,strong0) #0.2  A12U208Pad2 = rst ? 0 : ~(0|XB1_|T02_|A12U202Pad7);
// Gate A12-U203B
pullup(CYL_);
assign (highz1,strong0) #0.2  CYL_ = rst ? 1 : ~(0|A12U203Pad1|A12U203Pad8);
// Gate A12-U227A
pullup(T03_);
assign (highz1,strong0) #0.2  T03_ = rst ? 1 : ~(0|T03);
// Gate A12-U141A
pullup(RSC_);
assign (highz1,strong0) #0.2  RSC_ = rst ? 1 : ~(0|BRXP3);
// Gate A12-U235B
pullup(RL03_);
assign (highz1,strong0) #0.2  RL03_ = rst ? 1 : ~(0|R6);
// Gate A12-U212A
pullup(G07ED);
assign (highz1,strong0) #0.2  G07ED = rst ? 0 : ~(0|WL14_|WEDOPG_);
// Gate A12-U226B
pullup(T04_);
assign (highz1,strong0) #0.2  T04_ = rst ? 1 : ~(0|T04);
// Gate A12-U218B
pullup(A12U216Pad8);
assign (highz1,strong0) #0.2  A12U216Pad8 = rst ? 1 : ~(0|A12U214Pad8|A12U218Pad8);
// Gate A12-U121A
pullup(A12U119Pad2);
assign (highz1,strong0) #0.2  A12U119Pad2 = rst ? 1 : ~(0|SAP|MONPAR|A12U119Pad8);
// Gate A12-U222B
pullup(G03ED);
assign (highz1,strong0) #0.2  G03ED = rst ? 0 : ~(0|WL10_|WEDOPG_);
// Gate A12-U253A
pullup(A12U252Pad2);
assign (highz1,strong0) #0.2  A12U252Pad2 = rst ? 0 : ~(0|CSG|A12U252Pad1);
// Gate A12-U103A
pullup(GEQZRO_);
assign (highz1,strong0) #0.2  GEQZRO_ = rst ? 0 : ~(0|A12U102Pad9);
// Gate A12-U211A A12-U216A A12-U214A
pullup(T12A);
assign (highz1,strong0) #0.2  T12A = rst ? 0 : ~(0|T12_);
// Gate A12-U258B
pullup(S07_);
assign (highz1,strong0) #0.2  S07_ = rst ? 0 : ~(0|A12U257Pad2);
// Gate A12-U202A
pullup(A12U201Pad2);
assign (highz1,strong0) #0.2  A12U201Pad2 = rst ? 0 : ~(0|T12A|EDOP_);
// Gate A12-U123B
pullup(PC15_);
assign (highz1,strong0) #0.2  PC15_ = rst ? 0 : ~(0|PC15);
// Gate A12-U149A
pullup(A12U149Pad1);
assign (highz1,strong0) #0.2  A12U149Pad1 = rst ? 0 : ~(0|A12U149Pad2|A12U149Pad3|G10);
// Gate A12-U121B
pullup(A12U119Pad8);
assign (highz1,strong0) #0.2  A12U119Pad8 = rst ? 0 : ~(0|CGG|A12U119Pad2);
// Gate A12-U153B
pullup(A12U149Pad2);
assign (highz1,strong0) #0.2  A12U149Pad2 = rst ? 1 : ~(0|G12);
// Gate A12-U112B
pullup(EAD10);
assign (highz1,strong0) #0.2  EAD10 = rst ? 1 : ~(0|S10_|A12U112Pad1);
// Gate A12-U113B
pullup(EAD11);
assign (highz1,strong0) #0.2  EAD11 = rst ? 0 : ~(0|S10_|S09_|EB11_);
// Gate A12-U149B
pullup(A12U149Pad9);
assign (highz1,strong0) #0.2  A12U149Pad9 = rst ? 1 : ~(0|G10);
// Gate A12-U157A
pullup(G16A_);
assign (highz1,strong0) #0.2  G16A_ = rst ? 1 : ~(0|G16);
// Gate A12-U119B
pullup(A12U118Pad4);
assign (highz1,strong0) #0.2  A12U118Pad4 = rst ? 0 : ~(0|PC15|A12U119Pad8);
// Gate A12-U160A
pullup(PA15_);
assign (highz1,strong0) #0.2  PA15_ = rst ? 1 : ~(0|PA15);
// Gate A12-U246A
pullup(RL05_);
assign (highz1,strong0) #0.2  RL05_ = rst ? 1 : ~(0|RPTAD5|CAD5);
// Gate A12-U146A
pullup(WG_);
assign (highz1,strong0) #0.2  WG_ = rst ? 1 : ~(0|BRXP3);
// Gate A12-U250A A12-U250B
pullup(S05_);
assign (highz1,strong0) #0.2  S05_ = rst ? 0 : ~(0|A12U248Pad1);
// Gate A12-U122A
pullup(MSCDBL_);
assign (highz1,strong0) #0.2  MSCDBL_ = rst ? 1 : ~(0|SCADBL);
// Gate A12-U233B A12-U234B
pullup(S01_);
assign (highz1,strong0) #0.2  S01_ = rst ? 1 : ~(0|A12U233Pad2);
// Gate A12-U229A
pullup(A12U225Pad2);
assign (highz1,strong0) #0.2  A12U225Pad2 = rst ? 0 : ~(0|WL09_|WSG_);
// Gate A12-U260A
pullup(A12J4Pad458);
assign (highz1,strong0) #0.2  A12J4Pad458 = rst ? 1 : ~(0);
// Gate A12-U136B
pullup(A12U136Pad9);
assign (highz1,strong0) #0.2  A12U136Pad9 = rst ? 1 : ~(0|G04);
// Gate A12-U204A
pullup(A12U203Pad8);
assign (highz1,strong0) #0.2  A12U203Pad8 = rst ? 0 : ~(0|XB2_|A12U202Pad7|T02_);
// Gate A12-U132B
pullup(A12G02_);
assign (highz1,strong0) #0.2  A12G02_ = rst ? 1 : ~(0|G02);
// Gate A12-U134B
pullup(A12U134Pad9);
assign (highz1,strong0) #0.2  A12U134Pad9 = rst ? 0 : ~(0|A12G02_|G03|G01A_);
// Gate A12-U223A A12-U223B
pullup(S09_);
assign (highz1,strong0) #0.2  S09_ = rst ? 1 : ~(0|A12U223Pad2);
// Gate A12-U206B A12-U205B
pullup(A12U204Pad8);
assign (highz1,strong0) #0.2  A12U204Pad8 = rst ? 1 : ~(0|A12U206Pad1|A12U206Pad8|A12U203Pad1|A12U201Pad2);
// Gate A12-U140A
pullup(PA06_);
assign (highz1,strong0) #0.2  PA06_ = rst ? 1 : ~(0|PA06);
// Gate A12-U138A
pullup(A12U138Pad1);
assign (highz1,strong0) #0.2  A12U138Pad1 = rst ? 0 : ~(0|A12U137Pad2|A12U136Pad9|G05);
// Gate A12-U202B
pullup(A12U201Pad3);
assign (highz1,strong0) #0.2  A12U201Pad3 = rst ? 0 : ~(0|T02_|A12U202Pad7|XB3_);
// Gate A12-U228B
pullup(A12U226Pad2);
assign (highz1,strong0) #0.2  A12U226Pad2 = rst ? 1 : ~(0|CSG|A12U227Pad8);
// Gate A12-U201A
pullup(EDOP_);
assign (highz1,strong0) #0.2  EDOP_ = rst ? 1 : ~(0|A12U201Pad2|A12U201Pad3);
// Gate A12-U252A
pullup(A12U252Pad1);
assign (highz1,strong0) #0.2  A12U252Pad1 = rst ? 1 : ~(0|A12U252Pad2|A12U247Pad1);
// Gate A12-U256B
pullup(L02A_);
assign (highz1,strong0) #0.2  L02A_ = rst ? 0 : ~(0|A12U256Pad1);
// Gate A12-U125B
pullup(PB15_);
assign (highz1,strong0) #0.2  PB15_ = rst ? 1 : ~(0|PB15);
// Gate A12-U213B
pullup(A12U212Pad7);
assign (highz1,strong0) #0.2  A12U212Pad7 = rst ? 0 : ~(0|WSG_|WL12_);
// Gate A12-U120A
pullup(GEMP);
assign (highz1,strong0) #0.2  GEMP = rst ? 1 : ~(0|PC15_);
// Gate A12-U211B
pullup(S12);
assign (highz1,strong0) #0.2  S12 = rst ? 1 : ~(0|A12U211Pad8);
// Gate A12-U147A
pullup(PA09_);
assign (highz1,strong0) #0.2  PA09_ = rst ? 1 : ~(0|PA09);
// Gate A12-U215B
pullup(G06ED);
assign (highz1,strong0) #0.2  G06ED = rst ? 0 : ~(0|WEDOPG_|WL13_);
// Gate A12-U255A A12-U255B
pullup(S06_);
assign (highz1,strong0) #0.2  S06_ = rst ? 1 : ~(0|A12U252Pad2);
// Gate A12-U209A
pullup(A12U202Pad7);
assign (highz1,strong0) #0.2  A12U202Pad7 = rst ? 1 : ~(0|OCTAD2);
// Gate A12-U119A
pullup(A12U116Pad3);
assign (highz1,strong0) #0.2  A12U116Pad3 = rst ? 0 : ~(0|A12U119Pad2|PC15_);
// Gate A12-U158B
pullup(A12U158Pad9);
assign (highz1,strong0) #0.2  A12U158Pad9 = rst ? 0 : ~(0|A12U155Pad9);
// Gate A12-U130B
pullup(A12U127Pad3);
assign (highz1,strong0) #0.2  A12U127Pad3 = rst ? 0 : ~(0|PA06_|PA09_|PA03);
// Gate A12-U130A
pullup(A12U127Pad2);
assign (highz1,strong0) #0.2  A12U127Pad2 = rst ? 1 : ~(0|PA03|PA06|PA09);
// Gate A12-U113A
pullup(EAD10_);
assign (highz1,strong0) #0.2  EAD10_ = rst ? 0 : ~(0|EAD10);
// Gate A12-U108B
pullup(EXTPLS);
assign (highz1,strong0) #0.2  EXTPLS = rst ? 0 : ~(0|A12U102Pad3|A12U108Pad7|A12U102Pad2);
// Gate A12-U126A
pullup(A12U125Pad3);
assign (highz1,strong0) #0.2  A12U125Pad3 = rst ? 1 : ~(0|PA12|PA15);
// Gate A12-U126B
pullup(A12U125Pad2);
assign (highz1,strong0) #0.2  A12U125Pad2 = rst ? 0 : ~(0|PA15_|PA12_);
// Gate A12-U129A
pullup(A12U128Pad2);
assign (highz1,strong0) #0.2  A12U128Pad2 = rst ? 0 : ~(0|PA06|PA03_|PA09_);
// Gate A12-U129B
pullup(A12U128Pad3);
assign (highz1,strong0) #0.2  A12U128Pad3 = rst ? 0 : ~(0|PA09|PA06_|PA03_);
// Gate A12-U114A
pullup(BRXP3);
assign (highz1,strong0) #0.2  BRXP3 = rst ? 0 : ~(0|T03_|IC15_);
// Gate A12-U243A
pullup(A12U243Pad1);
assign (highz1,strong0) #0.2  A12U243Pad1 = rst ? 1 : ~(0|A12U243Pad2|CSG);
// Gate A12-U131A
pullup(A12U131Pad1);
assign (highz1,strong0) #0.2  A12U131Pad1 = rst ? 1 : ~(0|G02|G03|G01);
// Gate A12-U110B
pullup(A12U110Pad9);
assign (highz1,strong0) #0.2  A12U110Pad9 = rst ? 0 : ~(0|EB9|S10_);
// Gate A12-U131B
pullup(G01A_);
assign (highz1,strong0) #0.2  G01A_ = rst ? 1 : ~(0|G01);
// Gate A12-U101A
pullup(RADRZ);
assign (highz1,strong0) #0.2  RADRZ = rst ? 0 : ~(0|A12U101Pad2|A12U101Pad3);
// Gate A12-U243B
pullup(A12U243Pad2);
assign (highz1,strong0) #0.2  A12U243Pad2 = rst ? 0 : ~(0|A12U238Pad9|A12U243Pad1);
// Gate A12-U128A A12-U127A
pullup(PB09);
assign (highz1,strong0) #0.2  PB09 = rst ? 0 : ~(0|A12U128Pad2|A12U128Pad3|A12U127Pad2|A12U127Pad3);
// Gate A12-U220B
pullup(A12U218Pad8);
assign (highz1,strong0) #0.2  A12U218Pad8 = rst ? 0 : ~(0|WSG_|WL11_);
// Gate A12-U101B
pullup(RADRG);
assign (highz1,strong0) #0.2  RADRG = rst ? 0 : ~(0|A12U101Pad6|A12U101Pad3);
// Gate A12-U109B
pullup(A12U102Pad2);
assign (highz1,strong0) #0.2  A12U102Pad2 = rst ? 1 : ~(0|A12U109Pad8);
// Gate A12-U108A
pullup(A12U102Pad3);
assign (highz1,strong0) #0.2  A12U102Pad3 = rst ? 0 : ~(0|GNZRO);
// Gate A12-U109A
pullup(A12U108Pad7);
assign (highz1,strong0) #0.2  A12U108Pad7 = rst ? 1 : ~(0|A12U109Pad4);
// Gate A12-U208A
pullup(SR_);
assign (highz1,strong0) #0.2  SR_ = rst ? 1 : ~(0|A12U208Pad2|A12U206Pad1);
// Gate A12-U104B A12-U102B
pullup(A12U102Pad9);
assign (highz1,strong0) #0.2  A12U102Pad9 = rst ? 1 : ~(0|A12U102Pad3|G02|G01|G03);
// Gate A12-U227B
pullup(S08);
assign (highz1,strong0) #0.2  S08 = rst ? 1 : ~(0|A12U227Pad8);
// Gate A12-U224B
pullup(S09);
assign (highz1,strong0) #0.2  S09 = rst ? 0 : ~(0|A12U224Pad8);
// Gate A12-U225A
pullup(A12U224Pad8);
assign (highz1,strong0) #0.2  A12U224Pad8 = rst ? 1 : ~(0|A12U225Pad2|A12U223Pad2);
// Gate A12-U224A
pullup(T05_);
assign (highz1,strong0) #0.2  T05_ = rst ? 1 : ~(0|T05);
// Gate A12-U231B A12-U232B
pullup(S01);
assign (highz1,strong0) #0.2  S01 = rst ? 0 : ~(0|A12U231Pad8);
// Gate A12-U236B A12-U237B
pullup(S02);
assign (highz1,strong0) #0.2  S02 = rst ? 1 : ~(0|A12U236Pad1);
// Gate A12-U241B A12-U240B
pullup(S03);
assign (highz1,strong0) #0.2  S03 = rst ? 1 : ~(0|A12U240Pad1);
// Gate A12-U244A A12-U244B
pullup(S04);
assign (highz1,strong0) #0.2  S04 = rst ? 1 : ~(0|A12U243Pad2);
// Gate A12-U249A A12-U249B
pullup(S05);
assign (highz1,strong0) #0.2  S05 = rst ? 1 : ~(0|A12U248Pad2);
// Gate A12-U147B
pullup(A12U147Pad9);
assign (highz1,strong0) #0.2  A12U147Pad9 = rst ? 0 : ~(0|A12U142Pad9);
// Gate A12-U207B
pullup(CYR_);
assign (highz1,strong0) #0.2  CYR_ = rst ? 1 : ~(0|A12U206Pad8|A12U207Pad8);
// Gate A12-U124B
pullup(A12U123Pad3);
assign (highz1,strong0) #0.2  A12U123Pad3 = rst ? 0 : ~(0|PB09|PB15_);
// Gate A12-U124A
pullup(A12U123Pad2);
assign (highz1,strong0) #0.2  A12U123Pad2 = rst ? 0 : ~(0|PB15|PB09_);
// Gate A12-U247A
pullup(A12U247Pad1);
assign (highz1,strong0) #0.2  A12U247Pad1 = rst ? 0 : ~(0|WSG_|WL06_);
// Gate A12-U228A
pullup(A12U227Pad8);
assign (highz1,strong0) #0.2  A12U227Pad8 = rst ? 0 : ~(0|A12U228Pad2|A12U226Pad2);
// Gate A12-U247B
pullup(A12U247Pad9);
assign (highz1,strong0) #0.2  A12U247Pad9 = rst ? 0 : ~(0|WL05_|WSG_);
// Gate A12-U221B
pullup(A12U220Pad2);
assign (highz1,strong0) #0.2  A12U220Pad2 = rst ? 0 : ~(0|WSG_|WL10_);
// Gate A12-U256A
pullup(A12U256Pad1);
assign (highz1,strong0) #0.2  A12U256Pad1 = rst ? 1 : ~(0|L02_);
// Gate A12-U125A
pullup(PB15);
assign (highz1,strong0) #0.2  PB15 = rst ? 0 : ~(0|A12U125Pad2|A12U125Pad3);
// Gate A12-U229B
pullup(A12U228Pad2);
assign (highz1,strong0) #0.2  A12U228Pad2 = rst ? 0 : ~(0|WSG_|WL08_);
// Gate A12-U112A
pullup(A12U112Pad1);
assign (highz1,strong0) #0.2  A12U112Pad1 = rst ? 0 : ~(0|S09_|EB10);
// Gate A12-U201B
pullup(SHIFT);
assign (highz1,strong0) #0.2  SHIFT = rst ? 0 : ~(0|SHIFT_);
// Gate A12-U205A
pullup(A12J3Pad310);
assign (highz1,strong0) #0.2  A12J3Pad310 = rst ? 1 : ~(0);
// Gate A12-U257A
pullup(A12U257Pad1);
assign (highz1,strong0) #0.2  A12U257Pad1 = rst ? 0 : ~(0|A12U257Pad2|A12U254Pad1);
// Gate A12-U120B
pullup(MSP);
assign (highz1,strong0) #0.2  MSP = rst ? 0 : ~(0|A12U119Pad2);
// Gate A12-U152B A12-U150A
pullup(PA12);
assign (highz1,strong0) #0.2  PA12 = rst ? 0 : ~(0|A12U151Pad9|A12U151Pad1|A12U148Pad1|A12U149Pad1);
// Gate A12-U148B
pullup(A12U148Pad9);
assign (highz1,strong0) #0.2  A12U148Pad9 = rst ? 0 : ~(0|A12U137Pad9);
// Gate A12-U159A A12-U157B
pullup(PA15);
assign (highz1,strong0) #0.2  PA15 = rst ? 0 : ~(0|A12U158Pad1|A12U156Pad9|A12U155Pad9|A12U156Pad1);
// Gate A12-U217B
pullup(T10_);
assign (highz1,strong0) #0.2  T10_ = rst ? 1 : ~(0|T10);
// Gate A12-U148A
pullup(A12U148Pad1);
assign (highz1,strong0) #0.2  A12U148Pad1 = rst ? 1 : ~(0|G12|G10|G11);
// Gate A12-U246B
pullup(RL06_);
assign (highz1,strong0) #0.2  RL06_ = rst ? 1 : ~(0|CAD6|RPTAD6);
// Gate A12-U215A
pullup(G05ED);
assign (highz1,strong0) #0.2  G05ED = rst ? 0 : ~(0|WEDOPG_|WL12_);
// Gate A12-U259A
pullup(A12U259Pad1);
assign (highz1,strong0) #0.2  A12U259Pad1 = rst ? 0 : ~(0|L15_);
// Gate A12-U210A
pullup(S12_);
assign (highz1,strong0) #0.2  S12_ = rst ? 0 : ~(0|A12U210Pad2);
// Gate A12-U231A
pullup(A12U231Pad1);
assign (highz1,strong0) #0.2  A12U231Pad1 = rst ? 0 : ~(0|WL02_|WSG_);
// Gate A12-U259B
pullup(L15A_);
assign (highz1,strong0) #0.2  L15A_ = rst ? 1 : ~(0|A12U259Pad1);
// Gate A12-U233A
pullup(A12U231Pad8);
assign (highz1,strong0) #0.2  A12U231Pad8 = rst ? 1 : ~(0|A12U233Pad2|A12U232Pad1);
// Gate A12-U156A
pullup(A12U156Pad1);
assign (highz1,strong0) #0.2  A12U156Pad1 = rst ? 0 : ~(0|G16A_|A12U155Pad1|G13);
// Gate A12-U132A
pullup(A12U109Pad4);
assign (highz1,strong0) #0.2  A12U109Pad4 = rst ? 0 : ~(0|A12G03_|A12G02_|G01);
// Gate A12-U156B
pullup(A12U156Pad9);
assign (highz1,strong0) #0.2  A12U156Pad9 = rst ? 0 : ~(0|A12U154Pad9|G14|G16A_);
// Gate A12-U110A
pullup(A12U109Pad8);
assign (highz1,strong0) #0.2  A12U109Pad8 = rst ? 0 : ~(0|T7PHS4_|TSUDO_);
// Gate A12-U234A
pullup(A12U233Pad2);
assign (highz1,strong0) #0.2  A12U233Pad2 = rst ? 0 : ~(0|CSG|A12U231Pad8);
// Gate A12-U204B
pullup(GINH);
assign (highz1,strong0) #0.2  GINH = rst ? 0 : ~(0|A12U204Pad8);
// Gate A12-U155B
pullup(A12U155Pad9);
assign (highz1,strong0) #0.2  A12U155Pad9 = rst ? 1 : ~(0|G16|G13|G14);
// Gate A12-U144A
pullup(A12U144Pad1);
assign (highz1,strong0) #0.2  A12U144Pad1 = rst ? 0 : ~(0|A12U143Pad7|A12U142Pad1|G08);
// Gate A12-U155A
pullup(A12U155Pad1);
assign (highz1,strong0) #0.2  A12U155Pad1 = rst ? 1 : ~(0|G14);
// Gate A12-U142A
pullup(A12U142Pad1);
assign (highz1,strong0) #0.2  A12U142Pad1 = rst ? 1 : ~(0|G07);
// Gate A12-U146B A12-U144B
pullup(PA09);
assign (highz1,strong0) #0.2  PA09 = rst ? 0 : ~(0|A12U144Pad1|A12U145Pad9|A12U143Pad9|A12U142Pad9);
// Gate A12-U158A
pullup(A12U158Pad1);
assign (highz1,strong0) #0.2  A12U158Pad1 = rst ? 0 : ~(0|A12U154Pad9|A12U155Pad1|G16);
// Gate A12-U142B
pullup(A12U142Pad9);
assign (highz1,strong0) #0.2  A12U142Pad9 = rst ? 1 : ~(0|G07|G09|G08);
// Gate A12-U111A
pullup(EAD09_);
assign (highz1,strong0) #0.2  EAD09_ = rst ? 1 : ~(0|EAD09);
// Gate A12-U203A
pullup(A12U203Pad1);
assign (highz1,strong0) #0.2  A12U203Pad1 = rst ? 0 : ~(0|CYL_|T12A);
// Gate A12-U135B A12-U133A
pullup(PA03);
assign (highz1,strong0) #0.2  PA03 = rst ? 0 : ~(0|A12U134Pad9|A12U133Pad9|A12U131Pad1|A12U109Pad4);
// Gate A12-U214B
pullup(S11_);
assign (highz1,strong0) #0.2  S11_ = rst ? 1 : ~(0|A12U214Pad8);
// Gate A12-U230B
pullup(G02ED);
assign (highz1,strong0) #0.2  G02ED = rst ? 0 : ~(0|WL09_|WEDOPG_);
// Gate A12-U219B
pullup(T07_);
assign (highz1,strong0) #0.2  T07_ = rst ? 1 : ~(0|T07);
// Gate A12-U127B
pullup(PB09_);
assign (highz1,strong0) #0.2  PB09_ = rst ? 1 : ~(0|PB09);
// Gate A12-U225B
pullup(A12U223Pad2);
assign (highz1,strong0) #0.2  A12U223Pad2 = rst ? 0 : ~(0|CSG|A12U224Pad8);
// Gate A12-U153A
pullup(PA12_);
assign (highz1,strong0) #0.2  PA12_ = rst ? 1 : ~(0|PA12);
// Gate A12-U212B
pullup(A12U211Pad8);
assign (highz1,strong0) #0.2  A12U211Pad8 = rst ? 0 : ~(0|A12U210Pad2|A12U212Pad7|d8XP5);
// Gate A12-U106B A12-U102A
pullup(INHPLS);
assign (highz1,strong0) #0.2  INHPLS = rst ? 0 : ~(0|G02|A12G03_|A12U102Pad2|A12U102Pad3|G01);
// Gate A12-U151B
pullup(A12U151Pad9);
assign (highz1,strong0) #0.2  A12U151Pad9 = rst ? 0 : ~(0|G11|A12U149Pad9|A12U149Pad2);
// Gate A12-U140B
pullup(A12U140Pad9);
assign (highz1,strong0) #0.2  A12U140Pad9 = rst ? 0 : ~(0|G06|A12U137Pad3|A12U136Pad9);
// Gate A12-U117B
pullup(MPAL_);
assign (highz1,strong0) #0.2  MPAL_ = rst ? 1 : ~(0|PALE);
// Gate A12-U210B
pullup(SHIFT_);
assign (highz1,strong0) #0.2  SHIFT_ = rst ? 1 : ~(0|SHANC|SHINC);
// Gate A12-U151A
pullup(A12U151Pad1);
assign (highz1,strong0) #0.2  A12U151Pad1 = rst ? 0 : ~(0|A12U149Pad3|A12U149Pad9|G12);

endmodule
