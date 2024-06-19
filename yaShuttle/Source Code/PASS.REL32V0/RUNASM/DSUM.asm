*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DSUM.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'DSUM--SCALAR SUM FUNCTION, DP'                          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
DSUM     AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* RETURNS THE SUM OF ALL THE ELEMENTS OF A LENGTH N ARRAY OF DOUBLE     00000400
*   PRECISION SCALARS.                                                  00000500
*                                                                       00000600
         INPUT R2,            ARRAY(N) SCALAR DP                       X00000700
               R5             INTEGER(N) SP                             00000800
         OUTPUT F0            SCALAR DP                                 00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   F0 = 0;                                                             00001200
*   DO FOR I = 1 TO N;                                                  00001300
*     F0 = F0 + ARRAY$(I);                                              00001400
*   END;                                                                00001500
*                                                                       00001600
         SEDR F0,F0           CLEAR ACCUMULATOR                         00001700
LOOPD    AED  F0,4(R2)        ADD IN ELEMENT OF ARRAY                   00001800
         LA   R2,4(R2)        BUMP INPUT PTR TO NEXT ELEMENT            00001900
         BCT  R5,LOOPD                                                  00002000
         AEXIT                                                          00002100
         ACLOSE                                                         00002200
