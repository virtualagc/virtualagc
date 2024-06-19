*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DEXP.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

     TITLE 'DEXP -- DOUBLE PRECISION EXPONENTIAL FUNCTION'              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
* DEXP: EXPONENTIAL(DOUBLE)                                             00000200
*                                                                       00000300
*        1. INPUT AND OUTPUT VIA F0-F1.                                 00000400
*        2. WRITE X=(4A-B-C/16)*LOGE(2)+R, WHERE A,B,AND C              00000500
*           ARE INTEGERS, 0<=B<=3, 0<=C<=15, AND R IS A                 00000600
*           FRACTION, -1/16<=R<0.                                       00000700
*        2. THEN E**X=(16**A)(2**(-B))(2**(-C/16))(E**R).               00000800
*        3. 2**(-C/16) IS COMPUTED BY TABLE LOOKUP.                     00000900
*        4. E**R IS COMPUTED BY POLYNOMIAL.                             00001000
*        5. ERRORS GIVEN IF X<-180.2187 OR X>174.6731.                  00001100
*        6. FLOATING REGISTERS F4-F5 NOT USED.                          00001200
*                                                                       00001300
*                                                                       00001400
*  REVISION HISTORY:                                                    00001500
*                                                                       00001600
*     DATE       NAME  DR/SSCR#   DESCRIPTION                           00001700
*     --------   ----  --------   -----------------------------------   00001800
*     12/16/89   JAC   DR103762   REPLACED QCED/QCEDR MACRO WITH        00001900
*                                 CED/CEDR INSTRUCTION                  00002000
*                                                                       00002100
*     03/15/91   RAH   CR11055    RUNTIME LIBRARY CODE COMMENT CHANGES  00002200
*                                 (RELEASE 23V2)                        00002300
*                                                                       00002400
DEXP     AMAIN                                                          00002500
* COMPUTE E**X IN DOUBLE PRECISION                                      00002600
         INPUT F0             SCALAR DP                                 00002700
         OUTPUT F0 SCALAR DP                                            00002800
         WORK  R2,R5,R6,R7,F1,F2,F3                                     00002900
         CE    F0,MAX                                                   00003000
         BH    ERROR                                                    00003100
         CE    F0,MIN                                                   00003200
         BNH   UNFLO                                                    00003300
*                                                                       00003400
         LER   F3,F1                                                    00003500
         LER   F2,F0          DECOMPOSE X AS P*LOG(2)+R,                00003600
         DE    F2,LOG2H       WHERE R IS AN INTEGRAL                    00003700
         BNM   POS                                                      00003800
         SE    F2,SCALER                                                00003900
         LFXR  R6,F2                                                    00004000
         AE    F2,SCALER                                                00004100
         B     PM                                                       00004200
*                                                                       00004300
POS      AE    F2,SCALER                                                00004400
         LFXR  R6,F2                                                    00004500
         SE    F2,SCALER                                                00004600
*                                                                       00004700
PM       LFXR  R5,F2                                                    00004800
         ME    F2,LOG2H                                                 00004900
         SEDR  F0,F2          LOG(2) = LOG2H+LOG2L,                     00005000
         LFLR  F2,R5          WHERE LOG2H IS ROUNDED UP.                00005100
         SER   F3,F3                                                    00005200
         MED   F2,LOG2L       TOTAL PRECISION 80 BITS                   00005300
         XR    R7,R7          * -- REL20V12 AND REL21V2 FIX --          00005400
         SRDA  R6,16          * |P| IN UPPER HALF R7, SIGN OF R6 SAVED  00005500
         LR    R6,R6          * SET CONDITION CODE                      00005600
         BCF   2,NEGP         * IF R6 > 0 THEN                          00005700
         LACR  R7,R7          * COMPLIMENT R7 (P)                       00005800
NEGP     LR    R6,R7          * LOAD -P INTO R6                         00005900
         SEDR  F0,F2          X = P'*LOG(2)+R', WHERE |R'|              00006000
         BNP   ZMINUS         MAY BE SLIGHTLY OVER LOG(2)/16            00006100
*                                                                       00006200
PLUS     BCTB  R6,*+1         SUBTRACT LOG(2)/16 FROM R UNTIL           00006300
         AED   F0,ML216       IT GOES NEGATIVE, SUBTRACTING 1           00006400
         BP    PLUS           FROM -P EACH TIME AROUND.                 00006500
         B     READY                                                    00006600
*                                                                       00006700
ZMINUS   CED   F0,ML216       /* DR103762 - CHANGED QCED TO CED */      00006800
         BH    READY          IF R'<-LOG(2)/16,                         00006900
         SED   F0,ML216       ADD LOG(2)/16 AND INCREMENT               00007000
         AHI   R6,1           R6, WHOSE HIGH PART IS -P.                00007100
*                                                                       00007200
READY    SR    R7,R7          R7 = -P = -4A+B+C/16                      00007300
         SRDL  R6,20          C IN HIGH R7                              00007400
         SRL   R7,12                                                    00007500
         SRDL  R6,2           B IN HIGH R7,C IN LOW R7.                 00007600
         SLL   R6,24                                                    00007700
         LACR  R5,R6          A (AT BIT 7) IN R5, CHAR. MODIFIER        00007800
         SR    R6,R6                                                    00007900
         SLDL  R6,2           B IN R6, C IN R7 HIGH                     00008000
         LA    R2,MCONST                                                00008100
*                                                                       00008200
         CE    F0,NEAR0       IF |R|<2**(-60), AVOID                    00008300
         BH    SKIP1          UNDERFLOW BY SETTING E**R=1,              00008400
         LER   F2,F0                                                    00008500
         LER   F3,F1                                                    00008600
         ME    F0,C6                                                    00008700
         AED   F0,C5                                                    00008800
         MEDR  F0,F2                                                    00008900
         AED   F0,C4                                                    00009000
         MEDR  F0,F2                                                    00009100
         AED   F0,C3                                                    00009200
         MEDR  F0,F2                                                    00009300
         AED   F0,C2                                                    00009400
         MEDR  F0,F2                                                    00009500
         AED   F0,C1                                                    00009600
         MEDR  F0,F2          E**(-R) READY IN F0                       00009700
         MED   F0,0(R7,R2)                                              00009800
*                                                                       00009900
SKIP1    AED   F0,0(R7,R2)    (E**R)*(2**(-C/16)) READY                 00010000
*                                                                       00010100
         LR    R6,R6          MULTIPLY BY 2**(-B)                       00010200
         BZ    SKIP2          BY HALVING B TIMES                        00010300
         SLL   R6,16                                                    00010400
MULT     MED   F0,HALF                                                  00010500
         BCT   R6,MULT                                                  00010600
*                                                                       00010700
SKIP2    LFXR  R6,F0                                                    00010800
         AR    R6,R5                                                    00010900
         LFLR  F0,R6                                                    00011000
*                                                                       00011100
EXIT     AEXIT                                                          00011200
*                                                                       00011300
* ARG TOO SMALL - GIVE UNDERFLOW                                        00011400
*                                                                       00011500
UNFLO    LE    F0,C5+2                                                  00011600
         MEDR  F0,F0                                                    00011700
         B     EXIT                                                     00011800
*                                                                       00011900
* ARG TOO LARGE - GIVE ERROR                                            00012000
*                                                                       00012100
ERROR    AERROR 6             ARG>174.6731                              00012200
         LED   F0,INFINITY    STANDARD FIXUP IS MAXIMUM FLOATING NO.    00012300
         B     EXIT                                                     00012400
*                                                                       00012500
         DS    0F                                                       00012600
LOG2H    DC    X'40B17218'    LOG(2) ROUNDED UP                         00012700
MAX      DC    X'42AEAC4E'    174.67306                                 00012800
MIN      DC    X'C2B437DF'    -180.21824                                00012900
INFINITY DC    X'7FFFFFFFFFFFFFFF'  STANDARD FIXUP                      00013000
NEAR0    DC    X'B2100000'    -2**60                                    00013100
C6       DC    X'3E591893'    0.1359497E-2                              00013200
C5       DC    X'3F2220559A15E158'   0.8331617720039062E-2              00013300
C4       DC    X'3FAAAA9D6AC1D734'   0.416666173078875E-1               00013400
C3       DC    X'402AAAAAA794AA99'   0.1666666659481656                 00013500
C2       DC    X'407FFFFFFFFAB64A'   0.4999999999951906                 00013600
C1       DC    X'40FFFFFFFFFFFCFC'   0.9999999999999892                 00013700
LOG2L    DC    X'B982E308654361C4'   LOG(2)-LOG2H TO 80 BITS            00013800
ML216    DC    X'BFB17217F7D1CF7A'   -LOG(2)/16 ROUNDED UP              00013900
HALF     DC    X'4080000000000000'   0.5                                00014000
SCALER   DC    X'45100000'                                              00014100
         ADATA                                                          00014200
MCONST   DC    X'4110000000000000'   2**(-0/16)                         00014300
         DC    X'40F5257D152486CD'   2**(-1/16)                         00014400
         DC    X'40EAC0C6E7DD243A'   2**(-2/16)                         00014500
         DC    X'40E0CCDEEC2A94E1'   2**(-3/16)                         00014600
         DC    X'40D744FCCAD69D6B'   2**(-4/16)                         00014700
         DC    X'40CE248C151F8481'   2**(-5/16)                         00014800
         DC    X'40C5672A115506DB'   2**(-6/16)                         00014900
         DC    X'40BD08A39F580C37'   2**(-7/16)                         00015000
         DC    X'40B504F333F9DE65'   2**(-8/16)                         00015100
         DC    X'40AD583EEA42A14B'   2**(-9/16)                         00015200
         DC    X'40A5FED6A9B15139'   2**(-10/16)                        00015300
         DC    X'409EF5326091A112'   2**(-11/16)                        00015400
         DC    X'409837F0518DB8AA'   2**(-12/16)                        00015500
         DC    X'4091C3D373AB11C4'   2**(-13/16)                        00015600
         DC    X'408B95C1E3EA8BD7'   2**(-14/16)                        00015700
         DC    X'4085AAC367CC487C'   2**(-15/16)                        00015800
         ACLOSE                                                         00015900
