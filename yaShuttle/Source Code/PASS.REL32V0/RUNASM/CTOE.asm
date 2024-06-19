*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CTOE.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CTOE--CHARACTER TO SCALAR CONVERSION'                   00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
COUNTE   DS    H              POWER OF 10                               00000400
COUNTH   DS    H              POWER OF 16                               00000500
COUNTB   DS    H              POWER OF 2                                00000600
SWITCH   DS    H              FLAGS                                     00000700
X41ETC   DS    D              TO FLOAT A DECIMAL DIGIT                  00000800
F6SAVE   DS    D                                                        00000900
         MEND                                                           00001000
CTOE     AMAIN QDED=YES                                                 00001100
*                                                                       00001200
* CONVERT A CHARACTER STRING, C1, TO A SINGLE PRECISION SCALAR.         00001300
*                                                                       00001400
         INPUT R2             CHARACTER(C1)                             00001500
         OUTPUT F0            SCALAR SP                                 00001600
         WORK  R1,R3,R4,R5,R6,R7,F1,F2,F3,F4,F6                         00001700
*                                                                       00001800
* ALGORITHM:                                                            00001900
*   GO TO CTOD;                                                         00002000
*                                                                       00002100
         B     START                                                    00002200
CTOD     AENTRY                                                         00002300
*                                                                       00002400
* CONVERT A CHARACTER STRING, C1,  TO A DOUBLE PRECISION SCALAR.        00002500
*                                                                       00002600
         INPUT R2             CHARACTER(C1)                             00002700
         OUTPUT F0            SCALAR DP                                 00002800
         WORK  R1,R3,R4,R5,R6,R7,F1,F2,F3,F4,F6                         00002900
*                                                                       00003000
* ALGORITHM:                                                            00003100
*   CURR_LEN = CURRENT_LENGTH(C1);                                      00003200
*   IF CURR_LEN = 0 THEN                                                00003300
*     DO;                                                               00003400
*       SEND ERROR$(4:20);                                              00003500
*       RETURN 0;                                                       00003600
*     END;                                                              00003700
* LSTRP:                                                                00003800
*   DO WHILE TRUE;                                                      00003900
*     IF C1$(2 AT 1) = '  ' THEN                                        00004000
*       DO;                                                             00004100
*         NAME(C1) = NAME(C1) + 1;                                      00004200
*         CURR_LEN = CURR_LEN - 2;                                      00004300
*         IF CURR_LEN > 0 THEN                                          00004400
*           REPEAT LSTRP;                                               00004500
*         ELSE                                                          00004600
*           DO;                                                         00004700
*             SEND ERROR$(4:20);                                        00004800
*             RETURN 0;                                                 00004900
*           END;                                                        00005000
*       END;                                                            00005100
*     ELSE                                                              00005200
*       EXIT;                                                           00005300
*   END LSTRP;                                                          00005400
*   IF C1$(1) = ' ' THEN                                                00005500
*     DO;                                                               00005600
*       RIGHT_BYTE_SWITCH = ON; /* FOR GTBYTE */                        00005700
*       CURR_LEN = CURR_LEN - 1;                                        00005800
*       IF CURR_LEN = 0 THEN                                            00005900
*         DO;                                                           00006000
*           SEND ERROR$(4:20);                                          00006100
*           RETURN 0;                                                   00006200
*         END;                                                          00006300
*     END;                                                              00006400
* RSTRP:                                                                00006500
*   I = CURR_LEN;                                                       00006600
*   CURR_CHAR = C1$(I);                                                 00006700
*   DO WHILE CURR_CHAR = ' ';                                           00006800
*     I = I - 1;                                                        00006900
*     CURR_LEN = CURR_LEN - 1;                                          00007000
*     CURR_CHAR = C1$(I);                                               00007100
*   END;                                                                00007200
*   DEC_PT_REACHED,F0,F1,X41ETC,COUNTB,COUNTE = 0;                      00007300
*   X41ETC = HEX'4100';                                                 00007400
*   CURR_CHAR = GTBYTE;                                                 00007500
*   IF CURR_CHAR ^= '+' THEN                                            00007600
*     DO;                                                               00007700
*       IF CURR_CHAR ^= '-' THEN                                        00007800
*         EXIT;                                                         00007900
*       ELSE                                                            00008000
*         VALID_SIGN = ON;                                              00008100
*       CURR_CHAR = GTBYTE;                                             00008200
*       CURR_LEN = CURR_LEN - 1;                                        00008300
*       IF CURR_LEN = 0 THEN                                            00008400
*         DO;                                                           00008500
*           SEND ERROR$(4:20);                                          00008600
*           RETURN;                                                     00008700
*         END;                                                          00008800
*     END;                                                              00008900
* NOSIGNS:                                                              00009000
*   DO WHILE CURR_LEN > 0;                                              00009100
*     IF CURR_CHAR < '0' OR CURR_CHAR > '9' THEN                        00009200
*       DO;                                                             00009300
*         IF CURR_CHAR ^= '.' THEN                                      00009400
*           GO TO EXPON;                                                00009500
*         IF DEC_PT_REACHED = ON THEN                                   00009600
*           DO;                                                         00009700
*             SEND ERROR$(4:20);  /* TWO DECIMAL POINTS IN C1 */        00009800
*             RETURN 0;                                                 00009900
*           END;                                                        00010000
*         ELSE                                                          00010100
*           DEC_PT_REACHED = ON;                                        00010200
*       END;                                                            00010300
*     ELSE                                                              00010400
*       IF IGNORE = OFF THEN                                            00010500
*         DO;                                                           00010600
*           TEMP = SLL(INTEGER(SUBBIT$(5 TO 8)(CURR_CHAR),4);           00010700
*           X41ETC = X41ETC + TEMP;                                     00010800
*           F0 = F0 10;                                                 00010900
*           F0 = F0 + X41ETC.                                           00011000
*           IF F0 >= SCALAR(HEX'4E19999A') THEN                         00011100
*             DO;                                                       00011200
*               IF DEC_PT_REACHED = ON THEN                             00011300
*                 IGNORE = ON;                                          00011400
*             END;                                                      00011500
*           VALID_DIGIT = ON;                                           00011600
*           X41ETC = HEX'4100';                                         00011700
*           COUNTE = COUNTE - INTEGER(DEC_PT_REACHED);                  00011800
*         END;                                                          00011900
*     CURR_LEN = CURR_LEN - 1;                                          00012000
*     CURR_CHAR = GTBYTE;                                               00012100
*   END;                                                                00012200
*   IF VALID_DIGIT = OFF THEN                                           00012300
*     DO;                                                               00012400
*       SEND ERROR$(4:20);                                              00012500
*       RETURN 0;                                                       00012600
*     END;                                                              00012700
*   GO TO TIMES10;                                                      00012800
* EXPON:                                                                00012900
* TIMES10:                                                              00013000
*   TEMP = SRA(COUNTE,16);                                              00013100
*   TEMP_SCAL1 = 10;                                                    00013200
*   TEMP_SCAL2 = 1;                                                     00013300
*   IF TEMP ^= 0 THEN                                                   00013400
*     DO;                                                               00013500
*       TEMP1 = ABS(TEMP);                                              00013600
*       DO WHILE TRUE;                                                  00013700
*         IF TEMP1 > 23 THEN                                            00013800
*           DO;                                                         00013900
*             IF TEMP >= 0 THEN                                         00014000
*               F0 = F0 1.E+23;                                         00014100
*             ELSE                                                      00014200
*               F0 = F0 / 1.E+23;                                       00014300
*             TEMP1 = TEMP1 - 23;                                       00014400
*           END;                                                        00014500
*         ELSE                                                          00014600
*           EXIT;                                                       00014700
*       END;                                                            00014800
*       DO WHILE TRUE;                                                  00014900
*         TEMP1 = SRDL(TEMP1,1);                                        00015000
*         IF SUBBIT$(33)(TEMP1) = OFF THEN                              00015100
*           TEMP_SCAL2 = TEMP_SCAL2 TEMP_SCAL1;                         00015200
*         IF TEMP1 = 0 THEN                                             00015300
*           EXIT;                                                       00015400
*         TEMP_SCAL1 = TEMP_SCAL1 TEMP_SCAL1;                           00015500
*       END;                                                            00015600
*     END;                                                              00015700
*   IF TEMP >= 0 THEN                                                   00015800
*     F0 = F0 TEMP_SCAL2;                                               00015900
*   ELSE                                                                00016000
*     F0 = F0 / TEMP_SCAL2;                                             00016100
*   IF VALID_SIGN = ON THEN                                             00016200
*     F0 = -F0;                                                         00016300
*   RETURN F0;                                                          00016400
*                                                                       00016500
START    STED  F6,F6SAVE      SAVE F6                                   00016600
         LH    R6,0(R2)       GET C1 DESCRIPTOR                         00016700
         NHI   R6,X'00FF'     BYTE LENGTH IN R6                         00016800
         BZ    ERROR          ERROR IF ZERO LENGTH                      00016900
*                                                                       00017000
*  STRIP LEADING BLANKS                                                 00017100
*                                                                       00017200
LSTRP    LH    R5,1(R2)       GET FIRST 2 CHARS                         00017300
         CHI   R5,X'2020'     COMPARE WITH '  '                         00017400
         BNE   CK1            IF ^= THEN BRANCH                         00017500
         LA    R2,1(R2)       OTHERWISE BUMP C1 PTR                     00017600
         AHI   R6,-2          DECREMENT LENGTH                          00017700
         BP    LSTRP          GO BACK FOR MORE                          00017800
         B     ERROR                                                    00017900
*                                                                       00018000
CK1      SRL   R5,8           PLACE FIRST CHAR IN LOWER BYTE            00018100
         LA    R5,0(R5,3)     CLEAR BOTTOM HALF OF REGISTER             00018200
         CHI   R5,X'20'       COMPARE WITH ' '                          00018300
         BNE   RSTRP          IF FIRST CHAR NOT EQUAL THEN BRANCH       00018400
         IAL   R2,X'8000'     ELSE SET RIGHT BYTE PTR                   00018500
         BCT   R6,RSTRP       GO TO RSTRP AND DECREMENT CURRLEN         00018600
         B     ERROR          IF CURRLEN WAS 1 THEN ERROR               00018700
*                             I.E., ALL BLANK INPUT                     00018800
*                                                                       00018900
*  STRIP TRAILING BLANKS                                                00019000
*                                                                       00019100
RSTRP    LR    R3,R2          SAVE R2                                   00019200
         SRL   R6,1           DIVIDE CURRLEN BY 2                       00019300
         AR    R2,R6          R2 POINTS TO LAST BYTE+1                  00019400
         A     R2,=X'FFFF8000'  R2 POINTS TO LAST BYTE                  00019500
         SLL   R6,1           RESTORE COUNT                             00019600
RLOOP    ABAL  GTBYTE         NEXT CHARACTER IN TOP HALF R5             00019700
         CHI   R5,X'20'       COMPARE WITH ' '                          00019800
         BNE   CTOE1          IF ^= THEN BRANCH                         00019900
         BCTB  R2,*+1         DECREMENT BYTE POINTER                    00020000
         BCT   R6,RLOOP       DECREMENT LENGTH                          00020100
*                                                                       00020200
*  NOTE THAT LENGTH CANNOT REACH 0 HERE                                 00020300
*                                                                       00020400
CTOE1    LR    R2,R3          RESTORE R3                                00020500
*                                                                       00020600
*  THIS SECTION DOES THE ACTUAL TRANSLATION                             00020700
*  AT ENTRY, R2 IS BYTE POINTER, R6 IS LENGTH.                          00020800
*                                                                       00020900
         XR    R7,R7          CLEAR R7                                  00021000
         LFLR  F2,R7          CLEAR F2                                  00021100
         LFLR  F3,R7          CLEAR F3                                  00021200
         ST    R7,X41ETC      CLEAR HALF OF X41ETC                      00021300
         ST    R7,X41ETC+2    CLEAR OTHER HALF X41ETC                   00021400
         ST    R7,COUNTE      CLEAR COUNTE AND COUNTH                   00021500
         ST    R7,COUNTB      CLEAR COUNTB AND SWITCH                   00021600
         MSTH  X41ETC,X'4100'  SET FIRST BYTE OF X41ETC TO X'41'        00021700
*                                                                       00021800
* END OF SETUP FOR TRANSLATION                                          00021900
*                                                                       00022000
         ABAL  GTBYTE         NEXT CHARACTER IN TOP HALF R5             00022100
         CHI   R5,X'2B'       IF PLUS SIGN, IGNORE                      00022200
         BE    UPPTR          BY UPDATING POINTER                       00022300
         CHI   R5,X'2D'       C'-'                                      00022400
         BNE   NOSIGNS        IF MINUS SIGN, SET                        00022500
         SB    SWITCH,VSIGN   'VSIGN' FLAG                              00022600
*                                                                       00022700
UPPTR    ABAL  GTBYTE         NEXT CHARACTER IN TOP HALF R5             00022800
         BCT   R6,NOSIGNS     IF LENGTH GOES TO 0 HERE,                 00022900
         B     ERROR          THERE ARE NO DIGITS                       00023000
*                                                                       00023100
*  HERE WE GET DIGITS AND ASSEMBLE THEM                                 00023200
*  INTO AN UNSCALED FLOATING POINT NUMBER                               00023300
*                                                                       00023400
NOSIGNS  CHI   R5,X'30'       COMPARE WITH '0'                          00023500
         BL    NOTNUM         IF < THEN NOT NUM                         00023600
         CHI   R5,X'39'       COMPARE WITH '9'                          00023700
         BH    NOTNUM         IF > THEN NOT NUM AS WELL                 00023800
         TB    SWITCH,IGNORE  IF DIGIT NOT SIGNIFICANT,                 00023900
         BO    BCT1           CONTINUE SCANNING                         00024000
*                                                                       00024100
         NHI   R5,X'000F'     GET DIGIT IN BITS                         00024200
         SLL   R5,4           8 TO 11 OF R5, AND                        00024300
         AST   R5,X41ETC      FLOAT IN X41ETC.                          00024400
*                                                                       00024500
         MED   F2,=D'10'                                                00024600
         AED   F2,X41ETC      F2 = 10*F2 + (DIGIT)                      00024700
         CE    F2,=X'4E19999A'   IF F2 IS THIS LARGE,                   00024800
         BL    DIGIT                                                    00024900
         LR    R7,R7          SET "IGNORE" FLAG UNLESS                  00025000
         BZ    DIGIT          DECIMAL POINT NOT REACHED.                00025100
         SB    SWITCH,IGNORE                                            00025200
*                                                                       00025300
DIGIT    SB    SWITCH,VDIGIT                                            00025400
         ZB    X41ETC,X'00FF'  RESET X41ETC TO X'4100'                  00025500
         SST   R7,COUNTE      R7 IS '1' IF DECIMAL PT. HAS BEEN         00025600
*                             ENCOUNTERED, AND 0 OTHERWISE              00025700
*                                                                       00025800
BCT1     ABAL  GTBYTE         NEXT CHARACTER IN TOP HALF R5             00025900
         BCT   R6,NOSIGNS                                               00026000
*                                                                       00026100
         TB    SWITCH,VDIGIT  GIVE ERROR IF                             00026200
         BZ    ERROR          NO DIGITS IN NUMBER                       00026300
         B     TIMES10                                                  00026400
*                                                                       00026500
*  NOTNUM: NOT A DECIMAL DIGIT. VALID ARE '.','E','H','B'.              00026600
*                                                                       00026700
NOTNUM   CHI   R5,X'2E'       C'.'                                      00026800
         BNE   EXPON                                                    00026900
         LR    R7,R7          IF R7 CONTAINS '1', A DECIMAL             00027000
         BP    ERROR          POINT HAS ALREADY BEEN FOUND.             00027100
         LA    R7,1           IF NOT, SET R7 TO '1'                     00027200
         B     BCT1           AND CONTINUE SCANNING                     00027300
*                                                                       00027400
*  CHECK HERE TO SEE IF AN EXPONENT IS INDICATED                        00027500
*                                                                       00027600
EXPON    TB    SWITCH,VDIGIT  GIVE ERROR IF                             00027700
         BZ    ERROR          NO DIGITS IN NUMBER                       00027800
*                                                                       00027900
EXPONE   CHI   R5,X'45'       C'E'                                      00028000
         BNE   EXPONH                                                   00028100
         SR    R7,R7          R7=0 TO INDEX COUNTE                      00028200
         B     EXPONENT                                                 00028300
*                                                                       00028400
EXPONH   CHI   R5,X'48'       C'H'                                      00028500
         BNE   EXPONB                                                   00028600
         LA    R7,1           R7=1 TO INDEX COUNTH                      00028700
         B     EXPONENT                                                 00028800
*                                                                       00028900
EXPONB   CHI   R5,X'42'       C'B'                                      00029000
         BNE   ERROR          INVALID CHARACTER                         00029100
         LA    R7,2           R7=2 TO INDEX COUNTB                      00029200
*                                                                       00029300
*  CONSTRUCT EXPONENT HERE                                              00029400
*                                                                       00029500
EXPONENT BCT   R6,FINDX       GIVE ERROR IF                             00029600
         B     ERROR          NO DIGITS IN EXPONENT                     00029700
*                                                                       00029800
FINDX    SR    R1,R1                                                    00029900
         ABAL  GTBYTE         NEXT CHARACTER IN TOP HALF R5             00030000
         CHI   R5,X'2B'       IF PLUS SIGN, IGNORE                      00030100
         BE    UPPTRE         BY UPDATING POINTER                       00030200
         CHI   R5,X'2D'       C'-'                                      00030300
         BNE   NOSIGNE        IF MINUS SIGN,                            00030400
         SB    SWITCH,ESIGN   SET 'ESIGN' FLAG                          00030500
*                                                                       00030600
UPPTRE   ABAL  GTBYTE         NEXT CHARACTER IN TOP HALF R5             00030700
         BCT   R6,NOSIGNE     GIVE ERROR IF                             00030800
         B     ERROR          NO DIGITS IN EXPONENT                     00030900
*                                                                       00031000
NOSIGNE  CHI   R5,X'30'       C'0'                                      00031100
         BL    ERROR          INVALID CHARACTER                         00031200
         CHI   R5,X'39'       C'9'                                      00031300
         BH    NOTNUME        ERROR OR MORE EXPONENT                    00031400
         SB    SWITCH,EDIGIT                                            00031500
         MIH   R1,=H'10'                                                00031600
         NHI   R5,X'000F'     GET NEXT DECIMAL DIGIT                    00031700
         AR    R1,R5          ACCUMULATE EXPONENT IN R5                 00031800
         ABAL  GTBYTE         NEXT CHARACTER IN TOP HALF R5             00031900
         BCT   R6,NOSIGNE                                               00032000
         SB    SWITCH,FINISHED                                          00032100
*                                                                       00032200
ETEST    TB    SWITCH,ESIGN                                             00032300
         BZ    EOK            COMPLEMENT EXPONENT IF                    00032400
         LACR  R1,R1          'ESIGN' FLAG SET                          00032500
*                                                                       00032600
EOK      AH    R1,COUNTE(R7)  UPDATE APPROPRIATE                        00032700
         STH   R1,COUNTE(R7)  EXPONENT COUNTER                          00032800
         TB    SWITCH,FINISHED                                          00032900
         BO    PWR2                                                     00033000
         ZB    SWITCH,ESIGN+EDIGIT                                      00033100
         B     EXPONE                                                   00033200
*                                                                       00033300
NOTNUME  TB    SWITCH,EDIGIT  CURRENTLY ACCUMULATING EXPONENT?          00033400
         BNZ   ETEST          IF SO,EVALUATE EXPONENT AND KEEP LOOKING  00033500
         B     ERROR          IF NOT, SHOULDN'T BE HERE                 00033600
*                                                                       00033700
*  POWERS OF 2 AND 16                                                   00033800
*                                                                       00033900
PWR2     LFXR  R7,F2          GET NUMBER IN R7 TO FIX CHARACTERISTIC    00034000
         LH    R4,COUNTH      GET EXPONENT IN                           00034100
         SLL   R4,2           BINARY AS                                 00034200
         AH    R4,COUNTB      4*COUNTH+COUNTB                           00034300
         BZ    TIMES10                                                  00034400
         SRDL  R4,18          GET HEX PART IN                           00034500
         SLL   R4,24          CHARACTERISTIC POSITION IN R4             00034600
         SRL   R5,14          BINARY PART IN TOP HALFWORD OF R5         00034700
         AHI   R5,1           INCREMENT FOR BCT                         00034800
         AR    R7,R4          ADD HEX EXPONENT                          00034900
         LFLR  F2,R7                                                    00035000
         B     COUNT                                                    00035100
         AEDR  F2,F2                                                    00035200
COUNT    BCT   R5,*-1                                                   00035300
*                                                                       00035400
*  TIME10: POWERS OF 10                                                 00035500
*                                                                       00035600
TIMES10  LH    R7,COUNTE                                                00035700
         SRA   R7,16          CONVERT TO FULLWORD INTEGER               00035800
         LED   F4,=D'10'                                                00035900
         LED   F6,=D'1'                                                 00036000
         LR    R4,R7                                                    00036100
         BZ    ENDALL                                                   00036200
         BP    POS10                                                    00036300
         LACR  R4,R4                                                    00036400
POS10    C     R4,=F'23'                                                00036500
         BL    TIMES10B                                                 00036600
         LR    R7,R7                                                    00036700
         BM    DIV1                                                     00036800
         MED   F2,=D'1E23'                                              00036900
         B     SUB23                                                    00037000
DIV1     QDED   F2,=D'1E23'                                             00037100
SUB23    S     R4,=F'23'                                                00037200
         B     POS10                                                    00037300
*                                                                       00037400
TIMES10B SRDL  R4,1                                                     00037500
         LR    R5,R5                                                    00037600
         BNM   TEST10                                                   00037700
         MEDR  F6,F4                                                    00037800
TEST10   LR    R4,R4                                                    00037900
         BZ    TIMES10C                                                 00038000
         MEDR  F4,F4                                                    00038100
         B     TIMES10B                                                 00038200
*                                                                       00038300
TIMES10C LR    R7,R7                                                    00038400
         BM    DIV2                                                     00038500
         MEDR  F2,F6                                                    00038600
         B     ENDALL                                                   00038700
DIV2     QDEDR  F2,F6                                                   00038800
*                                                                       00038900
ENDALL   TB    SWITCH,VSIGN                                             00039000
         BZ    EXIT                                                     00039100
         LER   F2,F2          WORKAROUND FOR BUG                        00039200
         BZ    EXIT           IN LECR INSTRUCTION.                      00039300
         LECR  F2,F2                                                    00039400
*                                                                       00039500
EXIT     LED   F6,F6SAVE      RESTORE F6 CONTENTS                       00039600
         LER   F0,F2          PUT RESULT IN DESIRED REGISTER            00039700
         LER   F1,F3                  "        "                        00039800
         AEXIT                AND RETURN                                00039900
*                                                                       00040000
ERROR    AERROR 20            INTERNAL CONVERSION ERROR                 00040100
         SEDR  F2,F2          STANDARD FIXUP RETURNS 0                  00040200
         B     EXIT                                                     00040300
*                                                                       00040400
VSIGN    EQU   X'8000'                                                  00040500
VDIGIT   EQU   X'4000'                                                  00040600
ESIGN    EQU   X'2000'                                                  00040700
EDIGIT   EQU   X'1000'                                                  00040800
IGNORE   EQU   X'0800'                                                  00040900
FINISHED EQU   X'0400'                                                  00041000
         ACLOSE                                                         00041100
