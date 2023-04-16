 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HASH.xpl
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
/* PROCEDURE NAME:  HASH                                                   */
/* MEMBER NAME:     HASH                                                   */
/* INPUT PARAMETERS:                                                       */
/*          NAME              CHARACTER;                                   */
/* LOCAL DECLARATIONS:                                                     */
/*          HASHIT            FIXED                                        */
/*          I                 FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          HASHSIZE                                                       */
/* CALLED BY:                                                              */
/*          LIB_LOOK                                                       */
/*          GENERATE                                                       */
/***************************************************************************/
                                                                                00589500
 /* ROUTINE TO HASH-CODE EXTERNAL SYMBOLS TO SPEED UP SEARCHING */              00590000
HASH:                                                                           00590500
   PROCEDURE(NAME);                                                             00591000
      DECLARE NAME CHARACTER, (HASHIT, I) FIXED;                                00591500
      HASHIT = 0;                                                               00592000
      DO I = 0 TO LENGTH(NAME)-1;                                               00592500
         HASHIT = BYTE(NAME, I) + SHL(HASHIT, 1);                               00593000
      END;                                                                      00593500
      RETURN HASHIT MOD HASHSIZE;                                               00594000
   END HASH;                                                                    00594500
