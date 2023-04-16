 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COMPARE.xpl
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
 /* PROCEDURE NAME:  COMPARE                                                */
 /* MEMBER NAME:     COMPARE                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          DIM               FIXED                                        */
 /*          F_DIM             FIXED                                        */
 /*          ERROR#            FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ID_LOC                                                         */
 /*          CLASS_DS                                                       */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          CHECK_CONFLICTS                                                */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> COMPARE <==                                                         */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
                                                                                01022500
                                                                                01022600
COMPARE:                                                                        01022700
   PROCEDURE(DIM, F_DIM, ERROR#);                                               01022800
      DECLARE (DIM, F_DIM, ERROR#) FIXED;                                       01022900
      IF F_DIM = 0 THEN RETURN DIM;                                             01023000
      IF DIM = 0 THEN RETURN F_DIM;                                             01023100
      IF DIM = F_DIM THEN RETURN DIM;                                           01023200
      CALL ERROR(CLASS_DS, ERROR#, SYT_NAME(ID_LOC));                           01023300
      RETURN DIM;                                                               01023400
   END COMPARE;                                                                 01023500
