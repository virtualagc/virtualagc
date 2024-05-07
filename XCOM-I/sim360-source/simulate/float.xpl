/*
**      XPL IBM/360 EMULATOR DIAGNOSTIC FOR FLOATING POINT
**
**      AUTHOR: DANIEL WEAVER
*/

/* DECLARE VARIABLES THAT NEED TO BE ALLOCATED ON A DOUBLE WORD BOUNDARY */
/* FILLER IS USED TO GET THE ALIGNMENT CORRECT */
DECLARE FILLER(2) FIXED,
   (A, B, C, EXPECT, N)(1) FIXED,
   DEADBEEF(1) FIXED INITIAL(0, "DEADBEEF");

DECLARE PLUS_NORMAL FIXED INITIAL("4E000000"),
   MINUS_NORMAL FIXED INITIAL("CE000000"),
   MSBIT FIXED INITIAL("80000000"),
   EXPECTED_CC FIXED;

DECLARE ERROR_COUNT FIXED;
DECLARE LINE CHARACTER;
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
   OP_LA   LITERALLY '"41"',
   OP_BC   LITERALLY '"47"',
   OP_ST   LITERALLY '"50"',
   OP_L    LITERALLY '"58"',
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
   OP_SU   LITERALLY '"7F"';
/*
   OP_LPR  LITERALLY '"10"',
   OP_LNR  LITERALLY '"11"',
   OP_NR   LITERALLY '"14"',
   OP_CLR  LITERALLY '"15"',
   OP_OR   LITERALLY '"16"',
   OP_CR   LITERALLY '"19"',
   OP_AR   LITERALLY '"1A"',
   OP_SR   LITERALLY '"1B"',
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
   OP_BCTR LITERALLY '"06"',
   OP_BCR  LITERALLY '"07"',
   OP_SSK  LITERALLY '"08"',
   OP_ISK  LITERALLY '"09"',
   OP_SVC  LITERALLY '"0A"',
   OP_LR   LITERALLY '"18"',
   OP_SLR  LITERALLY '"1F"',
   OP_STH  LITERALLY '"40"',
   OP_STC  LITERALLY '"42"',
   OP_IC   LITERALLY '"43"',
   OP_EX   LITERALLY '"44"',
   OP_BAL  LITERALLY '"45"',
   OP_BCT  LITERALLY '"46"',
   OP_LH   LITERALLY '"48"',
   OP_CVD  LITERALLY '"4E"',
   OP_CVB  LITERALLY '"4F"',
   OP_SSM  LITERALLY '"80"',
   OP_LPSW LITERALLY '"82"',
   OP_WRD  LITERALLY '"84"',
   OP_RDD  LITERALLY '"85"',
   OP_BXH  LITERALLY '"86"',
   OP_BXLE LITERALLY '"87"',
   OP_STM  LITERALLY '"90"',
   OP_MVI  LITERALLY '"92"',
   OP_TS   LITERALLY '"93"',
   OP_LM   LITERALLY '"98"',
   OP_SIO  LITERALLY '"9C"',
   OP_TIO  LITERALLY '"9D"',
   OP_HIO  LITERALLY '"9E"',
   OP_TCH  LITERALLY '"9F"',
   OP_MVN  LITERALLY '"D1"',
   OP_MVC  LITERALLY '"D2"',
   OP_MVZ  LITERALLY '"D3"',
   OP_ED   LITERALLY '"DE"',
   OP_EDMK LITERALLY '"DF"',
   OP_MVO  LITERALLY '"F1"',
   OP_PACK LITERALLY '"F2"',
   OP_UNPK LITERALLY '"F3"',
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
    DECLARE HEX_DIGITS CHARACTER INITIAL('0123456789ABCDEF');

    S = '';
    L = L - 4;
    DO WHILE L >= 0;
        S = S || SUBSTR(HEX_DIGITS, SHR(V, L) & 15, 1);
        L = L - 4;
    END;
    RETURN S;
END HEX;

BINARY: PROCEDURE(V, L) CHARACTER;
    DECLARE (V, L) FIXED;
    DECLARE S CHARACTER;

    S = '';
    L = L - 1;
    DO WHILE L >= 0;
        S = S || SUBSTR('01', SHR(V, L) & 1, 1);
        L = L - 1;
    END;
    RETURN S;
   END BINARY;

FAIL_HEADER: PROCEDURE(MNEMONIC, TEXT_CODE);
      DECLARE (MNEMONIC, TEXT_CODE) CHARACTER;

      LINE = '*** ' || MNEMONIC;
      LINE = LINE || SUBSTR('         FAIL ', LENGTH(LINE)) || TEXT_CODE;
   END FAIL_HEADER;

FAIL_LOAD_32_HEADER: PROCEDURE(MNEMONIC, TEXT_CODE);
      DECLARE (MNEMONIC, TEXT_CODE) CHARACTER;

      LINE = '*** ' || MNEMONIC;
      LINE = LINE || SUBSTR('         FAIL ', LENGTH(LINE)) || HEX(A(0), 32)
         || TEXT_CODE;
   END FAIL_LOAD_32_HEADER;

FAIL_LOAD_64_HEADER: PROCEDURE(MNEMONIC, TEXT_CODE);
      DECLARE (MNEMONIC, TEXT_CODE) CHARACTER;

      LINE = '*** ' || MNEMONIC;
      LINE = LINE || SUBSTR('         FAIL ', LENGTH(LINE)) ||
         HEX(A(0), 32) || '_' || HEX(A(1), 32) || TEXT_CODE;
   END FAIL_LOAD_64_HEADER;

FAIL_32_HEADER: PROCEDURE(MNEMONIC, TEXT_CODE);
      DECLARE (MNEMONIC, TEXT_CODE) CHARACTER;

      LINE = '*** ' || MNEMONIC;
      LINE = LINE || SUBSTR('         FAIL ', LENGTH(LINE)) || HEX(A(0), 32)
         || TEXT_CODE || HEX(B(0), 32);
   END FAIL_32_HEADER;

FAIL_64_HEADER: PROCEDURE(MNEMONIC, TEXT_CODE);
      DECLARE (MNEMONIC, TEXT_CODE) CHARACTER;

      LINE = '*** ' || MNEMONIC;
      LINE = LINE || SUBSTR('         FAIL ', LENGTH(LINE)) ||
         HEX(A(0), 32) || '_' || HEX(A(1), 32) || TEXT_CODE ||
         HEX(B(0), 32) || '_' || HEX(B(1), 32);
   END FAIL_64_HEADER;

FAIL_32_RESULT: PROCEDURE;
      LINE = LINE || ' = ' || HEX(EXPECT(0), 32);
      IF C(0) = EXPECT(0) THEN LINE = LINE || '              ';
      ELSE LINE = LINE || ' GOT: ' || HEX(C(0), 32);
   END FAIL_32_RESULT;

FAIL_64_RESULT: PROCEDURE;
      LINE = LINE || ' = ' || HEX(EXPECT(0), 32) || '_' || HEX(EXPECT(1), 32);
      IF C(0) = EXPECT(0) & C(1) = EXPECT(1) THEN
         LINE = LINE || '                       ';
      ELSE LINE = LINE || ' GOT: ' || HEX(C(0), 32) || '_' || HEX(C(1), 32);
   END FAIL_64_RESULT;

FAIL_CONDITION: PROCEDURE(GOT);
      DECLARE GOT FIXED;

      IF EXPECTED_CC = GOT THEN LINE = LINE || ' CC=' || EXPECTED_CC;
      ELSE LINE = LINE || ' CC=' || EXPECTED_CC || ' GOT: CC=' || GOT;
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
        CALL INLINE(OP_BALR, 1, 0);        /* GET THE CURRENT PROGRAM COUNTER */
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

/*
**    NORMALIZE THE NUMBER IN N(0) AND N(1).
*/
NORMALIZE_64:
   PROCEDURE;
      DECLARE (I, H) FIXED;
      DECLARE (SIGN, EXP) FIXED;

      SIGN = N(0) & MSBIT;
      EXP = SHR(N(0), 24) & "7F";
      N(0) = N(0) & "00FFFFFF";

      IF N(0) = 0 & N(1) = 0 THEN DO;
            RETURN;
         END;
      DO I = 0 TO 14;
         IF (N(0) & "00F00000") = 0 THEN DO;
            EXP = EXP - 1;
            H = SHR(N(1), 28) & 15;
            N(0) = SHL(N(0), 4) + H;
            N(1) = SHL(N(1), 4);
         END;
         ELSE I = 64;
      END;
      H = SHL(EXP & "7F", 24) | (N(0) & "00FFFFFF");
      N(0) = SIGN | H;
   END NORMALIZE_64;

/*
**    UNNORMALIZE THE NUMBER IN EXPECT(0) AND EXPECT(1).
*/
UNNORMALIZE_64:
   PROCEDURE;
      DECLARE H FIXED;
      DECLARE (SIGN, EXP, XA, XB) FIXED;

      XA = SHR(A(0), 24) & "7F";
      XB = SHR(B(0), 24) & "7F";
      IF XA < XB THEN XA = XB;
      EXP = SHR(EXPECT(0), 24) & "7F";
      IF XA <= EXP THEN RETURN;

      SIGN = EXPECT(0) & MSBIT;
      EXPECT(0) = EXPECT(0) & "00FFFFFF";
      IF EXPECT(0) = 0 & EXPECT(1) = 0 THEN RETURN;

      EXP = EXP + 1;
      H = SHL(EXPECT(0) & 15, 28);
      EXPECT(1) = SHR(EXPECT(1), 4) + H;
      EXPECT(0) = SHR(EXPECT(0), 4);
      H = SHL(EXP & "7F", 24) | (EXPECT(0) & "00FFFFFF");
      EXPECT(0) = SIGN | H;
   END UNNORMALIZE_64;

NORMALIZE:  PROCEDURE(N) FIXED;
      DECLARE (I, W, N) FIXED;

      W = "46000000";
      DO I = 0 TO 1;
         IF (N & "FF000000") ~= 0 THEN DO;
            W = W + "01000000";
            N = SHR(N, 4) & "0FFFFFFF";
         END;
      END;
      DO I = 0 TO 6;
         IF (N & "00F00000") = 0 THEN DO;
            W = W - "01000000";
            N = SHL(N, 4);
         END;
         ELSE I = 64;
      END;
      RETURN W + N;
   END NORMALIZE;

FLOAT_VALUE: PROCEDURE(N) FIXED;
      DECLARE N FIXED;
      IF N = 0 THEN RETURN 0;
      IF N > 0 THEN RETURN NORMALIZE(N);
      RETURN NORMALIZE(-N) + MSBIT;
   END FLOAT_VALUE;

TEST_CONDITION_CODES:
   PROCEDURE;
      DECLARE (I, NCC) FIXED;

      DO I = 0 TO 3;
         CALL SET_CONDITION_CODES(I);
         NCC = CONDITION_CODES;
         IF NCC ~= I THEN DO;
               EXPECTED_CC = I;
               LINE = '*** CONDITION FAIL';
               CALL FAIL_CONDITION(NCC);
            END;
      END;
   END TEST_CONDITION_CODES;

TEST_LOAD_SHORT:
   PROCEDURE;
      DECLARE I FIXED;
      DECLARE NCC FIXED;

      OUTPUT = 'TESTING LOAD SHORT FLOAT';
      CALL INLINE(OP_LD, 2, 0, DEADBEEF);  /* FILL THE LOWER HALF WITH CRAP */
      CALL INLINE(OP_LD, 4, 0, DEADBEEF);
      DO I = -16 TO 16 BY 16;
         A(0) = FLOAT_VALUE(I);
         A(1) = 0;
         EXPECT(0) = FLOAT_VALUE(I);
         EXPECT(1) = 0;
         EXPECTED_CC = CC_OV;

         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LE, 2, 0, A);
         CALL INLINE(OP_STE, 2, 0, C);
         NCC = CONDITION_CODES;

         IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_LOAD_32_HEADER('LE', '');
               CALL FAIL_32_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;

         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LER, 4, 2);
         CALL INLINE(OP_STE, 4, 0, C);
         NCC = CONDITION_CODES;

         IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_LOAD_32_HEADER('LER', '');
               CALL FAIL_32_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;

         IF I < 0 THEN EXPECTED_CC = CC_LT;  ELSE
         IF I > 0 THEN EXPECTED_CC = CC_GT;  ELSE EXPECTED_CC = CC_EQ;
         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LTER, 4, 2);
         CALL INLINE(OP_STE, 4, 0, C);
         NCC = CONDITION_CODES;

         IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_LOAD_32_HEADER('LTER', '');
               CALL FAIL_32_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;

         IF I > 0 THEN EXPECTED_CC = CC_LT;  ELSE
         IF I < 0 THEN EXPECTED_CC = CC_GT;  ELSE EXPECTED_CC = CC_EQ;
         EXPECT(0) = FLOAT_VALUE(I);
         EXPECT(0) = EXPECT(0) + MSBIT;
         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LCER, 4, 2);
         CALL INLINE(OP_STE, 4, 0, C);
         NCC = CONDITION_CODES;

         IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_LOAD_32_HEADER('LCER', '');
               CALL FAIL_32_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;

         IF I = 0 THEN EXPECTED_CC = CC_EQ;  ELSE EXPECTED_CC = CC_GT;
         EXPECT(0) = FLOAT_VALUE(I);
         EXPECT(0) = EXPECT(0) & "7FFFFFFF";
         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LPER, 4, 2);
         CALL INLINE(OP_STE, 4, 0, C);
         NCC = CONDITION_CODES;

         IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_LOAD_32_HEADER('LPER', '');
               CALL FAIL_32_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;

         IF I = 0 THEN EXPECTED_CC = CC_EQ;  ELSE EXPECTED_CC = CC_LT;
         EXPECT(0) = FLOAT_VALUE(I);
         EXPECT(0) = EXPECT(0) | MSBIT;
         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LNER, 4, 2);
         CALL INLINE(OP_STE, 4, 0, C);
         NCC = CONDITION_CODES;

         IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_LOAD_32_HEADER('LNER', '');
               CALL FAIL_32_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;
      END;
      /* CHECK TO SEE IF THE LOWER HALF OF THE REGISTER GOT CORRUPTED */
      CALL INLINE(OP_STD, 2, 0, C);
      EXPECT(0) = 0;
      EXPECT(1) = DEADBEEF(1);
      IF C(1) ~= EXPECT(1) THEN DO;
         C(0) = 0;
         CALL FAIL_HEADER('R2', ' LOWER HALF');
         CALL FAIL_64_RESULT;
         CALL FAIL_PRINT;
      END;
      CALL INLINE(OP_STD, 4, 0, C);
      IF C(1) ~= EXPECT(1) THEN DO;
         C(0) = 0;
         CALL FAIL_HEADER('R4', ' LOWER HALF');
         CALL FAIL_64_RESULT;
         CALL FAIL_PRINT;
      END;
   END TEST_LOAD_SHORT;

TEST_LOAD_LONG:
   PROCEDURE;
      DECLARE I FIXED;
      DECLARE NCC FIXED;

      OUTPUT = 'TESTING LOAD LONG FLOAT';
      DO I = -16 TO 16 BY 16;
         A(0) = FLOAT_VALUE(I);
         A(1) = 0;
         EXPECT(0) = FLOAT_VALUE(I);
         EXPECT(1) = 0;
         EXPECTED_CC = CC_OV;

         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LD, 2, 0, A);
         CALL INLINE(OP_STD, 2, 0, C);
         NCC = CONDITION_CODES;

         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) | NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_LOAD_64_HEADER('LD', '');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;

         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LDR, 4, 2);
         CALL INLINE(OP_STD, 4, 0, C);
         NCC = CONDITION_CODES;

         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) | NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_LOAD_64_HEADER('LDR', '');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;

         IF I < 0 THEN EXPECTED_CC = CC_LT;  ELSE
         IF I > 0 THEN EXPECTED_CC = CC_GT;  ELSE EXPECTED_CC = CC_EQ;
         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LTDR, 4, 2);
         CALL INLINE(OP_STD, 4, 0, C);
         NCC = CONDITION_CODES;

         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) | NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_LOAD_64_HEADER('LTDR', '');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;

         IF I > 0 THEN EXPECTED_CC = CC_LT;  ELSE
         IF I < 0 THEN EXPECTED_CC = CC_GT;  ELSE EXPECTED_CC = CC_EQ;
         EXPECT(0) = FLOAT_VALUE(I);
         EXPECT(0) = EXPECT(0) + MSBIT;
         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LCDR, 4, 2);
         CALL INLINE(OP_STD, 4, 0, C);
         NCC = CONDITION_CODES;

         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) | NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_LOAD_64_HEADER('LCDR', '');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;

         IF I = 0 THEN EXPECTED_CC = CC_EQ;  ELSE EXPECTED_CC = CC_GT;
         EXPECT(0) = FLOAT_VALUE(I);
         EXPECT(0) = EXPECT(0) & "7FFFFFFF";
         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LPDR, 4, 2);
         CALL INLINE(OP_STD, 4, 0, C);
         NCC = CONDITION_CODES;

         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) | NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_LOAD_64_HEADER('LPDR', '');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;

         IF I = 0 THEN EXPECTED_CC = CC_EQ;  ELSE EXPECTED_CC = CC_LT;
         EXPECT(0) = FLOAT_VALUE(I);
         EXPECT(0) = EXPECT(0) | MSBIT;
         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LNDR, 4, 2);
         CALL INLINE(OP_STD, 4, 0, C);
         NCC = CONDITION_CODES;

         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) | NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_LOAD_64_HEADER('LNDR', '');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;
      END;
   END TEST_LOAD_LONG;

TEST_ADD:
   PROCEDURE;
      DECLARE (I, J, K, L, M) FIXED;
      DECLARE NCC FIXED;

      OUTPUT = 'TESTING ADD SHORT FLOAT';
      CALL INLINE(OP_LD, 2, 0, DEADBEEF);  /* FILL THE LOWER HALF WITH CRAP */
      CALL INLINE(OP_LD, 4, 0, DEADBEEF);
      DO I = -31 TO 30;
         IF I < 0 THEN K = -SHL(1, -I);  ELSE
         IF I > 0 THEN K = SHL(1, I);  ELSE K = 0;
         A(0) = FLOAT_VALUE(K);
         A(1) = 0;
         DO J = -28 TO 28 BY 4;
            IF J < 0 THEN L = -SHL(1, -J);  ELSE
            IF J > 0 THEN L = SHL(1, J);  ELSE L = 0;
            B(0) = FLOAT_VALUE(L);
            B(1) = 0;
            IF I = -31 & J < 0 THEN DO;
                  N(0) = MINUS_NORMAL;
                  N(1) = K - L;
                  CALL NORMALIZE_64;
                  EXPECT(0) = N(0);
                  EXPECT(1) = N(1);
                  EXPECTED_CC = CC_LT;
            END;
            ELSE DO;
                  M = K + L;
                  EXPECT(0) = FLOAT_VALUE(M);
                  EXPECT(1) = 0;
                  IF M = 0 THEN EXPECTED_CC = CC_EQ;  ELSE
                  IF M < 0 THEN EXPECTED_CC = CC_LT;  ELSE EXPECTED_CC = CC_GT;
            END;

            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LE, 2, 0, A);
            CALL INLINE(OP_LE, 4, 0, B);
            CALL INLINE(OP_AER, 2, 4);            /* RR */
            CALL INLINE(OP_STE, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_32_HEADER('AER', '+');
                  CALL FAIL_32_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;

            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LE, 2, 0, A);
            CALL INLINE(OP_AE, 2, 0, B);            /* RX */
            CALL INLINE(OP_STE, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_32_HEADER('AE', '+');
                  CALL FAIL_32_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;

            CALL UNNORMALIZE_64;
            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LE, 2, 0, A);
            CALL INLINE(OP_LE, 4, 0, B);
            CALL INLINE(OP_AUR, 2, 4);            /* RR */
            CALL INLINE(OP_STE, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_32_HEADER('AUR', '+');
                  CALL FAIL_32_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;

            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LE, 2, 0, A);
            CALL INLINE(OP_AU, 2, 0, B);            /* RX */
            CALL INLINE(OP_STE, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_32_HEADER('AU', '+');
                  CALL FAIL_32_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;
         END;
      END;
      /* CHECK TO SEE IF THE LOWER HALF OF THE REGISTER GOT CORRUPTED */
      CALL INLINE(OP_STD, 2, 0, C);
      EXPECT(0) = 0;
      EXPECT(1) = DEADBEEF(1);
      IF C(1) ~= EXPECT(1) THEN DO;
         C(0) = 0;
         CALL FAIL_HEADER('R2', ' LOWER HALF');
         CALL FAIL_64_RESULT;
         CALL FAIL_PRINT;
      END;
      CALL INLINE(OP_STD, 4, 0, C);
      IF C(1) ~= EXPECT(1) THEN DO;
         C(0) = 0;
         CALL FAIL_HEADER('R4', ' LOWER HALF');
         CALL FAIL_64_RESULT;
         CALL FAIL_PRINT;
      END;
   END TEST_ADD;

TEST_ADD_LONG:
   PROCEDURE;
      DECLARE (I, J, K, L) FIXED;
      DECLARE NCC FIXED;

      OUTPUT = 'TESTING ADD LONG FLOAT';
      DO I = -31 TO 30;
         IF I < 0 THEN K = -SHL(1, -I);  ELSE
         IF I > 0 THEN K = SHL(1, I);  ELSE K = 0;
         A(0) = FLOAT_VALUE(K);
         A(1) = 0;
         DO J = -28 TO 28 BY 4;
            IF J < 0 THEN L = -SHL(1, -J);  ELSE
            IF J > 0 THEN L = SHL(1, J);  ELSE L = 0;
            B(0) = FLOAT_VALUE(L);
            B(1) = 0;
            IF I = -31 & J < 0 THEN DO;
                  N(0) = MINUS_NORMAL;
                  N(1) = K - L;
                  EXPECTED_CC = CC_LT;
            END;
            ELSE
            IF K + L < 0 THEN DO;
                  N(0) = MINUS_NORMAL;
                  N(1) = -(K + L);
                  EXPECTED_CC = CC_LT;
            END;
            ELSE DO;
                  N(0) = PLUS_NORMAL;
                  N(1) = K + L;
                  EXPECTED_CC = CC_GT;
            END;
            CALL NORMALIZE_64;
            EXPECT(0) = N(0);
            EXPECT(1) = N(1);
            IF EXPECT(0) = 0 & EXPECT(1) = 0 THEN EXPECTED_CC = CC_EQ;

            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LD, 2, 0, A);
            CALL INLINE(OP_LD, 4, 0, B);
            CALL INLINE(OP_ADR, 2, 4);            /* RR */
            CALL INLINE(OP_STD, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
               NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_64_HEADER('ADR', '+');
                  CALL FAIL_64_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;

            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LD, 2, 0, A);
            CALL INLINE(OP_AD, 2, 0, B);            /* RX */
            CALL INLINE(OP_STD, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
               NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_64_HEADER('AD', '+');
                  CALL FAIL_64_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;

            CALL UNNORMALIZE_64;
            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LD, 2, 0, A);
            CALL INLINE(OP_LD, 4, 0, B);
            CALL INLINE(OP_AWR, 2, 4);            /* RR */
            CALL INLINE(OP_STD, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
               NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_64_HEADER('AWR', '+');
                  CALL FAIL_64_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;

            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LD, 2, 0, A);
            CALL INLINE(OP_AW, 2, 0, B);            /* RX */
            CALL INLINE(OP_STD, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
               NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_64_HEADER('AW', '+');
                  CALL FAIL_64_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;
         END;
      END;
      OUTPUT = 'TESTING ADD ZERO LONG FLOAT';
      /* NORMALIZATION TEST */
      DO I = 0 TO 31;
         K = SHL(1, I);
         A(0) = FLOAT_VALUE(K) & "7FFFFFFF";
         A(1) = 0;
         B(0) = "4E000000";
         B(1) = 0;
         EXPECT(0) = "4E000000";
         EXPECT(1) = K;
         EXPECTED_CC = CC_GT;

         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LD, 2, 0, A);
         CALL INLINE(OP_LD, 4, 0, B);
         CALL INLINE(OP_AWR, 2, 4);            /* RR */
         CALL INLINE(OP_STD, 2, 0, C);
         NCC = CONDITION_CODES;
         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
            NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_64_HEADER('AWR', '+');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;

         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LD, 2, 0, A);
         CALL INLINE(OP_AW, 2, 0, B);            /* RX */
         CALL INLINE(OP_STD, 2, 0, C);
         NCC = CONDITION_CODES;
         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
            NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_64_HEADER('AW', '+');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;
      END;
      OUTPUT = 'TESTING ADD ONE LONG FLOAT';
      /* YET ANOTHER NORMALIZATION TEST */
      DO I = -64 TO 64;
         J = I + "104";
         K = SHL(J & "1FC", 22);
         A(0) = SHL("00100000", I & 3) + K;
         A(1) = 0;
         B(0) = FLOAT_VALUE(1);
         B(1) = 0;
         IF I < -52 THEN DO;
            EXPECT(0) = B(0);
            EXPECT(1) = 0;
         END;
         ELSE
         IF I < -20 THEN DO;
            EXPECT(0) = B(0);
            EXPECT(1) = SHL(1, 52 + I);
         END;
         ELSE
         IF I < 0 THEN DO;
            J = SHL(1, 20 + I);
            EXPECT(0) = J + "41100000";
            EXPECT(1) = 0;
         END;
         ELSE
         IF I < 24 THEN DO;
            J = SHL(1, I);
            EXPECT(0) = FLOAT_VALUE(J + 1);
            EXPECT(1) = 0;
         END;
         ELSE
         IF I < 56 THEN DO;
            EXPECT(0) = A(0);
            EXPECT(1) = SHL(1, (55 - I) & "1FC");
         END;
         ELSE DO;
            EXPECT(0) = A(0);
            EXPECT(1) = 0;
         END;
         EXPECTED_CC = CC_GT;

         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LD, 2, 0, A);
         CALL INLINE(OP_LD, 4, 0, B);
         CALL INLINE(OP_ADR, 2, 4);            /* RR */
         CALL INLINE(OP_STD, 2, 0, C);
         NCC = CONDITION_CODES;
         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
            NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_64_HEADER('ADR', '+');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;

         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LD, 2, 0, A);
         CALL INLINE(OP_AD, 2, 0, B);            /* RX */
         CALL INLINE(OP_STD, 2, 0, C);
         NCC = CONDITION_CODES;
         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
            NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_64_HEADER('AD', '+');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;
      END;
   END TEST_ADD_LONG;

TEST_SUBTRACT:
   PROCEDURE;
      DECLARE (I, J, K, L, M) FIXED;
      DECLARE NCC FIXED;

      OUTPUT = 'TESTING SUBTRACT SHORT FLOAT';
      CALL INLINE(OP_LD, 2, 0, DEADBEEF);  /* FILL THE LOWER HALF WITH CRAP */
      CALL INLINE(OP_LD, 4, 0, DEADBEEF);
      DO I = -31 TO 30;
         IF I < 0 THEN K = -SHL(1, -I);  ELSE
         IF I > 0 THEN K = SHL(1, I);  ELSE K = 0;
         A(0) = FLOAT_VALUE(K);
         A(1) = 0;
         DO J = -28 TO 28 BY 4;
            IF J < 0 THEN L = -SHL(1, -J);  ELSE
            IF J > 0 THEN L = SHL(1, J);  ELSE L = 0;
            B(0) = FLOAT_VALUE(L);
            B(1) = 0;
            IF I = -31 & J > 0 THEN DO;
                  N(0) = MINUS_NORMAL;
                  N(1) = K + L;
                  CALL NORMALIZE_64;
                  EXPECT(0) = N(0);
                  EXPECT(1) = N(1);
                  EXPECTED_CC = CC_LT;
            END;
            ELSE DO;
                  M = K - L;
                  EXPECT(0) = FLOAT_VALUE(M);
                  EXPECT(1) = 0;
                  IF M = 0 THEN EXPECTED_CC = CC_EQ;  ELSE
                  IF M < 0 THEN EXPECTED_CC = CC_LT;  ELSE EXPECTED_CC = CC_GT;
            END;

            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LE, 2, 0, A);
            CALL INLINE(OP_LE, 4, 0, B);
            CALL INLINE(OP_SER, 2, 4);            /* RR */
            CALL INLINE(OP_STE, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_32_HEADER('SER', '-');
                  CALL FAIL_32_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;

            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LE, 2, 0, A);
            CALL INLINE(OP_SE, 2, 0, B);            /* RX */
            CALL INLINE(OP_STE, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_32_HEADER('SE', '-');
                  CALL FAIL_32_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;

            CALL UNNORMALIZE_64;
            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LE, 2, 0, A);
            CALL INLINE(OP_LE, 4, 0, B);
            CALL INLINE(OP_SUR, 2, 4);            /* RR */
            CALL INLINE(OP_STE, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_32_HEADER('SUR', '-');
                  CALL FAIL_32_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;

            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LE, 2, 0, A);
            CALL INLINE(OP_SU, 2, 0, B);            /* RX */
            CALL INLINE(OP_STE, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_32_HEADER('SU', '-');
                  CALL FAIL_32_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;
         END;
      END;
      /* CHECK TO SEE IF THE LOWER HALF OF THE REGISTER GOT CORRUPTED */
      CALL INLINE(OP_STD, 2, 0, C);
      EXPECT(0) = 0;
      EXPECT(1) = DEADBEEF(1);
      IF C(1) ~= EXPECT(1) THEN DO;
         C(0) = 0;
         CALL FAIL_HEADER('R2', ' LOWER HALF');
         CALL FAIL_64_RESULT;
         CALL FAIL_PRINT;
      END;
      CALL INLINE(OP_STD, 4, 0, C);
      IF C(1) ~= EXPECT(1) THEN DO;
         C(0) = 0;
         CALL FAIL_HEADER('R4', ' LOWER HALF');
         CALL FAIL_64_RESULT;
         CALL FAIL_PRINT;
      END;
   END TEST_SUBTRACT;

TEST_SUBTRACT_LONG:
   PROCEDURE;
      DECLARE (I, J, K, L) FIXED;
      DECLARE NCC FIXED;

      OUTPUT = 'TESTING SUBTRACT LONG FLOAT';
      DO I = -31 TO 30;
         IF I < 0 THEN K = -SHL(1, -I);  ELSE
         IF I > 0 THEN K = SHL(1, I);  ELSE K = 0;
         A(0) = FLOAT_VALUE(K);
         A(1) = 0;
         DO J = -28 TO 28 BY 4;
            IF J < 0 THEN L = -SHL(1, -J);  ELSE
            IF J > 0 THEN L = SHL(1, J);  ELSE L = 0;
            B(0) = FLOAT_VALUE(L);
            B(1) = 0;
            IF I = -31 & J > 0 THEN DO;
                  N(0) = MINUS_NORMAL;
                  N(1) = K + L;
                  EXPECTED_CC = CC_LT;
            END;
            ELSE
            IF K - L < 0 THEN DO;
                  N(0) = MINUS_NORMAL;
                  N(1) = -(K - L);
                  EXPECTED_CC = CC_LT;
            END;
            ELSE DO;
                  N(0) = PLUS_NORMAL;
                  N(1) = K - L;
                  EXPECTED_CC = CC_GT;
            END;
            CALL NORMALIZE_64;
            EXPECT(0) = N(0);
            EXPECT(1) = N(1);
            IF EXPECT(0) = 0 & EXPECT(1) = 0 THEN EXPECTED_CC = CC_EQ;

            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LD, 2, 0, A);
            CALL INLINE(OP_LD, 4, 0, B);
            CALL INLINE(OP_SDR, 2, 4);            /* RR */
            CALL INLINE(OP_STD, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
               NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_64_HEADER('SDR', '-');
                  CALL FAIL_64_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;

            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LD, 2, 0, A);
            CALL INLINE(OP_SD, 2, 0, B);            /* RX */
            CALL INLINE(OP_STD, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
               NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_64_HEADER('SD', '-');
                  CALL FAIL_64_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;

            CALL UNNORMALIZE_64;
            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LD, 2, 0, A);
            CALL INLINE(OP_LD, 4, 0, B);
            CALL INLINE(OP_SWR, 2, 4);            /* RR */
            CALL INLINE(OP_STD, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
               NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_64_HEADER('SWR', '-');
                  CALL FAIL_64_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;

            CALL SET_CONDITION_CODES(CC_OV);
            CALL INLINE(OP_LD, 2, 0, A);
            CALL INLINE(OP_SW, 2, 0, B);            /* RX */
            CALL INLINE(OP_STD, 2, 0, C);
            NCC = CONDITION_CODES;
            IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
               NCC ~= EXPECTED_CC THEN DO;
                  CALL FAIL_64_HEADER('SW', '-');
                  CALL FAIL_64_RESULT;
                  CALL FAIL_CONDITION(NCC);
               END;
         END;
      END;
      OUTPUT = 'TESTING SUBTRACT ONE LONG FLOAT';
      /* YET ANOTHER NORMALIZATION TEST */
      DO I = -64 TO 64;
         J = I + "104";
         K = SHL(J & "1FC", 22);
         A(0) = SHL("00100000", I & 3) + K;
         A(1) = 0;
         B(0) = FLOAT_VALUE(1);
         B(1) = 0;
         IF I < -52 THEN DO;
            EXPECT(0) = FLOAT_VALUE(-1);
            EXPECT(1) = 0;
         END;
         ELSE
         IF I < -23 THEN DO;
            EXPECT(0) = "C0FFFFFF";
            EXPECT(1) = SHL("FFFFFFF0", 52 + I);
         END;
         ELSE
         IF I < 0 THEN DO;
            J = SHL("FFFFFFFF", 24 + I);
            EXPECT(0) = J & "C0FFFFFF";
            EXPECT(1) = 0;
         END;
         ELSE
         IF I < 24 THEN DO;
            J = SHL(1, I);
            EXPECT(0) = FLOAT_VALUE(1 - J) & "7FFFFFFF";
            EXPECT(1) = 0;
         END;
         ELSE
         IF I < 28 THEN DO;
            J = FLOAT_VALUE(SHL(1, I - 20) - 1) + "05000000";
            EXPECT(0) = J | "000FFFFF";
            EXPECT(1) = SHL("FFFFFFFF", (56 - I) & "1FC");
         END;
         ELSE
         IF I < 56 THEN DO;
            J = FLOAT_VALUE(SHL(1, I - 24) - 1) + "06000000";
            EXPECT(0) = J | "000FFFFF";
            EXPECT(1) = SHL("FFFFFFFF", (56 - I) & "1FC");
         END;
         ELSE DO;
            EXPECT(0) = A(0);
            EXPECT(1) = 0;
         END;
         IF EXPECT(0) = 0 THEN EXPECTED_CC = CC_EQ;  ELSE
         IF (EXPECT(0) & MSBIT) = 0 THEN EXPECTED_CC = CC_GT;
         ELSE EXPECTED_CC = CC_LT;

         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LD, 2, 0, A);
         CALL INLINE(OP_LD, 4, 0, B);
         CALL INLINE(OP_SDR, 2, 4);            /* RR */
         CALL INLINE(OP_STD, 2, 0, C);
         NCC = CONDITION_CODES;
         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
            NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_64_HEADER('SDR', '-');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;

         CALL SET_CONDITION_CODES(CC_OV);
         CALL INLINE(OP_LD, 2, 0, A);
         CALL INLINE(OP_SD, 2, 0, B);            /* RX */
         CALL INLINE(OP_STD, 2, 0, C);
         NCC = CONDITION_CODES;
         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
            NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_64_HEADER('SD', '-');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;
      END;
   END TEST_SUBTRACT_LONG;

TEST_COMPARE:
   PROCEDURE;
      DECLARE (I, J, K) FIXED;
      DECLARE NCC FIXED;
      DECLARE ENDPOINT FIXED INITIAL(8),
         VALUE(32) FIXED INITIAL( "FFFFFF00", "FFFFFFE0", "FFFFFFF0",
            "FFFFFFFF", 0, 1, 16, 32, 256, 42);
      DECLARE RESULT(32) FIXED INITIAL(
         1, 1, 1, 1, 1, 1, 0, 1, 1, 2, 1, 1, 2, 0, 1, 2, 2,
         1, 2, 2, 0, 2, 2, 2, 2, 2, 2);

      OUTPUT = 'TESTING COMPARE SHORT FLOAT';
      CALL INLINE(OP_LD, 2, 0, DEADBEEF);  /* FILL THE LOWER HALF WITH CRAP */
      CALL INLINE(OP_LD, 4, 0, DEADBEEF);
      K = 0;
      DO I = 0 TO ENDPOINT;
         A(0) = FLOAT_VALUE(VALUE(I));
         A(1) = 0;
         DO J = -16 TO 16 BY 16;
               B(0) = FLOAT_VALUE(J);
               B(1) = 0;
               EXPECTED_CC = RESULT(K);

               CALL SET_CONDITION_CODES(CC_EQ);
               CALL INLINE(OP_LE, 2, 0, A);
               CALL INLINE(OP_LE, 4, 0, B);
               CALL INLINE(OP_CER, 2, 4);            /* RR */
               NCC = CONDITION_CODES;
               IF NCC ~= EXPECTED_CC THEN DO;
                     CALL FAIL_32_HEADER('CER', ' COMPARE ');
                     CALL FAIL_CONDITION(NCC);
                  END;

               CALL SET_CONDITION_CODES(CC_LT);
               CALL INLINE(OP_LE, 2, 0, A);
               CALL INLINE(OP_CE, 2, 0, B);            /* RX */
               NCC = CONDITION_CODES;
               IF NCC ~= EXPECTED_CC THEN DO;
                     CALL FAIL_32_HEADER('CE', ' COMPARE ');
                     CALL FAIL_CONDITION(NCC);
                  END;

               K = K + 1;
         END;
      END;
      /* CHECK TO SEE IF THE LOWER HALF OF THE REGISTER GOT CORRUPTED */
      CALL INLINE(OP_STD, 2, 0, C);
      EXPECT(0) = 0;
      EXPECT(1) = DEADBEEF(1);
      IF C(1) ~= EXPECT(1) THEN DO;
         C(0) = 0;
         CALL FAIL_HEADER('R2', ' LOWER HALF');
         CALL FAIL_64_RESULT;
         CALL FAIL_PRINT;
      END;
      CALL INLINE(OP_STD, 4, 0, C);
      IF C(1) ~= EXPECT(1) THEN DO;
         C(0) = 0;
         CALL FAIL_HEADER('R4', ' LOWER HALF');
         CALL FAIL_64_RESULT;
         CALL FAIL_PRINT;
      END;
      OUTPUT = 'TESTING COMPARE LONG FLOAT';
      K = 0;
      DO I = 0 TO ENDPOINT;
         A(0) = FLOAT_VALUE(VALUE(I));
         A(1) = 0;
         DO J = -16 TO 16 BY 16;
               B(0) = FLOAT_VALUE(J);
               B(1) = 0;
               EXPECTED_CC = RESULT(K);

               CALL SET_CONDITION_CODES(CC_GT);
               CALL INLINE(OP_LD, 2, 0, A);
               CALL INLINE(OP_LD, 4, 0, B);
               CALL INLINE(OP_CDR, 2, 4);            /* RR */
               NCC = CONDITION_CODES;
               IF NCC ~= EXPECTED_CC THEN DO;
                     CALL FAIL_64_HEADER('CDR', ' COMPARE ');
                     CALL FAIL_CONDITION(NCC);
                  END;

               CALL SET_CONDITION_CODES(CC_OV);
               CALL INLINE(OP_LD, 2, 0, A);
               CALL INLINE(OP_CD, 2, 0, B);            /* RX */
               NCC = CONDITION_CODES;
               IF NCC ~= EXPECTED_CC THEN DO;
                     CALL FAIL_64_HEADER('CD', ' COMPARE ');
                     CALL FAIL_CONDITION(NCC);
                  END;

               K = K + 1;
         END;
      END;
   END TEST_COMPARE;

TEST_DIVIDE:
   PROCEDURE;
      DECLARE (I, J, K) FIXED;
      DECLARE NCC FIXED;

      OUTPUT = 'TESTING DIVIDE SHORT FLOAT';
      CALL INLINE(OP_LD, 2, 0, DEADBEEF);  /* FILL THE LOWER HALF WITH CRAP */
      CALL INLINE(OP_LD, 4, 0, DEADBEEF);
      DO I = -360 TO 360 BY 360;
         A(0) = FLOAT_VALUE(I);
         A(1) = 0;
            DO J = -6 TO 6;
               IF J = 0 THEN J = 1;
               B(0) = FLOAT_VALUE(J);
               B(1) = 0;
               K = I / J;
               EXPECT(0) = FLOAT_VALUE(K);
               EXPECT(1) = 0;
               EXPECTED_CC = CC_OV;

               CALL SET_CONDITION_CODES(EXPECTED_CC);
               CALL INLINE(OP_LE, 2, 0, A);
               CALL INLINE(OP_LE, 4, 0, B);
               CALL INLINE(OP_DER, 2, 4);            /* RR */
               CALL INLINE(OP_STE, 2, 0, C);
               NCC = CONDITION_CODES;
               IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
                     CALL FAIL_32_HEADER('DER', '/');
                     CALL FAIL_32_RESULT;
                     CALL FAIL_CONDITION(NCC);
                  END;

               EXPECTED_CC = CC_GT;
               CALL SET_CONDITION_CODES(EXPECTED_CC);
               CALL INLINE(OP_LE, 2, 0, A);
               CALL INLINE(OP_DE, 2, 0, B);            /* RX */
               CALL INLINE(OP_STE, 2, 0, C);
               NCC = CONDITION_CODES;
               IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
                     CALL FAIL_32_HEADER('DE', '/');
                     CALL FAIL_32_RESULT;
                     CALL FAIL_CONDITION(NCC);
                  END;
            END;
      END;
      OUTPUT = 'TESTING HALVE SHORT FLOAT';
      DO I = -32 TO 32;
         A(0) = FLOAT_VALUE(I);
         A(1) = 0;
         K = SHR(A(0) & "00FFFFFF", 1);
         EXPECT(0) = (A(0) & "FF000000") + K;
         EXPECT(1) = SHL(A(0), 31);
         EXPECTED_CC = CC_OV;
         CALL SET_CONDITION_CODES(EXPECTED_CC);
         CALL INLINE(OP_LE, 4, 0, A);
         CALL INLINE(OP_HER, 2, 4);            /* RR */
         CALL INLINE(OP_STE, 2, 0, C);
         NCC = CONDITION_CODES;
         IF C(0) ~= EXPECT(0) | NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_LOAD_32_HEADER('HER', ' HALF');
               CALL FAIL_32_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;
      END;
      /* CHECK TO SEE IF THE LOWER HALF OF THE REGISTER GOT CORRUPTED */
      CALL INLINE(OP_STD, 2, 0, C);
      EXPECT(0) = 0;
      EXPECT(1) = DEADBEEF(1);
      IF C(1) ~= EXPECT(1) THEN DO;
         C(0) = 0;
         CALL FAIL_HEADER('R2', ' LOWER HALF');
         CALL FAIL_64_RESULT;
         CALL FAIL_PRINT;
      END;
      CALL INLINE(OP_STD, 4, 0, C);
      IF C(1) ~= EXPECT(1) THEN DO;
         C(0) = 0;
         CALL FAIL_HEADER('R4', ' LOWER HALF');
         CALL FAIL_64_RESULT;
         CALL FAIL_PRINT;
      END;
      OUTPUT = 'TESTING DIVIDE LONG FLOAT';
      DO I = -360 TO 360 BY 360;
         A(0) = FLOAT_VALUE(I);
         A(1) = 0;
            DO J = -6 TO 6;
               IF J = 0 THEN J = 1;
               B(0) = FLOAT_VALUE(J);
               B(1) = 0;
               K = I / J;
               EXPECT(0) = FLOAT_VALUE(K);
               EXPECT(1) = 0;
               EXPECTED_CC = CC_OV;
               CALL SET_CONDITION_CODES(EXPECTED_CC);
               CALL INLINE(OP_LD, 2, 0, A);
               CALL INLINE(OP_LD, 4, 0, B);
               CALL INLINE(OP_DDR, 2, 4);            /* RR */
               CALL INLINE(OP_STD, 2, 0, C);
               NCC = CONDITION_CODES;
               IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
                  NCC ~= EXPECTED_CC THEN DO;
                     CALL FAIL_64_HEADER('DDR', '/');
                     CALL FAIL_64_RESULT;
                     CALL FAIL_CONDITION(NCC);
                  END;

               EXPECTED_CC = CC_GT;
               CALL SET_CONDITION_CODES(EXPECTED_CC);
               CALL INLINE(OP_LD, 2, 0, A);
               CALL INLINE(OP_DD, 2, 0, B);            /* RX */
               CALL INLINE(OP_STD, 2, 0, C);
               NCC = CONDITION_CODES;
               IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
                  NCC ~= EXPECTED_CC THEN DO;
                     CALL FAIL_64_HEADER('DD', '/');
                     CALL FAIL_64_RESULT;
                     CALL FAIL_CONDITION(NCC);
                  END;
            END;
      END;
      OUTPUT = 'TESTING WALKING ONES DIVIDE LONG FLOAT';
      DO I = 0 TO 52;
         J = SHL(1, I & 31);
         IF I < 32 THEN DO;
            A(0) = FLOAT_VALUE(2);
            A(1) = J;
         END;
         ELSE DO;
            A(0) = FLOAT_VALUE(2) + J;
            A(1) = 0;
         END;
         B(0) = FLOAT_VALUE(2);
         B(1) = 0;
         EXPECT(0) = FLOAT_VALUE(1);
         EXPECT(1) = 0;
         K = SHL(1, (I - 1) & 31);
         IF I > 32 THEN DO;
            EXPECT(0) = EXPECT(0) + K;
         END;
         ELSE
         IF I > 0 THEN DO;
            EXPECT(1) = K;
         END;
         EXPECTED_CC = CC_OV;
         CALL SET_CONDITION_CODES(EXPECTED_CC);
         CALL INLINE(OP_LD, 2, 0, A);
         CALL INLINE(OP_LD, 4, 0, B);
         CALL INLINE(OP_DDR, 2, 4);            /* RR */
         CALL INLINE(OP_STD, 2, 0, C);
         NCC = CONDITION_CODES;
         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
            NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_64_HEADER('DDR', '/');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;

         EXPECTED_CC = CC_GT;
         CALL SET_CONDITION_CODES(EXPECTED_CC);
         CALL INLINE(OP_LD, 2, 0, A);
         CALL INLINE(OP_DD, 2, 0, B);            /* RX */
         CALL INLINE(OP_STD, 2, 0, C);
         NCC = CONDITION_CODES;
         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
            NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_64_HEADER('DD', '/');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;
      END;
      OUTPUT = 'TESTING HALVE LONG FLOAT';
      DO I = -32 TO 32;
         A(0) = FLOAT_VALUE(I);
         A(1) = 0;
         K = SHR(A(0) & "00FFFFFF", 1);
         EXPECT(0) = (A(0) & "FF000000") + K;
         EXPECT(1) = SHL(A(0), 31);
         EXPECTED_CC = CC_OV;
         CALL SET_CONDITION_CODES(EXPECTED_CC);
         CALL INLINE(OP_LD, 4, 0, A);
         CALL INLINE(OP_HDR, 2, 4);            /* RR */
         CALL INLINE(OP_STD, 2, 0, C);
         NCC = CONDITION_CODES;
         IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
            NCC ~= EXPECTED_CC THEN DO;
               CALL FAIL_LOAD_64_HEADER('HDR', ' HALF');
               CALL FAIL_64_RESULT;
               CALL FAIL_CONDITION(NCC);
            END;
      END;
   END TEST_DIVIDE;

TEST_MULTIPLY:
   PROCEDURE;
      DECLARE (I, J, K, L, M) FIXED;
      DECLARE NCC FIXED;

      OUTPUT = 'TESTING MULTIPLY SHORT FLOAT';
      DO I = -12 TO 12 BY 4;
         IF I = 0 THEN K = 0;  ELSE
         IF I < 0 THEN DO;
            K = SHL(1, -I);
         END;
         ELSE DO;
            K = SHL(1, I);
         END;
         A(0) = FLOAT_VALUE(K);
         A(1) = "CAFEBABE";
            DO J = -12 TO 12 BY 4;
               IF J = 0 THEN L = 0;  ELSE
               IF J < 0 THEN DO;
                  L = SHL(1, -J);
               END;
               ELSE DO;
                  L = SHL(1, J);
               END;
               B(0) = FLOAT_VALUE(L);
               B(1) = 0;
               M = K * L;
               EXPECT(0) = FLOAT_VALUE(M);
               EXPECT(1) = 0;
               EXPECTED_CC = CC_OV;
               CALL SET_CONDITION_CODES(EXPECTED_CC);
               CALL INLINE(OP_LD, 2, 0, A);
               CALL INLINE(OP_LE, 4, 0, B);
               CALL INLINE(OP_MER, 2, 4);            /* RR */
               CALL INLINE(OP_STD, 2, 0, C);
               NCC = CONDITION_CODES;
               IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
                  NCC ~= EXPECTED_CC THEN DO;
                     CALL FAIL_32_HEADER('MER', '*');
                     CALL FAIL_64_RESULT;
                     CALL FAIL_CONDITION(NCC);
                  END;

               EXPECTED_CC = CC_GT;
               CALL SET_CONDITION_CODES(EXPECTED_CC);
               CALL INLINE(OP_LD, 2, 0, A);
               CALL INLINE(OP_ME, 2, 0, B);            /* RX */
               CALL INLINE(OP_STD, 2, 0, C);
               NCC = CONDITION_CODES;
               IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
                  NCC ~= EXPECTED_CC THEN DO;
                     CALL FAIL_32_HEADER('ME', '*');
                     CALL FAIL_64_RESULT;
                     CALL FAIL_CONDITION(NCC);
                  END;
            END;
      END;
      OUTPUT = 'TESTING MULTIPLY LONG FLOAT';
      DO I = -12 TO 12 BY 4;
         IF I = 0 THEN K = 0;  ELSE
         IF I < 0 THEN DO;
            K = SHL(1, -I);
         END;
         ELSE DO;
            K = SHL(1, I);
         END;
         A(0) = FLOAT_VALUE(K);
         A(1) = 0;
            DO J = -12 TO 12 BY 4;
               IF J = 0 THEN L = 0;  ELSE
               IF J < 0 THEN DO;
                  L = SHL(1, -J);
               END;
               ELSE DO;
                  L = SHL(1, J);
               END;
               B(0) = FLOAT_VALUE(L);
               B(1) = 0;
               M = K * L;
               EXPECT(0) = FLOAT_VALUE(M);
               EXPECT(1) = 0;
               EXPECTED_CC = CC_OV;
               CALL SET_CONDITION_CODES(EXPECTED_CC);
               CALL INLINE(OP_LD, 2, 0, A);
               CALL INLINE(OP_LD, 4, 0, B);
               CALL INLINE(OP_MDR, 2, 4);            /* RR */
               CALL INLINE(OP_STD, 2, 0, C);
               NCC = CONDITION_CODES;
               IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
                  NCC ~= EXPECTED_CC THEN DO;
                     CALL FAIL_64_HEADER('MDR', '*');
                     CALL FAIL_64_RESULT;
                     CALL FAIL_CONDITION(NCC);
                  END;

               EXPECTED_CC = CC_GT;
               CALL SET_CONDITION_CODES(EXPECTED_CC);
               CALL INLINE(OP_LD, 2, 0, A);
               CALL INLINE(OP_MD, 2, 0, B);            /* RX */
               CALL INLINE(OP_STD, 2, 0, C);
               NCC = CONDITION_CODES;
               IF C(0) ~= EXPECT(0) | C(1) ~= EXPECT(1) |
                  NCC ~= EXPECTED_CC THEN DO;
                     CALL FAIL_64_HEADER('MD', '*');
                     CALL FAIL_64_RESULT;
                     CALL FAIL_CONDITION(NCC);
                  END;
            END;
      END;
   END TEST_MULTIPLY;

SHOW_MEMINFO: PROCEDURE;
      DECLARE (ND, HIGH, V, LOWPOINT, DATASEC) FIXED;
      DECLARE AT_STRING CHARACTER INITIAL(' @ ');

      LOWPOINT = FREEPOINT;
      CALL INLINE(OP_ST, 11, 0, DATASEC);  /* THE ADDRESS OF THE DATA SECTION */
      HIGH = 0;
      DO ND = 0 TO NDESCRIPT;
         V = SHR(DESCRIPTOR(ND), 24) + (DESCRIPTOR(ND) & "FFFFFF");
         IF V > HIGH THEN HIGH = V;
      END;
      OUTPUT = 'FREEBASE  ' || HEX(FREEBASE, 32) || AT_STRING
            || HEX(ADDR(FREEBASE), 32) || ' OFFSET ' 
            || HEX(ADDR(FREEBASE) - DATASEC, 32);
      OUTPUT = 'FREEPOINT ' || HEX(LOWPOINT, 32) || AT_STRING
            || HEX(ADDR(FREEPOINT), 32) || ' OFFSET ' 
            || HEX(ADDR(FREEPOINT) - DATASEC, 32);
      OUTPUT = 'FREELIMIT ' || HEX(FREELIMIT, 32) || AT_STRING
            || HEX(ADDR(FREELIMIT), 32) || ' OFFSET ' 
            || HEX(ADDR(FREELIMIT) - DATASEC, 32);
      OUTPUT = 'DATA SECTION START: ' || HEX(DATASEC, 32);
      OUTPUT = 'MONITOR LINK ADDRESS: ' || HEX(ADDR(MONITOR_LINK), 32);
      OUTPUT = 'DESCRIPTOR SECTION START: ' || HEX(ADDR(DESCRIPTOR), 32);
      OUTPUT = 'HIGH STRING ADDRESS: ' || HEX(HIGH, 32);
      OUTPUT = 'NDESCRIPT = ' || NDESCRIPT;
      OUTPUT = '';
   END SHOW_MEMINFO;

IF (ADDR(A) & 7) ~= 0 THEN DO;
   OUTPUT = 'DOUBLE WORD ADDRESSESS NOT PROPERLY ALIGNED.';
   /* ADD ONE TO THE FILLER() ARRAY AND RECOMPILE. */
   RETURN 1;
END;
CALL SHOW_MEMINFO;
CALL TEST_LOAD_SHORT;
CALL TEST_LOAD_LONG;
CALL TEST_CONDITION_CODES;
CALL TEST_ADD;
CALL TEST_ADD_LONG;
CALL TEST_SUBTRACT;
CALL TEST_SUBTRACT_LONG;
CALL TEST_COMPARE;
CALL TEST_DIVIDE;
CALL TEST_MULTIPLY;

IF ERROR_COUNT = 0 THEN OUTPUT = 'PASSED';
ELSE OUTPUT = 'FAILED: ' || ERROR_COUNT || ' ERRORS';

RETURN ERROR_COUNT;

EOF;
