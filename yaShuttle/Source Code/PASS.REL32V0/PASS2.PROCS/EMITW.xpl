 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMITW.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

/***************************************************************************/
/* PROCEDURE NAME:  EMITW                                                  */
/* MEMBER NAME:     EMITW                                                  */
/* INPUT PARAMETERS:                                                       */
/*          DATA              FIXED                                        */
/*          MODIFIER          BIT(8)                                       */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          BINARY_CODE                                                    */
/*          FALSE                                                          */
/*          INDEXNEST                                                      */
/*          X3                                                             */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CODE_LINE                                                      */
/*          CODE                                                           */
/*          LOCCTR                                                         */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          HEX                                                            */
/*          GET_CODE                                                       */
/*          HEX_LOCCTR                                                     */
/* CALLED BY:                                                              */
/*          EMIT_BRANCH_AROUND                                             */
/*          EMIT_NOP                                                       */
/*          EMITADDR                                                       */
/*          EMITSTRING                                                     */
/*          GENERATE                                                       */
/*          GENERATE_CONSTANTS                                             */
/*          SET_LOCCTR                                                     */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> EMITW <==                                                           */
/*     ==> HEX                                                             */
/*     ==> HEX_LOCCTR                                                      */
/*         ==> HEX                                                         */
/*     ==> GET_CODE                                                        */
/***************************************************************************/
                                                                                00727500
 /* ROUTINE TO EMIT DATA WORDS ONTO CODE FILE  */                               00728000
EMITW:                                                                          00728500
   PROCEDURE(DATA, MODIFIER);                                                   00729000
      DECLARE DATA FIXED, MODIFIER BIT(1);                                      00729500
      CODE(GET_CODE(CODE_LINE)) = DATA;                                         00730000
      IF BINARY_CODE THEN DO;                                                   00730500
         OUTPUT = HEX_LOCCTR || X3 || HEX(DATA, 8);                             00731000
      END;                                                                      00731500
      IF ^MODIFIER THEN LOCCTR(INDEXNEST) = LOCCTR(INDEXNEST) + 2;              00732000
      MODIFIER = FALSE;                                                         00732500
      CODE_LINE = CODE_LINE + 1;                                                00733000
   END EMITW;                                                                   00733500
