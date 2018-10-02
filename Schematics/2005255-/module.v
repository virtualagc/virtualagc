// Verilog module auto-generated for AGC module A8 by dumbVerilog.py

module A8 ( 
  rst, A2XG_, CAG, CBG, CGA8, CGG, CH01, CH02, CH03, CH04, CI01_, CLG1G,
  CLXC, CQG, CUG, CZG, G01ED, G02ED, G03ED, G04ED, G05ED, G06ED, G07_, G2LSG_,
  L2GDG_, MCRO_, MDT01, MDT02, MDT03, MDT04, MONEX, PONEX, R15, R1C, RAG_,
  RB1, RB2, RBLG_, RCG_, RGG_, RLG_, RQG_, RULOG_, RZG_, S08, S08_, SA01,
  SA02, SA03, SA04, SETAB_, SETCD_, TWOX, WAG_, WALSG_, WBG_, WG1G_, WG3G_,
  WG4G_, WL05_, WL06_, WL16_, WLG_, WQG_, WYDG_, WYDLOG_, WYLOG_, WZG_, XUY05_,
  XUY06_, CI02_, CI03_, CI04_, CO04, CO06, G01_, G02_, G03_, G04_, G05_,
  G06_, GEM01, GEM02, GEM03, GEM04, L01_, L02_, L03_, MWL01, MWL02, MWL03,
  MWL04, RL01_, RL02_, RL03_, RL04_, S08A, S08A_, SUMA04_, WL01_, WL02_,
  WL03_, WL04_, XUY03_, XUY04_, A01_, A02_, A03_, A04_, CI05_, CLEARA, CLEARB,
  CLEARC, CLEARD, G01, G02, G03, G04, L04_, SUMA01_, SUMA02_, SUMA03_, SUMB01_,
  SUMB02_, SUMB03_, SUMB04_, WL01, WL02, WL03, WL04, XUY01_, XUY02_, Z01_,
  Z02_, Z03_, Z04_
);

input wire rst, A2XG_, CAG, CBG, CGA8, CGG, CH01, CH02, CH03, CH04, CI01_,
  CLG1G, CLXC, CQG, CUG, CZG, G01ED, G02ED, G03ED, G04ED, G05ED, G06ED, G07_,
  G2LSG_, L2GDG_, MCRO_, MDT01, MDT02, MDT03, MDT04, MONEX, PONEX, R15, R1C,
  RAG_, RB1, RB2, RBLG_, RCG_, RGG_, RLG_, RQG_, RULOG_, RZG_, S08, S08_,
  SA01, SA02, SA03, SA04, SETAB_, SETCD_, TWOX, WAG_, WALSG_, WBG_, WG1G_,
  WG3G_, WG4G_, WL05_, WL06_, WL16_, WLG_, WQG_, WYDG_, WYDLOG_, WYLOG_,
  WZG_, XUY05_, XUY06_;

inout wire CI02_, CI03_, CI04_, CO04, CO06, G01_, G02_, G03_, G04_, G05_,
  G06_, GEM01, GEM02, GEM03, GEM04, L01_, L02_, L03_, MWL01, MWL02, MWL03,
  MWL04, RL01_, RL02_, RL03_, RL04_, S08A, S08A_, SUMA04_, WL01_, WL02_,
  WL03_, WL04_, XUY03_, XUY04_;

output wire A01_, A02_, A03_, A04_, CI05_, CLEARA, CLEARB, CLEARC, CLEARD,
  G01, G02, G03, G04, L04_, SUMA01_, SUMA02_, SUMA03_, SUMB01_, SUMB02_,
  SUMB03_, SUMB04_, WL01, WL02, WL03, WL04, XUY01_, XUY02_, Z01_, Z02_, Z03_,
  Z04_;

assign #0.2  G01_ = rst ? 0 : ~(0|U137Pad9|U136Pad9|G01|G01ED|U140Pad6|U140Pad7|SA01);
assign #0.2  U121Pad1 = rst ? 0 : ~(0|L02_|CLG1G);
assign #0.2  U229Pad2 = rst ? 0 : ~(0|WZG_|WL03_);
assign #0.2  U219Pad9 = rst ? 0 : ~(0|WG3G_|WL02_);
assign #0.2  U121Pad9 = rst ? 0 : ~(0|U120Pad8|CUG);
assign #0.2  U140Pad7 = rst ? 0 : ~(0|WL16_|WG3G_);
assign #0.2  U140Pad6 = rst ? 0 : ~(0|WG4G_|WL02_);
assign #0.2  U226Pad1 = rst ? 0 : ~(0|Z03_|RZG_);
assign #0.2  J4Pad440 = rst ? 0 : ~(0|RLG_|L03_);
assign #0.2  U258Pad1 = rst ? 0 : ~(0|CZG|Z04_);
assign #0.2  U215Pad1 = rst ? 0 : ~(0|U213Pad1|RBLG_);
assign #0.2  U129Pad9 = rst ? 0 : ~(0|A02_|A2XG_);
assign #0.2  U212Pad1 = rst ? 0 : ~(0|WL03_|WBG_);
assign #0.2  XUY02_ = rst ? 0 : ~(0|U121Pad9|U127Pad8);
assign #0.2  L02_ = rst ? 0 : ~(0|U122Pad2|U122Pad3|U121Pad1);
assign #0.2  CI03_ = rst ? 0 : ~(0|U116Pad7|SUMA02_);
assign #0.2  WL01 = rst ? 0 : ~(0|RL01_);
assign #0.2  WL03 = rst ? 0 : ~(0|RL03_);
assign #0.2  WL02 = rst ? 0 : ~(0|RL02_);
assign #0.2  U108Pad2 = rst ? 0 : ~(0|WL02_|WQG_);
assign #0.2  U242Pad1 = rst ? 0 : ~(0|WBG_|WL04_);
assign #0.2  U238Pad9 = rst ? 0 : ~(0|U238Pad6|U237Pad9|U234Pad8);
assign #0.2  SUMA03_ = rst ? 0 : ~(0|U211Pad9|XUY03_|CI03_);
assign #0.2  U238Pad1 = rst ? 0 : ~(0|G2LSG_|G07_);
assign #0.2  U253Pad1 = rst ? 0 : ~(0|U253Pad2|U250Pad1);
assign #0.2  U253Pad2 = rst ? 0 : ~(0|U253Pad1|CQG);
assign #0.2  G02_ = rst ? 0 : ~(0|U106Pad9|U107Pad9|G02|G02ED|U110Pad6|U110Pad7|SA02);
assign #0.2  U238Pad6 = rst ? 0 : ~(0|WL03_|WYDG_);
assign #0.2  SUMB02_ = rst ? 0 : ~(0|U115Pad7|U115Pad8);
assign #0.2  U235Pad1 = rst ? 0 : ~(0|RAG_|A04_);
assign #0.2  MWL03 = rst ? 0 : ~(0|RL03_);
assign #0.2  A03_ = rst ? 0 : ~(0|U201Pad1|U202Pad1|U203Pad4);
assign #0.2  U115Pad8 = rst ? 0 : ~(0|CI02_);
assign #0.2  U109Pad1 = rst ? 0 : ~(0|RGG_|G02_);
assign #0.2  U104Pad3 = rst ? 0 : ~(0|U106Pad2|RQG_);
assign #0.2  U104Pad2 = rst ? 0 : ~(0|RZG_|Z02_);
assign #0.2  U150Pad7 = rst ? 0 : ~(0|U159Pad9|U157Pad8|PONEX);
assign #0.2  U150Pad8 = rst ? 0 : ~(0|U152Pad9|U151Pad9|U153Pad8);
assign #0.2  U115Pad2 = rst ? 0 : ~(0|CBG|U116Pad3);
assign #0.2  U115Pad7 = rst ? 0 : ~(0|U116Pad7|XUY02_);
assign #0.2  Z04_ = rst ? 0 : ~(0|U259Pad2|U258Pad1);
assign #0.2  U102Pad2 = rst ? 0 : ~(0|Z02_|CZG);
assign #0.2  U118Pad2 = rst ? 0 : ~(0|WBG_|WL02_);
assign #0.2  U255Pad1 = rst ? 0 : ~(0|RQG_|U253Pad1);
assign #0.2  U216Pad1 = rst ? 0 : ~(0|RCG_|U213Pad2);
assign #0.2  CI02_ = rst ? 0 : ~(0|SUMA01_|U146Pad8);
assign #0.2  Z03_ = rst ? 0 : ~(0|U229Pad2|U228Pad1);
assign #0.2  U120Pad7 = rst ? 0 : ~(0|U129Pad9|U127Pad8|TWOX);
assign #0.2  L04_ = rst ? 0 : ~(0|U239Pad2|U238Pad1|U237Pad1);
assign #0.2  U107Pad1 = rst ? 0 : ~(0|CQG|U106Pad2);
assign #0.2  U222Pad6 = rst ? 0 : ~(0|L2GDG_|L02_);
assign #0.2  U222Pad8 = rst ? 0 : ~(0|WL03_|WG1G_);
assign #0.2  U120Pad8 = rst ? 0 : ~(0|U122Pad9|U121Pad9|U123Pad8);
assign #0.2  U207Pad1 = rst ? 0 : ~(0|WLG_|WL03_);
assign #0.2  U223Pad2 = rst ? 0 : ~(0|U223Pad1|CQG);
assign #0.2  CO06 = rst ? 0 : ~(0|XUY06_|XUY04_|CI03_|XUY05_|XUY03_);
assign #0.2  U243Pad9 = rst ? 0 : ~(0|XUY04_|U241Pad9);
assign #0.2  CO04 = rst ? 0 : ~(0|XUY02_|XUY04_|CI01_|XUY01_|XUY03_);
assign #0.2  U250Pad1 = rst ? 0 : ~(0|WQG_|WL04_);
assign #0.2  RL03_ = rst ? 0 : ~(0|U225Pad1|U226Pad1|J4Pad440|R15|R1C|MDT03|U215Pad1|U217Pad3|U216Pad1|U205Pad2|CH03|U205Pad4);
assign #0.2  U232Pad1 = rst ? 0 : ~(0|WL06_|WALSG_);
assign #0.2  U131Pad1 = rst ? 0 : ~(0|WL01_|WZG_);
assign #0.2  U237Pad9 = rst ? 0 : ~(0|WL04_|WYLOG_);
assign #0.2  S08A = rst ? 0 : ~(0|S08_);
assign #0.2  U237Pad1 = rst ? 0 : ~(0|WLG_|WL04_);
assign #0.2  U127Pad8 = rst ? 0 : ~(0|CUG|U120Pad7|CLXC);
assign #0.2  CI05_ = rst ? 0 : ~(0|U241Pad9|SUMA04_|CO04);
assign #0.2  U127Pad1 = rst ? 0 : ~(0|CAG|A02_);
assign #0.2  U239Pad2 = rst ? 0 : ~(0|CLG1G|L04_);
assign #0.2  U203Pad4 = rst ? 0 : ~(0|A03_|CAG);
assign #0.2  U231Pad1 = rst ? 0 : ~(0|WL04_|WAG_);
assign #0.2  U250Pad9 = rst ? 0 : ~(0|WL05_|WG4G_);
assign #0.2  Z02_ = rst ? 0 : ~(0|U102Pad2|U101Pad1);
assign #0.2  U231Pad6 = rst ? 0 : ~(0|A2XG_|A04_);
assign #0.2  U231Pad8 = rst ? 0 : ~(0|U231Pad9|CLXC|CUG);
assign #0.2  U231Pad9 = rst ? 0 : ~(0|U231Pad6|MONEX|U231Pad8);
assign #0.2  WL01_ = rst ? 0 : ~(0|WL01);
assign #0.2  U153Pad8 = rst ? 0 : ~(0|WYLOG_|WL01_);
assign #0.2  U116Pad3 = rst ? 0 : ~(0|U118Pad2|U115Pad2);
assign #0.2  U116Pad7 = rst ? 0 : ~(0|U120Pad7|U120Pad8);
assign #0.2  U157Pad1 = rst ? 0 : ~(0|CAG|A01_);
assign #0.2  SUMB04_ = rst ? 0 : ~(0|U244Pad9|U243Pad9);
assign #0.2  A02_ = rst ? 0 : ~(0|U128Pad2|U128Pad3|U127Pad1);
assign #0.2  U241Pad9 = rst ? 0 : ~(0|U238Pad9|U231Pad9);
assign #0.2  U157Pad8 = rst ? 0 : ~(0|CUG|U150Pad7|CLXC);
assign #0.2  U114Pad9 = rst ? 0 : ~(0|RULOG_|SUMA02_|SUMB02_);
assign #0.2  U146Pad3 = rst ? 0 : ~(0|U148Pad2|U145Pad2);
assign #0.2  U202Pad1 = rst ? 0 : ~(0|WL05_|WALSG_);
assign #0.2  U138Pad2 = rst ? 0 : ~(0|WL01_|WQG_);
assign #0.2  CLEARC = rst ? 0 : ~(0|SETCD_|S08A_);
assign #0.2  L01_ = rst ? 0 : ~(0|U152Pad2|U152Pad3|U151Pad1);
assign #0.2  CLEARA = rst ? 0 : ~(0|S08A_|SETAB_);
assign #0.2  U114Pad3 = rst ? 0 : ~(0|U115Pad2|RCG_);
assign #0.2  U128Pad3 = rst ? 0 : ~(0|WAG_|WL02_);
assign #0.2  U128Pad2 = rst ? 0 : ~(0|WALSG_|WL04_);
assign #0.2  U136Pad2 = rst ? 0 : ~(0|U138Pad2|U137Pad1);
assign #0.2  U209Pad4 = rst ? 0 : ~(0|CLG1G|L03_);
assign #0.2  L03_ = rst ? 0 : ~(0|U207Pad1|U208Pad1|U209Pad4);
assign #0.2  SUMA01_ = rst ? 0 : ~(0|U146Pad8|XUY01_|CI01_);
assign #0.2  U148Pad2 = rst ? 0 : ~(0|WBG_|WL01_);
assign #0.2  U144Pad3 = rst ? 0 : ~(0|RBLG_|U146Pad3);
assign #0.2  U144Pad2 = rst ? 0 : ~(0|U145Pad2|RCG_);
assign #0.2  WL02_ = rst ? 0 : ~(0|WL02);
assign #0.2  U106Pad2 = rst ? 0 : ~(0|U108Pad2|U107Pad1);
assign #0.2  U144Pad9 = rst ? 0 : ~(0|RULOG_|SUMA01_|SUMB01_);
assign #0.2  U106Pad9 = rst ? 0 : ~(0|WG1G_|WL02_);
assign #0.2  U233Pad4 = rst ? 0 : ~(0|A04_|CAG);
assign #0.2  G05_ = rst ? 0 : ~(0|G05ED);
assign #0.2  U123Pad8 = rst ? 0 : ~(0|WYLOG_|WL02_);
assign #0.2  SUMB01_ = rst ? 0 : ~(0|U145Pad7|U145Pad8);
assign #0.2  U204Pad8 = rst ? 0 : ~(0|CUG|U208Pad9);
assign #0.2  U207Pad9 = rst ? 0 : ~(0|WL03_|WYLOG_);
assign #0.2  U208Pad1 = rst ? 0 : ~(0|G2LSG_|G06_);
assign #0.2  U201Pad9 = rst ? 0 : ~(0|U201Pad6|MONEX|U201Pad8);
assign #0.2  U201Pad8 = rst ? 0 : ~(0|U201Pad9|CLXC|CUG);
assign #0.2  SUMA04_ = rst ? 0 : ~(0|U241Pad9|XUY04_|CI04_);
assign #0.2  U125Pad3 = rst ? 0 : ~(0|RAG_|A02_);
assign #0.2  GEM03 = rst ? 0 : ~(0|G03_);
assign #0.2  U201Pad1 = rst ? 0 : ~(0|WL03_|WAG_);
assign #0.2  Z01_ = rst ? 0 : ~(0|U132Pad2|U131Pad1);
assign #0.2  U101Pad1 = rst ? 0 : ~(0|WL02_|WZG_);
assign #0.2  J3Pad340 = rst ? 0 : ~(0|RLG_|L04_);
assign #0.2  U201Pad6 = rst ? 0 : ~(0|A2XG_|A03_);
assign #0.2  U245Pad1 = rst ? 0 : ~(0|U243Pad1|RBLG_);
assign #0.2  U236Pad4 = rst ? 0 : ~(0|RULOG_|SUMB04_|SUMA04_);
assign #0.2  U244Pad9 = rst ? 0 : ~(0|CI04_);
assign #0.2  U208Pad6 = rst ? 0 : ~(0|WL02_|WYDG_);
assign #0.2  RL04_ = rst ? 0 : ~(0|R15|R1C|MDT04|U235Pad1|CH04|U236Pad4|U255Pad1|U256Pad1|J3Pad340|U245Pad1|U246Pad1|U247Pad4);
assign #0.2  U246Pad1 = rst ? 0 : ~(0|RCG_|U243Pad2);
assign #0.2  WL03_ = rst ? 0 : ~(0|WL03);
assign #0.2  RL02_ = rst ? 0 : ~(0|CH02|U125Pad3|U114Pad9|U114Pad2|U114Pad3|U109Pad1|RB2|MDT02|R1C|U104Pad2|U104Pad3|J2Pad240);
assign #0.2  U139Pad1 = rst ? 0 : ~(0|RGG_|G01_);
assign #0.2  U107Pad9 = rst ? 0 : ~(0|L01_|L2GDG_);
assign #0.2  G06_ = rst ? 0 : ~(0|G06ED);
assign #0.2  U208Pad9 = rst ? 0 : ~(0|U208Pad6|U207Pad9|U204Pad8);
assign #0.2  A04_ = rst ? 0 : ~(0|U231Pad1|U232Pad1|U233Pad4);
assign #0.2  WL04 = rst ? 0 : ~(0|RL04_);
assign #0.2  U159Pad9 = rst ? 0 : ~(0|A01_|A2XG_);
assign #0.2  XUY01_ = rst ? 0 : ~(0|U151Pad9|U157Pad8);
assign #0.2  U213Pad9 = rst ? 0 : ~(0|XUY03_|U211Pad9);
assign #0.2  U247Pad4 = rst ? 0 : ~(0|G04_|RGG_);
assign #0.2  U213Pad1 = rst ? 0 : ~(0|U213Pad2|U212Pad1);
assign #0.2  U213Pad2 = rst ? 0 : ~(0|U213Pad1|CBG);
assign #0.2  U211Pad9 = rst ? 0 : ~(0|U208Pad9|U201Pad9);
assign #0.2  U243Pad2 = rst ? 0 : ~(0|U243Pad1|CBG);
assign #0.2  U243Pad1 = rst ? 0 : ~(0|U243Pad2|U242Pad1);
assign #0.2  U146Pad8 = rst ? 0 : ~(0|U150Pad7|U150Pad8);
assign #0.2  U134Pad3 = rst ? 0 : ~(0|RZG_|Z01_);
assign #0.2  U114Pad2 = rst ? 0 : ~(0|RBLG_|U116Pad3);
assign #0.2  U134Pad4 = rst ? 0 : ~(0|U136Pad2|RQG_);
assign #0.2  SUMA02_ = rst ? 0 : ~(0|U116Pad7|CI02_|XUY02_);
assign #0.2  CLEARB = rst ? 0 : ~(0|S08A|SETAB_);
assign #0.2  WL04_ = rst ? 0 : ~(0|WL04);
assign #0.2  U234Pad8 = rst ? 0 : ~(0|CUG|U238Pad9);
assign #0.2  G03_ = rst ? 0 : ~(0|G03ED|U222Pad6|G03|U222Pad8|U220Pad9|SA03|U219Pad9);
assign #0.2  G04 = rst ? 0 : ~(0|CGG|G04_);
assign #0.2  XUY03_ = rst ? 0 : ~(0|U201Pad8|U204Pad8);
assign #0.2  MWL01 = rst ? 0 : ~(0|RL01_);
assign #0.2  U110Pad6 = rst ? 0 : ~(0|WG4G_|WL03_);
assign #0.2  U110Pad7 = rst ? 0 : ~(0|WL01_|WG3G_);
assign #0.2  G01 = rst ? 0 : ~(0|G01_|CGG);
assign #0.2  G02 = rst ? 0 : ~(0|G02_|CGG);
assign #0.2  G03 = rst ? 0 : ~(0|CGG|G03_);
assign #0.2  U151Pad1 = rst ? 0 : ~(0|L01_|CLG1G);
assign #0.2  GEM01 = rst ? 0 : ~(0|G01_);
assign #0.2  S08A_ = rst ? 0 : ~(0|S08);
assign #0.2  MWL02 = rst ? 0 : ~(0|RL02_);
assign #0.2  GEM04 = rst ? 0 : ~(0|G04_);
assign #0.2  U152Pad2 = rst ? 0 : ~(0|G04_|G2LSG_);
assign #0.2  U152Pad3 = rst ? 0 : ~(0|WLG_|WL01_);
assign #0.2  MWL04 = rst ? 0 : ~(0|RL04_);
assign #0.2  U137Pad1 = rst ? 0 : ~(0|CQG|U136Pad2);
assign #0.2  CLEARD = rst ? 0 : ~(0|S08A|SETCD_);
assign #0.2  U155Pad1 = rst ? 0 : ~(0|A01_|RAG_);
assign #0.2  SUMB03_ = rst ? 0 : ~(0|U214Pad9|U213Pad9);
assign #0.2  XUY04_ = rst ? 0 : ~(0|U231Pad8|U234Pad8);
assign #0.2  U137Pad9 = rst ? 0 : ~(0|MCRO_|L2GDG_);
assign #0.2  U249Pad9 = rst ? 0 : ~(0|WG3G_|WL03_);
assign #0.2  U223Pad1 = rst ? 0 : ~(0|U223Pad2|U220Pad1);
assign #0.2  U252Pad8 = rst ? 0 : ~(0|WL04_|WG1G_);
assign #0.2  U220Pad9 = rst ? 0 : ~(0|WL04_|WG4G_);
assign #0.2  CI04_ = rst ? 0 : ~(0|SUMA03_|U211Pad9);
assign #0.2  U132Pad2 = rst ? 0 : ~(0|Z01_|CZG);
assign #0.2  G04_ = rst ? 0 : ~(0|U250Pad9|SA04|U249Pad9|G04ED|U252Pad6|G04|U252Pad8);
assign #0.2  U220Pad1 = rst ? 0 : ~(0|WQG_|WL03_);
assign #0.2  GEM02 = rst ? 0 : ~(0|G02_);
assign #0.2  U252Pad6 = rst ? 0 : ~(0|L2GDG_|L03_);
assign #0.2  U259Pad2 = rst ? 0 : ~(0|WZG_|WL04_);
assign #0.2  U152Pad9 = rst ? 0 : ~(0|WYDLOG_|WL16_);
assign #0.2  U136Pad9 = rst ? 0 : ~(0|WG1G_|WL01_);
assign #0.2  RL01_ = rst ? 0 : ~(0|U144Pad9|U155Pad1|CH01|R15|MDT01|RB1|J1Pad140|U134Pad3|U134Pad4|U144Pad2|U144Pad3|U139Pad1);
assign #0.2  U145Pad8 = rst ? 0 : ~(0|CI01_);
assign #0.2  A01_ = rst ? 0 : ~(0|U158Pad2|U158Pad3|U157Pad1);
assign #0.2  U122Pad3 = rst ? 0 : ~(0|WLG_|WL02_);
assign #0.2  U122Pad2 = rst ? 0 : ~(0|G05_|G2LSG_);
assign #0.2  J2Pad240 = rst ? 0 : ~(0|L02_|RLG_);
assign #0.2  U145Pad2 = rst ? 0 : ~(0|CBG|U146Pad3);
assign #0.2  U205Pad4 = rst ? 0 : ~(0|RULOG_|SUMB03_|SUMA03_);
assign #0.2  U158Pad2 = rst ? 0 : ~(0|WL03_|WALSG_);
assign #0.2  U158Pad3 = rst ? 0 : ~(0|WAG_|WL01_);
assign #0.2  U145Pad7 = rst ? 0 : ~(0|U146Pad8|XUY01_);
assign #0.2  U122Pad9 = rst ? 0 : ~(0|WYDG_|WL01_);
assign #0.2  J1Pad140 = rst ? 0 : ~(0|L01_|RLG_);
assign #0.2  U151Pad9 = rst ? 0 : ~(0|U150Pad8|CUG);
assign #0.2  U214Pad9 = rst ? 0 : ~(0|CI03_);
assign #0.2  U228Pad1 = rst ? 0 : ~(0|CZG|Z03_);
assign #0.2  U225Pad1 = rst ? 0 : ~(0|RQG_|U223Pad1);
assign #0.2  U205Pad2 = rst ? 0 : ~(0|RAG_|A03_);
assign #0.2  U217Pad3 = rst ? 0 : ~(0|G03_|RGG_);
assign #0.2  U256Pad1 = rst ? 0 : ~(0|Z04_|RZG_);

endmodule
