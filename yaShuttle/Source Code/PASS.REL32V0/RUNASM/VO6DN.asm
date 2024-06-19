*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VO6DN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'VO6DN--VECTOR OUTER PRODUCT, LENGTH N, DP'             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VO6DN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* TAKES THE VECTOR OUTER PRODUCT OF V1(N) AND V2(M) WHERE V1 AND V2     00000400
*   ARE DOUBLE PRECISION VECTORS OF LENGTH N AND M RESPECTIVELY, AND    00000500
*   WHERE AT LEAST ONE OF N, M IS NOT EQUAL TO 3.                       00000600
*                                                                       00000700
         INPUT R2,            VECTOR(N) DP                             X00000800
               R3,            VECTOR(M) DP                             X00000900
               R5,            INTEGER(N) SP                            X00001000
               R6             INTEGER(M) SP                             00001100
         OUTPUT R1            MATRIX(N,M) DP                            00001200
         WORK  R7,F0,F1,F4                                              00001300
*                                                                       00001400
* ALGORITHM:                                                            00001500
*   DO FOR I = 1 TO N BY 1;                                             00001600
*     DO FOR J = M TO 1 BY -1;                                          00001700
*       M$(I,J) = V1$(I) V2$(J);                                        00001800
*     END;                                                              00001900
*   END;                                                                00002000
*                                                                       00002100
         LFLR  F4,R6          SAVE M IN F4                              00002200
         LR    R7,R6          PLACE M IN R7                             00002300
         SLL   R7,2           GET # OF HALFWORDS IN V2                  00002400
         XR    R2,R3          SWITCH CONTENTS OF R2 AND R3              00002500
         XR    R3,R2          VECTOR(N) PTR IS NOW IN R3                00002600
         XR    R2,R3                                                    00002700
LOOP1    LE    F0,4(R3)       GET LEFT HALF OF ELEMENT OF V1            00002800
         LE    F1,6(R3)       GET RIGHT HALF OF ELEMENT OF V1           00002900
         MED   F0,0(R6,R2)                                              00003000
         STED  F0,0(R6,R1)                                              00003100
         BCTB  R6,LOOP1                                                 00003200
         LFXR  R6,F4          RESET R6 TO M                             00003300
         LA    R3,4(R3)       SET V1 PTR TO NEXT ELEMENT                00003400
         AR    R1,R7          BUMP OUTPUT PTR TO NEXT ROW               00003500
         BCTB  R5,LOOP1                                                 00003600
         AEXIT                                                          00003700
         ACLOSE                                                         00003800
