/*
**      XPL IBM/360 EMULATOR DIAGNOSTIC FOR DECIMAL ARITHMETIC
**
**      AUTHOR: DANIEL WEAVER
*/

DECLARE (CC, NCC, VALUE) FIXED,
   MSBIT FIXED INITIAL("80000000");

DECLARE (PLUS_SIGN, MINUS_SIGN) FIXED;
DECLARE (NUM_PLUS, NUM_MINUS, PACKED_PLUS, PACKED_MINUS) CHARACTER;

DECLARE P(512) BIT(8);  /* BUFFER FOR PACKED DATA */

DECLARE (@A, @B, @C) FIXED,
   (DO_NOT_DELETE_THIS, A, B, C)(2) FIXED;

/* TRANSLATION TABLES */
DECLARE (START_EDIT, FINISH_EDIT)(256) BIT(8);
DECLARE HEX_MAP(255) BIT(8);

DECLARE ERROR_COUNT FIXED;
DECLARE LINE CHARACTER;
DECLARE X1 CHARACTER INITIAL(' ');
DECLARE HEX_DIGITS CHARACTER INITIAL('0123456789ABCDEF');
DECLARE ZEROS CHARACTER INITIAL('00000000000000000000000000000000');
DECLARE ZERO_STRING CHARACTER;
DECLARE X70 CHARACTER INITIAL(
   '                                                                      ');

/* CONDITION CODES */
DECLARE CC_EQ LITERALLY '0',
   CC_LT LITERALLY '1',
   CC_GT LITERALLY '2',
   CC_OV LITERALLY '3';

DECLARE
   OP_BALR LITERALLY '"05"',
   OP_LTR  LITERALLY '"12"',
   OP_LCR  LITERALLY '"13"',
   OP_XR   LITERALLY '"17"',
   OP_SR   LITERALLY '"1B"',
   OP_LA   LITERALLY '"41"',
   OP_EX   LITERALLY '"44"',
   OP_BC   LITERALLY '"47"',
   OP_ST   LITERALLY '"50"',
   OP_L    LITERALLY '"58"',
   OP_MVN  LITERALLY '"D1"',
   OP_MVC  LITERALLY '"D2"',
   OP_MVZ  LITERALLY '"D3"',
   OP_ED   LITERALLY '"DE"',
   OP_EDMK LITERALLY '"DF"',
   OP_MVO  LITERALLY '"F1"',
   OP_PACK LITERALLY '"F2"',
   OP_UNPK LITERALLY '"F3"';

/*
   OP_BXLE LITERALLY '"87"',
   OP_BXH  LITERALLY '"86"',
   OP_BCT  LITERALLY '"46"',
   OP_BAL  LITERALLY '"45"',
   OP_LNR  LITERALLY '"11"',
   OP_BCR  LITERALLY '"07"',
   OP_BCTR LITERALLY '"06"',
   OP_LPDR LITERALLY '"20"',
   OP_LNDR LITERALLY '"21"',
   OP_LTDR LITERALLY '"22"',
   OP_LCDR LITERALLY '"23"',
   OP_HDR  LITERALLY '"24"',
   OP_LDR  LITERALLY '"28"',
   OP_CDR  LITERALLY '"29"',
   OP_ADR  LITERALLY '"2A"',
   OP_SDR  LITERALLY '"2B"',
   OP_MDR  LITERALLY '"2C"',
   OP_DDR  LITERALLY '"2D"',
   OP_AWR  LITERALLY '"2E"',
   OP_SWR  LITERALLY '"2F"',
   OP_LPER LITERALLY '"30"',
   OP_LNER LITERALLY '"31"',
   OP_LTER LITERALLY '"32"',
   OP_LCER LITERALLY '"33"',
   OP_HER  LITERALLY '"34"',
   OP_LER  LITERALLY '"38"',
   OP_CER  LITERALLY '"39"',
   OP_AER  LITERALLY '"3A"',
   OP_SER  LITERALLY '"3B"',
   OP_MER  LITERALLY '"3C"',
   OP_DER  LITERALLY '"3D"',
   OP_AUR  LITERALLY '"3E"',
   OP_SUR  LITERALLY '"3F"',
   OP_STD  LITERALLY '"60"',
   OP_LD   LITERALLY '"68"',
   OP_CD   LITERALLY '"69"',
   OP_AD   LITERALLY '"6A"',
   OP_SD   LITERALLY '"6B"',
   OP_MD   LITERALLY '"6C"',
   OP_DD   LITERALLY '"6D"',
   OP_AW   LITERALLY '"6E"',
   OP_SW   LITERALLY '"6F"',
   OP_STE  LITERALLY '"70"',
   OP_LE   LITERALLY '"78"',
   OP_CE   LITERALLY '"79"',
   OP_AE   LITERALLY '"7A"',
   OP_SE   LITERALLY '"7B"',
   OP_ME   LITERALLY '"7C"',
   OP_DE   LITERALLY '"7D"',
   OP_AU   LITERALLY '"7E"',
   OP_SU   LITERALLY '"7F"',
   OP_LPR  LITERALLY '"10"',
   OP_NR   LITERALLY '"14"',
   OP_CLR  LITERALLY '"15"',
   OP_OR   LITERALLY '"16"',
   OP_CR   LITERALLY '"19"',
   OP_AR   LITERALLY '"1A"',
   OP_MR   LITERALLY '"1C"',
   OP_DR   LITERALLY '"1D"',
   OP_ALR  LITERALLY '"1E"',
   OP_SH   LITERALLY '"4B"',
   OP_CH   LITERALLY '"49"',
   OP_AH   LITERALLY '"4A"',
   OP_MH   LITERALLY '"4C"',
   OP_N    LITERALLY '"54"',
   OP_CL   LITERALLY '"55"',
   OP_O    LITERALLY '"56"',
   OP_C    LITERALLY '"59"',
   OP_A    LITERALLY '"5A"',
   OP_S    LITERALLY '"5B"',
   OP_M    LITERALLY '"5C"',
   OP_D    LITERALLY '"5D"',
   OP_AL   LITERALLY '"5E"',
   OP_SL   LITERALLY '"5F"',
   OP_SRL  LITERALLY '"88"',
   OP_SLL  LITERALLY '"89"',
   OP_SRA  LITERALLY '"8A"',
   OP_SLA  LITERALLY '"8B"',
   OP_SRDL LITERALLY '"8C"',
   OP_SLDL LITERALLY '"8D"',
   OP_SRDA LITERALLY '"8E"',
   OP_SLDA LITERALLY '"8F"',
   OP_TM   LITERALLY '"91"',
   OP_NI   LITERALLY '"94"',
   OP_OI   LITERALLY '"96"',
   OP_XI   LITERALLY '"97"',
   OP_CLI  LITERALLY '"95"',
   OP_NC   LITERALLY '"D4"',
   OP_CLC  LITERALLY '"D5"',
   OP_OC   LITERALLY '"D6"',
   OP_XC   LITERALLY '"D7"',
   OP_TRT  LITERALLY '"DD"',
   OP_TR   LITERALLY '"DC"',
   OP_SSK  LITERALLY '"08"',
   OP_ISK  LITERALLY '"09"',
   OP_SVC  LITERALLY '"0A"',
   OP_LR   LITERALLY '"18"',
   OP_SLR  LITERALLY '"1F"',
   OP_STH  LITERALLY '"40"',
   OP_STC  LITERALLY '"42"',
   OP_IC   LITERALLY '"43"',
   OP_LH   LITERALLY '"48"',
   OP_CVD  LITERALLY '"4E"',
   OP_CVB  LITERALLY '"4F"',
   OP_SSM  LITERALLY '"80"',
   OP_LPSW LITERALLY '"82"',
   OP_WRD  LITERALLY '"84"',
   OP_RDD  LITERALLY '"85"',
   OP_STM  LITERALLY '"90"',
   OP_MVI  LITERALLY '"92"',
   OP_TS   LITERALLY '"93"',
   OP_LM   LITERALLY '"98"',
   OP_SIO  LITERALLY '"9C"',
   OP_TIO  LITERALLY '"9D"',
   OP_HIO  LITERALLY '"9E"',
   OP_TCH  LITERALLY '"9F"',
   OP_ZAP  LITERALLY '"F8"',
   OP_CP   LITERALLY '"F9"',
   OP_AP   LITERALLY '"FA"',
   OP_SP   LITERALLY '"FB"',
   OP_MP   LITERALLY '"FC"',
   OP_DP   LITERALLY '"FD"';
*/

PAD:
PROCEDURE(STRING, WIDTH) CHARACTER;
   DECLARE STRING CHARACTER, (WIDTH, L) FIXED;

   L = WIDTH - LENGTH(STRING);
   DO WHILE L >= LENGTH(X70);
      STRING = STRING || X70;
      L = L - LENGTH(X70);
   END;
   IF L <= 0 THEN RETURN STRING;
   RETURN STRING || SUBSTR(X70, 0, L);
END PAD;

HEX: PROCEDURE(V, L) CHARACTER;
   DECLARE (V, L) FIXED;
   DECLARE S CHARACTER;

   S = '';
   L = L - 4;
   DO WHILE L >= 0;
      S = S || SUBSTR(HEX_DIGITS, SHR(V, L) & 15, 1);
      L = L - 4;
   END;
   RETURN S;
END HEX;

FAIL_HEADER:
   PROCEDURE(MNEMONIC);
      DECLARE (MNEMONIC, TEXT_CODE) CHARACTER;

      LINE = '*** ' || MNEMONIC;
      LINE = LINE || SUBSTR('         FAIL ', LENGTH(LINE));
   END FAIL_HEADER;

FAIL_TEXT_HEADER:
   PROCEDURE(MNEMONIC, A, TEXT_CODE, B, W);
      DECLARE (A, B, W) FIXED;
      DECLARE (MNEMONIC, TEXT_CODE) CHARACTER;

      LINE = '*** ' || MNEMONIC;
      LINE = LINE || SUBSTR('         FAIL ', LENGTH(LINE)) || HEX(A, W)
         || TEXT_CODE || HEX(B, W);
   END FAIL_TEXT_HEADER;

FAIL_RESULT:
   PROCEDURE(TAG, EXPECTED, GOT, LEN);
      DECLARE (EXPECTED, GOT, LEN, L) FIXED;
      DECLARE TAG CHARACTER;

      LINE = LINE || TAG || HEX(EXPECTED, LEN);
      L = SHR(LEN, 2) + 6;
      IF EXPECTED = GOT THEN LINE = LINE || SUBSTR(X70, 0, L);
      ELSE LINE = LINE || ' GOT: ' || HEX(GOT, LEN);
   END FAIL_RESULT;

FAIL_CONDITION:
   PROCEDURE(EXPECTED, GOT);
      DECLARE (EXPECTED, GOT) FIXED;

      IF EXPECTED = GOT THEN LINE = LINE || ' CC=' || EXPECTED;
      ELSE LINE = LINE || ' CC=' || EXPECTED || ' GOT: CC=' || GOT;
      OUTPUT = LINE;
      ERROR_COUNT = ERROR_COUNT + 1;
   END FAIL_CONDITION;

FAIL_PRINT: PROCEDURE;
   OUTPUT = LINE;
   ERROR_COUNT = ERROR_COUNT + 1;
END FAIL_PRINT;

CONDITION_CODES:
PROCEDURE FIXED;
   /* THIS SUBROUTINE WILL READ THE CONDITION CODES. */
   DECLARE RESULT_CC FIXED;

   CALL INLINE(OP_LA, 2, 0, 0, 0);    /* CLEAR REGISTER 2 */
   CALL INLINE(OP_BALR, 1, 0);        /* GET CURRENT PROGRAM COUNTER */
   CALL INLINE(OP_BC, 8, 0, 1, 24);   /* BRANCH IF EQ BIT SET */
   CALL INLINE(OP_LA, 2, 0, 2, 1);    /* ADD 1 */
   CALL INLINE(OP_BC, 4, 0, 1, 24);   /* BRANCH IF LT BIT SET */
   CALL INLINE(OP_LA, 2, 0, 2, 1);    /* ADD 1 */
   CALL INLINE(OP_BC, 2, 0, 1, 24);   /* BRANCH IF GT BIT SET */
   CALL INLINE(OP_LA, 2, 0, 2, 1);    /* ADD 1 */
   CALL INLINE(OP_ST, 2, 0, RESULT_CC);  /* STORE THE CONDITION CODES */
   RETURN RESULT_CC;
END CONDITION_CODES;

SET_CONDITION_CODES:
PROCEDURE(NCC);
   DECLARE NCC FIXED;

   DO CASE NCC;
      /* CC=0 EQ */
      DO;
         CALL INLINE(OP_XR, 1, 1);  /* SET CC=EQ */
      END;
      /* CC=1 LT */
      DO;
         CALL INLINE(OP_L, 1, 0, MSBIT);
         CALL INLINE(OP_LTR, 1, 1);  /* SET CC=LT */
      END;
      /* CC=2 GT */
      DO;
         CALL INLINE(OP_LA, 1, 0, 0, 1);    /* LOAD 1 */
         CALL INLINE(OP_LTR, 1, 1);   /* SET CC=GT */
      END;
      /* CC=3 OV */
      DO;
         CALL INLINE(OP_L, 1, 0, MSBIT);
         CALL INLINE(OP_LCR, 1, 1);  /* SET CC=OV */
      END;
   END;
END SET_CONDITION_CODES;

ZAP_CONDITION_CODES:
   PROCEDURE(CODE);
      /* SET THE CONDITION CODES TO ANYTHING BUT THE EXPECTED CODE */
      DECLARE CODE FIXED;

      IF CODE = 0 THEN DO;
            CALL INLINE(OP_LA, 1, 0, 0, 1);  /* LOAD 1 */
            CALL INLINE(OP_LTR, 1, 1);   /* SET CC=GT */
            RETURN;
         END;
      CALL INLINE(OP_SR, 1, 1);  /* SET THE CONDITION CODES TO EQ */
      RETURN;
   END ZAP_CONDITION_CODES;

HEX_WRITE:
   PROCEDURE(S);
      /* STORE THE HEXADECIMAL STRING OF CHARACTERS INTO THE P ARRAY
         STARTING AT 0 */
      DECLARE (I, J) FIXED, S CHARACTER;

      IF (LENGTH(S) & 1) = 1 THEN S = '0' || S;
      DO I = 0 TO LENGTH(S) - 2 BY 2;
         J = SHL(HEX_MAP(BYTE(S, I)), 4);
         J = J + HEX_MAP(BYTE(S, I + 1));
         P(SHR(I, 1)) = J;
      END;
   END HEX_WRITE;

HEX_READ:
   PROCEDURE(INDEX, LEN) CHARACTER;
      /* CONVERT THE DATA IN THE P ARRAY STARTING AT INDEX TO A HEX STRING */
      DECLARE (I, J, INDEX, LEN) FIXED;
      DECLARE S CHARACTER;

      S = '';
      DO I = 0 TO LEN;
         J = P(INDEX + I);
         S = S || SUBSTR(HEX_DIGITS, SHR(J, 4) & 15, 1) ||
            SUBSTR(HEX_DIGITS, J & 15, 1);
      END;
      RETURN S;
   END HEX_READ;

INITIALIZATION:
   PROCEDURE;
      DECLARE (I, J) FIXED;

      DO I = 0 TO 255;
         START_EDIT(I), FINISH_EDIT(I) = I;
         HEX_MAP(I) = 0;
      END;
      START_EDIT(BYTE('0')) = "22";
      START_EDIT(BYTE('1')) = "21";
      START_EDIT(BYTE('9')) = "20";
      START_EDIT("20") = 0;
      START_EDIT("21") = 0;
      START_EDIT("22") = 0;
      @A = ADDR(A) & "00FFFFF8";
      @B = ADDR(B) & "00FFFFF8";
      @C = ADDR(C) & "00FFFFF8";
      DO I = BYTE('0') TO BYTE('9');
         HEX_MAP(I) = I - BYTE('0');
      END;
      DO I = 0 TO 5;
         HEX_MAP(I + BYTE('a')), HEX_MAP(I + BYTE('A')) = I + 10;
      END;

      IF BYTE('0') = "F0" THEN PLUS_SIGN = "C0";
      ELSE PLUS_SIGN = "A0";
      MINUS_SIGN = PLUS_SIGN + "10";

      DO I = 0 TO 8;
         J = BYTE(HEX_DIGITS, I + 1);
         P(I), P(I + 9) = J;
      END;
      P(15) = PLUS_SIGN + 7;
      NUM_PLUS = HEX_READ(0, 15);
      P(15) = MINUS_SIGN + 7;
      NUM_MINUS = HEX_READ(0, 15);
      OUTPUT = 'NUM_PLUS:     ' || NUM_PLUS;
      OUTPUT = 'NUM_MINUS:    ' || NUM_MINUS;

      J = 4;
      PACKED_PLUS = '';
      DO I = 0 TO 31;
         PACKED_PLUS = PACKED_PLUS || SUBSTR(HEX_DIGITS, J, 1);
         J = J + 1;
         IF J >= 10 THEN J = 1;
      END;
      J = BYTE(HEX_DIGITS, SHR(PLUS_SIGN, 4));
      BYTE(PACKED_PLUS, 30) = BYTE('7');
      BYTE(PACKED_PLUS, 31) = J;
      PACKED_MINUS = SUBSTR('X' || PACKED_PLUS, 1);
      J = BYTE(HEX_DIGITS, SHR(MINUS_SIGN, 4));
      BYTE(PACKED_MINUS, 31) = J;
      OUTPUT = 'PACKED PLUS:  ' || PACKED_PLUS;
      OUTPUT = 'PACKED MINUS: ' || PACKED_MINUS;

      ZERO_STRING = '';
      DO I = 0 TO 15;
         ZERO_STRING = ZERO_STRING || HEX(BYTE('0'), 8);
      END;
      OUTPUT = 'ZERO STRING:  ' || ZERO_STRING;
   END INITIALIZATION;

/*
**  PACK(STRING, INDEX)
**
**  GIVEN A STRING, PACK IT INTO A PACKED DECIMAL FIELD.
**  THE SIGN IS + OR -
**
**  RETURN TRUE IF ERROR.
*/
PACK:
   PROCEDURE(S, INDEX) FIXED;
      DECLARE S CHARACTER,
         (I, K, CHR, VALUE, INDEX) FIXED;

      VALUE = 0;
      K = LENGTH(S) & 1;
      DO I = 0 TO LENGTH(S) - 1;
         CHR = BYTE(S, I);
         IF CHR >= BYTE('0') & CHR <= BYTE('9') THEN
            DO;
               CHR = CHR - BYTE('0');
               IF (K & 1) = 1 THEN P(SHR(K, 1) + INDEX) = VALUE + CHR;
               ELSE VALUE = SHL(CHR, 4);
            END;
         ELSE
         IF CHR = BYTE('+') THEN
            DO;
               IF (K & 1) = 1 THEN P(SHR(K, 1) + INDEX) = VALUE + 12;
               ELSE DO;
                     OUTPUT = 'SIGN IN LEFT POSITION: ' || S;
                     ERROR_COUNT = ERROR_COUNT + 1;
                     RETURN 1;
                  END;
               VALUE = 0;
            END;
         ELSE
         IF CHR = BYTE('-') THEN
            DO;
               IF (K & 1) = 1 THEN P(SHR(K, 1) + INDEX) = VALUE + 13;
               ELSE DO;
                     OUTPUT = 'SIGN IN LEFT POSITION: ' || S;
                     ERROR_COUNT = ERROR_COUNT + 1;
                     RETURN 1;
                  END;
               VALUE = 0;
            END;
         ELSE DO;
               OUTPUT = 'ILLEGAL PACKED DECIMAL: ' ||
                  SUBSTR(S, SHR(I, 1), 1);
               ERROR_COUNT = ERROR_COUNT + 1;
               RETURN 1;
            END;
         K = K + 1;
      END;
      P(SHR(K, 1) + INDEX) = VALUE;
      RETURN 0;
   END PACK;

/*
**  THE ED AND EDMK INSTRUCTIONS ARE SERIOUSLY BRAIN DAMAGED.
**  THEY ARE DIFFICULT TO USE IN EBCDIC AND NEARLY IMPOSSIBLE TO USE IN ASCII.
**
**  THIS FUNCTION REASSIGNS THE CONTROL CHARACTERS ON THE WAY IN AND
**  REMAPS THE SPACE CHARACTER ON THE WAY OUT.
**  '1' -> "21"  Significance start
**  '0' -> "22"  Field separator
**  '9' -> "20"  Digit selector
**
**  ON OUTPUT THE NULL BYTE IS TRANSLATED TO SPACE
*/
EXEC_EDIT:
   PROCEDURE(OP, PACKED, PAT, EXPECTED, REG1, CC);
      DECLARE (PACKED, PAT, EXPECTED, RESULT, MNEMONIC) CHARACTER,
         (I, LEN, CC, OP, VALUE, REG1) FIXED;
      DECLARE OPCODE(3) BIT(16) INITIAL(0, "2000", "3000");
      DECLARE TAB(255) BIT(8);

      IF PACK(PACKED) = 1 THEN RETURN;

      TAB(0) = 0;
      LEN = LENGTH(PAT) - 1;
      DO I = 1 TO LEN;
         TAB(I) = START_EDIT(BYTE(PAT, I));
      END;

      OPCODE(0) = SHL(OP, 8) + LEN;

      CALL ZAP_CONDITION_CODES(CC);
      /* CLEAR REGISTER ONE WITHOUT CHANGING THE CONDITION CODES */
      CALL INLINE(OP_LA, 1, 0, 0, 0);
      CALL INLINE(OP_LA, 2, 0, TAB);
      CALL INLINE(OP_LA, 3, 0, P);
      CALL INLINE(OP_EX, 0, 0, OPCODE);
      CALL INLINE(OP_ST, 1, 0, VALUE);
      NCC = CONDITION_CODES;

      DO I = 0 TO LEN;
         IF TAB(I) = 0 THEN TAB(I) = BYTE(PAT);
      END;

      IF REG1 > 0 THEN REG1 = ADDR(TAB) + REG1;
      RESULT = SUBSTR('', ADDR(TAB), LEN + 1);
      IF CC = NCC THEN
         IF REG1 = VALUE THEN
            IF RESULT = EXPECTED THEN RETURN;

      IF OP = OP_ED THEN MNEMONIC = 'ED';
      ELSE MNEMONIC = 'EDMK';
      CALL FAIL_HEADER(MNEMONIC);
      LINE = PAD(LINE || PACKED, 32);
      CALL FAIL_RESULT('R1 = ', REG1, VALUE);
      CALL FAIL_CONDITION(CC, NCC);
      OUTPUT = '*** PATTERN: ' || PAT;
      OUTPUT = '*** EXPECT:  ' || EXPECTED;
      OUTPUT = '*** RECEIVED:' || RESULT;
   END EXEC_EDIT;

TEST_EDIT:
   PROCEDURE;
      OUTPUT = 'TESTING EDMK';
      CALL EXEC_EDIT(OP_EDMK, '01234567654+0000', ' 999,999,991.99 CR',
         '  12,345,676.54   ', 2, CC_GT);
      CALL EXEC_EDIT(OP_EDMK, '01234567654-0000', ' 999,999,991.99 CR',
         '  12,345,676.54 CR', 2, CC_LT);
      CALL EXEC_EDIT(OP_EDMK, '1234567654-', ' 999,999,991.99 CR',
         '  12,345,676.54 CR', 2, CC_LT);
      CALL EXEC_EDIT(OP_EDMK, '123456789-', ' 999,999,991.99 CR',
         ' 123,456,789.00 CR', 1, CC_LT);
      CALL EXEC_EDIT(OP_EDMK, '00000-', ' 991.99 CR', '    .00 CR', 0, CC_EQ);
      CALL EXEC_EDIT(OP_EDMK, '10000+', ' 991.99 CR', ' 100.00   ', 1, CC_GT);
      CALL EXEC_EDIT(OP_EDMK, '00000+', ' 99991', '      ', 0, CC_EQ);
      CALL EXEC_EDIT(OP_EDMK, '00000+', ' 99919', '     0', 0, CC_EQ);
      CALL EXEC_EDIT(OP_EDMK, '00001+', ' 99919', '     1', 0, CC_GT);
      CALL EXEC_EDIT(OP_EDMK, '00000+', '*99919', '*****0', 0, CC_EQ);
      CALL EXEC_EDIT(OP_EDMK, '123-456+', ' 999-0999-', ' 123- 456 ', 6, CC_GT);

      OUTPUT = 'TESTING ED';
      CALL EXEC_EDIT(OP_ED, '01234567654+0000', ' 999,999,991.99 CR',
         '  12,345,676.54   ', 0, CC_GT);
      CALL EXEC_EDIT(OP_ED, '01234567654-0000', ' 999,999,991.99 CR',
         '  12,345,676.54 CR', 0, CC_LT);
      CALL EXEC_EDIT(OP_ED, '1234567654-', ' 999,999,991.99 CR',
         '  12,345,676.54 CR', 0, CC_LT);
      CALL EXEC_EDIT(OP_ED, '123456789-', ' 999,999,991.99 CR',
         ' 123,456,789.00 CR', 0, CC_LT);
      CALL EXEC_EDIT(OP_ED, '00000-', ' 991.99 CR', '    .00 CR', 0, CC_EQ);
      CALL EXEC_EDIT(OP_ED, '10000+', ' 991.99 CR', ' 100.00   ', 0, CC_GT);
   END TEST_EDIT;

EXEC_PACK:
   PROCEDURE(D, EXPECTED, L1, L2);
      DECLARE (D, EXPECTED, RESULT) CHARACTER;
      DECLARE (J, L1, L2, GUARD) FIXED;
      DECLARE OPCODE(3) BIT(16) INITIAL(0, "1080", "1000");

      CALL HEX_WRITE(D);
      OPCODE(0) = SHL(OP_PACK, 8) + SHL(L1, 4) + L2;
      DO J = 127 TO 145;
         P(J) = 255;
      END;
      CC = CC + 1;
      IF CC > 3 THEN CC = 0;
      CALL SET_CONDITION_CODES(CC);
      CALL INLINE(OP_LA, 1, 0, P);
      CALL INLINE(OP_EX, 0, 0, OPCODE);
      NCC = CONDITION_CODES;

      RESULT = HEX_READ(128, L1);
      IF CC = NCC THEN
         IF P(127) = 255 THEN
            IF EXPECTED = RESULT THEN RETURN;

      CALL FAIL_HEADER('PACK');
      LINE = LINE || D;
      CALL FAIL_RESULT(' GUARD=', 255, P(127), 8);
      CALL FAIL_CONDITION(CC, NCC);
      OUTPUT = '*** EXPECT:   ' || EXPECTED;
      OUTPUT = '*** RECEIVED: ' || RESULT;
   END EXEC_PACK;

TEST_PACK:
   PROCEDURE;
      DECLARE (I, J) FIXED;
      DECLARE (S, R, T) CHARACTER;

      OUTPUT = 'TESTING PACK';
      J = LENGTH(NUM_PLUS) - 2;
      DO I = 0 TO 15;
         S = SUBSTR(NUM_PLUS, J);
         IF I > 12 THEN DO;
               R = SUBSTR(PACKED_PLUS, 18);
            END;
         ELSE DO;
               R = SUBSTR(PACKED_PLUS, 30 - I);
               IF LENGTH(R) < 14 THEN
                  R = SUBSTR(ZEROS, 0, 14 - LENGTH(R)) || R;
            END;
         CALL EXEC_PACK(S, R, 6, I);
         J = J - 2;
      END;
      T = SUBSTR(ZEROS, 0, 24) || SUBSTR(PACKED_PLUS, 24);
      S = SUBSTR(NUM_PLUS, 19);
      J = 30;
      DO I = 0 TO 15;
         R = SUBSTR(T, J);
         CALL EXEC_PACK(S, R, I, 6);
         J = J - 2;
      END;
      J = LENGTH(NUM_PLUS) - 2;
      DO I = 0 TO 15;
         S = SUBSTR(NUM_PLUS, J);
         R = SUBSTR(PACKED_PLUS, 30 - I);
         IF (LENGTH(R) & 1) = 1 THEN R = '0' || R;
         CALL EXEC_PACK(S, R, SHR(I + 1, 1), I);
         J = J - 2;
      END;
   END TEST_PACK;

EXEC_UNPK:
   PROCEDURE(D, EXPECTED, L1, L2);
      DECLARE (D, EXPECTED, RESULT) CHARACTER;
      DECLARE (J, L1, L2, GUARD) FIXED;
      DECLARE OPCODE(3) BIT(16) INITIAL(0, "1080", "1000");

      CALL HEX_WRITE(D);
      OPCODE(0) = SHL(OP_UNPK, 8) + SHL(L1, 4) + L2;
      DO J = 127 TO 145;
         P(J) = 255;
      END;
      CC = CC + 1;
      IF CC > 3 THEN CC = 0;
      CALL SET_CONDITION_CODES(CC);
      CALL INLINE(OP_LA, 1, 0, P);
      CALL INLINE(OP_EX, 0, 0, OPCODE);
      NCC = CONDITION_CODES;

      RESULT = HEX_READ(128, L1);
      IF CC = NCC THEN
         IF P(127) = 255 THEN
            IF EXPECTED = RESULT THEN RETURN;

      CALL FAIL_HEADER('UNPK');
      LINE = LINE || D;
      CALL FAIL_RESULT(' GUARD=', 255, P(127), 8);
      CALL FAIL_CONDITION(CC, NCC);
      OUTPUT = '*** EXPECT:   ' || EXPECTED;
      OUTPUT = '*** RECEIVED: ' || RESULT;
   END EXEC_UNPK;

TEST_UNPK:
   PROCEDURE;
      DECLARE (I, J) FIXED;
      DECLARE (S, R, T) CHARACTER;

      OUTPUT = 'TESTING UNPK';
      T = SUBSTR(ZERO_STRING, 0, 6) || SUBSTR(NUM_PLUS, 6);
      J = LENGTH(NUM_PLUS) - 2;
      DO I = 0 TO 15;
         S = SUBSTR(T, J);
         R = SUBSTR(PACKED_PLUS, 18);
         CALL EXEC_UNPK(R, S, I, 6);
         J = J - 2;
      END;
      DO I = 0 TO 15;
         IF I > 5 THEN DO;
               S = SUBSTR(NUM_PLUS, 18);
            END;
         ELSE DO;
               S = SUBSTR(NUM_PLUS, 30 - I - I);
               IF LENGTH(S) < 14 THEN
                  S = SUBSTR(ZERO_STRING, 0, 14 - LENGTH(S)) || S;
            END;
         R = SUBSTR(PACKED_PLUS, 30 - I);
         CALL EXEC_UNPK(R, S, 6, SHR(I + 1, 1));
      END;
      J = LENGTH(NUM_MINUS) - 2;
      DO I = 0 TO 15;
         S = SUBSTR(NUM_MINUS, J);
         R = SUBSTR(PACKED_MINUS, 30 - I);
         CALL EXEC_UNPK(R, S, I, SHR(I + 1, 1));
         J = J - 2;
      END;
   END TEST_UNPK;

EXEC_MVO:
   PROCEDURE(SIGN, S, EXPECTED, L1, L2);
      DECLARE (S, EXPECTED, RESULT) CHARACTER;
      DECLARE (SIGN, J, L1, L2, GUARD) FIXED;
      DECLARE OPCODE(3) BIT(16) INITIAL(0, "1080", "1000");

      CALL HEX_WRITE(S);
      OPCODE(0) = SHL(OP_MVO, 8) + SHL(L1, 4) + L2;
      DO J = 127 TO 145;
         P(J) = 255;
      END;
      P(128 + L1) = SHR(SIGN, 4) + "F0";
      CC = CC + 1;
      IF CC > 3 THEN CC = 0;
      CALL SET_CONDITION_CODES(CC);
      CALL INLINE(OP_LA, 1, 0, P);
      CALL INLINE(OP_EX, 0, 0, OPCODE);
      NCC = CONDITION_CODES;

      RESULT = HEX_READ(128, L1);
      IF CC = NCC THEN
         IF P(127) = 255 THEN
            IF EXPECTED = RESULT THEN RETURN;

      CALL FAIL_HEADER('MVO');
      LINE = LINE || S || ' SIGN=' || SUBSTR(HEX_DIGITS, SHR(SIGN, 4), 1);
      CALL FAIL_RESULT(' GUARD=', 255, P(127), 8);
      CALL FAIL_CONDITION(CC, NCC);
      OUTPUT = '*** EXPECT:   ' || EXPECTED;
      OUTPUT = '*** RECEIVED: ' || RESULT;
   END EXEC_MVO;

TEST_MVO:
   PROCEDURE;
      DECLARE (I, J) FIXED;
      DECLARE (S, R, T, PP, PM) CHARACTER;

      OUTPUT = 'TESTING MVO';
      PP = '23' || SUBSTR(PACKED_PLUS, 0, LENGTH(PACKED_PLUS) - 2);
      PM = '23' || SUBSTR(PACKED_MINUS, 0, LENGTH(PACKED_MINUS) - 2);
      T = SUBSTR(PACKED_MINUS, LENGTH(PACKED_MINUS) - 1, 1);
      S = SUBSTR(PP, 0, 16);
      DO I = 0 TO 15;
         IF I < 8 THEN R = SUBSTR(S, 16 - SHL(I, 1) - 1) || T;
         ELSE R = SUBSTR(ZEROS, 0, SHL(I, 1) - 15) || S || T;
         CALL EXEC_MVO(MINUS_SIGN, S, R, I, 7);
      END;
      T = SUBSTR(PACKED_PLUS, LENGTH(PACKED_PLUS) - 1, 1);
      J = LENGTH(PP) - 2;
      DO I = 0 TO 15;
         S = SUBSTR(PP, J, SHL(I, 1) + 2);
         R = S || T;
         IF LENGTH(R) < 16 THEN R = SUBSTR(ZEROS, 0, 16 - LENGTH(R)) || R;
         ELSE R = SUBSTR(R, LENGTH(R) - 16);
         CALL EXEC_MVO(PLUS_SIGN, S, R, 7, I);
         J = J - 2;
      END;
      T = SUBSTR(PACKED_MINUS, LENGTH(PACKED_MINUS) - 1, 1);
      J = LENGTH(PP) - 2;
      DO I = 0 TO 15;
         S = SUBSTR(PP, J, SHL(I, 1) + 2);
         R = SUBSTR(S, 1, LENGTH(S) - 1) || T;
         CALL EXEC_MVO(MINUS_SIGN, S, R, I, I);
         J = J - 2;
      END;
   END TEST_MVO;

TEST_MOVE:
   PROCEDURE;
      /* TEST OVERLAPPING DATA COPY */
      DECLARE (I, J) FIXED;

      OUTPUT = 'TESTING MVC';
      DO I = 0 TO 258;
         P(I) = 255;
      END;
      P(1) = 0;

      /*
      ** MVC - MOVE CHARACTER (SS)
      */
      CALL INLINE(OP_LA, 1, 0, P);
      CALL INLINE(OP_MVC, 15, 15, 1, 2, 1, 1);         /* SS */

      DO I = 1 TO 257;
         IF P(I) ~= 0 THEN DO;
             CALL FAIL_TEXT_HEADER('MVC', 0, '->', I - 1, 12);
             CALL FAIL_RESULT(X1, 0, P(I), 8);
             CALL FAIL_PRINT;
         END;
      END;
      IF P(0) ~= 255 THEN DO;
          CALL FAIL_TEXT_HEADER('MVC', 0, '->', -1, 32);
          CALL FAIL_RESULT(X1, 255, P(0), 8);
          CALL FAIL_PRINT;
      END;
      IF P(258) ~= 255 THEN DO;
          CALL FAIL_TEXT_HEADER('MVC', 0, '->', 257, 32);
          CALL FAIL_RESULT(X1, 255, P(258), 8);
          CALL FAIL_PRINT;
      END;

      OUTPUT = 'TESTING MVN';
      DO I = 0 TO 258;
         P(I) = I;
      END;
      P(0) = 255;
      P(258) = 255;

      /*
      ** MVN - MOVE NUMERICS (SS)
      */
      CALL INLINE(OP_LA, 1, 0, P);
      CALL INLINE(OP_MVN, 15, 15, 1, 2, 1, 1);         /* SS */

      DO I = 1 TO 257;
         J = (I & "F0") + 1;
         IF P(I) ~= J THEN DO;
             CALL FAIL_TEXT_HEADER('MVN', 0, '->', I - 1, 12);
             CALL FAIL_RESULT(X1, J, P(I), 8);
             CALL FAIL_PRINT;
         END;
      END;
      IF P(0) ~= 255 THEN DO;
          CALL FAIL_TEXT_HEADER('MVN', 0, '->', -1, 32);
          CALL FAIL_RESULT(X1, 255, P(0), 8);
          CALL FAIL_PRINT;
      END;
      IF P(258) ~= 255 THEN DO;
          CALL FAIL_TEXT_HEADER('MVN', 0, '->', 257, 32);
          CALL FAIL_RESULT(X1, 255, P(258), 8);
          CALL FAIL_PRINT;
      END;

      OUTPUT = 'TESTING MVZ';
      DO I = 0 TO 258;
         P(I) = I;
      END;
      P(0) = 255;
      P(258) = 255;

      /*
      ** MVZ - MOVE ZONES (SS)
      */
      CALL INLINE(OP_LA, 1, 0, P);
      CALL INLINE(OP_MVZ, 15, 15, 1, 2, 1, 1);         /* SS */

      DO I = 1 TO 257;
         J = I & "0F";
         IF P(I) ~= J THEN DO;
             CALL FAIL_TEXT_HEADER('MVZ', 0, '->', I - 1, 12);
             CALL FAIL_RESULT(X1, J, P(I), 8);
             CALL FAIL_PRINT;
         END;
      END;
      IF P(0) ~= 255 THEN DO;
          CALL FAIL_TEXT_HEADER('MVZ', 0, '->', -1, 32);
          CALL FAIL_RESULT(X1, 255, P(0), 8);
          CALL FAIL_PRINT;
      END;
      IF P(258) ~= 255 THEN DO;
          CALL FAIL_TEXT_HEADER('MVZ', 0, '->', 257, 32);
          CALL FAIL_RESULT(X1, 255, P(258), 8);
          CALL FAIL_PRINT;
      END;
   END TEST_MOVE;

OUTPUT = '';
CALL INITIALIZATION;
CALL TEST_EDIT;
CALL TEST_PACK;
CALL TEST_UNPK;
CALL TEST_MVO;
CALL TEST_MOVE;

IF ERROR_COUNT = 0 THEN OUTPUT = 'PASSED';
ELSE OUTPUT = 'FAILED: ' || ERROR_COUNT || ' ERRORS';

RETURN ERROR_COUNT;

EOF;
