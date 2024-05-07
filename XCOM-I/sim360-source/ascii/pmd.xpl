   /********************************************************************
   *                                                                   *
   *                  STONY BROOK PASCAL 360 COMPILER                  *
   *                   POST MORTEM ANALYSIS ROUTINES                   *
   *                                                                   *
   ********************************************************************/

   /*

   COPYRIGHT (C) 1976 DEPARTMENT OF COMPUTER SCIENCE, SUNY AT STONY BROOK.

   */



   /* THE FOLLOWING VARIABLES ARE INITIALIZED FROM THE STATUS BLOCK, WHOSE
         ADDRESS IS INSERTED BY THE RUN MONITOR INTO MONITOR_LINK(3):
      AR_BASE_ADDR IS THE ADDRESS OF THE GLOBAL ACTIVATION RECORD.
      ORIGIN_ADDR IS THE ADDRESS OF THE ORG SEGMENT.
      TRANSFER_VECTOR_BASE_ADDR IS THE ADDRESS OF THE ORG SEGMENT TRANSFER
         VECTOR, WHICH CONTAINS THE ADDRESS OF EACH PASCAL BLOCK ENTRY POINT.
      CODE_SEG_BASE_ADDR IS THE ADDRESS OF THE PASCAL CODE SEGMENT, OVER WHICH
         THIS CODE IS OVERLAYED.
      EXECUTION_TIME IS THE CPU TIME, IN UNITS OF 0.01 SECONDS, USED BY THE
         PASCAL PROGRAM.
      ERROR_LINE IS THE SOURCE LINE NUMBER CORRESPONDING TO A RUN ERROR;
         ZERO IF THE PASCAL PROGRAM TERMINATED NORMALLY.
      CORETOP IS THE LAST ADDRESS IN THE REGION.  THE VALUE OF CORETOP
         BECOMES 'FREELIMIT' AT FLOW_SUMMARY TIME, THUS CLOBBERING THE
         ACTIVATION RECORD STACK AS WELL AS THE HEAP.
   */
   DECLARE (AR_BASE_ADDR, ORIGIN_ADDR, TRANSFER_VECTOR_BASE_ADDR,
            CODE_SEG_BASE_ADDR, EXECUTION_TIME, ERROR_LINE, CORETOP) FIXED;

   /* PASCAL_REGS IS THE ADDRESS OF A LOCATION IN THE ORG SEGMENT WHERE THE
         PASCAL REGISTERS ARE SAVED IN THE ORDER 11..15, 0..10.
      BLOCK_COUNTER_BASE_ADDR IS THE ADDRESS OF ANOTHER LOCATION IN THE ORG
         SEGMENT, WHERE THE BASIC BLOCK EXECUTION COUNTERS USED IN THE FLOW
         SUMMARY ARE FOUND.
   */
   DECLARE (PASCAL_REGS, BLOCK_COUNTER_BASE_ADDR) FIXED;

   /* THE VALUES OF THE ABOVE VARIABLES ARE SET IN INITIALIZE, AND REMAIN
      CONSTANT THEREAFTER.
   */

   /* SOME COMMONLY USED EUPHAMISMS */
   DECLARE FALSE LITERALLY '0', TRUE LITERALLY '1', FOREVER LITERALLY 'WHILE 1',
           REAL LITERALLY 'FIXED', FPR LITERALLY '6', NULL LITERALLY '-1',
           DEBUG_LEVEL LITERALLY 'MONITOR_LINK(2)';

   /* MAX_STRING_LENGTH IS THE MAXIMUM LENGTH OF AN XPL CHARACTER STRING.
   */
   DECLARE MAX_STRING_LENGTH LITERALLY '256';

   /* SOME COMMONLY USED CONSTANT STRINGS */
   DECLARE X1 CHARACTER INITIAL (' '), X70 CHARACTER INITIAL (
      '                                                                      ');

   /* THE FLOATING-POINT POWERS OF TEN(LONG).  TWO ADJACENT ENTRIES IN 'POWERS' 
      (EVEN-ODD) FORM ONE DOUBLE-PRECISION REAL.
   */
   DECLARE POWERS(307) REAL INITIAL("001DA48C", "E468E7C7", "011286D8",
      "0EC190DC", "01B94470", "938FA89C", "0273CAC6", "5C39C961", "03485EBB",
      "F9A41DDD", "042D3B35", "7C0692AA", "051C4501", "6D841BAA", "0611AB20",
      "E472914A", "06B0AF48", "EC79ACE8", "076E6D8D", "93CC0C11", "08450478",
      "7C5F878B", "092B22CB", "4DBBB4B7", "0A1AF5BF", "109550F2", "0B10D997",
      "6A5D5297", "0BA87FEA", "27A539EA", "0C694FF2", "58C74432", "0D41D1F7",
      "777C8A9F", "0E29233A", "AAADD6A4", "0F19B604", "AAACA626", "101011C2",
      "EAABE7D8", "10A0B19D", "2AB70E6F", "11646F02", "3AB26905", "123EC561",
      "64AF81A3", "13273B5C", "DEEDB106", "1418851A", "0B548EA4", "14F53304",
      "714D9266", "15993FE2", "C6D07B80", "165FC7ED", "BC424D30", "173BDCF4",
      "95A9703E", "18256A18", "DD89E627", "1917624F", "8A762FD8", "19E9D71B",
      "689DDE72", "1A922671", "2162AB07", "1B5B5806", "B4DDAAE4", "1C391704",
      "310A8ACF", "1D23AE62", "9EA696C1", "1E164CFD", "A3281E39", "1EDF01E8",
      "5F912E38", "1F8B6131", "3BBABCE3", "20571CBE", "C554B60E", "213671F7",
      "3B54F1C9", "2222073A", "8515171D", "23154484", "932D2E72", "23D4AD2D",
      "BFC3D078", "2484EC3C", "97DA624B", "255313A5", "DEE87D6F", "2633EC47",
      "AB514E65", "272073AC", "CB12D0FF", "2814484B", "FEEBC2A0", "28CAD2F7",
      "F5359A3B", "297EC3DA", "F9418065", "2A4F3A68", "DBC8F03F", "2B318481",
      "895D9627", "2C1EF2D0", "F5DA7DD9", "2D1357C2", "99A88EA7", "2DC16D9A",
      "0095928A", "2E78E480", "405D7B96", "2F4B8ED0", "283A6D3E", "302F3942",
      "19248447", "311D83C9", "4FB6D2AC", "3212725D", "D1D243AC", "32B877AA",
      "3236A4B4", "33734ACA", "5F6226F1", "34480EBE", "7B9D5856", "352D0937",
      "0D425736", "361C25C2", "68497682", "37119799", "812DEA11", "37AFEBFF",
      "0BCB24AB", "386DF37F", "675EF6EB", "3944B82F", "A09B5A53", "3A2AF31D",
      "C4611874", "3B1AD7F2", "9ABCAF48", "3C10C6F7", "A0B5ED8D", "3CA7C5AC",
      "471B4784", "3D68DB8B", "AC710CB3", "3E418937", "4BC6A7F0", "3F28F5C2",
      "8F5C28F6", "40199999", "9999999A", "41100000", "00000000", "41A00000",
      "00000000", "42640000", "00000000", "433E8000", "00000000", "44271000",
      "00000000", "45186A00", "00000000", "45F42400", "00000000", "46989680",
      "00000000", "475F5E10", "00000000", "483B9ACA", "00000000", "492540BE",
      "40000000", "4A174876", "E8000000", "4AE8D4A5", "10000000", "4B9184E7",
      "2A000000", "4C5AF310", "7A400000", "4D38D7EA", "4C680000", "4E2386F2",
      "6FC10000", "4F163457", "85D8A000", "4FDE0B6B", "3A764000", "508AC723",
      "0489E800", "5156BC75", "E2D63100", "523635C9", "ADC5DEA0", "5321E19E",
      "0C9BAB24", "54152D02", "C7E14AF7", "54D3C21B", "CECCEDA1", "55845951",
      "61401485", "5652B7D2", "DCC80CD3", "5733B2E3", "C9FD0804", "58204FCE",
      "5E3E2502", "591431E0", "FAE6D721", "59C9F2C9", "CD04674F", "5A7E37BE",
      "2022C091", "5B4EE2D6", "D415B85B", "5C314DC6", "448D9339", "5D1ED09B",
      "EAD87C03", "5E134261", "72C74D82", "5EC097CE", "7BC90716", "5F785EE1",
      "0D5DA46E", "604B3B4C", "A85A86C4", "612F050F", "E938943B", "621D6329",
      "F1C35CA5", "63125DFA", "371A19E7", "63B7ABC6", "27050306", "6472CB5B",
      "D86321E4", "6547BF19", "673DF52E", "662CD76F", "E086B93D", "671C0615",
      "EC5433C6", "68118427", "B3B4A05C", "68AF298D", "050E4396", "696D79F8",
      "2328EA3E", "6A446C3B", "15F99267", "6B2AC3A4", "EDBBFB80", "6C1ABA47",
      "14957D30", "6D10B46C", "6CDD6E3E", "6DA70C3C", "40A64E6C", "6E6867A5",
      "A867F104", "6F4140C7", "8940F6A2", "7028C87C", "B5C89A25", "71197D4D",
      "F19D6057", "71FEE50B", "7025C36A", "729F4F27", "26179A22", "73639178",
      "77CEC055", "743E3AEB", "4AE13835", "7526E4D3", "0ECCC321", "76184F03",
      "E93FF9F5", "76F31627", "1C7FC391", "7797EDD8", "71CFDA3A", "785EF4A7",
      "4721E864", "793B58E8", "8C75313F", "7A251791", "57C93EC7", "7B172EBA",
      "D6DDC73D", "7BE7D34C", "64A9C85D", "7C90E40F", "BEEA1D3A", "7D5A8E89",
      "D7525244", "7E389916", "2693736B", "7F235FAD", "D81C2823");



         /*   P R O C E D U R E S   */



DIVFLT:
   PROCEDURE (DIVIDEND, DIVISOR) REAL;
      DECLARE (DIVIDEND, DIVISOR, QUOTIENT) REAL;
      CALL INLINE("78",FPR,0,DIVIDEND);          /* LE   FPR,DIVIDEND      */
      CALL INLINE("7D",FPR,0,DIVISOR);           /* DE   FPR,DIVISOR       */
      CALL INLINE("70",FPR,0,QUOTIENT);          /* STE  FPR,QUOTIENT      */
      RETURN QUOTIENT;
   END DIVFLT;

ROUND:
   PROCEDURE(X) FIXED;
      DECLARE X REAL, WORK(4) REAL, HALF REAL INITIAL("40800000"),
              ZERO(4) REAL INITIAL("4E000000", 0, 0, "4E000000", 0);
      /* NOTE THAT IF WORK IS DOUBLE-WORD ALLIGNED, THEN SO IS ZERO. */
      DECLARE IS_ALLIGNED BIT(1), OFFSET FIXED;
      IS_ALLIGNED = ((ADDR(WORK) & "FFFFFFF8") = ADDR(WORK));
      IF IS_ALLIGNED THEN OFFSET = 0;   ELSE OFFSET = 12;
      CALL INLINE("58",2,0,OFFSET);              /* L    2,OFFSET          */
      CALL INLINE("2B",FPR,FPR);                 /* SDR  FPR,FPR           */
      CALL INLINE("78",FPR,0,X);                 /* LE   FPR,X             */
      CALL INLINE("7A",FPR,0,HALF);              /* AE   FPR,HALF          */
      CALL INLINE("6E",FPR,2,ZERO);              /* AW   FPR,ZERO(2)       */
      CALL INLINE("60",FPR,2,WORK);              /* STD  FPR,WORK(2)       */
      IF IS_ALLIGNED THEN RETURN WORK(1);   ELSE RETURN WORK(4);
   END ROUND;

I_FORMAT:
   PROCEDURE (NUMBER, WIDTH) CHARACTER;
      DECLARE (NUMBER, WIDTH, L) FIXED, STRING CHARACTER;
      STRING = NUMBER;
      L = LENGTH(STRING);
      IF L >= WIDTH THEN RETURN STRING;
      ELSE RETURN SUBSTR(X70, 0, WIDTH - L) || STRING;
   END I_FORMAT;

E_FORMAT:
   PROCEDURE (NUMBER, WIDTH) CHARACTER;
      DECLARE (NUMBER, MANTISSA) FIXED;
      DECLARE (WIDTH, EXPONENT, I, J, X) BIT(16);
      DECLARE (S, S1) CHARACTER;
      /* MINIMUM FIELD IS B+9.9E+99 */
      IF WIDTH < 9 THEN WIDTH = 9;
      /* MAXIMUM 7 SIGNIFICANT DIGITS */
      IF WIDTH > 14 THEN
         DO;
            S = SUBSTR(X70, 0, WIDTH - 13);
            WIDTH = 14;
         END;
      ELSE S = X1; /* MUST HAVE LEADING BLANK */
      IF NUMBER < 0 THEN
         DO;
            S = S || '-';
            NUMBER = NUMBER & "7FFFFFFF";
         END;
      ELSE S = S || X1;
      IF (NUMBER & "00FFFFFF") = 0 THEN
         RETURN S || SUBSTR('0.0000000', 0, WIDTH - 6) || 'E+00';
      IF NUMBER < POWERS(14) /* 10**-71 */ THEN
         DO;
            NUMBER = DIVFLT(NUMBER, POWERS(0));
            /* NUMBER = NUMBER / 10**-78 */
            EXPONENT = - 78;
         END;
      ELSE EXPONENT = 0;
      /* NOW BINARY-SEARCH THE ARRAY POWERS TO FIND X SUCH THAT
            10**X  <=  NUMBER  <  10**(X+1)  .   */
      I = 0;   J = 306;   X = 152;
      DO WHILE I <= J;
         IF POWERS(X) <= NUMBER THEN I = X + 2;
         ELSE J = X - 2;
         X = SHR(I + J, 1) & "FFFE";
      END;
      MANTISSA = ROUND(DIVFLT(NUMBER, POWERS(X - 14)));
      EXPONENT = EXPONENT + SHR(X, 1) - 78;
      S1 = MANTISSA;
      IF LENGTH(S1) > 8 THEN EXPONENT = EXPONENT + 1;
      ELSE IF LENGTH(S1) < 8 THEN EXPONENT = EXPONENT - 1;
      S = S || SUBSTR(S1, 0, 1) || '.' || SUBSTR(S1, 1, WIDTH - 8) || 'E';
      IF EXPONENT >= 0 THEN S = S || '+';
      ELSE
         DO;
            S = S || '-';
            EXPONENT = - EXPONENT;
         END;
      IF EXPONENT < 10 THEN RETURN S || '0' || EXPONENT;
      ELSE RETURN S || EXPONENT;
   END E_FORMAT;

REWIND:
   PROCEDURE (IS_OUTPUT_FILE, FILE#);
      DECLARE IS_OUTPUT_FILE BIT(1), FILE# FIXED;
      CALL INLINE("1B",0,0);                     /* SR   0,0              */
      CALL INLINE("43",0,0,IS_OUTPUT_FILE);      /* IC   0,IS_OUTPUT_FILE */
      CALL INLINE("41",1,0,0,28);                /* LA   1,28             */
      CALL INLINE("58",2,0,FILE#);               /* L    2,FILE#          */
      CALL INLINE("05",12,15);                   /* BALR 12,15            */
   END REWIND;

PRINT_TIME:
   PROCEDURE(TIME, MESSAGE);
      DECLARE (TIME, L) FIXED, (MESSAGE, STRING) CHARACTER;
      STRING = TIME;   L = LENGTH(STRING);
      IF L < 5 THEN STRING = SUBSTR('00000', 0, 5 - L) || STRING;
      STRING = '0' || SUBSTR(STRING, 0, 3) || '.' || SUBSTR(STRING, 3, 2);
      OUTPUT(1) = STRING || MESSAGE;
   END PRINT_TIME;

SOURCE_LINE:
   PROCEDURE (ABSOLUTE_ADDRESS) FIXED;
      DECLARE (ABSOLUTE_ADDRESS, RELATIVE_ADDRESS, LINE#, I) FIXED,
              LINES(19) FIXED, BUFFER CHARACTER;
      DECLARE LINE#_FILE FIXED INITIAL (5);
      LINE# = 0;
      IF (ABSOLUTE_ADDRESS < CODE_SEG_BASE_ADDR)
         | (ABSOLUTE_ADDRESS >= AR_BASE_ADDR) THEN
         RETURN 0;
      RELATIVE_ADDRESS = ABSOLUTE_ADDRESS - CODE_SEG_BASE_ADDR;
      BUFFER = INPUT(LINE#_FILE);
      CALL INLINE("58",1,0,BUFFER);              /* L    1,BUFFER         */
      CALL INLINE("41",2,0,LINES);               /* LA   2,LINES          */
      CALL INLINE("D2","4","F",2,0,1,0);         /* MVC  0(80,2),0(1)     */
      DO WHILE (BYTE(BUFFER) ~= BYTE('%')) & (LINES(19) <= RELATIVE_ADDRESS);
         LINE# = LINE# + 20;
         BUFFER = INPUT(LINE#_FILE);
         CALL INLINE("58",1,0,BUFFER);           /* L    1,BUFFER         */
         CALL INLINE("41",2,0,LINES);            /* LA   2,LINES          */
         CALL INLINE("D2","4","F",2,0,1,0);      /* MVC  0(80,2),0(1)     */
      END;
      CALL REWIND(FALSE, LINE#_FILE);
      IF BYTE(BUFFER) = BYTE('%') THEN
         RETURN LINE#;
      I = 18;
      DO WHILE (I >= 0) & (LINES(I) > RELATIVE_ADDRESS);
         I = I - 1;
      END;
      RETURN LINE# + I + 1;
   END SOURCE_LINE;

INITIALIZE:
   PROCEDURE;
      DECLARE I FIXED;
      I = SHR(MONITOR_LINK(3), 2);
      AR_BASE_ADDR = COREWORD(I);
      ORIGIN_ADDR = COREWORD(I + 1);
      TRANSFER_VECTOR_BASE_ADDR = COREWORD(I + 2);
      CODE_SEG_BASE_ADDR = COREWORD(I + 3);
      EXECUTION_TIME = COREWORD(I + 4);
      ERROR_LINE = COREWORD(I + 5);
      CORETOP = COREWORD(I + 6);
      PASCAL_REGS = ORIGIN_ADDR + 208;
      BLOCK_COUNTER_BASE_ADDR = ORIGIN_ADDR + 308;
   END INITIALIZE;

POST_MORTEM_DUMP:
   PROCEDURE;

      /* THE PMD TABLES */
      DECLARE SYTSIZE LITERALLY '255';
      DECLARE IDENTITY(SYTSIZE) CHARACTER,
              DATATYPE(SYTSIZE) BIT(16),
              VAR_TYPE(SYTSIZE) BIT(16),
              STRUCTYPE(SYTSIZE) BIT(16),
              STORAGE_LNGTH(SYTSIZE) BIT(16),
              S_LIST(SYTSIZE) BIT(16),
              DISPLACEMENT(SYTSIZE) FIXED,
              VALUE(SYTSIZE) FIXED;
      DECLARE PROCMAX LITERALLY '127';
      DECLARE PROC_HEAD(PROCMAX) FIXED;

      /* VAR_TYPE CODES ENCOUNTERED IN PMD TABLES */
      DECLARE VARIABLE BIT(16) INITIAL (1),
              CONSTANT BIT(16) INITIAL (2),
              TYPE     BIT(16) INITIAL (4),
              PROC     BIT(16) INITIAL (5);

      /* STRUCTYPE CODES ENCOUNTERED IN PMD TABLES */
      DECLARE STATEMENT  BIT(16) INITIAL (0),
              SCALAR     BIT(16) INITIAL (1),
              SUBRANGE   BIT(16) INITIAL (2),
              POINTER    BIT(16) INITIAL (3),
              ARRAY      BIT(16) INITIAL (4),
              ARITHMETIC BIT(16) INITIAL (14);

      /* POINTERS INTO THE PMD TABLES TO THE PREDECLARED TYPES */
      DECLARE INTPTR  BIT(16) INITIAL (2),
              BOOLPTR BIT(16) INITIAL (3),
              REALPTR BIT(16) INITIAL (4),
              CHARPTR BIT(16) INITIAL (5);

      DECLARE FATAL_ERROR BIT(1),
              (THIS_PROC, N_DECL_SYMB, PROC_SEQUENCE_NUMBER) BIT(16),
              (CBR, ARBASE, GLOBAL_ARBASE, CALLED_FROM_ADDR) FIXED;

   INITIALIZE_PMD_TABLES:
      PROCEDURE;
         DECLARE PMD_FILE BIT(16) INITIAL (6),
                 BUFFER CHARACTER,
                 I FIXED;

      NEXT_SYMBOL:
         PROCEDURE CHARACTER;
            DECLARE S CHARACTER;
            IF LENGTH(BUFFER) < 12 THEN
               BUFFER = BUFFER || INPUT(PMD_FILE);
            S = SUBSTR(BUFFER, 0, 12);
            BUFFER = SUBSTR(BUFFER, 12);
            RETURN S;
         END NEXT_SYMBOL;

      READ_COLUMN:
         PROCEDURE (ARRAY_ADDR, BYTES_PER_ITEM, LIMIT);
            DECLARE (BYTES_PER_ITEM, LIMIT) BIT(16),
                    (ARRAY_ADDR, INCREMENT, I, J, K) FIXED,
                    MOVE (2) BIT(16) INITIAL ("D200", "2000", "1000");
            INCREMENT = 80/BYTES_PER_ITEM;
            J = ARRAY_ADDR;
            I = 0;
            DO WHILE I + INCREMENT <= LIMIT;
               CALL INLINE("58",1,0,BUFFER);     /* L    1,BUFFER          */
               CALL INLINE("58",2,0,J);          /* L    2,J               */
               CALL INLINE("D2","4","F",2,0,1,0);/* MVC  0(80,2),0(1)      */
               I = I + INCREMENT;
               J = J + 80;
               BUFFER = INPUT(PMD_FILE);
            END;
            K = (LIMIT - I + 1)*BYTES_PER_ITEM - 1;
            CALL INLINE("58",1,0,BUFFER);        /* L    1,BUFFER          */
            CALL INLINE("58",2,0,J);             /* L    2,J               */
            CALL INLINE("58",3,0,K);             /* L    3,K               */
            CALL INLINE("44",3,0,MOVE);          /* EX   3,MOVE            */
            BUFFER = INPUT(PMD_FILE);
         END READ_COLUMN;

         N_DECL_SYMB, PROC_SEQUENCE_NUMBER = 0;
         BUFFER = INPUT(PMD_FILE);
         IF SUBSTR(BUFFER, 0, 5) ~= '%PMD ' THEN
            DO;
               OUTPUT = '%PMD CARD EXPECTED';
               FATAL_ERROR = TRUE;
               RETURN;
            END;
         DO I = 5 TO 9;
            IF BYTE(BUFFER, I) ~= BYTE(' ') THEN
               N_DECL_SYMB = 10*N_DECL_SYMB + BYTE(BUFFER, I) - BYTE('0');
         END;
         DO I = 10 TO 14;
            IF BYTE(BUFFER, I) ~= BYTE(' ') THEN
               PROC_SEQUENCE_NUMBER =
                  10*PROC_SEQUENCE_NUMBER + BYTE(BUFFER, I) - BYTE('0');
         END;
         IF (N_DECL_SYMB > SYTSIZE) | (PROC_SEQUENCE_NUMBER > PROCMAX) THEN
            DO;
               OUTPUT = 'PMD TABLE OVERFLOW';
               FATAL_ERROR = TRUE;
               RETURN;
            END;
         BUFFER = INPUT(PMD_FILE);
         DO I = 0 TO N_DECL_SYMB;
            IDENTITY(I) = NEXT_SYMBOL;
         END;
         BUFFER = INPUT(PMD_FILE);
         CALL READ_COLUMN(ADDR(DATATYPE), 2, N_DECL_SYMB);
         CALL READ_COLUMN(ADDR(VAR_TYPE), 2, N_DECL_SYMB);
         CALL READ_COLUMN(ADDR(STRUCTYPE), 2, N_DECL_SYMB);
         CALL READ_COLUMN(ADDR(STORAGE_LNGTH), 2, N_DECL_SYMB);
         CALL READ_COLUMN(ADDR(S_LIST), 2, N_DECL_SYMB);
         CALL READ_COLUMN(ADDR(DISPLACEMENT), 4, N_DECL_SYMB);
         CALL READ_COLUMN(ADDR(VALUE), 4, N_DECL_SYMB);
         CALL READ_COLUMN(ADDR(PROC_HEAD), 4, PROC_SEQUENCE_NUMBER);
         IF SUBSTR(BUFFER, 0, 4) ~= '%END' THEN
            DO;
               OUTPUT = '%END CARD EXPECTED';
               FATAL_ERROR = TRUE;
            END;
      END INITIALIZE_PMD_TABLES;

   INITIALIZE_PMD_POINTERS:
      PROCEDURE;
         GLOBAL_ARBASE = AR_BASE_ADDR;
         ARBASE = COREWORD(SHR(PASCAL_REGS, 2)) & "00FFFFFF";
         CBR = COREWORD(SHR(PASCAL_REGS, 2) + 1) & "00FFFFFF";
         FATAL_ERROR = (CBR < CODE_SEG_BASE_ADDR) | (CBR > GLOBAL_ARBASE)
                       | (ARBASE < GLOBAL_ARBASE)
                       | (ARBASE >= CORETOP);
      END INITIALIZE_PMD_POINTERS;

   FINDPROC:
      PROCEDURE (CBR) BIT(16);
         /* RETURNS SEQUENCE # OF CODE BLOCK WHOSE ENTRY POINT ADDRESS
            IS IN CBR. */
         DECLARE CBR FIXED, SEQ# BIT(16);
         DO SEQ# = 0 TO PROC_SEQUENCE_NUMBER;
            /* SEARCH THE TRANSFER VECTOR. */
            IF CBR = COREWORD(SHR(TRANSFER_VECTOR_BASE_ADDR, 2) + SEQ#) THEN
               RETURN SEQ#;
         END;
         /* CBR IS NOT A VALID ENTRY POINT. */
         RETURN NULL;
      END FINDPROC;

   DUMP_LOCAL_VARIABLES:
      PROCEDURE (SEQ#);
         DECLARE (SEQ#, #ACTIVATIONS, VAR_PTR, PROC_PTR, L) BIT(16),
                 (VAR_VALUE, VAR_ADDR, I, B) FIXED,
                 (LINE, S) CHARACTER,
                 MAX_DUMPS LITERALLY '5';

      TAB:
         PROCEDURE;
            /* AFTER EXECUTION OF THIS PROCEDURE,
               LENGTH(LINE) IN (.1, 33, 65, 97.) */
            DECLARE (L1, L2) BIT(16);
            L1 = LENGTH(LINE);
            L2 = (L1 - 1) MOD 32;
            IF (L1 < 97) & (L2 ~= 0) THEN
               LINE = LINE || SUBSTR(X70, 0, 32 - L2);
            ELSE IF L1 > 97 THEN
               DO;
                  OUTPUT = LINE;
                  LINE = X1;
               END;
         END TAB;

         #ACTIVATIONS = SHR(PROC_HEAD(SEQ#), 16);
         IF #ACTIVATIONS = MAX_DUMPS THEN
            DO;   /* WRITE ELLIPSES */
               OUTPUT = '. . .';
               OUTPUT  = '';   /* WRITES A BLANK LINE */
            END;
         #ACTIVATIONS = #ACTIVATIONS + 1;
         PROC_HEAD(SEQ#) = (PROC_HEAD(SEQ#) & "FFFF") | SHL(#ACTIVATIONS, 16);
         IF #ACTIVATIONS > MAX_DUMPS THEN RETURN;
         PROC_PTR = PROC_HEAD(SEQ#) & "FFFF";
         IF SEQ# = 0 THEN
            LINE = '=> PROGRAM BLOCK ';
         ELSE IF STRUCTYPE(PROC_PTR) = STATEMENT THEN
            LINE = '=> PROCEDURE BLOCK ';
         ELSE LINE = '=> FUNCTION BLOCK ';
         OUTPUT = LINE || IDENTITY(PROC_PTR);
         VAR_PTR = S_LIST(PROC_PTR);
         IF VAR_PTR = NULL THEN
            OUTPUT(1) =
               '0  NO LOCAL SCALAR, SUBRANGE, POINTER OR STRING VARIABLES';
         ELSE OUTPUT(1) = '0  VALUE OF LOCAL VARIABLES:';
         LINE = X1;
         DO WHILE VAR_PTR ~= NULL;
            VAR_ADDR = ARBASE + DISPLACEMENT(VAR_PTR);
            S = X1 || IDENTITY(VAR_PTR);
            L = LENGTH(S) - 1;
            DO WHILE BYTE(S, L) = BYTE(' ');
               L = L - 1;
            END;
            S = SUBSTR(S, 0, L + 1) || ' = ';
            IF STRUCTYPE(VAR_PTR) ~= ARRAY THEN
               DO; /* FETCH VALUE FROM ACTIVATION RECORD */
                  VAR_VALUE = 0;
                  DO I = 0 TO STORAGE_LNGTH(VAR_PTR) - 1;
                     VAR_VALUE = SHL(VAR_VALUE, 8) + COREBYTE(VAR_ADDR + I);
                  END;
                  VAR_VALUE = VAR_VALUE + VALUE(VAR_PTR);
                  IF (DATATYPE(VAR_PTR) = CHARPTR)
                     & (STRUCTYPE(VAR_PTR) ~= POINTER) THEN
                     DO;
                        S = S || '''X''';
                        BYTE(S, LENGTH(S) - 2) = VAR_VALUE;
                     END;
                  ELSE IF STRUCTYPE(DATATYPE(VAR_PTR)) = SCALAR THEN
                     DO;
                        I = S_LIST(DATATYPE(VAR_PTR)) + VAR_VALUE;
                        IF (DATATYPE(I) = DATATYPE(VAR_PTR))
                           & (VAR_TYPE(I) = CONSTANT) THEN
                           S = S || IDENTITY(I);
                        ELSE S = S || '?';
                     END;
                  ELSE IF STRUCTYPE(VAR_PTR) = POINTER THEN
                     DO;
                        IF VAR_VALUE = 0 THEN S = S || 'UNDEFINED';
                        ELSE IF VAR_VALUE = "FBFBFBFB" THEN S = S || 'NIL';
                        ELSE S = S || '(DEFINED)';
                     END;
                  ELSE IF DATATYPE(VAR_PTR) = REALPTR THEN
                     S = S || E_FORMAT(VAR_VALUE, 14);
                  ELSE S = S || VAR_VALUE;
                  IF (STRUCTYPE(VAR_PTR) ~= POINTER) &
                     (VAR_VALUE = VALUE(VAR_PTR)) THEN
                     DO;   /* POSSIBLY UNDEFINED VARIABLE */
                        L = LENGTH(S) - 1;
                        DO WHILE BYTE(S, L) = BYTE(' ');
                           L = L - 1;
                        END;
                        S = SUBSTR(S, 0, L + 1) || ' (OR UNDEFINED)';
                     END;
                  LINE = LINE || S;
                  CALL TAB;
               END;
            ELSE   /* CHARACTER ARRAY */
               DO;
                  IF LENGTH(LINE) + LENGTH(S) + STORAGE_LNGTH(VAR_PTR) + 2 > 132
                  THEN
                     DO;
                        IF LENGTH(LINE) > 1 THEN OUTPUT = LINE;
                        LINE = X1;
                     END;
                  L = STORAGE_LNGTH(VAR_PTR);
                  IF LENGTH(S) + L > 130 THEN L = 130 - LENGTH(S);
                  LINE = LINE || S;
                  S = 'X';
                  DO WHILE LENGTH(S) + 70 < L;
                     S = S || X70;
                  END;
                  IF LENGTH(S) < L THEN S = S || SUBSTR(X70, 0, L - LENGTH(S));
                  DO I = 0 TO L - 1;
                     B = COREBYTE(VAR_ADDR + I);
                     BYTE(S, I) = B;
                  END;
                  LINE = LINE || '''' || S || '''';
                  CALL TAB;
               END;
         /* S_LIST(VAR_PTR) = NULL OR VAR_PTR < S_LIST(VAR_PTR) <= N_DECL_SYMB
            AND VAR_TYPE(S_LIST(VAR_PTR)) = VARIABLE */
            VAR_PTR = S_LIST(VAR_PTR);
         END; /* WHILE */
         IF LENGTH(LINE) > 1 THEN OUTPUT = LINE;
         OUTPUT = '';   /* WRITES A BLANK LINE */
         IF SEQ# = 0 THEN RETURN;
         LINE = '  ' || IDENTITY(PROC_PTR);
         L = LENGTH(LINE) - 1;
         DO WHILE BYTE(LINE, L) = BYTE(' ');
            L = L - 1;
         END;
         OUTPUT = SUBSTR(LINE, 0, L + 1) || ' WAS CALLED NEAR LINE '            
                  || SOURCE_LINE(CALLED_FROM_ADDR);
         OUTPUT = '';
      END DUMP_LOCAL_VARIABLES;

      /****   POST MORTEM DUMP STARTS HERE   ****/
      FATAL_ERROR = FALSE;
      CALL INITIALIZE_PMD_POINTERS;
      IF FATAL_ERROR THEN RETURN;
      CALL INITIALIZE_PMD_TABLES;
      IF FATAL_ERROR THEN RETURN;
      OUTPUT(1) = '1=> TRACE OF ACTIVE BLOCKS';
      OUTPUT = '';
      DO FOREVER;
         THIS_PROC = FINDPROC(CBR);   /* RETURNS SEQ# */
         IF THIS_PROC = NULL THEN RETURN;
         CALLED_FROM_ADDR = (COREWORD(SHR(ARBASE, 2) + 1) & "00FFFFFF") - 2;
         CALL DUMP_LOCAL_VARIABLES(THIS_PROC);
         CBR = COREWORD(SHR(ARBASE, 2) + 3);
         IF ARBASE ~= GLOBAL_ARBASE THEN
            ARBASE = COREWORD(SHR(ARBASE, 2) + 2);
         ELSE RETURN;
      END;
   END POST_MORTEM_DUMP;

BLOCK_COUNT:
   PROCEDURE (BLOCK#) FIXED;
      DECLARE (I, BLOCK#) FIXED;
      DECLARE WORK(4) FIXED, OFFSET FIXED;
      IF (ADDR(WORK) & "FFFFFFF8") ~= ADDR(WORK) THEN OFFSET = 12;
      ELSE OFFSET = 0;   /* OFFSET IS INDEX INTO WORK OF DOUBLEWORD BOUNDARY */
      I = BLOCK_COUNTER_BASE_ADDR + SHL(BLOCK#, 2);
      WORK(0), WORK(3) = 0;
      WORK(1) = COREWORD(SHR(I, 2));
      WORK(4) = WORK(1);
      CALL INLINE("58",2,0,OFFSET);              /* L    2,OFFSET          */
      CALL INLINE("4F",3,2,WORK);   /*   CVB INTO XPL FUNC RETURN REG   */
   END BLOCK_COUNT;

FLOW_SUMMARY:
   PROCEDURE (ERROR_LINE);
      DECLARE ERROR_LINE FIXED;
      DECLARE DGNS#_FILE_NO FIXED INITIAL (3);
      DECLARE READING BIT(1), BLOCK# BIT(16);
      DECLARE STRING CHARACTER, I FIXED;

   DGNS#_DUMP:
      PROCEDURE (BLOCK_NUMBER);
      /* DUMP ONE SUMMARY BLOCK */
         DECLARE (POS, I, LAST_LINE, LINE_NUMBER, BLOCK_NUMBER,
                  INDENTATION) FIXED,
                 SUMMARY_1(7200) BIT(8), /* MUST BE FULLWORD-ALLIGNED */
                 (TEMP_STRING, EXTRA_STR) CHARACTER,
                 COUNTER# BIT(16);

      DECODE:
         PROCEDURE (POS) CHARACTER;
            /* DECODE ONE LINE OF PARAGRAPHED TEXT */
            DECLARE (POS, I) FIXED, (EXTRA_STR, CHAR_STR) CHARACTER;
            CHAR_STR = 'X';
            EXTRA_STR = X1;
            DO I = 1 TO SUMMARY_1(POS + 1);
               BYTE(CHAR_STR) = SUMMARY_1(POS + I + 5);
               EXTRA_STR = EXTRA_STR || CHAR_STR;
            END;
            RETURN EXTRA_STR;
         END DECODE;

         SUMMARY_1 = FILE(DGNS#_FILE_NO, BLOCK_NUMBER);
         READING = SUMMARY_1(0);
         POS = 1;
         DO WHILE POS < 7200;
            /* MAKE SURE THE BLOCK DOES NOT END PREMATURELY */
            IF SUMMARY_1(POS + 1) = 0 THEN
               POS = 7200;
            ELSE
               DO;
                  LAST_LINE = LINE_NUMBER;
                  LINE_NUMBER = SHL(SUMMARY_1(POS + 2), 8) + SUMMARY_1(POS + 3);
                  IF ERROR_LINE > 0 THEN
                     IF ((LAST_LINE < ERROR_LINE) & (LINE_NUMBER >= ERROR_LINE))
                       | ((LAST_LINE = ERROR_LINE) & (LINE_NUMBER > ERROR_LINE))
                  THEN
                OUTPUT = '---- ERROR -------------------------------------------
------------------------------------------------------------------------------';
                  COUNTER# = SHL(SUMMARY_1(POS + 4), 8) + SUMMARY_1(POS + 5);
                  TEMP_STRING = LINE_NUMBER;
                  I = LENGTH(TEMP_STRING);
                  IF I < 4 THEN
                     TEMP_STRING = SUBSTR('0000', 0, 4 - I) || TEMP_STRING;
                  EXTRA_STR = DECODE(POS);
                  INDENTATION = SUMMARY_1(POS);
                  TEMP_STRING = TEMP_STRING || SUBSTR(X70, 0, INDENTATION);
                  IF EXTRA_STR = '  ' THEN TEMP_STRING = '';
                  ELSE IF COUNTER# ~= NULL THEN
                     EXTRA_STR = I_FORMAT(BLOCK_COUNT(COUNTER#), 8)
                                     || '.--|     ' || EXTRA_STR;
                  ELSE EXTRA_STR = '           |     ' || EXTRA_STR;
                  OUTPUT = TEMP_STRING || EXTRA_STR;
               END;
            POS = POS + SUMMARY_1(POS + 1) + 6;
         END;
      END DGNS#_DUMP;

      /* FIRST EXECUTABLE STATEMENT OF FLOW_SUMMARY */
      READING = TRUE;
      BLOCK# = 0;
      OUTPUT(1) = '1=> EXECUTION FLOW SUMMARY';
      OUTPUT = '';   /* PRINTS A BLANK LINE */
      DO WHILE READING;
         CALL DGNS#_DUMP(BLOCK#);
         BLOCK# = BLOCK# + 1;
      END;
   END FLOW_SUMMARY;



MAIN_PROCEDURE:
   PROCEDURE;

      CALL INITIALIZE;

      IF (DEBUG_LEVEL > 0) & (ERROR_LINE ~= 0) THEN
         CALL POST_MORTEM_DUMP;

      IF DEBUG_LEVEL > 1 THEN
         DO;
            FREELIMIT = CORETOP - MAX_STRING_LENGTH;
            CALL FLOW_SUMMARY(ERROR_LINE & "00FFFFFF");
         END;

      CALL PRINT_TIME(EXECUTION_TIME, ' SECONDS IN EXECUTION.');

   END MAIN_PROCEDURE;


   CALL MAIN_PROCEDURE;

EOF EOF EOF
