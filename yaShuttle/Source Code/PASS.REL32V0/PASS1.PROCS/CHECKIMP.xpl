 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKIMP.xpl
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
 /* PROCEDURE NAME:  CHECK_IMPLICIT_T                                       */
 /* MEMBER NAME:     CHECKIMP                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          CLASS_DU                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          IMPLICIT_T                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHECK_IMPLICIT_T <==                                                */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
                                                                                01080300
                                                                                01080400
CHECK_IMPLICIT_T:                                                               01080500
   PROCEDURE;                                                                   01080600
      IF IMPLICIT_T THEN DO;                                                    01080700
         IMPLICIT_T=FALSE;                                                      01080800
         CALL ERROR(CLASS_DU,1,'T');                                            01080900
      END;                                                                      01081000
   END CHECK_IMPLICIT_T;                                                        01081100
