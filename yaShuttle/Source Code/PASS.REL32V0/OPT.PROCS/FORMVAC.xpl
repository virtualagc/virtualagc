 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMVAC.xpl
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
 /* PROCEDURE NAME:  FORM_VAC                                               */
 /* MEMBER NAME:     FORMVAC                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          PARITY            BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TMP               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          TERMINAL_VAC                                                   */
 /* CALLED BY:                                                              */
 /*          GROW_TREE                                                      */
 /***************************************************************************/
                                                                                01705000
                                                                                01706000
 /*FORMATS A "VAC" TERMINAL NODE ON LIST*/                                      01707000
FORM_VAC:                                                                       01708000
   PROCEDURE(PTR,PARITY);                                                       01709000
      DECLARE TMP FIXED;                                                        01710000
      DECLARE PTR BIT(16);                                                      01711000
      DECLARE PARITY BIT(8);                                                    01712000
      TMP = TERMINAL_VAC | PTR | SHL(PARITY,20);                                01713000
      PARITY = 0;                                                               01714000
      RETURN TMP;                                                               01715000
   END FORM_VAC;                                                                01716000
