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
    wire net_R3004_Pad2; //FPGA#wand
    wire net_R3005_Pad2; //FPGA#wand
    wire net_R4001_Pad2; //FPGA#wand
    wire net_R4002_Pad2; //FPGA#wand
    wire net_R4006_Pad2; //FPGA#wand
    wire net_R4007_Pad2; //FPGA#wand
    wire net_R4011_Pad2; //FPGA#wand
    wire net_U4001_Pad10;
    wire net_U4001_Pad13;
    wire net_U4001_Pad3;
    wire net_U4001_Pad8;
    wire net_U4001_Pad9;
    wire net_U4003_Pad11;
    wire net_U4003_Pad13;
    wire net_U4003_Pad3;
    wire net_U4003_Pad5;
    wire net_U4003_Pad9;
    wire net_U4004_Pad11;
    wire net_U4004_Pad13;
    wire net_U4004_Pad2;
    wire net_U4004_Pad6;
    wire net_U4004_Pad8;
    wire net_U4005_Pad10;
    wire net_U4005_Pad13;
    wire net_U4006_Pad13;
    wire net_U4006_Pad9;
    wire net_U4008_Pad5;
    wire net_U4008_Pad9;
    wire net_U4009_Pad10;
    wire net_U4009_Pad13;
    wire net_U4010_Pad13;
    wire net_U4010_Pad9;
    wire net_U4011_Pad1;
    wire net_U4011_Pad12;
    wire net_U4012_Pad1;
    wire net_U4012_Pad10;
    wire net_U4012_Pad13;
    wire net_U4013_Pad1;
    wire net_U4013_Pad10;
    wire net_U4015_Pad6;
    wire net_U4016_Pad1;
    wire net_U4017_Pad10;
    wire net_U4019_Pad1;
    wire net_U4019_Pad10;
    wire net_U4019_Pad13;
    wire net_U4020_Pad10;
    wire net_U4020_Pad11;
    wire net_U4020_Pad12;
    wire net_U4020_Pad6;
    wire net_U4020_Pad8;
    wire net_U4021_Pad10;
    wire net_U4021_Pad13;
    wire net_U4022_Pad1;
    wire net_U4022_Pad13;
    wire net_U4023_Pad13;
    wire net_U4023_Pad9;
    wire net_U4024_Pad10;
    wire net_U4024_Pad13;
    wire net_U4024_Pad4;
    wire net_U4024_Pad8;
    wire net_U4025_Pad12;
    wire net_U4025_Pad13;
    wire net_U4025_Pad9;
    wire net_U4026_Pad12;
    wire net_U4026_Pad6;
    wire net_U4026_Pad8;
    wire net_U4027_Pad13;
    wire net_U4028_Pad1;
    wire net_U4028_Pad11;
    wire net_U4029_Pad9;
    wire net_U4030_Pad13;
    wire net_U4034_Pad8;
    wire net_U4035_Pad2;
    wire net_U4035_Pad6;
    wire net_U4036_Pad11;
    wire net_U4036_Pad13;
    wire net_U4037_Pad10;
    wire net_U4037_Pad11;
    wire net_U4037_Pad6;
    wire net_U4037_Pad8;
    wire net_U4038_Pad10;
    wire net_U4038_Pad4;
    wire net_U4039_Pad11;
    wire net_U4039_Pad13;
    wire net_U4039_Pad3;
    wire net_U4039_Pad5;
    wire net_U4039_Pad9;
    wire net_U4040_Pad11;
    wire net_U4040_Pad13;
    wire net_U4040_Pad2;
    wire net_U4040_Pad9;
    wire net_U4042_Pad4;
    wire net_U4043_Pad6;
    wire net_U4044_Pad10;
    wire net_U4045_Pad11;
    wire net_U4045_Pad13;
    wire net_U4045_Pad3;
    wire net_U4045_Pad5;
    wire net_U4045_Pad9;
    wire net_U4046_Pad12;
    wire net_U4047_Pad10;
    wire net_U4047_Pad13;
    wire net_U4048_Pad6;
    wire net_U4048_Pad8;
    wire net_U4050_Pad13;
    wire net_U4051_Pad12;
    wire net_U4051_Pad6;
    wire net_U4051_Pad8;
    wire net_U4052_Pad12;
    wire net_U4054_Pad13;
    wire net_U4054_Pad4;
    wire net_U4055_Pad12;
    wire net_U4055_Pad6;
    wire net_U4055_Pad8;
    wire net_U4056_Pad10;
    wire net_U4056_Pad13;
    wire net_U4057_Pad12;
    wire net_U4057_Pad8;
    wire net_U4058_Pad4;
    wire net_U4059_Pad6;
    wire net_U4059_Pad8;
    wire net_U4060_Pad10;
    wire net_U4060_Pad13;
    wire net_U4060_Pad4;
    wire net_U4061_Pad11;
    wire net_U4061_Pad5;
    wire net_U4061_Pad9;
    wire net_U4063_Pad11;

    pullup R4001(net_R4001_Pad2);
    pullup R4002(net_R4002_Pad2);
    pullup R4003(__A04_1__SGUM);
    pullup R3004(net_R3004_Pad2);
    pullup R3005(net_R3005_Pad2);
    pullup R4006(net_R4006_Pad2);
    pullup R4007(net_R4007_Pad2);
    pullup R4008(n5XP11);
    pullup R4011(net_R4011_Pad2);
    pullup R4021(n8PP4);
    U74HC02 #(1'b0, 1'b0, 1'b0, 1'b1) U4001(T12USE_n, DVST, net_U4001_Pad3, DIVSTG, T12USE_n, T03_n, GND, net_U4001_Pad8, net_U4001_Pad9, net_U4001_Pad10, GOJAM, MTCSAI, net_U4001_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b0) U4002(T03_n, T12USE_n, T12USE_n, RSTSTG, GOJAM, net_U4001_Pad3, GND, net_U4001_Pad9, PHS3_n, net_U4001_Pad3, T12_n, net_U4001_Pad8, PHS3_n, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U4003(net_U4001_Pad13, net_R4001_Pad2, net_U4003_Pad3, net_R4001_Pad2, net_U4003_Pad5, net_R4002_Pad2, GND, net_R4002_Pad2, net_U4003_Pad9, __A04_1__SGUM, net_U4003_Pad11, __A04_1__SGUM, net_U4003_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 #(1'b1, 1'b1, 1'b0) U4004(ST1, net_U4004_Pad2, __A04_1__STG1, __A04_1__STG3, __A04_1__STG2, net_U4004_Pad6, GND, net_U4004_Pad8, __A04_1__STG2, __A04_1__STG3, net_U4004_Pad11, net_U4003_Pad3, net_U4004_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4005(net_U4004_Pad13, net_R4001_Pad2, T01, net_U4004_Pad2, __A04_1__DVST_n, __A04_1__STG3, GND, net_U4001_Pad10, net_R4001_Pad2, net_U4005_Pad10, net_U4004_Pad13, net_U4001_Pad10, net_U4005_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b1, 1'b0, 1'b1, 1'b0) U4006(net_U4004_Pad11, net_U4005_Pad10, __A04_1__STG1, __A04_1__STG1, net_U4004_Pad11, net_U4005_Pad13, GND, ST2, net_U4006_Pad9, net_U4003_Pad5, __A04_1__DVST_n, net_U4004_Pad11, net_U4006_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 #(1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0) U4008(net_U4004_Pad6, ST0_n, net_U4004_Pad8, ST1_n, net_U4008_Pad5, ST3_n, GND, __A04_1__ST4_n, net_U4008_Pad9, __A04_1__ST376_n, __A04_1__ST376, DV1376_n, DV1376, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b1, 1'b0, 1'b0) U4009(net_U4006_Pad13, MTCSAI, net_R4002_Pad2, GOJAM, T01, net_U4009_Pad13, GND, net_U4008_Pad5, __A04_1__STG3, net_U4009_Pad10, net_U4004_Pad11, net_U4003_Pad9, net_U4009_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U4010(net_U4006_Pad9, __A04_1__TRSM_n, XT1_n, XB7_n, NDR100_n,  , GND,  , net_U4010_Pad9, STRTFC, T01, RSTSTG, net_U4010_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b1, 1'b0) U4011(net_U4011_Pad1, net_U4001_Pad10, net_R4002_Pad2, net_U4011_Pad12, net_U4009_Pad13, net_U4001_Pad10, GND, net_U4011_Pad1, __A04_1__STG2, net_U4009_Pad10, net_U4009_Pad10, net_U4011_Pad12, __A04_1__STG2, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U4012(net_U4012_Pad1, __A04_1__DVST_n, net_U4009_Pad10, net_U4010_Pad9, net_U4012_Pad1, net_U4010_Pad13, GND, net_U4001_Pad10, net_U4010_Pad9, net_U4012_Pad10, net_U4010_Pad13, net_U4001_Pad10, net_U4012_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b1, 1'b0, 1'b0, 1'b0) U4013(net_U4013_Pad1, net_U4012_Pad10, __A04_1__STG3, __A04_1__STG3, net_U4013_Pad1, net_U4012_Pad13, GND, __A04_1__STG1, __A04_1__STG3, net_U4013_Pad10, net_U4009_Pad10, net_U4013_Pad10, __A04_1__ST376, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U4014(STD2, INKL, __A04_1__STG1, __A04_1__STG3, net_U4009_Pad10,  , GND,  , SQ0_n, EXST1_n, QC3_n, SQR10_n, RUPT1, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4015(net_U4013_Pad1, __A04_1__STG1, QC0_n, SQEXT_n, SQ1_n, net_U4015_Pad6, GND, net_U4003_Pad11, SUMB16_n, SUMA16_n, TSGU_n, net_U4008_Pad9, __A04_1__STG2, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4016(net_U4016_Pad1, net_U4008_Pad9, __A04_1__ST376, DV3764, DIV_n, net_U4016_Pad1, GND, net_U4004_Pad8, __A04_1__ST376, __A04_1__ST1376_n, DIV_n, __A04_1__ST1376_n, DV1376, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 U4017(net_U4015_Pad6, DIV_n, __A04_1__DV0, __A04_1__DV0_n, DV1, DV1_n, GND, DV376_n, __A04_1__DV376, net_U4017_Pad10, TL15, BR1, net_R3004_Pad2, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4018(__A04_1__DV0, DIV_n, ST0_n, DV1, DIV_n, ST1_n, GND, DIV_n, __A04_1__ST4_n, DV4, DIV_n, __A04_1__ST376_n, __A04_1__DV376, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4019(net_U4019_Pad1, SUMA16_n, SUMB16_n, net_U4003_Pad13, PHS4, PHS3_n, GND, UNF_n, TOV_n, net_U4019_Pad10, L15_n, net_U4017_Pad10, net_U4019_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b0, 1'b1) U4020(PHS4_n, WL16_n, net_U4019_Pad13, net_U4020_Pad12, net_R3005_Pad2, net_U4020_Pad6, GND, net_U4020_Pad8, net_R3004_Pad2, net_U4020_Pad10, net_U4020_Pad11, net_U4020_Pad12, TSGN_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4021(net_U4020_Pad10, TSGN_n, PHS3_n, net_U4020_Pad11, net_U4017_Pad10, PHS3_n, GND, TOV_n, PHS2_n, net_U4021_Pad10, __A04_1__SGUM, net_U4019_Pad10, net_U4021_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U4022(net_U4022_Pad1, net_U4019_Pad1, PHS3_n, TSGU_n, PHS4,  , GND,  , WL16_n, WL15_n, WL14_n, WL13_n, net_U4022_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U4023(net_U4021_Pad13, net_R3004_Pad2, net_U4020_Pad6, net_R3004_Pad2, net_U4020_Pad8, net_R3005_Pad2, GND, net_R3005_Pad2, net_U4023_Pad9, net_R4006_Pad2, net_U4022_Pad13, net_R4006_Pad2, net_U4023_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 #(1'b1, 1'b0, 1'b0, 1'b0) U4024(net_U4023_Pad9, net_U4021_Pad10, net_U4022_Pad1, net_U4024_Pad4, TOV_n, OVF_n, GND, net_U4024_Pad8, PHS3_n, net_U4024_Pad10, TMZ_n, PHS4_n, net_U4024_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 U4025(net_R3005_Pad2, BR1_n, __A04_1__TSGN2, net_U4024_Pad8, net_R4007_Pad2, BR2, GND, BR2_n, net_U4025_Pad9, DV4_n, DV4, net_U4025_Pad12, net_U4025_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4026(GEQZRO_n, PHS4_n, WL16_n, PHS4_n, net_U4024_Pad8, net_U4026_Pad6, GND, net_U4026_Pad8, net_U4026_Pad6, net_R4006_Pad2, net_U4025_Pad9, net_U4026_Pad12, TPZG_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U4027(net_U4023_Pad13, WL12_n, WL11_n, WL10_n, WL09_n,  , GND,  , WL08_n, WL07_n, WL06_n, WL05_n, net_U4027_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 #(1'b0, 1'b1) U4028(net_U4028_Pad1, WL04_n, WL03_n, WL02_n, WL01_n,  , GND,  , net_R4007_Pad2, net_U4024_Pad10, net_U4028_Pad11, net_U4021_Pad10, net_U4025_Pad9, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U4029(net_U4027_Pad13, net_R4006_Pad2, net_U4028_Pad1, net_R4006_Pad2, net_U4024_Pad13, net_R4006_Pad2, GND, net_R4007_Pad2, net_U4029_Pad9, net_R4007_Pad2, net_U4026_Pad8,  ,  , p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10
    U74HC02 U4030(net_U4028_Pad11, TMZ_n, PHS3_n, net_U4029_Pad9, net_U4026_Pad12, net_U4024_Pad4, GND, SQ0_n, EXST0_n, net_U4025_Pad13, QC3_n, SQEXT, net_U4030_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4031(net_U4025_Pad12, SQR10, QC0_n, net_U4025_Pad12, SQR10_n, __A04_2__WRITE0, GND, RAND0, SQR10, net_U4025_Pad12, QC1_n, READ0, QC0_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 U4032(READ0, __A04_2__READ0_n, __A04_2__WRITE0, __A04_2__WRITE0_n, WOR0, __A04_2__WOR0_n, GND, RXOR0_n, RXOR0, __A04_2__RUPT0_n, RUPT0, __A04_2__RUPT1_n, RUPT1, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4033(QC1_n, SQR10_n, SQR10, net_U4025_Pad12, QC2_n, ROR0, GND, WOR0, QC2_n, net_U4025_Pad12, SQR10_n, WAND0, net_U4025_Pad12, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4034(SQR10, net_U4025_Pad12, QC3_n, net_U4025_Pad12, SQR10_n, RUPT0, GND, net_U4034_Pad8, ST0_n, SQR12_n, SQ2_n, RXOR0, QC3_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 U4035(net_U4034_Pad8, net_U4035_Pad2, INOUT, INOUT_n, net_R4011_Pad2, net_U4035_Pad6, GND, BR1B2_n, __A04_2__BR1B2, BR12B_n, __A04_2__BR12B, BR1B2B_n, BR1B2B, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4036(PRINC, net_U4030_Pad13, net_U4035_Pad2, RRPA, T03_n, __A04_2__RUPT1_n, GND, T03_n, RXOR0_n, n3XP7, net_U4036_Pad11, T03_n, net_U4036_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4037(EXST0_n, SQ0_n, INOUT, DV4, PRINC, net_U4037_Pad6, GND, net_U4037_Pad8, net_U4036_Pad13, net_U4037_Pad10, net_U4037_Pad11, INOUT, RUPT0, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4038(net_U4036_Pad11, ROR0, WOR0, net_U4038_Pad4, T03_n, net_U4038_Pad10, GND, RAND0, WAND0, net_U4038_Pad10, DV4_n, T05_n, n5XP28, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U4039(net_U4037_Pad8, RB_n, net_U4039_Pad3, RC_n, net_U4039_Pad5, n5XP11, GND, n5XP11, net_U4039_Pad9, RA_n, net_U4039_Pad11, WG_n, net_U4039_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 #(1'b0, 1'b0, 1'b1) U4040(net_U4038_Pad4, net_U4040_Pad2, T05_n, INOUT_n, READ0, net_U4039_Pad5, GND, WCH_n, net_U4040_Pad9, n7XP14, net_U4040_Pad11, net_U4039_Pad3, net_U4040_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4041(net_U4039_Pad9, __A04_2__WRITE0, RXOR0, net_U4037_Pad10, __A04_2__READ0_n, T05_n, GND, __A04_2__WRITE0_n, T05_n, net_U4040_Pad9, T05_n, __A04_2__WOR0_n, net_U4040_Pad11, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4042(net_U4040_Pad2, T05_n, RXOR0_n, net_U4042_Pad4, T02_n, __A04_2__WRITE0_n, GND, T02_n, INOUT_n, n2XP3, T09_n, __A04_2__RUPT0_n, n9XP1, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4043(net_U4040_Pad9, net_U4040_Pad2, RUPT1, IC13, IC12, net_U4043_Pad6, GND, net_U4039_Pad13, n9XP1, net_U4040_Pad13, net_U4037_Pad11, net_U4039_Pad11, n2XP3, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4044(net_U4040_Pad13, T09_n, RXOR0_n, net_U4037_Pad11, T09_n, net_U4043_Pad6, GND, net_U4040_Pad2, net_U4042_Pad4, net_U4044_Pad10, T01_n, __A04_2__RUPT1_n, RB2, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U4045(net_U4044_Pad10, WG_n, net_U4045_Pad3, net_R4011_Pad2, net_U4045_Pad5, net_R4011_Pad2, GND, RA_n, net_U4045_Pad9, WG_n, net_U4045_Pad11, TMZ_n, net_U4045_Pad13, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 U4046(RUPT0, RUPT1, INOUT, MP1, MP3A, net_U4045_Pad3, GND, net_U4045_Pad5, __A04_1__DV0, IC15, DV1376, net_U4046_Pad12, RSM3, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4047(R15, net_U4046_Pad12, T01_n, n1XP10, T01_n, __A04_1__DV0_n, GND, MP0_n, T03_n, net_U4047_Pad10, INOUT_n, T03_n, net_U4047_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4048(T02_n, __A04_1__DV0_n, BRDIF_n, TS0_n, T04_n, net_U4048_Pad6, GND, net_U4048_Pad8, T04_n, BR1, MP0_n, n2XP5, BR1, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4049(n3XP2, T03_n, TS0_n, __A04_2__BR1B2, BR1, BR2_n, GND, BR1_n, BR2, __A04_2__BR12B, __A04_2__BR1B2, __A04_2__BR12B, BRDIF_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4050(BR1B2B, BR2, BR1, n4XP5, TS0_n, T04_n, GND, T04_n, INOUT_n, n4XP11, T04_n, MP3_n, net_U4050_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4051(MP0_n, BR1_n, DV1_n, T04_n, BR2_n, net_U4051_Pad6, GND, net_U4051_Pad8, TS0_n, T05_n, BR1B2_n, net_U4051_Pad12, T04_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4052(T05_n, TS0_n, T07_n, BR1_n, MP3_n, n7XP19, GND, n8XP6, T08_n, DV1_n, BR2, net_U4052_Pad12, BR12B_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4053(B15X, T05_n, DV1_n, n5XP4, T05_n, RSM3_n, GND, T06_n, DV1_n, n6XP5, T06_n, MP3_n, TL15, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4054(__A04_1__TSGN2, T07_n, MP0_n, net_U4054_Pad4, T07_n, DV1_n, GND, T08_n, DV1_n, n8XP5, T09_n, MP3_n, net_U4054_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4055(T09_n, BR1, T09_n, MP0_n, BR1_n, net_U4055_Pad6, GND, net_U4055_Pad8, MP0_n, T09_n, BRDIF_n, net_U4055_Pad12, MP0_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4056(KRPT, T09_n, __A04_2__RUPT1_n, MP0T10, T10_n, MP0_n, GND, net_U4035_Pad6, T02_n, net_U4056_Pad10, STORE1_n, T09_n, net_U4056_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U4057(BR1_n, MP0_n, n1XP10, n8XP5, net_U4054_Pad13, net_U4045_Pad9, GND, net_U4057_Pad8, net_U4051_Pad6, net_U4047_Pad10, net_U4054_Pad4, net_U4057_Pad12, T11_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 #(1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0) U4058(DVST, __A04_1__DVST_n, net_U4057_Pad12, net_U4058_Pad4, TRSM, __A04_1__TRSM_n, GND,  ,  ,  ,  ,  ,  , p4VSW, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b1) U4059( ,  , net_U4047_Pad13, B15X, n7XP19, net_U4059_Pad6, GND, net_U4059_Pad8, n8XP5, net_U4055_Pad12, net_U4055_Pad6,  ,  , p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U4060(net_U4045_Pad13, n2XP5, n1XP10, net_U4060_Pad4, net_U4048_Pad6, net_U4055_Pad8, GND, n1XP10, MP0T10, net_U4060_Pad10, net_U4051_Pad8, net_U4057_Pad12, net_U4060_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U4061(net_U4059_Pad6, WY_n, net_U4059_Pad8, WY_n, net_U4061_Pad5, WL_n, GND, RC_n, net_U4061_Pad9, RB_n, net_U4061_Pad11, CI_n, net_U4060_Pad4, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC27 #(1'b1, 1'b0, 1'b0) U4062(net_U4048_Pad8, net_U4051_Pad12, net_U4051_Pad12, n2XP5, net_U4055_Pad6, net_U4061_Pad9, GND, net_U4061_Pad11, net_U4048_Pad8, n7XP19, net_U4055_Pad12, net_U4061_Pad5, n6XP5, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U4063(net_U4060_Pad10, TSGN_n, net_U4057_Pad8, TSGN_n, net_U4060_Pad13, RB1_n, GND, L16_n, net_U4058_Pad4, R1C_n, net_U4063_Pad11, n8PP4, net_U4037_Pad6, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74HC02 U4064(net_U4063_Pad11, net_U4057_Pad12, net_U4052_Pad12, __A04_2__BRXP3, T03_n, IC15_n, GND,  ,  ,  ,  ,  ,  , p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U4065(RSC_n, net_U4056_Pad10, net_U4050_Pad13, net_U4054_Pad4, __A04_2__BRXP3,  , GND,  , net_U4056_Pad10, net_U4056_Pad13, net_U4050_Pad13, __A04_2__BRXP3, net_U4045_Pad11, p4VSW, SIM_RST, SIM_CLK);
    U74LVC06 U4066(net_U4004_Pad11, MST1, net_U4009_Pad10, MST2, net_U4013_Pad1, MST3, GND, MBR1, net_R3004_Pad2, MBR2, net_R4007_Pad2, MWCH, WCH_n, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74LVC06 U4067(RSC_n, MRSC,  ,  ,  ,  , GND,  ,  ,  ,  ,  ,  , p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2
endmodule