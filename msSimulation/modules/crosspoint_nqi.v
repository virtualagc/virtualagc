`timescale 1ns/1ps
`default_nettype none

module crosspoint_nqi(SIM_RST, SIM_CLK, p4VSW, GND, GOJAM, T01, T01_n, T02_n, T03_n, T04_n, T05_n, T06_n, T07_n, T08_n, T09_n, T10_n, T11_n, T12_n, T12USE_n, STD2, BR1, BR1_n, BR2, BR2_n, BR12B_n, BR1B2_n, BRDIF_n, S11, S12, INKL_n, MONpCH, MONWBK, ADS0, CCS0, CCS0_n, CHINC_n, DAS0, DAS0_n, DAS1, DAS1_n, DV1, DV1_n, DV4, DV4_n, DIV_n, DXCH0, FETCH0, FETCH0_n, GOJ1, GOJ1_n, INOUT, INOUT_n, MASK0, MASK0_n, MP0, MP3, MP3_n, MSU0, MSU0_n, NDX0_n, PRINC, QXCH0_n, RAND0, READ0, ROR0, RSM3, IC15_n, IC16, RSM3_n, RUPT0, RXOR0, RXOR0_n, SHANC_n, SHIFT, SHIFT_n, STFET1_n, TC0, TC0_n, TCF0, TCSAJ3_n, TS0, TS0_n, WAND0, WOR0, IC1, IC2, IC2_n, IC3, IC4, IC5, IC5_n, IC8_n, IC9, IC10, IC10_n, IC11_n, IC12, IC12_n, IC13, IC14, IC16_n, XT0_n, XT2_n, XT3_n, XT4_n, XT5_n, XT6_n, YB0_n, YT0_n, n4XP5, n5XP11, A2X_n, CI_n, DVST, MONEX_n, NDR100_n, NISQ, NISQ_n, PTWOX, R6, RA_n, RAD, RB_n, RC_n, RG_n, RL_n, RL10BB, RQ_n, RSTRT, RSTSTG, RU_n, RZ_n, SCAD, SCAD_n, ST2_n, TMZ_n, TOV_n, TPZG_n, TSGN_n, TSUDO_n, U2BBK, WA_n, WB_n, WG_n, WL_n, WS_n, WY_n, WY12_n, WYD_n, WZ_n, Z15_n, Z16_n, DV4B1B, GNHNC, TRSM, RSCT, OCTAD2, OCTAD3, OCTAD4, OCTAD5, OCTAD6, n2XP7, n2XP8, n3XP6, n5XP12, n5XP15, n5XP21, n6XP8, n7XP4, n7XP9, n9XP5, n10XP1, n10XP8, n11XP2, MNISQ);
    input wire SIM_RST;
    input wire SIM_CLK;
    input wire p4VSW;
    input wire GND;
    output wire A2X_n; //FPGA#wand
    input wire ADS0;
    input wire BR1;
    input wire BR12B_n;
    input wire BR1B2_n;
    input wire BR1_n;
    input wire BR2;
    input wire BR2_n;
    input wire BRDIF_n;
    input wire CCS0;
    input wire CCS0_n;
    input wire CHINC_n;
    output wire CI_n; //FPGA#wand
    input wire DAS0;
    input wire DAS0_n;
    input wire DAS1;
    input wire DAS1_n;
    input wire DIV_n;
    input wire DV1;
    input wire DV1_n;
    input wire DV4;
    output wire DV4B1B;
    input wire DV4_n;
    output wire DVST;
    input wire DXCH0;
    input wire FETCH0;
    input wire FETCH0_n;
    output wire GNHNC;
    input wire GOJ1;
    input wire GOJ1_n;
    input wire GOJAM;
    input wire IC1;
    input wire IC10;
    input wire IC10_n;
    input wire IC11_n;
    input wire IC12;
    input wire IC12_n;
    input wire IC13;
    input wire IC14;
    input wire IC15_n;
    input wire IC16;
    input wire IC16_n;
    input wire IC2;
    input wire IC2_n;
    input wire IC3;
    input wire IC4;
    input wire IC5;
    input wire IC5_n;
    input wire IC8_n;
    input wire IC9;
    input wire INKL_n;
    input wire INOUT;
    input wire INOUT_n;
    input wire MASK0;
    input wire MASK0_n;
    output wire MNISQ; //FPGA#wand
    output wire MONEX_n; //FPGA#wand
    input wire MONWBK;
    input wire MONpCH;
    input wire MP0;
    input wire MP3;
    input wire MP3_n;
    input wire MSU0;
    input wire MSU0_n;
    output wire NDR100_n;
    input wire NDX0_n;
    output wire NISQ;
    output wire NISQ_n;
    output wire OCTAD2;
    output wire OCTAD3;
    output wire OCTAD4;
    output wire OCTAD5;
    output wire OCTAD6;
    input wire PRINC;
    output wire PTWOX;
    input wire QXCH0_n;
    output wire R6;
    output wire RAD;
    input wire RAND0;
    output wire RA_n; //FPGA#wand
    output wire RB_n; //FPGA#wand
    output wire RC_n; //FPGA#wand
    input wire READ0;
    output wire RG_n; //FPGA#wand
    output wire RL10BB;
    output wire RL_n; //FPGA#wand
    input wire ROR0;
    output wire RQ_n;
    output wire RSCT;
    input wire RSM3;
    input wire RSM3_n;
    output wire RSTRT;
    output wire RSTSTG;
    input wire RUPT0;
    output wire RU_n; //FPGA#wand
    input wire RXOR0;
    input wire RXOR0_n;
    output wire RZ_n; //FPGA#wand
    input wire S11;
    input wire S12;
    inout wire SCAD; //FPGA#wand
    output wire SCAD_n;
    input wire SHANC_n;
    input wire SHIFT;
    input wire SHIFT_n;
    output wire ST2_n; //FPGA#wand
    input wire STD2;
    input wire STFET1_n;
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
    input wire T12USE_n;
    input wire T12_n;
    input wire TC0;
    input wire TC0_n;
    input wire TCF0;
    input wire TCSAJ3_n;
    output wire TMZ_n; //FPGA#wand
    output wire TOV_n; //FPGA#wand
    output wire TPZG_n;
    output wire TRSM;
    input wire TS0;
    input wire TS0_n;
    output wire TSGN_n; //FPGA#wand
    output wire TSUDO_n;
    output wire U2BBK;
    input wire WAND0;
    output wire WA_n; //FPGA#wand
    output wire WB_n; //FPGA#wand
    output wire WG_n; //FPGA#wand
    output wire WL_n; //FPGA#wand
    input wire WOR0;
    output wire WS_n; //FPGA#wand
    output wire WY12_n; //FPGA#wand
    output wire WYD_n; //FPGA#wand
    output wire WY_n; //FPGA#wand
    output wire WZ_n; //FPGA#wand
    input wire XT0_n;
    input wire XT2_n;
    input wire XT3_n;
    input wire XT4_n;
    input wire XT5_n;
    input wire XT6_n;
    input wire YB0_n;
    input wire YT0_n;
    output wire Z15_n; //FPGA#wand
    output wire Z16_n; //FPGA#wand
    wire __A05_1__10XP6;
    wire __A05_1__10XP7;
    wire __A05_1__3XP5;
    wire __A05_1__8XP12;
    wire __A05_1__8XP15;
    wire __A05_1__8XP3;
    wire __A05_1__DV1B1B;
    wire __A05_1__PARTC;
    wire __A05_2__10XP10;
    wire __A05_2__11XP6;
    wire __A05_2__5XP13;
    wire __A05_2__5XP19;
    wire __A05_2__5XP9;
    wire __A05_2__6XP2;
    wire __A05_2__6XP7;
    wire __A05_NET_177;
    wire __A05_NET_178;
    wire __A05_NET_179;
    wire __A05_NET_181;
    wire __A05_NET_182;
    wire __A05_NET_183;
    wire __A05_NET_184;
    wire __A05_NET_185;
    wire __A05_NET_186;
    wire __A05_NET_187;
    wire __A05_NET_188;
    wire __A05_NET_189;
    wire __A05_NET_190;
    wire __A05_NET_191;
    wire __A05_NET_192;
    wire __A05_NET_193;
    wire __A05_NET_194;
    wire __A05_NET_196;
    wire __A05_NET_198;
    wire __A05_NET_199;
    wire __A05_NET_203;
    wire __A05_NET_204;
    wire __A05_NET_205;
    wire __A05_NET_206;
    wire __A05_NET_208;
    wire __A05_NET_209;
    wire __A05_NET_210;
    wire __A05_NET_211;
    wire __A05_NET_212;
    wire __A05_NET_213;
    wire __A05_NET_214;
    wire __A05_NET_215;
    wire __A05_NET_216;
    wire __A05_NET_217;
    wire __A05_NET_218;
    wire __A05_NET_219;
    wire __A05_NET_220;
    wire __A05_NET_221;
    wire __A05_NET_222;
    wire __A05_NET_223;
    wire __A05_NET_224;
    wire __A05_NET_225;
    wire __A05_NET_226;
    wire __A05_NET_227;
    wire __A05_NET_228;
    wire __A05_NET_229;
    wire __A05_NET_230;
    wire __A05_NET_231;
    wire __A05_NET_232;
    wire __A05_NET_233;
    wire __A05_NET_234;
    wire __A05_NET_235;
    wire __A05_NET_236;
    wire __A05_NET_237;
    wire __A05_NET_238;
    wire __A05_NET_239;
    wire __A05_NET_240;
    wire __A05_NET_243;
    wire __A05_NET_244;
    wire __A05_NET_245;
    wire __A05_NET_246;
    wire __A05_NET_247;
    wire __A05_NET_248;
    wire __A05_NET_249;
    wire __A05_NET_250;
    wire __A05_NET_251;
    wire __A05_NET_252;
    wire __A05_NET_253;
    wire __A05_NET_254;
    wire __A05_NET_255;
    wire __A05_NET_256;
    wire __A05_NET_257;
    wire __A05_NET_258;
    wire __A05_NET_259;
    wire __A05_NET_260; //FPGA#wand
    wire __A05_NET_261;
    wire __A05_NET_262;
    wire __A05_NET_263;
    wire __A05_NET_264;
    wire __A05_NET_265;
    wire __A05_NET_266;
    wire __A05_NET_267; //FPGA#wand
    wire __A05_NET_268;
    wire __A05_NET_269;
    wire __A05_NET_270;
    wire __A05_NET_271;
    wire __A05_NET_272;
    wire __A05_NET_273;
    wire __A05_NET_276;
    wire __A05_NET_277;
    wire __A05_NET_279;
    wire __A05_NET_280;
    wire __A05_NET_281;
    wire __A05_NET_282; //FPGA#wand
    wire __A05_NET_283;
    wire __A05_NET_284;
    wire __A05_NET_285; //FPGA#wand
    wire __A05_NET_286;
    wire __A05_NET_287;
    wire __A05_NET_288;
    wire __A05_NET_289;
    wire __A05_NET_291;
    wire __A05_NET_292;
    wire __A05_NET_293;
    wire __A05_NET_294;
    wire __A05_NET_296;
    wire __A05_NET_297;
    wire __A05_NET_298;
    wire __A05_NET_299;
    wire __A05_NET_300;
    wire __A05_NET_301;
    wire __A05_NET_302;
    wire __A05_NET_303;
    wire __A05_NET_305;
    wire __A05_NET_306;
    wire __A05_NET_307;
    wire __A05_NET_308;
    wire __A05_NET_309;
    wire __A05_NET_310;
    wire __A05_NET_313;
    wire __A05_NET_314;
    wire __A05_NET_315;
    wire __A05_NET_316;
    wire __A05_NET_317;
    wire __A05_NET_318;
    wire __A05_NET_319;
    wire __A05_NET_320;
    wire __A05_NET_323;
    wire __A05_NET_324;
    wire __A05_NET_325;
    wire __A05_NET_326;
    wire __A05_NET_327;
    wire __A05_NET_328;
    wire __A05_NET_330;
    wire __A05_NET_331;
    wire __A05_NET_333;
    wire __A05_NET_334;
    wire __A05_NET_335;
    wire __A05_NET_338;
    wire __A05_NET_339;
    wire __A05_NET_340;
    wire __A05_NET_341;
    wire __A05_NET_342;
    wire __A05_NET_343;
    wire __A05_NET_344;
    wire __A05_NET_345;
    wire __A05_NET_346;
    wire __A05_NET_348;
    wire __A05_NET_349;
    wire __A05_NET_350;
    wire __A05_NET_351;
    wire __A05_NET_352;
    output wire n10XP1;
    output wire n10XP8;
    output wire n11XP2;
    output wire n2XP7;
    output wire n2XP8;
    output wire n3XP6;
    input wire n4XP5;
    input wire n5XP11;
    output wire n5XP12;
    output wire n5XP15;
    output wire n5XP21;
    output wire n6XP8;
    output wire n7XP4;
    output wire n7XP9;
    output wire n9XP5;

    pullup R5002(__A05_NET_282);
    pullup R5003(__A05_NET_285);
    pullup R5004(RL_n);
    pullup R5005(RA_n);
    pullup R5006(WY_n);
    pullup R5007(WY12_n);
    pullup R5008(SCAD);
    pullup R5009(__A05_NET_260);
    pullup R5010(__A05_NET_267);
    pullup R5011(TMZ_n);
    pullup R5012(TSGN_n);
    U74HC27 U5001(IC10, IC3, TC0, TCF0, IC4, __A05_NET_217, GND, __A05_NET_215, IC2, IC3, RSM3, __A05_NET_212, IC2, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5002(__A05_NET_211, STD2, IC2, __A05_NET_198, T01_n, __A05_NET_212, GND, T01_n, __A05_NET_211, __A05_NET_213, IC10_n, T01_n, __A05_NET_219, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5003(__A05_NET_218, T01_n, __A05_NET_217, __A05_NET_216, T02_n, __A05_NET_215, GND, T08_n, CCS0_n, __A05_NET_254, T02_n, MP3_n, n2XP7, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b0) U5004(T02_n, STD2, __A05_1__10XP6, __A05_1__10XP7, __A05_NET_219, __A05_NET_214, GND, __A05_NET_209, __A05_NET_213, n3XP6, __A05_NET_188, DVST, DIV_n, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5005(__A05_NET_214, MONEX_n, __A05_NET_209, RZ_n, __A05_NET_203, RB_n, GND, RA_n, __A05_NET_210, WA_n, __A05_NET_208, RL_n, __A05_NET_220, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 U5006(__A05_NET_216, __A05_1__8XP15, __A05_NET_181, __A05_NET_183, __A05_1__8XP12, __A05_NET_220, GND, __A05_1__PARTC, INKL_n, SHIFT, MONpCH, NISQ_n, n2XP7, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5007(__A05_1__3XP5, T03_n, IC2_n, __A05_NET_206, T01_n, IC15_n, GND, __A05_NET_206, __A05_NET_185, __A05_NET_210, T03_n, TC0_n, n3XP6, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5008(__A05_NET_185, T04_n, IC2_n, __A05_NET_184, T02_n, IC15_n, GND, __A05_NET_184, __A05_NET_186, TPZG_n, T04_n, DAS0_n, __A05_NET_181, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b1, 1'b0, 1'b0, 1'b0) U5009(__A05_NET_208, __A05_NET_181, __A05_NET_182, __A05_NET_182, T04_n, MASK0_n, GND, MP3_n, T10_n, __A05_NET_183, T05_n, IC2_n, __A05_NET_188, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5010(__A05_NET_186, T05_n, __A05_NET_187, __A05_NET_221, __A05_NET_206, __A05_NET_186, GND, T05_n, DAS0_n, n5XP12, T06_n, RSM3_n, __A05_NET_205, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U5011(__A05_1__PARTC, PRINC, __A05_NET_186, __A05_NET_206, n7XP9, __A05_NET_178, GND, __A05_NET_177, n9XP5, __A05_NET_206, __A05_NET_205, __A05_NET_187, CCS0, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5012(__A05_NET_221, TMZ_n, __A05_NET_177, WG_n, __A05_NET_179, RG_n, GND, RC_n, __A05_NET_204, A2X_n, __A05_NET_193, WY_n, __A05_NET_189, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 U5013(__A05_NET_191, T06_n, DAS0_n, __A05_NET_190, T06_n, MSU0_n, GND, __A05_NET_182, __A05_NET_190, __A05_NET_204, T07_n, DAS0_n, __A05_NET_199, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b1) U5014(__A05_NET_186, __A05_NET_192, __A05_NET_192, __A05_NET_191, __A05_NET_190, __A05_NET_193, GND, __A05_NET_189, __A05_NET_192, __A05_NET_190, __A05_NET_191, __A05_NET_179, __A05_NET_191, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U5015(__A05_NET_203, __A05_NET_218, __A05_1__3XP5, __A05_NET_199, __A05_NET_205,  , GND,  , IC3, RSM3, MP3, IC16, TSUDO_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5016(n7XP9, T07_n, MSU0_n, __A05_NET_192, T07_n, IC2_n, GND, T07_n, CCS0_n, __A05_NET_248, __A05_NET_243, __A05_NET_235, __A05_NET_240, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b0, 1'b1) U5017(__A05_NET_190, __A05_NET_198, __A05_1__8XP3, __A05_NET_248, n4XP5, __A05_NET_194, GND, __A05_NET_249, n4XP5, __A05_NET_248, __A05_NET_198, __A05_NET_196, __A05_1__10XP6, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5018(__A05_NET_196, CI_n, __A05_NET_194, RZ_n, __A05_NET_249, WY12_n, GND, WZ_n, __A05_NET_244, RB_n, __A05_NET_240, WB_n, __A05_NET_246, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 #(1'b0, 1'b0, 1'b1) U5019(CCS0_n, T07_n, BR1_n, CCS0_n, T07_n, PTWOX, GND, __A05_NET_244, __A05_1__3XP5, __A05_NET_250, __A05_NET_254, n7XP4, BR2_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U5020(INKL_n, FETCH0, __A05_NET_254, __A05_NET_252, n9XP5, __A05_NET_253, GND, __A05_NET_256, IC2, IC4, DXCH0, __A05_NET_243, T08_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U5021(RAD, TSUDO_n, T08_n, __A05_NET_246, RAD, __A05_NET_247, GND, T08_n, __A05_NET_245, __A05_1__8XP15, T08_n, __A05_NET_255, __A05_1__8XP3, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 U5022(IC16, __A05_NET_245, __A05_NET_350, RQ_n, MP3, __A05_NET_316, GND, SCAD_n, SCAD, NDR100_n, __A05_NET_296, __A05_NET_261, __A05_NET_262, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5023(__A05_NET_255, MP0, IC1, __A05_NET_252, T08_n, __A05_NET_256, GND, T08_n, __A05_NET_257, __A05_NET_247, T08_n, GOJ1_n, RSTRT, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5024(__A05_NET_253, RU_n, __A05_NET_231, RA_n, __A05_NET_230, ST2_n, GND, WY_n, __A05_NET_224, RC_n, __A05_NET_239, WA_n, __A05_NET_234, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 U5025(DXCH0, GOJ1, CCS0_n, BR2, T10_n, __A05_1__10XP6, GND, __A05_NET_226, IC1, IC10, RUPT0, __A05_NET_257, DAS0, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5026(__A05_1__8XP12, T08_n, DAS0_n, __A05_NET_250, T08_n, TCSAJ3_n, GND, T09_n, __A05_NET_251, __A05_NET_235, IC2, __A05_1__DV1B1B, __A05_NET_251, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5027(n9XP5, T09_n, DAS0_n, __A05_NET_222, T09_n, MASK0_n, GND, __A05_NET_222, __A05_NET_223, __A05_NET_231, T10_n, CCS0_n, __A05_NET_232, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5028(__A05_NET_230, __A05_NET_250, __A05_NET_232, n10XP1, __A05_NET_226, T10_n, GND, T10_n, __A05_NET_225, __A05_NET_223, DAS0, __A05_NET_227, __A05_NET_225, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b1, 1'b0, 1'b1) U5029(__A05_NET_232, __A05_NET_222, T10_n, DAS0_n, BR1B2_n, n10XP8, GND, __A05_NET_234, __A05_NET_235, __A05_NET_236, n5XP11, __A05_NET_224, __A05_NET_223, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5030(__A05_NET_227, MSU0_n, BR1_n, __A05_1__10XP7, T10_n, __A05_NET_228, GND, __A05_NET_227, __A05_NET_229, __A05_NET_228, BR12B_n, DAS0_n, __A05_NET_229, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5031(n11XP2, T11_n, MSU0_n, __A05_NET_237, T11_n, MASK0_n, GND, __A05_NET_222, __A05_NET_237, __A05_NET_239, T11_n, __A05_NET_238, __A05_NET_236, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5032(__A05_NET_238, MSU0, IC14, __A05_NET_293, T10_n, __A05_NET_339, GND, GOJAM, GNHNC, __A05_NET_233, __A05_NET_233, T01, GNHNC, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b1, 1'b0, 1'b1) U5033(__A05_NET_307, __A05_NET_351, IC12, DAS0, DAS1, __A05_NET_308, GND, __A05_NET_310, RL10BB, __A05_NET_283, RSCT, __A05_NET_301, __A05_2__6XP2, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5034( ,  ,  ,  ,  ,  , GND, __A05_NET_282, __A05_NET_308, __A05_NET_282, __A05_NET_309, WS_n, __A05_NET_310, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:8,10,12
    U74HC02 U5035(__A05_2__10XP10, T10_n, IC11_n, __A05_NET_345, T10_n, __A05_NET_346, GND, T01_n, __A05_NET_282, RL10BB, T01_n, FETCH0_n, R6, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U5036(__A05_NET_309, IC9, DXCH0, PRINC, INOUT,  , GND,  , YB0_n, YT0_n, S12, S11, __A05_NET_296, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5037(__A05_NET_283, T01_n, CHINC_n, __A05_NET_349, T03_n, __A05_NET_285, GND, IC5, MP0, __A05_NET_299, T03_n, IC8_n, __A05_NET_284, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b0, 1'b1) U5038(T01_n, MONpCH, TS0, DAS0, MASK0, __A05_NET_302, GND, __A05_NET_300, __A05_NET_349, __A05_NET_284, __A05_NET_350, RSCT, INKL_n, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5039(__A05_NET_300, WB_n, __A05_NET_301, WB_n, __A05_NET_302, __A05_NET_285, GND, __A05_NET_285, __A05_NET_299, RL_n, __A05_NET_298, RA_n, __A05_NET_303, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 U5040(n2XP8, T02_n, FETCH0_n, __A05_NET_350, T03_n, QXCH0_n, GND, T04_n, DV1_n, __A05_NET_305, T04_n, __A05_NET_306, __A05_NET_307, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U5041(__A05_NET_284, __A05_NET_305, DV1, INOUT, IC2, __A05_NET_306, GND, __A05_NET_327, __A05_NET_351, __A05_NET_348, __A05_2__5XP9, __A05_NET_298, __A05_2__11XP6, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5042(__A05_NET_303, __A05_NET_349, __A05_2__6XP2, TRSM, T05_n, NDX0_n, GND, IC12_n, T05_n, __A05_NET_351, DAS1_n, T05_n, __A05_NET_348, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b0, 1'b1) U5043(__A05_2__5XP13, n5XP15, DAS1, PRINC, __A05_1__PARTC, __A05_NET_325, GND, __A05_NET_326, __A05_NET_328, n2XP8, __A05_2__10XP10, __A05_NET_324, __A05_NET_318, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5044(__A05_NET_327, RG_n, __A05_NET_324, RG_n, __A05_NET_326, WY_n, GND, A2X_n, __A05_NET_333, CI_n, __A05_NET_330, WY12_n, __A05_NET_313, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U5045(__A05_NET_328, __A05_NET_325, T05_n, __A05_NET_333, __A05_NET_348, __A05_2__10XP10, GND, SHIFT_n, T05_n, __A05_2__5XP9, SHANC_n, T05_n, __A05_NET_331, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U5046(__A05_NET_331, __A05_NET_314, YT0_n, YB0_n, XT0_n, __A05_NET_319, GND, __A05_NET_279, RAND0, WAND0, __A05_NET_262, __A05_NET_330, __A05_NET_315, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5047(__A05_2__5XP13, IC8_n, T05_n, n5XP15, QXCH0_n, T05_n, GND, CHINC_n, T05_n, n5XP21, IC5_n, T05_n, __A05_NET_318, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b1, 1'b0) U5048(__A05_NET_314, IC16_n, T05_n, __A05_NET_315, __A05_NET_316, T05_n, GND, __A05_NET_314, __A05_NET_315, __A05_NET_313, S11, S12, __A05_NET_320, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5049(__A05_NET_317, RB_n, __A05_NET_323, RZ_n, __A05_NET_320, SCAD, GND, SCAD, __A05_NET_319, RC_n, __A05_NET_276, __A05_NET_260, __A05_NET_258, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 U5050(__A05_NET_317, __A05_2__5XP19, __A05_NET_314, __A05_NET_323, __A05_2__6XP7, __A05_NET_315, GND, XT2_n, NDR100_n, OCTAD2, NDR100_n, XT3_n, OCTAD3, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5051(OCTAD4, NDR100_n, XT4_n, OCTAD5, NDR100_n, XT5_n, GND, NDR100_n, XT6_n, OCTAD6, BR1_n, DV1_n, __A05_NET_262, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5052(__A05_NET_280, __A05_NET_279, T05_n, __A05_2__5XP19, T05_n, __A05_NET_272, GND, DV1_n, BR1, __A05_1__DV1B1B, TS0_n, BRDIF_n, __A05_NET_264, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 #(1'b0, 1'b1) U5053(__A05_NET_276, __A05_NET_280, __A05_NET_281, __A05_NET_277, __A05_NET_273,  , GND,  , __A05_2__5XP13, __A05_NET_287, __A05_NET_338, __A05_NET_345, __A05_NET_335, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U5054(ROR0, __A05_1__DV1B1B, IC2, IC5, READ0, __A05_NET_258, GND, __A05_NET_265, IC2, IC3, TS0, __A05_NET_272, WOR0, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b0, 1'b1) U5055(__A05_NET_259, __A05_NET_264, DV4, __A05_NET_270, __A05_NET_260, T05_n, GND, __A05_NET_261, T05_n, __A05_NET_263, __A05_NET_270, __A05_NET_281, __A05_NET_271, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5056(__A05_NET_259, __A05_NET_260, __A05_NET_269, Z16_n, __A05_NET_271, WA_n, GND, __A05_NET_267, __A05_NET_265, __A05_NET_267, __A05_NET_266, WZ_n, __A05_NET_268, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC04 #(1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0) U5057(__A05_NET_263, __A05_NET_269, __A05_NET_352, __A05_NET_268, __A05_NET_281, __A05_NET_341, GND, __A05_NET_334, __A05_NET_277, NISQ, NISQ_n,  ,  , p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b0, 1'b1) U5058(__A05_NET_266, IC16, MP3, __A05_NET_352, T06_n, __A05_NET_267, GND, T06_n, DAS1_n, n6XP8, n6XP8, __A05_2__6XP7, __A05_NET_289, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5059(__A05_NET_289, TOV_n, __A05_NET_286, RU_n, __A05_NET_288, RU_n, GND, WB_n, __A05_NET_291, RG_n, __A05_NET_292, TSGN_n, __A05_NET_342, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 U5060(__A05_2__6XP7, DV4_n, T06_n, __A05_NET_340, T07_n, __A05_NET_297, GND, T07_n, STFET1_n, __A05_NET_294, T08_n, DV4_n, RSTSTG, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U5061(__A05_NET_352, n6XP8, __A05_NET_293, __A05_NET_338, __A05_NET_287, __A05_NET_288, GND, __A05_2__6XP2, T06_n, RXOR0, INOUT_n, __A05_NET_286, n5XP11, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b0) U5062(IC13, IC14, __A05_NET_340, __A05_NET_338, __A05_NET_293, __A05_NET_291, GND, __A05_NET_292, __A05_NET_340, __A05_NET_294, __A05_NET_273, __A05_NET_297, DV1, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U5063(T08_n, MONWBK, IC2, IC14, DV1, __A05_NET_339, GND, __A05_NET_346, DV4B1B, IC4, __A05_NET_344, U2BBK, STFET1_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5064(__A05_NET_342, RSTSTG, __A05_2__5XP9, __A05_NET_281, T09_n, __A05_NET_261, GND, T09_n, DV4_n, __A05_NET_338, T09_n, DAS1_n, __A05_NET_277, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5065(__A05_NET_341, Z15_n, __A05_NET_335, WL_n, __A05_NET_334, TMZ_n, GND, WYD_n, __A05_NET_343, TSGN_n, __A05_NET_178,  ,  , p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10
    U74HC27 U5066(DAS1_n, ADS0, T12_n, T12USE_n, DV1_n, __A05_NET_287, GND,  ,  ,  ,  , __A05_NET_344, BR2, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b1, 1'b0) U5067(DV4B1B, DV4_n, BR1, __A05_2__11XP6, T11_n, DV1_n, GND, __A05_2__5XP9, __A05_2__11XP6, __A05_NET_343, T11_n, RXOR0_n, __A05_NET_273, p4VSW, SIM_RST, SIM_CLK);
    U74LVC06 U5068(NISQ_n, MNISQ,  ,  ,  ,  , GND,  ,  ,  ,  ,  ,  , p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2
endmodule