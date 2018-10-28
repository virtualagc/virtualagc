`timescale 1ns/1ps
`default_nettype none

module timer(SIM_RST, SIM_CLK, p4VDC, p4VSW, GND, CLOCK, ALGA, STRT1, STRT2, MSTP, MSTRTP, SBY, GOJ1, WL15, WL15_n, WL16, WL16_n, CLK, GOJAM, STOP, PHS2_n, PHS3_n, PHS4, PHS4_n, CT, CT_n, RT_n, WT_n, TT_n, P02, P02_n, P03, P03_n, P04_n, SB0_n, SB1_n, SB2, SB2_n, SB4, FS01, FS01_n, F01A, F01B, T01, T01_n, T02, T02_n, T03, T03_n, T04, T04_n, T05, T05_n, T06, T06_n, T07, T07_n, T08, T08_n, T09, T09_n, T10, T10_n, T11, T11_n, T12, T12_n, T12A, TIMR, OVF_n, UNF_n, MGOJAM, MSTPIT_n, MT01, MT02, MT03, MT04, MT05, MT06, MT07, MT08, MT09, MT10, MT11, MT12, MONWT);
    input wire SIM_RST;
    input wire SIM_CLK;
    input wire p4VDC;
    input wire p4VSW;
    input wire GND;
    input wire ALGA;
    output wire CLK;
    input wire CLOCK;
    output wire CT;
    output wire CT_n;
    output wire F01A;
    output wire F01B;
    output wire FS01;
    output wire FS01_n;
    input wire GOJ1;
    output wire GOJAM;
    wire GOJAM_n;
    output wire MGOJAM; //FPGA#wand
    output wire MONWT; //FPGA#wand
    input wire MSTP;
    output wire MSTPIT_n; //FPGA#wand
    input wire MSTRTP;
    output wire MT01; //FPGA#wand
    output wire MT02; //FPGA#wand
    output wire MT03; //FPGA#wand
    output wire MT04; //FPGA#wand
    output wire MT05; //FPGA#wand
    output wire MT06; //FPGA#wand
    output wire MT07; //FPGA#wand
    output wire MT08; //FPGA#wand
    output wire MT09; //FPGA#wand
    output wire MT10; //FPGA#wand
    output wire MT11; //FPGA#wand
    output wire MT12; //FPGA#wand
    output wire OVF_n;
    wire P01;
    wire P01_n;
    output wire P02;
    output wire P02_n;
    output wire P03;
    output wire P03_n;
    wire P04;
    output wire P04_n;
    wire P05;
    wire P05_n;
    wire PHS2;
    output wire PHS2_n;
    output wire PHS3_n;
    output wire PHS4;
    output wire PHS4_n;
    wire RT;
    output wire RT_n;
    output wire SB0_n;
    output wire SB1_n;
    output wire SB2;
    output wire SB2_n;
    output wire SB4;
    input wire SBY;
    output wire STOP;
    wire STOPA;
    wire STOP_n;
    input wire STRT1;
    input wire STRT2;
    output wire T01;
    output wire T01_n;
    output wire T02;
    output wire T02_n;
    output wire T03;
    output wire T03_n;
    output wire T04;
    output wire T04_n;
    output wire T05;
    output wire T05_n;
    output wire T06;
    output wire T06_n;
    output wire T07;
    output wire T07_n;
    output wire T08;
    output wire T08_n;
    output wire T09;
    output wire T09_n;
    output wire T10;
    output wire T10_n;
    output wire T11;
    output wire T11_n;
    output wire T12;
    output wire T12A;
    output wire T12_n;
    output wire TIMR;
    output wire TT_n;
    output wire UNF_n;
    input wire WL15;
    input wire WL15_n;
    input wire WL16;
    input wire WL16_n;
    wire WT;
    output wire WT_n;
    wire __A02_1__EVNSET_n;
    wire __A02_1__ODDSET_n;
    wire __A02_1__OVFSTB_n;
    wire __A02_1__Q2A; //FPGA#wand
    wire __A02_1__RINGA_n;
    wire __A02_1__RINGB_n;
    wire __A02_1__cdiv_1__A;
    wire __A02_1__cdiv_1__B;
    wire __A02_1__cdiv_1__D;
    wire __A02_1__cdiv_1__FS;
    wire __A02_1__cdiv_1__FS_n;
    wire __A02_1__cdiv_2__A;
    wire __A02_1__cdiv_2__B;
    wire __A02_1__cdiv_2__C;
    wire __A02_1__cdiv_2__D;
    wire __A02_1__cdiv_2__F;
    wire __A02_1__cdiv_2__FS;
    wire __A02_1__cdiv_2__FS_n;
    wire __A02_1__evnset;
    wire __A02_1__oddset;
    wire __A02_1__ovfstb_r1;
    wire __A02_1__ovfstb_r2;
    wire __A02_1__ovfstb_r3;
    wire __A02_1__ovfstb_r4;
    wire __A02_1__ovfstb_r5;
    wire __A02_1__ovfstb_r6;
    wire __A02_2__EDSET;
    wire __A02_2__F01C;
    wire __A02_2__F01D;
    wire __A02_2__SB0;
    wire __A02_2__SB1;
    wire __A02_2__T12DC_n;
    wire __A02_3__OVF;
    wire __A02_3__T01DC_n;
    wire __A02_3__T02DC_n;
    wire __A02_3__T03DC_n;
    wire __A02_3__T04DC_n;
    wire __A02_3__T05DC_n;
    wire __A02_3__T06DC_n;
    wire __A02_3__T07DC_n;
    wire __A02_3__T08DC_n;
    wire __A02_3__T09DC_n;
    wire __A02_3__T10DC_n;
    wire __A02_3__T12SET; //FPGA#wand
    wire __A02_3__UNF;
    wire net_R2001_Pad2; //FPGA#wand
    wire net_U2024_Pad10;
    wire net_U2024_Pad13;
    wire net_U2024_Pad4;
    wire net_U2024_Pad6;
    wire net_U2025_Pad11;
    wire net_U2026_Pad1;
    wire net_U2026_Pad13;
    wire net_U2027_Pad10;
    wire net_U2028_Pad10;
    wire net_U2028_Pad2;
    wire net_U2028_Pad4;
    wire net_U2029_Pad11;
    wire net_U2030_Pad1;
    wire net_U2031_Pad10;
    wire net_U2031_Pad2;
    wire net_U2031_Pad4;
    wire net_U2032_Pad1;
    wire net_U2032_Pad13;
    wire net_U2033_Pad10;
    wire net_U2034_Pad10;
    wire net_U2034_Pad11;
    wire net_U2034_Pad2;
    wire net_U2034_Pad4;
    wire net_U2035_Pad4;
    wire net_U2036_Pad1;
    wire net_U2037_Pad12;
    wire net_U2037_Pad6;
    wire net_U2037_Pad8;
    wire net_U2038_Pad1;
    wire net_U2042_Pad9;
    wire net_U2043_Pad1;
    wire net_U2043_Pad4;
    wire net_U2044_Pad10;
    wire net_U2103_Pad11;
    wire net_U2107_Pad10;
    wire net_U2111_Pad12;
    wire net_U2111_Pad6;
    wire net_U2111_Pad8;
    wire net_U2112_Pad10;
    wire net_U2112_Pad13;
    wire net_U2113_Pad13;
    wire net_U2114_Pad10;
    wire net_U2114_Pad13;
    wire net_U2115_Pad10;
    wire net_U2115_Pad13;
    wire net_U2116_Pad10;
    wire net_U2116_Pad12;
    wire net_U2116_Pad13;
    wire net_U2119_Pad10;
    wire net_U2119_Pad12;
    wire net_U2119_Pad6;
    wire net_U2119_Pad8;
    wire net_U2122_Pad1;
    wire net_U2122_Pad9;
    wire net_U2123_Pad1;
    wire net_U2123_Pad10;

    pullup R2001(net_R2001_Pad2);
    pullup R2002(__A02_3__T12SET);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U2101(__A02_1__cdiv_1__D, __A02_1__cdiv_1__FS_n, __A02_1__cdiv_1__B, __A02_1__cdiv_1__FS_n, __A02_1__cdiv_1__B, __A02_1__cdiv_1__FS, GND, __A02_1__cdiv_1__FS_n, __A02_1__cdiv_1__A, __A02_1__cdiv_1__FS, __A02_1__cdiv_1__A, __A02_1__cdiv_1__FS, PHS2, p4VDC, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b0) U2102(__A02_1__cdiv_1__D, CLOCK, __A02_1__cdiv_1__B, CLOCK, PHS2, __A02_1__cdiv_1__A, GND, __A02_2__EDSET, P02, P03_n, P04, __A02_1__cdiv_1__B, __A02_1__cdiv_1__A, p4VDC, SIM_RST, SIM_CLK);
    U74HC04 #(1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1) U2103(__A02_1__cdiv_1__D, __A02_1__cdiv_2__F, PHS2, PHS2_n, PHS4, PHS4_n, GND, net_U2103_Pad11, __A02_1__cdiv_1__B, CT, net_U2103_Pad11, CT_n, CT, p4VDC, SIM_RST, SIM_CLK);
    U74HC02 U2104(PHS4, __A02_1__cdiv_2__F, __A02_1__cdiv_1__A, __A02_1__oddset, STOP, __A02_1__RINGA_n, GND, P02_n, P04, SB4, P02_n, P05, __A02_2__SB0, p4VDC, SIM_RST, SIM_CLK);
    U74HC04 #(1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1) U2105(__A02_1__cdiv_1__FS_n, WT, WT, WT_n, WT, TT_n, GND, __A02_1__ovfstb_r5, __A02_1__ovfstb_r4, __A02_1__ovfstb_r6, __A02_1__ovfstb_r5, __A02_1__OVFSTB_n, __A02_1__ovfstb_r2, p4VDC, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U2106(__A02_1__cdiv_2__D, __A02_1__cdiv_2__FS_n, __A02_1__cdiv_2__B, __A02_1__cdiv_2__FS_n, __A02_1__cdiv_2__B, __A02_1__cdiv_2__FS, GND, __A02_1__cdiv_2__FS_n, __A02_1__cdiv_2__A, __A02_1__cdiv_2__FS, __A02_1__cdiv_2__A, __A02_1__cdiv_2__FS, __A02_1__cdiv_2__C, p4VDC, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b0) U2107(__A02_1__cdiv_2__D, __A02_1__cdiv_2__F, __A02_1__cdiv_2__B, __A02_1__cdiv_2__F, __A02_1__cdiv_2__C, __A02_1__cdiv_2__A, GND, P03, __A02_2__EDSET, net_U2107_Pad10, P03_n, __A02_1__cdiv_2__B, __A02_1__cdiv_2__A, p4VDC, SIM_RST, SIM_CLK);
    U74HC04 #(1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0) U2108(__A02_1__cdiv_2__D, __A02_1__RINGA_n, __A02_1__oddset, __A02_1__ODDSET_n, __A02_1__cdiv_2__C, __A02_1__RINGB_n, GND, __A02_1__evnset, __A02_1__RINGB_n, __A02_1__EVNSET_n, __A02_1__evnset, RT, __A02_1__cdiv_1__A, p4VDC, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b0, 1'b1) U2109(__A02_1__ovfstb_r1, CT_n, __A02_1__ovfstb_r2, __A02_1__ovfstb_r2, __A02_1__ovfstb_r6, __A02_1__ovfstb_r1, GND, __A02_1__ovfstb_r4, __A02_1__ovfstb_r2, __A02_1__ovfstb_r3, __A02_1__ovfstb_r3, __A02_1__ovfstb_r1, __A02_1__ovfstb_r4, p4VDC, SIM_RST, SIM_CLK);
    U74HC04 #(1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0) U2110(CT, PHS3_n, WT_n, CLK,  ,  , GND,  ,  , RT_n, RT,  ,  , p4VDC, SIM_RST, SIM_CLK);
    U74HC27 U2111(__A02_1__RINGB_n, P05_n, P04, P05, __A02_1__RINGA_n, net_U2111_Pad6, GND, net_U2111_Pad8, __A02_2__T12DC_n, net_R2001_Pad2, __A02_1__EVNSET_n, net_U2111_Pad12, P04_n, p4VDC, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U2112(P01, net_U2111_Pad12, P01_n, P01_n, P01, net_U2111_Pad6, GND, __A02_1__RINGA_n, P01, net_U2112_Pad10, P01_n, __A02_1__RINGB_n, net_U2112_Pad13, p4VDC, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U2113(P02, net_U2112_Pad10, P02_n, P02_n, P02, net_U2112_Pad13, GND, __A02_1__RINGB_n, P02, net_U2107_Pad10, P02_n, __A02_1__RINGA_n, net_U2113_Pad13, p4VDC, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U2114(__A02_2__SB1, P05_n, P03_n, P03_n, P03, net_U2113_Pad13, GND, __A02_1__RINGA_n, P03, net_U2114_Pad10, P03_n, __A02_1__RINGB_n, net_U2114_Pad13, p4VDC, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U2115(P04, net_U2114_Pad10, P04_n, P04_n, P04, net_U2114_Pad13, GND, __A02_1__RINGB_n, P04, net_U2115_Pad10, P04_n, __A02_1__RINGA_n, net_U2115_Pad13, p4VDC, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U2116(P05, net_U2115_Pad10, P05_n, P05_n, P05, net_U2115_Pad13, GND, net_R2001_Pad2, GOJ1, net_U2116_Pad10, __A02_1__EVNSET_n, net_U2116_Pad12, net_U2116_Pad13, p4VDC, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U2117(__A02_2__F01D, FS01_n, F01B, FS01_n, F01B, FS01, GND, FS01_n, F01A, FS01, F01A, FS01, __A02_2__F01C, p4VDC, SIM_RST, SIM_CLK);
    U74HC27 #(1'b0, 1'b1, 1'b0) U2118(__A02_2__F01D, P01_n, F01B, P01_n, __A02_2__F01C, F01A, GND,  ,  ,  ,  , F01B, F01A, p4VDC, SIM_RST, SIM_CLK);
    U74HC27 #(1'b1, 1'b1, 1'b0) U2119(SBY, ALGA, STRT1, STRT2, net_U2116_Pad10, net_U2119_Pad6, GND, net_U2119_Pad8, __A02_2__T12DC_n, net_U2119_Pad10, __A02_1__EVNSET_n, net_U2119_Pad12, MSTRTP, p4VDC, SIM_RST, SIM_CLK);
    U74LVC07 U2120(net_U2119_Pad12, net_R2001_Pad2, net_U2119_Pad6, net_R2001_Pad2,  ,  , GND,  ,  ,  ,  ,  ,  , p4VDC, SIM_RST, SIM_CLK); //FPGA#OD:2,4
    U74HC04 #(1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0) U2121(net_R2001_Pad2, net_U2116_Pad12, MSTP, net_U2119_Pad10, GOJAM_n, GOJAM, GND,  ,  , STOP, STOP_n,  ,  , p4VDC, SIM_RST, SIM_CLK);
    U74HC02 U2122(net_U2122_Pad1, __A02_1__EVNSET_n, MSTP, GOJAM_n, STRT2, STOPA, GND, STOPA, net_U2122_Pad9, STOP_n, P05_n, P02, SB2, p4VDC, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b1) U2123(net_U2123_Pad1, net_U2111_Pad8, STOPA, STOPA, net_U2123_Pad1, net_U2116_Pad13, GND, net_U2119_Pad8, net_U2122_Pad9, net_U2123_Pad10, net_U2123_Pad10, net_U2122_Pad1, net_U2122_Pad9, p4VDC, SIM_RST, SIM_CLK);
    U74HC27 #(1'b1, 1'b0, 1'b0) U2024(__A02_3__T12SET, GOJAM, __A02_3__T01DC_n, net_U2024_Pad4, GOJAM, net_U2024_Pad6, GND, net_U2024_Pad4, __A02_3__T02DC_n, net_U2024_Pad10, GOJAM, __A02_2__T12DC_n, net_U2024_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b0, 1'b1) U2025(net_U2024_Pad13, __A02_2__T12DC_n, net_U2024_Pad6, net_U2025_Pad11, __A02_2__T12DC_n, __A02_1__ODDSET_n, GND, __A02_2__T12DC_n, __A02_1__EVNSET_n, T12, net_U2025_Pad11, net_U2024_Pad6, __A02_3__T01DC_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b1, 1'b0) U2026(net_U2026_Pad1, __A02_3__T01DC_n, __A02_1__EVNSET_n, T01, __A02_3__T01DC_n, __A02_1__ODDSET_n, GND, net_U2026_Pad1, net_U2024_Pad4, __A02_3__T02DC_n, __A02_3__T02DC_n, __A02_1__ODDSET_n, net_U2026_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U2027(T02, __A02_3__T02DC_n, __A02_1__EVNSET_n, __A02_3__T03DC_n, net_U2026_Pad13, net_U2024_Pad10, GND, __A02_3__T03DC_n, __A02_1__EVNSET_n, net_U2027_Pad10, __A02_3__T03DC_n, __A02_1__ODDSET_n, T03, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U2028(__A02_3__T03DC_n, net_U2028_Pad2, __A02_3__T04DC_n, net_U2028_Pad4, GOJAM, net_U2028_Pad2, GND, net_U2028_Pad4, __A02_3__T05DC_n, net_U2028_Pad10, GOJAM, net_U2024_Pad10, GOJAM, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b1, 1'b0, 1'b0, 1'b1) U2029(__A02_3__T04DC_n, net_U2027_Pad10, net_U2028_Pad2, net_U2029_Pad11, __A02_3__T04DC_n, __A02_1__ODDSET_n, GND, __A02_3__T04DC_n, __A02_1__EVNSET_n, T04, net_U2029_Pad11, net_U2028_Pad4, __A02_3__T05DC_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b1, 1'b0) U2030(net_U2030_Pad1, __A02_3__T05DC_n, __A02_1__EVNSET_n, T05, __A02_3__T05DC_n, __A02_1__ODDSET_n, GND, net_U2028_Pad10, net_U2030_Pad1, __A02_3__T06DC_n, __A02_1__EVNSET_n, __A02_3__T06DC_n, T06, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U2031(GOJAM, net_U2031_Pad2, GOJAM, net_U2031_Pad4, __A02_3__T07DC_n, net_U2031_Pad2, GND, net_U2031_Pad4, GOJAM, net_U2031_Pad10, __A02_3__T08DC_n, net_U2028_Pad10, __A02_3__T06DC_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U2032(net_U2032_Pad1, __A02_1__ODDSET_n, __A02_3__T06DC_n, __A02_3__T07DC_n, net_U2031_Pad2, net_U2032_Pad1, GND, __A02_1__ODDSET_n, __A02_3__T07DC_n, T07, __A02_1__EVNSET_n, __A02_3__T07DC_n, net_U2032_Pad13, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b1, 1'b0, 1'b0, 1'b1) U2033(__A02_3__T08DC_n, net_U2031_Pad4, net_U2032_Pad13, T08, __A02_1__EVNSET_n, __A02_3__T08DC_n, GND, __A02_1__ODDSET_n, __A02_3__T08DC_n, net_U2033_Pad10, net_U2031_Pad10, net_U2033_Pad10, __A02_3__T09DC_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U2034(GOJAM, net_U2034_Pad2, GOJAM, net_U2034_Pad4, __A02_3__T10DC_n, net_U2034_Pad2, GND, net_U2034_Pad4, GOJAM, net_U2034_Pad10, net_U2034_Pad11, net_U2031_Pad10, __A02_3__T09DC_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b0, 1'b1, 1'b0) U2035(T09, __A02_1__ODDSET_n, __A02_3__T09DC_n, net_U2035_Pad4, __A02_1__EVNSET_n, __A02_3__T09DC_n, GND, net_U2034_Pad2, net_U2035_Pad4, __A02_3__T10DC_n, __A02_1__EVNSET_n, net_U2034_Pad2, net_U2034_Pad10, p4VSW, SIM_RST, SIM_CLK);
    U74HC02 #(1'b0, 1'b1, 1'b0, 1'b0) U2036(net_U2036_Pad1, __A02_1__ODDSET_n, __A02_3__T10DC_n, net_U2034_Pad11, net_U2034_Pad4, net_U2036_Pad1, GND, __A02_1__EVNSET_n, __A02_3__T10DC_n, T10, __A02_1__ODDSET_n, net_U2034_Pad11, T11, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U2037(net_U2028_Pad4, net_U2028_Pad2, net_U2031_Pad10, net_U2034_Pad2, __A02_1__EVNSET_n, net_U2037_Pad6, GND, net_U2037_Pad8, net_U2028_Pad10, net_U2031_Pad2, net_U2031_Pad4, net_U2037_Pad12, net_U2024_Pad10, p4VSW, SIM_RST, SIM_CLK);
    U74LVC07 U2038(net_U2038_Pad1, __A02_3__T12SET, net_U2037_Pad12, __A02_3__T12SET, net_U2037_Pad6, __A02_3__T12SET, GND, __A02_3__T12SET, net_U2037_Pad8,  ,  ,  ,  , p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8
    U74HC04 #(1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1) U2039(T01, T01_n, T02, T02_n, T03, T03_n, GND, T04_n, T04, T05_n, T05, T06_n, T06, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 #(1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1) U2040(T07, T07_n, T08, T08_n, T09, T09_n, GND, T10_n, T10, T11_n, T11, T12_n, T12, p4VSW, SIM_RST, SIM_CLK);
    U74HC27 U2041(WL15_n, WL16, __A02_1__OVFSTB_n, WL15, WL16_n, __A02_3__UNF, GND,  ,  ,  ,  , __A02_3__OVF, __A02_1__OVFSTB_n, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 U2042(__A02_3__OVF, OVF_n, __A02_3__UNF, UNF_n, T12_n, T12A, GND, TIMR, net_U2042_Pad9,  ,  ,  ,  , p4VSW, SIM_RST, SIM_CLK);
    U74HC4002 U2043(net_U2043_Pad1, P04, P05_n, net_U2043_Pad4, STOP_n,  , GND,  ,  ,  ,  ,  ,  , p4VSW, SIM_RST, SIM_CLK);
    U74HC02 U2044(net_U2038_Pad1, net_U2024_Pad4, net_U2024_Pad6, net_U2043_Pad4, P01, net_U2044_Pad10, GND, net_U2043_Pad4, STOP_n, net_U2044_Pad10, STRT2, net_U2043_Pad1, net_U2042_Pad9, p4VSW, SIM_RST, SIM_CLK);
    U74HC04 #(1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0) U2145(__A02_2__SB0, SB0_n, __A02_2__SB1, SB1_n, SB2, SB2_n, GND,  ,  ,  ,  ,  ,  , p4VDC, SIM_RST, SIM_CLK);
    U74LVC06 U2046(T01_n, MT01, T02_n, MT02, T03_n, MT03, GND, MT04, T04_n, MT05, T05_n, MT06, T06_n, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74LVC06 U2047(T07_n, MT07, T08_n, MT08, T09_n, MT09, GND, MT10, T10_n, MT11, T11_n, MT12, T12_n, p4VSW, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8,10,12
    U74LVC06 U2148(WT_n, MONWT, WT_n, __A02_1__Q2A, GOJAM_n, MGOJAM, GND, MSTPIT_n, STOP,  ,  ,  ,  , p4VDC, SIM_RST, SIM_CLK); //FPGA#OD:2,4,6,8
endmodule