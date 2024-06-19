*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    SNCS.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

    TITLE 'SNCS -- SINGLE PRECISION SINE-COSINE FUNCTION'               00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
* SNCS: SINE, COSINE, AND SINE/COSINE(SINGLE)                           00000200
*                                                                       00000300
*        1. INPUT AND OUTPUT VIA F0                                     00000400
*        2. LET |X|*4/PI = Q+R, WHERE Q IS AN INTEGER, 0<=R<1           00000500
*        3. CRANK Q BY 2 IF COSINE ENTRY AND 4 IF SINE AND X<0. SINCE   00000600
*           COS(X)=SIN(PI/2+X), AND SIN(-X)=SIN(PI+X), THIS REDUCES     00000700
*           THE PROBLEM TO THAT OF FINDING SIN(X) FOR 0<=X<PI/4.        00000800
*        4. IF Q IS EVEN, LET R'=R. OTHERWISE, LET R'=1-R.              00000900
*        5. THE OCTANT IS GIVEN BY Q MOD 8. THEN:                       00001000
*           IN OCTANTS 0,3,4,7, CALCULATE SIN(R'*PI/4);                 00001100
*           IN OCTANTS 1,2,5,6, CALCULATE COS(R'*PI/4).                 00001200
*        6. FINALLY, COMPLEMENT ANSWER IF IN BOTTOM HALF-PLANE (Q>3).   00001300
*        7. ERROR GIVEN IF |X|>PI*2**18.                                00001400
*        8. FLOATING REGISTERS USED: F0-F4.                             00001500
*                                                                       00001600
SNCS     AMAIN INTSIC=YES                                               00001700
*                                                                       00001800
* COMPUTES THE SIN AND COS IN SINGLE PRECISION                          00001900
*   OF THE INPUT ARGUMENT                                               00002000
*                                                                       00002100
         INPUT F0             SCALAR SP RADIANS                         00002200
         OUTPUT F0            SCALAR SP (SIN)                           00002300
         OUTPUT F2            SCALAR SP (COS)                           00002400
         WORK  R2,R3,F0,F1,F2,F3,F4                                     00002500
         LHI   R3,SCSENTRY    FLAG TO INDICATE SNCS ENTRY               00002600
         LE    F2,=X'46800000'  CRANK=0                                 00002700
         LER   F0,F0                                                    00002800
         BNM   MERGE          IF ARGUMENT<0, THEN SET                   00002900
         LHI   R3,SCSENTRY+NEG  SNCS ENTRY AND ARG<0 FLAGS.             00003000
         LE    F2,=X'46800004'  CRANK=4 FOR NEGATIVE ARG                00003100
         B     INVERT                                                   00003200
*                                                                       00003300
SIN      AENTRY                                                         00003400
*                                                                       00003500
* COMPUTES THE SIN IN SINGLE PRECISION OF THE INPUT ARGUMENT            00003600
*                                                                       00003700
         INPUT F0             SCALAR SP RADIANS                         00003800
         OUTPUT F0            SCALAR SP                                 00003900
         WORK  R2,R3,F0,F1,F2,F3,F4                                     00004000
         XR    R3,R3          ZERO SNCS ENTRY AND NEGATIVE ARG FLAGS    00004100
         LE    F2,=X'46800000'  CRANK=0                                 00004200
         LER   F0,F0                                                    00004300
         BNM   MERGE                                                    00004400
         LE    F2,=X'46800004'  CRANK=4 FOR SINE OF NEGATIVE ARG.       00004500
         B     INVERT                                                   00004600
*                                                                       00004700
COS      AENTRY                                                         00004800
*                                                                       00004900
* COMPUTES THE COS IN SINGLE PRECISION OF THE INPUT ARGUMENT            00005000
*                                                                       00005100
         INPUT F0             SCALAR SP RADIANS                         00005200
         OUTPUT F0            SCALAR SP                                 00005300
         WORK  R2,R3,F0,F1,F2,F3,F4                                     00005400
         XR    R3,R3          ZERO SNCS ENTRY AND NEGATIVE ARG FLAGS    00005500
         LE    F2,=X'46800002'  CRANK=2 FOR COSINE ENTRY                00005600
         LER   F0,F0                                                    00005700
         BNM   MERGE                                                    00005800
INVERT   LECR  F0,F0          GET |X|                                   00005900
*                                                                       00006000
MERGE    CE    F0,MAX                                                   00006100
         BNH   SMALL                                                    00006200
         AERROR 8             |ARG|>PI*2**18                            00006300
         LE    F0,RT2         FIXUP: SIN(X),COS(X)=SQRT(2)/2            00006400
         LER   F2,F0                                                    00006500
         B     EXIT                                                     00006600
*                                                                       00006700
SMALL    LE    F3,ZERO        ZERO LOW HALVES F0 AND F2                 00006800
         LER   F1,F3                                                    00006900
         MED   F0,FOVPI       REDUCE TO MULTIPLES OF PI/4               00007000
         AEDR  F0,F2          ADD CRANK, SEPARATE INTEGER AND FRACTION  00007100
         LFXR  R2,F0          INTEGER PART TO R2, TEMPORARILY           00007200
         SRR   R2,3           OCTANT TO TOP 3 BITS OF R2                00007300
         OR    R3,R2          COMBINE OCTANT AND FLAG BITS IN R3        00007400
*                                                                       00007500
*  COMPUTE R',LEAVE IN F0                                               00007600
*                                                                       00007700
         LER   F2,F0          INTEGER PART IN F2                        00007800
         SEDR  F0,F2          R IN F0                                   00007900
         TRB   R3,X'2000'     TEST OCTANT PARITY                        00008000
         BZ    EVEN           R'=R IN EVEN OCTANT                       00008100
         LECR  F0,F0                                                    00008200
         AED   F0,ONE         R'=1-R IN ODD OCTANT                      00008300
*                                                                       00008400
EVEN     LER   F4,F0          R' IN F4 FOR SINE POLYNOMIAL              00008500
         LFXR  R2,F0          TEST FOR UNDERFLOW IN FIXED               00008600
         SH    R2,UNFLO       POINT FOR SPEED                           00008700
         BNM   OK                                                       00008800
         LER   F0,F3          ZERO F0 TO AVOID UNDERFLOW                00008900
*                                                                       00009000
*  IF COSINE POLYNOMIAL ALONE TO BE COMPUTED,                           00009100
*  SKIP DOWN TO SECOND POLYNOMIAL                                       00009200
*                                                                       00009300
OK       MER   F0,F0          (R')**2 IN F0                             00009400
         LER   F2,F0          AND IN F2.                                00009500
         LA    R2,A3                                                    00009600
         USING A3,R2                                                    00009700
         TRB   R3,SCSENTRY    IF BOTH SIN AND COS TO BE COMPUTED,       00009800
         BO    SINPOLY        THEN DO BOTH POLYNOMIALS.                 00009900
         TRB   R3,X'6000'     ELSE IF COSINE ONLY (OCTANTS 1,2,5,6),    00010000
         BM    COSPOLY        JUMP TO COSINE POLYNOMIAL.                00010100
*                                                                       00010200
SINPOLY  ME    F0,A3                                                    00010300
         AE    F0,A2                                                    00010400
         MER   F0,F2                                                    00010500
         AE    F0,A1                                                    00010600
         MER   F0,F2                                                    00010700
         AE    F0,A0                                                    00010800
         MER   F0,F4                                                    00010900
*                                                                       00011000
*  SIN(R') IN F0, CORRECT UP TO                                         00011100
*  A POSSIBLE SIGN CHANGE                                               00011200
*                                                                       00011300
         TRB   R3,SCSENTRY    TEST FOR SNCS ENTRY,                      00011400
         BZ    SINONLY        EXIT IF NOT.                              00011500
*                                                                       00011600
*  COMPUTE COSINE POLYNOMIAL HERE.  NOTE THAT                           00011700
*  F2 CONTAINS (R')**2 AND F4 CONTAINS R', WHICH                        00011800
*  IS NO LONGER NEEDED.                                                 00011900
*                                                                       00012000
COSPOLY  LER   F4,F2          PUT (R')**2 IN F4 TEMPORARILY             00012100
         LA    R2,2(R2)       INDEX COSINE COEFFICIENTS                 00012200
         ME    F2,A3                                                    00012300
         AE    F2,A2                                                    00012400
         MER   F2,F4                                                    00012500
         AE    F2,A1                                                    00012600
         MER   F2,F4                                                    00012700
         AE    F2,A0                                                    00012800
*                                                                       00012900
*  COS(R') IN F2, CORRECT UP TO                                         00013000
*  A POSSIBLE SIGN CHANGE                                               00013100
*                                                                       00013200
         TRB   R3,SCSENTRY  TEST FOR SNCS ENTRY                         00013300
         BZ    COSONLY        AND EXIT IF NOT.                          00013400
*                                                                       00013500
*  SNCS PROCESSING HERE: CONTENTS OF F0 AND F2                          00013600
*  MUST BE SWITCHED IN OCTANTS 1,2,5,6                                  00013700
*                                                                       00013800
         TRB   R3,X'6000'                                               00013900
         BNM   FIXCOS         OK IN OCTANTS 0,3,4,7                     00014000
         LFXR  R2,F0          USE FIXED-POINT REGISTER                  00014100
         LER   F0,F2          AS TEMPORARY FOR SWITCH                   00014200
         LFLR  F2,R2          FOR FASTER EXECUTION.                     00014300
*                                                                       00014400
*  FIX SIGN OF COSINE OF ARGUMENT                                       00014500
*                                                                       00014600
FIXCOS   TRB   R3,X'C000'     COMPLEMENT IF                             00014700
         BNM   TSTNEG         OCTANT IS 2,3,4,5.                        00014800
         LER   F2,F2          WORKAROUND FOR BUG                        00014900
         BZ    TSTNEG         IN LECR INSTRUCTION.                      00015000
         LECR  F2,F2                                                    00015100
TSTNEG   TRB   R3,NEG         (RE)COMPLEMENT IF                         00015200
         BZ    SINONLY        INPUT ARGUMENT WAS NEGATIVE.              00015300
         LER   F2,F2          WORKAROUND FOR BUG                        00015400
         BZ    SINONLY        IN LECR INSTRUCTION.                      00015500
         LECR  F2,F2                                                    00015600
         B     SINONLY        FIX SIGN OF SIN(X).                       00015700
*                                                                       00015800
COSONLY  LER   F0,F2          GET COS(X) IN F0.                         00015900
SINONLY  LR    R3,R3          FIX SIGN, IF NECESSARY,                   00016000
         BNM   EXIT           OF SINGLE-ENTRY OUTPUT                    00016100
         LER   F0,F0          WORKAROUND FOR BUG                        00016200
         BZ    EXIT           IN LECR INSTRUCTION.                      00016300
         LECR  F0,F0          OR SINE OUTPUT OF SNCS.                   00016400
EXIT     AEXIT                                                          00016500
*                                                                       00016600
*  DATA DEFINITIONS                                                     00016700
*                                                                       00016800
SCSENTRY EQU   X'0400'                                                  00016900
NEG      EQU   X'0200'                                                  00017000
         ADATA                                                          00017100
FOVPI    DC    X'41145F306DC9C883'                                      00017200
MAX      DC    X'45C9'    PI*2**18                                      00017300
UNFLO    DC    X'3E10'                                                  00017400
A3       DC    X'BD25B368'    SIN A3=-.000035943                        00017500
         DC    X'BE14F17D'    COS A3=-.000319570                        00017600
A2       DC    X'3EA32F62'    SIN A2=.0024900069                        00017700
         DC    X'3F40ED0F'    COS A2=.0158510767                        00017800
A1       DC    X'C014ABBC'    SIN A1=-.080745459                        00017900
         DC    X'C04EF4EE'    COS A1=-.308424830                        00018000
A0       DC    X'40C90FDB'    SIN A0=.7853981853                        00018100
ONE      DC    X'41100000'    COS A0=1.0                                00018200
ZERO     DC    X'00000000'    0 AND LOW HALF OF ONE                     00018300
RT2      DC    X'40B504F3'    SQRT(2)/2                                 00018400
         ACLOSE                                                         00018500
