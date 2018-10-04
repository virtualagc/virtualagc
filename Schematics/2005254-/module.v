// Verilog module auto-generated for AGC module A20 by dumbVerilog.py

module A20 ( 
  rst, BKTF_, CA5_, CDUXD, CDUXM, CDUXP, CDUYD, CDUYM, CDUYP, CDUZD, CDUZM,
  CDUZP, CG26, CGA20, CXB0_, CXB1_, CXB5_, CXB6_, OCTAD2, OCTAD3, OCTAD4,
  OCTAD6, PIPXM, PIPXP, PIPYM, PIPYP, PIPZM, PIPZP, RSSB, SHAFTD, SHAFTM,
  SHAFTP, T1P, T2P, T3P, T4P, T5P, T6P, THRSTD, TRNM, TRNP, TRUND, XB2, XB3,
  XB4, XB7, CA2_, CA3_, CA4_, CG11, CG12, CG14, CG21, CG22, CG24, CXB2_,
  CXB3_, CXB4_, CXB7_, C24A, C24R, C25A, C25R, C26A, C26R, C27A, C27R, C30A,
  C30R, C31A, C31R, C32A, C32M, C32P, C32R, C33A, C33M, C33P, C33R, C34A,
  C34M, C34P, C34R, C35A, C35M, C35P, C35R, C36A, C36M, C36P, C36R, C37A,
  C37M, C37P, C37R, C40A, C40M, C40P, C40R, C41A, C41M, C41P, C41R, C50A,
  C50R, C51A, C51R, C52A, C52R, C53A, C53R, C54A, C54R, C55A, C55R, CA6_,
  CG13, CG23
);

input wire rst, BKTF_, CA5_, CDUXD, CDUXM, CDUXP, CDUYD, CDUYM, CDUYP, CDUZD,
  CDUZM, CDUZP, CG26, CGA20, CXB0_, CXB1_, CXB5_, CXB6_, OCTAD2, OCTAD3,
  OCTAD4, OCTAD6, PIPXM, PIPXP, PIPYM, PIPYP, PIPZM, PIPZP, RSSB, SHAFTD,
  SHAFTM, SHAFTP, T1P, T2P, T3P, T4P, T5P, T6P, THRSTD, TRNM, TRNP, TRUND,
  XB2, XB3, XB4, XB7;

inout wire CA2_, CA3_, CA4_, CG11, CG12, CG14, CG21, CG22, CG24, CXB2_, CXB3_,
  CXB4_, CXB7_;

output wire C24A, C24R, C25A, C25R, C26A, C26R, C27A, C27R, C30A, C30R, C31A,
  C31R, C32A, C32M, C32P, C32R, C33A, C33M, C33P, C33R, C34A, C34M, C34P,
  C34R, C35A, C35M, C35P, C35R, C36A, C36M, C36P, C36R, C37A, C37M, C37P,
  C37R, C40A, C40M, C40P, C40R, C41A, C41M, C41P, C41R, C50A, C50R, C51A,
  C51R, C52A, C52R, C53A, C53R, C54A, C54R, C55A, C55R, CA6_, CG13, CG23;

// Gate A20-U208B A20-U206B
pullup(A20J3Pad314);
assign (highz1,strong0) #0.2  A20J3Pad314 = rst ? 0 : ~(0|CG26|A20U208Pad8|A20U206Pad7|A20U206Pad8);
// Gate A20-U142B
pullup(C32P);
assign (highz1,strong0) #0.2  C32P = rst ? 0 : ~(0|A20U131Pad9|CA3_|CXB2_);
// Gate A20-U125B
pullup(A20U108Pad8);
assign (highz1,strong0) #0.2  A20U108Pad8 = rst ? 1 : ~(0|A20U125Pad7|C27R);
// Gate A20-U124B
pullup(C27R);
assign (highz1,strong0) #0.2  C27R = rst ? 0 : ~(0|A20U102Pad2|CXB7_|CA2_);
// Gate A20-U208A
pullup(A20U207Pad4);
assign (highz1,strong0) #0.2  A20U207Pad4 = rst ? 1 : ~(0|C37R|A20U208Pad3);
// Gate A20-U221A
pullup(C36M);
assign (highz1,strong0) #0.2  C36M = rst ? 0 : ~(0|CXB6_|CA3_|A20U221Pad4);
// Gate A20-U111A
pullup(A20U108Pad3);
assign (highz1,strong0) #0.2  A20U108Pad3 = rst ? 1 : ~(0|A20U111Pad2|A20U107Pad4);
// Gate A20-U225A
pullup(C36A);
assign (highz1,strong0) #0.2  C36A = rst ? 0 : ~(0|CG12|A20U224Pad2);
// Gate A20-U226A
pullup(A20U224Pad2);
assign (highz1,strong0) #0.2  A20U224Pad2 = rst ? 1 : ~(0|A20U226Pad2|A20U207Pad2);
// Gate A20-U237A
pullup(C53R);
assign (highz1,strong0) #0.2  C53R = rst ? 0 : ~(0|CXB3_|CA5_|A20U237Pad4);
// Gate A20-U126B
pullup(C27A);
assign (highz1,strong0) #0.2  C27A = rst ? 0 : ~(0|A20U125Pad7|CG21);
// Gate A20-U120B
pullup(A20U118Pad7);
assign (highz1,strong0) #0.2  A20U118Pad7 = rst ? 0 : ~(0|A20U106Pad8|A20U120Pad8);
// Gate A20-U219A
pullup(C36P);
assign (highz1,strong0) #0.2  C36P = rst ? 0 : ~(0|CXB6_|CA3_|A20U219Pad4);
// Gate A20-U203A
pullup(A20U203Pad1);
assign (highz1,strong0) #0.2  A20U203Pad1 = rst ? 1 : ~(0|C37R|A20U201Pad2);
// Gate A20-U220A
pullup(C36R);
assign (highz1,strong0) #0.2  C36R = rst ? 0 : ~(0|CXB6_|CA3_|A20U202Pad2);
// Gate A20-U230B
pullup(A20U229Pad7);
assign (highz1,strong0) #0.2  A20U229Pad7 = rst ? 1 : ~(0|A20U228Pad8|C50R);
// Gate A20-U115A
pullup(A20U114Pad2);
assign (highz1,strong0) #0.2  A20U114Pad2 = rst ? 0 : ~(0|A20U112Pad3|C35R);
// Gate A20-U157B
pullup(A20U157Pad9);
assign (highz1,strong0) #0.2  A20U157Pad9 = rst ? 0 : ~(0|A20U148Pad8|CDUYM);
// Gate A20-U113A
pullup(A20U111Pad2);
assign (highz1,strong0) #0.2  A20U111Pad2 = rst ? 0 : ~(0|A20U113Pad2|A20U113Pad3);
// Gate A20-U245A
pullup(A20U245Pad1);
assign (highz1,strong0) #0.2  A20U245Pad1 = rst ? 1 : ~(0|A20U245Pad2|C55R);
// Gate A20-U241B
pullup(C40R);
assign (highz1,strong0) #0.2  C40R = rst ? 0 : ~(0|A20U237Pad4|CXB0_|CA4_);
// Gate A20-U246A
pullup(A20U245Pad2);
assign (highz1,strong0) #0.2  A20U245Pad2 = rst ? 0 : ~(0|A20U245Pad1|THRSTD);
// Gate A20-U248A
pullup(A20U248Pad1);
assign (highz1,strong0) #0.2  A20U248Pad1 = rst ? 0 : ~(0|A20U233Pad2|A20U245Pad2);
// Gate A20-U246B
pullup(A20U245Pad7);
assign (highz1,strong0) #0.2  A20U245Pad7 = rst ? 1 : ~(0|A20U245Pad9|C41R);
// Gate A20-U207B
pullup(CG24);
assign (highz1,strong0) #0.2  CG24 = rst ? 1 : ~(0|A20J3Pad314);
// Gate A20-U258B
pullup(A20U248Pad8);
assign (highz1,strong0) #0.2  A20U248Pad8 = rst ? 1 : ~(0|A20U257Pad9|C41R);
// Gate A20-U154A
pullup(CG21);
assign (highz1,strong0) #0.2  CG21 = rst ? 1 : ~(0|A20J1Pad115);
// Gate A20-U107B
pullup(CG22);
assign (highz1,strong0) #0.2  CG22 = rst ? 1 : ~(0|A20J2Pad258);
// Gate A20-U254A
pullup(CG23);
assign (highz1,strong0) #0.2  CG23 = rst ? 1 : ~(0|A20J4Pad457);
// Gate A20-U234A
pullup(A20U234Pad1);
assign (highz1,strong0) #0.2  A20U234Pad1 = rst ? 1 : ~(0|A20U234Pad2|A20U233Pad1);
// Gate A20-U242B
pullup(C40P);
assign (highz1,strong0) #0.2  C40P = rst ? 0 : ~(0|A20U231Pad9|CA4_|CXB0_);
// Gate A20-U128B
pullup(A20U127Pad8);
assign (highz1,strong0) #0.2  A20U127Pad8 = rst ? 0 : ~(0|A20U113Pad3|A20U128Pad8);
// Gate A20-U254B
pullup(A20U254Pad9);
assign (highz1,strong0) #0.2  A20U254Pad9 = rst ? 0 : ~(0|A20U250Pad8|CG14|A20U235Pad8);
// Gate A20-U222B
pullup(A20U221Pad7);
assign (highz1,strong0) #0.2  A20U221Pad7 = rst ? 0 : ~(0|A20U222Pad7|CDUYD);
// Gate A20-U135A
pullup(C24A);
assign (highz1,strong0) #0.2  C24A = rst ? 1 : ~(0|A20U134Pad1);
// Gate A20-U114B
pullup(C31R);
assign (highz1,strong0) #0.2  C31R = rst ? 0 : ~(0|A20U102Pad2|CXB1_|CA3_);
// Gate A20-U236B
pullup(C40A);
assign (highz1,strong0) #0.2  C40A = rst ? 0 : ~(0|A20U235Pad9|CG14);
// Gate A20-U109B A20-U110B
pullup(C31A);
assign (highz1,strong0) #0.2  C31A = rst ? 0 : ~(0|A20U109Pad7|A20U106Pad8|CG21|A20U108Pad8);
// Gate A20-U137A
pullup(C24R);
assign (highz1,strong0) #0.2  C24R = rst ? 0 : ~(0|CXB4_|CA2_|A20U137Pad4);
// Gate A20-U127B
pullup(A20U125Pad7);
assign (highz1,strong0) #0.2  A20U125Pad7 = rst ? 0 : ~(0|A20U108Pad8|A20U127Pad8);
// Gate A20-U240B
pullup(C40M);
assign (highz1,strong0) #0.2  C40M = rst ? 0 : ~(0|A20U238Pad7|CA4_|CXB0_);
// Gate A20-U203B A20-U202B
pullup(CXB3_);
assign (highz1,strong0) #0.2  CXB3_ = rst ? 1 : ~(0|XB3);
// Gate A20-U255A A20-U253A
pullup(A20J4Pad457);
assign (highz1,strong0) #0.2  A20J4Pad457 = rst ? 0 : ~(0|A20U241Pad2|A20U249Pad2|CG24|A20U234Pad2);
// Gate A20-U237B
pullup(A20U235Pad8);
assign (highz1,strong0) #0.2  A20U235Pad8 = rst ? 0 : ~(0|A20U235Pad9|C40R);
// Gate A20-U201B
pullup(CA2_);
assign (highz1,strong0) #0.2  CA2_ = rst ? 1 : ~(0|OCTAD2);
// Gate A20-U235B
pullup(A20U235Pad9);
assign (highz1,strong0) #0.2  A20U235Pad9 = rst ? 1 : ~(0|A20U234Pad9|A20U235Pad8);
// Gate A20-U150A
pullup(A20U149Pad2);
assign (highz1,strong0) #0.2  A20U149Pad2 = rst ? 1 : ~(0|C26R|A20U149Pad1);
// Gate A20-U247B
pullup(A20U247Pad9);
assign (highz1,strong0) #0.2  A20U247Pad9 = rst ? 0 : ~(0|A20U247Pad7|A20U233Pad2);
// Gate A20-U130A
pullup(A20U119Pad4);
assign (highz1,strong0) #0.2  A20U119Pad4 = rst ? 1 : ~(0|CDUZP|A20U128Pad2);
// Gate A20-U213B
pullup(A20U212Pad8);
assign (highz1,strong0) #0.2  A20U212Pad8 = rst ? 0 : ~(0|A20U213Pad7|A20U213Pad3);
// Gate A20-U216A
pullup(A20U212Pad3);
assign (highz1,strong0) #0.2  A20U212Pad3 = rst ? 0 : ~(0|PIPXP|A20U214Pad2);
// Gate A20-U147B
pullup(A20U147Pad9);
assign (highz1,strong0) #0.2  A20U147Pad9 = rst ? 0 : ~(0|A20U147Pad7|A20U133Pad2);
// Gate A20-U250B
pullup(A20U250Pad9);
assign (highz1,strong0) #0.2  A20U250Pad9 = rst ? 0 : ~(0|A20U247Pad9|A20U250Pad8);
// Gate A20-U145B
pullup(A20U145Pad9);
assign (highz1,strong0) #0.2  A20U145Pad9 = rst ? 0 : ~(0|A20U145Pad7|CDUYP);
// Gate A20-U243B
pullup(A20U233Pad2);
assign (highz1,strong0) #0.2  A20U233Pad2 = rst ? 1 : ~(0|BKTF_);
// Gate A20-U121A
pullup(C34M);
assign (highz1,strong0) #0.2  C34M = rst ? 0 : ~(0|CXB4_|CA3_|A20U121Pad4);
// Gate A20-U146A
pullup(A20U145Pad2);
assign (highz1,strong0) #0.2  A20U145Pad2 = rst ? 0 : ~(0|T3P|A20U145Pad1);
// Gate A20-U228B
pullup(A20U227Pad8);
assign (highz1,strong0) #0.2  A20U227Pad8 = rst ? 0 : ~(0|A20U213Pad3|A20U228Pad8);
// Gate A20-U219B
pullup(C51A);
assign (highz1,strong0) #0.2  C51A = rst ? 0 : ~(0|A20U218Pad7|CG26|A20U208Pad8);
// Gate A20-U125A
pullup(C34A);
assign (highz1,strong0) #0.2  C34A = rst ? 0 : ~(0|CG11|A20U124Pad2);
// Gate A20-U146B
pullup(A20U145Pad7);
assign (highz1,strong0) #0.2  A20U145Pad7 = rst ? 1 : ~(0|A20U145Pad9|C33R);
// Gate A20-U116B
pullup(A20U115Pad7);
assign (highz1,strong0) #0.2  A20U115Pad7 = rst ? 0 : ~(0|A20U113Pad7|C31R);
// Gate A20-U148B
pullup(A20U147Pad7);
assign (highz1,strong0) #0.2  A20U147Pad7 = rst ? 0 : ~(0|A20U145Pad7|A20U148Pad8);
// Gate A20-U132B
pullup(A20U131Pad8);
assign (highz1,strong0) #0.2  A20U131Pad8 = rst ? 1 : ~(0|A20U131Pad9|C32R);
// Gate A20-U148A
pullup(A20U148Pad1);
assign (highz1,strong0) #0.2  A20U148Pad1 = rst ? 0 : ~(0|A20U133Pad2|A20U145Pad2);
// Gate A20-U120A
pullup(C34R);
assign (highz1,strong0) #0.2  C34R = rst ? 0 : ~(0|CXB4_|CA3_|A20U102Pad2);
// Gate A20-U217B
pullup(C51R);
assign (highz1,strong0) #0.2  C51R = rst ? 0 : ~(0|A20U202Pad2|CA5_|CXB1_);
// Gate A20-U119A
pullup(C34P);
assign (highz1,strong0) #0.2  C34P = rst ? 0 : ~(0|CXB4_|CA3_|A20U119Pad4);
// Gate A20-U240A
pullup(A20U240Pad1);
assign (highz1,strong0) #0.2  A20U240Pad1 = rst ? 0 : ~(0|A20U233Pad2|A20U238Pad2);
// Gate A20-U158B
pullup(A20U148Pad8);
assign (highz1,strong0) #0.2  A20U148Pad8 = rst ? 1 : ~(0|A20U157Pad9|C33R);
// Gate A20-U229A
pullup(A20U228Pad2);
assign (highz1,strong0) #0.2  A20U228Pad2 = rst ? 0 : ~(0|A20U219Pad4|C36R);
// Gate A20-U217A
pullup(A20U213Pad3);
assign (highz1,strong0) #0.2  A20U213Pad3 = rst ? 1 : ~(0|BKTF_);
// Gate A20-U249A
pullup(A20U249Pad1);
assign (highz1,strong0) #0.2  A20U249Pad1 = rst ? 0 : ~(0|A20U249Pad2|A20U248Pad1);
// Gate A20-U229B
pullup(A20U228Pad8);
assign (highz1,strong0) #0.2  A20U228Pad8 = rst ? 0 : ~(0|A20U229Pad7|CDUXD);
// Gate A20-U250A
pullup(A20U249Pad2);
assign (highz1,strong0) #0.2  A20U249Pad2 = rst ? 1 : ~(0|C55R|A20U249Pad1);
// Gate A20-U213A
pullup(A20U211Pad2);
assign (highz1,strong0) #0.2  A20U211Pad2 = rst ? 0 : ~(0|A20U213Pad2|A20U213Pad3);
// Gate A20-U126A
pullup(A20U124Pad2);
assign (highz1,strong0) #0.2  A20U124Pad2 = rst ? 0 : ~(0|A20U126Pad2|A20U107Pad2);
// Gate A20-U153B
pullup(A20U150Pad8);
assign (highz1,strong0) #0.2  A20U150Pad8 = rst ? 1 : ~(0|A20U150Pad9|C33R);
// Gate A20-U150B
pullup(A20U150Pad9);
assign (highz1,strong0) #0.2  A20U150Pad9 = rst ? 0 : ~(0|A20U147Pad9|A20U150Pad8);
// Gate A20-U123B
pullup(A20U122Pad7);
assign (highz1,strong0) #0.2  A20U122Pad7 = rst ? 1 : ~(0|A20U121Pad7|C30R);
// Gate A20-U143A
pullup(A20U141Pad2);
assign (highz1,strong0) #0.2  A20U141Pad2 = rst ? 1 : ~(0|C25R|A20U141Pad1);
// Gate A20-U127A
pullup(A20U126Pad2);
assign (highz1,strong0) #0.2  A20U126Pad2 = rst ? 0 : ~(0|A20U127Pad2|A20U113Pad3);
// Gate A20-U141A
pullup(A20U141Pad1);
assign (highz1,strong0) #0.2  A20U141Pad1 = rst ? 0 : ~(0|A20U141Pad2|A20U140Pad1);
// Gate A20-U129B
pullup(A20U128Pad8);
assign (highz1,strong0) #0.2  A20U128Pad8 = rst ? 1 : ~(0|A20U129Pad7|T4P);
// Gate A20-U201A
pullup(C37M);
assign (highz1,strong0) #0.2  C37M = rst ? 0 : ~(0|A20U201Pad2|CA3_|CXB7_);
// Gate A20-U147A
pullup(C26R);
assign (highz1,strong0) #0.2  C26R = rst ? 0 : ~(0|CA2_|CXB6_|A20U137Pad4);
// Gate A20-U215A
pullup(A20U214Pad2);
assign (highz1,strong0) #0.2  A20U214Pad2 = rst ? 1 : ~(0|A20U212Pad3|C37R);
// Gate A20-U233B
pullup(A20U233Pad9);
assign (highz1,strong0) #0.2  A20U233Pad9 = rst ? 1 : ~(0|A20U233Pad7|A20U231Pad8);
// Gate A20-U226B
pullup(C50A);
assign (highz1,strong0) #0.2  C50A = rst ? 0 : ~(0|A20U225Pad7|CG26);
// Gate A20-U129A
pullup(A20U128Pad2);
assign (highz1,strong0) #0.2  A20U128Pad2 = rst ? 0 : ~(0|A20U119Pad4|C34R);
// Gate A20-U248B
pullup(A20U247Pad7);
assign (highz1,strong0) #0.2  A20U247Pad7 = rst ? 0 : ~(0|A20U245Pad7|A20U248Pad8);
// Gate A20-U224A
pullup(A20U207Pad2);
assign (highz1,strong0) #0.2  A20U207Pad2 = rst ? 0 : ~(0|A20U224Pad2|C36R);
// Gate A20-U209A
pullup(C37A);
assign (highz1,strong0) #0.2  C37A = rst ? 0 : ~(0|A20U207Pad2|CG12|A20U208Pad3);
// Gate A20-U233A
pullup(A20U233Pad1);
assign (highz1,strong0) #0.2  A20U233Pad1 = rst ? 0 : ~(0|A20U233Pad2|A20U231Pad3);
// Gate A20-U151A A20-U152A
pullup(C26A);
assign (highz1,strong0) #0.2  C26A = rst ? 0 : ~(0|A20U134Pad2|A20U141Pad2|A20U149Pad1);
// Gate A20-U107A
pullup(A20U105Pad2);
assign (highz1,strong0) #0.2  A20U105Pad2 = rst ? 0 : ~(0|A20U107Pad2|CG11|A20U107Pad4);
// Gate A20-U218A
pullup(A20U202Pad2);
assign (highz1,strong0) #0.2  A20U202Pad2 = rst ? 1 : ~(0|RSSB);
// Gate A20-U211A
pullup(A20U208Pad3);
assign (highz1,strong0) #0.2  A20U208Pad3 = rst ? 0 : ~(0|A20U211Pad2|A20U207Pad4);
// Gate A20-U105B A20-U104B A20-U156A A20-U157A
pullup(CA3_);
assign (highz1,strong0) #0.2  CA3_ = rst ? 1 : ~(0|OCTAD3);
// Gate A20-U227B
pullup(A20U225Pad7);
assign (highz1,strong0) #0.2  A20U225Pad7 = rst ? 0 : ~(0|A20U208Pad8|A20U227Pad8);
// Gate A20-U202A
pullup(C37R);
assign (highz1,strong0) #0.2  C37R = rst ? 0 : ~(0|A20U202Pad2|CA3_|CXB7_);
// Gate A20-U212A
pullup(C37P);
assign (highz1,strong0) #0.2  C37P = rst ? 0 : ~(0|CXB7_|A20U212Pad3|CA3_);
// Gate A20-U205A
pullup(CG14);
assign (highz1,strong0) #0.2  CG14 = rst ? 1 : ~(0|A20U205Pad2);
// Gate A20-U155B
pullup(A20J1Pad105);
assign (highz1,strong0) #0.2  A20J1Pad105 = rst ? 1 : ~(0);
// Gate A20-U158A A20-U159A
pullup(A20J1Pad104);
assign (highz1,strong0) #0.2  A20J1Pad104 = rst ? 1 : ~(0);
// Gate A20-U156B
pullup(CG11);
assign (highz1,strong0) #0.2  CG11 = rst ? 1 : ~(0|A20U154Pad9);
// Gate A20-U231B
pullup(A20U231Pad9);
assign (highz1,strong0) #0.2  A20U231Pad9 = rst ? 1 : ~(0|PIPYP|A20U231Pad8);
// Gate A20-U256B
pullup(CG13);
assign (highz1,strong0) #0.2  CG13 = rst ? 1 : ~(0|A20U254Pad9);
// Gate A20-U105A
pullup(CG12);
assign (highz1,strong0) #0.2  CG12 = rst ? 1 : ~(0|A20U105Pad2);
// Gate A20-U231A
pullup(A20U231Pad1);
assign (highz1,strong0) #0.2  A20U231Pad1 = rst ? 1 : ~(0|C53R|A20U231Pad3);
// Gate A20-U232A
pullup(A20U231Pad3);
assign (highz1,strong0) #0.2  A20U231Pad3 = rst ? 0 : ~(0|A20U231Pad1|TRUND);
// Gate A20-U204A
pullup(A20U201Pad2);
assign (highz1,strong0) #0.2  A20U201Pad2 = rst ? 0 : ~(0|PIPXM|A20U203Pad1);
// Gate A20-U241A
pullup(A20U241Pad1);
assign (highz1,strong0) #0.2  A20U241Pad1 = rst ? 1 : ~(0|A20U241Pad2|A20U240Pad1);
// Gate A20-U243A
pullup(A20U241Pad2);
assign (highz1,strong0) #0.2  A20U241Pad2 = rst ? 0 : ~(0|C54R|A20U241Pad1);
// Gate A20-U224B
pullup(C50R);
assign (highz1,strong0) #0.2  C50R = rst ? 0 : ~(0|A20U202Pad2|CXB0_|CA5_);
// Gate A20-U121B
pullup(A20U120Pad8);
assign (highz1,strong0) #0.2  A20U120Pad8 = rst ? 0 : ~(0|A20U121Pad7|A20U113Pad3);
// Gate A20-U215B
pullup(A20U213Pad7);
assign (highz1,strong0) #0.2  A20U213Pad7 = rst ? 0 : ~(0|A20U215Pad7|CDUZD);
// Gate A20-U216B
pullup(A20U215Pad7);
assign (highz1,strong0) #0.2  A20U215Pad7 = rst ? 1 : ~(0|A20U213Pad7|C52R);
// Gate A20-U139A
pullup(A20U138Pad2);
assign (highz1,strong0) #0.2  A20U138Pad2 = rst ? 0 : ~(0|A20U138Pad1|T1P);
// Gate A20-U141B
pullup(C32R);
assign (highz1,strong0) #0.2  C32R = rst ? 0 : ~(0|A20U137Pad4|CXB2_|CA3_);
// Gate A20-U138A
pullup(A20U138Pad1);
assign (highz1,strong0) #0.2  A20U138Pad1 = rst ? 1 : ~(0|A20U138Pad2|C25R);
// Gate A20-U139B
pullup(A20U138Pad7);
assign (highz1,strong0) #0.2  A20U138Pad7 = rst ? 1 : ~(0|A20U133Pad7|CDUXM);
// Gate A20-U221B
pullup(A20U220Pad8);
assign (highz1,strong0) #0.2  A20U220Pad8 = rst ? 0 : ~(0|A20U221Pad7|A20U213Pad3);
// Gate A20-U122A
pullup(A20U121Pad4);
assign (highz1,strong0) #0.2  A20U121Pad4 = rst ? 1 : ~(0|CDUZM|A20U122Pad3);
// Gate A20-U122B
pullup(A20U121Pad7);
assign (highz1,strong0) #0.2  A20U121Pad7 = rst ? 0 : ~(0|A20U122Pad7|T5P);
// Gate A20-U235A
pullup(C53A);
assign (highz1,strong0) #0.2  C53A = rst ? 0 : ~(0|CG24|A20U234Pad1);
// Gate A20-U136B
pullup(C32A);
assign (highz1,strong0) #0.2  C32A = rst ? 0 : ~(0|A20U135Pad9|CG22);
// Gate A20-U228A
pullup(A20U227Pad2);
assign (highz1,strong0) #0.2  A20U227Pad2 = rst ? 0 : ~(0|A20U228Pad2|A20U222Pad3);
// Gate A20-U116A
pullup(A20U112Pad3);
assign (highz1,strong0) #0.2  A20U112Pad3 = rst ? 1 : ~(0|TRNP|A20U114Pad2);
// Gate A20-U140B
pullup(C32M);
assign (highz1,strong0) #0.2  C32M = rst ? 0 : ~(0|A20U138Pad7|CA3_|CXB2_);
// Gate A20-U113B
pullup(A20U112Pad8);
assign (highz1,strong0) #0.2  A20U112Pad8 = rst ? 0 : ~(0|A20U113Pad7|A20U113Pad3);
// Gate A20-U155A A20-U153A
pullup(A20J1Pad115);
assign (highz1,strong0) #0.2  A20J1Pad115 = rst ? 0 : ~(0|A20U141Pad2|A20U149Pad2|A20U134Pad2);
// Gate A20-U218B
pullup(A20U206Pad8);
assign (highz1,strong0) #0.2  A20U206Pad8 = rst ? 1 : ~(0|A20U218Pad7|C51R);
// Gate A20-U223B
pullup(A20U222Pad7);
assign (highz1,strong0) #0.2  A20U222Pad7 = rst ? 1 : ~(0|A20U221Pad7|C51R);
// Gate A20-U223A
pullup(A20U222Pad3);
assign (highz1,strong0) #0.2  A20U222Pad3 = rst ? 1 : ~(0|C36R|A20U221Pad4);
// Gate A20-U133A
pullup(A20U133Pad1);
assign (highz1,strong0) #0.2  A20U133Pad1 = rst ? 0 : ~(0|A20U133Pad2|A20U131Pad3);
// Gate A20-U220B
pullup(A20U218Pad7);
assign (highz1,strong0) #0.2  A20U218Pad7 = rst ? 0 : ~(0|A20U206Pad8|A20U220Pad8);
// Gate A20-U143B
pullup(A20U133Pad2);
assign (highz1,strong0) #0.2  A20U133Pad2 = rst ? 1 : ~(0|BKTF_);
// Gate A20-U212B
pullup(A20U209Pad7);
assign (highz1,strong0) #0.2  A20U209Pad7 = rst ? 0 : ~(0|A20U206Pad7|A20U212Pad8);
// Gate A20-U138B
pullup(A20U133Pad7);
assign (highz1,strong0) #0.2  A20U133Pad7 = rst ? 0 : ~(0|A20U138Pad7|C32R);
// Gate A20-U211B
pullup(A20U206Pad7);
assign (highz1,strong0) #0.2  A20U206Pad7 = rst ? 1 : ~(0|A20U209Pad7|C52R);
// Gate A20-U133B
pullup(A20U133Pad9);
assign (highz1,strong0) #0.2  A20U133Pad9 = rst ? 0 : ~(0|A20U133Pad7|A20U131Pad8);
// Gate A20-U128A
pullup(A20U127Pad2);
assign (highz1,strong0) #0.2  A20U127Pad2 = rst ? 1 : ~(0|A20U128Pad2|A20U122Pad3);
// Gate A20-U104A
pullup(A20U101Pad2);
assign (highz1,strong0) #0.2  A20U101Pad2 = rst ? 1 : ~(0|TRNM|A20U103Pad1);
// Gate A20-U145A
pullup(A20U145Pad1);
assign (highz1,strong0) #0.2  A20U145Pad1 = rst ? 1 : ~(0|A20U145Pad2|C26R);
// Gate A20-U214B
pullup(C52R);
assign (highz1,strong0) #0.2  C52R = rst ? 0 : ~(0|A20U202Pad2|CXB2_|CA5_);
// Gate A20-U112A
pullup(C35P);
assign (highz1,strong0) #0.2  C35P = rst ? 0 : ~(0|CXB5_|A20U112Pad3|CA3_);
// Gate A20-U102A
pullup(C35R);
assign (highz1,strong0) #0.2  C35R = rst ? 0 : ~(0|A20U102Pad2|CA3_|CXB5_);
// Gate A20-U108B A20-U106B
pullup(A20J2Pad258);
assign (highz1,strong0) #0.2  A20J2Pad258 = rst ? 0 : ~(0|CG21|A20U108Pad8|A20U106Pad7|A20U106Pad8);
// Gate A20-U117B
pullup(C30R);
assign (highz1,strong0) #0.2  C30R = rst ? 0 : ~(0|A20U102Pad2|CA3_|CXB0_);
// Gate A20-U230A
pullup(A20U219Pad4);
assign (highz1,strong0) #0.2  A20U219Pad4 = rst ? 1 : ~(0|SHAFTP|A20U228Pad2);
// Gate A20-U118A
pullup(A20U102Pad2);
assign (highz1,strong0) #0.2  A20U102Pad2 = rst ? 1 : ~(0|RSSB);
// Gate A20-U154B
pullup(A20U154Pad9);
assign (highz1,strong0) #0.2  A20U154Pad9 = rst ? 0 : ~(0|A20U150Pad8|CG22|A20U135Pad8);
// Gate A20-U225B
pullup(A20U208Pad8);
assign (highz1,strong0) #0.2  A20U208Pad8 = rst ? 1 : ~(0|A20U225Pad7|C50R);
// Gate A20-U109A
pullup(C35A);
assign (highz1,strong0) #0.2  C35A = rst ? 0 : ~(0|A20U107Pad2|CG11|A20U108Pad3);
// Gate A20-U257B
pullup(A20U257Pad9);
assign (highz1,strong0) #0.2  A20U257Pad9 = rst ? 0 : ~(0|A20U248Pad8|PIPZM);
// Gate A20-U209B A20-U210B
pullup(C52A);
assign (highz1,strong0) #0.2  C52A = rst ? 0 : ~(0|A20U209Pad7|A20U206Pad8|CG26|A20U208Pad8);
// Gate A20-U101A
pullup(C35M);
assign (highz1,strong0) #0.2  C35M = rst ? 0 : ~(0|A20U101Pad2|CA3_|CXB5_);
// Gate A20-U232B
pullup(A20U231Pad8);
assign (highz1,strong0) #0.2  A20U231Pad8 = rst ? 0 : ~(0|A20U231Pad9|C40R);
// Gate A20-U227A
pullup(A20U226Pad2);
assign (highz1,strong0) #0.2  A20U226Pad2 = rst ? 0 : ~(0|A20U227Pad2|A20U213Pad3);
// Gate A20-U130B
pullup(A20U129Pad7);
assign (highz1,strong0) #0.2  A20U129Pad7 = rst ? 0 : ~(0|A20U128Pad8|C27R);
// Gate A20-U260A
pullup(CA6_);
assign (highz1,strong0) #0.2  CA6_ = rst ? 1 : ~(0|OCTAD6);
// Gate A20-U108A
pullup(A20U107Pad4);
assign (highz1,strong0) #0.2  A20U107Pad4 = rst ? 0 : ~(0|C35R|A20U108Pad3);
// Gate A20-U140A
pullup(A20U140Pad1);
assign (highz1,strong0) #0.2  A20U140Pad1 = rst ? 0 : ~(0|A20U133Pad2|A20U138Pad2);
// Gate A20-U124A
pullup(A20U107Pad2);
assign (highz1,strong0) #0.2  A20U107Pad2 = rst ? 1 : ~(0|A20U124Pad2|C34R);
// Gate A20-U134B
pullup(A20U134Pad9);
assign (highz1,strong0) #0.2  A20U134Pad9 = rst ? 0 : ~(0|A20U133Pad9|A20U133Pad2);
// Gate A20-U103B A20-U102B
pullup(CXB2_);
assign (highz1,strong0) #0.2  CXB2_ = rst ? 1 : ~(0|XB2);
// Gate A20-U238B
pullup(A20U233Pad7);
assign (highz1,strong0) #0.2  A20U233Pad7 = rst ? 0 : ~(0|A20U238Pad7|C40R);
// Gate A20-U136A
pullup(A20U134Pad2);
assign (highz1,strong0) #0.2  A20U134Pad2 = rst ? 1 : ~(0|C24R|A20U134Pad1);
// Gate A20-U134A
pullup(A20U134Pad1);
assign (highz1,strong0) #0.2  A20U134Pad1 = rst ? 0 : ~(0|A20U134Pad2|A20U133Pad1);
// Gate A20-U260B
pullup(C41R);
assign (highz1,strong0) #0.2  C41R = rst ? 0 : ~(0|CXB1_|CA4_|A20U237Pad4);
// Gate A20-U251A A20-U252A
pullup(C55A);
assign (highz1,strong0) #0.2  C55A = rst ? 0 : ~(0|CG24|A20U234Pad2|A20U241Pad2|A20U249Pad1);
// Gate A20-U123A
pullup(A20U122Pad3);
assign (highz1,strong0) #0.2  A20U122Pad3 = rst ? 0 : ~(0|C34R|A20U121Pad4);
// Gate A20-U142A
pullup(C25A);
assign (highz1,strong0) #0.2  C25A = rst ? 0 : ~(0|A20U141Pad1|A20U134Pad2);
// Gate A20-U106A
pullup(A20J2Pad269);
assign (highz1,strong0) #0.2  A20J2Pad269 = rst ? 1 : ~(0);
// Gate A20-U112B
pullup(A20U109Pad7);
assign (highz1,strong0) #0.2  A20U109Pad7 = rst ? 1 : ~(0|A20U106Pad7|A20U112Pad8);
// Gate A20-U236A
pullup(A20U234Pad2);
assign (highz1,strong0) #0.2  A20U234Pad2 = rst ? 0 : ~(0|C53R|A20U234Pad1);
// Gate A20-U247A
pullup(C55R);
assign (highz1,strong0) #0.2  C55R = rst ? 0 : ~(0|CA5_|CXB5_|A20U237Pad4);
// Gate A20-U252B
pullup(C41A);
assign (highz1,strong0) #0.2  C41A = rst ? 0 : ~(0|CG14|A20U250Pad9|A20U235Pad8);
// Gate A20-U144B
pullup(C25R);
assign (highz1,strong0) #0.2  C25R = rst ? 0 : ~(0|CXB5_|A20U137Pad4|CA2_);
// Gate A20-U258A A20-U259A
pullup(CXB4_);
assign (highz1,strong0) #0.2  CXB4_ = rst ? 1 : ~(0|XB4);
// Gate A20-U255B
pullup(A20J4Pad467);
assign (highz1,strong0) #0.2  A20J4Pad467 = rst ? 1 : ~(0);
// Gate A20-U119B
pullup(C30A);
assign (highz1,strong0) #0.2  C30A = rst ? 0 : ~(0|A20U118Pad7|CG21|A20U108Pad8);
// Gate A20-U249B
pullup(C41P);
assign (highz1,strong0) #0.2  C41P = rst ? 0 : ~(0|CXB1_|A20U245Pad9|CA4_);
// Gate A20-U222A
pullup(A20U221Pad4);
assign (highz1,strong0) #0.2  A20U221Pad4 = rst ? 0 : ~(0|SHAFTM|A20U222Pad3);
// Gate A20-U259B
pullup(C41M);
assign (highz1,strong0) #0.2  C41M = rst ? 0 : ~(0|A20U257Pad9|CA4_|CXB1_);
// Gate A20-U234B
pullup(A20U234Pad9);
assign (highz1,strong0) #0.2  A20U234Pad9 = rst ? 0 : ~(0|A20U233Pad9|A20U233Pad2);
// Gate A20-U244A
pullup(A20U237Pad4);
assign (highz1,strong0) #0.2  A20U237Pad4 = rst ? 1 : ~(0|RSSB);
// Gate A20-U101B A20-U160A
pullup(CXB7_);
assign (highz1,strong0) #0.2  CXB7_ = rst ? 1 : ~(0|XB7);
// Gate A20-U245B
pullup(A20U245Pad9);
assign (highz1,strong0) #0.2  A20U245Pad9 = rst ? 0 : ~(0|A20U245Pad7|PIPZP);
// Gate A20-U205B A20-U204B A20-U256A A20-U257A
pullup(CA4_);
assign (highz1,strong0) #0.2  CA4_ = rst ? 1 : ~(0|OCTAD4);
// Gate A20-U160B
pullup(C33R);
assign (highz1,strong0) #0.2  C33R = rst ? 0 : ~(0|CXB3_|CA3_|A20U137Pad4);
// Gate A20-U131B
pullup(A20U131Pad9);
assign (highz1,strong0) #0.2  A20U131Pad9 = rst ? 0 : ~(0|CDUXP|A20U131Pad8);
// Gate A20-U149B
pullup(C33P);
assign (highz1,strong0) #0.2  C33P = rst ? 0 : ~(0|CXB3_|A20U145Pad9|CA3_);
// Gate A20-U206A
pullup(A20J3Pad303);
assign (highz1,strong0) #0.2  A20J3Pad303 = rst ? 1 : ~(0);
// Gate A20-U242A
pullup(C54A);
assign (highz1,strong0) #0.2  C54A = rst ? 0 : ~(0|A20U241Pad1|CG24|A20U234Pad2);
// Gate A20-U214A
pullup(A20U213Pad2);
assign (highz1,strong0) #0.2  A20U213Pad2 = rst ? 0 : ~(0|A20U214Pad2|A20U203Pad1);
// Gate A20-U207A
pullup(A20U205Pad2);
assign (highz1,strong0) #0.2  A20U205Pad2 = rst ? 0 : ~(0|A20U207Pad2|CG12|A20U207Pad4);
// Gate A20-U132A
pullup(A20U131Pad3);
assign (highz1,strong0) #0.2  A20U131Pad3 = rst ? 1 : ~(0|A20U131Pad1|T2P);
// Gate A20-U131A
pullup(A20U131Pad1);
assign (highz1,strong0) #0.2  A20U131Pad1 = rst ? 0 : ~(0|C24R|A20U131Pad3);
// Gate A20-U253B
pullup(A20U250Pad8);
assign (highz1,strong0) #0.2  A20U250Pad8 = rst ? 1 : ~(0|A20U250Pad9|C41R);
// Gate A20-U115B
pullup(A20U113Pad7);
assign (highz1,strong0) #0.2  A20U113Pad7 = rst ? 1 : ~(0|A20U115Pad7|T6P);
// Gate A20-U152B
pullup(C33A);
assign (highz1,strong0) #0.2  C33A = rst ? 0 : ~(0|CG22|A20U150Pad9|A20U135Pad8);
// Gate A20-U117A
pullup(A20U113Pad3);
assign (highz1,strong0) #0.2  A20U113Pad3 = rst ? 1 : ~(0|BKTF_);
// Gate A20-U114A
pullup(A20U113Pad2);
assign (highz1,strong0) #0.2  A20U113Pad2 = rst ? 1 : ~(0|A20U114Pad2|A20U103Pad1);
// Gate A20-U244B
pullup(C54R);
assign (highz1,strong0) #0.2  C54R = rst ? 0 : ~(0|CXB4_|A20U237Pad4|CA5_);
// Gate A20-U149A
pullup(A20U149Pad1);
assign (highz1,strong0) #0.2  A20U149Pad1 = rst ? 0 : ~(0|A20U149Pad2|A20U148Pad1);
// Gate A20-U159B
pullup(C33M);
assign (highz1,strong0) #0.2  C33M = rst ? 0 : ~(0|A20U157Pad9|CA3_|CXB3_);
// Gate A20-U103A
pullup(A20U103Pad1);
assign (highz1,strong0) #0.2  A20U103Pad1 = rst ? 0 : ~(0|C35R|A20U101Pad2);
// Gate A20-U118B
pullup(A20U106Pad8);
assign (highz1,strong0) #0.2  A20U106Pad8 = rst ? 1 : ~(0|A20U118Pad7|C30R);
// Gate A20-U111B
pullup(A20U106Pad7);
assign (highz1,strong0) #0.2  A20U106Pad7 = rst ? 0 : ~(0|A20U109Pad7|C31R);
// Gate A20-U144A
pullup(A20U137Pad4);
assign (highz1,strong0) #0.2  A20U137Pad4 = rst ? 1 : ~(0|RSSB);
// Gate A20-U135B
pullup(A20U135Pad9);
assign (highz1,strong0) #0.2  A20U135Pad9 = rst ? 0 : ~(0|A20U134Pad9|A20U135Pad8);
// Gate A20-U137B
pullup(A20U135Pad8);
assign (highz1,strong0) #0.2  A20U135Pad8 = rst ? 1 : ~(0|A20U135Pad9|C32R);
// Gate A20-U239B
pullup(A20U238Pad7);
assign (highz1,strong0) #0.2  A20U238Pad7 = rst ? 1 : ~(0|A20U233Pad7|PIPYM);
// Gate A20-U238A
pullup(A20U238Pad1);
assign (highz1,strong0) #0.2  A20U238Pad1 = rst ? 0 : ~(0|A20U238Pad2|C54R);
// Gate A20-U239A
pullup(A20U238Pad2);
assign (highz1,strong0) #0.2  A20U238Pad2 = rst ? 1 : ~(0|A20U238Pad1|SHAFTD);

endmodule
