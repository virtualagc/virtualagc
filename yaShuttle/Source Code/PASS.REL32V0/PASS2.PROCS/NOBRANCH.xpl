 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NOBRANCH.xpl
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
/* PROCEDURE NAME:  NO_BRANCH_AROUND                                       */
/* MEMBER NAME:     NOBRANCH                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          FIXED                                                          */
/* INPUT PARAMETERS:                                                       */
/*          LINE              FIXED                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          SAVE_LINE         FIXED                                        */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CODE_LINE                                                      */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          EMIT_NOP                                                       */
/* CALLED BY:                                                              */
/*          NEED_STACK                                                     */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> NO_BRANCH_AROUND <==                                                */
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
                                                                                00786690
 /* ROUTINE TO OMIT PREVIOUSLY SPECIFIED BRANCH AROUND */                       00786695
NO_BRANCH_AROUND:                                                               00786700
   PROCEDURE(LINE) FIXED;                                                       00786705
      DECLARE (LINE, SAVE_LINE) FIXED;                                          00786710
      IF LINE > 0 THEN DO;                                                      00786715
         SAVE_LINE = CODE_LINE;  CODE_LINE = LINE;                              00786720
            CALL EMIT_NOP;                                                      00786725
         CODE_LINE = SAVE_LINE;                                                 00786730
      END;                                                                      00786735
      RETURN 0;                                                                 00786740
   END NO_BRANCH_AROUND;                                                        00786745
