*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DSINH.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

     TITLE 'DSINH -- DOUBLE PRECISION HYPERBOLIC SINE-COSINE'           00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
* DSINH: HYPERBOLIC SINE-COSINE(SINGLE)                                 00000200
*                                                                       00000300
*        1. INPUT AND OUTPUT VIA F0-F1.                                 00000400
*        2.                                                             00000500
*                                                                       00000600
         MACRO                                                          00000700
         WORKAREA                                                       00000800
FOUR     DS    D                                                        00000900
         MEND                                                           00001000
*                                                                       00001100
DSINH    AMAIN ACALL=YES,QDED=YES                                       00001200
* COMPUTES HYPERBOLIC SIN IN DOUBLE PRECISION                           00001300
         INPUT F0             SCALAR DP                                 00001400
         OUTPUT F0            SCALAR DP                                 00001500
         WORK  R5,F1,F2,F3,F4,F5                                        00001600
         XR    R5,R5          R5=0 FOR SINH                             00001700
         B     BEGIN                                                    00001800
*                                                                       00001900
DCOSH    AENTRY                                                         00002000
* COMPUTES HYPERBOLIC COSINE IN DOUBLE PRECISION                        00002100
         INPUT F0             SCALAR DP                                 00002200
         OUTPUT F0            SCALAR DP                                 00002300
         WORK  R5,F1,F2,F3,F4                                           00002400
         LHI   R5,X'FFFF'     R5<0 FOR COSH                             00002500
*                                                                       00002600
BEGIN    LER   F5,F1                                                    00002700
         LER   F4,F0                                                    00002800
         BNM   PRETEST        ALL SET IF >0                             00002900
*                                                                       00003000
         LECR  F0,F0          GET |X|                                   00003100
         LR    R5,R5                                                    00003200
         BNM   TEST                                                     00003300
         LECR  F4,F4                                                    00003400
         B     EXPON                                                    00003500
*                                                                       00003600
PRETEST  LR    R5,R5                                                    00003700
         BM    EXPON                                                    00003800
TEST     CE    F0,LIMIT                                                 00003900
         BNM   EXPON                                                    00004000
*                                                                       00004100
* COMPUTE POLYNOMIAL HERE                                               00004200
*                                                                       00004300
         CE    F0,UNFLO                                                 00004400
         BL    SIGN                                                     00004500
         MEDR  F0,F0                                                    00004600
         LER   F2,F0                                                    00004700
         LER   F3,F1                                                    00004800
         MED   F0,C6                                                    00004900
         AED   F0,C5                                                    00005000
         MEDR  F0,F2                                                    00005100
         AED   F0,C4                                                    00005200
         MEDR  F0,F2                                                    00005300
         AED   F0,C3                                                    00005400
         MEDR  F0,F2                                                    00005500
         AED   F0,C2                                                    00005600
         MEDR  F0,F2                                                    00005700
         AED   F0,C1                                                    00005800
         MEDR  F0,F2                                                    00005900
         MEDR  F0,F4                                                    00006000
         AEDR  F0,F4                                                    00006100
         B     EXIT                                                     00006200
*                                                                       00006300
EXPON    CE    F0,MAX                                                   00006400
         BH    ERROR                                                    00006500
         AED   F0,LNV                                                   00006600
         STED  F4,FOUR                                                  00006700
         ACALL DEXP                                                     00006800
         LED   F4,FOUR                                                  00006900
         LED   F2,VSQ                                                   00007000
        QDEDR  F2,F0                                                    00007100
         STED  F0,FOUR                                                  00007200
         LR    R5,R5                                                    00007300
         BNZ   ECOSH                                                    00007400
         LECR  F2,F2                                                    00007500
*                                                                       00007600
ECOSH    AEDR  F0,F2                                                    00007700
         MED   F0,DELTA                                                 00007800
         AEDR  F0,F2                                                    00007900
         AED   F0,FOUR                                                  00008000
*                                                                       00008100
SIGN     LER   F4,F4                                                    00008200
         BNM   EXIT                                                     00008300
         LER   F0,F0          WORKAROUND FOR BUG                        00008400
         BZ    EXIT           IN LECR INSTRUCTION.                      00008500
         LECR  F0,F0                                                    00008600
*                                                                       00008700
EXIT     AEXIT                                                          00008800
*                                                                       00008900
ERROR    AERROR 9             |X|<=175.366                              00009000
         LED   F0,INFINITY                                              00009100
         B     EXIT                                                     00009200
*                                                                       00009300
         DS    0D                                                       00009400
INFINITY DC    X'7FFFFFFFFFFFFFFF' STANDARD FIXUP= INFINITY             00009500
UNFLO    EQU   *                                                        00009600
C6       DC    X'38B2D4C184418A97'       0.1626459177981471(-9)         00009700
C5       DC    X'3A6B96B8975A1636'       0.2504995887597646(-7)         00009800
C4       DC    X'3C2E3BC881345D91'       0.2755733025610683(-5)         00009900
C3       DC    X'3DD00D00CB06A6F5'       0.1984126981270711(-3)         00010000
C2       DC    X'3F2222222222BACE'       0.8333333333367232(-2)         00010100
C1       DC    X'402AAAAAAAAAAA4D'       0.1666666666666653 +2F         00010200
VSQ      DC    X'403FDF9434F03D26'       0.2495052937740537 = V**2      00010300
LNV      DC    X'C0B1B30000000000'      -0.6941375732421875 = LOG(V)    00010400
DELTA    DC    X'3E40F0434B741C6D'       0.0009908832830238=1/2V-1 +F   00010500
MAX      DC    X'42AF5DC0'               175.366                        00010600
LIMIT    DC    X'40E1A1B8'               0.881374                       00010700
         ACLOSE                                                         00010800
