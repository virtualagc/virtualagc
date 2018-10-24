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
  SCAD, SCADBL, SHANC, SHINC, T02_, T03, T04, T05, T07, T10, T12_, T7PHS4_,
  TPARG_, TSUDO_, WEDOPG_, WL01_, WL02_, WL03_, WL04_, WL05_, WL06_, WL07_,
  WL08_, WL09_, WL10_, WL11_, WL12_, WL13_, WL14_, WSG_, XB0_, XB1_, XB2_,
  XB3_, d8XP5;

input wire SAP;

inout wire BRXP3, G01A_, GEMP, GNZRO, MGP_, MPAL_, MSCDBL_, MSP, PA03, PA03_,
  PA06, PA06_, PA09, PA09_, PA12, PA12_, PA15, PA15_, RL03_, RL04_, RL05_,
  RL06_, RSC_, S09_, S10_, T03_, T04_, T05_, T07_, T10_, T12A, WG_;

output wire CYL_, CYR_, EAD09, EAD09_, EAD10, EAD10_, EAD11, EAD11_, EDOP_,
  EXTPLS, G01A, G01ED, G02ED, G03ED, G04ED, G05ED, G06ED, G07ED, G16A_, GEQZRO_,
  GINH, INHPLS, L02A_, L15A_, PALE, PB09, PB09_, PB15, PB15_, PC15, PC15_,
  RADRG, RADRZ, RELPLS, S01, S01_, S02, S02_, S03, S03_, S04, S04_, S05,
  S05_, S06, S06_, S07, S07_, S08, S08_, S09, S10, S11, S11_, S12, S12_,
  SHIFT, SHIFT_, SR_, WGA_;

parameter GATE_DELAY = 0.2; // This default may be overridden at compile time.
initial $display("Gate delay (A12) will be %f ns.", GATE_DELAY*100);

// Gate A12-U241A
pullup(g34417);
assign #GATE_DELAY g34417 = rst ? 0 : ((0|g34416|CSG) ? 1'b0 : 1'bz);
// Gate A12-U240A
pullup(g34416);
assign #GATE_DELAY g34416 = rst ? 1'bz : ((0|g34415|g34417) ? 1'b0 : 1'bz);
// Gate A12-U232A
pullup(g34401);
assign #GATE_DELAY g34401 = rst ? 0 : ((0|WL01_|WSG_) ? 1'b0 : 1'bz);
// Gate A12-U248B
pullup(g34430);
assign #GATE_DELAY g34430 = rst ? 1'bz : ((0|g34429|g34431) ? 1'b0 : 1'bz);
// Gate A12-U248A
pullup(g34431);
assign #GATE_DELAY g34431 = rst ? 0 : ((0|CSG|g34430) ? 1'b0 : 1'bz);
// Gate A12-U139A A12-U141B
pullup(PA06);
assign #GATE_DELAY PA06 = rst ? 0 : ((0|g34115|g34114|g34116|g34117) ? 1'b0 : 1'bz);
// Gate A12-U235A
pullup(RL04_);
assign #GATE_DELAY RL04_ = rst ? 1'bz : ((0|RPTAD4|CAD4) ? 1'b0 : 1'bz);
// Gate A12-U143A
pullup(g34123);
assign #GATE_DELAY g34123 = rst ? 1'bz : ((0|G08) ? 1'b0 : 1'bz);
// Gate A12-U135A A12-U159B A12-U160B
pullup(GNZRO);
assign #GATE_DELAY GNZRO = rst ? 0 : ((0|G15|g34121|g34132|g34142|g34154) ? 1'b0 : 1'bz);
// Gate A12-U145A
pullup(g34124);
assign #GATE_DELAY g34124 = rst ? 1'bz : ((0|G09) ? 1'b0 : 1'bz);
// Gate A12-U107A A12-U106A
pullup(RELPLS);
assign #GATE_DELAY RELPLS = rst ? 0 : ((0|G03|_A12_1_G02_|G01A_|g34204|g34202) ? 1'b0 : 1'bz);
// Gate A12-U213A
pullup(g34336);
assign #GATE_DELAY g34336 = rst ? 0 : ((0|g34335|CSG) ? 1'b0 : 1'bz);
// Gate A12-U114B
pullup(EAD11_);
assign #GATE_DELAY EAD11_ = rst ? 1'bz : ((0|EAD11) ? 1'b0 : 1'bz);
// Gate A12-U143B
pullup(g34126);
assign #GATE_DELAY g34126 = rst ? 0 : ((0|G07|g34124|g34123) ? 1'b0 : 1'bz);
// Gate A12-U216B
pullup(S11);
assign #GATE_DELAY S11 = rst ? 1'bz : ((0|g34327) ? 1'b0 : 1'bz);
// Gate A12-U260B
pullup(G01A);
assign #GATE_DELAY G01A = rst ? 0 : ((0|G01A_) ? 1'b0 : 1'bz);
// Gate A12-U239A A12-U239B
pullup(S02_);
assign #GATE_DELAY S02_ = rst ? 1'bz : ((0|g34410) ? 1'b0 : 1'bz);
// Gate A12-U254A
pullup(g34443);
assign #GATE_DELAY g34443 = rst ? 0 : ((0|WL07_|WSG_) ? 1'b0 : 1'bz);
// Gate A12-U221A
pullup(g34320);
assign #GATE_DELAY g34320 = rst ? 0 : ((0|g34319|CSG) ? 1'b0 : 1'bz);
// Gate A12-U254B A12-U253B
pullup(S06);
assign #GATE_DELAY S06 = rst ? 0 : ((0|g34437) ? 1'b0 : 1'bz);
// Gate A12-U230A
pullup(G01ED);
assign #GATE_DELAY G01ED = rst ? 0 : ((0|WL08_|WEDOPG_) ? 1'b0 : 1'bz);
// Gate A12-U226A
pullup(S08_);
assign #GATE_DELAY S08_ = rst ? 1'bz : ((0|g34304) ? 1'b0 : 1'bz);
// Gate A12-U252B
pullup(g34467);
assign #GATE_DELAY g34467 = rst ? 0 : ((0|WG_) ? 1'b0 : 1'bz);
// Gate A12-U236A
pullup(g34409);
assign #GATE_DELAY g34409 = rst ? 1'bz : ((0|g34408|g34410) ? 1'b0 : 1'bz);
// Gate A12-U237A
pullup(g34410);
assign #GATE_DELAY g34410 = rst ? 0 : ((0|g34409|CSG) ? 1'b0 : 1'bz);
// Gate A12-U132B
pullup(_A12_1_G02_);
assign #GATE_DELAY _A12_1_G02_ = rst ? 1'bz : ((0|G02) ? 1'b0 : 1'bz);
// Gate A12-U219A
pullup(S10);
assign #GATE_DELAY S10 = rst ? 0 : ((0|g34319) ? 1'b0 : 1'bz);
// Gate A12-U222A
pullup(G04ED);
assign #GATE_DELAY G04ED = rst ? 0 : ((0|WL11_|WEDOPG_) ? 1'b0 : 1'bz);
// Gate A12-U258A
pullup(g34445);
assign #GATE_DELAY g34445 = rst ? 0 : ((0|g34444|CSG) ? 1'b0 : 1'bz);
// Gate A12-U154B
pullup(g34144);
assign #GATE_DELAY g34144 = rst ? 1'bz : ((0|G13) ? 1'b0 : 1'bz);
// Gate A12-U133B
pullup(g34106);
assign #GATE_DELAY g34106 = rst ? 0 : ((0|G02|_A12_1_G03_|G01A_) ? 1'b0 : 1'bz);
// Gate A12-U154A
pullup(g34142);
assign #GATE_DELAY g34142 = rst ? 0 : ((0|g34136) ? 1'b0 : 1'bz);
// Gate A12-U251A A12-U251B
pullup(WGA_);
assign #GATE_DELAY WGA_ = rst ? 1'bz : ((0|g34467) ? 1'b0 : 1'bz);
// Gate A12-U136A
pullup(PA03_);
assign #GATE_DELAY PA03_ = rst ? 1'bz : ((0|PA03) ? 1'b0 : 1'bz);
// Gate A12-U245A A12-U245B
pullup(S04_);
assign #GATE_DELAY S04_ = rst ? 1'bz : ((0|g34424) ? 1'b0 : 1'bz);
// Gate A12-U257B
pullup(S07);
assign #GATE_DELAY S07 = rst ? 0 : ((0|g34444) ? 1'b0 : 1'bz);
// Gate A12-U118A A12-U116A
pullup(PALE);
assign #GATE_DELAY PALE = rst ? 0 : ((0|g34248|GOJAM|SCAD|d8XP5|g34247|TPARG_) ? 1'b0 : 1'bz);
// Gate A12-U242A A12-U242B
pullup(S03_);
assign #GATE_DELAY S03_ = rst ? 1'bz : ((0|g34417) ? 1'b0 : 1'bz);
// Gate A12-U217A
pullup(S10_);
assign #GATE_DELAY S10_ = rst ? 1'bz : ((0|g34320) ? 1'b0 : 1'bz);
// Gate A12-U104A
pullup(g34210);
assign #GATE_DELAY g34210 = rst ? 0 : ((0|g34209|T12A) ? 1'b0 : 1'bz);
// Gate A12-U103B
pullup(g34211);
assign #GATE_DELAY g34211 = rst ? 1'bz : ((0|RAD) ? 1'b0 : 1'bz);
// Gate A12-U107B A12-U105B
pullup(g34209);
assign #GATE_DELAY g34209 = rst ? 1'bz : ((0|RELPLS|EXTPLS|g34210|INHPLS) ? 1'b0 : 1'bz);
// Gate A12-U206A
pullup(g34351);
assign #GATE_DELAY g34351 = rst ? 0 : ((0|SR_|T12A) ? 1'b0 : 1'bz);
// Gate A12-U103A
pullup(GEQZRO_);
assign #GATE_DELAY GEQZRO_ = rst ? 1'bz : ((0|g34217) ? 1'b0 : 1'bz);
// Gate A12-U137B
pullup(g34114);
assign #GATE_DELAY g34114 = rst ? 1'bz : ((0|G06|G04|G05) ? 1'b0 : 1'bz);
// Gate A12-U207A
pullup(g34349);
assign #GATE_DELAY g34349 = rst ? 0 : ((0|T12A|CYR_) ? 1'b0 : 1'bz);
// Gate A12-U139B
pullup(g34113);
assign #GATE_DELAY g34113 = rst ? 1'bz : ((0|G06) ? 1'b0 : 1'bz);
// Gate A12-U138B
pullup(g34112);
assign #GATE_DELAY g34112 = rst ? 1'bz : ((0|G05) ? 1'b0 : 1'bz);
// Gate A12-U137A
pullup(g34115);
assign #GATE_DELAY g34115 = rst ? 0 : ((0|G04|g34112|g34113) ? 1'b0 : 1'bz);
// Gate A12-U209B
pullup(g34344);
assign #GATE_DELAY g34344 = rst ? 0 : ((0|T02_|g34343|XB0_) ? 1'b0 : 1'bz);
// Gate A12-U220A
pullup(g34319);
assign #GATE_DELAY g34319 = rst ? 1'bz : ((0|g34320|g34318) ? 1'b0 : 1'bz);
// Gate A12-U238B
pullup(g34422);
assign #GATE_DELAY g34422 = rst ? 0 : ((0|WL04_|WSG_) ? 1'b0 : 1'bz);
// Gate A12-U123A
pullup(PC15);
assign #GATE_DELAY PC15 = rst ? 1'bz : ((0|g34239|g34238) ? 1'b0 : 1'bz);
// Gate A12-U122B
pullup(MGP_);
assign #GATE_DELAY MGP_ = rst ? 0 : ((0|PC15) ? 1'b0 : 1'bz);
// Gate A12-U218A
pullup(g34328);
assign #GATE_DELAY g34328 = rst ? 1'bz : ((0|CSG|g34327) ? 1'b0 : 1'bz);
// Gate A12-U150B
pullup(g34134);
assign #GATE_DELAY g34134 = rst ? 1'bz : ((0|G11) ? 1'b0 : 1'bz);
// Gate A12-U238A
pullup(g34415);
assign #GATE_DELAY g34415 = rst ? 0 : ((0|WL03_|WSG_) ? 1'b0 : 1'bz);
// Gate A12-U111B
pullup(EAD09);
assign #GATE_DELAY EAD09 = rst ? 0 : ((0|g34219|S09_) ? 1'b0 : 1'bz);
// Gate A12-U208B
pullup(g34345);
assign #GATE_DELAY g34345 = rst ? 0 : ((0|XB1_|T02_|g34343) ? 1'b0 : 1'bz);
// Gate A12-U203B
pullup(CYL_);
assign #GATE_DELAY CYL_ = rst ? 1'bz : ((0|g34353|g34346) ? 1'b0 : 1'bz);
// Gate A12-U227A
pullup(T03_);
assign #GATE_DELAY T03_ = rst ? 1'bz : ((0|T03) ? 1'b0 : 1'bz);
// Gate A12-U141A
pullup(RSC_);
assign #GATE_DELAY RSC_ = rst ? 1'bz : ((0|BRXP3) ? 1'b0 : 1'bz);
// Gate A12-U235B
pullup(RL03_);
assign #GATE_DELAY RL03_ = rst ? 1'bz : ((0|R6) ? 1'b0 : 1'bz);
// Gate A12-U212A
pullup(G07ED);
assign #GATE_DELAY G07ED = rst ? 0 : ((0|WEDOPG_|WL14_) ? 1'b0 : 1'bz);
// Gate A12-U125B
pullup(PB15_);
assign #GATE_DELAY PB15_ = rst ? 1'bz : ((0|PB15) ? 1'b0 : 1'bz);
// Gate A12-U226B
pullup(T04_);
assign #GATE_DELAY T04_ = rst ? 1'bz : ((0|T04) ? 1'b0 : 1'bz);
// Gate A12-U218B
pullup(g34327);
assign #GATE_DELAY g34327 = rst ? 0 : ((0|g34328|g34326) ? 1'b0 : 1'bz);
// Gate A12-U121A
pullup(g34245);
assign #GATE_DELAY g34245 = rst ? 1'bz : ((0|g34246|MONPAR|SAP) ? 1'b0 : 1'bz);
// Gate A12-U222B
pullup(G03ED);
assign #GATE_DELAY G03ED = rst ? 0 : ((0|WL10_|WEDOPG_) ? 1'b0 : 1'bz);
// Gate A12-U253A
pullup(g34438);
assign #GATE_DELAY g34438 = rst ? 0 : ((0|g34437|CSG) ? 1'b0 : 1'bz);
// Gate A12-U145B
pullup(g34128);
assign #GATE_DELAY g34128 = rst ? 0 : ((0|g34123|g34122|G09) ? 1'b0 : 1'bz);
// Gate A12-U211A A12-U216A A12-U214A
pullup(T12A);
assign #GATE_DELAY T12A = rst ? 1'bz : ((0|T12_) ? 1'b0 : 1'bz);
// Gate A12-U258B
pullup(S07_);
assign #GATE_DELAY S07_ = rst ? 1'bz : ((0|g34445) ? 1'b0 : 1'bz);
// Gate A12-U202A
pullup(g34355);
assign #GATE_DELAY g34355 = rst ? 0 : ((0|EDOP_|T12A) ? 1'b0 : 1'bz);
// Gate A12-U123B
pullup(PC15_);
assign #GATE_DELAY PC15_ = rst ? 0 : ((0|PC15) ? 1'b0 : 1'bz);
// Gate A12-U149A
pullup(g34137);
assign #GATE_DELAY g34137 = rst ? 0 : ((0|G10|g34134|g34135) ? 1'b0 : 1'bz);
// Gate A12-U121B
pullup(g34246);
assign #GATE_DELAY g34246 = rst ? 0 : ((0|CGG|g34245) ? 1'b0 : 1'bz);
// Gate A12-U153B
pullup(g34135);
assign #GATE_DELAY g34135 = rst ? 1'bz : ((0|G12) ? 1'b0 : 1'bz);
// Gate A12-U112B
pullup(EAD10);
assign #GATE_DELAY EAD10 = rst ? 0 : ((0|S10_|g34220) ? 1'b0 : 1'bz);
// Gate A12-U113B
pullup(EAD11);
assign #GATE_DELAY EAD11 = rst ? 0 : ((0|S10_|S09_|EB11_) ? 1'b0 : 1'bz);
// Gate A12-U149B
pullup(g34133);
assign #GATE_DELAY g34133 = rst ? 1'bz : ((0|G10) ? 1'b0 : 1'bz);
// Gate A12-U157A
pullup(G16A_);
assign #GATE_DELAY G16A_ = rst ? 1'bz : ((0|G16) ? 1'b0 : 1'bz);
// Gate A12-U119B
pullup(g34248);
assign #GATE_DELAY g34248 = rst ? 0 : ((0|PC15|g34246) ? 1'b0 : 1'bz);
// Gate A12-U160A
pullup(PA15_);
assign #GATE_DELAY PA15_ = rst ? 1'bz : ((0|PA15) ? 1'b0 : 1'bz);
// Gate A12-U246A
pullup(RL05_);
assign #GATE_DELAY RL05_ = rst ? 1'bz : ((0|CAD5|RPTAD5) ? 1'b0 : 1'bz);
// Gate A12-U146A
pullup(WG_);
assign #GATE_DELAY WG_ = rst ? 1'bz : ((0|BRXP3) ? 1'b0 : 1'bz);
// Gate A12-U250A A12-U250B
pullup(S05_);
assign #GATE_DELAY S05_ = rst ? 1'bz : ((0|g34431) ? 1'b0 : 1'bz);
// Gate A12-U122A
pullup(MSCDBL_);
assign #GATE_DELAY MSCDBL_ = rst ? 1'bz : ((0|SCADBL) ? 1'b0 : 1'bz);
// Gate A12-U233B A12-U234B
pullup(S01_);
assign #GATE_DELAY S01_ = rst ? 1'bz : ((0|g34403) ? 1'b0 : 1'bz);
// Gate A12-U134A
pullup(_A12_1_G03_);
assign #GATE_DELAY _A12_1_G03_ = rst ? 1'bz : ((0|G03) ? 1'b0 : 1'bz);
// Gate A12-U229A
pullup(g34310);
assign #GATE_DELAY g34310 = rst ? 0 : ((0|WSG_|WL09_) ? 1'b0 : 1'bz);
// Gate A12-U260A
pullup(g34461);
assign #GATE_DELAY g34461 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A12-U136B
pullup(g34111);
assign #GATE_DELAY g34111 = rst ? 1'bz : ((0|G04) ? 1'b0 : 1'bz);
// Gate A12-U204A
pullup(g34346);
assign #GATE_DELAY g34346 = rst ? 0 : ((0|T02_|g34343|XB2_) ? 1'b0 : 1'bz);
// Gate A12-U127B
pullup(PB09_);
assign #GATE_DELAY PB09_ = rst ? 1'bz : ((0|PB09) ? 1'b0 : 1'bz);
// Gate A12-U134B
pullup(g34107);
assign #GATE_DELAY g34107 = rst ? 0 : ((0|_A12_1_G02_|G03|G01A_) ? 1'b0 : 1'bz);
// Gate A12-U223A A12-U223B
pullup(S09_);
assign #GATE_DELAY S09_ = rst ? 1'bz : ((0|g34312) ? 1'b0 : 1'bz);
// Gate A12-U206B A12-U205B
pullup(g34357);
assign #GATE_DELAY g34357 = rst ? 1'bz : ((0|g34351|g34349|g34353|g34355) ? 1'b0 : 1'bz);
// Gate A12-U140A
pullup(PA06_);
assign #GATE_DELAY PA06_ = rst ? 1'bz : ((0|PA06) ? 1'b0 : 1'bz);
// Gate A12-U138A
pullup(g34116);
assign #GATE_DELAY g34116 = rst ? 0 : ((0|G05|g34111|g34113) ? 1'b0 : 1'bz);
// Gate A12-U202B
pullup(g34347);
assign #GATE_DELAY g34347 = rst ? 0 : ((0|T02_|g34343|XB3_) ? 1'b0 : 1'bz);
// Gate A12-U228B
pullup(g34304);
assign #GATE_DELAY g34304 = rst ? 0 : ((0|CSG|g34303) ? 1'b0 : 1'bz);
// Gate A12-U201A
pullup(EDOP_);
assign #GATE_DELAY EDOP_ = rst ? 1'bz : ((0|g34347|g34355) ? 1'b0 : 1'bz);
// Gate A12-U252A
pullup(g34437);
assign #GATE_DELAY g34437 = rst ? 1'bz : ((0|g34436|g34438) ? 1'b0 : 1'bz);
// Gate A12-U256B
pullup(L02A_);
assign #GATE_DELAY L02A_ = rst ? 1'bz : ((0|g34462) ? 1'b0 : 1'bz);
// Gate A12-U113A
pullup(EAD10_);
assign #GATE_DELAY EAD10_ = rst ? 1'bz : ((0|EAD10) ? 1'b0 : 1'bz);
// Gate A12-U213B
pullup(g34334);
assign #GATE_DELAY g34334 = rst ? 0 : ((0|WSG_|WL12_) ? 1'b0 : 1'bz);
// Gate A12-U120A
pullup(GEMP);
assign #GATE_DELAY GEMP = rst ? 1'bz : ((0|PC15_) ? 1'b0 : 1'bz);
// Gate A12-U211B
pullup(S12);
assign #GATE_DELAY S12 = rst ? 0 : ((0|g34335) ? 1'b0 : 1'bz);
// Gate A12-U147A
pullup(PA09_);
assign #GATE_DELAY PA09_ = rst ? 1'bz : ((0|PA09) ? 1'b0 : 1'bz);
// Gate A12-U215B
pullup(G06ED);
assign #GATE_DELAY G06ED = rst ? 0 : ((0|WEDOPG_|WL13_) ? 1'b0 : 1'bz);
// Gate A12-U255A A12-U255B
pullup(S06_);
assign #GATE_DELAY S06_ = rst ? 1'bz : ((0|g34438) ? 1'b0 : 1'bz);
// Gate A12-U209A
pullup(g34343);
assign #GATE_DELAY g34343 = rst ? 1'bz : ((0|OCTAD2) ? 1'b0 : 1'bz);
// Gate A12-U119A
pullup(g34247);
assign #GATE_DELAY g34247 = rst ? 0 : ((0|PC15_|g34245) ? 1'b0 : 1'bz);
// Gate A12-U158B
pullup(g34154);
assign #GATE_DELAY g34154 = rst ? 0 : ((0|g34147) ? 1'b0 : 1'bz);
// Gate A12-U130B
pullup(g34228);
assign #GATE_DELAY g34228 = rst ? 0 : ((0|PA06_|PA09_|PA03) ? 1'b0 : 1'bz);
// Gate A12-U130A
pullup(g34227);
assign #GATE_DELAY g34227 = rst ? 1'bz : ((0|PA09|PA06|PA03) ? 1'b0 : 1'bz);
// Gate A12-U108B
pullup(EXTPLS);
assign #GATE_DELAY EXTPLS = rst ? 0 : ((0|g34204|g34203|g34202) ? 1'b0 : 1'bz);
// Gate A12-U126A
pullup(g34234);
assign #GATE_DELAY g34234 = rst ? 1'bz : ((0|PA15|PA12) ? 1'b0 : 1'bz);
// Gate A12-U126B
pullup(g34235);
assign #GATE_DELAY g34235 = rst ? 0 : ((0|PA15_|PA12_) ? 1'b0 : 1'bz);
// Gate A12-U129A
pullup(g34229);
assign #GATE_DELAY g34229 = rst ? 0 : ((0|PA09_|PA03_|PA06) ? 1'b0 : 1'bz);
// Gate A12-U129B
pullup(g34230);
assign #GATE_DELAY g34230 = rst ? 0 : ((0|PA09|PA06_|PA03_) ? 1'b0 : 1'bz);
// Gate A12-U114A
pullup(BRXP3);
assign #GATE_DELAY BRXP3 = rst ? 0 : ((0|IC15_|T03_) ? 1'b0 : 1'bz);
// Gate A12-U243A
pullup(g34424);
assign #GATE_DELAY g34424 = rst ? 0 : ((0|CSG|g34423) ? 1'b0 : 1'bz);
// Gate A12-U131A
pullup(g34104);
assign #GATE_DELAY g34104 = rst ? 1'bz : ((0|G01|G03|G02) ? 1'b0 : 1'bz);
// Gate A12-U110B
pullup(g34219);
assign #GATE_DELAY g34219 = rst ? 0 : ((0|EB9|S10_) ? 1'b0 : 1'bz);
// Gate A12-U131B
pullup(G01A_);
assign #GATE_DELAY G01A_ = rst ? 1'bz : ((0|G01) ? 1'b0 : 1'bz);
// Gate A12-U101A
pullup(RADRZ);
assign #GATE_DELAY RADRZ = rst ? 0 : ((0|g34211|g34209) ? 1'b0 : 1'bz);
// Gate A12-U243B
pullup(g34423);
assign #GATE_DELAY g34423 = rst ? 1'bz : ((0|g34422|g34424) ? 1'b0 : 1'bz);
// Gate A12-U128A A12-U127A
pullup(PB09);
assign #GATE_DELAY PB09 = rst ? 0 : ((0|g34230|g34229|g34228|g34227) ? 1'b0 : 1'bz);
// Gate A12-U220B
pullup(g34326);
assign #GATE_DELAY g34326 = rst ? 0 : ((0|WSG_|WL11_) ? 1'b0 : 1'bz);
// Gate A12-U101B
pullup(RADRG);
assign #GATE_DELAY RADRG = rst ? 0 : ((0|g34210|g34211) ? 1'b0 : 1'bz);
// Gate A12-U109B
pullup(g34202);
assign #GATE_DELAY g34202 = rst ? 1'bz : ((0|g34201) ? 1'b0 : 1'bz);
// Gate A12-U108A
pullup(g34204);
assign #GATE_DELAY g34204 = rst ? 1'bz : ((0|GNZRO) ? 1'b0 : 1'bz);
// Gate A12-U109A
pullup(g34203);
assign #GATE_DELAY g34203 = rst ? 1'bz : ((0|g34105) ? 1'b0 : 1'bz);
// Gate A12-U208A
pullup(SR_);
assign #GATE_DELAY SR_ = rst ? 1'bz : ((0|g34351|g34345) ? 1'b0 : 1'bz);
// Gate A12-U104B A12-U102B
pullup(g34217);
assign #GATE_DELAY g34217 = rst ? 0 : ((0|g34204|G02|G01|G03) ? 1'b0 : 1'bz);
// Gate A12-U227B
pullup(S08);
assign #GATE_DELAY S08 = rst ? 0 : ((0|g34303) ? 1'b0 : 1'bz);
// Gate A12-U224B
pullup(S09);
assign #GATE_DELAY S09 = rst ? 0 : ((0|g34311) ? 1'b0 : 1'bz);
// Gate A12-U225A
pullup(g34311);
assign #GATE_DELAY g34311 = rst ? 1'bz : ((0|g34312|g34310) ? 1'b0 : 1'bz);
// Gate A12-U224A
pullup(T05_);
assign #GATE_DELAY T05_ = rst ? 1'bz : ((0|T05) ? 1'b0 : 1'bz);
// Gate A12-U231B A12-U232B
pullup(S01);
assign #GATE_DELAY S01 = rst ? 0 : ((0|g34402) ? 1'b0 : 1'bz);
// Gate A12-U236B A12-U237B
pullup(S02);
assign #GATE_DELAY S02 = rst ? 0 : ((0|g34409) ? 1'b0 : 1'bz);
// Gate A12-U241B A12-U240B
pullup(S03);
assign #GATE_DELAY S03 = rst ? 0 : ((0|g34416) ? 1'b0 : 1'bz);
// Gate A12-U244A A12-U244B
pullup(S04);
assign #GATE_DELAY S04 = rst ? 0 : ((0|g34423) ? 1'b0 : 1'bz);
// Gate A12-U249A A12-U249B
pullup(S05);
assign #GATE_DELAY S05 = rst ? 0 : ((0|g34430) ? 1'b0 : 1'bz);
// Gate A12-U147B
pullup(g34132);
assign #GATE_DELAY g34132 = rst ? 0 : ((0|g34125) ? 1'b0 : 1'bz);
// Gate A12-U207B
pullup(CYR_);
assign #GATE_DELAY CYR_ = rst ? 1'bz : ((0|g34349|g34344) ? 1'b0 : 1'bz);
// Gate A12-U124B
pullup(g34239);
assign #GATE_DELAY g34239 = rst ? 0 : ((0|PB09|PB15_) ? 1'b0 : 1'bz);
// Gate A12-U124A
pullup(g34238);
assign #GATE_DELAY g34238 = rst ? 0 : ((0|PB09_|PB15) ? 1'b0 : 1'bz);
// Gate A12-U247A
pullup(g34436);
assign #GATE_DELAY g34436 = rst ? 0 : ((0|WL06_|WSG_) ? 1'b0 : 1'bz);
// Gate A12-U228A
pullup(g34303);
assign #GATE_DELAY g34303 = rst ? 1'bz : ((0|g34304|g34302) ? 1'b0 : 1'bz);
// Gate A12-U247B
pullup(g34429);
assign #GATE_DELAY g34429 = rst ? 0 : ((0|WL05_|WSG_) ? 1'b0 : 1'bz);
// Gate A12-U221B
pullup(g34318);
assign #GATE_DELAY g34318 = rst ? 0 : ((0|WSG_|WL10_) ? 1'b0 : 1'bz);
// Gate A12-U256A
pullup(g34462);
assign #GATE_DELAY g34462 = rst ? 0 : ((0|L02_) ? 1'b0 : 1'bz);
// Gate A12-U125A
pullup(PB15);
assign #GATE_DELAY PB15 = rst ? 0 : ((0|g34234|g34235) ? 1'b0 : 1'bz);
// Gate A12-U229B
pullup(g34302);
assign #GATE_DELAY g34302 = rst ? 0 : ((0|WSG_|WL08_) ? 1'b0 : 1'bz);
// Gate A12-U112A
pullup(g34220);
assign #GATE_DELAY g34220 = rst ? 0 : ((0|EB10|S09_) ? 1'b0 : 1'bz);
// Gate A12-U201B
pullup(SHIFT);
assign #GATE_DELAY SHIFT = rst ? 0 : ((0|SHIFT_) ? 1'b0 : 1'bz);
// Gate A12-U205A
pullup(g34361);
assign #GATE_DELAY g34361 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A12-U257A
pullup(g34444);
assign #GATE_DELAY g34444 = rst ? 1'bz : ((0|g34443|g34445) ? 1'b0 : 1'bz);
// Gate A12-U120B
pullup(MSP);
assign #GATE_DELAY MSP = rst ? 0 : ((0|g34245) ? 1'b0 : 1'bz);
// Gate A12-U152B A12-U150A
pullup(PA12);
assign #GATE_DELAY PA12 = rst ? 0 : ((0|g34138|g34139|g34137|g34136) ? 1'b0 : 1'bz);
// Gate A12-U148B
pullup(g34121);
assign #GATE_DELAY g34121 = rst ? 0 : ((0|g34114) ? 1'b0 : 1'bz);
// Gate A12-U159A A12-U157B
pullup(PA15);
assign #GATE_DELAY PA15 = rst ? 0 : ((0|g34149|g34150|g34147|g34148) ? 1'b0 : 1'bz);
// Gate A12-U217B
pullup(T10_);
assign #GATE_DELAY T10_ = rst ? 1'bz : ((0|T10) ? 1'b0 : 1'bz);
// Gate A12-U148A
pullup(g34136);
assign #GATE_DELAY g34136 = rst ? 1'bz : ((0|G11|G10|G12) ? 1'b0 : 1'bz);
// Gate A12-U246B
pullup(RL06_);
assign #GATE_DELAY RL06_ = rst ? 1'bz : ((0|CAD6|RPTAD6) ? 1'b0 : 1'bz);
// Gate A12-U215A
pullup(G05ED);
assign #GATE_DELAY G05ED = rst ? 0 : ((0|WL12_|WEDOPG_) ? 1'b0 : 1'bz);
// Gate A12-U259A
pullup(g34464);
assign #GATE_DELAY g34464 = rst ? 1'bz : ((0|L15_) ? 1'b0 : 1'bz);
// Gate A12-U210A
pullup(S12_);
assign #GATE_DELAY S12_ = rst ? 1'bz : ((0|g34336) ? 1'b0 : 1'bz);
// Gate A12-U231A
pullup(g34408);
assign #GATE_DELAY g34408 = rst ? 0 : ((0|WSG_|WL02_) ? 1'b0 : 1'bz);
// Gate A12-U259B
pullup(L15A_);
assign #GATE_DELAY L15A_ = rst ? 0 : ((0|g34464) ? 1'b0 : 1'bz);
// Gate A12-U233A
pullup(g34402);
assign #GATE_DELAY g34402 = rst ? 1'bz : ((0|g34401|g34403) ? 1'b0 : 1'bz);
// Gate A12-U156A
pullup(g34148);
assign #GATE_DELAY g34148 = rst ? 0 : ((0|G13|g34145|G16A_) ? 1'b0 : 1'bz);
// Gate A12-U132A
pullup(g34105);
assign #GATE_DELAY g34105 = rst ? 0 : ((0|G01|_A12_1_G02_|_A12_1_G03_) ? 1'b0 : 1'bz);
// Gate A12-U156B
pullup(g34149);
assign #GATE_DELAY g34149 = rst ? 0 : ((0|g34144|G14|G16A_) ? 1'b0 : 1'bz);
// Gate A12-U110A
pullup(g34201);
assign #GATE_DELAY g34201 = rst ? 0 : ((0|TSUDO_|T7PHS4_) ? 1'b0 : 1'bz);
// Gate A12-U234A
pullup(g34403);
assign #GATE_DELAY g34403 = rst ? 0 : ((0|g34402|CSG) ? 1'b0 : 1'bz);
// Gate A12-U204B
pullup(GINH);
assign #GATE_DELAY GINH = rst ? 0 : ((0|g34357) ? 1'b0 : 1'bz);
// Gate A12-U155B
pullup(g34147);
assign #GATE_DELAY g34147 = rst ? 1'bz : ((0|G16|G13|G14) ? 1'b0 : 1'bz);
// Gate A12-U144A
pullup(g34127);
assign #GATE_DELAY g34127 = rst ? 0 : ((0|G08|g34122|g34124) ? 1'b0 : 1'bz);
// Gate A12-U155A
pullup(g34145);
assign #GATE_DELAY g34145 = rst ? 1'bz : ((0|G14) ? 1'b0 : 1'bz);
// Gate A12-U142A
pullup(g34122);
assign #GATE_DELAY g34122 = rst ? 1'bz : ((0|G07) ? 1'b0 : 1'bz);
// Gate A12-U146B A12-U144B
pullup(PA09);
assign #GATE_DELAY PA09 = rst ? 0 : ((0|g34127|g34128|g34126|g34125) ? 1'b0 : 1'bz);
// Gate A12-U158A
pullup(g34150);
assign #GATE_DELAY g34150 = rst ? 0 : ((0|G16|g34145|g34144) ? 1'b0 : 1'bz);
// Gate A12-U142B
pullup(g34125);
assign #GATE_DELAY g34125 = rst ? 1'bz : ((0|G07|G09|G08) ? 1'b0 : 1'bz);
// Gate A12-U111A
pullup(EAD09_);
assign #GATE_DELAY EAD09_ = rst ? 1'bz : ((0|EAD09) ? 1'b0 : 1'bz);
// Gate A12-U203A
pullup(g34353);
assign #GATE_DELAY g34353 = rst ? 0 : ((0|T12A|CYL_) ? 1'b0 : 1'bz);
// Gate A12-U135B A12-U133A
pullup(PA03);
assign #GATE_DELAY PA03 = rst ? 0 : ((0|g34107|g34106|g34105|g34104) ? 1'b0 : 1'bz);
// Gate A12-U214B
pullup(S11_);
assign #GATE_DELAY S11_ = rst ? 0 : ((0|g34328) ? 1'b0 : 1'bz);
// Gate A12-U230B
pullup(G02ED);
assign #GATE_DELAY G02ED = rst ? 0 : ((0|WL09_|WEDOPG_) ? 1'b0 : 1'bz);
// Gate A12-U219B
pullup(T07_);
assign #GATE_DELAY T07_ = rst ? 1'bz : ((0|T07) ? 1'b0 : 1'bz);
// Gate A12-U225B
pullup(g34312);
assign #GATE_DELAY g34312 = rst ? 0 : ((0|CSG|g34311) ? 1'b0 : 1'bz);
// Gate A12-U153A
pullup(PA12_);
assign #GATE_DELAY PA12_ = rst ? 1'bz : ((0|PA12) ? 1'b0 : 1'bz);
// Gate A12-U212B
pullup(g34335);
assign #GATE_DELAY g34335 = rst ? 1'bz : ((0|g34336|g34334|d8XP5) ? 1'b0 : 1'bz);
// Gate A12-U106B A12-U102A
pullup(INHPLS);
assign #GATE_DELAY INHPLS = rst ? 0 : ((0|G02|_A12_1_G03_|G01|g34204|g34202) ? 1'b0 : 1'bz);
// Gate A12-U151B
pullup(g34138);
assign #GATE_DELAY g34138 = rst ? 0 : ((0|G11|g34133|g34135) ? 1'b0 : 1'bz);
// Gate A12-U140B
pullup(g34117);
assign #GATE_DELAY g34117 = rst ? 0 : ((0|G06|g34112|g34111) ? 1'b0 : 1'bz);
// Gate A12-U117B
pullup(MPAL_);
assign #GATE_DELAY MPAL_ = rst ? 1'bz : ((0|PALE) ? 1'b0 : 1'bz);
// Gate A12-U210B
pullup(SHIFT_);
assign #GATE_DELAY SHIFT_ = rst ? 1'bz : ((0|SHANC|SHINC) ? 1'b0 : 1'bz);
// Gate A12-U151A
pullup(g34139);
assign #GATE_DELAY g34139 = rst ? 0 : ((0|G12|g34133|g34134) ? 1'b0 : 1'bz);
// End of NOR gates


endmodule
