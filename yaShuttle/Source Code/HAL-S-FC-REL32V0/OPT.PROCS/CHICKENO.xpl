 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHICKENO.xpl
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
 /* PROCEDURE NAME:  CHICKEN_OUT                                            */
 /* MEMBER NAME:     CHICKENO                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          FIRST             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          IF_CTR            BIT(16)                                      */
 /*          LAST              MACRO                                        */
 /*          LEAF_PTR          BIT(16)                                      */
 /*          LEAFCHECKING      BIT(8)                                       */
 /*          NEXTOP            BIT(16)                                      */
 /*          NO_OPT            BIT(8)                                       */
 /*          OK                BIT(16)                                      */
 /*          OLD_VDLP#         BIT(8)                                       */
 /*          RESET             BIT(16)                                      */
 /*          SKIP              BIT(8)                                       */
 /*          TEMP              BIT(16)                                      */
 /*          TEST_PUSH         LABEL                                        */
 /*          VM_OP             BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK_END                                                      */
 /*          CLASS                                                          */
 /*          CLASS_BI                                                       */
 /*          CLASS0                                                         */
 /*          DOSIZE                                                         */
 /*          DSUB_LOC                                                       */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          LEVEL                                                          */
 /*          NOT_XREC                                                       */
 /*          OBPS                                                           */
 /*          OPCODE                                                         */
 /*          OR                                                             */
 /*          PULL_LOOP_HEAD                                                 */
 /*          STACK_TAGS                                                     */
 /*          STT#                                                           */
 /*          STUB_FLAG                                                      */
 /*          SUBCODE2                                                       */
 /*          SYM_FLAGS                                                      */
 /*          SYT_FLAGS                                                      */
 /*          TAG                                                            */
 /*          TRUE                                                           */
 /*          TSAPS                                                          */
 /*          VDLP#                                                          */
 /*          XAST                                                           */
 /*          XPULL_LOOP_HEAD                                                */
 /*          XSMRK                                                          */
 /*          XSTACK_TAGS                                                    */
 /*          ZAP_LEVEL                                                      */
 /*          ZAPS                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ARRAYED_CONDITIONAL                                            */
 /*          ASSIGN_CTR                                                     */
 /*          C_TRACE                                                        */
 /*          CROSS_STATEMENTS                                               */
 /*          CSE_TAB_DUMP2                                                  */
 /*          CTR                                                            */
 /*          DEBUG                                                          */
 /*          DO_INX                                                         */
 /*          DO_LIST                                                        */
 /*          ELEGANT_BUGOUT                                                 */
 /*          EXTNS_PRESENT                                                  */
 /*          FOLLOW_REARRANGE                                               */
 /*          HALMAT_BLAB                                                    */
 /*          HALMAT_REQUESTED                                               */
 /*          INL#                                                           */
 /*          LEVEL_STACK_VARS                                               */
 /*          LOOPY_ASSIGN_ONLY                                              */
 /*          MESSAGE                                                        */
 /*          MOVE_TRACE                                                     */
 /*          NODE_DUMP                                                      */
 /*          NUMOP                                                          */
 /*          OPR                                                            */
 /*          OPTIMIZER_OFF                                                  */
 /*          PHASE1_ERROR                                                   */
 /*          POST_STATEMENT_PUSH                                            */
 /*          PUSH_TEST                                                      */
 /*          SMRK_CTR                                                       */
 /*          STACK_TRACE                                                    */
 /*          STATEMENT_ARRAYNESS                                            */
 /*          STATISTICS                                                     */
 /*          SUB_TRACE                                                      */
 /*          SYM_TAB                                                        */
 /*          TEST                                                           */
 /*          TRACE                                                          */
 /*          WATCH                                                          */
 /*          XREC_PTR                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ASSIGN_TYPE                                                    */
 /*          ASSIGNMENT                                                     */
 /*          BLAB_BLOCK                                                     */
 /*          DECODEPOP                                                      */
 /*          DUMP_VALIDS                                                    */
 /*          END_MULTICASE                                                  */
 /*          ERASE_ZAPS                                                     */
 /*          ERRORS                                                         */
 /*          EXIT_CHECK                                                     */
 /*          EXPAND_DSUB                                                    */
 /*          LOOPY                                                          */
 /*          NO_OPERANDS                                                    */
 /*          POP_STACK                                                      */
 /*          POP_ZAP_STACK                                                  */
 /*          PRESCAN                                                        */
 /*          PROCESS_LABEL                                                  */
 /*          PUSH_HALMAT                                                    */
 /*          PUSH_STACK                                                     */
 /*          PUSH_ZAP_STACK                                                 */
 /*          PUT_VM_INLINE                                                  */
 /*          STACK_DUMP                                                     */
 /*          S                                                              */
 /*          TAG_CONDITIONALS                                               */
 /*          XHALMAT_QUAL                                                   */
 /*          ZAP_TABLES                                                     */
 /* CALLED BY:                                                              */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHICKEN_OUT <==                                                     */
 /*     ==> DECODEPOP                                                       */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*     ==> STACK_DUMP                                                      */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*     ==> BLAB_BLOCK                                                      */
 /*         ==> DECODEPIP                                                   */
 /*             ==> FORMAT                                                  */
 /*         ==> DECODEPOP                                                   */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> S                                                               */
 /*     ==> XHALMAT_QUAL                                                    */
 /*     ==> ASSIGN_TYPE                                                     */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> DUMP_VALIDS                                                     */
 /*         ==> FORMAT                                                      */
 /*         ==> CATALOG_PTR                                                 */
 /*         ==> VALIDITY                                                    */
 /*     ==> PUSH_HALMAT                                                     */
 /*         ==> HEX                                                         */
 /*         ==> OPOP                                                        */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> BUMP_D_N                                                    */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> ENTER                                                       */
 /*         ==> LAST_OP                                                     */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> MOVE_LIMB                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> RELOCATE                                                */
 /*             ==> MOVECODE                                                */
 /*                 ==> ENTER                                               */
 /*     ==> LOOPY                                                           */
 /*         ==> GET_CLASS                                                   */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> ASSIGN_TYPE                                                 */
 /*         ==> NO_OPERANDS                                                 */
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
 /*     ==> ASSIGNMENT                                                      */
 /*         ==> CATALOG_PTR                                                 */
 /*         ==> SET_CATALOG_PTR                                             */
 /*         ==> VALIDITY                                                    */
 /*         ==> SET_VALIDITY                                                */
 /*         ==> SYTP                                                        */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> NAME_CHECK                                                  */
 /*             ==> SET_VALIDITY                                            */
 /*             ==> ZAP_VARS_BY_TYPE                                        */
 /*                 ==> ZAP_TABLES                                          */
 /*                     ==> STACK_DUMP                                      */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*                     ==> CSE_TAB_DUMP                                    */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*                         ==> CATALOG_PTR                                 */
 /*                         ==> VALIDITY                                    */
 /*                         ==> CSE_WORD_FORMAT                             */
 /*                             ==> HEX                                     */
 /*                     ==> FINAL_PASS                                      */
 /*                         ==> GET_CLASS                                   */
 /*                         ==> OPOP                                        */
 /*                         ==> BUMP_D_N                                    */
 /*                         ==> S                                           */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> NAME_OR_PARM                                */
 /*                         ==> ASSIGN_TYPE                                 */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> LAST_OPERAND                                */
 /*                         ==> LOOP_OPERANDS                               */
 /*                             ==> GET_CLASS                               */
 /*                             ==> LAST_OPERAND                            */
 /*                         ==> EXTN_CHECK                                  */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> NAME_OR_PARM                            */
 /*                         ==> BUMP_ADD                                    */
 /*                         ==> LOOPY                                       */
 /*                             ==> GET_CLASS                               */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                         ==> VM_DETAG                                    */
 /*                             ==> OPOP                                    */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> TERMINAL                                */
 /*                                 ==> VAC_OR_XPT                          */
 /*                                 ==> HALMAT_FLAG                         */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                 ==> CLASSIFY                            */
 /*                                     ==> PRINT_SENTENCE                  */
 /*                                         ==> FORMAT                      */
 /*                                         ==> HEX                         */
 /*                             ==> LOOPY                                   */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> ASSIGN_TYPE                         */
 /*                                 ==> NO_OPERANDS                         */
 /*                         ==> INIT_ARCONFS                                */
 /*                         ==> C_STACK_DUMP                                */
 /*                             ==> FORMAT                                  */
 /*                         ==> CHECK_ADJACENT_LOOPS                        */
 /*                             ==> OPOP                                    */
 /*                             ==> LAST_OP                                 */
 /*                             ==> LAST_OPERAND                            */
 /*                         ==> PUSH_LOOP_STACKS                            */
 /*                             ==> INIT_ARCONFS                            */
 /*                             ==> CHECK_ADJACENT_LOOPS                    */
 /*                                 ==> OPOP                                */
 /*                                 ==> LAST_OP                             */
 /*                                 ==> LAST_OPERAND                        */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                             ==> BUMP_LOOPSTACK                          */
 /*                         ==> POP_LOOP_STACKS                             */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                         ==> COMBINE_LOOPS                               */
 /*                             ==> VU                                      */
 /*                                 ==> HEX                                 */
 /*                         ==> DENEST                                      */
 /*                             ==> VU                                      */
 /*                                 ==> HEX                                 */
 /*                             ==> POP_LOOP_STACKS                         */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                             ==> MULTIPLY_DIMS                           */
 /*                                 ==> VU                                  */
 /*                                     ==> HEX                             */
 /*                         ==> CHECK_ARRAYNESS                             */
 /*                             ==> SET_VAR                                 */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> LAST_OPERAND                        */
 /*                             ==> LOOPY                                   */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> ASSIGN_TYPE                         */
 /*                                 ==> NO_OPERANDS                         */
 /*                             ==> BUMP_REF_OPS                            */
 /*                                 ==> POP_COMPARE                         */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> NO_OPERANDS                     */
 /*                         ==> SET_LOOP_END                                */
 /*                         ==> PUSH_VM_STACK                               */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                         ==> CHECK_VM_COMBINE                            */
 /*                             ==> VM_DETAG                                */
 /*                                 ==> OPOP                                */
 /*                                 ==> NO_OPERANDS                         */
 /*                                 ==> TERMINAL                            */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                     ==> HALMAT_FLAG                     */
 /*                                         ==> VAC_OR_XPT                  */
 /*                                     ==> CLASSIFY                        */
 /*                                         ==> PRINT_SENTENCE              */
 /*                                             ==> FORMAT                  */
 /*                                             ==> HEX                     */
 /*                                 ==> LOOPY                               */
 /*                                     ==> GET_CLASS                       */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> ASSIGN_TYPE                     */
 /*                                     ==> NO_OPERANDS                     */
 /*                             ==> POP_LOOP_STACKS                         */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                             ==> COMBINE_LOOPS                           */
 /*                                 ==> VU                                  */
 /*                                     ==> HEX                             */
 /*                         ==> CHECK_LIST                                  */
 /*                             ==> FORMAT                                  */
 /*                             ==> OPOP                                    */
 /*                             ==> SET_V_M_TAGS                            */
 /*                                 ==> LAST_OPERAND                        */
 /*                         ==> EMPTY_ARRAY                                 */
 /*                             ==> OPOP                                    */
 /*                             ==> LAST_OPERAND                            */
 /*                     ==> RELOCATE_HALMAT                                 */
 /*                         ==> HEX                                         */
 /*                         ==> OPOP                                        */
 /*                         ==> VAC_OR_XPT                                  */
 /*                         ==> LAST_OP                                     */
 /*                         ==> TWIN_HALMATTED                              */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> DETAG                                       */
 /*                         ==> REFERENCE                                   */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> TERMINAL                                */
 /*                                 ==> VAC_OR_XPT                          */
 /*                                 ==> HALMAT_FLAG                         */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                 ==> CLASSIFY                            */
 /*                                     ==> PRINT_SENTENCE                  */
 /*                                         ==> FORMAT                      */
 /*                                         ==> HEX                         */
 /*         ==> ST_CHECK                                                    */
 /*             ==> SYTP                                                    */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> TERM_CHECK                                              */
 /*                 ==> LAST_OPERAND                                        */
 /*                 ==> ZAP_TABLES                                          */
 /*                     ==> STACK_DUMP                                      */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*                     ==> CSE_TAB_DUMP                                    */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*                         ==> CATALOG_PTR                                 */
 /*                         ==> VALIDITY                                    */
 /*                         ==> CSE_WORD_FORMAT                             */
 /*                             ==> HEX                                     */
 /*                     ==> FINAL_PASS                                      */
 /*                         ==> GET_CLASS                                   */
 /*                         ==> OPOP                                        */
 /*                         ==> BUMP_D_N                                    */
 /*                         ==> S                                           */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> NAME_OR_PARM                                */
 /*                         ==> ASSIGN_TYPE                                 */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> LAST_OPERAND                                */
 /*                         ==> LOOP_OPERANDS                               */
 /*                             ==> GET_CLASS                               */
 /*                             ==> LAST_OPERAND                            */
 /*                         ==> EXTN_CHECK                                  */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> NAME_OR_PARM                            */
 /*                         ==> BUMP_ADD                                    */
 /*                         ==> LOOPY                                       */
 /*                             ==> GET_CLASS                               */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                         ==> VM_DETAG                                    */
 /*                             ==> OPOP                                    */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> TERMINAL                                */
 /*                                 ==> VAC_OR_XPT                          */
 /*                                 ==> HALMAT_FLAG                         */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                 ==> CLASSIFY                            */
 /*                                     ==> PRINT_SENTENCE                  */
 /*                                         ==> FORMAT                      */
 /*                                         ==> HEX                         */
 /*                             ==> LOOPY                                   */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> ASSIGN_TYPE                         */
 /*                                 ==> NO_OPERANDS                         */
 /*                         ==> INIT_ARCONFS                                */
 /*                         ==> C_STACK_DUMP                                */
 /*                             ==> FORMAT                                  */
 /*                         ==> CHECK_ADJACENT_LOOPS                        */
 /*                             ==> OPOP                                    */
 /*                             ==> LAST_OP                                 */
 /*                             ==> LAST_OPERAND                            */
 /*                         ==> PUSH_LOOP_STACKS                            */
 /*                             ==> INIT_ARCONFS                            */
 /*                             ==> CHECK_ADJACENT_LOOPS                    */
 /*                                 ==> OPOP                                */
 /*                                 ==> LAST_OP                             */
 /*                                 ==> LAST_OPERAND                        */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                             ==> BUMP_LOOPSTACK                          */
 /*                         ==> POP_LOOP_STACKS                             */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                         ==> COMBINE_LOOPS                               */
 /*                             ==> VU                                      */
 /*                                 ==> HEX                                 */
 /*                         ==> DENEST                                      */
 /*                             ==> VU                                      */
 /*                                 ==> HEX                                 */
 /*                             ==> POP_LOOP_STACKS                         */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                             ==> MULTIPLY_DIMS                           */
 /*                                 ==> VU                                  */
 /*                                     ==> HEX                             */
 /*                         ==> CHECK_ARRAYNESS                             */
 /*                             ==> SET_VAR                                 */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> LAST_OPERAND                        */
 /*                             ==> LOOPY                                   */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> ASSIGN_TYPE                         */
 /*                                 ==> NO_OPERANDS                         */
 /*                             ==> BUMP_REF_OPS                            */
 /*                                 ==> POP_COMPARE                         */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> NO_OPERANDS                     */
 /*                         ==> SET_LOOP_END                                */
 /*                         ==> PUSH_VM_STACK                               */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                         ==> CHECK_VM_COMBINE                            */
 /*                             ==> VM_DETAG                                */
 /*                                 ==> OPOP                                */
 /*                                 ==> NO_OPERANDS                         */
 /*                                 ==> TERMINAL                            */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                     ==> HALMAT_FLAG                     */
 /*                                         ==> VAC_OR_XPT                  */
 /*                                     ==> CLASSIFY                        */
 /*                                         ==> PRINT_SENTENCE              */
 /*                                             ==> FORMAT                  */
 /*                                             ==> HEX                     */
 /*                                 ==> LOOPY                               */
 /*                                     ==> GET_CLASS                       */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> ASSIGN_TYPE                     */
 /*                                     ==> NO_OPERANDS                     */
 /*                             ==> POP_LOOP_STACKS                         */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                             ==> COMBINE_LOOPS                           */
 /*                                 ==> VU                                  */
 /*                                     ==> HEX                             */
 /*                         ==> CHECK_LIST                                  */
 /*                             ==> FORMAT                                  */
 /*                             ==> OPOP                                    */
 /*                             ==> SET_V_M_TAGS                            */
 /*                                 ==> LAST_OPERAND                        */
 /*                         ==> EMPTY_ARRAY                                 */
 /*                             ==> OPOP                                    */
 /*                             ==> LAST_OPERAND                            */
 /*                     ==> RELOCATE_HALMAT                                 */
 /*                         ==> HEX                                         */
 /*                         ==> OPOP                                        */
 /*                         ==> VAC_OR_XPT                                  */
 /*                         ==> LAST_OP                                     */
 /*                         ==> TWIN_HALMATTED                              */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> DETAG                                       */
 /*                         ==> REFERENCE                                   */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> TERMINAL                                */
 /*                                 ==> VAC_OR_XPT                          */
 /*                                 ==> HALMAT_FLAG                         */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                 ==> CLASSIFY                            */
 /*                                     ==> PRINT_SENTENCE                  */
 /*                                         ==> FORMAT                      */
 /*                                         ==> HEX                         */
 /*                 ==> NAME_CHECK                                          */
 /*                     ==> SET_VALIDITY                                    */
 /*                     ==> ZAP_VARS_BY_TYPE                                */
 /*                         ==> ZAP_TABLES                                  */
 /*                             ==> STACK_DUMP                              */
 /*                                 ==> FORMAT                              */
 /*                                 ==> HEX                                 */
 /*                             ==> CSE_TAB_DUMP                            */
 /*                                 ==> FORMAT                              */
 /*                                 ==> HEX                                 */
 /*                                 ==> CATALOG_PTR                         */
 /*                                 ==> VALIDITY                            */
 /*                                 ==> CSE_WORD_FORMAT                     */
 /*                                     ==> HEX                             */
 /*                             ==> FINAL_PASS                              */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> OPOP                                */
 /*                                 ==> BUMP_D_N                            */
 /*                                 ==> S                                   */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> NAME_OR_PARM                        */
 /*                                 ==> ASSIGN_TYPE                         */
 /*                                 ==> NO_OPERANDS                         */
 /*                                 ==> LAST_OPERAND                        */
 /*                                 ==> LOOP_OPERANDS                       */
 /*                                     ==> GET_CLASS                       */
 /*                                     ==> LAST_OPERAND                    */
 /*                                 ==> EXTN_CHECK                          */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> NAME_OR_PARM                    */
 /*                                 ==> BUMP_ADD                            */
 /*                                 ==> LOOPY                               */
 /*                                     ==> GET_CLASS                       */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> ASSIGN_TYPE                     */
 /*                                     ==> NO_OPERANDS                     */
 /*                                 ==> VM_DETAG                            */
 /*                                     ==> OPOP                            */
 /*                                     ==> NO_OPERANDS                     */
 /*                                     ==> TERMINAL                        */
 /*                                         ==> VAC_OR_XPT                  */
 /*                                         ==> HALMAT_FLAG                 */
 /*                                             ==> VAC_OR_XPT              */
 /*                                         ==> CLASSIFY                    */
 /*                                             ==> PRINT_SENTENCE          */
 /*                                                 ==> FORMAT              */
 /*                                                 ==> HEX                 */
 /*                                     ==> LOOPY                           */
 /*                                         ==> GET_CLASS                   */
 /*                                         ==> XHALMAT_QUAL                */
 /*                                         ==> ASSIGN_TYPE                 */
 /*                                         ==> NO_OPERANDS                 */
 /*                                 ==> INIT_ARCONFS                        */
 /*                                 ==> C_STACK_DUMP                        */
 /*                                     ==> FORMAT                          */
 /*                                 ==> CHECK_ADJACENT_LOOPS                */
 /*                                     ==> OPOP                            */
 /*                                     ==> LAST_OP                         */
 /*                                     ==> LAST_OPERAND                    */
 /*                                 ==> PUSH_LOOP_STACKS                    */
 /*                                     ==> INIT_ARCONFS                    */
 /*                                     ==> CHECK_ADJACENT_LOOPS            */
 /*                                         ==> OPOP                        */
 /*                                         ==> LAST_OP                     */
 /*                                         ==> LAST_OPERAND                */
 /*                                     ==> MOVE_LOOP_STACK                 */
 /*                                     ==> BUMP_LOOPSTACK                  */
 /*                                 ==> POP_LOOP_STACKS                     */
 /*                                     ==> MOVE_LOOP_STACK                 */
 /*                                 ==> COMBINE_LOOPS                       */
 /*                                     ==> VU                              */
 /*                                         ==> HEX                         */
 /*                                 ==> DENEST                              */
 /*                                     ==> VU                              */
 /*                                         ==> HEX                         */
 /*                                     ==> POP_LOOP_STACKS                 */
 /*                                         ==> MOVE_LOOP_STACK             */
 /*                                     ==> MULTIPLY_DIMS                   */
 /*                                         ==> VU                          */
 /*                                             ==> HEX                     */
 /*                                 ==> CHECK_ARRAYNESS                     */
 /*                                     ==> SET_VAR                         */
 /*                                         ==> XHALMAT_QUAL                */
 /*                                         ==> LAST_OPERAND                */
 /*                                     ==> LOOPY                           */
 /*                                         ==> GET_CLASS                   */
 /*                                         ==> XHALMAT_QUAL                */
 /*                                         ==> ASSIGN_TYPE                 */
 /*                                         ==> NO_OPERANDS                 */
 /*                                     ==> BUMP_REF_OPS                    */
 /*                                         ==> POP_COMPARE                 */
 /*                                             ==> XHALMAT_QUAL            */
 /*                                             ==> NO_OPERANDS             */
 /*                                 ==> SET_LOOP_END                        */
 /*                                 ==> PUSH_VM_STACK                       */
 /*                                     ==> MOVE_LOOP_STACK                 */
 /*                                 ==> CHECK_VM_COMBINE                    */
 /*                                     ==> VM_DETAG                        */
 /*                                         ==> OPOP                        */
 /*                                         ==> NO_OPERANDS                 */
 /*                                         ==> TERMINAL                    */
 /*                                             ==> VAC_OR_XPT              */
 /*                                             ==> HALMAT_FLAG             */
 /*                                                 ==> VAC_OR_XPT          */
 /*                                             ==> CLASSIFY                */
 /*                                                 ==> PRINT_SENTENCE      */
 /*                                                     ==> FORMAT          */
 /*                                                     ==> HEX             */
 /*                                         ==> LOOPY                       */
 /*                                             ==> GET_CLASS               */
 /*                                             ==> XHALMAT_QUAL            */
 /*                                             ==> ASSIGN_TYPE             */
 /*                                             ==> NO_OPERANDS             */
 /*                                     ==> POP_LOOP_STACKS                 */
 /*                                         ==> MOVE_LOOP_STACK             */
 /*                                     ==> COMBINE_LOOPS                   */
 /*                                         ==> VU                          */
 /*                                             ==> HEX                     */
 /*                                 ==> CHECK_LIST                          */
 /*                                     ==> FORMAT                          */
 /*                                     ==> OPOP                            */
 /*                                     ==> SET_V_M_TAGS                    */
 /*                                         ==> LAST_OPERAND                */
 /*                                 ==> EMPTY_ARRAY                         */
 /*                                     ==> OPOP                            */
 /*                                     ==> LAST_OPERAND                    */
 /*                             ==> RELOCATE_HALMAT                         */
 /*                                 ==> HEX                                 */
 /*                                 ==> OPOP                                */
 /*                                 ==> VAC_OR_XPT                          */
 /*                                 ==> LAST_OP                             */
 /*                                 ==> TWIN_HALMATTED                      */
 /*                                 ==> NO_OPERANDS                         */
 /*                                 ==> DETAG                               */
 /*                                 ==> REFERENCE                           */
 /*                                     ==> NO_OPERANDS                     */
 /*                                     ==> TERMINAL                        */
 /*                                         ==> VAC_OR_XPT                  */
 /*                                         ==> HALMAT_FLAG                 */
 /*                                             ==> VAC_OR_XPT              */
 /*                                         ==> CLASSIFY                    */
 /*                                             ==> PRINT_SENTENCE          */
 /*                                                 ==> FORMAT              */
 /*                                                 ==> HEX                 */
 /*     ==> ERASE_ZAPS                                                      */
 /*     ==> PUSH_ZAP_STACK                                                  */
 /*         ==> ERASE_ZAPS                                                  */
 /*     ==> POP_ZAP_STACK                                                   */
 /*     ==> PUSH_STACK                                                      */
 /*         ==> STACK_DUMP                                                  */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*         ==> BUMP_BLOCK                                                  */
 /*     ==> POP_STACK                                                       */
 /*         ==> STACK_DUMP                                                  */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*         ==> ZAP_TABLES                                                  */
 /*             ==> STACK_DUMP                                              */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*             ==> CSE_TAB_DUMP                                            */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*                 ==> CATALOG_PTR                                         */
 /*                 ==> VALIDITY                                            */
 /*                 ==> CSE_WORD_FORMAT                                     */
 /*                     ==> HEX                                             */
 /*             ==> FINAL_PASS                                              */
 /*                 ==> GET_CLASS                                           */
 /*                 ==> OPOP                                                */
 /*                 ==> BUMP_D_N                                            */
 /*                 ==> S                                                   */
 /*                 ==> XHALMAT_QUAL                                        */
 /*                 ==> NAME_OR_PARM                                        */
 /*                 ==> ASSIGN_TYPE                                         */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> LAST_OPERAND                                        */
 /*                 ==> LOOP_OPERANDS                                       */
 /*                     ==> GET_CLASS                                       */
 /*                     ==> LAST_OPERAND                                    */
 /*                 ==> EXTN_CHECK                                          */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> NAME_OR_PARM                                    */
 /*                 ==> BUMP_ADD                                            */
 /*                 ==> LOOPY                                               */
 /*                     ==> GET_CLASS                                       */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> ASSIGN_TYPE                                     */
 /*                     ==> NO_OPERANDS                                     */
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
 /*                 ==> INIT_ARCONFS                                        */
 /*                 ==> C_STACK_DUMP                                        */
 /*                     ==> FORMAT                                          */
 /*                 ==> CHECK_ADJACENT_LOOPS                                */
 /*                     ==> OPOP                                            */
 /*                     ==> LAST_OP                                         */
 /*                     ==> LAST_OPERAND                                    */
 /*                 ==> PUSH_LOOP_STACKS                                    */
 /*                     ==> INIT_ARCONFS                                    */
 /*                     ==> CHECK_ADJACENT_LOOPS                            */
 /*                         ==> OPOP                                        */
 /*                         ==> LAST_OP                                     */
 /*                         ==> LAST_OPERAND                                */
 /*                     ==> MOVE_LOOP_STACK                                 */
 /*                     ==> BUMP_LOOPSTACK                                  */
 /*                 ==> POP_LOOP_STACKS                                     */
 /*                     ==> MOVE_LOOP_STACK                                 */
 /*                 ==> COMBINE_LOOPS                                       */
 /*                     ==> VU                                              */
 /*                         ==> HEX                                         */
 /*                 ==> DENEST                                              */
 /*                     ==> VU                                              */
 /*                         ==> HEX                                         */
 /*                     ==> POP_LOOP_STACKS                                 */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                     ==> MULTIPLY_DIMS                                   */
 /*                         ==> VU                                          */
 /*                             ==> HEX                                     */
 /*                 ==> CHECK_ARRAYNESS                                     */
 /*                     ==> SET_VAR                                         */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> LAST_OPERAND                                */
 /*                     ==> LOOPY                                           */
 /*                         ==> GET_CLASS                                   */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> ASSIGN_TYPE                                 */
 /*                         ==> NO_OPERANDS                                 */
 /*                     ==> BUMP_REF_OPS                                    */
 /*                         ==> POP_COMPARE                                 */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> NO_OPERANDS                             */
 /*                 ==> SET_LOOP_END                                        */
 /*                 ==> PUSH_VM_STACK                                       */
 /*                     ==> MOVE_LOOP_STACK                                 */
 /*                 ==> CHECK_VM_COMBINE                                    */
 /*                     ==> VM_DETAG                                        */
 /*                         ==> OPOP                                        */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> TERMINAL                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> CLASSIFY                                */
 /*                                 ==> PRINT_SENTENCE                      */
 /*                                     ==> FORMAT                          */
 /*                                     ==> HEX                             */
 /*                         ==> LOOPY                                       */
 /*                             ==> GET_CLASS                               */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                     ==> POP_LOOP_STACKS                                 */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                     ==> COMBINE_LOOPS                                   */
 /*                         ==> VU                                          */
 /*                             ==> HEX                                     */
 /*                 ==> CHECK_LIST                                          */
 /*                     ==> FORMAT                                          */
 /*                     ==> OPOP                                            */
 /*                     ==> SET_V_M_TAGS                                    */
 /*                         ==> LAST_OPERAND                                */
 /*                 ==> EMPTY_ARRAY                                         */
 /*                     ==> OPOP                                            */
 /*                     ==> LAST_OPERAND                                    */
 /*             ==> RELOCATE_HALMAT                                         */
 /*                 ==> HEX                                                 */
 /*                 ==> OPOP                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> LAST_OP                                             */
 /*                 ==> TWIN_HALMATTED                                      */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> DETAG                                               */
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
 /*         ==> MODIFY_VALIDITY                                             */
 /*         ==> COPY_DOWN                                                   */
 /*     ==> END_MULTICASE                                                   */
 /*         ==> STACK_DUMP                                                  */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*         ==> POP_ZAP_STACK                                               */
 /*         ==> POP_STACK                                                   */
 /*             ==> STACK_DUMP                                              */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*             ==> ZAP_TABLES                                              */
 /*                 ==> STACK_DUMP                                          */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*                 ==> CSE_TAB_DUMP                                        */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*                     ==> CATALOG_PTR                                     */
 /*                     ==> VALIDITY                                        */
 /*                     ==> CSE_WORD_FORMAT                                 */
 /*                         ==> HEX                                         */
 /*                 ==> FINAL_PASS                                          */
 /*                     ==> GET_CLASS                                       */
 /*                     ==> OPOP                                            */
 /*                     ==> BUMP_D_N                                        */
 /*                     ==> S                                               */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> NAME_OR_PARM                                    */
 /*                     ==> ASSIGN_TYPE                                     */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> LAST_OPERAND                                    */
 /*                     ==> LOOP_OPERANDS                                   */
 /*                         ==> GET_CLASS                                   */
 /*                         ==> LAST_OPERAND                                */
 /*                     ==> EXTN_CHECK                                      */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> NAME_OR_PARM                                */
 /*                     ==> BUMP_ADD                                        */
 /*                     ==> LOOPY                                           */
 /*                         ==> GET_CLASS                                   */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> ASSIGN_TYPE                                 */
 /*                         ==> NO_OPERANDS                                 */
 /*                     ==> VM_DETAG                                        */
 /*                         ==> OPOP                                        */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> TERMINAL                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> CLASSIFY                                */
 /*                                 ==> PRINT_SENTENCE                      */
 /*                                     ==> FORMAT                          */
 /*                                     ==> HEX                             */
 /*                         ==> LOOPY                                       */
 /*                             ==> GET_CLASS                               */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                     ==> INIT_ARCONFS                                    */
 /*                     ==> C_STACK_DUMP                                    */
 /*                         ==> FORMAT                                      */
 /*                     ==> CHECK_ADJACENT_LOOPS                            */
 /*                         ==> OPOP                                        */
 /*                         ==> LAST_OP                                     */
 /*                         ==> LAST_OPERAND                                */
 /*                     ==> PUSH_LOOP_STACKS                                */
 /*                         ==> INIT_ARCONFS                                */
 /*                         ==> CHECK_ADJACENT_LOOPS                        */
 /*                             ==> OPOP                                    */
 /*                             ==> LAST_OP                                 */
 /*                             ==> LAST_OPERAND                            */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                         ==> BUMP_LOOPSTACK                              */
 /*                     ==> POP_LOOP_STACKS                                 */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                     ==> COMBINE_LOOPS                                   */
 /*                         ==> VU                                          */
 /*                             ==> HEX                                     */
 /*                     ==> DENEST                                          */
 /*                         ==> VU                                          */
 /*                             ==> HEX                                     */
 /*                         ==> POP_LOOP_STACKS                             */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                         ==> MULTIPLY_DIMS                               */
 /*                             ==> VU                                      */
 /*                                 ==> HEX                                 */
 /*                     ==> CHECK_ARRAYNESS                                 */
 /*                         ==> SET_VAR                                     */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> LAST_OPERAND                            */
 /*                         ==> LOOPY                                       */
 /*                             ==> GET_CLASS                               */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                         ==> BUMP_REF_OPS                                */
 /*                             ==> POP_COMPARE                             */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> NO_OPERANDS                         */
 /*                     ==> SET_LOOP_END                                    */
 /*                     ==> PUSH_VM_STACK                                   */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                     ==> CHECK_VM_COMBINE                                */
 /*                         ==> VM_DETAG                                    */
 /*                             ==> OPOP                                    */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> TERMINAL                                */
 /*                                 ==> VAC_OR_XPT                          */
 /*                                 ==> HALMAT_FLAG                         */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                 ==> CLASSIFY                            */
 /*                                     ==> PRINT_SENTENCE                  */
 /*                                         ==> FORMAT                      */
 /*                                         ==> HEX                         */
 /*                             ==> LOOPY                                   */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> ASSIGN_TYPE                         */
 /*                                 ==> NO_OPERANDS                         */
 /*                         ==> POP_LOOP_STACKS                             */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                         ==> COMBINE_LOOPS                               */
 /*                             ==> VU                                      */
 /*                                 ==> HEX                                 */
 /*                     ==> CHECK_LIST                                      */
 /*                         ==> FORMAT                                      */
 /*                         ==> OPOP                                        */
 /*                         ==> SET_V_M_TAGS                                */
 /*                             ==> LAST_OPERAND                            */
 /*                     ==> EMPTY_ARRAY                                     */
 /*                         ==> OPOP                                        */
 /*                         ==> LAST_OPERAND                                */
 /*                 ==> RELOCATE_HALMAT                                     */
 /*                     ==> HEX                                             */
 /*                     ==> OPOP                                            */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> LAST_OP                                         */
 /*                     ==> TWIN_HALMATTED                                  */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> DETAG                                           */
 /*                     ==> REFERENCE                                       */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> TERMINAL                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> CLASSIFY                                */
 /*                                 ==> PRINT_SENTENCE                      */
 /*                                     ==> FORMAT                          */
 /*                                     ==> HEX                             */
 /*             ==> MODIFY_VALIDITY                                         */
 /*             ==> COPY_DOWN                                               */
 /*     ==> PROCESS_LABEL                                                   */
 /*         ==> LAST_OP                                                     */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> ZAP_TABLES                                                  */
 /*             ==> STACK_DUMP                                              */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*             ==> CSE_TAB_DUMP                                            */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*                 ==> CATALOG_PTR                                         */
 /*                 ==> VALIDITY                                            */
 /*                 ==> CSE_WORD_FORMAT                                     */
 /*                     ==> HEX                                             */
 /*             ==> FINAL_PASS                                              */
 /*                 ==> GET_CLASS                                           */
 /*                 ==> OPOP                                                */
 /*                 ==> BUMP_D_N                                            */
 /*                 ==> S                                                   */
 /*                 ==> XHALMAT_QUAL                                        */
 /*                 ==> NAME_OR_PARM                                        */
 /*                 ==> ASSIGN_TYPE                                         */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> LAST_OPERAND                                        */
 /*                 ==> LOOP_OPERANDS                                       */
 /*                     ==> GET_CLASS                                       */
 /*                     ==> LAST_OPERAND                                    */
 /*                 ==> EXTN_CHECK                                          */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> NAME_OR_PARM                                    */
 /*                 ==> BUMP_ADD                                            */
 /*                 ==> LOOPY                                               */
 /*                     ==> GET_CLASS                                       */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> ASSIGN_TYPE                                     */
 /*                     ==> NO_OPERANDS                                     */
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
 /*                 ==> INIT_ARCONFS                                        */
 /*                 ==> C_STACK_DUMP                                        */
 /*                     ==> FORMAT                                          */
 /*                 ==> CHECK_ADJACENT_LOOPS                                */
 /*                     ==> OPOP                                            */
 /*                     ==> LAST_OP                                         */
 /*                     ==> LAST_OPERAND                                    */
 /*                 ==> PUSH_LOOP_STACKS                                    */
 /*                     ==> INIT_ARCONFS                                    */
 /*                     ==> CHECK_ADJACENT_LOOPS                            */
 /*                         ==> OPOP                                        */
 /*                         ==> LAST_OP                                     */
 /*                         ==> LAST_OPERAND                                */
 /*                     ==> MOVE_LOOP_STACK                                 */
 /*                     ==> BUMP_LOOPSTACK                                  */
 /*                 ==> POP_LOOP_STACKS                                     */
 /*                     ==> MOVE_LOOP_STACK                                 */
 /*                 ==> COMBINE_LOOPS                                       */
 /*                     ==> VU                                              */
 /*                         ==> HEX                                         */
 /*                 ==> DENEST                                              */
 /*                     ==> VU                                              */
 /*                         ==> HEX                                         */
 /*                     ==> POP_LOOP_STACKS                                 */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                     ==> MULTIPLY_DIMS                                   */
 /*                         ==> VU                                          */
 /*                             ==> HEX                                     */
 /*                 ==> CHECK_ARRAYNESS                                     */
 /*                     ==> SET_VAR                                         */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> LAST_OPERAND                                */
 /*                     ==> LOOPY                                           */
 /*                         ==> GET_CLASS                                   */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> ASSIGN_TYPE                                 */
 /*                         ==> NO_OPERANDS                                 */
 /*                     ==> BUMP_REF_OPS                                    */
 /*                         ==> POP_COMPARE                                 */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> NO_OPERANDS                             */
 /*                 ==> SET_LOOP_END                                        */
 /*                 ==> PUSH_VM_STACK                                       */
 /*                     ==> MOVE_LOOP_STACK                                 */
 /*                 ==> CHECK_VM_COMBINE                                    */
 /*                     ==> VM_DETAG                                        */
 /*                         ==> OPOP                                        */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> TERMINAL                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> CLASSIFY                                */
 /*                                 ==> PRINT_SENTENCE                      */
 /*                                     ==> FORMAT                          */
 /*                                     ==> HEX                             */
 /*                         ==> LOOPY                                       */
 /*                             ==> GET_CLASS                               */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                     ==> POP_LOOP_STACKS                                 */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                     ==> COMBINE_LOOPS                                   */
 /*                         ==> VU                                          */
 /*                             ==> HEX                                     */
 /*                 ==> CHECK_LIST                                          */
 /*                     ==> FORMAT                                          */
 /*                     ==> OPOP                                            */
 /*                     ==> SET_V_M_TAGS                                    */
 /*                         ==> LAST_OPERAND                                */
 /*                 ==> EMPTY_ARRAY                                         */
 /*                     ==> OPOP                                            */
 /*                     ==> LAST_OPERAND                                    */
 /*             ==> RELOCATE_HALMAT                                         */
 /*                 ==> HEX                                                 */
 /*                 ==> OPOP                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> LAST_OP                                             */
 /*                 ==> TWIN_HALMATTED                                      */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> DETAG                                               */
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
 /*         ==> END_MULTICASE                                               */
 /*             ==> STACK_DUMP                                              */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*             ==> POP_ZAP_STACK                                           */
 /*             ==> POP_STACK                                               */
 /*                 ==> STACK_DUMP                                          */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*                 ==> ZAP_TABLES                                          */
 /*                     ==> STACK_DUMP                                      */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*                     ==> CSE_TAB_DUMP                                    */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*                         ==> CATALOG_PTR                                 */
 /*                         ==> VALIDITY                                    */
 /*                         ==> CSE_WORD_FORMAT                             */
 /*                             ==> HEX                                     */
 /*                     ==> FINAL_PASS                                      */
 /*                         ==> GET_CLASS                                   */
 /*                         ==> OPOP                                        */
 /*                         ==> BUMP_D_N                                    */
 /*                         ==> S                                           */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> NAME_OR_PARM                                */
 /*                         ==> ASSIGN_TYPE                                 */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> LAST_OPERAND                                */
 /*                         ==> LOOP_OPERANDS                               */
 /*                             ==> GET_CLASS                               */
 /*                             ==> LAST_OPERAND                            */
 /*                         ==> EXTN_CHECK                                  */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> NAME_OR_PARM                            */
 /*                         ==> BUMP_ADD                                    */
 /*                         ==> LOOPY                                       */
 /*                             ==> GET_CLASS                               */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                         ==> VM_DETAG                                    */
 /*                             ==> OPOP                                    */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> TERMINAL                                */
 /*                                 ==> VAC_OR_XPT                          */
 /*                                 ==> HALMAT_FLAG                         */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                 ==> CLASSIFY                            */
 /*                                     ==> PRINT_SENTENCE                  */
 /*                                         ==> FORMAT                      */
 /*                                         ==> HEX                         */
 /*                             ==> LOOPY                                   */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> ASSIGN_TYPE                         */
 /*                                 ==> NO_OPERANDS                         */
 /*                         ==> INIT_ARCONFS                                */
 /*                         ==> C_STACK_DUMP                                */
 /*                             ==> FORMAT                                  */
 /*                         ==> CHECK_ADJACENT_LOOPS                        */
 /*                             ==> OPOP                                    */
 /*                             ==> LAST_OP                                 */
 /*                             ==> LAST_OPERAND                            */
 /*                         ==> PUSH_LOOP_STACKS                            */
 /*                             ==> INIT_ARCONFS                            */
 /*                             ==> CHECK_ADJACENT_LOOPS                    */
 /*                                 ==> OPOP                                */
 /*                                 ==> LAST_OP                             */
 /*                                 ==> LAST_OPERAND                        */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                             ==> BUMP_LOOPSTACK                          */
 /*                         ==> POP_LOOP_STACKS                             */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                         ==> COMBINE_LOOPS                               */
 /*                             ==> VU                                      */
 /*                                 ==> HEX                                 */
 /*                         ==> DENEST                                      */
 /*                             ==> VU                                      */
 /*                                 ==> HEX                                 */
 /*                             ==> POP_LOOP_STACKS                         */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                             ==> MULTIPLY_DIMS                           */
 /*                                 ==> VU                                  */
 /*                                     ==> HEX                             */
 /*                         ==> CHECK_ARRAYNESS                             */
 /*                             ==> SET_VAR                                 */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> LAST_OPERAND                        */
 /*                             ==> LOOPY                                   */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> ASSIGN_TYPE                         */
 /*                                 ==> NO_OPERANDS                         */
 /*                             ==> BUMP_REF_OPS                            */
 /*                                 ==> POP_COMPARE                         */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> NO_OPERANDS                     */
 /*                         ==> SET_LOOP_END                                */
 /*                         ==> PUSH_VM_STACK                               */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                         ==> CHECK_VM_COMBINE                            */
 /*                             ==> VM_DETAG                                */
 /*                                 ==> OPOP                                */
 /*                                 ==> NO_OPERANDS                         */
 /*                                 ==> TERMINAL                            */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                     ==> HALMAT_FLAG                     */
 /*                                         ==> VAC_OR_XPT                  */
 /*                                     ==> CLASSIFY                        */
 /*                                         ==> PRINT_SENTENCE              */
 /*                                             ==> FORMAT                  */
 /*                                             ==> HEX                     */
 /*                                 ==> LOOPY                               */
 /*                                     ==> GET_CLASS                       */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> ASSIGN_TYPE                     */
 /*                                     ==> NO_OPERANDS                     */
 /*                             ==> POP_LOOP_STACKS                         */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                             ==> COMBINE_LOOPS                           */
 /*                                 ==> VU                                  */
 /*                                     ==> HEX                             */
 /*                         ==> CHECK_LIST                                  */
 /*                             ==> FORMAT                                  */
 /*                             ==> OPOP                                    */
 /*                             ==> SET_V_M_TAGS                            */
 /*                                 ==> LAST_OPERAND                        */
 /*                         ==> EMPTY_ARRAY                                 */
 /*                             ==> OPOP                                    */
 /*                             ==> LAST_OPERAND                            */
 /*                     ==> RELOCATE_HALMAT                                 */
 /*                         ==> HEX                                         */
 /*                         ==> OPOP                                        */
 /*                         ==> VAC_OR_XPT                                  */
 /*                         ==> LAST_OP                                     */
 /*                         ==> TWIN_HALMATTED                              */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> DETAG                                       */
 /*                         ==> REFERENCE                                   */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> TERMINAL                                */
 /*                                 ==> VAC_OR_XPT                          */
 /*                                 ==> HALMAT_FLAG                         */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                 ==> CLASSIFY                            */
 /*                                     ==> PRINT_SENTENCE                  */
 /*                                         ==> FORMAT                      */
 /*                                         ==> HEX                         */
 /*                 ==> MODIFY_VALIDITY                                     */
 /*                 ==> COPY_DOWN                                           */
 /*     ==> EXIT_CHECK                                                      */
 /*         ==> STACK_DUMP                                                  */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> ERASE_ZAPS                                                  */
 /*         ==> PUSH_ZAP_STACK                                              */
 /*             ==> ERASE_ZAPS                                              */
 /*         ==> PUSH_STACK                                                  */
 /*             ==> STACK_DUMP                                              */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*             ==> BUMP_BLOCK                                              */
 /*         ==> POP_STACK                                                   */
 /*             ==> STACK_DUMP                                              */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*             ==> ZAP_TABLES                                              */
 /*                 ==> STACK_DUMP                                          */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*                 ==> CSE_TAB_DUMP                                        */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*                     ==> CATALOG_PTR                                     */
 /*                     ==> VALIDITY                                        */
 /*                     ==> CSE_WORD_FORMAT                                 */
 /*                         ==> HEX                                         */
 /*                 ==> FINAL_PASS                                          */
 /*                     ==> GET_CLASS                                       */
 /*                     ==> OPOP                                            */
 /*                     ==> BUMP_D_N                                        */
 /*                     ==> S                                               */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> NAME_OR_PARM                                    */
 /*                     ==> ASSIGN_TYPE                                     */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> LAST_OPERAND                                    */
 /*                     ==> LOOP_OPERANDS                                   */
 /*                         ==> GET_CLASS                                   */
 /*                         ==> LAST_OPERAND                                */
 /*                     ==> EXTN_CHECK                                      */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> NAME_OR_PARM                                */
 /*                     ==> BUMP_ADD                                        */
 /*                     ==> LOOPY                                           */
 /*                         ==> GET_CLASS                                   */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> ASSIGN_TYPE                                 */
 /*                         ==> NO_OPERANDS                                 */
 /*                     ==> VM_DETAG                                        */
 /*                         ==> OPOP                                        */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> TERMINAL                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> CLASSIFY                                */
 /*                                 ==> PRINT_SENTENCE                      */
 /*                                     ==> FORMAT                          */
 /*                                     ==> HEX                             */
 /*                         ==> LOOPY                                       */
 /*                             ==> GET_CLASS                               */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                     ==> INIT_ARCONFS                                    */
 /*                     ==> C_STACK_DUMP                                    */
 /*                         ==> FORMAT                                      */
 /*                     ==> CHECK_ADJACENT_LOOPS                            */
 /*                         ==> OPOP                                        */
 /*                         ==> LAST_OP                                     */
 /*                         ==> LAST_OPERAND                                */
 /*                     ==> PUSH_LOOP_STACKS                                */
 /*                         ==> INIT_ARCONFS                                */
 /*                         ==> CHECK_ADJACENT_LOOPS                        */
 /*                             ==> OPOP                                    */
 /*                             ==> LAST_OP                                 */
 /*                             ==> LAST_OPERAND                            */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                         ==> BUMP_LOOPSTACK                              */
 /*                     ==> POP_LOOP_STACKS                                 */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                     ==> COMBINE_LOOPS                                   */
 /*                         ==> VU                                          */
 /*                             ==> HEX                                     */
 /*                     ==> DENEST                                          */
 /*                         ==> VU                                          */
 /*                             ==> HEX                                     */
 /*                         ==> POP_LOOP_STACKS                             */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                         ==> MULTIPLY_DIMS                               */
 /*                             ==> VU                                      */
 /*                                 ==> HEX                                 */
 /*                     ==> CHECK_ARRAYNESS                                 */
 /*                         ==> SET_VAR                                     */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> LAST_OPERAND                            */
 /*                         ==> LOOPY                                       */
 /*                             ==> GET_CLASS                               */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                         ==> BUMP_REF_OPS                                */
 /*                             ==> POP_COMPARE                             */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> NO_OPERANDS                         */
 /*                     ==> SET_LOOP_END                                    */
 /*                     ==> PUSH_VM_STACK                                   */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                     ==> CHECK_VM_COMBINE                                */
 /*                         ==> VM_DETAG                                    */
 /*                             ==> OPOP                                    */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> TERMINAL                                */
 /*                                 ==> VAC_OR_XPT                          */
 /*                                 ==> HALMAT_FLAG                         */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                 ==> CLASSIFY                            */
 /*                                     ==> PRINT_SENTENCE                  */
 /*                                         ==> FORMAT                      */
 /*                                         ==> HEX                         */
 /*                             ==> LOOPY                                   */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> ASSIGN_TYPE                         */
 /*                                 ==> NO_OPERANDS                         */
 /*                         ==> POP_LOOP_STACKS                             */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                         ==> COMBINE_LOOPS                               */
 /*                             ==> VU                                      */
 /*                                 ==> HEX                                 */
 /*                     ==> CHECK_LIST                                      */
 /*                         ==> FORMAT                                      */
 /*                         ==> OPOP                                        */
 /*                         ==> SET_V_M_TAGS                                */
 /*                             ==> LAST_OPERAND                            */
 /*                     ==> EMPTY_ARRAY                                     */
 /*                         ==> OPOP                                        */
 /*                         ==> LAST_OPERAND                                */
 /*                 ==> RELOCATE_HALMAT                                     */
 /*                     ==> HEX                                             */
 /*                     ==> OPOP                                            */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> LAST_OP                                         */
 /*                     ==> TWIN_HALMATTED                                  */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> DETAG                                           */
 /*                     ==> REFERENCE                                       */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> TERMINAL                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> CLASSIFY                                */
 /*                                 ==> PRINT_SENTENCE                      */
 /*                                     ==> FORMAT                          */
 /*                                     ==> HEX                             */
 /*             ==> MODIFY_VALIDITY                                         */
 /*             ==> COPY_DOWN                                               */
 /*     ==> PRESCAN                                                         */
 /*         ==> ZAP_TABLES                                                  */
 /*             ==> STACK_DUMP                                              */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*             ==> CSE_TAB_DUMP                                            */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*                 ==> CATALOG_PTR                                         */
 /*                 ==> VALIDITY                                            */
 /*                 ==> CSE_WORD_FORMAT                                     */
 /*                     ==> HEX                                             */
 /*             ==> FINAL_PASS                                              */
 /*                 ==> GET_CLASS                                           */
 /*                 ==> OPOP                                                */
 /*                 ==> BUMP_D_N                                            */
 /*                 ==> S                                                   */
 /*                 ==> XHALMAT_QUAL                                        */
 /*                 ==> NAME_OR_PARM                                        */
 /*                 ==> ASSIGN_TYPE                                         */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> LAST_OPERAND                                        */
 /*                 ==> LOOP_OPERANDS                                       */
 /*                     ==> GET_CLASS                                       */
 /*                     ==> LAST_OPERAND                                    */
 /*                 ==> EXTN_CHECK                                          */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> NAME_OR_PARM                                    */
 /*                 ==> BUMP_ADD                                            */
 /*                 ==> LOOPY                                               */
 /*                     ==> GET_CLASS                                       */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> ASSIGN_TYPE                                     */
 /*                     ==> NO_OPERANDS                                     */
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
 /*                 ==> INIT_ARCONFS                                        */
 /*                 ==> C_STACK_DUMP                                        */
 /*                     ==> FORMAT                                          */
 /*                 ==> CHECK_ADJACENT_LOOPS                                */
 /*                     ==> OPOP                                            */
 /*                     ==> LAST_OP                                         */
 /*                     ==> LAST_OPERAND                                    */
 /*                 ==> PUSH_LOOP_STACKS                                    */
 /*                     ==> INIT_ARCONFS                                    */
 /*                     ==> CHECK_ADJACENT_LOOPS                            */
 /*                         ==> OPOP                                        */
 /*                         ==> LAST_OP                                     */
 /*                         ==> LAST_OPERAND                                */
 /*                     ==> MOVE_LOOP_STACK                                 */
 /*                     ==> BUMP_LOOPSTACK                                  */
 /*                 ==> POP_LOOP_STACKS                                     */
 /*                     ==> MOVE_LOOP_STACK                                 */
 /*                 ==> COMBINE_LOOPS                                       */
 /*                     ==> VU                                              */
 /*                         ==> HEX                                         */
 /*                 ==> DENEST                                              */
 /*                     ==> VU                                              */
 /*                         ==> HEX                                         */
 /*                     ==> POP_LOOP_STACKS                                 */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                     ==> MULTIPLY_DIMS                                   */
 /*                         ==> VU                                          */
 /*                             ==> HEX                                     */
 /*                 ==> CHECK_ARRAYNESS                                     */
 /*                     ==> SET_VAR                                         */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> LAST_OPERAND                                */
 /*                     ==> LOOPY                                           */
 /*                         ==> GET_CLASS                                   */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> ASSIGN_TYPE                                 */
 /*                         ==> NO_OPERANDS                                 */
 /*                     ==> BUMP_REF_OPS                                    */
 /*                         ==> POP_COMPARE                                 */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> NO_OPERANDS                             */
 /*                 ==> SET_LOOP_END                                        */
 /*                 ==> PUSH_VM_STACK                                       */
 /*                     ==> MOVE_LOOP_STACK                                 */
 /*                 ==> CHECK_VM_COMBINE                                    */
 /*                     ==> VM_DETAG                                        */
 /*                         ==> OPOP                                        */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> TERMINAL                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> CLASSIFY                                */
 /*                                 ==> PRINT_SENTENCE                      */
 /*                                     ==> FORMAT                          */
 /*                                     ==> HEX                             */
 /*                         ==> LOOPY                                       */
 /*                             ==> GET_CLASS                               */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                     ==> POP_LOOP_STACKS                                 */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                     ==> COMBINE_LOOPS                                   */
 /*                         ==> VU                                          */
 /*                             ==> HEX                                     */
 /*                 ==> CHECK_LIST                                          */
 /*                     ==> FORMAT                                          */
 /*                     ==> OPOP                                            */
 /*                     ==> SET_V_M_TAGS                                    */
 /*                         ==> LAST_OPERAND                                */
 /*                 ==> EMPTY_ARRAY                                         */
 /*                     ==> OPOP                                            */
 /*                     ==> LAST_OPERAND                                    */
 /*             ==> RELOCATE_HALMAT                                         */
 /*                 ==> HEX                                                 */
 /*                 ==> OPOP                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> LAST_OP                                             */
 /*                 ==> TWIN_HALMATTED                                      */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> DETAG                                               */
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
 /*         ==> ASSIGNMENT                                                  */
 /*             ==> CATALOG_PTR                                             */
 /*             ==> SET_CATALOG_PTR                                         */
 /*             ==> VALIDITY                                                */
 /*             ==> SET_VALIDITY                                            */
 /*             ==> SYTP                                                    */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> NAME_CHECK                                              */
 /*                 ==> SET_VALIDITY                                        */
 /*                 ==> ZAP_VARS_BY_TYPE                                    */
 /*                     ==> ZAP_TABLES                                      */
 /*                         ==> STACK_DUMP                                  */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*                         ==> CSE_TAB_DUMP                                */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*                             ==> CATALOG_PTR                             */
 /*                             ==> VALIDITY                                */
 /*                             ==> CSE_WORD_FORMAT                         */
 /*                                 ==> HEX                                 */
 /*                         ==> FINAL_PASS                                  */
 /*                             ==> GET_CLASS                               */
 /*                             ==> OPOP                                    */
 /*                             ==> BUMP_D_N                                */
 /*                             ==> S                                       */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> NAME_OR_PARM                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> LAST_OPERAND                            */
 /*                             ==> LOOP_OPERANDS                           */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> LAST_OPERAND                        */
 /*                             ==> EXTN_CHECK                              */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> NAME_OR_PARM                        */
 /*                             ==> BUMP_ADD                                */
 /*                             ==> LOOPY                                   */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> ASSIGN_TYPE                         */
 /*                                 ==> NO_OPERANDS                         */
 /*                             ==> VM_DETAG                                */
 /*                                 ==> OPOP                                */
 /*                                 ==> NO_OPERANDS                         */
 /*                                 ==> TERMINAL                            */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                     ==> HALMAT_FLAG                     */
 /*                                         ==> VAC_OR_XPT                  */
 /*                                     ==> CLASSIFY                        */
 /*                                         ==> PRINT_SENTENCE              */
 /*                                             ==> FORMAT                  */
 /*                                             ==> HEX                     */
 /*                                 ==> LOOPY                               */
 /*                                     ==> GET_CLASS                       */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> ASSIGN_TYPE                     */
 /*                                     ==> NO_OPERANDS                     */
 /*                             ==> INIT_ARCONFS                            */
 /*                             ==> C_STACK_DUMP                            */
 /*                                 ==> FORMAT                              */
 /*                             ==> CHECK_ADJACENT_LOOPS                    */
 /*                                 ==> OPOP                                */
 /*                                 ==> LAST_OP                             */
 /*                                 ==> LAST_OPERAND                        */
 /*                             ==> PUSH_LOOP_STACKS                        */
 /*                                 ==> INIT_ARCONFS                        */
 /*                                 ==> CHECK_ADJACENT_LOOPS                */
 /*                                     ==> OPOP                            */
 /*                                     ==> LAST_OP                         */
 /*                                     ==> LAST_OPERAND                    */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                                 ==> BUMP_LOOPSTACK                      */
 /*                             ==> POP_LOOP_STACKS                         */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                             ==> COMBINE_LOOPS                           */
 /*                                 ==> VU                                  */
 /*                                     ==> HEX                             */
 /*                             ==> DENEST                                  */
 /*                                 ==> VU                                  */
 /*                                     ==> HEX                             */
 /*                                 ==> POP_LOOP_STACKS                     */
 /*                                     ==> MOVE_LOOP_STACK                 */
 /*                                 ==> MULTIPLY_DIMS                       */
 /*                                     ==> VU                              */
 /*                                         ==> HEX                         */
 /*                             ==> CHECK_ARRAYNESS                         */
 /*                                 ==> SET_VAR                             */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> LAST_OPERAND                    */
 /*                                 ==> LOOPY                               */
 /*                                     ==> GET_CLASS                       */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> ASSIGN_TYPE                     */
 /*                                     ==> NO_OPERANDS                     */
 /*                                 ==> BUMP_REF_OPS                        */
 /*                                     ==> POP_COMPARE                     */
 /*                                         ==> XHALMAT_QUAL                */
 /*                                         ==> NO_OPERANDS                 */
 /*                             ==> SET_LOOP_END                            */
 /*                             ==> PUSH_VM_STACK                           */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                             ==> CHECK_VM_COMBINE                        */
 /*                                 ==> VM_DETAG                            */
 /*                                     ==> OPOP                            */
 /*                                     ==> NO_OPERANDS                     */
 /*                                     ==> TERMINAL                        */
 /*                                         ==> VAC_OR_XPT                  */
 /*                                         ==> HALMAT_FLAG                 */
 /*                                             ==> VAC_OR_XPT              */
 /*                                         ==> CLASSIFY                    */
 /*                                             ==> PRINT_SENTENCE          */
 /*                                                 ==> FORMAT              */
 /*                                                 ==> HEX                 */
 /*                                     ==> LOOPY                           */
 /*                                         ==> GET_CLASS                   */
 /*                                         ==> XHALMAT_QUAL                */
 /*                                         ==> ASSIGN_TYPE                 */
 /*                                         ==> NO_OPERANDS                 */
 /*                                 ==> POP_LOOP_STACKS                     */
 /*                                     ==> MOVE_LOOP_STACK                 */
 /*                                 ==> COMBINE_LOOPS                       */
 /*                                     ==> VU                              */
 /*                                         ==> HEX                         */
 /*                             ==> CHECK_LIST                              */
 /*                                 ==> FORMAT                              */
 /*                                 ==> OPOP                                */
 /*                                 ==> SET_V_M_TAGS                        */
 /*                                     ==> LAST_OPERAND                    */
 /*                             ==> EMPTY_ARRAY                             */
 /*                                 ==> OPOP                                */
 /*                                 ==> LAST_OPERAND                        */
 /*                         ==> RELOCATE_HALMAT                             */
 /*                             ==> HEX                                     */
 /*                             ==> OPOP                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> LAST_OP                                 */
 /*                             ==> TWIN_HALMATTED                          */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> DETAG                                   */
 /*                             ==> REFERENCE                               */
 /*                                 ==> NO_OPERANDS                         */
 /*                                 ==> TERMINAL                            */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                     ==> HALMAT_FLAG                     */
 /*                                         ==> VAC_OR_XPT                  */
 /*                                     ==> CLASSIFY                        */
 /*                                         ==> PRINT_SENTENCE              */
 /*                                             ==> FORMAT                  */
 /*                                             ==> HEX                     */
 /*             ==> ST_CHECK                                                */
 /*                 ==> SYTP                                                */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> TERM_CHECK                                          */
 /*                     ==> LAST_OPERAND                                    */
 /*                     ==> ZAP_TABLES                                      */
 /*                         ==> STACK_DUMP                                  */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*                         ==> CSE_TAB_DUMP                                */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*                             ==> CATALOG_PTR                             */
 /*                             ==> VALIDITY                                */
 /*                             ==> CSE_WORD_FORMAT                         */
 /*                                 ==> HEX                                 */
 /*                         ==> FINAL_PASS                                  */
 /*                             ==> GET_CLASS                               */
 /*                             ==> OPOP                                    */
 /*                             ==> BUMP_D_N                                */
 /*                             ==> S                                       */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> NAME_OR_PARM                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> LAST_OPERAND                            */
 /*                             ==> LOOP_OPERANDS                           */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> LAST_OPERAND                        */
 /*                             ==> EXTN_CHECK                              */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> NAME_OR_PARM                        */
 /*                             ==> BUMP_ADD                                */
 /*                             ==> LOOPY                                   */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> ASSIGN_TYPE                         */
 /*                                 ==> NO_OPERANDS                         */
 /*                             ==> VM_DETAG                                */
 /*                                 ==> OPOP                                */
 /*                                 ==> NO_OPERANDS                         */
 /*                                 ==> TERMINAL                            */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                     ==> HALMAT_FLAG                     */
 /*                                         ==> VAC_OR_XPT                  */
 /*                                     ==> CLASSIFY                        */
 /*                                         ==> PRINT_SENTENCE              */
 /*                                             ==> FORMAT                  */
 /*                                             ==> HEX                     */
 /*                                 ==> LOOPY                               */
 /*                                     ==> GET_CLASS                       */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> ASSIGN_TYPE                     */
 /*                                     ==> NO_OPERANDS                     */
 /*                             ==> INIT_ARCONFS                            */
 /*                             ==> C_STACK_DUMP                            */
 /*                                 ==> FORMAT                              */
 /*                             ==> CHECK_ADJACENT_LOOPS                    */
 /*                                 ==> OPOP                                */
 /*                                 ==> LAST_OP                             */
 /*                                 ==> LAST_OPERAND                        */
 /*                             ==> PUSH_LOOP_STACKS                        */
 /*                                 ==> INIT_ARCONFS                        */
 /*                                 ==> CHECK_ADJACENT_LOOPS                */
 /*                                     ==> OPOP                            */
 /*                                     ==> LAST_OP                         */
 /*                                     ==> LAST_OPERAND                    */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                                 ==> BUMP_LOOPSTACK                      */
 /*                             ==> POP_LOOP_STACKS                         */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                             ==> COMBINE_LOOPS                           */
 /*                                 ==> VU                                  */
 /*                                     ==> HEX                             */
 /*                             ==> DENEST                                  */
 /*                                 ==> VU                                  */
 /*                                     ==> HEX                             */
 /*                                 ==> POP_LOOP_STACKS                     */
 /*                                     ==> MOVE_LOOP_STACK                 */
 /*                                 ==> MULTIPLY_DIMS                       */
 /*                                     ==> VU                              */
 /*                                         ==> HEX                         */
 /*                             ==> CHECK_ARRAYNESS                         */
 /*                                 ==> SET_VAR                             */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> LAST_OPERAND                    */
 /*                                 ==> LOOPY                               */
 /*                                     ==> GET_CLASS                       */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> ASSIGN_TYPE                     */
 /*                                     ==> NO_OPERANDS                     */
 /*                                 ==> BUMP_REF_OPS                        */
 /*                                     ==> POP_COMPARE                     */
 /*                                         ==> XHALMAT_QUAL                */
 /*                                         ==> NO_OPERANDS                 */
 /*                             ==> SET_LOOP_END                            */
 /*                             ==> PUSH_VM_STACK                           */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                             ==> CHECK_VM_COMBINE                        */
 /*                                 ==> VM_DETAG                            */
 /*                                     ==> OPOP                            */
 /*                                     ==> NO_OPERANDS                     */
 /*                                     ==> TERMINAL                        */
 /*                                         ==> VAC_OR_XPT                  */
 /*                                         ==> HALMAT_FLAG                 */
 /*                                             ==> VAC_OR_XPT              */
 /*                                         ==> CLASSIFY                    */
 /*                                             ==> PRINT_SENTENCE          */
 /*                                                 ==> FORMAT              */
 /*                                                 ==> HEX                 */
 /*                                     ==> LOOPY                           */
 /*                                         ==> GET_CLASS                   */
 /*                                         ==> XHALMAT_QUAL                */
 /*                                         ==> ASSIGN_TYPE                 */
 /*                                         ==> NO_OPERANDS                 */
 /*                                 ==> POP_LOOP_STACKS                     */
 /*                                     ==> MOVE_LOOP_STACK                 */
 /*                                 ==> COMBINE_LOOPS                       */
 /*                                     ==> VU                              */
 /*                                         ==> HEX                         */
 /*                             ==> CHECK_LIST                              */
 /*                                 ==> FORMAT                              */
 /*                                 ==> OPOP                                */
 /*                                 ==> SET_V_M_TAGS                        */
 /*                                     ==> LAST_OPERAND                    */
 /*                             ==> EMPTY_ARRAY                             */
 /*                                 ==> OPOP                                */
 /*                                 ==> LAST_OPERAND                        */
 /*                         ==> RELOCATE_HALMAT                             */
 /*                             ==> HEX                                     */
 /*                             ==> OPOP                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> LAST_OP                                 */
 /*                             ==> TWIN_HALMATTED                          */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> DETAG                                   */
 /*                             ==> REFERENCE                               */
 /*                                 ==> NO_OPERANDS                         */
 /*                                 ==> TERMINAL                            */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                     ==> HALMAT_FLAG                     */
 /*                                         ==> VAC_OR_XPT                  */
 /*                                     ==> CLASSIFY                        */
 /*                                         ==> PRINT_SENTENCE              */
 /*                                             ==> FORMAT                  */
 /*                                             ==> HEX                     */
 /*                     ==> NAME_CHECK                                      */
 /*                         ==> SET_VALIDITY                                */
 /*                         ==> ZAP_VARS_BY_TYPE                            */
 /*                             ==> ZAP_TABLES                              */
 /*                                 ==> STACK_DUMP                          */
 /*                                     ==> FORMAT                          */
 /*                                     ==> HEX                             */
 /*                                 ==> CSE_TAB_DUMP                        */
 /*                                     ==> FORMAT                          */
 /*                                     ==> HEX                             */
 /*                                     ==> CATALOG_PTR                     */
 /*                                     ==> VALIDITY                        */
 /*                                     ==> CSE_WORD_FORMAT                 */
 /*                                         ==> HEX                         */
 /*                                 ==> FINAL_PASS                          */
 /*                                     ==> GET_CLASS                       */
 /*                                     ==> OPOP                            */
 /*                                     ==> BUMP_D_N                        */
 /*                                     ==> S                               */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> NAME_OR_PARM                    */
 /*                                     ==> ASSIGN_TYPE                     */
 /*                                     ==> NO_OPERANDS                     */
 /*                                     ==> LAST_OPERAND                    */
 /*                                     ==> LOOP_OPERANDS                   */
 /*                                         ==> GET_CLASS                   */
 /*                                         ==> LAST_OPERAND                */
 /*                                     ==> EXTN_CHECK                      */
 /*                                         ==> XHALMAT_QUAL                */
 /*                                         ==> NAME_OR_PARM                */
 /*                                     ==> BUMP_ADD                        */
 /*                                     ==> LOOPY                           */
 /*                                         ==> GET_CLASS                   */
 /*                                         ==> XHALMAT_QUAL                */
 /*                                         ==> ASSIGN_TYPE                 */
 /*                                         ==> NO_OPERANDS                 */
 /*                                     ==> VM_DETAG                        */
 /*                                         ==> OPOP                        */
 /*                                         ==> NO_OPERANDS                 */
 /*                                         ==> TERMINAL                    */
 /*                                             ==> VAC_OR_XPT              */
 /*                                             ==> HALMAT_FLAG             */
 /*                                                 ==> VAC_OR_XPT          */
 /*                                             ==> CLASSIFY                */
 /*                                                 ==> PRINT_SENTENCE      */
 /*                                                     ==> FORMAT          */
 /*                                                     ==> HEX             */
 /*                                         ==> LOOPY                       */
 /*                                             ==> GET_CLASS               */
 /*                                             ==> XHALMAT_QUAL            */
 /*                                             ==> ASSIGN_TYPE             */
 /*                                             ==> NO_OPERANDS             */
 /*                                     ==> INIT_ARCONFS                    */
 /*                                     ==> C_STACK_DUMP                    */
 /*                                         ==> FORMAT                      */
 /*                                     ==> CHECK_ADJACENT_LOOPS            */
 /*                                         ==> OPOP                        */
 /*                                         ==> LAST_OP                     */
 /*                                         ==> LAST_OPERAND                */
 /*                                     ==> PUSH_LOOP_STACKS                */
 /*                                         ==> INIT_ARCONFS                */
 /*                                         ==> CHECK_ADJACENT_LOOPS        */
 /*                                             ==> OPOP                    */
 /*                                             ==> LAST_OP                 */
 /*                                             ==> LAST_OPERAND            */
 /*                                         ==> MOVE_LOOP_STACK             */
 /*                                         ==> BUMP_LOOPSTACK              */
 /*                                     ==> POP_LOOP_STACKS                 */
 /*                                         ==> MOVE_LOOP_STACK             */
 /*                                     ==> COMBINE_LOOPS                   */
 /*                                         ==> VU                          */
 /*                                             ==> HEX                     */
 /*                                     ==> DENEST                          */
 /*                                         ==> VU                          */
 /*                                             ==> HEX                     */
 /*                                         ==> POP_LOOP_STACKS             */
 /*                                             ==> MOVE_LOOP_STACK         */
 /*                                         ==> MULTIPLY_DIMS               */
 /*                                             ==> VU                      */
 /*                                                 ==> HEX                 */
 /*                                     ==> CHECK_ARRAYNESS                 */
 /*                                         ==> SET_VAR                     */
 /*                                             ==> XHALMAT_QUAL            */
 /*                                             ==> LAST_OPERAND            */
 /*                                         ==> LOOPY                       */
 /*                                             ==> GET_CLASS               */
 /*                                             ==> XHALMAT_QUAL            */
 /*                                             ==> ASSIGN_TYPE             */
 /*                                             ==> NO_OPERANDS             */
 /*                                         ==> BUMP_REF_OPS                */
 /*                                             ==> POP_COMPARE             */
 /*                                                 ==> XHALMAT_QUAL        */
 /*                                                 ==> NO_OPERANDS         */
 /*                                     ==> SET_LOOP_END                    */
 /*                                     ==> PUSH_VM_STACK                   */
 /*                                         ==> MOVE_LOOP_STACK             */
 /*                                     ==> CHECK_VM_COMBINE                */
 /*                                         ==> VM_DETAG                    */
 /*                                             ==> OPOP                    */
 /*                                             ==> NO_OPERANDS             */
 /*                                             ==> TERMINAL                */
 /*                                                 ==> VAC_OR_XPT          */
 /*                                                 ==> HALMAT_FLAG         */
 /*                                                     ==> VAC_OR_XPT      */
 /*                                                 ==> CLASSIFY            */
 /*                                                     ==> PRINT_SENTENCE  */
 /*                                                         ==> FORMAT      */
 /*                                                         ==> HEX         */
 /*                                             ==> LOOPY                   */
 /*                                                 ==> GET_CLASS           */
 /*                                                 ==> XHALMAT_QUAL        */
 /*                                                 ==> ASSIGN_TYPE         */
 /*                                                 ==> NO_OPERANDS         */
 /*                                         ==> POP_LOOP_STACKS             */
 /*                                             ==> MOVE_LOOP_STACK         */
 /*                                         ==> COMBINE_LOOPS               */
 /*                                             ==> VU                      */
 /*                                                 ==> HEX                 */
 /*                                     ==> CHECK_LIST                      */
 /*                                         ==> FORMAT                      */
 /*                                         ==> OPOP                        */
 /*                                         ==> SET_V_M_TAGS                */
 /*                                             ==> LAST_OPERAND            */
 /*                                     ==> EMPTY_ARRAY                     */
 /*                                         ==> OPOP                        */
 /*                                         ==> LAST_OPERAND                */
 /*                                 ==> RELOCATE_HALMAT                     */
 /*                                     ==> HEX                             */
 /*                                     ==> OPOP                            */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                     ==> LAST_OP                         */
 /*                                     ==> TWIN_HALMATTED                  */
 /*                                     ==> NO_OPERANDS                     */
 /*                                     ==> DETAG                           */
 /*                                     ==> REFERENCE                       */
 /*                                         ==> NO_OPERANDS                 */
 /*                                         ==> TERMINAL                    */
 /*                                             ==> VAC_OR_XPT              */
 /*                                             ==> HALMAT_FLAG             */
 /*                                                 ==> VAC_OR_XPT          */
 /*                                             ==> CLASSIFY                */
 /*                                                 ==> PRINT_SENTENCE      */
 /*                                                     ==> FORMAT          */
 /*                                                     ==> HEX             */
 /*         ==> PROCESS_LABEL                                               */
 /*             ==> LAST_OP                                                 */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> ZAP_TABLES                                              */
 /*                 ==> STACK_DUMP                                          */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*                 ==> CSE_TAB_DUMP                                        */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*                     ==> CATALOG_PTR                                     */
 /*                     ==> VALIDITY                                        */
 /*                     ==> CSE_WORD_FORMAT                                 */
 /*                         ==> HEX                                         */
 /*                 ==> FINAL_PASS                                          */
 /*                     ==> GET_CLASS                                       */
 /*                     ==> OPOP                                            */
 /*                     ==> BUMP_D_N                                        */
 /*                     ==> S                                               */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> NAME_OR_PARM                                    */
 /*                     ==> ASSIGN_TYPE                                     */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> LAST_OPERAND                                    */
 /*                     ==> LOOP_OPERANDS                                   */
 /*                         ==> GET_CLASS                                   */
 /*                         ==> LAST_OPERAND                                */
 /*                     ==> EXTN_CHECK                                      */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> NAME_OR_PARM                                */
 /*                     ==> BUMP_ADD                                        */
 /*                     ==> LOOPY                                           */
 /*                         ==> GET_CLASS                                   */
 /*                         ==> XHALMAT_QUAL                                */
 /*                         ==> ASSIGN_TYPE                                 */
 /*                         ==> NO_OPERANDS                                 */
 /*                     ==> VM_DETAG                                        */
 /*                         ==> OPOP                                        */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> TERMINAL                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> CLASSIFY                                */
 /*                                 ==> PRINT_SENTENCE                      */
 /*                                     ==> FORMAT                          */
 /*                                     ==> HEX                             */
 /*                         ==> LOOPY                                       */
 /*                             ==> GET_CLASS                               */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                     ==> INIT_ARCONFS                                    */
 /*                     ==> C_STACK_DUMP                                    */
 /*                         ==> FORMAT                                      */
 /*                     ==> CHECK_ADJACENT_LOOPS                            */
 /*                         ==> OPOP                                        */
 /*                         ==> LAST_OP                                     */
 /*                         ==> LAST_OPERAND                                */
 /*                     ==> PUSH_LOOP_STACKS                                */
 /*                         ==> INIT_ARCONFS                                */
 /*                         ==> CHECK_ADJACENT_LOOPS                        */
 /*                             ==> OPOP                                    */
 /*                             ==> LAST_OP                                 */
 /*                             ==> LAST_OPERAND                            */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                         ==> BUMP_LOOPSTACK                              */
 /*                     ==> POP_LOOP_STACKS                                 */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                     ==> COMBINE_LOOPS                                   */
 /*                         ==> VU                                          */
 /*                             ==> HEX                                     */
 /*                     ==> DENEST                                          */
 /*                         ==> VU                                          */
 /*                             ==> HEX                                     */
 /*                         ==> POP_LOOP_STACKS                             */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                         ==> MULTIPLY_DIMS                               */
 /*                             ==> VU                                      */
 /*                                 ==> HEX                                 */
 /*                     ==> CHECK_ARRAYNESS                                 */
 /*                         ==> SET_VAR                                     */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> LAST_OPERAND                            */
 /*                         ==> LOOPY                                       */
 /*                             ==> GET_CLASS                               */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                         ==> BUMP_REF_OPS                                */
 /*                             ==> POP_COMPARE                             */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> NO_OPERANDS                         */
 /*                     ==> SET_LOOP_END                                    */
 /*                     ==> PUSH_VM_STACK                                   */
 /*                         ==> MOVE_LOOP_STACK                             */
 /*                     ==> CHECK_VM_COMBINE                                */
 /*                         ==> VM_DETAG                                    */
 /*                             ==> OPOP                                    */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> TERMINAL                                */
 /*                                 ==> VAC_OR_XPT                          */
 /*                                 ==> HALMAT_FLAG                         */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                 ==> CLASSIFY                            */
 /*                                     ==> PRINT_SENTENCE                  */
 /*                                         ==> FORMAT                      */
 /*                                         ==> HEX                         */
 /*                             ==> LOOPY                                   */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> ASSIGN_TYPE                         */
 /*                                 ==> NO_OPERANDS                         */
 /*                         ==> POP_LOOP_STACKS                             */
 /*                             ==> MOVE_LOOP_STACK                         */
 /*                         ==> COMBINE_LOOPS                               */
 /*                             ==> VU                                      */
 /*                                 ==> HEX                                 */
 /*                     ==> CHECK_LIST                                      */
 /*                         ==> FORMAT                                      */
 /*                         ==> OPOP                                        */
 /*                         ==> SET_V_M_TAGS                                */
 /*                             ==> LAST_OPERAND                            */
 /*                     ==> EMPTY_ARRAY                                     */
 /*                         ==> OPOP                                        */
 /*                         ==> LAST_OPERAND                                */
 /*                 ==> RELOCATE_HALMAT                                     */
 /*                     ==> HEX                                             */
 /*                     ==> OPOP                                            */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> LAST_OP                                         */
 /*                     ==> TWIN_HALMATTED                                  */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> DETAG                                           */
 /*                     ==> REFERENCE                                       */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> TERMINAL                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> HALMAT_FLAG                             */
 /*                                 ==> VAC_OR_XPT                          */
 /*                             ==> CLASSIFY                                */
 /*                                 ==> PRINT_SENTENCE                      */
 /*                                     ==> FORMAT                          */
 /*                                     ==> HEX                             */
 /*             ==> END_MULTICASE                                           */
 /*                 ==> STACK_DUMP                                          */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*                 ==> POP_ZAP_STACK                                       */
 /*                 ==> POP_STACK                                           */
 /*                     ==> STACK_DUMP                                      */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*                     ==> ZAP_TABLES                                      */
 /*                         ==> STACK_DUMP                                  */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*                         ==> CSE_TAB_DUMP                                */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*                             ==> CATALOG_PTR                             */
 /*                             ==> VALIDITY                                */
 /*                             ==> CSE_WORD_FORMAT                         */
 /*                                 ==> HEX                                 */
 /*                         ==> FINAL_PASS                                  */
 /*                             ==> GET_CLASS                               */
 /*                             ==> OPOP                                    */
 /*                             ==> BUMP_D_N                                */
 /*                             ==> S                                       */
 /*                             ==> XHALMAT_QUAL                            */
 /*                             ==> NAME_OR_PARM                            */
 /*                             ==> ASSIGN_TYPE                             */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> LAST_OPERAND                            */
 /*                             ==> LOOP_OPERANDS                           */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> LAST_OPERAND                        */
 /*                             ==> EXTN_CHECK                              */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> NAME_OR_PARM                        */
 /*                             ==> BUMP_ADD                                */
 /*                             ==> LOOPY                                   */
 /*                                 ==> GET_CLASS                           */
 /*                                 ==> XHALMAT_QUAL                        */
 /*                                 ==> ASSIGN_TYPE                         */
 /*                                 ==> NO_OPERANDS                         */
 /*                             ==> VM_DETAG                                */
 /*                                 ==> OPOP                                */
 /*                                 ==> NO_OPERANDS                         */
 /*                                 ==> TERMINAL                            */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                     ==> HALMAT_FLAG                     */
 /*                                         ==> VAC_OR_XPT                  */
 /*                                     ==> CLASSIFY                        */
 /*                                         ==> PRINT_SENTENCE              */
 /*                                             ==> FORMAT                  */
 /*                                             ==> HEX                     */
 /*                                 ==> LOOPY                               */
 /*                                     ==> GET_CLASS                       */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> ASSIGN_TYPE                     */
 /*                                     ==> NO_OPERANDS                     */
 /*                             ==> INIT_ARCONFS                            */
 /*                             ==> C_STACK_DUMP                            */
 /*                                 ==> FORMAT                              */
 /*                             ==> CHECK_ADJACENT_LOOPS                    */
 /*                                 ==> OPOP                                */
 /*                                 ==> LAST_OP                             */
 /*                                 ==> LAST_OPERAND                        */
 /*                             ==> PUSH_LOOP_STACKS                        */
 /*                                 ==> INIT_ARCONFS                        */
 /*                                 ==> CHECK_ADJACENT_LOOPS                */
 /*                                     ==> OPOP                            */
 /*                                     ==> LAST_OP                         */
 /*                                     ==> LAST_OPERAND                    */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                                 ==> BUMP_LOOPSTACK                      */
 /*                             ==> POP_LOOP_STACKS                         */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                             ==> COMBINE_LOOPS                           */
 /*                                 ==> VU                                  */
 /*                                     ==> HEX                             */
 /*                             ==> DENEST                                  */
 /*                                 ==> VU                                  */
 /*                                     ==> HEX                             */
 /*                                 ==> POP_LOOP_STACKS                     */
 /*                                     ==> MOVE_LOOP_STACK                 */
 /*                                 ==> MULTIPLY_DIMS                       */
 /*                                     ==> VU                              */
 /*                                         ==> HEX                         */
 /*                             ==> CHECK_ARRAYNESS                         */
 /*                                 ==> SET_VAR                             */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> LAST_OPERAND                    */
 /*                                 ==> LOOPY                               */
 /*                                     ==> GET_CLASS                       */
 /*                                     ==> XHALMAT_QUAL                    */
 /*                                     ==> ASSIGN_TYPE                     */
 /*                                     ==> NO_OPERANDS                     */
 /*                                 ==> BUMP_REF_OPS                        */
 /*                                     ==> POP_COMPARE                     */
 /*                                         ==> XHALMAT_QUAL                */
 /*                                         ==> NO_OPERANDS                 */
 /*                             ==> SET_LOOP_END                            */
 /*                             ==> PUSH_VM_STACK                           */
 /*                                 ==> MOVE_LOOP_STACK                     */
 /*                             ==> CHECK_VM_COMBINE                        */
 /*                                 ==> VM_DETAG                            */
 /*                                     ==> OPOP                            */
 /*                                     ==> NO_OPERANDS                     */
 /*                                     ==> TERMINAL                        */
 /*                                         ==> VAC_OR_XPT                  */
 /*                                         ==> HALMAT_FLAG                 */
 /*                                             ==> VAC_OR_XPT              */
 /*                                         ==> CLASSIFY                    */
 /*                                             ==> PRINT_SENTENCE          */
 /*                                                 ==> FORMAT              */
 /*                                                 ==> HEX                 */
 /*                                     ==> LOOPY                           */
 /*                                         ==> GET_CLASS                   */
 /*                                         ==> XHALMAT_QUAL                */
 /*                                         ==> ASSIGN_TYPE                 */
 /*                                         ==> NO_OPERANDS                 */
 /*                                 ==> POP_LOOP_STACKS                     */
 /*                                     ==> MOVE_LOOP_STACK                 */
 /*                                 ==> COMBINE_LOOPS                       */
 /*                                     ==> VU                              */
 /*                                         ==> HEX                         */
 /*                             ==> CHECK_LIST                              */
 /*                                 ==> FORMAT                              */
 /*                                 ==> OPOP                                */
 /*                                 ==> SET_V_M_TAGS                        */
 /*                                     ==> LAST_OPERAND                    */
 /*                             ==> EMPTY_ARRAY                             */
 /*                                 ==> OPOP                                */
 /*                                 ==> LAST_OPERAND                        */
 /*                         ==> RELOCATE_HALMAT                             */
 /*                             ==> HEX                                     */
 /*                             ==> OPOP                                    */
 /*                             ==> VAC_OR_XPT                              */
 /*                             ==> LAST_OP                                 */
 /*                             ==> TWIN_HALMATTED                          */
 /*                             ==> NO_OPERANDS                             */
 /*                             ==> DETAG                                   */
 /*                             ==> REFERENCE                               */
 /*                                 ==> NO_OPERANDS                         */
 /*                                 ==> TERMINAL                            */
 /*                                     ==> VAC_OR_XPT                      */
 /*                                     ==> HALMAT_FLAG                     */
 /*                                         ==> VAC_OR_XPT                  */
 /*                                     ==> CLASSIFY                        */
 /*                                         ==> PRINT_SENTENCE              */
 /*                                             ==> FORMAT                  */
 /*                                             ==> HEX                     */
 /*                     ==> MODIFY_VALIDITY                                 */
 /*                     ==> COPY_DOWN                                       */
 /*         ==> PREVENT_PULLS                                               */
 /*             ==> SET_VALIDITY                                            */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> LAST_OPERAND                                            */
 /*             ==> BUMP_ADD                                                */
 /*     ==> TAG_CONDITIONALS                                                */
 /*         ==> BUMP_D_N                                                    */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> BUMP_ADD                                                    */
 /*         ==> CLASSIFY                                                    */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*         ==> NOT_TYPE                                                    */
 /*         ==> ANDOR_TYPE                                                  */
 /*         ==> COMPARE_TYPE                                                */
 /*     ==> EXPAND_DSUB                                                     */
 /*         ==> OPOP                                                        */
 /*         ==> LAST_OP                                                     */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> SET_VAR                                                     */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> LAST_OPERAND                                            */
 /*         ==> SET_SAV                                                     */
 /*             ==> OPOP                                                    */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> LAST_OPERAND                                            */
 /*             ==> VU                                                      */
 /*                 ==> HEX                                                 */
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
 /*         ==> CHECK_COMPONENT                                             */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> CONVERSION_TYPE                                         */
 /*             ==> GENERATE_DSUB_COMPUTATION                               */
 /*                 ==> INSERT_HALMAT_TRIPLE                                */
 /*                     ==> VU                                              */
 /*                         ==> HEX                                         */
 /*                     ==> PUSH_HALMAT                                     */
 /*                         ==> HEX                                         */
 /*                         ==> OPOP                                        */
 /*                         ==> VAC_OR_XPT                                  */
 /*                         ==> BUMP_D_N                                    */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> ENTER                                       */
 /*                         ==> LAST_OP                                     */
 /*                         ==> NO_OPERANDS                                 */
 /*                         ==> MOVE_LIMB                                   */
 /*                             ==> ERRORS                                  */
 /*                                 ==> COMMON_ERRORS                       */
 /*                             ==> RELOCATE                                */
 /*                             ==> MOVECODE                                */
 /*                                 ==> ENTER                               */
 /*                 ==> COMPUTE_DIM_CONSTANT                                */
 /*                     ==> SAVE_LITERAL                                    */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> GET_LITERAL                                 */
 /*                     ==> TEMPLATE_LIT                                    */
 /*                         ==> STRUCTURE_COMPARE                           */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> GENERATE_TEMPLATE_LIT                       */
 /*                             ==> SAVE_LITERAL                            */
 /*                                 ==> ERRORS                              */
 /*                                     ==> COMMON_ERRORS                   */
 /*                                 ==> GET_LITERAL                         */
 /*                     ==> INT_TO_SCALAR                                   */
 /*                         ==> HEX                                         */
 /*                 ==> EXTRACT_VAR                                         */
 /*                     ==> HEX                                             */
 /*                     ==> OPOP                                            */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                 ==> COMPUTE_DIMENSIONS                                  */
 /*     ==> PUT_VM_INLINE                                                   */
 /*         ==> OPOP                                                        */
 /*         ==> BUMP_D_N                                                    */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> NAME_OR_PARM                                                */
 /*         ==> ASSIGN_TYPE                                                 */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> LAST_OPERAND                                                */
 /*         ==> NONCONSEC                                                   */
 /*             ==> LAST_OPERAND                                            */
 /*         ==> LOOP_OPERANDS                                               */
 /*             ==> GET_CLASS                                               */
 /*             ==> LAST_OPERAND                                            */
 /*         ==> EXTN_CHECK                                                  */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> NAME_OR_PARM                                            */
 /*         ==> BUMP_ADD                                                    */
 /*         ==> LOOPY                                                       */
 /*             ==> GET_CLASS                                               */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> ASSIGN_TYPE                                             */
 /*             ==> NO_OPERANDS                                             */
 /*         ==> PUT_VDLP                                                    */
 /*             ==> ASSIGN_TYPE                                             */
 /*             ==> LAST_OPERAND                                            */
 /*             ==> VU                                                      */
 /*                 ==> HEX                                                 */
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
 /*         ==> INSERT                                                      */
 /*             ==> MOVE_LIMB                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> RELOCATE                                            */
 /*                 ==> MOVECODE                                            */
 /*                     ==> ENTER                                           */
 /*         ==> SEARCH_DIMENSION                                            */
 /*             ==> OPOP                                                    */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> LAST_OPERAND                                            */
 /*             ==> GET_LOOP_DIMENSION                                      */
 /*                 ==> LAST_OPERAND                                        */
 /*                 ==> SET_VAR                                             */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> LAST_OPERAND                                    */
 /*                 ==> COMPUTE_DIM_CONSTANT                                */
 /*                     ==> SAVE_LITERAL                                    */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> GET_LITERAL                                 */
 /*                     ==> TEMPLATE_LIT                                    */
 /*                         ==> STRUCTURE_COMPARE                           */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> GENERATE_TEMPLATE_LIT                       */
 /*                             ==> SAVE_LITERAL                            */
 /*                                 ==> ERRORS                              */
 /*                                     ==> COMMON_ERRORS                   */
 /*                                 ==> GET_LITERAL                         */
 /*                     ==> INT_TO_SCALAR                                   */
 /*                         ==> HEX                                         */
 /*                 ==> COMPUTE_DIMENSIONS                                  */
 /***************************************************************************/
                                                                                02375130
 /* ONLY OPTIMIZE SENTENCES WITH KNOWN OPERATORS*/                              02375140
CHICKEN_OUT:                                                                    02375150
   PROCEDURE(FIRST) BIT(8);                                                     02375160
      DECLARE (NO_OPT,SKIP) BIT(8);                                             02375170
      DECLARE (FIRST,RESET,OK,TEMP,IF_CTR) BIT(16),                             02376000
         LEAFCHECKING BIT(8),                                                   02377000
         VM_OP BIT(8),                                                          02377010
         OLD_VDLP# BIT(8),                                                      02377020
         I BIT(16),                                                             02378000
         NEXTOP BIT(16),                                                        02379000
         LEAF_PTR BIT(16);                                                      02380000
      DECLARE LAST LITERALLY 'SMRK_CTR';                                        02380010
                                                                                02458000
                                                                                02459000
TEST_PUSH:                                                                      02460000
      PROCEDURE;                                                                02461000
         PUSH_TEST = TRUE;                                                      02461010
         TEMP = BLOCK_END - FIRST;                                              02462000
         NEXTOP = FIRST + NO_OPERANDS(FIRST) + 1;                               02463000
         CALL PUSH_HALMAT(NEXTOP,TEMP);                                         02464000
         OPR(NEXTOP) = SHL(TEMP-1,16);     /* NOP*/                             02465000
         DO FOR I = NEXTOP + 1 TO NEXTOP + TEMP - 1;                            02466000
            OPR(I) = 0;                                                         02467000
         END;                                                                   02468000
         LAST = SMRK_CTR;                                                       02469000
         OUTPUT = NEXTOP || ' PUSHED BY '|| TEMP;                               02470000
      END TEST_PUSH;                                                            02471000
                                                                                02472000
                                                                                02473000
                                                                                02474000
                                                                                02475000
      IF NOT_XREC THEN DO;                                                      02476000
         DEBUG = SHR(OPR(SMRK_CTR + 1),8) & "FF";                               02477000
         IF DEBUG ^= 0 THEN IF DEBUG <= 40                                      02478000
            THEN DO CASE DEBUG;       /* DEBUG TOGGLE*/                         02478010
            ;                                                                   02479000
            NO_OPT = NO_OPT + 1;       /* DEBUG H(1) = OPTIMIZER OFF/ON   */    02480000
            SKIP = SKIP + 1;           /*       H(2) = SKIP SENTENCES     */    02481000
            DO;                /* H(3) = WATCH*/                                02482000
               WATCH = WATCH + 1;                                               02483000
               IF ^ WATCH THEN DO;                                              02484000
                  STACK_TRACE,                                                  02484001
                     MOVE_TRACE,                                                02484002
                     C_TRACE,TRACE,SUB_TRACE = FALSE;                           02484010
               END;                                                             02484020
            END;                                                                02485000
                                                                                02486000
            CALL TEST_PUSH;       /* H(4) TESTS PUSH HALMAT*/                   02487000
                                                                                02488000
            DO;                   /* H(5) = TRACE*/                             02489000
               TRACE = TRACE + 1;                                               02490000
               IF TRACE THEN DO;                                                02491000
                  STACK_TRACE,                                                  02491001
                     MOVE_TRACE,                                                02491002
                     C_TRACE,WATCH,SUB_TRACE = TRUE;                            02491010
               END;                                                             02491020
            END;                                                                02492000
                                                                                02493000
            HALMAT_REQUESTED = HALMAT_REQUESTED + 1; /* H(6) = HALMAT REQ*/     02494000
                                                                                02495000
            HALMAT_BLAB = HALMAT_BLAB + 1;      /* H(7) = HALMAT_BLAB*/         02496000
                                                                                02497000
            ELEGANT_BUGOUT = TRUE;   /* H(8) = NO PHASE 2*/                     02498000
                                                                                02499000
            CALL EXIT;        /* H(9) = DUMP*/                                  02500000
                                                                                02501000
            SUB_TRACE = SUB_TRACE + 1;          /* H(10) = SUB EXPANSION TRACE*/02502000
                                                                                02503000
            C_TRACE = C_TRACE + 1;          /* H(11) = LOOP COMBINE TRACE*/     02503010
                                                                                02503020
            STACK_TRACE = STACK_TRACE + 1;          /* H(12) = STACK TRACE*/    02503030
                                                                                02503040
            NODE_DUMP = NODE_DUMP + 1;              /* H(13) = NODE DUMP*/      02503050
                                                                                02503060
            DO;                                                                 02503070
            CROSS_STATEMENTS = CROSS_STATEMENTS+1;  /*H(14) = CROSS STATEMENTS*/02503080
               IF CROSS_STATEMENTS THEN MESSAGE = ' ENABLED ';                  02503090
               ELSE MESSAGE = ' DISABLED ';                                     02503100
              OUTPUT = 'CROSS STATEMENT LOOP COMBINING AND INVARIANT PULLING' ||02503110
                  MESSAGE || 'AT HAL/S STATEMENT ' || STT#;                     02503120
            END;                                                                02503130
                                                                                02503140
          CSE_TAB_DUMP2 = CSE_TAB_DUMP2 + 1;  /* H(15) = CSE_TAB_DUMP OF CATALOG02503150
                                                AND ENTRY NODES*/               02503160
            CALL STACK_DUMP;    /* H(16) = STACK DUMP */                        02503165
            FOLLOW_REARRANGE=FOLLOW_REARRANGE+1; /* EXTRA HALMAT DUMPS */       02503170
            ;                                    /* H(18) NOT USED */           02503175
                                                                                02503180
            CALL DUMP_VALIDS;  /* H(19) = DUMP VALIDS*/                         02503220
            STATISTICS = STATISTICS + 1;  /* H(20) = STATISTICS */              02503240
            MOVE_TRACE = MOVE_TRACE + 1;  /* H(21) = MOVE HALMAT TRACE*/        02503250
            CALL BLAB_BLOCK(0);               /* H(22) BLAB FIRST HALMAT BLOCK*/02503270
         CALL BLAB_BLOCK(BLOCK_END + 1);     /* H(23) BLAB SECOND HALMAT BLOCK*/02503280
            DO;                               /* H(24) BLAB BOTH HALMAT BLOCKS*/02503290
               CALL BLAB_BLOCK(0);                                              02503300
               CALL BLAB_BLOCK(BLOCK_END + 1);                                  02503310
            END;                                                                02503320
                                                                                02504000
            ;;;;;;                                                              02504010
                                                                                02504020
                                                                                02505000
                                                                                02506000
            END; /* DO CASE*/                                                   02507000
         ELSE IF DEBUG <= 99 THEN TEST = TEST + 1;                              02508000
                                                                                02509000
      END;                                                                      02510000
                                                                                02511000
                                                                                02512000
      PHASE1_ERROR = SHR(OPR(LAST),24) ^= 0;                                    02513000
      IF PHASE1_ERROR THEN DO;                                                  02513010
         CALL ZAP_TABLES(1);                                                    02514000
         CTR = SMRK_CTR;                                                        02514010
         OPTIMIZER_OFF = TRUE;  /* STATEMENT WITH ERROR STOPS OPTIMIZATION*/    02515000
         RETURN 1;                                                              02516000
      END;                                                                      02517000
      IF LAST < FIRST THEN DO;                                                  02518000
         IF WATCH THEN OUTPUT = '******ERROR IN CTR, STATEMENT SKIPPED';        02519000
         DO WHILE (OPR(CTR) & "FFF1") ^= XSMRK;                                 02520000
            CTR = CTR + 1;                                                      02521000
         END;                                                                   02522000
         CTR = CTR - 1;                                                         02523000
         RETURN 1;                                                              02524000
      END;                                                                      02525000
      EXTNS_PRESENT,                                                            02525005
         STATEMENT_ARRAYNESS, ARRAYED_CONDITIONAL = FALSE;                      02525010
      IF_CTR,ASSIGN_CTR = 0;                                                    02526000
      RESET = FIRST;                                                            02527000
      OK = 3;                                                                   02528000
      LOOPY_ASSIGN_ONLY,VM_OP = FALSE;                                          02528010
      DO WHILE FIRST<LAST;                                                      02529000
         CALL DECODEPOP(FIRST);                                                 02530000
         DO CASE CLASS;                                                         02531000
            DO;                                                                 02532000
               OK = CLASS0(OPCODE) & OK;                                        02533000
                                                                                02534000
               DO CASE SHR(CLASS0(OPCODE),4);                                   02535000
                                                                                02536000
                  ;     /* NO SPECIAL ACTION*/                                  02537000
                                                                                02538000
                  CALL PROCESS_LABEL(FIRST);       /* LBL*/                     02539000
                                                                                02540000
                  CALL EXIT_CHECK(FIRST);    /* BRA*/                           02541000
                                                                                02542000
                  DO;                              /* DSMP*/                    02543000
                     DO_INX = DO_INX + 1;                                       02544000
                     IF DO_INX > DOSIZE THEN CALL ERRORS (CLASS_BI, 311);       02545000
                     DO_LIST(DO_INX) = SHR(OPR(FIRST + 1),16);                  02546000
                  END;                                                          02547000
                                                                                02548000
                  DO;                              /* ESMP*/                    02549000
                     IF DO_LIST(DO_INX) < 0 THEN OK = 0;                        02550000
                     DO_INX = DO_INX - 1;                                       02551000
                  END;                                                          02552000
                                                                                02553000
                  ASSIGN_CTR = FIRST;   /* TASN*/                               02554000
                                                                                02555000
                  DO;                                                           02555010
                     IF NUMOP = 1 THEN ASSIGN_CTR = FIRST;    /*RTRN*/          02556000
                     CALL ERASE_ZAPS;                                           02556010
                  END;                                                          02556020
                                                                                02557000
                  IF LEAFCHECKING THEN SYT_FLAGS(LEAF_PTR) =   /* XXST*/        02558000
                     SYT_FLAGS(LEAF_PTR) | STUB_FLAG;                           02559000
                                                                                02560000
                  DO;                              /* OPENINGS*/                02561000
                     IF LEAFCHECKING THEN SYT_FLAGS(LEAF_PTR) =                 02562000
                        SYT_FLAGS(LEAF_PTR) | STUB_FLAG;                        02563000
                     LEAF_PTR = SHR(OPR(FIRST + 1),16);                         02564000
                     LEAFCHECKING = TRUE;                                       02565000
                     CALL ZAP_TABLES(1);                                        02565010
                  END;                                                          02566000
                                                                                02567000
                  DO;                                                           02567010
                     LEAFCHECKING = FALSE;      /* CLOS,ICLS*/                  02568000
                     CALL ZAP_TABLES(1);                                        02568010
                  END;                                                          02568020
                                                                                02569000
                  XREC_PTR = SHR(OPR(FIRST+1),16);         /* PXRC*/            02570000
                                                                                02571000
                  DO;                                                           02571010
                     IF OK = 3 THEN                                             02572000
                       CALL TAG_CONDITIONALS(SHR(OPR(FIRST + 2),16));  /* FBRA*/02573000
                     POST_STATEMENT_PUSH = TRUE;                                02573010
                     IF STATEMENT_ARRAYNESS THEN ARRAYED_CONDITIONAL = TRUE;    02573015
                  END;                                                          02573020
                                                                                02574000
                  CALL TAG_CONDITIONALS(SHR(OPR(FIRST + 1),16));                02575000
 /* CFOR, CTST*/                                                                02576000
                                                                                02576010
                  IF OK = 3 & IF_CTR = 0 THEN DO;                               02576020
 /* ONLY EXPAND CSE ELIGIBLE OPS IN CONDL*/                                     02576030
                     CALL EXPAND_DSUB(FIRST);      /* DSUB*/                    02576040
 /* & TSUB */                                                                   02576041
                     FIRST = DSUB_LOC;                                          02576050
                     NUMOP = NO_OPERANDS(DSUB_LOC);                             02576060
                  END;                                                          02576070
                                                                                02576080
                  DO;                                       /* ADLP*/           02576090
                     IF IF_CTR = 0 THEN                                         02576091
                        STATEMENT_ARRAYNESS = TRUE;                             02576092
                     IF XHALMAT_QUAL(FIRST + 1) = XAST THEN                     02576094
                        OK = OK & 1;   /* NO CSE'S ETC*/                        02576096
                  END;                                                          02576098
                                                                                02576120
                  DO;                                                  /* DCAS*/02576130
                     INL# = SHR(OPR(FIRST+1),16);                               02576140
                     POST_STATEMENT_PUSH = TRUE;                                02576150
                  END;                                                          02576160
                                                                                02576170
                  DO;                                                  /* CLBL*/02576180
                     IF ^TAG THEN DO;      /* NOT LAST CLBL*/                   02576190
                        IF ^STACK_TAGS(LEVEL) THEN DO;                          02576200
                           STACK_TAGS(LEVEL) = STACK_TAGS(LEVEL) | "1";         02576210
                        END;                                                    02576220
                                                                                02576230
                        ELSE DO;                                                02576240
                           CALL POP_ZAP_STACK(1);                               02576250
                        END;                                                    02576260
                        CALL PUSH_ZAP_STACK;                                    02576270
                        CALL POP_STACK;                                         02576280
                        CALL PUSH_STACK(SHR(OPR(FIRST + 1) ,16),1);             02576290
                        IF STACK_TRACE THEN CALL STACK_DUMP;                    02576300
                     END;                                                       02576310
                  END;   /* CLBL*/                                              02576320
                                                                                02576330
                  DO;                                                  /*ECAS*/ 02576340
                     CALL END_MULTICASE;                                        02576350
                  END;                                                          02576360
                                                                                02576370
                  DO;                           /* DTST,DFOR*/                  02576380
                     CALL PUSH_ZAP_STACK;                                       02576390
                     CALL PRESCAN(SHR(OPR(FIRST + 1),16));                      02576400
                     CALL PUSH_STACK(SHR(OPR(FIRST + 1),16),0,1);               02576410
                     IF ZAPS(0) THEN DO;                                        02576420
                        PULL_LOOP_HEAD(LEVEL) = -1;                             02576430
                     END;                                                       02576440
                     ELSE DO;                                                   02576450
                        STACK_TAGS(LEVEL) = STACK_TAGS(LEVEL) | "4";            02576460
                        PULL_LOOP_HEAD(LEVEL) = FIRST;                          02576470
                     END;                                                       02576480
                  END;                                                          02576490
                                                                                02576500
                  DO;                           /* ETST,EFOR*/                  02576510
                     CALL POP_STACK;                                            02576520
                     CALL POP_ZAP_STACK(1);                                     02576530
                     IF SHR(STACK_TAGS(LEVEL + 1),1) THEN                       02576540
                        CALL ZAP_TABLES;   /* EXIT*/                            02576550
                  END;                                                          02576560
                                                                                02576570
                  ;                           /* AFOR:  NO ACTION*/             02576580
                  ;                           /* XREC:  NO ACTION*/             02576590
                  ;                           /* SMRK:  NO ACTION*/             02576600
                  DO;                         /* NOP*/                          02576610
                  END;                                                          02576620
                                                                                02576622
                  ;        /* EXTN*/                                            02576624
                                                                                02576630
                                                                                02577000
               END;                                                             02578000
            END;                                                                02579000
            ;                          /* CLASS 1 = BIT*/                       02580000
            OK = OK & 1;                          /* CLASS 2 = CHARACTER*/      02581000
            IF LOOPY(FIRST) THEN VM_OP = TRUE;     /* CLASS 3 = MATRIX */       02582000
            IF LOOPY(FIRST) THEN VM_OP = TRUE;     /* CLASS 4 = VECTOR */       02582010
            DO;           /* 5 = SCALAR*/                                       02584000
               IF SUBCODE2 = "41" THEN OK = OK & 1;                             02585000
            END;                                                                02586000
            DO;                          /* CLASS 6 = INTEGER*/                 02587000
               IF SUBCODE2 = "41" THEN OK = OK & 1;                             02588000
               IF LOOPY(FIRST) THEN IF ^VM_OP THEN                              02588010
                  LOOPY_ASSIGN_ONLY,VM_OP = TRUE;                               02588020
            END;                                                                02589000
            DO;                                                                 02590000
               IF IF_CTR = 0 THEN IF_CTR = FIRST; /* CLASS7=CONDITIONALS*/      02591000
 /* CSE'S ONLY IN FIRST PART OF COMPOUND CONDITIONAL*/                          02592000
                                                                                02594000
 /* PICKS FIRST CLASS 7*/                                                       02595000
            END;                                                                02596000
            ;                          /* CLASS 8 = INITIALIZATION*/            02597000
         END; /* DO CASE*/                                                      02598000
         IF SUBCODE2 = "01" THEN IF CLASS ^= 0 &                                02599000
            CLASS ^= 8 THEN ASSIGN_CTR = FIRST;                                 02600000
         FIRST = FIRST + NUMOP + 1;                                             02601000
      END;                                                                      02602000
                                                                                02603000
      IF ^OK OR NO_OPT THEN DO;      /* NO_OPT SET BY DEBUG*/                   02604000
         CALL ZAP_TABLES(NO_OPT);                                               02605000
         CTR = SMRK_CTR;                                                        02605010
         RETURN 1;                                                              02606000
      END;                                                                      02607000
      IF SKIP THEN OK = OK & 1;          /* SKIPS SENTENCES*/                   02608000
                                                                                02609000
      IF OK ^= 3 THEN DO;                                                       02610000
         IF ASSIGN_CTR ^= 0 THEN DO;                                            02611000
            CTR = ASSIGN_CTR;                                                   02612000
            IF ASSIGN_TYPE(CTR) THEN CALL ASSIGNMENT(CTR,0,0);                  02613000
         END;                                                                   02614000
         CTR = SMRK_CTR;                                                        02615000
         RETURN 1;                                                              02616000
      END;                                                                      02617000
      IF IF_CTR ^= 0 THEN CTR = IF_CTR;                                         02618000
      ELSE IF ASSIGN_CTR ^= 0 THEN CTR = ASSIGN_CTR;                            02619000
      ELSE CTR = SMRK_CTR;                                                      02620000
      CALL DECODEPOP(CTR);                                                      02621000
      IF VM_OP THEN DO;                                                         02621010
         CALL PUT_VM_INLINE;                                                    02621020
         IF STATISTICS THEN DO;                                                 02621030
            TEMP = VDLP# - OLD_VDLP#;                                           02621040
            IF TEMP ^= 0 THEN DO;                                               02621050
               OUTPUT='******* '||TEMP||' INLINE VECTOR/MATRIX LOOP'||S(TEMP)|| 02621060
                  ' GENERATED IN HAL/S STATEMENT '                              02621070
                  ||STT#;                                                       02621080
               OLD_VDLP# = VDLP#;                                               02621090
            END;                                                                02621100
         END;                                                                   02621110
      END;                                                                      02621120
      RETURN 0;                                                                 02622000
   END CHICKEN_OUT;                                                             02623000
