 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETSYTEN.xpl
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
 /* PROCEDURE NAME:  SET_SYT_ENTRIES                                        */
 /* MEMBER NAME:     SETSYTEN                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CHAR_STAR_ERR     LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ASSIGN_PARM                                                    */
 /*          BLOCK_MODE                                                     */
 /*          CHAR_TYPE                                                      */
 /*          CLASS_BX                                                       */
 /*          CLASS_DD                                                       */
 /*          CLASS_DL                                                       */
 /*          CLASS_DS                                                       */
 /*          CMPL_MODE                                                      */
 /*          DEF_CHAR_LENGTH                                                */
 /*          EXT_ARRAY_PTR                                                  */
 /*          FACTOR_LIM                                                     */
 /*          ID_LOC                                                         */
 /*          LATCHED_FLAG                                                   */
 /*          LOCK_FLAG                                                      */
 /*          LOCK#                                                          */
 /*          MAJ_STRUC                                                      */
 /*          N_DIM                                                          */
 /*          NAME_FLAG                                                      */
 /*          NAME_IMPLIED                                                   */
 /*          NEST                                                           */
 /*          ON_ERROR_PTR                                                   */
 /*          PARM_FLAGS                                                     */
 /*          PROG_LABEL                                                     */
 /*          STRUC_PTR                                                      */
 /*          SYM_ARRAY                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_LENGTH                                                     */
 /*          SYM_LOCK#                                                      */
 /*          SYM_NAME                                                       */
 /*          SYM_TYPE                                                       */
 /*          SYT_ARRAY                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_LOCK#                                                      */
 /*          SYT_NAME                                                       */
 /*          TASK_LABEL                                                     */
 /*          VAR_LENGTH                                                     */
 /*          VEC_TYPE                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ATTRIBUTES                                                     */
 /*          CHAR_LENGTH                                                    */
 /*          I                                                              */
 /*          S_ARRAY                                                        */
 /*          STRUC_DIM                                                      */
 /*          SYM_TAB                                                        */
 /*          TYPE                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ENTER_DIMS                                                     */
 /*          ERROR                                                          */
 /*          HALMAT_INIT_CONST                                              */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_SYT_ENTRIES <==                                                 */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> ENTER_DIMS                                                      */
 /*     ==> HALMAT_INIT_CONST                                               */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> HALMAT_POP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*         ==> HALMAT_PIP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*         ==> GET_ICQ                                                     */
 /*         ==> ICQ_ARRAYNESS_OUTPUT                                        */
 /*             ==> HALMAT_POP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_FIX_PIP#                                         */
 /*         ==> ICQ_CHECK_TYPE                                              */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> ICQ_OUTPUT                                                  */
 /*             ==> HALMAT_POP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_FIX_PIPTAGS                                      */
 /*             ==> GET_ICQ                                                 */
 /*             ==> ICQ_CHECK_TYPE                                          */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*         ==> HOW_TO_INIT_ARGS                                            */
 /*             ==> ICQ_TERM#                                               */
 /*             ==> ICQ_ARRAY#                                              */
 /***************************************************************************/
 /***************************************************************************/
 /*                                                                         */
 /*  REVISION HISTORY                                                       */
 /*                                                                         */
 /*  DATE     WHO  RLS   DR/CR #  DESCRIPTION                               */
 /*                                                                         */
 /*  02/01/01 DCP  31V0/ DR111367 ABEND OCCURS FOR A                        */
 /*                16V0           MULTI-DIMENSIONAL ARRAY                   */
 /***************************************************************************/
                                                                                01043300
                                                                                01047400
SET_SYT_ENTRIES:                                                                01047500
   PROCEDURE;                                                                   01047600
      SYT_TYPE(ID_LOC) = TYPE;                                                  01047700
      IF (ATTRIBUTES&LOCK_FLAG)^=0 THEN DO;                                     01047800
         IF (NEST=1&BLOCK_MODE(NEST)^<CMPL_MODE)|                               01047900
            (SYT_FLAGS(ID_LOC)&ASSIGN_PARM)^=0 THEN                             01048000
            SYT_LOCK#(ID_LOC)=LOCK#;                                            01048100
         ELSE DO;                                                               01048200
            ATTRIBUTES=ATTRIBUTES&(^LOCK_FLAG);                                 01048300
            CALL ERROR(CLASS_DL,1,SYT_NAME(ID_LOC));                            01048400
         END;                                                                   01048500
      END;                                                                      01048600
      IF NAME_IMPLIED THEN ATTRIBUTES=ATTRIBUTES|NAME_FLAG;                     01048700
      SYT_FLAGS(ID_LOC) = SYT_FLAGS(ID_LOC) | ATTRIBUTES;                       01048800
      IF TYPE=CHAR_TYPE THEN DO;                                                01048900
         IF NAME_IMPLIED THEN DO;                                               01049000
            IF N_DIM^=0 THEN GO TO CHAR_STAR_ERR;                               01049100
         END;                                                                   01049200
         ELSE IF (SYT_FLAGS(ID_LOC)&PARM_FLAGS)^=0 THEN DO;                     01049300
            IF CHAR_LENGTH^=-1 THEN DO;                                         01049400
               CHAR_LENGTH=-1;                                                  01049500
               CALL ERROR(CLASS_DS,11);                                         01049600
            END;                                                                01049700
         END;                                                                   01049800
ELSE CHAR_STAR_ERR:                                                             01049900
         IF CHAR_LENGTH=-1 THEN DO;                                             01050000
            CHAR_LENGTH=DEF_CHAR_LENGTH;                                        01050100
            CALL ERROR(CLASS_DS,3);                                             01050200
         END;                                                                   01050300
      END;                                                                      01050400
      IF TYPE <= VEC_TYPE THEN                                                  01050500
         VAR_LENGTH(ID_LOC) = TYPE(TYPE);                                       01050600
      IF N_DIM ^= 0 THEN                                                        01050700
         DO;  /* STUFF THE DIMENSIONS */                                        01050800
         IF EXT_ARRAY_PTR+N_DIM>=ON_ERROR_PTR THEN                              01050900
            CALL ERROR(CLASS_BX, 5);                                            01051000
         ELSE DO;                                                               01051100
            IF (N_DIM = 1) & (S_ARRAY = -1) THEN                                01051200
               DO;                                                              01051300
               IF (SYT_FLAGS(ID_LOC)&PARM_FLAGS)^=0&(^NAME_IMPLIED) THEN        01051400
                  S_ARRAY = -ID_LOC;                                            01051500
               ELSE DO;                                                         01051600
                  S_ARRAY = 2;                                                  01051700
                  CALL ERROR(CLASS_DD,10, SYT_NAME(ID_LOC));                    01051800
               END;                                                             01051900
            END;                                                                01052000
            CALL ENTER_DIMS;                                                    01052100
         /* IF AN ARRAY'S SIZE IS NOT AN * THEN CHECK IF THE TOTAL /*DR111367*/
         /* NUMBER OF ELEMENTS IN AN ARRAY IS GREATER THAN 32767   /*DR111367*/
         /* OR LESS THAN 1. IF IT IS THEN GENERATE A DD1 ERROR.    /*DR111367*/
            IF EXT_ARRAY(SYT_ARRAY(ID_LOC)+1) > 0 THEN DO;         /*DR111367*/
             IF (ICQ_TERM#(ID_LOC) * ICQ_ARRAY#(ID_LOC) > ARRAY_DIM_LIM ) /*"*/
              | (ICQ_TERM#(ID_LOC) * ICQ_ARRAY#(ID_LOC) < 1)       /*DR111367*/
             THEN CALL ERROR(CLASS_DD, 1);                         /*DR111367*/
            END;                                                   /*DR111367*/
         END;                                                                   01052200
      END;                                                                      01052300
      IF TYPE = MAJ_STRUC THEN                                                  01052400
         DO;                                                                    01052500
         VAR_LENGTH(ID_LOC)=STRUC_PTR;                                          01052600
         IF STRUC_DIM = -1 THEN DO;                                             01052700
            IF (SYT_FLAGS(ID_LOC)&PARM_FLAGS)^=0&(^NAME_IMPLIED) THEN           01052800
               STRUC_DIM = -ID_LOC;                                             01052900
            ELSE DO;                                                            01053000
               CALL ERROR(CLASS_DD, 8, SYT_NAME(ID_LOC));                       01053100
               STRUC_DIM = 2;                                                   01053200
            END;                                                                01053300
         END;                                                                   01053400
         IF STRUC_DIM^=0 THEN DO;                                  /*DR111367*/ 01053500
            SYT_ARRAY(ID_LOC) = STRUC_DIM;                         /*DR111367*/
      /* IF A STRUCTURE'S SIZE IS NOT AN * THEN CHECK IF THE TOTAL /*DR111367*/
      /* NUMBER OF ELEMENTS IN A MAJOR STRUCTURE IS GREATER THAN   /*DR111367*/
      /* 32767 OR LESS THAN 1. IF IT IS THEN GENERATE A DD11 ERROR./*DR111367*/
            IF STRUC_DIM > 0 THEN                                  /*DR111367*/
              IF (ICQ_TERM#(ID_LOC) * SYT_ARRAY(ID_LOC) > ARRAY_DIM_LIM) /*""*/
               | (ICQ_TERM#(ID_LOC) * SYT_ARRAY(ID_LOC) < 1)       /*DR111367*/
              THEN CALL ERROR(CLASS_DD, 11);                       /*DR111367*/
         END;                                                      /*DR111367*/
         ELSE IF (ICQ_TERM#(ID_LOC) > ARRAY_DIM_LIM) |             /*DR111367*/
                 (ICQ_TERM#(ID_LOC) < 1)                           /*DR111367*/
         THEN CALL ERROR(CLASS_DD, 11);                            /*DR111367*/
      END;                                                                      01053600
      ELSE IF TYPE=TASK_LABEL|TYPE=PROG_LABEL THEN                              01053700
         SYT_FLAGS(ID_LOC)=SYT_FLAGS(ID_LOC)|LATCHED_FLAG;                      01053800
      CALL HALMAT_INIT_CONST;                                                   01053900
      DO I = 0 TO FACTOR_LIM;                                                   01054000
         TYPE(I) = 0;                                                           01054100
      END;                                                                      01054200
                                                                                01054300
   END SET_SYT_ENTRIES;                                                         01054400
