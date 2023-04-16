 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INITIALI.xpl
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
 /* PROCEDURE NAME:  INITIALISE                                             */
 /* MEMBER NAME:     INITIALI                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*       ADDRESSABLE       LABEL              PROCENTRY         LABEL      */
 /*       ALLOCATE_TEMPLATE LABEL              PTRARG(255)       BIT(8)     */
 /*       CHECK_COMPILABLE  LABEL              SDF_INCLUDED      BIT(8)     */
 /*       CONST             MACRO              SET_BIT_TYPE      LABEL      */
 /*       CONSTERM          LABEL              SET_NEST_AND_LOCKS  LABEL    */
 /*       DATAPOINT         BIT(16)            SET_PROCESS_SIZE  LABEL      */
 /*       DENSEWORDS        BIT(16)            SETUP_DATA        LABEL      */
 /*       ENTER             LABEL              SETUP_DATABASE    LABEL      */
 /*       EXTTYPE           LABEL              SETUP_REMOTE_DATA LABEL      */
 /*       FIXARG            MACRO              SETUP_STACKS      LABEL      */
 /*       FLTARG            MACRO              SETUP_XPROG       LABEL      */
 /*       FORMALP           LABEL              SINGLE_VALUED     LABEL      */
 /*       FORMALS           LABEL              STARTBASE         BIT(16)    */
 /*       FUNC_PARM         LABEL              STORAGE_ASSIGNMENT  LABEL    */
 /*       K                 FIXED              STRUCT_PARM_FIX   LABEL      */
 /*       L                 FIXED              SYMBOL_USED       LABEL      */
 /*       PARAMETER_ALLOCATE  LABEL            VARIABLES         LABEL      */
 /*       PARMTYPE          BIT(16)                                         */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*       ADCON                                POINTER_FLAG                 */
 /*       ANY_LABEL                            PROC#                        */
 /*       APOINTER                             PROG_LABEL                   */
 /*       ASSIGN_OR_NAME                       PROGBASE                     */
 /*       AUTO_FLAG                            PTRARG1                      */
 /*       BASE_NUM                             R_BASE                       */
 /*       BIGHTS                               R_SECTION                    */
 /*       BITESIZE                             REENTRANT_FLAG               */
 /*       BITS                                 REMOTE_BASE                  */
 /*       BOOLEAN                              REMOTE_FLAG                  */
 /*       BRANCH_TBL                           REMOTE#R                     */
 /*       CHAR                                 RIGHTBRACKET                 */
 /*       CLASS_BI                             RIGID_FLAG                   */
 /*       CLASS_BS                             SCALAR                       */
 /*       CLASS_BX                             SDF_INCL_FLAG                */
 /*       CLASS_PE                             SDF_INCL_LIST                */
 /*       CODE_SIZE                            SECTION                      */
 /*       CODEHWM_HEAD                         SSTYPE                       */
 /*       COMMA                                STMT_LABEL                   */
 /*       COMPOOL_LABEL                        STMTNUM                      */
 /*       CONSTANT_FLAG                        STRUCTURE                    */
 /*       CR_REF                               SYM                          */
 /*       CROSS_REF                            SYM_ADDR                     */
 /*       CSYM                                 SYM_ARRAY                    */
 /*       DATA_REMOTE                          SYM_BASE                     */
 /*       DATATYPE                             SYM_CLASS                    */
 /*       DEFINED_BLOCK                        SYM_CONST                    */
 /*       DEFINED_LABEL                        SYM_DISP                     */
 /*       DENSE_FLAG                           SYM_FLAGS                    */
 /*       DINTEGER                             SYM_LENGTH                   */
 /*       DNS                                  SYM_LEVEL                    */
 /*       DOUBLE_ACC                           SYM_LINK1                    */
 /*       DOUBLE_FLAG                          SYM_LINK2                    */
 /*       ESD_CHAR_LIMIT                       SYM_LOCK#                    */
 /*       EVENT                                SYM_NAME                     */
 /*       EVIL_FLAGS                           SYM_NEST                     */
 /*       EXCLUSIVE_FLAG                       SYM_PARM                     */
 /*       EXTENT                               SYM_PTR                      */
 /*       EXTERNAL_FLAG                        SYM_SCOPE                    */
 /*       FALSE                                SYM_SORT                     */
 /*       FIRSTSTMT#                           SYM_TYPE                     */
 /*       FIXARG1                              SYM_XREF                     */
 /*       FIXED_ACC                            SYT_ADDR                     */
 /*       FL_NO_MAX                            SYT_ARRAY                    */
 /*       FOREVER                              SYT_BASE                     */
 /*       FR0                                  SYT_CLASS                    */
 /*       FR7                                  SYT_CONST                    */
 /*       FULLBIT                              SYT_DIMS                     */
 /*       FULLWORD                             SYT_DISP                     */
 /*       HALFWORDSIZE                         SYT_FLAGS                    */
 /*       IGNORE_FLAG                          SYT_LABEL                    */
 /*       IMD                                  SYT_LEVEL                    */
 /*       INCLUDED_REMOTE                      SYT_LINK1                    */
 /*       INDEX_REG                            SYT_LINK2                    */
 /*       INL                                  SYT_LOCK#                    */
 /*       LAB_LOC                              SYT_MAX                      */
 /*       LATCH_FLAG                           SYT_NAME                     */
 /*       LEFTBRACKET                          SYT_NEST                     */
 /*       LIB_NAMES                            SYT_PARM                     */
 /*       LIB_NUM                              SYT_PTR                      */
 /*       LINKREG                              SYT_SCOPE                    */
 /*       LIT                                  SYT_SORT                     */
 /*       MAJ_STRUC                            SYT_TYPE                     */
 /*       MATRIX                               SYT_XREF                     */
 /*       MAX_SCOPE#                           TASK_LABEL                   */
 /*       MOVEABLE                             TEMPBASE                     */
 /*       NAME_FLAG                            TEMPL_NAME                   */
 /*       NAME_OR_REMOTE                       TEMPORARY_FLAG               */
 /*       NONHAL_FLAG                          TOGGLE                       */
 /*       NOTLEAF_FLAG                         TRUE                         */
 /*       ODD_REG                              VAC                          */
 /*       OFF_PAGE_MAX                         VALS                         */
 /*       OFFSET                               VECTOR                       */
 /*       OPMODE                               WORK                         */
 /*       OPTION_BITS                          XREF                         */
 /*       PACKFUNC_CLASS                       XTNT                         */
 /*       PACKTYPE                             X2                           */
 /*       PAGE_FIX                             X72                          */
 /*       PARM_FLAGS                                                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*       ASSEMBLER_CODE                       NOT_LEAF                     */
 /*       BASE_REGS                            NOT_MODIFIER                 */
 /*       CALL#                                OFF_PAGE_BASE                */
 /*       CMPUNIT_ID                           OLD_LINKAGE                  */
 /*       CODE_LIM                             OP1                          */
 /*       CODE_LISTING_REQUESTED               OP2                          */
 /*       COMM                                 OVERFLOW_LEVEL               */
 /*       COMPACT_CODE                         PACKFORM                     */
 /*       CONSTANTS                            PCEBASE                      */
 /*       DATABASE                             PROC_LEVEL                   */
 /*       DATALIMIT                            PROC_LINK                    */
 /*       DECK_REQUESTED                       PROCLIMIT                    */
 /*       DIAGNOSTICS                          PROCPOINT                    */
 /*       DOSORT                               PROGDATA                     */
 /*       DOUBLEFLAG                           PROGPOINT                    */
 /*       DSECLR                               P2SYMS                       */
 /*       DSESET                               R_INX                        */
 /*       DSR                                  RCLASS_START                 */
 /*       DUMMY                                REGISTER_SAVE_AREA           */
 /*       ENTRYPOINT                           REGISTER_TRACE               */
 /*       ERRALLGRP                            REGISTERS                    */
 /*       ERRSEG                               REGOPT                       */
 /*       ESD_MAX                              REMOTE_LEVEL                 */
 /*       ESD_NAME                             SDL                          */
 /*       EXCLBASE                             SELF_ALIGNING                */
 /*       EXCLUSIVE#                           SELFNAMELOC                  */
 /*       EXTRA_LISTING                        SREF                         */
 /*       FIRST_INST                           STACKPOINT                   */
 /*       FIRSTREMOTE                          STACKSPACE                   */
 /*       FSIMBASE                             STATNOLIMIT                  */
 /*       HALMAT_REQUESTED                     STRUCT_LINK                  */
 /*       INDEXNEST                            STRUCT_START                 */
 /*       IX1                                  SYM_TAB                      */
 /*       IX2                                  SYMBREAK                     */
 /*       LABELSIZE                            SYMFORM                      */
 /*       LASTBASE                             SYSARG0                      */
 /*       LASTREMOTE                           SYSARG1                      */
 /*       LIB_NAME_INDEX                       SYSARG2                      */
 /*       LOCCTR                               SYT_SIZE                     */
 /*       MAX_SEVERITY                         TAG2                         */
 /*       MAX_SRS_DISP                         TASK#                        */
 /*       MAXERR                               TASKPOINT                    */
 /*       MAXTEMP                              TEMPSPACE                    */
 /*       NARGS                                TMP                          */
 /*       NDECSY                               TRACING                      */
 /*       NEW_INSTRUCTIONS                     WORKSEG                      */
 /*       NEXTDECLREG                          WORK2                        */
 /*       NO_SRS                               XPROGLINK                    */
 /*       NO_VM_OPT                            Z_LINKAGE                    */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*       ADJUST                               GETSTATNO                    */
 /*       CHAR_INDEX                           HEX                          */
 /*       CHECKSIZE                            MAX                          */
 /*       CSECT_TYPE                           NAMESIZE                     */
 /*       CS                                   NEED_STACK                   */
 /*       ENTER_ESD                            PRIM_TO_OVFL                 */
 /*       ERRORS                               PROGNAME                     */
 /*       ESD_TABLE                            SET_MASKING_BIT              */
 /*       GETARRAY#                            SETUP_STACK                  */
 /*       GETARRAYDIM                          UNSPEC                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> INITIALISE <==                                                      */
 /*     ==> CSECT_TYPE                                                      */
 /*     ==> MAX                                                             */
 /*     ==> CHAR_INDEX                                                      */
 /*     ==> HEX                                                             */
 /*     ==> ESD_TABLE                                                       */
 /*     ==> ENTER_ESD                                                       */
 /*         ==> PAD                                                         */
 /*     ==> PRIM_TO_OVFL                                                    */
 /*         ==> ESD_TABLE                                                   */
 /*     ==> SETUP_STACK                                                     */
 /*     ==> ADJUST                                                          */
 /*     ==> CS                                                              */
 /*     ==> NEED_STACK                                                      */
 /*         ==> NO_BRANCH_AROUND                                            */
 /*             ==> EMIT_NOP                                                */
 /*                 ==> EMITC                                               */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*                     ==> HEX_LOCCTR                                      */
 /*                         ==> HEX                                         */
 /*                     ==> GET_CODE                                        */
 /*                 ==> EMITW                                               */
 /*                     ==> HEX                                             */
 /*                     ==> HEX_LOCCTR ****                                 */
 /*                     ==> GET_CODE                                        */
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
 /*     ==> CHECKSIZE                                                       */
 /*         ==> ERRORS ****                                                 */
 /*     ==> GETSTATNO                                                       */
 /*         ==> ERRORS ****                                                 */
 /*     ==> GETARRAYDIM                                                     */
 /*     ==> GETARRAY#                                                       */
 /*     ==> NAMESIZE                                                        */
 /*     ==> PROGNAME                                                        */
 /*         ==> CHAR_INDEX                                                  */
 /*     ==> SET_MASKING_BIT                                                 */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> LOCATE                                                      */
 /*         ==> ERRORS ****                                                 */
 /*     ==> UNSPEC                                                          */
 /*                                                                         */
 /*                                                                         */
 /*  **** - BRANCH PREVIOUSLY EXPANDED                                      */
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*10/14/90 RAH   23V1  102952 SIMPLE ASSIGNMENT ERROR WITH REMOTE INTEGER  */
 /*                            DATA                                         */
 /*01/21/91 DKB   23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /*02/15/91 LWW   23V2  CR11095  SPLIT THE COMPILER SDL OPTION              */
 /*                                                                         */
 /*03/04/91 RAH   23V2  CR11109 CLEANUP OF COMPILER SOURCE CODE             */
 /*                                                                         */
 /*07/08/91 RSJ   24V0  CR11096 #DFLAG - IF DATA_REMOTE IS USED CLEAR       */
 /*                             ALL NON-NAME #D REMOTE_FLAGS                */
 /*                                                                         */
 /*07/15/91 DAS   24V0  CR11096 #DDSE - SET UP $ZDSESET & $ZDSECLR          */
 /*                             CONSTANTS                                   */
 /*                                                                         */
 /*07/15/91 DAS   24V0  CR11096 #DNAME - MOVED SINGLE_VALUED ROUTINE        */
 /*                                                                         */
 /*09/04/91 DAS   24V0  CR11120 #DFLAG - DONT SET THE REMOTE FLAG OF        */
 /*                              COMSUBS THAT USE DATA_REMOTE               */
 /*                                                                         */
 /*05/07/92 JAC    7V0  CR11114 MERGE BFS/PASS COMPILERS                    */
 /*                                                                         */
 /*06/17/92 LJK    7V0  DR106214 ERR MSG XQ102 USED FOR TWO DIFF PURPOSE    */
 /*                                                                         */
 /*12/23/92 PMA    8V0  *        MERGED 7V0 AND 24V0 COMPILERS.             */
 /*                              * REFERENCE 24V0 CR/DRS
 /*                                                                         */
 /*04/11/94 JAC   26V0  108643   'INCREM' INCORRECTLY LISTED IN             */
 /*               10V0           SDFLIST AS 'NONHAL'
 /*                                                                         */
 /*02/10/95 DAS   27V0  103787   WRONG VALUE LOADED FROM REGISTER FOR       */
 /*               11V0           A STRUCTURE NODE DEREFERENCE
 /*                                                                         */
 /*11/29/95 SMR   27V1  108619   CONSTANT REMOTE ATTRIBUTE ON IN SDF        */
 /*               11V1                                                      */
 /*                                                                         */
 /*10/17/96 DAS   28V0  109051   SCALAR DOUBLE AUTOMATIC IN REENTRANT       */
 /*               12V0           PROCEDURE NOT ON STACK                     */
 /*                                                                         */
 /*01/15/98 DCP   29V0  109083   CONSTANT DOUBLE SCALAR CONVERTED TO        */
 /*               14V0           CHARACTER AS SINGLE PRECISION              */
 /*                                                                         */
 /*04/20/04 DCP   32V0  CR13832  REMOVE UNPRINTED TYPE 1 HAL/S COMPILER     */
 /*               17V0           OPTIONS                                    */
 /*                                                                         */
 /*03/30/04 TKN   32V0  13670    ENHANCE & UPDATE INFORMATION ON THE USAGE  */
 /*               17V0           OF TYPE 2 OPTIONS                          */
 /*                                                                         */
 /***************************************************************************/
                                                                                00933500
 /* SUBROUTINE FOR SYMBOL TABLE PRE-PROCESSING  */                              00934000
INITIALISE:                                                                     00934500
   PROCEDURE;                                                                   00935000
      DECLARE FIXARG LITERALLY 'STACKSPACE', FLTARG LITERALLY 'ERRSEG',         00935500
         (DENSEWORDS,PARMTYPE) BIT(16), STARTBASE BIT(16) INITIAL(-1);          00936000
      DECLARE DATAPOINT BIT(16) INITIAL(0), CONST LITERALLY 'CONSTANTS';        00936500
      ARRAY   PTRARG(PROC#) BIT(1);                                             00937000
                                                                                00937500
      DECLARE (K,L) FIXED, SDF_INCLUDED BIT(1);                                 00937510
 /?B  /* CR11114 -- BFS/PASS INTERFACE; NAMING CONVENTIONS */
      DECLARE TEMP_OP BIT(16), WORK_STRING CHARACTER;
      DECLARE TEMP_EXTTYPE BIT(16);
 ?/
                                                                                00937520
 /* LOCAL SUBROUTINE TO MAKE DENSE BIT(1) VARIABLES FOR PROCESS EVENTS */       00938170
SET_PROCESS_SIZE:                                                               00938500
      PROCEDURE(OP);                                                            00939000
         DECLARE OP BIT(16);                                                    00939500
         IF SYT_TYPE(OP) = TASK_LABEL | SYT_TYPE(OP) = PROG_LABEL THEN          00940000
            SYT_DIMS(OP) = "FF01";                                              00940500
      END SET_PROCESS_SIZE;                                                     00941000
                                                                                00941500
 /* LOCAL SUBROUTINE FOR UPDATING SUBPROG FLOW STACKS */                        00942000
PROCENTRY:                                                                      00942500
      PROCEDURE;                                                                00943000
         PROCPOINT = SYT_SCOPE(OP1);                                            00943500
         IF PROCPOINT > PROC# THEN CALL ERRORS(CLASS_BS,102);                   00944000
         IF PROCPOINT > PROCLIMIT THEN                                          00944500
            CALL ERRORS(CLASS_BX, 200);                                         00945000
         PROC_LEVEL(PROCPOINT)=OP1;                                             00945500
         PROC_LINK(PROCPOINT)=OP1;                                              00946000
         DATABASE(PROCPOINT) = PROCPOINT;                                         946500
/* CR11120 - #DFLAG - REMOVED CODE THAT SET REMOTE FLAG OF COMSUB */              946500
         IF SELFNAMELOC > 0 THEN                                                00947000
 /?P        /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
            CALL ENTER_ESD(PROGNAME(SELFNAMELOC,7,PROCPOINT),PROCPOINT,0);      00947500
         NARGS(PROCPOINT)=0;                                                    00948000
         MAXERR(PROCPOINT) = SYT_ARRAY(OP1) & "FFF";                            00948500
 ?/
 /?B        /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
            CALL ENTER_ESD(PROGNAME(SELFNAMELOC, 7, PROCPOINT), PROCPOINT, 0,
               CODE_CSECT_TYPE);
         NARGS(PROCPOINT)=0;                                                    00948000
         MAXERR(PROCPOINT) = 0; /*FIXES PROBLEM WITH ERROR HW IN STACK*/
 ?/
         ERRALLGRP(PROCPOINT) = SHR(SYT_ARRAY(OP1), 12) & 1;                    00949000
         FIXARG(PROCPOINT), FLTARG(PROCPOINT) = 0;                              00949500
         IF SYT_TYPE(OP1) ^= COMPOOL_LABEL THEN                                 00950000
            IF (SYT_FLAGS(OP1) & NOTLEAF_FLAG) ^= 0 | PROGPOINT = 0 THEN        00950500
            CALL NEED_STACK(PROCPOINT);                                         00951000
         IF (SYT_FLAGS(OP1) & REENTRANT_FLAG) ^= 0 THEN                         00951500
            LASTBASE(PROCPOINT) = TEMPBASE;                                     00952000
         ELSE LASTBASE(PROCPOINT) = STARTBASE;                                  00952500
         SYT_LABEL(OP1) = GETSTATNO;                                            00953000
         SYT_ARRAY(OP1) = 0;                                                    00953500
         IF (SYT_FLAGS(OP1)&EXCLUSIVE_FLAG) ^= 0 THEN                           00954000
            IF (SYT_FLAGS(OP1) & EXTERNAL_FLAG) = 0 THEN DO;                    00954500
            SYT_LINK1(OP1) = EXCLUSIVE#;                                        00955000
            EXCLUSIVE# = EXCLUSIVE# + 1;                                        00955500
         END;                                                                   00956500
         CALL GETSTATNO;                                                        00957000
         SYT_NEST(OP1) = SYT_NEST(OP1) + 1; /* TO MATCH VARIABLES */            00957500
         IF (SYT_FLAGS(OP1) & LATCH_FLAG) ^= 0 THEN DO;                         00958000
            SYT_BASE(OP1) = TEMPBASE;                                           00958500
            CALL SET_PROCESS_SIZE(OP1);                                         00959000
            CALL NEED_STACK(PROCPOINT);                                         00959100
         END;                                                                   00959500
         IF SYT_TYPE(OP1) = STMT_LABEL |                                        00960000
            (SYT_FLAGS(OP1) & EXCLUSIVE_FLAG) ^= 0 THEN                         00960500
            DO;                                                                   961000
            CALL#(PROCPOINT) = 4;                                                 961100
            CALL NEED_STACK(PROCPOINT);                                           961200
         END;                                                                     961300
      END PROCENTRY;                                                            00962000
                                                                                00962500
 /* ROUTINE TO SET UP EXTERNAL NAME GENERATION CLASS */                         00963000
EXTTYPE:                                                                        00963500
      PROCEDURE(OP) BIT(16);                                                    00964000
         DECLARE OP BIT(16);                                                    00964500
         IF SYT_TYPE(OP) = COMPOOL_LABEL THEN RETURN 3;                         00965000
         IF SYT_TYPE(OP) ^= PROG_LABEL THEN RETURN 1;                           00965500
 /?P     /* CR11114 -- BFS/PASS INTERFACE; FIXES ABEND BUG FOR   */
         /*            BFS- 2.01 ZAP (BFS)                       */
         IF (SYT_FLAGS(OP) & EXTERNAL_FLAG) ^= 0 THEN RETURN 9;                 00966000
 ?/
         RETURN 0;                                                              00966500
      END EXTTYPE;                                                              00968000
                                                                                00968500
 /* ROUTINE TO SET UP OUTER BLOCK  */                                           00969000
CHECK_COMPILABLE:                                                               00969500
      PROCEDURE;                                                                00970000
         IF PROGPOINT > 0 THEN RETURN;                                          00970500
         PROGPOINT = PROCPOINT;                                                 00971000
 /?P     /* CR11114 -- BFS/PASS INTERFACE; FIX ABEND BUG FOR     */
         /*            BFS- 2.01 ZAP (BFS)                       */
         CALL ENTER_ESD(PROGNAME(OP1, EXTTYPE(OP1)), PROGPOINT, 0);             00971500
 ?/
 /?B     /* CR11114 -- BFS/PASS INTERFACE; FIX ABEND BUG         */
         TEMP_EXTTYPE = EXTTYPE(OP1);
         IF TEMP_EXTTYPE = 3 THEN
            CALL ENTER_ESD(PROGNAME(OP1, TEMP_EXTTYPE), PROGPOINT, 0,
               DATA_CSECT_TYPE);
         ELSE
            CALL ENTER_ESD(PROGNAME(OP1, TEMP_EXTTYPE), PROGPOINT, 0,
               CODE_CSECT_TYPE);
 ?/
         SELFNAMELOC, TASKPOINT = OP1;                                          00972000
         IF SYT_TYPE(OP1) = COMPOOL_LABEL THEN                                  00972500
            DATAPOINT = PROGPOINT;                                              00973000
         LASTBASE(DATAPOINT), STARTBASE = PROGBASE;                             00973500
         IF (SYT_FLAGS(OP1) & REENTRANT_FLAG) = 0 THEN                          00974000
            LASTBASE(PROGPOINT) = PROGBASE;                                     00974500
         NEXTDECLREG = PROGBASE;                                                00975000
         R_INX(PROGBASE), R_INX(TEMPBASE) = -1;                                 00975500
         PROC_LEVEL(DATAPOINT) = OP1;                                           00976000
      END CHECK_COMPILABLE;                                                     00976500
                                                                                00977000
 /?P /* CR11114 -- BFS/PASS INTERFACE; DELETED NONHAL HANDLING    */
     /*            (SETUP_XPROG), DELETE CODE FOR EXR'S OF STACKS */
     /*            (SETUP_STACKS)                                 */
 /* ROUTINE TO SETUP EXTERNAL PROGRAM ESDIDS  */                                00977500
SETUP_XPROG:                                                                    00978000
      PROCEDURE;                                                                00978500
         DO WHILE XPROGLINK > 0;                                                00979000
            ESD_MAX = ESD_MAX + 1;                                              00979500
            CALL ENTER_ESD(PROGNAME(XPROGLINK, 0), ESD_MAX, 2);                 00980000
            SYT_SCOPE(XPROGLINK) = ESD_MAX;                                     00980500
            XPROGLINK = SYT_LINK1(XPROGLINK);                                   00981000
         END;                                                                   00981500
      END SETUP_XPROG;                                                          00982000
                                                                                00982500
 /* ROUTINE TO SET UP PROGRAM AND TASK STACK ESDIDS  */                         00983000
SETUP_STACKS:                                                                   00983500
      PROCEDURE;                                                                00984000
         DECLARE (PTR, CTR) BIT(16);                                            00984500
         IF SDL THEN RETURN;                                                    00985000
         STACKPOINT = ESD_MAX + 1;                                              00985500
         PTR = SELFNAMELOC;                                                     00986000
         CTR = 0;                                                               00986500
         DO WHILE PTR > 0;                                                      00987000
            ESD_MAX = ESD_MAX + 1;                                              00987500
            CALL ENTER_ESD(PROGNAME(SELFNAMELOC, 2, CTR), ESD_MAX, 2);          00988000
            CTR = CTR + 1;                                                      00988500
            PTR = SYT_LINK1(PTR);                                               00989000
         END;                                                                   00989500
      END SETUP_STACKS;                                                         00990000
                                                                                00990500
 ?/
 /* ROUTINE TO SET UP REMOTE DATA AREA FOR COMPILATION UNIT IF REQUIRED */      00991000
SETUP_REMOTE_DATA:                                                              00991500
      PROCEDURE;                                                                00992000
         IF REMOTE_LEVEL THEN DO;                                                 992500
            ESD_MAX, REMOTE_LEVEL, REMOTE_LEVEL(DATABASE) = ESD_MAX + 1;        00993000
 /?P        /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
            CALL ENTER_ESD(PROGNAME(SELFNAMELOC, 11), ESD_MAX, 0);              00993500
 ?/
 /?B        /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
            CALL ENTER_ESD(PROGNAME(SELFNAMELOC, 11), ESD_MAX, 0,
               DATA_CSECT_TYPE);
 ?/
         END;                                                                   00994000
      END SETUP_REMOTE_DATA;                                                    00994500
SETUP_DATABASE:                                                                   994510
      PROCEDURE;                                                                  994520
         DO OP2 = PROGPOINT TO PROCLIMIT;                                       00994670
            DATABASE(OP2) = DATABASE;                                           00994680
            REMOTE_LEVEL(OP2) = REMOTE_LEVEL;                                   00994690
         END;                                                                   00994780
      END SETUP_DATABASE;                                                       00994910
                                                                                00994920
 /* ROUTINE TO SETUP CONSTANT AND DATA AREAS FOR COMPILATION UNIT */            00995500
SETUP_DATA:                                                                     00996000
      PROCEDURE(PCE);                                                           00996500
         DECLARE PCE BIT(1);                                                    00997000
 /?P     /* CR11114 -- BFS/PASS INTERFACE; CHANGE #Z TO SEPARATE */
         /*            OBJECT MODULE FOR BFS                     */
         ESD_MAX, PCEBASE = DATALIMIT + 1;                                      00997500
         CALL ENTER_ESD(PROGNAME(SELFNAMELOC, 8 + PCE), PCEBASE, 0);            00998000
         IF EXCLUSIVE# > 0 THEN DO;                                             00998500
            ESD_MAX, EXCLBASE = ESD_MAX + 1;                                    00999000
            CALL ENTER_ESD(PROGNAME(SELFNAMELOC, 10), EXCLBASE, 0);             00999500
            LOCCTR(EXCLBASE) = SHL(EXCLUSIVE#, 1);                              01000000
         END;                                                                   01000500
/*------------------------- #DDSE --------------------------------*/            05160000
/* LDM CONSTANTS ARE SET UP IN "CONSTANT" ASSEMBLY MODULE FOR     */            05160000
/* INTERMETRICS' SIMULATION.  FCOS WILL PROVIDE CONSTANTS FOR     */            05160000
/* ACTUAL FSW EXECUTION.                                          */            05160000
         IF DATA_REMOTE THEN DO;                                                05160000
            ESD_MAX, DSESET = ESD_MAX + 1;                                      07909500
            CALL ENTER_ESD('$ZDSESET',DSESET,2);                                07909500
            ESD_MAX, DSECLR = ESD_MAX + 1;                                      07909500
            CALL ENTER_ESD('$ZDSECLR',DSECLR,2);                                07909500
         END;                                                                   07909500
/*----------------------------------------------------------------*/            05160000
         ESD_MAX, DATABASE = ESD_MAX + 1;                                       01001000

         /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT  */
         FSIMBASE = 0;                                                          01001500
         CALL ENTER_ESD(PROGNAME(SELFNAMELOC, 4), DATABASE, 0);                 01004000
 ?/
 /?B
/*------------------------- #DDSE --------------------------------*/            05160000
/* LDM CONSTANTS ARE SET UP IN "CONSTANT" ASSEMBLY MODULE FOR     */            05160000
/* INTERMETRICS' SIMULATION.  FCOS WILL PROVIDE CONSTANTS FOR     */            05160000
/* ACTUAL FSW EXECUTION.                                          */            05160000
         IF DATA_REMOTE THEN DO;                                                05160000
            ESD_MAX, DSESET = ESD_MAX + 1;                                      07909500
            CALL ENTER_ESD('$ZDSESET',DSESET,2);                                07909500
            ESD_MAX, DSECLR = ESD_MAX + 1;                                      07909500
            CALL ENTER_ESD('$ZDSECLR',DSECLR,2);                                07909500
         END;                                                                   07909500
/*----------------------------------------------------------------*/            05160000
         /* CR11114 -- BFS/PASS INTERFACE; #Z OBJECT MODULE      */
         PCEBASE = ^PCE;
         ESD_MAX, DATABASE = DATALIMIT + 1;
         FSIMBASE = 0;                                                          01001500

         /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT  */
         CALL ENTER_ESD(PROGNAME(SELFNAMELOC, 4), DATABASE, 0, DATA_CSECT_TYPE);
 ?/
         CALL SETUP_REMOTE_DATA;                                                01004500
         CALL SETUP_DATABASE;                                                    1004600
         IF ESD_MAX > PROC# THEN CALL ERRORS(CLASS_BS,102);                     01005000
      END SETUP_DATA;                                                           01005500
                                                                                01006000
 /* LOCAL SUBROUTINE FOR SETTING LOCKS AND NESTS  */                            01006500
SET_NEST_AND_LOCKS:                                                             01007000
      PROCEDURE;                                                                01007500
         TAG2, SYT_DISP(OP1)=SYT_SCOPE(OP1);                                    01008000
         OP2=PROC_LINK(TAG2);                                                   01008500
         IF OP2^=0 THEN SYT_LEVEL(OP2)=OP1;                                     01009000
         PROC_LINK(TAG2)=OP1;                                                   01009500
         IF PROGPOINT > 0 & TAG2 >= PROGPOINT THEN                              01010000
            IF LASTBASE(TAG2) = TEMPBASE THEN DO;                               01010500
            IF (SYT_FLAGS(OP1) & AUTO_FLAG) = 0 THEN                            01011000
               SYT_DISP(OP1) = DATAPOINT;                                       01011500
         END;                                                                   01012000
         ELSE IF TAG2 = PROGPOINT THEN                                          01012500
            SYT_DISP(OP1) = DATAPOINT;                                          01013000
         ELSE IF SYT_CONST(OP1) ^= 0 & (SYT_FLAGS(OP1)&NAME_FLAG) = 0 THEN      01013500
            SYT_DISP(OP1) = DATAPOINT;                                          01014000
/*-CR11096F--RSJ------------- #DFLAG --------------------------------*/
/* UNSET THE REMOTE_FLAG OF EACH #D VARIABLE (EXCEPT NAME VARIABLES).*/
/* THE FLAG WAS SET IN PHASE1 SO DATA CHECKING COULD BE PERFORMED.   */
         IF DATA_REMOTE THEN
         IF (CSECT_TYPE(OP1,0)=REMOTE#R)& ((SYT_FLAGS(OP1)&NAME_FLAG)=0)
         THEN DO;
            SYT_FLAGS(OP1) = SYT_FLAGS(OP1) & ^REMOTE_FLAG;
         END;
/* NOTE THAT UNSETTING THE REMOTE_FLAG MAKES #D VARIABLES (AND #R)   */
/* HAVE A CSECT_TYPE OF LOCAL#D.                                     */
/*-------------------------------------------------------------------*/
 /* ------------------ DANNY STRAUSS DR100579 ---------------------*/           01014500
 /* IF VARIABLE WAS DECLARED REMOTE (THIS EXCLUDES LOCAL VARIABLES */           01014501
 /* THAT WERE INCLUDED IN A REMOTE COMPOOL), THEN INDICATE BY      */           01014502
 /* SETTING REMOTE_LEVEL AND CREATE #R CSECT IF IT DOESN'T EXIST.  */           01014503
 /* IF INCLUDED_REMOTE, SKIP OVER CODE TO CREATE #R BECAUSE THE    */           01014504
 /* VARIABLE RESIDES IN THE INCLUDED #P                            */           01014505
         IF ((SYT_FLAGS(OP1) & NAME_OR_REMOTE) = REMOTE_FLAG) &                 01014506
            ((SYT_FLAGS(OP1) & INCLUDED_REMOTE) = 0) THEN DO;                   01014507
 /* ---------------------------------------------------------------*/           01014508
            IF PROGPOINT > 0 & TAG2 >= PROGPOINT THEN DO;                       01015000
               SYT_DISP(OP1) = DATAPOINT;                                       01015500
               REMOTE_LEVEL = TRUE;                                              1016000
            END;                                                                01016500
            ELSE IF REMOTE_LEVEL(TAG2) = 0 THEN DO;                             01017000
               REMOTE_LEVEL(TAG2), DATALIMIT = DATALIMIT + 1;                   01017500
 /?P           /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
               CALL ENTER_ESD(PROGNAME(PROC_LEVEL(TAG2), 11), DATALIMIT, 2);    01018000
 ?/
 /?B           /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
                  CALL ENTER_ESD(PROGNAME(PROC_LEVEL(TAG2), 11), DATALIMIT, 2,
                     DATA_CSECT_TYPE);
 ?/
            END;                                                                01018500
LINK_REMOTE:                                                                     1018600
 /* PUT ALL VARIABLES WITH THE REMOTE ATTRIBUTE IN THE REMOTE      */           01018610
 /* LINKED LIST.                                                   */           01018620
            SYT_LINK1(OP1) = 0;                                                 01019000
            IF LASTREMOTE > 0 THEN                                              01019500
               SYT_LINK1(LASTREMOTE) = OP1;                                     01020000
            ELSE FIRSTREMOTE = OP1;                                             01020500
            LASTREMOTE = OP1;                                                   01021000
         END;                                                                   01021500
 /* REMOTELY INCLUDED COMPOOL VARIABLES ARE ALSO PUT IN REMOTE LIST*/           01021510
         ELSE IF ((SYT_FLAGS(PROC_LEVEL(TAG2)) & REMOTE_FLAG) ^= 0) &            1021600
   /*-RSJ-----CR11096F------------- #DFLAG --------------------------*/
   /* MAKE SURE IT'S A COMPOOL, SINCE COMSUBS NOW MAY HAVE FLAG SET. */
                 (SYT_TYPE(PROC_LEVEL(TAG2)) = COMPOOL_LABEL) THEN
   /*----------------------------------------------------------------*/
            GO TO LINK_REMOTE;                                                   1021700
      END SET_NEST_AND_LOCKS;                                                   01023000
                                                                                01023500
SET_BIT_TYPE:                                                                   01024000
      PROCEDURE(OP1);                                                           01024500
         DECLARE OP1 BIT(16);                                                   01025000
         IF OP1 > HALFWORDSIZE THEN RETURN FULLBIT;                             01025500
         ELSE RETURN BITS;                                                      01026500
      END SET_BIT_TYPE;                                                         01027000
                                                                                01027500
 /*  ROUTINE TO EVALUATE CONSTANT INDEXING TERM FOR 0'TH ITEM */                01028000
CONSTERM:                                                                       01028500
      PROCEDURE(OP) FIXED;                                                      01029000
         DECLARE (OP, I, J, K, T) BIT(16), TERM1 FIXED;                         01029500
         T = DATATYPE(SYT_TYPE(OP));                                            01030000
         TERM1 = -1;                                                            01030500
         J = 2;                                                                 01031000
         IF T = 0 THEN DO;  /* STRUCTURE  */                                    01031500
            IF SYT_ARRAY(OP) ^= 0 THEN DO;                                      01032000
               K = SYT_DIMS(OP);                                                01032500
               RETURN -(EXTENT(K) + SYT_DISP(K));                               01033000
            END;                                                                01033500
            ELSE RETURN 0;                                                      01034000
         END;                                                                   01034500
         ELSE DO;                                                               01035000
            K = GETARRAY#(OP);                                                  01035500
            IF K > 0 THEN DO;                                                   01036000
               DO I = J TO K;                                                   01036500
                  TERM1 = TERM1 * GETARRAYDIM(I, OP) - 1;                       01037000
               END;                                                             01037500
               J = 1;                                                           01038000
            END;                                                                01038500
            IF T = CHAR THEN DO;                                                01039000
               IF J = 1 THEN                                                    01039500
                  IF SYT_DIMS(OP) > 0 THEN TERM1 = TERM1 * CS(SYT_DIMS(OP)+2);  01040000
            END;                                                                01040500
            ELSE IF T = MATRIX THEN DO;                                         01041000
               IF J = 1 THEN DO;                                                01041500
                  TERM1 = SHR(SYT_DIMS(OP), 8) * TERM1;                         01042000
                  TERM1 = (SYT_DIMS(OP) & "FF") * TERM1 - 1;                    01042500
               END;                                                             01043000
               J = 1;                                                           01043500
            END;                                                                01044000
            ELSE IF T = VECTOR THEN DO;                                         01044500
               IF J = 1 THEN TERM1 = TERM1 * (SYT_DIMS(OP)&"FF") - 1;           01045000
               J = 1;                                                           01045500
            END;                                                                01046000
            IF J = 2 THEN RETURN 0;                                             01046500
            RETURN TERM1 * BIGHTS(SYT_TYPE(OP));                                01047000
         END;                                                                   01047500
      END CONSTERM;                                                             01048000
                                                                                 1048020
 /* ROUTINE TO DETERMINE IS SYMBOL TABLE ELEMENT IS USED BY PROGRAM */           1048040
SYMBOL_USED:                                                                     1048060
      PROCEDURE(PTR) BIT(1);                                                     1048080
         DECLARE PTR BIT(16);                                                    1048100
         IF SELFNAMELOC > 0 THEN IF PTR >= SELFNAMELOC THEN RETURN TRUE;        01048120
         IF MAX_SEVERITY > 0 THEN RETURN TRUE;                                   1048140
         PTR = SYT_XREF(PTR);                                                    1048160
         DO WHILE PTR > 0;                                                       1048180
            IF (XREF(PTR) & "E000") ^= 0 THEN                                    1048200
               IF (XREF(PTR) & "1FFF") > FIRSTSTMT# THEN RETURN TRUE;            1048220
            PTR = SHR(XREF(PTR), 16);                                            1048240
         END;                                                                    1048260
         RETURN FALSE;                                                           1048280
      END SYMBOL_USED;                                                           1048300
                                                                                 1048310
 /* ROUTINE TO DETERMINE IF SPECIFIED SYMBOL IS SINGLE VALUED */                 1048320
SINGLE_VALUED:                                                                   1048330
      PROCEDURE(PTR) BIT(1);                                                     1048340
         DECLARE PTR BIT(16);                                                    1048350
         IF (SYT_FLAGS(PTR) & NAME_FLAG) ^= 0 THEN RETURN TRUE;                  1048360
         IF PACKTYPE(SYT_TYPE(PTR)) THEN                                         1048370
            RETURN SYT_ARRAY(PTR) = 0;                                           1048380
         ELSE RETURN FALSE;                                                      1048390
      END SINGLE_VALUED;                                                         1048400
                                                                                01048500
 /*#DNAME -- MOVED SINGLE_VALUED UP FROM HERE FOR USE IN YCON_TO_ZCON */        07360020
                                                                                01048500
 /* ROUTINE TO VERIFY ADDRESSABILITY OF DECLARED VARIABLES */                   01049000
ADDRESSABLE:                                                                    01049500
      PROCEDURE(OP, LOC);                                                       01050000
         DECLARE (OP, INX, R, T, Y, SCOPE) BIT(16), (LOC, X) FIXED;             01050500
         DECLARE M BIT(16);                                                     01050600
                                                                                01051000
 /*INTERNAL ROUTINE TO CHECK FOR PERMANENT BASE REGISTER ASSIGNMENT*/           01051500
REGISTER_ASSIGNMENT:                                                            01052000
         PROCEDURE(R) BIT(16);                                                  01052500
            DECLARE R BIT(16);                                                  01053000
            IF R <= PROGBASE THEN RETURN R;                                     01053500
            RETURN -R;                                                          01054000
         END REGISTER_ASSIGNMENT;                                               01055500
                                                                                01056000
         SCOPE, INX = SYT_DISP(OP);                                             01056050
         IF SCOPE=DATAPOINT THEN SCOPE=PROGPOINT;                               01056100
         IF SYT_BASE(OP) THEN T = 55; ELSE T = 110;                             01056500
            R = LASTBASE(INX);                                                  01056550
         IF R ^= TEMPBASE THEN                                                  01056600
            IF (INX>=PROGPOINT & INX<=PROCLIMIT) THEN R = LASTBASE(DATAPOINT);  01056650
         M = 0;                                                                 01056700
         IF (SYT_FLAGS(OP) & NAME_FLAG) ^= 0 THEN X = LOC;                      01056750
         ELSE IF DATATYPE(SYT_TYPE(OP)) = MATRIX THEN DO;                       01056800
            M = (SYT_DIMS(OP)&"FF") * BIGHTS(SYT_TYPE(OP));                     01056850
            X = LOC + SYT_CONST(OP) - M;                                        01056900
         END;                                                                   01056950
         ELSE X = LOC + SYT_CONST(OP);                                          01057000
         IF SCOPE >= PROGPOINT THEN                                             01058350
            Y = 2048 - 112;                                                     01058400
         ELSE IF (SYT_BASE(OP)=4 & SYT_TYPE(OP)^=STRUCTURE) |                   01058450
            ABS(SYT_CONST(OP)) > T THEN                                         01058500
            Y = 2048;                                                           01058550
         ELSE Y = T;                                                            01058600
         SYT_BASE(OP) = 255;  SYT_DISP(OP) = 0;                                 01058650
            DO WHILE R >= 0;                                                    01060000
            IF X >= R_BASE(R) THEN                                              01060500
               IF X < R_BASE(R)+Y-M THEN DO;                                    01061000
               IF SYT_DISP(OP) > X-R_BASE(R) | SYT_BASE(OP) = 255 THEN DO;      01061500
                  SYT_BASE(OP) = REGISTER_ASSIGNMENT(R);                        01062500
                  SYT_DISP(OP) = X - R_BASE(R) + M;                             01063000
               END;                                                             01063500
            END;                                                                01064000
            R = R_INX(R);                                                       01064500
         END;                                                                   01065000
         IF SCOPE >= PROGPOINT THEN                                             01065500
            IF SYT_BASE(OP) ^= TEMPBASE THEN                                    01066000
            IF SINGLE_VALUED(OP) THEN                                           01066500
            IF OPMODE(SYT_TYPE(OP)) ^= 4 THEN                                   01066510
            IF ^NO_SRS                                                          01066512
            THEN DO;                                                            01066514
            IF X-SYT_ADDR(PROC_LEVEL(SCOPE)) <= T THEN DO;                      01066520
               SYT_LINK2(OP) = X - SYT_ADDR(PROC_LEVEL(SCOPE));                 01066530
               IF SCOPE = PROGPOINT THEN DO;                                    01066540
                  IF T = 55 THEN MAX_SRS_DISP = SYT_LINK2(OP);                  01066550
                  ELSE MAX_SRS_DISP(1) = SYT_LINK2(OP);                         01066560
                  IF ^SDL THEN                                                  01066570
 /*  CR11095  LARRY WINGO  -  CHECK FOR REGOPT AS WELL AS SDL */
 /*    BEFORE SETTING BIT INDICATING NO REGISTER OPTIMIZATION.*/
                     IF ^REGOPT THEN
 /*  *****  END CR11095  *****                                */
                     NOT_LEAF(SCOPE) = NOT_LEAF(SCOPE) | 2;                     01066570
               END;                                                             01066580
               ELSE NOT_LEAF(SCOPE) = NOT_LEAF(SCOPE) | 2;                      01066590
            END;                                                                01069000
         END;                                                                   01069010
         IF SYT_BASE(OP) = 255 THEN DO;                                         01069500
            IF LASTBASE(INX) = TEMPBASE THEN                                    01070000
               CALL ERRORS(CLASS_BX,100,SYT_NAME(OP));                          01070500
            ELSE DO;                                                            01075000
               R, NEXTDECLREG = NEXTDECLREG + 1;                                01075500
/?P  /* SSCR 8348 -- BASE REG. ALLOCATION (ADCON)  */
               NEXT_ELEMENT(BASE_REGS);                                         01076000
?/
/?B  /* SSCR 8348 -- BASE REG. ALLOCATION (ADCON)  */
               IF R > BASE_NUM THEN DO;
                  CALL ERRORS(CLASS_BX,100,SYT_NAME(OP));
                  RETURN;
               END;
?/
               IF INX>=PROGPOINT & INX<=PROCLIMIT THEN INX=DATAPOINT;           01077500
               R_INX(R) = LASTBASE(INX);                                        01078000
               LASTBASE(INX) = R;                                               01078500
               R_BASE(R) = X & ^TRUE;                                            1079000
               R_SECTION(R) = INX;                                              01079500
               SYT_BASE(OP) = REGISTER_ASSIGNMENT(R);                           01080000
               SYT_DISP(OP) = (X & TRUE) + M;                                   01080500
            END;                                                                01081000
         END;                                                                   01081500
      END ADDRESSABLE;                                                          01084500
                                                                                01085000
 /* SUBROUTINE TO SET ASIDE DECLARED STORAGE BY LEVEL AND TYPE */               01085500
STORAGE_ASSIGNMENT:                                                             01086000
      PROCEDURE;                                                                01086500
         DECLARE (I,J,M,N,P,Q,X,Y) FIXED, (EXCHANGES,RIGID_BLOCK) BIT(1);       01087000
         DECLARE EXCHANGE LITERALLY                                             01087500
            'RETURN TRUE';                                                      01088000
                                                                                01088500
 /* LOCAL ROUTINE TO ASSIGN BLOCK HEADERS  */                                   01089000
SET_BLOCK_ADDRS:                                                                01089500
         PROCEDURE;                                                             01090000
            IF Y > X THEN DO;                                                   01090500
               IF X = -1 THEN X = PROGPOINT-1;                                  01091000
               IF Y < PROGPOINT THEN Y = PROGPOINT;                             01091500
               DO X = X+1 TO Y;                                                 01092000
                  IF X = PROGPOINT THEN IF CALL#(X) ^= 2 THEN DO;               01095500
                     LASTREMOTE = FIRSTREMOTE;                                  01096000
                     DO WHILE LASTREMOTE > 0;                                   01096500
                        IF SYMBOL_USED(LASTREMOTE) THEN DO;                      1096600
                           L = ADJUST(2,MAXTEMP(DATABASE));                     01097000
                           SYT_LINK2(LASTREMOTE) = L;                           01097500
                           MAXTEMP(DATABASE) = L + 2;                           01098000
                        END;                                                     1098100
                        ELSE SYT_LINK2(LASTREMOTE) = -1;                         1098200
                        LASTREMOTE = SYT_LINK1(LASTREMOTE);                     01098500
                     END;                                                       01099000
                  END;                                                          01099500
                  NO_SRS = FALSE;                                               01099510
                  L = ADJUST(2, MAXTEMP(DATABASE));                             01099530
                  Q = 0;                                                        01099540
                  IF CALL#(X) = 4 THEN Q = 5;                                   01099550
                  ELSE IF CALL#(X) ^= 2 THEN Q = 2;                             01099560
                  MAXTEMP(DATABASE) = L + Q;                                    01099670
                  SYT_ADDR(PROC_LEVEL(X)) = L;                                  01099680
               END;                                                             01100000
               X = Y;                                                           01100500
            END;                                                                01101000
         END SET_BLOCK_ADDRS;                                                   01101500
         M = SHR(NDECSY, 1);                                                    01102500
         DO WHILE M > 0;                                                        01103000
            DO J = 1 TO NDECSY - M;                                             01103500
               I = J;                                                           01104000
               DO WHILE SYT_SORT(I) > SYT_SORT(I+M);                            01104500
                  L = SYT_SORT(I);                                              01105000
                  SYT_SORT(I) = SYT_SORT(I+M);                                  01105500
                  SYT_SORT(I+M) = L;                                            01106000
                  I = I - M;                                                    01106500
                  IF I < 1 THEN GO TO SORT_EXIT;                                01107000
               END;                                                             01107500
SORT_EXIT:                                                                      01108000
            END;                                                                01108500
            M = SHR(M, 1);                                                      01109000
         END;                                                                   01109500
         P = 1;                                                                 01110000
         DO WHILE P <= NDECSY;                                                  01110500
            PROCPOINT = SHR(SYT_SORT(P),16);                                    01110600
            SDF_INCLUDED = (SYT_FLAGS(PROC_LEVEL(PROCPOINT))&SDF_INCL_FLAG)^=0; 01110700
            RIGID_BLOCK = (SYT_FLAGS(PROC_LEVEL(PROCPOINT))&RIGID_FLAG) ^= 0    01110800
               & (SYT_FLAGS(PROC_LEVEL(PROCPOINT))&SDF_INCL_LIST) = 0;          01110900
            Q = P;                                                              01111000
            DO WHILE PROCPOINT = SHR(SYT_SORT(Q+1),16) & Q < NDECSY;            01111500
               Q = Q + 1;                                                       01112000
            END;                                                                01112500
            K = Q - P;                                                          01113000
            L = SHR(K+1, 1);                                                    01113500
            EXCHANGES = CALL#(PROCPOINT) ^= 2 & PROCPOINT = DATAPOINT;          01113510
SWAP:       PROCEDURE(L, I) BIT(1);                                             01114000
               DECLARE (I, L) BIT(16);                                          01114500
               N = SYT_SORT(I) & "FFFF";                                        01117000
               M = SYT_SORT(L) & "FFFF";                                        01117500
               IF SDF_INCLUDED THEN                                             01117510
                  RETURN (SYT_ADDR(M) > SYT_ADDR(N));                           01117520
               IF EXCHANGES THEN DO;                                            01117530
                  X = SYT_BASE(M) = 4;                                          01117540
                  Y = SYT_BASE(N) = 4;                                          01117550
                  IF X > Y THEN EXCHANGE;                                       01117560
                  ELSE IF X ^= Y THEN RETURN FALSE;                             01117570
               END;                                                             01117580
               X = SYT_CONST(M)=0;                                              01118000
               Y = SYT_CONST(N)=0;                                              01118500
               IF X < Y THEN EXCHANGE;                                          01119000
               ELSE IF X = Y THEN DO;                                           01119500
                  X = PACKTYPE(SYT_TYPE(M)) & 1;                                01120000
                  Y = PACKTYPE(SYT_TYPE(N)) & 1;                                01120500
                  IF X < Y THEN EXCHANGE;                                       01121000
                  ELSE IF X = Y THEN DO;                                        01121500
                     X = SYT_BASE(M);                                           01122000
                     Y = SYT_BASE(N);                                           01122500
                     IF X > Y THEN EXCHANGE;                                    01123000
                     ELSE IF X = Y THEN DO;                                     01123500
                        X = SYT_CONST(M);                                       01124000
                        Y = SYT_CONST(N);                                       01124010
                        IF X < Y THEN EXCHANGE;                                 01124020
                        ELSE IF X = Y THEN                                      01124030
                           IF M > N THEN EXCHANGE;                              01124040
                     END;                                                       01124500
                  END;                                                          01125000
               END;                                                             01125500
               RETURN FALSE;                                                    01125510
            END SWAP;                                                           01125520
            IF ^RIGID_BLOCK THEN                                                01125530
               DO WHILE L > 0;                                                  01125540
               DO J = P TO Q - L;                                               01125550
                  I = J;                                                        01125560
                  DO WHILE SWAP(I, I+L);                                        01125570
                     SYT_SORT(I) = N;                                           01125580
                     SYT_SORT(I+L) = M;                                         01125590
                     I = I - L;                                                 01125600
                     IF I < P THEN ESCAPE;                                      01125610
                  END;                                                          01125620
               END;                                                             01126000
               L = SHR(L, 1);                                                   01126100
            END;                                                                01126500
            P = Q + 1;                                                          01127000
         END;                                                                   01127500
         PROCPOINT, X = -1;                                                     01128000
         DO I = 1 TO NDECSY;                                                    01128500
            J = SYT_SORT(I) & "FFFF";                                           01129000
            IF PROCPOINT ^= SYT_DISP(J) THEN DO;                                01129010
               PROCPOINT = SYT_DISP(J);                                         01129020
               SDF_INCLUDED = (SYT_FLAGS(PROC_LEVEL(PROCPOINT)) &               01129030
                  SDF_INCL_FLAG) ^= 0;                                          01129040
            END;                                                                01129050
            Y = SYT_DISP(J);                                                    01129500
            IF Y = DATAPOINT THEN K = DATABASE;                                 01130000
            ELSE IF Y >= PROGPOINT THEN DO;                                     01130500
               IF LASTBASE(Y) ^= TEMPBASE THEN K = DATABASE;                    01131000
               ELSE DO;                                                         01131500
                  K = Y;                                                        01132000
                  CALL NEED_STACK(K);                                           01132500
               END;                                                             01133000
            END;                                                                01133500
            ELSE K = Y;                                                         01134000
            CALL SET_BLOCK_ADDRS;                                               01134500
 /************* DR102952 R. HANDLEY ********************************/
 /* RESET THE VARIABLE Y HERE TO WHAT IT WAS BEFORE THE CALL TO    */
 /* SET_BLOCK_ADDRS. SET_BLOCK ADDRS MAY SOMETIMES RETURN WITH THE */
 /* INCORRECT VALUE OF Y IF THERE ARE NO DATA ITEMS DECLARED IN    */
 /* THE CURRENT COMPILATION UNIT (DATA IS OBTAINED ONLY FROM       */
 /* INCLUDED COMPOOLS). THE PROPER VALUE OF Y IS NEEDED LATER TO   */
 /* CHECK IF A VARIABLE IS IN A REMOTELY INCLUDED COMPOOL SO THAT  */
 /* THE VARIABLE CAN BE ADDRESSED AS A REMOTE VARIABLE.            */
 /******************************************************************/
            Y = SYT_DISP(J);
 /************* END DR102952 ***************************************/
 /* ------------------ DANNY STRAUSS DR100579 ---------------------*/           01135000
 /* SET K TO ESD OF REMOTE CSECT ONLY IF VARIABLE WAS DECLARED     */           01135001
 /* REMOTE; K REMAINS SET TO ESD OF DATA CSECT IF VARIABLE WAS     */           01135002
 /* LOCAL OR REMOTE ONLY BECAUSE IT WAS INCLUDED IN A REMOTE       */           01135003
 /* COMPOOL. K'S STORAGE REQUIREMENTS ARE LATER INCREASED THE      */           01135004
 /* APPROPRIATE AMOUNT FOR THE CURRENT VARIABLE.                   */           01135005
            IF ((SYT_FLAGS(J) & NAME_OR_REMOTE) = REMOTE_FLAG) &                01135006
               ((SYT_FLAGS(J) & INCLUDED_REMOTE) = 0) THEN DO;                  01135007
 /* ---------------------------------------------------------------*/           01135008
               K = REMOTE_LEVEL(K);                                              1135500
ADDRESS_REMOTE:                                                                  1136600
               IF SDF_INCLUDED THEN                                             01137000
                  L = SYT_ADDR(J);                                              01137020
               ELSE                                                             01137040
                  L = ADJUST(SYT_BASE(J),MAXTEMP(K));                           01137230
               SYT_BASE(J) = REMOTE_BASE + SHL(SINGLE_VALUED(J),3);              1137500
               SYT_DISP(J) = SYT_LINK2(J);                                      01138000
               SYT_LINK2(J) = 0;                                                01138500
            END;                                                                01139000
 /* REMOTELY INCLUDED COMPOOL VARIABLES ALSO GET ADDRESSED REMOTE. */           01139010
            ELSE IF ((SYT_FLAGS(PROC_LEVEL(Y)) & REMOTE_FLAG) ^= 0) &            1139100
   /*-RSJ-----CR11096F------------- #DFLAG --------------------------*/
   /* MAKE SURE IT'S A COMPOOL, SINCE COMSUBS NOW MAY HAVE FLAG SET. */
                    (SYT_TYPE(PROC_LEVEL(Y)) = COMPOOL_LABEL) THEN
   /*----------------------------------------------------------------*/
               GO TO ADDRESS_REMOTE;                                             1139200
            ELSE DO;                                                            01139500
               IF SDF_INCLUDED THEN                                             01140500
                  L = SYT_ADDR(J);                                              01140510
               ELSE L = ADJUST(SYT_BASE(J), MAXTEMP(K));                        01140520
               IF SYMBOL_USED(J) THEN                                            1141000
                  CALL ADDRESSABLE(J, L);                                        1141100
               ELSE SYT_DISP(J) = -1;                                            1141200
            END;                                                                01141500
            IF ASSEMBLER_CODE THEN                                              01142000
               OUTPUT=SYT_NAME(J)||X2||LEFTBRACKET||EXTENT(J)||RIGHTBRACKET||X2 01142500
               ||HEX(L,6)||X2||HEX(SYT_DISP(J),3)||LEFTBRACKET||SYT_BASE(J)     01143000
               ||RIGHTBRACKET||X2||SYT_CONST(J);                                01143500
            IF (SYT_FLAGS(J) & NAME_FLAG) ^= 0 THEN                             01144000
               MAXTEMP(K) = L + NAMESIZE(J);                                     1144500
            ELSE MAXTEMP(K) = L + EXTENT(J);                                    01145000
            WORKSEG(K) = MAXTEMP(K);                                            01145500
            SYT_ADDR(J) = L;                                                    01146000
         END;                                                                   01146500
         Y = PROCLIMIT;                                                         01147000
         CALL SET_BLOCK_ADDRS;                                                  01147500
         PROGDATA = MAXTEMP(DATABASE);                                          01148000
         PROGDATA(1) = MAXTEMP(REMOTE_LEVEL);                                    1148500
      END STORAGE_ASSIGNMENT;                                                   01149000
                                                                                01149500
 /* ROUTINE TO ALLOCATE TERMINAL NODES OF A STRUCTURE TEMPLATE  */              01150000
ALLOCATE_TEMPLATE:                                                              01150500
      PROCEDURE(PTR);                                                           01151000
         DECLARE (PTR,Q) BIT(16), (I,J,K,L,M,N,X,Y) FIXED;                      01151500
         DECLARE EXCHANGE LITERALLY                                             01152000
            'RETURN TRUE';                                                      01152500
         IF NDECSY - SYT_LEVEL(PTR) = 0 THEN RETURN;                            01153000
         K = NDECSY - SYT_LEVEL(PTR) - 1;                                       01153500
         L = SHR(K+1, 1);                                                       01154000
SWAP:    PROCEDURE(L, I) BIT(1);                                                01154500
            DECLARE (I, L) BIT(16);                                             01155000
            N = SYT_SORT(I) & "FFFF";                                           01157000
            M = SYT_SORT(L) & "FFFF";                                           01157500
            X = (SYT_FLAGS(M) & RIGID_FLAG) ^= 0;                               01158000
            Y = (SYT_FLAGS(N) & RIGID_FLAG) ^= 0;                               01158500
            IF X > Y THEN EXCHANGE;                                             01159000
            ELSE IF X = Y & ^X THEN                                             01159500
               IF SYT_BASE(M) < SYT_BASE(N) THEN EXCHANGE;                      01160000
            ELSE IF SYT_BASE(M) = SYT_BASE(N) THEN                              01160500
               IF SYT_DISP(M) > SYT_DISP(N) THEN EXCHANGE;                      01161000
            ELSE IF SYT_DISP(M) = SYT_DISP(N) THEN                              01161010
               IF M > N THEN EXCHANGE;                                          01161020
            RETURN FALSE;                                                       01161030
         END SWAP;                                                              01161040
         IF (SYT_FLAGS(PTR) & RIGID_FLAG) = 0 THEN                              01161050
            DO WHILE L > 0;                                                     01161060
            DO J = SYT_LEVEL(PTR) + 1 TO NDECSY - L;                            01161070
               I = J;                                                           01161080
               DO WHILE SWAP(I, I+L);                                           01161090
                  SYT_SORT(I) = N;                                              01161100
                  SYT_SORT(I+L) = M;                                            01161110
                  I = I - L;                                                    01161120
                  IF I <= SYT_LEVEL(PTR) THEN ESCAPE;                           01161130
               END;                                                             01161140
            END;                                                                01161500
            L = SHR(L, 1);                                                      01161600
         END;                                                                   01162000
         K, N, Q = 0;                                                           01162500
         DO I = SYT_LEVEL(PTR) + 1 TO NDECSY;                                   01163000
            J = SYT_SORT(I) & "FFFF";                                           01163500
            IF SYT_PARM(J) = 2 THEN DO;                                         01164000
               L = SYT_BASE(J) - 1;                                             01164500
               Y = BIGHTS(FULLWORD) - 1;                                        01165000
               L = (K + L) & (^L);                                              01165500
               Y = ((L + Y) & (^Y)) - L;                                        01166000
               IF Y = 0 THEN Y = BIGHTS(FULLWORD);                              01166500
               Y = Y * BITESIZE;                                                01167000
               M = Y - SYT_DIMS(J);                                             01167500
               DO IX1 = I+1 TO NDECSY;                                          01168000
                  IX2 = SYT_SORT(IX1) & "FFFF";                                 01168500
                  IF SYT_PARM(IX2) ^= 2 THEN GO TO LAST_DENSE;                  01169000
                  IF SYT_DIMS(IX2) > M THEN GO TO LAST_DENSE;                   01169500
                  M = M - SYT_DIMS(IX2);                                        01170000
               END;                                                             01170500
               IX2 = 0;                                                         01171000
LAST_DENSE:                                                                     01171500
               IX1 = IX1 - 1;                                                   01172000
               IF I = IX1 THEN GO TO NOT_DENSE;                                 01172500
               IX2 = SYT_BASE(IX2) * BITESIZE;                                  01173000
               DO WHILE M >= IX2;                                               01173500
                  Y = Y - IX2;                                                  01174000
                  M = M - IX2;                                                  01174500
               END;                                                             01175000
               X = SET_BIT_TYPE(Y);                                             01175500
               Q = Q + 1;                                                       01175600
               DO I = I TO IX1;                                                 01176500
                  J = SYT_SORT(I) & "FFFF";                                     01177000
                  M = M + SYT_DIMS(J);                                          01177500
                  IF M = Y THEN SYT_DIMS(J) = "FF00" + SYT_DIMS(J);             01178000
                  ELSE SYT_DIMS(J) = SHL(Y - M, 8) + SYT_DIMS(J);               01178500
                  SYT_TYPE(J) = X;                                              01179000
                  SYT_BASE(J), EXTENT(J) = BIGHTS(X);                           01179500
                  SYT_ADDR(J) = L;                                              01180000
               END;                                                             01180500
               X = BIGHTS(X);                                                   01181000
               N = MAX(X, N);                                                   01181500
               K = L + X;                                                       01182000
               IF M ^= Y THEN                                                   01182500
                  CALL ERRORS(CLASS_BI,501,' '||Y - M);                         01183000
               I = IX1;                                                         01183500
            END;                                                                01184000
            ELSE DO;                                                            01184500
NOT_DENSE:                                                                      01185000
               L = ADJUST(SYT_BASE(J), K);                                      01185500
               SYT_ADDR(J) = L;                                                 01186000
               N = MAX(SYT_BASE(J), N);                                         01186500
               IF (SYT_FLAGS(J) & NAME_FLAG) ^= 0 THEN K = L + NAMESIZE(J);      1187000
               ELSE DO;                                                         01187500
                  K = L + EXTENT(J);                                            01187510
                  IF SYT_LINK1(J) > 0 THEN                                      01187520
                     Q = Q - SYT_PARM(J);                                       01187530
                  ELSE IF SYT_TYPE(J) = STRUCTURE THEN                          01187540
                     Q = Q - SYT_PARM(SYT_DIMS(J));                             01187550
               END;                                                             01187560
            END;                                                                01188000
         END;                                                                   01188500
         SYT_BASE(PTR) = N;                                                     01189000
         EXTENT(PTR) = K;                                                       01189500
         SYT_DISP(PTR) = ADJUST(N, K) - K;                                      01190000
         SYT_PARM(PTR) = -Q;                                                    01190010
         DENSEWORDS = MAX(DENSEWORDS,Q);                                        01190020
         NDECSY = SYT_LEVEL(PTR);                                               01190500
      END ALLOCATE_TEMPLATE;                                                    01191000
                                                                                01191500
 /* ROUTINE TO ENTER A SYMBOL ONTO THE DECLARED STORAGE STACK  */               01192000
ENTER:                                                                          01192500
      PROCEDURE(SYM);                                                           01193000
         DECLARE SYM BIT(16);                                                   01193500
         IF (SYT_FLAGS(SYM) & TEMPORARY_FLAG) ^= 0 THEN RETURN;                 01194000
         NDECSY = NDECSY + 1;                                                   01194500
         DO WHILE NDECSY >= RECORD_TOP(DOSORT);                                 01194600
            NEXT_ELEMENT(DOSORT);                                               01194700
         END;                                                                   01194800
         SYT_SORT(NDECSY) = SHL(SYT_DISP(SYM), 16) + SYM;                       01195000
      END ENTER;                                                                01195500
                                                                                01196000
 /* ROUTINE TO FIX-UP FORWARD STRUCTURE PARAMETER WIDTHS */                     01196500
STRUCT_PARM_FIX:                                                                01197000
      PROCEDURE(OP1, OP2);                                                      01197500
         DECLARE (OP1, OP2) BIT(16);                                            01198000
         IF SYT_ARRAY(OP1) = 0 THEN                                             01198500
            EXTENT(OP1) = EXTENT(OP2);                                          01199000
         ELSE DO;                                                               01199500
            TMP = EXTENT(OP2) + SYT_DISP(OP2);                                  01200000
            IF SYT_ARRAY(OP1) < 0 THEN EXTENT(OP1) = TMP;                       01200500
            ELSE EXTENT(OP1) = SYT_ARRAY(OP1) * TMP;                            01201000
         END;                                                                   01201500
      END STRUCT_PARM_FIX;                                                      01202000
                                                                                01202500
 /* SUBROUTINE TO DETERMINE STORAGE LOCATIONS FOR FORMAL PARAMETERS */          01203000
PARAMETER_ALLOCATE:                                                             01203500
      PROCEDURE(OP, PTYPE, LEN);                                                01204000
         DECLARE (OP, PTYPE, LEN, TEMP, SCOPE) BIT(16);                         01204500
 /* LOCAL ROUTINE TO ALLOCATE PARAMETER SPACE OUT OF TEMPORARY AREA */          01205000
PARMTEMP:                                                                       01205500
         PROCEDURE FIXED;                                                       01206000
            DECLARE LOC FIXED;                                                  01206500
            LOC = ADJUST(BIGHTS(PTYPE), MAXTEMP(SCOPE));                        01207000
            MAXTEMP(SCOPE) = LOC + TEMP;                                        01207500
            RETURN LOC;                                                         01208000
         END PARMTEMP;                                                          01208500
                                                                                01209000
         IF PTYPE = APOINTER THEN DO;                                            1209500
            SYT_FLAGS(OP) = SYT_FLAGS(OP) | POINTER_FLAG;                       01210000
            TEMP = BIGHTS(DINTEGER) * LEN;                                      01210500
         END;                                                                   01211000
         ELSE TEMP = BIGHTS(PTYPE) * LEN;                                       01211500
         SCOPE = SYT_SCOPE(OP);                                                 01212000
         CALL NEED_STACK(SCOPE);                                                01212500
         SYT_PARM(OP) = -1;  /* NO REGISTER ASSIGNED */                         01213000
         IF DATATYPE(PTYPE)=SCALAR THEN DO;                                     01213500
            SYT_DISP(OP) = PARMTEMP;                                            01214000
            IF FLTARG(SCOPE) <= 4 THEN                                          01214500
               SYT_PARM(OP) = FLTARG(SCOPE) + FR0;                              01215000
            FLTARG(SCOPE) = FLTARG(SCOPE) + 2;                                  01215500
         END;                                                                   01216000
         ELSE IF PTYPE = APOINTER & LEN = 1 & PTRARG(SCOPE) = 0 THEN DO;         1216500
            SYT_DISP(OP) = SHL(PTRARG1, 1) + REGISTER_SAVE_AREA;                01217000
            SYT_PARM(OP) = PTRARG1;                                             01217500
            PTRARG(SCOPE) = 1;                                                  01218000
         END;                                                                   01218500
         ELSE DO;                                                               01219000
            IF FIXARG(SCOPE) > 3-LEN THEN                                       01219500
               SYT_DISP(OP) = PARMTEMP;                                         01220000
            ELSE DO;                                                            01220500
               SYT_DISP(OP) = SHL(FIXARG(SCOPE)+FIXARG1,1) + REGISTER_SAVE_AREA;01221000
               SYT_PARM(OP) = FIXARG(SCOPE) + FIXARG1;                          01221500
            END;                                                                01223000
            FIXARG(SCOPE) = FIXARG(SCOPE) + LEN;                                01223500
         END;                                                                   01224000
         SYT_ADDR(OP) = SYT_DISP(OP);                                           01224500
         SYT_BASE(OP) = TEMPBASE;                                               01225000
         IF LEN > 1 THEN                                                        01225500
            SYT_LEVEL(OP) = LEN - 1;                                            01226000
         IF ASSEMBLER_CODE THEN DO;                                             01226500
            OUTPUT=SYT_NAME(OP)||X2||LEFTBRACKET||EXTENT(OP)||RIGHTBRACKET||X2||01227000
               HEX(SYT_ADDR(OP),6)||X2||HEX(SYT_DISP(OP),3)||LEFTBRACKET||      01227500
               SYT_BASE(OP)||RIGHTBRACKET||X2||SYT_CONST(OP);                   01228000
         END;                                                                   01228500
      END PARAMETER_ALLOCATE;                                                   01229000
                                                                                01238000
      ALLOCATE_SPACE(LAB_LOC,STATNOLIMIT+1); /*CR13670*/
      DUMMY=PARM_FIELD;                                                         01238500
      DECK_REQUESTED = (OPTION_BITS & "400000") ^= 0;                           01239000
      TRACING=(OPTION_BITS & "8") ^= 0;                                         01239500
      IF (OPTION_BITS & "20000") ^= 0 THEN DO;                                  01240500
 /?P     /* CR11114 -- BFS/PASS INTERFACE; 'AB' & 'L' INDEPENDENT */
         /*            FOR BFS                                    */
         CODE_LISTING_REQUESTED = TRUE;                                         01241000
         TOGGLE = TOGGLE | "70";                                                01241500
      END;                                                                      01242000
      ELSE CODE_LISTING_REQUESTED = (OPTION_BITS & "4") ^= 0;                   01242500
 ?/
 /?B     /* CR11114 -- BFS/PASS INTERFACE; 'AB' & 'L' INDEPENDENT */
         CODE_LISTING = TRUE;
         TOGGLE = TOGGLE | "70";                                                01241500
      END;                                                                      01242000
      ELSE
         CODE_LISTING = (OPTION_BITS & "4") ^= 0;
 ?/
      NO_VM_OPT=(OPTION_BITS & "40")^=0;                                        01243000
      MAX_SEVERITY = (TOGGLE&"8")^=0;                                           01247000
      DIAGNOSTICS = (TOGGLE&"10")^=0;                                           01247500
      ASSEMBLER_CODE = (TOGGLE&"20")^=0;                                        01248000
      HALMAT_REQUESTED = (TOGGLE&"40")^=0;                                      01248500
 /?P     /* CR11114 -- BFS/PASS INTERFACE; 'AB' & 'L' INDEPENDENT */
      REGISTER_TRACE = ASSEMBLER_CODE & CODE_LISTING_REQUESTED;                 01249000
 ?/
 /?B     /* CR11114 -- BFS/PASS INTERFACE; 'AB' & 'L' INDEPENDENT */
      REGISTER_TRACE = ASSEMBLER_CODE & CODE_LISTING;
 ?/
      SDL = (OPTION_BITS & "800000") ^= 0;                                      01249500
 /*  CR11095  LARRY WINGO  - THIS CR WAS IMPLEMENTED DIFFERENTLY  */
 /*           FOR CR11114 (MERGE BFS/PASS COMPILERS)              */
 /?P  /*BIT STRING IS SET DIFFERENT IN PASS THAN BFS IN MONITOR */
      REGOPT = (OPTION_BITS & "2000000") ^= 0;
 ?/
 /?B  /*BIT STRING IS SET DIFFERENT IN PASS THAN BFS IN MONITOR */
      REGOPT = (OPTION_BITS & "40000000") ^= 0;
 ?/
 /*  *****  END CR11095  *****                                    */
      SREF = (OPTION_BITS & "2000") ^= 0;                                        1249600
      Z_LINKAGE = (OPTION_BITS & "400") ^= 0;                                   01250000
      COMPACT_CODE = (OPTION_BITS & "0020 0000")^=0;                            01250500
      NEW_INSTRUCTIONS = (OPTION_BITS & "04000000") ^= 0;  /* X8 */             01251000
      OLD_LINKAGE = ^NEW_INSTRUCTIONS;                                          01251500
      IF OLD_LINKAGE THEN DO;                                                   01252000
         SYSARG0(0), SYSARG0(2) = SYSARG0(1);                                   01252500
         SYSARG1(0), SYSARG1(2) = SYSARG1(1);                                   01253000
         SYSARG2(0), SYSARG2(2) = SYSARG2(1);                                   01253500
         DO IX1 = 0 TO 10 BY 2;                                                 01254000
            REGISTER_SAVE_AREA(IX1) = REGISTER_SAVE_AREA(IX1+1);                01254500
         END;                                                                   01255000
      END;                                                                      01255500
      EXTRA_LISTING = (OPTION_BITS & "4000") ^= 0;                              01256000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; 'AB' & 'L' INDEPENDENT */
      CODE_LISTING_REQUESTED = CODE_LISTING | EXTRA_LISTING;
 ?/
      SELF_ALIGNING = TRUE;                                        /*CR13832*/  01256500
      HIGHOPT = (OPTION_BITS & "80") ^= 0; /*DR103787*/                         01256500
      TMP = MONITOR(13, 0);                                                     01257000
      COREWORD(ADDR(VALS)) = COREWORD(TMP+16);                                  01257500
      SYT_SIZE = SYT_MAX;                                                       01258000
      LABELSIZE = FL_NO_MAX + 5;                                                01258500
 /* NOW OBTAIN STORAGE WHICH WILL BE RETURNED TO FREE STRING AREA  */           01263000
      RECORD_CONSTANT(P2SYMS,SYT_SIZE+1,MOVEABLE);                              01263500
      RECORD_USED(P2SYMS) = RECORD_ALLOC(P2SYMS);                               01264000
      STATNOLIMIT = VALS(9);                                                    01266000
      ALLOCATE_SPACE(DOSORT,SYT_SIZE+1);                                        01266500
      NEXT_ELEMENT(DOSORT);                                                     01266510

/?P  /* SSCR 8348 -- BASE REGISTER ALLOCATION (ADCON)  */

 /* ALLOCATE VIRTUAL BASE REGISTER TABLE */                                     01266511
      ALLOCATE_SPACE(BASE_REGS,BASE_NUM);                                       01266512
 /* WILL START PUTTING INFO AT LOCATION 'PROGBASE+1' IN BASE_REGS.              01266513
        ACTUALLY WILL START PUTTING STUFF AT LOCATION 2.  THE FOLLOWING         01266514
        STATEMENT MAKES SURE THAT LOCATIONS 0 AND 1 ARE BYPASSED */             01266515
      RECORD_USED(BASE_REGS) = PROGBASE + 1;                                    01266516
?/
      CMPUNIT_ID = VALS(6);                                                     01267000
      DSR = VALS(10);                                                           01267500
      SYT_BASE(0) = BIGHTS(BOOLEAN);                                            01268000
      DUMMY = SUBSTR(X72,0,64);                                                 01268500
      DUMMY = DUMMY || DUMMY || DUMMY || DUMMY;                                 01269000
      DO IX1 = 0 TO ESD_CHAR_LIMIT;                                             01269500
         ESD_NAME(IX1) = DUMMY;                                                 01270000
      END;                                                                      01270500
      CODEHWM_HEAD = -1;                                                        01270510
      SYMBREAK, PROCLIMIT, DATALIMIT = MAX_SCOPE#;                              01271000
      DO FOREVER;                                                               01271500
         TEMPSPACE=0;                                                           01272000
         OP1=OP1+1;                                                             01272500
         IF SELFNAMELOC>0                                                       01272510
            THEN SYT_FLAGS(OP1) = SYT_FLAGS(OP1) & "FFFF7DFF";                  01272520
         ELSE SYT_FLAGS(OP1) = SYT_FLAGS(OP1) & "FFFF7FFF";                     01272530
         IF (SYT_FLAGS(OP1)&IGNORE_FLAG)=0 THEN                                 01273000
            DO CASE SYT_CLASS(OP1);                                             01273500
 /*  ALL THROUGH     */                                                         01274000
            DO;                                                                 01274500
               DO CASE CALL#(PROGPOINT) & "3";                                  01275000
                  DO;  /* EXTERNAL PROC/FUNC  */                                01275500
                     CALL SETUP_DATA;                                           01276000
                  END;                                                          01276500
                  DO;  /* PROGRAM  */                                           01277000
                     CALL SETUP_DATA(1);                                        01277500
 /?P  /* CR11114 -- BFS/PASS INTERFACES; CODE FOR EXR'S OF STACKS */
                     CALL SETUP_STACKS;                                         01278000
 ?/
                  END;                                                          01278500
                  DO;  /* COMPOOL  */                                           01279000
                     DATABASE = PROCLIMIT;                                      01279500
                     ESD_MAX = DATALIMIT;                                       01280000
                     CALL SETUP_REMOTE_DATA;                                    01280500
                     CALL SETUP_DATABASE;                                       01280600
                     SYMBREAK = PROCLIMIT - 1;                                  01281000
                  END;                                                          01281500
               END;                                                             01282000
 /?P  /* CR11114 -- BFS/PASS INTERFACES;NONHAL HANDLING */
               CALL SETUP_XPROG;                                                01282500
               DO IX1 = PROGPOINT TO PROCLIMIT;                                 01283000
      /* CR11114 -- REFERENCE TO MAXERR IS DIFFERENT */
                  IF MAXERR(IX1) > 0 THEN CALL NEED_STACK(IX1);                 01283500
                  ERRSEG(IX1) = ADJUST(2, MAXTEMP(IX1));                        01284000
                  MAXTEMP(IX1) = SHL(MAXERR(IX1), 1) + ERRSEG(IX1);             01284500
 ?/
 /?B  /* CR11114 -- REFERENCE TO MAXERR IS DIFFERENT */
               DO IX1 = PROGPOINT TO PROCLIMIT;                                 01283000
                  ERRSEG(IX1) = ADJUST(2, MAXTEMP(IX1));                        01284000
                  MAXTEMP(IX1) = ERRSEG(IX1);
 ?/
                  WORKSEG(IX1) = MAXTEMP(IX1);                                  01285500
                  PROC_LINK(IX1) = 0;                                           01285600
               END;                                                             01286000
               CALL STORAGE_ASSIGNMENT;                                         01286500
               RECORD_FREE(DOSORT);                                             01287000
               IF DENSEWORDS>0 THEN DO;                                         01287010
                  RECORD_CONSTANT(DNS,SHL(DENSEWORDS+2,2),MOVEABLE);            01287020
                  RECORD_USED(DNS) = RECORD_ALLOC(DNS);                         01287030
               END;                                                             01287040
               ALLOCATE_SPACE(STMTNUM,LABELSIZE+1);                             01287520
               NEXT_ELEMENT(STMTNUM);                                           01287530
               OFF_PAGE_BASE(1) = OFF_PAGE_MAX;                                  1288600
               ALLOCATE_SPACE(PAGE_FIX,SHL(OFF_PAGE_MAX,1));                    01288700
               NEXT_ELEMENT(PAGE_FIX);                                          01288750

 /?P  /*  SSCR 8348 -- BRANCH CONDENSING   */
               ALLOCATE_SPACE(BRANCH_TBL, STATNOLIMIT/5);                       01288760
               NEXT_ELEMENT(BRANCH_TBL);                                        01288770
 ?/
               IX1 = RCLASS_START(DOUBLE_ACC);                                  01289000
               OP2 = FR0;                                                       01289500
               DO WHILE OP2 > LINKREG;                                          01290000
                  OP2 = OP2 - 2;                                                01290500
                  REGISTERS(IX1) = OP2;                                         01291500
                  IX1 = IX1 + 1;                                                01292500
               END;                                                             01293000
               RCLASS_START(FIXED_ACC) = IX1;                                   01293500
               OP2 = LINKREG+1;                                                 01294000
               DO WHILE OP2 < FR0;                                              01294500
                  REGISTERS(IX1) = OP2;                                         01295500
                  OP2 = OP2 + 1;                                                01296000
                  IX1 = IX1 + 1;                                                01296500
               END;                                                             01297000
               REGISTERS(IX1)=LINKREG;                                          01297500
               IX1=IX1+1;                                                       01298000
               RCLASS_START(INDEX_REG) = IX1;                                   01299500
               DO WHILE OP2 > LINKREG;                                          01300000
                  OP2 = OP2 - 1;                                                01300500
                  REGISTERS(IX1) = OP2;                                         01301000
                  IX1 = IX1 + 1;                                                01301500
               END;                                                             01302000
               RCLASS_START(ODD_REG)=IX1;                                       01302500
               OP2=FR7;                                                         01303000
               DO WHILE OP2>FR0;                                                01303500
                  REGISTERS(IX1)=OP2;                                           01304000
                  IX1=IX1+1;                                                    01304500
                  OP2=OP2-2;                                                    01305000
               END;                                                             01305500
               RCLASS_START(ODD_REG+1)=IX1;                                     01306000
               INDEXNEST = 0;                                                   01306500
               DO IX1 = 0 TO SSTYPE;                                            01307000
                  NOT_MODIFIER(IX1) = TRUE;                                     01307500
               END;                                                             01308000
               NOT_MODIFIER(ADCON) = FALSE;                                     01308500
               PACKFORM(CSYM), PACKFORM(WORK) = 1;                              01309000
               PACKFORM(LIT), PACKFORM(VAC) = 2;                                01309500
               SYMFORM(SYM), SYMFORM(CSYM), SYMFORM(IMD), SYMFORM(INL) = TRUE;  01311500
               DO IX1 = 1 TO LIB_NUM;                                           01314000
                  OP2 = LIB_NAME_INDEX(IX1) & "FF";                             01314500
                  DUMMY=SUBSTR(LIB_NAMES(OP2),SHR(LIB_NAME_INDEX(IX1),8)&"FFFF",01315000
                     SHR(LIB_NAME_INDEX(IX1),24));                              01315500
                  LIB_NAME_INDEX(IX1) = UNSPEC(DUMMY);                          01316000
               END;                                                             01316500
               CALL SETUP_STACK;                                                01320000
               CODE_LIM = CODE_SIZE;                                            01320500
               CALL SET_MASKING_BIT(0);  /* INITIALIZATION CALL */              01321000
               FIRST_INST = TRUE;                                               01321500
               RETURN;                                                          01322000
            END;                                                                01322500
 /*  VARIABLE CLASS   */                                                        01323000
            IF (SYT_FLAGS(OP1)&PARM_FLAGS)=0 THEN DO;                           01323500
                                                                                01324000
 /* LOCAL PROCEDURE TO HANDLE VARIABLE OR TERMINAL ALLOCATION */                01324500
VARIABLES:                                                                      01325000
               PROCEDURE(OP1) BIT(16);                                          01325500
                  DECLARE (OP1, OP2) BIT(16);                                   01326000
                  DO CASE SYT_TYPE(OP1);                                        01326500
                     ;                                                          01327000
 /*  BITSTRINGS   */                                                            01327500
                     DO;                                                        01328000
                        TEMPSPACE=1;                                            01328500
                        SYT_TYPE(OP1) = SET_BIT_TYPE(SYT_DIMS(OP1));            01329000
                     END;                                                       01329500
 /*  CHARACTERS */                                                              01330000
                     DO;                                                        01330500
                        TEMPSPACE = CS(SYT_DIMS(OP1)+2);                        01331000
                     END;                                                       01331500
 /*   MATRICES */                                                               01332000
                     DO;                                                        01332500
                        TEMPSPACE=(SYT_DIMS(OP1)&"FF")*SHR(SYT_DIMS(OP1),8);    01333000
                     END;                                                       01333500
 /*   VECTORS   */                                                              01334000
                     DO;                                                        01334500
                        TEMPSPACE=SYT_DIMS(OP1)&"FF";                           01335000
                        SYT_DIMS(OP1) = TEMPSPACE|"100";                        01335500
                     END;                                                       01336000
 /*   SCALARS  */                                                               01336500
                     TEMPSPACE=1;                                               01337000
 /*   INTEGERS   */                                                             01337500
                     TEMPSPACE=1;                                               01338000
 /*  UNUSED  */                                                                 01338500
                     ; ;                                                        01339000
 /*  EVENTS  */                                                                 01339500
                        DO;                                                     01340000
                        TEMPSPACE=1;                                            01340500
                        SYT_TYPE(OP1) = EVENT;                                  01341000
                        SYT_DIMS(OP1) = "FF01";                                 01341500
                     END;                                                       01342000
 /* MAJOR STRUCTURE  */                                                         01342500
                     DO;                                                        01343000
                        CALL ENTER(OP1);                                        01343500
                        OP2 = SYT_DIMS(OP1);                                    01344000
                        IF SYT_ARRAY(OP1) = 0 THEN                              01344500
                           EXTENT(OP1) = EXTENT(OP2);                           01345000
                        ELSE DO;                                                01345500
                           TEMPSPACE = EXTENT(OP2) + SYT_DISP(OP2);             01346000
                           EXTENT(OP1) = TEMPSPACE * SYT_ARRAY(OP1);            01346500
                           SYT_CONST(OP1) = -TEMPSPACE;                         01347000
                        END;                                                    01347500
                        SYT_TYPE(OP1) = STRUCTURE;                              01348000
                        RETURN SYT_BASE(OP2);                                   01348500
                     END;                                                       01349000
                  END;                                                          01349500
                  IF (SYT_FLAGS(OP1)&DOUBLE_FLAG)^=0 THEN                       01350000
                     SYT_TYPE(OP1)=SYT_TYPE(OP1)|8;                             01350500
                  OP2=BIGHTS(SYT_TYPE(OP1));                                    01351000
                  CALL ENTER(OP1);                                              01351500
                  SYT_PARM(OP1)=0;                                              01352000
                  TEMPSPACE=TEMPSPACE*OP2;                                      01352500
                  DO IX1=1 TO GETARRAY#(OP1);                                   01353000
                     TEMPSPACE=TEMPSPACE*GETARRAYDIM(IX1,OP1);                  01353500
                     CALL CHECKSIZE(TEMPSPACE,2);                               01354000
                  END;                                                          01354500
                  EXTENT(OP1)=TEMPSPACE;                                        01355000
                  SYT_CONST(OP1)=CONSTERM(OP1);                                 01355500
                  RETURN OP2;                                                   01356000
               END VARIABLES;                                                   01356500
                                                                                01357000
     /*UNSET THE REMOTE_FLAG OF EACH #D CHAR, INTEGER AND SCALAR */
     /*CONSTANT. THE FLAG WAS SET IN PHASE1 SO DATA CHECKING     */
     /*COULD BE PERFORMED.                                       */
               IF ( ((SYT_FLAGS(OP1)&CONSTANT_FLAG)^=0) &           /*DR108619*/
               ( (SYT_TYPE(OP1)=CHAR) | (SYT_TYPE(OP1)=SCALAR) |    /*DR108619*/
               (SYT_TYPE(OP1)=INTEGER) )) & DATA_REMOTE THEN        /*DR108619*/
                  IF (CSECT_TYPE(OP1,0)=REMOTE#R) THEN              /*DR108619*/
                     SYT_FLAGS(OP1) = SYT_FLAGS(OP1) & ^REMOTE_FLAG;/*DR108619*/

               IF (SYT_FLAGS(OP1)&CONSTANT_FLAG)=0 | SYT_PTR(OP1)^<0 THEN DO;   01357500
                  CALL SET_NEST_AND_LOCKS;                                      01358000
                  SYT_BASE(OP1) = VARIABLES(OP1);                               01358500
                  IF (SYT_FLAGS(OP1) & NAME_FLAG) ^= 0 THEN                     01359000
                     SYT_BASE(OP1) = NAMESIZE(OP1);                              1359500
                  ELSE IF SYT_DISP(OP1) > PROGPOINT & PROGPOINT > 0 THEN        01359510
                     IF SYT_BASE(OP1) = 4 THEN                                  01359520
/*DR109051 DONT MOVE TO MAIN UNIT #D IF VARIABLE LIVES ON STACK */
/*DR109051 (THIS INCLUDES AUTOMATIC IN REENTRANT PROC AS WELL AS TEMPORARY)*/
/*DR109051*/         IF ^( ((SYT_FLAGS(OP1) & AUTO_FLAG) ^= 0) &
/*DR109051*/               (LASTBASE(SYT_DISP(OP1)) = TEMPBASE) ) THEN
                     IF (SYT_FLAGS(OP1) & TEMPORARY_FLAG) = 0 THEN DO;          01359525
                     SYT_DISP(OP1) = DATAPOINT;                                 01359530
                     SYT_SORT(NDECSY) = SHL(DATAPOINT,16) + OP1;                01359540
                  END;                                                          01359550
               END;                                                             01360000
            END;                                                                01360500
            ELSE DO;                                                            01361000
FORMALP:                                                                        01361500
               NARGS(SYT_SCOPE(OP1)) = NARGS(SYT_SCOPE(OP1)) + 1;               01362000
FORMALS:       TEMPSPACE, TMP = 1;                                              01362500
               DO CASE SYT_TYPE(OP1);                                           01363000
                  ;                                                             01363500
 /*   BITSTRINGS   */                                                           01364000
                  DO;                                                           01364500
                     SYT_TYPE(OP1) = SET_BIT_TYPE(SYT_DIMS(OP1));               01365000
                     IF SYT_ARRAY(OP1)=0 THEN                                   01365500
                        PARMTYPE = SYT_TYPE(OP1);                               01366000
                     ELSE PARMTYPE = APOINTER;                                   1366500
                  END;                                                          01367000
 /*  CHARACTERS  */                                                             01367500
                  DO;                                                           01368000
                     PARMTYPE = APOINTER;                                        1368500
                     IF SYT_ARRAY(OP1) ^= 0 THEN DO;                            01369000
                        SYT_DIMS(OP1) = -OP1;                                   01369500
                        TEMPSPACE = TEMPSPACE + 1;                              01370000
                     END;                                                       01370500
                  END;                                                          01371000
 /*  MATRICES */                                                                01371500
                  DO;                                                           01372000
                     TMP = (SYT_DIMS(OP1)&"FF")*SHR(SYT_DIMS(OP1),8);           01372500
                     PARMTYPE = APOINTER;                                        1373000
                  END;                                                          01373500
 /*   VECTORS  */                                                               01374000
                  DO;                                                           01374500
                     TMP = SYT_DIMS(OP1) & "FF";                                01375000
                     PARMTYPE = APOINTER;                                        1375500
                     SYT_DIMS(OP1)=SYT_DIMS(OP1)&"FF"|"100";                    01376000
                  END;                                                          01376500
 /*   SCALARS   */                                                              01377000
                  IF SYT_ARRAY(OP1) = 0 THEN                                    01377500
                     PARMTYPE = SYT_TYPE(OP1);                                  01378000
                  ELSE PARMTYPE = APOINTER;                                      1378500
 /*   INTEGERS   */                                                             01379000
                  IF SYT_ARRAY(OP1) = 0 THEN                                    01379500
                     PARMTYPE = SYT_TYPE(OP1);                                  01380000
                  ELSE PARMTYPE = APOINTER;                                      1380500
 /* UNUSED  */                                                                  01381000
                  ;  ;                                                          01381500
 /* EVENTS  */                                                                  01382000
                     DO;                                                        01382500
                     SYT_TYPE(OP1) = EVENT;                                     01383000
                     SYT_DIMS(OP1) = "FF01";                                    01383500
                     IF SYT_ARRAY(OP1)=0 THEN                                   01384000
                        PARMTYPE = SYT_TYPE(OP1);                               01384500
                     ELSE PARMTYPE = APOINTER;                                   1385000
                  END;                                                          01385500
                  DO;  /* STRUCTURES  */                                        01386000
                     OP2 = SYT_DIMS(OP1);                                       01386500
                     IF OP1 > OP2 THEN                                          01387000
                        CALL STRUCT_PARM_FIX(OP1, OP2);                         01387500
                     ELSE DO;                                                   01388000
                        SYT_LINK1(OP1) = -SYT_PARM(OP2);                        01388500
                        SYT_DIMS(OP2) = -OP1;                                   01389000
                     END;                                                       01389500
                     SYT_TYPE(OP1) = STRUCTURE;                                 01390000
                     PARMTYPE = APOINTER;                                        1390500
                  END;                                                          01391000
                  ; ; ;                                                         01391500
                  END;                                                          01392000
               IF (SYT_FLAGS(OP1)&DOUBLE_FLAG)^=0 THEN DO;                      01392500
                  SYT_TYPE(OP1)=SYT_TYPE(OP1)|8;                                01393000
                  IF PARMTYPE ^= APOINTER THEN                                   1393500
                     PARMTYPE = SYT_TYPE(OP1);                                  01394000
               END;                                                             01394500
               IF (SYT_FLAGS(OP1)&ASSIGN_OR_NAME) ^= 0 THEN PARMTYPE = APOINTER; 1395000
               IF SYT_ARRAY(OP1) ^= 0 THEN                                      01395500
                  IF GETARRAYDIM(1, OP1) < 0 THEN TEMPSPACE = TEMPSPACE + 1;    01396000
               IF SYT_TYPE(OP1) ^= STRUCTURE THEN DO;                           01396500
                  TMP = BIGHTS(SYT_TYPE(OP1)) * TMP;                            01397000
                  DO IX1 = 1 TO GETARRAY#(OP1);                                 01397500
                     OP2 = GETARRAYDIM(IX1, OP1);                               01398000
                     IF OP2 > 0 THEN TMP = TMP * OP2;                           01398500
                  END;                                                          01399000
                  EXTENT(OP1) = TMP;                                            01399500
               END;                                                             01400000
               SYT_CONST(OP1) = CONSTERM(OP1);                                  01400500
               CALL PARAMETER_ALLOCATE(OP1, PARMTYPE, TEMPSPACE);               01401000
            END;                                                                01401500
 /*   LABEL CLASS   */                                                          01402000
            IF (SYT_FLAGS(OP1) & DEFINED_BLOCK) = 0 THEN                        01402500
               DO CASE SYT_TYPE(OP1)&"F";                                       01403000
               ; ;                                                              01403500
 /*  STATEMENT LABEL  */                                                        01404000
                  DO;                                                           01404500
                  IF SYT_DIMS(OP1) < 1 | SYT_DIMS(OP1) > 2 THEN                 01405000
                     SYT_LABEL(OP1) = GETSTATNO;                                01405500
                  ELSE DO;                                                      01406000
 /* THIS IS REALLY AN UPDATE LABEL  */                                          01406500
                     CALL PROCENTRY;                                            01407000
                  END;                                                          01407500
               END;                                                             01408000
               ; ; ; ;                                                          01408500
 /*  PROCEDURE LABEL  */                                                        01409000
                  DO;                                                           01409500
                  CALL PROCENTRY;                                               01410000
                  CALL CHECK_COMPILABLE;                                        01410500
                  PTRARG(SYT_SCOPE(OP1)) = 1;                                   01411000
               END;                                                             01411500
 /*  TASK LABEL  */                                                             01412000
               DO;                                                              01412500
 /?B  /* CR11114 -- BFS/PASS INTERFACE; FIX STACK = 0 FOR TASKS BUG */
                  SYT_FLAGS(OP1) = SYT_FLAGS(OP1) | NOTLEAF_FLAG;
 ?/
                  CALL PROCENTRY;                                               01413000
                  SYT_PARM(OP1), TASK# = TASK# + 1;                             01413500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; NAMING CONVENTIONS */
                  CALL ENTER_ESD(PROGNAME(SELFNAMELOC, 0, TASK#), PROCPOINT, 0);01414000
                  TASKPOINT, SYT_LINK1(TASKPOINT) = OP1;                        01414500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; NAMING CONVENTIONS */
                  CALL ENTER_ESD(PROGNAME(OP1, 0), PROCPOINT, 0,
                     CODE_CSECT_TYPE);
                  TASKPOINT, SYT_LINK1(TASKPOINT) = OP1;                        01414500
      /*            DUPLICATE TASK CSECT NAMES                        */
                  TEMP_OP = SELFNAMELOC;
                  WORK_STRING = ESD_TABLE(PROCPOINT);
                  DO WHILE TEMP_OP ^= OP1;
                     IF ESD_TABLE(SYT_SCOPE(TEMP_OP)) = WORK_STRING THEN
      /* DR106214 -- CHANGE ERROR MSG FROM XQ102 TO PR6   */
                        CALL ERRORS(CLASS_PR, 6, SYT_NAME(OP1));
                     TEMP_OP = SYT_LINK1(TEMP_OP);
                  END;
 ?/
               END;                                                             01415000
 /*  PROGRAM LABEL  */                                                          01415500
               DO;                                                              01416000
                  CALL PROCENTRY;                                               01416500
                  CALL#(PROCPOINT) = TRUE;                                      01417000
                  CALL CHECK_COMPILABLE;                                        01417500
               END;                                                             01418000
 /*  COMPOOL LABEL  */                                                          01418500
               DO;                                                              01419000
                  CALL PROCENTRY;                                               01419500
                  CALL#(PROCPOINT) = 2;                                         01420000
                  CALL CHECK_COMPILABLE;                                        01420500
               END;                                                             01421000
 /* EXTERNAL LABEL */                                                           01421500
               DO;                                                              01422000
                  SYT_LINK1(OP1) = ENTRYPOINT;                                  01422500
                  ENTRYPOINT = OP1;                                             01423000
               END;                                                             01423500
            END;                                                                01424000
            ELSE IF (SYT_FLAGS(OP1) & PARM_FLAGS) ^= 0 THEN DO;                 01424500
               NARGS(SYT_SCOPE(OP1)) = NARGS(SYT_SCOPE(OP1)) + 1;               01425000
               CALL PARAMETER_ALLOCATE(OP1, APOINTER, 1);                        1425500
               CALL SET_PROCESS_SIZE(OP1);                                      01426000
            END;                                                                01426500
            ELSE IF (SYT_FLAGS(OP1) & EXTERNAL_FLAG) = 0 THEN DO;               01427000
               CALL SET_NEST_AND_LOCKS;                                         01427500
               CALL ENTER(OP1);                                                 01428000
               SYT_BASE(OP1) = NAMESIZE(OP1);                                    1428500
               CALL SET_PROCESS_SIZE(OP1);                                      01429000
            END;                                                                01429500
            ELSE DO;                                                            01430000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; NONHAL HANDLING */
               /*** DR108643 ***/
               IF (SYT_FLAGS2(OP1) & NONHAL_FLAG) ^= 0 THEN DO;                 01430500
               /*** END DR108643 ***/
                  SYT_LINK1(OP1) = XPROGLINK;                                   01431000
                  XPROGLINK = OP1;                                              01431500
               END;                                                             01432000
               ELSE DO;                                                         01432500
                  CALL PROCENTRY;                                               01433000
                  CALL ENTER_ESD(PROGNAME(OP1, EXTTYPE(OP1)), PROCPOINT, 2);    01433500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; NONHAL HANDLING */
                  CALL PROCENTRY;                                               01433000
                  TEMP_EXTTYPE = EXTTYPE(OP1);
                     IF TEMP_EXTTYPE = 3 THEN
                        CALL ENTER_ESD(PROGNAME(OP1, TEMP_EXTTYPE), PROCPOINT,
                           2, DATA_CSECT_TYPE);
                     ELSE
                        CALL ENTER_ESD(PROGNAME(OP1, TEMP_EXTTYPE), PROCPOINT,
                            2, CODE_CSECT_TYPE);
 ?/
                  IF SYT_TYPE(OP1) ^= PROG_LABEL THEN                           01434000
                     PTRARG(SYT_SCOPE(OP1)) = 1;                                01434500
                  IF SYT_TYPE(OP1) = COMPOOL_LABEL &                            01434510
                     (SYT_FLAGS(OP1) & SDF_INCL_FLAG) ^= 0 THEN DO;             01434520
                     OVERFLOW_LEVEL = SYT_ADDR(OP1);                            01434530
                     IF (OVERFLOW_LEVEL & 4) = 4 THEN DO;                       01434545
                        REMOTE_LEVEL(PROCPOINT), DATALIMIT = DATALIMIT + 1;     01434550
/?P  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
                        CALL ENTER_ESD(PROGNAME(PROC_LEVEL(PROCPOINT),11),      01434560
                           DATALIMIT, 2);                                       01434570
                     END;                                                       01434580
     /* CR11114 -- THIS SECTION OF CODE IS SPILL RELATED           */
                     IF (OVERFLOW_LEVEL & 2) = 2 THEN DO;                       01434590
                        OVERFLOW_LEVEL(PROCPOINT), DATALIMIT = DATALIMIT + 1;   01434600
                        LASTBASE(DATALIMIT)=STARTBASE;                          01434610
                        CALL ENTER_ESD(PRIM_TO_OVFL(PROCPOINT), DATALIMIT, 2);  01434620
                     END;                                                       01434630
?/
/?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
                        CALL ENTER_ESD(PROGNAME(PROC_LEVEL(PROCPOINT),11),      01434560
                           DATALIMIT, 2, DATA_CSECT_TYPE);                      01434570
                     END;                                                       01434580
?/
                     IF (OVERFLOW_LEVEL & 1) = 1 THEN DO;                       01434640
                        DATALIMIT = DATALIMIT + 1;                              01434650
                        IF REMOTE_LEVEL(PROCPOINT)=0 THEN                       01434660
                           REMOTE_LEVEL(PROCPOINT) = DATALIMIT;                 01434670
                        OVERFLOW_LEVEL(REMOTE_LEVEL(PROCPOINT))=DATALIMIT;      01434680
/?P  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
                        CALL ENTER_ESD('#U'||SUBSTR(ESD_TABLE(PROCPOINT),2),    01434690
                           DATALIMIT, 2);                                       01434700
?/
/?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
                        CALL ENTER_ESD('#U'||SUBSTR(ESD_TABLE(PROCPOINT),2),    01434690
                           DATALIMIT, 2, DATA_CSECT_TYPE);                      01434700
?/
                     END;                                                       01434710
                     SYT_ADDR(OP1) = 0;                                         01434720
                  END;                                                          01434730
/?P  /* CR11114 -- BFS/PASS INTERFACE; NONHAL HANDLING */
               END;                                                             01435000
?/
            END;                                                                01435500
 /*  FUNCTION CLASS  */                                                         01436000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; NONHAL HANDLING */
            IF (SYT_FLAGS2(OP1) & NONHAL_FLAG) = 0 THEN /* DR108643 */          01436500
 ?/
               DO;                                                              01437000
               IF (SYT_FLAGS(OP1) & DEFINED_LABEL) ^= 0 THEN                    01437500
                  IF (SYT_FLAGS(OP1) & NAME_FLAG) ^= 0 THEN DO;                 01438000
                  IF (SYT_FLAGS(OP1) & PARM_FLAGS) ^= 0 THEN                    01438500
                     GO TO FORMALP;                                             01439000
                  CALL SET_NEST_AND_LOCKS;                                      01439500
                  CALL VARIABLES(OP1);                                          01440000
                  SYT_BASE(OP1) = NAMESIZE(OP1);                                 1440500
                  SYT_PARM(OP1) = -(PACKTYPE(SYT_TYPE(OP1))&1);                 01441000
               END;                                                             01441500
               ELSE DO;                                                         01442000
                  CALL PROCENTRY;                                               01442500
                  IF (SYT_FLAGS(OP1)&EXTERNAL_FLAG)=0 THEN                      01443000
                     CALL CHECK_COMPILABLE;                                     01443500
                  ELSE DO;                                                      01444000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT    */
                     CALL ENTER_ESD(PROGNAME(OP1, 1), PROCPOINT, 2);            01444500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT    */
                     CALL ENTER_ESD(PROGNAME(OP1, 1), PROCPOINT, 2,
                        CODE_CSECT_TYPE);
 ?/
                  END;                                                          01445000
                  IF SYT_TYPE(OP1) = MAJ_STRUC THEN GO TO FORMALS;              01445500
FUNC_PARM:        SYT_PARM(OP1) = -1;                                           01446000
                  DO CASE PACKTYPE(SYT_TYPE(OP1));                              01446500
                     GO TO FORMALS;  /* VECTOR-MATRIX */                        01447000
                     SYT_TYPE(OP1) = SET_BIT_TYPE(SYT_DIMS(OP1));               01447500
                     GO TO FORMALS;  /* CHARACTERS */                           01448000
                     IF (SYT_FLAGS(OP1)&DOUBLE_FLAG)^=0 THEN                    01448500
                        SYT_TYPE(OP1) = SYT_TYPE(OP1) | 8;                      01449000
                  END;                                                          01449500
                  /**** DR108643 ****/
                  IF (SYT_FLAGS2(OP1) & NONHAL_FLAG) = 0 THEN                   01450000
                  /**** END DR108643 ****/
                     PTRARG(SYT_SCOPE(OP1)) = 1;                                01450500
               END;                                                             01451000
 /?P        /* CR11114 -- BFS/PASS INTERFACE; NONHAL HANDLING */
            END;                                                                01451500
            ELSE DO;                                                            01452000
               SYT_LINK1(OP1) = XPROGLINK;                                      01452500
               XPROGLINK = OP1;                                                 01453000
               IF SYT_TYPE(OP1) = MAJ_STRUC | ^PACKTYPE(SYT_TYPE(OP1)) THEN DO; 01453500
                  CALL ERRORS(CLASS_PE,100);                                    01454000
                  SYT_TYPE(OP1) = ANY_LABEL;                                    01454500
               END;                                                             01455000
               ELSE GO TO FUNC_PARM;                                            01455500
 ?/
            END;                                                                01456000
 /* UNUSED  */                                                                  01456500
            ;  ;  ;                                                             01457000
 /*  TEMPLATE CLASS  */                                                         01457500
               IF SYT_TYPE(OP1) = TEMPL_NAME THEN DO;                           01458000
               SYT_LINK2(OP1), SYT_ADDR(OP1) = 0;                               01458500
               SYT_LOCK#(OP1) = SYT_LOCK#(OP1) | "80";                          01459000
               IF (SYT_FLAGS(OP1) & EVIL_FLAGS) ^= EVIL_FLAGS THEN DO;          01459500
                  WORK2 = FALSE;                                                01459600
                  OP2 = OP1;                                                    01460000
                  DO WHILE OP2 > 0;                                             01460500
                     WORK2 = WORK2 | SYMBOL_USED(OP2);                          01460600
                     IF SYT_LINK1(OP2) > 0 THEN DO;                             01461000
                        CALL ENTER(OP2);                                        01461500
                        SYT_TYPE(OP2) = STRUCTURE;                              01462000
                        SYT_LEVEL(OP2) = NDECSY;                                01462500
                        OP2 = SYT_LINK1(OP2);                                   01463000
                     END;                                                       01463500
                     ELSE IF SYT_TYPE(OP2) = MAJ_STRUC THEN DO;                 01464000
                        CALL ENTER(OP2);                                        01464500
                        SYT_TYPE(OP2) = STRUCTURE;                              01465000
                        TMP = SYT_DIMS(OP2);                                    01465500
                        SYT_BASE(OP2) = SYT_BASE(TMP);                          01466000
                        SYT_DISP(OP2) = SYT_DISP(TMP);                          01466500
                        EXTENT(OP2) = EXTENT(TMP);                              01467000
                        IF (SYT_FLAGS(OP2) & NAME_FLAG) ^= 0 THEN DO;           01467500
                           SYT_BASE(OP2) = NAMESIZE(OP2);                        1468000
                           SYT_DISP(OP2) = 0;                                   01468500
                           IF SYT_ARRAY(OP2) ^= 0 THEN DO;                      01469000
                              TMP = EXTENT(TMP) + SYT_DISP(TMP);                01469500
                              EXTENT(OP2) = TMP * SYT_ARRAY(OP2);               01470000
                           END;                                                 01470500
                        END;                                                    01471000
                        OP2 = SYT_LINK2(OP2);                                   01471500
                     END;                                                       01472000
                     ELSE IF SYT_TYPE(OP2) >= ANY_LABEL THEN DO;                01472500
                        CALL ENTER(OP2);                                        01473000
                        SYT_BASE(OP2) = NAMESIZE(OP2);                           1473500
                        CALL SET_PROCESS_SIZE(OP2);                             01474000
                        OP2 = SYT_LINK2(OP2);                                   01474500
                     END;                                                       01475000
                     ELSE DO;                                                   01475500
                        SYT_BASE(OP2) = VARIABLES(OP2);                         01476000
                        IF (SYT_FLAGS(OP2) & NAME_FLAG) ^= 0 THEN DO;           01476500
                           SYT_BASE(OP2) = NAMESIZE(OP2);                        1477000
                           IF PACKFUNC_CLASS(SYT_CLASS(OP2)) THEN               01477500
                              SYT_PARM(OP2) = -(PACKTYPE(SYT_TYPE(OP2))&1);     01478000
                        END;                                                    01478500
                        ELSE IF DATATYPE(SYT_TYPE(OP2)) = BITS THEN             01479000
                           IF SYT_ARRAY(OP2) = 0 THEN                           01479500
                           IF (SYT_FLAGS(OP2) & DENSE_FLAG) ^= 0 THEN           01480000
                           SYT_PARM(OP2) = 2;                                   01480500
                        OP2 = SYT_LINK2(OP2);                                   01481000
                     END;                                                       01481500
                     DO WHILE OP2 < 0;                                          01482000
                        CALL ALLOCATE_TEMPLATE(-OP2);                           01482500
                        OP2 = SYT_LINK2(-OP2);                                  01483000
                     END;                                                       01483500
                  END;                                                          01484000
                  NDECSY = NDECSY - 1;                                          01484500
                  CONST, IX1 = 0;                                               01485000
                  OP2 = OP1;                                                    01485500
                  DO WHILE OP2 > 0;                                             01486000
                     SYT_ADDR(OP2) = SYT_ADDR(OP2) + CONST(IX1);                01486500
                     IF SYT_TYPE(OP2) = STRUCTURE THEN                          01487000
                        IF SYT_LINK1(OP2) = 0 THEN                              01487500
                        IF SYT_DIMS(OP2) = OP1 THEN                             01488000
                        EXTENT(OP2) = EXTENT(OP1);                              01488500
                     IF ASSEMBLER_CODE THEN DO;                                 01489000
                        OUTPUT=IX1||X2||SYT_NAME(OP2)||X2||LEFTBRACKET||        01489500
                           SYT_BASE(OP2)||COMMA||SYT_DISP(OP2)||COMMA||         01490000
                           EXTENT(OP2)||RIGHTBRACKET||X2||HEX(SYT_ADDR(OP2),6)||01490500
                           X2||SYT_CONST(OP2)||X2||LEFTBRACKET||                01491000
                           (SHR(SYT_DIMS(OP2),8)&"FF")||COMMA||                 01491500
                           (SYT_DIMS(OP2)&"FF")||RIGHTBRACKET;                  01492000
                     END;                                                       01492500
                     IF SYT_LINK1(OP2) > 0 THEN DO;                             01493000
                        IX1 = IX1 + 1;                                          01493500
                        CONST(IX1) = SYT_ADDR(OP2);                             01494000
                        OP2 = SYT_LINK1(OP2);                                   01494500
                     END;                                                       01495000
                     ELSE OP2 = SYT_LINK2(OP2);                                 01495500
                     DO WHILE OP2 < 0;                                          01496000
                        IX1 = IX1 - 1;                                          01496500
                        OP2 = SYT_LINK2(-OP2);                                  01497000
                     END;                                                       01497500
                  END;                                                          01498000
                  IF SYT_DIMS(OP1) < 0 THEN DO;                                 01498500
                     OP2 = -SYT_DIMS(OP1);                                      01498510
                     DO WHILE OP2 > 0;                                          01499500
                        CALL STRUCT_PARM_FIX(OP2, OP1);                         01500000
                        OP2 = SYT_LINK1(OP2);                                   01500500
                     END;                                                       01501000
                     SYT_DIMS(OP1) = 0;                                         01501500
                  END;                                                          01502000
                  IF WORK2|^SREF THEN DO;  /* IF TEMPLATE USED BY COMPILATION */01502100
                     IF STRUCT_START = 0 THEN                                   01502500
                        STRUCT_START = OP1;                                     01503000
                     ELSE SYT_LEVEL(STRUCT_LINK) = OP1;                         01503500
                     SYT_LEVEL(OP1) = 0;                                        01504000
                     STRUCT_LINK = OP1;                                         01504500
                  END;                                                          01504600
               END;                                                             01505000
            END;                                                                01505500
 /*  OTHER CLASSES  */                                                          01506000
            ; ; ; ;                                                             01506500
            END;                                                                01507000
      END;                                                                      01507500
   END INITIALISE  /* $S  */  ;  /* $S  */                                      01508000
