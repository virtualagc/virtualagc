*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DPROD.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'DPROD--SCALAR PROD FUNCTION, DP'                        00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
DPROD    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* RETURNS THE PRODUCT OF ALL THE ELEMENTS OF A LENGTH N ARRAY OF        00000400
*   DOUBLE PRECISION SCALARS.                                           00000500
*                                                                       00000600
         INPUT R2,            ARRAY(N) SCALAR DP                       X00000700
               R5             INTEGER(N) SP                             00000800
         OUTPUT F0            SCALAR DP                                 00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   F0 = 1;                                                             00001200
*   DO FOR I = 1 TO N;                                                  00001300
*     F0 = F0 * ARRAY$(I);                                              00001400
*     IF F0 = 0 THEN                                                    00001500
*       EXIT;                                                           00001600
*   END;                                                                00001700
*                                                                       00001800
         LED   F0,=D'1'       INITIALIZE ACCUMULATOR                    00001900
LOOPD    MED   F0,4(R2)       MULTIPLY BY ELEMENT OF ARRAY              00002000
         LER   F0,F0          SET CONDITION CODE                        00002100
         BZ    EXIT           IF ACCUMULATOR = 0 THEN EXIT              00002200
         LA    R2,4(R2)       BUMP INPUT PTR TO NEXT ELEMENT            00002300
         BCT   R5,LOOPD                                                 00002400
EXIT     AEXIT                                                          00002500
         ACLOSE                                                         00002600
