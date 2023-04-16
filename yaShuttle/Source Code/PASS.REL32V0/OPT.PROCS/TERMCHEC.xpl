 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   TERMCHEC.xpl
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
 /* PROCEDURE NAME:  TERM_CHECK                                             */
 /* MEMBER NAME:     TERMCHEC                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          ST_PTR            BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          MAJ_STRUCT                                                     */
 /*          OPR                                                            */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LAST_OPERAND                                                   */
 /*          NAME_CHECK                                                     */
 /*          ZAP_TABLES                                                     */
 /* CALLED BY:                                                              */
 /*          ST_CHECK                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> TERM_CHECK <==                                                      */
 /*     ==> LAST_OPERAND                                                    */
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
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*02/10/95 DAS   27V0/ 103787 WRONG VALUE LOADED FROM REGISTER FOR A       */
 /*               11V0         STRUCTURE NODE REFERENCE                     */
 /*                                                                         */
 /***************************************************************************/
                                                                                02015000
 /* HANDLES MINOR STRUCTURES AND STRUCT TEMPLATES*/                             02016000
TERM_CHECK:                                                                     02017000
   PROCEDURE(PTR,ST_PTR) BIT(8);                                                02018000
      DECLARE (PTR,ST_PTR) BIT(16);                                             02019000
      IF NAME_CHECK(ST_PTR,1) THEN RETURN 1;                                    02020000
      PTR = LAST_OPERAND(PTR);                                                  02021000
      /* DR103787: CHECK MINOR NODE NAME DEREF ACCORDING TO HIGHOPT: */         02021000
      /*   (0) CHECK FOR ANY MINOR NODE NAME DEREFERENCE TO CATCH */            02021000
      /*       WHEN MINOR NAME STRUC POINTS TO DIFFERENT TEMPLATE */            02021000
      /*   (1) NO CHECK: ASSUME POINTS TO SAME TEMPLATE.          */            02021000
      /*  (SYMS ARE NODES, OTHER TYPES ARE SUBSCRIPTS, ETC) */                  02021000
      IF ^HIGHOPT THEN DO;                         /*DR103787*/                 02021000
         ST_PTR = ST_PTR + 1;                      /*DR103787*/                 02021000
         DO WHILE ST_PTR < PTR;                    /*DR103787*/
            IF (SHR(OPR(ST_PTR),4) & "F") = SYM    /*DR103787*/                 02020000
               THEN DO;                            /*DR103787*/                 02020000
                  IF NAME_CHECK(ST_PTR,1)          /*DR103787*/                 02020000
                     THEN RETURN 1;                /*DR103787*/                 02020000
               END;                                /*DR103787*/                 02020000
            ST_PTR = ST_PTR + 1;                   /*DR103787*/                 02020000
         END;                                      /*DR103787*/                 02020000
      END;                                         /*DR103787*/                 02020000
                                                                                02023000
      IF SYT_TYPE(SHR(OPR(PTR),16)) < MAJ_STRUCT THEN                           02021010
         RETURN NAME_CHECK(PTR,0);                                              02021020
                                                                                02023000
 /* WIPE OUT EVERYTHING IF ASSIGN TO A NON-TERMINAL*/                           02024000
                                                                                02025000
      ELSE DO;                                                                  02026000
         CALL ZAP_TABLES;                                                       02027000
         RETURN 1;                                                              02028000
      END;                                                                      02029000
      RETURN 0;                                                                 02030000
   END TERM_CHECK;                                                              02031000
