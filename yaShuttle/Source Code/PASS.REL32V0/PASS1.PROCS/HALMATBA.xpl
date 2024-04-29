 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HALMATBA.xpl
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
 /* PROCEDURE NAME:  HALMAT_BACKUP                                          */
 /* MEMBER NAME:     HALMATBA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          OLD_ATOM          FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          HALMAT_OK                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          NEXT_ATOM#                                                     */
 /* CALLED BY:                                                              */
 /*          END_ANY_FCN                                                    */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
HALMAT_BACKUP:                                                                  00803400
   PROCEDURE(OLD_ATOM);                                                         00803500
      DECLARE OLD_ATOM FIXED;                                                   00803600
      IF HALMAT_OK THEN NEXT_ATOM#=OLD_ATOM;                                    00803700
   END HALMAT_BACKUP;                                                           00803800
