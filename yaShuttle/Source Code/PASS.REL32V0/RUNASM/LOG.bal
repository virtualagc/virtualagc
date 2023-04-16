*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    LOG.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

       TITLE 'LOG -- SINGLE PRECISION NATURAL LOGARITHM FUNCTION'       00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
* LOG: LOGARITHM(SINGLE PRECISION)                                      00000200
*                                                                       00000300
*        1. INPUT AND OUTPUT VIA F0.                                    00000400
*        2. LET X = (16**P)(2**(-Q))(M), WHERE P AND Q ARE INTEGERS,    00000500
*           0<=Q<=3, AND 1/2<=M<1.                                      00000600
*        3. IF M>SQRT(2)/2, LET A=1,B=0. OTHERWISE, LET A=0,B=1.        00000700
*        4. LET Z=(M-A)/(M+A).                                          00000800
*        5. THEN LOG(X)=(4P-Q-B)LOG(2)+LOG((1+Z)/(1-Z)).                00000900
*        6. AN ERROR IS GIVEN IF X<=0.                                  00001000
*        7. FLOATING REGISTERS USED: F0-F5.                             00001100
*                                                                       00001200
LOG      AMAIN                                                          00001300
* COMPUTES LOG(X) IN SINGLE PRECISION                                   00001400
         INPUT F0             SCALAR SP                                 00001500
         OUTPUT F0            SCALAR SP                                 00001600
         WORK  R5,R6,R7,F1,F2,F3,F4                                     00001700
START    SER   F1,F1                                                    00001800
         LER   F2,F0          CLEAR F1 TO PREVENT UNDERFLOW ERORS AS F1 00001900
*                             IS GARBAGE SINCE THIS IS A SINGLE PRECIS- 00002000
*                             ON ROUTINE                                00002100
         BNP   ERROR                                                    00002200
         LFXR  R6,F0                                                    00002300
         SR    R7,R7          CLEAR R7 TO RECEIVE MANTISSA              00002400
         SRDL  R6,24          P+64 IN R6 LOW 8 BITS                     00002500
         SRL   R7,1                                                     00002600
         NCT   R5,R7          Q IN R5 TOP HALFWORD, M IN R7             00002700
         SLL   R6,18          4(P+64) IN R6 TOP HALFWORD                00002800
         SR    R6,R5          (4P-Q)+OFFSET IN R6                       00002900
         LFLI  F2,1           A=1, B=0 IF M>SQRT(2)/2                   00003000
         LE    F3,HALF        A/2=1/2                                   00003100
         C     R7,LIMIT                                                 00003200
         BH    POS                                                      00003300
         LE    F2,HALF        A=1/2 IF M<=SQRT(2)/2                     00003400
         LE    F3,QUARTER     A/2=1/4                                   00003500
         AHI   R6,X'FFFF'     B=1                                       00003600
*                                                                       00003700
POS      AHI   R6,X'FF00'     4P-Q-B READY IN R6 TOP                    00003800
         SRL   R7,7                                                     00003900
         AHI   R7,X'4000'     FLOAT M AND                               00004000
         LFLR  F0,R7          PUT IN F0                                 00004100
*                                                                       00004200
         LER   F4,F0          M IN F4                                   00004300
         SER   F0,F2          M-A IN F0                                 00004400
         BZ    ELSPETH        IF Z=0, LOG((1+Z)/(1-Z))=0                00004500
         ME    F4,HALF        M/2 IN F4                                 00004600
         AER   F4,F3          M/2+A/2 IN F4                             00004700
         DER   F0,F4          W IN F2. W=2Z=2(M-A)/(M+A)                00004800
*                                                                       00004900
         LER   F2,F0          NOW, COMPUTE LOG((1+Z)/(1-Z))             00005000
         MER   F0,F0          BY THE MINIMAX APPROXIMATION              00005100
         LE    F4,S           W+W(R*W**2/(S-W**2))                      00005200
         SER   F4,F0                                                    00005300
         ME    F0,R                                                     00005400
         DER   F0,F4                                                    00005500
         MER   F0,F2                                                    00005600
         LE    F3,ROUND                                                 00005700
         AEDR  F0,F2          W+W(R*W**2/(S-W**2))                      00005800
*                                                                       00005900
*  NOW, WE HAD TO KLUDGE TO GET AROUND                                  00006000
*  ERROR IN SIMULATION OF CVFL. IN THE FINAL                            00006100
*  VERSION, THE FOLLOWING SEQUENCE IS                                   00006200
*  REPLACED BY THE SINGLE INSTRUCTION:                                  00006300
*                                                                       00006400
ELSPETH  CVFL  F2,R6                                                    00006500
*                                                                       00006600
*ELSPETH  LR    R6,R6                                                   00006700
*         BNM   CVPOS                                                   00006800
*         LACR  R6,R6                                                   00006900
*         AHI   R6,X'C200'                                              00007000
*         B     NEXXT                                                   00007100
*CVPOS    AHI   R6,X'4200'                                              00007200
*NEXXT    LFLR  F2,R6                                                   00007300
*                                                                       00007400
*  END OF KLUDGE                                                        00007500
*                                                                       00007600
         ME    F2,LOGE2       (4P-Q-B)LOG(2)                            00007700
         AEDR  F0,F2          ANSWER IN F0                              00007800
EXIT     AEXIT                                                          00007900
*                                                                       00008000
ERROR    AERROR 7             ARG <= 0                                  00008100
* FIXUP SECTION                                                         00008200
         LER   F0,F0                                                    00008300
         BZ    ARGZERO                                                  00008400
         LECR  F0,F0          IF ARG<0, GET |ARG|                       00008500
         B     START          AND TRY AGAIN.                            00008600
*                                                                       00008700
ARGZERO  LE    F0,INFINITY    IF ARG=0, RETURN MAXIMUM NEGATIVE         00008800
         B     EXIT           FLOATING POINT NUMBER.                    00008900
*                                                                       00009000
         DS    0F                                                       00009100
LIMIT    DC    X'5A8279D8'    SQRT(2)/2                                 00009200
ROUND    DC    X'F0000000'                                              00009300
LOGE2    DC    X'40B17219'    LOG(BASE E)2 + FUDGE                      00009400
R        DC    X'408D8BC7'    0.55291413                                00009500
S        DC    X'416A298C'    6.6351437                                 00009600
HALF     DC    X'40800000'    0.5                                       00009700
QUARTER  DC    X'40400000'    0.25                                      00009800
INFINITY DC    X'FFFFFFFF'                                              00009900
         ACLOSE                                                         00010000
