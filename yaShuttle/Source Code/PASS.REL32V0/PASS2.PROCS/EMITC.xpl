 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMITC.xpl
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
/* PROCEDURE NAME:  EMITC                                                  */
/* MEMBER NAME:     EMITC                                                  */
/* INPUT PARAMETERS:                                                       */
/*          TYPE              BIT(16)                                      */
/*          INST              BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          BINARY_CODE                                                    */
/*          COMMA                                                          */
/*          FALSE                                                          */
/*          INDEXNEST                                                      */
/*          NOT_MODIFIER                                                   */
/*          X3                                                             */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CODE_LINE                                                      */
/*          CODE                                                           */
/*          LOCCTR                                                         */
/*          MESSAGE                                                        */
/*          STOPPERFLAG                                                    */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          FORMAT                                                         */
/*          GET_CODE                                                       */
/*          HEX                                                            */
/*          HEX_LOCCTR                                                     */
/* CALLED BY:                                                              */
/*          BOUNDARY_ALIGN                                                 */
/*          EMIT_BRANCH_AROUND                                             */
/*          EMIT_NOP                                                       */
/*          EMITADDR                                                       */
/*          EMITSTRING                                                     */
/*          GENERATE                                                       */
/*          GENERATE_CONSTANTS                                             */
/*          OPTIMISE                                                       */
/*          SET_LOCCTR                                                     */
/*          TERMINATE                                                      */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> EMITC <==                                                           */
/*     ==> FORMAT                                                          */
/*     ==> HEX                                                             */
/*     ==> HEX_LOCCTR                                                      */
/*         ==> HEX                                                         */
/*     ==> GET_CODE                                                        */
/***************************************************************************/
                                                                                00714500
 /* SUBROUTINE TO EMIT THE BASIC INTERMEDIATE FORMS  */                         00719500
EMITC:                                                                          00720000
   PROCEDURE(TYPE, INST);                                                       00720500
      DECLARE (TYPE, INST) BIT(16);                                             00721000
      CODE(GET_CODE(CODE_LINE)) = SHL(TYPE, 16) | INST & "FFFF";                00721500
      IF BINARY_CODE THEN DO;                                                   00722000
         MESSAGE = HEX(INST&"FFFF", 4);                                         00722500
         MESSAGE = FORMAT(TYPE, 6) || COMMA || X3 || MESSAGE;                   00723000
         OUTPUT = HEX_LOCCTR || MESSAGE;                                        00723500
      END;                                                                      00724000
      IF NOT_MODIFIER(TYPE) THEN DO;                                            00724500
         LOCCTR(INDEXNEST) = LOCCTR(INDEXNEST) + 1;                             00725000
         STOPPERFLAG = FALSE;                                                   00725500
      END;                                                                      00726000
      CODE_LINE = CODE_LINE + 1;                                                00726500
   END EMITC;                                                                   00727000
