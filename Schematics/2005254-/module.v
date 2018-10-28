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

parameter GATE_DELAY = 20; // This default may be overridden at compile time.
initial $display("Gate delay (A20) will be %f ns.", GATE_DELAY);

// Gate A20-U208B A20-U206B
pullup(g31351);
assign #GATE_DELAY g31351 = rst ? 0 : ((0|CG26|g31333|g31347|g31340) ? 1'b0 : 1'bz);
// Gate A20-U142B
pullup(C32P);
assign #GATE_DELAY C32P = rst ? 0 : ((0|g31102|CA3_|CXB2_) ? 1'b0 : 1'bz);
// Gate A20-U125B
pullup(g31233);
assign #GATE_DELAY g31233 = rst ? 0 : ((0|g31232|C27R) ? 1'b0 : 1'bz);
// Gate A20-U124B
pullup(C27R);
assign #GATE_DELAY C27R = rst ? 0 : ((0|g31211|CXB7_|CA2_) ? 1'b0 : 1'bz);
// Gate A20-U208A
pullup(g31320);
assign #GATE_DELAY g31320 = rst ? 0 : ((0|g31319|C37R) ? 1'b0 : 1'bz);
// Gate A20-U221A
pullup(C36M);
assign #GATE_DELAY C36M = rst ? 0 : ((0|g31309|CA3_|CXB6_) ? 1'b0 : 1'bz);
// Gate A20-U111A
pullup(g31219);
assign #GATE_DELAY g31219 = rst ? 1'bz : ((0|g31220|g31218) ? 1'b0 : 1'bz);
// Gate A20-U225A
pullup(C36A);
assign #GATE_DELAY C36A = rst ? 0 : ((0|g31306|CG12) ? 1'b0 : 1'bz);
// Gate A20-U226A
pullup(g31306);
assign #GATE_DELAY g31306 = rst ? 1'bz : ((0|g31307|g31305) ? 1'b0 : 1'bz);
// Gate A20-U237A
pullup(C53R);
assign #GATE_DELAY C53R = rst ? 0 : ((0|g31411|CA5_|CXB3_) ? 1'b0 : 1'bz);
// Gate A20-U126B
pullup(C27A);
assign #GATE_DELAY C27A = rst ? 0 : ((0|g31232|CG21) ? 1'b0 : 1'bz);
// Gate A20-U120B
pullup(g31239);
assign #GATE_DELAY g31239 = rst ? 1'bz : ((0|g31240|g31238) ? 1'b0 : 1'bz);
// Gate A20-U219A
pullup(C36P);
assign #GATE_DELAY C36P = rst ? 0 : ((0|g31302|CA3_|CXB6_) ? 1'b0 : 1'bz);
// Gate A20-U203A
pullup(g31325);
assign #GATE_DELAY g31325 = rst ? 0 : ((0|g31324|C37R) ? 1'b0 : 1'bz);
// Gate A20-U220A
pullup(C36R);
assign #GATE_DELAY C36R = rst ? 0 : ((0|g31311|CA3_|CXB6_) ? 1'b0 : 1'bz);
// Gate A20-U230B
pullup(g31330);
assign #GATE_DELAY g31330 = rst ? 0 : ((0|g31329|C50R) ? 1'b0 : 1'bz);
// Gate A20-U115A
pullup(g31216);
assign #GATE_DELAY g31216 = rst ? 0 : ((0|C35R|g31215) ? 1'b0 : 1'bz);
// Gate A20-U157B
pullup(g31124);
assign #GATE_DELAY g31124 = rst ? 1'bz : ((0|g31125|CDUYM) ? 1'b0 : 1'bz);
// Gate A20-U113A
pullup(g31218);
assign #GATE_DELAY g31218 = rst ? 0 : ((0|g31201|g31217) ? 1'b0 : 1'bz);
// Gate A20-U245A
pullup(g31444);
assign #GATE_DELAY g31444 = rst ? 0 : ((0|C55R|g31443) ? 1'b0 : 1'bz);
// Gate A20-U241B
pullup(C40R);
assign #GATE_DELAY C40R = rst ? 0 : ((0|g31411|CXB0_|CA4_) ? 1'b0 : 1'bz);
// Gate A20-U246A
pullup(g31443);
assign #GATE_DELAY g31443 = rst ? 1'bz : ((0|THRSTD|g31444) ? 1'b0 : 1'bz);
// Gate A20-U248A
pullup(g31445);
assign #GATE_DELAY g31445 = rst ? 0 : ((0|g31443|g31401) ? 1'b0 : 1'bz);
// Gate A20-U246B
pullup(g31416);
assign #GATE_DELAY g31416 = rst ? 0 : ((0|g31415|C41R) ? 1'b0 : 1'bz);
// Gate A20-U207B
pullup(CG24);
assign #GATE_DELAY CG24 = rst ? 1'bz : ((0|g31351) ? 1'b0 : 1'bz);
// Gate A20-U258B
pullup(g31425);
assign #GATE_DELAY g31425 = rst ? 0 : ((0|g31424|C41R) ? 1'b0 : 1'bz);
// Gate A20-U154A
pullup(CG21);
assign #GATE_DELAY CG21 = rst ? 0 : ((0|g31150) ? 1'b0 : 1'bz);
// Gate A20-U107B
pullup(CG22);
assign #GATE_DELAY CG22 = rst ? 0 : ((0|g31251) ? 1'b0 : 1'bz);
// Gate A20-U254A
pullup(CG23);
assign #GATE_DELAY CG23 = rst ? 1'bz : ((0|g31450) ? 1'b0 : 1'bz);
// Gate A20-U234A
pullup(g31432);
assign #GATE_DELAY g31432 = rst ? 1'bz : ((0|g31431|g31433) ? 1'b0 : 1'bz);
// Gate A20-U242B
pullup(C40P);
assign #GATE_DELAY C40P = rst ? 0 : ((0|g31402|CA4_|CXB0_) ? 1'b0 : 1'bz);
// Gate A20-U128B
pullup(g31231);
assign #GATE_DELAY g31231 = rst ? 0 : ((0|g31201|g31229) ? 1'b0 : 1'bz);
// Gate A20-U254B
pullup(g31422);
assign #GATE_DELAY g31422 = rst ? 0 : ((0|g31420|CG14|g31407) ? 1'b0 : 1'bz);
// Gate A20-U222B
pullup(g31336);
assign #GATE_DELAY g31336 = rst ? 1'bz : ((0|g31337|CDUYD) ? 1'b0 : 1'bz);
// Gate A20-U135A
pullup(C24A);
assign #GATE_DELAY C24A = rst ? 0 : ((0|g31132) ? 1'b0 : 1'bz);
// Gate A20-U114B
pullup(C31R);
assign #GATE_DELAY C31R = rst ? 0 : ((0|g31211|CXB1_|CA3_) ? 1'b0 : 1'bz);
// Gate A20-U236B
pullup(C40A);
assign #GATE_DELAY C40A = rst ? 0 : ((0|g31406|CG14) ? 1'b0 : 1'bz);
// Gate A20-U109B A20-U110B
pullup(C31A);
assign #GATE_DELAY C31A = rst ? 0 : ((0|g31246|g31240|CG21|g31233) ? 1'b0 : 1'bz);
// Gate A20-U137A
pullup(C24R);
assign #GATE_DELAY C24R = rst ? 0 : ((0|g31111|CA2_|CXB4_) ? 1'b0 : 1'bz);
// Gate A20-U127B
pullup(g31232);
assign #GATE_DELAY g31232 = rst ? 1'bz : ((0|g31233|g31231) ? 1'b0 : 1'bz);
// Gate A20-U240B
pullup(C40M);
assign #GATE_DELAY C40M = rst ? 0 : ((0|g31409|CA4_|CXB0_) ? 1'b0 : 1'bz);
// Gate A20-U203B A20-U202B
pullup(CXB3_);
assign #GATE_DELAY CXB3_ = rst ? 1'bz : ((0|XB3) ? 1'b0 : 1'bz);
// Gate A20-U255A A20-U253A
pullup(g31450);
assign #GATE_DELAY g31450 = rst ? 0 : ((0|g31447|g31440|g31433|CG24) ? 1'b0 : 1'bz);
// Gate A20-U237B
pullup(g31407);
assign #GATE_DELAY g31407 = rst ? 0 : ((0|g31406|C40R) ? 1'b0 : 1'bz);
// Gate A20-U201B
pullup(CA2_);
assign #GATE_DELAY CA2_ = rst ? 1'bz : ((0|OCTAD2) ? 1'b0 : 1'bz);
// Gate A20-U235B
pullup(g31406);
assign #GATE_DELAY g31406 = rst ? 1'bz : ((0|g31405|g31407) ? 1'b0 : 1'bz);
// Gate A20-U150A
pullup(g31147);
assign #GATE_DELAY g31147 = rst ? 0 : ((0|g31146|C26R) ? 1'b0 : 1'bz);
// Gate A20-U247B
pullup(g31418);
assign #GATE_DELAY g31418 = rst ? 0 : ((0|g31417|g31401) ? 1'b0 : 1'bz);
// Gate A20-U130A
pullup(g31202);
assign #GATE_DELAY g31202 = rst ? 1'bz : ((0|g31203|CDUZP) ? 1'b0 : 1'bz);
// Gate A20-U213B
pullup(g31345);
assign #GATE_DELAY g31345 = rst ? 0 : ((0|g31343|g31301) ? 1'b0 : 1'bz);
// Gate A20-U216A
pullup(g31315);
assign #GATE_DELAY g31315 = rst ? 1'bz : ((0|g31316|PIPXP) ? 1'b0 : 1'bz);
// Gate A20-U147B
pullup(g31118);
assign #GATE_DELAY g31118 = rst ? 0 : ((0|g31117|g31101) ? 1'b0 : 1'bz);
// Gate A20-U250B
pullup(g31419);
assign #GATE_DELAY g31419 = rst ? 1'bz : ((0|g31418|g31420) ? 1'b0 : 1'bz);
// Gate A20-U145B
pullup(g31115);
assign #GATE_DELAY g31115 = rst ? 1'bz : ((0|g31116|CDUYP) ? 1'b0 : 1'bz);
// Gate A20-U243B
pullup(g31401);
assign #GATE_DELAY g31401 = rst ? 1'bz : ((0|BKTF_) ? 1'b0 : 1'bz);
// Gate A20-U121A
pullup(C34M);
assign #GATE_DELAY C34M = rst ? 0 : ((0|g31209|CA3_|CXB4_) ? 1'b0 : 1'bz);
// Gate A20-U146A
pullup(g31143);
assign #GATE_DELAY g31143 = rst ? 1'bz : ((0|g31144|T3P) ? 1'b0 : 1'bz);
// Gate A20-U228B
pullup(g32331);
assign #GATE_DELAY g32331 = rst ? 0 : ((0|g31301|g31329) ? 1'b0 : 1'bz);
// Gate A20-U219B
pullup(C51A);
assign #GATE_DELAY C51A = rst ? 0 : ((0|g31339|CG26|g31333) ? 1'b0 : 1'bz);
// Gate A20-U125A
pullup(C34A);
assign #GATE_DELAY C34A = rst ? 1'bz : ((0|g31206|CG11) ? 1'b0 : 1'bz);
// Gate A20-U146B
pullup(g31116);
assign #GATE_DELAY g31116 = rst ? 0 : ((0|g31115|C33R) ? 1'b0 : 1'bz);
// Gate A20-U116B
pullup(g31244);
assign #GATE_DELAY g31244 = rst ? 0 : ((0|g31243|C31R) ? 1'b0 : 1'bz);
// Gate A20-U148B
pullup(g31117);
assign #GATE_DELAY g31117 = rst ? 1'bz : ((0|g31116|g31125) ? 1'b0 : 1'bz);
// Gate A20-U132B
pullup(g31103);
assign #GATE_DELAY g31103 = rst ? 0 : ((0|g31102|C32R) ? 1'b0 : 1'bz);
// Gate A20-U148A
pullup(g31145);
assign #GATE_DELAY g31145 = rst ? 0 : ((0|g31143|g31101) ? 1'b0 : 1'bz);
// Gate A20-U120A
pullup(C34R);
assign #GATE_DELAY C34R = rst ? 0 : ((0|g31211|CA3_|CXB4_) ? 1'b0 : 1'bz);
// Gate A20-U217B
pullup(C51R);
assign #GATE_DELAY C51R = rst ? 0 : ((0|g31311|CA5_|CXB1_) ? 1'b0 : 1'bz);
// Gate A20-U119A
pullup(C34P);
assign #GATE_DELAY C34P = rst ? 0 : ((0|g31202|CA3_|CXB4_) ? 1'b0 : 1'bz);
// Gate A20-U240A
pullup(g31438);
assign #GATE_DELAY g31438 = rst ? 0 : ((0|g31436|g31401) ? 1'b0 : 1'bz);
// Gate A20-U158B
pullup(g31125);
assign #GATE_DELAY g31125 = rst ? 0 : ((0|g31124|C33R) ? 1'b0 : 1'bz);
// Gate A20-U229A
pullup(g31303);
assign #GATE_DELAY g31303 = rst ? 0 : ((0|C36R|g31302) ? 1'b0 : 1'bz);
// Gate A20-U217A
pullup(g31301);
assign #GATE_DELAY g31301 = rst ? 1'bz : ((0|BKTF_) ? 1'b0 : 1'bz);
// Gate A20-U249A
pullup(g31446);
assign #GATE_DELAY g31446 = rst ? 1'bz : ((0|g31445|g31447) ? 1'b0 : 1'bz);
// Gate A20-U229B
pullup(g31329);
assign #GATE_DELAY g31329 = rst ? 1'bz : ((0|g31330|CDUXD) ? 1'b0 : 1'bz);
// Gate A20-U250A
pullup(g31447);
assign #GATE_DELAY g31447 = rst ? 0 : ((0|g31446|C55R) ? 1'b0 : 1'bz);
// Gate A20-U213A
pullup(g31318);
assign #GATE_DELAY g31318 = rst ? 0 : ((0|g31301|g31317) ? 1'b0 : 1'bz);
// Gate A20-U126A
pullup(g31206);
assign #GATE_DELAY g31206 = rst ? 0 : ((0|g31207|g31205) ? 1'b0 : 1'bz);
// Gate A20-U153B
pullup(g31120);
assign #GATE_DELAY g31120 = rst ? 0 : ((0|g31119|C33R) ? 1'b0 : 1'bz);
// Gate A20-U150B
pullup(g31119);
assign #GATE_DELAY g31119 = rst ? 1'bz : ((0|g31118|g31120) ? 1'b0 : 1'bz);
// Gate A20-U123B
pullup(g31237);
assign #GATE_DELAY g31237 = rst ? 0 : ((0|g31236|C30R) ? 1'b0 : 1'bz);
// Gate A20-U143A
pullup(g31140);
assign #GATE_DELAY g31140 = rst ? 0 : ((0|g31139|C25R) ? 1'b0 : 1'bz);
// Gate A20-U127A
pullup(g31205);
assign #GATE_DELAY g31205 = rst ? 0 : ((0|g31201|g31204) ? 1'b0 : 1'bz);
// Gate A20-U141A
pullup(g31139);
assign #GATE_DELAY g31139 = rst ? 1'bz : ((0|g31138|g31140) ? 1'b0 : 1'bz);
// Gate A20-U129B
pullup(g31229);
assign #GATE_DELAY g31229 = rst ? 1'bz : ((0|g31230|T4P) ? 1'b0 : 1'bz);
// Gate A20-U201A
pullup(C37M);
assign #GATE_DELAY C37M = rst ? 0 : ((0|CXB7_|CA3_|g31324) ? 1'b0 : 1'bz);
// Gate A20-U147A
pullup(C26R);
assign #GATE_DELAY C26R = rst ? 0 : ((0|g31111|CXB6_|CA2_) ? 1'b0 : 1'bz);
// Gate A20-U215A
pullup(g31316);
assign #GATE_DELAY g31316 = rst ? 0 : ((0|C37R|g31315) ? 1'b0 : 1'bz);
// Gate A20-U233B
pullup(g31404);
assign #GATE_DELAY g31404 = rst ? 1'bz : ((0|g31410|g31403) ? 1'b0 : 1'bz);
// Gate A20-U226B
pullup(C50A);
assign #GATE_DELAY C50A = rst ? 0 : ((0|g31332|CG26) ? 1'b0 : 1'bz);
// Gate A20-U129A
pullup(g31203);
assign #GATE_DELAY g31203 = rst ? 0 : ((0|C34R|g31202) ? 1'b0 : 1'bz);
// Gate A20-U248B
pullup(g31417);
assign #GATE_DELAY g31417 = rst ? 1'bz : ((0|g31416|g31425) ? 1'b0 : 1'bz);
// Gate A20-U224A
pullup(g31307);
assign #GATE_DELAY g31307 = rst ? 0 : ((0|C36R|g31306) ? 1'b0 : 1'bz);
// Gate A20-U209A
pullup(C37A);
assign #GATE_DELAY C37A = rst ? 0 : ((0|g31319|CG12|g31307) ? 1'b0 : 1'bz);
// Gate A20-U233A
pullup(g31431);
assign #GATE_DELAY g31431 = rst ? 0 : ((0|g31429|g31401) ? 1'b0 : 1'bz);
// Gate A20-U151A A20-U152A
pullup(C26A);
assign #GATE_DELAY C26A = rst ? 0 : ((0|g31133|g31146|g31140) ? 1'b0 : 1'bz);
// Gate A20-U107A
pullup(g31222);
assign #GATE_DELAY g31222 = rst ? 0 : ((0|g31220|CG11|g31207) ? 1'b0 : 1'bz);
// Gate A20-U218A
pullup(g31311);
assign #GATE_DELAY g31311 = rst ? 1'bz : ((0|RSSB) ? 1'b0 : 1'bz);
// Gate A20-U211A
pullup(g31319);
assign #GATE_DELAY g31319 = rst ? 1'bz : ((0|g31320|g31318) ? 1'b0 : 1'bz);
// Gate A20-U105B A20-U104B A20-U156A A20-U157A
pullup(CA3_);
assign #GATE_DELAY CA3_ = rst ? 1'bz : ((0|OCTAD3) ? 1'b0 : 1'bz);
// Gate A20-U227B
pullup(g31332);
assign #GATE_DELAY g31332 = rst ? 1'bz : ((0|g31333|g32331) ? 1'b0 : 1'bz);
// Gate A20-U202A
pullup(C37R);
assign #GATE_DELAY C37R = rst ? 0 : ((0|CXB7_|CA3_|g31311) ? 1'b0 : 1'bz);
// Gate A20-U212A
pullup(C37P);
assign #GATE_DELAY C37P = rst ? 0 : ((0|CA3_|g31315|CXB7_) ? 1'b0 : 1'bz);
// Gate A20-U205A
pullup(CG14);
assign #GATE_DELAY CG14 = rst ? 1'bz : ((0|g31322) ? 1'b0 : 1'bz);
// Gate A20-U155B
pullup(g31159);
assign #GATE_DELAY g31159 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A20-U158A A20-U159A
pullup(g31157);
assign #GATE_DELAY g31157 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A20-U156B
pullup(CG11);
assign #GATE_DELAY CG11 = rst ? 0 : ((0|g31122) ? 1'b0 : 1'bz);
// Gate A20-U231B
pullup(g31402);
assign #GATE_DELAY g31402 = rst ? 1'bz : ((0|PIPYP|g31403) ? 1'b0 : 1'bz);
// Gate A20-U256B
pullup(CG13);
assign #GATE_DELAY CG13 = rst ? 1'bz : ((0|g31422) ? 1'b0 : 1'bz);
// Gate A20-U105A
pullup(CG12);
assign #GATE_DELAY CG12 = rst ? 1'bz : ((0|g31222) ? 1'b0 : 1'bz);
// Gate A20-U231A
pullup(g31430);
assign #GATE_DELAY g31430 = rst ? 0 : ((0|g31429|C53R) ? 1'b0 : 1'bz);
// Gate A20-U232A
pullup(g31429);
assign #GATE_DELAY g31429 = rst ? 1'bz : ((0|TRUND|g31430) ? 1'b0 : 1'bz);
// Gate A20-U204A
pullup(g31324);
assign #GATE_DELAY g31324 = rst ? 1'bz : ((0|g31325|PIPXM) ? 1'b0 : 1'bz);
// Gate A20-U241A
pullup(g31439);
assign #GATE_DELAY g31439 = rst ? 1'bz : ((0|g31438|g31440) ? 1'b0 : 1'bz);
// Gate A20-U243A
pullup(g31440);
assign #GATE_DELAY g31440 = rst ? 0 : ((0|g31439|C54R) ? 1'b0 : 1'bz);
// Gate A20-U224B
pullup(C50R);
assign #GATE_DELAY C50R = rst ? 0 : ((0|g31311|CXB0_|CA5_) ? 1'b0 : 1'bz);
// Gate A20-U121B
pullup(g31238);
assign #GATE_DELAY g31238 = rst ? 0 : ((0|g31236|g31201) ? 1'b0 : 1'bz);
// Gate A20-U215B
pullup(g31343);
assign #GATE_DELAY g31343 = rst ? 1'bz : ((0|g31344|CDUZD) ? 1'b0 : 1'bz);
// Gate A20-U216B
pullup(g31344);
assign #GATE_DELAY g31344 = rst ? 0 : ((0|g31343|C52R) ? 1'b0 : 1'bz);
// Gate A20-U139A
pullup(g31136);
assign #GATE_DELAY g31136 = rst ? 1'bz : ((0|T1P|g31137) ? 1'b0 : 1'bz);
// Gate A20-U141B
pullup(C32R);
assign #GATE_DELAY C32R = rst ? 0 : ((0|g31111|CXB2_|CA3_) ? 1'b0 : 1'bz);
// Gate A20-U138A
pullup(g31137);
assign #GATE_DELAY g31137 = rst ? 0 : ((0|C25R|g31136) ? 1'b0 : 1'bz);
// Gate A20-U139B
pullup(g31109);
assign #GATE_DELAY g31109 = rst ? 1'bz : ((0|g31110|CDUXM) ? 1'b0 : 1'bz);
// Gate A20-U221B
pullup(g31338);
assign #GATE_DELAY g31338 = rst ? 0 : ((0|g31336|g31301) ? 1'b0 : 1'bz);
// Gate A20-U122A
pullup(g31209);
assign #GATE_DELAY g31209 = rst ? 1'bz : ((0|g31210|CDUZM) ? 1'b0 : 1'bz);
// Gate A20-U122B
pullup(g31236);
assign #GATE_DELAY g31236 = rst ? 1'bz : ((0|g31237|T5P) ? 1'b0 : 1'bz);
// Gate A20-U235A
pullup(C53A);
assign #GATE_DELAY C53A = rst ? 0 : ((0|g31432|CG24) ? 1'b0 : 1'bz);
// Gate A20-U136B
pullup(C32A);
assign #GATE_DELAY C32A = rst ? 0 : ((0|g31106|CG22) ? 1'b0 : 1'bz);
// Gate A20-U228A
pullup(g31304);
assign #GATE_DELAY g31304 = rst ? 1'bz : ((0|g31310|g31303) ? 1'b0 : 1'bz);
// Gate A20-U116A
pullup(g31215);
assign #GATE_DELAY g31215 = rst ? 1'bz : ((0|g31216|TRNP) ? 1'b0 : 1'bz);
// Gate A20-U140B
pullup(C32M);
assign #GATE_DELAY C32M = rst ? 0 : ((0|g31109|CA3_|CXB2_) ? 1'b0 : 1'bz);
// Gate A20-U113B
pullup(g31245);
assign #GATE_DELAY g31245 = rst ? 0 : ((0|g31243|g31201) ? 1'b0 : 1'bz);
// Gate A20-U155A A20-U153A
pullup(g31150);
assign #GATE_DELAY g31150 = rst ? 1'bz : ((0|g31147|g31140|g31133) ? 1'b0 : 1'bz);
// Gate A20-U218B
pullup(g31340);
assign #GATE_DELAY g31340 = rst ? 0 : ((0|g31339|C51R) ? 1'b0 : 1'bz);
// Gate A20-U223B
pullup(g31337);
assign #GATE_DELAY g31337 = rst ? 0 : ((0|g31336|C51R) ? 1'b0 : 1'bz);
// Gate A20-U223A
pullup(g31310);
assign #GATE_DELAY g31310 = rst ? 0 : ((0|g31309|C36R) ? 1'b0 : 1'bz);
// Gate A20-U133A
pullup(g31131);
assign #GATE_DELAY g31131 = rst ? 0 : ((0|g31129|g31101) ? 1'b0 : 1'bz);
// Gate A20-U220B
pullup(g31339);
assign #GATE_DELAY g31339 = rst ? 1'bz : ((0|g31340|g31338) ? 1'b0 : 1'bz);
// Gate A20-U143B
pullup(g31101);
assign #GATE_DELAY g31101 = rst ? 1'bz : ((0|BKTF_) ? 1'b0 : 1'bz);
// Gate A20-U212B
pullup(g31346);
assign #GATE_DELAY g31346 = rst ? 1'bz : ((0|g31347|g31345) ? 1'b0 : 1'bz);
// Gate A20-U138B
pullup(g31110);
assign #GATE_DELAY g31110 = rst ? 0 : ((0|g31109|C32R) ? 1'b0 : 1'bz);
// Gate A20-U211B
pullup(g31347);
assign #GATE_DELAY g31347 = rst ? 0 : ((0|g31346|C52R) ? 1'b0 : 1'bz);
// Gate A20-U133B
pullup(g31104);
assign #GATE_DELAY g31104 = rst ? 1'bz : ((0|g31110|g31103) ? 1'b0 : 1'bz);
// Gate A20-U128A
pullup(g31204);
assign #GATE_DELAY g31204 = rst ? 1'bz : ((0|g31210|g31203) ? 1'b0 : 1'bz);
// Gate A20-U104A
pullup(g31224);
assign #GATE_DELAY g31224 = rst ? 1'bz : ((0|g31225|TRNM) ? 1'b0 : 1'bz);
// Gate A20-U145A
pullup(g31144);
assign #GATE_DELAY g31144 = rst ? 0 : ((0|C26R|g31143) ? 1'b0 : 1'bz);
// Gate A20-U214B
pullup(C52R);
assign #GATE_DELAY C52R = rst ? 0 : ((0|g31311|CXB2_|CA5_) ? 1'b0 : 1'bz);
// Gate A20-U112A
pullup(C35P);
assign #GATE_DELAY C35P = rst ? 0 : ((0|CA3_|g31215|CXB5_) ? 1'b0 : 1'bz);
// Gate A20-U102A
pullup(C35R);
assign #GATE_DELAY C35R = rst ? 0 : ((0|CXB5_|CA3_|g31211) ? 1'b0 : 1'bz);
// Gate A20-U108B A20-U106B
pullup(g31251);
assign #GATE_DELAY g31251 = rst ? 1'bz : ((0|CG21|g31233|g31247|g31240) ? 1'b0 : 1'bz);
// Gate A20-U117B
pullup(C30R);
assign #GATE_DELAY C30R = rst ? 0 : ((0|g31211|CA3_|CXB0_) ? 1'b0 : 1'bz);
// Gate A20-U230A
pullup(g31302);
assign #GATE_DELAY g31302 = rst ? 1'bz : ((0|g31303|SHAFTP) ? 1'b0 : 1'bz);
// Gate A20-U118A
pullup(g31211);
assign #GATE_DELAY g31211 = rst ? 1'bz : ((0|RSSB) ? 1'b0 : 1'bz);
// Gate A20-U154B
pullup(g31122);
assign #GATE_DELAY g31122 = rst ? 1'bz : ((0|g31120|CG22|g31107) ? 1'b0 : 1'bz);
// Gate A20-U225B
pullup(g31333);
assign #GATE_DELAY g31333 = rst ? 0 : ((0|g31332|C50R) ? 1'b0 : 1'bz);
// Gate A20-U109A
pullup(C35A);
assign #GATE_DELAY C35A = rst ? 0 : ((0|g31219|CG11|g31207) ? 1'b0 : 1'bz);
// Gate A20-U257B
pullup(g31424);
assign #GATE_DELAY g31424 = rst ? 1'bz : ((0|g31425|PIPZM) ? 1'b0 : 1'bz);
// Gate A20-U209B A20-U210B
pullup(C52A);
assign #GATE_DELAY C52A = rst ? 0 : ((0|g31346|g31340|CG26|g31333) ? 1'b0 : 1'bz);
// Gate A20-U101A
pullup(C35M);
assign #GATE_DELAY C35M = rst ? 0 : ((0|CXB5_|CA3_|g31224) ? 1'b0 : 1'bz);
// Gate A20-U232B
pullup(g31403);
assign #GATE_DELAY g31403 = rst ? 0 : ((0|g31402|C40R) ? 1'b0 : 1'bz);
// Gate A20-U227A
pullup(g31305);
assign #GATE_DELAY g31305 = rst ? 0 : ((0|g31301|g31304) ? 1'b0 : 1'bz);
// Gate A20-U130B
pullup(g31230);
assign #GATE_DELAY g31230 = rst ? 0 : ((0|g31229|C27R) ? 1'b0 : 1'bz);
// Gate A20-U260A
pullup(CA6_);
assign #GATE_DELAY CA6_ = rst ? 1'bz : ((0|OCTAD6) ? 1'b0 : 1'bz);
// Gate A20-U108A
pullup(g31220);
assign #GATE_DELAY g31220 = rst ? 0 : ((0|g31219|C35R) ? 1'b0 : 1'bz);
// Gate A20-U140A
pullup(g31138);
assign #GATE_DELAY g31138 = rst ? 0 : ((0|g31136|g31101) ? 1'b0 : 1'bz);
// Gate A20-U124A
pullup(g31207);
assign #GATE_DELAY g31207 = rst ? 1'bz : ((0|C34R|g31206) ? 1'b0 : 1'bz);
// Gate A20-U134B
pullup(g31105);
assign #GATE_DELAY g31105 = rst ? 0 : ((0|g31104|g31101) ? 1'b0 : 1'bz);
// Gate A20-U103B A20-U102B
pullup(CXB2_);
assign #GATE_DELAY CXB2_ = rst ? 1'bz : ((0|XB2) ? 1'b0 : 1'bz);
// Gate A20-U238B
pullup(g31410);
assign #GATE_DELAY g31410 = rst ? 0 : ((0|g31409|C40R) ? 1'b0 : 1'bz);
// Gate A20-U136A
pullup(g31133);
assign #GATE_DELAY g31133 = rst ? 0 : ((0|g31132|C24R) ? 1'b0 : 1'bz);
// Gate A20-U134A
pullup(g31132);
assign #GATE_DELAY g31132 = rst ? 1'bz : ((0|g31131|g31133) ? 1'b0 : 1'bz);
// Gate A20-U260B
pullup(C41R);
assign #GATE_DELAY C41R = rst ? 0 : ((0|CXB1_|CA4_|g31411) ? 1'b0 : 1'bz);
// Gate A20-U251A A20-U252A
pullup(C55A);
assign #GATE_DELAY C55A = rst ? 0 : ((0|g31433|CG24|g31446|g31440) ? 1'b0 : 1'bz);
// Gate A20-U123A
pullup(g31210);
assign #GATE_DELAY g31210 = rst ? 0 : ((0|g31209|C34R) ? 1'b0 : 1'bz);
// Gate A20-U142A
pullup(C25A);
assign #GATE_DELAY C25A = rst ? 0 : ((0|g31133|g31139) ? 1'b0 : 1'bz);
// Gate A20-U106A
pullup(g31259);
assign #GATE_DELAY g31259 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A20-U112B
pullup(g31246);
assign #GATE_DELAY g31246 = rst ? 1'bz : ((0|g31247|g31245) ? 1'b0 : 1'bz);
// Gate A20-U236A
pullup(g31433);
assign #GATE_DELAY g31433 = rst ? 0 : ((0|g31432|C53R) ? 1'b0 : 1'bz);
// Gate A20-U247A
pullup(C55R);
assign #GATE_DELAY C55R = rst ? 0 : ((0|g31411|CXB5_|CA5_) ? 1'b0 : 1'bz);
// Gate A20-U252B
pullup(C41A);
assign #GATE_DELAY C41A = rst ? 0 : ((0|CG14|g31419|g31407) ? 1'b0 : 1'bz);
// Gate A20-U144B
pullup(C25R);
assign #GATE_DELAY C25R = rst ? 0 : ((0|CXB5_|g31111|CA2_) ? 1'b0 : 1'bz);
// Gate A20-U258A A20-U259A
pullup(CXB4_);
assign #GATE_DELAY CXB4_ = rst ? 1'bz : ((0|XB4) ? 1'b0 : 1'bz);
// Gate A20-U255B
pullup(g31459);
assign #GATE_DELAY g31459 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A20-U119B
pullup(C30A);
assign #GATE_DELAY C30A = rst ? 0 : ((0|g31239|CG21|g31233) ? 1'b0 : 1'bz);
// Gate A20-U249B
pullup(C41P);
assign #GATE_DELAY C41P = rst ? 0 : ((0|CXB1_|g31415|CA4_) ? 1'b0 : 1'bz);
// Gate A20-U222A
pullup(g31309);
assign #GATE_DELAY g31309 = rst ? 1'bz : ((0|g31310|SHAFTM) ? 1'b0 : 1'bz);
// Gate A20-U259B
pullup(C41M);
assign #GATE_DELAY C41M = rst ? 0 : ((0|g31424|CA4_|CXB1_) ? 1'b0 : 1'bz);
// Gate A20-U234B
pullup(g31405);
assign #GATE_DELAY g31405 = rst ? 0 : ((0|g31404|g31401) ? 1'b0 : 1'bz);
// Gate A20-U244A
pullup(g31411);
assign #GATE_DELAY g31411 = rst ? 1'bz : ((0|RSSB) ? 1'b0 : 1'bz);
// Gate A20-U101B A20-U160A
pullup(CXB7_);
assign #GATE_DELAY CXB7_ = rst ? 1'bz : ((0|XB7) ? 1'b0 : 1'bz);
// Gate A20-U245B
pullup(g31415);
assign #GATE_DELAY g31415 = rst ? 1'bz : ((0|g31416|PIPZP) ? 1'b0 : 1'bz);
// Gate A20-U205B A20-U204B A20-U256A A20-U257A
pullup(CA4_);
assign #GATE_DELAY CA4_ = rst ? 1'bz : ((0|OCTAD4) ? 1'b0 : 1'bz);
// Gate A20-U160B
pullup(C33R);
assign #GATE_DELAY C33R = rst ? 0 : ((0|CXB3_|CA3_|g31111) ? 1'b0 : 1'bz);
// Gate A20-U131B
pullup(g31102);
assign #GATE_DELAY g31102 = rst ? 1'bz : ((0|CDUXP|g31103) ? 1'b0 : 1'bz);
// Gate A20-U149B
pullup(C33P);
assign #GATE_DELAY C33P = rst ? 0 : ((0|CXB3_|g31115|CA3_) ? 1'b0 : 1'bz);
// Gate A20-U206A
pullup(g31359);
assign #GATE_DELAY g31359 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A20-U242A
pullup(C54A);
assign #GATE_DELAY C54A = rst ? 0 : ((0|g31433|CG24|g31439) ? 1'b0 : 1'bz);
// Gate A20-U214A
pullup(g31317);
assign #GATE_DELAY g31317 = rst ? 1'bz : ((0|g31325|g31316) ? 1'b0 : 1'bz);
// Gate A20-U207A
pullup(g31322);
assign #GATE_DELAY g31322 = rst ? 0 : ((0|g31320|CG12|g31307) ? 1'b0 : 1'bz);
// Gate A20-U132A
pullup(g31129);
assign #GATE_DELAY g31129 = rst ? 1'bz : ((0|T2P|g31130) ? 1'b0 : 1'bz);
// Gate A20-U131A
pullup(g31130);
assign #GATE_DELAY g31130 = rst ? 0 : ((0|g31129|C24R) ? 1'b0 : 1'bz);
// Gate A20-U253B
pullup(g31420);
assign #GATE_DELAY g31420 = rst ? 0 : ((0|g31419|C41R) ? 1'b0 : 1'bz);
// Gate A20-U115B
pullup(g31243);
assign #GATE_DELAY g31243 = rst ? 1'bz : ((0|g31244|T6P) ? 1'b0 : 1'bz);
// Gate A20-U152B
pullup(C33A);
assign #GATE_DELAY C33A = rst ? 0 : ((0|CG22|g31119|g31107) ? 1'b0 : 1'bz);
// Gate A20-U117A
pullup(g31201);
assign #GATE_DELAY g31201 = rst ? 1'bz : ((0|BKTF_) ? 1'b0 : 1'bz);
// Gate A20-U114A
pullup(g31217);
assign #GATE_DELAY g31217 = rst ? 1'bz : ((0|g31225|g31216) ? 1'b0 : 1'bz);
// Gate A20-U244B
pullup(C54R);
assign #GATE_DELAY C54R = rst ? 0 : ((0|CXB4_|g31411|CA5_) ? 1'b0 : 1'bz);
// Gate A20-U149A
pullup(g31146);
assign #GATE_DELAY g31146 = rst ? 1'bz : ((0|g31145|g31147) ? 1'b0 : 1'bz);
// Gate A20-U159B
pullup(C33M);
assign #GATE_DELAY C33M = rst ? 0 : ((0|g31124|CA3_|CXB3_) ? 1'b0 : 1'bz);
// Gate A20-U103A
pullup(g31225);
assign #GATE_DELAY g31225 = rst ? 0 : ((0|g31224|C35R) ? 1'b0 : 1'bz);
// Gate A20-U118B
pullup(g31240);
assign #GATE_DELAY g31240 = rst ? 0 : ((0|g31239|C30R) ? 1'b0 : 1'bz);
// Gate A20-U111B
pullup(g31247);
assign #GATE_DELAY g31247 = rst ? 0 : ((0|g31246|C31R) ? 1'b0 : 1'bz);
// Gate A20-U144A
pullup(g31111);
assign #GATE_DELAY g31111 = rst ? 1'bz : ((0|RSSB) ? 1'b0 : 1'bz);
// Gate A20-U135B
pullup(g31106);
assign #GATE_DELAY g31106 = rst ? 1'bz : ((0|g31105|g31107) ? 1'b0 : 1'bz);
// Gate A20-U137B
pullup(g31107);
assign #GATE_DELAY g31107 = rst ? 0 : ((0|g31106|C32R) ? 1'b0 : 1'bz);
// Gate A20-U239B
pullup(g31409);
assign #GATE_DELAY g31409 = rst ? 1'bz : ((0|g31410|PIPYM) ? 1'b0 : 1'bz);
// Gate A20-U238A
pullup(g31437);
assign #GATE_DELAY g31437 = rst ? 0 : ((0|C54R|g31436) ? 1'b0 : 1'bz);
// Gate A20-U239A
pullup(g31436);
assign #GATE_DELAY g31436 = rst ? 1'bz : ((0|SHAFTD|g31437) ? 1'b0 : 1'bz);
// End of NOR gates


endmodule
