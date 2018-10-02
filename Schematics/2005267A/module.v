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

assign #0.2  U244Pad1 = rst ? 0 : ~(0|U243Pad2|CCH10);
assign #0.2  U230Pad2 = rst ? 0 : ~(0|WCH10_|CHWL01_);
assign #0.2  CCH10 = rst ? 0 : ~(0|U249Pad2);
assign #0.2  U229Pad1 = rst ? 0 : ~(0|U228Pad2|CCH10);
assign #0.2  U121Pad9 = rst ? 0 : ~(0|TRANmY|RCH31_);
assign #0.2  U111Pad9 = rst ? 0 : ~(0|HOLFUN|RCH31_);
assign #0.2  U226Pad1 = rst ? 0 : ~(0|U225Pad2|RCH10_);
assign #0.2  U254Pad9 = rst ? 0 : ~(0|CCHG_|XT1_|XB1_);
assign #0.2  CHOR07_ = rst ? 0 : ~(0|U115Pad9|U146Pad3|U146Pad4|CH1407|CH1307|U209Pad4);
assign #0.2  RLYB09 = rst ? 0 : ~(0|U204Pad2);
assign #0.2  U215Pad6 = rst ? 0 : ~(0|U216Pad2|RCH10_);
assign #0.2  U129Pad9 = rst ? 0 : ~(0|RCH31_|MANRpP);
assign #0.2  RLYB08 = rst ? 0 : ~(0|U207Pad2);
assign #0.2  U129Pad1 = rst ? 0 : ~(0|CHWL12_|WCH13_);
assign #0.2  U208Pad1 = rst ? 0 : ~(0|U207Pad2|RCH10_);
assign #0.2  CHOR09_ = rst ? 0 : ~(0|U119Pad9|U149Pad3|U149Pad4|CH1309|CH1409|U203Pad4);
assign #0.2  U133Pad2 = rst ? 0 : ~(0|XB1_|XT3_);
assign #0.2  U238Pad1 = rst ? 0 : ~(0|U237Pad2|CCH10);
assign #0.2  U255Pad9 = rst ? 0 : ~(0|GOJAM|U254Pad9);
assign #0.2  HNDRPT = rst ? 0 : ~(0|U110Pad7|TPOR_);
assign #0.2  U233Pad7 = rst ? 0 : ~(0|U235Pad7|U235Pad1);
assign #0.2  U235Pad7 = rst ? 0 : ~(0|WCH10_|CHWL12_);
assign #0.2  U235Pad1 = rst ? 0 : ~(0|U233Pad7|CCH10);
assign #0.2  U257Pad9 = rst ? 0 : ~(0|XT1_|XB1_);
assign #0.2  CHOR06_ = rst ? 0 : ~(0|U122Pad9|U152Pad3|U152Pad4|CH1406|CH1306|U214Pad1);
assign #0.2  U115Pad9 = rst ? 0 : ~(0|TRANpX|RCH31_);
assign #0.2  U117Pad9 = rst ? 0 : ~(0|TRANmX|RCH31_);
assign #0.2  U109Pad1 = rst ? 0 : ~(0|GCAPCL|RCH31_);
assign #0.2  U221Pad6 = rst ? 0 : ~(0|U222Pad2|RCH10_);
assign #0.2  U115Pad1 = rst ? 0 : ~(0|U115Pad2|U115Pad3);
assign #0.2  CH3208 = rst ? 0 : ~(0|TRST10|RCH32_);
assign #0.2  U115Pad3 = rst ? 0 : ~(0|GOJAM|TRP31B|U115Pad1);
assign #0.2  U115Pad2 = rst ? 0 : ~(0|WCH13_|CHWL13_);
assign #0.2  XB0 = rst ? 0 : ~(0|S01|S02);
assign #0.2  RLYB04 = rst ? 0 : ~(0|U219Pad2);
assign #0.2  U118Pad1 = rst ? 0 : ~(0|U118Pad2|U118Pad3);
assign #0.2  U118Pad2 = rst ? 0 : ~(0|GOJAM|TRP32|U118Pad1);
assign #0.2  U118Pad3 = rst ? 0 : ~(0|WCH13_|CHWL14_);
assign #0.2  RYWD13 = rst ? 0 : ~(0|U237Pad2);
assign #0.2  RYWD12 = rst ? 0 : ~(0|U233Pad7);
assign #0.2  RLYB06 = rst ? 0 : ~(0|U213Pad2);
assign #0.2  RYWD16 = rst ? 0 : ~(0|U243Pad2);
assign #0.2  WCH10_ = rst ? 0 : ~(0|U245Pad9);
assign #0.2  CHOR14_ = rst ? 0 : ~(0|U135Pad2|U135Pad3|U109Pad9|CH1414|CH1214|U240Pad8);
assign #0.2  CHOR11_ = rst ? 0 : ~(0|U114Pad9|U144Pad3|U143Pad1|CH1411|U233Pad1|CH1311);
assign #0.2  U153Pad3 = rst ? 0 : ~(0|RCH30_|LFTOFF);
assign #0.2  U222Pad2 = rst ? 0 : ~(0|U223Pad1|U223Pad8);
assign #0.2  U109Pad9 = rst ? 0 : ~(0|FREFUN|RCH31_);
assign #0.2  J4Pad468 = rst ? 0 : ~(0);
assign #0.2  U207Pad8 = rst ? 0 : ~(0|WCH10_|CHWL08_);
assign #0.2  J4Pad467 = rst ? 0 : ~(0);
assign #0.2  CHOR03_ = rst ? 0 : ~(0|U126Pad9|U156Pad3|U156Pad4|U221Pad6|CH1403|CH1303);
assign #0.2  U120Pad9 = rst ? 0 : ~(0|MANRmR|MANRmY|MANRpR|MANRpY|MANRmP|MANRpP);
assign #0.2  U207Pad2 = rst ? 0 : ~(0|U207Pad1|U207Pad8);
assign #0.2  U207Pad1 = rst ? 0 : ~(0|U207Pad2|CCH10);
assign #0.2  U213Pad1 = rst ? 0 : ~(0|U213Pad2|CCH10);
assign #0.2  CHOR05_ = rst ? 0 : ~(0|U123Pad9|U153Pad3|U153Pad4|U215Pad6|CH1405|CH1305);
assign #0.2  U126Pad1 = rst ? 0 : ~(0|F05A_|U120Pad9|U126Pad4);
assign #0.2  U112Pad3 = rst ? 0 : ~(0|TRANmY|TRANmZ|TRANpZ|TRANpY|TRANpX|TRANmX);
assign #0.2  U126Pad4 = rst ? 0 : ~(0|U129Pad1|U130Pad1);
assign #0.2  U126Pad9 = rst ? 0 : ~(0|MANRpY|RCH31_);
assign #0.2  RCH11_ = rst ? 0 : ~(0|U257Pad9);
assign #0.2  U112Pad9 = rst ? 0 : ~(0|TRANmZ|RCH31_);
assign #0.2  U232Pad1 = rst ? 0 : ~(0|CCH10|U231Pad2);
assign #0.2  U131Pad2 = rst ? 0 : ~(0|XB0_|XT3_);
assign #0.2  U231Pad9 = rst ? 0 : ~(0|WCH10_|CHWL11_);
assign #0.2  U237Pad9 = rst ? 0 : ~(0|WCH10_|CHWL13_);
assign #0.2  RCH33_ = rst ? 0 : ~(0|U143Pad9);
assign #0.2  U237Pad2 = rst ? 0 : ~(0|U237Pad9|U238Pad1);
assign #0.2  CCH11 = rst ? 0 : ~(0|U255Pad9);
assign #0.2  CH3204 = rst ? 0 : ~(0|MNIMmY|RCH32_);
assign #0.2  CH3205 = rst ? 0 : ~(0|MNIMpR|RCH32_);
assign #0.2  CH3206 = rst ? 0 : ~(0|MNIMmR|RCH32_);
assign #0.2  CH3207 = rst ? 0 : ~(0|TRST9|RCH32_);
assign #0.2  CH3201 = rst ? 0 : ~(0|MNIMpP|RCH32_);
assign #0.2  CH3202 = rst ? 0 : ~(0|MNIMmP|RCH32_);
assign #0.2  CH3203 = rst ? 0 : ~(0|MNIMpY|RCH32_);
assign #0.2  U127Pad2 = rst ? 0 : ~(0|F05D|U120Pad9|U125Pad3);
assign #0.2  U119Pad9 = rst ? 0 : ~(0|TRANpY|RCH31_);
assign #0.2  CH3209 = rst ? 0 : ~(0|PCHGOF|RCH32_);
assign #0.2  U203Pad4 = rst ? 0 : ~(0|U204Pad2|RCH10_);
assign #0.2  TRP32 = rst ? 0 : ~(0|F05B_|U122Pad3);
assign #0.2  U231Pad2 = rst ? 0 : ~(0|U231Pad9|U232Pad1);
assign #0.2  U216Pad2 = rst ? 0 : ~(0|U217Pad1|U217Pad8);
assign #0.2  U153Pad4 = rst ? 0 : ~(0|RCH33_|OPMSW2);
assign #0.2  U239Pad1 = rst ? 0 : ~(0|U237Pad2|RCH10_);
assign #0.2  U156Pad4 = rst ? 0 : ~(0|RCH33_|RRRLSC);
assign #0.2  U156Pad3 = rst ? 0 : ~(0|RCH30_|SPSRDY);
assign #0.2  U239Pad7 = rst ? 0 : ~(0|U241Pad7|U241Pad1);
assign #0.2  U149Pad4 = rst ? 0 : ~(0|RCH33_|LRRLSC);
assign #0.2  U251Pad2 = rst ? 0 : ~(0|XB0_|XT1_);
assign #0.2  U241Pad1 = rst ? 0 : ~(0|U239Pad7|CCH10);
assign #0.2  U149Pad3 = rst ? 0 : ~(0|RCH30_|IMUOPR);
assign #0.2  WCH11_ = rst ? 0 : ~(0|U252Pad9);
assign #0.2  RCH10_ = rst ? 0 : ~(0|U251Pad2);
assign #0.2  CHOR04_ = rst ? 0 : ~(0|U125Pad9|U155Pad3|U155Pad4|CH1404|CH1304|U220Pad1);
assign #0.2  U130Pad1 = rst ? 0 : ~(0|U126Pad4|GOJAM|TRP31A);
assign #0.2  U114Pad9 = rst ? 0 : ~(0|TRANpZ|RCH31_);
assign #0.2  U146Pad3 = rst ? 0 : ~(0|RCH33_|STRPRS);
assign #0.2  U202Pad1 = rst ? 0 : ~(0|RCH10_|U201Pad2);
assign #0.2  U128Pad9 = rst ? 0 : ~(0|MANRmP|RCH31_);
assign #0.2  U146Pad4 = rst ? 0 : ~(0|RCH30_|OPCDFL);
assign #0.2  U112Pad4 = rst ? 0 : ~(0|U114Pad2|U112Pad1);
assign #0.2  RCH32_ = rst ? 0 : ~(0|U139Pad8);
assign #0.2  U114Pad2 = rst ? 0 : ~(0|U115Pad1|F05A_|U112Pad3);
assign #0.2  U241Pad7 = rst ? 0 : ~(0|WCH10_|CHWL14_);
assign #0.2  U138Pad9 = rst ? 0 : ~(0|RCH30_|IMUFAL);
assign #0.2  CH3210 = rst ? 0 : ~(0|ROLGOF|RCH32_);
assign #0.2  CHOR16_ = rst ? 0 : ~(0|U109Pad1|U134Pad3|U134Pad4|CH1316|CH1416|U245Pad1);
assign #0.2  RYWD14 = rst ? 0 : ~(0|U239Pad7);
assign #0.2  U148Pad3 = rst ? 0 : ~(0|RCH30_|IN3008);
assign #0.2  U148Pad2 = rst ? 0 : ~(0|RCH33_|LVDAGD);
assign #0.2  U144Pad3 = rst ? 0 : ~(0|RCH30_|IMUCAG);
assign #0.2  U249Pad2 = rst ? 0 : ~(0|U248Pad9|GOJAM);
assign #0.2  CHOR13_ = rst ? 0 : ~(0|U111Pad9|U138Pad9|U137Pad1|CH1113|CH1413|U239Pad1|CH1213);
assign #0.2  U141Pad4 = rst ? 0 : ~(0|RCH30_|CDUFAL);
assign #0.2  U233Pad1 = rst ? 0 : ~(0|RCH10_|U231Pad2);
assign #0.2  U141Pad3 = rst ? 0 : ~(0|RCH32_|IN3212);
assign #0.2  U123Pad9 = rst ? 0 : ~(0|MANRpR|RCH31_);
assign #0.2  U123Pad1 = rst ? 0 : ~(0|F05D|U122Pad3|U105Pad1);
assign #0.2  RCH31_ = rst ? 0 : ~(0|U133Pad2);
assign #0.2  U204Pad2 = rst ? 0 : ~(0|U205Pad7|U205Pad1);
assign #0.2  U201Pad9 = rst ? 0 : ~(0|WCH10_|CHWL10_);
assign #0.2  U125Pad3 = rst ? 0 : ~(0|U127Pad2|U126Pad1);
assign #0.2  U248Pad9 = rst ? 0 : ~(0|XT1_|XB0_|CCHG_);
assign #0.2  U201Pad1 = rst ? 0 : ~(0|U201Pad2|CCH10);
assign #0.2  U125Pad9 = rst ? 0 : ~(0|MANRmY|RCH31_);
assign #0.2  U201Pad2 = rst ? 0 : ~(0|U201Pad1|U201Pad9);
assign #0.2  U245Pad1 = rst ? 0 : ~(0|RCH10_|U243Pad2);
assign #0.2  CHOR10_ = rst ? 0 : ~(0|U121Pad9|U151Pad3|CH3310|U202Pad1|CH1410|CH1310);
assign #0.2  U139Pad8 = rst ? 0 : ~(0|XT3_|XB2_);
assign #0.2  U245Pad9 = rst ? 0 : ~(0|XB0_|WCHG_|XT1_);
assign #0.2  U135Pad3 = rst ? 0 : ~(0|RCH32_|IN3214);
assign #0.2  U135Pad2 = rst ? 0 : ~(0|RCH30_|ISSTOR);
assign #0.2  U227Pad6 = rst ? 0 : ~(0|U228Pad2|RCH10_);
assign #0.2  CHOR02_ = rst ? 0 : ~(0|U128Pad9|U158Pad3|U158Pad4|CH1402|CH1302|U226Pad1);
assign #0.2  U219Pad8 = rst ? 0 : ~(0|WCH10_|CHWL04_);
assign #0.2  U219Pad2 = rst ? 0 : ~(0|U219Pad1|U219Pad8);
assign #0.2  U219Pad1 = rst ? 0 : ~(0|U219Pad2|CCH10);
assign #0.2  U213Pad8 = rst ? 0 : ~(0|WCH10_|CHWL06_);
assign #0.2  U211Pad1 = rst ? 0 : ~(0|U210Pad2|CCH10);
assign #0.2  U159Pad3 = rst ? 0 : ~(0|RCH30_|ULLTHR);
assign #0.2  U159Pad4 = rst ? 0 : ~(0|RCH33_|IN3301);
assign #0.2  U211Pad8 = rst ? 0 : ~(0|WCH10_|CHWL07_);
assign #0.2  RCH30_ = rst ? 0 : ~(0|U131Pad2);
assign #0.2  U252Pad9 = rst ? 0 : ~(0|XT1_|WCHG_|XB1_);
assign #0.2  U243Pad2 = rst ? 0 : ~(0|U243Pad9|U244Pad1);
assign #0.2  U134Pad3 = rst ? 0 : ~(0|RCH30_|TEMPIN);
assign #0.2  RLYB10 = rst ? 0 : ~(0|U201Pad2);
assign #0.2  RLYB11 = rst ? 0 : ~(0|U231Pad2);
assign #0.2  U134Pad4 = rst ? 0 : ~(0|RCH32_|IN3216);
assign #0.2  U205Pad1 = rst ? 0 : ~(0|U204Pad2|CCH10);
assign #0.2  U112Pad1 = rst ? 0 : ~(0|F05D|U112Pad3|U112Pad4);
assign #0.2  CHOR01_ = rst ? 0 : ~(0|U129Pad9|U159Pad3|U159Pad4|U227Pad6|CH1301|CH1401);
assign #0.2  TRP31A = rst ? 0 : ~(0|F05B_|U125Pad3);
assign #0.2  TRP31B = rst ? 0 : ~(0|F05B_|U112Pad4);
assign #0.2  U243Pad9 = rst ? 0 : ~(0|WCH10_|CHWL16_);
assign #0.2  U110Pad7 = rst ? 0 : ~(0|TRP31A|TRP32|TRP31B);
assign #0.2  U240Pad8 = rst ? 0 : ~(0|U239Pad7|RCH10_);
assign #0.2  U234Pad8 = rst ? 0 : ~(0|U233Pad7|RCH10_);
assign #0.2  U105Pad1 = rst ? 0 : ~(0|MNIMpY|MNIMmY|MNIMmP|TRST10|ROLGOF|PCHGOF|MNIMpP|MNIMmR|TRST9|MNIMpR);
assign #0.2  U217Pad8 = rst ? 0 : ~(0|WCH10_|CHWL05_);
assign #0.2  U151Pad3 = rst ? 0 : ~(0|RCH30_|CTLSAT);
assign #0.2  U152Pad3 = rst ? 0 : ~(0|RCH33_|OPMSW3);
assign #0.2  U152Pad4 = rst ? 0 : ~(0|RCH30_|GUIREL);
assign #0.2  U137Pad1 = rst ? 0 : ~(0|RCH32_|IN3213);
assign #0.2  U155Pad4 = rst ? 0 : ~(0|RCH33_|ZEROP);
assign #0.2  U143Pad1 = rst ? 0 : ~(0|RCH32_|LEMATT);
assign #0.2  U155Pad3 = rst ? 0 : ~(0|RCH30_|S4BSAB);
assign #0.2  RLYB01 = rst ? 0 : ~(0|U228Pad2);
assign #0.2  RLYB03 = rst ? 0 : ~(0|U222Pad2);
assign #0.2  RLYB02 = rst ? 0 : ~(0|U225Pad2);
assign #0.2  RLYB05 = rst ? 0 : ~(0|U216Pad2);
assign #0.2  U143Pad9 = rst ? 0 : ~(0|XT3_|XB3_);
assign #0.2  RLYB07 = rst ? 0 : ~(0|U210Pad2);
assign #0.2  U209Pad4 = rst ? 0 : ~(0|U210Pad2|RCH10_);
assign #0.2  U223Pad1 = rst ? 0 : ~(0|U222Pad2|CCH10);
assign #0.2  U213Pad2 = rst ? 0 : ~(0|U213Pad1|U213Pad8);
assign #0.2  U223Pad8 = rst ? 0 : ~(0|WCH10_|CHWL03_);
assign #0.2  U220Pad1 = rst ? 0 : ~(0|U219Pad2|RCH10_);
assign #0.2  U210Pad2 = rst ? 0 : ~(0|U211Pad1|U211Pad8);
assign #0.2  U217Pad1 = rst ? 0 : ~(0|U216Pad2|CCH10);
assign #0.2  U214Pad1 = rst ? 0 : ~(0|U213Pad2|RCH10_);
assign #0.2  U122Pad3 = rst ? 0 : ~(0|U124Pad2|U123Pad1);
assign #0.2  U205Pad7 = rst ? 0 : ~(0|WCH10_|CHWL09_);
assign #0.2  U158Pad3 = rst ? 0 : ~(0|RCH30_|SMSEPR);
assign #0.2  U158Pad4 = rst ? 0 : ~(0|RCH33_|RRPONA);
assign #0.2  U122Pad9 = rst ? 0 : ~(0|MANRmR|RCH31_);
assign #0.2  U228Pad2 = rst ? 0 : ~(0|U230Pad2|U229Pad1);
assign #0.2  CHOR08_ = rst ? 0 : ~(0|U148Pad2|U148Pad3|U117Pad9|CH1408|U208Pad1|CH1308);
assign #0.2  U124Pad2 = rst ? 0 : ~(0|U118Pad1|U105Pad1|F05A_);
assign #0.2  U225Pad2 = rst ? 0 : ~(0|U225Pad1|U225Pad8);
assign #0.2  U225Pad1 = rst ? 0 : ~(0|U225Pad2|CCH10);
assign #0.2  CH3316 = rst ? 0 : ~(0|RCH33_|OSCALM);
assign #0.2  CHOR12_ = rst ? 0 : ~(0|U112Pad9|U141Pad3|U141Pad4|CH3312|CH1412|U234Pad8);
assign #0.2  CH3314 = rst ? 0 : ~(0|AGCWAR|RCH33_);
assign #0.2  CH3313 = rst ? 0 : ~(0|RCH33_|PIPAFL);
assign #0.2  U225Pad8 = rst ? 0 : ~(0|WCH10_|CHWL02_);

endmodule
