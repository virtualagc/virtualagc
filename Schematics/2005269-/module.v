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

input wand rst, ALTEST, ALTM, BMAGZM, CCH33, CDUXD, CDUYD, CDUZD, CGA13,
  CON2, CTROR, CT_, DLKRPT, DRPRST, EMSD, ERRST, F05A_, F05B_, F07A, F07B_,
  F08B, F10A_, F10B, F14B, F14H, FLTOUT, FS01, FS10, G01A, G01A_, G16A_,
  GOJAM, GYROD, IIP, IIP_, INKL, INLNKM, INLNKP, MSTRT, NHALGA, NHVFAL, NOTEST,
  OTLNKM, P02, P02_, P03, P03_, PALE, PIPAFL, RNRADM, RNRADP, SB0_, SB2_,
  SBY, SCAFAL, SHAFTD, STNDBY_, STRT2, SUMA16_, SUMB16_, T03_, T04_, T09_,
  T10, T10_, TC0, TCF0, TEMPIN_, THRSTD, TMPOUT, TRUND, VFAIL, WATCHP, XT0,
  XT1, d2FSFAL;

inout wand CON3, CTPLS_, DOFILT, FILTIN, MCTRAL_, MOSCAL_, MPIPAL_, MRPTAL_,
  MSCAFL_, MTCAL_, MVFAIL_, MWARNF_, SCADBL, WARN, XT0_, XT1_;

output wand AGCWAR, ALGA, CGCWAR, CKTAL_, DLKPLS, F08B_, G16SW_, MSTRTP,
  OSCALM, RESTRT, SBYEXT, STRT1, SYNC14_, SYNC4_, TMPCAU;

// Gate A13-U102B
assign #0.2  DLKPLS = rst ? 0 : !(0|g41152|T10_);
// Gate A13-U138A
assign #0.2  g41237 = rst ? 0 : !(0|g41238|GOJAM);
// Gate A13-U115B
assign #0.2  g41130 = rst ? 0 : !(0|SUMA16_|G01A_|SUMB16_);
// Gate A13-U101A
assign #0.2  DOFILT = rst ? 1 : !(0|g41146);
// Gate A13-U115A
assign #0.2  g41129 = rst ? 0 : !(0|G16A_|G01A);
// Gate A13-U160B
assign #0.2  g41201 = rst ? 1 : !(0|VFAIL);
// Gate A13-U110A
assign #0.2  g41137 = rst ? 0 : !(0|CTPLS_);
// Gate A13-U160A
assign #0.2  g41202 = rst ? 0 : !(0|g41201|F05B_);
// Gate A13-U134B
assign #0.2  SCADBL = rst ? 0 : !(0|d2FSFAL|CON3);
// Gate A13-U154A
assign #0.2  g41213 = rst ? 0 : !(0|SB0_|g41209|g41211);
// Gate A13-U124B
assign #0.2  g41109 = rst ? 0 : !(0|IIP_|g41110);
// Gate A13-U157A A13-U155A
assign #0.2  g41211 = rst ? 0 : !(0|DOFILT|g41206|SCADBL|ALTEST|g41212);
// Gate A13-U130B
assign #0.2  MSTRTP = rst ? 0 : !(0|F05A_|g41103);
// Gate A13-U158B
assign #0.2  g41206 = rst ? 0 : !(0|STNDBY_|F05A_|g41203);
// Gate A13-U133A
assign #0.2  g41244 = rst ? 1 : !(0);
// Gate A13-U101B
assign #0.2  g41146 = rst ? 0 : !(0|g41143|GOJAM|g41151);
// Gate A13-U133B
assign #0.2  CON3 = rst ? 1 : !(0|CON2|FS10);
// Gate A13-U159B
assign #0.2  g41204 = rst ? 0 : !(0|g41203|NHVFAL|g41201);
// Gate A13-U152B
assign #0.2  g41245 = rst ? 0 : !(0|g41204|F05A_);
// Gate A13-U153A
assign #0.2  g41247 = rst ? 1 : !(0|g41205|STRT1);
// Gate A13-U130A
assign #0.2  g41104 = rst ? 0 : !(0|g41103|g41101);
// Gate A13-U129A
assign #0.2  g41103 = rst ? 1 : !(0|g41104|g41102);
// Gate A13-U154B
assign #0.2  g41214 = rst ? 1 : !(0|g41215|g41213);
// Gate A13-U144B
assign #0.2  g41229 = rst ? 0 : !(0|TMPOUT|TEMPIN_);
// Gate A13-U144A
assign #0.2  CGCWAR = rst ? 1 : !(0|WARN);
// Gate A13-U127A A13-U122A
assign #0.2  CKTAL_ = rst ? 1 : !(0|g41113|g41112|PALE|WATCHP|g41125|g41126);
// Gate A13-U121A A13-U121B
assign #0.2  MTCAL_ = rst ? 1 : !(0|g41126|g41125);
// Gate A13-U159A
assign #0.2  g41203 = rst ? 1 : !(0|g41204|g41202);
// Gate A13-U146A
assign #0.2  g41225 = rst ? 1 : !(0|SCAFAL|FLTOUT|AGCWAR);
// Gate A13-U149A
assign #0.2  SYNC14_ = rst ? 1 : !(0|g41220);
// Gate A13-U125A
assign #0.2  g41112 = rst ? 0 : !(0|g41111|g41108);
// Gate A13-U125B
assign #0.2  g41113 = rst ? 0 : !(0|g41110|g41111);
// Gate A13-U142A
assign #0.2  MOSCAL_ = rst ? 0 : !(0|STRT2);
// Gate A13-U117A
assign #0.2  G16SW_ = rst ? 1 : !(0|g41129|g41130);
// Gate A13-U141B
assign #0.2  OSCALM = rst ? 1 : !(0|g41232|CCH33);
// Gate A13-U139B
assign #0.2  SBYEXT = rst ? 0 : !(0|g41234);
// Gate A13-U153B
assign #0.2  g41215 = rst ? 0 : !(0|g41214|F08B);
// Gate A13-U107B
assign #0.2  g41149 = rst ? 0 : !(0|g41148|g41150);
// Gate A13-U120B
assign #0.2  g41126 = rst ? 0 : !(0|F10A_|g41124);
// Gate A13-U106A
assign #0.2  g41142 = rst ? 0 : !(0|INKL|g41141);
// Gate A13-U158A
assign #0.2  g41205 = rst ? 0 : !(0|NHVFAL|g41203|F05A_);
// Gate A13-U112A A13-U112B
assign #0.2  XT1_ = rst ? 1 : !(0|XT1);
// Gate A13-U128B
assign #0.2  ALGA = rst ? 0 : !(0|CKTAL_|NHALGA);
// Gate A13-U155B
assign #0.2  g41212 = rst ? 1 : !(0|g41210|g41211);
// Gate A13-U156B
assign #0.2  g41210 = rst ? 0 : !(0|g41209|SB2_);
// Gate A13-U126A A13-U126B
assign #0.2  MRPTAL_ = rst ? 1 : !(0|g41112|g41113);
// Gate A13-U134A
assign #0.2  F08B_ = rst ? 1 : !(0|F08B);
// Gate A13-U147B
assign #0.2  MWARNF_ = rst ? 1 : !(0|FLTOUT);
// Gate A13-U141A
assign #0.2  g41232 = rst ? 0 : !(0|STRT2|OSCALM);
// Gate A13-U106B
assign #0.2  g41150 = rst ? 1 : !(0|F07A|g41149);
// Gate A13-U114A A13-U114B
assign #0.2  XT0_ = rst ? 0 : !(0|XT0);
// Gate A13-U107A
assign #0.2  g41141 = rst ? 1 : !(0|g41140|g41142);
// Gate A13-U103B A13-U113A A13-U113B A13-U108A A13-U108B
assign #0.2  CTPLS_ = rst ? 1 : !(0|CDUXD|CDUYD|CDUZD|SHAFTD|TRUND|THRSTD|ALTM|OTLNKM|EMSD|RNRADM|GYROD|RNRADP|INLNKM|BMAGZM|INLNKP);
// Gate A13-U111B
assign #0.2  g41138 = rst ? 1 : !(0|g41139|g41137);
// Gate A13-U127B
assign #0.2  MPIPAL_ = rst ? 0 : !(0|PIPAFL);
// Gate A13-U105B
assign #0.2  g41151 = rst ? 0 : !(0|F07B_|g41150);
// Gate A13-U120A
assign #0.2  g41125 = rst ? 0 : !(0|g41122|F10A_);
// Gate A13-U103A
assign #0.2  g41153 = rst ? 0 : !(0|g41152|GOJAM|DRPRST);
// Gate A13-U102A
assign #0.2  g41152 = rst ? 1 : !(0|DLKRPT|g41153);
// Gate A13-U105A
assign #0.2  g41143 = rst ? 0 : !(0|g41141|T03_);
// Gate A13-U117B A13-U116B
assign #0.2  g41120 = rst ? 0 : !(0|TC0|TCF0|T04_|INKL);
// Gate A13-U156A
assign #0.2  g41209 = rst ? 1 : !(0|F14B);
// Gate A13-U143B
assign #0.2  TMPCAU = rst ? 1 : !(0|g41229);
// Gate A13-U149B
assign #0.2  g41220 = rst ? 0 : !(0|P03|CT_|P02_);
// Gate A13-U122B
assign #0.2  g41111 = rst ? 1 : !(0|F14H);
// Gate A13-U146B
assign #0.2  g41224 = rst ? 1 : !(0|SCAFAL|FLTOUT);
// Gate A13-U139A
assign #0.2  g41235 = rst ? 0 : !(0|g41234|T10);
// Gate A13-U124A
assign #0.2  g41110 = rst ? 1 : !(0|g41109|F14B);
// Gate A13-U157B
assign #0.2  MVFAIL_ = rst ? 1 : !(0|g41205);
// Gate A13-U110B
assign #0.2  g41148 = rst ? 0 : !(0|T03_|INKL|CTROR);
// Gate A13-U109A
assign #0.2  g41140 = rst ? 0 : !(0|T09_|g41138|NOTEST);
// Gate A13-U138B
assign #0.2  g41238 = rst ? 1 : !(0|ERRST|g41237|SBYEXT);
// Gate A13-U137A
assign #0.2  g41239 = rst ? 0 : !(0|g41238|ALTEST);
// Gate A13-U152A
assign #0.2  STRT1 = rst ? 0 : !(0|g41245|g41247);
// Gate A13-U111A
assign #0.2  g41139 = rst ? 0 : !(0|g41138|INKL);
// Gate A13-U147A
assign #0.2  MSCAFL_ = rst ? 1 : !(0|SCAFAL);
// Gate A13-U151B
assign #0.2  FILTIN = rst ? 0 : !(0|g41214);
// Gate A13-U145A
assign #0.2  WARN = rst ? 0 : !(0|g41224);
// Gate A13-U123A
assign #0.2  g41108 = rst ? 0 : !(0|F14B|g41107);
// Gate A13-U123B
assign #0.2  g41107 = rst ? 1 : !(0|IIP|g41108);
// Gate A13-U150B
assign #0.2  SYNC4_ = rst ? 1 : !(0|g41218);
// Gate A13-U151A A13-U150A
assign #0.2  g41218 = rst ? 0 : !(0|P02|FS01|P03_|CT_);
// Gate A13-U145B
assign #0.2  AGCWAR = rst ? 0 : !(0|g41225|CCH33);
// Gate A13-U104A A13-U104B
assign #0.2  MCTRAL_ = rst ? 1 : !(0|g41143|g41151);
// Gate A13-U119B
assign #0.2  g41124 = rst ? 0 : !(0|F10B|g41123);
// Gate A13-U140A
assign #0.2  g41234 = rst ? 1 : !(0|g41235|SBY);
// Gate A13-U119A
assign #0.2  g41122 = rst ? 1 : !(0|g41121|F10B);
// Gate A13-U118A
assign #0.2  g41121 = rst ? 0 : !(0|g41122|TCF0|TC0);
// Gate A13-U137B
assign #0.2  RESTRT = rst ? 1 : !(0|g41239);
// Gate A13-U129B
assign #0.2  g41101 = rst ? 1 : !(0|MSTRT);
// Gate A13-U128A
assign #0.2  g41102 = rst ? 0 : !(0|F05B_|g41101);
// Gate A13-U118B
assign #0.2  g41123 = rst ? 1 : !(0|g41120|g41124);
// End of NOR gates

endmodule
