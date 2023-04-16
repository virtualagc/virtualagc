*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    XXDSQRT.bal
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

SQRT     TITLE 'COMPILER''S DSQRT ROUTINE'                              00000100
XXDSQRT  CSECT                                                          00000200
         USING *,15                                                     00000300
         REGEQU                                                         00000400
       LTDR    F4,F0                                                    00000500
       BC      4,ERROR         IF NEGATIVE ARG, ERROR                   00000600
       BC      8,EXIT          IF ARG IS 0, ANSWER IS 0. RETURN         00000700
       STE     F4,BUFF                                                  00000800
       SPACE                                                            00000900
       L       R0,BUFF        COMPUTE TARGET CHARACTERISTIC - 8         00001000
       AL      R0,BIAS          = X'31000000' CHAR OF X'41' MINUS 2*8   00001100
       SRDL    R0,25            LOW R0 = X'40'+P+Q-8                    00001200
       STC     R0,BUFF        GIVE THIS CHARACTERISTIC TO M AND B       00001300
       STC     R0,B             THIS SEEMINGLY ARTIFICIAL CHAR WAS      00001400
       LE      F2,BUFF            CHOSEN TO AID THE FINAL ROUNDING      00001500
       AE      F2,B           (M+B)*16**(P+Q-8)                         00001600
       ME      F2,A           A*(M+B)*16**(P+Q), A IS SCALED BY 8       00001700
       LTR     R1,R1                                                    00001800
       BC      10,*+8          IF Q=1, 1ST APPROX. Y0 IS READY          00001900
       AER     F2,F2         IF Q=0, MULTIPLY BY 4 TO OBTAIN Y0         00002000
       AER     F2,F2                                                    00002100
       SPACE                                                            00002200
       DER     F4,F2         NEWTON-RAPHSON ITERATIONS                  00002300
       AUR     F4,F2                                                    00002400
       HER     F4,F4         Y1 = (Y0+ARG/Y0)/2  IN SHORT PRECISION     00002500
       LER     F2,F0                                                    00002600
       DER     F2,F4                                                    00002700
       AUR     F2,F4                                                    00002800
       HER     F2,F2         Y2 = (Y1+ARG/Y1)/2  IN SHORT PRECISION     00002900
       LDR     F4,F0                                                    00003000
       DDR     F4,F2                                                    00003100
       AWR     F4,F2                                                    00003200
       HDR     F4,F4         Y3 = (Y2+ARG/Y2)/2  IN LONG PRECISION      00003300
       SPACE                                                            00003400
       DDR     F0,F4         Y4 = (ARG/Y3-Y3)/2-D+D+Y3 FOR ROUNDING     00003500
       SDR     F0,F4           1ST APPOXROX IS SO CHOSEN THAT           00003600
       HER     F0,F0             ARG/Y3-Y3 IS LESS THAN 16**(P+Q-8)     00003700
       SU      F0,B                 HENCE 'HER' IS GOOD ENOUGH          00003800
       AU      F0,B             -D+D IS TO CHOP OFF EXCESS DIGITS OF    00003900
       ADR     F0,F4             NEGATIVE VALUE (ARG/Y3-Y3)/2           00004000
       SPACE                                                            00004100
EXIT   BR    14                                                         00004200
ERROR    DS    0H                                                       00004300
         LA    15,1                                                     00004400
         BR    14                                                       00004500
       DS      0E                                                       00004600
BIAS   DC      X'31000000'                                              00004700
A      DC      X'48385F07'     0.2202*16**8                             00004800
BUFF     DS    F                                                        00004900
B        DC    X'00423A2A'                                              00005000
OFFSET   EQU   X'C4'                                                    00005100
       END                                                              00005200
