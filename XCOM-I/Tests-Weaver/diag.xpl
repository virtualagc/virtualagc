/*
**      XPL IBM/360 EMULATOR DIAGNOSTIC
**
**      AUTHOR: DANIEL WEAVER
*/

/* COMMON TEST VECTORS.  DO NOT CHANGE THE ORDER.  DO NOT CHANGE THE VALUES */
DECLARE TV(3) FIXED INITIAL("FFFFFFFF", 0, "7FFFFFFF", "80000000"),
    HTV(3) BIT(16) INITIAL("FFFFFFFF", 0, "7FFF", "8000"),
    MINUS_ONE FIXED INITIAL("FFFFFFFF"),
    MSBIT FIXED INITIAL("80000000"),
    FIFTEEN FIXED INITIAL(15),
    ZERO FIXED INITIAL(0),
    LINE CHARACTER,
    ERROR_COUNT FIXED;

DECLARE ADD_REFERENCE(15) FIXED INITIAL("FFFFFFFE", "FFFFFFFF",
        "7FFFFFFE", "7FFFFFFF", "FFFFFFFF", "00000000", "7FFFFFFF",
        "80000000", "7FFFFFFE", "7FFFFFFF", "FFFFFFFE", "FFFFFFFF",
        "7FFFFFFF", "80000000", "FFFFFFFF", "00000000");

DECLARE SUBTRACT_REFERENCE(15) FIXED INITIAL("00000000", "FFFFFFFF",
        "80000000", "7FFFFFFF", "00000001", "00000000", "80000001",
        "80000000", "80000000", "7FFFFFFF", "00000000", "FFFFFFFF",
        "80000001", "80000000", "00000001", "00000000");

DECLARE ADD_HALF_REFERENCE(15) FIXED INITIAL("FFFFFFFE", "FFFFFFFF",
        "00007FFE", "FFFF7FFF", "FFFFFFFF", "00000000", "00007FFF",
        "FFFF8000", "7FFFFFFE", "7FFFFFFF", "80007FFE", "7FFF7FFF",
        "7FFFFFFF", "80000000", "80007FFF", "7FFF8000");

DECLARE SUBTRACT_HALF_REFERENCE(15) FIXED INITIAL("00000000", "FFFFFFFF",
        "FFFF8000", "00007FFF", "00000001", "00000000", "FFFF8001",
        "00008000", "80000000", "7FFFFFFF", "7FFF8000", "80007FFF",
        "80000001", "80000000", "7FFF8001", "80008000");

DECLARE (I, J, K, L) FIXED;

/* CONDITION CODES */
DECLARE CC_EQ LITERALLY '0',
    CC_LT LITERALLY '1',
    CC_GT LITERALLY '2',
    CC_OV LITERALLY '3',
    CC0 LITERALLY '0',
    CC1 LITERALLY '1',
    CC2 LITERALLY '2',
    CC3 LITERALLY '3';

DECLARE
   OP_BALR LITERALLY '"05"',
   OP_LPR  LITERALLY '"10"',
   OP_LNR  LITERALLY '"11"',
   OP_LTR  LITERALLY '"12"',
   OP_LCR  LITERALLY '"13"',
   OP_NR   LITERALLY '"14"',
   OP_CLR  LITERALLY '"15"',
   OP_OR   LITERALLY '"16"',
   OP_XR   LITERALLY '"17"',
   OP_CR   LITERALLY '"19"',
   OP_AR   LITERALLY '"1A"',
   OP_SR   LITERALLY '"1B"',
   OP_MR   LITERALLY '"1C"',
   OP_DR   LITERALLY '"1D"',
   OP_ALR  LITERALLY '"1E"',
   OP_LA   LITERALLY '"41"',
   OP_BC   LITERALLY '"47"',
   OP_SH   LITERALLY '"4B"',
   OP_CH   LITERALLY '"49"',
   OP_AH   LITERALLY '"4A"',
   OP_MH   LITERALLY '"4C"',
   OP_ST   LITERALLY '"50"',
   OP_N    LITERALLY '"54"',
   OP_CL   LITERALLY '"55"',
   OP_O    LITERALLY '"56"',
   OP_X    LITERALLY '"57"',
   OP_L    LITERALLY '"58"',
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
   OP_TRT  LITERALLY '"DD"';
/*
   OP_TR   LITERALLY '"DC"',
   BCTR LITERALLY '"06"',
   BCR  LITERALLY '"07"',
   SSK  LITERALLY '"08"',
   ISK  LITERALLY '"09"',
   SVC  LITERALLY '"0A"',
   LR   LITERALLY '"18"',
   SLR  LITERALLY '"1F"',
   LPDR LITERALLY '"20"',
   LNDR LITERALLY '"21"',
   LTDR LITERALLY '"22"',
   LCDR LITERALLY '"23"',
   HDR  LITERALLY '"24"',
   LDR  LITERALLY '"28"',
   CDR  LITERALLY '"29"',
   ADR  LITERALLY '"2A"',
   SDR  LITERALLY '"2B"',
   MDR  LITERALLY '"2C"',
   DDR  LITERALLY '"2D"',
   AWR  LITERALLY '"2E"',
   SWR  LITERALLY '"2F"',
   LPER LITERALLY '"30"',
   LNER LITERALLY '"31"',
   LTER LITERALLY '"32"',
   LCER LITERALLY '"33"',
   HER  LITERALLY '"34"',
   LER  LITERALLY '"38"',
   CER  LITERALLY '"39"',
   AER  LITERALLY '"3A"',
   SER  LITERALLY '"3B"',
   MER  LITERALLY '"3C"',
   DER  LITERALLY '"3D"',
   AUR  LITERALLY '"3E"',
   SUR  LITERALLY '"3F"',
   STH  LITERALLY '"40"',
   STC  LITERALLY '"42"',
   IC   LITERALLY '"43"',
   EX   LITERALLY '"44"',
   BAL  LITERALLY '"45"',
   BCT  LITERALLY '"46"',
   LH   LITERALLY '"48"',
   CVD  LITERALLY '"4E"',
   CVB  LITERALLY '"4F"',
   STD  LITERALLY '"60"',
   LD   LITERALLY '"68"',
   CD   LITERALLY '"69"',
   AD   LITERALLY '"6A"',
   SD   LITERALLY '"6B"',
   MD   LITERALLY '"6C"',
   DD   LITERALLY '"6D"',
   AW   LITERALLY '"6E"',
   SW   LITERALLY '"6F"',
   STE  LITERALLY '"70"',
   LE   LITERALLY '"78"',
   CE   LITERALLY '"79"',
   AE   LITERALLY '"7A"',
   SE   LITERALLY '"7B"',
   ME   LITERALLY '"7C"',
   DE   LITERALLY '"7D"',
   AU   LITERALLY '"7E"',
   SU   LITERALLY '"7F"',
   SSM  LITERALLY '"80"',
   LPSW LITERALLY '"82"',
   WRD  LITERALLY '"84"',
   RDD  LITERALLY '"85"',
   BXH  LITERALLY '"86"',
   BXLE LITERALLY '"87"',
   STM  LITERALLY '"90"',
   MVI  LITERALLY '"92"',
   TS   LITERALLY '"93"',
   LM   LITERALLY '"98"',
   SIO  LITERALLY '"9C"',
   TIO  LITERALLY '"9D"',
   HIO  LITERALLY '"9E"',
   TCH  LITERALLY '"9F"',
   MVN  LITERALLY '"D1"',
   MVC  LITERALLY '"D2"',
   MVZ  LITERALLY '"D3"',
   ED   LITERALLY '"DE"',
   EDMK LITERALLY '"DF"',
   MVO  LITERALLY '"F1"',
   PACK LITERALLY '"F2"',
   UNPK LITERALLY '"F3"',
   ZAP  LITERALLY '"F8"',
   CP   LITERALLY '"F9"',
   AP   LITERALLY '"FA"',
   SP   LITERALLY '"FB"',
   MP   LITERALLY '"FC"',
   DP   LITERALLY '"FD"';
*/

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

FAIL_LOAD_HEADER: PROCEDURE(MNEMONIC);
      DECLARE MNEMONIC CHARACTER;

      LINE = '*** ' || MNEMONIC;
      LINE = LINE || SUBSTR('         FAIL ', LENGTH(LINE));
   END FAIL_LOAD_HEADER;

FAIL_HEADER: PROCEDURE(MNEMONIC, A, TEXT_CODE, B);
      DECLARE (A, B) FIXED;
      DECLARE (MNEMONIC, TEXT_CODE) CHARACTER;

      LINE = '*** ' || MNEMONIC;
      LINE = LINE || SUBSTR('         FAIL ', LENGTH(LINE)) || HEX(A, 32)
         || TEXT_CODE || HEX(B, 32);
   END FAIL_HEADER;

FAIL_RESULT: PROCEDURE(EXPECTED, GOT);
      DECLARE (EXPECTED, GOT) FIXED;

      LINE = LINE || ' = ' || HEX(EXPECTED, 32);
      IF EXPECTED = GOT THEN LINE = LINE || '              ';
      ELSE LINE = LINE || ' GOT: ' || HEX(GOT, 32);
   END FAIL_RESULT;

FAIL_SINGLE: PROCEDURE(EXPECTED, GOT);
      DECLARE (EXPECTED, GOT) FIXED;

      LINE = LINE || HEX(EXPECTED, 32);
      IF EXPECTED = GOT THEN LINE = LINE || '              ';
      ELSE LINE = LINE || ' GOT: ' || HEX(GOT, 32);
   END FAIL_SINGLE;

FAIL_CONDITION: PROCEDURE(EXPECTED, GOT);
      DECLARE (EXPECTED, GOT) FIXED;

      IF EXPECTED = GOT THEN LINE = LINE || ' CC=' || EXPECTED;
      ELSE LINE = LINE || ' CC=' || EXPECTED || ' GOT: CC=' || GOT;
      OUTPUT = LINE;
      ERROR_COUNT = ERROR_COUNT + 1;
   END FAIL_CONDITION;

FAIL_DONE: PROCEDURE;
      OUTPUT = LINE;
      ERROR_COUNT = ERROR_COUNT + 1;
   END FAIL_DONE;

FAIL_64_32_HEADER: PROCEDURE(MNEMONIC, A1, A2, TEXT_CODE, B);
      DECLARE (A1, A2, B) FIXED;
      DECLARE (MNEMONIC, TEXT_CODE) CHARACTER;

      LINE = '*** ' || MNEMONIC;
      LINE = LINE || SUBSTR('         FAIL ', LENGTH(LINE))
         || HEX(A1, 32) || '_' || HEX(A2, 32) || TEXT_CODE
         || HEX(B, 32);
   END FAIL_64_32_HEADER;

FAIL_64_8_HEADER: PROCEDURE(MNEMONIC, A1, A2, TEXT_CODE, B);
      DECLARE (A1, A2, B) FIXED;
      DECLARE (MNEMONIC, TEXT_CODE) CHARACTER;

      LINE = '*** ' || MNEMONIC;
      LINE = LINE || SUBSTR('         FAIL ', LENGTH(LINE))
         || HEX(A1, 32) || '_' || HEX(A2, 32) || TEXT_CODE
         || HEX(B, 8);
   END FAIL_64_8_HEADER;

FAIL_64_64_HEADER: PROCEDURE(MNEMONIC, A1, A2, TEXT_CODE, B1, B2);
      DECLARE (A1, A2, B1, B2) FIXED;
      DECLARE (MNEMONIC, TEXT_CODE) CHARACTER;

      LINE = '*** ' || MNEMONIC;
      LINE = LINE || SUBSTR('         FAIL ', LENGTH(LINE))
         || HEX(A1, 32) || '_' || HEX(A2, 32) || TEXT_CODE
         || HEX(B1, 32) || '_' || HEX(B2, 32);
   END FAIL_64_64_HEADER;

FAIL_64_RESULT: PROCEDURE(X1, X2, G1, G2);
      DECLARE (X1, X2, G1, G2) FIXED;

      LINE = LINE || ' = ' || HEX(X1, 32) || '_' || HEX(X2, 32);
      IF X1 = G1 & X2 = G2 THEN LINE = LINE || '                       ';
      ELSE LINE = LINE || ' GOT: ' || HEX(G1, 32) || '_' || HEX(G2, 32);
   END FAIL_64_RESULT;

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

CC_WITHOUT_OVERFLOW:
   PROCEDURE(C) FIXED;
      DECLARE (C, CC) FIXED;

      CC = 0;
      IF C = 0 THEN CC = CC_EQ;
      IF C < 0 THEN CC = CC_LT;
      IF C > 0 THEN CC = CC_GT;
      RETURN CC;
   END CC_WITHOUT_OVERFLOW;

CC_COMPARE:
   PROCEDURE(A, B) FIXED;
      DECLARE (A, B, CC) FIXED;

      CC = 0;
      IF A = B THEN CC = CC_EQ;
      IF A < B THEN CC = CC_LT;
      IF A > B THEN CC = CC_GT;
      RETURN CC;
   END CC_COMPARE;

CC_WITH_OVERFLOW:
   PROCEDURE(A, B, C) FIXED;
      DECLARE (A, B, C, N, CC) FIXED;

      N = (SHR(A, 29) & 4) + (SHR(B, 30) & 2) + (SHR(C, 31) & 1);
      IF N = 1 | N = 6 THEN CC = CC_OV;
      ELSE DO;
         IF C = 0 THEN CC = CC_EQ;
         IF C < 0 THEN CC = CC_LT;
         IF C > 0 THEN CC = CC_GT;
      END;
      RETURN CC;
   END CC_WITH_OVERFLOW;

CC_ADD_CARRY:
   PROCEDURE(A, B, C) FIXED;
      DECLARE (A, B, C, N, CC) FIXED;

      N = (SHR(A, 29) & 4) + (SHR(B, 30) & 2) + (SHR(C, 31) & 1);
      IF (SHR("(1)11010100", N) & 1) = 1 THEN DO;
          /* CARRY */
          IF C = 0 THEN CC = CC2;
          ELSE CC = CC3;
      END;
      ELSE DO;
          /* NO CARRY */
          IF C = 0 THEN CC = CC0;
          ELSE CC = CC1;
      END;
      RETURN CC;
   END CC_ADD_CARRY;

CC_SUBTRACT_CARRY:
   PROCEDURE(A, B, C) FIXED;
      DECLARE (A, B, C, N, CC) FIXED;

      N = (SHR(A, 29) & 4) + (SHR(~B, 30) & 2) + (SHR(C, 31) & 1);
      CC = 0;
      IF (SHR("(1)11010100", N) & 1) = 1 THEN DO;
          /* CARRY */
          IF C = 0 THEN CC = CC2;
          ELSE CC = CC3;
      END;
      ELSE DO;
          /* NO CARRY */
          IF C ~= 0 THEN CC = CC1;
      END;
      RETURN CC;
   END CC_SUBTRACT_CARRY;

TEST_ADD: PROCEDURE;
      DECLARE (I, J, CODE, VALUE) FIXED;
      DECLARE (A, B) FIXED;
      DECLARE NCC FIXED;
      DECLARE H BIT(16);

      OUTPUT = 'TESTING ADD';
      K = 0;
      DO I = 0 TO 3;
         DO J = 0 TO 3;
            A = TV(I);
            B = TV(J);
            CODE = CC_WITH_OVERFLOW(A, B, A + B);
            /*
            ** ADD (RX)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_A, 1, 0, B);         /* RX */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= ADD_REFERENCE(K) | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('A', A, '+', B);
                CALL FAIL_RESULT(ADD_REFERENCE(K), VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            /*
            ** ADD (RR)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_L, 2, 0, B);
            CALL INLINE(OP_AR, 1, 2);         /* RR */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= ADD_REFERENCE(K) | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('AR', A, '+', B);
                CALL FAIL_RESULT(ADD_REFERENCE(K), VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            /*
            ** ADD HALFWORD (RX)
            */
            A = TV(I);
            H = HTV(J);
            CODE = CC_WITH_OVERFLOW(A, H, A + H);
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_AH, 1, 0, H);         /* RX */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= ADD_HALF_REFERENCE(K) | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('AH', A, '+', H);
                CALL FAIL_RESULT(ADD_HALF_REFERENCE(K), VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            A = TV(I);
            B = TV(J);
            CODE = CC_ADD_CARRY(A, B, A + B);
            /*
            ** ADD LOGICAL (RX)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_AL, 1, 0, B);         /* RX */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= ADD_REFERENCE(K) | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('AL', A, '+', B);
                CALL FAIL_RESULT(ADD_REFERENCE(K), VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            /*
            ** ADD LOGICAL (RR)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_L, 2, 0, B);
            CALL INLINE(OP_ALR, 1, 2);         /* RR */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= ADD_REFERENCE(K) | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('ALR', A, '+', B);
                CALL FAIL_RESULT(ADD_REFERENCE(K), VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            K = K + 1;
         END;
      END;
   END TEST_ADD;

TEST_COMPARE: PROCEDURE;
      DECLARE (I, CODE) FIXED;
      DECLARE (A, B) FIXED;
      DECLARE NCC FIXED;
      DECLARE H BIT(16);

      OUTPUT = 'TESTING ARITHMETIC COMPARE';
      DO I = 0 TO 3;
         DO J = 0 TO 3;
            A = TV(I);
            B = TV(J);
            CODE = CC_COMPARE(A, B);
            /*
            ** COMPARE (RX)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_C, 1, 0, B);         /* RX */
            NCC = CONDITION_CODES;

            IF NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('C', A, '-', B);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            /*
            ** COMPARE HALFWORD (RX)
            */
            A = TV(I);
            H = HTV(J);
            CODE = CC_COMPARE(A, H);
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_CH, 1, 0, H);         /* RX */
            NCC = CONDITION_CODES;

            IF NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('CH', A, '-', H);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
         END;
      END;
      DO I = 0 TO 3;
         DO J = 0 TO 3;
            A = TV(I);
            B = TV(J);
            CODE = CC_COMPARE(A, B);
            /*
            ** COMPARE (RR)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_L, 2, 0, B);
            CALL INLINE(OP_CR, 1, 2);         /* RR */
            NCC = CONDITION_CODES;

            IF NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('CR', A, '-', B);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            /*
            ** COMPARE HALFWORD (RX)
            */
            A = TV(I);
            H = HTV(J);
            CODE = CC_COMPARE(A, H);
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_CH, 1, 0, H);         /* RX */
            NCC = CONDITION_CODES;

            IF NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('CH', A, '-', H);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
         END;
      END;
   END TEST_COMPARE;

TEST_LOGICAL_COMPARE: PROCEDURE;
      DECLARE (I, CODE) FIXED;
      DECLARE (A, B) FIXED;
      DECLARE NCC FIXED;

      OUTPUT = 'TESTING LOGICAL COMPARE';
      DO I = 0 TO 3;
         DO J = 0 TO 3;
            A = TV(I);
            B = TV(J);
            /* FLIP THE SIGN BITS TO GET AN UNSIGNED COMPARE */
            CODE = CC_COMPARE(A + MSBIT, B + MSBIT);
            /*
            ** COMPARE UNSIGNED (RR)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_L, 2, 0, B);
            CALL INLINE(OP_CLR, 1, 2);         /* RR */
            NCC = CONDITION_CODES;

            IF NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('CLR', A, '-', B);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            /*
            ** COMPARE UNSIGNED (RX)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_CL, 1, 0, B);         /* RX */
            NCC = CONDITION_CODES;

            IF NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('CL', A, '-', B);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
         END;
      END;
      DO I = 0 TO 4;
            DECLARE CB(4) BIT(8) INITIAL(0, 252, 253, 254, 255);
            DECLARE ABYTE BIT(8);

            /*
            ** COMPARE IMMEDIATE UNSIGNED (SI)
            */
            A = CB(I);
            B = 254;
            CODE = CC_COMPARE(A, B);
            ABYTE = A;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_CLI, 15, 14, ABYTE);         /* SI */
            NCC = CONDITION_CODES;

            IF NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('CLI', A, '-', B);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
      END;
      DO;
            DECLARE BB(16) BIT(8) INITIAL(1, 2, 3, 4, 5, 6, 7, 8, 9,
                10, 11, 12, 13, 14, 15, 16);

            A = BB(0);
            B = BB(1);
            CODE = CC_LT;
            /*
            ** COMPARE LOGICAL CHARACTER (SS)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_LA, 1, 0, BB);
            CALL INLINE(OP_LA, 2, 0, 1, 1);
            CALL INLINE(OP_CLC, 0, 8, 1, 0, 2, 0);         /* SS */
            NCC = CONDITION_CODES;

            IF NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('CLC', A, '-', B);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            A = BB(0);
            B = BB(0);
            CODE = CC_EQ;
            /*
            ** COMPARE LOGICAL CHARACTER (SS)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_LA, 1, 0, BB);
            CALL INLINE(OP_CLC, 0, 8, 1, 0, 1, 0);         /* SS */
            NCC = CONDITION_CODES;

            IF NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('CLC', A, '-', B);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            A = BB(1);
            B = BB(0);
            CODE = CC_GT;
            /*
            ** COMPARE LOGICAL CHARACTER (SS)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_LA, 1, 0, BB);
            CALL INLINE(OP_LA, 2, 0, 1, 1);
            CALL INLINE(OP_CLC, 0, 8, 2, 0, 1, 0);         /* SS */
            NCC = CONDITION_CODES;

            IF NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('CLC', A, '-', B);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
      END;
   END TEST_LOGICAL_COMPARE;

TEST_SUBTRACT: PROCEDURE;
      DECLARE (I, J, CODE, VALUE) FIXED;
      DECLARE (A, B) FIXED;
      DECLARE NCC FIXED;
      DECLARE H BIT(16);

      OUTPUT = 'TESTING SUBTRACT';
      K = 0;
      DO I = 0 TO 3;
         DO J = 0 TO 3;
            A = TV(I);
            B = TV(J);
            CODE = CC_WITH_OVERFLOW(A, ~B, A - B);
            /*
            ** SUBTRACT (RX)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_S, 1, 0, B);         /* RX */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= SUBTRACT_REFERENCE(K) | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('S', A, '-', B);
                CALL FAIL_RESULT(SUBTRACT_REFERENCE(K), VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            /*
            ** SUBTRACT (RR)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_L, 2, 0, B);
            CALL INLINE(OP_SR, 1, 2);         /* RR */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= SUBTRACT_REFERENCE(K) | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('SR', A, '-', B);
                CALL FAIL_RESULT(SUBTRACT_REFERENCE(K), VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            /*
            ** SUBTRACT HALFWORD (RX)
            */
            A = TV(I);
            H = HTV(J);
            CODE = CC_WITH_OVERFLOW(A, ~H, A - H);
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_SH, 1, 0, H);         /* RX */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= SUBTRACT_HALF_REFERENCE(K) | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('SH', A, '-', H);
                CALL FAIL_RESULT(SUBTRACT_HALF_REFERENCE(K), VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            A = TV(I);
            B = TV(J);
            CODE = CC_SUBTRACT_CARRY(A, B, A - B);
            /*
            ** SUBTRACT LOGICAL (RX)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_SL, 1, 0, B);         /* RX */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= SUBTRACT_REFERENCE(K) | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('SL', A, '-', B);
                CALL FAIL_RESULT(SUBTRACT_REFERENCE(K), VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            K = K + 1;
         END;
      END;
   END TEST_SUBTRACT;

TEST_LOAD: PROCEDURE;
      DECLARE LOAD_TEST(3) FIXED INITIAL("80000000", "FFFFFFFF", 0, "7FFFFFFF");
      DECLARE CC_LTR(3) FIXED INITIAL(CC1, CC1, CC0, CC2);
      DECLARE CC_LCR(3) FIXED INITIAL(CC_OV, CC_GT, CC_EQ, CC_LT);
      DECLARE CC_LPR(3) FIXED INITIAL(CC_OV, CC_GT, CC_EQ, CC_GT);
      DECLARE CC_LNR(3) FIXED INITIAL(CC_LT, CC_LT, CC_EQ, CC_LT);
      DECLARE (I, A, B, CODE, VALUE) FIXED;
      DECLARE NCC FIXED;

      OUTPUT = 'TESTING LOAD';
      DO I = 0 TO 3;
            A = LOAD_TEST(I);
            /*
            ** LOAD AND TEST (RR)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, A);
            CALL INLINE(OP_LTR, 1, 2);         /* RR */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;
            CODE = CC_LTR(I);

            IF VALUE ~= A | NCC ~= CODE THEN DO;
                CALL FAIL_LOAD_HEADER('LTR');
                CALL FAIL_SINGLE(A, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            /*
            ** LOAD COMPLEMENT (RR)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, A);
            CALL INLINE(OP_LCR, 1, 2);         /* RR */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;
            CODE = CC_LCR(I);
            B = ZERO - A;

            IF VALUE ~= B | NCC ~= CODE THEN DO;
                CALL FAIL_LOAD_HEADER('LCR');
                CALL FAIL_SINGLE(B, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            /*
            ** LOAD POSITIVE (RR)
            */
            CODE = CC_LPR(I);
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, A);
            CALL INLINE(OP_LPR, 1, 2);         /* RR */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;
            IF A >= 0 THEN B = A;
            ELSE B = ZERO - A;

            IF VALUE ~= B | NCC ~= CODE THEN DO;
                CALL FAIL_LOAD_HEADER('LPR');
                CALL FAIL_SINGLE(B, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            /*
            ** LOAD NEGATIVE (RR)
            */
            CODE = CC_LNR(I);
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, A);
            CALL INLINE(OP_LNR, 1, 2);         /* RR */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;
            IF A < 0 THEN B = A;
            ELSE B = ZERO - A;

            IF VALUE ~= B | NCC ~= CODE THEN DO;
                CALL FAIL_LOAD_HEADER('LNR');
                CALL FAIL_SINGLE(B, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
      END;
   END TEST_LOAD;

TEST_SHIFT_LOGICAL: PROCEDURE;
      DECLARE (I, A, B, C, VALUE) FIXED;
      DECLARE POWER(64) FIXED;

      OUTPUT = 'TESTING SHIFT LOGICAL';
      A = 1;
      DO I = 0 TO 35;
            C = A + A;
            /*
            ** SHIFT LEFT LOGICAL SINGLE (RS)
            */
            CALL INLINE(OP_L, 2, 0, A);
            CALL INLINE(OP_SLL, 2, 0, 0, 1);         /* RS */
            CALL INLINE(OP_ST, 2, 0, VALUE);

            IF VALUE ~= C THEN DO;
                CALL FAIL_HEADER('SLL', A, '<<', 1);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_DONE;
            END;

            /*
            ** SHIFT LEFT LOGICAL SINGLE (RS)
            */
            B = 1;
            CALL INLINE(OP_L, 1, 0, B);
            CALL INLINE(OP_L, 2, 0, I);
            CALL INLINE(OP_SLL, 1, 0, 2, 0);         /* RS */
            CALL INLINE(OP_ST, 1, 0, VALUE);

            IF VALUE ~= A THEN DO;
                CALL FAIL_HEADER('SLL', B, '<<', I);
                CALL FAIL_RESULT(A, VALUE);
                CALL FAIL_DONE;
            END;

           /* USE ADDITION TO TEST THE SHIFT INSTRUCTION */
           A = A + A;
      END;
      A = 1;
      DO I = 0 TO 31;
            POWER(31 - I) = A;
            POWER(32 + I) = 0;
            A = A + A;
      END;
      POWER(64) = 0;
      DO I = 0 TO 35;
            /*
            ** SHIFT RIGHT LOGICAL SINGLE (RS)
            */
            A = POWER(I);
            CALL INLINE(OP_L, 2, 0, A);
            CALL INLINE(OP_SRL, 2, 0, 0, 1);         /* RS */
            CALL INLINE(OP_ST, 2, 0, VALUE);

            C = POWER(I + 1);
            IF VALUE ~= C THEN DO;
                CALL FAIL_HEADER('SRL', A, '>>', 1);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_DONE;
            END;

            /*
            ** SHIFT RIGHT LOGICAL SINGLE (RS)
            */
            A = MSBIT;
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_L, 2, 0, I);
            CALL INLINE(OP_SRL, 1, 0, 2, 0);         /* RS */
            CALL INLINE(OP_ST, 1, 0, VALUE);

            C = POWER(I);
            IF VALUE ~= C THEN DO;
                CALL FAIL_HEADER('SRL', A, '>>', I);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_DONE;
            END;
      END;
   END TEST_SHIFT_LOGICAL;

TEST_SHIFT_DOUBLE_LOGICAL: PROCEDURE;
      DECLARE (I, A1, A2, B1, B2, C1, C2, V1, V2) FIXED;
      DECLARE (P1, P2)(64) FIXED;

      OUTPUT = 'TESTING SHIFT DOUBLE LOGICAL';
      A1 = 0;
      A2 = 1;
      DO I = 0 TO 63;
            C1 = A1 + A1;
            C2 = A2 + A2;
            IF A2 = MSBIT THEN C1 = 1;
            /*
            ** SHIFT LEFT DOUBLE LOGICAL (RS)
            */
            CALL INLINE(OP_L, 2, 0, A1);
            CALL INLINE(OP_L, 3, 0, A2);
            CALL INLINE(OP_SLDL, 2, 0, 0, 1);         /* RS */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);

            IF V1 ~= C1 | V2 ~= C2 THEN DO;
                CALL FAIL_64_8_HEADER('SLDL', A1, A2, '<<', 1);
                CALL FAIL_64_RESULT(C1, C2, V1, V2);
                CALL FAIL_DONE;
            END;

            /*
            ** SHIFT LEFT DOUBLE LOGICAL (RS)
            */
            B1 = 0;
            B2 = 1;
            CALL INLINE(OP_L, 2, 0, B1);
            CALL INLINE(OP_L, 3, 0, B2);
            CALL INLINE(OP_L, 1, 0, I);
            CALL INLINE(OP_SLDL, 2, 0, 1, 0);         /* RS */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);

            IF V1 ~= A1 | V2 ~= A2 THEN DO;
                CALL FAIL_64_8_HEADER('SLDL', B1, B2, '<<', I);
                CALL FAIL_64_RESULT(A1, A2, V1, V2);
                CALL FAIL_DONE;
            END;

            A1 = C1;
            A2 = C2;
      END;
      A1 = 1;
      DO I = 0 TO 31;
            P2(31 - I) = 0;
            P1(31 - I) = A1;
            P2(63 - I) = A1;
            P1(63 - I) = 0;
            A1 = A1 + A1;
      END;
      P1(64), P2(64) = 0;
      DO I = 0 TO 63;
            /*
            ** SHIFT RIGHT DOUBLE LOGICAL (RS)
            */
            A1 = P1(I);
            A2 = P2(I);
            CALL INLINE(OP_L, 2, 0, A1);
            CALL INLINE(OP_L, 3, 0, A2);
            CALL INLINE(OP_SRDL, 2, 0, 0, 1);         /* RS */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);

            C1 = P1(I + 1);
            C2 = P2(I + 1);
            IF V1 ~= C1 | V2 ~= C2 THEN DO;
                CALL FAIL_64_8_HEADER('SRDL', A1, A2, '>>', 1);
                CALL FAIL_64_RESULT(C1, C2, V1, V2);
                CALL FAIL_DONE;
            END;

            /*
            ** SHIFT RIGHT DOUBLE LOGICAL (RS)
            */
            A1 = MSBIT;
            A2 = 0;
            CALL INLINE(OP_L, 2, 0, A1);
            CALL INLINE(OP_L, 3, 0, A2);
            CALL INLINE(OP_L, 1, 0, I);
            CALL INLINE(OP_SRDL, 2, 0, 1, 0);         /* RS */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);

            C1 = P1(I);
            C2 = P2(I);
            IF V1 ~= C1 | V2 ~= C2 THEN DO;
                CALL FAIL_64_8_HEADER('SRDL', A1, A2, '>>', I);
                CALL FAIL_64_RESULT(C1, C2, V1, V2);
                CALL FAIL_DONE;
            END;
      END;
   END TEST_SHIFT_DOUBLE_LOGICAL;

TEST_SHIFT_LEFT_ARITHMETIC: PROCEDURE;
      DECLARE (I, A, B, C, NV, CODE, VALUE, MASK) FIXED;
      DECLARE NCC FIXED;

      OUTPUT = 'TESTING SHIFT LEFT ARITHMETIC';
      A = 1;
      DO I = 0 TO 32;
            /* THE SIGN BIT IS STICKY */
            C = (A & MSBIT) | ((A + A) & "7FFFFFFF");
            CODE = CC_WITHOUT_OVERFLOW(C);
            IF C ~= (A + A) THEN CODE = CC_OV;
            /*
            ** SHIFT LEFT ARITHMETIC SINGLE (RS)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, A);
            CALL INLINE(OP_SLA, 2, 0, 0, 1);         /* RS */
            CALL INLINE(OP_ST, 2, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= C | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('SLA', A, '<<', 1);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /* THE SIGN BIT IS STICKY */
            NV = -A;
            C = (NV & MSBIT) | ((NV + NV) & "7FFFFFFF");
            CODE = CC_WITHOUT_OVERFLOW(C);
            IF C ~= (NV + NV) THEN CODE = CC_OV;
            /*
            ** SHIFT LEFT ARITHMETIC SINGLE (RS)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, NV);
            CALL INLINE(OP_SLA, 2, 0, 0, 1);         /* RS */
            CALL INLINE(OP_ST, 2, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= C | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('SLA', NV, '<<', 1);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

           /* USE ADDITION TO TEST THE SHIFT INSTRUCTION */
           A = A + A;
      END;
      /* THE TESTS IN THE PREVIOUS LOOP SHOULD PASS BEFORE THIS LOOP IS RUN. */
      MASK = MSBIT;
      DO B = 0 TO 33;
            A = 255;
            NV = SHL(A, B);
            C = NV & "7FFFFFFF";  /* THE SIGN BIT IS STICKY */
            CODE = CC_WITHOUT_OVERFLOW(C);
            IF (A & MASK) ~= 0 THEN CODE = CC_OV;
            /*
            ** SHIFT LEFT ARITHMETIC SINGLE (RS)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_L, 2, 0, B);
            CALL INLINE(OP_SLA, 1, 0, 2, 0);         /* RS */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= C | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('SLA', A, '<<', B);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            A = "FFFFFF01";
            C = SHL(A, B) | MSBIT;  /* THE SIGN BIT IS STICKY */
            IF (A & MASK) = MASK THEN CODE = CC_LT;
            ELSE CODE = CC_OV;
            /*
            ** SHIFT LEFT ARITHMETIC SINGLE (RS)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_L, 2, 0, B);
            CALL INLINE(OP_SLA, 1, 0, 2, 0);         /* RS */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= C | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('SLA', A, '<<', B);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
            MASK = SHR(MASK, 1) | MSBIT;
      END;
   END TEST_SHIFT_LEFT_ARITHMETIC;

TEST_SHIFT_RIGHT_ARITHMETIC: PROCEDURE;
      DECLARE (I, A, C, CODE, VALUE) FIXED;
      DECLARE NCC FIXED;
      DECLARE POWER(64) FIXED;

      OUTPUT = 'TESTING SHIFT RIGHT ARITHMETIC';
      A = 1;
      DO I = 0 TO 31;
            POWER(31 - I) = A;
            POWER(32 + I) = 0;
            A = A + A;
      END;
      POWER(64) = 0;
      DO I = 0 TO 35;
            A = POWER(I);
            C = POWER(I + 1);
            IF A < 0 THEN C = -C;
            CODE = CC_WITHOUT_OVERFLOW(C);
            /*
            ** SHIFT RIGHT ARITHMETIC SINGLE (RS)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, A);
            CALL INLINE(OP_SRA, 2, 0, 0, 1);         /* RS */
            CALL INLINE(OP_ST, 2, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= C | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('SRA', A, '>>', 1);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
      END;
      A = MSBIT;
      DO I = 0 TO 35;
            C = -POWER(I);
            IF I >= 32 THEN C = -1;
            CODE = CC_WITHOUT_OVERFLOW(C);
            /*
            ** SHIFT RIGHT ARITHMETIC SINGLE (RS)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, A);
            CALL INLINE(OP_L, 1, 0, I);
            CALL INLINE(OP_SRA, 2, 0, 1, 0);         /* RS */
            CALL INLINE(OP_ST, 2, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= C | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('SRA', A, '>>', I);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
      END;
      A = "40000000";
      DO I = 0 TO 35;
            C = POWER(I + 1);
            CODE = CC_WITHOUT_OVERFLOW(C);
            /*
            ** SHIFT RIGHT ARITHMETIC SINGLE (RS)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, A);
            CALL INLINE(OP_L, 1, 0, I);
            CALL INLINE(OP_SRA, 2, 0, 1, 0);         /* RS */
            CALL INLINE(OP_ST, 2, 0, VALUE);
            NCC = CONDITION_CODES;

            IF VALUE ~= C | NCC ~= CODE THEN DO;
                CALL FAIL_HEADER('SRA', A, '>>', I);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
      END;
   END TEST_SHIFT_RIGHT_ARITHMETIC;

TEST_SHIFT_DOUBLE_ARITHMETIC: PROCEDURE;
      DECLARE (I, K, A1, A2, B1, B2, C1, C2, V1, V2, W1, W2) FIXED;
      DECLARE (CODE, NCC) FIXED;
      DECLARE (P1, P2)(65) FIXED;

      OUTPUT = 'TESTING SHIFT DOUBLE ARITHMETIC';
      A1 = 0;
      A2 = 1;
      K = 256;
      DO I = 0 TO 63;
            C1 = A1 + A1;
            C2 = A2 + A2;

            IF A2 = MSBIT THEN C1 = 1;
            IF (C1 & MSBIT) ~= 0 THEN DO;
               CODE = CC_OV;
               C1 = C1 & "7FFFFFFF";
            END;
            ELSE
            IF C1 < 0 THEN CODE = CC_LT;
            ELSE
            IF (C1 | C2) = 0 THEN CODE = CC_EQ;
            ELSE CODE = CC_GT;
            /*
            ** SHIFT LEFT DOUBLE ARITHMETIC (RS)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, A1);
            CALL INLINE(OP_L, 3, 0, A2);
            CALL INLINE(OP_SLDA, 2, 0, 0, 1);         /* RS */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);
            NCC = CONDITION_CODES;

            IF C1 ~= V1 | C2 ~= V2 | CODE ~= NCC THEN DO;
                CALL FAIL_64_8_HEADER('SLDA', A1, A2, '<<', 1);
                CALL FAIL_64_RESULT(C1, C2, V1, V2);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            IF I = 63 THEN CODE = CC_OV;
            ELSE
            IF (A1 | A2) = 0 THEN CODE = CC_EQ;
            ELSE CODE = CC_GT;
            /*
            ** SHIFT LEFT DOUBLE ARITHMETIC (RS)
            */
            B1 = 0;
            B2 = 1;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, B1);
            CALL INLINE(OP_L, 3, 0, B2);
            CALL INLINE(OP_L, 1, 0, I);
            CALL INLINE(OP_SLDA, 2, 0, 1, 0);         /* RS */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);
            NCC = CONDITION_CODES;

            IF A1 ~= V1 | A2 ~= V2 | CODE ~= NCC THEN DO;
                CALL FAIL_64_8_HEADER('SLDA', B1, B2, '<<', I);
                CALL FAIL_64_RESULT(A1, A2, V1, V2);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            W1 = (K + A1) & "7FFFFFFF";
            W2 = A2;
            IF I >= 23 THEN CODE = CC_OV;
            ELSE
            IF (W1 | W2) = 0 THEN CODE = CC_EQ;
            ELSE CODE = CC_GT;
            /*
            ** SHIFT LEFT DOUBLE ARITHMETIC (RS)
            */
            B1 = 256;
            B2 = 1;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, B1);
            CALL INLINE(OP_L, 3, 0, B2);
            CALL INLINE(OP_L, 1, 0, I);
            CALL INLINE(OP_SLDA, 2, 0, 1, 0);         /* RS */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);
            NCC = CONDITION_CODES;

            IF W1 ~= V1 | W2 ~= V2 | CODE ~= NCC THEN DO;
                CALL FAIL_64_8_HEADER('SLDA', B1, B2, '<<', I);
                CALL FAIL_64_RESULT(W1, W2, V1, V2);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            W1 = (A1 - K) | MSBIT;
            W2 = A2;
            IF I >= 24 THEN CODE = CC_OV;
            ELSE CODE = CC_LT;
            /*
            ** SHIFT LEFT DOUBLE ARITHMETIC (RS)
            */
            B1 = -256;
            B2 = 1;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, B1);
            CALL INLINE(OP_L, 3, 0, B2);
            CALL INLINE(OP_L, 1, 0, I);
            CALL INLINE(OP_SLDA, 2, 0, 1, 0);         /* RS */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);
            NCC = CONDITION_CODES;

            IF W1 ~= V1 | W2 ~= V2 | CODE ~= NCC THEN DO;
                CALL FAIL_64_8_HEADER('SLDA', B1, B2, '<<', I);
                CALL FAIL_64_RESULT(W1, W2, V1, V2);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            K = K + K;
            A1 = C1;
            A2 = C2;
      END;
      A1 = 1;
      DO I = 0 TO 31;
            P2(31 - I) = 0;
            P1(31 - I) = A1;
            P2(63 - I) = A1;
            P1(63 - I) = 0;
            A1 = A1 + A1;
      END;
      P1(64), P2(64) = 0;
      P1(65), P2(65) = 0;
      DO I = 0 TO 63;
            /*
            ** SHIFT RIGHT DOUBLE ARITHMETIC (RS)
            */
            A1 = P1(I);
            A2 = P2(I);
            IF A1 = MSBIT THEN C1 = "C0000000";
            ELSE C1 = P1(I + 1);
            C2 = P2(I + 1);
            IF C1 < 0 THEN CODE = CC_LT;
            ELSE
            IF (C1 | C2) = 0 THEN CODE = CC_EQ;
            ELSE CODE = CC_GT;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, A1);
            CALL INLINE(OP_L, 3, 0, A2);
            CALL INLINE(OP_SRDA, 2, 0, 0, 1);         /* RS */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);
            NCC = CONDITION_CODES;

            IF C1 ~= V1 | C2 ~= V2 | CODE ~= NCC THEN DO;
                CALL FAIL_64_8_HEADER('SRDA', A1, A2, '>>', 1);
                CALL FAIL_64_RESULT(C1, C2, V1, V2);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** SHIFT RIGHT DOUBLE ARITHMETIC (RS)
            */
            A1 = MSBIT;
            A2 = 0;
            IF P1(I) = 0 THEN C1 = -1;
            ELSE C1 = -P1(I);
            C2 = -P2(I);
            CODE = CC_LT;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, A1);
            CALL INLINE(OP_L, 3, 0, A2);
            CALL INLINE(OP_L, 1, 0, I);
            CALL INLINE(OP_SRDA, 2, 0, 1, 0);         /* RS */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);
            NCC = CONDITION_CODES;

            IF C1 ~= V1 | C2 ~= V2 | CODE ~= NCC THEN DO;
                CALL FAIL_64_8_HEADER('SRDA', A1, A2, '>>', I);
                CALL FAIL_64_RESULT(C1, C2, V1, V2);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** SHIFT RIGHT DOUBLE ARITHMETIC (RS)
            */
            A1 = "60000000";
            A2 = MSBIT;
            C1 = P1(I + 1) + P1(I + 2);
            C2 = P2(I + 1) + P2(I + 2);
            IF I < 32 THEN C2 = C2 | P1(I);
            IF (C1 | C2) = 0 THEN CODE = CC_EQ;
            ELSE CODE = CC_GT;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 2, 0, A1);
            CALL INLINE(OP_L, 3, 0, A2);
            CALL INLINE(OP_L, 1, 0, I);
            CALL INLINE(OP_SRDA, 2, 0, 1, 0);         /* RS */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);
            NCC = CONDITION_CODES;

            IF C1 ~= V1 | C2 ~= V2 | CODE ~= NCC THEN DO;
                CALL FAIL_64_8_HEADER('SRDA', A1, A2, '>>', I);
                CALL FAIL_64_RESULT(C1, C2, V1, V2);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
      END;
   END TEST_SHIFT_DOUBLE_ARITHMETIC;

TEST_MULTIPLY: PROCEDURE;
      DECLARE (I, A, B, C1, C2, V1, V2) FIXED;
      DECLARE H BIT(16);
      DECLARE MP1(5) FIXED INITIAL("075BCD15", "40000000", "C0000000",
            "40000000", "C0000000", "FFFFFFFF"),
         MP2(5) FIXED INITIAL("075BCD15", "40000000", "C0000000",
            "C0000000", "40000000", "7FFFFFFF"),
         P1(5) FIXED INITIAL ("00362622", "10000000", "10000000",
            "F0000000", "F0000000", "FFFFFFFF"),
         P2(5) FIXED INITIAL ("9738A3B9", "00000000", "00000000",
            "00000000", "00000000", "80000001"),
         MH(5) BIT(16) INITIAL("2B67", "4000", "C000", "C000", "4000",
            "7FFF"),
         HR(5) FIXED INITIAL("61620A73", "00000000", "00000000",
            "00000000", "00000000", "FFFF8001");

      OUTPUT = 'TESTING MULTIPLY';
      DO I = 0 TO 5;
            C1 = P1(I);
            C2 = P2(I);
            A = MP1(I);
            B = MP2(I);
            /*
            ** MULTIPLY (RR)
            **
            ** THE MULTIPLICAND IS IN THE ODD DOUBLE REGISTER PAIR.
            ** THE PRODUCT IS 64 BITS.
            */
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_L, 3, 0, B);
            CALL INLINE(OP_MR, 2, 1);         /* RR */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);

            IF C1 ~= V1 | C2 ~= V2 THEN DO;
                CALL FAIL_HEADER('MR', A, '*', B);
                CALL FAIL_64_RESULT(C1, C2, V1, V2);
                CALL FAIL_DONE;
            END;

            /*
            ** MULTIPLY (RX)
            **
            ** THE MULTIPLICAND IS IN THE ODD DOUBLE REGISTER PAIR.
            ** THE PRODUCT IS 64 BITS.
            */
            CALL INLINE(OP_L, 3, 0, A);
            CALL INLINE(OP_M, 2, 0, B);         /* RX */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);

            IF C1 ~= V1 | C2 ~= V2 THEN DO;
                CALL FAIL_HEADER('M', A, '*', B);
                CALL FAIL_64_RESULT(C1, C2, V1, V2);
                CALL FAIL_DONE;
            END;

            /*
            ** MULTIPLY HALFWORD (RX)
            **
            ** MULTIPLY HALFWORD PRODUCES A 32-BIT RESULT
            */
            H = MH(I);
            CALL INLINE(OP_L, 2, 0, A);
            CALL INLINE(OP_MH, 2, 0, H);         /* RX */
            CALL INLINE(OP_ST, 2, 0, V1);

            C1 = HR(I);
            IF C1 ~= V1 THEN DO;
                CALL FAIL_HEADER('MH', A, '*', H);
                CALL FAIL_RESULT(C1, V1);
                CALL FAIL_DONE;
            END;
      END;
   END TEST_MULTIPLY;

TEST_DIVIDE: PROCEDURE;
      DECLARE (I, A, B, C1, C2, V1, V2) FIXED,
      DIVIDEND(5) FIXED INITIAL(
         "7FFFFFFF", "40000022", "EFFFFEDD", "18700567", "E987FDCC", 
         "FFFFFFFF"),
      DIVISOR(5) FIXED INITIAL(
         "075BCD15", "10000000", "F0000000", "F0000000", "10000000", 
         "7FFFFFFF"),
      QUOTIENT(5) FIXED INITIAL(
         "00000011", "00000004", "00000001", "FFFFFFFF", "FFFFFFFF", 
         "00000000"),
      REMAINDER(5) FIXED INITIAL(
         "02E7619A", "00000022", "FFFFFEDD", "08700567", "F987FDCC", 
         "FFFFFFFF");

      OUTPUT = 'TESTING DIVIDE';
      DO I = 0 TO 5;
            C1 = REMAINDER(I);
            C2 = QUOTIENT(I);
            A = DIVIDEND(I);
            B = DIVISOR(I);
            /*
            ** DIVIDE (RR)
            **
            ** THE DIVIDEND IS IN THE EVEN HALF OF A 64 BIT REGISTER
            ** THE REMAINDER IS PLACED INTO THE EVEN HALF OF THE DOUBLE REGISTER
            ** THE QUOTIENT IS IN THE ODD HALF
            */
            CALL INLINE(OP_L, 2, 0, A);
            CALL INLINE(OP_SRDA, 2, 0, 0, 32);
            CALL INLINE(OP_L, 1, 0, B);
            CALL INLINE(OP_DR, 2, 1);         /* RR */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);


            IF C1 ~= V1 | C2 ~= V2 THEN DO;
                CALL FAIL_HEADER('DR', A, '/', B);
                CALL FAIL_64_RESULT(C1, C2, V1, V2);
                CALL FAIL_DONE;
            END;

            /*
            ** DIVIDE (RX)
            **
            ** THE DIVIDEND IS IN THE EVEN HALF OF A 64 BIT REGISTER
            ** THE REMAINDER IS PLACED INTO THE EVEN HALF OF THE DOUBLE REGISTER
            ** THE QUOTIENT IS IN THE ODD HALF
            */
            CALL INLINE(OP_L, 2, 0, A);
            CALL INLINE(OP_SRDA, 2, 0, 0, 32);
            CALL INLINE(OP_D, 2, 0, B);         /* RX */
            CALL INLINE(OP_ST, 2, 0, V1);
            CALL INLINE(OP_ST, 3, 0, V2);

            IF C1 ~= V1 | C2 ~= V2 THEN DO;
                CALL FAIL_HEADER('D', A, '/', B);
                CALL FAIL_64_RESULT(C1, C2, V1, V2);
                CALL FAIL_DONE;
            END;
      END;
   END TEST_DIVIDE;

DECLARE LATV(1) BIT(32) INITIAL("3C3C3C3C", 0),
   LBTV(1) BIT(32) INITIAL("0F0F0F0F", 0),
   LRCC(1) BIT(32) INITIAL(CC1, CC0);

TEST_LOGICAL_AND: PROCEDURE;
      DECLARE I FIXED;
      DECLARE (A, B, C, VALUE) FIXED;
      DECLARE (CODE, NCC) FIXED;
      DECLARE (AV, CV, VV) BIT(8);
      DECLARE LAND(1) BIT(32) INITIAL("0C0C0C0C", 0);

      OUTPUT = 'TESTING LOGICAL AND';
      DO I = 0 TO 1;
            A = LATV(I);
            B = LBTV(I);
            C = LAND(I);
            CODE = LRCC(I);

            /*
            ** LOGICAL AND (RR)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_L, 2, 0, B);
            CALL INLINE(OP_NR, 1, 2);         /* RR */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF C ~= VALUE | CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('NR', A, '&', B);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** LOGICAL AND (RX)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_N, 1, 0, B);         /* RX */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF C ~= VALUE | CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('N', A, '&', B);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** AND CHARACTER (SS)
            */
            VALUE = A;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_NC, 0, 3, VALUE, B);         /* SS */
            NCC = CONDITION_CODES;

            IF C ~= VALUE | CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('NC', A, '&', B);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** AND IMMEDIATE (SI)
            */
            AV, VV = A;
            B = "0F";
            CV = C;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_NI, 0, 15, VV);         /* SI */
            NCC = CONDITION_CODES;

            IF CV ~= VV | CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('NI', AV, '&', B);
                CALL FAIL_RESULT(CV, VV);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** TEST UNDER MASK (SI)
            */
            AV = A;
            B = "0F";
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_TM, 0, 15, AV);         /* SI */
            NCC = CONDITION_CODES;

            IF CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('TM', AV, '&', B);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** TEST UNDER MASK (SI)
            */
            AV = A;
            B = "00";
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_TM, 0, 15, AV);         /* SI */
            NCC = CONDITION_CODES;

            IF CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('TM', AV, '&', B);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** TEST UNDER MASK (SI)
            */
            AV, A = 255;
            B = "FF";
            CODE = CC3;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_TM, 15, 15, AV);         /* SI */
            NCC = CONDITION_CODES;

            IF CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('TM', AV, '&', B);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
      END;
   END TEST_LOGICAL_AND;

TEST_LOGICAL_OR: PROCEDURE;
      DECLARE I FIXED;
      DECLARE (A, B, C, VALUE) FIXED;
      DECLARE (CODE, NCC) FIXED;
      DECLARE (AV, CV, VV) BIT(8);
      DECLARE LOR(1) BIT(32) INITIAL("3F3F3F3F", 0);
      DECLARE LOI(1) BIT(8) INITIAL("3F", "0F");

      OUTPUT = 'TESTING LOGICAL OR';
      DO I = 0 TO 1;
            A = LATV(I);
            B = LBTV(I);
            C = LOR(I);
            CODE = LRCC(I);

            /*
            ** LOGICAL OR (RR)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_L, 2, 0, B);
            CALL INLINE(OP_OR, 1, 2);         /* RR */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF C ~= VALUE | CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('OR', A, '|', B);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** LOGICAL OR (RX)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_O, 1, 0, B);         /* RX */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF C ~= VALUE | CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('O', A, '|', B);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** OR CHARACTER (SS)
            */
            VALUE = A;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_OC, 0, 3, VALUE, B);         /* SS */
            NCC = CONDITION_CODES;

            IF C ~= VALUE | CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('OC', A, '|', B);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** OR IMMEDIATE (SI)
            */
            AV, VV = A;
            B = "00";
            CV = A;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_OI, 0, 0, VV);         /* SI */
            NCC = CONDITION_CODES;

            IF CV ~= VV | CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('OI', AV, '|', B);
                CALL FAIL_RESULT(CV, VV);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** OR IMMEDIATE (SI)
            */
            AV, VV = A;
            B = "0F";
            CV = LOI(I);
            CODE = CC1;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_OI, 0, 15, VV);         /* SI */
            NCC = CONDITION_CODES;

            IF CV ~= VV | CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('OI', AV, '|', B);
                CALL FAIL_RESULT(CV, VV);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
      END;
   END TEST_LOGICAL_OR;

TEST_LOGICAL_XOR: PROCEDURE;
      DECLARE I FIXED;
      DECLARE (A, B, C, VALUE) FIXED;
      DECLARE (CODE, NCC) FIXED;
      DECLARE (AV, CV, VV) BIT(8);
      DECLARE LXOR(1) BIT(32) INITIAL("33333333", 0);
      DECLARE LXOI(1) BIT(8) INITIAL("33", "0F");

      OUTPUT = 'TESTING EXCLUSIVE OR';
      DO I = 0 TO 1;
            A = LATV(I);
            B = LBTV(I);
            C = LXOR(I);
            CODE = LRCC(I);

            /*
            ** LOGICAL OR (RR)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_L, 2, 0, B);
            CALL INLINE(OP_XR, 1, 2);         /* RR */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF C ~= VALUE | CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('XR', A, '^', B);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** EXCLUSIVE OR (RX)
            */
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_L, 1, 0, A);
            CALL INLINE(OP_X, 1, 0, B);         /* RX */
            CALL INLINE(OP_ST, 1, 0, VALUE);
            NCC = CONDITION_CODES;

            IF C ~= VALUE | CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('X', A, '^', B);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** EXCLUSIVE OR CHARACTER (SS)
            */
            VALUE = A;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_XC, 0, 3, VALUE, B);         /* SS */
            NCC = CONDITION_CODES;

            IF C ~= VALUE | CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('XC', A, '^', B);
                CALL FAIL_RESULT(C, VALUE);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** EXCLUSIVE OR IMMEDIATE (SI)
            */
            AV, VV = A;
            B = "00";
            CV = A;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_XI, 0, 0, VV);         /* SI */
            NCC = CONDITION_CODES;

            IF CV ~= VV | CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('XI', AV, '^', B);
                CALL FAIL_RESULT(CV, VV);
                CALL FAIL_CONDITION(CODE, NCC);
            END;

            /*
            ** EXCLUSIVE OR IMMEDIATE (SI)
            */
            AV, VV = A;
            B = "0F";
            CV = LXOI(I);
            CODE = CC1;
            CALL ZAP_CONDITION_CODES(CODE);
            CALL INLINE(OP_XI, 0, 15, VV);         /* SI */
            NCC = CONDITION_CODES;

            IF CV ~= VV | CODE ~= NCC THEN DO;
                CALL FAIL_HEADER('XI', AV, '^', B);
                CALL FAIL_RESULT(CV, VV);
                CALL FAIL_CONDITION(CODE, NCC);
            END;
      END;
   END TEST_LOGICAL_XOR;

TEST_EXEC: PROCEDURE;
      DECLARE I FIXED;
      DECLARE (A, B, GOT_A, GOT_B, VALUE) FIXED;
      DECLARE AV BIT(8);
      DECLARE MAP(255) BIT(8);
      DECLARE CB(255) BIT(8);
      DECLARE (CODE, NCC) BIT(32);

      OUTPUT = 'TESTING EXECUTE';
      DO I = 0 TO 255;
            AV = I;

            /*
            ** EXECUTE (RX)
            */
            CALL INLINE(OP_BALR, 3, 0);
            CALL INLINE(OP_BC, 15, 3, 0, 8);
            CALL INLINE(/* MVI */ "92", 0, 0, AV);
            CALL INLINE(OP_L, 2, 0, I);
            CALL INLINE(/* EX */ "44", 2, 0, 3, 4);         /* RX */
            VALUE = AV;

            IF I ~= VALUE THEN DO;
                CALL FAIL_HEADER('EX', I, '->', I);
                CALL FAIL_RESULT(I, VALUE);
                CALL FAIL_DONE;
            END;
      END;
      OUTPUT = 'TESTING MOVE CHARACTER';
      DO I = 0 TO 255;
         CB(I) = 0;
         MAP(I) = I;
      END;
      /*
      ** MOVE CHARACTER (SS)
      */
      CALL INLINE(OP_LA, 1, 0, MAP);
      CALL INLINE(/* MVC */ "D2", 0, 15, CB, 1, 128);         /* SS */

      DO I = 0 TO 255;
         IF I >= 0 & I < 16 THEN A = I + 128;
         ELSE A = 0;
         VALUE = CB(I);
         IF A ~= VALUE THEN DO;
             CALL FAIL_HEADER('MVC', I, '->', I);
             CALL FAIL_RESULT(A, VALUE);
             CALL FAIL_DONE;
         END;
      END;

      DO I = 0 TO 255;
         MAP(I) = 255 - I;
         CB(I) = I;
      END;
      /*
      ** TRANSLATE (SS)
      */
      CALL INLINE(/* TR */ "DC", 15, 15, CB, MAP);         /* SS */

      DO I = 0 TO 255;
         A = 255 - I;
         VALUE = CB(I);
         IF A ~= VALUE THEN DO;
             CALL FAIL_HEADER('TR', A, '->', I);
             CALL FAIL_RESULT(A, VALUE);
             CALL FAIL_DONE;
         END;
      END;

      DO I = 0 TO 255;
         MAP(I) = 0;
         CB(I) = I;
      END;
      /*
      ** TRANSLATE AND TEST (SS)
      */
      A, B = 0;
      CODE = CC0;
      CALL ZAP_CONDITION_CODES(CODE);
      CALL INLINE(OP_SR, 1, 1);
      CALL INLINE(OP_SR, 2, 2);
      CALL INLINE(OP_TRT, 15, 15, CB, MAP);         /* SS */
      CALL INLINE(OP_ST, 1, 0, GOT_A);
      CALL INLINE(OP_ST, 2, 0, GOT_B);
      NCC = CONDITION_CODES;

      IF A ~= GOT_A | CODE ~= NCC THEN DO;
          CALL FAIL_HEADER('TRT', 0, '-(R1)-', 0);
          CALL FAIL_RESULT(A, GOT_A);
          CALL FAIL_CONDITION(CODE, NCC);
      END;
      IF B ~= GOT_B THEN DO;
          CALL FAIL_HEADER('TRT', 0, '-(R2)-', 0);
          CALL FAIL_RESULT(B, GOT_B);
          CALL FAIL_DONE;
      END;

      /*
      ** TRANSLATE AND TEST (SS)
      */
      MAP(255) = "FF";
      A = ADDR(CB) + 255;
      B = "FF";
      CODE = CC2;
      CALL ZAP_CONDITION_CODES(CODE);
      CALL INLINE(OP_SR, 1, 1);
      CALL INLINE(OP_SR, 2, 2);
      CALL INLINE(OP_TRT, 15, 15, CB, MAP);         /* SS */
      CALL INLINE(OP_ST, 1, 0, GOT_A);
      CALL INLINE(OP_ST, 2, 0, GOT_B);
      NCC = CONDITION_CODES;

      IF A ~= GOT_A | CODE ~= NCC THEN DO;
          CALL FAIL_HEADER('TRT', 0, '-(R1)-', 0);
          CALL FAIL_RESULT(A, GOT_A);
          CALL FAIL_CONDITION(CODE, NCC);
      END;
      IF B ~= GOT_B THEN DO;
          CALL FAIL_HEADER('TRT', 0, '-(R2)-', 0);
          CALL FAIL_RESULT(B, GOT_B);
          CALL FAIL_DONE;
      END;

      /*
      ** TRANSLATE AND TEST (SS)
      */
      MAP(255) = "42";
      A = ADDR(CB) + 255;
      A = A | "FF000000";
      B = "FFFFFF42";
      CODE = CC2;
      CALL ZAP_CONDITION_CODES(CODE);
      CALL INLINE(OP_L, 1, 0, MINUS_ONE);
      CALL INLINE(OP_L, 2, 0, MINUS_ONE);
      CALL INLINE(OP_TRT, 15, 15, CB, MAP);         /* SS */
      CALL INLINE(OP_ST, 1, 0, GOT_A);
      CALL INLINE(OP_ST, 2, 0, GOT_B);
      NCC = CONDITION_CODES;

      IF A ~= GOT_A | CODE ~= NCC THEN DO;
          CALL FAIL_HEADER('TRT', -1, '-(R1)-', -1);
          CALL FAIL_RESULT(A, GOT_A);
          CALL FAIL_CONDITION(CODE, NCC);
      END;
      IF B ~= GOT_B THEN DO;
          CALL FAIL_HEADER('TRT', -1, '-(R2)-', -1);
          CALL FAIL_RESULT(B, GOT_B);
          CALL FAIL_DONE;
      END;

      /*
      ** TRANSLATE AND TEST (SS)
      */
      MAP(254) = "06";
      A = ADDR(CB) + 254;
      A = A | "FF000000";
      B = "FFFFFF06";
      CODE = CC1;
      CALL ZAP_CONDITION_CODES(CODE);
      CALL INLINE(OP_L, 1, 0, MINUS_ONE);
      CALL INLINE(OP_L, 2, 0, MINUS_ONE);
      CALL INLINE(OP_TRT, 15, 15, CB, MAP);         /* SS */
      CALL INLINE(OP_ST, 1, 0, GOT_A);
      CALL INLINE(OP_ST, 2, 0, GOT_B);
      NCC = CONDITION_CODES;

      IF A ~= GOT_A | CODE ~= NCC THEN DO;
          CALL FAIL_HEADER('TRT', -1, '-(R1)-', -1);
          CALL FAIL_RESULT(A, GOT_A);
          CALL FAIL_CONDITION(CODE, NCC);
      END;
      IF B ~= GOT_B THEN DO;
          CALL FAIL_HEADER('TRT', -1, '-(R2)-', -1);
          CALL FAIL_RESULT(B, GOT_B);
          CALL FAIL_DONE;
      END;
   END TEST_EXEC;

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

CALL SHOW_MEMINFO;
CALL TEST_COMPARE;
CALL TEST_SUBTRACT;
CALL TEST_ADD;
CALL TEST_LOAD;
CALL TEST_SHIFT_LOGICAL;
CALL TEST_SHIFT_DOUBLE_LOGICAL;
CALL TEST_SHIFT_LEFT_ARITHMETIC;
CALL TEST_SHIFT_RIGHT_ARITHMETIC;
CALL TEST_SHIFT_DOUBLE_ARITHMETIC;
CALL TEST_MULTIPLY;
CALL TEST_DIVIDE;
CALL TEST_LOGICAL_COMPARE;
CALL TEST_LOGICAL_AND;
CALL TEST_LOGICAL_OR;
CALL TEST_LOGICAL_XOR;
CALL TEST_EXEC;

IF ERROR_COUNT = 0 THEN OUTPUT = 'PASSED';
ELSE OUTPUT = 'FAILED: ' || ERROR_COUNT || ' ERRORS';

RETURN ERROR_COUNT;

EOF;
