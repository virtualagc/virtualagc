// Verilog module auto-generated for AGC module A14 by dumbVerilog.py

module A14 ( 
  rst, BR12B, CGA14, CHINC, CLEARA, CLEARB, CLEARC, CLEARD, DV3764, GOJ1,
  GOJAM, INOUT, MAMU, MNHSBF, MP1, MYCLMP, NISQL_, PHS2_, PHS3_, PHS4_, PSEUDO,
  R1C_, RB1_, RSC_, RT_, S01, S01_, S02, S02_, S03, S03_, S04, S04_, S05,
  S05_, S06, S06_, S07, S07_, S08, S08_, S09, S09_, S11, S12, SBY, SCAD,
  SCAD_, T01, T01_, T02_, T03, T03_, T04_, T05, T05_, T06, T06_, T07, T07_,
  T08, T08_, T09, T10, T10_, T11, T12A, T12_, TCSAJ3, TIMR, WHOMP_, WL11,
  WL16, WSC_, BR12B_, CLROPE, ERAS, IHENV, ILP, ILP_, NOTEST_, RESETA, RESETB,
  RESETC, RESETD, REX, REY, RILP1, RILP1_, SBE, SBF, SBYREL_, SETAB, SETCD,
  SETEK, WEX, WEY, WL11_, WL16_, XB0, XB0E, XB1, XB1E, XB2E, XB3, XB3E, XB4E,
  XB5, XB5E, XB6, XB6E, XB7E, XT0E, XT1E, XT2E, XT3E, XT4E, XT5E, XT6E, XT7E,
  YB0E, YB1E, YB2E, YB3E, ZID, CXB1_, ERAS_, FNERAS_, NOTEST, R1C, RB1, REDRST,
  ROP_, RSCG_, RSTK_, SBESET, SBFSET, SETAB_, SETCD_, STBE, STBF, STRGAT,
  TPARG_, TPGE, TPGF, WHOMPA, WSCG_, XB0_, XB1_, XB2, XB2_, XB3_, XB4, XB4_,
  XB5_, XB6_, XB7, XB7_, XT0, XT0_, XT1, XT1_, XT2, XT2_, XT3, XT3_, XT4,
  XT4_, XT5, XT5_, XT6, XT6_, XT7, XT7_, YB0, YB0_, YB1, YB1_, YB2, YB2_,
  YB3, YB3_
);

input wire rst, BR12B, CGA14, CHINC, CLEARA, CLEARB, CLEARC, CLEARD, DV3764,
  GOJ1, GOJAM, INOUT, MAMU, MNHSBF, MP1, MYCLMP, NISQL_, PHS2_, PHS3_, PHS4_,
  PSEUDO, R1C_, RB1_, RSC_, RT_, S01, S01_, S02, S02_, S03, S03_, S04, S04_,
  S05, S05_, S06, S06_, S07, S07_, S08, S08_, S09, S09_, S11, S12, SBY, SCAD,
  SCAD_, T01, T01_, T02_, T03, T03_, T04_, T05, T05_, T06, T06_, T07, T07_,
  T08, T08_, T09, T10, T10_, T11, T12A, T12_, TCSAJ3, TIMR, WHOMP_, WL11,
  WL16, WSC_;

inout wire BR12B_, CLROPE, ERAS, IHENV, ILP, ILP_, NOTEST_, RESETA, RESETB,
  RESETC, RESETD, REX, REY, RILP1, RILP1_, SBE, SBF, SBYREL_, SETAB, SETCD,
  SETEK, WEX, WEY, WL11_, WL16_, XB0, XB0E, XB1, XB1E, XB2E, XB3, XB3E, XB4E,
  XB5, XB5E, XB6, XB6E, XB7E, XT0E, XT1E, XT2E, XT3E, XT4E, XT5E, XT6E, XT7E,
  YB0E, YB1E, YB2E, YB3E, ZID;

output wire CXB1_, ERAS_, FNERAS_, NOTEST, R1C, RB1, REDRST, ROP_, RSCG_,
  RSTK_, SBESET, SBFSET, SETAB_, SETCD_, STBE, STBF, STRGAT, TPARG_, TPGE,
  TPGF, WHOMPA, WSCG_, XB0_, XB1_, XB2, XB2_, XB3_, XB4, XB4_, XB5_, XB6_,
  XB7, XB7_, XT0, XT0_, XT1, XT1_, XT2, XT2_, XT3, XT3_, XT4, XT4_, XT5,
  XT5_, XT6, XT6_, XT7, XT7_, YB0, YB0_, YB1, YB1_, YB2, YB2_, YB3, YB3_;

assign #0.2  U121Pad6 = rst ? 0 : ~(0|PHS4_|T02_);
assign #0.2  XB2E = rst ? 0 : ~(0|XB2_);
assign #0.2  U121Pad2 = rst ? 0 : ~(0|FNERAS_|PHS3_|T10_);
assign #0.2  U121Pad3 = rst ? 0 : ~(0|U121Pad6|TIMR|RSTK_);
assign #0.2  XT4_ = rst ? 0 : ~(0|XT4);
assign #0.2  RSCG_ = rst ? 0 : ~(0|U234Pad1);
assign #0.2  ERAS = rst ? 0 : ~(0|S12|S11|TCSAJ3|MAMU|MP1|INOUT|GOJ1|CHINC);
assign #0.2  U111Pad6 = rst ? 0 : ~(0|U113Pad1|U113Pad8);
assign #0.2  XB5_ = rst ? 0 : ~(0|XB5);
assign #0.2  U111Pad2 = rst ? 0 : ~(0|U112Pad2|U110Pad9);
assign #0.2  ILP_ = rst ? 0 : ~(0|U237Pad2);
assign #0.2  ERAS_ = rst ? 0 : ~(0|ERAS);
assign #0.2  U129Pad7 = rst ? 0 : ~(0|U130Pad2|U129Pad1);
assign #0.2  U129Pad1 = rst ? 0 : ~(0|T12_|PHS3_);
assign #0.2  U141Pad6 = rst ? 0 : ~(0|U142Pad2|CLEARC);
assign #0.2  XT2E = rst ? 0 : ~(0|XT2_);
assign #0.2  WL11_ = rst ? 0 : ~(0|WL11);
assign #0.2  U136Pad7 = rst ? 0 : ~(0|ROP_);
assign #0.2  XB5E = rst ? 0 : ~(0|XB5_);
assign #0.2  CLROPE = rst ? 0 : ~(0|U134Pad2);
assign #0.2  XT5_ = rst ? 0 : ~(0|XT5);
assign #0.2  ZID = rst ? 0 : ~(0|MYCLMP|U119Pad6);
assign #0.2  WEY = rst ? 0 : ~(0|U126Pad6);
assign #0.2  WEX = rst ? 0 : ~(0|U126Pad2);
assign #0.2  U115Pad9 = rst ? 0 : ~(0|PHS3_|T06_);
assign #0.2  U117Pad9 = rst ? 0 : ~(0|T05_|ERAS_);
assign #0.2  SETCD = rst ? 0 : ~(0|SETCD_);
assign #0.2  TPARG_ = rst ? 0 : ~(0|TPGE|TPGF);
assign #0.2  XB7 = rst ? 0 : ~(0|S03_|S02_|S01_);
assign #0.2  XB6 = rst ? 0 : ~(0|S02_|S03_|S01);
assign #0.2  XB1 = rst ? 0 : ~(0|S01_|S02|S03);
assign #0.2  XB0 = rst ? 0 : ~(0|S03|S02|S01);
assign #0.2  XB3 = rst ? 0 : ~(0|S03|S01_|S02_);
assign #0.2  XB2 = rst ? 0 : ~(0|S01|S03|S02_);
assign #0.2  XT7E = rst ? 0 : ~(0|XT7_);
assign #0.2  XT7_ = rst ? 0 : ~(0|XT7);
assign #0.2  U118Pad3 = rst ? 0 : ~(0|FNERAS_|GOJAM|T12A);
assign #0.2  RILP1 = rst ? 0 : ~(0|YB0|YB3);
assign #0.2  U120Pad3 = rst ? 0 : ~(0|U119Pad6|T01|TIMR);
assign #0.2  U120Pad2 = rst ? 0 : ~(0|FNERAS_|T10_);
assign #0.2  XB0E = rst ? 0 : ~(0|XB0_);
assign #0.2  U126Pad2 = rst ? 0 : ~(0|U125Pad1|U128Pad1);
assign #0.2  U112Pad2 = rst ? 0 : ~(0|GOJAM|REDRST|U111Pad2);
assign #0.2  U126Pad6 = rst ? 0 : ~(0|U124Pad9|U127Pad3);
assign #0.2  SBYREL_ = rst ? 0 : ~(0|SBY);
assign #0.2  YB2_ = rst ? 0 : ~(0|YB2);
assign #0.2  XB3E = rst ? 0 : ~(0|XB3_);
assign #0.2  U237Pad8 = rst ? 0 : ~(0|RILP1|U240Pad9|U240Pad1);
assign #0.2  U237Pad7 = rst ? 0 : ~(0|U241Pad6|RILP1|U240Pad2);
assign #0.2  ROP_ = rst ? 0 : ~(0|S12|S11);
assign #0.2  U132Pad3 = rst ? 0 : ~(0|ROP_|T10_);
assign #0.2  U237Pad2 = rst ? 0 : ~(0|U239Pad2|U239Pad3|U237Pad7|U237Pad8);
assign #0.2  U237Pad1 = rst ? 0 : ~(0|U237Pad2);
assign #0.2  U119Pad6 = rst ? 0 : ~(0|U120Pad2|U120Pad3);
assign #0.2  U113Pad8 = rst ? 0 : ~(0|PHS3_|ERAS_|T03_);
assign #0.2  U127Pad3 = rst ? 0 : ~(0|U127Pad6|U126Pad6|TIMR);
assign #0.2  YB2E = rst ? 0 : ~(0|YB2_);
assign #0.2  XB2_ = rst ? 0 : ~(0|XB2);
assign #0.2  U127Pad6 = rst ? 0 : ~(0|U129Pad7|T12A);
assign #0.2  U113Pad1 = rst ? 0 : ~(0|GOJAM|U111Pad6|REDRST);
assign #0.2  U153Pad3 = rst ? 0 : ~(0|U154Pad2|U154Pad3);
assign #0.2  XT7 = rst ? 0 : ~(0|S04_|S06_|S05_);
assign #0.2  WL16_ = rst ? 0 : ~(0|WL16);
assign #0.2  U239Pad3 = rst ? 0 : ~(0|U240Pad9|U240Pad2|RILP1_);
assign #0.2  REDRST = rst ? 0 : ~(0|T05|U101Pad9);
assign #0.2  XT6 = rst ? 0 : ~(0|S05_|S06_|S04);
assign #0.2  U250Pad2 = rst ? 0 : ~(0|S04_|S05_|S06);
assign #0.2  U239Pad2 = rst ? 0 : ~(0|U241Pad6|U240Pad1|RILP1_);
assign #0.2  U154Pad3 = rst ? 0 : ~(0|ROP_|PHS4_|T10_);
assign #0.2  U156Pad2 = rst ? 0 : ~(0|U157Pad1|U157Pad8);
assign #0.2  STBF = rst ? 0 : ~(0|GOJAM|U148Pad1|U148Pad8);
assign #0.2  STBE = rst ? 0 : ~(0|U105Pad6|GOJAM|T05);
assign #0.2  U116Pad1 = rst ? 0 : ~(0|GOJAM|U114Pad6|U115Pad9);
assign #0.2  R1C = rst ? 0 : ~(0|R1C_);
assign #0.2  U157Pad1 = rst ? 0 : ~(0|U155Pad1|TIMR|U156Pad2);
assign #0.2  U116Pad8 = rst ? 0 : ~(0|T03_|ERAS_);
assign #0.2  U130Pad2 = rst ? 0 : ~(0|U129Pad7|T01);
assign #0.2  SETCD_ = rst ? 0 : ~(0|U152Pad8);
assign #0.2  U157Pad8 = rst ? 0 : ~(0|T08|ROP_|U158Pad4);
assign #0.2  U146Pad1 = rst ? 0 : ~(0|PHS3_|T05_|ROP_);
assign #0.2  SETEK = rst ? 0 : ~(0|MYCLMP|U114Pad6);
assign #0.2  YB3_ = rst ? 0 : ~(0|YB3);
assign #0.2  XB5 = rst ? 0 : ~(0|S02|S01_|S03_);
assign #0.2  U138Pad1 = rst ? 0 : ~(0|ROP_|T02_);
assign #0.2  YB0 = rst ? 0 : ~(0|S07|S08);
assign #0.2  YB1 = rst ? 0 : ~(0|S07_|S08);
assign #0.2  YB2 = rst ? 0 : ~(0|S07|S08_);
assign #0.2  YB3 = rst ? 0 : ~(0|S08_|S07_);
assign #0.2  U128Pad1 = rst ? 0 : ~(0|U127Pad6|U126Pad2|TIMR);
assign #0.2  U114Pad6 = rst ? 0 : ~(0|U116Pad1|U116Pad8);
assign #0.2  U241Pad6 = rst ? 0 : ~(0|XB6|XB5);
assign #0.2  XT1_ = rst ? 0 : ~(0|XT1);
assign #0.2  U148Pad8 = rst ? 0 : ~(0|STBF|SBFSET);
assign #0.2  U240Pad1 = rst ? 0 : ~(0|U240Pad2);
assign #0.2  YB3E = rst ? 0 : ~(0|YB3_);
assign #0.2  J1Pad109 = rst ? 0 : ~(0);
assign #0.2  U148Pad1 = rst ? 0 : ~(0|T07_|PHS3_);
assign #0.2  REX = rst ? 0 : ~(0|U111Pad2);
assign #0.2  REY = rst ? 0 : ~(0|U111Pad6);
assign #0.2  U144Pad6 = rst ? 0 : ~(0|CLEARA|U145Pad8);
assign #0.2  RESETA = rst ? 0 : ~(0|U144Pad6);
assign #0.2  RESETC = rst ? 0 : ~(0|U141Pad6);
assign #0.2  RESETB = rst ? 0 : ~(0|U143Pad1);
assign #0.2  RESETD = rst ? 0 : ~(0|U139Pad1);
assign #0.2  XT0E = rst ? 0 : ~(0|XT0_);
assign #0.2  ILP = rst ? 0 : ~(0|U237Pad1);
assign #0.2  XB7_ = rst ? 0 : ~(0|XB7);
assign #0.2  XT4E = rst ? 0 : ~(0|XT4_);
assign #0.2  XT5 = rst ? 0 : ~(0|S05|S06_|S04_);
assign #0.2  XT4 = rst ? 0 : ~(0|S05|S04|S06_);
assign #0.2  XT2 = rst ? 0 : ~(0|S05_|S06|S04);
assign #0.2  XT1 = rst ? 0 : ~(0|S05|S06|S04_);
assign #0.2  RILP1_ = rst ? 0 : ~(0|RILP1);
assign #0.2  XB3_ = rst ? 0 : ~(0|XB3);
assign #0.2  WHOMPA = rst ? 0 : ~(0|WHOMP_);
assign #0.2  U125Pad1 = rst ? 0 : ~(0|T10|U124Pad4);
assign #0.2  U101Pad9 = rst ? 0 : ~(0|U101Pad7|U101Pad1);
assign #0.2  RSTK_ = rst ? 0 : ~(0|U121Pad2|U121Pad3);
assign #0.2  XT3E = rst ? 0 : ~(0|XT3_);
assign #0.2  XB7E = rst ? 0 : ~(0|XB7_);
assign #0.2  U101Pad1 = rst ? 0 : ~(0|PHS3_|T05_);
assign #0.2  CXB1_ = rst ? 0 : ~(0|XB1);
assign #0.2  U101Pad7 = rst ? 0 : ~(0|U101Pad9|T06);
assign #0.2  NOTEST = rst ? 0 : ~(0|NOTEST_);
assign #0.2  XT0_ = rst ? 0 : ~(0|XT0);
assign #0.2  XB1E = rst ? 0 : ~(0|XB1_);
assign #0.2  U139Pad2 = rst ? 0 : ~(0|U142Pad6|S09_|S08_);
assign #0.2  U139Pad1 = rst ? 0 : ~(0|U139Pad2|CLEARD);
assign #0.2  U135Pad2 = rst ? 0 : ~(0|GOJAM|T07|U134Pad2);
assign #0.2  XB1_ = rst ? 0 : ~(0|XB1);
assign #0.2  U135Pad4 = rst ? 0 : ~(0|U132Pad1|U136Pad7|T02_);
assign #0.2  XT2_ = rst ? 0 : ~(0|XT2);
assign #0.2  XT1E = rst ? 0 : ~(0|XT1_);
assign #0.2  XB6_ = rst ? 0 : ~(0|XB6);
assign #0.2  YB1_ = rst ? 0 : ~(0|YB1);
assign #0.2  XB0_ = rst ? 0 : ~(0|XB0);
assign #0.2  U159Pad2 = rst ? 0 : ~(0|PHS3_|T08_);
assign #0.2  XB4 = rst ? 0 : ~(0|S01|S02|S03_);
assign #0.2  XT3_ = rst ? 0 : ~(0|U250Pad2);
assign #0.2  SBF = rst ? 0 : ~(0|U148Pad8);
assign #0.2  U154Pad2 = rst ? 0 : ~(0|U153Pad3|U155Pad1|TIMR);
assign #0.2  SBE = rst ? 0 : ~(0|U105Pad6);
assign #0.2  U134Pad2 = rst ? 0 : ~(0|U135Pad2|U135Pad4);
assign #0.2  XB6E = rst ? 0 : ~(0|XB6_);
assign #0.2  IHENV = rst ? 0 : ~(0|U156Pad2);
assign #0.2  YB1E = rst ? 0 : ~(0|YB1_);
assign #0.2  U234Pad1 = rst ? 0 : ~(0|RSC_|SCAD_|RT_);
assign #0.2  U110Pad9 = rst ? 0 : ~(0|ERAS_|PHS4_|T03_);
assign #0.2  U240Pad2 = rst ? 0 : ~(0|XT6|XT5|XT0|XT3);
assign #0.2  U105Pad6 = rst ? 0 : ~(0|STBE|SBESET);
assign #0.2  U240Pad8 = rst ? 0 : ~(0|XB3|XB0);
assign #0.2  U234Pad8 = rst ? 0 : ~(0|SCAD_|WSC_);
assign #0.2  WSCG_ = rst ? 0 : ~(0|U234Pad8);
assign #0.2  U147Pad1 = rst ? 0 : ~(0|T08|GOJAM|U142Pad6);
assign #0.2  U152Pad8 = rst ? 0 : ~(0|U153Pad3|S09_);
assign #0.2  STRGAT = rst ? 0 : ~(0|U137Pad6|T08|GOJAM);
assign #0.2  U152Pad2 = rst ? 0 : ~(0|S09|U153Pad3);
assign #0.2  SBESET = rst ? 0 : ~(0|T04_|ERAS_|SCAD);
assign #0.2  RB1 = rst ? 0 : ~(0|RB1_);
assign #0.2  U240Pad9 = rst ? 0 : ~(0|U240Pad8);
assign #0.2  XT5E = rst ? 0 : ~(0|XT5_);
assign #0.2  NOTEST_ = rst ? 0 : ~(0|PSEUDO|NISQL_);
assign #0.2  U155Pad1 = rst ? 0 : ~(0|T01_);
assign #0.2  U143Pad1 = rst ? 0 : ~(0|U143Pad2|CLEARB);
assign #0.2  U143Pad2 = rst ? 0 : ~(0|S09|S08_|U142Pad6);
assign #0.2  U137Pad6 = rst ? 0 : ~(0|STRGAT|U138Pad1);
assign #0.2  SETAB_ = rst ? 0 : ~(0|U152Pad2);
assign #0.2  XT6_ = rst ? 0 : ~(0|XT6);
assign #0.2  YB0E = rst ? 0 : ~(0|YB0_);
assign #0.2  XT0 = rst ? 0 : ~(0|S04|S06|S05);
assign #0.2  U132Pad1 = rst ? 0 : ~(0|U132Pad2|U132Pad3);
assign #0.2  U132Pad2 = rst ? 0 : ~(0|U132Pad1|GOJAM|T03);
assign #0.2  FNERAS_ = rst ? 0 : ~(0|U117Pad9|U118Pad3);
assign #0.2  TPGE = rst ? 0 : ~(0|SCAD|GOJAM|ERAS_|PHS3_|T05_);
assign #0.2  TPGF = rst ? 0 : ~(0|T08_|DV3764|ROP_|TCSAJ3|GOJAM|GOJ1|PHS2_|MP1);
assign #0.2  BR12B_ = rst ? 0 : ~(0|BR12B);
assign #0.2  YB0_ = rst ? 0 : ~(0|YB0);
assign #0.2  U158Pad9 = rst ? 0 : ~(0|U158Pad4|T09|GOJAM);
assign #0.2  U145Pad8 = rst ? 0 : ~(0|S08|U142Pad6|S09);
assign #0.2  SETAB = rst ? 0 : ~(0|SETAB_);
assign #0.2  XB4_ = rst ? 0 : ~(0|XB4);
assign #0.2  SBFSET = rst ? 0 : ~(0|T06_|DV3764|ROP_|PHS4_|MNHSBF|MP1);
assign #0.2  XT6E = rst ? 0 : ~(0|XT6_);
assign #0.2  U158Pad4 = rst ? 0 : ~(0|U159Pad2|U158Pad9);
assign #0.2  U124Pad1 = rst ? 0 : ~(0|T11|TIMR|U124Pad4);
assign #0.2  U142Pad6 = rst ? 0 : ~(0|U146Pad1|U147Pad1);
assign #0.2  U124Pad4 = rst ? 0 : ~(0|U121Pad2|U124Pad1);
assign #0.2  U142Pad2 = rst ? 0 : ~(0|S09_|U142Pad6|S08);
assign #0.2  U124Pad9 = rst ? 0 : ~(0|T10_|FNERAS_|PHS4_);
assign #0.2  XB4E = rst ? 0 : ~(0|XB4_);

endmodule
