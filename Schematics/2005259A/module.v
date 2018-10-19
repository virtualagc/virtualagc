// Verilog module auto-generated for AGC module A1 by dumbVerilog.py

module A1 ( 
  rst, CGA1, FS01_, RCHAT_, RCHBT_, F03B, F07A, F09A, F17A, F18A, F18A_,
  F25A, FS06, FS07, FS07_, FS08, CHAT01, CHAT02, CHAT03, CHAT04, CHAT05,
  CHAT06, CHAT07, CHAT08, CHAT09, CHAT10, CHAT11, CHAT12, CHAT13, CHAT14,
  CHBT01, CHBT02, CHBT03, CHBT04, CHBT05, CHBT06, CHBT07, CHBT08, CHBT09,
  CHBT10, CHBT11, CHBT12, CHBT13, CHBT14, F02A, F02B, F03A, F03B_, F04A,
  F04B, F05A, F05B, F06A, F06B, F07A_, F07B, F08A, F08B, F09B, F10A, F10B,
  F11A, F11B, F12A, F12B, F13A, F13B, F14A, F14B, F15A, F15B, F16A, F16B,
  F17B, F18AX, F18B, F19A, F19B, F20A, F20B, F21A, F21B, F22A, F22B, F23A,
  F23B, F24A, F24B, F25B, F26A, F26B, F27A, F27B, F28A, F28B, F29A, F29B,
  F30A, F30B, F31A, F31B, F32A, F32B, F33A, F33B, FS02, FS02A, FS03, FS03A,
  FS04, FS04A, FS05, FS05A, FS06_, FS07A, FS08_, FS09, FS10, FS11, FS12,
  FS13, FS14, FS15, FS16, FS17, FS18, FS19, FS20, FS21, FS22, FS23, FS24,
  FS25, FS26, FS27, FS28, FS29, FS30, FS31, FS32, FS33
);

input wire rst, CGA1, FS01_, RCHAT_, RCHBT_;

inout wire F03B, F07A, F09A, F17A, F18A, F18A_, F25A, FS06, FS07, FS07_,
  FS08;

output wire CHAT01, CHAT02, CHAT03, CHAT04, CHAT05, CHAT06, CHAT07, CHAT08,
  CHAT09, CHAT10, CHAT11, CHAT12, CHAT13, CHAT14, CHBT01, CHBT02, CHBT03,
  CHBT04, CHBT05, CHBT06, CHBT07, CHBT08, CHBT09, CHBT10, CHBT11, CHBT12,
  CHBT13, CHBT14, F02A, F02B, F03A, F03B_, F04A, F04B, F05A, F05B, F06A,
  F06B, F07A_, F07B, F08A, F08B, F09B, F10A, F10B, F11A, F11B, F12A, F12B,
  F13A, F13B, F14A, F14B, F15A, F15B, F16A, F16B, F17B, F18AX, F18B, F19A,
  F19B, F20A, F20B, F21A, F21B, F22A, F22B, F23A, F23B, F24A, F24B, F25B,
  F26A, F26B, F27A, F27B, F28A, F28B, F29A, F29B, F30A, F30B, F31A, F31B,
  F32A, F32B, F33A, F33B, FS02, FS02A, FS03, FS03A, FS04, FS04A, FS05, FS05A,
  FS06_, FS07A, FS08_, FS09, FS10, FS11, FS12, FS13, FS14, FS15, FS16, FS17,
  FS18, FS19, FS20, FS21, FS22, FS23, FS24, FS25, FS26, FS27, FS28, FS29,
  FS30, FS31, FS32, FS33;

parameter GATE_DELAY = 0.2; // This default may be overridden at compile time.
initial $display("Gate delay (A1) will be %f ns.", GATE_DELAY*100);

// Gate A1-U242A
pullup(g38435);
assign #GATE_DELAY g38435 = rst ? 1'bz : ((0|g38433|F28A|F29B) ? 1'b0 : 1'bz);
// Gate A1-U126B
pullup(FS02A);
assign #GATE_DELAY FS02A = rst ? 0 : ((0|g38204) ? 1'b0 : 1'bz);
// Gate A1-U239B
pullup(F28A);
assign #GATE_DELAY F28A = rst ? 0 : ((0|g38423|g38424) ? 1'b0 : 1'bz);
// Gate A1-U238B
pullup(F28B);
assign #GATE_DELAY F28B = rst ? 0 : ((0|FS28|g38425) ? 1'b0 : 1'bz);
// Gate A1-U252A
pullup(g38465);
assign #GATE_DELAY g38465 = rst ? 1'bz : ((0|F31A|g38463|F32B) ? 1'b0 : 1'bz);
// Gate A1-U253A
pullup(g38463);
assign #GATE_DELAY g38463 = rst ? 0 : ((0|g38465|F31A|F32A) ? 1'b0 : 1'bz);
// Gate A1-U244B
pullup(FS29);
assign #GATE_DELAY FS29 = rst ? 0 : ((0|g38435|g38434) ? 1'b0 : 1'bz);
// Gate A1-U154B
pullup(F16A);
assign #GATE_DELAY F16A = rst ? 0 : ((0|g38163|g38164) ? 1'b0 : 1'bz);
// Gate A1-U153B
pullup(F16B);
assign #GATE_DELAY F16B = rst ? 0 : ((0|FS16|g38165) ? 1'b0 : 1'bz);
// Gate A1-U105A
pullup(CHAT04);
assign #GATE_DELAY CHAT04 = rst ? 0 : ((0|g38274|RCHAT_) ? 1'b0 : 1'bz);
// Gate A1-U135A
pullup(CHAT05);
assign #GATE_DELAY CHAT05 = rst ? 0 : ((0|g38104|RCHAT_) ? 1'b0 : 1'bz);
// Gate A1-U135B
pullup(CHAT06);
assign #GATE_DELAY CHAT06 = rst ? 0 : ((0|RCHAT_|g38114) ? 1'b0 : 1'bz);
// Gate A1-U142A
pullup(CHAT07);
assign #GATE_DELAY CHAT07 = rst ? 0 : ((0|RCHAT_|g38124) ? 1'b0 : 1'bz);
// Gate A1-U245A
pullup(g38445);
assign #GATE_DELAY g38445 = rst ? 1'bz : ((0|g38443|F29A|F30B) ? 1'b0 : 1'bz);
// Gate A1-U112B
pullup(CHAT01);
assign #GATE_DELAY CHAT01 = rst ? 0 : ((0|RCHAT_|g38244) ? 1'b0 : 1'bz);
// Gate A1-U112A
pullup(CHAT02);
assign #GATE_DELAY CHAT02 = rst ? 0 : ((0|RCHAT_|g38254) ? 1'b0 : 1'bz);
// Gate A1-U107B
pullup(CHAT03);
assign #GATE_DELAY CHAT03 = rst ? 0 : ((0|g38264|RCHAT_) ? 1'b0 : 1'bz);
// Gate A1-U142B
pullup(CHAT08);
assign #GATE_DELAY CHAT08 = rst ? 0 : ((0|g38134|RCHAT_) ? 1'b0 : 1'bz);
// Gate A1-U148B
pullup(CHAT09);
assign #GATE_DELAY CHAT09 = rst ? 0 : ((0|g38144|RCHAT_) ? 1'b0 : 1'bz);
// Gate A1-U203A
pullup(g38374);
assign #GATE_DELAY g38374 = rst ? 1'bz : ((0|g38373|FS25) ? 1'b0 : 1'bz);
// Gate A1-U125A
pullup(g38213);
assign #GATE_DELAY g38213 = rst ? 0 : ((0|F03A|F02A|g38215) ? 1'b0 : 1'bz);
// Gate A1-U123A
pullup(g38214);
assign #GATE_DELAY g38214 = rst ? 1'bz : ((0|FS03|g38213) ? 1'b0 : 1'bz);
// Gate A1-U225B
pullup(F19A);
assign #GATE_DELAY F19A = rst ? 0 : ((0|g38314|g38313) ? 1'b0 : 1'bz);
// Gate A1-U226B
pullup(F19B);
assign #GATE_DELAY F19B = rst ? 0 : ((0|g38315|FS19) ? 1'b0 : 1'bz);
// Gate A1-U125B
pullup(g38215);
assign #GATE_DELAY g38215 = rst ? 1'bz : ((0|g38213|F03B|F02A) ? 1'b0 : 1'bz);
// Gate A1-U117B
pullup(F05A);
assign #GATE_DELAY F05A = rst ? 0 : ((0|g38234|g38233) ? 1'b0 : 1'bz);
// Gate A1-U111B
pullup(F07B);
assign #GATE_DELAY F07B = rst ? 0 : ((0|g38255|FS07) ? 1'b0 : 1'bz);
// Gate A1-U236B
pullup(F27A);
assign #GATE_DELAY F27A = rst ? 0 : ((0|g38414|g38413) ? 1'b0 : 1'bz);
// Gate A1-U235B
pullup(F27B);
assign #GATE_DELAY F27B = rst ? 0 : ((0|g38415|FS27) ? 1'b0 : 1'bz);
// Gate A1-U217A
pullup(g38334);
assign #GATE_DELAY g38334 = rst ? 1'bz : ((0|g38333|FS21) ? 1'b0 : 1'bz);
// Gate A1-U205A
pullup(g38375);
assign #GATE_DELAY g38375 = rst ? 1'bz : ((0|g38373|F24A|F25B) ? 1'b0 : 1'bz);
// Gate A1-U113A
pullup(g38244);
assign #GATE_DELAY g38244 = rst ? 1'bz : ((0|FS06|g38243) ? 1'b0 : 1'bz);
// Gate A1-U228A
pullup(g38304);
assign #GATE_DELAY g38304 = rst ? 1'bz : ((0|g38303|FS18) ? 1'b0 : 1'bz);
// Gate A1-U215A
pullup(g38343);
assign #GATE_DELAY g38343 = rst ? 0 : ((0|F22A|F21A|g38345) ? 1'b0 : 1'bz);
// Gate A1-U247B
pullup(FS30);
assign #GATE_DELAY FS30 = rst ? 0 : ((0|g38445|g38444) ? 1'b0 : 1'bz);
// Gate A1-U158B
pullup(F17B);
assign #GATE_DELAY F17B = rst ? 0 : ((0|g38175|FS17) ? 1'b0 : 1'bz);
// Gate A1-U126A
pullup(FS03A);
assign #GATE_DELAY FS03A = rst ? 0 : ((0|g38214) ? 1'b0 : 1'bz);
// Gate A1-U157B
pullup(F17A);
assign #GATE_DELAY F17A = rst ? 0 : ((0|g38174|g38173) ? 1'b0 : 1'bz);
// Gate A1-U227A
pullup(CHAT13);
assign #GATE_DELAY CHAT13 = rst ? 0 : ((0|RCHAT_|g38304) ? 1'b0 : 1'bz);
// Gate A1-U156B
pullup(CHAT12);
assign #GATE_DELAY CHAT12 = rst ? 0 : ((0|RCHAT_|g38174) ? 1'b0 : 1'bz);
// Gate A1-U155B
pullup(CHAT11);
assign #GATE_DELAY CHAT11 = rst ? 0 : ((0|RCHAT_|g38164) ? 1'b0 : 1'bz);
// Gate A1-U149B
pullup(CHAT10);
assign #GATE_DELAY CHAT10 = rst ? 0 : ((0|RCHAT_|g38154) ? 1'b0 : 1'bz);
// Gate A1-U102A
pullup(g38274);
assign #GATE_DELAY g38274 = rst ? 1'bz : ((0|FS09|g38273) ? 1'b0 : 1'bz);
// Gate A1-U251B
pullup(FS31);
assign #GATE_DELAY FS31 = rst ? 0 : ((0|g38455|g38454) ? 1'b0 : 1'bz);
// Gate A1-U254B
pullup(FS32);
assign #GATE_DELAY FS32 = rst ? 0 : ((0|g38464|g38465) ? 1'b0 : 1'bz);
// Gate A1-U104A
pullup(g38273);
assign #GATE_DELAY g38273 = rst ? 0 : ((0|g38275|F08A|F09A) ? 1'b0 : 1'bz);
// Gate A1-U219A
pullup(g38335);
assign #GATE_DELAY g38335 = rst ? 1'bz : ((0|g38333|F20A|F21B) ? 1'b0 : 1'bz);
// Gate A1-U227B
pullup(CHAT14);
assign #GATE_DELAY CHAT14 = rst ? 0 : ((0|g38314|RCHAT_) ? 1'b0 : 1'bz);
// Gate A1-U144A
pullup(g38135);
assign #GATE_DELAY g38135 = rst ? 1'bz : ((0|F13B|F12A|g38133) ? 1'b0 : 1'bz);
// Gate A1-U122B
pullup(F04B);
assign #GATE_DELAY F04B = rst ? 0 : ((0|g38225|FS04) ? 1'b0 : 1'bz);
// Gate A1-U121B
pullup(F04A);
assign #GATE_DELAY F04A = rst ? 0 : ((0|g38224|g38223) ? 1'b0 : 1'bz);
// Gate A1-U222B
pullup(F20A);
assign #GATE_DELAY F20A = rst ? 0 : ((0|g38324|g38323) ? 1'b0 : 1'bz);
// Gate A1-U223B
pullup(F20B);
assign #GATE_DELAY F20B = rst ? 0 : ((0|g38325|FS20) ? 1'b0 : 1'bz);
// Gate A1-U208A
pullup(g38363);
assign #GATE_DELAY g38363 = rst ? 0 : ((0|F24A|F23A|g38365) ? 1'b0 : 1'bz);
// Gate A1-U246A
pullup(g38443);
assign #GATE_DELAY g38443 = rst ? 0 : ((0|F29A|g38445|F30A) ? 1'b0 : 1'bz);
// Gate A1-U119B
pullup(FS04A);
assign #GATE_DELAY FS04A = rst ? 0 : ((0|g38224) ? 1'b0 : 1'bz);
// Gate A1-U237A
pullup(g38414);
assign #GATE_DELAY g38414 = rst ? 1'bz : ((0|g38413|FS27) ? 1'b0 : 1'bz);
// Gate A1-U160B
pullup(FS06_);
assign #GATE_DELAY FS06_ = rst ? 1'bz : ((0|FS06) ? 1'b0 : 1'bz);
// Gate A1-U133A
pullup(F10B);
assign #GATE_DELAY F10B = rst ? 0 : ((0|FS10|g38105) ? 1'b0 : 1'bz);
// Gate A1-U132A
pullup(F10A);
assign #GATE_DELAY F10A = rst ? 0 : ((0|g38104|g38103) ? 1'b0 : 1'bz);
// Gate A1-U103A
pullup(g38275);
assign #GATE_DELAY g38275 = rst ? 1'bz : ((0|g38273|F08A|F09B) ? 1'b0 : 1'bz);
// Gate A1-U159B
pullup(g38174);
assign #GATE_DELAY g38174 = rst ? 1'bz : ((0|FS17|g38173) ? 1'b0 : 1'bz);
// Gate A1-U237B
pullup(FS27);
assign #GATE_DELAY FS27 = rst ? 0 : ((0|g38415|g38414) ? 1'b0 : 1'bz);
// Gate A1-U233B
pullup(FS26);
assign #GATE_DELAY FS26 = rst ? 0 : ((0|g38405|g38404) ? 1'b0 : 1'bz);
// Gate A1-U203B
pullup(FS25);
assign #GATE_DELAY FS25 = rst ? 0 : ((0|g38374|g38375) ? 1'b0 : 1'bz);
// Gate A1-U207B
pullup(FS24);
assign #GATE_DELAY FS24 = rst ? 0 : ((0|g38364|g38365) ? 1'b0 : 1'bz);
// Gate A1-U210B
pullup(FS23);
assign #GATE_DELAY FS23 = rst ? 0 : ((0|g38354|g38355) ? 1'b0 : 1'bz);
// Gate A1-U214B
pullup(FS22);
assign #GATE_DELAY FS22 = rst ? 0 : ((0|g38344|g38345) ? 1'b0 : 1'bz);
// Gate A1-U111A
pullup(g38255);
assign #GATE_DELAY g38255 = rst ? 1'bz : ((0|F06A|g38253|F07B) ? 1'b0 : 1'bz);
// Gate A1-U221B
pullup(FS20);
assign #GATE_DELAY FS20 = rst ? 0 : ((0|g38324|g38325) ? 1'b0 : 1'bz);
// Gate A1-U133B
pullup(g38105);
assign #GATE_DELAY g38105 = rst ? 1'bz : ((0|F09A|g38103|F10B) ? 1'b0 : 1'bz);
// Gate A1-U110A
pullup(g38253);
assign #GATE_DELAY g38253 = rst ? 0 : ((0|F07A|g38255|F06A) ? 1'b0 : 1'bz);
// Gate A1-U145B
pullup(g38134);
assign #GATE_DELAY g38134 = rst ? 1'bz : ((0|g38133|FS13) ? 1'b0 : 1'bz);
// Gate A1-U109A
pullup(g38254);
assign #GATE_DELAY g38254 = rst ? 1'bz : ((0|FS07|g38253) ? 1'b0 : 1'bz);
// Gate A1-U216A
pullup(g38345);
assign #GATE_DELAY g38345 = rst ? 1'bz : ((0|g38343|F21A|F22B) ? 1'b0 : 1'bz);
// Gate A1-U257B
pullup(F33A);
assign #GATE_DELAY F33A = rst ? 0 : ((0|g38473|g38474) ? 1'b0 : 1'bz);
// Gate A1-U256B
pullup(F33B);
assign #GATE_DELAY F33B = rst ? 0 : ((0|g38475|FS33) ? 1'b0 : 1'bz);
// Gate A1-U124B
pullup(F03B);
assign #GATE_DELAY F03B = rst ? 0 : ((0|FS03|g38215) ? 1'b0 : 1'bz);
// Gate A1-U124A
pullup(F03A);
assign #GATE_DELAY F03A = rst ? 0 : ((0|g38214|g38213) ? 1'b0 : 1'bz);
// Gate A1-U211B
pullup(F23A);
assign #GATE_DELAY F23A = rst ? 0 : ((0|g38354|g38353) ? 1'b0 : 1'bz);
// Gate A1-U212B
pullup(F23B);
assign #GATE_DELAY F23B = rst ? 0 : ((0|FS23|g38355) ? 1'b0 : 1'bz);
// Gate A1-U119A
pullup(FS05A);
assign #GATE_DELAY FS05A = rst ? 0 : ((0|g38234) ? 1'b0 : 1'bz);
// Gate A1-U236A
pullup(g38413);
assign #GATE_DELAY g38413 = rst ? 0 : ((0|g38415|F26A|F27A) ? 1'b0 : 1'bz);
// Gate A1-U221A
pullup(g38324);
assign #GATE_DELAY g38324 = rst ? 1'bz : ((0|g38323|FS20) ? 1'b0 : 1'bz);
// Gate A1-U114A
pullup(g38243);
assign #GATE_DELAY g38243 = rst ? 0 : ((0|g38245|F06A|F05A) ? 1'b0 : 1'bz);
// Gate A1-U158A
pullup(g38175);
assign #GATE_DELAY g38175 = rst ? 1'bz : ((0|F16A|F17B|g38173) ? 1'b0 : 1'bz);
// Gate A1-U234B
pullup(CHBT08);
assign #GATE_DELAY CHBT08 = rst ? 0 : ((0|g38414|RCHBT_) ? 1'b0 : 1'bz);
// Gate A1-U136B
pullup(F11A);
assign #GATE_DELAY F11A = rst ? 0 : ((0|g38114|g38113) ? 1'b0 : 1'bz);
// Gate A1-U136A
pullup(F11B);
assign #GATE_DELAY F11B = rst ? 0 : ((0|FS11|g38115) ? 1'b0 : 1'bz);
// Gate A1-U115A
pullup(g38245);
assign #GATE_DELAY g38245 = rst ? 1'bz : ((0|F05A|g38243|F06B) ? 1'b0 : 1'bz);
// Gate A1-U243B
pullup(F29A);
assign #GATE_DELAY F29A = rst ? 0 : ((0|g38433|g38434) ? 1'b0 : 1'bz);
// Gate A1-U244A
pullup(g38434);
assign #GATE_DELAY g38434 = rst ? 1'bz : ((0|g38433|FS29) ? 1'b0 : 1'bz);
// Gate A1-U148A
pullup(g38144);
assign #GATE_DELAY g38144 = rst ? 1'bz : ((0|g38143|FS14) ? 1'b0 : 1'bz);
// Gate A1-U209B
pullup(F24B);
assign #GATE_DELAY F24B = rst ? 0 : ((0|g38365|FS24) ? 1'b0 : 1'bz);
// Gate A1-U235A
pullup(g38415);
assign #GATE_DELAY g38415 = rst ? 1'bz : ((0|g38413|F26A|F27B) ? 1'b0 : 1'bz);
// Gate A1-U141B
pullup(FS12);
assign #GATE_DELAY FS12 = rst ? 0 : ((0|g38125|g38124) ? 1'b0 : 1'bz);
// Gate A1-U145A
pullup(FS13);
assign #GATE_DELAY FS13 = rst ? 0 : ((0|g38135|g38134) ? 1'b0 : 1'bz);
// Gate A1-U134B
pullup(FS10);
assign #GATE_DELAY FS10 = rst ? 0 : ((0|g38105|g38104) ? 1'b0 : 1'bz);
// Gate A1-U138B
pullup(FS11);
assign #GATE_DELAY FS11 = rst ? 0 : ((0|g38115|g38114) ? 1'b0 : 1'bz);
// Gate A1-U156A
pullup(FS16);
assign #GATE_DELAY FS16 = rst ? 0 : ((0|g38164|g38165) ? 1'b0 : 1'bz);
// Gate A1-U159A
pullup(FS17);
assign #GATE_DELAY FS17 = rst ? 0 : ((0|g38175|g38174) ? 1'b0 : 1'bz);
// Gate A1-U149A
pullup(FS14);
assign #GATE_DELAY FS14 = rst ? 0 : ((0|g38144|g38145) ? 1'b0 : 1'bz);
// Gate A1-U150A
pullup(g38155);
assign #GATE_DELAY g38155 = rst ? 1'bz : ((0|F15B|F14A|g38153) ? 1'b0 : 1'bz);
// Gate A1-U248B
pullup(CHBT12);
assign #GATE_DELAY CHBT12 = rst ? 0 : ((0|g38454|RCHBT_) ? 1'b0 : 1'bz);
// Gate A1-U255A
pullup(CHBT13);
assign #GATE_DELAY CHBT13 = rst ? 0 : ((0|RCHBT_|g38464) ? 1'b0 : 1'bz);
// Gate A1-U228B
pullup(FS18);
assign #GATE_DELAY FS18 = rst ? 0 : ((0|g38304|g38305) ? 1'b0 : 1'bz);
// Gate A1-U224B
pullup(FS19);
assign #GATE_DELAY FS19 = rst ? 0 : ((0|g38314|g38315) ? 1'b0 : 1'bz);
// Gate A1-U150B
pullup(F15B);
assign #GATE_DELAY F15B = rst ? 0 : ((0|FS15|g38155) ? 1'b0 : 1'bz);
// Gate A1-U255B
pullup(CHBT14);
assign #GATE_DELAY CHBT14 = rst ? 0 : ((0|g38474|RCHBT_) ? 1'b0 : 1'bz);
// Gate A1-U216B
pullup(F22B);
assign #GATE_DELAY F22B = rst ? 0 : ((0|g38345|FS22) ? 1'b0 : 1'bz);
// Gate A1-U220A
pullup(CHBT01);
assign #GATE_DELAY CHBT01 = rst ? 0 : ((0|RCHBT_|g38324) ? 1'b0 : 1'bz);
// Gate A1-U215B
pullup(F22A);
assign #GATE_DELAY F22A = rst ? 0 : ((0|g38344|g38343) ? 1'b0 : 1'bz);
// Gate A1-U230B
pullup(F18B);
assign #GATE_DELAY F18B = rst ? 0 : ((0|g38305|FS18) ? 1'b0 : 1'bz);
// Gate A1-U229B
pullup(F18A);
assign #GATE_DELAY F18A = rst ? 0 : ((0|g38304|g38303) ? 1'b0 : 1'bz);
// Gate A1-U249A
pullup(g38455);
assign #GATE_DELAY g38455 = rst ? 1'bz : ((0|g38453|F30A|F31B) ? 1'b0 : 1'bz);
// Gate A1-U128B
pullup(F02A);
assign #GATE_DELAY F02A = rst ? 0 : ((0|g38204|g38203) ? 1'b0 : 1'bz);
// Gate A1-U129B
pullup(F02B);
assign #GATE_DELAY F02B = rst ? 0 : ((0|g38205|FS02) ? 1'b0 : 1'bz);
// Gate A1-U146A
pullup(g38145);
assign #GATE_DELAY g38145 = rst ? 1'bz : ((0|F13A|g38143|F14B) ? 1'b0 : 1'bz);
// Gate A1-U213A
pullup(CHBT03);
assign #GATE_DELAY CHBT03 = rst ? 0 : ((0|RCHBT_|g38344) ? 1'b0 : 1'bz);
// Gate A1-U147A
pullup(g38143);
assign #GATE_DELAY g38143 = rst ? 0 : ((0|F13A|g38145|F14A) ? 1'b0 : 1'bz);
// Gate A1-U249B
pullup(F31B);
assign #GATE_DELAY F31B = rst ? 0 : ((0|g38455|FS31) ? 1'b0 : 1'bz);
// Gate A1-U220B
pullup(CHBT02);
assign #GATE_DELAY CHBT02 = rst ? 0 : ((0|g38334|RCHBT_) ? 1'b0 : 1'bz);
// Gate A1-U128A
pullup(g38203);
assign #GATE_DELAY g38203 = rst ? 0 : ((0|F02A|FS01_|g38205) ? 1'b0 : 1'bz);
// Gate A1-U204A
pullup(g38373);
assign #GATE_DELAY g38373 = rst ? 0 : ((0|g38375|F24A|F25A) ? 1'b0 : 1'bz);
// Gate A1-U202B
pullup(F18AX);
assign #GATE_DELAY F18AX = rst ? 0 : ((0|F18A_) ? 1'b0 : 1'bz);
// Gate A1-U259A
pullup(F18A_);
assign #GATE_DELAY F18A_ = rst ? 1'bz : ((0|F18A) ? 1'b0 : 1'bz);
// Gate A1-U129A
pullup(g38205);
assign #GATE_DELAY g38205 = rst ? 1'bz : ((0|g38203|FS01_|F02B) ? 1'b0 : 1'bz);
// Gate A1-U213B
pullup(CHBT04);
assign #GATE_DELAY CHBT04 = rst ? 0 : ((0|g38354|RCHBT_) ? 1'b0 : 1'bz);
// Gate A1-U107A
pullup(g38263);
assign #GATE_DELAY g38263 = rst ? 0 : ((0|F08A|F07A|g38265) ? 1'b0 : 1'bz);
// Gate A1-U139A
pullup(F12A);
assign #GATE_DELAY F12A = rst ? 0 : ((0|g38124|g38123) ? 1'b0 : 1'bz);
// Gate A1-U234A
pullup(CHBT07);
assign #GATE_DELAY CHBT07 = rst ? 0 : ((0|RCHBT_|g38404) ? 1'b0 : 1'bz);
// Gate A1-U132B
pullup(g38103);
assign #GATE_DELAY g38103 = rst ? 0 : ((0|F09A|F10A|g38105) ? 1'b0 : 1'bz);
// Gate A1-U134A
pullup(g38104);
assign #GATE_DELAY g38104 = rst ? 1'bz : ((0|g38103|FS10) ? 1'b0 : 1'bz);
// Gate A1-U144B
pullup(g38133);
assign #GATE_DELAY g38133 = rst ? 0 : ((0|F13A|g38135|F12A) ? 1'b0 : 1'bz);
// Gate A1-U206B
pullup(CHBT06);
assign #GATE_DELAY CHBT06 = rst ? 0 : ((0|g38374|RCHBT_) ? 1'b0 : 1'bz);
// Gate A1-U108B
pullup(F08B);
assign #GATE_DELAY F08B = rst ? 0 : ((0|g38265|FS08) ? 1'b0 : 1'bz);
// Gate A1-U157A
pullup(g38173);
assign #GATE_DELAY g38173 = rst ? 0 : ((0|F16A|g38175|F17A) ? 1'b0 : 1'bz);
// Gate A1-U106A
pullup(F08A);
assign #GATE_DELAY F08A = rst ? 0 : ((0|g38263|g38264) ? 1'b0 : 1'bz);
// Gate A1-U241A
pullup(CHBT09);
assign #GATE_DELAY CHBT09 = rst ? 0 : ((0|RCHBT_|g38424) ? 1'b0 : 1'bz);
// Gate A1-U254A
pullup(g38464);
assign #GATE_DELAY g38464 = rst ? 1'bz : ((0|g38463|FS32) ? 1'b0 : 1'bz);
// Gate A1-U102B
pullup(FS09);
assign #GATE_DELAY FS09 = rst ? 0 : ((0|g38274|g38275) ? 1'b0 : 1'bz);
// Gate A1-U105B
pullup(FS08);
assign #GATE_DELAY FS08 = rst ? 0 : ((0|g38265|g38264) ? 1'b0 : 1'bz);
// Gate A1-U251A
pullup(g38454);
assign #GATE_DELAY g38454 = rst ? 1'bz : ((0|g38453|FS31) ? 1'b0 : 1'bz);
// Gate A1-U116B
pullup(FS05);
assign #GATE_DELAY FS05 = rst ? 0 : ((0|g38234|g38235) ? 1'b0 : 1'bz);
// Gate A1-U120B
pullup(FS04);
assign #GATE_DELAY FS04 = rst ? 0 : ((0|g38224|g38225) ? 1'b0 : 1'bz);
// Gate A1-U109B
pullup(FS07);
assign #GATE_DELAY FS07 = rst ? 0 : ((0|g38254|g38255) ? 1'b0 : 1'bz);
// Gate A1-U113B
pullup(FS06);
assign #GATE_DELAY FS06 = rst ? 0 : ((0|g38244|g38245) ? 1'b0 : 1'bz);
// Gate A1-U206A
pullup(CHBT05);
assign #GATE_DELAY CHBT05 = rst ? 0 : ((0|RCHBT_|g38364) ? 1'b0 : 1'bz);
// Gate A1-U259B
pullup(F03B_);
assign #GATE_DELAY F03B_ = rst ? 1'bz : ((0|F03B) ? 1'b0 : 1'bz);
// Gate A1-U123B
pullup(FS03);
assign #GATE_DELAY FS03 = rst ? 0 : ((0|g38214|g38215) ? 1'b0 : 1'bz);
// Gate A1-U127B
pullup(FS02);
assign #GATE_DELAY FS02 = rst ? 0 : ((0|g38204|g38205) ? 1'b0 : 1'bz);
// Gate A1-U140B
pullup(g38125);
assign #GATE_DELAY g38125 = rst ? 1'bz : ((0|g38123|F11A|F12B) ? 1'b0 : 1'bz);
// Gate A1-U218A
pullup(g38333);
assign #GATE_DELAY g38333 = rst ? 0 : ((0|F21A|F20A|g38335) ? 1'b0 : 1'bz);
// Gate A1-U233A
pullup(g38404);
assign #GATE_DELAY g38404 = rst ? 1'bz : ((0|g38403|FS26) ? 1'b0 : 1'bz);
// Gate A1-U141A
pullup(g38124);
assign #GATE_DELAY g38124 = rst ? 1'bz : ((0|g38123|FS12) ? 1'b0 : 1'bz);
// Gate A1-U140A
pullup(g38123);
assign #GATE_DELAY g38123 = rst ? 0 : ((0|F11A|F12A|g38125) ? 1'b0 : 1'bz);
// Gate A1-U205B
pullup(F25B);
assign #GATE_DELAY F25B = rst ? 0 : ((0|g38375|FS25) ? 1'b0 : 1'bz);
// Gate A1-U204B
pullup(F25A);
assign #GATE_DELAY F25A = rst ? 0 : ((0|g38374|g38373) ? 1'b0 : 1'bz);
// Gate A1-U258B
pullup(FS33);
assign #GATE_DELAY FS33 = rst ? 0 : ((0|g38474|g38475) ? 1'b0 : 1'bz);
// Gate A1-U219B
pullup(F21B);
assign #GATE_DELAY F21B = rst ? 0 : ((0|g38335|FS21) ? 1'b0 : 1'bz);
// Gate A1-U222A
pullup(g38323);
assign #GATE_DELAY g38323 = rst ? 0 : ((0|F20A|F19A|g38325) ? 1'b0 : 1'bz);
// Gate A1-U218B
pullup(F21A);
assign #GATE_DELAY F21A = rst ? 0 : ((0|g38334|g38333) ? 1'b0 : 1'bz);
// Gate A1-U243A
pullup(g38433);
assign #GATE_DELAY g38433 = rst ? 0 : ((0|g38435|F28A|F29A) ? 1'b0 : 1'bz);
// Gate A1-U231A
pullup(g38405);
assign #GATE_DELAY g38405 = rst ? 1'bz : ((0|F26B|F25A|g38403) ? 1'b0 : 1'bz);
// Gate A1-U143A
pullup(F13B);
assign #GATE_DELAY F13B = rst ? 0 : ((0|FS13|g38135) ? 1'b0 : 1'bz);
// Gate A1-U143B
pullup(F13A);
assign #GATE_DELAY F13A = rst ? 0 : ((0|g38134|g38133) ? 1'b0 : 1'bz);
// Gate A1-U232A
pullup(g38403);
assign #GATE_DELAY g38403 = rst ? 0 : ((0|g38405|F25A|F26A) ? 1'b0 : 1'bz);
// Gate A1-U101A
pullup(FS07A);
assign #GATE_DELAY FS07A = rst ? 0 : ((0|FS07_) ? 1'b0 : 1'bz);
// Gate A1-U223A
pullup(g38325);
assign #GATE_DELAY g38325 = rst ? 1'bz : ((0|g38323|F19A|F20B) ? 1'b0 : 1'bz);
// Gate A1-U160A
pullup(FS07_);
assign #GATE_DELAY FS07_ = rst ? 1'bz : ((0|FS07) ? 1'b0 : 1'bz);
// Gate A1-U137A
pullup(g38115);
assign #GATE_DELAY g38115 = rst ? 1'bz : ((0|F10A|F11B|g38113) ? 1'b0 : 1'bz);
// Gate A1-U138A
pullup(g38114);
assign #GATE_DELAY g38114 = rst ? 1'bz : ((0|g38113|FS11) ? 1'b0 : 1'bz);
// Gate A1-U137B
pullup(g38113);
assign #GATE_DELAY g38113 = rst ? 0 : ((0|F11A|F10A|g38115) ? 1'b0 : 1'bz);
// Gate A1-U250B
pullup(F31A);
assign #GATE_DELAY F31A = rst ? 0 : ((0|g38454|g38453) ? 1'b0 : 1'bz);
// Gate A1-U209A
pullup(g38365);
assign #GATE_DELAY g38365 = rst ? 1'bz : ((0|g38363|F23A|F24B) ? 1'b0 : 1'bz);
// Gate A1-U256A
pullup(g38475);
assign #GATE_DELAY g38475 = rst ? 1'bz : ((0|F32A|g38473|F33B) ? 1'b0 : 1'bz);
// Gate A1-U257A
pullup(g38473);
assign #GATE_DELAY g38473 = rst ? 0 : ((0|F32A|g38475|F33A) ? 1'b0 : 1'bz);
// Gate A1-U212A
pullup(g38355);
assign #GATE_DELAY g38355 = rst ? 1'bz : ((0|g38353|F22A|F23B) ? 1'b0 : 1'bz);
// Gate A1-U154A
pullup(g38163);
assign #GATE_DELAY g38163 = rst ? 0 : ((0|g38165|F15A|F16A) ? 1'b0 : 1'bz);
// Gate A1-U153A
pullup(g38165);
assign #GATE_DELAY g38165 = rst ? 1'bz : ((0|F15A|g38163|F16B) ? 1'b0 : 1'bz);
// Gate A1-U152A
pullup(FS15);
assign #GATE_DELAY FS15 = rst ? 0 : ((0|g38155|g38154) ? 1'b0 : 1'bz);
// Gate A1-U211A
pullup(g38353);
assign #GATE_DELAY g38353 = rst ? 0 : ((0|g38355|F23A|F22A) ? 1'b0 : 1'bz);
// Gate A1-U210A
pullup(g38354);
assign #GATE_DELAY g38354 = rst ? 1'bz : ((0|g38353|FS23) ? 1'b0 : 1'bz);
// Gate A1-U117A
pullup(g38233);
assign #GATE_DELAY g38233 = rst ? 0 : ((0|F05A|g38235|F04A) ? 1'b0 : 1'bz);
// Gate A1-U116A
pullup(g38234);
assign #GATE_DELAY g38234 = rst ? 1'bz : ((0|FS05|g38233) ? 1'b0 : 1'bz);
// Gate A1-U252B
pullup(F32B);
assign #GATE_DELAY F32B = rst ? 0 : ((0|FS32|g38465) ? 1'b0 : 1'bz);
// Gate A1-U253B
pullup(F32A);
assign #GATE_DELAY F32A = rst ? 0 : ((0|g38463|g38464) ? 1'b0 : 1'bz);
// Gate A1-U208B
pullup(F24A);
assign #GATE_DELAY F24A = rst ? 0 : ((0|g38364|g38363) ? 1'b0 : 1'bz);
// Gate A1-U118A
pullup(g38235);
assign #GATE_DELAY g38235 = rst ? 1'bz : ((0|g38233|F04A|F05B) ? 1'b0 : 1'bz);
// Gate A1-U118B
pullup(F05B);
assign #GATE_DELAY F05B = rst ? 0 : ((0|g38235|FS05) ? 1'b0 : 1'bz);
// Gate A1-U241B
pullup(CHBT10);
assign #GATE_DELAY CHBT10 = rst ? 0 : ((0|g38434|RCHBT_) ? 1'b0 : 1'bz);
// Gate A1-U127A
pullup(g38204);
assign #GATE_DELAY g38204 = rst ? 1'bz : ((0|FS02|g38203) ? 1'b0 : 1'bz);
// Gate A1-U258A
pullup(g38474);
assign #GATE_DELAY g38474 = rst ? 1'bz : ((0|g38473|FS33) ? 1'b0 : 1'bz);
// Gate A1-U248A
pullup(CHBT11);
assign #GATE_DELAY CHBT11 = rst ? 0 : ((0|RCHBT_|g38444) ? 1'b0 : 1'bz);
// Gate A1-U231B
pullup(F26B);
assign #GATE_DELAY F26B = rst ? 0 : ((0|g38405|FS26) ? 1'b0 : 1'bz);
// Gate A1-U232B
pullup(F26A);
assign #GATE_DELAY F26A = rst ? 0 : ((0|g38403|g38404) ? 1'b0 : 1'bz);
// Gate A1-U238A
pullup(g38425);
assign #GATE_DELAY g38425 = rst ? 1'bz : ((0|g38423|F27A|F28B) ? 1'b0 : 1'bz);
// Gate A1-U146B
pullup(F14B);
assign #GATE_DELAY F14B = rst ? 0 : ((0|FS14|g38145) ? 1'b0 : 1'bz);
// Gate A1-U147B
pullup(F14A);
assign #GATE_DELAY F14A = rst ? 0 : ((0|g38143|g38144) ? 1'b0 : 1'bz);
// Gate A1-U121A
pullup(g38223);
assign #GATE_DELAY g38223 = rst ? 0 : ((0|F04A|g38225|F03A) ? 1'b0 : 1'bz);
// Gate A1-U242B
pullup(F29B);
assign #GATE_DELAY F29B = rst ? 0 : ((0|g38435|FS29) ? 1'b0 : 1'bz);
// Gate A1-U239A
pullup(g38423);
assign #GATE_DELAY g38423 = rst ? 0 : ((0|g38425|F27A|F28A) ? 1'b0 : 1'bz);
// Gate A1-U122A
pullup(g38225);
assign #GATE_DELAY g38225 = rst ? 1'bz : ((0|F03A|g38223|F04B) ? 1'b0 : 1'bz);
// Gate A1-U155A
pullup(g38164);
assign #GATE_DELAY g38164 = rst ? 1'bz : ((0|g38163|FS16) ? 1'b0 : 1'bz);
// Gate A1-U214A
pullup(g38344);
assign #GATE_DELAY g38344 = rst ? 1'bz : ((0|FS22|g38343) ? 1'b0 : 1'bz);
// Gate A1-U152B
pullup(g38154);
assign #GATE_DELAY g38154 = rst ? 1'bz : ((0|g38153|FS15) ? 1'b0 : 1'bz);
// Gate A1-U240A
pullup(g38424);
assign #GATE_DELAY g38424 = rst ? 1'bz : ((0|g38423|FS28) ? 1'b0 : 1'bz);
// Gate A1-U108A
pullup(g38265);
assign #GATE_DELAY g38265 = rst ? 1'bz : ((0|g38263|F07A|F08B) ? 1'b0 : 1'bz);
// Gate A1-U110B
pullup(F07A);
assign #GATE_DELAY F07A = rst ? 0 : ((0|g38254|g38253) ? 1'b0 : 1'bz);
// Gate A1-U106B
pullup(g38264);
assign #GATE_DELAY g38264 = rst ? 1'bz : ((0|FS08|g38263) ? 1'b0 : 1'bz);
// Gate A1-U240B
pullup(FS28);
assign #GATE_DELAY FS28 = rst ? 0 : ((0|g38425|g38424) ? 1'b0 : 1'bz);
// Gate A1-U120A
pullup(g38224);
assign #GATE_DELAY g38224 = rst ? 1'bz : ((0|FS04|g38223) ? 1'b0 : 1'bz);
// Gate A1-U202A
pullup(F07A_);
assign #GATE_DELAY F07A_ = rst ? 1'bz : ((0|F07A) ? 1'b0 : 1'bz);
// Gate A1-U151B
pullup(F15A);
assign #GATE_DELAY F15A = rst ? 0 : ((0|g38154|g38153) ? 1'b0 : 1'bz);
// Gate A1-U151A
pullup(g38153);
assign #GATE_DELAY g38153 = rst ? 0 : ((0|F14A|g38155|F15A) ? 1'b0 : 1'bz);
// Gate A1-U247A
pullup(g38444);
assign #GATE_DELAY g38444 = rst ? 1'bz : ((0|g38443|FS30) ? 1'b0 : 1'bz);
// Gate A1-U104B
pullup(F09A);
assign #GATE_DELAY F09A = rst ? 0 : ((0|g38273|g38274) ? 1'b0 : 1'bz);
// Gate A1-U103B
pullup(F09B);
assign #GATE_DELAY F09B = rst ? 0 : ((0|g38275|FS09) ? 1'b0 : 1'bz);
// Gate A1-U217B
pullup(FS21);
assign #GATE_DELAY FS21 = rst ? 0 : ((0|g38334|g38335) ? 1'b0 : 1'bz);
// Gate A1-U230A
pullup(g38305);
assign #GATE_DELAY g38305 = rst ? 1'bz : ((0|g38303|F17A|F18B) ? 1'b0 : 1'bz);
// Gate A1-U246B
pullup(F30A);
assign #GATE_DELAY F30A = rst ? 0 : ((0|g38443|g38444) ? 1'b0 : 1'bz);
// Gate A1-U229A
pullup(g38303);
assign #GATE_DELAY g38303 = rst ? 0 : ((0|F18A|F17A|g38305) ? 1'b0 : 1'bz);
// Gate A1-U250A
pullup(g38453);
assign #GATE_DELAY g38453 = rst ? 0 : ((0|g38455|F30A|F31A) ? 1'b0 : 1'bz);
// Gate A1-U225A
pullup(g38313);
assign #GATE_DELAY g38313 = rst ? 0 : ((0|F19A|F18A|g38315) ? 1'b0 : 1'bz);
// Gate A1-U224A
pullup(g38314);
assign #GATE_DELAY g38314 = rst ? 1'bz : ((0|g38313|FS19) ? 1'b0 : 1'bz);
// Gate A1-U114B
pullup(F06A);
assign #GATE_DELAY F06A = rst ? 0 : ((0|g38244|g38243) ? 1'b0 : 1'bz);
// Gate A1-U115B
pullup(F06B);
assign #GATE_DELAY F06B = rst ? 0 : ((0|g38245|FS06) ? 1'b0 : 1'bz);
// Gate A1-U207A
pullup(g38364);
assign #GATE_DELAY g38364 = rst ? 1'bz : ((0|FS24|g38363) ? 1'b0 : 1'bz);
// Gate A1-U101B
pullup(FS08_);
assign #GATE_DELAY FS08_ = rst ? 1'bz : ((0|FS08) ? 1'b0 : 1'bz);
// Gate A1-U226A
pullup(g38315);
assign #GATE_DELAY g38315 = rst ? 1'bz : ((0|g38313|F18A|F19B) ? 1'b0 : 1'bz);
// Gate A1-U139B
pullup(F12B);
assign #GATE_DELAY F12B = rst ? 0 : ((0|g38125|FS12) ? 1'b0 : 1'bz);
// Gate A1-U245B
pullup(F30B);
assign #GATE_DELAY F30B = rst ? 0 : ((0|g38445|FS30) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
