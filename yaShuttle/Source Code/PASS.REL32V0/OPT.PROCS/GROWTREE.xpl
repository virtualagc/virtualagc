 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GROWTREE.xpl
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
 /* PROCEDURE NAME:  GROW_TREE                                              */
 /* MEMBER NAME:     GROWTREE                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          BUILD_NODE_LIST   LABEL                                        */
 /*          NODE_TYPE(15)     BIT(8)                                       */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ALPHA_BETA_QUAL_MASK                                           */
 /*          BFNC_OK                                                        */
 /*          BLOCK#                                                         */
 /*          CONTROL_MASK                                                   */
 /*          CSE                                                            */
 /*          CSE2                                                           */
 /*          DSUB                                                           */
 /*          DUMMY_NODE                                                     */
 /*          END_OF_LIST                                                    */
 /*          END_OF_NODE                                                    */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          IMD                                                            */
 /*          LAST_SMRK                                                      */
 /*          LEVEL                                                          */
 /*          LITERAL                                                        */
 /*          LIT                                                            */
 /*          LIT_PG                                                         */
 /*          LITERAL1                                                       */
 /*          LIT1                                                           */
 /*          MAX_NODE_SIZE                                                  */
 /*          OR                                                             */
 /*          PARITY                                                         */
 /*          PRTYEXP                                                        */
 /*          PUSH_TEST                                                      */
 /*          SAV_VAC_BITS                                                   */
 /*          SAV_XPT_BITS                                                   */
 /*          SMRK_CTR                                                       */
 /*          SSPR                                                           */
 /*          TRACE                                                          */
 /*          TRANSPARENT                                                    */
 /*          TRUE                                                           */
 /*          TSUB                                                           */
 /*          WATCH                                                          */
 /*          XVAC                                                           */
 /*          XXPT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          A_INX                                                          */
 /*          A_PARITY                                                       */
 /*          ADD                                                            */
 /*          CSE_FOUND_INX                                                  */
 /*          CTR                                                            */
 /*          D_N_INX                                                        */
 /*          DIFF_NODE                                                      */
 /*          DIFF_PTR                                                       */
 /*          EON_PTR                                                        */
 /*          FNPARITY0#                                                     */
 /*          FNPARITY1#                                                     */
 /*          GET_INX                                                        */
 /*          LAST_END_OF_LIST                                               */
 /*          MPARITY0#                                                      */
 /*          MPARITY1#                                                      */
 /*          N_INX                                                          */
 /*          NODE                                                           */
 /*          NODE2                                                          */
 /*          NONCOMMUTATIVE                                                 */
 /*          OP                                                             */
 /*          OPR                                                            */
 /*          OPTYPE                                                         */
 /*          STILL_NODES                                                    */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ASSIGN_TYPE                                                    */
 /*          BUMP_CSE                                                       */
 /*          BUMP_D_N                                                       */
 /*          CLASSIFY                                                       */
 /*          COLLAPSE_LITERALS                                              */
 /*          CONVERSION_TYPE                                                */
 /*          CSE_TAB_DUMP                                                   */
 /*          ELIMINATE_DIVIDES                                              */
 /*          FORM_TERM                                                      */
 /*          FORM_VAC                                                       */
 /*          GET_LITERAL                                                    */
 /*          LAST_OPERAND                                                   */
 /*          NO_OPERANDS                                                    */
 /*          OPOP                                                           */
 /*          PTR_TO_VAC                                                     */
 /*          PUT_SHAPING_ARGS                                               */
 /*          SET_NONCOMMUTATIVE                                             */
 /*          SHAPING_FN                                                     */
 /*          TERMINAL                                                       */
 /*          VAC_OR_XPT                                                     */
 /*          XHALMAT_QUAL                                                   */
 /*          ZAP_TABLES                                                     */
 /* CALLED BY:                                                              */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GROW_TREE <==                                                       */
 /*     ==> OPOP                                                            */
 /*     ==> SHAPING_FN                                                      */
 /*         ==> OPOP                                                        */
 /*     ==> VAC_OR_XPT                                                      */
 /*     ==> BUMP_D_N                                                        */
 /*     ==> GET_LITERAL                                                     */
 /*     ==> XHALMAT_QUAL                                                    */
 /*     ==> ASSIGN_TYPE                                                     */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> LAST_OPERAND                                                    */
 /*     ==> CSE_TAB_DUMP                                                    */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*         ==> CATALOG_PTR                                                 */
 /*         ==> VALIDITY                                                    */
 /*         ==> CSE_WORD_FORMAT                                             */
 /*             ==> HEX                                                     */
 /*     ==> CONVERSION_TYPE                                                 */
 /*     ==> FORM_VAC                                                        */
 /*     ==> PTR_TO_VAC                                                      */
 /*     ==> FORM_TERM                                                       */
 /*         ==> NAME_OR_PARM                                                */
 /*     ==> BUMP_CSE                                                        */
 /*     ==> SET_NONCOMMUTATIVE                                              */
 /*         ==> HEX                                                         */
 /*     ==> CLASSIFY                                                        */
 /*         ==> PRINT_SENTENCE                                              */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*     ==> TERMINAL                                                        */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
 /*         ==> CLASSIFY                                                    */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*     ==> ZAP_TABLES                                                      */
 /*         ==> STACK_DUMP                                                  */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*         ==> CSE_TAB_DUMP                                                */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*             ==> CATALOG_PTR                                             */
 /*             ==> VALIDITY                                                */
 /*             ==> CSE_WORD_FORMAT                                         */
 /*                 ==> HEX                                                 */
 /*         ==> FINAL_PASS                                                  */
 /*             ==> GET_CLASS                                               */
 /*             ==> OPOP                                                    */
 /*             ==> BUMP_D_N                                                */
 /*             ==> S                                                       */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> NAME_OR_PARM                                            */
 /*             ==> ASSIGN_TYPE                                             */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> LAST_OPERAND                                            */
 /*             ==> LOOP_OPERANDS                                           */
 /*                 ==> GET_CLASS                                           */
 /*                 ==> LAST_OPERAND                                        */
 /*             ==> EXTN_CHECK                                              */
 /*                 ==> XHALMAT_QUAL                                        */
 /*                 ==> NAME_OR_PARM                                        */
 /*             ==> BUMP_ADD                                                */
 /*             ==> LOOPY                                                   */
 /*                 ==> GET_CLASS                                           */
 /*                 ==> XHALMAT_QUAL                                        */
 /*                 ==> ASSIGN_TYPE                                         */
 /*                 ==> NO_OPERANDS                                         */
 /*             ==> VM_DETAG                                                */
 /*                 ==> OPOP                                                */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> TERMINAL                                            */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> CLASSIFY                                        */
 /*                         ==> PRINT_SENTENCE                              */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*                 ==> LOOPY                                               */
 /*                     ==> GET_CLASS                                       */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> ASSIGN_TYPE                                     */
 /*                     ==> NO_OPERANDS                                     */
 /*             ==> INIT_ARCONFS                                            */
 /*             ==> C_STACK_DUMP                                            */
 /*                 ==> FORMAT                                              */
 /*             ==> CHECK_ADJACENT_LOOPS                                    */
 /*                 ==> OPOP                                                */
 /*                 ==> LAST_OP                                             */
 /*                 ==> LAST_OPERAND                                        */
 /*             ==> PUSH_LOOP_STACKS                                        */
 /*                 ==> INIT_ARCONFS                                        */
 /*                 ==> CHECK_ADJACENT_LOOPS                                */
 /*                     ==> OPOP                                            */
 /*                     ==> LAST_OP                                         */
 /*                     ==> LAST_OPERAND                                    */
 /*                 ==> MOVE_LOOP_STACK                                     */
 /*                 ==> BUMP_LOOPSTACK                                      */
 /*             ==> POP_LOOP_STACKS                                         */
 /*                 ==> MOVE_LOOP_STACK                                     */
 /*             ==> COMBINE_LOOPS                                           */
 /*                 ==> VU                                                  */
 /*                     ==> HEX                                             */
 /*             ==> DENEST                                                  */
 /*                 ==> VU                                                  */
 /*                     ==> HEX                                             */
 /*                 ==> POP_LOOP_STACKS                                     */
 /*                     ==> MOVE_LOOP_STACK                                 */
 /*                 ==> MULTIPLY_DIMS                                       */
 /*                     ==> VU                                              */
 /*                         ==> HEX                                         */
 /*             ==> CHECK_ARRAYNESS                                         */
 /*                 ==> SET_VAR                                             */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> LAST_OPERAND                                    */
 /*                 ==> LOOPY                                               */
 /*                     ==> GET_CLASS                                       */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> ASSIGN_TYPE                                     */
 /*                     ==> NO_OPERANDS                                     */
 /*                 ==> BUMP_REF_OPS                                        */
 /*                     ==> POP_COMPARE                                     */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> NO_OPERANDS                                 */
 /*             ==> SET_LOOP_END                                            */
 /*             ==> PUSH_VM_STACK                                           */
 /*                 ==> MOVE_LOOP_STACK                                     */
 /*             ==> CHECK_VM_COMBINE                                        */
 /*                 ==> VM_DETAG                                            */
 /*                     ==> OPOP                                            */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> TERMINAL                                        */
 /*                         ==> VAC_OR_XPT                                  */
 /*                         ==> HALMAT_FLAG                                 */
 /*                             ==> VAC_OR_XPT                              */
 /*                         ==> CLASSIFY                                    */
 /*                             ==> PRINT_SENTENCE                          */
 /*                                 ==> FORMAT                              */
 /*                                 ==> HEX                                 */
 /*                     ==> LOOPY                                           */
 /*                         ==> GET_CLASS                                   */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> ASSIGN_TYPE                                 */
 /*                         ==> NO_OPERANDS                                 */
 /*                 ==> POP_LOOP_STACKS                                     */
 /*                     ==> MOVE_LOOP_STACK                                 */
 /*                 ==> COMBINE_LOOPS                                       */
 /*                     ==> VU                                              */
 /*                         ==> HEX                                         */
 /*             ==> CHECK_LIST                                              */
 /*                 ==> FORMAT                                              */
 /*                 ==> OPOP                                                */
 /*                 ==> SET_V_M_TAGS                                        */
 /*                     ==> LAST_OPERAND                                    */
 /*             ==> EMPTY_ARRAY                                             */
 /*                 ==> OPOP                                                */
 /*                 ==> LAST_OPERAND                                        */
 /*         ==> RELOCATE_HALMAT                                             */
 /*             ==> HEX                                                     */
 /*             ==> OPOP                                                    */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> LAST_OP                                                 */
 /*             ==> TWIN_HALMATTED                                          */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> DETAG                                                   */
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
 /*     ==> ELIMINATE_DIVIDES                                               */
 /*         ==> PRINT_SENTENCE                                              */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
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
 /*     ==> COLLAPSE_LITERALS                                               */
 /*         ==> COMBINED_LITERALS                                           */
 /*             ==> HEX                                                     */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> MESSAGE_FORMAT                                          */
 /*                 ==> HEX                                                 */
 /*             ==> GET_LITERAL                                             */
 /*             ==> FILL_DW                                                 */
 /*                 ==> GET_LITERAL                                         */
 /*             ==> SAVE_LITERAL                                            */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> GET_LITERAL                                         */
 /*             ==> LIT_ARITHMETIC                                          */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*         ==> PRINT_SENTENCE                                              */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*         ==> CSE_WORD_FORMAT                                             */
 /*             ==> HEX                                                     */
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
 /*     ==> PUT_SHAPING_ARGS                                                */
 /*         ==> OPOP                                                        */
 /*         ==> XNEST                                                       */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> BUMP_D_N                                                    */
 /*         ==> LAST_OP                                                     */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /* 03/01/00 DCP  30V0/ DR111352 ALGEBRAIC BUILT-IN FUNCTION FAILS          */
 /*               15V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                03339180
                                                                                03466000
 /****************************************************************/             03467000
                                                                                03468000
 /*SETS UP NODE LIST TO SEARCH FOR CSE'S.*/                                     03469000
                                                                                03470000
 /*THREE STACKS USED:                                                           03471000
          NODE      --THE STACK OF TERMINAL OPERANDS IN CSE FORMAT              03472000
                      INDEXED BY N_INX.                                         03473000
          NODE2     --WIPEOUT# FOR NODE, INDEXED BY N_INX                       03474000
                      FOR OUTER_TERMINAL_VAC, PTR TO CSE_TAB                    03475000
                      FOR OPERATOR, TERMINAL VAC REFERENCING IT                 03476000
                      FOR END_OF_NODE, PTR TO OPERATOR                          03477000
                      FOR VAC_PTR, PTR TO CSE_TAB                               03478000
          ADD       --THE STACK OF VACS WHOSE OPERANDS ARE OF THE               03479000
                      SAME OPERATOR CLASSIFICATION AS THE NODE                  03480000
                      CURRENTLY BEING PROCESSED                                 03481000
                      INDEXED BY A_INX                                          03482000
          A_PARITY  --1 IF VAC IS SUBTRACTED OR DIVIDED.  0 OTHERWISE           03483000
                      INDEXED BY A_INX                                          03484000
          DIFF_NODE --THE STACK OF NODES OF DIFFERENT CLASSIFICATION            03485000
                      INDEXED BY D_N_INX                                        03486000
          DIFF_PTR  --USED TO GET TERMINAL VAC PTR'S POINTING TO "VAC_PTR" WORD 03487000
                      OF APPROPRIATE NODE.  INDEXED BY D_N_INX.                 03488000
                                                                                03489000
                                                                                03490000
   STRUCTURE OF NODE LIST:                                                      03491000
                                                                                03492000
            NODE                                NODE2                           03493000
            ----                                -----                           03494000
                                                                                03495000
         END_OF_LIST                    LEVEL(5 BITS), BLOCK#(11 BITS)          03496000
                                                                                03497000
      I  VAC_PTR                        0 OR CSE_TAB PTR                        03498000
      I  END_OF_NODE                    PTR TO OPTYPE                           03499000
      I                                                                         03500000
      I  OPERANDS:                                                              03501000
      I     VALUE_NO                    POINTER TO SYMBOL TABLE FOR VAR         03502000
      I        (PTR TO CSE_TAB)                                                 03503000
NODE: I     OUTER_TERMINAL_VAC          CSE_TAB_PTR                             03504000
      I        (PTR TO "VAC_PTR" OF NODE)                                       03505000
      I     LITERAL                     PTR TO LIT TABLE                        03506000
      I     TERMINAL_VAC                PTR TO END OF NODE                      03507000
      I        (PTR TO "VAC_PTR" OF NODE)                                       03508000
      I                                                                         03509000
      I  TAGS,OPTYPE                    0 OR PTR TO "END_OF_NODE" OF NODE       03510000
      I                                    CONTAINING TERMINAL_VAC REFERENCING  03511000
      I                                    NODE. IF TOPTAG THEN UNRELIABLE.     03512000
                                                                                03513000
                                        TAGS(16 BITS) =                         03514000
                                            "8000" FOR TWIN_OP(EG. SIN) NODE    03515000
                                            IN CSE                              03516000
                                            "4000" IF CONTAINS DUMMY OPERAND    03516010
                                            "2000" IF ARRAYED                   03516020
      I                                                                         03517000
NODE: I                                                                         03518000
      I                                                                         03519000
                                                                                03520000
         END_OF_LIST                    LEVEL(5 BITS), BLOCK#(11 BITS)          03521000
                                                                                03522000
MORE NODES:                                                                     03523000
                                                                                03524000
*******************************************************************************/03525000
                                                                                03526000
GROW_TREE:                                                                      03527000
   PROCEDURE;                                                                   03528000
      DECLARE TEMP BIT(16);                                                     03529000
      DECLARE I BIT(16);                                                        03530000
      DECLARE NODE_TYPE(15) BIT(8) INITIAL(0,                                   03532000
         0, /* 1 = SYT*/                                                        03533000
         0,                                                                     03534000
         2, /* 3 = VAC*/                                                        03535000
         2, /* 4 = XPT*/                                                        03536000
         1, /* 5 = LIT*/                                                        03537000
         0);/* 6 = IMD*/                                                        03537010
 /* 0 = OTHERS*/                                                                03538000
                                                                                03539000
                                                                                03540000
BUILD_NODE_LIST:                                                                03541000
      PROCEDURE;                                                                03542000
         DECLARE (REF_PTR,PTR,PRTYEXPN,DIVIDE#) BIT(16);                        03543000
         DECLARE INX BIT(16);                                                   03543010
         DECLARE ASSIGN_FLAG BIT(8);                                            03543020
         DECLARE TYPE BIT(8);                                                   03544000
         DECLARE CONTROL_TEMP FIXED;                                            03545000
         DECLARE OPR_TEMP FIXED;                                                03546000
         DECLARE XQUAL BIT(16);                                                 03546010
                                                                                03547000
 /* REPLACE VAC REFERENCE TO HARMLESS LIT CONVERSION BY LIT PTR*/               03548000
LIT_CONVERSION:                                                                 03549000
         PROCEDURE(LC_PTR) BIT(8);                                              03550000
            DECLARE LC_PTR BIT(16);                                             03551000
            PTR = SHR(OPR(LC_PTR),16);                                          03552000
            IF CONVERSION_TYPE(PTR) & (SHR(OPR(PTR + 1),4) & "F") = LIT THEN DO;03553000
               OPR(LC_PTR) = OPR(LC_PTR) & "FF00";       /*DR111352*/
               OPR(LC_PTR) = OPR(PTR + 1) | OPR(LC_PTR); /*DR111352*/           03554000
               OPR(PTR) = OPR(PTR) & "FF 0000";                                 03555000
               OPR(PTR + 1) = 0;                                                03556000
               IF WATCH THEN OUTPUT = 'NOP LIT CONVERSION:  '                   03557000
                  || PTR || ',' || PTR + 1;                                     03558000
               RETURN TRUE;                                                     03559000
            END;                                                                03560000
            RETURN FALSE;                                                       03561000
         END LIT_CONVERSION;                                                    03562000
                                                                                03562010
 /* CHECKS IF TSUB PRESENT AND, IF SO, PUTS EXTN ON NODE LIST */                03562020
CHECK_TSUB:                                                                     03562030
         PROCEDURE(PTR);                                                        03562040
            DECLARE PTR BIT(16);                                                03562050
            PTR = SHR(OPR(PTR),16);   /* EXTN */                                03562060
            IF XHALMAT_QUAL(PTR + 1) = XVAC THEN    /* TSUB PRESENT*/           03562070
               CALL BUMP_D_N(SHR(OPR(PTR+1), 16));                              03562080
         END CHECK_TSUB;                                                        03562090
                                                                                03563000
                                                                                03564000
                                                                                03565000
         DIFF_NODE(1) = CTR;                                                    03566000
         DIFF_PTR(1) = 0;                                                       03567000
         D_N_INX = 1;                                                           03568000
         NODE,NODE2 = 0;                                                        03569000
         DO WHILE D_N_INX ^= 0;                                                 03570000
                                                                                03570010
            IF DIFF_NODE(D_N_INX) = 0 THEN D_N_INX = D_N_INX - 1;               03570020
            ELSE DO;                                                            03570030
                                                                                03570040
              OP,OPTYPE = CLASSIFY(DIFF_NODE(D_N_INX),0,1); /* CHANGE M**T V  */03571000
               NONCOMMUTATIVE = SET_NONCOMMUTATIVE(OP);                         03572000
                                                                                03573000
 /*TRANSPARENT*/                                                                03574000
               IF TRANSPARENT THEN DO;     /* CONDITIONALS*/                    03575000
                  TEMP = DIFF_NODE(D_N_INX);                                    03576000
                 NODE(DIFF_PTR(D_N_INX)) = NODE(DIFF_PTR(D_N_INX)) | DUMMY_NODE;03577000
                  D_N_INX = D_N_INX - 1;                                        03578000
                                                                                03578010
                  ASSIGN_FLAG = ASSIGN_TYPE(TEMP);                              03578020
                  IF ASSIGN_FLAG THEN DO;                                       03578030
                     DO FOR I = TEMP + 2 TO LAST_OPERAND(TEMP);                 03578040
                                                                                03578050
                        XQUAL = XHALMAT_QUAL(I);                                03578060
                        IF XQUAL = XVAC THEN DO;                                03578062
                           INX = SHR(OPR(I),16);                                03578070
                           IF OPOP(INX) = DSUB THEN DO;                         03578080
                                                                                03578090
 /* CHECK IF SAV.  NO SUBBIT RECEIVERS HANDLED*/                                03578100
                                                                                03578110
                              IF XHALMAT_QUAL(INX + 1) = XXPT THEN              03578112
                                 CALL CHECK_TSUB(INX + 1);                      03578114
 /* PUT TSUB INTO THE HOPPER*/                                                  03578116
                              INX = LAST_OPERAND(INX);                          03578120
                             IF (OPR(INX) & ALPHA_BETA_QUAL_MASK) = SAV_VAC_BITS03578130
                              | (OPR(INX) & ALPHA_BETA_QUAL_MASK) = SAV_XPT_BITS03578135
                                 THEN CALL BUMP_D_N(SHR(OPR(INX),16));          03578140
                           END;                                                 03578150
                        END;                                                    03578160
                        ELSE IF XQUAL = XXPT THEN DO;                           03578163
                           CALL CHECK_TSUB(I);                                  03578166
                        END;                                                    03578169
                     END;     /* DO FOR*/                                       03578170
                                                                                03578180
                  END;                                                          03578190
                  I = TEMP + 1;                                                 03579000
                                                                                03579010
                  IF SHAPING_FN(TEMP) THEN CALL PUT_SHAPING_ARGS(TEMP);         03579020
                                                                                03579030
                  ELSE                                                          03579040
                     DO WHILE I <= TEMP + NO_OPERANDS(TEMP);                    03580000
                     IF VAC_OR_XPT(I) THEN DO;                                  03581000
                        CALL BUMP_D_N(SHR(OPR(I),16));                          03582000
                     END;                                                       03585000
                     IF ASSIGN_FLAG THEN                                        03586000
                        I = TEMP + NO_OPERANDS(TEMP) + 1;                       03587000
                     ELSE I = I + 1;                                            03588000
                  END;                                                          03589000
               END;   /* TRANSPARENT*/                                          03590000
                                                                                03591000
 /*BAD BFNC'S*/                                                                 03592000
               ELSE IF (OPTYPE & "F00") = "F00" & ^ BFNC_OK THEN DO;            03593000
                  NODE(DIFF_PTR(D_N_INX)) = NODE(DIFF_PTR(D_N_INX)) |           03594000
                     DUMMY_NODE;                                                03595000
                  D_N_INX = D_N_INX - 1;  /* OMIT BAD BFNC'S*/                  03596000
               END;                                                             03597000
                                                                                03598000
                                                                                03599000
               ELSE DO;                                                         03600000
                  NODE(N_INX) = PTR_TO_VAC(DIFF_NODE(D_N_INX));                 03601000
                NODE(DIFF_PTR(D_N_INX))=FORM_VAC(N_INX)|NODE(DIFF_PTR(D_N_INX));03602000
 /* FILL IN EARLIER VAC*/                                                       03603000
                                                                                03604000
                  NODE2(N_INX) = 0;                                             03605000
                  NODE(N_INX + 1) = END_OF_NODE;                                03606000
                  EON_PTR = N_INX + 1;                                          03607000
                  N_INX = N_INX + 2;                                            03608000
                  A_INX =1;                                                     03609000
                  ADD(1) = DIFF_NODE(D_N_INX);                                  03610000
                  A_PARITY(1) = 0;                                              03611000
               REF_PTR = DIFF_PTR(D_N_INX);/*PTR TO TERM. VAC REFERENCING NODE*/03612000
                  D_N_INX = D_N_INX -1;                                         03613000
                                                                                03614000
 /*NONCOMMUTATIVE*/                                                             03615000
                  IF NONCOMMUTATIVE  THEN DO;                                   03616000
                     TEMP = ADD(1);                                             03617000
                     DO FOR I = TEMP + 1 TO TEMP + NO_OPERANDS(TEMP);           03618000
                        TYPE = SHR(OPR(I),4) & "F";                             03619000
                        DO CASE NODE_TYPE(TYPE);                                03620000
                           DO;   /* 0 = TERMINAL*/                              03621000
                              NODE(N_INX) = FORM_TERM(I,0,TYPE=IMD);            03622000
                              NODE2(N_INX) = 0;                                 03623000
                           END;                                                 03624000
                                                                                03625000
                           DO;   /* 1 = LIT*/                                   03626000
PUT_LIT:                      NODE(N_INX) = LITERAL;                            03627000
                              NODE2(N_INX) = SHR(OPR(I),16);                    03628000
                           END;                                                 03629000
                                                                                03630000
 /* 2 = VAC*/                                                                   03631000
                           IF LIT_CONVERSION(I) THEN GO TO PUT_LIT;             03632000
                           ELSE DO;                                             03633000
                              CALL BUMP_D_N(SHR(OPR(I),16),N_INX);              03634000
                              NODE(N_INX) = 0;                                  03637000
                              NODE2(N_INX) =EON_PTR;                            03638000
                           END;                                                 03639000
                                                                                03640000
                        END;  /* DO CASE*/                                      03641000
                                                                                03642000
                        IF OP = DSUB OR OP = TSUB THEN DO;                      03643000
                           IF OP = DSUB OR I = TEMP + 1 THEN OPR_TEMP = OPR(I); 03644000
                        ELSE OPR_TEMP = OPR(I) - "700"; /*BRING ALPHA IN RANGE*/03645000
                           CONTROL_TEMP = (SHL(OPR_TEMP & "2",19)               03646000
                              | SHL(OPR_TEMP & "700",13))                       03647000
                              & CONTROL_MASK;                                   03648000
                                                                                03649000
                           IF CONTROL_TEMP = "F 0 0000" THEN                    03650000
                           CONTROL_TEMP = "1 0 0000"; /* SO COMPARE WON'T BLOW*/03651000
                                                                                03652000
                           NODE(N_INX) = NODE(N_INX) | CONTROL_TEMP;            03653000
                                                                                03654000
 /* ALPHA AND BETA ARE NOW IN CONTROL FIELD*/                                   03655000
                                                                                03656000
                        END;                                                    03657000
                                                                                03658000
                        N_INX = N_INX + 1;                                      03659000
                     END;   /* DO FOR*/                                         03660000
                  END;  /*NONCOMMUTATIVE*/                                      03661000
                                                                                03662000
 /*COMMUTATIVE*/                                                                03663000
                  ELSE  DO;                          /* COMMUTATIVE*/           03664000
                     DIVIDE#,FNPARITY1#,MPARITY1#, CSE_FOUND_INX = 0;           03665000
                     DO WHILE A_INX > 0 ;                                       03666000
                        A_PARITY = A_PARITY(A_INX);                             03667000
                        TEMP = ADD(A_INX);                                      03668000
                        A_INX = A_INX - 1;                                      03669000
                        IF OPTYPE^= CLASSIFY(TEMP,1) THEN DO;                   03670000
 /* DIFFERENT NODES GO TO D_N_LIST*/                                            03671000
 /* SETS PARITY*/                                                               03672000
                           CALL BUMP_D_N(TEMP,N_INX);                           03673000
                           FNPARITY1# = FNPARITY1# + A_PARITY;                  03676000
                           NODE(N_INX) = SHL(A_PARITY,20);                      03677000
                           NODE2(N_INX) = EON_PTR;                              03678000
                           N_INX = N_INX + 1;                                   03679000
                        END;                                                    03680000
                        ELSE DO;                                                03681000
                           DO FOR I = 1 TO NO_OPERANDS(TEMP);                   03682000
                              PRTYEXPN = PRTYEXP;                               03683000
                              IF TERMINAL(TEMP + I) THEN DO;                    03684000
                                 FNPARITY1# = FNPARITY1# + PRTYEXPN;            03685000
                                 IF (SHR(OPR(TEMP+I),4)&"F") = LIT THEN DO;     03686000
                                  IF LIT1(GET_LITERAL(SHR(OPR(TEMP+I),16))) ^= 303686200
                                       THEN CALL BUMP_CSE(TEMP+I,PRTYEXPN);     03686400
                                    ELSE DO;                                    03686600
                                       NODE(N_INX) = LITERAL | SHL(PRTYEXPN,20);03686800
                                       NODE2(N_INX) = SHR(OPR(TEMP+I),16);      03687000
                                       N_INX = N_INX + 1;                       03687200
                                    END;                                        03687400
                                 END;                                           03687600
                                 ELSE DO;                                       03688000
                                    NODE(N_INX) = FORM_TERM(TEMP + I,PRTYEXPN); 03689000
                                    NODE2(N_INX) = 0;                           03690000
                                    N_INX = N_INX + 1;                          03691000
                                 END;                                           03692000
                              END;                                              03693000
                              ELSE IF LIT_CONVERSION(TEMP + I) THEN DO ;        03694000
                                 FNPARITY1# = FNPARITY1# + PRTYEXPN;            03695000
                                 CALL BUMP_CSE(TEMP + I,PRTYEXPN);              03696000
                              END;                                              03697000
                              ELSE DO;                                          03698000
                                 A_INX = A_INX + 1;                             03699000
                                 ADD(A_INX) = SHR(OPR(TEMP + I),16);            03700000
 /* NON TERM GOES TO ADD LIST*/                                                 03701000
                                 A_PARITY(A_INX) = PRTYEXPN;                    03702000
                              END;                                              03703000
                           END;                                                 03704000
                           DIVIDE# = DIVIDE# + PARITY;                          03705000
                        END;                                                    03706000
                     END;   /* DO WHILE A_INX*/                                 03707000
                                                                                03708000
                     NODE2(EON_PTR) = N_INX;   /* FOR MOVE_LIMB*/               03709000
                     IF OPTYPE = SSPR THEN                                      03710000
                        IF DIVIDE# >= 2 & CSE_FOUND_INX <= 1 THEN               03711000
                        CALL ELIMINATE_DIVIDES;      /* FIX SO ONLY ONE DIVIDE*/03712000
                     IF CSE_FOUND_INX ^= 0 THEN DO;                             03713000
                        IF CSE_FOUND_INX > 1 THEN DO;                           03714000
                           FNPARITY0# =N_INX - EON_PTR -1+ CSE_FOUND_INX        03715000
                              - FNPARITY1#;                                     03716000
                           MPARITY0# = CSE_FOUND_INX - MPARITY1#;               03717000
                           CALL COLLAPSE_LITERALS(EON_PTR - 1);                 03718000
                        END;                                                    03719000
                        ELSE DO;                                                03720000
                           NODE2(N_INX) = CSE2(1);                              03721000
                           NODE(N_INX) = CSE(1);                                03722000
                        END;                                                    03723000
                        N_INX = N_INX + 1;                                      03724000
                     END;                                                       03725000
                  END; /* COMMUTATIVE*/                                         03726000
                                                                                03727000
                  NODE(N_INX) = OPTYPE;                                         03728000
                  NODE2(N_INX) = NODE2(REF_PTR);                                03729000
                  NODE2(EON_PTR) = N_INX;                                       03730000
                  N_INX = N_INX +1;                                             03731000
               END;  /*ELSE DO*/                                                03732000
                                                                                03732910
            END;        /* DIFF_NODE(D_N_INX) ^= 0*/                            03732920
                                                                                03732930
         END; /*DO WHILE D_N_INX*/                                              03733000
      END BUILD_NODE_LIST;                                                      03734000
                                                                                03735000
                                                                                03736000
      I = SMRK_CTR - LAST_SMRK;      /* CHECK ENOUGH ROOM IN NODE LIST*/        03737000
      IF N_INX + I + I > MAX_NODE_SIZE THEN                                     03738000
         IF ^PUSH_TEST THEN DO;                                                 03738010
                                                                                03738020
         CALL ZAP_TABLES(1);                                                    03738030
         CTR = SMRK_CTR;                                                        03738040
         STILL_NODES = FALSE;                                                   03740000
         RETURN;                                                                03741000
      END;                                                                      03742000
      STILL_NODES = TRUE;                                                       03743000
      NODE(N_INX) = END_OF_LIST;                                                03744000
      NODE2(N_INX) = SHL(LEVEL,11) | BLOCK#;                                    03745000
      LAST_END_OF_LIST = N_INX;                                                 03745010
      N_INX = N_INX+1;                                                          03746000
      CALL BUILD_NODE_LIST;                                                     03747000
      GET_INX=N_INX - 1;      /* POINTS TO OPERATION*/                          03748000
      IF NODE(GET_INX) = END_OF_LIST THEN DO;    /*NO NEW NODES*/               03749000
         STILL_NODES = FALSE;                                                   03750000
         N_INX = GET_INX;                                                       03751000
         RETURN;                                                                03752000
      END;                                                                      03753000
      IF TRACE THEN CALL CSE_TAB_DUMP;                                          03754000
   END GROW_TREE;                                                               03755000
