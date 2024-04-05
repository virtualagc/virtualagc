 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMITNOP.xpl
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
/* PROCEDURE NAME:  EMIT_NOP                                               */
/* MEMBER NAME:     EMITNOP                                                */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          NOP                                                            */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          EMITC                                                          */
/*          EMITW                                                          */
/* CALLED BY:                                                              */
/*          NO_BRANCH_AROUND                                               */
/*          GENERATE                                                       */
/*          SAVE_BRANCH_AROUND                                             */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> EMIT_NOP <==                                                        */
/*     ==> EMITC                                                           */
/*         ==> FORMAT                                                      */
/*         ==> HEX                                                         */
/*         ==> HEX_LOCCTR                                                  */
/*             ==> HEX                                                     */
/*         ==> GET_CODE                                                    */
/*     ==> EMITW                                                           */
/*         ==> HEX                                                         */
/*         ==> HEX_LOCCTR                                                  */
/*             ==> HEX                                                     */
/*         ==> GET_CODE                                                    */
/***************************************************************************/
                                                                                00786510
 /* ROUTINE TO EMIT NOPS INTO THE CODE STREAM */                                00786520
EMIT_NOP:                                                                       00786530
   PROCEDURE;                                                                   00786540
      CALL EMITC(NOP, 0);                                                       00786550
      CALL EMITW(0, 1);                                                         00786560
   END EMIT_NOP;                                                                00786570
