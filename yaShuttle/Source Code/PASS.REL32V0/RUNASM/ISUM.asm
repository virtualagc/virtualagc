*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    ISUM.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'ISUM--INTEGER SUM FUNCTION, DP'                         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
ISUM     AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* RETURNS THE SUM OF ALL THE ELEMENTS OF A LENGTH N ARRAY OF DOUBLE     00000400
*   PRECISION INTEGERS.                                                 00000500
*                                                                       00000600
         INPUT R2,            ARRAY(N) INTEGER DP                      X00000700
               R5             INTEGER(N) SP                             00000800
         OUTPUT R5            INTEGER DP                                00000900
         WORK  R6                                                       00001000
*                                                                       00001100
* ALGORITHM:                                                            00001200
*   SEE ALGORITHM DESCRIPTION IN DSUM                                   00001300
*                                                                       00001400
         SR    R6,R6          CLEAR ACCUMULATOR                         00001500
LOOPI    A     R6,2(R2)       ADD IN NEXT ELEMENT                       00001600
         LA    R2,2(R2)       BUMP INPUT PTR TO NEXT ELEMENT            00001700
         BCT   R5,LOOPI                                                 00001800
         LR    R5,R6          ANSWER EXPECTED IN R5                     00001900
         AEXIT                                                          00002000
         ACLOSE                                                         00002100
