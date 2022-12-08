*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CTRIMV.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CTRIMV--TRIMS LEADING AND TRAILING BLANKS'              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
CTRIMV   AMAIN                                                          00000200
*                                                                       00000300
* TRIM LEADING AND TRAILING BLANKS OFF A CHATACTER STRING, C1.          00000400
*                                                                       00000500
         INPUT R4             CHARACTER(C1)                             00000600
         OUTPUT R2            CHARACTER(VAC)                            00000700
         WORK  R1,R3,R5,R6,R7,F0                                        00000800
*                                                                       00000900
* ALGORITHM:                                                            00001000
*   CURR_LEN = CURRENT_LENGTH(C1);                                      00001100
*   IF CURR_LEN = 0 THEN                                                00001200
*     RETURN;                                                           00001300
*   IF ODD(CURR_LEN) THEN                                               00001400
*     DO;                                                               00001500
*       ODD_FLAG = ON;                                                  00001600
*       J = CURR_LEN - 1;                                               00001700
*     END;                                                              00001800
*   ELSE                                                                00001900
*     J = CURR_LEN;                                                     00002000
*   J = J/2;                                                            00002100
*   END_PTR = NAME(C1) + J;                                             00002200
*   IF ODD_FLAG THEN                                                    00002300
*     DO;                                                               00002400
*       CURR_LEN = CURR_LEN + 1;                                        00002500
*       IF C1$(#) = ' ' THEN                                            00002600
*         DO;                                                           00002700
*           CURR_LEN = CURR_LEN - 1;                                    00002800
*           ODD_FLAG = OFF;                                             00002900
*         END;                                                          00003000
*       ELSE                                                            00003100
*         IF CURR_LEN = 1 THEN                                          00003200
*           GO TO MOVE;                                                 00003300
*     END;                                                              00003400
*   DO WHILE TRUE;                                                      00003500
*     IF NAME(C1) = END_PTR THEN                                        00003600
*       RETURN '';                                                      00003700
*     IF C1$(2 AT 1) ^= '  ' THEN                                       00003800
*       EXIT;                                                           00003900
*     NAME(C1) = NAME(C1) + 1;                                          00004000
*     CURR_LEN = CURR_LEN + 1;                                          00004100
*   END;                                                                00004200
*   IF C1$(1) = ' ' THEN                                                00004300
*     DO;                                                               00004400
*       CURR_LEN = CURR_LEN - 1;                                        00004500
*       RIGHT_BYTE FLAG = ON;  /* FOR GTBYTE AND STBYTE */              00004600
*     END;                                                              00004700
*   IF ^ODD_FLAG THEN                                                   00004800
*     DO;                                                               00004900
*       DO WHILE TRUE;                                                  00005000
*         IF C1$(2 AT END_PTR) ^= '  ' THEN                             00005100
*           EXIT;                                                       00005200
*         CURR_LEN = CURR_LEN - 2;                                      00005300
*         END_PTR = END_PTR - 1;                                        00005400
*       END;                                                            00005500
*       IF C1$(END_PTR + 1) = ' ' THEN                                  00005600
*         CURR_LEN = CURR_LEN - 1;                                      00005700
*     END;                                                              00005800
* MOVE:                                                                 00005900
*   DESCRIPTOR(VAC) = MAXIMUM_LENGTH(VAC) || CURR_LEN;                  00006000
*   DO FOR I = 1 TO  CURR_LEN;                                          00006100
*     VAC$(I) = C1$(I);                                                 00006200
*   END;                                                                00006300
*                                                                       00006400
         LR    R1,R2          PLACE VAC PTR IN R1                       00006500
         LR    R2,R4          PLACE C1 PTR IN R2 FOR ADDRESSABILITY     00006600
         SR    R7,R7          CLEAR R7 FOR USE AS ODD FLAG              00006700
         LH    R5,0(R2)       GET DESCRIPTOR OF C1                      00006800
         NHI   R5,X'00FF'     MASK OFF MAXIMUM LENGTH                   00006900
         BZ    NULL           IF CURRENT_LENGTH(C1) = 0 THEN RETURN     00007000
         TRB   R5,X'0001'     CHECK TO SEE IF CURRENT_LENGTH(C1) IS ODD 00007100
         BZ    SKIP           IF ZERO THEN EVEN, SO SKIP                00007200
         LFXI  R7,1           ELSE SET ODD FLAG                         00007300
         SH    R5,=H'1'       CURRENT_LENGTH(C1) =                      00007400
*                             CURRENT_LENGTH(C1) - 1                    00007500
SKIP     LR    R3,R5          R3 <- CURRENT_LENGTH(C1)                  00007600
         SRL   R3,1           GET LENGTH OF C1 IN HALFWORDS             00007700
         AR    R3,R2          SET R3 TO POINT TO HALFWORD CONTAINING    00007800
*                             LAST CHARS                                00007900
ODD      LR    R7,R7          TEST ODD FLAG                             00008000
         BZ    LOOP           IF ZERO GO TO LOOP                        00008100
*                             ELSE CHECK LAST CHARACTER                 00008200
         AHI   R5,1           GET BACK ORIGINAL CURRENT_LENGTH          00008300
         TB    1(R3),X'DF00'  TEST IF LAST CHAR BLANK                   00008400
         BNZ   TEST           IF ^= 0 THEN NOT BLANK                    00008500
         TB    1(R3),X'2000'  TEST AGAIN                                00008600
         BNZ   NEXT           IF 1 THEN LAST CHAR IS BLANK              00008700
*                                                                       00008800
* IF GET HERE THEN LAST ODD CHAR WAS BLANK                              00008900
*                                                                       00009000
TEST     CH    R5,=H'1'       ELSE COMPARE CURRENT_LENGTH(C1) WITH 1    00009100
         BE    MOVE           IF = THEN MOVE SINGLE CHAR AND DONE       00009200
         B     LOOP           ELSE CHECK FRONT OF C1                    00009300
NEXT     SR    R7,R7          CLEAR ODD FLAG                            00009400
         SH    R5,=H'1'       CURRENT_LENGTH(C1) =                      00009500
*                             CURRENT_LENGTH(C1) - 1                    00009600
*                                                                       00009700
* THIS LOOP CHECKS FRONT END OF C1                                      00009800
*                                                                       00009900
LOOP     CR    R3,R2          COMPARE END_PTR TO C1 PTR                 00010000
         BE    NULL           IF EQUAL THEN STRING IS ALL BLANK         00010100
         CIST  1(R2),X'2020'  ELSE COMPARE WITH '  '                    00010200
         BNE   FBYT1          IF ^= THEN EHECK IF FIRST BYTE IS BLANK   00010300
         LA    R2,1(R2)       ELSE UPDATE C1 PTR                        00010400
         SH    R5,=H'2'       AND UPDATE CURRENT_LENGTH(C2)             00010500
*                             (DECUMULATES AS LENGTH OF RESULT)         00010600
         B     LOOP           GO TO CHECK NEXT HALFWORD AT FRONT        00010700
FBYT1    TB    1(R2),X'DF00'  CHECK IF LEFT BYTE IS BLANK               00010800
         BNZ   BACBYT         IF NOT GO TO CHECK BACK OF STRING         00010900
         TB    1(R2),X'2000'  TEST AGAIN                                00011000
         BZ    BACBYT         IF ZERO THEN NOT BLANK SO CHECK BACK END  00011100
NJUNK    IAL   R2,X'8000'     SET ODD SWITCH FOR GTBYTE AND STBYTE      00011200
         SH    R5,=H'1'       DECUMULATE FOR LENGTH OF RESULT           00011300
BACBYT   LR    R7,R7          TEST ODD FLAG                             00011400
         BNZ   MOVE           IF ^= 0 THEN DONE SO MOVE CHARS           00011500
*                                                                       00011600
* THIS LOOP CHECKS BACK END OF C1                                       00011700
*                                                                       00011800
FBYTC    CIST  0(R3),X'2020'  ELSE COMPARE FROM BACK END                00011900
         BNE   FBYT2          IF ^= '  ' THEN CHECK WITH BYTE IS BACK   00012000
*                             BYTE IS BLANK                             00012100
         SH    R3,=H'1'       ELSE REDUCE BACK END PTR                  00012200
         SH    R5,=H'2'       DECUMULATE FOR LENGTH OF RESULT           00012300
         B     FBYTC          LOOP FOR ANOTHER CHECK                    00012400
FBYT2    LH    R4,0(R3)       GET THE 2 CHARS ^= '  '                   00012500
         TRB   R4,X'00DF'     CHECK IF RIGHT BYTE BLANK                 00012600
         BNZ   J2             IF ^= 0 THEN NOT BLANK                    00012700
         TRB   R4,X'0020'     CHECK AGAIN                               00012800
         BO    N2             IF ONE THEN BLANK                         00012900
J2       LA    R3,0(R3)       ELSE CLEAR RIGHT HALF OF R3 AND           00013000
         B     MOVE           MOVE                                      00013100
N2       LA    R3,0(R3)       CLEAR RIGHT HALF OF R3                    00013200
         SH    R5,=H'1'       DECUMULATE FOR LENGTH OF RESULT           00013300
MOVE     LH    R6,0(R1)       GET VAC DESCRIPTOR                        00013400
         NHI   R6,X'FF00'     CLEAR CURRENT LENGTH FIELD                00013500
         AR    R6,R5          GET MAX_LENGTH || CURRENT_LENGTH(C1)      00013600
         STH   R6,0(R1)       STORE BACK DESCRIPTOR                     00013700
         LR    R6,R5          SET LOOP COUNTER                          00013800
NEXTB    ABAL  GTBYTE                                                   00013900
         ABAL  STBYTE                                                   00014000
         BCTB  R6,NEXTB                                                 00014100
EXIT     AEXIT                                                          00014200
NULL     NIST  0(R1),X'FF00'  SET L TO 0                                00014300
         B     EXIT                                                     00014400
         ACLOSE                                                         00014500
