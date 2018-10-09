// Verilog module auto-generated for AGC module A22 by dumbVerilog.py

module A22 ( 
  rst, CCH34, CCH35, CCHG_, CGA22, CHWL01_, CHWL02_, CHWL03_, CHWL04_, CHWL05_,
  CHWL06_, CHWL07_, CHWL08_, CHWL09_, CHWL10_, CHWL11_, CHWL12_, CHWL13_,
  CHWL14_, CHWL16_, DKBSNC, DKSTRT, END, F12B, FS13, FS14, GOJAM, HIGH0_,
  HIGH1_, HIGH2_, HIGH3_, PC15_, WCH34_, WCH35_, WCHG_, XB3_, XB4_, XT1_,
  BSYNC_, CCH13, DATA_, DKCTR2, DKCTR3, DKCTR3_, DKDAT_, DLKCLR, F12B_, FS13_,
  LOW0_, LOW1_, LOW2_, LOW3_, LOW4_, LOW5_, LOW6_, LOW7_, ORDRBT, RCH13_,
  RDOUT_, WCH13_, WDORDR, WRD1B1, WRD1BP, WRD2B2, WRD2B3, ADVCTR, CCH14,
  CH1307, DKCTR1, DKCTR1_, DKCTR2_, DKCTR4, DKCTR4_, DKCTR5, DKCTR5_, DKDATA,
  DKDATB, F14H, RCH14_, WCH14_, d16CNT, d1CNT, d32CNT
);

input wand rst, CCH34, CCH35, CCHG_, CGA22, CHWL01_, CHWL02_, CHWL03_, CHWL04_,
  CHWL05_, CHWL06_, CHWL07_, CHWL08_, CHWL09_, CHWL10_, CHWL11_, CHWL12_,
  CHWL13_, CHWL14_, CHWL16_, DKBSNC, DKSTRT, END, F12B, FS13, FS14, GOJAM,
  HIGH0_, HIGH1_, HIGH2_, HIGH3_, PC15_, WCH34_, WCH35_, WCHG_, XB3_, XB4_,
  XT1_;

inout wand BSYNC_, CCH13, DATA_, DKCTR2, DKCTR3, DKCTR3_, DKDAT_, DLKCLR,
  F12B_, FS13_, LOW0_, LOW1_, LOW2_, LOW3_, LOW4_, LOW5_, LOW6_, LOW7_, ORDRBT,
  RCH13_, RDOUT_, WCH13_, WDORDR, WRD1B1, WRD1BP, WRD2B2, WRD2B3;

output wand ADVCTR, CCH14, CH1307, DKCTR1, DKCTR1_, DKCTR2_, DKCTR4, DKCTR4_,
  DKCTR5, DKCTR5_, DKDATA, DKDATB, F14H, RCH14_, WCH14_, d16CNT, d1CNT, d32CNT;

// Gate A22-U146B
assign #0.2  DKDATA = rst ? 0 : !(0|DKDAT_|RDOUT_|BSYNC_);
// Gate A22-U147A
assign #0.2  DKDATB = rst ? 0 : !(0|BSYNC_|RDOUT_|DKDAT_);
// Gate A22-U130A
assign #0.2  DKCTR5 = rst ? 0 : !(0|DKCTR5_|g47140);
// Gate A22-U112B
assign #0.2  DKCTR2 = rst ? 1 : !(0|g47122);
// Gate A22-U124B
assign #0.2  DKCTR3 = rst ? 0 : !(0|g47130);
// Gate A22-U139A
assign #0.2  LOW6_ = rst ? 1 : !(0|g47240);
// Gate A22-U108B
assign #0.2  DKCTR1 = rst ? 0 : !(0|g47114);
// Gate A22-U127A
assign #0.2  DKCTR4 = rst ? 0 : !(0|DKCTR4_|g47134);
// Gate A22-U237A
assign #0.2  g47457 = rst ? 1 : !(0|g47456|g47458);
// Gate A22-U126B
assign #0.2  g47133 = rst ? 0 : !(0|g47134|DKCTR4);
// Gate A22-U238A
assign #0.2  g47458 = rst ? 0 : !(0|CCH35|g47457);
// Gate A22-U136A
assign #0.2  g47248 = rst ? 1 : !(0|g47245|g47249);
// Gate A22-U125B
assign #0.2  g47134 = rst ? 1 : !(0|g47135|g47128|g47133);
// Gate A22-U126A
assign #0.2  g47136 = rst ? 0 : !(0|DKCTR4_|g47135);
// Gate A22-U125A
assign #0.2  g47135 = rst ? 0 : !(0|g47134|g47136|g47128);
// Gate A22-U136B
assign #0.2  g47246 = rst ? 1 : !(0|g47247|g47244);
// Gate A22-U219A
assign #0.2  g47324 = rst ? 0 : !(0|CCH34|g47323);
// Gate A22-U131B
assign #0.2  DKDAT_ = rst ? 1 : !(0|g47254|ORDRBT);
// Gate A22-U210A
assign #0.2  g47341 = rst ? 0 : !(0|CCH34|g47340);
// Gate A22-U246A
assign #0.2  g47440 = rst ? 1 : !(0|g47439|g47441);
// Gate A22-U118B
assign #0.2  WDORDR = rst ? 1 : !(0|g47147|g47153);
// Gate A22-U210B
assign #0.2  g47342 = rst ? 0 : !(0|HIGH1_|LOW0_|g47340);
// Gate A22-U259B
assign #0.2  g47416 = rst ? 0 : !(0|HIGH2_|LOW0_|g47614);
// Gate A22-U120B
assign #0.2  ORDRBT = rst ? 0 : !(0|g47153|g47156);
// Gate A22-U231A
assign #0.2  g47402 = rst ? 1 : !(0|g47401|g47403);
// Gate A22-U236B
assign #0.2  g47412 = rst ? 0 : !(0|LOW3_|HIGH3_|g47410);
// Gate A22-U160A A22-U159A A22-U159B
assign #0.2  WCH13_ = rst ? 1 : !(0|g47201);
// Gate A22-U250A
assign #0.2  g47431 = rst ? 1 : !(0|g47430|g47432);
// Gate A22-U151B
assign #0.2  g47223 = rst ? 0 : !(0|XB4_|XT1_);
// Gate A22-U231B
assign #0.2  g47401 = rst ? 0 : !(0|WCH35_|CHWL02_);
// Gate A22-U105A
assign #0.2  g47111 = rst ? 0 : !(0|g47110|g47112|g47108);
// Gate A22-U105B
assign #0.2  g47110 = rst ? 1 : !(0|g47111|g47108|d1CNT);
// Gate A22-U106A
assign #0.2  g47112 = rst ? 0 : !(0|g47114|g47111);
// Gate A22-U209B
assign #0.2  g47344 = rst ? 0 : !(0|WCH34_|CHWL06_);
// Gate A22-U103A
assign #0.2  ADVCTR = rst ? 0 : !(0|BSYNC_|RDOUT_|WDORDR);
// Gate A22-U248A
assign #0.2  g47436 = rst ? 1 : !(0|g47435|g47437);
// Gate A22-U224B
assign #0.2  g47313 = rst ? 0 : !(0|WCH34_|CHWL13_);
// Gate A22-U160B
assign #0.2  g47201 = rst ? 0 : !(0|XT1_|XB3_|WCHG_);
// Gate A22-U101B
assign #0.2  g47101 = rst ? 1 : !(0|DKSTRT);
// Gate A22-U155B
assign #0.2  g47214 = rst ? 0 : !(0|XB4_|XT1_|WCHG_);
// Gate A22-U232A
assign #0.2  g47403 = rst ? 0 : !(0|CCH35|g47402);
// Gate A22-U251A
assign #0.2  g47432 = rst ? 0 : !(0|CCH35|g47431);
// Gate A22-U233A
assign #0.2  g47406 = rst ? 1 : !(0|g47405|g47407);
// Gate A22-U114B
assign #0.2  g47147 = rst ? 0 : !(0|g47145|g47150);
// Gate A22-U116A
assign #0.2  g47151 = rst ? 1 : !(0|g47145|g47148);
// Gate A22-U114A
assign #0.2  g47148 = rst ? 0 : !(0|g47147|g47151);
// Gate A22-U204A
assign #0.2  g47354 = rst ? 0 : !(0|CCH34|g47353);
// Gate A22-U115B
assign #0.2  g47150 = rst ? 1 : !(0|g47149);
// Gate A22-U203B
assign #0.2  g47352 = rst ? 0 : !(0|WCH34_|CHWL04_);
// Gate A22-U239B
assign #0.2  g47452 = rst ? 0 : !(0|CHWL06_|WCH35_);
// Gate A22-U237B
assign #0.2  g47456 = rst ? 0 : !(0|CHWL05_|WCH35_);
// Gate A22-U145B
assign #0.2  g47228 = rst ? 0 : !(0|DKCTR3|DKCTR2|DKCTR1);
// Gate A22-U239A
assign #0.2  g47453 = rst ? 1 : !(0|g47452|g47454);
// Gate A22-U244B
assign #0.2  g47446 = rst ? 0 : !(0|LOW7_|HIGH2_|g47444);
// Gate A22-U242B
assign #0.2  g47451 = rst ? 0 : !(0|HIGH3_|LOW0_|g47449);
// Gate A22-U103B
assign #0.2  RDOUT_ = rst ? 1 : !(0|g47104|DLKCLR);
// Gate A22-U247B
assign #0.2  g47442 = rst ? 0 : !(0|LOW6_|HIGH2_|g47440);
// Gate A22-U229A
assign #0.2  g47302 = rst ? 1 : !(0|g47301|g47303);
// Gate A22-U223A
assign #0.2  g47315 = rst ? 0 : !(0|CCH34|g47314);
// Gate A22-U229B
assign #0.2  g47301 = rst ? 0 : !(0|WCH34_|PC15_);
// Gate A22-U146A
assign #0.2  BSYNC_ = rst ? 1 : !(0|DKBSNC);
// Gate A22-U258A
assign #0.2  g47418 = rst ? 1 : !(0|g47417|g47419);
// Gate A22-U257A
assign #0.2  g47419 = rst ? 0 : !(0|CCH35|g47418);
// Gate A22-U113A
assign #0.2  g47145 = rst ? 0 : !(0|BSYNC_);
// Gate A22-U211B
assign #0.2  g47339 = rst ? 0 : !(0|WCH34_|CHWL07_);
// Gate A22-U240A
assign #0.2  g47454 = rst ? 0 : !(0|CCH35|g47453);
// Gate A22-U124A
assign #0.2  DKCTR3_ = rst ? 1 : !(0|g47129);
// Gate A22-U132B A22-U133B A22-U220A A22-U220B A22-U241A A22-U241B A22-U254A A22-U254B A22-U207A A22-U207B
assign #0.2  DATA_ = rst ? 1 : !(0|g47251|g47250|WRD2B2|WRD1BP|WRD2B3|WRD1B1|g47312|g47316|g47320|g47325|g47329|g47333|g47451|g47446|g47442|g47455|g47459|g47412|g47429|g47438|g47433|g47416|g47420|g47425|g47351|g47355|g47359|g47342|g47347|g47338);
// Gate A22-U250B
assign #0.2  g47430 = rst ? 0 : !(0|CHWL11_|WCH35_);
// Gate A22-U142B
assign #0.2  g47234 = rst ? 0 : !(0|DKCTR1_|DKCTR2_|DKCTR3);
// Gate A22-U129B
assign #0.2  d16CNT = rst ? 0 : !(0|g47140|DKCTR5);
// Gate A22-U251B
assign #0.2  g47433 = rst ? 0 : !(0|LOW4_|HIGH2_|g47431);
// Gate A22-U141B
assign #0.2  g47236 = rst ? 0 : !(0|DKCTR3_|DKCTR2|DKCTR1);
// Gate A22-U209A
assign #0.2  g47345 = rst ? 1 : !(0|g47344|g47346);
// Gate A22-U221A
assign #0.2  g47318 = rst ? 1 : !(0|g47317|g47319);
// Gate A22-U222A
assign #0.2  g47319 = rst ? 0 : !(0|CCH34|g47318);
// Gate A22-U108A
assign #0.2  DKCTR1_ = rst ? 1 : !(0|g47113);
// Gate A22-U149A A22-U150A A22-U150B
assign #0.2  CCH14 = rst ? 1 : !(0|g47219);
// Gate A22-U218A
assign #0.2  g47323 = rst ? 1 : !(0|g47322|g47324);
// Gate A22-U138B
assign #0.2  g47242 = rst ? 0 : !(0|DKCTR1_|DKCTR3_|DKCTR2_);
// Gate A22-U208A
assign #0.2  g47346 = rst ? 0 : !(0|CCH34|g47345);
// Gate A22-U156A
assign #0.2  g47206 = rst ? 0 : !(0|g47205|GOJAM);
// Gate A22-U158B
assign #0.2  g47205 = rst ? 0 : !(0|XB3_|XT1_|CCHG_);
// Gate A22-U158A A22-U157A A22-U157B
assign #0.2  CCH13 = rst ? 1 : !(0|g47206);
// Gate A22-U215B
assign #0.2  g47333 = rst ? 0 : !(0|HIGH0_|LOW6_|g47331);
// Gate A22-U204B
assign #0.2  g47355 = rst ? 0 : !(0|HIGH1_|LOW3_|g47353);
// Gate A22-U141A
assign #0.2  LOW4_ = rst ? 1 : !(0|g47236);
// Gate A22-U216B
assign #0.2  g47326 = rst ? 0 : !(0|WCH34_|CHWL10_);
// Gate A22-U216A
assign #0.2  g47327 = rst ? 1 : !(0|g47326|g47328);
// Gate A22-U217A
assign #0.2  g47328 = rst ? 0 : !(0|CCH34|g47327);
// Gate A22-U138A
assign #0.2  LOW7_ = rst ? 1 : !(0|g47242);
// Gate A22-U234B
assign #0.2  WRD2B3 = rst ? 0 : !(0|LOW4_|HIGH3_|g47406);
// Gate A22-U232B
assign #0.2  WRD2B2 = rst ? 0 : !(0|LOW5_|HIGH3_|g47402);
// Gate A22-U245A
assign #0.2  g47444 = rst ? 1 : !(0|g47443|g47445);
// Gate A22-U224A
assign #0.2  g47314 = rst ? 1 : !(0|g47313|g47315);
// Gate A22-U243A
assign #0.2  g47449 = rst ? 1 : !(0|g47448|g47450);
// Gate A22-U256B
assign #0.2  g47422 = rst ? 0 : !(0|CHWL13_|WCH35_);
// Gate A22-U226B
assign #0.2  g47312 = rst ? 0 : !(0|HIGH1_|LOW5_|g47310);
// Gate A22-U112A
assign #0.2  DKCTR2_ = rst ? 0 : !(0|g47121);
// Gate A22-U214A
assign #0.2  g47331 = rst ? 1 : !(0|g47330|g47332);
// Gate A22-U215A
assign #0.2  g47332 = rst ? 0 : !(0|CCH34|g47331);
// Gate A22-U223B
assign #0.2  g47316 = rst ? 0 : !(0|HIGH0_|LOW2_|g47314);
// Gate A22-U134A
assign #0.2  g47251 = rst ? 0 : !(0|LOW1_|g47248|HIGH0_);
// Gate A22-U134B
assign #0.2  g47250 = rst ? 0 : !(0|LOW0_|HIGH0_|g47246);
// Gate A22-U242A
assign #0.2  g47450 = rst ? 0 : !(0|g47449|CCH35);
// Gate A22-U222B
assign #0.2  g47320 = rst ? 0 : !(0|HIGH0_|LOW3_|g47318);
// Gate A22-U247A
assign #0.2  g47441 = rst ? 0 : !(0|CCH35|g47440);
// Gate A22-U219B
assign #0.2  g47325 = rst ? 0 : !(0|HIGH0_|LOW4_|g47323);
// Gate A22-U153A
assign #0.2  g47219 = rst ? 0 : !(0|GOJAM|g47218);
// Gate A22-U212B
assign #0.2  g47338 = rst ? 0 : !(0|HIGH0_|LOW7_|g47336);
// Gate A22-U243B
assign #0.2  g47448 = rst ? 0 : !(0|CHWL07_|WCH35_);
// Gate A22-U102B
assign #0.2  g47104 = rst ? 0 : !(0|END|RDOUT_);
// Gate A22-U135B
assign #0.2  g47247 = rst ? 0 : !(0|g47246|CCH34);
// Gate A22-U123B
assign #0.2  g47130 = rst ? 1 : !(0|g47127|DLKCLR|g47129);
// Gate A22-U143A
assign #0.2  LOW2_ = rst ? 0 : !(0|g47232);
// Gate A22-U135A
assign #0.2  g47249 = rst ? 0 : !(0|g47248|CCH34);
// Gate A22-U123A
assign #0.2  g47129 = rst ? 0 : !(0|g47130|g47126);
// Gate A22-U153B
assign #0.2  g47218 = rst ? 0 : !(0|XB4_|CCHG_|XT1_);
// Gate A22-U139B
assign #0.2  g47240 = rst ? 0 : !(0|DKCTR1|DKCTR3_|DKCTR2_);
// Gate A22-U154A A22-U154B A22-U155A
assign #0.2  RCH13_ = rst ? 1 : !(0|g47210);
// Gate A22-U255B
assign #0.2  g47425 = rst ? 0 : !(0|LOW2_|HIGH2_|g47423);
// Gate A22-U130B
assign #0.2  DKCTR5_ = rst ? 1 : !(0|DLKCLR|g47141|DKCTR5);
// Gate A22-U257B
assign #0.2  g47420 = rst ? 0 : !(0|LOW1_|HIGH2_|g47418);
// Gate A22-U208B
assign #0.2  g47347 = rst ? 0 : !(0|HIGH1_|LOW1_|g47345);
// Gate A22-U149B A22-U148A A22-U148B
assign #0.2  RCH14_ = rst ? 1 : !(0|g47223);
// Gate A22-U115A
assign #0.2  g47149 = rst ? 0 : !(0|g47151);
// Gate A22-U116B
assign #0.2  g47160 = rst ? 1 : !(0);
// Gate A22-U104A
assign #0.2  g47108 = rst ? 0 : !(0|g47107);
// Gate A22-U104B
assign #0.2  g47107 = rst ? 1 : !(0|ADVCTR|DLKCLR);
// Gate A22-U213A
assign #0.2  g47336 = rst ? 1 : !(0|g47335|g47337);
// Gate A22-U212A
assign #0.2  g47337 = rst ? 0 : !(0|g47336|CCH34);
// Gate A22-U253A
assign #0.2  g47428 = rst ? 0 : !(0|CCH35|g47427);
// Gate A22-U252B
assign #0.2  g47426 = rst ? 0 : !(0|CHWL12_|WCH35_);
// Gate A22-U252A
assign #0.2  g47427 = rst ? 1 : !(0|g47426|g47428);
// Gate A22-U217B
assign #0.2  g47329 = rst ? 0 : !(0|HIGH0_|LOW5_|g47327);
// Gate A22-U110B
assign #0.2  g47117 = rst ? 0 : !(0|g47118|g47121);
// Gate A22-U240B
assign #0.2  g47455 = rst ? 0 : !(0|LOW1_|HIGH3_|g47453);
// Gate A22-U109A
assign #0.2  g47119 = rst ? 1 : !(0|g47118|g47120|g47112);
// Gate A22-U109B
assign #0.2  g47118 = rst ? 0 : !(0|g47119|g47112|g47117);
// Gate A22-U110A
assign #0.2  g47120 = rst ? 0 : !(0|g47122|g47119);
// Gate A22-U152A A22-U152B A22-U151A
assign #0.2  WCH14_ = rst ? 1 : !(0|g47214);
// Gate A22-U230A
assign #0.2  g47303 = rst ? 0 : !(0|CCH34|g47302);
// Gate A22-U106B
assign #0.2  d1CNT = rst ? 0 : !(0|g47110|g47113);
// Gate A22-U156B
assign #0.2  g47210 = rst ? 0 : !(0|XT1_|XB3_);
// Gate A22-U246B
assign #0.2  g47439 = rst ? 0 : !(0|CHWL09_|WCH35_);
// Gate A22-U214B
assign #0.2  g47330 = rst ? 0 : !(0|CHWL09_|WCH34_);
// Gate A22-U127B
assign #0.2  DKCTR4_ = rst ? 1 : !(0|g47135|DLKCLR|DKCTR4);
// Gate A22-U119B
assign #0.2  g47156 = rst ? 1 : !(0|g47155|g47157);
// Gate A22-U119A
assign #0.2  g47157 = rst ? 0 : !(0|g47156|CCH13);
// Gate A22-U255A
assign #0.2  g47424 = rst ? 0 : !(0|CCH35|g47423);
// Gate A22-U117B
assign #0.2  g47155 = rst ? 0 : !(0|WCH13_|CHWL07_);
// Gate A22-U203A
assign #0.2  g47353 = rst ? 1 : !(0|g47352|g47354);
// Gate A22-U226A
assign #0.2  g47311 = rst ? 0 : !(0|CCH34|g47310);
// Gate A22-U233B
assign #0.2  g47405 = rst ? 0 : !(0|CHWL03_|WCH35_);
// Gate A22-U234A
assign #0.2  g47407 = rst ? 0 : !(0|CCH35|g47406);
// Gate A22-U101A A22-U102A
assign #0.2  DLKCLR = rst ? 0 : !(0|g47101);
// Gate A22-U256A
assign #0.2  g47423 = rst ? 1 : !(0|g47422|g47424);
// Gate A22-U202A
assign #0.2  g47358 = rst ? 0 : !(0|CCH34|g47357);
// Gate A22-U201B
assign #0.2  g47356 = rst ? 0 : !(0|WCH34_|CHWL03_);
// Gate A22-U201A
assign #0.2  g47357 = rst ? 1 : !(0|g47356|g47358);
// Gate A22-U235B
assign #0.2  g47409 = rst ? 0 : !(0|CHWL04_|WCH35_);
// Gate A22-U236A
assign #0.2  g47411 = rst ? 0 : !(0|CCH35|g47410);
// Gate A22-U235A
assign #0.2  g47410 = rst ? 1 : !(0|g47409|g47411);
// Gate A22-U111B
assign #0.2  g47122 = rst ? 0 : !(0|g47119|DLKCLR|g47121);
// Gate A22-U260B
assign #0.2  g47413 = rst ? 0 : !(0|CHWL16_|WCH35_);
// Gate A22-U248B
assign #0.2  g47435 = rst ? 0 : !(0|CHWL10_|WCH35_);
// Gate A22-U249A
assign #0.2  g47437 = rst ? 0 : !(0|CCH35|g47436);
// Gate A22-U211A
assign #0.2  g47340 = rst ? 1 : !(0|g47339|g47341);
// Gate A22-U111A
assign #0.2  g47121 = rst ? 1 : !(0|g47122|g47118);
// Gate A22-U140A
assign #0.2  LOW5_ = rst ? 1 : !(0|g47238);
// Gate A22-U144B
assign #0.2  g47230 = rst ? 0 : !(0|DKCTR1_|DKCTR3|DKCTR2);
// Gate A22-U213B
assign #0.2  g47335 = rst ? 0 : !(0|WCH34_|CHWL08_);
// Gate A22-U145A
assign #0.2  LOW0_ = rst ? 1 : !(0|g47228);
// Gate A22-U143B
assign #0.2  g47232 = rst ? 1 : !(0|DKCTR2_|DKCTR1|DKCTR3);
// Gate A22-U144A
assign #0.2  LOW1_ = rst ? 1 : !(0|g47230);
// Gate A22-U227A
assign #0.2  g47306 = rst ? 1 : !(0|g47305|g47307);
// Gate A22-U113B
assign #0.2  F14H = rst ? 0 : !(0|FS14|FS13_|F12B_);
// Gate A22-U245B
assign #0.2  g47443 = rst ? 0 : !(0|CHWL08_|WCH35_);
// Gate A22-U117A
assign #0.2  F12B_ = rst ? 1 : !(0|F12B);
// Gate A22-U238B
assign #0.2  g47459 = rst ? 0 : !(0|LOW2_|HIGH3_|g47457);
// Gate A22-U230B
assign #0.2  WRD1BP = rst ? 0 : !(0|LOW7_|HIGH1_|g47302);
// Gate A22-U120A
assign #0.2  CH1307 = rst ? 0 : !(0|g47156|RCH13_);
// Gate A22-U249B
assign #0.2  g47438 = rst ? 0 : !(0|LOW5_|HIGH2_|g47436);
// Gate A22-U147B
assign #0.2  FS13_ = rst ? 1 : !(0|FS13);
// Gate A22-U259A
assign #0.2  g47415 = rst ? 0 : !(0|CCH35|g47614);
// Gate A22-U260A
assign #0.2  g47614 = rst ? 1 : !(0|g47413|g47415);
// Gate A22-U140B
assign #0.2  g47238 = rst ? 0 : !(0|DKCTR1_|DKCTR3_|DKCTR2);
// Gate A22-U202B
assign #0.2  g47359 = rst ? 0 : !(0|LOW4_|HIGH1_|g47357);
// Gate A22-U122B
assign #0.2  g47125 = rst ? 0 : !(0|g47126|g47129);
// Gate A22-U244A
assign #0.2  g47445 = rst ? 0 : !(0|CCH35|g47444);
// Gate A22-U142A
assign #0.2  LOW3_ = rst ? 1 : !(0|g47234);
// Gate A22-U228B
assign #0.2  WRD1B1 = rst ? 0 : !(0|HIGH1_|LOW6_|g47306);
// Gate A22-U121B
assign #0.2  g47126 = rst ? 1 : !(0|g47127|g47120|g47125);
// Gate A22-U122A
assign #0.2  g47128 = rst ? 0 : !(0|g47130|g47127);
// Gate A22-U121A
assign #0.2  g47127 = rst ? 0 : !(0|g47126|g47128|g47120);
// Gate A22-U221B
assign #0.2  g47317 = rst ? 0 : !(0|WCH34_|CHWL12_);
// Gate A22-U218B
assign #0.2  g47322 = rst ? 0 : !(0|WCH34_|CHWL11_);
// Gate A22-U118A
assign #0.2  g47153 = rst ? 0 : !(0|DLKCLR|WDORDR);
// Gate A22-U107B
assign #0.2  g47114 = rst ? 1 : !(0|g47111|DLKCLR|g47113);
// Gate A22-U258B
assign #0.2  g47417 = rst ? 0 : !(0|CHWL14_|WCH35_);
// Gate A22-U225A
assign #0.2  g47310 = rst ? 1 : !(0|g47309|g47311);
// Gate A22-U128B
assign #0.2  g47140 = rst ? 1 : !(0|g47141|g47136|d16CNT);
// Gate A22-U128A
assign #0.2  g47141 = rst ? 0 : !(0|g47140|d32CNT|g47136);
// Gate A22-U225B
assign #0.2  g47309 = rst ? 0 : !(0|WCH34_|CHWL02_);
// Gate A22-U107A
assign #0.2  g47113 = rst ? 0 : !(0|g47114|g47110);
// Gate A22-U228A
assign #0.2  g47307 = rst ? 0 : !(0|CCH34|g47306);
// Gate A22-U227B
assign #0.2  g47305 = rst ? 0 : !(0|CHWL01_|WCH34_);
// Gate A22-U132A
assign #0.2  g47254 = rst ? 0 : !(0|DATA_|WDORDR);
// Gate A22-U206B
assign #0.2  g47351 = rst ? 0 : !(0|HIGH1_|LOW2_|g47349);
// Gate A22-U137A
assign #0.2  g47245 = rst ? 0 : !(0|CHWL14_|WCH34_);
// Gate A22-U129A
assign #0.2  d32CNT = rst ? 0 : !(0|DKCTR5_|g47141);
// Gate A22-U206A
assign #0.2  g47350 = rst ? 0 : !(0|CCH34|g47349);
// Gate A22-U205B
assign #0.2  g47348 = rst ? 0 : !(0|WCH34_|CHWL05_);
// Gate A22-U205A
assign #0.2  g47349 = rst ? 1 : !(0|g47348|g47350);
// Gate A22-U253B
assign #0.2  g47429 = rst ? 0 : !(0|LOW3_|HIGH2_|g47427);
// Gate A22-U137B
assign #0.2  g47244 = rst ? 0 : !(0|CHWL16_|WCH34_);
// End of NOR gates

endmodule
