*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM1TNP.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

        TITLE 'MM1TNP--PARTITIONED MATRIX MOVE, LENGTH N, DP TO SP'     00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM1TNP   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* MOVE AN N X M PARTITION OF M1 TO ALL OR AN N X M PARTITION OF M2 OR   00000400
*   MOVE ALL OF M1 TO AN N X M PARTITION OF M2, WHERE M1 IS A DOUBLE    00000500
*   PRECISION MATRIX AND M2 IS A SINGLE PRECISION MATRIX.               00000600
*                                                                       00000700
         INPUT R2,            MATRIX(N,M) DP ( THIS IS M1 )            X00000800
               R5,            INTEGER(N) SP                            X00000900
               R6,            INTEGER(M) SP                            X00001000
               R7             INTEGER(INDEL || OUTDEL) SP               00001100
         OUTPUT R1            MATRIX(N,M) SP ( THIS IS M2 )             00001200
         WORK  R3,F0,F2                                                 00001300
*                                                                       00001400
* ALGORITHM:                                                            00001500
*   SEE ALGORITHM DESCRIPTION IN MM1DNP                                 00001600
*                                                                       00001700
         SR    R3,R3          CLEAR R3                                  00001800
         LFLR  F2,R6          SAVE # OF COLUMNS                         00001900
         XUL   R3,R7          LOAD OUTDEL INTO R3                       00002000
OUTLOOP  LFXR  R6,F2          LOAD # OF COLUMNS                         00002100
INLOOP   LED   F0,4(R2)                                                 00002200
         STE   F0,2(R1)                                                 00002300
         LA    R2,4(R2)       BUMP INPUT POINTER BY A DOUBLE WORD       00002400
         LA    R1,2(R1)       BUMP OUTPUT POINTER BY A FULL WORD        00002500
         BCTB  R6,INLOOP                                                00002600
         AR    R1,R3          BUMP OUTPUT POINTER TO NEXT ROW           00002700
         AR    R2,R7          BUMP INPUT POINTER TO NEXT ROW            00002800
         BCTB  R5,OUTLOOP                                               00002900
         AEXIT                                                          00003000
         ACLOSE                                                         00003100
