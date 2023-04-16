 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SRNUPDAT.xpl
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
 /* PROCEDURE NAME:  SRN_UPDATE                                             */
 /* MEMBER NAME:     SRNUPDAT                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          INCL_SRN                                                       */
 /*          SRN                                                            */
 /*          SRN_COUNT                                                      */
 /*          SRN_FLAG                                                       */
 /* CALLED BY:                                                              */
 /*          INITIALIZATION                                                 */
 /*          COMPILATION_LOOP                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
                                                                                00776900
                                                                                00777000
SRN_UPDATE:                                                                     00777100
   PROCEDURE;                                                                   00777200
      SRN_FLAG=FALSE;                                                           00777300
      SRN(2)=SRN(1);                                                            00777400
      INCL_SRN(2) = INCL_SRN(1);                                                00777410
      SRN_COUNT(2)=SRN_COUNT(1);                                                00777500
   END SRN_UPDATE;                                                              00777600
