*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV1D3P.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV1D3P--COLUMN VECTOR MOVE, LENGTH 3 OR N, DP'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV1D3P   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* MOVE V1 TO V2 WHERE V1 AND V2 ARE DOUBLE PRECISION 3 VECTORS,         00000400
*   AT LEAST ONE OF WHICH IS A COLUMN VECTOR WITHIN A MATRIX.           00000500
*                                                                       00000600
         INPUT R2,            VECTOR(3) DP                             X00000700
               R6,            INTEGER(INDEL) SP                        X00000800
               R7             INTEGER(OUTDEL) SP                        00000900
         OUTPUT R1            VECTOR(3) DP                              00001000
         WORK  R5,F0                                                    00001100
*                                                                       00001200
* ALGORITHM:                                                            00001300
*   SEE ALGORITHM DESCRIPTION BELOW FOR ENTRY                           00001400
*                                                                       00001500
         LA   R5,3                                                      00001600
VV1DNP   AENTRY                                                         00001700
*                                                                       00001800
* MOVE V1 TO V2 WHERE V1 AND V2 ARE DOUBLE PRECISION VECTORS OF LENGTH  00001900
*   N WHERE N IS NOT EQUAL TO 3 AND WHERE AT LEAST ONE OF WHICH IS      00002000
*   A COLUMN VECTOR WITHIN A MATRIX.                                    00002100
*  WHERE N IS NOT EQUAL TO 3.                                           00002200
*                                                                       00002300
         INPUT R2,            VECTOR(N) DP                             X00002400
               R5,            INTEGER(N) SP                            X00002500
               R6,            INTEGER(INDEL) SP                        X00002600
               R7             INTEGER(OUTDEL) SP                        00002700
         OUTPUT R1            VECTOR(N) DP                              00002800
         WORK  F0                                                       00002900
*                                                                       00003000
* ALGORITHM:                                                            00003100
*   IF OUTDEL = 0 THEN                                                  00003200
*     R7 = 4;   /* TO ADDRESS CONSECUTIVE ELEMENTS */                   00003300
*   IF INDEL = 0 THEN                                                   00003400
*     R6 = 4;   /* TO ADDRESS CONSECUTIVE ELEMENTS */                   00003500
*   DO FOR I = N TO 1 BY -1;                                            00003600
*     V2$(I) = V1$(I);                                                  00003700
*   END;                                                                00003800
*                                                                       00003900
         LR    R7,R7          SET CONDITION CODE                        00004000
         BNZ   VV1DNP1        IF OUTDEL^=0 BRANCH TO CHECK ON INDEL     00004100
         LFXI  R7,4           ELSE SET R7 TO ADDRESS CONSECUTIVE        00004200
*                             ELEMENT                                   00004300
VV1DNP1  LR    R6,R6          SET CONDITION CODE                        00004400
         BNZ   VV1DNP2        IF INDEL ^= 0 BRANCH TO MOVE LOOP         00004500
         LFXI  R6,4           ELSE SET R6 TO ADDRESS CONSECUTIVE        00004600
*                             ELEMENT                                   00004700
VV1DNP2  LED   F0,4(R2)                                                 00004800
         STED  F0,4(R1)                                                 00004900
         AR    R1,R7          BUMP OUTPUT PTR TO NEXT ELEMENT           00005000
         AR    R2,R6          BUMP INPUT PTR TO NEXT ELEMENT            00005100
         BCTB  R5,VV1DNP2                                               00005200
         AEXIT                                                          00005300
         ACLOSE                                                         00005400
