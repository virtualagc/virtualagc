*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM17S3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM17S3--MATRIX TO A POWER, SP'                          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
EXPSAVE  DS    H                                                        00000400
NSAVE    DS    H                                                        00000500
         MEND                                                           00000600
MM17S3   AMAIN                                                          00000700
*                                                                       00000800
* RAISES M TO AN INTEGER POWER WHERE M IS A SINGLE PRECISION            00000900
*   3 X 3 MATRIX                                                        00001000
*                                                                       00001100
         INPUT R4,            MATRIX(3,3) SP                           X00001200
               R6,            INTEGER(POWER) SP                        X00001300
               R7             MATRIX(3,3) DP TEMPORARY WORKAREA         00001400
         OUTPUT R2            MATRIX(3,3) SP                            00001500
         WORK  R1,R3,R5,F0,F2,F4,F5                                     00001600
*                                                                       00001700
* ALGORITHM:                                                            00001800
*   SEE ALGORITHM DESCRIPTION IN MM17D3                                 00001900
*                                                                       00002000
         LFXI  R5,3           SET N TO 3                                00002100
         B     MERGE                                                    00002200
MM17SN   AENTRY                                                         00002300
*                                                                       00002400
* RAISES M TO AN INTEGER POWER WHERE M IS A SINGLE PRECISION            00002500
*   N X N MATRIX WHERE N IS NOT EQUAL TO 3.                             00002600
*                                                                       00002700
         INPUT R4,            MATRIX(N,N) SP                           X00002800
               R5,            INTEGER(N) SP                            X00002900
               R6,            INTEGER(POWER) SP                        X00003000
               R7             MATRIX(N,N) SP TEMPORARY WORKAREA         00003100
         OUTPUT R2            MATRIX(N,N) SP                            00003200
         WORK  R1,R3,F0,F2,F4,F5                                        00003300
*                                                                       00003400
* ALGORITHM:                                                            00003500
*   SEE ALGORITHM DESCRIPTION IN MM17D3                                 00003600
*                                                                       00003700
MERGE    LR    R1,R2          PUTS RESULT PTR IN R1 FOR                 00003800
*                             ADDRESSABILITY PURPOSES                   00003900
         LR    R2,R4                 "           "                      00004000
         LR    R3,R7                 "           "                      00004100
         STH   R5,NSAVE       SAVE N IN NSAVE                           00004200
         LR    R4,R5          SET R4 TO N                               00004300
         SLL   R4,1           SET R4 TO N * 2                           00004400
         LR    R3,R2          LOAD INPUT ADDRESS INTO R3                00004500
         BAL   R7,MULT        BRANCH TO THE MULTIPLY ROUTINE            00004600
*                             THIS GETS RESULT = M ** 2;                00004700
         CH    R6,=X'0002'                                              00004800
         BE    OUT            IF POWER = 2 THEN RETURN                  00004900
         SLL   R6,1                                                     00005000
         AHI   R6,1           SET R6 = SHL(POWER,1) + 1;                00005100
SHIFTED  TRB   R6,X'8000'     TEST BIT TO BE SHIFTED OFF                00005200
         SLL   R6,1           POWER = SHL(POWER,1)                      00005300
         BC    4,SHIFTED      IF BIT SHIFTED OFF WAS 0,                 00005400
*                             THEN CONTINUE SEARCH FOR SIGNIFICANT BIT  00005500
         B     TEST           TAKEN WHEN HIGHER ORDER BIT WAS 1         00005600
COMPLOOP LH    R3,ARG7        PASS TEMP AS RIGHT MULTIPLIER             00005700
         BAL   R7,MOVE                                                  00005800
TEST     TRB   R6,X'8000'     TEST BIT TO BE SHIFTED OFF                00005900
         SLL   R6,1                                                     00006000
         BC    4,NOBIT        IF NO 1 WAS SHIFTED OFF DON'T MULTIPLY    00006100
         LH    R3,ARG4        PASS M AS RIGHT MULTIPLIER                00006200
         BAL   R7,MOVE                                                  00006300
NOBIT    CH    R6,=X'8000'    TEST DONE BIT                             00006400
         BNE   COMPLOOP       IF NOT EQUAL THEN CONTINUE PROCESSING     00006500
OUT      AEXIT                                                          00006600
*                                                                       00006700
* THE NEXT 7 INSTRCUTIONS MOVES RESULT TO TEMPORARY                     00006800
*                                                                       00006900
MOVE     LH    R1,ARG2        PUT ADDRESS OF RESULT IN R1               00007000
         LH    R5,NSAVE       PUT N INTO R5                             00007100
         MIH   R5,NSAVE       PUT N ** 2 IN R5                          00007200
         LH    R2,ARG7        PUT ADDRESS OF TEMPORARY IN R2            00007300
MLOOP    LE    F0,0(R5,R1)    GET ELEMENT OF RESULT                     00007400
         STE   F0,0(R5,R2)    STORE ELEMENT INTO TEMPORARY              00007500
         BCTB  R5,MLOOP                                                 00007600
*                                                                       00007700
* THE FOLLOWING CODE PERFORMS THE MATRIX MULTIPLY OF EITHER             00007800
*   RESULT = TEMPORARY TEMPORARY;                                       00007900
*         OR                                                            00008000
*   RESULT = TEMPORARY M;                                               00008100
* THE POINTER IN R3 DETERMINES WHICH CASE IS TO BE DONE.                00008200
*                                                                       00008300
*   R1 POINTS TO RESULT                                                 00008400
*   R2 POINTS TO TEMPORARY                                              00008500
*   R3 POINTS TO EITHER TEMPORARY OR M                                  00008600
*                                                                       00008700
MULT     STH   R6,EXPSAVE     SAVE EXPONENT                             00008800
         LFLR  F4,R7          SAVE RETURN IN F4                         00008900
         LH    R5,NSAVE       SET R5 TO N                               00009000
LOOP3    LH    R7,NSAVE       SET R7 TO N                               00009100
LOOP2    LH    R6,NSAVE       SET R6 TO N                               00009200
         LFLR  F5,R3          SAVE PTR TO COLUMN OF RIGHT MATRIX        00009300
         SER   F0,F0          CLEAR F0                                  00009400
LOOP1    LE    F2,2(R2)       GET ELEMENT OF LEFT MATRIX                00009500
         ME    F2,2(R3)       MULTIPLY BY ELEMENT OF RIGHT MATRIX       00009600
         AER   F0,F2          USING F0 AS ACCUMULATOR,                  00009700
*                             STORE PRODUCT                             00009800
         AR    R3,R4          BUMP RIGHT MATRIX POINTER TO NEXT         00009900
*                             ELEMENT IN COLUMN                         00010000
         LA    R2,2(R2)       BUMP LEFT MATRIX POINTER ALONG ROW        00010100
         BCTB  R6,LOOP1                                                 00010200
         STE   F0,2(R1)       STORE ACCUMULATOR IN RESULT               00010300
         LA    R1,2(R1)       BUMP RESULT PTR TO NEXT ELEMENT           00010400
         SR    R2,R4          RESET LEFT MATRIX PTR TO BEGINNING OR ROW 00010500
         LFXR  R3,F5          RESTORE RIGHT MATRIX PTR TO BEGINNING     00010600
*                             OF COLUMN                                 00010700
         LA    R3,2(R3)       BUMP RIGHT MATRIX PTR TO NEXT COLUMN      00010800
         BCTB  R7,LOOP2                                                 00010900
         AR    R2,R4          BUMP LEFT MATRIX PTR TO NEXT ROW          00011000
         SR    R3,R4          RESET RIGHT MATRIX PTR TO FIRST COLUMN    00011100
         BCTB  R5,LOOP3                                                 00011200
         LFXR  R7,F4          RESTORE RETURN ADDRESS                    00011300
         LH    R6,EXPSAVE     RESTORE EXPONENT                          00011400
         BR    R7             RETURN                                    00011500
         ACLOSE                                                         00011600
