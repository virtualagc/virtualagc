 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EXTRACTI.xpl
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
 /* PROCEDURE NAME:  EXTRACT_INVARS                                         */
 /* MEMBER NAME:     EXTRACTI                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          NODE_SAVE         BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          AR_TAG                                                         */
 /*          CROSS_STATEMENTS                                               */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          INVARIANT_COMPUTATION                                          */
 /*          NODE                                                           */
 /*          NONCOMMUTATIVE                                                 */
 /*          STATEMENT_ARRAYNESS                                            */
 /*          TOTAL_MATCH_PRES                                               */
 /*          TRACE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          AR_INX                                                         */
 /*          AR_LIST                                                        */
 /*          INVARIANT_PULLED                                               */
 /*          NODE_BEGINNING                                                 */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          PULL_INVARS                                                    */
 /* CALLED BY:                                                              */
 /*          GET_NODE                                                       */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> EXTRACT_INVARS <==                                                  */
 /*     ==> PULL_INVARS                                                     */
 /*         ==> BUMP_AR_INV                                                 */
 /*         ==> GET_ADLP                                                    */
 /*             ==> OPOP                                                    */
 /*             ==> LAST_OP                                                 */
 /*         ==> REARRANGE_HALMAT                                            */
 /*             ==> GET_LIT_ONE                                             */
 /*                 ==> SAVE_LITERAL                                        */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> GET_LITERAL                                     */
 /*             ==> LAST_OP                                                 */
 /*             ==> TWIN_HALMATTED                                          */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> MOVE_LIMB                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> RELOCATE                                            */
 /*                 ==> MOVECODE                                            */
 /*                     ==> ENTER                                           */
 /*             ==> SWITCH                                                  */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> ENTER                                               */
 /*                 ==> LAST_OP                                             */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> MOVE_LIMB                                           */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> RELOCATE                                        */
 /*                     ==> MOVECODE                                        */
 /*                         ==> ENTER                                       */
 /*                 ==> NEXT_FLAG                                           */
 /*                     ==> NO_OPERANDS                                     */
 /*             ==> PTR_TO_VAC                                              */
 /*             ==> REFERENCE                                               */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> TERMINAL                                            */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> CLASSIFY                                        */
 /*                         ==> PRINT_SENTENCE                              */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*             ==> SET_HALMAT_FLAG                                         */
 /*             ==> SET_VAC_REF                                             */
 /*                 ==> OPOP                                                */
 /*                 ==> ENTER                                               */
 /*             ==> PUT_NOP                                                 */
 /*                 ==> NO_OPERANDS                                         */
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
 /*             ==> COLLECT_MATCHES                                         */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*                 ==> SET_HALMAT_FLAG                                     */
 /*                 ==> FLAG_MATCHES                                        */
 /*                     ==> PRINT_SENTENCE                                  */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*                     ==> TYPE                                            */
 /*                     ==> FLAG_VAC_OR_LIT                                 */
 /*                         ==> VAC_OR_XPT                                  */
 /*                         ==> COMPARE_LITERALS                            */
 /*                             ==> HEX                                     */
 /*                             ==> GET_LITERAL                             */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> HALMAT_FLAG                                 */
 /*                             ==> VAC_OR_XPT                              */
 /*                         ==> SET_FLAG                                    */
 /*                     ==> FLAG_V_N                                        */
 /*                         ==> CATALOG_PTR                                 */
 /*                         ==> VALIDITY                                    */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> SET_FLAG                                    */
 /*                 ==> FLAG_NODE                                           */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
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
 /*                     ==> SET_FLAG                                        */
 /*                 ==> SET_WORDS                                           */
 /*                     ==> NEXT_FLAG                                       */
 /*                         ==> NO_OPERANDS                                 */
 /*                     ==> FORM_OPERATOR                                   */
 /*                         ==> HEX                                         */
 /*                     ==> SET_VAC_REF                                     */
 /*                         ==> OPOP                                        */
 /*                         ==> ENTER                                       */
 /*                     ==> FORCE_TERMINAL                                  */
 /*                         ==> NEXT_FLAG                                   */
 /*                             ==> NO_OPERANDS                             */
 /*                         ==> SWITCH                                      */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> ENTER                                   */
 /*                             ==> LAST_OP                                 */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> MOVE_LIMB                               */
 /*                                 ==> ERRORS                              */
 /*                                     ==> COMMON_ERRORS                   */
 /*                                 ==> RELOCATE                            */
 /*                                 ==> MOVECODE                            */
 /*                                     ==> ENTER                           */
 /*                             ==> NEXT_FLAG                               */
 /*                                 ==> NO_OPERANDS                         */
 /*                         ==> TERMINAL                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> CLASSIFY                                */
 /*                                 ==> PRINT_SENTENCE                      */
 /*                                     ==> FORMAT                          */
 /*                                     ==> HEX                             */
 /*                     ==> PUSH_OPERAND                                    */
 /*                         ==> ENTER                                       */
 /*                         ==> HALMAT_FLAG                                 */
 /*                             ==> VAC_OR_XPT                              */
 /*                         ==> NEXT_FLAG                                   */
 /*                             ==> NO_OPERANDS                             */
 /*                         ==> TERMINAL                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> CLASSIFY                                */
 /*                                 ==> PRINT_SENTENCE                      */
 /*                                     ==> FORMAT                          */
 /*                                     ==> HEX                             */
 /*                     ==> FORCE_MATCH                                     */
 /*                         ==> NEXT_FLAG                                   */
 /*                             ==> NO_OPERANDS                             */
 /*                         ==> SWITCH                                      */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> ENTER                                   */
 /*                             ==> LAST_OP                                 */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> MOVE_LIMB                               */
 /*                                 ==> ERRORS                              */
 /*                                     ==> COMMON_ERRORS                   */
 /*                                 ==> RELOCATE                            */
 /*                                 ==> MOVECODE                            */
 /*                                     ==> ENTER                           */
 /*                             ==> NEXT_FLAG                               */
 /*                                 ==> NO_OPERANDS                         */
 /*             ==> BOTTOM                                                  */
 /*                 ==> LAST_OP                                             */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*             ==> PUT_BFNC_TWIN                                           */
 /*         ==> SETUP_REARRANGE                                             */
 /*             ==> LAST_OP                                                 */
 /*             ==> CLASSIFY                                                */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*             ==> LOOPY                                                   */
 /*                 ==> GET_CLASS                                           */
 /*                 ==> XHALMAT_QUAL                                        */
 /*                 ==> ASSIGN_TYPE                                         */
 /*                 ==> NO_OPERANDS                                         */
 /*         ==> STRIP_NODES                                                 */
 /*             ==> COMPARE_LITERALS                                        */
 /*                 ==> HEX                                                 */
 /*                 ==> GET_LITERAL                                         */
 /*             ==> GET_LIT_ONE                                             */
 /*                 ==> SAVE_LITERAL                                        */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> GET_LITERAL                                     */
 /*             ==> SORTER                                                  */
 /*             ==> CSE_TAB_DUMP                                            */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*                 ==> CATALOG_PTR                                         */
 /*                 ==> VALIDITY                                            */
 /*                 ==> CSE_WORD_FORMAT                                     */
 /*                     ==> HEX                                             */
 /*             ==> REVERSE_PARITY                                          */
 /*             ==> SET_NONCOMMUTATIVE                                      */
 /*                 ==> HEX                                                 */
 /*             ==> TYPE                                                    */
 /*             ==> SET_ARRAYNESS                                           */
 /*                 ==> LAST_OPERAND                                        */
 /*                 ==> TYPE                                                */
 /*                 ==> ARRAYED_ELT                                         */
 /*                     ==> CSE_WORD_FORMAT                                 */
 /*                         ==> HEX                                         */
 /*                     ==> TYPE                                            */
 /*             ==> CATALOG_SRCH                                            */
 /*             ==> CATALOG_VAC                                             */
 /*                 ==> GET_FREE_SPACE                                      */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                 ==> CATALOG_ENTRY                                       */
 /*                     ==> GET_EON                                         */
 /*                     ==> GET_FREE_SPACE                                  */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*             ==> SET_O_T_V                                               */
 /*                 ==> CSE_WORD_FORMAT                                     */
 /*                     ==> HEX                                             */
 /*         ==> CHECK_INVAR                                                 */
 /*             ==> GET_EON                                                 */
 /*             ==> ARRAYED_ELT                                             */
 /*                 ==> CSE_WORD_FORMAT                                     */
 /*                     ==> HEX                                             */
 /*                 ==> TYPE                                                */
 /*             ==> INVAR                                                   */
 /*                 ==> CSE_WORD_FORMAT                                     */
 /*                     ==> HEX                                             */
 /*                 ==> TYPE                                                */
 /*                 ==> ARRAYED_ELT                                         */
 /*                     ==> CSE_WORD_FORMAT                                 */
 /*                         ==> HEX                                         */
 /*                     ==> TYPE                                            */
 /*                 ==> ZAP_BIT                                             */
 /*         ==> EJECT_INVARS                                                */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> LAST_OPERAND                                            */
 /*             ==> MOVE_LIMB                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> RELOCATE                                            */
 /*                 ==> MOVECODE                                            */
 /*                     ==> ENTER                                           */
 /*             ==> PUSH_HALMAT                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> OPOP                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> BUMP_D_N                                            */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> ENTER                                               */
 /*                 ==> LAST_OP                                             */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> MOVE_LIMB                                           */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> RELOCATE                                        */
 /*                     ==> MOVECODE                                        */
 /*                         ==> ENTER                                       */
 /*             ==> GROUP_CSE                                               */
 /*                 ==> LAST_OP                                             */
 /*                 ==> LAST_OPERAND                                        */
 /*                 ==> MOVE_LIMB                                           */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> RELOCATE                                        */
 /*                     ==> MOVECODE                                        */
 /*                         ==> ENTER                                       */
 /*                 ==> BUMP_ADD                                            */
 /*                 ==> TERMINAL                                            */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> CLASSIFY                                        */
 /*                         ==> PRINT_SENTENCE                              */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*             ==> GET_ADLP                                                */
 /*                 ==> OPOP                                                */
 /*                 ==> LAST_OP                                             */
 /***************************************************************************/
                                                                                04138530
                                                                                04138540
 /* PULLS INVARS FROM DO LOOPS, THEN FROM ARRAYS*/                              04138550
EXTRACT_INVARS:                                                                 04138560
   PROCEDURE;                                                                   04138570
      DECLARE NODE_SAVE BIT(16);                                                04138580
      INVARIANT_PULLED = FALSE;                                                 04138590
      AR_LIST(1) = NODE_BEGINNING;                                              04138600
      AR_INX = 1;                                                               04138610
      IF INVARIANT_COMPUTATION AND CROSS_STATEMENTS THEN CALL PULL_INVARS;      04138620
 /* GET LOOP INVARS*/                                                           04138630
      NODE_SAVE = NODE_BEGINNING;                                               04138640
                                                                                04138650
      DO FOR AR_INX = 1 TO AR_INX;   /* GET ADLP INVARS*/                       04138660
         NODE_BEGINNING = AR_LIST(AR_INX);                                      04138670
         IF (NODE(NODE_BEGINNING) & AR_TAG) ^= 0 THEN DO;                       04138680
            IF ^NONCOMMUTATIVE THEN CALL PULL_INVARS(1);                        04138690
         END;                                                                   04138700
         ELSE DO;                                                               04138710
            IF AR_INX > 1 THEN CALL PULL_INVARS(1);                             04138720
            ELSE IF STATEMENT_ARRAYNESS AND                                     04138730
               ^(INVARIANT_PULLED AND TOTAL_MATCH_PRES) THEN                    04138740
               CALL PULL_INVARS(1);                                             04138750
         END;                                                                   04138760
         IF TRACE THEN OUTPUT = '   AR_INX=' ||AR_INX||                         04138770
            ', INVARIANT_PULLED=' || INVARIANT_PULLED ||                        04138780
            ', STATEMENT_ARRAYNESS=' || STATEMENT_ARRAYNESS;                    04138790
      END;                                                                      04138800
      NODE_BEGINNING = NODE_SAVE;                                               04138810
   END EXTRACT_INVARS;                                                          04138820
