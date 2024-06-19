*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    EPWRI.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

 TITLE 'EPWRI -- EXPONENTIATION OF A SCALAR TO AN INTEGRAL POWER'       00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
* EPWRI: SCALAR TO AN INTEGRAL POWER(SINGLE)                            00000200
*                                                                       00000300
*        1. INPUTS: BASE IN F0, EXPONENT IN R6 FULLWORD.                00000400
*        2. OUTPUT IN F0 SINGLE.                                        00000500
*        3. SUCCESSIVELY TAKE FIRST, SECOND, FOURTH, ETC.               00000600
*           POWERS OF BASE, SIMULTANEOUSLY SHIFTING EXPONENT RIGHT.     00000700
*        4. MULTIPLY POWER OF BASE INTO ANSWER WHEN '1' IS SHIFTED OUT. 00000800
*        5. ERROR GIVEN WHEN BASE=0 AND EXPONENT<=0.                    00000900
*                                                                       00001000
EPWRI    AMAIN                                                          00001100
* EXPONENTIATION OF A SINGLE PRECISION SCALAR TO                        00001200
* A DOUBLE PRECISION INTEGER POWER                                      00001300
         INPUT F0,            SCALAR SP                                X00001400
               R6             INTEGER DP                                00001500
         OUTPUT F0            SCALAR SP                                 00001600
         WORK  R5,R6,R7,F2                                              00001700
         B     MERGE                                                    00001800
*                                                                       00001900
EPWRH    AENTRY                                                         00002000
* EXPONENTIATION OF A SINGLE PRECISION SCALAR                           00002100
* TO A SINGLE PRECISION INTEGER POWER                                   00002200
         INPUT F0,            SCALAR SP                                X00002300
               R6             INTEGER SP                                00002400
         OUTPUT F0            SCALAR SP                                 00002500
         WORK  R5,R6,R7,F2                                              00002600
         SRA   R6,16          GET FULLWORD EXPONENT                     00002700
MERGE    LER   F2,F0                                                    00002800
         BNZ   NOTZERO                                                  00002900
         LR    R5,R6          GIVE ERROR IF BASE=0                      00003000
         BNP   ERROR          AND EXPONENT<=0.                          00003100
*                                                                       00003200
ZERO     SER   F0,F0          RETURN 0                                  00003300
         B     EXIT                                                     00003400
*                                                                       00003500
NOTZERO  LE    F0,ONE                                                   00003600
         LR    R5,R6                                                    00003700
         BNM   LOOP                                                     00003800
         LACR  R6,R6          GET |EXPONENT|                            00003900
*                                                                       00004000
LOOP     SRDL  R6,1                                                     00004100
         LR    R7,R7                                                    00004200
         BNM   NOMULT                                                   00004300
         MER   F0,F2          MULTIPLY IN IF 1 SHIFTED OUT              00004400
NOMULT   LR    R6,R6                                                    00004500
         BZ    OUT                                                      00004600
         MER   F2,F2                                                    00004700
         B     LOOP                                                     00004800
*                                                                       00004900
OUT      LR    R5,R5                                                    00005000
         BNM   EXIT                                                     00005100
         LER   F2,F0          GET RECIPROCAL OF                         00005200
         LE    F0,ONE         ANSWER IF EXPONENT                        00005300
         DER   F0,F2          WAS NEGATIVE                              00005400
*                                                                       00005500
EXIT     AEXIT                                                          00005600
*                                                                       00005700
ERROR    AERROR 4             ZERO RAISED TO POWER <= 0                 00005800
         SER   F0,F0          STANDARD FIXUP RETURNS 0                  00005900
         B     EXIT                                                     00006000
*                                                                       00006100
ONE      DC    E'1'                                                     00006200
         ACLOSE                                                         00006300
