*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM15DN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM15DN--SQUARE IDENTITY MATRIX, DP'                     00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM15DN   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* CREATES AN N X N DOUBLE PRECISION IDENTITY MATRIX WHERE N IS >= 2.    00000400
*                                                                       00000500
         INPUT R5             INTEGER(N) SP                             00000600
         OUTPUT R1            MATRIX(N,N) DP                            00000700
         WORK  R6,R7,F0,F2,F3                                           00000800
*                                                                       00000900
* ALGORITHM:                                                            00001000
*   USES TWO LOOPS, ONE NESTED WITHIN THE OTHER.                        00001100
*   OUTER LOOP:                                                         00001200
*     COUNTS THRU THE ROWS OF THE MATRIX.                               00001300
*   INNER LOOP:                                                         00001400
*     COUNTS THRU THE COLUMNS OF THE MATRIX STORING ZEROES EXCEPT       00001500
*       WHEN ROW INDEX = COLUMN INDEX, THEN STORES A ONE.               00001600
*                                                                       00001700
         SEDR  F0,F0          PLACE A 0 IN F0                           00001800
         SER   F3,F3          CLEAR RHS OF F2                           00001900
         LFLI  F2,1           PLACE A 1 IN F1                           00002000
         LR    R6,R5          R6 IS THE OUTER LOOP COUNTER              00002100
CLOOP    LR    R7,R5          OBTAIN N FROM R5 FOR INNER LOOP           00002200
RLOOP    CR    R7,R6                                                    00002300
         BNE   LOADZ          IF INDICES NOT EQUAL THEN STORE 0         00002400
LOADW    STED  F2,4(R1)                                                 00002500
         B     LOOP                                                     00002600
LOADZ    STED  F0,4(R1)                                                 00002700
LOOP     LA    R1,4(R1)                                                 00002800
         BCTB  R7,RLOOP                                                 00002900
         BCTB  R6,CLOOP                                                 00003000
         AEXIT                                                          00003100
         ACLOSE                                                         00003200
