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

assign U232Pad8 = rst ? 1 : ~(0|FS26|U231Pad2);
assign FS02A = rst ? 0 : ~(0|U126Pad7);
assign F28A = rst ? 0 : ~(0|U238Pad4|U239Pad8);
assign F28B = rst ? 0 : ~(0|FS28|U238Pad1);
assign F16A = rst ? 0 : ~(0|U153Pad3|U154Pad8);
assign FS26 = rst ? 0 : ~(0|U231Pad1|U232Pad8);
assign F16B = rst ? 0 : ~(0|FS16|U153Pad1);
assign CHAT04 = rst ? 0 : ~(0|RCHAT_|U102Pad1);
assign CHAT05 = rst ? 0 : ~(0|RCHAT_|U132Pad3);
assign CHAT06 = rst ? 0 : ~(0|RCHAT_|U135Pad8);
assign CHAT07 = rst ? 0 : ~(0|U139Pad3|RCHAT_);
assign U206Pad2 = rst ? 1 : ~(0|U207Pad2|FS24);
assign CHAT01 = rst ? 0 : ~(0|RCHAT_|U112Pad8);
assign CHAT02 = rst ? 0 : ~(0|U109Pad1|RCHAT_);
assign CHAT03 = rst ? 0 : ~(0|U105Pad8|RCHAT_);
assign U231Pad2 = rst ? 0 : ~(0|F26A|F25A|U231Pad1);
assign CHAT08 = rst ? 0 : ~(0|U142Pad7|RCHAT_);
assign U127Pad8 = rst ? 1 : ~(0|F02B|FS01_|U127Pad2);
assign U203Pad8 = rst ? 1 : ~(0|F25B|F24A|U203Pad3);
assign F19A = rst ? 0 : ~(0|U224Pad1|U224Pad3);
assign F19B = rst ? 0 : ~(0|U224Pad8|FS19);
assign F05A = rst ? 0 : ~(0|U116Pad1|U116Pad2);
assign F05B = rst ? 0 : ~(0|U116Pad8|FS05);
assign U253Pad8 = rst ? 1 : ~(0|FS32|U252Pad3);
assign CHAT13 = rst ? 0 : ~(0|U227Pad2|RCHAT_);
assign F27B = rst ? 0 : ~(0|U235Pad1|FS27);
assign U143Pad2 = rst ? 1 : ~(0|U143Pad8|F12A|F13B);
assign CHAT12 = rst ? 0 : ~(0|RCHAT_|U156Pad8);
assign U238Pad1 = rst ? 1 : ~(0|F28B|F27A|U238Pad4);
assign CHAT11 = rst ? 0 : ~(0|RCHAT_|U154Pad8);
assign U235Pad4 = rst ? 0 : ~(0|F27A|F26A|U235Pad1);
assign U203Pad3 = rst ? 0 : ~(0|F25A|F24A|U203Pad8);
assign CHAT10 = rst ? 0 : ~(0|RCHAT_|U149Pad8);
assign U235Pad1 = rst ? 1 : ~(0|F27B|F26A|U235Pad4);
assign F17B = rst ? 0 : ~(0|U157Pad3|FS17);
assign U203Pad1 = rst ? 1 : ~(0|FS25|U203Pad3);
assign F17A = rst ? 0 : ~(0|U156Pad8|U157Pad1);
assign U109Pad2 = rst ? 0 : ~(0|F06A|U109Pad8|F07A);
assign U150Pad1 = rst ? 1 : ~(0|U150Pad2|F14A|F15B);
assign U150Pad2 = rst ? 0 : ~(0|F15A|U150Pad1|F14A);
assign U109Pad1 = rst ? 1 : ~(0|U109Pad2|FS07);
assign FS30 = rst ? 0 : ~(0|U245Pad1|U246Pad8);
assign FS32 = rst ? 0 : ~(0|U253Pad8|U252Pad1);
assign U224Pad8 = rst ? 1 : ~(0|F19B|F18A|U224Pad3);
assign CHAT14 = rst ? 0 : ~(0|U224Pad1|RCHAT_);
assign U249Pad1 = rst ? 1 : ~(0|F31B|F30A|U249Pad4);
assign U109Pad8 = rst ? 1 : ~(0|F07B|U109Pad2|F06A);
assign U221Pad8 = rst ? 1 : ~(0|F20B|F19A|U221Pad3);
assign U224Pad3 = rst ? 0 : ~(0|U224Pad8|F18A|F19A);
assign U224Pad1 = rst ? 1 : ~(0|FS19|U224Pad3);
assign F04B = rst ? 0 : ~(0|U120Pad8|FS04);
assign U255Pad7 = rst ? 1 : ~(0|FS33|U256Pad3);
assign U102Pad2 = rst ? 0 : ~(0|F09A|F08A|U102Pad8);
assign F20A = rst ? 0 : ~(0|U220Pad2|U221Pad3);
assign F20B = rst ? 0 : ~(0|U221Pad8|FS20);
assign U102Pad8 = rst ? 1 : ~(0|F09B|F08A|U102Pad2);
assign U153Pad3 = rst ? 0 : ~(0|F16A|F15A|U153Pad1);
assign FS04A = rst ? 0 : ~(0|U119Pad7);
assign U120Pad2 = rst ? 0 : ~(0|F03A|U120Pad8|F04A);
assign FS06_ = rst ? 0 : ~(0|FS06);
assign U207Pad8 = rst ? 1 : ~(0|F24B|F23A|U207Pad2);
assign U120Pad8 = rst ? 1 : ~(0|F04B|U120Pad2|F03A);
assign F10A = rst ? 0 : ~(0|U132Pad2|U132Pad3);
assign U126Pad7 = rst ? 1 : ~(0|U127Pad2|FS02);
assign U112Pad8 = rst ? 1 : ~(0|U113Pad2|FS06);
assign FS27 = rst ? 0 : ~(0|U235Pad1|U234Pad7);
assign U102Pad1 = rst ? 1 : ~(0|U102Pad2|FS09);
assign FS25 = rst ? 0 : ~(0|U203Pad1|U203Pad8);
assign U214Pad2 = rst ? 0 : ~(0|U214Pad8|F21A|F22A);
assign FS23 = rst ? 0 : ~(0|U210Pad1|U210Pad8);
assign FS22 = rst ? 0 : ~(0|U213Pad2|U214Pad8);
assign FS21 = rst ? 0 : ~(0|U217Pad1|U217Pad8);
assign FS20 = rst ? 0 : ~(0|U220Pad2|U221Pad8);
assign U123Pad2 = rst ? 0 : ~(0|U123Pad8|F02A|F03A);
assign U210Pad8 = rst ? 1 : ~(0|F23B|F22A|U210Pad3);
assign FS29 = rst ? 0 : ~(0|U242Pad1|U241Pad7);
assign FS28 = rst ? 0 : ~(0|U238Pad1|U239Pad8);
assign U252Pad1 = rst ? 1 : ~(0|F32B|U252Pad3|F31A);
assign U119Pad7 = rst ? 1 : ~(0|U120Pad2|FS04);
assign F04A = rst ? 0 : ~(0|U119Pad7|U120Pad2);
assign F33A = rst ? 0 : ~(0|U256Pad3|U255Pad7);
assign F33B = rst ? 0 : ~(0|U256Pad1|FS33);
assign U113Pad8 = rst ? 1 : ~(0|F06B|U113Pad2|F05A);
assign U127Pad2 = rst ? 0 : ~(0|U127Pad8|FS01_|F02A);
assign F03B = rst ? 0 : ~(0|FS03|U123Pad8);
assign F03A = rst ? 0 : ~(0|U123Pad2|U123Pad1);
assign F08A = rst ? 0 : ~(0|U105Pad8|U106Pad3);
assign F23A = rst ? 0 : ~(0|U210Pad1|U210Pad3);
assign U113Pad2 = rst ? 0 : ~(0|F05A|F06A|U113Pad8);
assign F23B = rst ? 0 : ~(0|FS23|U210Pad8);
assign FS05A = rst ? 0 : ~(0|U116Pad1);
assign U231Pad1 = rst ? 1 : ~(0|U231Pad2|F25A|F26B);
assign U153Pad1 = rst ? 1 : ~(0|F16B|U153Pad3|F15A);
assign U156Pad8 = rst ? 1 : ~(0|FS17|U157Pad1);
assign F07A_ = rst ? 0 : ~(0|F07A);
assign F11A = rst ? 0 : ~(0|U135Pad8|U136Pad8);
assign F11B = rst ? 0 : ~(0|U136Pad2|FS11);
assign F29B = rst ? 0 : ~(0|U242Pad1|FS29);
assign U116Pad2 = rst ? 0 : ~(0|F04A|U116Pad8|F05A);
assign U241Pad7 = rst ? 1 : ~(0|FS29|U242Pad4);
assign U116Pad1 = rst ? 1 : ~(0|U116Pad2|FS05);
assign U157Pad3 = rst ? 1 : ~(0|U157Pad1|F17B|F16A);
assign F29A = rst ? 0 : ~(0|U242Pad4|U241Pad7);
assign U157Pad1 = rst ? 0 : ~(0|F17A|U157Pad3|F16A);
assign U116Pad8 = rst ? 1 : ~(0|F05B|F04A|U116Pad2);
assign U149Pad8 = rst ? 1 : ~(0|U150Pad2|FS15);
assign FS12 = rst ? 0 : ~(0|U139Pad7|U139Pad3);
assign FS13 = rst ? 0 : ~(0|U142Pad7|U143Pad2);
assign FS10 = rst ? 0 : ~(0|U132Pad8|U132Pad3);
assign FS11 = rst ? 0 : ~(0|U136Pad2|U135Pad8);
assign FS16 = rst ? 0 : ~(0|U153Pad1|U154Pad8);
assign FS17 = rst ? 0 : ~(0|U156Pad8|U157Pad3);
assign FS14 = rst ? 0 : ~(0|U146Pad1|U147Pad8);
assign FS15 = rst ? 0 : ~(0|U149Pad8|U150Pad1);
assign CHBT12 = rst ? 0 : ~(0|U248Pad7|RCHBT_);
assign CHBT13 = rst ? 0 : ~(0|U253Pad8|RCHBT_);
assign FS18 = rst ? 0 : ~(0|U227Pad2|U228Pad8);
assign FS19 = rst ? 0 : ~(0|U224Pad1|U224Pad8);
assign CHBT14 = rst ? 0 : ~(0|U255Pad7|RCHBT_);
assign F22B = rst ? 0 : ~(0|U214Pad8|FS22);
assign CHBT01 = rst ? 0 : ~(0|U220Pad2|RCHBT_);
assign U136Pad2 = rst ? 1 : ~(0|U136Pad8|F11B|F10A);
assign F22A = rst ? 0 : ~(0|U213Pad2|U214Pad2);
assign F18B = rst ? 0 : ~(0|U228Pad8|FS18);
assign F18A = rst ? 0 : ~(0|U227Pad2|U228Pad3);
assign U136Pad8 = rst ? 0 : ~(0|F11A|F10A|U136Pad2);
assign F02A = rst ? 0 : ~(0|U126Pad7|U127Pad2);
assign F02B = rst ? 0 : ~(0|U127Pad8|FS02);
assign CHBT03 = rst ? 0 : ~(0|U213Pad2|RCHBT_);
assign FS31 = rst ? 0 : ~(0|U249Pad1|U248Pad7);
assign CHBT02 = rst ? 0 : ~(0|U217Pad1|RCHBT_);
assign CHBT04 = rst ? 0 : ~(0|U210Pad1|RCHBT_);
assign U106Pad3 = rst ? 0 : ~(0|U105Pad7|F07A|F08A);
assign CHBT05 = rst ? 0 : ~(0|U206Pad2|RCHBT_);
assign F18AX = rst ? 0 : ~(0|F18A_);
assign F18A_ = rst ? 0 : ~(0|F18A);
assign U221Pad3 = rst ? 0 : ~(0|U221Pad8|F19A|F20A);
assign CHAT09 = rst ? 0 : ~(0|U147Pad8|RCHAT_);
assign F12A = rst ? 0 : ~(0|U139Pad2|U139Pad3);
assign CHBT07 = rst ? 0 : ~(0|U232Pad8|RCHBT_);
assign U123Pad8 = rst ? 1 : ~(0|U123Pad2|F03B|F02A);
assign F12B = rst ? 0 : ~(0|U139Pad7|FS12);
assign CHBT06 = rst ? 0 : ~(0|U203Pad1|RCHBT_);
assign F08B = rst ? 0 : ~(0|U105Pad7|FS08);
assign U123Pad1 = rst ? 1 : ~(0|U123Pad2|FS03);
assign CHBT09 = rst ? 0 : ~(0|U239Pad8|RCHBT_);
assign CHBT08 = rst ? 0 : ~(0|U234Pad7|RCHBT_);
assign FS09 = rst ? 0 : ~(0|U102Pad1|U102Pad8);
assign FS08 = rst ? 0 : ~(0|U105Pad7|U105Pad8);
assign FS05 = rst ? 0 : ~(0|U116Pad1|U116Pad8);
assign FS04 = rst ? 0 : ~(0|U119Pad7|U120Pad8);
assign FS07 = rst ? 0 : ~(0|U109Pad1|U109Pad8);
assign FS06 = rst ? 0 : ~(0|U112Pad8|U113Pad8);
assign U210Pad3 = rst ? 0 : ~(0|F22A|F23A|U210Pad8);
assign F03B_ = rst ? 0 : ~(0|F03B);
assign FS03 = rst ? 0 : ~(0|U123Pad1|U123Pad8);
assign FS02 = rst ? 0 : ~(0|U126Pad7|U127Pad8);
assign F31B = rst ? 0 : ~(0|U249Pad1|FS31);
assign F31A = rst ? 0 : ~(0|U248Pad7|U249Pad4);
assign U146Pad3 = rst ? 0 : ~(0|F14A|U146Pad1|F13A);
assign F25A = rst ? 0 : ~(0|U203Pad1|U203Pad3);
assign FS33 = rst ? 0 : ~(0|U255Pad7|U256Pad1);
assign F21B = rst ? 0 : ~(0|U217Pad8|FS21);
assign U207Pad2 = rst ? 0 : ~(0|U207Pad8|F23A|F24A);
assign U146Pad1 = rst ? 1 : ~(0|F14B|U146Pad3|F13A);
assign U246Pad8 = rst ? 1 : ~(0|FS30|U245Pad4);
assign F21A = rst ? 0 : ~(0|U217Pad1|U217Pad3);
assign F13B = rst ? 0 : ~(0|U143Pad2|FS13);
assign F13A = rst ? 0 : ~(0|U142Pad7|U143Pad8);
assign U139Pad3 = rst ? 1 : ~(0|FS12|U139Pad2);
assign U139Pad2 = rst ? 0 : ~(0|U139Pad7|F12A|F11A);
assign FS07A = rst ? 0 : ~(0|FS07_);
assign F10B = rst ? 0 : ~(0|U132Pad8|FS10);
assign FS07_ = rst ? 0 : ~(0|FS07);
assign U227Pad2 = rst ? 1 : ~(0|FS18|U228Pad3);
assign U135Pad8 = rst ? 1 : ~(0|FS11|U136Pad8);
assign U248Pad7 = rst ? 1 : ~(0|FS31|U249Pad4);
assign U234Pad7 = rst ? 1 : ~(0|FS27|U235Pad4);
assign U213Pad2 = rst ? 1 : ~(0|U214Pad2|FS22);
assign F32B = rst ? 0 : ~(0|FS32|U252Pad1);
assign F32A = rst ? 0 : ~(0|U252Pad3|U253Pad8);
assign F24A = rst ? 0 : ~(0|U206Pad2|U207Pad2);
assign F24B = rst ? 0 : ~(0|U207Pad8|FS24);
assign U154Pad8 = rst ? 1 : ~(0|FS16|U153Pad3);
assign CHBT10 = rst ? 0 : ~(0|U241Pad7|RCHBT_);
assign F27A = rst ? 0 : ~(0|U234Pad7|U235Pad4);
assign CHBT11 = rst ? 0 : ~(0|U246Pad8|RCHBT_);
assign F26B = rst ? 0 : ~(0|U231Pad1|FS26);
assign F26A = rst ? 0 : ~(0|U231Pad2|U232Pad8);
assign U239Pad8 = rst ? 1 : ~(0|FS28|U238Pad4);
assign F25B = rst ? 0 : ~(0|U203Pad8|FS25);
assign F14B = rst ? 0 : ~(0|FS14|U146Pad1);
assign F14A = rst ? 0 : ~(0|U146Pad3|U147Pad8);
assign U105Pad8 = rst ? 1 : ~(0|FS08|U106Pad3);
assign U105Pad7 = rst ? 1 : ~(0|F08B|F07A|U106Pad3);
assign U245Pad4 = rst ? 0 : ~(0|F30A|U245Pad1|F29A);
assign U147Pad8 = rst ? 1 : ~(0|FS14|U146Pad3);
assign U139Pad7 = rst ? 1 : ~(0|U139Pad2|F11A|F12B);
assign F07B = rst ? 0 : ~(0|U109Pad8|FS07);
assign F07A = rst ? 0 : ~(0|U109Pad1|U109Pad2);
assign U249Pad4 = rst ? 0 : ~(0|F31A|F30A|U249Pad1);
assign FS03A = rst ? 0 : ~(0|U123Pad1);
assign U143Pad8 = rst ? 0 : ~(0|F13A|U143Pad2|F12A);
assign U132Pad2 = rst ? 0 : ~(0|F09A|F10A|U132Pad8);
assign U132Pad3 = rst ? 1 : ~(0|FS10|U132Pad2);
assign U220Pad2 = rst ? 1 : ~(0|FS20|U221Pad3);
assign U252Pad3 = rst ? 0 : ~(0|F32A|F31A|U252Pad1);
assign U132Pad8 = rst ? 1 : ~(0|F09A|U132Pad2|F10B);
assign U210Pad1 = rst ? 1 : ~(0|FS23|U210Pad3);
assign U238Pad4 = rst ? 0 : ~(0|F28A|F27A|U238Pad1);
assign F15A = rst ? 0 : ~(0|U149Pad8|U150Pad2);
assign F15B = rst ? 0 : ~(0|FS15|U150Pad1);
assign FS24 = rst ? 0 : ~(0|U206Pad2|U207Pad8);
assign U217Pad1 = rst ? 1 : ~(0|FS21|U217Pad3);
assign F09A = rst ? 0 : ~(0|U102Pad2|U102Pad1);
assign F09B = rst ? 0 : ~(0|U102Pad8|FS09);
assign U245Pad1 = rst ? 1 : ~(0|F30B|F29A|U245Pad4);
assign F30A = rst ? 0 : ~(0|U245Pad4|U246Pad8);
assign U242Pad4 = rst ? 0 : ~(0|F29A|F28A|U242Pad1);
assign U242Pad1 = rst ? 1 : ~(0|F29B|F28A|U242Pad4);
assign U217Pad8 = rst ? 1 : ~(0|F21B|F20A|U217Pad3);
assign U228Pad3 = rst ? 0 : ~(0|U228Pad8|F17A|F18A);
assign U142Pad7 = rst ? 1 : ~(0|U143Pad8|FS13);
assign U214Pad8 = rst ? 1 : ~(0|F22B|F21A|U214Pad2);
assign F06A = rst ? 0 : ~(0|U112Pad8|U113Pad2);
assign F06B = rst ? 0 : ~(0|U113Pad8|FS06);
assign FS08_ = rst ? 0 : ~(0|FS08);
assign U228Pad8 = rst ? 1 : ~(0|F18B|F17A|U228Pad3);
assign U217Pad3 = rst ? 0 : ~(0|U217Pad8|F20A|F21A);
assign U256Pad1 = rst ? 1 : ~(0|F33B|U256Pad3|F32A);
assign U256Pad3 = rst ? 0 : ~(0|F33A|U256Pad1|F32A);
assign F30B = rst ? 0 : ~(0|U245Pad1|FS30);

endmodule
