// Verilog module auto-generated for AGC module A52 by dumbVerilog.py

module A52 ( 
  rst, p4SW, MCTRAL_, MPAL_, MRCH, MRPTAL_, MSCAFL_, MSCDBL_, MT01, MT05,
  MT12, MTCAL_, MVFAIL_, MWATCH_, MWCH, MWL01, MWL02, MWL03, MWL04, MWL05,
  MWL06, MWSG, DBLTST, DOSCAL, MAMU, MDT01, MDT02, MDT03, MDT04, MDT05, MDT06,
  MDT07, MDT08, MDT09, MDT10, MDT11, MDT12, MDT13, MDT14, MDT15, MDT16, MLDCH,
  MLOAD, MNHNC, MNHRPT, MNHSBF, MONPAR, MONWBK, MRDCH, MREAD, MSBSTP, MSTP,
  MSTRT, MTCSAI, NHALGA
);

input wire rst, p4SW;

inout wire MCTRAL_, MPAL_, MRCH, MRPTAL_, MSCAFL_, MSCDBL_, MT01, MT05, MT12,
  MTCAL_, MVFAIL_, MWATCH_, MWCH, MWL01, MWL02, MWL03, MWL04, MWL05, MWL06,
  MWSG;

output wire DBLTST, DOSCAL, MAMU, MDT01, MDT02, MDT03, MDT04, MDT05, MDT06,
  MDT07, MDT08, MDT09, MDT10, MDT11, MDT12, MDT13, MDT14, MDT15, MDT16, MLDCH,
  MLOAD, MNHNC, MNHRPT, MNHSBF, MONPAR, MONWBK, MRDCH, MREAD, MSBSTP, MSTP,
  MSTRT, MTCSAI, NHALGA;

parameter GATE_DELAY = 0.2; // This default may be overridden at compile time.
initial $display("Gate delay (A52) will be %f ns.", GATE_DELAY*100);

// Gate A52-U115B
pullup(g98031);
assign #GATE_DELAY g98031 = rst ? 0 : ((0|g98030|g98049) ? 1'b0 : 1'bz);
// Gate A52-U128B
pullup(g98057);
assign #GATE_DELAY g98057 = rst ? 0 : ((0|g98015|g98039) ? 1'b0 : 1'bz);
// Gate A52-U127B
pullup(g98055);
assign #GATE_DELAY g98055 = rst ? 0 : ((0|g98015|g98037) ? 1'b0 : 1'bz);
// Gate A52-U118B
pullup(g98037);
assign #GATE_DELAY g98037 = rst ? 0 : ((0|g98036|g98055) ? 1'b0 : 1'bz);
// Gate A52-U119B
pullup(g98039);
assign #GATE_DELAY g98039 = rst ? 0 : ((0|g98038|g98057) ? 1'b0 : 1'bz);
// Gate A52-U101B A52-U110A A52-U110B
pullup(g98020);
assign #GATE_DELAY g98020 = rst ? 1'bz : ((0|g98005|g98004|g98002|g98008|g98006|g98007|g98009|g98010) ? 1'b0 : 1'bz);
// Gate A52-U105B A52-U107B
pullup(g98015);
assign #GATE_DELAY g98015 = rst ? 1'bz : ((0|g98014|g98013) ? 1'b0 : 1'bz);
// Gate A52-U102A
pullup(g98004);
assign #GATE_DELAY g98004 = rst ? 1'bz : ((0|MWL02) ? 1'b0 : 1'bz);
// Gate A52-U101A
pullup(g98002);
assign #GATE_DELAY g98002 = rst ? 0 : ((0|MWL01) ? 1'b0 : 1'bz);
// Gate A52-U113B
pullup(g98027);
assign #GATE_DELAY g98027 = rst ? 0 : ((0|g98026|g98045) ? 1'b0 : 1'bz);
// Gate A52-U122B
pullup(g98045);
assign #GATE_DELAY g98045 = rst ? 0 : ((0|g98015|g98027) ? 1'b0 : 1'bz);
// Gate A52-U113A
pullup(g98026);
assign #GATE_DELAY g98026 = rst ? 1'bz : ((0|MPAL_|g98024) ? 1'b0 : 1'bz);
// Gate A52-U112B
pullup(g98025);
assign #GATE_DELAY g98025 = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A52-U129B
pullup(g98059);
assign #GATE_DELAY g98059 = rst ? 0 : ((0|g98015|g98041) ? 1'b0 : 1'bz);
// Gate A52-U106A
pullup(g98012);
assign #GATE_DELAY g98012 = rst ? 1'bz : ((0|MT12|g98013) ? 1'b0 : 1'bz);
// Gate A52-U120B
pullup(g98041);
assign #GATE_DELAY g98041 = rst ? 0 : ((0|g98040|g98059) ? 1'b0 : 1'bz);
// Gate A52-U118A
pullup(g98036);
assign #GATE_DELAY g98036 = rst ? 1'bz : ((0|MCTRAL_) ? 1'b0 : 1'bz);
// Gate A52-U119A
pullup(g98038);
assign #GATE_DELAY g98038 = rst ? 1'bz : ((0|MSCAFL_) ? 1'b0 : 1'bz);
// Gate A52-U121A
pullup(MDT01);
assign #GATE_DELAY MDT01 = rst ? 0 : ((0|g98018|g98023) ? 1'b0 : 1'bz);
// Gate A52-U122A
pullup(MDT02);
assign #GATE_DELAY MDT02 = rst ? 0 : ((0|g98018|g98027) ? 1'b0 : 1'bz);
// Gate A52-U123A
pullup(MDT03);
assign #GATE_DELAY MDT03 = rst ? 0 : ((0|g98018|g98029) ? 1'b0 : 1'bz);
// Gate A52-U124A
pullup(MDT04);
assign #GATE_DELAY MDT04 = rst ? 0 : ((0|g98018|g98031) ? 1'b0 : 1'bz);
// Gate A52-U125A
pullup(MDT05);
assign #GATE_DELAY MDT05 = rst ? 0 : ((0|g98018|g98033) ? 1'b0 : 1'bz);
// Gate A52-U126A
pullup(MDT06);
assign #GATE_DELAY MDT06 = rst ? 0 : ((0|g98018|g98035) ? 1'b0 : 1'bz);
// Gate A52-U127A
pullup(MDT07);
assign #GATE_DELAY MDT07 = rst ? 0 : ((0|g98018|g98037) ? 1'b0 : 1'bz);
// Gate A52-U128A
pullup(MDT08);
assign #GATE_DELAY MDT08 = rst ? 0 : ((0|g98018|g98039) ? 1'b0 : 1'bz);
// Gate A52-U129A
pullup(MDT09);
assign #GATE_DELAY MDT09 = rst ? 0 : ((0|g98018|g98041) ? 1'b0 : 1'bz);
// Gate A52-U112A
pullup(g98024);
assign #GATE_DELAY g98024 = rst ? 0 : ((0|MT05) ? 1'b0 : 1'bz);
// Gate A52-U107A
pullup(g98014);
assign #GATE_DELAY g98014 = rst ? 0 : ((0|MWCH) ? 1'b0 : 1'bz);
// Gate A52-U106B
pullup(g98013);
assign #GATE_DELAY g98013 = rst ? 0 : ((0|g98012|g98020) ? 1'b0 : 1'bz);
// Gate A52-U109A A52-U109B
pullup(g98018);
assign #GATE_DELAY g98018 = rst ? 1'bz : ((0|g98017) ? 1'b0 : 1'bz);
// Gate A52-U104B
pullup(g98009);
assign #GATE_DELAY g98009 = rst ? 1'bz : ((0|MT01) ? 1'b0 : 1'bz);
// Gate A52-U124B
pullup(g98049);
assign #GATE_DELAY g98049 = rst ? 0 : ((0|g98015|g98031) ? 1'b0 : 1'bz);
// Gate A52-U123B
pullup(g98047);
assign #GATE_DELAY g98047 = rst ? 0 : ((0|g98015|g98029) ? 1'b0 : 1'bz);
// Gate A52-U126B
pullup(g98053);
assign #GATE_DELAY g98053 = rst ? 0 : ((0|g98015|g98035) ? 1'b0 : 1'bz);
// Gate A52-U117A
pullup(g98034);
assign #GATE_DELAY g98034 = rst ? 1'bz : ((0|MVFAIL_) ? 1'b0 : 1'bz);
// Gate A52-U104A
pullup(g98008);
assign #GATE_DELAY g98008 = rst ? 1'bz : ((0|MWL06) ? 1'b0 : 1'bz);
// Gate A52-U103B
pullup(g98007);
assign #GATE_DELAY g98007 = rst ? 1'bz : ((0|MWL05) ? 1'b0 : 1'bz);
// Gate A52-U115A
pullup(g98030);
assign #GATE_DELAY g98030 = rst ? 1'bz : ((0|MRPTAL_) ? 1'b0 : 1'bz);
// Gate A52-U108B
pullup(g98017);
assign #GATE_DELAY g98017 = rst ? 1'bz : ((0|g98016|g98013) ? 1'b0 : 1'bz);
// Gate A52-U103A
pullup(g98006);
assign #GATE_DELAY g98006 = rst ? 1'bz : ((0|MWL04) ? 1'b0 : 1'bz);
// Gate A52-U108A
pullup(g98016);
assign #GATE_DELAY g98016 = rst ? 0 : ((0|MRCH) ? 1'b0 : 1'bz);
// Gate A52-U102B
pullup(g98005);
assign #GATE_DELAY g98005 = rst ? 1'bz : ((0|MWL03) ? 1'b0 : 1'bz);
// Gate A52-U114A
pullup(g98028);
assign #GATE_DELAY g98028 = rst ? 1'bz : ((0|MTCAL_) ? 1'b0 : 1'bz);
// Gate A52-U117B
pullup(g98035);
assign #GATE_DELAY g98035 = rst ? 0 : ((0|g98034|g98053) ? 1'b0 : 1'bz);
// Gate A52-U105A
pullup(g98010);
assign #GATE_DELAY g98010 = rst ? 0 : ((0|MWSG) ? 1'b0 : 1'bz);
// Gate A52-U114B
pullup(g98029);
assign #GATE_DELAY g98029 = rst ? 0 : ((0|g98028|g98047) ? 1'b0 : 1'bz);
// Gate A52-U116B
pullup(g98033);
assign #GATE_DELAY g98033 = rst ? 0 : ((0|g98032|g98051) ? 1'b0 : 1'bz);
// Gate A52-U116A
pullup(g98032);
assign #GATE_DELAY g98032 = rst ? 1'bz : ((0|MWATCH_) ? 1'b0 : 1'bz);
// Gate A52-U125B
pullup(g98051);
assign #GATE_DELAY g98051 = rst ? 0 : ((0|g98015|g98033) ? 1'b0 : 1'bz);
// Gate A52-U121B
pullup(g98043);
assign #GATE_DELAY g98043 = rst ? 0 : ((0|g98015|g98023) ? 1'b0 : 1'bz);
// Gate A52-U111A
pullup(g98022);
assign #GATE_DELAY g98022 = rst ? 1'bz : ((0|MPAL_) ? 1'b0 : 1'bz);
// Gate A52-U111B
pullup(g98023);
assign #GATE_DELAY g98023 = rst ? 0 : ((0|g98022|g98043) ? 1'b0 : 1'bz);
// Gate A52-U120A
pullup(g98040);
assign #GATE_DELAY g98040 = rst ? 1'bz : ((0|MSCDBL_) ? 1'b0 : 1'bz);
// End of NOR gates

assign DBLTST = 1'b0;
assign DOSCAL = 1'b0;
assign MAMU = 1'b0;
assign MDT10 = 1'b0;
assign MDT11 = 1'b0;
assign MDT12 = 1'b0;
assign MDT13 = 1'b0;
assign MDT14 = 1'b0;
assign MDT15 = 1'b0;
assign MDT16 = 1'b0;
assign MLDCH = 1'b0;
assign MLOAD = 1'b0;
assign MNHNC = 1'b0;
assign MNHRPT = 1'b0;
assign MNHSBF = 1'b0;
assign MONPAR = 1'b0;
assign MONWBK = 1'b0;
assign MRDCH = 1'b0;
assign MREAD = 1'b0;
assign MSBSTP = 1'b0;
assign MSTP = 1'b0;
assign MSTRT = 1'b0;
assign MTCSAI = 1'b0;
assign NHALGA = 1'b0;

endmodule
