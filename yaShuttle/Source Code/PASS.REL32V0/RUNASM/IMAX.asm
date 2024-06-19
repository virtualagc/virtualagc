*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    IMAX.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'IMAX--INTEGER MAX FUNCTION ,DP'                         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
IMAX     AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* RETURNS THE MAXIMAL ELEMENT OF A LENGTH N ARRAY OF DOUBLE PRECISION   00000400
*   INTEGERS.                                                           00000500
*                                                                       00000600
         INPUT R2,            ARRAY(N) INTEGER DP                      X00000700
               R5             INTEGER(N) SP                             00000800
         OUTPUT R5            INTEGER DP                                00000900
         WORK  R6                                                       00001000
*                                                                       00001100
* ALGORITHM:                                                            00001200
*   SEE ALGORITHM DESCRIPTION IN DMAX                                   00001300
*                                                                       00001400
         B     START          GO TO SET CURRMAX                         00001500
ILOOP    C     R6,2(R2)       COMPARE CURRMAX TO NEXT ELEMENT           00001600
         BNL   HIGH           IF ^< THEN SKIP ASSIGNMENT                00001700
START    L     R6,2(R2)       RESET CURRMAX                             00001800
HIGH     LA    R2,2(R2)       BUMP INPUT PTR TO NEXT ELEMENT            00001900
         BCT   R5,ILOOP                                                 00002000
         LR    R5,R6          ANSWER EXPECTED IN R5                     00002100
         AEXIT                                                          00002200
         ACLOSE                                                         00002300
