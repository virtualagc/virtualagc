 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   OUTPUTWR.xpl
    Purpose:    This is a part of "Phase 1" (syntax analysis) of the HAL/S-FC 
                compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-07 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  OUTPUT_WRITER                                          */
 /* MEMBER NAME:     OUTPUTWR                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR_START         BIT(16)                                      */
 /*          PTR_END           BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ATTACH            CHARACTER                                    */
 /*          BUILD_E           CHARACTER;                                   */
 /*          BUILD_E_IND(100)  BIT(8)                                       */
 /*          BUILD_E_UND(100)  BIT(8)                                       */
 /*          BUILD_M           CHARACTER;                                   */
 /*          BUILD_S           CHARACTER;                                   */
 /*          BUILD_S_IND(100)  BIT(8)                                       */
 /*          BUILD_S_UND(100)  BIT(8)                                       */
 /*          CHECK_FOR_FUNC    LABEL                                        */
 /*          COMMENT_LOC       MACRO                                        */
 /*          CURRENT_ERROR_PTR BIT(16)                                      */
 /*          DOLLAR_CHECK1     LABEL                                        */
 /*          DOLLAR_CHECK2     LABEL                                        */
 /*          E_BEGIN           LABEL                                        */
 /*          E_CHAR_PTR        BIT(16)                                      */
 /*          E_CHAR_PTR_MAX    BIT(16)                                      */
 /*          E_FULL            LABEL                                        */
 /*          E_LEVEL           BIT(16)                                      */
 /*          E_LOOP            LABEL                                        */
 /*          E_PTR             BIT(16)                                      */
 /*          ERROR_PRINT       LABEL                                        */
 /*          ERRORCODE         CHARACTER;                                   */
 /*          ERRORS_PRINTED    BIT(8)                                       */
 /*          EXP_END(10)       BIT(16)                                      */
 /*          EXP_START(10)     BIT(16)                                      */
 /*          EXPAND            LABEL                                        */
 /*          FIND_ONLY         BIT(8)                                       */
 /*          FULL_LINE         LABEL                                        */
 /*          IMBEDDING         BIT(8)                                       */
 /*          INCLUDE_COUNT     BIT(16)                                      */
 /*          INCR_EXP_START    LABEL                                        */
 /*          INCR_SUB_START    LABEL                                        */
 /*          INDENT_LIMIT      MACRO                                        */
 /*          LABEL_END         BIT(16)                                      */
 /*          LABEL_START       BIT(16)                                      */
 /*          LAST_ERROR_WRITTEN  BIT(16)                                    */
 /*          LINE_CONTINUED    BIT(8)                                       */
 /*          LINE_FULL         BIT(8)                                       */
 /*          LINESIZE          MACRO                                        */
 /*          M_CHAR_PTR        FIXED                                        */
 /*          M_CHAR_PTR_MAX    BIT(16)                                      */
 /*          M_PTR             BIT(16)                                      */
 /*          M_UNDERSCORE      CHARACTER;                                   */
 /*          M_UNDERSCORE_NEEDED  BIT(8)                                    */
 /*          MACRO_WRITTEN     BIT(8)                                       */
 /*          MATCH             LABEL                                        */
 /*          MAX_E_LEVEL       BIT(16)                                      */
 /*          MAX_S_LEVEL       BIT(16)                                      */
 /*          MORE_E_C          LABEL                                        */
 /*          MORE_M_C          LABEL                                        */
 /*          MORE_S_C          LABEL                                        */
 /*          OUTPUT_WRITER_BEGINNING  LABEL                                 */
 /*          OUTPUT_WRITER_END LABEL                                        */
 /*          PRINT_ANY_ERRORS  LABEL                                        */
 /*          PRINT_TEXT        LABEL                                        */
 /*          PRNTERRWARN       BIT(8)                                       */
 /*          PTR               BIT(16)                                      */
 /*          PTR_LOOP_END      LABEL                                        */
 /*          RESET             LABEL                                        */
 /*          S_BEGIN           LABEL                                        */
 /*          S_CHAR_PTR        BIT(16)                                      */
 /*          S_CHAR_PTR_MAX    BIT(16)                                      */
 /*          S_FULL            LABEL                                        */
 /*          S_LEVEL           BIT(16)                                      */
 /*          S_LOOP            LABEL                                        */
 /*          S_PTR             BIT(16)                                      */
 /*          SAVE_E_C(2)       CHARACTER;                                   */
 /*          SAVE_MAX_E_LEVEL  BIT(16)                                      */
 /*          SAVE_MAX_S_LEVEL  BIT(16)                                      */
 /*          SAVE_S_C(2)       CHARACTER;                                   */
 /*          SDL_INFO          CHARACTER;                                   */
 /*          SEVERITY          BIT(16)                                      */
 /*          SKIP_REPL         LABEL                                        */
 /*          SPACE_NEEDED      BIT(16)                                      */
 /*          SUB_END(10)       BIT(16)                                      */
 /*          SUB_START(10)     BIT(16)                                      */
 /*          T                 CHARACTER;                                   */
 /*          TEMP              FIXED                                        */
 /*          UNDER_LINE        CHARACTER;                                   */
 /*          UNDERLINING       BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CHAR_OP                                                        */
 /*          CHARACTER_STRING                                               */
 /*          CLASS_BI                                                       */
 /*          COMM                                                           */
 /*          CURRENT_SCOPE                                                  */
 /*          DO_LEVEL                                                       */
 /*          DO_STMT#                                                       */
 /*          DOLLAR                                                         */
 /*          DOT_TOKEN                                                      */
 /*          DOUBLE                                                         */
 /*          END_FLAG                                                       */
 /*          ERRLIM                                                         */
 /*          ERROR_PTR                                                      */
 /*          ESCP                                                           */
 /*          EXPONENTIATE                                                   */
 /*          FALSE                                                          */
 /*          FUNC_FLAG                                                      */
 /*          INCLUDE_END                                                    */
 /*          INCLUDING                                                      */
 /*          INLINE_FLAG                                                    */
 /*          LABEL_FLAG                                                     */
 /*          LEFT_BRACE_FLAG                                                */
 /*          LEFT_BRACKET_FLAG                                              */
 /*          LEFT_PAREN                                                     */
 /*          LINE_LIM                                                       */
 /*          MAC_NUM                                                        */
 /*          MAC_TXT                                                        */
 /*          MACRO_ARG_FLAG                                                 */
 /*          MACRO_TEXTS                                                    */
 /*          MACRO_TEXT                                                     */
 /*          MAJ_STRUC                                                      */
 /*          NEST_LEVEL                                                     */
 /*          NT                                                             */
 /*          OUTPUT_WRITER_DISASTER                                         */
 /*          OVER_PUNCH_TYPE                                                */
 /*          PAD1                                                           */
 /*          PAD2                                                           */
 /*          PAGE                                                           */
 /*          PLUS                                                           */
 /*          PRINT_FLAG                                                     */
 /*          PRINT_FLAG_OFF                                                 */
 /*          RECOVERING                                                     */
 /*          REPLACE_TEXT                                                   */
 /*          RIGHT_BRACE_FLAG                                               */
 /*          RIGHT_BRACKET_FLAG                                             */
 /*          RT_PAREN                                                       */
 /*          SAVE_BCD                                                       */
 /*          SAVE_COMMENT                                                   */
 /*          SAVE_ERROR_MESSAGE                                             */
 /*          SAVE_STACK_DUMP                                                */
 /*          SCALAR_TYPE                                                    */
 /*          SDL_OPTION                                                     */
 /*          SPACE_FLAGS                                                    */
 /*          SRN                                                            */
 /*          SRN_COUNT                                                      */
 /*          SRN_PRESENT                                                    */
 /*          STMT_END_FLAG                                                  */
 /*          STMT_NUM                                                       */
 /*          STRUC_TOKEN                                                    */
 /*          SYM_ADDR                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_ADDR                                                       */
 /*          TOKEN_FLAGS                                                    */
 /*          TRANS_OUT                                                      */
 /*          TRUE                                                           */
 /*          TX                                                             */
 /*          VBAR                                                           */
 /*          VOCAB_INDEX                                                    */
 /*          X1                                                             */
 /*          X70                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BCD_PTR                                                        */
 /*          COMPILING                                                      */
 /*          C                                                              */
 /*          COMMENT_COUNT                                                  */
 /*          ELSEIF_PTR                                                     */
 /*          ERROR_COUNT                                                    */
 /*          GRAMMAR_FLAGS                                                  */
 /*          I                                                              */
 /*          INCLUDE_CHAR                                                   */
 /*          INDENT_LEVEL                                                   */
 /*          INFORMATION                                                    */
 /*          INLINE_INDENT                                                  */
 /*          INLINE_INDENT_RESET                                            */
 /*          J                                                              */
 /*          K                                                              */
 /*          L                                                              */
 /*          LABEL_COUNT                                                    */
 /*          LAST                                                           */
 /*          LAST_SPACE                                                     */
 /*          LAST_WRITE                                                     */
 /*          LINE_MAX                                                       */
 /*          MAX_SEVERITY                                                   */
 /*          NEXT_CC                                                        */
 /*          OUT_PREV_ERROR                                                 */
 /*          PAGE_THROWN                                                    */
 /*          STATEMENT_SEVERITY                                             */
 /*          S                                                              */
 /*          SAVE_LINE_#                                                    */
 /*          SAVE_SCOPE                                                     */
 /*          SAVE_SEVERITY                                                  */
 /*          SQUEEZING                                                      */
 /*          STACK_DUMP_PTR                                                 */
 /*          STACK_DUMPED                                                   */
 /*          STMT_END_PTR                                                   */
 /*          STMT_PTR                                                       */
 /*          STMT_STACK                                                     */
 /*          TOO_MANY_ERRORS                                                */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BLANK                                                          */
 /*          CHAR_INDEX                                                     */
 /*          CHECK_DOWN                                                     */
 /*          ERRORS                                                         */
 /*          I_FORMAT                                                       */
 /*          LEFT_PAD                                                       */
 /*          MAX                                                            */
 /*          MIN                                                            */
 /* CALLED BY:                                                              */
 /*          INTERPRET_ACCESS_FILE                                          */
 /*          PRINT_SUMMARY                                                  */
 /*          RECOVER                                                        */
 /*          SAVE_TOKEN                                                     */
 /*          STREAM                                                         */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> OUTPUT_WRITER <==                                                   */
 /*     ==> CHAR_INDEX                                                      */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> MIN                                                             */
 /*     ==> MAX                                                             */
 /*     ==> BLANK                                                           */
 /*     ==> LEFT_PAD                                                        */
 /*     ==> I_FORMAT                                                        */
 /*     ==> CHECK_DOWN                                                      */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /* 03/03/95 BAF  27V0  DR108629 STATEMENT NUMBER IN ERROR MESSAGE...       */
 /*               11V0   REMOVED PROCESSING FOR VARIABLE PREVIOUS_ERROR     */
 /*                       AND ADDED CHECK OF NO_LOOK_AHEAD_DONE FOR         */
 /*                       CALLS TO ERROR_PRINT.                             */
 /*                                                                         */
 /*                                                                         */
 /* 07/13/95 DAS  27V0  CR12416  IMPROVE COMPILER ERROR PROCESSING          */
 /*               11V0           (MAKE SEVERITY 3&4 ERRORS CAUSE ABORT)     */
 /*                                                                         */
 /* 01/25/96 DAS  27V1  DR109036 BAD SEVERITY 3 ERROR HANDLING IN PASS1     */
 /*               11V1                                                      */
 /*                                                                         */
 /* 12/20/96 SMR  28V0  CR12713  ENHANCE COMPILER LISTING                   */
 /*               12V0                                                      */
 /*                                                                         */
 /* 06/04/97 TEV  28V0/ DR109042 ERROR MESSAGE IS ON WRONG STATEMENT        */
 /*               12V0                                                      */
 /*                                                                         */
 /* 09/24/96 SMR  28V0  CR12157  MODIFY STATEMENT LABEL LIMITATION          */
 /*               12V0  DR108628 STATEMENT LABELS ARE NOT PRINTED IN        */
 /*                     PRIMARY (PASS1) LISTING                             */
 /*                                                                         */
 /* 02/22/98 SMR  29V0  CR12940  ENCHANCE COMPILER LISTING                  */
 /*               14V0                                                      */
 /*                                                                         */
 /* 02/06/98 DCP  29V0  DR109061 LEVEL NUMBER MISSING ON LINE WITH LABEL    */
 /*               14V0                                                      */
 /*                                                                         */
 /* 02/09/98 DCP  29V0  DR109066 LINE OF LABELS DOESN'T WRAP-AROUND         */
 /*               14V0                                                      */
 /*                                                                         */
 /* 11/14/97 DCP  29V0/ DR109062 SPACE MISSING IN MACRO TEXT                */
 /*               14V0                                                      */
 /*                                                                         */
 /* 11/12/98 JAC  29V0  DR109081 LOOKUP FAILURE FOR LONG TOKEN LISTS        */
 /*               14V0                                                      */
 /*                                                                         */
 /* 07/14/99 DCP  30V0  CR12214  USE THE SAFEST %MACRO THAT WORKS           */
 /*               15V0                                                      */
 /*                                                                         */
 /* 04/29/99 JAC  30V0  DR111326 STATEMENTS PRINTED INCORRECTLY AFTER       */
 /*               15V0           REPLACE MACRO                              */
 /*                                                                         */
 /* 03/10/99 SHH  30V0  DR109099 EXTRA LABEL PRINTED                        */
 /*               15V0                                                      */
 /*                                                                         */
 /* 04/26/01 DCP  31V0  CR13335  ALLEVIATE SOME DATA SPACE PROBLEMS         */
 /*               16V0           IN HAL/S COMPILER                          */
 /*                                                                         */
 /* 06/10/05 TKN  32V0  CR14122  CORRECT THE FUNNY CHARACTER IN THE HAL/S   */
 /*               17V0           COMPILER LISTING                           */
 /*                                                                         */
 /***************************************************************************/
                                                                                00290730
                                                                                00290900
 /*   INCLUDE CHECK_DOWN: $%CHECKDWN   */                                       00290901
OUTPUT_WRITER:                                                                  00291000
   PROCEDURE(PTR_START, PTR_END);                                               00291100
      DECLARE COMMENT_LOC LITERALLY '69';                                       00291200
      DECLARE LINESIZE LITERALLY '100',                                         00291300
         (E_PTR, M_PTR, S_PTR) BIT(16),                                         00291400
         PTR_START BIT(16), PTR_END BIT(16) INITIAL(-1),                        00291500
         LABEL_START BIT(16), LABEL_END BIT(16),                                00291600
         PRINT_LABEL BIT(1),                     /*DR108628, CR12157*/
         (S_LEVEL, E_LEVEL, MAX_S_LEVEL, MAX_E_LEVEL) BIT(16),                  00291700
         PTR BIT(16),                                                           00291800
         SPACE_NEEDED BIT(16),                                                  00291900
         MAX_LEVEL LITERALLY '10',                       /*DR109081*/
         (SUB_START, SUB_END) (MAX_LEVEL) BIT(16),       /*DR109081*/
         (EXP_START, EXP_END) (MAX_LEVEL) BIT(16),       /*DR109081*/
         LINE_FULL BIT(1),                                                      00292100
         FIND_ONLY BIT(1),                                                      00292200
         MACRO_WRITTEN BIT(1),                                                  00292300
         LINE_CONTINUED BIT(1),                                                 00292310
         (BUILD_S_IND, BUILD_E_IND) (LINESIZE) BIT(8);                          00292400
      DECLARE (BUILD_E_UND, BUILD_S_UND) (LINESIZE) BIT(8);                     00292500
      DECLARE (M_UNDERSCORE_NEEDED, UNDERLINING) BIT(1);                        00292600
      DECLARE M_UNDERSCORE CHARACTER INITIAL(           '                       00292700
                                                                             '),00292800
         UNDER_LINE CHARACTER INITIAL(                  '                       00292900
                                                                             ');00293000
      DECLARE BUILD_S CHARACTER INITIAL(                '                       00293100
                                                                             '),00293200
         BUILD_M CHARACTER INITIAL(                     '                       00293300
                                                                             '),00293400
         BUILD_E CHARACTER INITIAL(                     '                       00293500
                                                                             ');00293600
      DECLARE (S_CHAR_PTR, S_CHAR_PTR_MAX, E_CHAR_PTR, E_CHAR_PTR_MAX,          00293700
         M_CHAR_PTR_MAX) BIT(16), M_CHAR_PTR FIXED;                             00293800
      DECLARE (SAVE_S_C, SAVE_E_C)(2) CHARACTER;                                00293900
      DECLARE INDENT_LIMIT LITERALLY '69';                                      00294000
      DECLARE IMBEDDING BIT(1);                                                 00294100
      DECLARE PRNTERRWARN BIT(1) INITIAL(TRUE);                                 00294200
      DECLARE TEMP FIXED;                                                       00294300
      DECLARE SEVERITY BIT(16);                                                 00294400
      DECLARE ERRORCODE CHARACTER;                                              00294500
      DECLARE (SAVE_MAX_E_LEVEL, SAVE_MAX_S_LEVEL) BIT(16);                     00294600
      DECLARE (T, SDL_INFO) CHARACTER;                      /*CR12713*/         00294700
      DECLARE INCLUDE_COUNT BIT(16);                                            00294800
      DECLARE LAST_ERROR_WRITTEN BIT(16) INITIAL(-1);                           00294805
      DECLARE CURRENT_ERROR_PTR BIT(16) INITIAL(-1);                            00294810
      DECLARE ERRORS_PRINTED BIT(1);                                            00294815
      DECLARE IDX BIT(16);  /*TEMPORARY INTEGER*/          /*CR12940*/
      DECLARE C_RVL CHARACTER;                             /*CR12940*/
      DECLARE C_TMP CHARACTER; /*TEMORARY CHARACTER*/      /*CR12940*/
      DECLARE LABEL_TOO_LONG BIT(1);                        /*DR109061*/
      DECLARE CHAR CHARACTER;                              /*DR109066*/
                                                                                00294820
      ERRORS_PRINTED = FALSE;                       /*DR109081*/                00294825
      IF STMT_PTR < 0 THEN GO TO PRINT_ANY_ERRORS;                              00294830
      GO TO OUTPUT_WRITER_BEGINNING;  /* COLLECT A FEW BRANCHES */              00294835

ERROR_PRINT:                                                                    00294845
      PROCEDURE;                                                                00294850
         DECLARE C CHARACTER;                                                   00294852
         DECLARE NEW_SEVERITY FIXED;                                            00294853

         DO I = LAST_ERROR_WRITTEN + 1 TO CURRENT_ERROR_PTR;                    00294855
            ERRORS_PRINTED = TRUE;                                              00294860
            ERROR_COUNT = ERROR_COUNT + 1;                                      00294865
            SAVE_LINE_#(ERROR_COUNT) = STMT_NUM;                                00294870
            C = SAVE_ERROR_MESSAGE(I);                                          00294875
            ERRORCODE = SUBSTR(C, 0, 8); /* MEMBER NAME */                      00294880
            IF MONITOR(2, 5, ERRORCODE) THEN                                    00294885
               DO;                                                              00294890
               CALL ERRORS (CLASS_BI, 100, X1||ERRORCODE);          /*CR13335*/ 00294895
               GO TO ERROR_PRINT_END;                                           00294900
            END;                                                                00294905
            S = INPUT(5);  /* READ FROM ERROR FILE */                           00294910
            SEVERITY = BYTE(S) - BYTE('0');                                     00294915
            NEW_SEVERITY = CHECK_DOWN(ERRORCODE, SEVERITY);                     00294916
            SEVERITY = NEW_SEVERITY;                                            00294917
            SAVE_SEVERITY(ERROR_COUNT) = SEVERITY;                              00294920
            IF LENGTH(C) > 8 THEN                                               00294925
               DO;  /* SOME IMBEDDED TEXT EXISTS */                             00294930
               C = SUBSTR(C, 8);                                                00294935
               IMBEDDING = TRUE;                                                00294940
            END;                                                                00294945
            IF ERROR_COUNT>=ERRLIM-3 THEN                                       00294950
               DO;                                                              00294955
               MAX_SEVERITY = MAX(MAX_SEVERITY, 2);                             00294960
               IF PRNTERRWARN THEN                                              00294965
                  DO;                                                           00294970
                  PRNTERRWARN = FALSE;                                          00294975
                  CALL ERRORS (CLASS_BI, 106);                                  00294985
               END;                                                             00294990
               IF COMPILING THEN                                                00294995
                  COMPILING = FALSE;                                            00295000
               ELSE                                                             00295005
                  GO TO OUTPUT_WRITER_DISASTER;                                 00295010
            END;                                                                00295015
            OUTPUT(1) = '0***** ' || ERRORCODE || ' ERROR #' ||                 00295020
               ERROR_COUNT || ' OF SEVERITY ' || SEVERITY || '. *****';         00295025
            IF SEVERITY > MAX_SEVERITY THEN                                     00295030
               MAX_SEVERITY = SEVERITY;                                         00295035
            IF SEVERITY > STATEMENT_SEVERITY THEN                               00295040
               STATEMENT_SEVERITY = SEVERITY;                                   00295045
            S = INPUT(5);                                                       00295050
            DO WHILE LENGTH(S) > 0;                                             00295055
               IF IMBEDDING THEN                                                00295060
                  DO;                                                           00295065
                  K = CHAR_INDEX(S, '??');                                      00295070
                  IF K >= 0 THEN                                                00295075
                     DO;                                                        00295080
                     IF K = 0 THEN                                              00295085
                        S = C || SUBSTR(S, 2);                                  00295090
                     ELSE                                                       00295095
                        S = SUBSTR(S, 0, K) || C || SUBSTR(S, K + 2);           00295100
                     IMBEDDING = FALSE;                                         00295105
                  END;                                                          00295110
               END;                                                             00295115
               OUTPUT = STARS || X1 || S;                           /*CR13335*/ 00295120
               S = INPUT(5);                                                    00295125
            END;                                                                00295130
ERROR_PRINT_END:                                                                00295135
         END;  /* OF LOOP ON ERROR MSGS */                                      00295140
         LAST_ERROR_WRITTEN = CURRENT_ERROR_PTR;                                00295145
      END ERROR_PRINT;                                                          00295150
                                                                                00295155
ATTACH:                                                                         00295160
      PROCEDURE(PNTR, OFFSET) CHARACTER;                                        00295500
         DECLARE (PNTR, OFFSET) BIT(16);                                        00295600
         CURRENT_ERROR_PTR = MAX(CURRENT_ERROR_PTR, ERROR_PTR(PNTR));           00295710
         IF STMT_STACK(PNTR) = 0 THEN DO;                                       00295800
            SPACE_NEEDED = 0;                                                   00295900
            RETURN '';                                                          00296000
         END;                                                                   00296100
         IF (GRAMMAR_FLAGS(PNTR) & PRINT_FLAG) = 0 THEN                         00296200
            IF ^RECOVERING THEN                                                 00296300
            RETURN '';                                                          00296400
         GRAMMAR_FLAGS(PNTR) = GRAMMAR_FLAGS(PNTR) & PRINT_FLAG_OFF;            00296500
         SPACE_NEEDED = 1;                                                      00296600
         IF MACRO_WRITTEN THEN DO;                                              00296700
            MACRO_WRITTEN = FALSE;                                              00296800
            IF LAST_SPACE = 2 THEN                                              00296900
               IF SHR(TOKEN_FLAGS(PNTR), 6) = 0 THEN                            00297000
               IF STMT_STACK(PNTR) = LEFT_PAREN THEN                            00297100
               GO TO PARAM_MACRO;  /* LEAVE LAST_SPACE ALONE */                 00297200
            LAST_SPACE = 0;  /* FORCE A SPACE AFTER A NON-PARAM MACRO NAME */   00297300
         END;                                                                   00297400
PARAM_MACRO:                                                                    00297500
         L = SPACE_FLAGS(STMT_STACK(PNTR) + OFFSET);  /* SELECT LINE TYPE */    00297600
         I = SHR(L, 4) + LAST_SPACE;                                            00297700
         IF I ^> 4 THEN                                                         00297800
            IF I > 1 THEN                                                       00297900
            SPACE_NEEDED = 0;                                                   00298000
         IF SHR(TOKEN_FLAGS(PNTR), 5) THEN                                      00298100
            LAST_SPACE = 2;                                                     00298200
         ELSE                                                                   00298300
            LAST_SPACE = L & "0F";                                              00298400
         IF SHR(TOKEN_FLAGS(PNTR), 6) = 0 THEN                                  00298500
            C = STRING(VOCAB_INDEX(STMT_STACK(PNTR)));                          00298600
         ELSE                                                                   00298700
            DO;                                                                 00298800
            J = TOKEN_FLAGS(PNTR);                                              00298900
            C = SAVE_BCD(SHR(J, 6));  /* IDENTIFIER */                          00299000
            IF STMT_STACK(PNTR) = CHARACTER_STRING THEN                         00299100
               DO;                                                              00299200
ADD:                                                                            00299300
               PROCEDURE(STRING);                                               00299400
                  DECLARE STRING CHARACTER;                                     00299500
                  DECLARE T CHARACTER;                                          00299600
                  IF LENGTH(C(K)) + LENGTH(STRING) > 256 THEN                   00299700
                     DO;                                                        00299800
                     TEMP = 256 - LENGTH(C(K));                                 00299900
                     T = SUBSTR(STRING, 0, TEMP);                               00300000
                     C(K) = C(K) || T;                                          00300100
                     K = K + 1;                                                 00300200
                     C(K) = SUBSTR(STRING, TEMP);                               00300300
                  END;                                                          00300400
                  ELSE                                                          00300500
                     C(K) = C(K) || STRING;                                     00300600
               END ADD;                                                         00300700
               C(1), C(2) = '';                                                 00300800
               IF (GRAMMAR_FLAGS(PNTR) & MACRO_ARG_FLAG)^=0 THEN RETURN C;      00300900
               S = C;                                                           00301000
               C = SQUOTE;                                                      00301100
               I, J, K = 0;                                                     00301200
SEARCH:                                                                         00301300
 /*CR13335*/   DO WHILE (BYTE(S, I) ^= BYTE(SQUOTE)) & (I < LENGTH(S));         00301400
                  IF OFFSET ^= 0 THEN DO;  /* NOT AN M-LINE */                  00301500
                     IF (TRANS_OUT(BYTE(S, I)) & "FF") ^= 0 THEN DO;            00301600
                        IF I ^= J THEN                                          00301700
                           CALL ADD(SUBSTR(S, J, I - J));                       00301800
                        DO L = 0 TO SHR(TRANS_OUT(BYTE(S, I)), 8) & "FF";       00301900
                           CALL ADD(STRING(ADDR(ESCP)));                        00302000
                        END;                                                    00302100
                        CALL ADD(STRING(ADDR(TRANS_OUT(BYTE(S, I))) + 1));      00302200
                        J, I = I + 1;                                           00302300
                     END;                                                       00302400
                     ELSE I = I + 1;                                            00302500
                  END;                                                          00302600
                  ELSE I = I + 1;                                               00302700
               END;                                                             00302800
               IF I ^= J THEN                                                   00302900
                  CALL ADD(SUBSTR(S, J, I - J));                                00303000
               IF I ^= LENGTH(S) THEN                                           00303100
                  DO;                                                           00303200
                  CALL ADD(SQUOTE || SQUOTE);                                   00303300
                  I = I + 1;                                                    00303400
                  J = I;                                                        00303500
                  GO TO SEARCH;                                                 00303600
               END;                                                             00303700
               CALL ADD(SQUOTE);                                                00303800
               RETURN C;                                                        00303900
            END;                                                                00304000
            J = GRAMMAR_FLAGS(PNTR);                                            00304100
            IF (J & LEFT_BRACKET_FLAG) ^= 0 THEN                                00304200
               C = '[' || C;                                                    00304300
            IF (J & RIGHT_BRACKET_FLAG) ^= 0 THEN                               00304400
               C = C || ']';                                                    00304500
            IF (J & LEFT_BRACE_FLAG) ^= 0 THEN                                  00304600
               C = '{' || C; /*CR14122-RETYPED '{' TO CORRECT HEX CODE*/        00304700
            IF (J & RIGHT_BRACE_FLAG) ^= 0 THEN                                 00304800
               C = C || '}'; /*CR14122-RETYPED '}' TO CORRECT HEX CODE*/        00304900
         END;                                                                   00305000
         RETURN C;                                                              00305100
      END ATTACH;                                                               00305200
                                                                                00305300
                                                                                00305400
                                                                                00305500
                                                                                00305600
EXPAND:                                                                         00305700
      PROCEDURE(PTR);                                                           00305800
         DECLARE (C, CHAR) CHARACTER;                                           00305900
         DECLARE PTR BIT(16);                                                   00306000
         DECLARE (M_COMMENT_NEEDED,S_COMMENT_NEEDED,POST_COMMENT_NEEDED) BIT(1);00306100
         DECLARE (NUM_S_NEEDED, LOC, NUM) BIT(16);                              00306200
         DECLARE BUILD CHARACTER INITIAL(               '                       00306300
                                                                             ');00306400
         DECLARE FORMAT_CHAR CHARACTER INITIAL ('|');                           00306410
         IF (GRAMMAR_FLAGS(PTR) & STMT_END_FLAG) ^= 0 THEN                      00306500
            IF COMMENT_COUNT >= 0 THEN                                          00306600
            DO;                                                                 00306700
            COMMENT_COUNT = MIN(COMMENT_COUNT, 255);                            00306800
COMMENT_BRACKET:                                                                00306900
            PROCEDURE(STRING, LOC);                                             00307000
               DECLARE STRING CHARACTER, (LOC, I, J, PTR) BIT(16);              00307100
               BYTE(STRING, LOC) = BYTE('/');                                   00307200
               BYTE(STRING, LOC + 1) = BYTE('*');                               00307300
               LOC = LOC + 2;                                                   00307400
               DO I = PTR TO MIN(PTR + NUM, COMMENT_COUNT);                     00307500
                  J = BYTE(SAVE_COMMENT, I);                                    00307600
                  BYTE(STRING, LOC) = J;                                        00307700
                  LOC = LOC + 1;                                                00307800
               END;                                                             00307900
               BYTE(STRING, LOC) = BYTE('*');                                   00308000
               BYTE(STRING, LOC +1) = BYTE('/');                                00308100
               PTR = I;                                                         00308200
               NUM = MIN(NUM, COMMENT_COUNT - PTR + 1);                         00308300
               IF NUM <= 0 THEN                                                 00308400
                  DO;                                                           00308500
                  PTR = 0;                                                      00308600
                  COMMENT_COUNT = -1;                                           00308700
               END;                                                             00308800
            END COMMENT_BRACKET;                                                00308900
            COMMENT_COUNT = MIN(COMMENT_COUNT, 255);                            00309000
            I = COMMENT_COUNT;                                                  00309100
            DO WHILE BYTE(SAVE_COMMENT, COMMENT_COUNT) = BYTE(X1);  /*CR13335*/ 00309200
               COMMENT_COUNT = COMMENT_COUNT - 1;                               00309300
            END;                                                                00309400
            COMMENT_COUNT = COMMENT_COUNT + (COMMENT_COUNT ^= I);               00309500
            I = MAX(M_PTR, COMMENT_LOC + 1);                                    00309600
            IF COMMENT_COUNT < LINESIZE - I - 4 THEN                            00309700
               DO;  /* COMMENT WILL FIT ON M LINE */                            00309800
               M_COMMENT_NEEDED = TRUE;                                         00309900
               LOC = I;                                                         00310000
               NUM = COMMENT_COUNT;                                             00310100
            END;                                                                00310200
            ELSE IF COMMENT_COUNT < LINESIZE - M_PTR - 5 THEN                   00310300
               DO;  /* WILL FIT IF RIGHT JUSTIFIED */                           00310400
               M_COMMENT_NEEDED = TRUE;                                         00310500
               LOC = LINESIZE - COMMENT_COUNT - 5;                              00310600
               NUM = COMMENT_COUNT;                                             00310700
            END;                                                                00310800
            ELSE IF M_PTR < COMMENT_LOC THEN                                    00310900
               DO;  /* NEED MORE THAN ONE LINE */                               00311000
               M_COMMENT_NEEDED, S_COMMENT_NEEDED = TRUE;                       00311100
               LOC = M_PTR + 1;                                                 00311200
               NUM = LINESIZE - LOC - 5;                                        00311300
               NUM_S_NEEDED = (COMMENT_COUNT - 1) / NUM;                        00311400
               MAX_S_LEVEL = MAX(NUM_S_NEEDED, MAX_S_LEVEL);                    00311500
            END;                                                                00311600
            ELSE DO;                                                            00311700
               POST_COMMENT_NEEDED = TRUE;                                      00311800
               LOC = COMMENT_LOC;                                               00311900
               NUM = LINESIZE - LOC - 5;                                        00312000
            END;                                                                00312100
         END;                                                                   00312200
         IF MAX_E_LEVEL + MAX(MAX_S_LEVEL, SDL_OPTION) + 2 +                    00312300
            LINE_COUNT > LINE_MAX THEN                                          00312400
            C = PAGE;                                                           00312500
         ELSE                                                                   00312600
            C = NEXT_CC;                                                        00312700
         NEXT_CC = X1;      /* UNLESS CHANGED BELOW */     /*CR12713*/          00312800
         LINE_MAX = LINE_LIM;                                                   00312900
         S = I_FORMAT(STMT_NUM, 4);                                             00313000
         IF (INCLUDING | INCLUDE_END) THEN DO;                                  00313100
            INCLUDE_CHAR = PLUS;                                                00313200
            IF SRN_PRESENT THEN                                                 00313300
               S = LEFT_PAD(PLUS || INCLUDE_COUNT, 6) || X1 || S;               00313400
            T = PAD1;                                                           00313800
         END;                                                                   00313900
         ELSE DO;  /* NOT AN INCLUDED LINE */                                   00314000
            INCLUDE_CHAR = X1;                                                  00314100
            IF SRN_PRESENT THEN                                                 00314200
               S = SUBSTR(SDL_INFO, 0, 6) || X1 || S;  /* SRN */                00314300
            IF SDL_OPTION THEN DO;                                              00314400
               T = C_RVL;   /* RECORD REVISION INDICATOR */   /*CR12940*/
               IF LENGTH(SDL_INFO) >= 16 THEN                                   00314600
                  T = T || X1 || SUBSTR(SDL_INFO, 8, 8);                        00314700
               ELSE T = T || SUBSTR(X70, 0, 9);                                 00314800
            END;                                                                00314900
            ELSE T = PAD1;                                                      00315000
         END;                                                                   00315100
         IF MAX_E_LEVEL ^= 0 THEN DO;                                           00315200
            DO WHILE MAX_E_LEVEL ^= 0;                                          00315300
               CALL BLANK(BUILD, 0, LINESIZE);                                  00315400
               DO I = 0 TO LINESIZE - 1;                                        00315500
                  IF BUILD_E_IND(I) = MAX_E_LEVEL THEN                          00315600
                     DO;                                                        00315700
                     BUILD_E_IND(I)=0;                                          00315800
                     K = BYTE(BUILD_E, I);                                      00315900
                     BYTE(BUILD, I) = K;                                        00316000
                  END;                                                          00316100
                  IF BUILD_E_UND(I) = MAX_E_LEVEL THEN                          00316200
                     DO;  /* SOME UNDERLINING TO BE DONE */                     00316300
                     BUILD_E_UND(I) = 0;                                        00316400
                     BYTE(UNDER_LINE, I) = BYTE('_');                           00316500
                     UNDERLINING = TRUE;                                        00316600
                  END;                                                          00316700
               END;                                                             00316800
               /*CR12713 - PRINT A BLANK LINE BEFORE E-LINES.             */
               IF (C^=PAGE) & (^PREV_ELINE)  THEN C = DOUBLE;    /*CR12713*/
               /*CR12713 - SINCE REVISION LEVEL IS PRINTED ON M-LINE      */
               /*FOR SDL, LEAVE BLANK SPACE ON E-LINE.                    */
               IF SDL_OPTION THEN                                /*CR12713*/
                  OUTPUT(1) = C || PAD1 || INCLUDE_CHAR || 'E' || VBAR ||       00316900
                     BUILD || VBAR || X1 ||VBAR;                 /*CR12713*/    00317000
               ELSE                                              /*CR12713*/
                  OUTPUT(1) = C || PAD1 || INCLUDE_CHAR || 'E' || VBAR ||       00316900
                     BUILD || VBAR;                                             00317000
               PREV_ELINE = TRUE;                                /*CR12713*/
               IF UNDERLINING THEN                                              00317100
                  DO;                                                           00317200
                  UNDERLINING = FALSE;                                          00317300
                  OUTPUT(1) = PLUS || PAD2 || UNDER_LINE;                       00317400
                  CALL BLANK(UNDER_LINE, 0, LINESIZE);                          00317500
               END;                                                             00317600
               MAX_E_LEVEL = MAX_E_LEVEL - 1;                                   00317700
               C = X1;                                                          00317800
            END;                                                                00317900
            CALL BLANK(BUILD_E, 0, LINESIZE);                                   00318000
         END;                                                                   00318100
         IF M_COMMENT_NEEDED THEN                                               00318200
            DO;                                                                 00318300
            CALL COMMENT_BRACKET(BUILD_M, LOC);                                 00318400
            M_COMMENT_NEEDED = FALSE;                                           00318500
         END;                                                                   00318600
         IF ^LINE_CONTINUED THEN                                                00318608
            IF NEST_LEVEL > 0 THEN                                              00318616
            IF BYTE(BUILD_M,1) = BYTE(X1) THEN DO;                  /*CR13335*/ 00318620
            CHAR = NEST_LEVEL;                                                  00318624
            IF NEST_LEVEL < 10 THEN                                             00318632
               BYTE(BUILD_M) = BYTE(CHAR);                                      00318640
            ELSE DO;                                                            00318648
               BYTE(BUILD_M) = BYTE(CHAR);                                      00318656
               BYTE(BUILD_M,1) = BYTE(CHAR,1);                                  00318664
            END;                                                                00318672
         END;                                                                   00318680
         /*CR12713 - ON THE END STATEMENT, REPLACE THE CURRENT SCOPE WITH  */
         /*THE STATEMENT NUMBER OF THE DO STATEMENT.  ON THE CASES OF THE  */
         /*CASE STATEMENT, MOVE THE INFORMATION FIELD IDENTIFYING THE      */
         /*CASE NUMBER TO REPLACE THE CURRENT SCOPE INSTEAD OF PRINTING    */
         /*IT AFTER THE CURRENT SCOPE.  FOR IF-THEN-DO STATEMENTS, REPLACE */
         /*THE CURRENT SCOPE WITH THE STATEMENT NUMBER OF THE DO.          */
         IF END_FLAG & (LABEL_COUNT = 0) THEN                     /*CR12713*/
            CHAR = 'ST#'||DO_STMT#(DO_LEVEL+1);                   /*CR12713*/
         ELSE IF (LENGTH(INFORMATION) > 0)&(LABEL_COUNT=0) THEN   /*CR12713*/
         DO;                                                      /*CR12713*/
            CHAR = INFORMATION;                                   /*CR12713*/
            INFORMATION = '';                                     /*CR12713*/
         END;                                                     /*CR12713*/
         ELSE IF IF_FLAG & (LABEL_COUNT = 0) THEN                 /*CR12713*/
            CHAR = 'DO=ST#'||STMT_NUM+1;                          /*CR12713*/
         ELSE CHAR = SAVE_SCOPE;                                  /*CR12713*/
         /*CR12713 - PRINT REVISION LEVEL ON M-LINE FOR SDL                */
         IF SDL_OPTION THEN                                       /*CR12713*/
            C=C||S||INCLUDE_CHAR||'M'||VBAR||BUILD_M||            /*CR12713*/
            FORMAT_CHAR||SUBSTR(T,0,2)||FORMAT_CHAR;              /*CR12713*/
         ELSE                                                     /*CR12713*/
            C=C||S||INCLUDE_CHAR||'M'||VBAR||BUILD_M||FORMAT_CHAR;/*CR12713*/   00318800
         OUTPUT(1) = C || CHAR;                                   /*CR12713*/   00319900
         PREV_ELINE = FALSE;                                      /*CR12713*/   00319900
         IF M_UNDERSCORE_NEEDED THEN                                            00320000
            DO;                                                                 00320100
            M_UNDERSCORE_NEEDED = FALSE;                                        00320200
            OUTPUT(1) = PLUS || PAD2 || M_UNDERSCORE;                           00320300
            CALL BLANK(M_UNDERSCORE, 0, LINESIZE);                              00320400
         END;                                                                   00320500
         CALL BLANK(BUILD_M, 0, LINESIZE);                                      00320600
         IF MAX_S_LEVEL ^= 0 THEN DO;                                           00320800
            DO J = 1 TO MAX_S_LEVEL;                                            00320900
               CALL BLANK(BUILD, 0, LINESIZE);                                  00321000
               DO I = 0 TO LINESIZE - 1;                                        00321100
                  IF BUILD_S_IND(I) = J THEN                                    00321200
                     DO;                                                        00321300
                     BUILD_S_IND(I) = 0;                                        00321400
                     K = BYTE(BUILD_S, I);                                      00321500
                     BYTE(BUILD, I) = K;                                        00321600
                  END;                                                          00321700
                  IF BUILD_S_UND(I) = J THEN                                    00321800
                     DO;                                                        00321900
                     BUILD_S_UND(I) = 0;                                        00322000
                     BYTE(UNDER_LINE, I) = BYTE('_');                           00322100
                     UNDERLINING = TRUE;                                        00322200
                  END;                                                          00322300
               END;                                                             00322400
               IF S_COMMENT_NEEDED THEN                                         00322500
                  IF J <= NUM_S_NEEDED THEN                                     00322600
                  CALL COMMENT_BRACKET(BUILD, LOC);                             00322700
               /*CR12713 - PRINT A BLANK LINE AFTER  S-LINES.                */
               NEXT_CC = DOUBLE;                                    /*CR12713*/
               /*CR12713 - SINCE REVISION LEVEL IS PRINTED ON M-LINE         */
               /*FOR SDL, LEAVE BLANK SPACE ON S-LINE.                       */
               IF SDL_OPTION THEN                                   /*CR12713*/
                  OUTPUT(1) = X1 || PAD1 || INCLUDE_CHAR || 'S' || VBAR ||      00322800
                     BUILD|| VBAR || X1 || VBAR;                    /*CR12713*/ 00322900
               ELSE                                                 /*CR12713*/
                  OUTPUT(1) = X1 || PAD1 || INCLUDE_CHAR || 'S' || VBAR ||      00322800
                     BUILD|| VBAR;                                  /*CR12713*/ 00322900
               PREV_ELINE = FALSE;                                  /*CR12713*/
               IF UNDERLINING THEN                                              00323100
                  DO;                                                           00323200
                  UNDERLINING = FALSE;                                          00323300
                  OUTPUT(1) = PLUS || PAD2 || UNDER_LINE;                       00323400
                  CALL BLANK(UNDER_LINE, 0, LINESIZE);                          00323500
               END;                                                             00323600
            END;                                                                00323700
            CALL BLANK(BUILD_S, 0, LINESIZE);                                   00323800
         END;                                                                   00323900
         S_COMMENT_NEEDED = FALSE;                                              00324400
         MAX_S_LEVEL, MAX_E_LEVEL = 0;                                          00324500
         IF POST_COMMENT_NEEDED THEN                                            00324600
            DO;                                                                 00324700
            DO WHILE NUM > 0;                                                   00324800
               CALL BLANK(BUILD, 0, LINESIZE);                                  00324900
               CALL COMMENT_BRACKET(BUILD, LOC);                                00325000
               OUTPUT(1) = X1 || PAD2 || BUILD;                                 00325100
            END;                                                                00325200
            POST_COMMENT_NEEDED = FALSE;                                        00325300
         END;                                                                   00325400
                                                                                00325600
         /* DR109042 -- BACKED OUT INCORRECT DR108629 FIX */
         CALL ERROR_PRINT;                                                         00325
         LINE_CONTINUED = FALSE;                                                00325420
      END EXPAND;                                                               00325500
                                                                                00325600
                                                                                00325700
MATCH:                                                                          00325800
      PROCEDURE(START);                                                         00325900
 /* THIS PROCEDURE SEARCHES THE STMT_STACK STARTING AT START FOR                00326000
      MATCHING OPEN/CLOSE PAREN PAIRS.  IT REPLACES MATCHING OUTER              00326100
      PAIRS WITH ZEROS UNLESS THE "FIND_ONLY" FLAG IS ON. IT RETURNS A VALUE    00326200
      WHICH IS THE INDEX OF THE OUTERMOST ")". */                               00326300
         DECLARE (NUM_LEFT, NUM_RIGHT, START) BIT(16);                          00326400
         I = START;                                                             00326500
         NUM_LEFT = 1;                                                          00326600
         NUM_RIGHT = 0;                                                         00326700
         DO WHILE (NUM_LEFT > NUM_RIGHT) & (I <= PTR_END);                      00326800
            I = I + 1;                                                          00326900
            IF STMT_STACK(I) = LEFT_PAREN THEN                                  00327000
               NUM_LEFT = NUM_LEFT + 1;                                         00327100
            ELSE                                                                00327200
               IF STMT_STACK(I) = RT_PAREN THEN                                 00327300
               NUM_RIGHT = NUM_RIGHT + 1;                                       00327400
         END;                                                                   00327500
         IF NUM_LEFT = NUM_RIGHT THEN                                           00327600
            IF (STMT_STACK(START) = LEFT_PAREN) &                               00327700
            (STMT_STACK(I) = RT_PAREN) THEN                                     00327800
            IF ^FIND_ONLY THEN                                                  00327900
            STMT_STACK(START), STMT_STACK(I) = 0;                               00328000
         IF NUM_LEFT ^= NUM_RIGHT THEN CALL ERROR(CLASS_BS,6); /*DR109081*/
         RETURN I;                                                              00328100
      END MATCH;                                                                00328200
                                                                                00328300
                                                                                00328400
SKIP_REPL:                                                                      00328500
      PROCEDURE(POINT);                                                         00328600
         DECLARE POINT BIT(16);                                                 00328700
         DO WHILE ((TOKEN_FLAGS(POINT) & "1F") = 7) & (POINT <= PTR_END);       00328800
            POINT = POINT + 1;                                                  00328900
         END;                                                                   00329000
         RETURN POINT;                                                          00329100
      END SKIP_REPL;                                                            00329200
                                                                                00329300
                                                                                00329400
CHECK_FOR_FUNC:                                                                 00329500
      PROCEDURE(START);                                                         00329600
         DECLARE (START, FINISH, DEPTH) BIT(16);                                00329700
         FINISH = START;                                                        00329800
         IF (GRAMMAR_FLAGS(START) & FUNC_FLAG) ^= 0 THEN                        00329900
            DO;  /* A FUNCTION - CHECK FOR SUBSCRIPTING AND ARGUMENTS */        00330000
            DEPTH = 1;                                                          00330100
            DO WHILE (STMT_STACK(FINISH + 1) = DOLLAR) &                        00330200
                  ((FINISH + 1) < PTR_END);                                     00330300
               FINISH = FINISH + 2;                                             00330400
               IF STMT_STACK(FINISH) = LEFT_PAREN THEN                          00330500
                  DO;                                                           00330600
                  FIND_ONLY = TRUE;                                             00330700
                  FINISH = MATCH(FINISH);                                       00330800
                  FIND_ONLY = FALSE;                                            00330900
               END;                                                             00331000
               ELSE IF (GRAMMAR_FLAGS(FINISH) & FUNC_FLAG) ^= 0 THEN            00331100
                  DEPTH = DEPTH + 1;                                            00331200
            END;  /* OF DO WHILE... */                                          00331300
            DO DEPTH = 0 TO DEPTH;                                              00331400
               IF (FINISH + 1) < PTR_END THEN                                   00331500
                  IF STMT_STACK(FINISH + 1) = LEFT_PAREN THEN                   00331600
                  DO;  /* ARGUMENT LIST */                                      00331700
                  FIND_ONLY = TRUE;                                             00331800
                  FINISH = MATCH(FINISH + 1);                                   00331900
                  FIND_ONLY = FALSE;                                            00332000
               END;                                                             00332100
            END;                                                                00332200
            IF STMT_STACK(FINISH + 1) = LEFT_PAREN THEN /*DR109081*/
               CALL ERROR(CLASS_BS,6);                  /*DR109081*/
         END;
         ELSE DO;                                                               00332400
            GO TO START_SEARCH;                                                 00332500
            DO WHILE (STMT_STACK(START) = STRUC_TOKEN) &                        00332600
                  (STMT_STACK(DEPTH) = DOT_TOKEN);                              00332700
               FINISH = MIN(DEPTH + 1, PTR_END);                                00332800
START_SEARCH:                                                                   00332900
               START = SKIP_REPL(FINISH);                                       00333000
               DEPTH = SKIP_REPL(START + 1);                                    00333100
            END;                                                                00333200
         END;                                                                   00333300
         RETURN FINISH;                                                         00333400
      END CHECK_FOR_FUNC;                                                       00333500
                                                                                00333600
                                                                                00333700
OUTPUT_WRITER_BEGINNING:                                                        00333800
      PRINT_LABEL = FALSE;                        /*DR108628, CR12157*/
      I=2;                                                                      00333900
      SDL_INFO = SRN(I);                                                        00334000
      INCLUDE_COUNT = SRN_COUNT(I);                                             00334100
      IF ^LINE_CONTINUED THEN                                   /*DR109081*/
         M_PTR=MAX(MIN(INDENT_LEVEL,INDENT_LIMIT),0);           /*DR109081*/
      IF INLINE_INDENT_RESET>=0 THEN DO;                                        00334300
         INDENT_LEVEL=INLINE_INDENT_RESET;                                      00334400
         INLINE_INDENT_RESET=-1;                                                00334500
      END;                                                                      00334600
      IF PTR_END = -1 THEN                                                      00334700
         PTR_END = STMT_PTR;                                                    00334800
      IF (PTR_END=OUTPUT_STACK_MAX) & SQUEEZING THEN            /*DR109081*/
         PTR_END = PTR_END - 2;                                 /*DR109081*/
      DO WHILE ((GRAMMAR_FLAGS(PTR_START) & PRINT_FLAG) = 0) &                  00334900
            (PTR_START <= PTR_END);                                             00335000
         PTR_START = PTR_START + 1;                                             00335100
      END;                                                                      00335200
      IF PTR_START > PTR_END THEN                                               00335300
         GO TO AFTER_EXPAND;                                    /*DR111326*/    00335400
      /*FIND MOST RECENT RVL. THE RVL FOR EACH TOKEN WAS SAVED IN SAVE_TOKEN*/
      IF SDL_OPTION & (^INCLUDING) & (^INCLUDE_END) THEN DO;    /*CR12940*/
         C_RVL = STRING(ADDR(RVL_STACK1(PTR_START)))||          /*CR12940*/
                 STRING(ADDR(RVL_STACK2(PTR_START)));           /*CR12940*/
         DO IDX = PTR_START+1 TO PTR_END;                       /*CR12940*/
            IF ((GRAMMAR_FLAGS(IDX) & PRINT_FLAG) ^= 0) THEN DO;/*CR12940*/
               C_TMP = STRING(ADDR(RVL_STACK1(IDX)))||          /*CR12940*/
                       STRING(ADDR(RVL_STACK2(IDX)));           /*CR12940*/
               IF STRING_GT(C_TMP,C_RVL) THEN C_RVL = C_TMP;    /*CR12940*/
            END;                                                /*CR12940*/
         END;                                                   /*CR12940*/
         IF STRING_GT(C_RVL, SUBSTR(SRN(2),6,2)) THEN           /*CR12214*/
           SRN(2) = SUBSTR(SRN(2),0,6)|| C_RVL;                 /*CR12214*/
      END;                                                      /*CR12940*/
      LABEL_START = PTR_START;                                                  00335500
      IF LABEL_COUNT > 0 THEN                                                   00335600
         DO WHILE ((GRAMMAR_FLAGS(PTR_START) & LABEL_FLAG) ^= 0) /*DR109099*/   00335700
         & (PTR_START < PTR_END);                                /*DR109099*/
         PTR_START = PTR_START + 2;                                             00335800
      END;                                                                      00335900
      LABEL_END = PTR_START - 1;                                                00336000
      DO WHILE ((GRAMMAR_FLAGS(PTR_START) & PRINT_FLAG) = 0) &                  00336100
            (PTR_START <= PTR_END);                                             00336200
         PTR_START = PTR_START + 1;                                             00336300
      END;                                                                      00336400
      IF (PTR_START > PTR_END) & (LABEL_COUNT > 0) THEN DO;/*DR108628,CR12157*/
         PRINT_LABEL = TRUE;                               /*DR108628,CR12157*/
         GO TO STLABEL;                                    /*DR108628,CR12157*/
      END;                                                 /*DR108628,CR12157*/
      DO PTR = PTR_START TO PTR_END;                                            00336500
         SUB_START, EXP_START = 0;                                              00336600
         IF (GRAMMAR_FLAGS(PTR)&INLINE_FLAG)^=0 THEN INLINE_INDENT=M_PTR+1;     00336700
         IF STMT_STACK(PTR) = DOLLAR THEN                                       00336800
            DO;                                                                 00336900
            PTR = PTR + 1;                                                      00337000
            SUB_START = PTR;                                                    00337100
            S_LEVEL = 0;                                                        00337200
            IF MAX_S_LEVEL = 0 THEN                                             00337300
               MAX_S_LEVEL = 1;                                                 00337400
            IF STMT_STACK(SUB_START) = LEFT_PAREN THEN                          00337500
               DO;                                                              00337600
               SUB_END = MATCH(SUB_START);                                      00337700
               IF SUB_END < PTR_END THEN                                        00337800
                  IF STMT_STACK(SUB_END + 1) = DOLLAR THEN                      00337900
                  IF (SUB_END - SUB_START) > 2 THEN                             00338000
                  DO;                                                           00338100
                  STMT_STACK(SUB_START) = TX(BYTE('('));                        00338200
                  STMT_STACK(SUB_END) = TX(BYTE(')'));                          00338300
               END;                                                             00338400
            END;                                                                00338500
            ELSE                                                                00338600
               SUB_END = CHECK_FOR_FUNC(SUB_START);                             00338700
            DO WHILE (STMT_STACK(SUB_END + 1) = DOLLAR) &                       00338800
                  ((SUB_END + 1) < PTR_END);                                    00338900
               SUB_END = SUB_END + 2;                                           00339000
               IF STMT_STACK(SUB_END) = LEFT_PAREN THEN                         00339100
                  DO;                                                           00339200
                  FIND_ONLY = TRUE;                                             00339300
                  SUB_END = MATCH(SUB_END);                                     00339400
                  FIND_ONLY = FALSE;                                            00339500
               END;                                                             00339600
               ELSE SUB_END = CHECK_FOR_FUNC(SUB_END);                          00339700
            END;                                                                00339800
            PTR = SUB_END + 1;                                                  00339900
         END;                                                                   00340000
         IF (STMT_STACK(PTR) = EXPONENTIATE) & (PTR < PTR_END) THEN             00340100
            DO;                                                                 00340200
            PTR = PTR + 1;                                                      00340300
            EXP_START = PTR;                                                    00340400
            E_LEVEL = 0;                                                        00340500
            IF MAX_E_LEVEL = 0 THEN                                             00340600
               MAX_E_LEVEL = 1;                                                 00340700
            IF STMT_STACK(EXP_START) = LEFT_PAREN THEN                          00340800
               DO;                                                              00340900
               EXP_END = MATCH(EXP_START);                                      00341000
               IF EXP_END < PTR_END THEN                                        00341100
                  IF STMT_STACK(EXP_END + 1) = EXPONENTIATE THEN                00341200
                  IF (EXP_END - EXP_START) > 2 THEN                             00341300
                  DO;                                                           00341400
                  STMT_STACK(EXP_START) = TX(BYTE('('));                        00341500
                  STMT_STACK(EXP_END) = TX(BYTE(')'));                          00341600
               END;                                                             00341700
            END;                                                                00341800
            ELSE                                                                00341900
               EXP_END = CHECK_FOR_FUNC(EXP_START);                             00342000
            GO TO DOLLAR_CHECK1;                                                00342100
            DO WHILE (STMT_STACK(EXP_END + 1) = EXPONENTIATE) &                 00342200
                  ((EXP_END + 1) < PTR_END);                                    00342300
               EXP_END = EXP_END + 2;                                           00342400
               IF STMT_STACK(EXP_END) = LEFT_PAREN THEN                         00342500
                  DO;                                                           00342600
                  FIND_ONLY = TRUE;                                             00342700
                  EXP_END = MATCH(EXP_END);                                     00342800
                  FIND_ONLY = FALSE;                                            00342900
               END;                                                             00343000
               ELSE IF (GRAMMAR_FLAGS(EXP_END) & FUNC_FLAG) ^= 0 THEN           00343100
                  EXP_END = CHECK_FOR_FUNC(EXP_END);                            00343200
ELSE DOLLAR_CHECK1:                                                             00343300
               DO WHILE (STMT_STACK(EXP_END + 1) = DOLLAR) &                    00343400
                     (EXP_END + 1 < PTR_END);                                   00343500
                  EXP_END = EXP_END + 2;                                        00343600
                  IF STMT_STACK(EXP_END) = LEFT_PAREN THEN                      00343700
                     DO;                                                        00343800
                     FIND_ONLY = TRUE;                                          00343900
                     EXP_END = MATCH(EXP_END);                                  00344000
                     FIND_ONLY = FALSE;                                         00344100
                  END;                                                          00344200
                  ELSE EXP_END = CHECK_FOR_FUNC(EXP_END);                       00344300
               END;                                                             00344400
            END;                                                                00344500
            PTR = EXP_END + 1;                                                  00344600
         END;                                                                   00344700
         IF SUB_START + EXP_START ^= 0 THEN                                     00344800
            DO;                                                                 00344900
S_BEGIN:                                                                        00345000
            E_PTR, S_PTR = M_PTR;                                               00345100
            IF SUB_START ^= 0 THEN DO;                                          00345200
S_LOOP:                                                                         00345300
               LAST_SPACE = 2;                                                  00345400
               DO WHILE SUB_START(S_LEVEL) <= SUB_END(S_LEVEL);                 00345500
                  IF STMT_STACK(SUB_START(S_LEVEL)) = 0 THEN                    00345600
                     DO;                                                        00345700
                     SUB_START(S_LEVEL) = SUB_START(S_LEVEL) + 1;               00345800
                     GO TO S_LOOP;                                              00345900
                  END;                                                          00346000
                  IF STMT_STACK(SUB_START(S_LEVEL)) = DOLLAR THEN               00346100
                     DO;                                                        00346200
                     IF S_LEVEL = MAX_LEVEL THEN DO;               /*DR109081*/
                        CALL ERROR(CLASS_BS, 7);                   /*DR109081*/
                        SUB_START(S_LEVEL) = SUB_START(S_LEVEL) + 1; /*109081*/
                        GO TO S_LOOP;                              /*DR109081*/
                     END;                                          /*DR109081*/
                     S_LEVEL = S_LEVEL + 1;                                     00346300
                     IF MAX_S_LEVEL <= S_LEVEL THEN                             00346400
                        MAX_S_LEVEL = S_LEVEL + 1;                              00346500
                     SUB_START(S_LEVEL) = SUB_START(S_LEVEL - 1) + 1;           00346600
                     IF STMT_STACK(SUB_START(S_LEVEL)) = LEFT_PAREN THEN        00346700
                        DO;                                                     00346800
                        SUB_END(S_LEVEL) = MATCH(SUB_START(S_LEVEL));           00346900
                        IF SUB_END(S_LEVEL) < PTR_END THEN                      00347000
                           IF STMT_STACK(SUB_START(S_LEVEL) + 1) = DOLLAR       00347100
                           THEN                                                 00347200
                           IF (SUB_END(S_LEVEL) - SUB_START(S_LEVEL)) >         00347300
                           2 THEN                                               00347400
                           DO;                                                  00347500
                           STMT_STACK(SUB_START(S_LEVEL)) =                     00347600
                              TX(BYTE('('));                                    00347700
                           STMT_STACK(SUB_END(S_LEVEL)) =                       00347800
                              TX(BYTE(')'));                                    00347900
                        END;                                                    00348000
                     END;                                                       00348100
                     ELSE                                                       00348200
                        SUB_END(S_LEVEL) = CHECK_FOR_FUNC                       00348300
                        (SUB_START(S_LEVEL));                                   00348400
                     DO WHILE (STMT_STACK(SUB_END(S_LEVEL) + 1) = DOLLAR)       00348500
                           & ((SUB_END(S_LEVEL) + 1) < PTR_END);                00348600
                        SUB_END(S_LEVEL) = SUB_END(S_LEVEL) + 2;                00348700
                        IF STMT_STACK(SUB_END(S_LEVEL)) = LEFT_PAREN THEN       00348800
                           DO;                                                  00348900
                           FIND_ONLY = TRUE;                                    00349000
                           SUB_END(S_LEVEL) = MATCH(SUB_END(S_LEVEL));          00349100
                           FIND_ONLY = FALSE;                                   00349200
                        END;                                                    00349300
                        ELSE SUB_START(S_LEVEL) = CHECK_FOR_FUNC                00349400
                           (SUB_END(S_LEVEL));                                  00349500
                     END;                                                       00349600
                     IF SUB_END(S_LEVEL) >= PTR THEN                            00349700
                        PTR = SUB_END(S_LEVEL) + 1;                             00349800
                     GO TO S_LOOP;                                              00349900
                  END;                                                          00350000
                  IF STMT_STACK(SUB_START(S_LEVEL)) = CHARACTER_STRING THEN     00350100
                     DO;                                                        00350200
                     IF S_CHAR_PTR < S_CHAR_PTR_MAX THEN                        00350300
                        GO TO MORE_S_C;                                         00350400
                     C = ATTACH(SUB_START(S_LEVEL), NT);                        00350500
                     IF LENGTH(C) = 0 THEN GO TO INCR_SUB_START;                00350600
                     S_CHAR_PTR, S_CHAR_PTR_MAX = 0;                            00350700
                     DO I = 0 TO 2;                                             00350800
                        SAVE_S_C(I) = C(I);                                     00350900
                        S_CHAR_PTR_MAX = S_CHAR_PTR_MAX + LENGTH(C(I));         00351000
                     END;                                                       00351100
                     S_PTR = S_PTR + SPACE_NEEDED;                              00351200
MORE_S_C:                                                                       00351300
                     DO WHILE (S_CHAR_PTR < S_CHAR_PTR_MAX) &                   00351400
                           (S_PTR < LINESIZE);                                  00351500
                        J = BYTE(SAVE_S_C(SHR(S_CHAR_PTR, 8)),(S_CHAR_PTR       00351600
                           & "FF"));                                            00351700
                        BYTE(BUILD_S, S_PTR) = J;                               00351800
                        BUILD_S_IND(S_PTR) = S_LEVEL + 1;                       00351900
                        IF (GRAMMAR_FLAGS(SUB_START(S_LEVEL))                   00351910
                           & MACRO_ARG_FLAG) ^= 0 THEN                          00351920
                           BUILD_S_UND(S_PTR) = S_LEVEL + 1;                    00351930
                        S_PTR = S_PTR + 1;                                      00352000
                        S_CHAR_PTR = S_CHAR_PTR + 1;                            00352100
                     END;                                                       00352200
                     IF S_CHAR_PTR < S_CHAR_PTR_MAX THEN                        00352300
                        GO TO S_FULL;                                           00352400
                     GO TO INCR_SUB_START;                                      00352500
                  END;                                                          00352600
                  ELSE                                                          00352700
                     DO;  /* NOT A CHARACTER STRING */                          00352800
                     C = ATTACH(SUB_START(S_LEVEL), NT);                        00352900
                     IF LENGTH(C) = 0 THEN GO TO INCR_SUB_START;                00353000
                     S_PTR = S_PTR + SPACE_NEEDED;                              00353100
                     IF LENGTH(C) + S_PTR >= LINESIZE THEN                      00353200
                        DO;                                                     00353300
S_FULL:                                                                         00353400
 /* RESTORE PRINT FLAG TO OVERFLOWING TOKEN */                                  00353500
                        GRAMMAR_FLAGS(SUB_START(S_LEVEL)) =                     00353600
                           GRAMMAR_FLAGS(SUB_START(S_LEVEL)) |                  00353700
                           PRINT_FLAG;                                          00353800
                        LINE_FULL = TRUE;                                       00353900
                        SAVE_MAX_S_LEVEL = S_LEVEL + 1;                         00354000
                        GO TO E_BEGIN;                                          00354100
                     END;                                                       00354200
                     DO I = 0 TO LENGTH(C) - 1;                                 00354300
                        J = BYTE(C, I);                                         00354400
                        BYTE(BUILD_S, S_PTR + I) = J;                           00354500
                        BUILD_S_IND(S_PTR + I) = S_LEVEL + 1;                   00354600
                     END;                                                       00354700
                     IF (TOKEN_FLAGS(SUB_START(S_LEVEL)) & 7) = 7 THEN          00354800
                        MACRO_WRITTEN = TRUE;                                   00354900
                     IF (GRAMMAR_FLAGS(SUB_START(S_LEVEL))                      00354910
                        & MACRO_ARG_FLAG) ^= 0 THEN DO;                         00354920
                        DO I = 0 TO LENGTH(C) - 1;                              00355000
                           BUILD_S_UND(S_PTR + I) = S_LEVEL + 1;                00355100
                        END;                                                    00355200
                     END;                                                       00355300
                     S_PTR = S_PTR + LENGTH(C);                                 00355400
INCR_SUB_START:                                                                 00355500
                     SUB_START(S_LEVEL) = SUB_START(S_LEVEL) + 1;               00355600
                  END;  /* OF NOT A CHARACTER STRING */                         00355700
               END;  /* OF DO WHILE SUB_START <= SUB_END  */                    00355800
            END;  /* OF SUB_START ^= 0 */                                       00355900
            IF S_LEVEL ^= 0 THEN                                                00356000
               DO;                                                              00356100
               S_LEVEL = S_LEVEL - 1;                                           00356200
               SUB_START(S_LEVEL) = SUB_START(S_LEVEL + 1);                     00356300
               MACRO_WRITTEN = FALSE;                                           00356400
               GO TO S_LOOP;                                                    00356500
            END;                                                                00356600
E_BEGIN:                                                                        00356700
            IF EXP_START ^= 0 THEN DO;                                          00356800
E_LOOP:                                                                         00356900
               LAST_SPACE = 2;                                                  00357000
               DO WHILE EXP_START(E_LEVEL) <= EXP_END(E_LEVEL);                 00357100
                  IF STMT_STACK(EXP_START(E_LEVEL)) = 0 THEN                    00357200
                     DO;                                                        00357300
                     EXP_START(E_LEVEL) = EXP_START(E_LEVEL) + 1;               00357400
                     GO TO E_LOOP;                                              00357500
                  END;                                                          00357600
                  IF STMT_STACK(EXP_START(E_LEVEL)) = EXPONENTIATE THEN         00357700
                     DO;                                                        00357800
                     IF E_LEVEL = MAX_LEVEL THEN DO;               /*DR109081*/
                        CALL ERROR(CLASS_BS, 7);                   /*DR109081*/
                        EXP_START(E_LEVEL) = EXP_START(E_LEVEL) + 1; /*109081*/
                        GO TO E_LOOP;                              /*DR109081*/
                     END;                                          /*DR109081*/
                     E_LEVEL = E_LEVEL + 1;                                     00357900
                     IF MAX_E_LEVEL <= E_LEVEL THEN                             00358000
                        MAX_E_LEVEL = E_LEVEL + 1;                              00358100
                     EXP_START(E_LEVEL) = EXP_START(E_LEVEL - 1) + 1;           00358200
                     IF STMT_STACK(EXP_START(E_LEVEL)) = LEFT_PAREN THEN        00358300
                        DO;                                                     00358400
                        EXP_END(E_LEVEL) = MATCH(EXP_START(E_LEVEL));           00358500
                        IF EXP_END(E_LEVEL) < PTR_END THEN                      00358600
                           IF STMT_STACK(EXP_END(E_LEVEL) + 1) =                00358700
                           EXPONENTIATE THEN                                    00358800
                           IF (EXP_END(E_LEVEL) - EXP_START(E_LEVEL)) >         00358900
                           2 THEN                                               00359000
                           DO;                                                  00359100
                           STMT_STACK(EXP_START(E_LEVEL)) =                     00359200
                              TX(BYTE('('));                                    00359300
                           STMT_STACK(EXP_END(E_LEVEL)) =                       00359400
                              TX(BYTE(')'));                                    00359500
                        END;                                                    00359600
                     END;                                                       00359700
                     ELSE                                                       00359800
                        EXP_END(E_LEVEL) = CHECK_FOR_FUNC                       00359900
                        (EXP_START(E_LEVEL));                                   00360000
                     GO TO DOLLAR_CHECK2;                                       00360100
                     DO WHILE (STMT_STACK(EXP_END(E_LEVEL) + 1) =               00360200
                           EXPONENTIATE) & ((EXP_END(E_LEVEL) + 1) < PTR_END);  00360300
                        EXP_END(E_LEVEL) = EXP_END(E_LEVEL) + 2;                00360400
                        IF STMT_STACK(EXP_END(E_LEVEL)) = LEFT_PAREN THEN       00360500
                           DO;                                                  00360600
                           FIND_ONLY = TRUE;                                    00360700
                           EXP_END(E_LEVEL) = MATCH(EXP_END(E_LEVEL));          00360800
                           FIND_ONLY = FALSE;                                   00360900
                        END;                                                    00361000
                        ELSE IF (GRAMMAR_FLAGS(EXP_END(E_LEVEL)) &              00361100
                           FUNC_FLAG) ^= 0 THEN                                 00361200
                           EXP_END(E_LEVEL) = CHECK_FOR_FUNC                    00361300
                           (EXP_END(E_LEVEL));                                  00361400
ELSE DOLLAR_CHECK2:                                                             00361500
                        DO WHILE (STMT_STACK(EXP_END(E_LEVEL) + 1) =            00361600
                              DOLLAR) & (EXP_END(E_LEVEL) + 1 < PTR_END);       00361700
                           EXP_END(E_LEVEL) = EXP_END(E_LEVEL) + 2;             00361800
                           IF STMT_STACK(EXP_END(E_LEVEL)) =                    00361900
                              LEFT_PAREN THEN                                   00362000
                              DO;                                               00362100
                              FIND_ONLY = TRUE;                                 00362200
                              EXP_END(E_LEVEL) = MATCH                          00362300
                                 (EXP_END(E_LEVEL));                            00362400
                              FIND_ONLY = FALSE;                                00362500
                           END;                                                 00362600
                           ELSE EXP_END(E_LEVEL) = CHECK_FOR_FUNC               00362700
                              (EXP_END(E_LEVEL));                               00362800
                        END;                                                    00362900
                     END;                                                       00363000
                     IF EXP_END(E_LEVEL) >= PTR THEN                            00363100
                        PTR = EXP_END(E_LEVEL) + 1;                             00363200
                     GO TO E_LOOP;                                              00363300
                  END;                                                          00363400
                  IF STMT_STACK(EXP_START(E_LEVEL)) = CHARACTER_STRING THEN     00363500
                     DO;                                                        00363600
                     IF E_CHAR_PTR < E_CHAR_PTR_MAX THEN                        00363700
                        GO TO MORE_E_C;                                         00363800
                     C = ATTACH(EXP_START(E_LEVEL), NT);                        00363900
                     IF LENGTH(C) = 0 THEN GO TO INCR_EXP_START;                00364000
                     E_CHAR_PTR, E_CHAR_PTR_MAX = 0;                            00364100
                     DO I = 0 TO 2;                                             00364200
                        SAVE_E_C(I) = C(I);                                     00364300
                        E_CHAR_PTR_MAX = E_CHAR_PTR_MAX + LENGTH(C(I));         00364400
                     END;                                                       00364500
                     E_PTR = E_PTR + SPACE_NEEDED;                              00364600
MORE_E_C:                                                                       00364700
                     DO WHILE (E_CHAR_PTR < E_CHAR_PTR_MAX) &                   00364800
                           (E_PTR < LINESIZE);                                  00364900
                        J = BYTE(SAVE_E_C(SHR(E_CHAR_PTR, 8)),(E_CHAR_PTR       00365000
                           & "FF"));                                            00365100
                        BYTE(BUILD_E, E_PTR) = J;                               00365200
                        BUILD_E_IND(E_PTR) = E_LEVEL + 1;                       00365300
                        IF (GRAMMAR_FLAGS(EXP_START(E_LEVEL))                   00365310
                           & MACRO_ARG_FLAG) ^= 0 THEN                          00365320
                           BUILD_E_UND(E_PTR) = E_LEVEL + 1;                    00365330
                        E_PTR = E_PTR + 1;                                      00365400
                        E_CHAR_PTR = E_CHAR_PTR + 1;                            00365500
                     END;                                                       00365600
                     IF E_CHAR_PTR < E_CHAR_PTR_MAX THEN                        00365700
                        GO TO E_FULL;                                           00365800
                     GO TO INCR_EXP_START;                                      00365900
                  END;                                                          00366000
                  ELSE                                                          00366100
                     DO;  /* NOT A CHARACTER STRING */                          00366200
                     C = ATTACH(EXP_START(E_LEVEL), NT);                        00366300
                     IF LENGTH(C) = 0 THEN GO TO INCR_EXP_START;                00366400
                     E_PTR = E_PTR + SPACE_NEEDED;                              00366500
                     IF LENGTH(C) + E_PTR >= LINESIZE THEN                      00366600
                        DO;                                                     00366700
E_FULL:                                                                         00366800
                        GRAMMAR_FLAGS(EXP_START(E_LEVEL)) =                     00366900
                           GRAMMAR_FLAGS(EXP_START(E_LEVEL)) |                  00367000
                           PRINT_FLAG;                                          00367100
                        LINE_FULL = TRUE;                                       00367200
                        SAVE_MAX_E_LEVEL = E_LEVEL + 1;                         00367300
                        GO TO FULL_LINE;                                        00367400
                     END;                                                       00367500
                     DO I = 0 TO LENGTH(C) - 1;                                 00367600
                        J = BYTE(C, I);                                         00367700
                        BYTE(BUILD_E, E_PTR + I) = J;                           00367800
                        BUILD_E_IND(E_PTR + I) = E_LEVEL + 1;                   00367900
                     END;                                                       00368000
                     IF (TOKEN_FLAGS(EXP_START(E_LEVEL)) & 7) = 7 THEN          00368100
                        MACRO_WRITTEN = TRUE;                                   00368200
                     IF (GRAMMAR_FLAGS(EXP_START(E_LEVEL))                      00368210
                        & MACRO_ARG_FLAG) ^= 0 THEN DO;                         00368220
                        DO I = 0 TO LENGTH(C) - 1;                              00368300
                           BUILD_E_UND(E_PTR + I) = E_LEVEL + 1;                00368400
                        END;                                                    00368500
                     END;                                                       00368600
                     E_PTR = E_PTR + LENGTH(C);                                 00368700
INCR_EXP_START:                                                                 00368800
                     EXP_START(E_LEVEL) = EXP_START(E_LEVEL) + 1;               00368900
                  END;  /* OF NOT A CHARACTER STRING */                         00369000
               END;  /* OF DO WHILE EXP_START <= EXP_END */                     00369100
            END;  /* OF EXP_START ^= 0 */                                       00369200
            IF E_LEVEL ^= 0 THEN                                                00369300
               DO;                                                              00369400
               E_LEVEL = E_LEVEL - 1;                                           00369500
               EXP_START(E_LEVEL) = EXP_START(E_LEVEL + 1);                     00369600
               MACRO_WRITTEN = FALSE;                                           00369700
               GO TO E_LOOP;                                                    00369800
            END;                                                                00369900
FULL_LINE:                                                                      00370000
            IF LINE_FULL THEN                                                   00370100
               DO;                                                              00370200
               CALL EXPAND(0);                                                  00370300
               MAX_E_LEVEL = SAVE_MAX_E_LEVEL;                                  00370400
               MAX_S_LEVEL = SAVE_MAX_S_LEVEL;                                  00370500
               SAVE_MAX_E_LEVEL, SAVE_MAX_S_LEVEL = 0;                          00370600
               LINE_FULL = FALSE;                                               00370700
               IF (E_CHAR_PTR + S_CHAR_PTR) = 0 THEN                            00370800
                  M_PTR = MAX(MIN(INDENT_LEVEL, INDENT_LIMIT), 0);              00370900
               ELSE                                                             00371000
                  DO;  M_PTR = 0;  LINE_CONTINUED = TRUE;  END;                 00371100
                     GO TO S_BEGIN;                                             00371200
               END;                                                             00371300
               IF E_PTR > S_PTR THEN                                            00371400
                  M_PTR = E_PTR;                                                00371500
               ELSE                                                             00371600
                  M_PTR = S_PTR;                                                00371700
               LAST_SPACE = 1;                                                  00371800
            END;  /* OF DO IF SUB_START + EXP_START ^= 0 */                     00371900
            IF PTR > PTR_END THEN GO TO PTR_LOOP_END;                           00372000
            IF STMT_STACK(PTR) = CHARACTER_STRING THEN                          00372100
               DO;                                                              00372200
               C = ATTACH(PTR, 0);                       /*DR109081*/
               IF LENGTH(C) = 0 THEN GO TO PTR_LOOP_END; /*DR109081*/
               IF M_CHAR_PTR < M_CHAR_PTR_MAX THEN                              00372300
                  GO TO MORE_M_C;                                               00372400
               M_CHAR_PTR, M_CHAR_PTR_MAX = 0;                                  00372700
               DO I = 0 TO 2;                                                   00372800
                  M_CHAR_PTR_MAX = M_CHAR_PTR_MAX + LENGTH(C(I));               00372900
               END;                                                             00373000
               M_PTR = M_PTR + SPACE_NEEDED;                                    00373100
MORE_M_C:                                                                       00373200
               DO WHILE (M_CHAR_PTR < M_CHAR_PTR_MAX) & (M_PTR < LINESIZE);     00373300
                  J = BYTE(C(SHR(M_CHAR_PTR, 8)), (M_CHAR_PTR & "FF"));         00373400
                  IF (TRANS_OUT(J) & "FF") ^= 0 THEN DO;  /* ALT CHAR SET */    00373500
                     K = CHAR_OP(SHR(TRANS_OUT(J), 8) & "FF");  /* OP CHAR */   00373600
                     BYTE(BUILD_E, M_PTR) = K;                                  00373700
                     BUILD_E_IND(M_PTR) = 1;                                    00373800
                     IF MAX_E_LEVEL = 0 THEN MAX_E_LEVEL = 1;                   00373900
                     J = TRANS_OUT(J) & "FF";  /* BACK TO NORMAL CHAR SET */    00374000
                  END;                                                          00374100
                  BYTE(BUILD_M, M_PTR) = J;                                     00374200
                  IF (GRAMMAR_FLAGS(PTR) & MACRO_ARG_FLAG) ^= 0 THEN DO;        00374210
                     BYTE(M_UNDERSCORE, M_PTR) = BYTE('_');                     00374220
                     M_UNDERSCORE_NEEDED = TRUE;                                00374230
                  END;                                                          00374240
                  M_PTR = M_PTR + 1;                                            00374300
                  M_CHAR_PTR = M_CHAR_PTR + 1;                                  00374400
               END;                                                             00374500
               IF M_CHAR_PTR < M_CHAR_PTR_MAX THEN                              00374600
                  DO;                                                           00374700
RESET:            PROCEDURE;                                                    00374800
                     CALL EXPAND(0);                                            00375500
                     IF M_CHAR_PTR = 0 THEN                                     00375600
                        M_PTR = MAX(MIN(INDENT_LEVEL, INDENT_LIMIT), 0);        00375700
                     ELSE                                                       00375800
                        DO;  M_PTR = 0;  LINE_CONTINUED = TRUE;  END;           00375900
                        END RESET;                                              00376000
                     CALL RESET;                                                00376100
     /*DR109081*/    IF SQUEEZING THEN DO;
     /*DR109081*/       SQUEEZING = FALSE;
     /*DR109081*/       GRAMMAR_FLAGS(PTR) = GRAMMAR_FLAGS(PTR) | PRINT_FLAG;
     /*DR109081*/       GO TO OUTPUT_WRITER_END;
     /*DR109081*/    END;
                     GO TO MORE_M_C;                                            00376200
                  END;                                                          00376300
                  M_CHAR_PTR_MAX = 0;                                           00376400
               END;                                                             00376500
               ELSE                                                             00376600
                  IF STMT_STACK(PTR) = REPLACE_TEXT THEN                        00376700
                  DO;                                                           00376800
                  IF (GRAMMAR_FLAGS(PTR) & PRINT_FLAG)=0 THEN                   00376900
                     IF ^RECOVERING THEN GO TO PTR_LOOP_END;                    00377000
                  M_PTR=M_PTR+1;                                                00377100
                  M_CHAR_PTR = SYT_ADDR(MAC_NUM);                               00377200
                  BYTE(BUILD_M,M_PTR)=BYTE('"');                                00377300
                  M_PTR=M_PTR+1;                                                00377400
PRINT_TEXT:       PROCEDURE (LINELENGTH);                                       00377500
                     DECLARE LINELENGTH BIT(16);                                00377600
                     DECLARE WAS_HERE BIT(1);                                   00377610
                     WAS_HERE=FALSE;                                            00377700
                     J = MACRO_TEXT(M_CHAR_PTR);                                00377800
LINEDONE:                                                                       00377900
                     DO WHILE J ^= "EF" & M_PTR < LINELENGTH;                   00378000
                        IF J = "EE" THEN DO;                                    00378100
                           M_CHAR_PTR=M_CHAR_PTR+1;                             00378200
                           J = MACRO_TEXT(M_CHAR_PTR);                          00378300
                           IF J=0 THEN DO;                                      00378400
                              M_CHAR_PTR=M_CHAR_PTR+1;                          00378500
                              RETURN;                                           00378600
                           END;                                                 00378700
NEXT_LINE:                                                                      00378800
                           IF (J+M_PTR) >= LINELENGTH THEN DO;   /*DR109062*/   00378900
                              J = J-LINELENGTH+M_PTR;                           00379000
                              CALL RESET;                                       00379100
                              GO TO NEXT_LINE;                                  00379200
                           END;                                                 00379300
                           ELSE M_PTR=M_PTR+J;                                  00379400
                        END;                                                    00379500
                        ELSE IF J = BYTE('"') THEN DO;                          00379600
                           IF WAS_HERE THEN WAS_HERE = FALSE;                   00379700
                           ELSE DO;                                             00379800
                              WAS_HERE=TRUE;                                    00379900
                              M_CHAR_PTR=M_CHAR_PTR -1;                         00380000
                           END;                                                 00380100
                           BYTE(BUILD_M,M_PTR) = J;                             00380200
                        END;                                                    00380300
                        ELSE BYTE(BUILD_M,M_PTR) = J;                           00380400
                        M_PTR = M_PTR +1;                                       00380500
                        M_CHAR_PTR=M_CHAR_PTR+1;                                00380600
                        J = MACRO_TEXT(M_CHAR_PTR);                             00380700
                     END;                                                       00380800
                     IF J ^= "EF" THEN DO;                                      00380900
                        CALL RESET;                                             00381000
                        GO TO LINEDONE;                                         00381100
                     END;                                                       00381200
                     IF M_PTR = LINELENGTH THEN CALL RESET;      /*DR109062*/
                  END PRINT_TEXT;                                               00381300
                  CALL PRINT_TEXT(LINESIZE);                                    00381400
                  BYTE(BUILD_M,M_PTR) = BYTE('"');                              00381500
                  M_PTR=M_PTR+1;                                                00381600
               END;                                                             00381700
               ELSE                                                             00381800
                  DO;  /* NOT A CHARACTER STRING */                             00381900
                  C = ATTACH(PTR, 0);                                           00382000
                  IF LENGTH(C) = 0 THEN GO TO PTR_LOOP_END;                     00382100
                  M_PTR = M_PTR + SPACE_NEEDED;                                 00382200
                  IF LENGTH(C) + M_PTR >= LINESIZE THEN                         00382300
                     DO;                                                        00382400
                     CALL EXPAND(PTR - 1);                                      00382500
                     IF SQUEEZING THEN                                          00382600
                        DO;                                                     00382700
                        SQUEEZING = FALSE;                                      00382800
                        GRAMMAR_FLAGS(PTR) = GRAMMAR_FLAGS(PTR) | PRINT_FLAG;   00382900
                        GO TO OUTPUT_WRITER_END;                                00383000
                     END;                                                       00383100
                     M_PTR = MIN(INDENT_LEVEL, INDENT_LIMIT);                   00383200
                  END;                                                          00383300
                  IF PTR = PTR_START THEN                                       00383400
STLABEL:                                            /*DR108628,CR12157*/
                     IF LABEL_COUNT > 0 THEN                                    00383500
                     DO;                                                        00383600
                     TEMP = 0;                                                  00383700
                     LABEL_TOO_LONG = TRUE;                        /*DR109061*/
                     DO I = LABEL_START TO LABEL_END BY 2;                      00383800
                        J = TOKEN_FLAGS(I);                                     00383900
                        TEMP = TEMP + LENGTH(SAVE_BCD(SHR(J, 6))) + 2;          00384000
                     END;                                                       00384100
                     IF ((NEST_LEVEL = 0) & (TEMP <= M_PTR)) |     /*DR109061*/
                        ((NEST_LEVEL < 10) & (TEMP < (M_PTR-1))) | /*DR109061*/
                        ((NEST_LEVEL >= 10) & (TEMP < (M_PTR-2)))  /*DR109061*/
                     THEN DO;                                      /*DR109061*/
                        J = M_PTR - TEMP;                                       00384300
                        LABEL_TOO_LONG = FALSE;                    /*DR109061*/
                     END;                                          /*DR109061*/
                     ELSE                                                       00384400
                        J = 0;                                                  00384500
                     DO I = LABEL_START TO LABEL_END BY 2;                      00384600
                        K = TOKEN_FLAGS(I);                                     00384700
                        S = SAVE_BCD(SHR(K, 6));                                00384800
                        IF (LENGTH(S)+2+J) > LINESIZE THEN DO;     /*DR109066*/
                           J = I;                                  /*DR109066*/
                           CHAR = S;                               /*DR109066*/
                           CALL EXPAND(0);                         /*DR109066*/
                           I = J;                                  /*DR109066*/
                           S = CHAR;                               /*DR109066*/
                           J = 0;                                  /*DR109066*/
                        END;                                       /*DR109066*/
                        DO L = 0 TO LENGTH(S) - 1;                              00384900
                           K = BYTE(S, L);                                      00385000
                           BYTE(BUILD_M, J + L) = K;                            00385100
                        END;                                                    00385200
                        BYTE(BUILD_M, J + L) = BYTE(':');                       00385300
                        J = J + L + 2;                                          00385400
                     END;                                                       00385500
                     IF LABEL_TOO_LONG THEN                        /*DR109061*/ 00385600
                        CALL EXPAND(0);                                         00385700
                     LABEL_COUNT = 0;                                           00385800
                  END;                                                          00385900
                  IF PRINT_LABEL THEN GO TO AFTER_EXPAND; /*DR108628,CR12157*/
                  DO I = 0 TO LENGTH(C) - 1;                                    00386000
                     J = BYTE(C, I);                                            00386100
                     BYTE(BUILD_M, M_PTR + I) = J;                              00386200
                  END;                                                          00386300
                  I = TOKEN_FLAGS(PTR) & "1F";  /* TYPE FOR OVERPUNCH */        00386400
                  IF I > 0 THEN                                                 00386500
                     IF (I < SCALAR_TYPE) | (I = MAJ_STRUC) THEN                00386600
                     DO;                                                        00386700
                     K = OVER_PUNCH_TYPE(I);                                    00386800
                     I = (SHL(M_PTR, 1) - 1 + LENGTH(C)) / 2;                   00386900
                     BYTE(BUILD_E, I) = K;                                      00387000
                     BUILD_E_IND(I) = 1;                                        00387100
                     IF MAX_E_LEVEL = 0 THEN                                    00387200
                        MAX_E_LEVEL = 1;                                        00387300
                  END;                                                          00387400
                  IF (GRAMMAR_FLAGS(PTR) & MACRO_ARG_FLAG) ^= 0 THEN            00387500
                     DO;  /* REPLACE NAME, SO UNDERLINE IT */                   00387600
                     IF I = 7 THEN                                              00387610
                        MACRO_WRITTEN = TRUE;                                   00387620
                     DO I = 0 TO LENGTH(C) - 1;                                 00387700
                        BYTE(M_UNDERSCORE, M_PTR + I) = BYTE('_');              00387800
                     END;                                                       00387900
                     M_UNDERSCORE_NEEDED = TRUE;                                00388000
                  END;                                                          00388200
                  M_PTR = M_PTR + LENGTH(C);                                    00388400
               END;                                                             00388500
PTR_LOOP_END:                                                                   00388600
            END;  /* OF DO PTR = PTR_START TO PTR_END */                        00388700
            CALL EXPAND(PTR_END);  /* EXPAND BUFFERS */                         00388800
            IF SQUEEZING & (PTR > OUTPUT_STACK_MAX-2) THEN DO;  /*DR109081*/
               IF PTR > PTR_END+1 THEN PTR = PTR_END + 1;       /*DR109081*/
               SQUEEZING = FALSE;                               /*DR109081*/
               IF (SUB_START ^= 0) &                            /*DR109081*/
                  ((STMT_STACK(SUB_END+1) = DOLLAR) |           /*DR109081*/
                  (STMT_STACK(PTR_END) = EXPONENTIATE)) THEN    /*DR109081*/
                  CALL ERROR (CLASS_BS, 6);                     /*DR109081*/
               IF (EXP_START ^= 0) &                            /*DR109081*/
                  ((STMT_STACK(PTR_END) = DOLLAR) |             /*DR109081*/
                  (STMT_STACK(EXP_END+1) = EXPONENTIATE)) THEN  /*DR109081*/
                  CALL ERROR (CLASS_BS, 6);                     /*DR109081*/
            END;                                                /*DR109081*/
AFTER_EXPAND:                                     /*DR108628,CR12157*/
            IF PTR_END = STMT_PTR THEN                                          00388900
               DO;                                                              00389000
               IF STMT_PTR = STMT_END_PTR THEN STMT_END_PTR = -2;               00389010
               STMT_PTR = -1;                                                   00389100
               BCD_PTR, LAST_WRITE, ELSEIF_PTR = 0;                             00389200
            END;                                                                00389300
OUTPUT_WRITER_END:                                                              00389400
            LAST_SPACE = 2;                                                     00389500
            MACRO_WRITTEN = FALSE;                                              00389600
PRINT_ANY_ERRORS:                                                               00389700
            END_FLAG = FALSE;                              /*CR12713*/
            PAGE_THROWN, PTR_START = 0;                                         00389800
            PTR_END = -1;                                                       00389900
                                                                                00325600
            /* DR109042 -- BACKED OUT INCORRECT DR108629 FIX */
            IF STMT_PTR = -1 THEN  /* ALL TOKEN WRITTEN */
               IF LAST_ERROR_WRITTEN < LAST THEN DO;  /* GET ALL ERRORS */      00390100
               CURRENT_ERROR_PTR = LAST;                                        00390200
               CALL ERROR_PRINT;                                                00390300
            END;                                                                00390400
            IF ERRORS_PRINTED THEN DO;                                          00390500
               IF TOO_MANY_ERRORS THEN                                          00390600
                  DO;                                                           00390700
                  CALL ERRORS (CLASS_BI, 101);                                  00390800
                  TOO_MANY_ERRORS = FALSE;                                      00391000
               END;                                                             00391100
               IF OUT_PREV_ERROR ^= 0 THEN                                      00391200
                  OUTPUT = '***** LAST ERROR WAS DETECTED AT STATEMENT ' ||     00391300
                  OUT_PREV_ERROR || PERIOD || X1 || STARS;          /*CR13335*/ 00391400
               /* DR109042 -- THIS PART OF DR108629 FIX IS CORRECT */
               OUT_PREV_ERROR = STMT_NUM;                  /*DR108629*/         00391500
               IF LAST_ERROR_WRITTEN >= LAST THEN                               00391700
                  LAST_ERROR_WRITTEN, CURRENT_ERROR_PTR, LAST = -1;             00391800
            END;  /* OF DO WHEN ERRORS_PRINTED */                               00391900
            SAVE_SCOPE = CURRENT_SCOPE;                                         00397000
            IF STACK_DUMPED THEN DO;                                            00397100
               DO I = 0 TO STACK_DUMP_PTR;                                      00397200
               OUTPUT = SAVE_STACK_DUMP(I);  END;                               00397300
                  STACK_DUMP_PTR = -1;                                          00397400
               STACK_DUMPED = FALSE;                                            00397500
            END;                                                                00397600
/*DR109036 SEVERITY 3&4 ABORT NOW HANDLED IN ERROR ROUTINE */                   00295145
/*DR109036 (REMOVED CODE ADDED FOR CR12416) */                                  00295145
            RETURN PTR;                                                         00397700
         END OUTPUT_WRITER   /* $S */ ; /* $S */                                00399400
