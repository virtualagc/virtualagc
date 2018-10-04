// Verilog module auto-generated for AGC module A10 by dumbVerilog.py

module A10 ( 
  rst, A2XG_, BK16, CAG, CBG, CGA10, CGG, CH09, CH10, CH11, CH12, CI09_,
  CLG1G, CLXC, CO10, CQG, CUG, CZG, G13_, G14_, G15_, G2LSG_, L08_, L2GDG_,
  MDT09, MDT10, MDT11, MDT12, MONEX, PIPAXm, PIPAXp, PIPAYm_, PIPAYp, PIPAZm_,
  PIPAZp_, PIPSAM_, R1C, RAG_, RBHG_, RBLG_, RCG_, RGG_, RLG_, RQG_, RULOG_,
  RZG_, SA09, SA10, SA11, SA12, WAG_, WALSG_, WBG_, WG1G_, WG3G_, WG4G_,
  WHOMPA, WL08_, WL13_, WL14_, WLG_, WQG_, WYDG_, WYLOG_, WZG_, XUY13_, XUY14_,
  CI10_, CI11_, CI12_, CO04, CO12, CO14, G12_, GEM09, GEM10, GEM11, GEM12,
  L09_, L10_, L11_, MWL09, MWL10, MWL11, MWL12, RL09_, RL10_, RL11_, RL12_,
  RL15_, WL09_, WL10_, WL11_, WL12_, XUY11_, XUY12_, A09_, A10_, A11_, A12_,
  CI13_, G09, G09_, G10, G10_, G11, G11_, G12, L12_, PIPAXm_, PIPAXp_, PIPAYp_,
  PIPGYm, PIPGZm, PIPGZp, SUMA09_, SUMA10_, SUMA11_, SUMA12_, SUMB09_, SUMB10_,
  SUMB11_, SUMB12_, WL09, WL10, WL11, WL12, XUY09_, XUY10_, Z09_, Z10_, Z11_,
  Z12_
);

input wire rst, A2XG_, BK16, CAG, CBG, CGA10, CGG, CH09, CH10, CH11, CH12,
  CI09_, CLG1G, CLXC, CO10, CQG, CUG, CZG, G13_, G14_, G15_, G2LSG_, L08_,
  L2GDG_, MDT09, MDT10, MDT11, MDT12, MONEX, PIPAXm, PIPAXp, PIPAYm_, PIPAYp,
  PIPAZm_, PIPAZp_, PIPSAM_, R1C, RAG_, RBHG_, RBLG_, RCG_, RGG_, RLG_, RQG_,
  RULOG_, RZG_, SA09, SA10, SA11, SA12, WAG_, WALSG_, WBG_, WG1G_, WG3G_,
  WG4G_, WHOMPA, WL08_, WL13_, WL14_, WLG_, WQG_, WYDG_, WYLOG_, WZG_, XUY13_,
  XUY14_;

inout wire CI10_, CI11_, CI12_, CO04, CO12, CO14, G12_, GEM09, GEM10, GEM11,
  GEM12, L09_, L10_, L11_, MWL09, MWL10, MWL11, MWL12, RL09_, RL10_, RL11_,
  RL12_, RL15_, WL09_, WL10_, WL11_, WL12_, XUY11_, XUY12_;

output wire A09_, A10_, A11_, A12_, CI13_, G09, G09_, G10, G10_, G11, G11_,
  G12, L12_, PIPAXm_, PIPAXp_, PIPAYp_, PIPGYm, PIPGZm, PIPGZp, SUMA09_,
  SUMA10_, SUMA11_, SUMA12_, SUMB09_, SUMB10_, SUMB11_, SUMB12_, WL09, WL10,
  WL11, WL12, XUY09_, XUY10_, Z09_, Z10_, Z11_, Z12_;

// Gate A10-U230A
pullup(A10U229Pad2);
assign (highz1,strong0) #0.2  A10U229Pad2 = rst ? 0 : ~(0|WZG_|WL11_);
// Gate A10-U127A
pullup(A10U127Pad1);
assign (highz1,strong0) #0.2  A10U127Pad1 = rst ? 1 : ~(0|CAG|A10_);
// Gate A10-U131A
pullup(A10U131Pad1);
assign (highz1,strong0) #0.2  A10U131Pad1 = rst ? 0 : ~(0|WL09_|WZG_);
// Gate A10-U237A
pullup(A10U237Pad1);
assign (highz1,strong0) #0.2  A10U237Pad1 = rst ? 0 : ~(0|WLG_|WL12_);
// Gate A10-U128B
pullup(A10U127Pad8);
assign (highz1,strong0) #0.2  A10U127Pad8 = rst ? 0 : ~(0|CUG|A10U120Pad7|CLXC);
// Gate A10-U115B
pullup(SUMB10_);
assign (highz1,strong0) #0.2  SUMB10_ = rst ? 0 : ~(0|A10U115Pad7|A10U115Pad8);
// Gate A10-U112A
pullup(PIPGZm);
assign (highz1,strong0) #0.2  PIPGZm = rst ? 0 : ~(0|PIPSAM_|PIPAZm_);
// Gate A10-U117B
pullup(A10U115Pad8);
assign (highz1,strong0) #0.2  A10U115Pad8 = rst ? 1 : ~(0|CI10_);
// Gate A10-U139B A10-U140B
pullup(G09_);
assign (highz1,strong0) #0.2  G09_ = rst ? 1 : ~(0|A10U137Pad9|A10U136Pad9|G09|A10U140Pad6|A10U140Pad7|SA09);
// Gate A10-U211B
pullup(A10U211Pad9);
assign (highz1,strong0) #0.2  A10U211Pad9 = rst ? 0 : ~(0|A10U208Pad9|A10U201Pad9);
// Gate A10-U118B
pullup(A10U115Pad7);
assign (highz1,strong0) #0.2  A10U115Pad7 = rst ? 1 : ~(0|A10U116Pad7|XUY10_);
// Gate A10-U117A
pullup(A10U115Pad2);
assign (highz1,strong0) #0.2  A10U115Pad2 = rst ? 1 : ~(0|CBG|A10U116Pad3);
// Gate A10-U154A
pullup(A10U152Pad3);
assign (highz1,strong0) #0.2  A10U152Pad3 = rst ? 0 : ~(0|WLG_|WL09_);
// Gate A10-U153A
pullup(A10U152Pad2);
assign (highz1,strong0) #0.2  A10U152Pad2 = rst ? 0 : ~(0|G12_|G2LSG_);
// Gate A10-U128A
pullup(A10_);
assign (highz1,strong0) #0.2  A10_ = rst ? 0 : ~(0|A10U128Pad2|A10U128Pad3|A10U127Pad1);
// Gate A10-U152B
pullup(A10U152Pad9);
assign (highz1,strong0) #0.2  A10U152Pad9 = rst ? 0 : ~(0|WYDG_|WL08_);
// Gate A10-U253B
pullup(G12);
assign (highz1,strong0) #0.2  G12 = rst ? 0 : ~(0|CGG|G12_);
// Gate A10-U137A
pullup(A10U137Pad1);
assign (highz1,strong0) #0.2  A10U137Pad1 = rst ? 0 : ~(0|CQG|A10U136Pad2);
// Gate A10-U229B A10-U228B A10-U230B
pullup(WL11_);
assign (highz1,strong0) #0.2  WL11_ = rst ? 1 : ~(0|WL11);
// Gate A10-U225B
pullup(A10U222Pad8);
assign (highz1,strong0) #0.2  A10U222Pad8 = rst ? 0 : ~(0|WL11_|WG1G_);
// Gate A10-U160B
pullup(A10U150Pad7);
assign (highz1,strong0) #0.2  A10U150Pad7 = rst ? 1 : ~(0|A10U159Pad9|A10U157Pad8|MONEX);
// Gate A10-U135B
pullup(WL09);
assign (highz1,strong0) #0.2  WL09 = rst ? 0 : ~(0|RL09_);
// Gate A10-U137B
pullup(A10U137Pad9);
assign (highz1,strong0) #0.2  A10U137Pad9 = rst ? 0 : ~(0|L08_|L2GDG_);
// Gate A10-U229A
pullup(Z11_);
assign (highz1,strong0) #0.2  Z11_ = rst ? 0 : ~(0|A10U229Pad2|A10U228Pad1);
// Gate A10-U234A
pullup(A10U233Pad4);
assign (highz1,strong0) #0.2  A10U233Pad4 = rst ? 1 : ~(0|A12_|CAG);
// Gate A10-U120A
pullup(A10J2Pad240);
assign (highz1,strong0) #0.2  A10J2Pad240 = rst ? 0 : ~(0|L10_|RLG_);
// Gate A10-U202B
pullup(A10U201Pad6);
assign (highz1,strong0) #0.2  A10U201Pad6 = rst ? 0 : ~(0|A2XG_|A11_);
// Gate A10-U250B
pullup(A10U250Pad9);
assign (highz1,strong0) #0.2  A10U250Pad9 = rst ? 0 : ~(0|WL13_|WG4G_);
// Gate A10-U244A
pullup(A10U243Pad2);
assign (highz1,strong0) #0.2  A10U243Pad2 = rst ? 1 : ~(0|A10U243Pad1|CBG);
// Gate A10-U139A
pullup(A10U139Pad1);
assign (highz1,strong0) #0.2  A10U139Pad1 = rst ? 0 : ~(0|RGG_|G09_);
// Gate A10-U149A
pullup(A10U148Pad2);
assign (highz1,strong0) #0.2  A10U148Pad2 = rst ? 0 : ~(0|WBG_|WL09_);
// Gate A10-U242A
pullup(A10U242Pad1);
assign (highz1,strong0) #0.2  A10U242Pad1 = rst ? 0 : ~(0|WBG_|WL12_);
// Gate A10-U250A
pullup(A10U250Pad1);
assign (highz1,strong0) #0.2  A10U250Pad1 = rst ? 0 : ~(0|WQG_|WL12_);
// Gate A10-U136A
pullup(A10U134Pad4);
assign (highz1,strong0) #0.2  A10U134Pad4 = rst ? 0 : ~(0|A10U136Pad2|RQG_);
// Gate A10-U135A
pullup(A10U134Pad3);
assign (highz1,strong0) #0.2  A10U134Pad3 = rst ? 0 : ~(0|RZG_|Z09_);
// Gate A10-U106B
pullup(A10U106Pad9);
assign (highz1,strong0) #0.2  A10U106Pad9 = rst ? 0 : ~(0|WG1G_|WL10_);
// Gate A10-U201B
pullup(A10U201Pad9);
assign (highz1,strong0) #0.2  A10U201Pad9 = rst ? 0 : ~(0|A10U201Pad6|MONEX|A10U201Pad8);
// Gate A10-U210A
pullup(A10U209Pad4);
assign (highz1,strong0) #0.2  A10U209Pad4 = rst ? 1 : ~(0|CLG1G|L11_);
// Gate A10-U108A
pullup(A10U106Pad2);
assign (highz1,strong0) #0.2  A10U106Pad2 = rst ? 0 : ~(0|A10U108Pad2|A10U107Pad1);
// Gate A10-U260A
pullup(A10U259Pad2);
assign (highz1,strong0) #0.2  A10U259Pad2 = rst ? 0 : ~(0|WZG_|WL12_);
// Gate A10-U113A
pullup(A10J1Pad127);
assign (highz1,strong0) #0.2  A10J1Pad127 = rst ? 1 : ~(0);
// Gate A10-U255B
pullup(A10U252Pad8);
assign (highz1,strong0) #0.2  A10U252Pad8 = rst ? 0 : ~(0|WL12_|WG1G_);
// Gate A10-U215A
pullup(A10U215Pad1);
assign (highz1,strong0) #0.2  A10U215Pad1 = rst ? 0 : ~(0|A10U213Pad1|RBHG_);
// Gate A10-U116B
pullup(CI11_);
assign (highz1,strong0) #0.2  CI11_ = rst ? 0 : ~(0|CO10|A10U116Pad7|SUMA10_);
// Gate A10-U254B
pullup(A10U252Pad6);
assign (highz1,strong0) #0.2  A10U252Pad6 = rst ? 0 : ~(0|L2GDG_|L11_);
// Gate A10-U219B
pullup(A10U219Pad9);
assign (highz1,strong0) #0.2  A10U219Pad9 = rst ? 0 : ~(0|WG3G_|WL10_);
// Gate A10-U101B A10-U103B A10-U102B
pullup(WL10_);
assign (highz1,strong0) #0.2  WL10_ = rst ? 1 : ~(0|WL10);
// Gate A10-U115A
pullup(A10U114Pad3);
assign (highz1,strong0) #0.2  A10U114Pad3 = rst ? 0 : ~(0|A10U115Pad2|RCG_);
// Gate A10-U116A
pullup(A10U114Pad2);
assign (highz1,strong0) #0.2  A10U114Pad2 = rst ? 0 : ~(0|RBLG_|A10U116Pad3);
// Gate A10-U120B
pullup(A10U116Pad7);
assign (highz1,strong0) #0.2  A10U116Pad7 = rst ? 0 : ~(0|A10U120Pad7|A10U120Pad8);
// Gate A10-U127B
pullup(XUY10_);
assign (highz1,strong0) #0.2  XUY10_ = rst ? 0 : ~(0|A10U121Pad9|A10U127Pad8);
// Gate A10-U232A
pullup(A10U232Pad1);
assign (highz1,strong0) #0.2  A10U232Pad1 = rst ? 0 : ~(0|WL14_|WALSG_);
// Gate A10-U114B
pullup(A10U114Pad9);
assign (highz1,strong0) #0.2  A10U114Pad9 = rst ? 0 : ~(0|RULOG_|SUMA10_|SUMB10_);
// Gate A10-U222A
pullup(A10U217Pad3);
assign (highz1,strong0) #0.2  A10U217Pad3 = rst ? 0 : ~(0|G11_|RGG_);
// Gate A10-U225A
pullup(A10U225Pad1);
assign (highz1,strong0) #0.2  A10U225Pad1 = rst ? 0 : ~(0|RQG_|A10U223Pad1);
// Gate A10-U249B
pullup(A10U249Pad9);
assign (highz1,strong0) #0.2  A10U249Pad9 = rst ? 0 : ~(0|WG3G_|WL11_);
// Gate A10-U151A
pullup(A10U151Pad1);
assign (highz1,strong0) #0.2  A10U151Pad1 = rst ? 1 : ~(0|CLG1G|L09_);
// Gate A10-U235B
pullup(PIPAXm_);
assign (highz1,strong0) #0.2  PIPAXm_ = rst ? 1 : ~(0|PIPAXm);
// Gate A10-U244B
pullup(A10U244Pad9);
assign (highz1,strong0) #0.2  A10U244Pad9 = rst ? 1 : ~(0|CI12_);
// Gate A10-U242B
pullup(SUMA12_);
assign (highz1,strong0) #0.2  SUMA12_ = rst ? 1 : ~(0|A10U241Pad9|XUY12_|CI12_);
// Gate A10-U119A
pullup(A10U118Pad2);
assign (highz1,strong0) #0.2  A10U118Pad2 = rst ? 0 : ~(0|WBG_|WL10_);
// Gate A10-U151B
pullup(A10U151Pad9);
assign (highz1,strong0) #0.2  A10U151Pad9 = rst ? 1 : ~(0|A10U150Pad8|CUG);
// Gate A10-U143A
pullup(A10J2Pad239);
assign (highz1,strong0) #0.2  A10J2Pad239 = rst ? 1 : ~(0);
// Gate A10-U213B
pullup(A10U213Pad9);
assign (highz1,strong0) #0.2  A10U213Pad9 = rst ? 1 : ~(0|XUY11_|A10U211Pad9);
// Gate A10-U157A
pullup(A10U157Pad1);
assign (highz1,strong0) #0.2  A10U157Pad1 = rst ? 1 : ~(0|CAG|A09_);
// Gate A10-U205B
pullup(CO04);
assign (highz1,strong0) #0.2  CO04 = rst ? 1 : ~(0|WHOMPA);
// Gate A10-U213A
pullup(A10U213Pad1);
assign (highz1,strong0) #0.2  A10U213Pad1 = rst ? 1 : ~(0|A10U213Pad2|A10U212Pad1);
// Gate A10-U256A
pullup(A10U256Pad1);
assign (highz1,strong0) #0.2  A10U256Pad1 = rst ? 0 : ~(0|Z12_|RZG_);
// Gate A10-U158B
pullup(A10U157Pad8);
assign (highz1,strong0) #0.2  A10U157Pad8 = rst ? 0 : ~(0|CUG|A10U150Pad7|CLXC);
// Gate A10-U214A
pullup(A10U213Pad2);
assign (highz1,strong0) #0.2  A10U213Pad2 = rst ? 0 : ~(0|A10U213Pad1|CBG);
// Gate A10-U125A A10-U114A A10-U143B A10-U104A
pullup(RL10_);
assign (highz1,strong0) #0.2  RL10_ = rst ? 1 : ~(0|CH10|A10U125Pad3|A10U114Pad9|A10U114Pad2|A10U114Pad3|A10U109Pad1|MDT10|R1C|A10U104Pad2|A10U104Pad3|A10J2Pad240);
// Gate A10-U136B
pullup(A10U136Pad9);
assign (highz1,strong0) #0.2  A10U136Pad9 = rst ? 0 : ~(0|WG1G_|WL09_);
// Gate A10-U154B
pullup(A10U153Pad8);
assign (highz1,strong0) #0.2  A10U153Pad8 = rst ? 0 : ~(0|WYLOG_|WL09_);
// Gate A10-U138A
pullup(A10U136Pad2);
assign (highz1,strong0) #0.2  A10U136Pad2 = rst ? 1 : ~(0|A10U138Pad2|A10U137Pad1);
// Gate A10-U155A
pullup(A10U155Pad1);
assign (highz1,strong0) #0.2  A10U155Pad1 = rst ? 0 : ~(0|A09_|RAG_);
// Gate A10-U146B
pullup(CI10_);
assign (highz1,strong0) #0.2  CI10_ = rst ? 0 : ~(0|SUMA09_|A10U146Pad8);
// Gate A10-U107A
pullup(A10U107Pad1);
assign (highz1,strong0) #0.2  A10U107Pad1 = rst ? 1 : ~(0|CQG|A10U106Pad2);
// Gate A10-U126A
pullup(PIPGZp);
assign (highz1,strong0) #0.2  PIPGZp = rst ? 0 : ~(0|PIPSAM_|PIPAZp_);
// Gate A10-U232B
pullup(A10U231Pad6);
assign (highz1,strong0) #0.2  A10U231Pad6 = rst ? 0 : ~(0|A2XG_|A12_);
// Gate A10-U107B
pullup(A10U107Pad9);
assign (highz1,strong0) #0.2  A10U107Pad9 = rst ? 0 : ~(0|L09_|L2GDG_);
// Gate A10-U111A
pullup(A10U108Pad2);
assign (highz1,strong0) #0.2  A10U108Pad2 = rst ? 0 : ~(0|WL10_|WQG_);
// Gate A10-U228A
pullup(A10U228Pad1);
assign (highz1,strong0) #0.2  A10U228Pad1 = rst ? 1 : ~(0|CZG|Z11_);
// Gate A10-U216B
pullup(SUMB11_);
assign (highz1,strong0) #0.2  SUMB11_ = rst ? 0 : ~(0|A10U214Pad9|A10U213Pad9);
// Gate A10-U141A
pullup(A10U138Pad2);
assign (highz1,strong0) #0.2  A10U138Pad2 = rst ? 0 : ~(0|WL09_|WQG_);
// Gate A10-U220A
pullup(A10U220Pad1);
assign (highz1,strong0) #0.2  A10U220Pad1 = rst ? 0 : ~(0|WQG_|WL11_);
// Gate A10-U233A
pullup(A12_);
assign (highz1,strong0) #0.2  A12_ = rst ? 0 : ~(0|A10U231Pad1|A10U232Pad1|A10U233Pad4);
// Gate A10-U145A
pullup(A10U144Pad2);
assign (highz1,strong0) #0.2  A10U144Pad2 = rst ? 0 : ~(0|A10U145Pad2|RCG_);
// Gate A10-U149B
pullup(SUMA09_);
assign (highz1,strong0) #0.2  SUMA09_ = rst ? 1 : ~(0|A10U146Pad8|XUY09_|CI09_);
// Gate A10-U123A
pullup(A10U122Pad2);
assign (highz1,strong0) #0.2  A10U122Pad2 = rst ? 0 : ~(0|G13_|G2LSG_);
// Gate A10-U124A
pullup(A10U122Pad3);
assign (highz1,strong0) #0.2  A10U122Pad3 = rst ? 0 : ~(0|WLG_|WL10_);
// Gate A10-U236B A10-U206B
pullup(CO14);
assign (highz1,strong0) #0.2  CO14 = rst ? 1 : ~(0|XUY14_|XUY12_|CI11_|XUY13_|XUY11_);
// Gate A10-U156A
pullup(A10J1Pad104);
assign (highz1,strong0) #0.2  A10J1Pad104 = rst ? 1 : ~(0);
// Gate A10-U144B
pullup(A10U144Pad9);
assign (highz1,strong0) #0.2  A10U144Pad9 = rst ? 0 : ~(0|RULOG_|SUMA09_|SUMB09_);
// Gate A10-U129A
pullup(A10U128Pad2);
assign (highz1,strong0) #0.2  A10U128Pad2 = rst ? 0 : ~(0|WALSG_|WL12_);
// Gate A10-U125B A10-U155B A10-U248A
pullup(CO12);
assign (highz1,strong0) #0.2  CO12 = rst ? 1 : ~(0|XUY10_|XUY12_|CI09_|XUY09_|XUY11_|WHOMPA);
// Gate A10-U146A
pullup(A10U144Pad3);
assign (highz1,strong0) #0.2  A10U144Pad3 = rst ? 0 : ~(0|RBLG_|A10U146Pad3);
// Gate A10-U118A
pullup(A10U116Pad3);
assign (highz1,strong0) #0.2  A10U116Pad3 = rst ? 0 : ~(0|A10U118Pad2|A10U115Pad2);
// Gate A10-U203A
pullup(A11_);
assign (highz1,strong0) #0.2  A11_ = rst ? 0 : ~(0|A10U201Pad1|A10U202Pad1|A10U203Pad4);
// Gate A10-U214B
pullup(A10U214Pad9);
assign (highz1,strong0) #0.2  A10U214Pad9 = rst ? 1 : ~(0|CI11_);
// Gate A10-U234B
pullup(XUY12_);
assign (highz1,strong0) #0.2  XUY12_ = rst ? 0 : ~(0|A10U231Pad8|A10U234Pad8);
// Gate A10-U131B A10-U132B A10-U133B
pullup(WL09_);
assign (highz1,strong0) #0.2  WL09_ = rst ? 1 : ~(0|WL09);
// Gate A10-U148A
pullup(A10U146Pad3);
assign (highz1,strong0) #0.2  A10U146Pad3 = rst ? 0 : ~(0|A10U148Pad2|A10U145Pad2);
// Gate A10-U226A
pullup(A10U226Pad1);
assign (highz1,strong0) #0.2  A10U226Pad1 = rst ? 0 : ~(0|Z11_|RZG_);
// Gate A10-U241B
pullup(A10U241Pad9);
assign (highz1,strong0) #0.2  A10U241Pad9 = rst ? 0 : ~(0|A10U238Pad9|A10U231Pad9);
// Gate A10-U150B
pullup(A10U146Pad8);
assign (highz1,strong0) #0.2  A10U146Pad8 = rst ? 0 : ~(0|A10U150Pad7|A10U150Pad8);
// Gate A10-U215B
pullup(CI12_);
assign (highz1,strong0) #0.2  CI12_ = rst ? 0 : ~(0|SUMA11_|A10U211Pad9);
// Gate A10-U241A
pullup(A10J3Pad340);
assign (highz1,strong0) #0.2  A10J3Pad340 = rst ? 0 : ~(0|RLG_|L12_);
// Gate A10-U102A
pullup(Z10_);
assign (highz1,strong0) #0.2  Z10_ = rst ? 0 : ~(0|A10U102Pad2|A10U101Pad1);
// Gate A10-U145B
pullup(SUMB09_);
assign (highz1,strong0) #0.2  SUMB09_ = rst ? 0 : ~(0|A10U145Pad7|A10U145Pad8);
// Gate A10-U217B
pullup(A10U205Pad4);
assign (highz1,strong0) #0.2  A10U205Pad4 = rst ? 0 : ~(0|RULOG_|SUMB11_|SUMA11_);
// Gate A10-U243B
pullup(A10U243Pad9);
assign (highz1,strong0) #0.2  A10U243Pad9 = rst ? 1 : ~(0|XUY12_|A10U241Pad9);
// Gate A10-U103A
pullup(A10U102Pad2);
assign (highz1,strong0) #0.2  A10U102Pad2 = rst ? 1 : ~(0|Z10_|CZG);
// Gate A10-U133A
pullup(A10U132Pad2);
assign (highz1,strong0) #0.2  A10U132Pad2 = rst ? 1 : ~(0|Z09_|CZG);
// Gate A10-U222B A10-U221B
pullup(G11_);
assign (highz1,strong0) #0.2  G11_ = rst ? 1 : ~(0|A10U222Pad6|G11|A10U222Pad8|A10U220Pad9|SA11|A10U219Pad9);
// Gate A10-U243A
pullup(A10U243Pad1);
assign (highz1,strong0) #0.2  A10U243Pad1 = rst ? 0 : ~(0|A10U243Pad2|A10U242Pad1);
// Gate A10-U147A
pullup(A10U145Pad2);
assign (highz1,strong0) #0.2  A10U145Pad2 = rst ? 1 : ~(0|CBG|A10U146Pad3);
// Gate A10-U132A
pullup(Z09_);
assign (highz1,strong0) #0.2  Z09_ = rst ? 0 : ~(0|A10U132Pad2|A10U131Pad1);
// Gate A10-U148B
pullup(A10U145Pad7);
assign (highz1,strong0) #0.2  A10U145Pad7 = rst ? 1 : ~(0|A10U146Pad8|XUY09_);
// Gate A10-U218B A10-U236A A10-U257A A10-U247A
pullup(RL12_);
assign (highz1,strong0) #0.2  RL12_ = rst ? 1 : ~(0|R1C|MDT12|A10U235Pad1|CH12|A10U236Pad4|A10U255Pad1|A10U256Pad1|A10J3Pad340|A10U245Pad1|A10U246Pad1|A10U247Pad4);
// Gate A10-U147B
pullup(A10U145Pad8);
assign (highz1,strong0) #0.2  A10U145Pad8 = rst ? 1 : ~(0|CI09_);
// Gate A10-U246A
pullup(A10U246Pad1);
assign (highz1,strong0) #0.2  A10U246Pad1 = rst ? 0 : ~(0|RCG_|A10U243Pad2);
// Gate A10-U249A
pullup(PIPAXp_);
assign (highz1,strong0) #0.2  PIPAXp_ = rst ? 1 : ~(0|PIPAXp);
// Gate A10-U218A
pullup(RL15_);
assign (highz1,strong0) #0.2  RL15_ = rst ? 1 : ~(0|BK16);
// Gate A10-U159B
pullup(A10U159Pad9);
assign (highz1,strong0) #0.2  A10U159Pad9 = rst ? 0 : ~(0|A09_|A2XG_);
// Gate A10-U254A
pullup(A10U253Pad2);
assign (highz1,strong0) #0.2  A10U253Pad2 = rst ? 1 : ~(0|A10U253Pad1|CQG);
// Gate A10-U256B
pullup(WL12);
assign (highz1,strong0) #0.2  WL12 = rst ? 0 : ~(0|RL12_);
// Gate A10-U156B A10-U113B A10-U134A A10-U144A
pullup(RL09_);
assign (highz1,strong0) #0.2  RL09_ = rst ? 1 : ~(0|A10U144Pad9|A10U155Pad1|CH09|MDT09|R1C|A10J1Pad140|A10U134Pad3|A10U134Pad4|A10U144Pad2|A10U144Pad3|A10U139Pad1);
// Gate A10-U231A
pullup(A10U231Pad1);
assign (highz1,strong0) #0.2  A10U231Pad1 = rst ? 0 : ~(0|WL12_|WAG_);
// Gate A10-U227A A10-U248B A10-U217A A10-U205A
pullup(RL11_);
assign (highz1,strong0) #0.2  RL11_ = rst ? 1 : ~(0|A10U225Pad1|A10U226Pad1|A10J4Pad440|R1C|MDT11|A10U215Pad1|A10U217Pad3|A10U216Pad1|A10U205Pad2|CH11|A10U205Pad4);
// Gate A10-U122A
pullup(L10_);
assign (highz1,strong0) #0.2  L10_ = rst ? 0 : ~(0|A10U122Pad2|A10U122Pad3|A10U121Pad1);
// Gate A10-U122B
pullup(A10U122Pad9);
assign (highz1,strong0) #0.2  A10U122Pad9 = rst ? 0 : ~(0|WYDG_|WL09_);
// Gate A10-U105A
pullup(A10U104Pad2);
assign (highz1,strong0) #0.2  A10U104Pad2 = rst ? 0 : ~(0|RZG_|Z10_);
// Gate A10-U101A
pullup(A10U101Pad1);
assign (highz1,strong0) #0.2  A10U101Pad1 = rst ? 0 : ~(0|WL10_|WZG_);
// Gate A10-U153B
pullup(A10U150Pad8);
assign (highz1,strong0) #0.2  A10U150Pad8 = rst ? 0 : ~(0|A10U152Pad9|A10U151Pad9|A10U153Pad8);
// Gate A10-U160A
pullup(A10U158Pad3);
assign (highz1,strong0) #0.2  A10U158Pad3 = rst ? 0 : ~(0|WAG_|WL09_);
// Gate A10-U159A
pullup(A10U158Pad2);
assign (highz1,strong0) #0.2  A10U158Pad2 = rst ? 0 : ~(0|WL11_|WALSG_);
// Gate A10-U223A
pullup(A10U223Pad1);
assign (highz1,strong0) #0.2  A10U223Pad1 = rst ? 0 : ~(0|A10U223Pad2|A10U220Pad1);
// Gate A10-U126B
pullup(A10U125Pad3);
assign (highz1,strong0) #0.2  A10U125Pad3 = rst ? 0 : ~(0|RAG_|A10_);
// Gate A10-U224B
pullup(A10U222Pad6);
assign (highz1,strong0) #0.2  A10U222Pad6 = rst ? 0 : ~(0|L2GDG_|L10_);
// Gate A10-U109B A10-U110B
pullup(G10_);
assign (highz1,strong0) #0.2  G10_ = rst ? 1 : ~(0|A10U106Pad9|A10U107Pad9|G10|A10U110Pad6|A10U110Pad7|SA10);
// Gate A10-U211A
pullup(A10J4Pad440);
assign (highz1,strong0) #0.2  A10J4Pad440 = rst ? 0 : ~(0|RLG_|L11_);
// Gate A10-U245A
pullup(A10U245Pad1);
assign (highz1,strong0) #0.2  A10U245Pad1 = rst ? 0 : ~(0|A10U243Pad1|RBHG_);
// Gate A10-U142A
pullup(PIPGYm);
assign (highz1,strong0) #0.2  PIPGYm = rst ? 0 : ~(0|PIPAYm_|PIPSAM_);
// Gate A10-U245B
pullup(CI13_);
assign (highz1,strong0) #0.2  CI13_ = rst ? 0 : ~(0|A10U241Pad9|SUMA12_|CO12);
// Gate A10-U223B
pullup(G11);
assign (highz1,strong0) #0.2  G11 = rst ? 0 : ~(0|CGG|G11_);
// Gate A10-U108B
pullup(G10);
assign (highz1,strong0) #0.2  G10 = rst ? 0 : ~(0|G10_|CGG);
// Gate A10-U239A
pullup(L12_);
assign (highz1,strong0) #0.2  L12_ = rst ? 0 : ~(0|A10U239Pad2|A10U238Pad1|A10U237Pad1);
// Gate A10-U251A
pullup(GEM12);
assign (highz1,strong0) #0.2  GEM12 = rst ? 0 : ~(0|G12_);
// Gate A10-U221A
pullup(GEM11);
assign (highz1,strong0) #0.2  GEM11 = rst ? 0 : ~(0|G11_);
// Gate A10-U110A
pullup(GEM10);
assign (highz1,strong0) #0.2  GEM10 = rst ? 0 : ~(0|G10_);
// Gate A10-U129B
pullup(A10U129Pad9);
assign (highz1,strong0) #0.2  A10U129Pad9 = rst ? 0 : ~(0|A10_|A2XG_);
// Gate A10-U106A
pullup(A10U104Pad3);
assign (highz1,strong0) #0.2  A10U104Pad3 = rst ? 0 : ~(0|A10U106Pad2|RQG_);
// Gate A10-U235A
pullup(A10U235Pad1);
assign (highz1,strong0) #0.2  A10U235Pad1 = rst ? 0 : ~(0|RAG_|A12_);
// Gate A10-U209A
pullup(L11_);
assign (highz1,strong0) #0.2  L11_ = rst ? 0 : ~(0|A10U207Pad1|A10U208Pad1|A10U209Pad4);
// Gate A10-U239B
pullup(A10U238Pad6);
assign (highz1,strong0) #0.2  A10U238Pad6 = rst ? 0 : ~(0|WL11_|WYDG_);
// Gate A10-U130B
pullup(A10U120Pad7);
assign (highz1,strong0) #0.2  A10U120Pad7 = rst ? 1 : ~(0|A10U129Pad9|A10U127Pad8|MONEX);
// Gate A10-U238A
pullup(A10U238Pad1);
assign (highz1,strong0) #0.2  A10U238Pad1 = rst ? 0 : ~(0|G2LSG_|G15_);
// Gate A10-U259A
pullup(Z12_);
assign (highz1,strong0) #0.2  Z12_ = rst ? 0 : ~(0|A10U259Pad2|A10U258Pad1);
// Gate A10-U123B
pullup(A10U120Pad8);
assign (highz1,strong0) #0.2  A10U120Pad8 = rst ? 0 : ~(0|A10U122Pad9|A10U121Pad9|A10U123Pad8);
// Gate A10-U238B
pullup(A10U238Pad9);
assign (highz1,strong0) #0.2  A10U238Pad9 = rst ? 0 : ~(0|A10U238Pad6|A10U237Pad9|A10U234Pad8);
// Gate A10-U208A
pullup(A10U208Pad1);
assign (highz1,strong0) #0.2  A10U208Pad1 = rst ? 0 : ~(0|G2LSG_|G14_);
// Gate A10-U109A
pullup(A10U109Pad1);
assign (highz1,strong0) #0.2  A10U109Pad1 = rst ? 0 : ~(0|RGG_|G10_);
// Gate A10-U253A
pullup(A10U253Pad1);
assign (highz1,strong0) #0.2  A10U253Pad1 = rst ? 0 : ~(0|A10U253Pad2|A10U250Pad1);
// Gate A10-U206A
pullup(A10U205Pad2);
assign (highz1,strong0) #0.2  A10U205Pad2 = rst ? 0 : ~(0|RAG_|A11_);
// Gate A10-U209B
pullup(A10U208Pad6);
assign (highz1,strong0) #0.2  A10U208Pad6 = rst ? 0 : ~(0|WL10_|WYDG_);
// Gate A10-U208B
pullup(A10U208Pad9);
assign (highz1,strong0) #0.2  A10U208Pad9 = rst ? 1 : ~(0|A10U208Pad6|A10U207Pad9|A10U204Pad8);
// Gate A10-U105B
pullup(WL10);
assign (highz1,strong0) #0.2  WL10 = rst ? 0 : ~(0|RL10_);
// Gate A10-U226B
pullup(WL11);
assign (highz1,strong0) #0.2  WL11 = rst ? 0 : ~(0|RL11_);
// Gate A10-U246B
pullup(SUMB12_);
assign (highz1,strong0) #0.2  SUMB12_ = rst ? 0 : ~(0|A10U244Pad9|A10U243Pad9);
// Gate A10-U247B
pullup(A10U236Pad4);
assign (highz1,strong0) #0.2  A10U236Pad4 = rst ? 0 : ~(0|RULOG_|SUMB12_|SUMA12_);
// Gate A10-U134B
pullup(MWL09);
assign (highz1,strong0) #0.2  MWL09 = rst ? 0 : ~(0|RL09_);
// Gate A10-U240B
pullup(A10U234Pad8);
assign (highz1,strong0) #0.2  A10U234Pad8 = rst ? 1 : ~(0|CUG|A10U238Pad9);
// Gate A10-U138B
pullup(G09);
assign (highz1,strong0) #0.2  G09 = rst ? 0 : ~(0|G09_|CGG);
// Gate A10-U204A
pullup(A10U203Pad4);
assign (highz1,strong0) #0.2  A10U203Pad4 = rst ? 1 : ~(0|A11_|CAG);
// Gate A10-U157B
pullup(XUY09_);
assign (highz1,strong0) #0.2  XUY09_ = rst ? 0 : ~(0|A10U151Pad9|A10U157Pad8);
// Gate A10-U130A
pullup(A10U128Pad3);
assign (highz1,strong0) #0.2  A10U128Pad3 = rst ? 0 : ~(0|WAG_|WL10_);
// Gate A10-U124B
pullup(A10U123Pad8);
assign (highz1,strong0) #0.2  A10U123Pad8 = rst ? 0 : ~(0|WYLOG_|WL10_);
// Gate A10-U255A
pullup(A10U255Pad1);
assign (highz1,strong0) #0.2  A10U255Pad1 = rst ? 0 : ~(0|RQG_|A10U253Pad1);
// Gate A10-U207A
pullup(A10U207Pad1);
assign (highz1,strong0) #0.2  A10U207Pad1 = rst ? 0 : ~(0|WLG_|WL11_);
// Gate A10-U220B
pullup(A10U220Pad9);
assign (highz1,strong0) #0.2  A10U220Pad9 = rst ? 0 : ~(0|WL12_|WG4G_);
// Gate A10-U140A
pullup(GEM09);
assign (highz1,strong0) #0.2  GEM09 = rst ? 0 : ~(0|G09_);
// Gate A10-U207B
pullup(A10U207Pad9);
assign (highz1,strong0) #0.2  A10U207Pad9 = rst ? 0 : ~(0|WL11_|WYLOG_);
// Gate A10-U201A
pullup(A10U201Pad1);
assign (highz1,strong0) #0.2  A10U201Pad1 = rst ? 0 : ~(0|WL11_|WAG_);
// Gate A10-U237B
pullup(A10U237Pad9);
assign (highz1,strong0) #0.2  A10U237Pad9 = rst ? 0 : ~(0|WL12_|WYLOG_);
// Gate A10-U210B
pullup(A10U204Pad8);
assign (highz1,strong0) #0.2  A10U204Pad8 = rst ? 0 : ~(0|CUG|A10U208Pad9);
// Gate A10-U112B
pullup(A10U110Pad7);
assign (highz1,strong0) #0.2  A10U110Pad7 = rst ? 0 : ~(0|WL09_|WG3G_);
// Gate A10-U111B
pullup(A10U110Pad6);
assign (highz1,strong0) #0.2  A10U110Pad6 = rst ? 0 : ~(0|WG4G_|WL11_);
// Gate A10-U203B
pullup(A10U201Pad8);
assign (highz1,strong0) #0.2  A10U201Pad8 = rst ? 1 : ~(0|A10U201Pad9|CLXC|CUG);
// Gate A10-U204B
pullup(XUY11_);
assign (highz1,strong0) #0.2  XUY11_ = rst ? 0 : ~(0|A10U201Pad8|A10U204Pad8);
// Gate A10-U224A
pullup(A10U223Pad2);
assign (highz1,strong0) #0.2  A10U223Pad2 = rst ? 1 : ~(0|A10U223Pad1|CQG);
// Gate A10-U119B
pullup(SUMA10_);
assign (highz1,strong0) #0.2  SUMA10_ = rst ? 1 : ~(0|A10U116Pad7|CI10_|XUY10_);
// Gate A10-U251B A10-U252B
pullup(G12_);
assign (highz1,strong0) #0.2  G12_ = rst ? 1 : ~(0|A10U250Pad9|SA12|A10U249Pad9|A10U252Pad6|G12|A10U252Pad8);
// Gate A10-U216A
pullup(A10U216Pad1);
assign (highz1,strong0) #0.2  A10U216Pad1 = rst ? 0 : ~(0|RCG_|A10U213Pad2);
// Gate A10-U231B
pullup(A10U231Pad9);
assign (highz1,strong0) #0.2  A10U231Pad9 = rst ? 1 : ~(0|A10U231Pad6|MONEX|A10U231Pad8);
// Gate A10-U202A
pullup(A10U202Pad1);
assign (highz1,strong0) #0.2  A10U202Pad1 = rst ? 0 : ~(0|WL13_|WALSG_);
// Gate A10-U257B
pullup(MWL12);
assign (highz1,strong0) #0.2  MWL12 = rst ? 0 : ~(0|RL12_);
// Gate A10-U104B
pullup(MWL10);
assign (highz1,strong0) #0.2  MWL10 = rst ? 0 : ~(0|RL10_);
// Gate A10-U227B
pullup(MWL11);
assign (highz1,strong0) #0.2  MWL11 = rst ? 0 : ~(0|RL11_);
// Gate A10-U141B
pullup(A10U140Pad6);
assign (highz1,strong0) #0.2  A10U140Pad6 = rst ? 0 : ~(0|WG4G_|WL10_);
// Gate A10-U142B
pullup(A10U140Pad7);
assign (highz1,strong0) #0.2  A10U140Pad7 = rst ? 0 : ~(0|WL08_|WG3G_);
// Gate A10-U150A
pullup(A10J1Pad140);
assign (highz1,strong0) #0.2  A10J1Pad140 = rst ? 0 : ~(0|L09_|RLG_);
// Gate A10-U121B
pullup(A10U121Pad9);
assign (highz1,strong0) #0.2  A10U121Pad9 = rst ? 1 : ~(0|A10U120Pad8|CUG);
// Gate A10-U233B
pullup(A10U231Pad8);
assign (highz1,strong0) #0.2  A10U231Pad8 = rst ? 0 : ~(0|A10U231Pad9|CLXC|CUG);
// Gate A10-U258A
pullup(A10U258Pad1);
assign (highz1,strong0) #0.2  A10U258Pad1 = rst ? 1 : ~(0|CZG|Z12_);
// Gate A10-U219A
pullup(PIPAYp_);
assign (highz1,strong0) #0.2  PIPAYp_ = rst ? 1 : ~(0|PIPAYp);
// Gate A10-U121A
pullup(A10U121Pad1);
assign (highz1,strong0) #0.2  A10U121Pad1 = rst ? 1 : ~(0|L10_|CLG1G);
// Gate A10-U240A
pullup(A10U239Pad2);
assign (highz1,strong0) #0.2  A10U239Pad2 = rst ? 1 : ~(0|CLG1G|L12_);
// Gate A10-U252A
pullup(A10U247Pad4);
assign (highz1,strong0) #0.2  A10U247Pad4 = rst ? 0 : ~(0|G12_|RGG_);
// Gate A10-U212A
pullup(A10U212Pad1);
assign (highz1,strong0) #0.2  A10U212Pad1 = rst ? 0 : ~(0|WL11_|WBG_);
// Gate A10-U152A
pullup(L09_);
assign (highz1,strong0) #0.2  L09_ = rst ? 0 : ~(0|A10U152Pad2|A10U152Pad3|A10U151Pad1);
// Gate A10-U158A
pullup(A09_);
assign (highz1,strong0) #0.2  A09_ = rst ? 0 : ~(0|A10U158Pad2|A10U158Pad3|A10U157Pad1);
// Gate A10-U212B
pullup(SUMA11_);
assign (highz1,strong0) #0.2  SUMA11_ = rst ? 1 : ~(0|A10U211Pad9|XUY11_|CI11_);
// Gate A10-U260B A10-U258B A10-U259B
pullup(WL12_);
assign (highz1,strong0) #0.2  WL12_ = rst ? 1 : ~(0|WL12);

endmodule
