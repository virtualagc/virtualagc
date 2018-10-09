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

input wand rst, ALTEST, CAURST, CCH13, CCH33, CGA18, CH1111, CH1112, CH1114,
  CH1116, CH1211, CH1212, CH1216, CH3311, CH3313, CH3314, CH3316, CHAT11,
  CHAT12, CHAT13, CHAT14, CHBT11, CHBT12, CHBT13, CHBT14, CHOR11_, CHOR12_,
  CHOR13_, CHOR16_, CHWL01_, CHWL02_, CHWL03_, CHWL04_, CHWL11_, DKEND, F09A_,
  F09B, F09B_, F09D, F10A, F10A_, F17A, F17B, F5ASB2_, F5BSB2_, GOJAM, GTRST_,
  GTSET_, LRIN0, LRIN1, MAINRS, MARK, MKEY1, MKEY2, MKEY3, MKEY4, MKEY5,
  MRKREJ, MRKRST, NAVRST, NKEY1, NKEY2, NKEY3, NKEY4, NKEY5, RCH13_, RCH33_,
  RCHG_, RRIN0, RRIN1, SB0_, SB2_, SBYBUT, STOP, T05, T11, TEMPIN, W1110,
  WCH13_, XB5_, XB6_, XT1_;

inout wand CHOR14_, F17A_, F17B_, HERB, TPORA_, TPOR_;

output wand CH11, CH12, CH13, CH1301, CH1302, CH1303, CH1304, CH1311, CH14,
  CH1501, CH1502, CH1503, CH1504, CH1505, CH16, CH1601, CH1602, CH1603, CH1604,
  CH1605, CH1606, CH1607, CH3312, CNTOF9, DLKRPT, END, ERRST, F10AS0, KYRPT1,
  KYRPT2, LRRANG, LRSYNC, LRXVEL, LRYVEL, LRZVEL, MKRPT, RADRPT, RCH15_,
  RCH16_, RNRADM, RNRADP, RRRANG, RRRARA, RRSYNC, SBY, SBYLIT, STNDBY, STNDBY_,
  TEMPIN_;

// Gate A18-U241A
assign #0.2  g45417 = rst ? 0 : !(0|g45418|g45414);
// Gate A18-U238A A18-U239A
assign #0.2  g45414 = rst ? 1 : !(0|RADRPT|g45412|g45405|g45415);
// Gate A18-U237A
assign #0.2  g45412 = rst ? 0 : !(0|g45414|g45417);
// Gate A18-U205A
assign #0.2  g45350 = rst ? 0 : !(0|g45336|g45305|g45349);
// Gate A18-U231A
assign #0.2  g45401 = rst ? 0 : !(0|SB2_|g45402|F10A_);
// Gate A18-U136B
assign #0.2  g45147 = rst ? 0 : !(0|g45145|F17B_);
// Gate A18-U133B
assign #0.2  g45142 = rst ? 1 : !(0|g45146|g45147);
// Gate A18-U131B
assign #0.2  g45137 = rst ? 0 : !(0|WCH13_|CHWL11_);
// Gate A18-U150A
assign #0.2  g45116 = rst ? 0 : !(0|g45113);
// Gate A18-U244A
assign #0.2  g45422 = rst ? 0 : !(0|g45423|g45421|g45412);
// Gate A18-U205B
assign #0.2  g45349 = rst ? 1 : !(0|RRIN0);
// Gate A18-U132A
assign #0.2  g45138 = rst ? 1 : !(0|g45139|g45137);
// Gate A18-U213B
assign #0.2  g45336 = rst ? 1 : !(0|g45335);
// Gate A18-U136A
assign #0.2  g45146 = rst ? 0 : !(0|g45142|g45141);
// Gate A18-U245A
assign #0.2  g45424 = rst ? 0 : !(0|g45425|g45421);
// Gate A18-U211B
assign #0.2  g45339 = rst ? 0 : !(0|g45337|F5ASB2_);
// Gate A18-U219B
assign #0.2  g45324 = rst ? 1 : !(0|g45322);
// Gate A18-U236A
assign #0.2  g45410 = rst ? 1 : !(0|g45407|g45411);
// Gate A18-U243B
assign #0.2  CHOR13_ = rst ? 1 : !(0|CH3313|CHBT13|CHAT13);
// Gate A18-U243A A18-U242A
assign #0.2  g45421 = rst ? 1 : !(0|RADRPT|g45419|g45412|g45422);
// Gate A18-U121A
assign #0.2  g45217 = rst ? 1 : !(0|NKEY5|g45218);
// Gate A18-U223B
assign #0.2  g45316 = rst ? 0 : !(0|CHWL01_|WCH13_);
// Gate A18-U149B
assign #0.2  g45113 = rst ? 1 : !(0|g45114|MKEY4);
// Gate A18-U149A
assign #0.2  g45114 = rst ? 0 : !(0|g45123|g45113);
// Gate A18-U240B
assign #0.2  g45416 = rst ? 0 : !(0|g45418|g45415);
// Gate A18-U241B
assign #0.2  g45418 = rst ? 1 : !(0|g45415|g45417);
// Gate A18-U228B
assign #0.2  g45306 = rst ? 0 : !(0|WCH13_|CHWL03_);
// Gate A18-U151A
assign #0.2  g45118 = rst ? 0 : !(0|g45123|g45117);
// Gate A18-U151B
assign #0.2  g45117 = rst ? 1 : !(0|g45118|MKEY5);
// Gate A18-U111A
assign #0.2  g45228 = rst ? 1 : !(0|g45225);
// Gate A18-U113A
assign #0.2  g45225 = rst ? 0 : !(0|MARK|g45226);
// Gate A18-U114B
assign #0.2  g45246 = rst ? 0 : !(0|g45245|g45221);
// Gate A18-U118B
assign #0.2  g45221 = rst ? 1 : !(0|NAVRST);
// Gate A18-U122A
assign #0.2  g45218 = rst ? 0 : !(0|g45223|g45217);
// Gate A18-U230A
assign #0.2  g45302 = rst ? 1 : !(0|g45301|g45303);
// Gate A18-U256B
assign #0.2  DLKRPT = rst ? 0 : !(0|g45450|g45447);
// Gate A18-U116A
assign #0.2  g45245 = rst ? 1 : !(0|g45238);
// Gate A18-U218A
assign #0.2  g45326 = rst ? 1 : !(0|CNTOF9);
// Gate A18-U260B
assign #0.2  g45454 = rst ? 0 : !(0|g45453|g45455);
// Gate A18-U258A
assign #0.2  g45455 = rst ? 1 : !(0|CCH33|g45454);
// Gate A18-U124B
assign #0.2  g45212 = rst ? 0 : !(0|g45209);
// Gate A18-U224B
assign #0.2  g45312 = rst ? 0 : !(0|WCH13_|CHWL02_);
// Gate A18-U115A
assign #0.2  g45248 = rst ? 0 : !(0|KYRPT2|g45247);
// Gate A18-U115B
assign #0.2  g45247 = rst ? 1 : !(0|g45246|g45248);
// Gate A18-U154B
assign #0.2  g45121 = rst ? 1 : !(0|MAINRS);
// Gate A18-U139B
assign #0.2  g45152 = rst ? 0 : !(0|g45151|g45142);
// Gate A18-U141A
assign #0.2  g45154 = rst ? 1 : !(0|STNDBY|g45151);
// Gate A18-U231B
assign #0.2  F10AS0 = rst ? 0 : !(0|F10A_|SB0_);
// Gate A18-U144B
assign #0.2  CH1501 = rst ? 0 : !(0|g45101|RCH15_);
// Gate A18-U220A
assign #0.2  g45322 = rst ? 0 : !(0|g45310|g45320|F5BSB2_);
// Gate A18-U148B
assign #0.2  CH1503 = rst ? 0 : !(0|g45109|RCH15_);
// Gate A18-U228A
assign #0.2  g45305 = rst ? 1 : !(0|g45303);
// Gate A18-U148A
assign #0.2  g45112 = rst ? 0 : !(0|g45109);
// Gate A18-U216B
assign #0.2  RRRANG = rst ? 0 : !(0|g45314|g45324|g45317);
// Gate A18-U207A
assign #0.2  g45351 = rst ? 1 : !(0|g45348|g45354);
// Gate A18-U206A
assign #0.2  g45354 = rst ? 0 : !(0|g45311|g45305|g45353);
// Gate A18-U238B A18-U247B
assign #0.2  CHOR14_ = rst ? 1 : !(0|CHBT14|CH3314|CHAT14|CH1114);
// Gate A18-U250B A18-U252A
assign #0.2  CHOR11_ = rst ? 1 : !(0|CHAT11|CHBT11|CH1111|CH3311|CH1211);
// Gate A18-U102A
assign #0.2  g45257 = rst ? 0 : !(0|g45258|g45256);
// Gate A18-U104B
assign #0.2  g45258 = rst ? 1 : !(0|g45257|MKRPT);
// Gate A18-U105A
assign #0.2  g45256 = rst ? 0 : !(0|g45233|g45255);
// Gate A18-U111B
assign #0.2  g45249 = rst ? 0 : !(0|g45232|g45228);
// Gate A18-U107B
assign #0.2  g43252 = rst ? 0 : !(0|g45251|g45249|F09D);
// Gate A18-U108B A18-U142A
assign #0.2  g45160 = rst ? 0 : !(0|g45249|g45257|F09A_|g45234);
// Gate A18-U106B
assign #0.2  TEMPIN_ = rst ? 1 : !(0|TEMPIN);
// Gate A18-U138A
assign #0.2  g45150 = rst ? 1 : !(0|g45151|g45149);
// Gate A18-U203B
assign #0.2  g45353 = rst ? 1 : !(0|LRIN1);
// Gate A18-U139A
assign #0.2  STNDBY_ = rst ? 1 : !(0|STNDBY);
// Gate A18-U208B
assign #0.2  LRSYNC = rst ? 0 : !(0|g45344|g45311);
// Gate A18-U207B
assign #0.2  RRSYNC = rst ? 0 : !(0|g45344|g45336);
// Gate A18-U256A
assign #0.2  g45450 = rst ? 0 : !(0|g45451|DLKRPT);
// Gate A18-U145B
assign #0.2  g45105 = rst ? 1 : !(0|g45106|MKEY2);
// Gate A18-U145A
assign #0.2  g45106 = rst ? 0 : !(0|g45123|g45105);
// Gate A18-U142B
assign #0.2  g45158 = rst ? 1 : !(0);
// Gate A18-U217B
assign #0.2  RRRARA = rst ? 0 : !(0|g45324|g45313|g45318);
// Gate A18-U227A
assign #0.2  g45308 = rst ? 0 : !(0|CCH13|g45307);
// Gate A18-U246A
assign #0.2  g45425 = rst ? 1 : !(0|g45422|g45424);
// Gate A18-U201A
assign #0.2  g45357 = rst ? 1 : !(0|g45356|g45350);
// Gate A18-U152B
assign #0.2  CH1505 = rst ? 0 : !(0|g45117|RCH15_);
// Gate A18-U150B
assign #0.2  CH1504 = rst ? 0 : !(0|g45113|RCH15_);
// Gate A18-U106A
assign #0.2  F17B_ = rst ? 1 : !(0|F17B);
// Gate A18-U159B
assign #0.2  KYRPT1 = rst ? 0 : !(0|g45129|TPOR_|F09B_);
// Gate A18-U116B
assign #0.2  KYRPT2 = rst ? 0 : !(0|g45241|F09B_|TPOR_);
// Gate A18-U146B
assign #0.2  CH1502 = rst ? 0 : !(0|g45105|RCH15_);
// Gate A18-U158B
assign #0.2  TPOR_ = rst ? 1 : !(0|T05|T11);
// Gate A18-U255A
assign #0.2  END = rst ? 0 : !(0|g45447);
// Gate A18-U206B
assign #0.2  g45347 = rst ? 1 : !(0|RRIN1);
// Gate A18-U244B
assign #0.2  CH13 = rst ? 0 : !(0|CHOR13_|RCHG_);
// Gate A18-U229A
assign #0.2  g45303 = rst ? 0 : !(0|g45302|RADRPT|CCH13);
// Gate A18-U220B
assign #0.2  g45321 = rst ? 0 : !(0|CNTOF9|GOJAM|g45320);
// Gate A18-U226A
assign #0.2  g45311 = rst ? 1 : !(0|g45308);
// Gate A18-U201B
assign #0.2  TPORA_ = rst ? 1 : !(0|HERB);
// Gate A18-U104A
assign #0.2  g45259 = rst ? 1 : !(0);
// Gate A18-U249B
assign #0.2  g45431 = rst ? 0 : !(0|g45428|g45432);
// Gate A18-U232A
assign #0.2  g45403 = rst ? 0 : !(0|g45302|g45402);
// Gate A18-U250A A18-U251A
assign #0.2  CNTOF9 = rst ? 0 : !(0|g45425|g45431|g45410|g45418|F10A);
// Gate A18-U246B
assign #0.2  g45426 = rst ? 0 : !(0|g45431|g45428);
// Gate A18-U247A A18-U248B
assign #0.2  g45428 = rst ? 1 : !(0|RADRPT|g45426|g45419|g45429);
// Gate A18-U140A
assign #0.2  g45156 = rst ? 1 : !(0|ALTEST|STNDBY);
// Gate A18-U122B
assign #0.2  g45216 = rst ? 0 : !(0|g45213);
// Gate A18-U253A
assign #0.2  CH11 = rst ? 0 : !(0|RCHG_|CHOR11_);
// Gate A18-U105B
assign #0.2  MKRPT = rst ? 0 : !(0|g45251|TPOR_|F09B_);
// Gate A18-U120A
assign #0.2  g45220 = rst ? 0 : !(0|g45217);
// Gate A18-U213A
assign #0.2  g45335 = rst ? 0 : !(0|g45310|g45334);
// Gate A18-U117B
assign #0.2  g45241 = rst ? 1 : !(0|g45242|g45243);
// Gate A18-U214A
assign #0.2  g45334 = rst ? 1 : !(0|g45318|g45314);
// Gate A18-U226B
assign #0.2  g45310 = rst ? 0 : !(0|g45307);
// Gate A18-U119B A18-U126B
assign #0.2  g45238 = rst ? 0 : !(0|g45220|g45216|g45212|g45208|g45204);
// Gate A18-U217A
assign #0.2  g45327 = rst ? 0 : !(0|g45326|GTSET_);
// Gate A18-U221B
assign #0.2  g45320 = rst ? 1 : !(0|g45321|g45401);
// Gate A18-U210B
assign #0.2  g45341 = rst ? 0 : !(0|g45340|F09B|GOJAM);
// Gate A18-U134B
assign #0.2  g45144 = rst ? 0 : !(0|g45141|g45145);
// Gate A18-U135A
assign #0.2  g45145 = rst ? 1 : !(0|g45144|g45143);
// Gate A18-U211A
assign #0.2  g45340 = rst ? 1 : !(0|g45339|g45341);
// Gate A18-U212A
assign #0.2  g45338 = rst ? 0 : !(0|RADRPT|GOJAM|g45337);
// Gate A18-U204B
assign #0.2  RNRADP = rst ? 0 : !(0|g45351);
// Gate A18-U134A
assign #0.2  g45141 = rst ? 1 : !(0|SBYBUT);
// Gate A18-U202B
assign #0.2  RNRADM = rst ? 0 : !(0|g45357);
// Gate A18-U255B
assign #0.2  g45447 = rst ? 1 : !(0|DKEND);
// Gate A18-U242B
assign #0.2  g45419 = rst ? 0 : !(0|g45424|g45421);
// Gate A18-U152A
assign #0.2  g45120 = rst ? 0 : !(0|g45117);
// Gate A18-U113B
assign #0.2  ERRST = rst ? 0 : !(0|g45222);
// Gate A18-U253B
assign #0.2  CH12 = rst ? 0 : !(0|RCHG_|CHOR12_);
// Gate A18-U102B
assign #0.2  g45235 = rst ? 0 : !(0|XT1_|XB6_);
// Gate A18-U101A
assign #0.2  g45236 = rst ? 1 : !(0|g45235);
// Gate A18-U209B A18-U210A
assign #0.2  RADRPT = rst ? 0 : !(0|GTRST_|TPORA_|g45340);
// Gate A18-U235B
assign #0.2  CH16 = rst ? 0 : !(0|CHOR16_|RCHG_);
// Gate A18-U239B
assign #0.2  CH14 = rst ? 0 : !(0|CHOR14_|RCHG_);
// Gate A18-U110A
assign #0.2  g45230 = rst ? 0 : !(0|g45234|g45229);
// Gate A18-U146A
assign #0.2  g45108 = rst ? 0 : !(0|g45105);
// Gate A18-U114A
assign #0.2  g45222 = rst ? 1 : !(0|CAURST|W1110);
// Gate A18-U144A
assign #0.2  g45104 = rst ? 0 : !(0|g45101);
// Gate A18-U140B
assign #0.2  SBYLIT = rst ? 0 : !(0|g45156);
// Gate A18-U251B
assign #0.2  g45432 = rst ? 1 : !(0|g45429|g45431);
// Gate A18-U107A
assign #0.2  g45251 = rst ? 1 : !(0|g45160|g43252);
// Gate A18-U108A
assign #0.2  g45255 = rst ? 1 : !(0|g45249);
// Gate A18-U222B
assign #0.2  g45317 = rst ? 1 : !(0|g45316|g45318);
// Gate A18-U117A
assign #0.2  g45242 = rst ? 0 : !(0|F09D|g45238|g45241);
// Gate A18-U218B
assign #0.2  g45325 = rst ? 1 : !(0|g45323);
// Gate A18-U224A
assign #0.2  g45313 = rst ? 1 : !(0|g45314|g45312);
// Gate A18-U222A
assign #0.2  g45318 = rst ? 0 : !(0|g45317|CCH13);
// Gate A18-U225A
assign #0.2  g45314 = rst ? 0 : !(0|CCH13|g45313);
// Gate A18-U119A A18-U126A
assign #0.2  g45243 = rst ? 0 : !(0|F09A_|g45247|g45238|g45223);
// Gate A18-U130B
assign #0.2  g45201 = rst ? 1 : !(0|g45202|NKEY1);
// Gate A18-U249A
assign #0.2  g45430 = rst ? 0 : !(0|g45429|g45432);
// Gate A18-U141B
assign #0.2  STNDBY = rst ? 0 : !(0|g45154|g45152);
// Gate A18-U132B
assign #0.2  g45139 = rst ? 0 : !(0|g45138|CCH13);
// Gate A18-U248A
assign #0.2  g45429 = rst ? 0 : !(0|g45419|g45428|g45430);
// Gate A18-U214B
assign #0.2  LRRANG = rst ? 0 : !(0|g45325|g45313|g45317);
// Gate A18-U259B
assign #0.2  g45457 = rst ? 1 : !(0);
// Gate A18-U125B
assign #0.2  g45209 = rst ? 1 : !(0|g45210|NKEY3);
// Gate A18-U203A
assign #0.2  HERB = rst ? 0 : !(0|TPOR_);
// Gate A18-U204A
assign #0.2  g45356 = rst ? 0 : !(0|g45311|g45305|g45355);
// Gate A18-U237B
assign #0.2  g45411 = rst ? 0 : !(0|g45410|g45408);
// Gate A18-U124A
assign #0.2  g45214 = rst ? 0 : !(0|g45223|g45213);
// Gate A18-U156B
assign #0.2  RCH15_ = rst ? 1 : !(0|g45122);
// Gate A18-U159A
assign #0.2  g45133 = rst ? 0 : !(0|g45126);
// Gate A18-U118A
assign #0.2  g45223 = rst ? 0 : !(0|g45221);
// Gate A18-U129A
assign #0.2  g45204 = rst ? 0 : !(0|g45201);
// Gate A18-U143A
assign #0.2  g45102 = rst ? 0 : !(0|g45101|g45123);
// Gate A18-U156A
assign #0.2  g45123 = rst ? 0 : !(0|g45121);
// Gate A18-U143B
assign #0.2  g45101 = rst ? 1 : !(0|g45102|MKEY1);
// Gate A18-U245B
assign #0.2  g45423 = rst ? 0 : !(0|g45422|g45425);
// Gate A18-U127A
assign #0.2  g45208 = rst ? 1 : !(0|g42205);
// Gate A18-U103B
assign #0.2  g45234 = rst ? 0 : !(0|g45233);
// Gate A18-U240A
assign #0.2  g45415 = rst ? 0 : !(0|g45405|g45414|g45416);
// Gate A18-U138B
assign #0.2  g45151 = rst ? 0 : !(0|g45150|g45142);
// Gate A18-U103A
assign #0.2  g45233 = rst ? 1 : !(0|MRKRST);
// Gate A18-U137B
assign #0.2  SBY = rst ? 0 : !(0|STNDBY_);
// Gate A18-U131A
assign #0.2  CH1311 = rst ? 0 : !(0|RCH13_|g45138);
// Gate A18-U221A
assign #0.2  CH1301 = rst ? 0 : !(0|RCH13_|g45317);
// Gate A18-U230B
assign #0.2  g45301 = rst ? 0 : !(0|WCH13_|CHWL04_);
// Gate A18-U234A
assign #0.2  g45405 = rst ? 0 : !(0|g45410|g45407|RADRPT);
// Gate A18-U125A
assign #0.2  g45210 = rst ? 0 : !(0|g45223|g45209);
// Gate A18-U128A
assign #0.2  g45206 = rst ? 1 : !(0|g45223|g42205);
// Gate A18-U133A
assign #0.2  F17A_ = rst ? 1 : !(0|F17A);
// Gate A18-U212B
assign #0.2  g45337 = rst ? 1 : !(0|g45338|g45327);
// Gate A18-U123A
assign #0.2  g45213 = rst ? 1 : !(0|NKEY4|g45214);
// Gate A18-U259A
assign #0.2  g45453 = rst ? 0 : !(0|DLKRPT|g45447|g45451);
// Gate A18-U147A
assign #0.2  g45110 = rst ? 0 : !(0|g45123|g45109);
// Gate A18-U227B
assign #0.2  g45307 = rst ? 1 : !(0|g45308|g45306);
// Gate A18-U147B
assign #0.2  g45109 = rst ? 1 : !(0|g45110|MKEY3);
// Gate A18-U232B
assign #0.2  g45402 = rst ? 1 : !(0|g45403|F10AS0);
// Gate A18-U233A A18-U234B
assign #0.2  g45407 = rst ? 0 : !(0|g45405|RADRPT|g45401|g45408);
// Gate A18-U153B A18-U154A
assign #0.2  g45127 = rst ? 0 : !(0|g45123|F09A_|g45126|g45135);
// Gate A18-U257A
assign #0.2  g45452 = rst ? 0 : !(0|F10A|g45451);
// Gate A18-U130A
assign #0.2  g45202 = rst ? 0 : !(0|g45201|g45223);
// Gate A18-U153A A18-U155A
assign #0.2  g45126 = rst ? 1 : !(0|g45104|g45108|g45112|g45116|g45120);
// Gate A18-U101B
assign #0.2  RCH16_ = rst ? 1 : !(0|g45235);
// Gate A18-U225B
assign #0.2  CH1303 = rst ? 0 : !(0|g45307|RCH13_);
// Gate A18-U110B
assign #0.2  g45229 = rst ? 1 : !(0|g45230|MRKREJ);
// Gate A18-U109A
assign #0.2  g45232 = rst ? 0 : !(0|g45229);
// Gate A18-U257B
assign #0.2  g45451 = rst ? 1 : !(0|g45452|DLKRPT);
// Gate A18-U229B
assign #0.2  CH1304 = rst ? 0 : !(0|RCH13_|g45302);
// Gate A18-U235A
assign #0.2  g45409 = rst ? 0 : !(0|g45411|g45408);
// Gate A18-U202A
assign #0.2  g45355 = rst ? 1 : !(0|LRIN0);
// Gate A18-U233B
assign #0.2  CHOR16_ = rst ? 1 : !(0|CH1116|CH1216|CH3316);
// Gate A18-U112B
assign #0.2  CH1606 = rst ? 0 : !(0|g45225|g45236);
// Gate A18-U109B
assign #0.2  CH1607 = rst ? 0 : !(0|g45229|g45236);
// Gate A18-U121B
assign #0.2  CH1604 = rst ? 0 : !(0|g45213|g45236);
// Gate A18-U120B
assign #0.2  CH1605 = rst ? 0 : !(0|g45217|g45236);
// Gate A18-U127B
assign #0.2  CH1602 = rst ? 0 : !(0|g42205|g45236);
// Gate A18-U123B
assign #0.2  CH1603 = rst ? 0 : !(0|g45209|g45236);
// Gate A18-U129B
assign #0.2  CH1601 = rst ? 0 : !(0|g45236|g45201);
// Gate A18-U158A
assign #0.2  g45134 = rst ? 0 : !(0|g45121|g45133);
// Gate A18-U215A
assign #0.2  LRZVEL = rst ? 0 : !(0|g45313|g45318|g45325);
// Gate A18-U135B
assign #0.2  g45143 = rst ? 0 : !(0|F17A_|g45141);
// Gate A18-U215B
assign #0.2  LRXVEL = rst ? 0 : !(0|g45325|g45314|g45318);
// Gate A18-U254B A18-U252B
assign #0.2  CHOR12_ = rst ? 1 : !(0|CH1112|CH1212|CHAT12|CHBT12);
// Gate A18-U128B
assign #0.2  g42205 = rst ? 0 : !(0|g45206|NKEY2);
// Gate A18-U216A
assign #0.2  LRYVEL = rst ? 0 : !(0|g45317|g45314|g45325);
// Gate A18-U155B
assign #0.2  g45122 = rst ? 0 : !(0|XB5_|XT1_);
// Gate A18-U112A
assign #0.2  g45226 = rst ? 1 : !(0|g45225|g45234);
// Gate A18-U236B
assign #0.2  g45408 = rst ? 1 : !(0|g45409|g45407|g45401);
// Gate A18-U258B
assign #0.2  CH3312 = rst ? 0 : !(0|g45455|RCH33_);
// Gate A18-U157A
assign #0.2  g45130 = rst ? 0 : !(0|F09D|g45126|g45129);
// Gate A18-U137A
assign #0.2  g45149 = rst ? 0 : !(0|g45142|g45138|STOP);
// Gate A18-U157B
assign #0.2  g45129 = rst ? 1 : !(0|g45130|g45127);
// Gate A18-U223A
assign #0.2  CH1302 = rst ? 0 : !(0|RCH13_|g45313);
// Gate A18-U219A
assign #0.2  g45323 = rst ? 0 : !(0|g45311|g45320|F5BSB2_);
// Gate A18-U209A
assign #0.2  g45344 = rst ? 1 : !(0|g45339);
// Gate A18-U208A
assign #0.2  g45348 = rst ? 0 : !(0|g45336|g45305|g45347);
// Gate A18-U160B
assign #0.2  g45136 = rst ? 0 : !(0|KYRPT1|g45135);
// Gate A18-U160A
assign #0.2  g45135 = rst ? 1 : !(0|g45136|g45134);
// End of NOR gates

endmodule
