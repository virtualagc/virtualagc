// Verilog module auto-generated for AGC module A18 by dumbVerilog.py

module A18 ( 
  rst, ALTEST, CAURST, CCH13, CCH33, CGA18, CH1111, CH1112, CH1114, CH1116,
  CH1211, CH1212, CH1216, CH3311, CH3313, CH3314, CH3316, CHAT11, CHAT12,
  CHAT13, CHAT14, CHBT11, CHBT12, CHBT13, CHBT14, CHOR11_, CHOR12_, CHOR13_,
  CHOR16_, CHWL01_, CHWL02_, CHWL03_, CHWL04_, CHWL11_, DKEND, F09A_, F09B,
  F09B_, F09D, F10A, F10A_, F17A, F17B, F5ASB2_, F5BSB2_, GOJAM, GTRST_,
  GTSET_, LRIN0, LRIN1, MAINRS, MARK, MKEY1, MKEY2, MKEY3, MKEY4, MKEY5,
  MRKREJ, MRKRST, NAVRST, NKEY1, NKEY2, NKEY3, NKEY4, NKEY5, RCH13_, RCH33_,
  RCHG_, RRIN0, RRIN1, SB0_, SB2_, SBYBUT, STOP, T05, T11, TEMPIN, W1110,
  WCH13_, XB5_, XB6_, XT1_, CHOR14_, F17A_, F17B_, HERB, TPORA_, TPOR_, CH11,
  CH12, CH13, CH1301, CH1302, CH1303, CH1304, CH1311, CH14, CH1501, CH1502,
  CH1503, CH1504, CH1505, CH16, CH1601, CH1602, CH1603, CH1604, CH1605, CH1606,
  CH1607, CH3312, CNTOF9, DLKRPT, END, ERRST, F10AS0, KYRPT1, KYRPT2, LRRANG,
  LRSYNC, LRXVEL, LRYVEL, LRZVEL, MKRPT, RADRPT, RCH15_, RCH16_, RNRADM,
  RNRADP, RRRANG, RRRARA, RRSYNC, SBY, SBYLIT, STNDBY, STNDBY_, TEMPIN_
);

input wire rst, ALTEST, CAURST, CCH13, CCH33, CGA18, CH1111, CH1112, CH1114,
  CH1116, CH1211, CH1212, CH1216, CH3311, CH3313, CH3314, CH3316, CHAT11,
  CHAT12, CHAT13, CHAT14, CHBT11, CHBT12, CHBT13, CHBT14, CHOR11_, CHOR12_,
  CHOR13_, CHOR16_, CHWL01_, CHWL02_, CHWL03_, CHWL04_, CHWL11_, DKEND, F09A_,
  F09B, F09B_, F09D, F10A, F10A_, F17A, F17B, F5ASB2_, F5BSB2_, GOJAM, GTRST_,
  GTSET_, LRIN0, LRIN1, MAINRS, MARK, MKEY1, MKEY2, MKEY3, MKEY4, MKEY5,
  MRKREJ, MRKRST, NAVRST, NKEY1, NKEY2, NKEY3, NKEY4, NKEY5, RCH13_, RCH33_,
  RCHG_, RRIN0, RRIN1, SB0_, SB2_, SBYBUT, STOP, T05, T11, TEMPIN, W1110,
  WCH13_, XB5_, XB6_, XT1_;

inout wire CHOR14_, F17A_, F17B_, HERB, TPORA_, TPOR_;

output wire CH11, CH12, CH13, CH1301, CH1302, CH1303, CH1304, CH1311, CH14,
  CH1501, CH1502, CH1503, CH1504, CH1505, CH16, CH1601, CH1602, CH1603, CH1604,
  CH1605, CH1606, CH1607, CH3312, CNTOF9, DLKRPT, END, ERRST, F10AS0, KYRPT1,
  KYRPT2, LRRANG, LRSYNC, LRXVEL, LRYVEL, LRZVEL, MKRPT, RADRPT, RCH15_,
  RCH16_, RNRADM, RNRADP, RRRANG, RRRARA, RRSYNC, SBY, SBYLIT, STNDBY, STNDBY_,
  TEMPIN_;

assign U244Pad2 = rst ? 0 : ~(0|U242Pad3|U245Pad2);
assign U121Pad7 = rst ? 0 : ~(0|NKEY4|U123Pad3);
assign U121Pad3 = rst ? 0 : ~(0|U118Pad1|U120Pad2);
assign U229Pad2 = rst ? 0 : ~(0|U230Pad2|U228Pad2);
assign U257Pad1 = rst ? 0 : ~(0|F10A|U256Pad2);
assign F10AS0 = rst ? 0 : ~(0|F10A_|SB0_);
assign U230Pad2 = rst ? 0 : ~(0|WCH13_|CHWL04_);
assign RRRARA = rst ? 0 : ~(0|U216Pad7|U214Pad7|U214Pad2);
assign U140Pad1 = rst ? 0 : ~(0|ALTEST|STNDBY);
assign J2Pad270 = rst ? 0 : ~(0);
assign CH1304 = rst ? 0 : ~(0|RCH13_|U229Pad2);
assign U111Pad1 = rst ? 0 : ~(0|U111Pad2);
assign U111Pad2 = rst ? 0 : ~(0|MARK|U112Pad1);
assign U258Pad3 = rst ? 0 : ~(0|U259Pad1|U258Pad1);
assign U258Pad1 = rst ? 0 : ~(0|CCH33|U258Pad3);
assign U158Pad1 = rst ? 0 : ~(0|U154Pad9|U158Pad3);
assign U212Pad8 = rst ? 0 : ~(0|U217Pad2|GTSET_);
assign U206Pad1 = rst ? 0 : ~(0|U204Pad2|U204Pad3|U203Pad9);
assign U160Pad2 = rst ? 0 : ~(0|KYRPT1|U154Pad4);
assign U212Pad1 = rst ? 0 : ~(0|RADRPT|GOJAM|U211Pad7);
assign U203Pad9 = rst ? 0 : ~(0|LRIN1);
assign U129Pad2 = rst ? 0 : ~(0|U130Pad1|NKEY1);
assign U219Pad3 = rst ? 0 : ~(0|U220Pad9|U221Pad8);
assign U242Pad7 = rst ? 0 : ~(0|U245Pad2|U242Pad1);
assign LRRANG = rst ? 0 : ~(0|U214Pad6|U214Pad7|U214Pad8);
assign U245Pad2 = rst ? 0 : ~(0|U242Pad3|U242Pad7);
assign U256Pad1 = rst ? 0 : ~(0|U256Pad2|DLKRPT);
assign U133Pad7 = rst ? 0 : ~(0|U133Pad9|U134Pad1);
assign DLKRPT = rst ? 0 : ~(0|U256Pad1|U255Pad2);
assign J4Pad471 = rst ? 0 : ~(0);
assign U133Pad9 = rst ? 0 : ~(0|U133Pad7|U133Pad8);
assign U133Pad8 = rst ? 0 : ~(0|U134Pad8|F17B_);
assign CH1505 = rst ? 0 : ~(0|U151Pad3|RCH15_);
assign U109Pad1 = rst ? 0 : ~(0|U109Pad2);
assign U235Pad1 = rst ? 0 : ~(0|U235Pad2|U234Pad8);
assign U235Pad2 = rst ? 0 : ~(0|U234Pad2|U234Pad8);
assign U109Pad2 = rst ? 0 : ~(0|U110Pad1|MRKREJ);
assign U150Pad1 = rst ? 0 : ~(0|U149Pad3);
assign U117Pad8 = rst ? 0 : ~(0|F09A_|U115Pad3|U116Pad2|U118Pad1);
assign U115Pad1 = rst ? 0 : ~(0|KYRPT2|U115Pad3);
assign U117Pad1 = rst ? 0 : ~(0|F09D|U116Pad2|U116Pad6);
assign U221Pad8 = rst ? 0 : ~(0|SB2_|U231Pad3|F10A_);
assign U224Pad3 = rst ? 0 : ~(0|WCH13_|CHWL02_);
assign KYRPT1 = rst ? 0 : ~(0|U157Pad4|TPOR_|F09B_);
assign U102Pad1 = rst ? 0 : ~(0|U102Pad2|U102Pad3);
assign U218Pad8 = rst ? 0 : ~(0|U204Pad2|U219Pad3|F5BSB2_);
assign U102Pad3 = rst ? 0 : ~(0|U103Pad1|U105Pad3);
assign U102Pad2 = rst ? 0 : ~(0|U102Pad1|MKRPT);
assign U255Pad2 = rst ? 0 : ~(0|DKEND);
assign U118Pad1 = rst ? 0 : ~(0|U114Pad8);
assign RRRANG = rst ? 0 : ~(0|U214Pad3|U216Pad7|U214Pad8);
assign U115Pad3 = rst ? 0 : ~(0|U114Pad9|U115Pad1);
assign U216Pad7 = rst ? 0 : ~(0|U219Pad8);
assign CHOR14_ = rst ? 0 : ~(0|CHBT14|CH3314|CHAT14|CH1114);
assign CHOR11_ = rst ? 0 : ~(0|CHAT11|CHBT11|CH1111|CH3311|CH1211);
assign U107Pad7 = rst ? 0 : ~(0|U109Pad1|U111Pad1);
assign U226Pad2 = rst ? 0 : ~(0|CCH13|U225Pad7);
assign U107Pad2 = rst ? 0 : ~(0|U107Pad7|U102Pad1|F09A_|U103Pad9);
assign U120Pad2 = rst ? 0 : ~(0|NKEY5|U121Pad3);
assign U207Pad7 = rst ? 0 : ~(0|U209Pad2);
assign U259Pad1 = rst ? 0 : ~(0|DLKRPT|U255Pad2|U256Pad2);
assign U207Pad2 = rst ? 0 : ~(0|U205Pad2|U204Pad3|U206Pad9);
assign U213Pad1 = rst ? 0 : ~(0|U213Pad2|U213Pad3);
assign TEMPIN_ = rst ? 0 : ~(0|TEMPIN);
assign U220Pad9 = rst ? 0 : ~(0|CNTOF9|GOJAM|U219Pad3);
assign U126Pad7 = rst ? 0 : ~(0|U127Pad2);
assign U112Pad1 = rst ? 0 : ~(0|U111Pad2|U103Pad9);
assign U126Pad8 = rst ? 0 : ~(0|U129Pad2);
assign U232Pad1 = rst ? 0 : ~(0|U229Pad2|U231Pad3);
assign RRSYNC = rst ? 0 : ~(0|U207Pad7|U205Pad2);
assign U131Pad3 = rst ? 0 : ~(0|U132Pad2|U131Pad9);
assign U210Pad9 = rst ? 0 : ~(0|U210Pad2|F09B|GOJAM);
assign U237Pad2 = rst ? 0 : ~(0|RADRPT|U237Pad1|U233Pad2|U239Pad3);
assign U237Pad3 = rst ? 0 : ~(0|U240Pad7|U237Pad2);
assign U131Pad9 = rst ? 0 : ~(0|WCH13_|CHWL11_);
assign U237Pad1 = rst ? 0 : ~(0|U237Pad2|U237Pad3);
assign U119Pad7 = rst ? 0 : ~(0|U120Pad2);
assign U113Pad8 = rst ? 0 : ~(0|CAURST|W1110);
assign U127Pad2 = rst ? 0 : ~(0|U128Pad1|NKEY2);
assign CH1504 = rst ? 0 : ~(0|U149Pad3|RCH15_);
assign CH1501 = rst ? 0 : ~(0|U143Pad2|RCH15_);
assign U119Pad8 = rst ? 0 : ~(0|U121Pad7);
assign KYRPT2 = rst ? 0 : ~(0|U116Pad6|F09B_|TPOR_);
assign CH1502 = rst ? 0 : ~(0|U145Pad3|RCH15_);
assign U153Pad1 = rst ? 0 : ~(0|U144Pad1|U146Pad1|U148Pad1|U150Pad1|U152Pad1);
assign TPOR_ = rst ? 0 : ~(0|T05|T11);
assign END = rst ? 0 : ~(0|U255Pad2);
assign U153Pad9 = rst ? 0 : ~(0|U143Pad3|F09A_|U153Pad1|U154Pad4);
assign U239Pad3 = rst ? 0 : ~(0|U233Pad2|U237Pad2|U240Pad4);
assign U116Pad2 = rst ? 0 : ~(0|U119Pad7|U119Pad8|U124Pad9|U126Pad7|U126Pad8);
assign TPORA_ = rst ? 0 : ~(0|HERB);
assign U157Pad4 = rst ? 0 : ~(0|U157Pad1|U153Pad9);
assign U116Pad6 = rst ? 0 : ~(0|U117Pad1|U117Pad8);
assign U149Pad3 = rst ? 0 : ~(0|U149Pad1|MKEY4);
assign U157Pad1 = rst ? 0 : ~(0|F09D|U153Pad1|U157Pad4);
assign U149Pad1 = rst ? 0 : ~(0|U143Pad3|U149Pad3);
assign U204Pad8 = rst ? 0 : ~(0|U207Pad2|U206Pad1);
assign RADRPT = rst ? 0 : ~(0|GTRST_|TPORA_|U210Pad2);
assign U130Pad1 = rst ? 0 : ~(0|U129Pad2|U118Pad1);
assign U114Pad8 = rst ? 0 : ~(0|NAVRST);
assign U114Pad9 = rst ? 0 : ~(0|U114Pad7|U114Pad8);
assign U202Pad1 = rst ? 0 : ~(0|LRIN0);
assign U138Pad2 = rst ? 0 : ~(0|U138Pad1|U133Pad9);
assign U138Pad1 = rst ? 0 : ~(0|U138Pad2|U137Pad1);
assign U246Pad9 = rst ? 0 : ~(0|U246Pad7|U246Pad8);
assign U128Pad1 = rst ? 0 : ~(0|U118Pad1|U127Pad2);
assign U114Pad7 = rst ? 0 : ~(0|U116Pad2);
assign U209Pad2 = rst ? 0 : ~(0|U211Pad7|F5ASB2_);
assign CHOR16_ = rst ? 0 : ~(0|CH1116|CH1216|CH3316);
assign U148Pad1 = rst ? 0 : ~(0|U147Pad3);
assign U144Pad1 = rst ? 0 : ~(0|U143Pad2);
assign CHOR13_ = rst ? 0 : ~(0|CH3313|CHBT13|CHAT13);
assign U233Pad2 = rst ? 0 : ~(0|U234Pad2|U233Pad1|RADRPT);
assign U233Pad1 = rst ? 0 : ~(0|U233Pad2|RADRPT|U221Pad8|U234Pad8);
assign RNRADP = rst ? 0 : ~(0|U204Pad8);
assign U141Pad1 = rst ? 0 : ~(0|STNDBY|U138Pad2);
assign RNRADM = rst ? 0 : ~(0|U201Pad1);
assign CNTOF9 = rst ? 0 : ~(0|U245Pad2|U246Pad7|U234Pad2|U240Pad7|F10A);
assign U123Pad7 = rst ? 0 : ~(0|U125Pad1|NKEY3);
assign U206Pad9 = rst ? 0 : ~(0|RRIN1);
assign U123Pad3 = rst ? 0 : ~(0|U118Pad1|U121Pad7);
assign LRSYNC = rst ? 0 : ~(0|U207Pad7|U204Pad2);
assign CH12 = rst ? 0 : ~(0|RCHG_|CHOR12_);
assign CH13 = rst ? 0 : ~(0|CHOR13_|RCHG_);
assign U231Pad3 = rst ? 0 : ~(0|U232Pad1|F10AS0);
assign CH11 = rst ? 0 : ~(0|RCHG_|CHOR11_);
assign CH16 = rst ? 0 : ~(0|CHOR16_|RCHG_);
assign CH14 = rst ? 0 : ~(0|CHOR14_|RCHG_);
assign U107Pad3 = rst ? 0 : ~(0|U105Pad6|U107Pad7|F09D);
assign SBYLIT = rst ? 0 : ~(0|U140Pad1);
assign U204Pad2 = rst ? 0 : ~(0|U226Pad2);
assign U204Pad3 = rst ? 0 : ~(0|U228Pad2);
assign U125Pad1 = rst ? 0 : ~(0|U118Pad1|U123Pad7);
assign U101Pad2 = rst ? 0 : ~(0|XT1_|XB6_);
assign U201Pad3 = rst ? 0 : ~(0|U205Pad2|U204Pad3|U205Pad4);
assign U101Pad1 = rst ? 0 : ~(0|U101Pad2);
assign U248Pad1 = rst ? 0 : ~(0|U242Pad9|U246Pad8|U248Pad4);
assign U146Pad1 = rst ? 0 : ~(0|U145Pad3);
assign STNDBY = rst ? 0 : ~(0|U141Pad1|U139Pad9);
assign U205Pad4 = rst ? 0 : ~(0|RRIN0);
assign U139Pad9 = rst ? 0 : ~(0|U138Pad2|U133Pad9);
assign HERB = rst ? 0 : ~(0|TPOR_);
assign LRXVEL = rst ? 0 : ~(0|U214Pad6|U214Pad3|U214Pad2);
assign U135Pad3 = rst ? 0 : ~(0|F17A_|U134Pad1);
assign U201Pad1 = rst ? 0 : ~(0|U201Pad2|U201Pad3);
assign F17B_ = rst ? 0 : ~(0|F17B);
assign U225Pad7 = rst ? 0 : ~(0|U226Pad2|U227Pad8);
assign U219Pad8 = rst ? 0 : ~(0|U213Pad2|U219Pad3|F5BSB2_);
assign U227Pad8 = rst ? 0 : ~(0|WCH13_|CHWL03_);
assign U211Pad7 = rst ? 0 : ~(0|U212Pad1|U212Pad8);
assign U201Pad2 = rst ? 0 : ~(0|U204Pad2|U204Pad3|U202Pad1);
assign MKRPT = rst ? 0 : ~(0|U105Pad6|TPOR_|F09B_);
assign U222Pad7 = rst ? 0 : ~(0|CHWL01_|WCH13_);
assign CH1311 = rst ? 0 : ~(0|RCH13_|U131Pad3);
assign U213Pad2 = rst ? 0 : ~(0|U225Pad7);
assign U213Pad3 = rst ? 0 : ~(0|U214Pad2|U214Pad3);
assign U154Pad4 = rst ? 0 : ~(0|U160Pad2|U158Pad1);
assign U134Pad8 = rst ? 0 : ~(0|U134Pad9|U135Pad3);
assign U134Pad9 = rst ? 0 : ~(0|U134Pad1|U134Pad8);
assign U145Pad3 = rst ? 0 : ~(0|U145Pad1|MKEY2);
assign STNDBY_ = rst ? 0 : ~(0|STNDBY);
assign U134Pad1 = rst ? 0 : ~(0|SBYBUT);
assign U154Pad9 = rst ? 0 : ~(0|MAINRS);
assign U158Pad3 = rst ? 0 : ~(0|U153Pad1);
assign ERRST = rst ? 0 : ~(0|U113Pad8);
assign U234Pad8 = rst ? 0 : ~(0|U235Pad1|U233Pad1|U221Pad8);
assign F17A_ = rst ? 0 : ~(0|F17A);
assign U246Pad8 = rst ? 0 : ~(0|RADRPT|U246Pad9|U242Pad9|U248Pad1);
assign U240Pad4 = rst ? 0 : ~(0|U240Pad7|U239Pad3);
assign U240Pad7 = rst ? 0 : ~(0|U239Pad3|U237Pad3);
assign U234Pad2 = rst ? 0 : ~(0|U233Pad1|U235Pad2);
assign U105Pad6 = rst ? 0 : ~(0|U107Pad2|U107Pad3);
assign U242Pad1 = rst ? 0 : ~(0|RADRPT|U242Pad9|U237Pad1|U242Pad3);
assign U110Pad1 = rst ? 0 : ~(0|U103Pad9|U109Pad2);
assign U248Pad4 = rst ? 0 : ~(0|U248Pad1|U249Pad3);
assign U151Pad1 = rst ? 0 : ~(0|U143Pad3|U151Pad3);
assign U147Pad1 = rst ? 0 : ~(0|U143Pad3|U147Pad3);
assign U151Pad3 = rst ? 0 : ~(0|U151Pad1|MKEY5);
assign U147Pad3 = rst ? 0 : ~(0|U147Pad1|MKEY3);
assign RCH16_ = rst ? 0 : ~(0|U101Pad2);
assign CH1303 = rst ? 0 : ~(0|U225Pad7|RCH13_);
assign CH1302 = rst ? 0 : ~(0|RCH13_|U214Pad7);
assign CH1301 = rst ? 0 : ~(0|RCH13_|U214Pad8);
assign U152Pad1 = rst ? 0 : ~(0|U151Pad3);
assign U105Pad3 = rst ? 0 : ~(0|U107Pad7);
assign U137Pad1 = rst ? 0 : ~(0|U133Pad9|U131Pad3|STOP);
assign U103Pad1 = rst ? 0 : ~(0|MRKRST);
assign U143Pad1 = rst ? 0 : ~(0|U143Pad2|U143Pad3);
assign U143Pad2 = rst ? 0 : ~(0|U143Pad1|MKEY1);
assign U143Pad3 = rst ? 0 : ~(0|U154Pad9);
assign U103Pad9 = rst ? 0 : ~(0|U103Pad1);
assign U155Pad9 = rst ? 0 : ~(0|XB5_|XT1_);
assign U249Pad3 = rst ? 0 : ~(0|U248Pad1|U246Pad7);
assign CH1606 = rst ? 0 : ~(0|U111Pad2|U101Pad1);
assign CH1607 = rst ? 0 : ~(0|U109Pad2|U101Pad1);
assign CH1604 = rst ? 0 : ~(0|U121Pad7|U101Pad1);
assign CH1605 = rst ? 0 : ~(0|U120Pad2|U101Pad1);
assign CH1602 = rst ? 0 : ~(0|U127Pad2|U101Pad1);
assign CH1603 = rst ? 0 : ~(0|U123Pad7|U101Pad1);
assign U132Pad2 = rst ? 0 : ~(0|U131Pad3|CCH13);
assign CH1601 = rst ? 0 : ~(0|U101Pad1|U129Pad2);
assign LRZVEL = rst ? 0 : ~(0|U214Pad7|U214Pad2|U214Pad6);
assign U210Pad2 = rst ? 0 : ~(0|U209Pad2|U210Pad9);
assign U246Pad7 = rst ? 0 : ~(0|U246Pad8|U249Pad3);
assign U214Pad3 = rst ? 0 : ~(0|CCH13|U214Pad7);
assign CHOR12_ = rst ? 0 : ~(0|CH1112|CH1212|CHAT12|CHBT12);
assign LRYVEL = rst ? 0 : ~(0|U214Pad8|U214Pad3|U214Pad6);
assign SBY = rst ? 0 : ~(0|STNDBY_);
assign CH3312 = rst ? 0 : ~(0|U258Pad1|RCH33_);
assign RCH15_ = rst ? 0 : ~(0|U155Pad9);
assign U242Pad9 = rst ? 0 : ~(0|U242Pad7|U242Pad1);
assign J1Pad146 = rst ? 0 : ~(0);
assign U145Pad1 = rst ? 0 : ~(0|U143Pad3|U145Pad3);
assign U242Pad3 = rst ? 0 : ~(0|U244Pad2|U242Pad1|U237Pad1);
assign CH1503 = rst ? 0 : ~(0|U147Pad3|RCH15_);
assign U228Pad2 = rst ? 0 : ~(0|U229Pad2|RADRPT|CCH13);
assign U214Pad8 = rst ? 0 : ~(0|U222Pad7|U214Pad2);
assign U205Pad2 = rst ? 0 : ~(0|U213Pad1);
assign U124Pad9 = rst ? 0 : ~(0|U123Pad7);
assign U214Pad2 = rst ? 0 : ~(0|U214Pad8|CCH13);
assign U217Pad2 = rst ? 0 : ~(0|CNTOF9);
assign U214Pad7 = rst ? 0 : ~(0|U214Pad3|U224Pad3);
assign U214Pad6 = rst ? 0 : ~(0|U218Pad8);
assign U256Pad2 = rst ? 0 : ~(0|U257Pad1|DLKRPT);

endmodule
