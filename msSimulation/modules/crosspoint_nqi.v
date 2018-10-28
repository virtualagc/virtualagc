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
    wire net_R5002_Pad2; //FPGA#wand
    wire net_R5003_Pad2; //FPGA#wand
    wire net_R5009_Pad2; //FPGA#wand
    wire net_R5010_Pad2; //FPGA#wand
    wire net_U5001_Pad12;
    wire net_U5001_Pad6;
    wire net_U5001_Pad8;
    wire net_U5002_Pad1;
    wire net_U5002_Pad10;
    wire net_U5002_Pad13;
    wire net_U5002_Pad4;
    wire net_U5003_Pad1;
    wire net_U5003_Pad10;
    wire net_U5003_Pad4;
    wire net_U5004_Pad11;
    wire net_U5004_Pad6;
    wire net_U5004_Pad8;
    wire net_U5005_Pad11;
    wire net_U5005_Pad13;
    wire net_U5005_Pad5;
    wire net_U5005_Pad9;
    wire net_U5006_Pad3;
    wire net_U5006_Pad4;
    wire net_U5007_Pad4;
    wire net_U5007_Pad9;
    wire net_U5008_Pad4;
    wire net_U5008_Pad9;
    wire net_U5009_Pad3;
    wire net_U5010_Pad13;
    wire net_U5010_Pad3;
    wire net_U5010_Pad4;
    wire net_U5011_Pad6;
    wire net_U5011_Pad8;
    wire net_U5012_Pad11;
    wire net_U5012_Pad13;
    wire net_U5012_Pad5;
    wire net_U5012_Pad9;
    wire net_U5013_Pad1;
    wire net_U5013_Pad13;
    wire net_U5013_Pad4;
    wire net_U5014_Pad2;
    wire net_U5016_Pad10;
    wire net_U5016_Pad11;
    wire net_U5016_Pad12;
    wire net_U5016_Pad13;
    wire net_U5017_Pad12;
    wire net_U5017_Pad6;
    wire net_U5017_Pad8;
    wire net_U5018_Pad13;
    wire net_U5018_Pad9;
    wire net_U5019_Pad10;
    wire net_U5020_Pad4;
    wire net_U5020_Pad6;
    wire net_U5020_Pad8;
    wire net_U5021_Pad12;
    wire net_U5021_Pad6;
    wire net_U5021_Pad9;
    wire net_U5022_Pad11;
    wire net_U5022_Pad12;
    wire net_U5022_Pad13;
    wire net_U5022_Pad3;
    wire net_U5022_Pad6;
    wire net_U5023_Pad9;
    wire net_U5024_Pad11;
    wire net_U5024_Pad13;
    wire net_U5024_Pad3;
    wire net_U5024_Pad5;
    wire net_U5024_Pad9;
    wire net_U5025_Pad8;
    wire net_U5026_Pad13;
    wire net_U5027_Pad13;
    wire net_U5027_Pad4;
    wire net_U5027_Pad9;
    wire net_U5028_Pad12;
    wire net_U5028_Pad13;
    wire net_U5029_Pad10;
    wire net_U5030_Pad10;
    wire net_U5030_Pad13;
    wire net_U5031_Pad12;
    wire net_U5031_Pad4;
    wire net_U5032_Pad10;
    wire net_U5032_Pad4;
    wire net_U5032_Pad6;
    wire net_U5033_Pad1;
    wire net_U5033_Pad10;
    wire net_U5033_Pad12;
    wire net_U5033_Pad2;
    wire net_U5033_Pad6;
    wire net_U5033_Pad8;
    wire net_U5034_Pad11;
    wire net_U5035_Pad4;
    wire net_U5035_Pad6;
    wire net_U5037_Pad10;
    wire net_U5037_Pad13;
    wire net_U5037_Pad4;
    wire net_U5038_Pad6;
    wire net_U5038_Pad8;
    wire net_U5039_Pad11;
    wire net_U5039_Pad13;
    wire net_U5040_Pad10;
    wire net_U5040_Pad12;
    wire net_U5041_Pad10;
    wire net_U5041_Pad8;
    wire net_U5043_Pad12;
    wire net_U5043_Pad13;
    wire net_U5043_Pad6;
    wire net_U5043_Pad8;
    wire net_U5043_Pad9;
    wire net_U5044_Pad11;
    wire net_U5044_Pad13;
    wire net_U5044_Pad9;
    wire net_U5045_Pad13;
    wire net_U5046_Pad13;
    wire net_U5046_Pad2;
    wire net_U5046_Pad6;
    wire net_U5046_Pad8;
    wire net_U5048_Pad13;
    wire net_U5049_Pad1;
    wire net_U5049_Pad11;
    wire net_U5049_Pad13;
    wire net_U5049_Pad3;
    wire net_U5052_Pad1;
    wire net_U5052_Pad13;
    wire net_U5052_Pad6;
    wire net_U5053_Pad10;
    wire net_U5053_Pad11;
    wire net_U5053_Pad13;
    wire net_U5053_Pad3;
    wire net_U5053_Pad4;
    wire net_U5053_Pad5;
    wire net_U5054_Pad8;
    wire net_U5055_Pad1;
    wire net_U5055_Pad10;
    wire net_U5055_Pad11;
    wire net_U5055_Pad13;
    wire net_U5056_Pad11;
    wire net_U5056_Pad13;
    wire net_U5056_Pad3;
    wire net_U5057_Pad3;
    wire net_U5057_Pad6;
    wire net_U5057_Pad8;
    wire net_U5058_Pad13;
    wire net_U5059_Pad11;
    wire net_U5059_Pad13;
    wire net_U5059_Pad3;
    wire net_U5059_Pad5;
    wire net_U5059_Pad9;
    wire net_U5060_Pad10;
    wire net_U5060_Pad4;
    wire net_U5060_Pad6;
    wire net_U5063_Pad11;
    wire net_U5065_Pad9;

    pullup R5002(net_R5002_Pad2);
    pullup R5003(net_R5003_Pad2);
    pullup R5004(RL_n);
    pullup R5005(RA_n);
    pullup R5006(WY_n);
    pullup R5007(WY12_n);
    pullup R5008(SCAD);
    pullup R5009(net_R5009_Pad2);
    pullup R5010(net_R5010_Pad2);
    pullup R5011(TMZ_n);
    pullup R5012(TSGN_n);
    U74HC27 U5001(IC10, IC3, TC0, TCF0, IC4, net_U5001_Pad6, GND, net_U5001_Pad8, IC2, IC3, RSM3, net_U5001_Pad12, IC2, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5002(net_U5002_Pad1, STD2, IC2, net_U5002_Pad4, T01_n, net_U5001_Pad12, GND, T01_n, net_U5002_Pad1, net_U5002_Pad10, IC10_n, T01_n, net_U5002_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5003(net_U5003_Pad1, T01_n, net_U5001_Pad6, net_U5003_Pad4, T02_n, net_U5001_Pad8, GND, T08_n, CCS0_n, net_U5003_Pad10, T02_n, MP3_n, n2XP7, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b0) U5004(T02_n, STD2, __A05_1__10XP6, __A05_1__10XP7, net_U5002_Pad13, net_U5004_Pad6, GND, net_U5004_Pad8, net_U5002_Pad10, n3XP6, net_U5004_Pad11, DVST, DIV_n, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5005(net_U5004_Pad6, MONEX_n, net_U5004_Pad8, RZ_n, net_U5005_Pad5, RB_n, GND, RA_n, net_U5005_Pad9, WA_n, net_U5005_Pad11, RL_n, net_U5005_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 U5006(net_U5003_Pad4, __A05_1__8XP15, net_U5006_Pad3, net_U5006_Pad4, __A05_1__8XP12, net_U5005_Pad13, GND, __A05_1__PARTC, INKL_n, SHIFT, MONpCH, NISQ_n, n2XP7, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5007(__A05_1__3XP5, T03_n, IC2_n, net_U5007_Pad4, T01_n, IC15_n, GND, net_U5007_Pad4, net_U5007_Pad9, net_U5005_Pad9, T03_n, TC0_n, n3XP6, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5008(net_U5007_Pad9, T04_n, IC2_n, net_U5008_Pad4, T02_n, IC15_n, GND, net_U5008_Pad4, net_U5008_Pad9, TPZG_n, T04_n, DAS0_n, net_U5006_Pad3, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b1, 1'b0, 1'b0, 1'b0) U5009(net_U5005_Pad11, net_U5006_Pad3, net_U5009_Pad3, net_U5009_Pad3, T04_n, MASK0_n, GND, MP3_n, T10_n, net_U5006_Pad4, T05_n, IC2_n, net_U5004_Pad11, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5010(net_U5008_Pad9, T05_n, net_U5010_Pad3, net_U5010_Pad4, net_U5007_Pad4, net_U5008_Pad9, GND, T05_n, DAS0_n, n5XP12, T06_n, RSM3_n, net_U5010_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U5011(__A05_1__PARTC, PRINC, net_U5008_Pad9, net_U5007_Pad4, n7XP9, net_U5011_Pad6, GND, net_U5011_Pad8, n9XP5, net_U5007_Pad4, net_U5010_Pad13, net_U5010_Pad3, CCS0, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5012(net_U5010_Pad4, TMZ_n, net_U5011_Pad8, WG_n, net_U5012_Pad5, RG_n, GND, RC_n, net_U5012_Pad9, A2X_n, net_U5012_Pad11, WY_n, net_U5012_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 U5013(net_U5013_Pad1, T06_n, DAS0_n, net_U5013_Pad4, T06_n, MSU0_n, GND, net_U5009_Pad3, net_U5013_Pad4, net_U5012_Pad9, T07_n, DAS0_n, net_U5013_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b1) U5014(net_U5008_Pad9, net_U5014_Pad2, net_U5014_Pad2, net_U5013_Pad1, net_U5013_Pad4, net_U5012_Pad11, GND, net_U5012_Pad13, net_U5014_Pad2, net_U5013_Pad4, net_U5013_Pad1, net_U5012_Pad5, net_U5013_Pad1, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U5015(net_U5005_Pad5, net_U5003_Pad1, __A05_1__3XP5, net_U5013_Pad13, net_U5010_Pad13,  , GND,  , IC3, RSM3, MP3, IC16, TSUDO_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5016(n7XP9, T07_n, MSU0_n, net_U5014_Pad2, T07_n, IC2_n, GND, T07_n, CCS0_n, net_U5016_Pad10, net_U5016_Pad11, net_U5016_Pad12, net_U5016_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b0, 1'b1) U5017(net_U5013_Pad4, net_U5002_Pad4, __A05_1__8XP3, net_U5016_Pad10, n4XP5, net_U5017_Pad6, GND, net_U5017_Pad8, n4XP5, net_U5016_Pad10, net_U5002_Pad4, net_U5017_Pad12, __A05_1__10XP6, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5018(net_U5017_Pad12, CI_n, net_U5017_Pad6, RZ_n, net_U5017_Pad8, WY12_n, GND, WZ_n, net_U5018_Pad9, RB_n, net_U5016_Pad13, WB_n, net_U5018_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 #(1'b0, 1'b0, 1'b1) U5019(CCS0_n, T07_n, BR1_n, CCS0_n, T07_n, PTWOX, GND, net_U5018_Pad9, __A05_1__3XP5, net_U5019_Pad10, net_U5003_Pad10, n7XP4, BR2_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U5020(INKL_n, FETCH0, net_U5003_Pad10, net_U5020_Pad4, n9XP5, net_U5020_Pad6, GND, net_U5020_Pad8, IC2, IC4, DXCH0, net_U5016_Pad11, T08_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U5021(RAD, TSUDO_n, T08_n, net_U5018_Pad13, RAD, net_U5021_Pad6, GND, T08_n, net_U5021_Pad9, __A05_1__8XP15, T08_n, net_U5021_Pad12, __A05_1__8XP3, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 U5022(IC16, net_U5021_Pad9, net_U5022_Pad3, RQ_n, MP3, net_U5022_Pad6, GND, SCAD_n, SCAD, NDR100_n, net_U5022_Pad11, net_U5022_Pad12, net_U5022_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5023(net_U5021_Pad12, MP0, IC1, net_U5020_Pad4, T08_n, net_U5020_Pad8, GND, T08_n, net_U5023_Pad9, net_U5021_Pad6, T08_n, GOJ1_n, RSTRT, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5024(net_U5020_Pad6, RU_n, net_U5024_Pad3, RA_n, net_U5024_Pad5, ST2_n, GND, WY_n, net_U5024_Pad9, RC_n, net_U5024_Pad11, WA_n, net_U5024_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 U5025(DXCH0, GOJ1, CCS0_n, BR2, T10_n, __A05_1__10XP6, GND, net_U5025_Pad8, IC1, IC10, RUPT0, net_U5023_Pad9, DAS0, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5026(__A05_1__8XP12, T08_n, DAS0_n, net_U5019_Pad10, T08_n, TCSAJ3_n, GND, T09_n, net_U5026_Pad13, net_U5016_Pad12, IC2, __A05_1__DV1B1B, net_U5026_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5027(n9XP5, T09_n, DAS0_n, net_U5027_Pad4, T09_n, MASK0_n, GND, net_U5027_Pad4, net_U5027_Pad9, net_U5024_Pad3, T10_n, CCS0_n, net_U5027_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5028(net_U5024_Pad5, net_U5019_Pad10, net_U5027_Pad13, n10XP1, net_U5025_Pad8, T10_n, GND, T10_n, net_U5028_Pad13, net_U5027_Pad9, DAS0, net_U5028_Pad12, net_U5028_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b1, 1'b0, 1'b1) U5029(net_U5027_Pad13, net_U5027_Pad4, T10_n, DAS0_n, BR1B2_n, n10XP8, GND, net_U5024_Pad13, net_U5016_Pad12, net_U5029_Pad10, n5XP11, net_U5024_Pad9, net_U5027_Pad9, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5030(net_U5028_Pad12, MSU0_n, BR1_n, __A05_1__10XP7, T10_n, net_U5030_Pad10, GND, net_U5028_Pad12, net_U5030_Pad13, net_U5030_Pad10, BR12B_n, DAS0_n, net_U5030_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5031(n11XP2, T11_n, MSU0_n, net_U5031_Pad4, T11_n, MASK0_n, GND, net_U5027_Pad4, net_U5031_Pad4, net_U5024_Pad11, T11_n, net_U5031_Pad12, net_U5029_Pad10, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5032(net_U5031_Pad12, MSU0, IC14, net_U5032_Pad4, T10_n, net_U5032_Pad6, GND, GOJAM, GNHNC, net_U5032_Pad10, net_U5032_Pad10, T01, GNHNC, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b1, 1'b0, 1'b1) U5033(net_U5033_Pad1, net_U5033_Pad2, IC12, DAS0, DAS1, net_U5033_Pad6, GND, net_U5033_Pad8, RL10BB, net_U5033_Pad10, RSCT, net_U5033_Pad12, __A05_2__6XP2, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5034( ,  ,  ,  ,  ,  , GND, net_R5002_Pad2, net_U5033_Pad6, net_R5002_Pad2, net_U5034_Pad11, WS_n, net_U5033_Pad8, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:8,10,12
    U74HC02 U5035(__A05_2__10XP10, T10_n, IC11_n, net_U5035_Pad4, T10_n, net_U5035_Pad6, GND, T01_n, net_R5002_Pad2, RL10BB, T01_n, FETCH0_n, R6, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U5036(net_U5034_Pad11, IC9, DXCH0, PRINC, INOUT,  , GND,  , YB0_n, YT0_n, S12, S11, net_U5022_Pad11, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5037(net_U5033_Pad10, T01_n, CHINC_n, net_U5037_Pad4, T03_n, net_R5003_Pad2, GND, IC5, MP0, net_U5037_Pad10, T03_n, IC8_n, net_U5037_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b0, 1'b1) U5038(T01_n, MONpCH, TS0, DAS0, MASK0, net_U5038_Pad6, GND, net_U5038_Pad8, net_U5037_Pad4, net_U5037_Pad13, net_U5022_Pad3, RSCT, INKL_n, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5039(net_U5038_Pad8, WB_n, net_U5033_Pad12, WB_n, net_U5038_Pad6, net_R5003_Pad2, GND, net_R5003_Pad2, net_U5037_Pad10, RL_n, net_U5039_Pad11, RA_n, net_U5039_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 U5040(n2XP8, T02_n, FETCH0_n, net_U5022_Pad3, T03_n, QXCH0_n, GND, T04_n, DV1_n, net_U5040_Pad10, T04_n, net_U5040_Pad12, net_U5033_Pad1, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U5041(net_U5037_Pad13, net_U5040_Pad10, DV1, INOUT, IC2, net_U5040_Pad12, GND, net_U5041_Pad8, net_U5033_Pad2, net_U5041_Pad10, __A05_2__5XP9, net_U5039_Pad11, __A05_2__11XP6, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5042(net_U5039_Pad13, net_U5037_Pad4, __A05_2__6XP2, TRSM, T05_n, NDX0_n, GND, IC12_n, T05_n, net_U5033_Pad2, DAS1_n, T05_n, net_U5041_Pad10, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b0, 1'b1) U5043(__A05_2__5XP13, n5XP15, DAS1, PRINC, __A05_1__PARTC, net_U5043_Pad6, GND, net_U5043_Pad8, net_U5043_Pad9, n2XP8, __A05_2__10XP10, net_U5043_Pad12, net_U5043_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5044(net_U5041_Pad8, RG_n, net_U5043_Pad12, RG_n, net_U5043_Pad8, WY_n, GND, A2X_n, net_U5044_Pad9, CI_n, net_U5044_Pad11, WY12_n, net_U5044_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U5045(net_U5043_Pad9, net_U5043_Pad6, T05_n, net_U5044_Pad9, net_U5041_Pad10, __A05_2__10XP10, GND, SHIFT_n, T05_n, __A05_2__5XP9, SHANC_n, T05_n, net_U5045_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U5046(net_U5045_Pad13, net_U5046_Pad2, YT0_n, YB0_n, XT0_n, net_U5046_Pad6, GND, net_U5046_Pad8, RAND0, WAND0, net_U5022_Pad13, net_U5044_Pad11, net_U5046_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5047(__A05_2__5XP13, IC8_n, T05_n, n5XP15, QXCH0_n, T05_n, GND, CHINC_n, T05_n, n5XP21, IC5_n, T05_n, net_U5043_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b1, 1'b0) U5048(net_U5046_Pad2, IC16_n, T05_n, net_U5046_Pad13, net_U5022_Pad6, T05_n, GND, net_U5046_Pad2, net_U5046_Pad13, net_U5044_Pad13, S11, S12, net_U5048_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5049(net_U5049_Pad1, RB_n, net_U5049_Pad3, RZ_n, net_U5048_Pad13, SCAD, GND, SCAD, net_U5046_Pad6, RC_n, net_U5049_Pad11, net_R5009_Pad2, net_U5049_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 U5050(net_U5049_Pad1, __A05_2__5XP19, net_U5046_Pad2, net_U5049_Pad3, __A05_2__6XP7, net_U5046_Pad13, GND, XT2_n, NDR100_n, OCTAD2, NDR100_n, XT3_n, OCTAD3, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5051(OCTAD4, NDR100_n, XT4_n, OCTAD5, NDR100_n, XT5_n, GND, NDR100_n, XT6_n, OCTAD6, BR1_n, DV1_n, net_U5022_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5052(net_U5052_Pad1, net_U5046_Pad8, T05_n, __A05_2__5XP19, T05_n, net_U5052_Pad6, GND, DV1_n, BR1, __A05_1__DV1B1B, TS0_n, BRDIF_n, net_U5052_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 #(1'b0, 1'b1) U5053(net_U5049_Pad11, net_U5052_Pad1, net_U5053_Pad3, net_U5053_Pad4, net_U5053_Pad5,  , GND,  , __A05_2__5XP13, net_U5053_Pad10, net_U5053_Pad11, net_U5035_Pad4, net_U5053_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U5054(ROR0, __A05_1__DV1B1B, IC2, IC5, READ0, net_U5049_Pad13, GND, net_U5054_Pad8, IC2, IC3, TS0, net_U5052_Pad6, WOR0, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b0, 1'b1) U5055(net_U5055_Pad1, net_U5052_Pad13, DV4, net_U5055_Pad11, net_R5009_Pad2, T05_n, GND, net_U5022_Pad12, T05_n, net_U5055_Pad10, net_U5055_Pad11, net_U5053_Pad3, net_U5055_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5056(net_U5055_Pad1, net_R5009_Pad2, net_U5056_Pad3, Z16_n, net_U5055_Pad13, WA_n, GND, net_R5010_Pad2, net_U5054_Pad8, net_R5010_Pad2, net_U5056_Pad11, WZ_n, net_U5056_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC04 #(1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0) U5057(net_U5055_Pad10, net_U5056_Pad3, net_U5057_Pad3, net_U5056_Pad13, net_U5053_Pad3, net_U5057_Pad6, GND, net_U5057_Pad8, net_U5053_Pad4, NISQ, NISQ_n,  ,  , p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b0, 1'b1) U5058(net_U5056_Pad11, IC16, MP3, net_U5057_Pad3, T06_n, net_R5010_Pad2, GND, T06_n, DAS1_n, n6XP8, n6XP8, __A05_2__6XP7, net_U5058_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5059(net_U5058_Pad13, TOV_n, net_U5059_Pad3, RU_n, net_U5059_Pad5, RU_n, GND, WB_n, net_U5059_Pad9, RG_n, net_U5059_Pad11, TSGN_n, net_U5059_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 U5060(__A05_2__6XP7, DV4_n, T06_n, net_U5060_Pad4, T07_n, net_U5060_Pad6, GND, T07_n, STFET1_n, net_U5060_Pad10, T08_n, DV4_n, RSTSTG, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U5061(net_U5057_Pad3, n6XP8, net_U5032_Pad4, net_U5053_Pad11, net_U5053_Pad10, net_U5059_Pad5, GND, __A05_2__6XP2, T06_n, RXOR0, INOUT_n, net_U5059_Pad3, n5XP11, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b0) U5062(IC13, IC14, net_U5060_Pad4, net_U5053_Pad11, net_U5032_Pad4, net_U5059_Pad9, GND, net_U5059_Pad11, net_U5060_Pad4, net_U5060_Pad10, net_U5053_Pad5, net_U5060_Pad6, DV1, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U5063(T08_n, MONWBK, IC2, IC14, DV1, net_U5032_Pad6, GND, net_U5035_Pad6, DV4B1B, IC4, net_U5063_Pad11, U2BBK, STFET1_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U5064(net_U5059_Pad13, RSTSTG, __A05_2__5XP9, net_U5053_Pad3, T09_n, net_U5022_Pad12, GND, T09_n, DV4_n, net_U5053_Pad11, T09_n, DAS1_n, net_U5053_Pad4, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U5065(net_U5057_Pad6, Z15_n, net_U5053_Pad13, WL_n, net_U5057_Pad8, TMZ_n, GND, WYD_n, net_U5065_Pad9, TSGN_n, net_U5011_Pad6,  ,  , p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10
    U74HC27 U5066(DAS1_n, ADS0, T12_n, T12USE_n, DV1_n, net_U5053_Pad10, GND,  ,  ,  ,  , net_U5063_Pad11, BR2, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b1, 1'b0) U5067(DV4B1B, DV4_n, BR1, __A05_2__11XP6, T11_n, DV1_n, GND, __A05_2__5XP9, __A05_2__11XP6, net_U5065_Pad9, T11_n, RXOR0_n, net_U5053_Pad5, p4VSW, SIM_RST, SIM_CLK);
    U74LVC06 U5068(NISQ_n, MNISQ,  ,  ,  ,  , GND,  ,  ,  ,  ,  ,  , p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2
endmodule