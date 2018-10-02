// Verilog module auto-generated for AGC module A22 by dumbVerilog.py

module A22 ( 
  rst, CCH34, CCH35, CCHG_, CGA22, CHWL01_, CHWL02_, CHWL03_, CHWL04_, CHWL05_,
  CHWL06_, CHWL07_, CHWL08_, CHWL09_, CHWL10_, CHWL11_, CHWL12_, CHWL13_,
  CHWL14_, CHWL16_, DKBSNC, DKSTRT, END, F12B, FS13, FS14, GOJAM, HIGH0_,
  HIGH1_, HIGH2_, HIGH3_, PC15_, WCH34_, WCH35_, WCHG_, XB3_, XB4_, XT1_,
  BSYNC_, CCH13, DATA_, DKCTR2, DKCTR3, DKCTR3_, DKDAT_, DLKCLR, F12B_, FS13_,
  LOW0_, LOW1_, LOW2_, LOW3_, LOW4_, LOW5_, LOW6_, LOW7_, ORDRBT, RCH13_,
  RDOUT_, WCH13_, WDORDR, WRD1B1, WRD1BP, WRD2B2, WRD2B3, ADVCTR, CCH14,
  CH1307, DKCTR1, DKCTR1_, DKCTR2_, DKCTR4, DKCTR4_, DKCTR5, DKCTR5_, DKDATA,
  DKDATB, F14H, RCH14_, WCH14_, d16CNT, d1CNT, d32CNT
);

input wire rst, CCH34, CCH35, CCHG_, CGA22, CHWL01_, CHWL02_, CHWL03_, CHWL04_,
  CHWL05_, CHWL06_, CHWL07_, CHWL08_, CHWL09_, CHWL10_, CHWL11_, CHWL12_,
  CHWL13_, CHWL14_, CHWL16_, DKBSNC, DKSTRT, END, F12B, FS13, FS14, GOJAM,
  HIGH0_, HIGH1_, HIGH2_, HIGH3_, PC15_, WCH34_, WCH35_, WCHG_, XB3_, XB4_,
  XT1_;

inout wire BSYNC_, CCH13, DATA_, DKCTR2, DKCTR3, DKCTR3_, DKDAT_, DLKCLR,
  F12B_, FS13_, LOW0_, LOW1_, LOW2_, LOW3_, LOW4_, LOW5_, LOW6_, LOW7_, ORDRBT,
  RCH13_, RDOUT_, WCH13_, WDORDR, WRD1B1, WRD1BP, WRD2B2, WRD2B3;

output wire ADVCTR, CCH14, CH1307, DKCTR1, DKCTR1_, DKCTR2_, DKCTR4, DKCTR4_,
  DKCTR5, DKCTR5_, DKDATA, DKDATB, F14H, RCH14_, WCH14_, d16CNT, d1CNT, d32CNT;

assign #0.2  DKDATA = rst ? 0 : ~(0|DKDAT_|RDOUT_|BSYNC_);
assign #0.2  DKDATB = rst ? 0 : ~(0|BSYNC_|RDOUT_|DKDAT_);
assign #0.2  DKCTR5 = rst ? 0 : ~(0|DKCTR5_|U128Pad2);
assign #0.2  DKCTR2 = rst ? 0 : ~(0|U110Pad2);
assign #0.2  DKCTR3 = rst ? 0 : ~(0|U122Pad2);
assign #0.2  U121Pad2 = rst ? 0 : ~(0|U121Pad1|U109Pad3|U121Pad8);
assign #0.2  U121Pad3 = rst ? 0 : ~(0|U122Pad2|U121Pad1);
assign #0.2  U229Pad3 = rst ? 0 : ~(0|CCH34|U229Pad1);
assign #0.2  U229Pad2 = rst ? 0 : ~(0|WCH34_|PC15_);
assign #0.2  U229Pad1 = rst ? 0 : ~(0|U229Pad2|U229Pad3);
assign #0.2  U219Pad9 = rst ? 0 : ~(0|HIGH0_|LOW4_|U218Pad1);
assign #0.2  U121Pad8 = rst ? 0 : ~(0|U121Pad2|U122Pad8);
assign #0.2  DKCTR4 = rst ? 0 : ~(0|DKCTR4_|U125Pad2);
assign #0.2  U244Pad3 = rst ? 0 : ~(0|U245Pad2|U244Pad1);
assign #0.2  U140Pad2 = rst ? 0 : ~(0|DKCTR1_|DKCTR3_|DKCTR2);
assign #0.2  U242Pad1 = rst ? 0 : ~(0|U242Pad2|CCH35);
assign #0.2  U254Pad7 = rst ? 0 : ~(0|LOW1_|HIGH2_|U257Pad3);
assign #0.2  U254Pad6 = rst ? 0 : ~(0|HIGH2_|LOW0_|U259Pad3);
assign #0.2  DKCTR1_ = rst ? 0 : ~(0|U106Pad8);
assign #0.2  U121Pad1 = rst ? 0 : ~(0|U121Pad2|U121Pad3|U109Pad3);
assign #0.2  U258Pad2 = rst ? 0 : ~(0|CHWL14_|WCH35_);
assign #0.2  LOW6_ = rst ? 0 : ~(0|U139Pad2);
assign #0.2  WDORDR = rst ? 0 : ~(0|U114Pad2|U118Pad1);
assign #0.2  ORDRBT = rst ? 0 : ~(0|U118Pad1|U119Pad2);
assign #0.2  DKCTR1 = rst ? 0 : ~(0|U106Pad2);
assign #0.2  U212Pad1 = rst ? 0 : ~(0|U212Pad2|CCH34);
assign #0.2  U206Pad9 = rst ? 0 : ~(0|HIGH1_|LOW2_|U205Pad1);
assign #0.2  U208Pad1 = rst ? 0 : ~(0|CCH34|U208Pad3);
assign #0.2  WCH13_ = rst ? 0 : ~(0|U159Pad2);
assign #0.2  U260Pad2 = rst ? 0 : ~(0|CHWL16_|WCH35_);
assign #0.2  U236Pad9 = rst ? 0 : ~(0|LOW3_|HIGH3_|U235Pad1);
assign #0.2  U238Pad9 = rst ? 0 : ~(0|LOW2_|HIGH3_|U237Pad1);
assign #0.2  U221Pad3 = rst ? 0 : ~(0|CCH34|U221Pad1);
assign #0.2  LOW1_ = rst ? 0 : ~(0|U144Pad2);
assign #0.2  U221Pad2 = rst ? 0 : ~(0|WCH34_|CHWL12_);
assign #0.2  ADVCTR = rst ? 0 : ~(0|BSYNC_|RDOUT_|WDORDR);
assign #0.2  U221Pad1 = rst ? 0 : ~(0|U221Pad2|U221Pad3);
assign #0.2  U203Pad3 = rst ? 0 : ~(0|CCH34|U203Pad1);
assign #0.2  U244Pad1 = rst ? 0 : ~(0|CCH35|U244Pad3);
assign #0.2  U235Pad1 = rst ? 0 : ~(0|U235Pad2|U235Pad3);
assign #0.2  U235Pad2 = rst ? 0 : ~(0|CHWL04_|WCH35_);
assign #0.2  U235Pad3 = rst ? 0 : ~(0|CCH35|U235Pad1);
assign #0.2  U109Pad2 = rst ? 0 : ~(0|U109Pad1|U105Pad3|U109Pad8);
assign #0.2  U109Pad3 = rst ? 0 : ~(0|U110Pad2|U109Pad1);
assign #0.2  U117Pad9 = rst ? 0 : ~(0|WCH13_|CHWL07_);
assign #0.2  U109Pad1 = rst ? 0 : ~(0|U109Pad2|U109Pad3|U105Pad3);
assign #0.2  U104Pad2 = rst ? 0 : ~(0|ADVCTR|DLKCLR);
assign #0.2  U104Pad1 = rst ? 0 : ~(0|U104Pad2);
assign #0.2  U252Pad2 = rst ? 0 : ~(0|CHWL12_|WCH35_);
assign #0.2  U115Pad1 = rst ? 0 : ~(0|U114Pad3);
assign #0.2  U109Pad8 = rst ? 0 : ~(0|U109Pad2|U110Pad8);
assign #0.2  U224Pad2 = rst ? 0 : ~(0|WCH34_|CHWL13_);
assign #0.2  RDOUT_ = rst ? 0 : ~(0|U102Pad9|DLKCLR);
assign #0.2  U118Pad1 = rst ? 0 : ~(0|DLKCLR|WDORDR);
assign #0.2  U255Pad1 = rst ? 0 : ~(0|CCH35|U255Pad3);
assign #0.2  U102Pad9 = rst ? 0 : ~(0|END|RDOUT_);
assign #0.2  U216Pad3 = rst ? 0 : ~(0|CCH34|U216Pad1);
assign #0.2  U216Pad2 = rst ? 0 : ~(0|WCH34_|CHWL10_);
assign #0.2  BSYNC_ = rst ? 0 : ~(0|DKBSNC);
assign #0.2  U257Pad1 = rst ? 0 : ~(0|CCH35|U257Pad3);
assign #0.2  U257Pad3 = rst ? 0 : ~(0|U258Pad2|U257Pad1);
assign #0.2  U207Pad8 = rst ? 0 : ~(0|HIGH0_|LOW7_|U212Pad2);
assign #0.2  U207Pad7 = rst ? 0 : ~(0|HIGH1_|LOW1_|U208Pad3);
assign #0.2  U207Pad6 = rst ? 0 : ~(0|HIGH1_|LOW0_|U210Pad3);
assign #0.2  U259Pad1 = rst ? 0 : ~(0|CCH35|U259Pad3);
assign #0.2  U223Pad3 = rst ? 0 : ~(0|U224Pad2|U223Pad1);
assign #0.2  DKCTR3_ = rst ? 0 : ~(0|U122Pad8);
assign #0.2  DATA_ = rst ? 0 : ~(0|U132Pad6|U132Pad7|WRD2B2|WRD1BP|WRD2B3|WRD1B1|U220Pad2|U220Pad3|U220Pad4|U219Pad9|U217Pad9|U215Pad9|U241Pad2|U241Pad3|U241Pad4|U240Pad9|U238Pad9|U236Pad9|U253Pad9|U249Pad9|U251Pad9|U254Pad6|U254Pad7|U254Pad8|U206Pad9|U204Pad9|U202Pad9|U207Pad6|U207Pad7|U207Pad8);
assign #0.2  d16CNT = rst ? 0 : ~(0|U128Pad2|DKCTR5);
assign #0.2  U131Pad7 = rst ? 0 : ~(0|DATA_|WDORDR);
assign #0.2  U208Pad3 = rst ? 0 : ~(0|U209Pad2|U208Pad1);
assign #0.2  CCH14 = rst ? 0 : ~(0|U149Pad2);
assign #0.2  U237Pad2 = rst ? 0 : ~(0|CHWL05_|WCH35_);
assign #0.2  U237Pad3 = rst ? 0 : ~(0|CCH35|U237Pad1);
assign #0.2  CCH13 = rst ? 0 : ~(0|U156Pad1);
assign #0.2  U252Pad1 = rst ? 0 : ~(0|U252Pad2|U252Pad3);
assign #0.2  U119Pad1 = rst ? 0 : ~(0|U119Pad2|CCH13);
assign #0.2  U119Pad2 = rst ? 0 : ~(0|U117Pad9|U119Pad1);
assign #0.2  LOW4_ = rst ? 0 : ~(0|U141Pad2);
assign #0.2  U203Pad2 = rst ? 0 : ~(0|WCH34_|CHWL04_);
assign #0.2  U203Pad1 = rst ? 0 : ~(0|U203Pad2|U203Pad3);
assign #0.2  DKDAT_ = rst ? 0 : ~(0|U131Pad7|ORDRBT);
assign #0.2  U250Pad1 = rst ? 0 : ~(0|U250Pad2|U250Pad3);
assign #0.2  U113Pad1 = rst ? 0 : ~(0|BSYNC_);
assign #0.2  U255Pad3 = rst ? 0 : ~(0|U256Pad2|U255Pad1);
assign #0.2  U153Pad3 = rst ? 0 : ~(0|XB4_|CCHG_|XT1_);
assign #0.2  U231Pad1 = rst ? 0 : ~(0|U231Pad2|U231Pad3);
assign #0.2  U231Pad2 = rst ? 0 : ~(0|WCH35_|CHWL02_);
assign #0.2  U231Pad3 = rst ? 0 : ~(0|CCH35|U231Pad1);
assign #0.2  LOW7_ = rst ? 0 : ~(0|U138Pad2);
assign #0.2  WRD2B3 = rst ? 0 : ~(0|LOW4_|HIGH3_|U233Pad1);
assign #0.2  WRD2B2 = rst ? 0 : ~(0|LOW5_|HIGH3_|U231Pad1);
assign #0.2  U250Pad3 = rst ? 0 : ~(0|CCH35|U250Pad1);
assign #0.2  U239Pad1 = rst ? 0 : ~(0|U239Pad2|U239Pad3);
assign #0.2  U239Pad2 = rst ? 0 : ~(0|CHWL06_|WCH35_);
assign #0.2  U239Pad3 = rst ? 0 : ~(0|CCH35|U239Pad1);
assign #0.2  U156Pad2 = rst ? 0 : ~(0|XB3_|XT1_|CCHG_);
assign #0.2  U237Pad1 = rst ? 0 : ~(0|U237Pad2|U237Pad3);
assign #0.2  U156Pad1 = rst ? 0 : ~(0|U156Pad2|GOJAM);
assign #0.2  U216Pad1 = rst ? 0 : ~(0|U216Pad2|U216Pad3);
assign #0.2  U149Pad2 = rst ? 0 : ~(0|GOJAM|U153Pad3);
assign #0.2  U210Pad1 = rst ? 0 : ~(0|CCH34|U210Pad3);
assign #0.2  U241Pad3 = rst ? 0 : ~(0|LOW7_|HIGH2_|U244Pad3);
assign #0.2  U241Pad2 = rst ? 0 : ~(0|HIGH3_|LOW0_|U242Pad2);
assign #0.2  U205Pad2 = rst ? 0 : ~(0|WCH34_|CHWL05_);
assign #0.2  DKCTR2_ = rst ? 0 : ~(0|U110Pad8);
assign #0.2  U201Pad1 = rst ? 0 : ~(0|U201Pad2|U201Pad3);
assign #0.2  U114Pad8 = rst ? 0 : ~(0|U115Pad1);
assign #0.2  U138Pad2 = rst ? 0 : ~(0|DKCTR1_|DKCTR3_|DKCTR2_);
assign #0.2  U241Pad4 = rst ? 0 : ~(0|LOW6_|HIGH2_|U246Pad1);
assign #0.2  U114Pad1 = rst ? 0 : ~(0|U114Pad2|U114Pad3);
assign #0.2  U114Pad2 = rst ? 0 : ~(0|U113Pad1|U114Pad8);
assign #0.2  U114Pad3 = rst ? 0 : ~(0|U113Pad1|U114Pad1);
assign #0.2  U128Pad1 = rst ? 0 : ~(0|U128Pad2|d32CNT|U125Pad3);
assign #0.2  U128Pad2 = rst ? 0 : ~(0|U128Pad1|U125Pad3|d16CNT);
assign #0.2  U136Pad2 = rst ? 0 : ~(0|CHWL14_|WCH34_);
assign #0.2  U209Pad2 = rst ? 0 : ~(0|WCH34_|CHWL06_);
assign #0.2  U136Pad8 = rst ? 0 : ~(0|CHWL16_|WCH34_);
assign #0.2  U148Pad2 = rst ? 0 : ~(0|XB4_|XT1_);
assign #0.2  d32CNT = rst ? 0 : ~(0|DKCTR5_|U128Pad1);
assign #0.2  U144Pad2 = rst ? 0 : ~(0|DKCTR1_|DKCTR3|DKCTR2);
assign #0.2  U215Pad9 = rst ? 0 : ~(0|HIGH0_|LOW6_|U214Pad1);
assign #0.2  U106Pad2 = rst ? 0 : ~(0|U105Pad1|DLKCLR|U106Pad8);
assign #0.2  U233Pad2 = rst ? 0 : ~(0|CHWL03_|WCH35_);
assign #0.2  U233Pad3 = rst ? 0 : ~(0|CCH35|U233Pad1);
assign #0.2  LOW2_ = rst ? 0 : ~(0|U143Pad2);
assign #0.2  U233Pad1 = rst ? 0 : ~(0|U233Pad2|U233Pad3);
assign #0.2  U141Pad2 = rst ? 0 : ~(0|DKCTR3_|DKCTR2|DKCTR1);
assign #0.2  U106Pad8 = rst ? 0 : ~(0|U106Pad2|U105Pad2);
assign #0.2  RCH13_ = rst ? 0 : ~(0|U154Pad2);
assign #0.2  DKCTR5_ = rst ? 0 : ~(0|DLKCLR|U128Pad1|DKCTR5);
assign #0.2  U212Pad2 = rst ? 0 : ~(0|U213Pad2|U212Pad1);
assign #0.2  RCH14_ = rst ? 0 : ~(0|U148Pad2);
assign #0.2  U218Pad3 = rst ? 0 : ~(0|CCH34|U218Pad1);
assign #0.2  U204Pad9 = rst ? 0 : ~(0|HIGH1_|LOW3_|U203Pad1);
assign #0.2  U218Pad1 = rst ? 0 : ~(0|U218Pad2|U218Pad3);
assign #0.2  U125Pad1 = rst ? 0 : ~(0|U125Pad2|U125Pad3|U121Pad3);
assign #0.2  U125Pad2 = rst ? 0 : ~(0|U125Pad1|U121Pad3|U125Pad8);
assign #0.2  U125Pad3 = rst ? 0 : ~(0|DKCTR4_|U125Pad1);
assign #0.2  U259Pad3 = rst ? 0 : ~(0|U260Pad2|U259Pad1);
assign #0.2  U125Pad8 = rst ? 0 : ~(0|U125Pad2|DKCTR4);
assign #0.2  U201Pad3 = rst ? 0 : ~(0|CCH34|U201Pad1);
assign #0.2  U201Pad2 = rst ? 0 : ~(0|WCH34_|CHWL03_);
assign #0.2  U248Pad1 = rst ? 0 : ~(0|U248Pad2|U248Pad3);
assign #0.2  U248Pad2 = rst ? 0 : ~(0|CHWL10_|WCH35_);
assign #0.2  U248Pad3 = rst ? 0 : ~(0|CCH35|U248Pad1);
assign #0.2  WCH14_ = rst ? 0 : ~(0|U151Pad2);
assign #0.2  U245Pad2 = rst ? 0 : ~(0|CHWL08_|WCH35_);
assign #0.2  U218Pad2 = rst ? 0 : ~(0|WCH34_|CHWL11_);
assign #0.2  d1CNT = rst ? 0 : ~(0|U105Pad2|U106Pad8);
assign #0.2  U246Pad2 = rst ? 0 : ~(0|CHWL09_|WCH35_);
assign #0.2  U246Pad3 = rst ? 0 : ~(0|CCH35|U246Pad1);
assign #0.2  U246Pad1 = rst ? 0 : ~(0|U246Pad2|U246Pad3);
assign #0.2  U139Pad2 = rst ? 0 : ~(0|DKCTR1|DKCTR3_|DKCTR2_);
assign #0.2  U101Pad2 = rst ? 0 : ~(0|DKSTRT);
assign #0.2  U135Pad1 = rst ? 0 : ~(0|U134Pad3|CCH34);
assign #0.2  DKCTR4_ = rst ? 0 : ~(0|U125Pad1|DLKCLR|DKCTR4);
assign #0.2  U227Pad3 = rst ? 0 : ~(0|CCH34|U227Pad1);
assign #0.2  U227Pad2 = rst ? 0 : ~(0|CHWL01_|WCH34_);
assign #0.2  U135Pad9 = rst ? 0 : ~(0|U134Pad8|CCH34);
assign #0.2  U211Pad2 = rst ? 0 : ~(0|WCH34_|CHWL07_);
assign #0.2  DLKCLR = rst ? 0 : ~(0|U101Pad2);
assign #0.2  U159Pad2 = rst ? 0 : ~(0|XT1_|XB3_|WCHG_);
assign #0.2  U213Pad2 = rst ? 0 : ~(0|WCH34_|CHWL08_);
assign #0.2  U134Pad8 = rst ? 0 : ~(0|U135Pad9|U136Pad8);
assign #0.2  U243Pad2 = rst ? 0 : ~(0|CHWL07_|WCH35_);
assign #0.2  U154Pad2 = rst ? 0 : ~(0|XT1_|XB3_);
assign #0.2  U134Pad3 = rst ? 0 : ~(0|U136Pad2|U135Pad1);
assign #0.2  U250Pad2 = rst ? 0 : ~(0|CHWL11_|WCH35_);
assign #0.2  LOW5_ = rst ? 0 : ~(0|U140Pad2);
assign #0.2  U202Pad9 = rst ? 0 : ~(0|LOW4_|HIGH1_|U201Pad1);
assign #0.2  U253Pad9 = rst ? 0 : ~(0|LOW3_|HIGH2_|U252Pad1);
assign #0.2  U254Pad8 = rst ? 0 : ~(0|LOW2_|HIGH2_|U255Pad3);
assign #0.2  U242Pad2 = rst ? 0 : ~(0|U243Pad2|U242Pad1);
assign #0.2  LOW0_ = rst ? 0 : ~(0|U145Pad2);
assign #0.2  U110Pad8 = rst ? 0 : ~(0|U110Pad2|U109Pad2);
assign #0.2  F14H = rst ? 0 : ~(0|FS14|FS13_|F12B_);
assign #0.2  U105Pad2 = rst ? 0 : ~(0|U105Pad1|U104Pad1|d1CNT);
assign #0.2  U105Pad3 = rst ? 0 : ~(0|U106Pad2|U105Pad1);
assign #0.2  U110Pad2 = rst ? 0 : ~(0|U109Pad1|DLKCLR|U110Pad8);
assign #0.2  U105Pad1 = rst ? 0 : ~(0|U105Pad2|U105Pad3|U104Pad1);
assign #0.2  F12B_ = rst ? 0 : ~(0|F12B);
assign #0.2  WRD1BP = rst ? 0 : ~(0|LOW7_|HIGH1_|U229Pad1);
assign #0.2  CH1307 = rst ? 0 : ~(0|U119Pad2|RCH13_);
assign #0.2  U240Pad9 = rst ? 0 : ~(0|LOW1_|HIGH3_|U239Pad1);
assign #0.2  U249Pad9 = rst ? 0 : ~(0|LOW5_|HIGH2_|U248Pad1);
assign #0.2  FS13_ = rst ? 0 : ~(0|FS13);
assign #0.2  U143Pad2 = rst ? 0 : ~(0|DKCTR2_|DKCTR1|DKCTR3);
assign #0.2  U251Pad9 = rst ? 0 : ~(0|LOW4_|HIGH2_|U250Pad1);
assign #0.2  U223Pad1 = rst ? 0 : ~(0|CCH34|U223Pad3);
assign #0.2  U132Pad6 = rst ? 0 : ~(0|LOW1_|U134Pad3|HIGH0_);
assign #0.2  U132Pad7 = rst ? 0 : ~(0|LOW0_|HIGH0_|U134Pad8);
assign #0.2  U220Pad2 = rst ? 0 : ~(0|HIGH1_|LOW5_|U225Pad1);
assign #0.2  LOW3_ = rst ? 0 : ~(0|U142Pad2);
assign #0.2  U252Pad3 = rst ? 0 : ~(0|CCH35|U252Pad1);
assign #0.2  WRD1B1 = rst ? 0 : ~(0|HIGH1_|LOW6_|U227Pad1);
assign #0.2  U210Pad3 = rst ? 0 : ~(0|U211Pad2|U210Pad1);
assign #0.2  U220Pad4 = rst ? 0 : ~(0|HIGH0_|LOW3_|U221Pad1);
assign #0.2  U151Pad2 = rst ? 0 : ~(0|XB4_|XT1_|WCHG_);
assign #0.2  U214Pad2 = rst ? 0 : ~(0|CHWL09_|WCH34_);
assign #0.2  U220Pad3 = rst ? 0 : ~(0|HIGH0_|LOW2_|U223Pad3);
assign #0.2  U122Pad2 = rst ? 0 : ~(0|U121Pad1|DLKCLR|U122Pad8);
assign #0.2  U145Pad2 = rst ? 0 : ~(0|DKCTR3|DKCTR2|DKCTR1);
assign #0.2  J1Pad135 = rst ? 0 : ~(0);
assign #0.2  U205Pad1 = rst ? 0 : ~(0|U205Pad2|U205Pad3);
assign #0.2  U205Pad3 = rst ? 0 : ~(0|CCH34|U205Pad1);
assign #0.2  U122Pad8 = rst ? 0 : ~(0|U122Pad2|U121Pad2);
assign #0.2  U217Pad9 = rst ? 0 : ~(0|HIGH0_|LOW5_|U216Pad1);
assign #0.2  U225Pad3 = rst ? 0 : ~(0|CCH34|U225Pad1);
assign #0.2  U225Pad2 = rst ? 0 : ~(0|WCH34_|CHWL02_);
assign #0.2  U225Pad1 = rst ? 0 : ~(0|U225Pad2|U225Pad3);
assign #0.2  U142Pad2 = rst ? 0 : ~(0|DKCTR1_|DKCTR2_|DKCTR3);
assign #0.2  U214Pad3 = rst ? 0 : ~(0|CCH34|U214Pad1);
assign #0.2  U227Pad1 = rst ? 0 : ~(0|U227Pad2|U227Pad3);
assign #0.2  U214Pad1 = rst ? 0 : ~(0|U214Pad2|U214Pad3);
assign #0.2  U256Pad2 = rst ? 0 : ~(0|CHWL13_|WCH35_);

endmodule
