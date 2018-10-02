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

assign #0.2  U244Pad2 = rst ? 0 : ~(0|U242Pad3|U245Pad2);
assign #0.2  U121Pad7 = rst ? 0 : ~(0|NKEY4|U123Pad3);
assign #0.2  U121Pad3 = rst ? 0 : ~(0|U118Pad1|U120Pad2);
assign #0.2  U229Pad2 = rst ? 0 : ~(0|U230Pad2|U228Pad2);
assign #0.2  U257Pad1 = rst ? 0 : ~(0|F10A|U256Pad2);
assign #0.2  F10AS0 = rst ? 0 : ~(0|F10A_|SB0_);
assign #0.2  U230Pad2 = rst ? 0 : ~(0|WCH13_|CHWL04_);
assign #0.2  RRRARA = rst ? 0 : ~(0|U216Pad7|U214Pad7|U214Pad2);
assign #0.2  U140Pad1 = rst ? 0 : ~(0|ALTEST|STNDBY);
assign #0.2  J2Pad270 = rst ? 0 : ~(0);
assign #0.2  CH1304 = rst ? 0 : ~(0|RCH13_|U229Pad2);
assign #0.2  U111Pad1 = rst ? 0 : ~(0|U111Pad2);
assign #0.2  U111Pad2 = rst ? 0 : ~(0|MARK|U112Pad1);
assign #0.2  U258Pad3 = rst ? 0 : ~(0|U259Pad1|U258Pad1);
assign #0.2  U258Pad1 = rst ? 0 : ~(0|CCH33|U258Pad3);
assign #0.2  U158Pad1 = rst ? 0 : ~(0|U154Pad9|U158Pad3);
assign #0.2  U212Pad8 = rst ? 0 : ~(0|U217Pad2|GTSET_);
assign #0.2  U206Pad1 = rst ? 0 : ~(0|U204Pad2|U204Pad3|U203Pad9);
assign #0.2  U160Pad2 = rst ? 0 : ~(0|KYRPT1|U154Pad4);
assign #0.2  U212Pad1 = rst ? 0 : ~(0|RADRPT|GOJAM|U211Pad7);
assign #0.2  U203Pad9 = rst ? 0 : ~(0|LRIN1);
assign #0.2  U129Pad2 = rst ? 0 : ~(0|U130Pad1|NKEY1);
assign #0.2  U219Pad3 = rst ? 0 : ~(0|U220Pad9|U221Pad8);
assign #0.2  U242Pad7 = rst ? 0 : ~(0|U245Pad2|U242Pad1);
assign #0.2  LRRANG = rst ? 0 : ~(0|U214Pad6|U214Pad7|U214Pad8);
assign #0.2  U245Pad2 = rst ? 0 : ~(0|U242Pad3|U242Pad7);
assign #0.2  U256Pad1 = rst ? 0 : ~(0|U256Pad2|DLKRPT);
assign #0.2  U133Pad7 = rst ? 0 : ~(0|U133Pad9|U134Pad1);
assign #0.2  DLKRPT = rst ? 0 : ~(0|U256Pad1|U255Pad2);
assign #0.2  J4Pad471 = rst ? 0 : ~(0);
assign #0.2  U133Pad9 = rst ? 0 : ~(0|U133Pad7|U133Pad8);
assign #0.2  U133Pad8 = rst ? 0 : ~(0|U134Pad8|F17B_);
assign #0.2  CH1505 = rst ? 0 : ~(0|U151Pad3|RCH15_);
assign #0.2  U109Pad1 = rst ? 0 : ~(0|U109Pad2);
assign #0.2  U235Pad1 = rst ? 0 : ~(0|U235Pad2|U234Pad8);
assign #0.2  U235Pad2 = rst ? 0 : ~(0|U234Pad2|U234Pad8);
assign #0.2  U109Pad2 = rst ? 0 : ~(0|U110Pad1|MRKREJ);
assign #0.2  U150Pad1 = rst ? 0 : ~(0|U149Pad3);
assign #0.2  U117Pad8 = rst ? 0 : ~(0|F09A_|U115Pad3|U116Pad2|U118Pad1);
assign #0.2  U115Pad1 = rst ? 0 : ~(0|KYRPT2|U115Pad3);
assign #0.2  U117Pad1 = rst ? 0 : ~(0|F09D|U116Pad2|U116Pad6);
assign #0.2  U221Pad8 = rst ? 0 : ~(0|SB2_|U231Pad3|F10A_);
assign #0.2  U224Pad3 = rst ? 0 : ~(0|WCH13_|CHWL02_);
assign #0.2  KYRPT1 = rst ? 0 : ~(0|U157Pad4|TPOR_|F09B_);
assign #0.2  U102Pad1 = rst ? 0 : ~(0|U102Pad2|U102Pad3);
assign #0.2  U218Pad8 = rst ? 0 : ~(0|U204Pad2|U219Pad3|F5BSB2_);
assign #0.2  U102Pad3 = rst ? 0 : ~(0|U103Pad1|U105Pad3);
assign #0.2  U102Pad2 = rst ? 0 : ~(0|U102Pad1|MKRPT);
assign #0.2  U255Pad2 = rst ? 0 : ~(0|DKEND);
assign #0.2  U118Pad1 = rst ? 0 : ~(0|U114Pad8);
assign #0.2  RRRANG = rst ? 0 : ~(0|U214Pad3|U216Pad7|U214Pad8);
assign #0.2  U115Pad3 = rst ? 0 : ~(0|U114Pad9|U115Pad1);
assign #0.2  U216Pad7 = rst ? 0 : ~(0|U219Pad8);
assign #0.2  CHOR14_ = rst ? 0 : ~(0|CHBT14|CH3314|CHAT14|CH1114);
assign #0.2  CHOR11_ = rst ? 0 : ~(0|CHAT11|CHBT11|CH1111|CH3311|CH1211);
assign #0.2  U107Pad7 = rst ? 0 : ~(0|U109Pad1|U111Pad1);
assign #0.2  U226Pad2 = rst ? 0 : ~(0|CCH13|U225Pad7);
assign #0.2  U107Pad2 = rst ? 0 : ~(0|U107Pad7|U102Pad1|F09A_|U103Pad9);
assign #0.2  U120Pad2 = rst ? 0 : ~(0|NKEY5|U121Pad3);
assign #0.2  U207Pad7 = rst ? 0 : ~(0|U209Pad2);
assign #0.2  U259Pad1 = rst ? 0 : ~(0|DLKRPT|U255Pad2|U256Pad2);
assign #0.2  U207Pad2 = rst ? 0 : ~(0|U205Pad2|U204Pad3|U206Pad9);
assign #0.2  U213Pad1 = rst ? 0 : ~(0|U213Pad2|U213Pad3);
assign #0.2  TEMPIN_ = rst ? 0 : ~(0|TEMPIN);
assign #0.2  U220Pad9 = rst ? 0 : ~(0|CNTOF9|GOJAM|U219Pad3);
assign #0.2  U126Pad7 = rst ? 0 : ~(0|U127Pad2);
assign #0.2  U112Pad1 = rst ? 0 : ~(0|U111Pad2|U103Pad9);
assign #0.2  U126Pad8 = rst ? 0 : ~(0|U129Pad2);
assign #0.2  U232Pad1 = rst ? 0 : ~(0|U229Pad2|U231Pad3);
assign #0.2  RRSYNC = rst ? 0 : ~(0|U207Pad7|U205Pad2);
assign #0.2  U131Pad3 = rst ? 0 : ~(0|U132Pad2|U131Pad9);
assign #0.2  U210Pad9 = rst ? 0 : ~(0|U210Pad2|F09B|GOJAM);
assign #0.2  U237Pad2 = rst ? 0 : ~(0|RADRPT|U237Pad1|U233Pad2|U239Pad3);
assign #0.2  U237Pad3 = rst ? 0 : ~(0|U240Pad7|U237Pad2);
assign #0.2  U131Pad9 = rst ? 0 : ~(0|WCH13_|CHWL11_);
assign #0.2  U237Pad1 = rst ? 0 : ~(0|U237Pad2|U237Pad3);
assign #0.2  U119Pad7 = rst ? 0 : ~(0|U120Pad2);
assign #0.2  U113Pad8 = rst ? 0 : ~(0|CAURST|W1110);
assign #0.2  U127Pad2 = rst ? 0 : ~(0|U128Pad1|NKEY2);
assign #0.2  CH1504 = rst ? 0 : ~(0|U149Pad3|RCH15_);
assign #0.2  CH1501 = rst ? 0 : ~(0|U143Pad2|RCH15_);
assign #0.2  U119Pad8 = rst ? 0 : ~(0|U121Pad7);
assign #0.2  KYRPT2 = rst ? 0 : ~(0|U116Pad6|F09B_|TPOR_);
assign #0.2  CH1502 = rst ? 0 : ~(0|U145Pad3|RCH15_);
assign #0.2  U153Pad1 = rst ? 0 : ~(0|U144Pad1|U146Pad1|U148Pad1|U150Pad1|U152Pad1);
assign #0.2  TPOR_ = rst ? 0 : ~(0|T05|T11);
assign #0.2  END = rst ? 0 : ~(0|U255Pad2);
assign #0.2  U153Pad9 = rst ? 0 : ~(0|U143Pad3|F09A_|U153Pad1|U154Pad4);
assign #0.2  U239Pad3 = rst ? 0 : ~(0|U233Pad2|U237Pad2|U240Pad4);
assign #0.2  U116Pad2 = rst ? 0 : ~(0|U119Pad7|U119Pad8|U124Pad9|U126Pad7|U126Pad8);
assign #0.2  TPORA_ = rst ? 0 : ~(0|HERB);
assign #0.2  U157Pad4 = rst ? 0 : ~(0|U157Pad1|U153Pad9);
assign #0.2  U116Pad6 = rst ? 0 : ~(0|U117Pad1|U117Pad8);
assign #0.2  U149Pad3 = rst ? 0 : ~(0|U149Pad1|MKEY4);
assign #0.2  U157Pad1 = rst ? 0 : ~(0|F09D|U153Pad1|U157Pad4);
assign #0.2  U149Pad1 = rst ? 0 : ~(0|U143Pad3|U149Pad3);
assign #0.2  U204Pad8 = rst ? 0 : ~(0|U207Pad2|U206Pad1);
assign #0.2  RADRPT = rst ? 0 : ~(0|GTRST_|TPORA_|U210Pad2);
assign #0.2  U130Pad1 = rst ? 0 : ~(0|U129Pad2|U118Pad1);
assign #0.2  U114Pad8 = rst ? 0 : ~(0|NAVRST);
assign #0.2  U114Pad9 = rst ? 0 : ~(0|U114Pad7|U114Pad8);
assign #0.2  U202Pad1 = rst ? 0 : ~(0|LRIN0);
assign #0.2  U138Pad2 = rst ? 0 : ~(0|U138Pad1|U133Pad9);
assign #0.2  U138Pad1 = rst ? 0 : ~(0|U138Pad2|U137Pad1);
assign #0.2  U246Pad9 = rst ? 0 : ~(0|U246Pad7|U246Pad8);
assign #0.2  U128Pad1 = rst ? 0 : ~(0|U118Pad1|U127Pad2);
assign #0.2  U114Pad7 = rst ? 0 : ~(0|U116Pad2);
assign #0.2  U209Pad2 = rst ? 0 : ~(0|U211Pad7|F5ASB2_);
assign #0.2  CHOR16_ = rst ? 0 : ~(0|CH1116|CH1216|CH3316);
assign #0.2  U148Pad1 = rst ? 0 : ~(0|U147Pad3);
assign #0.2  U144Pad1 = rst ? 0 : ~(0|U143Pad2);
assign #0.2  CHOR13_ = rst ? 0 : ~(0|CH3313|CHBT13|CHAT13);
assign #0.2  U233Pad2 = rst ? 0 : ~(0|U234Pad2|U233Pad1|RADRPT);
assign #0.2  U233Pad1 = rst ? 0 : ~(0|U233Pad2|RADRPT|U221Pad8|U234Pad8);
assign #0.2  RNRADP = rst ? 0 : ~(0|U204Pad8);
assign #0.2  U141Pad1 = rst ? 0 : ~(0|STNDBY|U138Pad2);
assign #0.2  RNRADM = rst ? 0 : ~(0|U201Pad1);
assign #0.2  CNTOF9 = rst ? 0 : ~(0|U245Pad2|U246Pad7|U234Pad2|U240Pad7|F10A);
assign #0.2  U123Pad7 = rst ? 0 : ~(0|U125Pad1|NKEY3);
assign #0.2  U206Pad9 = rst ? 0 : ~(0|RRIN1);
assign #0.2  U123Pad3 = rst ? 0 : ~(0|U118Pad1|U121Pad7);
assign #0.2  LRSYNC = rst ? 0 : ~(0|U207Pad7|U204Pad2);
assign #0.2  CH12 = rst ? 0 : ~(0|RCHG_|CHOR12_);
assign #0.2  CH13 = rst ? 0 : ~(0|CHOR13_|RCHG_);
assign #0.2  U231Pad3 = rst ? 0 : ~(0|U232Pad1|F10AS0);
assign #0.2  CH11 = rst ? 0 : ~(0|RCHG_|CHOR11_);
assign #0.2  CH16 = rst ? 0 : ~(0|CHOR16_|RCHG_);
assign #0.2  CH14 = rst ? 0 : ~(0|CHOR14_|RCHG_);
assign #0.2  U107Pad3 = rst ? 0 : ~(0|U105Pad6|U107Pad7|F09D);
assign #0.2  SBYLIT = rst ? 0 : ~(0|U140Pad1);
assign #0.2  U204Pad2 = rst ? 0 : ~(0|U226Pad2);
assign #0.2  U204Pad3 = rst ? 0 : ~(0|U228Pad2);
assign #0.2  U125Pad1 = rst ? 0 : ~(0|U118Pad1|U123Pad7);
assign #0.2  U101Pad2 = rst ? 0 : ~(0|XT1_|XB6_);
assign #0.2  U201Pad3 = rst ? 0 : ~(0|U205Pad2|U204Pad3|U205Pad4);
assign #0.2  U101Pad1 = rst ? 0 : ~(0|U101Pad2);
assign #0.2  U248Pad1 = rst ? 0 : ~(0|U242Pad9|U246Pad8|U248Pad4);
assign #0.2  U146Pad1 = rst ? 0 : ~(0|U145Pad3);
assign #0.2  STNDBY = rst ? 0 : ~(0|U141Pad1|U139Pad9);
assign #0.2  U205Pad4 = rst ? 0 : ~(0|RRIN0);
assign #0.2  U139Pad9 = rst ? 0 : ~(0|U138Pad2|U133Pad9);
assign #0.2  HERB = rst ? 0 : ~(0|TPOR_);
assign #0.2  LRXVEL = rst ? 0 : ~(0|U214Pad6|U214Pad3|U214Pad2);
assign #0.2  U135Pad3 = rst ? 0 : ~(0|F17A_|U134Pad1);
assign #0.2  U201Pad1 = rst ? 0 : ~(0|U201Pad2|U201Pad3);
assign #0.2  F17B_ = rst ? 0 : ~(0|F17B);
assign #0.2  U225Pad7 = rst ? 0 : ~(0|U226Pad2|U227Pad8);
assign #0.2  U219Pad8 = rst ? 0 : ~(0|U213Pad2|U219Pad3|F5BSB2_);
assign #0.2  U227Pad8 = rst ? 0 : ~(0|WCH13_|CHWL03_);
assign #0.2  U211Pad7 = rst ? 0 : ~(0|U212Pad1|U212Pad8);
assign #0.2  U201Pad2 = rst ? 0 : ~(0|U204Pad2|U204Pad3|U202Pad1);
assign #0.2  MKRPT = rst ? 0 : ~(0|U105Pad6|TPOR_|F09B_);
assign #0.2  U222Pad7 = rst ? 0 : ~(0|CHWL01_|WCH13_);
assign #0.2  CH1311 = rst ? 0 : ~(0|RCH13_|U131Pad3);
assign #0.2  U213Pad2 = rst ? 0 : ~(0|U225Pad7);
assign #0.2  U213Pad3 = rst ? 0 : ~(0|U214Pad2|U214Pad3);
assign #0.2  U154Pad4 = rst ? 0 : ~(0|U160Pad2|U158Pad1);
assign #0.2  U134Pad8 = rst ? 0 : ~(0|U134Pad9|U135Pad3);
assign #0.2  U134Pad9 = rst ? 0 : ~(0|U134Pad1|U134Pad8);
assign #0.2  U145Pad3 = rst ? 0 : ~(0|U145Pad1|MKEY2);
assign #0.2  STNDBY_ = rst ? 0 : ~(0|STNDBY);
assign #0.2  U134Pad1 = rst ? 0 : ~(0|SBYBUT);
assign #0.2  U154Pad9 = rst ? 0 : ~(0|MAINRS);
assign #0.2  U158Pad3 = rst ? 0 : ~(0|U153Pad1);
assign #0.2  ERRST = rst ? 0 : ~(0|U113Pad8);
assign #0.2  U234Pad8 = rst ? 0 : ~(0|U235Pad1|U233Pad1|U221Pad8);
assign #0.2  F17A_ = rst ? 0 : ~(0|F17A);
assign #0.2  U246Pad8 = rst ? 0 : ~(0|RADRPT|U246Pad9|U242Pad9|U248Pad1);
assign #0.2  U240Pad4 = rst ? 0 : ~(0|U240Pad7|U239Pad3);
assign #0.2  U240Pad7 = rst ? 0 : ~(0|U239Pad3|U237Pad3);
assign #0.2  U234Pad2 = rst ? 0 : ~(0|U233Pad1|U235Pad2);
assign #0.2  U105Pad6 = rst ? 0 : ~(0|U107Pad2|U107Pad3);
assign #0.2  U242Pad1 = rst ? 0 : ~(0|RADRPT|U242Pad9|U237Pad1|U242Pad3);
assign #0.2  U110Pad1 = rst ? 0 : ~(0|U103Pad9|U109Pad2);
assign #0.2  U248Pad4 = rst ? 0 : ~(0|U248Pad1|U249Pad3);
assign #0.2  U151Pad1 = rst ? 0 : ~(0|U143Pad3|U151Pad3);
assign #0.2  U147Pad1 = rst ? 0 : ~(0|U143Pad3|U147Pad3);
assign #0.2  U151Pad3 = rst ? 0 : ~(0|U151Pad1|MKEY5);
assign #0.2  U147Pad3 = rst ? 0 : ~(0|U147Pad1|MKEY3);
assign #0.2  RCH16_ = rst ? 0 : ~(0|U101Pad2);
assign #0.2  CH1303 = rst ? 0 : ~(0|U225Pad7|RCH13_);
assign #0.2  CH1302 = rst ? 0 : ~(0|RCH13_|U214Pad7);
assign #0.2  CH1301 = rst ? 0 : ~(0|RCH13_|U214Pad8);
assign #0.2  U152Pad1 = rst ? 0 : ~(0|U151Pad3);
assign #0.2  U105Pad3 = rst ? 0 : ~(0|U107Pad7);
assign #0.2  U137Pad1 = rst ? 0 : ~(0|U133Pad9|U131Pad3|STOP);
assign #0.2  U103Pad1 = rst ? 0 : ~(0|MRKRST);
assign #0.2  U143Pad1 = rst ? 0 : ~(0|U143Pad2|U143Pad3);
assign #0.2  U143Pad2 = rst ? 0 : ~(0|U143Pad1|MKEY1);
assign #0.2  U143Pad3 = rst ? 0 : ~(0|U154Pad9);
assign #0.2  U103Pad9 = rst ? 0 : ~(0|U103Pad1);
assign #0.2  U155Pad9 = rst ? 0 : ~(0|XB5_|XT1_);
assign #0.2  U249Pad3 = rst ? 0 : ~(0|U248Pad1|U246Pad7);
assign #0.2  CH1606 = rst ? 0 : ~(0|U111Pad2|U101Pad1);
assign #0.2  CH1607 = rst ? 0 : ~(0|U109Pad2|U101Pad1);
assign #0.2  CH1604 = rst ? 0 : ~(0|U121Pad7|U101Pad1);
assign #0.2  CH1605 = rst ? 0 : ~(0|U120Pad2|U101Pad1);
assign #0.2  CH1602 = rst ? 0 : ~(0|U127Pad2|U101Pad1);
assign #0.2  CH1603 = rst ? 0 : ~(0|U123Pad7|U101Pad1);
assign #0.2  U132Pad2 = rst ? 0 : ~(0|U131Pad3|CCH13);
assign #0.2  CH1601 = rst ? 0 : ~(0|U101Pad1|U129Pad2);
assign #0.2  LRZVEL = rst ? 0 : ~(0|U214Pad7|U214Pad2|U214Pad6);
assign #0.2  U210Pad2 = rst ? 0 : ~(0|U209Pad2|U210Pad9);
assign #0.2  U246Pad7 = rst ? 0 : ~(0|U246Pad8|U249Pad3);
assign #0.2  U214Pad3 = rst ? 0 : ~(0|CCH13|U214Pad7);
assign #0.2  CHOR12_ = rst ? 0 : ~(0|CH1112|CH1212|CHAT12|CHBT12);
assign #0.2  LRYVEL = rst ? 0 : ~(0|U214Pad8|U214Pad3|U214Pad6);
assign #0.2  SBY = rst ? 0 : ~(0|STNDBY_);
assign #0.2  CH3312 = rst ? 0 : ~(0|U258Pad1|RCH33_);
assign #0.2  RCH15_ = rst ? 0 : ~(0|U155Pad9);
assign #0.2  U242Pad9 = rst ? 0 : ~(0|U242Pad7|U242Pad1);
assign #0.2  J1Pad146 = rst ? 0 : ~(0);
assign #0.2  U145Pad1 = rst ? 0 : ~(0|U143Pad3|U145Pad3);
assign #0.2  U242Pad3 = rst ? 0 : ~(0|U244Pad2|U242Pad1|U237Pad1);
assign #0.2  CH1503 = rst ? 0 : ~(0|U147Pad3|RCH15_);
assign #0.2  U228Pad2 = rst ? 0 : ~(0|U229Pad2|RADRPT|CCH13);
assign #0.2  U214Pad8 = rst ? 0 : ~(0|U222Pad7|U214Pad2);
assign #0.2  U205Pad2 = rst ? 0 : ~(0|U213Pad1);
assign #0.2  U124Pad9 = rst ? 0 : ~(0|U123Pad7);
assign #0.2  U214Pad2 = rst ? 0 : ~(0|U214Pad8|CCH13);
assign #0.2  U217Pad2 = rst ? 0 : ~(0|CNTOF9);
assign #0.2  U214Pad7 = rst ? 0 : ~(0|U214Pad3|U224Pad3);
assign #0.2  U214Pad6 = rst ? 0 : ~(0|U218Pad8);
assign #0.2  U256Pad2 = rst ? 0 : ~(0|U257Pad1|DLKRPT);

endmodule
