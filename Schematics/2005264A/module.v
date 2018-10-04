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

// Gate A14-U147A
pullup(A14U147Pad1);
assign (highz1,strong0) #0.2  A14U147Pad1 = rst ? 0 : ~(0|T08|GOJAM|A14U142Pad6);
// Gate A14-U222A
pullup(XB2E);
assign (highz1,strong0) #0.2  XB2E = rst ? 0 : ~(0|XB2_);
// Gate A14-U243B
pullup(A14U241Pad6);
assign (highz1,strong0) #0.2  A14U241Pad6 = rst ? 0 : ~(0|XB6|XB5);
// Gate A14-U146B
pullup(A14U145Pad8);
assign (highz1,strong0) #0.2  A14U145Pad8 = rst ? 0 : ~(0|S08|A14U142Pad6|S09);
// Gate A14-U235A A14-U236A
pullup(RSCG_);
assign (highz1,strong0) #0.2  RSCG_ = rst ? 1 : ~(0|A14U234Pad1);
// Gate A14-U103B A14-U109A A14-U102B
pullup(ERAS);
assign (highz1,strong0) #0.2  ERAS = rst ? 0 : ~(0|S12|S11|TCSAJ3|MAMU|MP1|INOUT|GOJ1|CHINC);
// Gate A14-U217A A14-U215A A14-U218B
pullup(XB5_);
assign (highz1,strong0) #0.2  XB5_ = rst ? 1 : ~(0|XB5);
// Gate A14-U223B A14-U224A A14-U224B
pullup(XB2_);
assign (highz1,strong0) #0.2  XB2_ = rst ? 1 : ~(0|XB2);
// Gate A14-U255B
pullup(A14U250Pad2);
assign (highz1,strong0) #0.2  A14U250Pad2 = rst ? 1 : ~(0|S04_|S05_|S06);
// Gate A14-U116A
pullup(A14U116Pad1);
assign (highz1,strong0) #0.2  A14U116Pad1 = rst ? 0 : ~(0|GOJAM|A14U114Pad6|A14U115Pad9);
// Gate A14-U239B
pullup(ILP_);
assign (highz1,strong0) #0.2  ILP_ = rst ? 1 : ~(0|A14U237Pad2);
// Gate A14-U138A
pullup(A14U138Pad1);
assign (highz1,strong0) #0.2  A14U138Pad1 = rst ? 0 : ~(0|ROP_|T02_);
// Gate A14-U104A A14-U104B
pullup(ERAS_);
assign (highz1,strong0) #0.2  ERAS_ = rst ? 1 : ~(0|ERAS);
// Gate A14-U121B
pullup(A14U121Pad3);
assign (highz1,strong0) #0.2  A14U121Pad3 = rst ? 0 : ~(0|A14U121Pad6|TIMR|RSTK_);
// Gate A14-U117A
pullup(A14U116Pad8);
assign (highz1,strong0) #0.2  A14U116Pad8 = rst ? 0 : ~(0|T03_|ERAS_);
// Gate A14-U258A
pullup(XT0E);
assign (highz1,strong0) #0.2  XT0E = rst ? 0 : ~(0|XT0_);
// Gate A14-U123A
pullup(A14U121Pad6);
assign (highz1,strong0) #0.2  A14U121Pad6 = rst ? 0 : ~(0|PHS4_|T02_);
// Gate A14-U127A
pullup(A14U126Pad6);
assign (highz1,strong0) #0.2  A14U126Pad6 = rst ? 1 : ~(0|A14U124Pad9|A14U127Pad3);
// Gate A14-U128B
pullup(A14U126Pad2);
assign (highz1,strong0) #0.2  A14U126Pad2 = rst ? 1 : ~(0|A14U125Pad1|A14U128Pad1);
// Gate A14-U112B
pullup(A14U112Pad2);
assign (highz1,strong0) #0.2  A14U112Pad2 = rst ? 0 : ~(0|GOJAM|REDRST|A14U111Pad2);
// Gate A14-U210B
pullup(WL11_);
assign (highz1,strong0) #0.2  WL11_ = rst ? 1 : ~(0|WL11);
// Gate A14-U143A
pullup(A14U143Pad1);
assign (highz1,strong0) #0.2  A14U143Pad1 = rst ? 1 : ~(0|A14U143Pad2|CLEARB);
// Gate A14-U134A A14-U134B
pullup(CLROPE);
assign (highz1,strong0) #0.2  CLROPE = rst ? 0 : ~(0|A14U134Pad2);
// Gate A14-U130B
pullup(A14U130Pad2);
assign (highz1,strong0) #0.2  A14U130Pad2 = rst ? 0 : ~(0|A14U129Pad7|T01);
// Gate A14-U129A
pullup(A14U129Pad1);
assign (highz1,strong0) #0.2  A14U129Pad1 = rst ? 0 : ~(0|T12_|PHS3_);
// Gate A14-U119A A14-U119B
pullup(ZID);
assign (highz1,strong0) #0.2  ZID = rst ? 0 : ~(0|MYCLMP|A14U119Pad6);
// Gate A14-U130A
pullup(A14U129Pad7);
assign (highz1,strong0) #0.2  A14U129Pad7 = rst ? 1 : ~(0|A14U130Pad2|A14U129Pad1);
// Gate A14-U136A
pullup(A14U135Pad2);
assign (highz1,strong0) #0.2  A14U135Pad2 = rst ? 0 : ~(0|GOJAM|T07|A14U134Pad2);
// Gate A14-U126B
pullup(WEY);
assign (highz1,strong0) #0.2  WEY = rst ? 0 : ~(0|A14U126Pad6);
// Gate A14-U126A
pullup(WEX);
assign (highz1,strong0) #0.2  WEX = rst ? 0 : ~(0|A14U126Pad2);
// Gate A14-U136B
pullup(A14U135Pad4);
assign (highz1,strong0) #0.2  A14U135Pad4 = rst ? 0 : ~(0|A14U132Pad1|A14U136Pad7|T02_);
// Gate A14-U107B
pullup(A14U105Pad6);
assign (highz1,strong0) #0.2  A14U105Pad6 = rst ? 1 : ~(0|STBE|SBESET);
// Gate A14-U151A
pullup(SETCD);
assign (highz1,strong0) #0.2  SETCD = rst ? 0 : ~(0|SETCD_);
// Gate A14-U106A
pullup(TPARG_);
assign (highz1,strong0) #0.2  TPARG_ = rst ? 1 : ~(0|TPGE|TPGF);
// Gate A14-U213A
pullup(XB7);
assign (highz1,strong0) #0.2  XB7 = rst ? 0 : ~(0|S03_|S02_|S01_);
// Gate A14-U215B
pullup(XB6);
assign (highz1,strong0) #0.2  XB6 = rst ? 1 : ~(0|S02_|S03_|S01);
// Gate A14-U228B
pullup(XB1);
assign (highz1,strong0) #0.2  XB1 = rst ? 0 : ~(0|S01_|S02|S03);
// Gate A14-U230B
pullup(XB0);
assign (highz1,strong0) #0.2  XB0 = rst ? 0 : ~(0|S03|S02|S01);
// Gate A14-U223A
pullup(XB3);
assign (highz1,strong0) #0.2  XB3 = rst ? 0 : ~(0|S03|S01_|S02_);
// Gate A14-U116B
pullup(A14U114Pad6);
assign (highz1,strong0) #0.2  A14U114Pad6 = rst ? 1 : ~(0|A14U116Pad1|A14U116Pad8);
// Gate A14-U246B
pullup(XT7E);
assign (highz1,strong0) #0.2  XT7E = rst ? 0 : ~(0|XT7_);
// Gate A14-U245A
pullup(XT7_);
assign (highz1,strong0) #0.2  XT7_ = rst ? 1 : ~(0|XT7);
// Gate A14-U113A
pullup(A14U113Pad1);
assign (highz1,strong0) #0.2  A14U113Pad1 = rst ? 0 : ~(0|GOJAM|A14U111Pad6|REDRST);
// Gate A14-U205A
pullup(RILP1);
assign (highz1,strong0) #0.2  RILP1 = rst ? 0 : ~(0|YB0|YB3);
// Gate A14-U115A
pullup(A14U113Pad8);
assign (highz1,strong0) #0.2  A14U113Pad8 = rst ? 0 : ~(0|PHS3_|ERAS_|T03_);
// Gate A14-U137A
pullup(A14U136Pad7);
assign (highz1,strong0) #0.2  A14U136Pad7 = rst ? 1 : ~(0|ROP_);
// Gate A14-U227B
pullup(XB0E);
assign (highz1,strong0) #0.2  XB0E = rst ? 0 : ~(0|XB0_);
// Gate A14-U229A A14-U229B A14-U228A A14-U230A
pullup(XB0_);
assign (highz1,strong0) #0.2  XB0_ = rst ? 1 : ~(0|XB0);
// Gate A14-U113B
pullup(A14U111Pad6);
assign (highz1,strong0) #0.2  A14U111Pad6 = rst ? 1 : ~(0|A14U113Pad1|A14U113Pad8);
// Gate A14-U112A
pullup(A14U111Pad2);
assign (highz1,strong0) #0.2  A14U111Pad2 = rst ? 1 : ~(0|A14U112Pad2|A14U110Pad9);
// Gate A14-U242A
pullup(A14U237Pad8);
assign (highz1,strong0) #0.2  A14U237Pad8 = rst ? 1 : ~(0|RILP1|A14U240Pad9|A14U240Pad1);
// Gate A14-U244A
pullup(A14U237Pad7);
assign (highz1,strong0) #0.2  A14U237Pad7 = rst ? 0 : ~(0|A14U241Pad6|RILP1|A14U240Pad2);
// Gate A14-U225A
pullup(XB2);
assign (highz1,strong0) #0.2  XB2 = rst ? 0 : ~(0|S01|S03|S02_);
// Gate A14-U142A
pullup(A14U141Pad6);
assign (highz1,strong0) #0.2  A14U141Pad6 = rst ? 1 : ~(0|A14U142Pad2|CLEARC);
// Gate A14-U237A
pullup(A14U237Pad1);
assign (highz1,strong0) #0.2  A14U237Pad1 = rst ? 1 : ~(0|A14U237Pad2);
// Gate A14-U205B
pullup(YB2_);
assign (highz1,strong0) #0.2  YB2_ = rst ? 1 : ~(0|YB2);
// Gate A14-U142B
pullup(A14U139Pad2);
assign (highz1,strong0) #0.2  A14U139Pad2 = rst ? 0 : ~(0|A14U142Pad6|S09_|S08_);
// Gate A14-U222B
pullup(XB3E);
assign (highz1,strong0) #0.2  XB3E = rst ? 0 : ~(0|XB3_);
// Gate A14-U139A
pullup(A14U139Pad1);
assign (highz1,strong0) #0.2  A14U139Pad1 = rst ? 1 : ~(0|A14U139Pad2|CLEARD);
// Gate A14-U256A A14-U255A
pullup(XT2_);
assign (highz1,strong0) #0.2  XT2_ = rst ? 1 : ~(0|XT2);
// Gate A14-U160A A14-U160B
pullup(ROP_);
assign (highz1,strong0) #0.2  ROP_ = rst ? 0 : ~(0|S12|S11);
// Gate A14-U155B
pullup(A14U154Pad2);
assign (highz1,strong0) #0.2  A14U154Pad2 = rst ? 0 : ~(0|A14U153Pad3|A14U155Pad1|TIMR);
// Gate A14-U254A
pullup(XT2E);
assign (highz1,strong0) #0.2  XT2E = rst ? 0 : ~(0|XT2_);
// Gate A14-U254B
pullup(XT3E);
assign (highz1,strong0) #0.2  XT3E = rst ? 1 : ~(0|XT3_);
// Gate A14-U203B
pullup(YB2E);
assign (highz1,strong0) #0.2  YB2E = rst ? 0 : ~(0|YB2_);
// Gate A14-U247B
pullup(XT7);
assign (highz1,strong0) #0.2  XT7 = rst ? 0 : ~(0|S04_|S06_|S05_);
// Gate A14-U245B
pullup(WL16_);
assign (highz1,strong0) #0.2  WL16_ = rst ? 1 : ~(0|WL16);
// Gate A14-U110A
pullup(REDRST);
assign (highz1,strong0) #0.2  REDRST = rst ? 0 : ~(0|T05|A14U101Pad9);
// Gate A14-U248B
pullup(XT6);
assign (highz1,strong0) #0.2  XT6 = rst ? 0 : ~(0|S05_|S06_|S04);
// Gate A14-U145B
pullup(A14U144Pad6);
assign (highz1,strong0) #0.2  A14U144Pad6 = rst ? 1 : ~(0|CLEARA|A14U145Pad8);
// Gate A14-U148B
pullup(STBF);
assign (highz1,strong0) #0.2  STBF = rst ? 0 : ~(0|GOJAM|A14U148Pad1|A14U148Pad8);
// Gate A14-U106B
pullup(STBE);
assign (highz1,strong0) #0.2  STBE = rst ? 0 : ~(0|A14U105Pad6|GOJAM|T05);
// Gate A14-U157B
pullup(A14U156Pad2);
assign (highz1,strong0) #0.2  A14U156Pad2 = rst ? 1 : ~(0|A14U157Pad1|A14U157Pad8);
// Gate A14-U232A A14-U233A A14-U233B
pullup(R1C);
assign (highz1,strong0) #0.2  R1C = rst ? 0 : ~(0|R1C_);
// Gate A14-U234B A14-U235B
pullup(WSCG_);
assign (highz1,strong0) #0.2  WSCG_ = rst ? 1 : ~(0|A14U234Pad8);
// Gate A14-U135A A14-U135B
pullup(A14U134Pad2);
assign (highz1,strong0) #0.2  A14U134Pad2 = rst ? 1 : ~(0|A14U135Pad2|A14U135Pad4);
// Gate A14-U221A A14-U221B A14-U220B
pullup(XB3_);
assign (highz1,strong0) #0.2  XB3_ = rst ? 1 : ~(0|XB3);
// Gate A14-U152B
pullup(SETCD_);
assign (highz1,strong0) #0.2  SETCD_ = rst ? 1 : ~(0|A14U152Pad8);
// Gate A14-U240B
pullup(A14U240Pad9);
assign (highz1,strong0) #0.2  A14U240Pad9 = rst ? 0 : ~(0|A14U240Pad8);
// Gate A14-U114A A14-U114B
pullup(SETEK);
assign (highz1,strong0) #0.2  SETEK = rst ? 0 : ~(0|MYCLMP|A14U114Pad6);
// Gate A14-U204A
pullup(YB3_);
assign (highz1,strong0) #0.2  YB3_ = rst ? 0 : ~(0|YB3);
// Gate A14-U209A
pullup(YB0);
assign (highz1,strong0) #0.2  YB0 = rst ? 0 : ~(0|S07|S08);
// Gate A14-U206A
pullup(YB1);
assign (highz1,strong0) #0.2  YB1 = rst ? 0 : ~(0|S07_|S08);
// Gate A14-U206B
pullup(YB2);
assign (highz1,strong0) #0.2  YB2 = rst ? 0 : ~(0|S07|S08_);
// Gate A14-U243A A14-U244B
pullup(A14U240Pad2);
assign (highz1,strong0) #0.2  A14U240Pad2 = rst ? 1 : ~(0|XT6|XT5|XT0|XT3);
// Gate A14-U146A
pullup(A14U146Pad1);
assign (highz1,strong0) #0.2  A14U146Pad1 = rst ? 0 : ~(0|PHS3_|T05_|ROP_);
// Gate A14-U232B
pullup(BR12B_);
assign (highz1,strong0) #0.2  BR12B_ = rst ? 1 : ~(0|BR12B);
// Gate A14-U226A A14-U226B A14-U225B
pullup(XB1_);
assign (highz1,strong0) #0.2  XB1_ = rst ? 1 : ~(0|XB1);
// Gate A14-U203A
pullup(YB3E);
assign (highz1,strong0) #0.2  YB3E = rst ? 1 : ~(0|YB3_);
// Gate A14-U111A
pullup(REX);
assign (highz1,strong0) #0.2  REX = rst ? 0 : ~(0|A14U111Pad2);
// Gate A14-U111B
pullup(REY);
assign (highz1,strong0) #0.2  REY = rst ? 0 : ~(0|A14U111Pad6);
// Gate A14-U144B
pullup(RESETA);
assign (highz1,strong0) #0.2  RESETA = rst ? 0 : ~(0|A14U144Pad6);
// Gate A14-U141B
pullup(RESETC);
assign (highz1,strong0) #0.2  RESETC = rst ? 0 : ~(0|A14U141Pad6);
// Gate A14-U144A
pullup(RESETB);
assign (highz1,strong0) #0.2  RESETB = rst ? 0 : ~(0|A14U143Pad1);
// Gate A14-U141A
pullup(RESETD);
assign (highz1,strong0) #0.2  RESETD = rst ? 0 : ~(0|A14U139Pad1);
// Gate A14-U238A
pullup(ILP);
assign (highz1,strong0) #0.2  ILP = rst ? 0 : ~(0|A14U237Pad1);
// Gate A14-U154A
pullup(A14U153Pad3);
assign (highz1,strong0) #0.2  A14U153Pad3 = rst ? 1 : ~(0|A14U154Pad2|A14U154Pad3);
// Gate A14-U143B
pullup(A14U142Pad2);
assign (highz1,strong0) #0.2  A14U142Pad2 = rst ? 0 : ~(0|S09_|A14U142Pad6|S08);
// Gate A14-U147B
pullup(A14U142Pad6);
assign (highz1,strong0) #0.2  A14U142Pad6 = rst ? 1 : ~(0|A14U146Pad1|A14U147Pad1);
// Gate A14-U210A A14-U211B
pullup(XB7_);
assign (highz1,strong0) #0.2  XB7_ = rst ? 1 : ~(0|XB7);
// Gate A14-U249A
pullup(XT4E);
assign (highz1,strong0) #0.2  XT4E = rst ? 0 : ~(0|XT4_);
// Gate A14-U251B
pullup(XT5);
assign (highz1,strong0) #0.2  XT5 = rst ? 0 : ~(0|S05|S06_|S04_);
// Gate A14-U252A
pullup(XT4);
assign (highz1,strong0) #0.2  XT4 = rst ? 0 : ~(0|S05|S04|S06_);
// Gate A14-U256B
pullup(XT2);
assign (highz1,strong0) #0.2  XT2 = rst ? 0 : ~(0|S05_|S06|S04);
// Gate A14-U259A
pullup(XT1);
assign (highz1,strong0) #0.2  XT1 = rst ? 0 : ~(0|S05|S06|S04_);
// Gate A14-U202B
pullup(RILP1_);
assign (highz1,strong0) #0.2  RILP1_ = rst ? 1 : ~(0|RILP1);
// Gate A14-U133A
pullup(WHOMPA);
assign (highz1,strong0) #0.2  WHOMPA = rst ? 0 : ~(0|WHOMP_);
// Gate A14-U123B
pullup(A14U121Pad2);
assign (highz1,strong0) #0.2  A14U121Pad2 = rst ? 0 : ~(0|FNERAS_|PHS3_|T10_);
// Gate A14-U159B
pullup(A14U159Pad2);
assign (highz1,strong0) #0.2  A14U159Pad2 = rst ? 0 : ~(0|PHS3_|T08_);
// Gate A14-U121A
pullup(RSTK_);
assign (highz1,strong0) #0.2  RSTK_ = rst ? 1 : ~(0|A14U121Pad2|A14U121Pad3);
// Gate A14-U218A
pullup(XB5);
assign (highz1,strong0) #0.2  XB5 = rst ? 0 : ~(0|S02|S01_|S03_);
// Gate A14-U212B
pullup(XB7E);
assign (highz1,strong0) #0.2  XB7E = rst ? 0 : ~(0|XB7_);
// Gate A14-U252B A14-U251A
pullup(XT4_);
assign (highz1,strong0) #0.2  XT4_ = rst ? 1 : ~(0|XT4);
// Gate A14-U231A
pullup(CXB1_);
assign (highz1,strong0) #0.2  CXB1_ = rst ? 1 : ~(0|XB1);
// Gate A14-U231B
pullup(NOTEST);
assign (highz1,strong0) #0.2  NOTEST = rst ? 1 : ~(0|NOTEST_);
// Gate A14-U122A
pullup(A14U120Pad2);
assign (highz1,strong0) #0.2  A14U120Pad2 = rst ? 0 : ~(0|FNERAS_|T10_);
// Gate A14-U120B
pullup(A14U120Pad3);
assign (highz1,strong0) #0.2  A14U120Pad3 = rst ? 0 : ~(0|A14U119Pad6|T01|TIMR);
// Gate A14-U132A
pullup(A14U132Pad1);
assign (highz1,strong0) #0.2  A14U132Pad1 = rst ? 1 : ~(0|A14U132Pad2|A14U132Pad3);
// Gate A14-U132B
pullup(A14U132Pad3);
assign (highz1,strong0) #0.2  A14U132Pad3 = rst ? 0 : ~(0|ROP_|T10_);
// Gate A14-U133B
pullup(A14U132Pad2);
assign (highz1,strong0) #0.2  A14U132Pad2 = rst ? 0 : ~(0|A14U132Pad1|GOJAM|T03);
// Gate A14-U260A A14-U259B
pullup(XT0_);
assign (highz1,strong0) #0.2  XT0_ = rst ? 1 : ~(0|XT0);
// Gate A14-U125A
pullup(A14U125Pad1);
assign (highz1,strong0) #0.2  A14U125Pad1 = rst ? 0 : ~(0|T10|A14U124Pad4);
// Gate A14-U125B
pullup(A14U124Pad4);
assign (highz1,strong0) #0.2  A14U124Pad4 = rst ? 1 : ~(0|A14U121Pad2|A14U124Pad1);
// Gate A14-U148A
pullup(A14U148Pad1);
assign (highz1,strong0) #0.2  A14U148Pad1 = rst ? 0 : ~(0|T07_|PHS3_);
// Gate A14-U124A
pullup(A14U124Pad1);
assign (highz1,strong0) #0.2  A14U124Pad1 = rst ? 0 : ~(0|T11|TIMR|A14U124Pad4);
// Gate A14-U118B
pullup(A14U118Pad3);
assign (highz1,strong0) #0.2  A14U118Pad3 = rst ? 0 : ~(0|FNERAS_|GOJAM|T12A);
// Gate A14-U220A
pullup(XB4);
assign (highz1,strong0) #0.2  XB4 = rst ? 0 : ~(0|S01|S02|S03_);
// Gate A14-U153A
pullup(A14U152Pad2);
assign (highz1,strong0) #0.2  A14U152Pad2 = rst ? 0 : ~(0|S09|A14U153Pad3);
// Gate A14-U149B
pullup(A14U148Pad8);
assign (highz1,strong0) #0.2  A14U148Pad8 = rst ? 1 : ~(0|STBF|SBFSET);
// Gate A14-U238B
pullup(SBYREL_);
assign (highz1,strong0) #0.2  SBYREL_ = rst ? 0 : ~(0|SBY);
// Gate A14-U124B
pullup(A14U124Pad9);
assign (highz1,strong0) #0.2  A14U124Pad9 = rst ? 0 : ~(0|T10_|FNERAS_|PHS4_);
// Gate A14-U138B
pullup(A14U137Pad6);
assign (highz1,strong0) #0.2  A14U137Pad6 = rst ? 1 : ~(0|STRGAT|A14U138Pad1);
// Gate A14-U213B A14-U214A A14-U214B
pullup(XB6_);
assign (highz1,strong0) #0.2  XB6_ = rst ? 0 : ~(0|XB6);
// Gate A14-U207B
pullup(YB1_);
assign (highz1,strong0) #0.2  YB1_ = rst ? 1 : ~(0|YB1);
// Gate A14-U247A
pullup(XT6_);
assign (highz1,strong0) #0.2  XT6_ = rst ? 1 : ~(0|XT6);
// Gate A14-U117B
pullup(A14U117Pad9);
assign (highz1,strong0) #0.2  A14U117Pad9 = rst ? 0 : ~(0|T05_|ERAS_);
// Gate A14-U253A A14-U253B A14-U250A
pullup(XT3_);
assign (highz1,strong0) #0.2  XT3_ = rst ? 0 : ~(0|A14U250Pad2);
// Gate A14-U108B
pullup(A14U101Pad7);
assign (highz1,strong0) #0.2  A14U101Pad7 = rst ? 0 : ~(0|A14U101Pad9|T06);
// Gate A14-U240A
pullup(A14U240Pad1);
assign (highz1,strong0) #0.2  A14U240Pad1 = rst ? 0 : ~(0|A14U240Pad2);
// Gate A14-U241A
pullup(A14U240Pad8);
assign (highz1,strong0) #0.2  A14U240Pad8 = rst ? 1 : ~(0|XB3|XB0);
// Gate A14-U150B
pullup(SBF);
assign (highz1,strong0) #0.2  SBF = rst ? 0 : ~(0|A14U148Pad8);
// Gate A14-U101A
pullup(A14U101Pad1);
assign (highz1,strong0) #0.2  A14U101Pad1 = rst ? 0 : ~(0|PHS3_|T05_);
// Gate A14-U105B
pullup(SBE);
assign (highz1,strong0) #0.2  SBE = rst ? 0 : ~(0|A14U105Pad6);
// Gate A14-U212A
pullup(XB6E);
assign (highz1,strong0) #0.2  XB6E = rst ? 1 : ~(0|XB6_);
// Gate A14-U120A
pullup(A14U119Pad6);
assign (highz1,strong0) #0.2  A14U119Pad6 = rst ? 1 : ~(0|A14U120Pad2|A14U120Pad3);
// Gate A14-U156A
pullup(IHENV);
assign (highz1,strong0) #0.2  IHENV = rst ? 0 : ~(0|A14U156Pad2);
// Gate A14-U101B
pullup(A14U101Pad9);
assign (highz1,strong0) #0.2  A14U101Pad9 = rst ? 1 : ~(0|A14U101Pad7|A14U101Pad1);
// Gate A14-U208A
pullup(YB1E);
assign (highz1,strong0) #0.2  YB1E = rst ? 0 : ~(0|YB1_);
// Gate A14-U216B
pullup(XB5E);
assign (highz1,strong0) #0.2  XB5E = rst ? 0 : ~(0|XB5_);
// Gate A14-U204B
pullup(YB3);
assign (highz1,strong0) #0.2  YB3 = rst ? 1 : ~(0|S08_|S07_);
// Gate A14-U110B
pullup(A14U110Pad9);
assign (highz1,strong0) #0.2  A14U110Pad9 = rst ? 0 : ~(0|ERAS_|PHS4_|T03_);
// Gate A14-U158A
pullup(A14U157Pad8);
assign (highz1,strong0) #0.2  A14U157Pad8 = rst ? 0 : ~(0|T08|ROP_|A14U158Pad4);
// Gate A14-U115B
pullup(A14U115Pad9);
assign (highz1,strong0) #0.2  A14U115Pad9 = rst ? 0 : ~(0|PHS3_|T06_);
// Gate A14-U157A
pullup(A14U157Pad1);
assign (highz1,strong0) #0.2  A14U157Pad1 = rst ? 0 : ~(0|A14U155Pad1|TIMR|A14U156Pad2);
// Gate A14-U145A
pullup(A14U143Pad2);
assign (highz1,strong0) #0.2  A14U143Pad2 = rst ? 0 : ~(0|S09|S08_|A14U142Pad6);
// Gate A14-U258B
pullup(XT1E);
assign (highz1,strong0) #0.2  XT1E = rst ? 0 : ~(0|XT1_);
// Gate A14-U156B
pullup(A14J1Pad109);
assign (highz1,strong0) #0.2  A14J1Pad109 = rst ? 1 : ~(0);
// Gate A14-U137B
pullup(STRGAT);
assign (highz1,strong0) #0.2  STRGAT = rst ? 0 : ~(0|A14U137Pad6|T08|GOJAM);
// Gate A14-U108A
pullup(SBESET);
assign (highz1,strong0) #0.2  SBESET = rst ? 0 : ~(0|T04_|ERAS_|SCAD);
// Gate A14-U241B
pullup(A14U239Pad2);
assign (highz1,strong0) #0.2  A14U239Pad2 = rst ? 0 : ~(0|A14U241Pad6|A14U240Pad1|RILP1_);
// Gate A14-U155A
pullup(A14U155Pad1);
assign (highz1,strong0) #0.2  A14U155Pad1 = rst ? 0 : ~(0|T01_);
// Gate A14-U248A
pullup(RB1);
assign (highz1,strong0) #0.2  RB1 = rst ? 0 : ~(0|RB1_);
// Gate A14-U239A A14-U237B
pullup(A14U237Pad2);
assign (highz1,strong0) #0.2  A14U237Pad2 = rst ? 0 : ~(0|A14U239Pad2|A14U239Pad3|A14U237Pad7|A14U237Pad8);
// Gate A14-U122B
pullup(NOTEST_);
assign (highz1,strong0) #0.2  NOTEST_ = rst ? 0 : ~(0|PSEUDO|NISQL_);
// Gate A14-U236B
pullup(A14U234Pad8);
assign (highz1,strong0) #0.2  A14U234Pad8 = rst ? 0 : ~(0|SCAD_|WSC_);
// Gate A14-U257A A14-U257B
pullup(XT1_);
assign (highz1,strong0) #0.2  XT1_ = rst ? 1 : ~(0|XT1);
// Gate A14-U152A
pullup(SETAB_);
assign (highz1,strong0) #0.2  SETAB_ = rst ? 1 : ~(0|A14U152Pad2);
// Gate A14-U234A
pullup(A14U234Pad1);
assign (highz1,strong0) #0.2  A14U234Pad1 = rst ? 0 : ~(0|RSC_|SCAD_|RT_);
// Gate A14-U208B
pullup(YB0E);
assign (highz1,strong0) #0.2  YB0E = rst ? 0 : ~(0|YB0_);
// Gate A14-U260B
pullup(XT0);
assign (highz1,strong0) #0.2  XT0 = rst ? 0 : ~(0|S04|S06|S05);
// Gate A14-U154B
pullup(A14U154Pad3);
assign (highz1,strong0) #0.2  A14U154Pad3 = rst ? 0 : ~(0|ROP_|PHS4_|T10_);
// Gate A14-U118A
pullup(FNERAS_);
assign (highz1,strong0) #0.2  FNERAS_ = rst ? 1 : ~(0|A14U117Pad9|A14U118Pad3);
// Gate A14-U107A A14-U105A
pullup(TPGE);
assign (highz1,strong0) #0.2  TPGE = rst ? 0 : ~(0|SCAD|GOJAM|ERAS_|PHS3_|T05_);
// Gate A14-U227A
pullup(XB1E);
assign (highz1,strong0) #0.2  XB1E = rst ? 0 : ~(0|XB1_);
// Gate A14-U139B A14-U140A A14-U140B
pullup(TPGF);
assign (highz1,strong0) #0.2  TPGF = rst ? 0 : ~(0|T08_|DV3764|ROP_|TCSAJ3|GOJAM|GOJ1|PHS2_|MP1);
// Gate A14-U158B
pullup(A14U158Pad9);
assign (highz1,strong0) #0.2  A14U158Pad9 = rst ? 0 : ~(0|A14U158Pad4|T09|GOJAM);
// Gate A14-U209B
pullup(YB0_);
assign (highz1,strong0) #0.2  YB0_ = rst ? 1 : ~(0|YB0);
// Gate A14-U159A
pullup(A14U158Pad4);
assign (highz1,strong0) #0.2  A14U158Pad4 = rst ? 1 : ~(0|A14U159Pad2|A14U158Pad9);
// Gate A14-U249B
pullup(XT5E);
assign (highz1,strong0) #0.2  XT5E = rst ? 0 : ~(0|XT5_);
// Gate A14-U151B
pullup(SETAB);
assign (highz1,strong0) #0.2  SETAB = rst ? 0 : ~(0|SETAB_);
// Gate A14-U217B A14-U219A A14-U219B
pullup(XB4_);
assign (highz1,strong0) #0.2  XB4_ = rst ? 1 : ~(0|XB4);
// Gate A14-U150A A14-U149A
pullup(SBFSET);
assign (highz1,strong0) #0.2  SBFSET = rst ? 0 : ~(0|T06_|DV3764|ROP_|PHS4_|MNHSBF|MP1);
// Gate A14-U128A
pullup(A14U128Pad1);
assign (highz1,strong0) #0.2  A14U128Pad1 = rst ? 0 : ~(0|A14U127Pad6|A14U126Pad2|TIMR);
// Gate A14-U246A
pullup(XT6E);
assign (highz1,strong0) #0.2  XT6E = rst ? 0 : ~(0|XT6_);
// Gate A14-U129B
pullup(A14U127Pad6);
assign (highz1,strong0) #0.2  A14U127Pad6 = rst ? 0 : ~(0|A14U129Pad7|T12A);
// Gate A14-U153B
pullup(A14U152Pad8);
assign (highz1,strong0) #0.2  A14U152Pad8 = rst ? 0 : ~(0|A14U153Pad3|S09_);
// Gate A14-U127B
pullup(A14U127Pad3);
assign (highz1,strong0) #0.2  A14U127Pad3 = rst ? 0 : ~(0|A14U127Pad6|A14U126Pad6|TIMR);
// Gate A14-U250B
pullup(XT5_);
assign (highz1,strong0) #0.2  XT5_ = rst ? 1 : ~(0|XT5);
// Gate A14-U242B
pullup(A14U239Pad3);
assign (highz1,strong0) #0.2  A14U239Pad3 = rst ? 0 : ~(0|A14U240Pad9|A14U240Pad2|RILP1_);
// Gate A14-U216A
pullup(XB4E);
assign (highz1,strong0) #0.2  XB4E = rst ? 0 : ~(0|XB4_);

endmodule
