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

// Gate A13-U102B
pullup(DLKPLS);
assign #0.2  DLKPLS = rst ? 0 : ((0|g41152|T10_) ? 1'b0 : 1'bz);
// Gate A13-U138A
pullup(g41237);
assign #0.2  g41237 = rst ? 0 : ((0|g41238|GOJAM) ? 1'b0 : 1'bz);
// Gate A13-U115B
pullup(g41130);
assign #0.2  g41130 = rst ? 1'bz : ((0|SUMA16_|G01A_|SUMB16_) ? 1'b0 : 1'bz);
// Gate A13-U101A
pullup(DOFILT);
assign #0.2  DOFILT = rst ? 1'bz : ((0|g41146) ? 1'b0 : 1'bz);
// Gate A13-U115A
pullup(g41129);
assign #0.2  g41129 = rst ? 0 : ((0|G16A_|G01A) ? 1'b0 : 1'bz);
// Gate A13-U160B
pullup(g41201);
assign #0.2  g41201 = rst ? 1'bz : ((0|VFAIL) ? 1'b0 : 1'bz);
// Gate A13-U110A
pullup(g41137);
assign #0.2  g41137 = rst ? 0 : ((0|CTPLS_) ? 1'b0 : 1'bz);
// Gate A13-U160A
pullup(g41202);
assign #0.2  g41202 = rst ? 0 : ((0|g41201|F05B_) ? 1'b0 : 1'bz);
// Gate A13-U134B
pullup(SCADBL);
assign #0.2  SCADBL = rst ? 0 : ((0|d2FSFAL|CON3) ? 1'b0 : 1'bz);
// Gate A13-U154A
pullup(g41213);
assign #0.2  g41213 = rst ? 0 : ((0|SB0_|g41209|g41211) ? 1'b0 : 1'bz);
// Gate A13-U124B
pullup(g41109);
assign #0.2  g41109 = rst ? 0 : ((0|IIP_|g41110) ? 1'b0 : 1'bz);
// Gate A13-U157A A13-U155A
pullup(g41211);
assign #0.2  g41211 = rst ? 0 : ((0|DOFILT|g41206|SCADBL|ALTEST|g41212) ? 1'b0 : 1'bz);
// Gate A13-U130B
pullup(MSTRTP);
assign #0.2  MSTRTP = rst ? 0 : ((0|F05A_|g41103) ? 1'b0 : 1'bz);
// Gate A13-U158B
pullup(g41206);
assign #0.2  g41206 = rst ? 0 : ((0|STNDBY_|F05A_|g41203) ? 1'b0 : 1'bz);
// Gate A13-U133A
pullup(g41244);
assign #0.2  g41244 = rst ? 0 : ((0) ? 1'b0 : 1'bz);
// Gate A13-U101B
pullup(g41146);
assign #0.2  g41146 = rst ? 0 : ((0|g41143|GOJAM|g41151) ? 1'b0 : 1'bz);
// Gate A13-U133B
pullup(CON3);
assign #0.2  CON3 = rst ? 1'bz : ((0|CON2|FS10) ? 1'b0 : 1'bz);
// Gate A13-U159B
pullup(g41204);
assign #0.2  g41204 = rst ? 0 : ((0|g41203|NHVFAL|g41201) ? 1'b0 : 1'bz);
// Gate A13-U152B
pullup(g41245);
assign #0.2  g41245 = rst ? 0 : ((0|g41204|F05A_) ? 1'b0 : 1'bz);
// Gate A13-U153A
pullup(g41247);
assign #0.2  g41247 = rst ? 1'bz : ((0|g41205|STRT1) ? 1'b0 : 1'bz);
// Gate A13-U130A
pullup(g41104);
assign #0.2  g41104 = rst ? 0 : ((0|g41103|g41101) ? 1'b0 : 1'bz);
// Gate A13-U129A
pullup(g41103);
assign #0.2  g41103 = rst ? 1'bz : ((0|g41104|g41102) ? 1'b0 : 1'bz);
// Gate A13-U154B
pullup(g41214);
assign #0.2  g41214 = rst ? 1'bz : ((0|g41215|g41213) ? 1'b0 : 1'bz);
// Gate A13-U144B
pullup(g41229);
assign #0.2  g41229 = rst ? 0 : ((0|TMPOUT|TEMPIN_) ? 1'b0 : 1'bz);
// Gate A13-U144A
pullup(CGCWAR);
assign #0.2  CGCWAR = rst ? 1'bz : ((0|WARN) ? 1'b0 : 1'bz);
// Gate A13-U127A A13-U122A
pullup(CKTAL_);
assign #0.2  CKTAL_ = rst ? 1'bz : ((0|g41113|g41112|PALE|WATCHP|g41125|g41126) ? 1'b0 : 1'bz);
// Gate A13-U121A A13-U121B
pullup(MTCAL_);
assign #0.2  MTCAL_ = rst ? 1'bz : ((0|g41126|g41125) ? 1'b0 : 1'bz);
// Gate A13-U159A
pullup(g41203);
assign #0.2  g41203 = rst ? 1'bz : ((0|g41204|g41202) ? 1'b0 : 1'bz);
// Gate A13-U146A
pullup(g41225);
assign #0.2  g41225 = rst ? 1'bz : ((0|SCAFAL|FLTOUT|AGCWAR) ? 1'b0 : 1'bz);
// Gate A13-U149A
pullup(SYNC14_);
assign #0.2  SYNC14_ = rst ? 1'bz : ((0|g41220) ? 1'b0 : 1'bz);
// Gate A13-U125A
pullup(g41112);
assign #0.2  g41112 = rst ? 0 : ((0|g41111|g41108) ? 1'b0 : 1'bz);
// Gate A13-U125B
pullup(g41113);
assign #0.2  g41113 = rst ? 0 : ((0|g41110|g41111) ? 1'b0 : 1'bz);
// Gate A13-U142A
pullup(MOSCAL_);
assign #0.2  MOSCAL_ = rst ? 0 : ((0|STRT2) ? 1'b0 : 1'bz);
// Gate A13-U117A
pullup(G16SW_);
assign #0.2  G16SW_ = rst ? 0 : ((0|g41129|g41130) ? 1'b0 : 1'bz);
// Gate A13-U141B
pullup(OSCALM);
assign #0.2  OSCALM = rst ? 1'bz : ((0|g41232|CCH33) ? 1'b0 : 1'bz);
// Gate A13-U139B
pullup(SBYEXT);
assign #0.2  SBYEXT = rst ? 1'bz : ((0|g41234) ? 1'b0 : 1'bz);
// Gate A13-U153B
pullup(g41215);
assign #0.2  g41215 = rst ? 0 : ((0|g41214|F08B) ? 1'b0 : 1'bz);
// Gate A13-U107B
pullup(g41149);
assign #0.2  g41149 = rst ? 0 : ((0|g41148|g41150) ? 1'b0 : 1'bz);
// Gate A13-U120B
pullup(g41126);
assign #0.2  g41126 = rst ? 0 : ((0|F10A_|g41124) ? 1'b0 : 1'bz);
// Gate A13-U106A
pullup(g41142);
assign #0.2  g41142 = rst ? 0 : ((0|INKL|g41141) ? 1'b0 : 1'bz);
// Gate A13-U158A
pullup(g41205);
assign #0.2  g41205 = rst ? 0 : ((0|NHVFAL|g41203|F05A_) ? 1'b0 : 1'bz);
// Gate A13-U112A A13-U112B
pullup(XT1_);
assign #0.2  XT1_ = rst ? 1'bz : ((0|XT1) ? 1'b0 : 1'bz);
// Gate A13-U128B
pullup(ALGA);
assign #0.2  ALGA = rst ? 0 : ((0|CKTAL_|NHALGA) ? 1'b0 : 1'bz);
// Gate A13-U155B
pullup(g41212);
assign #0.2  g41212 = rst ? 1'bz : ((0|g41210|g41211) ? 1'b0 : 1'bz);
// Gate A13-U156B
pullup(g41210);
assign #0.2  g41210 = rst ? 0 : ((0|g41209|SB2_) ? 1'b0 : 1'bz);
// Gate A13-U126A A13-U126B
pullup(MRPTAL_);
assign #0.2  MRPTAL_ = rst ? 1'bz : ((0|g41112|g41113) ? 1'b0 : 1'bz);
// Gate A13-U134A
pullup(F08B_);
assign #0.2  F08B_ = rst ? 1'bz : ((0|F08B) ? 1'b0 : 1'bz);
// Gate A13-U147B
pullup(MWARNF_);
assign #0.2  MWARNF_ = rst ? 1'bz : ((0|FLTOUT) ? 1'b0 : 1'bz);
// Gate A13-U141A
pullup(g41232);
assign #0.2  g41232 = rst ? 0 : ((0|STRT2|OSCALM) ? 1'b0 : 1'bz);
// Gate A13-U106B
pullup(g41150);
assign #0.2  g41150 = rst ? 1'bz : ((0|F07A|g41149) ? 1'b0 : 1'bz);
// Gate A13-U114A A13-U114B
pullup(XT0_);
assign #0.2  XT0_ = rst ? 1'bz : ((0|XT0) ? 1'b0 : 1'bz);
// Gate A13-U107A
pullup(g41141);
assign #0.2  g41141 = rst ? 1'bz : ((0|g41140|g41142) ? 1'b0 : 1'bz);
// Gate A13-U103B A13-U113A A13-U113B A13-U108A A13-U108B
pullup(CTPLS_);
assign #0.2  CTPLS_ = rst ? 1'bz : ((0|CDUXD|CDUYD|CDUZD|SHAFTD|TRUND|THRSTD|ALTM|OTLNKM|EMSD|RNRADM|GYROD|RNRADP|INLNKM|BMAGZM|INLNKP) ? 1'b0 : 1'bz);
// Gate A13-U111B
pullup(g41138);
assign #0.2  g41138 = rst ? 1'bz : ((0|g41139|g41137) ? 1'b0 : 1'bz);
// Gate A13-U127B
pullup(MPIPAL_);
assign #0.2  MPIPAL_ = rst ? 0 : ((0|PIPAFL) ? 1'b0 : 1'bz);
// Gate A13-U105B
pullup(g41151);
assign #0.2  g41151 = rst ? 0 : ((0|F07B_|g41150) ? 1'b0 : 1'bz);
// Gate A13-U120A
pullup(g41125);
assign #0.2  g41125 = rst ? 0 : ((0|g41122|F10A_) ? 1'b0 : 1'bz);
// Gate A13-U103A
pullup(g41153);
assign #0.2  g41153 = rst ? 0 : ((0|g41152|GOJAM|DRPRST) ? 1'b0 : 1'bz);
// Gate A13-U102A
pullup(g41152);
assign #0.2  g41152 = rst ? 1'bz : ((0|DLKRPT|g41153) ? 1'b0 : 1'bz);
// Gate A13-U105A
pullup(g41143);
assign #0.2  g41143 = rst ? 0 : ((0|g41141|T03_) ? 1'b0 : 1'bz);
// Gate A13-U117B A13-U116B
pullup(g41120);
assign #0.2  g41120 = rst ? 0 : ((0|TC0|TCF0|T04_|INKL) ? 1'b0 : 1'bz);
// Gate A13-U156A
pullup(g41209);
assign #0.2  g41209 = rst ? 1'bz : ((0|F14B) ? 1'b0 : 1'bz);
// Gate A13-U143B
pullup(TMPCAU);
assign #0.2  TMPCAU = rst ? 1'bz : ((0|g41229) ? 1'b0 : 1'bz);
// Gate A13-U149B
pullup(g41220);
assign #0.2  g41220 = rst ? 0 : ((0|P03|CT_|P02_) ? 1'b0 : 1'bz);
// Gate A13-U122B
pullup(g41111);
assign #0.2  g41111 = rst ? 1'bz : ((0|F14H) ? 1'b0 : 1'bz);
// Gate A13-U146B
pullup(g41224);
assign #0.2  g41224 = rst ? 1'bz : ((0|SCAFAL|FLTOUT) ? 1'b0 : 1'bz);
// Gate A13-U139A
pullup(g41235);
assign #0.2  g41235 = rst ? 1'bz : ((0|g41234|T10) ? 1'b0 : 1'bz);
// Gate A13-U124A
pullup(g41110);
assign #0.2  g41110 = rst ? 1'bz : ((0|g41109|F14B) ? 1'b0 : 1'bz);
// Gate A13-U157B
pullup(MVFAIL_);
assign #0.2  MVFAIL_ = rst ? 1'bz : ((0|g41205) ? 1'b0 : 1'bz);
// Gate A13-U110B
pullup(g41148);
assign #0.2  g41148 = rst ? 0 : ((0|T03_|INKL|CTROR) ? 1'b0 : 1'bz);
// Gate A13-U109A
pullup(g41140);
assign #0.2  g41140 = rst ? 0 : ((0|T09_|g41138|NOTEST) ? 1'b0 : 1'bz);
// Gate A13-U138B
pullup(g41238);
assign #0.2  g41238 = rst ? 0 : ((0|ERRST|g41237|SBYEXT) ? 1'b0 : 1'bz);
// Gate A13-U137A
pullup(g41239);
assign #0.2  g41239 = rst ? 1'bz : ((0|g41238|ALTEST) ? 1'b0 : 1'bz);
// Gate A13-U152A
pullup(STRT1);
assign #0.2  STRT1 = rst ? 0 : ((0|g41245|g41247) ? 1'b0 : 1'bz);
// Gate A13-U111A
pullup(g41139);
assign #0.2  g41139 = rst ? 0 : ((0|g41138|INKL) ? 1'b0 : 1'bz);
// Gate A13-U147A
pullup(MSCAFL_);
assign #0.2  MSCAFL_ = rst ? 1'bz : ((0|SCAFAL) ? 1'b0 : 1'bz);
// Gate A13-U151B
pullup(FILTIN);
assign #0.2  FILTIN = rst ? 0 : ((0|g41214) ? 1'b0 : 1'bz);
// Gate A13-U145A
pullup(WARN);
assign #0.2  WARN = rst ? 0 : ((0|g41224) ? 1'b0 : 1'bz);
// Gate A13-U123A
pullup(g41108);
assign #0.2  g41108 = rst ? 0 : ((0|F14B|g41107) ? 1'b0 : 1'bz);
// Gate A13-U123B
pullup(g41107);
assign #0.2  g41107 = rst ? 1'bz : ((0|IIP|g41108) ? 1'b0 : 1'bz);
// Gate A13-U150B
pullup(SYNC4_);
assign #0.2  SYNC4_ = rst ? 1'bz : ((0|g41218) ? 1'b0 : 1'bz);
// Gate A13-U151A A13-U150A
pullup(g41218);
assign #0.2  g41218 = rst ? 0 : ((0|P02|FS01|P03_|CT_) ? 1'b0 : 1'bz);
// Gate A13-U145B
pullup(AGCWAR);
assign #0.2  AGCWAR = rst ? 0 : ((0|g41225|CCH33) ? 1'b0 : 1'bz);
// Gate A13-U104A A13-U104B
pullup(MCTRAL_);
assign #0.2  MCTRAL_ = rst ? 1'bz : ((0|g41143|g41151) ? 1'b0 : 1'bz);
// Gate A13-U119B
pullup(g41124);
assign #0.2  g41124 = rst ? 1'bz : ((0|F10B|g41123) ? 1'b0 : 1'bz);
// Gate A13-U140A
pullup(g41234);
assign #0.2  g41234 = rst ? 0 : ((0|g41235|SBY) ? 1'b0 : 1'bz);
// Gate A13-U119A
pullup(g41122);
assign #0.2  g41122 = rst ? 1'bz : ((0|g41121|F10B) ? 1'b0 : 1'bz);
// Gate A13-U118A
pullup(g41121);
assign #0.2  g41121 = rst ? 0 : ((0|g41122|TCF0|TC0) ? 1'b0 : 1'bz);
// Gate A13-U137B
pullup(RESTRT);
assign #0.2  RESTRT = rst ? 0 : ((0|g41239) ? 1'b0 : 1'bz);
// Gate A13-U129B
pullup(g41101);
assign #0.2  g41101 = rst ? 1'bz : ((0|MSTRT) ? 1'b0 : 1'bz);
// Gate A13-U128A
pullup(g41102);
assign #0.2  g41102 = rst ? 0 : ((0|F05B_|g41101) ? 1'b0 : 1'bz);
// Gate A13-U118B
pullup(g41123);
assign #0.2  g41123 = rst ? 0 : ((0|g41120|g41124) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
