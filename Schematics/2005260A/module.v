// Verilog module auto-generated for AGC module A2 by dumbVerilog.py

module A2 ( 
  rst, ALGA, CGA2, CLOCK, GOJ1, MP3A, MSTP, MSTRTP, SBY, STRT1, STRT2, WL15,
  WL15_, WL16, WL16_, CINORM, EVNSET, EVNSET_, GOJAM, GOJAM_, MGOJAM, MONWT,
  MSTPIT_, MT01, MT02, MT03, MT04, MT05, MT06, MT07, MT08, MT09, MT10, MT11,
  MT12, ODDSET_, OVFSTB_, P01_, P02, P02_, P03, P03_, P04, P05, P05_, PHS4,
  PHS4_, Q2A, RINGA_, RINGB_, RT, STOP, STOPA, T02, T02DC_, T03, T03DC_,
  T06, T06DC_, T08, T08DC_, T10, T10DC_, T12DC_, WT, WT_, CLK, CT, CT_, EDSET,
  F01A, F01B, F01C, F01D, FS01, FS01_, GOSET_, OVF, OVF_, P01, P04_, PHS2,
  PHS2_, RT_, SB0, SB1, SB2, SB4, STOP_, T01, T01DC_, T01_, T02_, T03_, T04,
  T04_, T05, T05_, T06_, T07, T07DC_, T07_, T08_, T09, T09DC_, T09_, T10_,
  T11, T11_, T12, T12SET, T12_, TT_, UNF, UNF_
);

input wire rst, ALGA, CGA2, CLOCK, GOJ1, MP3A, MSTP, MSTRTP, SBY, STRT1,
  STRT2, WL15, WL15_, WL16, WL16_;

inout wire CINORM, EVNSET, EVNSET_, GOJAM, GOJAM_, MGOJAM, MONWT, MSTPIT_,
  MT01, MT02, MT03, MT04, MT05, MT06, MT07, MT08, MT09, MT10, MT11, MT12,
  ODDSET_, OVFSTB_, P01_, P02, P02_, P03, P03_, P04, P05, P05_, PHS4, PHS4_,
  Q2A, RINGA_, RINGB_, RT, STOP, STOPA, T02, T02DC_, T03, T03DC_, T06, T06DC_,
  T08, T08DC_, T10, T10DC_, T12DC_, WT, WT_;

output wire CLK, CT, CT_, EDSET, F01A, F01B, F01C, F01D, FS01, FS01_, GOSET_,
  OVF, OVF_, P01, P04_, PHS2, PHS2_, RT_, SB0, SB1, SB2, SB4, STOP_, T01,
  T01DC_, T01_, T02_, T03_, T04, T04_, T05, T05_, T06_, T07, T07DC_, T07_,
  T08_, T09, T09DC_, T09_, T10_, T11, T11_, T12, T12SET, T12_, TT_, UNF,
  UNF_;

assign #0.2  PHS4 = rst ? 0 : ~(0|U131Pad3|U137Pad9);
assign #0.2  U229Pad8 = rst ? 1 : ~(0|P04|P05|RINGA_);
assign #0.2  UNF = rst ? 0 : ~(0|WL16_|WL15|OVFSTB_);
assign #0.2  PHS2 = rst ? 0 : ~(0|U131Pad3|U134Pad8);
assign #0.2  U229Pad3 = rst ? 0 : ~(0|P05_|P04_|RINGB_);
assign #0.2  T09_ = rst ? 0 : ~(0|T09);
assign #0.2  WT = rst ? 0 : ~(0|U132Pad2);
assign #0.2  U215Pad2 = rst ? 0 : ~(0|GOJ1|GOSET_);
assign #0.2  U311Pad2 = rst ? 0 : ~(0|T07DC_|EVNSET_);
assign #0.2  MT09 = rst ? 0 : ~(0|T09_);
assign #0.2  EDSET = rst ? 0 : ~(0|P02|P03_|P04);
assign #0.2  P04_ = rst ? 0 : ~(0|P04|U223Pad8);
assign #0.2  U212Pad3 = rst ? 0 : ~(0|STOPA|U213Pad1);
assign #0.2  U212Pad2 = rst ? 1 : ~(0|EVNSET_|U214Pad1);
assign #0.2  T02_ = rst ? 0 : ~(0|T02);
assign #0.2  U326Pad2 = rst ? 0 : ~(0|U325Pad3|T01DC_|GOJAM);
assign #0.2  P03_ = rst ? 0 : ~(0|P03|U225Pad8);
assign #0.2  U144Pad8 = rst ? 1 : ~(0|U145Pad8|U142Pad9);
assign #0.2  MT03 = rst ? 0 : ~(0|T03_);
assign #0.2  T08_ = rst ? 0 : ~(0|T08);
assign #0.2  T07 = rst ? 0 : ~(0|T07DC_|ODDSET_);
assign #0.2  T06 = rst ? 0 : ~(0|T06DC_|EVNSET_);
assign #0.2  T05 = rst ? 1 : ~(0|ODDSET_|U316Pad2);
assign #0.2  T04 = rst ? 1 : ~(0|U319Pad2|EVNSET_);
assign #0.2  T03 = rst ? 1 : ~(0|ODDSET_|T03DC_);
assign #0.2  T02 = rst ? 1 : ~(0|EVNSET_|T02DC_);
assign #0.2  T01 = rst ? 1 : ~(0|T01DC_|ODDSET_);
assign #0.2  T09 = rst ? 0 : ~(0|T09DC_|ODDSET_);
assign #0.2  T08 = rst ? 0 : ~(0|T08DC_|EVNSET_);
assign #0.2  U221Pad2 = rst ? 1 : ~(0|P04|RINGB_);
assign #0.2  T01_ = rst ? 0 : ~(0|T01);
assign #0.2  T06DC_ = rst ? 0 : ~(0|U315Pad2|U315Pad3);
assign #0.2  U150Pad9 = rst ? 0 : ~(0|STOP|RINGA_);
assign #0.2  U221Pad8 = rst ? 0 : ~(0|RINGA_|P04_);
assign #0.2  MSTPIT_ = rst ? 0 : ~(0|STOP);
assign #0.2  P03 = rst ? 0 : ~(0|U225Pad2|P03_);
assign #0.2  P02 = rst ? 0 : ~(0|P02_|U227Pad3);
assign #0.2  P01 = rst ? 0 : ~(0|P01_|U229Pad3);
assign #0.2  ODDSET_ = rst ? 0 : ~(0|U150Pad9);
assign #0.2  OVF = rst ? 0 : ~(0|OVFSTB_|WL16|WL15_);
assign #0.2  P05 = rst ? 0 : ~(0|U221Pad2|P05_);
assign #0.2  P04 = rst ? 0 : ~(0|U223Pad2|P04_);
assign #0.2  T08DC_ = rst ? 0 : ~(0|U311Pad2|U311Pad3);
assign #0.2  Q2A = rst ? 0 : ~(0|WT_);
assign #0.2  PHS2_ = rst ? 0 : ~(0|PHS2);
assign #0.2  T10 = rst ? 0 : ~(0|T10DC_|EVNSET_);
assign #0.2  T11 = rst ? 0 : ~(0|U304Pad7|ODDSET_);
assign #0.2  T12 = rst ? 0 : ~(0|T12DC_|EVNSET_);
assign #0.2  T11_ = rst ? 0 : ~(0|T11);
assign #0.2  T03_ = rst ? 0 : ~(0|T03);
assign #0.2  U131Pad4 = rst ? 0 : ~(0|U132Pad2|U131Pad1);
assign #0.2  U131Pad3 = rst ? 1 : ~(0|CLOCK|U131Pad1|PHS2);
assign #0.2  U131Pad1 = rst ? 0 : ~(0|CLOCK|U131Pad3|U131Pad4);
assign #0.2  T02DC_ = rst ? 0 : ~(0|U325Pad2|U325Pad3);
assign #0.2  T04_ = rst ? 0 : ~(0|T04);
assign #0.2  U303Pad3 = rst ? 0 : ~(0|U305Pad3|T10DC_|GOJAM);
assign #0.2  RT_ = rst ? 0 : ~(0|RT);
assign #0.01 U153Pad3 = rst ? 1 : ~(0|U151Pad1|U153Pad1);
assign #0.2  RT = rst ? 0 : ~(0|U131Pad3);
assign #0.01 U153Pad1 = rst ? 0 : ~(0|U151Pad2|U153Pad3);
assign #0.2  P05_ = rst ? 0 : ~(0|P05|U221Pad8);
assign #0.2  RINGA_ = rst ? 0 : ~(0|U142Pad8);
assign #0.2  U319Pad2 = rst ? 0 : ~(0|U321Pad2|U320Pad2);
assign #0.2  MT10 = rst ? 0 : ~(0|T10_);
assign #0.2  MT11 = rst ? 0 : ~(0|T11_);
assign #0.2  U303Pad4 = rst ? 0 : ~(0|U303Pad3|T09DC_|GOJAM);
assign #0.01 U156Pad1 = rst ? 0 : ~(0|U153Pad3);
assign #0.2  MT12 = rst ? 0 : ~(0|T12_);
assign #0.2  T03DC_ = rst ? 0 : ~(0|U320Pad4|U323Pad3);
assign #0.2  T12DC_ = rst ? 0 : ~(0|T12SET|GOJAM|U330Pad1);
assign #0.2  EVNSET_ = rst ? 0 : ~(0|EVNSET);
assign #0.2  U209Pad1 = rst ? 0 : ~(0|U209Pad2|U209Pad3);
assign #0.2  U209Pad3 = rst ? 0 : ~(0|U209Pad1|U210Pad1);
assign #0.2  U209Pad2 = rst ? 0 : ~(0|EVNSET_|T12DC_|U211Pad1);
assign #0.2  T09DC_ = rst ? 0 : ~(0|U309Pad2|U303Pad4);
assign #0.2  OVFSTB_ = rst ? 0 : ~(0|U151Pad2);
assign #0.2  SB2 = rst ? 0 : ~(0|P02|P05_);
assign #0.2  SB0 = rst ? 0 : ~(0|P02_|P05);
assign #0.2  SB1 = rst ? 0 : ~(0|P03_|P05_);
assign #0.2  T07DC_ = rst ? 0 : ~(0|U313Pad2|U313Pad3);
assign #0.2  SB4 = rst ? 0 : ~(0|P04|P02_);
assign #0.2  MT08 = rst ? 0 : ~(0|T08_);
assign #0.2  MT07 = rst ? 0 : ~(0|T07_);
assign #0.2  MT06 = rst ? 0 : ~(0|T06_);
assign #0.2  MT05 = rst ? 0 : ~(0|T05_);
assign #0.2  CT_ = rst ? 0 : ~(0|CT);
assign #0.2  STOP = rst ? 0 : ~(0|STOP_);
assign #0.2  MT02 = rst ? 0 : ~(0|T02_);
assign #0.2  MT01 = rst ? 0 : ~(0|T01_);
assign #0.2  PHS4_ = rst ? 0 : ~(0|PHS4);
assign #0.2  U305Pad2 = rst ? 0 : ~(0|T10DC_|ODDSET_);
assign #0.2  U305Pad3 = rst ? 0 : ~(0|GOJAM|U304Pad1|U304Pad7);
assign #0.2  CINORM = rst ? 0 : ~(0|MP3A);
assign #0.2  T10DC_ = rst ? 0 : ~(0|U307Pad2|U303Pad3);
assign #0.2  WT_ = rst ? 0 : ~(0|WT);
assign #0.2  FS01_ = rst ? 0 : ~(0|FS01|F01B);
assign #0.2  U321Pad2 = rst ? 1 : ~(0|EVNSET_|T03DC_);
assign #0.2  FS01 = rst ? 0 : ~(0|FS01_|F01A);
assign #0.2  T06_ = rst ? 0 : ~(0|T06);
assign #0.2  GOJAM = rst ? 0 : ~(0|GOJAM_);
assign #0.2  T12_ = rst ? 0 : ~(0|T12);
assign #0.2  STOP_ = rst ? 0 : ~(0|STOPA|U209Pad3);
assign #0.2  CLK = rst ? 0 : ~(0|WT_);
assign #0.2  T07_ = rst ? 0 : ~(0|T07);
assign #0.2  F01B = rst ? 0 : ~(0|F01A|P01_|F01D);
assign #0.2  U320Pad2 = rst ? 0 : ~(0|U318Pad3|U319Pad2|GOJAM);
assign #0.2  U227Pad3 = rst ? 1 : ~(0|P01|RINGA_);
assign #0.2  STOPA = rst ? 0 : ~(0|U212Pad2|U212Pad3);
assign #0.2  U227Pad8 = rst ? 0 : ~(0|RINGB_|P01_);
assign #0.2  CT = rst ? 0 : ~(0|U142Pad1);
assign #0.2  UNF_ = rst ? 0 : ~(0|UNF);
assign #0.2  U211Pad1 = rst ? 1 : ~(0|MSTP);
assign #0.2  T05_ = rst ? 0 : ~(0|T05);
assign #0.2  U323Pad3 = rst ? 1 : ~(0|ODDSET_|T02DC_);
assign #0.2  U307Pad2 = rst ? 0 : ~(0|T09DC_|EVNSET_);
assign #0.2  U213Pad1 = rst ? 0 : ~(0|GOSET_|EVNSET_|T12DC_);
assign #0.2  U134Pad8 = rst ? 0 : ~(0|U132Pad2|U131Pad3);
assign #0.2  U330Pad1 = rst ? 0 : ~(0|T12DC_|U326Pad2);
assign #0.2  OVF_ = rst ? 0 : ~(0|OVF);
assign #0.2  U313Pad3 = rst ? 0 : ~(0|U311Pad3|T07DC_|GOJAM);
assign #0.2  U313Pad2 = rst ? 0 : ~(0|T06DC_|ODDSET_);
assign #0.2  U309Pad2 = rst ? 0 : ~(0|T08DC_|ODDSET_);
assign #0.2  U320Pad4 = rst ? 0 : ~(0|U320Pad2|T03DC_|GOJAM);
assign #0.2  P02_ = rst ? 0 : ~(0|P02|U227Pad8);
assign #0.2  MONWT = rst ? 0 : ~(0|WT_);
assign #0.2  T01DC_ = rst ? 0 : ~(0|U328Pad2|U326Pad2);
assign #0.2  RINGB_ = rst ? 0 : ~(0|U143Pad8);
assign #0.01 U151Pad1 = rst ? 1 : ~(0|U151Pad2|CT_);
assign #0.2  EVNSET = rst ? 0 : ~(0|RINGB_);
assign #0.01 U151Pad2 = rst ? 0 : ~(0|U152Pad2|U151Pad1);
assign #0.2  GOJAM_ = rst ? 0 : ~(0|STRT2|STOPA);
assign #0.01 U152Pad2 = rst ? 1 : ~(0|U156Pad1);
assign #0.2  MT04 = rst ? 0 : ~(0|T04_);
assign #0.2  U318Pad2 = rst ? 1 : ~(0|U319Pad2|ODDSET_);
assign #0.2  U318Pad3 = rst ? 0 : ~(0|U315Pad3|U316Pad2|GOJAM);
assign #0.2  U315Pad3 = rst ? 0 : ~(0|T06DC_|U313Pad3|GOJAM);
assign #0.2  U315Pad2 = rst ? 1 : ~(0|U316Pad2|EVNSET_);
assign #0.2  MGOJAM = rst ? 0 : ~(0|GOJAM_);
assign #0.2  U137Pad9 = rst ? 1 : ~(0|U131Pad4);
assign #0.2  U143Pad8 = rst ? 0 : ~(0|U142Pad6|U145Pad8);
assign #0.2  F01A = rst ? 0 : ~(0|F01C|F01B|P01_);
assign #0.2  F01C = rst ? 0 : ~(0|FS01|F01A);
assign #0.2  U223Pad2 = rst ? 1 : ~(0|P03|RINGA_);
assign #0.2  F01D = rst ? 0 : ~(0|F01B|FS01_);
assign #0.2  U132Pad2 = rst ? 1 : ~(0|U131Pad1|U134Pad8);
assign #0.2  P01_ = rst ? 0 : ~(0|P01|U229Pad8);
assign #0.2  U223Pad8 = rst ? 0 : ~(0|RINGB_|P03_);
assign #0.2  U210Pad1 = rst ? 1 : ~(0|EVNSET_|MSTP);
assign #0.2  U316Pad2 = rst ? 0 : ~(0|U318Pad2|U318Pad3);
assign #0.2  U311Pad3 = rst ? 0 : ~(0|U303Pad4|T08DC_|GOJAM);
assign #0.2  TT_ = rst ? 0 : ~(0|WT);
assign #0.2  T10_ = rst ? 0 : ~(0|T10);
assign #0.2  U325Pad2 = rst ? 1 : ~(0|T01DC_|EVNSET_);
assign #0.2  U325Pad3 = rst ? 0 : ~(0|T02DC_|U320Pad4|GOJAM);
assign #0.2  U145Pad8 = rst ? 0 : ~(0|U144Pad8|U142Pad6);
assign #0.2  U328Pad2 = rst ? 0 : ~(0|ODDSET_|T12DC_);
assign #0.2  T12SET = rst ? 0 : ~(0|EVNSET_|U303Pad3|U303Pad4|U320Pad2|U318Pad3|U320Pad4|U315Pad3|U313Pad3|U311Pad3|U326Pad2|U325Pad3);
assign #0.2  U304Pad7 = rst ? 1 : ~(0|U305Pad2|U305Pad3);
assign #0.2  U142Pad6 = rst ? 1 : ~(0|U142Pad9|U137Pad9|U143Pad8);
assign #0.2  U142Pad1 = rst ? 1 : ~(0|U131Pad1);
assign #0.2  U225Pad2 = rst ? 1 : ~(0|P02|RINGB_);
assign #0.2  U304Pad1 = rst ? 1 : ~(0|U303Pad3|EVNSET_);
assign #0.2  U214Pad1 = rst ? 0 : ~(0|GOSET_);
assign #0.2  U225Pad8 = rst ? 1 : ~(0|RINGA_|P02_);
assign #0.2  U142Pad9 = rst ? 0 : ~(0|U142Pad6|U137Pad9|U142Pad8);
assign #0.2  U142Pad8 = rst ? 0 : ~(0|U142Pad9|U144Pad8);
assign #0.2  GOSET_ = rst ? 0 : ~(0|ALGA|MSTRTP|SBY|U215Pad2|STRT1|STRT2);

endmodule
