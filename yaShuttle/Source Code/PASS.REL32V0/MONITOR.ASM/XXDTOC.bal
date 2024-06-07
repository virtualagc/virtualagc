*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    XXDTOC.bal
*/ Purpose:     This is a part of the "Monitor" of the HAL/S-FC 
*/              compiler program.
*/ Reference:   "HAL/S Compiler Functional Specification", 
*/              section 2.1.1.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-07 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ are from the Virtual AGC Project.
*/              Comments beginning merely with * are from the original 
*/              Space Shuttle development.

D2C      TITLE 'HAL COMPILER FLOAT TO CHARACTER CONVERSION'             00000100
XXDTOC   CSECT                                                          00000200
         REGEQU                                                         00000300
         USING *,15                                                     00000400
*R0      CODE FOR LENGTH (0=E, 8=D)                                     00000500
*R15     UPON EXIT CONTAINS DESCRIPTOR OF CHAR STRING                   00000600
         LTR   R0,R0                                                    00000700
         BNZ   DTOC                                                     00000800
         MVI   ADCON,14-1 SET LENGTH                                    00000900
         STE   F0,DOUBLE                                                00001000
         SDR   F0,F0                                                    00001100
         AE    F0,DOUBLE                                                00001200
         BNZ   *+14                                                     00001300
         MVC   CHARSTR+1(14),ZEROES                                     00001400
         B     PUTSCALR                                                 00001500
         LA    R6,MOVEPAT                                               00001600
FLFX     L     R10,TBLADDR                                              00001700
         SR    R1,R1                                                    00001800
         MVI   WSWC,C' '                                                00001900
         LTER  F0,F0                                                    00002000
         BH    CVFLT                                                    00002100
         MVI   WSWC,C'-'                                                00002200
         LPDR  F0,F0                                                    00002300
CVFLT    STD   F0,WINT                                                  00002400
         SR    R4,R4                                                    00002500
         SR    R3,R3                                                    00002600
         IC    R3,WINT                                                  00002700
         SH    R3,H78                                                   00002800
         BZ    CVFLD                                                    00002900
         BH    ONTEN                                                    00003000
         LA    R4,4                                                     00003100
         LPR   R3,R3                                                    00003200
ONTEN    MH    R3,HLOG16                                                00003300
         AH    R3,H8192                                                 00003400
         SRL   R3,14                                                    00003500
         CH    R3,H78                                                   00003600
         BNH   ONAIT                                                    00003700
         LH    R3,H78                                                   00003800
ONAIT    EX    0,ARSR(R4)                                               00003900
         SR    R2,R2                                                    00004000
         D     R2,F10                                                   00004100
         SLDA  R2,3                                                     00004200
         LTR   R2,R2                                                    00004300
         BZ    UPAIT                                                    00004400
         EX    0,DDMD(R4)                                               00004500
UPAIT    LTR   R2,R3                                                    00004600
         BZ    CVFLT                                                    00004700
         LA    R2,72(0,R2)                                              00004800
         EX    0,DDMD(R4)                                               00004900
         B     CVFLT                                                    00005000
CVFLD    MVI   WINT,0                                                   00005100
         LM    R2,R3,WINT                                               00005200
         D     R2,TNT9                                                  00005300
         CVD   R3,WORK                                                  00005400
         MVO   WINT(5),WORK+3(5)                                        00005500
         CVD   R2,WORK                                                  00005600
         MVC   WINT+4(5),WORK+3                                         00005700
         NI    WINT+8,240                                               00005800
         MVI   WINT+9,12                                                00005900
         TM    WINT,240                                                 00006000
         BZ    RET                                                      00006100
         MVO   WINT(10),WINT(9)                                         00006200
         AH    R1,ONE                                                   00006300
RET      AH    R1,H15                                                   00006400
         BR    R6                                                       00006500
MOVEPAT  DC    0H'0'                                                    00006600
         MVC   CHARSTR(15),PATTERN                                      00006700
         NI    WINT+4,240                                               00006800
         CVD   R1,WORK                                                  00006900
         L     R4,WORK+4                                                00007000
         SRL   R4,4                                                     00007100
         STC   R4,WINT+5                                                00007200
         ED    CHARSTR(15),WINT                                         00007300
         LTR   R1,R1                                                    00007400
         BM    *+12                                                     00007500
         MVI   CHARSTR+12,C'+'                                          00007600
         B     *+8                                                      00007700
         MVI   CHARSTR+12,C'-'                                          00007800
         IC    R3,WSWC                                                  00007900
         STC   R3,CHARSTR+1                                             00008000
PUTSCALR DC    0H'0'                                                    00008100
         L     15,ADCON       DESCRIPTOR                                00008200
         BR    14                                                       00008300
         EJECT                                                          00008400
DTOC     MVI   ADCON,23-1 DESCRIPTOR                                    00008500
         LTER  F0,F0                                                    00008600
         BNZ   *+14                                                     00008700
         MVC   CHARSTR+1(23),ZEROES                                     00008800
         B     PUTDSCLR                                                 00008900
         BAL   R6,FLFX                                                  00009000
         MVC   CHARSTR(24),DPATTERN                                     00009100
         CVD   R1,WORK                                                  00009200
         L     R4,WORK+4                                                00009300
         STC   R4,WINT+10                                               00009400
         SRL   R4,8                                                     00009500
         STC   R4,WINT+9                                                00009600
         ED    CHARSTR(24),WINT                                         00009700
         LTR   R1,R1                                                    00009800
         BM    *+12                                                     00009900
         MVI   CHARSTR+21,C'+'                                          00010000
         B     *+8                                                      00010100
         MVI   CHARSTR+21,C'-'                                          00010200
         IC    R3,WSWC                                                  00010300
         STC   R3,CHARSTR+1                                             00010400
PUTDSCLR DC    0H'0'                                                    00010500
         L     15,ADCON                                                 00010600
         BR    14                                                       00010700
         EJECT                                                          00010800
DDMD     DD    F0,0(R2,R10)                                             00010900
         MD    F0,0(R2,R10)                                             00011000
ARSR     AR    R1,R3                                                    00011100
H78      DC    H'78'                                                    00011200
         SR    R1,R3                                                    00011300
DOUBLE   DS    D                                                        00011400
WORK     DS    D                                                        00011500
CHARSTR  DS    CL24                                                     00011600
WINT     DS    CL24                                                     00011700
F10      DC    F'10'                                                    00011800
ADCON    DC    A(CHARSTR+1)                                             00011900
TBLADDR  DC    V(TENSTBL)                                               00012000
TNT9     DC    F'1000000000'                                            00012100
HLOG16   DC    H'19728'                                                 00012200
H8192    DC    H'8192'                                                  00012300
H15      DC    H'15'                                                    00012400
ONE      DC    H'1'                                                     00012500
WSWC    DC    C' '                                                      00012600
PATTERN  DC    X'4021204B',7X'20',X'C5',3X'20'                          00012700
DPATTERN DC    X'4021204B',16X'20',X'C5202020'                          00012800
ZEROES   DC    CL23' 0.0'                                               00012900
         END                                                            00013000
