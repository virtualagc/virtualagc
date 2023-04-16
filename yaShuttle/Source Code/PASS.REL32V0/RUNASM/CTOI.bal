*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CTOI.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CTOI--CHARACTER TO INTEGER AND BIT CONVERSION'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
SWITCH   DS    H                                                        00000400
         MEND                                                           00000500
*                                                                       00000600
CTOI     AMAIN                                                          00000700
*                                                                       00000800
* CONVERT A CHARACTER STRING, C1, TO A DOUBLE PRECISION INTEGER         00000900
*   WHERE C1 CONTAINS DECIMAL CHARACTERS AND '-' AND '+'.               00001000
*                                                                       00001100
         INPUT R2             CHARACTER(C1)                             00001200
         OUTPUT R5            INTEGER DP                                00001300
         WORK  R3,R4,R6,F0                                              00001400
*                                                                       00001500
* ALGORITHM:                                                            00001600
*   GO TO MERGE;                                                        00001700
*                                                                       00001800
         ZH    SWITCH                                                   00001900
         B     MERGE                                                    00002000
*                                                                       00002100
CTOK     AENTRY                                                         00002200
*                                                                       00002300
* CONVERT A CHARACTER STRING, C1, TO A BIT STRING WHERE C1 CONTAINS     00002400
*   DECIMAL CHARACTERS.                                                 00002500
*                                                                       00002600
         INPUT R2             CHARACTER(C1)                             00002700
         OUTPUT R5            BIT(32)                                   00002800
         WORK  R3,R4,R6,F0                                              00002900
*                                                                       00003000
* ALGORITHM:                                                            00003100
*   KTYPE = ON;                                                         00003200
*   GO TO MERGE;                                                        00003300
*                                                                       00003400
         ZH    SWITCH                                                   00003500
         SB    SWITCH,KTYPE                                             00003600
         B     MERGE                                                    00003700
*                                                                       00003800
CTOH     AENTRY                                                         00003900
*                                                                       00004000
* CONVERT A CHARACTER STRING, C1, TO A SINGLE PRECISION INTEGER         00004100
*   WHERE C1 CONTAINS DECIMAL CHARACTERS & '-' & '+'.                   00004200
*                                                                       00004300
         INPUT R2             CHARACTER(C1)                             00004400
         OUTPUT R5            INTEGER SP                                00004500
         WORK  R3,R4,R6,F0                                              00004600
*                                                                       00004700
* ALGORITHM:                                                            00004800
*   HTYPE = ON;                                                         00004900
* MERGE:                                                                00005000
*   TEMP = 0;                                                           00005100
*   CURR_LEN = CURRENT_LENGTH(C1);                                      00005200
*   DO WHILE TRUE;                                                      00005300
*     IF C1$(2 AT 1) = '  ' THEN                                        00005400
*       DO;                                                             00005500
*         NAME(C1) = NAME(C1) + 1;                                      00005600
*         CURR_LEN = CURR_LEN - 2;                                      00005700
*         IF CURR_LEN > 0 THEN                                          00005800
*           REPEAT;                                                     00005900
*         ELSE                                                          00006000
*           DO;                                                         00006100
*             SEND ERROR$(4:22);                                        00006200
*             RETURN 0;                                                 00006300
*           END;                                                        00006400
*       END;                                                            00006500
*     ELSE                                                              00006600
*       EXIT;                                                           00006700
*   END;                                                                00006800
*   CURR_CHAR = GTBYTE;                                                 00006900
*   IF CURR_CHAR = ' ' THEN                                             00007000
*     DO;                                                               00007100
*       CURR_LEN = CURR_LEN - 1;                                        00007200
*       IF CURR_LEN = 0 THEN                                            00007300
*         DO;                                                           00007400
*           SEND ERROR$(4:22);                                          00007500
*           RETURN 0;                                                   00007600
*         END;                                                          00007700
*       CURR_CHAR = GTBYTE;                                             00007800
*     END;                                                              00007900
*   IF CURR_CHAR < '0' THEN                                             00008000
*     DO;                                                               00008100
*       IF KTYPE THEN                                                   00008200
*         DO;                                                           00008300
*           SEND ERROR$(4:22);                                          00008400
*           RETURN 0;                                                   00008500
*         END;                                                          00008600
*       IF CURR_CHAR = '+' THEN                                         00008700
*         ;                                                             00008800
*       ELSE                                                            00008900
*         IF CURR_CHAR = '-' THEN                                       00009000
*           VALID_SIGN = ON;                                            00009100
*         ELSE                                                          00009200
*           DO;                                                         00009300
*             SEND ERROR$(4:22);                                        00009400
*             RETURN 0;                                                 00009500
*           END;                                                        00009600
*     END;                                                              00009700
*   ELSE                                                                00009800
*     DO;                                                               00009900
*       IF CURR_CHAR > 9 THEN                                           00010000
*         DO;                                                           00010100
*           SEND ERROR$(4:22);                                          00010200
*           RETURN 0;                                                   00010300
*         END;                                                          00010400
*       VALID_DIGIT = ON;                                               00010500
*       TEMP = TEMP + DIGIT;                                            00010600
*     END;                                                              00010700
*   CURR_CHAR = GET_CHAR;                                               00010800
*   CURR_LEN = CURR_LEN - 1;                                            00010900
*   DO WHILE CURR_LEN > 0;                                              00011000
*     IF CURR_CHAR < '0' THEN                                           00011100
*       DO;                                                             00011200
*         IF VALID_DIGIT THEN                                           00011300
*           DO;                                                         00011400
*             DO WHILE TRUE;                                            00011500
*               IF CURR_CHAR = ' ' THEN                                 00011600
*                 CURR_LEN = CURR_LEN - 1;                              00011700
*               ELSE                                                    00011800
*                 DO;                                                   00011900
*                   SEND ERROR$(4:22);                                  00012000
*                   RETURN 0;                                           00012100
*                 END;                                                  00012200
*             END;                                                      00012300
*             RETURN TEMP;                                              00012400
*           END;                                                        00012500
*         ELSE                                                          00012600
*           DO;                                                         00012700
*             SEND ERROR$(4:22);                                        00012800
*             RETURN 0;                                                 00012900
*           END;                                                        00013000
*       END;                                                            00013100
*     ELSE                                                              00013200
*       IF CURR_CHAR > '9' THEN                                         00013300
*         DO;                                                           00013400
*           SEND ERROR$(4:22);                                          00013500
*           RETURN 0;                                                   00013600
*         END;                                                          00013700
*       ELSE                                                            00013800
*         DO;                                                           00013900
*           VALID_DIGIT = ON;                                           00014000
*           TEMP = TEMP + DIGIT;                                        00014100
*           CURR_LEN = CURR_LEN - 1;                                    00014200
*         END;                                                          00014300
*   END;                                                                00014400
*   IF HTYPE THEN                                                       00014500
*     TEMP = SLL(TEMP,16);                                              00014600
*  IF VALID_SING THEN                                                   00014700
*     TEMP = - TEMP;                                                    00014800
*  RETURN TEMP;                                                         00014900
*                                                                       00015000
         ZH    SWITCH                                                   00015100
         SB    SWITCH,HTYPE                                             00015200
*                                                                       00015300
MERGE    XR    R6,R6          CLEAR R6 (WILL BE USED AS ACCUMULATOR)    00015400
         LH    R3,0(R2)       GET C1 DESCRIPTOR                         00015500
         NHI   R3,X'00FF'     LENGTH IN BYTES IN R3                     00015600
         LA    R2,0(R2)       MAKE SURE LOW HALF=0                      00015700
*                                                                       00015800
* STRIP LEADING BLANKS                                                  00015900
*                                                                       00016000
LSTRP    LH    R5,1(R2)       GET FIRST 2 CHARS                         00016100
         CHI   R5,X'2020'     COMPARE WITH TWO BLANKS                   00016200
         BNE   CK1            BUMP C1 PTR                               00016300
         LA    R2,1(R2)                                                 00016400
         AHI   R3,X'FFFE'     ADD -2 TO LENGTH                          00016500
         BP    LSTRP          ELSE ERROR                                00016600
         B     ERROR                                                    00016700
*                                                                       00016800
CK1      IAL   R2,X'8000'     SET RIGHT HALF BIT FOR GTBYTE             00016900
         SRL   R5,8           PUT FIRST CHAR IN LOWER BYTE              00017000
         NHI   R5,X'FFFF'     MASK OUT RIGHT HALF OF REG.               00017100
         CHI   R5,X'20'       COMPARE WITH ' '                          00017200
         BNE   SIGN1          IF ^= THEN CHECK WHAT IT COULD BE         00017300
         BCT   R3,SIGN        GO TO CHECK FOR SIGN AND REDUCE           00017400
*                             LENGTH BY ONE                             00017500
         B     ERROR          ELSE ERROR                                00017600
*                                                                       00017700
* CHECK SIGN                                                            00017800
*                                                                       00017900
SIGN     ABAL  GTBYTE         NEXT CHARACTER IN R5                      00018000
SIGN1    CHI   R5,X'30'       C'0'                                      00018100
         BNL   CHK9           IF CHAR >= '0' THEN CHECK AGAINST '9'     00018200
         TB    SWITCH,KTYPE   TEST SWITCH FOR K TYPE                    00018300
         BO    ERROR          IF BIT@DEC THEN INVALID CHARACTER         00018400
         CHI   R5,X'2B'       C'+'                                      00018500
         BE    GETB           GET NEXT CHARACTER IF '+'                 00018600
         CHI   R5,X'2D'       C'-'                                      00018700
         BNE   ERROR          INVALID CHARACTER IF NOT '-'              00018800
         SB    SWITCH,VSIGN   SET MINUS FLAG AND                        00018900
         B     GETB           GET NEXT CHARACTER                        00019000
*                                                                       00019100
*  MAIN CHARACTER TO INTEGER CONVERSION LOOP                            00019200
*                                                                       00019300
NOSIGNS  CHI   R5,X'30'       C'0'                                      00019400
         BL    NOTNUM                                                   00019500
CHK9     CHI   R5,X'39'       C'9'                                      00019600
         BH    ERROR                                                    00019700
         SB    SWITCH,VDIGIT  SET FLAG FOR VALID DIGIT ENCOUNTERED      00019800
         M     R6,F10         MULTIPLY ACCUMULATOR BY CONSTANT          00019900
         SLDL  R6,4                                                     00020000
         NHI   R5,X'000F'     GET LAST PART OF DIGIT                    00020100
         SRL   R5,16          PUT IN LOWER HALF OF REG                  00020200
         AR    R6,R5          PUT RESULT IN WITH ACCUMULATOR            00020300
GETB     ABAL  GTBYTE         GET NEXT CHAR                             00020400
         BCT   R3,NOSIGNS     BRANCH BACK TO TESTING                    00020500
*                                                                       00020600
OUT      TB    SWITCH,HTYPE   SEE IF HALFWORD ENTRY                     00020700
         BZ    STO            IF ZERO THEN CHECK SIGN                   00020800
         SLL   R6,16          ELSE CONVERT TO HALFWORD                  00020900
*                                                                       00021000
STO      TB    SWITCH,VSIGN   TEST FOR VALID SIGN                       00021100
         BZ    STR            IF VSIGN NOT ON THEN DONE                 00021200
         LACR  R6,R6          ELSE COMPLEMENT                           00021300
STR      ST    R6,ARG5                                                  00021400
EXIT     AEXIT                                                          00021500
*                                                                       00021600
NOTNUM   TB    SWITCH,VDIGIT  TEST FOR A VALID DIGIT                    00021700
         BZ    ERROR          IF NOT ON THEN ERROR                      00021800
ENDLOOP  CHI   R5,X'20'       COMPARE WITH ' '                          00021900
         BNE   ERROR          IF ^= THEN ERROR                          00022000
         ABAL  GTBYTE         GET NEXT BYTE                             00022100
         BCT   R3,ENDLOOP     FINISH UP CHARS                           00022200
         B     OUT                                                      00022300
*                                                                       00022400
ERROR    AERROR 22            INTERNAL CONVERSION ERROR                 00022500
         SR    R6,R6                                                    00022600
         B     STR                                                      00022700
*                                                                       00022800
HTYPE    EQU   X'8000'                                                  00022900
VDIGIT   EQU   X'4000'                                                  00023000
VSIGN    EQU   X'2000'                                                  00023100
KTYPE    EQU   X'1000'                                                  00023200
F10      DC    F'0.625'                                                 00023300
         ACLOSE                                                         00023400
