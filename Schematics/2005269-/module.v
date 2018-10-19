// Verilog module auto-generated for AGC module A13 by dumbVerilog.py

module A13 ( 
  rst, ALTEST, ALTM, BMAGZM, CCH33, CDUXD, CDUYD, CDUZD, CGA13, CON2, CTROR,
  CT_, DLKRPT, DRPRST, EMSD, ERRST, F05A_, F05B_, F07A, F07B_, F08B, F10A_,
  F10B, F14B, F14H, FLTOUT, FS01, FS10, G01A, G01A_, G16A_, GOJAM, GYROD,
  IIP, IIP_, INKL, INLNKM, INLNKP, MSTRT, NHALGA, NHVFAL, NOTEST, OTLNKM,
  P02, P02_, P03, P03_, PALE, PIPAFL, RNRADM, RNRADP, SB0_, SB2_, SBY, SCAFAL,
  SHAFTD, STNDBY_, STRT2, SUMA16_, SUMB16_, T03_, T04_, T09_, T10, T10_,
  TC0, TCF0, TEMPIN_, THRSTD, TMPOUT, TRUND, VFAIL, WATCHP, XT0, XT1, d2FSFAL,
  CON3, CTPLS_, DOFILT, FILTIN, MCTRAL_, MOSCAL_, MPIPAL_, MRPTAL_, MSCAFL_,
  MTCAL_, MVFAIL_, MWARNF_, SCADBL, WARN, XT0_, XT1_, AGCWAR, ALGA, CGCWAR,
  CKTAL_, DLKPLS, F08B_, G16SW_, MSTRTP, OSCALM, RESTRT, SBYEXT, STRT1, SYNC14_,
  SYNC4_, TMPCAU
);

input wire rst, ALTEST, ALTM, BMAGZM, CCH33, CDUXD, CDUYD, CDUZD, CGA13,
  CON2, CTROR, CT_, DLKRPT, DRPRST, EMSD, ERRST, F05A_, F05B_, F07A, F07B_,
  F08B, F10A_, F10B, F14B, F14H, FLTOUT, FS01, FS10, G01A, G01A_, G16A_,
  GOJAM, GYROD, IIP, IIP_, INKL, INLNKM, INLNKP, MSTRT, NHALGA, NHVFAL, NOTEST,
  OTLNKM, P02, P02_, P03, P03_, PALE, PIPAFL, RNRADM, RNRADP, SB0_, SB2_,
  SBY, SCAFAL, SHAFTD, STNDBY_, STRT2, SUMA16_, SUMB16_, T03_, T04_, T09_,
  T10, T10_, TC0, TCF0, TEMPIN_, THRSTD, TMPOUT, TRUND, VFAIL, WATCHP, XT0,
  XT1, d2FSFAL;

inout wire CON3, CTPLS_, DOFILT, FILTIN, MCTRAL_, MOSCAL_, MPIPAL_, MRPTAL_,
  MSCAFL_, MTCAL_, MVFAIL_, MWARNF_, SCADBL, WARN, XT0_, XT1_;

output wire AGCWAR, ALGA, CGCWAR, CKTAL_, DLKPLS, F08B_, G16SW_, MSTRTP,
  OSCALM, RESTRT, SBYEXT, STRT1, SYNC14_, SYNC4_, TMPCAU;

parameter GATE_DELAY = 0.2; // This default may be overridden at compile time.
initial $display("Gate delay (A13) will be %f ns.", GATE_DELAY*100);

// Gate A13-U102B
pullup(DLKPLS);
assign #GATE_DELAY DLKPLS = rst ? 0 : ((0|g41152|T10_) ? 1'b0 : 1'bz);
// Gate A13-U138A
pullup(g41237);
assign #GATE_DELAY g41237 = rst ? 0 : ((0|GOJAM|g41238) ? 1'b0 : 1'bz);
// Gate A13-U115B
pullup(g41130);
assign #GATE_DELAY g41130 = rst ? 1'bz : ((0|SUMA16_|G01A_|SUMB16_) ? 1'b0 : 1'bz);
// Gate A13-U101A
pullup(DOFILT);
assign #GATE_DELAY DOFILT = rst ? 1'bz : ((0|g41146) ? 1'b0 : 1'bz);
// Gate A13-U115A
pullup(g41129);
assign #GATE_DELAY g41129 = rst ? 0 : ((0|G01A|G16A_) ? 1'b0 : 1'bz);
// Gate A13-U160B
pullup(g41201);
assign #GATE_DELAY g41201 = rst ? 1'bz : ((0|VFAIL) ? 1'b0 : 1'bz);
// Gate A13-U110A
pullup(g41137);
assign #GATE_DELAY g41137 = rst ? 0 : ((0|CTPLS_) ? 1'b0 : 1'bz);
// Gate A13-U160A
pullup(g41202);
assign #GATE_DELAY g41202 = rst ? 0 : ((0|F05B_|g41201) ? 1'b0 : 1'bz);
// Gate A13-U134B
pullup(SCADBL);
assign #GATE_DELAY SCADBL = rst ? 0 : ((0|d2FSFAL|CON3) ? 1'b0 : 1'bz);
// Gate A13-U154A
pullup(g41213);
assign #GATE_DELAY g41213 = rst ? 0 : ((0|g41211|g41209|SB0_) ? 1'b0 : 1'bz);
// Gate A13-U124B
pullup(g41109);
assign #GATE_DELAY g41109 = rst ? 0 : ((0|IIP_|g41110) ? 1'b0 : 1'bz);
// Gate A13-U157A A13-U155A
pullup(g41211);
assign #GATE_DELAY g41211 = rst ? 0 : ((0|SCADBL|g41206|DOFILT|g41212|ALTEST) ? 1'b0 : 1'bz);
// Gate A13-U130B
pullup(MSTRTP);
assign #GATE_DELAY MSTRTP = rst ? 0 : ((0|F05A_|g41103) ? 1'b0 : 1'bz);
// Gate A13-U158B
pullup(g41206);
assign #GATE_DELAY g41206 = rst ? 0 : ((0|STNDBY_|F05A_|g41203) ? 1'b0 : 1'bz);
// Gate A13-U133A
pullup(g41244);
assign #GATE_DELAY g41244 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A13-U101B
pullup(g41146);
assign #GATE_DELAY g41146 = rst ? 0 : ((0|g41143|GOJAM|g41151) ? 1'b0 : 1'bz);
// Gate A13-U133B
pullup(CON3);
assign #GATE_DELAY CON3 = rst ? 1'bz : ((0|CON2|FS10) ? 1'b0 : 1'bz);
// Gate A13-U159B
pullup(g41204);
assign #GATE_DELAY g41204 = rst ? 0 : ((0|g41203|NHVFAL|g41201) ? 1'b0 : 1'bz);
// Gate A13-U152B
pullup(g41245);
assign #GATE_DELAY g41245 = rst ? 0 : ((0|g41204|F05A_) ? 1'b0 : 1'bz);
// Gate A13-U153A
pullup(g41247);
assign #GATE_DELAY g41247 = rst ? 1'bz : ((0|STRT1|g41205) ? 1'b0 : 1'bz);
// Gate A13-U130A
pullup(g41104);
assign #GATE_DELAY g41104 = rst ? 0 : ((0|g41101|g41103) ? 1'b0 : 1'bz);
// Gate A13-U129A
pullup(g41103);
assign #GATE_DELAY g41103 = rst ? 1'bz : ((0|g41102|g41104) ? 1'b0 : 1'bz);
// Gate A13-U154B
pullup(g41214);
assign #GATE_DELAY g41214 = rst ? 0 : ((0|g41215|g41213) ? 1'b0 : 1'bz);
// Gate A13-U144B
pullup(g41229);
assign #GATE_DELAY g41229 = rst ? 0 : ((0|TMPOUT|TEMPIN_) ? 1'b0 : 1'bz);
// Gate A13-U144A
pullup(CGCWAR);
assign #GATE_DELAY CGCWAR = rst ? 1'bz : ((0|WARN) ? 1'b0 : 1'bz);
// Gate A13-U127A A13-U122A
pullup(CKTAL_);
assign #GATE_DELAY CKTAL_ = rst ? 1'bz : ((0|PALE|g41112|g41113|g41126|g41125|WATCHP) ? 1'b0 : 1'bz);
// Gate A13-U121A A13-U121B
pullup(MTCAL_);
assign #GATE_DELAY MTCAL_ = rst ? 1'bz : ((0|g41126|g41125) ? 1'b0 : 1'bz);
// Gate A13-U159A
pullup(g41203);
assign #GATE_DELAY g41203 = rst ? 1'bz : ((0|g41202|g41204) ? 1'b0 : 1'bz);
// Gate A13-U146A
pullup(g41225);
assign #GATE_DELAY g41225 = rst ? 1'bz : ((0|AGCWAR|FLTOUT|SCAFAL) ? 1'b0 : 1'bz);
// Gate A13-U149A
pullup(SYNC14_);
assign #GATE_DELAY SYNC14_ = rst ? 1'bz : ((0|g41220) ? 1'b0 : 1'bz);
// Gate A13-U125A
pullup(g41112);
assign #GATE_DELAY g41112 = rst ? 0 : ((0|g41108|g41111) ? 1'b0 : 1'bz);
// Gate A13-U125B
pullup(g41113);
assign #GATE_DELAY g41113 = rst ? 0 : ((0|g41110|g41111) ? 1'b0 : 1'bz);
// Gate A13-U142A
pullup(MOSCAL_);
assign #GATE_DELAY MOSCAL_ = rst ? 0 : ((0|STRT2) ? 1'b0 : 1'bz);
// Gate A13-U117A
pullup(G16SW_);
assign #GATE_DELAY G16SW_ = rst ? 0 : ((0|g41130|g41129) ? 1'b0 : 1'bz);
// Gate A13-U141B
pullup(OSCALM);
assign #GATE_DELAY OSCALM = rst ? 1'bz : ((0|g41232|CCH33) ? 1'b0 : 1'bz);
// Gate A13-U139B
pullup(SBYEXT);
assign #GATE_DELAY SBYEXT = rst ? 1'bz : ((0|g41234) ? 1'b0 : 1'bz);
// Gate A13-U153B
pullup(g41215);
assign #GATE_DELAY g41215 = rst ? 1'bz : ((0|g41214|F08B) ? 1'b0 : 1'bz);
// Gate A13-U107B
pullup(g41149);
assign #GATE_DELAY g41149 = rst ? 0 : ((0|g41148|g41150) ? 1'b0 : 1'bz);
// Gate A13-U120B
pullup(g41126);
assign #GATE_DELAY g41126 = rst ? 0 : ((0|F10A_|g41124) ? 1'b0 : 1'bz);
// Gate A13-U106A
pullup(g41142);
assign #GATE_DELAY g41142 = rst ? 0 : ((0|g41141|INKL) ? 1'b0 : 1'bz);
// Gate A13-U158A
pullup(g41205);
assign #GATE_DELAY g41205 = rst ? 0 : ((0|F05A_|g41203|NHVFAL) ? 1'b0 : 1'bz);
// Gate A13-U112A A13-U112B
pullup(XT1_);
assign #GATE_DELAY XT1_ = rst ? 1'bz : ((0|XT1) ? 1'b0 : 1'bz);
// Gate A13-U128B
pullup(ALGA);
assign #GATE_DELAY ALGA = rst ? 0 : ((0|CKTAL_|NHALGA) ? 1'b0 : 1'bz);
// Gate A13-U155B
pullup(g41212);
assign #GATE_DELAY g41212 = rst ? 1'bz : ((0|g41210|g41211) ? 1'b0 : 1'bz);
// Gate A13-U156B
pullup(g41210);
assign #GATE_DELAY g41210 = rst ? 0 : ((0|g41209|SB2_) ? 1'b0 : 1'bz);
// Gate A13-U126A A13-U126B
pullup(MRPTAL_);
assign #GATE_DELAY MRPTAL_ = rst ? 1'bz : ((0|g41113|g41112) ? 1'b0 : 1'bz);
// Gate A13-U134A
pullup(F08B_);
assign #GATE_DELAY F08B_ = rst ? 1'bz : ((0|F08B) ? 1'b0 : 1'bz);
// Gate A13-U147B
pullup(MWARNF_);
assign #GATE_DELAY MWARNF_ = rst ? 1'bz : ((0|FLTOUT) ? 1'b0 : 1'bz);
// Gate A13-U141A
pullup(g41232);
assign #GATE_DELAY g41232 = rst ? 0 : ((0|OSCALM|STRT2) ? 1'b0 : 1'bz);
// Gate A13-U106B
pullup(g41150);
assign #GATE_DELAY g41150 = rst ? 1'bz : ((0|F07A|g41149) ? 1'b0 : 1'bz);
// Gate A13-U114A A13-U114B
pullup(XT0_);
assign #GATE_DELAY XT0_ = rst ? 0 : ((0|XT0) ? 1'b0 : 1'bz);
// Gate A13-U107A
pullup(g41141);
assign #GATE_DELAY g41141 = rst ? 1'bz : ((0|g41142|g41140) ? 1'b0 : 1'bz);
// Gate A13-U103B A13-U113A A13-U113B A13-U108A A13-U108B
pullup(CTPLS_);
assign #GATE_DELAY CTPLS_ = rst ? 1'bz : ((0|CDUXD|CDUYD|CDUZD|THRSTD|TRUND|SHAFTD|ALTM|OTLNKM|EMSD|RNRADP|GYROD|RNRADM|INLNKM|BMAGZM|INLNKP) ? 1'b0 : 1'bz);
// Gate A13-U111B
pullup(g41138);
assign #GATE_DELAY g41138 = rst ? 1'bz : ((0|g41139|g41137) ? 1'b0 : 1'bz);
// Gate A13-U127B
pullup(MPIPAL_);
assign #GATE_DELAY MPIPAL_ = rst ? 0 : ((0|PIPAFL) ? 1'b0 : 1'bz);
// Gate A13-U105B
pullup(g41151);
assign #GATE_DELAY g41151 = rst ? 0 : ((0|F07B_|g41150) ? 1'b0 : 1'bz);
// Gate A13-U120A
pullup(g41125);
assign #GATE_DELAY g41125 = rst ? 0 : ((0|F10A_|g41122) ? 1'b0 : 1'bz);
// Gate A13-U103A
pullup(g41153);
assign #GATE_DELAY g41153 = rst ? 0 : ((0|DRPRST|GOJAM|g41152) ? 1'b0 : 1'bz);
// Gate A13-U102A
pullup(g41152);
assign #GATE_DELAY g41152 = rst ? 1'bz : ((0|g41153|DLKRPT) ? 1'b0 : 1'bz);
// Gate A13-U105A
pullup(g41143);
assign #GATE_DELAY g41143 = rst ? 0 : ((0|T03_|g41141) ? 1'b0 : 1'bz);
// Gate A13-U117B A13-U116B
pullup(g41120);
assign #GATE_DELAY g41120 = rst ? 0 : ((0|TC0|TCF0|T04_|INKL) ? 1'b0 : 1'bz);
// Gate A13-U156A
pullup(g41209);
assign #GATE_DELAY g41209 = rst ? 1'bz : ((0|F14B) ? 1'b0 : 1'bz);
// Gate A13-U143B
pullup(TMPCAU);
assign #GATE_DELAY TMPCAU = rst ? 1'bz : ((0|g41229) ? 1'b0 : 1'bz);
// Gate A13-U149B
pullup(g41220);
assign #GATE_DELAY g41220 = rst ? 0 : ((0|P03|CT_|P02_) ? 1'b0 : 1'bz);
// Gate A13-U122B
pullup(g41111);
assign #GATE_DELAY g41111 = rst ? 1'bz : ((0|F14H) ? 1'b0 : 1'bz);
// Gate A13-U146B
pullup(g41224);
assign #GATE_DELAY g41224 = rst ? 1'bz : ((0|SCAFAL|FLTOUT) ? 1'b0 : 1'bz);
// Gate A13-U139A
pullup(g41235);
assign #GATE_DELAY g41235 = rst ? 1'bz : ((0|T10|g41234) ? 1'b0 : 1'bz);
// Gate A13-U124A
pullup(g41110);
assign #GATE_DELAY g41110 = rst ? 1'bz : ((0|F14B|g41109) ? 1'b0 : 1'bz);
// Gate A13-U157B
pullup(MVFAIL_);
assign #GATE_DELAY MVFAIL_ = rst ? 1'bz : ((0|g41205) ? 1'b0 : 1'bz);
// Gate A13-U110B
pullup(g41148);
assign #GATE_DELAY g41148 = rst ? 0 : ((0|T03_|INKL|CTROR) ? 1'b0 : 1'bz);
// Gate A13-U109A
pullup(g41140);
assign #GATE_DELAY g41140 = rst ? 0 : ((0|NOTEST|g41138|T09_) ? 1'b0 : 1'bz);
// Gate A13-U138B
pullup(g41238);
assign #GATE_DELAY g41238 = rst ? 0 : ((0|ERRST|g41237|SBYEXT) ? 1'b0 : 1'bz);
// Gate A13-U137A
pullup(g41239);
assign #GATE_DELAY g41239 = rst ? 1'bz : ((0|ALTEST|g41238) ? 1'b0 : 1'bz);
// Gate A13-U152A
pullup(STRT1);
assign #GATE_DELAY STRT1 = rst ? 0 : ((0|g41247|g41245) ? 1'b0 : 1'bz);
// Gate A13-U111A
pullup(g41139);
assign #GATE_DELAY g41139 = rst ? 0 : ((0|INKL|g41138) ? 1'b0 : 1'bz);
// Gate A13-U147A
pullup(MSCAFL_);
assign #GATE_DELAY MSCAFL_ = rst ? 1'bz : ((0|SCAFAL) ? 1'b0 : 1'bz);
// Gate A13-U151B
pullup(FILTIN);
assign #GATE_DELAY FILTIN = rst ? 1'bz : ((0|g41214) ? 1'b0 : 1'bz);
// Gate A13-U145A
pullup(WARN);
assign #GATE_DELAY WARN = rst ? 0 : ((0|g41224) ? 1'b0 : 1'bz);
// Gate A13-U123A
pullup(g41108);
assign #GATE_DELAY g41108 = rst ? 1'bz : ((0|g41107|F14B) ? 1'b0 : 1'bz);
// Gate A13-U123B
pullup(g41107);
assign #GATE_DELAY g41107 = rst ? 0 : ((0|IIP|g41108) ? 1'b0 : 1'bz);
// Gate A13-U150B
pullup(SYNC4_);
assign #GATE_DELAY SYNC4_ = rst ? 1'bz : ((0|g41218) ? 1'b0 : 1'bz);
// Gate A13-U151A A13-U150A
pullup(g41218);
assign #GATE_DELAY g41218 = rst ? 0 : ((0|FS01|P02|CT_|P03_) ? 1'b0 : 1'bz);
// Gate A13-U145B
pullup(AGCWAR);
assign #GATE_DELAY AGCWAR = rst ? 0 : ((0|g41225|CCH33) ? 1'b0 : 1'bz);
// Gate A13-U104A A13-U104B
pullup(MCTRAL_);
assign #GATE_DELAY MCTRAL_ = rst ? 1'bz : ((0|g41143|g41151) ? 1'b0 : 1'bz);
// Gate A13-U119B
pullup(g41124);
assign #GATE_DELAY g41124 = rst ? 1'bz : ((0|F10B|g41123) ? 1'b0 : 1'bz);
// Gate A13-U140A
pullup(g41234);
assign #GATE_DELAY g41234 = rst ? 0 : ((0|SBY|g41235) ? 1'b0 : 1'bz);
// Gate A13-U119A
pullup(g41122);
assign #GATE_DELAY g41122 = rst ? 1'bz : ((0|F10B|g41121) ? 1'b0 : 1'bz);
// Gate A13-U118A
pullup(g41121);
assign #GATE_DELAY g41121 = rst ? 0 : ((0|TC0|TCF0|g41122) ? 1'b0 : 1'bz);
// Gate A13-U137B
pullup(RESTRT);
assign #GATE_DELAY RESTRT = rst ? 0 : ((0|g41239) ? 1'b0 : 1'bz);
// Gate A13-U129B
pullup(g41101);
assign #GATE_DELAY g41101 = rst ? 1'bz : ((0|MSTRT) ? 1'b0 : 1'bz);
// Gate A13-U128A
pullup(g41102);
assign #GATE_DELAY g41102 = rst ? 0 : ((0|g41101|F05B_) ? 1'b0 : 1'bz);
// Gate A13-U118B
pullup(g41123);
assign #GATE_DELAY g41123 = rst ? 0 : ((0|g41120|g41124) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
