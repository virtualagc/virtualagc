 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   UNARRAY3.xpl
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
 /* PROCEDURE NAME:  UNARRAYED_SIMPLE                                       */
 /* MEMBER NAME:     UNARRAY3                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          INT_TYPE                                                       */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          SCALAR_TYPE                                                    */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CHECK_ARRAYNESS                                                */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> UNARRAYED_SIMPLE <==                                                */
 /*     ==> CHECK_ARRAYNESS                                                 */
 /***************************************************************************/
                                                                                00822500
UNARRAYED_SIMPLE:                                                               00822600
   PROCEDURE(LOC);                                                              00822700
      DECLARE LOC BIT(16);                                                      00822800
      LOC=PSEUDO_TYPE(PTR(LOC));                                                00822900
      RETURN CHECK_ARRAYNESS|((LOC^=INT_TYPE)&(LOC^=SCALAR_TYPE));              00823000
   END UNARRAYED_SIMPLE;                                                        00823100
