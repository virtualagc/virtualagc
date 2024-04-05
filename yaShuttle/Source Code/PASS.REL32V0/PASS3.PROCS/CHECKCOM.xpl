 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKCOM.xpl
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
 /* PROCEDURE NAME:  CHECK_COMPOUND                                         */
 /* MEMBER NAME:     CHECKCOM                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LHSSAVE                                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LHS_TAB                                                        */
 /*          TZCOUNT                                                        */
 /* CALLED BY:                                                              */
 /*          GET_STMT_DATA                                                  */
 /***************************************************************************/
                                                                                00204100
                                                                                00205600
 /* ROUTINE TO COMPLETE LHS INFO FOR COMPOUND STRUCTURE NAMES */                00205700
                                                                                00205800
CHECK_COMPOUND:                                                                 00205900
   PROCEDURE;                                                                   00206000
      IF TZCOUNT > 0 THEN DO;                                                   00206100
         LHS_TAB(LHSSAVE) = -TZCOUNT;                                           00206200
         TZCOUNT = 0;                                                           00206300
      END;                                                                      00206400
   END CHECK_COMPOUND;                                                          00206600
