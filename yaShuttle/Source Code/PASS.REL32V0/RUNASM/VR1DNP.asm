*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VR1DNP.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VR1DNP--REMOTE COLUMN VECTOR MOVE,DP'                   00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
VR1DNP   AMAIN                                                          00000200
*                                                                       00000300
* MOVES V1 TO V2 WHERE V1 AND V2 ARE DOUBLE PRECISION VECTORS,          00000400
*   AT LEAST ONE OF WHICH IS REMOTE AND AT LEAST ONE OF WHICH IS        00000500
*   A COLUMN VECTOR WITHIN A MATRIX, BOTH OF WHICH ARE LENGTH N.        00000600
*                                                                       00000700
         INPUT R4,            ZCON(VECTOR(N)) DP                       X00000800
               R5,            INTEGER(N) SP                            X00000900
               R6,            INTEGER(INDEL) SP                        X00001000
               R7             INTEGER(OUTDEL) SP                        00001100
         OUTPUT R2            ZCON(VECTOR(N)) DP                        00001200
         WORK  F0                                                       00001300
*                                                                       00001400
* ALGORITHM:                                                            00001500
*   DO FOR I = 1 TO N;                                                  00001600
*     V1$(I) = V2$(I);                                                  00001700
*   END;                                                                00001800
*                                                                       00001900
         LFXI  R4,1           SET INDEX REG TO 1                        00002000
         LR    R2,R4          SET OTHER INDEX TO 1                      00002100
         SRL   R7,2           CONVERT HALFWORDS TO INDEX                00002200
         LR    R7,R7          TEST FOR NO OUTDEL                        00002300
         BNZ   VR1            IF OUTDEL>0 THEN BRANCH                   00002400
         LR    R7,R2          ELEMENTS ARE IN A ROW, BUMP INDEX BY 1    00002500
VR1      SRL   R6,2           CONVERT HALFWORDS TO INDEX                00002600
         LR    R6,R6          SET CONDITION CODE                        00002700
         BNZ   VR2            BRANCH IF INDEL>0                         00002800
         LR    R6,R4          ELEMENTS ARE IN A ROW, BUMP INDEX BY 1    00002900
VR2      LED@# F0,ARG4(R4)    LOAD NEXT ELEMENT                         00003000
         STED@# F0,ARG2(R2)   STORE NEXT ELEMENT                        00003100
         AR    R2,R7          ADVANCE TO NEXT STORAGE ELEMENT           00003200
         AR    R4,R6          ADVANCE TO NEXT ELEMENT TO BE MOVED       00003300
         BCTB  R5,VR2                                                   00003400
         AEXIT                                                          00003500
         ACLOSE                                                         00003600
