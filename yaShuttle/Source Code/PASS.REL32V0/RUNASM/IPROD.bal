*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    IPROD.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'IPROD--INTEGER PROD FUNCTION, DP'                       00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
IPROD    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* RETURNS THE PRODUCT OF ALL THE ELEMENTS OF A LENGTH N ARRAY OF        00000400
*   DOUBLE PRECISION INTEGERS.                                          00000500
*                                                                       00000600
         INPUT R2,            ARRAY(N) INTEGER DP                      X00000700
               R5             INTEGER(N) SP                             00000800
         OUTPUT R5            INTEGER DP                                00000900
         WORK  R6,R7                                                    00001000
*                                                                       00001100
* ALGORITHM:                                                            00001200
*   SEE ALGORITHM DESCRIPTION IN DPROD                                  00001300
*                                                                       00001400
         L     R6,=F'1'       INITIALIZE ACCUMULATOR                    00001500
LOOPI    M     R6,2(R2)       MULTIPLY BY NEXT ELEMENT                  00001600
         SRDL  R6,1           FIX ANSWER                                00001700
         LR    R6,R6          CHECK FOR OVERFLOW TO R6                  00001800
         BZ    OK             IF ZERO THEN STILL OK                     00001900
         C     R6,BIG         CHECK AGAIN                               00002000
         BE    OK             IF ALL ONES THEN STILL OK                 00002100
*                                                                       00002200
*  IF PRODUCT TOO BIG FOR 32 BITS, THEN FORCE                           00002300
*  OVERFLOW TO SIGNAL POSSIBLE ERROR                                    00002400
*                                                                       00002500
         A     R6,BIG         ADD LARGE NUMBER TO FORCE OVERFLOW        00002600
OK       LR    R6,R7          PUT PROD IN R6 FOR NEXT MULTIPLY          00002700
         BZ    SHIFT          IF PROD = 0 THEN RETURN IMMEDIATELY       00002800
         LA    R2,2(R2)       BUMP INPUT PTR TO NEXT ELEMENT            00002900
         BCT   R5,LOOPI                                                 00003000
SHIFT    LR    R5,R6          ANSWER EXPECTED IN R5                     00003100
         AEXIT                                                          00003200
BIG      DC    F'2147483647'  X'7FFFFFFF'                               00003300
         ACLOSE                                                         00003400
