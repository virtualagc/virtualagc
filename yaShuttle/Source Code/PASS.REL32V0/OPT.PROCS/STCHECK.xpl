 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STCHECK.xpl
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
 /* PROCEDURE NAME:  ST_CHECK                                               */
 /* MEMBER NAME:     STCHECK                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TSUB_PTR          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          NODE                                                           */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HALMAT_FLAG                                                    */
 /*          SYTP                                                           */
 /*          TERM_CHECK                                                     */
 /* CALLED BY:                                                              */
 /*          ASSIGNMENT                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ST_CHECK <==                                                        */
 /*     ==> SYTP                                                            */
 /*     ==> HALMAT_FLAG                                                     */
 /*         ==> VAC_OR_XPT                                                  */
 /*     ==> TERM_CHECK                                                      */
 /*         ==> LAST_OPERAND                                                */
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
 /***************************************************************************/
                                                                                02032000
 /* CHECK STRUCTURE FOR NAMES; OPR(PTR) IS EXTN*/                               02033000
ST_CHECK:                                                                       02034000
   PROCEDURE(PTR);                                                              02035000
      DECLARE (PTR, TSUB_PTR) BIT(16);                                          02036000
      IF SYTP(PTR+1) THEN RETURN TERM_CHECK(PTR, PTR+1);                        02036010
      TSUB_PTR = SHR(OPR(PTR+1),16);                                            02036020
      IF HALMAT_FLAG(PTR+1) THEN TSUB_PTR = NODE(TSUB_PTR) & "FFFF";            02036030
      RETURN TERM_CHECK(PTR, TSUB_PTR + 1);                                     02036040
   END ST_CHECK;                                                                02043000
