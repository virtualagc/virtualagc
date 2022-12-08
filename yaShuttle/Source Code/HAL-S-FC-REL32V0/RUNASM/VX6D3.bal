*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VX6D3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VX6D3--VECTOR CROSS PRODUCT, LENGTH 3 DP'               00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VX6D3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* TAKES THE CROSS PRODUCT OF V1 AND V2 WHERE V1 AND V2 ARE TWO          00000400
*   DOUBLE PRECISION 3 VECTORS.                                         00000500
*                                                                       00000600
         INPUT R2,            VECTOR(3) DP                             X00000700
               R3             VECTOR(3) DP                              00000800
         OUTPUT R1            VECTOR(3) DP                              00000900
         WORK  F0,F1,F2,F3,F4,F5                                        00001000
*                                                                       00001100
* ALGORITHM:                                                            00001200
*   V1$(1) = V2$(2) V3$(3) - V3$(2) V2$(3)                              00001300
*   V1$(2) = V2$(3) V3$(1) - V3$(3) V2$(1)                              00001400
*   V1$(3) = V2$(1) V3$(2) - V3$(1) V2$(2)                              00001500
*                                                                       00001600
         LE    F0,12(R3)                                                00001700
         LE    F1,14(R3)      V3$(3)                                    00001800
         MED   F0,8(R2)       V3$(3) V2$(2)                             00001900
         LE    F2,8(R3)                                                 00002000
         LE    F3,10(R3)      V3$(2)                                    00002100
         MED   F2,12(R2)      V3$(2) V2$(3)                             00002200
         LE    F4,12(R3)                                                00002300
         LE    F5,14(R3)      V3$(3)                                    00002400
         MED   F4,4(R2)       V2$(1) V3$(3)                             00002500
         SEDR  F0,F2          V2$(2) V3$(3) - V3$(2) V2$(3)             00002600
         LE    F2,4(R3)                                                 00002700
         LE    F3,6(R3)       V3$(1)                                    00002800
         MED   F2,12(R2)      V2$(3) V3$(1)                             00002900
         SEDR  F2,F4          V2$(3) V3$(1) - V2$(1) V3$(3)             00003000
         STED  F0,4(R1)       STORE V1$(1)                              00003100
         STED  F2,8(R1)       STORE V1$(2)                              00003200
         LE    F0,8(R3)                                                 00003300
         LE    F1,10(R3)      V3$(2)                                    00003400
         MED   F0,4(R2)       V2$(1) V3$(2)                             00003500
         LE    F2,4(R3)                                                 00003600
         LE    F3,6(R3)       V3$(1)                                    00003700
         MED   F2,8(R2)       V2$(2) V3$(1)                             00003800
         SEDR  F0,F2          V2$(1) V3$(2) - V2$(2) V3$(1)             00003900
         STED  F0,12(R1)                                                00004000
         AEXIT                                                          00004100
         ACLOSE                                                         00004200
