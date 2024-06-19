*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    EXP.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

       TITLE 'EXP -- SINGLE PRECISION EXPONENTIAL FUNCTION'             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
* EXP: EXPONENTIAL(SINGLE)                                              00000200
*                                                                       00000300
*        1. INPUT AND OUTPUT VIA F0.                                    00000400
*        2. LET X*(LOG E BASE 2) = 4R-S-T, WHERE R AND S ARE INTEGERS,  00000500
*           0<=S<=3, AND 0<=T<1.                                        00000600
*        3. CALCULATE 2**(-T) USING A RATIONAL FUNCTION APPROXIMATION.  00000700
*        4. THEN EXP(X)=(16**R)(2**(-S))(2**(-T)).                      00000800
*        5. ERRORS ARE GIVEN IF X>174.673 OR X<-180.218.                00000900
*        6. FLOATING REGISTERS USED: F0-F3.                             00001000
*                                                                       00001100
EXP      AMAIN                                                          00001200
* COMPUTES E**X IN SINGLE PRECISION                                     00001300
         INPUT F0             SCALAR SP                                 00001400
         OUTPUT F0            SCALAR SP                                 00001500
         WORK  R1,R2,R3,R4,R5,R6,F1,F2                                  00001600
         CE    F0,MAX         GIVE ERROR IF ARG                         00001700
         BNH   LOW            GREATER THAN 174.673                      00001800
         AERROR 6             ARG > 174.673                             00001900
         LE    F0,ALLF                                                  00002000
         LECR  F0,F0                                                    00002100
         B     EXIT                                                     00002200
LOW      CE    F0,MIN                                                   00002300
         BNL   OK             IF ARG LESS THAN -180.218,                00002400
         LE    F0,ONE         LOAD F0 WITH TINY NUMBER                  00002500
         MER   F0,F0          AND GIVE EXPONENT UNDERFLOW.              00002600
         B     EXIT                                                     00002700
*                                                                       00002800
OK       SER   F1,F1                                                    00002900
         LER   F2,F0                                                    00003000
         MED   F0,LOG2E       LOG2E=4*LOG(BASE 2)E                      00003100
         BM    MINUS                                                    00003200
         AED   F0,CH47        SEPARATE INTEGER AND FRACTION             00003300
         B     TOG                                                      00003400
MINUS    SED   F0,CH47                                                  00003500
*                                                                       00003600
TOG      LFXR  R1,F0          INTEGER IN R1                             00003700
         LFXR  R3,F1          FRACTION IN R2                            00003800
*                                                                       00003900
*  NOW, IF X<0, THEN R1 CONTAINS -R IN THE LOW 8 BITS, AND R3           00004000
*  CONTAINS S IN THE TOP 2 BITS AND T IN THE LOW 30 BITS.               00004100
*   IF X>=0, THEN R1 CONTAINS R-1 IN THE LOW 8 BITS, AND R3 HAS         00004200
*  -S-1 IN THE TOP 2 BITS AND -T (WITHOUT THE SIGN BIT) IN LOW 30 BITS  00004300
*                                                                       00004400
         LER   F2,F2                                                    00004500
         BNP   NEG                                                      00004600
         X     R1,ALLF        -R IN R1                                  00004700
         X     R3,ALLF        S+T IN R3 HIGH (IGNORE ERROR IN LAST BIT) 00004800
*                                                                       00004900
*  BELOW THIS POINT, R1 LOW 8 BITS CONTAIN -R,                          00005000
*  AND R3 CONTAINS S+T                                                  00005100
*                                                                       00005200
NEG      SLL   R1,24          SHIFT -R TO CHARACTERISTIC POSITION       00005300
         AHI   R1,X'C000'     CHAR. OFFSET = -64                        00005400
         SR    R2,R2          CLEAR R2 TO RECEIVE S                     00005500
         SLDL  R2,2           S IN R2, T IN R3 UNSIGNED                 00005600
         SLL   R2,16          SHIFT TO TOP HALFWORD                     00005700
         SRL   R3,4           GIVE T POSITIVE SIGN (B3)                 00005800
         LR    R6,R3          T IN R6                                   00005900
         MR    R6,R6                                                    00006000
         SRDL  R6,1           T*T IN R6 (B7)                            00006100
         LR    R4,R6          AND IN R4 (B7)                            00006200
         M     R4,C           C*T*T (B3)                                00006300
         SRA   R4,1           C*T*T (B4)                                00006400
         A     R6,A           A+T*T (B7)                                00006500
         LR    R5,R6                                                    00006600
         L     R6,B           B (B11)                                   00006700
         DR    R6,R5          B/(A+T*T) (B4)                            00006800
         SRL   R3,1           T (B4)                                    00006900
         SR    R6,R3          -T+B/(A+T*T) (B4)                         00007000
         A     R6,D           D-T+B/(A+T*T) (B4)                        00007100
         AR    R6,R4          CT*T-T+D+B/(A+T*T) (B4)                   00007200
         LR    R4,R3                                                    00007300
         SRL   R4,1           2T (B6)                                   00007400
         DR    R4,R6          2T/(CT*T-T+D+B/(A+T*T)) (B2)              00007500
         SRA   R4,4           AND AT B6                                 00007600
*                                                                       00007700
         A     R4,FONE        2**(-T) READY AT BIT 6 OF R4              00007800
*                                                                       00007900
         SRL   R4,58          2**(-S)*2**(-T) AT BIT 6 OF R4            00008000
         S     R4,ALLF        ADD 1 AT BIT 31 TO ROUND                  00008100
*                                                                       00008200
         C     R4,FONE        FIXUP NEEDED IF CARRY INTO CHAR. POSITION 00008300
         SRL   R4,1           SHIFT TO MANTISSA POSITION BIT 7          00008400
         BL    READY                                                    00008500
*                                                                       00008600
         L     R4,ONE         FIXUP OCCURS HERE                         00008700
*                                                                       00008800
READY    SR    R4,R1          MULTIPLY BY 16**R                         00008900
         LFLR  F0,R4          AND FLOAT                                 00009000
EXIT     AEXIT                                                          00009100
*                                                                       00009200
         DS    0F                                                       00009300
MAX      DC    X'42AEAC4F'    174.673                                   00009400
MIN      DC    X'C2B437E0'    -180.218                                  00009500
LOG2E    DC    X'415C551D94AE0BF8'   4*LOG E BASE 2                     00009600
CH47     DC    X'4710000000000000'                                      00009700
ALLF     DC    X'FFFFFFFF'           ALSO = F'-1'                       00009800
A        DC    X'576AE119'    87.417497 (B7)                            00009900
B        DC    X'269F8E6B'    617.97227 (B11)                           00010000
C        DC    X'B9059003'    -0.03465736 (B-4)                         00010100
D        DC    X'B05CFCE3'    -9.95459578 (B4)                          00010200
FONE     DC    X'02000000'                                              00010300
ONE      DC    X'01100000'                                              00010400
         ACLOSE                                                         00010500
