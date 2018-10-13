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

parameter GATE_DELAY = 0.2; // This default may be overridden at compile time.
initial $display("Gate delay (A2) will be %f ns.", GATE_DELAY*100);

// Gate A2-U138B
pullup(PHS4);
assign #GATE_DELAY PHS4 = rst ? 0 : ((0|g37103|g37107) ? 1'b0 : 1'bz);
// Gate A2-U351A A2-U350A A2-U350B
pullup(T04_);
assign #GATE_DELAY T04_ = rst ? 1'bz : ((0|T04) ? 1'b0 : 1'bz);
// Gate A2-U134B
pullup(PHS2);
assign #GATE_DELAY PHS2 = rst ? 0 : ((0|g37103|g37106) ? 1'b0 : 1'bz);
// Gate A2-U215B
pullup(g37229);
assign #GATE_DELAY g37229 = rst ? 1'bz : ((0|GOJ1|GOSET_) ? 1'b0 : 1'bz);
// Gate A2-U336A A2-U336B A2-U337A A2-U337B
pullup(T09_);
assign #GATE_DELAY T09_ = rst ? 1'bz : ((0|T09) ? 1'b0 : 1'bz);
// Gate A2-U220B
pullup(SB1);
assign #GATE_DELAY SB1 = rst ? 0 : ((0|P03_|P05_) ? 1'b0 : 1'bz);
// Gate A2-U133A
pullup(RT);
assign #GATE_DELAY RT = rst ? 0 : ((0|g37103) ? 1'b0 : 1'bz);
// Gate A2-U308A
pullup(g37341);
assign #GATE_DELAY g37341 = rst ? 0 : ((0|T09DC_|EVNSET_) ? 1'b0 : 1'bz);
// Gate A2-U338B
pullup(MT09);
assign #GATE_DELAY MT09 = rst ? 0 : ((0|T09_) ? 1'b0 : 1'bz);
// Gate A2-U201B
pullup(EDSET);
assign #GATE_DELAY EDSET = rst ? 0 : ((0|P02|P03_|P04) ? 1'b0 : 1'bz);
// Gate A2-U211A
pullup(g37235);
assign #GATE_DELAY g37235 = rst ? 1'bz : ((0|MSTP) ? 1'b0 : 1'bz);
// Gate A2-U223B
pullup(P04_);
assign #GATE_DELAY P04_ = rst ? 0 : ((0|P04|g37214) ? 1'b0 : 1'bz);
// Gate A2-U135A A2-U136A A2-U137A A2-U138A A2-U160B
pullup(WT_);
assign #GATE_DELAY WT_ = rst ? 1'bz : ((0|WT) ? 1'b0 : 1'bz);
// Gate A2-U213A
pullup(g37231);
assign #GATE_DELAY g37231 = rst ? 1'bz : ((0|GOSET_|EVNSET_|T12DC_) ? 1'b0 : 1'bz);
// Gate A2-U210A
pullup(g37237);
assign #GATE_DELAY g37237 = rst ? 1'bz : ((0|EVNSET_|MSTP) ? 1'b0 : 1'bz);
// Gate A2-U225B
pullup(P03_);
assign #GATE_DELAY P03_ = rst ? 0 : ((0|P03|g37210) ? 1'b0 : 1'bz);
// Gate A2-U304A
pullup(g37346);
assign #GATE_DELAY g37346 = rst ? 1'bz : ((0|g37343|EVNSET_) ? 1'b0 : 1'bz);
// Gate A2-U305A
pullup(g37347);
assign #GATE_DELAY g37347 = rst ? 1'bz : ((0|g37345|g37348) ? 1'b0 : 1'bz);
// Gate A2-U353A
pullup(MT03);
assign #GATE_DELAY MT03 = rst ? 0 : ((0|T03_) ? 1'b0 : 1'bz);
// Gate A2-U325B
pullup(g37310);
assign #GATE_DELAY g37310 = rst ? 0 : ((0|T02DC_|g37314|GOJAM) ? 1'b0 : 1'bz);
// Gate A2-U327A
pullup(g37308);
assign #GATE_DELAY g37308 = rst ? 0 : ((0|T01DC_|EVNSET_) ? 1'b0 : 1'bz);
// Gate A2-U339A A2-U339B A2-U340A A2-U340B
pullup(T08_);
assign #GATE_DELAY T08_ = rst ? 1'bz : ((0|T08) ? 1'b0 : 1'bz);
// Gate A2-U312B
pullup(T07);
assign #GATE_DELAY T07 = rst ? 0 : ((0|T07DC_|ODDSET_) ? 1'b0 : 1'bz);
// Gate A2-U314A A2-U355B
pullup(T06);
assign #GATE_DELAY T06 = rst ? 0 : ((0|T06DC_|EVNSET_) ? 1'b0 : 1'bz);
// Gate A2-U317B A2-U316B
pullup(T05);
assign #GATE_DELAY T05 = rst ? 0 : ((0|ODDSET_|g37321) ? 1'b0 : 1'bz);
// Gate A2-U319A
pullup(T04);
assign #GATE_DELAY T04 = rst ? 0 : ((0|g37317|EVNSET_) ? 1'b0 : 1'bz);
// Gate A2-U157B A2-U322B
pullup(T03);
assign #GATE_DELAY T03 = rst ? 0 : ((0|ODDSET_|T03DC_) ? 1'b0 : 1'bz);
// Gate A2-U210B
pullup(g37239);
assign #GATE_DELAY g37239 = rst ? 0 : ((0|g37238|g37237) ? 1'b0 : 1'bz);
// Gate A2-U327B
pullup(T01);
assign #GATE_DELAY T01 = rst ? 0 : ((0|T01DC_|ODDSET_) ? 1'b0 : 1'bz);
// Gate A2-U209A
pullup(g37238);
assign #GATE_DELAY g37238 = rst ? 1'bz : ((0|g37236|g37239) ? 1'b0 : 1'bz);
// Gate A2-U308B
pullup(T09);
assign #GATE_DELAY T09 = rst ? 0 : ((0|T09DC_|ODDSET_) ? 1'b0 : 1'bz);
// Gate A2-U310A A2-U360B
pullup(T08);
assign #GATE_DELAY T08 = rst ? 0 : ((0|T08DC_|EVNSET_) ? 1'b0 : 1'bz);
// Gate A2-U355A A2-U356A A2-U356B
pullup(T01_);
assign #GATE_DELAY T01_ = rst ? 1'bz : ((0|T01) ? 1'b0 : 1'bz);
// Gate A2-U315A
pullup(T06DC_);
assign #GATE_DELAY T06DC_ = rst ? 1'bz : ((0|g37325|g37327) ? 1'b0 : 1'bz);
// Gate A2-U214B
pullup(g37232);
assign #GATE_DELAY g37232 = rst ? 0 : ((0|EVNSET_|g37230) ? 1'b0 : 1'bz);
// Gate A2-U203A
pullup(MSTPIT_);
assign #GATE_DELAY MSTPIT_ = rst ? 0 : ((0|STOP) ? 1'b0 : 1'bz);
// Gate A2-U225A
pullup(P03);
assign #GATE_DELAY P03 = rst ? 1'bz : ((0|g37209|P03_) ? 1'b0 : 1'bz);
// Gate A2-U227A
pullup(P02);
assign #GATE_DELAY P02 = rst ? 1'bz : ((0|P02_|g37205) ? 1'b0 : 1'bz);
// Gate A2-U229A
pullup(P01);
assign #GATE_DELAY P01 = rst ? 1'bz : ((0|P01_|g37201) ? 1'b0 : 1'bz);
// Gate A2-U151B A2-U152B A2-U153B
pullup(ODDSET_);
assign #GATE_DELAY ODDSET_ = rst ? 1'bz : ((0|g37121) ? 1'b0 : 1'bz);
// Gate A2-U303B
pullup(OVF);
assign #GATE_DELAY OVF = rst ? 0 : ((0|OVFSTB_|WL16|WL15_) ? 1'b0 : 1'bz);
// Gate A2-U221A
pullup(P05);
assign #GATE_DELAY P05 = rst ? 0 : ((0|g37217|P05_) ? 1'b0 : 1'bz);
// Gate A2-U223A
pullup(P04);
assign #GATE_DELAY P04 = rst ? 1'bz : ((0|g37213|P04_) ? 1'b0 : 1'bz);
// Gate A2-U319B
pullup(g37320);
assign #GATE_DELAY g37320 = rst ? 0 : ((0|g37317|ODDSET_) ? 1'b0 : 1'bz);
// Gate A2-U311A
pullup(T08DC_);
assign #GATE_DELAY T08DC_ = rst ? 1'bz : ((0|g37333|g37335) ? 1'b0 : 1'bz);
// Gate A2-U141A
pullup(Q2A);
assign #GATE_DELAY Q2A = rst ? 0 : ((0|WT_) ? 1'b0 : 1'bz);
// Gate A2-U131B
pullup(PHS2_);
assign #GATE_DELAY PHS2_ = rst ? 1'bz : ((0|PHS2) ? 1'b0 : 1'bz);
// Gate A2-U306A A2-U358B
pullup(T10);
assign #GATE_DELAY T10 = rst ? 0 : ((0|T10DC_|EVNSET_) ? 1'b0 : 1'bz);
// Gate A2-U304B
pullup(T11);
assign #GATE_DELAY T11 = rst ? 0 : ((0|g37347|ODDSET_) ? 1'b0 : 1'bz);
// Gate A2-U329A
pullup(T12);
assign #GATE_DELAY T12 = rst ? 1'bz : ((0|T12DC_|EVNSET_) ? 1'b0 : 1'bz);
// Gate A2-U331B A2-U332B
pullup(T11_);
assign #GATE_DELAY T11_ = rst ? 1'bz : ((0|T11) ? 1'b0 : 1'bz);
// Gate A2-U351B A2-U352A A2-U352B
pullup(T03_);
assign #GATE_DELAY T03_ = rst ? 1'bz : ((0|T03) ? 1'b0 : 1'bz);
// Gate A2-U134A
pullup(WT);
assign #GATE_DELAY WT = rst ? 0 : ((0|g37105) ? 1'b0 : 1'bz);
// Gate A2-U150B
pullup(g37121);
assign #GATE_DELAY g37121 = rst ? 0 : ((0|STOP|RINGA_) ? 1'b0 : 1'bz);
// Gate A2-U139A
pullup(TT_);
assign #GATE_DELAY TT_ = rst ? 1'bz : ((0|WT) ? 1'b0 : 1'bz);
// Gate A2-U325A
pullup(T02DC_);
assign #GATE_DELAY T02DC_ = rst ? 1'bz : ((0|g37308|g37310) ? 1'b0 : 1'bz);
// Gate A2-U157A
pullup(g37154);
assign #GATE_DELAY g37154 = rst ? 1'bz : ((0|g37153) ? 1'b0 : 1'bz);
// Gate A2-U328B
pullup(g37306);
assign #GATE_DELAY g37306 = rst ? 0 : ((0|g37310|T01DC_|GOJAM) ? 1'b0 : 1'bz);
// Gate A2-U222A
pullup(g37217);
assign #GATE_DELAY g37217 = rst ? 0 : ((0|P04|RINGB_) ? 1'b0 : 1'bz);
// Gate A2-U316A
pullup(g37325);
assign #GATE_DELAY g37325 = rst ? 0 : ((0|g37321|EVNSET_) ? 1'b0 : 1'bz);
// Gate A2-U315B
pullup(g37327);
assign #GATE_DELAY g37327 = rst ? 0 : ((0|T06DC_|g37331|GOJAM) ? 1'b0 : 1'bz);
// Gate A2-U222B
pullup(g37218);
assign #GATE_DELAY g37218 = rst ? 0 : ((0|RINGA_|P04_) ? 1'b0 : 1'bz);
// Gate A2-U301A A2-U301B A2-U302A
pullup(RT_);
assign #GATE_DELAY RT_ = rst ? 1'bz : ((0|RT) ? 1'b0 : 1'bz);
// Gate A2-U330A
pullup(g37303);
assign #GATE_DELAY g37303 = rst ? 1'bz : ((0|T12DC_|g37306) ? 1'b0 : 1'bz);
// Gate A2-U221B
pullup(P05_);
assign #GATE_DELAY P05_ = rst ? 1'bz : ((0|P05|g37218) ? 1'b0 : 1'bz);
// Gate A2-U228B
pullup(g37206);
assign #GATE_DELAY g37206 = rst ? 1'bz : ((0|RINGB_|P01_) ? 1'b0 : 1'bz);
// Gate A2-U148B A2-U149B
pullup(RINGA_);
assign #GATE_DELAY RINGA_ = rst ? 1'bz : ((0|g37111) ? 1'b0 : 1'bz);
// Gate A2-U321A
pullup(g37317);
assign #GATE_DELAY g37317 = rst ? 1'bz : ((0|g37316|g37318) ? 1'b0 : 1'bz);
// Gate A2-U333A
pullup(MT10);
assign #GATE_DELAY MT10 = rst ? 0 : ((0|T10_) ? 1'b0 : 1'bz);
// Gate A2-U333B
pullup(MT11);
assign #GATE_DELAY MT11 = rst ? 0 : ((0|T11_) ? 1'b0 : 1'bz);
// Gate A2-U357B
pullup(MT12);
assign #GATE_DELAY MT12 = rst ? 1'bz : ((0|T12_) ? 1'b0 : 1'bz);
// Gate A2-U330B
pullup(T12DC_);
assign #GATE_DELAY T12DC_ = rst ? 0 : ((0|T12SET|GOJAM|g37303) ? 1'b0 : 1'bz);
// Gate A2-U323A
pullup(T03DC_);
assign #GATE_DELAY T03DC_ = rst ? 1'bz : ((0|g37314|g37312) ? 1'b0 : 1'bz);
// Gate A2-U324B
pullup(g37312);
assign #GATE_DELAY g37312 = rst ? 0 : ((0|ODDSET_|T02DC_) ? 1'b0 : 1'bz);
// Gate A2-U59B A2-U158B A2-U160A A2-U159A
pullup(EVNSET_);
assign #GATE_DELAY EVNSET_ = rst ? 0 : ((0|EVNSET) ? 1'b0 : 1'bz);
// Gate A2-U152A
pullup(g37149);
assign #GATE_DELAY g37149 = rst ? 0 : ((0|g37154|g37148) ? 1'b0 : 1'bz);
// Gate A2-U312A
pullup(g37333);
assign #GATE_DELAY g37333 = rst ? 0 : ((0|T07DC_|EVNSET_) ? 1'b0 : 1'bz);
// Gate A2-U311B
pullup(g37335);
assign #GATE_DELAY g37335 = rst ? 0 : ((0|g37339|T08DC_|GOJAM) ? 1'b0 : 1'bz);
// Gate A2-U309A
pullup(T09DC_);
assign #GATE_DELAY T09DC_ = rst ? 1'bz : ((0|g37337|g37339) ? 1'b0 : 1'bz);
// Gate A2-U154A
pullup(OVFSTB_);
assign #GATE_DELAY OVFSTB_ = rst ? 1'bz : ((0|g37149) ? 1'b0 : 1'bz);
// Gate A2-U156A
pullup(g37153);
assign #GATE_DELAY g37153 = rst ? 0 : ((0|g37152) ? 1'b0 : 1'bz);
// Gate A2-U212B
pullup(SB2);
assign #GATE_DELAY SB2 = rst ? 0 : ((0|P02|P05_) ? 1'b0 : 1'bz);
// Gate A2-U305B
pullup(g37348);
assign #GATE_DELAY g37348 = rst ? 0 : ((0|GOJAM|g37346|g37347) ? 1'b0 : 1'bz);
// Gate A2-U220A
pullup(SB0);
assign #GATE_DELAY SB0 = rst ? 1'bz : ((0|P02_|P05) ? 1'b0 : 1'bz);
// Gate A2-U151A
pullup(g37148);
assign #GATE_DELAY g37148 = rst ? 0 : ((0|g37149|CT_) ? 1'b0 : 1'bz);
// Gate A2-U313A
pullup(T07DC_);
assign #GATE_DELAY T07DC_ = rst ? 1'bz : ((0|g37329|g37331) ? 1'b0 : 1'bz);
// Gate A2-U207B
pullup(SB4);
assign #GATE_DELAY SB4 = rst ? 0 : ((0|P04|P02_) ? 1'b0 : 1'bz);
// Gate A2-U338A
pullup(MT08);
assign #GATE_DELAY MT08 = rst ? 0 : ((0|T08_) ? 1'b0 : 1'bz);
// Gate A2-U343B
pullup(MT07);
assign #GATE_DELAY MT07 = rst ? 0 : ((0|T07_) ? 1'b0 : 1'bz);
// Gate A2-U343A
pullup(MT06);
assign #GATE_DELAY MT06 = rst ? 0 : ((0|T06_) ? 1'b0 : 1'bz);
// Gate A2-U349B
pullup(MT05);
assign #GATE_DELAY MT05 = rst ? 0 : ((0|T05_) ? 1'b0 : 1'bz);
// Gate A2-U145A A2-U148A A2-U149A A2-U146A A2-U147A A2-U119A
pullup(CT_);
assign #GATE_DELAY CT_ = rst ? 1'bz : ((0|CT) ? 1'b0 : 1'bz);
// Gate A2-U207A
pullup(STOP);
assign #GATE_DELAY STOP = rst ? 1'bz : ((0|STOP_) ? 1'b0 : 1'bz);
// Gate A2-U353B
pullup(MT02);
assign #GATE_DELAY MT02 = rst ? 0 : ((0|T02_) ? 1'b0 : 1'bz);
// Gate A2-U357A
pullup(MT01);
assign #GATE_DELAY MT01 = rst ? 0 : ((0|T01_) ? 1'b0 : 1'bz);
// Gate A2-U137B
pullup(g37107);
assign #GATE_DELAY g37107 = rst ? 1'bz : ((0|g37101) ? 1'b0 : 1'bz);
// Gate A2-U153A
pullup(g37150);
assign #GATE_DELAY g37150 = rst ? 0 : ((0|g37149|g37152) ? 1'b0 : 1'bz);
// Gate A2-U155A
pullup(g37152);
assign #GATE_DELAY g37152 = rst ? 1'bz : ((0|g37148|g37150) ? 1'b0 : 1'bz);
// Gate A2-U132B A2-U139B A2-U140B
pullup(PHS4_);
assign #GATE_DELAY PHS4_ = rst ? 1'bz : ((0|PHS4) ? 1'b0 : 1'bz);
// Gate A2-U354A A2-U354B
pullup(T02_);
assign #GATE_DELAY T02_ = rst ? 1'bz : ((0|T02) ? 1'b0 : 1'bz);
// Gate A2-U326B
pullup(CINORM);
assign #GATE_DELAY CINORM = rst ? 1'bz : ((0|MP3A) ? 1'b0 : 1'bz);
// Gate A2-U307A
pullup(T10DC_);
assign #GATE_DELAY T10DC_ = rst ? 1'bz : ((0|g37341|g37343) ? 1'b0 : 1'bz);
// Gate A2-U217A
pullup(FS01_);
assign #GATE_DELAY FS01_ = rst ? 0 : ((0|FS01|F01B) ? 1'b0 : 1'bz);
// Gate A2-U217B
pullup(FS01);
assign #GATE_DELAY FS01 = rst ? 1'bz : ((0|FS01_|F01A) ? 1'b0 : 1'bz);
// Gate A2-U345A A2-U345B A2-U344A A2-U344B
pullup(T06_);
assign #GATE_DELAY T06_ = rst ? 1'bz : ((0|T06) ? 1'b0 : 1'bz);
// Gate A2-U201A A2-U206A A2-U206B A2-U205A A2-U205B A2-U204A A2-U204B A2-U202A A2-U202B
pullup(GOJAM);
assign #GATE_DELAY GOJAM = rst ? 1'bz : ((0|GOJAM_) ? 1'b0 : 1'bz);
// Gate A2-U318A
pullup(g37321);
assign #GATE_DELAY g37321 = rst ? 1'bz : ((0|g37320|g37322) ? 1'b0 : 1'bz);
// Gate A2-U209B
pullup(STOP_);
assign #GATE_DELAY STOP_ = rst ? 0 : ((0|STOPA|g37239) ? 1'b0 : 1'bz);
// Gate A2-U140A
pullup(CLK);
assign #GATE_DELAY CLK = rst ? 0 : ((0|WT_) ? 1'b0 : 1'bz);
// Gate A2-U224A
pullup(g37213);
assign #GATE_DELAY g37213 = rst ? 0 : ((0|P03|RINGA_) ? 1'b0 : 1'bz);
// Gate A2-U341A A2-U341B A2-U342A A2-U342B
pullup(T07_);
assign #GATE_DELAY T07_ = rst ? 1'bz : ((0|T07) ? 1'b0 : 1'bz);
// Gate A2-U302B
pullup(UNF);
assign #GATE_DELAY UNF = rst ? 0 : ((0|WL16_|WL15|OVFSTB_) ? 1'b0 : 1'bz);
// Gate A2-U328A
pullup(T01DC_);
assign #GATE_DELAY T01DC_ = rst ? 1'bz : ((0|g37304|g37306) ? 1'b0 : 1'bz);
// Gate A2-U212A
pullup(STOPA);
assign #GATE_DELAY STOPA = rst ? 1'bz : ((0|g37232|g37233) ? 1'b0 : 1'bz);
// Gate A2-U144A A2-U143A
pullup(CT);
assign #GATE_DELAY CT = rst ? 0 : ((0|g37139) ? 1'b0 : 1'bz);
// Gate A2-U318B
pullup(g37322);
assign #GATE_DELAY g37322 = rst ? 0 : ((0|g37327|g37321|GOJAM) ? 1'b0 : 1'bz);
// Gate A2-U145B
pullup(g37114);
assign #GATE_DELAY g37114 = rst ? 1'bz : ((0|g37113|g37118) ? 1'b0 : 1'bz);
// Gate A2-U331A
pullup(UNF_);
assign #GATE_DELAY UNF_ = rst ? 1'bz : ((0|UNF) ? 1'b0 : 1'bz);
// Gate A2-U317A A2-U347A A2-U348A A2-U348B A2-U346A A2-U346B
pullup(T05_);
assign #GATE_DELAY T05_ = rst ? 1'bz : ((0|T05) ? 1'b0 : 1'bz);
// Gate A2-U226A
pullup(g37209);
assign #GATE_DELAY g37209 = rst ? 0 : ((0|P02|RINGB_) ? 1'b0 : 1'bz);
// Gate A2-U226B
pullup(g37210);
assign #GATE_DELAY g37210 = rst ? 0 : ((0|RINGA_|P02_) ? 1'b0 : 1'bz);
// Gate A2-U228A
pullup(g37205);
assign #GATE_DELAY g37205 = rst ? 0 : ((0|P01|RINGA_) ? 1'b0 : 1'bz);
// Gate A2-U332A
pullup(OVF_);
assign #GATE_DELAY OVF_ = rst ? 1'bz : ((0|OVF) ? 1'b0 : 1'bz);
// Gate A2-U230B
pullup(g37202);
assign #GATE_DELAY g37202 = rst ? 0 : ((0|P04|P05|RINGA_) ? 1'b0 : 1'bz);
// Gate A2-U306B
pullup(g37345);
assign #GATE_DELAY g37345 = rst ? 0 : ((0|T10DC_|ODDSET_) ? 1'b0 : 1'bz);
// Gate A2-U314B
pullup(g37329);
assign #GATE_DELAY g37329 = rst ? 0 : ((0|T06DC_|ODDSET_) ? 1'b0 : 1'bz);
// Gate A2-U313B
pullup(g37331);
assign #GATE_DELAY g37331 = rst ? 0 : ((0|g37335|T07DC_|GOJAM) ? 1'b0 : 1'bz);
// Gate A2-U230A
pullup(g37201);
assign #GATE_DELAY g37201 = rst ? 0 : ((0|P05_|P04_|RINGB_) ? 1'b0 : 1'bz);
// Gate A2-U227B
pullup(P02_);
assign #GATE_DELAY P02_ = rst ? 0 : ((0|P02|g37206) ? 1'b0 : 1'bz);
// Gate A2-U141B
pullup(MONWT);
assign #GATE_DELAY MONWT = rst ? 0 : ((0|WT_) ? 1'b0 : 1'bz);
// Gate A2-U136B
pullup(g37106);
assign #GATE_DELAY g37106 = rst ? 0 : ((0|g37105|g37103) ? 1'b0 : 1'bz);
// Gate A2-U154B A2-U155B
pullup(RINGB_);
assign #GATE_DELAY RINGB_ = rst ? 0 : ((0|g37114) ? 1'b0 : 1'bz);
// Gate A2-U146B
pullup(g37117);
assign #GATE_DELAY g37117 = rst ? 1'bz : ((0|g37118|g37112) ? 1'b0 : 1'bz);
// Gate A2-U322A
pullup(g37316);
assign #GATE_DELAY g37316 = rst ? 0 : ((0|EVNSET_|T03DC_) ? 1'b0 : 1'bz);
// Gate A2-U156B
pullup(EVNSET);
assign #GATE_DELAY EVNSET = rst ? 1'bz : ((0|RINGB_) ? 1'b0 : 1'bz);
// Gate A2-U158A A2-U208A A2-U208B
pullup(GOJAM_);
assign #GATE_DELAY GOJAM_ = rst ? 0 : ((0|STRT2|STOPA) ? 1'b0 : 1'bz);
// Gate A2-U349A
pullup(MT04);
assign #GATE_DELAY MT04 = rst ? 0 : ((0|T04_) ? 1'b0 : 1'bz);
// Gate A2-U329B
pullup(g37304);
assign #GATE_DELAY g37304 = rst ? 0 : ((0|ODDSET_|T12DC_) ? 1'b0 : 1'bz);
// Gate A2-U309B
pullup(g37339);
assign #GATE_DELAY g37339 = rst ? 0 : ((0|g37343|T09DC_|GOJAM) ? 1'b0 : 1'bz);
// Gate A2-U360A
pullup(A2);
assign #GATE_DELAY A2 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A2-U147B
pullup(g37118);
assign #GATE_DELAY g37118 = rst ? 0 : ((0|g37117|g37113) ? 1'b0 : 1'bz);
// Gate A2-U307B
pullup(g37343);
assign #GATE_DELAY g37343 = rst ? 0 : ((0|g37348|T10DC_|GOJAM) ? 1'b0 : 1'bz);
// Gate A2-U203B
pullup(MGOJAM);
assign #GATE_DELAY MGOJAM = rst ? 1'bz : ((0|GOJAM_) ? 1'b0 : 1'bz);
// Gate A2-U131A
pullup(g37102);
assign #GATE_DELAY g37102 = rst ? 0 : ((0|CLOCK|g37103|g37101) ? 1'b0 : 1'bz);
// Gate A2-U133B
pullup(g37103);
assign #GATE_DELAY g37103 = rst ? 1'bz : ((0|CLOCK|g37102|PHS2) ? 1'b0 : 1'bz);
// Gate A2-U132A
pullup(g37101);
assign #GATE_DELAY g37101 = rst ? 0 : ((0|g37105|g37102) ? 1'b0 : 1'bz);
// Gate A2-U213B
pullup(g37233);
assign #GATE_DELAY g37233 = rst ? 0 : ((0|STOPA|g37231) ? 1'b0 : 1'bz);
// Gate A2-U218A
pullup(F01A);
assign #GATE_DELAY F01A = rst ? 0 : ((0|F01C|F01B|P01_) ? 1'b0 : 1'bz);
// Gate A2-U18B
pullup(F01C);
assign #GATE_DELAY F01C = rst ? 0 : ((0|FS01|F01A) ? 1'b0 : 1'bz);
// Gate A2-U219B
pullup(F01B);
assign #GATE_DELAY F01B = rst ? 1'bz : ((0|F01A|P01_|F01D) ? 1'b0 : 1'bz);
// Gate A2-U219A
pullup(F01D);
assign #GATE_DELAY F01D = rst ? 0 : ((0|F01B|FS01_) ? 1'b0 : 1'bz);
// Gate A2-U324A A2-U347B
pullup(T02);
assign #GATE_DELAY T02 = rst ? 0 : ((0|EVNSET_|T02DC_) ? 1'b0 : 1'bz);
// Gate A2-U229B
pullup(P01_);
assign #GATE_DELAY P01_ = rst ? 0 : ((0|P01|g37202) ? 1'b0 : 1'bz);
// Gate A2-U359A A2-U359B A2-U358A
pullup(T12_);
assign #GATE_DELAY T12_ = rst ? 0 : ((0|T12) ? 1'b0 : 1'bz);
// Gate A2-U224B
pullup(g37214);
assign #GATE_DELAY g37214 = rst ? 1'bz : ((0|RINGB_|P03_) ? 1'b0 : 1'bz);
// Gate A2-U335A A2-U335B A2-U334A A2-U334B
pullup(T10_);
assign #GATE_DELAY T10_ = rst ? 1'bz : ((0|T10) ? 1'b0 : 1'bz);
// Gate A2-U144B
pullup(g37111);
assign #GATE_DELAY g37111 = rst ? 0 : ((0|g37112|g37117) ? 1'b0 : 1'bz);
// Gate A2-U142B
pullup(g37112);
assign #GATE_DELAY g37112 = rst ? 0 : ((0|g37113|g37107|g37111) ? 1'b0 : 1'bz);
// Gate A2-U303A A2-U320A A2-U320B A2-U326A
pullup(T12SET);
assign #GATE_DELAY T12SET = rst ? 1'bz : ((0|EVNSET_|g37343|g37339|g37318|g37322|g37314|g37327|g37331|g37335|g37306|g37310) ? 1'b0 : 1'bz);
// Gate A2-U142A
pullup(g37139);
assign #GATE_DELAY g37139 = rst ? 1'bz : ((0|g37102) ? 1'b0 : 1'bz);
// Gate A2-U143B
pullup(g37113);
assign #GATE_DELAY g37113 = rst ? 0 : ((0|g37112|g37107|g37114) ? 1'b0 : 1'bz);
// Gate A2-U323B
pullup(g37314);
assign #GATE_DELAY g37314 = rst ? 0 : ((0|g37318|T03DC_|GOJAM) ? 1'b0 : 1'bz);
// Gate A2-U214A
pullup(g37230);
assign #GATE_DELAY g37230 = rst ? 1'bz : ((0|GOSET_) ? 1'b0 : 1'bz);
// Gate A2-U321B
pullup(g37318);
assign #GATE_DELAY g37318 = rst ? 0 : ((0|g37322|g37317|GOJAM) ? 1'b0 : 1'bz);
// Gate A2-U211B
pullup(g37236);
assign #GATE_DELAY g37236 = rst ? 0 : ((0|EVNSET_|T12DC_|g37235) ? 1'b0 : 1'bz);
// Gate A2-U135B
pullup(g37105);
assign #GATE_DELAY g37105 = rst ? 1'bz : ((0|g37102|g37106) ? 1'b0 : 1'bz);
// Gate A2-U310B
pullup(g37337);
assign #GATE_DELAY g37337 = rst ? 0 : ((0|T08DC_|ODDSET_) ? 1'b0 : 1'bz);
// Gate A2-U216A A2-U215A
pullup(GOSET_);
assign #GATE_DELAY GOSET_ = rst ? 0 : ((0|ALGA|MSTRTP|SBY|g37229|STRT1|STRT2) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
