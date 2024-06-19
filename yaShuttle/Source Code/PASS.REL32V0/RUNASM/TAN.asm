*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    TAN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

       TITLE 'TAN -- SINGLE PRECISION TANGENT FUNCTION'                 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
* TAN: TANGENT(SINGLE)                                                  00000200
*                                                                       00000300
*        1. INPUT AND OUTPUT VIA F0                                     00000400
*        2. LET |X|*4/PI = Q+R, WHERE Q IS AN INTEGER AND R A FRACTION. 00000500
*        3. IF Q IS EVEN, THEN W=R. OTHERWISE, W=1-R.                   00000600
*        4. LET Q'=Q MOD 4. THEN                                        00000700
*           IF Q'=0, TAN(|X|)=TAN(W*PI/4);                              00000800
*           IF Q'=1, TAN(|X|)=COT(W*PI/4);                              00000900
*           IF Q'=2, TAN(|X|)=-COT(W*PI/4);                             00001000
*           IF Q'=3, TAN(|X|)=-TAN(W*PI/4).                             00001100
*        5. FINALLY, GET TAN(X) AS TAN(|X|) IF X>=0,                    00001200
*           OR -TAN(|X|) IF X<0.                                        00001300
*        6. ERRORS ARE GIVEN IF X>PI*2**18,OR IF X IS SUFFICIENTLY      00001400
*           CLOSE TO A SINGULARITY OF THE TANGENT FUNCTION THAT THE     00001500
*           COMBINATION OF COMPUTATIONAL ERROR AND MINIMAL INPUT ERROR  00001600
*           WILL CAUSE RELATIVE ERROR > 1/5 IN THE ANSWER.              00001700
*        7. FLOATING REGISTERS USED: F0-F4.                             00001800
*                                                                       00001900
         MACRO                                                          00002000
         WORKAREA                                                       00002100
COMPR    DS    F                                                        00002200
         MEND                                                           00002300
*                                                                       00002400
TAN      AMAIN                                                          00002500
* COMPUTES TANGENT(X) IN SINGLE PRECISION                               00002600
         INPUT F0             SCALAR SP RADIANS                         00002700
         OUTPUT F0            SCALAR SP                                 00002800
         WORK  R5,R6,R7,F0,F1,F2,F3,F4                                  00002900
         LFXR  R6,F0          SAVE ARG TO TEST SIGN                     00003000
         LER   F0,F0                                                    00003100
         BNM   POS                                                      00003200
         LECR  F0,F0          GET |X| IN F0                             00003300
*                                                                       00003400
POS      CE    F0,MAX         GIVE ERROR IF                             00003500
         BNL   ERROR1         ARGUMENT TOO LARGE                        00003600
*                                                                       00003700
         SER   F1,F1                                                    00003800
         SER   F3,F3                                                    00003900
         MED   F0,FOVPI                                                 00004000
*                                                                       00004100
         LFXR  R5,F0          PUT CHARACTERISTIC OF                     00004200
         N     R5,MASK        (ARG*4/PI) IN COMPARAND                   00004300
         A     R5,QTAN        FOR LATER USE,                            00004400
         ST    R5,COMPR       AND SAVE IN COMPR                         00004500
*                                                                       00004600
         AED   F0,CHAR46      SEPARATE INTEGER AND FRACTION             00004700
         LER   F2,F0          INTEGER PART + 16**5 IN F2                00004800
         SEDR  F0,F2          FRACTION IN F0                            00004900
*                                                                       00005000
JOIN     LFXR  R7,F2          SAVE INTEGER PART TO FIND OCTANT          00005100
         SLL   R7,16          MOVE INTEGER TO TOP HALFWORD              00005200
         SER   F2,F2                                                    00005300
         LER   F4,F0                                                    00005400
         TRB   R7,X'0001'                                               00005500
         BZ    EVEN           W READY IN F4 IF EVEN OCTANT              00005600
         SED   F0,ONE         W=1-FRACTION IF ODD OCTANT                00005700
         LECR  F4,F0                                                    00005800
*                                                                       00005900
EVEN     CE    F4,UNFLO       AVOID EXTRANEOUS UNDERFLOW                00006000
         BL    SKIP           IF W<16**(-3)                             00006100
*                                                                       00006200
*  COMPUTE TWO POLYNOMIALS IN W                                         00006300
*                                                                       00006400
         MER   F0,F0          U=W**2/2                                  00006500
         ME    F0,HALF                                                  00006600
         LER   F2,F0          Q(W)=B0+(B1*U)+(B2*U**2)                  00006700
         ME    F2,B2                                                    00006800
         AE    F2,B1                                                    00006900
         MER   F2,F0                                                    00007000
SKIP     AE    F2,B0                                                    00007100
         AE    F0,A0          P(W)=W*(A0+U)                             00007200
         MER   F0,F4                                                    00007300
*                                                                       00007400
*  CALCULATE THE TANGENT AS A RATIONAL FUNCTION IN W                    00007500
*                                                                       00007600
         TRB   R7,X'0003'                                               00007700
         BM    COTN                                                     00007800
         DER   F0,F2          USE TAN(W*PI/4)=P(W)/Q(W)                 00007900
         B     SIGN           IN OCTANTS 0,3,4,7                        00008000
*                                                                       00008100
COTN     CE    F4,COMPR       USE COT(W*PI/4)=Q(W)/P(W)                 00008200
         BNH   ERROR2         IN OCTANTS 1,2,5,6 UNLESS                 00008300
         DER   F2,F0          ARGUMENT IS TOO CLOSE TO                  00008400
         LER   F0,F2          A SINGULARITY (W TOO SMALL)               00008500
*                                                                       00008600
*  FIX SIGN OF ANSWER                                                   00008700
*                                                                       00008800
SIGN     TRB   R7,X'0002'                                               00008900
         BZ    NXTST                                                    00009000
         LER   F0,F0          WORKAROUND FOR BUG                        00009100
         BZ    NXTST          IN LECR INSTRUCTION.                      00009200
         LECR  F0,F0          COMPLEMENT IN OCTANTS 2,3,6,7             00009300
NXTST    LR    R6,R6          TEST SIGN OF ARGUMENT                     00009400
         BNM   EXIT           (SAVED IN R6), AND                        00009500
         LER   F0,F0          WORKAROUND FOR BUG                        00009600
         BZ    EXIT           IN LECR INSTRUCTION.                      00009700
         LECR  F0,F0          COMPLEMENT ANSWER IF ARG<0                00009800
*                                                                       00009900
EXIT     AEXIT                                                          00010000
ERROR1   AERROR 11            |ARG| > PI*2**18                          00010100
         LFLI  F0,1           FIXUP RETURNS 1                           00010200
         B     EXIT                                                     00010300
ERROR2   AERROR 12            TOO CLOSE TO SINGULARITY                  00010400
         LE    F0,INFINITY                                              00010500
         B     EXIT                                                     00010600
*                                                                       00010700
         DS    0F                                                       00010800
MAX      DC    X'45C90FDA'    PI*2**18                                  00010900
MASK     DC    X'FF000000'                                              00011000
QTAN     DC    X'00000008'                                              00011100
ONE      DC    X'4110000000000000'   1.0                                00011200
HALF     DC    X'4080000000000000'   0.5                                00011300
CHAR46   DC    X'4610000000000000'                                      00011400
FOVPI    DC    X'41145F306DC9C883'                                      00011500
UNFLO    DC    X'3B100000'       16**(-3)                               00011600
B2       DC    X'C028C93F'    -.15932077                                00011700
B1       DC    X'415B40FD'    5.7033663                                 00011800
B0       DC    X'C1AC5D33'    -10.7727537                               00011900
A0       DC    X'C1875FDC'    -8.4609032                                00012000
INFINITY DC    X'7FFFFFFF'                                              00012100
         ACLOSE                                                         00012200
