 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   UNSPEC.xpl
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
/* PROCEDURE NAME:  UNSPEC                                                 */
/* MEMBER NAME:     UNSPEC                                                 */
/* FUNCTION RETURN TYPE:                                                   */
/*          FIXED                                                          */
/* INPUT PARAMETERS:                                                       */
/*          F                 FIXED                                        */
/* CALLED BY:                                                              */
/*          INITIALISE                                                     */
/***************************************************************************/
                                                                                00929760
                                                                                00930000
 /* ROUTINE TO CREATE A POINTER OUT OF A DESCRIPTOR */                          00930500
UNSPEC:                                                                         00931000
   PROCEDURE(F) FIXED;                                                          00931500
      DECLARE F FIXED;                                                          00932000
      RETURN F;                                                                 00932500
   END UNSPEC;                                                                  00933000
