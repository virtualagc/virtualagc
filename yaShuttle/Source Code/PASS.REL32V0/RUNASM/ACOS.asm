*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    ACOS.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time
*/              library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the
*/              Virtual AGC Project. Comments beginning merely with *
*/              are from the original Space Shuttle development.

 TITLE 'ACOS -- SINGLE PRECISION INVERSE SINE-COSINE FUNCTION'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
*  ACOS:  INVERSE SINE-COSINE(SINGLE)                                   00000200
*                                                                       00000300
*        1. INPUT AND OUTPUT VIA F0.                                    00000400
*        2. FOR 0<=X<=1/2, COMPUTE ASIN(X) BY A RATIONAL FUNCTION.      00000500
*        3. FOR 1/2<X<=1, USE ASIN(X)=PI/2-2*ASIN(SQRT((1-X)/2)).       00000600
*        4. FOR X<0, USE ASIN(X)=-ASIN(-X).                             00000700
*        5. ACOS(X)=PI/2-ASIN(X).                                       00000800
*        6. ERROR GIVEN IF |X|>1.                                       00000900
*                                                                       00001000
*IBM CR #SS8244- RETURN PI FOR ARCCOS ARGUMENT < -1; 8/14/81   A.CLOSE  00001010
* REGISTER R4 IS USED AS A SWITCH-                                      00001100
*   BIT 0 IS USED TO SIGNAL WHETHER THIS PROCEDUER IS                   00001200
*   CALLED AS ACOS(ON) OR ASIN(OFF). BIT 1 IS USED TO SIGNAL            00001300
*   IF ARG. IS POS.(OFF) OR NEG.(ON).BIT 2 IS USED TO SIGNAL            00001400
*   ABS. VALUE OF ARG.,IF GREATER THAN 1/2(ON) ELSE (OFF)               00001500
*                                                                       00001600
         MACRO                                                          00001700
         WORKAREA                                                       00001800
SAVE6    DS    D              TO SAVE REGISTERS F6,F7                   00001900
SWITCH   DS    F              TO SAVE R4 ACROSS INTRINSIC CALL          00002000
         MEND                                                           00002100
ACOS     AMAIN ACALL=YES                                                00002200
*COMPUTES ARC-COSINE(X) OF SINGLE PRECISION SCALAR                      00002300
         INPUT F0             SCALAR SP                                 00002400
         OUTPUT F0            SCALAR SP RADIANS                         00002500
         WORK  R1,R2,R3,R4,R5,R6,R7,F1,F2,F3,F4,F6                      00002600
         SR    R4,R4          SIGNAL ACOS ENTRY                         00002700
         OHI   R4,X'8000'                                               00002800
         B     MERGE                                                    00002900
ASIN     AENTRY                                                         00003000
* COMPUTES ARC-SINE(X) OF SINGLE PRECISION SCALAR                       00003100
         INPUT F0             SCALAR SP                                 00003200
         OUTPUT F0            SCALAR SP RADIANS                         00003300
         WORK  R2,R3,R4,F2,F3,F4,F6                                     00003400
         SR    R4,R4          SIGNAL ASIN ENTRY                         00003500
*                                                                       00003600
MERGE    STED  F6,SAVE6       SAVE REGISTERS F6,F7                      00003700
         LER   F6,F0          GET ARGUMENT IN F6                        00003800
         BNM   POS            AND TEST SIGN                             00003900
         OHI   R4,X'4000'     SIGNAL NEG. ARG.                          00004000
         LECR  F0,F0          GET |X|                                   00004100
*                                                                       00004200
POS      CE    F0,HALF        SKIP TO 'SMALL' IF                        00004300
         BNH   SMALL          |X|<=1/2                                  00004400
*                                                                       00004500
*  Z=SQRT((1-|X|)/2) IF |X|^>|1/2                                       00004600
*                                                                       00004700
         OHI   R4,X'2000'     SIGNAL |X|>1/2                            00004800
         LECR  F0,F0                                                    00004900
         AE    F0,ONE         1-|X| IN F0                               00005000
         BNP   EXPRESS        BRANCH IF |X|>=1                          00005100
*                                                                       00005200
         LER   F6,F0                                                    00005300
         ME    F6,HALF        Z**2 IN F6                                00005400
         AER   F0,F0          4*Z**2 IN F0                              00005500
*                                                                       00005600
         ST    R4,SWITCH      SAVE R4 ACROSS INTRINSIC CALL             00005700
         ABAL  SQRT           GET 2Z IN F0 BY CALL TO                   00005800
         L     R4,SWITCH      RESTORE R4                                00005900
         B     POLY           SQRT, AND RETURN TO POLY                  00006000
*                                                                       00006100
SMALL    CE    F0,UNFLO                                                 00006200
         BNH   TESTS                                                    00006300
         MER   F6,F6          X**2 IN F6                                00006400
*                                                                       00006500
* COMPUTE ASIN(Z) HERE BY RATIONAL FUNCTION                             00006600
*                                                                       00006700
POLY     LE    F4,C2                                                    00006800
         AER   F4,F6                                                    00006900
         LE    F2,D2                                                    00007000
         DER   F2,F4          (C2+Z**2)/D2                              00007100
         AE    F2,C1                                                    00007200
         AER   F2,F6          C1+Z**2+(C2+Z**2)/D2                      00007300
         ME    F6,D1                                                    00007400
         DER   F6,F2                                                    00007500
         LE    F3,ROUND       ROUNDING NUMBER IN F3,                    00007600
         LER   F2,F0          AS LOW HALF OF 2Z.                        00007700
         MER   F0,F6                                                    00007800
         AEDR  F0,F2          ROUNDING OCCURS HERE                      00007900
*                                                                       00008000
*  REVERSE REDUCTIONS TO GIVE ACTUAL ANSWER                             00008100
*                                                                       00008200
TESTS    TRB    R4,X'A000'  IF ACOS ENTRY                               00008300
         BNM   TSTNEG         OR |X|>1/2 BUT NOT BOTH,                  00008400
         LECR  F0,F0          SUBTRACT RESULT                           00008500
         AED   F0,PIOV2       FROM PI/2                                 00008600
*                                                                       00008700
TSTNEG   TRB    R4,X'4000'  COMPLEMENT                                  00008800
         BNO   EXIT           IF ARGUMENT WAS NEGATIVE.                 00008900
         LER   F0,F0          CHECK FOR ARG=0(HARDWARE BUG)             00009000
         BZ    NOLECR                                                   00009100
         LECR  F0,F0                                                    00009200
NOLECR   TRB   R4,X'C000'     AND ADD PI TO                             00009300
         BNO   EXIT           RESULT IF ACOS ENTRY                      00009400
         AE    F0,PI          AND ARGUMENT<0.                           00009500
*                                                                       00009600
EXIT     LED   F6,SAVE6       RESTORE F6,F7                             00009700
         AEXIT                AND EXIT                                  00009800
*                                                                       00009900
EXPRESS  BZ    TESTS          SKIP POLYNOMIAL IF |X|=1                  00010000
         AERROR 10            |ARG|>1                                   00010100
         LE    F0,PIOV2                                                 00010200
         TRB   R4,X'8000'     ASIN CALL?                                00010300
         BZ    TSTNEG         YES, CHECK SIGN                           00010400
         TRB   R4,X'4000'     X=-1?                                     00010500
         BZ    RET0           NO,RETURN 0                               00010501
         LE    F0,PI          YES, RETURN PI                            00010502
         B     EXIT                                                     00010503
RET0     SER   F0,F0                                                    00010504
         B     EXIT                                                     00010600
*                                                                       00010700
         DS    0F                                                       00010800
PI       DC    X'413243F7'    PI                                        00010900
PIOV2    DC    X'411921FB'    PI/2                                      00011000
ROUND    DC    X'5FFFFFFF'                                              00011100
UNFLO    DC    X'3E100000'     16**(-3)                                 00011200
ONE      DC    X'41100000'    1.0                                       00011300
HALF     DC    X'40800000'    0.5                                       00011400
D1       DC    X'C08143C7'    -0.5049404                                00011500
C1       DC    X'C13B446A'    -3.7042025                                00011600
D2       DC    X'C11406BF'    -1.2516474                                00011700
C2       DC    X'C11DB034'    -1.8555182                                00011800
         ACLOSE                                                         00011900
