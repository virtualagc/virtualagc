 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   POPSTACK.xpl
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
 /* PROCEDURE NAME:  POP_STACK                                              */
 /* MEMBER NAME:     POPSTACK                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          ALTER_VALIDITY    BIT(8)                                       */
 /*          CD                BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TEMP              BIT(16)                                      */
 /*          EXITT             LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          MAX_STACK_LEVEL                                                */
 /*          STACK_TAGS                                                     */
 /*          STACK_TRACE                                                    */
 /*          STACKED_BLOCK#                                                 */
 /*          STT#                                                           */
 /*          TRACE                                                          */
 /*          XSTACK_TAGS                                                    */
 /*          XSTACKED_BLOCK#                                                */
 /*          XZAP_BASE                                                      */
 /*          ZAP_BASE                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BLOCK#                                                         */
 /*          LEVEL                                                          */
 /*          LEVEL_STACK_VARS                                               */
 /*          LOOP_ZAPS_LEVEL                                                */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          MODIFY_VALIDITY                                                */
 /*          COPY_DOWN                                                      */
 /*          STACK_DUMP                                                     */
 /*          ZAP_TABLES                                                     */
 /* CALLED BY:                                                              */
 /*          END_MULTICASE                                                  */
 /*          CHICKEN_OUT                                                    */
 /*          EXIT_CHECK                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> POP_STACK <==                                                       */
 /*     ==> STACK_DUMP                                                      */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
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
 /*     ==> MODIFY_VALIDITY                                                 */
 /*     ==> COPY_DOWN                                                       */
 /***************************************************************************/
                                                                                02207200
                                                                                02207210
 /* POPS CONTROL STACKS*/                                                       02207220
POP_STACK:                                                                      02207230
   PROCEDURE(ALTER_VALIDITY,CD);                                                02207240
      DECLARE (ALTER_VALIDITY,CD) BIT(8);                                       02207250
      DECLARE TEMP BIT(16);                                                     02207260
      IF STACK_TRACE THEN OUTPUT =                                              02207270
         'POP_STACK(' || ALTER_VALIDITY || '):  ' || STT#;                      02207280
      STACK_TAGS(LEVEL) = STACK_TAGS(LEVEL) & "1";                              02207290
      IF LEVEL = 0 THEN DO;                                                     02207300
         CALL ZAP_TABLES;                                                       02207310
         RETURN;                                                                02207320
      END;                                                                      02207330
                                                                                02207340
 /* FIRST DECREASE PTRS SO ALTER_VALIDITY WORKS*/                               02207350
                                                                                02207360
      LEVEL = LEVEL - 1;                                                        02207370
      IF ALTER_VALIDITY THEN DO;                                                02207410
         CALL MODIFY_VALIDITY;                                                  02207420
      END;                                                                      02207430
                                                                                02207440
      IF CD THEN DO;                                                            02207450
         CALL COPY_DOWN; /*FOR SIMPLE DO ENDS */                                02207451
         LEVEL = LEVEL + 1;                                                     02207452
      END;                                                                      02207453
                                                                                02207460
      ELSE DO;                                                                  02207470
         LEVEL = LEVEL + 1;                                                     02207471
         DO FOR TEMP=LEVEL TO MAX_STACK_LEVEL-1;                                02207472
            IF STACKED_BLOCK#(TEMP)>0 THEN                                      02207473
               STACKED_BLOCK#(TEMP) = -1;                                       02207474
            ELSE GO TO EXITT;                                                   02207475
         END;                                                                   02207476
      END;                                                                      02207477
EXITT:                                                                          02207520
      LEVEL = LEVEL - 1;                                                        02207530
      LOOP_ZAPS_LEVEL = ZAP_BASE(LEVEL);                                        02207540
      BLOCK# = STACKED_BLOCK#(LEVEL);                                           02207550
      CD,ALTER_VALIDITY = FALSE;                                                02207560
      IF TRACE THEN CALL STACK_DUMP;                                            02207570
   END POP_STACK;                                                               02207580
