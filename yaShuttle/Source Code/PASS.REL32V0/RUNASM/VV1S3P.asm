*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV1S3P.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV1S3P--COLUMN VECTOR MOVE, LENGTH 3 OR N, SP'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV1S3P   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* MOVE V1 TO V2 WHERE V1 AND V2 ARE SINGLE PRECISION 3 VECTORS,         00000400
*   AT LEAST ONE OF WHICH IS A COLUMN VECTOR WITHIN A MATRIX.           00000500
*                                                                       00000600
         INPUT R2,            VECTOR(3) SP                             X00000700
               R6,            INTEGER(INDEL) SP                        X00000800
               R7             INTEGER(OUTDEL) SP                        00000900
         OUTPUT R1            VECTOR(3) SP                              00001000
         WORK  R5,F0                                                    00001100
*                                                                       00001200
* ALGORITHM:                                                            00001300
*   SEE ALGORITHM DESCRIPTION IN VV1D3P                                 00001400
*                                                                       00001500
         LFXI  R5,3                                                     00001600
VV1SNP   AENTRY                                                         00001700
*                                                                       00001800
* MOVE V1 TO V2 WHERE V1 AND V2 ARE SINGLE PRECISION VECTORS OF LENGTH  00001900
*   N WHERE N IS NOT EQUAL TO 3 AND WHERE AT LEAST ONE OF V1 AND V2 IS  00002000
*   A COLUMN VECTOR WITHIN A MATRIX.                                    00002100
*                                                                       00002200
         INPUT R2,            VECTOR(N) SP                             X00002300
               R5,            INTEGER(N) SP                            X00002400
               R6,            INTEGER(INDEL) SP                        X00002500
               R7             INTEGER(OUTDEL) SP                        00002600
         OUTPUT R1            VECTOR(N) SP                              00002700
         WORK  F0                                                       00002800
*                                                                       00002900
* ALGORITHM:                                                            00003000
*   SEE ALGORITHM DESCRIPTION IN VV1D3P                                 00003100
*                                                                       00003200
         LR    R7,R7          SET CONDITION CODE                        00003300
         BNZ   VV1S3P1        IF OUTDEL > 0 THEN CHECK INDEL            00003400
         LFXI  R7,2           ELSE SET R7 TO POINT TO CONSECUTIVE       00003500
*                             ELEMENTS                                  00003600
VV1S3P1  LR    R6,R6          SET CONDITION CODE                        00003700
         BNZ   VV1S3P2        IF INDEL > 0 THEN PERFORM LOOP            00003800
         LFXI  R6,2           ELSE SET R6 TO POINT TO CONSECUTIVE       00003900
*                             ELEMENTS                                  00004000
VV1S3P2  LE    F0,2(R2)                                                 00004100
         STE   F0,2(R1)                                                 00004200
         AR    R1,R7          BUMP OUTPUT PTR TO NEXT ELEMENT           00004300
         AR    R2,R6          BUMP INPUT PTR TO NEXT ELEMENT            00004400
         BCTB  R5,VV1S3P2                                               00004500
         AEXIT                                                          00004600
         ACLOSE                                                         00004700
