*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    EATAN2.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'ARCTANGENT(SINGLE,2 ENTRIES)'                          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
EATAN2   AMAIN                                                          00000200
* COMPUTES ARC-TANGENT(ARG1,ARG2) BY FRACTIONAL APPROXIMATION IN        00000300
* THE RANGE (-PI,PI) IN SINGLE PRECISION                                00000400
         INPUT F0,            SCALAR SP                                X00000500
               F2             SCALAR SP                                 00000600
         OUTPUT F0            SCALAR SP RADIANS                         00000700
         WORK  R1,R2,R4,R5,R6,R7,F1,F4,F5,F6,F7                         00000800
         OHI   R1,X'FFFF'     FLAG=1 FOR ARCTAN2                        00000900
         B     MERGE                                                    00001000
ATAN     AENTRY                                                         00001100
* COMPUTES ARCTAN(X) BY FRACTIONAL APPROXIMATION IN                     00001200
* THE RANGE (-PI/2,PI/2) IN SINGLE PRECISION                            00001300
         INPUT F0             SCALAR SP                                 00001400
         OUTPUT F0            SCALAR SP RADIANS                         00001500
         WORK  R2,F2,F4,F6                                              00001600
         SR    R1,R1          FLAG=0 FOR ARCTAN                         00001700
MERGE    SER   F1,F1          THIS IS TO PREVENT UNORMALIZED INPUT      00002000
*                             TO FLOATING DIVIDE                        00002100
         LA    R2,DATA     SET POINTER TO ADDRESS OF FULLWORD '0'       00002200
         LFXR  R6,F0        SAVE FIRST(OR ONLY) ARG                     00002300
         LR    R6,R6          TEST SIGN OF FIRST(OR ONLY) ARG           00002400
         BNM   TEST1                                                    00002500
MINUS    LECR  F0,F0    USE POSITIVE ARG                                00002600
TEST1    LR    R1,R1          SET CONDITION CODE ACCORDING TO ENTRY     00002700
         BZ    ATAN1   IF ATAN ENTRY, SKIP TO MAIN CIRCUIT              00002800
*  IF ARCT2 ENTRY THEN DO THIS                                          00002900
         LFXR  R7,F2          SAVE COSARG                               00003000
         LR    R7,R7          SET CONDITION CODE FOR COSARG             00003100
         BNZ   CHECK                                                    00003200
         LR    R6,R6          IF COSARG=SINARG=0,                       00003210
         BZ    ERROR              THEN ERROR                            00003220
VALUE    LE    F0,PIOV2       IF COSARG=0,SINARG NOT=0,RETURN +/- PI/2  00003230
         B     STEST                                                    00003240
*    PROTECTION ADDED TO AVOID EXPONENT OVERFLOW IN THE DEIVDE WHICH    00003241
*    COMPUTES THE TANGENT.  THE PROTECTION SCHEME DEFAULTS TO           00003242
*    +/- PI/2 WHEN EXPONENT(SINARG) - EXPONENT(COSARG) >= 7.            00003243
CHECK    LFXR  R4,F0          GET EXPONENT OF SINARG * 16**2(I.E. EXP   00003250
         NHI   R4,X'7F00'        IS IN HIGH ORDER BITS,                 00003260
*                                0'S IN LOW ORDER BITS).                00003261
         LER   F0,F0          IF SINARG=0, CONTINUE WITH TANGENT        00003262
         BZ    TANDIV            DIVIDE                                 00003263
         LFXR  R5,F2          GET EXPONENT OF COSARG * 16**2            00003270
         NHI   R5,X'7F00'                                               00003280
         SR    R4,R5          DELTA =(EXP(SINARG)-EXP(COSARG)) * 16**2  00003290
         CHI   R4,X'0700'     IF DELTA >=  7 * 16**2,                   00003291
         BNL   VALUE              RETURN +/- PI/2                       00003292
*    BEGINNING OF TANGENT APPROXIMATION ALGORITHM.                      00003293
TANDIV   DER   F0,F2    X=|SINARG|/COSARG                               00003300
         LR    R7,R7   CHECK SIGN OF COSARG                             00003310
         BP    NORM    COSARG>0,X=|SINARG|/|COSARG|, SO CONTINUE        00003400
         LECR  F0,F0    COSARG<0, LOAD POSITIVE X                       00003500
         CE    F0,LOWLIM IF COSARG<0 AND X<=16**-6 THEN RETURN +/- PI   00003600
         BH    NORM                                                     00003700
         LE    F0,PI                                                    00003800
         B     STEST                                                    00003900
NORM     CE    F0,HIGHLIM   IF COSARG NOT=0 AND X>16**6                 00004400
         BH    VALUE      THEN RETURN +/- PI/2                          00004500
*   MAIN CIRCUIT- ATAN FN WITH SINARG=TAN% OR X=|SINARG|/|COSARG|       00004600
*   FIND %(ANGLE) AND FIX QUADRANTS AND SIGN OF RESULT                  00004700
ATAN1    CE    F0,FLONE                                                 00004800
         BNH   REDUC   IF X>1, THEN TAKE INVERSE                        00004900
         LER   F2,F0   PUT X IN F2                                      00005000
         LE    F0,FLONE                                                 00005100
         DER   F0,F2   F0=1/X                                           00005200
         LA    R2,4(R2)   MEANS REDUCTION FOR X>1 TAKEN                 00005300
*   CHECK FOR X<16**-3.  ALSO, CHECK IF X<=TAN(PI/12)                   00005400
*   IF NOT, THEN REDUCE X                                               00005500
REDUC    CE    F0,SMALL    IF X<16**-3 THEN ANSWER=X                    00005600
         BL    READY       THIS AVOIDS UNDERFLOW EXCEPTION              00005700
         LFXR  R4,F6          SAVE F6                                   00005710
         LFXR  R5,F7          SAVE F7                                   00005720
         CE    F0,TAN15    IF X>TAN(PI/12), THEN REDUCE USING           00005800
         BNH   OK          ATAN(X)=PI/6+TAN(Y), WHERE                   00005900
         LER   F2,F0       Y=(X*SQRT3-1)/(X+SQRT3)                      00006000
         ME    F0,RT3M1                                                 00006100
         SE    F0,FLONE    TO PROTECT SIGNIFICANT BITS, COMPUTE         00006200
         AER   F0,F2       X*SQRT3-1 AS X(SQRT3-1)-1+X                  00006300
         AE    F2,RT3                                                   00006400
         DER   F0,F2                                                    00006500
         LA    R2,2(R2)    MEANS REDUCTION FOR X OR 1/X>TAN(PI/12)      00006600
*   NOW X IS LESS THAN TAN(PI/12), SO COMPUTE ATAN                      00006700
OK       LER   F4,F0     F4=X                                           00006800
         MER   F0,F0    ATAN(X)/X=D+C*XSQ+B/(XSQ+A)                     00006900
         LER   F2,F0                                                    00007000
         ME    F0,C                                                     00007100
         AE    F2,A                                                     00007200
         LE    F6,B                                                     00007300
         SER   F7,F7          THIS IS TO PREVENT UNNORMALIZED INPUT     00007400
*                             TO FLOATING DIVIDE                        00007500
         DER   F6,F2                                                    00007600
         AER   F0,6                                                     00007700
         AE    F0,D                                                     00007800
         MER   F0,F4     MULTIPLY BY X;  F0=ATAN(X)                     00007900
         LFLR  F6,R4     RESTORE F6,F7                                  00007910
         LFLR  F7,R5                                                    00007920
*   NOW ADJUST ANGLE TO PROPER SECTION                                  00008000
*   R2=0 MEANS X<=TAN(PI/12)   ACTION TAKEN- ADD 0                      00008100
*   R2=2(0) MEANS TAN(PI/12)<X<=1   ACTION TAKEN- ADD PI/6              00008200
*   R2=4 MEANS 1/X<=TAN(PI/12)   ACTION TAKEN- SUBTRACT PI/2            00008300
*   R2=2(4) MEANS 1/X>TAN(PI/12)   ACTION TAKEN- SUBTRACT PI/3          00008400
READY    AE    F0,0(R2)     SETS CONDITION CODE                         00008500
         BNM   POSOK     WANT POSITIVE ANSWER                           00008600
         LECR  F0,F0                                                    00008700
*   ANSWER POSITIVE.  CHECK IF EATAN2 ENTRY AND COSARG<0                00008800
*   IF SO, THEN F0=PI-F0                                                00008900
*   IF TWO ARGS(EATAN2 ENTRY), THEN ANSWER IN RANGE (-PI,PI)            00009000
POSOK    LR    R1,R1      SET CONDITION CODE                            00009100
         BZ    STEST                                                    00009200
         LR    R7,R7          EATAN2-CHECK COSARG                       00009300
         BNM   STEST      GO TO STEST IF COSARG>=0                      00009400
         LE    F2,PI                                                    00009500
         SER   F2,F0      COSARG<0                                      00009600
         LER   F0,F2    ANSWER IN F0                                    00009700
         BNM   STEST    WANT POSITIVE ANSWER                            00009800
         LECR  F0,F0                                                    00009900
*   STEST MAKES SIGN OF ANSWER AGREE WITH SIGN OF SINARG                00010000
*   IF ONLY ONE ARG(ATAN ENTRY), THEN ANSWER IN RANGE (-PI/2,PI/2)      00010100
STEST    LR    R6,R6          SET CONDITION CODE                        00010200
         BNM   EXIT                                                     00010300
         LER   F0,F0          WORKAROUND FOR BUG                        00010400
         BZ    EXIT           IN LECR INSTRUCTION.                      00010500
         LECR  F0,F0                                                    00010600
EXIT     AEXIT                                                          00010900
*     ERROR HANDLER FOR SINARG=COSARG=0                                 00011000
ERROR    SER   F0,F0                                                    00011100
         AERROR 62            ARG1=ARG2=0                               00011200
         B     EXIT                                                     00011300
         DS   0F    ALIGN ON FULLWORD BOUNDARY                          00011400
FLONE    DC   X'41100000'                                               00011500
FLZERO   DC   X'00000000'                                               00011600
PI       DC   X'413243F7'                                               00011700
PIOV2    DC   X'411921FB'   +PI/2                                       00011800
LOWLIM   DC   X'3B100000'   16**-6                                      00011900
HIGHLIM  DC   X'47100000'   16**6                                       00012000
A        DC   X'41168A5E'   1.4087812                                   00012100
B        DC   X'408F239C'   0.55913711                                  00012200
C        DC   X'BFD35F49'  -0.051604543                                 00012300
D        DC   X'409A6524'   0.60310579                                  00012400
RT3M1    DC   X'40BB67AF'   SQRT3-1                                     00012500
RT3      DC   X'411BB67B'   SQRT3                                       00012600
SMALL    DC   X'3E100000'   16**-3                                      00012700
TAN15    DC   X'40449851'   TAN(PI/12)                                  00012800
         ADATA                                                          00012900
DATA     DC   E'0'                  THESE FOUR                          00013000
         DC   X'40860A92'   PI/6      CONSTANTS                         00013100
         DC   X'C11921FB'  -PI/2         MUST BE                        00013200
         DC   X'C110C152'  -PI/3            CONSECUTIVE                 00013300
         ACLOSE                                                         00013400
