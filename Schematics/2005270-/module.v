// Verilog module auto-generated for AGC module A19 by dumbVerilog.py

module A19 ( 
  rst, BLKUPL_, BMGXM, BMGXP, BMGYM, BMGYP, BMGZM, BMGZP, BR1, BR1_, C45R,
  CA2_, CA4_, CA5_, CA6_, CCH11, CCH13, CCH14, CCHG_, CGA19, CHWL01_, CHWL02_,
  CHWL03_, CHWL04_, CHWL05_, CHWL06_, CHWL07_, CHWL08_, CHWL09_, CHWL10_,
  CHWL11_, CHWL12_, CNTRSB_, CSG, CXB0_, CXB7_, F04A, F05A_, F05B_, F06B,
  F07B, F07C_, F07D_, F09B, F10A, F10B, F7CSB1_, FS10, GATEX_, GATEY_, GATEZ_,
  GOJAM, GTONE, GTSET, GTSET_, MOUT_, OVF_, POUT_, RCH11_, RCH13_, RCH14_,
  RCH33_, SB0_, SB1_, SB2_, SHINC_, SIGNX, SIGNY, SIGNZ, T06_, T6ON_, UPL0,
  UPL1, WCH11_, WCH13_, WCH14_, WOVR_, XB3_, XB5_, XB6_, XB7_, XLNK0, XLNK1,
  XT3_, ZOUT_, BLKUPL, C45R_, F5ASB0_, F5ASB2, F5ASB2_, UPL0_, UPL1_, XLNK0_,
  XLNK1_, ALRT0, ALRT1, ALT0, ALT1, ALTM, ALTSNC, BMAGXM, BMAGXP, BMAGYM,
  BMAGYP, BMAGZM, BMAGZP, CCH33, CH1109, CH1110, CH1111, CH1112, CH1305,
  CH1306, CH1308, CH1309, CH1401, CH1402, CH1403, CH1404, CH1405, CH1406,
  CH1407, CH1408, CH1409, CH1410, CH3310, CH3311, EMSD, EMSm, EMSp, F06B_,
  F09B_, F10A_, F10B_, F5ASB0, F5BSB2, F5BSB2_, FF1109, FF1109_, FF1110,
  FF1110_, FF1111, FF1111_, FF1112, FF1112_, GYENAB, GYROD, GYRRST, GYRSET,
  GYXM, GYXP, GYYM, GYYP, GYZM, GYZP, INLNKM, INLNKP, OTLNK0, OTLNK1, OTLNKM,
  RHCGO, SH3MS_, T1P, T2P, T3P, T4P, T5P, T6P, THRSTD, THRSTm, THRSTp, UPRUPT,
  W1110
);

input wire rst, BLKUPL_, BMGXM, BMGXP, BMGYM, BMGYP, BMGZM, BMGZP, BR1, BR1_,
  C45R, CA2_, CA4_, CA5_, CA6_, CCH11, CCH13, CCH14, CCHG_, CGA19, CHWL01_,
  CHWL02_, CHWL03_, CHWL04_, CHWL05_, CHWL06_, CHWL07_, CHWL08_, CHWL09_,
  CHWL10_, CHWL11_, CHWL12_, CNTRSB_, CSG, CXB0_, CXB7_, F04A, F05A_, F05B_,
  F06B, F07B, F07C_, F07D_, F09B, F10A, F10B, F7CSB1_, FS10, GATEX_, GATEY_,
  GATEZ_, GOJAM, GTONE, GTSET, GTSET_, MOUT_, OVF_, POUT_, RCH11_, RCH13_,
  RCH14_, RCH33_, SB0_, SB1_, SB2_, SHINC_, SIGNX, SIGNY, SIGNZ, T06_, T6ON_,
  UPL0, UPL1, WCH11_, WCH13_, WCH14_, WOVR_, XB3_, XB5_, XB6_, XB7_, XLNK0,
  XLNK1, XT3_, ZOUT_;

inout wire BLKUPL, C45R_, F5ASB0_, F5ASB2, F5ASB2_, UPL0_, UPL1_, XLNK0_,
  XLNK1_;

output wire ALRT0, ALRT1, ALT0, ALT1, ALTM, ALTSNC, BMAGXM, BMAGXP, BMAGYM,
  BMAGYP, BMAGZM, BMAGZP, CCH33, CH1109, CH1110, CH1111, CH1112, CH1305,
  CH1306, CH1308, CH1309, CH1401, CH1402, CH1403, CH1404, CH1405, CH1406,
  CH1407, CH1408, CH1409, CH1410, CH3310, CH3311, EMSD, EMSm, EMSp, F06B_,
  F09B_, F10A_, F10B_, F5ASB0, F5BSB2, F5BSB2_, FF1109, FF1109_, FF1110,
  FF1110_, FF1111, FF1111_, FF1112, FF1112_, GYENAB, GYROD, GYRRST, GYRSET,
  GYXM, GYXP, GYYM, GYYP, GYZM, GYZP, INLNKM, INLNKP, OTLNK0, OTLNK1, OTLNKM,
  RHCGO, SH3MS_, T1P, T2P, T3P, T4P, T5P, T6P, THRSTD, THRSTm, THRSTp, UPRUPT,
  W1110;

// Gate A19-U155B
pullup(A19U154Pad2);
assign (highz1,strong0) #0.2  A19U154Pad2 = rst ? 1 : ~(0|A19U155Pad1|A19U155Pad8);
// Gate A19-U154B
pullup(THRSTD);
assign (highz1,strong0) #0.2  THRSTD = rst ? 0 : ~(0|F5ASB2_|A19U154Pad2);
// Gate A19-U116A
pullup(A19U116Pad1);
assign (highz1,strong0) #0.2  A19U116Pad1 = rst ? 1 : ~(0|A19U109Pad6|A19U111Pad8);
// Gate A19-U151A
pullup(A19U151Pad1);
assign (highz1,strong0) #0.2  A19U151Pad1 = rst ? 0 : ~(0|ZOUT_|A19U149Pad3);
// Gate A19-U142A
pullup(CH1306);
assign (highz1,strong0) #0.2  CH1306 = rst ? 0 : ~(0|A19U142Pad2|RCH13_);
// Gate A19-U110B
pullup(A19U110Pad3);
assign (highz1,strong0) #0.2  A19U110Pad3 = rst ? 1 : ~(0|A19U109Pad2|A19U109Pad6);
// Gate A19-U216B
pullup(A19U216Pad9);
assign (highz1,strong0) #0.2  A19U216Pad9 = rst ? 1 : ~(0|A19U216Pad1);
// Gate A19-U205A
pullup(GYRRST);
assign (highz1,strong0) #0.2  GYRRST = rst ? 0 : ~(0|F5ASB2_|A19U203Pad1);
// Gate A19-U218B
pullup(A19U218Pad9);
assign (highz1,strong0) #0.2  A19U218Pad9 = rst ? 0 : ~(0|CHWL07_|WCH14_);
// Gate A19-U214A
pullup(GYYP);
assign (highz1,strong0) #0.2  GYYP = rst ? 0 : ~(0|A19U209Pad2|A19U213Pad9);
// Gate A19-U212B
pullup(A19U212Pad9);
assign (highz1,strong0) #0.2  A19U212Pad9 = rst ? 0 : ~(0|A19U210Pad3|A19U212Pad7|SB1_);
// Gate A19-U134A
pullup(CCH33);
assign (highz1,strong0) #0.2  CCH33 = rst ? 0 : ~(0|XT3_|XB3_|CCHG_);
// Gate A19-U243A
pullup(A19U242Pad3);
assign (highz1,strong0) #0.2  A19U242Pad3 = rst ? 0 : ~(0|A19U243Pad2|GATEY_|F5ASB2_);
// Gate A19-U233A
pullup(A19U231Pad2);
assign (highz1,strong0) #0.2  A19U231Pad2 = rst ? 1 : ~(0|BMGXP|A19U232Pad1);
// Gate A19-U256A
pullup(A19U231Pad3);
assign (highz1,strong0) #0.2  A19U231Pad3 = rst ? 1 : ~(0|A19U256Pad2);
// Gate A19-U233B
pullup(A19U231Pad7);
assign (highz1,strong0) #0.2  A19U231Pad7 = rst ? 1 : ~(0|A19U232Pad9|BMGXM);
// Gate A19-U111B
pullup(A19U111Pad9);
assign (highz1,strong0) #0.2  A19U111Pad9 = rst ? 1 : ~(0|A19U103Pad9|A19U111Pad8);
// Gate A19-U114B
pullup(A19U111Pad8);
assign (highz1,strong0) #0.2  A19U111Pad8 = rst ? 0 : ~(0|A19U114Pad7|F5ASB2_);
// Gate A19-U135A
pullup(A19U135Pad1);
assign (highz1,strong0) #0.2  A19U135Pad1 = rst ? 1 : ~(0|A19U134Pad8|A19U135Pad3);
// Gate A19-U230A
pullup(CH1112);
assign (highz1,strong0) #0.2  CH1112 = rst ? 0 : ~(0|RCH11_|FF1112_);
// Gate A19-U224A
pullup(CH1109);
assign (highz1,strong0) #0.2  CH1109 = rst ? 0 : ~(0|RCH11_|FF1109_);
// Gate A19-U225A
pullup(CH1110);
assign (highz1,strong0) #0.2  CH1110 = rst ? 0 : ~(0|RCH11_|FF1110_);
// Gate A19-U156A
pullup(A19U155Pad8);
assign (highz1,strong0) #0.2  A19U155Pad8 = rst ? 0 : ~(0|CHWL04_|WCH14_);
// Gate A19-U228A
pullup(CH1111);
assign (highz1,strong0) #0.2  CH1111 = rst ? 0 : ~(0|RCH11_|FF1111_);
// Gate A19-U243B
pullup(A19U242Pad7);
assign (highz1,strong0) #0.2  A19U242Pad7 = rst ? 0 : ~(0|F5ASB2_|GATEY_|A19U243Pad8);
// Gate A19-U144B
pullup(A19U140Pad3);
assign (highz1,strong0) #0.2  A19U140Pad3 = rst ? 1 : ~(0|A19U144Pad7|A19U141Pad4);
// Gate A19-U236B
pullup(F10A_);
assign (highz1,strong0) #0.2  F10A_ = rst ? 1 : ~(0|F10A);
// Gate A19-U129B
pullup(A19U129Pad9);
assign (highz1,strong0) #0.2  A19U129Pad9 = rst ? 1 : ~(0|A19U129Pad1);
// Gate A19-U207A
pullup(GYROD);
assign (highz1,strong0) #0.2  GYROD = rst ? 0 : ~(0|A19U203Pad3|F5ASB2_);
// Gate A19-U234B
pullup(F06B_);
assign (highz1,strong0) #0.2  F06B_ = rst ? 1 : ~(0|F06B);
// Gate A19-U231B
pullup(BMAGXM);
assign (highz1,strong0) #0.2  BMAGXM = rst ? 0 : ~(0|A19U231Pad7|A19U231Pad3);
// Gate A19-U129A
pullup(A19U129Pad1);
assign (highz1,strong0) #0.2  A19U129Pad1 = rst ? 0 : ~(0|CA5_|XB5_);
// Gate A19-U201B
pullup(A19U201Pad2);
assign (highz1,strong0) #0.2  A19U201Pad2 = rst ? 0 : ~(0|XB7_|CA4_);
// Gate A19-U231A
pullup(BMAGXP);
assign (highz1,strong0) #0.2  BMAGXP = rst ? 0 : ~(0|A19U231Pad2|A19U231Pad3);
// Gate A19-U105B
pullup(A19U105Pad9);
assign (highz1,strong0) #0.2  A19U105Pad9 = rst ? 0 : ~(0|CA5_|CXB7_);
// Gate A19-U138B A19-U117B
pullup(T2P);
assign (highz1,strong0) #0.2  T2P = rst ? 0 : ~(0|OVF_|WOVR_|XB5_|CA2_);
// Gate A19-U222B
pullup(XLNK0_);
assign (highz1,strong0) #0.2  XLNK0_ = rst ? 1 : ~(0|XLNK0);
// Gate A19-U124A
pullup(OTLNKM);
assign (highz1,strong0) #0.2  OTLNKM = rst ? 0 : ~(0|A19U124Pad2|F5ASB0_);
// Gate A19-U217B
pullup(GYXP);
assign (highz1,strong0) #0.2  GYXP = rst ? 0 : ~(0|A19U216Pad9|A19U209Pad2);
// Gate A19-U140A
pullup(A19U137Pad2);
assign (highz1,strong0) #0.2  A19U137Pad2 = rst ? 0 : ~(0|XLNK0_|A19U140Pad3);
// Gate A19-U150A
pullup(A19U149Pad3);
assign (highz1,strong0) #0.2  A19U149Pad3 = rst ? 1 : ~(0|A19U150Pad2);
// Gate A19-U124B
pullup(A19U124Pad9);
assign (highz1,strong0) #0.2  A19U124Pad9 = rst ? 0 : ~(0|A19U123Pad1|F5ASB2_);
// Gate A19-U258A
pullup(A19U256Pad2);
assign (highz1,strong0) #0.2  A19U256Pad2 = rst ? 0 : ~(0|CCH13|A19U257Pad2);
// Gate A19-U251B
pullup(A19U235Pad8);
assign (highz1,strong0) #0.2  A19U235Pad8 = rst ? 0 : ~(0|SB0_|A19U236Pad4|F07C_);
// Gate A19-U250A
pullup(A19U248Pad3);
assign (highz1,strong0) #0.2  A19U248Pad3 = rst ? 1 : ~(0|A19U248Pad8|A19U250Pad3);
// Gate A19-U107A
pullup(A19U107Pad1);
assign (highz1,strong0) #0.2  A19U107Pad1 = rst ? 0 : ~(0|WCH14_|CHWL03_);
// Gate A19-U125A
pullup(A19U124Pad2);
assign (highz1,strong0) #0.2  A19U124Pad2 = rst ? 1 : ~(0|A19U120Pad7|A19U124Pad9);
// Gate A19-U217A
pullup(GYXM);
assign (highz1,strong0) #0.2  GYXM = rst ? 0 : ~(0|A19U208Pad2|A19U216Pad9);
// Gate A19-U236A
pullup(A19U235Pad3);
assign (highz1,strong0) #0.2  A19U235Pad3 = rst ? 0 : ~(0|SIGNX|F7CSB1_|A19U236Pad4);
// Gate A19-U249B
pullup(BLKUPL);
assign (highz1,strong0) #0.2  BLKUPL = rst ? 1 : ~(0|BLKUPL_);
// Gate A19-U255B
pullup(UPL0_);
assign (highz1,strong0) #0.2  UPL0_ = rst ? 1 : ~(0|UPL0);
// Gate A19-U150B
pullup(A19U150Pad2);
assign (highz1,strong0) #0.2  A19U150Pad2 = rst ? 0 : ~(0|CA5_|XB6_);
// Gate A19-U114A
pullup(A19U114Pad1);
assign (highz1,strong0) #0.2  A19U114Pad1 = rst ? 0 : ~(0|GTSET_|A19U109Pad1);
// Gate A19-U245A
pullup(A19U244Pad2);
assign (highz1,strong0) #0.2  A19U244Pad2 = rst ? 0 : ~(0|SIGNY|A19U236Pad4|F7CSB1_);
// Gate A19-U255A
pullup(UPRUPT);
assign (highz1,strong0) #0.2  UPRUPT = rst ? 0 : ~(0|C45R_|BR1_);
// Gate A19-U146B
pullup(EMSp);
assign (highz1,strong0) #0.2  EMSp = rst ? 0 : ~(0|F5ASB0_|A19U146Pad8);
// Gate A19-U253B
pullup(RHCGO);
assign (highz1,strong0) #0.2  RHCGO = rst ? 0 : ~(0|F07C_|A19U253Pad7|SB2_);
// Gate A19-U253A
pullup(A19U236Pad4);
assign (highz1,strong0) #0.2  A19U236Pad4 = rst ? 1 : ~(0|A19U253Pad2);
// Gate A19-U227A
pullup(A19U227Pad1);
assign (highz1,strong0) #0.2  A19U227Pad1 = rst ? 0 : ~(0|WCH11_|CHWL11_);
// Gate A19-U224B
pullup(FF1109_);
assign (highz1,strong0) #0.2  FF1109_ = rst ? 1 : ~(0|A19U222Pad1|FF1109);
// Gate A19-U146A
pullup(EMSm);
assign (highz1,strong0) #0.2  EMSm = rst ? 0 : ~(0|A19U146Pad2|F5ASB0_);
// Gate A19-U259B
pullup(A19U256Pad8);
assign (highz1,strong0) #0.2  A19U256Pad8 = rst ? 1 : ~(0|A19U258Pad9|A19U259Pad8);
// Gate A19-U257A
pullup(CH1308);
assign (highz1,strong0) #0.2  CH1308 = rst ? 0 : ~(0|A19U257Pad2|RCH13_);
// Gate A19-U112B
pullup(ALT1);
assign (highz1,strong0) #0.2  ALT1 = rst ? 0 : ~(0|A19U111Pad9|A19U108Pad2);
// Gate A19-U112A
pullup(ALT0);
assign (highz1,strong0) #0.2  ALT0 = rst ? 0 : ~(0|A19U104Pad1|A19U108Pad2);
// Gate A19-U145B
pullup(A19U144Pad7);
assign (highz1,strong0) #0.2  A19U144Pad7 = rst ? 0 : ~(0|WCH13_|CHWL05_);
// Gate A19-U157A
pullup(A19U157Pad1);
assign (highz1,strong0) #0.2  A19U157Pad1 = rst ? 0 : ~(0|A19U157Pad2|A19U154Pad2);
// Gate A19-U246B
pullup(BMAGZM);
assign (highz1,strong0) #0.2  BMAGZM = rst ? 0 : ~(0|A19U246Pad7|A19U231Pad3);
// Gate A19-U144A
pullup(A19U141Pad4);
assign (highz1,strong0) #0.2  A19U141Pad4 = rst ? 0 : ~(0|CCH13|A19U140Pad3);
// Gate A19-U221A
pullup(A19U220Pad3);
assign (highz1,strong0) #0.2  A19U220Pad3 = rst ? 1 : ~(0|A19U221Pad2|A19U220Pad9);
// Gate A19-U143A
pullup(A19U142Pad2);
assign (highz1,strong0) #0.2  A19U142Pad2 = rst ? 1 : ~(0|A19U143Pad2|A19U136Pad7);
// Gate A19-U202A
pullup(A19U202Pad1);
assign (highz1,strong0) #0.2  A19U202Pad1 = rst ? 0 : ~(0|MOUT_|A19U201Pad1);
// Gate A19-U222A
pullup(A19U222Pad1);
assign (highz1,strong0) #0.2  A19U222Pad1 = rst ? 0 : ~(0|CHWL09_|WCH11_);
// Gate A19-U153A
pullup(A19U153Pad1);
assign (highz1,strong0) #0.2  A19U153Pad1 = rst ? 0 : ~(0|CCH14|A19U147Pad8|A19U151Pad1);
// Gate A19-U128A A19-U252B
pullup(F5ASB2);
assign (highz1,strong0) #0.2  F5ASB2 = rst ? 0 : ~(0|F05A_|SB2_);
// Gate A19-U127A
pullup(F5ASB0);
assign (highz1,strong0) #0.2  F5ASB0 = rst ? 0 : ~(0|F05A_|SB0_);
// Gate A19-U258B
pullup(A19U258Pad9);
assign (highz1,strong0) #0.2  A19U258Pad9 = rst ? 0 : ~(0|RHCGO|A19U256Pad8|CCH13);
// Gate A19-U151B
pullup(EMSD);
assign (highz1,strong0) #0.2  EMSD = rst ? 0 : ~(0|A19U147Pad8|F5ASB2_);
// Gate A19-U206B
pullup(A19U206Pad2);
assign (highz1,strong0) #0.2  A19U206Pad2 = rst ? 0 : ~(0|A19U204Pad9|A19U203Pad3|CCH14);
// Gate A19-U122A
pullup(A19U122Pad1);
assign (highz1,strong0) #0.2  A19U122Pad1 = rst ? 0 : ~(0|A19U120Pad8|GTSET_);
// Gate A19-U252A
pullup(UPL1_);
assign (highz1,strong0) #0.2  UPL1_ = rst ? 1 : ~(0|UPL1);
// Gate A19-U256B
pullup(A19U254Pad8);
assign (highz1,strong0) #0.2  A19U254Pad8 = rst ? 0 : ~(0|F07D_|A19U256Pad8);
// Gate A19-U229B
pullup(FF1112_);
assign (highz1,strong0) #0.2  FF1112_ = rst ? 1 : ~(0|A19U229Pad1|FF1112);
// Gate A19-U248B
pullup(A19U247Pad8);
assign (highz1,strong0) #0.2  A19U247Pad8 = rst ? 0 : ~(0|GATEZ_|F5ASB2_|A19U248Pad8);
// Gate A19-U251A
pullup(A19U250Pad3);
assign (highz1,strong0) #0.2  A19U250Pad3 = rst ? 0 : ~(0|SIGNZ|A19U236Pad4|F7CSB1_);
// Gate A19-U259A
pullup(A19U257Pad2);
assign (highz1,strong0) #0.2  A19U257Pad2 = rst ? 1 : ~(0|A19U259Pad2|A19U256Pad2);
// Gate A19-U209B
pullup(A19U209Pad2);
assign (highz1,strong0) #0.2  A19U209Pad2 = rst ? 0 : ~(0|A19U208Pad2|CCH14);
// Gate A19-U137B
pullup(INLNKM);
assign (highz1,strong0) #0.2  INLNKM = rst ? 0 : ~(0|A19U136Pad7|A19U132Pad8|A19U137Pad8);
// Gate A19-U117A
pullup(ALTM);
assign (highz1,strong0) #0.2  ALTM = rst ? 0 : ~(0|F5ASB0_|A19U116Pad1);
// Gate A19-U242A
pullup(A19U241Pad2);
assign (highz1,strong0) #0.2  A19U241Pad2 = rst ? 1 : ~(0|BMGYP|A19U242Pad3);
// Gate A19-U132B
pullup(A19U132Pad2);
assign (highz1,strong0) #0.2  A19U132Pad2 = rst ? 1 : ~(0|A19U131Pad1|A19U132Pad8);
// Gate A19-U155A
pullup(A19U155Pad1);
assign (highz1,strong0) #0.2  A19U155Pad1 = rst ? 0 : ~(0|A19U155Pad2|A19U154Pad2|CCH14);
// Gate A19-U149B
pullup(A19U148Pad2);
assign (highz1,strong0) #0.2  A19U148Pad2 = rst ? 0 : ~(0|A19U149Pad3|POUT_);
// Gate A19-U159A
pullup(A19U155Pad2);
assign (highz1,strong0) #0.2  A19U155Pad2 = rst ? 0 : ~(0|A19U129Pad9|ZOUT_);
// Gate A19-U133B
pullup(A19U132Pad8);
assign (highz1,strong0) #0.2  A19U132Pad8 = rst ? 0 : ~(0|A19U132Pad2|F04A);
// Gate A19-U214B
pullup(GYZP);
assign (highz1,strong0) #0.2  GYZP = rst ? 0 : ~(0|A19U213Pad1|A19U209Pad2);
// Gate A19-U244A
pullup(A19U243Pad2);
assign (highz1,strong0) #0.2  A19U243Pad2 = rst ? 1 : ~(0|A19U244Pad2|A19U243Pad8);
// Gate A19-U215B
pullup(GYZM);
assign (highz1,strong0) #0.2  GYZM = rst ? 0 : ~(0|A19U213Pad1|A19U208Pad2);
// Gate A19-U239A
pullup(T1P);
assign (highz1,strong0) #0.2  T1P = rst ? 0 : ~(0|CNTRSB_|F10B_);
// Gate A19-U203B
pullup(A19U203Pad2);
assign (highz1,strong0) #0.2  A19U203Pad2 = rst ? 1 : ~(0|A19U202Pad9|A19U202Pad1|A19U203Pad1);
// Gate A19-U203A
pullup(A19U203Pad1);
assign (highz1,strong0) #0.2  A19U203Pad1 = rst ? 0 : ~(0|A19U203Pad2|A19U203Pad3);
// Gate A19-U152A
pullup(A19U152Pad1);
assign (highz1,strong0) #0.2  A19U152Pad1 = rst ? 0 : ~(0|WCH14_|CHWL05_);
// Gate A19-U135B
pullup(A19U134Pad8);
assign (highz1,strong0) #0.2  A19U134Pad8 = rst ? 0 : ~(0|CCH33|A19U135Pad1|GOJAM);
// Gate A19-U244B
pullup(A19U243Pad8);
assign (highz1,strong0) #0.2  A19U243Pad8 = rst ? 0 : ~(0|A19U243Pad2|A19U235Pad8);
// Gate A19-U136B
pullup(INLNKP);
assign (highz1,strong0) #0.2  INLNKP = rst ? 0 : ~(0|A19U132Pad8|A19U136Pad7|A19U136Pad8);
// Gate A19-U260B
pullup(A19U259Pad8);
assign (highz1,strong0) #0.2  A19U259Pad8 = rst ? 0 : ~(0|WCH13_|CHWL09_);
// Gate A19-U213A
pullup(A19U213Pad1);
assign (highz1,strong0) #0.2  A19U213Pad1 = rst ? 1 : ~(0|A19U212Pad1);
// Gate A19-U132A
pullup(A19U131Pad3);
assign (highz1,strong0) #0.2  A19U131Pad3 = rst ? 0 : ~(0|A19U132Pad2|A19U131Pad1);
// Gate A19-U131A
pullup(A19U131Pad1);
assign (highz1,strong0) #0.2  A19U131Pad1 = rst ? 0 : ~(0|C45R_|A19U131Pad3);
// Gate A19-U245B
pullup(F09B_);
assign (highz1,strong0) #0.2  F09B_ = rst ? 1 : ~(0|F09B);
// Gate A19-U213B
pullup(A19U213Pad9);
assign (highz1,strong0) #0.2  A19U213Pad9 = rst ? 1 : ~(0|A19U212Pad9);
// Gate A19-U238B
pullup(T4P);
assign (highz1,strong0) #0.2  T4P = rst ? 0 : ~(0|CNTRSB_|FS10|F09B_);
// Gate A19-U216A
pullup(A19U216Pad1);
assign (highz1,strong0) #0.2  A19U216Pad1 = rst ? 0 : ~(0|A19U212Pad2|SB1_|A19U211Pad2);
// Gate A19-U104B
pullup(A19U101Pad8);
assign (highz1,strong0) #0.2  A19U101Pad8 = rst ? 0 : ~(0|CA6_|CXB0_);
// Gate A19-U101B
pullup(A19U101Pad9);
assign (highz1,strong0) #0.2  A19U101Pad9 = rst ? 1 : ~(0|A19U101Pad8);
// Gate A19-U106A
pullup(OTLNK0);
assign (highz1,strong0) #0.2  OTLNK0 = rst ? 0 : ~(0|A19U105Pad3|BR1|SH3MS_);
// Gate A19-U126A
pullup(OTLNK1);
assign (highz1,strong0) #0.2  OTLNK1 = rst ? 0 : ~(0|A19U126Pad2);
// Gate A19-U101A
pullup(A19U101Pad1);
assign (highz1,strong0) #0.2  A19U101Pad1 = rst ? 0 : ~(0|T06_|SHINC_);
// Gate A19-U205B
pullup(A19U205Pad9);
assign (highz1,strong0) #0.2  A19U205Pad9 = rst ? 0 : ~(0|WCH14_|CHWL10_);
// Gate A19-U136A
pullup(A19U135Pad3);
assign (highz1,strong0) #0.2  A19U135Pad3 = rst ? 0 : ~(0|A19U136Pad2|A19U132Pad2);
// Gate A19-U246A
pullup(BMAGZP);
assign (highz1,strong0) #0.2  BMAGZP = rst ? 0 : ~(0|A19U246Pad2|A19U231Pad3);
// Gate A19-U260A
pullup(A19U259Pad2);
assign (highz1,strong0) #0.2  A19U259Pad2 = rst ? 0 : ~(0|WCH13_|CHWL08_);
// Gate A19-U127B
pullup(F5ASB0_);
assign (highz1,strong0) #0.2  F5ASB0_ = rst ? 1 : ~(0|F5ASB0);
// Gate A19-U154A
pullup(CH1404);
assign (highz1,strong0) #0.2  CH1404 = rst ? 0 : ~(0|A19U154Pad2|RCH14_);
// Gate A19-U152B
pullup(CH1405);
assign (highz1,strong0) #0.2  CH1405 = rst ? 0 : ~(0|A19U147Pad8|RCH14_);
// Gate A19-U220A
pullup(CH1406);
assign (highz1,strong0) #0.2  CH1406 = rst ? 0 : ~(0|RCH14_|A19U220Pad3);
// Gate A19-U218A
pullup(CH1407);
assign (highz1,strong0) #0.2  CH1407 = rst ? 0 : ~(0|RCH14_|A19U212Pad2);
// Gate A19-U122B
pullup(CH1401);
assign (highz1,strong0) #0.2  CH1401 = rst ? 0 : ~(0|A19U121Pad9|RCH14_);
// Gate A19-U111A
pullup(CH1402);
assign (highz1,strong0) #0.2  CH1402 = rst ? 0 : ~(0|A19U108Pad1|RCH14_);
// Gate A19-U110A
pullup(CH1403);
assign (highz1,strong0) #0.2  CH1403 = rst ? 0 : ~(0|RCH14_|A19U110Pad3);
// Gate A19-U118A
pullup(A19U118Pad1);
assign (highz1,strong0) #0.2  A19U118Pad1 = rst ? 1 : ~(0|A19U118Pad2|A19U109Pad6);
// Gate A19-U118B
pullup(A19U118Pad2);
assign (highz1,strong0) #0.2  A19U118Pad2 = rst ? 0 : ~(0|GTONE|A19U118Pad1);
// Gate A19-U210A
pullup(CH1408);
assign (highz1,strong0) #0.2  CH1408 = rst ? 0 : ~(0|RCH14_|A19U210Pad3);
// Gate A19-U208A
pullup(CH1409);
assign (highz1,strong0) #0.2  CH1409 = rst ? 0 : ~(0|A19U208Pad2|RCH14_);
// Gate A19-U209A
pullup(A19U208Pad2);
assign (highz1,strong0) #0.2  A19U208Pad2 = rst ? 1 : ~(0|A19U209Pad2|A19U208Pad9);
// Gate A19-U208B
pullup(A19U208Pad9);
assign (highz1,strong0) #0.2  A19U208Pad9 = rst ? 0 : ~(0|CHWL09_|WCH14_);
// Gate A19-U131B
pullup(C45R_);
assign (highz1,strong0) #0.2  C45R_ = rst ? 1 : ~(0|C45R);
// Gate A19-U156B
pullup(THRSTp);
assign (highz1,strong0) #0.2  THRSTp = rst ? 0 : ~(0|A19U156Pad7|F5ASB0_);
// Gate A19-U123B
pullup(A19U123Pad2);
assign (highz1,strong0) #0.2  A19U123Pad2 = rst ? 0 : ~(0|GOJAM|GTONE|A19U123Pad1);
// Gate A19-U123A
pullup(A19U123Pad1);
assign (highz1,strong0) #0.2  A19U123Pad1 = rst ? 1 : ~(0|A19U123Pad2|A19U122Pad1);
// Gate A19-U248A
pullup(A19U247Pad2);
assign (highz1,strong0) #0.2  A19U247Pad2 = rst ? 0 : ~(0|F5ASB2_|A19U248Pad3|GATEZ_);
// Gate A19-U120A
pullup(ALTSNC);
assign (highz1,strong0) #0.2  ALTSNC = rst ? 0 : ~(0|A19U119Pad1);
// Gate A19-U113A
pullup(ALRT0);
assign (highz1,strong0) #0.2  ALRT0 = rst ? 0 : ~(0|A19U104Pad1|A19U108Pad1);
// Gate A19-U113B
pullup(ALRT1);
assign (highz1,strong0) #0.2  ALRT1 = rst ? 0 : ~(0|A19U111Pad9|A19U108Pad1);
// Gate A19-U242B
pullup(A19U241Pad7);
assign (highz1,strong0) #0.2  A19U241Pad7 = rst ? 1 : ~(0|A19U242Pad7|BMGYM);
// Gate A19-U204B
pullup(A19U204Pad9);
assign (highz1,strong0) #0.2  A19U204Pad9 = rst ? 0 : ~(0|A19U201Pad1|ZOUT_);
// Gate A19-U241B
pullup(BMAGYM);
assign (highz1,strong0) #0.2  BMAGYM = rst ? 0 : ~(0|A19U241Pad7|A19U231Pad3);
// Gate A19-U254A
pullup(A19U253Pad2);
assign (highz1,strong0) #0.2  A19U253Pad2 = rst ? 0 : ~(0|A19U253Pad7|F07B);
// Gate A19-U119A
pullup(A19U119Pad1);
assign (highz1,strong0) #0.2  A19U119Pad1 = rst ? 1 : ~(0|A19U115Pad2|A19U109Pad6|A19U118Pad2);
// Gate A19-U107B
pullup(A19U107Pad9);
assign (highz1,strong0) #0.2  A19U107Pad9 = rst ? 0 : ~(0|CHWL02_|WCH14_);
// Gate A19-U229A
pullup(A19U229Pad1);
assign (highz1,strong0) #0.2  A19U229Pad1 = rst ? 0 : ~(0|WCH11_|CHWL12_);
// Gate A19-U115A
pullup(A19U114Pad7);
assign (highz1,strong0) #0.2  A19U114Pad7 = rst ? 1 : ~(0|A19U115Pad2|A19U114Pad1);
// Gate A19-U102A
pullup(SH3MS_);
assign (highz1,strong0) #0.2  SH3MS_ = rst ? 1 : ~(0|A19U102Pad2|A19U101Pad1);
// Gate A19-U119B
pullup(A19U119Pad9);
assign (highz1,strong0) #0.2  A19U119Pad9 = rst ? 0 : ~(0|WCH14_|CHWL01_);
// Gate A19-U106B
pullup(A19U105Pad3);
assign (highz1,strong0) #0.2  A19U105Pad3 = rst ? 1 : ~(0|A19U105Pad9);
// Gate A19-U105A
pullup(A19U105Pad1);
assign (highz1,strong0) #0.2  A19U105Pad1 = rst ? 0 : ~(0|SH3MS_|A19U105Pad3|BR1_);
// Gate A19-U241A
pullup(BMAGYP);
assign (highz1,strong0) #0.2  BMAGYP = rst ? 0 : ~(0|A19U241Pad2|A19U231Pad3);
// Gate A19-U130B
pullup(F5BSB2_);
assign (highz1,strong0) #0.2  F5BSB2_ = rst ? 1 : ~(0|F5BSB2);
// Gate A19-U250B
pullup(A19U248Pad8);
assign (highz1,strong0) #0.2  A19U248Pad8 = rst ? 0 : ~(0|A19U235Pad8|A19U248Pad3);
// Gate A19-U148B
pullup(A19U148Pad3);
assign (highz1,strong0) #0.2  A19U148Pad3 = rst ? 0 : ~(0|A19U146Pad8|A19U147Pad8);
// Gate A19-U207B
pullup(CH1410);
assign (highz1,strong0) #0.2  CH1410 = rst ? 0 : ~(0|A19U203Pad3|RCH14_);
// Gate A19-U226A
pullup(W1110);
assign (highz1,strong0) #0.2  W1110 = rst ? 0 : ~(0|WCH11_|CHWL10_);
// Gate A19-U108B
pullup(A19U108Pad2);
assign (highz1,strong0) #0.2  A19U108Pad2 = rst ? 0 : ~(0|A19U108Pad1|CCH14);
// Gate A19-U108A
pullup(A19U108Pad1);
assign (highz1,strong0) #0.2  A19U108Pad1 = rst ? 1 : ~(0|A19U108Pad2|A19U107Pad9);
// Gate A19-U221B
pullup(A19U221Pad2);
assign (highz1,strong0) #0.2  A19U221Pad2 = rst ? 0 : ~(0|A19U220Pad3|CCH14);
// Gate A19-U202B
pullup(A19U202Pad9);
assign (highz1,strong0) #0.2  A19U202Pad9 = rst ? 0 : ~(0|POUT_|A19U201Pad1);
// Gate A19-U238A
pullup(T3P);
assign (highz1,strong0) #0.2  T3P = rst ? 0 : ~(0|F10B_|CNTRSB_);
// Gate A19-U239B
pullup(F10B_);
assign (highz1,strong0) #0.2  F10B_ = rst ? 1 : ~(0|F10B);
// Gate A19-U223A
pullup(GYENAB);
assign (highz1,strong0) #0.2  GYENAB = rst ? 0 : ~(0|A19U220Pad3|SB1_);
// Gate A19-U247B
pullup(A19U246Pad7);
assign (highz1,strong0) #0.2  A19U246Pad7 = rst ? 1 : ~(0|BMGZM|A19U247Pad8);
// Gate A19-U143B
pullup(A19U136Pad7);
assign (highz1,strong0) #0.2  A19U136Pad7 = rst ? 0 : ~(0|A19U142Pad2|CCH13);
// Gate A19-U234A
pullup(T6P);
assign (highz1,strong0) #0.2  T6P = rst ? 0 : ~(0|F06B_|T6ON_|CNTRSB_);
// Gate A19-U230B
pullup(FF1112);
assign (highz1,strong0) #0.2  FF1112 = rst ? 0 : ~(0|CCH11|FF1112_);
// Gate A19-U138A A19-U137A
pullup(A19U136Pad2);
assign (highz1,strong0) #0.2  A19U136Pad2 = rst ? 1 : ~(0|A19U138Pad2|A19U138Pad3|A19U137Pad2|A19U137Pad3);
// Gate A19-U130A
pullup(F5BSB2);
assign (highz1,strong0) #0.2  F5BSB2 = rst ? 0 : ~(0|F05B_|SB2_);
// Gate A19-U219B
pullup(A19U212Pad7);
assign (highz1,strong0) #0.2  A19U212Pad7 = rst ? 0 : ~(0|A19U212Pad2|CCH14);
// Gate A19-U157B
pullup(THRSTm);
assign (highz1,strong0) #0.2  THRSTm = rst ? 0 : ~(0|A19U157Pad2|F5ASB0_);
// Gate A19-U102B
pullup(A19U102Pad2);
assign (highz1,strong0) #0.2  A19U102Pad2 = rst ? 0 : ~(0|SH3MS_|CSG);
// Gate A19-U139B
pullup(A19U136Pad8);
assign (highz1,strong0) #0.2  A19U136Pad8 = rst ? 1 : ~(0|A19U138Pad3|A19U137Pad3);
// Gate A19-U247A
pullup(A19U246Pad2);
assign (highz1,strong0) #0.2  A19U246Pad2 = rst ? 1 : ~(0|A19U247Pad2|BMGZP);
// Gate A19-U249A
pullup(XLNK1_);
assign (highz1,strong0) #0.2  XLNK1_ = rst ? 1 : ~(0|XLNK1);
// Gate A19-U211A
pullup(A19U210Pad3);
assign (highz1,strong0) #0.2  A19U210Pad3 = rst ? 1 : ~(0|A19U211Pad2|A19U210Pad9);
// Gate A19-U232B
pullup(A19U232Pad9);
assign (highz1,strong0) #0.2  A19U232Pad9 = rst ? 0 : ~(0|F5ASB2_|GATEX_|A19U232Pad8);
// Gate A19-U226B
pullup(FF1110_);
assign (highz1,strong0) #0.2  FF1110_ = rst ? 1 : ~(0|W1110|FF1110);
// Gate A19-U128B
pullup(F5ASB2_);
assign (highz1,strong0) #0.2  F5ASB2_ = rst ? 1 : ~(0|F5ASB2);
// Gate A19-U223B
pullup(FF1109);
assign (highz1,strong0) #0.2  FF1109 = rst ? 0 : ~(0|CCH11|FF1109_);
// Gate A19-U232A
pullup(A19U232Pad1);
assign (highz1,strong0) #0.2  A19U232Pad1 = rst ? 0 : ~(0|A19U232Pad2|GATEX_|F5ASB2_);
// Gate A19-U215A
pullup(GYYM);
assign (highz1,strong0) #0.2  GYYM = rst ? 0 : ~(0|A19U213Pad9|A19U208Pad2);
// Gate A19-U121B
pullup(A19U121Pad9);
assign (highz1,strong0) #0.2  A19U121Pad9 = rst ? 1 : ~(0|A19U120Pad7|A19U120Pad9);
// Gate A19-U142B
pullup(CH1305);
assign (highz1,strong0) #0.2  CH1305 = rst ? 0 : ~(0|A19U140Pad3|RCH13_);
// Gate A19-U116B
pullup(A19U109Pad6);
assign (highz1,strong0) #0.2  A19U109Pad6 = rst ? 0 : ~(0|GOJAM|GTSET|A19U116Pad1);
// Gate A19-U139A
pullup(A19U137Pad8);
assign (highz1,strong0) #0.2  A19U137Pad8 = rst ? 1 : ~(0|A19U138Pad2|A19U137Pad2);
// Gate A19-U109B
pullup(A19U109Pad2);
assign (highz1,strong0) #0.2  A19U109Pad2 = rst ? 0 : ~(0|A19U109Pad6|A19U109Pad1|CCH14);
// Gate A19-U103B
pullup(A19U103Pad9);
assign (highz1,strong0) #0.2  A19U103Pad9 = rst ? 0 : ~(0|BR1_|A19U101Pad9|SH3MS_);
// Gate A19-U109A
pullup(A19U109Pad1);
assign (highz1,strong0) #0.2  A19U109Pad1 = rst ? 1 : ~(0|A19U109Pad2|A19U107Pad1);
// Gate A19-U206A
pullup(A19U203Pad3);
assign (highz1,strong0) #0.2  A19U203Pad3 = rst ? 1 : ~(0|A19U206Pad2|A19U205Pad9);
// Gate A19-U140B
pullup(A19U137Pad3);
assign (highz1,strong0) #0.2  A19U137Pad3 = rst ? 0 : ~(0|XLNK1_|A19U140Pad3);
// Gate A19-U115B
pullup(A19U115Pad2);
assign (highz1,strong0) #0.2  A19U115Pad2 = rst ? 0 : ~(0|GTONE|GOJAM|A19U114Pad7);
// Gate A19-U103A
pullup(A19U103Pad1);
assign (highz1,strong0) #0.2  A19U103Pad1 = rst ? 0 : ~(0|BR1|SH3MS_|A19U101Pad9);
// Gate A19-U158B
pullup(A19U158Pad9);
assign (highz1,strong0) #0.2  A19U158Pad9 = rst ? 0 : ~(0|A19U154Pad2|A19U156Pad7);
// Gate A19-U145A
pullup(A19U143Pad2);
assign (highz1,strong0) #0.2  A19U143Pad2 = rst ? 0 : ~(0|WCH13_|CHWL06_);
// Gate A19-U148A
pullup(A19U146Pad8);
assign (highz1,strong0) #0.2  A19U146Pad8 = rst ? 1 : ~(0|A19U148Pad2|A19U148Pad3);
// Gate A19-U158A
pullup(A19U157Pad2);
assign (highz1,strong0) #0.2  A19U157Pad2 = rst ? 1 : ~(0|A19U158Pad2|A19U157Pad1);
// Gate A19-U237A
pullup(T5P);
assign (highz1,strong0) #0.2  T5P = rst ? 0 : ~(0|CNTRSB_|F10A_);
// Gate A19-U201A
pullup(A19U201Pad1);
assign (highz1,strong0) #0.2  A19U201Pad1 = rst ? 1 : ~(0|A19U201Pad2);
// Gate A19-U257B
pullup(CH1309);
assign (highz1,strong0) #0.2  CH1309 = rst ? 0 : ~(0|RCH13_|A19U256Pad8);
// Gate A19-U147A
pullup(A19U146Pad2);
assign (highz1,strong0) #0.2  A19U146Pad2 = rst ? 1 : ~(0|A19U147Pad2|A19U147Pad3);
// Gate A19-U204A
pullup(GYRSET);
assign (highz1,strong0) #0.2  GYRSET = rst ? 0 : ~(0|F5ASB2_|A19U203Pad2);
// Gate A19-U235B
pullup(A19U232Pad8);
assign (highz1,strong0) #0.2  A19U232Pad8 = rst ? 1 : ~(0|A19U232Pad2|A19U235Pad8);
// Gate A19-U120B
pullup(A19U120Pad9);
assign (highz1,strong0) #0.2  A19U120Pad9 = rst ? 0 : ~(0|CCH14|A19U120Pad7|A19U120Pad8);
// Gate A19-U121A
pullup(A19U120Pad8);
assign (highz1,strong0) #0.2  A19U120Pad8 = rst ? 1 : ~(0|A19U119Pad9|A19U120Pad9);
// Gate A19-U149A
pullup(A19U147Pad2);
assign (highz1,strong0) #0.2  A19U147Pad2 = rst ? 0 : ~(0|MOUT_|A19U149Pad3);
// Gate A19-U147B
pullup(A19U147Pad3);
assign (highz1,strong0) #0.2  A19U147Pad3 = rst ? 0 : ~(0|A19U146Pad2|A19U147Pad8);
// Gate A19-U125B
pullup(A19U120Pad7);
assign (highz1,strong0) #0.2  A19U120Pad7 = rst ? 0 : ~(0|A19U124Pad2|GOJAM|GTSET);
// Gate A19-U153B
pullup(A19U147Pad8);
assign (highz1,strong0) #0.2  A19U147Pad8 = rst ? 1 : ~(0|A19U152Pad1|A19U153Pad1);
// Gate A19-U160B
pullup(A19U159Pad8);
assign (highz1,strong0) #0.2  A19U159Pad8 = rst ? 0 : ~(0|A19U129Pad9|POUT_);
// Gate A19-U227B
pullup(FF1111_);
assign (highz1,strong0) #0.2  FF1111_ = rst ? 1 : ~(0|A19U227Pad1|FF1111);
// Gate A19-U159B
pullup(A19U156Pad7);
assign (highz1,strong0) #0.2  A19U156Pad7 = rst ? 1 : ~(0|A19U158Pad9|A19U159Pad8);
// Gate A19-U212A
pullup(A19U212Pad1);
assign (highz1,strong0) #0.2  A19U212Pad1 = rst ? 0 : ~(0|A19U212Pad2|SB1_|A19U210Pad3);
// Gate A19-U104A
pullup(A19U104Pad1);
assign (highz1,strong0) #0.2  A19U104Pad1 = rst ? 1 : ~(0|A19U103Pad1);
// Gate A19-U219A
pullup(A19U212Pad2);
assign (highz1,strong0) #0.2  A19U212Pad2 = rst ? 1 : ~(0|A19U212Pad7|A19U218Pad9);
// Gate A19-U141A
pullup(A19U138Pad2);
assign (highz1,strong0) #0.2  A19U138Pad2 = rst ? 0 : ~(0|UPL0_|BLKUPL|A19U141Pad4);
// Gate A19-U141B
pullup(A19U138Pad3);
assign (highz1,strong0) #0.2  A19U138Pad3 = rst ? 0 : ~(0|UPL1_|A19U141Pad4|BLKUPL);
// Gate A19-U228B
pullup(FF1111);
assign (highz1,strong0) #0.2  FF1111 = rst ? 0 : ~(0|CCH11|FF1111_);
// Gate A19-U225B
pullup(FF1110);
assign (highz1,strong0) #0.2  FF1110 = rst ? 0 : ~(0|CCH11|FF1110_);
// Gate A19-U126B
pullup(A19U126Pad2);
assign (highz1,strong0) #0.2  A19U126Pad2 = rst ? 1 : ~(0|A19U105Pad1|A19U124Pad9);
// Gate A19-U220B
pullup(A19U220Pad9);
assign (highz1,strong0) #0.2  A19U220Pad9 = rst ? 0 : ~(0|CHWL06_|WCH14_);
// Gate A19-U133A
pullup(CH3310);
assign (highz1,strong0) #0.2  CH3310 = rst ? 0 : ~(0|RCH33_|BLKUPL);
// Gate A19-U235A
pullup(A19U232Pad2);
assign (highz1,strong0) #0.2  A19U232Pad2 = rst ? 0 : ~(0|A19U232Pad8|A19U235Pad3);
// Gate A19-U254B
pullup(A19U253Pad7);
assign (highz1,strong0) #0.2  A19U253Pad7 = rst ? 1 : ~(0|A19U253Pad2|A19U254Pad8);
// Gate A19-U211B
pullup(A19U211Pad2);
assign (highz1,strong0) #0.2  A19U211Pad2 = rst ? 0 : ~(0|A19U210Pad3|CCH14);
// Gate A19-U210B
pullup(A19U210Pad9);
assign (highz1,strong0) #0.2  A19U210Pad9 = rst ? 0 : ~(0|CHWL08_|WCH14_);
// Gate A19-U160A
pullup(A19U158Pad2);
assign (highz1,strong0) #0.2  A19U158Pad2 = rst ? 0 : ~(0|MOUT_|A19U129Pad9);
// Gate A19-U134B
pullup(CH3311);
assign (highz1,strong0) #0.2  CH3311 = rst ? 0 : ~(0|RCH33_|A19U134Pad8);

endmodule
