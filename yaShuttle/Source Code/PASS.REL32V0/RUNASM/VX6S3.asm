*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VX6S3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VX6S3--VECTOR CROSS PRODUCT, LENGTH 3, SP'              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VX6S3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* TAKES THE CROSS PRODUCT OF V1 AND V2 WHERE V1 AND V2 ARE SINGLE       00000400
*   PRECISION VECTORS.                                                  00000500
*                                                                       00000600
         INPUT R2,            VECTOR(3) SP                             X00000700
               R3             VECTOR(3) SP                              00000800
         OUTPUT R1            VECTOR(3) SP                              00000900
         WORK  F0,F2                                                    00001000
*                                                                       00001100
* ALGORITHM:                                                            00001200
*   SEE ALGORITHM DESCRIPTION IN VX6D3                                  00001300
*                                                                       00001400
VX6S3X   LE    F0,4(R2)       V2$(2)                                    00001500
         ME    F0,6(R3)       V2$(2) V3$(3)                             00001600
         LE    F2,6(R2)       V2$(3)                                    00001700
         ME    F2,4(R3)       V2$(3) V3$(2)                             00001800
         SEDR  F0,F2          V2$(2) V3$(3) - V2$(3) V3$(2)             00001900
         STE   F0,2(R1)       FIRST ELEMENT OF RESULT                   00002000
         LE    F2,2(R2)       V2$(1)                                    00002100
         ME    F2,6(R3)       V2$(1) V3$(3)                             00002200
         LE    F0,6(R2)       V2$(3)                                    00002300
         ME    F0,2(R3)       V2$(3) V3$(1)                             00002400
         SEDR  F0,F2          V2$(3) V3$(1) - V2$(1) V3$(3)             00002500
         STE   F0,4(R1)       2ND ELEMENT OF RESULT                     00002600
         LE    F0,2(R2)       V2$(1)                                    00002700
         ME    F0,4(R3)       V2$(1) V3$(2)                             00002800
         LE    F2,4(R2)       V2$(2)                                    00002900
         ME    F2,2(R3)       V2$(2) V3$(1)                             00003000
         SEDR  F0,F2          V2$(1) V3$(2) - V2$(2) V3$(1)             00003100
         STE   F0,6(R1)       3RD ELEMENT OF RESULT                     00003200
         AEXIT                                                          00003300
         ACLOSE                                                         00003400
