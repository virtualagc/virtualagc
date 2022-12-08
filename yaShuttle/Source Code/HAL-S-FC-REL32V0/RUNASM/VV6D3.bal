*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV6D3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'VV6D3--VECTOR DOT PRODUCT,LENGTH 3,DBLE PREC'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV6D3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*   COMPUTES THE DOT PRODUCT :                                          00000400
*                                                                       00000500
*    S = V1(3) . V2(3)                                                  00000600
*                                                                       00000700
*   WHERE S,V1,V2  ARE DP                                               00000800
*                                                                       00000900
         INPUT R2,            VECTOR(3)  DP                            X00001000
               R3             VECTOR(3)  DP                             00001100
         OUTPUT F0            SCALAR     DP                             00001200
         WORK  F1,F2,F3                                                 00001300
*                                                                       00001400
*   ALGORITHM :                                                         00001500
*   S=V1(1)V2(1)+V1(2)V2(2)+V1(3)V2(3);                                 00001600
*                                                                       00001700
         LE    F0,4(R3)      GET V1(1) ELE.                             00001800
         LE    F1,6(R3)                                                 00001900
         MED   F0,4(R2)      MUL BY V2(1)                               00002000
         LE    F2,8(R3)                                                 00002100
         LE    F3,10(R3)                                                00002200
         MED   F2,8(R2)                                                 00002300
         AEDR  F0,F2         GET V(1)V2(1)+V1(2)V2(2)                   00002400
         LE    F2,12(R3)                                                00002500
         LE    F3,14(R3)                                                00002600
         MED   F2,12(R2)                                                00002700
         AEDR  F0,F2         GET S                                      00002800
         AEXIT                                                          00002900
         ACLOSE                                                         00003000
