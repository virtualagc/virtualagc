 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SKIP.xpl
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
/* PROCEDURE NAME:  SKIP                                                   */
/* MEMBER NAME:     SKIP                                                   */
/* INPUT PARAMETERS:                                                       */
/*          N                 BIT(16)                                      */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          CODE_LINE                                                      */
/* CALLED BY:                                                              */
/*          OBJECT_CONDENSER                                               */
/*          OBJECT_GENERATOR                                               */
/*          SKIP_ADDR                                                      */
/***************************************************************************/
                                                                                07144000
 /* ROUTINE TO PASS OVER A SPECIFIED NUMBER OF CODE LINES */                    07144500
SKIP:                                                                           07145000
   PROCEDURE(N);                                                                07145500
      DECLARE N BIT(16);                                                        07146000
      CODE_LINE = CODE_LINE + N;                                                07146500
   END SKIP;                                                                    07147000
