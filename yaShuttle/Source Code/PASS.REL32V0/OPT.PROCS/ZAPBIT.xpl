 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ZAPBIT.xpl
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
 /* PROCEDURE NAME:  ZAP_BIT                                                */
 /* MEMBER NAME:     ZAPBIT                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LOOP_ZAPS_LEVEL                                                */
 /*          LOOP_ZAPS                                                      */
 /*          OBPS                                                           */
 /*          REL                                                            */
 /*          SYM_REL                                                        */
 /*          SYM_SHRINK                                                     */
 /*          TSAPS                                                          */
 /* CALLED BY:                                                              */
 /*          INVAR                                                          */
 /***************************************************************************/
                                                                                01891840
 /* RETURNS ZAP BIT FOR INNERMOST LOOP CORRESPONDING TO PTR*/                   01891850
ZAP_BIT:                                                                        01891860
   PROCEDURE(PTR) BIT(8);                                                       01891870
      DECLARE PTR BIT(16);                                                      01891880
      PTR = REL(PTR);                                                           01891890
      RETURN(SHR(LOOP_ZAPS(SHR(PTR,5)),PTR & "1F") | LOOP_ZAPS(0)) & "1";       01891900
   END ZAP_BIT;                                                                 01891910
