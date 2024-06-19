*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    ESUM.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'ESUM--SCALAR SUM FUNCTION,SP'                           00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
ESUM     AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* RETURNS THE SUM OF ALL THE ELEMENTS OF A LENGTH N ARRAY OF SINGLE     00000400
*   PRECISION SCALARS.                                                  00000500
*                                                                       00000600
         INPUT R2,            ARRAY(N) SCALAR SP                       X00000700
               R5             INTEGER(N) SP                             00000800
         OUTPUT F0            SCALAR SP                                 00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   SEE ALGORITHM DESCRIPTION IN DSUM                                   00001200
*                                                                       00001300
         SER   F0,F0          CLEAR ACCUMULATOR                         00001400
LOOPE    AE    F0,2(R2)       F0 = ACCUMULATOR                          00001500
         LA    R2,2(R2)       BUMP INPUT PTR TO NEXT ELEMENT            00001600
         BCT   R5,LOOPE                                                 00001700
         AEXIT                                                          00001800
         ACLOSE                                                         00001900
