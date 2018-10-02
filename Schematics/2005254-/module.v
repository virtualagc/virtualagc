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

assign #0.2  U121Pad4 = rst ? 0 : ~(0|CDUZM|U122Pad3);
assign #0.2  C36M = rst ? 0 : ~(0|CXB6_|CA3_|U221Pad4);
assign #0.2  U121Pad7 = rst ? 0 : ~(0|U122Pad7|T5P);
assign #0.2  C27R = rst ? 0 : ~(0|U102Pad2|CXB7_|CA2_);
assign #0.2  C52A = rst ? 0 : ~(0|U209Pad7|U206Pad8|CG26|U208Pad8);
assign #0.2  U229Pad7 = rst ? 0 : ~(0|U228Pad8|C50R);
assign #0.2  C32R = rst ? 0 : ~(0|U137Pad4|CXB2_|CA3_);
assign #0.2  C53R = rst ? 0 : ~(0|CXB3_|CA5_|U237Pad4);
assign #0.2  U247Pad7 = rst ? 0 : ~(0|U245Pad7|U248Pad8);
assign #0.2  U140Pad1 = rst ? 0 : ~(0|U133Pad2|U138Pad2);
assign #0.2  C27A = rst ? 0 : ~(0|U125Pad7|CG21);
assign #0.2  C36P = rst ? 0 : ~(0|CXB6_|CA3_|U219Pad4);
assign #0.2  U219Pad4 = rst ? 0 : ~(0|SHAFTP|U228Pad2);
assign #0.2  C36R = rst ? 0 : ~(0|CXB6_|CA3_|U202Pad2);
assign #0.2  U111Pad2 = rst ? 0 : ~(0|U113Pad2|U113Pad3);
assign #0.2  U206Pad7 = rst ? 0 : ~(0|U209Pad7|C52R);
assign #0.2  U212Pad8 = rst ? 0 : ~(0|U213Pad7|U213Pad3);
assign #0.2  C40M = rst ? 0 : ~(0|U238Pad7|CA4_|CXB0_);
assign #0.2  U129Pad7 = rst ? 0 : ~(0|U128Pad8|C27R);
assign #0.2  U212Pad3 = rst ? 0 : ~(0|PIPXP|U214Pad2);
assign #0.2  U108Pad8 = rst ? 0 : ~(0|U125Pad7|C27R);
assign #0.2  U241Pad2 = rst ? 0 : ~(0|C54R|U241Pad1);
assign #0.2  U108Pad3 = rst ? 0 : ~(0|U111Pad2|U107Pad4);
assign #0.2  C54A = rst ? 0 : ~(0|U241Pad1|CG24|U234Pad2);
assign #0.2  CG21 = rst ? 0 : ~(0|J1Pad115);
assign #0.2  CG22 = rst ? 0 : ~(0|J2Pad258);
assign #0.2  CG23 = rst ? 0 : ~(0|J4Pad457);
assign #0.2  C40P = rst ? 0 : ~(0|U231Pad9|CA4_|CXB0_);
assign #0.2  U133Pad7 = rst ? 0 : ~(0|U138Pad7|C32R);
assign #0.2  C40R = rst ? 0 : ~(0|U237Pad4|CXB0_|CA4_);
assign #0.2  U133Pad1 = rst ? 0 : ~(0|U133Pad2|U131Pad3);
assign #0.2  CG24 = rst ? 0 : ~(0|J3Pad314);
assign #0.2  U133Pad2 = rst ? 0 : ~(0|BKTF_);
assign #0.2  U238Pad1 = rst ? 0 : ~(0|U238Pad2|C54R);
assign #0.2  C24A = rst ? 0 : ~(0|U134Pad1);
assign #0.2  C31R = rst ? 0 : ~(0|U102Pad2|CXB1_|CA3_);
assign #0.2  U133Pad9 = rst ? 0 : ~(0|U133Pad7|U131Pad8);
assign #0.2  U238Pad7 = rst ? 0 : ~(0|U233Pad7|PIPYM);
assign #0.2  C36A = rst ? 0 : ~(0|CG12|U224Pad2);
assign #0.2  C40A = rst ? 0 : ~(0|U235Pad9|CG14);
assign #0.2  U127Pad2 = rst ? 0 : ~(0|U128Pad2|U122Pad3);
assign #0.2  J2Pad269 = rst ? 0 : ~(0);
assign #0.2  C31A = rst ? 0 : ~(0|U109Pad7|U106Pad8|CG21|U108Pad8);
assign #0.2  C24R = rst ? 0 : ~(0|CXB4_|CA2_|U137Pad4);
assign #0.2  U235Pad8 = rst ? 0 : ~(0|U235Pad9|C40R);
assign #0.2  U235Pad9 = rst ? 0 : ~(0|U234Pad9|U235Pad8);
assign #0.2  CA2_ = rst ? 0 : ~(0|OCTAD2);
assign #0.2  U221Pad7 = rst ? 0 : ~(0|U222Pad7|CDUYD);
assign #0.2  U109Pad7 = rst ? 0 : ~(0|U106Pad7|U112Pad8);
assign #0.2  U221Pad4 = rst ? 0 : ~(0|SHAFTM|U222Pad3);
assign #0.2  U150Pad8 = rst ? 0 : ~(0|U150Pad9|C33R);
assign #0.2  U150Pad9 = rst ? 0 : ~(0|U147Pad9|U150Pad8);
assign #0.2  U224Pad2 = rst ? 0 : ~(0|U226Pad2|U207Pad2);
assign #0.2  U115Pad7 = rst ? 0 : ~(0|U113Pad7|C31R);
assign #0.2  U102Pad2 = rst ? 0 : ~(0|RSSB);
assign #0.2  U257Pad9 = rst ? 0 : ~(0|U248Pad8|PIPZM);
assign #0.2  CXB3_ = rst ? 0 : ~(0|XB3);
assign #0.2  U107Pad4 = rst ? 0 : ~(0|C35R|U108Pad3);
assign #0.2  U222Pad3 = rst ? 0 : ~(0|C36R|U221Pad4);
assign #0.2  U226Pad2 = rst ? 0 : ~(0|U227Pad2|U213Pad3);
assign #0.2  U107Pad2 = rst ? 0 : ~(0|U124Pad2|C34R);
assign #0.2  C34M = rst ? 0 : ~(0|CXB4_|CA3_|U121Pad4);
assign #0.2  J4Pad467 = rst ? 0 : ~(0);
assign #0.2  C34A = rst ? 0 : ~(0|CG11|U124Pad2);
assign #0.2  U120Pad8 = rst ? 0 : ~(0|U121Pad7|U113Pad3);
assign #0.2  U126Pad2 = rst ? 0 : ~(0|U127Pad2|U113Pad3);
assign #0.2  U231Pad3 = rst ? 0 : ~(0|U231Pad1|TRUND);
assign #0.2  U112Pad3 = rst ? 0 : ~(0|TRNP|U114Pad2);
assign #0.2  C34R = rst ? 0 : ~(0|CXB4_|CA3_|U102Pad2);
assign #0.2  C51R = rst ? 0 : ~(0|U202Pad2|CA5_|CXB1_);
assign #0.2  C34P = rst ? 0 : ~(0|CXB4_|CA3_|U119Pad4);
assign #0.2  U112Pad8 = rst ? 0 : ~(0|U113Pad7|U113Pad3);
assign #0.2  CA4_ = rst ? 0 : ~(0|OCTAD4);
assign #0.2  U131Pad3 = rst ? 0 : ~(0|U131Pad1|T2P);
assign #0.2  U131Pad1 = rst ? 0 : ~(0|C24R|U131Pad3);
assign #0.2  U237Pad4 = rst ? 0 : ~(0|RSSB);
assign #0.2  CA6_ = rst ? 0 : ~(0|OCTAD6);
assign #0.2  U131Pad9 = rst ? 0 : ~(0|CDUXP|U131Pad8);
assign #0.2  U131Pad8 = rst ? 0 : ~(0|U131Pad9|C32R);
assign #0.2  U119Pad4 = rst ? 0 : ~(0|CDUZP|U128Pad2);
assign #0.2  U127Pad8 = rst ? 0 : ~(0|U113Pad3|U128Pad8);
assign #0.2  U118Pad7 = rst ? 0 : ~(0|U106Pad8|U120Pad8);
assign #0.2  J1Pad115 = rst ? 0 : ~(0|U141Pad2|U149Pad2|U134Pad2);
assign #0.2  U231Pad9 = rst ? 0 : ~(0|PIPYP|U231Pad8);
assign #0.2  U113Pad7 = rst ? 0 : ~(0|U115Pad7|T6P);
assign #0.2  U203Pad1 = rst ? 0 : ~(0|C37R|U201Pad2);
assign #0.2  CG14 = rst ? 0 : ~(0|U205Pad2);
assign #0.2  U113Pad3 = rst ? 0 : ~(0|BKTF_);
assign #0.2  U113Pad2 = rst ? 0 : ~(0|U114Pad2|U103Pad1);
assign #0.2  U231Pad1 = rst ? 0 : ~(0|C53R|U231Pad3);
assign #0.2  C37M = rst ? 0 : ~(0|U201Pad2|CA3_|CXB7_);
assign #0.2  C26R = rst ? 0 : ~(0|CA2_|CXB6_|U137Pad4);
assign #0.2  U233Pad7 = rst ? 0 : ~(0|U238Pad7|C40R);
assign #0.2  U231Pad8 = rst ? 0 : ~(0|U231Pad9|C40R);
assign #0.2  C50A = rst ? 0 : ~(0|U225Pad7|CG26);
assign #0.2  U215Pad7 = rst ? 0 : ~(0|U213Pad7|C52R);
assign #0.2  C37A = rst ? 0 : ~(0|U207Pad2|CG12|U208Pad3);
assign #0.2  C26A = rst ? 0 : ~(0|U134Pad2|U141Pad2|U149Pad1);
assign #0.2  U149Pad2 = rst ? 0 : ~(0|C26R|U149Pad1);
assign #0.2  U149Pad1 = rst ? 0 : ~(0|U149Pad2|U148Pad1);
assign #0.2  CA3_ = rst ? 0 : ~(0|OCTAD3);
assign #0.2  C37R = rst ? 0 : ~(0|U202Pad2|CA3_|CXB7_);
assign #0.2  U157Pad9 = rst ? 0 : ~(0|U148Pad8|CDUYM);
assign #0.2  C37P = rst ? 0 : ~(0|CXB7_|U212Pad3|CA3_);
assign #0.2  U202Pad2 = rst ? 0 : ~(0|RSSB);
assign #0.2  U138Pad7 = rst ? 0 : ~(0|U133Pad7|CDUXM);
assign #0.2  U138Pad2 = rst ? 0 : ~(0|U138Pad1|T1P);
assign #0.2  U128Pad8 = rst ? 0 : ~(0|U129Pad7|T4P);
assign #0.2  CG13 = rst ? 0 : ~(0|U254Pad9);
assign #0.2  U138Pad1 = rst ? 0 : ~(0|U138Pad2|C25R);
assign #0.2  U114Pad2 = rst ? 0 : ~(0|U112Pad3|C35R);
assign #0.2  U254Pad9 = rst ? 0 : ~(0|U250Pad8|CG14|U235Pad8);
assign #0.2  U128Pad2 = rst ? 0 : ~(0|U119Pad4|C34R);
assign #0.2  J1Pad105 = rst ? 0 : ~(0);
assign #0.2  J1Pad104 = rst ? 0 : ~(0);
assign #0.2  C50R = rst ? 0 : ~(0|U202Pad2|CXB0_|CA5_);
assign #0.2  U241Pad1 = rst ? 0 : ~(0|U241Pad2|U240Pad1);
assign #0.2  U148Pad1 = rst ? 0 : ~(0|U133Pad2|U145Pad2);
assign #0.2  C32P = rst ? 0 : ~(0|U131Pad9|CA3_|CXB2_);
assign #0.2  U106Pad7 = rst ? 0 : ~(0|U109Pad7|C31R);
assign #0.2  U233Pad9 = rst ? 0 : ~(0|U233Pad7|U231Pad8);
assign #0.2  U233Pad2 = rst ? 0 : ~(0|BKTF_);
assign #0.2  U233Pad1 = rst ? 0 : ~(0|U233Pad2|U231Pad3);
assign #0.2  U141Pad2 = rst ? 0 : ~(0|C25R|U141Pad1);
assign #0.2  U106Pad8 = rst ? 0 : ~(0|U118Pad7|C30R);
assign #0.2  U141Pad1 = rst ? 0 : ~(0|U141Pad2|U140Pad1);
assign #0.2  C53A = rst ? 0 : ~(0|CG24|U234Pad1);
assign #0.2  C32A = rst ? 0 : ~(0|U135Pad9|CG22);
assign #0.2  U206Pad8 = rst ? 0 : ~(0|U218Pad7|C51R);
assign #0.2  C32M = rst ? 0 : ~(0|U138Pad7|CA3_|CXB2_);
assign #0.2  U218Pad7 = rst ? 0 : ~(0|U206Pad8|U220Pad8);
assign #0.2  U238Pad2 = rst ? 0 : ~(0|U238Pad1|SHAFTD);
assign #0.2  C41P = rst ? 0 : ~(0|CXB1_|U245Pad9|CA4_);
assign #0.2  U222Pad7 = rst ? 0 : ~(0|U221Pad7|C51R);
assign #0.2  U208Pad3 = rst ? 0 : ~(0|U211Pad2|U207Pad4);
assign #0.2  U248Pad8 = rst ? 0 : ~(0|U257Pad9|C41R);
assign #0.2  U125Pad7 = rst ? 0 : ~(0|U108Pad8|U127Pad8);
assign #0.2  U101Pad2 = rst ? 0 : ~(0|TRNM|U103Pad1);
assign #0.2  U213Pad7 = rst ? 0 : ~(0|U215Pad7|CDUZD);
assign #0.2  U201Pad2 = rst ? 0 : ~(0|PIPXM|U203Pad1);
assign #0.2  C51A = rst ? 0 : ~(0|U218Pad7|CG26|U208Pad8);
assign #0.2  U245Pad1 = rst ? 0 : ~(0|U245Pad2|C55R);
assign #0.2  U207Pad4 = rst ? 0 : ~(0|C37R|U208Pad3);
assign #0.2  C52R = rst ? 0 : ~(0|U202Pad2|CXB2_|CA5_);
assign #0.2  C35P = rst ? 0 : ~(0|CXB5_|U112Pad3|CA3_);
assign #0.2  U245Pad7 = rst ? 0 : ~(0|U245Pad9|C41R);
assign #0.2  C35R = rst ? 0 : ~(0|U102Pad2|CA3_|CXB5_);
assign #0.2  U245Pad9 = rst ? 0 : ~(0|U245Pad7|PIPZP);
assign #0.2  U207Pad2 = rst ? 0 : ~(0|U224Pad2|C36R);
assign #0.2  U208Pad8 = rst ? 0 : ~(0|U225Pad7|C50R);
assign #0.2  C35A = rst ? 0 : ~(0|U107Pad2|CG11|U108Pad3);
assign #0.2  U227Pad2 = rst ? 0 : ~(0|U228Pad2|U222Pad3);
assign #0.2  C35M = rst ? 0 : ~(0|U101Pad2|CA3_|CXB5_);
assign #0.2  CG11 = rst ? 0 : ~(0|U154Pad9);
assign #0.2  U135Pad9 = rst ? 0 : ~(0|U134Pad9|U135Pad8);
assign #0.2  U135Pad8 = rst ? 0 : ~(0|U135Pad9|C32R);
assign #0.2  U227Pad8 = rst ? 0 : ~(0|U213Pad3|U228Pad8);
assign #0.2  U250Pad9 = rst ? 0 : ~(0|U247Pad9|U250Pad8);
assign #0.2  U211Pad2 = rst ? 0 : ~(0|U213Pad2|U213Pad3);
assign #0.2  U234Pad9 = rst ? 0 : ~(0|U233Pad9|U233Pad2);
assign #0.2  CG12 = rst ? 0 : ~(0|U105Pad2);
assign #0.2  J3Pad314 = rst ? 0 : ~(0|CG26|U208Pad8|U206Pad7|U206Pad8);
assign #0.2  U213Pad2 = rst ? 0 : ~(0|U214Pad2|U203Pad1);
assign #0.2  U213Pad3 = rst ? 0 : ~(0|BKTF_);
assign #0.2  U134Pad9 = rst ? 0 : ~(0|U133Pad9|U133Pad2);
assign #0.2  U134Pad2 = rst ? 0 : ~(0|C24R|U134Pad1);
assign #0.2  CXB2_ = rst ? 0 : ~(0|XB2);
assign #0.2  U134Pad1 = rst ? 0 : ~(0|U134Pad2|U133Pad1);
assign #0.2  U154Pad9 = rst ? 0 : ~(0|U150Pad8|CG22|U135Pad8);
assign #0.2  C55R = rst ? 0 : ~(0|CA5_|CXB5_|U237Pad4);
assign #0.2  C41R = rst ? 0 : ~(0|CXB1_|CA4_|U237Pad4);
assign #0.2  C55A = rst ? 0 : ~(0|CG24|U234Pad2|U241Pad2|U249Pad1);
assign #0.2  C25A = rst ? 0 : ~(0|U141Pad1|U134Pad2);
assign #0.2  C41A = rst ? 0 : ~(0|CG14|U250Pad9|U235Pad8);
assign #0.2  C30R = rst ? 0 : ~(0|U102Pad2|CA3_|CXB0_);
assign #0.2  U245Pad2 = rst ? 0 : ~(0|U245Pad1|THRSTD);
assign #0.2  U234Pad1 = rst ? 0 : ~(0|U234Pad2|U233Pad1);
assign #0.2  U240Pad1 = rst ? 0 : ~(0|U233Pad2|U238Pad2);
assign #0.2  U234Pad2 = rst ? 0 : ~(0|C53R|U234Pad1);
assign #0.2  C25R = rst ? 0 : ~(0|CXB5_|U137Pad4|CA2_);
assign #0.2  CXB4_ = rst ? 0 : ~(0|XB4);
assign #0.2  U105Pad2 = rst ? 0 : ~(0|U107Pad2|CG11|U107Pad4);
assign #0.2  C30A = rst ? 0 : ~(0|U118Pad7|CG21|U108Pad8);
assign #0.2  U225Pad7 = rst ? 0 : ~(0|U208Pad8|U227Pad8);
assign #0.2  C41M = rst ? 0 : ~(0|U257Pad9|CA4_|CXB1_);
assign #0.2  U248Pad1 = rst ? 0 : ~(0|U233Pad2|U245Pad2);
assign #0.2  U147Pad7 = rst ? 0 : ~(0|U145Pad7|U148Pad8);
assign #0.2  J3Pad303 = rst ? 0 : ~(0);
assign #0.2  U147Pad9 = rst ? 0 : ~(0|U147Pad7|U133Pad2);
assign #0.2  J2Pad258 = rst ? 0 : ~(0|CG21|U108Pad8|U106Pad7|U106Pad8);
assign #0.2  U103Pad1 = rst ? 0 : ~(0|C35R|U101Pad2);
assign #0.2  U137Pad4 = rst ? 0 : ~(0|RSSB);
assign #0.2  CXB7_ = rst ? 0 : ~(0|XB7);
assign #0.2  U249Pad1 = rst ? 0 : ~(0|U249Pad2|U248Pad1);
assign #0.2  U249Pad2 = rst ? 0 : ~(0|C55R|U249Pad1);
assign #0.2  C33R = rst ? 0 : ~(0|CXB3_|CA3_|U137Pad4);
assign #0.2  U220Pad8 = rst ? 0 : ~(0|U221Pad7|U213Pad3);
assign #0.2  C33P = rst ? 0 : ~(0|CXB3_|U145Pad9|CA3_);
assign #0.2  U209Pad7 = rst ? 0 : ~(0|U206Pad7|U212Pad8);
assign #0.2  U250Pad8 = rst ? 0 : ~(0|U250Pad9|C41R);
assign #0.2  U148Pad8 = rst ? 0 : ~(0|U157Pad9|C33R);
assign #0.2  C33A = rst ? 0 : ~(0|CG22|U150Pad9|U135Pad8);
assign #0.2  J4Pad457 = rst ? 0 : ~(0|U241Pad2|U249Pad2|CG24|U234Pad2);
assign #0.2  C54R = rst ? 0 : ~(0|CXB4_|U237Pad4|CA5_);
assign #0.2  C33M = rst ? 0 : ~(0|U157Pad9|CA3_|CXB3_);
assign #0.2  U122Pad7 = rst ? 0 : ~(0|U121Pad7|C30R);
assign #0.2  U145Pad9 = rst ? 0 : ~(0|U145Pad7|CDUYP);
assign #0.2  U122Pad3 = rst ? 0 : ~(0|C34R|U121Pad4);
assign #0.2  U145Pad2 = rst ? 0 : ~(0|T3P|U145Pad1);
assign #0.2  U247Pad9 = rst ? 0 : ~(0|U247Pad7|U233Pad2);
assign #0.2  U145Pad1 = rst ? 0 : ~(0|U145Pad2|C26R);
assign #0.2  U145Pad7 = rst ? 0 : ~(0|U145Pad9|C33R);
assign #0.2  U205Pad2 = rst ? 0 : ~(0|U207Pad2|CG12|U207Pad4);
assign #0.2  U228Pad2 = rst ? 0 : ~(0|U219Pad4|C36R);
assign #0.2  U124Pad2 = rst ? 0 : ~(0|U126Pad2|U107Pad2);
assign #0.2  U214Pad2 = rst ? 0 : ~(0|U212Pad3|C37R);
assign #0.2  U228Pad8 = rst ? 0 : ~(0|U229Pad7|CDUXD);

endmodule
