 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   UPDATEBL.xpl
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
 /* PROCEDURE NAME:  UPDATE_BLOCK_CHECK                                     */
 /* MEMBER NAME:     UPDATEBL                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          LOC               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FIXL                                                           */
 /*          CLASS_PU                                                       */
 /*          NEST                                                           */
 /*          SYM_NEST                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_NEST                                                       */
 /*          UPDATE_BLOCK_LEVEL                                             */
 /*          VAR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SETUP_NO_ARG_FCN                                               */
 /*          START_NORMAL_FCN                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> UPDATE_BLOCK_CHECK <==                                              */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
                                                                                00842700
UPDATE_BLOCK_CHECK:                                                             00842800
   PROCEDURE (LOC);                                                             00842900
      DECLARE LOC BIT(16);                                                      00843000
      IF UPDATE_BLOCK_LEVEL>0 THEN                                              00843100
         IF SYT_NEST(FIXL(LOC))<NEST THEN                                       00843200
         CALL ERROR(CLASS_PU,3,VAR(LOC));                                       00843300
   END UPDATE_BLOCK_CHECK;                                                      00843400
