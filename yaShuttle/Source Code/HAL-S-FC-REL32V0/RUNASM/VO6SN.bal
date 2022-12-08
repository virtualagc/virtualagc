*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VO6SN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VO6SN--VECTOR OUTER PRODUCT, LENGTH N, SP'              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VO6SN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* TAKES THE OUTER PRODUCT OF V1(N) AND V2(M) WHERE V1 AND V2 ARE        00000400
*   SINGLE PRECISION VECTORS OF LENGTH N AND M RESPECTIVELY, AND        00000500
*   WHERE AT LEAST ONE OF N, M IS NOT EQUAL TO 3.                       00000600
*                                                                       00000700
         INPUT R2,            VECTOR(N) SP                             X00000800
               R3,            VECTOR(M) SP                             X00000900
               R5,            INTEGER(N) SP                            X00001000
               R6             INTEGER(M) SP                             00001100
         OUTPUT R1            MATRIX(N,M) SP                            00001200
         WORK  R7,F0,F4                                                 00001300
*                                                                       00001400
* ALGORITHM:                                                            00001500
*   SEE ALGORITHM DESCRIPTION IN VO6DN                                  00001600
*                                                                       00001700
         LR    R7,R6          PLACE M IN R7                             00001800
         SLL   R7,1           GET # HALFWORDS IN V2                     00001900
         LFLR  F4,R6          SAVE M IN F4                              00002000
         XR    R2,R3          SWITCH PTRS IN R3 AND R2                  00002100
         XR    R3,R2                                                    00002200
         XR    R2,R3                                                    00002300
         NOPR  R1             NOP TO ALIGN ME AND STE ON EVEN           00002400
*                             BOUNDARIES                                00002500
LOOP1    LE    F0,2(R3)                                                 00002600
         ME    F0,0(R6,R2)                                              00002700
         STE   F0,0(R6,R1)                                              00002800
         BCTB  R6,LOOP1                                                 00002900
         LA    R3,2(R3)                                                 00003000
         LFXR  R6,F4          RESET R6 TO M                             00003100
         AR    R1,R7          BUMP OUTPUT PTR TO NEXT ROW               00003200
         BCTB  R5,LOOP1                                                 00003300
         AEXIT                                                          00003400
         ACLOSE                                                         00003500
