*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DATAN2.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'ARCTANGENT(DOUBLE,2 ENTRIES)'                          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
DATAN2   AMAIN QDED=YES                                                 00000200
* COMPUTES ARCTAN2(ARG1,ARG2) BY FRACTIONAL APPROXIMATION IN            00000300
* THE RANGE (-PI,PI) IN DOUBLE PRECISION                                00000400
*
*  REVISION HISTORY:
*
*   DATE       NAME  DR/SSCR#   DESCRIPTION
*   --------   ----  --------   --------------------------------------
*   12/16/89   JAC   DR103762   REPLACED QCED/QCEDR MACRO WITH
*                               CED/CEDR INSTRUCTION
*
         INPUT F0,            SCALAR DP                                X00000500
               F2             SCALAR DP                                 00000600
         OUTPUT F0            SCALAR DP RADIANS                         00000700
         WORK  R1,R2,R3,R4,R5,R6,R7,F1,F3,F4,F6,F7                      00000800
         OHI   R1,X'FFFF'     USING R1 TO FLAG THE ENTRY POINT          00000900
         B     MERGE                                                    00001000
DATAN    AENTRY                                                         00001100
* COMPUTES ARCTAN(X) BY FRACTIONAL APPROXIMATION IN                     00001200
* THE RANGE (-PI/2,PI/2) IN DOUBLE PRECISION                            00001300
         INPUT F0             SCALAR DP                                 00001400
         OUTPUT F0            SCALAR DP RADIANS                         00001500
         WORK  R1,R2,R3,R4,R5,R6,R7,F1,F2,F3,F4,F6                      00001600
         SR    R1,R1          SET R1 TO SIGNAL DATAN ENTRY              00001700
MERGE    LFXR  R6,F0          SAVE THE SIGN OF F0 IN R6                 00002100
         LER   F0,F0                                                    00002200
         BNM   TEST1    IF SINARG < 0,                                  00002300
MINUS    LECR  F0,F0         USE POSITIVE ARG                           00002400
TEST1    LR    R1,R1    CHECK CONDITION CODE                            00002500
         BZ    DATAN1   IF DATAN ENTRY, SKIP TO MAIN CIRCUIT            00002600
*  IF ARCT2 ENTRY THEN DO THIS                                          00002700
         LFXR  R7,F2          SAVE SIGN OF COSARG                       00002800
         LER   F2,F2                                                    00002900
         BNZ   CHECK                                                    00003000
         LER   F0,F0        IF COSARG=SINARG=0,                         00003010
         BZ    ERROR            THEN ERROR                              00003020
VALUE    LED   F0,PIOV2   IF COSARG=0,SINARG NOT=0,RETURN +/- PI/2      00003030
         B     STEST                                                    00003040
*    PROTECTION ADDED TO AVOID EXPONENT OVERFLOW AND UNDERFLOW IN ALL   00003041
*    STEPS OF THE TANGENT APPROXIMATION ALGORITHM.  THE PROTECTION      00003042
*    SCHEME DEFAULTS TO +/- PI/2 WHEN DELTA = EXPONENT(SINARG) -        00003043
*    EXPONENT(COSARG) >=15 AND DEFAULTS TO ARCTAN(0), I.E. 0 OR         00003044
*    +/- PI, WHEN DELTA < -51.                                          00003045
CHECK    LER   F0,F0      IF SINARG=0, CONTINUE WITH TANGENT            00003046
         BZ    TANDIV      DIVIDE                                       00003047
         LFXR  R4,F0      SAVE EXP(SINARG) * 16**2(I.E. EXP IS IN       00003050
         NHI   R4,X'7F00'  LOW ORDER BITS, 0'S IN HIGH ORDER BITS).     00003060
         LFXR  R5,F2      SAVE EXP(COSARG) * 16**2                      00003070
         NHI   R5,X'7F00'                                               00003080
         SR    R4,R5      DELTA =(EXP(SINARG) - EXP(COSARG)) * 16**2    00003090
         CHI   R4,X'0F00' IF DELTA >= 15 * 16**2, RETURN +/- PI/2       00003092
         BNL   VALUE                                                    00003093
         CHI   R4,X'CD00' IF DELTA < -51 * 16**2, RETURN ARCTAN(0):     00003097
         BNL   CHKHI                                                    00003098
         SER   F0,F0          CLEAR F0 AND F1 AND                       00003099
         SER   F1,F1                                                    00003100
         B     POSOK          RETURN 0 OR +/- PI                        00003101
*    WHEN EXP(SINARG) >= 61, OVERFLOW CAN OCCUR REGARDLESS OF THE       00003102
*    MAGNITUDE OF EXP(COSARG) AND SO THE ABOVE DEFAULTING SCHEME IS     00003103
*    NOT ADEQUATE. TO AVOID OVERFLOW, SUBTRACT3 FROM BOTH EXP(SINARG)   00003104
*    AND EXP(COSARG) BEFORE ENTERING TANGENT ALGORITHM.                 00003105
CHKHI    LFXR  R4,F0      GET EXP(SINARG)* 16**2                        00003106
         NHI   R4,X'7F00'                                               00003107
         CHI   R4,X'7D00'    7D00=61 * 16**2 IN EXCESS 64 NOTATION      00003108
         BL    CHKLO      IF EXP(SINARG) * 16**2 >= 61 * 16**2,         00003109
         L     R2,NEG3        SCALE BOTH EXP(SINARG) AND EXP(COSARG)    00003110
         B     SCALE          BY -3 * 16**2.                            00003111
*    WHEN EXP(SINARG) < -51, UNDERFLOW CAN OCCUR REGARDLESS OF THE      00003112
*    MAGNITUDE OF EXP(COSARG) AND SO THE ABOVE DEFAULTING SCHEME IS     00003113
*    NOT ENOUGH.  TO AVOID UNDERFLOW, ADD 13 TO BOTH EXP(SINARG) AND    00003114
*    EXP(COSARG) BEFORE ENTERING TANGENT ALGORITHM.                     00003115
CHKLO    CHI   R4,X'0D00'  0D00=-51 * 16**2 IN EXCESS 64 NOTATION       00003116
         BNL   TANDIV     IF EXP(SINARG) * 16**2 < -51 * 16**2,         00003117
         L     R2,THIRTN      SCALE BOTH EXPONENTS BY 13.               00003118
*    SCALE EXPONENTS BEFORE ENTERING TANGENT ALGORITHM IF EXP(SINARG)   00003119
*    >= 61 OR < -51.  EXPONENTS ARE SCALED BY EITHER-3 OR 13 (STORED    00003120
*    IN R2), DEPENDING ON WHETHER WE ARE AVOIDING UNDERFLOW OR OVER-    00003121
*    FLOW.                                                              00003122
SCALE    LFXR  R5,F2      GET HIGH ORDER HALFWORD OF COSARG,            00003123
         NHI   R5,X'7FFF'   WITHOUT SIGN BIT                            00003124
         AR    R5,R2      SCALE EXPONENT  BY EITHER -3 OR 13.           00003125
         LFXR  R4,F0      GET HIGH ORDER HALFWORD OF SINARG,            00003126
         NHI   R4,X'7FFF'   WITHOUT SIGN BIT                            00003127
         AR    R4,R2      SCALE EXPONENT BY EITHER -3 OR 13.            00003128
*    RESET ARGUMENTS                                                    00003129
         LFXR  R2,F0           RESET SINARG.                            00003130
         ZRB   R2,X'FFFF'      GET LOW ORDER HALFWORD OF SINARG         00003131
         OR    R4,R2           COMBINE WITH NEW HIGH ORDER HALF-        00003132
         LFLR  F0,R4             WORD IN R4                             00003133
         LFXR  R2,F2           RESET COSARG IN SAME MANNER.             00003134
         ZRB   R2,X'7FFF'                                               00003135
         OR    R5,R2                                                    00003136
         LFLR  F2,R5                                                    00003137
*    BEGINNING OF TANGENT APPROXIMATION ALGORITHM                       00003138
TANDIV  QDEDR  F0,F2    X=|SINARG|/COSARG                               00003140
         LER   F2,F2                                                    00003200
         BP    NORM    COSARG>0,X=|SINARG|/|COSARG|, SO CONTINUE        00003300
         LECR  F0,F0    COSARG<0, LOAD POSITIVE X                       00003400
*
*   DR103762 CHANGED QCED TO CED ON THE FOLLOWING LINE
*
         CED   F0,LOWLIM IF COSARG<0 AND X<=16**-14 THEN RETURN +/- PI  00003500
         BH    NORM                                                     00003600
         LED   F0,PI                                                    00003700
         B     STEST     STEST FIXES SIGN  OF RESULT                    00003800
*
*   DR103762 CHANGED QCED TO CED ON THE FOLLOWING LINE
*
NORM     CED   F0,HIGHLIM   IF COSARG NOT=0 AND X>16**14                00004300
         BH    VALUE      THEN RETURN +/- PI/2                          00004400
*   MAIN CIRCUIT- ARCTAN FN WITH SINARG=TAN% OR X=|SINARG|/|COSARG|     00004500
*   FIND %(ANGLE) AND FIX QUADRANTS AND SIGN OF RESULT                  00004600
DATAN1   LA    R3,ZERO    R3-->0 IF X<=1                                00004700
         LA    R2,DATA     SET POINTER TO ADDRESS OF DOUBLEWORD '0'     00004710
*
*   DR103762 CHANGED QCED TO CED ON THE FOLLOWING LINE
*
         CED   F0,FLONE                                                 00004800
         BNH   REDUC   IF X>1, THEN TAKE INVERSE                        00004900
         LER   F2,F0   PUT X IN F2                                      00005000
         LER   F3,F1                                                    00005100
         LED   F0,FLONE                                                 00005200
        QDEDR  F0,F2   F0=1/X                                           00005300
         LA    R2,8(R2)   MEANS REDUCTION FOR X>1 TAKEN                 00005400
         LA    R3,4(R3)    R3-->-1 IF X>1                               00005500
*   CHECK FOR X<16**-7.  ALSO, CHECK IF X<=TAN(PI/12)                   00005600
*   IF NOT, THEN REDUCE X                                               00005700
*
*   DR103762 CHANGED QCED TO CED ON THE FOLLOWING LINE
*
REDUC    CED   F0,SMALL    IF X<16**-7 THEN ANSWER=X                    00005800
         BL    READY       THIS AVOIDS UNDERFLOW EXCEPTION              00005900
         LFXR  R4,F6       SAVE F6,F7                                   00005910
         LFXR  R5,F7                                                    00005920
*
*   DR103762 CHANGED QCED TO CED ON THE FOLLOWING LINE
*
         CED   F0,TAN15    IF X>TAN(PI/12), THEN REDUCE USING           00006000
         BNH   OK          ATAN(X)=PI/6+TAN(Y), WHERE                   00006100
         LER   F2,F0       Y=(X*SQRT3-1)/(X+SQRT3)                      00006200
         LER   F3,F1                                                    00006300
         MED   F0,RT3M1                                                 00006400
         SED   F0,FLONE    TO PROTECT SIGNIFICANT BITS, COMPUTE         00006500
         AEDR  F0,F2       X*SQRT3-1 AS X(SQRT3-1)-1+X                  00006600
         AED   F2,RT3                                                   00006700
        QDEDR  F0,F2                                                    00006800
         LA    R2,4(R2)    MEANS REDUCTION FOR X OR 1/X>TAN(PI/12)      00006900
*   NOW X IS LESS THAN TAN(PI/12), SO COMPUTE ARCTAN                    00007000
OK       LER   F6,F0   ATAN(X)=X+X*X**2*F,WHERE                         00007100
         LER   F7,F1   F=C1+C2/(XSQ+C3+C4/(XSQ+C5+C6/(XSQ+C7))).        00007200
         MEDR  F0,F0                                                    00007300
         LED   F4,C7                                                    00007400
         AEDR  F4,F0                                                    00007500
         LED   F2,C6                                                    00007600
        QDEDR  F2,F4                                                    00007700
         AED   F2,C5                                                    00007800
         AEDR  F2,F0                                                    00007900
         LED   F4,C4                                                    00008000
        QDEDR  F4,F2                                                    00008100
         AED   F4,C3                                                    00008200
         AEDR  F4,F0                                                    00008300
         LED   F2,C2                                                    00008400
        QDEDR  F2,F4                                                    00008500
         AED   F2,C1                                                    00008600
         MEDR  F0,F2                                                    00008700
         MEDR  F0,F6                                                    00008800
         AEDR  F0,F6                                                    00008900
         LFLR  F6,R4                                                    00008910
         LFLR  F7,R5                                                    00008920
*   NOW ADJUST ANGLE TO PROPER SECTION                                  00009000
*   R2=0 MEANS X<=TAN(PI/12)   ACTION TAKEN- ADD 0                      00009100
*   R2=4(0) MEANS TAN(PI/12)<X<=1   ACTION TAKEN- ADD PI/6              00009200
*   R2=8 MEANS 1/X<=TAN(PI/12)   ACTION TAKEN- SUBTRACT PI/2            00009300
*   R2=4(8) MEANS 1/X>TAN(PI/12)   ACTION TAKEN- SUBTRACT PI/3          00009400
*   R3-->0 IF X<=1 USED                                                 00009500
*   R3-->-1 IF 1/X USED                                                 00009600
READY    AED   F0,0(R2)                                                 00009700
         LR    R2,R3                                                    00009800
         SED F0,0(R2)   SUBTRACT EITHER 0 OR -1                         00009900
         BNM   POSOK     WANT POSITIVE ANSWER                           00010000
         LECR  F0,F0                                                    00010100
*   ANSWER POSITIVE.  CHECK IF DATAN2 ENTRY AND COSARG<0                00010200
*   IF SO, THEN F0=PI-F0                                                00010300
*   IF TWO ARGS(DATAN2 ENTRY), THEN ANSWER IN RANGE (-PI,PI)            00010400
POSOK    LR    R1,R1          SET CONDITION CODE                        00010500
         BZ    STEST                                                    00010600
         LR    R7,R7          DATAN2 ENTRY-CHECK SIGN OF COSARG         00010700
         BNM   STEST      GO TO STEST IF COSARG>=0                      00010800
         LED   F2,PI                                                    00010900
         SEDR  F2,F0      COSARG<0                                      00011000
         LER   F1,F3    ANSWER IN F0                                    00011100
         LER   F0,F2                                                    00011200
         BNM   STEST    WANT POSITIVE ANSWER                            00011300
         LECR  F0,F0                                                    00011400
*   STEST MAKES SIGN OF ANSWER AGREE WITH SIGN OF SINARG                00011500
*   IF ONLY ONE ARG(DATAN ENTRY), THEN ANSWER IN RANGE (-PI/2,PI/2)     00011600
STEST    LR    R6,R6          SET CONDITION CODE                        00011700
         BNM   EXIT                                                     00011800
         LER   F0,F0          WORKAROUND FOR BUG                        00011900
         BZ    EXIT           IN LECR INSTRUCTION.                      00012000
         LECR  F0,F0                                                    00012100
EXIT     AEXIT                                                          00012400
*     ERROR HANDLER FOR SINARG=COSARG=0                                 00012500
ERROR    LED   F0,FLZERO   STANDARD FIX-UP=0.0                          00012600
         AERROR 62            ARG1=ARG2=0                               00012700
         B     EXIT                                                     00012800
         DS   0D   ALIGN ON DOUBLEWORD BOUNDARY                         00012900
FLONE    DC   X'4110000000000000'                                       00013000
FLZERO   DC   X'0000000000000000'                                       00013100
PI       DC   X'413243F6A8885A2F'                                       00013200
PIOV2    DC   X'411921FB54442D18'                                       00013300
LOWLIM   DC   X'3310000000000000'   16**-14                             00013400
HIGHLIM  DC   X'4F10000000000000'   16**14                              00013500
NEG3     DC   X'FD00000000000000'   -3                                  00013520
THIRTN   DC   X'0D00000000000000'   13                                  00013540
C1       DC   X'BF1E31FF1784B965'   -0.7371899082768562E-2              00013600
C2       DC   X'C0ACDB34C0D1B35D'   -0.6752198191404210                 00013700
C3       DC   X'412B7CE45AF5C165'    0.2717991214096480E+1              00013800
C4       DC   X'C11A8F923B178C78'   -0.1660051565960002E+1              00013900
C5       DC   X'412AB4FD5D433FF6'    0.2669186939532663E+1              00014000
C6       DC   X'C02298BB68CFD869'   -0.1351430064094942                 00014100
C7       DC   X'41154CEE8B70CA99'    0.1331282181443987E+1              00014200
RT3M1    DC   X'40BB67AE8584CAA8'   SQRT3-1                             00014300
RT3      DC   X'411BB67AE8584CAB'   SQRT3                               00014400
SMALL    DC   X'3A10000000000000'   16**-7                              00014500
TAN15    DC   X'40449851C5F064AC'   TAN(PI/12)                          00014600
         ADATA                                                          00014700
DATA     DC   D'0'                  THESE FOUR                          00014800
         DC   X'40860A91C16B9B2C'   PI/6      CONSTANTS                 00014900
         DC   X'C0921FB54442D184' -PI/2+1      MUST BE                  00015000
         DC   X'BFC152382D736574'            CONSECUTIVE                00015100
ZERO     DC   D'0'                                                      00015200
         DC   D'1'                                                      00015300
         ACLOSE                                                         00015400
