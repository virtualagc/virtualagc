*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV2DN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV2DN -- VECTOR ADD,LENGTH N,DOUBLE PREC'               00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV2DN     AMAIN INTSIC=YES                                              00000200
*                                                                       00000300
*    COMPUTES THE VECTOR SUM                                            00000400
*                                                                       00000500
*     V(N)=V1(N)+V2(N)                                                  00000600
*                                                                       00000700
*    WHERE N |=3 ,  V,V1,V2 ARE DP                                      00000800
*                                                                       00000900
         INPUT R2,            VECTOR(N)   DP                           X00001000
               R3,            VECTOR(N)   DP                           X00001100
               R5             INTEGER(N)  SP                            00001200
         OUTPUT R1            VECTOR(N)  DP                             00001300
         WORK  F0,F1                                                    00001400
*                                                                       00001500
*   ALGORITHM:                                                          00001600
*   DO FOR I=1 TO N ;                                                   00001700
*     V(I)=V1(I)+V2(I)                                                  00001800
*    END;                                                               00001900
*                                                                       00002000
VV2DNL   LE    F0,4(R3)        2 LE'S INTEAD OF LED TO OVERCOME         00002100
         LE    F1,6(R3)        ADDRESSING INADEQUACIES OF R3            00002200
         AED   F0,4(R2)      GET V ELE.                                 00002300
         STED  F0,4(R1)      PLACE V ELE.                               00002400
         LA    R1,4(R1)                                                 00002500
         LA    R2,4(R2)                                                 00002600
         LA    R3,4(R3)                                                 00002700
$TIM1    BCTB  R5,VV2DNL     I=1 TO N COUNTER                           00002800
         AEXIT                                                          00002900
         ACLOSE                                                         00003000
