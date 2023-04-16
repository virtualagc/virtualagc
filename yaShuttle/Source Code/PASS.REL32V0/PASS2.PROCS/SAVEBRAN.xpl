 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SAVEBRAN.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

/***************************************************************************/
/* PROCEDURE NAME:  SAVE_BRANCH_AROUND                                     */
/* MEMBER NAME:     SAVEBRAN                                               */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          INDEXNEST                                                      */
/*          CODE_LINE                                                      */
/*          LOCCTR                                                         */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          SAVE_LOCCTR                                                    */
/*          SAVE_CODE_LINE                                                 */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          EMIT_NOP                                                       */
/* CALLED BY:                                                              */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> SAVE_BRANCH_AROUND <==                                              */
/*     ==> EMIT_NOP                                                        */
/*         ==> EMITC                                                       */
/*             ==> FORMAT                                                  */
/*             ==> HEX                                                     */
/*             ==> HEX_LOCCTR                                              */
/*                 ==> HEX                                                 */
/*             ==> GET_CODE                                                */
/*         ==> EMITW                                                       */
/*             ==> HEX                                                     */
/*             ==> HEX_LOCCTR                                              */
/*                 ==> HEX                                                 */
/*             ==> GET_CODE                                                */
/***************************************************************************/
                                                                                00786575
 /* ROUTINE TO SET_ASIDE CODE SPACE FOR BRANCH AROUND CODE */                   00786580
SAVE_BRANCH_AROUND:                                                             00786585
   PROCEDURE;                                                                   00786590
      SAVE_LOCCTR = LOCCTR(INDEXNEST);                                          00786595
      SAVE_CODE_LINE = CODE_LINE;                                               00786600
      CALL EMIT_NOP;                                                            00786605
   END SAVE_BRANCH_AROUND;                                                      00786610
