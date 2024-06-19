*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DLOG.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

     TITLE 'DLOG -- DOUBLE PRECISION LOGARITHM FUNCTION'                00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
*                                                                       00000200
*      LOGARITHMIC FUNCTION (LONG)                                      00000300
*              1. WRITE X = (M*2**-Q)*16**P, M MANTISSA BETWEEN 1/2     00000400
*                   AND 1, Q INTEGER BETWEEN 0 AND 3. DEFINE A=1, B=0   00000500
*                     IF M GREATER THAN SQRT2/2, OTHERWISE A=1/2, B=1.  00000600
*              2. WRITE Z = (M-A)/(M+A), THEN                           00000700
*                   LOG(X) = (4P-Q-B)LOG(2)+LOG((1+Z)/(1-Z)).           00000800
*                                                                       00000900
* REVISION HISTORY
* ----------------
* DATE     NAME  REL   DR NUMBER AND TITLE
*
* 02/16/93  RAH  24V1  DR108626 - DLOG CAN ALTER F6 AND F7
*                        UNINTENTIONALLY. FIX - MOVED THE STED INST
*                        BEFORE THE START LABEL.
*
         MACRO                                                          00001000
         WORKAREA                                                       00001100
SAVE6    DS    D                                                        00001200
         MEND                                                           00001300
*                                                                       00001400
DLOG     AMAIN QDED=YES                                                 00001500
* COMPUTE LOG(X) IN DOUBLE PRECISION                                    00001600
         INPUT F0             SCALAR DP                                 00001700
         OUTPUT F0            SCALAR DP                                 00001800
         WORK  R2,R3,R4,R5,R6,R7,F1,F2,F3,F4,F6                         00001900
         STED  F6,SAVE6                                  /* DR108626 */
START    LER   F3,F1                                                    00002000
         LER   F2,F0                                                    00002100
         BNP   ERROR                                                    00002200
         LFXR  R6,F0                                                    00002400
         LFXR  R7,F1                                                    00002500
         LR    R2,R6                                                    00002600
         SR    R3,R3                                                    00002700
         SRDL  R2,24                                                    00002800
         SRL   R3,1                                                     00002900
         NCT   R5,R3          Q IN R5, M IN R7                          00003000
         SLL   R2,18                                                    00003100
         SR    R2,R5          4P-Q+OFFSET IN R6 TOP                     00003200
         SLDL  R6,61                                                    00003300
         N     R6,MASK                                                  00003400
         AHI   R6,X'4000'                                               00003500
         LFLR  F0,R6                                                    00003600
         LFLR  F1,R7                                                    00003700
         LED   F4,ONE                                                   00003800
         LED   F6,HALF                                                  00003900
         CE    F0,LIMIT                                                 00004000
         BH    POS                                                      00004100
         LED   F4,HALF                                                  00004200
         LED   F6,QUARTER                                               00004300
         BCTB  R2,*+1         B=1                                       00004400
*                                                                       00004500
POS      LA    R2,5(R2)       **INCREMENT BIAS BY 5  /*DR103652-ADD*/   00004601
         SRL   R2,16          GET 4P-Q-B+261 IN R2   /*DR103652-MOD*/   00004701
         AHI   R2,X'4600'     BOTTOM, AND FLOAT                         00004800
*                                                                       00004900
*  COMPUTE 2Z=(M-A)/(0.5M+0.5A)                                         00005000
*                                                                       00005100
         LER   F2,F0                                                    00005200
         LER   F3,F1                                                    00005300
         MED   F2,HALF                                                  00005400
         SEDR  F0,F4                                                    00005500
         AEDR  F2,F6                                                    00005600
         LER   F0,F0          CHECK IF DIVIDEND ZERO                    00005700
        QDEDR  F0,F2                                                    00005800
*                                                                       00005900
*  COMPUTE LOG((1+Z)/(1-Z)) BY A MINIMAX                                00006000
*  APPROXIMATION OF THE FORM                                            00006100
*  W+C1*W**3(W**2+C2+C3/(W**2+C4+C5/(W**2+C6))).                        00006200
         LER   F2,F0                                                    00006300
         LER   F3,F1                                                    00006400
         MEDR  F2,F2                                                    00006500
         LED   F4,C6                                                    00006600
         AEDR  F4,F2                                                    00006700
         LED   F6,C5                                                    00006800
        QDEDR  F6,F4                                                    00006900
         AED   F6,C4                                                    00007000
         AEDR  F6,F2                                                    00007100
         LED   F4,C3                                                    00007200
        QDEDR  F4,F6                                                    00007300
         AED   F4,C2                                                    00007400
         AEDR  F4,F2                                                    00007500
         MED   F4,C1                                                    00007600
         MEDR  F4,F2                                                    00007700
         MEDR  F4,F0                                                    00007800
         AEDR  F4,F0                                                    00007900
*                                                                       00008000
         LFLR  F0,R2                                                    00008100
         SER   F1,F1          4P-Q-B+261  /*DR103652-MOD COMMENT*/      00008201
         SE    F0,E261        4P-Q-B      /*DR103652-MOD*/              00008301
         MED   F0,LOGE2                                                 00008400
         AEDR  F0,F4                                                    00008500
*                                                                       00008600
EXIT     LED   F6,SAVE6                                                 00008700
         AEXIT                                                          00008800
*                                                                       00008900
ERROR    AERROR 7             ARG<=0                                    00009000
         LER   F0,F0                                                    00009100
         BZ    FIXUP                                                    00009200
         LECR  F0,F0                                                    00009300
         B     START                                                    00009400
FIXUP    LED   F0,INFINITY                                              00009500
         B     EXIT                                                     00009600
*                                                                       00009700
         DS    0D                                                       00009800
INFINITY DC    X'FFFFFFFFFFFFFFFF'    FIX FOR ZERO ARGUMENT             00009900
C6       DC    X'C158FA4E0E40C0A5'    -0.5561109595943017E+1            00010000
C5       DC    X'C12A017578F548D1'    -0.2625356171124214E+1            00010100
C4       DC    X'C16F2A64DDFCC1FD'    -0.6947850100648906E+1            00010200
C3       DC    X'C38E5A1C55CEB1C4'    -0.2277631917769813E+4            00010300
C2       DC    X'422FC604E13C20FE'     0.4777351196020117E+2            00010400
C1       DC    X'3DDABB6C9F18C6DD'     0.2085992109128247E-3            00010500
LOGE2    DC    X'40B17217F7D1CF7B'     LOG(2) BASE E + FUDGE 1          00010600
ONE      DC    X'4110000000000000'    1.0                               00010700
HALF     DC    X'4080000000000000'    0.5                               00010800
QUARTER  DC    X'4040000000000000'    0.25                              00010900
LIMIT    DC    X'40B504F3'               1/SQRT 2                       00011000
MASK     DC    X'00FFFFFF'                                              00011100
E261     DC    X'43105000'    261.0   /*DR103652-MOD*/                  00011201
         ACLOSE                                                         00011300
