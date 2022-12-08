 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COLLAPSE.xpl
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
 /* PROCEDURE NAME:  COLLAPSE_LITERALS                                      */
 /* MEMBER NAME:     COLLAPSE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          VAC_INX           BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TEMP              BIT(16)                                      */
 /*          NEW_LIT           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BIT_TYPE                                                       */
 /*          CSE2                                                           */
 /*          END_OF_NODE                                                    */
 /*          FNPARITY0#                                                     */
 /*          FNPARITY1#                                                     */
 /*          FOR                                                            */
 /*          HALMAT_NODE_START                                              */
 /*          HALMAT_PTR                                                     */
 /*          LITERAL                                                        */
 /*          MPARITY0#                                                      */
 /*          STATISTICS                                                     */
 /*          STT#                                                           */
 /*          TRACE                                                          */
 /*          WATCH                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CSE                                                            */
 /*          CSE_FOUND_INX                                                  */
 /*          FORWARD                                                        */
 /*          LITERAL_FOLDS                                                  */
 /*          N_INX                                                          */
 /*          NODE                                                           */
 /*          NODE2                                                          */
 /*          OPR                                                            */
 /*          REVERSE                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          COMBINED_LITERALS                                              */
 /*          COLLECT_MATCHES                                                */
 /*          CSE_WORD_FORMAT                                                */
 /*          PRINT_SENTENCE                                                 */
 /*          PUT_NOP                                                        */
 /*          REFERENCE                                                      */
 /* CALLED BY:                                                              */
 /*          GROW_TREE                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> COLLAPSE_LITERALS <==                                               */
 /*     ==> COMBINED_LITERALS                                               */
 /*         ==> HEX                                                         */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> MESSAGE_FORMAT                                              */
 /*             ==> HEX                                                     */
 /*         ==> GET_LITERAL                                                 */
 /*         ==> FILL_DW                                                     */
 /*             ==> GET_LITERAL                                             */
 /*         ==> SAVE_LITERAL                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> GET_LITERAL                                             */
 /*         ==> LIT_ARITHMETIC                                              */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*     ==> PRINT_SENTENCE                                                  */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*     ==> CSE_WORD_FORMAT                                                 */
 /*         ==> HEX                                                         */
 /*     ==> REFERENCE                                                       */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> TERMINAL                                                    */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> CLASSIFY                                                */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*     ==> PUT_NOP                                                         */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> CLASSIFY                                                    */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*         ==> TERMINAL                                                    */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> CLASSIFY                                                */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*     ==> COLLECT_MATCHES                                                 */
 /*         ==> PRINT_SENTENCE                                              */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*         ==> SET_HALMAT_FLAG                                             */
 /*         ==> FLAG_MATCHES                                                */
 /*             ==> PRINT_SENTENCE                                          */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*             ==> TYPE                                                    */
 /*             ==> FLAG_VAC_OR_LIT                                         */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> COMPARE_LITERALS                                    */
 /*                     ==> HEX                                             */
 /*                     ==> GET_LITERAL                                     */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> SET_FLAG                                            */
 /*             ==> FLAG_V_N                                                */
 /*                 ==> CATALOG_PTR                                         */
 /*                 ==> VALIDITY                                            */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> SET_FLAG                                            */
 /*         ==> FLAG_NODE                                                   */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> CLASSIFY                                                */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*             ==> TERMINAL                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> CLASSIFY                                            */
 /*                     ==> PRINT_SENTENCE                                  */
 /*                         ==> FORMAT                                      */
 /*                         ==> HEX                                         */
 /*             ==> SET_FLAG                                                */
 /*         ==> SET_WORDS                                                   */
 /*             ==> NEXT_FLAG                                               */
 /*                 ==> NO_OPERANDS                                         */
 /*             ==> FORM_OPERATOR                                           */
 /*                 ==> HEX                                                 */
 /*             ==> SET_VAC_REF                                             */
 /*                 ==> OPOP                                                */
 /*                 ==> ENTER                                               */
 /*             ==> FORCE_TERMINAL                                          */
 /*                 ==> NEXT_FLAG                                           */
 /*                     ==> NO_OPERANDS                                     */
 /*                 ==> SWITCH                                              */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> ENTER                                           */
 /*                     ==> LAST_OP                                         */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> MOVE_LIMB                                       */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> RELOCATE                                    */
 /*                         ==> MOVECODE                                    */
 /*                             ==> ENTER                                   */
 /*                     ==> NEXT_FLAG                                       */
 /*                         ==> NO_OPERANDS                                 */
 /*                 ==> TERMINAL                                            */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> CLASSIFY                                        */
 /*                         ==> PRINT_SENTENCE                              */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*             ==> PUSH_OPERAND                                            */
 /*                 ==> ENTER                                               */
 /*                 ==> HALMAT_FLAG                                         */
 /*                     ==> VAC_OR_XPT                                      */
 /*                 ==> NEXT_FLAG                                           */
 /*                     ==> NO_OPERANDS                                     */
 /*                 ==> TERMINAL                                            */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> CLASSIFY                                        */
 /*                         ==> PRINT_SENTENCE                              */
 /*                             ==> FORMAT                                  */
 /*                             ==> HEX                                     */
 /*             ==> FORCE_MATCH                                             */
 /*                 ==> NEXT_FLAG                                           */
 /*                     ==> NO_OPERANDS                                     */
 /*                 ==> SWITCH                                              */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> ENTER                                           */
 /*                     ==> LAST_OP                                         */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> HALMAT_FLAG                                     */
 /*                         ==> VAC_OR_XPT                                  */
 /*                     ==> MOVE_LIMB                                       */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> RELOCATE                                    */
 /*                         ==> MOVECODE                                    */
 /*                             ==> ENTER                                   */
 /*                     ==> NEXT_FLAG                                       */
 /*                         ==> NO_OPERANDS                                 */
 /***************************************************************************/
                                                                                03304000
 /* COMBINES LITERALS*/                                                         03305000
COLLAPSE_LITERALS:                                                              03306000
   PROCEDURE(VAC_INX);                                                          03307000
      DECLARE (VAC_INX,TEMP,NEW_LIT) BIT(16);                                   03308000
      IF TRACE THEN DO;                                                         03309000
         OUTPUT = 'COLLAPSE_LITERALS:  '||VAC_INX;                              03310000
         DO FOR TEMP = 1 TO CSE_FOUND_INX;                                      03311000
            OUTPUT = CSE_WORD_FORMAT(CSE(TEMP)) || ', CSE2:  ' || CSE2(TEMP);   03312000
         END;                                                                   03313000
      END;                                                                      03314000
      CSE_FOUND_INX = CSE_FOUND_INX + 1;                                        03315000
      CSE(CSE_FOUND_INX) = END_OF_NODE;                                         03316000
      IF ^BIT_TYPE THEN NEW_LIT = COMBINED_LITERALS(MPARITY0# = 0);             03317000
      ELSE NEW_LIT = 0;                                                         03318000
      IF NEW_LIT = 0 THEN DO;   DO FOR TEMP = 1 TO CSE_FOUND_INX - 1;           03319000
            NODE(N_INX) = CSE(TEMP);       /* RUN TIME ERROR*/                  03320000
         NODE2(N_INX) = CSE2(TEMP);                                             03321000
         N_INX = N_INX + 1;                                                     03322000
      END;  N_INX = N_INX - 1;    END;                                          03323000
         ELSE DO;                                                               03324000
         FORWARD = 1;                                                           03325000
         REVERSE = 0;                                                           03326000
         CALL COLLECT_MATCHES(NODE(VAC_INX) & "FFFF",FNPARITY0#,FNPARITY1#);    03327000
         CALL PUT_NOP(HALMAT_PTR);  /* ZERO OLD LITERALS*/                      03328000
         TEMP = REFERENCE(HALMAT_PTR);                                          03329000
         OPR(TEMP) = SHL(NEW_LIT,16) | "51";   /* NEW LIT POINTER*/             03330000
         NODE2(N_INX) = SHR(OPR(TEMP),16);                                      03331000
         NODE(N_INX) = LITERAL | SHL(MPARITY0# = 0,20);                         03332000
         IF WATCH THEN CALL PRINT_SENTENCE(HALMAT_NODE_START);                  03333000
         LITERAL_FOLDS = LITERAL_FOLDS + 1;                                     03334000
         IF STATISTICS THEN OUTPUT =                                            03335000
            'LITERAL FOLD FOUND IN HAL/S STATEMENT ' || STT#;                   03336000
      END;                                                                      03337000
   END COLLAPSE_LITERALS;                                                       03338000
