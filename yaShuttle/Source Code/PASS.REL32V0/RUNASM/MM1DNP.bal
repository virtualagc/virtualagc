*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM1DNP.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM1DNP--PARTITIONED MATRIX MOVE, LENGTH N, DP'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM1DNP   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* MOVE AN N X M PARTITION OF M1 TO ALL OR AN N X M PARTITION OF M2 OR   00000400
*   MOVE ALL OF M1 TO AN N X M PARTITION OF M2, WHERE M1 AND M2 ARE     00000500
*   DOUBLE PRECISION MATRICES                                           00000600
*                                                                       00000700
         INPUT R2,            MATRIX(N,M) DP ( THIS IS M1 )            X00000800
               R5,            INTEGER(N) SP                            X00000900
               R6,            INTEGER(M) SP                            X00001000
               R7             INTEGER(INDEL || OUTDEL) SP               00001100
         OUTPUT R1            MATRIX(N,M) DP ( THIS IS M2 )             00001200
         WORK  R3,F0,F2                                                 00001300
*                                                                       00001400
* ALGORITHM:                                                            00001500
*   TWO LOOPS ARE USED, ONE NESTED WITHIN THE OTHER.                    00001600
*   OUTER LOOP:                                                         00001700
*     THIS LOOP SETS R1 TO POINT TO THE 0TH ELEMENT OF THE ROW BEING    00001800
*       PROCESSED BY INCREMENTING USING THE OUTDEL VALUE IN R3 AND SETS 00001900
*       R2 TO POINT TO THE 0TH ELEMENT OF THE ROW BEING PROCESSED BY    00002000
*       INCREMENTING USING THE INDEL VALUE IN R7.                       00002100
*   INNER LOOP:                                                         00002200
*     THIS LOOP INCREMENTS R1 AND R2 BY 4 HALFWORDS IN ORDER TO WALK    00002300
*       THROUGH A GIVEN ROW, RETRIEVING AND STORING THE APPROPRIATE     00002400
*       ELEMENTS.                                                       00002500
*                                                                       00002600
         SR    R3,R3          CLEAR R3                                  00002700
         LFLR  F2,R6          SAVE # OF COLUMNS                         00002800
         XUL   R3,R7          PLACE OUTDEL IN R3                        00002900
OUTLOOP  LFXR  R6,F2          LOAD # OF COLUMNS                         00003000
INLOOP   LED   F0,4(R2)                                                 00003100
         STED  F0,4(R1)                                                 00003200
         LA    R2,4(R2)       BUMP THE INPUT POINTER BY A DOUBLE WORD   00003300
         LA    R1,4(R1)       BUMP THE OUTPUT POINTER BY A DOUBLE WORD  00003400
         BCTB  R6,INLOOP                                                00003500
         AR    R1,R3          BUMP THE OUTPUT POINTER TO NEXT ROW       00003600
         AR    R2,R7          BUMP THE INPUT POINTER TO NEXT ROW        00003700
         BCTB  R5,OUTLOOP                                               00003800
*                                                                       00003900
* THIS ALGORITHM DOES NOT USE THE BIX INSTRUCTION FOR THE CALCULATED    00004000
*   TRADEOFF INDICATES THAN THE PRODUCT MN MUST BE APPROXIMATELY 13.    00004100
*                                                                       00004200
         AEXIT                                                          00004300
         ACLOSE                                                         00004400
