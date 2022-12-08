*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV4SN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV4SN -- VECTOR TIMES SCALAR,LENGTH N,SINGLE PREC'      00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV4SN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*  COMPUTES THE VECTOR SCALAR PRODUCT:                                  00000400
*                                                                       00000500
*    V(N)= V1(N) * S                                                    00000600
*                                                                       00000700
*    WHERE N NOT=3 & V,V1,S ARE SP                                      00000800
*                                                                       00000900
         INPUT R2,            VECTOR(N)   SP                           X00001000
               F0,            SCALAR      SP                           X00001100
               R5             INTEGER(N)  SP                            00001200
         OUTPUT R1            VECTOR(N)                                 00001300
         WORK  F2                                                       00001400
*                                                                       00001500
*  ALGORITHM:                                                           00001600
*   DO FOR I=N TO 1;                                                    00001700
*    V(I)=V1(I)*S;                                                      00001800
*   END;                                                                00001900
*                                                                       00002000
VV4SNX   LE    F2,0(R5,R2)   GET V1 ELE.                                00002100
         MER   F2,F0         MUL BY S                                   00002200
         STE   F2,0(R5,R1)   PLACE V ELE.                               00002300
$TIM1    BCTB  R5,VV4SNX     I=N TO 1 COUNTER                           00002400
         AEXIT                                                          00002500
         ACLOSE                                                         00002600
