*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV5SN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV5SN--VECTOR DIVIDED BY SCALAR, LENGTH N, SP'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV5SN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* DIVIDES V1 OR M1 BY A SINGLE PRECISION SCALAR WHERE V1 IS A           00000400
*   SINGLE PRECISION VECTOR OF LENGTH N ANS M1 IS A SINGLE              00000500
*   PRECISION MATRIX OF LENGTH N = R S WHERE R AND S ARE THE            00000600
*   DIMENSIONS OF THE MATRIX, AND WHERE N IS NOT EQUAL TO 3             00000700
*                                                                       00000800
         INPUT R2,            VECTOR(N) SP                             X00000900
               R5,            INTEGER(N) SP                            X00001000
               F0             SCALAR SP                                 00001100
         OUTPUT R1            VECTOR(N) SP                              00001200
         WORK  F2                                                       00001300
*                                                                       00001400
* ALGORITHM:                                                            00001500
*   SEE ALGORITHM DESCRITPTION IN VV5DN                                 00001600
*                                                                       00001700
VV5SNX   LER   F0,F0          SET CONDITION CODE                        00001800
         BZ    VV5SDZ         IF ZERO THEN BRANCH TO SEND ERROR         00001900
VV5SLOP  LE    F2,0(R5,R2)    LOAD ELEMENT FROM INPUT                   00002000
         DER   F2,F0          DIVIDE BY THE SCALAR                      00002100
         STE   F2,0(R5,R1)    STORE THE ELEMENT                         00002200
         BCTB  R5,VV5SLOP                                               00002300
         AEXIT                                                          00002400
VV5SDZ   AERROR 25            ATTEMPT TO DIVIDE BY 0                    00002500
         LFLI  F0,1                                                     00002600
         B     VV5SLOP                                                  00002700
         ACLOSE                                                         00002800
