*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    SQRT.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

       TITLE 'SQRT -- SINGLE PRECISION SQUARE ROOT FUNCTION'            00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
* SQRT: SQUARE ROOT(SINGLE)                                             00000200
*                                                                       00000300
*        1. INPUT AND OUTPUT VIA F0.                                    00000400
*        2. WRITE X = 16**(2P-Q)*M, WHERE 1/16<=M<1.                    00000500
*        3. COMPUTE SQRT(M) BY A HYPERBOLIC APPROXIMATION               00000600
*           OF THE FORM A-B/(C+M).                                      00000700
*        4. THEN SQRT(X) = (16**P)(4**(-Q))(SQRT(M)).                   00000800
*        5. FOLLOW WITH TWO PASSES OF THE NEWTON-RAPHSON ITERATION.     00000900
*        6. REGISTERS USED: R5-R7,F0-F4.                                00001000
*        7. AVAIL NOT DISTURBED.                                        00001100
*                                                                       00001200
SQRT     AMAIN INTSIC=YES                                               00001300
* COMPUTES SQUARE ROOT IN SINGLE PRECISION                              00001400
         INPUT F0             SCALAR SP                                 00001500
         OUTPUT F0            SCALAR SP                                 00001600
         WORK  R1,R5,R6,R7,F1,F2,F3                                     00001700
         LA    R1,A                                                     00001800
         USING A,R1                                                     00001900
START    LER   F2,F0                                                    00002000
         BNP   ERROR          ARGUMENT NEGATIVE OR ZERO                 00002100
*                                                                       00002200
         LFXR  R7,F0          TRANSFER TO GENERAL REGISTER              00002300
         XR    R6,R6                                                    00002400
         SLDL  R6,7           Q & MANTISSA IN R7                        00002500
         SLL   R6,24          CHAR OF ANSWER - (Q+32) IN R6             00002600
         LR    R7,R7          CHECK FOR Q=1                             00002700
         BCF   5,GORP                                                   00002800
*                                                                       00002900
         AHI   R6,X'0100'     ADD 1 TO CHAR FOR Q=1                     00003000
         LA    R1,2(R1)       FULLWORD INDEX                            00003100
*                                                                       00003200
GORP     LR    R5,R6          CHARACTERISTIC OF ANSWER IN R5            00003300
         SRA   R7,1            FIXED M/2 + 'QQ' IN TOP BITS             00003400
         A     R7,C           ADD C/2, AND ELIMINATE 'QQ'               00003500
         L     R6,B           -B/2 OR -B/8 AT BIT 7(MANTISSA POS.)      00003600
         DR    R6,R7          (R6) = (4**(-Q))(-B/(C+M)) AT BIT 7       00003700
         A     R6,A           A OR A/4 AT BIT 7 + CHAR=32               00003800
         AR    R6,R5          RESTORE CHARACTERISTIC OF ANSWER          00003900
         LFLR  F1,R6                                                    00004000
*                                                                       00004100
         DROP  R1                                                       00004200
*                                                                       00004300
*  TWO PASSES OF THE NEWTON-RAPHSON ITERATION                           00004400
*                                                                       00004500
         DER   F0,F1                                                    00004600
         AER   F0,F1                                                    00004700
         LE    F3,FHALF                                                 00004800
         MER   F0,F3                                                    00004900
         DER   F2,F0                                                    00005000
*                                                                       00005100
         NHI   R6,X'FF00'     PUT CHARACTERISTIC OF                     00005200
         A     R6,ROUND       ANSWER IN ROUND                           00005300
         LFLR  F1,R6          DIGIT, AND ADD                            00005400
         AER   F0,F1          TO INTERMEDIATE RESULT                    00005500
*                                                                       00005600
         SER   F0,F2                                                    00005700
         MER   F0,F3                                                    00005800
         AER   F0,F2          ANSWER IN F0                              00005900
*                                                                       00006000
EXIT     AEXIT                AND RETURN                                00006100
*                                                                       00006200
ERROR    BCB   4,EXIT         EXIT IF ARG=0                             00006300
         AERROR 5             ARGUMENT<0                                00006400
         LECR  F0,F0          FIXUP: GET |ARG|                          00006500
         B     START          AND TRY AGAIN                             00006600
*                                                                       00006700
FHALF    DC    E'0.5'                                                   00006800
ROUND    DC    X'00000001'                                              00006900
*                                                                       00007000
         ADATA                                                          00007100
A        DC    X'21AE7D00'    1.6815948=A + X'20'                       00007200
         DC    X'206B9F40'    0.4203987=A/4 + X'20'                     00007300
B        DC    X'FF5B02F1'    -1.2889728=B                              00007400
         DC    X'FFD6C0BD'    -0.3222432=B/4                            00007500
C        DC    X'35CFC610'    0.8408065=C/2                             00007600
         DC    X'75CFC610'    0.8408065=C/2 + X'40'                     00007700
         ACLOSE                                                         00007800
