*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM15SN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM15SN--SQUARE IDENTITY MATRIX, SP'                     00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM15SN   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* CREATES AN N X N SINGLE PRECISION IDENTITY MATRIX WHERE N IS >= 2.    00000400
*                                                                       00000500
         INPUT R5             INTEGER(N) SP                             00000600
         OUTPUT R1            MATRIX(N,N) DP                            00000700
         WORK  R6,R7,F0,F2                                              00000800
*                                                                       00000900
* ALGORITHM:                                                            00001000
*   SEE ALGORITHM DESCRIPTION IN MM15DN                                 00001100
*                                                                       00001200
         SER   F0,F0          PLACE A 0 IN F0                           00001300
         LFLI  F2,1           PLACE A 1 IN F2                           00001400
         LR    R6,R5          OUTER LOOP INDEX IN R6                    00001500
CLOOP    LR    R7,R5          INNER LOOP INDEX IN R7                    00001600
RLOOP    CR    R7,R6                                                    00001700
         BNE   LOADZ          IF INDICES ^= THEN STORE A 0.             00001800
LOADW    STE   F2,2(R1)                                                 00001900
         B     LOOP                                                     00002000
LOADZ    STE   F0,2(R1)                                                 00002100
LOOP     LA    R1,2(R1)                                                 00002200
         BCTB  R7,RLOOP                                                 00002300
         BCTB  R6,CLOOP                                                 00002400
         AEXIT                                                          00002500
         ACLOSE                                                         00002600
