 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ASSIGNME.xpl
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
 /* PROCEDURE NAME:  ASSIGNMENT                                             */
 /* MEMBER NAME:     ASSIGNME                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          CTR               BIT(16)                                      */
 /*          PRESCANNING       BIT(8)                                       */
 /*          SPECIAL           BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          LHS_PTR           BIT(16)                                      */
 /*          RHS_PTR           BIT(16)                                      */
 /*          SIMPLE_ASSIGN     BIT(8)                                       */
 /*          TYPE              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          FOR                                                            */
 /*          OPR                                                            */
 /*          PM_FLAGS                                                       */
 /*          SYM                                                            */
 /*          SYM_FLAGS                                                      */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_FLAGS                                                      */
 /*          SYT_TYPE                                                       */
 /*          TRACE                                                          */
 /*          VAC                                                            */
 /*          XVAC                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CATALOG_PTR                                                    */
 /*          NAME_CHECK                                                     */
 /*          NO_OPERANDS                                                    */
 /*          SET_CATALOG_PTR                                                */
 /*          SET_VALIDITY                                                   */
 /*          ST_CHECK                                                       */
 /*          SYTP                                                           */
 /*          VALIDITY                                                       */
 /* CALLED BY:                                                              */
 /*          CHICKEN_OUT                                                    */
 /*          OPTIMISE                                                       */
 /*          PRESCAN                                                        */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ASSIGNMENT <==                                                      */
 /*     ==> CATALOG_PTR                                                     */
 /*     ==> SET_CATALOG_PTR                                                 */
 /*     ==> VALIDITY                                                        */
 /*     ==> SET_VALIDITY                                                    */
 /*     ==> SYTP                                                            */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> NAME_CHECK                                                      */
 /*         ==> SET_VALIDITY                                                */
 /*         ==> ZAP_VARS_BY_TYPE                                            */
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
 /*     ==> ST_CHECK                                                        */
 /*         ==> SYTP                                                        */
 /*         ==> HALMAT_FLAG                                                 */
 /*             ==> VAC_OR_XPT                                              */
 /*         ==> TERM_CHECK                                                  */
 /*             ==> LAST_OPERAND                                            */
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
 /***************************************************************************/
                                                                                02044000
 /* PROCESS ASSIGNMENT*/                                                        02045000
 /**************** ALL OPERANDS MUST BE GIVEN IN THE CALL**************/        02045010
ASSIGNMENT:                                                                     02046000
   PROCEDURE(CTR,PRESCANNING,SPECIAL);                                          02047000
      DECLARE CTR BIT(16),                                                      02047010
         (PRESCANNING,SPECIAL) BIT(8);                                          02047020
      DECLARE (I,LHS_PTR,RHS_PTR,TYPE) BIT(16),                                 02048000
         SIMPLE_ASSIGN BIT(8);                                                  02049000
      IF TRACE THEN OUTPUT = 'ASSIGNMENT: ' || CTR;                             02050000
      SIMPLE_ASSIGN = SYTP(CTR + 1);                                            02051000
      RHS_PTR = SHR(OPR(CTR + 1),16);   /* RHS PTR*/                            02052000
      DO FOR I = CTR + 2 TO CTR + NO_OPERANDS(CTR);                             02053000
         LHS_PTR = SHR(OPR(I),16);                                              02054000
         TYPE = SHR(OPR(I),4) & "F";                                            02055000
         IF TYPE = SYM THEN DO;  /* SYM RECEIVER*/                              02056000
            IF NAME_CHECK(I,0) THEN RETURN;                                     02057000
            IF SIMPLE_ASSIGN AND ^PRESCANNING THEN DO;                          02058000
               IF SYT_TYPE(LHS_PTR) = SYT_TYPE(RHS_PTR) &                       02059000
                  ((SYT_FLAGS(LHS_PTR) & PM_FLAGS) = (SYT_FLAGS(RHS_PTR) &      02060000
                  PM_FLAGS)) THEN DO;                                           02061000
                                                                                02062000
                  CALL SET_CATALOG_PTR(LHS_PTR,CATALOG_PTR(RHS_PTR));           02063000
                  CALL SET_VALIDITY(LHS_PTR,VALIDITY(RHS_PTR));                 02064000
               END;                                                             02065000
            END;                                                                02066000
         END;                                                                   02067000
         ELSE IF TYPE = VAC THEN DO;  /* POINTS TO DSUB OR SUBBIT*/             02068000
            IF (OPR(LHS_PTR + 1) & "FFF1") = XVAC THEN                          02069000
               LHS_PTR = SHR(OPR(LHS_PTR + 1),16);   /* SUBBIT -> DSUB*/        02070000
            IF SYTP(LHS_PTR + 1) THEN DO;                                       02071000
               IF NAME_CHECK(LHS_PTR + 1,0) THEN RETURN;                        02072000
            END;                                                                02073000
            ELSE DO;                                                            02074000
               IF ST_CHECK(SHR(OPR(LHS_PTR + 1),16)) THEN RETURN;   /* XPT*/    02075000
            END;                                                                02076000
         END;                                                                   02077000
         ELSE DO;                                                               02078000
            IF  ST_CHECK(LHS_PTR) THEN RETURN;                                  02079000
         END;                                                                   02080000
         IF SPECIAL THEN RETURN;                                                02080010
      END;                                                                      02081000
      IF TRACE THEN OUTPUT = '   END ASSIGNMENT.';                              02082000
   END ASSIGNMENT;                                                              02083000
