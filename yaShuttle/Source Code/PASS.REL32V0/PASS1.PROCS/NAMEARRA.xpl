 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NAMEARRA.xpl
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
 /* PROCEDURE NAME:  NAME_ARRAYNESS                                         */
 /* MEMBER NAME:     NAMEARRA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          EXT_P                                                          */
 /*          PTR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURRENT_ARRAYNESS                                              */
 /*          NAME_PSEUDOS                                                   */
 /* CALLED BY:                                                              */
 /*          SETUP_CALL_ARG                                                 */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
                                                                                00881200
NAME_ARRAYNESS:                                                                 00881300
   PROCEDURE (LOC);                                                             00881400
      DECLARE LOC BIT(16);                                                      00881500
      LOC=EXT_P(PTR(LOC));                                                      00881600
      CURRENT_ARRAYNESS(1)=LOC;                                                 00881700
      CURRENT_ARRAYNESS=LOC^=0;                                                 00881800
      NAME_PSEUDOS=FALSE;                                                       00881900
   END NAME_ARRAYNESS;                                                          00882000
