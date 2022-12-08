*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM0SNP.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'MM0SNP--SCALAR TO PARTITIONED MATRIX MOVE, SP'         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM0SNP   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* FILL AN N X M PARTITION OF A SINGLE PRECISION MATRIX WITH A           00000400
*   SINGLE PRECISION SCALAR                                             00000500
*                                                                       00000600
         INPUT F0,            SCALAR SP                                X00000700
               R5,            INTEGER(N) SP                            X00000800
               R6,            INTEGER(M) SP                            X00000900
               R7             INTEGER(OUTDEL) SP                        00001000
         OUTPUT R1            MATRIX(N,M) SP                            00001100
         WORK  R3                                                       00001200
         LR    R3,R6          SAVE # OF COLUMNS                         00001300
*                                                                       00001400
* ALGORITHM:                                                            00001500
*   SEE ALGORITM DESCRIPTION IN COMMENTS OF MM0DNP                      00001600
*                                                                       00001700
LOOP     LA    R1,2(R1)                                                 00001800
         STE   F0,0(R1)                                                 00001900
         BCTB  R6,LOOP                                                  00002000
         LR    R6,R3          RESET R6 TO # OF COLUMNS                  00002100
         AR    R1,R7          SET R1 TO PROPER ELEMENT IN NEXT ROW      00002200
         BCTB  R5,LOOP                                                  00002300
*                                                                       00002400
* SEE COMMENT ON BIX IN MM0DNP                                          00002500
*                                                                       00002600
         AEXIT                                                          00002700
         ACLOSE                                                         00002800
