*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV1W3P.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV1W3P--COLUMN VECTOR MOVE, LENGTH 3 OR N, SP TO DP'    00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV1W3P   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* MOVE V1 TO V2 WHERE V1 IS A SINGLE PRECISION 3 VECTOR AND V2 IS       00000400
*   A DOUBLE PRECISION 3 VECTOR WHERE AT LEAST ONE OF V1 AND V2         00000500
*   IS A COLUMN VECTOR WITHIN A MATRIX.                                 00000600
*                                                                       00000700
         INPUT R2,            VECTOR(3) SP                             X00000800
               R6,            INTEGER(INDEL) SP                        X00000900
               R7             INTEGER(OUTDEL) SP                        00001000
         OUTPUT R1            VECTOR(3) DP                              00001100
         WORK  R5,F0,F1                                                 00001200
*                                                                       00001300
* ALGORITHM:                                                            00001400
*   SEE ALGORITHM DESCRIPTION IN VV1D3P                                 00001500
*                                                                       00001600
         LA    R5,3                                                     00001700
VV1WNP   AENTRY                                                         00001800
*                                                                       00001900
* MOVE V1 TO V2 WHERE V1 IS A SINGLE PRECISION VECTOR OF LENGTH         00002000
*   N AND V2 IS A DOUBLE PRECISION VECTOR OF LENGTH N AND WHERE         00002100
*   AT LEAST ONE OF V1 AND V2 IS A COLUMN VECTOR WITHIN A MATRIX.       00002200
*                                                                       00002300
         INPUT R2,            VECTOR(N) SP                             X00002400
               R5,            INTEGER(N) SP                            X00002500
               R6,            INTEGER(INDEL) SP                        X00002600
               R7             INTEGER(OUTDEL) SP                        00002700
         OUTPUT R1            VECTOR(N) DP                              00002800
         WORK  F0,F1                                                    00002900
*                                                                       00003000
* ALGORITHM:                                                            00003100
*   SEE ALGORITHM DESCRIPTION IN VV1D3P                                 00003200
*                                                                       00003300
         SER   F1,F1          CLEAR F1                                  00003400
         LR    R7,R7          TEST R7 FOR 0                             00003500
         BNZ   SDNP1          IF OUTDEL>0 THEN CHECK INDEL              00003600
         LFXI  R7,4           ELSE SET R7 TO ACCESS CONSECUTIVE         00003700
*                             ELEMENTS                                  00003800
SDNP1    LR    R6,R6          SET CONDITION CODE                        00003900
         BNZ   SDNP2          IF INDEL>0 THEN PERFORM LOOP              00004000
         LFXI  R6,2           ELSE SET R6 TO ACCESS CONSECUTIVE         00004100
*                             ELEMENTS.                                 00004200
SDNP2    LE    F0,2(R2)       FIND NEXT ELEMENT                         00004300
         STED  F0,4(R1)       STORE IN NEXT STORAGE ELEMENT             00004400
         AR    R1,R7          ADVANCE TO NEXT STORAGE ELEMENT           00004500
         AR    R2,R6          ADVANCE TO NEXT ELEMENT TO BE STORED      00004600
         BCTB  R5,SDNP2                                                 00004700
         AEXIT                                                          00004800
         ACLOSE                                                         00004900
