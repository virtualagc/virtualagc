// Verilog module auto-generated for AGC module A4 by dumbVerilog.py

module A4 ( 
  rst, CGA4, DVST, EXST0_, EXST1_, GEQZRO_, GOJAM, IC12, IC13, INKL, L15_,
  MP0_, MP1, MP3_, MTCSAI, NDR100_, OVF_, PHS2_, PHS3_, PHS4, PHS4_, QC0_,
  QC1_, QC2_, QC3_, RSM3, RSM3_, RSTSTG, SQ0_, SQ1_, SQ2_, SQEXT, SQEXT_,
  SQR10, SQR10_, SQR12_, ST1, ST2, STORE1_, STRTFC, SUMA16_, SUMB16_, T01,
  T01_, T02_, T03_, T04_, T05_, T06_, T07_, T08_, T09_, T10_, T11_, T12_,
  TOV_, TPZG_, TRSM, TS0_, TSGU_, UNF_, WL01_, WL02_, WL03_, WL04_, WL05_,
  WL06_, WL07_, WL08_, WL09_, WL10_, WL11_, WL12_, WL13_, WL14_, WL15_, WL16_,
  XB7_, XT1_, d7XP14, BR1, BR1_, BR2, BR2_, CI_, DV0_, DV1_, DV4, DVST_,
  L16_, MBR1, MBR2, MP3A, MRSC, MST1, MST2, MST3, R1C_, RA_, RB1_, RB_, RC_,
  ST0_, TL15, TMZ_, TRSM_, TSGN2, TSGN_, WG_, WL_, WY_, d2PP1, B15X, BR12B,
  BR12B_, BR1B2, BR1B2B, BR1B2B_, BR1B2_, BRDIF_, DIVSTG, DIV_, DV0, DV1,
  DV1376, DV1376_, DV376, DV3764, DV376_, DV4_, INOUT, INOUT_, KRPT, MP0T10,
  PRINC, R15, RAND0, RB2, READ0, READ0_, ROR0, RRPA, RSC_, RUPT0, RUPT0_,
  RUPT1, RUPT1_, RXOR0, RXOR0_, SGUM, ST1376_, ST1D, ST1_, ST376, ST376_,
  ST3_, ST4_, STD2, STG1, STG2, STG3, T12USE_, WAND0, WCH_, WOR0, WOR0_,
  WRITE0, WRITE0_, d1XP10, d2XP3, d2XP5, d3XP2, d3XP7, d4XP11, d4XP5, d5XP11,
  d5XP28, d5XP4, d6XP5, d7XP19, d8PP4, d8XP5, d8XP6, d9XP1
);

input wire rst, CGA4, DVST, EXST0_, EXST1_, GEQZRO_, GOJAM, IC12, IC13, INKL,
  L15_, MP0_, MP1, MP3_, MTCSAI, NDR100_, OVF_, PHS2_, PHS3_, PHS4, PHS4_,
  QC0_, QC1_, QC2_, QC3_, RSM3, RSM3_, RSTSTG, SQ0_, SQ1_, SQ2_, SQEXT, SQEXT_,
  SQR10, SQR10_, SQR12_, ST1, ST2, STORE1_, STRTFC, SUMA16_, SUMB16_, T01,
  T01_, T02_, T03_, T04_, T05_, T06_, T07_, T08_, T09_, T10_, T11_, T12_,
  TOV_, TPZG_, TRSM, TS0_, TSGU_, UNF_, WL01_, WL02_, WL03_, WL04_, WL05_,
  WL06_, WL07_, WL08_, WL09_, WL10_, WL11_, WL12_, WL13_, WL14_, WL15_, WL16_,
  XB7_, XT1_, d7XP14;

inout wire BR1, BR1_, BR2, BR2_, CI_, DV0_, DV1_, DV4, DVST_, L16_, MBR1,
  MBR2, MP3A, MRSC, MST1, MST2, MST3, R1C_, RA_, RB1_, RB_, RC_, ST0_, TL15,
  TMZ_, TRSM_, TSGN2, TSGN_, WG_, WL_, WY_, d2PP1;

output wire B15X, BR12B, BR12B_, BR1B2, BR1B2B, BR1B2B_, BR1B2_, BRDIF_,
  DIVSTG, DIV_, DV0, DV1, DV1376, DV1376_, DV376, DV3764, DV376_, DV4_, INOUT,
  INOUT_, KRPT, MP0T10, PRINC, R15, RAND0, RB2, READ0, READ0_, ROR0, RRPA,
  RSC_, RUPT0, RUPT0_, RUPT1, RUPT1_, RXOR0, RXOR0_, SGUM, ST1376_, ST1D,
  ST1_, ST376, ST376_, ST3_, ST4_, STD2, STG1, STG2, STG3, T12USE_, WAND0,
  WCH_, WOR0, WOR0_, WRITE0, WRITE0_, d1XP10, d2XP3, d2XP5, d3XP2, d3XP7,
  d4XP11, d4XP5, d5XP11, d5XP28, d5XP4, d6XP5, d7XP19, d8PP4, d8XP5, d8XP6,
  d9XP1;

assign U121Pad3 = rst ? 0 : ~(0|PHS3_|U122Pad2);
assign U244Pad9 = rst ? 0 : ~(0|DV1_|T04_|BR2_);
assign U121Pad8 = rst ? 0 : ~(0|UNF_|TOV_);
assign d8PP4 = rst ? 0 : ~(0|DV4|INOUT|PRINC);
assign U140Pad6 = rst ? 0 : ~(0|U135Pad2|DVST_);
assign U140Pad1 = rst ? 0 : ~(0|T01|U139Pad9|GOJAM);
assign U237Pad1 = rst ? 0 : ~(0|DV1_|T07_);
assign RB1_ = rst ? 0 : ~(0|U234Pad9|U235Pad3);
assign d1XP10 = rst ? 0 : ~(0|T01_|DV0_);
assign DV1376 = rst ? 0 : ~(0|ST1376_|DIV_);
assign U141Pad9 = rst ? 0 : ~(0|U133Pad9|U139Pad9);
assign U108Pad8 = rst ? 0 : ~(0|TMZ_|PHS3_);
assign d2PP1 = rst ? 0 : ~(0|INOUT|MP1|MP3A);
assign U108Pad3 = rst ? 0 : ~(0|PHS4_|WL16_|U110Pad3);
assign U108Pad2 = rst ? 0 : ~(0|WL01_|TMZ_|PHS4_|WL03_|WL04_|WL02_|WL10_|WL08_|WL09_|WL11_|WL12_|WL13_|WL07_|WL06_|WL05_|WL16_|WL15_|WL14_);
assign ROR0 = rst ? 0 : ~(0|U201Pad1|QC2_|SQR10);
assign BR1_ = rst ? 0 : ~(0|U109Pad2);
assign STD2 = rst ? 0 : ~(0|STG3|U139Pad2|STG1|INKL);
assign MBR2 = rst ? 0 : ~(0|U101Pad7);
assign MBR1 = rst ? 0 : ~(0|U113Pad7);
assign U133Pad1 = rst ? 0 : ~(0|PHS3_|U131Pad1|T12_);
assign BRDIF_ = rst ? 0 : ~(0|BR12B|BR1B2);
assign ST3_ = rst ? 0 : ~(0|U155Pad1);
assign d5XP4 = rst ? 0 : ~(0|RSM3_|T05_);
assign KRPT = rst ? 0 : ~(0|T09_|RUPT1_);
assign U133Pad9 = rst ? 0 : ~(0|U132Pad1|U133Pad1);
assign RXOR0 = rst ? 0 : ~(0|U201Pad1|QC3_|SQR10);
assign BR1B2_ = rst ? 0 : ~(0|BR1B2);
assign BR1B2B = rst ? 0 : ~(0|BR2|BR1);
assign DIVSTG = rst ? 0 : ~(0|T12USE_|T03_);
assign U235Pad3 = rst ? 0 : ~(0|BR1_|T11_|MP0_);
assign R1C_ = rst ? 0 : ~(0|U233Pad9|U235Pad3);
assign U213Pad9 = rst ? 0 : ~(0|RAND0|WAND0);
assign U115Pad9 = rst ? 0 : ~(0|PHS4|PHS3_|U115Pad7|TSGU_);
assign U117Pad9 = rst ? 0 : ~(0|WL16_|PHS4_|TSGN_);
assign DV1_ = rst ? 0 : ~(0|DV1);
assign READ0 = rst ? 0 : ~(0|SQR10|U201Pad1|QC0_);
assign U117Pad1 = rst ? 0 : ~(0|PHS3_|TSGN_);
assign BR1B2B_ = rst ? 0 : ~(0|BR1B2B);
assign U104Pad9 = rst ? 0 : ~(0|T01|STRTFC|U144Pad8|RSTSTG);
assign U224Pad1 = rst ? 0 : ~(0|IC13|IC12|RUPT1);
assign RUPT0_ = rst ? 0 : ~(0|RUPT0);
assign d5XP11 = rst ? 0 : ~(0|T05_|INOUT_|READ0|WRITE0|RXOR0);
assign BR12B = rst ? 0 : ~(0|BR1_|BR2);
assign RAND0 = rst ? 0 : ~(0|SQR10|QC1_|U201Pad1);
assign ST376_ = rst ? 0 : ~(0|ST376);
assign U221Pad9 = rst ? 0 : ~(0|T05_|READ0_);
assign U255Pad9 = rst ? 0 : ~(0|T04_|BRDIF_|TS0_);
assign U223Pad1 = rst ? 0 : ~(0|SQR12_|SQ2_|ST0_);
assign U222Pad2 = rst ? 0 : ~(0|U224Pad1|T09_);
assign U107Pad7 = rst ? 0 : ~(0|PHS3_|U110Pad3);
assign SGUM = rst ? 0 : ~(0|PHS3_|PHS4|SUMA16_|SUMB16_|TSGU_);
assign RUPT0 = rst ? 0 : ~(0|U201Pad1|SQR10_|QC3_);
assign U109Pad2 = rst ? 0 : ~(0|U113Pad7|U121Pad3|U117Pad1|U108Pad7|U115Pad9);
assign U120Pad8 = rst ? 0 : ~(0|U122Pad2|L15_);
assign PRINC = rst ? 0 : ~(0|U225Pad9|U225Pad1);
assign WAND0 = rst ? 0 : ~(0|SQR10_|U201Pad1|QC1_);
assign U115Pad7 = rst ? 0 : ~(0|SUMB16_|SUMA16_);
assign U217Pad7 = rst ? 0 : ~(0|T05_|WRITE0_);
assign WL_ = rst ? 0 : ~(0|U239Pad2|U239Pad7|d6XP5);
assign INOUT = rst ? 0 : ~(0|RUPT0|SQ0_|EXST0_);
assign RSC_ = rst ? 0 : ~(0|U237Pad1|U247Pad9|U250Pad1);
assign R15 = rst ? 0 : ~(0|T01_|U251Pad1);
assign U131Pad1 = rst ? 0 : ~(0|RSTSTG|T12USE_|GOJAM);
assign U134Pad7 = rst ? 0 : ~(0|U134Pad9|T01);
assign TSGN_ = rst ? 0 : ~(0|U231Pad1|U244Pad9|U237Pad1|MP0T10|d1XP10);
assign TSGN2 = rst ? 0 : ~(0|T07_|MP0_);
assign RXOR0_ = rst ? 0 : ~(0|RXOR0);
assign MST1 = rst ? 0 : ~(0|U135Pad2);
assign MST2 = rst ? 0 : ~(0|U139Pad2);
assign MST3 = rst ? 0 : ~(0|U147Pad1);
assign DV376 = rst ? 0 : ~(0|DIV_|ST376_);
assign WRITE0_ = rst ? 0 : ~(0|WRITE0);
assign U113Pad7 = rst ? 0 : ~(0|SGUM|U121Pad8|U109Pad2|U117Pad9|U120Pad8);
assign U250Pad1 = rst ? 0 : ~(0|T02_|U249Pad1);
assign ST0_ = rst ? 0 : ~(0|U149Pad9);
assign U231Pad1 = rst ? 0 : ~(0|T03_|MP0_);
assign U156Pad9 = rst ? 0 : ~(0|STG2|STG1|U147Pad1);
assign INOUT_ = rst ? 0 : ~(0|INOUT);
assign U239Pad4 = rst ? 0 : ~(0|T09_|BR1|MP0_);
assign U239Pad2 = rst ? 0 : ~(0|BR1|MP0_|T04_);
assign U156Pad2 = rst ? 0 : ~(0|STG1|STG3);
assign U239Pad7 = rst ? 0 : ~(0|MP0_|T04_|BR1_);
assign U245Pad9 = rst ? 0 : ~(0|BRDIF_|MP0_|T09_);
assign WG_ = rst ? 0 : ~(0|d9XP1|U228Pad1|U220Pad9|U223Pad9|U222Pad2|U227Pad9|U250Pad1|U247Pad9);
assign U149Pad9 = rst ? 0 : ~(0|STG3|STG1|STG2);
assign U146Pad1 = rst ? 0 : ~(0|U133Pad9|U144Pad8);
assign ST1D = rst ? 0 : ~(0|U135Pad2|STG2|STG3);
assign MP0T10 = rst ? 0 : ~(0|T10_|MP0_);
assign U146Pad9 = rst ? 0 : ~(0|U104Pad9|U133Pad9);
assign U134Pad6 = rst ? 0 : ~(0|STG3|DVST_);
assign d3XP2 = rst ? 0 : ~(0|T03_|TS0_);
assign BR12B_ = rst ? 0 : ~(0|BR12B);
assign U128Pad2 = rst ? 0 : ~(0|QC0_|SQ1_|SQEXT_);
assign BR2_ = rst ? 0 : ~(0|U105Pad8);
assign ST1_ = rst ? 0 : ~(0|ST1D);
assign DV1376_ = rst ? 0 : ~(0|DV1376);
assign RUPT1_ = rst ? 0 : ~(0|RUPT1);
assign TMZ_ = rst ? 0 : ~(0|d2XP5|d1XP10);
assign U233Pad9 = rst ? 0 : ~(0|T05_|BR12B_|TS0_);
assign MP3A = rst ? 0 : ~(0|MP3_);
assign WY_ = rst ? 0 : ~(0|B15X|d7XP19|U234Pad1|d8XP5|U239Pad4|U246Pad1);
assign WRITE0 = rst ? 0 : ~(0|QC0_|SQR10_|U201Pad1);
assign U144Pad8 = rst ? 0 : ~(0|U145Pad2|U104Pad9);
assign BR2 = rst ? 0 : ~(0|U101Pad7);
assign BR1 = rst ? 0 : ~(0|U113Pad7);
assign U141Pad1 = rst ? 0 : ~(0|U133Pad9|U140Pad1);
assign d4XP5 = rst ? 0 : ~(0|T04_|TS0_);
assign d5XP28 = rst ? 0 : ~(0|T05_|DV4_);
assign RUPT1 = rst ? 0 : ~(0|SQR10_|EXST1_|QC3_|SQ0_);
assign U201Pad1 = rst ? 0 : ~(0|U201Pad2);
assign U101Pad1 = rst ? 0 : ~(0|XB7_|TRSM_|XT1_|NDR100_);
assign U101Pad7 = rst ? 0 : ~(0|U103Pad1|U103Pad9|U108Pad2|U108Pad3|U105Pad8);
assign U245Pad1 = rst ? 0 : ~(0|T09_|MP3_);
assign d4XP11 = rst ? 0 : ~(0|INOUT_|T04_);
assign U139Pad9 = rst ? 0 : ~(0|U140Pad6|MTCSAI|U140Pad1|ST2|U101Pad1);
assign d8XP6 = rst ? 0 : ~(0|T08_|DV1_|BR2);
assign TRSM_ = rst ? 0 : ~(0|TRSM);
assign U246Pad1 = rst ? 0 : ~(0|BR1_|T09_|MP0_);
assign U139Pad2 = rst ? 0 : ~(0|U141Pad9|STG2);
assign DIV_ = rst ? 0 : ~(0|U128Pad2);
assign U135Pad2 = rst ? 0 : ~(0|STG1|U136Pad1);
assign DVST_ = rst ? 0 : ~(0|DVST);
assign RA_ = rst ? 0 : ~(0|d2XP3|U217Pad7|U220Pad9|d1XP10|U245Pad1|d8XP5);
assign d9XP1 = rst ? 0 : ~(0|T09_|RUPT0_);
assign U227Pad9 = rst ? 0 : ~(0|T09_|STORE1_);
assign T12USE_ = rst ? 0 : ~(0|DVST|U131Pad1);
assign U201Pad2 = rst ? 0 : ~(0|EXST0_|SQ0_);
assign READ0_ = rst ? 0 : ~(0|READ0);
assign U108Pad7 = rst ? 0 : ~(0|PHS2_|TOV_);
assign B15X = rst ? 0 : ~(0|DV1_|T05_);
assign U213Pad1 = rst ? 0 : ~(0|U210Pad9|T03_);
assign ST376 = rst ? 0 : ~(0|U156Pad2|U139Pad2);
assign U134Pad9 = rst ? 0 : ~(0|U134Pad6|U134Pad7|ST1|GOJAM|MTCSAI);
assign STG1 = rst ? 0 : ~(0|U137Pad9|U135Pad2);
assign STG2 = rst ? 0 : ~(0|U139Pad2|U141Pad1);
assign STG3 = rst ? 0 : ~(0|U146Pad9|U147Pad1);
assign DV4 = rst ? 0 : ~(0|DIV_|ST4_);
assign DV1 = rst ? 0 : ~(0|DIV_|ST1_);
assign DV0 = rst ? 0 : ~(0|DIV_|ST0_);
assign L16_ = rst ? 0 : ~(0|U235Pad3);
assign ST4_ = rst ? 0 : ~(0|U156Pad9);
assign RC_ = rst ? 0 : ~(0|U220Pad9|U228Pad1|U214Pad9|d2XP5|U239Pad7|U246Pad1);
assign d6XP5 = rst ? 0 : ~(0|T06_|DV1_);
assign DV3764 = rst ? 0 : ~(0|DIV_|U158Pad1);
assign DV4_ = rst ? 0 : ~(0|DV4);
assign TL15 = rst ? 0 : ~(0|MP3_|T06_);
assign U234Pad1 = rst ? 0 : ~(0|INOUT_|T03_);
assign U105Pad8 = rst ? 0 : ~(0|U101Pad7|U107Pad7|U108Pad7|U108Pad8);
assign BR1B2 = rst ? 0 : ~(0|BR2_|BR1);
assign d8XP5 = rst ? 0 : ~(0|DV1_|T08_);
assign d3XP7 = rst ? 0 : ~(0|T03_|RXOR0_);
assign U234Pad9 = rst ? 0 : ~(0|TS0_|BR1B2_|T05_);
assign U110Pad3 = rst ? 0 : ~(0|TSGN2);
assign DV0_ = rst ? 0 : ~(0|DV0);
assign MRSC = rst ? 0 : ~(0|RSC_);
assign U136Pad1 = rst ? 0 : ~(0|U134Pad9|U133Pad9);
assign CI_ = rst ? 0 : ~(0|U245Pad9|U255Pad9);
assign RB2 = rst ? 0 : ~(0|T01_|RUPT1_);
assign U103Pad1 = rst ? 0 : ~(0|PHS4_|TPZG_|GEQZRO_);
assign d2XP5 = rst ? 0 : ~(0|T02_|DV0_|BR1);
assign U251Pad1 = rst ? 0 : ~(0|RUPT1|RSM3|RUPT0);
assign U155Pad1 = rst ? 0 : ~(0|U135Pad2|STG3|U139Pad2);
assign ST1376_ = rst ? 0 : ~(0|ST376|ST1D);
assign U137Pad9 = rst ? 0 : ~(0|U134Pad7|U133Pad9);
assign U103Pad9 = rst ? 0 : ~(0|TOV_|OVF_);
assign U249Pad1 = rst ? 0 : ~(0|d2PP1);
assign d2XP3 = rst ? 0 : ~(0|T02_|INOUT_);
assign RB_ = rst ? 0 : ~(0|U222Pad2|U213Pad1|U221Pad9|U239Pad2|d7XP19|U239Pad4);
assign U220Pad9 = rst ? 0 : ~(0|T05_|RXOR0_);
assign U132Pad1 = rst ? 0 : ~(0|PHS3_|T03_|T12USE_);
assign U210Pad9 = rst ? 0 : ~(0|ROR0|WOR0);
assign U147Pad1 = rst ? 0 : ~(0|STG3|U146Pad1);
assign U223Pad9 = rst ? 0 : ~(0|WRITE0_|T02_);
assign d7XP19 = rst ? 0 : ~(0|BR1_|MP3_|T07_);
assign WOR0_ = rst ? 0 : ~(0|WOR0);
assign WOR0 = rst ? 0 : ~(0|QC2_|U201Pad1|SQR10_);
assign U122Pad2 = rst ? 0 : ~(0|TL15);
assign U145Pad2 = rst ? 0 : ~(0|DVST_|U139Pad2);
assign U158Pad1 = rst ? 0 : ~(0|U156Pad9|ST376);
assign U247Pad9 = rst ? 0 : ~(0|MP3_|T04_);
assign RRPA = rst ? 0 : ~(0|RUPT1_|T03_);
assign U214Pad9 = rst ? 0 : ~(0|U213Pad9|T03_);
assign U228Pad1 = rst ? 0 : ~(0|T09_|RXOR0_);
assign U217Pad6 = rst ? 0 : ~(0|T05_|WOR0_);
assign U225Pad1 = rst ? 0 : ~(0|SQEXT|QC3_);
assign DV376_ = rst ? 0 : ~(0|DV376);
assign U225Pad9 = rst ? 0 : ~(0|U223Pad1);
assign WCH_ = rst ? 0 : ~(0|U217Pad6|U217Pad7|d7XP14);

endmodule
