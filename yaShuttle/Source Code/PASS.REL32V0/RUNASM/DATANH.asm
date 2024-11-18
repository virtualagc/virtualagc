*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DATANH.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.
         TITLE 'ARCTANCH,DOUBLE PRECISION'                              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
*        ARCTANH(X)=1/2*LN(1+X)/(1-X)                                   00000200
*                                                                       00000300
* THE FUNCTION IS MADE ODD BY COMPUTING IT FOR A POSITIVE ARGUMENT,     00000400
* THEN CHANGING THE SIGN OF THE RESULT IF THE ARGUMENT WAS              00000500
* NEGATIVE. IF ABS(X) IS SO SMALL THAT THE NEXT TERM IN THE TAYLOR      00000600
* SERIES FOR ARCTANH(X) WOULDN'T CHANGE THE RESULT, THEN X IS RETURNED. 00000700
* FOR LARGER ABS(X), THE TAYLOR SERIES IS CALCULATED. IF ABS(X) HAS AN  00000800
* EXPONENT LARGE ENOUGH TO PREVENT LARGE ACCURACY LOSSES, THEN THE LOG  00000900
* FUNCTION IS USED TO EVALUATE THE FUNCTION STRAIGHTFORWARDLY. IF       00001000
* ABS(X) IS GREATER THAN ONE, AN ERROR IS SIGNALED.                     00001100
*                                                                       00001200
* REVISION HISTORY                                                      00002502
*                                                                       00002602
*DR101156  1/24/89  R. HANDLEY                                          00003002
*     CHECK FOR AN EPSILON VALUE. IF 1<=|ARGUMENT|<=1+EPSILON THEN      00003102
*     DON'T PRODUCE ERROR, BUT RETURN FIXUP VALUE.                      00003202
*     IF |ARGUMENT|>1+EPSILON THEN PRODUCE ERROR AND RETURN FIXUP       00003302
*     VALUE. EPSILON IS A DOUBLEWORD WITH THE LAST HALFWORD CONTAINING  00003402
*     ALL ONES.                                                         00003502
*                                                                       00003602
*DR103795 2/22/93  P. ANSLEY  -  INTERMETRICS                           00016102
*     INCREASED EPLUS1 VALUE TO HANDLE ARGUMENTS BETWEEN
*     -1 AND 1 ACCURATE TO DOUBLE PRECISION REQUIREMENTS.
*
DATANH   AMAIN   ACALL=YES,QDED=YES                                     00016200
* COMPUTES HYPERBOLIC ARC-TANGENT IN DOUBLE PRECISION                   00016300
         INPUT F0             SCALAR DP                                 00016400
         OUTPUT F0            SCALAR DP                                 00016500
         WORK  R7,F1,F2,F3,F4,F5                                        00016600
         LFXR  R7,F0                                                    00016700
          LER F0,F0                                                     00016800
         BNM   POS                                                      00016900
         LECR     F0,F0                                                 00017000
POS      CED   F0,ONE                                                   00017101
         BNL   TESTE          TEST FOR EPSILON               DR101156   00017201
         CE    F0,TINY                                                  00017300
         BL    SIGN                                                     00017400
         CE    F0,SMALL                                                 00017500
         BNL   NORMAL         IF TINY< X <SMALL                         00017600
         LER   F2,F0          THEN COMPUTE TAYLOR SERIES =              00017700
         LER   F3,F1          X+X**3/3+X**5/5+X**7/7                    00017800
         MEDR  F2,F2          +X**9/9+X**11/11                          00017900
         LER  F4,F2                                                     00018000
         LER   F5,F3                                                    00018100
         MED   F4,A11                                                   00018200
         AED   F4,A9                                                    00018300
         MEDR  F4,F2                                                    00018400
         AED   F4,A7                                                    00018500
         MEDR  F4,F2                                                    00018600
         AED   F4,A5                                                    00018700
         MEDR  F4,F2                                                    00018800
         AED   F4,A3                                                    00018900
         MEDR  F4,F2                                                    00019000
         AED   F4,ONE                                                   00019100
         MEDR  F0,F4                                                    00019200
         B     SIGN                                                     00019300
NORMAL   LECR  F2,F0                                                    00019400
         LER   F3,F1                                                    00019500
         AED   F2,ONE                                                   00019600
         AED   F0,ONE                                                   00019700
        QDEDR  F0,F2                                                    00019800
         ACALL DLOG                                                     00019900
        QDED   F0,TWO                                                   00020000
SIGN     LR    R7,R7                                                    00020100
         BNM   EXIT                                                     00020200
         LER   F0,F0          WORKAROUND FOR BUG                        00020300
         BZ    EXIT           IN LECR INSTRUCTION                       00020400
         LECR  F0,F0                                                    00020500
EXIT     AEXIT                                                          00020600
TESTE    CED   F0,EPLUS1                                     DR101156   00020701
         BNH   NOTERR                                        DR101156   00020801
         AERROR 60            -1-EPSILON<ARG<1+EPSILON       DR101156   00020901
NOTERR   SEDR  F0,F0                                         DR101156   00021001
         B     EXIT                                                     00021100
ONE      DC    D'1'                                                     00021200
TWO      DC    D'2'                                                     00021300
A3       DC    X'4055555555555555'                                      00021400
A5       DC    X'4033333333333333'                                      00021500
A7       DC    X'4024924924924925'                                      00021600
A9       DC    X'401C71C71C71C71C'                                      00021700
A11      DC    X'401745D1745D1746'                                      00021800
TINY     DC    X'3A2E26E8'         /* 1.074559E-8 */                    00021903
SMALL    DC    X'40100000'         /* 6.25E-2 */                        00022003
EPLUS1   DC    X'411000000FFFFFFF' /* 1.0000000596046445 */  DR103795   00023003
         ACLOSE                                                         00030000
