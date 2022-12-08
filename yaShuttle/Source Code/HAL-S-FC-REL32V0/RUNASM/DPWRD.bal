*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DPWRD.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

 TITLE 'DPWRD -- EXPONENTIATION OF A SCALAR TO A SCALAR POWER'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
*                                                                       00000201
* REVISION HISTORY:                                                     00000301
*                                                                       00000401
*    DATE       NAME  DR/CR#     DESCRIPTION                            00000501
*    --------   ----  --------   ------------------------------------   00000601
*    12/16/89   JAC   DR103762   CHANGED QCED/QCEDR MACRO TO CED/CEDR   00000701
*                                INSTRUCTION                            00000801
*                                                                       00000901
*    01/14/93   RAH   CR11163    ADDED CODE TO COMPENSATE FOR BROKEN
*                                CED INSTRUCTION
*
* DPWRD: SCALAR TO SCALAR POWER(DOUBLE)                                 00001000
*                                                                       00001100
*        1. INPUTS: BASE IN F0, EXPONENT IN F2.                         00001200
*        2. OUTPUT IN F0.                                               00001300
*        3. X**Y = EXP(Y*LOG(X)).                                       00001400
*        3A. X**0.5 = SQRT(X)                                           00001500
*        4. ERRORS GIVEN WHEN BASE<0, OR BASE=0 AND EXPONENT<=0.        00001600
*                                                                       00001700
         MACRO                                                          00001800
         WORKAREA                                                       00001900
EXPON    DS    D                                                        00002000
         MEND                                                           00002100
*                                                                       00002200
DPWRD    AMAIN ACALL=YES                                                00002300
* PERFORMS EXPONENTIATION OF DOUBLE PRECISION SCALAR TO DOUBLE          00002400
* PRECISION POWER                                                       00002500
         INPUT F0,            SCALAR DP                                X00002600
               F2             SCALAR DP                                 00002700
         OUTPUT F0            SCALAR DP                                 00002800
         WORK  F1,F2,F3,F4,F5                                           00002900
         SEDR  F4,F4          TEST BASE, AND                            00003000
         AEDR  F4,F0          GIVE ERROR IF                             00003100
         BM    ERROR1         BASE<0.                                   00003200
         BNZ   NOTZERO                                                  00003300
*                                                                       00003400
         SEDR  F4,F4          TEST EXPONENT, AND                        00003500
         AEDR  F4,F2          EXIT IF BASE=0                            00003600
         BP    EXIT           AND EXPONENT<0.                           00003700
*                                                                       00003800
         AERROR 4             ZERO RAISED TO POWER <= 0                 00003900
         B     EXIT           FIXUP, RETURN ZERO                        00004000
*                                                                       00004100
*  MAIN COMPUTATION SECTION                                             00004200
*                                                                       00004300
NOTZERO  CE    F2,DHALF       CHECK FIRST PART OF EXP     /* CR11163 */
         BNE   SKIPCED                                    /* CR11163 */
         CED   F2,DHALF       IF EXPONENT=0.5,   /* DR103762,CR11163 */ 00004401
         BE    DOSQRT         CALL DSQRT                                00004500
*                                                                       00004600
SKIPCED  STED  F2,EXPON                                   /* CR11163 */ 00004700
         ACALL DLOG                                                     00004800
         MED   F0,EXPON                                                 00004900
         ACALL DEXP                                                     00005000
EXIT     AEXIT                                                          00005100
*                                                                       00005200
DOSQRT   ACALL DSQRT                                                    00005300
         B     EXIT                                                     00005400
*                                                                       00005500
ERROR1   AERROR 24            BASE<0 IN EXPONENTIATION                  00005600
         LECR  F0,F0          FIXUP: GET |BASE| AND TRY AGAIN           00005700
         B     NOTZERO                                                  00005800
*                                                                       00005900
         DS    0D                                                       00006000
DHALF    DC    X'4080000000000000'                                      00006100
         ACLOSE                                                         00007000
