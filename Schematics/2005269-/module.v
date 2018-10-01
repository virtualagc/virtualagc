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

assign DLKPLS = rst ? 0 : ~(0|U102Pad1|T10_);
assign J2Pad270 = rst ? 0 : ~(0);
assign U111Pad1 = rst ? 0 : ~(0|U109Pad3|INKL);
assign U129Pad1 = rst ? 0 : ~(0|U129Pad2|U128Pad1);
assign U129Pad2 = rst ? 0 : ~(0|U129Pad1|U128Pad3);
assign U143Pad7 = rst ? 0 : ~(0|TMPOUT|TEMPIN_);
assign XT0_ = rst ? 0 : ~(0|XT0);
assign SCADBL = rst ? 0 : ~(0|d2FSFAL|CON3);
assign U109Pad3 = rst ? 0 : ~(0|U111Pad1|U110Pad1);
assign MSTRTP = rst ? 0 : ~(0|F05A_|U129Pad1);
assign U115Pad9 = rst ? 0 : ~(0|SUMA16_|G01A_|SUMB16_);
assign U150Pad1 = rst ? 0 : ~(0|P02|FS01|P03_|CT_);
assign CON3 = rst ? 0 : ~(0|CON2|FS10);
assign U115Pad1 = rst ? 0 : ~(0|G16A_|G01A);
assign U102Pad1 = rst ? 0 : ~(0|DLKRPT|U102Pad3);
assign U102Pad3 = rst ? 0 : ~(0|U102Pad1|GOJAM|DRPRST);
assign U118Pad1 = rst ? 0 : ~(0|U118Pad2|TCF0|TC0);
assign U118Pad2 = rst ? 0 : ~(0|U118Pad1|F10B);
assign U118Pad8 = rst ? 0 : ~(0|F10B|U118Pad9);
assign U118Pad9 = rst ? 0 : ~(0|U116Pad9|U118Pad8);
assign U107Pad7 = rst ? 0 : ~(0|T03_|INKL|CTROR);
assign U120Pad1 = rst ? 0 : ~(0|U118Pad2|F10A_);
assign U107Pad2 = rst ? 0 : ~(0|T09_|U109Pad3|NOTEST);
assign U120Pad9 = rst ? 0 : ~(0|F10A_|U118Pad8);
assign CGCWAR = rst ? 0 : ~(0|WARN);
assign CKTAL_ = rst ? 0 : ~(0|U125Pad9|U125Pad1|PALE|WATCHP|U120Pad1|U120Pad9);
assign MTCAL_ = rst ? 0 : ~(0|U120Pad9|U120Pad1);
assign U153Pad2 = rst ? 0 : ~(0|NHVFAL|U158Pad3|F05A_);
assign SYNC14_ = rst ? 0 : ~(0|U149Pad2);
assign U153Pad9 = rst ? 0 : ~(0|U151Pad7|F08B);
assign MOSCAL_ = rst ? 0 : ~(0|STRT2);
assign U149Pad2 = rst ? 0 : ~(0|P03|CT_|P02_);
assign G16SW_ = rst ? 0 : ~(0|U115Pad1|U115Pad9);
assign U116Pad9 = rst ? 0 : ~(0|TC0|TCF0|T04_|INKL);
assign OSCALM = rst ? 0 : ~(0|U141Pad1|CCH33);
assign SBYEXT = rst ? 0 : ~(0|U139Pad2);
assign U138Pad1 = rst ? 0 : ~(0|U137Pad2|GOJAM);
assign U128Pad1 = rst ? 0 : ~(0|F05B_|U128Pad3);
assign U128Pad3 = rst ? 0 : ~(0|MSTRT);
assign XT1_ = rst ? 0 : ~(0|XT1);
assign U157Pad3 = rst ? 0 : ~(0|STNDBY_|F05A_|U158Pad3);
assign ALGA = rst ? 0 : ~(0|CKTAL_|NHALGA);
assign U106Pad1 = rst ? 0 : ~(0|INKL|U105Pad2);
assign U106Pad8 = rst ? 0 : ~(0|U107Pad7|U105Pad8);
assign MRPTAL_ = rst ? 0 : ~(0|U125Pad1|U125Pad9);
assign U141Pad1 = rst ? 0 : ~(0|STRT2|OSCALM);
assign F08B_ = rst ? 0 : ~(0|F08B);
assign U123Pad3 = rst ? 0 : ~(0|IIP|U123Pad1);
assign U123Pad1 = rst ? 0 : ~(0|F14B|U123Pad3);
assign MWARNF_ = rst ? 0 : ~(0|FLTOUT);
assign U125Pad1 = rst ? 0 : ~(0|U122Pad9|U123Pad1);
assign U101Pad8 = rst ? 0 : ~(0|F07B_|U105Pad8);
assign U101Pad2 = rst ? 0 : ~(0|U101Pad6|GOJAM|U101Pad8);
assign U125Pad9 = rst ? 0 : ~(0|U124Pad1|U122Pad9);
assign U101Pad6 = rst ? 0 : ~(0|U105Pad2|T03_);
assign U139Pad2 = rst ? 0 : ~(0|U139Pad1|SBY);
assign U139Pad1 = rst ? 0 : ~(0|U139Pad2|T10);
assign CTPLS_ = rst ? 0 : ~(0|CDUXD|CDUYD|CDUZD|SHAFTD|TRUND|THRSTD|ALTM|OTLNKM|EMSD|RNRADM|GYROD|RNRADP|INLNKM|BMAGZM|INLNKP);
assign U159Pad8 = rst ? 0 : ~(0|VFAIL);
assign MPIPAL_ = rst ? 0 : ~(0|PIPAFL);
assign U159Pad3 = rst ? 0 : ~(0|U159Pad8|F05B_);
assign U154Pad4 = rst ? 0 : ~(0|DOFILT|U157Pad3|SCADBL|ALTEST|U155Pad3);
assign U154Pad1 = rst ? 0 : ~(0|SB0_|U154Pad3|U154Pad4);
assign U154Pad3 = rst ? 0 : ~(0|F14B);
assign U155Pad7 = rst ? 0 : ~(0|U154Pad3|SB2_);
assign TMPCAU = rst ? 0 : ~(0|U143Pad7);
assign U105Pad8 = rst ? 0 : ~(0|F07A|U106Pad8);
assign U105Pad2 = rst ? 0 : ~(0|U107Pad2|U106Pad1);
assign U110Pad1 = rst ? 0 : ~(0|CTPLS_);
assign U151Pad7 = rst ? 0 : ~(0|U153Pad9|U154Pad1);
assign MVFAIL_ = rst ? 0 : ~(0|U153Pad2);
assign U152Pad2 = rst ? 0 : ~(0|U152Pad7|F05A_);
assign U152Pad3 = rst ? 0 : ~(0|U153Pad2|STRT1);
assign U152Pad7 = rst ? 0 : ~(0|U158Pad3|NHVFAL|U159Pad8);
assign U137Pad1 = rst ? 0 : ~(0|U137Pad2|ALTEST);
assign DOFILT = rst ? 0 : ~(0|U101Pad2);
assign U137Pad2 = rst ? 0 : ~(0|ERRST|U138Pad1|SBYEXT);
assign STRT1 = rst ? 0 : ~(0|U152Pad2|U152Pad3);
assign U155Pad3 = rst ? 0 : ~(0|U155Pad7|U154Pad4);
assign MSCAFL_ = rst ? 0 : ~(0|SCAFAL);
assign FILTIN = rst ? 0 : ~(0|U151Pad7);
assign WARN = rst ? 0 : ~(0|U145Pad2);
assign SYNC4_ = rst ? 0 : ~(0|U150Pad1);
assign AGCWAR = rst ? 0 : ~(0|U145Pad7|CCH33);
assign MCTRAL_ = rst ? 0 : ~(0|U101Pad6|U101Pad8);
assign U145Pad2 = rst ? 0 : ~(0|SCAFAL|FLTOUT);
assign U158Pad3 = rst ? 0 : ~(0|U152Pad7|U159Pad3);
assign U145Pad7 = rst ? 0 : ~(0|SCAFAL|FLTOUT|AGCWAR);
assign U122Pad9 = rst ? 0 : ~(0|F14H);
assign U124Pad1 = rst ? 0 : ~(0|U124Pad2|F14B);
assign U124Pad2 = rst ? 0 : ~(0|IIP_|U124Pad1);
assign RESTRT = rst ? 0 : ~(0|U137Pad1);

endmodule
