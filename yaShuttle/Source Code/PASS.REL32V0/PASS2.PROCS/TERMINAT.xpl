 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   TERMINAT.xpl
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
/* PROCEDURE NAME:  TERMINATE                                              */
/* MEMBER NAME:     TERMINAT                                               */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CALL#                                                          */
/*          CLASS_BS                                                       */
/*          CODE_END                                                       */
/*          DATA_HWM                                                       */
/*          DATABASE                                                       */
/*          ESD_LIMIT                                                      */
/*          PCEBASE                                                        */
/*          PROC_LEVEL                                                     */
/*          PROCLIMIT                                                      */
/*          PROGDATA                                                       */
/*          PROGPOINT                                                      */
/*          P2SYMS                                                         */
/*          REMOTE_HWM                                                     */
/*          REMOTE_LEVEL                                                   */
/*          RLD_POS_HEAD                                                   */
/*          SYM_LINK1                                                      */
/*          SYM_NAME                                                       */
/*          SYM_PARM                                                       */
/*          SYM_TAB                                                        */
/*          SYM_TYPE                                                       */
/*          SYT_LINK1                                                      */
/*          SYT_NAME                                                       */
/*          SYT_PARM                                                       */
/*          SYT_TYPE                                                       */
/*          TASK_LABEL                                                     */
/*          TASK#                                                          */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          COMM                                                           */
/*          CURRENT_ESDID                                                  */
/*          ENTRYPOINT                                                     */
/*          ESD_LINK                                                       */
/*          ESD_MAX                                                        */
/*          LASTBASE                                                       */
/*          LOCCTR                                                         */
/*          MAXTEMP                                                        */
/*          OP1                                                            */
/*          ORIGIN                                                         */
/*          PROGCODE                                                       */
/*          STACKSPACE                                                     */
/*          TEMPSPACE                                                      */
/*          TMP                                                            */
/*          WORKSEG                                                        */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          EMIT_ADDRS                                                     */
/*          EMITC                                                          */
/*          ENTER_ESD                                                      */
/*          ERRORS                                                         */
/*          GENERATE_CONSTANTS                                             */
/*          OBJECT_CONDENSER                                               */
/*          OBJECT_GENERATOR                                               */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> TERMINATE <==                                                       */
/*     ==> ENTER_ESD                                                       */
/*         ==> PAD                                                         */
/*     ==> EMITC                                                           */
/*         ==> FORMAT                                                      */
/*         ==> HEX                                                         */
/*         ==> HEX_LOCCTR                                                  */
/*             ==> HEX                                                     */
/*         ==> GET_CODE                                                    */
/*     ==> ERRORS                                                          */
/*         ==> NEXTCODE                                                    */
/*             ==> DECODEPOP                                               */
/*                 ==> FORMAT                                              */
/*                 ==> HEX                                                 */
/*                 ==> POPCODE                                             */
/*                 ==> POPNUM                                              */
/*                 ==> POPTAG                                              */
/*             ==> AUX_SYNC                                                */
/*                 ==> GET_AUX                                             */
/*                 ==> AUX_LINE                                            */
/*                     ==> GET_AUX                                         */
/*                 ==> AUX_OP                                              */
/*                     ==> GET_AUX                                         */
/*         ==> RELEASETEMP                                                 */
/*             ==> SETUP_STACK                                             */
/*             ==> CLEAR_REGS                                              */
/*                 ==> SET_LINKREG                                         */
/*         ==> COMMON_ERRORS                                               */
/*     ==> EMIT_ADDRS                                                      */
/*         ==> DISP                                                        */
/*         ==> LOCATE                                                      */
/*         ==> ERRORS                                                      */
/*             ==> NEXTCODE                                                */
/*                 ==> DECODEPOP                                           */
/*                     ==> FORMAT                                          */
/*                     ==> HEX                                             */
/*                     ==> POPCODE                                         */
/*                     ==> POPNUM                                          */
/*                     ==> POPTAG                                          */
/*                 ==> AUX_SYNC                                            */
/*                     ==> GET_AUX                                         */
/*                     ==> AUX_LINE                                        */
/*                         ==> GET_AUX                                     */
/*                     ==> AUX_OP                                          */
/*                         ==> GET_AUX                                     */
/*             ==> RELEASETEMP                                             */
/*                 ==> SETUP_STACK                                         */
/*                 ==> CLEAR_REGS                                          */
/*                     ==> SET_LINKREG                                     */
/*             ==> COMMON_ERRORS                                           */
/*     ==> GENERATE_CONSTANTS                                              */
/*         ==> GET_CODE                                                    */
/*         ==> EMITC                                                       */
/*             ==> FORMAT                                                  */
/*             ==> HEX                                                     */
/*             ==> HEX_LOCCTR                                              */
/*                 ==> HEX                                                 */
/*             ==> GET_CODE                                                */
/*         ==> EMITW                                                       */
/*             ==> HEX                                                     */
/*             ==> HEX_LOCCTR                                              */
/*                 ==> HEX                                                 */
/*             ==> GET_CODE                                                */
/*         ==> EMITSTRING                                                  */
/*             ==> CS                                                      */
/*             ==> EMITC                                                   */
/*                 ==> FORMAT                                              */
/*                 ==> HEX                                                 */
/*                 ==> HEX_LOCCTR                                          */
/*                     ==> HEX                                             */
/*                 ==> GET_CODE                                            */
/*             ==> EMITW                                                   */
/*                 ==> HEX                                                 */
/*                 ==> HEX_LOCCTR                                          */
/*                     ==> HEX                                             */
/*                 ==> GET_CODE                                            */
/*         ==> BOUNDARY_ALIGN                                              */
/*             ==> EMITC                                                   */
/*                 ==> FORMAT                                              */
/*                 ==> HEX                                                 */
/*                 ==> HEX_LOCCTR                                          */
/*                     ==> HEX                                             */
/*                 ==> GET_CODE                                            */
/*         ==> SET_LOCCTR                                                  */
/*             ==> EMITC                                                   */
/*                 ==> FORMAT                                              */
/*                 ==> HEX                                                 */
/*                 ==> HEX_LOCCTR                                          */
/*                     ==> HEX                                             */
/*                 ==> GET_CODE                                            */
/*             ==> EMITW                                                   */
/*                 ==> HEX                                                 */
/*                 ==> HEX_LOCCTR                                          */
/*                     ==> HEX                                             */
/*                 ==> GET_CODE                                            */
/*         ==> EMITADDR                                                    */
/*             ==> EMITC                                                   */
/*                 ==> FORMAT                                              */
/*                 ==> HEX                                                 */
/*                 ==> HEX_LOCCTR                                          */
/*                     ==> HEX                                             */
/*                 ==> GET_CODE                                            */
/*             ==> EMITW                                                   */
/*                 ==> HEX                                                 */
/*                 ==> HEX_LOCCTR                                          */
/*                     ==> HEX                                             */
/*                 ==> GET_CODE                                            */
/*     ==> OBJECT_CONDENSER                                                */
/*         ==> GET_CODE                                                    */
/*         ==> CHECK_SRS                                                   */
/*         ==> ERRORS                                                      */
/*             ==> NEXTCODE                                                */
/*                 ==> DECODEPOP                                           */
/*                     ==> FORMAT                                          */
/*                     ==> HEX                                             */
/*                     ==> POPCODE                                         */
/*                     ==> POPNUM                                          */
/*                     ==> POPTAG                                          */
/*                 ==> AUX_SYNC                                            */
/*                     ==> GET_AUX                                         */
/*                     ==> AUX_LINE                                        */
/*                         ==> GET_AUX                                     */
/*                     ==> AUX_OP                                          */
/*                         ==> GET_AUX                                     */
/*             ==> RELEASETEMP                                             */
/*                 ==> SETUP_STACK                                         */
/*                 ==> CLEAR_REGS                                          */
/*                     ==> SET_LINKREG                                     */
/*             ==> COMMON_ERRORS                                           */
/*         ==> NEXT_REC                                                    */
/*             ==> GET_CODE                                                */
/*         ==> SKIP                                                        */
/*         ==> SKIP_ADDR                                                   */
/*             ==> GET_CODE                                                */
/*             ==> NEXT_REC                                                */
/*                 ==> GET_CODE                                            */
/*             ==> SKIP                                                    */
/*         ==> REAL_LABEL                                                  */
/*         ==> GET_INST_R_X                                                */
/*     ==> OBJECT_GENERATOR                                                */
/*         ==> MIN                                                         */
/*         ==> PAD                                                         */
/*         ==> INSTRUCTION                                                 */
/*             ==> CHAR_INDEX                                              */
/*             ==> PAD                                                     */
/*         ==> ESD_TABLE                                                   */
/*         ==> ENTER_ESD                                                   */
/*             ==> PAD                                                     */
/*         ==> GET_LITERAL                                                 */
/*             ==> MAX                                                     */
/*         ==> ERRORS                                                      */
/*             ==> NEXTCODE                                                */
/*                 ==> DECODEPOP                                           */
/*                     ==> FORMAT                                          */
/*                     ==> HEX                                             */
/*                     ==> POPCODE                                         */
/*                     ==> POPNUM                                          */
/*                     ==> POPTAG                                          */
/*                 ==> AUX_SYNC                                            */
/*                     ==> GET_AUX                                         */
/*                     ==> AUX_LINE                                        */
/*                         ==> GET_AUX                                     */
/*                     ==> AUX_OP                                          */
/*                         ==> GET_AUX                                     */
/*             ==> RELEASETEMP                                             */
/*                 ==> SETUP_STACK                                         */
/*                 ==> CLEAR_REGS                                          */
/*                     ==> SET_LINKREG                                     */
/*             ==> COMMON_ERRORS                                           */
/*         ==> SET_MASKING_BIT                                             */
/*             ==> PTR_LOCATE                                              */
/*             ==> LOCATE                                                  */
/*             ==> ERRORS                                                  */
/*                 ==> NEXTCODE                                            */
/*                     ==> DECODEPOP                                       */
/*                         ==> FORMAT                                      */
/*                         ==> HEX                                         */
/*                         ==> POPCODE                                     */
/*                         ==> POPNUM                                      */
/*                         ==> POPTAG                                      */
/*                     ==> AUX_SYNC                                        */
/*                         ==> GET_AUX                                     */
/*                         ==> AUX_LINE                                    */
/*                             ==> GET_AUX                                 */
/*                         ==> AUX_OP                                      */
/*                             ==> GET_AUX                                 */
/*                 ==> RELEASETEMP                                         */
/*                     ==> SETUP_STACK                                     */
/*                     ==> CLEAR_REGS                                      */
/*                         ==> SET_LINKREG                                 */
/*                 ==> COMMON_ERRORS                                       */
/*         ==> EMIT_ADDRS                                                  */
/*             ==> DISP                                                    */
/*             ==> LOCATE                                                  */
/*             ==> ERRORS                                                  */
/*                 ==> NEXTCODE                                            */
/*                     ==> DECODEPOP                                       */
/*                         ==> FORMAT                                      */
/*                         ==> HEX                                         */
/*                         ==> POPCODE                                     */
/*                         ==> POPNUM                                      */
/*                         ==> POPTAG                                      */
/*                     ==> AUX_SYNC                                        */
/*                         ==> GET_AUX                                     */
/*                         ==> AUX_LINE                                    */
/*                             ==> GET_AUX                                 */
/*                         ==> AUX_OP                                      */
/*                             ==> GET_AUX                                 */
/*                 ==> RELEASETEMP                                         */
/*                     ==> SETUP_STACK                                     */
/*                     ==> CLEAR_REGS                                      */
/*                         ==> SET_LINKREG                                 */
/*                 ==> COMMON_ERRORS                                       */
/*         ==> NEXT_REC                                                    */
/*             ==> GET_CODE                                                */
/*         ==> SKIP                                                        */
/*         ==> SKIP_ADDR                                                   */
/*             ==> GET_CODE                                                */
/*             ==> NEXT_REC                                                */
/*                 ==> GET_CODE                                            */
/*             ==> SKIP                                                    */
/*         ==> REAL_LABEL                                                  */
/*         ==> GET_INST_R_X                                                */
/***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 DKB  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /* 05/07/92 JAC   7V0  CR11114  MERGE BFS/PASS COMPILERS                   */
 /*                                                                         */
 /***************************************************************************/
                                                                                07924850
TERMINATE:                                                                      07925000
   PROCEDURE;                                                                   07925500
      TEMPSPACE, TMP = 0;                                                       07926000
      STACKSPACE, MAXTEMP(PROGPOINT) = (MAXTEMP(PROGPOINT)+3) & "FFFFFC";       07926500
      DO OP1 = PROGPOINT+1 TO PROCLIMIT;                                        07927000
         MAXTEMP(OP1) = (MAXTEMP(OP1)+3) & "FFFFFC";                            07927500
         IF SYT_TYPE(PROC_LEVEL(OP1)) >= TASK_LABEL THEN                        07928000
            STACKSPACE(SYT_PARM(PROC_LEVEL(OP1))) = MAXTEMP(OP1);               07928500
         ELSE TMP = TMP + MAXTEMP(OP1);                                         07929000
      END;                                                                      07929500
      DO OP1 = 0 TO TASK#;                                                      07930000
         STACKSPACE(OP1) = STACKSPACE(OP1) + TMP + 1024;                        07930500
         TEMPSPACE = TEMPSPACE + STACKSPACE(OP1);                               07931000
      END;                                                                      07931500
      CALL GENERATE_CONSTANTS;                                                  07932000
      CALL EMITC(CODE_END, 0);                                                  07932500
      CALL OBJECT_CONDENSER;                                                    07933000
      DATA_HWM,REMOTE_HWM=0;                                                    07933150
 /?P  /* CR11114 -- BFS/PASS INTERFACE; FIX EQUATE EXTERNAL #    */
      /*            INDEPENDENCE FOR BFS                         */
      IF ENTRYPOINT > 0 THEN DO;                                                 7933500
         ESD_MAX = ESD_MAX + 1;                                                 07934000
         IF ESD_MAX > ESD_LIMIT THEN                                            07934500
            CALL ERRORS(CLASS_BS, 110);                                         07935000
         CALL ENTER_ESD(SYT_NAME(ENTRYPOINT),ESD_MAX,1);                        07935500
         ESD_LINK(ESD_MAX) = ENTRYPOINT;                                        07936000
         ENTRYPOINT = SYT_LINK1(ENTRYPOINT);                                    07936500
      END;                                                                      07937000
 ?/
      RLD_POS_HEAD(PROGPOINT), ORIGIN(PROGPOINT) = 0;                           07937500
      WORKSEG(PROGPOINT) = 0;                                                   07938000
      IF PROGPOINT ^= DATABASE THEN                                             07938500
         PROGCODE = LOCCTR(PROGPOINT);                                          07939000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; PDE EMISSION   */
      IF CALL#(PROGPOINT) THEN                                                  07939500
         LOCCTR(PCEBASE) = (TASK#+1) * 6;                                       07940000
 ?/
      DO OP1 = PROGPOINT+1 TO DATABASE-1;                                       07940500
         RLD_POS_HEAD(OP1), ORIGIN(OP1) = 0;                                    07941000
 /*ORIGIN(OP1) = (ORIGIN(OP1-1)+LOCCTR(OP1-1)+3) & "FFFFFC";*/                  07941500
         WORKSEG(OP1) = ORIGIN(OP1);                                            07942000
         PROGCODE = PROGCODE + LOCCTR(OP1);                                     07942500
      END;                                                                      07943000
      RLD_POS_HEAD(DATABASE) = 0;                                               07943500
      WORKSEG(DATABASE) = 0;                                                    07944000
      LOCCTR(DATABASE) = PROGDATA;                                              07945000
      LOCCTR(REMOTE_LEVEL) = PROGDATA(1);                                        7946000
      CURRENT_ESDID, WORKSEG = 0;                                               07946500
      CALL OBJECT_GENERATOR;                                                    07947000
      CALL EMIT_ADDRS(0);                                                       07947500
   END TERMINATE;                                                               07948000
