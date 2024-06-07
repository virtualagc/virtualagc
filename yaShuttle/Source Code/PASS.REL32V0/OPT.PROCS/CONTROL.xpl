 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CONTROL.xpl
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
 /* PROCEDURE NAME:  CONTROL                                                */
 /* MEMBER NAME:     CONTROL                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          CSE_WORD          FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CONTROL_MASK                                                   */
 /* CALLED BY:                                                              */
 /*          SETUP_REVERSE_COMPARE                                          */
 /*          GET_NODE                                                       */
 /***************************************************************************/
                                                                                01471000
 /* RETURNS UNSHIFTED CONTROL BITS OF CSE FORMATTED WORD*/                      01472000
CONTROL:                                                                        01473000
   PROCEDURE(CSE_WORD) ;                                                        01474000
      DECLARE CSE_WORD FIXED;                                                   01475000
      RETURN CSE_WORD & CONTROL_MASK;                                           01476000
   END CONTROL;                                                                 01477000
