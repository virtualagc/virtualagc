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
assign (highz1,strong0) #0.2  DLKPLS = rst ? 0 : ~(0|A13U102Pad1|T10_);
// Gate A13-U138A
pullup(A13U138Pad1);
assign (highz1,strong0) #0.2  A13U138Pad1 = rst ? 0 : ~(0|A13U137Pad2|GOJAM);
// Gate A13-U115B
pullup(A13U115Pad9);
assign (highz1,strong0) #0.2  A13U115Pad9 = rst ? 0 : ~(0|SUMA16_|G01A_|SUMB16_);
// Gate A13-U101A
pullup(DOFILT);
assign (highz1,strong0) #0.2  DOFILT = rst ? 1 : ~(0|A13U101Pad2);
// Gate A13-U115A
pullup(A13U115Pad1);
assign (highz1,strong0) #0.2  A13U115Pad1 = rst ? 0 : ~(0|G16A_|G01A);
// Gate A13-U160B
pullup(A13U159Pad8);
assign (highz1,strong0) #0.2  A13U159Pad8 = rst ? 1 : ~(0|VFAIL);
// Gate A13-U110A
pullup(A13U110Pad1);
assign (highz1,strong0) #0.2  A13U110Pad1 = rst ? 0 : ~(0|CTPLS_);
// Gate A13-U160A
pullup(A13U159Pad3);
assign (highz1,strong0) #0.2  A13U159Pad3 = rst ? 0 : ~(0|A13U159Pad8|F05B_);
// Gate A13-U134B
pullup(SCADBL);
assign (highz1,strong0) #0.2  SCADBL = rst ? 0 : ~(0|d2FSFAL|CON3);
// Gate A13-U154A
pullup(A13U154Pad1);
assign (highz1,strong0) #0.2  A13U154Pad1 = rst ? 0 : ~(0|SB0_|A13U154Pad3|A13U154Pad4);
// Gate A13-U124B
pullup(A13U124Pad2);
assign (highz1,strong0) #0.2  A13U124Pad2 = rst ? 0 : ~(0|IIP_|A13U124Pad1);
// Gate A13-U157A A13-U155A
pullup(A13U154Pad4);
assign (highz1,strong0) #0.2  A13U154Pad4 = rst ? 0 : ~(0|DOFILT|A13U157Pad3|SCADBL|ALTEST|A13U155Pad3);
// Gate A13-U130B
pullup(MSTRTP);
assign (highz1,strong0) #0.2  MSTRTP = rst ? 0 : ~(0|F05A_|A13U129Pad1);
// Gate A13-U158B
pullup(A13U157Pad3);
assign (highz1,strong0) #0.2  A13U157Pad3 = rst ? 0 : ~(0|STNDBY_|F05A_|A13U158Pad3);
// Gate A13-U133A
pullup(A13J2Pad270);
assign (highz1,strong0) #0.2  A13J2Pad270 = rst ? 1 : ~(0);
// Gate A13-U101B
pullup(A13U101Pad2);
assign (highz1,strong0) #0.2  A13U101Pad2 = rst ? 0 : ~(0|A13U101Pad6|GOJAM|A13U101Pad8);
// Gate A13-U133B
pullup(CON3);
assign (highz1,strong0) #0.2  CON3 = rst ? 1 : ~(0|CON2|FS10);
// Gate A13-U159B
pullup(A13U152Pad7);
assign (highz1,strong0) #0.2  A13U152Pad7 = rst ? 0 : ~(0|A13U158Pad3|NHVFAL|A13U159Pad8);
// Gate A13-U152B
pullup(A13U152Pad2);
assign (highz1,strong0) #0.2  A13U152Pad2 = rst ? 0 : ~(0|A13U152Pad7|F05A_);
// Gate A13-U153A
pullup(A13U152Pad3);
assign (highz1,strong0) #0.2  A13U152Pad3 = rst ? 1 : ~(0|A13U153Pad2|STRT1);
// Gate A13-U130A
pullup(A13U129Pad2);
assign (highz1,strong0) #0.2  A13U129Pad2 = rst ? 0 : ~(0|A13U129Pad1|A13U128Pad3);
// Gate A13-U129A
pullup(A13U129Pad1);
assign (highz1,strong0) #0.2  A13U129Pad1 = rst ? 1 : ~(0|A13U129Pad2|A13U128Pad1);
// Gate A13-U154B
pullup(A13U151Pad7);
assign (highz1,strong0) #0.2  A13U151Pad7 = rst ? 0 : ~(0|A13U153Pad9|A13U154Pad1);
// Gate A13-U144B
pullup(A13U143Pad7);
assign (highz1,strong0) #0.2  A13U143Pad7 = rst ? 0 : ~(0|TMPOUT|TEMPIN_);
// Gate A13-U144A
pullup(CGCWAR);
assign (highz1,strong0) #0.2  CGCWAR = rst ? 1 : ~(0|WARN);
// Gate A13-U127A A13-U122A
pullup(CKTAL_);
assign (highz1,strong0) #0.2  CKTAL_ = rst ? 1 : ~(0|A13U125Pad9|A13U125Pad1|PALE|WATCHP|A13U120Pad1|A13U120Pad9);
// Gate A13-U121A A13-U121B
pullup(MTCAL_);
assign (highz1,strong0) #0.2  MTCAL_ = rst ? 1 : ~(0|A13U120Pad9|A13U120Pad1);
// Gate A13-U159A
pullup(A13U158Pad3);
assign (highz1,strong0) #0.2  A13U158Pad3 = rst ? 1 : ~(0|A13U152Pad7|A13U159Pad3);
// Gate A13-U146A
pullup(A13U145Pad7);
assign (highz1,strong0) #0.2  A13U145Pad7 = rst ? 1 : ~(0|SCAFAL|FLTOUT|AGCWAR);
// Gate A13-U149A
pullup(SYNC14_);
assign (highz1,strong0) #0.2  SYNC14_ = rst ? 1 : ~(0|A13U149Pad2);
// Gate A13-U125A
pullup(A13U125Pad1);
assign (highz1,strong0) #0.2  A13U125Pad1 = rst ? 0 : ~(0|A13U122Pad9|A13U123Pad1);
// Gate A13-U125B
pullup(A13U125Pad9);
assign (highz1,strong0) #0.2  A13U125Pad9 = rst ? 0 : ~(0|A13U124Pad1|A13U122Pad9);
// Gate A13-U142A
pullup(MOSCAL_);
assign (highz1,strong0) #0.2  MOSCAL_ = rst ? 0 : ~(0|STRT2);
// Gate A13-U117A
pullup(G16SW_);
assign (highz1,strong0) #0.2  G16SW_ = rst ? 1 : ~(0|A13U115Pad1|A13U115Pad9);
// Gate A13-U141B
pullup(OSCALM);
assign (highz1,strong0) #0.2  OSCALM = rst ? 1 : ~(0|A13U141Pad1|CCH33);
// Gate A13-U139B
pullup(SBYEXT);
assign (highz1,strong0) #0.2  SBYEXT = rst ? 1 : ~(0|A13U139Pad2);
// Gate A13-U153B
pullup(A13U153Pad9);
assign (highz1,strong0) #0.2  A13U153Pad9 = rst ? 1 : ~(0|A13U151Pad7|F08B);
// Gate A13-U107B
pullup(A13U106Pad8);
assign (highz1,strong0) #0.2  A13U106Pad8 = rst ? 1 : ~(0|A13U107Pad7|A13U105Pad8);
// Gate A13-U120B
pullup(A13U120Pad9);
assign (highz1,strong0) #0.2  A13U120Pad9 = rst ? 0 : ~(0|F10A_|A13U118Pad8);
// Gate A13-U106A
pullup(A13U106Pad1);
assign (highz1,strong0) #0.2  A13U106Pad1 = rst ? 0 : ~(0|INKL|A13U105Pad2);
// Gate A13-U158A
pullup(A13U153Pad2);
assign (highz1,strong0) #0.2  A13U153Pad2 = rst ? 0 : ~(0|NHVFAL|A13U158Pad3|F05A_);
// Gate A13-U112A A13-U112B
pullup(XT1_);
assign (highz1,strong0) #0.2  XT1_ = rst ? 1 : ~(0|XT1);
// Gate A13-U128B
pullup(ALGA);
assign (highz1,strong0) #0.2  ALGA = rst ? 0 : ~(0|CKTAL_|NHALGA);
// Gate A13-U155B
pullup(A13U155Pad3);
assign (highz1,strong0) #0.2  A13U155Pad3 = rst ? 1 : ~(0|A13U155Pad7|A13U154Pad4);
// Gate A13-U156B
pullup(A13U155Pad7);
assign (highz1,strong0) #0.2  A13U155Pad7 = rst ? 0 : ~(0|A13U154Pad3|SB2_);
// Gate A13-U126A A13-U126B
pullup(MRPTAL_);
assign (highz1,strong0) #0.2  MRPTAL_ = rst ? 1 : ~(0|A13U125Pad1|A13U125Pad9);
// Gate A13-U134A
pullup(F08B_);
assign (highz1,strong0) #0.2  F08B_ = rst ? 1 : ~(0|F08B);
// Gate A13-U147B
pullup(MWARNF_);
assign (highz1,strong0) #0.2  MWARNF_ = rst ? 1 : ~(0|FLTOUT);
// Gate A13-U141A
pullup(A13U141Pad1);
assign (highz1,strong0) #0.2  A13U141Pad1 = rst ? 0 : ~(0|STRT2|OSCALM);
// Gate A13-U106B
pullup(A13U105Pad8);
assign (highz1,strong0) #0.2  A13U105Pad8 = rst ? 0 : ~(0|F07A|A13U106Pad8);
// Gate A13-U114A A13-U114B
pullup(XT0_);
assign (highz1,strong0) #0.2  XT0_ = rst ? 1 : ~(0|XT0);
// Gate A13-U107A
pullup(A13U105Pad2);
assign (highz1,strong0) #0.2  A13U105Pad2 = rst ? 1 : ~(0|A13U107Pad2|A13U106Pad1);
// Gate A13-U103B A13-U113A A13-U113B A13-U108A A13-U108B
pullup(CTPLS_);
assign (highz1,strong0) #0.2  CTPLS_ = rst ? 1 : ~(0|CDUXD|CDUYD|CDUZD|SHAFTD|TRUND|THRSTD|ALTM|OTLNKM|EMSD|RNRADM|GYROD|RNRADP|INLNKM|BMAGZM|INLNKP);
// Gate A13-U111B
pullup(A13U109Pad3);
assign (highz1,strong0) #0.2  A13U109Pad3 = rst ? 1 : ~(0|A13U111Pad1|A13U110Pad1);
// Gate A13-U127B
pullup(MPIPAL_);
assign (highz1,strong0) #0.2  MPIPAL_ = rst ? 0 : ~(0|PIPAFL);
// Gate A13-U105B
pullup(A13U101Pad8);
assign (highz1,strong0) #0.2  A13U101Pad8 = rst ? 0 : ~(0|F07B_|A13U105Pad8);
// Gate A13-U120A
pullup(A13U120Pad1);
assign (highz1,strong0) #0.2  A13U120Pad1 = rst ? 0 : ~(0|A13U118Pad2|F10A_);
// Gate A13-U103A
pullup(A13U102Pad3);
assign (highz1,strong0) #0.2  A13U102Pad3 = rst ? 0 : ~(0|A13U102Pad1|GOJAM|DRPRST);
// Gate A13-U102A
pullup(A13U102Pad1);
assign (highz1,strong0) #0.2  A13U102Pad1 = rst ? 1 : ~(0|DLKRPT|A13U102Pad3);
// Gate A13-U105A
pullup(A13U101Pad6);
assign (highz1,strong0) #0.2  A13U101Pad6 = rst ? 0 : ~(0|A13U105Pad2|T03_);
// Gate A13-U117B A13-U116B
pullup(A13U116Pad9);
assign (highz1,strong0) #0.2  A13U116Pad9 = rst ? 0 : ~(0|TC0|TCF0|T04_|INKL);
// Gate A13-U156A
pullup(A13U154Pad3);
assign (highz1,strong0) #0.2  A13U154Pad3 = rst ? 1 : ~(0|F14B);
// Gate A13-U143B
pullup(TMPCAU);
assign (highz1,strong0) #0.2  TMPCAU = rst ? 1 : ~(0|A13U143Pad7);
// Gate A13-U149B
pullup(A13U149Pad2);
assign (highz1,strong0) #0.2  A13U149Pad2 = rst ? 0 : ~(0|P03|CT_|P02_);
// Gate A13-U122B
pullup(A13U122Pad9);
assign (highz1,strong0) #0.2  A13U122Pad9 = rst ? 1 : ~(0|F14H);
// Gate A13-U146B
pullup(A13U145Pad2);
assign (highz1,strong0) #0.2  A13U145Pad2 = rst ? 1 : ~(0|SCAFAL|FLTOUT);
// Gate A13-U139A
pullup(A13U139Pad1);
assign (highz1,strong0) #0.2  A13U139Pad1 = rst ? 1 : ~(0|A13U139Pad2|T10);
// Gate A13-U124A
pullup(A13U124Pad1);
assign (highz1,strong0) #0.2  A13U124Pad1 = rst ? 1 : ~(0|A13U124Pad2|F14B);
// Gate A13-U157B
pullup(MVFAIL_);
assign (highz1,strong0) #0.2  MVFAIL_ = rst ? 1 : ~(0|A13U153Pad2);
// Gate A13-U110B
pullup(A13U107Pad7);
assign (highz1,strong0) #0.2  A13U107Pad7 = rst ? 0 : ~(0|T03_|INKL|CTROR);
// Gate A13-U109A
pullup(A13U107Pad2);
assign (highz1,strong0) #0.2  A13U107Pad2 = rst ? 0 : ~(0|T09_|A13U109Pad3|NOTEST);
// Gate A13-U138B
pullup(A13U137Pad2);
assign (highz1,strong0) #0.2  A13U137Pad2 = rst ? 0 : ~(0|ERRST|A13U138Pad1|SBYEXT);
// Gate A13-U137A
pullup(A13U137Pad1);
assign (highz1,strong0) #0.2  A13U137Pad1 = rst ? 1 : ~(0|A13U137Pad2|ALTEST);
// Gate A13-U152A
pullup(STRT1);
assign (highz1,strong0) #0.2  STRT1 = rst ? 0 : ~(0|A13U152Pad2|A13U152Pad3);
// Gate A13-U111A
pullup(A13U111Pad1);
assign (highz1,strong0) #0.2  A13U111Pad1 = rst ? 0 : ~(0|A13U109Pad3|INKL);
// Gate A13-U147A
pullup(MSCAFL_);
assign (highz1,strong0) #0.2  MSCAFL_ = rst ? 1 : ~(0|SCAFAL);
// Gate A13-U151B
pullup(FILTIN);
assign (highz1,strong0) #0.2  FILTIN = rst ? 1 : ~(0|A13U151Pad7);
// Gate A13-U145A
pullup(WARN);
assign (highz1,strong0) #0.2  WARN = rst ? 0 : ~(0|A13U145Pad2);
// Gate A13-U123A
pullup(A13U123Pad1);
assign (highz1,strong0) #0.2  A13U123Pad1 = rst ? 0 : ~(0|F14B|A13U123Pad3);
// Gate A13-U123B
pullup(A13U123Pad3);
assign (highz1,strong0) #0.2  A13U123Pad3 = rst ? 1 : ~(0|IIP|A13U123Pad1);
// Gate A13-U150B
pullup(SYNC4_);
assign (highz1,strong0) #0.2  SYNC4_ = rst ? 1 : ~(0|A13U150Pad1);
// Gate A13-U151A A13-U150A
pullup(A13U150Pad1);
assign (highz1,strong0) #0.2  A13U150Pad1 = rst ? 0 : ~(0|P02|FS01|P03_|CT_);
// Gate A13-U145B
pullup(AGCWAR);
assign (highz1,strong0) #0.2  AGCWAR = rst ? 0 : ~(0|A13U145Pad7|CCH33);
// Gate A13-U104A A13-U104B
pullup(MCTRAL_);
assign (highz1,strong0) #0.2  MCTRAL_ = rst ? 1 : ~(0|A13U101Pad6|A13U101Pad8);
// Gate A13-U119B
pullup(A13U118Pad8);
assign (highz1,strong0) #0.2  A13U118Pad8 = rst ? 1 : ~(0|F10B|A13U118Pad9);
// Gate A13-U140A
pullup(A13U139Pad2);
assign (highz1,strong0) #0.2  A13U139Pad2 = rst ? 0 : ~(0|A13U139Pad1|SBY);
// Gate A13-U119A
pullup(A13U118Pad2);
assign (highz1,strong0) #0.2  A13U118Pad2 = rst ? 1 : ~(0|A13U118Pad1|F10B);
// Gate A13-U118A
pullup(A13U118Pad1);
assign (highz1,strong0) #0.2  A13U118Pad1 = rst ? 0 : ~(0|A13U118Pad2|TCF0|TC0);
// Gate A13-U137B
pullup(RESTRT);
assign (highz1,strong0) #0.2  RESTRT = rst ? 0 : ~(0|A13U137Pad1);
// Gate A13-U129B
pullup(A13U128Pad3);
assign (highz1,strong0) #0.2  A13U128Pad3 = rst ? 1 : ~(0|MSTRT);
// Gate A13-U128A
pullup(A13U128Pad1);
assign (highz1,strong0) #0.2  A13U128Pad1 = rst ? 0 : ~(0|F05B_|A13U128Pad3);
// Gate A13-U118B
pullup(A13U118Pad9);
assign (highz1,strong0) #0.2  A13U118Pad9 = rst ? 0 : ~(0|A13U116Pad9|A13U118Pad8);

endmodule
