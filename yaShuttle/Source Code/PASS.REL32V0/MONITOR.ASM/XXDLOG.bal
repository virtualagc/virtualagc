*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    XXDLOG.bal
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

DLOG     TITLE 'COMPILER''S DLOG ROUTINE'                               00000100
XXDLOG   CSECT                                                          00000200
         USING *,15                                                     00000300
         REGEQU                                                         00000400
         STD   F0,TEMP                                                  00000500
       LM     R2,R3,TEMP                                                00000600
       LTR     R0,R2                                                    00000700
       BC      12,ERROR        IF ARG IS 0 OR NEGATIVE, ERROR           00000800
       SRDL    R0,24          CHAR IN LOW R0, 1ST DIGIT IN HIGH R1      00000900
       SLL     R0,2                                                     00001000
       STH     R0,IPART+2     FLOAT 4*CHAR AND SAVE IT                  00001100
       SRL     R1,29          1ST THREE BITS OF M IN R1                 00001200
       IC      R1,TABLE(R1)  NUMBER OF LEADING ZEROS (=Q) IN R1         00001300
       SLDL    R2,0(R1)                                                 00001400
       STM     R2,R3,BUFF                                               00001500
       MVI     BUFF,X'40'      M = FRACTION*2**Q IN CELL BUFF           00001600
       SPACE                                                            00001700
       SR      R2,R2         IF M LESS THAN SQRT2/2, R2=0               00001800
       LD      F0,BUFF       PICK UP M IN F0                            00001900
       CE      F0,LIMIT       IF M GREATER THAN SQRT2/2, R2=8           00002000
       BC      2,READY                                                  00002100
       LA      R2,8                                                     00002200
       LA      R1,1(R1)      CRANK R1 BY 1. Q+B IN R1                   00002300
       SPACE                                                            00002400
READY  HDR     F2,F0         COMPUTE 2Z = (M-A)/(0.5M+0.5A),            00002500
       SD      F0,ONE(R2)      A = 1 OR 1/2                             00002600
       AD      F2,HALF(R2)   0.5M+0.5A HAS 56 BITS                      00002700
       DDR     F0,F2                                                    00002800
       SPACE                                                            00002900
       LDR     F2,F0         COMPUTE LOG((1+Z)/(1-Z)) BY MINIMAX        00003000
       STD     F0,TEMP                                                  00003100
       MDR     F2,F2           APPROXIMATION OF THE FORM                00003200
       LD      F4,C6              W+C1*W**3(W**2+C2+C3/                 00003300
       ADR     F4,F2               (W**2+C4+C5/(W**2+C6)))              00003400
       LD      F0,C5                                                    00003500
       DDR     F0,F4                                                    00003600
       AD      F0,C4                                                    00003700
       ADR     F0,F2                                                    00003800
       LD      F4,C3                                                    00003900
       DDR     F4,F0                                                    00004000
       AD      F4,C2                                                    00004100
       ADR     F4,F2                                                    00004200
       MD      F4,C1                                                    00004300
       MDR     F4,F2                                                    00004400
       LD      F0,TEMP                                                  00004500
       MDR     F4,F0                                                    00004600
       ADR     F4,F0                                                    00004700
       SPACE                                                            00004800
       LD      F0,IPART       4*(P+64)                                  00004900
       LA      R1,256(R1)    4*64+Q+B                                   00005000
       STH     R1,IPART+2     FLOAT THIS AND SUBTRACT FROM F0           00005100
       SE      F0,IPART         TO OBTAIN 4P-Q-B                        00005200
       MD      F0,LOGE2       MULTIPLY BY LOG(2) BASE E                 00005300
       ADR     F0,F4           AND ADD TO LOG((1+Z)/(1-Z))              00005400
EXIT     BR    14                                                       00005500
ERROR    LA    15,1                                                     00005600
         BR    14                                                       00005700
       DS      0D                                                       00005800
IPART    DC    X'4600000000000000'                                      00005900
TEMP     DS    D                                                        00006000
BUFF     DS    D                                                        00006100
C6     DC      X'C158FA4E0E40C0A5'    -0.5561109595943017E+1            00006200
C5     DC      X'C12A017578F548D1'    -0.2625356171124214E+1            00006300
C4     DC      X'C16F2A64DDFCC1FD'    -0.6947850100648906E+1            00006400
C3     DC      X'C38E5A1C55CEB1C4'    -0.2277631917769813E+4            00006500
C2     DC      X'422FC604E13C20FE'     0.4777351196020117E+2            00006600
C1     DC      X'3DDABB6C9F18C6DD'     0.2085992109128247E-3            00006700
LOGE2  DC      X'40B17217F7D1CF7B'     LOG(2) BASE E + FUDGE 1          00006800
LOGTE  DC      X'406F2DEC549B943A'     LOG(E) BASE 10 + FUDGE 1         00006900
TABLE  DC      X'0302010100000000'                                      00007000
ONE    DC      X'4110000000000000'     THEESE THREE                    00007100
HALF   DC      X'4080000000000000'       CONSTANTS MUST BE              00007200
QUART  DC      X'4040000000000000'          CONSECUTIVE                 00007300
LIMIT  DC      X'40B504F3'               1/SQRT 2                       00007400
       END                                                              00007500
