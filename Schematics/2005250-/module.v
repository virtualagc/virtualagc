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

assign INOTLD = rst ? 0 : ~(0|U112Pad8|U118Pad1);
assign C47A = rst ? 0 : ~(0|U208Pad8|CG16|U209Pad8);
assign U121Pad3 = rst ? 0 : ~(0|U123Pad1|U114Pad7);
assign C57A = rst ? 0 : ~(0|CG23|U241Pad1|U234Pad2);
assign U140Pad7 = rst ? 0 : ~(0|d50SUM|C46A|C47A|C40A|C41A|C42A|C60A|C45A|C44A|C43A);
assign SHANC_ = rst ? 0 : ~(0|SHANC|U134Pad1);
assign U226Pad7 = rst ? 0 : ~(0|U208Pad8|U225Pad9);
assign U140Pad2 = rst ? 0 : ~(0|C26A|C25A|C24A|C27A|d30SUM|C60A);
assign U226Pad2 = rst ? 0 : ~(0|U227Pad2|U213Pad3);
assign U111Pad2 = rst ? 0 : ~(0|PHS2_|U109Pad9);
assign U137Pad1 = rst ? 0 : ~(0|C45M|C46M|C57A|C60A);
assign J3Pad323 = rst ? 0 : ~(0);
assign U212Pad8 = rst ? 0 : ~(0|U213Pad7|U213Pad3);
assign CXB5_ = rst ? 0 : ~(0|XB5);
assign U212Pad3 = rst ? 0 : ~(0|INLNKP|U214Pad3);
assign d32004K = rst ? 0 : ~(0|C37A|C36A|C32A|C31A|C30A|C35A|C34A|C33A);
assign FETCH0_ = rst ? 0 : ~(0|FETCH0);
assign U208Pad3 = rst ? 0 : ~(0|U211Pad2|U207Pad4);
assign U208Pad6 = rst ? 0 : ~(0|U209Pad8|C47R);
assign U208Pad8 = rst ? 0 : ~(0|U226Pad7|C46R);
assign MON_ = rst ? 0 : ~(0|U114Pad8|U114Pad7);
assign CG26 = rst ? 0 : ~(0|J3Pad314);
assign U108Pad7 = rst ? 0 : ~(0|U110Pad6|GOJAM|U110Pad8);
assign C56A = rst ? 0 : ~(0|CG23|U234Pad1);
assign U133Pad1 = rst ? 0 : ~(0|U133Pad2|INCSET_);
assign U108Pad2 = rst ? 0 : ~(0|CTROR_|U108Pad7|MNHNC|U109Pad3);
assign U133Pad2 = rst ? 0 : ~(0|C54A|C56A|C55A|C50A|C47A|C31A|C51A|C52A|C53A);
assign U238Pad1 = rst ? 0 : ~(0|U238Pad2|C57R);
assign U238Pad2 = rst ? 0 : ~(0|U238Pad1|OTLNKM);
assign U133Pad9 = rst ? 0 : ~(0|C46P|C45P);
assign U238Pad7 = rst ? 0 : ~(0|U233Pad7|BMAGXM);
assign C56R = rst ? 0 : ~(0|CXB6_|CA5_|U237Pad4);
assign MONpCH = rst ? 0 : ~(0|U114Pad2);
assign CTROR = rst ? 0 : ~(0|CTROR_);
assign INOTRD = rst ? 0 : ~(0|U112Pad8|U116Pad1);
assign U235Pad8 = rst ? 0 : ~(0|U235Pad9|C42R);
assign U235Pad9 = rst ? 0 : ~(0|U234Pad9|U235Pad8);
assign U109Pad3 = rst ? 0 : ~(0|U128Pad1);
assign DINCNC_ = rst ? 0 : ~(0|DINC|U133Pad1);
assign U221Pad7 = rst ? 0 : ~(0|U218Pad8|C46R);
assign STORE1 = rst ? 0 : ~(0|U125Pad2|ST1_);
assign U221Pad4 = rst ? 0 : ~(0|BMAGZM|U222Pad3);
assign U117Pad3 = rst ? 0 : ~(0|MRDCH);
assign RQ_ = rst ? 0 : ~(0|RQ);
assign U221Pad9 = rst ? 0 : ~(0|U221Pad7|U221Pad8);
assign U109Pad9 = rst ? 0 : ~(0|MREAD|MLOAD|MLDCH|MRDCH);
assign U224Pad2 = rst ? 0 : ~(0|U226Pad2|U207Pad2);
assign SHANC = rst ? 0 : ~(0|SHANC_|T12A);
assign STFET1_ = rst ? 0 : ~(0|STORE1|FETCH1);
assign U241Pad1 = rst ? 0 : ~(0|U241Pad2|U240Pad1);
assign U221Pad8 = rst ? 0 : ~(0|C46R|U220Pad8);
assign MREQIN = rst ? 0 : ~(0|U114Pad2);
assign U102Pad4 = rst ? 0 : ~(0|U108Pad2|U105Pad2);
assign U118Pad3 = rst ? 0 : ~(0|U109Pad3|U119Pad3|U110Pad8);
assign U234Pad1 = rst ? 0 : ~(0|U234Pad2|U233Pad1);
assign U107Pad6 = rst ? 0 : ~(0|U108Pad7|CTROR_);
assign U222Pad3 = rst ? 0 : ~(0|C44R|U221Pad4);
assign DINC = rst ? 0 : ~(0|T12A|DINCNC_);
assign C47R = rst ? 0 : ~(0|U202Pad2|CXB7_|CA4_);
assign U107Pad3 = rst ? 0 : ~(0|U107Pad6|PHS3_|T12_);
assign J4Pad467 = rst ? 0 : ~(0);
assign U207Pad4 = rst ? 0 : ~(0|C45R|U208Pad3);
assign U207Pad2 = rst ? 0 : ~(0|U224Pad2|C44R);
assign C45M = rst ? 0 : ~(0|U201Pad2|CA4_|CXB5_);
assign C45R = rst ? 0 : ~(0|U202Pad2|CA4_|CXB5_);
assign U126Pad2 = rst ? 0 : ~(0|U110Pad8|U127Pad1|U109Pad3);
assign C45P = rst ? 0 : ~(0|CXB5_|U212Pad3|CA4_);
assign U250Pad8 = rst ? 0 : ~(0|U250Pad9|C43R);
assign CG15 = rst ? 0 : ~(0|U254Pad9);
assign U112Pad8 = rst ? 0 : ~(0|T12_|CT|PHS2_);
assign U112Pad9 = rst ? 0 : ~(0|U112Pad8);
assign J3Pad343 = rst ? 0 : ~(0);
assign U237Pad4 = rst ? 0 : ~(0|RSSB);
assign U249Pad1 = rst ? 0 : ~(0|U249Pad2|U247Pad1);
assign RSSB = rst ? 0 : ~(0|PHS3_|T07_|U102Pad4);
assign U119Pad3 = rst ? 0 : ~(0|MLDCH);
assign U113Pad7 = rst ? 0 : ~(0|FETCH1|STORE1|CHINC);
assign U203Pad1 = rst ? 0 : ~(0|C45R|U201Pad2);
assign U127Pad1 = rst ? 0 : ~(0|MLOAD);
assign U118Pad1 = rst ? 0 : ~(0|INOTLD|U118Pad3);
assign U231Pad1 = rst ? 0 : ~(0|C56R|U231Pad3);
assign U250Pad9 = rst ? 0 : ~(0|U247Pad9|U250Pad8);
assign U231Pad3 = rst ? 0 : ~(0|U231Pad1|EMSD);
assign C46A = rst ? 0 : ~(0|U226Pad7|CG16);
assign U231Pad7 = rst ? 0 : ~(0|U231Pad9|C42R);
assign U231Pad9 = rst ? 0 : ~(0|U231Pad7|BMAGXP);
assign C46M = rst ? 0 : ~(0|CA4_|CXB6_|U218Pad8);
assign U116Pad3 = rst ? 0 : ~(0|U109Pad3|U117Pad3|U110Pad8);
assign U116Pad1 = rst ? 0 : ~(0|INOTRD|U116Pad3);
assign INCSET_ = rst ? 0 : ~(0|U105Pad8);
assign C46R = rst ? 0 : ~(0|CA4_|CXB6_|U202Pad2);
assign C46P = rst ? 0 : ~(0|CA4_|CXB6_|U220Pad8);
assign U241Pad2 = rst ? 0 : ~(0|C57R|U241Pad1);
assign U215Pad7 = rst ? 0 : ~(0|U213Pad7|C47R);
assign U114Pad8 = rst ? 0 : ~(0|U120Pad1|U125Pad2|GOJAM);
assign CG16 = rst ? 0 : ~(0|U205Pad2);
assign U114Pad2 = rst ? 0 : ~(0|U114Pad7|U114Pad8|INOTLD|INOTRD);
assign U128Pad1 = rst ? 0 : ~(0|PHS4_|T12_|NISQL_|GNHNC|PSEUDO);
assign U114Pad7 = rst ? 0 : ~(0|U120Pad1|U121Pad3|GOJAM);
assign C57R = rst ? 0 : ~(0|CXB7_|U237Pad4|CA5_);
assign U209Pad8 = rst ? 0 : ~(0|U208Pad6|U212Pad8);
assign CXB6_ = rst ? 0 : ~(0|XB6);
assign U247Pad1 = rst ? 0 : ~(0|U233Pad2|U245Pad2);
assign U233Pad9 = rst ? 0 : ~(0|U233Pad7|U231Pad7);
assign C43M = rst ? 0 : ~(0|U257Pad9|CA4_|CXB3_);
assign U141Pad9 = rst ? 0 : ~(0|U137Pad1|INCSET_);
assign U233Pad2 = rst ? 0 : ~(0|BKTF_);
assign C43A = rst ? 0 : ~(0|CG13|U250Pad9|U235Pad8);
assign U233Pad1 = rst ? 0 : ~(0|U233Pad2|U231Pad3);
assign U141Pad2 = rst ? 0 : ~(0|C36A|C37A|C44A|C57A|C55A|C54A|C56A|C27A|C34A|C35A|C25A|C24A|C26A|C45A|C47A|C46A);
assign U233Pad7 = rst ? 0 : ~(0|U238Pad7|C42R);
assign SHINC_ = rst ? 0 : ~(0|SHINC|U141Pad9);
assign d50SUM = rst ? 0 : ~(0|U145Pad8);
assign C45A = rst ? 0 : ~(0|U207Pad2|CG15|U208Pad3);
assign C43P = rst ? 0 : ~(0|CXB3_|U245Pad9|CA4_);
assign U120Pad1 = rst ? 0 : ~(0|ST1_|MON_|U112Pad9);
assign C43R = rst ? 0 : ~(0|CXB3_|CA4_|U237Pad4);
assign CTROR_ = rst ? 0 : ~(0|U241Pad2|U249Pad2|CG23|U234Pad2);
assign U123Pad3 = rst ? 0 : ~(0|MREAD);
assign U123Pad1 = rst ? 0 : ~(0|U109Pad3|U123Pad3|U110Pad8);
assign SCAS17 = rst ? 0 : ~(0|FS17|DOSCAL);
assign U218Pad8 = rst ? 0 : ~(0|U221Pad7|RNRADM);
assign U125Pad2 = rst ? 0 : ~(0|U126Pad2|U114Pad8);
assign U248Pad8 = rst ? 0 : ~(0|U257Pad9|C43R);
assign U201Pad2 = rst ? 0 : ~(0|INLNKM|U203Pad1);
assign CHINC_ = rst ? 0 : ~(0|INOTRD|INOTLD);
assign U202Pad2 = rst ? 0 : ~(0|RSSB);
assign U245Pad2 = rst ? 0 : ~(0|U245Pad1|ALTM);
assign U245Pad7 = rst ? 0 : ~(0|U245Pad9|C43R);
assign U245Pad9 = rst ? 0 : ~(0|U245Pad7|BMAGYP);
assign C44A = rst ? 0 : ~(0|CG15|U224Pad2);
assign U145Pad8 = rst ? 0 : ~(0|C57A|C56A|C52A|C50A|C51A|C53A|C55A|C54A);
assign U227Pad2 = rst ? 0 : ~(0|U228Pad2|U222Pad3);
assign U247Pad7 = rst ? 0 : ~(0|U245Pad7|U248Pad8);
assign U219Pad4 = rst ? 0 : ~(0|BMAGZP|U228Pad2);
assign CA5_ = rst ? 0 : ~(0|OCTAD5);
assign C44P = rst ? 0 : ~(0|CXB4_|CA4_|U219Pad4);
assign C44R = rst ? 0 : ~(0|CXB4_|CA4_|U202Pad2);
assign C60A = rst ? 0 : ~(0|CG23|U234Pad2|U241Pad2|U249Pad1);
assign U211Pad2 = rst ? 0 : ~(0|U213Pad2|U213Pad3);
assign U254Pad9 = rst ? 0 : ~(0|U250Pad8|CG13|U235Pad8);
assign U213Pad7 = rst ? 0 : ~(0|U215Pad7|GYROD);
assign J3Pad314 = rst ? 0 : ~(0|U208Pad6|CG16|U208Pad8);
assign U213Pad2 = rst ? 0 : ~(0|U203Pad1|U214Pad3);
assign U213Pad3 = rst ? 0 : ~(0|BKTF_);
assign C60R = rst ? 0 : ~(0|CA6_|CXB0_|U237Pad4);
assign CHINC = rst ? 0 : ~(0|CHINC_);
assign STORE1_ = rst ? 0 : ~(0|STORE1);
assign U110Pad8 = rst ? 0 : ~(0|U111Pad2|U108Pad7);
assign U134Pad1 = rst ? 0 : ~(0|INCSET_|U133Pad9);
assign INKL_ = rst ? 0 : ~(0|U105Pad2|MONpCH);
assign FETCH0 = rst ? 0 : ~(0|MON_|ST0_);
assign FETCH1 = rst ? 0 : ~(0|ST1_|U121Pad3);
assign C44M = rst ? 0 : ~(0|CXB4_|CA4_|U221Pad4);
assign SHINC = rst ? 0 : ~(0|SHINC_|T12A);
assign INKL = rst ? 0 : ~(0|INKL_);
assign U240Pad1 = rst ? 0 : ~(0|U233Pad2|U238Pad2);
assign U105Pad8 = rst ? 0 : ~(0|U102Pad4|T02_);
assign U234Pad2 = rst ? 0 : ~(0|C56R|U234Pad1);
assign U110Pad6 = rst ? 0 : ~(0|U113Pad7|T11_);
assign U105Pad2 = rst ? 0 : ~(0|GOJAM|U107Pad3|U102Pad4);
assign INKBT1 = rst ? 0 : ~(0|STD2);
assign J3Pad303 = rst ? 0 : ~(0);
assign U234Pad9 = rst ? 0 : ~(0|U233Pad9|U233Pad2);
assign BKTF_ = rst ? 0 : ~(0|T10_);
assign d30SUM = rst ? 0 : ~(0|d32004K);
assign U143Pad1 = rst ? 0 : ~(0|d30SUM|d50SUM);
assign CA4_ = rst ? 0 : ~(0|OCTAD4);
assign U143Pad8 = rst ? 0 : ~(0|C57A|C55A|C53A|C47A|C51A|C33A|C35A|C37A|C31A|C27A|C25A|C45A|C43A|C41A);
assign U249Pad2 = rst ? 0 : ~(0|C60R|U249Pad1);
assign U220Pad8 = rst ? 0 : ~(0|U221Pad8|RNRADP);
assign C42M = rst ? 0 : ~(0|U238Pad7|CA4_|CXB2_);
assign C42A = rst ? 0 : ~(0|U235Pad9|CG13);
assign U257Pad9 = rst ? 0 : ~(0|U248Pad8|BMAGYM);
assign C42R = rst ? 0 : ~(0|U237Pad4|CA4_|CXB2_);
assign DINC_ = rst ? 0 : ~(0|DINC);
assign C42P = rst ? 0 : ~(0|U231Pad9|CXB2_|CA4_);
assign MINKL = rst ? 0 : ~(0|INKL_);
assign U245Pad1 = rst ? 0 : ~(0|U245Pad2|C60R);
assign CAD1 = rst ? 0 : ~(0|RSCT_|U143Pad8);
assign CAD2 = rst ? 0 : ~(0|RSCT_|U142Pad8);
assign CAD3 = rst ? 0 : ~(0|U141Pad2|RSCT_);
assign CAD4 = rst ? 0 : ~(0|RSCT_|U143Pad1);
assign CAD5 = rst ? 0 : ~(0|U140Pad2|RSCT_);
assign CAD6 = rst ? 0 : ~(0|U140Pad7|RSCT_);
assign U247Pad9 = rst ? 0 : ~(0|U247Pad7|U233Pad2);
assign U205Pad2 = rst ? 0 : ~(0|U207Pad2|CG15|U207Pad4);
assign U228Pad2 = rst ? 0 : ~(0|U219Pad4|C44R);
assign CXB0_ = rst ? 0 : ~(0|XB0);
assign U214Pad3 = rst ? 0 : ~(0|U212Pad3|C45R);
assign U142Pad8 = rst ? 0 : ~(0|C53A|C52A|C47A|C33A|C36A|C37A|C32A|C26A|C27A|C57A|C56A|C46A|C42A|C43A);
assign U225Pad9 = rst ? 0 : ~(0|U213Pad3|U221Pad9);

endmodule
