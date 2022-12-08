*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VR1SNP.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VR1SNP--REMOVE COLUMN VECTOR MOVE, SP'                  00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
VR1SNP   AMAIN                                                          00000200
*                                                                       00000300
* MOVES V1 TO V2 THERE V1 AND V2 ARE SINGLE PRECISION VECTORS,          00000400
*   AT LEAST ONE OF WHICH IS REMOTE AND AT LEAST ONE OF WHICH IS        00000500
*   A COLUMN VECTOR WITHIN A MATRIX, BOTH OF WHICH ARE LENGTH N         00000600
*                                                                       00000700
         INPUT R4,            ZCON(VECTOR(N)) SP                       X00000800
               R5,            INTEGER(N) SP                            X00000900
               R6,            INTEGER(INDEL) SP                        X00001000
               R7             INTEGER(OUTDEL) SP                        00001100
         OUTPUT R2            ZCON(VECTOR(N)) SP                        00001200
         WORK F0                                                        00001300
*                                                                       00001400
* ALGORITHM:                                                            00001500
*   SEE ALGORITHM DESCRIPTION IN VR1DNP                                 00001600
*                                                                       00001700
         LFXI  R4,1           SET INDEX REG TO 1                        00001800
         LR    R2,R4                                                    00001900
         SRL   R7,1           CONVERT HW TO INDEX                       00002000
         LR    R7,R7          SET CONDITION CODE                        00002100
         BNZ   VR1            IF OUTDEL>0 THEN BRANCH                   00002200
         LR    R7,R2          ELEMENTS ARE IN A ROW                     00002300
VR1      SRL   R6,1           CONVERT HW TO INDEX                       00002400
         LR    R6,R6          SET CONDITION CODE                        00002500
         BNZ   VR2            BRANCH IF INDEL>0                         00002600
         LR    R6,R4          ELEMENTS ARE IN A ROW                     00002700
VR2      LE@#  F0,ARG4(R4)    LOAD NEXT ELEMENT                         00002800
         STE@# F0,ARG2(R2)    STORE NEXT ELEMENT                        00002900
         AR    R2,R7          ADVANCE TO NEXT STORAGE ELEMENT           00003000
         AR    R4,R6          ADVANCE TO NEXT ELEMENT TO BE MOVED       00003100
         BCTB  R5,VR2                                                   00003200
         AEXIT                                                          00003300
         ACLOSE                                                         00003400
