*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV1T3P.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV1T3P--COLUMN VECTOR MOVE, LENGTH 3 OR N, DP TO SP'    00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV1T3P   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* MOVE V1 TO V2 WHERE V1 IS A DOUBLE PRECISION 3 VECTOR AND V2 IS A     00000400
*   SINGLE PRECISION 3 VECTOR, AT LEAST ONE OF WHICH IS A COLUMN VECTOR 00000500
*   WITHIN A MATRIX.                                                    00000600
*                                                                       00000700
         INPUT R2,            VECTOR(3) DP                             X00000800
               R6,            INTEGER(INDEL) SP                        X00000900
               R7             INTEGER(OUTDEL) SP                        00001000
         OUTPUT R1            VECTOR(3) SP                              00001100
         WORK  R5,F0                                                    00001200
*                                                                       00001300
* ALGORITHM:                                                            00001400
*   SEE ALGORITHM DESCRIPTION IN VV1D3P                                 00001500
*                                                                       00001600
         LFXI  R5,3                                                     00001700
VV1TNP   AENTRY                                                         00001800
*                                                                       00001900
* MOVE V1 TO V2 WHERE V1 IS A DOUBLE PRECISION VECTOR OF LENGTH         00002000
*   N AND V2 IS A SINGLE PRECISION VECTOR OF LENGTH N AT LEAST          00002100
*   ONE OF WHICH IS A COLUMN VECTOR WITHIN A MATRIX, AND WHERE          00002200
*   N IS NOT EQUAL TO 3.                                                00002300
*                                                                       00002400
         INPUT R2,            VECTOR(N) DP                             X00002500
               R5,            INTEGER(N) SP                            X00002600
               R6,            INTEGER(INDEL) SP                        X00002700
               R7             INTEGER(OUTDEL) SP                        00002800
         OUTPUT R1            VECTOR(N) SP                              00002900
         WORK  F0                                                       00003000
*                                                                       00003100
* ALGORITHM:                                                            00003200
*   SEE ALGORITHM DESCRIPTION IN VV1D3P                                 00003300
*                                                                       00003400
         LR    R7,R7          SET CONDITION CODE                        00003500
         BNZ   DSNP1          IF OUTDEL ^= 0 THEN CHECK INDEL           00003600
         LFXI  R7,2           ELSE SET R7 TO ACCESS CONSECUTIVE         00003700
*                             ELEMENTS.                                 00003800
DSNP1    LR    R6,R6          SET CONDITION CODE                        00003900
         BNZ   DSNP2          IF INDEL ^= 0 THEN DO THE LOOP            00004000
         LFXI  R6,4           ELSE SET R6 TO ACCESS CONSECUTIVE         00004100
*                             ELEMENTS.                                 00004200
DSNP2    LE    F0,4(R2)       LOAD ELEMENT TO BE MOVED                  00004300
         STE   F0,2(R1)       STORE ELEMENT                             00004400
         AR    R1,R7          ADVANCE TO NEXT STORAGE SPOT              00004500
         AR    R2,R6          ADVANCE TO NEXT ELEMENT TO BE MOVED       00004600
         BCTB  R5,DSNP2                                                 00004700
         AEXIT                                                          00004800
         ACLOSE                                                         00004900
