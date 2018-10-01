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

assign U121Pad4 = rst ? 0 : ~(0|CDUZM|U122Pad3);
assign C36M = rst ? 0 : ~(0|CXB6_|CA3_|U221Pad4);
assign U121Pad7 = rst ? 0 : ~(0|U122Pad7|T5P);
assign C27R = rst ? 0 : ~(0|U102Pad2|CXB7_|CA2_);
assign C52A = rst ? 0 : ~(0|U209Pad7|U206Pad8|CG26|U208Pad8);
assign U229Pad7 = rst ? 0 : ~(0|U228Pad8|C50R);
assign C32R = rst ? 0 : ~(0|U137Pad4|CXB2_|CA3_);
assign C53R = rst ? 0 : ~(0|CXB3_|CA5_|U237Pad4);
assign U247Pad7 = rst ? 0 : ~(0|U245Pad7|U248Pad8);
assign U140Pad1 = rst ? 0 : ~(0|U133Pad2|U138Pad2);
assign C27A = rst ? 0 : ~(0|U125Pad7|CG21);
assign C36P = rst ? 0 : ~(0|CXB6_|CA3_|U219Pad4);
assign U219Pad4 = rst ? 0 : ~(0|SHAFTP|U228Pad2);
assign C36R = rst ? 0 : ~(0|CXB6_|CA3_|U202Pad2);
assign U111Pad2 = rst ? 0 : ~(0|U113Pad2|U113Pad3);
assign U206Pad7 = rst ? 0 : ~(0|U209Pad7|C52R);
assign U212Pad8 = rst ? 0 : ~(0|U213Pad7|U213Pad3);
assign C40M = rst ? 0 : ~(0|U238Pad7|CA4_|CXB0_);
assign U129Pad7 = rst ? 0 : ~(0|U128Pad8|C27R);
assign U212Pad3 = rst ? 0 : ~(0|PIPXP|U214Pad2);
assign U108Pad8 = rst ? 0 : ~(0|U125Pad7|C27R);
assign U241Pad2 = rst ? 0 : ~(0|C54R|U241Pad1);
assign U108Pad3 = rst ? 0 : ~(0|U111Pad2|U107Pad4);
assign C54A = rst ? 0 : ~(0|U241Pad1|CG24|U234Pad2);
assign CG21 = rst ? 0 : ~(0|J1Pad115);
assign CG22 = rst ? 0 : ~(0|J2Pad258);
assign CG23 = rst ? 0 : ~(0|J4Pad457);
assign C40P = rst ? 0 : ~(0|U231Pad9|CA4_|CXB0_);
assign U133Pad7 = rst ? 0 : ~(0|U138Pad7|C32R);
assign C40R = rst ? 0 : ~(0|U237Pad4|CXB0_|CA4_);
assign U133Pad1 = rst ? 0 : ~(0|U133Pad2|U131Pad3);
assign CG24 = rst ? 0 : ~(0|J3Pad314);
assign U133Pad2 = rst ? 0 : ~(0|BKTF_);
assign U238Pad1 = rst ? 0 : ~(0|U238Pad2|C54R);
assign C24A = rst ? 0 : ~(0|U134Pad1);
assign C31R = rst ? 0 : ~(0|U102Pad2|CXB1_|CA3_);
assign U133Pad9 = rst ? 0 : ~(0|U133Pad7|U131Pad8);
assign U238Pad7 = rst ? 0 : ~(0|U233Pad7|PIPYM);
assign C36A = rst ? 0 : ~(0|CG12|U224Pad2);
assign C40A = rst ? 0 : ~(0|U235Pad9|CG14);
assign U127Pad2 = rst ? 0 : ~(0|U128Pad2|U122Pad3);
assign J2Pad269 = rst ? 0 : ~(0);
assign C31A = rst ? 0 : ~(0|U109Pad7|U106Pad8|CG21|U108Pad8);
assign C24R = rst ? 0 : ~(0|CXB4_|CA2_|U137Pad4);
assign U235Pad8 = rst ? 0 : ~(0|U235Pad9|C40R);
assign U235Pad9 = rst ? 0 : ~(0|U234Pad9|U235Pad8);
assign CA2_ = rst ? 0 : ~(0|OCTAD2);
assign U221Pad7 = rst ? 0 : ~(0|U222Pad7|CDUYD);
assign U109Pad7 = rst ? 0 : ~(0|U106Pad7|U112Pad8);
assign U221Pad4 = rst ? 0 : ~(0|SHAFTM|U222Pad3);
assign U150Pad8 = rst ? 0 : ~(0|U150Pad9|C33R);
assign U150Pad9 = rst ? 0 : ~(0|U147Pad9|U150Pad8);
assign U224Pad2 = rst ? 0 : ~(0|U226Pad2|U207Pad2);
assign U115Pad7 = rst ? 0 : ~(0|U113Pad7|C31R);
assign U102Pad2 = rst ? 0 : ~(0|RSSB);
assign U257Pad9 = rst ? 0 : ~(0|U248Pad8|PIPZM);
assign CXB3_ = rst ? 0 : ~(0|XB3);
assign U107Pad4 = rst ? 0 : ~(0|C35R|U108Pad3);
assign U222Pad3 = rst ? 0 : ~(0|C36R|U221Pad4);
assign U226Pad2 = rst ? 0 : ~(0|U227Pad2|U213Pad3);
assign U107Pad2 = rst ? 0 : ~(0|U124Pad2|C34R);
assign C34M = rst ? 0 : ~(0|CXB4_|CA3_|U121Pad4);
assign J4Pad467 = rst ? 0 : ~(0);
assign C34A = rst ? 0 : ~(0|CG11|U124Pad2);
assign U120Pad8 = rst ? 0 : ~(0|U121Pad7|U113Pad3);
assign U126Pad2 = rst ? 0 : ~(0|U127Pad2|U113Pad3);
assign U231Pad3 = rst ? 0 : ~(0|U231Pad1|TRUND);
assign U112Pad3 = rst ? 0 : ~(0|TRNP|U114Pad2);
assign C34R = rst ? 0 : ~(0|CXB4_|CA3_|U102Pad2);
assign C51R = rst ? 0 : ~(0|U202Pad2|CA5_|CXB1_);
assign C34P = rst ? 0 : ~(0|CXB4_|CA3_|U119Pad4);
assign U112Pad8 = rst ? 0 : ~(0|U113Pad7|U113Pad3);
assign CA4_ = rst ? 0 : ~(0|OCTAD4);
assign U131Pad3 = rst ? 0 : ~(0|U131Pad1|T2P);
assign U131Pad1 = rst ? 0 : ~(0|C24R|U131Pad3);
assign U237Pad4 = rst ? 0 : ~(0|RSSB);
assign CA6_ = rst ? 0 : ~(0|OCTAD6);
assign U131Pad9 = rst ? 0 : ~(0|CDUXP|U131Pad8);
assign U131Pad8 = rst ? 0 : ~(0|U131Pad9|C32R);
assign U119Pad4 = rst ? 0 : ~(0|CDUZP|U128Pad2);
assign U127Pad8 = rst ? 0 : ~(0|U113Pad3|U128Pad8);
assign U118Pad7 = rst ? 0 : ~(0|U106Pad8|U120Pad8);
assign J1Pad115 = rst ? 0 : ~(0|U141Pad2|U149Pad2|U134Pad2);
assign U231Pad9 = rst ? 0 : ~(0|PIPYP|U231Pad8);
assign U113Pad7 = rst ? 0 : ~(0|U115Pad7|T6P);
assign U203Pad1 = rst ? 0 : ~(0|C37R|U201Pad2);
assign CG14 = rst ? 0 : ~(0|U205Pad2);
assign U113Pad3 = rst ? 0 : ~(0|BKTF_);
assign U113Pad2 = rst ? 0 : ~(0|U114Pad2|U103Pad1);
assign U231Pad1 = rst ? 0 : ~(0|C53R|U231Pad3);
assign C37M = rst ? 0 : ~(0|U201Pad2|CA3_|CXB7_);
assign C26R = rst ? 0 : ~(0|CA2_|CXB6_|U137Pad4);
assign U233Pad7 = rst ? 0 : ~(0|U238Pad7|C40R);
assign U231Pad8 = rst ? 0 : ~(0|U231Pad9|C40R);
assign C50A = rst ? 0 : ~(0|U225Pad7|CG26);
assign U215Pad7 = rst ? 0 : ~(0|U213Pad7|C52R);
assign C37A = rst ? 0 : ~(0|U207Pad2|CG12|U208Pad3);
assign C26A = rst ? 0 : ~(0|U134Pad2|U141Pad2|U149Pad1);
assign U149Pad2 = rst ? 0 : ~(0|C26R|U149Pad1);
assign U149Pad1 = rst ? 0 : ~(0|U149Pad2|U148Pad1);
assign CA3_ = rst ? 0 : ~(0|OCTAD3);
assign C37R = rst ? 0 : ~(0|U202Pad2|CA3_|CXB7_);
assign U157Pad9 = rst ? 0 : ~(0|U148Pad8|CDUYM);
assign C37P = rst ? 0 : ~(0|CXB7_|U212Pad3|CA3_);
assign U202Pad2 = rst ? 0 : ~(0|RSSB);
assign U138Pad7 = rst ? 0 : ~(0|U133Pad7|CDUXM);
assign U138Pad2 = rst ? 0 : ~(0|U138Pad1|T1P);
assign U128Pad8 = rst ? 0 : ~(0|U129Pad7|T4P);
assign CG13 = rst ? 0 : ~(0|U254Pad9);
assign U138Pad1 = rst ? 0 : ~(0|U138Pad2|C25R);
assign U114Pad2 = rst ? 0 : ~(0|U112Pad3|C35R);
assign U254Pad9 = rst ? 0 : ~(0|U250Pad8|CG14|U235Pad8);
assign U128Pad2 = rst ? 0 : ~(0|U119Pad4|C34R);
assign J1Pad105 = rst ? 0 : ~(0);
assign J1Pad104 = rst ? 0 : ~(0);
assign C50R = rst ? 0 : ~(0|U202Pad2|CXB0_|CA5_);
assign U241Pad1 = rst ? 0 : ~(0|U241Pad2|U240Pad1);
assign U148Pad1 = rst ? 0 : ~(0|U133Pad2|U145Pad2);
assign C32P = rst ? 0 : ~(0|U131Pad9|CA3_|CXB2_);
assign U106Pad7 = rst ? 0 : ~(0|U109Pad7|C31R);
assign U233Pad9 = rst ? 0 : ~(0|U233Pad7|U231Pad8);
assign U233Pad2 = rst ? 0 : ~(0|BKTF_);
assign U233Pad1 = rst ? 0 : ~(0|U233Pad2|U231Pad3);
assign U141Pad2 = rst ? 0 : ~(0|C25R|U141Pad1);
assign U106Pad8 = rst ? 0 : ~(0|U118Pad7|C30R);
assign U141Pad1 = rst ? 0 : ~(0|U141Pad2|U140Pad1);
assign C53A = rst ? 0 : ~(0|CG24|U234Pad1);
assign C32A = rst ? 0 : ~(0|U135Pad9|CG22);
assign U206Pad8 = rst ? 0 : ~(0|U218Pad7|C51R);
assign C32M = rst ? 0 : ~(0|U138Pad7|CA3_|CXB2_);
assign U218Pad7 = rst ? 0 : ~(0|U206Pad8|U220Pad8);
assign U238Pad2 = rst ? 0 : ~(0|U238Pad1|SHAFTD);
assign C41P = rst ? 0 : ~(0|CXB1_|U245Pad9|CA4_);
assign U222Pad7 = rst ? 0 : ~(0|U221Pad7|C51R);
assign U208Pad3 = rst ? 0 : ~(0|U211Pad2|U207Pad4);
assign U248Pad8 = rst ? 0 : ~(0|U257Pad9|C41R);
assign U125Pad7 = rst ? 0 : ~(0|U108Pad8|U127Pad8);
assign U101Pad2 = rst ? 0 : ~(0|TRNM|U103Pad1);
assign U213Pad7 = rst ? 0 : ~(0|U215Pad7|CDUZD);
assign U201Pad2 = rst ? 0 : ~(0|PIPXM|U203Pad1);
assign C51A = rst ? 0 : ~(0|U218Pad7|CG26|U208Pad8);
assign U245Pad1 = rst ? 0 : ~(0|U245Pad2|C55R);
assign U207Pad4 = rst ? 0 : ~(0|C37R|U208Pad3);
assign C52R = rst ? 0 : ~(0|U202Pad2|CXB2_|CA5_);
assign C35P = rst ? 0 : ~(0|CXB5_|U112Pad3|CA3_);
assign U245Pad7 = rst ? 0 : ~(0|U245Pad9|C41R);
assign C35R = rst ? 0 : ~(0|U102Pad2|CA3_|CXB5_);
assign U245Pad9 = rst ? 0 : ~(0|U245Pad7|PIPZP);
assign U207Pad2 = rst ? 0 : ~(0|U224Pad2|C36R);
assign U208Pad8 = rst ? 0 : ~(0|U225Pad7|C50R);
assign C35A = rst ? 0 : ~(0|U107Pad2|CG11|U108Pad3);
assign U227Pad2 = rst ? 0 : ~(0|U228Pad2|U222Pad3);
assign C35M = rst ? 0 : ~(0|U101Pad2|CA3_|CXB5_);
assign CG11 = rst ? 0 : ~(0|U154Pad9);
assign U135Pad9 = rst ? 0 : ~(0|U134Pad9|U135Pad8);
assign U135Pad8 = rst ? 0 : ~(0|U135Pad9|C32R);
assign U227Pad8 = rst ? 0 : ~(0|U213Pad3|U228Pad8);
assign U250Pad9 = rst ? 0 : ~(0|U247Pad9|U250Pad8);
assign U211Pad2 = rst ? 0 : ~(0|U213Pad2|U213Pad3);
assign U234Pad9 = rst ? 0 : ~(0|U233Pad9|U233Pad2);
assign CG12 = rst ? 0 : ~(0|U105Pad2);
assign J3Pad314 = rst ? 0 : ~(0|CG26|U208Pad8|U206Pad7|U206Pad8);
assign U213Pad2 = rst ? 0 : ~(0|U214Pad2|U203Pad1);
assign U213Pad3 = rst ? 0 : ~(0|BKTF_);
assign U134Pad9 = rst ? 0 : ~(0|U133Pad9|U133Pad2);
assign U134Pad2 = rst ? 0 : ~(0|C24R|U134Pad1);
assign CXB2_ = rst ? 0 : ~(0|XB2);
assign U134Pad1 = rst ? 0 : ~(0|U134Pad2|U133Pad1);
assign U154Pad9 = rst ? 0 : ~(0|U150Pad8|CG22|U135Pad8);
assign C55R = rst ? 0 : ~(0|CA5_|CXB5_|U237Pad4);
assign C41R = rst ? 0 : ~(0|CXB1_|CA4_|U237Pad4);
assign C55A = rst ? 0 : ~(0|CG24|U234Pad2|U241Pad2|U249Pad1);
assign C25A = rst ? 0 : ~(0|U141Pad1|U134Pad2);
assign C41A = rst ? 0 : ~(0|CG14|U250Pad9|U235Pad8);
assign C30R = rst ? 0 : ~(0|U102Pad2|CA3_|CXB0_);
assign U245Pad2 = rst ? 0 : ~(0|U245Pad1|THRSTD);
assign U234Pad1 = rst ? 0 : ~(0|U234Pad2|U233Pad1);
assign U240Pad1 = rst ? 0 : ~(0|U233Pad2|U238Pad2);
assign U234Pad2 = rst ? 0 : ~(0|C53R|U234Pad1);
assign C25R = rst ? 0 : ~(0|CXB5_|U137Pad4|CA2_);
assign CXB4_ = rst ? 0 : ~(0|XB4);
assign U105Pad2 = rst ? 0 : ~(0|U107Pad2|CG11|U107Pad4);
assign C30A = rst ? 0 : ~(0|U118Pad7|CG21|U108Pad8);
assign U225Pad7 = rst ? 0 : ~(0|U208Pad8|U227Pad8);
assign C41M = rst ? 0 : ~(0|U257Pad9|CA4_|CXB1_);
assign U248Pad1 = rst ? 0 : ~(0|U233Pad2|U245Pad2);
assign U147Pad7 = rst ? 0 : ~(0|U145Pad7|U148Pad8);
assign J3Pad303 = rst ? 0 : ~(0);
assign U147Pad9 = rst ? 0 : ~(0|U147Pad7|U133Pad2);
assign J2Pad258 = rst ? 0 : ~(0|CG21|U108Pad8|U106Pad7|U106Pad8);
assign U103Pad1 = rst ? 0 : ~(0|C35R|U101Pad2);
assign U137Pad4 = rst ? 0 : ~(0|RSSB);
assign CXB7_ = rst ? 0 : ~(0|XB7);
assign U249Pad1 = rst ? 0 : ~(0|U249Pad2|U248Pad1);
assign U249Pad2 = rst ? 0 : ~(0|C55R|U249Pad1);
assign C33R = rst ? 0 : ~(0|CXB3_|CA3_|U137Pad4);
assign U220Pad8 = rst ? 0 : ~(0|U221Pad7|U213Pad3);
assign C33P = rst ? 0 : ~(0|CXB3_|U145Pad9|CA3_);
assign U209Pad7 = rst ? 0 : ~(0|U206Pad7|U212Pad8);
assign U250Pad8 = rst ? 0 : ~(0|U250Pad9|C41R);
assign U148Pad8 = rst ? 0 : ~(0|U157Pad9|C33R);
assign C33A = rst ? 0 : ~(0|CG22|U150Pad9|U135Pad8);
assign J4Pad457 = rst ? 0 : ~(0|U241Pad2|U249Pad2|CG24|U234Pad2);
assign C54R = rst ? 0 : ~(0|CXB4_|U237Pad4|CA5_);
assign C33M = rst ? 0 : ~(0|U157Pad9|CA3_|CXB3_);
assign U122Pad7 = rst ? 0 : ~(0|U121Pad7|C30R);
assign U145Pad9 = rst ? 0 : ~(0|U145Pad7|CDUYP);
assign U122Pad3 = rst ? 0 : ~(0|C34R|U121Pad4);
assign U145Pad2 = rst ? 0 : ~(0|T3P|U145Pad1);
assign U247Pad9 = rst ? 0 : ~(0|U247Pad7|U233Pad2);
assign U145Pad1 = rst ? 0 : ~(0|U145Pad2|C26R);
assign U145Pad7 = rst ? 0 : ~(0|U145Pad9|C33R);
assign U205Pad2 = rst ? 0 : ~(0|U207Pad2|CG12|U207Pad4);
assign U228Pad2 = rst ? 0 : ~(0|U219Pad4|C36R);
assign U124Pad2 = rst ? 0 : ~(0|U126Pad2|U107Pad2);
assign U214Pad2 = rst ? 0 : ~(0|U212Pad3|C37R);
assign U228Pad8 = rst ? 0 : ~(0|U229Pad7|CDUXD);

endmodule
