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

// Gate A22-U146B
pullup(DKDATA);
assign (highz1,strong0) #0.2  DKDATA = rst ? 0 : ~(0|DKDAT_|RDOUT_|BSYNC_);
// Gate A22-U147A
pullup(DKDATB);
assign (highz1,strong0) #0.2  DKDATB = rst ? 0 : ~(0|BSYNC_|RDOUT_|DKDAT_);
// Gate A22-U130A
pullup(DKCTR5);
assign (highz1,strong0) #0.2  DKCTR5 = rst ? 0 : ~(0|DKCTR5_|A22U128Pad2);
// Gate A22-U112B
pullup(DKCTR2);
assign (highz1,strong0) #0.2  DKCTR2 = rst ? 1 : ~(0|A22U110Pad2);
// Gate A22-U124B
pullup(DKCTR3);
assign (highz1,strong0) #0.2  DKCTR3 = rst ? 0 : ~(0|A22U122Pad2);
// Gate A22-U139A
pullup(LOW6_);
assign (highz1,strong0) #0.2  LOW6_ = rst ? 1 : ~(0|A22U139Pad2);
// Gate A22-U108B
pullup(DKCTR1);
assign (highz1,strong0) #0.2  DKCTR1 = rst ? 0 : ~(0|A22U106Pad2);
// Gate A22-U127A
pullup(DKCTR4);
assign (highz1,strong0) #0.2  DKCTR4 = rst ? 1 : ~(0|DKCTR4_|A22U125Pad2);
// Gate A22-U237A
pullup(A22U237Pad1);
assign (highz1,strong0) #0.2  A22U237Pad1 = rst ? 1 : ~(0|A22U237Pad2|A22U237Pad3);
// Gate A22-U126B
pullup(A22U125Pad8);
assign (highz1,strong0) #0.2  A22U125Pad8 = rst ? 0 : ~(0|A22U125Pad2|DKCTR4);
// Gate A22-U238A
pullup(A22U237Pad3);
assign (highz1,strong0) #0.2  A22U237Pad3 = rst ? 0 : ~(0|CCH35|A22U237Pad1);
// Gate A22-U136A
pullup(A22U134Pad3);
assign (highz1,strong0) #0.2  A22U134Pad3 = rst ? 1 : ~(0|A22U136Pad2|A22U135Pad1);
// Gate A22-U125B
pullup(A22U125Pad2);
assign (highz1,strong0) #0.2  A22U125Pad2 = rst ? 0 : ~(0|A22U125Pad1|A22U121Pad3|A22U125Pad8);
// Gate A22-U126A
pullup(A22U125Pad3);
assign (highz1,strong0) #0.2  A22U125Pad3 = rst ? 0 : ~(0|DKCTR4_|A22U125Pad1);
// Gate A22-U125A
pullup(A22U125Pad1);
assign (highz1,strong0) #0.2  A22U125Pad1 = rst ? 1 : ~(0|A22U125Pad2|A22U125Pad3|A22U121Pad3);
// Gate A22-U136B
pullup(A22U134Pad8);
assign (highz1,strong0) #0.2  A22U134Pad8 = rst ? 1 : ~(0|A22U135Pad9|A22U136Pad8);
// Gate A22-U219A
pullup(A22U218Pad3);
assign (highz1,strong0) #0.2  A22U218Pad3 = rst ? 0 : ~(0|CCH34|A22U218Pad1);
// Gate A22-U131B
pullup(DKDAT_);
assign (highz1,strong0) #0.2  DKDAT_ = rst ? 1 : ~(0|A22U131Pad7|ORDRBT);
// Gate A22-U210A
pullup(A22U210Pad1);
assign (highz1,strong0) #0.2  A22U210Pad1 = rst ? 0 : ~(0|CCH34|A22U210Pad3);
// Gate A22-U246A
pullup(A22U246Pad1);
assign (highz1,strong0) #0.2  A22U246Pad1 = rst ? 1 : ~(0|A22U246Pad2|A22U246Pad3);
// Gate A22-U118B
pullup(WDORDR);
assign (highz1,strong0) #0.2  WDORDR = rst ? 0 : ~(0|A22U114Pad2|A22U118Pad1);
// Gate A22-U210B
pullup(A22U207Pad6);
assign (highz1,strong0) #0.2  A22U207Pad6 = rst ? 0 : ~(0|HIGH1_|LOW0_|A22U210Pad3);
// Gate A22-U259B
pullup(A22U254Pad6);
assign (highz1,strong0) #0.2  A22U254Pad6 = rst ? 0 : ~(0|HIGH2_|LOW0_|A22U259Pad3);
// Gate A22-U120B
pullup(ORDRBT);
assign (highz1,strong0) #0.2  ORDRBT = rst ? 0 : ~(0|A22U118Pad1|A22U119Pad2);
// Gate A22-U231A
pullup(A22U231Pad1);
assign (highz1,strong0) #0.2  A22U231Pad1 = rst ? 1 : ~(0|A22U231Pad2|A22U231Pad3);
// Gate A22-U236B
pullup(A22U236Pad9);
assign (highz1,strong0) #0.2  A22U236Pad9 = rst ? 0 : ~(0|LOW3_|HIGH3_|A22U235Pad1);
// Gate A22-U160A A22-U159A A22-U159B
pullup(WCH13_);
assign (highz1,strong0) #0.2  WCH13_ = rst ? 1 : ~(0|A22U159Pad2);
// Gate A22-U250A
pullup(A22U250Pad1);
assign (highz1,strong0) #0.2  A22U250Pad1 = rst ? 1 : ~(0|A22U250Pad2|A22U250Pad3);
// Gate A22-U151B
pullup(A22U148Pad2);
assign (highz1,strong0) #0.2  A22U148Pad2 = rst ? 0 : ~(0|XB4_|XT1_);
// Gate A22-U231B
pullup(A22U231Pad2);
assign (highz1,strong0) #0.2  A22U231Pad2 = rst ? 0 : ~(0|WCH35_|CHWL02_);
// Gate A22-U105A
pullup(A22U105Pad1);
assign (highz1,strong0) #0.2  A22U105Pad1 = rst ? 0 : ~(0|A22U105Pad2|A22U105Pad3|A22U104Pad1);
// Gate A22-U105B
pullup(A22U105Pad2);
assign (highz1,strong0) #0.2  A22U105Pad2 = rst ? 1 : ~(0|A22U105Pad1|A22U104Pad1|d1CNT);
// Gate A22-U106A
pullup(A22U105Pad3);
assign (highz1,strong0) #0.2  A22U105Pad3 = rst ? 0 : ~(0|A22U106Pad2|A22U105Pad1);
// Gate A22-U209B
pullup(A22U209Pad2);
assign (highz1,strong0) #0.2  A22U209Pad2 = rst ? 0 : ~(0|WCH34_|CHWL06_);
// Gate A22-U103A
pullup(ADVCTR);
assign (highz1,strong0) #0.2  ADVCTR = rst ? 0 : ~(0|BSYNC_|RDOUT_|WDORDR);
// Gate A22-U248A
pullup(A22U248Pad1);
assign (highz1,strong0) #0.2  A22U248Pad1 = rst ? 1 : ~(0|A22U248Pad2|A22U248Pad3);
// Gate A22-U224B
pullup(A22U224Pad2);
assign (highz1,strong0) #0.2  A22U224Pad2 = rst ? 0 : ~(0|WCH34_|CHWL13_);
// Gate A22-U160B
pullup(A22U159Pad2);
assign (highz1,strong0) #0.2  A22U159Pad2 = rst ? 0 : ~(0|XT1_|XB3_|WCHG_);
// Gate A22-U101B
pullup(A22U101Pad2);
assign (highz1,strong0) #0.2  A22U101Pad2 = rst ? 1 : ~(0|DKSTRT);
// Gate A22-U155B
pullup(A22U151Pad2);
assign (highz1,strong0) #0.2  A22U151Pad2 = rst ? 0 : ~(0|XB4_|XT1_|WCHG_);
// Gate A22-U232A
pullup(A22U231Pad3);
assign (highz1,strong0) #0.2  A22U231Pad3 = rst ? 0 : ~(0|CCH35|A22U231Pad1);
// Gate A22-U251A
pullup(A22U250Pad3);
assign (highz1,strong0) #0.2  A22U250Pad3 = rst ? 0 : ~(0|CCH35|A22U250Pad1);
// Gate A22-U233A
pullup(A22U233Pad1);
assign (highz1,strong0) #0.2  A22U233Pad1 = rst ? 1 : ~(0|A22U233Pad2|A22U233Pad3);
// Gate A22-U114B
pullup(A22U114Pad2);
assign (highz1,strong0) #0.2  A22U114Pad2 = rst ? 0 : ~(0|A22U113Pad1|A22U114Pad8);
// Gate A22-U116A
pullup(A22U114Pad3);
assign (highz1,strong0) #0.2  A22U114Pad3 = rst ? 1 : ~(0|A22U113Pad1|A22U114Pad1);
// Gate A22-U114A
pullup(A22U114Pad1);
assign (highz1,strong0) #0.2  A22U114Pad1 = rst ? 0 : ~(0|A22U114Pad2|A22U114Pad3);
// Gate A22-U204A
pullup(A22U203Pad3);
assign (highz1,strong0) #0.2  A22U203Pad3 = rst ? 0 : ~(0|CCH34|A22U203Pad1);
// Gate A22-U115B
pullup(A22U114Pad8);
assign (highz1,strong0) #0.2  A22U114Pad8 = rst ? 1 : ~(0|A22U115Pad1);
// Gate A22-U203B
pullup(A22U203Pad2);
assign (highz1,strong0) #0.2  A22U203Pad2 = rst ? 0 : ~(0|WCH34_|CHWL04_);
// Gate A22-U239B
pullup(A22U239Pad2);
assign (highz1,strong0) #0.2  A22U239Pad2 = rst ? 0 : ~(0|CHWL06_|WCH35_);
// Gate A22-U237B
pullup(A22U237Pad2);
assign (highz1,strong0) #0.2  A22U237Pad2 = rst ? 0 : ~(0|CHWL05_|WCH35_);
// Gate A22-U145B
pullup(A22U145Pad2);
assign (highz1,strong0) #0.2  A22U145Pad2 = rst ? 0 : ~(0|DKCTR3|DKCTR2|DKCTR1);
// Gate A22-U239A
pullup(A22U239Pad1);
assign (highz1,strong0) #0.2  A22U239Pad1 = rst ? 1 : ~(0|A22U239Pad2|A22U239Pad3);
// Gate A22-U244B
pullup(A22U241Pad3);
assign (highz1,strong0) #0.2  A22U241Pad3 = rst ? 0 : ~(0|LOW7_|HIGH2_|A22U244Pad3);
// Gate A22-U242B
pullup(A22U241Pad2);
assign (highz1,strong0) #0.2  A22U241Pad2 = rst ? 0 : ~(0|HIGH3_|LOW0_|A22U242Pad2);
// Gate A22-U103B
pullup(RDOUT_);
assign (highz1,strong0) #0.2  RDOUT_ = rst ? 0 : ~(0|A22U102Pad9|DLKCLR);
// Gate A22-U247B
pullup(A22U241Pad4);
assign (highz1,strong0) #0.2  A22U241Pad4 = rst ? 0 : ~(0|LOW6_|HIGH2_|A22U246Pad1);
// Gate A22-U229A
pullup(A22U229Pad1);
assign (highz1,strong0) #0.2  A22U229Pad1 = rst ? 1 : ~(0|A22U229Pad2|A22U229Pad3);
// Gate A22-U223A
pullup(A22U223Pad1);
assign (highz1,strong0) #0.2  A22U223Pad1 = rst ? 0 : ~(0|CCH34|A22U223Pad3);
// Gate A22-U229B
pullup(A22U229Pad2);
assign (highz1,strong0) #0.2  A22U229Pad2 = rst ? 0 : ~(0|WCH34_|PC15_);
// Gate A22-U146A
pullup(BSYNC_);
assign (highz1,strong0) #0.2  BSYNC_ = rst ? 1 : ~(0|DKBSNC);
// Gate A22-U258A
pullup(A22U257Pad3);
assign (highz1,strong0) #0.2  A22U257Pad3 = rst ? 1 : ~(0|A22U258Pad2|A22U257Pad1);
// Gate A22-U257A
pullup(A22U257Pad1);
assign (highz1,strong0) #0.2  A22U257Pad1 = rst ? 0 : ~(0|CCH35|A22U257Pad3);
// Gate A22-U113A
pullup(A22U113Pad1);
assign (highz1,strong0) #0.2  A22U113Pad1 = rst ? 0 : ~(0|BSYNC_);
// Gate A22-U211B
pullup(A22U211Pad2);
assign (highz1,strong0) #0.2  A22U211Pad2 = rst ? 0 : ~(0|WCH34_|CHWL07_);
// Gate A22-U240A
pullup(A22U239Pad3);
assign (highz1,strong0) #0.2  A22U239Pad3 = rst ? 0 : ~(0|CCH35|A22U239Pad1);
// Gate A22-U124A
pullup(DKCTR3_);
assign (highz1,strong0) #0.2  DKCTR3_ = rst ? 1 : ~(0|A22U122Pad8);
// Gate A22-U132B A22-U133B A22-U220A A22-U220B A22-U241A A22-U241B A22-U254A A22-U254B A22-U207A A22-U207B
pullup(DATA_);
assign (highz1,strong0) #0.2  DATA_ = rst ? 1 : ~(0|A22U132Pad6|A22U132Pad7|WRD2B2|WRD1BP|WRD2B3|WRD1B1|A22U220Pad2|A22U220Pad3|A22U220Pad4|A22U219Pad9|A22U217Pad9|A22U215Pad9|A22U241Pad2|A22U241Pad3|A22U241Pad4|A22U240Pad9|A22U238Pad9|A22U236Pad9|A22U253Pad9|A22U249Pad9|A22U251Pad9|A22U254Pad6|A22U254Pad7|A22U254Pad8|A22U206Pad9|A22U204Pad9|A22U202Pad9|A22U207Pad6|A22U207Pad7|A22U207Pad8);
// Gate A22-U250B
pullup(A22U250Pad2);
assign (highz1,strong0) #0.2  A22U250Pad2 = rst ? 0 : ~(0|CHWL11_|WCH35_);
// Gate A22-U142B
pullup(A22U142Pad2);
assign (highz1,strong0) #0.2  A22U142Pad2 = rst ? 0 : ~(0|DKCTR1_|DKCTR2_|DKCTR3);
// Gate A22-U129B
pullup(d16CNT);
assign (highz1,strong0) #0.2  d16CNT = rst ? 0 : ~(0|A22U128Pad2|DKCTR5);
// Gate A22-U251B
pullup(A22U251Pad9);
assign (highz1,strong0) #0.2  A22U251Pad9 = rst ? 0 : ~(0|LOW4_|HIGH2_|A22U250Pad1);
// Gate A22-U141B
pullup(A22U141Pad2);
assign (highz1,strong0) #0.2  A22U141Pad2 = rst ? 0 : ~(0|DKCTR3_|DKCTR2|DKCTR1);
// Gate A22-U209A
pullup(A22U208Pad3);
assign (highz1,strong0) #0.2  A22U208Pad3 = rst ? 1 : ~(0|A22U209Pad2|A22U208Pad1);
// Gate A22-U221A
pullup(A22U221Pad1);
assign (highz1,strong0) #0.2  A22U221Pad1 = rst ? 1 : ~(0|A22U221Pad2|A22U221Pad3);
// Gate A22-U222A
pullup(A22U221Pad3);
assign (highz1,strong0) #0.2  A22U221Pad3 = rst ? 0 : ~(0|CCH34|A22U221Pad1);
// Gate A22-U108A
pullup(DKCTR1_);
assign (highz1,strong0) #0.2  DKCTR1_ = rst ? 1 : ~(0|A22U106Pad8);
// Gate A22-U149A A22-U150A A22-U150B
pullup(CCH14);
assign (highz1,strong0) #0.2  CCH14 = rst ? 1 : ~(0|A22U149Pad2);
// Gate A22-U218A
pullup(A22U218Pad1);
assign (highz1,strong0) #0.2  A22U218Pad1 = rst ? 1 : ~(0|A22U218Pad2|A22U218Pad3);
// Gate A22-U138B
pullup(A22U138Pad2);
assign (highz1,strong0) #0.2  A22U138Pad2 = rst ? 0 : ~(0|DKCTR1_|DKCTR3_|DKCTR2_);
// Gate A22-U208A
pullup(A22U208Pad1);
assign (highz1,strong0) #0.2  A22U208Pad1 = rst ? 0 : ~(0|CCH34|A22U208Pad3);
// Gate A22-U156A
pullup(A22U156Pad1);
assign (highz1,strong0) #0.2  A22U156Pad1 = rst ? 0 : ~(0|A22U156Pad2|GOJAM);
// Gate A22-U158B
pullup(A22U156Pad2);
assign (highz1,strong0) #0.2  A22U156Pad2 = rst ? 0 : ~(0|XB3_|XT1_|CCHG_);
// Gate A22-U158A A22-U157A A22-U157B
pullup(CCH13);
assign (highz1,strong0) #0.2  CCH13 = rst ? 1 : ~(0|A22U156Pad1);
// Gate A22-U215B
pullup(A22U215Pad9);
assign (highz1,strong0) #0.2  A22U215Pad9 = rst ? 0 : ~(0|HIGH0_|LOW6_|A22U214Pad1);
// Gate A22-U204B
pullup(A22U204Pad9);
assign (highz1,strong0) #0.2  A22U204Pad9 = rst ? 0 : ~(0|HIGH1_|LOW3_|A22U203Pad1);
// Gate A22-U141A
pullup(LOW4_);
assign (highz1,strong0) #0.2  LOW4_ = rst ? 1 : ~(0|A22U141Pad2);
// Gate A22-U216B
pullup(A22U216Pad2);
assign (highz1,strong0) #0.2  A22U216Pad2 = rst ? 0 : ~(0|WCH34_|CHWL10_);
// Gate A22-U216A
pullup(A22U216Pad1);
assign (highz1,strong0) #0.2  A22U216Pad1 = rst ? 1 : ~(0|A22U216Pad2|A22U216Pad3);
// Gate A22-U217A
pullup(A22U216Pad3);
assign (highz1,strong0) #0.2  A22U216Pad3 = rst ? 0 : ~(0|CCH34|A22U216Pad1);
// Gate A22-U138A
pullup(LOW7_);
assign (highz1,strong0) #0.2  LOW7_ = rst ? 1 : ~(0|A22U138Pad2);
// Gate A22-U234B
pullup(WRD2B3);
assign (highz1,strong0) #0.2  WRD2B3 = rst ? 0 : ~(0|LOW4_|HIGH3_|A22U233Pad1);
// Gate A22-U232B
pullup(WRD2B2);
assign (highz1,strong0) #0.2  WRD2B2 = rst ? 0 : ~(0|LOW5_|HIGH3_|A22U231Pad1);
// Gate A22-U245A
pullup(A22U244Pad3);
assign (highz1,strong0) #0.2  A22U244Pad3 = rst ? 1 : ~(0|A22U245Pad2|A22U244Pad1);
// Gate A22-U224A
pullup(A22U223Pad3);
assign (highz1,strong0) #0.2  A22U223Pad3 = rst ? 1 : ~(0|A22U224Pad2|A22U223Pad1);
// Gate A22-U243A
pullup(A22U242Pad2);
assign (highz1,strong0) #0.2  A22U242Pad2 = rst ? 1 : ~(0|A22U243Pad2|A22U242Pad1);
// Gate A22-U256B
pullup(A22U256Pad2);
assign (highz1,strong0) #0.2  A22U256Pad2 = rst ? 0 : ~(0|CHWL13_|WCH35_);
// Gate A22-U226B
pullup(A22U220Pad2);
assign (highz1,strong0) #0.2  A22U220Pad2 = rst ? 0 : ~(0|HIGH1_|LOW5_|A22U225Pad1);
// Gate A22-U112A
pullup(DKCTR2_);
assign (highz1,strong0) #0.2  DKCTR2_ = rst ? 0 : ~(0|A22U110Pad8);
// Gate A22-U214A
pullup(A22U214Pad1);
assign (highz1,strong0) #0.2  A22U214Pad1 = rst ? 1 : ~(0|A22U214Pad2|A22U214Pad3);
// Gate A22-U215A
pullup(A22U214Pad3);
assign (highz1,strong0) #0.2  A22U214Pad3 = rst ? 0 : ~(0|CCH34|A22U214Pad1);
// Gate A22-U223B
pullup(A22U220Pad3);
assign (highz1,strong0) #0.2  A22U220Pad3 = rst ? 0 : ~(0|HIGH0_|LOW2_|A22U223Pad3);
// Gate A22-U134A
pullup(A22U132Pad6);
assign (highz1,strong0) #0.2  A22U132Pad6 = rst ? 0 : ~(0|LOW1_|A22U134Pad3|HIGH0_);
// Gate A22-U134B
pullup(A22U132Pad7);
assign (highz1,strong0) #0.2  A22U132Pad7 = rst ? 0 : ~(0|LOW0_|HIGH0_|A22U134Pad8);
// Gate A22-U242A
pullup(A22U242Pad1);
assign (highz1,strong0) #0.2  A22U242Pad1 = rst ? 0 : ~(0|A22U242Pad2|CCH35);
// Gate A22-U222B
pullup(A22U220Pad4);
assign (highz1,strong0) #0.2  A22U220Pad4 = rst ? 0 : ~(0|HIGH0_|LOW3_|A22U221Pad1);
// Gate A22-U247A
pullup(A22U246Pad3);
assign (highz1,strong0) #0.2  A22U246Pad3 = rst ? 0 : ~(0|CCH35|A22U246Pad1);
// Gate A22-U219B
pullup(A22U219Pad9);
assign (highz1,strong0) #0.2  A22U219Pad9 = rst ? 0 : ~(0|HIGH0_|LOW4_|A22U218Pad1);
// Gate A22-U153A
pullup(A22U149Pad2);
assign (highz1,strong0) #0.2  A22U149Pad2 = rst ? 0 : ~(0|GOJAM|A22U153Pad3);
// Gate A22-U212B
pullup(A22U207Pad8);
assign (highz1,strong0) #0.2  A22U207Pad8 = rst ? 0 : ~(0|HIGH0_|LOW7_|A22U212Pad2);
// Gate A22-U243B
pullup(A22U243Pad2);
assign (highz1,strong0) #0.2  A22U243Pad2 = rst ? 0 : ~(0|CHWL07_|WCH35_);
// Gate A22-U102B
pullup(A22U102Pad9);
assign (highz1,strong0) #0.2  A22U102Pad9 = rst ? 1 : ~(0|END|RDOUT_);
// Gate A22-U135B
pullup(A22U135Pad9);
assign (highz1,strong0) #0.2  A22U135Pad9 = rst ? 0 : ~(0|A22U134Pad8|CCH34);
// Gate A22-U123B
pullup(A22U122Pad2);
assign (highz1,strong0) #0.2  A22U122Pad2 = rst ? 1 : ~(0|A22U121Pad1|DLKCLR|A22U122Pad8);
// Gate A22-U143A
pullup(LOW2_);
assign (highz1,strong0) #0.2  LOW2_ = rst ? 0 : ~(0|A22U143Pad2);
// Gate A22-U135A
pullup(A22U135Pad1);
assign (highz1,strong0) #0.2  A22U135Pad1 = rst ? 0 : ~(0|A22U134Pad3|CCH34);
// Gate A22-U123A
pullup(A22U122Pad8);
assign (highz1,strong0) #0.2  A22U122Pad8 = rst ? 0 : ~(0|A22U122Pad2|A22U121Pad2);
// Gate A22-U153B
pullup(A22U153Pad3);
assign (highz1,strong0) #0.2  A22U153Pad3 = rst ? 0 : ~(0|XB4_|CCHG_|XT1_);
// Gate A22-U139B
pullup(A22U139Pad2);
assign (highz1,strong0) #0.2  A22U139Pad2 = rst ? 0 : ~(0|DKCTR1|DKCTR3_|DKCTR2_);
// Gate A22-U154A A22-U154B A22-U155A
pullup(RCH13_);
assign (highz1,strong0) #0.2  RCH13_ = rst ? 1 : ~(0|A22U154Pad2);
// Gate A22-U255B
pullup(A22U254Pad8);
assign (highz1,strong0) #0.2  A22U254Pad8 = rst ? 0 : ~(0|LOW2_|HIGH2_|A22U255Pad3);
// Gate A22-U130B
pullup(DKCTR5_);
assign (highz1,strong0) #0.2  DKCTR5_ = rst ? 1 : ~(0|DLKCLR|A22U128Pad1|DKCTR5);
// Gate A22-U257B
pullup(A22U254Pad7);
assign (highz1,strong0) #0.2  A22U254Pad7 = rst ? 0 : ~(0|LOW1_|HIGH2_|A22U257Pad3);
// Gate A22-U208B
pullup(A22U207Pad7);
assign (highz1,strong0) #0.2  A22U207Pad7 = rst ? 0 : ~(0|HIGH1_|LOW1_|A22U208Pad3);
// Gate A22-U149B A22-U148A A22-U148B
pullup(RCH14_);
assign (highz1,strong0) #0.2  RCH14_ = rst ? 1 : ~(0|A22U148Pad2);
// Gate A22-U115A
pullup(A22U115Pad1);
assign (highz1,strong0) #0.2  A22U115Pad1 = rst ? 0 : ~(0|A22U114Pad3);
// Gate A22-U116B
pullup(A22J1Pad135);
assign (highz1,strong0) #0.2  A22J1Pad135 = rst ? 1 : ~(0);
// Gate A22-U104A
pullup(A22U104Pad1);
assign (highz1,strong0) #0.2  A22U104Pad1 = rst ? 0 : ~(0|A22U104Pad2);
// Gate A22-U104B
pullup(A22U104Pad2);
assign (highz1,strong0) #0.2  A22U104Pad2 = rst ? 1 : ~(0|ADVCTR|DLKCLR);
// Gate A22-U213A
pullup(A22U212Pad2);
assign (highz1,strong0) #0.2  A22U212Pad2 = rst ? 1 : ~(0|A22U213Pad2|A22U212Pad1);
// Gate A22-U212A
pullup(A22U212Pad1);
assign (highz1,strong0) #0.2  A22U212Pad1 = rst ? 0 : ~(0|A22U212Pad2|CCH34);
// Gate A22-U253A
pullup(A22U252Pad3);
assign (highz1,strong0) #0.2  A22U252Pad3 = rst ? 0 : ~(0|CCH35|A22U252Pad1);
// Gate A22-U252B
pullup(A22U252Pad2);
assign (highz1,strong0) #0.2  A22U252Pad2 = rst ? 0 : ~(0|CHWL12_|WCH35_);
// Gate A22-U252A
pullup(A22U252Pad1);
assign (highz1,strong0) #0.2  A22U252Pad1 = rst ? 1 : ~(0|A22U252Pad2|A22U252Pad3);
// Gate A22-U217B
pullup(A22U217Pad9);
assign (highz1,strong0) #0.2  A22U217Pad9 = rst ? 0 : ~(0|HIGH0_|LOW5_|A22U216Pad1);
// Gate A22-U110B
pullup(A22U109Pad8);
assign (highz1,strong0) #0.2  A22U109Pad8 = rst ? 0 : ~(0|A22U109Pad2|A22U110Pad8);
// Gate A22-U240B
pullup(A22U240Pad9);
assign (highz1,strong0) #0.2  A22U240Pad9 = rst ? 0 : ~(0|LOW1_|HIGH3_|A22U239Pad1);
// Gate A22-U109A
pullup(A22U109Pad1);
assign (highz1,strong0) #0.2  A22U109Pad1 = rst ? 1 : ~(0|A22U109Pad2|A22U109Pad3|A22U105Pad3);
// Gate A22-U109B
pullup(A22U109Pad2);
assign (highz1,strong0) #0.2  A22U109Pad2 = rst ? 0 : ~(0|A22U109Pad1|A22U105Pad3|A22U109Pad8);
// Gate A22-U110A
pullup(A22U109Pad3);
assign (highz1,strong0) #0.2  A22U109Pad3 = rst ? 0 : ~(0|A22U110Pad2|A22U109Pad1);
// Gate A22-U152A A22-U152B A22-U151A
pullup(WCH14_);
assign (highz1,strong0) #0.2  WCH14_ = rst ? 1 : ~(0|A22U151Pad2);
// Gate A22-U230A
pullup(A22U229Pad3);
assign (highz1,strong0) #0.2  A22U229Pad3 = rst ? 0 : ~(0|CCH34|A22U229Pad1);
// Gate A22-U106B
pullup(d1CNT);
assign (highz1,strong0) #0.2  d1CNT = rst ? 0 : ~(0|A22U105Pad2|A22U106Pad8);
// Gate A22-U156B
pullup(A22U154Pad2);
assign (highz1,strong0) #0.2  A22U154Pad2 = rst ? 0 : ~(0|XT1_|XB3_);
// Gate A22-U246B
pullup(A22U246Pad2);
assign (highz1,strong0) #0.2  A22U246Pad2 = rst ? 0 : ~(0|CHWL09_|WCH35_);
// Gate A22-U214B
pullup(A22U214Pad2);
assign (highz1,strong0) #0.2  A22U214Pad2 = rst ? 0 : ~(0|CHWL09_|WCH34_);
// Gate A22-U127B
pullup(DKCTR4_);
assign (highz1,strong0) #0.2  DKCTR4_ = rst ? 0 : ~(0|A22U125Pad1|DLKCLR|DKCTR4);
// Gate A22-U119B
pullup(A22U119Pad2);
assign (highz1,strong0) #0.2  A22U119Pad2 = rst ? 1 : ~(0|A22U117Pad9|A22U119Pad1);
// Gate A22-U119A
pullup(A22U119Pad1);
assign (highz1,strong0) #0.2  A22U119Pad1 = rst ? 0 : ~(0|A22U119Pad2|CCH13);
// Gate A22-U255A
pullup(A22U255Pad1);
assign (highz1,strong0) #0.2  A22U255Pad1 = rst ? 0 : ~(0|CCH35|A22U255Pad3);
// Gate A22-U117B
pullup(A22U117Pad9);
assign (highz1,strong0) #0.2  A22U117Pad9 = rst ? 0 : ~(0|WCH13_|CHWL07_);
// Gate A22-U203A
pullup(A22U203Pad1);
assign (highz1,strong0) #0.2  A22U203Pad1 = rst ? 1 : ~(0|A22U203Pad2|A22U203Pad3);
// Gate A22-U226A
pullup(A22U225Pad3);
assign (highz1,strong0) #0.2  A22U225Pad3 = rst ? 0 : ~(0|CCH34|A22U225Pad1);
// Gate A22-U233B
pullup(A22U233Pad2);
assign (highz1,strong0) #0.2  A22U233Pad2 = rst ? 0 : ~(0|CHWL03_|WCH35_);
// Gate A22-U234A
pullup(A22U233Pad3);
assign (highz1,strong0) #0.2  A22U233Pad3 = rst ? 0 : ~(0|CCH35|A22U233Pad1);
// Gate A22-U101A A22-U102A
pullup(DLKCLR);
assign (highz1,strong0) #0.2  DLKCLR = rst ? 0 : ~(0|A22U101Pad2);
// Gate A22-U256A
pullup(A22U255Pad3);
assign (highz1,strong0) #0.2  A22U255Pad3 = rst ? 1 : ~(0|A22U256Pad2|A22U255Pad1);
// Gate A22-U202A
pullup(A22U201Pad3);
assign (highz1,strong0) #0.2  A22U201Pad3 = rst ? 0 : ~(0|CCH34|A22U201Pad1);
// Gate A22-U201B
pullup(A22U201Pad2);
assign (highz1,strong0) #0.2  A22U201Pad2 = rst ? 0 : ~(0|WCH34_|CHWL03_);
// Gate A22-U201A
pullup(A22U201Pad1);
assign (highz1,strong0) #0.2  A22U201Pad1 = rst ? 1 : ~(0|A22U201Pad2|A22U201Pad3);
// Gate A22-U235B
pullup(A22U235Pad2);
assign (highz1,strong0) #0.2  A22U235Pad2 = rst ? 0 : ~(0|CHWL04_|WCH35_);
// Gate A22-U236A
pullup(A22U235Pad3);
assign (highz1,strong0) #0.2  A22U235Pad3 = rst ? 0 : ~(0|CCH35|A22U235Pad1);
// Gate A22-U235A
pullup(A22U235Pad1);
assign (highz1,strong0) #0.2  A22U235Pad1 = rst ? 1 : ~(0|A22U235Pad2|A22U235Pad3);
// Gate A22-U111B
pullup(A22U110Pad2);
assign (highz1,strong0) #0.2  A22U110Pad2 = rst ? 0 : ~(0|A22U109Pad1|DLKCLR|A22U110Pad8);
// Gate A22-U260B
pullup(A22U260Pad2);
assign (highz1,strong0) #0.2  A22U260Pad2 = rst ? 0 : ~(0|CHWL16_|WCH35_);
// Gate A22-U248B
pullup(A22U248Pad2);
assign (highz1,strong0) #0.2  A22U248Pad2 = rst ? 0 : ~(0|CHWL10_|WCH35_);
// Gate A22-U249A
pullup(A22U248Pad3);
assign (highz1,strong0) #0.2  A22U248Pad3 = rst ? 0 : ~(0|CCH35|A22U248Pad1);
// Gate A22-U211A
pullup(A22U210Pad3);
assign (highz1,strong0) #0.2  A22U210Pad3 = rst ? 1 : ~(0|A22U211Pad2|A22U210Pad1);
// Gate A22-U111A
pullup(A22U110Pad8);
assign (highz1,strong0) #0.2  A22U110Pad8 = rst ? 1 : ~(0|A22U110Pad2|A22U109Pad2);
// Gate A22-U140A
pullup(LOW5_);
assign (highz1,strong0) #0.2  LOW5_ = rst ? 1 : ~(0|A22U140Pad2);
// Gate A22-U144B
pullup(A22U144Pad2);
assign (highz1,strong0) #0.2  A22U144Pad2 = rst ? 0 : ~(0|DKCTR1_|DKCTR3|DKCTR2);
// Gate A22-U213B
pullup(A22U213Pad2);
assign (highz1,strong0) #0.2  A22U213Pad2 = rst ? 0 : ~(0|WCH34_|CHWL08_);
// Gate A22-U145A
pullup(LOW0_);
assign (highz1,strong0) #0.2  LOW0_ = rst ? 1 : ~(0|A22U145Pad2);
// Gate A22-U143B
pullup(A22U143Pad2);
assign (highz1,strong0) #0.2  A22U143Pad2 = rst ? 1 : ~(0|DKCTR2_|DKCTR1|DKCTR3);
// Gate A22-U144A
pullup(LOW1_);
assign (highz1,strong0) #0.2  LOW1_ = rst ? 1 : ~(0|A22U144Pad2);
// Gate A22-U227A
pullup(A22U227Pad1);
assign (highz1,strong0) #0.2  A22U227Pad1 = rst ? 1 : ~(0|A22U227Pad2|A22U227Pad3);
// Gate A22-U113B
pullup(F14H);
assign (highz1,strong0) #0.2  F14H = rst ? 0 : ~(0|FS14|FS13_|F12B_);
// Gate A22-U245B
pullup(A22U245Pad2);
assign (highz1,strong0) #0.2  A22U245Pad2 = rst ? 0 : ~(0|CHWL08_|WCH35_);
// Gate A22-U117A
pullup(F12B_);
assign (highz1,strong0) #0.2  F12B_ = rst ? 1 : ~(0|F12B);
// Gate A22-U238B
pullup(A22U238Pad9);
assign (highz1,strong0) #0.2  A22U238Pad9 = rst ? 0 : ~(0|LOW2_|HIGH3_|A22U237Pad1);
// Gate A22-U230B
pullup(WRD1BP);
assign (highz1,strong0) #0.2  WRD1BP = rst ? 0 : ~(0|LOW7_|HIGH1_|A22U229Pad1);
// Gate A22-U120A
pullup(CH1307);
assign (highz1,strong0) #0.2  CH1307 = rst ? 0 : ~(0|A22U119Pad2|RCH13_);
// Gate A22-U249B
pullup(A22U249Pad9);
assign (highz1,strong0) #0.2  A22U249Pad9 = rst ? 0 : ~(0|LOW5_|HIGH2_|A22U248Pad1);
// Gate A22-U147B
pullup(FS13_);
assign (highz1,strong0) #0.2  FS13_ = rst ? 1 : ~(0|FS13);
// Gate A22-U259A
pullup(A22U259Pad1);
assign (highz1,strong0) #0.2  A22U259Pad1 = rst ? 0 : ~(0|CCH35|A22U259Pad3);
// Gate A22-U260A
pullup(A22U259Pad3);
assign (highz1,strong0) #0.2  A22U259Pad3 = rst ? 1 : ~(0|A22U260Pad2|A22U259Pad1);
// Gate A22-U140B
pullup(A22U140Pad2);
assign (highz1,strong0) #0.2  A22U140Pad2 = rst ? 0 : ~(0|DKCTR1_|DKCTR3_|DKCTR2);
// Gate A22-U202B
pullup(A22U202Pad9);
assign (highz1,strong0) #0.2  A22U202Pad9 = rst ? 0 : ~(0|LOW4_|HIGH1_|A22U201Pad1);
// Gate A22-U122B
pullup(A22U121Pad8);
assign (highz1,strong0) #0.2  A22U121Pad8 = rst ? 0 : ~(0|A22U121Pad2|A22U122Pad8);
// Gate A22-U244A
pullup(A22U244Pad1);
assign (highz1,strong0) #0.2  A22U244Pad1 = rst ? 0 : ~(0|CCH35|A22U244Pad3);
// Gate A22-U142A
pullup(LOW3_);
assign (highz1,strong0) #0.2  LOW3_ = rst ? 1 : ~(0|A22U142Pad2);
// Gate A22-U228B
pullup(WRD1B1);
assign (highz1,strong0) #0.2  WRD1B1 = rst ? 0 : ~(0|HIGH1_|LOW6_|A22U227Pad1);
// Gate A22-U121B
pullup(A22U121Pad2);
assign (highz1,strong0) #0.2  A22U121Pad2 = rst ? 1 : ~(0|A22U121Pad1|A22U109Pad3|A22U121Pad8);
// Gate A22-U122A
pullup(A22U121Pad3);
assign (highz1,strong0) #0.2  A22U121Pad3 = rst ? 0 : ~(0|A22U122Pad2|A22U121Pad1);
// Gate A22-U121A
pullup(A22U121Pad1);
assign (highz1,strong0) #0.2  A22U121Pad1 = rst ? 0 : ~(0|A22U121Pad2|A22U121Pad3|A22U109Pad3);
// Gate A22-U221B
pullup(A22U221Pad2);
assign (highz1,strong0) #0.2  A22U221Pad2 = rst ? 0 : ~(0|WCH34_|CHWL12_);
// Gate A22-U218B
pullup(A22U218Pad2);
assign (highz1,strong0) #0.2  A22U218Pad2 = rst ? 0 : ~(0|WCH34_|CHWL11_);
// Gate A22-U118A
pullup(A22U118Pad1);
assign (highz1,strong0) #0.2  A22U118Pad1 = rst ? 1 : ~(0|DLKCLR|WDORDR);
// Gate A22-U107B
pullup(A22U106Pad2);
assign (highz1,strong0) #0.2  A22U106Pad2 = rst ? 1 : ~(0|A22U105Pad1|DLKCLR|A22U106Pad8);
// Gate A22-U258B
pullup(A22U258Pad2);
assign (highz1,strong0) #0.2  A22U258Pad2 = rst ? 0 : ~(0|CHWL14_|WCH35_);
// Gate A22-U225A
pullup(A22U225Pad1);
assign (highz1,strong0) #0.2  A22U225Pad1 = rst ? 1 : ~(0|A22U225Pad2|A22U225Pad3);
// Gate A22-U128B
pullup(A22U128Pad2);
assign (highz1,strong0) #0.2  A22U128Pad2 = rst ? 1 : ~(0|A22U128Pad1|A22U125Pad3|d16CNT);
// Gate A22-U128A
pullup(A22U128Pad1);
assign (highz1,strong0) #0.2  A22U128Pad1 = rst ? 0 : ~(0|A22U128Pad2|d32CNT|A22U125Pad3);
// Gate A22-U225B
pullup(A22U225Pad2);
assign (highz1,strong0) #0.2  A22U225Pad2 = rst ? 0 : ~(0|WCH34_|CHWL02_);
// Gate A22-U107A
pullup(A22U106Pad8);
assign (highz1,strong0) #0.2  A22U106Pad8 = rst ? 0 : ~(0|A22U106Pad2|A22U105Pad2);
// Gate A22-U228A
pullup(A22U227Pad3);
assign (highz1,strong0) #0.2  A22U227Pad3 = rst ? 0 : ~(0|CCH34|A22U227Pad1);
// Gate A22-U227B
pullup(A22U227Pad2);
assign (highz1,strong0) #0.2  A22U227Pad2 = rst ? 0 : ~(0|CHWL01_|WCH34_);
// Gate A22-U132A
pullup(A22U131Pad7);
assign (highz1,strong0) #0.2  A22U131Pad7 = rst ? 0 : ~(0|DATA_|WDORDR);
// Gate A22-U206B
pullup(A22U206Pad9);
assign (highz1,strong0) #0.2  A22U206Pad9 = rst ? 0 : ~(0|HIGH1_|LOW2_|A22U205Pad1);
// Gate A22-U137A
pullup(A22U136Pad2);
assign (highz1,strong0) #0.2  A22U136Pad2 = rst ? 0 : ~(0|CHWL14_|WCH34_);
// Gate A22-U129A
pullup(d32CNT);
assign (highz1,strong0) #0.2  d32CNT = rst ? 0 : ~(0|DKCTR5_|A22U128Pad1);
// Gate A22-U206A
pullup(A22U205Pad3);
assign (highz1,strong0) #0.2  A22U205Pad3 = rst ? 0 : ~(0|CCH34|A22U205Pad1);
// Gate A22-U205B
pullup(A22U205Pad2);
assign (highz1,strong0) #0.2  A22U205Pad2 = rst ? 0 : ~(0|WCH34_|CHWL05_);
// Gate A22-U205A
pullup(A22U205Pad1);
assign (highz1,strong0) #0.2  A22U205Pad1 = rst ? 1 : ~(0|A22U205Pad2|A22U205Pad3);
// Gate A22-U253B
pullup(A22U253Pad9);
assign (highz1,strong0) #0.2  A22U253Pad9 = rst ? 0 : ~(0|LOW3_|HIGH2_|A22U252Pad1);
// Gate A22-U137B
pullup(A22U136Pad8);
assign (highz1,strong0) #0.2  A22U136Pad8 = rst ? 0 : ~(0|CHWL16_|WCH34_);

endmodule
