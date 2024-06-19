*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DACOS.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

 TITLE 'DACOS -- DOUBLE PRECISION INVERSE SINE-COSINE FUNCTION'         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
*  DACOS:  INVERSE SINE-COSINE(DOUBLE)                                  00000200
*                                                                       00000300
*        1. INPUT AND OUTPUT VIA F0.                                    00000400
*        2. FOR 0<=X<=1/2, COMPUTE ARCSIN(X) BY A RATIONAL FUNCTION.    00000500
*        3. FOR 1/2<X<=1, USE ARCSIN(X)=PI/2-2*ARCSIN(SQRT((1-X)/2)).   00000600
*        4. FOR X<0, USE ARCSIN(X)=-ARCSIN(-X).                         00000700
*        5. ARCCOS(X)=PI/2-ARCSIN(X).                                   00000800
*        6. ERROR GIVEN IF |X|>1 + EPSILON.                             00000900
*
* REVISION HISTORY
*
*IBM CR #SS8244  8/14/81   A. CLOSE                                     00000901
*     RETURN PI FOR DACOS ARGUMENT < -1                                 00000901
*                                                                       00001000
*DR101156  1/24/89  R. HANDLEY                                          00001000
*     CHECK FOR AN EPSILON VALUE. IF 1<=|ARGUMENT|<=1+EPSILON THEN      00001000
*     DON'T PRODUCE ERROR, BUT RETURN FIXUP VALUE.                      00001000
*     IF |ARGUMENT|>1+EPSILON THEN PRODUCE ERROR AND RETURN FIXUP       00001000
*     VALUE. EPSILON IS A DOUBLEWORD WITH THE LAST HALFWORD CONTAINING  00001000
*     ALL ONES.                                                         00001100
*                                                                       00001100
*DR103795 2/19/93  P. ANSLEY   -   INTERMETRICS
*     INCREASED EPSILON VALUE TO HANDLE ARGUMENTS BETWEEN
*     -1 AND 1 ACCURATE TO DOUBLE PRECISION REQUIREMENTS.
*
DACOS    AMAIN ACALL=YES,QDED=YES                                       00001200
* COMPUTES ARC-COSINE(X) IN DOUBLE PRECISION                            00001300
         INPUT F0             SCALAR DP                                 00001400
         OUTPUT F0            SCALAR DP RADIANS                         00001500
         WORK  R2,R3,R4,R5,R6,R7,F1,F2,F3,F4,F5,F6,F7                   00001600
         SR    R4,R4                                                    00001700
         OHI   R4,X'8000'     SET SWITCH 1 FOR ARCOS                    00001800
         B     MERGE                                                    00001900
DASIN    AENTRY                                                         00002000
* COMPUTES ARC-SINE(X) IN DOUBLE PRECISION                              00002100
         INPUT F0             SCALAR DP                                 00002200
         OUTPUT F0            SCALAR DP RADIANS                         00002300
         WORK  F1,F2,F4,F6,F7                                           00002400
         SR    R4,R4                                                    00002500
*                                                                       00002600
MERGE    LFXR  R2,F6          SAVE REGISTERS F6,F7                      00002700
         LFXR  R3,F7                                                    00002800
         SEDR  F4,F4          ZERO F4 IN CASE OF SKIPPED SECTIONS       00002900
         LER   F7,F1                                                    00003000
         LER   F6,F0                                                    00003100
         BNM   POS                                                      00003200
         OHI   R4,X'4000'     SET SWITCH 2 FOR NEGATIVE ARG             00003300
         LECR  F0,F0          GET |X|                                   00003400
*                                                                       00003500
POS      CE    F0,HALF                                                  00003600
         BNH   SMALL                                                    00003700
*                                                                       00003800
*  Z=SQRT((1-|X|)/2)                                                    00003900
*                                                                       00004000
         OHI   R4,X'2000'     SET SWITCH 3 FOR |X|>1/2                  00004100
         LECR  F0,F0                                                    00004200
         AED   F0,ONE         1-|X| IN F0                               00004300
         BNP   EXPRESS                                                  00004400
*                                                                       00004500
         LER   F6,F0                                                    00004600
         LER   F7,F1                                                    00004700
         MED   F6,HALF        Z**2 IN F6                                00004800
         AEDR  F0,F0          4*Z**2 IN F0                              00004900
*                                                                       00005000
         ACALL DSQRT          GET 2Z IN F0 BY CALL TO                   00005100
         B     POLY           SQRT, AND RETURN TO POLY                  00005200
*                                                                       00005300
SMALL    CE    F0,UNFLO                                                 00005400
         BNH   TESTS                                                    00005500
         MEDR  F6,F6          X**2 IN F6                                00005600
*                                                                       00005700
* COMPUTE ARCSIN(Z) HERE BY RATIONAL FUNCTION                           00005800
*                                                                       00005900
POLY     LED   F4,C5                                                    00006000
         AEDR  F4,F6                                                    00006100
         LED   F2,D4                                                    00006200
        QDEDR  F2,F4                                                    00006300
         AED   F2,C4                                                    00006400
         AEDR  F2,F6                                                    00006500
         LED   F4,D3                                                    00006600
        QDEDR  F4,F2                                                    00006700
         AED   F4,C3                                                    00006800
         AEDR  F4,F6                                                    00006900
         LED   F2,D2                                                    00007000
        QDEDR  F2,F4                                                    00007100
         AED   F2,C2                                                    00007200
         AEDR  F2,F6                                                    00007300
         LED   F4,D1                                                    00007400
        QDEDR  F4,F2                                                    00007500
         AED   F4,C1                                                    00007600
         MEDR  F4,F6                                                    00007700
         MEDR  F4,F0                                                    00007800
*                                                                       00007900
*  SET SIGN,ETC.                                                        00008000
*                                                                       00008100
TESTS    TRB   R4,X'A000'     IF ARCCOS ENTRY                           00008200
         BNM   TSTNEG         OR |X|>1/2,                               00008300
         SED   F4,ONE         BUT NOT BOTH                              00008400
         LECR  F4,F4                                                    00008500
         SED   F0,PIOV2M1                                               00008600
         LECR  F0,F0                                                    00008700
*                                                                       00008800
TSTNEG   AEDR  F0,F4                                                    00008900
         TRB   R4,X'4000'      COMPLEMENT                               00009000
         BNO   EXIT           IF ARGUMENT                               00009100
         LER   F0,F0          WORKAROUND FOR BUG                        00009200
         BZ    TEST2          IN LECR INSTRUCTION                       00009300
         LECR  F0,F0          WAS NEGATIVE                              00009400
TEST2    TRB    R4,X'C000'      AND ADD PI TO                           00009500
         BNO   EXIT           RESULT IF ARCCOS ENTRY                    00009600
         AED   F0,PI          AND ARGUMENT<0.                           00009700
*                                                                       00009800
EXIT     LFLR  F6,R2          RESTORE REGISTERS F6,F7                   00009900
         LFLR  F7,R3                                                    00010000
         AEXIT                                                          00010100
*                                                                       00010200
EXPRESS  BZ    TESTS          SKIP POLYNOMIAL IF |X|=1                  00010300
         AED   F0,EPSILON     CHECK FOR MACHINE ACCURACY      DR101156
         BNM   NOTERR         DON'T ERROR IF WITHIN LIMITS    DR101156
         AERROR 10            |ARG|>1+EPSILON                           00010400
NOTERR   SEDR  F0,F0          STANDARD FIXUP RETURNS 0        DR101156  00010500
         TRB   R4,X'8000'     ACOS CALL?                                00010600
         BO    TSTCOS         YES, TEST FOR X < -1                      00010700
         SEDR  F4,F4          ZERO REG                                  00010800
         B     TESTS          RETURN SIGN(X) PI/2 FOR ASIN              00010900
TSTCOS  TRB    R4,X'4000'     X NEGATIVE?                               00010901
        BZ     EXIT           NO                                        00010902
        LED    F0,PI          YES,RETURN PI                             00010903
        B      EXIT                                                     00010904
*                                                                       00011000
         DS    0D                                                       00011100
C1       DC    X'3F180CD96B42A610'        0.00587162904063511           00011200
D1       DC    X'C07FE6DD798CBF27'       -0.49961647241138661           00011300
C2       DC    X'C1470EC5E7C7075C'       -4.44110670602864049           00011400
D2       DC    X'C1489A752C6A6B54'       -4.53770940160639666           00011500
C3       DC    X'C13A5496A02A788D'       -3.64565146031194167           00011600
D3       DC    X'C06B411D9ED01722'       -0.41896233680025977           00011700
C4       DC    X'C11BFB2E6EB617AA'       -1.74882357832528117           00011800
D4       DC    X'BF99119272C87E78'       -0.03737027365107758           00011900
C5       DC    X'C11323D9C96F1661'       -1.19625261960154476           00012000
ONE      DC    X'4110000000000000'        1.0                           00012100
PIOV2M1  DC    X'40921FB54442D184'        PI/2 - 1.0                    00012200
PI       DC    X'413243F6A8885A30'        PI   -F                       00012300
HALF     DC    X'4080000000000000'        0.5                           00012400
UNFLO    DC    X'3A100000'                16**-7                        00012500
EPSILON  DC    X'3AFFFFFFF0000000'        5.96046445E-08      DR103795  00012500
         ACLOSE                                                         00012600
