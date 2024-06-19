*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM17D3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM17D3--MATRIX TO A POWER, DP'                          00000100
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
MM17D3   AMAIN                                                          00000700
*                                                                       00000800
* RAISES M TO AN INTEGER POWER WHERE M IS A DOUBLE PRECISION            00000900
*   3 X 3 MATRIX.                                                       00001000
*                                                                       00001100
         INPUT R4,            MATRIX(3,3) DP                           X00001200
               R6,            INTEGER(POWER) SP                        X00001300
               R7             MATRIX(3,3) DP TEMPORARY WORKAREA         00001400
         OUTPUT R2            MATRIX(3,3) DP                            00001500
         WORK  R1,R3,R5,F0,F2,F3,F4,F5                                  00001600
*                                                                       00001700
* ALGORITHM:                                                            00001800
*   RESULT = M M;                                                       00001900
*   IF POWER = 2 THEN                                                   00002000
*     RETURN;                                                           00002100
*   ELSE                                                                00002200
*     DO;                                                               00002300
*       POWER = SHL(POWER,1) + 1;                                       00002400
*       DO WHILE SUBBIT$(1)(POWER) = 0;                                 00002500
*         POWER = SHL(POWER,1);                                         00002600
*       END;                                                            00002700
*       POWER = SHL(POWER,1);                                           00002800
*       DO WHILE TRUE;                                                  00002900
*         IF SUBBIT$(1)(POWER) = ON THEN                                00003000
*           DO;                                                         00003100
*             TEMPORARY = RESULT;                                       00003200
*             RESULT = TEMPORARY M;                                     00003300
*           END;                                                        00003400
*         POWER = SHL(POWER,1);                                         00003500
*         IF POWER = HEX'8000' THEN                                     00003600
*           EXIT;                                                       00003700
*         ELSE                                                          00003800
*           DO;                                                         00003900
*             TEMPORARY = RESULT;                                       00004000
*             RESULT = TEMPORARY TEMPORARY;                             00004100
*           END;                                                        00004200
*       END;                                                            00004300
*     END;                                                              00004400
*                                                                       00004500
         LFXI  R5,3           SET SIZE TO 3                             00004600
         B     MERGE                                                    00004700
MM17DN   AENTRY                                                         00004800
*                                                                       00004900
* RAISES M TO AN INTEGER POWER WHERE M IS A DOUBLE PRECISION            00005000
*   MATRIX OF DIMENSIONS N X N WHERE N IS NOT EQUAL TO 3.               00005100
*                                                                       00005200
         INPUT R4,            MATRIX(N,N) DP                           X00005300
               R5,            INTEGER(N) SP                            X00005400
               R6,            INTEGER(POWER)                           X00005500
               R7             MATRIX(N,N) DP TEMPORARY WORKAREA         00005600
         OUTPUT R2            MATRIX(N,N) DP                            00005700
         WORK  R1,R3,F0,F2,F3,F4,F5                                     00005800
*                                                                       00005900
* ALGORITHM:                                                            00006000
*   SEE ALGORITHM DESCRIPTION ABOVE                                     00006100
*                                                                       00006200
MERGE    LR    R1,R2          PUT RESULT ADDRESS IN R1 FOR              00006300
*                             ADDRESSABILITY PURPOSES                   00006400
         LR    R2,R4                 "           "                      00006500
         LR    R3,R7                 "           "                      00006600
         STH   R5,NSAVE       SAVE N IN NSAVE                           00006700
         LR    R4,R5          LOAD N INTO R4                            00006800
         SLL   R4,2           SET R4 = N * 4                            00006900
         LR    R3,R2          LOAD INPUT ADDRESS INTO R3                00007000
         BAL   R7,MULT        BRANCH TO THE MULTIPLY ROUTINE            00007100
*                             THIS GETS RESULT = M ** 2;                00007200
         CH    R6,=X'0002'                                              00007300
         BE    OUT            IF POWER = 2 THEN RETURN                  00007400
         SLL   R6,1                                                     00007500
         AHI   R6,1           SET R6 TO SHL(POWER,1) + 1                00007600
SHIFTED  TRB   R6,X'8000'     TEST BIT TO BE SHIFTED OFF                00007700
         SLL   R6,1                                                     00007800
         BC    4,SHIFTED      IF HIGH ORDER BIT 0 THEN CONTINUE         00007900
*                             TO SEARCH FOR SIGNIFICANT BIT             00008000
         B     TEST           TAKEN WHEN HIGHER ORDER BIT WAS 1         00008100
COMPLOOP LH    R3,ARG7        PASS TEMPORARY AS RIGHT MULTIPLIER        00008200
         BAL   R7,MOVE                                                  00008300
TEST     TRB   R6,X'8000'     TEST BIT TO BE SHIFTED OFF                00008400
         SLL   R6,1                                                     00008500
         BC    4,NOBIT        IF NO 1 WAS SHIFTED OFF DON'T MULTIPLY    00008600
         LH    R3,ARG4        PASS M AS RIGHT MULTIPLIER                00008700
         BAL   R7,MOVE                                                  00008800
NOBIT    CH    R6,=X'8000'    TEST DONE BIT                             00008900
         BNE   COMPLOOP       IF NOT EQUAL THEN CONTINUE PROCESSING     00009000
OUT      AEXIT                                                          00009100
*                                                                       00009200
* THE NEXT 7 INSTRUCTIONS MOVES RESULT TO TEMPORARY                     00009300
*                                                                       00009400
MOVE     LH    R1,ARG2        PUT ADDRESS OF RESULT IN R1               00009500
         LH    R5,NSAVE       PLACE N INTO R5                           00009600
         MIH   R5,NSAVE       PUT N ** 2 IN R5                          00009700
         LH    R2,ARG7        GET ADDRESS OF TEMPORARY AREA IN R2       00009800
MLOOP    LED   F0,0(R5,R1)    GET ELEMENT OF RESULT                     00009900
         STED  F0,0(R5,R2)    STORE ELEMENT INTO TEMPORARY              00010000
         BCTB  R5,MLOOP                                                 00010100
*                                                                       00010200
* THE FOLLOWING CODE PERFORMS THE MATRIX MULTIPLY OF EITHER             00010300
*   RESULT = TEMPORARY TEMPORARY; OR                                    00010400
*   RESULT = TEMPORARY M;                                               00010500
* THE POINTER IN R3 DETERMINES WHICH CASE IS TO BE PERFORMED.           00010600
*                                                                       00010700
*   R1 POINTS TO RESULT                                                 00010800
*   R2 POINTS TO TEMPORARY                                              00010900
*   R3 POINTS TO EITHER TEMPORARY OR M                                  00011000
*                                                                       00011100
MULT     STH   R6,EXPSAVE     SAVE EXPONENT ON STACK                    00011200
         LFLR  F4,R7          SAVE RETURN IN F4                         00011300
         LH    R5,NSAVE       SET R5 TO N                               00011400
LOOP3    LH    R7,NSAVE       SET R7 TO N                               00011500
LOOP2    LH    R6,NSAVE       SET R6 TO N                               00011600
         LFLR  F5,R3          SAVE PTR TO COLUMN OF RIGHT MATRIX        00011700
         SEDR  F0,F0          CLEAR F0                                  00011800
LOOP1    LE    F2,4(R3)       GET LEFT HALF OF RIGHT MATRIX             00011900
         LE    F3,6(R3)       GET RIGHT HALF OF RIGHT MATRIX            00012000
         MED   F2,4(R2)       MULTIPLY BY ELEMENT OF LEFT MATRIX        00012100
         AEDR  F0,F2          USING F0 AS ACCUMULATOR,                  00012200
*                             STORE PRODUCT                             00012300
         AR    R3,R4          BUMP RIGHT MATRIX POINTER TO NEXT         00012400
*                             ELEMENT IN COLUMN                         00012500
         LA    R2,4(R2)       BUMP LEFT MATRIX POINTER ALONG ROW        00012600
         BCTB  R6,LOOP1                                                 00012700
         STED  F0,4(R1)       STORE ACCUMULATED RESULT IN RESULT        00012800
         LA    R1,4(R1)       BUMP RESULT PTR TO NEXT ELEMENT           00012900
         SR    R2,R4          RESET LEFT MATRIX PTR TO BEGINNING OF ROW 00013000
         LFXR  R3,F5          RESTORE RIGHT MATRIX PTR TO BEGINNING     00013100
*                             OF COLUMN                                 00013200
         LA    R3,4(R3)       BUMP RIGHT MATRIX PTR TO NEXT COLUMN      00013300
         BCTB  R7,LOOP2                                                 00013400
         AR    R2,R4          BUMP LEFT MATRIX PTR TO NEXT ROW          00013500
         SR    R3,R4          RESET RIGHT MATRIX PTR TO FIRST COLUMN    00013600
         BCTB  R5,LOOP3                                                 00013700
         LFXR  R7,F4          RESTORE RETURN ADDRESS                    00013800
         LH    R6,EXPSAVE     RESTORE EXPONENT                          00013900
         BR    R7             RETURN                                    00014000
         ACLOSE                                                         00014100
