 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETNODE.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  GET_NODE                                               */
 /* MEMBER NAME:     GETNODE                                                */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ARRAYED_TSUB_OP   FIXED                                        */
 /*          BUMP_SEARCH(1283) LABEL                                        */
 /*          CATALOG_CHECK(1273)  LABEL                                     */
 /*          I                 BIT(16)                                      */
 /*          INV_INX           BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ARRAYED_CONDITIONAL                                            */
 /*          CSE_INX                                                        */
 /*          CSE_TAB                                                        */
 /*          END_OF_LIST                                                    */
 /*          END_OF_NODE                                                    */
 /*          EXTN                                                           */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          LEVEL                                                          */
 /*          LEVEL_STACK_VARS                                               */
 /*          NOT                                                            */
 /*          STACK_TAGS                                                     */
 /*          TRACE                                                          */
 /*          TRUE                                                           */
 /*          TWIN_OP                                                        */
 /*          VALUE_NO                                                       */
 /*          WIPEOUT#                                                       */
 /*          XSTACK_TAGS                                                    */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ARRAYED_TSUB                                                   */
 /*          EXTNS_PRESENT                                                  */
 /*          GET_INX                                                        */
 /*          INVARIANT_COMPUTATION                                          */
 /*          LEV                                                            */
 /*          NODE                                                           */
 /*          NODE_BEGINNING                                                 */
 /*          NODE_SIZE                                                      */
 /*          NODE2                                                          */
 /*          NONCOMMUTATIVE                                                 */
 /*          OP                                                             */
 /*          OPTYPE                                                         */
 /*          PRESENT_NODE_PTR                                               */
 /*          SEARCH                                                         */
 /*          SEARCH_INX                                                     */
 /*          SEARCHABLE                                                     */
 /*          SEARCH2                                                        */
 /*          STILL_NODES                                                    */
 /*          SYT_POINT                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CATALOG_PTR                                                    */
 /*          CATALOG_SRCH                                                   */
 /*          CATALOG                                                        */
 /*          CONTROL                                                        */
 /*          CSE_WORD_FORMAT                                                */
 /*          EXTRACT_INVARS                                                 */
 /*          INVAR                                                          */
 /*          SEARCH_SORTER                                                  */
 /*          SET_ARRAYNESS                                                  */
 /*          SET_NONCOMMUTATIVE                                             */
 /*          SORTER                                                         */
 /*          TABLE_NODE                                                     */
 /*          TYPE                                                           */
 /*          VALIDITY                                                       */
 /* CALLED BY:                                                              */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GET_NODE <==                                                        */
 /*     ==> CATALOG_PTR                                                     */
 /*     ==> VALIDITY                                                        */
 /*     ==> SORTER                                                          */
 /*     ==> SEARCH_SORTER                                                   */
 /*     ==> CSE_WORD_FORMAT                                                 */
 /*         ==> HEX                                                         */
 /*     ==> CONTROL                                                         */
 /*     ==> SET_NONCOMMUTATIVE                                              */
 /*         ==> HEX                                                         */
 /*     ==> TYPE                                                            */
 /*     ==> SET_ARRAYNESS                                                   */
 /*         ==> LAST_OPERAND                                                */
 /*         ==> TYPE                                                        */
 /*         ==> ARRAYED_ELT                                                 */
 /*             ==> CSE_WORD_FORMAT                                         */
 /*                 ==> HEX                                                 */
 /*             ==> TYPE                                                    */
 /*     ==> INVAR                                                           */
 /*         ==> CSE_WORD_FORMAT                                             */
 /*             ==> HEX                                                     */
 /*         ==> TYPE                                                        */
 /*         ==> ARRAYED_ELT                                                 */
 /*             ==> CSE_WORD_FORMAT                                         */
 /*                 ==> HEX                                                 */
 /*             ==> TYPE                                                    */
 /*         ==> ZAP_BIT                                                     */
 /*     ==> CATALOG_SRCH                                                    */
 /*     ==> CATALOG                                                         */
 /*         ==> SET_CATALOG_PTR                                             */
 /*         ==> SET_VALIDITY                                                */
 /*         ==> GET_FREE_SPACE                                              */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*         ==> CATALOG_ENTRY                                               */
 /*             ==> GET_EON                                                 */
 /*             ==> GET_FREE_SPACE                                          */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*     ==> TABLE_NODE                                                      */
 /*         ==> GET_FREE_SPACE                                              */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*         ==> TYPE                                                        */
 /*         ==> CATALOG_SRCH                                                */
 /*         ==> CATALOG_ENTRY                                               */
 /*             ==> GET_EON                                                 */
 /*             ==> GET_FREE_SPACE                                          */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*     ==> EXTRACT_INVARS                                                  */
 /*         ==> PULL_INVARS                                                 */
 /*             ==> BUMP_AR_INV                                             */
 /*             ==> GET_ADLP                                                */
 /*                 ==> OPOP                                                */
 /*                 ==> LAST_OP                                             */
 /*             ==> REARRANGE_HALMAT                                        */
 /*                 ==> GET_LIT_ONE                                         */
 /*                     ==> SAVE_LITERAL                                    */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> GET_LITERAL                                 */
 /*                 ==> LAST_OP                                             */
 /*                 ==> TWIN_HALMATTED                                      */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> MOVE_LIMB                                           */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> RELOCATE                                        */
 /*                     ==> MOVECODE                                        */
 /*                         ==> ENTER                                       */
 /*                 ==> SWITCH                                              */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> ENTER                                           */
 /*                     ==> LAST_OP                                         */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> MOVE_LIMB                                       */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> RELOCATE                                    */
 /*                         ==> MOVECODE                                    */
 /*                             ==> ENTER                                   */
 /*                     ==> NEXT_FLAG                                       */
 /*                         ==> NO_OPERANDS                                 */
 /*                 ==> PTR_TO_VAC                                          */
 /*                 ==> REFERENCE                                           */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> TERMINAL                                        */
 /*                         ==> VAC_OR_XPT                                  */
 /*                         ==> HALMAT_FLAG                                 */
 /*                             ==> VAC_OR_XPT                              */
 /*                         ==> CLASSIFY                                    */
 /*                             ==> PRINT_SENTENCE                          */
 /*                                 ==> FORMAT                              */
 /*                                 ==> HEX                                 */
 /*                 ==> SET_HALMAT_FLAG                                     */
 /*                 ==> SET_VAC_REF                                         */
 /*                     ==> OPOP                                            */
 /*                     ==> ENTER                                           */
 /*                 ==> PUT_NOP                                             */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> CLASSIFY                                        */
 /*                         ==> PRINT_SENTENCE                              */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*                     ==> TERMINAL                                        */
 /*                         ==> VAC_OR_XPT                                  */
 /*                         ==> HALMAT_FLAG                                 */
 /*                             ==> VAC_OR_XPT                              */
 /*                         ==> CLASSIFY                                    */
 /*                             ==> PRINT_SENTENCE                          */
 /*                                 ==> FORMAT                              */
 /*                                 ==> HEX                                 */
 /*                 ==> COLLECT_MATCHES                                     */
 /*                     ==> PRINT_SENTENCE                                  */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*                     ==> SET_HALMAT_FLAG                                 */
 /*                     ==> FLAG_MATCHES                                    */
 /*                         ==> PRINT_SENTENCE                              */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*                         ==> TYPE                                        */
 /*                         ==> FLAG_VAC_OR_LIT                             */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> COMPARE_LITERALS                        */
 /*                                 ==> HEX                                 */
 /*                                 ==> GET_LITERAL                         */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> SET_FLAG                                */
 /*                         ==> FLAG_V_N                                    */
 /*                             ==> CATALOG_PTR                             */
 /*                             ==> VALIDITY                                */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> SET_FLAG                                */
 /*                     ==> FLAG_NODE                                       */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> HALMAT_FLAG                                 */
 /*                             ==> VAC_OR_XPT                              */
 /*                         ==> CLASSIFY                                    */
 /*                             ==> PRINT_SENTENCE                          */
 /*                                 ==> FORMAT                              */
 /*                                 ==> HEX                                 */
 /*                         ==> TERMINAL                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> CLASSIFY                                */
 /*                                 ==> PRINT_SENTENCE                      */
 /*                                     ==> FORMAT                          */
 /*                                     ==> HEX                             */
 /*                         ==> SET_FLAG                                    */
 /*                     ==> SET_WORDS                                       */
 /*                         ==> NEXT_FLAG                                   */
 /*                             ==> NO_OPERANDS                             */
 /*                         ==> FORM_OPERATOR                               */
 /*                             ==> HEX                                     */
 /*                         ==> SET_VAC_REF                                 */
 /*                             ==> OPOP                                    */
 /*                             ==> ENTER                                   */
 /*                         ==> FORCE_TERMINAL                              */
 /*                             ==> NEXT_FLAG                               */
 /*                                 ==> NO_OPERANDS                         */
 /*                             ==> SWITCH                                  */
 /*                                 ==> VAC_OR_XPT                          */
 /*                                 ==> ENTER                               */
 /*                                 ==> LAST_OP                             */
 /*                                 ==> NO_OPERANDS                         */
 /*                                 ==> HALMAT_FLAG                         */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                 ==> MOVE_LIMB                           */
 /*                                     ==> ERRORS                          */
 /*                                         ==> COMMON_ERRORS               */
 /*                                     ==> RELOCATE                        */
 /*                                     ==> MOVECODE                        */
 /*                                         ==> ENTER                       */
 /*                                 ==> NEXT_FLAG                           */
 /*                                     ==> NO_OPERANDS                     */
 /*                             ==> TERMINAL                                */
 /*                                 ==> VAC_OR_XPT                          */
 /*                                 ==> HALMAT_FLAG                         */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                 ==> CLASSIFY                            */
 /*                                     ==> PRINT_SENTENCE                  */
 /*                                         ==> FORMAT                      */
 /*                                         ==> HEX                         */
 /*                         ==> PUSH_OPERAND                                */
 /*                             ==> ENTER                                   */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> NEXT_FLAG                               */
 /*                                 ==> NO_OPERANDS                         */
 /*                             ==> TERMINAL                                */
 /*                                 ==> VAC_OR_XPT                          */
 /*                                 ==> HALMAT_FLAG                         */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                 ==> CLASSIFY                            */
 /*                                     ==> PRINT_SENTENCE                  */
 /*                                         ==> FORMAT                      */
 /*                                         ==> HEX                         */
 /*                         ==> FORCE_MATCH                                 */
 /*                             ==> NEXT_FLAG                               */
 /*                                 ==> NO_OPERANDS                         */
 /*                             ==> SWITCH                                  */
 /*                                 ==> VAC_OR_XPT                          */
 /*                                 ==> ENTER                               */
 /*                                 ==> LAST_OP                             */
 /*                                 ==> NO_OPERANDS                         */
 /*                                 ==> HALMAT_FLAG                         */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                 ==> MOVE_LIMB                           */
 /*                                     ==> ERRORS                          */
 /*                                         ==> COMMON_ERRORS               */
 /*                                     ==> RELOCATE                        */
 /*                                     ==> MOVECODE                        */
 /*                                         ==> ENTER                       */
 /*                                 ==> NEXT_FLAG                           */
 /*                                     ==> NO_OPERANDS                     */
 /*                 ==> BOTTOM                                              */
 /*                     ==> LAST_OP                                         */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                 ==> PUT_BFNC_TWIN                                       */
 /*             ==> SETUP_REARRANGE                                         */
 /*                 ==> LAST_OP                                             */
 /*                 ==> CLASSIFY                                            */
 /*                     ==> PRINT_SENTENCE                                  */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*                 ==> LOOPY                                               */
 /*                     ==> GET_CLASS                                       */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> ASSIGN_TYPE                                     */
 /*                     ==> NO_OPERANDS                                     */
 /*             ==> STRIP_NODES                                             */
 /*                 ==> COMPARE_LITERALS                                    */
 /*                     ==> HEX                                             */
 /*                     ==> GET_LITERAL                                     */
 /*                 ==> GET_LIT_ONE                                         */
 /*                     ==> SAVE_LITERAL                                    */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> GET_LITERAL                                 */
 /*                 ==> SORTER                                              */
 /*                 ==> CSE_TAB_DUMP                                        */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*                     ==> CATALOG_PTR                                     */
 /*                     ==> VALIDITY                                        */
 /*                     ==> CSE_WORD_FORMAT                                 */
 /*                         ==> HEX                                         */
 /*                 ==> REVERSE_PARITY                                      */
 /*                 ==> SET_NONCOMMUTATIVE                                  */
 /*                     ==> HEX                                             */
 /*                 ==> TYPE                                                */
 /*                 ==> SET_ARRAYNESS                                       */
 /*                     ==> LAST_OPERAND                                    */
 /*                     ==> TYPE                                            */
 /*                     ==> ARRAYED_ELT                                     */
 /*                         ==> CSE_WORD_FORMAT                             */
 /*                             ==> HEX                                     */
 /*                         ==> TYPE                                        */
 /*                 ==> CATALOG_SRCH                                        */
 /*                 ==> CATALOG_VAC                                         */
 /*                     ==> GET_FREE_SPACE                                  */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                     ==> CATALOG_ENTRY                                   */
 /*                         ==> GET_EON                                     */
 /*                         ==> GET_FREE_SPACE                              */
 /*                             ==> ERRORS                                  */
 /*                                 ==> COMMON_ERRORS                       */
 /*                 ==> SET_O_T_V                                           */
 /*                     ==> CSE_WORD_FORMAT                                 */
 /*                         ==> HEX                                         */
 /*             ==> CHECK_INVAR                                             */
 /*                 ==> GET_EON                                             */
 /*                 ==> ARRAYED_ELT                                         */
 /*                     ==> CSE_WORD_FORMAT                                 */
 /*                         ==> HEX                                         */
 /*                     ==> TYPE                                            */
 /*                 ==> INVAR                                               */
 /*                     ==> CSE_WORD_FORMAT                                 */
 /*                         ==> HEX                                         */
 /*                     ==> TYPE                                            */
 /*                     ==> ARRAYED_ELT                                     */
 /*                         ==> CSE_WORD_FORMAT                             */
 /*                             ==> HEX                                     */
 /*                         ==> TYPE                                        */
 /*                     ==> ZAP_BIT                                         */
 /*             ==> EJECT_INVARS                                            */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> LAST_OPERAND                                        */
 /*                 ==> MOVE_LIMB                                           */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> RELOCATE                                        */
 /*                     ==> MOVECODE                                        */
 /*                         ==> ENTER                                       */
 /*                 ==> PUSH_HALMAT                                         */
 /*                     ==> HEX                                             */
 /*                     ==> OPOP                                            */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> BUMP_D_N                                        */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> ENTER                                           */
 /*                     ==> LAST_OP                                         */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> MOVE_LIMB                                       */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> RELOCATE                                    */
 /*                         ==> MOVECODE                                    */
 /*                             ==> ENTER                                   */
 /*                 ==> GROUP_CSE                                           */
 /*                     ==> LAST_OP                                         */
 /*                     ==> LAST_OPERAND                                    */
 /*                     ==> MOVE_LIMB                                       */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> RELOCATE                                    */
 /*                         ==> MOVECODE                                    */
 /*                             ==> ENTER                                   */
 /*                     ==> BUMP_ADD                                        */
 /*                     ==> TERMINAL                                        */
 /*                         ==> VAC_OR_XPT                                  */
 /*                         ==> HALMAT_FLAG                                 */
 /*                             ==> VAC_OR_XPT                              */
 /*                         ==> CLASSIFY                                    */
 /*                             ==> PRINT_SENTENCE                          */
 /*                                 ==> FORMAT                              */
 /*                                 ==> HEX                                 */
 /*                 ==> GET_ADLP                                            */
 /*                     ==> OPOP                                            */
 /*                     ==> LAST_OP                                         */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /* 03/19/98 JAC  29V0  DR109092 INDEX OUT OF RANGE FOR HALMAT OPERAND      */
 /*               14V0           ARRAY                                      */
 /*                                                                         */
 /* 01/29/05 TKN  32V0  DR120263 INFINITE LOOP FOR ARRAYED CONDITIONAL      */
 /*               17V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                04138830
                                                                                04138840
 /* GETS NODE AND UPDATES CATALOG_PTR'S IN SYMBOL TABLE AND HALMAT*/            04138850
GET_NODE:                                                                       04138860
   PROCEDURE;                                                                   04138870
      DECLARE I BIT(16);                                                        04138880
      DECLARE (TEMP,INV_INX) BIT(16);                                           04138900
      DECLARE ARRAYED_TSUB_OP FIXED INITIAL("2000 001B");                       04138910
                                                                                04138920
BUMP_SEARCH:                                                                    04138930
      PROCEDURE(TAG);                                                           04138940
         DECLARE TAG BIT(8);                                                    04138950
         SEARCH_INX = SEARCH_INX + 1;                                           04138960
         IF TAG THEN DO;                                                        04138970
            SEARCH(SEARCH_INX) =                                                04138980
               CATALOG_PTR(SYT_POINT) | CONTROL(NODE) | VALUE_NO;               04138990
            SEARCH2(SEARCH_INX) = WIPEOUT#(SYT_POINT);                          04139000
            TAG = 0;                                                            04139010
         END;                                                                   04139020
                                                                                04139030
         ELSE DO;                                                               04139040
            SEARCH(SEARCH_INX) = NODE;                                          04139050
            SEARCH2(SEARCH_INX) = NODE2;                                        04139060
         END;                                                                   04139070
      END BUMP_SEARCH;                                                          04139080
                                                                                04139090
 /* ENTERS NEW OP IN CATALOG; TRUE IF OP WASN'T ALREADY IN CATALOG*/            04139100
CATALOG_CHECK:                                                                  04139110
      PROCEDURE(CAT_POINT, BUMP#) BIT(8);                                       04139120
         DECLARE CAT_POINT BIT(16),                                             04139130
            BUMP# BIT(8);                                                       04139140
         IF CATALOG_SRCH(CAT_POINT) = 0 THEN DO;  /* OPTYPE NOT IN TABLE*/      04139150
            IF ^ARRAYED_CONDITIONAL THEN CALL CATALOG(0,1);  /* PUT IN TABLE */ 04139160
            IF TWIN_OP THEN IF CATALOG_SRCH(CAT_POINT,1) ^= 0 THEN              04139170
               CALL BUMP_SEARCH(BUMP#);                                         04139180
            RETURN TRUE;                                                        04139190
         END;                                                                   04139200
         RETURN FALSE;                                                          04139210
      END CATALOG_CHECK;                                                        04139220
                                                                                04139230
                                                                                04139240
      INV_INX = 0;                                                              04139250
      LEV = LEVEL;                                                              04139260
      IF NODE(GET_INX) = END_OF_LIST THEN DO;                                   04139270
         SEARCHABLE,STILL_NODES = FALSE;                                        04139280
         RETURN;                                                                04139290
      END;                                                                      04139300
      SEARCH_INX = 0;                                                           04139310
      OP,OPTYPE = NODE(GET_INX) & "FFFF";                                       04139320
      IF OPTYPE = EXTN THEN EXTNS_PRESENT = TRUE;                               04139330
      NONCOMMUTATIVE = SET_NONCOMMUTATIVE(OP);                                  04139340
      NODE_BEGINNING = GET_INX ;   /* POINTS TO OPTYPE FOR NODE */              04139350
      GET_INX = GET_INX -1;                                                     04139360
      NODE = NODE(GET_INX);                                                     04139370
      NODE2 = NODE2(GET_INX);                                                   04139380
      DO WHILE NODE ^= END_OF_NODE & SEARCH_INX < (MAX_NODE - 1); /*DR109092*/  04139390
         DO CASE TYPE(NODE);                                                    04139400
            ;             /* 0 = EMPTY NODE */                                  04139410
            DO;               /* 1 = SYT */                                     04139420
               SYT_POINT = NODE & "FFFF";                                       04139430
               IF TRACE THEN DO;                                                04139440
                  OUTPUT = 'GET_NODE:  SYT_POINT '||SYT_POINT;                  04139450
                  OUTPUT = '         VALIDITY '||VALIDITY(SYT_POINT);           04139460
               END;                                                             04139470
               IF ^ VALIDITY(SYT_POINT) THEN DO;  /* NOTHING IN CATALOG*/       04139480
                                                                                04139490
                  CALL CATALOG(SYT_POINT);                  /*DR120263*/
                  IF ARRAYED_CONDITIONAL THEN               /*DR120263*/
                     CSE_TAB(CATALOG_PTR(SYT_POINT)+1) = 0; /*DR120263*/
               END;                                                             04139510
                                                                                04139520
               ELSE DO;                                                         04139530
                                                                                04139540
                  IF CATALOG_CHECK(CATALOG_PTR(SYT_POINT),1) THEN ;             04139550
                  ELSE IF CSE_TAB(CSE_INX) ^= NODE_BEGINNING THEN DO;           04139560
 /* VARIABLE NOT JUST CATALOGED*/                                               04139570
                     CALL BUMP_SEARCH(1);                                       04139580
                  END;                                                          04139590
                                                                                04139600
               END;                                                             04139610
               NODE(GET_INX) =                                                  04139620
                  CATALOG_PTR(SYT_POINT) | CONTROL(NODE) | VALUE_NO;            04139630
               NODE2(GET_INX) = SYT_POINT;                                      04139640
            END; /*SYT*/                                                        04139650
                                                                                04139660
            ;;                /* IGNORE TERMINAL VACS */                        04139670
               ;;                                                               04139680
               DO;               /* 6 = IMMEDIATE */                            04139690
               CALL BUMP_SEARCH;                                                04139700
            END;                                                                04139710
            CALL BUMP_SEARCH;         /* 7 = AST*/                              04139720
            CALL BUMP_SEARCH;         /* 8 = CSZ*/                              04139730
            CALL BUMP_SEARCH;         /* 9 = ASZ*/                              04139740
            ;                         /* A = OFF*/                              04139750
            DO;                       /* B = VALUE_NO (ONLY AFTER MATCH)*/      04139760
               IF CATALOG_SRCH(NODE & "FFFF") ^= 0 THEN                         04139770
                  IF CSE_TAB(CSE_INX) ^= NODE_BEGINNING THEN CALL BUMP_SEARCH;  04139780
            END;                                                                04139790
                                                                                04139800
 /* C = OUTER_TERMINAL_VAC*/                                                    04139810
            IF NODE2 ^= 0 THEN DO;                                              04139820
               IF NOT CATALOG_CHECK(NODE2,0) THEN CALL BUMP_SEARCH;             04139830
            END;                                                                04139840
            ;                                   /* DUMMY_NODE.  IGNORE.*/       04139850
            CALL BUMP_SEARCH  /* LITERAL*/;;  /*SAFETY*/                        04139860
            END; /*DO CASE*/                                                    04139870
                                                                                04139880
         IF SHR(STACK_TAGS(LEVEL),2) THEN                                       04139890
            INV_INX = INV_INX + INVAR(NODE(GET_INX),NODE2(GET_INX));            04139900
         GET_INX = GET_INX - 1;                                                 04139910
         NODE = NODE(GET_INX);                                                  04139920
         NODE2 = NODE2(GET_INX);                                                04139930
      END; /*DO WHILE*/                                                         04139940
      IF ^ NONCOMMUTATIVE THEN CALL SORTER(GET_INX + 1,NODE_BEGINNING - 1);     04139950
      NODE_SIZE = SEARCH_INX;                                                   04139960
                                                                                04139970
      CALL SET_ARRAYNESS(NODE_BEGINNING);                                       04139980
      IF NODE(NODE_BEGINNING) = ARRAYED_TSUB_OP THEN ARRAYED_TSUB = TRUE;       04139990
      ELSE ARRAYED_TSUB = FALSE;                                                04140000
      TEMP = NODE_BEGINNING - GET_INX - 1;                                      04140010
      IF SHR(STACK_TAGS(LEVEL),2) THEN                                          04140020
         INVARIANT_COMPUTATION = NONCOMMUTATIVE & INV_INX = TEMP                04140030
         | ^NONCOMMUTATIVE & INV_INX >= 2;                                      04140040
      ELSE INVARIANT_COMPUTATION = FALSE;                                       04140050
                                                                                04140060
      IF NONCOMMUTATIVE & SEARCH_INX ^= TEMP                                    04140070
         | ^NONCOMMUTATIVE & SEARCH_INX < 2 THEN DO;                            04140080
         IF ^ARRAYED_TSUB THEN CALL EXTRACT_INVARS;                             04140090
         CALL TABLE_NODE;                                                       04140100
         SEARCHABLE = FALSE;                                                    04140110
      END;                                                                      04140120
      ELSE DO;                                                                  04140130
         IF ^NONCOMMUTATIVE THEN CALL SEARCH_SORTER(1,SEARCH_INX);              04140140
         SEARCH_INX = SEARCH_INX + 1;                                           04140150
         SEARCH(SEARCH_INX) = END_OF_NODE;                                      04140160
         SEARCH2(SEARCH_INX) = 0;                                               04140170
         SEARCHABLE = TRUE;                                                     04140180
         IF TRACE THEN DO;                                                      04140190
            OUTPUT = '';                                                        04140200
            OUTPUT = '     SEARCH LIST';                                        04140210
            DO FOR I = 1 TO SEARCH_INX;                                         04140220
               OUTPUT= CSE_WORD_FORMAT(SEARCH(I))||' *** '||SEARCH2(I);         04140230
            END;                                                                04140240
         END;                                                                   04140250
      END;                                                                      04140260
      PRESENT_NODE_PTR = GET_INX - 1;                                           04140270
      GET_INX = GET_INX - 2;                                                    04140280
      IF NODE(GET_INX) = END_OF_LIST THEN STILL_NODES=FALSE;                    04140290
   END GET_NODE;                                                                04140300
