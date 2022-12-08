*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV1TN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV1TN--VECTOR MOVE, LENGTH N, DP TO SP'                 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV1TN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* MOVE V1 TO V2 WHERE V1 IS A DOUBLE PRECISION VECTOR OF LENGTH N       00000400
*   AND V2 IS A SINGLE PRECISION VECTOR OF LENGTH N AND WHERE N         00000500
*   IS NOT EQUAL TO 3.                                                  00000600
*                                                                       00000700
         INPUT R2,            VECTOR(N) DP                             X00000800
               R5             INTEGER(N) SP                             00000900
         OUTPUT R1            VECTOR(N) SP                              00001000
         WORK  F0                                                       00001100
*                                                                       00001200
* ALGORITHM:                                                            00001300
*   SEE ALGORITHM DESCRIPTION IN VV1DN                                  00001400
*                                                                       00001500
DSLOOP   LED   F0,0(R5,R2)                                              00001600
         STE   F0,0(R5,R1)                                              00001700
         BCTB  R5,DSLOOP                                                00001800
         AEXIT                                                          00001900
         ACLOSE                                                         00002000
