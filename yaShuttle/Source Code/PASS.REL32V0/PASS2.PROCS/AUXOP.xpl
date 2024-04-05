 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   AUXOP.xpl
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
/* PROCEDURE NAME:  AUX_OP                                                 */
/* MEMBER NAME:     AUXOP                                                  */
/* INPUT PARAMETERS:                                                       */
/*          CTR               FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          AUX                                                            */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          GET_AUX                                                        */
/* CALLED BY:                                                              */
/*          AUX_SYNC                                                       */
/*          GENERATE                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> AUX_OP <==                                                          */
/*     ==> GET_AUX                                                         */
/***************************************************************************/
                                                                                  637020
 /* PROCEDURE TO EXTRACT AUXILIARY HALMAT OPCODE */                               637040
AUX_OP:                                                                           637060
   PROCEDURE(CTR);                                                                637080
      DECLARE CTR FIXED;                                                          637100
      RETURN SHR(AUX(GET_AUX(CTR)),1) & "F";                                      637120
   END AUX_OP;                                                                    637140
