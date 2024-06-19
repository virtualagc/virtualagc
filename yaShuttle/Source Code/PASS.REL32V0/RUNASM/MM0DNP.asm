*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM0DNP.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'MM0DNP--SCALAR TO PARTITIONED MATRIX MOVE, DP'         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM0DNP   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* FILL AN N X M PARTITION OF A DOUBLE PRECISION MATRIX WITH A           00000400
*   DOUBLE PRECISION SCALAR                                             00000500
*                                                                       00000600
         INPUT F0,            SCALAR DP                                X00000700
               R5,            INTEGER(N) SP                            X00000800
               R6,            INTEGER(M) SP                            X00000900
               R7             INTEGER(OUTDEL) SP                        00001000
         OUTPUT R1            MATRIX(N,M) DP                            00001100
         WORK  R3                                                       00001200
         LR    R3,R6          SAVE # OF COLUMNS                         00001300
*                                                                       00001400
* ALGORITHM:                                                            00001500
*   TWO LOOPS ARE USED, ONE NESTED WITHIN THE OTHER.                    00001600
*   OUTER LOOP:                                                         00001700
*     THIS LOOP SETS R1 TO POINT TO THE 0TH ELEMENT OF THE ROW          00001800
*       OF THE N X M MATRIX IN QUESTION BY USING THE OUTDEL             00001900
*       VALUE IN R7.                                                    00002000
*   INNER LOOP:                                                         00002100
*     THIS LOOP INCREMENTS R1 BY 4 HALFWORDS AND STORES THE SCALAR      00002200
*       WITHIN THE APPROPRIATE COLUMN OF THE N X M MATRIX.              00002300
*                                                                       00002400
LOOP     LA    R1,4(R1)       BUMP OUTPUT PTR TO NEXT ELEMENT           00002500
         STED  F0,0(R1)                                                 00002600
         BCTB  R6,LOOP                                                  00002700
         LR    R6,R3          RESET R6 TO # OF COLUMNS                  00002800
         AR    R1,R7          SET R1 TO PROPER ELEMENT IN NEXT ROW      00002900
         BCTB  R5,LOOP                                                  00003000
*                                                                       00003100
* THIS ALGORITHM DOES NOT USE THE BIX INSTRUCTION FOR THE               00003200
*   CALCULATED TRADEOFF INDICATES THAN N MUST BE APPROXIMATELY          00003300
*   11.  IN ADDITION, THE THE BIX REQUIRES MORE SETUP TIME AND SPACE.   00003400
*                                                                       00003500
         AEXIT                                                          00003600
         ACLOSE                                                         00003700
