*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    TANH.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

    TITLE 'TANH -- SINGLE PRECISION HYPERBOLIC TANGENT FUNCTION'        00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
* TANH: HYPERBOLIC TANGENT(SINGLE)                                      00000200
*                                                                       00000300
*        1. INPUT AND OUTPUT VIA F0.                                    00000400
*        2. FOR |X|<16**(-3), RETURN TANH(X)=X.                         00000500
*        3. IF |X|<0.7, USE A RATIONAL FUNCTION APPROXIMATION.          00000600
*        4. IF |X|>9.011, RETURN +1 OR -1.                              00000700
*        5. FOR OTHER VALUES OF X, USE EXP:                             00000800
*           TANH(|X|) = 1 - 2 * (1 + EXP(2 * |X|)).                     00000900
*        6. TO GET THE SIGN, USE TANH(-X) = -TANH(X).                   00001000
*                                                                       00001100
*                                                                       00001200
TANH     AMAIN ACALL=YES                                                00001300
* COMPUTES HYPERBOLIC TANGENT IN SINGLE PRECISION                       00001400
         INPUT F0             SCALAR SP                                 00001500
         OUTPUT F0            SCALAR SP                                 00001600
         WORK  F2,F4,F5                                                 00001700
         LER   F5,F0                                                    00001800
         BNM   POSARG                                                   00001900
         LECR  F0,F0          GET |X|                                   00002000
POSARG   CE    F0,MLIM                                                  00002100
         BNH   SMALL                                                    00002200
         CE    F0,HILIM                                                 00002300
         BNL   BIG                                                      00002400
         ACALL EXP                                                      00002500
         LFLI  F4,1                                                     00002600
         MER   F0,F0                                                    00002700
         AER   F0,F4                                                    00002800
         LER   F2,F4                                                    00002900
         AER   F2,F2                                                    00003000
         DER   F2,F0                                                    00003100
         LER   F0,F4                                                    00003200
         SER   F0,F2                                                    00003300
*                                                                       00003400
SIGN     LER   F5,F5                                                    00003500
         BNM   EXIT                                                     00003600
         LER   F0,F0          WORKAROUND FOR BUG                        00003700
         BZ    EXIT           IN LECR INSTRUCTION.                      00003800
         LECR  F0,F0                                                    00003900
EXIT     AEXIT                                                          00004000
*                                                                       00004100
BIG      LFLI  F0,1                                                     00004200
         B     SIGN                                                     00004300
*                                                                       00004400
SMALL    CE    F0,LOLIM                                                 00004500
         BNH   SIGN           TANH(X)=X IF X IS SMALL                   00004600
         MER   F0,F0                                                    00004700
         LE    F4,C                                                     00004800
         AER   F4,F0                                                    00004900
         LE    F2,B                                                     00005000
         DER   F2,F4                                                    00005100
         AE    F2,A                                                     00005200
         MER   F0,F2                                                    00005300
         MER   F0,F5                                                    00005400
         AER   F0,F5                                                    00005500
         B     EXIT                                                     00005600
*                                                                       00005700
         DS    0E                                                       00005800
A        DC    X'BEF7EA70'    -.003782895                               00005900
B        DC    X'C0D08756'    -.81456511                                00006000
C        DC    X'41278C49'    2.4717498                                 00006100
HILIM    DC    X'41902D0E'    9.011                                     00006200
LOLIM    DC    X'3E100000'    16**(-3)                                  00006300
MLIM     DC    X'40B33333'    0.7                                       00006400
         ACLOSE                                                         00006500
