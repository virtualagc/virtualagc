 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EXITCHEC.xpl
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
 /* PROCEDURE NAME:  EXIT_CHECK                                             */
 /* MEMBER NAME:     EXITCHEC                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DO_INX                                                         */
 /*          FOR                                                            */
 /*          LEVEL                                                          */
 /*          OPR                                                            */
 /*          STACK_INL#                                                     */
 /*          STACK_TAGS                                                     */
 /*          STACK_TRACE                                                    */
 /*          XINL                                                           */
 /*          XSTACK_INL#                                                    */
 /*          XSTACK_TAGS                                                    */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          DO_LIST                                                        */
 /*          LEVEL_STACK_VARS                                               */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERASE_ZAPS                                                     */
 /*          POP_STACK                                                      */
 /*          PUSH_STACK                                                     */
 /*          PUSH_ZAP_STACK                                                 */
 /*          STACK_DUMP                                                     */
 /*          XHALMAT_QUAL                                                   */
 /* CALLED BY:                                                              */
 /*          CHICKEN_OUT                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> EXIT_CHECK <==                                                      */
 /*     ==> STACK_DUMP                                                      */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*     ==> XHALMAT_QUAL                                                    */
 /*     ==> ERASE_ZAPS                                                      */
 /*     ==> PUSH_ZAP_STACK                                                  */
 /*         ==> ERASE_ZAPS                                                  */
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
 /***************************************************************************/
                                                                                02207930
 /* ERASES ZAPS IF NO EXITS ENCOUNTERED*/                                       02207940
 /*EXITLESS_ERASE:                                                              02207950
   PROCEDURE;                                                                   02207960
      DECLARE TEMP BIT(8);                                                      02207970
      DECLARE K BIT(16);                                                        02207980
      TEMP = 0;                                                                 02207990
      DO FOR K = 1 TO LEVEL;                                                    02208000
         TEMP = TEMP | STACK_TAGS(K);                                           02208010
      END;                                                                      02208020
      IF ^SHR(TEMP,1) THEN CALL ERASE_ZAPS;                                     02208030
   END EXITLESS_ERASE*/                                                         02208040
                                                                                02208050
                                                                                02208060
 /*MANAGES STACK IN IF THEN (ELSE)'S AND ALSO */                                02210910
 /* CHECKS BRA'S TO SEE IF THEY WERE GENERATED BY EXITS IN SIMPLE DO,ENDS*/     02211000
EXIT_CHECK:                                                                     02212000
   PROCEDURE(PTR);                                                              02213000
      DECLARE (PTR,I) BIT(16);                                                  02214000
      IF XHALMAT_QUAL(PTR + 1) = XINL THEN DO;                                  02215000
         IF SHR(OPR(PTR),24) THEN DO;    /* IF THEN ELSE*/                      02215010
            CALL POP_STACK;                                                     02215020
            CALL PUSH_STACK;                                                    02215030
            STACK_TAGS(LEVEL) = 1;   /* MULTICASE*/                             02215040
            CALL PUSH_ZAP_STACK;                                                02215050
            IF STACK_TRACE THEN CALL STACK_DUMP;                                02215060
         END;                                                                   02215070
                                                                                02215080
         ELSE DO;                                                               02215090
            PTR = SHR(OPR(PTR + 1),16);   /* BRANCH INX*/                       02216000
            I = DO_INX;                                                         02216010
            DO WHILE I > 0;                                                     02216020
               IF DO_LIST(I) = PTR THEN                                         02216030
                  DO_LIST(I) = -DO_LIST(I);                                     02216040
               I = I - 1;                                                       02216050
            END;                                                                02216060
            DO FOR I = 0 TO LEVEL;                                              02217000
               IF STACK_INL#(I) = PTR | STACK_INL#(I) = PTR - 1 THEN DO;        02217010
                  CALL ERASE_ZAPS;  /* FOR EXIT,REPEAT*/                        02217020
                IF STACK_INL#(I) = PTR THEN STACK_TAGS(I) = STACK_TAGS(I) | "2";02217030
                  RETURN;                                                       02221000
               END;                                                             02222000
            END;                                                                02223000
         END;                                                                   02224000
      END;                                                                      02225000
   END EXIT_CHECK;                                                              02226000
