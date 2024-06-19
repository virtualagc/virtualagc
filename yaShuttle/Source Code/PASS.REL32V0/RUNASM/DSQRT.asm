*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DSQRT.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'DSQRT -- DOUBLE PRECISION SQUARE ROOT FUNCTION'         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 00000200
*  DOUBLE SQUARE ROOT _ 31 BITS ACCURACY                                00000300
*         USE QUADRATIC FUNCTION IN HALF WD FIXED, ONE NEWTON-RAPHSON   00000400
*         ITERATION(SP), THEN A N-R IN FORM X3=X2 + (X-X2(X2))/(X2+X2)  00000500
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 00000600
DSQRT    AMAIN                                                          00000700
* COMPUTES SQRT(X) IN DOUBLE PRECISION                                  00000800
         INPUT F0             SCALAR DP                                 00000900
         OUTPUT F0            SCALAR DP                                 00001000
         WORK  R2,R4,R5,R6,R7,F1,F2,F4,F5                               00001100
         XR    R6,R6         . ZERO REG                                 00001200
         LFLR  F4,R6         . ZERO REG                                 00001300
         AER   F4,F0         . SET REG AND CC IN PSW                    00001400
         BNP   ERROR         . INPUT MUST BE GREATER THAN ZERO          00001500
START    LFXR  R7,F4         . USE NORMALIZED INPUT                     00001600
         AHI   R7,X'4100'    . CHAR ADJUSTMENT                          00001700
         SLDL  R6,7          . NEED 6 BITS AND SIGN OF MANTISSA         00001800
         SLL   R6,6          . SET UP FOR LATER ADJUSTMENT              00001900
         XHI   R7,X'8000'    . COMPLEMENT FIRST BIT                     00002000
         SLDL  R6,1          . LAST BIT OF CHAR DETERMINES SHIFT        00002100
         SLL   R6,17         . MOVE TO HIGH ORDER BITS                  00002200
         AHI   R6,5          . FINAL SHIFT ADJUSTMENT                   00002300
         SRL   R7,1          . ADJUST MANTISSA FOR COMPUTATION          00002400
         LA    R2,CONST      . ADDRESS OF DATA AREA                     00002500
         USING CONST,R2      . ESTABLISH BASE                           00002600
         CHI   R7,X'2000'    . COMPARE MANTISSA                         00002700
         BC    2,LESS        . BRANCH ON LESS THAN                      00002800
         LA    R2,1(R2)      . BUMP TO CORRECT COEF.                    00002900
LESS     LR    R5,R7         . NEED VALUE LATER - X                     00003000
         MH    R5,A          . AX                                       00003100
         AH    R5,B          . AX+B                                     00003200
         MR    R5,R7         . (AX+B)X                                  00003300
         AH    R5,C          . (AX+B)X + C - REG 5 HAS QUADRATIC        00003400
         DROP  R2            . DO NOT NEED BASE REG                     00003500
         SRL   R5,62         . SHIFT BY BITS IN R6 - TO ADJUST          00003600
         NHI   R6,X'FF00'    . ZERO SHIFT COUNT                         00003700
         OR    R6,R5         . FLOAT  QUADRATIC-CHAR. PLUS MANTISSA     00003800
         LFLR  F2,R6         . LOAD INTO FLOATING REGISTER - X1         00003900
         DER   F4,F2         . FIRST PASS                               00004000
         AER   F4,F2         .   THROUGH NEWTON-RAPHSON                 00004100
         ME    F4,HALF       .   RESULT=X2                              00004200
         XR    R7,R7         . ZERO REG.                                00004300
         LFLR  F5,R7         . ZERO REG                                 00004400
         LER   F2,F4         . SAME FIRST 32 BITS IN F2                 00004500
         MER   F2,F4         .  X2(X2)                                  00004600
         SEDR  F0,F2         .  X - X2(X2)       X= INPUT VALUE         00004700
         LER   F2,F4         . RESTORE X2                               00004800
         AER   F2,F2         .  X2 + X2                                 00004900
         DER   F0,F2         .  (X - X2(X2)) / (X2+X2)                  00005000
         AEDR  F0,F4         .  X2 + ( X - X2(X2)) / (X2 + X2)          00005100
         LFXR  R6,F1         . NEED TO SAVE FIRST 10 BITS CLEAR REM.    00005200
         N     R6,MSK        .   MASK TO SAVE 10                        00005300
         LFLR  F1,R6         . RESTOR E F1                              00005400
EXIT     AEXIT                                                          00005500
*                                                                       00005600
ERROR    BZ    EXIT          . CANNOT BE ZERO                           00005700
         AERROR 5            . ARGUMENT LESS THAN ZERO                  00005800
         LECR  F0,F0         . COMPLEMENT                               00005900
         LECR  F4,F4         . COMPLEMENT REG                           00006000
         B     START                                                    00006100
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 00006200
         DS    0F                                                       00006300
HALF     DC    X'40800000'   . 0.5                                      00006400
MSK      DC    X'FFC00000'   .  MASK TO SAVE 10 BITS                    00006500
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 00006600
*                                                                       00006700
* COEFFICIENTS FOR QUADRATIC                                            00006800
*                                                                       00006900
         ADATA                                                          00007000
CONST    DS    0H                                                       00007100
A        DC    X'AF76'       .MANTISSA LT 0.25                          00007200
         DC    X'F5EF'       .MANTISSA GE 0.25                          00007300
B        DC    X'433E'       .MANTISSA LT 0.25                          00007400
         DC    X'219F'       .MANTISSA GE 0.25                          00007500
C        DC    X'0427'       .MANTISSA LT 0.25                          00007600
         DC    X'084D'       .MANTISSA GE 0.25                          00007700
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 00007800
         ACLOSE                                                         00007900
