*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV5DN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV5DN--VECTOR DIVIDED BY SCALAR, LENGTH N, DP'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV5DN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* DIVIDES V1 OR M1 BY A DOUBLE PRECISION SCALAR WHERE V1 IS A DOUBLE    00000400
*   PRECISION VECTOR OF LENGTH N AND M1 IS A DOUBLE PRECISION           00000500
*   MATRIX OF LENGTH N = R S WHERE R AND S ARE THE DIMENSIONS OF        00000600
*   THE MATRIX, WHERE N IS NOT EQUAL TO 3.                              00000700
*                                                                       00000800
         INPUT R2,            VECTOR(N) DP                             X00000900
               R5,            INTEGER(N) SP                            X00001000
               F0,            SCALAR DP                                X00001100
               F1             SCALAR DP                                 00001200
         OUTPUT R1            VECTOR(N) DP                              00001300
         WORK  F2,F3,F4,F5,F6,F7                                        00001400
*                                                                       00001500
* ALGORITHM:                                                            00001600
*   IF F0 = 0 THEN                                                      00001700
*     SEND A DIVIDE BY 0 ERROR;                                         00001800
*   ELSE                                                                00001900
*     DO;                                                               00002000
*       F2 = 1 / F0;                                                    00002100
*       DO FOR I = N TO 1 BY -1;                                        00002200
*         V2$(I) = V1$(I) F2;                                           00002300
*       END;                                                            00002400
*     END;                                                              00002500
*                                                                       00002600
VV5DNL   SEDR  F2,F2          CLEAR F2                                  00002700
        QCEDR  F2,F0          COMPARE INPUT AGAINST 0                   00002800
         LFLI  F2,1           LOAD UP A ONE                             00002900
         BE    AOUT           IF OLD(F0) = 0 THEN SEND AN ERROR         00003000
        IDEDR  F2,F0,F4,F6    TAKE 1 / F0                               00003100
VV5DNX   LED   F0,0(R5,R2)    LOAD ELEMENT OF VECTOR                    00003200
         MEDR  F0,F2          MULTIPLY BY 1 / OLD(F0)                   00003300
         STED  F0,0(R5,R1)    STORE AWAY IS RESULT AREA                 00003400
         BCTB  R5,VV5DNX                                                00003500
OUT      AEXIT                                                          00003600
AOUT     AERROR    25         ATTEMPT TO DIVIDE BY 0                    00003700
         B     VV5DNX                                                   00003800
         ACLOSE                                                         00003900
