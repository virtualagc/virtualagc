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
pullup(g45417);
assign #0.2  g45417 = rst ? 0 : ((0|g45418|g45414) ? 1'b0 : 1'bz);
// Gate A18-U238A A18-U239A
pullup(g45414);
assign #0.2  g45414 = rst ? 1'bz : ((0|RADRPT|g45412|g45405|g45415) ? 1'b0 : 1'bz);
// Gate A18-U237A
pullup(g45412);
assign #0.2  g45412 = rst ? 0 : ((0|g45414|g45417) ? 1'b0 : 1'bz);
// Gate A18-U205A
pullup(g45350);
assign #0.2  g45350 = rst ? 0 : ((0|g45336|g45305|g45349) ? 1'b0 : 1'bz);
// Gate A18-U231A
pullup(g45401);
assign #0.2  g45401 = rst ? 0 : ((0|SB2_|g45402|F10A_) ? 1'b0 : 1'bz);
// Gate A18-U136B
pullup(g45147);
assign #0.2  g45147 = rst ? 0 : ((0|g45145|F17B_) ? 1'b0 : 1'bz);
// Gate A18-U133B
pullup(g45142);
assign #0.2  g45142 = rst ? 1'bz : ((0|g45146|g45147) ? 1'b0 : 1'bz);
// Gate A18-U131B
pullup(g45137);
assign #0.2  g45137 = rst ? 0 : ((0|WCH13_|CHWL11_) ? 1'b0 : 1'bz);
// Gate A18-U150A
pullup(g45116);
assign #0.2  g45116 = rst ? 0 : ((0|g45113) ? 1'b0 : 1'bz);
// Gate A18-U244A
pullup(g45422);
assign #0.2  g45422 = rst ? 0 : ((0|g45423|g45421|g45412) ? 1'b0 : 1'bz);
// Gate A18-U205B
pullup(g45349);
assign #0.2  g45349 = rst ? 1'bz : ((0|RRIN0) ? 1'b0 : 1'bz);
// Gate A18-U132A
pullup(g45138);
assign #0.2  g45138 = rst ? 1'bz : ((0|g45139|g45137) ? 1'b0 : 1'bz);
// Gate A18-U213B
pullup(g45336);
assign #0.2  g45336 = rst ? 1'bz : ((0|g45335) ? 1'b0 : 1'bz);
// Gate A18-U136A
pullup(g45146);
assign #0.2  g45146 = rst ? 0 : ((0|g45142|g45141) ? 1'b0 : 1'bz);
// Gate A18-U245A
pullup(g45424);
assign #0.2  g45424 = rst ? 0 : ((0|g45425|g45421) ? 1'b0 : 1'bz);
// Gate A18-U211B
pullup(g45339);
assign #0.2  g45339 = rst ? 0 : ((0|g45337|F5ASB2_) ? 1'b0 : 1'bz);
// Gate A18-U219B
pullup(g45324);
assign #0.2  g45324 = rst ? 1'bz : ((0|g45322) ? 1'b0 : 1'bz);
// Gate A18-U236A
pullup(g45410);
assign #0.2  g45410 = rst ? 1'bz : ((0|g45407|g45411) ? 1'b0 : 1'bz);
// Gate A18-U243B
pullup(CHOR13_);
assign #0.2  CHOR13_ = rst ? 1'bz : ((0|CH3313|CHBT13|CHAT13) ? 1'b0 : 1'bz);
// Gate A18-U243A A18-U242A
pullup(g45421);
assign #0.2  g45421 = rst ? 1'bz : ((0|RADRPT|g45419|g45412|g45422) ? 1'b0 : 1'bz);
// Gate A18-U121A
pullup(g45217);
assign #0.2  g45217 = rst ? 1'bz : ((0|NKEY5|g45218) ? 1'b0 : 1'bz);
// Gate A18-U223B
pullup(g45316);
assign #0.2  g45316 = rst ? 0 : ((0|CHWL01_|WCH13_) ? 1'b0 : 1'bz);
// Gate A18-U149B
pullup(g45113);
assign #0.2  g45113 = rst ? 1'bz : ((0|g45114|MKEY4) ? 1'b0 : 1'bz);
// Gate A18-U149A
pullup(g45114);
assign #0.2  g45114 = rst ? 0 : ((0|g45123|g45113) ? 1'b0 : 1'bz);
// Gate A18-U240B
pullup(g45416);
assign #0.2  g45416 = rst ? 0 : ((0|g45418|g45415) ? 1'b0 : 1'bz);
// Gate A18-U241B
pullup(g45418);
assign #0.2  g45418 = rst ? 1'bz : ((0|g45415|g45417) ? 1'b0 : 1'bz);
// Gate A18-U228B
pullup(g45306);
assign #0.2  g45306 = rst ? 0 : ((0|WCH13_|CHWL03_) ? 1'b0 : 1'bz);
// Gate A18-U151A
pullup(g45118);
assign #0.2  g45118 = rst ? 0 : ((0|g45123|g45117) ? 1'b0 : 1'bz);
// Gate A18-U151B
pullup(g45117);
assign #0.2  g45117 = rst ? 1'bz : ((0|g45118|MKEY5) ? 1'b0 : 1'bz);
// Gate A18-U111A
pullup(g45228);
assign #0.2  g45228 = rst ? 1'bz : ((0|g45225) ? 1'b0 : 1'bz);
// Gate A18-U113A
pullup(g45225);
assign #0.2  g45225 = rst ? 0 : ((0|MARK|g45226) ? 1'b0 : 1'bz);
// Gate A18-U114B
pullup(g45246);
assign #0.2  g45246 = rst ? 0 : ((0|g45245|g45221) ? 1'b0 : 1'bz);
// Gate A18-U118B
pullup(g45221);
assign #0.2  g45221 = rst ? 1'bz : ((0|NAVRST) ? 1'b0 : 1'bz);
// Gate A18-U122A
pullup(g45218);
assign #0.2  g45218 = rst ? 0 : ((0|g45223|g45217) ? 1'b0 : 1'bz);
// Gate A18-U230A
pullup(g45302);
assign #0.2  g45302 = rst ? 1'bz : ((0|g45301|g45303) ? 1'b0 : 1'bz);
// Gate A18-U256B
pullup(DLKRPT);
assign #0.2  DLKRPT = rst ? 0 : ((0|g45450|g45447) ? 1'b0 : 1'bz);
// Gate A18-U116A
pullup(g45245);
assign #0.2  g45245 = rst ? 1'bz : ((0|g45238) ? 1'b0 : 1'bz);
// Gate A18-U218A
pullup(g45326);
assign #0.2  g45326 = rst ? 1'bz : ((0|CNTOF9) ? 1'b0 : 1'bz);
// Gate A18-U260B
pullup(g45454);
assign #0.2  g45454 = rst ? 0 : ((0|g45453|g45455) ? 1'b0 : 1'bz);
// Gate A18-U258A
pullup(g45455);
assign #0.2  g45455 = rst ? 1'bz : ((0|CCH33|g45454) ? 1'b0 : 1'bz);
// Gate A18-U124B
pullup(g45212);
assign #0.2  g45212 = rst ? 0 : ((0|g45209) ? 1'b0 : 1'bz);
// Gate A18-U224B
pullup(g45312);
assign #0.2  g45312 = rst ? 0 : ((0|WCH13_|CHWL02_) ? 1'b0 : 1'bz);
// Gate A18-U115A
pullup(g45248);
assign #0.2  g45248 = rst ? 0 : ((0|KYRPT2|g45247) ? 1'b0 : 1'bz);
// Gate A18-U115B
pullup(g45247);
assign #0.2  g45247 = rst ? 1'bz : ((0|g45246|g45248) ? 1'b0 : 1'bz);
// Gate A18-U154B
pullup(g45121);
assign #0.2  g45121 = rst ? 1'bz : ((0|MAINRS) ? 1'b0 : 1'bz);
// Gate A18-U139B
pullup(g45152);
assign #0.2  g45152 = rst ? 0 : ((0|g45151|g45142) ? 1'b0 : 1'bz);
// Gate A18-U141A
pullup(g45154);
assign #0.2  g45154 = rst ? 1'bz : ((0|STNDBY|g45151) ? 1'b0 : 1'bz);
// Gate A18-U231B
pullup(F10AS0);
assign #0.2  F10AS0 = rst ? 0 : ((0|F10A_|SB0_) ? 1'b0 : 1'bz);
// Gate A18-U144B
pullup(CH1501);
assign #0.2  CH1501 = rst ? 0 : ((0|g45101|RCH15_) ? 1'b0 : 1'bz);
// Gate A18-U220A
pullup(g45322);
assign #0.2  g45322 = rst ? 0 : ((0|g45310|g45320|F5BSB2_) ? 1'b0 : 1'bz);
// Gate A18-U148B
pullup(CH1503);
assign #0.2  CH1503 = rst ? 0 : ((0|g45109|RCH15_) ? 1'b0 : 1'bz);
// Gate A18-U228A
pullup(g45305);
assign #0.2  g45305 = rst ? 1'bz : ((0|g45303) ? 1'b0 : 1'bz);
// Gate A18-U148A
pullup(g45112);
assign #0.2  g45112 = rst ? 0 : ((0|g45109) ? 1'b0 : 1'bz);
// Gate A18-U216B
pullup(RRRANG);
assign #0.2  RRRANG = rst ? 0 : ((0|g45314|g45324|g45317) ? 1'b0 : 1'bz);
// Gate A18-U207A
pullup(g45351);
assign #0.2  g45351 = rst ? 1'bz : ((0|g45348|g45354) ? 1'b0 : 1'bz);
// Gate A18-U206A
pullup(g45354);
assign #0.2  g45354 = rst ? 0 : ((0|g45311|g45305|g45353) ? 1'b0 : 1'bz);
// Gate A18-U238B A18-U247B
pullup(CHOR14_);
assign #0.2  CHOR14_ = rst ? 1'bz : ((0|CHBT14|CH3314|CHAT14|CH1114) ? 1'b0 : 1'bz);
// Gate A18-U250B A18-U252A
pullup(CHOR11_);
assign #0.2  CHOR11_ = rst ? 1'bz : ((0|CHAT11|CHBT11|CH1111|CH3311|CH1211) ? 1'b0 : 1'bz);
// Gate A18-U102A
pullup(g45257);
assign #0.2  g45257 = rst ? 0 : ((0|g45258|g45256) ? 1'b0 : 1'bz);
// Gate A18-U104B
pullup(g45258);
assign #0.2  g45258 = rst ? 1'bz : ((0|g45257|MKRPT) ? 1'b0 : 1'bz);
// Gate A18-U105A
pullup(g45256);
assign #0.2  g45256 = rst ? 0 : ((0|g45233|g45255) ? 1'b0 : 1'bz);
// Gate A18-U111B
pullup(g45249);
assign #0.2  g45249 = rst ? 0 : ((0|g45232|g45228) ? 1'b0 : 1'bz);
// Gate A18-U107B
pullup(g43252);
assign #0.2  g43252 = rst ? 0 : ((0|g45251|g45249|F09D) ? 1'b0 : 1'bz);
// Gate A18-U108B A18-U142A
pullup(g45160);
assign #0.2  g45160 = rst ? 0 : ((0|g45249|g45257|F09A_|g45234) ? 1'b0 : 1'bz);
// Gate A18-U106B
pullup(TEMPIN_);
assign #0.2  TEMPIN_ = rst ? 1'bz : ((0|TEMPIN) ? 1'b0 : 1'bz);
// Gate A18-U138A
pullup(g45150);
assign #0.2  g45150 = rst ? 1'bz : ((0|g45151|g45149) ? 1'b0 : 1'bz);
// Gate A18-U203B
pullup(g45353);
assign #0.2  g45353 = rst ? 1'bz : ((0|LRIN1) ? 1'b0 : 1'bz);
// Gate A18-U139A
pullup(STNDBY_);
assign #0.2  STNDBY_ = rst ? 1'bz : ((0|STNDBY) ? 1'b0 : 1'bz);
// Gate A18-U208B
pullup(LRSYNC);
assign #0.2  LRSYNC = rst ? 0 : ((0|g45344|g45311) ? 1'b0 : 1'bz);
// Gate A18-U207B
pullup(RRSYNC);
assign #0.2  RRSYNC = rst ? 0 : ((0|g45344|g45336) ? 1'b0 : 1'bz);
// Gate A18-U256A
pullup(g45450);
assign #0.2  g45450 = rst ? 0 : ((0|g45451|DLKRPT) ? 1'b0 : 1'bz);
// Gate A18-U145B
pullup(g45105);
assign #0.2  g45105 = rst ? 1'bz : ((0|g45106|MKEY2) ? 1'b0 : 1'bz);
// Gate A18-U145A
pullup(g45106);
assign #0.2  g45106 = rst ? 0 : ((0|g45123|g45105) ? 1'b0 : 1'bz);
// Gate A18-U142B
pullup(g45158);
assign #0.2  g45158 = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A18-U217B
pullup(RRRARA);
assign #0.2  RRRARA = rst ? 0 : ((0|g45324|g45313|g45318) ? 1'b0 : 1'bz);
// Gate A18-U227A
pullup(g45308);
assign #0.2  g45308 = rst ? 0 : ((0|CCH13|g45307) ? 1'b0 : 1'bz);
// Gate A18-U246A
pullup(g45425);
assign #0.2  g45425 = rst ? 1'bz : ((0|g45422|g45424) ? 1'b0 : 1'bz);
// Gate A18-U201A
pullup(g45357);
assign #0.2  g45357 = rst ? 1'bz : ((0|g45356|g45350) ? 1'b0 : 1'bz);
// Gate A18-U152B
pullup(CH1505);
assign #0.2  CH1505 = rst ? 0 : ((0|g45117|RCH15_) ? 1'b0 : 1'bz);
// Gate A18-U150B
pullup(CH1504);
assign #0.2  CH1504 = rst ? 0 : ((0|g45113|RCH15_) ? 1'b0 : 1'bz);
// Gate A18-U106A
pullup(F17B_);
assign #0.2  F17B_ = rst ? 1'bz : ((0|F17B) ? 1'b0 : 1'bz);
// Gate A18-U159B
pullup(KYRPT1);
assign #0.2  KYRPT1 = rst ? 0 : ((0|g45129|TPOR_|F09B_) ? 1'b0 : 1'bz);
// Gate A18-U116B
pullup(KYRPT2);
assign #0.2  KYRPT2 = rst ? 0 : ((0|g45241|F09B_|TPOR_) ? 1'b0 : 1'bz);
// Gate A18-U146B
pullup(CH1502);
assign #0.2  CH1502 = rst ? 0 : ((0|g45105|RCH15_) ? 1'b0 : 1'bz);
// Gate A18-U158B
pullup(TPOR_);
assign #0.2  TPOR_ = rst ? 1'bz : ((0|T05|T11) ? 1'b0 : 1'bz);
// Gate A18-U255A
pullup(END);
assign #0.2  END = rst ? 0 : ((0|g45447) ? 1'b0 : 1'bz);
// Gate A18-U206B
pullup(g45347);
assign #0.2  g45347 = rst ? 1'bz : ((0|RRIN1) ? 1'b0 : 1'bz);
// Gate A18-U244B
pullup(CH13);
assign #0.2  CH13 = rst ? 0 : ((0|CHOR13_|RCHG_) ? 1'b0 : 1'bz);
// Gate A18-U229A
pullup(g45303);
assign #0.2  g45303 = rst ? 0 : ((0|g45302|RADRPT|CCH13) ? 1'b0 : 1'bz);
// Gate A18-U220B
pullup(g45321);
assign #0.2  g45321 = rst ? 0 : ((0|CNTOF9|GOJAM|g45320) ? 1'b0 : 1'bz);
// Gate A18-U226A
pullup(g45311);
assign #0.2  g45311 = rst ? 1'bz : ((0|g45308) ? 1'b0 : 1'bz);
// Gate A18-U201B
pullup(TPORA_);
assign #0.2  TPORA_ = rst ? 1'bz : ((0|HERB) ? 1'b0 : 1'bz);
// Gate A18-U104A
pullup(g45259);
assign #0.2  g45259 = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A18-U249B
pullup(g45431);
assign #0.2  g45431 = rst ? 0 : ((0|g45428|g45432) ? 1'b0 : 1'bz);
// Gate A18-U232A
pullup(g45403);
assign #0.2  g45403 = rst ? 0 : ((0|g45302|g45402) ? 1'b0 : 1'bz);
// Gate A18-U250A A18-U251A
pullup(CNTOF9);
assign #0.2  CNTOF9 = rst ? 0 : ((0|g45425|g45431|g45410|g45418|F10A) ? 1'b0 : 1'bz);
// Gate A18-U246B
pullup(g45426);
assign #0.2  g45426 = rst ? 0 : ((0|g45431|g45428) ? 1'b0 : 1'bz);
// Gate A18-U247A A18-U248B
pullup(g45428);
assign #0.2  g45428 = rst ? 1'bz : ((0|RADRPT|g45426|g45419|g45429) ? 1'b0 : 1'bz);
// Gate A18-U140A
pullup(g45156);
assign #0.2  g45156 = rst ? 1'bz : ((0|ALTEST|STNDBY) ? 1'b0 : 1'bz);
// Gate A18-U122B
pullup(g45216);
assign #0.2  g45216 = rst ? 0 : ((0|g45213) ? 1'b0 : 1'bz);
// Gate A18-U253A
pullup(CH11);
assign #0.2  CH11 = rst ? 0 : ((0|RCHG_|CHOR11_) ? 1'b0 : 1'bz);
// Gate A18-U105B
pullup(MKRPT);
assign #0.2  MKRPT = rst ? 0 : ((0|g45251|TPOR_|F09B_) ? 1'b0 : 1'bz);
// Gate A18-U120A
pullup(g45220);
assign #0.2  g45220 = rst ? 0 : ((0|g45217) ? 1'b0 : 1'bz);
// Gate A18-U213A
pullup(g45335);
assign #0.2  g45335 = rst ? 0 : ((0|g45310|g45334) ? 1'b0 : 1'bz);
// Gate A18-U117B
pullup(g45241);
assign #0.2  g45241 = rst ? 1'bz : ((0|g45242|g45243) ? 1'b0 : 1'bz);
// Gate A18-U214A
pullup(g45334);
assign #0.2  g45334 = rst ? 1'bz : ((0|g45318|g45314) ? 1'b0 : 1'bz);
// Gate A18-U226B
pullup(g45310);
assign #0.2  g45310 = rst ? 0 : ((0|g45307) ? 1'b0 : 1'bz);
// Gate A18-U119B A18-U126B
pullup(g45238);
assign #0.2  g45238 = rst ? 0 : ((0|g45220|g45216|g45212|g45208|g45204) ? 1'b0 : 1'bz);
// Gate A18-U217A
pullup(g45327);
assign #0.2  g45327 = rst ? 0 : ((0|g45326|GTSET_) ? 1'b0 : 1'bz);
// Gate A18-U221B
pullup(g45320);
assign #0.2  g45320 = rst ? 1'bz : ((0|g45321|g45401) ? 1'b0 : 1'bz);
// Gate A18-U210B
pullup(g45341);
assign #0.2  g45341 = rst ? 0 : ((0|g45340|F09B|GOJAM) ? 1'b0 : 1'bz);
// Gate A18-U134B
pullup(g45144);
assign #0.2  g45144 = rst ? 0 : ((0|g45141|g45145) ? 1'b0 : 1'bz);
// Gate A18-U135A
pullup(g45145);
assign #0.2  g45145 = rst ? 1'bz : ((0|g45144|g45143) ? 1'b0 : 1'bz);
// Gate A18-U211A
pullup(g45340);
assign #0.2  g45340 = rst ? 1'bz : ((0|g45339|g45341) ? 1'b0 : 1'bz);
// Gate A18-U212A
pullup(g45338);
assign #0.2  g45338 = rst ? 0 : ((0|RADRPT|GOJAM|g45337) ? 1'b0 : 1'bz);
// Gate A18-U204B
pullup(RNRADP);
assign #0.2  RNRADP = rst ? 0 : ((0|g45351) ? 1'b0 : 1'bz);
// Gate A18-U134A
pullup(g45141);
assign #0.2  g45141 = rst ? 1'bz : ((0|SBYBUT) ? 1'b0 : 1'bz);
// Gate A18-U202B
pullup(RNRADM);
assign #0.2  RNRADM = rst ? 0 : ((0|g45357) ? 1'b0 : 1'bz);
// Gate A18-U255B
pullup(g45447);
assign #0.2  g45447 = rst ? 1'bz : ((0|DKEND) ? 1'b0 : 1'bz);
// Gate A18-U242B
pullup(g45419);
assign #0.2  g45419 = rst ? 0 : ((0|g45424|g45421) ? 1'b0 : 1'bz);
// Gate A18-U152A
pullup(g45120);
assign #0.2  g45120 = rst ? 0 : ((0|g45117) ? 1'b0 : 1'bz);
// Gate A18-U113B
pullup(ERRST);
assign #0.2  ERRST = rst ? 0 : ((0|g45222) ? 1'b0 : 1'bz);
// Gate A18-U253B
pullup(CH12);
assign #0.2  CH12 = rst ? 0 : ((0|RCHG_|CHOR12_) ? 1'b0 : 1'bz);
// Gate A18-U102B
pullup(g45235);
assign #0.2  g45235 = rst ? 0 : ((0|XT1_|XB6_) ? 1'b0 : 1'bz);
// Gate A18-U101A
pullup(g45236);
assign #0.2  g45236 = rst ? 1'bz : ((0|g45235) ? 1'b0 : 1'bz);
// Gate A18-U209B A18-U210A
pullup(RADRPT);
assign #0.2  RADRPT = rst ? 0 : ((0|GTRST_|TPORA_|g45340) ? 1'b0 : 1'bz);
// Gate A18-U235B
pullup(CH16);
assign #0.2  CH16 = rst ? 0 : ((0|CHOR16_|RCHG_) ? 1'b0 : 1'bz);
// Gate A18-U239B
pullup(CH14);
assign #0.2  CH14 = rst ? 0 : ((0|CHOR14_|RCHG_) ? 1'b0 : 1'bz);
// Gate A18-U110A
pullup(g45230);
assign #0.2  g45230 = rst ? 0 : ((0|g45234|g45229) ? 1'b0 : 1'bz);
// Gate A18-U146A
pullup(g45108);
assign #0.2  g45108 = rst ? 0 : ((0|g45105) ? 1'b0 : 1'bz);
// Gate A18-U114A
pullup(g45222);
assign #0.2  g45222 = rst ? 1'bz : ((0|CAURST|W1110) ? 1'b0 : 1'bz);
// Gate A18-U144A
pullup(g45104);
assign #0.2  g45104 = rst ? 0 : ((0|g45101) ? 1'b0 : 1'bz);
// Gate A18-U140B
pullup(SBYLIT);
assign #0.2  SBYLIT = rst ? 0 : ((0|g45156) ? 1'b0 : 1'bz);
// Gate A18-U251B
pullup(g45432);
assign #0.2  g45432 = rst ? 1'bz : ((0|g45429|g45431) ? 1'b0 : 1'bz);
// Gate A18-U107A
pullup(g45251);
assign #0.2  g45251 = rst ? 1'bz : ((0|g45160|g43252) ? 1'b0 : 1'bz);
// Gate A18-U108A
pullup(g45255);
assign #0.2  g45255 = rst ? 1'bz : ((0|g45249) ? 1'b0 : 1'bz);
// Gate A18-U222B
pullup(g45317);
assign #0.2  g45317 = rst ? 1'bz : ((0|g45316|g45318) ? 1'b0 : 1'bz);
// Gate A18-U117A
pullup(g45242);
assign #0.2  g45242 = rst ? 0 : ((0|F09D|g45238|g45241) ? 1'b0 : 1'bz);
// Gate A18-U218B
pullup(g45325);
assign #0.2  g45325 = rst ? 1'bz : ((0|g45323) ? 1'b0 : 1'bz);
// Gate A18-U224A
pullup(g45313);
assign #0.2  g45313 = rst ? 1'bz : ((0|g45314|g45312) ? 1'b0 : 1'bz);
// Gate A18-U222A
pullup(g45318);
assign #0.2  g45318 = rst ? 0 : ((0|g45317|CCH13) ? 1'b0 : 1'bz);
// Gate A18-U225A
pullup(g45314);
assign #0.2  g45314 = rst ? 0 : ((0|CCH13|g45313) ? 1'b0 : 1'bz);
// Gate A18-U119A A18-U126A
pullup(g45243);
assign #0.2  g45243 = rst ? 0 : ((0|F09A_|g45247|g45238|g45223) ? 1'b0 : 1'bz);
// Gate A18-U130B
pullup(g45201);
assign #0.2  g45201 = rst ? 1'bz : ((0|g45202|NKEY1) ? 1'b0 : 1'bz);
// Gate A18-U249A
pullup(g45430);
assign #0.2  g45430 = rst ? 0 : ((0|g45429|g45432) ? 1'b0 : 1'bz);
// Gate A18-U141B
pullup(STNDBY);
assign #0.2  STNDBY = rst ? 0 : ((0|g45154|g45152) ? 1'b0 : 1'bz);
// Gate A18-U132B
pullup(g45139);
assign #0.2  g45139 = rst ? 0 : ((0|g45138|CCH13) ? 1'b0 : 1'bz);
// Gate A18-U248A
pullup(g45429);
assign #0.2  g45429 = rst ? 0 : ((0|g45419|g45428|g45430) ? 1'b0 : 1'bz);
// Gate A18-U214B
pullup(LRRANG);
assign #0.2  LRRANG = rst ? 0 : ((0|g45325|g45313|g45317) ? 1'b0 : 1'bz);
// Gate A18-U259B
pullup(g45457);
assign #0.2  g45457 = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A18-U125B
pullup(g45209);
assign #0.2  g45209 = rst ? 1'bz : ((0|g45210|NKEY3) ? 1'b0 : 1'bz);
// Gate A18-U203A
pullup(HERB);
assign #0.2  HERB = rst ? 0 : ((0|TPOR_) ? 1'b0 : 1'bz);
// Gate A18-U204A
pullup(g45356);
assign #0.2  g45356 = rst ? 0 : ((0|g45311|g45305|g45355) ? 1'b0 : 1'bz);
// Gate A18-U237B
pullup(g45411);
assign #0.2  g45411 = rst ? 0 : ((0|g45410|g45408) ? 1'b0 : 1'bz);
// Gate A18-U124A
pullup(g45214);
assign #0.2  g45214 = rst ? 0 : ((0|g45223|g45213) ? 1'b0 : 1'bz);
// Gate A18-U156B
pullup(RCH15_);
assign #0.2  RCH15_ = rst ? 1'bz : ((0|g45122) ? 1'b0 : 1'bz);
// Gate A18-U159A
pullup(g45133);
assign #0.2  g45133 = rst ? 0 : ((0|g45126) ? 1'b0 : 1'bz);
// Gate A18-U118A
pullup(g45223);
assign #0.2  g45223 = rst ? 0 : ((0|g45221) ? 1'b0 : 1'bz);
// Gate A18-U129A
pullup(g45204);
assign #0.2  g45204 = rst ? 0 : ((0|g45201) ? 1'b0 : 1'bz);
// Gate A18-U143A
pullup(g45102);
assign #0.2  g45102 = rst ? 0 : ((0|g45101|g45123) ? 1'b0 : 1'bz);
// Gate A18-U156A
pullup(g45123);
assign #0.2  g45123 = rst ? 0 : ((0|g45121) ? 1'b0 : 1'bz);
// Gate A18-U143B
pullup(g45101);
assign #0.2  g45101 = rst ? 1'bz : ((0|g45102|MKEY1) ? 1'b0 : 1'bz);
// Gate A18-U245B
pullup(g45423);
assign #0.2  g45423 = rst ? 0 : ((0|g45422|g45425) ? 1'b0 : 1'bz);
// Gate A18-U127A
pullup(g45208);
assign #0.2  g45208 = rst ? 1'bz : ((0|g42205) ? 1'b0 : 1'bz);
// Gate A18-U103B
pullup(g45234);
assign #0.2  g45234 = rst ? 0 : ((0|g45233) ? 1'b0 : 1'bz);
// Gate A18-U240A
pullup(g45415);
assign #0.2  g45415 = rst ? 0 : ((0|g45405|g45414|g45416) ? 1'b0 : 1'bz);
// Gate A18-U138B
pullup(g45151);
assign #0.2  g45151 = rst ? 0 : ((0|g45150|g45142) ? 1'b0 : 1'bz);
// Gate A18-U103A
pullup(g45233);
assign #0.2  g45233 = rst ? 1'bz : ((0|MRKRST) ? 1'b0 : 1'bz);
// Gate A18-U137B
pullup(SBY);
assign #0.2  SBY = rst ? 0 : ((0|STNDBY_) ? 1'b0 : 1'bz);
// Gate A18-U131A
pullup(CH1311);
assign #0.2  CH1311 = rst ? 0 : ((0|RCH13_|g45138) ? 1'b0 : 1'bz);
// Gate A18-U221A
pullup(CH1301);
assign #0.2  CH1301 = rst ? 0 : ((0|RCH13_|g45317) ? 1'b0 : 1'bz);
// Gate A18-U230B
pullup(g45301);
assign #0.2  g45301 = rst ? 0 : ((0|WCH13_|CHWL04_) ? 1'b0 : 1'bz);
// Gate A18-U234A
pullup(g45405);
assign #0.2  g45405 = rst ? 0 : ((0|g45410|g45407|RADRPT) ? 1'b0 : 1'bz);
// Gate A18-U125A
pullup(g45210);
assign #0.2  g45210 = rst ? 0 : ((0|g45223|g45209) ? 1'b0 : 1'bz);
// Gate A18-U128A
pullup(g45206);
assign #0.2  g45206 = rst ? 1'bz : ((0|g45223|g42205) ? 1'b0 : 1'bz);
// Gate A18-U133A
pullup(F17A_);
assign #0.2  F17A_ = rst ? 1'bz : ((0|F17A) ? 1'b0 : 1'bz);
// Gate A18-U212B
pullup(g45337);
assign #0.2  g45337 = rst ? 1'bz : ((0|g45338|g45327) ? 1'b0 : 1'bz);
// Gate A18-U123A
pullup(g45213);
assign #0.2  g45213 = rst ? 1'bz : ((0|NKEY4|g45214) ? 1'b0 : 1'bz);
// Gate A18-U259A
pullup(g45453);
assign #0.2  g45453 = rst ? 0 : ((0|DLKRPT|g45447|g45451) ? 1'b0 : 1'bz);
// Gate A18-U147A
pullup(g45110);
assign #0.2  g45110 = rst ? 0 : ((0|g45123|g45109) ? 1'b0 : 1'bz);
// Gate A18-U227B
pullup(g45307);
assign #0.2  g45307 = rst ? 1'bz : ((0|g45308|g45306) ? 1'b0 : 1'bz);
// Gate A18-U147B
pullup(g45109);
assign #0.2  g45109 = rst ? 1'bz : ((0|g45110|MKEY3) ? 1'b0 : 1'bz);
// Gate A18-U232B
pullup(g45402);
assign #0.2  g45402 = rst ? 1'bz : ((0|g45403|F10AS0) ? 1'b0 : 1'bz);
// Gate A18-U233A A18-U234B
pullup(g45407);
assign #0.2  g45407 = rst ? 0 : ((0|g45405|RADRPT|g45401|g45408) ? 1'b0 : 1'bz);
// Gate A18-U153B A18-U154A
pullup(g45127);
assign #0.2  g45127 = rst ? 0 : ((0|g45123|F09A_|g45126|g45135) ? 1'b0 : 1'bz);
// Gate A18-U257A
pullup(g45452);
assign #0.2  g45452 = rst ? 0 : ((0|F10A|g45451) ? 1'b0 : 1'bz);
// Gate A18-U130A
pullup(g45202);
assign #0.2  g45202 = rst ? 0 : ((0|g45201|g45223) ? 1'b0 : 1'bz);
// Gate A18-U153A A18-U155A
pullup(g45126);
assign #0.2  g45126 = rst ? 1'bz : ((0|g45104|g45108|g45112|g45116|g45120) ? 1'b0 : 1'bz);
// Gate A18-U101B
pullup(RCH16_);
assign #0.2  RCH16_ = rst ? 1'bz : ((0|g45235) ? 1'b0 : 1'bz);
// Gate A18-U225B
pullup(CH1303);
assign #0.2  CH1303 = rst ? 0 : ((0|g45307|RCH13_) ? 1'b0 : 1'bz);
// Gate A18-U110B
pullup(g45229);
assign #0.2  g45229 = rst ? 1'bz : ((0|g45230|MRKREJ) ? 1'b0 : 1'bz);
// Gate A18-U109A
pullup(g45232);
assign #0.2  g45232 = rst ? 0 : ((0|g45229) ? 1'b0 : 1'bz);
// Gate A18-U257B
pullup(g45451);
assign #0.2  g45451 = rst ? 1'bz : ((0|g45452|DLKRPT) ? 1'b0 : 1'bz);
// Gate A18-U229B
pullup(CH1304);
assign #0.2  CH1304 = rst ? 0 : ((0|RCH13_|g45302) ? 1'b0 : 1'bz);
// Gate A18-U235A
pullup(g45409);
assign #0.2  g45409 = rst ? 0 : ((0|g45411|g45408) ? 1'b0 : 1'bz);
// Gate A18-U202A
pullup(g45355);
assign #0.2  g45355 = rst ? 1'bz : ((0|LRIN0) ? 1'b0 : 1'bz);
// Gate A18-U233B
pullup(CHOR16_);
assign #0.2  CHOR16_ = rst ? 1'bz : ((0|CH1116|CH1216|CH3316) ? 1'b0 : 1'bz);
// Gate A18-U112B
pullup(CH1606);
assign #0.2  CH1606 = rst ? 0 : ((0|g45225|g45236) ? 1'b0 : 1'bz);
// Gate A18-U109B
pullup(CH1607);
assign #0.2  CH1607 = rst ? 0 : ((0|g45229|g45236) ? 1'b0 : 1'bz);
// Gate A18-U121B
pullup(CH1604);
assign #0.2  CH1604 = rst ? 0 : ((0|g45213|g45236) ? 1'b0 : 1'bz);
// Gate A18-U120B
pullup(CH1605);
assign #0.2  CH1605 = rst ? 0 : ((0|g45217|g45236) ? 1'b0 : 1'bz);
// Gate A18-U127B
pullup(CH1602);
assign #0.2  CH1602 = rst ? 0 : ((0|g42205|g45236) ? 1'b0 : 1'bz);
// Gate A18-U123B
pullup(CH1603);
assign #0.2  CH1603 = rst ? 0 : ((0|g45209|g45236) ? 1'b0 : 1'bz);
// Gate A18-U129B
pullup(CH1601);
assign #0.2  CH1601 = rst ? 0 : ((0|g45236|g45201) ? 1'b0 : 1'bz);
// Gate A18-U158A
pullup(g45134);
assign #0.2  g45134 = rst ? 0 : ((0|g45121|g45133) ? 1'b0 : 1'bz);
// Gate A18-U215A
pullup(LRZVEL);
assign #0.2  LRZVEL = rst ? 0 : ((0|g45313|g45318|g45325) ? 1'b0 : 1'bz);
// Gate A18-U135B
pullup(g45143);
assign #0.2  g45143 = rst ? 0 : ((0|F17A_|g45141) ? 1'b0 : 1'bz);
// Gate A18-U215B
pullup(LRXVEL);
assign #0.2  LRXVEL = rst ? 0 : ((0|g45325|g45314|g45318) ? 1'b0 : 1'bz);
// Gate A18-U254B A18-U252B
pullup(CHOR12_);
assign #0.2  CHOR12_ = rst ? 1'bz : ((0|CH1112|CH1212|CHAT12|CHBT12) ? 1'b0 : 1'bz);
// Gate A18-U128B
pullup(g42205);
assign #0.2  g42205 = rst ? 0 : ((0|g45206|NKEY2) ? 1'b0 : 1'bz);
// Gate A18-U216A
pullup(LRYVEL);
assign #0.2  LRYVEL = rst ? 0 : ((0|g45317|g45314|g45325) ? 1'b0 : 1'bz);
// Gate A18-U155B
pullup(g45122);
assign #0.2  g45122 = rst ? 0 : ((0|XB5_|XT1_) ? 1'b0 : 1'bz);
// Gate A18-U112A
pullup(g45226);
assign #0.2  g45226 = rst ? 1'bz : ((0|g45225|g45234) ? 1'b0 : 1'bz);
// Gate A18-U236B
pullup(g45408);
assign #0.2  g45408 = rst ? 1'bz : ((0|g45409|g45407|g45401) ? 1'b0 : 1'bz);
// Gate A18-U258B
pullup(CH3312);
assign #0.2  CH3312 = rst ? 0 : ((0|g45455|RCH33_) ? 1'b0 : 1'bz);
// Gate A18-U157A
pullup(g45130);
assign #0.2  g45130 = rst ? 0 : ((0|F09D|g45126|g45129) ? 1'b0 : 1'bz);
// Gate A18-U137A
pullup(g45149);
assign #0.2  g45149 = rst ? 0 : ((0|g45142|g45138|STOP) ? 1'b0 : 1'bz);
// Gate A18-U157B
pullup(g45129);
assign #0.2  g45129 = rst ? 1'bz : ((0|g45130|g45127) ? 1'b0 : 1'bz);
// Gate A18-U223A
pullup(CH1302);
assign #0.2  CH1302 = rst ? 0 : ((0|RCH13_|g45313) ? 1'b0 : 1'bz);
// Gate A18-U219A
pullup(g45323);
assign #0.2  g45323 = rst ? 0 : ((0|g45311|g45320|F5BSB2_) ? 1'b0 : 1'bz);
// Gate A18-U209A
pullup(g45344);
assign #0.2  g45344 = rst ? 1'bz : ((0|g45339) ? 1'b0 : 1'bz);
// Gate A18-U208A
pullup(g45348);
assign #0.2  g45348 = rst ? 0 : ((0|g45336|g45305|g45347) ? 1'b0 : 1'bz);
// Gate A18-U160B
pullup(g45136);
assign #0.2  g45136 = rst ? 0 : ((0|KYRPT1|g45135) ? 1'b0 : 1'bz);
// Gate A18-U160A
pullup(g45135);
assign #0.2  g45135 = rst ? 1'bz : ((0|g45136|g45134) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
