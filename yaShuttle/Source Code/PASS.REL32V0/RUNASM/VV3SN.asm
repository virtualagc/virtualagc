*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV3SN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV3SN -- VECTOR SUBTRACT,LENGTH N,SINGLE PREC'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV3SN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*   COMPUTES THE VECTOR SUBTRACT:                                       00000400
*                                                                       00000500
*    V(N)= V1(N) - V2(N)                                                00000600
*                                                                       00000700
*   WHERE N NOT=3  V,V1,V2 ARE SP                                       00000800
*                                                                       00000900
         INPUT R2,            VECTOR(N)   SP                           X00001000
               R3,            VECTOR(N)   SP                           X00001100
               R5             INTEGER(N)  SP                            00001200
         OUTPUT R1            VECTOR(N)    SP                           00001300
         WORK  F0                                                       00001400
*                                                                       00001500
*  ALGORITHM :                                                          00001600
*   DO FOR I=1 TO N ;                                                   00001700
*    V(I)=V1(I)-V2(I);                                                  00001800
*   END;                                                                00001900
*                                                                       00002000
VV3SNX   LE    F0,2(R2)      GET V1 ELE.                                00002100
         SE    F0,2(R3)      GET V ELE.                                 00002200
         STE   F0,2(R1)      PLACE V ELE.                               00002300
         LA    R2,2(R2)      BUMP PTR BY 2                              00002400
         LA    R3,2(R3)                                                 00002500
         LA    R1,2(R1)                                                 00002600
$TIM1    BCTB  R5,VV3SNX     I=1 TO N COUNTER                           00002700
         AEXIT                                                          00002800
         ACLOSE                                                         00002900
