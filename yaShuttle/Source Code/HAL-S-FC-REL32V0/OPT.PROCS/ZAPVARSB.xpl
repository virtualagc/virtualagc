 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ZAPVARSB.xpl
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
 /* PROCEDURE NAME:  ZAP_VARS_BY_TYPE                                       */
 /* MEMBER NAME:     ZAPVARSB                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          SYB_PTR           BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /*          BASE              BIT(16)                                      */
 /*          TYPE              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FOR                                                            */
 /*          INT_VAR                                                        */
 /*          LEVEL                                                          */
 /*          OR                                                             */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          SYT_USED                                                       */
 /*          SYT_WORDS                                                      */
 /*          TSAPS                                                          */
 /*          TYPE_ZAP                                                       */
 /*          VAL_ARRAY                                                      */
 /*          VALIDITY_ARRAY                                                 */
 /*          ZAP_LEVEL                                                      */
 /*          ZAPIT                                                          */
 /*          ZAPS                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          VAL_TABLE                                                      */
 /*          OBPS                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ZAP_TABLES                                                     */
 /* CALLED BY:                                                              */
 /*          NAME_CHECK                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ZAP_VARS_BY_TYPE <==                                                */
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
 /***************************************************************************/
                                                                                01993000
                                                                                01994000
                                                                                01994010
 /* ZAPS EVERYTHING OF SAME TYPE.  IF VECTOR TYPE, ALSO ZAPS MATRICES.          01994020
         IF SCALAR TYPE, ZAPS ALL THREE TYPE VARS*/                             01994030
ZAP_VARS_BY_TYPE:                                                               01994040
   PROCEDURE(SYB_PTR);                                                          01994050
      DECLARE (SYB_PTR,TYPE,K,BASE) BIT(16);                                    01994060
      TYPE = SYT_TYPE(SYB_PTR);                                                 01994070
      IF TYPE <= 0 OR TYPE > INT_VAR THEN CALL ZAP_TABLES;                      01994080
      ELSE DO;                                                                  01994090
         BASE = TYPE - 1;                                                       01994100
                                                                                01994110
         DO FOR K = 0 TO SYT_WORDS;                                             01994120
            VALIDITY_ARRAY(K) = VALIDITY_ARRAY(K)                               01994130
               & ^(ZAPIT(BASE).TYPE_ZAP(K));                                    01994140
            ZAPS(K) = ZAPS(K) | ZAPIT(BASE).TYPE_ZAP(K);                        01994141
         END;                                                                   01994160
                                                                                01994170
      END;                                                                      01994180
   END ZAP_VARS_BY_TYPE;                                                        01994190
