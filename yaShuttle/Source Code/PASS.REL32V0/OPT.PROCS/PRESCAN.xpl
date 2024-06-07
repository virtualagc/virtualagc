 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRESCAN.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
                                Fixed a space that had been incorrectly 
                                encoded as 0x00.
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  PRESCAN                                                */
 /* MEMBER NAME:     PRESCAN                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          END_PTR           BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CLASS             BIT(16)                                      */
 /*          INX               BIT(16)                                      */
 /*          NUMOP             BIT(16)                                      */
 /*          OPCODE            BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          CLASS0                                                         */
 /*          CTR                                                            */
 /*          DFOR                                                           */
 /*          DOUBLEBLOCK_SIZE                                               */
 /*          OBPS                                                           */
 /*          OPR                                                            */
 /*          STACK_TRACE                                                    */
 /*          TRUE                                                           */
 /*          TSAPS                                                          */
 /*          ZAP_LEVEL                                                      */
 /*          ZAPS                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FBRA_FLAG                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ASSIGNMENT                                                     */
 /*          PREVENT_PULLS                                                  */
 /*          PROCESS_LABEL                                                  */
 /*          ZAP_TABLES                                                     */
 /* CALLED BY:                                                              */
 /*          CHICKEN_OUT                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PRESCAN <==                                                         */
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
 /*     ==> PREVENT_PULLS                                                   */
 /*         ==> SET_VALIDITY                                                */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> LAST_OPERAND                                                */
 /*         ==> BUMP_ADD                                                    */
 /***************************************************************************/
                                                                                02226280
                                                                                02226290
                                                                                02226300
 /* PRESCANS A LOOP TO DISCOVER WHAT IS LOOP INVARIANT*/                        02226310
PRESCAN:                                                                        02226320
   PROCEDURE(END_PTR);                                                          02226330
      DECLARE (END_PTR,INX,CLASS,OPCODE,NUMOP) BIT(16);                         02226340
                                                                                02226350
      IF STACK_TRACE THEN OUTPUT = 'PRESCAN(' || END_PTR || '):  CTR='||CTR;    02226360
      INX = CTR;                                                                02226370
                                                                                02226380
      DO WHILE INX <= DOUBLEBLOCK_SIZE;                                         02226390
         CLASS = SHR(OPR(INX),12) & "F";                                        02226400
         NUMOP = SHR(OPR(INX),16) & "FF";                                       02226410
         OPCODE = SHR(OPR(INX),4) & "FF";                                       02226420
                                                                                02226430
         IF CLASS = 0 THEN DO;                                                  02226440
            CLASS = CLASS0(OPCODE);                                             02226450
            IF ^CLASS THEN DO;                                                  02226460
               CALL ZAP_TABLES;                                                 02226470
               RETURN;                                                          02226480
            END;                                                                02226490
                                                                                02226500
            ELSE DO CASE SHR(CLASS,4);                                          02226510
                                                                                02226520
               ;                                                                02226530
                                                                                02226540
               DO;   /* LBL*/                                                   02226550
                  CALL PROCESS_LABEL(INX,1);                                    02226560
               END;                                                             02226570
                                                                                02226580
               DO;   /* BRA*/                                                   02226590
               END;                                                             02226600
                                                                                02226610
               ;   /* DSMP*/                                                    02226620
               ;   /* ESMP*/                                                    02226630
                                                                                02226640
               DO;   /* TASN*/                                                  02226650
                  CALL ASSIGNMENT(INX,1,0);                                     02226660
               END;                                                             02226670
                                                                                02226680
               ;   /* RTRN*/                                                    02226690
               ;   /* XXST*/                                                    02226700
               CALL ZAP_TABLES;   /* OPENINGS */                                02226710
               CALL ZAP_TABLES;   /* CLOSINGS */                                02226720
               ;   /* PXRC*/                                                    02226730
                                                                                02226740
               DO;   /* FBRA*/                                                  02226750
                  CALL PREVENT_PULLS(INX);                                      02226760
                  FBRA_FLAG = TRUE;                          /* DR103032 */     02226761
               END;                                                             02226770
                                                                                02226780
               DO;   /* CFOR,CTST*/                                             02226790
                  CALL PREVENT_PULLS(INX);                                      02226800
               END;                                                             02226810
                                                                                02226820
               ;   /* DSUB*/                                                    02226830
               ;   /* ADLP*/                                                    02226840
               ;   /* DCAS*/                                                    02226850
               ;   /* CLBL*/                                                    02226860
               ;   /* ECAS*/                                                    02226870
                                                                                02226880
               DO;   /* DTST,DFOR*/                                             02226890
                  IF OPCODE = DFOR THEN CALL ASSIGNMENT(INX,1,1);               02226900
               END;                                                             02226910
                                                                                02226920
               DO;   /* ETST,EFOR*/                                             02226930
                  IF SHR(OPR(INX + 1),16) = END_PTR THEN RETURN;                02226940
               END;                                                             02226950
                                                                                02226960
               DO;   /* AFOR*/                                                  02226970
                  CALL PREVENT_PULLS(INX);                                      02226980
               END;                                                             02226990
                                                                                02227000
               DO;   /* XREC*/                                                  02227010
                  CALL ZAP_TABLES;                                              02227020
                  RETURN;                                                       02227030
               END;                                                             02227040
                                                                                02227050
               DO;   /* SMRK*/                                                  02227060
                  IF SHR(OPR(INX),24) ^= 0 THEN CALL ZAP_TABLES;                02227070
 /* PHASE 1 ERROR*/                                                             02227080
                  IF ZAPS(0) THEN RETURN;                                       02227090
               END;                                                             02227100
                                                                                02227110
               ;   /* NOP*/                                                     02227120
                                                                                02227121
               ;   /* EXTN*/                                                    02227122
                                                                                02227130
                                                                                02227140
            END;   /* DO CASE*/                                                 02227150
                                                                                02227160
         END;   /* CLASS = 0*/                                                  02227170
                                                                                02227180
         ELSE IF OPCODE = "01" AND CLASS ^= 8 THEN                              02227190
            CALL ASSIGNMENT(INX,1,0);                                           02227200
                                                                                02227210
         INX = INX + NUMOP + 1;                                                 02227220
         DO WHILE OPR(INX);                                                     02227230
            INX = INX + 1;        /* SAFETY*/                                   02227240
         END;                                                                   02227250
      END;   /* DO WHILE*/                                                      02227260
   END PRESCAN;                                                                 02227270
