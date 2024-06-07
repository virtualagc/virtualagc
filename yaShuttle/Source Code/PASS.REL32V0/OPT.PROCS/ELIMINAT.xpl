 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ELIMINAT.xpl
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
 /* PROCEDURE NAME:  ELIMINATE_DIVIDES                                      */
 /* MEMBER NAME:     ELIMINAT                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CSE_FOUND_INX                                                  */
 /*          EON_PTR                                                        */
 /*          FALSE                                                          */
 /*          FNPARITY1#                                                     */
 /*          HALMAT_NODE_START                                              */
 /*          N_INX                                                          */
 /*          NODE                                                           */
 /*          STATISTICS                                                     */
 /*          STT#                                                           */
 /*          WATCH                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FORWARD                                                        */
 /*          DIVISION_ELIMINATIONS                                          */
 /*          MPARITY0#                                                      */
 /*          MPARITY1#                                                      */
 /*          REVERSE                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          PRINT_SENTENCE                                                 */
 /*          COLLECT_MATCHES                                                */
 /* CALLED BY:                                                              */
 /*          GROW_TREE                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ELIMINATE_DIVIDES <==                                               */
 /*     ==> PRINT_SENTENCE                                                  */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
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
                                                                                03290000
 /* ROUTINE TO ELIMINATE ALL BUT ONE DIVIDE FROM SSPR NODE*/                    03291000
ELIMINATE_DIVIDES:                                                              03292000
   PROCEDURE;                                                                   03293000
      MPARITY1# = FNPARITY1#;                                                   03294000
      MPARITY0# = N_INX - EON_PTR - 1 + CSE_FOUND_INX - FNPARITY1#;             03295000
 /* WANT THINGS GROUPED LIKE THE CSE PART, BUT WITHOUT FLAGS*/                  03296000
      FORWARD,REVERSE = FALSE;                                                  03297000
      CALL COLLECT_MATCHES(NODE(EON_PTR - 1) & "FFFF",0,0,1);                   03298000
      IF WATCH THEN CALL PRINT_SENTENCE(HALMAT_NODE_START);                     03299000
      DIVISION_ELIMINATIONS = DIVISION_ELIMINATIONS + 1;                        03300000
      IF STATISTICS THEN OUTPUT =                                               03301000
         'DIVISION ELIMINATION FOUND IN HAL/S STATEMENT '||STT#;                03302000
   END ELIMINATE_DIVIDES;                                                       03303000
