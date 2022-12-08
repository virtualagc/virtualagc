*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM1SNP.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM1SNP--PARTITIONED MATRIX MOVE, LENGTH N, SP'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM1SNP   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* MOVE AN N X M PARTITION OF M1 TO ALL OR AN N X M PARTITION OF M2 OR   00000400
*   MOVE ALL OF M1 TO AN N X M PARTITION OF M2, WHERE M1 AND M2 ARE     00000500
*   SINGLE PRECISION MATRICES.                                          00000600
*                                                                       00000700
         INPUT R2,            MATRIX(N,M) SP ( THIS IS M1 )            X00000800
               R5,            INTEGER(N) SP                            X00000900
               R6,            INTEGER(M) SP                            X00001000
               R7             INTEGER(INDEL || OUTDEL) SP               00001100
         OUTPUT R1            MATRIX(N,M) SP ( THIS IS M2)              00001200
         WORK  R3,F0,F1                                                 00001300
*                                                                       00001400
* ALGORITHM:                                                            00001500
*   SEE ALGORITHM DESCRIPTION IN MM1DNP                                 00001600
*                                                                       00001700
         SR    R3,R3          CLEAR R3                                  00001800
         LFLR  F1,R6          SAVE # OF COLUMNS                         00001900
         XUL   R3,R7          PLACE OUTDEL IN R3                        00002000
OUTLOOP  LFXR  R6,F1          LOAD # OF COLUMNS                         00002100
INLOOP   LE    F0,2(R2)                                                 00002200
         LA    R2,2(R2)       BUMP THE INPUT POINTER BY A FULL WORD     00002300
         STE   F0,2(R1)                                                 00002400
         LA    R1,2(R1)       BUMP THE OUTPUT POINTER BY A FULL WORD    00002500
         BCTB  R6,INLOOP                                                00002600
         AR    R1,R3          BUMP THE OUTPUT POINTER TO THE NEXT ROW   00002700
         AR    R2,R7          BUMP THE INPUT POINTER TO THE NEXT ROW    00002800
         BCTB  R5,OUTLOOP                                               00002900
*                                                                       00003000
* SEE COMMENT ON BIX IN MM1DNP                                          00003100
*                                                                       00003200
         AEXIT                                                          00003300
         ACLOSE                                                         00003400
