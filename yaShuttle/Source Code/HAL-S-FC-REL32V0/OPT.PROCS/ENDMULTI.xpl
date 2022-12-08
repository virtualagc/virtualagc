 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ENDMULTI.xpl
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
 /* PROCEDURE NAME:  END_MULTICASE                                          */
 /* MEMBER NAME:     ENDMULTI                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LEVEL                                                          */
 /*          LEVEL_STACK_VARS                                               */
 /*          STACK_TAGS                                                     */
 /*          STACK_TRACE                                                    */
 /*          XSTACK_TAGS                                                    */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          POP_ZAP_STACK                                                  */
 /*          POP_STACK                                                      */
 /*          STACK_DUMP                                                     */
 /* CALLED BY:                                                              */
 /*          PROCESS_LABEL                                                  */
 /*          CHICKEN_OUT                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> END_MULTICASE <==                                                   */
 /*     ==> STACK_DUMP                                                      */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*     ==> POP_ZAP_STACK                                                   */
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
 /***************************************************************************/
                                                                                02207590
 /* ENDS IF THEN ELSE OR DO CASE*/                                              02207600
END_MULTICASE:                                                                  02207610
   PROCEDURE;                                                                   02207620
      IF STACK_TAGS(LEVEL) THEN DO;                                             02207630
         CALL POP_ZAP_STACK(1);     /* IF THEN ELSE:COMBINE ZAPS*/              02207640
      END;                                                                      02207650
      CALL POP_STACK(1);           /* POP & MODIFY STACK*/                      02207660
      CALL POP_ZAP_STACK(1);                                                    02207670
      IF STACK_TRACE THEN CALL STACK_DUMP;                                      02207680
   END END_MULTICASE;                                                           02207690
