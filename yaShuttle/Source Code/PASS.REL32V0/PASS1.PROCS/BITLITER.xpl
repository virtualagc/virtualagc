 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BITLITER.xpl
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
 /* PROCEDURE NAME:  BIT_LITERAL                                            */
 /* MEMBER NAME:     BITLITER                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC1              BIT(16)                                      */
 /*          LOC2              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          LIT_PG                                                         */
 /*          LITERAL2                                                       */
 /*          LIT2                                                           */
 /*          LOC_P                                                          */
 /*          PSEUDO_FORM                                                    */
 /*          PTR                                                            */
 /*          TRUE                                                           */
 /*          XLIT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FIXV                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_LITERAL                                                    */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> BIT_LITERAL <==                                                     */
 /*     ==> GET_LITERAL                                                     */
 /***************************************************************************/
                                                                                00845020
BIT_LITERAL:                                                                    00845100
   PROCEDURE (LOC1,LOC2) BIT(1);                                                00845200
      DECLARE (LOC1,LOC2) BIT(16);                                              00845300
      IF PSEUDO_FORM(PTR(LOC1))^=XLIT THEN RETURN FALSE;                        00845400
      FIXV(LOC1)=LIT2(GET_LITERAL(LOC_P(PTR(LOC1))));                           00845500
      IF LOC2=0 THEN RETURN TRUE;                                               00845600
      IF PSEUDO_FORM(PTR(LOC2))^=XLIT THEN RETURN FALSE;                        00845700
      FIXV(LOC2)=LIT2(GET_LITERAL(LOC_P(PTR(LOC2))));                           00845800
      RETURN TRUE;                                                              00845900
   END BIT_LITERAL;                                                             00846000
