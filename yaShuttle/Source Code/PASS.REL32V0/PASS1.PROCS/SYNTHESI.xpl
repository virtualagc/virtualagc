 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SYNTHESI.xpl
    Purpose:    This is a part of "Phase 1" (syntax analysis) of the HAL/S-FC 
                compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-07 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  SYNTHESIZE                                             */
 /* MEMBER NAME:     SYNTHESI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*       PRODUCTION_NUMBER FIXED                                           */
 /* LOCAL DECLARATIONS:                                                     */
 /*       ALSO_SCALAR       LABEL              INLINE_ENTRY      LABEL      */
 /*       ARITH_LITS        LABEL              INLINE_NAME       CHARACTER  */
 /*       ARRAY_SPEC        LABEL              INLINE_SCOPE      LABEL      */
 /*       ASSIGN_ARG        LABEL              IO_CONTROL        LABEL      */
 /*       ASSIGNING         LABEL              IO_EMIT           LABEL      */
 /*       CHANGED_STMT_NUM  BIT(1)                                          */
 /*       CASE_HEAD         LABEL              LABEL_INCORP      LABEL      */
 /*       CHAR_LITS         LABEL              MAKE_ATTRIBUTES   LABEL      */
 /*       CHECK_ARRAY_SPEC  LABEL              MATRICES_MAY_GO_RIGHT  LABEL */
 /*       CHECK_DECLS       LABEL              MATRICES_TAKEN_CARE_OF  LABEL*/
 /*       CHECK_READ        LABEL              MODE_CHECK        LABEL      */
 /*       CLOSE_IF          LABEL              MOST_IDS          LABEL      */
 /*       CLOSE_IT          LABEL              NEW_SCOPE         LABEL      */
 /*       CLOSE_SCOPE       LABEL              NEXT_ARG          LABEL      */
 /*       COMBINE_SCALARS_AND_VECTORS  LABEL   NO_ATTR_STRUCT    LABEL      */
 /*       CROSS_PRODUCTS    LABEL              NON_EVENT         LABEL      */
 /*       DECL_STAT         LABEL              OK_LABELS         LABEL      */
 /*       DEFAULT_SHAPER    LABEL              ON_ERROR_ACTION   LABEL      */
 /*       DIV_FAIL          LABEL              OUTERMOST_BLOCK   LABEL      */
 /*       DO_BIT_CAT        LABEL              POWER_FAIL        LABEL      */
 /*       DO_BIT_CONST      LABEL              PROC_FUNC_HEAD    LABEL      */
 /*       DO_BIT_CONSTANT_END  LABEL           REGULAR_EXP       LABEL      */
 /*       DO_BIT_FACTOR     LABEL              REPEATING         LABEL      */
 /*       DO_CHAR_CAT       LABEL              SCALAR_SHAPER     LABEL      */
 /*       DO_CONSTANT       LABEL              SCHED_PRIO        LABEL      */
 /*       DO_DISCRETE       LABEL              SCHEDULE_AT       LABEL      */
 /*       DO_DONE           LABEL              SCHEDULE_EMIT     LABEL      */
 /*       DO_FLOWSET        LABEL              SCHEDULE_EVERY    LABEL      */
 /*       DO_INIT_CONST_HEAD  LABEL            SET_ARITH_SHAPERS LABEL      */
 /*       DO_LIT_BIT_FACTOR LABEL              SET_AUTSTAT       LABEL      */
 /*       DO_QUALIFIED_ATTRIBUTE  LABEL        SET_CASE          LABEL      */
 /*       DOT_PRODUCTS      LABEL              SET_INIT          LABEL      */
 /*       DOT_PRODUCTS_LOOP LABEL              SHARP_EXP         LABEL      */
 /*       DUPLICATE_BLOCK   LABEL              SIGNAL_EMIT       LABEL      */
 /*       EMIT_CASE         LABEL              SIMPLE_EXP        LABEL      */
 /*       EMIT_IF           LABEL              SIMPLE_SUBS       LABEL      */
 /*       EMIT_IO_ARG       LABEL              SPEC_TYPE         LABEL      */
 /*       EMIT_IO_HEAD      LABEL              SPEC_VAR          LABEL      */
 /*       EMIT_NULL         LABEL              SS_CHEX           LABEL      */
 /*       EMIT_REL          LABEL              SS_FIXUP          LABEL      */
 /*       EMIT_WHILE        LABEL              STRUC_IDS         LABEL      */
 /*       END_ASSIGN        LABEL              STRUCT_GOING_DOWN LABEL      */
 /*       END_REPEAT_INIT   LABEL              STRUCT_GOING_UP   LABEL      */
 /*       ENDING_DONE       LABEL              SUB_START         LABEL      */
 /*       EXITTING          LABEL              T_FOUND           LABEL      */
 /*       FINISH_EXP        LABEL              TEMPL_INITIAL_CHECK  LABEL   */
 /*       FIX_AUTSTAT       LABEL              TERM_LIST         LABEL      */
 /*       FIX_NOLAB         LABEL              UNQ_TEST1         LABEL      */
 /*       FIX_NULL          LABEL              UNQ_TEST2         LABEL      */
 /*       FUNC_HEADER       LABEL              UP_PRIO           LABEL      */
 /*       FUNC_IDS          LABEL              UPDATE_CHECK      LABEL      */
 /*       H1                BIT(16)            UPDATE_HEAD       LABEL      */
 /*       H2                BIT(16)            UPDATE_NAME       CHARACTER  */
 /*       INCORPORATE_ATTR  LABEL              WAIT_TIME         LABEL      */
 /*       INIT_ELEMENT      LABEL              WHILE_KEY         LABEL      */
 /*       INIT_MACRO        LABEL              YES_EVENT         LABEL      */
 /*       INLINE_DEFS       LABEL                                           */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*       #PRODUCE_NAME                        MAX_SCOPE#                   */
 /*       ACCESS_FLAG                          MISC_NAME_FLAG               */
 /*       ALDENSE_FLAGS                        MPP1                         */
 /*       ALIGNED_FLAG                         MTX_NDX                      */
 /*       ANY_TYPE                             N_DIM_LIM                    */
 /*       ARRAY_DIM_LIM                        NAME_FLAG                    */
 /*       ARRAY_FLAG                           NDECSY                       */
 /*       ARRAY_SUB_COUNT                      NEST_LIM                     */
 /*       ASSIGN_CONTEXT                       NEXT_ATOM#                   */
 /*       ASSIGN_TYPE                          NO_LOOK_AHEAD_DONE           */
 /*       ATTR_BEGIN_FLAG                      NONHAL_FLAG                  */
 /*       AUTO_FLAG                            NOSPACE                      */
 /*       AUTSTAT_FLAGS                        NUM_EL_MAX                   */
 /*       BIT_LENGTH_LIM                       PAGE_THROWN                  */
 /*       BIT_NDX                              PARM_CONTEXT                 */
 /*       BIT_TYPE                             PARM_FLAGS                   */
 /*       CASE_LEVEL_LIM                       PARSE_STACK                  */
 /*       CHAR_LENGTH_LIM                      PC_STMT_TYPE_BASE            */
 /*       CHAR_NDX                             PCARGBITS                    */
 /*       CHAR_TYPE                            PCARGTYPE                    */
 /*       CLASS_AA                             PCCOPY_INDEX                 */
 /*       CLASS_AV                             PERIOD                       */
 /*       CLASS_B                              PRIMARY                      */
 /*       CLASS_BN                             PROC_LABEL                   */
 /*       CLASS_BT                             PROC_MODE                    */
 /*       CLASS_C                              PROG_LABEL                   */
 /*       CLASS_D                              PROG_MODE                    */
 /*       CLASS_DA                             READ_ACCESS_FLAG             */
 /*       CLASS_DC                             REENTRANT_FLAG               */
 /*       CLASS_DD                             REMOTE                       */
 /*       CLASS_DI                             REMOTE_FLAG                  */
 /*       CLASS_DL                             REPL_ARG_CLASS               */
 /*       CLASS_DN                             REPLACE_TEXT_PTR             */
 /*       CLASS_DQ                             RIGID_FLAG                   */
 /*       CLASS_DS                             SBIT_NDX                     */
 /*       CLASS_DT                             SCALAR_TYPE                  */
 /*       CLASS_DU                             SCLR_NDX                     */
 /*       CLASS_E                              SD_FLAGS                     */
 /*       CLASS_EA                             SINGLE_FLAG                  */
 /*       CLASS_EB                             SP                           */
 /*       CLASS_EC                             STAB_STACKTOP                */
 /*       CLASS_ED                             START_POINT                  */
 /*       CLASS_EL                             STATIC_FLAG                  */
 /*       CLASS_EM                             STMT_END_PTR                 */
 /*       CLASS_EN                             STMT_LABEL                   */
 /*       CLASS_EO                             STMT_NUM                     */
 /*       CLASS_EV                             STRUCTURE_SUB_COUNT          */
 /*       CLASS_FD                             SUB_COUNT                    */
 /*       CLASS_FS                             SYM_ADDR                     */
 /*       CLASS_FT                             SYM_ARRAY                    */
 /*       CLASS_GB                             SYM_CLASS                    */
 /*       CLASS_GC                             SYM_FLAGS                    */
 /*       CLASS_GE                             SYM_LENGTH                   */
 /*       CLASS_GL                             SYM_LINK1                    */
 /*       CLASS_GV                             SYM_LINK2                    */
 /*       CLASS_IR                             SYM_LOCK#                    */
 /*       CLASS_IS                             SYM_NAME                     */
 /*       CLASS_LB                             SYM_NEST                     */
 /*       CLASS_LS                             SYM_PTR                      */
 /*       CLASS_P                              SYM_SCOPE                    */
 /*       CLASS_PC                             SYM_TYPE                     */
 /*       CLASS_PE                             SYT_ADDR                     */
 /*       CLASS_PF                             SYT_ARRAY                    */
 /*       CLASS_PL                             SYT_CLASS                    */
 /*       CLASS_PP                             SYT_FLAGS                    */
 /*       CLASS_PS                             SYT_HASHSIZE                 */
 /*       CLASS_PT                             SYT_LINK1                    */
 /*       CLASS_QS                             SYT_LINK2                    */
 /*       CLASS_QX                             SYT_LOCK#                    */
 /*       CLASS_RT                             SYT_MAX                      */
 /*       CLASS_RU                             SYT_NAME                     */
 /*       CLASS_SP                             SYT_NEST                     */
 /*       CLASS_SV                             SYT_PTR                      */
 /*       CLASS_T                              SYT_SCOPE                    */
 /*       CLASS_TC                             SYT_TYPE                     */
 /*       CLASS_TD                             TASK_LABEL                   */
 /*       CLASS_UI                             TASK_MODE                    */
 /*       CLASS_UP                             TEMP_TYPE                    */
 /*       CLASS_UT                             TEMPL_NAME                   */
 /*       CLASS_VA                             TEMPLATE_CLASS               */
 /*       CLASS_VC                             TEMPORARY_FLAG               */
 /*       CLASS_VE                             TEMPORARY_IMPLIED            */
 /*       CLASS_XM                             TOKEN                        */
 /*       CLASS_XR                             TPL_FLAG                     */
 /*       CLASS_XS                             TRUE                         */
 /*       CMPL_MODE                            UNSPEC_LABEL                 */
 /*       COMPOOL_LABEL                        UPDATE_MODE                  */
 /*       COMSUB_END                           VAR_CLASS                    */
 /*       CONSTANT_FLAG                        VAR_LENGTH                   */
 /*       CONTROL                              VEC_LENGTH_LIM               */
 /*       CROSS_TOKEN                          VEC_NDX                      */
 /*       CROSS                                VEC_TYPE                     */
 /*       CURLBLK                              XAFOR                        */
 /*       DECL_STMT_TYPE                       XAST                         */
 /*       DECLARE_CONTEXT                      XBAND                        */
 /*       DEF_BIT_LENGTH                       XBCAT                        */
 /*       DEF_CHAR_LENGTH                      XBEQU                        */
 /*       DEF_MAT_LENGTH                       XBNOT                        */
 /*       DEF_VEC_LENGTH                       XBOR                         */
 /*       DEFAULT_ATTR                         XBRA                         */
 /*       DEFAULT_TYPE                         XBTRU                        */
 /*       DEFINED_LABEL                        XCANC                        */
 /*       DENSE_FLAG                           XCAND                        */
 /*       DEVICE_LIMIT                         XCCAT                        */
 /*       DO_LEVEL_LIM                         XCDEF                        */
 /*       DO_STMT#                             XCEQU                        */
 /*       DO_TOKEN                             XCFOR                        */
 /*       DOT_TOKEN                            XCLBL                        */
 /*       DOT                                  XCLOS                        */
 /*       DOUBLE_FLAG                          XCNOT                        */
 /*       DUMMY_FLAG                           XCO_N                        */
 /*       DUPL_FLAG                            XCOR                         */
 /*       DW_AD                                XCTST                        */
 /*       ENDSCOPE_FLAG                        XDCAS                        */
 /*       EQUATE_TYPE                          XDFOR                        */
 /*       EVENT_TYPE                           XDSMP                        */
 /*       EVIL_FLAG                            XDSUB                        */
 /*       EXCLUSIVE_FLAG                       XDTST                        */
 /*       EXPONENT                             XECAS                        */
 /*       EXPRESSION_CONTEXT                   XEDCL                        */
 /*       EXT_ARRAY                            XEFOR                        */
 /*       EXTENT                               XEINT                        */
 /*       EXTERNAL_FLAG                        XERON                        */
 /*       FACTOR                               XERSE                        */
 /*       FACTOR_LIM                           XESMP                        */
 /*       FACTORED_IC_FND                      XETST                        */
 /*       FACTORED_IC_PTR                      XEXTN                        */
 /*       FALSE                                XFBRA                        */
 /*       FCN_LV                               XFDEF                        */
 /*       FCN_MODE                             XFILE                        */
 /*       FIRST_FREE                           XICLS                        */
 /*       FIRST_STMT                           XIDEF                        */
 /*       FL_NO                                XIEQU                        */
 /*       FUNC_CLASS                           XIFHD                        */
 /*       FUNC_MODE                            XIMD                         */
 /*       HALMAT_CRAP                          XINL                         */
 /*       HOST_BIT_LENGTH_LIM                  XLBL                         */
 /*       IF_TOKEN                             XLIT                         */
 /*       ILL_EQUATE_ATTR                      XMDEF                        */
 /*       ILL_INIT_ATTR                        XMEQU                        */
 /*       ILL_MINOR_STRUC                      XMINV                        */
 /*       ILL_NAME_ATTR                        XMNEG                        */
 /*       ILL_TEMPL_ATTR                       XMSDV                        */
 /*       ILL_TEMPORARY_ATTR                   XMTRA                        */
 /*       ILL_TERM_ATTR                        XNASN                        */
 /*       IMP_DECL                             XNEQU                        */
 /*       IMPL_T_FLAG                          XPDEF                        */
 /*       INACTIVE_FLAG                        XPMAR                        */
 /*       INCLUDED_REMOTE                      XPMHD                        */
 /*       IND_CALL_LAB                         XPMIN                        */
 /*       IND_LINK                             XPRIO                        */
 /*       INDENT_INCR                          XREAD                        */
 /*       INIT_CONST                           XREF_ASSIGN                  */
 /*       INIT_FLAG                            XREF_REF                     */
 /*       INLINE_FLAG                          XRTRN                        */
 /*       INLINE_INDENT                        XSCHD                        */
 /*       INLINE_MODE                          XSEQU                        */
 /*       INPUT_PARM                           XSET                         */
 /*       INT_NDX                              XSEXP                        */
 /*       INT_TYPE                             XSFST                        */
 /*       LABEL_CLASS                          XSGNL                        */
 /*       LABEL_DEFINITION                     XSIEX                        */
 /*       LABEL_FLAG                           XSPEX                        */
 /*       LAST_POP#                            XSYT                         */
 /*       LATCHED_FLAG                         XTDCL                        */
 /*       LIST_EXP_LIM                         XTDEF                        */
 /*       LIT_PG                               XTEQU                        */
 /*       LITERAL1                             XTERM                        */
 /*       LITERAL2                             XTNT                         */
 /*       LITFILE                              XTSUB                        */
 /*       LIT1                                 XUDEF                        */
 /*       LIT2                                 XVAC                         */
 /*       LOCK_FLAG                            XVEQU                        */
 /*       LOCK_LIM                             XWAIT                        */
 /*       MAC_TXT                              XXASN                        */
 /*       MACRO_TEXT                           XXPT                         */
 /*       MAJ_STRUC                            XXREC                        */
 /*       MAT_DIM_LIM                          XXXAR                        */
 /*       MAT_TYPE                             XXXND                        */
 /*       MAX_PARAMETER                        XXXST                        */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*       ACCESS_FOUND                         MAIN_SCOPE                   */
 /*       ALT_PCARG#                           MAT_LENGTH                   */
 /*       ARRAYNESS_FLAG                       MATRIX_COUNT                 */
 /*       ASSIGN_ARG_LIST                      MATRIX_PASSED                */
 /*       ATOM#_FAULT                          MATRIXP                      */
 /*       ATTR_FOUND                           MAXNEST                      */
 /*       ATTR_INDENT                          MP                           */
 /*       ATTR_LOC                             N_DIM                        */
 /*       ATTR_MASK                            NAME_BIT                     */
 /*       ATTRIBUTES                           NAME_HASH                    */
 /*       BEGINP                               NAME_IMPLIED                 */
 /*       BI_FUNC_FLAG                         NAME_PSEUDOS                 */
 /*       BIT_LENGTH                           NAMING                       */
 /*       BLOCK_MODE                           NEST                         */
 /*       BLOCK_SYTREF                         NEST_LEVEL                   */
 /*       BUILDING_TEMPLATE                    NEST_STACK                   */
 /*       CLOSE_BCD                            NEXT_SUB                     */
 /*       COMPILING                            NONHAL                       */
 /*       C                                    NUM_ELEMENTS                 */
 /*       CASE_LEVEL                           NUM_FL_NO                    */
 /*       CASE_STACK                           NUM_STACKS                   */
 /*       CHAR_LENGTH                          ON_ERROR_PTR                 */
 /*       CLASS                                OUTER_REF_INDEX              */
 /*       COMM                                 OUTER_REF_PTR                */
 /*       CONTEXT                              PARMS_PRESENT                */
 /*       CROSS_COUNT                          PARMS_WATCH                  */
 /*       CSECT_LENGTHS                        PCARG#                       */
 /*       CURRENT_SCOPE                        PCARGOFF                     */
 /*       DATA_REMOTE                          PP                           */
 /*       DELAY_CONTEXT_CHECK                  PPTEMP                       */
 /*       DO_CHAIN                             PROCMARK                     */
 /*       DO_INIT                              PROCMARK_STACK               */
 /*       DO_INX                               PSEUDO_FORM                  */
 /*       DO_LEVEL                             PSEUDO_LENGTH                */
 /*       DO_LOC                               PSEUDO_TYPE                  */
 /*       DOT_COUNT                            PTR                          */
 /*       ELSE_FLAG                                                         */
 /*       ELSEIF_PTR                           PTR_TOP                      */
 /*       END_FLAG                                                          */
 /*       EXPONENT_LEVEL                       REF_ID_LOC                   */
 /*       EXT_P                                REFER_LOC                    */
 /*       EXTERNAL_MODE                        REGULAR_PROCMARK             */
 /*       EXTERNALIZE                          REL_OP                       */
 /*       FACTOR_FOUND                         S                            */
 /*       FACTORED_TYPE                        S_ARRAY                      */
 /*       FACTORING                            SAVE_ARRAYNESS_FLAG          */
 /*       FCN_ARG                              SAVE_INDENT_LEVEL            */
 /*       FCN_LOC                              SAVE_SCOPE                   */
 /*       FIXF                                 SCALAR_COUNT                 */
 /*       FIXL                                 SCALARP                      */
 /*       FIXV                                 SCOPE#                       */
 /*       GRAMMAR_FLAGS                        SCOPE#_STACK                 */
 /*       HALMAT_OK                            SIMULATING                   */
 /*       IC_FND                               SRN                          */
 /*       IC_PTR                               SRN_COUNT_MARK               */
 /*       ID_LOC                               SRN_COUNT                    */
 /*       INDENT_STACK                         SRN_FLAG                     */
 /*       IODEV                                SRN_MARK                     */
 /*       I                                    STAB_MARK                    */
 /*       IC_FORM                              STAB_STACK                   */
 /*       IC_FOUND                             STAB2_MARK                   */
 /*       IC_LEN                               STAB2_STACKTOP               */
 /*       IC_LINE                              STACK_PTR                    */
 /*       IC_LOC                               STARRED_DIMS                 */
 /*       IC_PTR1                              STMT_PTR                     */
 /*       IC_TYPE                              STMT_TYPE                    */
 /*       IC_VAL                               STRUC_DIM                    */
 /*       IF_FLAG                                                           */
 /*       IMPLICIT_T                           STRUC_PTR                    */
 /*       IMPLIED_UPDATE_LABEL                 STRUC_SIZE                   */
 /*       INCL_SRN                             SUB_END_PTR                  */
 /*       INCL_SRN_MARK                        SUB_SEEN                     */
 /*       INDENT_LEVEL                         SUBSCRIPT_LEVEL              */
 /*       INFORMATION                          SYM_TAB                      */
 /*       INIT_EMISSION                        TEMP1                        */
 /*       INLINE_INDENT_RESET                  TEMP2                        */
 /*       INLINE_LABEL                         TEMP3                        */
 /*       INLINE_LEVEL                         TEMP                         */
 /*       INLINE_STMT_RESET                    TEMP_SYN                     */
 /*       INX                                  TERMP                        */
 /*       J                                    TOKEN_FLAGS                  */
 /*       K                                    TPL_REMOTE                   */
 /*       LOCK#                                TPL_VERSION                  */
 /*       L                                    TYPE                         */
 /*       LABEL_COUNT                          UPDATE_BLOCK_LEVEL           */
 /*       LAST_WRITE                           VAL_P                        */
 /*       LINE_MAX                             VAR                          */
 /*       LOC_P                                VEC_LENGTH                   */
 /*       MAC_NUM                              VECTOR_COUNT                 */
 /*       MACRO_ARG_COUNT                      VECTORP                      */
 /*       MACRO_TEXTS                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*       ADD_AND_SUBTRACT                     ICQ_ARRAY#                   */
 /*       ARITH_LITERAL                        ICQ_TERM#                    */
 /*       ARITH_SHAPER_SUB                     IORS                         */
 /*       ARITH_TO_CHAR                        KILL_NAME                    */
 /*       ASSOCIATE                            LABEL_MATCH                  */
 /*       ATTACH_SUBSCRIPT                     LIT_RESULT_TYPE              */
 /*       BIT_LITERAL                          MAKE_FIXED_LIT               */
 /*       BLOCK_SUMMARY                        MATCH_ARITH                  */
 /*       CALL_SCAN                            MATCH_SIMPLES                */
 /*       CHAR_LITERAL                         MATRIX_COMPARE               */
 /*       CHECK_ARRAYNESS                      MULTIPLY_SYNTHESIZE          */
 /*       CHECK_ASSIGN_CONTEXT                 NAME_ARRAYNESS               */
 /*       CHECK_CONFLICTS                      NAME_COMPARE                 */
 /*       CHECK_CONSISTENCY                    OUTPUT_WRITER                */
 /*       CHECK_EVENT_CONFLICTS                PREC_SCALE                   */
 /*       CHECK_EVENT_EXP                      PROCESS_CHECK                */
 /*       CHECK_IMPLICIT_T                     PUSH_FCN_STACK               */
 /*       CHECK_NAMING                         PUSH_INDIRECT                */
 /*       CHECK_STRUC_CONFLICTS                READ_ALL_TYPE                */
 /*       COMPRESS_OUTER_REF                   RESET_ARRAYNESS              */
 /*       COPINESS                             SAVE_ARRAYNESS               */
 /*       DESCORE                              SAVE_LITERAL                 */
 /*       DISCONNECT                           SET_BI_XREF                  */
 /*       EMIT_ARRAYNESS                       SET_BLOCK_SRN                */
 /*       EMIT_EXTERNAL                        SET_LABEL_TYPE               */
 /*       EMIT_PUSH_DO                         SET_OUTER_REF                */
 /*       EMIT_SMRK                            SET_SYT_ENTRIES              */
 /*       EMIT_SUBSCRIPT                       SET_XREF                     */
 /*       END_ANY_FCN                          SET_XREF_RORS                */
 /*       END_SUBBIT_FCN                       SETUP_CALL_ARG               */
 /*       ENTER                                SETUP_NO_ARG_FCN             */
 /*       ENTER_LAYOUT                         SETUP_VAC                    */
 /*       ERROR                                SRN_UPDATE                   */
 /*       ERROR_SUB                            STAB_HDR                     */
 /*       GET_ICQ                              STAB_LAB                     */
 /*       GET_LITERAL                          STAB_VAR                     */
 /*       HALMAT_BACKUP                        STACK_DUMP                   */
 /*       HALMAT_FIX_PIP#                      START_NORMAL_FCN             */
 /*       HALMAT_FIX_PIPTAGS                   STRUCTURE_COMPARE            */
 /*       HALMAT_FIX_POPTAG                    TIE_XREF                     */
 /*       HALMAT_INIT_CONST                    UNARRAYED_INTEGER            */
 /*       HALMAT_OUT                           UNARRAYED_SCALAR             */
 /*       HALMAT_PIP                           UNARRAYED_SIMPLE             */
 /*       HALMAT_POP                           UNBRANCHABLE                 */
 /*       HALMAT_TUPLE                         VECTOR_COMPARE               */
 /*       HASH                                                              */
 /* CALLED BY:                                                              */
 /*       COMPILATION_LOOP                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SYNTHESIZE <==                                                      */
 /*     ==> GET_LITERAL                                                     */
 /*     ==> DESCORE                                                         */
 /*         ==> PAD                                                         */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> MAKE_FIXED_LIT                                                  */
 /*         ==> GET_LITERAL                                                 */
 /*     ==> HASH                                                            */
 /*     ==> SAVE_LITERAL                                                    */
 /*     ==> ICQ_TERM#                                                       */
 /*     ==> ICQ_ARRAY#                                                      */
 /*     ==> CHECK_STRUC_CONFLICTS                                           */
 /*     ==> ENTER                                                           */
 /*     ==> DISCONNECT                                                      */
 /*     ==> ENTER_LAYOUT                                                    */
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
 /*     ==> COMPRESS_OUTER_REF                                              */
 /*         ==> MAX                                                         */
 /*     ==> BLOCK_SUMMARY                                                   */
 /*         ==> COMPRESS_OUTER_REF ****                                     */
 /*     ==> SET_OUTER_REF                                                   */
 /*         ==> COMPRESS_OUTER_REF ****                                     */
 /*     ==> SET_BI_XREF                                                     */
 /*         ==> ENTER_XREF                                                  */
 /*     ==> SET_XREF                                                        */
 /*         ==> ENTER_XREF                                                  */
 /*         ==> SET_OUTER_REF                                               */
 /*             ==> COMPRESS_OUTER_REF ****                                 */
 /*     ==> SET_XREF_RORS                                                   */
 /*         ==> SET_XREF ****                                               */
 /*     ==> TIE_XREF                                                        */
 /*         ==> ERROR ****                                                  */
 /*     ==> EMIT_EXTERNAL                                                   */
 /*         ==> PAD                                                         */
 /*         ==> BLANK                                                       */
 /*         ==> DESCORE ****                                                */
 /*         ==> ERROR ****                                                  */
 /*         ==> FINDER                                                      */
 /*     ==> SRN_UPDATE                                                      */
 /*     ==> STAB_VAR                                                        */
 /*         ==> ERROR ****                                                  */
 /*     ==> STAB_LAB                                                        */
 /*         ==> ERROR ****                                                  */
 /*     ==> STAB_HDR                                                        */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> GET_CELL                                                    */
 /*         ==> LOCATE                                                      */
 /*     ==> HALMAT_OUT                                                      */
 /*         ==> HALMAT_BLAB                                                 */
 /*             ==> HEX                                                     */
 /*             ==> I_FORMAT                                                */
 /*     ==> HALMAT_BACKUP                                                   */
 /*     ==> HALMAT_POP                                                      */
 /*         ==> HALMAT                                                      */
 /*             ==> ERROR ****                                              */
 /*             ==> HALMAT_BLAB ****                                        */
 /*             ==> HALMAT_OUT ****                                         */
 /*     ==> HALMAT_PIP                                                      */
 /*         ==> HALMAT                                                      */
 /*             ==> ERROR ****                                              */
 /*             ==> HALMAT_BLAB ****                                        */
 /*             ==> HALMAT_OUT ****                                         */
 /*     ==> HALMAT_TUPLE                                                    */
 /*         ==> HALMAT_POP ****                                             */
 /*         ==> HALMAT_PIP ****                                             */
 /*     ==> HALMAT_FIX_PIP#                                                 */
 /*     ==> HALMAT_FIX_POPTAG                                               */
 /*     ==> HALMAT_FIX_PIPTAGS                                              */
 /*     ==> EMIT_SMRK                                                       */
 /*         ==> STAB_HDR ****                                               */
 /*         ==> HALMAT_RELOCATE                                             */
 /*         ==> HALMAT_POP ****                                             */
 /*         ==> HALMAT_PIP ****                                             */
 /*     ==> EMIT_PUSH_DO                                                    */
 /*         ==> ERROR ****                                                  */
 /*         ==> HALMAT_PIP ****                                             */
 /*     ==> PUSH_INDIRECT                                                   */
 /*         ==> ERROR ****                                                  */
 /*     ==> LABEL_MATCH                                                     */
 /*     ==> UNBRANCHABLE                                                    */
 /*         ==> ERROR ****                                                  */
 /*     ==> SETUP_VAC                                                       */
 /*     ==> VECTOR_COMPARE                                                  */
 /*         ==> ERROR ****                                                  */
 /*     ==> MATRIX_COMPARE                                                  */
 /*         ==> VECTOR_COMPARE                                              */
 /*             ==> ERROR ****                                              */
 /*     ==> CHECK_ARRAYNESS                                                 */
 /*     ==> UNARRAYED_INTEGER                                               */
 /*         ==> HALMAT_TUPLE                                                */
 /*             ==> HALMAT_POP ****                                         */
 /*             ==> HALMAT_PIP ****                                         */
 /*         ==> SETUP_VAC                                                   */
 /*         ==> CHECK_ARRAYNESS                                             */
 /*     ==> UNARRAYED_SCALAR                                                */
 /*         ==> HALMAT_TUPLE                                                */
 /*             ==> HALMAT_POP ****                                         */
 /*             ==> HALMAT_PIP ****                                         */
 /*         ==> SETUP_VAC                                                   */
 /*         ==> CHECK_ARRAYNESS                                             */
 /*     ==> UNARRAYED_SIMPLE                                                */
 /*         ==> CHECK_ARRAYNESS                                             */
 /*     ==> CHECK_EVENT_EXP                                                 */
 /*         ==> HALMAT_FIX_POPTAG                                           */
 /*         ==> CHECK_ARRAYNESS                                             */
 /*     ==> PROCESS_CHECK                                                   */
 /*         ==> ERROR ****                                                  */
 /*         ==> CHECK_ARRAYNESS                                             */
 /*     ==> CHECK_ASSIGN_CONTEXT                                            */
 /*         ==> ERROR ****                                                  */
 /*         ==> SET_XREF_RORS                                               */
 /*             ==> SET_XREF ****                                           */
 /*         ==> STAB_VAR                                                    */
 /*             ==> ERROR ****                                              */
 /*         ==> HALMAT_FIX_PIPTAGS                                          */
 /*     ==> ERROR_SUB                                                       */
 /*         ==> ERROR ****                                                  */
 /*         ==> MAKE_FIXED_LIT ****                                         */
 /*     ==> MATCH_SIMPLES                                                   */
 /*         ==> HALMAT_TUPLE                                                */
 /*             ==> HALMAT_POP ****                                         */
 /*             ==> HALMAT_PIP ****                                         */
 /*         ==> SETUP_VAC                                                   */
 /*     ==> READ_ALL_TYPE                                                   */
 /*     ==> STRUCTURE_COMPARE                                               */
 /*         ==> ERROR ****                                                  */
 /*     ==> PUSH_FCN_STACK                                                  */
 /*         ==> ERROR ****                                                  */
 /*     ==> ARITH_LITERAL                                                   */
 /*         ==> GET_LITERAL                                                 */
 /*     ==> PREC_SCALE                                                      */
 /*         ==> ERROR ****                                                  */
 /*         ==> MAKE_FIXED_LIT ****                                         */
 /*         ==> FLOATING                                                    */
 /*         ==> SAVE_LITERAL                                                */
 /*         ==> HALMAT_TUPLE                                                */
 /*             ==> HALMAT_POP ****                                         */
 /*             ==> HALMAT_PIP ****                                         */
 /*         ==> SETUP_VAC                                                   */
 /*         ==> ARITH_LITERAL ****                                          */
 /*     ==> BIT_LITERAL                                                     */
 /*         ==> GET_LITERAL                                                 */
 /*     ==> CHAR_LITERAL                                                    */
 /*         ==> GET_LITERAL                                                 */
 /*     ==> MATCH_ARITH                                                     */
 /*         ==> ERROR ****                                                  */
 /*         ==> VECTOR_COMPARE                                              */
 /*             ==> ERROR ****                                              */
 /*         ==> MATRIX_COMPARE ****                                         */
 /*         ==> MATCH_SIMPLES ****                                          */
 /*     ==> LIT_RESULT_TYPE                                                 */
 /*     ==> ADD_AND_SUBTRACT                                                */
 /*         ==> ERROR ****                                                  */
 /*         ==> SAVE_LITERAL                                                */
 /*         ==> HALMAT_TUPLE                                                */
 /*             ==> HALMAT_POP ****                                         */
 /*             ==> HALMAT_PIP ****                                         */
 /*         ==> SETUP_VAC                                                   */
 /*         ==> ARITH_LITERAL ****                                          */
 /*         ==> MATCH_ARITH ****                                            */
 /*         ==> LIT_RESULT_TYPE                                             */
 /*     ==> MULTIPLY_SYNTHESIZE                                             */
 /*         ==> ERROR ****                                                  */
 /*         ==> SAVE_LITERAL                                                */
 /*         ==> HALMAT_TUPLE                                                */
 /*             ==> HALMAT_POP ****                                         */
 /*             ==> HALMAT_PIP ****                                         */
 /*         ==> SETUP_VAC                                                   */
 /*         ==> VECTOR_COMPARE                                              */
 /*             ==> ERROR ****                                              */
 /*         ==> MATCH_SIMPLES ****                                          */
 /*         ==> ARITH_LITERAL ****                                          */
 /*         ==> LIT_RESULT_TYPE                                             */
 /*     ==> IORS                                                            */
 /*         ==> ERROR ****                                                  */
 /*     ==> EMIT_ARRAYNESS                                                  */
 /*         ==> HALMAT_POP ****                                             */
 /*         ==> HALMAT_PIP ****                                             */
 /*     ==> SAVE_ARRAYNESS                                                  */
 /*         ==> ERROR ****                                                  */
 /*     ==> RESET_ARRAYNESS                                                 */
 /*     ==> ARITH_TO_CHAR                                                   */
 /*         ==> ERROR ****                                                  */
 /*         ==> HALMAT_TUPLE                                                */
 /*             ==> HALMAT_POP ****                                         */
 /*             ==> HALMAT_PIP ****                                         */
 /*         ==> SETUP_VAC                                                   */
 /*     ==> NAME_COMPARE                                                    */
 /*         ==> ERROR ****                                                  */
 /*         ==> RESET_ARRAYNESS                                             */
 /*     ==> KILL_NAME                                                       */
 /*         ==> CHECK_ARRAYNESS                                             */
 /*         ==> RESET_ARRAYNESS                                             */
 /*     ==> COPINESS                                                        */
 /*     ==> NAME_ARRAYNESS                                                  */
 /*     ==> CHECK_NAMING                                                    */
 /*         ==> ERROR ****                                                  */
 /*         ==> SET_XREF_RORS                                               */
 /*             ==> SET_XREF ****                                           */
 /*         ==> CHECK_ASSIGN_CONTEXT ****                                   */
 /*     ==> SETUP_NO_ARG_FCN                                                */
 /*         ==> ERROR ****                                                  */
 /*         ==> FLOATING                                                    */
 /*         ==> SAVE_LITERAL                                                */
 /*         ==> SET_BI_XREF ****                                            */
 /*         ==> SET_XREF_RORS                                               */
 /*             ==> SET_XREF ****                                           */
 /*         ==> HALMAT_POP ****                                             */
 /*         ==> HALMAT_TUPLE                                                */
 /*             ==> HALMAT_POP ****                                         */
 /*             ==> HALMAT_PIP ****                                         */
 /*         ==> SETUP_VAC                                                   */
 /*         ==> UPDATE_BLOCK_CHECK                                          */
 /*             ==> ERROR ****                                              */
 /*         ==> PREC_SCALE ****                                             */
 /*         ==> STRUCTURE_FCN                                               */
 /*     ==> START_NORMAL_FCN                                                */
 /*         ==> ERROR ****                                                  */
 /*         ==> SET_BI_XREF ****                                            */
 /*         ==> SET_XREF_RORS                                               */
 /*             ==> SET_XREF ****                                           */
 /*         ==> HALMAT_POP ****                                             */
 /*         ==> HALMAT_PIP ****                                             */
 /*         ==> PUSH_INDIRECT                                               */
 /*             ==> ERROR ****                                              */
 /*         ==> PUSH_FCN_STACK                                              */
 /*             ==> ERROR ****                                              */
 /*         ==> UPDATE_BLOCK_CHECK                                          */
 /*             ==> ERROR ****                                              */
 /*         ==> SAVE_ARRAYNESS                                              */
 /*             ==> ERROR ****                                              */
 /*         ==> STRUCTURE_FCN                                               */
 /*     ==> SETUP_CALL_ARG                                                  */
 /*         ==> ERROR ****                                                  */
 /*         ==> HALMAT_PIP ****                                             */
 /*         ==> HALMAT_TUPLE                                                */
 /*             ==> HALMAT_POP ****                                         */
 /*             ==> HALMAT_PIP ****                                         */
 /*         ==> HALMAT_FIX_PIP#                                             */
 /*         ==> HALMAT_FIX_PIPTAGS                                          */
 /*         ==> VECTOR_COMPARE                                              */
 /*             ==> ERROR ****                                              */
 /*         ==> MATRIX_COMPARE ****                                         */
 /*         ==> CHECK_ARRAYNESS                                             */
 /*         ==> STRUCTURE_COMPARE                                           */
 /*             ==> ERROR ****                                              */
 /*         ==> EMIT_ARRAYNESS                                              */
 /*             ==> HALMAT_POP ****                                         */
 /*             ==> HALMAT_PIP ****                                         */
 /*         ==> SAVE_ARRAYNESS                                              */
 /*             ==> ERROR ****                                              */
 /*         ==> RESET_ARRAYNESS                                             */
 /*         ==> NAME_COMPARE ****                                           */
 /*         ==> KILL_NAME ****                                              */
 /*         ==> NAME_ARRAYNESS                                              */
 /*         ==> GET_FCN_PARM                                                */
 /*     ==> ARITH_SHAPER_SUB                                                */
 /*         ==> ERROR ****                                                  */
 /*         ==> MAKE_FIXED_LIT ****                                         */
 /*     ==> ATTACH_SUBSCRIPT                                                */
 /*         ==> ERROR ****                                                  */
 /*         ==> CHECK_ARRAYNESS                                             */
 /*         ==> RESET_ARRAYNESS                                             */
 /*         ==> GET_ARRAYNESS                                               */
 /*         ==> MATCH_ARRAYNESS                                             */
 /*             ==> ERROR ****                                              */
 /*         ==> ATTACH_SUB_COMPONENT                                        */
 /*             ==> ERROR ****                                              */
 /*             ==> REDUCE_SUBSCRIPT                                        */
 /*                 ==> ERROR ****                                          */
 /*                 ==> CHECK_SUBSCRIPT                                     */
 /*                     ==> ERROR ****                                      */
 /*                     ==> MAKE_FIXED_LIT ****                             */
 /*                     ==> HALMAT_POP ****                                 */
 /*                     ==> HALMAT_PIP ****                                 */
 /*             ==> AST_STACKER                                             */
 /*                 ==> ERROR ****                                          */
 /*                 ==> PUSH_INDIRECT                                       */
 /*                     ==> ERROR ****                                      */
 /*             ==> SLIP_SUBSCRIPT                                          */
 /*         ==> ATTACH_SUB_ARRAY                                            */
 /*             ==> ERROR ****                                              */
 /*             ==> REDUCE_SUBSCRIPT ****                                   */
 /*             ==> AST_STACKER ****                                        */
 /*             ==> SLIP_SUBSCRIPT                                          */
 /*         ==> ATTACH_SUB_STRUCTURE                                        */
 /*             ==> ERROR ****                                              */
 /*             ==> REDUCE_SUBSCRIPT ****                                   */
 /*             ==> AST_STACKER ****                                        */
 /*             ==> SLIP_SUBSCRIPT                                          */
 /*     ==> EMIT_SUBSCRIPT                                                  */
 /*         ==> HALMAT_PIP ****                                             */
 /*     ==> END_ANY_FCN                                                     */
 /*         ==> MAX                                                         */
 /*         ==> ERROR ****                                                  */
 /*         ==> SAVE_LITERAL                                                */
 /*         ==> HALMAT_XNOP                                                 */
 /*         ==> HALMAT_BACKUP                                               */
 /*         ==> HALMAT_POP ****                                             */
 /*         ==> HALMAT_PIP ****                                             */
 /*         ==> HALMAT_TUPLE                                                */
 /*             ==> HALMAT_POP ****                                         */
 /*             ==> HALMAT_PIP ****                                         */
 /*         ==> HALMAT_FIX_PIP#                                             */
 /*         ==> SETUP_VAC                                                   */
 /*         ==> MATCH_SIMPLES ****                                          */
 /*         ==> ARITH_LITERAL ****                                          */
 /*         ==> RESET_ARRAYNESS                                             */
 /*         ==> GET_FCN_PARM                                                */
 /*         ==> REDUCE_SUBSCRIPT ****                                       */
 /*     ==> END_SUBBIT_FCN                                                  */
 /*         ==> ERROR ****                                                  */
 /*         ==> HALMAT_PIP ****                                             */
 /*         ==> HALMAT_TUPLE                                                */
 /*             ==> HALMAT_POP ****                                         */
 /*             ==> HALMAT_PIP ****                                         */
 /*         ==> HALMAT_FIX_PIP#                                             */
 /*         ==> SETUP_VAC                                                   */
 /*         ==> REDUCE_SUBSCRIPT ****                                       */
 /*     ==> GET_ICQ                                                         */
 /*     ==> HALMAT_INIT_CONST                                               */
 /*         ==> ERROR ****                                                  */
 /*         ==> HALMAT_POP ****                                             */
 /*         ==> HALMAT_PIP ****                                             */
 /*         ==> GET_ICQ                                                     */
 /*         ==> ICQ_ARRAYNESS_OUTPUT                                        */
 /*             ==> HALMAT_POP ****                                         */
 /*             ==> HALMAT_PIP ****                                         */
 /*             ==> HALMAT_FIX_PIP#                                         */
 /*         ==> ICQ_CHECK_TYPE                                              */
 /*             ==> ERROR ****                                              */
 /*         ==> ICQ_OUTPUT                                                  */
 /*             ==> HALMAT_POP ****                                         */
 /*             ==> HALMAT_PIP ****                                         */
 /*             ==> HALMAT_FIX_PIPTAGS                                      */
 /*             ==> GET_ICQ                                                 */
 /*             ==> ICQ_CHECK_TYPE                                          */
 /*                 ==> ERROR ****                                          */
 /*         ==> HOW_TO_INIT_ARGS                                            */
 /*             ==> ICQ_TERM#                                               */
 /*             ==> ICQ_ARRAY#                                              */
 /*     ==> CHECK_CONSISTENCY                                               */
 /*         ==> ERROR ****                                                  */
 /*     ==> CHECK_CONFLICTS                                                 */
 /*         ==> ERROR ****                                                  */
 /*         ==> COMPARE                                                     */
 /*             ==> ERROR ****                                              */
 /*         ==> CHECK_CONSISTENCY                                           */
 /*             ==> ERROR ****                                              */
 /*     ==> CHECK_EVENT_CONFLICTS                                           */
 /*         ==> ERROR ****                                                  */
 /*     ==> SET_SYT_ENTRIES                                                 */
 /*         ==> ERROR ****                                                  */
 /*         ==> ENTER_DIMS                                                  */
 /*         ==> HALMAT_INIT_CONST ****                                      */
 /*     ==> CHECK_IMPLICIT_T                                                */
 /*         ==> ERROR ****                                                  */
 /*     ==> CALL_SCAN                                                       */
 /*         ==> HEX                                                         */
 /*         ==> SAVE_DUMP                                                   */
 /*         ==> SCAN                                                        */
 /*             ==> MIN                                                     */
 /*             ==> HEX                                                     */
 /*             ==> ERROR ****                                              */
 /*             ==> FINISH_MACRO_TEXT                                       */
 /*             ==> SAVE_TOKEN                                              */
 /*                 ==> OUTPUT_WRITER ****                                  */
 /*             ==> STREAM                                                  */
 /*                 ==> PAD                                                 */
 /*                 ==> CHAR_INDEX                                          */
 /*                 ==> ERRORS ****                                         */
 /*                 ==> MOVE                                                */
 /*                 ==> MIN                                                 */
 /*                 ==> MAX                                                 */
 /*                 ==> DESCORE ****                                        */
 /*                 ==> HEX                                                 */
 /*                 ==> SAVE_INPUT                                          */
 /*                     ==> PAD                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> PRINT2                                              */
 /*                 ==> OUTPUT_GROUP                                        */
 /*                     ==> PRINT2                                          */
 /*                 ==> ERROR ****                                          */
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
 /*                 ==> OUTPUT_WRITER ****                                  */
 /*                 ==> FINDER                                              */
 /*                 ==> INTERPRET_ACCESS_FILE                               */
 /*                     ==> ERROR ****                                      */
 /*                     ==> HASH                                            */
 /*                     ==> OUTPUT_WRITER ****                              */
 /*                 ==> NEXT_RECORD                                         */
 /*                     ==> DECOMPRESS                                      */
 /*                         ==> BLANK                                       */
 /*                 ==> ORDER_OK                                            */
 /*                     ==> ERROR ****                                      */
 /*             ==> IDENTIFY                                                */
 /*                 ==> ERROR ****                                          */
 /*                 ==> HASH                                                */
 /*                 ==> ENTER                                               */
 /*                 ==> SET_DUPL_FLAG                                       */
 /*                 ==> SET_XREF ****                                       */
 /*                 ==> BUFFER_MACRO_XREF                                   */
 /*             ==> PREP_LITERAL                                            */
 /*                 ==> SAVE_LITERAL                                        */
 /*     ==> STACK_DUMP                                                      */
 /*         ==> SAVE_DUMP                                                   */
 /*     ==> SET_LABEL_TYPE                                                  */
 /*         ==> ERROR ****                                                  */
 /*     ==> ASSOCIATE                                                       */
 /*         ==> ERROR ****                                                  */
 /*         ==> HALMAT_FIX_POPTAG                                           */
 /*         ==> SAVE_ARRAYNESS                                              */
 /*             ==> ERROR ****                                              */
 /*     ==> SET_BLOCK_SRN                                                   */
 /*         ==> LOCATE                                                      */
 /*                                                                         */
 /*                                                                         */
 /*  **** - BRANCH PREVIOUSLY EXPANDED                                      */
 /***************************************************************************/
 /*     REVISION HISTORY :                                                  */
 /*     ------------------                                                  */
 /*     DATE    NAME  REL    DR NUMBER AND TITLE                            */
 /*                                                                         */
 /*     8/24/90 LJK   23V1   103732 REMOTE VARIABLE IN INITIAL GETS ERROR   */
 /*     9/27/90 JCS   23V1   102960 %NAMEADD WITH 3RD ARGUMENT A REMOTE     */
 /*                                 INTEGER GENERATES ERROR MESSAGE         */
 /*    12/21/91 TKK   23V2   11098  DELETE SPILL CODE FROM COMPILER         */
 /*     2/22/91 TKK   23V2   11109  CLEAN UP OF COMPILER                    */
 /*                                 SOURCE CODE                             */
 /*    07/01/91 RSJ   24V0 CR11096F THE REMOTE ATTRIBUTE IS SET FOR ALL     */
 /*                                 #D VARIABLES WHEN DATA_REMOTE IS ON     */
 /*                                                                         */
 /*    12/23/92 PMA    8V0   *      MERGED 7V0 AND 24V0 COMPILERS.          */
 /*                                 * REFERENCE 24V0 CR/DR                  */
 /*    03/10/93 LJK   25V0   105069 STRUCTURE NODE USED WITHOUT             */
 /*                   9V0           STRUCTURE DECLARE                       */
 /*                                                                         */
 /*    05/24/93 RAH   25V0   105709 REPLACE AND STRUCTURE STATEMENTS        */
 /*                    9V0          ADDED TO STATEMENT FILE (FILE6) FOR     */
 /*                                 USE IN PASS3.                           */
 /*                                                                         */
 /*    04/11/94 JAC   26V0   108643 'INCREM' INCORRECTLY LISTED AS          */
 /*                   10V0          'NONHAL' IN SDF LISTING.                */
 /*                                                                         */
 /*    07/13/95 DAS  27V0  CR12416  IMPROVE COMPILER ERROR PROCESSING       */
 /*                  11V0           (MAKE SEVERITY 3&4 ERRORS CAUSE ABORT)  */
 /*                                                                         */
 /*    12/08/94 TEV   27V0/  109021 A3 ERROR NOT EMITTED FOR NON-NAME       */
 /*                   11V0          STRUCTURE NODE                          */
 /*                                                                         */
 /*    11/21/95 BAF/  27V1 DR107302 INCORRECT ERROR MESSAGE FOR NAME        */
 /*              RCK  11V1            INITIALIZATION                        */
 /*                                                                         */
 /*                                                                         */
 /*    12/07/95 BAF/  27V1 DR109024 INVALID NONHAL DECLARATIONS DO NOT      */
 /*             RCK   11V1           GET ERROR MESSAGES                     */
 /*                                                                         */
 /*    01/15/96 RCK   27V1/  107771 EXTRANEOUS EN4 ERROR MESSAGE            */
 /*                   11V1                                                  */
 /*                                                                         */
 /*    12/11/95 TEV   27V1/  107308 EXTRANEOUS DATA_REMOTE ERROR MESSAGE    */
 /*                   11V1                                                  */
 /*                                                                         */
 /*    11/22/95 JMP   27V1/  109031 PASS1 EMITS ILLEGAL AV0/C0 ERRORS       */
 /*                   11V1          FOR STRUCTURES                          */
 /*                                                                         */
 /*    06/10/97 JMP   28V0/  109039 HALMAT IS INCORRECT FOR A SUBSCRIPTED   */
 /*                   12V0          NAME REMOTE                             */
 /*                                                                         */
 /*    12/20/96 SMR   28V0/ CR12713 ENHANCE COMPILER LISTING                */
 /*                   12V0                                                  */
 /*                                                                         */
 /*    11/07/96 TEV   28V0/  109047 NAME REMOTE PARAMETER USE GENERATED BAD */
 /*                   12V0          OBJECT CODE                             */
 /*                                                                         */
 /*    09/19/96 JMP   28V0/  109050 NAME VARIABLE INITIALIZED TO POINT      */
 /*                   12V0          TO ASSIGN PARAMETER                     */
 /*                                                                         */
 /*    08/19/96 SMR   28V0/  108603 ZS1 NOT DOWNGRADED FOR CARD TYPE        */
 /*                   12V0          WCZMTCBCPC                              */
 /*                                                                         */
 /*    08/06/96 SMR   28V0/  109044 DI17 ERROR EMITTED FOR NAME             */
 /*                   12V0          CHARACTER(*) PARAMETERS                 */
 /*                                                                         */
 /*    07/15/96 TMP   28V0/  110231 AV0 ERROR GENERATED FOR ASSIGNMENT      */
 /*                   12V0          TO NAME TASK                            */
 /*                                                                         */
 /*    02/18/98 SMR   29V0/ CR12940 ENHANCE COMPILER LISTING                */
 /*                   14V0                                                  */
 /*                                                                         */
 /*    03/03/98 DCP   29V0/  109052 ARITHMETIC EXPRESSION IN CONSTANT/      */
 /*                   14V0          INITIAL VALUE GETS ERROR                */
 /*                                                                         */
 /*    01/15/98 DCP   29V0/  109083 CONSTANT DOUBLE SCALAR CONVERTED TO     */
 /*                   14V0          CHARACTER AS SINGLE PRECISION           */
 /*                                                                         */
 /*    04/07/98 DAS   29V0/  CR12935 ALLOW REMOTE PASS BY REFERENCE         */
 /*                   14V0           PARAMETERS                             */
 /*                                                                         */
 /*    03/02/98 SMR   29V0/  109057 INCORRECT INDENTION AND EXTRA S-LINE    */
 /*                   14V0          IN LISTING                              */
 /*                                                                         */
 /*    03/05/98 SMR   29V0/  109091 ARRAY INDEX OUT OF RANGE FOR NESTED     */
 /*                   14V0          DO-CASE                                 */
 /*    03/03/98 LJK   29V0/  109076 REPLACE MACRO SPLIT ON TWO LINES        */
 /*                   14V0                                                  */
 /*                                                                         */
 /*    09/30/97 DCP   29V0/  109070 DI3 ERROR INCORRECTLY EMITTED           */
 /*                   14V0                                                  */
 /*                                                                         */
 /*    02/05/00 KHP   30V0/ CR13236 REMOVE UNNECESSARY DENSE ATTRIBUTE      */
 /*                   15V0          MATCHING                                */
 /*                                                                         */
 /*    01/28/00 TKN   30V0/  13211  GENERATE ADVISORY MESSAGES WHEN BIT     */
 /*                   15V0          STRING ASSIGNED TO SHORTER STRING       */
 /*                                                                         */
 /*                                                                         */
 /*    08/04/99 DAS   30V0/ CR13245 RESTRICT #R CAPABILITY WITH             */
 /*                   15V0          SDL OPTION IN HAL/S COMPILER            */
 /*                                                                         */
 /*    12/09/99 DAS   30V0   CR13212 ALLOW NAME REMOTE VARIABLES IN THE     */
 /*                   15V0            RUNTIME STACK                         */
 /*                                                                         */
 /*    05/18/00 JAC   30V0   111342 IF-THEN-ELSE REPLACE MACRO INCORRECTLY  */
 /*                   15V0          PRINTED                                 */
 /*                                                                         */
 /*    09/09/99 JAC   30V0/  111341 DO CASE STATEMENT PRINTED INCORRECTLY   */
 /*                   15V0                                                  */
 /*                                                                         */
 /*    05/03/99 JAC   30V0/  111320 INCORRECTLY PRINTED EXPONENT IN         */
 /*                   15V0          OUTPUT LISTING                          */
 /*                                                                         */
 /*    04/20/99 DCP   30V0/  111329 NESTED IF-THEN STATEMENTS INCORRECTLY   */
 /*                   15V0          PRINTED                                 */
 /*    03/23/99 LJK   30V0/  109096 CROSS REFERENCE INFORMATION WRONG       */
 /*                   15V0                                                  */
 /*                                                                         */
 /*    06/12/01 TKN   31V0/  111376 NO SR3 ERROR GENERATED FOR CHARACTER    */
 /*                   16V0          SHAPING FUNCTION                        */
 /*                                                                         */
 /*    03/28/01 DCP   31V0/  111366 CROSS REFERENCE INFORMATION IS          */
 /*                   16V0          INACCURATE FOR DO GROUP LABEL           */
 /*                                                                         */
 /*    01/23/01 DCP   31V0/ CR13336 DON'T ALLOW ARITHMETIC EXPRESSIONS IN   */
 /*                   16V0          CHARACTER INITIAL CLAUSES               */
 /*                                                                         */
 /*    02/01/01 DCP   31V0/  111367 ABEND OCCURS FOR A                      */
 /*                   16V0          MULTI-DIMENSIONAL ARRAY                 */
 /*                                                                         */
 /*    07/23/01 TKN   31V0/  111356 XREF INCORRECT FOR STRUCTURE TEMPLATE   */
 /*                   16V0          DECLARATION                             */
 /*                   16V0          MULTI-DIMENSIONAL ARRAY                 */
 /*                                                                         */
 /*    01/25/05 JAC   32V0/  120267 BLOCKSUM'S USED VALUE INCORRECT         */
 /*                   17V0                                                  */
 /*                                                                         */
 /*    10/01/03 JAC   32V0/  120223 NO FT101 ERROR FOR LITERAL ARGUMENT     */
 /*                   17V0                                                  */
 /*                                                                         */
 /*    09/20/03 DCP   32V0/  120227 INCORRECT INCLUDE COUNT IN COMPILATION  */
 /*                   17V0          LISTING                                 */
 /*                                                                         */
 /*    07/25/03 DCP   32V0/  120220 MISSING SUBBIT CROSS-REFERENCE          */
 /*                   17V0                                                  */
 /*                                                                         */
 /*    09/10/02 JAC   32V0/ CR13570 CREATE NEW %MACRO TO PERFORM ZEROTH     */
 /*                   17V0          ELEMENT CALCULATIONS                    */
 /*                                                                         */
 /*    01/05/04 JAC   32V0/ CR13813 REMOTE SHOULD BE IGNORED ON NON-NAME    */
 /*                   17V0          INPUT PARAMETER                         */
 /***************************************************************************/
                                                                                01101190
                                                                                01101200
 /*                  THE SYNTHESIS ALGORITHM FOR HAL                       */   01101300
                                                                                01101400
                                                                                01101500
SYNTHESIZE:                                                                     01101600
   PROCEDURE(PRODUCTION_NUMBER);                                                01101700
      DECLARE PRODUCTION_NUMBER FIXED;                                          01101800
      DECLARE INLINE_NAME CHARACTER INITIAL('$FUNCTION');                       01101900
      DECLARE UPDATE_NAME CHARACTER INITIAL('$UPDATE');                         01102000
      DECLARE (H1, H2) BIT(16);                                                 01102100
      DECLARE (PREV_LIVES_REMOTE,PREV_POINTS,PREV_REMOTE) BIT(16);  /*DR109031*/
      DECLARE (NAME_SET,REMOTE_SET,CURRENT_LIVES_REMOTE) BIT(16);   /*DR109031*/
      DECLARE CHANGED_STMT_NUM BIT(1);                               /*CR12713*/
      DECLARE ELSE_TOKEN FIXED INITIAL(48);                         /*DR111342*/
SET_INIT:                                                                       01102200
      PROCEDURE (A,B,C,D,E);                                                    01102300
         DECLARE (A,C,E) BIT(16), (B,D) BIT(8);                                 01102400
         DECLARE Q BIT(16);                                                     01102500
         IC_LINE=IC_LINE+1;                                                     01102600
         IF IC_LINE>NUM_EL_MAX THEN CALL ERROR(CLASS_BT,7); /* CR12416 */       01102700
         Q=GET_ICQ(IC_LINE);                                                    01102800
         IC_VAL(Q)=E;                                                           01102900
         IC_LOC(Q)=A;                                                           01103000
         IC_LEN(Q)=C;                                                           01103100
         IC_FORM(Q)=B;                                                          01103200
         IC_TYPE(Q)=D;                                                          01103300
      END SET_INIT;                                                             01103400

 /*  THIS PROCEDURE IS RESPONSIBLE FOR THE SEMANTICS (CODE SYNTHESIS), IF       01103600
      ANY, OF THE SKELETON COMPILER.  ITS ARGUMENT IS THE NUMBER OF THE         01103700
      PRODUCTION WHICH WILL BE APPLIED IN THE PENDING REDUCTION.  THE GLOBAL    01103800
      VARIABLES MP AND SP POINT TO THE BOUNDS IN THE STACKS OF THE RIGHT PART   01103900
      OF THIS PRODUCTION.                                                     */01104000
                                                                                01104100
      IF CONTROL(8) THEN                                                        01104200
         OUTPUT = '->->->->->->PRODUCTION NUMBER ' || PRODUCTION_NUMBER         01104300
         ;                                                                      01104400
      IF SHR(#PRODUCE_NAME(PRODUCTION_NUMBER),12) THEN                          01104410
         CALL ERROR(CLASS_XS,2,'#'||PRODUCTION_NUMBER);                         01104420

      /*CR12713 - THIS CODE CHECKS TO SEE IF THE PREVIOUS STATEMENT WAS AN */
      /*IF-THEN OR ELSE AND IF THE CURRENT STATEMENT IS NOT A SIMPLE DO.   */
      /*IF TRUE, THE PREVIOUS STATEMENT IS PRINTED AND EXEUCTION CONTINUES.*/
      IF (IF_FLAG | ELSE_FLAG) & (PRODUCTION_NUMBER^=144) THEN DO;/*CR12713*/
         SQUEEZING = FALSE;                                      /*DR111329*/
         CHANGED_STMT_NUM = FALSE;                                /*CR12713*/
         IF IF_FLAG THEN DO;                                      /*CR12713*/
            STMT_NUM = STMT_NUM - 1;                              /*CR12713*/
            CHANGED_STMT_NUM = TRUE;                              /*CR12713*/
         END;                                                     /*CR12713*/
         SAVE_SRN2 = SRN(2);                                      /*CR12713*/
         SRN(2) = SAVE_SRN1;                                      /*CR12713*/
         SAVE_SRN_COUNT2 = SRN_COUNT(2);                         /*DR120227*/
         SRN_COUNT(2) = SAVE_SRN_COUNT1;                         /*DR120227*/
         IF_FLAG,ELSE_FLAG = FALSE;/*MUST BE BEFORE OUTPUTWR CALL  *CR12713*/
         CALL OUTPUT_WRITER(SAVE1,SAVE2);                         /*CR12713*/
         INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;                   /*CR12713*/
         IF CHANGED_STMT_NUM THEN STMT_NUM = STMT_NUM + 1;        /*CR12713*/
         IF STMT_PTR > -1 THEN LAST_WRITE = SAVE2 + 1;            /*CR12713*/
         SRN(2) = SAVE_SRN2;                                      /*CR12713*/
         SRN_COUNT(2) = SAVE_SRN_COUNT2;                         /*DR120227*/
      END;                                                        /*CR12713*/

      /*CR12713 - THIS CODE IS USED TO ALIGN THE ELSE STATEMENTS CORRECTLY.  */
      /*IF THE CURRENT STATEMENT IS NOT AN ELSE OR A DO, MOVE_ELSE=TRUE.  .  */
      IF (PRODUCTION_NUMBER ^= 140) & (PRODUCTION_NUMBER ^= 54) &   /*CR12713*/
         (PRODUCTION_NUMBER ^= 40) THEN                             /*CR12713*/
         MOVE_ELSE = TRUE;                                          /*CR12713*/
      IF (SAVE_DO_LEVEL ^= -1) & (PRODUCTION_NUMBER ^= 167) THEN DO;/*CR12713*/
         IFDO_FLAG(SAVE_DO_LEVEL) = FALSE;                          /*CR12713*/
         SAVE_DO_LEVEL = -1;                                        /*CR12713*/
      END;                                                          /*CR12713*/

      DO CASE PRODUCTION_NUMBER;                                                01104500
                                                                                01104600
         ;                                                                      01104700
                                                                                01104800
 /* <COMPILATION>::= <COMPILE LIST> _|_ */                                      01104900
         DO;                                                                    01105000
            IF MP>0 THEN DO;                                                    01105100
               CALL ERROR(CLASS_P,1);                                           01105200
               CALL STACK_DUMP;                                                 01105300
            END;                                                                01105400
            ELSE IF BLOCK_MODE=0 THEN CALL ERROR(CLASS_PP,4);                   01105500
            CALL HALMAT_POP(XXREC,0,0,1);                                       01105600
            ATOM#_FAULT=-1;                                                     01105700
            CALL HALMAT_OUT;                                                    01105800
            FILE(LITFILE,CURLBLK)=LIT1(0);                                      01105900
            COMPILING="80";                                                     01106000
            STMT_PTR=STMT_PTR-1;                                                01106100
         END;                                                                   01106200
 /* <COMPILE LIST>::=<BLOCK DEFINITION> */                                      01106300
         ;                                                                      01106400
 /* <COMPILE LIST>::= <COMPILE LIST> <BLOCK DEFINITION> */                      01106500
         ;                                                                      01106600
                                                                                01106700
 /*  <ARITH EXP> ::= <TERM>    */                                               01106800
         ;                                                                      01106900
 /*  <ARITH EXP> ::= + <TERM>    */                                             01107000
         DO ;  /* JUST ABSORB '+' SIGN, IE, RESET INDIRECT STACK */             01107100
            PTR(MP) = PTR(SP) ;                                                 01107200
            NOSPACE;                                                            01107300
         END ;                                                                  01107400
 /*  <ARITH EXP> ::= -1 <TERM>    */                                            01107500
         DO ;                                                                   01107600
            IF ARITH_LITERAL(SP,0) THEN DO;                                     01107700
          CALL INLINE("58",1,0,DW_AD);                   /* L   1,DW_AD       */01107800
          CALL INLINE("97",8,0,1,0);                     /* XI  0(1),X'80'    */01107900
               LOC_P(PTR(SP))=SAVE_LITERAL(1,DW_AD);                            01108000
            END;                                                                01108100
            ELSE DO;                                                            01108200
               TEMP=PSEUDO_TYPE(PTR(SP));                                       01108300
               CALL HALMAT_TUPLE(XMNEG(TEMP-MAT_TYPE),0,SP,0,0);                01108400
               CALL SETUP_VAC(SP,TEMP,PSEUDO_LENGTH(PTR(SP)));                  01108500
            END;                                                                01108600
            NOSPACE;                                                            01108700
            PTR(MP)=PTR(SP);                                                    01108800
         END ;                                                                  01108900
 /*  <ARITH EXP> ::= <ARITH EXP> + <TERM>    */                                 01109000
         CALL ADD_AND_SUBTRACT(0);                                              01109100
 /*  <ARITH EXP> ::= <ARITH EXP> -1 <TERM>    */                                01109200
         CALL ADD_AND_SUBTRACT(1);                                              01109300
                                                                                01109400
 /*  <TERM> ::= <PRODUCT>    */                                                 01109500
         ;                                                                      01109600
 /*  <TERM> ::= <PRODUCT> / <TERM>    */                                        01109700
         DO ;                                                                   01109800
            IF ARITH_LITERAL(MP,SP) THEN DO;                                    01109900
               IF MONITOR(9,4) THEN DO;                                         01110000
                  CALL ERROR(CLASS_VA,4);                                       01110100
                  GO TO DIV_FAIL;                                               01110200
               END;                                                             01110300
               LOC_P(PTR(MP))=SAVE_LITERAL(1,DW_AD);                            01110400
               PSEUDO_TYPE(PTR(MP))=SCALAR_TYPE;                                01110500
            END;                                                                01110600
            ELSE DO;                                                            01110700
DIV_FAIL:                                                                       01110800
               IF PSEUDO_TYPE(PTR(SP))<SCALAR_TYPE THEN CALL ERROR(CLASS_E,1);  01110900
               PTR=0;                                                           01111000
               PSEUDO_TYPE=SCALAR_TYPE;                                         01111100
               CALL MATCH_SIMPLES(0,SP);                                        01111200
             IF PSEUDO_TYPE(PTR(MP))^<SCALAR_TYPE THEN CALL MATCH_SIMPLES(0,MP);01111300
               TEMP=PSEUDO_TYPE(PTR(MP));                                       01111400
               CALL HALMAT_TUPLE(XMSDV(TEMP-MAT_TYPE),0,MP,SP,0);               01111500
               CALL SETUP_VAC(MP,TEMP);                                         01111600
            END;                                                                01111700
            PTR_TOP=PTR(MP);                                                    01111800
         END ;                                                                  01111900
 /*  <PRODUCT> ::= <FACTOR>    */                                               01112000
         DO;                                                                    01112100
            CROSS_COUNT,DOT_COUNT,SCALAR_COUNT,VECTOR_COUNT,MATRIX_COUNT = 0;   01112200
            TERMP = SP + 1;                                                     01112300
            DO WHILE TERMP > 0;                                                 01112400
               TERMP = TERMP - 1;                                               01112500
               IF PARSE_STACK(TERMP) = CROSS_TOKEN THEN                         01112600
                  DO;                                                           01112700
                  CROSS_COUNT = CROSS_COUNT + 1;                                01112800
                  FIXV(TERMP) = CROSS;                                          01112900
               END;  ELSE                                                       01113000
                  IF PARSE_STACK(TERMP) = DOT_TOKEN THEN                        01113100
                  DO;                                                           01113200
                  DOT_COUNT = DOT_COUNT + 1;                                    01113300
                  FIXV(TERMP) = DOT;                                            01113400
               END;  ELSE                                                       01113500
                  IF PARSE_STACK(TERMP) = FACTOR THEN                           01113600
                  DO CASE "0F" & PSEUDO_TYPE(PTR(TERMP));                       01113700
                  ;;;  /* 0 IS DUMMY, 1 IS BIT, 2 IS CHAR   */                  01113800
                     DO;                                                        01113900
                     MATRIX_COUNT = MATRIX_COUNT + 1;                           01114000
                     FIXV(TERMP) = MAT_TYPE;                                    01114100
                  END;                                                          01114200
                  DO;                                                           01114300
                     VECTOR_COUNT = VECTOR_COUNT + 1;                           01114400
                     FIXV(TERMP) = VEC_TYPE;                                    01114500
                  END;                                                          01114600
                  DO;                                                           01114700
ALSO_SCALAR:                                                                    01114800
                     SCALAR_COUNT = SCALAR_COUNT + 1;                           01114900
                     FIXV(TERMP) = SCALAR_TYPE;                                 01115000
                  END;                                                          01115100
                  GO TO ALSO_SCALAR;  /* TYPE 6 IS INTEGER  */                  01115200
               END;   ELSE                                                      01115300
                  DO;                                                           01115400
                  MP    = TERMP + 1;  /* IT WAS DECREMENTED AT START OF LOOP  */01115500
                  TERMP = 0;  /* GET OUT OF LOOP  */                            01115600
               END;                                                             01115700
            END;                                                                01115800
            TERMP = MP;                                                         01115900
                                                                                01116000
            IF TERMP = SP THEN RETURN;                                          01116100
                                                                                01116200
 /*  MULTIPLY ALL SCALARS, PLACE RESULT AT SCALARP   */                         01116300
            SCALARP = 0;                                                        01116400
            PP = TERMP - 1;                                                     01116500
            DO WHILE SCALAR_COUNT > 0;                                          01116600
               PP = PP + 1;                                                     01116700
               IF FIXV(PP) = SCALAR_TYPE THEN                                   01116800
                  DO;                                                           01116900
                  SCALAR_COUNT = SCALAR_COUNT - 1;                              01117000
                  IF SCALARP = 0 THEN SCALARP = PP;                             01117100
                  ELSE CALL MULTIPLY_SYNTHESIZE(SCALARP,PP,SCALARP,0);          01117200
               END;                                                             01117300
            END;                                                                01117400
                                                                                01117500
                                                                                01117600
                                                                                01117700
 /* PRODUCTS WITHOUT VECTORS HANDLED HERE  */                                   01117800
            IF VECTOR_COUNT = 0 THEN                                            01117900
               DO;                                                              01118000
               IF CROSS_COUNT + DOT_COUNT > 0 THEN                              01118100
                  DO;                                                           01118200
                  CALL ERROR(CLASS_E,4);                                        01118300
                  PTR_TOP = PTR(MP);                                            01118400
                  RETURN;                                                       01118500
               END;                                                             01118600
               IF MATRIX_COUNT = 0 THEN                                         01118700
                  DO;                                                           01118800
                  PTR_TOP = PTR(MP);                                            01118900
                  RETURN;                                                       01119000
               END;                                                             01119100
 /*  MULTIPLY MATRIX PRODUCTS   */                                              01119200
               MATRIXP = 0;                                                     01119300
               PP = TERMP - 1;                                                  01119400
               DO WHILE MATRIX_COUNT > 0;                                       01119500
                  PP = PP + 1;                                                  01119600
                  IF FIXV(PP) = MAT_TYPE THEN                                   01119700
                     DO;                                                        01119800
                     MATRIX_COUNT = MATRIX_COUNT - 1;                           01119900
                     IF MATRIXP = 0 THEN MATRIXP = PP;                          01120000
                     ELSE CALL MULTIPLY_SYNTHESIZE(MATRIXP,PP,MATRIXP,8);       01120100
                  END;                                                          01120200
               END;                                                             01120300
         IF SCALARP ^= 0 THEN CALL MULTIPLY_SYNTHESIZE(MATRIXP,SCALARP,TERMP,2);01120400
               PTR_TOP = PTR(MP);                                               01120500
               RETURN;                                                          01120600
            END;                                                                01120700
                                                                                01120800
                                                                                01120900
                                                                                01121000
 /* PRODUCTS WITH VECTORS TAKE UP THE REST OF THIS REDUCTION  */                01121100
                                                                                01121200
 /*  FIRST MATRICES ARE PULLED INTO VECTORS    */                               01121300
            IF MATRIX_COUNT = 0 THEN GO TO MATRICES_TAKEN_CARE_OF;              01121400
            BEGINP = TERMP;                                                     01121500
MATRICES_MAY_GO_RIGHT:                                                          01121600
            MATRIX_PASSED = 0;                                                  01121700
            DO PP = BEGINP TO SP;                                               01121800
             IF FIXV(PP) = MAT_TYPE THEN MATRIX_PASSED = MATRIX_PASSED + 1; ELSE01121900
               IF FIXV(PP) = DOT | FIXV(PP) = CROSS THEN MATRIX_PASSED = 0; ELSE01122000
 /*  THIS ILLEGAL SYNTAX WILL BE CAUGHT ELSEWHERE  */                           01122100
                  IF FIXV(PP) = VEC_TYPE THEN                                   01122200
                  DO;                                                           01122300
                  PPTEMP = PP;                                                  01122400
                  DO WHILE MATRIX_PASSED > 0;                                   01122500
                     PPTEMP = PPTEMP - 1;                                       01122600
                     IF FIXV(PPTEMP) = MAT_TYPE THEN                            01122700
                        DO;                                                     01122800
                        MATRIX_PASSED = MATRIX_PASSED - 1;                      01122900
                        CALL MULTIPLY_SYNTHESIZE(PPTEMP,PP,PP,7);               01123000
                     END;                                                       01123100
                  END;                                                          01123200
                  DO PPTEMP = PP + 1 TO SP;                                     01123300
                     IF FIXV(PPTEMP) = MAT_TYPE THEN                            01123400
                        CALL MULTIPLY_SYNTHESIZE(PP,PPTEMP,PP,6); ELSE          01123500
                        IF FIXV(PPTEMP) = VEC_TYPE THEN PP = PPTEMP;  ELSE      01123600
                        IF FIXV(PPTEMP) = DOT | FIXV(PPTEMP) = CROSS THEN       01123700
                        DO;                                                     01123800
                        BEGINP = PPTEMP + 1;                                    01123900
                        GO TO MATRICES_MAY_GO_RIGHT;                            01124000
                     END;                                                       01124100
                  END;                                                          01124200
               END;                                                             01124300
            END;                                                                01124400
                                                                                01124500
MATRICES_TAKEN_CARE_OF:                                                         01124600
 /* PRODUCTS WITHOUT DOT OR CROSS COME NEXT   */                                01124700
            IF (DOT_COUNT + CROSS_COUNT) > 0 THEN GO TO CROSS_PRODUCTS;         01124800
            IF VECTOR_COUNT > 2 THEN                                            01124900
               DO;                                                              01125000
               CALL ERROR(CLASS_EO,1);                                          01125100
               PTR_TOP = PTR(MP);                                               01125200
               RETURN;                                                          01125300
            END;                                                                01125400
            DO PP = MP TO SP;                                                   01125500
               IF FIXV(PP) = VEC_TYPE THEN                                      01125600
                  DO;                                                           01125700
                  VECTORP = PP;                                                 01125800
                  PP= SP + 1;                                                   01125900
               END;                                                             01126000
            END;                                                                01126100
COMBINE_SCALARS_AND_VECTORS:                                                    01126200
            IF SCALARP ^= 0 THEN                                                01126300
               CALL MULTIPLY_SYNTHESIZE(VECTORP,SCALARP,TERMP,1);  ELSE         01126400
               IF VECTORP ^= MP THEN                                            01126500
               DO;                                                              01126600
 /*   THIS BLOCK OF CODE PUTS THE INDIRECT STACK INFORMATION FOR THE  */        01126700
 /*   ENTIRE PRODUCT IN THE FIRST OF THE INDIRECT STACK ENTRIES ALOTTED */      01126800
 /*   TO THE ENTIRE PRODUCT, IN CASE THE FINAL MULTIPLY DOESN'T DO SO */        01126900
               PTR_TOP = PTR(MP);                                               01127000
               INX(PTR_TOP) = INX(PTR(VECTORP));                                01127100
               LOC_P(PTR_TOP) = LOC_P(PTR(VECTORP));                            01127200
               VAL_P(PTR_TOP) = VAL_P(PTR(VECTORP));                            01127300
               PSEUDO_TYPE(PTR_TOP) = PSEUDO_TYPE(PTR(VECTORP));                01127400
               PSEUDO_FORM(PTR_TOP) = PSEUDO_FORM(PTR(VECTORP));                01127500
               PSEUDO_LENGTH(PTR_TOP) = PSEUDO_LENGTH(PTR(VECTORP));            01127600
            END;                                                                01127700
            IF VECTOR_COUNT = 1 THEN                                            01127800
               DO;                                                              01127900
               PTR_TOP = PTR(MP);                                               01128000
               RETURN;                                                          01128100
            END;                                                                01128200
 /*  VECTOR_COUNT SHOULD BE 2 HERE */                                           01128300
            DO PP = VECTORP + 1 TO SP;                                          01128400
               IF FIXV(PP) = VEC_TYPE THEN                                      01128500
                  DO;                                                           01128600
                  CALL MULTIPLY_SYNTHESIZE(TERMP,PP,TERMP,5);                   01128700
                  PTR_TOP = PTR(MP);                                            01128800
                  RETURN;                                                       01128900
               END;                                                             01129000
            END;                                                                01129100
                                                                                01129200
CROSS_PRODUCTS:                                                                 01129300
            DO WHILE CROSS_COUNT > 0;                                           01129400
               VECTORP = 0;                                                     01129500
               DO PP = MP TO SP;                                                01129600
                  IF FIXV(PP) = VEC_TYPE THEN VECTORP = PP; ELSE                01129700
                     IF FIXV(PP) = DOT THEN VECTORP = 0; ELSE                   01129800
                     IF FIXV(PP) = CROSS THEN                                   01129900
                     DO;                                                        01130000
                     IF VECTORP = 0 THEN                                        01130100
                        DO;                                                     01130200
                        CALL ERROR(CLASS_EC,3);                                 01130300
                        PTR_TOP = PTR(MP);                                      01130400
                        RETURN;                                                 01130500
                     END; ELSE                                                  01130600
                        DO PPTEMP = PP + 1 TO SP;                               01130700
                        IF FIXV(PPTEMP) = VEC_TYPE THEN                         01130800
                           DO;                                                  01130900
                           CALL MULTIPLY_SYNTHESIZE(VECTORP,PPTEMP,VECTORP,4);  01131000
                           FIXV(PP) = 0;                                        01131100
                           CROSS_COUNT = CROSS_COUNT - 1;                       01131200
                           FIXV(PPTEMP) = 0;                                    01131300
                           VECTOR_COUNT = VECTOR_COUNT - 1;                     01131400
                           GO TO CROSS_PRODUCTS;                                01131500
                        END;                                                    01131600
                     END;                                                       01131700
                     CALL ERROR(CLASS_EC,2);                                    01131800
                     PTR_TOP = PTR(MP);                                         01131900
                     RETURN;                                                    01132000
                  END;                                                          01132100
               END;                                                             01132200
            END;                                                                01132300
                                                                                01132400
                                                                                01132500
            IF DOT_COUNT > 0 THEN GO TO DOT_PRODUCTS;                           01132600
            IF VECTOR_COUNT > 1 THEN                                            01132700
               DO;                                                              01132800
               CALL ERROR(CLASS_EO,2);                                          01132900
               PTR_TOP = PTR(MP);                                               01133000
               RETURN;                                                          01133100
            END;                                                                01133200
 /* IF YOU GET TO THIS GOTO, VECTOR_COUNT HAD BETTER BE 1  */                   01133300
            GO TO COMBINE_SCALARS_AND_VECTORS;                                  01133400
                                                                                01133500
                                                                                01133600
DOT_PRODUCTS:                                                                   01133700
            BEGINP = TERMP;                                                     01133800
DOT_PRODUCTS_LOOP:                                                              01133900
            DO WHILE DOT_COUNT > 0;                                             01134000
               VECTORP = 0;                                                     01134100
               DO PP = BEGINP TO SP;                                            01134200
                  IF FIXV(PP) = VEC_TYPE THEN VECTORP = PP;                     01134300
                  IF FIXV(PP) = DOT THEN                                        01134400
                     DO;                                                        01134500
                     IF VECTORP = 0 THEN                                        01134600
                        DO;                                                     01134700
                        CALL ERROR(CLASS_ED,2);                                 01134800
                        PTR_TOP = PTR(MP);                                      01134900
                        RETURN;                                                 01135000
                     END;  ELSE                                                 01135100
                        DO PPTEMP = PP + 1 TO SP;                               01135200
                        IF FIXV(PPTEMP) = VEC_TYPE THEN                         01135300
                           DO;                                                  01135400
                           CALL MULTIPLY_SYNTHESIZE(VECTORP,PPTEMP,VECTORP,3);  01135500
                           IF SCALARP = 0 THEN SCALARP = VECTORP; ELSE          01135600
                            CALL MULTIPLY_SYNTHESIZE(SCALARP,VECTORP,SCALARP,0);01135700
                           BEGINP = PPTEMP + 1;                                 01135800
                           DOT_COUNT = DOT_COUNT - 1;                           01135900
                           FIXV(VECTORP) = 0;                                   01136000
                           FIXV(PPTEMP) = 0;                                    01136100
                           VECTOR_COUNT = VECTOR_COUNT - 2;                     01136200
                           GO TO DOT_PRODUCTS_LOOP;                             01136300
                        END;                                                    01136400
                     END;                                                       01136500
                     CALL ERROR(CLASS_ED,1);                                    01136600
                     PTR_TOP = PTR(MP);                                         01136700
                     RETURN;                                                    01136800
                  END;                                                          01136900
               END;                                                             01137000
            END;                                                                01137100
            IF VECTOR_COUNT>0 THEN                                              01137200
               DO;                                                              01137300
               CALL ERROR(CLASS_EO,3);                                          01137400
               PTR_TOP = PTR(MP);                                               01137500
               RETURN;                                                          01137600
            END;                                                                01137700
 /* VECTOR_COUNT MUST BE 0 HERE   */                                            01137800
            IF SCALARP = MP THEN                                                01137900
               DO;                                                              01138000
               PTR_TOP = PTR(MP);                                               01138100
               RETURN;                                                          01138200
            END;                                                                01138300
 /*   KLUDGE TO USE CODE IN ANOTHER SECTION OF THIS CASE   */                   01138400
            VECTORP = SCALARP;                                                  01138500
            VECTOR_COUNT = 1;                                                   01138600
            SCALARP = 0;                                                        01138700
            GO TO COMBINE_SCALARS_AND_VECTORS;                                  01138800
                                                                                01138900
         END;                                                                   01139000
 /*  <PRODUCT> ::= <FACTOR> * <PRODUCT>    */                                   01139100
 /*  <PRODUCT> ::= <FACTOR> . <PRODUCT>    */                                   01139200
 /*  <PRODUCT> ::= <FACTOR> <PRODUCT>    */                                     01139300
         ; ; ;                                                                  01139400
                                                                                01139500
 /* <FACTOR> ::= <PRIMARY> */                                                   01139600
            IF PARSE_STACK(MP-1)^=EXPONENT THEN IF FIXF(MP)>0 THEN              01139700
            CALL SET_XREF_RORS(MP);                                             01139800
 /*  <FACTOR>  ::=  <PRIMARY>  <**>  <FACTOR>  */                               01139900
         DO;                                                                    01140000
            I=PTR(SP);                                                          01140100
            IF FIXF(MP)>0 THEN CALL SET_XREF_RORS(MP);                          01140200
            EXPONENT_LEVEL=EXPONENT_LEVEL-1;                                    01140300
            TEMP=PSEUDO_TYPE(PTR(MP));                                          01140400
            DO CASE TEMP-MAT_TYPE;                                              01140500
 /*  MATRIX  */                                                                 01140600
               DO;                                                              01140700
                  TEMP2=PSEUDO_LENGTH(PTR(MP));                                 01140800
                  IF (PSEUDO_FORM(I)=XSYT)|(PSEUDO_FORM(I)=XXPT) THEN DO;       01140900
                     IF VAR(SP)='T' THEN DO;                                    01141000
                        CALL HALMAT_TUPLE(XMTRA,0,MP,0,0);                      01141100
                        CALL SETUP_VAC(MP,TEMP,SHL(TEMP2,8)|SHR(TEMP2,8));      01141200
                        IF IMPLICIT_T THEN DO;                                  01141300
                           SYT_FLAGS(LOC_P(I))=SYT_FLAGS(LOC_P(I))|IMPL_T_FLAG; 01141400
                           IMPLICIT_T=FALSE;                                    01141500
                        END;                                                    01141600
                        GO TO T_FOUND;                                          01141700
                     END;                                                       01141800
                  END;                                                          01141900
                  IF PSEUDO_TYPE(I)^=INT_TYPE|PSEUDO_FORM(I)^=XLIT THEN         01142000
                     CALL ERROR(CLASS_E,2);                                     01142100
                  IF (TEMP2&"FF")^=SHR(TEMP2,8) THEN CALL ERROR(CLASS_EM,4);    01142200
                  CALL HALMAT_TUPLE(XMINV,0,MP,SP,0);                           01142300
                  CALL SETUP_VAC(MP,TEMP);                                      01142400
               END;                                                             01142500
 /*  VECTOR  */                                                                 01142600
               DO;                                                              01142700
                  CALL ERROR(CLASS_EV,4);                                       01142800
                  TEMP2=XSEXP;                                                  01142900
                  GO TO FINISH_EXP;                                             01143000
               END;                                                             01143100
 /*  SCALAR  */                                                                 01143200
SIMPLE_EXP:                                                                     01143300
               IF ARITH_LITERAL(MP,SP,TRUE) THEN DO;               /*DR109083*/ 01143400
                  IF MONITOR(9,5) THEN DO;                                      01143500
                     CALL ERROR(CLASS_VA,5);                                    01143600
                     GO TO POWER_FAIL;                                          01143700
                  END;                                                          01143800
                  LOC_P(PTR(MP))=SAVE_LITERAL(1,DW_AD);                         01143900
                  TEMP=LIT_RESULT_TYPE(MP,SP);                                  01144000
                  IF TEMP=INT_TYPE THEN IF MAKE_FIXED_LIT(LOC_P(I))<0 THEN      01144100
                     TEMP=SCALAR_TYPE;                                          01144200
                  PSEUDO_TYPE(PTR(MP))=TEMP;                                    01144300
               END;                                                             01144400
               ELSE DO;                                                         01144500
POWER_FAIL:                                                                     01144600
                  TEMP2=XSPEX(TEMP-SCALAR_TYPE);                                01144700
                  IF PSEUDO_TYPE(I)<SCALAR_TYPE THEN CALL ERROR(CLASS_E,3);     01144800
                  IF PSEUDO_TYPE(I)^=INT_TYPE THEN DO;                          01144900
                     TEMP2=XSEXP;                                               01145000
REGULAR_EXP:                                                                    01145100
                     PTR=0;                                                     01145200
                     PSEUDO_TYPE=SCALAR_TYPE;                                   01145300
                     CALL MATCH_SIMPLES(MP,0);                                  01145400
                  END;                                                          01145500
                  ELSE IF PSEUDO_FORM(I)^=XLIT THEN DO;                         01145600
                     TEMP2=XSIEX;                                               01145700
                     GO TO REGULAR_EXP;                                         01145800
                  END;                                                          01145900
                  ELSE DO;                                                      01146000
                     TEMP=MAKE_FIXED_LIT(LOC_P(I));                             01146100
                     IF TEMP<0 THEN DO;                                         01146200
                        TEMP2=XSIEX;                                            01146300
                        GO TO REGULAR_EXP;                                      01146400
                     END;                                                       01146500
                  END;                                                          01146600
FINISH_EXP:                                                                     01146700
                  CALL HALMAT_TUPLE(TEMP2,0,MP,SP,0);                           01146800
                  CALL SETUP_VAC(MP,PSEUDO_TYPE(PTR(MP)));                      01146900
               END;                                                             01147000
 /*  INTEGER  */                                                                01147100
               GO TO SIMPLE_EXP;                                                01147200
            END;                                                                01147300
            IF FIXF(SP)>0 THEN CALL SET_XREF_RORS(SP);                          01147400
T_FOUND:                                                                        01147500
            PTR_TOP=PTR(MP);                                                    01147600
         END;                                                                   01147700
 /*  <**>  ::=  **  */                                                          01147800
         EXPONENT_LEVEL=EXPONENT_LEVEL+1;                                       01147900
 /*  <PRE PRIMARY>  ::=  (  <ARITH EXP>  )  */                                  01148000
         DO;                                                                    01148100
            VAR(MP)=VAR(MPP1);                                                  01148200
            PTR(MP)=PTR(MPP1);                                                  01148300
         END;                                                                   01148400
 /*  <PRE PRIMARY> ::= <NUMBER>    */                                           01148500
         DO ;                                                                   01148600
            TEMP=INT_TYPE;                                                      01148700
ARITH_LITS:                                                                     01148800
            PTR(MP)=PUSH_INDIRECT(1);                                           01148900
            LOC_P(PTR(MP))=FIXL(MP);                                            01149000
            PSEUDO_FORM(PTR(MP)) = XLIT ;                                       01149100
            PSEUDO_TYPE(PTR(MP))=TEMP;                                          01149200
         END ;                                                                  01149300
 /*  <PRE PRIMARY> ::= <COMPOUND NUMBER>    */                                  01149400
         DO ;                                                                   01149500
            TEMP=SCALAR_TYPE;                                                   01149600
            GO TO ARITH_LITS;                                                   01149700
         END ;                                                                  01149800
                                                                                01149900
 /*  <ARITH FUNC HEAD>  ::=  <ARITH FUNC>  */                                   01150000
         CALL START_NORMAL_FCN;                                                 01150100
 /*  <ARITH FUNC HEAD>  ::=  <ARITH CONV> <SUBSCRIPT>  */                       01150200
         DO;                                                                    01150300
            NOSPACE;                                                            01150400
            TEMP,NEXT_SUB=PTR(SP);                                              01150500
            PTR_TOP,PTR(MP)=TEMP;                                               01150600
            IF INX(TEMP)=0 THEN GO TO DEFAULT_SHAPER;                           01150700
       IF (PSEUDO_LENGTH(TEMP)>=0)|(VAL_P(TEMP)>=0) THEN CALL ERROR(CLASS_QS,1);01150800
            DO CASE FIXL(MP);                                                   01150900
 /*  MATRIX  */                                                                 01151000
               IF INX(TEMP)^=2 THEN DO;                                         01151100
                  CALL ERROR(CLASS_QS,2);                                       01151200
                  GO TO DEFAULT_SHAPER;                                         01151300
               END;                                                             01151400
               ELSE DO;                                                         01151500
                  TEMP_SYN=ARITH_SHAPER_SUB(MAT_DIM_LIM);                       01151600
                  TEMP1=ARITH_SHAPER_SUB(MAT_DIM_LIM);                          01151700
                  PSEUDO_LENGTH(TEMP)=SHL(TEMP_SYN,8)|TEMP1;                    01151800
                  INX(TEMP)=TEMP_SYN*TEMP1;                                     01151900
               END;                                                             01152000
 /*  VECTOR  */                                                                 01152100
               IF INX(TEMP)^=1 THEN DO;                                         01152200
                  CALL ERROR(CLASS_QS,3);                                       01152300
                  GO TO DEFAULT_SHAPER;                                         01152400
               END;                                                             01152500
               ELSE DO;                                                         01152600
                  TEMP_SYN=ARITH_SHAPER_SUB(VEC_LENGTH_LIM);                    01152700
                  PSEUDO_LENGTH(TEMP),INX(TEMP)=TEMP_SYN;                       01152800
               END;                                                             01152900
 /*  SCALAR  */                                                                 01153000
SCALAR_SHAPER:                                                                  01153100
               IF (INX(TEMP)<1)|(INX(TEMP)>N_DIM_LIM) THEN DO;                  01153200
                  CALL ERROR(CLASS_QS,4);                                       01153300
                  GO TO DEFAULT_SHAPER;                                         01153400
               END;                                                             01153500
               ELSE DO;                                                         01153600
                  TEMP_SYN=1;                                                   01153700
                  DO TEMP1=1 TO INX(TEMP);                                      01153800
                     PTR_TOP=PTR_TOP+1; /* OLD STACKS BEING REINSTATED */       01153900
                     LOC_P(PTR_TOP)=ARITH_SHAPER_SUB(ARRAY_DIM_LIM);            01154000
                     TEMP_SYN=LOC_P(PTR_TOP)*TEMP_SYN;                          01154100
                  END;                                                          01154200
               /* IF THE TOTAL NUMBER OF ELEMENTS BEING CREATED   /*DR111367*/
               /* WITH A SHAPING FUNCTION IS GREATER THAN 32767   /*DR111367*/
               /* OR LESS THAN 1 THEN GENERATE A QS8 ERROR        /*DR111367*/
                  IF (TEMP_SYN > ARRAY_DIM_LIM) | (TEMP_SYN < 1) THEN /* "" */
                     CALL ERROR(CLASS_QS, 8);                     /*DR111367*/
                  PSEUDO_LENGTH(TEMP)=TEMP_SYN;                                 01154300
               END;                                                             01154400
 /*  INTEGER  */                                                                01154500
               GO TO SCALAR_SHAPER;                                             01154600
            END;                                                                01154700
            GO TO SET_ARITH_SHAPERS;                                            01154800
DEFAULT_SHAPER:                                                                 01154900
            DO CASE FIXL(MP);                                                   01155000
 /*  MATRIX  */                                                                 01155100
               DO;                                                              01155200
                  PSEUDO_LENGTH(PTR_TOP)=DEF_MAT_LENGTH;                        01155300
                  TEMP=DEF_MAT_LENGTH&"FF";                                     01155400
                  INX(PTR_TOP)=TEMP*TEMP;                                       01155500
               END;                                                             01155600
 /*  VECTOR  */                                                                 01155700
               PSEUDO_LENGTH(PTR_TOP),INX(PTR_TOP)=DEF_VEC_LENGTH;              01155800
 /*  SCALAR  */                                                                 01155900
               INX(PTR_TOP)=0;                                                  01156000
 /*  INTEGER  */                                                                01156100
               INX(PTR_TOP)=0;                                                  01156200
            END;                                                                01156300
SET_ARITH_SHAPERS:                                                              01156400
            PSEUDO_TYPE(PTR(MP))=FIXL(MP)+MAT_TYPE;                             01156500
            IF PUSH_FCN_STACK(2) THEN DO;                                       01156600
               FCN_LOC(FCN_LV)=FIXL(MP);                                        01156700
               CALL SAVE_ARRAYNESS;                                             01156800
               CALL HALMAT_POP(XSFST,0,XCO_N,FCN_LV);                           01156900
               VAL_P(PTR_TOP)=LAST_POP#;                                        01157000
            END;                                                                01157100
         END;                                                                   01157200
 /*  <ARITH CONV>  ::=  INTEGER  */                                             01157300
         DO;                                                                    01157400
            FIXL(MP) = 3;                                                       01157410
            CALL SET_BI_XREF(INT_NDX);                                          01157420
         END;                                                                   01157430
 /*  <ARITH CONV>  ::=  SCALAR  */                                              01157500
         DO;                                                                    01157600
            FIXL(MP) = 2;                                                       01157610
            CALL SET_BI_XREF(SCLR_NDX);                                         01157620
         END;                                                                   01157630
 /*  <ARITH CONV>  ::=  VECTOR  */                                              01157700
         DO;                                                                    01157800
            FIXL(MP) = 1;                                                       01157810
            CALL SET_BI_XREF(VEC_NDX);                                          01157820
         END;                                                                   01157830
 /*  <ARITH CONV>  ::=  MATRIX  */                                              01157900
         DO;                                                                    01158000
            FIXL(MP) = 0;                                                       01158010
            CALL SET_BI_XREF(MTX_NDX);                                          01158020
         END;                                                                   01158030
 /*  <PRIMARY> ::= <ARITH VAR>    */                                            01158100
         ;                                                                      01158200
 /* <PRE PRIMARY>  ::=  <ARITH FUNC HEAD> ( <CALL LIST> )  */                   01158300
         CALL END_ANY_FCN;                                                      01158400
 /*  <PRIMARY>  ::=  <MODIFIED ARITH FUNC>  */                                  01158500
         CALL SETUP_NO_ARG_FCN(TEMP_SYN);                                       01158600
 /*  <PRIMARY>  ::=  <ARITH INLINE DEF>  <BLOCK BODY>  <CLOSING>  ;  */         01158700
         DO;                                                                    01158800
INLINE_SCOPE:                                                                   01158900
            TEMP2=INLINE_LEVEL;                                                 01159000
            TEMP=XICLS;                                                         01159100
          GRAMMAR_FLAGS(STACK_PTR(SP))=GRAMMAR_FLAGS(STACK_PTR(SP))|INLINE_FLAG;01159200
            GO TO CLOSE_SCOPE;                                                  01159300
         END;                                                                   01159400
 /*  <PRIMARY> ::= <PRE PRIMARY>    */                                          01159500
         FIXF(MP)=0;                                                            01159600
 /*  <PRIMARY> ::= <PRE PRIMARY> <QUALIFIER>    */                              01159700
         DO ;                                                                   01159800
            CALL PREC_SCALE(SP,PSEUDO_TYPE(PTR(MP)));                           01159900
            PTR_TOP=PTR(MP);                                                    01160200
            FIXF(MP)=0;                                                         01160300
         END ;                                                                  01160400
                                                                                01160500
 /*  <OTHER STATEMENT>  ::=  <ON PHRASE> <STATEMENT> */                         01160600
         DO;                                                                    01160700
            CALL HALMAT_POP(XLBL,1,XCO_N,0);                                    01160800
            CALL HALMAT_PIP(FIXL(MP),XINL,0,0);                                 01160900
            INDENT_LEVEL=INDENT_LEVEL-INDENT_INCR;                              01161000
            CALL UNBRANCHABLE(SP,7);                                            01161100
            FIXF(MP)=0;                                                         01161200
         END;                                                                   01161300
 /*  <OTHER STATEMENT> ::= <IF STATEMENT>  */                                   01161400
         FIXF(MP)=0;                                                            01161500
 /*  <OTHER STATEMENT>  ::= <LABEL DEFINITION> <OTHER STATEMENT>  */            01161600
         DO;                                                                    01161700
LABEL_INCORP:                                                                   01161800
            IF FIXL(MP)^=FIXF(SP) THEN SYT_PTR(FIXL(MP)) = FIXF(SP);            01161900
            FIXF(MP)=FIXL(MP);                                                  01162000
            PTR(MP)=PTR(MPP1);                                                  01162100
            CALL SET_LABEL_TYPE(FIXL(MP),STMT_LABEL);                           01162200
         END;                                                                   01162300
 /*  <STATEMENT> ::= <BASIC STATEMENT>  */                                      01162400
         DO;                                                                    01162500
            CALL CHECK_IMPLICIT_T;                                              01162600
            CALL OUTPUT_WRITER(LAST_WRITE, STMT_END_PTR);                       01162700
            /*ONLY SET LAST_WRITE TO 0 WHEN STATEMENT STACK*/
            /*COMPLETELY PRINTED.                          */
            IF STMT_END_PTR > -1 THEN    /*DR111342,CR12940*/
               LAST_WRITE = STMT_END_PTR + 1;     /*CR12940*/
            ELSE LAST_WRITE = 0;                  /*CR12940*/
            CALL EMIT_SMRK;                                                     01162900
         END;                                                                   01163000
 /*  <STATEMENT>  ::=  <OTHER STATEMENT>  */                                    01163100
         ;                                                                      01163200
 /*  <ANY STATEMENT>  ::= <STATEMENT>  */                                       01163300
         PTR(MP)=1;                                                             01163400
 /* <ANY STATEMENT>::= <BLOCK DEFINITION> */                                    01163500
         PTR(MP)=BLOCK_MODE(NEST+1)=UPDATE_MODE; /* WHAT BLOCK WAS  */          01163600
 /*  <BASIC STATEMENT>  ::= <LABEL DEFINITION> <BASIC STATEMENT>  */            01163700
         GO TO LABEL_INCORP;                                                    01163800
 /* <BASIC STATEMENT>::=<ASSIGNMENT> */                                         01163900
         DO;                                                                    01164000
            XSET"4";                                                            01164100
            PTR_TOP=PTR_TOP-INX(PTR(MP));                                       01164200
            IF NAME_PSEUDOS THEN CALL NAME_ARRAYNESS(MP);                       01164300
            CALL HALMAT_FIX_PIP#(LAST_POP#,INX(PTR(MP)));                       01164400
            CALL EMIT_ARRAYNESS;                                                01164500
            GO TO FIX_NOLAB;                                                    01164600
         END;                                                                   01164700
                                                                                01164800
 /* <BASIC STATEMENT>::= EXIT ; */                                              01164900
         DO;                                                                    01165000
EXITTING:                                                                       01165100
            TEMP=DO_LEVEL;                                                      01165200
            DO WHILE TEMP>1;                                                    01165300
               IF SHR(DO_INX(TEMP),7) THEN CALL ERROR(CLASS_GE,3);              01165400
               IF LABEL_MATCH THEN DO;                                          01165500
                  CALL HALMAT_POP(XBRA,1,0,0);                                  01165600
                  CALL HALMAT_PIP(DO_LOC(TEMP),XINL,0,0);                       01165700
                  TEMP=1;                                                       01165800
               END;                                                             01165900
               TEMP=TEMP-1;                                                     01166000
            END;                                                                01166100
            IF TEMP=1 THEN CALL ERROR(CLASS_GE,1);                              01166200
            XSET"1";                                                            01166300
            GO TO FIX_NOLAB;                                                    01166400
         END;                                                                   01166500
 /*  <BASIC STATEMENT>  ::=  EXIT  <LABEL>  ;  */                               01166600
         DO;                                                                    01166700
            CALL SET_XREF(FIXL(MPP1),XREF_REF);                                 01166800
            GO TO EXITTING;                                                     01166900
         END;                                                                   01167000
 /* <BASIC STATEMENT>::= REPEAT ; */                                            01167100
         DO;                                                                    01167200
REPEATING:                                                                      01167300
            TEMP=DO_LEVEL;                                                      01167400
            DO WHILE TEMP>1;                                                    01167500
               IF SHR(DO_INX(TEMP),7) THEN CALL ERROR(CLASS_GE,4);              01167600
               IF DO_INX(TEMP) THEN IF LABEL_MATCH THEN DO;                     01167700
                  CALL HALMAT_POP(XBRA,1,0,0);                                  01167800
                  CALL HALMAT_PIP(DO_LOC(TEMP)+1,XINL,0,0);                     01167900
                  TEMP=1;                                                       01168000
               END;                                                             01168100
               TEMP=TEMP-1;                                                     01168200
            END;                                                                01168300
            IF TEMP=1 THEN CALL ERROR(CLASS_GE,2);                              01168400
            XSET "801";                                                         01168500
            GO TO FIX_NOLAB;                                                    01168600
         END;                                                                   01168700
 /*  <BASIC STATEMENT>  ::=  REPEAT  <LABEL>  ;  */                             01168800
         DO;                                                                    01168900
            CALL SET_XREF(FIXL(MPP1),XREF_REF);                                 01169000
            GO TO REPEATING;                                                    01169100
         END;                                                                   01169200
 /*  <BASIC STATEMENT>  ::=  GO TO  <LABEL>  ;  */                              01169300
         DO;                                                                    01169400
            I=FIXL(MP+2);                                                       01169500
            CALL  SET_XREF(I,XREF_REF);                                         01169600
            IF SYT_LINK1(I)<0 THEN DO;                                          01169700
               IF DO_LEVEL<(-SYT_LINK1(I)) THEN CALL ERROR(CLASS_GL,3);         01169800
            END;                                                                01169900
            ELSE IF SYT_LINK1(I) = 0 THEN SYT_LINK1(I) = STMT_NUM;              01170000
            XSET "1001";                                                        01170200
            IF VAR_LENGTH(I)>3 THEN CALL ERROR(CLASS_GL,VAR_LENGTH(I));         01170300
            ELSE IF VAR_LENGTH(I)=0 THEN VAR_LENGTH(I)=3;                       01170400
            CALL HALMAT_POP(XBRA,1,0,0);                                        01170500
            CALL HALMAT_PIP(I,XSYT,0,0);                                        01170600
            GO TO FIX_NOLAB;                                                    01170700
         END;                                                                   01170800
 /* <BASIC STATEMENT>::= ; */                                                   01170900
FIX_NOLAB:FIXF(MP)=0;                                                           01171000
 /* <BASIC STATEMENT>::= <CALL KEY> ; */                                        01171100
         CALL END_ANY_FCN;                                                      01171200
 /* <BASIC STATEMENT>::= <CALL KEY> (<CALL LIST>) ; */                          01171300
         CALL END_ANY_FCN;                                                      01171400
 /* <BASIC STATEMENT>::=<CALL KEY><ASSIGN>(<CALL ASSIGN LIST>);  */             01171500
         CALL END_ANY_FCN;                                                      01171600
 /* <BASIC STATEMENT>::=<CALL KEY>(<CALL LIST>)<ASSIGN>(<CALL ASSIGN LIST>); */ 01171700
         CALL END_ANY_FCN;                                                      01171800
 /* <BASIC STATEMENT>::= RETURN ; */                                            01171900
         DO;                                                                    01172000
        IF SYT_CLASS(BLOCK_SYTREF(NEST))=FUNC_CLASS THEN CALL ERROR(CLASS_PF,1);01172100
            ELSE IF BLOCK_MODE(NEST)=UPDATE_MODE THEN CALL ERROR(CLASS_UP,2);   01172200
            CALL HALMAT_POP(XRTRN,0,0,0);                                       01172300
            XSET"7";                                                            01172400
            GO TO FIX_NOLAB;                                                    01172500
         END;                                                                   01172600
 /* <BASIC STATEMENT>::= RETURN <EXPRESSION> ; */                               01172700
         DO;                                                                    01172800
            XSET"7";                                                            01172900
            TEMP=0;                                                             01173000
            IF KILL_NAME(MPP1) THEN CALL ERROR(CLASS_PF,9);                     01173100
            IF CHECK_ARRAYNESS THEN CALL ERROR(CLASS_PF,3);                     01173200
            IF BLOCK_MODE(NEST)=UPDATE_MODE THEN CALL ERROR(CLASS_UP,2);        01173300
            ELSE IF SYT_CLASS(BLOCK_SYTREF(NEST))^=FUNC_CLASS THEN              01173400
               CALL ERROR(CLASS_PF,2);                                          01173500
            ELSE DO;                                                            01173600
               PTR=0;                                                           01173700
               LOC_P=BLOCK_SYTREF(NEST);                                        01173800
               PSEUDO_LENGTH= VAR_LENGTH(LOC_P);                                01173900
               TEMP=SYT_TYPE(BLOCK_SYTREF(NEST));                               01174000
               IF (SHL(1,PSEUDO_TYPE(PTR(MPP1)))&ASSIGN_TYPE(TEMP))=0 THEN      01174100
                  CALL ERROR(CLASS_PF,4);                                       01174200
            END;                                                                01174300
            DO CASE TEMP;                                                       01174400
               ;;;                                                              01174500
                  CALL MATRIX_COMPARE(0,MPP1,CLASS_PF,5);                       01174600
               CALL VECTOR_COMPARE(0,MPP1,CLASS_PF,6);                          01174700
               ;;;;;                                                            01174800
                CALL STRUCTURE_COMPARE(VAR_LENGTH(LOC_P),FIXL(MPP1),CLASS_PF,7);01174900
               ;                                                                01175000
            END;                                                                01175100
            CALL HALMAT_TUPLE(XRTRN,0,MPP1,0,0);                                01175200
            CALL HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,         /*DR120223*/
               PSEUDO_TYPE(PTR(MPP1)),0);                 /*DR120223*/
            PTR_TOP=PTR(MPP1)-1;                                                01175300
            GO TO FIX_NOLAB;                                                    01175400
         END;                                                                   01175500
                                                                                01175600
 /* <BASIC STATEMENT>::= <DO GROUP HEAD> <ENDING> ; */                          01175700
         DO;                                                                    01175800
            XSET"8";                                                            01175900
            INDENT_LEVEL=INDENT_LEVEL - INDENT_INCR;                            01176000
            NEST_LEVEL = NEST_LEVEL - 1;                                        01176050
            DO CASE DO_INX(DO_LEVEL)&"7F";                                      01176100
 /* SIMPLE DO */                                                                01176200
               TEMP=XESMP;                                                      01176300
 /* DO FOR */                                                                   01176400
               TEMP=XEFOR;                                                      01176500
 /* DO CASE */                                                                  01176600
               DO;                                                              01176700
                  CALL HALMAT_FIX_POPTAG(FIXV(MP),1);                           01176800
                  TEMP=XECAS;                                                   01176900
                  INFORMATION= '';                              /*CR12713*/
                  CASE_LEVEL=CASE_LEVEL-1;                                      01177100
               END;                                                             01177200
 /* DO WHILE */                                                                 01177300
               TEMP=XETST;                                                      01177400
            END;                                                                01177500
            CALL HALMAT_POP(TEMP,1,0,0);                                        01177600
            CALL HALMAT_PIP(DO_LOC(DO_LEVEL),XINL,0,0);                         01177700
            I=0;                                                                01177800
            DO WHILE SYT_LINK2(I)>0;                                            01177900
               J=SYT_LINK2(I);                                                  01178000
               IF SYT_LINK1(J)<0 THEN IF DO_LEVEL=(-SYT_LINK1(J)) THEN DO;      01178100
                  SYT_LINK1(J)=-(DO_LEVEL_LIM+1);                               01178200
                  SYT_LINK2(I)=SYT_LINK2(J);                                    01178300
               END;                                                             01178400
               I=J;                                                             01178500
            END;                                                                01178600
            IF DO_LOC=0 THEN DO;                                                01178700
               I=DO_CHAIN(DO_LEVEL);                                            01178800
               DO WHILE I>0;                                                    01178900
                  CLOSE_BCD=SYT_NAME(I);                                        01179000
                  CALL DISCONNECT(I);                                           01179100
                  I=SYT_LINK1(I);                                               01179200
               END;                                                             01179300
               DO_LEVEL=DO_LEVEL-1;                                             01179400
            END;                                                                01179500
            ELSE DO_LOC=DO_LOC-1;                                               01179600
            GO TO FIX_NOLAB;                                                    01179700
         END;                                                                   01179800
 /* <BASIC STATEMENT>::= <READ KEY>; */                                         01179900
         DO;                                                                    01180000
IO_EMIT:                                                                        01180100
            XSET"3";                                                            01180200
            CALL HALMAT_TUPLE(XREAD(INX(PTR(MP))),0,MP,0,0);                    01180300
            PTR_TOP=PTR(MP)-1;                                                  01180400
            CALL HALMAT_POP(XXXND,0,0,0);                                       01180500
            GO TO FIX_NOLAB;                                                    01180600
         END;                                                                   01180700
 /* <BASIC STATEMENT>::= <READ PHRASE> ; */                                     01180800
         GO TO IO_EMIT;                                                         01180900
 /* <BASIC STATEMENT>::= <WRITE KEY> ; */                                       01181000
         GO TO IO_EMIT;                                                         01181100
 /* <BASIC STATEMENT>::= <WRITE PHRASE> ; */                                    01181200
         GO TO IO_EMIT;                                                         01181300
 /* <BASIC STATEMENT>::= <FILE EXP> = <EXPRESSION> ; */                         01181400
         DO;                                                                    01181500
            CALL HALMAT_TUPLE(XFILE,0,MP,SP-1,FIXV(MP));                        01181600
            CALL HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,PSEUDO_TYPE(PTR(SP-1)),1);     01181700
            IF KILL_NAME(SP-1) THEN CALL ERROR(CLASS_T,5);                      01181800
            CALL EMIT_ARRAYNESS;                                                01181900
            PTR_TOP=PTR(MP)-1;                                                  01182000
            XSET "800";                                                         01182050
            GO TO FIX_NOLAB;                                                    01182100
         END;                                                                   01182200
 /* <BASIC STATEMENT>::= <VARIABLE> = <FILE EXP> ; */                           01182300
         DO;                                                                    01182400
            CALL HALMAT_TUPLE(XFILE,0,SP-1,MP,FIXV(SP-1));                      01182500
            H1=VAL_P(PTR(MP));                                                  01182600
            IF SHR(H1,7) THEN CALL ERROR(CLASS_T,4);                            01182700
            IF SHR(H1,4) THEN CALL ERROR(CLASS_T,7);                            01182800
            IF (H1&"6")="2" THEN CALL ERROR(CLASS_T,8);                         01182900
            CALL HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,PSEUDO_TYPE(PTR(MP)),0);       01183000
            IF KILL_NAME(MP) THEN CALL ERROR(CLASS_T,5);                        01183100
            CALL CHECK_ARRAYNESS;  /* DR 173 */                                 01183200
            PTR_TOP=PTR(MP)-1;                                                  01183300
            GO TO FIX_NOLAB;                                                    01183400
         END;                                                                   01183500
 /* <BASIC STATEMENT>  ::=  <WAIT KEY>  FOR DEPENDENT ;  */                     01183600
         DO;                                                                    01183700
            CALL HALMAT_POP(XWAIT,0,0,0);                                       01183800
            XSET"B";                                                            01183900
UPDATE_CHECK:                                                                   01184000
            IF UPDATE_BLOCK_LEVEL>0 THEN CALL ERROR(CLASS_RU,1);                01184100
            IF INLINE_LEVEL>0 THEN CALL ERROR(CLASS_PP,6);                      01184200
            REFER_LOC=0;                                                        01184300
            GO TO FIX_NOLAB;                                                    01184400
         END;                                                                   01184500
 /* <BASIC STATEMENT>::= <WAIT KEY><ARITH EXP>; */                              01184600
         DO;                                                                    01184700
            TEMP=1;                                                             01184800
            IF UNARRAYED_SCALAR(SP-1) THEN CALL ERROR(CLASS_RT,6,'WAIT');       01184900
WAIT_TIME:                                                                      01185000
            XSET"B";                                                            01185100
            CALL HALMAT_TUPLE(XWAIT,0,SP-1,0,TEMP);                             01185200
            PTR_TOP=PTR(SP-1)-1;                                                01185300
            GO TO UPDATE_CHECK;                                                 01185400
         END;                                                                   01185500
 /*  <BASIC STATEMENT> ::=  <WAIT KEY> UNTIL <ARITH EXP> ;  */                  01185600
         DO;                                                                    01185700
            TEMP=2;                                                             01185800
            IF UNARRAYED_SCALAR(SP-1) THEN CALL ERROR(CLASS_RT,6,'WAIT UNTIL'); 01185900
            GO TO WAIT_TIME;                                                    01186000
         END;                                                                   01186100
 /* <BASIC STATEMENT>::= <WAIT KEY> FOR <BIT EXP> ; */                          01186200
         DO;                                                                    01186300
            TEMP=3;                                                             01186400
            IF CHECK_EVENT_EXP(SP-1) THEN CALL ERROR(CLASS_RT,6,'WAIT FOR');    01186500
            GO TO WAIT_TIME;                                                    01186600
         END;                                                                   01186700
 /* <BASIC STATEMENT>::= <TERMINATOR> ; */                                      01186800
         DO;                                                                    01186900
            XSET"A";                                                            01187000
            CALL HALMAT_POP(FIXL(MP),0,0,0);                                    01187100
            GO TO UPDATE_CHECK;                                                 01187200
         END;                                                                   01187300
 /* <BASIC STATEMENT>::= <TERMINATOR> <TERMINATE LIST>; */                      01187400
         DO;                                                                    01187500
            XSET"A";                                                            01187600
            CALL HALMAT_POP(FIXL(MP),EXT_P(PTR(MPP1)),0,1);                     01187700
            DO H1=PTR(MPP1) TO EXT_P(PTR(MPP1))+PTR(MPP1)-1;                    01187800
               CALL HALMAT_PIP(LOC_P(H1),PSEUDO_FORM(H1),0,0);                  01187900
            END;                                                                01188000
            PTR_TOP=PTR(MPP1)-1;                                                01188100
            GO TO UPDATE_CHECK;                                                 01188200
         END;                                                                   01188300
 /* <BASIC STATEMENT>::= UPDATE PRIORITY TO <ARITH EXP>; */                     01188400
         DO;                                                                    01188500
            PTR_TOP=PTR(SP-1)-1;                                                01188600
            TEMP=0;                                                             01188700
UP_PRIO:                                                                        01188800
            XSET"C";                                                            01188900
            IF UNARRAYED_INTEGER(SP-1) THEN                                     01189000
               CALL ERROR(CLASS_RT,4,'UPDATE PRIORITY');                        01189100
            CALL HALMAT_TUPLE(XPRIO,0,SP-1,TEMP,TEMP>0);                        01189200
            GO TO UPDATE_CHECK;                                                 01189300
         END;                                                                   01189400
 /*  <BASIC STATEMENT>  ::=  UPDATE PRIORITY  <LABEL VAR>  TO  <ARITH EXP>; */  01189500
         DO;                                                                    01189600
            CALL SET_XREF_RORS(MP+2,"C000");                                    01189700
            CALL PROCESS_CHECK(MP+2);                                           01189800
            TEMP=MP+2;                                                          01189900
            PTR_TOP=PTR(TEMP)-1;                                                01190000
            GO TO UP_PRIO;                                                      01190100
         END;                                                                   01190200
 /* <BASIC STATEMENT>::= <SCHEDULE PHRASE>; */                                  01190300
         DO;                                                                    01190400
SCHEDULE_EMIT:                                                                  01190500
            XSET"9";                                                            01190600
            CALL HALMAT_POP(XSCHD,PTR_TOP-REFER_LOC+1,0,INX(REFER_LOC));        01190700
            DO WHILE REFER_LOC<=PTR_TOP;                                        01190800
               CALL HALMAT_PIP(LOC_P(REFER_LOC),PSEUDO_FORM(REFER_LOC),0,0);    01190900
               REFER_LOC=REFER_LOC+1;                                           01191000
            END;                                                                01191100
            PTR_TOP=PTR(MP)-1;                                                  01191200
            GO TO UPDATE_CHECK;                                                 01191300
         END;                                                                   01191400
 /* <BASIC STATEMENT>::=<SCHEDULE PHRASE><SCHEDULE CONTROL>; */                 01191500
         GO TO SCHEDULE_EMIT;                                                   01191600
 /*  <BASIC  STATEMENT>  ::=  <SIGNAL CLAUSE>  ;  */                            01191700
         DO;                                                                    01191800
            XSET"D";                                                            01191900
            CALL HALMAT_TUPLE(XSGNL,0,MP,0,INX(PTR(MP)));                       01192000
            PTR_TOP=PTR(MP)-1;                                                  01192100
            GO TO FIX_NOLAB;                                                    01192200
         END;                                                                   01192300
 /*  <BASIC STATEMENT>  ::=  SEND ERROR <SUBSCRIPT>  ;  */                      01192400
         DO;                                                                    01192500
            CALL ERROR_SUB(2);                                                  01192600
            CALL HALMAT_TUPLE(XERSE,0,MP+2,0,0,FIXV(MP)&"3F");                  01192700
            CALL SET_OUTER_REF(FIXV(MP),"0000");                                01192800
            PTR_TOP=PTR(MP+2)-1;                                                01192900
            GO TO FIX_NOLAB;                                                    01193000
         END;                                                                   01193100
 /*  <BASIC STATEMENT>  ::=  <ON CLAUSE>  ;  */                                 01193200
         DO;                                                                    01193300
            CALL HALMAT_TUPLE(XERON,0,MP,0,FIXL(MP),FIXV(MP)&"3F");             01193400
            PTR_TOP=PTR(MP)-1;                                                  01193500
            GO TO FIX_NOLAB;                                                    01193600
         END;                                                                   01193700
 /*  <BASIC STATEMENT>  ::=  <ON CLAUSE> AND <SIGNAL CLAUSE> ;  */              01193800
         DO;                                                                    01193900
            CALL HALMAT_TUPLE(XERON,0,MP,MP+2,FIXL(MP),FIXV(MP)&"3F",0,0,       01194000
               INX(PTR(MP+2)));                                                 01194100
            PTR_TOP=PTR(MP)-1;                                                  01194200
            GO TO FIX_NOLAB;                                                    01194300
         END;                                                                   01194400
 /*  <BASIC STATEMENT>  ::=  OFF ERROR <SUBSCRIPT>  ;  */                       01194500
         DO;                                                                    01194600
            CALL ERROR_SUB(0);                                                  01194700
            CALL HALMAT_TUPLE(XERON,0,MP+2,0,3,FIXV(MP)&"3F");                  01194800
            PTR_TOP=PTR(MP+2)-1;                                                01194900
            GO TO FIX_NOLAB;                                                    01195000
         END;                                                                   01195100
 /*  <BASIC STATEMENT>  ::=  <% MACRO NAME> ;  */                               01195200
         DO;                                                                    01195300
            CALL HALMAT_POP(XPMHD,0,0,FIXL(MP));                                01195400
            CALL HALMAT_POP(XPMIN,0,0,FIXL(MP));                                01195500
            XSET (PC_STMT_TYPE_BASE + FIXL(MP));                                01195600
            IF PCARG#(FIXL(MP)) ^= 0 THEN                                       01195700
               IF ALT_PCARG#(FIXL(MP)) ^= 0 THEN                                01195800
               CALL ERROR(CLASS_XM, 2, VAR(MP));                                01195900
            GO TO FIX_NOLAB;                                                    01196000
         END;                                                                   01196100
 /*  <BASIC STATEMENT>  ::=  <% MACRO HEAD> <% MACRO ARG> ) ;  */               01196200
         DO;                                                                    01196300
            IF PCARG# ^= 0 THEN                                                 01196400
               IF ALT_PCARG# ^= 0 THEN                                          01196500
               CALL ERROR(CLASS_XM, 2, VAR(MP));                                01196600
            CALL HALMAT_TUPLE(XPMAR, 0, MPP1, 0, 0, PSEUDO_TYPE(PTR(MPP1)));    01196700
            PTR_TOP=PTR(MPP1)-1;                                                01196800
            DELAY_CONTEXT_CHECK=FALSE;                                          01196900
            CALL HALMAT_POP(XPMIN,0,0,FIXL(MP));                                01197000
            ASSIGN_ARG_LIST = FALSE;  /* RESTORE LOCK GROUP CHECKING */         01197010

            /* RESET PCARGOFF HERE SO THAT IT CAN BE USED       DR109039*/
            /* TO DETERMINE WHETHER PERCENT MACRO ARGUMENT      DR109039*/
            /* PROCESSING IS HAPPENING.                         DR109039*/
            PCARGOFF = 0;                                     /*DR109039*/
            GO TO FIX_NOLAB;                                                    01197100
         END;                                                                   01197200
 /*  <% MACRO HEAD>  ::=  <% MACRO NAME> (  */                                  01197300
         DO;                                                                    01197400
            IF FIXL(MP) = 0 THEN ALT_PCARG#, PCARG#, PCARGOFF = 0;              01197500
            ELSE DO;                                                            01197600
               PCARG#=PCARG#(FIXL(MP));                                         01197700
               PCARGOFF=PCARGOFF(FIXL(MP));                                     01197800

               /* CHECK PCARGBITS OF THE %MACRO ARGUMENT TO   DR109039*/
               /* SEE IF IT REQUIRES NAME CONTEXT CHECKING.   DR109039*/
               /* IF SO, SET NAMING FLAG.                     DR109039*/
               IF ((PCARGBITS(PCARGOFF)&"80")^=0) THEN      /*DR109039*/
                  NAMING = TRUE;                            /*DR109039*/

               ALT_PCARG# = ALT_PCARG#(FIXL(MP));                               01197900
            END;                                                                01198000
            XSET (PC_STMT_TYPE_BASE + FIXL(MP));                                01198100
            CALL HALMAT_POP(XPMHD,0,0,FIXL(MP));                                01198200
            DELAY_CONTEXT_CHECK=TRUE;                                           01198300
            IF FIXL(MP) = PCCOPY_INDEX THEN                                     01198310
               ASSIGN_ARG_LIST = TRUE;  /* INHIBIT LOCK CHECK IN ASSOCIATE */   01198320
         END;                                                                   01198400
 /*  <% MACRO HEAD>  ::=  <% MACRO HEAD> <% MACRO ARG> ,  */                    01198500
         DO;                                                                    01198600
            CALL HALMAT_TUPLE(XPMAR, 0, MPP1, 0, 0, PSEUDO_TYPE(PTR(MPP1)));    01198700
            PTR_TOP=PTR(MPP1)-1;                                                01198800
         END;                                                                   01198900
 /*  <% MACRO ARG>  ::=  <NAME VAR>  */                                         01199000
         IF PCARGOFF>0 THEN DO;                                                 01199100
            IF PCARG#=0 THEN PCARGOFF=0;                                        01199200
            ELSE DO;                                                            01199300
               TEMP=PCARGBITS(PCARGOFF);                                        01199400
               IF (TEMP&"1")=0 THEN CALL ERROR(CLASS_XM,5);                     01199500
               ELSE DO;                                                         01199600
                  H1=PSEUDO_TYPE(PTR(MP));                                      01199700
                  IF H1 > "40" THEN H1 = (H1 & "F") + 10;                       01199800
                  ELSE IF TEMP_SYN = 0 THEN H1 = H1 + 20;                       01199900
                  IF (SHL(1,H1)&PCARGTYPE(PCARGOFF))=0 THEN                     01200000
                     CALL ERROR(CLASS_XM,4);   /* ILLEGAL TYPE  */              01200100
                  IF EXT_P(PTR(MP))>0 THEN IF SHR(TEMP,6) THEN                  01200200
                     CALL ERROR(CLASS_XM,10);   /* NO NAME COPINESS */          01200300
                  CALL RESET_ARRAYNESS;                                         01200400
                  IF CHECK_ARRAYNESS THEN IF SHR(TEMP,5) THEN                   01200500
                     CALL ERROR(CLASS_XM,7);  /* NO ARRAYNESS */                01200600
                  IF SHR(TEMP,4) THEN IF TEMP_SYN^=2 THEN TEMP_SYN=3;           01200700
                  IF SHR(TEMP,7) THEN CALL CHECK_NAMING(TEMP_SYN,MP);           01200800
                  ELSE DO;                                                      01200900
                     IF SHR(TEMP,4) THEN CALL CHECK_ASSIGN_CONTEXT(MP);         01201000
                     ELSE CALL SET_XREF_RORS(MP);                               01201100
                     IF FIXV(MP)>0 THEN H2=FIXV(MP);                            01201200
                     ELSE H2=FIXL(MP);                                          01201300
                     IF (SYT_FLAGS(H2)&(TEMPORARY_FLAG))^=0 THEN /* DR102960 */ 01201400
                        IF SHR(TEMP,8) THEN CALL ERROR(CLASS_XM,8);             01201500
                     H2=VAL_P(PTR(MP));                                         01201600
  /*CR13570 - NO SUBSCRIPTS ARE ALLOWED ON THE SOURCE OF %NAMEBIAS */
  /*CR13570*/        IF PCARGOFF=2 THEN DO;
  /*CR13570*/           IF SHR(TEMP,2) THEN
  /*CR13570*/              IF SHR(H2,5) THEN CALL ERROR(CLASS_XM,9);
  /*CR13570*/        END;
  /*CR13570*/        ELSE
                        IF SHR(TEMP,2) THEN                                     01201700
                           IF SHR(H2,4) THEN CALL ERROR(CLASS_XM,9);
                  END;                                                          01201800
               END;                                                             01201900
               PCARGOFF=PCARGOFF+1;                                             01202000

               /* CHECK PCARGBITS OF THE %MACRO ARGUMENT TO   DR109039*/
               /* SEE IF IT REQUIRES NAME CONTEXT CHECKING.   DR109039*/
               /* IF SO, SET NAMING FLAG.                     DR109039*/
               IF ((PCARGBITS(PCARGOFF)&"80")^=0) THEN      /*DR109039*/
                  NAMING = TRUE;                            /*DR109039*/

            END;                                                                01202100
            PCARG#=PCARG#-1;                                                    01202200
            ALT_PCARG# = ALT_PCARG# - 1;                                        01202300
         END;                                                                   01202400
 /*  <% MACRO ARG>  ::=  <CONSTANT>  */                                         01202500
         IF PCARGOFF>0 THEN DO;                                                 01202600
            IF PCARG#=0 THEN PCARGOFF=0;                                        01202700
            ELSE DO;                                                            01202800
               IF (PCARGBITS(PCARGOFF)&"8")=0 THEN CALL ERROR(CLASS_XM,3);      01202900
 /* LITERALS ILLEGAL */                                                         01203000
               ELSE IF (SHL(1,PSEUDO_TYPE(PTR(MP)))&PCARGTYPE(PCARGOFF))=0 THEN 01203100
                  CALL ERROR(CLASS_XM,4);    /*  TYPE ILLEGAL */                01203200
               PCARGOFF=PCARGOFF+1;                                             01203300
            END;                                                                01203400
            PCARG#=PCARG#-1;                                                    01203500
            ALT_PCARG# = ALT_PCARG# - 1;                                        01203600
         END;                                                                   01203700
 /*  <BIT PRIM>  ::=  <BIT VAR>  */                                             01203800
         DO;                                                                    01203900
            CALL SET_XREF_RORS(MP);                                             01204000
NON_EVENT:                                                                      01204100
            INX(PTR(MP))=FALSE;                                                 01204200
         END;                                                                   01204300
 /*  <BIT PRIM>  ::=  <LABEL VAR>  */                                           01204400
         DO;                                                                    01204500
            CALL SET_XREF_RORS(MP,"2000");                                      01204600
            TEMP=PSEUDO_TYPE(PTR(MP));                                          01204700
            IF (TEMP=TASK_LABEL)|(TEMP=PROG_LABEL) THEN;                        01204800
            ELSE CALL ERROR(CLASS_RT,14,VAR(MP));                               01204900
            IF REFER_LOC>0 THEN INX(PTR(MP))=1;                                 01205000
            ELSE INX(PTR(MP))=2;                                                01205100
YES_EVENT:                                                                      01205200
            PSEUDO_TYPE(PTR(MP))=BIT_TYPE;                                      01205300
            PSEUDO_LENGTH(PTR(MP))=1;                                           01205400
         END;                                                                   01205500
 /*  <BIT PRIM>  ::=  <EVENT VAR>  */                                           01205600
         DO;                                                                    01205700
            CALL SET_XREF_RORS(MP);                                             01205800
            INX(PTR(MP))=REFER_LOC>0;                                           01205900
            GO TO YES_EVENT;                                                    01206000
         END;                                                                   01206100
 /*  <BIT PRIM>  ::=  <BIT CONST>  */                                           01206200
         GO TO NON_EVENT;                                                       01206300
 /*  <BIT PRIM>  ::=  (  <BIT EXP>  )  */                                       01206400
         PTR(MP)=PTR(MPP1);                                                     01206500
 /*  <BIT PRIM>  ::=  <MODIFIED BIT FUNC>  */                                   01206600
         DO;                                                                    01206700
            CALL SETUP_NO_ARG_FCN;                                              01206800
            GO TO NON_EVENT;                                                    01206900
         END;                                                                   01207000
 /*  <BIT PRIM>  ::=  <BIT INLINE DEF> <BLOCK BODY> <CLOSING>  ;  */            01207100
         DO;                                                                    01207200
            GO TO INLINE_SCOPE;                                                 01207300
         END;                                                                   01207400
 /*  <BIT PRIM>  ::=  <SUBBIT HEAD>  <EXPRESSION>  )  */                        01207500
         DO;                                                                    01207600
            CALL END_SUBBIT_FCN;                                                01207700
            CALL SET_BI_XREF(SBIT_NDX);                                         01207710
            GO TO NON_EVENT;                                                    01207800
         END;                                                                   01207900
 /*  <BIT PRIM>  ::=  <BIT FUNC HEAD>  (  <CALL LIST>  )  */                    01208000
         DO;                                                                    01208100
            CALL END_ANY_FCN;                                                   01208200
            GO TO NON_EVENT;                                                    01208300
         END;                                                                   01208400
 /*  <BIT FUNC HEAD>  ::= <BIT FUNC>  */                                        01208500
         IF START_NORMAL_FCN THEN CALL ASSOCIATE;                               01208600
 /*  <BIT FUNC HEAD>  ::=  BIT  <SUB OR QUALIFIER>  */                          01208700
         DO;                                                                    01208800
            NOSPACE;                                                            01208900
            PTR(MP)=PTR(SP);                                                    01209000
            PSEUDO_TYPE(PTR(MP))=BIT_TYPE;                                      01209100
            VAR(MP)='BIT CONVERSION FUNCTION';                                  01209200
            IF PUSH_FCN_STACK(3) THEN FCN_LOC(FCN_LV)=1;                        01209300
            CALL SET_BI_XREF(BIT_NDX);                                          01209310
         END;                                                                   01209400
 /*  <BIT CAT> ::= <BIT PRIM>    */                                             01209500
         ;                                                                      01209600
 /*  <BIT CAT>  ::=  <BIT CAT>  <CAT>  <BIT PRIM>  */                           01209700
DO_BIT_CAT :                                                                    01209800
         DO ;                                                                   01209900
            INX(PTR(MP))=FALSE;                                                 01210000
            TEMP=PSEUDO_LENGTH(PTR(MP))+PSEUDO_LENGTH(PTR(SP));                 01210100
            IF TEMP>BIT_LENGTH_LIM THEN DO;                                     01210200
               TEMP=BIT_LENGTH_LIM;                                             01210300
               CALL ERROR(CLASS_EB,1);                                          01210400
            END;                                                                01210500
            CALL HALMAT_TUPLE(XBCAT,0,MP,SP,0);                                 01210600
            CALL SETUP_VAC(MP,BIT_TYPE,TEMP);                                   01210700
            PTR_TOP=PTR(MP);                                                    01210800
         END ;                                                                  01210900
 /* <BIT CAT> ::= <NOT> <BIT PRIM>  */                                          01211000
         DO ;                                                                   01211100
            IF BIT_LITERAL(SP,0) THEN DO;                                       01211200
               TEMP=PSEUDO_LENGTH(PTR(SP));                                     01211300
               TEMP2=SHL(FIXV(SP),HOST_BIT_LENGTH_LIM-TEMP);                    01211400
               TEMP2=^TEMP2;                                                    01211500
               TEMP2=SHR(TEMP2,HOST_BIT_LENGTH_LIM-TEMP);                       01211600
               LOC_P(PTR(SP))=SAVE_LITERAL(2,TEMP2,TEMP);                       01211700
            END;                                                                01211800
            ELSE DO;                                                            01211900
               CALL HALMAT_TUPLE(XBNOT,0,SP,0,INX(PTR(SP)));                    01212000
               CALL SETUP_VAC(SP,BIT_TYPE);                                     01212100
            END;                                                                01212200
            INX(PTR(SP))=INX(PTR(SP))&1;                                        01212300
            PTR(MP)=PTR(SP);                                                    01212400
         END ;                                                                  01212500
 /* <BIT CAT> ::= <BIT CAT> <CAT> <NOT> <BIT PRIM>  */                          01212600
         DO;                                                                    01212700
            CALL HALMAT_TUPLE(XBNOT,0,SP,0,0);                                  01212800
            CALL SETUP_VAC(SP,BIT_TYPE);                                        01212900
            GO TO DO_BIT_CAT;                                                   01213000
         END ;                                                                  01213100
 /*  <BIT FACTOR> ::= <BIT CAT>    */                                           01213200
         ;                                                                      01213300
 /*   <BIT FACTOR> ::= <BIT FACTOR> <AND> <BIT CAT>  */                         01213400
         DO ;                                                                   01213500
            IF BIT_LITERAL(MP,SP) THEN DO;                                      01213600
               TEMP=FIXV(MP)&FIXV(SP);                                          01213700
DO_LIT_BIT_FACTOR:                                                              01213800
               IF PSEUDO_LENGTH(PTR(MP)) ^= PSEUDO_LENGTH(PTR(SP)) /*CR13211*/
                  THEN CALL ERROR(CLASS_YE,100);                   /*CR13211*/
               TEMP2=PSEUDO_LENGTH(PTR(MP));                                    01213900
              IF TEMP2<PSEUDO_LENGTH(PTR(SP)) THEN TEMP2=PSEUDO_LENGTH(PTR(SP));01214000
               LOC_P(PTR(MP))=SAVE_LITERAL(2,TEMP,TEMP2);                       01214100
            END;                                                                01214200
            ELSE DO;                                                            01214300
               TEMP = XBAND ;                                                   01214400
DO_BIT_FACTOR:                                                                  01214500
               TEMP2=INX(PTR(MP))&INX(PTR(SP))&1;                               01214600
               CALL HALMAT_TUPLE(TEMP,0,MP,SP,TEMP2);                           01214700
               INX(PTR(MP))=TEMP2;                                              01214800
               TEMP=PSEUDO_LENGTH(PTR(MP));                                     01214900
               IF TEMP<PSEUDO_LENGTH(PTR(SP)) THEN                              01215000
                  TEMP=PSEUDO_LENGTH(PTR(SP));                                  01215100
               CALL SETUP_VAC(MP,BIT_TYPE,TEMP);                                01215200
            END;                                                                01215300
            PTR_TOP=PTR(MP);                                                    01215400
         END ;                                                                  01215500
 /*  <BIT EXP> ::= <BIT FACTOR>    */                                           01215600
         ;                                                                      01215700
 /*   <BIT EXP> ::= <BIT EXP> <OR> <BIT FACTOR>  */                             01215800
         DO ;                                                                   01215900
            IF BIT_LITERAL(MP,SP) THEN DO;                                      01216000
               TEMP=FIXV(MP)|FIXV(SP);                                          01216100
               GO TO DO_LIT_BIT_FACTOR;                                         01216200
            END;                                                                01216300
            ELSE DO;                                                            01216400
               TEMP=XBOR;                                                       01216500
               GO TO DO_BIT_FACTOR;                                             01216600
            END;                                                                01216700
         END ;                                                                  01216800
                                                                                01216900
 /*  <RELATIONAL OP> ::= =    */                                                01217000
         REL_OP = 0 ;                                                           01217100
 /* <RELATIONAL OP> ::= <NOT> =  */                                             01217200
         REL_OP = 1 ;                                                           01217300
 /*  <RELATIONAL OP> ::= <    */                                                01217400
         REL_OP = 2 ;                                                           01217500
 /*  <RELATIONAL OP> ::= >    */                                                01217600
         REL_OP = 3 ;                                                           01217700
 /* <RELATIONAL OP> ::= <  = */                                                 01217800
         DO;                                                                    01217900
            NOSPACE;                                                            01218000
            REL_OP = 4 ;                                                        01218100
         END;                                                                   01218200
 /* <RELATIONAL OP> ::= >  = */                                                 01218300
         DO;                                                                    01218400
            NOSPACE;                                                            01218500
            REL_OP = 5 ;                                                        01218600
         END;                                                                   01218700
 /* <RELATIONAL OP> ::= <NOT> <  */                                             01218800
         REL_OP = 5 ;                                                           01218900
 /* <RELATIONAL OP> ::= <NOT> >  */                                             01219000
         REL_OP = 4 ;                                                           01219100
                                                                                01219200
 /*  <COMPARISON> ::= <ARITH EXP> <RELATIONAL OP> <ARITH EXP>    */             01219300
         DO ;                                                                   01219400
            CALL MATCH_ARITH(MP,SP);                                            01219500
            DO CASE PSEUDO_TYPE(PTR(MP))-MAT_TYPE;                              01219600
               DO;                                                              01219700
                  TEMP=XMEQU(REL_OP);                                           01219800
                  VAR(MP)='MATRIX';                                             01219900
               END;                                                             01220000
               DO;                                                              01220100
                  TEMP=XVEQU(REL_OP);                                           01220200
                  VAR(MP)='VECTOR';                                             01220300
               END;                                                             01220400
               DO;                                                              01220500
                  TEMP=XSEQU(REL_OP);                                           01220600
                  VAR(MP)='';                                                   01220700
               END;                                                             01220800
               DO;                                                              01220900
                  TEMP=XIEQU(REL_OP);                                           01221000
                  VAR(MP)='';                                                   01221100
               END;                                                             01221200
            END;                                                                01221300
EMIT_REL:                                                                       01221400
            CALL HALMAT_TUPLE(TEMP,XCO_N,MP,SP,0);                              01221500
         END ;                                                                  01221600
 /* <COMPARISON> ::= <CHAR EXP> <RELATIONAL OP> <CHAR EXP> */                   01221700
         DO ;                                                                   01221800
            TEMP=XCEQU(REL_OP);                                                 01221900
            VAR(MP)='';                                                         01222000
            GO TO EMIT_REL;                                                     01222100
         END ;                                                                  01222200
 /* <COMAPRISON> ::= <BIT CAT> <RELATIONAL OP> <BIT CAT> */                     01222300
         DO ;                                                                   01222400
            TEMP=XBEQU(REL_OP);                                                 01222500
            VAR(MP)='BIT';                                                      01222600
            GO TO EMIT_REL;                                                     01222700
         END ;                                                                  01222800
 /*  <COMPARISON>  ::=  <STRUCTURE EXP> <RELATIONAL OP> <STRUCTURE EXP>  */     01222900
         DO ;                                                                   01223000
            TEMP=XTEQU(REL_OP);                                                 01223100
            VAR(MP)='STRUCTURE';                                                01223200
            CALL STRUCTURE_COMPARE(FIXL(MP),FIXL(SP),CLASS_C,3);                01223300
            GO TO EMIT_REL;                                                     01223400
         END ;                                                                  01223500
 /*  <COMPARISON>  ::=  <NAME EXP>  <RELATIONAL OP>  <NAME EXP>  */             01223600
         DO;                                                                    01223700
            CALL NAME_COMPARE(MP,SP,CLASS_C,4);                                 01223800
            TEMP=XNEQU(REL_OP);                                                 01223900
            VAR(MP)='NAME';                                                     01224000
            IF COPINESS(MP,SP) THEN CALL ERROR(CLASS_EA,1,VAR(SP));             01224100
            CALL NAME_ARRAYNESS(SP);                                            01224200
            GO TO EMIT_REL;                                                     01224300
         END;                                                                   01224400
 /*  <RELATIONAL FACTOR>  ::=  <REL PRIM>  */                                   01224500
         ;                                                                      01224600
 /* <RELATIONAL FACTOR> ::= <RELATIONAL FACTOR> <AND> <REL PRIM>  */            01224700
         DO ;                                                                   01224800
            CALL HALMAT_TUPLE(XCAND,XCO_N,MP,SP,0);                             01224900
            CALL SETUP_VAC(MP,0);                                               01225000
            PTR_TOP=PTR(MP);                                                    01225100
         END ;                                                                  01225200
 /* <RELATIONAL EXP> ::= <RELATIONAL FACTOR> */                                 01225300
         ;                                                                      01225400
 /* <RELATIONAL EXP> ::= < RELATIONAL EXP> <OR> < RELATIONAL FACTOR>  */        01225500
         DO ;                                                                   01225600
            CALL HALMAT_TUPLE(XCOR,XCO_N,MP,SP,0);                              01225700
            CALL SETUP_VAC(MP,0);                                               01225800
            PTR_TOP=PTR(MP);                                                    01225900
         END ;                                                                  01226000
 /* <REL PRIM> ::= (1 <RELATIONAL EXP> ) */                                     01226100
         PTR(MP) = PTR(MPP1) ; /* MOVE INDIRECT STACKS */                       01226200
 /* <REL PRIM> ::= <NOT> (1 <RELATIONAL EXP> )  */                              01226300
         DO ;                                                                   01226400
            CALL HALMAT_TUPLE(XCNOT,XCO_N,MP+2,0,0);                            01226500
            PTR(MP)=PTR(MP+2);                                                  01226600
            CALL SETUP_VAC(MP,0);                                               01226700
         END ;                                                                  01226800
 /* <REL PRIM> ::=  <COMPARISON>  */                                            01226900
         DO ;                                                                   01227000
            IF REL_OP>1 THEN DO;                                                01227100
               IF LENGTH(VAR(MP))>0 THEN CALL ERROR(CLASS_C,1,VAR(MP));         01227200
               ELSE IF CHECK_ARRAYNESS THEN CALL ERROR(CLASS_C,2);              01227300
               CALL CHECK_ARRAYNESS;                                            01227400
            END;                                                                01227500
            CALL SETUP_VAC(MP,0);                                               01227600
            PTR_TOP=PTR(MP);                                                    01227700
            CALL EMIT_ARRAYNESS;                                                01227800
         END ;                                                                  01227900
                                                                                01228000
 /*  <CHAR PRIM> ::= <CHAR VAR>    */                                           01228100
         CALL SET_XREF_RORS(MP);  /* SET XREF FLAG TO SUBSCR OR REF  */         01228200
 /*  <CHAR PRIM>  ::=  <CHAR CONST>  */                                         01228300
         ;                                                                      01228400
 /*  <CHAR PRIM>  ::=  <MODIFIED CHAR FUNC>  */                                 01228500
         CALL SETUP_NO_ARG_FCN;                                                 01228600
 /*  <CHAR PRIM>  ::=  <CHAR INLINE DEF> <BLOCK BODY> <CLOSING>  ;  */          01228700
         GO TO INLINE_SCOPE;                                                    01228800
 /*  <CHAR PRIM>  ::=  <CHAR FUNC HEAD>  (  <CALL LIST>  )  */                  01228900
         CALL END_ANY_FCN;                                                      01229000
 /*  <CHAR PRIM>  ::=  (  <CHAR EXP>  )  */                                     01229100
         PTR(MP)=PTR(MPP1);                                                     01229200
 /*  <CHAR FUNC HEAD>  ::=  <CHAR FUNC>  */                                     01229300
         IF START_NORMAL_FCN THEN CALL ASSOCIATE;                               01229400
 /*  <CHAR FUNC HEAD>  ::=  CHARACTER  <SUB OR QUALIFIER>  */                   01229500
         DO;                                                                    01229600
            NOSPACE;                                                            01229700
            PTR(MP)=PTR(SP);                                                    01229800
            PSEUDO_TYPE(PTR(MP))=CHAR_TYPE;                                     01229900
            VAR(MP)='CHARACTER CONVERSION FUNCTION';                            01230000
            IF PUSH_FCN_STACK(3) THEN FCN_LOC(FCN_LV)=0;                        01230100
            CALL SET_BI_XREF(CHAR_NDX);                                         01230110
         END;                                                                   01230200
 /*  <SUB OR QUALIFIER>  ::=  <SUBSCRIPT>  */                                   01230300
         DO;                                                                    01230400
            TEMP=PTR(MP);                                                       01230500
            LOC_P(TEMP)=0;                                                      01230600
            IF PSEUDO_FORM(TEMP)^=0 THEN DO;                                    01230700
               PSEUDO_FORM(TEMP)=0;                                             01230800
               CALL ERROR(CLASS_QS,9);                                          01230900
            END;                                                                01231000
            IF INX(TEMP)>0 THEN DO;                                             01231100
               IF (PSEUDO_LENGTH(TEMP)>=0)|(VAL_P(TEMP)>=0) THEN                01231200
                  CALL ERROR(CLASS_QS,1);                                       01231300
               IF INX(TEMP)^=1 THEN DO;                                         01231400
                  INX(TEMP)=1;                                                  01231500
                  CALL ERROR(CLASS_QS,10);                                      01231600
               END;                                                             01231700
            END;                                                                01231800
         END;                                                                   01231900
 /*  <SUB OR QUALIFIER>  ::=  <BIT QUALIFIER>  */                               01232000
         INX(PTR(MP))=0;                                                        01232100
                                                                                01232200
 /*  <CHAR EXP> ::= <CHAR PRIM>    */                                           01232300
         ;                                                                      01232400
 /* <CHAR EXP> ::= <CHAR EXP> <CAT> <CHAR PRIM> */                              01232500
         DO;                                                                    01232600
            IF CHAR_LITERAL(MP,SP) THEN DO;                                     01232700
               TEMP=CHAR_LENGTH_LIM - LENGTH(VAR(MP));                          01232800
               IF TEMP<LENGTH(VAR(SP)) THEN DO;                                 01232900
                  VAR(SP)=SUBSTR(VAR(SP),0,TEMP);                               01233000
                  CALL ERROR(CLASS_VC,1);                                       01233100
               END;                                                             01233200
               VAR(MP)=VAR(MP)||VAR(SP);                                        01233300
               LOC_P(PTR(MP))=SAVE_LITERAL(0,VAR(MP));                          01233400
               PSEUDO_LENGTH(PTR(MP)) = LENGTH(VAR(MP)); /*DR111376*/
            END;                                                                01233500
            ELSE DO;                                                            01233600
DO_CHAR_CAT:                                                                    01233700
               CALL HALMAT_TUPLE(XCCAT,0,MP,SP,0);                              01233800
               CALL SETUP_VAC(MP,CHAR_TYPE);                                    01233900
            END;                                                                01234000
            PTR_TOP=PTR(MP);                                                    01234100
         END;                                                                   01234200
 /* <CHAR EXP> ::= <CHAR EXP> <CAT> <ARITH EXP> */                              01234300
         DO ;                                                                   01234400
            CALL ARITH_TO_CHAR(SP) ;                                            01234500
            GO TO DO_CHAR_CAT ;                                                 01234600
         END ;                                                                  01234700
 /*  <CHAR EXP>  ::=  <ARITH EXP>  <CAT>  <ARITH EXP>  */                       01234800
         DO;                                                                    01234900
            CALL ARITH_TO_CHAR(SP);                                             01235000
            CALL ARITH_TO_CHAR(MP);                                             01235100
            GO TO DO_CHAR_CAT;                                                  01235200
         END;                                                                   01235300
 /* <CHAR EXP> ::= <ARITH EXP> <CAT> <CHAR PRIM> */                             01235400
         DO ;                                                                   01235500
            CALL ARITH_TO_CHAR(MP) ;                                            01235600
            GO TO DO_CHAR_CAT ;                                                 01235700
         END ;                                                                  01235800
 /* <ASSIGNMENT>::=<VARIABLE><=1><EXPRESSION> */                                01235900
         DO;                                                                    01236000
            INX(PTR(SP))=2;                                                     01236100
            IF NAME_PSEUDOS THEN DO;                                            01236200
               CALL NAME_COMPARE(MP,SP,CLASS_AV,5);                             01236300
               CALL HALMAT_TUPLE(XNASN,0,SP,MP,0);                              01236400
               IF COPINESS(MP,SP)>2 THEN CALL ERROR(CLASS_AA,1);                01236500
               GO TO END_ASSIGN;                                                01236600
            END;                                                                01236700
            IF RESET_ARRAYNESS>2 THEN CALL ERROR(CLASS_AA,1);                   01236800
            CALL HALMAT_TUPLE(XXASN(PSEUDO_TYPE(PTR(SP))),0,SP,MP,0);           01236900
ASSIGNING:                                                                      01237000
            TEMP=PSEUDO_TYPE(PTR(SP));                                          01237100
            IF TEMP=INT_TYPE THEN IF PSEUDO_FORM(PTR(SP))=XLIT THEN DO;         01237200
               TEMP2=GET_LITERAL(LOC_P(PTR(SP)));                               01237300
               IF LIT2(TEMP2)=0 THEN TEMP=0;                                    01237400
            END;                                                                01237500
            IF (SHL(1,TEMP)&ASSIGN_TYPE(PSEUDO_TYPE(PTR(MP))))=0 THEN           01237600
               CALL ERROR(CLASS_AV,1,VAR(MP));                                  01237700
            ELSE IF TEMP>0 THEN DO CASE PSEUDO_TYPE(PTR(MP));                   01237800
               ;                                                                01237900
               ; /*BIT */                                                       01238000
               /*CHAR*/                                          /*DR109083*/   01238100
               /* CHECK IF THE EXPRESSION BEING ASSIGNED TO A    /*DR109083*/
               /* CHARACTER IS SCALAR AND SHOULD BE IN DOUBLE    /*DR109083*/
               /* PRECISION (DOUBLELIT=TRUE).  IF TRUE, THEN SET /*DR109083*/
               /* LIT1 EQUAL TO 5.                               /*DR109083*/
               IF (PSEUDO_TYPE(PTR(SP))=SCALAR_TYPE) & DOUBLELIT THEN /* " */
                 LIT1(GET_LITERAL(LOC_P(PTR(SP)))) = 5;          /*DR109083*/
               CALL MATRIX_COMPARE(MP,SP,CLASS_AV,2); /*MATRIX*/                01238200
               CALL VECTOR_COMPARE(MP,SP,CLASS_AV,3); /*VECTOR*/                01238300
               ; /*SCALAR*/                                                     01238400
               ; /*INTEGER*/                                                    01238500
               ;;                                                               01238600
                  ; /*EVENT*/                                                   01238700
               CALL STRUCTURE_COMPARE(FIXL(MP),FIXL(SP),CLASS_AV,4); /* STRUC */01238800
               ;                                                                01238900
            END;                                                                01239000
END_ASSIGN:                                                                     01239100
            DOUBLELIT = FALSE;                                   /*DR109083*/
            FIXV(MP)=FIXV(SP);                                                  01239300
            PTR(MP)=PTR(SP);                                                    01239400
         END;                                                                   01239500
 /* <ASSIGNMENT>::=<VARIABLE>,<ASSIGNMENT> */                                   01239600
         DO;                                                                    01239700
            CALL HALMAT_PIP(LOC_P(PTR(MP)),PSEUDO_FORM(PTR(MP)),0,0);           01239800
            INX(PTR(SP))=INX(PTR(SP))+1;                                        01239900
            IF NAME_PSEUDOS THEN DO;                                            01240000
               CALL NAME_COMPARE(MP,SP,CLASS_AV,5,0);                           01240100
               IF COPINESS(MP,SP)>0 THEN CALL ERROR(CLASS_AA,2,VAR(MP));        01240200
               GO TO END_ASSIGN;                                                01240300
            END;                                                                01240400
            ELSE GO TO ASSIGNING;                                               01240500
         END;                                                                   01240600
                                                                                01240700
                                                                                01240800
 /* <IF STATEMENT>::= <IF CLAUSE> <STATEMENT> */                                01240900
         DO;                                                                    01241000
            CALL UNBRANCHABLE(SP,4);                                            01241100
CLOSE_IF:                                                                       01241200
            INDENT_LEVEL=FIXL(MP);                                              01241300
            CALL HALMAT_POP(XLBL,1,XCO_N,1);                                    01241400
            CALL HALMAT_PIP(FIXV(MP),XINL,0,0);                                 01241500
         END;                                                                   01241600
 /* <IF STATEMENT>::=<TRUE PART> <STATEMENT> */                                 01241700
         DO;                                                                    01241800
            CALL UNBRANCHABLE(SP,5);                                            01241900
            GO TO CLOSE_IF;                                                     01242000
         END;                                                                   01242100
 /* <TRUE PART>::=<IF CLAUSE><BASIC STATEMENT> ELSE */                          01242200
         DO;                                                                    01242300
            CALL UNBRANCHABLE(MPP1,4);                                          01242400
            CALL CHECK_IMPLICIT_T;                                              01242500
            ELSEIF_PTR = STACK_PTR(SP);                                         01242600
            /*MOVE ELSEIF_PTR TO FIRST PRINTABLE REPLACE MACRO TOKEN-111342*/
            I = ELSEIF_PTR;
            DO WHILE (I > 0) &                                   /*DR111342*/
            ((GRAMMAR_FLAGS(I-1) & MACRO_ARG_FLAG)^=0);          /*DR111342*/
               I = I - 1;                                        /*DR111342*/
               IF ((GRAMMAR_FLAGS(I) & PRINT_FLAG)^=0) THEN      /*DR111342*/
                  ELSEIF_PTR = I;                                /*DR111342*/
            END;                                                 /*DR111342*/
            IF ELSEIF_PTR > 0 THEN                      /*DR111341,DR109057*/   01242650
               IF STMT_END_PTR > -1 THEN DO;                     /*DR111341*/   01242650
                 SQUEEZING = FALSE;                              /*DR111329*/
                 CALL OUTPUT_WRITER(LAST_WRITE, ELSEIF_PTR - 1); /*DR109057*/   01242700
                 LAST_WRITE = ELSEIF_PTR;                        /*DR109057*/   01242700
            END;                                                 /*DR109057*/
            /*CR12713 - ALIGN ELSE CORRECTLY.                              */
            IF MOVE_ELSE THEN                                     /*CR12713*/
               INDENT_LEVEL=INDENT_LEVEL-INDENT_INCR;                           01242800
            MOVE_ELSE = TRUE;                                     /*CR12713*/
            CALL EMIT_SMRK;                                                     01242900
            CALL SRN_UPDATE;                                                    01243000
            /*CR12713 - PUT THE ELSE ON THE SAME LINE AS THE DO.           */
            ELSE_FLAG = TRUE;                                     /*CR12713*/
            /*DETERMINES IF ELSE WAS ALREADY PRINTED IN REPLACE MACRO-11342*/
            IF (GRAMMAR_FLAGS(ELSEIF_PTR) & PRINT_FLAG)=0 THEN   /*DR111342*/
               ELSE_FLAG = FALSE;                                /*DR111342*/
            IF NO_LOOK_AHEAD_DONE THEN CALL CALL_SCAN;            /*CR12713*/
            IF TOKEN ^= IF_TOKEN THEN DO;                         /*CR12713*/
            /*CR12713 - PRINT ELSE STATEMENTS ON SAME LINE AS A            */
            /*SIMPLE DO.  IF ELSE_FLAG IS FALSE, THEN THE ELSE STATEMENT   */
            /*WAS ALREADY PRINTED.                                         */
               IF ^ELSE_FLAG   THEN DO;                           /*CR12713*/
                  INDENT_LEVEL = INDENT_LEVEL + INDENT_INCR;      /*CR12713*/
               END;                                               /*CR12713*/
               ELSE DO;                                           /*CR12713*/
               /*CR12713 -  DO NOT CALL OUTPUT_WRITER.  SAVE VALUES        */
               /*THAT ARE NEEDED WHEN OUTPUT_WRITER WILL BE CALLED.        */
                  SAVE_SRN1 = SRN(2);                             /*CR12713*/
                  SAVE_SRN_COUNT1 = SRN_COUNT(2);                /*DR120227*/
                  SAVE1 = ELSEIF_PTR;                             /*CR12713*/
                  SAVE2 = STACK_PTR(SP);                 /*DR111342,CR12713*/
               END;                                               /*CR12713*/
            END;                                                  /*CR12713*/
            ELSE DO;                                              /*CR12713*/
               /*CR12713 - IF ELSE_FLAG IS FALSE, THEN THE ELSE STATEMENT  */
               /*WAS ALREADY PRINTED FROM PRINT_COMMENT AND INDENT_LEVEL   */
               /*SHOULD BE SET TO INDENT THE LINE FOLLOWING THE COMMENT    */
               /*OR DIRECTIVE.                                             */
               IF ^ELSE_FLAG THEN                                 /*CR12713*/
                  INDENT_LEVEL = INDENT_LEVEL + INDENT_INCR;      /*CR12713*/
               ELSE_FLAG = FALSE;                                 /*CR12713*/
               LAST_WRITE = ELSEIF_PTR;                           /*CR12713*/
            END;                                                  /*CR12713*/
            CALL HALMAT_POP(XBRA,1,0,1);                                        01243300
            CALL HALMAT_PIP(FL_NO,XINL,0,0);                                    01243400
            CALL HALMAT_POP(XLBL,1,XCO_N,0);                                    01243500
            CALL HALMAT_PIP(FIXV(MP),XINL,0,0);                                 01243600
            FIXV(MP)=FL_NO;                                                     01243700
            XSET"100";                                                          01243800
            FL_NO=FL_NO+1;                                                      01243900
         END;                                                                   01244000
 /* <IF CLAUSE>  ::=  <IF> <RELATIONAL EXP> THEN  */                            01244100
         DO;                                                                    01244200
            TEMP=LOC_P(PTR(MPP1));                                              01244300
EMIT_IF:                                                                        01244400
            CALL HALMAT_POP(XFBRA,2,XCO_N,0);                                   01244500
            CALL HALMAT_PIP(FL_NO,XINL,0,0);                                    01244600
            CALL HALMAT_PIP(TEMP,XVAC,0,0);                                     01244700
            PTR_TOP=PTR(MPP1)-1;                                                01244800
            FIXV(MP)=FL_NO;                                                     01244900
            FL_NO=FL_NO+1;                                                      01245000
            /*CR12713 - PRINT IF-THEN STATEMENTS ON SAME LINE AS A            */
            /*SIMPLE DO.  DO NOT CALL OUTPUT_WRITER.  SAVE VALUES THAT        */
            /*ARE NEEDED WHEN OUTPUT_WRITER WILL BE CALLED.                   */
            IF_FLAG = TRUE;                                          /*CR12713*/
            /*DETERMINES IF IF-THEN WAS ALREADY PRINTED IN REPLACE MACRO-11342*/
            IF (GRAMMAR_FLAGS(LAST_WRITE) & PRINT_FLAG)=0 THEN DO;  /*DR111342*/
               IF_FLAG = FALSE;                                     /*DR111342*/
               DO I=(LAST_WRITE+1) TO STACK_PTR(SP);                /*DR111342*/
                  IF (GRAMMAR_FLAGS(I) & PRINT_FLAG)^=0 THEN        /*DR111342*/
                     IF_FLAG = TRUE;                                /*DR111342*/
               END;                                                 /*DR111342*/
            END;                                                    /*DR111342*/
            IF ^IF_FLAG & (STMT_STACK(LAST_WRITE)^=ELSE_TOKEN) THEN /*DR111342*/
               INDENT_LEVEL = INDENT_LEVEL + INDENT_INCR;           /*DR111342*/
            ELSE DO;                                                /*DR111342*/
               SAVE_SRN1 = SRN(2);                                   /*CR12713*/
               SAVE_SRN_COUNT1 = SRN_COUNT(2);                      /*DR120227*/
               SAVE1 = LAST_WRITE;                                   /*CR12713*/
               SAVE2 = STACK_PTR(SP);                                /*CR12713*/
            END;                                                    /*DR111342*/
            CALL EMIT_SMRK;                                                     01245200
            XSET"200";                                                          01245300
         END;                                                                   01245500
 /*  <IF CLAUSE>  ::=  <IF> <BIT EXP> THEN  */                                  01245600
         DO;                                                                    01245700
            CALL HALMAT_TUPLE(XBTRU,0,MPP1,0,0);                                01245800
            IF PSEUDO_LENGTH(PTR(MPP1))>1 THEN CALL ERROR(CLASS_GB,1,'IF');     01245900
            TEMP=LAST_POP#;                                                     01246000
            CALL EMIT_ARRAYNESS;                                                01246100
            GO TO EMIT_IF;                                                      01246200
         END;                                                                   01246300
 /*  <IF>  ::=  IF  */                                                          01246400
         DO;                                                                    01246500
            XSET"5";                                                            01246600
            FIXL(MP)=INDENT_LEVEL;                                              01246650
            CALL HALMAT_POP(XIFHD,0,XCO_N,0);                                   01246700
         END;                                                                   01246800
 /* <DO GROUP HEAD>::= DO ; */                                                  01246900
         DO;                                                                    01247000
            XSET"11";                                                           01247100
            FIXL(MPP1)=0;                                                       01247200
            CALL HALMAT_POP(XDSMP,1,0,0);                                       01247300
            CALL EMIT_PUSH_DO(0,1,0,MP-1);                                      01247400
DO_DONE:                                                                        01247500
            FIXV(MP)=0;                                                         01247600
            CALL CHECK_IMPLICIT_T;                                              01247700
            /*CR12713 - PRINT IF-THEN/ELSE STATEMENTS ON SAME LINE AS A    */
            /*SIMPLE DO.  IF AN IF-THEN OR ELSE WAS THE PREVIOUS STATEMENT */
            /*PRINT THE DO ON THE SAME LINE USING SRN & STATEMENT NUMBER   */
            /*FROM IF-THEN OR ELSE.                                        */
            IF (IF_FLAG|ELSE_FLAG) & (PRODUCTION_NUMBER=144) THEN /*CR12713*/
            DO;                                                   /*CR12713*/
              SQUEEZING = FALSE;                                 /*DR111329*/
              SAVE_SRN2 = SRN(2);                                 /*CR12940*/
              SRN(2) = SAVE_SRN1;                                 /*CR12713*/
              SAVE_SRN_COUNT2 = SRN_COUNT(2);                    /*DR120227*/
              SRN_COUNT(2) = SAVE_SRN_COUNT1;                    /*DR120227*/
              IF IF_FLAG THEN                                     /*CR12713*/
                 STMT_NUM = STMT_NUM - 1;                         /*CR12713*/
              CALL OUTPUT_WRITER(SAVE1, STMT_PTR);                /*CR12713*/
              IF IF_FLAG THEN                                     /*CR12713*/
                 STMT_NUM = STMT_NUM + 1;                         /*CR12713*/
              IF_FLAG,ELSE_FLAG = FALSE;                          /*CR12713*/
              IFDO_FLAG(DO_LEVEL) = TRUE;                         /*CR12713*/
              SRN(2) = SAVE_SRN2;                                 /*CR12940*/
              SRN_COUNT(2) = SAVE_SRN_COUNT2;                    /*DR120227*/
            END;                                                  /*CR12713*/
            ELSE DO;                                              /*CR12713*/   01247800
              IF_FLAG,ELSE_FLAG = FALSE;                          /*CR12713*/
              CALL OUTPUT_WRITER(LAST_WRITE, STMT_PTR);           /*CR12713*/   01247800
            END;                                                  /*CR12713*/   01247800
            IF FIXL(MPP1)>0 THEN DO;                                            01247900
               CALL HALMAT_POP(XTDCL,1,0,0);                                    01248000
               CALL HALMAT_PIP(FIXL(MPP1),XSYT,0,0);                            01248100
            END;                                                                01248200
            CALL EMIT_SMRK;                                                     01248300
            INDENT_LEVEL=INDENT_LEVEL + INDENT_INCR;                            01248400
            NEST_LEVEL = NEST_LEVEL + 1;                                        01248450
         END;                                                                   01248500
 /* <DO GROUP HEAD>::= DO <FOR LIST> ; */                                       01248600
         DO;                                                                    01248700
            XSET"13";                                                           01248800
            CALL HALMAT_FIX_POPTAG(FIXV(MPP1),PTR(MPP1));                       01248900
            GO TO DO_DONE;                                                      01249000
         END;                                                                   01249100
 /* <DO GROUP HEAD>::= DO <FOR LIST> <WHILE CLAUSE> ; */                        01249200
         DO;                                                                    01249300
            XSET"13";                                                           01249400
            TEMP=PTR(SP-1);                                                     01249500
            CALL HALMAT_FIX_POPTAG(FIXV(MPP1),SHL(INX(TEMP),4)|PTR(MPP1));      01249600
            CALL HALMAT_POP(XCFOR,1,0,INX(TEMP));                               01249700
EMIT_WHILE:                                                                     01249800
            CALL HALMAT_PIP(LOC_P(TEMP),PSEUDO_FORM(TEMP),0,0);                 01249900
            PTR_TOP=TEMP-1;                                                     01250000
            GO TO DO_DONE;                                                      01250100
         END;                                                                   01250200
 /* <DO GROUP HEAD>::= DO <WHILE CLAUSE> ; */                                   01250300
         DO;                                                                    01250400
            XSET"12";                                                           01250500
            FIXL(MPP1)=0;                                                       01250600
            TEMP=PTR(MPP1);                                                     01250700
            CALL HALMAT_POP(XCTST,1,0,INX(TEMP));                               01250800
            GO TO EMIT_WHILE;                                                   01250900
         END;                                                                   01251000
 /* <DO GROUP HEAD>::= DO CASE  <ARITH EXP> ; */                                01251100
         DO;                                                                    01251200
            FIXV(MP),FIXL(MP)=0;                                                01251300
CASE_HEAD:                                                                      01251400
            XSET"14";                                                           01251500
            TEMP2=PTR(MP+2);                                                    01251600
            IF UNARRAYED_INTEGER(MP+2) THEN CALL ERROR(CLASS_GC,1);             01251700
            CALL HALMAT_POP(XDCAS,2,0,FIXL(MP));                                01251800
            CALL EMIT_PUSH_DO(2,4,0,MP-1);                                      01251900
            CALL HALMAT_PIP(LOC_P(TEMP2),PSEUDO_FORM(TEMP2),0,0);               01252000
            PTR_TOP=TEMP2-1;                                                    01252100
            CALL CHECK_IMPLICIT_T;                                              01252200
            IF FIXL(MP) THEN DO;                                                01252300
               CALL OUTPUT_WRITER(LAST_WRITE,STACK_PTR(SP)-1);                  01252400
               LAST_WRITE=STACK_PTR(SP);                                        01252500
               INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;                           01252600
               CALL EMIT_SMRK;                                                  01252700
               CALL SRN_UPDATE;                                                 01252800
               XSET"100";                                                       01252900
               CALL OUTPUT_WRITER(LAST_WRITE,LAST_WRITE);                       01253000
               INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;                           01253100
            END;                                                                01253200
            ELSE DO;                                                            01253300
               IF STMT_END_PTR > -1 THEN                        /*DR111341*/
                  CALL OUTPUT_WRITER(LAST_WRITE, STACK_PTR(SP));                01253400
               CALL EMIT_SMRK;                                                  01253500
               INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;                           01253600
               GO TO SET_CASE;                                                  01253700
            END;                                                                01253800
         END;                                                                   01253900
 /*  <DO GROUP HEAD>  ::=  <CASE ELSE>  <STATEMENT>  */                         01254000
         DO;                                                                    01254100
            CALL UNBRANCHABLE(SP,6);                                            01254200
            FIXV(MP)=0;                                                         01254300
            INDENT_LEVEL=INDENT_LEVEL-INDENT_INCR;                              01254400
SET_CASE:                                                                       01254500
            CASE_LEVEL = CASE_LEVEL +1;                /*DR109091*/             01254600
            IF CASE_LEVEL <= CASE_LEVEL_LIM THEN       /*DR109091*/
               CASE_STACK(CASE_LEVEL)=0;                                        01254700
            NEST_LEVEL = NEST_LEVEL + 1;                                        01254750
            GO TO EMIT_CASE;                                                    01254800
         END;                                                                   01254900
 /* <DO GROUP HEAD>::= <DO GROUP HEAD> <ANY STATEMENT> */                       01255000
         DO;                                                                    01255100
            FIXV(MP)=1;                                                         01255200
            IF (DO_INX(DO_LEVEL)&"7F")=2 THEN IF PTR(SP) THEN DO;               01255300
EMIT_CASE:                                                                      01255400
               INFORMATION=INFORMATION||'CASE ';                  /*CR12713*/   01255500
               IF CASE_LEVEL <= CASE_LEVEL_LIM THEN               /*DR109091*/
                  CASE_STACK(CASE_LEVEL)=CASE_STACK(CASE_LEVEL)+1;              01255600
               TEMP = 0;                                          /*DR109091*/
               DO WHILE (TEMP<CASE_LEVEL)&(TEMP<CASE_LEVEL_LIM);  /*DR109091*/  01255700
                  INFORMATION=INFORMATION||CASE_STACK(TEMP)||PERIOD;            01255800
                  TEMP = TEMP + 1;                                /*DR109091*/
               END;                                                             01255900
               INFORMATION=INFORMATION||CASE_STACK(TEMP);         /*DR109091*/  01256000
               CALL HALMAT_POP(XCLBL,2,XCO_N,0);                                01256100
               CALL HALMAT_PIP(DO_LOC(DO_LEVEL),XINL,0,0);                      01256200
               CALL HALMAT_PIP(FL_NO,XINL,0,0);                                 01256300
               FL_NO=FL_NO+2;                                                   01256400
               FIXV(MP)=LAST_POP#;                                              01256500
            END;                                                                01256600
         END;                                                                   01256700
 /*  <DO GROUP HEAD>  ::=  <DO GROUP HEAD>  <TEMPORARY STMT>  */                01256800
         DO;                                                                    01256900
            IF (DO_INX(DO_LEVEL)&"7F")=2 THEN CALL ERROR(CLASS_D,10);           01257000
            ELSE IF FIXV(MP) THEN DO;                                           01257100
               CALL ERROR(CLASS_D,7);                                           01257200
               FIXV(MP)=0;                                                      01257300
            END;                                                                01257400
            GO TO EMIT_NULL;                                                    01257500
         END;                                                                   01257600
 /*  <CASE ELSE>  ::=  DO CASE <ARITH EXP> ; ELSE  */                           01257700
         DO;                                                                    01257800
            FIXL(MP)=1;                                                         01257900
            GO TO CASE_HEAD;                                                    01258000
         END;                                                                   01258100
                                                                                01258200
 /* <WHILE KEY>::= WHILE */                                                     01258300
         DO;                                                                    01258400
            TEMP=0;                                                             01258500
WHILE_KEY:                                                                      01258600
            IF PARSE_STACK(MP-1)=DO_TOKEN THEN DO;                              01258700
               CALL HALMAT_POP(XDTST,1,XCO_N,TEMP);                             01258800
               CALL EMIT_PUSH_DO(3,3,0,MP-2);                                   01258900
            END;                                                                01259000
            FIXL(MP)=TEMP;                                                      01259100
         END;                                                                   01259200
 /* <WHILE KEY>::= UNTIL */                                                     01259300
         DO;                                                                    01259400
            TEMP=1;                                                             01259500
            GO TO WHILE_KEY;                                                    01259600
         END;                                                                   01259700
 /* <WHILE CLAUSE>::=<WHILE KEY> <BIT EXP> */                                   01259800
         DO;                                                                    01259900
            IF CHECK_ARRAYNESS THEN CALL ERROR(CLASS_GC,2);                     01260000
          IF PSEUDO_LENGTH(PTR(SP))>1 THEN CALL ERROR(CLASS_GB,1,'WHILE/UNTIL');01260100
            CALL HALMAT_TUPLE(XBTRU,0,SP,0,0);                                  01260200
            CALL SETUP_VAC(SP,BIT_TYPE);                                        01260300
DO_FLOWSET:                                                                     01260400
            INX(PTR(SP))=FIXL(MP);                                              01260500
            PTR(MP)=PTR(SP);                                                    01260600
         END;                                                                   01260700
 /* <WHILE CLAUSE>::= <WHILE KEY> <RELATIONAL EXP> */                           01260800
         GO TO DO_FLOWSET;                                                      01260900
 /* <FOR LIST>::= <FOR KEY>  <ARITH EXP><ITERATION CONTROL> */                  01261000
         DO;                                                                    01261100
            IF UNARRAYED_SIMPLE(SP-1) THEN CALL ERROR(CLASS_GC,3);              01261200
            CALL HALMAT_POP(XDFOR,TEMP2+3,XCO_N,0);                             01261300
            CALL EMIT_PUSH_DO(1,5,PSEUDO_TYPE(PTR(SP))=INT_TYPE,MP-2,FIXL(MP)); 01261400
            TEMP=PTR(MP);                                                       01261500
            DO WHILE TEMP <= PTR_TOP;                                           01261600
               CALL HALMAT_PIP(LOC_P(TEMP),PSEUDO_FORM(TEMP),0,0);              01261700
               TEMP=TEMP+1;                                                     01261800
            END;                                                                01261900
            FIXV(MP)=LAST_POP#;                                                 01262000
            PTR_TOP=PTR(MP)-1;                                                  01262100
            PTR(MP) = TEMP2 | FIXF(MP);  /* RECORD DO TYPE AND WHETHER          01262200
                                      LOOP VAR IS TEMPORARY */                  01262210
         END;                                                                   01262300
 /* <FOR LIST> = <FOR KEY>  <ITERATION BODY> */                                 01262400
         DO;                                                                    01262500
            CALL HALMAT_FIX_POPTAG(FIXV(SP),1);                                 01262600
            PTR_TOP=PTR(MP)-1;                                                  01262700
            PTR(MP) = FIXF(MP);  /* RECORD WHETHER LOOP VAR IS TEMPORARY */     01262800
         END;                                                                   01262900
                                                                                01263000
 /* <ITERATION BODY>::= <ARITH EXP> */                                          01263100
         DO;                                                                    01263200
            TEMP=PTR(MP-1);   /*<FOR KEY> PTR */                                01263300
            CALL HALMAT_POP(XDFOR,2,XCO_N,0);                                   01263400
            CALL EMIT_PUSH_DO(1,5,0,MP-3,FIXL(MP-1));                           01263500
            CALL HALMAT_PIP(LOC_P(TEMP),PSEUDO_FORM(TEMP),0,0);                 01263600
            FIXV(MP-1)=LAST_POP#; /* IN <FOR KEY> STACK ENTRY */                01263700
            GO TO DO_DISCRETE;                                                  01263800
         END;                                                                   01263900
 /* <ITERATION BODY>::= <ITERATION BODY>,<ARITH EXP> */                         01264000
         DO;                                                                    01264100
DO_DISCRETE:                                                                    01264200
            IF UNARRAYED_SIMPLE(SP) THEN CALL ERROR(CLASS_GC,3);                01264300
            PTR_TOP=PTR(SP)-1;                                                  01264400
            CALL HALMAT_TUPLE(XAFOR,XCO_N,SP,0,0);                              01264500
            FL_NO=FL_NO+1;                                                      01264600
            FIXV(MP)=LAST_POP#;                                                 01264700
         END;                                                                   01264800
 /* <ITERATION CONTROL>::= TO <ARITH EXP> */                                    01264900
         DO;                                                                    01265000
            IF UNARRAYED_SIMPLE(MPP1) THEN CALL ERROR(CLASS_GC,3);              01265100
            PTR(MP)=PTR(MPP1);                                                  01265200
            TEMP2=1;                                                            01265300
         END;                                                                   01265400
 /* <ITERATION CONTROL>::= TO <ARITH EXP> BY <ARITH EXP> */                     01265500
         DO;                                                                    01265600
            TEMP2=UNARRAYED_SIMPLE(SP);                                         01265700
            IF UNARRAYED_SIMPLE(MPP1)|TEMP2 THEN                                01265800
               CALL ERROR(CLASS_GC,3);                                          01265900
            PTR(MP)=PTR(MPP1);                                                  01266000
            TEMP2=2;                                                            01266100
         END;                                                                   01266200
 /* <FOR KEY>::= FOR <ARITH VAR> = */                                           01266300
         DO;                                                                    01266400
            CALL CHECK_ASSIGN_CONTEXT(MPP1);                                    01266500
            IF UNARRAYED_SIMPLE(MPP1) THEN CALL ERROR(CLASS_GV,1);              01266600
            PTR(MP)=PTR(MPP1);                                                  01266700
            FIXL(MP), FIXF(MP) = 0;  /* NO DO CHAIN EXISTS */                   01266800
         END;                                                                   01266900
 /*  <FOR KEY>  ::=  FOR TEMPORARY  <IDENTIFIER>  =  */                         01267000
         DO;                                                                    01267100
            ID_LOC=FIXL(MP+2);                                                  01267200
            PTR(MP)=PUSH_INDIRECT(1);                                           01267300
            LOC_P(PTR_TOP)=ID_LOC;                                              01267400
            PSEUDO_FORM(PTR_TOP)=XSYT;                                          01267500
            PSEUDO_TYPE(PTR_TOP),SYT_TYPE(ID_LOC)=INT_TYPE;                     01267600
            TEMP=DEFAULT_ATTR&SD_FLAGS;                                         01267700
            SYT_FLAGS(ID_LOC)=SYT_FLAGS(ID_LOC)|TEMP;                           01267800
            FIXL(MP),DO_CHAIN=ID_LOC;                                           01267900
            FIXF(MP) = 8;  /* DO CHAIN EXISTS FOR CURRENT DO */                 01267910
            CONTEXT=0;                                                          01268000
            FACTORING = TRUE;                                                   01268100
            IF SIMULATING THEN CALL STAB_VAR(MP);                               01268200
            CALL SET_XREF(ID_LOC,XREF_ASSIGN);                                  01268300
         END;                                                                   01268400
 /* <ENDING>::= END */                                                          01268500
         DO;                                                  /*CR12713*/
            /*CR12713 - ON END STATEMENT, REPLACE THE CURRENT SCOPE WITH   */
            /*THE STATEMENT NUMBER OF THE DO.  SET A FLAG HERE TO BE USED  */
            /*IN OUTPUT_WRITER IF THE END ISN'T IN A NON-EXPANDED          */
            /*REPLACE MACRO.                                               */
            IF ((GRAMMAR_FLAGS(STACK_PTR(SP))&PRINT_FLAG)^=0) THEN/*CR12713*/
               END_FLAG = TRUE;                                   /*CR12713*/
            /*CR12713 - USED TO ALIGN ELSE CORRECTLY                       */
            IF (DO_INX(DO_LEVEL) = 0) & IFDO_FLAG(DO_LEVEL) THEN  /*CR12713*/
               MOVE_ELSE = FALSE;                                 /*CR12713*/
            SAVE_DO_LEVEL = DO_LEVEL;                             /*CR12713*/
         END;                                                     /*CR12713*/
 /* <ENDING>::= END <LABEL> */                                                  01268700
         DO;                                                                    01268800
            /*CR12713 - ON END STATEMENT, REPLACE THE CURRENT SCOPE WITH   */
            /*THE STATEMENT NUMBER OF THE DO.  SET A FLAG HERE TO BE USED  */
            /*IN OUTPUT_WRITER IF THE END ISN'T IN A NON-EXPANDED          */
            /*REPLACE MACRO.                                               */
            IF ((GRAMMAR_FLAGS(STACK_PTR(SP))&PRINT_FLAG)^=0) THEN/*CR12713*/
               END_FLAG = TRUE;                                   /*CR12713*/
            /*CR12713 - USED TO ALIGN ELSE CORRECTLY                       */
            IF (DO_INX(DO_LEVEL) = 0) & IFDO_FLAG(DO_LEVEL) THEN  /*CR12713*/
               MOVE_ELSE = FALSE;                                 /*CR12713*/
            SAVE_DO_LEVEL = DO_LEVEL;                             /*CR12713*/
            TEMP=MP-1;                                                          01268900
            DO WHILE PARSE_STACK(TEMP)=LABEL_DEFINITION;                        01269000
               TEMP=TEMP-1;                                                     01269100
            END;                                                                01269200
            TEMP=TEMP-1;                                                        01269300
            DO WHILE PARSE_STACK(TEMP)=LABEL_DEFINITION;                        01269400
               IF FIXL(TEMP)=FIXL(SP) THEN DO;                    /*DR111366*/  01269500
                  /* CREATE AN ASSIGN XREF ENTRY FOR A LABEL THAT /*DR111366*/
                  /* IS USED ON AN END STATEMENT SO THE "NOT      /*DR111366*/
                  /* REFERENCED" MESSAGE WILL NOT BE PRINTED IN   /*DR111366*/
                  /* THE CROSS REFERENCE TABLE. THIS XREF ENTRY   /*DR111366*/
                  /* WILL BE REMOVED IN SYT_DUMP SO IT DOES NOT   /*DR111366*/
                  /* SHOW UP IN THE SDF.                          /*DR111366*/
                  CALL SET_XREF(FIXL(SP),XREF_ASSIGN);            /*DR111366*/
                  GO TO ENDING_DONE;                              /*DR111366*/
               END;                                               /*DR111366*/
               TEMP=TEMP-1;                                                     01269600
            END;                                                                01269700
            CALL ERROR(CLASS_GL,1);                                             01269800
ENDING_DONE:                                                                    01269900
         END;                                                                   01270000
 /* <ENDING>::= <LABEL DEFINITION> <ENDING> */                                  01270100
        DO;                                                       /*CR12713*/
            /*CR12713 - USED TO ALIGN ELSE CORRECTLY                       */
            IF (DO_INX(DO_LEVEL) = 0) & IFDO_FLAG(DO_LEVEL) THEN  /*CR12713*/
               MOVE_ELSE = FALSE;                                 /*CR12713*/
            SAVE_DO_LEVEL = DO_LEVEL;                             /*CR12713*/
            CALL SET_LABEL_TYPE(FIXL(MP),STMT_LABEL);                           01270200
        END;                                                      /*CR12713*/
                                                                                01270300
 /*    <ON PHRASE>  ::= ON ERROR  <SUBSCRIPT>  */                               01270400
         DO;                                                                    01270500
            CALL ERROR_SUB(1);                                                  01270600
            CALL HALMAT_POP(XERON,2,0,0);                                       01270700
            CALL HALMAT_PIP(LOC_P(PTR(MP+2)),XIMD,FIXV(MP)&"3F",0);             01270800
            CALL HALMAT_PIP(FL_NO,XINL,0,0);                                    01270900
            FIXL(MP)=FL_NO;                                                     01271000
            FL_NO=FL_NO+1;                                                      01271100
            PTR_TOP=PTR(SP)-1;                                                  01271200
            IF INX(PTR(SP)) = 0 THEN                                            01271300
               SUB_END_PTR = STACK_PTR(MP) + 1;  /* NULL SUBSCRIPT */           01271310
            CALL OUTPUT_WRITER(LAST_WRITE, SUB_END_PTR);                        01271320
            INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;                              01271400
            CALL EMIT_SMRK;                                                     01271500
            XSET"400";                                                          01271600
         END;                                                                   01271700
 /*  <ON CLAUSE>  ::=  ON ERROR <SUBSCRIPT>  SYSTEM  */                         01271800
         DO;                                                                    01271900
            FIXL(MP)=1;                                                         01272000
ON_ERROR_ACTION:                                                                01272100
            CALL ERROR_SUB(1);                                                  01272200
            PTR(MP),PTR_TOP=PTR(MP+2);                                          01272300
         END;                                                                   01272400
 /*  <ON CLAUSE>  ::=  ON ERROR <SUBSCRIPT> IGNORE  */                          01272500
         DO;                                                                    01272600
            FIXL(MP)=2;                                                         01272700
            GO TO ON_ERROR_ACTION;                                              01272800
         END;                                                                   01272900
 /*  <SIGNAL CLAUSE>  ::=  SET <EVENT VAR>  */                                  01273000
         DO;                                                                    01273100
            TEMP=1;                                                             01273200
SIGNAL_EMIT:                                                                    01273300
            IF INLINE_LEVEL>0 THEN CALL ERROR(CLASS_PP,6);                      01273400
            IF TEMP>0 THEN IF (SYT_FLAGS(FIXL(MPP1))&LATCHED_FLAG)=0 THEN       01273500
               CALL ERROR(CLASS_RT,10);                                         01273600
            CALL SET_XREF_RORS(MPP1,0,XREF_ASSIGN);                             01273700
            IF CHECK_ARRAYNESS THEN CALL ERROR(CLASS_RT,8);                     01273800
            IF SIMULATING THEN CALL STAB_VAR(MPP1);                             01273900
            PTR(MP)=PTR(MPP1);                                                  01274000
            INX(PTR(MP))=TEMP;                                                  01274100
         END;                                                                   01274200
 /*  <SIGNAL CLAUSE>  ::=  RESET <EVENT VAR>  */                                01274300
         DO;                                                                    01274400
            TEMP=2;                                                             01274500
            GO TO SIGNAL_EMIT;                                                  01274600
         END;                                                                   01274700
 /*  <SIGNAL CLAUSE>  ::= SIGNAL <EVENT VAR>  */                                01274800
         DO;                                                                    01274900
            TEMP=0;                                                             01275000
            GO TO SIGNAL_EMIT;                                                  01275100
         END;                                                                   01275200
                                                                                01275300
 /*  <FILE EXP>  ::=  <FILE HEAD>  ,  <ARITH EXP>  )  */                        01275400
         DO;                                                                    01275500
            IF FIXV(MP)>DEVICE_LIMIT THEN DO;                                   01275600
               CALL ERROR(CLASS_TD,1,''||DEVICE_LIMIT);                         01275700
               FIXV(MP)=0;                                                      01275800
            END;                                                                01275900
            IF UNARRAYED_INTEGER(SP-1) THEN CALL ERROR(CLASS_TD,2);             01276000
            CALL RESET_ARRAYNESS;                                               01276100
            PTR(MP)=PTR(SP-1);                                                  01276200
            IF UPDATE_BLOCK_LEVEL>0 THEN CALL ERROR(CLASS_UT,1);                01276300
            XSET"10";                                                           01276400
         END;                                                                   01276500
 /*  <FILE HEAD>  ::=  FILE  (  <NUMBER>  */                                    01276600
         DO;                                                                    01276700
            FIXV(MP)=FIXV(MP+2);                                                01276800
            IF INLINE_LEVEL>0 THEN CALL ERROR(CLASS_PP,5);                      01276900
            CALL SAVE_ARRAYNESS;                                                01277000
         END;                                                                   01277100
 /*  <CALL KEY>  ::=  CALL  <LABEL VAR>  */                                     01277200
         DO;                                                                    01277300
            I = FIXL(MPP1);                                                     01277400
            IF SYT_TYPE(I) = PROC_LABEL THEN IF SYT_LINK1(I) < 0 THEN           01277410
              IF DO_LEVEL<(-SYT_LINK1(I)) THEN CALL ERROR(CLASS_PL,8,VAR(MPP1));01277420
            IF SYT_LINK1(I) = 0 THEN SYT_LINK1(I) = STMT_NUM;                   01277430
            DO WHILE SYT_TYPE(I) = IND_CALL_LAB;                                01277500
               I = SYT_PTR(I);                                                  01277600
            END;                                                                01277700
            IF SYT_TYPE(I)^=PROC_LABEL THEN CALL ERROR(CLASS_DT,3,VAR(MPP1));   01277800
            IF CHECK_ARRAYNESS THEN CALL ERROR(CLASS_PL,7,VAR(MPP1));           01277900
            IF (SYT_FLAGS(I) & ACCESS_FLAG) ^= 0 THEN                           01278000
               CALL ERROR(CLASS_PS, 6, VAR(MPP1));                              01278100
            XSET"2";                                                            01278200
            FCN_ARG=0;                                                          01278300
            PTR(MP)=PTR(MPP1);                                                  01278400
            CALL SET_XREF_RORS(SP,"6000");                                      01278500
            IF INLINE_LEVEL>0 THEN CALL ERROR(CLASS_PP,7);                      01278600
         END;                                                                   01278700
                                                                                01278800
 /*  <CALL LIST> ::= <LIST EXP>  */                                             01278900
         CALL SETUP_CALL_ARG;                                                   01279000
                                                                                01279100
 /*  <CALL LIST> ::= <CALL LIST> , <LIST EXP>  */                               01279200
         CALL SETUP_CALL_ARG;                                                   01279300
                                                                                01279400
 /*  <CALL ASSIGN LIST> ::= <VARIABLE>  */                                      01279500
         IF INLINE_LEVEL=0 THEN DO;                                             01279600
ASSIGN_ARG:                                                                     01279700
            FCN_ARG=FCN_ARG+1;                                                  01279800
            CALL HALMAT_TUPLE(XXXAR,XCO_N,SP,0,0);                              01279900
            CALL HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,PSEUDO_TYPE(PTR(SP))|          01280000
               SHL(NAME_PSEUDOS,7),1);                                          01280100
            IF NAME_PSEUDOS THEN DO;                                            01280200
               CALL KILL_NAME(SP);                                              01280300
               IF EXT_P(PTR(SP))^=0 THEN CALL ERROR(CLASS_FD,7);                01280400
            END;                                                                01280500
            CALL CHECK_ARRAYNESS;                                               01280600
            H1=VAL_P(PTR(SP));                                                  01280700
            IF SHR(H1,7) THEN CALL ERROR(CLASS_FS,1);                           01280800
            IF SHR(H1,4) THEN CALL ERROR(CLASS_SV,1,VAR(SP));                   01280900
            IF (H1&"6")="2" THEN CALL ERROR(CLASS_FS,2,VAR(SP));                01281000
            PTR_TOP=PTR(SP)-1;                                                  01281100
         END;                                                                   01281200
                                                                                01281300
 /*  <CALL ASSIGN LIST> ::= <CALL ASSIGN LIST> , <VARIABLE>  */                 01281400
         GO TO ASSIGN_ARG;                                                      01281500
                                                                                01281600
 /*  <EXPRESSION> ::= <ARITH EXP>    */                                         01281700
         DO;                                                       /*DR109083*/
           EXT_P(PTR(MP))=0;                                                    01281800
           /* IF THE DECLARED VALUE IS A DOUBLE CONSTANT SCALAR OR /*DR109083*/
           /* INTEGER, THEN SET LIT1 EQUAL TO 5.                   /*DR109083*/
           IF (TYPE=SCALAR_TYPE) | (FACTORED_TYPE=SCALAR_TYPE) |   /*DR109083*/
              (TYPE=INT_TYPE) | (FACTORED_TYPE=INT_TYPE) |         /*DR109083*/
              ((TYPE=0) & (FACTORED_TYPE=0))                       /*DR109083*/
           THEN                                                    /*DR109083*/
             IF ((ATTRIBUTES & DOUBLE_FLAG) ^= 0) &                /*DR109083*/
                ((FIXV(MP-1) & CONSTANT_FLAG) ^= 0)                /*DR109083*/
             THEN                                                  /*DR109083*/
               LIT1(GET_LITERAL(LOC_P(PTR(MP)))) = 5;              /*DR109083*/
         END;                                                      /*DR109083*/
 /*  <EXPRESSION> ::= <BIT EXP>    */                                           01281900
         EXT_P(PTR(MP))=0;                                                      01282000
 /*  <EXPRESSION> ::= <CHAR EXP>    */                                          01282100
         EXT_P(PTR(MP))=0;                                                      01282200
 /*  <EXPRESSION>  ::=  <STRUCTURE EXP>  */                                     01282300
         EXT_P(PTR(MP))=0;                                                      01282400
 /*  <EXPRESSION>  ::=  <NAME EXP>  */                                          01282500
         ;                                                                      01282600
 /*  <STRUCTURE EXP>  ::=  <STRUCTURE VAR>  */                                  01282700
         CALL SET_XREF_RORS(MP);                                                01282800
 /*  <STRUCTURE EXP>  ::=  <MODIFIED STRUCT FUNC>  */                           01282900
         CALL SETUP_NO_ARG_FCN;                                                 01283000
 /*  <STRUCTURE EXP>  ::=  <STRUC INLINE DEF> <BLOCK BODY> <CLOSING> ; */       01283100
         GO TO INLINE_SCOPE;                                                    01283200
 /*  <STRUCTURE EXP>  ::=  <STRUCT FUNC HEAD>  (  <CALL LIST>  )  */            01283300
         CALL END_ANY_FCN;                                                      01283400
 /*  <STRUCT FUNC HEAD>  ::=  <STRUCT FUNC>  */                                 01283500
         IF START_NORMAL_FCN THEN CALL ASSOCIATE;                               01283600
 /* <LIST EXP> ::= <EXPRESSION>  */                                             01283700
         IF FCN_MODE(FCN_LV)^=1 THEN INX(PTR(MP))=0;                            01283800
 /*  <LIST EXP>  ::=  <ARITH EXP>  #  <EXPRESSION>  */                          01283900
         DO;                                                                    01284000
            IF FCN_MODE(FCN_LV)=2 THEN DO;                                      01284100
               IF PSEUDO_FORM(PTR(MP))^=XLIT THEN TEMP=0;                       01284200
               ELSE TEMP=MAKE_FIXED_LIT(LOC_P(PTR(MP)));                        01284300
               IF (TEMP<1)|(TEMP>LIST_EXP_LIM) THEN DO;                         01284400
                  TEMP=1;                                                       01284500
                  CALL ERROR(CLASS_EL,2);                                       01284600
               END;                                                             01284700
               INX(PTR(MP))=TEMP;                                               01284800
            END;                                                                01284900
            ELSE DO;                                                            01285000
               CALL ERROR(CLASS_EL,1);                                          01285100
               IF FCN_MODE(FCN_LV)^=1 THEN INX(PTR(MP))=1;                      01285200
               ELSE INX(PTR(MP))=INX(PTR(SP));                                  01285300
            END;                                                                01285400
            TEMP=PTR(SP);                                                       01285500
            PTR_TOP=PTR(MP);                                                    01285600
            LOC_P(PTR_TOP)=LOC_P(TEMP);                                         01285700
            PSEUDO_FORM(PTR_TOP)=PSEUDO_FORM(TEMP);                             01285800
            PSEUDO_TYPE(PTR_TOP)=PSEUDO_TYPE(TEMP);                             01285900
            PSEUDO_LENGTH(PTR_TOP)=PSEUDO_LENGTH(TEMP);                         01286000
         END;                                                                   01286100
 /*  <VARIABLE> ::= <ARITH VAR>    */                                           01286200
         IF ^DELAY_CONTEXT_CHECK THEN CALL CHECK_ASSIGN_CONTEXT(MP);            01286300
 /*  <VARIABLE> ::= <STRUCTURE VAR>    */                                       01286400
         IF ^DELAY_CONTEXT_CHECK THEN CALL CHECK_ASSIGN_CONTEXT(MP);            01286500
 /*  <VARIABLE> ::= <BIT VAR>    */                                             01286600
         IF ^DELAY_CONTEXT_CHECK THEN CALL CHECK_ASSIGN_CONTEXT(MP);            01286700
 /*  <VARIABLE  ::=  <EVENT VAR>  */                                            01286800
         DO;                                                                    01286900
          IF CONTEXT>0 THEN IF ^NAME_PSEUDOS THEN PSEUDO_TYPE(PTR(MP))=BIT_TYPE;01287000
            IF ^DELAY_CONTEXT_CHECK THEN CALL CHECK_ASSIGN_CONTEXT(MP);         01287100
            PSEUDO_LENGTH(PTR(MP))=1;                                           01287200
         END;                                                                   01287300
 /*  <VARIABLE>  ::=  <SUBBIT HEAD>  <VARIABLE>  )  */                          01287400
         DO;                                                                    01287500
            IF CONTEXT=0 THEN DO;                                               01287600
               IF SHR(VAL_P(PTR(MPP1)),7) THEN CALL ERROR(CLASS_QX,7);          01287700
               TEMP=1;                                                          01287800
            END;                                                                01287900
            ELSE TEMP=0;                                                        01288000
            CALL END_SUBBIT_FCN(TEMP);                                          01288100
            CALL SET_BI_XREF(SBIT_NDX);                             /*DR120220*/
            VAL_P(PTR(MP))=VAL_P(PTR(MPP1))|"80";                               01288200
         END;                                                                   01288300
 /*  <VARIABLE> ::= <CHAR VAR>    */                                            01288400
         IF ^DELAY_CONTEXT_CHECK THEN CALL CHECK_ASSIGN_CONTEXT(MP);            01288500
 /*  <VARIABLE>  ::=  <NAME KEY>  (  <NAME VAR>  )  */                          01288600
         DO;                                                                    01288700
            IF TEMP_SYN^=2 THEN IF CONTEXT=0 THEN TEMP_SYN=3;                   01288800
            CALL CHECK_NAMING(TEMP_SYN,MP+2);                                   01288900
            DELAY_CONTEXT_CHECK=FALSE;                                          01289000
         END;                                                                   01289100
 /*  <NAME VAR>  ::=  <VARIABLE>  */                                            01289200
         DO;                                                                    01289300
            H1=VAL_P(PTR(MP));                                                  01289400
            ARRAYNESS_FLAG=0;                                                   01289500
            IF SHR(H1,11) THEN CALL ERROR(CLASS_EN,1);                          01289600
            VAL_P(PTR(MP))=H1|"800";                                            01289700
            IF SHR(H1,7) THEN CALL ERROR(CLASS_EN,2);                           01289800
            IF (H1&"880")^=0 THEN TEMP_SYN=2;                                   01289900
            ELSE TEMP_SYN=1;                                                    01290000
         END;                                                                   01290100
 /*  <NAME VAR>  ::=  <LABEL VAR>  */                                           01290200
         DO;                                                                    01290300
            H1=SYT_TYPE(FIXL(MP));                                              01290400
            IF H1=TASK_LABEL|H1=PROG_LABEL THEN GO TO OK_LABELS;                01290500
            ELSE IF VAR(MP-2) = 'NAME' THEN         /*DR107771*/                01290600
                 CALL ERROR(CLASS_EN,4,VAR(MP));    /*DR107771*/                01290600
OK_LABELS:                                                                      01290700
            TEMP_SYN=0;                                                         01290800
         END;                                                                   01290900
 /*  <NAME VAR>  ::=  <MODIFIED ARITH FUNC>  */                                 01291000
         TEMP_SYN=0;                                                            01291100
 /*  <NAME VAR>  ::=  <MODIFIED BIT FUNC>  */                                   01291200
         TEMP_SYN=0;                                                            01291300
 /*  <NAME VAR>  ::=  <MODIFIED CHAR FUNC>  */                                  01291400
         TEMP_SYN=0;                                                            01291500
 /*  <NAME VAR>  ::=  <MODIFIED STRUCT FUNC>  */                                01291600
         TEMP_SYN=0;                                                            01291700
 /*  <NAME EXP>  ::=  <NAME KEY>  (  <NAME VAR>  )  */                          01291800
         DO;                                                                    01291900
            CALL CHECK_NAMING(TEMP_SYN,MP+2);                                   01292000
            DELAY_CONTEXT_CHECK=FALSE;                                          01292100
         END;                                                                   01292200
 /*  <NAME EXP>  ::=  NULL  */                                                  01292300
         DO;                                                                    01292400
FIX_NULL:                                                                       01292500
            PTR(MP)=PUSH_INDIRECT(1);                                           01292600
            LOC_P(PTR_TOP)=0;                                                   01292700
            PSEUDO_FORM(PTR_TOP)=XIMD;                                          01292800
            NAME_PSEUDOS=TRUE;                                                  01292900
            EXT_P(PTR_TOP)=0;                                                   01293000
            VAL_P(PTR_TOP)="500";                                               01293100
         END;                                                                   01293200
 /*  <NAME EXP>  ::=  <NAME KEY> ( NULL )  */                                   01293300
         DO;                                                                    01293400
            NAMING=FALSE;                                                       01293500
            DELAY_CONTEXT_CHECK=FALSE;                                          01293600
            GO TO FIX_NULL;                                                     01293700
         END;                                                                   01293800
 /*  <NAME KEY>  ::=  NAME  */                                                  01293900
         DO;                                                                    01294000
            NAMING,NAME_PSEUDOS=TRUE;                                           01294100
            DELAY_CONTEXT_CHECK=TRUE;                                           01294200
            ARRAYNESS_FLAG=0;                                                   01294300
         END;                                                                   01294400
 /*  <LABEL VAR>  ::=  <PREFIX>  <LABEL>  <SUBSCRIPT>  */                       01294500
         GO TO FUNC_IDS;                                                        01294600
 /*  <MODIFIED ARITH FUNC>  ::=  <PREFIX>  <NO ARG ARITH FUNC> <SUBSCRIPT>  */  01294700
         GO TO FUNC_IDS;                                                        01294800
 /*  <MODIFIED BIT FUNC>  ::=  <PREFIX>  <NO ARG BIT FUNC>  <SUBSCRIPT>  */     01294900
         GO TO FUNC_IDS;                                                        01295000
 /*  <MODIFIED CHAR FUNC>  ::=  <PREFIX> <NO ARG CHAR FUNC>  <SUBSCRIPT>  */    01295100
         GO TO FUNC_IDS;                                                        01295200
 /*  <MODIFIED STRUCT FUNC> ::= <PREFIX> <NO ARG STRUCT FUNC> <SUBSCRIPT>  */   01295300
         DO;                                                                    01295400
FUNC_IDS:                                                                       01295500
            IF FIXL(MPP1)>SYT_MAX THEN DO;                                      01295600
               IF FIXL(SP) THEN CALL ERROR(CLASS_FT,8,VAR(MPP1));               01295700
               TEMP_SYN=PSEUDO_FORM(PTR(SP));                                   01295800
               PTR_TOP=PTR(MP);                                                 01295900
               FIXL(MP)=FIXL(MPP1);                                             01296000
               VAR(MP)=VAR(MPP1);                                               01296100
            END;                                                                01296200
            ELSE DO;                                                            01296300
               FIXL(SP)=FIXL(SP)|2;                                             01296400
               GO TO MOST_IDS;                                                  01296500
            END;                                                                01296600
         END;                                                                   01296700
 /*  <STRUCTURE VAR>  ::=  <QUAL STRUCT>  <SUBSCRIPT>  */                       01296800
         DO;                                                                    01296900
            H1=PTR(MP);                                                         01297000
            GO TO STRUC_IDS;                                                    01297100
         END;                                                                   01297200
 /*  <ARITH VAR>  ::=  <PREFIX>  <ARITH ID>  <SUBSCRIPT>  */                    01297300
         GO TO MOST_IDS;                                                        01297400
 /*  <CHAR VAR>  ::=  <PREFIX>  <CHAR ID>  <SUBSCRIPT>  */                      01297500
         GO TO MOST_IDS;                                                        01297600
 /*  <BIT VAR>  ::=  <PREFIX>  <BIT ID>  <SUBSCRIPT>  */                        01297700
         GO TO MOST_IDS;                                                        01297800
 /*  <EVENT VAR>  ::=  <PREFIX>  (EVENT ID>  <SUBSCRIPT>  */                    01297900
         DO;                                                                    01298000
MOST_IDS:                                                                       01298100
            H1=PTR(MP);                                                         01298200
            PSEUDO_TYPE(H1)=SYT_TYPE(FIXL(MPP1));                               01298300
            PSEUDO_LENGTH(H1)=VAR_LENGTH(FIXL(MPP1));                           01298400
            IF FIXV(MP)=0 THEN DO;                                              01298500
               STACK_PTR(MP)=STACK_PTR(MPP1);                                   01298600
               VAR(MP)=VAR(MPP1);                                               01298700
               IF FIXV(MPP1)=0 THEN LOC_P(H1)=FIXL(MPP1);                       01298800
               ELSE FIXV(MP),LOC_P(H1)=FIXV(MPP1);                              01298900
               PSEUDO_FORM(H1)=XSYT;                                            01299000
            END;                                                                01299100
            ELSE DO;                                                            01299200
               VAR(MP)=VAR(MP)||PERIOD||VAR(MPP1);                              01299300
               TOKEN_FLAGS(EXT_P(H1))=TOKEN_FLAGS(EXT_P(H1))|"20";              01299400
               I = FIXL(MPP1);                                                  01299408
UNQ_TEST1:                                                                      01299416
               DO WHILE I > 0;                                                  01299424
                  I = SYT_LINK2(I);                                             01299432
               END;                                                             01299440
               I = -I;                                                          01299448
               IF I = 0 THEN DO;                                                01299456
                  CALL ERROR (CLASS_IS, 2, VAR(MPP1));                          01299464
                  GO TO UNQ_TEST2;                                              01299472
               END;                                                             01299480
               IF I ^= FIXL(MP) THEN GO TO UNQ_TEST1;                           01299488
UNQ_TEST2:                                                                      01299496
            END;                                                                01299500
            FIXL(MP)=FIXL(MPP1);                                                01299600
            EXT_P(H1)=STACK_PTR(MPP1);                                          01299700
STRUC_IDS:                                                                      01299800
            NAME_BIT=SHR(VAL_P(H1),1)&"80";
            TEMP_SYN=INX(H1);                                                   01300000
            TEMP3=LOC_P(H1);                                                    01300010
            IF ATTACH_SUBSCRIPT THEN DO;                                        01300100
               CALL HALMAT_TUPLE(XTSUB,0,MP,0,MAJ_STRUC|NAME_BIT);              01300200
               INX(H1)=NEXT_ATOM#-1;                                            01300300
               CALL HALMAT_FIX_PIP#(LAST_POP#,EMIT_SUBSCRIPT("8"));             01300400
               CALL SETUP_VAC(MP,PSEUDO_TYPE(H1));                              01300500
               VAL_P(H1)=VAL_P(H1)|"20";                                        01300600
            END;                                                                01300700
            PTR_TOP=H1;  /* BASH DOWN STACKS  */                                01300800
            IF FIXV(MP)>0 THEN DO;                                              01300900
               CALL HALMAT_TUPLE(XEXTN,0,MP,0,0);                               01301000
               TEMP=H1;                                                         01301100
               IF (SYT_FLAGS(TEMP3) & NAME_FLAG) ^= 0 THEN                      01301110
                  VAL_P(H1) = VAL_P(H1) | "4000";                               01301120
               H2 = FALSE;                                                      01301200

               PREV_LIVES_REMOTE=(SYT_FLAGS(TEMP3)&REMOTE_FLAG)^=0; /*DR109031*/
               PREV_POINTS=(SYT_FLAGS(TEMP3)&NAME_FLAG)^= 0;        /*DR109031*/
               PREV_REMOTE=PREV_LIVES_REMOTE;                       /*DR109031*/

               DO WHILE TEMP_SYN^=0;                                            01301300
                  TEMP=TEMP+1;                                                  01301400
                  TEMP3=LOC_P(TEMP);                                            01301500
                  CALL HALMAT_PIP(TEMP3,XSYT,0,0);                              01301510
                  H2=H2|(SYT_FLAGS(TEMP3)&NAME_FLAG)^=0;                        01301520

                  /* DR109031 - KEEP TRACK OF THE REMOTENESS -----------------*/
                  /* OF THE NODE BEING PROCESSED                      DR109031*/
                  NAME_SET = ((SYT_FLAGS(TEMP3)&NAME_FLAG) > 0);    /*DR109031*/
                  REMOTE_SET=((SYT_FLAGS(TEMP3)&REMOTE_FLAG)>0);    /*DR109031*/
                  IF (REMOTE_SET & ^NAME_SET)                       /*DR109031*/
                     | (PREV_POINTS & PREV_REMOTE)                  /*DR109031*/
                     | (PREV_LIVES_REMOTE & ^PREV_POINTS) THEN      /*DR109031*/
                     CURRENT_LIVES_REMOTE = TRUE;                   /*DR109031*/
                  ELSE                                              /*DR109031*/
                     CURRENT_LIVES_REMOTE = FALSE;                  /*DR109031*/
                  PREV_LIVES_REMOTE = CURRENT_LIVES_REMOTE;         /*DR109031*/
                  PREV_POINTS = NAME_SET;                           /*DR109031*/
                  PREV_REMOTE = REMOTE_SET;                         /*DR109031*/

                  TEMP_SYN=INX(TEMP);                                           01301700
               END;                                                             01301800
               IF H2 THEN VAL_P(H1) = VAL_P(H1) | "4000";                       01301810

               /* DR109031 - SET FLAG IN VAL_P TO INDICATE            DR109031*/
               /* THAT TERMINAL LIVES REMOTE                          DR109031*/
               IF (PREV_POINTS & PREV_REMOTE)                       /*DR109031*/
                  | (PREV_LIVES_REMOTE & ^ PREV_POINTS)             /*DR109031*/
               THEN                                                 /*DR109031*/
                  VAL_P(H1) = VAL_P(H1) | "8000";                   /*DR109031*/

               PTR_TOP=TEMP;  /* WAIT - DONT LOSE EXTN TILL XREF DONE  */       01301900
               IF VAR_LENGTH(TEMP3)=FIXL(MP) THEN DO;                           01302000
                  IF TEMP=H1 THEN VAL_P(H1)=VAL_P(H1)|"4";                      01302100
                  VAL_P(H1)=VAL_P(H1)|"1000";                                   01302200
                  CALL HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,0,1);                    01302300
                  /* PUT BACK THE CODE WHICH DR105069 DELETED. */
                  /* ALSO DELETED DR105069 FIX BELOW.          */
                  IF (SYT_FLAGS(TEMP3)&NAME_FLAG) ^=0 THEN /*DR109021*/
                     VAL_P(H1)=VAL_P(H1)|"200";            /*DR109021*/
               END;                                                             01302600
               CALL HALMAT_PIP(FIXL(MP),XSYT,0,1);                              01302700
               H2 = H2 | (SYT_FLAGS(FIXL(MP)) & NAME_FLAG) ^= 0;                01302800
               CALL HALMAT_FIX_PIP#(LAST_POP#, TEMP - H1 + 2);                  01302900
               CALL HALMAT_FIX_POPTAG(LAST_POP#, H2);                           01303000
               LOC_P(H1),H2=LAST_POP#;                                          01303100
               PSEUDO_FORM(H1)=XXPT;                                            01303200
            END;                                                                01303300
            ELSE H2=-1;                                                         01303400
            IF PSEUDO_FORM(INX)>0 THEN DO;                                      01303500
               IF FIXL(SP)>=2 THEN DO;                                          01303600
                  IF DELAY_CONTEXT_CHECK THEN DO;                               01303700
                     CALL ERROR(CLASS_EN,14);                                   01303800
                     PSEUDO_FORM(INX)=0;                                        01303900
                  END;                                                          01304000
                  ELSE TEMP_SYN=SP;                                             01304100
 /* THIS ASSUMES THAT PTR(SP) AND THE INDIRECT STACKS */                        01304110
 /* ARE NOT OVERWRITTEN UNTIL AFTER REACHING THE      */                        01304120
 /* <PRIMARY>::=<MODIFIED ARITH FUNC> PRODUCTION,     */                        01304130
 /* WHEN THAT PARSING ROUTE IS TAKEN                  */                        01304140
               END;                                                             01304200
               ELSE CALL PREC_SCALE(SP,PSEUDO_TYPE(H1));                        01304300
               IF PSEUDO_FORM(INX)>0 THEN VAL_P(H1)=VAL_P(H1)|"40";             01304800
            END;                                                                01304900
            ELSE IF IND_LINK>0 THEN DO;                                         01305000
               CALL HALMAT_TUPLE(XDSUB,0,MP,0,PSEUDO_TYPE(H1)|NAME_BIT);        01305100
               INX(H1)=NEXT_ATOM#-1;                                            01305200
               VAL_P(H1)=VAL_P(H1)|"20";                                        01305300
               CALL HALMAT_FIX_PIP#(LAST_POP#,EMIT_SUBSCRIPT("0"));             01305400
               CALL SETUP_VAC(MP,PSEUDO_TYPE(H1));                              01305500
            END;                                                                01305600
            FIXF(MP)=PTR_TOP;  /* RECORD WHERE TOP IS IN CASE CHANGED */        01305700
            CALL ASSOCIATE(H2);                                                 01305800
         END;                                                                   01305900
 /*  <QUAL STRUCT>  ::=  <STRUCTURE ID>  */                                     01306000
         DO;                                                                    01306100
            PTR(MP)=PUSH_INDIRECT(1);                                           01306200
            PSEUDO_TYPE(PTR_TOP)=MAJ_STRUC;                                     01306300
            EXT_P(PTR_TOP)=STACK_PTR(SP);                                       01306400
            IF FIXV(MP)=0 THEN DO;                                              01306500
               FIXV(MP)=FIXL(MP);                                               01306600
               FIXL(MP)=VAR_LENGTH(FIXL(MP));                                   01306700
               CALL SET_XREF(FIXL(MP), XREF_REF);                               01306750
            END;                                                                01306800
            LOC_P(PTR_TOP)=FIXV(MP);                                            01306900
            INX(PTR_TOP)=0;                                                     01307000
            VAL_P(PTR_TOP)=SHL(NAMING,8);                                       01307100
            PSEUDO_FORM(PTR_TOP)=XSYT;                                          01307200
         END;                                                                   01307300
 /*  <QUAL STRUCT>  ::=  <QUAL STRUCT>  .  <STRUCTURE ID>  */                   01307400
         DO;                                                                    01307500
            TEMP=VAR_LENGTH(FIXL(SP));                                          01307600
            IF TEMP>0 THEN DO;                                                  01307700
               CALL PUSH_INDIRECT(1);                                           01307800
               LOC_P(PTR_TOP)=FIXL(SP);                                         01307900
               INX(PTR_TOP-1)=1;                                                01308000
               INX(PTR_TOP)=0;                                                  01308100
               CALL SET_XREF(TEMP, XREF_REF);                                   01308150
               FIXL(MP)=TEMP;                                                   01308200
            END;                                                                01308300
            ELSE FIXL(MP)=FIXL(SP);                                             01308400
            VAR(MP)=VAR(MP)||PERIOD||VAR(SP);                                   01308500
            TOKEN_FLAGS(STACK_PTR(MPP1)) = TOKEN_FLAGS(STACK_PTR(MPP1)) | "20"; 01308600
            TOKEN_FLAGS(EXT_P(PTR(MP)))=TOKEN_FLAGS(EXT_P(PTR(MP)))|"20";       01308700
            EXT_P(PTR(MP))=STACK_PTR(SP);                                       01308800
         END;                                                                   01308900
 /*  <PREFIX>  ::=  <EMPTY>  */                                                 01309000
         DO;                                                                    01309100
            PTR(MP)=PUSH_INDIRECT(1);                                           01309200
            VAL_P(PTR_TOP)=SHL(NAMING,8);                                       01309300
            INX(PTR_TOP)=0;                                                     01309400
            FIXL(MP),FIXV(MP)=0;                                                01309500
         END;                                                                   01309600
 /*  <PREFIX>  ::=  <QUAL STRUCT>  .  */                                        01309700
         DO;                                                                    01309800
            TOKEN_FLAGS(STACK_PTR(SP))=TOKEN_FLAGS(STACK_PTR(SP))|"20";         01309900
         END;                                                                   01310000
 /* <SUBBIT HEAD>::= <SUBBIT KEY> <SUBSCRIPT>(  */                              01310100
         DO;                                                                    01310200
            PTR(MP),TEMP=PTR(MPP1);                                             01310300
            LOC_P(TEMP)=0;                                                      01310400
            IF INX(TEMP)>0 THEN DO;                                             01310500
          IF PSEUDO_LENGTH(TEMP)>=0|VAL_P(TEMP)>=0 THEN CALL ERROR(CLASS_QS,12);01310600
               IF PSEUDO_FORM(TEMP)^=0 THEN CALL ERROR(CLASS_QS,13);            01310700
               IF INX(TEMP)^=1 THEN DO;                                         01310800
                  INX(TEMP)=1;                                                  01310900
                  CALL ERROR(CLASS_QS,11);                                      01311000
               END;                                                             01311100
            END;                                                                01311200
         END;                                                                   01311300
 /* <SUBBIT KEY> ::= SUBBIT */                                                  01311400
         DO;                                                                    01311500
            NAMING=FALSE;                                                       01311600
            VAR(MP)='SUBBIT PSEUDO-VARIABLE';                                   01311700
         END;                                                                   01311800
 /*  <SUBSCRIPT> ::= <SUB HEAD> )    */                                         01311900
         DO;                                                                    01312000
            SUB_END_PTR = STMT_PTR;                                             01312010
            IF SUB_SEEN=0 THEN CALL ERROR(CLASS_SP,6);                          01312100
            GO TO SS_CHEX;                                                      01312200
         END;                                                                   01312300
 /*  <SUBSCRIPT>  ::=  <QUALIFIER>  */                                          01312400
         DO;                                                                    01312500
            SUB_END_PTR = STMT_PTR;                                             01312510
            SUB_COUNT=0;                                                        01312600
            FIXL(MP)=0;                                                         01312700
            STRUCTURE_SUB_COUNT=0;                                              01312800
            ARRAY_SUB_COUNT=0;                                                  01312900
         END;                                                                   01313000
 /* <SUBSCRIPT> ::= <$> <NUMBER>  */                                            01313100
         DO;                                                                    01313200
            SUB_END_PTR = STMT_PTR;                                             01313210
            PTR(SP)=PUSH_INDIRECT(1);                                           01313300
            LOC_P(PTR(SP))=FIXV(SP);                                            01313400
            PSEUDO_FORM(PTR(SP))=XIMD;                                          01313500
            PSEUDO_TYPE(PTR(SP))=INT_TYPE;                                      01313600
SIMPLE_SUBS:                                                                    01313700
            INX(PTR(SP))=1;                                                     01313800
            VAL_P(PTR(SP))=0;                                                   01313900
            SUB_COUNT=1;                                                        01314000
            ARRAY_SUB_COUNT=-1;                                                 01314100
            STRUCTURE_SUB_COUNT=-1;                                             01314200
            GO TO SS_CHEX;                                                      01314300
         END;                                                                   01314400
 /* <SUBSCRIPT> ::= <$> <ARITH VAR>  */                                         01314500
         DO;                                                                    01314600
            SUB_END_PTR = STMT_PTR;                                             01314610
            CALL IORS(SP);                                                      01314700
            CALL SET_XREF_RORS(MPP1);                                           01314800
            GO TO SIMPLE_SUBS;                                                  01314900
         END;                                                                   01315000
 /*  <SUBSCRIPT>  ::=  <EMPTY>  */                                              01315100
         DO;                                                                    01315200
            FIXL(MP)=0;                                                         01315300
            GO TO SS_FIXUP;                                                     01315400
         END;                                                                   01315500
 /*  <SUB START>  ::=  <$> (  */                                                01315600
         DO;                                                                    01315700
SUB_START:                                                                      01315800
            SUB_COUNT=0;                                                        01315900
            STRUCTURE_SUB_COUNT=-1;                                             01316000
            ARRAY_SUB_COUNT=-1;                                                 01316100
            SUB_SEEN=0;                                                         01316200
         END;                                                                   01316300
 /*  <SUB START>  ::=  <$>  (  @  <PREC SPEC>  ,  */                            01316400
         DO;                                                                    01316500
            PSEUDO_FORM(PTR(MP))=PTR(MP+3);                                     01316600
            GO TO SUB_START;                                                    01316700
         END;                                                                   01316800
 /*  <SUB START> ::= <SUB HEAD> ;    */                                         01316900
         DO;                                                                    01317000
            IF STRUCTURE_SUB_COUNT>=0 THEN CALL ERROR(CLASS_SP,1);              01317100
            IF SUB_SEEN THEN STRUCTURE_SUB_COUNT=SUB_COUNT;                     01317200
            ELSE CALL ERROR(CLASS_SP,4);                                        01317300
            SUB_SEEN=1;                                                         01317400
         END;                                                                   01317500
 /*  <SUB START> ::= <SUB HEAD> :    */                                         01317600
         DO;                                                                    01317700
            IF STRUCTURE_SUB_COUNT=-1 THEN STRUCTURE_SUB_COUNT=0;               01317800
            IF ARRAY_SUB_COUNT>=0 THEN CALL ERROR(CLASS_SP,2);                  01317900
            IF SUB_SEEN THEN ARRAY_SUB_COUNT=SUB_COUNT-STRUCTURE_SUB_COUNT;     01318000
            ELSE CALL ERROR(CLASS_SP,3);                                        01318100
            SUB_SEEN=1;                                                         01318200
         END;                                                                   01318300
 /*  <SUB START> ::= <SUB HEAD> ,    */                                         01318400
         DO ;                                                                   01318500
            IF SUB_SEEN THEN ;                                                  01318600
            ELSE CALL ERROR(CLASS_SP,5);                                        01318700
            SUB_SEEN=0;                                                         01318800
         END ;                                                                  01318900
 /*  <SUB HEAD> ::= <SUB START>    */                                           01319000
         IF SUB_SEEN THEN SUB_SEEN=2;                                           01319100
 /*  <SUB HEAD> ::= <SUB START> <SUB>    */                                     01319200
         DO ;                                                                   01319300
            SUB_SEEN=1;                                                         01319400
            SUB_COUNT = SUB_COUNT + 1 ;                                         01319500
         END ;                                                                  01319600
                                                                                01319700
 /*  <SUB> ::= <SUB EXP>    */                                                  01319800
         INX(PTR(MP))=1;                                                        01319900
 /* <SUB> ::= *     */                                                          01320000
         DO;                                                                    01320100
            PTR(MP)=PUSH_INDIRECT(1);                                           01320200
            INX(PTR(MP))=0;                                                     01320300
            PSEUDO_FORM(PTR(MP))=XAST;                                          01320400
            PSEUDO_TYPE(PTR(MP))=0;                                             01320500
            VAL_P(PTR(MP))=0;                                                   01320600
            LOC_P(PTR(MP))=0;                                                   01320700
         END;                                                                   01320800
 /* <SUB> ::= <SUB RUN HEAD><SYB EXP>   */                                      01320900
         DO;                                                                    01321000
            INX(PTR(MP))=2;                                                     01321100
            INX(PTR(SP))=2;                                                     01321200
         END;                                                                   01321300
 /* <SUB> ::= <ARITH EXP> AT <SUB EXP>  */                                      01321400
         DO;                                                                    01321500
            CALL IORS(MP);                                                      01321600
            INX(PTR(MP))=3;                                                     01321700
            INX(PTR(SP))=3;                                                     01321800
            VAL_P(PTR(MP))=0;                                                   01321900
            PTR(MPP1)=PTR(SP);                                                  01322000
         END;                                                                   01322100
 /* <SUB RUN HEAD> ::= <SUB EXP> TO */                                          01322200
         ;                                                                      01322300
 /* <SUB EXP> ::= <ARITH EXP>  */                                               01322400
         DO;                                                                    01322500
            CALL IORS(MP);                                                      01322600
            VAL_P(PTR(MP))=0;                                                   01322700
         END;                                                                   01322800
 /* <SUB EXP> ::= <# EXPRESSION>  */                                            01322900
         DO;                                                                    01323000
            IF FIXL(MP)=1 THEN DO;                                              01323100
               PTR(MP)=PUSH_INDIRECT(1);                                        01323200
               PSEUDO_FORM(PTR(MP))=0; /*  MUSNT FALL IN LIT OR VAC  */         01323300
               PSEUDO_TYPE(PTR(MP))=INT_TYPE;                                   01323400
            END;                                                                01323500
            VAL_P(PTR(MP))=FIXL(MP);                                            01323600
         END;                                                                   01323700
 /*  <# EXPRESSION>  ::=  #  */                                                 01323800
         FIXL(MP)=1;                                                            01323900
 /* <# EXPRESSION> ::= <# EXPRESSION> + <TERM> */                               01324000
         DO;                                                                    01324100
            TEMP=0;                                                             01324200
SHARP_EXP:                                                                      01324300
            CALL IORS(SP);                                                      01324400
            IF FIXL(MP)=1 THEN DO;                                              01324500
               FIXL(MP)=TEMP+2;                                                 01324600
               PTR(MP)=PTR(SP);                                                 01324700
            END;                                                                01324800
            ELSE DO;                                                            01324900
               IF FIXL(MP)=3 THEN TEMP=1-TEMP;                                  01325000
               CALL ADD_AND_SUBTRACT(TEMP);                                     01325100
            END;                                                                01325200
         END;                                                                   01325300
 /* <# EXPRESSION> ::= <# EXPRESSION> -1 <TERM>  */                             01325400
         DO;                                                                    01325500
            TEMP=1;                                                             01325600
            GO TO SHARP_EXP;                                                    01325700
         END;                                                                   01325800
                                                                                01325900
 /* <=1> ::= = */                                                               01326000
         DO;                                                                    01326100
            IF ARRAYNESS_FLAG THEN CALL SAVE_ARRAYNESS;                         01326200
            ARRAYNESS_FLAG=0;                                                   01326300
         END;                                                                   01326400
                                                                                01326500
 /* <$> ::= $  */                                                               01326600
         DO;                                                                    01326700
            FIXL(MP)=1;                                                         01326800
SS_FIXUP:                                                                       01326900
            TEMP=FIXF(MP-1);                                                    01327000
            IF TEMP>0 THEN DO;                                                  01327100
               CALL HALMAT_POP(XXXST,1,XCO_N,TEMP+FCN_LV-1);                    01327200
               CALL HALMAT_PIP(FIXL(MP-1),XSYT,0,0);                            01327300
            END;                                                                01327400
            NAMING=FALSE;                                                       01327500
            IF SUBSCRIPT_LEVEL=0 THEN DO;                                       01327600
               IF ARRAYNESS_FLAG THEN CALL SAVE_ARRAYNESS;                      01327700
               SAVE_ARRAYNESS_FLAG=ARRAYNESS_FLAG;                              01327800
               ARRAYNESS_FLAG=0;                                                01327900
            END;                                                                01328000
            SUBSCRIPT_LEVEL=SUBSCRIPT_LEVEL+FIXL(MP);                           01328100
            PTR(MP)=PUSH_INDIRECT(1);                                           01328200
            PSEUDO_FORM(PTR_TOP)=0;                                             01328300
            LOC_P(PTR_TOP),INX(PTR_TOP)=0;                                      01328400
         END;                                                                   01328500
 /* <AND> ::= &  */                                                             01328600
 /* <AND> ::= AND  */                                                           01328700
 /* <OR> ::= |  */                                                              01328800
 /* <OR> ::= OR  */                                                             01328900
         ;;;;                                                                   01329000
 /* <NOT> ::= ^  */                                                             01329100
 /* <NOT> ::= NOT  */                                                           01329200
            ;;                                                                  01329300
                                                                                01329400
 /* <CAT> ::= || */                                                             01329500
 /* <CAT> ::= CAT */                                                            01329600
            ; ;                                                                 01329700
                                                                                01329800
 /*  <QUALIFIER>  ::=  <$>  (  @  <PREC SPEC>  )  */                            01329900
            DO;                                                                 01330000
            PSEUDO_FORM(PTR(MP))=PTR(MP+3);                                     01330100
            GO TO SS_CHEX;                                                      01330200
         END;                                                                   01330300
 /*  <QUALIFIER> ::= <$> ( <SCALE HEAD> <ARITH EXP> )  */                       01330302
         DO;                                                                    01330304
            PSEUDO_FORM(PTR(MP))="F0";                                          01330306
            INX(PTR(SP-1))=PTR(SP-2);                                           01330308
            GO TO SS_CHEX;                                                      01330310
         END;                                                                   01330312
 /*<QUALIFIER>::=<$>(@<PREC SPEC>,<SCALE HEAD><ARITH EXP>)*/                    01330314
         DO;                                                                    01330316
            PSEUDO_FORM(PTR(MP))="F0"|PTR(MP+3);                                01330318
            INX(PTR(SP-1))=PTR(SP-2);                                           01330320
            GO TO SS_CHEX;                                                      01330322
         END;                                                                   01330324
 /*  <SCALE HEAD>  ::=  @  */                                                   01330326
         PTR(MP)=0;                                                             01330328
 /*  <SCALE HEAD> ::=  @ @ */                                                   01330330
         PTR(MP)=1;                                                             01330332
 /* <BIT QUALIFIER> ::= <$(> @ <RADIX> )  */                                    01330400
         DO;                                                                    01330500
            IF TEMP3=0 THEN TEMP3=2;                                            01330600
            PSEUDO_FORM(PTR(MP))=TEMP3;                                         01330700
SS_CHEX:                                                                        01330800
            IF SUBSCRIPT_LEVEL > 0 THEN                                         01330850
               SUBSCRIPT_LEVEL=SUBSCRIPT_LEVEL-1;                               01330900
         END;                                                                   01331000
                                                                                01331100
 /*  <RADIX> ::= HEX    */                                                      01331200
         TEMP3=4;                                                               01331300
 /*  <RADIX> ::= OCT    */                                                      01331400
         TEMP3=3;                                                               01331500
 /*  <RADIX> ::= BIN    */                                                      01331600
         TEMP3=1;                                                               01331700
 /* <RADIX> ::= DEC  */                                                         01331800
         TEMP3=0;                                                               01331900
 /*  <BIT CONST HEAD> ::= <RADIX>    */                                         01332000
         FIXL(MP)=1;                                                            01332100
 /*  <BIT CONST HEAD>  ::=  <RADIX>  (  <NUMBER>  )  */                         01332200
         DO;                                                                    01332300
            TOKEN_FLAGS(STACK_PTR(SP)) = TOKEN_FLAGS(STACK_PTR(SP)) | "20";     01332400
            IF FIXV(MP+2)=0 THEN DO;                                            01332500
               CALL ERROR(CLASS_LB,8);                                          01332600
               FIXL(MP)=1;                                                      01332700
            END;                                                                01332800
            ELSE FIXL(MP)=FIXV(MP+2);                                           01332900
         END;                                                                   01333000
 /*  <BIT CONST> ::= <BIT CONST HEAD> <CHAR STRING>    */                       01333100
         DO;                                                                    01333200
            S = VAR(SP);                                                        01333300
            I = 1;                                                              01333400
            K = LENGTH(S);                                                      01333500
            L=FIXL(MP);                                                         01333600
            TEMP_SYN = 0;  /*  START WITH VALUE CALC. = O  */                   01333700
            DO CASE TEMP3;                                                      01333800
               DO;                                                              01333900
                  C = 'D';                                                      01334000
                  IF L ^= 1 THEN                                                01334100
                     DO;                                                        01334200
                     CALL ERROR(CLASS_LB,2);                                    01334300
                     L = 1;                                                     01334400
                  END;                                                          01334500
                  TEMP2 = 0;  /*  INDICATE START FROM 1ST CHAR  */              01334600
                  IF SUBSTR(S, TEMP2) > '2147483647' THEN DO;                   01335200
                     CALL ERROR(CLASS_LB,1);                                    01335300
                     GO TO DO_BIT_CONSTANT_END;                                 01335400
                  END;                                                          01335500
                DO TEMP = TEMP2 TO LENGTH(S) - 1;  /*  CHECK FOR CHAR 1 TO 9  */01335600
                     H1=BYTE(S,TEMP);                                           01335700
                     IF ^((H1>=BYTE('0'))&(H1<=BYTE('9'))) THEN DO;             01335800
                        CALL ERROR(CLASS_LB,4);                                 01335900
                        TEMP_SYN = 0;                                           01336000
                        GO TO DO_BIT_CONSTANT_END;                              01336100
                     END;                                                       01336200
                     ELSE DO;                                                   01336300
                        TEMP_SYN = TEMP_SYN * 10;  /*  ADD IN NEXT DIGIT  */    01336400
                        TEMP_SYN=TEMP_SYN+(H1&"0F");                            01336500
                     END;                                                       01336600
                  END;  /*  END OF DO FOR  */                                   01336700
                  I = 1;                                                        01337000
                  DO WHILE SHR(TEMP_SYN, I) ^= 0;                               01337100
                     I = I + 1;                                                 01337200
                  END;                                                          01337300
                  GO TO DO_BIT_CONSTANT_END;                                    01337400
               END;  /*  END OF CASE 0  */                                      01337500
 /* CASE 1, BIN  */                                                             01337600
               DO;                                                              01337700
                  C = 'B';                                                      01337800
                  DO TEMP = 0 TO LENGTH(S)-1;  /*  CHECK FOR '0' OR '1'  */     01337900
                     H1=BYTE(S,TEMP);                                           01338000
                     IF ^((H1=BYTE('0'))|(H1=BYTE('1'))) THEN DO;               01338100
                        CALL ERROR(CLASS_LB,5);                                 01338200
                        TEMP_SYN = 0;                                           01338300
                        GO TO DO_BIT_CONSTANT_END;                              01338400
                     END;                                                       01338500
                     ELSE DO;                                                   01338600
                        TEMP_SYN = SHL(TEMP_SYN,1);  /*  ADDIN NEXT VALUE  */   01338700
                        TEMP_SYN=TEMP_SYN|(H1&"0F");                            01338800
                     END;                                                       01338900
                  END;                                                          01339000
               END;  /*  END OF CASE 1  */                                      01339100
 /* CASE 2, NO RADIX BASE 2 AT MOMENT  */                                       01339200
               ;                                                                01339300
 /* CASE 3, OCT  */                                                             01339400
               DO;                                                              01339500
                  C = 'O';                                                      01339600
                 DO TEMP = 0 TO LENGTH(S)-1;  /*  CHECK FOR OCTAL CHARACTERS  */01339700
                     H1=BYTE(S,TEMP);                                           01339800
                     IF ^((H1>=BYTE('0'))&(H1<=BYTE('7'))) THEN DO;             01339900
                        CALL ERROR(CLASS_LB,6);                                 01340000
                        TEMP_SYN = 0;                                           01340100
                        GO TO DO_BIT_CONSTANT_END;                              01340200
                     END;                                                       01340300
                     ELSE DO;                                                   01340400
                        TEMP_SYN = SHL(TEMP_SYN,3);  /*  ADD IN NEXT VALUE  */  01340500
                        TEMP_SYN=TEMP_SYN|(H1&"0F");                            01340600
                     END;                                                       01340700
                  END;                                                          01340800
               END;  /*  END OF CASE 3  */                                      01340900
 /* CASE 4, HEX  */                                                             01341000
               DO;                                                              01341100
                  C = 'H';                                                      01341200
           DO TEMP = 0 TO LENGTH(S)-1;  /*  CHECK FOR HEXADECIMAL CHARACTERS  */01341300
                     H1=BYTE(S,TEMP);                                           01341400
                     IF ^((H1>=BYTE('0'))&(H1<=BYTE('9'))) THEN DO;             01341500
                        IF ^((H1>=BYTE('A'))&(H1<=BYTE('F'))) THEN DO;          01341600
                           CALL ERROR(CLASS_LB,7);                              01341700
                           TEMP_SYN = 0;                                        01341800
                           GO TO DO_BIT_CONSTANT_END;                           01341900
                        END;                                                    01342000
                        ELSE DO;                                                01342100
                   TEMP_SYN = SHL(TEMP_SYN,4);  /*  GET NEW VAL WITH NUM.DIG. */01342200
                           TEMP_SYN=TEMP_SYN+9+(H1&"0F");                       01342300
                        END;                                                    01342400
                     END;                                                       01342500
                     ELSE DO;                                                   01342600
                        TEMP_SYN = SHL(TEMP_SYN,4);  /*  ADD IN NUM. VALUE  */  01342700
                        TEMP_SYN=TEMP_SYN+(H1&"0F");                            01342800
                     END;                                                       01342900
                  END;                                                          01343000
               END;  /* OF CASE 4 */                                            01343100
            END;  /*  END OF DO CASE  */                                        01343200
 /*  INCORPORATE REPETITION FACTOR */                                           01343300
            TEMP2=TEMP_SYN;                                                     01343400
            J=TEMP3*K;                                                          01343500
            DO TEMP=2 TO L;                                                     01343600
               TEMP_SYN=SHL(TEMP_SYN,J)|TEMP2;                                  01343700
            END;                                                                01343800
            I=J*L;                                                              01343900
            IF I>BIT_LENGTH_LIM THEN DO;                                        01344000
               IF I-TEMP3 < BIT_LENGTH_LIM THEN DO;                             01344100
                  H1 = BYTE(S);                                                 01344110
                  IF H1 >= BYTE('A') & H1 <= BYTE('F') THEN H1 = H1 + 9;        01344120
                  H1 = H1 & "0F";                                               01344130
                  IF SHR(H1,BIT_LENGTH_LIM+TEMP3-I) ^= 0 THEN                   01344140
                     CALL ERROR(CLASS_LB,1);                                    01344150
               END;                                                             01344160
               ELSE CALL ERROR(CLASS_LB,1);                                     01344170
               I=BIT_LENGTH_LIM;                                                01344200
            END;                                                                01344300
DO_BIT_CONSTANT_END :                                                           01344400
            PTR(MP)=PUSH_INDIRECT(1);                                           01344500
            PSEUDO_TYPE(PTR(MP)) = BIT_TYPE;                                    01344600
            PSEUDO_FORM(PTR(MP)) = XLIT;                                        01344700
            PSEUDO_LENGTH(PTR(MP)) = I;                                         01344800
            LOC_P(PTR(MP))=SAVE_LITERAL(2,TEMP_SYN,I);                          01344900
         END;                                                                   01345000
                                                                                01345100
 /* <BIT CONST> ::= TRUE  */                                                    01345200
         DO;                                                                    01345300
            TEMP_SYN=1;                                                         01345400
DO_BIT_CONST:                                                                   01345500
            I=1;                                                                01345600
            GO TO DO_BIT_CONSTANT_END;                                          01345700
         END;                                                                   01345800
 /* <BIT CONST> ::= FALSE  */                                                   01345900
         DO;                                                                    01346000
            TEMP_SYN=0;                                                         01346100
            GO TO DO_BIT_CONST;                                                 01346200
         END;                                                                   01346300
 /* <BIT CONST> ::= ON  */                                                      01346400
         DO;                                                                    01346500
            TEMP_SYN=1;                                                         01346600
            GO TO DO_BIT_CONST;                                                 01346700
         END;                                                                   01346800
 /* <BIT CONST> ::= OFF  */                                                     01346900
         DO;                                                                    01347000
            TEMP_SYN=0;                                                         01347100
            GO TO DO_BIT_CONST;                                                 01347200
         END;                                                                   01347300
 /*  <CHAR CONST>  ::=  <CHAR STRING>  */                                       01347400
         DO;                                                                    01347500
CHAR_LITS:                                                                      01347600
            PTR(MP)=PUSH_INDIRECT(1);                                           01347700
            LOC_P(PTR(MP))=SAVE_LITERAL(0,VAR(MP));                             01347800
            PSEUDO_FORM(PTR(MP))=XLIT;                                          01347900
            PSEUDO_TYPE(PTR(MP))=CHAR_TYPE;                                     01348000
            PSEUDO_LENGTH(PTR(MP))=LENGTH(VAR(MP));  /*DR111376*/
         END;                                                                   01348100
 /*  <CHAR CONST>  ::=  CHAR  (  <NUMBER>  )  <CHAR STRING>  */                 01348200
         DO;                                                                    01348300
         TOKEN_FLAGS(STACK_PTR(SP - 1)) = TOKEN_FLAGS(STACK_PTR(SP - 1)) | "20";01348400
            VAR(MP)=VAR(SP);                                                    01348500
            TEMP=FIXV(MP+2);                                                    01348600
            IF TEMP<1 THEN CALL ERROR(CLASS_LS,2);                              01348700
            ELSE DO WHILE TEMP>1;                                               01348800
               TEMP=TEMP-1;                                                     01348900
               TEMP2=CHAR_LENGTH_LIM-LENGTH(VAR(MP));                           01349000
               IF TEMP2<FIXV(SP) THEN DO;                                       01349100
                  TEMP=0;                                                       01349200
                  CALL ERROR(CLASS_LS,1);                                       01349300
                  S=SUBSTR(VAR(SP),0,TEMP2);                                    01349400
                  VAR(MP)=VAR(MP)||S;                                           01349500
               END;                                                             01349600
               ELSE VAR(MP)=VAR(MP)||VAR(SP);                                   01349700
            END;                                                                01349800
            GO TO CHAR_LITS;                                                    01349900
         END;                                                                   01350000
 /*  <IO CONTROL>  ::=  SKIP  (  <ARITH EXP>  )  */                             01350100
         DO;                                                                    01350200
            TEMP=3;                                                             01350300
IO_CONTROL:                                                                     01350400
            IF UNARRAYED_INTEGER(SP-1) THEN CALL ERROR(CLASS_TC,1);             01350500
            VAL_P(PTR(MP))=0;                                                   01350600
            PTR(MP)=PTR(SP-1);                                                  01350700
         END;                                                                   01350800
 /*  <IO CONTROL>  ::=  TAB  (  <ARITH EXP>  )  */                              01350900
         DO;                                                                    01351000
            TEMP=1;                                                             01351100
            GO TO IO_CONTROL;                                                   01351200
         END;                                                                   01351300
 /*  <IO CONTROL>  ::=  COLUMN  (  <ARITH EXP>  )  */                           01351400
         DO;                                                                    01351500
            TEMP=2;                                                             01351600
            GO TO IO_CONTROL;                                                   01351700
         END;                                                                   01351800
 /*  <IO CONTROL>  ::=  LINE  (  <ARITH EXP>  )  */                             01351900
         DO;                                                                    01352000
            TEMP=4;                                                             01352100
            GO TO IO_CONTROL;                                                   01352200
         END;                                                                   01352300
 /*  <IO CONTROL>  ::=  PAGE  (  <ARITH EXP>  )  */                             01352400
         DO;                                                                    01352500
            TEMP=5;                                                             01352600
            GO TO IO_CONTROL;                                                   01352700
         END;                                                                   01352800
 /*  <READ PHRASE>  ::=  <READ KEY>  <READ ARG>  */                             01352900
         DO;                                                                    01353000
CHECK_READ:                                                                     01353100
            IF INX(PTR(MP))=0 THEN DO;                                          01353200
               IF SHR(VAL_P(PTR(SP)),7) THEN CALL ERROR(CLASS_T,3);             01353300
               IF PSEUDO_TYPE(PTR(SP))=EVENT_TYPE THEN CALL ERROR(CLASS_T,2);   01353400
            END;                                                                01353500
            ELSE IF TEMP>0 THEN ;                                               01353600
            ELSE IF READ_ALL_TYPE(SP) THEN CALL ERROR(CLASS_T,1);               01353700
         END;                                                                   01353800
 /*  <READ PHRASE>  ::=  <READ PHRASE>  ,  <READ ARG>  */                       01353900
         GO TO CHECK_READ;                                                      01354000
 /*  <WRITE PHRASE>  ::=  <WRITE KEY>  <WRITE ARG>  */                          01354100
         ;                                                                      01354200
 /*  <WRITE PHRASE>  ::=  <WRITE PHRASE>  ,  <WRITE ARG>  */                    01354300
         ;                                                                      01354400
 /*  <READ ARG>  ::=  <VARIABLE>  */                                            01354500
         DO;                                                                    01354600
            TEMP=0;                                                             01354700
EMIT_IO_ARG:                                                                    01354800
            IF KILL_NAME(MP) THEN CALL ERROR(CLASS_T,5);                        01354900
            IF INLINE_LEVEL>0 THEN CALL ERROR(CLASS_PP,5);                      01355000
            CALL HALMAT_TUPLE(XXXAR,XCO_N,MP,0,0);                              01355100
            CALL HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,PSEUDO_TYPE(PTR(MP)),TEMP);    01355200
            IF PSEUDO_TYPE(PTR(MP))=MAJ_STRUC THEN                              01355300
               IF (SYT_FLAGS(VAR_LENGTH(FIXV(MP)))&MISC_NAME_FLAG)^=0 THEN      01355400
               CALL ERROR(CLASS_T,6);                                           01355500
            CALL EMIT_ARRAYNESS;                                                01355600
            PTR_TOP=PTR(MP)-1;                                                  01355700
         END;                                                                   01355800
 /*  <READ ARG>  ::=  <IO CONTROL>  */                                          01355900
         GO TO EMIT_IO_ARG;                                                     01356000
 /*  <WRITE ARG>  ::=  <EXPRESSION>  */                                         01356100
         DO;                                                                    01356200
            TEMP=0;                                                             01356300
            GO TO EMIT_IO_ARG;                                                  01356400
         END;                                                                   01356500
 /*  <WRITE ARG>  ::=  <IO CONTROL>  */                                         01356600
         GO TO EMIT_IO_ARG;                                                     01356700
 /*  <READ KEY>  ::=  READ  (  <NUMBER>  )  */                                  01356800
         DO;                                                                    01356900
            TEMP=0;                                                             01357000
EMIT_IO_HEAD:                                                                   01357100
            XSET SHL(TEMP,11);                                                  01357150
            CALL HALMAT_POP(XXXST,1,XCO_N,0);                                   01357200
            CALL HALMAT_PIP(TEMP,XIMD,0,0);                                     01357300
            PTR(MP)=PUSH_INDIRECT(1);                                           01357400
            IF FIXV(MP+2)> DEVICE_LIMIT THEN DO;                                01357500
               CALL ERROR(CLASS_TD,1,''||DEVICE_LIMIT);                         01357600
               LOC_P(PTR(MP))=0;                                                01357700
            END;                                                                01357800
            ELSE DO;                                                            01357900
               LOC_P(PTR(MP))=FIXV(MP+2);                                       01358000
               I=IODEV(FIXV(MP+2));                                             01358100
               IF (I&"28")=0 THEN DO;                                           01358200
                  IF TEMP=2 THEN DO;                                            01358300
                     IF (I&"01")=0 THEN I=I|"04";                               01358400
                     ELSE I=I|"02";                                             01358500
                  END;                                                          01358600
                  ELSE DO;                                                      01358700
                     I=I|"01";                                                  01358800
                     IF (I&"04")^=0 THEN IF (I&"40")^=0 THEN I=I|"80";          01358900
                     ELSE I=(I&"FB")|"02";                                      01359000
                  END;                                                          01359100
               END;                                                             01359200
               IODEV(FIXV(MP+2))=I;                                             01359300
            END;                                                                01359400
            PSEUDO_FORM(PTR(MP))=XIMD;                                          01359500
            INX(PTR(MP))=TEMP;                                                  01359600
            IF UPDATE_BLOCK_LEVEL>0 THEN CALL ERROR(CLASS_UT,1);                01359700
         END;                                                                   01359800
 /*  <READ KEY>  ::=  READALL  (  <NUMBER>  )  */                               01359900
         DO;                                                                    01360000
            TEMP=1;                                                             01360100
            GO TO EMIT_IO_HEAD;                                                 01360200
         END;                                                                   01360300
 /*  <WRITE KEY>  ::=  WRITE  (  <NUMBER>  )  */                                01360400
         DO;                                                                    01360500
            TEMP=2;                                                             01360600
            GO TO EMIT_IO_HEAD;                                                 01360700
         END;                                                                   01360800
 /*  <BLOCK DEFINITION> ::= <BLOCK STMT> <BLOCK BODY> <CLOSING> ;  */           01360900
         DO;                                                                    01361000
            TEMP=XCLOS;                                                         01361100
            TEMP2=0;                                                            01361200
CLOSE_SCOPE:                                                                    01361300
            CALL HALMAT_POP(TEMP,1,0,TEMP2);                                    01361400
            CALL HALMAT_PIP(BLOCK_SYTREF(NEST),XSYT,0,0);                       01361500
            DO I = 0 TO NDECSY - REGULAR_PROCMARK;                              01361600
               J = NDECSY - I;                                                  01361700
               IF (SYT_FLAGS(J) & INACTIVE_FLAG) = 0 THEN                       01361800
                  DO;                                                           01361900
                  CLOSE_BCD = SYT_NAME(J);                                      01362000
                  IF SYT_CLASS(J) = FUNC_CLASS THEN                             01362100
                     DO;                                                        01362200
                     IF (SYT_FLAGS(J) & DEFINED_LABEL) = 0 THEN                 01362300
                        CALL ERROR(CLASS_PL, 1, CLOSE_BCD);                     01362400
                     CALL DISCONNECT(J);                                        01362500
                  END;                                                          01362600
                  ELSE IF SYT_CLASS(J) = LABEL_CLASS THEN                       01362700
                     DO;                                                        01362800
                     IF (SYT_FLAGS(J) & DEFINED_LABEL) = 0 THEN                 01362900
                        DO;  /* UNDEFINED CALLABLE LABEL */                     01363000
                        IF SYT_TYPE(J) = STMT_LABEL THEN                        01363100
                           DO;                                                  01363200
                           CALL DISCONNECT(J);                                  01363300
                           CALL ERROR(CLASS_PL, 5, CLOSE_BCD);                  01363400
 /* UNDEFINED OBJECT OF GO TO */                                                01363500
                        END;                                                    01363600
                        ELSE                                                    01363700
                           DO;  /* CALLED/SCHED BUT UNDEFINED                   01363800
                                         PROCS/TASKS */                         01363900
                           IF NEST=1 THEN                                       01364000
                              DO;  /* CLOSING PROGRAM -                         01364100
                                               MAKE UNDEFINED CALLS/SCHEDS      01364200
                                               INTO ERRORS */                   01364300
                              CALL ERROR(CLASS_PL, 6, CLOSE_BCD);               01364400
                              CALL DISCONNECT(J);                               01364500
                           END;                                                 01364600
                           ELSE DO;                                             01364700
                              CALL SET_OUTER_REF(J,"6000");                     01364800
                              SYT_NEST(J)=NEST-1;                               01364900
                           END;                                                 01365000
                        END;  /* OF CALLED LABELS */                            01365100
                     END;  /* OF UNDEFINED CALLABLE LABELS */                   01365200
                     ELSE IF SYT_TYPE(J) = IND_CALL_LAB THEN                    01365300
                        DO;                                                     01365400
                        SYT_NEST(J) = NEST - 1;                                 01365500
                        K = SYT_PTR(J);                                         01365600
                        DO WHILE SYT_TYPE(K) = IND_CALL_LAB;                    01365700
                           K = SYT_PTR(K);                                      01365800
                        END;                                                    01365900
                        IF SYT_NEST(K) >= SYT_NEST(J) THEN                      01366000
                           DO; /* IND CALL HAS REACHED SAME SCOPE AS            01366100
                                          DEFINITION OF LABEL. SO LEAVE         01366200
                                          AS IND CALL AND DISCONNECT FROM SYT */01366300
                           IF SYT_PTR(J) = K THEN                               01366310
                              IF SYT_LINK1(K) < 0 THEN                          01366320
                              IF DO_LEVEL < (-SYT_LINK1(K)) THEN                01366330
                              CALL ERROR(CLASS_PL, 11, CLOSE_BCD);              01366340
                           CALL DISCONNECT(J);                                  01366400
                           CALL TIE_XREF(J);                                    01366500
                        END;                                                    01366600
                     END;  /* OF TYPE = IND_CALL_LAB */                         01366700
                     ELSE CALL DISCONNECT(J); /* NONE OF THE ABOVE */           01366800
                  END;  /* OF LABEL CLASS */                                    01366900
                  ELSE CALL DISCONNECT(J);  /* ALL OTHER CLASSES */             01367000
               END;                                                             01367100
            END;                                                                01367200
            IF BLOCK_MODE(NEST)=UPDATE_MODE THEN                                01367300
               UPDATE_BLOCK_LEVEL = UPDATE_BLOCK_LEVEL - 1;                     01367400
            IF LENGTH(VAR(SP-1)) > 0 THEN                                       01367500
               IF VAR(SP-1) ^= CURRENT_SCOPE THEN                               01367600
               CALL ERROR(CLASS_PL,3,CURRENT_SCOPE);                            01367700
            IF REGULAR_PROCMARK > NDECSY THEN    /* NO LOCAL NAMES */           01367800
               SYT_PTR(FIXL(MP)) = 0;                                           01367900
            IF (SYT_FLAGS(FIXL(MP)) & ACCESS_FLAG) ^= 0 THEN                    01368000
               IF BLOCK_MODE(NEST) = CMPL_MODE THEN                             01368100
               DO I = FIXL(MP) TO NDECSY;                                       01368200
               SYT_FLAGS(I) = SYT_FLAGS(I) | READ_ACCESS_FLAG;                  01368300
            END;                                                                01368400
 /*********  FIX FOR DR102949  MATTHEW S. BELCHER, 12/88  **********/           01368402
 /* IF THIS IS THE CLOSE OF A COMPOOL INCLUDED REMOTE                           01368404
     THEN MAKE SURE THAT ALL OF THE ITEMS IN THE COMPOOL                        01368406
     ARE ALSO FLAGED AS REMOTE - EXCEPT FOR NAME TYPES AND                      01368408
     STRUCTURE TEMPLATE VARIABLES. */                                           01368410
            IF ((SYT_FLAGS(FIXL(MP)) & EXTERNAL_FLAG) ^= 0)                     01368412
               & ((SYT_FLAGS(FIXL(MP)) & REMOTE_FLAG) ^= 0) THEN                01368414
               IF BLOCK_MODE(NEST) = CMPL_MODE THEN                             01368416
               DO I = FIXL(MP) TO NDECSY;                                       01368418
 /*----------------- DANNY STRAUSS DR102949 --------------------------*/        01368420
 /* IF 16-BIT NAME VARIABLE WAS INITIALIZED TO NON-REMOTE VARIABLE IN */        01368422
 /* A REMOTELY INCLUDED COMPOOL, IT IS NOW INVALID.                   */        01368424
TEMPL_INITIAL_CHECK:PROCEDURE;                                                  01368426
 /* IS POINTED TO BY A NAME VARIABLE */                                         01368428
                  IF (SYT_FLAGS(I) & MISC_NAME_FLAG) ^= 0                       01368430
                     THEN IF SYT_TYPE(I) ^= TEMPL_NAME /* NOT A TEMPLATE*/      01368432
 /* NON-REMOTE */                                                               01368434
                     THEN IF (SYT_FLAGS(I) & REMOTE_FLAG) = 0                   01368436
                     THEN CALL ERROR(CLASS_DI,21);                              01368438
               END TEMPL_INITIAL_CHECK;                                         01368440
               CALL TEMPL_INITIAL_CHECK;                                        01368442
 /*-------------------------------------------------------------------*/        01368444
 /*----------------- DANNY STRAUSS DR102949 --------------------------*/        01368446
 /*          INCLUDED_REMOTE MEANS VARIABLE LIVES REMOTE ONLY BECAUSE */        01368448
 /*          IT WAS INCLUDED REMOTE (IT RESIDES IN #P, NOT IN #R)     */        01368450
               IF (SYT_CLASS(I) ^= TEMPLATE_CLASS) THEN DO;                     01368452
 /* NOT A NAME VARIABLE AND NOT INITIALLY DECLARED REMOTE */                    01368454
                  IF ((SYT_FLAGS(I) & NAME_FLAG) = 0) &                         01368456
                     ((SYT_FLAGS(I) & REMOTE_FLAG) = 0) THEN                    01368458
                     SYT_FLAGS(I) = SYT_FLAGS(I) | REMOTE_FLAG |                01368460
                     INCLUDED_REMOTE;                                           01368462
 /* FOR NAME VARIABLES, SET THAT THEY NOW LIVE REMOTE     */                    01368464
                  IF ((SYT_FLAGS(I) & NAME_FLAG) ^= 0) THEN                     01368466
                     SYT_FLAGS(I) = SYT_FLAGS(I) |                              01368468
                     INCLUDED_REMOTE;                                           01368470
               END;                                                             01368472
            END;                                                                01368474
 /*************  END OF FIX FOR DR102949  **************************/           01368476
            SYT_FLAGS(NDECSY) = SYT_FLAGS(NDECSY) | ENDSCOPE_FLAG;              01368500
            CURRENT_SCOPE = VAR(MP);                                            01368600
            IF PTR(MPP1) THEN DO CASE EXTERNAL_MODE;                            01368700
 /*  NOT EXTERNAL  */                                                           01368800
               IF BLOCK_MODE(NEST)=CMPL_MODE THEN CALL ERROR(CLASS_PC,1);       01368900
 /*  PROC MODE  */                                                              01369000
               CALL ERROR(CLASS_PS,1);                                          01369100
 /*  FUNC MODE  */                                                              01369200
               CALL ERROR(CLASS_PS,1);                                          01369300
 /*  COMPOOL MODE  */                                                           01369400
               CALL ERROR(CLASS_PC,2);                                          01369500
 /* PROGRAM MODE */                                                             01369510
               CALL ERROR(CLASS_PS,1);                                          01369520
            END;                                                                01369600
            CALL OUTPUT_WRITER;                                                 01369700
            CALL EMIT_SMRK;                                                     01369800
            IF BLOCK_MODE(NEST)=INLINE_MODE THEN DO;                            01369900
               INLINE_INDENT_RESET=EXT_P(PTR(MP));                              01370000
               INDENT_LEVEL=INLINE_INDENT+INDENT_INCR;                          01370100
               INLINE_STMT_RESET=STMT_NUM;                                      01370200
               STMT_NUM=INX(PTR(MP));                                           01370300
               INX(PTR(MP)) = 0;                                                01370400
               IF PSEUDO_TYPE(PTR(MP))=MAJ_STRUC THEN FIXL(MP)=                 01370410
                  PSEUDO_LENGTH(PTR(MP));                                       01370420
               CALL RESET_ARRAYNESS;                                            01370500
               INLINE_LEVEL=INLINE_LEVEL-1;                                     01370600
               NEST_LEVEL = NEST_LEVEL - 1;                                     01370650
               IF INLINE_LEVEL=0 THEN DO;                                       01370700
                  STAB_MARK,STAB2_MARK = 0;                                     01370800
                  XSET STAB_STACK;                                              01370900
                  SRN_FLAG=FALSE;                                               01371000
                  SRN(2)=SRN_MARK;                                              01371100
                  INCL_SRN(2) = INCL_SRN_MARK;                                  01371110
                  SRN_COUNT(2)=SRN_COUNT_MARK;                                  01371200
               END;                                                             01371300
               FIXF(MP)=0;                                                      01371400
            END;                                                                01371500
            ELSE DO;                                                            01371600
               CALL BLOCK_SUMMARY;                                              01371700
               OUTER_REF_INDEX=(OUTER_REF_PTR(NEST)&"7FFF")-1;                  01371800
               INDENT_LEVEL = INDENT_STACK(NEST);                               01371850
               NEST_LEVEL = NEST_STACK(NEST);                                   01371860
            END;                                                                01371900
            PROCMARK,REGULAR_PROCMARK=PROCMARK_STACK(NEST);                     01372000
            SCOPE# = SCOPE#_STACK(NEST);                                        01372100
            I=0;                                                                01372200
            DO WHILE ON_ERROR_PTR<-SYT_ARRAY(BLOCK_SYTREF(NEST));               01372300
               IF EXT_ARRAY(ON_ERROR_PTR)="3FFF" THEN I=I+"1001";               01372400
               ELSE I=I+1;                                                      01372500
               ON_ERROR_PTR=ON_ERROR_PTR+1;                                     01372600
            END;                                                                01372700
            SYT_ARRAY(BLOCK_SYTREF(NEST))=I|"E000";                             01372800
            NEST = NEST - 1;                                                    01372900
            DO_INX(DO_LEVEL)=DO_INX(DO_LEVEL)&"7F";                             01373000
            IF NEST=0 THEN DO;                                                  01373100
               IF EXTERNAL_MODE>0 THEN DO;                                      01373200
                  IF SIMULATING=2 THEN DO;                                      01373300
                     STMT_TYPE=0;                                               01373400
                     SIMULATING=1;                                              01373500
                  END;                                                          01373600
                  EXTERNAL_MODE=0;                                              01373700
                  TPL_VERSION=BLOCK_SYTREF(NEST+1);                             01373800
                  SYT_LOCK#(TPL_VERSION)=0;                                     01373900
               END;                                                             01374000
               ELSE IF BLOCK_MODE>0 THEN DO;                                    01374100
                  IF EXTERNALIZE=4 THEN EXTERNALIZE=2;                          01374200
                  CALL EMIT_EXTERNAL;                                           01374300
               END;                                                             01374400
            END;                                                                01374500
         END;                                                                   01374600
 /*  <BLOCK BODY>  ::= <EMPTY>  */                                              01374700
         DO;                                                                    01374800
            CALL HALMAT_POP(XEDCL,0,XCO_N,0);                                   01374900
            GO TO CHECK_DECLS;                                                  01375000
         END;                                                                   01375100
                                                                                01375200
 /*  <BLOCK BODY>  ::=  <DECLARE GROUP>  */                                     01375300
         DO;                                                                    01375400
            CALL HALMAT_POP(XEDCL, 0, XCO_N, 1);                                01375500
CHECK_DECLS:                                                                    01375600
            I = BLOCK_MODE(NEST);                                               01375700
            IF (I = FUNC_MODE) | (I = PROC_MODE) THEN DO;                       01375800
               J=BLOCK_SYTREF(NEST);  /* PROC FUNC NAME  */                     01375900
               IF SYT_PTR(J) ^= 0 THEN DO;                                      01376000
                  J = SYT_PTR(J);  /* POINT TO FIRST ARG */                     01376100
                  DO WHILE (SYT_FLAGS(J) & PARM_FLAGS) ^= 0;                    01376200
                     IF (SYT_FLAGS(J) & IMP_DECL) ^= 0 THEN                     01376300
                        DO;  /* UNDECLARED PARAMETER */                         01376400
                        CALL ERROR(CLASS_DU, 2, SYT_NAME(J));                   01376500
                        PARMS_PRESENT=0;                                        01376600
                        SYT_TYPE(J) = DEFAULT_TYPE;                             01376700
                        SYT_FLAGS(J) = SYT_FLAGS(J) | DEFAULT_ATTR;             01376800
                     END;                                                       01376900
                     J = J + 1;  /* NEXT PARAMETER */                           01377000
                  END;                                                          01377100
                  IF (EXTERNAL_MODE > 0) & (EXTERNAL_MODE < CMPL_MODE) THEN     01377200
                     DO WHILE J <= NDECSY;                                      01377300
                     IF SYT_CLASS(J)<REPL_ARG_CLASS THEN DO;                    01377400
                        CALL ERROR(CLASS_DU, 3, SYT_NAME(J));                   01377500
                        SYT_FLAGS(J) = SYT_FLAGS(J) | DUMMY_FLAG;               01377600
                     END;                                                       01377700
                     J = J + 1;                                                 01377800
                  END;                                                          01377900
               END;                                                             01378000
            END;                                                                01378100
            IF EXTERNALIZE THEN EXTERNALIZE=4;                                  01378200
            PTR(MP)=0;                                                          01378300
         END;                                                                   01378400
                                                                                01378500
 /*  <BLOCK BODY>  ::=  <BLOCK BODY>  <ANY STATEMENT>  */                       01378600
         PTR(MP)=1;                                                             01378700
 /*  <ARITH INLINE DEF>  ::=  FUNCTION <ARITH SPEC>  ;  */                      01378800
         DO;                                                                    01378900
            IF TYPE=0 THEN TYPE=DEFAULT_TYPE;                                   01379000
            IF (ATTRIBUTES&SD_FLAGS)=0 THEN ATTRIBUTES=ATTRIBUTES|              01379100
               (DEFAULT_ATTR&SD_FLAGS);                                         01379200
            IF TYPE<SCALAR_TYPE THEN TEMP=TYPE(TYPE);                           01379300
            ELSE TEMP=0;                                                        01379400
INLINE_DEFS:                                                                    01379500
            IF CONTEXT=EXPRESSION_CONTEXT THEN CALL ERROR(CLASS_PP,11);         01379600
            CONTEXT=0;                                                          01379700
          GRAMMAR_FLAGS(STACK_PTR(MP))=GRAMMAR_FLAGS(STACK_PTR(MP))|INLINE_FLAG;01379800
            PTR(MP)=PUSH_INDIRECT(1);                                           01379900
            INLINE_LEVEL=INLINE_LEVEL+1;                                        01380000
            IF INLINE_LEVEL>1 THEN CALL ERROR(CLASS_PP,10);                     01380100
            ELSE  DO;                                                           01380200
               STAB_MARK=STAB_STACKTOP;                                         01380300
               STAB2_MARK = STAB2_STACKTOP;                                     01380310
               STAB_STACK=STMT_TYPE;                                            01380400
               SRN_MARK=SRN(2);                                                 01380500
               INCL_SRN_MARK = INCL_SRN(2);                                     01380510
               SRN_COUNT_MARK=SRN_COUNT(2);                                     01380600
               STMT_TYPE=0;                                                     01380700
            END;                                                                01380800
            INLINE_LABEL=INLINE_LABEL+1;                                        01380900
            VAR(MP)=INLINE_NAME||INLINE_LABEL;                                  01381000
            NAME_HASH=HASH(VAR(MP),SYT_HASHSIZE);                               01381100
            I,FIXL(MP)=ENTER(VAR(MP),FUNC_CLASS);                               01381200
            IF SIMULATING THEN CALL STAB_LAB(I);                                01381300
            CALL SET_XREF(I,XREF_REF);                                          01381400
            SYT_TYPE(I)=TYPE;                                                   01381500
            SYT_FLAGS(I)=SYT_FLAGS(I)|DEFINED_LABEL|ATTRIBUTES;                 01381600
            VAR_LENGTH(I)=TEMP;                                                 01381700
            CALL HALMAT_POP(XIDEF,1,0,INLINE_LEVEL);                            01381800
            CALL HALMAT_PIP(I,XSYT,0,0);                                        01381900
            CALL SETUP_VAC(MP,TYPE,TEMP);                                       01382000
            TEMP2=INLINE_MODE;                                                  01382100
            DO I=0 TO FACTOR_LIM;                                               01382200
               TYPE(I)=0;                                                       01382300
            END;                                                                01382400
            CALL SAVE_ARRAYNESS;                                 /* CR12416 */  01382500
          IF (SUBSCRIPT_LEVEL|EXPONENT_LEVEL)^=0 THEN CALL ERROR(CLASS_B,2);    01382600
            GO TO INLINE_ENTRY;                                                 01382700
         END;                                                                   01382800
 /*  <ARITH INLINE DEF>  ::=  FUNCTION  ;  */                                   01382900
         DO;                                                                    01383000
            TYPE=DEFAULT_TYPE;                                                  01383100
            ATTRIBUTES=DEFAULT_ATTR&SD_FLAGS;                                   01383200
            TEMP=0;                                                             01383300
            GO TO INLINE_DEFS;                                                  01383400
         END;                                                                   01383500
 /*  <BIT INLINE DEF>  ::=  FUNCTION <BIT SPEC>  ;  */                          01383600
         DO;                                                                    01383700
            TEMP=BIT_LENGTH;                                                    01383800
            GO TO INLINE_DEFS;                                                  01383900
         END;                                                                   01384000
 /*  <CHAR INLINE DEF>  ::=  FUNCTION <CHAR SPEC>  ;  */                        01384100
         DO;                                                                    01384200
            IF CHAR_LENGTH<0 THEN DO;                                           01384300
               CALL ERROR(CLASS_DS,3);                                          01384400
               TEMP=DEF_CHAR_LENGTH;                                            01384500
            END;                                                                01384600
            ELSE TEMP=CHAR_LENGTH;                                              01384700
            GO TO INLINE_DEFS;                                                  01384800
         END;                                                                   01384900
 /*  <STRUC INLINE DEF>  ::=  FUNCTION <STRUCT SPEC>  ;  */                     01385000
         DO;                                                                    01385100
            IF STRUC_DIM^=0 THEN DO;                                            01385200
               CALL ERROR(CLASS_DD,12);                                         01385210
               STRUC_DIM=0;                                                     01385220
            END;                                                                01385230
            TEMP=STRUC_PTR;                                                     01385240
            TYPE=MAJ_STRUC;                                                     01385250
            GO TO INLINE_DEFS;                                                  01385700
         END;                                                                   01385800
 /*  <BLOCK STMT>  ::=  <BLOCK STMT TOP>  ;  */                                 01385900
         DO;                                                                    01386000
            CALL OUTPUT_WRITER;                                                 01386200
            IF PARMS_PRESENT<=0 THEN IF EXTERNALIZE THEN EXTERNALIZE=4;         01386300
            INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;                              01386400
            IF TPL_REMOTE THEN                                                  01386410
               IF EXTERNAL_MODE>0 & NEST=1 & BLOCK_MODE(NEST)=CMPL_MODE THEN    01386420
               SYT_FLAGS(FIXL(MP)) = SYT_FLAGS(FIXL(MP)) | REMOTE_FLAG;         01386430
            ELSE CALL ERROR(CLASS_PS,13);                                       01386440
            TPL_REMOTE = FALSE;                                                 01386450
            CALL EMIT_SMRK;                                                     01386500
         END;                                                                   01386600
 /*  <BLOCK STMT TOP> ::= <BLOCK STMT TOP> ACCESS  */                           01386700
         DO;                                                                    01386800
            IF BLOCK_MODE(NEST)>PROG_MODE THEN                                  01386900
               CALL ERROR(CLASS_PS,3);                                          01387000
            ELSE IF NEST ^= 1 THEN CALL ERROR(CLASS_PS, 4);                     01387100
      ELSE IF (SYT_FLAGS(FIXL(MP))&ACCESS_FLAG)^=0 THEN CALL ERROR(CLASS_PS,10);01387200
            ELSE DO;                                                            01387300
               SYT_FLAGS(FIXL(MP)) = SYT_FLAGS(FIXL(MP)) | ACCESS_FLAG;         01387400
               ACCESS_FOUND = TRUE;                                             01387500
            END;                                                                01387600
         END;                                                                   01387700
 /*  <BLOCK STMT TOP>  ::= <BLOCK STMT TOP> RIGID  */                           01387800
         DO;                                                                    01387900
            IF BLOCK_MODE(NEST)^=CMPL_MODE THEN CALL ERROR(CLASS_PS,12);        01388000
       ELSE IF (SYT_FLAGS(FIXL(MP))&RIGID_FLAG)^=0 THEN CALL ERROR(CLASS_PS,11);01388100
            ELSE SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|RIGID_FLAG;            01388200
         END;                                                                   01388300
 /*  <BLOCK STMT TOP>  ::=  <BLOCK STMT HEAD>  */                               01388400
         ;                                                                      01388500
 /*  <BLOCK STMT TOP>  ::=  <BLOCK STMT HEAD>  EXCLUSIVE  */                    01388600
         DO;                                                                    01388700
          IF BLOCK_MODE(NEST)>FUNC_MODE THEN CALL ERROR(CLASS_PS,2,'EXCLUSIVE');01388800
            SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|EXCLUSIVE_FLAG;             01388900
         END;                                                                   01389000
 /*  <BLOCK STMT TOP>  ::=  <BLOCK STMT HEAD>  REENTRANT  */                    01389100
         DO;                                                                    01389200
          IF BLOCK_MODE(NEST)>FUNC_MODE THEN CALL ERROR(CLASS_PS,2,'REENTRANT');01389300
            SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|REENTRANT_FLAG;             01389400
         END;                                                                   01389500
 /*  <LABEL DEFINITION>  ::=  <LABEL>  :  */                                    01389600
         DO;                                                                    01389700
            IF NEST=0 THEN EXTERNAL_MODE=0;                                     01389800
            CALL HALMAT_POP(XLBL,1,XCO_N,0);                                    01389900
            CALL HALMAT_PIP(FIXL(MP),XSYT,0,0);                                 01390000
            TEMP=FIXL(MP);                                                      01390100
            IF SYT_TYPE(TEMP) ^= IND_CALL_LAB THEN DO;                          01390200
               IF SYT_LINK1(TEMP)>0 THEN IF DO_LEVEL>0 THEN                     01390250
                  IF DO_STMT#(DO_LEVEL) > SYT_LINK1(TEMP) THEN DO;              01390300
                  IF SYT_TYPE(TEMP) = STMT_LABEL THEN CALL ERROR(CLASS_GL, 2);  01390350
                  ELSE CALL ERROR(CLASS_PL, 10);                                01390400
               END;                                                             01390450
               IF SYT_LINK1(TEMP) >= 0 THEN DO;                                 01390500
                  SYT_LINK1(TEMP) = -DO_LEVEL;                                  01390550
                  SYT_LINK2(TEMP) = SYT_LINK2(0);                               01390600
                  SYT_LINK2(0) = TEMP;                                          01390650
               END;                                                             01390700
            END;                                                                01390750
            LABEL_COUNT=LABEL_COUNT+1;                                          01390900
            IF SIMULATING THEN CALL STAB_LAB(FIXL(MP));                         01391000
           GRAMMAR_FLAGS(STACK_PTR(MP))=GRAMMAR_FLAGS(STACK_PTR(MP))|LABEL_FLAG;01391100
 /*DR109096 IF THE XREF ENTRY IS FOR THE LABEL'S DEFINITION (FLAG=0),       */
 /*109096   THEN CHECK THE STATEMENT NUMBER.  IF IT IS NOT EQUAL TO CURRENT */
 /*109096   STATEMENT NUMBER, CHANGE IT TO THE CURRENT STATEMENT NUMBER.    */
 /*109096*/ IF (SHR(XREF(SYT_XREF(FIXL(MP))),13) & 7) = 0 THEN
 /*109096*/    IF (XREF(SYT_XREF(FIXL(MP))) & XREF_MASK) ^= STMT_NUM THEN
 /*DR109096*/     XREF(SYT_XREF(FIXL(MP))) =
 /*DR109096*/       (XREF(SYT_XREF(FIXL(MP))) & "FFFFE000") | STMT_NUM;
            IF SYT_TYPE(FIXL(MP))=STMT_LABEL THEN DO; /*DR111356*/              01391200
              NO_NEW_XREF = TRUE;                     /*DR111356*/
              CALL SET_XREF(FIXL(MP),0);
            END;                                      /*DR111356*/
         END;                                                                   01391300
 /*  <LABEL EXTERNAL>  ::=  <LABEL DEFINITION>  */                              01391400
         ;                                                                      01391500
 /*  <LABEL EXTERNAL>  ::=  <LABEL DEFINITION>  EXTERNAL  */                    01391600
         DO;                                                                    01391700
            IF NEST>0 THEN CALL ERROR(CLASS_PE,1);                              01391800
            ELSE DO;                                                            01391900
               SYT_FLAGS(FIXL(MP)) = SYT_FLAGS(FIXL(MP)) | EXTERNAL_FLAG;       01392000
               EXTERNAL_MODE=1;   /* JUST A FLAG FOR NOW  */                    01392100
               IF BLOCK_MODE>0 THEN CALL ERROR(CLASS_PE,2);                     01392200
               IF SIMULATING THEN DO;                                           01392300
                  STAB2_STACKTOP = STAB2_STACKTOP - 1;                          01392400
                  SIMULATING=2;                                                 01392500
               END;                                                             01392600
            END;                                                                01392700
         END;                                                                   01392800
 /*  <BLOCK STMT HEAD>  ::=  <LABEL EXTERNAL>  PROGRAM  */                      01392900
         DO;                                                                    01393000
            TEMP=XMDEF;                                                         01393100
            PARMS_PRESENT=0;                                                    01393200
            TEMP2=PROG_MODE;                                                    01393300
            CALL SET_LABEL_TYPE(FIXL(MP),PROG_LABEL);                           01393400
            SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|LATCHED_FLAG;               01393500
            IF EXTERNAL_MODE>0 THEN DO;                                         01393600
               IF NEST=0 THEN EXTERNAL_MODE=TEMP2;                              01393700
               GO TO NEW_SCOPE;                                                 01393800
            END;                                                                01393900
OUTERMOST_BLOCK:                                                                01394000
            IF NEST>0 THEN CALL ERROR(CLASS_PP,1,VAR(MPP1));                    01394100
            ELSE DO;                                                            01394200
DUPLICATE_BLOCK:                                                                01394300
               IF BLOCK_MODE=0 THEN DO;                                         01394400
                  MAIN_SCOPE=MAX_SCOPE#+1;  /* WHAT SYT_SCOPE WILL BECOME */    01394500
                  FIRST_STMT = STMT_NUM;                                        01394600
                  BLOCK_MODE=TEMP2;                                             01394700
                  IF BLOCK_MODE<TASK_MODE THEN IF TPL_FLAG<3 THEN EXTERNALIZE=3;01394800
                  CALL MONITOR(17,DESCORE(VAR(MP)));                            01394900
                  CALL EMIT_EXTERNAL;                                           01395000
               END;                                                             01395100
               ELSE CALL ERROR(CLASS_PP,2);                                     01395200
            END;                                                                01395300
            GO TO NEW_SCOPE;                                                    01395400
         END;                                                                   01395500
 /*  <BLOCK STMT HEAD>  ::=  <LABEL EXTERNAL>  COMPOOL  */                      01395600
         DO;                                                                    01395700
            TEMP=XCDEF;                                                         01395800
            TEMP2=CMPL_MODE;                                                    01395900
            PARMS_PRESENT=1;/*  FIX SO ALL DECLARES EMITTED IN CMPL TEMPLATE  */01396000
            CALL SET_LABEL_TYPE(FIXL(MP),COMPOOL_LABEL);                        01396100
/*-RSJ-------------#DFLAG-----------CR11096F-------------------*/
            /*THIS IS A COMPOOL COMPILATION*/
            /*CHECK IF #D OPTION IS ON.   EMIT FATAL ERROR IF ITS. */
            /*TURN OFF DATA REMOTE TO ALLOW FOR FUTURE DOWNGRADE OF*/
            /*THE ERROR                                            */
            /* DR107308 - PART 1. ALSO CHECK IF COMPOOL IS NOT     */
            /*            EXTERNAL BEFORE EMITTING THE XR2 ERROR.  */
            IF DATA_REMOTE & (EXTERNAL_MODE = 0) THEN DO;/*DR107308*/
               CALL ERROR(CLASS_XR,2);
               DATA_REMOTE=FALSE;
            END;
/*-------------------------------------------------------------*/
            IF EXTERNAL_MODE>0 THEN DO;                                         01396200
               IF NEST=0 THEN EXTERNAL_MODE=TEMP2;                              01396300
               GO TO NEW_SCOPE;                                                 01396400
            END;                                                                01396500
            ELSE GO TO OUTERMOST_BLOCK;                                         01396600
         END;                                                                   01396700
 /*  <BLOCK STMT HEAD>  ::=  <LABEL DEFINITION>  TASK  */                       01396800
         DO;                                                                    01396900
            TEMP=XTDEF;                                                         01397000
            TEMP2=TASK_MODE;                                                    01397100
            CALL SET_LABEL_TYPE(FIXL(MP),TASK_LABEL);                           01397200
            SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|LATCHED_FLAG;               01397300
            IF NEST=1 THEN DO;                                                  01397400
               IF BLOCK_MODE(1) = PROG_MODE THEN DO;                            01397500
                  IF DO_LEVEL > 1 THEN CALL ERROR(CLASS_PT, 2);                 01397510
                  GO TO NEW_SCOPE;                                              01397520
               END;                                                             01397530
            END;                                                                01397600
            CALL ERROR(CLASS_PT,1);                                             01397700
            IF NEST=0 THEN GO TO DUPLICATE_BLOCK;                               01397800
            ELSE GO TO NEW_SCOPE;                                               01397900
         END;                                                                   01398000
 /*  <BLOCK STMT HEAD>  ::=  <LABEL DEFINITION>  UPDATE  */                     01398100
         DO;                                                                    01398200
            VAR_LENGTH(FIXL(MP))=1;                                             01398300
            CALL HALMAT_BACKUP(LAST_POP#);                                      01398400
UPDATE_HEAD:                                                                    01398500
            IF UPDATE_BLOCK_LEVEL>0 THEN CALL ERROR(CLASS_UI,2);                01398600
            UPDATE_BLOCK_LEVEL=UPDATE_BLOCK_LEVEL+1;                            01398700
            TEMP2=UPDATE_MODE;                                                  01398800
            TEMP=XUDEF;                                                         01398900
            CALL SET_LABEL_TYPE(FIXL(MP),STMT_LABEL);                           01399000
            IF NEST=0 THEN DO;                                                  01399100
               CALL ERROR(CLASS_PP,3,VAR(MPP1));                                01399200
               GO TO DUPLICATE_BLOCK;                                           01399300
            END;                                                                01399400
            ELSE GO TO NEW_SCOPE;                                               01399500
         END;                                                                   01399600
 /*  <BLOCK STMT HEAD>  ::=  UPDATE  */                                         01399700
         DO;                                                                    01399800
            VAR(MPP1)=VAR(MP);                                                  01399900
            IMPLIED_UPDATE_LABEL=IMPLIED_UPDATE_LABEL+1;                        01400000
            VAR(MP)=UPDATE_NAME||IMPLIED_UPDATE_LABEL;                          01400100
            NAME_HASH=HASH(VAR(MP),SYT_HASHSIZE);                               01400200
            I,FIXL(MP)=ENTER(VAR(MP),LABEL_CLASS);                              01400300
            SYT_TYPE(I)=UNSPEC_LABEL;                                           01400400
            SYT_FLAGS(I)=SYT_FLAGS(I)|DEFINED_LABEL;                            01400500
            VAR_LENGTH(I)=2;                                                    01400600
            IF SIMULATING THEN CALL STAB_LAB(FIXL(MP));                         01400700
            GO TO UPDATE_HEAD;                                                  01400800
         END;                                                                   01400900
 /*  <BLOCK STMT HEAD>  ::=  <FUNCTION NAME>  */                                01401000
         DO;                                                                    01401100
FUNC_HEADER:                                                                    01401200
            IF PARMS_PRESENT = 0 THEN DO;                                       01401300
               PARMS_WATCH = FALSE;                                             01401320
               IF MAIN_SCOPE = SCOPE# THEN COMSUB_END = FIXL(MP);               01401340
            END;                                                                01401360
            FACTORING=TRUE;                                                     01401400
            DO_INIT = FALSE;                                                    01401500
            IF TYPE = 0 THEN                                                    01401600
               TYPE = DEFAULT_TYPE;                                             01401700
            ELSE IF TYPE = EVENT_TYPE THEN                                      01401800
               DO;                                                              01401900
               CALL ERROR(CLASS_FT, 3, SYT_NAME(ID_LOC));                       01402000
               TYPE = DEFAULT_TYPE;                                             01402100
            END;                                                                01402200
            IF (ATTRIBUTES & SD_FLAGS) = 0 THEN                                 01402300
               IF (TYPE >= MAT_TYPE) & (TYPE <= INT_TYPE) THEN                  01402400
               ATTRIBUTES = ATTRIBUTES | (DEFAULT_ATTR & SD_FLAGS);             01402500
            IF TYPE=MAJ_STRUC THEN CALL CHECK_STRUC_CONFLICTS;                  01402600
            IF SYT_TYPE(ID_LOC) = 0 THEN DO;                                    01402700
               CALL SET_SYT_ENTRIES;                                            01402800
            END;
            ELSE DO;                                                            01402900
               IF SYT_TYPE(ID_LOC) ^= TYPE THEN                                 01403000
                  CALL ERROR(CLASS_DT, 1, SYT_NAME(ID_LOC));                    01403100
               ELSE DO;  /* TYPES MATCH, WHAT ABOUT SIZES */                    01403200
                  IF TYPE <= VEC_TYPE THEN DO;                                  01403300
                     IF TYPE(TYPE) ^= VAR_LENGTH(ID_LOC) THEN                   01403400
                        CALL ERROR(CLASS_FT, 4, SYT_NAME(ID_LOC));              01403500
                  END;                                                          01403600
                  ELSE IF TYPE = MAJ_STRUC THEN DO;                             01403700
                     IF STRUC_PTR^=VAR_LENGTH(ID_LOC) THEN                      01403800
                        CALL ERROR(CLASS_FT, 6, SYT_NAME(ID_LOC));              01403900
                  END;                                                          01404000
                  IF (ATTRIBUTES & SD_FLAGS) ^= 0 THEN                          01404100
                     IF ((SYT_FLAGS(ID_LOC) & ATTRIBUTES) & SD_FLAGS) = 0 THEN  01404200
                     CALL ERROR(CLASS_FT, 7, SYT_NAME(ID_LOC));                 01404300
               END;  /* OF TYPES MATCH */                                       01404400
               DO I = 0 TO FACTOR_LIM;                                          01404500
                  TYPE(I) = 0;                                                  01404600
               END;                                                             01404700
            END;                                                                01404800
         END;                                                                   01404900
 /*  <BLOCK STMT HEAD>  ::=  <FUNCTION NAME>  <FUNC STMT BODY>  */              01405000
         GO TO FUNC_HEADER;                                                     01405100
 /*  <BLOCK STMT HEAD>  ::=  <PROCEDURE NAME>  */                               01405200
         DO;                                                                    01405300
            PARMS_WATCH = FALSE;                                                01405320
            IF MAIN_SCOPE = SCOPE# THEN COMSUB_END = FIXL(MP);                  01405340
         END;                                                                   01405360
 /*  <BLOCK STMT HEAD>  ::=  <PROCEDURE NAME>  <PROC STMT BODY>  */             01405400
         ;                                                                      01405500
 /*  <FUNCTION NAME>  ::=  <LABEL EXTERNAL>  FUNCTION  */                       01405600
         DO;                                                                    01405700
            ID_LOC=FIXL(MP);                                                    01405800
            FACTORING=FALSE;                                                    01405900
            IF SYT_CLASS(ID_LOC)^=FUNC_CLASS THEN                               01406000
           IF SYT_CLASS(ID_LOC)^=LABEL_CLASS|SYT_TYPE(ID_LOC)^=UNSPEC_LABEL THEN01406100
               CALL ERROR(CLASS_PL,4);                                          01406200
            ELSE DO;                                                            01406300
               SYT_CLASS(ID_LOC)=FUNC_CLASS;                                    01406400
               SYT_TYPE(ID_LOC)=0;                                              01406500
            END;                                                                01406600
            TEMP=XFDEF;                                                         01406700
            TEMP2=FUNC_MODE;                                                    01406800
            GO TO PROC_FUNC_HEAD;                                               01406900
         END;                                                                   01407000
 /*  <PROCEDURE NAME>  ::=  <LABEL EXTERNAL>  PROCEDURE  */                     01407100
         DO;                                                                    01407200
            TEMP2=PROC_MODE;                                                    01407300
            TEMP=XPDEF;                                                         01407400
            CALL SET_LABEL_TYPE(FIXL(MP),PROC_LABEL);                           01407500
PROC_FUNC_HEAD:                                                                 01407600
            PARMS_PRESENT=0;                                                    01407700
            IF INLINE_LEVEL>0 THEN CALL ERROR(CLASS_PP,9);                      01407800
            IF EXTERNAL_MODE>0 THEN DO;                                         01407900
               IF NEST=0 THEN EXTERNAL_MODE=TEMP2;                              01408000
            END;                                                                01408100
            ELSE IF NEST=0 THEN DO;                                             01408200
               PARMS_WATCH=TRUE;                                                01408300
               GO TO DUPLICATE_BLOCK;                                           01408400
            END;                                                                01408500
 /*  ALL BLOCKS AND TEMPLATES COME HERE  */                                     01408600
NEW_SCOPE:                                                                      01408700
            CALL SET_BLOCK_SRN(FIXL(MP));                                       01408710
            IF ^PAGE_THROWN THEN                                                01408800
               IF (SYT_FLAGS(FIXL(MP)) & EXTERNAL_FLAG) = 0 THEN                01408900
               LINE_MAX = 0;                                                    01409000
            IF TEMP2^=UPDATE_MODE THEN DO;                                      01409100
               CALL HALMAT_BACKUP(LAST_POP#);                                   01409400
            END;                                                                01409500
            IF ^HALMAT_CRAP THEN HALMAT_OK=EXTERNAL_MODE=0; /*DR109044*/        01409600
            CALL HALMAT_POP(TEMP,1,0,0);                                        01409700
            CALL HALMAT_PIP(FIXL(MP),XSYT,0,0);                                 01409800
INLINE_ENTRY:                                                                   01409900
            XSET"16";                                                           01410000
            NEST=NEST+1;                                                        01410100
            DO_INX(DO_LEVEL)=DO_INX(DO_LEVEL)|"80";                             01410200
            BLOCK_MODE(NEST)=TEMP2;                                             01410300
            BLOCK_SYTREF(NEST)=FIXL(MP);                                        01410400
            SYT_ARRAY(BLOCK_SYTREF(NEST))=-ON_ERROR_PTR;                        01410500
            IF NEST > MAXNEST THEN                                              01410600
               DO;                                                              01410700
               MAXNEST = NEST;                                                  01410800
               IF NEST >= NEST_LIM THEN                                         01410900
                  CALL ERROR(CLASS_BN,1); /* CR12416 */                         01411000
            END;                                                                01411100
            SCOPE#_STACK(NEST) = SCOPE#;                                        01411200
            MAX_SCOPE#, SCOPE# = MAX_SCOPE# + 1;                                01411300
            IF (SYT_FLAGS(FIXL(MP))&EXTERNAL_FLAG) ^= 0 THEN DO;                01411310
               NEXT_ELEMENT(CSECT_LENGTHS);                                     01411320
               CSECT_LENGTHS(SCOPE#).PRIMARY = "7FFF";/* SET LENGTH TO MAX */   01411330
               CSECT_LENGTHS(SCOPE#).REMOTE = "7FFF"; /* TO TURN OFF PHASE2*/   01411340
 /* %COPY CHECKING */                                                           01411350
            END;                                                                01411360
            SYT_SCOPE(FIXL(MP)) = SCOPE#; /* UPDATE BLOCK NAME TO SAME SCOPE */ 01411400
 /* AS CONTENTS */                                                              01411500
            PROCMARK_STACK(NEST) = PROCMARK;                                    01411600
            REGULAR_PROCMARK, PROCMARK = NDECSY + 1;                            01411700
            SYT_PTR(FIXL(MP)) = PROCMARK;                                       01411800
            IF BLOCK_MODE(NEST) = CMPL_MODE THEN                                01411900
               PROCMARK = 1;  /* ALL COMPOOLS IN SAME SCOPE */                  01412000
            S = CURRENT_SCOPE;                                                  01412100
            SAVE_SCOPE, CURRENT_SCOPE = VAR(MP);                                01412200
            VAR(MP) = S;                                                        01412300
            NEST = NEST - 1;          /*DR120267*/
            CALL COMPRESS_OUTER_REF;                                            01412400
            NEST = NEST + 1;          /*DR120267*/
            OUTER_REF_PTR(NEST)=OUTER_REF_INDEX+1;                              01412500
            CALL ENTER_LAYOUT(FIXL(MP));                                        01412600
            IF BLOCK_MODE(NEST)=INLINE_MODE THEN DO;                            01413200
               IF STACK_PTR(MP)>0 THEN CALL OUTPUT_WRITER(0,STACK_PTR(MP)-1);   01413300
               EXT_P(PTR(MP))=INDENT_LEVEL;                                     01413400
               INX(PTR(MP))=STMT_NUM;                                           01413500
               CALL EMIT_SMRK(5);                                               01413600
               INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;                           01413700
               CALL OUTPUT_WRITER(STACK_PTR(MP),STACK_PTR(SP));                 01413800
               INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;                           01413900
               NEST_LEVEL = NEST_LEVEL + 1;                                     01413950
               CALL EMIT_SMRK;                                                  01414000
            END;                                                                01414100
            ELSE DO;                                                            01414110
               INDENT_STACK(NEST) = INDENT_LEVEL;                               01414120
               NEST_STACK(NEST) = NEST_LEVEL;                                   01414130
               INDENT_LEVEL, NEST_LEVEL = 0;                                    01414140
            END;                                                                01414150
         END;                                                                   01414200
 /*  <FUNC STMT BODY>  ::=  <PARAMETER LIST>  */                                01414300
         ;                                                                      01414400
 /*  <FUNC STMT BODY>  ::=  <TYPE SPEC>  */                                     01414500
         ;                                                                      01414600
 /*  <FUNC STMT BODY>  ::=  <PARAMETER LIST>  <TYPE SPEC>  */                   01414700
         ;                                                                      01414800
 /*  <PROC STMT BODY>  ::=  <PARAMETER LIST>  */                                01414900
         ;                                                                      01415000
 /*  <PROC STMT BODY>  ::=  <ASSIGN LIST>  */                                   01415100
         ;                                                                      01415200
 /*  <PROC STMT BODY>  ::=  <PARAMETER LIST>  < ASSIGN LIST>  */                01415300
         ;                                                                      01415400
 /*  <PARAMETER LIST>  ::=  <PARAMETER HEAD>  <IDENTIFIER>  )  */               01415500
         PARMS_PRESENT=PARMS_PRESENT+1;                                         01415600
 /*  <PARAMETER HEAD>  ::=  (  */                                               01415700
         ;                                                                      01415800
 /*  <PARAMETER HEAD>  ::=  <PARAMETER HEAD>  <IDENTIFIER>  ,  */               01415900
         PARMS_PRESENT=PARMS_PRESENT+1;                                         01416000
 /*  <ASSIGN LIST>  ::=  <ASSIGN>  <PARAMETER LIST>  */                         01416100
         ;                                                                      01416200
 /*  <ASSIGN>  ::=  ASSIGN  */                                                  01416300
         IF CONTEXT=PARM_CONTEXT THEN CONTEXT=ASSIGN_CONTEXT;                   01416400
         ELSE ASSIGN_ARG_LIST=TRUE;                                             01416500
                                                                                01416600
 /*  <DECLARE ELEMENT>  ::=  <DECLARE STATEMENT>  */                            01416700
         DO;                                                                    01416800
            STMT_TYPE = DECL_STMT_TYPE;                                         01416810
            IF SIMULATING THEN CALL STAB_HDR;                                   01416820
            CALL EMIT_SMRK(1);                                                  01416830
         END;                                                                   01416840
                                                                                01416900
 /*  <DECLARE ELEMENT>  ::=  <REPLACE STMT>  ;  */                              01417000
         DO;                                                                    01417100
/*********** DR105709, RAH, 4/23/92 ***********************************/
            STMT_TYPE = REPLACE_STMT_TYPE;
            IF SIMULATING THEN CALL STAB_HDR;
/*********** END DR105709 *********************************************/
EMIT_NULL:                                                                      01417200
            CALL OUTPUT_WRITER;                                                 01417300
            CALL EMIT_SMRK(1);                                                  01417400
         END;                                                                   01417500
 /*  <DECLARE ELEMENT>  ::=  <STRUCTURE STMT>  */                               01417600
         DO;                                                                    01417700
            SYT_ADDR(REF_ID_LOC)=STRUC_SIZE;                                    01417800
            REF_ID_LOC=0;                                                       01417900
/*********** DR105709, RAH, 4/23/92 ***********************************/
            STMT_TYPE = STRUC_STMT_TYPE;
            IF SIMULATING THEN CALL STAB_HDR;
/*********** END DR105709 *********************************************/
            GO TO EMIT_NULL;                                                    01418000
         END;                                                                   01418100
 /*  <DECLARE ELEMENT>  ::=  EQUATE  EXTERNAL  <IDENTIFIER>  TO                 01418200
                             <VARIABLE>  ;  */                                  01418300
         DO;                                                                    01418400
            I = FIXL(MP + 2);  /* EQUATE NAME */                                01420200
            J = SP - 1;                                                         01420300
            IF SYT_CLASS(FIXL(J)) = TEMPLATE_CLASS THEN                         01420400
               J = FIXV(J);  /* ROOT PTR SAVED IN FIXV FOR STRUCS */            01420500
            ELSE J = FIXL(J);  /* SYT PTR IN FIXL FOR OTHERS */                 01420600
            SYT_PTR(I) = J;  /* POINT AT REFERENCED ITEM */                     01420700
            IF (SYT_FLAGS(BLOCK_SYTREF(NEST)) & EXTERNAL_FLAG) ^= 0 THEN        01420800
            SYT_FLAGS(I) = SYT_FLAGS(I) | DUMMY_FLAG;  /* IGNORE IN TEMPLATES */01420900
            IF SYT_SCOPE(I) ^= SYT_SCOPE(J) THEN                                01421000
               CALL ERROR(CLASS_DU, 7, VAR(SP - 1));                            01421100
            IF SYT_TYPE(J) > MAJ_STRUC THEN                                     01421200
               CALL ERROR(CLASS_DU, 8, VAR(SP - 1));                            01421300
            IF (SYT_FLAGS(J) & ILL_EQUATE_ATTR) ^= 0 THEN                       01421400
               CALL ERROR(CLASS_DU, 9, VAR(SP - 1));                            01421500
            IF (SYT_FLAGS(J) & AUTO_FLAG) ^= 0 THEN                             01421600
               IF (SYT_FLAGS(BLOCK_SYTREF(NEST)) & REENTRANT_FLAG) ^= 0 THEN    01421700
               CALL ERROR(CLASS_DU, 13, VAR(SP - 1));                           01421800
            TEMP = PTR(SP - 1);                                                 01421900
            IF (VAL_P(TEMP) & "40") ^= 0 THEN                                   01422000
               CALL ERROR(CLASS_DU, 10, VAR(SP - 1));  /* PREC MODIFIER */      01422100
            IF (VAL_P(TEMP) & "80") ^= 0 THEN                                   01422200
               CALL ERROR(CLASS_DU, 11, VAR(MP + 2));  /* SUBBIT */             01422300
            IF KILL_NAME(SP - 1) THEN                                           01422400
               CALL ERROR(CLASS_DU, 14, VAR(MP + 2));  /* NAME(.) */            01422500
            ELSE CALL RESET_ARRAYNESS;                                          01422510
            IF (VAL_P(TEMP) & "20") ^= 0 THEN                                   01422520
               CALL HALMAT_FIX_PIPTAGS(INX(TEMP), 0, 1);                        01422530
            DELAY_CONTEXT_CHECK, NAMING = FALSE;                                01422540
            IF SYT_PTR(J) < 0 THEN                                              01422600
               CALL ERROR(CLASS_DU, 12, VAR(SP - 1));                           01422700
            CALL HALMAT_POP(XEINT, 2, 0, PSEUDO_TYPE(TEMP));                    01422800
            CALL HALMAT_PIP(FIXL(MP + 2), XSYT, 0, 0);                          01422900
            CALL HALMAT_PIP(LOC_P(TEMP), PSEUDO_FORM(TEMP), 0, 0);              01423000
            CALL CHECK_ARRAYNESS;                                               01423100
            PTR_TOP = PTR(SP - 1) - 1;                                          01423200
            STMT_TYPE = EQUATE_TYPE;                                            01423210
            IF SIMULATING THEN CALL STAB_HDR;                                   01423220
            GO TO EMIT_NULL;                                                    01423300
         END;                                                                   01423400
 /*  <REPLACE STMT>  ::=  REPLACE  <REPLACE HEAD>  BY  <TEXT>  */               01423500
         DO;                                                                    01423600
            CONTEXT = 0;                                                        01423700
            MAC_NUM = FIXL(MPP1);                                               01423900
            SYT_ADDR(MAC_NUM) = START_POINT;                                    01424100
            VAR_LENGTH(MAC_NUM) = MACRO_ARG_COUNT;                              01424200
            EXTENT(MAC_NUM) = REPLACE_TEXT_PTR;                                 01424210
            MACRO_ARG_COUNT = 0;                                                01424300
         END;                                                                   01424400
 /*  <REPLACE HEAD>  ::=  <IDENTIFIER>  */                                      01424500
         DO;                                                                    01424600
INIT_MACRO:                                                                     01424610
            CONTEXT = 0;                                                        01424620
            MACRO_TEXT(FIRST_FREE) = "EF";  /* INITIALIZE TO NULL */            01424630
         END;                                                                   01424640
 /*  <REPLACE HEAD>  ::=  <IDENTIFIER>  (  <ARG LIST>  )  */                    01424700
         DO;                                                                    01424800
            NOSPACE;                                                            01424900
            GO TO INIT_MACRO;                                                   01425000
                                                                                01425010
         END;                                                                   01425100
 /*  <ARG LIST>  ::=  <IDENTIFIER>  */                                          01425200
NEXT_ARG:DO;                                                                    01425300
            MACRO_ARG_COUNT = MACRO_ARG_COUNT + 1 ;                             01425400
            IF MACRO_ARG_COUNT > MAX_PARAMETER THEN DO;                         01425500
               CALL ERROR(CLASS_IR,10);                                         01425600
            END;                                                                01425700
         END;                                                                   01425900
 /*  <ARG LIST>  ::=  <ARG LIST>  ,  <IDENTIFIER>  */                           01426000
         GO TO NEXT_ARG;                                                        01426100
 /*  <TEMPORARY STMT>  ::=  TEMPORARY  <DECLARE BODY>  ;  */                    01426200
         DO;                                                                    01426300
            IF SIMULATING THEN STMT_TYPE = TEMP_TYPE;                           01426310
            CALL STAB_HDR;                                                      01426320
            GO TO DECL_STAT;                                                    01426330
         END;                                                                   01426340
 /*  <DECLARE STATEMENT>  ::=  DECLARE  <DECLARE BODY>  ;  */                   01426400
         DO;                                                                    01426500
            IF PARMS_PRESENT<=0 THEN DO;                                        01426600
               PARMS_WATCH=FALSE;                                               01426700
               IF EXTERNALIZE THEN EXTERNALIZE=4;                               01426800
            END;                                                                01426900
DECL_STAT:                                                                      01427000
            FACTORING=TRUE;                                                     01427100
            IF IC_FOUND>0 THEN DO;                                              01427200
               IC_LINE=INX(IC_PTR1);                                            01427300
               PTR_TOP=IC_PTR1-1;                                               01427400
            END;                                                                01427500
            IC_FOUND=0;                                                         01427600
            IF ATTR_LOC>1 THEN DO;                                              01427700
               CALL OUTPUT_WRITER(LAST_WRITE,ATTR_LOC-1);                       01427800
               IF ^ATTR_FOUND THEN DO;                                          01427900
                  IF (GRAMMAR_FLAGS(1)&ATTR_BEGIN_FLAG)^=0 THEN                 01428000
                     INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT+INDENT_INCR;         01428100
               END;                                                             01428200
               ELSE IF INDENT_LEVEL=SAVE_INDENT_LEVEL THEN                      01428300
                  INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT;                        01428400
               CALL OUTPUT_WRITER(ATTR_LOC,STMT_PTR);                           01428500
            END;                                                                01428600
            ELSE CALL OUTPUT_WRITER(LAST_WRITE,STMT_PTR);                       01428700
            INDENT_LEVEL=SAVE_INDENT_LEVEL;                                     01428800
            LAST_WRITE,SAVE_INDENT_LEVEL=0;                                     01428900
         END;                                                                   01429000
 /*  <DECLARE BODY>  ::=  <DECLARATION LIST>  */                                01429100
         ;                                                                      01429200
                                                                                01429300
 /*  <DECLARE BODY>  ::=  <ATTRIBUTES> , <DECLARATION LIST>  */                 01429400
         DO;                                                                    01429500
            DO I = 0 TO FACTOR_LIM;                                             01429600
               FACTORED_TYPE(I) = 0;                                            01429700
            END;                                                                01429800
            FACTOR_FOUND = FALSE;                                               01429900
         END;                                                                   01430000
                                                                                01430100
 /*  <DECLARATION LIST>  ::=  <DECLARATION>  */                                 01430200
         DO;                                                                    01430300
            SAVE_INDENT_LEVEL = INDENT_LEVEL;                                   01430400
            ATTR_FOUND = FALSE;                                                 01430500
            LAST_WRITE = 0;                                                     01430600
         END;                                                                   01430700
                                                                                01430800
 /*  <DECLARATION LIST>  ::=  <DCL LIST ,>   <DECLARATION>  */                  01430900
         ;                                                                      01431000
                                                                                01431100
 /*  <DCL LIST ,>  ::=  <DECLARATION LIST>  ,  */                               01431200
         DO;                                                                    01431300
            IF ATTR_FOUND THEN                                                  01431400
               DO;                                                              01431500
               IF ATTR_LOC >= 0 THEN                                            01431600
                  DO;                                                           01431700
                  IF ATTR_LOC ^= 0 THEN                                         01431800
                     DO;                                                        01431900
                     CALL OUTPUT_WRITER(LAST_WRITE, ATTR_LOC - 1);              01432000
                     IF INDENT_LEVEL = SAVE_INDENT_LEVEL THEN                   01432100
                        INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT;                  01432200
                  END;                                                          01432300
                  CALL OUTPUT_WRITER(ATTR_LOC, STMT_PTR);                       01432400
                  LAST_WRITE = 0;                                               01432500
               END;                                                             01432600
            END;                                                                01432700
            ELSE                                                                01432800
               DO;                                                              01432900
               ATTR_FOUND = TRUE;                                               01433000
               IF (GRAMMAR_FLAGS(1) & ATTR_BEGIN_FLAG) ^= 0 THEN                01433100
                  DO;  /* <ARRAY, TYPE, & ATTR> FACTORED */                     01433200
                  CALL OUTPUT_WRITER(0, STACK_PTR(MP) - 1);                     01433300
                  LAST_WRITE = STACK_PTR(MP);                                   01433400
                  INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT+INDENT_INCR;            01433500
                  IF ATTR_LOC >= 0 THEN                                         01433600
                     DO;                                                        01433700
                     CALL OUTPUT_WRITER(STACK_PTR(MP), STMT_PTR);               01433800
                     LAST_WRITE = 0;                                            01433900
                  END;                                                          01434000
               END;                                                             01434100
               ELSE                                                             01434200
                  DO;                                                           01434300
                  IF ATTR_LOC >= 0 THEN                                         01434400
                     DO;                                                        01434500
                     CALL OUTPUT_WRITER;                                        01434600
                     LAST_WRITE = 0;                                            01434700
                     INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT;                     01434800
                  END;                                                          01434900
               END;                                                             01435000
            END;                                                                01435100
            IF INIT_EMISSION THEN DO;                                           01435200
               INIT_EMISSION=FALSE;                                             01435300
               CALL EMIT_SMRK(0);                                               01435400
            END;                                                                01435500
         END;                                                                   01435600
                                                                                01435700
 /*  <DECLARE GROUP>  ::=  <DECLARE ELEMENT>  */                                01435800
         ;                                                                      01435900
 /*  <DECLARE GROUP>  ::=  <DECLARE GROUP>  <DECLARE ELEMENT>  */               01436000
         ;                                                                      01436100
 /*  <STRUCTURE STMT>  ::=  STRUCTURE <STRUCT STMT HEAD> <STRUCT STMT TAIL> */  01436200
         DO;                                                                    01436300
            FIXV(SP)=0;                                                         01436400
            FIXL(MP)=FIXL(MPP1);                                                01436500
            FIXV(MP)=FIXV(MPP1);                                                01436600
            FIXL(MPP1)=FIXL(SP);                                                01436700
            FACTORING = TRUE;                                                   01436800
            GO TO STRUCT_GOING_UP;                                              01436900
         END;                                                                   01437000
 /*  <STRUCT STMT HEAD>  ::=  <IDENTIFIER>  :  <LEVEL>  */                      01437100
         DO;                                                                    01437200
NO_ATTR_STRUCT:                                                                 01437300
            BUILDING_TEMPLATE = TRUE;                                           01437400
            ID_LOC,FIXL(MPP1)=FIXL(MP);                                         01437500
            STRUC_SIZE=0;                                                       01437600
            REF_ID_LOC=ID_LOC;                                                  01437700
            IF FIXV(SP)>1 THEN CALL ERROR(CLASS_DQ,1);                          01437800
            FIXV(MP)=1;                                                         01437900
            SYT_CLASS(ID_LOC) = TEMPLATE_CLASS;                                 01438000
            SYT_TYPE(ID_LOC) = TEMPL_NAME;                                      01438100
            IF (ATTRIBUTES & ILL_TEMPL_ATTR) ^= 0 |                             01438200
               (ATTRIBUTES2 & NONHAL_FLAG) ^= 0 THEN DO;    /*DR109024*/        01438200
               CALL ERROR(CLASS_DA,22,SYT_NAME(ID_LOC));                        01438300
               ATTRIBUTES = ATTRIBUTES & ^ILL_TEMPL_ATTR;                       01438400
               ATTRIBUTES2 = ATTRIBUTES2 & ^NONHAL_FLAG;    /*DR109024*/        01438400
               DO_INIT=FALSE;                                                   01438500
            END;                                                                01438600
            IF (ATTRIBUTES & ALDENSE_FLAGS) = 0 THEN                            01438700
               ATTRIBUTES = ATTRIBUTES | (DEFAULT_ATTR & ALDENSE_FLAGS);        01438800
            SYT_FLAGS(ID_LOC)=SYT_FLAGS(ID_LOC)|ATTRIBUTES;                     01438900
            CALL HALMAT_INIT_CONST;                                             01439000
            DO I=0 TO FACTOR_LIM;                                               01439100
               TYPE(I)=0;                                                       01439200
            END;                                                                01439300
            SAVE_INDENT_LEVEL = INDENT_LEVEL;                                   01439400
            IF STACK_PTR(SP) > 0 THEN                                           01439500
               CALL OUTPUT_WRITER(0, STACK_PTR(SP) - 1);                        01439600
            LAST_WRITE = STACK_PTR(SP);                                         01439700
          INDENT_LEVEL = SAVE_INDENT_LEVEL + INDENT_INCR;  /* IN BY ONE LEVEL */01439800
            GO TO STRUCT_GOING_DOWN;                                            01439900
         END;                                                                   01440000
 /*  <STRUCT STMT HEAD>  ::=  <IDENTIFIER> <MINOR ATTR LIST> : <LEVEL> */       01440100
         GO TO NO_ATTR_STRUCT;                                                  01440200
 /*  <STRUCT STMT HEAD> ::= <STRUCT STMT HEAD> <DECLARATION> , <LEVEL>  */      01440300
         DO;                                                                    01440400
STRUCT_GOING_UP:                                                                01440500
            IF (SYT_FLAGS(ID_LOC)&DUPL_FLAG)^=0 THEN  DO;                       01440600
               SYT_FLAGS(ID_LOC)=SYT_FLAGS(ID_LOC)&(^DUPL_FLAG);                01440700
               S=SYT_NAME(ID_LOC);                                              01440800
               TEMP_SYN=SYT_LINK1(FIXL(MP));                                    01440900
               DO WHILE TEMP_SYN^=ID_LOC;                                       01441000
                  IF S=SYT_NAME(TEMP_SYN) THEN DO;                              01441100
                     CALL ERROR(CLASS_DQ,9,S);                                  01441200
                     S='';                                                      01441300
                  END;                                                          01441400
                  TEMP_SYN=SYT_LINK2(TEMP_SYN);                                 01441500
               END;                                                             01441600
            END;                                                                01441700
            IF FIXV(SP)>FIXV(MP) THEN DO;                                       01441800
               IF FIXV(SP)>FIXV(MP)+1 THEN CALL ERROR(CLASS_DQ,2);              01441900
               FIXV(MP)=FIXV(MP)+1;                                             01442000
               IF (TYPE|CLASS)^=0 THEN                                          01442100
                CALL ERROR(CLASS_DT, 5, SYT_NAME(ID_LOC));  /* TYPE NOT LEGAL */01442200
               IF (ATTRIBUTES&ILL_MINOR_STRUC)^=0 | NAME_IMPLIED |              01442300
                  (ATTRIBUTES2 & NONHAL_FLAG)^=0 THEN DO; /*DR109024*/          01442300
                  CALL ERROR(CLASS_DA, 20, SYT_NAME(ID_LOC));                   01442400
                  ATTRIBUTES = ATTRIBUTES & (^ILL_MINOR_STRUC);                 01442500
                  ATTRIBUTES2 = ATTRIBUTES2 & (^NONHAL_FLAG); /*DR109024*/      01442500
                  NAME_IMPLIED=FALSE;                                           01442600
                  DO_INIT = 0;                                                  01442700
               END;                                                             01442800
               IF N_DIM ^= 0 THEN DO;  /* DR 145 */                             01442900
                  CALL ERROR(CLASS_DA, 21, SYT_NAME(ID_LOC));                   01443000
                  N_DIM = 0;                                                    01443100
                  ATTRIBUTES = ATTRIBUTES & (^ARRAY_FLAG);                      01443200
               END;                                                             01443300
               SYT_CLASS(ID_LOC) = TEMPLATE_CLASS;                              01443400
               TYPE = MAJ_STRUC;                                                01443500
               IF (ATTRIBUTES & ALDENSE_FLAGS) = 0 THEN                         01443600
                ATTRIBUTES = ATTRIBUTES | (SYT_FLAGS(FIXL(MP)) & ALDENSE_FLAGS);01443700
 /* GIVE ALIGNED/DENSE OF PARENT IF NOT LOCALLY SPECIFIED */                    01443800
               IF (ATTRIBUTES&RIGID_FLAG)=0 THEN                                01443900
                  ATTRIBUTES=ATTRIBUTES|(SYT_FLAGS(FIXL(MP))&RIGID_FLAG);       01444000
               CALL SET_SYT_ENTRIES;                                            01444100
               IF STACK_PTR(SP) > 0 THEN                                        01444200
                  CALL OUTPUT_WRITER(LAST_WRITE, STACK_PTR(SP) - 1);            01444300
               LAST_WRITE = STACK_PTR(SP);                                      01444400
               INDENT_LEVEL = SAVE_INDENT_LEVEL + (FIXV(MP) * INDENT_INCR);     01444500
STRUCT_GOING_DOWN:                                                              01444600
               CALL PUSH_INDIRECT(1);                                           01444700
               LOC_P(PTR_TOP)=FIXL(MP);                                         01444800
               SYT_LINK1(FIXL(MPP1))=FIXL(MPP1)+1;                              01444900
               FIXL(MP)=FIXL(MPP1);                                             01445000
            END;                                                                01445100
            ELSE DO;                                                            01445200
               TEMP_SYN=FIXL(MPP1);                                             01445300
               FIXL(SP)=FIXL(MP);                                               01445400
               DO WHILE FIXV(SP)<FIXV(MP);                                      01445500
                  SYT_LINK2(FIXL(MPP1))=-FIXL(MP);                              01445600
                  FIXL(MPP1)=FIXL(MP);                                          01445700
                  FIXL(MP)=LOC_P(PTR_TOP);                                      01445800
                  PTR_TOP=PTR_TOP-1;                                            01445900
                  FIXV(MP)=FIXV(MP)-1;                                          01446000
               END;                                                             01446100
               IF TYPE=0 THEN TYPE=DEFAULT_TYPE;                                01446200
               ELSE IF TYPE=MAJ_STRUC THEN IF ^NAME_IMPLIED THEN                01446300
                  IF STRUC_PTR=REF_ID_LOC THEN DO;                              01446400
                  CALL ERROR(CLASS_DT,6);                                       01446500
                  SYT_FLAGS(REF_ID_LOC)=SYT_FLAGS(REF_ID_LOC)|EVIL_FLAG;        01446600
               END;                                                             01446700
               IF CLASS^=0 THEN DO;                                             01446800
                  IF NAME_IMPLIED THEN DO;                                      01446900
                     ATTRIBUTES=ATTRIBUTES|DEFINED_LABEL;                       01447000
               IF TYPE=PROC_LABEL THEN CALL ERROR(CLASS_DA,14,SYT_NAME(ID_LOC));01447100
                  ELSE IF CLASS=2 THEN CALL ERROR(CLASS_DA,13,SYT_NAME(ID_LOC));01447200
                  END;                                                          01447300
                  ELSE DO;                                                      01447400
                     CALL ERROR(CLASS_DT,7,SYT_NAME(ID_LOC));                   01447500
                     CLASS=0;                                                   01447600
                     IF TYPE>ANY_TYPE THEN TYPE=DEFAULT_TYPE;                   01447700
                  END;                                                          01447800
               END;                                                             01447900
               CALL CHECK_CONSISTENCY;                                          01448000
               IF (ATTRIBUTES&ILL_TERM_ATTR(NAME_IMPLIED))^=0 |                 01448100
                  (ATTRIBUTES2&NONHAL_FLAG)^=0 THEN DO;  /*DR109024*/           01448100
                  CALL ERROR(CLASS_DA, 23, SYT_NAME(ID_LOC));                   01448200
 /*  ILL_NAME_ATTR MUST BE SUBSET OF ILL_TERM_ATTR  */                          01448300
                  ATTRIBUTES=(^ILL_TERM_ATTR(NAME_IMPLIED))&ATTRIBUTES;         01448400
                  ATTRIBUTES2=(^NONHAL_FLAG)&ATTRIBUTES2; /*DR109024*/          01448400
                  DO_INIT=FALSE;                                                01448500
               END;                                                             01448600
               SYT_CLASS(ID_LOC)=TEMPLATE_CLASS+CLASS;                          01448700
               IF TYPE=MAJ_STRUC THEN CALL CHECK_STRUC_CONFLICTS;               01448800
               ELSE IF TYPE=EVENT_TYPE THEN CALL CHECK_EVENT_CONFLICTS;         01448900
               IF (ATTRIBUTES&SD_FLAGS)=0 THEN                                  01449000
                  IF (TYPE>=MAT_TYPE)&(TYPE<=INT_TYPE) THEN                     01449100
                  ATTRIBUTES=ATTRIBUTES|(DEFAULT_ATTR&SD_FLAGS);                01449200
               IF (ATTRIBUTES & ALDENSE_FLAGS) = 0 THEN                         01449300
 /*CR13236*/      IF (^NAME_IMPLIED) & ((ATTRIBUTES&ARRAY_FLAG)=0) &
 /*CR13236*/         (TYPE=BIT_TYPE) THEN
                     ATTRIBUTES=ATTRIBUTES|(SYT_FLAGS(FIXL(SP))&ALDENSE_FLAGS); 01449400
 /*CR13236*/      ELSE
 /*CR13236*/         ATTRIBUTES=ATTRIBUTES|ALIGNED_FLAG;
               IF (ATTRIBUTES&RIGID_FLAG)=0 THEN                                01449500
                  ATTRIBUTES=ATTRIBUTES|(SYT_FLAGS(FIXL(SP))&RIGID_FLAG);       01449600
               IF NAME_IMPLIED THEN SYT_FLAGS(REF_ID_LOC)=SYT_FLAGS(REF_ID_LOC) 01449700
                  |MISC_NAME_FLAG;                                              01449800
               CALL SET_SYT_ENTRIES;                                            01449900
               STRUC_SIZE=ICQ_TERM#(ID_LOC)*ICQ_ARRAY#(ID_LOC)+STRUC_SIZE;      01450000
               NAME_IMPLIED=FALSE;                                              01450100
               IF FIXV(SP)>0 THEN DO;                                           01450200
                  SYT_LINK2(FIXL(MPP1))=TEMP_SYN+1;                             01450300
                  IF STACK_PTR(SP) > 0 THEN                                     01450400
                     CALL OUTPUT_WRITER(LAST_WRITE, STACK_PTR(SP) - 1);         01450500
                  LAST_WRITE = STACK_PTR(SP);                                   01450600
                  INDENT_LEVEL = SAVE_INDENT_LEVEL + (FIXV(MP) * INDENT_INCR);  01450700
               END;                                                             01450800
               ELSE DO;                                                         01450900
                  BUILDING_TEMPLATE=FALSE;                                      01451000
                  CALL OUTPUT_WRITER(LAST_WRITE, STMT_PTR);                     01451100
                  INDENT_LEVEL = SAVE_INDENT_LEVEL;                             01451200
                  LAST_WRITE, SAVE_INDENT_LEVEL = 0;                            01451300
               END;                                                             01451400
            END;                                                                01451500
         END;                                                                   01451600
 /*  <STRUCT STMT TAIL>  ::=  <DECLARATION>  ;  */                              01451700
         ;                                                                      01451800
 /* <STRUCT SPEC> ::= <STRUCT TEMPLATE> <STRUCT SPEC BODY>  */                  01451900
         DO;                                                                    01452000
            STRUC_PTR = FIXL(MP);                                               01452100
            IF SYT_TYPE(STRUC_PTR) ^= TEMPL_NAME THEN                           01452110
               SYT_FLAGS(STRUC_PTR) = SYT_FLAGS(STRUC_PTR) | EVIL_FLAG;         01452120
            CALL SET_XREF(STRUC_PTR,XREF_REF);                                  01452200
            NOSPACE;                                                            01452300
         END;                                                                   01452400
 /* <STRUCT SPEC BODY> ::= - STRUCTURE */                                       01452500
         NOSPACE;                                                               01452600
 /* <STRUCT SPEC BODY> ::= <STRUCT SPEC HEAD> <LITERAL EXP OR*> ) */            01452700
         DO;                                                                    01452800
            CONTEXT = DECLARE_CONTEXT;                                          01452900
            I = FIXV(MPP1);                                                     01453000
            IF ^((I > 1) & (I <= ARRAY_DIM_LIM) | (I = -1)) THEN DO;            01453100
               CALL ERROR(CLASS_DD, 11);                                        01453200
               STRUC_DIM = 2;  /* A DEFAULT */                                  01453300
            END;                                                                01453400
            ELSE STRUC_DIM = I;                                                 01453500
         END;                                                                   01453600
 /* <STRUCT SPEC HEAD> ::= - STRUCTURE (  */                                    01453700
         DO;                                                                    01453800
            NOSPACE;                                                            01453900
            TOKEN_FLAGS(STACK_PTR(MPP1))=TOKEN_FLAGS(STACK_PTR(MPP1))|"20";     01454000
         END;                                                                   01454100
 /*  <DECLARATION>  ::=  <NAME ID>  */                                          01454200
         IF ^BUILDING_TEMPLATE THEN DO;                                         01454300
            IF NAME_IMPLIED THEN ATTR_LOC=STACK_PTR(MP);                        01454400
            ELSE ATTR_LOC=-1;                                                   01454500
            GO TO SPEC_VAR;                                                     01454600
         END;                                                                   01454700
 /*  <DECLARATION>  ::=  <NAME ID>  <ATTRIBUTES>  */                            01454800
         IF ^BUILDING_TEMPLATE THEN DO;                                         01454900
            IF (TOKEN_FLAGS(0)&7)= 7 THEN ATTR_LOC=0;           /*DR109076*/    01455000
            ELSE IF (TOKEN_FLAGS(1)&7)= 7 THEN ATTR_LOC=1;      /*DR109076*/    01455000
                 ELSE ATTR_LOC=MAX(0,STACK_PTR(MP));   /*DR111320,DR109076*/    01455000
SPEC_VAR:                                                                       01455100
            DO_INIT=TRUE;                                                       01455200
            CALL CHECK_CONFLICTS;                                               01455300
            I=SYT_FLAGS(ID_LOC);                                                01455400
            IF (I&PARM_FLAGS)^=0 THEN DO;                                       01455500
               PARMS_PRESENT=PARMS_PRESENT-1;                                   01455600
               IF PARMS_PRESENT=0 & PARMS_WATCH THEN COMSUB_END = NDECSY;       01455650
               IF (ATTRIBUTES&ILL_INIT_ATTR)^=0 THEN DO;                        01455700
                  CALL ERROR(CLASS_DI,12,VAR(MP));                              01455800
                  DO_INIT=FALSE;                                                01455900
                  ATTRIBUTES=ATTRIBUTES&(^ILL_INIT_ATTR);                       01456000
               END;                                                             01456100
               IF CLASS>0&(^NAME_IMPLIED) THEN DO;                              01456200
                  CALL ERROR(CLASS_D,1,VAR(MP));                                01456300
                  NONHAL,CLASS=0;                                               01456400
                  IF TYPE>ANY_TYPE THEN TYPE=DEFAULT_TYPE;                      01456500
               END;                                                             01456600
  /*CR12935  REMOTE NOW OK FOR ASSIGN PARMS & IGNORED FOR INPUT PARMS */
  /*CR12935  SO REMOVE D14 ERROR MESSAGE.                             */
            END;                                                                01457100
            ELSE IF PARMS_WATCH THEN CALL ERROR(CLASS_D,15);                    01457200
            IF TYPE=EVENT_TYPE THEN CALL CHECK_EVENT_CONFLICTS;                 01457300
            IF ^NAME_IMPLIED THEN DO;                                           01457400
               IF NONHAL>0 THEN DO;                                             01457500
                  IF TYPE=PROC_LABEL|CLASS=2 THEN DO;                           01457600
                     ATTRIBUTES=ATTRIBUTES|EXTERNAL_FLAG|DEFINED_LABEL;         01457700
                     SYT_ARRAY(ID_LOC)=NONHAL|"FF00";                           01457800
                     GO TO MODE_CHECK;                                          01457900
                  END;                                                          01458000
                  ELSE DO;                                                      01458100
                     CALL ERROR(CLASS_D,11,VAR(MP));                            01458200
                     /*** DR108643 - DISCONNECT SYT_FLAGS WITH NONHAL */
                     /*   THIS ALSO DISCONNECTS ATTRIBUTES WITH NONHAL*/
                     SYT_FLAGS2(ID_LOC) = SYT_FLAGS2(ID_LOC) &                  01458300
                        (^NONHAL_FLAG);
                     /*** END DR108643 ***/
                  END;                                                          01458400
               END;                                                             01458500
               ELSE IF CLASS=2 THEN DO;                                         01458600
MODE_CHECK:                                                                     01458700
               IF BLOCK_MODE(NEST)=CMPL_MODE THEN CALL ERROR(CLASS_D,2,VAR(MP));01458800
               END;                                                             01458900
               ELSE IF CLASS=1 THEN DO;                                         01459000
                  IF TYPE=TASK_LABEL THEN DO;                                   01459100
                     IF NEST>1|BLOCK_MODE(1)^=PROG_MODE THEN                    01459200
                        CALL ERROR(CLASS_PT,1);                                 01459300
                  END;                                                          01459400
                  ELSE DO;                                                      01459500
                     CALL ERROR(CLASS_DN,1,VAR(MP));                            01459600
                     CLASS=0;                                                   01459700
                     TYPE=DEFAULT_TYPE;                                         01459800
                  END;                                                          01459900
               END;                                                             01460000
               IF CLASS^=0 THEN DO;                                             01460100
                  IF (ATTRIBUTES&ILL_INIT_ATTR)^=0 THEN DO;                     01460200
                     CALL ERROR(CLASS_DI,13,VAR(MP));                           01460300
                     ATTRIBUTES=ATTRIBUTES&(^ILL_INIT_ATTR);                    01460400
                     DO_INIT=FALSE;                                             01460500
                  END;                                                          01460600
                  IF TEMPORARY_IMPLIED THEN DO;                                 01460700
                     CALL ERROR(CLASS_D,8,VAR(MP));                             01460800
                     CLASS=0;                                                   01460900
                     IF TYPE>ANY_TYPE THEN TYPE=DEFAULT_TYPE;                   01461000
                  END;                                                          01461100
               END;                                                             01461200
               ELSE DO;                                                         01461300
                  IF TEMPORARY_IMPLIED THEN DO;                                 01461400
                     IF (ATTRIBUTES&ILL_TEMPORARY_ATTR)^=0 |                    01461500
                        (ATTRIBUTES2&NONHAL_FLAG)^=0 THEN DO; /*DR109024*/      01461500
                        CALL ERROR(CLASS_D,8,VAR(MP));                          01461600
                        ATTRIBUTES=ATTRIBUTES&(^ILL_TEMPORARY_ATTR);            01461700
                        ATTRIBUTES2=ATTRIBUTES2&(^NONHAL_FLAG); /*DR109024*/    01461700
                        DO_INIT=FALSE;                                          01461800
                     END;                                                       01461900
                  END;                                                          01462000
                  ELSE DO;                                                      01462100
FIX_AUTSTAT:                                                                    01462200
                     IF (ATTRIBUTES&ALDENSE_FLAGS)=0 THEN                       01462300
                        ATTRIBUTES=ATTRIBUTES|(DEFAULT_ATTR&ALDENSE_FLAGS);     01462400
                     IF BLOCK_MODE(NEST)^=CMPL_MODE THEN                        01462500
                        IF (I&PARM_FLAGS)=0 THEN                                01462600
                        IF (ATTRIBUTES&AUTSTAT_FLAGS)=0 THEN                    01462700
                        ATTRIBUTES=ATTRIBUTES|(DEFAULT_ATTR&AUTSTAT_FLAGS);     01462800
                  END;                                                          01462900
               END;                                                             01463000
            END;                                                                01463100
            ELSE DO;                                                            01463200
/*CR13212- ADD ILLEGAL TEMP ATTRIBUTE CHECKING FROM ABOVE FOR NAME TEMPS TOO */
/*CR13212*/    IF TEMPORARY_IMPLIED THEN DO;
/*CR13212*/       IF CLASS^=0 THEN DO;
/*CR13212*/          CALL ERROR(CLASS_D,8,VAR(MP));
/*CR13212*/          CLASS=0;
/*CR13212*/          IF TYPE>ANY_TYPE THEN TYPE=DEFAULT_TYPE;
/*CR13212*/       END;
/*CR13212- ONLY DIFFERENCE FOR NAME TEMPS IS THAT REMOTE IS LEGAL */
/*CR13212*/       ELSE IF (((ATTRIBUTES&ILL_TEMPORARY_ATTR)^=0) &
/*CR13212*/                ((ATTRIBUTES&ILL_TEMPORARY_ATTR)^=REMOTE_FLAG)) |
/*CR13212*/          (ATTRIBUTES2&NONHAL_FLAG)^=0 THEN DO;
/*CR13212*/          CALL ERROR(CLASS_D,8,VAR(MP));
/*CR13212*/          ATTRIBUTES=ATTRIBUTES&(^ILL_TEMPORARY_ATTR);
/*CR13212*/          ATTRIBUTES2=ATTRIBUTES2&(^NONHAL_FLAG);
/*CR13212*/          DO_INIT=FALSE;
/*CR13212*/       END;
/*CR13212*/    END;
               IF (ATTRIBUTES&ILL_NAME_ATTR)^=0 |                               01463300
                  (ATTRIBUTES2&NONHAL_FLAG)^=0 THEN DO;   /*DR109024*/          01463300
                  CALL ERROR(CLASS_D,12,VAR(MP));                               01463400
                  ATTRIBUTES=ATTRIBUTES&(^ILL_NAME_ATTR);                       01463500
                  ATTRIBUTES2=ATTRIBUTES2&(^NONHAL_FLAG); /*DR109024*/          01463500
               END;                                                             01463600
               IF TYPE=PROC_LABEL THEN CALL ERROR(CLASS_DA,14,VAR(MP));         01463700
               ELSE IF CLASS=2 THEN CALL ERROR(CLASS_DA,13,VAR(MP));            01463800
               IF CLASS>0 THEN ATTRIBUTES=ATTRIBUTES|DEFINED_LABEL;             01463900
               GO TO FIX_AUTSTAT;                                               01464000
            END;                                                                01464100
            SYT_CLASS(ID_LOC)=VAR_CLASS(CLASS);                                 01464200
            IF TYPE=MAJ_STRUC THEN CALL CHECK_STRUC_CONFLICTS;                  01464300
           IF (ATTRIBUTES&SD_FLAGS)=0 THEN IF TYPE>=MAT_TYPE&TYPE<=INT_TYPE THEN01464400
               ATTRIBUTES=ATTRIBUTES|(DEFAULT_ATTR&SD_FLAGS);                   01464500
            CALL SET_SYT_ENTRIES;                                               01464600
            NAME_IMPLIED=FALSE;                                                 01464700
            IF TEMPORARY_IMPLIED THEN DO;                                       01464800
               ATTR_INDENT=10;                                                  01464900
               IF DO_CHAIN(DO_LEVEL)=0 THEN DO;                                 01465000
                  DO_CHAIN(DO_LEVEL)=ID_LOC;                                    01465100
                  CALL HALMAT_POP(XTDCL,1,0,0);                                 01465200
                  CALL HALMAT_PIP(ID_LOC,XSYT,0,0);                             01465300
               END;                                                             01465400
               ELSE SYT_LINK1(DO_CHAIN)=ID_LOC;                                 01465500
               DO_CHAIN=ID_LOC;                                                 01465600
            END;                                                                01465700
            ELSE ATTR_INDENT=8;                                                 01465800
/*-RSJ------------------ #DFLAGS ----CR11096-------------------------*/
/*SET REMOTE ATTRIBUTE FOR ALL NON-NAME #D DATA WHEN THE             */
/*DATA_REMOTE DIRECTIVE IS IN EFFECT                                 */
/*(MUST NOT BE AUTOMATIC OR A PARAMETER TO BE #D DATA.)              */
            IF DATA_REMOTE THEN DO;
               IF ((SYT_FLAGS(ID_LOC) & NAME_FLAG) = 0) &
                  ((SYT_FLAGS(ID_LOC) & TEMPORARY_FLAG) = 0) &
   /* DR110231    DON'T SET REMOTE FLAG FOR TASKS, FUNCTIONS,  */
   /* DR110231    OR PROCEDURES                                */
   /* DR110231 */ (SYT_TYPE(ID_LOC) ^= TASK_LABEL) &
   /* DR110231 */ (SYT_TYPE(ID_LOC) ^= PROC_LABEL) &
   /* DR110231 */ (SYT_CLASS(ID_LOC) ^= FUNC_CLASS) &
                  /* DR107308 - PART 1. SET THE REMOTE FLAG IF DATA  */
                  /* IS DECLARED IN A NON "EXTERNAL" BLOCK.          */
   /* DR107308 */ ((SYT_FLAGS(BLOCK_SYTREF(NEST)) & EXTERNAL_FLAG)=0) &
                 ^(((SYT_FLAGS(ID_LOC) & AUTO_FLAG) ^= 0) &                     60101014
                   ((SYT_FLAGS(BLOCK_SYTREF(NEST)) & REENTRANT_FLAG) ^= 0)) &   60102014
                  ((SYT_FLAGS(ID_LOC) & PARM_FLAGS) = 0) THEN DO;
                   IF (SYT_FLAGS(ID_LOC) & REMOTE_FLAG) ^= 0 THEN
                      CALL ERROR(CLASS_XR,3);
/*#DEVENT*/        IF SYT_TYPE(ID_LOC) = EVENT_TYPE THEN                        01457360
                      CALL ERROR(CLASS_DA,9);                                   01457370
                   SYT_FLAGS(ID_LOC) = SYT_FLAGS(ID_LOC) | REMOTE_FLAG;
               END;
            END;
/*-------------------------------------------------------------------*/
            ELSE IF SDL_OPTION &                           /* CR13245 */
                    ((SYT_FLAGS(ID_LOC) & NAME_FLAG)=0) &  /* CR13245 */
                    ((SYT_FLAGS(ID_LOC) & PARM_FLAGS)=0) & /* CR13245 */
                    ((SYT_FLAGS(ID_LOC) & REMOTE_FLAG)^=0) /* CR13245 */
                 THEN CALL ERROR(CLASS_XR, 5);             /* CR13245 */
            IF ((SYT_FLAGS(ID_LOC) & NAME_FLAG)=0) &                 /*CR13813*/
               ((SYT_FLAGS(ID_LOC) & INPUT_PARM)^=0) &               /*CR13813*/
               ((SYT_FLAGS(ID_LOC) & REMOTE_FLAG)^=0) THEN DO;       /*CR13813*/
                 SYT_FLAGS(ID_LOC)=SYT_FLAGS(ID_LOC) & ^REMOTE_FLAG; /*CR13813*/
                 CALL ERROR(CLASS_YD, 100);                          /*CR13813*/
            END;                                                     /*CR13813*/
         END;                                                                   01465900
 /*  <NAME ID>   ::=  <IDENTIFIER>  */                                          01466000
         ID_LOC=FIXL(MP);                                                       01466100
 /*  <NAME ID>  ::=  <IDENTIFIER> NAME  */                                      01466200
         DO;                                                                    01466300
/*CR13212 - REMOVED DN2 ERROR */
            NAME_IMPLIED=TRUE; /*CR13212*/                                      01466500
            ID_LOC=FIXL(MP);                                                    01466600
         END;                                                                   01466700
 /* <ATTRIBUTES> ::= <ARRAY SPEC> <TYPE & MINOR ATTR>  */                       01466800
         GO TO CHECK_ARRAY_SPEC;                                                01466900
                                                                                01467000
 /*  <ATTRIBUTES> ::= <ARRAY SPEC>  */                                          01467100
CHECK_ARRAY_SPEC:                                                               01467200
         DO;                                                                    01467300
            IF N_DIM > 1 THEN                                                   01467400
               IF STARRED_DIMS > 0 THEN DO;                                     01467500
               CALL ERROR(CLASS_DD, 6);                                         01467600
               DO I = 0 TO N_DIM - 1;                                           01467700
                  IF S_ARRAY(I) = -1 THEN                                       01467800
                     S_ARRAY(I) = 2;  /* DEFAULT */                             01467900
               END;                                                             01468000
            END;                                                                01468100
            GO TO MAKE_ATTRIBUTES;                                              01468200
         END;                                                                   01468300
                                                                                01468400
 /*  <ATTRIBUTES> ::= <TYPE & MINOR ATTR>  */                                   01468500
         DO;                                                                    01468600
MAKE_ATTRIBUTES:                                                                01468700
            GRAMMAR_FLAGS(STACK_PTR(MP)) =                                      01468800
               GRAMMAR_FLAGS(STACK_PTR(MP)) | ATTR_BEGIN_FLAG;                  01468900
            CALL CHECK_CONSISTENCY;                                             01469000
            IF FACTORING THEN                                                   01469100
               DO;                                                              01469200
               DO I = 0 TO FACTOR_LIM;                                          01469300
                  FACTORED_TYPE(I) = TYPE(I);                                   01469400
                  TYPE(I) = 0;                                                  01469500
               END;                                                             01469600
               FACTOR_FOUND = TRUE;                                             01469700
               IF FACTORED_IC_FND THEN                                          01469800
                  DO;                                                           01469900
                  IC_FOUND = 1;  /* FOR HALMAT_INIT_CONST */                    01470000
                  IC_PTR1 = FACTORED_IC_PTR;                                    01470100
               END;                                                             01470200
            END;                                                                01470300
         END;                                                                   01470400
                                                                                01470500
 /*  <ARRAY SPEC> ::= <ARRAY HEAD> <LITERAL EXP OR *> )  */                     01470600
         DO;                                                                    01470700
            CONTEXT = DECLARE_CONTEXT;                                          01470800
            GO TO ARRAY_SPEC;                                                   01470900
         END;                                                                   01471000
 /*  <ARRAY SPEC>  ::=  FUNCTION  */                                            01471100
         CLASS=2;                                                               01471200
 /*  <ARRAY SPEC>  ::=  PROCEDURE  */                                           01471300
         DO;                                                                    01471400
            TYPE=PROC_LABEL;                                                    01471500
            CLASS=1;                                                            01471600
         END;                                                                   01471700
 /*  <ARRAY SPEC>  ::= PROGRAM  */                                              01471800
         DO;                                                                    01471900
            TYPE=PROG_LABEL;                                                    01472000
            CLASS=1;                                                            01472100
         END;                                                                   01472200
 /*  <ARRAY SPEC>  ::=  TASK   */                                               01472300
         DO;                                                                    01472400
            TYPE=TASK_LABEL;                                                    01472500
            CLASS=1;                                                            01472600
         END;                                                                   01472700
 /*  <ARRAY HEAD> ::= ARRAY (  */                                               01472800
         DO;                                                                    01472900
            STARRED_DIMS, N_DIM = 0;                                            01473000
            DO I = 0 TO N_DIM_LIM;                                              01473100
               S_ARRAY(I) = 0;                                                  01473200
            END;                                                                01473300
            FIXL(SP),FIXV(SP)=ARRAY_FLAG;                                       01473400
            GO TO INCORPORATE_ATTR;                                             01473500
         END;                                                                   01473600
                                                                                01473700
 /*  <ARRAY HEAD> ::= <ARRAY HEAD> <LITERAL_EXP OR *> ,  */                     01473800
ARRAY_SPEC:                                                                     01473900
         DO;                                                                    01474000
            IF N_DIM >= N_DIM_LIM THEN                                          01474100
               CALL ERROR(CLASS_DD, 3);                                         01474200
            ELSE DO;                                                            01474300
               K = 2;  /* A DEFAULT */                                          01474400
               I = FIXV(MPP1);                                                  01474500
               IF ^(I > 1 & I <= ARRAY_DIM_LIM | I = -1) THEN                   01474600
                  CALL ERROR(CLASS_DD, 1);                                      01474700
               ELSE K = I;                                                      01474800
               IF K = -1 THEN STARRED_DIMS = STARRED_DIMS + 1;                  01474900
               S_ARRAY(N_DIM) = K;                                              01475000
               N_DIM = N_DIM + 1;                                               01475100
            END;                                                                01475200
         END;                                                                   01475300
                                                                                01475400
 /*  <TYPE & MINOR ATTR> ::= <TYPE SPEC>  */                                    01475500
         GO TO SPEC_TYPE;                                                       01475600
                                                                                01475700
 /*  <TYPE & MINOR ATTR> ::= <TYPE SPEC> <MINOR ATTR LIST>  */                  01475800
         DO;                                                                    01475900
SPEC_TYPE:                                                                      01476000
            IF CLASS THEN DO;                                                   01476100
               CALL ERROR(CLASS_DC,1);                                          01476200
               CLASS=0;                                                         01476300
            END;                                                                01476400
         END;                                                                   01476500
 /*  <TYPE & MINOR ATTR> ::= <MINOR ATTR LIST>  */                              01476600
         ;                                                                      01476700
                                                                                01476800
 /*  <TYPE SPEC> ::= <STRUCT SPEC>  */                                          01476900
         TYPE = MAJ_STRUC;                                                      01477000
                                                                                01477100
 /*  <TYPE SPEC>  ::=  <BIT SPEC>  */                                           01477200
         ;                                                                      01477300
 /*  <TYPE SPEC>  ::=  <CHAR SPEC>  */                                          01477400
         ;                                                                      01477500
 /*  <TYPE SPEC>  ::=  <ARITH SPEC>  */                                         01477600
         ;                                                                      01477700
 /*  <TYPE SPEC>  ::=  EVENT  */                                                01477800
         TYPE=EVENT_TYPE;                                                       01477900
                                                                                01478000
 /*  <BIT SPEC>  ::=  BOOLEAN  */                                               01478100
         DO;                                                                    01478200
            TYPE = BIT_TYPE;                                                    01478300
            BIT_LENGTH = 1;  /* BOOLEAN */                                      01478400
         END;                                                                   01478500
                                                                                01478600
                                                                                01478700
 /*  <BIT SPEC>  ::=  BIT  (  <LITERAL EXP OR *>  )  */                         01478800
         DO;                                                                    01478900
            NOSPACE;                                                            01479000
            CONTEXT = DECLARE_CONTEXT;                                          01479100
            J=FIXV(MP+2);                                                       01479200
            K = DEF_BIT_LENGTH;                                                 01479300
            IF J = -1 THEN CALL ERROR(CLASS_DS, 4);  /* "*" ILLEGAL */          01479400
            ELSE IF (J ^> 0) | (J > BIT_LENGTH_LIM) THEN                        01479500
               CALL ERROR(CLASS_DS, 1);                                         01479600
            ELSE K = J;                                                         01479700
            TYPE = BIT_TYPE;                                                    01479800
            BIT_LENGTH = K;                                                     01479900
         END;                                                                   01480000
                                                                                01480100
                                                                                01480200
 /*  <CHAR SPEC>  ::=  CHARACTER  (  <LITERAL EXP OR *>  )  */                  01480300
         DO;                                                                    01480400
            NOSPACE;                                                            01480500
            CONTEXT = DECLARE_CONTEXT;                                          01480600
            J=FIXV(MP+2);                                                       01480700
            K = DEF_CHAR_LENGTH;                                                01480800
            IF J=-1 THEN K=J;                                                   01480900
            ELSE IF (J ^> 0) | (J > CHAR_LENGTH_LIM) THEN                       01481000
               CALL ERROR(CLASS_DS, 2);                                         01481100
            ELSE K = J;                                                         01481200
            CHAR_LENGTH = K;                                                    01481300
            TYPE = CHAR_TYPE;                                                   01481400
         END;                                                                   01481500
                                                                                01481600
 /*  <ARITH SPEC>  ::=  <PREC SPEC>  */                                         01481700
         DO;                                                                    01481800
            ATTR_MASK = ATTR_MASK | FIXL(MP);                                   01481900
            ATTRIBUTES = ATTRIBUTES | FIXV(MP);                                 01482000
         END;                                                                   01482100
                                                                                01482200
 /*  <ARITH SPEC>  ::=  <SQ DQ NAME>  */                                        01482300
         ;                                                                      01482400
                                                                                01482500
 /*  <ARITH SPEC>  ::=  <SQ DQ NAME>  <PREC SPEC>  */                           01482600
         DO;                                                                    01482700
            ATTR_MASK = ATTR_MASK | FIXL(SP);                                   01482800
            ATTRIBUTES = ATTRIBUTES | FIXV(SP);                                 01482900
         END;                                                                   01483000
                                                                                01483100
 /*  <SQ DQ NAME> ::= <DOUBLY QUAL NAME HEAD> <LITERAL EXP OR *> )  */          01483200
         DO;                                                                    01483300
            CONTEXT = DECLARE_CONTEXT;                                          01483400
            I = FIXV(MPP1);  /* VALUE */                                        01483500
            TYPE = FIXL(MP);                                                    01483600
            IF TYPE = VEC_TYPE THEN                                             01483700
               DO;                                                              01483800
               IF I = -1 THEN                                                   01483900
                  DO;                                                           01484000
                  CALL ERROR(CLASS_DD, 7);                                      01484100
                  I = 3;                                                        01484200
               END;                                                             01484300
               ELSE IF (I ^> 1) | (I > VEC_LENGTH_LIM) THEN                     01484400
                  DO;                                                           01484500
                  CALL ERROR(CLASS_DD, 5);                                      01484600
                  I = 3;                                                        01484700
               END;                                                             01484800
               VEC_LENGTH = I;                                                  01484900
            END;                                                                01485000
            ELSE  /* MATRIX */                                                  01485100
               DO;                                                              01485200
               IF I = -1 THEN                                                   01485300
                  DO;                                                           01485400
                  CALL ERROR(CLASS_DD,9);                                       01485500
                  I = 3;                                                        01485600
               END;                                                             01485700
               ELSE IF (I ^> 1) | (I > MAT_DIM_LIM) THEN                        01485800
                  DO;                                                           01485900
                  CALL ERROR(CLASS_DD, 4);                                      01486000
                  I = 3;                                                        01486100
               END;                                                             01486200
               MAT_LENGTH = SHL(FIXV(MP), 8) + (I & "FF");                      01486300
            END;                                                                01486400
         END;                                                                   01486500
                                                                                01486600
 /*  <SQ DQ NAME> ::= INTEGER  */                                               01486700
         TYPE = INT_TYPE;                                                       01486800
                                                                                01486900
 /*  <SQ DQ NAME> ::= SCALAR  */                                                01487000
         TYPE = SCALAR_TYPE;                                                    01487100
                                                                                01487200
 /*  <SQ DQ NAME> ::= VECTOR  */                                                01487300
         DO;                                                                    01487400
            TYPE = VEC_TYPE;                                                    01487500
            VEC_LENGTH = DEF_VEC_LENGTH;                                        01487600
         END;                                                                   01487700
                                                                                01487800
 /*  <SQ DQ NAME> ::= MATRIX  */                                                01487900
         DO;                                                                    01488000
            TYPE = MAT_TYPE;                                                    01488100
            MAT_LENGTH = DEF_MAT_LENGTH;                                        01488200
         END;                                                                   01488300
                                                                                01488400
 /*  <DOUBLY QUAL NAME HEAD> ::= VECTOR (  */                                   01488500
         DO;                                                                    01488600
            NOSPACE;                                                            01488700
            FIXL(MP) = VEC_TYPE;                                                01488800
         END;                                                                   01488900
                                                                                01489000
 /*  <DOUBLY QUAL NAME HEAD>  ::=  MATRIX  (  <LITERAL EXP OR *>  ,  */         01489100
         DO;                                                                    01489200
            NOSPACE;                                                            01489300
            FIXL(MP) = MAT_TYPE;                                                01489400
            I=FIXV(MP+2);                                                       01489500
            FIXV(MP) = 3;  /* DEFAULT IF BAD SPEC FOLLOWS */                    01489600
            IF I = -1 THEN CALL ERROR(CLASS_DD, 9);                             01489700
            ELSE IF (I ^> 1) | (I > MAT_DIM_LIM) THEN                           01489800
               CALL ERROR(CLASS_DD, 4);                                         01489900
            ELSE FIXV(MP) = I;                                                  01490000
         END;                                                                   01490100
                                                                                01490200
 /*  <LITERAL EXP OR *> ::= <ARITH EXP>  */                                     01490300
         DO;                                                                    01490400
            PTR_TOP = PTR(MP) - 1;                                              01490500
            CALL CHECK_ARRAYNESS;                                               01490600
            CALL CHECK_IMPLICIT_T;                                              01490700
            IF PSEUDO_FORM(PTR(SP)) ^= XLIT THEN                                01490800
               DO;                                                              01490900
               CALL ERROR(CLASS_VE,1);                                          01491000
               TEMP = 0;                                                        01491100
            END;                                                                01491200
            ELSE                                                                01491300
               DO;                                                              01491400
               TEMP = MAKE_FIXED_LIT(LOC_P(PTR(SP)));                           01491500
               IF TEMP = -1 THEN                                                01491600
                  TEMP = 0;                                                     01491700
            END;                                                                01491800
            FIXV(SP) = TEMP;                                                    01491900
         END;                                                                   01492000
                                                                                01492100
 /*  <LITERAL EXP OR *> ::= *  */                                               01492200
         FIXV(SP) = -1;                                                         01492300
                                                                                01492400
 /*  <PREC_SPEC> ::= SINGLE  */                                                 01492500
         DO;                                                                    01492600
            FIXL(MP) = SD_FLAGS;                                                01492700
            FIXV(MP) = SINGLE_FLAG;                                             01492800
            PTR(MP)=1;                                                          01492900
         END;                                                                   01493000
                                                                                01493100
 /*  <PREC SPEC> ::= DOUBLE  */                                                 01493200
         DO;                                                                    01493300
            FIXL(MP) = SD_FLAGS;                                                01493400
            FIXV(MP) = DOUBLE_FLAG;                                             01493500
            PTR(MP)=2;                                                          01493600
         END;                                                                   01493700
                                                                                01493800
 /*  <MINOR ATTR LIST> ::= <MINOR ATTRIBUTE>  */                                01493900
         GO TO INCORPORATE_ATTR;                                                01494000
                                                                                01494100
 /*  <MINOR ATTR LIST> ::= <MINOR ATTR LIST> <MINOR ATTRIBUTE>  */              01494200
         DO;                                                                    01494300
INCORPORATE_ATTR:                                                               01494400
            IF (ATTR_MASK & FIXL(SP)) ^= 0 THEN                                 01494500
               CALL ERROR(CLASS_DA,25);                                         01494600
            ELSE DO;                                                            01494700
               ATTR_MASK = ATTR_MASK | FIXL(SP);                                01494800
               ATTRIBUTES = ATTRIBUTES | FIXV(SP);                              01494900
            END;                                                                01495000
         END;                                                                   01495100
                                                                                01495200
 /*  <MINOR ATTRIBUTE> ::= STATIC  */                                           01495300
         DO;                                                                    01495400
            I = STATIC_FLAG;                                                    01495500
SET_AUTSTAT:                                                                    01495600
            IF BLOCK_MODE(NEST) = CMPL_MODE THEN                                01495700
               CALL ERROR(CLASS_DC, 2);                                         01495800
            ELSE DO;                                                            01495900
               FIXL(MP) = AUTSTAT_FLAGS;                                        01496000
               FIXV(MP) = I;                                                    01496100
            END;                                                                01496200
         END;                                                                   01496300
                                                                                01496400
 /*  <MINOR ATTRIBUTE> ::= AUTOMATIC  */                                        01496500
         DO;                                                                    01496600
            I = AUTO_FLAG;                                                      01496700
            GO TO SET_AUTSTAT;                                                  01496800
         END;                                                                   01496900
                                                                                01497000
 /*  <MINOR ATTRIBUTE> ::= DENSE  */                                            01497100
         DO;                                                                    01497200
            IF (TYPE=0) | (BUILDING_TEMPLATE & (TYPE=BIT_TYPE) & /*CR13236*/
               ((ATTRIBUTES&ARRAY_FLAG)=0) &                     /*CR13236*/
               (^NAME_IMPLIED)) THEN DO;                         /*CR13236*/
               FIXL(MP) = ALDENSE_FLAGS;                                        01497300
               FIXV(MP) = DENSE_FLAG;                                           01497400
            END;                                                 /*CR13236*/
         END;                                                                   01497500
                                                                                01497600
 /*  <MINOR ATTRIBUTE> ::= ALIGNED  */                                          01497700
         DO;                                                                    01497800
            FIXL(MP) = ALDENSE_FLAGS;                                           01497900
            FIXV(MP) = ALIGNED_FLAG;                                            01498000
         END;                                                                   01498100
                                                                                01498200
 /*  <MINOR ATTRIBUTE> ::= ACCESS  */                                           01498300
         DO;                                                                    01498400
            IF BLOCK_MODE(NEST) = CMPL_MODE THEN                                01498500
               DO;                                                              01498600
               FIXL(MP) = ACCESS_FLAG;                                          01498700
               FIXV(MP) = ACCESS_FLAG;                                          01498800
               ACCESS_FOUND = TRUE;                                             01498900
            END;                                                                01499000
            ELSE CALL ERROR(CLASS_DC,5);                                        01499100
         END;                                                                   01499200
                                                                                01499300
 /*  <MINOR ATTRIBUTE>  ::=  LOCK ( <LITERAL EXP OR *> )  */                    01499400
         DO;                                                                    01499500
            CONTEXT=DECLARE_CONTEXT;                                            01499600
            LOCK#=FIXV(MP+2);                                                   01499700
            IF LOCK#<0 THEN LOCK#="FF";                                         01499800
            ELSE IF LOCK#<1|LOCK#>LOCK_LIM THEN DO;                             01499900
               CALL ERROR(CLASS_DL,3);                                          01500000
               LOCK#="FF";                                                      01500100
            END;                                                                01500200
            FIXL(MP),FIXV(MP)=LOCK_FLAG;                                        01500300
         END;                                                                   01500400
 /*  <MINOR ATTRIBUTE>  ::=  REMOTE  */                                         01500500
         DO;                                                                    01500600
            FIXL(MP),FIXV(MP)=REMOTE_FLAG;                                      01500700
         END;                                                                   01500800
 /*  <MINOR ATTRIBUTE> ::= RIGID  */                                            01500900
         DO;                                                                    01501000
            FIXL(MP),FIXV(MP)=RIGID_FLAG;                                       01501100
         END;                                                                   01501200
                                                                                01501300
 /*  <MINOR ATTRIBUTE> ::= <INIT/CONST HEAD> <REPEATED CONSTANT> )  */          01501400
         DO;                                                                    01501500
            PSEUDO_TYPE(PTR(MP)) = 0;   /* NO "*" */                            01501600
DO_QUALIFIED_ATTRIBUTE:                                                         01501700
            BI_FUNC_FLAG=FALSE;                                                 01501800
            CALL CHECK_IMPLICIT_T;                                              01501900
            CONTEXT = DECLARE_CONTEXT;                                          01502000
/*DR111367*/IF (NUM_ELEMENTS >= NUM_EL_MAX) | (NUM_ELEMENTS < 1) THEN/*CR12416*/01502100
/*DR111367*/   CALL ERROR(CLASS_DI,2);                               /*CR12416*/
            LOC_P(PTR(MP)) = NUM_ELEMENTS;  /* SAVE NUMBER OF ELEMENTS TO SET */01502200
            VAL_P(PTR(MP)) = NUM_FL_NO;  /* SAVE NUMBER OF GVR'S USED */        01502300
            PSEUDO_LENGTH(PTR(MP)) = NUM_STACKS;  /* INDICATE LENGTH OF LIST */ 01502400
            IC_PTR = PTR(MP);  /* SAVE PTR TO THIS I/C LIST */                  01502500
            IC_FND = TRUE;                                                      01502600
            IF BUILDING_TEMPLATE THEN PTR_TOP=PTR(MP)-1;                        01502700
 /* KILL STACKS IF STRUCTURE TEMPLATE  */                                       01502800
         END;                                                                   01502900
                                                                                01503000
 /*  <MINOR ATTRIBUTE> ::= <INIT/CONST HEAD> * )  */                            01503100
         DO;                                                                    01503200
            PSEUDO_TYPE(PTR(MP)) = 1;  /* INDICATE "*" PRESENT */               01503300
            GO TO DO_QUALIFIED_ATTRIBUTE;                                       01503400
         END;                                                                   01503500
                                                                                01503600
 /*  <MINOR ATTRIBUTE> ::= LATCHED  */                                          01503700
         DO;                                                                    01503800
            FIXL(MP) = LATCHED_FLAG;                                            01503900
            FIXV(MP) = LATCHED_FLAG;                                            01504000
         END;                                                                   01504100
                                                                                01504200
 /*  <MINOR ATTRIBUTE>  ::=  NONHAL  (  <LEVEL>  )  */                          01504300
         DO;                                                                    01504400
            NONHAL=FIXV(MP+2);                                                  01504500
            /* DR108643 - DISCONNECT SYT_FLAGS FROM NONHAL; SET       */
            /*   NONHAL IN SYT_FLAGS2 ARRAY.                          */
            FIXL(MP)=NONHAL_FLAG;                                               01504600
            SYT_FLAGS2(ID_LOC) = SYT_FLAGS2(ID_LOC) | NONHAL_FLAG;
            /****** END DR108643 ******/
            ATTRIBUTES2 = ATTRIBUTES2 | NONHAL_FLAG;    /*DR109024*/
         END;                                                                   01504700
                                                                                01504800
 /*  <INIT/CONST HEAD> ::= INITIAL (    */                                      01504900
         DO;                                                                    01505000
            FIXL(MP) = INIT_CONST;                                              01505100
            FIXV(MP) = INIT_FLAG;                                               01505200
DO_INIT_CONST_HEAD :                                                            01505300
            BI_FUNC_FLAG=TRUE;                                                  01505400
            PTR(MP)=PUSH_INDIRECT(1);                                           01505500
            NUM_ELEMENTS,NUM_FL_NO=0;                                           01505600
            NUM_STACKS = 1;  /*  THIS IS FIRST INDIRECT LOC NEEDED  */          01505700
            PSEUDO_FORM(PTR(MP)) = 0;  /*  INDICATE I/C LIST TOP, IE., STRI  */ 01505800
            INX(PTR(MP)) = IC_LINE;                                             01505900
         END;                                                                   01506000
                                                                                01506100
 /*  <INIT/CONST HEAD> ::= CONSTANT (    */                                     01506200
         DO;                                                                    01506300
            FIXL(MP) = INIT_CONST;                                              01506400
            FIXV(MP) = CONSTANT_FLAG;                                           01506500
            GO TO DO_INIT_CONST_HEAD;                                           01506600
         END;                                                                   01506700
                                                                                01506800
 /*  <INIT/CONST HEAD>  ::=  <INIT/CONST HEAD>  <REPEATED CONSTANT>  ,  */      01506900
         ;                                                                      01507000
 /*  <REPEATED CONSTANT>  ::=  <EXPRESSION>  */                                 01507100
         DO;                                                                    01507200
            TEMP_SYN=0;                                                         01507300
            GO TO INIT_ELEMENT;                                                 01507400
         END;                                                                   01507500
 /*  <REPEATED CONSTANT>  ::=  <REPEAT HEAD>  <VARIABLE>  */                    01507600
         DO;                                                                    01507700
            TEMP_SYN=1;                                                         01507800
            GO TO INIT_ELEMENT;                                                 01507900
         END;                                                                   01508000
 /*  <REPEATED CONSTANT>  ::=  <REPEAT HEAD>  <CONSTANT>  */                    01508100
         DO;                                                                    01508200
            TEMP_SYN=1;                                                         01508300
INIT_ELEMENT:                                                                   01508400
            TEMP=PTR(SP);                                                       01508500
            IF NAME_PSEUDOS THEN DO;                                            01508600
               NAME_PSEUDOS=FALSE;                                              01508700
               PSEUDO_TYPE(TEMP)=PSEUDO_TYPE(TEMP)|"80";                        01508800
               IF (VAL_P(TEMP)&"40")^=0 THEN CALL ERROR(CLASS_DI,14);           01508900
               IF (VAL_P(TEMP)&"200")^=0 THEN CALL ERROR(CLASS_DI,16);          01509000
               /* LOOK FOR THE "4000" VAL_P BIT AND EMIT DI16 ERROR.  */
               /* THE VAL_P "4000" BIT INDICATES THE PRESENCE OF A    */
               /* NAME VARIABLE SOMEWHERE INSIDE THE STRUCTURE REFER- */
               /* ENCE LIST. THE PRESENCE OF A NAME VARIABLE INSIDE   */
               /* A NAME() INITIALIZATION IS A DI16 ERROR CONDITION.  */
               IF (VAL_P(TEMP)&"4000")^=0 THEN   /*DR109021*/
                  CALL ERROR(CLASS_DI,16);       /*DR109021 */
               IF EXT_P(TEMP)^=0 THEN CALL ERROR(CLASS_DI,15);                  01509100
               IF (VAL_P(TEMP) & "400") = 0 THEN CALL RESET_ARRAYNESS;          01509200
               IF SYT_CLASS(FIXL(MP)) = TEMPLATE_CLASS THEN DO;   /*DR109070*/
                  IF (((SYT_FLAGS(FIXV(MP)) & ASSIGN_PARM) > 0) | /*DR109070*/
                     (((SYT_FLAGS(FIXV(MP)) & AUTO_FLAG) ^= 0) &  /*DR109070*/
                     ((SYT_FLAGS(BLOCK_SYTREF(NEST)) &            /*DR109050*/
                       REENTRANT_FLAG)^=0)))                      /*DR109050*/
                  THEN                                            /*DR109050*/
                       CALL ERROR(CLASS_DI,3);                    /*DR109050*/
               END;                                               /*DR109070*/
               ELSE DO;                                           /*DR109070*/
                  IF (((SYT_FLAGS(FIXL(MP)) & ASSIGN_PARM) > 0) | /*DR109070*/
                     (((SYT_FLAGS(FIXL(MP)) & AUTO_FLAG) ^= 0) &  /*DR109070*/
                     ((SYT_FLAGS(BLOCK_SYTREF(NEST)) &            /*DR109070*/
                       REENTRANT_FLAG)^=0)))                      /*DR109070*/
                  THEN                                            /*DR109070*/
                       CALL ERROR(CLASS_DI,3);                    /*DR109070*/
               END;                                               /*DR109070*/
            END;                                                                01509300
            ELSE IF PSEUDO_FORM(TEMP)^=XLIT THEN CALL ERROR(CLASS_DI,3);        01509400
            CALL CHECK_ARRAYNESS;                                               01509500
            CALL SET_INIT(LOC_P(TEMP),2,PSEUDO_FORM(TEMP),PSEUDO_TYPE(TEMP),    01509600
               NUM_ELEMENTS);                                                   01509700
            NUM_ELEMENTS=NUM_ELEMENTS+1;                                        01509800
            NUM_STACKS=NUM_STACKS+1;                                            01509900
            IF TEMP_SYN THEN DO;                                                01510000
END_REPEAT_INIT:                                                                01510100
               CALL SET_INIT(0,3,0,0,NUM_FL_NO);                                01510200
               NUM_FL_NO=NUM_FL_NO-1;                                           01510300
               NUM_STACKS=NUM_STACKS+1;                                         01510400
               TEMP_SYN=NUM_ELEMENTS-FIXV(MP);                                  01510500
               IC_LEN(GET_ICQ(FIXL(MP)))=TEMP_SYN;                              01510600
               NUM_ELEMENTS=INX(PTR(MP))*TEMP_SYN+FIXV(MP);                     01510700
            END;                                                                01510800
            PTR_TOP=PTR(MP)-1;                                                  01510900
         END;                                                                   01511000
 /* <REPEATED CONSTANT>  ::=  <NESTED REPEAT HEAD>  <REPEATED CONSTANT>  )  */  01511100
         GO TO END_REPEAT_INIT;                                                 01511200
 /*  <REPEATED CONSTANT>  ::=  <REPEAT HEAD>  */                                01511300
         DO;                                                                    01511400
            IC_LINE=IC_LINE-1;                                                  01511500
            NUM_STACKS=NUM_STACKS-1;                                            01511600
            NUM_FL_NO=NUM_FL_NO-1;                                              01511700
            NUM_ELEMENTS=NUM_ELEMENTS+INX(PTR(MP));                             01511800
            PTR_TOP=PTR(MP)-1;                                                  01511900
         END;                                                                   01512000
 /*  <REPEAT HEAD>  ::=  <ARITH EXP>  #  */                                     01512100
         DO;                                                                    01512200
            CALL CHECK_ARRAYNESS;                                               01512300
            IF PSEUDO_FORM(PTR(MP))^=XLIT THEN TEMP_SYN=0;                      01512400
            ELSE TEMP_SYN=MAKE_FIXED_LIT(LOC_P(PTR(MP)));                       01512500
            IF TEMP_SYN<1 THEN DO;                                              01512600
               CALL ERROR(CLASS_DI,1);                                          01512700
               TEMP_SYN=0;                                                      01512800
            END;                                                                01512900
            IF TEMP_SYN>NUM_EL_MAX THEN TEMP_SYN=NUM_EL_MAX;                    01513000
            INX(PTR(MP))=TEMP_SYN;                                              01513100
            FIXV(MP)=NUM_ELEMENTS;                                              01513200
            NUM_FL_NO=NUM_FL_NO+1;                                              01513300
            CALL SET_INIT(TEMP_SYN,1,0,0,NUM_FL_NO);                            01513400
            FIXL(MP)=IC_LINE;                                                   01513500
            NUM_STACKS=NUM_STACKS+1;                                            01513600
         END;                                                                   01513700
 /*  <NESTED REPEAT HEAD>  ::=  <REPEAT HEAD>  (  */                            01513800
         ;                                                                      01513900
 /*  <NESTED REPEAT HEAD>  ::=  <NESTED REPEAT HEAD>  <REPEATED CONSTANT>  ,  */01514000
         ;                                                                      01514100
 /*  <CONSTANT>  ::=  <NUMBER>  */                                              01514200
         DO;                                                                    01514300
            TEMP_SYN=INT_TYPE;                                                  01514400
DO_CONSTANT:                                                                    01514500
            PTR(MP)=PUSH_INDIRECT(1);                                           01514600
            PSEUDO_TYPE(PTR(MP))=TEMP_SYN;                                      01514700
            PSEUDO_FORM(PTR(MP))=XLIT;                                          01514800
            LOC_P(PTR(MP))=FIXL(MP);                                            01514900
         END;                                                                   01515000
 /*  <CONSTANT>  ::=  <COMPOUND NUMBER>  */                                     01515100
         DO;                                                                    01515200
            TEMP_SYN=SCALAR_TYPE;                                               01515300
            GO TO DO_CONSTANT;                                                  01515400
         END;                                                                   01515500
 /*  <CONSTANT>  ::=  <BIT CONST>  */                                           01515600
         ;                                                                      01515700
 /*  <CONSTANT>  ::=  <CHAR CONST>  */                                          01515800
         ;                                                                      01515900
 /*  <NUMBER> ::= <SIMPLE NUMBER>    */                                         01516000
 /*  <NUMBER> ::= <LEVEL>    */                                                 01516100
         ; ;                                                                    01516200
                                                                                01516300
 /*  <CLOSING> ::= CLOSE    */                                                  01516400
            DO;                                                                 01516500
            VAR(MP) = '';                                                       01516600
CLOSE_IT:                                                                       01516700
            INDENT_LEVEL=INDENT_LEVEL-INDENT_INCR;                              01516800
            XSET"6";                                                            01516900
         END;                                                                   01517000
                                                                                01517100
 /*  <CLOSING> ::= CLOSE <LABEL>    */                                          01517200
         DO;                                                                    01517300
            VAR(MP) = VAR(SP);                                                  01517400
            GO TO CLOSE_IT;                                                     01517500
         END;                                                                   01517600
                                                                                01517700
 /*  <CLOSING> ::= <LABEL DEFINITION> <CLOSING>    */                           01517800
         DO;                                                                    01517900
            CALL SET_LABEL_TYPE(FIXL(MP), STMT_LABEL);                          01518000
            VAR(MP) = VAR(SP);                                                  01518100
         END;                                                                   01518200
 /* <TERMINATOR>::= TERMINATE */                                                01518300
         DO;                                                                    01518400
            FIXL(MP)=XTERM;                                                     01518500
            FIXV(MP)="E000";                                                    01518600
         END;                                                                   01518700
 /* <TERMINATOR>::= CANCEL */                                                   01518800
         DO;                                                                    01518900
            FIXL(MP)=XCANC;                                                     01519000
            FIXV(MP)="A000";                                                    01519100
         END;                                                                   01519200
 /*  <TERMINATE LIST>  ::=  <LABEL VAR>  */                                     01519300
         DO;                                                                    01519400
            EXT_P(PTR(MP))=1;                                                   01519500
            GO TO TERM_LIST;                                                    01519600
         END;                                                                   01519700
 /*  <TERMINATE LIST>  ::=  <TERMINATE LIST>  ,  <LABEL VAR>  */                01519800
         DO;                                                                    01519900
            EXT_P(PTR(MP))=EXT_P(PTR(MP))+1;                                    01520000
TERM_LIST:                                                                      01520100
            CALL SET_XREF_RORS(SP,FIXV(MP-1));                                  01520200
            CALL PROCESS_CHECK(SP);                                             01520300
         END;                                                                   01520400
 /* <WAIT KEY>::= WAIT */                                                       01520500
         REFER_LOC=1;                                                           01520600
 /*  <SCHEDULE HEAD>  ::=  SCHEDULE  <LABEL VAR>  */                            01520700
         DO;                                                                    01520800
            CALL PROCESS_CHECK(MPP1);                                           01520900
            IF (SYT_FLAGS(FIXL(MPP1)) & ACCESS_FLAG) ^= 0 THEN                  01521000
               CALL ERROR(CLASS_PS, 5, VAR(MPP1));                              01521100
            CALL SET_XREF_RORS(MPP1,"6000");                                    01521200
            REFER_LOC,PTR(MP)=PTR(MPP1);                                        01521300
            INX(REFER_LOC)=0;                                                   01521400
         END;                                                                   01521500
 /* <SCHEDULE HEAD>::= <SCHEDULE HEAD> AT <ARITH EXP> */                        01521600
         DO;                                                                    01521700
            TEMP="1";                                                           01521800
            IF UNARRAYED_SCALAR(SP) THEN CALL ERROR(CLASS_RT,1,'AT');           01521900
SCHEDULE_AT:                                                                    01522000
            IF INX(REFER_LOC)=0 THEN INX(REFER_LOC)=TEMP;                       01522100
            ELSE DO;                                                            01522200
               CALL ERROR(CLASS_RT,5);                                          01522300
               PTR_TOP=PTR_TOP-1;                                               01522400
            END;                                                                01522500
         END;                                                                   01522600
 /* <SCHEDULE HEAD>::= <SCHEDULE HEAD> IN <ARITH EXP> */                        01522700
         DO;                                                                    01522800
            TEMP="2";                                                           01522900
            IF UNARRAYED_SCALAR(SP) THEN CALL ERROR(CLASS_RT,1,'IN');           01523000
            GO TO SCHEDULE_AT;                                                  01523100
         END;                                                                   01523200
 /* <SCHEDULE HEAD>::=<SCHEDULE HEAD> ON <BIT EXP> */                           01523300
         DO;                                                                    01523400
            TEMP="3";                                                           01523500
            IF CHECK_EVENT_EXP(SP) THEN CALL ERROR(CLASS_RT,3,'ON');            01523600
            GO TO SCHEDULE_AT;                                                  01523700
         END;                                                                   01523800
 /* <SCHEDULE PHRASE>::=<SCHEDULE HEAD> */                                      01523900
SCHED_PRIO:CALL ERROR(CLASS_RT,4,'SCHEDULE');                                   01524000
 /* <SCHEDULE PHRASE>::=<SCHEDULE HEAD> PRIORITY (<ARITH EXP>) */               01524100
         DO;                                                                    01524200
            IF UNARRAYED_INTEGER(SP-1) THEN GO TO SCHED_PRIO;                   01524300
            INX(REFER_LOC)=INX(REFER_LOC)|"4";                                  01524400
         END;                                                                   01524500
 /*  <SCHEDULE PHRASE>  ::=  <SCHEDULE PHRASE>  DEPENDENT  */                   01524600
         INX(REFER_LOC)=INX(REFER_LOC)|"8";                                     01524700
 /* <SCHEDULE CONTROL>::= <STOPPING> */                                         01524800
         ;                                                                      01524900
 /* <SCHEDULE CONTROL>::= <TIMING> */                                           01525000
         ;                                                                      01525100
 /* <SCHEDULE CONTROL>::= <TIMING><STOPPING> */                                 01525200
         ;                                                                      01525300
 /*  <TIMING>  ::=  <REPEAT> EVERY <ARITH EXP>  */                              01525400
         DO;                                                                    01525500
            TEMP="20";                                                          01525600
SCHEDULE_EVERY:                                                                 01525700
            IF UNARRAYED_SCALAR(SP) THEN CALL ERROR(CLASS_RT,1,'EVERY/AFTER');  01525800
            INX(REFER_LOC)=INX(REFER_LOC)|TEMP;                                 01525900
         END;                                                                   01526000
 /*  <TIMING>  ::=  <REPEAT> AFTER <ARITH EXP>  */                              01526100
         DO;                                                                    01526200
            TEMP="30";                                                          01526300
            GO TO SCHEDULE_EVERY;                                               01526400
         END;                                                                   01526500
 /*  <TIMING>  ::=  <REPEAT>  */                                                01526600
         INX(REFER_LOC)=INX(REFER_LOC)|"10";                                    01526700
 /*  <REPEAT>  ::=  , REPEAT  */                                                01526800
         CONTEXT=0;                                                             01526900
 /* <STOPPING>::=<WHILE KEY><ARITH EXP> */                                      01527000
         DO;                                                                    01527100
            IF FIXL(MP)=0 THEN CALL ERROR(CLASS_RT,2);                          01527200
            ELSE IF UNARRAYED_SCALAR(SP) THEN CALL ERROR(CLASS_RT,1,'UNTIL');   01527300
            INX(REFER_LOC)=INX(REFER_LOC)|"40";                                 01527400
         END;                                                                   01527500
 /* <STOPPING>::=<WHILE KEY><BIT EXP> */                                        01527600
         DO;                                                                    01527700
            IF CHECK_EVENT_EXP(SP) THEN CALL ERROR(CLASS_RT,3,'WHILE/UNTIL');   01527800
            TEMP=SHL(FIXL(MP)+2,6);                                             01527900
            INX(REFER_LOC)=INX(REFER_LOC)|TEMP;                                 01528000
         END;                                                                   01528100
                                                                                01528200
         ;  ;  ;  ;  ;          /*  INSURANCE  */                               01528300
                                                                                01528400
         END;     /*  OF PART_2  */                                             01528500
      IF (PREV_STMT_NUM ^= STMT_NUM) THEN     /*DR108603*/
         INCREMENT_DOWN_STMT = FALSE;         /*DR108603*/
      PREV_STMT_NUM = STMT_NUM;               /*DR108603*/
                                                                                01528600
   END SYNTHESIZE     /*  $S  */     ;     /*  $S  */                           01528700
