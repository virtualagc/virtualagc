 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PROCESSL.xpl
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
 /* PROCEDURE NAME:  PROCESS_LABEL                                          */
 /* MEMBER NAME:     PROCESSL                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          PRESCAN           BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TAGGED_BRA        FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SYM_LENGTH                                                     */
 /*          OPR                                                            */
 /*          SYM_TAB                                                        */
 /*          SYT_DIMS                                                       */
 /*          TAG                                                            */
 /*          XINL                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LAST_OP                                                        */
 /*          END_MULTICASE                                                  */
 /*          XHALMAT_QUAL                                                   */
 /*          ZAP_TABLES                                                     */
 /* CALLED BY:                                                              */
 /*          PRESCAN                                                        */
 /*          CHICKEN_OUT                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PROCESS_LABEL <==                                                   */
 /*     ==> LAST_OP                                                         */
 /*     ==> XHALMAT_QUAL                                                    */
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
 /***************************************************************************/
                                                                                02207700
 /* PROCESSES LABEL OPRTR*/                                                     02207710
PROCESS_LABEL:                                                                  02207720
   PROCEDURE(PTR,PRESCAN);                                                      02207730
      DECLARE PRESCAN BIT(8);                                                   02207740
      DECLARE PTR BIT(16);                                                      02207750
      DECLARE TAGGED_BRA FIXED INITIAL("1 01 009 0");                           02207760
      IF XHALMAT_QUAL(PTR + 1) = XINL THEN DO;                                  02207770
         IF TAG THEN DO;   /* EXIT LABEL FROM IF*/                              02207780
            IF ^PRESCAN THEN CALL END_MULTICASE;                                02207790
         END;                                                                   02207800
         ELSE IF(OPR(LAST_OP(PTR-1)) & "1 FF FFF 1") ^= TAGGED_BRA THEN DO;     02207810
            CALL ZAP_TABLES;        /* LBL FOR ON ERROR*/                       02207820
         END;                                                                   02207830
                                                                                02207840
 /* IF LBL FOR FALSE PART OF IF THEN ELSE, NO ACTION*/                          02207850
                                                                                02207860
      END;                                                                      02207870
                                                                                02207880
      ELSE IF SYT_DIMS(SHR(OPR(PTR + 1),16)) ^= 0 THEN                          02207890
         CALL ZAP_TABLES;                              /* REFERENCED LABEL*/    02207900
      PRESCAN = 0;                                                              02207910
   END PROCESS_LABEL;                                                           02207920
