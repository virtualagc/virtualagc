 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ZAPTABLE.xpl
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
 /* PROCEDURE NAME:  ZAP_TABLES                                             */
 /* MEMBER NAME:     ZAPTABLE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          MAJOR             BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FINAL_LEVEL       BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CSE_L_INX                                                      */
 /*          CSE_TAB_SIZE                                                   */
 /*          CTR                                                            */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          STACK_TAGS                                                     */
 /*          STACK_TRACE                                                    */
 /*          STACKED_BLOCK#                                                 */
 /*          STT#                                                           */
 /*          SYT_WORDS                                                      */
 /*          TRACE                                                          */
 /*          TSAPS                                                          */
 /*          VAL_ARRAY                                                      */
 /*          XSTACK_TAGS                                                    */
 /*          XSTACKED_BLOCK#                                                */
 /*          ZAPS                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BLOCK#                                                         */
 /*          FREE_BLOCK_BEGIN                                               */
 /*          FREE_SPACE                                                     */
 /*          LAST_SPACE_BLOCK                                               */
 /*          LAST_ZAP                                                       */
 /*          LEVEL                                                          */
 /*          LEVEL_STACK_VARS                                               */
 /*          MAX_CSE_TAB                                                    */
 /*          MAXNODE                                                        */
 /*          N_INX                                                          */
 /*          OBPS                                                           */
 /*          SEARCHABLE                                                     */
 /*          STILL_NODES                                                    */
 /*          SYT_USED                                                       */
 /*          VAL_TABLE                                                      */
 /*          ZAP_LEVEL                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CSE_TAB_DUMP                                                   */
 /*          FINAL_PASS                                                     */
 /*          RELOCATE_HALMAT                                                */
 /*          STACK_DUMP                                                     */
 /* CALLED BY:                                                              */
 /*          CHICKEN_OUT                                                    */
 /*          GROW_TREE                                                      */
 /*          OPTIMISE                                                       */
 /*          POP_STACK                                                      */
 /*          PRESCAN                                                        */
 /*          PROCESS_LABEL                                                  */
 /*          TERM_CHECK                                                     */
 /*          ZAP_VARS_BY_TYPE                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ZAP_TABLES <==                                                      */
 /*     ==> STACK_DUMP                                                      */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*     ==> CSE_TAB_DUMP                                                    */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*         ==> CATALOG_PTR                                                 */
 /*         ==> VALIDITY                                                    */
 /*         ==> CSE_WORD_FORMAT                                             */
 /*             ==> HEX                                                     */
 /*     ==> FINAL_PASS                                                      */
 /*         ==> GET_CLASS                                                   */
 /*         ==> OPOP                                                        */
 /*         ==> BUMP_D_N                                                    */
 /*         ==> S                                                           */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> NAME_OR_PARM                                                */
 /*         ==> ASSIGN_TYPE                                                 */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> LAST_OPERAND                                                */
 /*         ==> LOOP_OPERANDS                                               */
 /*             ==> GET_CLASS                                               */
 /*             ==> LAST_OPERAND                                            */
 /*         ==> EXTN_CHECK                                                  */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> NAME_OR_PARM                                            */
 /*         ==> BUMP_ADD                                                    */
 /*         ==> LOOPY                                                       */
 /*             ==> GET_CLASS                                               */
 /*             ==> XHALMAT_QUAL                                            */
 /*             ==> ASSIGN_TYPE                                             */
 /*             ==> NO_OPERANDS                                             */
 /*         ==> VM_DETAG                                                    */
 /*             ==> OPOP                                                    */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> TERMINAL                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> CLASSIFY                                            */
 /*                     ==> PRINT_SENTENCE                                  */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*             ==> LOOPY                                                   */
 /*                 ==> GET_CLASS                                           */
 /*                 ==> XHALMAT_QUAL                                        */
 /*                 ==> ASSIGN_TYPE                                         */
 /*                 ==> NO_OPERANDS                                         */
 /*         ==> INIT_ARCONFS                                                */
 /*         ==> C_STACK_DUMP                                                */
 /*             ==> FORMAT                                                  */
 /*         ==> CHECK_ADJACENT_LOOPS                                        */
 /*             ==> OPOP                                                    */
 /*             ==> LAST_OP                                                 */
 /*             ==> LAST_OPERAND                                            */
 /*         ==> PUSH_LOOP_STACKS                                            */
 /*             ==> INIT_ARCONFS                                            */
 /*             ==> CHECK_ADJACENT_LOOPS                                    */
 /*                 ==> OPOP                                                */
 /*                 ==> LAST_OP                                             */
 /*                 ==> LAST_OPERAND                                        */
 /*             ==> MOVE_LOOP_STACK                                         */
 /*             ==> BUMP_LOOPSTACK                                          */
 /*         ==> POP_LOOP_STACKS                                             */
 /*             ==> MOVE_LOOP_STACK                                         */
 /*         ==> COMBINE_LOOPS                                               */
 /*             ==> VU                                                      */
 /*                 ==> HEX                                                 */
 /*         ==> DENEST                                                      */
 /*             ==> VU                                                      */
 /*                 ==> HEX                                                 */
 /*             ==> POP_LOOP_STACKS                                         */
 /*                 ==> MOVE_LOOP_STACK                                     */
 /*             ==> MULTIPLY_DIMS                                           */
 /*                 ==> VU                                                  */
 /*                     ==> HEX                                             */
 /*         ==> CHECK_ARRAYNESS                                             */
 /*             ==> SET_VAR                                                 */
 /*                 ==> XHALMAT_QUAL                                        */
 /*                 ==> LAST_OPERAND                                        */
 /*             ==> LOOPY                                                   */
 /*                 ==> GET_CLASS                                           */
 /*                 ==> XHALMAT_QUAL                                        */
 /*                 ==> ASSIGN_TYPE                                         */
 /*                 ==> NO_OPERANDS                                         */
 /*             ==> BUMP_REF_OPS                                            */
 /*                 ==> POP_COMPARE                                         */
 /*                     ==> XHALMAT_QUAL                                    */
 /*                     ==> NO_OPERANDS                                     */
 /*         ==> SET_LOOP_END                                                */
 /*         ==> PUSH_VM_STACK                                               */
 /*             ==> MOVE_LOOP_STACK                                         */
 /*         ==> CHECK_VM_COMBINE                                            */
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
 /*             ==> POP_LOOP_STACKS                                         */
 /*                 ==> MOVE_LOOP_STACK                                     */
 /*             ==> COMBINE_LOOPS                                           */
 /*                 ==> VU                                                  */
 /*                     ==> HEX                                             */
 /*         ==> CHECK_LIST                                                  */
 /*             ==> FORMAT                                                  */
 /*             ==> OPOP                                                    */
 /*             ==> SET_V_M_TAGS                                            */
 /*                 ==> LAST_OPERAND                                        */
 /*         ==> EMPTY_ARRAY                                                 */
 /*             ==> OPOP                                                    */
 /*             ==> LAST_OPERAND                                            */
 /*     ==> RELOCATE_HALMAT                                                 */
 /*         ==> HEX                                                         */
 /*         ==> OPOP                                                        */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> LAST_OP                                                     */
 /*         ==> TWIN_HALMATTED                                              */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> DETAG                                                       */
 /*         ==> REFERENCE                                                   */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> TERMINAL                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> CLASSIFY                                            */
 /*                     ==> PRINT_SENTENCE                                  */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /***************************************************************************/
                                                                                01965010
                                                                                01965100
                                                                                01966000
 /*DELETES ALL INFORMATION IN CSE TABLES*/                                      01967000
ZAP_TABLES:                                                                     01968000
   PROCEDURE(MAJOR);                                                            01969000
      DECLARE MAJOR BIT(8);                                                     01969010
      DECLARE FINAL_LEVEL BIT(16);                                              01969020
      DECLARE K BIT(16);                                                        01970100
      IF STACK_TRACE THEN OUTPUT =                                              01971000
         'ZAP_TABLES('||MAJOR||'):  '||STT#;                                    01971010
      IF MAJOR THEN DO;                                                         01972000
         FINAL_LEVEL = 0;                                                       01972010
         ZAP_LEVEL = 0;                                                         01972020
      END;                                                                      01972060
      ELSE FINAL_LEVEL = LEVEL;                                                 01972070
                                                                                01972080
      ZAPS(0) = 1; /*SET RIGHT BIT TO INDICATE ZAP TAKEN PLACE */               01972090
                                                                                01972100
      DO WHILE LEVEL > FINAL_LEVEL;  /* NEEDED FOR MAJOR ZAPS*/                 01972110
         DO FOR K = 0 TO SYT_WORDS;                                             01972120
            VAL_TABLE(LEVEL).VAL_ARRAY(K) = 0;                                  01972130
         END;                                                                   01972140
         STACK_TAGS(LEVEL) = STACK_TAGS(LEVEL) & "1";                           01972150
         LEVEL = LEVEL - 1;                                                     01972160
      END;                                                                      01972170
      DO FOR K = 0 TO SYT_WORDS;                                                01972180
         VAL_TABLE(LEVEL).VAL_ARRAY(K) = 0;                                     01972181
      END;                                                                      01972182
      BLOCK# = STACKED_BLOCK#(LEVEL);                                           01972190
                                                                                01974000
      IF LEVEL = 0 THEN DO;                                                     01974010
                                                                                01974020
         IF N_INX ^= 1 THEN DO;                                                 01978000
            IF STACK_TRACE THEN DO;                                             01979000
               CALL CSE_TAB_DUMP;                                               01980000
            END;                                                                01981000
            IF MAX_CSE_TAB < FREE_BLOCK_BEGIN THEN                              01982000
               MAX_CSE_TAB = FREE_BLOCK_BEGIN;       /* STATISTICS*/            01983000
            IF N_INX > MAXNODE THEN MAXNODE = N_INX;                            01984000
            LAST_SPACE_BLOCK = 0;                                               01985000
            FREE_SPACE = CSE_TAB_SIZE;                                          01986000
            FREE_BLOCK_BEGIN = 1;      /*DELETE CSE_TAB*/                       01987000
            IF CSE_L_INX ^= 0 THEN CALL RELOCATE_HALMAT;                        01988000
         END;                                                                   01990000
         SYT_USED = 0;   /* ALL SYMBOLS NOW INVALID*/                           01990001
         CALL FINAL_PASS;                                                       01990010
         LAST_ZAP = CTR;                                                        01990020
         N_INX = 1;       /* DELETE NODE LIST*/                                 01990040
      END;                                                                      01990050
      ELSE IF TRACE THEN CALL CSE_TAB_DUMP;                                     01990060
                                                                                01990070
      MAJOR = 0;                                                                01990080
      STILL_NODES,SEARCHABLE=FALSE;                                             01991000
      IF STACK_TRACE THEN CALL STACK_DUMP;                                      01991010
   END ZAP_TABLES;                                                              01992000
