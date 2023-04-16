 /*/
    Encoding:   Access this file using a UTF-8 character encoding.  
    		The following should appear to be a U.S. cent symbol: '¢'.
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SCAN.xpl
    Purpose:    This is a part of "Phase 1" (syntax analysis) of the HAL/S-FC 
                compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-07 RSB  Suffixed the filename with ".xpl".  Before this
                                file had been received, it appears as though
                                an EBCDIC-to-ASCII conversion had incorrectly
                                encoded the character '¢' (U.S. cent) as 0x9B.  
                                This has been repaired.
                2022-12-14 RSB	Changed encoding from ISO 8859-15 (or -1) 
                		to UTF-8.
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  SCAN                                                   */
 /* MEMBER NAME:     SCAN                                                   */
 /* LOCAL DECLARATIONS:                                                     */
 /*          BLANK_BYTES       BIT(16)                                      */
 /*          BUILD(1535)       LABEL                                        */
 /*          BUILD_BCD         LABEL                                        */
 /*          BUILD_COMMENT(1507)  LABEL                                     */
 /*          BUILD_INTERNAL_BCD(19)  LABEL                                  */
 /*          CASE13(1516)      LABEL                                        */
 /*          CENT_START        LABEL                                        */
 /*          CHAR_ALREADY_SCANNED  BIT(8)                                   */
 /*          CHAR_NEEDED       BIT(8)                                       */
 /*          CHAR_OP_CHECK(13) LABEL                                        */
 /*          CHECK(1500)       LABEL                                        */
 /*          COMMENT_PTR       BIT(16)                                      */
 /*          CONCAT(1533)      LABEL                                        */
 /*          DEC_POINT         BIT(8)                                       */
 /*          DEC_POINT_ENTRY   LABEL                                        */
 /*          DIGIT             BIT(8)                                       */
 /*          END_CHECK_RESERVED_WORD(1512)  LABEL                           */
 /*          END_OF_CENT(1558) LABEL                                        */
 /*          ESCAPE_LEVEL      BIT(16)                                      */
 /*          EXP_BEGIN         BIT(16)                                      */
 /*          EXP_CHECK         LABEL                                        */
 /*          EXP_DIGITS        BIT(16)                                      */
 /*          EXP_DONE          LABEL                                        */
 /*          EXP_SIGN          BIT(16)                                      */
 /*          FOUND_ERROR       LABEL                                        */
 /*          FOUND_TOKEN(1505) LABEL                                        */
 /*          GET_NEW_CHAR      LABEL                                        */
 /*          ID_LOOP(1524)     LABEL                                        */
 /*          INTERNAL_BCD      CHARACTER;                                   */
 /*          LOOK_FOR_COMMENT(1572)  LABEL                                  */
 /*          LOOP_END          LABEL                                        */
 /*          NUMBER_DONE       LABEL                                        */
 /*          OVERPUNCH_ALREADY_SCANNED  BIT(8)                              */
 /*          PARAMETER_PROCESSING(19)  LABEL                                */
 /*          PARM_FOUND(1514)  LABEL                                        */
 /*          POWER_INDICATOR(1541)  LABEL                                   */
 /*          PUSH_MACRO(1498)  LABEL                                        */
 /*          RESET_LITERAL     LABEL                                        */
 /*          SCAN_END          LABEL                                        */
 /*          SCAN_START        LABEL                                        */
 /*          SCAN_TOP          LABEL                                        */
 /*          SEARCH_NEEDED     BIT(8)                                       */
 /*          SEARCH_NEXT_CHAR(1545)  LABEL                                  */
 /*          SET_SEARCH(1554)  LABEL                                        */
 /*          SIG_CHECK         LABEL                                        */
 /*          SIG_DIGITS        BIT(16)                                      */
 /*          START_EXPONENT(1551)  LABEL                                    */
 /*          STORE_NEXT_CHAR(1576)  LABEL                                   */
 /*          STR_TOO_LONG(1534)  LABEL                                      */
 /*          S1                BIT(16)                                      */
 /*          TEMP_CHAR         BIT(8)                                       */
 /*          TEST_SEARCH(1564) LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CHAR_LENGTH_LIM                                                */
 /*          CHAR_OP                                                        */
 /*          CHARACTER_STRING                                               */
 /*          CHARTYPE                                                       */
 /*          CLASS_DT                                                       */
 /*          CLASS_IL                                                       */
 /*          CLASS_IR                                                       */
 /*          CLASS_LC                                                       */
 /*          CLASS_LF                                                       */
 /*          CLASS_LS                                                       */
 /*          CLASS_M                                                        */
 /*          CLASS_MC                                                       */
 /*          CLASS_MO                                                       */
 /*          CLASS_XM                                                       */
 /*          COMMA                                                          */
 /*          CONCATENATE                                                    */
 /*          CONST_DW                                                       */
 /*          CONTROL                                                        */
 /*          DECLARE_CONTEXT                                                */
 /*          DW                                                             */
 /*          EOFILE                                                         */
 /*          EQUATE_TOKEN                                                   */
 /*          ESCP                                                           */
 /*          EXPONENTIATE                                                   */
 /*          EXPRESSION_CONTEXT                                             */
 /*          FALSE                                                          */
 /*          FIRST_FREE                                                     */
 /*          FOREVER                                                        */
 /*          GROUP_NEEDED                                                   */
 /*          ID_LIMIT                                                       */
 /*          ID_TOKEN                                                       */
 /*          LEFT_PAREN                                                     */
 /*          LETTER_OR_DIGIT                                                */
 /*          LEVEL                                                          */
 /*          MAC_TXT                                                        */
 /*          MACRO_ARG_FLAG                                                 */
 /*          MACRO_EXPAN_LIMIT                                              */
 /*          MACRO_TEXT                                                     */
 /*          MAX_STRING_SIZE                                                */
 /*          MAX_STRUC_LEVEL                                                */
 /*          NUMBER                                                         */
 /*          ONE_BYTE                                                       */
 /*          OVER_PUNCH_SIZE                                                */
 /*          OVER_PUNCH_TYPE                                                */
 /*          PARM_CONTEXT                                                   */
 /*          PC_INDEX                                                       */
 /*          PC_LIMIT                                                       */
 /*          PCNAME                                                         */
 /*          PERCENT_MACRO                                                  */
 /*          PRINT_FLAG                                                     */
 /*          RECOVERING                                                     */
 /*          REPLACE_TEXT                                                   */
 /*          RESERVED_LIMIT                                                 */
 /*          RT_PAREN                                                       */
 /*          SAVE_COMMENT                                                   */
 /*          SET_CONTEXT                                                    */
 /*          SRN_PRESENT                                                    */
 /*          STMT_PTR                                                       */
 /*          STRUCTURE_WORD                                                 */
 /*          SUBSCRIPT_LEVEL                                                */
 /*          SYM_ADDR                                                       */
 /*          SYM_LENGTH                                                     */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_ADDR                                                       */
 /*          SYT_NAME                                                       */
 /*          TEMPORARY                                                      */
 /*          TRANS_IN                                                       */
 /*          TRUE                                                           */
 /*          TX                                                             */
 /*          V_INDEX                                                        */
 /*          VALID_00_CHAR                                                  */
 /*          VALID_00_OP                                                    */
 /*          VAR_LENGTH                                                     */
 /*          VOCAB_INDEX                                                    */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BASE_PARM_LEVEL                                                */
 /*          BCD                                                            */
 /*          BLANK_COUNT                                                    */
 /*          C                                                              */
 /*          COMM                                                           */
 /*          COMMENT_COUNT                                                  */
 /*          CONTEXT                                                        */
 /*          DONT_SET_WAIT                                                  */
 /*          EQUATE_IMPLIED                                                 */
 /*          EXP_OVERFLOW                                                   */
 /*          EXP_TYPE                                                       */
 /*          FIRST_TIME                                                     */
 /*          FIRST_TIME_PARM                                                */
 /*          FIXING                                                         */
 /*          FOR_DW                                                         */
 /*          FOUND_CENT                                                     */
 /*          GRAMMAR_FLAGS                                                  */
 /*          IMPLIED_TYPE                                                   */
 /*          I                                                              */
 /*          INCL_SRN                                                       */
 /*          K                                                              */
 /*          LABEL_IMPLIED                                                  */
 /*          LOOKUP_ONLY                                                    */
 /*          M_BLANK_COUNT                                                  */
 /*          M_CENT                                                         */
 /*          M_P                                                            */
 /*          M_PRINT                                                        */
 /*          M_TOKENS                                                       */
 /*          MACRO_CALL_PARM_TABLE                                          */
 /*          MACRO_EXPAN_LEVEL                                              */
 /*          MACRO_EXPAN_STACK                                              */
 /*          MACRO_FOUND                                                    */
 /*          MACRO_POINT                                                    */
 /*          MACRO_TEXTS                                                    */
 /*          NEW_MEL                                                        */
 /*          NEXT_CHAR                                                      */
 /*          NUM_OF_PARM                                                    */
 /*          OLD_MEL                                                        */
 /*          OLD_MP                                                         */
 /*          OLD_PEL                                                        */
 /*          OLD_PR_PTR                                                     */
 /*          OLD_TOPS                                                       */
 /*          OVER_PUNCH                                                     */
 /*          P_CENT                                                         */
 /*          PARM_COUNT                                                     */
 /*          PARM_EXPAN_LEVEL                                               */
 /*          PARM_REPLACE_PTR                                               */
 /*          PARM_STACK_PTR                                                 */
 /*          PASS                                                           */
 /*          PRINTING_ENABLED                                               */
 /*          RESERVED_WORD                                                  */
 /*          RESTORE                                                        */
 /*          SAVE_PE                                                        */
 /*          SOME_BCD                                                       */
 /*          START_POINT                                                    */
 /*          SUPPRESS_THIS_TOKEN_ONLY                                       */
 /*          S                                                              */
 /*          SAVE_BLANK_COUNT                                               */
 /*          SAVE_NEXT_CHAR                                                 */
 /*          SAVE_OVER_PUNCH                                                */
 /*          SCAN_COUNT                                                     */
 /*          SRN                                                            */
 /*          SRN_COUNT                                                      */
 /*          STRING_OVERFLOW                                                */
 /*          SYT_INDEX                                                      */
 /*          T_INDEX                                                        */
 /*          TEMP_INDEX                                                     */
 /*          TEMP_STRING                                                    */
 /*          TEMPLATE_IMPLIED                                               */
 /*          TEMPORARY_IMPLIED                                              */
 /*          TOKEN                                                          */
 /*          TOKEN_FLAGS                                                    */
 /*          TOP_OF_PARM_STACK                                              */
 /*          VALUE                                                          */
 /*          WAIT                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          FINISH_MACRO_TEXT                                              */
 /*          HEX                                                            */
 /*          IDENTIFY                                                       */
 /*          MIN                                                            */
 /*          PREP_LITERAL                                                   */
 /*          SAVE_TOKEN                                                     */
 /*          STREAM                                                         */
 /* CALLED BY:                                                              */
 /*          INITIALIZATION                                                 */
 /*          CALL_SCAN                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SCAN <==                                                            */
 /*     ==> MIN                                                             */
 /*     ==> HEX                                                             */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> FINISH_MACRO_TEXT                                               */
 /*     ==> SAVE_TOKEN                                                      */
 /*         ==> OUTPUT_WRITER                                               */
 /*             ==> CHAR_INDEX                                              */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> MIN                                                     */
 /*             ==> MAX                                                     */
 /*             ==> BLANK                                                   */
 /*             ==> LEFT_PAD                                                */
 /*             ==> I_FORMAT                                                */
 /*             ==> CHECK_DOWN                                              */
 /*     ==> STREAM                                                          */
 /*         ==> PAD                                                         */
 /*         ==> CHAR_INDEX                                                  */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> MOVE                                                        */
 /*         ==> MIN                                                         */
 /*         ==> MAX                                                         */
 /*         ==> DESCORE                                                     */
 /*             ==> PAD                                                     */
 /*         ==> HEX                                                         */
 /*         ==> SAVE_INPUT                                                  */
 /*             ==> PAD                                                     */
 /*             ==> I_FORMAT                                                */
 /*         ==> PRINT2                                                      */
 /*         ==> OUTPUT_GROUP                                                */
 /*             ==> PRINT2                                                  */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> HASH                                                        */
 /*         ==> ENTER_XREF                                                  */
 /*         ==> SAVE_LITERAL                                                */
 /*         ==> ICQ_TERM#                                                   */
 /*         ==> ICQ_ARRAY#                                                  */
 /*         ==> CHECK_STRUC_CONFLICTS                                       */
 /*         ==> ENTER                                                       */
 /*         ==> ENTER_DIMS                                                  */
 /*         ==> DISCONNECT                                                  */
 /*         ==> SET_DUPL_FLAG                                               */
 /*         ==> FINISH_MACRO_TEXT                                           */
 /*         ==> ENTER_LAYOUT                                                */
 /*         ==> MAKE_INCL_CELL                                              */
 /*         ==> OUTPUT_WRITER                                               */
 /*             ==> CHAR_INDEX                                              */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> MIN                                                     */
 /*             ==> MAX                                                     */
 /*             ==> BLANK                                                   */
 /*             ==> LEFT_PAD                                                */
 /*             ==> I_FORMAT                                                */
 /*             ==> CHECK_DOWN                                              */
 /*         ==> FINDER                                                      */
 /*         ==> INTERPRET_ACCESS_FILE                                       */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HASH                                                    */
 /*             ==> OUTPUT_WRITER                                           */
 /*                 ==> CHAR_INDEX                                          */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> MIN                                                 */
 /*                 ==> MAX                                                 */
 /*                 ==> BLANK                                               */
 /*                 ==> LEFT_PAD                                            */
 /*                 ==> I_FORMAT                                            */
 /*                 ==> CHECK_DOWN                                          */
 /*         ==> NEXT_RECORD                                                 */
 /*             ==> DECOMPRESS                                              */
 /*                 ==> BLANK                                               */
 /*         ==> ORDER_OK                                                    */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*     ==> IDENTIFY                                                        */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> HASH                                                        */
 /*         ==> ENTER                                                       */
 /*         ==> SET_DUPL_FLAG                                               */
 /*         ==> SET_XREF                                                    */
 /*             ==> ENTER_XREF                                              */
 /*             ==> SET_OUTER_REF                                           */
 /*                 ==> COMPRESS_OUTER_REF                                  */
 /*                     ==> MAX                                             */
 /*         ==> BUFFER_MACRO_XREF                                           */
 /*     ==> PREP_LITERAL                                                    */
 /*         ==> SAVE_LITERAL                                                */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /* 02/22/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /* 05/18/94 RSJ  27V0  DR104674 NESTED REPLACE MACRO                       */
 /* 06/20/97 LJK  28V0, DR109054 NESTED REPLACE MACRO GENERATES ERROR       */
 /*               12V0                                                      */
 /* 06/20/97 LJK  28V0, DR109035 NESTED REPLACE MACROS ARE NOT PRINTED      */
 /*               12V0           CORRECTLY                                  */
 /* 03/03/98 LJK  29V0, DR109076 REPLACE MACRO SPLIT ON TWO LINES           */
 /*               14V0                                                      */
 /* 09/09/99 JAC  30V0, DR111341 DO CASE STATEMENT PRINTED INCORRECTLY      */
 /*               15V0           (PRINT_FLUSH DELETED)                      */
 /* 04/21/00 JAC  30V0, DR111335 TOKEN NOT PRINTED AFTER REPLACE MACRO      */
 /*               15V0                                                      */
 /*                                                                         */
 /* 04/26/01 DCP  31V0, CR13335  ALLEVIATE SOME DATA SPACE PROBLEMS         */
 /*               16V0           IN HAL/S COMPILER                          */
 /***************************************************************************/
                                                                                00675200
                                                                                00675300
SCAN:                                                                           00675400
   PROCEDURE;                                                                   00675500
      DECLARE (SIG_DIGITS, EXP_SIGN,                                            00675600
         EXP_BEGIN, S1, EXP_DIGITS) BIT(16),                                    00675700
         DEC_POINT BIT(1),                                                      00675800
         CHAR_NEEDED BIT(1),                                                    00675900
         SEARCH_NEEDED BIT(1) INITIAL(TRUE),                                    00676000
         CHAR_ALREADY_SCANNED BIT(8),                                           00676100
         OVERPUNCH_ALREADY_SCANNED BIT(8),                                      00676200
         INTERNAL_BCD CHARACTER,                                                00676300
         COMMENT_PTR BIT(16),                                                   00676400
         DIGIT BIT(8);                                                          00676500
      DECLARE TEMP_CHAR BIT(8),                                                 00676600
         (BLANK_BYTES) BIT(16),                                                 00676620
         ESCAPE_LEVEL BIT(16);                                                  00676700
                                                                                00676800
CHAR_OP_CHECK:                                                                  00676900
      PROCEDURE(CHAR) BIT(8);                                                   00677000
         DECLARE (CHAR, HOLD_CHAR) BIT(8);                                      00677100
         IF OVER_PUNCH = 0 THEN RETURN CHAR;                                    00677200
         IF OVER_PUNCH = CHAR_OP THEN DO;  /* LEVEL 1 ESCAPE */                 00677300
            HOLD_CHAR = TRANS_IN(CHAR) & "FF";                                  00677400
VALID_TEST:                                                                     00677500
            IF HOLD_CHAR = "00" THEN                                            00677600
               IF OVER_PUNCH ^= VALID_00_OP | CHAR ^= VALID_00_CHAR THEN DO;    00677700
               CALL ERROR(CLASS_MO, 6, HEX(CHAR, 2));                           00677800
               RETURN CHAR;                                                     00677900
            END;                                                                00678000
            RETURN HOLD_CHAR;                                                   00678100
         END;                                                                   00678200
         ELSE IF OVER_PUNCH = CHAR_OP(1) THEN DO;                               00678300
            HOLD_CHAR = SHR(TRANS_IN(CHAR), 8) & "FF";  /* LEVEL 2 ESCAPE */    00678400
            GO TO VALID_TEST;  /* SEE IF IT A LEGAL ESCAPE */                   00678500
         END;                                                                   00678600
         ELSE DO;  /* ILLEGAL OVER PUNCH */                                     00678700
            CALL ERROR(CLASS_MO, 1, HEX(CHAR, 2));                              00678800
            RETURN CHAR;  /* NO TRANSLATION */                                  00678900
         END;                                                                   00679000
      END CHAR_OP_CHECK;                                                        00679100
                                                                                00679200
                                                                                00679300
                                                                                00679400
BUILD_BCD:                                                                      00679500
      PROCEDURE;                                                                00679600
         IF LENGTH(BCD) > 0 THEN                                                00679700
            BCD = BCD || X1;                                                    00679800
         ELSE                                                                   00679900
            BCD = SUBSTR(X1 || X1, 1);                                          00680000
 /*  FORCE BCD TO TOP OF FREE STRING AREA AND INCREASE LENGTH BY ONE  */        00680100
         COREBYTE(FREEPOINT - 1) = NEXT_CHAR;                                   00680200
      END BUILD_BCD;                                                            00680300
                                                                                00680400
BUILD_INTERNAL_BCD:                                                             00680500
      PROCEDURE;                                                                00680600
         IF LENGTH(INTERNAL_BCD) > 0 THEN                                       00680700
            INTERNAL_BCD = INTERNAL_BCD || X1;                                  00680800
         ELSE                                                                   00680900
            INTERNAL_BCD = SUBSTR(X1 || X1, 1);                                 00681000
         COREBYTE(FREEPOINT - 1) = NEXT_CHAR;                                   00681100
      END BUILD_INTERNAL_BCD;                                                   00681200
PARAMETER_PROCESSING:                                                           00681400
      PROCEDURE;                                                                00681500
         DECLARE I FIXED;                                                       00681600
         DECLARE (ARG_COUNT, NUM_OF_PAREN) BIT(16),                             00681700
            (LAST_ARG,QUOTE_FLAG,D_QUOTE_FLAG,CENT_FLAG) BIT(1);                00681800
         LAST_ARG, QUOTE_FLAG ,D_QUOTE_FLAG,CENT_FLAG= FALSE;                   00681900
         ARG_COUNT, NUM_OF_PAREN = 0 ;                                          00682000
         /* DR104674 :MOVED LOOP TO PUSH MACRO */
         IF VAR_LENGTH(SYT_INDEX)=0 THEN DO;                                    00682400
            LAST_ARG = TRUE;                                                    00682500
            GO TO CHECK_ARG_NUM;                                                00682600
         END;                                                                   00682700
         IF NEXT_CHAR = BYTE('(') THEN DO;                                      00682800
            TOKEN_FLAGS(STMT_PTR)=TOKEN_FLAGS(STMT_PTR)|"20";                   00682900
            RESERVED_WORD=TRUE;                                                 00683000
            CALL SAVE_TOKEN(LEFT_PAREN,0,"20",1);         /*DR109076*/          00683100
            GRAMMAR_FLAGS(STMT_PTR) = GRAMMAR_FLAGS(STMT_PTR) | MACRO_ARG_FLAG; 00683110
            DO I = 1 TO NUM_OF_PARM(MACRO_EXPAN_LEVEL+1);                       00683200
               TEMP_STRING=X1;                                                  00683300
               DO FOREVER;                                                      00683400
                  CALL STREAM;                                                  00683500
 /*CR13335*/      IF NEXT_CHAR = BYTE(SQUOTE) THEN QUOTE_FLAG = ^ QUOTE_FLAG;   00683600
                  ELSE IF QUOTE_FLAG = FALSE THEN DO;                           00683700
                     IF NEXT_CHAR = BYTE('(') THEN NUM_OF_PAREN=NUM_OF_PAREN+1; 00683800
                     ELSE IF NEXT_CHAR = BYTE(')') THEN DO;                     00683900
                        NUM_OF_PAREN=NUM_OF_PAREN-1;                            00684000
                        IF NUM_OF_PAREN < 0 THEN DO;                            00684100
                           LAST_ARG=TRUE;                                       00684200
                           CALL STREAM;                                         00684300
                           GO TO UP_ARG_COUNT;                                  00684400
                        END;                                                    00684500
                     END;                                                       00684600
                    ELSE IF NEXT_CHAR=BYTE('"') THEN D_QUOTE_FLAG=^D_QUOTE_FLAG;00684700
                     ELSE IF NEXT_CHAR=BYTE('¢') THEN CENT_FLAG=^CENT_FLAG;     00684800
                     ELSE IF NEXT_CHAR = BYTE(',') THEN DO;                     00684900
                        IF NUM_OF_PAREN=0 & D_QUOTE_FLAG =FALSE THEN            00685000
                           IF CENT_FLAG=FALSE THEN                              00685100
                           IF QUOTE_FLAG=FALSE THEN GO TO UP_ARG_COUNT;         00685200
                     END;                                                       00685300
                  END;                                                          00685400
                  IF LENGTH(TEMP_STRING) = 250 THEN DO;                         00685500
                     CALL ERROR(CLASS_IR,7);                                    00685600
                     RETURN;                                                    00685700
                  END;                                                          00685800
                  BYTE(ONE_BYTE) = NEXT_CHAR;                                   00685900
                  TEMP_STRING = TEMP_STRING || ONE_BYTE;                        00686000
 /*CR13335*/      IF NEXT_CHAR = BYTE(X1) THEN IF BLANK_COUNT > 0 THEN          00686100
                     IF (LENGTH(TEMP_STRING)+BLANK_COUNT) > 250 THEN DO;        00686200
                     CALL ERROR(CLASS_IR,7);                                    00686300
                     RETURN;                                                    00686400
                  END;                                                          00686500
                  ELSE DO K = 1 TO BLANK_COUNT;                                 00686600
                     TEMP_STRING=TEMP_STRING||X1;                               00686700
                  END;                                                          00686800
               END; /* OF DO FOREVER */                                         00686900
UP_ARG_COUNT:                                                                   00687000
               ARG_COUNT= ARG_COUNT + 1;                                        00687100
               TEMP_STRING,                                                     00687200
               MACRO_CALL_PARM_TABLE(I+TOP_OF_PARM_STACK)=SUBSTR(TEMP_STRING,1);00687300
               IF LENGTH(TEMP_STRING)>0 THEN DO;                                00687400
                  RESERVED_WORD=FALSE;                                          00687500
                  CALL SAVE_TOKEN(CHARACTER_STRING,TEMP_STRING,0,1); /*109076*/ 00687600
                 GRAMMAR_FLAGS(STMT_PTR)=GRAMMAR_FLAGS(STMT_PTR)|MACRO_ARG_FLAG;00687700
               END;                                                             00687800
               IF LAST_ARG = TRUE THEN GO TO CHECK_ARG_NUM;                     00687900
               RESERVED_WORD=TRUE;                                              00688000
               CALL SAVE_TOKEN(COMMA,0,"20",1);               /*DR109076*/      00688100
               GRAMMAR_FLAGS(STMT_PTR)=GRAMMAR_FLAGS(STMT_PTR)|MACRO_ARG_FLAG;  00688110
            END;                                                                00688200
         END;                                                                   00688300
         ELSE LAST_ARG = TRUE;                                                  00688400
CHECK_ARG_NUM:                                                                  00688500
         IF ARG_COUNT ^= NUM_OF_PARM(MACRO_EXPAN_LEVEL+1) | LAST_ARG = FALSE    00688600
            THEN DO;  CALL ERROR(CLASS_IR,8);                                   00688700
               RETURN;                                                          00688750
         END;                                                                   00688800
         IF NEXT_CHAR=BYTE('¢') THEN                                            00688900
            IF FOUND_CENT THEN IF MACRO_EXPAN_LEVEL>0 THEN GO TO NO_BACKUP;     00689000
         ELSE CALL STREAM;                                                      00689100
         IF PARM_EXPAN_LEVEL>BASE_PARM_LEVEL(MACRO_EXPAN_LEVEL) THEN DO;        00689200
            IF FIRST_TIME_PARM(PARM_EXPAN_LEVEL) THEN                           00689300
        PARM_REPLACE_PTR(PARM_EXPAN_LEVEL)=PARM_REPLACE_PTR(PARM_EXPAN_LEVEL)-1;00689400
            ELSE FIRST_TIME_PARM(PARM_EXPAN_LEVEL)=TRUE;                        00689500
         END;                                                                   00689600
         ELSE DO;                                                               00689700
            IF FIRST_TIME(MACRO_EXPAN_LEVEL) THEN DO;                           00689800
               IF MACRO_TEXT(MACRO_POINT-2)="EE" THEN                           00689900
                  MACRO_POINT=MACRO_POINT-2;                                    00690000
               ELSE IF MACRO_TEXT(MACRO_POINT)^="EF" THEN                       00690100
                  MACRO_POINT=MACRO_POINT-1;                                    00690200
               ELSE IF MACRO_TEXT(MACRO_POINT) ="EF" &       /*DR111335*/
                  MACRO_TEXT(MACRO_POINT-1) = NEXT_CHAR THEN /*DR111335*/
                  MACRO_POINT=MACRO_POINT-1;                 /*DR111335*/
            END;                                                                00690300
            ELSE FIRST_TIME(MACRO_EXPAN_LEVEL)=TRUE;                            00690400
         END;                                                                   00690500
NO_BACKUP:                                                                      00690600
         IF ARG_COUNT>0 THEN DO;                                                00690700
            RESERVED_WORD=TRUE;                                                 00690800
            CALL SAVE_TOKEN(RT_PAREN,0,0,1);          /*DR109035,109076*/       00690900
            GRAMMAR_FLAGS(STMT_PTR)=GRAMMAR_FLAGS(STMT_PTR)|MACRO_ARG_FLAG;     00690910
         END;                                                                   00691000
         M_P(MACRO_EXPAN_LEVEL)=MACRO_POINT;                                    00691100
         M_BLANK_COUNT(MACRO_EXPAN_LEVEL) = BLANK_COUNT;                        00691200
         MACRO_EXPAN_LEVEL=MACRO_EXPAN_LEVEL+1;                                 00691300
         FIRST_TIME(MACRO_EXPAN_LEVEL)=TRUE;                                    00691400
         TOP_OF_PARM_STACK = TOP_OF_PARM_STACK + ARG_COUNT;                     00691500
         TEMP_STRING = '';                                                      00691600
         RESERVED_WORD=FALSE;                                                   00691700
      END PARAMETER_PROCESSING;                                                 00691800

/*--------------------------------------------------------------------*/
/* DR104674: ROUTINE TO DETERMINE IF END OF MACRO HAS BEEN REACHED BY */
/*           MACRO_POINT                                              */
/*--------------------------------------------------------------------*/
END_OF_MACRO:
   PROCEDURE BIT(1);
      DECLARE MP FIXED;

      MP=MACRO_POINT;
      /* FIRST SKIP BLANKS */
      DO WHILE (MACRO_TEXT(MP)="EE" | MACRO_TEXT(MP)=BYTE(X1));     /*CR13335*/
         IF MACRO_TEXT(MP)="EE" THEN MP=MP+1;
         MP=MP+1;
      END;
      /* THEN CHECK FOR END OF MACRO CHARACTER */
      IF MACRO_TEXT(MP)="EF" THEN
         IF NEXT_CHAR=BYTE(X1) THEN RETURN TRUE;                    /*CR13335*/
      RETURN FALSE;
END END_OF_MACRO;
                                                                                00691900
      IF SEARCH_NEEDED THEN GO TO SCAN_END;  /* PRE-SEARCH FOR COMMENTS */      00692000
SCAN_TOP:/* CONTROL RETURNED HERE FROM COMMENT SEARCH */                        00692100
      SCAN_COUNT = SCAN_COUNT + 1;                                              00692200
      IF CHAR_NEEDED THEN                                                       00692300
         DO;                                                                    00692400
         CALL STREAM;                                                           00692500
         CHAR_NEEDED = FALSE;                                                   00692600
      END;                                                                      00692700
SCAN_START:                                                                     00692800
      M_TOKENS(MACRO_EXPAN_LEVEL)=M_TOKENS(MACRO_EXPAN_LEVEL)+1;                00692900
      BCD = '';                                                                 00693000
      FIXING=0;                                                                 00693100
      DW(6), DW(7), VALUE, SYT_INDEX = 0;                                       00693200
      RESERVED_WORD = TRUE;                                                     00693300
      IMPLIED_TYPE = 0;                                                         00693400
      DO FOREVER;    /* START OF SCAN */                                        00693500
         IF ^MACRO_FOUND THEN IF SRN_PRESENT THEN DO;                           00693600
            SRN(1)=SRN;                                                         00693700
            INCL_SRN(1) = INCL_SRN;                                             00693710
            SRN_COUNT(1)=SRN_COUNT;                                             00693800
         END;                                                                   00693900
         DO CASE CHARTYPE(NEXT_CHAR);                                           00694000
            DO;  /* CASE 0--ILLEGAL CHARACTERS */                               00694100
               C = HEX(NEXT_CHAR, 2);                                           00694300
               CALL ERROR(CLASS_DT,4,C);                                        00694400
               IF OVER_PUNCH ^= 0 THEN                                          00694500
                  CALL ERROR(CLASS_MO,1);                                       00694600
               CALL STREAM;                                                     00694700
            END;                                                                00694800
            DO;  /* CASE 1--DIGITS */                                           00694900
               RESERVED_WORD, DEC_POINT = FALSE;                                00695000
               CALL BUILD_BCD;                                                  00695100
               IF OVER_PUNCH ^= 0 THEN                                          00695200
                  CALL ERROR(CLASS_MO,1);                                       00695300
               CALL STREAM;                                                     00695400
               TOKEN = NUMBER;                                                  00695500
               IF NEXT_CHAR=BYTE(X1)|NEXT_CHAR=BYTE(')') THEN       /*CR13335*/ 00695600
                  DO;                                                           00695700
                  VALUE = BYTE(BCD) - BYTE('0');                                00695800
                  IF VALUE >= 1 & VALUE <= MAX_STRUC_LEVEL THEN                 00695900
                     TOKEN = LEVEL;                                             00696000
               END;                                                             00696100
               DIGIT = BYTE(BCD);                                               00696200
DEC_POINT_ENTRY:                                                                00696300
               SIG_DIGITS=0;                                                    00696400
               INTERNAL_BCD = BCD;  /* START THE SAME */                        00696500
               GO TO SIG_CHECK;                                                 00696600
               DO WHILE CHARTYPE(DIGIT) = 1;                                    00696700
                  IF OVER_PUNCH ^= 0 THEN                                       00696900
                     CALL ERROR(CLASS_MO,1);                                    00697000
                  CALL BUILD_BCD;                                               00697100
                  CALL BUILD_INTERNAL_BCD;                                      00697200
SIG_CHECK:                                                                      00697300
                  IF SIG_DIGITS = 0 THEN                                        00697400
                     IF DIGIT = BYTE('0') THEN                                  00697500
                     DO;                                                        00697600
                     IF LENGTH(BCD) = 1 THEN                                    00697700
                        GO TO LOOP_END;                                         00697800
                     GO TO GET_NEW_CHAR;                                        00697900
                  END;                                                          00698000
                  SIG_DIGITS = SIG_DIGITS + 1;                                  00698100
                  IF SIG_DIGITS > 74 THEN                                       00698200
                     GO TO GET_NEW_CHAR;   /* TOO MANY SIG DIGITS */            00698300
                  IF LENGTH(BCD) = 1 THEN                                       00698400
                     GO TO LOOP_END;                                            00698500
GET_NEW_CHAR:                                                                   00698600
                  CALL STREAM;                                                  00698700
LOOP_END:                                                                       00698800
                  DIGIT = NEXT_CHAR;                                            00698900
               END;  /* OF DO WHILE... */                                       00699000
               IF DIGIT = BYTE(PERIOD) THEN                         /*CR13335*/ 00699100
                  DO;                                                           00699200
                  IF DEC_POINT THEN                                             00699300
                     DO;                                                        00699400
                     CALL BUILD_BCD;                                            00699500
                     CALL ERROR(CLASS_LF,2);                                    00699600
FOUND_ERROR:                                                                    00699700
                     IF OVER_PUNCH ^= 0 THEN                                    00699800
                        CALL ERROR(CLASS_MO,1);                                 00699900
                     GO TO GET_NEW_CHAR;                                        00700000
                  END;                                                          00700100
                  DEC_POINT = TRUE;                                             00700200
                  CALL BUILD_BCD;                                               00700300
                  CALL BUILD_INTERNAL_BCD;                                      00700400
                  GO TO FOUND_ERROR;                                            00700500
               END;                                                             00700600
START_EXPONENT:                                                                 00700700
               EXP_TYPE = DIGIT;                                                00700800
               IF EXP_TYPE = BYTE('E') THEN                                     00700900
                  DO;                                                           00701000
POWER_INDICATOR:                                                                00701100
                  EXP_SIGN, EXP_BEGIN = 0;                                      00701200
                  EXP_DIGITS = 0;                                               00701300
                  EXP_BEGIN = LENGTH(INTERNAL_BCD) + 1;                         00701400
                  GO TO EXP_CHECK;                                              00701500
                  DO WHILE CHARTYPE(DIGIT) = 1;                                 00701600
                     EXP_DIGITS = EXP_DIGITS + 1;                               00701700
EXP_CHECK:                                                                      00701800
                     IF OVER_PUNCH ^= 0 THEN                                    00701900
                        CALL ERROR(CLASS_MO,1);                                 00702000
                     CALL BUILD_BCD;                                            00702100
                     CALL BUILD_INTERNAL_BCD;                                   00702200
                     CALL STREAM;                                               00702400
                     DIGIT = NEXT_CHAR;                                         00702500
                  END;                                                          00702600
                  IF LENGTH(INTERNAL_BCD) = EXP_BEGIN THEN                      00702700
                     DO;                                                        00702800
                     IF DIGIT = BYTE('+') | DIGIT = BYTE('-') THEN              00702900
                        DO;                                                     00703000
                        EXP_SIGN = DIGIT;                                       00703100
                        GO TO EXP_CHECK;                                        00703200
                     END;                                                       00703300
                     CALL ERROR(CLASS_LF, 1);                                   00703400
                     GO TO RESET_LITERAL;                                       00703500
                  END;                                                          00703600
                  ELSE                                                          00703700
                     GO TO EXP_DONE;                                            00703800
               END;                                                             00703900
               IF EXP_TYPE = BYTE('H') | EXP_TYPE = BYTE('B') THEN              00704000
                  GO TO POWER_INDICATOR;                                        00704100
               GO TO NUMBER_DONE;                                               00704200
EXP_DONE:                                                                       00704300
               IF EXP_DIGITS ^> 0 THEN                                          00704400
                  DO;                                                           00704500
                  CALL ERROR(CLASS_LF,5);                                       00704600
RESET_LITERAL:                                                                  00704700
                  INTERNAL_BCD = SUBSTR(INTERNAL_BCD, 0, EXP_BEGIN - 1);        00704800
                  GO TO START_EXPONENT;                                         00704900
               END;                                                             00705000
               GO TO START_EXPONENT;                                            00705100
NUMBER_DONE:                                                                    00705200
               IF SIG_DIGITS > 74 THEN                                          00705300
                  CALL ERROR(CLASS_LF,3);                                       00705400
             EXP_OVERFLOW = MONITOR(10, INTERNAL_BCD);  /* CONVERT THE NUMBER */00705500
               IF EXP_OVERFLOW THEN CALL ERROR(CLASS_LC, 2, BCD);               00705600
               CALL PREP_LITERAL;                                               00705700
               GO TO SCAN_END;                                                  00705800
            END; /* OF CASE 1 */                                                00705900
            DO; /* CASE 2--LETTERS=IDENTS & RESERVED WORDS */                   00706000
               STRING_OVERFLOW, LABEL_IMPLIED = FALSE;                          00706100
               IMPLIED_TYPE = 0;                                                00706200
               DO FOREVER;                                                      00706300
CENT_START:                                                                     00706400
                  IF LETTER_OR_DIGIT(NEXT_CHAR) THEN                            00706500
                     DO; /* VALID CHARACTER */                                  00706600
ID_LOOP:             PROCEDURE;                                                 00706700
                        S1=NEXT_CHAR=BYTE('_');                                 00706800
                        IF LENGTH(BCD) < ID_LIMIT THEN                          00706900
                           DO;                                                  00707000
                           CALL BUILD_BCD;                                      00707100
                           IF OVER_PUNCH ^= 0 THEN                              00707200
                              DO;                                               00707300
                              IF IMPLIED_TYPE > 0 THEN                          00707400
                                 CALL ERROR(CLASS_MO,3);                        00707500
                              ELSE                                              00707600
                                 DO;                                            00707700
                                 DO I = 1 TO OVER_PUNCH_SIZE;                   00707800
                                    IF OVER_PUNCH = OVER_PUNCH_TYPE(I)          00707900
                                       THEN DO;                                 00708000
                                       IMPLIED_TYPE = I;                        00708100
                                       GO TO NEW_CHAR;                          00708200
                                    END;                                        00708300
                                 END;                                           00708400
                                 CALL ERROR(CLASS_MO,4);                        00708500
                                 OVER_PUNCH = 0;                                00708600
                              END;                                              00708700
                           END;                                                 00708800
                        END;                                                    00708900
                        ELSE                                                    00709000
                           DO; /* TOO MANY CHARACTERS IN IDENT */               00709100
                           IF ^STRING_OVERFLOW THEN                             00709200
                              DO;                                               00709300
                              CALL ERROR(CLASS_IL,2);                           00709400
                              STRING_OVERFLOW = TRUE;                           00709500
                           END;                                                 00709600
                        END;                                                    00709700
NEW_CHAR:                                                                       00709800
                        CALL STREAM;                                            00709900
                     END ID_LOOP;                                               00710000
                     CALL ID_LOOP;                                              00710100
                  END; /* OF DO...VALID CHARACTER */                            00710200
                  ELSE DO;                                                      00710300
                     IF S1 THEN                                                 00710400
                        IF NEXT_CHAR ^= BYTE('¢') THEN                          00710500
                        CALL ERROR(CLASS_IL, 1);                                00710600
                     GO TO FOUND_TOKEN;                                         00710700
                  END;                                                          00710800
               END; /* OF DO FOREVER */                                         00710900
FOUND_TOKEN:                                                                    00711000
               IF NEXT_CHAR=BYTE('¢') THEN DO;                                  00711100
                  GO TO CASE13;                                                 00711200
               END;                                                             00711300
               ELSE DO;                                                         00711400
                  S1 = LENGTH(BCD);                                             00711500
                  IF S1 > 1 THEN                                                00711600
                     IF S1 <= RESERVED_LIMIT THEN                               00711700
 /* CHECK FOR RESERVED WORDS */                                                 00711800
                     DO I = V_INDEX(S1 - 1) TO V_INDEX(S1) - 1;                 00711900
                     S = STRING(VOCAB_INDEX(I));                                00712000
                     IF BYTE(S) > BYTE(BCD) THEN GO TO END_CHECK_RESERVED_WORD; 00712100
                     IF S = BCD THEN                                            00712200
                        DO;                                                     00712300
                        TOKEN = I;                                              00712400
                        IF IMPLIED_TYPE > 0 THEN                                00712500
                           CALL ERROR(CLASS_MC,4,BCD);                          00712600
                        I = SET_CONTEXT(I);                                     00712700
                        IF I > 0 THEN DO;                                       00712800
                           IF TOKEN=TEMPORARY THEN TEMPORARY_IMPLIED=TRUE;      00712900
                           IF TOKEN = EQUATE_TOKEN THEN                         00713000
                              EQUATE_IMPLIED = TRUE;                            00713100
                           IF I = EXPRESSION_CONTEXT THEN DO;                   00713200
                              IF CONTEXT = DECLARE_CONTEXT |                    00713300
                                 CONTEXT = PARM_CONTEXT THEN DO;                00713400
                                 OLD_MEL=MACRO_EXPAN_LEVEL;                     00713500
                                 SAVE_PE=PRINTING_ENABLED;                      00713600
                                 DO WHILE NEXT_CHAR = BYTE(X1);     /*CR13335*/ 00713700
                                    IF ^MACRO_FOUND THEN                        00713800
                                       SAVE_BLANK_COUNT = BLANK_COUNT;          00713900
                                    CALL STREAM;                                00714000
                                 END;                                           00714100
                                 IF OLD_MEL>MACRO_EXPAN_LEVEL THEN              00714200
                                    IF M_TOKENS(OLD_MEL)<=1 THEN                00714300
                                    IF SAVE_PE^=PRINTING_ENABLED THEN           00714400
                                    SUPPRESS_THIS_TOKEN_ONLY=TRUE;              00714500
                                 IF NEXT_CHAR = BYTE('(') THEN                  00714600
                                    CONTEXT = I;                                00714700
                              END;                                              00714800
                              ELSE IF TOKEN = STRUCTURE_WORD THEN DO;           00714900
                                 CONTEXT = DECLARE_CONTEXT;                     00715000
                                 TEMPLATE_IMPLIED = TRUE;                       00715100
                              END;                                              00715200
                           END;                                                 00715300
                           ELSE IF CONTEXT ^= DECLARE_CONTEXT THEN              00715400
                              IF CONTEXT ^= EXPRESSION_CONTEXT THEN             00715500
                              CONTEXT = I;                                      00715600
                        END;                                                    00715700
                        GO TO SCAN_END;                                         00715800
                     END;                                                       00715900
                  END;                                                          00716000
               END;                                                             00716100
END_CHECK_RESERVED_WORD:                                                        00716200
               RESERVED_WORD = FALSE;                                           00716300
               IF MACRO_EXPAN_LEVEL > 0 THEN                                    00716400
                  DO;                                                           00716500
            /*-------------------------------------------------------*/
            /* DR104674: AT THIS POINT, WE ARE CHECKING TO SEE IF    */
            /*             BCD IS A FORMAL PARAMETER OF THE MACRO.   */
            /*             IF IT IS THEN THE DELIMITER WE JUST       */
            /*             FETCHED OUT OF THE MACRO TABLE CANNOT BE  */
            /*             PROCESSED UNTIL AFTER WE GET THE PARAMETER*/
            /*             VALUE.  INSTEAD OF SAVING THE DELIMITER,  */
            /*             MACRO_POINT WILL SIMPLY BACK UP AND THE   */
            /*             DELIMETER WILL BE FETCHED AGAIN.          */
            /*           FOR THE DR SCENARIO, THE DELIMITER WAS AN   */
            /*             END_OF MACRO, THEREFORE THE MACRO_POINT   */
            /*             WAS NOT ADAVNCED WHEN IT WAS FETCHED.     */
            /*             IN THIS CASE WE SHOULD NOT BACK UP THE    */
            /*             MACRO_POINT.                              */
            /*-------------------------------------------------------*/
PARM_FOUND:       PROCEDURE BIT(8);                                             00716600
                     TEMP_INDEX=MACRO_EXPAN_LEVEL;                              00716700
                     PARM_COUNT=NUM_OF_PARM(TEMP_INDEX);                        00716800
                     DO WHILE TEMP_INDEX>0;                                     00716900
                        DO I=1 TO NUM_OF_PARM(TEMP_INDEX);                      00717000
                       IF BCD=SYT_NAME(MACRO_EXPAN_STACK(TEMP_INDEX)+I) THEN DO;00717100
                              PARM_EXPAN_LEVEL = PARM_EXPAN_LEVEL + 1;          00717200
                              FIRST_TIME_PARM(PARM_EXPAN_LEVEL)=TRUE;           00717300
                              PARM_REPLACE_PTR(PARM_EXPAN_LEVEL) = 0;           00717400
                              PARM_STACK_PTR(PARM_EXPAN_LEVEL) = I +            00717500
                                 TOP_OF_PARM_STACK-PARM_COUNT;                  00717600
                              IF BASE_PARM_LEVEL(MACRO_EXPAN_LEVEL)+1 =         00717700
                                 PARM_EXPAN_LEVEL THEN DO;                      00717800
                                 IF ^FOUND_CENT THEN DO;                        00717900
                                    IF ^END_OF_MACRO THEN DO; /* DR104674 */
                                       IF MACRO_TEXT(MACRO_POINT-2)="EE" THEN   00718000
                                          MACRO_POINT=MACRO_POINT-1;            00718100
                                       MACRO_POINT=MACRO_POINT-1;               00718200
                                    END;
                                 END;                                           00718300
                              END;                                              00718400
                              ELSE DO;                                          00718500
                                 IF FIRST_TIME_PARM(PARM_EXPAN_LEVEL-1) THEN DO;00718600
 /*  CHECK FOR CENT SIGN  */                                                    00718610
                                    IF NEXT_CHAR^=BYTE('¢') THEN                00718620
                                       PARM_REPLACE_PTR(PARM_EXPAN_LEVEL-1)=    00718700
                                       PARM_REPLACE_PTR(PARM_EXPAN_LEVEL-1)-1;  00718800
                                 END;                                           00718810
                                 ELSE FIRST_TIME_PARM(PARM_EXPAN_LEVEL-1)=TRUE; 00718900
                              END;                                              00719000
                              BLANK_COUNT, OVER_PUNCH = 0;                      00719100
                              P_CENT(PARM_EXPAN_LEVEL)=FOUND_CENT;              00719200
                              CALL STREAM;                                      00719300
                              RETURN 1;                                         00719400
                           END;                                                 00719500
                        END;                                                    00719600
                        TEMP_INDEX=TEMP_INDEX-1;                                00719700
                        PARM_COUNT=PARM_COUNT + NUM_OF_PARM(TEMP_INDEX);        00719800
                     END;                                                       00719900
                     RETURN 0;                                                  00720000
                  END PARM_FOUND;                                               00720100
                  FOUND_CENT=FALSE;                                             00720200
                  IF PARM_FOUND THEN GO TO SCAN_START;                          00720300
               END;                                                             00720400
               OLD_MEL = MACRO_EXPAN_LEVEL;                                     00720500
               OLD_PEL = PARM_EXPAN_LEVEL;                                      00720600
               OLD_PR_PTR = PARM_REPLACE_PTR(PARM_EXPAN_LEVEL);                 00720610
               OLD_TOPS=TOP_OF_PARM_STACK;                                      00720700
               SAVE_PE = PRINTING_ENABLED;                                      00720800
               OLD_MP=MACRO_POINT;                                              00720900
               DO WHILE NEXT_CHAR=BYTE(X1);                         /*CR13335*/ 00721000
                  IF ^MACRO_FOUND THEN SAVE_BLANK_COUNT=BLANK_COUNT;            00721100
                  CALL STREAM;                                                  00721200
               END;                                                             00721300
               NEW_MEL = MACRO_EXPAN_LEVEL;                                     00721400
               IF OLD_MEL > NEW_MEL THEN                                        00721500
                  IF M_TOKENS(OLD_MEL) <= 1 THEN                                00721600
                  IF SAVE_PE ^= PRINTING_ENABLED THEN                           00721700
                  SUPPRESS_THIS_TOKEN_ONLY = TRUE;                              00721800
               IF SUBSCRIPT_LEVEL = 0 THEN                                      00721900
                  DO;                                                           00722000
                  IF NEXT_CHAR = BYTE(':') THEN DO;                             00722100
                     IF CONTEXT ^= DECLARE_CONTEXT THEN                         00722200
                        LABEL_IMPLIED = TRUE;                                   00722300
                  END;                                                          00722400
                  ELSE IF NEXT_CHAR = BYTE('-') THEN                            00722500
                     IF CONTEXT = DECLARE_CONTEXT | CONTEXT = PARM_CONTEXT      00722600
                     THEN DO;                                                   00722700
                     TEMPLATE_IMPLIED = TRUE;                                   00722800
                     LOOKUP_ONLY = TRUE;                                        00722900
                  END;                                                          00723000
               END;                                                             00723100
               IF RECOVERING THEN DO;                                           00723200
                  LOOKUP_ONLY, TEMPLATE_IMPLIED = FALSE;                        00723300
                  GO TO SCAN_END;  /* WITHOUT CALLING IDENTIFY */               00723400
               END;                                                             00723500
               CALL IDENTIFY(BCD,0);                                            00723600
               LOOKUP_ONLY, TEMPLATE_IMPLIED = FALSE;                           00723700
               IF CONTROL(3) THEN DO;                                           00723800
                  IF TOKEN > 0 THEN S = STRING(VOCAB_INDEX(TOKEN));             00723900
                  ELSE S = TOKEN;                                               00724000
                  OUTPUT = BCD || ' :  TOKEN = ' || S || ', IMPLIED_TYPE = '    00724100
                     || IMPLIED_TYPE || ', SYT_INDEX = ' || SYT_INDEX           00724200
                     || ', CONTEXT = ' || CONTEXT;                              00724300
               END;                                                             00724400
               IF MACRO_FOUND THEN                                              00724500
                  IF OLD_PEL^=PARM_EXPAN_LEVEL THEN                             00724600
                IF BASE_PARM_LEVEL(MACRO_EXPAN_LEVEL)>=PARM_EXPAN_LEVEL THEN DO;00724700
                  NEXT_CHAR=BYTE(X1);                               /*CR13335*/ 00724800
                  MACRO_POINT=MACRO_POINT-1;                                    00724900
               END;                                                             00725000
               IF TOKEN < 0 THEN                                                00725100
                  DO; /* MACRO NAME FOUND */                                    00725200
 /*CR13335*/      IF MACRO_EXPAN_LEVEL=0 & SAVE_NEXT_CHAR=BYTE(X1)  /*DR109054*/
                     THEN SAVE_NEXT_CHAR = NEXT_CHAR;               /*DR109054*/
                  IF OLD_MEL > NEW_MEL THEN DO;                                 00725300
                     IF PARM_EXPAN_LEVEL>BASE_PARM_LEVEL(MACRO_EXPAN_LEVEL)     00725310
                        THEN IF OLD_PR_PTR<PARM_REPLACE_PTR(PARM_EXPAN_LEVEL)   00725320
                        THEN PARM_REPLACE_PTR(PARM_EXPAN_LEVEL)=OLD_PR_PTR;     00725330
                     NEW_MEL, MACRO_EXPAN_LEVEL = OLD_MEL;                      00725400
                     MACRO_FOUND = TRUE;                                        00725500
                     WAIT=FALSE;                                                00725600
                     MACRO_POINT = OLD_MP;                                      00725700
                     PRINTING_ENABLED=SAVE_PE;                                  00725800
                     TOP_OF_PARM_STACK=OLD_TOPS;                                00725900
                  END;                                                          00726000
     /*DR109076*/ IF STMT_STACK(STMT_PTR)=SEMI_COLON & STMT_END_PTR=STMT_PTR
                     THEN DO;                                       /*DR109076*/
                          CALL OUTPUT_WRITER(LAST_WRITE,STMT_PTR);  /*DR109076*/
                     END;                                           /*DR109076*/
PUSH_MACRO:       PROCEDURE;                                                    00726100
                     SUPPRESS_THIS_TOKEN_ONLY = FALSE;                          00726200
                     /* DR104674: GET NEXT NON-BLANK BEFORE*/
                     /*           PARAMETER_PROCESSING     */
                     DO WHILE NEXT_CHAR=BYTE(X1);                   /*CR13335*/ 00682100
                        CALL STREAM;                                            00682200
                     END;                                                       00682300
                     IF MACRO_EXPAN_LEVEL+1 > MACRO_EXPAN_LIMIT THEN            00726300
                        DO;                                                     00726400
                        CALL ERROR(CLASS_IR,9,BCD);                             00726500
                        MACRO_EXPAN_LEVEL,PARM_EXPAN_LEVEL,MACRO_FOUND=0;       00726600
                        NEXT_CHAR=SAVE_NEXT_CHAR;                               00726700
                        OVER_PUNCH=SAVE_OVER_PUNCH;                             00726800
                        PRINTING_ENABLED=PRINT_FLAG;                            00726900
                        RETURN;                                                 00727000
                     END;                                                       00727100
                     MACRO_EXPAN_STACK(MACRO_EXPAN_LEVEL+1) = SYT_INDEX;        00727200
                     IF PRINTING_ENABLED=PRINT_FLAG THEN DO;                    00727300
                        RESTORE=PRINT_FLAG;                                     00727400
                        IF FOUND_CENT THEN DO;                                  00727500
                           PASS=PRINT_FLAG;                                     00727600
                           PRINTING_ENABLED=0;                                  00727700
                        END;                                                    00727800
                        ELSE PASS=0;                                            00727900
                     END;                                                       00728000
                     ELSE RESTORE,PASS=0;                                       00728100
                     CALL SAVE_TOKEN(ID_TOKEN,BCD,7);                           00728200
                     GRAMMAR_FLAGS(STMT_PTR) = GRAMMAR_FLAGS(STMT_PTR)          00728210
                        | MACRO_ARG_FLAG;                                       00728220
                     NUM_OF_PARM(MACRO_EXPAN_LEVEL+1)=                          00728300
                        VAR_LENGTH(SYT_INDEX);                                  00728400
                     CALL PARAMETER_PROCESSING;                                 00728500
                     PRINTING_ENABLED=PASS;                                     00728600
                     IF TEMP_STRING = '' THEN DO;                               00728700
                        BASE_PARM_LEVEL(MACRO_EXPAN_LEVEL)=PARM_EXPAN_LEVEL;    00728800
                        M_TOKENS(MACRO_EXPAN_LEVEL)=0;                          00728900
                        M_CENT(MACRO_EXPAN_LEVEL)=FOUND_CENT;                   00729000
                        M_PRINT(MACRO_EXPAN_LEVEL)=RESTORE;                     00729100
                        FOUND_CENT=FALSE;                                       00729200
                        MACRO_POINT = SYT_ADDR(SYT_INDEX);                      00729300
                        IF MACRO_EXPAN_LEVEL = 1 THEN DO;                       00729400
                           MACRO_FOUND = TRUE ;                                 00729500
                           SAVE_NEXT_CHAR=NEXT_CHAR;                            00729600
                           SAVE_OVER_PUNCH = OVER_PUNCH;                        00729700
                           BLANK_COUNT,OVER_PUNCH=0;                            00729800
                        END;                                                    00729900
                     END;                                                       00730000
                     ELSE FOUND_CENT=FALSE;                                     00730100
                     CALL STREAM;                                               00730200
                     RETURN;                                                    00730300
                  END PUSH_MACRO;                                               00730400
                  CALL PUSH_MACRO;                                              00730500
                  GO TO SCAN_START;                                             00730600
               END;                                                             00730700
               ELSE IF ^MACRO_FOUND THEN                                        00730800
                  SAVE_BLANK_COUNT = -1;                                        00730900
               GO TO SCAN_END;                                                  00731000
            END; /* OF CASE 2 */                                                00731100
            DO; /* CASE 3--SPECIAL SINGLE CHARACTERS */                         00731200
               IF OVER_PUNCH ^= 0 THEN                                          00731300
                  CALL ERROR(CLASS_MO,1);                                       00731400
               TOKEN = TX(NEXT_CHAR);                                           00731500
               CHAR_NEEDED = TRUE;                                              00731600
               GO TO SCAN_END;                                                  00731700
            END; /* OF CASE 3 */                                                00731800
            DO; /* CASE 4--PERIOD */                                            00731900
 /* COULD BE DOT PRODUCT OR DECIMAL POINT */                                    00732000
               IF OVER_PUNCH ^= 0 THEN                                          00732100
                  CALL ERROR(CLASS_MO,1);                                       00732200
               CALL BUILD_BCD;                                                  00732300
               CALL STREAM;                                                     00732400
               IF CHARTYPE(NEXT_CHAR) = 1 THEN                                  00732500
                  DO;                                                           00732600
                  DEC_POINT = TRUE;                                             00732700
                  CALL BUILD_BCD;                                               00732800
                  TOKEN = NUMBER;                                               00732900
                  DIGIT = NEXT_CHAR;                                            00733000
                  IF OVER_PUNCH ^= 0 THEN                                       00733100
                     CALL ERROR(CLASS_MO,1);                                    00733200
                  RESERVED_WORD = FALSE;                                        00733300
                  GO TO DEC_POINT_ENTRY;                                        00733400
               END;                                                             00733500
               TOKEN = TX(BYTE(PERIOD));                            /*CR13335*/ 00733600
               GO TO SCAN_END;                                                  00733700
            END;  /* OF CASE 4 */                                               00733800
            DO;  /* CASE 5--SINGLE QUOTE = CHARACTER LITERAL */                 00733900
               I = 0;                                                           00734000
               STRING_OVERFLOW, RESERVED_WORD = FALSE;                          00734100
               IF OVER_PUNCH ^= 0 THEN                                          00734200
                  CALL ERROR(CLASS_MO, 5);                                      00734300
               TOKEN = CHARACTER_STRING;                                        00734400
               GO TO CHECK;                                                     00734500
               DO WHILE NEXT_CHAR ^= BYTE(SQUOTE);                  /*CR13335*/ 00734600
BUILD:                                                                          00734700
                  IF NEXT_CHAR ^= BYTE(X1) THEN                     /*CR13335*/ 00734800
                     BLANK_COUNT = 0;                                           00734900
                  DO I = 0 TO BLANK_COUNT;                                      00735000
                     IF LENGTH(BCD) < CHAR_LENGTH_LIM THEN                      00735100
                        CALL BUILD_BCD;                                         00735200
                     ELSE                                                       00735300
                        DO;                                                     00735400
                        CALL ERROR(CLASS_LS,1);                                 00735500
STR_TOO_LONG:                                                                   00735600
                        STRING_OVERFLOW = TRUE;                                 00735700
                        GO TO SCAN_END;                                         00735800
                     END;                                                       00735900
                  END;                                                          00736000
CHECK:                                                                          00736100
                  CALL STREAM;                                                  00736200
                  ESCAPE_LEVEL = -1;                                            00736300
                  DO WHILE NEXT_CHAR = ESCP;                                    00736400
                     ESCAPE_LEVEL = ESCAPE_LEVEL + 1;                           00736500
                     IF OVER_PUNCH ^= 0 THEN                                    00736600
                        CALL ERROR(CLASS_MO, 8);                                00736700
                     CALL STREAM;                                               00736800
                  END;                                                          00736900
                  TEMP_CHAR = CHAR_OP_CHECK(NEXT_CHAR);                         00737000
                  IF ESCAPE_LEVEL >= 0 THEN DO;                                 00737100
                     IF ESCAPE_LEVEL > 1 THEN DO;                               00737200
                        CALL ERROR(CLASS_MO, 7, HEX(NEXT_CHAR, 2));             00737300
                        ESCAPE_LEVEL = 1;                                       00737400
                     END;                                                       00737500
                     OVER_PUNCH = CHAR_OP(ESCAPE_LEVEL);                        00737600
 /*CR13335*/         IF NEXT_CHAR = BYTE(X1) THEN DO;   /* HANDLE MULT BLANKS   00737700
                                                        CAREFULLY */            00737800
                        NEXT_CHAR = CHAR_OP_CHECK(TEMP_CHAR);                   00737900
                        IF BLANK_COUNT > 0 THEN DO;                             00738000
                           IF LENGTH(BCD) < MAX_STRING_SIZE THEN                00738100
                              CALL BUILD_BCD;                                   00738200
                           ELSE GO TO STR_TOO_LONG;                             00738300
                           BLANK_COUNT = BLANK_COUNT - 1;                       00738400
                           NEXT_CHAR = BYTE(X1);                    /*CR13335*/ 00738500
                        END;                                                    00738600
                     END;                                                       00738700
                     ELSE                                                       00738800
                        NEXT_CHAR = CHAR_OP_CHECK(TEMP_CHAR);                   00738900
                  END;  /* OF ESCAPE LEVEL >= 0 */                              00739000
                  ELSE NEXT_CHAR = TEMP_CHAR;                                   00739100
               END; /* OF DO WHILE... */                                        00739200
               CALL STREAM;                                                     00739300
               IF NEXT_CHAR ^= BYTE(SQUOTE) THEN                    /*CR13335*/ 00739400
                  DO;                                                           00739500
                  VALUE = LENGTH(BCD);                                          00739600
                  GO TO SCAN_END;                                               00739700
               END;                                                             00739800
               IF OVER_PUNCH ^= 0 THEN                                          00739900
                  CALL ERROR(CLASS_MO,1);                                       00740000
               GO TO BUILD;                                                     00740100
            END; /* OF CASE 5 */                                                00740200
            DO WHILE NEXT_CHAR = BYTE(X1);  /* CASE 6--BLANK */     /*CR13335*/ 00740300
               DONT_SET_WAIT = TRUE;        /* DR111335 */
               CALL STREAM;                                                     00740400
               DONT_SET_WAIT = FALSE;       /* DR111335 */
            END; /* OF CASE 6 */                                                00740500
            DO; /* CASE 7--'|' OR'||' */                                        00740600
               TOKEN = TX(NEXT_CHAR);                                           00740700
               IF OVER_PUNCH ^= 0 THEN                                          00740800
                  CALL ERROR(CLASS_MO,1);                                       00740900
               CALL STREAM;                                                     00741000
               IF NEXT_CHAR ^= BYTE('|') THEN                                   00741100
                  GO TO SCAN_END;                                               00741200
               IF OVER_PUNCH ^= 0 THEN                                          00741300
                  CALL ERROR(CLASS_MO,1);                                       00741400
               TOKEN = CONCATENATE;                                             00741500
               CALL STREAM;                                                     00741600
               GO TO SCAN_END;                                                  00741700
            END; /* OF CASE 7 */                                                00741800
            DO;  /* CASE 8--'*' OR '**' */                                      00741900
               TOKEN = TX(NEXT_CHAR);                                           00742000
               IF OVER_PUNCH ^= 0 THEN                                          00742100
                  CALL ERROR(CLASS_MO,1);                                       00742200
               CALL STREAM;                                                     00742300
               IF NEXT_CHAR ^= BYTE('*') THEN                                   00742400
                  GO TO SCAN_END;                                               00742500
               IF OVER_PUNCH ^= 0 THEN                                          00742600
                  CALL ERROR(CLASS_MO,1);                                       00742700
               TOKEN = EXPONENTIATE;                                            00742800
               CALL STREAM;                                                     00742900
               GO TO SCAN_END;                                                  00743000
            END; /* OF CASE 8 */                                                00743100
            DO;  /* CASE 9--HEX'FE' = EOF */                                    00743200
               TOKEN = EOFILE;                                                  00743300
               CALL STREAM;                                                     00743400
               GO TO SCAN_END;                                                  00743500
            END;  /* OF CASE 9 */                                               00743600
            DO;  /* CASE 10--SPECIAL CHARACTERS TREATED AS BLANKS */            00743700
               NEXT_CHAR = BYTE(X1);                                /*CR13335*/ 00743800
               BLANK_COUNT = 0;                                                 00743900
            END;  /* OF CASE 10 */                                              00744000
            DO;  /* CASE 11--DOUBLE QUOTES FOR REPLACE DEFINITION */            00744100
               TOKEN = REPLACE_TEXT;                                            00744200
               TEMP_STRING=X1;                                                  00744300
               BLANK_BYTES = 0;                                                 00744310
               T_INDEX,START_POINT = FIRST_FREE;                                00744700
               DO FOREVER;                                                      00744800
                  CALL STREAM;                                                  00744900
                  IF NEXT_CHAR = BYTE('"') THEN DO;                             00745000
                     CALL STREAM;                                               00745100
                     IF NEXT_CHAR ^= BYTE('"') THEN DO;                         00745200
                        FIRST_FREE = T_INDEX;                                   00745300
                        CALL FINISH_MACRO_TEXT;                                 00745400
                        GO TO SCAN_END;                                         00745500
                     END;                                                       00745600
                  END;                                                          00745700
CONCAT:           NEXT_ELEMENT(MACRO_TEXTS);                                    00746900
                  MACRO_TEXT(T_INDEX) = NEXT_CHAR;                              00746910
                  T_INDEX = T_INDEX + 1;                                        00746920
                  IF NEXT_CHAR = BYTE(X1) THEN                      /*CR13335*/ 00747500
                     IF BLANK_COUNT > 0 THEN DO;                                00747600
                     MACRO_TEXT(T_INDEX-1) = "EE";                              00747700
                     NEXT_ELEMENT(MACRO_TEXTS);                                 00747710
                     NEXT_ELEMENT(MACRO_TEXTS);                                 00747720
                     IF BLANK_COUNT < 256 THEN DO;                              00747800
                        MACRO_TEXT(T_INDEX) = BLANK_COUNT;                      00747900
                        BLANK_BYTES = BLANK_BYTES + BLANK_COUNT-1;              00747910
                        T_INDEX = T_INDEX+1;                                    00748000
                     END;                                                       00748100
                     ELSE DO;                                                   00748200
                        MACRO_TEXT(T_INDEX) = 255;                              00748300
                        BLANK_BYTES = BLANK_BYTES + 254;                        00748310
                        BLANK_COUNT=BLANK_COUNT-255;                            00748400
                        T_INDEX=T_INDEX+1;                                      00748500
                        GO TO CONCAT;                                           00748600
                     END;                                                       00748700
                  END;                                                          00748800
               END; /* OF DO FOREVER */                                         00748900
            END;    /* OF CASE 11 */                                            00749000
            DO;    /*  CASE 12 - % FOR %MACROS  */                              00749100
               RESERVED_WORD,STRING_OVERFLOW=FALSE;                             00749200
               TOKEN=PERCENT_MACRO;                                             00749300
               DO FOREVER;                                                      00749400
                  IF LENGTH(BCD)<PC_LIMIT THEN CALL BUILD_BCD;                  00749500
                  ELSE STRING_OVERFLOW=TRUE;                                    00749600
                  IF OVER_PUNCH^=0 THEN CALL ERROR(CLASS_MO,1);                 00749700
                  CALL STREAM;                                                  00749800
                  IF ^LETTER_OR_DIGIT(NEXT_CHAR) THEN DO;                       00749900
                     IF STRING_OVERFLOW THEN CALL ERROR(CLASS_IL,2);            00750000
                     S1=LENGTH(BCD);                                            00750100
                     DO SYT_INDEX=1 TO PC_INDEX;                                00750200
                        IF SUBSTR(PCNAME,SHL(SYT_INDEX,4),S1)=BCD THEN          00750300
                           GO TO SCAN_END;                                      00750400
                     END;                                                       00750500
                     CALL ERROR(CLASS_XM,1,BCD);                                00750600
                     SYT_INDEX=0;                                               00750700
                     GO TO SCAN_END;                                            00750800
                  END;                                                          00750900
               END;                                                             00751000
            END;   /*  END OF CASE 12  */                                       00751100
            DO;    /*  CASE 13 - ¢ FOR ¢MACROS  */                              00751200
CASE13:                                                                         00751300
               SOME_BCD=BCD;                                                    00751400
               BCD='';                                                          00751500
               CALL STREAM;                                                     00751600
               DO FOREVER;                                                      00751700
                  IF LETTER_OR_DIGIT(NEXT_CHAR) THEN CALL ID_LOOP;              00751800
                  ELSE GO TO END_OF_CENT;                                       00751900
               END;                                                             00752000
END_OF_CENT:                                                                    00752100
               FOUND_CENT=TRUE;                                                 00752200
               IF NEXT_CHAR=BYTE('¢') THEN DO;                                  00752300
                  IF PARM_FOUND THEN DO;                                        00752400
                     IF SOME_BCD='' THEN GO TO SCAN_START;                      00752500
                     BCD=SOME_BCD;                                              00752600
                     GO TO CENT_START;                                          00752700
                  END;                                                          00752800
                  ELSE DO;                                                      00752900
                     CALL IDENTIFY(BCD,1);                                      00753000
                     IF TOKEN<0 THEN DO;                                        00753100
                        CALL PUSH_MACRO;                                        00753200
                        IF SOME_BCD='' THEN GO TO SCAN_START;                   00753300
                        SYT_INDEX=0;                                            00753400
                        BCD=SOME_BCD;                                           00753500
                        GO TO CENT_START;                                       00753600
                     END;                                                       00753700
                     ELSE DO;                                                   00753800
                        CALL ERROR(CLASS_IR,4,BCD);                             00753900
                        GO TO SCAN_START;                                       00754000
                     END;                                                       00754100
                  END;                                                          00754200
               END;                                                             00754300
               ELSE DO;                                                         00754400
                  CALL IDENTIFY(BCD,1);                                         00754500
                  IF TOKEN<0 THEN DO;                                           00754600
                     CALL PUSH_MACRO;                                           00754700
                     GO TO SCAN_START;                                          00754800
                  END;                                                          00754900
                  ELSE DO;                                                      00755000
                     CALL ERROR(CLASS_IR,4,BCD);                                00755100
                     GO TO SCAN_START;                                          00755200
                  END;                                                          00755300
               END;                                                             00755400
            END;   /*  END OF CASE 13  */                                       00755500
         END; /* OF DO CASE... */                                               00755600
      END; /* OF DO FOREVER */                                                  00755700
BUILD_COMMENT:                                                                  00755800
      PROCEDURE;                                                                00755900
         IF NEXT_CHAR ^= BYTE(X1) THEN BLANK_COUNT = 0;             /*CR13335*/ 00756000
         DO BLANK_COUNT = 0 TO BLANK_COUNT;                                     00756100
            COMMENT_COUNT = COMMENT_COUNT + 1;                                  00756200
            IF COMMENT_COUNT >= 256 THEN                                        00756300
               IF COMMENT_COUNT = 256 THEN CALL ERROR(CLASS_M, 3);              00756400
            COMMENT_PTR = MIN(COMMENT_COUNT, 255);                              00756500
            BYTE(SAVE_COMMENT, COMMENT_PTR) = NEXT_CHAR;                        00756600
         END;                                                                   00756700
      END BUILD_COMMENT;                                                        00756800
                                                                                00756900
SCAN_END:                                                                       00757000
      IF CHAR_ALREADY_SCANNED ^= 0 THEN DO;                                     00757100
         NEXT_CHAR = CHAR_ALREADY_SCANNED;                                      00757200
         CHAR_ALREADY_SCANNED = 0;                                              00757300
         CHAR_NEEDED = FALSE;                                                   00757400
         OVER_PUNCH = OVERPUNCH_ALREADY_SCANNED;                                00757500
TEST_SEARCH:                                                                    00757600
         IF SEARCH_NEEDED THEN DO;                                              00757700
            SEARCH_NEEDED = FALSE;                                              00757800
            GO TO SCAN_TOP;                                                     00757900
         END;                                                                   00758000
         RETURN;                                                                00758100
      END;                                                                      00758200
LOOK_FOR_COMMENT:                                                               00758300
      IF GROUP_NEEDED & MACRO_EXPAN_LEVEL=0 THEN DO;                            00758400
SET_SEARCH:                                                                     00758500
         IF SEARCH_NEEDED THEN DO;                                              00758600
            CALL STREAM;                                                        00758700
            CHAR_NEEDED = FALSE;                                                00758800
            GO TO SCAN_END;                                                     00758900
         END;                                                                   00759000
         SEARCH_NEEDED = CHAR_NEEDED;  /* NO SEARCH NEEDED IF CHAR_NEEDED       00759100
                                          IS NOT ON BECAUSE THE GROUP_NEEDED    00759200
                                          CONDITION MUST BE CAUSED BY A LOOK    00759300
                                          AHEAD IN NEXT_CHAR WHICH REALLY WAS   00759400
                                          IN COLUMN 80 AND WILL BE SCANNED OUT  00759500
                                          NEXT TIME */                          00759600
         RETURN;                                                                00759700
      END;                                                                      00759800
      ELSE IF CHAR_NEEDED THEN DO;                                              00759900
         CHAR_NEEDED = FALSE;                                                   00760000
         CALL STREAM;                                                           00760100
      END;                                                                      00760200
      DO WHILE NEXT_CHAR = BYTE(X1);                                /*CR13335*/ 00760300
         IF M_TOKENS(MACRO_EXPAN_LEVEL) <= 1 THEN     /*DR111335*/              00760400
            RETURN;                                                             00760600
         IF GROUP_NEEDED&MACRO_EXPAN_LEVEL=0 THEN DO;                           00760900
            CHAR_NEEDED = TRUE;                                                 00761000
            GO TO SET_SEARCH;                                                   00761100
         END;                                                                   00761200
         ELSE CALL STREAM;                                                      00761300
      END;                                                                      00761400
      IF (NEXT_CHAR ^= BYTE('/')) | GROUP_NEEDED THEN GO TO TEST_SEARCH;        00761500
      IF OVER_PUNCH ^= 0 THEN CALL ERROR(CLASS_MO, 1);                          00761600
      CALL STREAM;  /* LOOK AT NEXT CHAR */                                     00761700
      IF NEXT_CHAR ^= BYTE('*') THEN DO;  /* NOT REALLY A COMMENT */            00761800
         CHAR_ALREADY_SCANNED = NEXT_CHAR;                                      00761900
         NEXT_CHAR = BYTE('/');                                                 00762000
         OVERPUNCH_ALREADY_SCANNED = OVER_PUNCH;                                00762100
         GO TO TEST_SEARCH;                                                     00762200
      END;                                                                      00762300
 /* IF WE GET HERE, WE HAVE A GENUINE COMMENT */                                00762400
      IF OVER_PUNCH ^= 0 THEN CALL ERROR(CLASS_MO, 1);                          00762500
      GO TO SEARCH_NEXT_CHAR;                                                   00762600
      DO WHILE NEXT_CHAR ^= BYTE('/');                                          00762700
STORE_NEXT_CHAR:                                                                00762800
         CALL BUILD_COMMENT;                                                    00762900
SEARCH_NEXT_CHAR:                                                               00763000
         IF GROUP_NEEDED THEN DO;                                               00763100
            CHAR_NEEDED = TRUE;                                                 00763200
            GO TO SET_SEARCH;                                                   00763300
         END;                                                                   00763400
         CALL STREAM;                                                           00763500
         IF OVER_PUNCH ^= 0 THEN CALL ERROR(CLASS_MO, 1);                       00763600
      END;                                                                      00763700
      IF BYTE(SAVE_COMMENT, COMMENT_PTR) ^= BYTE('*') THEN                      00763800
         GO TO STORE_NEXT_CHAR;                                                 00763900
      COMMENT_COUNT = COMMENT_COUNT - 1;  /* UNSAVE THE '*' */                  00764000
      COMMENT_PTR = COMMENT_PTR - 1;  /* HERE TOO */                            00764100
      CHAR_NEEDED = TRUE;                                                       00764200
      GO TO LOOK_FOR_COMMENT;                                                   00764300
   END SCAN  /* $S */ ; /* $S */                                                00764400
