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

parameter GATE_DELAY = 20; // This default may be overridden at compile time.
initial $display("Gate delay (A18) will be %f ns.", GATE_DELAY);

// Gate A18-U129A
pullup(g45204);
assign #GATE_DELAY g45204 = rst ? 0 : ((0|g45201) ? 1'b0 : 1'bz);
// Gate A18-U129B
pullup(CH1601);
assign #GATE_DELAY CH1601 = rst ? 0 : ((0|g45236|g45201) ? 1'b0 : 1'bz);
// Gate A18-U128A
pullup(g45206);
assign #GATE_DELAY g45206 = rst ? 0 : ((0|g45205|g45223) ? 1'b0 : 1'bz);
// Gate A18-U128B
pullup(g45205);
assign #GATE_DELAY g45205 = rst ? 1'bz : ((0|g45206|NKEY2) ? 1'b0 : 1'bz);
// Gate A18-U123A
pullup(g45213);
assign #GATE_DELAY g45213 = rst ? 1'bz : ((0|g45214|NKEY4) ? 1'b0 : 1'bz);
// Gate A18-U123B
pullup(CH1603);
assign #GATE_DELAY CH1603 = rst ? 0 : ((0|g45209|g45236) ? 1'b0 : 1'bz);
// Gate A18-U122A
pullup(g45218);
assign #GATE_DELAY g45218 = rst ? 0 : ((0|g45217|g45223) ? 1'b0 : 1'bz);
// Gate A18-U122B
pullup(g45216);
assign #GATE_DELAY g45216 = rst ? 0 : ((0|g45213) ? 1'b0 : 1'bz);
// Gate A18-U121A
pullup(g45217);
assign #GATE_DELAY g45217 = rst ? 1'bz : ((0|g45218|NKEY5) ? 1'b0 : 1'bz);
// Gate A18-U121B
pullup(CH1604);
assign #GATE_DELAY CH1604 = rst ? 0 : ((0|g45213|g45236) ? 1'b0 : 1'bz);
// Gate A18-U120A
pullup(g45220);
assign #GATE_DELAY g45220 = rst ? 0 : ((0|g45217) ? 1'b0 : 1'bz);
// Gate A18-U120B
pullup(CH1605);
assign #GATE_DELAY CH1605 = rst ? 0 : ((0|g45217|g45236) ? 1'b0 : 1'bz);
// Gate A18-U127A
pullup(g45208);
assign #GATE_DELAY g45208 = rst ? 0 : ((0|g45205) ? 1'b0 : 1'bz);
// Gate A18-U127B
pullup(CH1602);
assign #GATE_DELAY CH1602 = rst ? 0 : ((0|g45205|g45236) ? 1'b0 : 1'bz);
// Gate A18-U125A
pullup(g45210);
assign #GATE_DELAY g45210 = rst ? 1'bz : ((0|g45209|g45223) ? 1'b0 : 1'bz);
// Gate A18-U125B
pullup(g45209);
assign #GATE_DELAY g45209 = rst ? 0 : ((0|g45210|NKEY3) ? 1'b0 : 1'bz);
// Gate A18-U124A
pullup(g45214);
assign #GATE_DELAY g45214 = rst ? 0 : ((0|g45213|g45223) ? 1'b0 : 1'bz);
// Gate A18-U124B
pullup(g45212);
assign #GATE_DELAY g45212 = rst ? 1'bz : ((0|g45209) ? 1'b0 : 1'bz);
// Gate A18-U130A
pullup(g45202);
assign #GATE_DELAY g45202 = rst ? 0 : ((0|g45223|g45201) ? 1'b0 : 1'bz);
// Gate A18-U130B
pullup(g45201);
assign #GATE_DELAY g45201 = rst ? 1'bz : ((0|g45202|NKEY1) ? 1'b0 : 1'bz);
// Gate A18-U106A
pullup(F17B_);
assign #GATE_DELAY F17B_ = rst ? 1'bz : ((0|F17B) ? 1'b0 : 1'bz);
// Gate A18-U106B
pullup(TEMPIN_);
assign #GATE_DELAY TEMPIN_ = rst ? 1'bz : ((0|TEMPIN) ? 1'b0 : 1'bz);
// Gate A18-U109A
pullup(g45232);
assign #GATE_DELAY g45232 = rst ? 0 : ((0|g45229) ? 1'b0 : 1'bz);
// Gate A18-U109B
pullup(CH1607);
assign #GATE_DELAY CH1607 = rst ? 0 : ((0|g45229|g45236) ? 1'b0 : 1'bz);
// Gate A18-U108A
pullup(g45255);
assign #GATE_DELAY g45255 = rst ? 0 : ((0|g45249) ? 1'b0 : 1'bz);
// Gate A18-U108B A18-U142A
pullup(g45160);
assign #GATE_DELAY g45160 = rst ? 0 : ((0|g45249|g45257|F09A_|g45234) ? 1'b0 : 1'bz);
// Gate A18-U105A
pullup(g45256);
assign #GATE_DELAY g45256 = rst ? 0 : ((0|g45255|g45233) ? 1'b0 : 1'bz);
// Gate A18-U105B
pullup(MKRPT);
assign #GATE_DELAY MKRPT = rst ? 0 : ((0|g45251|TPOR_|F09B_) ? 1'b0 : 1'bz);
// Gate A18-U104A
pullup(g45259);
assign #GATE_DELAY g45259 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A18-U104B
pullup(g45258);
assign #GATE_DELAY g45258 = rst ? 0 : ((0|g45257|MKRPT) ? 1'b0 : 1'bz);
// Gate A18-U107A
pullup(g45251);
assign #GATE_DELAY g45251 = rst ? 1'bz : ((0|g45252|g45160) ? 1'b0 : 1'bz);
// Gate A18-U107B
pullup(g45252);
assign #GATE_DELAY g45252 = rst ? 0 : ((0|g45251|g45249|F09D) ? 1'b0 : 1'bz);
// Gate A18-U101A
pullup(g45236);
assign #GATE_DELAY g45236 = rst ? 1'bz : ((0|g45235) ? 1'b0 : 1'bz);
// Gate A18-U101B
pullup(RCH16_);
assign #GATE_DELAY RCH16_ = rst ? 1'bz : ((0|g45235) ? 1'b0 : 1'bz);
// Gate A18-U103A
pullup(g45233);
assign #GATE_DELAY g45233 = rst ? 1'bz : ((0|MRKRST) ? 1'b0 : 1'bz);
// Gate A18-U103B
pullup(g45234);
assign #GATE_DELAY g45234 = rst ? 0 : ((0|g45233) ? 1'b0 : 1'bz);
// Gate A18-U102A
pullup(g45257);
assign #GATE_DELAY g45257 = rst ? 1'bz : ((0|g45256|g45258) ? 1'b0 : 1'bz);
// Gate A18-U102B
pullup(g45235);
assign #GATE_DELAY g45235 = rst ? 0 : ((0|XT1_|XB6_) ? 1'b0 : 1'bz);
// Gate A18-U153A A18-U155A
pullup(g45126);
assign #GATE_DELAY g45126 = rst ? 1'bz : ((0|g45112|g45108|g45104|g45120|g45116) ? 1'b0 : 1'bz);
// Gate A18-U153B A18-U154A
pullup(g45127);
assign #GATE_DELAY g45127 = rst ? 0 : ((0|g45123|g45135|g45126|F09A_) ? 1'b0 : 1'bz);
// Gate A18-U112A
pullup(g45226);
assign #GATE_DELAY g45226 = rst ? 0 : ((0|g45234|g45225) ? 1'b0 : 1'bz);
// Gate A18-U112B
pullup(CH1606);
assign #GATE_DELAY CH1606 = rst ? 0 : ((0|g45225|g45236) ? 1'b0 : 1'bz);
// Gate A18-U113A
pullup(g45225);
assign #GATE_DELAY g45225 = rst ? 1'bz : ((0|g45226|MARK) ? 1'b0 : 1'bz);
// Gate A18-U113B
pullup(ERRST);
assign #GATE_DELAY ERRST = rst ? 0 : ((0|g45222) ? 1'b0 : 1'bz);
// Gate A18-U110A
pullup(g45230);
assign #GATE_DELAY g45230 = rst ? 0 : ((0|g45229|g45234) ? 1'b0 : 1'bz);
// Gate A18-U110B
pullup(g45229);
assign #GATE_DELAY g45229 = rst ? 1'bz : ((0|g45230|MRKREJ) ? 1'b0 : 1'bz);
// Gate A18-U111A
pullup(g45228);
assign #GATE_DELAY g45228 = rst ? 0 : ((0|g45225) ? 1'b0 : 1'bz);
// Gate A18-U111B
pullup(g45249);
assign #GATE_DELAY g45249 = rst ? 1'bz : ((0|g45232|g45228) ? 1'b0 : 1'bz);
// Gate A18-U116A
pullup(g45245);
assign #GATE_DELAY g45245 = rst ? 1'bz : ((0|g45238) ? 1'b0 : 1'bz);
// Gate A18-U116B
pullup(KYRPT2);
assign #GATE_DELAY KYRPT2 = rst ? 0 : ((0|g45241|F09B_|TPOR_) ? 1'b0 : 1'bz);
// Gate A18-U117A
pullup(g45242);
assign #GATE_DELAY g45242 = rst ? 0 : ((0|g45241|g45238|F09D) ? 1'b0 : 1'bz);
// Gate A18-U117B
pullup(g45241);
assign #GATE_DELAY g45241 = rst ? 1'bz : ((0|g45242|g45243) ? 1'b0 : 1'bz);
// Gate A18-U114A
pullup(g45222);
assign #GATE_DELAY g45222 = rst ? 1'bz : ((0|W1110|CAURST) ? 1'b0 : 1'bz);
// Gate A18-U114B
pullup(g45246);
assign #GATE_DELAY g45246 = rst ? 0 : ((0|g45245|g45221) ? 1'b0 : 1'bz);
// Gate A18-U115A
pullup(g45248);
assign #GATE_DELAY g45248 = rst ? 0 : ((0|g45247|KYRPT2) ? 1'b0 : 1'bz);
// Gate A18-U115B
pullup(g45247);
assign #GATE_DELAY g45247 = rst ? 1'bz : ((0|g45246|g45248) ? 1'b0 : 1'bz);
// Gate A18-U118A
pullup(g45223);
assign #GATE_DELAY g45223 = rst ? 0 : ((0|g45221) ? 1'b0 : 1'bz);
// Gate A18-U118B
pullup(g45221);
assign #GATE_DELAY g45221 = rst ? 1'bz : ((0|NAVRST) ? 1'b0 : 1'bz);
// Gate A18-U119A A18-U126A
pullup(g45243);
assign #GATE_DELAY g45243 = rst ? 0 : ((0|g45238|g45247|F09A_|g45223) ? 1'b0 : 1'bz);
// Gate A18-U119B A18-U126B
pullup(g45238);
assign #GATE_DELAY g45238 = rst ? 0 : ((0|g45220|g45216|g45212|g45208|g45204) ? 1'b0 : 1'bz);
// Gate A18-U142B
pullup(g45158);
assign #GATE_DELAY g45158 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A18-U160A
pullup(g45135);
assign #GATE_DELAY g45135 = rst ? 0 : ((0|g45134|g45136) ? 1'b0 : 1'bz);
// Gate A18-U160B
pullup(g45136);
assign #GATE_DELAY g45136 = rst ? 1'bz : ((0|KYRPT1|g45135) ? 1'b0 : 1'bz);
// Gate A18-U135A
pullup(g45145);
assign #GATE_DELAY g45145 = rst ? 1'bz : ((0|g45143|g45144) ? 1'b0 : 1'bz);
// Gate A18-U135B
pullup(g45143);
assign #GATE_DELAY g45143 = rst ? 0 : ((0|F17A_|g45141) ? 1'b0 : 1'bz);
// Gate A18-U137A
pullup(g45149);
assign #GATE_DELAY g45149 = rst ? 0 : ((0|STOP|g45138|g45142) ? 1'b0 : 1'bz);
// Gate A18-U137B
pullup(SBY);
assign #GATE_DELAY SBY = rst ? 0 : ((0|STNDBY_) ? 1'b0 : 1'bz);
// Gate A18-U136A
pullup(g45146);
assign #GATE_DELAY g45146 = rst ? 0 : ((0|g45141|g45142) ? 1'b0 : 1'bz);
// Gate A18-U136B
pullup(g45147);
assign #GATE_DELAY g45147 = rst ? 0 : ((0|g45145|F17B_) ? 1'b0 : 1'bz);
// Gate A18-U131A
pullup(CH1311);
assign #GATE_DELAY CH1311 = rst ? 0 : ((0|g45138|RCH13_) ? 1'b0 : 1'bz);
// Gate A18-U131B
pullup(g45137);
assign #GATE_DELAY g45137 = rst ? 0 : ((0|WCH13_|CHWL11_) ? 1'b0 : 1'bz);
// Gate A18-U133A
pullup(F17A_);
assign #GATE_DELAY F17A_ = rst ? 1'bz : ((0|F17A) ? 1'b0 : 1'bz);
// Gate A18-U133B
pullup(g45142);
assign #GATE_DELAY g45142 = rst ? 1'bz : ((0|g45146|g45147) ? 1'b0 : 1'bz);
// Gate A18-U132A
pullup(g45138);
assign #GATE_DELAY g45138 = rst ? 1'bz : ((0|g45137|g45139) ? 1'b0 : 1'bz);
// Gate A18-U132B
pullup(g45139);
assign #GATE_DELAY g45139 = rst ? 0 : ((0|g45138|CCH13) ? 1'b0 : 1'bz);
// Gate A18-U138A
pullup(g45150);
assign #GATE_DELAY g45150 = rst ? 1'bz : ((0|g45149|g45151) ? 1'b0 : 1'bz);
// Gate A18-U138B
pullup(g45151);
assign #GATE_DELAY g45151 = rst ? 0 : ((0|g45150|g45142) ? 1'b0 : 1'bz);
// Gate A18-U141A
pullup(g45154);
assign #GATE_DELAY g45154 = rst ? 1'bz : ((0|g45151|STNDBY) ? 1'b0 : 1'bz);
// Gate A18-U141B
pullup(STNDBY);
assign #GATE_DELAY STNDBY = rst ? 0 : ((0|g45154|g45152) ? 1'b0 : 1'bz);
// Gate A18-U140A
pullup(g45156);
assign #GATE_DELAY g45156 = rst ? 1'bz : ((0|STNDBY|ALTEST) ? 1'b0 : 1'bz);
// Gate A18-U140B
pullup(SBYLIT);
assign #GATE_DELAY SBYLIT = rst ? 0 : ((0|g45156) ? 1'b0 : 1'bz);
// Gate A18-U134A
pullup(g45141);
assign #GATE_DELAY g45141 = rst ? 1'bz : ((0|SBYBUT) ? 1'b0 : 1'bz);
// Gate A18-U134B
pullup(g45144);
assign #GATE_DELAY g45144 = rst ? 0 : ((0|g45141|g45145) ? 1'b0 : 1'bz);
// Gate A18-U149A
pullup(g45114);
assign #GATE_DELAY g45114 = rst ? 0 : ((0|g45113|g45123) ? 1'b0 : 1'bz);
// Gate A18-U149B
pullup(g45113);
assign #GATE_DELAY g45113 = rst ? 1'bz : ((0|g45114|MKEY4) ? 1'b0 : 1'bz);
// Gate A18-U148A
pullup(g45112);
assign #GATE_DELAY g45112 = rst ? 0 : ((0|g45109) ? 1'b0 : 1'bz);
// Gate A18-U148B
pullup(CH1503);
assign #GATE_DELAY CH1503 = rst ? 0 : ((0|g45109|RCH15_) ? 1'b0 : 1'bz);
// Gate A18-U143A
pullup(g45102);
assign #GATE_DELAY g45102 = rst ? 0 : ((0|g45123|g45101) ? 1'b0 : 1'bz);
// Gate A18-U143B
pullup(g45101);
assign #GATE_DELAY g45101 = rst ? 1'bz : ((0|g45102|MKEY1) ? 1'b0 : 1'bz);
// Gate A18-U145A
pullup(g45106);
assign #GATE_DELAY g45106 = rst ? 0 : ((0|g45105|g45123) ? 1'b0 : 1'bz);
// Gate A18-U145B
pullup(g45105);
assign #GATE_DELAY g45105 = rst ? 1'bz : ((0|g45106|MKEY2) ? 1'b0 : 1'bz);
// Gate A18-U144A
pullup(g45104);
assign #GATE_DELAY g45104 = rst ? 0 : ((0|g45101) ? 1'b0 : 1'bz);
// Gate A18-U144B
pullup(CH1501);
assign #GATE_DELAY CH1501 = rst ? 0 : ((0|g45101|RCH15_) ? 1'b0 : 1'bz);
// Gate A18-U147A
pullup(g45110);
assign #GATE_DELAY g45110 = rst ? 0 : ((0|g45109|g45123) ? 1'b0 : 1'bz);
// Gate A18-U147B
pullup(g45109);
assign #GATE_DELAY g45109 = rst ? 1'bz : ((0|g45110|MKEY3) ? 1'b0 : 1'bz);
// Gate A18-U146A
pullup(g45108);
assign #GATE_DELAY g45108 = rst ? 0 : ((0|g45105) ? 1'b0 : 1'bz);
// Gate A18-U146B
pullup(CH1502);
assign #GATE_DELAY CH1502 = rst ? 0 : ((0|g45105|RCH15_) ? 1'b0 : 1'bz);
// Gate A18-U139A
pullup(STNDBY_);
assign #GATE_DELAY STNDBY_ = rst ? 1'bz : ((0|STNDBY) ? 1'b0 : 1'bz);
// Gate A18-U139B
pullup(g45152);
assign #GATE_DELAY g45152 = rst ? 0 : ((0|g45151|g45142) ? 1'b0 : 1'bz);
// Gate A18-U158A
pullup(g45134);
assign #GATE_DELAY g45134 = rst ? 0 : ((0|g45133|g45121) ? 1'b0 : 1'bz);
// Gate A18-U158B
pullup(TPOR_);
assign #GATE_DELAY TPOR_ = rst ? 1'bz : ((0|T05|T11) ? 1'b0 : 1'bz);
// Gate A18-U159A
pullup(g45133);
assign #GATE_DELAY g45133 = rst ? 0 : ((0|g45126) ? 1'b0 : 1'bz);
// Gate A18-U159B
pullup(KYRPT1);
assign #GATE_DELAY KYRPT1 = rst ? 0 : ((0|g45129|TPOR_|F09B_) ? 1'b0 : 1'bz);
// Gate A18-U156A
pullup(g45123);
assign #GATE_DELAY g45123 = rst ? 0 : ((0|g45121) ? 1'b0 : 1'bz);
// Gate A18-U156B
pullup(RCH15_);
assign #GATE_DELAY RCH15_ = rst ? 1'bz : ((0|g45122) ? 1'b0 : 1'bz);
// Gate A18-U157A
pullup(g45130);
assign #GATE_DELAY g45130 = rst ? 0 : ((0|g45129|g45126|F09D) ? 1'b0 : 1'bz);
// Gate A18-U157B
pullup(g45129);
assign #GATE_DELAY g45129 = rst ? 1'bz : ((0|g45130|g45127) ? 1'b0 : 1'bz);
// Gate A18-U154B
pullup(g45121);
assign #GATE_DELAY g45121 = rst ? 1'bz : ((0|MAINRS) ? 1'b0 : 1'bz);
// Gate A18-U155B
pullup(g45122);
assign #GATE_DELAY g45122 = rst ? 0 : ((0|XB5_|XT1_) ? 1'b0 : 1'bz);
// Gate A18-U152A
pullup(g45120);
assign #GATE_DELAY g45120 = rst ? 0 : ((0|g45117) ? 1'b0 : 1'bz);
// Gate A18-U152B
pullup(CH1505);
assign #GATE_DELAY CH1505 = rst ? 0 : ((0|g45117|RCH15_) ? 1'b0 : 1'bz);
// Gate A18-U150A
pullup(g45116);
assign #GATE_DELAY g45116 = rst ? 0 : ((0|g45113) ? 1'b0 : 1'bz);
// Gate A18-U150B
pullup(CH1504);
assign #GATE_DELAY CH1504 = rst ? 0 : ((0|g45113|RCH15_) ? 1'b0 : 1'bz);
// Gate A18-U151A
pullup(g45118);
assign #GATE_DELAY g45118 = rst ? 0 : ((0|g45117|g45123) ? 1'b0 : 1'bz);
// Gate A18-U151B
pullup(g45117);
assign #GATE_DELAY g45117 = rst ? 1'bz : ((0|g45118|MKEY5) ? 1'b0 : 1'bz);
// Gate A18-U229A
pullup(g45303);
assign #GATE_DELAY g45303 = rst ? 0 : ((0|CCH13|RADRPT|g45302) ? 1'b0 : 1'bz);
// Gate A18-U229B
pullup(CH1304);
assign #GATE_DELAY CH1304 = rst ? 0 : ((0|RCH13_|g45302) ? 1'b0 : 1'bz);
// Gate A18-U228A
pullup(g45305);
assign #GATE_DELAY g45305 = rst ? 1'bz : ((0|g45303) ? 1'b0 : 1'bz);
// Gate A18-U228B
pullup(g45306);
assign #GATE_DELAY g45306 = rst ? 0 : ((0|WCH13_|CHWL03_) ? 1'b0 : 1'bz);
// Gate A18-U223A
pullup(CH1302);
assign #GATE_DELAY CH1302 = rst ? 0 : ((0|g45313|RCH13_) ? 1'b0 : 1'bz);
// Gate A18-U223B
pullup(g45316);
assign #GATE_DELAY g45316 = rst ? 0 : ((0|CHWL01_|WCH13_) ? 1'b0 : 1'bz);
// Gate A18-U222A
pullup(g45318);
assign #GATE_DELAY g45318 = rst ? 0 : ((0|CCH13|g45317) ? 1'b0 : 1'bz);
// Gate A18-U222B
pullup(g45317);
assign #GATE_DELAY g45317 = rst ? 1'bz : ((0|g45316|g45318) ? 1'b0 : 1'bz);
// Gate A18-U221A
pullup(CH1301);
assign #GATE_DELAY CH1301 = rst ? 0 : ((0|g45317|RCH13_) ? 1'b0 : 1'bz);
// Gate A18-U221B
pullup(g45320);
assign #GATE_DELAY g45320 = rst ? 1'bz : ((0|g45321|g45404) ? 1'b0 : 1'bz);
// Gate A18-U220A
pullup(g45322);
assign #GATE_DELAY g45322 = rst ? 0 : ((0|F5BSB2_|g45320|g45310) ? 1'b0 : 1'bz);
// Gate A18-U220B
pullup(g45321);
assign #GATE_DELAY g45321 = rst ? 0 : ((0|CNTOF9|GOJAM|g45320) ? 1'b0 : 1'bz);
// Gate A18-U227A
pullup(g45308);
assign #GATE_DELAY g45308 = rst ? 0 : ((0|g45307|CCH13) ? 1'b0 : 1'bz);
// Gate A18-U227B
pullup(g45307);
assign #GATE_DELAY g45307 = rst ? 1'bz : ((0|g45308|g45306) ? 1'b0 : 1'bz);
// Gate A18-U226A
pullup(g45311);
assign #GATE_DELAY g45311 = rst ? 1'bz : ((0|g45308) ? 1'b0 : 1'bz);
// Gate A18-U226B
pullup(g45310);
assign #GATE_DELAY g45310 = rst ? 0 : ((0|g45307) ? 1'b0 : 1'bz);
// Gate A18-U225A
pullup(g45314);
assign #GATE_DELAY g45314 = rst ? 0 : ((0|g45313|CCH13) ? 1'b0 : 1'bz);
// Gate A18-U225B
pullup(CH1303);
assign #GATE_DELAY CH1303 = rst ? 0 : ((0|g45307|RCH13_) ? 1'b0 : 1'bz);
// Gate A18-U224A
pullup(g45313);
assign #GATE_DELAY g45313 = rst ? 1'bz : ((0|g45312|g45314) ? 1'b0 : 1'bz);
// Gate A18-U224B
pullup(g45312);
assign #GATE_DELAY g45312 = rst ? 0 : ((0|WCH13_|CHWL02_) ? 1'b0 : 1'bz);
// Gate A18-U233A A18-U234B
pullup(g45407);
assign #GATE_DELAY g45407 = rst ? 1'bz : ((0|RADRPT|g45405|g45404|g45408) ? 1'b0 : 1'bz);
// Gate A18-U233B
pullup(CHOR16_);
assign #GATE_DELAY CHOR16_ = rst ? 1'bz : ((0|CH1116|CH1216|CH3316) ? 1'b0 : 1'bz);
// Gate A18-U238A A18-U239A
pullup(g45414);
assign #GATE_DELAY g45414 = rst ? 1'bz : ((0|g45412|RADRPT|g45415|g45405) ? 1'b0 : 1'bz);
// Gate A18-U238B A18-U247B
pullup(CHOR14_);
assign #GATE_DELAY CHOR14_ = rst ? 1'bz : ((0|CHBT14|CH3314|CHAT14|CH1114) ? 1'b0 : 1'bz);
// Gate A18-U239B
pullup(CH14);
assign #GATE_DELAY CH14 = rst ? 0 : ((0|CHOR14_|RCHG_) ? 1'b0 : 1'bz);
// Gate A18-U230A
pullup(g45302);
assign #GATE_DELAY g45302 = rst ? 1'bz : ((0|g45303|g45301) ? 1'b0 : 1'bz);
// Gate A18-U230B
pullup(g45301);
assign #GATE_DELAY g45301 = rst ? 0 : ((0|WCH13_|CHWL04_) ? 1'b0 : 1'bz);
// Gate A18-U231A
pullup(g45404);
assign #GATE_DELAY g45404 = rst ? 0 : ((0|F10A_|g45402|SB2_) ? 1'b0 : 1'bz);
// Gate A18-U231B
pullup(F10AS0);
assign #GATE_DELAY F10AS0 = rst ? 0 : ((0|F10A_|SB0_) ? 1'b0 : 1'bz);
// Gate A18-U232A
pullup(g45403);
assign #GATE_DELAY g45403 = rst ? 0 : ((0|g45402|g45302) ? 1'b0 : 1'bz);
// Gate A18-U232B
pullup(g45402);
assign #GATE_DELAY g45402 = rst ? 1'bz : ((0|g45403|F10AS0) ? 1'b0 : 1'bz);
// Gate A18-U234A
pullup(g45405);
assign #GATE_DELAY g45405 = rst ? 0 : ((0|RADRPT|g45407|g45410) ? 1'b0 : 1'bz);
// Gate A18-U235A
pullup(g45409);
assign #GATE_DELAY g45409 = rst ? 0 : ((0|g45408|g45411) ? 1'b0 : 1'bz);
// Gate A18-U235B
pullup(CH16);
assign #GATE_DELAY CH16 = rst ? 0 : ((0|CHOR16_|RCHG_) ? 1'b0 : 1'bz);
// Gate A18-U236A
pullup(g45410);
assign #GATE_DELAY g45410 = rst ? 0 : ((0|g45411|g45407) ? 1'b0 : 1'bz);
// Gate A18-U236B
pullup(g45408);
assign #GATE_DELAY g45408 = rst ? 0 : ((0|g45409|g45407|g45404) ? 1'b0 : 1'bz);
// Gate A18-U237A
pullup(g45412);
assign #GATE_DELAY g45412 = rst ? 0 : ((0|g45417|g45414) ? 1'b0 : 1'bz);
// Gate A18-U237B
pullup(g45411);
assign #GATE_DELAY g45411 = rst ? 1'bz : ((0|g45410|g45408) ? 1'b0 : 1'bz);
// Gate A18-U247A A18-U248B
pullup(g45428);
assign #GATE_DELAY g45428 = rst ? 1'bz : ((0|g45426|RADRPT|g45419|g45429) ? 1'b0 : 1'bz);
// Gate A18-U243A A18-U242A
pullup(g45421);
assign #GATE_DELAY g45421 = rst ? 1'bz : ((0|g45419|RADRPT|g45422|g45412) ? 1'b0 : 1'bz);
// Gate A18-U243B
pullup(CHOR13_);
assign #GATE_DELAY CHOR13_ = rst ? 1'bz : ((0|CH3313|CHBT13|CHAT13) ? 1'b0 : 1'bz);
// Gate A18-U209A
pullup(g45344);
assign #GATE_DELAY g45344 = rst ? 1'bz : ((0|g45339) ? 1'b0 : 1'bz);
// Gate A18-U209B A18-U210A
pullup(RADRPT);
assign #GATE_DELAY RADRPT = rst ? 0 : ((0|GTRST_|TPORA_|g45340) ? 1'b0 : 1'bz);
// Gate A18-U208A
pullup(g45348);
assign #GATE_DELAY g45348 = rst ? 0 : ((0|g45347|g45305|g45336) ? 1'b0 : 1'bz);
// Gate A18-U208B
pullup(LRSYNC);
assign #GATE_DELAY LRSYNC = rst ? 0 : ((0|g45344|g45311) ? 1'b0 : 1'bz);
// Gate A18-U205A
pullup(g45350);
assign #GATE_DELAY g45350 = rst ? 0 : ((0|g45349|g45305|g45336) ? 1'b0 : 1'bz);
// Gate A18-U205B
pullup(g45349);
assign #GATE_DELAY g45349 = rst ? 1'bz : ((0|RRIN0) ? 1'b0 : 1'bz);
// Gate A18-U204A
pullup(g45356);
assign #GATE_DELAY g45356 = rst ? 0 : ((0|g45355|g45305|g45311) ? 1'b0 : 1'bz);
// Gate A18-U204B
pullup(RNRADP);
assign #GATE_DELAY RNRADP = rst ? 0 : ((0|g45351) ? 1'b0 : 1'bz);
// Gate A18-U207A
pullup(g45351);
assign #GATE_DELAY g45351 = rst ? 1'bz : ((0|g45354|g45348) ? 1'b0 : 1'bz);
// Gate A18-U207B
pullup(RRSYNC);
assign #GATE_DELAY RRSYNC = rst ? 0 : ((0|g45344|g45336) ? 1'b0 : 1'bz);
// Gate A18-U206A
pullup(g45354);
assign #GATE_DELAY g45354 = rst ? 0 : ((0|g45353|g45305|g45311) ? 1'b0 : 1'bz);
// Gate A18-U206B
pullup(g45347);
assign #GATE_DELAY g45347 = rst ? 1'bz : ((0|RRIN1) ? 1'b0 : 1'bz);
// Gate A18-U201A
pullup(g45357);
assign #GATE_DELAY g45357 = rst ? 1'bz : ((0|g45350|g45356) ? 1'b0 : 1'bz);
// Gate A18-U201B
pullup(TPORA_);
assign #GATE_DELAY TPORA_ = rst ? 1'bz : ((0|HERB) ? 1'b0 : 1'bz);
// Gate A18-U203A
pullup(HERB);
assign #GATE_DELAY HERB = rst ? 0 : ((0|TPOR_) ? 1'b0 : 1'bz);
// Gate A18-U203B
pullup(g45353);
assign #GATE_DELAY g45353 = rst ? 1'bz : ((0|LRIN1) ? 1'b0 : 1'bz);
// Gate A18-U202A
pullup(g45355);
assign #GATE_DELAY g45355 = rst ? 1'bz : ((0|LRIN0) ? 1'b0 : 1'bz);
// Gate A18-U202B
pullup(RNRADM);
assign #GATE_DELAY RNRADM = rst ? 0 : ((0|g45357) ? 1'b0 : 1'bz);
// Gate A18-U254B A18-U252B
pullup(CHOR12_);
assign #GATE_DELAY CHOR12_ = rst ? 1'bz : ((0|CH1112|CH1212|CHAT12|CHBT12) ? 1'b0 : 1'bz);
// Gate A18-U250A A18-U251A
pullup(CNTOF9);
assign #GATE_DELAY CNTOF9 = rst ? 0 : ((0|g45431|g45425|F10A|g45418|g45410) ? 1'b0 : 1'bz);
// Gate A18-U250B A18-U252A
pullup(CHOR11_);
assign #GATE_DELAY CHOR11_ = rst ? 1'bz : ((0|CHAT11|CHBT11|CH1111|CH1211|CH3311) ? 1'b0 : 1'bz);
// Gate A18-U212A
pullup(g45338);
assign #GATE_DELAY g45338 = rst ? 0 : ((0|g45337|GOJAM|RADRPT) ? 1'b0 : 1'bz);
// Gate A18-U212B
pullup(g45337);
assign #GATE_DELAY g45337 = rst ? 1'bz : ((0|g45338|g45327) ? 1'b0 : 1'bz);
// Gate A18-U213A
pullup(g45335);
assign #GATE_DELAY g45335 = rst ? 0 : ((0|g45334|g45310) ? 1'b0 : 1'bz);
// Gate A18-U213B
pullup(g45336);
assign #GATE_DELAY g45336 = rst ? 1'bz : ((0|g45335) ? 1'b0 : 1'bz);
// Gate A18-U210B
pullup(g45341);
assign #GATE_DELAY g45341 = rst ? 0 : ((0|g45340|F09B|GOJAM) ? 1'b0 : 1'bz);
// Gate A18-U211A
pullup(g45340);
assign #GATE_DELAY g45340 = rst ? 1'bz : ((0|g45341|g45339) ? 1'b0 : 1'bz);
// Gate A18-U211B
pullup(g45339);
assign #GATE_DELAY g45339 = rst ? 0 : ((0|g45337|F5ASB2_) ? 1'b0 : 1'bz);
// Gate A18-U216A
pullup(LRYVEL);
assign #GATE_DELAY LRYVEL = rst ? 0 : ((0|g45325|g45314|g45317) ? 1'b0 : 1'bz);
// Gate A18-U216B
pullup(RRRANG);
assign #GATE_DELAY RRRANG = rst ? 0 : ((0|g45314|g45324|g45317) ? 1'b0 : 1'bz);
// Gate A18-U217A
pullup(g45327);
assign #GATE_DELAY g45327 = rst ? 0 : ((0|GTSET_|g45326) ? 1'b0 : 1'bz);
// Gate A18-U217B
pullup(RRRARA);
assign #GATE_DELAY RRRARA = rst ? 0 : ((0|g45324|g45313|g45318) ? 1'b0 : 1'bz);
// Gate A18-U214A
pullup(g45334);
assign #GATE_DELAY g45334 = rst ? 1'bz : ((0|g45314|g45318) ? 1'b0 : 1'bz);
// Gate A18-U214B
pullup(LRRANG);
assign #GATE_DELAY LRRANG = rst ? 0 : ((0|g45325|g45313|g45317) ? 1'b0 : 1'bz);
// Gate A18-U215A
pullup(LRZVEL);
assign #GATE_DELAY LRZVEL = rst ? 0 : ((0|g45325|g45318|g45313) ? 1'b0 : 1'bz);
// Gate A18-U215B
pullup(LRXVEL);
assign #GATE_DELAY LRXVEL = rst ? 0 : ((0|g45325|g45314|g45318) ? 1'b0 : 1'bz);
// Gate A18-U218A
pullup(g45326);
assign #GATE_DELAY g45326 = rst ? 1'bz : ((0|CNTOF9) ? 1'b0 : 1'bz);
// Gate A18-U218B
pullup(g45325);
assign #GATE_DELAY g45325 = rst ? 1'bz : ((0|g45323) ? 1'b0 : 1'bz);
// Gate A18-U219A
pullup(g45323);
assign #GATE_DELAY g45323 = rst ? 0 : ((0|F5BSB2_|g45320|g45311) ? 1'b0 : 1'bz);
// Gate A18-U219B
pullup(g45324);
assign #GATE_DELAY g45324 = rst ? 1'bz : ((0|g45322) ? 1'b0 : 1'bz);
// Gate A18-U260B
pullup(g45454);
assign #GATE_DELAY g45454 = rst ? 0 : ((0|g45453|g45455) ? 1'b0 : 1'bz);
// Gate A18-U249A
pullup(g45430);
assign #GATE_DELAY g45430 = rst ? 0 : ((0|g45432|g45429) ? 1'b0 : 1'bz);
// Gate A18-U249B
pullup(g45431);
assign #GATE_DELAY g45431 = rst ? 0 : ((0|g45428|g45432) ? 1'b0 : 1'bz);
// Gate A18-U248A
pullup(g45429);
assign #GATE_DELAY g45429 = rst ? 0 : ((0|g45430|g45428|g45419) ? 1'b0 : 1'bz);
// Gate A18-U241A
pullup(g45417);
assign #GATE_DELAY g45417 = rst ? 0 : ((0|g45414|g45418) ? 1'b0 : 1'bz);
// Gate A18-U241B
pullup(g45418);
assign #GATE_DELAY g45418 = rst ? 1'bz : ((0|g45415|g45417) ? 1'b0 : 1'bz);
// Gate A18-U240A
pullup(g45415);
assign #GATE_DELAY g45415 = rst ? 0 : ((0|g45416|g45414|g45405) ? 1'b0 : 1'bz);
// Gate A18-U240B
pullup(g45416);
assign #GATE_DELAY g45416 = rst ? 0 : ((0|g45418|g45415) ? 1'b0 : 1'bz);
// Gate A18-U242B
pullup(g45419);
assign #GATE_DELAY g45419 = rst ? 0 : ((0|g45424|g45421) ? 1'b0 : 1'bz);
// Gate A18-U245A
pullup(g45424);
assign #GATE_DELAY g45424 = rst ? 0 : ((0|g45421|g45425) ? 1'b0 : 1'bz);
// Gate A18-U245B
pullup(g45423);
assign #GATE_DELAY g45423 = rst ? 0 : ((0|g45422|g45425) ? 1'b0 : 1'bz);
// Gate A18-U244A
pullup(g45422);
assign #GATE_DELAY g45422 = rst ? 0 : ((0|g45412|g45421|g45423) ? 1'b0 : 1'bz);
// Gate A18-U244B
pullup(CH13);
assign #GATE_DELAY CH13 = rst ? 0 : ((0|CHOR13_|RCHG_) ? 1'b0 : 1'bz);
// Gate A18-U246A
pullup(g45425);
assign #GATE_DELAY g45425 = rst ? 1'bz : ((0|g45424|g45422) ? 1'b0 : 1'bz);
// Gate A18-U246B
pullup(g45426);
assign #GATE_DELAY g45426 = rst ? 0 : ((0|g45431|g45428) ? 1'b0 : 1'bz);
// Gate A18-U258A
pullup(g45455);
assign #GATE_DELAY g45455 = rst ? 1'bz : ((0|g45454|CCH33) ? 1'b0 : 1'bz);
// Gate A18-U258B
pullup(CH3312);
assign #GATE_DELAY CH3312 = rst ? 0 : ((0|g45455|RCH33_) ? 1'b0 : 1'bz);
// Gate A18-U259A
pullup(g45453);
assign #GATE_DELAY g45453 = rst ? 0 : ((0|g45451|g45447|DLKRPT) ? 1'b0 : 1'bz);
// Gate A18-U259B
pullup(g45457);
assign #GATE_DELAY g45457 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A18-U256A
pullup(g45450);
assign #GATE_DELAY g45450 = rst ? 0 : ((0|DLKRPT|g45451) ? 1'b0 : 1'bz);
// Gate A18-U256B
pullup(DLKRPT);
assign #GATE_DELAY DLKRPT = rst ? 0 : ((0|g45450|g45447) ? 1'b0 : 1'bz);
// Gate A18-U257A
pullup(g45452);
assign #GATE_DELAY g45452 = rst ? 0 : ((0|g45451|F10A) ? 1'b0 : 1'bz);
// Gate A18-U257B
pullup(g45451);
assign #GATE_DELAY g45451 = rst ? 1'bz : ((0|g45452|DLKRPT) ? 1'b0 : 1'bz);
// Gate A18-U255A
pullup(END);
assign #GATE_DELAY END = rst ? 0 : ((0|g45447) ? 1'b0 : 1'bz);
// Gate A18-U255B
pullup(g45447);
assign #GATE_DELAY g45447 = rst ? 1'bz : ((0|DKEND) ? 1'b0 : 1'bz);
// Gate A18-U253A
pullup(CH11);
assign #GATE_DELAY CH11 = rst ? 0 : ((0|CHOR11_|RCHG_) ? 1'b0 : 1'bz);
// Gate A18-U253B
pullup(CH12);
assign #GATE_DELAY CH12 = rst ? 0 : ((0|RCHG_|CHOR12_) ? 1'b0 : 1'bz);
// Gate A18-U251B
pullup(g45432);
assign #GATE_DELAY g45432 = rst ? 1'bz : ((0|g45429|g45431) ? 1'b0 : 1'bz);
// End of NOR gates


endmodule
