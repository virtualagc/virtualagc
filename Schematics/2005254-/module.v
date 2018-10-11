// Verilog module auto-generated for AGC module A20 by dumbVerilog.py

module A20 ( 
  rst, BKTF_, CA5_, CDUXD, CDUXM, CDUXP, CDUYD, CDUYM, CDUYP, CDUZD, CDUZM,
  CDUZP, CG26, CGA20, CXB0_, CXB1_, CXB5_, CXB6_, OCTAD2, OCTAD3, OCTAD4,
  OCTAD6, PIPXM, PIPXP, PIPYM, PIPYP, PIPZM, PIPZP, RSSB, SHAFTD, SHAFTM,
  SHAFTP, T1P, T2P, T3P, T4P, T5P, T6P, THRSTD, TRNM, TRNP, TRUND, XB2, XB3,
  XB4, XB7, CA2_, CA3_, CA4_, CG11, CG12, CG14, CG21, CG22, CG24, CXB2_,
  CXB3_, CXB4_, CXB7_, C24A, C24R, C25A, C25R, C26A, C26R, C27A, C27R, C30A,
  C30R, C31A, C31R, C32A, C32M, C32P, C32R, C33A, C33M, C33P, C33R, C34A,
  C34M, C34P, C34R, C35A, C35M, C35P, C35R, C36A, C36M, C36P, C36R, C37A,
  C37M, C37P, C37R, C40A, C40M, C40P, C40R, C41A, C41M, C41P, C41R, C50A,
  C50R, C51A, C51R, C52A, C52R, C53A, C53R, C54A, C54R, C55A, C55R, CA6_,
  CG13, CG23
);

input wire rst, BKTF_, CA5_, CDUXD, CDUXM, CDUXP, CDUYD, CDUYM, CDUYP, CDUZD,
  CDUZM, CDUZP, CG26, CGA20, CXB0_, CXB1_, CXB5_, CXB6_, OCTAD2, OCTAD3,
  OCTAD4, OCTAD6, PIPXM, PIPXP, PIPYM, PIPYP, PIPZM, PIPZP, RSSB, SHAFTD,
  SHAFTM, SHAFTP, T1P, T2P, T3P, T4P, T5P, T6P, THRSTD, TRNM, TRNP, TRUND,
  XB2, XB3, XB4, XB7;

inout wire CA2_, CA3_, CA4_, CG11, CG12, CG14, CG21, CG22, CG24, CXB2_, CXB3_,
  CXB4_, CXB7_;

output wire C24A, C24R, C25A, C25R, C26A, C26R, C27A, C27R, C30A, C30R, C31A,
  C31R, C32A, C32M, C32P, C32R, C33A, C33M, C33P, C33R, C34A, C34M, C34P,
  C34R, C35A, C35M, C35P, C35R, C36A, C36M, C36P, C36R, C37A, C37M, C37P,
  C37R, C40A, C40M, C40P, C40R, C41A, C41M, C41P, C41R, C50A, C50R, C51A,
  C51R, C52A, C52R, C53A, C53R, C54A, C54R, C55A, C55R, CA6_, CG13, CG23;

// Gate A20-U208B A20-U206B
pullup(g31351);
assign #0.2  g31351 = rst ? 0 : ((0|CG26|g31333|g31347|g31340) ? 1'b0 : 1'bz);
// Gate A20-U142B
pullup(C32P);
assign #0.2  C32P = rst ? 0 : ((0|g31102|CA3_|CXB2_) ? 1'b0 : 1'bz);
// Gate A20-U125B
pullup(g31233);
assign #0.2  g31233 = rst ? 0 : ((0|g31232|C27R) ? 1'b0 : 1'bz);
// Gate A20-U124B
pullup(C27R);
assign #0.2  C27R = rst ? 0 : ((0|g31211|CXB7_|CA2_) ? 1'b0 : 1'bz);
// Gate A20-U208A
pullup(g31320);
assign #0.2  g31320 = rst ? 0 : ((0|C37R|g31319) ? 1'b0 : 1'bz);
// Gate A20-U221A
pullup(C36M);
assign #0.2  C36M = rst ? 0 : ((0|CXB6_|CA3_|g31309) ? 1'b0 : 1'bz);
// Gate A20-U111A
pullup(g31219);
assign #0.2  g31219 = rst ? 1'bz : ((0|g31218|g31220) ? 1'b0 : 1'bz);
// Gate A20-U225A
pullup(C36A);
assign #0.2  C36A = rst ? 0 : ((0|CG12|g31306) ? 1'b0 : 1'bz);
// Gate A20-U226A
pullup(g31306);
assign #0.2  g31306 = rst ? 1'bz : ((0|g31305|g31307) ? 1'b0 : 1'bz);
// Gate A20-U237A
pullup(C53R);
assign #0.2  C53R = rst ? 0 : ((0|CXB3_|CA5_|g31411) ? 1'b0 : 1'bz);
// Gate A20-U126B
pullup(C27A);
assign #0.2  C27A = rst ? 0 : ((0|g31232|CG21) ? 1'b0 : 1'bz);
// Gate A20-U120B
pullup(g31239);
assign #0.2  g31239 = rst ? 1'bz : ((0|g31240|g31238) ? 1'b0 : 1'bz);
// Gate A20-U219A
pullup(C36P);
assign #0.2  C36P = rst ? 0 : ((0|CXB6_|CA3_|g31302) ? 1'b0 : 1'bz);
// Gate A20-U203A
pullup(g31325);
assign #0.2  g31325 = rst ? 0 : ((0|C37R|g31324) ? 1'b0 : 1'bz);
// Gate A20-U220A
pullup(C36R);
assign #0.2  C36R = rst ? 0 : ((0|CXB6_|CA3_|g31311) ? 1'b0 : 1'bz);
// Gate A20-U230B
pullup(g31330);
assign #0.2  g31330 = rst ? 0 : ((0|g31329|C50R) ? 1'b0 : 1'bz);
// Gate A20-U115A
pullup(g31216);
assign #0.2  g31216 = rst ? 0 : ((0|g31215|C35R) ? 1'b0 : 1'bz);
// Gate A20-U157B
pullup(g31124);
assign #0.2  g31124 = rst ? 1'bz : ((0|g31125|CDUYM) ? 1'b0 : 1'bz);
// Gate A20-U113A
pullup(g31218);
assign #0.2  g31218 = rst ? 0 : ((0|g31217|g31201) ? 1'b0 : 1'bz);
// Gate A20-U245A
pullup(g31444);
assign #0.2  g31444 = rst ? 0 : ((0|g31443|C55R) ? 1'b0 : 1'bz);
// Gate A20-U241B
pullup(C40R);
assign #0.2  C40R = rst ? 0 : ((0|g31411|CXB0_|CA4_) ? 1'b0 : 1'bz);
// Gate A20-U246A
pullup(g31443);
assign #0.2  g31443 = rst ? 1'bz : ((0|g31444|THRSTD) ? 1'b0 : 1'bz);
// Gate A20-U248A
pullup(g31445);
assign #0.2  g31445 = rst ? 0 : ((0|g31401|g31443) ? 1'b0 : 1'bz);
// Gate A20-U246B
pullup(g31416);
assign #0.2  g31416 = rst ? 0 : ((0|g31415|C41R) ? 1'b0 : 1'bz);
// Gate A20-U207B
pullup(CG24);
assign #0.2  CG24 = rst ? 1'bz : ((0|g31351) ? 1'b0 : 1'bz);
// Gate A20-U258B
pullup(g31425);
assign #0.2  g31425 = rst ? 0 : ((0|g31424|C41R) ? 1'b0 : 1'bz);
// Gate A20-U154A
pullup(CG21);
assign #0.2  CG21 = rst ? 0 : ((0|g31150) ? 1'b0 : 1'bz);
// Gate A20-U107B
pullup(CG22);
assign #0.2  CG22 = rst ? 0 : ((0|g31251) ? 1'b0 : 1'bz);
// Gate A20-U254A
pullup(CG23);
assign #0.2  CG23 = rst ? 1'bz : ((0|g31450) ? 1'b0 : 1'bz);
// Gate A20-U234A
pullup(g31432);
assign #0.2  g31432 = rst ? 1'bz : ((0|g31433|g31431) ? 1'b0 : 1'bz);
// Gate A20-U242B
pullup(C40P);
assign #0.2  C40P = rst ? 0 : ((0|g31402|CA4_|CXB0_) ? 1'b0 : 1'bz);
// Gate A20-U128B
pullup(g31231);
assign #0.2  g31231 = rst ? 0 : ((0|g31201|g31229) ? 1'b0 : 1'bz);
// Gate A20-U254B
pullup(g31422);
assign #0.2  g31422 = rst ? 1'bz : ((0|g31420|CG14|g31407) ? 1'b0 : 1'bz);
// Gate A20-U222B
pullup(g31336);
assign #0.2  g31336 = rst ? 1'bz : ((0|g31337|CDUYD) ? 1'b0 : 1'bz);
// Gate A20-U135A
pullup(C24A);
assign #0.2  C24A = rst ? 0 : ((0|g31132) ? 1'b0 : 1'bz);
// Gate A20-U114B
pullup(C31R);
assign #0.2  C31R = rst ? 0 : ((0|g31211|CXB1_|CA3_) ? 1'b0 : 1'bz);
// Gate A20-U236B
pullup(C40A);
assign #0.2  C40A = rst ? 0 : ((0|g31406|CG14) ? 1'b0 : 1'bz);
// Gate A20-U109B A20-U110B
pullup(C31A);
assign #0.2  C31A = rst ? 0 : ((0|g31246|g31240|CG21|g31233) ? 1'b0 : 1'bz);
// Gate A20-U137A
pullup(C24R);
assign #0.2  C24R = rst ? 0 : ((0|CXB4_|CA2_|g31111) ? 1'b0 : 1'bz);
// Gate A20-U127B
pullup(g31232);
assign #0.2  g31232 = rst ? 1'bz : ((0|g31233|g31231) ? 1'b0 : 1'bz);
// Gate A20-U240B
pullup(C40M);
assign #0.2  C40M = rst ? 0 : ((0|g31409|CA4_|CXB0_) ? 1'b0 : 1'bz);
// Gate A20-U203B A20-U202B
pullup(CXB3_);
assign #0.2  CXB3_ = rst ? 1'bz : ((0|XB3) ? 1'b0 : 1'bz);
// Gate A20-U255A A20-U253A
pullup(g31450);
assign #0.2  g31450 = rst ? 0 : ((0|g31440|g31447|CG24|g31433) ? 1'b0 : 1'bz);
// Gate A20-U237B
pullup(g31407);
assign #0.2  g31407 = rst ? 0 : ((0|g31406|C40R) ? 1'b0 : 1'bz);
// Gate A20-U201B
pullup(CA2_);
assign #0.2  CA2_ = rst ? 1'bz : ((0|OCTAD2) ? 1'b0 : 1'bz);
// Gate A20-U235B
pullup(g31406);
assign #0.2  g31406 = rst ? 1'bz : ((0|g31405|g31407) ? 1'b0 : 1'bz);
// Gate A20-U150A
pullup(g31147);
assign #0.2  g31147 = rst ? 0 : ((0|C26R|g31146) ? 1'b0 : 1'bz);
// Gate A20-U247B
pullup(g31418);
assign #0.2  g31418 = rst ? 0 : ((0|g31417|g31401) ? 1'b0 : 1'bz);
// Gate A20-U130A
pullup(g31202);
assign #0.2  g31202 = rst ? 1'bz : ((0|CDUZP|g31203) ? 1'b0 : 1'bz);
// Gate A20-U213B
pullup(g31345);
assign #0.2  g31345 = rst ? 0 : ((0|g31343|g31301) ? 1'b0 : 1'bz);
// Gate A20-U216A
pullup(g31315);
assign #0.2  g31315 = rst ? 1'bz : ((0|PIPXP|g31316) ? 1'b0 : 1'bz);
// Gate A20-U147B
pullup(g31118);
assign #0.2  g31118 = rst ? 0 : ((0|g31117|g31101) ? 1'b0 : 1'bz);
// Gate A20-U250B
pullup(g31419);
assign #0.2  g31419 = rst ? 1'bz : ((0|g31418|g31420) ? 1'b0 : 1'bz);
// Gate A20-U145B
pullup(g31115);
assign #0.2  g31115 = rst ? 1'bz : ((0|g31116|CDUYP) ? 1'b0 : 1'bz);
// Gate A20-U243B
pullup(g31401);
assign #0.2  g31401 = rst ? 1'bz : ((0|BKTF_) ? 1'b0 : 1'bz);
// Gate A20-U121A
pullup(C34M);
assign #0.2  C34M = rst ? 0 : ((0|CXB4_|CA3_|g31209) ? 1'b0 : 1'bz);
// Gate A20-U146A
pullup(g31143);
assign #0.2  g31143 = rst ? 1'bz : ((0|T3P|g31144) ? 1'b0 : 1'bz);
// Gate A20-U228B
pullup(g32331);
assign #0.2  g32331 = rst ? 0 : ((0|g31301|g31329) ? 1'b0 : 1'bz);
// Gate A20-U219B
pullup(C51A);
assign #0.2  C51A = rst ? 0 : ((0|g31339|CG26|g31333) ? 1'b0 : 1'bz);
// Gate A20-U125A
pullup(C34A);
assign #0.2  C34A = rst ? 0 : ((0|CG11|g31206) ? 1'b0 : 1'bz);
// Gate A20-U146B
pullup(g31116);
assign #0.2  g31116 = rst ? 0 : ((0|g31115|C33R) ? 1'b0 : 1'bz);
// Gate A20-U116B
pullup(g31244);
assign #0.2  g31244 = rst ? 0 : ((0|g31243|C31R) ? 1'b0 : 1'bz);
// Gate A20-U148B
pullup(g31117);
assign #0.2  g31117 = rst ? 1'bz : ((0|g31116|g31125) ? 1'b0 : 1'bz);
// Gate A20-U132B
pullup(g31103);
assign #0.2  g31103 = rst ? 0 : ((0|g31102|C32R) ? 1'b0 : 1'bz);
// Gate A20-U148A
pullup(g31145);
assign #0.2  g31145 = rst ? 0 : ((0|g31101|g31143) ? 1'b0 : 1'bz);
// Gate A20-U120A
pullup(C34R);
assign #0.2  C34R = rst ? 0 : ((0|CXB4_|CA3_|g31211) ? 1'b0 : 1'bz);
// Gate A20-U217B
pullup(C51R);
assign #0.2  C51R = rst ? 0 : ((0|g31311|CA5_|CXB1_) ? 1'b0 : 1'bz);
// Gate A20-U119A
pullup(C34P);
assign #0.2  C34P = rst ? 0 : ((0|CXB4_|CA3_|g31202) ? 1'b0 : 1'bz);
// Gate A20-U240A
pullup(g31438);
assign #0.2  g31438 = rst ? 0 : ((0|g31401|g31436) ? 1'b0 : 1'bz);
// Gate A20-U158B
pullup(g31125);
assign #0.2  g31125 = rst ? 0 : ((0|g31124|C33R) ? 1'b0 : 1'bz);
// Gate A20-U229A
pullup(g31303);
assign #0.2  g31303 = rst ? 0 : ((0|g31302|C36R) ? 1'b0 : 1'bz);
// Gate A20-U217A
pullup(g31301);
assign #0.2  g31301 = rst ? 1'bz : ((0|BKTF_) ? 1'b0 : 1'bz);
// Gate A20-U249A
pullup(g31446);
assign #0.2  g31446 = rst ? 1'bz : ((0|g31447|g31445) ? 1'b0 : 1'bz);
// Gate A20-U229B
pullup(g31329);
assign #0.2  g31329 = rst ? 1'bz : ((0|g31330|CDUXD) ? 1'b0 : 1'bz);
// Gate A20-U250A
pullup(g31447);
assign #0.2  g31447 = rst ? 0 : ((0|C55R|g31446) ? 1'b0 : 1'bz);
// Gate A20-U213A
pullup(g31318);
assign #0.2  g31318 = rst ? 0 : ((0|g31317|g31301) ? 1'b0 : 1'bz);
// Gate A20-U126A
pullup(g31206);
assign #0.2  g31206 = rst ? 1'bz : ((0|g31205|g31207) ? 1'b0 : 1'bz);
// Gate A20-U153B
pullup(g31120);
assign #0.2  g31120 = rst ? 0 : ((0|g31119|C33R) ? 1'b0 : 1'bz);
// Gate A20-U150B
pullup(g31119);
assign #0.2  g31119 = rst ? 1'bz : ((0|g31118|g31120) ? 1'b0 : 1'bz);
// Gate A20-U123B
pullup(g31237);
assign #0.2  g31237 = rst ? 0 : ((0|g31236|C30R) ? 1'b0 : 1'bz);
// Gate A20-U143A
pullup(g31140);
assign #0.2  g31140 = rst ? 0 : ((0|C25R|g31139) ? 1'b0 : 1'bz);
// Gate A20-U127A
pullup(g31205);
assign #0.2  g31205 = rst ? 0 : ((0|g31204|g31201) ? 1'b0 : 1'bz);
// Gate A20-U141A
pullup(g31139);
assign #0.2  g31139 = rst ? 1'bz : ((0|g31140|g31138) ? 1'b0 : 1'bz);
// Gate A20-U129B
pullup(g31229);
assign #0.2  g31229 = rst ? 1'bz : ((0|g31230|T4P) ? 1'b0 : 1'bz);
// Gate A20-U201A
pullup(C37M);
assign #0.2  C37M = rst ? 0 : ((0|g31324|CA3_|CXB7_) ? 1'b0 : 1'bz);
// Gate A20-U147A
pullup(C26R);
assign #0.2  C26R = rst ? 0 : ((0|CA2_|CXB6_|g31111) ? 1'b0 : 1'bz);
// Gate A20-U215A
pullup(g31316);
assign #0.2  g31316 = rst ? 0 : ((0|g31315|C37R) ? 1'b0 : 1'bz);
// Gate A20-U233B
pullup(g31404);
assign #0.2  g31404 = rst ? 1'bz : ((0|g31410|g31403) ? 1'b0 : 1'bz);
// Gate A20-U226B
pullup(C50A);
assign #0.2  C50A = rst ? 0 : ((0|g31332|CG26) ? 1'b0 : 1'bz);
// Gate A20-U129A
pullup(g31203);
assign #0.2  g31203 = rst ? 0 : ((0|g31202|C34R) ? 1'b0 : 1'bz);
// Gate A20-U248B
pullup(g31417);
assign #0.2  g31417 = rst ? 1'bz : ((0|g31416|g31425) ? 1'b0 : 1'bz);
// Gate A20-U224A
pullup(g31307);
assign #0.2  g31307 = rst ? 0 : ((0|g31306|C36R) ? 1'b0 : 1'bz);
// Gate A20-U209A
pullup(C37A);
assign #0.2  C37A = rst ? 0 : ((0|g31307|CG12|g31319) ? 1'b0 : 1'bz);
// Gate A20-U233A
pullup(g31431);
assign #0.2  g31431 = rst ? 0 : ((0|g31401|g31429) ? 1'b0 : 1'bz);
// Gate A20-U151A A20-U152A
pullup(C26A);
assign #0.2  C26A = rst ? 0 : ((0|g31133|g31140|g31146) ? 1'b0 : 1'bz);
// Gate A20-U107A
pullup(g31222);
assign #0.2  g31222 = rst ? 1'bz : ((0|g31207|CG11|g31220) ? 1'b0 : 1'bz);
// Gate A20-U218A
pullup(g31311);
assign #0.2  g31311 = rst ? 1'bz : ((0|RSSB) ? 1'b0 : 1'bz);
// Gate A20-U211A
pullup(g31319);
assign #0.2  g31319 = rst ? 1'bz : ((0|g31318|g31320) ? 1'b0 : 1'bz);
// Gate A20-U105B A20-U104B A20-U156A A20-U157A
pullup(CA3_);
assign #0.2  CA3_ = rst ? 1'bz : ((0|OCTAD3) ? 1'b0 : 1'bz);
// Gate A20-U227B
pullup(g31332);
assign #0.2  g31332 = rst ? 1'bz : ((0|g31333|g32331) ? 1'b0 : 1'bz);
// Gate A20-U202A
pullup(C37R);
assign #0.2  C37R = rst ? 0 : ((0|g31311|CA3_|CXB7_) ? 1'b0 : 1'bz);
// Gate A20-U212A
pullup(C37P);
assign #0.2  C37P = rst ? 0 : ((0|CXB7_|g31315|CA3_) ? 1'b0 : 1'bz);
// Gate A20-U205A
pullup(CG14);
assign #0.2  CG14 = rst ? 0 : ((0|g31322) ? 1'b0 : 1'bz);
// Gate A20-U155B
pullup(g31159);
assign #0.2  g31159 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A20-U158A A20-U159A
pullup(g31157);
assign #0.2  g31157 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A20-U156B
pullup(CG11);
assign #0.2  CG11 = rst ? 0 : ((0|g31122) ? 1'b0 : 1'bz);
// Gate A20-U231B
pullup(g31402);
assign #0.2  g31402 = rst ? 1'bz : ((0|PIPYP|g31403) ? 1'b0 : 1'bz);
// Gate A20-U256B
pullup(CG13);
assign #0.2  CG13 = rst ? 0 : ((0|g31422) ? 1'b0 : 1'bz);
// Gate A20-U105A
pullup(CG12);
assign #0.2  CG12 = rst ? 0 : ((0|g31222) ? 1'b0 : 1'bz);
// Gate A20-U231A
pullup(g31430);
assign #0.2  g31430 = rst ? 0 : ((0|C53R|g31429) ? 1'b0 : 1'bz);
// Gate A20-U232A
pullup(g31429);
assign #0.2  g31429 = rst ? 1'bz : ((0|g31430|TRUND) ? 1'b0 : 1'bz);
// Gate A20-U204A
pullup(g31324);
assign #0.2  g31324 = rst ? 1'bz : ((0|PIPXM|g31325) ? 1'b0 : 1'bz);
// Gate A20-U241A
pullup(g31439);
assign #0.2  g31439 = rst ? 1'bz : ((0|g31440|g31438) ? 1'b0 : 1'bz);
// Gate A20-U243A
pullup(g31440);
assign #0.2  g31440 = rst ? 0 : ((0|C54R|g31439) ? 1'b0 : 1'bz);
// Gate A20-U224B
pullup(C50R);
assign #0.2  C50R = rst ? 0 : ((0|g31311|CXB0_|CA5_) ? 1'b0 : 1'bz);
// Gate A20-U121B
pullup(g31238);
assign #0.2  g31238 = rst ? 0 : ((0|g31236|g31201) ? 1'b0 : 1'bz);
// Gate A20-U215B
pullup(g31343);
assign #0.2  g31343 = rst ? 1'bz : ((0|g31344|CDUZD) ? 1'b0 : 1'bz);
// Gate A20-U216B
pullup(g31344);
assign #0.2  g31344 = rst ? 0 : ((0|g31343|C52R) ? 1'b0 : 1'bz);
// Gate A20-U139A
pullup(g31136);
assign #0.2  g31136 = rst ? 1'bz : ((0|g31137|T1P) ? 1'b0 : 1'bz);
// Gate A20-U141B
pullup(C32R);
assign #0.2  C32R = rst ? 0 : ((0|g31111|CXB2_|CA3_) ? 1'b0 : 1'bz);
// Gate A20-U138A
pullup(g31137);
assign #0.2  g31137 = rst ? 0 : ((0|g31136|C25R) ? 1'b0 : 1'bz);
// Gate A20-U139B
pullup(g31109);
assign #0.2  g31109 = rst ? 1'bz : ((0|g31110|CDUXM) ? 1'b0 : 1'bz);
// Gate A20-U221B
pullup(g31338);
assign #0.2  g31338 = rst ? 0 : ((0|g31336|g31301) ? 1'b0 : 1'bz);
// Gate A20-U122A
pullup(g31209);
assign #0.2  g31209 = rst ? 1'bz : ((0|CDUZM|g31210) ? 1'b0 : 1'bz);
// Gate A20-U122B
pullup(g31236);
assign #0.2  g31236 = rst ? 1'bz : ((0|g31237|T5P) ? 1'b0 : 1'bz);
// Gate A20-U235A
pullup(C53A);
assign #0.2  C53A = rst ? 0 : ((0|CG24|g31432) ? 1'b0 : 1'bz);
// Gate A20-U136B
pullup(C32A);
assign #0.2  C32A = rst ? 0 : ((0|g31106|CG22) ? 1'b0 : 1'bz);
// Gate A20-U228A
pullup(g31304);
assign #0.2  g31304 = rst ? 1'bz : ((0|g31303|g31310) ? 1'b0 : 1'bz);
// Gate A20-U116A
pullup(g31215);
assign #0.2  g31215 = rst ? 1'bz : ((0|TRNP|g31216) ? 1'b0 : 1'bz);
// Gate A20-U140B
pullup(C32M);
assign #0.2  C32M = rst ? 0 : ((0|g31109|CA3_|CXB2_) ? 1'b0 : 1'bz);
// Gate A20-U113B
pullup(g31245);
assign #0.2  g31245 = rst ? 0 : ((0|g31243|g31201) ? 1'b0 : 1'bz);
// Gate A20-U155A A20-U153A
pullup(g31150);
assign #0.2  g31150 = rst ? 1'bz : ((0|g31140|g31147|g31133) ? 1'b0 : 1'bz);
// Gate A20-U218B
pullup(g31340);
assign #0.2  g31340 = rst ? 0 : ((0|g31339|C51R) ? 1'b0 : 1'bz);
// Gate A20-U223B
pullup(g31337);
assign #0.2  g31337 = rst ? 0 : ((0|g31336|C51R) ? 1'b0 : 1'bz);
// Gate A20-U223A
pullup(g31310);
assign #0.2  g31310 = rst ? 0 : ((0|C36R|g31309) ? 1'b0 : 1'bz);
// Gate A20-U133A
pullup(g31131);
assign #0.2  g31131 = rst ? 0 : ((0|g31101|g31129) ? 1'b0 : 1'bz);
// Gate A20-U220B
pullup(g31339);
assign #0.2  g31339 = rst ? 1'bz : ((0|g31340|g31338) ? 1'b0 : 1'bz);
// Gate A20-U143B
pullup(g31101);
assign #0.2  g31101 = rst ? 1'bz : ((0|BKTF_) ? 1'b0 : 1'bz);
// Gate A20-U212B
pullup(g31346);
assign #0.2  g31346 = rst ? 1'bz : ((0|g31347|g31345) ? 1'b0 : 1'bz);
// Gate A20-U138B
pullup(g31110);
assign #0.2  g31110 = rst ? 0 : ((0|g31109|C32R) ? 1'b0 : 1'bz);
// Gate A20-U211B
pullup(g31347);
assign #0.2  g31347 = rst ? 0 : ((0|g31346|C52R) ? 1'b0 : 1'bz);
// Gate A20-U133B
pullup(g31104);
assign #0.2  g31104 = rst ? 1'bz : ((0|g31110|g31103) ? 1'b0 : 1'bz);
// Gate A20-U128A
pullup(g31204);
assign #0.2  g31204 = rst ? 1'bz : ((0|g31203|g31210) ? 1'b0 : 1'bz);
// Gate A20-U104A
pullup(g31224);
assign #0.2  g31224 = rst ? 1'bz : ((0|TRNM|g31225) ? 1'b0 : 1'bz);
// Gate A20-U145A
pullup(g31144);
assign #0.2  g31144 = rst ? 0 : ((0|g31143|C26R) ? 1'b0 : 1'bz);
// Gate A20-U214B
pullup(C52R);
assign #0.2  C52R = rst ? 0 : ((0|g31311|CXB2_|CA5_) ? 1'b0 : 1'bz);
// Gate A20-U112A
pullup(C35P);
assign #0.2  C35P = rst ? 0 : ((0|CXB5_|g31215|CA3_) ? 1'b0 : 1'bz);
// Gate A20-U102A
pullup(C35R);
assign #0.2  C35R = rst ? 0 : ((0|g31211|CA3_|CXB5_) ? 1'b0 : 1'bz);
// Gate A20-U108B A20-U106B
pullup(g31251);
assign #0.2  g31251 = rst ? 1'bz : ((0|CG21|g31233|g31247|g31240) ? 1'b0 : 1'bz);
// Gate A20-U117B
pullup(C30R);
assign #0.2  C30R = rst ? 0 : ((0|g31211|CA3_|CXB0_) ? 1'b0 : 1'bz);
// Gate A20-U230A
pullup(g31302);
assign #0.2  g31302 = rst ? 1'bz : ((0|SHAFTP|g31303) ? 1'b0 : 1'bz);
// Gate A20-U118A
pullup(g31211);
assign #0.2  g31211 = rst ? 1'bz : ((0|RSSB) ? 1'b0 : 1'bz);
// Gate A20-U154B
pullup(g31122);
assign #0.2  g31122 = rst ? 1'bz : ((0|g31120|CG22|g31107) ? 1'b0 : 1'bz);
// Gate A20-U225B
pullup(g31333);
assign #0.2  g31333 = rst ? 0 : ((0|g31332|C50R) ? 1'b0 : 1'bz);
// Gate A20-U109A
pullup(C35A);
assign #0.2  C35A = rst ? 0 : ((0|g31207|CG11|g31219) ? 1'b0 : 1'bz);
// Gate A20-U257B
pullup(g31424);
assign #0.2  g31424 = rst ? 1'bz : ((0|g31425|PIPZM) ? 1'b0 : 1'bz);
// Gate A20-U209B A20-U210B
pullup(C52A);
assign #0.2  C52A = rst ? 0 : ((0|g31346|g31340|CG26|g31333) ? 1'b0 : 1'bz);
// Gate A20-U101A
pullup(C35M);
assign #0.2  C35M = rst ? 0 : ((0|g31224|CA3_|CXB5_) ? 1'b0 : 1'bz);
// Gate A20-U232B
pullup(g31403);
assign #0.2  g31403 = rst ? 0 : ((0|g31402|C40R) ? 1'b0 : 1'bz);
// Gate A20-U227A
pullup(g31305);
assign #0.2  g31305 = rst ? 0 : ((0|g31304|g31301) ? 1'b0 : 1'bz);
// Gate A20-U130B
pullup(g31230);
assign #0.2  g31230 = rst ? 0 : ((0|g31229|C27R) ? 1'b0 : 1'bz);
// Gate A20-U260A
pullup(CA6_);
assign #0.2  CA6_ = rst ? 1'bz : ((0|OCTAD6) ? 1'b0 : 1'bz);
// Gate A20-U108A
pullup(g31220);
assign #0.2  g31220 = rst ? 0 : ((0|C35R|g31219) ? 1'b0 : 1'bz);
// Gate A20-U140A
pullup(g31138);
assign #0.2  g31138 = rst ? 0 : ((0|g31101|g31136) ? 1'b0 : 1'bz);
// Gate A20-U124A
pullup(g31207);
assign #0.2  g31207 = rst ? 0 : ((0|g31206|C34R) ? 1'b0 : 1'bz);
// Gate A20-U134B
pullup(g31105);
assign #0.2  g31105 = rst ? 0 : ((0|g31104|g31101) ? 1'b0 : 1'bz);
// Gate A20-U103B A20-U102B
pullup(CXB2_);
assign #0.2  CXB2_ = rst ? 1'bz : ((0|XB2) ? 1'b0 : 1'bz);
// Gate A20-U238B
pullup(g31410);
assign #0.2  g31410 = rst ? 0 : ((0|g31409|C40R) ? 1'b0 : 1'bz);
// Gate A20-U136A
pullup(g31133);
assign #0.2  g31133 = rst ? 0 : ((0|C24R|g31132) ? 1'b0 : 1'bz);
// Gate A20-U134A
pullup(g31132);
assign #0.2  g31132 = rst ? 1'bz : ((0|g31133|g31131) ? 1'b0 : 1'bz);
// Gate A20-U260B
pullup(C41R);
assign #0.2  C41R = rst ? 0 : ((0|CXB1_|CA4_|g31411) ? 1'b0 : 1'bz);
// Gate A20-U251A A20-U252A
pullup(C55A);
assign #0.2  C55A = rst ? 0 : ((0|CG24|g31433|g31440|g31446) ? 1'b0 : 1'bz);
// Gate A20-U123A
pullup(g31210);
assign #0.2  g31210 = rst ? 0 : ((0|C34R|g31209) ? 1'b0 : 1'bz);
// Gate A20-U142A
pullup(C25A);
assign #0.2  C25A = rst ? 0 : ((0|g31139|g31133) ? 1'b0 : 1'bz);
// Gate A20-U106A
pullup(g31259);
assign #0.2  g31259 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A20-U112B
pullup(g31246);
assign #0.2  g31246 = rst ? 1'bz : ((0|g31247|g31245) ? 1'b0 : 1'bz);
// Gate A20-U236A
pullup(g31433);
assign #0.2  g31433 = rst ? 0 : ((0|C53R|g31432) ? 1'b0 : 1'bz);
// Gate A20-U247A
pullup(C55R);
assign #0.2  C55R = rst ? 0 : ((0|CA5_|CXB5_|g31411) ? 1'b0 : 1'bz);
// Gate A20-U252B
pullup(C41A);
assign #0.2  C41A = rst ? 0 : ((0|CG14|g31419|g31407) ? 1'b0 : 1'bz);
// Gate A20-U144B
pullup(C25R);
assign #0.2  C25R = rst ? 0 : ((0|CXB5_|g31111|CA2_) ? 1'b0 : 1'bz);
// Gate A20-U258A A20-U259A
pullup(CXB4_);
assign #0.2  CXB4_ = rst ? 1'bz : ((0|XB4) ? 1'b0 : 1'bz);
// Gate A20-U255B
pullup(g31459);
assign #0.2  g31459 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A20-U119B
pullup(C30A);
assign #0.2  C30A = rst ? 0 : ((0|g31239|CG21|g31233) ? 1'b0 : 1'bz);
// Gate A20-U249B
pullup(C41P);
assign #0.2  C41P = rst ? 0 : ((0|CXB1_|g31415|CA4_) ? 1'b0 : 1'bz);
// Gate A20-U222A
pullup(g31309);
assign #0.2  g31309 = rst ? 1'bz : ((0|SHAFTM|g31310) ? 1'b0 : 1'bz);
// Gate A20-U259B
pullup(C41M);
assign #0.2  C41M = rst ? 0 : ((0|g31424|CA4_|CXB1_) ? 1'b0 : 1'bz);
// Gate A20-U234B
pullup(g31405);
assign #0.2  g31405 = rst ? 0 : ((0|g31404|g31401) ? 1'b0 : 1'bz);
// Gate A20-U244A
pullup(g31411);
assign #0.2  g31411 = rst ? 1'bz : ((0|RSSB) ? 1'b0 : 1'bz);
// Gate A20-U101B A20-U160A
pullup(CXB7_);
assign #0.2  CXB7_ = rst ? 1'bz : ((0|XB7) ? 1'b0 : 1'bz);
// Gate A20-U245B
pullup(g31415);
assign #0.2  g31415 = rst ? 1'bz : ((0|g31416|PIPZP) ? 1'b0 : 1'bz);
// Gate A20-U205B A20-U204B A20-U256A A20-U257A
pullup(CA4_);
assign #0.2  CA4_ = rst ? 1'bz : ((0|OCTAD4) ? 1'b0 : 1'bz);
// Gate A20-U160B
pullup(C33R);
assign #0.2  C33R = rst ? 0 : ((0|CXB3_|CA3_|g31111) ? 1'b0 : 1'bz);
// Gate A20-U131B
pullup(g31102);
assign #0.2  g31102 = rst ? 1'bz : ((0|CDUXP|g31103) ? 1'b0 : 1'bz);
// Gate A20-U149B
pullup(C33P);
assign #0.2  C33P = rst ? 0 : ((0|CXB3_|g31115|CA3_) ? 1'b0 : 1'bz);
// Gate A20-U206A
pullup(g31359);
assign #0.2  g31359 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A20-U242A
pullup(C54A);
assign #0.2  C54A = rst ? 0 : ((0|g31439|CG24|g31433) ? 1'b0 : 1'bz);
// Gate A20-U214A
pullup(g31317);
assign #0.2  g31317 = rst ? 1'bz : ((0|g31316|g31325) ? 1'b0 : 1'bz);
// Gate A20-U207A
pullup(g31322);
assign #0.2  g31322 = rst ? 1'bz : ((0|g31307|CG12|g31320) ? 1'b0 : 1'bz);
// Gate A20-U132A
pullup(g31129);
assign #0.2  g31129 = rst ? 1'bz : ((0|g31130|T2P) ? 1'b0 : 1'bz);
// Gate A20-U131A
pullup(g31130);
assign #0.2  g31130 = rst ? 0 : ((0|C24R|g31129) ? 1'b0 : 1'bz);
// Gate A20-U253B
pullup(g31420);
assign #0.2  g31420 = rst ? 0 : ((0|g31419|C41R) ? 1'b0 : 1'bz);
// Gate A20-U115B
pullup(g31243);
assign #0.2  g31243 = rst ? 1'bz : ((0|g31244|T6P) ? 1'b0 : 1'bz);
// Gate A20-U152B
pullup(C33A);
assign #0.2  C33A = rst ? 0 : ((0|CG22|g31119|g31107) ? 1'b0 : 1'bz);
// Gate A20-U117A
pullup(g31201);
assign #0.2  g31201 = rst ? 1'bz : ((0|BKTF_) ? 1'b0 : 1'bz);
// Gate A20-U114A
pullup(g31217);
assign #0.2  g31217 = rst ? 1'bz : ((0|g31216|g31225) ? 1'b0 : 1'bz);
// Gate A20-U244B
pullup(C54R);
assign #0.2  C54R = rst ? 0 : ((0|CXB4_|g31411|CA5_) ? 1'b0 : 1'bz);
// Gate A20-U149A
pullup(g31146);
assign #0.2  g31146 = rst ? 1'bz : ((0|g31147|g31145) ? 1'b0 : 1'bz);
// Gate A20-U159B
pullup(C33M);
assign #0.2  C33M = rst ? 0 : ((0|g31124|CA3_|CXB3_) ? 1'b0 : 1'bz);
// Gate A20-U103A
pullup(g31225);
assign #0.2  g31225 = rst ? 0 : ((0|C35R|g31224) ? 1'b0 : 1'bz);
// Gate A20-U118B
pullup(g31240);
assign #0.2  g31240 = rst ? 0 : ((0|g31239|C30R) ? 1'b0 : 1'bz);
// Gate A20-U111B
pullup(g31247);
assign #0.2  g31247 = rst ? 0 : ((0|g31246|C31R) ? 1'b0 : 1'bz);
// Gate A20-U144A
pullup(g31111);
assign #0.2  g31111 = rst ? 1'bz : ((0|RSSB) ? 1'b0 : 1'bz);
// Gate A20-U135B
pullup(g31106);
assign #0.2  g31106 = rst ? 1'bz : ((0|g31105|g31107) ? 1'b0 : 1'bz);
// Gate A20-U137B
pullup(g31107);
assign #0.2  g31107 = rst ? 0 : ((0|g31106|C32R) ? 1'b0 : 1'bz);
// Gate A20-U239B
pullup(g31409);
assign #0.2  g31409 = rst ? 1'bz : ((0|g31410|PIPYM) ? 1'b0 : 1'bz);
// Gate A20-U238A
pullup(g31437);
assign #0.2  g31437 = rst ? 0 : ((0|g31436|C54R) ? 1'b0 : 1'bz);
// Gate A20-U239A
pullup(g31436);
assign #0.2  g31436 = rst ? 1'bz : ((0|g31437|SHAFTD) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
