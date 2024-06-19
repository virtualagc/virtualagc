*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV2S3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'VV2S3--VECTOR ADD,LENGTH3,SINGLE PREC'                 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV2S3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*   COMPUTES THE VECTOR SUM :                                           00000400
*    V(3)=V1(3)+V2(3)                                                   00000500
*                                                                       00000600
*     WHERE V,V1,V2  AREW SP                                            00000700
*                                                                       00000800
         INPUT R2,            VECTOR(3)  SP                            X00000900
               R3             VECTOR(3)  SP                             00001000
         OUTPUT R1            VECTOR(3)   SP                            00001100
         WORK  F0,F2,F4                                                 00001200
*                                                                       00001300
*   ALGORITHM:                                                          00001400
*   V(1)=V1(1)+V2(1);                                                   00001500
*   V(2)=V1(2)+V2(2);                                                   00001600
*   V(3)=V1(3)+V2(3);                                                   00001700
*                                                                       00001800
         LE    F0,2(R2)      GET V1 ELE.                                00001900
         LE    F2,4(R2)                                                 00002000
         LE    F4,6(R2)                                                 00002100
         AE    F0,2(R3)      ADD V2 ELE.                                00002200
         AE    F2,4(R3)                                                 00002300
         AE    F4,6(R3)                                                 00002400
         STE   F0,2(R1)      PLACE V ELE.                               00002500
         STE   F2,4(R1)                                                 00002600
         STE   F4,6(R1)                                                 00002700
         AEXIT                                                          00002800
         ACLOSE                                                         00002900
