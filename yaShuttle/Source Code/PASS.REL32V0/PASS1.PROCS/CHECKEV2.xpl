 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKEV2.xpl
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
 /* PROCEDURE NAME:  CHECK_EVENT_CONFLICTS                                  */
 /* MEMBER NAME:     CHECKEV2                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BUILDING_TEMPLATE                                              */
 /*          CLASS                                                          */
 /*          CLASS_D                                                        */
 /*          CLASS_DA                                                       */
 /*          CLASS_DT                                                       */
 /*          CLASS_FT                                                       */
 /*          DEFAULT_TYPE                                                   */
 /*          FALSE                                                          */
 /*          ID_LOC                                                         */
 /*          I                                                              */
 /*          ILL_INIT_ATTR                                                  */
 /*          INPUT_PARM                                                     */
 /*          LATCHED_FLAG                                                   */
 /*          MP                                                             */
 /*          NAME_IMPLIED                                                   */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /*          TEMPORARY_IMPLIED                                              */
 /*          VAR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          DO_INIT                                                        */
 /*          ATTRIBUTES                                                     */
 /*          TYPE                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHECK_EVENT_CONFLICTS <==                                           */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
                                                                                01036300
                                                                                01040800
CHECK_EVENT_CONFLICTS:                                                          01040900
   PROCEDURE;                                                                   01041000
      IF CLASS=2 THEN DO;                                                       01041100
         CALL ERROR(CLASS_FT,3,SYT_NAME(ID_LOC));                               01041200
         TYPE=DEFAULT_TYPE;                                                     01041300
      END;                                                                      01041400
      ELSE IF BUILDING_TEMPLATE THEN DO;                                        01041500
         IF ^NAME_IMPLIED THEN DO;                                              01041600
            CALL ERROR(CLASS_DT,7,SYT_NAME(ID_LOC));                            01041700
            TYPE=DEFAULT_TYPE;                                                  01041800
         END;                                                                   01041900
      END;                                                                      01042000
      ELSE IF TEMPORARY_IMPLIED THEN DO;                                        01042100
         CALL ERROR(CLASS_D,8,VAR(MP));                                         01042200
         TYPE=DEFAULT_TYPE;                                                     01042300
      END;                                                                      01042400
      ELSE IF (I&INPUT_PARM)^=0 THEN CALL ERROR(CLASS_DT,8,SYT_NAME(ID_LOC));   01042500
      ELSE IF (ATTRIBUTES&LATCHED_FLAG)=0 THEN                                  01042600
         IF (ATTRIBUTES&ILL_INIT_ATTR)^=0 THEN DO;                              01042700
         CALL ERROR(CLASS_DA,TYPE);                                             01042800
         ATTRIBUTES=ATTRIBUTES&(^ILL_INIT_ATTR);                                01042900
         DO_INIT=FALSE;                                                         01043000
      END;                                                                      01043100
   END CHECK_EVENT_CONFLICTS;                                                   01043200
