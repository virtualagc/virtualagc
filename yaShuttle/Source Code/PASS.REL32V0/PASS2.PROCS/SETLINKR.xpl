 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETLINKR.xpl
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
/* PROCEDURE NAME:  SET_LINKREG                                            */
/* MEMBER NAME:     SETLINKR                                               */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          LINKREG                                                        */
/*          NARGINDEX                                                      */
/*          NOT_LEAF                                                       */
/*          OFFSET                                                         */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          USAGE                                                          */
/*          R_CONTENTS                                                     */
/*          USAGE_LINE                                                     */
/* CALLED BY:                                                              */
/*          CLEAR_REGS                                                     */
/*          GENERATE                                                       */
/***************************************************************************/
                                                                                00686500
 /* ROUTINE TO HOLD UP ALLOCATION OF LINKREG IF LEAF PROCEDURE */               00687000
SET_LINKREG:                                                                    00687500
   PROCEDURE;                                                                   00688000
      IF NOT_LEAF(NARGINDEX) THEN                                               00688500
         USAGE(LINKREG) = 0;                                                    00689000
      ELSE DO;                                                                  00689500
         USAGE(LINKREG) = 1;  USAGE_LINE(LINKREG) = -1;                           690000
            R_CONTENTS(LINKREG) = OFFSET;  /* TO INHIBIT USE OF LINKREG */      00690500
      END;                                                                      00691000
   END SET_LINKREG;                                                             00691500
