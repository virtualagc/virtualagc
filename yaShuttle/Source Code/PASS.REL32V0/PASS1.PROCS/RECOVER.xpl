 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   RECOVER.xpl
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
 /* PROCEDURE NAME:  RECOVER                                                */
 /* MEMBER NAME:     RECOVER                                                */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* LOCAL DECLARATIONS:                                                     */
 /*          DECLARING         BIT(8)                                       */
 /*          BAD_BAD(1818)     LABEL                                        */
 /*          TOKEN_LOOP_START(1859)  LABEL                                  */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BCD                                                            */
 /*          DECLARE_TOKEN                                                  */
 /*          DOUBLE                                                         */
 /*          DOUBLE_SPACE                                                   */
 /*          EOFILE                                                         */
 /*          EVIL_FLAG                                                      */
 /*          FACTOR_LIM                                                     */
 /*          FALSE                                                          */
 /*          IC_PTR1                                                        */
 /*          IC_PTR2                                                        */
 /*          ID_TOKEN                                                       */
 /*          IMPLIED_TYPE                                                   */
 /*          LAST_WRITE                                                     */
 /*          LOOK_STACK                                                     */
 /*          REPLACE_TOKEN                                                  */
 /*          SAVE_INDENT_LEVEL                                              */
 /*          SEMI_COLON                                                     */
 /*          STATE_NAME                                                     */
 /*          STATE_STACK                                                    */
 /*          STMT_PTR                                                       */
 /*          STRUCTURE_WORD                                                 */
 /*          SUB_START_TOKEN                                                */
 /*          SYM_FLAGS                                                      */
 /*          SYT_FLAGS                                                      */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ASSIGN_ARG_LIST                                                */
 /*          BI_FUNC_FLAG                                                   */
 /*          COMPILING                                                      */
 /*          CONTEXT                                                        */
 /*          DELAY_CONTEXT_CHECK                                            */
 /*          DO_INIT                                                        */
 /*          FACTOR_FOUND                                                   */
 /*          FACTORED_TYPE                                                  */
 /*          FACTORING                                                      */
 /*          FCN_LV                                                         */
 /*          FIXING                                                         */
 /*          I                                                              */
 /*          IC_FOUND                                                       */
 /*          INDENT_LEVEL                                                   */
 /*          INIT_EMISSION                                                  */
 /*          NAME_IMPLIED                                                   */
 /*          NAME_PSEUDOS                                                   */
 /*          NAMING                                                         */
 /*          PARMS_WATCH                                                    */
 /*          PTR_TOP                                                        */
 /*          QUALIFICATION                                                  */
 /*          RECOVERING                                                     */
 /*          REF_ID_LOC                                                     */
 /*          REFER_LOC                                                      */
 /*          SP                                                             */
 /*          STATE                                                          */
 /*          SUBSCRIPT_LEVEL                                                */
 /*          SYM_TAB                                                        */
 /*          TEMPORARY_IMPLIED                                              */
 /*          TOKEN                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CALL_SCAN                                                      */
 /*          CHECK_ARRAYNESS                                                */
 /*          CHECK_TOKEN                                                    */
 /*          EMIT_SMRK                                                      */
 /*          OUTPUT_WRITER                                                  */
 /*          SAVE_TOKEN                                                     */
 /*          STACK_DUMP                                                     */
 /* CALLED BY:                                                              */
 /*          COMPILATION_LOOP                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> RECOVER <==                                                         */
 /*     ==> OUTPUT_WRITER                                                   */
 /*         ==> CHAR_INDEX                                                  */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> MIN                                                         */
 /*         ==> MAX                                                         */
 /*         ==> BLANK                                                       */
 /*         ==> LEFT_PAD                                                    */
 /*         ==> I_FORMAT                                                    */
 /*         ==> CHECK_DOWN                                                  */
 /*     ==> SAVE_TOKEN                                                      */
 /*         ==> OUTPUT_WRITER                                               */
 /*             ==> CHAR_INDEX                                              */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> MIN                                                     */
 /*             ==> MAX                                                     */
 /*             ==> BLANK                                                   */
 /*             ==> LEFT_PAD                                                */
 /*             ==> I_FORMAT                                                */
 /*             ==> CHECK_DOWN                                              */
 /*     ==> EMIT_SMRK                                                       */
 /*         ==> STAB_HDR                                                    */
 /*             ==> PTR_LOCATE                                              */
 /*             ==> GET_CELL                                                */
 /*             ==> LOCATE                                                  */
 /*         ==> HALMAT_RELOCATE                                             */
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
 /*     ==> CHECK_ARRAYNESS                                                 */
 /*     ==> CALL_SCAN                                                       */
 /*         ==> HEX                                                         */
 /*         ==> SAVE_DUMP                                                   */
 /*         ==> SCAN                                                        */
 /*             ==> MIN                                                     */
 /*             ==> HEX                                                     */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> FINISH_MACRO_TEXT                                       */
 /*             ==> SAVE_TOKEN                                              */
 /*                 ==> OUTPUT_WRITER                                       */
 /*                     ==> CHAR_INDEX                                      */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> MIN                                             */
 /*                     ==> MAX                                             */
 /*                     ==> BLANK                                           */
 /*                     ==> LEFT_PAD                                        */
 /*                     ==> I_FORMAT                                        */
 /*                     ==> CHECK_DOWN                                      */
 /*             ==> STREAM                                                  */
 /*                 ==> PAD                                                 */
 /*                 ==> CHAR_INDEX                                          */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> MOVE                                                */
 /*                 ==> MIN                                                 */
 /*                 ==> MAX                                                 */
 /*                 ==> DESCORE                                             */
 /*                     ==> PAD                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> SAVE_INPUT                                          */
 /*                     ==> PAD                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> PRINT2                                              */
 /*                 ==> OUTPUT_GROUP                                        */
 /*                     ==> PRINT2                                          */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HASH                                                */
 /*                 ==> ENTER_XREF                                          */
 /*                 ==> SAVE_LITERAL                                        */
 /*                 ==> ICQ_TERM#                                           */
 /*                 ==> ICQ_ARRAY#                                          */
 /*                 ==> CHECK_STRUC_CONFLICTS                               */
 /*                 ==> ENTER                                               */
 /*                 ==> ENTER_DIMS                                          */
 /*                 ==> DISCONNECT                                          */
 /*                 ==> SET_DUPL_FLAG                                       */
 /*                 ==> FINISH_MACRO_TEXT                                   */
 /*                 ==> ENTER_LAYOUT                                        */
 /*                 ==> MAKE_INCL_CELL                                      */
 /*                 ==> OUTPUT_WRITER                                       */
 /*                     ==> CHAR_INDEX                                      */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> MIN                                             */
 /*                     ==> MAX                                             */
 /*                     ==> BLANK                                           */
 /*                     ==> LEFT_PAD                                        */
 /*                     ==> I_FORMAT                                        */
 /*                     ==> CHECK_DOWN                                      */
 /*                 ==> FINDER                                              */
 /*                 ==> INTERPRET_ACCESS_FILE                               */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HASH                                            */
 /*                     ==> OUTPUT_WRITER                                   */
 /*                         ==> CHAR_INDEX                                  */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> MIN                                         */
 /*                         ==> MAX                                         */
 /*                         ==> BLANK                                       */
 /*                         ==> LEFT_PAD                                    */
 /*                         ==> I_FORMAT                                    */
 /*                         ==> CHECK_DOWN                                  */
 /*                 ==> NEXT_RECORD                                         */
 /*                     ==> DECOMPRESS                                      */
 /*                         ==> BLANK                                       */
 /*                 ==> ORDER_OK                                            */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*             ==> IDENTIFY                                                */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HASH                                                */
 /*                 ==> ENTER                                               */
 /*                 ==> SET_DUPL_FLAG                                       */
 /*                 ==> SET_XREF                                            */
 /*                     ==> ENTER_XREF                                      */
 /*                     ==> SET_OUTER_REF                                   */
 /*                         ==> COMPRESS_OUTER_REF                          */
 /*                             ==> MAX                                     */
 /*                 ==> BUFFER_MACRO_XREF                                   */
 /*             ==> PREP_LITERAL                                            */
 /*                 ==> SAVE_LITERAL                                        */
 /*     ==> STACK_DUMP                                                      */
 /*         ==> SAVE_DUMP                                                   */
 /*     ==> CHECK_TOKEN                                                     */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /***************************************************************************/
                                                                                01534400
RECOVER:                                                                        01534500
   PROCEDURE FIXED;                                                             01534600
 /* THIS ERROR RECOVERY SEARCHES FORWARD IN THE TEXT FOR A SEMICOLON OR         01534700
      END_OF_FILE, AS BEFORE.  THEN IT WIPES THE STATE STACK BACKWARD SEARCHING 01534800
      FOR A STATE THAT CAN READ THE NEW TOKEN.  THE STATE IN WHICH THE PARSE    01534900
      SHOULD BE RESUMED IS RETURNED     */                                      01535000
                                                                                01535100
      DECLARE DECLARING BIT(1);                                                 01535200
      DECLARING=FALSE;                                                          01535400
      RECOVERING = TRUE;                                                        01535500
      IF TOKEN ^= SEMI_COLON & TOKEN ^= EOFILE THEN                             01535510
         GO TO TOKEN_LOOP_START;                                                01535520
      DO WHILE TOKEN^=SEMI_COLON&TOKEN^=EOFILE;                                 01535600
         IF TOKEN ^= 0 THEN                                                     01535700
            CALL SAVE_TOKEN(TOKEN, BCD, IMPLIED_TYPE);                          01535800
         ELSE                                                                   01535900
            CALL SAVE_TOKEN(ID_TOKEN, BCD, IMPLIED_TYPE);                       01536000
TOKEN_LOOP_START:                                                               01536010
         TOKEN = 0;                                                             01536100
         CALL CALL_SCAN;   /* TO FIND SOMETHING SOLID IN THE TEXT  */           01536200
      END;                                                                      01536300
      CONTEXT,TEMPORARY_IMPLIED=0;                                              01536400
      NAME_IMPLIED,DELAY_CONTEXT_CHECK=FALSE;                                   01536500
      ASSIGN_ARG_LIST=FALSE;                                                    01536600
      NAME_PSEUDOS=FALSE;                                                       01536700
      NAMING,FIXING,REFER_LOC=0;                                                01536800
      PARMS_WATCH=FALSE;                                                        01536900
      QUALIFICATION=0;                                                          01537000
      RECOVERING, DO_INIT = FALSE;                                              01537100
      BI_FUNC_FLAG,INIT_EMISSION=FALSE;                                         01537200
      IF (IC_FOUND & 1) ^= 0 THEN /*  RESET PTR_TOP IF POSSIBLE  */             01537300
         PTR_TOP = IC_PTR1 - 1;  /*  IF SYNTAX ERROR DURING FACTORED INIT  */   01537400
      ELSE                                                                      01537500
         IF (IC_FOUND & 2) ^= 0 THEN  /*  NORMAL INITIALAZATION  */             01537600
         PTR_TOP = IC_PTR2 - 1;                                                 01537700
      IC_FOUND = 0;  /*  RESET TO SHOW NO INITIALIZATION IN PROGRESS  */        01537800
      IF SUBSCRIPT_LEVEL>0 THEN DO;                                             01537900
         SUBSCRIPT_LEVEL=0;                                                     01538000
      END;                                                                      01538100
      FCN_LV = 0;                                                               01538200
      IF REF_ID_LOC>0 THEN DO;                                                  01538300
         SYT_FLAGS(REF_ID_LOC)=SYT_FLAGS(REF_ID_LOC)|EVIL_FLAG;                 01538400
         REF_ID_LOC=0;                                                          01538500
      END;                                                                      01538600
      CALL CHECK_ARRAYNESS;                                                     01538700
      DO WHILE SP>0;                                                            01538800
         STATE=CHECK_TOKEN(STATE_STACK(SP),LOOK_STACK(SP),TOKEN);               01538900
         IF STATE>0 & STATE_NAME(STATE_STACK(SP))^=SUB_START_TOKEN THEN DO;     01539000
            SP=SP-1;                                                            01539100
            CALL STACK_DUMP;                                                    01539200
            IF TOKEN^=EOFILE THEN DO;                                           01539300
               IF SAVE_INDENT_LEVEL^=0 THEN INDENT_LEVEL=SAVE_INDENT_LEVEL;     01539400
               IF ^DECLARING THEN RETURN;                                       01539500
               CALL SAVE_TOKEN(TOKEN,BCD,IMPLIED_TYPE);                         01539600
               CALL OUTPUT_WRITER(LAST_WRITE,STMT_PTR);                         01539700
               CALL CALL_SCAN;                                                  01539800
               CALL EMIT_SMRK;                                                  01539900
               FACTORING = TRUE;                                                01540000
               FACTOR_FOUND = FALSE;                                            01540100
               DO I = 0 TO FACTOR_LIM;                                          01540200
                  FACTORED_TYPE(I) = 0;                                         01540300
               END;                                                             01540400
            END;                                                                01540500
            ELSE GO TO BAD_BAD;                                                 01540600
            RETURN;                                                             01540700
         END;                                                                   01540800
         I=STATE_NAME(STATE_STACK(SP));                                         01540900
         IF (I=DECLARE_TOKEN)|(I=REPLACE_TOKEN) THEN DECLARING=TRUE;            01541000
         ELSE IF I=STRUCTURE_WORD THEN DECLARING=TRUE;                          01541100
         SP=SP-1;                                                               01541200
      END;                                                                      01541300
BAD_BAD:                                                                        01541400
      CALL OUTPUT_WRITER(LAST_WRITE,STMT_PTR);                                  01541500
      DOUBLE_SPACE;                                                             01541600
      OUTPUT='***** ERROR RECOVERY UNSUCCESSFUL.';                              01541700
      COMPILING=FALSE;                                                          01541800
      RETURN;                                                                   01541900
   END RECOVER;                                                                 01542000
