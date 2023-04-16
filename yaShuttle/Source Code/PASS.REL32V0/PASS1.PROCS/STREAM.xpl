 /*/
    Encoding:   Access this file using a UTF-8 character encoding.  
    		The following should appear to be a U.S. cent symbol: '¢'.
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STREAM.xpl
    Purpose:    This is a part of "Phase 1" (syntax analysis) of the HAL/S-FC 
                compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-07 RSB  Suffixed the filename with ".xpl".  Before this
                                file had been received, it appears as though
                                an EBCDIC-to-ASCII conversion had incorrectly
                                encoded the character '¢' (U.S. cent) as 0x9B.  
                                This has been repaired.
                2022-12-14 RSB	Changed the character encoding from ISO 8859-15
                		to UTF-8.
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  STREAM                                                 */
 /* MEMBER NAME:     STREAM                                                 */
 /* LOCAL DECLARATIONS:                                                     */
 /*       ARROW             BIT(16)            LAST_E_COUNT      BIT(16)    */
 /*       ARROW_FLAG        BIT(8)             LAST_E_IND        BIT(16)    */
 /*       BEGINNING         LABEL              LAST_S_COUNT      BIT(16)    */
 /*       BLANKS            CHARACTER          LAST_S_IND        BIT(16)    */
 /*       BUILD_XSCRIPTS    LABEL              M_BLANKS          BIT(16)    */
 /*       CHAR_TEMP         CHARACTER          M_LINE            CHARACTER  */
 /*       CHECK_STRING_POSITION  LABEL         MACRO_DIAGNOSTICS LABEL      */
 /*       CHOP              LABEL              MACRO_DONE(1570)  LABEL      */
 /*       COMP              LABEL              PARM_DONE         LABEL      */
 /*       CP                BIT(16)            PNTR              BIT(16)    */
 /*       CREATING          BIT(8)             PREV_CARD         FIXED      */
 /*       D_CONTINUATION_OK BIT(8)             PRINT_COMMENT(1548)  LABEL   */
 /*       D_INDEX           BIT(16)            PROCESS_COMMENT   LABEL      */
 /*       D_TOKEN           CHARACTER          READ_CARD         LABEL      */
 /*       E_BLANKS          BIT(16)            RETURN_CHAR(2)    BIT(16)    */
 /*       E_COUNT           BIT(16)            RETURNING_E       BIT(16)    */
 /*       E_IND(127)        BIT(16)            RETURNING_M       BIT(8)     */
 /*       E_INDICATOR(127)  BIT(16)            RETURNING_S       BIT(16)    */
 /*       E_LINE            CHARACTER          S_BLANKS          BIT(16)    */
 /*       E_STACK           CHARACTER          S_COUNT           BIT(16)    */
 /*       EP                BIT(16)            S_IND(127)        BIT(16)    */
 /*       EXPONENT          LABEL              S_INDICATOR(127)  BIT(16)    */
 /*       FILL              BIT(16)            S_LINE            CHARACTER  */
 /*       FOUND_CHAR        LABEL              S_STACK           CHARACTER  */
 /*       GET_GROUP         LABEL              SAVE_BLANK_COUNT1 BIT(16)    */
 /*       I                 BIT(16)            SAVE_NEXT_CHAR1   BIT(8)     */
 /*       II                BIT(16)            SAVE_OVER_PUNCH1  BIT(8)     */
 /*       INCL_REMOTE_FLAG  MACRO              SCAN_CARD(1)      LABEL      */
 /*       INCL_TEMPLATE_FLAG  MACRO            SP                BIT(16)    */
 /*       INCLUDE_OK(1677)  LABEL              STACK             LABEL      */
 /*       INCLUDE_SDF       LABEL              STACK_CHECK       LABEL      */
 /*       INCREMENT_DOWN_STMT  BIT(8)          STACK_RETURN_CHAR LABEL      */
 /*       IND_LIM           MACRO              STREAM_START(1562)  LABEL    */
 /*       IND_SHIFT         MACRO              SUBS(1687)        LABEL      */
 /*       INDEX             BIT(16)            TEMPLATE_FLAG     BIT(8)     */
 /*       INPUT_PAD         CHARACTER          TYPE_CHAR(2)      BIT(8)     */
 /*       L                 BIT(16)                                         */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*       ACCESS_FLAG                          MISC_NAME_FLAG               */
 /*       ALIGNED_FLAG                         NAME_FLAG                    */
 /*       AREAFCB                              NDECSY                       */
 /*       AREAPG                               NONHAL_FLAG                  */
 /*       ARRAY_FLAG                           NUM_ERR                      */
 /*       ASSIGN_PARM                          NUM_OF_PARM                  */
 /*       AUTO_FLAG                            PAD1                         */
 /*       BASE_PARM_LEVEL                      PAGE                         */
 /*       BIT_TYPE                             PARM_EXPAN_LIMIT             */
 /*       CARD_TYPE                            PARM_STACK_PTR               */
 /*       CHAR_TYPE                            PLUS                         */
 /*       CHARTYPE                             PRIMARY                      */
 /*       CLASS_BI                             PRINT_FLAG                   */
 /*       CLASS_DI                             PROC_LABEL                   */
 /*       CLASS_DU                             PROC_MODE                    */
 /*       CLASS_IR                             PROG_LABEL                   */
 /*       CLASS_M                              PROG_MODE                    */
 /*       CLASS_ME                             READ_ACCESS_FLAG             */
 /*       CLASS_MS                             REENTRANT_FLAG               */
 /*       CLASS_PE                             REMOTE                       */
 /*       CLASS_PL                             REMOTE_FLAG                  */
 /*       CLASS_PM                             REPL_ARG_CLASS               */
 /*       CLASS_XA                             REPL_CLASS                   */
 /*       CLASS_XD                             REPLACE_TEXT_PTR             */
 /*       CLASS_XI                             RIGID_FLAG                   */
 /*       CLASS_XR                             SAVE_NEXT_CHAR               */
 /*       CLASS_XU                             SAVE_OVER_PUNCH              */
 /*       CMPL_MODE                            SAVE_SCOPE                   */
 /*       COMPOOL_LABEL                        SCALAR_TYPE                  */
 /*       CONSTANT_FLAG                        SDF_INCL_FLAG                */
 /*       CURRENT_SCOPE                        SDF_INCL_LIST                */
 /*       DEFINED_LABEL                        SDL_OPTION                   */
 /*       DENSE_FLAG                           SEMI_COLON                   */
 /*       DOUBLE                               SIMULATING                   */
 /*       DOUBLE_FLAG                          SINGLE_FLAG                  */
 /*                                            SRN_PRESENT                  */
 /*       DOWN_CLS                             STARS                        */
 /*       DOWN_ERR                             STMT_NUM                     */
 /*       DOWN_STMT                            STMT_PTR                     */
 /*       DOWNGRADE_LIMIT                      SYM_ADDR                     */
 /*       DUPL_FLAG                            SYM_ARRAY                    */
 /*       DWN_CLS                              SYM_CLASS                    */
 /*       DWN_ERR                              SYM_FLAGS                    */
 /*       DWN_STMT                             SYM_HASHLINK                 */
 /*       EJECT_PAGE                           SYM_LENGTH                   */
 /*       ENDSCOPE_FLAG                        SYM_LINK1                    */
 /*       ERR_VALUE                            SYM_LINK2                    */
 /*       ERROR_INDEX                          SYM_LOCK#                    */
 /*       EVENT_TYPE                           SYM_NAME                     */
 /*       EVIL_FLAG                            SYM_PTR                      */
 /*       EXCLUSIVE_FLAG                       SYM_SCOPE                    */
 /*       EXTENT                               SYM_TYPE                     */
 /*       EXTERNAL_FLAG                        SYM_XREF                     */
 /*       FACTOR_LIM                           SYT_ADDR                     */
 /*       FALSE                                SYT_ARRAY                    */
 /*       FIRST_FREE                           SYT_CLASS                    */
 /*       FOREVER                              SYT_FLAGS                    */
 /*       FUNC_CLASS                           SYT_HASHLINK                 */
 /*       FUNC_MODE                            SYT_HASHSIZE                 */
 /*       INACTIVE_FLAG                        SYT_HASHSTART                */
 /*       INCLUDE_FILE#                        SYT_LINK1                    */
 /*       INCLUDED_REMOTE                      SYT_LINK2                    */
 /*       INIT_AFCBAREA                        SYT_LOCK#                    */
 /*       INIT_APGAREA                         SYT_NAME                     */
 /*       INIT_FLAG                            SYT_PTR                      */
 /*       INPUT_PARM                           SYT_SCOPE                    */
 /*       INT_TYPE                             SYT_TYPE                     */
 /*       LABEL_CLASS                          SYT_XREF                     */
 /*       LAST_WRITE                           TEMPL_NAME                   */
 /*       LATCHED_FLAG                         TEMPLATE_CLASS               */
 /*       LINE_LIM                             TEMPORARY_FLAG               */
 /*       LINK_SORT                            TEXT_LIMIT                   */
 /*       LISTING2                             TOKEN                        */
 /*       LIT_TOP                              TPL_FUNC_CLASS               */
 /*       LOCK_FLAG                            TPL_LAB_CLASS                */
 /*       M_BLANK_COUNT                        TRUE                         */
 /*       M_CENT                               UNMOVEABLE                   */
 /*       M_P                                  VAR_CLASS                    */
 /*       M_PRINT                              VAR_LENGTH                   */
 /*       M_TOKENS                             VBAR                         */
 /*       MAC_TXT                              VEC_TYPE                     */
 /*       MACRO_CALL_PARM_TABLE                XREF_REF                     */
 /*       MACRO_TEXTS                          XTNT                         */
 /*       MACRO_TEXT                           X1                           */
 /*       MAJ_STRUC                            X4                           */
 /*       MAT_TYPE                             X70                          */
 /*       MAX_SCOPE#                           X8                           */
 /*       MAX_STRUC_LEVEL                                                   */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*       BCD                                  MACRO_EXPAN_LEVEL            */
 /*       BLANK_COUNT                          MACRO_FOUND                  */
 /*       BLOCK_MODE                           MACRO_POINT                  */
 /*       BLOCK_SYTREF                         MEMBER                       */
 /*       BUILDING_TEMPLATE                    N_DIM                        */
 /*       CLOSE_BCD                            NAME_HASH                    */
 /*       C                                    NAME_IMPLIED                 */
 /*       CARD_COUNT                           NEST                         */
 /*       COMM                                 NEW_LEVEL                    */
 /*                                            NEXT_CC                      */
 /*       COMMENTING                           NEXT_CHAR                    */
 /*       COMPARE_SOURCE                       NONBLANK_FOUND               */
 /*       CONTROL                              OLD_LEVEL                    */
 /*       CSECT_LENGTHS                        OVER_PUNCH                   */
 /*       CURRENT_CARD                         P_CENT                       */
 /*       DATA_REMOTE                          PAGE_THROWN                  */
 /*                                            PARM_EXPAN_LEVEL             */
 /*       DOWN_COUNT                           PARM_REPLACE_PTR             */
 /*       DOWN_INFO                            PRINTING_ENABLED             */
 /*       END_GROUP                            PROCMARK                     */
 /*       END_OF_INPUT                         PROCMARK_STACK               */
 /*       FIRST_TIME                           PROGRAM_ID                   */
 /*       FIRST_TIME_PARM                      REF_ID_LOC                   */
 /*       GROUP_NEEDED                         REGULAR_PROCMARK             */
 /*       ID_LOC                               REV_CAT                      */
 /*       INCL_SRN                             START_POINT                  */
 /*       INCLUDE_CHAR                         S                            */
 /*       INCLUDE_COMPRESSED                   S_ARRAY                      */
 /*       INCLUDE_COUNT                        SAVE_CARD                    */
 /*       INCLUDE_END                          SCOPE#                       */
 /*       INCLUDE_LIST                         SCOPE#_STACK                 */
 /*       INCLUDE_LIST2                        SDF_OPEN                     */
 /*       INCLUDE_MSG                          SMRK_FLAG                    */
 /*       INCLUDE_OFFSET                       SRN                          */
 /*       INCLUDE_OPENED                       SRN_COUNT                    */
 /*       INCLUDING                            STRUC_DIM                    */
 /*       INITIAL_INCLUDE_RECORD               STRUC_PTR                    */
 /*       INPUT_DEV                            STRUC_SIZE                   */
 /*       INPUT_REC                            SYM_TAB                      */
 /*       IODEV                                TEMPORARY_IMPLIED            */
 /*       J                                    TOP_OF_PARM_STACK            */
 /*       K                                    TPL_REMOTE                   */
 /*       LINE_MAX                             TPL_VERSION                  */
 /*       LOOKED_RECORD_AHEAD                  TYPE                         */
 /*       LRECL                                WAIT                         */
 /*       MACRO_ARG_COUNT                                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*       CHAR_INDEX                           ICQ_TERM#                    */
 /*       CHECK_STRUC_CONFLICTS                INTERPRET_ACCESS_FILE        */
 /*       DESCORE                              MAKE_INCL_CELL               */
 /*       DISCONNECT                           MAX                          */
 /*       ENTER_XREF                           MIN                          */
 /*       ENTER                                MOVE                         */
 /*       ENTER_DIMS                           NEXT_RECORD                  */
 /*       ENTER_LAYOUT                         ORDER_OK                     */
 /*       ERRORS                               OUTPUT_GROUP                 */
 /*       ERROR                                OUTPUT_WRITER                */
 /*       FINDER                               PAD                          */
 /*       FINISH_MACRO_TEXT                    PRINT2                       */
 /*       HASH                                 SAVE_INPUT                   */
 /*       HEX                                  SAVE_LITERAL                 */
 /*       ICQ_ARRAY#                           SET_DUPL_FLAG                */
 /* CALLED BY:                                                              */
 /*       SCAN                                                              */
 /*       INITIALIZATION                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> STREAM <==                                                          */
 /*     ==> PAD                                                             */
 /*     ==> CHAR_INDEX                                                      */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> MOVE                                                            */
 /*     ==> MIN                                                             */
 /*     ==> MAX                                                             */
 /*     ==> DESCORE                                                         */
 /*         ==> PAD                                                         */
 /*     ==> HEX                                                             */
 /*     ==> SAVE_INPUT                                                      */
 /*         ==> PAD                                                         */
 /*         ==> I_FORMAT                                                    */
 /*     ==> PRINT2                                                          */
 /*     ==> OUTPUT_GROUP                                                    */
 /*         ==> PRINT2                                                      */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> HASH                                                            */
 /*     ==> ENTER_XREF                                                      */
 /*     ==> SAVE_LITERAL                                                    */
 /*     ==> ICQ_TERM#                                                       */
 /*     ==> ICQ_ARRAY#                                                      */
 /*     ==> CHECK_STRUC_CONFLICTS                                           */
 /*     ==> ENTER                                                           */
 /*     ==> ENTER_DIMS                                                      */
 /*     ==> DISCONNECT                                                      */
 /*     ==> SET_DUPL_FLAG                                                   */
 /*     ==> FINISH_MACRO_TEXT                                               */
 /*     ==> ENTER_LAYOUT                                                    */
 /*     ==> MAKE_INCL_CELL                                                  */
 /*     ==> OUTPUT_WRITER                                                   */
 /*         ==> CHAR_INDEX                                                  */
 /*         ==> ERRORS ****                                                 */
 /*         ==> MIN                                                         */
 /*         ==> MAX                                                         */
 /*         ==> BLANK                                                       */
 /*         ==> LEFT_PAD                                                    */
 /*         ==> I_FORMAT                                                    */
 /*         ==> CHECK_DOWN                                                  */
 /*     ==> FINDER                                                          */
 /*     ==> INTERPRET_ACCESS_FILE                                           */
 /*         ==> ERROR ****                                                  */
 /*         ==> HASH                                                        */
 /*         ==> OUTPUT_WRITER ****                                          */
 /*     ==> NEXT_RECORD                                                     */
 /*         ==> DECOMPRESS                                                  */
 /*             ==> BLANK                                                   */
 /*     ==> ORDER_OK                                                        */
 /*         ==> ERROR ****                                                  */
 /*                                                                         */
 /*                                                                         */
 /*  **** - BRANCH PREVIOUSLY EXPANDED                                      */
 /***************************************************************************/
 /***********************************************************/                  00006000
 /*                                                         */                  00007000
 /*  REVISION HISTORY                                       */                  00008000
 /*                                                         */                  00009000
 /*  DATE     WHO  RLS   DR/CR #  DESCRIPTION               */                  00009100
 /*                                                         */                  00009200
 /*  11/30/90 RAH  23V1  CR11088  INCREASE DOWNGRADE LIMIT  */                  00009300
 /*  12/21/91 TKK  23V2  CR11098  DELETE SPILLL CODE FROM   */
 /*                               COMPILER                  */
 /*  03/03/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER      */
 /*                               SOURCE CODE               */
 /*  07/01/91 RSJ  24V0  CR11096F ADDED DATA_REMOTE         */
 /*                               DIRECTIVE                 */                  00009400
 /*  06/20/91 TEV  7V0   CR11114  MERGE BFS/PASS COMPILERS  */
 /*                               WITH CR/DR FIXES          */
 /*                                                         */                  00009400
 /*  12/23/92 PMA  8V0   *        MERGED 7V0 AND 24V0       */
 /*                               COMPILERS.                */
 /*                               * REFERENCE 24V0 CR/DR    */
 /*                                                         */
 /*  12/28/92 PMA  8V0   CR11142  ADDED 'DATA_REMOTE'       */
 /*                               RESRICTION TO BFS.        */
 /*                               NOTE: THIS WILL NEED TO   */
 /*                               BE REMOVED IF AND WHEN    */
 /*                               BFS BEGINS USING          */
 /*                               DATA_REMOTE               */
 /*                                                         */
 /*  01/25/94 RSJ  26V0  DR105391 INCORRECT SRN IN HALSTAT  */
 /*                10V0           FOR INCLUDE FILES         */
 /*                                                         */
 /*  10/29/93 TEV  26V0  DR108630 0C4 ABEND OCCURS ON       */
 /*                10V0           ILLEGAL DOWNGRADE         */
 /*                                                         */
 /*  07/13/95 DAS  27V0  CR12416  IMPROVE COMPILER ERROR PROCESSING         */
 /*                11V0           (MAKE SEVERITY 3&4 ERRORS CAUSE ABORT)    */
 /*                                                                         */
 /*  12/11/95 TEV  27V1/ DR107308 EXTRANEOUS DATA_REMOTE    */
 /*                11V1           ERROR MESSAGE             */
 /*                                                         */
 /*  01/20/97 SMR  28V0/ CR12713  ENHANCE COMPILER LISTING  */
 /*                12V0                                     */
 /*                                                         */
 /*  11/22/96 LJK  28V0, DR109035 NESTED REPLACE MACROS ARE */
 /*                12V0           NOT PRINTED CORRECTLY     */
 /*  08/19/96 SMR  28V0/ DR108603 ZS1 NOT DOWNGRADED FOR    */
 /*                12V0           CARD TYPE WCZMTCBCPC      */
 /*                                                         */
 /*  04/22/98 SMR  28V0/ CR12940  ENHANCE COMPILER LISTING  */
 /*                14V0                                     */
 /*                                                         */
 /*  12/02/97 JAC  29V0  DR109074 DOWNGRADE OF DI21 ERROR   */
 /*                14V0           FAILS WHEN INCLUDING A    */
 /*                               REMOTELY INCLUDED COMPOOL */
 /*  12/04/97 DCP  29V0/ DR109079 NO ERROR GENERATED WHEN   */
 /*                14V0           DEFINE BLOCKS HAVE SAME   */
 /*                               NAME                      */
 /*                                                         */
 /*  06/22/99 JAC  30V0/ DR111335 TOKEN NOT PRINTED AFTER   */
 /*                15V0           REPLACE MACRO             */
 /*  03/25/99 JAC  30V0/ DR111314 INCLUDE FAILS WITH SRN    */
 /*                15V0           OPTION                    */
 /*                                                         */
 /*  04/26/01 DCP  31V0/ CR13335  ALLEVIATE SOME DATA SPACE */
 /*                16V0           PROBLEMS IN HAL/S COMPILER*/
 /***********************************************************/                  00009500
                                                                                00440500
                                                                                00440600
STREAM:                                                                         00440700
   PROCEDURE;                                                                   00440800
 /* THIS PROCEDURE FILLS THE VARIABLES NEXT_CHAR, ARROW, AND OVER_PUNCH.        00440900
     NEXT_CHAR IS A ONE BYTE  VARIABLE THAT CONTAINS THE NEXT CHARACTER IN      00441000
     THE INPUT STREAM. ARROW IS A HALF-WORD VARIABLE THAT CONTAINS AN INTEGER   00441100
     WHICH REPRESENTS THE RELATIVE DISPLACEMENT OF THE CHARACTER IN NEXT_CHAR   00441200
     WITH RESPECT TO THE LAST CHARACTER. A POSITIVE VALUE INDICATES A MOVE UP.  00441300
     OVER_PUNCH IS A ONE BYTE  VARIABLE THAT IS FILLED WITH A NON-ZERO          00441400
     VALUE WHEN A CHARACTER OTHER THAN BLANK APPEARS DIRECTLY OVER AN           00441500
     M-LINE CHARACTER--THE VALUE IS THE BYTE VALUE OF THE OVER PUNCH CHARACTER  00441600
  */                                                                            00441700
   DECLARE BLANKS CHARACTER INITIAL('                                           00441800
 ');                                                                            00441900
      DECLARE M_LINE CHARACTER;                                                 00442100
 /* THE FOLLOWING DECLARE MUST BE IN THE EXACT ORDER STATED. ITS USE IS         00442200
      DEPENDENT UPON THE MEMORY LOCATIONS ASSIGNED TO CONTIGUOUSLY              00442300
      DECLARED CHARACTER STRING DESCRIPTORS WHICH IS CURRENTLY                  00442400
      PRESUMED TO BE IN ASCENDING LOCATIONS */                                  00442500
      DECLARE (E_LINE,S_LINE) CHARACTER, (E_STACK,S_STACK) CHARACTER,           00442600
 /* THE EOF SYMBOL IS A HEX'FE'. IT IS CREATED BY A 12-11-0-6-8-9               00442700
         MULTIPLE PUNCH ON A CARD.                                              00442800
         THE FORMAT OF INPUT_PAD IS:                                            00442900
                   'M XY YX Z Z '' Z Z " Z Z'                                   00443000
         WHERE X IS A "/", Y IS A "*", AND Z IS THE EOF SYMBOL */               00443100
         INPUT_PAD CHARACTER INITIAL('M /**/ ¢ ¢ '' ¢ ¢ " ¢ ¢');                00443200
      DECLARE (LAST_E_IND, LAST_S_IND, E_BLANKS, S_BLANKS, EP, SP) BIT(16),     00443300
         M_BLANKS BIT(16) INITIAL(-1),                                          00443400
         IND_LIM LITERALLY '127', IND_SHIFT LITERALLY '7',                      00443500
         (E_IND, S_IND, E_INDICATOR, S_INDICATOR) (IND_LIM) BIT(16);            00443600
                                                                                00443700
      DECLARE (E_COUNT, S_COUNT, LAST_E_COUNT, LAST_S_COUNT, PNTR, CP,          00443800
         FILL) BIT(16);                                                         00443900
      DECLARE INDEX BIT(16) INITIAL(1);                                         00444000
   DECLARE RETURNING_M BIT(8) INITIAL(TRUE), (RETURNING_S, RETURNING_E) BIT(16);00444100
      DECLARE PREV_CARD FIXED;                                                  00444200
      DECLARE CHAR_TEMP CHARACTER;                                              00444500
      DECLARE RETURN_CHAR(2) BIT(16), TYPE_CHAR(2) BIT(8), ARROW_FLAG BIT(1),   00444600
         ARROW BIT(16), II BIT(16);                                             00444700
      DECLARE (SAVE_OVER_PUNCH1, SAVE_NEXT_CHAR1) BIT(8),                       00444800
         SAVE_BLANK_COUNT1 BIT(16);                                             00444900
      DECLARE (I, L) BIT(16);                                                   00445000
      DECLARE (CREATING, TEMPLATE_FLAG) BIT(1);                                 00445010
      DECLARE   /* INCLUDE CELL FLAG BITS */                                    00445020
         INCL_TEMPLATE_FLAG LITERALLY '"02"',                                   00445030
         INCL_REMOTE_FLAG   LITERALLY '"01"';                                   00445040
      DECLARE   /* D_TOKEN GLOBALS */                                           00445050
         D_INDEX BIT(16),                                                       00445060
         D_CONTINUATION_OK BIT(1) INITIAL(FALSE);                               00445070
 /*  TWO-DIMENSIONAL INPUT PROCEDURES     */                                    00445200
      GO TO STREAM_START;                                                       00445300
                                                                                00445400
                                                                                00445500
 /* $%PRINTCOM - PRINT_COMMENT */                                               00445600
 /* $%DTOKEN   - D_TOKEN */                                                     00445700
      /%INCLUDE INCSDF %/                                                       00445800
 /* $%PATCHINC  -  PATCH_INCLUDE*/                                              00445900
                                                                                00447000
                                                                                00447100
PROCESS_COMMENT:                                                                00447200
      PROCEDURE;                                                                00447300
         DECLARE NEXT_DIR(1) CHARACTER;        /*DR108603*/
         DECLARE TMP_INCREMENT BIT(1);         /*DR108603*/
         DECLARE PRINT_FLAG BIT(16), I FIXED;                                   00447400
         DECLARE (RECORD_NOT_WRITTEN, LIST_FLAG) BIT(1);                        00447450
         DECLARE C(1) CHARACTER, XC CHARACTER INITIAL('C');                     00447510
         DECLARE INCLUDE_DIR CHARACTER INITIAL('INCLUDE'),                      00447520
            START CHARACTER INITIAL('START');                                   00447530
         DECLARE EJECT_DIR CHARACTER INITIAL('EJECT'),                          00447600
            SPACE_DIR CHARACTER INITIAL('SPACE');                               00447700
         DECLARE TOGGLES CHARACTER INITIAL('0123456789ABCDEFG');                00447800
         IF BYTE(CURRENT_CARD) = BYTE('C') THEN                                 00453700
            CALL PRINT_COMMENT(TRUE);                                           00453800
         ELSE IF BYTE(CURRENT_CARD) = BYTE('D') THEN                            00456400
            DO;  /* A DIRECTIVE CARD */                                         00456500
            D_INDEX = 1;                                                        00456600
            C = D_TOKEN;                                                        00456700
            IF (C = EJECT_DIR) | (C = SPACE_DIR) THEN DO;                       00456800
               CALL PRINT_COMMENT(FALSE);                                       00456900
               IF C = EJECT_DIR THEN DO;                                        00457000
                  IF ^PAGE_THROWN | LINE_MAX ^= 0 THEN DO;                      00457100
                     LINE_MAX = 0;                                              00457200
                     PAGE_THROWN = TRUE;                                        00457300
                  END;                                                          00457400
               END;                                                             00457500
               ELSE DO;  /* SPACE DIRECTIVE */                                  00457600
                  C = D_TOKEN;                                                  00457700
                  IF LENGTH(C) = 0 THEN                                         00457800
                     J = 1;  /* 1 SPACE */                                      00457900
                  ELSE DO;                                                      00458000
                     J = BYTE(C);                                               00458100
                     IF CHARTYPE(J) ^= 1 THEN                                   00458200
                        J = 1;  /* ASSUME ONE SPACE */                          00458300
                     ELSE                                                       00458400
                        J = J & "F";                                            00458500
                     IF J > 3 THEN                                              00458600
                        J = 3;                                                  00458700
                  END;                                                          00458800
                  IF LINE_MAX = 0 THEN DO;                                      00458900
                     LINE_MAX = LINE_LIM;                                       00459000
                     EJECT_PAGE;                                                00459100
                  END;                                                          00459200
                  IF LINE_COUNT + J > LINE_MAX THEN                             00459300
                     LINE_MAX = 0;                                              00459400
                  ELSE DO I = 1 TO J;                                           00459500
                     OUTPUT = X1;                                               00459600
                  END;                                                          00459700
               END;                                                             00459800
               RETURN;                                                          00459900
            END;                                                                00460000
            CALL PRINT_COMMENT(TRUE,C);                  /*CR12713*/            00460100
            IF (C = 'EB') | (C = 'EBUG') THEN DO;  /* DEBUG DIRECTIVE */        00460200
CHAR_VALUE:    PROCEDURE(STR);                                                  00460300
                  DECLARE STR CHARACTER, (J, K, VAL) FIXED;                     00460400
                  J, VAL=0;                                                     00460500
                  DO WHILE J < LENGTH(STR);                                     00460600
                     K = BYTE(STR, J);                                          00460700
                     IF (K >= BYTE('0')) & (K <= BYTE('9')) THEN                00460800
                        VAL = VAL * 10 + (K - BYTE('0'));                       00460900
                     J = J + 1;                                                 00461000
                  END;                                                          00461100
                  RETURN VAL;                                                   00461200
               END CHAR_VALUE;                                                  00461300
               C = D_TOKEN;                                                     00461400
               DO WHILE LENGTH(C) ^= 0;                                         00461500
                  IF SUBSTR(C, 0, 2) = 'H(' THEN                                00461600
                     SMRK_FLAG = CHAR_VALUE(C);                                 00461700
                  ELSE ;  /* ADD NEW DEBUG TYPES HERE */                        00461800
                  C = D_TOKEN;                                                  00461900
               END;                                                             00462000
               DO I = 1 TO TEXT_LIMIT - 1;                                      00462005
                  IF BYTE(CURRENT_CARD, I) = BYTE('¢') THEN                     00462010
                     DO;                                                        00462015
                     J = CHAR_INDEX(TOGGLES, SUBSTR(CURRENT_CARD, I + 1, 1));   00462020
                     IF J > -1 THEN                                             00462025
                        DO;                                                     00462030
                        IF I < TEXT_LIMIT - 1 THEN                              00462035
                           K = BYTE(CURRENT_CARD, I + 2);                       00462040
                        ELSE                                                    00462045
                           GO TO COMPLEMENT;                                    00462050
                        IF K = BYTE('+') THEN                                   00462055
                           CONTROL(J) = "FF";                                   00462060
                        ELSE IF K = BYTE('-') THEN                              00462065
                           CONTROL(J) = FALSE;                                  00462070
                        ELSE                                                    00462075
COMPLEMENT:                                                                     00462080
                        CONTROL(J) = ^ CONTROL(J);                              00462085
                        IF J = "D" THEN                                         00462090
                           INCLUDE_LIST, INCLUDE_LIST2 = CONTROL(J);            00462095
                     END;                                                       00462100
                     IF CONTROL("A") THEN CALL EXIT;                            00462105
                  END;                                                          00462110
               END;                                                             00462115
            END;  /* OF DEBUG DIRECTIVE */                                      00462200
            ELSE IF C = 'DEVICE' THEN                                           00462300
               DO;                                                              00462400
               C = D_TOKEN;                                                     00462500
               IF LENGTH(C) = 0 THEN                                            00462600
                  DO;                                                           00462700
NO_CHAN:          CALL ERROR(CLASS_XD,3);                                       00462800
                  GO TO ERRPRINT;                                               00462900
               END;                                                             00463000
               I = CHAR_INDEX(C, 'CHANNEL=');                                   00463100
               IF I ^= 0 THEN                                                   00463200
                  GO TO NO_CHAN;                                                00463300
               J = 0;                                                           00463400
               DO I = 8 TO LENGTH(C) - 1;                                       00463500
                  K = BYTE(C, I);                                               00463600
                  IF CHARTYPE(K) ^= 1 THEN                                      00463700
                     GO TO NO_CHAN;                                             00463800
                  J = J * 10 + (K & "F");                                       00463900
               END;                                                             00464000
               IF I = 8 THEN                                                    00464100
                  GO TO NO_CHAN;                                                00464200
               IF J > 9 THEN                                                    00464300
                  DO;                                                           00464400
                  CALL ERROR(CLASS_XD,4);                                       00464500
                  GO TO ERRPRINT;                                               00464600
               END;                                                             00464700
               C = D_TOKEN;                                                     00464800
               PRINT_FLAG = FALSE;                                              00464900
               L = IODEV(J);                                                    00465000
               IF C = 'UNPAGED' THEN ;                                          00465100
               ELSE IF C = 'PAGED'  THEN                                        00465200
                  PRINT_FLAG = TRUE;                                            00465300
               ELSE IF C ^= '' THEN                                             00465400
                  DO;                                                           00465500
                  L = L | "20";                                                 00465600
                  CALL ERROR(CLASS_XD,1);                                       00465700
               END;                                                             00465800
               IF (L & "40") ^= 0 THEN                                          00465900
                  DO;                                                           00466000
                  CALL ERROR(CLASS_XD,2);                                       00466100
                  GO TO D_DONE;                                                 00466200
               END;                                                             00466300
               IF L = 0 THEN                                                    00466400
                  L = "50";  /* DIRECTIVE FOUND AND UNUSED FLAGS */             00466500
               ELSE                                                             00466600
                  L = L | "40";  /* DIRECTIVE FOUND */                          00466700
               IF (L & "28") ^= 0 THEN                                          00466800
                  GO TO D_DONE;  /* ERRORS ALREADY EXIST FOR THIS CHANNEL */    00466900
               IF PRINT_FLAG THEN                                               00467000
                  DO;                                                           00467100
                  IF (L & "03") ^= 0 THEN                                       00467200
                     DO;                                                        00467300
                     L = L | "08";  /* CONFLICT FLAG */                         00467400
                     GO TO D_DONE;                                              00467500
                  END;                                                          00467600
                  L = L | "04";  /* PRINT FLAG */                               00467700
               END;                                                             00467800
               ELSE                                                             00467900
                  L = (L & "FB") | "03";  /* PRINT OFF, READ/WRITE ON */        00468000
D_DONE:                                                                         00468100
               IODEV(J) = L;                                                    00468200
               GO TO ERRPRINT;                                                  00468300
            END;                                                                00468400
            ELSE IF C = INCLUDE_DIR THEN                                        00468500
               DO;  /* AN INCLUDE DIRECTIVE */                                  00468600
               IF INCLUDE_OK THEN                                               00473530
                  OUTPUT = X8 || STARS || START || INCLUDE_MSG || STARS;        00473610
            END;  /* OF INCLUDE DIRECTIVE */                                    00473620
            ELSE IF C='VERSION' THEN DO;                                        00473700
               IF TPL_VERSION>0 THEN DO;                                        00473800
                  I=BYTE(CURRENT_CARD,D_INDEX+1);                               00473900
                  SYT_LOCK#(TPL_VERSION)=I;                                     00474000
                  TPL_VERSION=0;                                                00474100
               END;                                                             00474200
            END;                                                                00474300
            ELSE IF C = 'DOWNGRADE' | C = 'OWNGRADE'  THEN DO; /* DOWNGRADE */  00474302
               DECLARE (TEMP_CLS, ULT_TEMP_CLS, FIN_TMP_CLS) CHARACTER;         00474304
               DECLARE TEMP_COUNT BIT(16);                                      00474306
               DECLARE CONTINUE BIT(1);                                         00474308
               CONTINUE = 0;                                                    00474310
               C = D_TOKEN;                                                     00474312
               IF LENGTH(C) = 0 THEN /* NO ERROR NUMBER TO DOWNGRADE */         00474314
                  CALL ERRORS (CLASS_BI, 108);                                  00474316
               ELSE DO;  /* OBTAIN CLASS */                                     00474318
 /**** CR11088 11/90 RAH **********************************************/
 /* IN ORDER TO COMPLETELY REMOVE THE LIMIT ON THE NUMBER OF          */
 /* ALLOWABLE DOWNGRADES JUST REMOVE THE FOLLOWING IF STATEMENT AND   */
 /* CALL TO ERRORS. SUBSEQUENTLY THE ELSE DO AND CORRESPONDING END    */
 /* STATEMENTS MUST ALSO THEN BE REMOVED.                             */
 /* CHECK TO SEE IF EXCEEDED DOWNGRADE_LIMIT */                                 00474320
                  IF DOWN_COUNT > DOWNGRADE_LIMIT THEN                          00474322
                     CALL ERRORS (CLASS_BI, 109);                               00474324
                  ELSE DO;                                                      00474326
                     NEXT_ELEMENT(DOWN_INFO);
                     DOWN_COUNT = DOWN_COUNT + 1;
 /**** CR11088 11/90 RAH **********************************************/
                     DO I = 0 TO 1 ;                                            00474328
                        TEMP_CLS = SUBSTR(C,0,I+1);                             00474330
                        ULT_TEMP_CLS = SUBSTR(TEMP_CLS,I,I);                    00474332
                        IF ULT_TEMP_CLS >= '0' & ULT_TEMP_CLS <= '9' THEN       00474334
                           CONTINUE = 1;                                        00474336
                        IF CONTINUE = 0 THEN DO; /* GET CLASS */                00474338
                           ULT_TEMP_CLS = PAD('CLASS_'||TEMP_CLS,8);            00474340
                           FIN_TMP_CLS = SUBSTR(X1||ULT_TEMP_CLS, 1);/*CR13335*/00474342
                        END;   /* DETERMINE CLASS */                            00474344
                     END;   /* OF ELSE FOR CLASS */                             00474345
 /* CHECK THE NEXT STATEMENT TO SEE IF DOWNGRADING A DIRECTIVE     */
 /* OR A STATEMENT  IF THE NEXT STATEMENT IS A DIRECTIVE, THEN     */
 /* SET INCREMENT_DOWN_STMT TO FALSE.                              */
                     TMP_INCREMENT = INCREMENT_DOWN_STMT;   /*DR108603*/
                     CALL NEXT_RECORD;                      /*DR108603*/
                     LOOKED_RECORD_AHEAD = TRUE;            /*DR108603*/
                     IF CARD_TYPE(BYTE(CURRENT_CARD)) =     /*DR108603*/
                        CARD_TYPE(BYTE('D')) THEN DO;       /*DR108603*/
                        D_INDEX = 1;                        /*DR108603*/
                        NEXT_DIR = D_TOKEN;                 /*DR108603*/
                        IF NEXT_DIR ^= 'DOWNGRADE' &        /*DR108603*/
                           NEXT_DIR ^= 'OWNGRADE' THEN      /*DR108603*/
                           INCREMENT_DOWN_STMT = FALSE;     /*DR108603*/
                        END;                                /*DR108603*/
 /* DR58324 - ATTACH DOWNGRADE TO CORRECT STATEMENT */                          00474346
                     IF INCREMENT_DOWN_STMT & TOKEN=SEMI_COLON THEN             00474347
                        DWN_STMT(DOWN_COUNT)=SUBSTR(X1||STMT_NUM+1,1);/*C13335*/00474348
                     ELSE DWN_STMT(DOWN_COUNT)=SUBSTR(X1||STMT_NUM,1);/* """  */00474349
                     INCREMENT_DOWN_STMT = TMP_INCREMENT;   /*DR108603*/
                     TEMP_CLS = CHAR_VALUE(C);                                  00474350
                     DWN_ERR(DOWN_COUNT) = SUBSTR(X1||TEMP_CLS,1);  /*CR13335*/ 00474352
                     CONTINUE = 1;                                              00474354
                     TEMP_COUNT = 0;                                            00474356
                     DO WHILE CONTINUE = 1 & TEMP_COUNT <= NUM_ERR;             00474358
                        IF FIN_TMP_CLS = ERROR_INDEX(TEMP_COUNT) THEN DO;       00474360
                           DWN_CLS(DOWN_COUNT) = ERR_VALUE(TEMP_COUNT);         00474362
                           CONTINUE = 0;                                        00474364
                        END;                                                    00474366
                        ELSE                                                    00474368
                           TEMP_COUNT = TEMP_COUNT + 1;                         00474370
                     END;                                                       00474372
                     IF CONTINUE = 1 THEN   /* ERROR CLASS NOT FOUND */         00474374
/************************* DR108630 - TEV - 10/29/93 *****************/
/* SAVE THE ERROR NUMBER LOCATED IN 'C' INTO 'DWN_UNKN'. CODE IN     */
/* DOWNGRADE_SUMMARY WILL USE THIS INFO TO BUILD A DOWNGRADE SUMMARY */
/* REPORT INSTEAD OF USING 'DWN_CLS' TO FIND THE ERROR CLASS (THERE  */
/* IS NO INFORMATION TO PUT INFO 'DWN_CLS' SINCE THE ERROR CLASS DOES*/
/* NOT EXIST).                                                       */
                     DO;
                        DWN_UNKN(DOWN_COUNT) = C;
/************************* END DR108630 ******************************/
                        CALL ERRORS (CLASS_BI, 107);                            00474376
                     END;        /* DR108630 - TEV - 10/29/93 */
                  END;                                                          00474380
               END;                                                             00474382
            END;  /* END OF DOWNGRADE */                                        00474384
            ELSE IF C = 'PROGRAM' THEN DO;                                      00474400
               IF BLOCK_MODE ^= 0 THEN DO;                                      00474500
                  CALL ERROR(CLASS_XA, 3);                                      00474600
                  GO TO ERRPRINT;                                               00474700
               END;                                                             00474800
               IF LENGTH(PROGRAM_ID) > 0 THEN DO;                               00474900
                  CALL ERROR(CLASS_XA, 1);                                      00475000
                  GO TO ERRPRINT;                                               00475100
               END;                                                             00475200
               C = D_TOKEN;                                                     00475300
               IF LENGTH(C) = 0 THEN DO;                                        00475400
NO_ID:                                                                          00475500
                  CALL ERROR(CLASS_XA, 2);                                      00475600
                  GO TO ERRPRINT;                                               00475700
               END;                                                             00475800
               I = CHAR_INDEX(C, 'ID=');                                        00475900
               IF I ^= 0 THEN GO TO NO_ID;                                      00476000
               IF LENGTH(C) <= 3 THEN GO TO NO_ID;                              00476100
               IF LENGTH(C)>=11 THEN                                            00476200
                  PROGRAM_ID = SUBSTR(C, 3, 8);                                 00476300
               ELSE                                                             00476400
                  PROGRAM_ID = PAD(SUBSTR(C, 3), 8);                            00476500
               CALL INTERPRET_ACCESS_FILE;                                      00476600
            END;                                                                00476700
            ELSE IF C = 'DEFINE' THEN DO;                                       00476704
COPY_TO_8:                                                                      00476708
               PROCEDURE;                                                       00476712
                  CALL PRINT_COMMENT(LIST_FLAG);                                00476716
                  OUTPUT(8) = CURRENT_CARD;                                     00476720
                  RECORD_NOT_WRITTEN = FALSE;                                   00476724
                  CALL MONITOR(16,"10");                                        00476726
               END COPY_TO_8;                                                   00476728
               C(1) = D_TOKEN;                                                  00476732
               IF LENGTH(C(1)) = 0 THEN CALL ERROR(CLASS_XD, 5);                00476736
               ELSE IF LENGTH(C(1)) >= 8 THEN C(1) = SUBSTR(C(1),0,8);          00476740
               ELSE C(1) = PAD(C(1), 8);                                        00476744
               C = D_TOKEN;                                                     00476748
               IF LENGTH(C) > 0 THEN LIST_FLAG = (C = 'LIST');                  00476752
               ELSE LIST_FLAG = FALSE;                                          00476756
               RECORD_NOT_WRITTEN = TRUE;                                       00476760
               IF INCLUDING THEN CALL ERROR(CLASS_XD, 8);                       00476764
               ELSE CREATING = TRUE;                                            00476768
               DO WHILE CREATING;                                               00476772
                  CALL NEXT_RECORD;                                             00476776
                  IF LENGTH(CURRENT_CARD) = 0 THEN DO;                          00476780
                     IF INCLUDING THEN DO;                                      00476784
                        INPUT_DEV = 0;
                        INCLUDING,INCLUDE_COMPRESSED=FALSE;                     00476909
                        INCLUDE_LIST,INCLUDE_LIST2=TRUE;                        00476914
                        OUTPUT(8)=XC||STARS||'END'||                            00476919
                           INCLUDE_MSG||STARS;                                  00476924
                        INCLUDE_OFFSET,INCLUDE_COUNT=                           00476929
                           INCLUDE_COUNT+CARD_COUNT+1-INCLUDE_OFFSET;           00476934
                     END;                                                       00476939
                     ELSE DO;                                                   00477034
                        CREATING = FALSE;                                       00477044
                        END_OF_INPUT = TRUE;                                    00477054
                        CURRENT_CARD = INPUT_PAD || X70;                        00477064
                     END;                                                       00477074
                  END;                                                          00477084
                  ELSE DO;                                                      00477094
                     CARD_COUNT = CARD_COUNT + 1;                               00477104
                     IF CARD_TYPE(BYTE(CURRENT_CARD))=CARD_TYPE(BYTE('D')) THEN 00477114
                        DO;                                                     00477124
                        D_INDEX = 1;                                            00477134
                        C = D_TOKEN;                                            00477144
                        IF C = INCLUDE_DIR THEN DO;                             00477154
                           BYTE(CURRENT_CARD) = BYTE('C');                      00477164
                           CALL COPY_TO_8;                                      00477174
                           IF INCLUDE_OK THEN
                           OUTPUT(8)=XC||STARS||START||INCLUDE_MSG||STARS;      00477264
                        END;                                                    00477274
                        ELSE IF C = 'CLOSE' THEN DO;  /* END OF INLINE BLOCK */ 00477284
                           CALL PRINT_COMMENT(TRUE);                            00477294
                           C = D_TOKEN;                                         00477304
                           IF LENGTH(C) >= 8 THEN C = SUBSTR(C,0,8);            00477314
                           ELSE C = PAD(C, 8);                                  00477324
                           IF C ^= C(1) THEN CALL ERROR(CLASS_XD, 6, C);        00477334
                           IF RECORD_NOT_WRITTEN THEN CALL ERROR(CLASS_XD, 7);  00477344
                           ELSE IF LENGTH(C(1)) > 0 THEN                        00477354
      /*DR109079*/            IF MONITOR(1, 8, C(1)) THEN /* STOW THE MEMBER */ 00477364
      /*DR109079*/              CALL ERROR(CLASS_XD, 9, C(1));
                           CREATING = FALSE;                                    00477374
                        END;                                                    00477384
                        ELSE CALL COPY_TO_8;                                    00477394
                     END;                                                       00477404
                     ELSE CALL COPY_TO_8;                                       00477414
                  END;                                                          00477424
               END;  /* WHILE CREATING */                                       00477434
            END;                                                                00477444
/*-RSJ------------------#DFLAG---------CR11096---------------------*/
/*IN THIS SECTION OF CODE,WE LOOK FOR THE DATA_REMOTE DIRECTIVE    */

            ELSE IF C='DATA_REMOTE'|C='ATA_REMOTE' THEN /*REMOTE #D*/
               DO;
                  DATA_REMOTE=TRUE;
/?P
                  /*CHECK FOR ILLEGAL LOCATION OF THE DIRECTIVE */
                  IF BLOCK_MODE ^= 0 THEN CALL ERRORS(CLASS_XR,1);
                  /* DR107308 - PART2 -- CHECK FOR ILLEGAL LOCATION OF */
                  /* THE DIRECTIVE INSIDE AN EXTERNAL BLOCK.           */
   /* DR107308 */ IF ((SYT_FLAGS(BLOCK_SYTREF(NEST))&EXTERNAL_FLAG)^=0)
   /* DR107308 */ THEN CALL ERRORS(CLASS_XR,1);
?/
               END;   /*ELSE IF C='DATA_REMOTE' */

/*-----------------------------------------------------------------*/
            ELSE CALL ERROR(CLASS_XU,1);                                        00477454
/?B
/* PMA ---------------------- CR11142 -----------------------------*/
/* THIS CODE RESTRICTS BFS FROM USING THE 'DATA_REMOTE' DIRECTIVE  */
/* AND WILL ISSUE A B102 ERROR MESSAGE.  THIS CODE WILL NEED TO BE */
/* REMOVED IF AND WHEN BFS BEGINS USING 'DATA_REMOTE'.             */
            IF DATA_REMOTE THEN DO;
               CALL ERROR(CLASS_B,102);
               DATA_REMOTE=FALSE;
            END;
/*-----------------------------------------------------------------*/
?/
ERRPRINT:                                                                       00477464
            CALL OUTPUT_WRITER;  /* PRINT ANY ERRORS */                         00477474
            IF ^INCLUDING THEN INCLUDE_STMT = -1;        /*DR109074*/
         END;                                                                   00477484
      END PROCESS_COMMENT;                                                      00477700
STACK_RETURN_CHAR:                                                              00477800
      PROCEDURE(NUMBER, CHAR);                                                  00477900
         DECLARE (NUMBER, I) BIT(16), CHAR BIT(8);                              00478000
         DO I = 0 TO 2;                                                         00478100
            IF RETURN_CHAR(I) = 0 THEN                                          00478200
               DO;                                                              00478300
               RETURN_CHAR(I) = NUMBER;                                         00478400
               TYPE_CHAR(I) = CHAR;                                             00478500
               RETURN;                                                          00478600
            END;                                                                00478700
         END;                                                                   00478800
      END STACK_RETURN_CHAR;                                                    00478900
READ_CARD:                                                                      00479000
      PROCEDURE;                                                                00479100
         IF END_OF_INPUT THEN                                                   00479300
            DO;                                                                 00479400
            CURRENT_CARD = INPUT_PAD || X70;                                    00479500
            RETURN;                                                             00479600
         END;                                                                   00479700
READ:                                                                           00479800
         CALL NEXT_RECORD;                                                      00479900
         IF LENGTH(CURRENT_CARD) > 88 THEN                                      00480000
            CURRENT_CARD = SUBSTR(CURRENT_CARD, 0, 88);                         00480100
         IF LENGTH(CURRENT_CARD) = 0 THEN                                       00480200
            DO;                                                                 00480300
            IF INCLUDING THEN DO;                                               00480400
               INPUT_DEV=0;                                                     00480410
               INCLUDE_COMPRESSED,INCLUDING=FALSE;                              00480600
               INCLUDE_STMT = -1;                             /*DR109074*/
               INCLUDE_END=TRUE;                                                00480610
 /?B                  /* CR11114 -- BFS/PASS INTERFACE; TEMPLATE LENGTH */
                  IF TEMPLATE_FLAG THEN TEXT_LIMIT=TEXT_LIMIT(1);
 ?/
               GOTO READ;                                                       00480620
            END;                                                                00480630
            ELSE                                                                00481100
               DO;                                                              00481200
               END_OF_INPUT = TRUE;                                             00481300
               CURRENT_CARD = INPUT_PAD || X70;                                 00481400
            END;                                                                00481500
         END;                                                                   00481600
         CARD_COUNT = CARD_COUNT + 1;                                           00481700
         IF LISTING2 THEN                                                       00481800
            IF CARD_COUNT ^= 0 THEN                                             00481900
            CALL SAVE_INPUT;                                                    00482000
         IF INCLUDE_END THEN                                                    00482100
            DO;                                                                 00482200
            INCLUDE_LIST2 = TRUE;                                               00482300
            INCLUDE_OFFSET, INCLUDE_COUNT = INCLUDE_COUNT + CARD_COUNT          00482400
               - INCLUDE_OFFSET;                                                00482500
         END;                                                                   00482600
         SAVE_CARD = CURRENT_CARD;                                              00482700
      END READ_CARD;                                                            00482800
                                                                                00482900
                                                                                00483000
SCAN_CARD:                                                                      00483100
      PROCEDURE(TYPE);                                                          00483200
         DECLARE (TYPE, POINT) FIXED;                                           00483300
         POINT = SHL(TYPE, IND_SHIFT);                                          00483400
         DO CP = 1 TO TEXT_LIMIT;                                               00483500
            IF BYTE(CURRENT_CARD, CP) ^= BYTE(X1) THEN              /*CR13335*/ 00483600
               DO;                                                              00483700
               IF BYTE(E_LINE(TYPE), CP) ^= BYTE(X1) THEN           /*CR13335*/ 00483800
                  DO CASE TYPE;                                                 00483900
                  CALL ERROR(CLASS_ME,4);                                       00484000
                  DO;                                                           00484100
                     CALL ERROR(CLASS_MS,4);                                    00484200
                     GO TO CONTINUE;                                            00484300
                  END;                                                          00484400
               END;                                                             00484500
               E_INDICATOR(CP + POINT) = E_COUNT(TYPE);                         00484600
               FILL = BYTE(CURRENT_CARD, CP);                                   00484700
               BYTE(E_LINE(TYPE), CP) = FILL;                                   00484800
            END;                                                                00484900
CONTINUE:                                                                       00485000
         END;                                                                   00485100
      END SCAN_CARD;                                                            00485200
                                                                                00485300
                                                                                00485400
COMP:                                                                           00485500
      PROCEDURE(TYPE);                                                          00485600
         DECLARE (TYPE, POINT) FIXED;                                           00485700
         POINT = "C5" + "1D" * TYPE;                                            00485800
         E_COUNT(TYPE) = 1;                                                     00485900
         DO FOREVER;                                                            00486000
            CALL SCAN_CARD(TYPE);                                               00486100
            CALL READ_CARD;                                                     00486200
            IF BYTE(CURRENT_CARD) ^= POINT THEN                                 00486300
               DO;  /* NO MORE OF THIS TYPE OF CARD */                          00486400
               IF ^ORDER_OK(POINT) THEN                                         00486500
                  CALL ERROR(CLASS_M,2);                                        00486600
               POINT = SHL(TYPE, IND_SHIFT);                                    00486700
               DO CP = 1 TO TEXT_LIMIT;                                         00486800
                  IF BYTE(E_LINE(TYPE), CP) = BYTE(X1) THEN         /*CR13335*/ 00486900
                     E_INDICATOR(CP + POINT) = 0;                               00487000
                  ELSE                                                          00487100
                     IF ^TYPE THEN                                              00487200
                     DO;                                                        00487300
                     FILL = E_COUNT - E_INDICATOR(CP) + 1;                      00487400
                     E_INDICATOR(CP) = FILL;                                    00487500
                  END;                                                          00487600
               END;                                                             00487700
               RETURN;                                                          00487800
            END;                                                                00487900
            E_COUNT(TYPE) = E_COUNT(TYPE) + 1;                                  00488000
         END;                                                                   00488100
      END COMP;                                                                 00488200
                                                                                00488300
                                                                                00488400
GET_GROUP:                                                                      00488500
      PROCEDURE;                                                                00488600
         E_LINE = BLANKS || BLANKS;                                             00488700
         S_LINE = BLANKS || BLANKS;                                             00488800
         LAST_E_COUNT = E_COUNT;                                                00488900
         LAST_S_COUNT = S_COUNT;                                                00489000
         E_COUNT, S_COUNT = 0;                                                  00489100
         IF ^INCREMENT_DOWN_STMT THEN   /*DR108603*/
            INCREMENT_DOWN_STMT = (LAST_WRITE <= STMT_PTR);                     00489150
         CALL OUTPUT_GROUP;                                                     00489200
         IF INCLUDE_END THEN                                                    00489300
            DO;                                                                 00489400
            CALL OUTPUT_WRITER(LAST_WRITE, STMT_PTR);                           00489500
            OUTPUT = X8 || STARS || 'END' || INCLUDE_MSG || STARS;              00489600
            NEXT_CC = DOUBLE;                               /*CR12713*/         00489700
            INCLUDE_LIST = TRUE;                                                00489800
            SRN_COUNT=0;                                                        00489900
            IF TPL_REMOTE THEN DO;                                              00489910
               CALL ERROR(CLASS_XI,5);                                          00489920
               TPL_REMOTE = FALSE;                                              00489930
            END;                                                                00489940
            INCLUDE_END = FALSE;                                                00490000
         END;                                                                   00490100
         GO TO LOOP;                                                            00490200
READ:    CALL READ_CARD;                                                        00490300
CHECK_ORDER:                                                                    00490400
         IF ^ ORDER_OK(PREV_CARD) THEN                                          00490500
            DO;                                                                 00490600
            CALL ERROR(CLASS_M,2);                                              00490700
            GO TO COMMENT_CARD;                                                 00490800
         END;                                                                   00490900
LOOP:                                                                           00491000
         IF END_GROUP THEN GO TO FOUND_GROUP;                                   00491100
         DO CASE CARD_TYPE(BYTE(CURRENT_CARD));                                 00491200
            ;  /* CASE 0--DUMMY */                                              00491300
            DO;  /* CASE 1--E LINE */                                           00491400
               CALL COMP(0);                                                    00491500
               GO TO LOOP;                                                      00491600
            END;                                                                00491700
            DO;  /* CASE 2--M LINE */                                           00491800
               M_LINE = CURRENT_CARD;                                           00491900
               IF SRN_PRESENT THEN DO;                                          00492000
                  IF INCLUDING THEN DO;                                         00492100
                     INCL_SRN = SUBSTR(CURRENT_CARD,TEXT_LIMIT+1);              00492110
                     SRN_COUNT = SRN_COUNT + 1;                                 00492120
                  END;                                                          00492130
                  ELSE DO;                         /*CR12940*/                  00492200
                     SRN=SUBSTR(CURRENT_CARD,TEXT_LIMIT+1);                     00492200
                     RVL(1) = SUBSTR(SRN,6,2);     /*CR12940*/
                  END;                             /*CR12940*/
               END;                                                             00492300
               BYTE(SAVE_CARD) = BYTE('M');                                     00492400
               PREV_CARD = BYTE(CURRENT_CARD);                                  00492500
               GO TO READ;                                                      00492600
            END;                                                                00492700
            DO;  /* CASE 3--S LINE */                                           00492800
               CALL COMP(1);                                                    00492900
               GO TO LOOP;                                                      00493000
            END;                                                                00493100
            DO;  /* CASE 4--COMMENT */                                          00493200
               BYTE(CURRENT_CARD) = BYTE('C');                                  00493210
COMMENT_CARD:                                                                   00493300
               IF PREV_CARD = BYTE('C') THEN                                    00493400
                  COMMENTING = TRUE;                                            00493500
               ELSE                                                             00493600
                  COMMENTING = FALSE;                                           00493700
               PREV_CARD = BYTE('C');                                           00493800

               /*----------------------------------------*/
               /* DR 105391 - INCORRECT SRN IN SDF.      */
               /* SAVE SRN FIELD FOR NON-INCLUDED SOURCE */
               /* CODE ONLY. (SRN'S OF COMMENTS ARE      */
               /* NOT NEEDED FOR INCLUDED SOURCE CODE)   */
               /*----------------------------------------*/

               IF SRN_PRESENT THEN DO;                                          00493900
                  IF ^INCLUDING THEN DO;                   /*CR12940*/          00493910
                     SRN=SUBSTR(CURRENT_CARD,TEXT_LIMIT+1);                     00493920
                     RVL = '';                             /*CR12940*/
                     RVL(1) = '';                          /*CR12940*/
                     NEXT_CHAR_RVL = '';                   /*CR12940*/
                   END;                                    /*CR12940*/
               END;

               CALL PROCESS_COMMENT;                                            00494100
               CALL READ_CARD;                                                  00494200
               IF INCLUDE_END THEN                                              00494300
                  DO;                                                           00494400
                  OUTPUT = X8 || STARS || 'END' || INCLUDE_MSG || STARS;        00494500
                  NEXT_CC = DOUBLE;                         /*CR12713*/         00489700
                  INCLUDE_LIST = TRUE;                                          00494700
                  SRN_COUNT=0;                                                  00494800
                  IF TPL_REMOTE THEN DO;                                        00494810
                     CALL ERROR(CLASS_XI,5);                                    00494820
                     TPL_REMOTE = FALSE;                                        00494830
                  END;                                                          00494840
                  INCLUDE_END = FALSE;                                          00494900
               END;                                                             00495000
               GO TO CHECK_ORDER;                                               00495100
            END;                                                                00495200
            DO;  /* CASE 5--DIRECTIVE */                                        00495210
               BYTE(CURRENT_CARD) = BYTE('D');                                  00495220
               GO TO COMMENT_CARD;                                              00495230
            END;                                                                00495240
         END;  /* OF DO CASE */                                                 00495300
FOUND_GROUP:                                                                    00495400
         END_GROUP = FALSE;                                                     00495500
         E_LINE = SUBSTR(E_LINE, 0, LENGTH(M_LINE));                            00495600
         IF E_COUNT ^> 0 THEN                                                   00495700
            DO;                                                                 00495800
            DO CP = 1 TO TEXT_LIMIT;                                            00495900
               E_INDICATOR(CP) = 0;                                             00496000
            END;                                                                00496100
            E_COUNT = LAST_E_COUNT;                                             00496200
         END;                                                                   00496300
         S_LINE = SUBSTR(S_LINE, 0, LENGTH(M_LINE));                            00496400
         IF S_COUNT ^> 0 THEN                                                   00496500
            DO;                                                                 00496600
            DO CP = 1 TO TEXT_LIMIT;                                            00496700
               S_INDICATOR(CP) = 0;                                             00496800
            END;                                                                00496900
            S_COUNT = LAST_S_COUNT;                                             00497000
         END;                                                                   00497100
      END GET_GROUP;                                                            00497200
                                                                                00497300
                                                                                00497400
CHOP:                                                                           00497500
      PROCEDURE;                                                                00497600
         INDEX = INDEX + 1;                                                     00497700
         IF INDEX > TEXT_LIMIT THEN                                             00497800
          IF ^INCLUDING | ^TEMPLATE_FLAG |               /*DR111314*/
            (INCLUDING & TEMPLATE_FLAG &                 /*DR111314*/
            (INDEX > (TPL_LRECL-1))) THEN                /*DR111314*/
            IF (CARD_TYPE(BYTE(CURRENT_CARD)) >= 4) | INCLUDE_END THEN          00497900
            GROUP_NEEDED = TRUE;                                                00498000
         ELSE                                                                   00498100
            DO;  /* OUT OF DATA--GET MORE */                                    00498200
            CALL GET_GROUP;                                                     00498300
            INDEX = 1;                                                          00498400
         END;                                                                   00498500
      END CHOP;                                                                 00498600
                                                                                00498700
                                                                                00498800
STACK:                                                                          00498900
      PROCEDURE(TYPE);                                                          00499000
         DECLARE (TYPE, POINT) FIXED;                                           00499100
         POINT = EP(TYPE) + SHL(TYPE, IND_SHIFT);                               00499200
         IF EP(TYPE) < 0 THEN                                                   00499300
            GO TO NOT_MULTIPLE;                                                 00499400
         IF BYTE(E_LINE(TYPE), INDEX) = BYTE(X1) THEN               /*CR13335*/ 00499500
            DO;                                                                 00499600
            IF BYTE(E_STACK(TYPE), EP(TYPE)) = BYTE(X1) THEN        /*CR13335*/ 00499700
               E_IND(POINT) = E_IND(POINT) + 1;                                 00499800
            ELSE                                                                00499900
               GO TO NOT_MULTIPLE;                                              00500000
         END;                                                                   00500100
         ELSE                                                                   00500200
            DO;                                                                 00500300
NOT_MULTIPLE:                                                                   00500400
            EP(TYPE) = EP(TYPE) + 1;                                            00500500
            IF EP(TYPE) > IND_LIM THEN                                          00500600
               DO CASE TYPE;                                                    00500700
               CALL ERROR(CLASS_ME,1); /* CR12416 */                            00500800
               CALL ERROR(CLASS_MS,1); /* CR12416 */                            00500900
            END;                                                                00501000
            POINT = POINT + 1;                                                  00501100
            CHAR_TEMP = SUBSTR(E_LINE(TYPE), INDEX, 1);                         00501200
            IF CHAR_TEMP ^= X1 THEN NONBLANK_FOUND = TRUE;          /*CR13335*/ 00501300
            E_STACK(TYPE) = E_STACK(TYPE) || CHAR_TEMP;                         00501400
            E_IND(POINT) = E_INDICATOR(INDEX + SHL(TYPE, IND_SHIFT));           00501500
         END;                                                                   00501600
      END STACK;                                                                00501700
                                                                                00501800
                                                                                00501900
BUILD_XSCRIPTS:                                                                 00502000
      PROCEDURE;                                                                00502100
         S_STACK, E_STACK = '';                                                 00502200
         S_BLANKS, E_BLANKS = -1;                                               00502300
         SP, EP = -1;                                                           00502400
CHECK_M:                                                                        00502500
         IF BYTE(M_LINE, INDEX) = BYTE(X1) THEN                     /*CR13335*/ 00502600
            DO;                                                                 00502700
            CALL STACK(0);                                                      00502800
            CALL STACK(1);                                                      00502900
            CALL CHOP;                                                          00503000
            IF ^GROUP_NEEDED THEN                                               00503100
               GO TO CHECK_M;                                                   00503200
         END;                                                                   00503300
         IF GROUP_NEEDED THEN                                                   00503400
            IF NONBLANK_FOUND THEN DO;                                          00503500
            CALL GET_GROUP;                                                     00503600
            INDEX = 1;                                                          00503700
            GROUP_NEEDED = FALSE;                                               00503800
            GO TO CHECK_M;                                                      00503900
         END;                                                                   00504000
         NONBLANK_FOUND = FALSE;                                                00504100
         IF BYTE(S_STACK, SP) = BYTE(X1) THEN                       /*CR13335*/ 00504200
            DO;                                                                 00504300
            IF SP > 0 THEN                                                      00504400
               S_STACK = SUBSTR(S_STACK, 0, SP);                                00504500
            ELSE                                                                00504600
               S_STACK = '';                                                    00504700
            S_BLANKS = S_IND(SP);                                               00504800
         END;                                                                   00504900
         IF BYTE(E_STACK, EP) = BYTE(X1) THEN                       /*CR13335*/ 00505000
            DO;                                                                 00505100
            IF EP > 0 THEN                                                      00505200
               E_STACK = SUBSTR(E_STACK, 0, EP);                                00505300
            ELSE                                                                00505400
               E_STACK = '';                                                    00505500
            E_BLANKS = E_IND(EP);                                               00505600
         END;                                                                   00505700
         IF E_BLANKS >= S_BLANKS THEN                                           00505800
            M_BLANKS = S_BLANKS;                                                00505900
         ELSE                                                                   00506000
            M_BLANKS = E_BLANKS;                                                00506100
      END BUILD_XSCRIPTS;                                                       00506200
MACRO_DIAGNOSTICS:                                                              00506300
      PROCEDURE (WHERE);                                                        00506310
         DECLARE WHERE BIT(16);                                                 00506320
                                                                                00506330
        OUTPUT = 'AT '||WHERE||'  NEXT_CHAR='||NEXT_CHAR||'  MACRO_EXPAN_LEVEL='00506340
            ||MACRO_EXPAN_LEVEL||'  MACRO_TEXT('||MACRO_POINT||')='||           00506350
            MACRO_TEXT(MACRO_POINT)||'  PARM_REPLACE_PTR('||PARM_EXPAN_LEVEL||  00506360
            ')='||PARM_REPLACE_PTR(PARM_EXPAN_LEVEL);                           00506370
      END MACRO_DIAGNOSTICS;                                                    00506380
                                                                                00506400
STREAM_START:                                                                   00506500
CHECK_STRING_POSITION:                                                          00506600
      IF MACRO_EXPAN_LEVEL > 0 THEN DO;                                         00506700
         OVER_PUNCH = 0;  /* FIX ESCAPE BUG WITHIN MACRO */                     00506710
         IF PARM_EXPAN_LEVEL > BASE_PARM_LEVEL(MACRO_EXPAN_LEVEL) THEN          00506800
            IF PARM_EXPAN_LEVEL>=PARM_EXPAN_LIMIT THEN DO;                      00506900
            CALL ERROR(CLASS_IR,6, 0);                                          00507000
            MACRO_EXPAN_LEVEL,PARM_EXPAN_LEVEL,MACRO_FOUND=0;                   00507100
            GO TO MACRO_DONE;                                                   00507200
         END;                                                                   00507300
         ELSE                                                                   00507400
           IF PARM_REPLACE_PTR(PARM_EXPAN_LEVEL) < LENGTH(MACRO_CALL_PARM_TABLE(00507500
            PARM_STACK_PTR(PARM_EXPAN_LEVEL))) THEN DO;                         00507600
            NEXT_CHAR=BYTE(MACRO_CALL_PARM_TABLE(PARM_STACK_PTR(                00507700
               PARM_EXPAN_LEVEL)),PARM_REPLACE_PTR(PARM_EXPAN_LEVEL));          00507800
            PARM_REPLACE_PTR(PARM_EXPAN_LEVEL) =                                00507900
               PARM_REPLACE_PTR(PARM_EXPAN_LEVEL) + 1 ;                         00508000
            IF CONTROL(3) THEN CALL MACRO_DIAGNOSTICS(1);                       00508010
            RETURN;                                                             00508100
         END;                                                                   00508200
         ELSE DO;                                                               00508300
            IF FIRST_TIME_PARM(PARM_EXPAN_LEVEL) THEN DO;                       00508400
               IF P_CENT(PARM_EXPAN_LEVEL) THEN DO;                             00508500
                  P_CENT(PARM_EXPAN_LEVEL)=FALSE;                               00508600
PARM_DONE:        FIRST_TIME_PARM(PARM_EXPAN_LEVEL)=TRUE;                       00508700
                  PARM_EXPAN_LEVEL=PARM_EXPAN_LEVEL-1;                          00508800
                  GO TO CHECK_STRING_POSITION;                                  00508900
               END;                                                             00509000
               NEXT_CHAR=BYTE(X1);                                  /*CR13335*/ 00509100
               FIRST_TIME_PARM(PARM_EXPAN_LEVEL)=FALSE;                         00509200
               IF CONTROL(3) THEN CALL MACRO_DIAGNOSTICS(2);                    00509210
               RETURN;                                                          00509300
            END;                                                                00509400
            ELSE GO TO PARM_DONE;                                               00509500
         END;                                                                   00509600
         IF MACRO_TEXT(MACRO_POINT) ^= "EF" THEN DO;                            00509700
            BLANK_COUNT = 0;                                                    00509800
            IF MACRO_TEXT(MACRO_POINT) = "EE" THEN DO;                          00509900
               MACRO_POINT=MACRO_POINT+1;                                       00510000
               BLANK_COUNT=MACRO_TEXT(MACRO_POINT);                             00510100
               NEXT_CHAR = BYTE(X1);                                /*CR13335*/ 00510200
            END;                                                                00510300
            ELSE NEXT_CHAR=MACRO_TEXT(MACRO_POINT);                             00510400
            MACRO_POINT=MACRO_POINT + 1;                                        00510500
            IF CONTROL(3) THEN CALL MACRO_DIAGNOSTICS(3);                       00510510
            RETURN;                                                             00510600
         END;                                                                   00510700
         IF FIRST_TIME(MACRO_EXPAN_LEVEL) THEN DO;                              00510800
            IF ^M_CENT(MACRO_EXPAN_LEVEL) THEN DO;                              00510900
               FIRST_TIME(MACRO_EXPAN_LEVEL)= FALSE;                            00511000
               NEXT_CHAR = BYTE(X1);                                /*CR13335*/ 00511100
               IF CONTROL(3) THEN CALL MACRO_DIAGNOSTICS(4);                    00511110
               RETURN;                                                          00511200
            END;                                                                00511300
         END;                                                                   00511400
         ELSE FIRST_TIME(MACRO_EXPAN_LEVEL)=TRUE;                               00511500
         TOP_OF_PARM_STACK=TOP_OF_PARM_STACK-NUM_OF_PARM(MACRO_EXPAN_LEVEL);    00511600
         PRINTING_ENABLED=M_PRINT(MACRO_EXPAN_LEVEL);                           00511700
         IF ^M_CENT(MACRO_EXPAN_LEVEL) THEN  /* DR109035,DR111335 */
            IF ^DONT_SET_WAIT THEN                    /* DR111335 */            00511900
               WAIT = TRUE;                           /* DR111335 */            00512000
         MACRO_EXPAN_LEVEL = MACRO_EXPAN_LEVEL - 1;                             00512200
         MACRO_POINT=M_P(MACRO_EXPAN_LEVEL);                                    00512300
         BLANK_COUNT = M_BLANK_COUNT(MACRO_EXPAN_LEVEL);                        00512400
         IF MACRO_EXPAN_LEVEL = 0 THEN DO;                                      00512500
            MACRO_FOUND = FALSE ;                                               00512600
MACRO_DONE:                                                                     00512700
            NEXT_CHAR = SAVE_NEXT_CHAR;                                         00512800
            OVER_PUNCH = SAVE_OVER_PUNCH;                                       00512900
            PRINTING_ENABLED=PRINT_FLAG;                                        00513000
            IF CONTROL(3) THEN CALL MACRO_DIAGNOSTICS(5);                       00513010
            RETURN;                                                             00513100
         END;                                                                   00513200
         ELSE GO TO CHECK_STRING_POSITION;                                      00513300
      END;                                                                      00513400
      BLANK_COUNT = -1;                                                         00513500
STACK_CHECK:                                                                    00513600
      DO II = II TO 2;                                                          00513700
         IF RETURN_CHAR(II) ^= 0 THEN                                           00513800
            DO;                                                                 00513900
            ARROW_FLAG = TRUE;                                                  00514000
            RETURN_CHAR(II) = RETURN_CHAR(II) - 1;                              00514100
            NEXT_CHAR = TYPE_CHAR(II);                                          00514200
            OVER_PUNCH = 0;                                                     00514300
            RETURN;                                                             00514400
         END;                                                                   00514500
      END;                                                                      00514600
      II = 0;                                                                   00514700
      IF ARROW_FLAG THEN                                                        00514800
         DO;                                                                    00514900
         ARROW_FLAG = FALSE;                                                    00515000
         NEXT_CHAR = SAVE_NEXT_CHAR1;                                           00515100
         OVER_PUNCH = SAVE_OVER_PUNCH1;                                         00515200
         BLANK_COUNT = SAVE_BLANK_COUNT1;                                       00515300
         RETURN;                                                                00515400
      END;                                                                      00515500
      IF GROUP_NEEDED THEN                                                      00515600
         DO;                                                                    00515700
         CALL GET_GROUP;                                                        00515800
         INDEX = 1;                                                             00515900
         GROUP_NEEDED = FALSE;                                                  00516000
      END;                                                                      00516100
BEGINNING:                                                                      00516200
      IF RETURNING_M THEN                                                       00516300
         DO;                                                                    00516400
         IF M_BLANKS >= 0 THEN                                                  00516500
            DO;                                                                 00516600
            NEXT_CHAR = BYTE(X1);                                   /*CR13335*/ 00516700
            ARROW = -LAST_E_IND;                                                00516800
            LAST_E_IND = 0;                                                     00516900
            BLANK_COUNT = M_BLANKS;                                             00517000
            M_BLANKS = -1;                                                      00517100
            GO TO FOUND_CHAR;                                                   00517200
         END;                                                                   00517300
         IF BYTE(M_LINE, INDEX) ^= BYTE(X1) THEN                    /*CR13335*/ 00517400
            DO;                                                                 00517500
            IF E_COUNT > 0 THEN                                                 00517600
               DO;                                                              00517700
               IF BYTE(E_LINE, INDEX) ^= BYTE(X1) THEN              /*CR13335*/ 00517800
                  DO;                                                           00517900
                  IF E_INDICATOR(INDEX) ^= 1 THEN                               00518000
                     CALL ERROR(CLASS_ME,3);                                    00518100
                  ELSE                                                          00518200
                     OVER_PUNCH = BYTE(E_LINE, INDEX);                          00518300
               END;                                                             00518400
               ELSE                                                             00518500
                  OVER_PUNCH = 0;                                               00518600
            END;                                                                00518700
            ELSE                                                                00518800
               OVER_PUNCH = 0;                                                  00518900
            IF S_COUNT > 0 THEN                                                 00519000
               IF BYTE(S_LINE, INDEX) ^= BYTE(X1) THEN              /*CR13335*/ 00519100
               CALL ERROR(CLASS_MS,3);                                          00519200
            ARROW = -LAST_E_IND;                                                00519300
            LAST_E_IND = 0;                                                     00519400
            IF ^INCLUDING THEN DO;                   /*CR12940*/
            /*CHECK THE RVL FOR EACH CHARACTER AS IT IS READ.  RVL WILL */
            /*HOLD THE MOST RECENT RVL ASSOCIATED WITH A TOKEN.         */
               IF STRING_GT(NEXT_CHAR_RVL,RVL) THEN  /*CR12940*/
                  RVL = NEXT_CHAR_RVL;               /*CR12940*/
               NEXT_CHAR_RVL = RVL(1);               /*CR12940*/
            END;                                     /*CR12940*/
            NEXT_CHAR = BYTE(M_LINE, INDEX);                                    00519500
            CALL CHOP;                                                          00519600
            GO TO FOUND_CHAR;                                                   00519700
         END;                                                                   00519800
         ELSE                                                                   00519900
            DO;                                                                 00520100
            CALL BUILD_XSCRIPTS;                                                00520200
            OVER_PUNCH = 0;                                                     00520300
            RETURNING_M = FALSE;                                                00520400
            LAST_S_IND = 0;                                                     00520500
            RETURNING_S = TRUE;                                                 00520600
            PNTR = 0;                                                           00520700
         END;                                                                   00520800
      END;                                                                      00520900
      IF RETURNING_S THEN                                                       00521000
         DO;                                                                    00521100
         IF LENGTH(S_STACK) > 0 & PNTR < LENGTH(S_STACK) THEN                   00521200
            DO;                                                                 00521300
            IF BYTE(S_STACK, PNTR) = BYTE(X1) THEN                  /*CR13335*/ 00521400
               DO;                                                              00521500
               IF S_IND(PNTR) >= 0 THEN   /* MORE LEFT */                       00521600
                  DO;                                                           00521700
                  NEXT_CHAR = BYTE(X1);                             /*CR13335*/ 00521800
                  BLANK_COUNT = S_IND(PNTR);                                    00521900
                  PNTR = PNTR + 1;                                              00522000
                  ARROW = LAST_S_IND - S_IND(PNTR);                             00522100
                  LAST_S_IND = S_IND(PNTR);                                     00522200
               END;                                                             00522300
            END;                                                                00522400
            ELSE   /* A NON-BLANK */                                            00522500
               DO;                                                              00522600
               NEXT_CHAR = BYTE(S_STACK, PNTR);                                 00522700
               ARROW = LAST_S_IND - S_IND(PNTR);                                00522800
               LAST_S_IND = S_IND(PNTR);                                        00522900
               PNTR = PNTR + 1;                                                 00523000
            END;                                                                00523100
            GO TO FOUND_CHAR;                                                   00523200
         END;                                                                   00523300
         ELSE    /* CAN'T RETURN S */                                           00523400
            DO;                                                                 00523500
            RETURNING_S = FALSE;                                                00523600
            RETURNING_E = TRUE;                                                 00523700
            LAST_E_IND = -LAST_S_IND;                                           00523800
            PNTR = 0;                                                           00523900
         END;                                                                   00524000
      END;                                                                      00524100
      IF RETURNING_E THEN                                                       00524200
         DO;                                                                    00524300
         IF LENGTH(E_STACK) > 0 & PNTR < LENGTH(E_STACK) THEN                   00524400
            DO;                                                                 00524500
            IF BYTE(E_STACK, PNTR) = BYTE(X1) THEN                  /*CR13335*/ 00524600
               DO;                                                              00524700
               IF E_IND(PNTR) >= 0 THEN   /* MORE TO GO */                      00524800
                  DO;                                                           00524900
                  NEXT_CHAR = BYTE(X1);                             /*CR13335*/ 00525000
                  BLANK_COUNT = E_IND(PNTR);                                    00525100
                  PNTR = PNTR + 1;                                              00525200
                  ARROW = E_IND(PNTR) - LAST_E_IND;                             00525300
                  LAST_E_IND = E_IND(PNTR);                                     00525400
               END;                                                             00525500
            END;                                                                00525600
            ELSE    /* A NON-BLANK */                                           00525700
               DO;                                                              00525800
               NEXT_CHAR = BYTE(E_STACK, PNTR);                                 00525900
               ARROW = E_IND(PNTR) - LAST_E_IND;                                00526000
               LAST_E_IND = E_IND(PNTR);                                        00526100
               PNTR = PNTR + 1;                                                 00526200
            END;                                                                00526300
            GO TO FOUND_CHAR;                                                   00526400
         END;                                                                   00526500
         ELSE  /* CAN'T RETURN E */                                             00526600
            DO;                                                                 00526700
            RETURNING_E = FALSE;                                                00526800
            RETURNING_M = TRUE;                                                 00526900
         END;                                                                   00527000
      END;                                                                      00527100
      GO TO BEGINNING;                                                          00527200
FOUND_CHAR:                                                                     00527300
      IF ARROW ^= 0 THEN                                                        00527400
         DO;                                                                    00527500
         OLD_LEVEL = NEW_LEVEL;                                                 00527600
         NEW_LEVEL = NEW_LEVEL + ARROW;                                         00527700
         SAVE_OVER_PUNCH1 = OVER_PUNCH;                                         00527800
         SAVE_NEXT_CHAR1 = NEXT_CHAR;                                           00527900
         SAVE_BLANK_COUNT1 = BLANK_COUNT;                                       00528000
         IF OLD_LEVEL > 0 THEN                                                  00528100
            DO;                                                                 00528200
            IF ARROW < 0 THEN                                                   00528300
               CALL STACK_RETURN_CHAR(-ARROW, BYTE(')'));                       00528400
            ELSE                                                                00528500
EXPONENT:                                                                       00528600
            DO;                                                                 00528700
               IF ARROW > 1 THEN                                                00528800
                  CALL ERROR(CLASS_ME,2);                                       00528900
               CALL STACK_RETURN_CHAR(2, BYTE('*'));                            00529000
               CALL STACK_RETURN_CHAR(ARROW, BYTE('('));                        00529100
            END;                                                                00529200
         END;                                                                   00529300
         ELSE                                                                   00529400
            IF OLD_LEVEL = 0 THEN                                               00529500
            DO;                                                                 00529600
            IF ARROW < 0 THEN                                                   00529700
SUBS:                                                                           00529800
            DO;                                                                 00529900
               IF ARROW < -1 THEN                                               00530000
                  CALL ERROR(CLASS_MS,2);                                       00530100
               CALL STACK_RETURN_CHAR(1, BYTE('$'));                            00530200
               CALL STACK_RETURN_CHAR(-ARROW, BYTE('('));                       00530300
            END;                                                                00530400
            ELSE                                                                00530500
               GO TO EXPONENT;                                                  00530600
         END;                                                                   00530700
         ELSE                                                                   00530800
            DO;   /* OLD < 0 */                                                 00530900
            IF ARROW < 0 THEN                                                   00531000
               GO TO SUBS;                                                      00531100
            IF NEW_LEVEL <= 0 THEN                                              00531200
               CALL STACK_RETURN_CHAR(ARROW, BYTE(')'));                        00531300
            ELSE                                                                00531400
               DO;                                                              00531500
               CALL STACK_RETURN_CHAR(-OLD_LEVEL, BYTE(')'));                   00531600
               IF NEW_LEVEL > 1 THEN                                            00531700
                  CALL ERROR(CLASS_ME,2);                                       00531800
               CALL STACK_RETURN_CHAR(2, BYTE('*'));                            00531900
               CALL STACK_RETURN_CHAR(NEW_LEVEL, BYTE('('));                    00532000
            END;                                                                00532100
         END;                                                                   00532200
         ARROW = 0;                                                             00532300
         GO TO STACK_CHECK;                                                     00532400
      END;                                                                      00532500
      RETURN;                                                                   00532600
   END STREAM   /*  $S  */  ;  /*  $S   */                                      00532700
