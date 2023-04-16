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
 /*          STR               FIXED                                        */
 /* CALLED BY:                                                              */
 /*          INITIALIZATION                                                 */
 /***************************************************************************/
                                                                                00265200
                                                                                00265300
UNSPEC:                                                                         00265400
   PROCEDURE(STR) FIXED;                                                        00265500
      DECLARE STR FIXED;                                                        00265600
      RETURN STR;                                                               00265700
   END UNSPEC;                                                                  00265800
