*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    ACOSH.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'ACOSH--ARCCOSH,SINGLE PRECISION'                       00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
*    ARCCOSH(X)=LN(X+SQRT(X**2-1))                                      00000200
*                                                                       00000300
* X**2-1 COMPUTED AS (X+1)*(X-1) TO AVOID ACCURACY LOSS.                00000400
* FOR LARGE X,SQRT(X**2-1) NEARLY EQUALS X. IN THAT CASE,               00000500
* LN(2X), OR LN(X) + LN(2) IS COMPUTED TO AVOID EXPONENT                00000600
* OVERFLOW ERRORS AND USELESS CALCULATIONS.                             00000700
* IF X IS LESS THAN ONE, AN ERROR IS SIGNALED.                          00000800
         MACRO                                                          00000900
         WORKAREA                                                       00001000
BUFF     DS    E                                                        00001100
         MEND                                                           00001200
ACOSH    AMAIN ACALL=YES                                                00001300
* COMPUTES HYBERBOLIC ARC-COSINE IN SINGLE PRECISION                    00001400
         INPUT F0             SCALAR SP                                 00001500
         OUTPUT F0            SCALAR SP                                 00001600
         WORK  R1,R5,R6,R7,F1,F2,F3,F4                                  00001700
         CE    F0,BIG                                                   00001800
         BL    NORMAL                                                   00001900
         ACALL LOG                                                      00002000
         AE    F0,LN2                                                   00002100
         AEXIT                                                          00002200
NORMAL   LE    F2,ONE                                                   00002300
         STE   F0,BUFF                                                  00002400
         SER   F0,F2                                                    00002500
         BM    ERROR                                                    00002600
         AE    F2,BUFF                                                  00002700
         MER   F0,F2                                                    00002800
         ABAL  SQRT                                                     00002900
         AE    F0,BUFF                                                  00003000
         ACALL LOG                                                      00003100
FIN      AEXIT                                                          00003200
ERROR    AERROR 59            ARG<1                                     00003300
         SER   F0,F0                                                    00003400
         AEXIT                                                          00003500
ONE      DC    E'1'                                                     00003600
LN2      DC    X'40B17218'                                              00003700
BIG      DC    X'47100000'                                              00003800
         ACLOSE                                                         00003900
