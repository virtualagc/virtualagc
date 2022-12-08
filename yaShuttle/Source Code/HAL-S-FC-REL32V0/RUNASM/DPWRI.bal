*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DPWRI.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

 TITLE 'DPWRI -- EXPONENTIATION OF A SCALAR TO AN INTEGRAL POWER'       00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
* DPWRI: SCALAR TO AN INTEGRAL POWER(DOUBLE)                            00000200
*                                                                       00000300
*        1. INPUTS: BASE IN F0, EXPONENT IN R6.                         00000400
*        2. OUTPUT IN F0 SINGLE.                                        00000500
*        3. SUCCESSIVELY TAKE FIRST, SECOND, FOURTH, ETC.               00000600
*           POWERS OF BASE, SIMULTANEOUSLY SHIFTING EXPONENT RIGHT.     00000700
*        4. MULTIPLY POWER OF BASE INTO ANSWER WHEN '1' IS SHIFTED OUT. 00000800
*        5. ERROR GIVEN WHEN BASE=0 AND EXPONENT<=0.                    00000900
*                                                                       00001000
DPWRI    AMAIN QDED=YES                                                 00001100
* EXPONENTIATION OF A DOUBLE PRECISION SCALAR                           00001200
* TO A FULLWORD INTEGER POWER                                           00001300
         INPUT F0,            SCALAR DP                                X00001400
               R6             INTEGER DP                                00001500
         OUTPUT F0            SCALAR DP                                 00001600
         WORK  R5,R7,F1,F2,F3                                           00001700
         B     MERGE                                                    00001800
*                                                                       00001900
DPWRH    AENTRY                                                         00002000
* EXPONENTIATION OF A DOUBLE PRECISION SCALAR                           00002100
* TO A HALFWORD INTEGER POWER                                           00002200
         INPUT F0,            SCALAR DP                                X00002300
               R6             INTEGER SP                                00002400
         OUTPUT F0            SCALAR DP                                 00002500
         WORK  R5,R7,F1,F2,F3                                           00002600
         SRA   R6,16          GET FULLWORD EXPONENT                     00002700
MERGE    LER   F3,F1          GET BASE IN REGISTER PAIR                 00002800
         LER   F2,F0          F2-F3 AND TEST SIGN                       00002900
         BNZ   NOTZERO                                                  00003000
         LR    R5,R6          RETURN 0 IF BASE=0                        00003100
         BP    EXIT           AND EXPONENT>0.                           00003200
         AERROR 4             ERROR: BASE=0, EXPONENT<=0                00003300
         B     EXIT           FIXUP: RETURN 0                           00003400
*                                                                       00003500
NOTZERO  LED   F0,ONE                                                   00003600
         LR    R5,R6                                                    00003700
         BNM   LOOP                                                     00003800
         LACR  R6,R6          GET |EXPONENT|                            00003900
*                                                                       00004000
LOOP     SRDL  R6,1                                                     00004100
         LR    R7,R7                                                    00004200
         BNM   NOMULT                                                   00004300
         MEDR  F0,F2          MULTIPLY IN IF 1 SHIFTED OUT              00004400
NOMULT   LR    R6,R6                                                    00004500
         BZ    OUT                                                      00004600
         MEDR  F2,F2                                                    00004700
         B     LOOP                                                     00004800
*                                                                       00004900
OUT      LR    R5,R5                                                    00005000
         BNM   EXIT                                                     00005100
         LER   F2,F0          GET RECIPROCAL OF                         00005200
         LER   F3,F1                                                    00005300
         LED   F0,ONE                                                   00005400
        QDEDR  F0,F2          WAS NEGATIVE                              00005500
*                                                                       00005600
EXIT     AEXIT                                                          00005700
*                                                                       00005800
         DS    0E                                                       00005900
ONE      DC    X'4110000000000000'                                      00006000
*                                                                       00006100
         ACLOSE                                                         00006200
