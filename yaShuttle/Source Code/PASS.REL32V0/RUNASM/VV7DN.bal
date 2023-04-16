*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV7DN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV7DN -- VECTOR NEGATE,LENGTH N,DOUBLE PREC'            00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV7DN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*  GENERATES THE NEGATIVE OF A VECTOR                                   00000400
*                                                                       00000500
*  V(N) = -V1(N)                                                        00000600
*                                                                       00000700
*   WHERE N NOT=3 & V,V1 ARE DP                                         00000800
*                                                                       00000900
         INPUT R2,            VECTOR(N)   DP                           X00001000
               R5             INTEGER(N)  DP                            00001100
         OUTPUT R1            VECTOR(N)   DP                            00001200
         WORK  F0                                                       00001300
*                                                                       00001400
*  ALGORITHM :                                                          00001500
*   DO FOR I=N TO 1;                                                    00001600
*     V(I)=-V1(I);                                                      00001700
*   END;                                                                00001800
*                                                                       00001900
VV7DNX   LED   F0,0(R5,R2)   GET V1 ELE.                                00002000
         BZ    FX1            WORKAROUND FOR LECR BUG.                  00002100
         LECR  F0,F0         V(I)=-V1(I)                                00002200
FX1      STED  F0,0(R5,R1)   PLACE V  ELE.                              00002300
         BCTB  R5,VV7DNX     I=N TO 1 COUNTER                           00002400
         AEXIT                                                          00002500
         ACLOSE                                                         00002600
