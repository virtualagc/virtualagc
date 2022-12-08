*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV3D3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'VV3D3--VECTOR SUBTRACT,LENGTH 3,DOUBLE PREC'           00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV3D3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*  COMPUTES THE VECTOR SUBTRACT :                                       00000400
*                                                                       00000500
*    V(3) = V1(3) - V2(3)                                               00000600
*                                                                       00000700
*   WHERE V,V1,V2  ARE DP                                               00000800
*                                                                       00000900
         INPUT R2,            VECTOR(3)   DP                           X00001000
               R3             VECTOR(3)  DP                             00001100
         OUTPUT R1            VECTOR(3)  DP                             00001200
         WORK  F0,F1                                                    00001300
*                                                                       00001400
*   ALGORITHM:                                                          00001500
*    V(1)= V1(1)-V2(1)                                                  00001600
*    V(2)= V1(2)-V2(2)                                                  00001700
*    V(3)= V1(3)-V2(3)                                                  00001800
*                                                                       00001900
         XR    R3,R2         CHANGE BETWEEN R2&R3                       00002000
         XR    R2,R3                                                    00002100
         XR    R3,R2                                                    00002200
         LE    F0,4(R3)      GET V1 ELE.                                00002300
         LE    F1,6(R3)                                                 00002400
         SED   F0,4(R2)      GET V ELE                                  00002500
         STED  F0,4(R1)      PLACE V ELE.                               00002600
         LE    F0,8(R3)                                                 00002700
         LE    F1,10(R3)                                                00002800
         SED   F0,8(R2)                                                 00002900
         STED  F0,8(R1)                                                 00003000
         LE    F0,12(R3)                                                00003100
         LE    F1,14(R3)                                                00003200
         SED   F0,12(R2)                                                00003300
         STED  F0,12(R1)                                                00003400
         AEXIT                                                          00003500
         ACLOSE                                                         00003600
