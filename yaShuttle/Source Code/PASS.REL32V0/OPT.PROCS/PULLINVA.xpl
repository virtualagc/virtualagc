 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PULLINVA.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  PULL_INVARS                                            */
 /* MEMBER NAME:     PULLINVA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          AR_INV            BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          NOT_TSUB          BIT(8)                                       */
 /*          EXITT             LABEL                                        */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          ARRAYED_OPS                                                    */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          I_TRACE                                                        */
 /*          LEVEL                                                          */
 /*          NODE                                                           */
 /*          NODE_BEGINNING                                                 */
 /*          NONCOMMUTATIVE                                                 */
 /*          OR                                                             */
 /*          PULL_LOOP_HEAD                                                 */
 /*          STACK_TAGS                                                     */
 /*          STACK_TRACE                                                    */
 /*          STATEMENT_ARRAYNESS                                            */
 /*          STATISTICS                                                     */
 /*          STT#                                                           */
 /*          TOTAL_MATCH_PRES                                               */
 /*          TRUE                                                           */
 /*          TSUB                                                           */
 /*          XPULL_LOOP_HEAD                                                */
 /*          XSTACK_TAGS                                                    */
 /*          XZAP_BASE                                                      */
 /*          ZAP_BASE                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          INVAR#                                                         */
 /*          INVARIANT_COMPUTATION                                          */
 /*          INVARIANT_PULLED                                               */
 /*          LEVEL_STACK_VARS                                               */
 /*          LEV                                                            */
 /*          LOOP_ZAPS_LEVEL                                                */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BUMP_AR_INV                                                    */
 /*          CHECK_INVAR                                                    */
 /*          EJECT_INVARS                                                   */
 /*          GET_ADLP                                                       */
 /*          REARRANGE_HALMAT                                               */
 /*          SETUP_REARRANGE                                                */
 /*          STRIP_NODES                                                    */
 /* CALLED BY:                                                              */
 /*          EXTRACT_INVARS                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PULL_INVARS <==                                                     */
 /*     ==> BUMP_AR_INV                                                     */
 /*     ==> GET_ADLP                                                        */
 /*         ==> OPOP                                                        */
 /*         ==> LAST_OP                                                     */
 /*     ==> REARRANGE_HALMAT                                                */
 /*         ==> GET_LIT_ONE                                                 */
 /*             ==> SAVE_LITERAL                                            */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> GET_LITERAL                                         */
 /*         ==> LAST_OP                                                     */
 /*         ==> TWIN_HALMATTED                                              */
 /*         ==> PRINT_SENTENCE                                              */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
 /*         ==> MOVE_LIMB                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> RELOCATE                                                */
 /*             ==> MOVECODE                                                */
 /*                 ==> ENTER                                               */
 /*         ==> SWITCH                                                      */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> ENTER                                                   */
 /*             ==> LAST_OP                                                 */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> MOVE_LIMB                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> RELOCATE                                            */
 /*                 ==> MOVECODE                                            */
 /*                     ==> ENTER                                           */
 /*             ==> NEXT_FLAG                                               */
 /*                 ==> NO_OPERANDS                                         */
 /*         ==> PTR_TO_VAC                                                  */
 /*         ==> REFERENCE                                                   */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> TERMINAL                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> CLASSIFY                                            */
 /*                     ==> PRINT_SENTENCE                                  */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*         ==> SET_HALMAT_FLAG                                             */
 /*         ==> SET_VAC_REF                                                 */
 /*             ==> OPOP                                                    */
 /*             ==> ENTER                                                   */
 /*         ==> PUT_NOP                                                     */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> CLASSIFY                                                */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*             ==> TERMINAL                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> CLASSIFY                                            */
 /*                     ==> PRINT_SENTENCE                                  */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*         ==> COLLECT_MATCHES                                             */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*             ==> SET_HALMAT_FLAG                                         */
 /*             ==> FLAG_MATCHES                                            */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*                 ==> TYPE                                                */
 /*                 ==> FLAG_VAC_OR_LIT                                     */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> COMPARE_LITERALS                                */
 /*                         ==> HEX                                         */
 /*                         ==> GET_LITERAL                                 */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> SET_FLAG                                        */
 /*                 ==> FLAG_V_N                                            */
 /*                     ==> CATALOG_PTR                                     */
 /*                     ==> VALIDITY                                        */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> SET_FLAG                                        */
 /*             ==> FLAG_NODE                                               */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> CLASSIFY                                            */
 /*                     ==> PRINT_SENTENCE                                  */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*                 ==> TERMINAL                                            */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> CLASSIFY                                        */
 /*                         ==> PRINT_SENTENCE                              */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*                 ==> SET_FLAG                                            */
 /*             ==> SET_WORDS                                               */
 /*                 ==> NEXT_FLAG                                           */
 /*                     ==> NO_OPERANDS                                     */
 /*                 ==> FORM_OPERATOR                                       */
 /*                     ==> HEX                                             */
 /*                 ==> SET_VAC_REF                                         */
 /*                     ==> OPOP                                            */
 /*                     ==> ENTER                                           */
 /*                 ==> FORCE_TERMINAL                                      */
 /*                     ==> NEXT_FLAG                                       */
 /*                         ==> NO_OPERANDS                                 */
 /*                     ==> SWITCH                                          */
 /*                         ==> VAC_OR_XPT                                  */
 /*                         ==> ENTER                                       */
 /*                         ==> LAST_OP                                     */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> HALMAT_FLAG                                 */
 /*                             ==> VAC_OR_XPT                              */
 /*                         ==> MOVE_LIMB                                   */
 /*                             ==> ERRORS                                  */
 /*                                 ==> COMMON_ERRORS                       */
 /*                             ==> RELOCATE                                */
 /*                             ==> MOVECODE                                */
 /*                                 ==> ENTER                               */
 /*                         ==> NEXT_FLAG                                   */
 /*                             ==> NO_OPERANDS                             */
 /*                     ==> TERMINAL                                        */
 /*                         ==> VAC_OR_XPT                                  */
 /*                         ==> HALMAT_FLAG                                 */
 /*                             ==> VAC_OR_XPT                              */
 /*                         ==> CLASSIFY                                    */
 /*                             ==> PRINT_SENTENCE                          */
 /*                                 ==> FORMAT                              */
 /*                                 ==> HEX                                 */
 /*                 ==> PUSH_OPERAND                                        */
 /*                     ==> ENTER                                           */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> NEXT_FLAG                                       */
 /*                         ==> NO_OPERANDS                                 */
 /*                     ==> TERMINAL                                        */
 /*                         ==> VAC_OR_XPT                                  */
 /*                         ==> HALMAT_FLAG                                 */
 /*                             ==> VAC_OR_XPT                              */
 /*                         ==> CLASSIFY                                    */
 /*                             ==> PRINT_SENTENCE                          */
 /*                                 ==> FORMAT                              */
 /*                                 ==> HEX                                 */
 /*                 ==> FORCE_MATCH                                         */
 /*                     ==> NEXT_FLAG                                       */
 /*                         ==> NO_OPERANDS                                 */
 /*                     ==> SWITCH                                          */
 /*                         ==> VAC_OR_XPT                                  */
 /*                         ==> ENTER                                       */
 /*                         ==> LAST_OP                                     */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> HALMAT_FLAG                                 */
 /*                             ==> VAC_OR_XPT                              */
 /*                         ==> MOVE_LIMB                                   */
 /*                             ==> ERRORS                                  */
 /*                                 ==> COMMON_ERRORS                       */
 /*                             ==> RELOCATE                                */
 /*                             ==> MOVECODE                                */
 /*                                 ==> ENTER                               */
 /*                         ==> NEXT_FLAG                                   */
 /*                             ==> NO_OPERANDS                             */
 /*         ==> BOTTOM                                                      */
 /*             ==> LAST_OP                                                 */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*         ==> PUT_BFNC_TWIN                                               */
 /*     ==> SETUP_REARRANGE                                                 */
 /*         ==> LAST_OP                                                     */
 /*         ==> CLASSIFY                                                    */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*         ==> LOOPY                                                       */
 /*             ==> GET_CLASS                                               */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> ASSIGN_TYPE                                             */
 /*             ==> NO_OPERANDS                                             */
 /*     ==> STRIP_NODES                                                     */
 /*         ==> COMPARE_LITERALS                                            */
 /*             ==> HEX                                                     */
 /*             ==> GET_LITERAL                                             */
 /*         ==> GET_LIT_ONE                                                 */
 /*             ==> SAVE_LITERAL                                            */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> GET_LITERAL                                         */
 /*         ==> SORTER                                                      */
 /*         ==> CSE_TAB_DUMP                                                */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*             ==> CATALOG_PTR                                             */
 /*             ==> VALIDITY                                                */
 /*             ==> CSE_WORD_FORMAT                                         */
 /*                 ==> HEX                                                 */
 /*         ==> REVERSE_PARITY                                              */
 /*         ==> SET_NONCOMMUTATIVE                                          */
 /*             ==> HEX                                                     */
 /*         ==> TYPE                                                        */
 /*         ==> SET_ARRAYNESS                                               */
 /*             ==> LAST_OPERAND                                            */
 /*             ==> TYPE                                                    */
 /*             ==> ARRAYED_ELT                                             */
 /*                 ==> CSE_WORD_FORMAT                                     */
 /*                     ==> HEX                                             */
 /*                 ==> TYPE                                                */
 /*         ==> CATALOG_SRCH                                                */
 /*         ==> CATALOG_VAC                                                 */
 /*             ==> GET_FREE_SPACE                                          */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*             ==> CATALOG_ENTRY                                           */
 /*                 ==> GET_EON                                             */
 /*                 ==> GET_FREE_SPACE                                      */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*         ==> SET_O_T_V                                                   */
 /*             ==> CSE_WORD_FORMAT                                         */
 /*                 ==> HEX                                                 */
 /*     ==> CHECK_INVAR                                                     */
 /*         ==> GET_EON                                                     */
 /*         ==> ARRAYED_ELT                                                 */
 /*             ==> CSE_WORD_FORMAT                                         */
 /*                 ==> HEX                                                 */
 /*             ==> TYPE                                                    */
 /*         ==> INVAR                                                       */
 /*             ==> CSE_WORD_FORMAT                                         */
 /*                 ==> HEX                                                 */
 /*             ==> TYPE                                                    */
 /*             ==> ARRAYED_ELT                                             */
 /*                 ==> CSE_WORD_FORMAT                                     */
 /*                     ==> HEX                                             */
 /*                 ==> TYPE                                                */
 /*             ==> ZAP_BIT                                                 */
 /*     ==> EJECT_INVARS                                                    */
 /*         ==> PRINT_SENTENCE                                              */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> LAST_OPERAND                                                */
 /*         ==> MOVE_LIMB                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> RELOCATE                                                */
 /*             ==> MOVECODE                                                */
 /*                 ==> ENTER                                               */
 /*         ==> PUSH_HALMAT                                                 */
 /*             ==> HEX                                                     */
 /*             ==> OPOP                                                    */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> BUMP_D_N                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> ENTER                                                   */
 /*             ==> LAST_OP                                                 */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> MOVE_LIMB                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> RELOCATE                                            */
 /*                 ==> MOVECODE                                            */
 /*                     ==> ENTER                                           */
 /*         ==> GROUP_CSE                                                   */
 /*             ==> LAST_OP                                                 */
 /*             ==> LAST_OPERAND                                            */
 /*             ==> MOVE_LIMB                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> RELOCATE                                            */
 /*                 ==> MOVECODE                                            */
 /*                     ==> ENTER                                           */
 /*             ==> BUMP_ADD                                                */
 /*             ==> TERMINAL                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> CLASSIFY                                            */
 /*                     ==> PRINT_SENTENCE                                  */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*         ==> GET_ADLP                                                    */
 /*             ==> OPOP                                                    */
 /*             ==> LAST_OP                                                 */
 /***************************************************************************/
                                                                                04138080
                                                                                04138090
 /* EXTRACTS_INVARIANT COMPUTATIONS AND FIXES NODE LIST.  */                    04138100
PULL_INVARS:                                                                    04138110
   PROCEDURE(AR_INV);                                                           04138120
      DECLARE (AR_INV,NOT_TSUB) BIT(8);                                         04138130
      DECLARE TEMP BIT(16);                                                     04138140
      IF I_TRACE THEN OUTPUT =                                                  04138150
         'PULL_INVARS(' || AR_INV || '):  NODE_BEGINNING = ' || NODE_BEGINNING; 04138160
      PULL_LOOP_HEAD(0) = 0;                                                    04138170
      NOT_TSUB = (NODE(NODE_BEGINNING) & "FFFF") ^= TSUB;                       04138175
      DO FOR LEV = 1 - AR_INV TO LEVEL;                                         04138180
         IF PULL_LOOP_HEAD(LEV) >= 0                                            04138190
            & PULL_LOOP_HEAD(LEV) ^= PULL_LOOP_HEAD(0) & SHR(STACK_TAGS(LEV),2) 04138200
            OR AR_INV THEN DO;                                                  04138210
                                                                                04138220
 /* NEXT NESTED LOOP*/                                                          04138230
            IF AR_INV THEN PULL_LOOP_HEAD(0) = GET_ADLP(NODE_BEGINNING,1);      04138240
            ELSE PULL_LOOP_HEAD(0) = PULL_LOOP_HEAD(LEV);                       04138250
            LOOP_ZAPS_LEVEL = ZAP_BASE(LEV);                                    04138260
                                                                                04138273
            IF PULL_LOOP_HEAD(0) >= 0 THEN                                      04138276
               IF CHECK_INVAR(AR_INV) THEN DO;                                  04138280
               INVARIANT_PULLED = TRUE;                                         04138290
               CALL SETUP_REARRANGE(1);                                         04138300
               CALL REARRANGE_HALMAT(1);                                        04138310
               CALL STRIP_NODES(1);                                             04138320
               TEMP = EJECT_INVARS(AR_INV,NOT_TSUB);                            04138330
               IF ^AR_INV AND STATEMENT_ARRAYNESS AND NOT_TSUB AND              04138340
                  (^NONCOMMUTATIVE OR (^ARRAYED_OPS AND NONCOMMUTATIVE)) THEN   04138350
                  CALL BUMP_AR_INV(TEMP);                                       04138360
               IF STATISTICS THEN DO;                                           04138370
                  INVAR# = INVAR# + 1;                                          04138380
                  OUTPUT='LOOP INVARIANT COMPUTATION FOUND IN HAL/S STATEMENT  '04138390
                     || STT#;                                                   04138400
               END;                                                             04138410
               IF TOTAL_MATCH_PRES THEN GO TO EXITT;                            04138420
            END;  /* IF INVAR_FOUND*/                                           04138430
         END;  /* NEXT LOOP*/                                                   04138440
         IF AR_INV THEN GO TO  EXITT;                                           04138450
      END;  /* DO FOR*/                                                         04138460
EXITT:                                                                          04138470
      INVARIANT_COMPUTATION = FALSE;                                            04138480
      LOOP_ZAPS_LEVEL = ZAP_BASE(LEVEL);                                        04138490
      LEV = LEVEL;                                                              04138500
      AR_INV = 0;                                                               04138510
   END PULL_INVARS;                                                             04138520
