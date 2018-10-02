// Verilog module auto-generated for AGC module A24 by dumbVerilog.py

module A24 ( 
  rst, A15_, A16_, BMAGXM, BMAGXP, BMAGYM, BMAGYP, BMAGZP, CA6_, CDUXM, CDUXP,
  CDUYM, CDUYP, CDUZM, CDUZP, CGA24, CI_, CT, CT_, DKCTR4, DKCTR4_, DKCTR5,
  DKCTR5_, F01A, F01B, F02B, F03B_, F04B, F05A, F05B, F06B_, F07A_, F07B,
  F08B_, F09A, F17A, F17B, F18AX, F5ASB0, F5ASB2, FF1109_, FF1110_, FF1111_,
  FF1112_, FS02, FS03, FS04, FS05, FS06, FS06_, FS07A, FS07_, FS08, FS08_,
  FS09, FS16, FS17, GOJAM_, IC11, MP3, NISQ_, OCTAD2, OCTAD3, ODDSET_, PIPGZm,
  PIPGZp, PIPXM, PIPXP, PIPYM, PIPYP, RCH_, RSCT, RT_, RUSG_, SB0, SB1, SB2,
  SB4, SHAFTM, SHAFTP, SUMA15_, SUMB15_, T01DC_, T02, T06, T08, T09DC_, T1P,
  T2P, T3P, T4P, T5P, T6P, TRNM, TRNP, U2BBK, WCH_, WL01, WL02, WL03, WL04,
  WL05, WL06, WL07, WL08, WL09, WL10, WL11, WL12, WL13, WL14, WL16, WT_,
  XB3_, XB4_, XB7_, XT0_, CA2_, CA3_, CTPLS_, F05A_, F05B_, F07B_, F5ASB0_,
  F5ASB2_, FS05_, GOJAM, MNISQ, MON800, MRCH, MWATCH_, MWCH, OUTCOM, PIPZM,
  PIPZP, SB0_, SB1_, SB2_, T01, T02_, T09, BOTHZ, CCHG_, CDUCLK, CDUSTB_,
  CHWL01_, CHWL02_, CHWL03_, CHWL04_, CHWL05_, CHWL06_, CHWL07_, CHWL08_,
  CHWL09_, CHWL10_, CHWL11_, CHWL12_, CHWL13_, CHWL14_, CHWL16_, CI, CNTRSB_,
  ELSNCM, ELSNCN, F04B_, F05D, F07C_, F07D_, F09A_, F09D, F7CSB1_, FLASH,
  FLASH_, FS09_, GTONE, GTRST, GTSET, GTSET_, HIGH0_, HIGH1_, HIGH2_, HIGH3_,
  IC11_, LRRST, MISSZ, NISQ, NOZM, NOZP, ONE, OT1110, OT1111, OT1112, OVNHRP,
  PHS3_, PIPASW, PIPDAT, PIPINT, PIPPLS_, RCHAT_, RCHBT_, RCHG_, RRRST, RSCT_,
  U2BBKG_, US2SG, WATCH, WATCHP, WATCH_, WCHG_, d12KPPS, d25KPPS, d3200A,
  d3200B, d3200C, d3200D, d800RST, d800SET
);

input wire rst, A15_, A16_, BMAGXM, BMAGXP, BMAGYM, BMAGYP, BMAGZP, CA6_,
  CDUXM, CDUXP, CDUYM, CDUYP, CDUZM, CDUZP, CGA24, CI_, CT, CT_, DKCTR4,
  DKCTR4_, DKCTR5, DKCTR5_, F01A, F01B, F02B, F03B_, F04B, F05A, F05B, F06B_,
  F07A_, F07B, F08B_, F09A, F17A, F17B, F18AX, F5ASB0, F5ASB2, FF1109_, FF1110_,
  FF1111_, FF1112_, FS02, FS03, FS04, FS05, FS06, FS06_, FS07A, FS07_, FS08,
  FS08_, FS09, FS16, FS17, GOJAM_, IC11, MP3, NISQ_, OCTAD2, OCTAD3, ODDSET_,
  PIPGZm, PIPGZp, PIPXM, PIPXP, PIPYM, PIPYP, RCH_, RSCT, RT_, RUSG_, SB0,
  SB1, SB2, SB4, SHAFTM, SHAFTP, SUMA15_, SUMB15_, T01DC_, T02, T06, T08,
  T09DC_, T1P, T2P, T3P, T4P, T5P, T6P, TRNM, TRNP, U2BBK, WCH_, WL01, WL02,
  WL03, WL04, WL05, WL06, WL07, WL08, WL09, WL10, WL11, WL12, WL13, WL14,
  WL16, WT_, XB3_, XB4_, XB7_, XT0_;

inout wire CA2_, CA3_, CTPLS_, F05A_, F05B_, F07B_, F5ASB0_, F5ASB2_, FS05_,
  GOJAM, MNISQ, MON800, MRCH, MWATCH_, MWCH, OUTCOM, PIPZM, PIPZP, SB0_,
  SB1_, SB2_, T01, T02_, T09;

output wire BOTHZ, CCHG_, CDUCLK, CDUSTB_, CHWL01_, CHWL02_, CHWL03_, CHWL04_,
  CHWL05_, CHWL06_, CHWL07_, CHWL08_, CHWL09_, CHWL10_, CHWL11_, CHWL12_,
  CHWL13_, CHWL14_, CHWL16_, CI, CNTRSB_, ELSNCM, ELSNCN, F04B_, F05D, F07C_,
  F07D_, F09A_, F09D, F7CSB1_, FLASH, FLASH_, FS09_, GTONE, GTRST, GTSET,
  GTSET_, HIGH0_, HIGH1_, HIGH2_, HIGH3_, IC11_, LRRST, MISSZ, NISQ, NOZM,
  NOZP, ONE, OT1110, OT1111, OT1112, OVNHRP, PHS3_, PIPASW, PIPDAT, PIPINT,
  PIPPLS_, RCHAT_, RCHBT_, RCHG_, RRRST, RSCT_, U2BBKG_, US2SG, WATCH, WATCHP,
  WATCH_, WCHG_, d12KPPS, d25KPPS, d3200A, d3200B, d3200C, d3200D, d800RST,
  d800SET;

assign #0.2  T01 = rst ? 0 : ~(0|ODDSET_|T01DC_);
assign #0.2  F04B_ = rst ? 0 : ~(0|F04B);
assign #0.2  PIPZM = rst ? 0 : ~(0|U207Pad6|U207Pad3|U207Pad8);
assign #0.2  GTSET = rst ? 0 : ~(0|FS06_|F05B_|U204Pad4);
assign #0.2  MRCH = rst ? 0 : ~(0|RCH_);
assign #0.2  U140Pad4 = rst ? 0 : ~(0|F04B);
assign #0.2  PIPZP = rst ? 0 : ~(0|U207Pad2|U207Pad3|U207Pad4);
assign #0.2  U226Pad1 = rst ? 0 : ~(0|F18AX|NOZP);
assign #0.2  LRRST = rst ? 0 : ~(0|F05B_|SB1_);
assign #0.2  ONE = rst ? 0 : ~(0);
assign #0.2  U226Pad8 = rst ? 0 : ~(0|FS07_|F06B_);
assign #0.2  U206Pad1 = rst ? 0 : ~(0|F08B_);
assign #0.2  RRRST = rst ? 0 : ~(0|F05B_|SB1_);
assign #0.2  CHWL02_ = rst ? 0 : ~(0|WL02);
assign #0.2  U208Pad2 = rst ? 0 : ~(0|U208Pad7|U207Pad3);
assign #0.2  U208Pad3 = rst ? 0 : ~(0|U210Pad2|U210Pad3);
assign #0.2  MWCH = rst ? 0 : ~(0|WCH_);
assign #0.2  U208Pad7 = rst ? 0 : ~(0|U210Pad7|U210Pad3);
assign #0.2  F05D = rst ? 0 : ~(0|FS05_|F04B_);
assign #0.2  U108Pad1 = rst ? 0 : ~(0|SB1_|U107Pad2);
assign #0.2  HIGH0_ = rst ? 0 : ~(0|U109Pad1);
assign #0.2  GTONE = rst ? 0 : ~(0|F05B_|FS06|FS07A|FS09|FS08);
assign #0.2  NOZP = rst ? 0 : ~(0|PIPGZp|U226Pad1);
assign #0.2  CHWL08_ = rst ? 0 : ~(0|WL08);
assign #0.2  NOZM = rst ? 0 : ~(0|PIPGZm|U228Pad1);
assign #0.2  PIPASW = rst ? 0 : ~(0|PIPPLS_|SB1_);
assign #0.2  T09 = rst ? 0 : ~(0|ODDSET_|T09DC_);
assign #0.2  U115Pad9 = rst ? 0 : ~(0|RCH_|RT_);
assign #0.2  d3200C = rst ? 0 : ~(0|SB0_|U140Pad4|FS05);
assign #0.2  U109Pad1 = rst ? 0 : ~(0|DKCTR5|DKCTR4);
assign #0.2  CA2_ = rst ? 0 : ~(0|OCTAD2);
assign #0.2  U104Pad1 = rst ? 0 : ~(0|NISQ_|U102Pad9|U102Pad1);
assign #0.2  d3200B = rst ? 0 : ~(0|F05B_|SB0_);
assign #0.2  U115Pad1 = rst ? 0 : ~(0|DKCTR5_|DKCTR4_);
assign #0.2  U224Pad4 = rst ? 0 : ~(0|MISSZ|F5ASB2);
assign #0.2  CHWL01_ = rst ? 0 : ~(0|WL01);
assign #0.2  d3200A = rst ? 0 : ~(0|F05A_|SB0_);
assign #0.2  U104Pad9 = rst ? 0 : ~(0|U103Pad1|OVNHRP);
assign #0.2  U102Pad1 = rst ? 0 : ~(0|U101Pad9|A15_);
assign #0.2  U218Pad8 = rst ? 0 : ~(0|U207Pad6|U208Pad2|U207Pad2);
assign #0.2  CHWL09_ = rst ? 0 : ~(0|WL09);
assign #0.2  U118Pad1 = rst ? 0 : ~(0|WCH_|WT_);
assign #0.2  U102Pad9 = rst ? 0 : ~(0|A16_|U101Pad1);
assign #0.2  U216Pad3 = rst ? 0 : ~(0|U217Pad2|U210Pad3);
assign #0.2  U216Pad7 = rst ? 0 : ~(0|U217Pad7|U210Pad3);
assign #0.2  ELSNCN = rst ? 0 : ~(0|U154Pad2);
assign #0.2  ELSNCM = rst ? 0 : ~(0|U154Pad2);
assign #0.2  U107Pad2 = rst ? 0 : ~(0|F17A);
assign #0.2  U207Pad8 = rst ? 0 : ~(0|PIPGZm);
assign #0.2  U207Pad6 = rst ? 0 : ~(0|U207Pad4|U216Pad3);
assign #0.2  d800SET = rst ? 0 : ~(0|SB1_|F07A_);
assign #0.2  MON800 = rst ? 0 : ~(0|FS07A);
assign #0.2  U207Pad2 = rst ? 0 : ~(0|PIPGZp);
assign #0.2  CDUCLK = rst ? 0 : ~(0|SB0_|U146Pad1);
assign #0.2  U112Pad1 = rst ? 0 : ~(0|DKCTR4_|DKCTR5);
assign #0.2  RCHG_ = rst ? 0 : ~(0|U115Pad9);
assign #0.2  U112Pad9 = rst ? 0 : ~(0|DKCTR5_|DKCTR4);
assign #0.2  BOTHZ = rst ? 0 : ~(0|U207Pad8|U207Pad2);
assign #0.2  CHWL04_ = rst ? 0 : ~(0|WL04);
assign #0.2  MWATCH_ = rst ? 0 : ~(0|WATCH);
assign #0.2  U2BBKG_ = rst ? 0 : ~(0|U2BBK);
assign #0.2  J2Pad210 = rst ? 0 : ~(0);
assign #0.2  CHWL12_ = rst ? 0 : ~(0|WL12);
assign #0.2  U237Pad1 = rst ? 0 : ~(0|CDUSTB_|T08);
assign #0.2  HIGH2_ = rst ? 0 : ~(0|U112Pad9);
assign #0.2  GTSET_ = rst ? 0 : ~(0|GTSET);
assign #0.2  U119Pad9 = rst ? 0 : ~(0|CT_|WCH_);
assign #0.2  F07D_ = rst ? 0 : ~(0|U226Pad8);
assign #0.2  U153Pad2 = rst ? 0 : ~(0|FS04);
assign #0.2  U156Pad2 = rst ? 0 : ~(0|XB3_|XT0_);
assign #0.2  F09A_ = rst ? 0 : ~(0|F09A);
assign #0.2  U149Pad2 = rst ? 0 : ~(0|SB4);
assign #0.2  d25KPPS = rst ? 0 : ~(0|FS02|SB0_|U134Pad4);
assign #0.2  MISSZ = rst ? 0 : ~(0|PIPGZp|PIPGZm|U224Pad4);
assign #0.2  T02_ = rst ? 0 : ~(0|T02);
assign #0.2  CA3_ = rst ? 0 : ~(0|OCTAD3);
assign #0.2  PHS3_ = rst ? 0 : ~(0|CT);
assign #0.2  CHWL14_ = rst ? 0 : ~(0|WL14);
assign #0.2  FS05_ = rst ? 0 : ~(0|FS05);
assign #0.2  U146Pad1 = rst ? 0 : ~(0|F01A);
assign #0.2  CHWL03_ = rst ? 0 : ~(0|WL03);
assign #0.2  CHWL13_ = rst ? 0 : ~(0|WL13);
assign #0.2  U209Pad1 = rst ? 0 : ~(0|U207Pad2|U207Pad6|U207Pad3);
assign #0.2  OVNHRP = rst ? 0 : ~(0|U104Pad1|U104Pad9|MP3);
assign #0.2  F05A_ = rst ? 0 : ~(0|F05A);
assign #0.2  F7CSB1_ = rst ? 0 : ~(0|U224Pad9);
assign #0.2  CNTRSB_ = rst ? 0 : ~(0|SB2);
assign #0.2  U209Pad9 = rst ? 0 : ~(0|U207Pad3|U207Pad4|U207Pad8);
assign #0.2  IC11_ = rst ? 0 : ~(0|IC11);
assign #0.2  HIGH1_ = rst ? 0 : ~(0|U112Pad1);
assign #0.2  U207Pad4 = rst ? 0 : ~(0|U216Pad7|U207Pad6);
assign #0.2  PIPDAT = rst ? 0 : ~(0|PIPPLS_|SB2_);
assign #0.2  F07B_ = rst ? 0 : ~(0|F07B);
assign #0.2  OT1112 = rst ? 0 : ~(0|FF1112_);
assign #0.2  RCHAT_ = rst ? 0 : ~(0|U158Pad2);
assign #0.2  OT1110 = rst ? 0 : ~(0|FF1110_);
assign #0.2  OT1111 = rst ? 0 : ~(0|FF1111_);
assign #0.2  d3200D = rst ? 0 : ~(0|SB0_|FS05_|U140Pad4);
assign #0.2  SB0_ = rst ? 0 : ~(0|SB0);
assign #0.2  F5ASB0_ = rst ? 0 : ~(0|F5ASB0);
assign #0.2  CHWL10_ = rst ? 0 : ~(0|WL10);
assign #0.2  U218Pad2 = rst ? 0 : ~(0|U207Pad8|U208Pad2|U207Pad4);
assign #0.2  U204Pad4 = rst ? 0 : ~(0|U205Pad1);
assign #0.2  F05B_ = rst ? 0 : ~(0|F05B);
assign #0.2  GOJAM = rst ? 0 : ~(0|GOJAM_);
assign #0.2  U101Pad9 = rst ? 0 : ~(0|A16_);
assign #0.2  d12KPPS = rst ? 0 : ~(0|FS03|U137Pad1|SB0_);
assign #0.2  FS09_ = rst ? 0 : ~(0|FS09);
assign #0.2  U101Pad1 = rst ? 0 : ~(0|A15_);
assign #0.2  WCHG_ = rst ? 0 : ~(0|U118Pad1);
assign #0.2  PIPPLS_ = rst ? 0 : ~(0|U152Pad2);
assign #0.2  FLASH = rst ? 0 : ~(0|FS17|FS16);
assign #0.2  U207Pad3 = rst ? 0 : ~(0|U208Pad2|U208Pad3);
assign #0.2  F07C_ = rst ? 0 : ~(0|U227Pad8);
assign #0.2  CTPLS_ = rst ? 0 : ~(0|BMAGXM|BMAGXP|PIPZM|BMAGYP|BMAGYM|BMAGZP|T4P|T6P|T5P|T1P|T2P|T3P|TRNP|TRNM|SHAFTP|PIPZP|PIPYM|PIPYP|SHAFTM|PIPXP|PIPXM|CDUZM|CDUZP|CDUYM|CDUXP|CDUXM|CDUYP);
assign #0.2  d800RST = rst ? 0 : ~(0|SB1_|F07B_);
assign #0.2  RCHBT_ = rst ? 0 : ~(0|U156Pad2);
assign #0.2  SB1_ = rst ? 0 : ~(0|SB1);
assign #0.2  U227Pad8 = rst ? 0 : ~(0|FS07A|F06B_);
assign #0.2  PIPINT = rst ? 0 : ~(0|U149Pad2|PIPPLS_);
assign #0.2  CDUSTB_ = rst ? 0 : ~(0|T06|U237Pad1);
assign #0.2  U211Pad2 = rst ? 0 : ~(0|U207Pad2|U207Pad4|U208Pad2);
assign #0.2  U211Pad3 = rst ? 0 : ~(0|U207Pad8|U208Pad2|U207Pad6);
assign #0.2  CHWL05_ = rst ? 0 : ~(0|WL05);
assign #0.2  CHWL11_ = rst ? 0 : ~(0|WL11);
assign #0.2  GTRST = rst ? 0 : ~(0|FS06|U204Pad4|F05B_);
assign #0.2  FLASH_ = rst ? 0 : ~(0|FLASH);
assign #0.2  HIGH3_ = rst ? 0 : ~(0|U115Pad1);
assign #0.2  OUTCOM = rst ? 0 : ~(0|FF1109_);
assign #0.2  U154Pad2 = rst ? 0 : ~(0|FS07A);
assign #0.2  RSCT_ = rst ? 0 : ~(0|RSCT);
assign #0.2  U134Pad4 = rst ? 0 : ~(0|F01B);
assign #0.2  U205Pad1 = rst ? 0 : ~(0|FS08_|FS07_|FS09_);
assign #0.2  U224Pad9 = rst ? 0 : ~(0|F07C_|SB1_);
assign #0.2  CI = rst ? 0 : ~(0|CI_);
assign #0.2  US2SG = rst ? 0 : ~(0|SUMB15_|SUMA15_|RUSG_);
assign #0.2  SB2_ = rst ? 0 : ~(0|SB2);
assign #0.2  CCHG_ = rst ? 0 : ~(0|U119Pad9);
assign #0.2  U105Pad2 = rst ? 0 : ~(0|XB7_|CA6_|T02_);
assign #0.2  CHWL07_ = rst ? 0 : ~(0|WL07);
assign #0.2  U105Pad1 = rst ? 0 : ~(0|U105Pad2|U105Pad3);
assign #0.2  WATCH_ = rst ? 0 : ~(0|WATCHP|WATCH);
assign #0.2  F5ASB2_ = rst ? 0 : ~(0|F5ASB2);
assign #0.2  CHWL16_ = rst ? 0 : ~(0|WL16);
assign #0.2  U152Pad2 = rst ? 0 : ~(0|U153Pad2|F03B_|FS05);
assign #0.2  WATCHP = rst ? 0 : ~(0|U107Pad2|SB2_|U105Pad3);
assign #0.2  U105Pad3 = rst ? 0 : ~(0|U105Pad1|F17B);
assign #0.2  U137Pad1 = rst ? 0 : ~(0|F02B);
assign #0.2  U103Pad1 = rst ? 0 : ~(0|U103Pad2|NISQ_);
assign #0.2  U103Pad2 = rst ? 0 : ~(0|U102Pad1|U102Pad9);
assign #0.2  NISQ = rst ? 0 : ~(0|NISQ_);
assign #0.2  U210Pad7 = rst ? 0 : ~(0|U209Pad1|U210Pad2|U209Pad9);
assign #0.2  U210Pad3 = rst ? 0 : ~(0|F5ASB2);
assign #0.2  U210Pad2 = rst ? 0 : ~(0|U211Pad2|U211Pad3|U210Pad7);
assign #0.2  CHWL06_ = rst ? 0 : ~(0|WL06);
assign #0.2  MNISQ = rst ? 0 : ~(0|NISQ_);
assign #0.2  F09D = rst ? 0 : ~(0|U206Pad1|FS09_);
assign #0.2  J1Pad146 = rst ? 0 : ~(0);
assign #0.2  U158Pad2 = rst ? 0 : ~(0|XB4_|XT0_);
assign #0.2  WATCH = rst ? 0 : ~(0|WATCH_|U108Pad1);
assign #0.2  U228Pad1 = rst ? 0 : ~(0|NOZM|F18AX);
assign #0.2  U217Pad2 = rst ? 0 : ~(0|U218Pad2|U217Pad7);
assign #0.2  U217Pad7 = rst ? 0 : ~(0|U217Pad2|U218Pad8);

endmodule
