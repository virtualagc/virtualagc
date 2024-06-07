 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BUMPARIN.xpl
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
 /* PROCEDURE NAME:  BUMP_AR_INV                                            */
 /* MEMBER NAME:     BUMPARIN                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          AR_LIST                                                        */
 /*          AR_INX                                                         */
 /* CALLED BY:                                                              */
 /*          PULL_INVARS                                                    */
 /***************************************************************************/
                                                                                01890730
 /* PUTS PTR ON STACK OF NODES TO BE CHECKED FOR ARRAY INVARIANCE*/             01890740
BUMP_AR_INV:                                                                    01890750
   PROCEDURE(PTR);                                                              01890760
      DECLARE PTR BIT(16);                                                      01890770
      AR_INX = AR_INX + 1;                                                      01890780
      AR_LIST(AR_INX) = PTR;                                                    01890790
   END BUMP_AR_INV;                                                             01890800
