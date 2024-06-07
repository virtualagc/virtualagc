 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   REVERSEP.xpl
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
 /* PROCEDURE NAME:  REVERSE_PARITY                                         */
 /* MEMBER NAME:     REVERSEP                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          WORD              FIXED                                        */
 /* CALLED BY:                                                              */
 /*          STRIP_NODES                                                    */
 /***************************************************************************/
                                                                                01478000
 /* REVERSES PARITY BIT OF WORD IN CSE FORMAT*/                                 01479000
REVERSE_PARITY:                                                                 01480000
   PROCEDURE(WORD);                                                             01481000
      DECLARE WORD FIXED;                                                       01482000
      RETURN (WORD & "FFEF FFFF") | ^WORD & "10 0000";                          01483000
   END REVERSE_PARITY;                                                          01484000
