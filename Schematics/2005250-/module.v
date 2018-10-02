// Verilog module auto-generated for AGC module A21 by dumbVerilog.py

module A21 ( 
  rst, ALTM, BMAGXM, BMAGXP, BMAGYM, BMAGYP, BMAGZM, BMAGZP, C24A, C25A,
  C26A, C27A, C30A, C31A, C32A, C33A, C34A, C35A, C36A, C37A, C40A, C41A,
  C50A, C51A, C52A, C53A, C54A, C55A, CA6_, CG13, CG23, CGA21, CT, CXB2_,
  CXB3_, CXB4_, CXB7_, DOSCAL, EMSD, FS17, GNHNC, GOJAM, GYROD, INLNKM, INLNKP,
  MLDCH, MLOAD, MNHNC, MRDCH, MREAD, NISQL_, OCTAD4, OCTAD5, OTLNKM, PHS2_,
  PHS3_, PHS4_, PSEUDO, RNRADM, RNRADP, RQ, RSCT_, ST0_, ST1_, STD2, T02_,
  T07_, T10_, T11_, T12A, T12_, XB0, XB5, XB6, BKTF_, C42A, C43A, C44A, C45A,
  C45M, C45P, C46A, C46M, C46P, C47A, C56A, C57A, C60A, CA4_, CA5_, CG15,
  CG16, CHINC, CHINC_, CTROR_, CXB0_, CXB5_, CXB6_, DINC, INCSET_, INKBT1,
  INOTLD, INOTRD, MINKL, MREQIN, RSSB, SCAS17, d32004K, C42M, C42P, C42R,
  C43M, C43P, C43R, C44M, C44P, C44R, C45R, C46R, C47R, C56R, C57R, C60R,
  CAD1, CAD2, CAD3, CAD4, CAD5, CAD6, CG26, CTROR, DINCNC_, DINC_, FETCH0,
  FETCH0_, FETCH1, INKL, INKL_, MON_, MONpCH, RQ_, SHANC, SHANC_, SHINC,
  SHINC_, STFET1_, STORE1, STORE1_, d30SUM, d50SUM
);

input wire rst, ALTM, BMAGXM, BMAGXP, BMAGYM, BMAGYP, BMAGZM, BMAGZP, C24A,
  C25A, C26A, C27A, C30A, C31A, C32A, C33A, C34A, C35A, C36A, C37A, C40A,
  C41A, C50A, C51A, C52A, C53A, C54A, C55A, CA6_, CG13, CG23, CGA21, CT,
  CXB2_, CXB3_, CXB4_, CXB7_, DOSCAL, EMSD, FS17, GNHNC, GOJAM, GYROD, INLNKM,
  INLNKP, MLDCH, MLOAD, MNHNC, MRDCH, MREAD, NISQL_, OCTAD4, OCTAD5, OTLNKM,
  PHS2_, PHS3_, PHS4_, PSEUDO, RNRADM, RNRADP, RQ, RSCT_, ST0_, ST1_, STD2,
  T02_, T07_, T10_, T11_, T12A, T12_, XB0, XB5, XB6;

inout wire BKTF_, C42A, C43A, C44A, C45A, C45M, C45P, C46A, C46M, C46P, C47A,
  C56A, C57A, C60A, CA4_, CA5_, CG15, CG16, CHINC, CHINC_, CTROR_, CXB0_,
  CXB5_, CXB6_, DINC, INCSET_, INKBT1, INOTLD, INOTRD, MINKL, MREQIN, RSSB,
  SCAS17, d32004K;

output wire C42M, C42P, C42R, C43M, C43P, C43R, C44M, C44P, C44R, C45R, C46R,
  C47R, C56R, C57R, C60R, CAD1, CAD2, CAD3, CAD4, CAD5, CAD6, CG26, CTROR,
  DINCNC_, DINC_, FETCH0, FETCH0_, FETCH1, INKL, INKL_, MON_, MONpCH, RQ_,
  SHANC, SHANC_, SHINC, SHINC_, STFET1_, STORE1, STORE1_, d30SUM, d50SUM;

assign #0.2  INOTLD = rst ? 0 : ~(0|U112Pad8|U118Pad1);
assign #0.2  C47A = rst ? 0 : ~(0|U208Pad8|CG16|U209Pad8);
assign #0.2  U121Pad3 = rst ? 0 : ~(0|U123Pad1|U114Pad7);
assign #0.2  C57A = rst ? 0 : ~(0|CG23|U241Pad1|U234Pad2);
assign #0.2  U140Pad7 = rst ? 0 : ~(0|d50SUM|C46A|C47A|C40A|C41A|C42A|C60A|C45A|C44A|C43A);
assign #0.2  SHANC_ = rst ? 0 : ~(0|SHANC|U134Pad1);
assign #0.2  U226Pad7 = rst ? 0 : ~(0|U208Pad8|U225Pad9);
assign #0.2  U140Pad2 = rst ? 0 : ~(0|C26A|C25A|C24A|C27A|d30SUM|C60A);
assign #0.2  U226Pad2 = rst ? 0 : ~(0|U227Pad2|U213Pad3);
assign #0.2  U111Pad2 = rst ? 0 : ~(0|PHS2_|U109Pad9);
assign #0.2  U137Pad1 = rst ? 0 : ~(0|C45M|C46M|C57A|C60A);
assign #0.2  J3Pad323 = rst ? 0 : ~(0);
assign #0.2  U212Pad8 = rst ? 0 : ~(0|U213Pad7|U213Pad3);
assign #0.2  CXB5_ = rst ? 0 : ~(0|XB5);
assign #0.2  U212Pad3 = rst ? 0 : ~(0|INLNKP|U214Pad3);
assign #0.2  d32004K = rst ? 0 : ~(0|C37A|C36A|C32A|C31A|C30A|C35A|C34A|C33A);
assign #0.2  FETCH0_ = rst ? 0 : ~(0|FETCH0);
assign #0.2  U208Pad3 = rst ? 0 : ~(0|U211Pad2|U207Pad4);
assign #0.2  U208Pad6 = rst ? 0 : ~(0|U209Pad8|C47R);
assign #0.2  U208Pad8 = rst ? 0 : ~(0|U226Pad7|C46R);
assign #0.2  MON_ = rst ? 0 : ~(0|U114Pad8|U114Pad7);
assign #0.2  CG26 = rst ? 0 : ~(0|J3Pad314);
assign #0.2  U108Pad7 = rst ? 0 : ~(0|U110Pad6|GOJAM|U110Pad8);
assign #0.2  C56A = rst ? 0 : ~(0|CG23|U234Pad1);
assign #0.2  U133Pad1 = rst ? 0 : ~(0|U133Pad2|INCSET_);
assign #0.2  U108Pad2 = rst ? 0 : ~(0|CTROR_|U108Pad7|MNHNC|U109Pad3);
assign #0.2  U133Pad2 = rst ? 0 : ~(0|C54A|C56A|C55A|C50A|C47A|C31A|C51A|C52A|C53A);
assign #0.2  U238Pad1 = rst ? 0 : ~(0|U238Pad2|C57R);
assign #0.2  U238Pad2 = rst ? 0 : ~(0|U238Pad1|OTLNKM);
assign #0.2  U133Pad9 = rst ? 0 : ~(0|C46P|C45P);
assign #0.2  U238Pad7 = rst ? 0 : ~(0|U233Pad7|BMAGXM);
assign #0.2  C56R = rst ? 0 : ~(0|CXB6_|CA5_|U237Pad4);
assign #0.2  MONpCH = rst ? 0 : ~(0|U114Pad2);
assign #0.2  CTROR = rst ? 0 : ~(0|CTROR_);
assign #0.2  INOTRD = rst ? 0 : ~(0|U112Pad8|U116Pad1);
assign #0.2  U235Pad8 = rst ? 0 : ~(0|U235Pad9|C42R);
assign #0.2  U235Pad9 = rst ? 0 : ~(0|U234Pad9|U235Pad8);
assign #0.2  U109Pad3 = rst ? 0 : ~(0|U128Pad1);
assign #0.2  DINCNC_ = rst ? 0 : ~(0|DINC|U133Pad1);
assign #0.2  U221Pad7 = rst ? 0 : ~(0|U218Pad8|C46R);
assign #0.2  STORE1 = rst ? 0 : ~(0|U125Pad2|ST1_);
assign #0.2  U221Pad4 = rst ? 0 : ~(0|BMAGZM|U222Pad3);
assign #0.2  U117Pad3 = rst ? 0 : ~(0|MRDCH);
assign #0.2  RQ_ = rst ? 0 : ~(0|RQ);
assign #0.2  U221Pad9 = rst ? 0 : ~(0|U221Pad7|U221Pad8);
assign #0.2  U109Pad9 = rst ? 0 : ~(0|MREAD|MLOAD|MLDCH|MRDCH);
assign #0.2  U224Pad2 = rst ? 0 : ~(0|U226Pad2|U207Pad2);
assign #0.2  SHANC = rst ? 0 : ~(0|SHANC_|T12A);
assign #0.2  STFET1_ = rst ? 0 : ~(0|STORE1|FETCH1);
assign #0.2  U241Pad1 = rst ? 0 : ~(0|U241Pad2|U240Pad1);
assign #0.2  U221Pad8 = rst ? 0 : ~(0|C46R|U220Pad8);
assign #0.2  MREQIN = rst ? 0 : ~(0|U114Pad2);
assign #0.2  U102Pad4 = rst ? 0 : ~(0|U108Pad2|U105Pad2);
assign #0.2  U118Pad3 = rst ? 0 : ~(0|U109Pad3|U119Pad3|U110Pad8);
assign #0.2  U234Pad1 = rst ? 0 : ~(0|U234Pad2|U233Pad1);
assign #0.2  U107Pad6 = rst ? 0 : ~(0|U108Pad7|CTROR_);
assign #0.2  U222Pad3 = rst ? 0 : ~(0|C44R|U221Pad4);
assign #0.2  DINC = rst ? 0 : ~(0|T12A|DINCNC_);
assign #0.2  C47R = rst ? 0 : ~(0|U202Pad2|CXB7_|CA4_);
assign #0.2  U107Pad3 = rst ? 0 : ~(0|U107Pad6|PHS3_|T12_);
assign #0.2  J4Pad467 = rst ? 0 : ~(0);
assign #0.2  U207Pad4 = rst ? 0 : ~(0|C45R|U208Pad3);
assign #0.2  U207Pad2 = rst ? 0 : ~(0|U224Pad2|C44R);
assign #0.2  C45M = rst ? 0 : ~(0|U201Pad2|CA4_|CXB5_);
assign #0.2  C45R = rst ? 0 : ~(0|U202Pad2|CA4_|CXB5_);
assign #0.2  U126Pad2 = rst ? 0 : ~(0|U110Pad8|U127Pad1|U109Pad3);
assign #0.2  C45P = rst ? 0 : ~(0|CXB5_|U212Pad3|CA4_);
assign #0.2  U250Pad8 = rst ? 0 : ~(0|U250Pad9|C43R);
assign #0.2  CG15 = rst ? 0 : ~(0|U254Pad9);
assign #0.2  U112Pad8 = rst ? 0 : ~(0|T12_|CT|PHS2_);
assign #0.2  U112Pad9 = rst ? 0 : ~(0|U112Pad8);
assign #0.2  J3Pad343 = rst ? 0 : ~(0);
assign #0.2  U237Pad4 = rst ? 0 : ~(0|RSSB);
assign #0.2  U249Pad1 = rst ? 0 : ~(0|U249Pad2|U247Pad1);
assign #0.2  RSSB = rst ? 0 : ~(0|PHS3_|T07_|U102Pad4);
assign #0.2  U119Pad3 = rst ? 0 : ~(0|MLDCH);
assign #0.2  U113Pad7 = rst ? 0 : ~(0|FETCH1|STORE1|CHINC);
assign #0.2  U203Pad1 = rst ? 0 : ~(0|C45R|U201Pad2);
assign #0.2  U127Pad1 = rst ? 0 : ~(0|MLOAD);
assign #0.2  U118Pad1 = rst ? 0 : ~(0|INOTLD|U118Pad3);
assign #0.2  U231Pad1 = rst ? 0 : ~(0|C56R|U231Pad3);
assign #0.2  U250Pad9 = rst ? 0 : ~(0|U247Pad9|U250Pad8);
assign #0.2  U231Pad3 = rst ? 0 : ~(0|U231Pad1|EMSD);
assign #0.2  C46A = rst ? 0 : ~(0|U226Pad7|CG16);
assign #0.2  U231Pad7 = rst ? 0 : ~(0|U231Pad9|C42R);
assign #0.2  U231Pad9 = rst ? 0 : ~(0|U231Pad7|BMAGXP);
assign #0.2  C46M = rst ? 0 : ~(0|CA4_|CXB6_|U218Pad8);
assign #0.2  U116Pad3 = rst ? 0 : ~(0|U109Pad3|U117Pad3|U110Pad8);
assign #0.2  U116Pad1 = rst ? 0 : ~(0|INOTRD|U116Pad3);
assign #0.2  INCSET_ = rst ? 0 : ~(0|U105Pad8);
assign #0.2  C46R = rst ? 0 : ~(0|CA4_|CXB6_|U202Pad2);
assign #0.2  C46P = rst ? 0 : ~(0|CA4_|CXB6_|U220Pad8);
assign #0.2  U241Pad2 = rst ? 0 : ~(0|C57R|U241Pad1);
assign #0.2  U215Pad7 = rst ? 0 : ~(0|U213Pad7|C47R);
assign #0.2  U114Pad8 = rst ? 0 : ~(0|U120Pad1|U125Pad2|GOJAM);
assign #0.2  CG16 = rst ? 0 : ~(0|U205Pad2);
assign #0.2  U114Pad2 = rst ? 0 : ~(0|U114Pad7|U114Pad8|INOTLD|INOTRD);
assign #0.2  U128Pad1 = rst ? 0 : ~(0|PHS4_|T12_|NISQL_|GNHNC|PSEUDO);
assign #0.2  U114Pad7 = rst ? 0 : ~(0|U120Pad1|U121Pad3|GOJAM);
assign #0.2  C57R = rst ? 0 : ~(0|CXB7_|U237Pad4|CA5_);
assign #0.2  U209Pad8 = rst ? 0 : ~(0|U208Pad6|U212Pad8);
assign #0.2  CXB6_ = rst ? 0 : ~(0|XB6);
assign #0.2  U247Pad1 = rst ? 0 : ~(0|U233Pad2|U245Pad2);
assign #0.2  U233Pad9 = rst ? 0 : ~(0|U233Pad7|U231Pad7);
assign #0.2  C43M = rst ? 0 : ~(0|U257Pad9|CA4_|CXB3_);
assign #0.2  U141Pad9 = rst ? 0 : ~(0|U137Pad1|INCSET_);
assign #0.2  U233Pad2 = rst ? 0 : ~(0|BKTF_);
assign #0.2  C43A = rst ? 0 : ~(0|CG13|U250Pad9|U235Pad8);
assign #0.2  U233Pad1 = rst ? 0 : ~(0|U233Pad2|U231Pad3);
assign #0.2  U141Pad2 = rst ? 0 : ~(0|C36A|C37A|C44A|C57A|C55A|C54A|C56A|C27A|C34A|C35A|C25A|C24A|C26A|C45A|C47A|C46A);
assign #0.2  U233Pad7 = rst ? 0 : ~(0|U238Pad7|C42R);
assign #0.2  SHINC_ = rst ? 0 : ~(0|SHINC|U141Pad9);
assign #0.2  d50SUM = rst ? 0 : ~(0|U145Pad8);
assign #0.2  C45A = rst ? 0 : ~(0|U207Pad2|CG15|U208Pad3);
assign #0.2  C43P = rst ? 0 : ~(0|CXB3_|U245Pad9|CA4_);
assign #0.2  U120Pad1 = rst ? 0 : ~(0|ST1_|MON_|U112Pad9);
assign #0.2  C43R = rst ? 0 : ~(0|CXB3_|CA4_|U237Pad4);
assign #0.2  CTROR_ = rst ? 0 : ~(0|U241Pad2|U249Pad2|CG23|U234Pad2);
assign #0.2  U123Pad3 = rst ? 0 : ~(0|MREAD);
assign #0.2  U123Pad1 = rst ? 0 : ~(0|U109Pad3|U123Pad3|U110Pad8);
assign #0.2  SCAS17 = rst ? 0 : ~(0|FS17|DOSCAL);
assign #0.2  U218Pad8 = rst ? 0 : ~(0|U221Pad7|RNRADM);
assign #0.2  U125Pad2 = rst ? 0 : ~(0|U126Pad2|U114Pad8);
assign #0.2  U248Pad8 = rst ? 0 : ~(0|U257Pad9|C43R);
assign #0.2  U201Pad2 = rst ? 0 : ~(0|INLNKM|U203Pad1);
assign #0.2  CHINC_ = rst ? 0 : ~(0|INOTRD|INOTLD);
assign #0.2  U202Pad2 = rst ? 0 : ~(0|RSSB);
assign #0.2  U245Pad2 = rst ? 0 : ~(0|U245Pad1|ALTM);
assign #0.2  U245Pad7 = rst ? 0 : ~(0|U245Pad9|C43R);
assign #0.2  U245Pad9 = rst ? 0 : ~(0|U245Pad7|BMAGYP);
assign #0.2  C44A = rst ? 0 : ~(0|CG15|U224Pad2);
assign #0.2  U145Pad8 = rst ? 0 : ~(0|C57A|C56A|C52A|C50A|C51A|C53A|C55A|C54A);
assign #0.2  U227Pad2 = rst ? 0 : ~(0|U228Pad2|U222Pad3);
assign #0.2  U247Pad7 = rst ? 0 : ~(0|U245Pad7|U248Pad8);
assign #0.2  U219Pad4 = rst ? 0 : ~(0|BMAGZP|U228Pad2);
assign #0.2  CA5_ = rst ? 0 : ~(0|OCTAD5);
assign #0.2  C44P = rst ? 0 : ~(0|CXB4_|CA4_|U219Pad4);
assign #0.2  C44R = rst ? 0 : ~(0|CXB4_|CA4_|U202Pad2);
assign #0.2  C60A = rst ? 0 : ~(0|CG23|U234Pad2|U241Pad2|U249Pad1);
assign #0.2  U211Pad2 = rst ? 0 : ~(0|U213Pad2|U213Pad3);
assign #0.2  U254Pad9 = rst ? 0 : ~(0|U250Pad8|CG13|U235Pad8);
assign #0.2  U213Pad7 = rst ? 0 : ~(0|U215Pad7|GYROD);
assign #0.2  J3Pad314 = rst ? 0 : ~(0|U208Pad6|CG16|U208Pad8);
assign #0.2  U213Pad2 = rst ? 0 : ~(0|U203Pad1|U214Pad3);
assign #0.2  U213Pad3 = rst ? 0 : ~(0|BKTF_);
assign #0.2  C60R = rst ? 0 : ~(0|CA6_|CXB0_|U237Pad4);
assign #0.2  CHINC = rst ? 0 : ~(0|CHINC_);
assign #0.2  STORE1_ = rst ? 0 : ~(0|STORE1);
assign #0.2  U110Pad8 = rst ? 0 : ~(0|U111Pad2|U108Pad7);
assign #0.2  U134Pad1 = rst ? 0 : ~(0|INCSET_|U133Pad9);
assign #0.2  INKL_ = rst ? 0 : ~(0|U105Pad2|MONpCH);
assign #0.2  FETCH0 = rst ? 0 : ~(0|MON_|ST0_);
assign #0.2  FETCH1 = rst ? 0 : ~(0|ST1_|U121Pad3);
assign #0.2  C44M = rst ? 0 : ~(0|CXB4_|CA4_|U221Pad4);
assign #0.2  SHINC = rst ? 0 : ~(0|SHINC_|T12A);
assign #0.2  INKL = rst ? 0 : ~(0|INKL_);
assign #0.2  U240Pad1 = rst ? 0 : ~(0|U233Pad2|U238Pad2);
assign #0.2  U105Pad8 = rst ? 0 : ~(0|U102Pad4|T02_);
assign #0.2  U234Pad2 = rst ? 0 : ~(0|C56R|U234Pad1);
assign #0.2  U110Pad6 = rst ? 0 : ~(0|U113Pad7|T11_);
assign #0.2  U105Pad2 = rst ? 0 : ~(0|GOJAM|U107Pad3|U102Pad4);
assign #0.2  INKBT1 = rst ? 0 : ~(0|STD2);
assign #0.2  J3Pad303 = rst ? 0 : ~(0);
assign #0.2  U234Pad9 = rst ? 0 : ~(0|U233Pad9|U233Pad2);
assign #0.2  BKTF_ = rst ? 0 : ~(0|T10_);
assign #0.2  d30SUM = rst ? 0 : ~(0|d32004K);
assign #0.2  U143Pad1 = rst ? 0 : ~(0|d30SUM|d50SUM);
assign #0.2  CA4_ = rst ? 0 : ~(0|OCTAD4);
assign #0.2  U143Pad8 = rst ? 0 : ~(0|C57A|C55A|C53A|C47A|C51A|C33A|C35A|C37A|C31A|C27A|C25A|C45A|C43A|C41A);
assign #0.2  U249Pad2 = rst ? 0 : ~(0|C60R|U249Pad1);
assign #0.2  U220Pad8 = rst ? 0 : ~(0|U221Pad8|RNRADP);
assign #0.2  C42M = rst ? 0 : ~(0|U238Pad7|CA4_|CXB2_);
assign #0.2  C42A = rst ? 0 : ~(0|U235Pad9|CG13);
assign #0.2  U257Pad9 = rst ? 0 : ~(0|U248Pad8|BMAGYM);
assign #0.2  C42R = rst ? 0 : ~(0|U237Pad4|CA4_|CXB2_);
assign #0.2  DINC_ = rst ? 0 : ~(0|DINC);
assign #0.2  C42P = rst ? 0 : ~(0|U231Pad9|CXB2_|CA4_);
assign #0.2  MINKL = rst ? 0 : ~(0|INKL_);
assign #0.2  U245Pad1 = rst ? 0 : ~(0|U245Pad2|C60R);
assign #0.2  CAD1 = rst ? 0 : ~(0|RSCT_|U143Pad8);
assign #0.2  CAD2 = rst ? 0 : ~(0|RSCT_|U142Pad8);
assign #0.2  CAD3 = rst ? 0 : ~(0|U141Pad2|RSCT_);
assign #0.2  CAD4 = rst ? 0 : ~(0|RSCT_|U143Pad1);
assign #0.2  CAD5 = rst ? 0 : ~(0|U140Pad2|RSCT_);
assign #0.2  CAD6 = rst ? 0 : ~(0|U140Pad7|RSCT_);
assign #0.2  U247Pad9 = rst ? 0 : ~(0|U247Pad7|U233Pad2);
assign #0.2  U205Pad2 = rst ? 0 : ~(0|U207Pad2|CG15|U207Pad4);
assign #0.2  U228Pad2 = rst ? 0 : ~(0|U219Pad4|C44R);
assign #0.2  CXB0_ = rst ? 0 : ~(0|XB0);
assign #0.2  U214Pad3 = rst ? 0 : ~(0|U212Pad3|C45R);
assign #0.2  U142Pad8 = rst ? 0 : ~(0|C53A|C52A|C47A|C33A|C36A|C37A|C32A|C26A|C27A|C57A|C56A|C46A|C42A|C43A);
assign #0.2  U225Pad9 = rst ? 0 : ~(0|U213Pad3|U221Pad9);

endmodule
