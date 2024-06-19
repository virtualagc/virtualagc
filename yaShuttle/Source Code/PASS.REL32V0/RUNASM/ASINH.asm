*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    ASINH.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'ASINH-- ARCSINCH,SINGLE PRECISION'                     00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
*   ARCSINCH(X)=LN(X+SQRT(X**2+1))                                      00000200
*                                                                       00000300
* THE FUNCTION IS MADE ODD BY TAKING THE ABSOLUTE VALUE OF THE          00000400
* ARGUMENT, COMPUTING THE FUNCTION, AND REVERSING THE SIGN OF THE       00000500
* RESULT IF THE ARGUMENT WAS NEGATIVE. IF THE ABSOLUTE VALUE OF         00000600
* THE ARGUMENT IS VERY SMALL,ARCSINH(X) NEARLY EQUALS X. FOR            00000700
* LARGER VALUES OF ABS(X), A TAYLOR SERIES POLYNOMIAL FOR ARCSINH(X)    00000800
* IS COMPUTED. OTHERWISE, THE COMPUTATION USES THE SQRT AND LOG         00000900
* SUBROUTINES STRAIGHTFORWARDLY, UNLESS ABS(X) IS SO LARGE THAT         00001000
* SQRT(X**2+1) IS INDISTINGUISHABLE  (TO SINGLE PREC) FROM X.           00001100
* IN THAT CASE,LN(X)+LN2 IS CALCULATED TO AVOID EXPONENT                00001200
* OVERFLOW ERRORS AND USELESS CALCULATIONS.                             00001300
*                                                                       00001400
         MACRO                                                          00001500
         WORKAREA                                                       00001600
BUFF     DS    E                                                        00001700
         MEND                                                           00001800
ASINH    AMAIN ACALL=YES                                                00001900
* COMPUTES HYPERBOLIC ARC-SINE IN SINGLE PRECISION                      00002000
         INPUT F0             SCALAR SP                                 00002100
         OUTPUT F0            SCALAR SP                                 00002200
         WORK  R1,R2,R5,R6,R7,F1,F2,F3,F4                               00002300
         LFXR  R2,F0                                                    00002400
         LER   F0,F0                                                    00002500
         BNM   POS                                                      00002600
         LECR  F0,F0                                                    00002700
POS      CE    F0,XBEST    IF SMALLER THAN THIS, NEST TERM IN           00002800
         BNL   HAUSDORF    TAYLOR SERIES WOULDN'T CHANGE RESULT         00002900
         LFLR  F0,R2                                                    00003000
         AEXIT                                                          00003100
HAUSDORF CE    F0,BIG                                                   00003200
         BL    REGULAR                                                  00003300
         ACALL LOG                                                      00003400
         AE    F0,LN2                                                   00003500
         B     SIGN                                                     00003600
REGULAR  CE    F0,POLYBEST                                              00003700
         BH    NORMAL                                                   00003800
         LER   F2,F0          TAYLOR SERIES IS                          00003900
         MER   F2,F2          X-1/6X**3+3/40X**5                        00004000
         LER   F4,F2                                                    00004100
         ME    F4,A2                                                    00004200
         AE    F4,A1                                                    00004300
         MER   F4,F2                                                    00004400
         AE    F4,ONE                                                   00004500
         MER   F0,F4                                                    00004600
         B     SIGN                                                     00004700
NORMAL   STE   F0,BUFF                                                  00004800
         MER   F0,F0                                                    00004900
         AE    F0,ONE                                                   00005000
         ABAL  SQRT                                                     00005100
         AE    F0,BUFF                                                  00005200
         ACALL LOG                                                      00005300
SIGN     LR    R2,R2                                                    00005400
         BNM   FIN                                                      00005500
         LECR  F0,F0                                                    00005600
FIN      AEXIT                                                          00005700
ONE      DC    E'1'                                                     00005800
XBEST    DC    X'3E3A25DA'                                              00005900
BIG      DC    X'47100000'                                              00006000
POLYBEST DC    X'4037614E'                                              00006100
A1       DC    X'C02AAAAB'                                              00006200
A2       DC    X'40133333'                                              00006300
LN2      DC    X'40B17218'                                              00006400
         ACLOSE                                                         00006500
