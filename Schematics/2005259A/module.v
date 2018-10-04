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

// Gate A1-U242A
pullup(A1U242Pad1);
assign (highz1,strong0) #0.2  A1U242Pad1 = rst ? 1 : ~(0|F29B|F28A|A1U242Pad4);
// Gate A1-U126B
pullup(FS02A);
assign (highz1,strong0) #0.2  FS02A = rst ? 1 : ~(0|A1U126Pad7);
// Gate A1-U239B
pullup(F28A);
assign (highz1,strong0) #0.2  F28A = rst ? 0 : ~(0|A1U238Pad4|A1U239Pad8);
// Gate A1-U238B
pullup(F28B);
assign (highz1,strong0) #0.2  F28B = rst ? 0 : ~(0|FS28|A1U238Pad1);
// Gate A1-U252A
pullup(A1U252Pad1);
assign (highz1,strong0) #0.2  A1U252Pad1 = rst ? 1 : ~(0|F32B|A1U252Pad3|F31A);
// Gate A1-U253A
pullup(A1U252Pad3);
assign (highz1,strong0) #0.2  A1U252Pad3 = rst ? 0 : ~(0|F32A|F31A|A1U252Pad1);
// Gate A1-U244B
pullup(FS29);
assign (highz1,strong0) #0.2  FS29 = rst ? 0 : ~(0|A1U242Pad1|A1U241Pad7);
// Gate A1-U154B
pullup(F16A);
assign (highz1,strong0) #0.2  F16A = rst ? 0 : ~(0|A1U153Pad3|A1U154Pad8);
// Gate A1-U153B
pullup(F16B);
assign (highz1,strong0) #0.2  F16B = rst ? 0 : ~(0|FS16|A1U153Pad1);
// Gate A1-U105A
pullup(CHAT04);
assign (highz1,strong0) #0.2  CHAT04 = rst ? 0 : ~(0|RCHAT_|A1U102Pad1);
// Gate A1-U135A
pullup(CHAT05);
assign (highz1,strong0) #0.2  CHAT05 = rst ? 0 : ~(0|RCHAT_|A1U132Pad3);
// Gate A1-U135B
pullup(CHAT06);
assign (highz1,strong0) #0.2  CHAT06 = rst ? 0 : ~(0|RCHAT_|A1U135Pad8);
// Gate A1-U142A
pullup(CHAT07);
assign (highz1,strong0) #0.2  CHAT07 = rst ? 0 : ~(0|A1U139Pad3|RCHAT_);
// Gate A1-U245A
pullup(A1U245Pad1);
assign (highz1,strong0) #0.2  A1U245Pad1 = rst ? 1 : ~(0|F30B|F29A|A1U245Pad4);
// Gate A1-U112B
pullup(CHAT01);
assign (highz1,strong0) #0.2  CHAT01 = rst ? 0 : ~(0|RCHAT_|A1U112Pad8);
// Gate A1-U112A
pullup(CHAT02);
assign (highz1,strong0) #0.2  CHAT02 = rst ? 0 : ~(0|A1U109Pad1|RCHAT_);
// Gate A1-U107B
pullup(CHAT03);
assign (highz1,strong0) #0.2  CHAT03 = rst ? 0 : ~(0|A1U105Pad8|RCHAT_);
// Gate A1-U142B
pullup(CHAT08);
assign (highz1,strong0) #0.2  CHAT08 = rst ? 0 : ~(0|A1U142Pad7|RCHAT_);
// Gate A1-U148B
pullup(CHAT09);
assign (highz1,strong0) #0.2  CHAT09 = rst ? 0 : ~(0|A1U147Pad8|RCHAT_);
// Gate A1-U203A
pullup(A1U203Pad1);
assign (highz1,strong0) #0.2  A1U203Pad1 = rst ? 1 : ~(0|FS25|A1U203Pad3);
// Gate A1-U125A
pullup(A1U123Pad2);
assign (highz1,strong0) #0.2  A1U123Pad2 = rst ? 0 : ~(0|A1U123Pad8|F02A|F03A);
// Gate A1-U123A
pullup(A1U123Pad1);
assign (highz1,strong0) #0.2  A1U123Pad1 = rst ? 1 : ~(0|A1U123Pad2|FS03);
// Gate A1-U225B
pullup(F19A);
assign (highz1,strong0) #0.2  F19A = rst ? 0 : ~(0|A1U224Pad1|A1U224Pad3);
// Gate A1-U226B
pullup(F19B);
assign (highz1,strong0) #0.2  F19B = rst ? 0 : ~(0|A1U224Pad8|FS19);
// Gate A1-U125B
pullup(A1U123Pad8);
assign (highz1,strong0) #0.2  A1U123Pad8 = rst ? 1 : ~(0|A1U123Pad2|F03B|F02A);
// Gate A1-U117B
pullup(F05A);
assign (highz1,strong0) #0.2  F05A = rst ? 0 : ~(0|A1U116Pad1|A1U116Pad2);
// Gate A1-U111B
pullup(F07B);
assign (highz1,strong0) #0.2  F07B = rst ? 0 : ~(0|A1U109Pad8|FS07);
// Gate A1-U236B
pullup(F27A);
assign (highz1,strong0) #0.2  F27A = rst ? 0 : ~(0|A1U234Pad7|A1U235Pad4);
// Gate A1-U235B
pullup(F27B);
assign (highz1,strong0) #0.2  F27B = rst ? 0 : ~(0|A1U235Pad1|FS27);
// Gate A1-U217A
pullup(A1U217Pad1);
assign (highz1,strong0) #0.2  A1U217Pad1 = rst ? 1 : ~(0|FS21|A1U217Pad3);
// Gate A1-U205A
pullup(A1U203Pad8);
assign (highz1,strong0) #0.2  A1U203Pad8 = rst ? 1 : ~(0|F25B|F24A|A1U203Pad3);
// Gate A1-U113A
pullup(A1U112Pad8);
assign (highz1,strong0) #0.2  A1U112Pad8 = rst ? 1 : ~(0|A1U113Pad2|FS06);
// Gate A1-U228A
pullup(A1U227Pad2);
assign (highz1,strong0) #0.2  A1U227Pad2 = rst ? 0 : ~(0|FS18|A1U228Pad3);
// Gate A1-U215A
pullup(A1U214Pad2);
assign (highz1,strong0) #0.2  A1U214Pad2 = rst ? 0 : ~(0|A1U214Pad8|F21A|F22A);
// Gate A1-U247B
pullup(FS30);
assign (highz1,strong0) #0.2  FS30 = rst ? 0 : ~(0|A1U245Pad1|A1U246Pad8);
// Gate A1-U158B
pullup(F17B);
assign (highz1,strong0) #0.2  F17B = rst ? 0 : ~(0|A1U157Pad3|FS17);
// Gate A1-U126A
pullup(FS03A);
assign (highz1,strong0) #0.2  FS03A = rst ? 0 : ~(0|A1U123Pad1);
// Gate A1-U157B
pullup(F17A);
assign (highz1,strong0) #0.2  F17A = rst ? 0 : ~(0|A1U156Pad8|A1U157Pad1);
// Gate A1-U227A
pullup(CHAT13);
assign (highz1,strong0) #0.2  CHAT13 = rst ? 0 : ~(0|A1U227Pad2|RCHAT_);
// Gate A1-U156B
pullup(CHAT12);
assign (highz1,strong0) #0.2  CHAT12 = rst ? 0 : ~(0|RCHAT_|A1U156Pad8);
// Gate A1-U155B
pullup(CHAT11);
assign (highz1,strong0) #0.2  CHAT11 = rst ? 0 : ~(0|RCHAT_|A1U154Pad8);
// Gate A1-U149B
pullup(CHAT10);
assign (highz1,strong0) #0.2  CHAT10 = rst ? 0 : ~(0|RCHAT_|A1U149Pad8);
// Gate A1-U102A
pullup(A1U102Pad1);
assign (highz1,strong0) #0.2  A1U102Pad1 = rst ? 1 : ~(0|A1U102Pad2|FS09);
// Gate A1-U251B
pullup(FS31);
assign (highz1,strong0) #0.2  FS31 = rst ? 0 : ~(0|A1U249Pad1|A1U248Pad7);
// Gate A1-U254B
pullup(FS32);
assign (highz1,strong0) #0.2  FS32 = rst ? 0 : ~(0|A1U253Pad8|A1U252Pad1);
// Gate A1-U104A
pullup(A1U102Pad2);
assign (highz1,strong0) #0.2  A1U102Pad2 = rst ? 0 : ~(0|F09A|F08A|A1U102Pad8);
// Gate A1-U219A
pullup(A1U217Pad8);
assign (highz1,strong0) #0.2  A1U217Pad8 = rst ? 1 : ~(0|F21B|F20A|A1U217Pad3);
// Gate A1-U227B
pullup(CHAT14);
assign (highz1,strong0) #0.2  CHAT14 = rst ? 0 : ~(0|A1U224Pad1|RCHAT_);
// Gate A1-U144A
pullup(A1U143Pad2);
assign (highz1,strong0) #0.2  A1U143Pad2 = rst ? 1 : ~(0|A1U143Pad8|F12A|F13B);
// Gate A1-U122B
pullup(F04B);
assign (highz1,strong0) #0.2  F04B = rst ? 0 : ~(0|A1U120Pad8|FS04);
// Gate A1-U121B
pullup(F04A);
assign (highz1,strong0) #0.2  F04A = rst ? 0 : ~(0|A1U119Pad7|A1U120Pad2);
// Gate A1-U222B
pullup(F20A);
assign (highz1,strong0) #0.2  F20A = rst ? 0 : ~(0|A1U220Pad2|A1U221Pad3);
// Gate A1-U223B
pullup(F20B);
assign (highz1,strong0) #0.2  F20B = rst ? 0 : ~(0|A1U221Pad8|FS20);
// Gate A1-U208A
pullup(A1U207Pad2);
assign (highz1,strong0) #0.2  A1U207Pad2 = rst ? 1 : ~(0|A1U207Pad8|F23A|F24A);
// Gate A1-U246A
pullup(A1U245Pad4);
assign (highz1,strong0) #0.2  A1U245Pad4 = rst ? 0 : ~(0|F30A|A1U245Pad1|F29A);
// Gate A1-U119B
pullup(FS04A);
assign (highz1,strong0) #0.2  FS04A = rst ? 0 : ~(0|A1U119Pad7);
// Gate A1-U237A
pullup(A1U234Pad7);
assign (highz1,strong0) #0.2  A1U234Pad7 = rst ? 0 : ~(0|FS27|A1U235Pad4);
// Gate A1-U160B
pullup(FS06_);
assign (highz1,strong0) #0.2  FS06_ = rst ? 1 : ~(0|FS06);
// Gate A1-U133A
pullup(F10B);
assign (highz1,strong0) #0.2  F10B = rst ? 0 : ~(0|A1U132Pad8|FS10);
// Gate A1-U132A
pullup(F10A);
assign (highz1,strong0) #0.2  F10A = rst ? 0 : ~(0|A1U132Pad2|A1U132Pad3);
// Gate A1-U103A
pullup(A1U102Pad8);
assign (highz1,strong0) #0.2  A1U102Pad8 = rst ? 1 : ~(0|F09B|F08A|A1U102Pad2);
// Gate A1-U159B
pullup(A1U156Pad8);
assign (highz1,strong0) #0.2  A1U156Pad8 = rst ? 0 : ~(0|FS17|A1U157Pad1);
// Gate A1-U237B
pullup(FS27);
assign (highz1,strong0) #0.2  FS27 = rst ? 1 : ~(0|A1U235Pad1|A1U234Pad7);
// Gate A1-U233B
pullup(FS26);
assign (highz1,strong0) #0.2  FS26 = rst ? 0 : ~(0|A1U231Pad1|A1U232Pad8);
// Gate A1-U203B
pullup(FS25);
assign (highz1,strong0) #0.2  FS25 = rst ? 0 : ~(0|A1U203Pad1|A1U203Pad8);
// Gate A1-U207B
pullup(FS24);
assign (highz1,strong0) #0.2  FS24 = rst ? 1 : ~(0|A1U206Pad2|A1U207Pad8);
// Gate A1-U210B
pullup(FS23);
assign (highz1,strong0) #0.2  FS23 = rst ? 1 : ~(0|A1U210Pad1|A1U210Pad8);
// Gate A1-U214B
pullup(FS22);
assign (highz1,strong0) #0.2  FS22 = rst ? 0 : ~(0|A1U213Pad2|A1U214Pad8);
// Gate A1-U111A
pullup(A1U109Pad8);
assign (highz1,strong0) #0.2  A1U109Pad8 = rst ? 1 : ~(0|F07B|A1U109Pad2|F06A);
// Gate A1-U221B
pullup(FS20);
assign (highz1,strong0) #0.2  FS20 = rst ? 1 : ~(0|A1U220Pad2|A1U221Pad8);
// Gate A1-U133B
pullup(A1U132Pad8);
assign (highz1,strong0) #0.2  A1U132Pad8 = rst ? 1 : ~(0|F09A|A1U132Pad2|F10B);
// Gate A1-U110A
pullup(A1U109Pad2);
assign (highz1,strong0) #0.2  A1U109Pad2 = rst ? 0 : ~(0|F06A|A1U109Pad8|F07A);
// Gate A1-U145B
pullup(A1U142Pad7);
assign (highz1,strong0) #0.2  A1U142Pad7 = rst ? 1 : ~(0|A1U143Pad8|FS13);
// Gate A1-U109A
pullup(A1U109Pad1);
assign (highz1,strong0) #0.2  A1U109Pad1 = rst ? 1 : ~(0|A1U109Pad2|FS07);
// Gate A1-U216A
pullup(A1U214Pad8);
assign (highz1,strong0) #0.2  A1U214Pad8 = rst ? 1 : ~(0|F22B|F21A|A1U214Pad2);
// Gate A1-U257B
pullup(F33A);
assign (highz1,strong0) #0.2  F33A = rst ? 0 : ~(0|A1U256Pad3|A1U255Pad7);
// Gate A1-U256B
pullup(F33B);
assign (highz1,strong0) #0.2  F33B = rst ? 0 : ~(0|A1U256Pad1|FS33);
// Gate A1-U124B
pullup(F03B);
assign (highz1,strong0) #0.2  F03B = rst ? 0 : ~(0|FS03|A1U123Pad8);
// Gate A1-U124A
pullup(F03A);
assign (highz1,strong0) #0.2  F03A = rst ? 0 : ~(0|A1U123Pad2|A1U123Pad1);
// Gate A1-U211B
pullup(F23A);
assign (highz1,strong0) #0.2  F23A = rst ? 0 : ~(0|A1U210Pad1|A1U210Pad3);
// Gate A1-U212B
pullup(F23B);
assign (highz1,strong0) #0.2  F23B = rst ? 0 : ~(0|FS23|A1U210Pad8);
// Gate A1-U119A
pullup(FS05A);
assign (highz1,strong0) #0.2  FS05A = rst ? 0 : ~(0|A1U116Pad1);
// Gate A1-U236A
pullup(A1U235Pad4);
assign (highz1,strong0) #0.2  A1U235Pad4 = rst ? 1 : ~(0|F27A|F26A|A1U235Pad1);
// Gate A1-U221A
pullup(A1U220Pad2);
assign (highz1,strong0) #0.2  A1U220Pad2 = rst ? 0 : ~(0|FS20|A1U221Pad3);
// Gate A1-U114A
pullup(A1U113Pad2);
assign (highz1,strong0) #0.2  A1U113Pad2 = rst ? 0 : ~(0|F05A|F06A|A1U113Pad8);
// Gate A1-U158A
pullup(A1U157Pad3);
assign (highz1,strong0) #0.2  A1U157Pad3 = rst ? 0 : ~(0|A1U157Pad1|F17B|F16A);
// Gate A1-U234B
pullup(CHBT08);
assign (highz1,strong0) #0.2  CHBT08 = rst ? 0 : ~(0|A1U234Pad7|RCHBT_);
// Gate A1-U136B
pullup(F11A);
assign (highz1,strong0) #0.2  F11A = rst ? 0 : ~(0|A1U135Pad8|A1U136Pad8);
// Gate A1-U136A
pullup(F11B);
assign (highz1,strong0) #0.2  F11B = rst ? 0 : ~(0|A1U136Pad2|FS11);
// Gate A1-U115A
pullup(A1U113Pad8);
assign (highz1,strong0) #0.2  A1U113Pad8 = rst ? 1 : ~(0|F06B|A1U113Pad2|F05A);
// Gate A1-U243B
pullup(F29A);
assign (highz1,strong0) #0.2  F29A = rst ? 0 : ~(0|A1U242Pad4|A1U241Pad7);
// Gate A1-U244A
pullup(A1U241Pad7);
assign (highz1,strong0) #0.2  A1U241Pad7 = rst ? 1 : ~(0|FS29|A1U242Pad4);
// Gate A1-U148A
pullup(A1U147Pad8);
assign (highz1,strong0) #0.2  A1U147Pad8 = rst ? 0 : ~(0|FS14|A1U146Pad3);
// Gate A1-U209B
pullup(F24B);
assign (highz1,strong0) #0.2  F24B = rst ? 0 : ~(0|A1U207Pad8|FS24);
// Gate A1-U235A
pullup(A1U235Pad1);
assign (highz1,strong0) #0.2  A1U235Pad1 = rst ? 0 : ~(0|F27B|F26A|A1U235Pad4);
// Gate A1-U141B
pullup(FS12);
assign (highz1,strong0) #0.2  FS12 = rst ? 0 : ~(0|A1U139Pad7|A1U139Pad3);
// Gate A1-U145A
pullup(FS13);
assign (highz1,strong0) #0.2  FS13 = rst ? 0 : ~(0|A1U142Pad7|A1U143Pad2);
// Gate A1-U134B
pullup(FS10);
assign (highz1,strong0) #0.2  FS10 = rst ? 0 : ~(0|A1U132Pad8|A1U132Pad3);
// Gate A1-U138B
pullup(FS11);
assign (highz1,strong0) #0.2  FS11 = rst ? 1 : ~(0|A1U136Pad2|A1U135Pad8);
// Gate A1-U156A
pullup(FS16);
assign (highz1,strong0) #0.2  FS16 = rst ? 0 : ~(0|A1U153Pad1|A1U154Pad8);
// Gate A1-U159A
pullup(FS17);
assign (highz1,strong0) #0.2  FS17 = rst ? 1 : ~(0|A1U156Pad8|A1U157Pad3);
// Gate A1-U149A
pullup(FS14);
assign (highz1,strong0) #0.2  FS14 = rst ? 1 : ~(0|A1U146Pad1|A1U147Pad8);
// Gate A1-U150A
pullup(A1U150Pad1);
assign (highz1,strong0) #0.2  A1U150Pad1 = rst ? 0 : ~(0|A1U150Pad2|F14A|F15B);
// Gate A1-U248B
pullup(CHBT12);
assign (highz1,strong0) #0.2  CHBT12 = rst ? 0 : ~(0|A1U248Pad7|RCHBT_);
// Gate A1-U255A
pullup(CHBT13);
assign (highz1,strong0) #0.2  CHBT13 = rst ? 0 : ~(0|A1U253Pad8|RCHBT_);
// Gate A1-U228B
pullup(FS18);
assign (highz1,strong0) #0.2  FS18 = rst ? 1 : ~(0|A1U227Pad2|A1U228Pad8);
// Gate A1-U224B
pullup(FS19);
assign (highz1,strong0) #0.2  FS19 = rst ? 0 : ~(0|A1U224Pad1|A1U224Pad8);
// Gate A1-U150B
pullup(F15B);
assign (highz1,strong0) #0.2  F15B = rst ? 0 : ~(0|FS15|A1U150Pad1);
// Gate A1-U255B
pullup(CHBT14);
assign (highz1,strong0) #0.2  CHBT14 = rst ? 0 : ~(0|A1U255Pad7|RCHBT_);
// Gate A1-U216B
pullup(F22B);
assign (highz1,strong0) #0.2  F22B = rst ? 0 : ~(0|A1U214Pad8|FS22);
// Gate A1-U220A
pullup(CHBT01);
assign (highz1,strong0) #0.2  CHBT01 = rst ? 0 : ~(0|A1U220Pad2|RCHBT_);
// Gate A1-U215B
pullup(F22A);
assign (highz1,strong0) #0.2  F22A = rst ? 0 : ~(0|A1U213Pad2|A1U214Pad2);
// Gate A1-U230B
pullup(F18B);
assign (highz1,strong0) #0.2  F18B = rst ? 0 : ~(0|A1U228Pad8|FS18);
// Gate A1-U229B
pullup(F18A);
assign (highz1,strong0) #0.2  F18A = rst ? 0 : ~(0|A1U227Pad2|A1U228Pad3);
// Gate A1-U249A
pullup(A1U249Pad1);
assign (highz1,strong0) #0.2  A1U249Pad1 = rst ? 1 : ~(0|F31B|F30A|A1U249Pad4);
// Gate A1-U128B
pullup(F02A);
assign (highz1,strong0) #0.2  F02A = rst ? 0 : ~(0|A1U126Pad7|A1U127Pad2);
// Gate A1-U129B
pullup(F02B);
assign (highz1,strong0) #0.2  F02B = rst ? 0 : ~(0|A1U127Pad8|FS02);
// Gate A1-U146A
pullup(A1U146Pad1);
assign (highz1,strong0) #0.2  A1U146Pad1 = rst ? 0 : ~(0|F14B|A1U146Pad3|F13A);
// Gate A1-U213A
pullup(CHBT03);
assign (highz1,strong0) #0.2  CHBT03 = rst ? 0 : ~(0|A1U213Pad2|RCHBT_);
// Gate A1-U147A
pullup(A1U146Pad3);
assign (highz1,strong0) #0.2  A1U146Pad3 = rst ? 1 : ~(0|F14A|A1U146Pad1|F13A);
// Gate A1-U249B
pullup(F31B);
assign (highz1,strong0) #0.2  F31B = rst ? 0 : ~(0|A1U249Pad1|FS31);
// Gate A1-U220B
pullup(CHBT02);
assign (highz1,strong0) #0.2  CHBT02 = rst ? 0 : ~(0|A1U217Pad1|RCHBT_);
// Gate A1-U128A
pullup(A1U127Pad2);
assign (highz1,strong0) #0.2  A1U127Pad2 = rst ? 1 : ~(0|A1U127Pad8|FS01_|F02A);
// Gate A1-U204A
pullup(A1U203Pad3);
assign (highz1,strong0) #0.2  A1U203Pad3 = rst ? 0 : ~(0|F25A|F24A|A1U203Pad8);
// Gate A1-U202B
pullup(F18AX);
assign (highz1,strong0) #0.2  F18AX = rst ? 0 : ~(0|F18A_);
// Gate A1-U259A
pullup(F18A_);
assign (highz1,strong0) #0.2  F18A_ = rst ? 1 : ~(0|F18A);
// Gate A1-U129A
pullup(A1U127Pad8);
assign (highz1,strong0) #0.2  A1U127Pad8 = rst ? 0 : ~(0|F02B|FS01_|A1U127Pad2);
// Gate A1-U213B
pullup(CHBT04);
assign (highz1,strong0) #0.2  CHBT04 = rst ? 0 : ~(0|A1U210Pad1|RCHBT_);
// Gate A1-U107A
pullup(A1U106Pad3);
assign (highz1,strong0) #0.2  A1U106Pad3 = rst ? 0 : ~(0|A1U105Pad7|F07A|F08A);
// Gate A1-U139A
pullup(F12A);
assign (highz1,strong0) #0.2  F12A = rst ? 0 : ~(0|A1U139Pad2|A1U139Pad3);
// Gate A1-U234A
pullup(CHBT07);
assign (highz1,strong0) #0.2  CHBT07 = rst ? 0 : ~(0|A1U232Pad8|RCHBT_);
// Gate A1-U132B
pullup(A1U132Pad2);
assign (highz1,strong0) #0.2  A1U132Pad2 = rst ? 0 : ~(0|F09A|F10A|A1U132Pad8);
// Gate A1-U134A
pullup(A1U132Pad3);
assign (highz1,strong0) #0.2  A1U132Pad3 = rst ? 1 : ~(0|FS10|A1U132Pad2);
// Gate A1-U144B
pullup(A1U143Pad8);
assign (highz1,strong0) #0.2  A1U143Pad8 = rst ? 0 : ~(0|F13A|A1U143Pad2|F12A);
// Gate A1-U206B
pullup(CHBT06);
assign (highz1,strong0) #0.2  CHBT06 = rst ? 0 : ~(0|A1U203Pad1|RCHBT_);
// Gate A1-U108B
pullup(F08B);
assign (highz1,strong0) #0.2  F08B = rst ? 0 : ~(0|A1U105Pad7|FS08);
// Gate A1-U157A
pullup(A1U157Pad1);
assign (highz1,strong0) #0.2  A1U157Pad1 = rst ? 1 : ~(0|F17A|A1U157Pad3|F16A);
// Gate A1-U106A
pullup(F08A);
assign (highz1,strong0) #0.2  F08A = rst ? 0 : ~(0|A1U105Pad8|A1U106Pad3);
// Gate A1-U241A
pullup(CHBT09);
assign (highz1,strong0) #0.2  CHBT09 = rst ? 0 : ~(0|A1U239Pad8|RCHBT_);
// Gate A1-U254A
pullup(A1U253Pad8);
assign (highz1,strong0) #0.2  A1U253Pad8 = rst ? 1 : ~(0|FS32|A1U252Pad3);
// Gate A1-U102B
pullup(FS09);
assign (highz1,strong0) #0.2  FS09 = rst ? 0 : ~(0|A1U102Pad1|A1U102Pad8);
// Gate A1-U105B
pullup(FS08);
assign (highz1,strong0) #0.2  FS08 = rst ? 0 : ~(0|A1U105Pad7|A1U105Pad8);
// Gate A1-U251A
pullup(A1U248Pad7);
assign (highz1,strong0) #0.2  A1U248Pad7 = rst ? 1 : ~(0|FS31|A1U249Pad4);
// Gate A1-U116B
pullup(FS05);
assign (highz1,strong0) #0.2  FS05 = rst ? 0 : ~(0|A1U116Pad1|A1U116Pad8);
// Gate A1-U120B
pullup(FS04);
assign (highz1,strong0) #0.2  FS04 = rst ? 0 : ~(0|A1U119Pad7|A1U120Pad8);
// Gate A1-U109B
pullup(FS07);
assign (highz1,strong0) #0.2  FS07 = rst ? 0 : ~(0|A1U109Pad1|A1U109Pad8);
// Gate A1-U113B
pullup(FS06);
assign (highz1,strong0) #0.2  FS06 = rst ? 0 : ~(0|A1U112Pad8|A1U113Pad8);
// Gate A1-U206A
pullup(CHBT05);
assign (highz1,strong0) #0.2  CHBT05 = rst ? 0 : ~(0|A1U206Pad2|RCHBT_);
// Gate A1-U259B
pullup(F03B_);
assign (highz1,strong0) #0.2  F03B_ = rst ? 1 : ~(0|F03B);
// Gate A1-U123B
pullup(FS03);
assign (highz1,strong0) #0.2  FS03 = rst ? 0 : ~(0|A1U123Pad1|A1U123Pad8);
// Gate A1-U127B
pullup(FS02);
assign (highz1,strong0) #0.2  FS02 = rst ? 1 : ~(0|A1U126Pad7|A1U127Pad8);
// Gate A1-U140B
pullup(A1U139Pad7);
assign (highz1,strong0) #0.2  A1U139Pad7 = rst ? 1 : ~(0|A1U139Pad2|F11A|F12B);
// Gate A1-U218A
pullup(A1U217Pad3);
assign (highz1,strong0) #0.2  A1U217Pad3 = rst ? 0 : ~(0|A1U217Pad8|F20A|F21A);
// Gate A1-U233A
pullup(A1U232Pad8);
assign (highz1,strong0) #0.2  A1U232Pad8 = rst ? 1 : ~(0|FS26|A1U231Pad2);
// Gate A1-U141A
pullup(A1U139Pad3);
assign (highz1,strong0) #0.2  A1U139Pad3 = rst ? 1 : ~(0|FS12|A1U139Pad2);
// Gate A1-U140A
pullup(A1U139Pad2);
assign (highz1,strong0) #0.2  A1U139Pad2 = rst ? 0 : ~(0|A1U139Pad7|F12A|F11A);
// Gate A1-U205B
pullup(F25B);
assign (highz1,strong0) #0.2  F25B = rst ? 0 : ~(0|A1U203Pad8|FS25);
// Gate A1-U204B
pullup(F25A);
assign (highz1,strong0) #0.2  F25A = rst ? 0 : ~(0|A1U203Pad1|A1U203Pad3);
// Gate A1-U258B
pullup(FS33);
assign (highz1,strong0) #0.2  FS33 = rst ? 0 : ~(0|A1U255Pad7|A1U256Pad1);
// Gate A1-U219B
pullup(F21B);
assign (highz1,strong0) #0.2  F21B = rst ? 0 : ~(0|A1U217Pad8|FS21);
// Gate A1-U222A
pullup(A1U221Pad3);
assign (highz1,strong0) #0.2  A1U221Pad3 = rst ? 1 : ~(0|A1U221Pad8|F19A|F20A);
// Gate A1-U218B
pullup(F21A);
assign (highz1,strong0) #0.2  F21A = rst ? 0 : ~(0|A1U217Pad1|A1U217Pad3);
// Gate A1-U243A
pullup(A1U242Pad4);
assign (highz1,strong0) #0.2  A1U242Pad4 = rst ? 0 : ~(0|F29A|F28A|A1U242Pad1);
// Gate A1-U231A
pullup(A1U231Pad1);
assign (highz1,strong0) #0.2  A1U231Pad1 = rst ? 1 : ~(0|A1U231Pad2|F25A|F26B);
// Gate A1-U143A
pullup(F13B);
assign (highz1,strong0) #0.2  F13B = rst ? 0 : ~(0|A1U143Pad2|FS13);
// Gate A1-U143B
pullup(F13A);
assign (highz1,strong0) #0.2  F13A = rst ? 0 : ~(0|A1U142Pad7|A1U143Pad8);
// Gate A1-U232A
pullup(A1U231Pad2);
assign (highz1,strong0) #0.2  A1U231Pad2 = rst ? 0 : ~(0|F26A|F25A|A1U231Pad1);
// Gate A1-U101A
pullup(FS07A);
assign (highz1,strong0) #0.2  FS07A = rst ? 0 : ~(0|FS07_);
// Gate A1-U223A
pullup(A1U221Pad8);
assign (highz1,strong0) #0.2  A1U221Pad8 = rst ? 0 : ~(0|F20B|F19A|A1U221Pad3);
// Gate A1-U160A
pullup(FS07_);
assign (highz1,strong0) #0.2  FS07_ = rst ? 1 : ~(0|FS07);
// Gate A1-U137A
pullup(A1U136Pad2);
assign (highz1,strong0) #0.2  A1U136Pad2 = rst ? 0 : ~(0|A1U136Pad8|F11B|F10A);
// Gate A1-U138A
pullup(A1U135Pad8);
assign (highz1,strong0) #0.2  A1U135Pad8 = rst ? 0 : ~(0|FS11|A1U136Pad8);
// Gate A1-U137B
pullup(A1U136Pad8);
assign (highz1,strong0) #0.2  A1U136Pad8 = rst ? 1 : ~(0|F11A|F10A|A1U136Pad2);
// Gate A1-U250B
pullup(F31A);
assign (highz1,strong0) #0.2  F31A = rst ? 0 : ~(0|A1U248Pad7|A1U249Pad4);
// Gate A1-U209A
pullup(A1U207Pad8);
assign (highz1,strong0) #0.2  A1U207Pad8 = rst ? 0 : ~(0|F24B|F23A|A1U207Pad2);
// Gate A1-U256A
pullup(A1U256Pad1);
assign (highz1,strong0) #0.2  A1U256Pad1 = rst ? 1 : ~(0|F33B|A1U256Pad3|F32A);
// Gate A1-U257A
pullup(A1U256Pad3);
assign (highz1,strong0) #0.2  A1U256Pad3 = rst ? 0 : ~(0|F33A|A1U256Pad1|F32A);
// Gate A1-U212A
pullup(A1U210Pad8);
assign (highz1,strong0) #0.2  A1U210Pad8 = rst ? 0 : ~(0|F23B|F22A|A1U210Pad3);
// Gate A1-U154A
pullup(A1U153Pad3);
assign (highz1,strong0) #0.2  A1U153Pad3 = rst ? 0 : ~(0|F16A|F15A|A1U153Pad1);
// Gate A1-U153A
pullup(A1U153Pad1);
assign (highz1,strong0) #0.2  A1U153Pad1 = rst ? 1 : ~(0|F16B|A1U153Pad3|F15A);
// Gate A1-U152A
pullup(FS15);
assign (highz1,strong0) #0.2  FS15 = rst ? 1 : ~(0|A1U149Pad8|A1U150Pad1);
// Gate A1-U211A
pullup(A1U210Pad3);
assign (highz1,strong0) #0.2  A1U210Pad3 = rst ? 1 : ~(0|F22A|F23A|A1U210Pad8);
// Gate A1-U210A
pullup(A1U210Pad1);
assign (highz1,strong0) #0.2  A1U210Pad1 = rst ? 0 : ~(0|FS23|A1U210Pad3);
// Gate A1-U117A
pullup(A1U116Pad2);
assign (highz1,strong0) #0.2  A1U116Pad2 = rst ? 0 : ~(0|F04A|A1U116Pad8|F05A);
// Gate A1-U116A
pullup(A1U116Pad1);
assign (highz1,strong0) #0.2  A1U116Pad1 = rst ? 1 : ~(0|A1U116Pad2|FS05);
// Gate A1-U252B
pullup(F32B);
assign (highz1,strong0) #0.2  F32B = rst ? 0 : ~(0|FS32|A1U252Pad1);
// Gate A1-U253B
pullup(F32A);
assign (highz1,strong0) #0.2  F32A = rst ? 0 : ~(0|A1U252Pad3|A1U253Pad8);
// Gate A1-U208B
pullup(F24A);
assign (highz1,strong0) #0.2  F24A = rst ? 0 : ~(0|A1U206Pad2|A1U207Pad2);
// Gate A1-U118A
pullup(A1U116Pad8);
assign (highz1,strong0) #0.2  A1U116Pad8 = rst ? 1 : ~(0|F05B|F04A|A1U116Pad2);
// Gate A1-U118B
pullup(F05B);
assign (highz1,strong0) #0.2  F05B = rst ? 0 : ~(0|A1U116Pad8|FS05);
// Gate A1-U241B
pullup(CHBT10);
assign (highz1,strong0) #0.2  CHBT10 = rst ? 0 : ~(0|A1U241Pad7|RCHBT_);
// Gate A1-U127A
pullup(A1U126Pad7);
assign (highz1,strong0) #0.2  A1U126Pad7 = rst ? 0 : ~(0|A1U127Pad2|FS02);
// Gate A1-U258A
pullup(A1U255Pad7);
assign (highz1,strong0) #0.2  A1U255Pad7 = rst ? 1 : ~(0|FS33|A1U256Pad3);
// Gate A1-U248A
pullup(CHBT11);
assign (highz1,strong0) #0.2  CHBT11 = rst ? 0 : ~(0|A1U246Pad8|RCHBT_);
// Gate A1-U231B
pullup(F26B);
assign (highz1,strong0) #0.2  F26B = rst ? 0 : ~(0|A1U231Pad1|FS26);
// Gate A1-U232B
pullup(F26A);
assign (highz1,strong0) #0.2  F26A = rst ? 0 : ~(0|A1U231Pad2|A1U232Pad8);
// Gate A1-U238A
pullup(A1U238Pad1);
assign (highz1,strong0) #0.2  A1U238Pad1 = rst ? 1 : ~(0|F28B|F27A|A1U238Pad4);
// Gate A1-U146B
pullup(F14B);
assign (highz1,strong0) #0.2  F14B = rst ? 0 : ~(0|FS14|A1U146Pad1);
// Gate A1-U147B
pullup(F14A);
assign (highz1,strong0) #0.2  F14A = rst ? 0 : ~(0|A1U146Pad3|A1U147Pad8);
// Gate A1-U121A
pullup(A1U120Pad2);
assign (highz1,strong0) #0.2  A1U120Pad2 = rst ? 0 : ~(0|F03A|A1U120Pad8|F04A);
// Gate A1-U242B
pullup(F29B);
assign (highz1,strong0) #0.2  F29B = rst ? 0 : ~(0|A1U242Pad1|FS29);
// Gate A1-U239A
pullup(A1U238Pad4);
assign (highz1,strong0) #0.2  A1U238Pad4 = rst ? 0 : ~(0|F28A|F27A|A1U238Pad1);
// Gate A1-U122A
pullup(A1U120Pad8);
assign (highz1,strong0) #0.2  A1U120Pad8 = rst ? 1 : ~(0|F04B|A1U120Pad2|F03A);
// Gate A1-U155A
pullup(A1U154Pad8);
assign (highz1,strong0) #0.2  A1U154Pad8 = rst ? 1 : ~(0|FS16|A1U153Pad3);
// Gate A1-U214A
pullup(A1U213Pad2);
assign (highz1,strong0) #0.2  A1U213Pad2 = rst ? 1 : ~(0|A1U214Pad2|FS22);
// Gate A1-U152B
pullup(A1U149Pad8);
assign (highz1,strong0) #0.2  A1U149Pad8 = rst ? 0 : ~(0|A1U150Pad2|FS15);
// Gate A1-U240A
pullup(A1U239Pad8);
assign (highz1,strong0) #0.2  A1U239Pad8 = rst ? 1 : ~(0|FS28|A1U238Pad4);
// Gate A1-U108A
pullup(A1U105Pad7);
assign (highz1,strong0) #0.2  A1U105Pad7 = rst ? 1 : ~(0|F08B|F07A|A1U106Pad3);
// Gate A1-U110B
pullup(F07A);
assign (highz1,strong0) #0.2  F07A = rst ? 0 : ~(0|A1U109Pad1|A1U109Pad2);
// Gate A1-U106B
pullup(A1U105Pad8);
assign (highz1,strong0) #0.2  A1U105Pad8 = rst ? 1 : ~(0|FS08|A1U106Pad3);
// Gate A1-U240B
pullup(FS28);
assign (highz1,strong0) #0.2  FS28 = rst ? 0 : ~(0|A1U238Pad1|A1U239Pad8);
// Gate A1-U120A
pullup(A1U119Pad7);
assign (highz1,strong0) #0.2  A1U119Pad7 = rst ? 1 : ~(0|A1U120Pad2|FS04);
// Gate A1-U202A
pullup(F07A_);
assign (highz1,strong0) #0.2  F07A_ = rst ? 1 : ~(0|F07A);
// Gate A1-U151B
pullup(F15A);
assign (highz1,strong0) #0.2  F15A = rst ? 0 : ~(0|A1U149Pad8|A1U150Pad2);
// Gate A1-U151A
pullup(A1U150Pad2);
assign (highz1,strong0) #0.2  A1U150Pad2 = rst ? 1 : ~(0|F15A|A1U150Pad1|F14A);
// Gate A1-U247A
pullup(A1U246Pad8);
assign (highz1,strong0) #0.2  A1U246Pad8 = rst ? 1 : ~(0|FS30|A1U245Pad4);
// Gate A1-U104B
pullup(F09A);
assign (highz1,strong0) #0.2  F09A = rst ? 0 : ~(0|A1U102Pad2|A1U102Pad1);
// Gate A1-U103B
pullup(F09B);
assign (highz1,strong0) #0.2  F09B = rst ? 0 : ~(0|A1U102Pad8|FS09);
// Gate A1-U217B
pullup(FS21);
assign (highz1,strong0) #0.2  FS21 = rst ? 0 : ~(0|A1U217Pad1|A1U217Pad8);
// Gate A1-U230A
pullup(A1U228Pad8);
assign (highz1,strong0) #0.2  A1U228Pad8 = rst ? 0 : ~(0|F18B|F17A|A1U228Pad3);
// Gate A1-U246B
pullup(F30A);
assign (highz1,strong0) #0.2  F30A = rst ? 0 : ~(0|A1U245Pad4|A1U246Pad8);
// Gate A1-U229A
pullup(A1U228Pad3);
assign (highz1,strong0) #0.2  A1U228Pad3 = rst ? 1 : ~(0|A1U228Pad8|F17A|F18A);
// Gate A1-U250A
pullup(A1U249Pad4);
assign (highz1,strong0) #0.2  A1U249Pad4 = rst ? 0 : ~(0|F31A|F30A|A1U249Pad1);
// Gate A1-U225A
pullup(A1U224Pad3);
assign (highz1,strong0) #0.2  A1U224Pad3 = rst ? 0 : ~(0|A1U224Pad8|F18A|F19A);
// Gate A1-U224A
pullup(A1U224Pad1);
assign (highz1,strong0) #0.2  A1U224Pad1 = rst ? 1 : ~(0|FS19|A1U224Pad3);
// Gate A1-U114B
pullup(F06A);
assign (highz1,strong0) #0.2  F06A = rst ? 0 : ~(0|A1U112Pad8|A1U113Pad2);
// Gate A1-U115B
pullup(F06B);
assign (highz1,strong0) #0.2  F06B = rst ? 0 : ~(0|A1U113Pad8|FS06);
// Gate A1-U207A
pullup(A1U206Pad2);
assign (highz1,strong0) #0.2  A1U206Pad2 = rst ? 0 : ~(0|A1U207Pad2|FS24);
// Gate A1-U101B
pullup(FS08_);
assign (highz1,strong0) #0.2  FS08_ = rst ? 1 : ~(0|FS08);
// Gate A1-U226A
pullup(A1U224Pad8);
assign (highz1,strong0) #0.2  A1U224Pad8 = rst ? 1 : ~(0|F19B|F18A|A1U224Pad3);
// Gate A1-U139B
pullup(F12B);
assign (highz1,strong0) #0.2  F12B = rst ? 0 : ~(0|A1U139Pad7|FS12);
// Gate A1-U245B
pullup(F30B);
assign (highz1,strong0) #0.2  F30B = rst ? 0 : ~(0|A1U245Pad1|FS30);

endmodule
