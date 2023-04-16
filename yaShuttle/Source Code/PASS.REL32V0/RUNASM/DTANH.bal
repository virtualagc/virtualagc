*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DTANH.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

      TITLE 'DTANH -- DOUBLE PRECISION HYPERBOLIC TANGENT'              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
* DTANH: HYPERBOLIC TANGENT(DOUBLE)                                     00000200
*                                                                       00000300
*        1.INPUT AND OUTPUT VIA F0-F1.                                  00000400
*        2. IF |X|<0.54931, USE A FRACTIONAL APPROXIMATION.             00000500
*        3. IF |X|>20.101, ANSWER IS +1 OR -1.                          00000600
*        4. FOR OTHER VALUES OF X, USE EXTERNAL DEXP FUNCTION:          00000700
*           TANH(|X|) = 1-2/(EXP(2|X|)+1).                              00000800
*        5. TANH(-X) = -TANH(X)                                         00000900
*                                                                       00001000
         MACRO                                                          00001100
         WORKAREA                                                       00001200
SAVE6    DS    D                                                        00001300
         MEND                                                           00001400
*                                                                       00001500
DTANH    AMAIN ACALL=YES,QDED=YES                                       00001600
* COMPUTES HYPERBOLIC TANGENT IN DOUBLE PRECISION                       00001700
         INPUT F0             SCALAR DP                                 00001800
         OUTPUT F0            SCALAR DP                                 00001900
         WORK  F1,F2,F3,F4,F5,F6,F7                                     00002000
         STED  F6,SAVE6                                                 00002100
         LER   F7,F1                                                    00002200
         LER   F6,F0          GET X IN F6                               00002300
         BNM   POS            AND TEST SIGN                             00002400
         LECR  F0,F0          |X| IN F0                                 00002500
*                                                                       00002600
POS      CE    F0,MLIM        IF |X|<=0.54931, COMPUTE TANH(X)          00002700
         BNH   SMALL          USING A FRACTIONAL APPROXIMATION.         00002800
         CE    F0,HLIM        IF |X|>=20.101,                           00002900
         BNL   BIG            RETURN +1 OR -1.                          00003000
*                                                                       00003100
*  INTERMEDIATE VALUE OF X: USE EXTERNAL DEXP FUNCTION                  00003200
*                                                                       00003300
         AEDR  F0,F0          2|X| IN F0                                00003400
         ACALL DEXP      EXP(2|X|) IN F0. DEXP DOES NOT ALTER F4-F5.    00003500
         LFLI  F4,1                                                     00003600
         SER   F5,F5                                                    00003700
         AEDR  F0,F4          EXP(2|X|)+1.                              00003800
         LER   F2,F4                                                    00003900
         SER   F3,F3                                                    00004000
         AEDR  F2,F2                                                    00004100
        QDEDR  F2,F0                                                    00004200
         LER   F0,F4                                                    00004300
         SER   F1,F1                                                    00004400
         SEDR  F0,F2          TANH(|X|) READY                           00004500
*                                                                       00004600
SIGN     LER   F6,F6          TEST SIGN OF ARGUMENT, AND                00004700
         BNM   EXIT           EXIT IF NOT NEGATIVE.                     00004800
         LER   F0,F0          WORKAROUND FOR BUG                        00004900
         BZ    EXIT           IN LECR INSTRUCTION.                      00005000
         LECR  F0,F0          COMPLEMENT IF ARGUMENT WAS NEGATIVE       00005100
*                                                                       00005200
EXIT     LED   F6,SAVE6       RESTORE F6                                00005300
         AEXIT                AND EXIT                                  00005400
*                                                                       00005500
*  LARGE ARGUMENT RETURNS +1 OR -1                                      00005600
*                                                                       00005700
BIG      LFLI  F0,1           F0=1 FOR LARGE ARGUMENT                   00005800
         SER   F1,F1                                                    00005900
         B     SIGN                                                     00006000
*                                                                       00006100
SMALL    CE    F0,LLIM        IF |X|<16**(-7),                          00006200
         BNH   SIGN           LET TANH(X)=X.                            00006300
         MEDR  F0,F0          OTHERWISE, COMPUTE TANH(X) BY POLYNOMIAL. 00006400
         LED   F4,C5                                                    00006500
         AEDR  F4,F0                                                    00006600
         LED   F2,C4                                                    00006700
        QDEDR  F2,F4                                                    00006800
         AED   F2,C3                                                    00006900
         AEDR  F2,F0                                                    00007000
         LED   F4,C2                                                    00007100
        QDEDR  F4,F2                                                    00007200
         AED   F4,C1                                                    00007300
         AEDR  F4,F0                                                    00007400
         MED   F0,C0                                                    00007500
        QDEDR  F0,F4                                                    00007600
         MEDR  F0,F6                                                    00007700
         AEDR  F0,F6                                                    00007800
         LED   F6,SAVE6       RESTORE F6                                00007900
         AEXIT                                                          00008000
*                                                                       00008100
         DS    0D                                                       00008200
C0       DC    X'C0F6E12F40F5590A'   -.9643735440816707                 00008300
C1       DC    X'419DA5D6FD3DBC84'   9.8529882328255392                 00008400
C2       DC    X'C31C504FEF537AF6'   453.01951534852503                 00008500
C3       DC    X'424D2FA31CAD8D00'   77.186082641955181                 00008600
C4       DC    X'C3136E2A5891D8E9'   -310.8853383729134                 00008700
C5       DC    X'4219B3ACA4C6E790'   25.701853083191565                 00008800
HLIM     DC    X'421419DB'  20.101                                      00008900
LLIM     DC    X'3A100000'  16**(-7)                                    00009000
MLIM     DC    X'408C9F95'  0.54931                                     00009100
         ACLOSE                                                         00009200
