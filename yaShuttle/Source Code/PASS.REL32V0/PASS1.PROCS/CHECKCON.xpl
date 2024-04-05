 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKCON.xpl
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
 /* PROCEDURE NAME:  CHECK_CONSISTENCY                                      */
 /* MEMBER NAME:     CHECKCON                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ARRAY_FLAG                                                     */
 /*          BUILDING_TEMPLATE                                              */
 /*          CLASS                                                          */
 /*          CLASS_DA                                                       */
 /*          CLASS_DL                                                       */
 /*          CONSTANT_FLAG                                                  */
 /*          FALSE                                                          */
 /*          ILL_ATTR                                                       */
 /*          ILL_CLASS_ATTR                                                 */
 /*          ILL_LATCHED_ATTR                                               */
 /*          LATCHED_FLAG                                                   */
 /*          LOCK_FLAG                                                      */
 /*          MAJ_STRUC                                                      */
 /*          NONHAL_FLAG                             DR109024               */
 /*          RIGID_FLAG                                                     */
 /*          TRUE                                                           */
 /*          TYPE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ATTR_MASK                                                      */
 /*          ATTRIBUTES                                                     */
 /*          ATTRIBUTES2                             DR109024               */
 /*          J                                                              */
 /*          N_DIM                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /* CALLED BY:                                                              */
 /*          CHECK_CONFLICTS                                                */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHECK_CONSISTENCY <==                                               */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /***************************************************************************/
 /*****                               HISTORY                       *********/
 /***************************************************************************/
 /*      DATE   NAME  REL    DR NUMBER AND TITLE                            */
 /*                                                                         */
 /*    12/07/95 BAF   27V1   109024  INVALID NONHAL DECLARATIONS DO NOT     */
 /*             RCK   11V1            GET ERROR MESSAGES                    */
 /*                                                                         */
 /*    06/12/98 DAS   29V0   109097  INCORRECT ZB1 OR BS123 ERROR           */
 /*                   14V0            GENERATED                             */
 /*                                                                         */
 /*    06/03/98 SHH   29V0   109086  NO DA10 ERROR MESSAGE FOR DENSE,
 /*                   14V0            ALIGNED, OR RIGID
 /*
 /*    12/09/99 DAS   30V0   CR13212 ALLOW NAME REMOTE VARIABLES IN THE     */
 /*                   15V0            RUNTIME STACK                         */
 /*                                                                         */
 /***************************************************************************/
                                                                                01023600
                                                                                01023700
CHECK_CONSISTENCY:                                                              01023800
   PROCEDURE;                                                                   01023900
 /* CHECK SOME GLOBAL ERRORS */                                                 01024000
      IF (ATTRIBUTES & CONSTANT_FLAG) ^= 0 THEN                                 01024100
         IF (ATTRIBUTES & LOCK_FLAG) ^= 0 THEN                                  01024200
         DO;                                                                    01024300
         CALL ERROR(CLASS_DL, 2);                                               01024400
         ATTRIBUTES=ATTRIBUTES&(^LOCK_FLAG);                                    01024500
         ATTR_MASK=ATTR_MASK&(^LOCK_FLAG);                                      01024600
      END;                                                                      01024700
      IF (ATTRIBUTES & AUTO_FLAG) ^= 0 THEN          /*DR109097*/               01024800
         IF ((SYT_FLAGS(BLOCK_SYTREF(NEST)) & REENTRANT_FLAG)^=0) /*CR13212*/
            & ^NAME_IMPLIED THEN                                  /*CR13212*/
         IF (ATTRIBUTES & REMOTE_FLAG) ^= 0 THEN DO; /*DR109097*/               01024800
         CALL ERROR(CLASS_DA, 15);                   /*DR109097*/               01024800
         ATTRIBUTES=ATTRIBUTES&(^REMOTE_FLAG);       /*DR109097*/               01024800
         ATTR_MASK=ATTR_MASK&(^REMOTE_FLAG);         /*DR109097*/               01024800
      END;                                           /*DR109097*/               01024800
 /* NOW CHECK ILLEGAL ATTRIBUTES THAT ARE ALWAYS SO FOR                         01024800
         EACH DATA TYPE */                                                      01024900
      IF TYPE <= MAJ_STRUC THEN                                                 01025000
         DO;                                                                    01025100
         IF TYPE = MAJ_STRUC THEN                                               01025200
            IF N_DIM ^= 0 THEN DO;  /* ARRAY SPEC BAD */                        01025300
            CALL ERROR(CLASS_DA, 26);                                           01025400
            N_DIM = 0;                                                          01025500
            ATTRIBUTES = ATTRIBUTES & (^ARRAY_FLAG);                            01025600
         END;                                                                   01025700
         J = FALSE;                                                             01025800
         IF (ATTRIBUTES & ILL_ATTR(TYPE)) ^= 0 THEN                             01025900
            DO;                                                                 01026000
            J = TRUE;  /* ONLY GIVE ONE ERROR */                                01026100
            ATTRIBUTES=ATTRIBUTES&(^ILL_ATTR(TYPE));                            01026200
            ATTR_MASK=ATTR_MASK&(^ILL_ATTR(TYPE));                              01026300
         END;                                                                   01026400
         IF TYPE = 0 THEN                                                       01026500
            IF (ATTRIBUTES & LATCHED_FLAG) ^= 0 THEN                            01026600
            IF (ATTRIBUTES & ILL_LATCHED_ATTR) ^= 0 |                           01026700
               (ATTRIBUTES2 & NONHAL_FLAG) ^= 0 THEN     /*DR109024*/           01026700
            DO;                                                                 01026800
            J = TRUE;                                                           01026900
            ATTRIBUTES=ATTRIBUTES&(^ILL_LATCHED_ATTR);                          01027000
            ATTRIBUTES2=ATTRIBUTES2&(^NONHAL_FLAG);      /*DR109024*/           01027000
            ATTR_MASK=ATTR_MASK&(^ILL_LATCHED_ATTR);                            01027100
         END;                                                                   01027200
         IF J THEN CALL ERROR(CLASS_DA, TYPE);                                  01027300
      END;                                                                      01027400
      IF (ATTRIBUTES&ILL_CLASS_ATTR(CLASS))^=0 THEN DO;                         01027500
         CALL ERROR(CLASS_DA,11);                                               01027600
         N_DIM=0;                                                               01027700
         ATTRIBUTES=ATTRIBUTES&(^ILL_CLASS_ATTR(CLASS));                        01027800
         ATTR_MASK=ATTR_MASK&(^ILL_CLASS_ATTR(CLASS));                          01027900
      END;                                                                      01028000
      ELSE IF ^BUILDING_TEMPLATE THEN DO;                                       01028100
         IF (ATTRIBUTES&RIGID_FLAG)^=0 THEN DO;                                 01028200
            IF TYPE = MAJ_STRUC THEN DO;                 /*DR109086*/
                CALL ERROR(CLASS_DA,10);                 /*DR109086*/
            END;                                         /*DR109086*/
            ELSE                                         /*DR109086*/
            CALL ERROR(CLASS_DA,12);                                            01028300
            ATTRIBUTES=ATTRIBUTES&(^RIGID_FLAG);                                01028400
         END;                                                                   01028500
         IF TYPE = MAJ_STRUC THEN DO;                    /*DR109086*/
           IF (ATTRIBUTES&ALDENSE_FLAGS)^=0 THEN DO;     /*DR109086*/
              CALL ERROR(CLASS_DA,10);                   /*DR109086*/
              ATTRIBUTES=ATTRIBUTES&(^ALDENSE_FLAGS);    /*DR109086*/
           END;                                          /*DR109086*/
         END;                                            /*DR109086*/
      END;                                                                      01028600
                                                                                01028700
   END CHECK_CONSISTENCY;                                                       01028800
