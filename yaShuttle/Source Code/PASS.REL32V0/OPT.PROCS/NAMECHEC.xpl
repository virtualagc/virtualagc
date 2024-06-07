 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NAMECHEC.xpl
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
 /* PROCEDURE NAME:  NAME_CHECK                                             */
 /* MEMBER NAME:     NAMECHEC                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          KEEP_VALIDITY     BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          SYB_PTR           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          NAME_OR_PARM_FLAG                                              */
 /*          OPR                                                            */
 /*          SYM_FLAGS                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_FLAGS                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          SET_VALIDITY                                                   */
 /*          ZAP_VARS_BY_TYPE                                               */
 /* CALLED BY:                                                              */
 /*          TERM_CHECK                                                     */
 /*          ASSIGNMENT                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> NAME_CHECK <==                                                      */
 /*     ==> SET_VALIDITY                                                    */
 /*     ==> ZAP_VARS_BY_TYPE                                                */
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
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*02/10/95 DAS   27V0/ 103787 WRONG VALUE LOADED FROM REGISTER FOR A       */
 /*               11V0         STRUCTURE NODE REFERENCE                     */
 /*                                                                         */
 /***************************************************************************/
                                                                                01994200
NAME_CHECK:                                                                     02002000
   PROCEDURE(PTR,KEEP_VALIDITY) BIT(8);                                         02003000
      DECLARE KEEP_VALIDITY BIT(8);                                             02004000
      DECLARE(PTR,SYB_PTR) BIT(16);                                             02005000
      SYB_PTR = SHR(OPR(PTR),16);                                               02006000
      IF (SYT_FLAGS(SYB_PTR) & NAME_OR_PARM_FLAG) ^= 0 THEN DO;                 02007000
         /* DR103787 - CLEAR CSES ACCORDING TO HIGHOPT OPTION:        */        02008000
         /* DR103787 - (0) CLEAR ALL TYPES                            */        02008000
         /* DR103787 - (1) CLEAR SAME TYPE AS NAME                    */        02008000
         IF ^HIGHOPT THEN                    /*DR103787*/                       02008000
            CALL ZAP_TABLES;                 /*DR103787*/                       02008000
         ELSE                                /*DR103787*/                       02008000
            CALL ZAP_VARS_BY_TYPE(SYB_PTR);  /*DR103787*/                       02008000
         RETURN 1;                                                              02009000
      END;                                                                      02010000
      IF ^KEEP_VALIDITY THEN                                                    02011000
         CALL SET_VALIDITY(SYB_PTR,FALSE);                                      02012000
      RETURN 0;                                                                 02013000
   END;                                                                         02014000
