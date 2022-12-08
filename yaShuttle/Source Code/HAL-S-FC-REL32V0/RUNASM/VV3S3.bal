*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV3S3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV3S3--VECTOR SUBTRACT,LENGTH3,SINGLE PREC'             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV3S3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*    COMPUTES THE VECTOR SUBTRACT :                                     00000400
*                                                                       00000500
*      V(3) = V1(3) - V2(3)                                             00000600
*                                                                       00000700
*      WHERE V,V1,V2 ARE SP                                             00000800
*                                                                       00000900
         INPUT R2,            VECTOR(3)  SP                            X00001000
               R3             VECTOR(3)  SP                             00001100
         OUTPUT R1            VECTOR(3)  SP                             00001200
         WORK  F0,F2,F4                                                 00001300
*                                                                       00001400
*   ALGORITHM :                                                         00001500
*   V(1)=V1(1)-V2(1);                                                   00001600
*   V(2)=V1(2)-V2(2);                                                   00001700
*   V(3)=V1(3)-V2(3);                                                   00001800
*                                                                       00001900
VV3S3X   LE    F0,2(R2)      GET V1 ELE.                                00002000
         LE    F2,4(R2)                                                 00002100
         LE    F4,6(R2)                                                 00002200
         SE    F0,2(R3)      GET V ELE.                                 00002300
         SE    F2,4(R3)                                                 00002400
         SE    F4,6(R3)                                                 00002500
         STE   F0,2(R1)      PLACE V ELE.                               00002600
         STE   F2,4(R1)                                                 00002700
         STE   F4,6(R1)                                                 00002800
         AEXIT                                                          00002900
         ACLOSE                                                         00003000
