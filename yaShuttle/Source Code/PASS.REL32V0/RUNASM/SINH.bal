*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    SINH.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

    TITLE 'SINH -- SINGLE PRECISION HYPERBOLIC SINE-COSINE FUNCTION'    00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
* SINH: HYPERBOLIC SINE-COSINE(SINGLE)                                  00000200
*                                                                       00000300
*        1. INPUT AND OUTPUT VIA F0.                                    00000400
*        2. IF  SINH ENTRY AND X<2.04E-4, GIVE SINH(X)=X.               00000500
*        3. IF SINH ENTRY AND 2.04<=X<1, COMPUTE SINH(X) DIRECTLY       00000600
*           WITH A POLYNOMIAL APPROXIMATION.                            00000700
*        4. OTHERWISE, COMPUTE USING EXP:                               00000800
*           SINH(X) = (1/2)(E**X-E**(-X));                              00000900
*           COSH(X) = (1/2)(E**X+E**(-X)).                              00001000
*        5. ERROR GIVEN IF X>175.366.                                   00001100
*                                                                       00001200
SINH     AMAIN ACALL=YES                                                00001300
* COMPUTES HYPERBOLIC SIN IN SINGLE PRECISION                           00001400
         INPUT F0             SCALAR SP                                 00001500
         OUTPUT F0            SCALAR SP                                 00001600
         WORK  R5,F2,F3,F4                                              00001700
         SR    R5,R5          R5=0 FOR SINH, X>=0                       00001800
         LER   F4,F0                                                    00001900
         BNM   POS                                                      00002000
         LFXI  R5,-1          R5<0 FOR SINH, X<0                        00002100
         LECR  F0,F0          GET |X|                                   00002200
*                                                                       00002300
POS      CE    F0,LIMIT                                                 00002400
         BNL   JOIN                                                     00002500
         CE    F0,UNFLO       IF |X|<2.04E-4,                           00002600
         BL    SIGN           GIVE SINH(X)=X                            00002700
*                                                                       00002800
*  IF X IS SMALL, COMPUTE SINH(X) DIRECTLY WITH A POLYNOMIAL            00002900
*                                                                       00003000
         MER   F0,F0          THE FORM OF THE POLYNOMIAL IS             00003100
         LER   F2,F0          X+C1X**3+C2X**5+C3X**7                    00003200
         ME    F0,C3                                                    00003300
         AE    F0,C2                                                    00003400
         MER   F0,F2                                                    00003500
         AE    F0,C1                                                    00003600
         MER   F0,F2                                                    00003700
         MER   F0,F4                                                    00003800
         AER   F0,F4                                                    00003900
         B     EXIT                                                     00004000
*                                                                       00004100
COSH     AENTRY                                                         00004200
* COMPUTES HYPERBOLIC COSINE IN SINGLE PRECISION                        00004300
         INPUT F0             SCALAR SP                                 00004400
         OUTPUT F0            SCALAR SP                                 00004500
         WORK  R5,F2,F3                                                 00004600
         LFXI  R5,1           R5>0 FOR COSH                             00004700
         LER   F0,F0                                                    00004800
         BNM   JOIN                                                     00004900
         LECR  F0,F0          GET |X|                                   00005000
*                                                                       00005100
JOIN     CE    F0,MAX         GIVE ERROR IF                             00005200
         BH    ERROR          |X|>175.366                               00005300
*                                                                       00005400
*  NOW,COMPUTE SINH OR COSH USING EXP. V IS INTRODUCED                  00005500
*  TO CONTROL ROUNDING ERRORS, AND IS EQUAL TO 0.4995050                00005600
*                                                                       00005700
         AE    F0,LNV                                                   00005800
         ACALL EXP                                                      00005900
*                                                                       00006000
*  F0 CONTAINS EXP(X+LN(V))                                             00006100
*                                                                       00006200
         LE    F2,VSQ                                                   00006300
         DER   F2,F0                                                    00006400
         LR    R5,R5                                                    00006500
         BNP   ESINH                                                    00006600
         AER   F0,F2                                                    00006700
         B     ROUND                                                    00006800
ESINH    SER   F0,F2                                                    00006900
*                                                                       00007000
*  F0 CONTAINS V(E**X+E**(-X)) FOR COSH, OR V(E**X-E**(-X)) FOR SINH    00007100
*                                                                       00007200
ROUND    LE    F3,LNV         ROUNDING OCCURS HERE.                     00007300
         LER   F2,F0          THE NUMBER DELTA IS SUCH                  00007400
         ME    F0,DELTA       THAT 1+DELTA=1/(2V).                      00007500
         AEDR  F0,F2                                                    00007600
*                                                                       00007700
SIGN     LR    R5,R5                                                    00007800
         BNM   EXIT                                                     00007900
         LER   F0,F0          WORKAROUND FOR BUG                        00008000
         BZ    EXIT           IN LECR INSTRUCTION.                      00008100
         LECR  F0,F0                                                    00008200
*                                                                       00008300
EXIT     AEXIT                                                          00008400
*                                                                       00008500
ERROR    AERROR 9             ARG > 175.366                             00008600
         LE    F0,INFINITY                                              00008700
         B     EXIT                                                     00008800
*                                                                       00008900
         DS    0F                                                       00009000
MAX      DC    X'42AF5DC0'    175.366                                   00009100
LIMIT    DC    X'41100000'    1.0                                       00009200
VSQ      DC    X'403FDF95'    V**2=0.2495053                            00009300
LNV      DC    X'C0B1B300'    LN(V)=-.6941376                           00009400
DELTA    DC    X'3E40F043'    1/(2V)-1=.99088E-3                        00009500
C1       DC    X'402AAAB8'    0.16666734                                00009600
C2       DC    X'3F221E8C'    .008329912                                00009700
UNFLO    EQU   *                                                        00009800
C3       DC    X'3DD5D8B3'    .2039399E-3                               00009900
INFINITY DC    X'7FFFFFFF'                                              00010000
         ACLOSE                                                         00010100
