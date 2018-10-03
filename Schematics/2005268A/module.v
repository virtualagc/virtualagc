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

// Gate A18-U241A
assign #0.2  A18U237Pad3 = rst ? 1 : ~(0|A18U240Pad7|A18U237Pad2);
// Gate A18-U238A A18-U239A
assign #0.2  A18U237Pad2 = rst ? 0 : ~(0|RADRPT|A18U237Pad1|A18U233Pad2|A18U239Pad3);
// Gate A18-U237A
assign #0.2  A18U237Pad1 = rst ? 0 : ~(0|A18U237Pad2|A18U237Pad3);
// Gate A18-U205A
assign #0.2  A18U201Pad3 = rst ? 0 : ~(0|A18U205Pad2|A18U204Pad3|A18U205Pad4);
// Gate A18-U231A
assign #0.2  A18U221Pad8 = rst ? 0 : ~(0|SB2_|A18U231Pad3|F10A_);
// Gate A18-U136B
assign #0.2  A18U133Pad8 = rst ? 0 : ~(0|A18U134Pad8|F17B_);
// Gate A18-U133B
assign #0.2  A18U133Pad9 = rst ? 1 : ~(0|A18U133Pad7|A18U133Pad8);
// Gate A18-U131B
assign #0.2  A18U131Pad9 = rst ? 0 : ~(0|WCH13_|CHWL11_);
// Gate A18-U150A
assign #0.2  A18U150Pad1 = rst ? 1 : ~(0|A18U149Pad3);
// Gate A18-U244A
assign #0.2  A18U242Pad3 = rst ? 1 : ~(0|A18U244Pad2|A18U242Pad1|A18U237Pad1);
// Gate A18-U205B
assign #0.2  A18U205Pad4 = rst ? 1 : ~(0|RRIN0);
// Gate A18-U132A
assign #0.2  A18U131Pad3 = rst ? 1 : ~(0|A18U132Pad2|A18U131Pad9);
// Gate A18-U213B
assign #0.2  A18U205Pad2 = rst ? 1 : ~(0|A18U213Pad1);
// Gate A18-U136A
assign #0.2  A18U133Pad7 = rst ? 0 : ~(0|A18U133Pad9|A18U134Pad1);
// Gate A18-U245A
assign #0.2  A18U242Pad7 = rst ? 1 : ~(0|A18U245Pad2|A18U242Pad1);
// Gate A18-U211B
assign #0.2  A18U209Pad2 = rst ? 0 : ~(0|A18U211Pad7|F5ASB2_);
// Gate A18-U219B
assign #0.2  A18U216Pad7 = rst ? 1 : ~(0|A18U219Pad8);
// Gate A18-U236A
assign #0.2  A18U234Pad2 = rst ? 1 : ~(0|A18U233Pad1|A18U235Pad2);
// Gate A18-U243B
assign #0.2  CHOR13_ = rst ? 1 : ~(0|CH3313|CHBT13|CHAT13);
// Gate A18-U243A A18-U242A
assign #0.2  A18U242Pad1 = rst ? 0 : ~(0|RADRPT|A18U242Pad9|A18U237Pad1|A18U242Pad3);
// Gate A18-U121A
assign #0.2  A18U120Pad2 = rst ? 1 : ~(0|NKEY5|A18U121Pad3);
// Gate A18-U223B
assign #0.2  A18U222Pad7 = rst ? 0 : ~(0|CHWL01_|WCH13_);
// Gate A18-U149B
assign #0.2  A18U149Pad3 = rst ? 0 : ~(0|A18U149Pad1|MKEY4);
// Gate A18-U149A
assign #0.2  A18U149Pad1 = rst ? 1 : ~(0|A18U143Pad3|A18U149Pad3);
// Gate A18-U240B
assign #0.2  A18U240Pad4 = rst ? 0 : ~(0|A18U240Pad7|A18U239Pad3);
// Gate A18-U241B
assign #0.2  A18U240Pad7 = rst ? 0 : ~(0|A18U239Pad3|A18U237Pad3);
// Gate A18-U228B
assign #0.2  A18U227Pad8 = rst ? 0 : ~(0|WCH13_|CHWL03_);
// Gate A18-U151A
assign #0.2  A18U151Pad1 = rst ? 0 : ~(0|A18U143Pad3|A18U151Pad3);
// Gate A18-U151B
assign #0.2  A18U151Pad3 = rst ? 1 : ~(0|A18U151Pad1|MKEY5);
// Gate A18-U111A
assign #0.2  A18U111Pad1 = rst ? 0 : ~(0|A18U111Pad2);
// Gate A18-U113A
assign #0.2  A18U111Pad2 = rst ? 1 : ~(0|MARK|A18U112Pad1);
// Gate A18-U114B
assign #0.2  A18U114Pad9 = rst ? 0 : ~(0|A18U114Pad7|A18U114Pad8);
// Gate A18-U118B
assign #0.2  A18U114Pad8 = rst ? 1 : ~(0|NAVRST);
// Gate A18-U122A
assign #0.2  A18U121Pad3 = rst ? 0 : ~(0|A18U118Pad1|A18U120Pad2);
// Gate A18-U230A
assign #0.2  A18U229Pad2 = rst ? 1 : ~(0|A18U230Pad2|A18U228Pad2);
// Gate A18-U256B
assign #0.2  DLKRPT = rst ? 0 : ~(0|A18U256Pad1|A18U255Pad2);
// Gate A18-U116A
assign #0.2  A18U114Pad7 = rst ? 1 : ~(0|A18U116Pad2);
// Gate A18-U218A
assign #0.2  A18U217Pad2 = rst ? 1 : ~(0|CNTOF9);
// Gate A18-U260B
assign #0.2  A18U258Pad3 = rst ? 0 : ~(0|A18U259Pad1|A18U258Pad1);
// Gate A18-U258A
assign #0.2  A18U258Pad1 = rst ? 1 : ~(0|CCH33|A18U258Pad3);
// Gate A18-U124B
assign #0.2  A18U124Pad9 = rst ? 0 : ~(0|A18U123Pad7);
// Gate A18-U224B
assign #0.2  A18U224Pad3 = rst ? 0 : ~(0|WCH13_|CHWL02_);
// Gate A18-U115A
assign #0.2  A18U115Pad1 = rst ? 1 : ~(0|KYRPT2|A18U115Pad3);
// Gate A18-U115B
assign #0.2  A18U115Pad3 = rst ? 0 : ~(0|A18U114Pad9|A18U115Pad1);
// Gate A18-U154B
assign #0.2  A18U154Pad9 = rst ? 1 : ~(0|MAINRS);
// Gate A18-U139B
assign #0.2  A18U139Pad9 = rst ? 0 : ~(0|A18U138Pad2|A18U133Pad9);
// Gate A18-U141A
assign #0.2  A18U141Pad1 = rst ? 0 : ~(0|STNDBY|A18U138Pad2);
// Gate A18-U231B
assign #0.2  F10AS0 = rst ? 0 : ~(0|F10A_|SB0_);
// Gate A18-U144B
assign #0.2  CH1501 = rst ? 0 : ~(0|A18U143Pad2|RCH15_);
// Gate A18-U220A
assign #0.2  A18U219Pad8 = rst ? 0 : ~(0|A18U213Pad2|A18U219Pad3|F5BSB2_);
// Gate A18-U148B
assign #0.2  CH1503 = rst ? 0 : ~(0|A18U147Pad3|RCH15_);
// Gate A18-U228A
assign #0.2  A18U204Pad3 = rst ? 1 : ~(0|A18U228Pad2);
// Gate A18-U148A
assign #0.2  A18U148Pad1 = rst ? 1 : ~(0|A18U147Pad3);
// Gate A18-U216B
assign #0.2  RRRANG = rst ? 0 : ~(0|A18U214Pad3|A18U216Pad7|A18U214Pad8);
// Gate A18-U207A
assign #0.2  A18U204Pad8 = rst ? 1 : ~(0|A18U207Pad2|A18U206Pad1);
// Gate A18-U206A
assign #0.2  A18U206Pad1 = rst ? 0 : ~(0|A18U204Pad2|A18U204Pad3|A18U203Pad9);
// Gate A18-U238B A18-U247B
assign #0.2  CHOR14_ = rst ? 1 : ~(0|CHBT14|CH3314|CHAT14|CH1114);
// Gate A18-U250B A18-U252A
assign #0.2  CHOR11_ = rst ? 1 : ~(0|CHAT11|CHBT11|CH1111|CH3311|CH1211);
// Gate A18-U102A
assign #0.2  A18U102Pad1 = rst ? 1 : ~(0|A18U102Pad2|A18U102Pad3);
// Gate A18-U104B
assign #0.2  A18U102Pad2 = rst ? 0 : ~(0|A18U102Pad1|MKRPT);
// Gate A18-U105A
assign #0.2  A18U102Pad3 = rst ? 0 : ~(0|A18U103Pad1|A18U105Pad3);
// Gate A18-U111B
assign #0.2  A18U107Pad7 = rst ? 1 : ~(0|A18U109Pad1|A18U111Pad1);
// Gate A18-U107B
assign #0.2  A18U107Pad3 = rst ? 0 : ~(0|A18U105Pad6|A18U107Pad7|F09D);
// Gate A18-U108B A18-U142A
assign #0.2  A18U107Pad2 = rst ? 0 : ~(0|A18U107Pad7|A18U102Pad1|F09A_|A18U103Pad9);
// Gate A18-U106B
assign #0.2  TEMPIN_ = rst ? 1 : ~(0|TEMPIN);
// Gate A18-U138A
assign #0.2  A18U138Pad1 = rst ? 1 : ~(0|A18U138Pad2|A18U137Pad1);
// Gate A18-U203B
assign #0.2  A18U203Pad9 = rst ? 1 : ~(0|LRIN1);
// Gate A18-U139A
assign #0.2  STNDBY_ = rst ? 0 : ~(0|STNDBY);
// Gate A18-U208B
assign #0.2  LRSYNC = rst ? 0 : ~(0|A18U207Pad7|A18U204Pad2);
// Gate A18-U207B
assign #0.2  RRSYNC = rst ? 0 : ~(0|A18U207Pad7|A18U205Pad2);
// Gate A18-U256A
assign #0.2  A18U256Pad1 = rst ? 0 : ~(0|A18U256Pad2|DLKRPT);
// Gate A18-U145B
assign #0.2  A18U145Pad3 = rst ? 0 : ~(0|A18U145Pad1|MKEY2);
// Gate A18-U145A
assign #0.2  A18U145Pad1 = rst ? 1 : ~(0|A18U143Pad3|A18U145Pad3);
// Gate A18-U142B
assign #0.2  A18J1Pad146 = rst ? 1 : ~(0);
// Gate A18-U217B
assign #0.2  RRRARA = rst ? 0 : ~(0|A18U216Pad7|A18U214Pad7|A18U214Pad2);
// Gate A18-U227A
assign #0.2  A18U226Pad2 = rst ? 0 : ~(0|CCH13|A18U225Pad7);
// Gate A18-U246A
assign #0.2  A18U245Pad2 = rst ? 0 : ~(0|A18U242Pad3|A18U242Pad7);
// Gate A18-U201A
assign #0.2  A18U201Pad1 = rst ? 1 : ~(0|A18U201Pad2|A18U201Pad3);
// Gate A18-U152B
assign #0.2  CH1505 = rst ? 0 : ~(0|A18U151Pad3|RCH15_);
// Gate A18-U150B
assign #0.2  CH1504 = rst ? 0 : ~(0|A18U149Pad3|RCH15_);
// Gate A18-U106A
assign #0.2  F17B_ = rst ? 1 : ~(0|F17B);
// Gate A18-U159B
assign #0.2  KYRPT1 = rst ? 0 : ~(0|A18U157Pad4|TPOR_|F09B_);
// Gate A18-U116B
assign #0.2  KYRPT2 = rst ? 0 : ~(0|A18U116Pad6|F09B_|TPOR_);
// Gate A18-U146B
assign #0.2  CH1502 = rst ? 0 : ~(0|A18U145Pad3|RCH15_);
// Gate A18-U158B
assign #0.2  TPOR_ = rst ? 1 : ~(0|T05|T11);
// Gate A18-U255A
assign #0.2  END = rst ? 0 : ~(0|A18U255Pad2);
// Gate A18-U206B
assign #0.2  A18U206Pad9 = rst ? 1 : ~(0|RRIN1);
// Gate A18-U244B
assign #0.2  CH13 = rst ? 0 : ~(0|CHOR13_|RCHG_);
// Gate A18-U229A
assign #0.2  A18U228Pad2 = rst ? 0 : ~(0|A18U229Pad2|RADRPT|CCH13);
// Gate A18-U220B
assign #0.2  A18U220Pad9 = rst ? 0 : ~(0|CNTOF9|GOJAM|A18U219Pad3);
// Gate A18-U226A
assign #0.2  A18U204Pad2 = rst ? 1 : ~(0|A18U226Pad2);
// Gate A18-U201B
assign #0.2  TPORA_ = rst ? 1 : ~(0|HERB);
// Gate A18-U104A
assign #0.2  A18J2Pad270 = rst ? 1 : ~(0);
// Gate A18-U249B
assign #0.2  A18U246Pad7 = rst ? 1 : ~(0|A18U246Pad8|A18U249Pad3);
// Gate A18-U232A
assign #0.2  A18U232Pad1 = rst ? 0 : ~(0|A18U229Pad2|A18U231Pad3);
// Gate A18-U250A A18-U251A
assign #0.2  CNTOF9 = rst ? 0 : ~(0|A18U245Pad2|A18U246Pad7|A18U234Pad2|A18U240Pad7|F10A);
// Gate A18-U246B
assign #0.2  A18U246Pad9 = rst ? 0 : ~(0|A18U246Pad7|A18U246Pad8);
// Gate A18-U247A A18-U248B
assign #0.2  A18U246Pad8 = rst ? 0 : ~(0|RADRPT|A18U246Pad9|A18U242Pad9|A18U248Pad1);
// Gate A18-U140A
assign #0.2  A18U140Pad1 = rst ? 0 : ~(0|ALTEST|STNDBY);
// Gate A18-U122B
assign #0.2  A18U119Pad8 = rst ? 0 : ~(0|A18U121Pad7);
// Gate A18-U253A
assign #0.2  CH11 = rst ? 0 : ~(0|RCHG_|CHOR11_);
// Gate A18-U105B
assign #0.2  MKRPT = rst ? 0 : ~(0|A18U105Pad6|TPOR_|F09B_);
// Gate A18-U120A
assign #0.2  A18U119Pad7 = rst ? 0 : ~(0|A18U120Pad2);
// Gate A18-U213A
assign #0.2  A18U213Pad1 = rst ? 0 : ~(0|A18U213Pad2|A18U213Pad3);
// Gate A18-U117B
assign #0.2  A18U116Pad6 = rst ? 0 : ~(0|A18U117Pad1|A18U117Pad8);
// Gate A18-U214A
assign #0.2  A18U213Pad3 = rst ? 1 : ~(0|A18U214Pad2|A18U214Pad3);
// Gate A18-U226B
assign #0.2  A18U213Pad2 = rst ? 0 : ~(0|A18U225Pad7);
// Gate A18-U119B A18-U126B
assign #0.2  A18U116Pad2 = rst ? 0 : ~(0|A18U119Pad7|A18U119Pad8|A18U124Pad9|A18U126Pad7|A18U126Pad8);
// Gate A18-U217A
assign #0.2  A18U212Pad8 = rst ? 0 : ~(0|A18U217Pad2|GTSET_);
// Gate A18-U221B
assign #0.2  A18U219Pad3 = rst ? 1 : ~(0|A18U220Pad9|A18U221Pad8);
// Gate A18-U210B
assign #0.2  A18U210Pad9 = rst ? 0 : ~(0|A18U210Pad2|F09B|GOJAM);
// Gate A18-U134B
assign #0.2  A18U134Pad9 = rst ? 0 : ~(0|A18U134Pad1|A18U134Pad8);
// Gate A18-U135A
assign #0.2  A18U134Pad8 = rst ? 1 : ~(0|A18U134Pad9|A18U135Pad3);
// Gate A18-U211A
assign #0.2  A18U210Pad2 = rst ? 1 : ~(0|A18U209Pad2|A18U210Pad9);
// Gate A18-U212A
assign #0.2  A18U212Pad1 = rst ? 0 : ~(0|RADRPT|GOJAM|A18U211Pad7);
// Gate A18-U204B
assign #0.2  RNRADP = rst ? 0 : ~(0|A18U204Pad8);
// Gate A18-U134A
assign #0.2  A18U134Pad1 = rst ? 1 : ~(0|SBYBUT);
// Gate A18-U202B
assign #0.2  RNRADM = rst ? 0 : ~(0|A18U201Pad1);
// Gate A18-U255B
assign #0.2  A18U255Pad2 = rst ? 1 : ~(0|DKEND);
// Gate A18-U242B
assign #0.2  A18U242Pad9 = rst ? 0 : ~(0|A18U242Pad7|A18U242Pad1);
// Gate A18-U152A
assign #0.2  A18U152Pad1 = rst ? 0 : ~(0|A18U151Pad3);
// Gate A18-U113B
assign #0.2  ERRST = rst ? 0 : ~(0|A18U113Pad8);
// Gate A18-U253B
assign #0.2  CH12 = rst ? 0 : ~(0|RCHG_|CHOR12_);
// Gate A18-U102B
assign #0.2  A18U101Pad2 = rst ? 0 : ~(0|XT1_|XB6_);
// Gate A18-U101A
assign #0.2  A18U101Pad1 = rst ? 1 : ~(0|A18U101Pad2);
// Gate A18-U209B A18-U210A
assign #0.2  RADRPT = rst ? 0 : ~(0|GTRST_|TPORA_|A18U210Pad2);
// Gate A18-U235B
assign #0.2  CH16 = rst ? 0 : ~(0|CHOR16_|RCHG_);
// Gate A18-U239B
assign #0.2  CH14 = rst ? 0 : ~(0|CHOR14_|RCHG_);
// Gate A18-U110A
assign #0.2  A18U110Pad1 = rst ? 0 : ~(0|A18U103Pad9|A18U109Pad2);
// Gate A18-U146A
assign #0.2  A18U146Pad1 = rst ? 1 : ~(0|A18U145Pad3);
// Gate A18-U114A
assign #0.2  A18U113Pad8 = rst ? 1 : ~(0|CAURST|W1110);
// Gate A18-U144A
assign #0.2  A18U144Pad1 = rst ? 1 : ~(0|A18U143Pad2);
// Gate A18-U140B
assign #0.2  SBYLIT = rst ? 1 : ~(0|A18U140Pad1);
// Gate A18-U251B
assign #0.2  A18U249Pad3 = rst ? 0 : ~(0|A18U248Pad1|A18U246Pad7);
// Gate A18-U107A
assign #0.2  A18U105Pad6 = rst ? 1 : ~(0|A18U107Pad2|A18U107Pad3);
// Gate A18-U108A
assign #0.2  A18U105Pad3 = rst ? 0 : ~(0|A18U107Pad7);
// Gate A18-U222B
assign #0.2  A18U214Pad8 = rst ? 1 : ~(0|A18U222Pad7|A18U214Pad2);
// Gate A18-U117A
assign #0.2  A18U117Pad1 = rst ? 1 : ~(0|F09D|A18U116Pad2|A18U116Pad6);
// Gate A18-U218B
assign #0.2  A18U214Pad6 = rst ? 1 : ~(0|A18U218Pad8);
// Gate A18-U224A
assign #0.2  A18U214Pad7 = rst ? 1 : ~(0|A18U214Pad3|A18U224Pad3);
// Gate A18-U222A
assign #0.2  A18U214Pad2 = rst ? 0 : ~(0|A18U214Pad8|CCH13);
// Gate A18-U225A
assign #0.2  A18U214Pad3 = rst ? 0 : ~(0|CCH13|A18U214Pad7);
// Gate A18-U119A A18-U126A
assign #0.2  A18U117Pad8 = rst ? 0 : ~(0|F09A_|A18U115Pad3|A18U116Pad2|A18U118Pad1);
// Gate A18-U130B
assign #0.2  A18U129Pad2 = rst ? 1 : ~(0|A18U130Pad1|NKEY1);
// Gate A18-U249A
assign #0.2  A18U248Pad4 = rst ? 0 : ~(0|A18U248Pad1|A18U249Pad3);
// Gate A18-U141B
assign #0.2  STNDBY = rst ? 1 : ~(0|A18U141Pad1|A18U139Pad9);
// Gate A18-U132B
assign #0.2  A18U132Pad2 = rst ? 0 : ~(0|A18U131Pad3|CCH13);
// Gate A18-U248A
assign #0.2  A18U248Pad1 = rst ? 1 : ~(0|A18U242Pad9|A18U246Pad8|A18U248Pad4);
// Gate A18-U214B
assign #0.2  LRRANG = rst ? 0 : ~(0|A18U214Pad6|A18U214Pad7|A18U214Pad8);
// Gate A18-U259B
assign #0.2  A18J4Pad471 = rst ? 1 : ~(0);
// Gate A18-U125B
assign #0.2  A18U123Pad7 = rst ? 1 : ~(0|A18U125Pad1|NKEY3);
// Gate A18-U203A
assign #0.2  HERB = rst ? 0 : ~(0|TPOR_);
// Gate A18-U204A
assign #0.2  A18U201Pad2 = rst ? 0 : ~(0|A18U204Pad2|A18U204Pad3|A18U202Pad1);
// Gate A18-U237B
assign #0.2  A18U235Pad2 = rst ? 0 : ~(0|A18U234Pad2|A18U234Pad8);
// Gate A18-U124A
assign #0.2  A18U123Pad3 = rst ? 0 : ~(0|A18U118Pad1|A18U121Pad7);
// Gate A18-U156B
assign #0.2  RCH15_ = rst ? 1 : ~(0|A18U155Pad9);
// Gate A18-U159A
assign #0.2  A18U158Pad3 = rst ? 1 : ~(0|A18U153Pad1);
// Gate A18-U118A
assign #0.2  A18U118Pad1 = rst ? 0 : ~(0|A18U114Pad8);
// Gate A18-U129A
assign #0.2  A18U126Pad8 = rst ? 0 : ~(0|A18U129Pad2);
// Gate A18-U143A
assign #0.2  A18U143Pad1 = rst ? 1 : ~(0|A18U143Pad2|A18U143Pad3);
// Gate A18-U156A
assign #0.2  A18U143Pad3 = rst ? 0 : ~(0|A18U154Pad9);
// Gate A18-U143B
assign #0.2  A18U143Pad2 = rst ? 0 : ~(0|A18U143Pad1|MKEY1);
// Gate A18-U245B
assign #0.2  A18U244Pad2 = rst ? 0 : ~(0|A18U242Pad3|A18U245Pad2);
// Gate A18-U127A
assign #0.2  A18U126Pad7 = rst ? 1 : ~(0|A18U127Pad2);
// Gate A18-U103B
assign #0.2  A18U103Pad9 = rst ? 0 : ~(0|A18U103Pad1);
// Gate A18-U240A
assign #0.2  A18U239Pad3 = rst ? 1 : ~(0|A18U233Pad2|A18U237Pad2|A18U240Pad4);
// Gate A18-U138B
assign #0.2  A18U138Pad2 = rst ? 0 : ~(0|A18U138Pad1|A18U133Pad9);
// Gate A18-U103A
assign #0.2  A18U103Pad1 = rst ? 1 : ~(0|MRKRST);
// Gate A18-U137B
assign #0.2  SBY = rst ? 1 : ~(0|STNDBY_);
// Gate A18-U131A
assign #0.2  CH1311 = rst ? 0 : ~(0|RCH13_|A18U131Pad3);
// Gate A18-U221A
assign #0.2  CH1301 = rst ? 0 : ~(0|RCH13_|A18U214Pad8);
// Gate A18-U230B
assign #0.2  A18U230Pad2 = rst ? 0 : ~(0|WCH13_|CHWL04_);
// Gate A18-U234A
assign #0.2  A18U233Pad2 = rst ? 0 : ~(0|A18U234Pad2|A18U233Pad1|RADRPT);
// Gate A18-U125A
assign #0.2  A18U125Pad1 = rst ? 0 : ~(0|A18U118Pad1|A18U123Pad7);
// Gate A18-U128A
assign #0.2  A18U128Pad1 = rst ? 1 : ~(0|A18U118Pad1|A18U127Pad2);
// Gate A18-U133A
assign #0.2  F17A_ = rst ? 1 : ~(0|F17A);
// Gate A18-U212B
assign #0.2  A18U211Pad7 = rst ? 1 : ~(0|A18U212Pad1|A18U212Pad8);
// Gate A18-U123A
assign #0.2  A18U121Pad7 = rst ? 1 : ~(0|NKEY4|A18U123Pad3);
// Gate A18-U259A
assign #0.2  A18U259Pad1 = rst ? 0 : ~(0|DLKRPT|A18U255Pad2|A18U256Pad2);
// Gate A18-U147A
assign #0.2  A18U147Pad1 = rst ? 1 : ~(0|A18U143Pad3|A18U147Pad3);
// Gate A18-U227B
assign #0.2  A18U225Pad7 = rst ? 1 : ~(0|A18U226Pad2|A18U227Pad8);
// Gate A18-U147B
assign #0.2  A18U147Pad3 = rst ? 0 : ~(0|A18U147Pad1|MKEY3);
// Gate A18-U232B
assign #0.2  A18U231Pad3 = rst ? 1 : ~(0|A18U232Pad1|F10AS0);
// Gate A18-U233A A18-U234B
assign #0.2  A18U233Pad1 = rst ? 0 : ~(0|A18U233Pad2|RADRPT|A18U221Pad8|A18U234Pad8);
// Gate A18-U153B A18-U154A
assign #0.2  A18U153Pad9 = rst ? 0 : ~(0|A18U143Pad3|F09A_|A18U153Pad1|A18U154Pad4);
// Gate A18-U257A
assign #0.2  A18U257Pad1 = rst ? 0 : ~(0|F10A|A18U256Pad2);
// Gate A18-U130A
assign #0.2  A18U130Pad1 = rst ? 0 : ~(0|A18U129Pad2|A18U118Pad1);
// Gate A18-U153A A18-U155A
assign #0.2  A18U153Pad1 = rst ? 0 : ~(0|A18U144Pad1|A18U146Pad1|A18U148Pad1|A18U150Pad1|A18U152Pad1);
// Gate A18-U101B
assign #0.2  RCH16_ = rst ? 1 : ~(0|A18U101Pad2);
// Gate A18-U225B
assign #0.2  CH1303 = rst ? 0 : ~(0|A18U225Pad7|RCH13_);
// Gate A18-U110B
assign #0.2  A18U109Pad2 = rst ? 1 : ~(0|A18U110Pad1|MRKREJ);
// Gate A18-U109A
assign #0.2  A18U109Pad1 = rst ? 0 : ~(0|A18U109Pad2);
// Gate A18-U257B
assign #0.2  A18U256Pad2 = rst ? 1 : ~(0|A18U257Pad1|DLKRPT);
// Gate A18-U229B
assign #0.2  CH1304 = rst ? 0 : ~(0|RCH13_|A18U229Pad2);
// Gate A18-U235A
assign #0.2  A18U235Pad1 = rst ? 0 : ~(0|A18U235Pad2|A18U234Pad8);
// Gate A18-U202A
assign #0.2  A18U202Pad1 = rst ? 1 : ~(0|LRIN0);
// Gate A18-U233B
assign #0.2  CHOR16_ = rst ? 1 : ~(0|CH1116|CH1216|CH3316);
// Gate A18-U112B
assign #0.2  CH1606 = rst ? 0 : ~(0|A18U111Pad2|A18U101Pad1);
// Gate A18-U109B
assign #0.2  CH1607 = rst ? 0 : ~(0|A18U109Pad2|A18U101Pad1);
// Gate A18-U121B
assign #0.2  CH1604 = rst ? 0 : ~(0|A18U121Pad7|A18U101Pad1);
// Gate A18-U120B
assign #0.2  CH1605 = rst ? 0 : ~(0|A18U120Pad2|A18U101Pad1);
// Gate A18-U127B
assign #0.2  CH1602 = rst ? 0 : ~(0|A18U127Pad2|A18U101Pad1);
// Gate A18-U123B
assign #0.2  CH1603 = rst ? 0 : ~(0|A18U123Pad7|A18U101Pad1);
// Gate A18-U129B
assign #0.2  CH1601 = rst ? 0 : ~(0|A18U101Pad1|A18U129Pad2);
// Gate A18-U158A
assign #0.2  A18U158Pad1 = rst ? 0 : ~(0|A18U154Pad9|A18U158Pad3);
// Gate A18-U215A
assign #0.2  LRZVEL = rst ? 0 : ~(0|A18U214Pad7|A18U214Pad2|A18U214Pad6);
// Gate A18-U135B
assign #0.2  A18U135Pad3 = rst ? 0 : ~(0|F17A_|A18U134Pad1);
// Gate A18-U215B
assign #0.2  LRXVEL = rst ? 0 : ~(0|A18U214Pad6|A18U214Pad3|A18U214Pad2);
// Gate A18-U254B A18-U252B
assign #0.2  CHOR12_ = rst ? 1 : ~(0|CH1112|CH1212|CHAT12|CHBT12);
// Gate A18-U128B
assign #0.2  A18U127Pad2 = rst ? 0 : ~(0|A18U128Pad1|NKEY2);
// Gate A18-U216A
assign #0.2  LRYVEL = rst ? 0 : ~(0|A18U214Pad8|A18U214Pad3|A18U214Pad6);
// Gate A18-U155B
assign #0.2  A18U155Pad9 = rst ? 0 : ~(0|XB5_|XT1_);
// Gate A18-U112A
assign #0.2  A18U112Pad1 = rst ? 0 : ~(0|A18U111Pad2|A18U103Pad9);
// Gate A18-U236B
assign #0.2  A18U234Pad8 = rst ? 1 : ~(0|A18U235Pad1|A18U233Pad1|A18U221Pad8);
// Gate A18-U258B
assign #0.2  CH3312 = rst ? 0 : ~(0|A18U258Pad1|RCH33_);
// Gate A18-U157A
assign #0.2  A18U157Pad1 = rst ? 1 : ~(0|F09D|A18U153Pad1|A18U157Pad4);
// Gate A18-U137A
assign #0.2  A18U137Pad1 = rst ? 0 : ~(0|A18U133Pad9|A18U131Pad3|STOP);
// Gate A18-U157B
assign #0.2  A18U157Pad4 = rst ? 0 : ~(0|A18U157Pad1|A18U153Pad9);
// Gate A18-U223A
assign #0.2  CH1302 = rst ? 0 : ~(0|RCH13_|A18U214Pad7);
// Gate A18-U219A
assign #0.2  A18U218Pad8 = rst ? 0 : ~(0|A18U204Pad2|A18U219Pad3|F5BSB2_);
// Gate A18-U209A
assign #0.2  A18U207Pad7 = rst ? 1 : ~(0|A18U209Pad2);
// Gate A18-U208A
assign #0.2  A18U207Pad2 = rst ? 0 : ~(0|A18U205Pad2|A18U204Pad3|A18U206Pad9);
// Gate A18-U160B
assign #0.2  A18U160Pad2 = rst ? 1 : ~(0|KYRPT1|A18U154Pad4);
// Gate A18-U160A
assign #0.2  A18U154Pad4 = rst ? 0 : ~(0|A18U160Pad2|A18U158Pad1);

endmodule
