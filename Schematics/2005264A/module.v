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

input wand rst, BR12B, CGA14, CHINC, CLEARA, CLEARB, CLEARC, CLEARD, DV3764,
  GOJ1, GOJAM, INOUT, MAMU, MNHSBF, MP1, MYCLMP, NISQL_, PHS2_, PHS3_, PHS4_,
  PSEUDO, R1C_, RB1_, RSC_, RT_, S01, S01_, S02, S02_, S03, S03_, S04, S04_,
  S05, S05_, S06, S06_, S07, S07_, S08, S08_, S09, S09_, S11, S12, SBY, SCAD,
  SCAD_, T01, T01_, T02_, T03, T03_, T04_, T05, T05_, T06, T06_, T07, T07_,
  T08, T08_, T09, T10, T10_, T11, T12A, T12_, TCSAJ3, TIMR, WHOMP_, WL11,
  WL16, WSC_;

inout wand BR12B_, CLROPE, ERAS, IHENV, ILP, ILP_, NOTEST_, RESETA, RESETB,
  RESETC, RESETD, REX, REY, RILP1, RILP1_, SBE, SBF, SBYREL_, SETAB, SETCD,
  SETEK, WEX, WEY, WL11_, WL16_, XB0, XB0E, XB1, XB1E, XB2E, XB3, XB3E, XB4E,
  XB5, XB5E, XB6, XB6E, XB7E, XT0E, XT1E, XT2E, XT3E, XT4E, XT5E, XT6E, XT7E,
  YB0E, YB1E, YB2E, YB3E, ZID;

output wand CXB1_, ERAS_, FNERAS_, NOTEST, R1C, RB1, REDRST, ROP_, RSCG_,
  RSTK_, SBESET, SBFSET, SETAB_, SETCD_, STBE, STBF, STRGAT, TPARG_, TPGE,
  TPGF, WHOMPA, WSCG_, XB0_, XB1_, XB2, XB2_, XB3_, XB4, XB4_, XB5_, XB6_,
  XB7, XB7_, XT0, XT0_, XT1, XT1_, XT2, XT2_, XT3, XT3_, XT4, XT4_, XT5,
  XT5_, XT6, XT6_, XT7, XT7_, YB0, YB0_, YB1, YB1_, YB2, YB2_, YB3, YB3_;

// Gate A14-U147A
assign #0.2  A14U147Pad1 = rst ? 0 : ~(0|T08|GOJAM|A14U142Pad6);
// Gate A14-U222A
assign #0.2  XB2E = rst ? 0 : ~(0|XB2_);
// Gate A14-U243B
assign #0.2  A14U241Pad6 = rst ? 0 : ~(0|XB6|XB5);
// Gate A14-U146B
assign #0.2  A14U145Pad8 = rst ? 0 : ~(0|S08|A14U142Pad6|S09);
// Gate A14-U235A A14-U236A
assign #0.2  RSCG_ = rst ? 1 : ~(0|A14U234Pad1);
// Gate A14-U103B A14-U109A A14-U102B
assign #0.2  ERAS = rst ? 0 : ~(0|S12|S11|TCSAJ3|MAMU|MP1|INOUT|GOJ1|CHINC);
// Gate A14-U217A A14-U215A A14-U218B
assign #0.2  XB5_ = rst ? 1 : ~(0|XB5);
// Gate A14-U223B A14-U224A A14-U224B
assign #0.2  XB2_ = rst ? 1 : ~(0|XB2);
// Gate A14-U255B
assign #0.2  A14U250Pad2 = rst ? 1 : ~(0|S04_|S05_|S06);
// Gate A14-U116A
assign #0.2  A14U116Pad1 = rst ? 0 : ~(0|GOJAM|A14U114Pad6|A14U115Pad9);
// Gate A14-U239B
assign #0.2  ILP_ = rst ? 1 : ~(0|A14U237Pad2);
// Gate A14-U138A
assign #0.2  A14U138Pad1 = rst ? 0 : ~(0|ROP_|T02_);
// Gate A14-U104A A14-U104B
assign #0.2  ERAS_ = rst ? 1 : ~(0|ERAS);
// Gate A14-U121B
assign #0.2  A14U121Pad3 = rst ? 0 : ~(0|A14U121Pad6|TIMR|RSTK_);
// Gate A14-U117A
assign #0.2  A14U116Pad8 = rst ? 0 : ~(0|T03_|ERAS_);
// Gate A14-U258A
assign #0.2  XT0E = rst ? 0 : ~(0|XT0_);
// Gate A14-U123A
assign #0.2  A14U121Pad6 = rst ? 0 : ~(0|PHS4_|T02_);
// Gate A14-U127A
assign #0.2  A14U126Pad6 = rst ? 1 : ~(0|A14U124Pad9|A14U127Pad3);
// Gate A14-U128B
assign #0.2  A14U126Pad2 = rst ? 1 : ~(0|A14U125Pad1|A14U128Pad1);
// Gate A14-U112B
assign #0.2  A14U112Pad2 = rst ? 0 : ~(0|GOJAM|REDRST|A14U111Pad2);
// Gate A14-U210B
assign #0.2  WL11_ = rst ? 1 : ~(0|WL11);
// Gate A14-U143A
assign #0.2  A14U143Pad1 = rst ? 1 : ~(0|A14U143Pad2|CLEARB);
// Gate A14-U134A A14-U134B
assign #0.2  CLROPE = rst ? 0 : ~(0|A14U134Pad2);
// Gate A14-U130B
assign #0.2  A14U130Pad2 = rst ? 0 : ~(0|A14U129Pad7|T01);
// Gate A14-U129A
assign #0.2  A14U129Pad1 = rst ? 0 : ~(0|T12_|PHS3_);
// Gate A14-U119A A14-U119B
assign #0.2  ZID = rst ? 0 : ~(0|MYCLMP|A14U119Pad6);
// Gate A14-U130A
assign #0.2  A14U129Pad7 = rst ? 1 : ~(0|A14U130Pad2|A14U129Pad1);
// Gate A14-U136A
assign #0.2  A14U135Pad2 = rst ? 0 : ~(0|GOJAM|T07|A14U134Pad2);
// Gate A14-U126B
assign #0.2  WEY = rst ? 0 : ~(0|A14U126Pad6);
// Gate A14-U126A
assign #0.2  WEX = rst ? 0 : ~(0|A14U126Pad2);
// Gate A14-U136B
assign #0.2  A14U135Pad4 = rst ? 0 : ~(0|A14U132Pad1|A14U136Pad7|T02_);
// Gate A14-U107B
assign #0.2  A14U105Pad6 = rst ? 1 : ~(0|STBE|SBESET);
// Gate A14-U151A
assign #0.2  SETCD = rst ? 0 : ~(0|SETCD_);
// Gate A14-U106A
assign #0.2  TPARG_ = rst ? 1 : ~(0|TPGE|TPGF);
// Gate A14-U213A
assign #0.2  XB7 = rst ? 0 : ~(0|S03_|S02_|S01_);
// Gate A14-U215B
assign #0.2  XB6 = rst ? 1 : ~(0|S02_|S03_|S01);
// Gate A14-U228B
assign #0.2  XB1 = rst ? 0 : ~(0|S01_|S02|S03);
// Gate A14-U230B
assign #0.2  XB0 = rst ? 0 : ~(0|S03|S02|S01);
// Gate A14-U223A
assign #0.2  XB3 = rst ? 0 : ~(0|S03|S01_|S02_);
// Gate A14-U116B
assign #0.2  A14U114Pad6 = rst ? 1 : ~(0|A14U116Pad1|A14U116Pad8);
// Gate A14-U246B
assign #0.2  XT7E = rst ? 0 : ~(0|XT7_);
// Gate A14-U245A
assign #0.2  XT7_ = rst ? 1 : ~(0|XT7);
// Gate A14-U113A
assign #0.2  A14U113Pad1 = rst ? 0 : ~(0|GOJAM|A14U111Pad6|REDRST);
// Gate A14-U205A
assign #0.2  RILP1 = rst ? 0 : ~(0|YB0|YB3);
// Gate A14-U115A
assign #0.2  A14U113Pad8 = rst ? 0 : ~(0|PHS3_|ERAS_|T03_);
// Gate A14-U137A
assign #0.2  A14U136Pad7 = rst ? 1 : ~(0|ROP_);
// Gate A14-U227B
assign #0.2  XB0E = rst ? 0 : ~(0|XB0_);
// Gate A14-U229A A14-U229B A14-U228A A14-U230A
assign #0.2  XB0_ = rst ? 1 : ~(0|XB0);
// Gate A14-U113B
assign #0.2  A14U111Pad6 = rst ? 1 : ~(0|A14U113Pad1|A14U113Pad8);
// Gate A14-U112A
assign #0.2  A14U111Pad2 = rst ? 1 : ~(0|A14U112Pad2|A14U110Pad9);
// Gate A14-U242A
assign #0.2  A14U237Pad8 = rst ? 1 : ~(0|RILP1|A14U240Pad9|A14U240Pad1);
// Gate A14-U244A
assign #0.2  A14U237Pad7 = rst ? 0 : ~(0|A14U241Pad6|RILP1|A14U240Pad2);
// Gate A14-U225A
assign #0.2  XB2 = rst ? 0 : ~(0|S01|S03|S02_);
// Gate A14-U142A
assign #0.2  A14U141Pad6 = rst ? 1 : ~(0|A14U142Pad2|CLEARC);
// Gate A14-U237A
assign #0.2  A14U237Pad1 = rst ? 1 : ~(0|A14U237Pad2);
// Gate A14-U205B
assign #0.2  YB2_ = rst ? 1 : ~(0|YB2);
// Gate A14-U142B
assign #0.2  A14U139Pad2 = rst ? 0 : ~(0|A14U142Pad6|S09_|S08_);
// Gate A14-U222B
assign #0.2  XB3E = rst ? 0 : ~(0|XB3_);
// Gate A14-U139A
assign #0.2  A14U139Pad1 = rst ? 1 : ~(0|A14U139Pad2|CLEARD);
// Gate A14-U256A A14-U255A
assign #0.2  XT2_ = rst ? 1 : ~(0|XT2);
// Gate A14-U160A A14-U160B
assign #0.2  ROP_ = rst ? 0 : ~(0|S12|S11);
// Gate A14-U155B
assign #0.2  A14U154Pad2 = rst ? 0 : ~(0|A14U153Pad3|A14U155Pad1|TIMR);
// Gate A14-U254A
assign #0.2  XT2E = rst ? 0 : ~(0|XT2_);
// Gate A14-U254B
assign #0.2  XT3E = rst ? 1 : ~(0|XT3_);
// Gate A14-U203B
assign #0.2  YB2E = rst ? 0 : ~(0|YB2_);
// Gate A14-U247B
assign #0.2  XT7 = rst ? 0 : ~(0|S04_|S06_|S05_);
// Gate A14-U245B
assign #0.2  WL16_ = rst ? 1 : ~(0|WL16);
// Gate A14-U110A
assign #0.2  REDRST = rst ? 0 : ~(0|T05|A14U101Pad9);
// Gate A14-U248B
assign #0.2  XT6 = rst ? 0 : ~(0|S05_|S06_|S04);
// Gate A14-U145B
assign #0.2  A14U144Pad6 = rst ? 1 : ~(0|CLEARA|A14U145Pad8);
// Gate A14-U148B
assign #0.2  STBF = rst ? 0 : ~(0|GOJAM|A14U148Pad1|A14U148Pad8);
// Gate A14-U106B
assign #0.2  STBE = rst ? 0 : ~(0|A14U105Pad6|GOJAM|T05);
// Gate A14-U157B
assign #0.2  A14U156Pad2 = rst ? 1 : ~(0|A14U157Pad1|A14U157Pad8);
// Gate A14-U232A A14-U233A A14-U233B
assign #0.2  R1C = rst ? 0 : ~(0|R1C_);
// Gate A14-U234B A14-U235B
assign #0.2  WSCG_ = rst ? 1 : ~(0|A14U234Pad8);
// Gate A14-U135A A14-U135B
assign #0.2  A14U134Pad2 = rst ? 1 : ~(0|A14U135Pad2|A14U135Pad4);
// Gate A14-U221A A14-U221B A14-U220B
assign #0.2  XB3_ = rst ? 1 : ~(0|XB3);
// Gate A14-U152B
assign #0.2  SETCD_ = rst ? 1 : ~(0|A14U152Pad8);
// Gate A14-U240B
assign #0.2  A14U240Pad9 = rst ? 0 : ~(0|A14U240Pad8);
// Gate A14-U114A A14-U114B
assign #0.2  SETEK = rst ? 0 : ~(0|MYCLMP|A14U114Pad6);
// Gate A14-U204A
assign #0.2  YB3_ = rst ? 0 : ~(0|YB3);
// Gate A14-U209A
assign #0.2  YB0 = rst ? 0 : ~(0|S07|S08);
// Gate A14-U206A
assign #0.2  YB1 = rst ? 0 : ~(0|S07_|S08);
// Gate A14-U206B
assign #0.2  YB2 = rst ? 0 : ~(0|S07|S08_);
// Gate A14-U243A A14-U244B
assign #0.2  A14U240Pad2 = rst ? 1 : ~(0|XT6|XT5|XT0|XT3);
// Gate A14-U146A
assign #0.2  A14U146Pad1 = rst ? 0 : ~(0|PHS3_|T05_|ROP_);
// Gate A14-U232B
assign #0.2  BR12B_ = rst ? 1 : ~(0|BR12B);
// Gate A14-U226A A14-U226B A14-U225B
assign #0.2  XB1_ = rst ? 1 : ~(0|XB1);
// Gate A14-U203A
assign #0.2  YB3E = rst ? 1 : ~(0|YB3_);
// Gate A14-U111A
assign #0.2  REX = rst ? 0 : ~(0|A14U111Pad2);
// Gate A14-U111B
assign #0.2  REY = rst ? 0 : ~(0|A14U111Pad6);
// Gate A14-U144B
assign #0.2  RESETA = rst ? 0 : ~(0|A14U144Pad6);
// Gate A14-U141B
assign #0.2  RESETC = rst ? 0 : ~(0|A14U141Pad6);
// Gate A14-U144A
assign #0.2  RESETB = rst ? 0 : ~(0|A14U143Pad1);
// Gate A14-U141A
assign #0.2  RESETD = rst ? 0 : ~(0|A14U139Pad1);
// Gate A14-U238A
assign #0.2  ILP = rst ? 0 : ~(0|A14U237Pad1);
// Gate A14-U154A
assign #0.2  A14U153Pad3 = rst ? 1 : ~(0|A14U154Pad2|A14U154Pad3);
// Gate A14-U143B
assign #0.2  A14U142Pad2 = rst ? 0 : ~(0|S09_|A14U142Pad6|S08);
// Gate A14-U147B
assign #0.2  A14U142Pad6 = rst ? 1 : ~(0|A14U146Pad1|A14U147Pad1);
// Gate A14-U210A A14-U211B
assign #0.2  XB7_ = rst ? 1 : ~(0|XB7);
// Gate A14-U249A
assign #0.2  XT4E = rst ? 0 : ~(0|XT4_);
// Gate A14-U251B
assign #0.2  XT5 = rst ? 0 : ~(0|S05|S06_|S04_);
// Gate A14-U252A
assign #0.2  XT4 = rst ? 0 : ~(0|S05|S04|S06_);
// Gate A14-U256B
assign #0.2  XT2 = rst ? 0 : ~(0|S05_|S06|S04);
// Gate A14-U259A
assign #0.2  XT1 = rst ? 0 : ~(0|S05|S06|S04_);
// Gate A14-U202B
assign #0.2  RILP1_ = rst ? 1 : ~(0|RILP1);
// Gate A14-U133A
assign #0.2  WHOMPA = rst ? 0 : ~(0|WHOMP_);
// Gate A14-U123B
assign #0.2  A14U121Pad2 = rst ? 0 : ~(0|FNERAS_|PHS3_|T10_);
// Gate A14-U159B
assign #0.2  A14U159Pad2 = rst ? 0 : ~(0|PHS3_|T08_);
// Gate A14-U121A
assign #0.2  RSTK_ = rst ? 1 : ~(0|A14U121Pad2|A14U121Pad3);
// Gate A14-U218A
assign #0.2  XB5 = rst ? 0 : ~(0|S02|S01_|S03_);
// Gate A14-U212B
assign #0.2  XB7E = rst ? 0 : ~(0|XB7_);
// Gate A14-U252B A14-U251A
assign #0.2  XT4_ = rst ? 1 : ~(0|XT4);
// Gate A14-U231A
assign #0.2  CXB1_ = rst ? 1 : ~(0|XB1);
// Gate A14-U231B
assign #0.2  NOTEST = rst ? 1 : ~(0|NOTEST_);
// Gate A14-U122A
assign #0.2  A14U120Pad2 = rst ? 0 : ~(0|FNERAS_|T10_);
// Gate A14-U120B
assign #0.2  A14U120Pad3 = rst ? 0 : ~(0|A14U119Pad6|T01|TIMR);
// Gate A14-U132A
assign #0.2  A14U132Pad1 = rst ? 1 : ~(0|A14U132Pad2|A14U132Pad3);
// Gate A14-U132B
assign #0.2  A14U132Pad3 = rst ? 0 : ~(0|ROP_|T10_);
// Gate A14-U133B
assign #0.2  A14U132Pad2 = rst ? 0 : ~(0|A14U132Pad1|GOJAM|T03);
// Gate A14-U260A A14-U259B
assign #0.2  XT0_ = rst ? 1 : ~(0|XT0);
// Gate A14-U125A
assign #0.2  A14U125Pad1 = rst ? 0 : ~(0|T10|A14U124Pad4);
// Gate A14-U125B
assign #0.2  A14U124Pad4 = rst ? 1 : ~(0|A14U121Pad2|A14U124Pad1);
// Gate A14-U148A
assign #0.2  A14U148Pad1 = rst ? 0 : ~(0|T07_|PHS3_);
// Gate A14-U124A
assign #0.2  A14U124Pad1 = rst ? 0 : ~(0|T11|TIMR|A14U124Pad4);
// Gate A14-U118B
assign #0.2  A14U118Pad3 = rst ? 0 : ~(0|FNERAS_|GOJAM|T12A);
// Gate A14-U220A
assign #0.2  XB4 = rst ? 0 : ~(0|S01|S02|S03_);
// Gate A14-U153A
assign #0.2  A14U152Pad2 = rst ? 0 : ~(0|S09|A14U153Pad3);
// Gate A14-U149B
assign #0.2  A14U148Pad8 = rst ? 1 : ~(0|STBF|SBFSET);
// Gate A14-U238B
assign #0.2  SBYREL_ = rst ? 0 : ~(0|SBY);
// Gate A14-U124B
assign #0.2  A14U124Pad9 = rst ? 0 : ~(0|T10_|FNERAS_|PHS4_);
// Gate A14-U138B
assign #0.2  A14U137Pad6 = rst ? 1 : ~(0|STRGAT|A14U138Pad1);
// Gate A14-U213B A14-U214A A14-U214B
assign #0.2  XB6_ = rst ? 0 : ~(0|XB6);
// Gate A14-U207B
assign #0.2  YB1_ = rst ? 1 : ~(0|YB1);
// Gate A14-U247A
assign #0.2  XT6_ = rst ? 1 : ~(0|XT6);
// Gate A14-U117B
assign #0.2  A14U117Pad9 = rst ? 0 : ~(0|T05_|ERAS_);
// Gate A14-U253A A14-U253B A14-U250A
assign #0.2  XT3_ = rst ? 0 : ~(0|A14U250Pad2);
// Gate A14-U108B
assign #0.2  A14U101Pad7 = rst ? 0 : ~(0|A14U101Pad9|T06);
// Gate A14-U240A
assign #0.2  A14U240Pad1 = rst ? 0 : ~(0|A14U240Pad2);
// Gate A14-U241A
assign #0.2  A14U240Pad8 = rst ? 1 : ~(0|XB3|XB0);
// Gate A14-U150B
assign #0.2  SBF = rst ? 0 : ~(0|A14U148Pad8);
// Gate A14-U101A
assign #0.2  A14U101Pad1 = rst ? 0 : ~(0|PHS3_|T05_);
// Gate A14-U105B
assign #0.2  SBE = rst ? 0 : ~(0|A14U105Pad6);
// Gate A14-U212A
assign #0.2  XB6E = rst ? 1 : ~(0|XB6_);
// Gate A14-U120A
assign #0.2  A14U119Pad6 = rst ? 1 : ~(0|A14U120Pad2|A14U120Pad3);
// Gate A14-U156A
assign #0.2  IHENV = rst ? 0 : ~(0|A14U156Pad2);
// Gate A14-U101B
assign #0.2  A14U101Pad9 = rst ? 1 : ~(0|A14U101Pad7|A14U101Pad1);
// Gate A14-U208A
assign #0.2  YB1E = rst ? 0 : ~(0|YB1_);
// Gate A14-U216B
assign #0.2  XB5E = rst ? 0 : ~(0|XB5_);
// Gate A14-U204B
assign #0.2  YB3 = rst ? 1 : ~(0|S08_|S07_);
// Gate A14-U110B
assign #0.2  A14U110Pad9 = rst ? 0 : ~(0|ERAS_|PHS4_|T03_);
// Gate A14-U158A
assign #0.2  A14U157Pad8 = rst ? 0 : ~(0|T08|ROP_|A14U158Pad4);
// Gate A14-U115B
assign #0.2  A14U115Pad9 = rst ? 0 : ~(0|PHS3_|T06_);
// Gate A14-U157A
assign #0.2  A14U157Pad1 = rst ? 0 : ~(0|A14U155Pad1|TIMR|A14U156Pad2);
// Gate A14-U145A
assign #0.2  A14U143Pad2 = rst ? 0 : ~(0|S09|S08_|A14U142Pad6);
// Gate A14-U258B
assign #0.2  XT1E = rst ? 0 : ~(0|XT1_);
// Gate A14-U156B
assign #0.2  A14J1Pad109 = rst ? 1 : ~(0);
// Gate A14-U137B
assign #0.2  STRGAT = rst ? 0 : ~(0|A14U137Pad6|T08|GOJAM);
// Gate A14-U108A
assign #0.2  SBESET = rst ? 0 : ~(0|T04_|ERAS_|SCAD);
// Gate A14-U241B
assign #0.2  A14U239Pad2 = rst ? 0 : ~(0|A14U241Pad6|A14U240Pad1|RILP1_);
// Gate A14-U155A
assign #0.2  A14U155Pad1 = rst ? 0 : ~(0|T01_);
// Gate A14-U248A
assign #0.2  RB1 = rst ? 0 : ~(0|RB1_);
// Gate A14-U239A A14-U237B
assign #0.2  A14U237Pad2 = rst ? 0 : ~(0|A14U239Pad2|A14U239Pad3|A14U237Pad7|A14U237Pad8);
// Gate A14-U122B
assign #0.2  NOTEST_ = rst ? 0 : ~(0|PSEUDO|NISQL_);
// Gate A14-U236B
assign #0.2  A14U234Pad8 = rst ? 0 : ~(0|SCAD_|WSC_);
// Gate A14-U257A A14-U257B
assign #0.2  XT1_ = rst ? 1 : ~(0|XT1);
// Gate A14-U152A
assign #0.2  SETAB_ = rst ? 1 : ~(0|A14U152Pad2);
// Gate A14-U234A
assign #0.2  A14U234Pad1 = rst ? 0 : ~(0|RSC_|SCAD_|RT_);
// Gate A14-U208B
assign #0.2  YB0E = rst ? 0 : ~(0|YB0_);
// Gate A14-U260B
assign #0.2  XT0 = rst ? 0 : ~(0|S04|S06|S05);
// Gate A14-U154B
assign #0.2  A14U154Pad3 = rst ? 0 : ~(0|ROP_|PHS4_|T10_);
// Gate A14-U118A
assign #0.2  FNERAS_ = rst ? 1 : ~(0|A14U117Pad9|A14U118Pad3);
// Gate A14-U107A A14-U105A
assign #0.2  TPGE = rst ? 0 : ~(0|SCAD|GOJAM|ERAS_|PHS3_|T05_);
// Gate A14-U227A
assign #0.2  XB1E = rst ? 0 : ~(0|XB1_);
// Gate A14-U139B A14-U140A A14-U140B
assign #0.2  TPGF = rst ? 0 : ~(0|T08_|DV3764|ROP_|TCSAJ3|GOJAM|GOJ1|PHS2_|MP1);
// Gate A14-U158B
assign #0.2  A14U158Pad9 = rst ? 0 : ~(0|A14U158Pad4|T09|GOJAM);
// Gate A14-U209B
assign #0.2  YB0_ = rst ? 1 : ~(0|YB0);
// Gate A14-U159A
assign #0.2  A14U158Pad4 = rst ? 1 : ~(0|A14U159Pad2|A14U158Pad9);
// Gate A14-U249B
assign #0.2  XT5E = rst ? 0 : ~(0|XT5_);
// Gate A14-U151B
assign #0.2  SETAB = rst ? 0 : ~(0|SETAB_);
// Gate A14-U217B A14-U219A A14-U219B
assign #0.2  XB4_ = rst ? 1 : ~(0|XB4);
// Gate A14-U150A A14-U149A
assign #0.2  SBFSET = rst ? 0 : ~(0|T06_|DV3764|ROP_|PHS4_|MNHSBF|MP1);
// Gate A14-U128A
assign #0.2  A14U128Pad1 = rst ? 0 : ~(0|A14U127Pad6|A14U126Pad2|TIMR);
// Gate A14-U246A
assign #0.2  XT6E = rst ? 0 : ~(0|XT6_);
// Gate A14-U129B
assign #0.2  A14U127Pad6 = rst ? 0 : ~(0|A14U129Pad7|T12A);
// Gate A14-U153B
assign #0.2  A14U152Pad8 = rst ? 0 : ~(0|A14U153Pad3|S09_);
// Gate A14-U127B
assign #0.2  A14U127Pad3 = rst ? 0 : ~(0|A14U127Pad6|A14U126Pad6|TIMR);
// Gate A14-U250B
assign #0.2  XT5_ = rst ? 1 : ~(0|XT5);
// Gate A14-U242B
assign #0.2  A14U239Pad3 = rst ? 0 : ~(0|A14U240Pad9|A14U240Pad2|RILP1_);
// Gate A14-U216A
assign #0.2  XB4E = rst ? 0 : ~(0|XB4_);

endmodule
