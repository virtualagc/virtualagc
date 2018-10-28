`timescale 1ns/1ps
`default_nettype none

module crosspoint_ii(SIM_RST, SIM_CLK, p4VSW, GND, GOJAM, T01, T01_n, T02, T02_n, T03, T03_n, T04, T04_n, T05, T06, T06_n, T07, T07_n, T08, T08_n, T09, T10, T10_n, T11, T11_n, T12, T12USE_n, PHS4_n, ST2_n, BR1, BR1_n, BR2_n, BR1B2_n, BR12B_n, BR1B2B, BR1B2B_n, INKL, AD0, ADS0, AUG0_n, CCS0, CCS0_n, CDUSTB_n, DAS0, DAS1, DAS1_n, DCA0, DCS0, DIM0_n, DINC, DINC_n, DV1376, DV1376_n, DV376_n, DV4_n, DV4B1B, DXCH0, FETCH1, INCR0, INOTLD, MASK0, MCDU, MINC, MP0T10, MP1, MP1_n, MP3_n, MSU0, NDXX1_n, NISQ, PCDU, PINC, PRINC, RAND0, RUPT0, RUPT1, SHIFT, STFET1_n, SU0, WAND0, IC6, IC7, IC9, IC11, IC17, B15X, DIVSTG, PTWOX, R6, R15, R1C_n, RADRG, RADRZ, RB1_n, RBSQ, RRPA, STBE, STBF, TL15, L01_n, L02_n, L15_n, MON_n, MONpCH, n8PP4, n1XP10, n2XP3, n2XP5, n2XP7, n2XP8, n3XP2, n3XP6, n3XP7, n4XP11, n5XP4, n5XP12, n5XP15, n5XP21, n5XP28, n6XP5, n6XP8, n7XP4, n7XP9, n7XP19, n8XP6, n9XP1, n9XP5, n10XP1, n10XP8, n11XP2, A2X_n, BXVX, CGMC, CI_n, CLXC, EXT, L2GD_n, MCRO_n, MONEX, MONEX_n, NEAC, PIFL_n, PONEX, R1C, RB_n, RB1, RB1F, RC_n, RCH_n, RG_n, RU_n, RUS_n, RZ_n, ST1, ST2, TOV_n, TSGU_n, TWOX, WA_n, WB_n, WG_n, WL_n, WOVR_n, WQ_n, WS_n, WSC_n, WY_n, WYD_n, WZ_n, ZAP_n, POUT_n, MOUT_n, ZOUT_n, RPTSET, PSEUDO, n7XP14, WHOMP, WHOMPA, MRCH);
    input wire SIM_RST;
    input wire SIM_CLK;
    input wire p4VSW;
    input wire GND;
    output wire A2X_n; //FPGA#wand
    input wire AD0;
    input wire ADS0;
    input wire AUG0_n;
    input wire B15X;
    input wire BR1;
    input wire BR12B_n;
    input wire BR1B2B;
    input wire BR1B2B_n;
    input wire BR1B2_n;
    input wire BR1_n;
    input wire BR2_n;
    output wire BXVX;
    input wire CCS0;
    input wire CCS0_n;
    input wire CDUSTB_n;
    output wire CGMC;
    output wire CI_n; //FPGA#wand
    output wire CLXC;
    input wire DAS0;
    input wire DAS1;
    input wire DAS1_n;
    input wire DCA0;
    input wire DCS0;
    input wire DIM0_n;
    input wire DINC;
    input wire DINC_n;
    input wire DIVSTG;
    input wire DV1376;
    input wire DV1376_n;
    input wire DV376_n;
    input wire DV4B1B;
    input wire DV4_n;
    input wire DXCH0;
    output wire EXT;
    input wire FETCH1;
    input wire GOJAM;
    input wire IC11;
    input wire IC17;
    input wire IC6;
    input wire IC7;
    input wire IC9;
    input wire INCR0;
    input wire INKL;
    input wire INOTLD;
    input wire L01_n;
    input wire L02_n;
    input wire L15_n;
    output wire L2GD_n;
    input wire MASK0;
    input wire MCDU;
    output wire MCRO_n;
    input wire MINC;
    output wire MONEX;
    inout wire MONEX_n; //FPGA#wand
    input wire MON_n;
    input wire MONpCH;
    output wire MOUT_n;
    input wire MP0T10;
    input wire MP1;
    input wire MP1_n;
    input wire MP3_n;
    output wire MRCH; //FPGA#wand
    input wire MSU0;
    input wire NDXX1_n;
    output wire NEAC;
    input wire NISQ;
    input wire PCDU;
    input wire PHS4_n;
    output wire PIFL_n;
    input wire PINC;
    output wire PONEX;
    output wire POUT_n;
    input wire PRINC;
    output wire PSEUDO;
    input wire PTWOX;
    input wire R15;
    output wire R1C;
    inout wire R1C_n; //FPGA#wand
    input wire R6;
    input wire RADRG;
    input wire RADRZ;
    input wire RAND0;
    output wire RB1;
    output wire RB1F;
    inout wire RB1_n; //FPGA#wand
    input wire RBSQ;
    output wire RB_n; //FPGA#wand
    output wire RCH_n;
    output wire RC_n; //FPGA#wand
    output wire RG_n; //FPGA#wand
    output wire RPTSET; //FPGA#wand
    input wire RRPA;
    input wire RUPT0;
    input wire RUPT1;
    output wire RUS_n;
    output wire RU_n; //FPGA#wand
    output wire RZ_n; //FPGA#wand
    input wire SHIFT;
    output wire ST1;
    output wire ST2;
    inout wire ST2_n; //FPGA#wand
    input wire STBE;
    input wire STBF;
    input wire STFET1_n;
    input wire SU0;
    input wire T01;
    input wire T01_n;
    input wire T02;
    input wire T02_n;
    input wire T03;
    input wire T03_n;
    input wire T04;
    input wire T04_n;
    input wire T05;
    input wire T06;
    input wire T06_n;
    input wire T07;
    input wire T07_n;
    input wire T08;
    input wire T08_n;
    input wire T09;
    input wire T10;
    input wire T10_n;
    input wire T11;
    input wire T11_n;
    input wire T12;
    input wire T12USE_n;
    input wire TL15;
    output wire TOV_n; //FPGA#wand
    output wire TSGU_n;
    output wire TWOX;
    input wire WAND0;
    output wire WA_n; //FPGA#wand
    output wire WB_n; //FPGA#wand
    output wire WG_n; //FPGA#wand
    output wire WHOMP;
    output wire WHOMPA;
    output wire WL_n; //FPGA#wand
    output wire WOVR_n;
    output wire WQ_n;
    output wire WSC_n; //FPGA#wand
    output wire WS_n; //FPGA#wand
    output wire WYD_n; //FPGA#wand
    output wire WY_n; //FPGA#wand
    output wire WZ_n; //FPGA#wand
    output wire ZAP_n;
    output wire ZOUT_n;
    wire __A06_1__DVXP1;
    wire __A06_1__L02A_n;
    wire __A06_1__WHOMP_n;
    wire __A06_1__ZAP;
    wire __A06_1__ZIP;
    wire __A06_1__ZIPCI;
    wire __A06_2__10XP15;
    wire __A06_2__10XP9;
    wire __A06_2__6XP10;
    wire __A06_2__6XP12;
    wire __A06_2__7XP10;
    wire __A06_2__7XP11;
    wire __A06_2__7XP15;
    wire __A06_2__7XP7;
    wire __A06_2__8XP4;
    wire __A06_2__MOUT;
    wire __A06_2__POUT;
    wire __A06_2__RDBANK;
    wire __A06_2__ZOUT;
    input wire n10XP1;
    input wire n10XP8;
    input wire n11XP2;
    input wire n1XP10;
    input wire n2XP3;
    input wire n2XP5;
    input wire n2XP7;
    input wire n2XP8;
    input wire n3XP2;
    input wire n3XP6;
    input wire n3XP7;
    input wire n4XP11;
    input wire n5XP12;
    input wire n5XP15;
    input wire n5XP21;
    input wire n5XP28;
    input wire n5XP4;
    input wire n6XP5;
    input wire n6XP8;
    output wire n7XP14;
    input wire n7XP19;
    input wire n7XP4;
    input wire n7XP9;
    inout wire n8PP4; //FPGA#wand
    input wire n8XP6;
    input wire n9XP1;
    input wire n9XP5;
    wire net_R6001_Pad2; //FPGA#wand
    wire net_R6005_Pad2; //FPGA#wand
    wire net_R6014_Pad2; //FPGA#wand
    wire net_R6015_Pad2; //FPGA#wand
    wire net_R6020_Pad2; //FPGA#wand
    wire net_R6022_Pad2; //FPGA#wand
    wire net_R6025_Pad2; //FPGA#wand
    wire net_U6001_Pad12;
    wire net_U6001_Pad3;
    wire net_U6001_Pad4;
    wire net_U6001_Pad5;
    wire net_U6001_Pad6;
    wire net_U6001_Pad8;
    wire net_U6002_Pad13;
    wire net_U6003_Pad12;
    wire net_U6003_Pad3;
    wire net_U6003_Pad6;
    wire net_U6003_Pad8;
    wire net_U6004_Pad11;
    wire net_U6004_Pad13;
    wire net_U6004_Pad5;
    wire net_U6004_Pad9;
    wire net_U6005_Pad1;
    wire net_U6005_Pad11;
    wire net_U6005_Pad12;
    wire net_U6005_Pad13;
    wire net_U6005_Pad9;
    wire net_U6006_Pad12;
    wire net_U6006_Pad13;
    wire net_U6006_Pad2;
    wire net_U6006_Pad4;
    wire net_U6006_Pad6;
    wire net_U6007_Pad4;
    wire net_U6007_Pad8;
    wire net_U6008_Pad6;
    wire net_U6009_Pad10;
    wire net_U6009_Pad13;
    wire net_U6009_Pad4;
    wire net_U6010_Pad10;
    wire net_U6010_Pad3;
    wire net_U6010_Pad4;
    wire net_U6010_Pad5;
    wire net_U6010_Pad6;
    wire net_U6012_Pad10;
    wire net_U6012_Pad13;
    wire net_U6012_Pad5;
    wire net_U6013_Pad12;
    wire net_U6013_Pad8;
    wire net_U6014_Pad11;
    wire net_U6014_Pad13;
    wire net_U6014_Pad5;
    wire net_U6014_Pad9;
    wire net_U6015_Pad1;
    wire net_U6015_Pad4;
    wire net_U6016_Pad13;
    wire net_U6016_Pad4;
    wire net_U6018_Pad13;
    wire net_U6019_Pad11;
    wire net_U6019_Pad13;
    wire net_U6019_Pad3;
    wire net_U6019_Pad9;
    wire net_U6021_Pad10;
    wire net_U6021_Pad13;
    wire net_U6021_Pad6;
    wire net_U6022_Pad10;
    wire net_U6022_Pad6;
    wire net_U6022_Pad9;
    wire net_U6023_Pad10;
    wire net_U6023_Pad11;
    wire net_U6023_Pad12;
    wire net_U6023_Pad5;
    wire net_U6023_Pad6;
    wire net_U6024_Pad3;
    wire net_U6024_Pad4;
    wire net_U6025_Pad10;
    wire net_U6025_Pad11;
    wire net_U6025_Pad12;
    wire net_U6025_Pad2;
    wire net_U6025_Pad4;
    wire net_U6025_Pad6;
    wire net_U6026_Pad10;
    wire net_U6027_Pad1;
    wire net_U6027_Pad10;
    wire net_U6027_Pad13;
    wire net_U6027_Pad4;
    wire net_U6028_Pad12;
    wire net_U6029_Pad13;
    wire net_U6029_Pad9;
    wire net_U6030_Pad11;
    wire net_U6030_Pad13;
    wire net_U6030_Pad4;
    wire net_U6031_Pad11;
    wire net_U6032_Pad1;
    wire net_U6032_Pad10;
    wire net_U6032_Pad6;
    wire net_U6034_Pad10;
    wire net_U6034_Pad12;
    wire net_U6034_Pad3;
    wire net_U6034_Pad9;
    wire net_U6035_Pad10;
    wire net_U6035_Pad13;
    wire net_U6035_Pad2;
    wire net_U6035_Pad4;
    wire net_U6036_Pad10;
    wire net_U6036_Pad8;
    wire net_U6037_Pad11;
    wire net_U6037_Pad13;
    wire net_U6037_Pad3;
    wire net_U6037_Pad5;
    wire net_U6037_Pad9;
    wire net_U6038_Pad10;
    wire net_U6038_Pad11;
    wire net_U6038_Pad12;
    wire net_U6040_Pad8;
    wire net_U6041_Pad11;
    wire net_U6041_Pad13;
    wire net_U6041_Pad3;
    wire net_U6041_Pad5;
    wire net_U6041_Pad9;
    wire net_U6042_Pad11;
    wire net_U6043_Pad4;
    wire net_U6044_Pad10;
    wire net_U6044_Pad4;
    wire net_U6045_Pad3;
    wire net_U6045_Pad6;
    wire net_U6045_Pad8;
    wire net_U6046_Pad13;
    wire net_U6047_Pad11;
    wire net_U6047_Pad13;
    wire net_U6047_Pad5;
    wire net_U6048_Pad13;
    wire net_U6048_Pad4;
    wire net_U6049_Pad10;
    wire net_U6050_Pad6;
    wire net_U6050_Pad9;
    wire net_U6052_Pad9;
    wire net_U6053_Pad4;
    wire net_U6055_Pad10;
    wire net_U6055_Pad6;

    pullup R6001(net_R6001_Pad2);
    pullup R6002(A2X_n);
    pullup R6003(RB_n);
    pullup R6004(WYD_n);
    pullup R6005(net_R6005_Pad2);
    pullup R6006(WL_n);
    pullup R6007(RG_n);
    pullup R6008(WB_n);
    pullup R6009(RU_n);
    pullup R6010(WZ_n);
    pullup R6011(TOV_n);
    pullup R6012(WSC_n);
    pullup R6013(WG_n);
    pullup R6014(net_R6014_Pad2);
    pullup R6015(net_R6015_Pad2);
    pullup R6016(MONEX_n);
    pullup R6017(RB1_n);
    pullup R6018(R1C_n);
    pullup R6019(n8PP4);
    pullup R6020(net_R6020_Pad2);
    pullup R6021(WS_n);
    pullup R6022(net_R6022_Pad2);
    pullup R6023(CI_n);
    pullup R6024(WA_n);
    pullup R6025(net_R6025_Pad2);
    pullup R6026(ST2_n);
    pullup R6027(RZ_n);
    pullup R6028(RC_n);
    U74HC27 U6001(T04, T07, net_U6001_Pad3, net_U6001_Pad4, net_U6001_Pad5, net_U6001_Pad6, GND, net_U6001_Pad8, T01, T03, T05, net_U6001_Pad12, T10, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U6002(net_U6001_Pad3, net_U6001_Pad12, DV376_n, net_U6001_Pad4, T01_n, DV1376_n, GND, T04_n, DV4_n, net_U6001_Pad5, MP1_n, net_R6001_Pad2, net_U6002_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b0, 1'b1) U6003(T07, T09, net_U6003_Pad3, __A06_1__L02A_n, L01_n, net_U6003_Pad6, GND, net_U6003_Pad8, T05, T08, T11, net_U6003_Pad12, T11, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U6004(net_U6001_Pad8, net_R6001_Pad2, net_U6003_Pad12, net_R6001_Pad2, net_U6004_Pad5, A2X_n, GND, RB_n, net_U6004_Pad9, WYD_n, net_U6004_Pad11, WY_n, net_U6004_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 #(1'b1, 1'b1, 1'b1, 1'b0) U6005(net_U6005_Pad1, net_U6002_Pad13, n2XP7, L2GD_n, __A06_1__ZIP, __A06_1__DVXP1, GND, __A06_1__DVXP1, net_U6005_Pad9, net_U6004_Pad11, net_U6005_Pad11, net_U6005_Pad12, net_U6005_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 #(1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0) U6006(L01_n, net_U6006_Pad2, __A06_1__L02A_n, net_U6006_Pad4, net_U6003_Pad3, net_U6006_Pad6, GND, __A06_1__DVXP1, net_U6001_Pad6, __A06_1__ZIP, net_U6005_Pad1, net_U6006_Pad12, net_U6006_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b1, 1'b0, 1'b0) U6007(n7XP19, __A06_1__ZIP, __A06_1__DVXP1, net_U6007_Pad4, RBSQ, net_U6004_Pad9, GND, net_U6007_Pad8, net_U6006_Pad2, net_U6006_Pad4, net_U6006_Pad6, net_U6004_Pad5, __A06_1__DVXP1, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U6008(net_U6006_Pad6, net_U6006_Pad2, net_U6005_Pad1, net_U6005_Pad12, net_U6005_Pad11, net_U6008_Pad6, GND, net_U6006_Pad13, net_U6005_Pad11, net_U6005_Pad12, __A06_1__L02A_n, net_U6005_Pad12, __A06_1__L02A_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U6009(net_U6005_Pad9, net_U6005_Pad1, net_U6005_Pad13, net_U6009_Pad4, net_U6005_Pad1, net_U6006_Pad12, GND, net_U6003_Pad8, DV376_n, net_U6009_Pad10, DV1376_n, T02_n, net_U6009_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 U6010(net_U6009_Pad4, MCRO_n, net_U6010_Pad3, net_U6010_Pad4, net_U6010_Pad5, net_U6010_Pad6, GND, __A06_1__ZAP, ZAP_n, net_U6010_Pad10, net_U6003_Pad8, MONEX, MONEX_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U6011(net_U6005_Pad1, net_U6006_Pad12, net_U6006_Pad13, net_U6007_Pad8, net_U6005_Pad1, net_U6007_Pad4, GND, net_U6005_Pad11, net_U6006_Pad4, net_U6003_Pad3, L01_n, __A06_1__ZIPCI, net_U6003_Pad6, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b1, 1'b1, 1'b1, 1'b0) U6012(net_U6010_Pad3, net_U6009_Pad10, net_U6009_Pad13, net_U6010_Pad5, net_U6012_Pad5, DIVSTG, GND, T08, T10, net_U6012_Pad10, MP1_n, net_R6005_Pad2, net_U6012_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b1, 1'b0, 1'b1) U6013(T06, T09, DV376_n, net_U6013_Pad12, T12USE_n, net_U6012_Pad5, GND, net_U6013_Pad8, T02, T04, T06, net_U6013_Pad12, T12, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U6014(net_U6013_Pad8, net_R6005_Pad2, net_U6012_Pad10, net_R6005_Pad2, net_U6014_Pad5, WL_n, GND, RG_n, net_U6014_Pad9, WB_n, net_U6014_Pad11, RU_n, net_U6014_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 #(1'b1, 1'b0, 1'b1, 1'b0) U6015(net_U6015_Pad1, T01, T03, net_U6015_Pad4, net_U6015_Pad1, MP3_n, GND, net_U6012_Pad13, net_U6015_Pad4, ZAP_n, n5XP28, net_U6010_Pad4, TSGU_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b1, 1'b1, 1'b1, 1'b1) U6016(net_U6014_Pad5, net_U6010_Pad4, n5XP12, net_U6016_Pad4, RRPA, n5XP4, GND, n5XP15, n3XP6, WQ_n, n9XP5, n6XP8, net_U6016_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 #(1'b0, 1'b1) U6017(net_U6014_Pad9, n5XP4, RADRG, net_U6010_Pad4, n5XP28,  , GND,  , n5XP28, n1XP10, net_U6010_Pad6, n2XP3, net_U6014_Pad11, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U6018(net_U6014_Pad13, net_U6010_Pad6, __A06_1__ZAP, n5XP12, n6XP5,  , GND,  , PRINC, PINC, MINC, DINC, net_U6018_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U6019(net_U6016_Pad4, WZ_n, net_U6019_Pad3, TOV_n, net_U6016_Pad13, WSC_n, GND, WG_n, net_U6019_Pad9, net_R6014_Pad2, net_U6019_Pad11, net_R6014_Pad2, net_U6019_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 #(1'b1, 1'b0, 1'b0) U6020(n6XP5, n3XP2, BR1_n, PHS4_n, TSGU_n, RB1F, GND, CLXC, TSGU_n, BR1, PHS4_n, net_U6019_Pad3, n9XP5, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b1, 1'b1) U6021(net_U6019_Pad9, n6XP8, n6XP8, PIFL_n, __A06_1__DVXP1, net_U6021_Pad6, GND, PTWOX, MONEX, net_U6021_Pad10, MONEX, B15X, net_U6021_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b0) U6022(PIFL_n, net_U6010_Pad10, STBE, n1XP10, STBF, net_U6022_Pad6, GND, net_U6019_Pad11, net_U6022_Pad9, net_U6022_Pad10, INCR0, net_U6021_Pad6, T02, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 #(1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0) U6023(net_U6021_Pad10, TWOX, net_U6021_Pad13, BXVX, net_U6023_Pad5, net_U6023_Pad6, GND, net_U6023_Pad11, net_U6023_Pad6, net_U6023_Pad10, net_U6023_Pad11, net_U6023_Pad12, net_U6023_Pad10, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U6024(CGMC, net_U6022_Pad6, net_U6024_Pad3, net_U6024_Pad4, CGMC, net_U6023_Pad5, GND, net_U6024_Pad4, net_U6022_Pad6, net_U6023_Pad5, BR1, AUG0_n, net_U6022_Pad9, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 #(1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0) U6025(net_U6023_Pad12, net_U6025_Pad2, net_U6025_Pad2, net_U6025_Pad4, net_U6025_Pad4, net_U6025_Pad6, GND, net_U6024_Pad3, net_U6025_Pad6, net_U6025_Pad10, net_U6025_Pad11, net_U6025_Pad12, __A06_2__7XP10, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U6026(net_U6022_Pad10, DIM0_n, BR12B_n, net_U6019_Pad13, PINC, net_U6026_Pad10, GND, BR12B_n, DINC_n, net_U6026_Pad10, T06_n, net_R6014_Pad2, __A06_2__6XP10, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U6027(net_U6027_Pad1, MINC, MCDU, net_U6027_Pad4, AUG0_n, BR1_n, GND, DIM0_n, BR1B2B_n, net_U6027_Pad10, BR1B2B_n, DINC_n, net_U6027_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U6028(net_U6027_Pad4, net_U6027_Pad10, BR1B2B_n, CDUSTB_n, DINC_n, __A06_2__POUT, GND, __A06_2__MOUT, BR12B_n, CDUSTB_n, DINC_n, net_U6028_Pad12, net_U6027_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U6029(net_U6027_Pad1, net_R6015_Pad2, net_U6028_Pad12, net_R6015_Pad2, net_U6025_Pad10, MONEX_n, GND, WA_n, net_U6029_Pad9, RB1_n, net_U6025_Pad12, R1C_n, net_U6029_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 U6030(net_U6025_Pad11, T06_n, net_R6015_Pad2, net_U6030_Pad4, PCDU, MCDU, GND, T06_n, net_U6030_Pad4, __A06_2__6XP12, net_U6030_Pad11, T07_n, net_U6030_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b1) U6031(BR2_n, DINC_n, DAS0, DAS1, MSU0, net_U6030_Pad11, GND, net_U6029_Pad9, net_U6030_Pad13, __A06_2__7XP7, net_U6031_Pad11, __A06_2__ZOUT, CDUSTB_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U6032(net_U6032_Pad1, DV4_n, BR1B2B, __A06_2__7XP7, T07_n, net_U6032_Pad6, GND, WAND0, INOTLD, net_U6032_Pad10, T07_n, net_U6032_Pad10, n7XP14, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U6033(net_U6032_Pad1, WAND0, DAS1_n, T07_n, BR1B2_n, __A06_2__7XP10, GND, __A06_2__7XP11, DAS1_n, T07_n, BR12B_n, net_U6032_Pad6, RAND0, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 U6034(__A06_2__7XP11, net_U6029_Pad13, net_U6034_Pad3, PONEX, ST2_n, ST2, GND, ST1, net_U6034_Pad9, net_U6034_Pad10, PSEUDO, net_U6034_Pad12, __A06_2__RDBANK, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U6035(__A06_2__7XP15, net_U6035_Pad2, T07_n, net_U6035_Pad4, net_U6018_Pad13, T07_n, GND, PRINC, INKL, net_U6035_Pad10, IC9, DXCH0, net_U6035_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U6036(PCDU, MCDU, n7XP9, n11XP2, __A06_2__7XP15, RUS_n, GND, net_U6036_Pad8, net_U6035_Pad4, net_U6036_Pad10, net_U6031_Pad11, net_U6035_Pad2, SHIFT, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U6037(net_U6036_Pad8, RU_n, net_U6037_Pad3, WSC_n, net_U6037_Pad5, WG_n, GND, RB_n, net_U6037_Pad9, n8PP4, net_U6037_Pad11, n8PP4, net_U6037_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 #(1'b0, 1'b0, 1'b1) U6038(net_U6035_Pad10, T07_n, T04_n, MON_n, FETCH1, net_U6038_Pad10, GND, net_U6037_Pad3, net_U6038_Pad12, net_U6038_Pad10, net_U6038_Pad11, net_U6038_Pad12, MONpCH, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U6039(net_U6037_Pad5, net_U6038_Pad12, net_U6038_Pad11, net_U6038_Pad11, T07_n, net_U6035_Pad13, GND, __A06_2__10XP9, net_U6038_Pad11, net_U6037_Pad9, T08_n, n8PP4, __A06_2__8XP4, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U6040(RUPT1, DAS1, IC17, MASK0, IC11, net_U6037_Pad13, GND, net_U6040_Pad8, IC6, IC7, IC9, net_U6037_Pad11, MSU0, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U6041(net_U6040_Pad8, n8PP4, net_U6041_Pad3, net_R6020_Pad2, net_U6041_Pad5, net_R6020_Pad2, GND, WS_n, net_U6041_Pad9, net_R6022_Pad2, net_U6041_Pad11, net_R6022_Pad2, net_U6041_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 #(1'b0, 1'b1, 1'b0) U6042(T08_n, RUPT0, net_R6020_Pad2, R6, R15, net_U6041_Pad9, GND, net_U6041_Pad13, ADS0, IC11, net_U6042_Pad11, net_U6041_Pad3, DAS0, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U6043(net_U6041_Pad5, MP1, DV1376, net_U6043_Pad4, MP3_n, BR1_n, GND, net_U6043_Pad4, CCS0, net_U6041_Pad11, T11_n, net_R6022_Pad2, net_U6031_Pad11, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U6044(net_U6042_Pad11, DAS1_n, BR2_n, net_U6044_Pad4, __A06_1__ZIPCI, __A06_2__6XP12, GND, CCS0_n, BR1B2B_n, net_U6044_Pad10, T10_n, NDXX1_n, EXT, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b0) U6045(T03_n, DAS1_n, net_U6045_Pad3, net_U6036_Pad10, n2XP5, net_U6045_Pad6, GND, net_U6045_Pad8, IC7, DCS0, SU0, net_U6036_Pad10, ADS0, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 #(1'b1, 1'b0) U6046(net_U6034_Pad3, n8XP6, n7XP4, n10XP8, __A06_2__6XP10,  , GND,  , IC6, DCA0, AD0, net_U6044_Pad10, net_U6046_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U6047(net_U6044_Pad4, CI_n, net_U6045_Pad6, WA_n, net_U6047_Pad5, RC_n, GND, net_R6025_Pad2, net_U6045_Pad8, net_R6025_Pad2, net_U6047_Pad11, ST2_n, net_U6047_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 U6048(__A06_2__10XP9, T10_n, net_U6046_Pad13, net_U6048_Pad4, IC6, IC7, GND, T10_n, net_U6048_Pad4, net_U6045_Pad3, T10_n, net_R6025_Pad2, net_U6048_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U6049(net_U6047_Pad5, net_U6048_Pad13, __A06_2__7XP7, net_U6047_Pad11, net_U6049_Pad10, DV4B1B, GND, CCS0_n, BR12B_n, net_U6049_Pad10, T10_n, MP1_n, __A06_2__10XP15, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U6050(__A06_2__8XP4, __A06_2__10XP15, __A06_2__8XP4, RADRZ, n9XP1, net_U6050_Pad6, GND, NEAC, net_U6050_Pad9, TL15, GOJAM, net_U6047_Pad13, RADRZ, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U6051(net_U6034_Pad9, n2XP8, n10XP1, MP0T10, __A06_2__10XP15,  , GND,  , __A06_1__DVXP1, GOJAM, NISQ, __A06_1__WHOMP_n, WHOMP, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U6052(net_U6050_Pad6, RZ_n, net_U6034_Pad10, RPTSET, net_U6034_Pad12, RU_n, GND, RC_n, net_U6052_Pad9,  ,  ,  ,  , p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8
    U74HC02 #(1'b1, 1'b0, 1'b0, 1'b0) U6053(net_U6050_Pad9, MP0T10, NEAC, net_U6053_Pad4, RADRZ, PSEUDO, GND, T06_n, STFET1_n, __A06_2__RDBANK, __A06_1__ZIPCI, n3XP7, net_U6052_Pad9, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b1, 1'b0, 1'b0) U6054(net_U6053_Pad4, GOJAM, n3XP7, n5XP21, n4XP11, RCH_n, GND,  ,  ,  ,  , PSEUDO, RADRG, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 #(1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0) U6055(R1C_n, R1C, RB1_n, RB1, L02_n, net_U6055_Pad6, GND, __A06_1__L02A_n, net_U6055_Pad6, net_U6055_Pad10, L15_n, net_U6003_Pad3, net_U6055_Pad10, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 #(1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0) U6056(net_U6008_Pad6, net_U6004_Pad13, __A06_1__WHOMP_n, WHOMPA, net_U6038_Pad12, WOVR_n, GND, POUT_n, __A06_2__POUT, MOUT_n, __A06_2__MOUT, ZOUT_n, __A06_2__ZOUT, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b1, 1'b0, 1'b0, 1'b0) U6057(__A06_1__WHOMP_n, WHOMP, CLXC,  ,  ,  , GND,  ,  ,  ,  ,  ,  , p4VSW, SIM_RST, SIM_CLK);
    U74LVC06 U6058(RCH_n, MRCH,  ,  ,  ,  , GND,  ,  ,  ,  ,  ,  , p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2
endmodule