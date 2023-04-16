*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV6DN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'VV6DN--VECTOR DOT PRODUCT,LENGTH N,DOUBLE PREC'        00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV6DN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*   COMPUTES THE DOT PRODUCT:                                           00000400
*                                                                       00000500
*    S = V1 . V2                                                        00000600
*                                                                       00000700
*  WHERE LENGTH V1,V2 NOT=3  S,V1,V2 ARE DP                             00000800
*                                                                       00000900
         INPUT R2,            VECTOR(N)   DP                           X00001000
               R3,            VECTOR(N)   DP                           X00001100
               R5             INTEGER(N)  SP                            00001200
         OUTPUT F0            SCALAR     DP                             00001300
         WORK  F2,F3,R1                                                 00001400
*                                                                       00001500
*  ALGORITHM :                                                          00001600
*  DO FOR I=N TO 1;                                                     00001700
*   S=S+V1(I)*V2(I);                                                    00001800
*  END;                                                                 00001900
*                                                                       00002000
         SEDR  F0,F0                                                    00002100
$TIM1    LR    R1,R3                                                    00002200
VV6DNL   LED   F2,0(R5,R1)    GET V1 ELE.                               00002300
         MED   F2,0(R5,R2)                                              00002400
         AEDR  F0,F2                                                    00002500
$TIM2    BCTB  R5,VV6DNL     I=N TO 1 COUNTER                           00002600
         AEXIT                                                          00002700
         ACLOSE                                                         00002800
