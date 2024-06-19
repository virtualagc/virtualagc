*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV1DN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV1DN--VECTOR MOVE, LENGTH N, DP'                       00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV1DN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* MOVE V1 TO V2 WHERE V1 AND V2 ARE DOUBLE PRECISION N VECTORS AND      00000400
*   WHERE N IS NOT EQUAL TO 3.                                          00000500
*                                                                       00000600
         INPUT R2,            VECTOR(N) DP                             X00000700
               R5             INTEGER(N) SP                             00000800
         OUTPUT R1            VECTOR(N) DP                              00000900
         WORK  F0                                                       00001000
*                                                                       00001100
* ALGORITHM:                                                            00001200
*   DO FOR I = N TO 1 BY -1;                                            00001300
*     V2$(I) = V1$(I);                                                  00001400
*   END;                                                                00001500
*                                                                       00001600
DLOOP    LED   F0,0(R5,R2)                                              00001700
         STED  F0,0(R5,R1)                                              00001800
         BCTB  R5,DLOOP                                                 00001900
         AEXIT                                                          00002000
         ACLOSE                                                         00002100
