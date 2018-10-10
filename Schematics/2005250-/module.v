// Verilog module auto-generated for AGC module A21 by dumbVerilog.py

module A21 ( 
  rst, ALTM, BMAGXM, BMAGXP, BMAGYM, BMAGYP, BMAGZM, BMAGZP, C24A, C25A,
  C26A, C27A, C30A, C31A, C32A, C33A, C34A, C35A, C36A, C37A, C40A, C41A,
  C50A, C51A, C52A, C53A, C54A, C55A, CA6_, CG13, CG23, CGA21, CT, CXB2_,
  CXB3_, CXB4_, CXB7_, DOSCAL, EMSD, FS17, GNHNC, GOJAM, GYROD, INLNKM, INLNKP,
  MLDCH, MLOAD, MNHNC, MRDCH, MREAD, NISQL_, OCTAD4, OCTAD5, OTLNKM, PHS2_,
  PHS3_, PHS4_, PSEUDO, RNRADM, RNRADP, RQ, RSCT_, ST0_, ST1_, STD2, T02_,
  T07_, T10_, T11_, T12A, T12_, XB0, XB5, XB6, BKTF_, C42A, C43A, C44A, C45A,
  C45M, C45P, C46A, C46M, C46P, C47A, C56A, C57A, C60A, CA4_, CA5_, CG15,
  CG16, CHINC, CHINC_, CTROR_, CXB0_, CXB5_, CXB6_, DINC, INCSET_, INKBT1,
  INOTLD, INOTRD, MINKL, MREQIN, RSSB, SCAS17, d32004K, C42M, C42P, C42R,
  C43M, C43P, C43R, C44M, C44P, C44R, C45R, C46R, C47R, C56R, C57R, C60R,
  CAD1, CAD2, CAD3, CAD4, CAD5, CAD6, CG26, CTROR, DINCNC_, DINC_, FETCH0,
  FETCH0_, FETCH1, INKL, INKL_, MON_, MONpCH, RQ_, SHANC, SHANC_, SHINC,
  SHINC_, STFET1_, STORE1, STORE1_, d30SUM, d50SUM
);

input wire rst, ALTM, BMAGXM, BMAGXP, BMAGYM, BMAGYP, BMAGZM, BMAGZP, C24A,
  C25A, C26A, C27A, C30A, C31A, C32A, C33A, C34A, C35A, C36A, C37A, C40A,
  C41A, C50A, C51A, C52A, C53A, C54A, C55A, CA6_, CG13, CG23, CGA21, CT,
  CXB2_, CXB3_, CXB4_, CXB7_, DOSCAL, EMSD, FS17, GNHNC, GOJAM, GYROD, INLNKM,
  INLNKP, MLDCH, MLOAD, MNHNC, MRDCH, MREAD, NISQL_, OCTAD4, OCTAD5, OTLNKM,
  PHS2_, PHS3_, PHS4_, PSEUDO, RNRADM, RNRADP, RQ, RSCT_, ST0_, ST1_, STD2,
  T02_, T07_, T10_, T11_, T12A, T12_, XB0, XB5, XB6;

inout wire BKTF_, C42A, C43A, C44A, C45A, C45M, C45P, C46A, C46M, C46P, C47A,
  C56A, C57A, C60A, CA4_, CA5_, CG15, CG16, CHINC, CHINC_, CTROR_, CXB0_,
  CXB5_, CXB6_, DINC, INCSET_, INKBT1, INOTLD, INOTRD, MINKL, MREQIN, RSSB,
  SCAS17, d32004K;

output wire C42M, C42P, C42R, C43M, C43P, C43R, C44M, C44P, C44R, C45R, C46R,
  C47R, C56R, C57R, C60R, CAD1, CAD2, CAD3, CAD4, CAD5, CAD6, CG26, CTROR,
  DINCNC_, DINC_, FETCH0, FETCH0_, FETCH1, INKL, INKL_, MON_, MONpCH, RQ_,
  SHANC, SHANC_, SHINC, SHINC_, STFET1_, STORE1, STORE1_, d30SUM, d50SUM;

// Gate A21-U143A
pullup(g32007);
assign #0.2  g32007 = rst ? 1'bz : ((0|d30SUM|d50SUM) ? 1'b0 : 1'bz);
// Gate A21-U118B
pullup(INOTLD);
assign #0.2  INOTLD = rst ? 0 : ((0|g32233|g32222) ? 1'b0 : 1'bz);
// Gate A21-U255B
pullup(g32559);
assign #0.2  g32559 = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A21-U209B
pullup(C47A);
assign #0.2  C47A = rst ? 0 : ((0|g32633|CG16|g32646) ? 1'b0 : 1'bz);
// Gate A21-U225B
pullup(g32631);
assign #0.2  g32631 = rst ? 0 : ((0|g32601|g32638) ? 1'b0 : 1'bz);
// Gate A21-U149B A21-U150B A21-U157B A21-U159B A21-U155B
pullup(g32021);
assign #0.2  g32021 = rst ? 1'bz : ((0|C57A|C55A|C53A|C47A|C51A|C33A|C35A|C37A|C31A|C27A|C25A|C45A|C43A|C41A) ? 1'b0 : 1'bz);
// Gate A21-U242A
pullup(C57A);
assign #0.2  C57A = rst ? 0 : ((0|CG23|g32539|g32533) ? 1'b0 : 1'bz);
// Gate A21-U250A
pullup(g32547);
assign #0.2  g32547 = rst ? 1'bz : ((0|C60R|g32546) ? 1'b0 : 1'bz);
// Gate A21-U116B
pullup(INOTRD);
assign #0.2  INOTRD = rst ? 0 : ((0|g32233|g32226) ? 1'b0 : 1'bz);
// Gate A21-U214B
pullup(C47R);
assign #0.2  C47R = rst ? 0 : ((0|g32611|CXB7_|CA4_) ? 1'b0 : 1'bz);
// Gate A21-U137A A21-U138A A21-U139B
pullup(g32056);
assign #0.2  g32056 = rst ? 1'bz : ((0|C45M|C46M|C57A|C60A) ? 1'b0 : 1'bz);
// Gate A21-U229A
pullup(g32603);
assign #0.2  g32603 = rst ? 0 : ((0|g32602|C44R) ? 1'b0 : 1'bz);
// Gate A21-U203A
pullup(g32625);
assign #0.2  g32625 = rst ? 0 : ((0|C45R|g32624) ? 1'b0 : 1'bz);
// Gate A21-U211B
pullup(g32648);
assign #0.2  g32648 = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A21-U258A A21-U259A
pullup(CXB5_);
assign #0.2  CXB5_ = rst ? 1'bz : ((0|XB5) ? 1'b0 : 1'bz);
// Gate A21-U256A A21-U257A
pullup(CA5_);
assign #0.2  CA5_ = rst ? 1'bz : ((0|OCTAD5) ? 1'b0 : 1'bz);
// Gate A21-U156A A21-U158A A21-U155A
pullup(d32004K);
assign #0.2  d32004K = rst ? 1'bz : ((0|C37A|C36A|C32A|C31A|C30A|C35A|C34A|C33A) ? 1'b0 : 1'bz);
// Gate A21-U129B
pullup(SCAS17);
assign #0.2  SCAS17 = rst ? 0 : ((0|FS17|DOSCAL) ? 1'b0 : 1'bz);
// Gate A21-U120B
pullup(FETCH0_);
assign #0.2  FETCH0_ = rst ? 1'bz : ((0|FETCH0) ? 1'b0 : 1'bz);
// Gate A21-U122A
pullup(MON_);
assign #0.2  MON_ = rst ? 1'bz : ((0|g32207|g32214) ? 1'b0 : 1'bz);
// Gate A21-U207B
pullup(CG26);
assign #0.2  CG26 = rst ? 1'bz : ((0|g32650) ? 1'b0 : 1'bz);
// Gate A21-U220A
pullup(C44R);
assign #0.2  C44R = rst ? 0 : ((0|CXB4_|CA4_|g32611) ? 1'b0 : 1'bz);
// Gate A21-U212B
pullup(g32646);
assign #0.2  g32646 = rst ? 0 : ((0|g32647|g32645) ? 1'b0 : 1'bz);
// Gate A21-U228A
pullup(g32604);
assign #0.2  g32604 = rst ? 0 : ((0|g32603|g32610) ? 1'b0 : 1'bz);
// Gate A21-U235A
pullup(C56A);
assign #0.2  C56A = rst ? 0 : ((0|CG23|g32532) ? 1'b0 : 1'bz);
// Gate A21-U111A
pullup(g32238);
assign #0.2  g32238 = rst ? 1'bz : ((0|g32237|g32239) ? 1'b0 : 1'bz);
// Gate A21-U139A
pullup(BKTF_);
assign #0.2  BKTF_ = rst ? 0 : ((0|T10_) ? 1'b0 : 1'bz);
// Gate A21-U113B
pullup(g32232);
assign #0.2  g32232 = rst ? 0 : ((0|g32259|T11_) ? 1'b0 : 1'bz);
// Gate A21-U223A
pullup(g32610);
assign #0.2  g32610 = rst ? 1'bz : ((0|C44R|g32609) ? 1'b0 : 1'bz);
// Gate A21-U237A
pullup(C56R);
assign #0.2  C56R = rst ? 0 : ((0|CXB6_|CA5_|g32511) ? 1'b0 : 1'bz);
// Gate A21-U114A
pullup(MONpCH);
assign #0.2  MONpCH = rst ? 0 : ((0|g32229) ? 1'b0 : 1'bz);
// Gate A21-U141B
pullup(g32058);
assign #0.2  g32058 = rst ? 0 : ((0|g32056|INCSET_) ? 1'b0 : 1'bz);
// Gate A21-U112A
pullup(g32237);
assign #0.2  g32237 = rst ? 0 : ((0|PHS2_|g32235) ? 1'b0 : 1'bz);
// Gate A21-U254A
pullup(CTROR);
assign #0.2  CTROR = rst ? 1'bz : ((0|CTROR_) ? 1'b0 : 1'bz);
// Gate A21-U135A
pullup(SHANC_);
assign #0.2  SHANC_ = rst ? 1'bz : ((0|SHANC|g32062) ? 1'b0 : 1'bz);
// Gate A21-U154A A21-U148A A21-U150A A21-U157A A21-U159A A21-U153A
pullup(g32033);
assign #0.2  g32033 = rst ? 0 : ((0|C36A|C37A|C44A|C57A|C55A|C54A|C56A|C27A|C34A|C35A|C25A|C24A|C26A|C45A|C47A|C46A) ? 1'b0 : 1'bz);
// Gate A21-U235B
pullup(g32506);
assign #0.2  g32506 = rst ? 1'bz : ((0|g32505|g32507) ? 1'b0 : 1'bz);
// Gate A21-U237B
pullup(g32507);
assign #0.2  g32507 = rst ? 0 : ((0|g32506|C42R) ? 1'b0 : 1'bz);
// Gate A21-U208B
pullup(g32650);
assign #0.2  g32650 = rst ? 0 : ((0|g32647|CG16|g32633) ? 1'b0 : 1'bz);
// Gate A21-U134B
pullup(DINCNC_);
assign #0.2  DINCNC_ = rst ? 1'bz : ((0|DINC|g32049) ? 1'b0 : 1'bz);
// Gate A21-U125A
pullup(STORE1);
assign #0.2  STORE1 = rst ? 0 : ((0|g32206|ST1_) ? 1'b0 : 1'bz);
// Gate A21-U224A
pullup(g32607);
assign #0.2  g32607 = rst ? 1'bz : ((0|g32606|C44R) ? 1'b0 : 1'bz);
// Gate A21-U201B
pullup(RQ_);
assign #0.2  RQ_ = rst ? 1'bz : ((0|RQ) ? 1'b0 : 1'bz);
// Gate A21-U207A
pullup(g32622);
assign #0.2  g32622 = rst ? 0 : ((0|g32607|CG15|g32620) ? 1'b0 : 1'bz);
// Gate A21-U136A
pullup(SHANC);
assign #0.2  SHANC = rst ? 0 : ((0|SHANC_|T12A) ? 1'b0 : 1'bz);
// Gate A21-U125B
pullup(STFET1_);
assign #0.2  STFET1_ = rst ? 1'bz : ((0|STORE1|FETCH1) ? 1'b0 : 1'bz);
// Gate A21-U245B
pullup(g32515);
assign #0.2  g32515 = rst ? 1'bz : ((0|g32516|BMAGYP) ? 1'b0 : 1'bz);
// Gate A21-U115A
pullup(MREQIN);
assign #0.2  MREQIN = rst ? 0 : ((0|g32229) ? 1'b0 : 1'bz);
// Gate A21-U234B
pullup(g32505);
assign #0.2  g32505 = rst ? 0 : ((0|g32504|g32501) ? 1'b0 : 1'bz);
// Gate A21-U234A
pullup(g32532);
assign #0.2  g32532 = rst ? 0 : ((0|g32533|g32531) ? 1'b0 : 1'bz);
// Gate A21-U236A
pullup(g32533);
assign #0.2  g32533 = rst ? 1'bz : ((0|C56R|g32532) ? 1'b0 : 1'bz);
// Gate A21-U238A
pullup(g32537);
assign #0.2  g32537 = rst ? 0 : ((0|g32536|C57R) ? 1'b0 : 1'bz);
// Gate A21-U239A
pullup(g32536);
assign #0.2  g32536 = rst ? 1'bz : ((0|g32537|OTLNKM) ? 1'b0 : 1'bz);
// Gate A21-U209A
pullup(C45A);
assign #0.2  C45A = rst ? 0 : ((0|g32607|CG15|g32619) ? 1'b0 : 1'bz);
// Gate A21-U136B
pullup(DINC);
assign #0.2  DINC = rst ? 0 : ((0|T12A|DINCNC_) ? 1'b0 : 1'bz);
// Gate A21-U239B
pullup(g32509);
assign #0.2  g32509 = rst ? 1'bz : ((0|g32510|BMAGXM) ? 1'b0 : 1'bz);
// Gate A21-U254B
pullup(g32522);
assign #0.2  g32522 = rst ? 0 : ((0|g32520|CG13|g32507) ? 1'b0 : 1'bz);
// Gate A21-U201A
pullup(C45M);
assign #0.2  C45M = rst ? 0 : ((0|g32624|CA4_|CXB5_) ? 1'b0 : 1'bz);
// Gate A21-U231A
pullup(g32530);
assign #0.2  g32530 = rst ? 1'bz : ((0|C56R|g32529) ? 1'b0 : 1'bz);
// Gate A21-U232A
pullup(g32529);
assign #0.2  g32529 = rst ? 0 : ((0|g32530|EMSD) ? 1'b0 : 1'bz);
// Gate A21-U208A
pullup(g32620);
assign #0.2  g32620 = rst ? 0 : ((0|C45R|g32619) ? 1'b0 : 1'bz);
// Gate A21-U232B
pullup(g32503);
assign #0.2  g32503 = rst ? 0 : ((0|g32502|C42R) ? 1'b0 : 1'bz);
// Gate A21-U231B
pullup(g32502);
assign #0.2  g32502 = rst ? 1'bz : ((0|g32503|BMAGXP) ? 1'b0 : 1'bz);
// Gate A21-U206A
pullup(g32659);
assign #0.2  g32659 = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A21-U206B
pullup(CA4_);
assign #0.2  CA4_ = rst ? 1'bz : ((0|OCTAD4) ? 1'b0 : 1'bz);
// Gate A21-U129A A21-U128A
pullup(g32202);
assign #0.2  g32202 = rst ? 0 : ((0|PHS4_|T12_|NISQL_|GNHNC|PSEUDO) ? 1'b0 : 1'bz);
// Gate A21-U102A
pullup(RSSB);
assign #0.2  RSSB = rst ? 0 : ((0|PHS3_|T07_|g32244) ? 1'b0 : 1'bz);
// Gate A21-U230A
pullup(g32602);
assign #0.2  g32602 = rst ? 1'bz : ((0|BMAGZP|g32603) ? 1'b0 : 1'bz);
// Gate A21-U244B
pullup(C57R);
assign #0.2  C57R = rst ? 0 : ((0|CXB7_|g32511|CA5_) ? 1'b0 : 1'bz);
// Gate A21-U204A
pullup(g32624);
assign #0.2  g32624 = rst ? 1'bz : ((0|INLNKM|g32625) ? 1'b0 : 1'bz);
// Gate A21-U203B A21-U202B
pullup(CXB6_);
assign #0.2  CXB6_ = rst ? 1'bz : ((0|XB6) ? 1'b0 : 1'bz);
// Gate A21-U241A
pullup(g32539);
assign #0.2  g32539 = rst ? 1'bz : ((0|g32540|g32538) ? 1'b0 : 1'bz);
// Gate A21-U243A
pullup(g32540);
assign #0.2  g32540 = rst ? 0 : ((0|C57R|g32539) ? 1'b0 : 1'bz);
// Gate A21-U226B
pullup(C46A);
assign #0.2  C46A = rst ? 0 : ((0|g32632|CG16) ? 1'b0 : 1'bz);
// Gate A21-U126B
pullup(g32207);
assign #0.2  g32207 = rst ? 0 : ((0|g32218|g32206|GOJAM) ? 1'b0 : 1'bz);
// Gate A21-U218B
pullup(C46M);
assign #0.2  C46M = rst ? 0 : ((0|CA4_|CXB6_|g32636) ? 1'b0 : 1'bz);
// Gate A21-U154B A21-U156B A21-U158B A21-U147A A21-U153B
pullup(g32022);
assign #0.2  g32022 = rst ? 0 : ((0|C53A|C52A|C47A|C33A|C36A|C37A|C32A|C26A|C27A|C57A|C56A|C46A|C42A|C43A) ? 1'b0 : 1'bz);
// Gate A21-U246B
pullup(g32516);
assign #0.2  g32516 = rst ? 0 : ((0|g32515|C43R) ? 1'b0 : 1'bz);
// Gate A21-U105B A21-U106A
pullup(INCSET_);
assign #0.2  INCSET_ = rst ? 1'bz : ((0|g32246) ? 1'b0 : 1'bz);
// Gate A21-U224B
pullup(C46R);
assign #0.2  C46R = rst ? 0 : ((0|CA4_|CXB6_|g32611) ? 1'b0 : 1'bz);
// Gate A21-U246A
pullup(g32543);
assign #0.2  g32543 = rst ? 0 : ((0|g32544|ALTM) ? 1'b0 : 1'bz);
// Gate A21-U220B
pullup(C46P);
assign #0.2  C46P = rst ? 0 : ((0|CA4_|CXB6_|g32629) ? 1'b0 : 1'bz);
// Gate A21-U213A
pullup(g32618);
assign #0.2  g32618 = rst ? 0 : ((0|g32617|g32601) ? 1'b0 : 1'bz);
// Gate A21-U256B
pullup(CG15);
assign #0.2  CG15 = rst ? 1'bz : ((0|g32522) ? 1'b0 : 1'bz);
// Gate A21-U205A
pullup(CG16);
assign #0.2  CG16 = rst ? 1'bz : ((0|g32622) ? 1'b0 : 1'bz);
// Gate A21-U105A A21-U102B
pullup(INKL_);
assign #0.2  INKL_ = rst ? 1'bz : ((0|g32245|MONpCH) ? 1'b0 : 1'bz);
// Gate A21-U250B
pullup(g32519);
assign #0.2  g32519 = rst ? 1'bz : ((0|g32518|g32520) ? 1'b0 : 1'bz);
// Gate A21-U247A
pullup(g32545);
assign #0.2  g32545 = rst ? 0 : ((0|g32501|g32543) ? 1'b0 : 1'bz);
// Gate A21-U227A
pullup(g32605);
assign #0.2  g32605 = rst ? 0 : ((0|g32604|g32601) ? 1'b0 : 1'bz);
// Gate A21-U112B
pullup(g32234);
assign #0.2  g32234 = rst ? 1'bz : ((0|g32233) ? 1'b0 : 1'bz);
// Gate A21-U229B
pullup(g32629);
assign #0.2  g32629 = rst ? 0 : ((0|g32630|RNRADP) ? 1'b0 : 1'bz);
// Gate A21-U120A
pullup(g32218);
assign #0.2  g32218 = rst ? 0 : ((0|ST1_|MON_|g32234) ? 1'b0 : 1'bz);
// Gate A21-U114B A21-U115B
pullup(g32229);
assign #0.2  g32229 = rst ? 1'bz : ((0|g32214|g32207|INOTLD|INOTRD) ? 1'b0 : 1'bz);
// Gate A21-U257B
pullup(g32524);
assign #0.2  g32524 = rst ? 1'bz : ((0|g32525|BMAGYM) ? 1'b0 : 1'bz);
// Gate A21-U259B
pullup(C43M);
assign #0.2  C43M = rst ? 0 : ((0|g32524|CA4_|CXB3_) ? 1'b0 : 1'bz);
// Gate A21-U252B
pullup(C43A);
assign #0.2  C43A = rst ? 0 : ((0|CG13|g32519|g32507) ? 1'b0 : 1'bz);
// Gate A21-U126A
pullup(g32206);
assign #0.2  g32206 = rst ? 1'bz : ((0|g32205|g32207) ? 1'b0 : 1'bz);
// Gate A21-U146B
pullup(SHINC_);
assign #0.2  SHINC_ = rst ? 1'bz : ((0|SHINC|g32058) ? 1'b0 : 1'bz);
// Gate A21-U145B
pullup(d50SUM);
assign #0.2  d50SUM = rst ? 0 : ((0|g32044) ? 1'b0 : 1'bz);
// Gate A21-U118A
pullup(g32222);
assign #0.2  g32222 = rst ? 1'bz : ((0|INOTLD|g32221) ? 1'b0 : 1'bz);
// Gate A21-U227B
pullup(g32632);
assign #0.2  g32632 = rst ? 0 : ((0|g32633|g32631) ? 1'b0 : 1'bz);
// Gate A21-U119A
pullup(g32221);
assign #0.2  g32221 = rst ? 0 : ((0|g32203|g32220|g32238) ? 1'b0 : 1'bz);
// Gate A21-U241B
pullup(C42R);
assign #0.2  C42R = rst ? 0 : ((0|g32511|CA4_|CXB2_) ? 1'b0 : 1'bz);
// Gate A21-U249B
pullup(C43P);
assign #0.2  C43P = rst ? 0 : ((0|CXB3_|g32515|CA4_) ? 1'b0 : 1'bz);
// Gate A21-U260B
pullup(C43R);
assign #0.2  C43R = rst ? 0 : ((0|CXB3_|CA4_|g32511) ? 1'b0 : 1'bz);
// Gate A21-U107A
pullup(g32245);
assign #0.2  g32245 = rst ? 0 : ((0|GOJAM|g32243|g32244) ? 1'b0 : 1'bz);
// Gate A21-U223B
pullup(g32637);
assign #0.2  g32637 = rst ? 0 : ((0|g32636|C46R) ? 1'b0 : 1'bz);
// Gate A21-U110A A21-U109A
pullup(g32240);
assign #0.2  g32240 = rst ? 0 : ((0|CTROR_|g32239|MNHNC|g32203) ? 1'b0 : 1'bz);
// Gate A21-U106B
pullup(g32246);
assign #0.2  g32246 = rst ? 0 : ((0|g32244|T02_) ? 1'b0 : 1'bz);
// Gate A21-U216B
pullup(g32644);
assign #0.2  g32644 = rst ? 1'bz : ((0|g32643|C47R) ? 1'b0 : 1'bz);
// Gate A21-U122B
pullup(g32214);
assign #0.2  g32214 = rst ? 0 : ((0|g32218|g32213|GOJAM) ? 1'b0 : 1'bz);
// Gate A21-U255A A21-U253A
pullup(CTROR_);
assign #0.2  CTROR_ = rst ? 0 : ((0|g32540|g32547|CG23|g32533) ? 1'b0 : 1'bz);
// Gate A21-U142A
pullup(g32259);
assign #0.2  g32259 = rst ? 1'bz : ((0|FETCH1|STORE1|CHINC) ? 1'b0 : 1'bz);
// Gate A21-U222A
pullup(g32609);
assign #0.2  g32609 = rst ? 0 : ((0|BMAGZM|g32610) ? 1'b0 : 1'bz);
// Gate A21-U230B
pullup(g32630);
assign #0.2  g32630 = rst ? 1'bz : ((0|C46R|g32629) ? 1'b0 : 1'bz);
// Gate A21-U119B
pullup(g32220);
assign #0.2  g32220 = rst ? 1'bz : ((0|MLDCH) ? 1'b0 : 1'bz);
// Gate A21-U132B
pullup(CHINC_);
assign #0.2  CHINC_ = rst ? 1'bz : ((0|INOTRD|INOTLD) ? 1'b0 : 1'bz);
// Gate A21-U226A
pullup(g32606);
assign #0.2  g32606 = rst ? 0 : ((0|g32605|g32607) ? 1'b0 : 1'bz);
// Gate A21-U225A
pullup(C44A);
assign #0.2  C44A = rst ? 0 : ((0|CG15|g32606) ? 1'b0 : 1'bz);
// Gate A21-U142B
pullup(CAD2);
assign #0.2  CAD2 = rst ? 0 : ((0|RSCT_|g32022) ? 1'b0 : 1'bz);
// Gate A21-U111B A21-U109B
pullup(g32235);
assign #0.2  g32235 = rst ? 1'bz : ((0|MREAD|MLOAD|MLDCH|MRDCH) ? 1'b0 : 1'bz);
// Gate A21-U244A
pullup(g32511);
assign #0.2  g32511 = rst ? 1'bz : ((0|RSSB) ? 1'b0 : 1'bz);
// Gate A21-U128B
pullup(g32203);
assign #0.2  g32203 = rst ? 1'bz : ((0|g32202) ? 1'b0 : 1'bz);
// Gate A21-U219A
pullup(C44P);
assign #0.2  C44P = rst ? 0 : ((0|CXB4_|CA4_|g32602) ? 1'b0 : 1'bz);
// Gate A21-U133B
pullup(g32061);
assign #0.2  g32061 = rst ? 1'bz : ((0|C46P|C45P) ? 1'b0 : 1'bz);
// Gate A21-U202A
pullup(C45R);
assign #0.2  C45R = rst ? 0 : ((0|g32611|CA4_|CXB5_) ? 1'b0 : 1'bz);
// Gate A21-U251A A21-U252A
pullup(C60A);
assign #0.2  C60A = rst ? 0 : ((0|CG23|g32533|g32540|g32546) ? 1'b0 : 1'bz);
// Gate A21-U249A
pullup(g32546);
assign #0.2  g32546 = rst ? 0 : ((0|g32547|g32545) ? 1'b0 : 1'bz);
// Gate A21-U107B
pullup(g32243);
assign #0.2  g32243 = rst ? 0 : ((0|g32242|PHS3_|T12_) ? 1'b0 : 1'bz);
// Gate A21-U117B
pullup(g32224);
assign #0.2  g32224 = rst ? 1'bz : ((0|MRDCH) ? 1'b0 : 1'bz);
// Gate A21-U108B
pullup(g32242);
assign #0.2  g32242 = rst ? 1'bz : ((0|g32239|CTROR_) ? 1'b0 : 1'bz);
// Gate A21-U248A
pullup(C60R);
assign #0.2  C60R = rst ? 0 : ((0|CA6_|CXB0_|g32511) ? 1'b0 : 1'bz);
// Gate A21-U260A
pullup(CHINC);
assign #0.2  CHINC = rst ? 0 : ((0|CHINC_) ? 1'b0 : 1'bz);
// Gate A21-U124B
pullup(STORE1_);
assign #0.2  STORE1_ = rst ? 1'bz : ((0|STORE1) ? 1'b0 : 1'bz);
// Gate A21-U221B
pullup(g32638);
assign #0.2  g32638 = rst ? 0 : ((0|g32637|g32630) ? 1'b0 : 1'bz);
// Gate A21-U253B
pullup(g32520);
assign #0.2  g32520 = rst ? 0 : ((0|g32519|C43R) ? 1'b0 : 1'bz);
// Gate A21-U121B
pullup(FETCH0);
assign #0.2  FETCH0 = rst ? 0 : ((0|MON_|ST0_) ? 1'b0 : 1'bz);
// Gate A21-U121A
pullup(FETCH1);
assign #0.2  FETCH1 = rst ? 0 : ((0|ST1_|g32213) ? 1'b0 : 1'bz);
// Gate A21-U221A
pullup(C44M);
assign #0.2  C44M = rst ? 0 : ((0|CXB4_|CA4_|g32609) ? 1'b0 : 1'bz);
// Gate A21-U144B
pullup(SHINC);
assign #0.2  SHINC = rst ? 0 : ((0|SHINC_|T12A) ? 1'b0 : 1'bz);
// Gate A21-U108A
pullup(g32244);
assign #0.2  g32244 = rst ? 1'bz : ((0|g32240|g32245) ? 1'b0 : 1'bz);
// Gate A21-U104A A21-U104B
pullup(INKL);
assign #0.2  INKL = rst ? 0 : ((0|INKL_) ? 1'b0 : 1'bz);
// Gate A21-U219B
pullup(g32641);
assign #0.2  g32641 = rst ? 1'bz : ((0) ? 1'b0 : 1'bz);
// Gate A21-U134A
pullup(g32062);
assign #0.2  g32062 = rst ? 0 : ((0|INCSET_|g32061) ? 1'b0 : 1'bz);
// Gate A21-U103B
pullup(INKBT1);
assign #0.2  INKBT1 = rst ? 1'bz : ((0|STD2) ? 1'b0 : 1'bz);
// Gate A21-U124A
pullup(g32211);
assign #0.2  g32211 = rst ? 1'bz : ((0|MREAD) ? 1'b0 : 1'bz);
// Gate A21-U123A
pullup(g32212);
assign #0.2  g32212 = rst ? 0 : ((0|g32203|g32211|g32238) ? 1'b0 : 1'bz);
// Gate A21-U240A
pullup(g32538);
assign #0.2  g32538 = rst ? 0 : ((0|g32501|g32536) ? 1'b0 : 1'bz);
// Gate A21-U215A
pullup(g32616);
assign #0.2  g32616 = rst ? 0 : ((0|g32615|C45R) ? 1'b0 : 1'bz);
// Gate A21-U233A
pullup(g32531);
assign #0.2  g32531 = rst ? 0 : ((0|g32501|g32529) ? 1'b0 : 1'bz);
// Gate A21-U238B
pullup(g32510);
assign #0.2  g32510 = rst ? 0 : ((0|g32509|C42R) ? 1'b0 : 1'bz);
// Gate A21-U217A
pullup(g32611);
assign #0.2  g32611 = rst ? 1'bz : ((0|RSSB) ? 1'b0 : 1'bz);
// Gate A21-U146A
pullup(d30SUM);
assign #0.2  d30SUM = rst ? 0 : ((0|d32004K) ? 1'b0 : 1'bz);
// Gate A21-U248B
pullup(g32517);
assign #0.2  g32517 = rst ? 1'bz : ((0|g32516|g32525) ? 1'b0 : 1'bz);
// Gate A21-U127A
pullup(g32204);
assign #0.2  g32204 = rst ? 1'bz : ((0|MLOAD) ? 1'b0 : 1'bz);
// Gate A21-U245A
pullup(g32544);
assign #0.2  g32544 = rst ? 1'bz : ((0|g32543|C60R) ? 1'b0 : 1'bz);
// Gate A21-U213B
pullup(g32645);
assign #0.2  g32645 = rst ? 0 : ((0|g32643|g32601) ? 1'b0 : 1'bz);
// Gate A21-U247B
pullup(g32518);
assign #0.2  g32518 = rst ? 0 : ((0|g32517|g32501) ? 1'b0 : 1'bz);
// Gate A21-U228B
pullup(g32633);
assign #0.2  g32633 = rst ? 1'bz : ((0|g32632|C46R) ? 1'b0 : 1'bz);
// Gate A21-U240B
pullup(C42M);
assign #0.2  C42M = rst ? 0 : ((0|g32509|CA4_|CXB2_) ? 1'b0 : 1'bz);
// Gate A21-U149A A21-U152A A21-U151A
pullup(g32044);
assign #0.2  g32044 = rst ? 1'bz : ((0|C57A|C56A|C52A|C50A|C51A|C53A|C55A|C54A) ? 1'b0 : 1'bz);
// Gate A21-U236B
pullup(C42A);
assign #0.2  C42A = rst ? 0 : ((0|g32506|CG13) ? 1'b0 : 1'bz);
// Gate A21-U210B
pullup(g32647);
assign #0.2  g32647 = rst ? 1'bz : ((0|g32646|C47R) ? 1'b0 : 1'bz);
// Gate A21-U233B
pullup(g32504);
assign #0.2  g32504 = rst ? 1'bz : ((0|g32510|g32503) ? 1'b0 : 1'bz);
// Gate A21-U211A
pullup(g32619);
assign #0.2  g32619 = rst ? 1'bz : ((0|g32618|g32620) ? 1'b0 : 1'bz);
// Gate A21-U215B
pullup(g32643);
assign #0.2  g32643 = rst ? 0 : ((0|g32644|GYROD) ? 1'b0 : 1'bz);
// Gate A21-U217B
pullup(g32601);
assign #0.2  g32601 = rst ? 1'bz : ((0|BKTF_) ? 1'b0 : 1'bz);
// Gate A21-U214A
pullup(g32617);
assign #0.2  g32617 = rst ? 1'bz : ((0|g32625|g32616) ? 1'b0 : 1'bz);
// Gate A21-U160A A21-U160B A21-U145A
pullup(g32015);
assign #0.2  g32015 = rst ? 0 : ((0|C26A|C25A|C24A|C27A|d30SUM|C60A) ? 1'b0 : 1'bz);
// Gate A21-U110B
pullup(g32239);
assign #0.2  g32239 = rst ? 0 : ((0|g32232|GOJAM|g32238) ? 1'b0 : 1'bz);
// Gate A21-U132A
pullup(DINC_);
assign #0.2  DINC_ = rst ? 1'bz : ((0|DINC) ? 1'b0 : 1'bz);
// Gate A21-U242B
pullup(C42P);
assign #0.2  C42P = rst ? 0 : ((0|g32502|CXB2_|CA4_) ? 1'b0 : 1'bz);
// Gate A21-U103A
pullup(MINKL);
assign #0.2  MINKL = rst ? 0 : ((0|INKL_) ? 1'b0 : 1'bz);
// Gate A21-U148B A21-U152B A21-U147B A21-U151B
pullup(g32016);
assign #0.2  g32016 = rst ? 1'bz : ((0|d50SUM|C46A|C47A|C40A|C41A|C42A|C60A|C45A|C44A|C43A) ? 1'b0 : 1'bz);
// Gate A21-U117A
pullup(g32225);
assign #0.2  g32225 = rst ? 0 : ((0|g32203|g32224|g32238) ? 1'b0 : 1'bz);
// Gate A21-U143B
pullup(CAD1);
assign #0.2  CAD1 = rst ? 0 : ((0|RSCT_|g32021) ? 1'b0 : 1'bz);
// Gate A21-U116A
pullup(g32226);
assign #0.2  g32226 = rst ? 1'bz : ((0|INOTRD|g32225) ? 1'b0 : 1'bz);
// Gate A21-U141A
pullup(CAD3);
assign #0.2  CAD3 = rst ? 0 : ((0|g32033|RSCT_) ? 1'b0 : 1'bz);
// Gate A21-U144A
pullup(CAD4);
assign #0.2  CAD4 = rst ? 0 : ((0|RSCT_|g32007) ? 1'b0 : 1'bz);
// Gate A21-U140A
pullup(CAD5);
assign #0.2  CAD5 = rst ? 0 : ((0|g32015|RSCT_) ? 1'b0 : 1'bz);
// Gate A21-U140B
pullup(CAD6);
assign #0.2  CAD6 = rst ? 0 : ((0|g32016|RSCT_) ? 1'b0 : 1'bz);
// Gate A21-U123B
pullup(g32213);
assign #0.2  g32213 = rst ? 1'bz : ((0|g32212|g32214) ? 1'b0 : 1'bz);
// Gate A21-U133A
pullup(g32049);
assign #0.2  g32049 = rst ? 0 : ((0|g32068|INCSET_) ? 1'b0 : 1'bz);
// Gate A21-U137B A21-U138B A21-U135B
pullup(g32068);
assign #0.2  g32068 = rst ? 1'bz : ((0|C54A|C56A|C55A|C50A|C47A|C31A|C51A|C52A|C53A) ? 1'b0 : 1'bz);
// Gate A21-U205B A21-U204B
pullup(CXB0_);
assign #0.2  CXB0_ = rst ? 1'bz : ((0|XB0) ? 1'b0 : 1'bz);
// Gate A21-U127B
pullup(g32205);
assign #0.2  g32205 = rst ? 0 : ((0|g32238|g32204|g32203) ? 1'b0 : 1'bz);
// Gate A21-U222B
pullup(g32636);
assign #0.2  g32636 = rst ? 1'bz : ((0|g32637|RNRADM) ? 1'b0 : 1'bz);
// Gate A21-U243B
pullup(g32501);
assign #0.2  g32501 = rst ? 1'bz : ((0|BKTF_) ? 1'b0 : 1'bz);
// Gate A21-U258B
pullup(g32525);
assign #0.2  g32525 = rst ? 0 : ((0|g32524|C43R) ? 1'b0 : 1'bz);
// Gate A21-U113A
pullup(g32233);
assign #0.2  g32233 = rst ? 0 : ((0|T12_|CT|PHS2_) ? 1'b0 : 1'bz);
// Gate A21-U212A
pullup(C45P);
assign #0.2  C45P = rst ? 0 : ((0|CXB5_|g32615|CA4_) ? 1'b0 : 1'bz);
// Gate A21-U216A
pullup(g32615);
assign #0.2  g32615 = rst ? 1'bz : ((0|INLNKP|g32616) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
