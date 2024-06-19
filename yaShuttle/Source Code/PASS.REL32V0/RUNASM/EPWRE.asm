*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    EPWRE.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

 TITLE 'EPWRE -- EXPONENTIATION OF A SCALAR TO A SCALAR POWER'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
* EPWRE: SCALAR TO SCALAR POWER(SINGLE)                                 00000200
*                                                                       00000300
*        1. INPUTS: BASE IN F0, EXPONENT IN F2.                         00000400
*        2. OUTPUT IN F0.                                               00000500
*        3. X**Y = EXP(Y*LOG(X)).                                       00000600
*        3A. X**0.5 = SQRT(X)                                           00000700
*        4. ERRORS GIVEN WHEN BASE<0, OR BASE=0 AND EXPONENT<=0.        00000800
*                                                                       00000900
         MACRO                                                          00001000
         WORKAREA                                                       00001100
EXPON    DS    D                                                        00001200
         MEND                                                           00001300
*                                                                       00001400
EPWRE    AMAIN ACALL=YES                                                00001500
* EXPONENTIATION OF A SINGLE PRECISION SCALAR                           00001600
* TO A SINGLE PRECISION SCALAR POWER                                    00001700
         INPUT F0,            SCALAR SP                                X00001800
               F2             SCALAR SP                                 00001900
         OUTPUT F0            SCALAR SP                                 00002000
         WORK  R1,R5,R6,R7,F0,F1,F2,F3,F4                               00002100
         LER   F0,F0                                                    00002200
         BM    ERROR1                                                   00002300
         BNZ   NOTZERO                                                  00002400
         LER   F2,F2                                                    00002500
         BP    EXIT                                                     00002600
         AERROR 4             ZERO RAISED TO POWER <= 0                 00002700
         B     EXIT           FIXUP, RETURN ZERO                        00002800
*                                                                       00002900
NOTZERO  CE    F2,=X'40800000' IS EXPONENT 0.5                          00003000
         BE    DOSQRT                                                   00003100
         STE   F2,EXPON                                                 00003200
         ACALL LOG                                                      00003300
         ME    F0,EXPON                                                 00003400
         ACALL EXP                                                      00003500
EXIT     AEXIT                                                          00003600
*                                                                       00003700
DOSQRT   ABAL  SQRT                                                     00003800
         B     EXIT                                                     00003900
*                                                                       00004000
ERROR1   AERROR 24            BASE<0 IN EXPONENTIATION                  00004100
         LECR  F0,F0          FIXUP: GET |BASE| AND TRY AGAIN           00004200
         B     NOTZERO                                                  00004300
*                                                                       00004400
         ACLOSE                                                         00004500
