*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM11DN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'MM11DN--MATRIX TRANSPOSE, LENGTN N, DP'                00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM11DN   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* TO CREATE THE DOUBLE PRECISION TRANSPOSE OF AN N X M MATRIX WHERE     00000400
*   EITHER N AND/OR M ARE NOT EQUAL TO 3                                00000500
*                                                                       00000600
         INPUT R2,            MATRIX(N,M) DP                           X00000700
               R5,            INTEGER(M) SP                            X00000800
               R6             INTEGER(N) SP                             00000900
         OUTPUT R1            MATRIX(M,N) DP                            00001000
         WORK  R3,R7,F0,F2                                              00001100
*                                                                       00001200
* ALGORITHM:                                                            00001300
*   USES TWO LOOPS, ONE NESTED WITHIN THE OTHER.                        00001400
*   OUTER LOOP:                                                         00001500
*     THIS LOOP SETS THE COLUMN OF THE INPUT MATRIX BEING               00001600
*       PROCESSED.                                                      00001700
*   INNER LOOP:                                                         00001800
*     THIS LOOP TAKES AN ELEMENT FROM A COLUMN OF THE INPUT MATRIX      00001900
*       AND PUTS IT IN THE APPROPRIATE ROW OF THE OUTPUT MATRIX.        00002000
*       THE INPUT MATRIX IS WALKED THRU BY COLUMN ELEMENTS AND THE      00002100
*       OUTPUT MATRIX IS WALKED THRU BY ROW ELEMENTS.                   00002200
*                                                                       00002300
         LR    R7,R5          SAVE # OF ROWS OF RESULT                  00002400
         LFLR  F2,R6          SAVE # OF COLUMNS OF RESULT               00002500
ILOOP    SR    R3,R3          SET INDEX REG TO 0                        00002600
JLOOP    LA    R1,4(R1)       BUMP OUTPUT PTR TO NEXT ELEMENT           00002700
         LED   F0,4(R3,R2)                                              00002800
         STED  F0,0(R1)                                                 00002900
         AR    R3,R7          BUMP INDEX REG TO POINT TO NEXT COLUMN    00003000
*                             ELEMENT OF INPUT MATRIX                   00003100
         BCTB  R6,JLOOP                                                 00003200
         LFXR  R6,F2          RESTORE # OF COLUMNS COUNT                00003300
         LA    R2,4(R2)       BUMP INPUT PTR TO FIRST ENTRY OF COLUMN   00003400
*                             BEING PROCESSED                           00003500
         BCTB  R5,ILOOP                                                 00003600
         AEXIT                                                          00003700
         ACLOSE                                                         00003800
