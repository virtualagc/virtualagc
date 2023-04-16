 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BUMPBLOC.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  BUMP_BLOCK                                             */
 /* MEMBER NAME:     BUMPBLOC                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BLOCK_TOP                                                      */
 /* CALLED BY:                                                              */
 /*          PUSH_STACK                                                     */
 /***************************************************************************/
                                                                                00560420
 /* FINDS NEXT UNUSED BLOCK#*/                                                  00560430
BUMP_BLOCK:                                                                     00560440
   PROCEDURE BIT(16);                                                           00560450
      BLOCK_TOP = BLOCK_TOP + 1;                                                00560460
      RETURN BLOCK_TOP;                                                         00560470
   END BUMP_BLOCK;                                                              00560480
