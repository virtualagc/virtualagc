 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STRUCTU2.xpl
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
 /* PROCEDURE NAME:  STRUCTURE_FCN                                          */
 /* MEMBER NAME:     STRUCTU2                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          MAJ_STRUC                                                      */
 /*          MP                                                             */
 /*          SYM_LENGTH                                                     */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          VAR_LENGTH                                                     */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FIXV                                                           */
 /*          FIXL                                                           */
 /* CALLED BY:                                                              */
 /*          SETUP_NO_ARG_FCN                                               */
 /*          START_NORMAL_FCN                                               */
 /***************************************************************************/
                                                                                00890100
STRUCTURE_FCN:                                                                  00890200
   PROCEDURE;                                                                   00890300
      IF SYT_TYPE(FIXL(MP))<MAJ_STRUC THEN RETURN;                              00890400
      IF FIXV(MP)=0 THEN FIXV(MP)=FIXL(MP);                                     00890500
      FIXL(MP)=VAR_LENGTH(FIXL(MP));                                            00890600
   END STRUCTURE_FCN;                                                           00890700
