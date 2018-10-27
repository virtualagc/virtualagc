`timescale 1ns/1ps
`default_nettype none

module stage_branch(SIM_RST, SIM_CLK, p4VSW, GND, GOJAM, PHS2_n, PHS3_n, PHS4, PHS4_n, T01, T01_n, T02_n, T03_n, T04_n, T05_n, T06_n, T07_n, T08_n, T09_n, T10_n, T11_n, T12_n, SQ0_n, SQ1_n, SQ2_n, QC0_n, QC1_n, QC2_n, QC3_n, SQEXT, SQEXT_n, SQR10, SQR10_n, SQR12_n, STRTFC, WL16_n, WL15_n, WL14_n, WL13_n, WL12_n, WL11_n, WL10_n, WL09_n, WL08_n, WL07_n, WL06_n, WL05_n, WL04_n, WL03_n, WL02_n, WL01_n, OVF_n, UNF_n, SUMA16_n, SUMB16_n, EXST0_n, EXST1_n, ST1, ST2, RSTSTG, TMZ_n, TOV_n, TSGN_n, TSGU_n, TPZG_n, DVST, GEQZRO_n, TRSM, NDR100_n, INKL, L15_n, TL15, XT1_n, XB7_n, MTCSAI, MP0_n, MP1, MP3A, MP3_n, IC12, IC13, IC15, IC15_n, TS0_n, RSM3, RSM3_n, STORE1_n, n7XP14, T12USE_n, ST0_n, ST1_n, STD2, ST3_n, BR1, BR1_n, BR2, BR2_n, BRDIF_n, BR12B_n, BR1B2_n, BR1B2B, BR1B2B_n, DIVSTG, KRPT, INOUT, INOUT_n, DIV_n, DV1, DV1_n, DV1376, DV1376_n, DV376_n, DV3764, DV4, DV4_n, L16_n, PRINC, RAND0, READ0, ROR0, RUPT0, RUPT1, RXOR0, RXOR0_n, WAND0, WOR0, B15X, CI_n, R15, R1C_n, RA_n, RB_n, RB1_n, RB2, RC_n, RSC_n, RRPA, WCH_n, WG_n, WL_n, WY_n, n8PP4, n1XP10, n2XP3, n2XP5, n3XP2, n3XP7, n4XP5, n4XP11, n5XP4, n5XP11, n5XP28, n6XP5, n7XP19, n8XP5, n8XP6, n9XP1, MP0T10, MST1, MST2, MST3, MBR1, MBR2, MRSC, MWCH);
    input wire SIM_RST;
    input wire SIM_CLK;
    input wire p4VSW;
    input wire GND;
    output wire B15X;
    output wire BR1;
    output wire BR12B_n;
    output wire BR1B2B;
    output wire BR1B2B_n;
    output wire BR1B2_n;
    output wire BR1_n;
    output wire BR2;
    output wire BR2_n;
    output wire BRDIF_n;
    output wire CI_n; //FPGA#wand
    output wire DIVSTG;
    output wire DIV_n;
    output wire DV1;
    output wire DV1376;
    output wire DV1376_n;
    output wire DV1_n;
    output wire DV3764;
    output wire DV376_n;
    output wire DV4;
    output wire DV4_n;
    input wire DVST;
    input wire EXST0_n;
    input wire EXST1_n;
    input wire GEQZRO_n;
    input wire GOJAM;
    input wire IC12;
    input wire IC13;
    input wire IC15;
    input wire IC15_n;
    input wire INKL;
    output wire INOUT;
    output wire INOUT_n;
    output wire KRPT;
    input wire L15_n;
    output wire L16_n; //FPGA#wand
    output wire MBR1; //FPGA#wand
    output wire MBR2; //FPGA#wand
    output wire MP0T10;
    input wire MP0_n;
    input wire MP1;
    input wire MP3A;
    input wire MP3_n;
    output wire MRSC; //FPGA#wand
    output wire MST1; //FPGA#wand
    output wire MST2; //FPGA#wand
    output wire MST3; //FPGA#wand
    input wire MTCSAI;
    output wire MWCH; //FPGA#wand
    input wire NDR100_n;
    input wire OVF_n;
    input wire PHS2_n;
    input wire PHS3_n;
    input wire PHS4;
    input wire PHS4_n;
    output wire PRINC;
    input wire QC0_n;
    input wire QC1_n;
    input wire QC2_n;
    input wire QC3_n;
    output wire R15;
    output wire R1C_n; //FPGA#wand
    output wire RAND0;
    output wire RA_n; //FPGA#wand
    output wire RB1_n; //FPGA#wand
    output wire RB2;
    output wire RB_n; //FPGA#wand
    output wire RC_n; //FPGA#wand
    output wire READ0;
    output wire ROR0;
    output wire RRPA;
    output wire RSC_n;
    input wire RSM3;
    input wire RSM3_n;
    input wire RSTSTG;
    output wire RUPT0;
    output wire RUPT1;
    output wire RXOR0;
    output wire RXOR0_n;
    input wire SQ0_n;
    input wire SQ1_n;
    input wire SQ2_n;
    input wire SQEXT;
    input wire SQEXT_n;
    input wire SQR10;
    input wire SQR10_n;
    input wire SQR12_n;
    output wire ST0_n;
    input wire ST1;
    output wire ST1_n;
    input wire ST2;
    output wire ST3_n;
    output wire STD2;
    input wire STORE1_n;
    input wire STRTFC;
    input wire SUMA16_n;
    input wire SUMB16_n;
    input wire T01;
    input wire T01_n;
    input wire T02_n;
    input wire T03_n;
    input wire T04_n;
    input wire T05_n;
    input wire T06_n;
    input wire T07_n;
    input wire T08_n;
    input wire T09_n;
    input wire T10_n;
    input wire T11_n;
    output wire T12USE_n;
    input wire T12_n;
    output wire TL15;
    inout wire TMZ_n; //FPGA#wand
    input wire TOV_n;
    input wire TPZG_n;
    input wire TRSM;
    input wire TS0_n;
    inout wire TSGN_n; //FPGA#wand
    input wire TSGU_n;
    input wire UNF_n;
    output wire WAND0;
    output wire WCH_n;
    output wire WG_n; //FPGA#wand
    input wire WL01_n;
    input wire WL02_n;
    input wire WL03_n;
    input wire WL04_n;
    input wire WL05_n;
    input wire WL06_n;
    input wire WL07_n;
    input wire WL08_n;
    input wire WL09_n;
    input wire WL10_n;
    input wire WL11_n;
    input wire WL12_n;
    input wire WL13_n;
    input wire WL14_n;
    input wire WL15_n;
    input wire WL16_n;
    output wire WL_n; //FPGA#wand
    output wire WOR0;
    output wire WY_n; //FPGA#wand
    input wire XB7_n;
    input wire XT1_n;
    wire __A04_1__DV0;
    wire __A04_1__DV0_n;
    wire __A04_1__DV376;
    wire __A04_1__DVST_n;
    wire __A04_1__SGUM; //FPGA#wand
    wire __A04_1__ST1376_n;
    wire __A04_1__ST376;
    wire __A04_1__ST376_n;
    wire __A04_1__ST4_n;
    wire __A04_1__STG1;
    wire __A04_1__STG2;
    wire __A04_1__STG3;
    wire __A04_1__TRSM_n;
    wire __A04_1__TSGN2;
    wire __A04_2__BR12B;
    wire __A04_2__BR1B2;
    wire __A04_2__BRXP3;
    wire __A04_2__READ0_n;
    wire __A04_2__RUPT0_n;
    wire __A04_2__RUPT1_n;
    wire __A04_2__WOR0_n;
    wire __A04_2__WRITE0;
    wire __A04_2__WRITE0_n;
    wire __A04_NET_184;
    wire __A04_NET_185;
    wire __A04_NET_186;
    wire __A04_NET_187;
    wire __A04_NET_188;
    wire __A04_NET_189;
    wire __A04_NET_192;
    wire __A04_NET_193; //FPGA#wand
    wire __A04_NET_194;
    wire __A04_NET_195;
    wire __A04_NET_196;
    wire __A04_NET_197;
    wire __A04_NET_198;
    wire __A04_NET_199;
    wire __A04_NET_200;
    wire __A04_NET_201;
    wire __A04_NET_202;
    wire __A04_NET_203;
    wire __A04_NET_204; //FPGA#wand
    wire __A04_NET_205;
    wire __A04_NET_206;
    wire __A04_NET_207;
    wire __A04_NET_208; //FPGA#wand
    wire __A04_NET_209;
    wire __A04_NET_210;
    wire __A04_NET_211;
    wire __A04_NET_214;
    wire __A04_NET_215; //FPGA#wand
    wire __A04_NET_222;
    wire __A04_NET_223;
    wire __A04_NET_225;
    wire __A04_NET_226;
    wire __A04_NET_227;
    wire __A04_NET_230;
    wire __A04_NET_231;
    wire __A04_NET_232;
    wire __A04_NET_233;
    wire __A04_NET_234;
    wire __A04_NET_235;
    wire __A04_NET_236; //FPGA#wand
    wire __A04_NET_237;
    wire __A04_NET_238;
    wire __A04_NET_239;
    wire __A04_NET_241;
    wire __A04_NET_244;
    wire __A04_NET_245;
    wire __A04_NET_246;
    wire __A04_NET_247;
    wire __A04_NET_248;
    wire __A04_NET_249; //FPGA#wand
    wire __A04_NET_250;
    wire __A04_NET_251;
    wire __A04_NET_252;
    wire __A04_NET_253;
    wire __A04_NET_254;
    wire __A04_NET_255;
    wire __A04_NET_256;
    wire __A04_NET_257;
    wire __A04_NET_258;
    wire __A04_NET_259;
    wire __A04_NET_260;
    wire __A04_NET_261;
    wire __A04_NET_262;
    wire __A04_NET_263;
    wire __A04_NET_266;
    wire __A04_NET_269;
    wire __A04_NET_270;
    wire __A04_NET_271;
    wire __A04_NET_272;
    wire __A04_NET_273;
    wire __A04_NET_274;
    wire __A04_NET_275;
    wire __A04_NET_276;
    wire __A04_NET_277;
    wire __A04_NET_278;
    wire __A04_NET_279; //FPGA#wand
    wire __A04_NET_280;
    wire __A04_NET_281;
    wire __A04_NET_282;
    wire __A04_NET_283;
    wire __A04_NET_284;
    wire __A04_NET_285;
    wire __A04_NET_286;
    wire __A04_NET_287;
    wire __A04_NET_288;
    wire __A04_NET_289;
    wire __A04_NET_290;
    wire __A04_NET_291;
    wire __A04_NET_292;
    wire __A04_NET_293;
    wire __A04_NET_294;
    wire __A04_NET_295;
    wire __A04_NET_296;
    wire __A04_NET_297;
    wire __A04_NET_298;
    wire __A04_NET_299;
    wire __A04_NET_300;
    wire __A04_NET_301;
    wire __A04_NET_302;
    wire __A04_NET_303;
    wire __A04_NET_304;
    wire __A04_NET_305;
    wire __A04_NET_306;
    wire __A04_NET_307;
    wire __A04_NET_308;
    wire __A04_NET_309;
    wire __A04_NET_310;
    wire __A04_NET_311;
    wire __A04_NET_312;
    wire __A04_NET_313;
    wire __A04_NET_314;
    wire __A04_NET_315;
    wire __A04_NET_316;
    wire __A04_NET_319;
    wire __A04_NET_320;
    wire __A04_NET_321;
    wire __A04_NET_322;
    wire __A04_NET_323;
    wire __A04_NET_324;
    wire __A04_NET_325;
    wire __A04_NET_326;
    wire __A04_NET_327;
    wire __A04_NET_328;
    wire __A04_NET_329;
    wire __A04_NET_334;
    wire __A04_NET_335;
    wire __A04_NET_336;
    wire __A04_NET_337;
    output wire n1XP10;
    output wire n2XP3;
    output wire n2XP5;
    output wire n3XP2;
    output wire n3XP7;
    output wire n4XP11;
    output wire n4XP5;
    output wire n5XP11; //FPGA#wand
    output wire n5XP28;
    output wire n5XP4;
    output wire n6XP5;
    input wire n7XP14;
    output wire n7XP19;
    output wire n8PP4; //FPGA#wand
    output wire n8XP5;
    output wire n8XP6;
    output wire n9XP1;

    pullup R4001(__A04_NET_249);
    pullup R4002(__A04_NET_236);
    pullup R4003(__A04_1__SGUM);
    pullup R3004(__A04_NET_215);
    pullup R3005(__A04_NET_193);
    pullup R4006(__A04_NET_204);
    pullup R4007(__A04_NET_208);
    pullup R4008(n5XP11);
    pullup R4011(__A04_NET_279);
    pullup R4021(n8PP4);
    U74HC02 #(1'b0, 1'b0, 1'b0, 1'b1) U4001(T12USE_n, DVST, __A04_NET_245, DIVSTG, T12USE_n, T03_n, GND, __A04_NET_247, __A04_NET_246, __A04_NET_261, GOJAM, MTCSAI, __A04_NET_252, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b0) U4002(T03_n, T12USE_n, T12USE_n, RSTSTG, GOJAM, __A04_NET_245, GND, __A04_NET_246, PHS3_n, __A04_NET_245, T12_n, __A04_NET_247, PHS3_n, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U4003(__A04_NET_252, __A04_NET_249, __A04_NET_253, __A04_NET_249, __A04_NET_234, __A04_NET_236, GND, __A04_NET_236, __A04_NET_232, __A04_1__SGUM, __A04_NET_200, __A04_1__SGUM, __A04_NET_201, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 #(1'b1, 1'b1, 1'b0) U4004(ST1, __A04_NET_248, __A04_1__STG1, __A04_1__STG3, __A04_1__STG2, __A04_NET_235, GND, __A04_NET_256, __A04_1__STG2, __A04_1__STG3, __A04_NET_244, __A04_NET_253, __A04_NET_237, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4005(__A04_NET_237, __A04_NET_249, T01, __A04_NET_248, __A04_1__DVST_n, __A04_1__STG3, GND, __A04_NET_261, __A04_NET_249, __A04_NET_250, __A04_NET_237, __A04_NET_261, __A04_NET_251, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b1, 1'b0, 1'b1, 1'b0) U4006(__A04_NET_244, __A04_NET_250, __A04_1__STG1, __A04_1__STG1, __A04_NET_244, __A04_NET_251, GND, ST2, __A04_NET_241, __A04_NET_234, __A04_1__DVST_n, __A04_NET_244, __A04_NET_231, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 #(1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0) U4008(__A04_NET_235, ST0_n, __A04_NET_256, ST1_n, __A04_NET_266, ST3_n, GND, __A04_1__ST4_n, __A04_NET_258, __A04_1__ST376_n, __A04_1__ST376, DV1376_n, DV1376, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b1, 1'b0, 1'b0) U4009(__A04_NET_231, MTCSAI, __A04_NET_236, GOJAM, T01, __A04_NET_233, GND, __A04_NET_266, __A04_1__STG3, __A04_NET_257, __A04_NET_244, __A04_NET_232, __A04_NET_233, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U4010(__A04_NET_241, __A04_1__TRSM_n, XT1_n, XB7_n, NDR100_n,  , GND,  , __A04_NET_262, STRTFC, T01, RSTSTG, __A04_NET_263, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b1, 1'b0) U4011(__A04_NET_238, __A04_NET_261, __A04_NET_236, __A04_NET_239, __A04_NET_233, __A04_NET_261, GND, __A04_NET_238, __A04_1__STG2, __A04_NET_257, __A04_NET_257, __A04_NET_239, __A04_1__STG2, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U4012(__A04_NET_260, __A04_1__DVST_n, __A04_NET_257, __A04_NET_262, __A04_NET_260, __A04_NET_263, GND, __A04_NET_261, __A04_NET_262, __A04_NET_269, __A04_NET_263, __A04_NET_261, __A04_NET_270, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b1, 1'b0, 1'b0, 1'b0) U4013(__A04_NET_214, __A04_NET_269, __A04_1__STG3, __A04_1__STG3, __A04_NET_214, __A04_NET_270, GND, __A04_1__STG1, __A04_1__STG3, __A04_NET_254, __A04_NET_257, __A04_NET_254, __A04_1__ST376, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U4014(STD2, INKL, __A04_1__STG1, __A04_1__STG3, __A04_NET_257,  , GND,  , SQ0_n, EXST1_n, QC3_n, SQR10_n, RUPT1, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4015(__A04_NET_214, __A04_1__STG1, QC0_n, SQEXT_n, SQ1_n, __A04_NET_259, GND, __A04_NET_200, SUMB16_n, SUMA16_n, TSGU_n, __A04_NET_258, __A04_1__STG2, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4016(__A04_NET_255, __A04_NET_258, __A04_1__ST376, DV3764, DIV_n, __A04_NET_255, GND, __A04_NET_256, __A04_1__ST376, __A04_1__ST1376_n, DIV_n, __A04_1__ST1376_n, DV1376, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 U4017(__A04_NET_259, DIV_n, __A04_1__DV0, __A04_1__DV0_n, DV1, DV1_n, GND, DV376_n, __A04_1__DV376, __A04_NET_202, TL15, BR1, __A04_NET_215, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4018(__A04_1__DV0, DIV_n, ST0_n, DV1, DIV_n, ST1_n, GND, DIV_n, __A04_1__ST4_n, DV4, DIV_n, __A04_1__ST376_n, __A04_1__DV376, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4019(__A04_NET_192, SUMA16_n, SUMB16_n, __A04_NET_201, PHS4, PHS3_n, GND, UNF_n, TOV_n, __A04_NET_196, L15_n, __A04_NET_202, __A04_NET_197, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b0, 1'b1) U4020(PHS4_n, WL16_n, __A04_NET_197, __A04_NET_186, __A04_NET_193, __A04_NET_185, GND, __A04_NET_184, __A04_NET_215, __A04_NET_198, __A04_NET_199, __A04_NET_186, TSGN_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4021(__A04_NET_198, TSGN_n, PHS3_n, __A04_NET_199, __A04_NET_202, PHS3_n, GND, TOV_n, PHS2_n, __A04_NET_205, __A04_1__SGUM, __A04_NET_196, __A04_NET_187, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U4022(__A04_NET_189, __A04_NET_192, PHS3_n, TSGU_n, PHS4,  , GND,  , WL16_n, WL15_n, WL14_n, WL13_n, __A04_NET_226, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U4023(__A04_NET_187, __A04_NET_215, __A04_NET_185, __A04_NET_215, __A04_NET_184, __A04_NET_193, GND, __A04_NET_193, __A04_NET_188, __A04_NET_204, __A04_NET_226, __A04_NET_204, __A04_NET_227, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 #(1'b1, 1'b0, 1'b0, 1'b0) U4024(__A04_NET_188, __A04_NET_205, __A04_NET_189, __A04_NET_195, TOV_n, OVF_n, GND, __A04_NET_230, PHS3_n, __A04_NET_207, TMZ_n, PHS4_n, __A04_NET_225, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 U4025(__A04_NET_193, BR1_n, __A04_1__TSGN2, __A04_NET_230, __A04_NET_208, BR2, GND, BR2_n, __A04_NET_209, DV4_n, DV4, __A04_NET_281, __A04_NET_315, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4026(GEQZRO_n, PHS4_n, WL16_n, PHS4_n, __A04_NET_230, __A04_NET_203, GND, __A04_NET_211, __A04_NET_203, __A04_NET_204, __A04_NET_209, __A04_NET_194, TPZG_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U4027(__A04_NET_227, WL12_n, WL11_n, WL10_n, WL09_n,  , GND,  , WL08_n, WL07_n, WL06_n, WL05_n, __A04_NET_222, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 #(1'b0, 1'b1) U4028(__A04_NET_223, WL04_n, WL03_n, WL02_n, WL01_n,  , GND,  , __A04_NET_208, __A04_NET_207, __A04_NET_206, __A04_NET_205, __A04_NET_209, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U4029(__A04_NET_222, __A04_NET_204, __A04_NET_223, __A04_NET_204, __A04_NET_225, __A04_NET_204, GND, __A04_NET_208, __A04_NET_210, __A04_NET_208, __A04_NET_211,  ,  , p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10
    U74HC02 U4030(__A04_NET_206, TMZ_n, PHS3_n, __A04_NET_210, __A04_NET_194, __A04_NET_195, GND, SQ0_n, EXST0_n, __A04_NET_315, QC3_n, SQEXT, __A04_NET_280, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4031(__A04_NET_281, SQR10, QC0_n, __A04_NET_281, SQR10_n, __A04_2__WRITE0, GND, RAND0, SQR10, __A04_NET_281, QC1_n, READ0, QC0_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 U4032(READ0, __A04_2__READ0_n, __A04_2__WRITE0, __A04_2__WRITE0_n, WOR0, __A04_2__WOR0_n, GND, RXOR0_n, RXOR0, __A04_2__RUPT0_n, RUPT0, __A04_2__RUPT1_n, RUPT1, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4033(QC1_n, SQR10_n, SQR10, __A04_NET_281, QC2_n, ROR0, GND, WOR0, QC2_n, __A04_NET_281, SQR10_n, WAND0, __A04_NET_281, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4034(SQR10, __A04_NET_281, QC3_n, __A04_NET_281, SQR10_n, RUPT0, GND, __A04_NET_296, ST0_n, SQR12_n, SQ2_n, RXOR0, QC3_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 U4035(__A04_NET_296, __A04_NET_287, INOUT, INOUT_n, __A04_NET_279, __A04_NET_306, GND, BR1B2_n, __A04_2__BR1B2, BR12B_n, __A04_2__BR12B, BR1B2B_n, BR1B2B, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4036(PRINC, __A04_NET_280, __A04_NET_287, RRPA, T03_n, __A04_2__RUPT1_n, GND, T03_n, RXOR0_n, n3XP7, __A04_NET_286, T03_n, __A04_NET_283, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4037(EXST0_n, SQ0_n, INOUT, DV4, PRINC, __A04_NET_319, GND, __A04_NET_316, __A04_NET_283, __A04_NET_285, __A04_NET_275, INOUT, RUPT0, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4038(__A04_NET_286, ROR0, WOR0, __A04_NET_282, T03_n, __A04_NET_284, GND, RAND0, WAND0, __A04_NET_284, DV4_n, T05_n, n5XP28, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U4039(__A04_NET_316, RB_n, __A04_NET_310, RC_n, __A04_NET_309, n5XP11, GND, n5XP11, __A04_NET_308, RA_n, __A04_NET_307, WG_n, __A04_NET_314, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 #(1'b0, 1'b0, 1'b1) U4040(__A04_NET_282, __A04_NET_277, T05_n, INOUT_n, READ0, __A04_NET_309, GND, WCH_n, __A04_NET_276, n7XP14, __A04_NET_278, __A04_NET_310, __A04_NET_272, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4041(__A04_NET_308, __A04_2__WRITE0, RXOR0, __A04_NET_285, __A04_2__READ0_n, T05_n, GND, __A04_2__WRITE0_n, T05_n, __A04_NET_276, T05_n, __A04_2__WOR0_n, __A04_NET_278, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4042(__A04_NET_277, T05_n, RXOR0_n, __A04_NET_271, T02_n, __A04_2__WRITE0_n, GND, T02_n, INOUT_n, n2XP3, T09_n, __A04_2__RUPT0_n, n9XP1, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4043(__A04_NET_276, __A04_NET_277, RUPT1, IC13, IC12, __A04_NET_273, GND, __A04_NET_314, n9XP1, __A04_NET_272, __A04_NET_275, __A04_NET_307, n2XP3, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4044(__A04_NET_272, T09_n, RXOR0_n, __A04_NET_275, T09_n, __A04_NET_273, GND, __A04_NET_277, __A04_NET_271, __A04_NET_313, T01_n, __A04_2__RUPT1_n, RB2, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U4045(__A04_NET_313, WG_n, __A04_NET_311, __A04_NET_279, __A04_NET_312, __A04_NET_279, GND, RA_n, __A04_NET_327, WG_n, __A04_NET_329, TMZ_n, __A04_NET_328, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 U4046(RUPT0, RUPT1, INOUT, MP1, MP3A, __A04_NET_311, GND, __A04_NET_312, __A04_1__DV0, IC15, DV1376, __A04_NET_274, RSM3, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4047(R15, __A04_NET_274, T01_n, n1XP10, T01_n, __A04_1__DV0_n, GND, MP0_n, T03_n, __A04_NET_299, INOUT_n, T03_n, __A04_NET_288, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4048(T02_n, __A04_1__DV0_n, BRDIF_n, TS0_n, T04_n, __A04_NET_297, GND, __A04_NET_298, T04_n, BR1, MP0_n, n2XP5, BR1, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4049(n3XP2, T03_n, TS0_n, __A04_2__BR1B2, BR1, BR2_n, GND, BR1_n, BR2, __A04_2__BR12B, __A04_2__BR1B2, __A04_2__BR12B, BRDIF_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4050(BR1B2B, BR2, BR1, n4XP5, TS0_n, T04_n, GND, T04_n, INOUT_n, n4XP11, T04_n, MP3_n, __A04_NET_294, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4051(MP0_n, BR1_n, DV1_n, T04_n, BR2_n, __A04_NET_300, GND, __A04_NET_305, TS0_n, T05_n, BR1B2_n, __A04_NET_290, T04_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4052(T05_n, TS0_n, T07_n, BR1_n, MP3_n, n7XP19, GND, n8XP6, T08_n, DV1_n, BR2, __A04_NET_303, BR12B_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4053(B15X, T05_n, DV1_n, n5XP4, T05_n, RSM3_n, GND, T06_n, DV1_n, n6XP5, T06_n, MP3_n, TL15, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4054(__A04_1__TSGN2, T07_n, MP0_n, __A04_NET_301, T07_n, DV1_n, GND, T08_n, DV1_n, n8XP5, T09_n, MP3_n, __A04_NET_292, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4055(T09_n, BR1, T09_n, MP0_n, BR1_n, __A04_NET_289, GND, __A04_NET_302, MP0_n, T09_n, BRDIF_n, __A04_NET_293, MP0_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4056(KRPT, T09_n, __A04_2__RUPT1_n, MP0T10, T10_n, MP0_n, GND, __A04_NET_306, T02_n, __A04_NET_295, STORE1_n, T09_n, __A04_NET_291, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4057(BR1_n, MP0_n, n1XP10, n8XP5, __A04_NET_292, __A04_NET_327, GND, __A04_NET_337, __A04_NET_300, __A04_NET_299, __A04_NET_301, __A04_NET_304, T11_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 #(1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0) U4058(DVST, __A04_1__DVST_n, __A04_NET_304, __A04_NET_336, TRSM, __A04_1__TRSM_n, GND,  ,  ,  ,  ,  ,  , p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b1) U4059( ,  , __A04_NET_288, B15X, n7XP19, __A04_NET_323, GND, __A04_NET_322, n8XP5, __A04_NET_293, __A04_NET_289,  ,  , p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4060(__A04_NET_328, n2XP5, n1XP10, __A04_NET_324, __A04_NET_297, __A04_NET_302, GND, n1XP10, MP0T10, __A04_NET_325, __A04_NET_305, __A04_NET_304, __A04_NET_335, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U4061(__A04_NET_323, WY_n, __A04_NET_322, WY_n, __A04_NET_320, WL_n, GND, RC_n, __A04_NET_321, RB_n, __A04_NET_326, CI_n, __A04_NET_324, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 #(1'b1, 1'b0, 1'b0) U4062(__A04_NET_298, __A04_NET_290, __A04_NET_290, n2XP5, __A04_NET_289, __A04_NET_321, GND, __A04_NET_326, __A04_NET_298, n7XP19, __A04_NET_293, __A04_NET_320, n6XP5, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U4063(__A04_NET_325, TSGN_n, __A04_NET_337, TSGN_n, __A04_NET_335, RB1_n, GND, L16_n, __A04_NET_336, R1C_n, __A04_NET_334, n8PP4, __A04_NET_319, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 U4064(__A04_NET_334, __A04_NET_304, __A04_NET_303, __A04_2__BRXP3, T03_n, IC15_n, GND,  ,  ,  ,  ,  ,  , p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U4065(RSC_n, __A04_NET_295, __A04_NET_294, __A04_NET_301, __A04_2__BRXP3,  , GND,  , __A04_NET_295, __A04_NET_291, __A04_NET_294, __A04_2__BRXP3, __A04_NET_329, p4VSW, SIM_RST, SIM_CLK);
    U74LVC06 U4066(__A04_NET_244, MST1, __A04_NET_257, MST2, __A04_NET_214, MST3, GND, MBR1, __A04_NET_215, MBR2, __A04_NET_208, MWCH, WCH_n, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74LVC06 U4067(RSC_n, MRSC,  ,  ,  ,  , GND,  ,  ,  ,  ,  ,  , p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2
endmodule