#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   RECOVER.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-12 RSB  Began porting from XPL
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
import HALINCL.CERRDECL as d

'''
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
 /*       d.CLASS_AA                             PCCOPY_INDEX                 */
 /*       d.CLASS_AV                             PERIOD                       */
 /*       d.CLASS_B                              PRIMARY                      */
 /*       d.CLASS_BN                             PROC_LABEL                   */
 /*       d.CLASS_BT                             PROC_MODE                    */
 /*       d.CLASS_C                              PROG_LABEL                   */
 /*       d.CLASS_D                              PROG_MODE                    */
 /*       d.CLASS_DA                             READ_ACCESS_FLAG             */
 /*       d.CLASS_DC                             REENTRANT_FLAG               */
 /*       d.CLASS_DD                             REMOTE                       */
 /*       d.CLASS_DI                             REMOTE_FLAG                  */
 /*       d.CLASS_DL                             REPL_ARG_CLASS               */
 /*       d.CLASS_DN                             REPLACE_TEXT_PTR             */
 /*       d.CLASS_DQ                             RIGID_FLAG                   */
 /*       d.CLASS_DS                             SBIT_NDX                     */
 /*       d.CLASS_DT                             SCALAR_TYPE                  */
 /*       d.CLASS_DU                             SCLR_NDX                     */
 /*       d.CLASS_E                              SD_FLAGS                     */
 /*       d.CLASS_EA                             SINGLE_FLAG                  */
 /*       d.CLASS_EB                             SP                           */
 /*       d.CLASS_EC                             STAB_STACKTOP                */
 /*       d.CLASS_ED                             START_POINT                  */
 /*       d.CLASS_EL                             STATIC_FLAG                  */
 /*       d.CLASS_EM                             STMT_END_PTR                 */
 /*       d.CLASS_EN                             STMT_LABEL                   */
 /*       d.CLASS_EO                             STMT_NUM                     */
 /*       d.CLASS_EV                             STRUCTURE_SUB_COUNT          */
 /*       d.CLASS_FD                             SUB_COUNT                    */
 /*       d.CLASS_FS                             SYM_ADDR                     */
 /*       d.CLASS_FT                             SYM_ARRAY                    */
 /*       d.CLASS_GB                             SYM_CLASS                    */
 /*       d.CLASS_GC                             SYM_FLAGS                    */
 /*       d.CLASS_GE                             SYM_LENGTH                   */
 /*       d.CLASS_GL                             SYM_LINK1                    */
 /*       d.CLASS_GV                             SYM_LINK2                    */
 /*       d.CLASS_IR                             SYM_LOCK#                    */
 /*       d.CLASS_IS                             SYM_NAME                     */
 /*       d.CLASS_LB                             SYM_NEST                     */
 /*       d.CLASS_LS                             SYM_PTR                      */
 /*       d.CLASS_P                              SYM_SCOPE                    */
 /*       d.CLASS_PC                             SYM_TYPE                     */
 /*       d.CLASS_PE                             SYT_ADDR                     */
 /*       d.CLASS_PF                             SYT_ARRAY                    */
 /*       d.CLASS_PL                             SYT_CLASS                    */
 /*       d.CLASS_PP                             SYT_FLAGS                    */
 /*       d.CLASS_PS                             SYT_HASHSIZE                 */
 /*       d.CLASS_PT                             SYT_LINK1                    */
 /*       d.CLASS_QS                             SYT_LINK2                    */
 /*       d.CLASS_QX                             SYT_LOCK#                    */
 /*       d.CLASS_RT                             SYT_MAX                      */
 /*       d.CLASS_RU                             SYT_NAME                     */
 /*       d.CLASS_SP                             SYT_NEST                     */
 /*       d.CLASS_SV                             SYT_PTR                      */
 /*       d.CLASS_T                              SYT_SCOPE                    */
 /*       d.CLASS_TC                             SYT_TYPE                     */
 /*       d.CLASS_TD                             TASK_LABEL                   */
 /*       d.CLASS_UI                             TASK_MODE                    */
 /*       d.CLASS_UP                             TEMP_TYPE                    */
 /*       d.CLASS_UT                             TEMPL_NAME                   */
 /*       d.CLASS_VA                             TEMPLATE_CLASS               */
 /*       d.CLASS_VC                             TEMPORARY_FLAG               */
 /*       d.CLASS_VE                             TEMPORARY_IMPLIED            */
 /*       d.CLASS_XM                             TOKEN                        */
 /*       d.CLASS_XR                             TPL_FLAG                     */
 /*       d.CLASS_XS                             TRUE                         */
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
'''

#                  THE SYNTHESIS ALGORITHM FOR HAL

class cSYNTHESIZE:
    def __init__(self):
        self.INLINE_NAME ='$FUNCTION'
        self.UPDATE_NAME = '$UPDATE'
        self.H1 = 0
        self.H2 = 0
        self.PREV_LIVES_REMOTE = 0
        self.PREV_POINTS = 0
        self.PREV_REMOTE = 0
        self.NAME_SET = 0
        self.REMOTE_SET = 0
        self.CURRENT_LIVES_REMOTE = 0
        self.CHANGED_STMT_NUM = 0
        self.ELSE_TOKEN = 0
lSYNTHESIZE = cSYNTHESIZE()

def SYNTHESIZE(PRODUCTION_NUMBER):
    l = lSYNTHESIZE # Local variables.
    
    def SET_INIT(A,B,C,D,E):
        # Local Q doesn't need to be persistent
        IC_LINE=IC_LINE+1;
        if IC_LINE>NUM_EL_MAX:
            ERROR(d.CLASS_BT,7);
        Q=GET_ICQ(IC_LINE);
        IC_VAL(Q)=E;
        IC_LOC(Q)=A;
        IC_LEN(Q)=C;
        IC_FORM(Q)=B;
        IC_TYPE(Q)=D;
    
    '''
    THIS PROCEDURE IS RESPONSIBLE FOR THE SEMANTICS (CODE SYNTHESIS), IF
    ANY, OF THE SKELETON COMPILER.  ITS ARGUMENT IS THE NUMBER OF THE
    PRODUCTION WHICH WILL BE APPLIED IN THE PENDING REDUCTION.  THE GLOBAL
    VARIABLES MP AND SP POINT TO THE BOUNDS IN THE STACKS OF THE RIGHT PART
    OF THIS PRODUCTION.
    '''
    
    if CONTROL(8):
       OUTPUT = '->->->->->->PRODUCTION NUMBER ' + PRODUCTION_NUMBER
    if SHR(pPRODUCE_NAME(PRODUCTION_NUMBER),12):
       ERROR(d.CLASS_XS,2,'#'+PRODUCTION_NUMBER);
    
    # THIS CODE CHECKS TO SEE IF THE PREVIOUS STATEMENT WAS AN
    # IF-THEN OR ELSE AND IF THE CURRENT STATEMENT IS NOT A SIMPLE DO.
    # IF TRUE, THE PREVIOUS STATEMENT IS PRINTED AND EXEUCTION CONTINUES.
    if (IF_FLAG | ELSE_FLAG) & (PRODUCTION_NUMBER!=144): DO;
       SQUEEZING = FALSE;
       l.CHANGED_STMT_NUM = FALSE;
       if IF_FLAG: DO;
          STMT_NUM = STMT_NUM - 1;
          l.CHANGED_STMT_NUM = TRUE;
       END;
       SAVE_SRN2 = SRN(2);
       SRN(2) = SAVE_SRN1;
       SAVE_SRN_COUNT2 = SRN_COUNT(2);
       SRN_COUNT(2) = SAVE_SRN_COUNT1;
       IF_FLAG,ELSE_FLAG = FALSE;#MUST BE BEFORE OUTPUTWR CALL
       OUTPUT_WRITER(SAVE1,SAVE2);
       INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
       if l.CHANGED_STMT_NUM: STMT_NUM = STMT_NUM + 1;
       if STMT_PTR > -1: LAST_WRITE = SAVE2 + 1;
       SRN(2) = SAVE_SRN2;
       SRN_COUNT(2) = SAVE_SRN_COUNT2;
    END;
    
    # THIS CODE IS USED TO ALIGN THE ELSE STATEMENTS CORRECTLY.
    # IF THE CURRENT STATEMENT IS NOT AN ELSE OR A DO, MOVE_ELSE=TRUE.
    if (PRODUCTION_NUMBER != 140) & (PRODUCTION_NUMBER != 54) &
       (PRODUCTION_NUMBER != 40):
       MOVE_ELSE = TRUE;
    if (SAVE_DO_LEVEL != -1) & (PRODUCTION_NUMBER != 167): DO;
       IFDO_FLAG(SAVE_DO_LEVEL) = FALSE;
       SAVE_DO_LEVEL = -1;
    END;
    
    DO CASE PRODUCTION_NUMBER;
    
       ;
    
    # <COMPILATION>::= <COMPILE LIST> _|_
       DO;
          if MP>0: DO;
             ERROR(d.CLASS_P,1);
             STACK_DUMP();
          END;
          ELSE if BLOCK_MODE=0: ERROR(d.CLASS_PP,4);
          HALMAT_POP(XXREC,0,0,1);
          ATOM#_FAULT=-1;
          HALMAT_OUT();
          FILE(LITFILE,CURLBLK)=LIT1(0);
          COMPILING="80";
          STMT_PTR=STMT_PTR-1;
       END;
    # <COMPILE LIST>::=<BLOCK DEFINITION>
       ;
    # <COMPILE LIST>::= <COMPILE LIST> <BLOCK DEFINITION>
       ;
    
    #  <ARITH EXP> ::= <TERM>
       ;
    #  <ARITH EXP> ::= + <TERM>
       DO ;  # JUST ABSORB '+' SIGN, IE, RESET INDIRECT STACK
          PTR(MP) = PTR(SP) ;
          NOSPACE;
       END ;
    #  <ARITH EXP> ::= -1 <TERM>
       DO ;
          if ARITH_LITERAL(SP,0): DO;
        INLINE("58",1,0,DW_AD);                   # L   1,DW_AD
        INLINE("97",8,0,1,0);                     # XI  0(1),X'80'
             LOC_P(PTR(SP))=SAVE_LITERAL(1,DW_AD);
          END;
          ELSE DO;
             TEMP=PSEUDO_TYPE(PTR(SP));
             HALMAT_TUPLE(XMNEG(TEMP-MAT_TYPE),0,SP,0,0);
             SETUP_VAC(SP,TEMP,PSEUDO_LENGTH(PTR(SP)));
          END;
          NOSPACE;
          PTR(MP)=PTR(SP);
       END ;
    #  <ARITH EXP> ::= <ARITH EXP> + <TERM>
       ADD_AND_SUBTRACT(0);
    #  <ARITH EXP> ::= <ARITH EXP> -1 <TERM>
       ADD_AND_SUBTRACT(1);
    
    #  <TERM> ::= <PRODUCT>
       ;
    #  <TERM> ::= <PRODUCT> / <TERM>
       DO ;
          if ARITH_LITERAL(MP,SP): DO;
             if MONITOR(9,4): DO;
                ERROR(d.CLASS_VA,4);
                GO TO DIV_FAIL;
             END;
             LOC_P(PTR(MP))=SAVE_LITERAL(1,DW_AD);
             PSEUDO_TYPE(PTR(MP))=SCALAR_TYPE;
          END;
          ELSE DO;
    DIV_FAIL:
             if PSEUDO_TYPE(PTR(SP))<SCALAR_TYPE: ERROR(d.CLASS_E,1);
             PTR=0;
             PSEUDO_TYPE=SCALAR_TYPE;
             MATCH_SIMPLES(0,SP);
           if PSEUDO_TYPE(PTR(MP))^<SCALAR_TYPE: MATCH_SIMPLES(0,MP);
             TEMP=PSEUDO_TYPE(PTR(MP));
             HALMAT_TUPLE(XMSDV(TEMP-MAT_TYPE),0,MP,SP,0);
             SETUP_VAC(MP,TEMP);
          END;
          PTR_TOP=PTR(MP);
       END ;
    #  <PRODUCT> ::= <FACTOR>
       DO;
          CROSS_COUNT,DOT_COUNT,SCALAR_COUNT,VECTOR_COUNT,MATRIX_COUNT = 0;
          TERMP = SP + 1;
          DO WHILE TERMP > 0;
             TERMP = TERMP - 1;
             if PARSE_STACK(TERMP) = CROSS_TOKEN:
                DO;
                CROSS_COUNT = CROSS_COUNT + 1;
                FIXV(TERMP) = CROSS;
             END;  ELSE
                if PARSE_STACK(TERMP) = DOT_TOKEN:
                DO;
                DOT_COUNT = DOT_COUNT + 1;
                FIXV(TERMP) = DOT;
             END;  ELSE
                if PARSE_STACK(TERMP) = FACTOR:
                DO CASE "0F" & PSEUDO_TYPE(PTR(TERMP));
                ;;;  # 0 IS DUMMY, 1 IS BIT, 2 IS CHAR
                   DO;
                   MATRIX_COUNT = MATRIX_COUNT + 1;
                   FIXV(TERMP) = MAT_TYPE;
                END;
                DO;
                   VECTOR_COUNT = VECTOR_COUNT + 1;
                   FIXV(TERMP) = VEC_TYPE;
                END;
                DO;
    ALSO_SCALAR:
                   SCALAR_COUNT = SCALAR_COUNT + 1;
                   FIXV(TERMP) = SCALAR_TYPE;
                END;
                GO TO ALSO_SCALAR;  # TYPE 6 IS INTEGER
             END;   ELSE
                DO;
                MP    = TERMP + 1;  # IT WAS DECREMENTED AT START OF LOOP
                TERMP = 0;  # GET OUT OF LOOP
             END;
          END;
          TERMP = MP;
    
          if TERMP = SP: return;
    
    #  MULTIPLY ALL SCALARS, PLACE RESULT AT SCALARP
          SCALARP = 0;
          PP = TERMP - 1;
          DO WHILE SCALAR_COUNT > 0;
             PP = PP + 1;
             if FIXV(PP) = SCALAR_TYPE:
                DO;
                SCALAR_COUNT = SCALAR_COUNT - 1;
                if SCALARP = 0: SCALARP = PP;
                ELSE MULTIPLY_SYNTHESIZE(SCALARP,PP,SCALARP,0);
             END;
          END;
    
    
    
    # PRODUCTS WITHOUT VECTORS HANDLED HERE
          if VECTOR_COUNT = 0:
             DO;
             if CROSS_COUNT + DOT_COUNT > 0:
                DO;
                ERROR(d.CLASS_E,4);
                PTR_TOP = PTR(MP);
                return;
             END;
             if MATRIX_COUNT = 0:
                DO;
                PTR_TOP = PTR(MP);
                return;
             END;
    #  MULTIPLY MATRIX PRODUCTS
             MATRIXP = 0;
             PP = TERMP - 1;
             DO WHILE MATRIX_COUNT > 0;
                PP = PP + 1;
                if FIXV(PP) = MAT_TYPE:
                   DO;
                   MATRIX_COUNT = MATRIX_COUNT - 1;
                   if MATRIXP = 0: MATRIXP = PP;
                   ELSE MULTIPLY_SYNTHESIZE(MATRIXP,PP,MATRIXP,8);
                END;
             END;
       if SCALARP != 0: MULTIPLY_SYNTHESIZE(MATRIXP,SCALARP,TERMP,2);
             PTR_TOP = PTR(MP);
             return;
          END;
    
    
    
    # PRODUCTS WITH VECTORS TAKE UP THE REST OF THIS REDUCTION
    
    #  FIRST MATRICES ARE PULLED INTO VECTORS
          if MATRIX_COUNT = 0: GO TO MATRICES_TAKEN_CARE_OF;
          BEGINP = TERMP;
    MATRICES_MAY_GO_RIGHT:
          MATRIX_PASSED = 0;
          DO PP = BEGINP TO SP;
           if FIXV(PP) = MAT_TYPE: MATRIX_PASSED = MATRIX_PASSED + 1; ELSE
             if FIXV(PP) = DOT | FIXV(PP) = CROSS: MATRIX_PASSED = 0; ELSE
    #  THIS ILLEGAL SYNTAX WILL BE CAUGHT ELSEWHERE
                if FIXV(PP) = VEC_TYPE:
                DO;
                PPTEMP = PP;
                DO WHILE MATRIX_PASSED > 0;
                   PPTEMP = PPTEMP - 1;
                   if FIXV(PPTEMP) = MAT_TYPE:
                      DO;
                      MATRIX_PASSED = MATRIX_PASSED - 1;
                      MULTIPLY_SYNTHESIZE(PPTEMP,PP,PP,7);
                   END;
                END;
                DO PPTEMP = PP + 1 TO SP;
                   if FIXV(PPTEMP) = MAT_TYPE:
                      MULTIPLY_SYNTHESIZE(PP,PPTEMP,PP,6); ELSE
                      if FIXV(PPTEMP) = VEC_TYPE: PP = PPTEMP;  ELSE
                      if FIXV(PPTEMP) = DOT | FIXV(PPTEMP) = CROSS:
                      DO;
                      BEGINP = PPTEMP + 1;
                      GO TO MATRICES_MAY_GO_RIGHT;
                   END;
                END;
             END;
          END;
    
    MATRICES_TAKEN_CARE_OF:
    # PRODUCTS WITHOUT DOT OR CROSS COME NEXT
          if (DOT_COUNT + CROSS_COUNT) > 0: GO TO CROSS_PRODUCTS;
          if VECTOR_COUNT > 2:
             DO;
             ERROR(d.CLASS_EO,1);
             PTR_TOP = PTR(MP);
             return;
          END;
          DO PP = MP TO SP;
             if FIXV(PP) = VEC_TYPE:
                DO;
                VECTORP = PP;
                PP= SP + 1;
             END;
          END;
    COMBINE_SCALARS_AND_VECTORS:
          if SCALARP != 0:
             MULTIPLY_SYNTHESIZE(VECTORP,SCALARP,TERMP,1);  ELSE
             if VECTORP != MP:
             DO;
    #   THIS BLOCK OF CODE PUTS THE INDIRECT STACK INFORMATION FOR THE
    #   ENTIRE PRODUCT IN THE FIRST OF THE INDIRECT STACK ENTRIES ALOTTED
    #   TO THE ENTIRE PRODUCT, IN CASE THE FINAL MULTIPLY DOESN'T DO SO
             PTR_TOP = PTR(MP);
             INX(PTR_TOP) = INX(PTR(VECTORP));
             LOC_P(PTR_TOP) = LOC_P(PTR(VECTORP));
             VAL_P(PTR_TOP) = VAL_P(PTR(VECTORP));
             PSEUDO_TYPE(PTR_TOP) = PSEUDO_TYPE(PTR(VECTORP));
             PSEUDO_FORM(PTR_TOP) = PSEUDO_FORM(PTR(VECTORP));
             PSEUDO_LENGTH(PTR_TOP) = PSEUDO_LENGTH(PTR(VECTORP));
          END;
          if VECTOR_COUNT = 1:
             DO;
             PTR_TOP = PTR(MP);
             return;
          END;
    #  VECTOR_COUNT SHOULD BE 2 HERE
          DO PP = VECTORP + 1 TO SP;
             if FIXV(PP) = VEC_TYPE:
                DO;
                MULTIPLY_SYNTHESIZE(TERMP,PP,TERMP,5);
                PTR_TOP = PTR(MP);
                return;
             END;
          END;
    
    CROSS_PRODUCTS:
          DO WHILE CROSS_COUNT > 0;
             VECTORP = 0;
             DO PP = MP TO SP;
                if FIXV(PP) = VEC_TYPE: VECTORP = PP; ELSE
                   if FIXV(PP) = DOT: VECTORP = 0; ELSE
                   if FIXV(PP) = CROSS:
                   DO;
                   if VECTORP = 0:
                      DO;
                      ERROR(d.CLASS_EC,3);
                      PTR_TOP = PTR(MP);
                      return;
                   END; ELSE
                      DO PPTEMP = PP + 1 TO SP;
                      if FIXV(PPTEMP) = VEC_TYPE:
                         DO;
                         MULTIPLY_SYNTHESIZE(VECTORP,PPTEMP,VECTORP,4);
                         FIXV(PP) = 0;
                         CROSS_COUNT = CROSS_COUNT - 1;
                         FIXV(PPTEMP) = 0;
                         VECTOR_COUNT = VECTOR_COUNT - 1;
                         GO TO CROSS_PRODUCTS;
                      END;
                   END;
                   ERROR(d.CLASS_EC,2);
                   PTR_TOP = PTR(MP);
                   return;
                END;
             END;
          END;
    
    
          if DOT_COUNT > 0: GO TO DOT_PRODUCTS;
          if VECTOR_COUNT > 1:
             DO;
             ERROR(d.CLASS_EO,2);
             PTR_TOP = PTR(MP);
             return;
          END;
    # IF YOU GET TO THIS GOTO, VECTOR_COUNT HAD BETTER BE 1
          GO TO COMBINE_SCALARS_AND_VECTORS;
    
    
    DOT_PRODUCTS:
          BEGINP = TERMP;
    DOT_PRODUCTS_LOOP:
          DO WHILE DOT_COUNT > 0;
             VECTORP = 0;
             DO PP = BEGINP TO SP;
                if FIXV(PP) = VEC_TYPE: VECTORP = PP;
                if FIXV(PP) = DOT:
                   DO;
                   if VECTORP = 0:
                      DO;
                      ERROR(d.CLASS_ED,2);
                      PTR_TOP = PTR(MP);
                      return;
                   END;  ELSE
                      DO PPTEMP = PP + 1 TO SP;
                      if FIXV(PPTEMP) = VEC_TYPE:
                         DO;
                         MULTIPLY_SYNTHESIZE(VECTORP,PPTEMP,VECTORP,3);
                         if SCALARP = 0: SCALARP = VECTORP; ELSE
                          MULTIPLY_SYNTHESIZE(SCALARP,VECTORP,SCALARP,0);
                         BEGINP = PPTEMP + 1;
                         DOT_COUNT = DOT_COUNT - 1;
                         FIXV(VECTORP) = 0;
                         FIXV(PPTEMP) = 0;
                         VECTOR_COUNT = VECTOR_COUNT - 2;
                         GO TO DOT_PRODUCTS_LOOP;
                      END;
                   END;
                   ERROR(d.CLASS_ED,1);
                   PTR_TOP = PTR(MP);
                   return;
                END;
             END;
          END;
          if VECTOR_COUNT>0:
             DO;
             ERROR(d.CLASS_EO,3);
             PTR_TOP = PTR(MP);
             return;
          END;
    # VECTOR_COUNT MUST BE 0 HERE
          if SCALARP = MP:
             DO;
             PTR_TOP = PTR(MP);
             return;
          END;
    #   KLUDGE TO USE CODE IN ANOTHER SECTION OF THIS CASE
          VECTORP = SCALARP;
          VECTOR_COUNT = 1;
          SCALARP = 0;
          GO TO COMBINE_SCALARS_AND_VECTORS;
    
       END;
    #  <PRODUCT> ::= <FACTOR> * <PRODUCT>
    #  <PRODUCT> ::= <FACTOR> . <PRODUCT>
    #  <PRODUCT> ::= <FACTOR> <PRODUCT>
       ; ; ;
    
    # <FACTOR> ::= <PRIMARY>
          if PARSE_STACK(MP-1)!=EXPONENT: if FIXF(MP)>0:
          SET_XREF_RORS(MP);
    #  <FACTOR>  ::=  <PRIMARY>  <**>  <FACTOR>
       DO;
          I=PTR(SP);
          if FIXF(MP)>0: SET_XREF_RORS(MP);
          EXPONENT_LEVEL=EXPONENT_LEVEL-1;
          TEMP=PSEUDO_TYPE(PTR(MP));
          DO CASE TEMP-MAT_TYPE;
    #  MATRIX
             DO;
                TEMP2=PSEUDO_LENGTH(PTR(MP));
                if (PSEUDO_FORM(I)=XSYT)|(PSEUDO_FORM(I)=XXPT): DO;
                   if VAR(SP)='T': DO;
                      HALMAT_TUPLE(XMTRA,0,MP,0,0);
                      SETUP_VAC(MP,TEMP,SHL(TEMP2,8)|SHR(TEMP2,8));
                      if IMPLICIT_T: DO;
                         SYT_FLAGS(LOC_P(I))=SYT_FLAGS(LOC_P(I))|IMPL_T_FLAG;
                         IMPLICIT_T=FALSE;
                      END;
                      GO TO T_FOUND;
                   END;
                END;
                if PSEUDO_TYPE(I)!=INT_TYPE|PSEUDO_FORM(I)!=XLIT:
                   ERROR(d.CLASS_E,2);
                if (TEMP2&"FF")!=SHR(TEMP2,8): ERROR(d.CLASS_EM,4);
                HALMAT_TUPLE(XMINV,0,MP,SP,0);
                SETUP_VAC(MP,TEMP);
             END;
    #  VECTOR
             DO;
                ERROR(d.CLASS_EV,4);
                TEMP2=XSEXP;
                GO TO FINISH_EXP;
             END;
    #  SCALAR
    SIMPLE_EXP:
             if ARITH_LITERAL(MP,SP,TRUE): DO;
                if MONITOR(9,5): DO;
                   ERROR(d.CLASS_VA,5);
                   GO TO POWER_FAIL;
                END;
                LOC_P(PTR(MP))=SAVE_LITERAL(1,DW_AD);
                TEMP=LIT_RESULT_TYPE(MP,SP);
                if TEMP=INT_TYPE: if MAKE_FIXED_LIT(LOC_P(I))<0:
                   TEMP=SCALAR_TYPE;
                PSEUDO_TYPE(PTR(MP))=TEMP;
             END;
             ELSE DO;
    POWER_FAIL:
                TEMP2=XSPEX(TEMP-SCALAR_TYPE);
                if PSEUDO_TYPE(I)<SCALAR_TYPE: ERROR(d.CLASS_E,3);
                if PSEUDO_TYPE(I)!=INT_TYPE: DO;
                   TEMP2=XSEXP;
    REGULAR_EXP:
                   PTR=0;
                   PSEUDO_TYPE=SCALAR_TYPE;
                   MATCH_SIMPLES(MP,0);
                END;
                ELSE if PSEUDO_FORM(I)!=XLIT: DO;
                   TEMP2=XSIEX;
                   GO TO REGULAR_EXP;
                END;
                ELSE DO;
                   TEMP=MAKE_FIXED_LIT(LOC_P(I));
                   if TEMP<0: DO;
                      TEMP2=XSIEX;
                      GO TO REGULAR_EXP;
                   END;
                END;
    FINISH_EXP:
                HALMAT_TUPLE(TEMP2,0,MP,SP,0);
                SETUP_VAC(MP,PSEUDO_TYPE(PTR(MP)));
             END;
    #  INTEGER
             GO TO SIMPLE_EXP;
          END;
          if FIXF(SP)>0: SET_XREF_RORS(SP);
    T_FOUND:
          PTR_TOP=PTR(MP);
       END;
    #  <**>  ::=  **
       EXPONENT_LEVEL=EXPONENT_LEVEL+1;
    #  <PRE PRIMARY>  ::=  (  <ARITH EXP>  )
       DO;
          VAR(MP)=VAR(MPP1);
          PTR(MP)=PTR(MPP1);
       END;
    #  <PRE PRIMARY> ::= <NUMBER>
       DO ;
          TEMP=INT_TYPE;
    ARITH_LITS:
          PTR(MP)=PUSH_INDIRECT(1);
          LOC_P(PTR(MP))=FIXL(MP);
          PSEUDO_FORM(PTR(MP)) = XLIT ;
          PSEUDO_TYPE(PTR(MP))=TEMP;
       END ;
    #  <PRE PRIMARY> ::= <COMPOUND NUMBER>
       DO ;
          TEMP=SCALAR_TYPE;
          GO TO ARITH_LITS;
       END ;
    
    #  <ARITH FUNC HEAD>  ::=  <ARITH FUNC>
       START_NORMAL_FCN;
    #  <ARITH FUNC HEAD>  ::=  <ARITH CONV> <SUBSCRIPT>
       DO;
          NOSPACE;
          TEMP,NEXT_SUB=PTR(SP);
          PTR_TOP,PTR(MP)=TEMP;
          if INX(TEMP)=0: GO TO DEFAULT_SHAPER;
     if (PSEUDO_LENGTH(TEMP)>=0)|(VAL_P(TEMP)>=0): ERROR(d.CLASS_QS,1);
          DO CASE FIXL(MP);
    #  MATRIX
             if INX(TEMP)!=2: DO;
                ERROR(d.CLASS_QS,2);
                GO TO DEFAULT_SHAPER;
             END;
             ELSE DO;
                TEMP_SYN=ARITH_SHAPER_SUB(MAT_DIM_LIM);
                TEMP1=ARITH_SHAPER_SUB(MAT_DIM_LIM);
                PSEUDO_LENGTH(TEMP)=SHL(TEMP_SYN,8)|TEMP1;
                INX(TEMP)=TEMP_SYN*TEMP1;
             END;
    #  VECTOR
             if INX(TEMP)!=1: DO;
                ERROR(d.CLASS_QS,3);
                GO TO DEFAULT_SHAPER;
             END;
             ELSE DO;
                TEMP_SYN=ARITH_SHAPER_SUB(VEC_LENGTH_LIM);
                PSEUDO_LENGTH(TEMP),INX(TEMP)=TEMP_SYN;
             END;
    #  SCALAR
    SCALAR_SHAPER:
             if (INX(TEMP)<1)|(INX(TEMP)>N_DIM_LIM): DO;
                ERROR(d.CLASS_QS,4);
                GO TO DEFAULT_SHAPER;
             END;
             ELSE DO;
                TEMP_SYN=1;
                DO TEMP1=1 TO INX(TEMP);
                   PTR_TOP=PTR_TOP+1; # OLD STACKS BEING REINSTATED
                   LOC_P(PTR_TOP)=ARITH_SHAPER_SUB(ARRAY_DIM_LIM);
                   TEMP_SYN=LOC_P(PTR_TOP)*TEMP_SYN;
                END;
             # IF THE TOTAL NUMBER OF ELEMENTS BEING CREATED
             # WITH A SHAPING FUNCTION IS GREATER THAN 32767
             # OR LESS THAN 1 THEN GENERATE A QS8 ERROR
                if (TEMP_SYN > ARRAY_DIM_LIM) | (TEMP_SYN < 1): # ""
                   ERROR(d.CLASS_QS, 8);
                PSEUDO_LENGTH(TEMP)=TEMP_SYN;
             END;
    #  INTEGER
             GO TO SCALAR_SHAPER;
          END;
          GO TO SET_ARITH_SHAPERS;
    DEFAULT_SHAPER:
          DO CASE FIXL(MP);
    #  MATRIX
             DO;
                PSEUDO_LENGTH(PTR_TOP)=DEF_MAT_LENGTH;
                TEMP=DEF_MAT_LENGTH&"FF";
                INX(PTR_TOP)=TEMP*TEMP;
             END;
    #  VECTOR
             PSEUDO_LENGTH(PTR_TOP),INX(PTR_TOP)=DEF_VEC_LENGTH;
    #  SCALAR
             INX(PTR_TOP)=0;
    #  INTEGER
             INX(PTR_TOP)=0;
          END;
    SET_ARITH_SHAPERS:
          PSEUDO_TYPE(PTR(MP))=FIXL(MP)+MAT_TYPE;
          if PUSH_FCN_STACK(2): DO;
             FCN_LOC(FCN_LV)=FIXL(MP);
             SAVE_ARRAYNESS();
             HALMAT_POP(XSFST,0,XCO_N,FCN_LV);
             VAL_P(PTR_TOP)=LAST_POP#;
          END;
       END;
    #  <ARITH CONV>  ::=  INTEGER
       DO;
          FIXL(MP) = 3;
          SET_BI_XREF(INT_NDX);
       END;
    #  <ARITH CONV>  ::=  SCALAR
       DO;
          FIXL(MP) = 2;
          SET_BI_XREF(SCLR_NDX);
       END;
    #  <ARITH CONV>  ::=  VECTOR
       DO;
          FIXL(MP) = 1;
          SET_BI_XREF(VEC_NDX);
       END;
    #  <ARITH CONV>  ::=  MATRIX
       DO;
          FIXL(MP) = 0;
          SET_BI_XREF(MTX_NDX);
       END;
    #  <PRIMARY> ::= <ARITH VAR>
       ;
    # <PRE PRIMARY>  ::=  <ARITH FUNC HEAD> ( <CALL LIST> )
       END_ANY_FCN();
    #  <PRIMARY>  ::=  <MODIFIED ARITH FUNC>
       SETUP_NO_ARG_FCN(TEMP_SYN);
    #  <PRIMARY>  ::=  <ARITH INLINE DEF>  <BLOCK BODY>  <CLOSING>  ;
       DO;
    INLINE_SCOPE:
          TEMP2=INLINE_LEVEL;
          TEMP=XICLS;
        GRAMMAR_FLAGS(STACK_PTR(SP))=GRAMMAR_FLAGS(STACK_PTR(SP))|INLINE_FLAG;
          GO TO CLOSE_SCOPE;
       END;
    #  <PRIMARY> ::= <PRE PRIMARY>
       FIXF(MP)=0;
    #  <PRIMARY> ::= <PRE PRIMARY> <QUALIFIER>
       DO ;
          PREC_SCALE(SP,PSEUDO_TYPE(PTR(MP)));
          PTR_TOP=PTR(MP);
          FIXF(MP)=0;
       END ;
    
    #  <OTHER STATEMENT>  ::=  <ON PHRASE> <STATEMENT>
       DO;
          HALMAT_POP(XLBL,1,XCO_N,0);
          HALMAT_PIP(FIXL(MP),XINL,0,0);
          INDENT_LEVEL=INDENT_LEVEL-INDENT_INCR;
          UNBRANCHABLE(SP,7);
          FIXF(MP)=0;
       END;
    #  <OTHER STATEMENT> ::= <IF STATEMENT>
       FIXF(MP)=0;
    #  <OTHER STATEMENT>  ::= <LABEL DEFINITION> <OTHER STATEMENT>
       DO;
    LABEL_INCORP:
          if FIXL(MP)!=FIXF(SP): SYT_PTR(FIXL(MP)) = FIXF(SP);
          FIXF(MP)=FIXL(MP);
          PTR(MP)=PTR(MPP1);
          SET_LABEL_TYPE(FIXL(MP),STMT_LABEL);
       END;
    #  <STATEMENT> ::= <BASIC STATEMENT>
       DO;
          CHECK_IMPLICIT_T();
          OUTPUT_WRITER(LAST_WRITE, STMT_END_PTR);
          #ONLY SET LAST_WRITE TO 0 WHEN STATEMENT STACK
          #COMPLETELY PRINTED.
          if STMT_END_PTR > -1:
             LAST_WRITE = STMT_END_PTR + 1;
          ELSE LAST_WRITE = 0;
          EMIT_SMRK();
       END;
    #  <STATEMENT>  ::=  <OTHER STATEMENT>
       ;
    #  <ANY STATEMENT>  ::= <STATEMENT>
       PTR(MP)=1;
    # <ANY STATEMENT>::= <BLOCK DEFINITION>
       PTR(MP)=BLOCK_MODE(NEST+1)=UPDATE_MODE; # WHAT BLOCK WAS
    #  <BASIC STATEMENT>  ::= <LABEL DEFINITION> <BASIC STATEMENT>
       GO TO LABEL_INCORP;
    # <BASIC STATEMENT>::=<ASSIGNMENT>
       DO;
          XSET"4";
          PTR_TOP=PTR_TOP-INX(PTR(MP));
          if NAME_PSEUDOS: NAME_ARRAYNESS(MP);
          HALMAT_FIX_PIP#(LAST_POP#,INX(PTR(MP)));
          EMIT_ARRAYNESS();
          GO TO FIX_NOLAB;
       END;
    
    # <BASIC STATEMENT>::= EXIT ;
       DO;
    EXITTING:
          TEMP=DO_LEVEL;
          DO WHILE TEMP>1;
             if SHR(DO_INX(TEMP),7): ERROR(d.CLASS_GE,3);
             if LABEL_MATCH: DO;
                HALMAT_POP(XBRA,1,0,0);
                HALMAT_PIP(DO_LOC(TEMP),XINL,0,0);
                TEMP=1;
             END;
             TEMP=TEMP-1;
          END;
          if TEMP=1: ERROR(d.CLASS_GE,1);
          XSET"1";
          GO TO FIX_NOLAB;
       END;
    #  <BASIC STATEMENT>  ::=  EXIT  <LABEL>  ;
       DO;
          SET_XREF(FIXL(MPP1),XREF_REF);
          GO TO EXITTING;
       END;
    # <BASIC STATEMENT>::= REPEAT ;
       DO;
    REPEATING:
          TEMP=DO_LEVEL;
          DO WHILE TEMP>1;
             if SHR(DO_INX(TEMP),7): ERROR(d.CLASS_GE,4);
             if DO_INX(TEMP): if LABEL_MATCH: DO;
                HALMAT_POP(XBRA,1,0,0);
                HALMAT_PIP(DO_LOC(TEMP)+1,XINL,0,0);
                TEMP=1;
             END;
             TEMP=TEMP-1;
          END;
          if TEMP=1: ERROR(d.CLASS_GE,2);
          XSET "801";
          GO TO FIX_NOLAB;
       END;
    #  <BASIC STATEMENT>  ::=  REPEAT  <LABEL>  ;
       DO;
          SET_XREF(FIXL(MPP1),XREF_REF);
          GO TO REPEATING;
       END;
    #  <BASIC STATEMENT>  ::=  GO TO  <LABEL>  ;
       DO;
          I=FIXL(MP+2);
          SET_XREF(I,XREF_REF);
          if SYT_LINK1(I)<0: DO;
             if DO_LEVEL<(-SYT_LINK1(I)): ERROR(d.CLASS_GL,3);
          END;
          ELSE if SYT_LINK1(I) = 0: SYT_LINK1(I) = STMT_NUM;
          XSET "1001";
          if VAR_LENGTH(I)>3: ERROR(d.CLASS_GL,VAR_LENGTH(I));
          ELSE if VAR_LENGTH(I)=0: VAR_LENGTH(I)=3;
          HALMAT_POP(XBRA,1,0,0);
          HALMAT_PIP(I,XSYT,0,0);
          GO TO FIX_NOLAB;
       END;
    # <BASIC STATEMENT>::= ;
    FIX_NOLAB:FIXF(MP)=0;
    # <BASIC STATEMENT>::= <CALL KEY> ;
       END_ANY_FCN();
    # <BASIC STATEMENT>::= <CALL KEY> (<CALL LIST>) ;
       END_ANY_FCN();
    # <BASIC STATEMENT>::=<CALL KEY><ASSIGN>(<CALL ASSIGN LIST>);
       END_ANY_FCN();
    # <BASIC STATEMENT>::=<CALL KEY>(<CALL LIST>)<ASSIGN>(<CALL ASSIGN LIST>);
       END_ANY_FCN();
    # <BASIC STATEMENT>::= RETURN ;
       DO;
      if SYT_CLASS(BLOCK_SYTREF(NEST))=FUNC_CLASS: ERROR(d.CLASS_PF,1);
          ELSE if BLOCK_MODE(NEST)=UPDATE_MODE: ERROR(d.CLASS_UP,2);
          HALMAT_POP(XRTRN,0,0,0);
          XSET"7";
          GO TO FIX_NOLAB;
       END;
    # <BASIC STATEMENT>::= RETURN <EXPRESSION> ;
       DO;
          XSET"7";
          TEMP=0;
          if KILL_NAME(MPP1): ERROR(d.CLASS_PF,9);
          if CHECK_ARRAYNESS: ERROR(d.CLASS_PF,3);
          if BLOCK_MODE(NEST)=UPDATE_MODE: ERROR(d.CLASS_UP,2);
          ELSE if SYT_CLASS(BLOCK_SYTREF(NEST))!=FUNC_CLASS:
             ERROR(d.CLASS_PF,2);
          ELSE DO;
             PTR=0;
             LOC_P=BLOCK_SYTREF(NEST);
             PSEUDO_LENGTH= VAR_LENGTH(LOC_P);
             TEMP=SYT_TYPE(BLOCK_SYTREF(NEST));
             if (SHL(1,PSEUDO_TYPE(PTR(MPP1)))&ASSIGN_TYPE(TEMP))=0:
                ERROR(d.CLASS_PF,4);
          END;
          DO CASE TEMP;
             ;;;
                MATRIX_COMPARE(0,MPP1,d.CLASS_PF,5);
             VECTOR_COMPARE(0,MPP1,d.CLASS_PF,6);
             ;;;;;
              STRUCTURE_COMPARE(VAR_LENGTH(LOC_P),FIXL(MPP1),d.CLASS_PF,7);
             ;
          END;
          HALMAT_TUPLE(XRTRN,0,MPP1,0,0);
          HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,
             PSEUDO_TYPE(PTR(MPP1)),0);
          PTR_TOP=PTR(MPP1)-1;
          GO TO FIX_NOLAB;
       END;
    
    # <BASIC STATEMENT>::= <DO GROUP HEAD> <ENDING> ;
       DO;
          XSET"8";
          INDENT_LEVEL=INDENT_LEVEL - INDENT_INCR;
          NEST_LEVEL = NEST_LEVEL - 1;
          DO CASE DO_INX(DO_LEVEL)&"7F";
    # SIMPLE DO
             TEMP=XESMP;
    # DO FOR
             TEMP=XEFOR;
    # DO CASE
             DO;
                HALMAT_FIX_POPTAG(FIXV(MP),1);
                TEMP=XECAS;
                INFORMATION= '';
                CASE_LEVEL=CASE_LEVEL-1;
             END;
    # DO WHILE
             TEMP=XETST;
          END;
          HALMAT_POP(TEMP,1,0,0);
          HALMAT_PIP(DO_LOC(DO_LEVEL),XINL,0,0);
          I=0;
          DO WHILE SYT_LINK2(I)>0;
             J=SYT_LINK2(I);
             if SYT_LINK1(J)<0: if DO_LEVEL=(-SYT_LINK1(J)): DO;
                SYT_LINK1(J)=-(DO_LEVEL_LIM+1);
                SYT_LINK2(I)=SYT_LINK2(J);
             END;
             I=J;
          END;
          if DO_LOC=0: DO;
             I=DO_CHAIN(DO_LEVEL);
             DO WHILE I>0;
                CLOSE_BCD=SYT_NAME(I);
                DISCONNECT(I);
                I=SYT_LINK1(I);
             END;
             DO_LEVEL=DO_LEVEL-1;
          END;
          ELSE DO_LOC=DO_LOC-1;
          GO TO FIX_NOLAB;
       END;
    # <BASIC STATEMENT>::= <READ KEY>;
       DO;
    IO_EMIT:
          XSET"3";
          HALMAT_TUPLE(XREAD(INX(PTR(MP))),0,MP,0,0);
          PTR_TOP=PTR(MP)-1;
          HALMAT_POP(XXXND,0,0,0);
          GO TO FIX_NOLAB;
       END;
    # <BASIC STATEMENT>::= <READ PHRASE> ;
       GO TO IO_EMIT;
    # <BASIC STATEMENT>::= <WRITE KEY> ;
       GO TO IO_EMIT;
    # <BASIC STATEMENT>::= <WRITE PHRASE> ;
       GO TO IO_EMIT;
    # <BASIC STATEMENT>::= <FILE EXP> = <EXPRESSION> ;
       DO;
          HALMAT_TUPLE(XFILE,0,MP,SP-1,FIXV(MP));
          HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,PSEUDO_TYPE(PTR(SP-1)),1);
          if KILL_NAME(SP-1): ERROR(d.CLASS_T,5);
          EMIT_ARRAYNESS();
          PTR_TOP=PTR(MP)-1;
          XSET "800";
          GO TO FIX_NOLAB;
       END;
    # <BASIC STATEMENT>::= <VARIABLE> = <FILE EXP> ;
       DO;
          HALMAT_TUPLE(XFILE,0,SP-1,MP,FIXV(SP-1));
          l.H1=VAL_P(PTR(MP));
          if SHR(l.H1,7): ERROR(d.CLASS_T,4);
          if SHR(l.H1,4): ERROR(d.CLASS_T,7);
          if (l.H1&"6")="2": ERROR(d.CLASS_T,8);
          HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,PSEUDO_TYPE(PTR(MP)),0);
          if KILL_NAME(MP): ERROR(d.CLASS_T,5);
          CHECK_ARRAYNESS();  # DR 173
          PTR_TOP=PTR(MP)-1;
          GO TO FIX_NOLAB;
       END;
    # <BASIC STATEMENT>  ::=  <WAIT KEY>  FOR DEPENDENT ;
       DO;
          HALMAT_POP(XWAIT,0,0,0);
          XSET"B";
    UPDATE_CHECK:
          if UPDATE_BLOCK_LEVEL>0: ERROR(d.CLASS_RU,1);
          if INLINE_LEVEL>0: ERROR(d.CLASS_PP,6);
          REFER_LOC=0;
          GO TO FIX_NOLAB;
       END;
    # <BASIC STATEMENT>::= <WAIT KEY><ARITH EXP>;
       DO;
          TEMP=1;
          if UNARRAYED_SCALAR(SP-1): ERROR(d.CLASS_RT,6,'WAIT');
    WAIT_TIME:
          XSET"B";
          HALMAT_TUPLE(XWAIT,0,SP-1,0,TEMP);
          PTR_TOP=PTR(SP-1)-1;
          GO TO UPDATE_CHECK;
       END;
    #  <BASIC STATEMENT> ::=  <WAIT KEY> UNTIL <ARITH EXP> ;
       DO;
          TEMP=2;
          if UNARRAYED_SCALAR(SP-1): ERROR(d.CLASS_RT,6,'WAIT UNTIL');
          GO TO WAIT_TIME;
       END;
    # <BASIC STATEMENT>::= <WAIT KEY> FOR <BIT EXP> ;
       DO;
          TEMP=3;
          if CHECK_EVENT_EXP(SP-1): ERROR(d.CLASS_RT,6,'WAIT FOR');
          GO TO WAIT_TIME;
       END;
    # <BASIC STATEMENT>::= <TERMINATOR> ;
       DO;
          XSET"A";
          HALMAT_POP(FIXL(MP),0,0,0);
          GO TO UPDATE_CHECK;
       END;
    # <BASIC STATEMENT>::= <TERMINATOR> <TERMINATE LIST>;
       DO;
          XSET"A";
          HALMAT_POP(FIXL(MP),EXT_P(PTR(MPP1)),0,1);
          DO l.H1=PTR(MPP1) TO EXT_P(PTR(MPP1))+PTR(MPP1)-1;
             HALMAT_PIP(LOC_P(l.H1),PSEUDO_FORM(l.H1),0,0);
          END;
          PTR_TOP=PTR(MPP1)-1;
          GO TO UPDATE_CHECK;
       END;
    # <BASIC STATEMENT>::= UPDATE PRIORITY TO <ARITH EXP>;
       DO;
          PTR_TOP=PTR(SP-1)-1;
          TEMP=0;
    UP_PRIO:
          XSET"C";
          if UNARRAYED_INTEGER(SP-1):
             ERROR(d.CLASS_RT,4,'UPDATE PRIORITY');
          HALMAT_TUPLE(XPRIO,0,SP-1,TEMP,TEMP>0);
          GO TO UPDATE_CHECK;
       END;
    #  <BASIC STATEMENT>  ::=  UPDATE PRIORITY  <LABEL VAR>  TO  <ARITH EXP>;
       DO;
          SET_XREF_RORS(MP+2,"C000");
          PROCESS_CHECK(MP+2);
          TEMP=MP+2;
          PTR_TOP=PTR(TEMP)-1;
          GO TO UP_PRIO;
       END;
    # <BASIC STATEMENT>::= <SCHEDULE PHRASE>;
       DO;
    SCHEDULE_EMIT:
          XSET"9";
          HALMAT_POP(XSCHD,PTR_TOP-REFER_LOC+1,0,INX(REFER_LOC));
          DO WHILE REFER_LOC<=PTR_TOP;
             HALMAT_PIP(LOC_P(REFER_LOC),PSEUDO_FORM(REFER_LOC),0,0);
             REFER_LOC=REFER_LOC+1;
          END;
          PTR_TOP=PTR(MP)-1;
          GO TO UPDATE_CHECK;
       END;
    # <BASIC STATEMENT>::=<SCHEDULE PHRASE><SCHEDULE CONTROL>;
       GO TO SCHEDULE_EMIT;
    #  <BASIC  STATEMENT>  ::=  <SIGNAL CLAUSE>  ;
       DO;
          XSET"D";
          HALMAT_TUPLE(XSGNL,0,MP,0,INX(PTR(MP)));
          PTR_TOP=PTR(MP)-1;
          GO TO FIX_NOLAB;
       END;
    #  <BASIC STATEMENT>  ::=  SEND ERROR <SUBSCRIPT>  ;
       DO;
          ERROR_SUB(2);
          HALMAT_TUPLE(XERSE,0,MP+2,0,0,FIXV(MP)&"3F");
          SET_OUTER_REF(FIXV(MP),"0000");
          PTR_TOP=PTR(MP+2)-1;
          GO TO FIX_NOLAB;
       END;
    #  <BASIC STATEMENT>  ::=  <ON CLAUSE>  ;
       DO;
          HALMAT_TUPLE(XERON,0,MP,0,FIXL(MP),FIXV(MP)&"3F");
          PTR_TOP=PTR(MP)-1;
          GO TO FIX_NOLAB;
       END;
    #  <BASIC STATEMENT>  ::=  <ON CLAUSE> AND <SIGNAL CLAUSE> ;
       DO;
          HALMAT_TUPLE(XERON,0,MP,MP+2,FIXL(MP),FIXV(MP)&"3F",0,0,
             INX(PTR(MP+2)));
          PTR_TOP=PTR(MP)-1;
          GO TO FIX_NOLAB;
       END;
    #  <BASIC STATEMENT>  ::=  OFF ERROR <SUBSCRIPT>  ;
       DO;
          ERROR_SUB(0);
          HALMAT_TUPLE(XERON,0,MP+2,0,3,FIXV(MP)&"3F");
          PTR_TOP=PTR(MP+2)-1;
          GO TO FIX_NOLAB;
       END;
    #  <BASIC STATEMENT>  ::=  <% MACRO NAME> ;
       DO;
          HALMAT_POP(XPMHD,0,0,FIXL(MP));
          HALMAT_POP(XPMIN,0,0,FIXL(MP));
          XSET (PC_STMT_TYPE_BASE + FIXL(MP));
          if PCARG#(FIXL(MP)) != 0:
             if ALT_PCARG#(FIXL(MP)) != 0:
             ERROR(d.CLASS_XM, 2, VAR(MP));
          GO TO FIX_NOLAB;
       END;
    #  <BASIC STATEMENT>  ::=  <% MACRO HEAD> <% MACRO ARG> ) ;
       DO;
          if PCARG# != 0:
             if ALT_PCARG# != 0:
             ERROR(d.CLASS_XM, 2, VAR(MP));
          HALMAT_TUPLE(XPMAR, 0, MPP1, 0, 0, PSEUDO_TYPE(PTR(MPP1)));
          PTR_TOP=PTR(MPP1)-1;
          DELAY_CONTEXT_CHECK=FALSE;
          HALMAT_POP(XPMIN,0,0,FIXL(MP));
          ASSIGN_ARG_LIST = FALSE;  # RESTORE LOCK GROUP CHECKING
    
          # RESET PCARGOFF HERE SO THAT IT CAN BE USED
          # TO DETERMINE WHETHER PERCENT MACRO ARGUMENT
          # PROCESSING IS HAPPENING.
          PCARGOFF = 0;
          GO TO FIX_NOLAB;
       END;
    #  <% MACRO HEAD>  ::=  <% MACRO NAME> (
       DO;
          if FIXL(MP) = 0: ALT_PCARG#, PCARG#, PCARGOFF = 0;
          ELSE DO;
             PCARG#=PCARG#(FIXL(MP));
             PCARGOFF=PCARGOFF(FIXL(MP));
    
             # CHECK PCARGBITS OF THE %MACRO ARGUMENT TO
             # SEE IF IT REQUIRES NAME CONTEXT CHECKING.
             # IF SO, SET NAMING FLAG.
             if ((PCARGBITS(PCARGOFF)&"80")!=0):
                NAMING = TRUE;
    
             ALT_PCARG# = ALT_PCARG#(FIXL(MP));
          END;
          XSET (PC_STMT_TYPE_BASE + FIXL(MP));
          HALMAT_POP(XPMHD,0,0,FIXL(MP));
          DELAY_CONTEXT_CHECK=TRUE;
          if FIXL(MP) = PCCOPY_INDEX:
             ASSIGN_ARG_LIST = TRUE;  # INHIBIT LOCK CHECK IN ASSOCIATE
       END;
    #  <% MACRO HEAD>  ::=  <% MACRO HEAD> <% MACRO ARG> ,
       DO;
          HALMAT_TUPLE(XPMAR, 0, MPP1, 0, 0, PSEUDO_TYPE(PTR(MPP1)));
          PTR_TOP=PTR(MPP1)-1;
       END;
    #  <% MACRO ARG>  ::=  <NAME VAR>
       if PCARGOFF>0: DO;
          if PCARG#=0: PCARGOFF=0;
          ELSE DO;
             TEMP=PCARGBITS(PCARGOFF);
             if (TEMP&"1")=0: ERROR(d.CLASS_XM,5);
             ELSE DO;
                l.H1=PSEUDO_TYPE(PTR(MP));
                if l.H1 > "40": l.H1 = (l.H1 & "F") + 10;
                ELSE if TEMP_SYN = 0: l.H1 = l.H1 + 20;
                if (SHL(1,l.H1)&PCARGTYPE(PCARGOFF))=0:
                   ERROR(d.CLASS_XM,4);   # ILLEGAL TYPE
                if EXT_P(PTR(MP))>0: if SHR(TEMP,6):
                   ERROR(d.CLASS_XM,10);   # NO NAME COPINESS
                RESET_ARRAYNESS();
                if CHECK_ARRAYNESS: if SHR(TEMP,5):
                   ERROR(d.CLASS_XM,7);  # NO ARRAYNESS
                if SHR(TEMP,4): if TEMP_SYN!=2: TEMP_SYN=3;
                if SHR(TEMP,7): CHECK_NAMING(TEMP_SYN,MP);
                ELSE DO;
                   if SHR(TEMP,4): CHECK_ASSIGN_CONTEXT(MP);
                   ELSE SET_XREF_RORS(MP);
                   if FIXV(MP)>0: l.H2=FIXV(MP);
                   ELSE l.H2=FIXL(MP);
                   if (SYT_FLAGS(l.H2)&(TEMPORARY_FLAG))!=0:
                      if SHR(TEMP,8): ERROR(d.CLASS_XM,8);
                   l.H2=VAL_P(PTR(MP));
           # NO SUBSCRIPTS ARE ALLOWED ON THE SOURCE OF %NAMEBIAS
                   if PCARGOFF=2: DO;
                      if SHR(TEMP,2):
                         if SHR(l.H2,5): ERROR(d.CLASS_XM,9);
                   END;
                   ELSE
                      if SHR(TEMP,2):
                         if SHR(l.H2,4): ERROR(d.CLASS_XM,9);
                END;
             END;
             PCARGOFF=PCARGOFF+1;
    
             # CHECK PCARGBITS OF THE %MACRO ARGUMENT TO
             # SEE IF IT REQUIRES NAME CONTEXT CHECKING.
             # IF SO, SET NAMING FLAG.
             if ((PCARGBITS(PCARGOFF)&"80")!=0):
                NAMING = TRUE;
    
          END;
          PCARG#=PCARG#-1;
          ALT_PCARG# = ALT_PCARG# - 1;
       END;
    #  <% MACRO ARG>  ::=  <CONSTANT>
       if PCARGOFF>0: DO;
          if PCARGp==0: PCARGOFF=0;
          ELSE DO;
             if (PCARGBITS(PCARGOFF)&"8")=0: ERROR(d.CLASS_XM,3);
    # LITERALS ILLEGAL
             ELSE if (SHL(1,PSEUDO_TYPE(PTR(MP)))&PCARGTYPE(PCARGOFF))=0:
                ERROR(d.CLASS_XM,4);    #  TYPE ILLEGAL
             PCARGOFF=PCARGOFF+1;
          END;
          PCARG#=PCARG#-1;
          ALT_PCARG# = ALT_PCARG# - 1;
       END;
    #  <BIT PRIM>  ::=  <BIT VAR>
       DO;
          SET_XREF_RORS(MP);
    NON_EVENT:
          INX(PTR(MP))=FALSE;
       END;
    #  <BIT PRIM>  ::=  <LABEL VAR>
       DO;
          SET_XREF_RORS(MP,"2000");
          TEMP=PSEUDO_TYPE(PTR(MP));
          if (TEMP=TASK_LABEL)|(TEMP=PROG_LABEL):;
          ELSE ERROR(d.CLASS_RT,14,VAR(MP));
          if REFER_LOC>0: INX(PTR(MP))=1;
          ELSE INX(PTR(MP))=2;
    YES_EVENT:
          PSEUDO_TYPE(PTR(MP))=BIT_TYPE;
          PSEUDO_LENGTH(PTR(MP))=1;
       END;
    #  <BIT PRIM>  ::=  <EVENT VAR>
       DO;
          SET_XREF_RORS(MP);
          INX(PTR(MP))=REFER_LOC>0;
          GO TO YES_EVENT;
       END;
    #  <BIT PRIM>  ::=  <BIT CONST>
       GO TO NON_EVENT;
    #  <BIT PRIM>  ::=  (  <BIT EXP>  )
       PTR(MP)=PTR(MPP1);
    #  <BIT PRIM>  ::=  <MODIFIED BIT FUNC>
       DO;
          SETUP_NO_ARG_FCN();
          GO TO NON_EVENT;
       END;
    #  <BIT PRIM>  ::=  <BIT INLINE DEF> <BLOCK BODY> <CLOSING>  ;
       DO;
          GO TO INLINE_SCOPE;
       END;
    #  <BIT PRIM>  ::=  <SUBBIT HEAD>  <EXPRESSION>  )
       DO;
          END_SUBBIT_FCN;
          SET_BI_XREF(SBIT_NDX);
          GO TO NON_EVENT;
       END;
    #  <BIT PRIM>  ::=  <BIT FUNC HEAD>  (  <CALL LIST>  )
       DO;
          END_ANY_FCN();
          GO TO NON_EVENT;
       END;
    #  <BIT FUNC HEAD>  ::= <BIT FUNC>
       if START_NORMAL_FCN: ASSOCIATE();
    #  <BIT FUNC HEAD>  ::=  BIT  <SUB OR QUALIFIER>
       DO;
          NOSPACE;
          PTR(MP)=PTR(SP);
          PSEUDO_TYPE(PTR(MP))=BIT_TYPE;
          VAR(MP)='BIT CONVERSION FUNCTION';
          if PUSH_FCN_STACK(3): FCN_LOC(FCN_LV)=1;
          SET_BI_XREF(BIT_NDX);
       END;
    #  <BIT CAT> ::= <BIT PRIM>
       ;
    #  <BIT CAT>  ::=  <BIT CAT>  <CAT>  <BIT PRIM>
    DO_BIT_CAT :
       DO ;
          INX(PTR(MP))=FALSE;
          TEMP=PSEUDO_LENGTH(PTR(MP))+PSEUDO_LENGTH(PTR(SP));
          if TEMP>BIT_LENGTH_LIM: DO;
             TEMP=BIT_LENGTH_LIM;
             ERROR(d.CLASS_EB,1);
          END;
          HALMAT_TUPLE(XBCAT,0,MP,SP,0);
          SETUP_VAC(MP,BIT_TYPE,TEMP);
          PTR_TOP=PTR(MP);
       END ;
    # <BIT CAT> ::= <NOT> <BIT PRIM>
       DO ;
          if BIT_LITERAL(SP,0): DO;
             TEMP=PSEUDO_LENGTH(PTR(SP));
             TEMP2=SHL(FIXV(SP),HOST_BIT_LENGTH_LIM-TEMP);
             TEMP2=^TEMP2;
             TEMP2=SHR(TEMP2,HOST_BIT_LENGTH_LIM-TEMP);
             LOC_P(PTR(SP))=SAVE_LITERAL(2,TEMP2,TEMP);
          END;
          ELSE DO;
             HALMAT_TUPLE(XBNOT,0,SP,0,INX(PTR(SP)));
             SETUP_VAC(SP,BIT_TYPE);
          END;
          INX(PTR(SP))=INX(PTR(SP))&1;
          PTR(MP)=PTR(SP);
       END ;
    # <BIT CAT> ::= <BIT CAT> <CAT> <NOT> <BIT PRIM>
       DO;
          HALMAT_TUPLE(XBNOT,0,SP,0,0);
          SETUP_VAC(SP,BIT_TYPE);
          GO TO DO_BIT_CAT;
       END ;
    #  <BIT FACTOR> ::= <BIT CAT>
       ;
    #   <BIT FACTOR> ::= <BIT FACTOR> <AND> <BIT CAT>
       DO ;
          if BIT_LITERAL(MP,SP): DO;
             TEMP=FIXV(MP)&FIXV(SP);
    DO_LIT_BIT_FACTOR:
             if PSEUDO_LENGTH(PTR(MP)) != PSEUDO_LENGTH(PTR(SP))
               : ERROR(d.CLASS_YE,100);
             TEMP2=PSEUDO_LENGTH(PTR(MP));
            if TEMP2<PSEUDO_LENGTH(PTR(SP)): TEMP2=PSEUDO_LENGTH(PTR(SP));
             LOC_P(PTR(MP))=SAVE_LITERAL(2,TEMP,TEMP2);
          END;
          ELSE DO;
             TEMP = XBAND ;
    DO_BIT_FACTOR:
             TEMP2=INX(PTR(MP))&INX(PTR(SP))&1;
             HALMAT_TUPLE(TEMP,0,MP,SP,TEMP2);
             INX(PTR(MP))=TEMP2;
             TEMP=PSEUDO_LENGTH(PTR(MP));
             if TEMP<PSEUDO_LENGTH(PTR(SP)):
                TEMP=PSEUDO_LENGTH(PTR(SP));
             SETUP_VAC(MP,BIT_TYPE,TEMP);
          END;
          PTR_TOP=PTR(MP);
       END ;
    #  <BIT EXP> ::= <BIT FACTOR>
       ;
    #   <BIT EXP> ::= <BIT EXP> <OR> <BIT FACTOR>
       DO ;
          if BIT_LITERAL(MP,SP): DO;
             TEMP=FIXV(MP)|FIXV(SP);
             GO TO DO_LIT_BIT_FACTOR;
          END;
          ELSE DO;
             TEMP=XBOR;
             GO TO DO_BIT_FACTOR;
          END;
       END ;
    
    #  <RELATIONAL OP> ::= =
       REL_OP = 0 ;
    # <RELATIONAL OP> ::= <NOT> =
       REL_OP = 1 ;
    #  <RELATIONAL OP> ::= <
       REL_OP = 2 ;
    #  <RELATIONAL OP> ::= >
       REL_OP = 3 ;
    # <RELATIONAL OP> ::= <  =
       DO;
          NOSPACE;
          REL_OP = 4 ;
       END;
    # <RELATIONAL OP> ::= >  =
       DO;
          NOSPACE;
          REL_OP = 5 ;
       END;
    # <RELATIONAL OP> ::= <NOT> <
       REL_OP = 5 ;
    # <RELATIONAL OP> ::= <NOT> >
       REL_OP = 4 ;
    
    #  <COMPARISON> ::= <ARITH EXP> <RELATIONAL OP> <ARITH EXP>
       DO ;
          MATCH_ARITH(MP,SP);
          DO CASE PSEUDO_TYPE(PTR(MP))-MAT_TYPE;
             DO;
                TEMP=XMEQU(REL_OP);
                VAR(MP)='MATRIX';
             END;
             DO;
                TEMP=XVEQU(REL_OP);
                VAR(MP)='VECTOR';
             END;
             DO;
                TEMP=XSEQU(REL_OP);
                VAR(MP)='';
             END;
             DO;
                TEMP=XIEQU(REL_OP);
                VAR(MP)='';
             END;
          END;
    EMIT_REL:
          HALMAT_TUPLE(TEMP,XCO_N,MP,SP,0);
       END ;
    # <COMPARISON> ::= <CHAR EXP> <RELATIONAL OP> <CHAR EXP>
       DO ;
          TEMP=XCEQU(REL_OP);
          VAR(MP)='';
          GO TO EMIT_REL;
       END ;
    # <COMAPRISON> ::= <BIT CAT> <RELATIONAL OP> <BIT CAT>
       DO ;
          TEMP=XBEQU(REL_OP);
          VAR(MP)='BIT';
          GO TO EMIT_REL;
       END ;
    #  <COMPARISON>  ::=  <STRUCTURE EXP> <RELATIONAL OP> <STRUCTURE EXP>
       DO ;
          TEMP=XTEQU(REL_OP);
          VAR(MP)='STRUCTURE';
          STRUCTURE_COMPARE(FIXL(MP),FIXL(SP),d.CLASS_C,3);
          GO TO EMIT_REL;
       END ;
    #  <COMPARISON>  ::=  <NAME EXP>  <RELATIONAL OP>  <NAME EXP>
       DO;
          NAME_COMPARE(MP,SP,d.CLASS_C,4);
          TEMP=XNEQU(REL_OP);
          VAR(MP)='NAME';
          if COPINESS(MP,SP): ERROR(d.CLASS_EA,1,VAR(SP));
          NAME_ARRAYNESS(SP);
          GO TO EMIT_REL;
       END;
    #  <RELATIONAL FACTOR>  ::=  <REL PRIM>
       ;
    # <RELATIONAL FACTOR> ::= <RELATIONAL FACTOR> <AND> <REL PRIM>
       DO ;
          HALMAT_TUPLE(XCAND,XCO_N,MP,SP,0);
          SETUP_VAC(MP,0);
          PTR_TOP=PTR(MP);
       END ;
    # <RELATIONAL EXP> ::= <RELATIONAL FACTOR>
       ;
    # <RELATIONAL EXP> ::= < RELATIONAL EXP> <OR> < RELATIONAL FACTOR>
       DO ;
          HALMAT_TUPLE(XCOR,XCO_N,MP,SP,0);
          SETUP_VAC(MP,0);
          PTR_TOP=PTR(MP);
       END ;
    # <REL PRIM> ::= (1 <RELATIONAL EXP> )
       PTR(MP) = PTR(MPP1) ; # MOVE INDIRECT STACKS
    # <REL PRIM> ::= <NOT> (1 <RELATIONAL EXP> )
       DO ;
          HALMAT_TUPLE(XCNOT,XCO_N,MP+2,0,0);
          PTR(MP)=PTR(MP+2);
          SETUP_VAC(MP,0);
       END ;
    # <REL PRIM> ::=  <COMPARISON>
       DO ;
          if REL_OP>1: DO;
             if LENGTH(VAR(MP))>0: ERROR(d.CLASS_C,1,VAR(MP));
             ELSE if CHECK_ARRAYNESS: ERROR(d.CLASS_C,2);
             CHECK_ARRAYNESS();
          END;
          SETUP_VAC(MP,0);
          PTR_TOP=PTR(MP);
          EMIT_ARRAYNESS();
       END ;
    
    #  <CHAR PRIM> ::= <CHAR VAR>
       SET_XREF_RORS(MP);  # SET XREF FLAG TO SUBSCR OR REF
    #  <CHAR PRIM>  ::=  <CHAR CONST>
       ;
    #  <CHAR PRIM>  ::=  <MODIFIED CHAR FUNC>
       SETUP_NO_ARG_FCN();
    #  <CHAR PRIM>  ::=  <CHAR INLINE DEF> <BLOCK BODY> <CLOSING>  ;
       GO TO INLINE_SCOPE;
    #  <CHAR PRIM>  ::=  <CHAR FUNC HEAD>  (  <CALL LIST>  )
       END_ANY_FCN();
    #  <CHAR PRIM>  ::=  (  <CHAR EXP>  )
       PTR(MP)=PTR(MPP1);
    #  <CHAR FUNC HEAD>  ::=  <CHAR FUNC>
       if START_NORMAL_FCN: ASSOCIATE();
    #  <CHAR FUNC HEAD>  ::=  CHARACTER  <SUB OR QUALIFIER>
       DO;
          NOSPACE;
          PTR(MP)=PTR(SP);
          PSEUDO_TYPE(PTR(MP))=CHAR_TYPE;
          VAR(MP)='CHARACTER CONVERSION FUNCTION';
          if PUSH_FCN_STACK(3): FCN_LOC(FCN_LV)=0;
          SET_BI_XREF(CHAR_NDX);
       END;
    #  <SUB OR QUALIFIER>  ::=  <SUBSCRIPT>
       DO;
          TEMP=PTR(MP);
          LOC_P(TEMP)=0;
          if PSEUDO_FORM(TEMP)!=0: DO;
             PSEUDO_FORM(TEMP)=0;
             ERROR(d.CLASS_QS,9);
          END;
          if INX(TEMP)>0: DO;
             if (PSEUDO_LENGTH(TEMP)>=0)|(VAL_P(TEMP)>=0):
                ERROR(d.CLASS_QS,1);
             if INX(TEMP)!=1: DO;
                INX(TEMP)=1;
                ERROR(d.CLASS_QS,10);
             END;
          END;
       END;
    #  <SUB OR QUALIFIER>  ::=  <BIT QUALIFIER>
       INX(PTR(MP))=0;
    
    #  <CHAR EXP> ::= <CHAR PRIM>
       ;
    # <CHAR EXP> ::= <CHAR EXP> <CAT> <CHAR PRIM>
       DO;
          if CHAR_LITERAL(MP,SP): DO;
             TEMP=CHAR_LENGTH_LIM - LENGTH(VAR(MP));
             if TEMP<LENGTH(VAR(SP)): DO;
                VAR(SP)=SUBSTR(VAR(SP),0,TEMP);
                ERROR(d.CLASS_VC,1);
             END;
             VAR(MP)=VAR(MP)+VAR(SP);
             LOC_P(PTR(MP))=SAVE_LITERAL(0,VAR(MP));
             PSEUDO_LENGTH(PTR(MP)) = LENGTH(VAR(MP));
          END;
          ELSE DO;
    DO_CHAR_CAT:
             HALMAT_TUPLE(XCCAT,0,MP,SP,0);
             SETUP_VAC(MP,CHAR_TYPE);
          END;
          PTR_TOP=PTR(MP);
       END;
    # <CHAR EXP> ::= <CHAR EXP> <CAT> <ARITH EXP>
       DO ;
          ARITH_TO_CHAR(SP) ;
          GO TO DO_CHAR_CAT ;
       END ;
    #  <CHAR EXP>  ::=  <ARITH EXP>  <CAT>  <ARITH EXP>
       DO;
          ARITH_TO_CHAR(SP);
          ARITH_TO_CHAR(MP);
          GO TO DO_CHAR_CAT;
       END;
    # <CHAR EXP> ::= <ARITH EXP> <CAT> <CHAR PRIM>
       DO ;
          ARITH_TO_CHAR(MP) ;
          GO TO DO_CHAR_CAT ;
       END ;
    # <ASSIGNMENT>::=<VARIABLE><=1><EXPRESSION>
       DO;
          INX(PTR(SP))=2;
          if NAME_PSEUDOS: DO;
             NAME_COMPARE(MP,SP,d.CLASS_AV,5);
             HALMAT_TUPLE(XNASN,0,SP,MP,0);
             if COPINESS(MP,SP)>2: ERROR(d.CLASS_AA,1);
             GO TO END_ASSIGN;
          END;
          if RESET_ARRAYNESS>2: ERROR(d.CLASS_AA,1);
          HALMAT_TUPLE(XXASN(PSEUDO_TYPE(PTR(SP))),0,SP,MP,0);
    ASSIGNING:
          TEMP=PSEUDO_TYPE(PTR(SP));
          if TEMP=INT_TYPE: if PSEUDO_FORM(PTR(SP))=XLIT: DO;
             TEMP2=GET_LITERAL(LOC_P(PTR(SP)));
             if LIT2(TEMP2)=0: TEMP=0;
          END;
          if (SHL(1,TEMP)&ASSIGN_TYPE(PSEUDO_TYPE(PTR(MP))))=0:
             ERROR(d.CLASS_AV,1,VAR(MP));
          ELSE if TEMP>0: DO CASE PSEUDO_TYPE(PTR(MP));
             ;
             ; #BIT
             #CHAR*/
             # CHECK IF THE EXPRESSION BEING ASSIGNED TO A
             # CHARACTER IS SCALAR AND SHOULD BE IN DOUBLE
             # PRECISION (DOUBLELIT=TRUE).  IF TRUE, THEN SET
             # LIT1 EQUAL TO 5.
             if (PSEUDO_TYPE(PTR(SP))=SCALAR_TYPE) & DOUBLELIT: # "
               LIT1(GET_LITERAL(LOC_P(PTR(SP)))) = 5;
             MATRIX_COMPARE(MP,SP,d.CLASS_AV,2); #MATRIX
             VECTOR_COMPARE(MP,SP,d.CLASS_AV,3); #VECTOR
             ; #SCALAR
             ; #INTEGER
             ;;
                ; #EVENT
             STRUCTURE_COMPARE(FIXL(MP),FIXL(SP),d.CLASS_AV,4); # STRUC
             ;
          END;
    END_ASSIGN:
          DOUBLELIT = FALSE;
          FIXV(MP)=FIXV(SP);
          PTR(MP)=PTR(SP);
       END;
    # <ASSIGNMENT>::=<VARIABLE>,<ASSIGNMENT>
       DO;
          HALMAT_PIP(LOC_P(PTR(MP)),PSEUDO_FORM(PTR(MP)),0,0);
          INX(PTR(SP))=INX(PTR(SP))+1;
          if NAME_PSEUDOS: DO;
             NAME_COMPARE(MP,SP,d.CLASS_AV,5,0);
             if COPINESS(MP,SP)>0: ERROR(d.CLASS_AA,2,VAR(MP));
             GO TO END_ASSIGN;
          END;
          ELSE GO TO ASSIGNING;
       END;
    
    
    # <IF STATEMENT>::= <IF CLAUSE> <STATEMENT>
       DO;
          UNBRANCHABLE(SP,4);
    CLOSE_IF:
          INDENT_LEVEL=FIXL(MP);
          HALMAT_POP(XLBL,1,XCO_N,1);
          HALMAT_PIP(FIXV(MP),XINL,0,0);
       END;
    # <IF STATEMENT>::=<TRUE PART> <STATEMENT>
       DO;
          UNBRANCHABLE(SP,5);
          GO TO CLOSE_IF;
       END;
    # <TRUE PART>::=<IF CLAUSE><BASIC STATEMENT> ELSE
       DO;
          UNBRANCHABLE(MPP1,4);
          CHECK_IMPLICIT_T();
          ELSEIF_PTR = STACK_PTR(SP);
          #MOVE ELSEIF_PTR TO FIRST PRINTABLE REPLACE MACRO TOKEN-111342
          I = ELSEIF_PTR;
          DO WHILE (I > 0) &
          ((GRAMMAR_FLAGS(I-1) & MACRO_ARG_FLAG)!=0);
             I = I - 1;
             if ((GRAMMAR_FLAGS(I) & PRINT_FLAG)!=0):
                ELSEIF_PTR = I;
          END;
          if ELSEIF_PTR > 0:
             if STMT_END_PTR > -1: DO;
               SQUEEZING = FALSE;
               OUTPUT_WRITER(LAST_WRITE, ELSEIF_PTR - 1);
               LAST_WRITE = ELSEIF_PTR;
          END;
          # ALIGN ELSE CORRECTLY.
          if MOVE_ELSE:
             INDENT_LEVEL=INDENT_LEVEL-INDENT_INCR;
          MOVE_ELSE = TRUE;
          EMIT_SMRK();
          SRN_UPDATE();
          # PUT THE ELSE ON THE SAME LINE AS THE DO.
          ELSE_FLAG = TRUE;
          #DETERMINES IF ELSE WAS ALREADY PRINTED IN REPLACE MACRO-11342
          if (GRAMMAR_FLAGS(ELSEIF_PTR) & PRINT_FLAG)=0:
             ELSE_FLAG = FALSE;
          if NO_LOOK_AHEAD_DONE: CALL_SCAN();
          if TOKEN != IF_TOKEN: DO;
          #  PRINT ELSE STATEMENTS ON SAME LINE AS A
          # SIMPLE DO.  IF ELSE_FLAG IS FALSE, THEN THE ELSE STATEMENT
          # WAS ALREADY PRINTED.
             if ^ELSE_FLAG  : DO;
                INDENT_LEVEL = INDENT_LEVEL + INDENT_INCR;
             END;
             ELSE DO;
             # DO NOT OUTPUT_WRITER.  SAVE VALUES
             # THAT ARE NEEDED WHEN OUTPUT_WRITER WILL BE CALLED.
                SAVE_SRN1 = SRN(2);
                SAVE_SRN_COUNT1 = SRN_COUNT(2);
                SAVE1 = ELSEIF_PTR;
                SAVE2 = STACK_PTR(SP);
             END;
          END;
          ELSE DO;
             # IF ELSE_FLAG IS FALSE, THEN THE ELSE STATEMENT
             # WAS ALREADY PRINTED FROM PRINT_COMMENT AND INDENT_LEVEL
             # SHOULD BE SET TO INDENT THE LINE FOLLOWING THE COMMENT
             # OR DIRECTIVE.
             if ^ELSE_FLAG:
                INDENT_LEVEL = INDENT_LEVEL + INDENT_INCR;
             ELSE_FLAG = FALSE;
             LAST_WRITE = ELSEIF_PTR;
          END;
          HALMAT_POP(XBRA,1,0,1);
          HALMAT_PIP(FL_NO,XINL,0,0);
          HALMAT_POP(XLBL,1,XCO_N,0);
          HALMAT_PIP(FIXV(MP),XINL,0,0);
          FIXV(MP)=FL_NO;
          XSET"100";
          FL_NO=FL_NO+1;
       END;
    # <IF CLAUSE>  ::=  <IF> <RELATIONAL EXP> THEN
       DO;
          TEMP=LOC_P(PTR(MPP1));
    EMIT_IF:
          HALMAT_POP(XFBRA,2,XCO_N,0);
          HALMAT_PIP(FL_NO,XINL,0,0);
          HALMAT_PIP(TEMP,XVAC,0,0);
          PTR_TOP=PTR(MPP1)-1;
          FIXV(MP)=FL_NO;
          FL_NO=FL_NO+1;
          # PRINT IF-THEN STATEMENTS ON SAME LINE AS A
          # SIMPLE DO.  DO NOT OUTPUT_WRITER.  SAVE VALUES THAT
          # ARE NEEDED WHEN OUTPUT_WRITER WILL BE CALLED.
          IF_FLAG = TRUE;
          # DETERMINES IF IF-THEN WAS ALREADY PRINTED IN REPLACE MACRO-11342
          if (GRAMMAR_FLAGS(LAST_WRITE) & PRINT_FLAG)=0: DO;
             IF_FLAG = FALSE;
             DO I=(LAST_WRITE+1) TO STACK_PTR(SP);
                if (GRAMMAR_FLAGS(I) & PRINT_FLAG)!=0:
                   IF_FLAG = TRUE;
             END;
          END;
          if ^IF_FLAG & (STMT_STACK(LAST_WRITE)!=l.ELSE_TOKEN):
             INDENT_LEVEL = INDENT_LEVEL + INDENT_INCR;
          ELSE DO;
             SAVE_SRN1 = SRN(2);
             SAVE_SRN_COUNT1 = SRN_COUNT(2);
             SAVE1 = LAST_WRITE;
             SAVE2 = STACK_PTR(SP);
          END;
          EMIT_SMRK();
          XSET"200";
       END;
    #  <IF CLAUSE>  ::=  <IF> <BIT EXP> THEN
       DO;
          HALMAT_TUPLE(XBTRU,0,MPP1,0,0);
          if PSEUDO_LENGTH(PTR(MPP1))>1: ERROR(d.CLASS_GB,1,'IF');
          TEMP=LAST_POP#;
          EMIT_ARRAYNESS();
          GO TO EMIT_IF;
       END;
    #  <IF>  ::=  IF
       DO;
          XSET"5";
          FIXL(MP)=INDENT_LEVEL;
          HALMAT_POP(XIFHD,0,XCO_N,0);
       END;
    # <DO GROUP HEAD>::= DO ;
       DO;
          XSET"11";
          FIXL(MPP1)=0;
          HALMAT_POP(XDSMP,1,0,0);
          EMIT_PUSH_DO(0,1,0,MP-1);
    DO_DONE:
          FIXV(MP)=0;
          CHECK_IMPLICIT_T();
          # PRINT IF-THEN/ELSE STATEMENTS ON SAME LINE AS A
          # SIMPLE DO.  IF AN IF-THEN OR ELSE WAS THE PREVIOUS STATEMENT
          # PRINT THE DO ON THE SAME LINE USING SRN & STATEMENT NUMBER
          # FROM IF-THEN OR ELSE.
          if (IF_FLAG|ELSE_FLAG) & (PRODUCTION_NUMBER=144):
          DO;
            SQUEEZING = FALSE;
            SAVE_SRN2 = SRN(2);
            SRN(2) = SAVE_SRN1;
            SAVE_SRN_COUNT2 = SRN_COUNT(2);
            SRN_COUNT(2) = SAVE_SRN_COUNT1;
            if IF_FLAG:
               STMT_NUM = STMT_NUM - 1;
            OUTPUT_WRITER(SAVE1, STMT_PTR);
            if IF_FLAG:
               STMT_NUM = STMT_NUM + 1;
            IF_FLAG,ELSE_FLAG = FALSE;
            IFDO_FLAG(DO_LEVEL) = TRUE;
            SRN(2) = SAVE_SRN2;
            SRN_COUNT(2) = SAVE_SRN_COUNT2;
          END;
          ELSE DO;
            IF_FLAG,ELSE_FLAG = FALSE;
            OUTPUT_WRITER(LAST_WRITE, STMT_PTR);
          END;
          if FIXL(MPP1)>0: DO;
             HALMAT_POP(XTDCL,1,0,0);
             HALMAT_PIP(FIXL(MPP1),XSYT,0,0);
          END;
          EMIT_SMRK();
          INDENT_LEVEL=INDENT_LEVEL + INDENT_INCR;
          NEST_LEVEL = NEST_LEVEL + 1;
       END;
    # <DO GROUP HEAD>::= DO <FOR LIST> ;
       DO;
          XSET"13";
          HALMAT_FIX_POPTAG(FIXV(MPP1),PTR(MPP1));
          GO TO DO_DONE;
       END;
    # <DO GROUP HEAD>::= DO <FOR LIST> <WHILE CLAUSE> ;
       DO;
          XSET"13";
          TEMP=PTR(SP-1);
          HALMAT_FIX_POPTAG(FIXV(MPP1),SHL(INX(TEMP),4)|PTR(MPP1));
          HALMAT_POP(XCFOR,1,0,INX(TEMP));
    EMIT_WHILE:
          HALMAT_PIP(LOC_P(TEMP),PSEUDO_FORM(TEMP),0,0);
          PTR_TOP=TEMP-1;
          GO TO DO_DONE;
       END;
    # <DO GROUP HEAD>::= DO <WHILE CLAUSE> ;
       DO;
          XSET"12";
          FIXL(MPP1)=0;
          TEMP=PTR(MPP1);
          HALMAT_POP(XCTST,1,0,INX(TEMP));
          GO TO EMIT_WHILE;
       END;
    # <DO GROUP HEAD>::= DO CASE  <ARITH EXP> ;
       DO;
          FIXV(MP),FIXL(MP)=0;
    CASE_HEAD:
          XSET"14";
          TEMP2=PTR(MP+2);
          if UNARRAYED_INTEGER(MP+2): ERROR(d.CLASS_GC,1);
          HALMAT_POP(XDCAS,2,0,FIXL(MP));
          EMIT_PUSH_DO(2,4,0,MP-1);
          HALMAT_PIP(LOC_P(TEMP2),PSEUDO_FORM(TEMP2),0,0);
          PTR_TOP=TEMP2-1;
          CHECK_IMPLICIT_T();
          if FIXL(MP): DO;
             OUTPUT_WRITER(LAST_WRITE,STACK_PTR(SP)-1);
             LAST_WRITE=STACK_PTR(SP);
             INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
             EMIT_SMRK();
             SRN_UPDATE();
             XSET"100";
             OUTPUT_WRITER(LAST_WRITE,LAST_WRITE);
             INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
          END;
          ELSE DO;
             if STMT_END_PTR > -1:
                OUTPUT_WRITER(LAST_WRITE, STACK_PTR(SP));
             EMIT_SMRK();
             INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
             GO TO SET_CASE;
          END;
       END;
    #  <DO GROUP HEAD>  ::=  <CASE ELSE>  <STATEMENT>
       DO;
          UNBRANCHABLE(SP,6);
          FIXV(MP)=0;
          INDENT_LEVEL=INDENT_LEVEL-INDENT_INCR;
    SET_CASE:
          CASE_LEVEL = CASE_LEVEL +1;
          if CASE_LEVEL <= CASE_LEVEL_LIM:
             CASE_STACK(CASE_LEVEL)=0;
          NEST_LEVEL = NEST_LEVEL + 1;
          GO TO EMIT_CASE;
       END;
    # <DO GROUP HEAD>::= <DO GROUP HEAD> <ANY STATEMENT>
       DO;
          FIXV(MP)=1;
          if (DO_INX(DO_LEVEL)&"7F")=2: if PTR(SP): DO;
    EMIT_CASE:
             INFORMATION=INFORMATION+'CASE ';
             if CASE_LEVEL <= CASE_LEVEL_LIM:
                CASE_STACK(CASE_LEVEL)=CASE_STACK(CASE_LEVEL)+1;
             TEMP = 0;
             DO WHILE (TEMP<CASE_LEVEL)&(TEMP<CASE_LEVEL_LIM);
                INFORMATION=INFORMATION+CASE_STACK(TEMP)+PERIOD;
                TEMP = TEMP + 1;
             END;
             INFORMATION=INFORMATION+CASE_STACK(TEMP);
             HALMAT_POP(XCLBL,2,XCO_N,0);
             HALMAT_PIP(DO_LOC(DO_LEVEL),XINL,0,0);
             HALMAT_PIP(FL_NO,XINL,0,0);
             FL_NO=FL_NO+2;
             FIXV(MP)=LAST_POP#;
          END;
       END;
    #  <DO GROUP HEAD>  ::=  <DO GROUP HEAD>  <TEMPORARY STMT>
       DO;
          if (DO_INX(DO_LEVEL)&"7F")=2: ERROR(d.CLASS_D,10);
          ELSE if FIXV(MP): DO;
             ERROR(d.CLASS_D,7);
             FIXV(MP)=0;
          END;
          GO TO EMIT_NULL;
       END;
    #  <CASE ELSE>  ::=  DO CASE <ARITH EXP> ; ELSE
       DO;
          FIXL(MP)=1;
          GO TO CASE_HEAD;
       END;
    
    # <WHILE KEY>::= WHILE
       DO;
          TEMP=0;
    WHILE_KEY:
          if PARSE_STACK(MP-1)=DO_TOKEN: DO;
             HALMAT_POP(XDTST,1,XCO_N,TEMP);
             EMIT_PUSH_DO(3,3,0,MP-2);
          END;
          FIXL(MP)=TEMP;
       END;
    # <WHILE KEY>::= UNTIL
       DO;
          TEMP=1;
          GO TO WHILE_KEY;
       END;
    # <WHILE CLAUSE>::=<WHILE KEY> <BIT EXP>
       DO;
          if CHECK_ARRAYNESS: ERROR(d.CLASS_GC,2);
        if PSEUDO_LENGTH(PTR(SP))>1: ERROR(d.CLASS_GB,1,'WHILE/UNTIL');
          HALMAT_TUPLE(XBTRU,0,SP,0,0);
          SETUP_VAC(SP,BIT_TYPE);
    DO_FLOWSET:
          INX(PTR(SP))=FIXL(MP);
          PTR(MP)=PTR(SP);
       END;
    # <WHILE CLAUSE>::= <WHILE KEY> <RELATIONAL EXP>
       GO TO DO_FLOWSET;
    # <FOR LIST>::= <FOR KEY>  <ARITH EXP><ITERATION CONTROL>
       DO;
          if UNARRAYED_SIMPLE(SP-1): ERROR(d.CLASS_GC,3);
          HALMAT_POP(XDFOR,TEMP2+3,XCO_N,0);
          EMIT_PUSH_DO(1,5,PSEUDO_TYPE(PTR(SP))=INT_TYPE,MP-2,FIXL(MP));
          TEMP=PTR(MP);
          DO WHILE TEMP <= PTR_TOP;
             HALMAT_PIP(LOC_P(TEMP),PSEUDO_FORM(TEMP),0,0);
             TEMP=TEMP+1;
          END;
          FIXV(MP)=LAST_POP#;
          PTR_TOP=PTR(MP)-1;
          PTR(MP) = TEMP2 | FIXF(MP);  # RECORD DO TYPE AND WHETHER
                                    LOOP VAR IS TEMPORARY
       END;
    # <FOR LIST> = <FOR KEY>  <ITERATION BODY>
       DO;
          HALMAT_FIX_POPTAG(FIXV(SP),1);
          PTR_TOP=PTR(MP)-1;
          PTR(MP) = FIXF(MP);  # RECORD WHETHER LOOP VAR IS TEMPORARY
       END;
    
    # <ITERATION BODY>::= <ARITH EXP>
       DO;
          TEMP=PTR(MP-1);   #<FOR KEY> PTR
          HALMAT_POP(XDFOR,2,XCO_N,0);
          EMIT_PUSH_DO(1,5,0,MP-3,FIXL(MP-1));
          HALMAT_PIP(LOC_P(TEMP),PSEUDO_FORM(TEMP),0,0);
          FIXV(MP-1)=LAST_POP#; # IN <FOR KEY> STACK ENTRY
          GO TO DO_DISCRETE;
       END;
    # <ITERATION BODY>::= <ITERATION BODY>,<ARITH EXP>
       DO;
    DO_DISCRETE:
          if UNARRAYED_SIMPLE(SP): ERROR(d.CLASS_GC,3);
          PTR_TOP=PTR(SP)-1;
          HALMAT_TUPLE(XAFOR,XCO_N,SP,0,0);
          FL_NO=FL_NO+1;
          FIXV(MP)=LAST_POP#;
       END;
    # <ITERATION CONTROL>::= TO <ARITH EXP>
       DO;
          if UNARRAYED_SIMPLE(MPP1): ERROR(d.CLASS_GC,3);
          PTR(MP)=PTR(MPP1);
          TEMP2=1;
       END;
    # <ITERATION CONTROL>::= TO <ARITH EXP> BY <ARITH EXP>
       DO;
          TEMP2=UNARRAYED_SIMPLE(SP);
          if UNARRAYED_SIMPLE(MPP1)|TEMP2:
             ERROR(d.CLASS_GC,3);
          PTR(MP)=PTR(MPP1);
          TEMP2=2;
       END;
    # <FOR KEY>::= FOR <ARITH VAR> =
       DO;
          CHECK_ASSIGN_CONTEXT(MPP1);
          if UNARRAYED_SIMPLE(MPP1): ERROR(d.CLASS_GV,1);
          PTR(MP)=PTR(MPP1);
          FIXL(MP), FIXF(MP) = 0;  # NO DO CHAIN EXISTS
       END;
    #  <FOR KEY>  ::=  FOR TEMPORARY  <IDENTIFIER>  =
       DO;
          ID_LOC=FIXL(MP+2);
          PTR(MP)=PUSH_INDIRECT(1);
          LOC_P(PTR_TOP)=ID_LOC;
          PSEUDO_FORM(PTR_TOP)=XSYT;
          PSEUDO_TYPE(PTR_TOP),SYT_TYPE(ID_LOC)=INT_TYPE;
          TEMP=DEFAULT_ATTR&SD_FLAGS;
          SYT_FLAGS(ID_LOC)=SYT_FLAGS(ID_LOC)|TEMP;
          FIXL(MP),DO_CHAIN=ID_LOC;
          FIXF(MP) = 8;  # DO CHAIN EXISTS FOR CURRENT DO
          CONTEXT=0;
          FACTORING = TRUE;
          if SIMULATING: STAB_VAR(MP);
          SET_XREF(ID_LOC,XREF_ASSIGN);
       END;
    # <ENDING>::= END
       DO;
          # ON END STATEMENT, REPLACE THE CURRENT SCOPE WITH
          # THE STATEMENT NUMBER OF THE DO.  SET A FLAG HERE TO BE USED
          # IN OUTPUT_WRITER IF THE END ISN'T IN A NON-EXPANDED
          # REPLACE MACRO.
          if ((GRAMMAR_FLAGS(STACK_PTR(SP))&PRINT_FLAG)!=0):
             END_FLAG = TRUE;
          # USED TO ALIGN ELSE CORRECTLY
          if (DO_INX(DO_LEVEL) = 0) & IFDO_FLAG(DO_LEVEL):
             MOVE_ELSE = FALSE;
          SAVE_DO_LEVEL = DO_LEVEL;
       END;
    # <ENDING>::= END <LABEL>
       DO;
          # ON END STATEMENT, REPLACE THE CURRENT SCOPE WITH
          # THE STATEMENT NUMBER OF THE DO.  SET A FLAG HERE TO BE USED
          # IN OUTPUT_WRITER IF THE END ISN'T IN A NON-EXPANDED
          # REPLACE MACRO.
          if ((GRAMMAR_FLAGS(STACK_PTR(SP))&PRINT_FLAG)!=0):
             END_FLAG = TRUE;
          # USED TO ALIGN ELSE CORRECTLY
          if (DO_INX(DO_LEVEL) = 0) & IFDO_FLAG(DO_LEVEL):
             MOVE_ELSE = FALSE;
          SAVE_DO_LEVEL = DO_LEVEL;
          TEMP=MP-1;
          DO WHILE PARSE_STACK(TEMP)=LABEL_DEFINITION;
             TEMP=TEMP-1;
          END;
          TEMP=TEMP-1;
          DO WHILE PARSE_STACK(TEMP)=LABEL_DEFINITION;
             if FIXL(TEMP)=FIXL(SP): DO;
                # CREATE AN ASSIGN XREF ENTRY FOR A LABEL THAT
                # IS USED ON AN END STATEMENT SO THE "NOT
                # REFERENCED" MESSAGE WILL NOT BE PRINTED IN
                # THE CROSS REFERENCE TABLE. THIS XREF ENTRY
                # WILL BE REMOVED IN SYT_DUMP SO IT DOES NOT
                # SHOW UP IN THE SDF.
                SET_XREF(FIXL(SP),XREF_ASSIGN);
                GO TO ENDING_DONE;
             END;
             TEMP=TEMP-1;
          END;
          ERROR(d.CLASS_GL,1);
    ENDING_DONE:
       END;
    # <ENDING>::= <LABEL DEFINITION> <ENDING>
      DO;
          # USED TO ALIGN ELSE CORRECTLY
          if (DO_INX(DO_LEVEL) = 0) & IFDO_FLAG(DO_LEVEL):
             MOVE_ELSE = FALSE;
          SAVE_DO_LEVEL = DO_LEVEL;
          SET_LABEL_TYPE(FIXL(MP),STMT_LABEL);
      END;
    
    #    <ON PHRASE>  ::= ON ERROR  <SUBSCRIPT>
       DO;
          ERROR_SUB(1);
          HALMAT_POP(XERON,2,0,0);
          HALMAT_PIP(LOC_P(PTR(MP+2)),XIMD,FIXV(MP)&"3F",0);
          HALMAT_PIP(FL_NO,XINL,0,0);
          FIXL(MP)=FL_NO;
          FL_NO=FL_NO+1;
          PTR_TOP=PTR(SP)-1;
          if INX(PTR(SP)) = 0:
             SUB_END_PTR = STACK_PTR(MP) + 1;  # NULL SUBSCRIPT
          OUTPUT_WRITER(LAST_WRITE, SUB_END_PTR);
          INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
          EMIT_SMRK();
          XSET"400";
       END;
    #  <ON CLAUSE>  ::=  ON ERROR <SUBSCRIPT>  SYSTEM
       DO;
          FIXL(MP)=1;
    ON_ERROR_ACTION:
          ERROR_SUB(1);
          PTR(MP),PTR_TOP=PTR(MP+2);
       END;
    #  <ON CLAUSE>  ::=  ON ERROR <SUBSCRIPT> IGNORE
       DO;
          FIXL(MP)=2;
          GO TO ON_ERROR_ACTION;
       END;
    #  <SIGNAL CLAUSE>  ::=  SET <EVENT VAR>
       DO;
          TEMP=1;
    SIGNAL_EMIT:
          if INLINE_LEVEL>0: ERROR(d.CLASS_PP,6);
          if TEMP>0: if (SYT_FLAGS(FIXL(MPP1))&LATCHED_FLAG)=0:
             ERROR(d.CLASS_RT,10);
          SET_XREF_RORS(MPP1,0,XREF_ASSIGN);
          if CHECK_ARRAYNESS: ERROR(d.CLASS_RT,8);
          if SIMULATING: STAB_VAR(MPP1);
          PTR(MP)=PTR(MPP1);
          INX(PTR(MP))=TEMP;
       END;
    #  <SIGNAL CLAUSE>  ::=  RESET <EVENT VAR>
       DO;
          TEMP=2;
          GO TO SIGNAL_EMIT;
       END;
    #  <SIGNAL CLAUSE>  ::= SIGNAL <EVENT VAR>
       DO;
          TEMP=0;
          GO TO SIGNAL_EMIT;
       END;
    
    #  <FILE EXP>  ::=  <FILE HEAD>  ,  <ARITH EXP>  )
       DO;
          if FIXV(MP)>DEVICE_LIMIT: DO;
             ERROR(d.CLASS_TD,1,''+DEVICE_LIMIT);
             FIXV(MP)=0;
          END;
          if UNARRAYED_INTEGER(SP-1): ERROR(d.CLASS_TD,2);
          RESET_ARRAYNESS();
          PTR(MP)=PTR(SP-1);
          if UPDATE_BLOCK_LEVEL>0: ERROR(d.CLASS_UT,1);
          XSET"10";
       END;
    #  <FILE HEAD>  ::=  FILE  (  <NUMBER>
       DO;
          FIXV(MP)=FIXV(MP+2);
          if INLINE_LEVEL>0: ERROR(d.CLASS_PP,5);
          SAVE_ARRAYNESS();
       END;
    #  <CALL KEY>  ::=  CALL  <LABEL VAR>
       DO;
          I = FIXL(MPP1);
          if SYT_TYPE(I) = PROC_LABEL: if SYT_LINK1(I) < 0:
            if DO_LEVEL<(-SYT_LINK1(I)): ERROR(d.CLASS_PL,8,VAR(MPP1));
          if SYT_LINK1(I) = 0: SYT_LINK1(I) = STMT_NUM;
          DO WHILE SYT_TYPE(I) = IND_CALL_LAB;
             I = SYT_PTR(I);
          END;
          if SYT_TYPE(I)!=PROC_LABEL: ERROR(d.CLASS_DT,3,VAR(MPP1));
          if CHECK_ARRAYNESS: ERROR(d.CLASS_PL,7,VAR(MPP1));
          if (SYT_FLAGS(I) & ACCESS_FLAG) != 0:
             ERROR(d.CLASS_PS, 6, VAR(MPP1));
          XSET"2";
          FCN_ARG=0;
          PTR(MP)=PTR(MPP1);
          SET_XREF_RORS(SP,"6000");
          if INLINE_LEVEL>0: ERROR(d.CLASS_PP,7);
       END;
    
    #  <CALL LIST> ::= <LIST EXP>
       SETUP_CALL_ARG();
    
    #  <CALL LIST> ::= <CALL LIST> , <LIST EXP>
       SETUP_CALL_ARG();
    
    #  <CALL ASSIGN LIST> ::= <VARIABLE>
       if INLINE_LEVEL=0: DO;
    ASSIGN_ARG:
          FCN_ARG=FCN_ARG+1;
          HALMAT_TUPLE(XXXAR,XCO_N,SP,0,0);
          HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,PSEUDO_TYPE(PTR(SP))|
             SHL(NAME_PSEUDOS,7),1);
          if NAME_PSEUDOS: DO;
             KILL_NAME(SP);
             if EXT_P(PTR(SP))!=0: ERROR(d.CLASS_FD,7);
          END;
          CHECK_ARRAYNESS();
          l.H1=VAL_P(PTR(SP));
          if SHR(l.H1,7): ERROR(d.CLASS_FS,1);
          if SHR(l.H1,4): ERROR(d.CLASS_SV,1,VAR(SP));
          if (l.H1&"6")="2": ERROR(d.CLASS_FS,2,VAR(SP));
          PTR_TOP=PTR(SP)-1;
       END;
    
    #  <CALL ASSIGN LIST> ::= <CALL ASSIGN LIST> , <VARIABLE>
       GO TO ASSIGN_ARG;
    
    #  <EXPRESSION> ::= <ARITH EXP>
       DO;
         EXT_P(PTR(MP))=0;
         # if THE DECLARED VALUE IS A DOUBLE CONSTANT SCALAR OR
         # INTEGER,: SET LIT1 EQUAL TO 5.
         if (TYPE=SCALAR_TYPE) | (FACTORED_TYPE=SCALAR_TYPE) |
            (TYPE=INT_TYPE) | (FACTORED_TYPE=INT_TYPE) |
            ((TYPE=0) & (FACTORED_TYPE=0))
        :
           if ((ATTRIBUTES & DOUBLE_FLAG) != 0) &
              ((FIXV(MP-1) & CONSTANT_FLAG) != 0)
          :
             LIT1(GET_LITERAL(LOC_P(PTR(MP)))) = 5;
       END;
    #  <EXPRESSION> ::= <BIT EXP>
       EXT_P(PTR(MP))=0;
    #  <EXPRESSION> ::= <CHAR EXP>
       EXT_P(PTR(MP))=0;
    #  <EXPRESSION>  ::=  <STRUCTURE EXP>
       EXT_P(PTR(MP))=0;
    #  <EXPRESSION>  ::=  <NAME EXP>
       ;
    #  <STRUCTURE EXP>  ::=  <STRUCTURE VAR>
       SET_XREF_RORS(MP);
    #  <STRUCTURE EXP>  ::=  <MODIFIED STRUCT FUNC>
       SETUP_NO_ARG_FCN();
    #  <STRUCTURE EXP>  ::=  <STRUC INLINE DEF> <BLOCK BODY> <CLOSING> ;
       GO TO INLINE_SCOPE;
    #  <STRUCTURE EXP>  ::=  <STRUCT FUNC HEAD>  (  <CALL LIST>  )
       END_ANY_FCN();
    #  <STRUCT FUNC HEAD>  ::=  <STRUCT FUNC>
       if START_NORMAL_FCN: ASSOCIATE();
    # <LIST EXP> ::= <EXPRESSION>
       if FCN_MODE(FCN_LV)!=1: INX(PTR(MP))=0;
    #  <LIST EXP>  ::=  <ARITH EXP>  #  <EXPRESSION>
       DO;
          if FCN_MODE(FCN_LV)=2: DO;
             if PSEUDO_FORM(PTR(MP))!=XLIT: TEMP=0;
             ELSE TEMP=MAKE_FIXED_LIT(LOC_P(PTR(MP)));
             if (TEMP<1)|(TEMP>LIST_EXP_LIM): DO;
                TEMP=1;
                ERROR(d.CLASS_EL,2);
             END;
             INX(PTR(MP))=TEMP;
          END;
          ELSE DO;
             ERROR(d.CLASS_EL,1);
             if FCN_MODE(FCN_LV)!=1: INX(PTR(MP))=1;
             ELSE INX(PTR(MP))=INX(PTR(SP));
          END;
          TEMP=PTR(SP);
          PTR_TOP=PTR(MP);
          LOC_P(PTR_TOP)=LOC_P(TEMP);
          PSEUDO_FORM(PTR_TOP)=PSEUDO_FORM(TEMP);
          PSEUDO_TYPE(PTR_TOP)=PSEUDO_TYPE(TEMP);
          PSEUDO_LENGTH(PTR_TOP)=PSEUDO_LENGTH(TEMP);
       END;
    #  <VARIABLE> ::= <ARITH VAR>
       if ^DELAY_CONTEXT_CHECK: CHECK_ASSIGN_CONTEXT(MP);
    #  <VARIABLE> ::= <STRUCTURE VAR>
       if ^DELAY_CONTEXT_CHECK: CHECK_ASSIGN_CONTEXT(MP);
    #  <VARIABLE> ::= <BIT VAR>
       if ^DELAY_CONTEXT_CHECK: CHECK_ASSIGN_CONTEXT(MP);
    #  <VARIABLE  ::=  <EVENT VAR>
       DO;
        if CONTEXT>0: if ^NAME_PSEUDOS: PSEUDO_TYPE(PTR(MP))=BIT_TYPE;
          if ^DELAY_CONTEXT_CHECK: CHECK_ASSIGN_CONTEXT(MP);
          PSEUDO_LENGTH(PTR(MP))=1;
       END;
    #  <VARIABLE>  ::=  <SUBBIT HEAD>  <VARIABLE>  )
       DO;
          if CONTEXT=0: DO;
             if SHR(VAL_P(PTR(MPP1)),7): ERROR(d.CLASS_QX,7);
             TEMP=1;
          END;
          ELSE TEMP=0;
          END_SUBBIT_FCN(TEMP);
          SET_BI_XREF(SBIT_NDX);
          VAL_P(PTR(MP))=VAL_P(PTR(MPP1))|"80";
       END;
    #  <VARIABLE> ::= <CHAR VAR>
       if ^DELAY_CONTEXT_CHECK: CHECK_ASSIGN_CONTEXT(MP);
    #  <VARIABLE>  ::=  <NAME KEY>  (  <NAME VAR>  )
       DO;
          if TEMP_SYN!=2: if CONTEXT=0: TEMP_SYN=3;
          CHECK_NAMING(TEMP_SYN,MP+2);
          DELAY_CONTEXT_CHECK=FALSE;
       END;
    #  <NAME VAR>  ::=  <VARIABLE>
       DO;
          l.H1=VAL_P(PTR(MP));
          ARRAYNESS_FLAG=0;
          if SHR(l.H1,11): ERROR(d.CLASS_EN,1);
          VAL_P(PTR(MP))=l.H1|"800";
          if SHR(l.H1,7): ERROR(d.CLASS_EN,2);
          if (l.H1&"880")!=0: TEMP_SYN=2;
          ELSE TEMP_SYN=1;
       END;
    #  <NAME VAR>  ::=  <LABEL VAR>
       DO;
          l.H1=SYT_TYPE(FIXL(MP));
          if l.H1=TASK_LABEL|l.H1=PROG_LABEL: GO TO OK_LABELS;
          ELSE if VAR(MP-2) = 'NAME':
               ERROR(d.CLASS_EN,4,VAR(MP));
    OK_LABELS:
          TEMP_SYN=0;
       END;
    #  <NAME VAR>  ::=  <MODIFIED ARITH FUNC>
       TEMP_SYN=0;
    #  <NAME VAR>  ::=  <MODIFIED BIT FUNC>
       TEMP_SYN=0;
    #  <NAME VAR>  ::=  <MODIFIED CHAR FUNC>
       TEMP_SYN=0;
    #  <NAME VAR>  ::=  <MODIFIED STRUCT FUNC>
       TEMP_SYN=0;
    #  <NAME EXP>  ::=  <NAME KEY>  (  <NAME VAR>  )
       DO;
          CHECK_NAMING(TEMP_SYN,MP+2);
          DELAY_CONTEXT_CHECK=FALSE;
       END;
    #  <NAME EXP>  ::=  NULL
       DO;
    FIX_NULL:
          PTR(MP)=PUSH_INDIRECT(1);
          LOC_P(PTR_TOP)=0;
          PSEUDO_FORM(PTR_TOP)=XIMD;
          NAME_PSEUDOS=TRUE;
          EXT_P(PTR_TOP)=0;
          VAL_P(PTR_TOP)="500";
       END;
    #  <NAME EXP>  ::=  <NAME KEY> ( NULL )
       DO;
          NAMING=FALSE;
          DELAY_CONTEXT_CHECK=FALSE;
          GO TO FIX_NULL;
       END;
    #  <NAME KEY>  ::=  NAME
       DO;
          NAMING,NAME_PSEUDOS=TRUE;
          DELAY_CONTEXT_CHECK=TRUE;
          ARRAYNESS_FLAG=0;
       END;
    #  <LABEL VAR>  ::=  <PREFIX>  <LABEL>  <SUBSCRIPT>
       GO TO FUNC_IDS;
    #  <MODIFIED ARITH FUNC>  ::=  <PREFIX>  <NO ARG ARITH FUNC> <SUBSCRIPT>
       GO TO FUNC_IDS;
    #  <MODIFIED BIT FUNC>  ::=  <PREFIX>  <NO ARG BIT FUNC>  <SUBSCRIPT>
       GO TO FUNC_IDS;
    #  <MODIFIED CHAR FUNC>  ::=  <PREFIX> <NO ARG CHAR FUNC>  <SUBSCRIPT>
       GO TO FUNC_IDS;
    #  <MODIFIED STRUCT FUNC> ::= <PREFIX> <NO ARG STRUCT FUNC> <SUBSCRIPT>
       DO;
    FUNC_IDS:
          if FIXL(MPP1)>SYT_MAX: DO;
             if FIXL(SP): ERROR(d.CLASS_FT,8,VAR(MPP1));
             TEMP_SYN=PSEUDO_FORM(PTR(SP));
             PTR_TOP=PTR(MP);
             FIXL(MP)=FIXL(MPP1);
             VAR(MP)=VAR(MPP1);
          END;
          ELSE DO;
             FIXL(SP)=FIXL(SP)|2;
             GO TO MOST_IDS;
          END;
       END;
    #  <STRUCTURE VAR>  ::=  <QUAL STRUCT>  <SUBSCRIPT>
       DO;
          l.H1=PTR(MP);
          GO TO STRUC_IDS;
       END;
    #  <ARITH VAR>  ::=  <PREFIX>  <ARITH ID>  <SUBSCRIPT>
       GO TO MOST_IDS;
    #  <CHAR VAR>  ::=  <PREFIX>  <CHAR ID>  <SUBSCRIPT>
       GO TO MOST_IDS;
    #  <BIT VAR>  ::=  <PREFIX>  <BIT ID>  <SUBSCRIPT>
       GO TO MOST_IDS;
    #  <EVENT VAR>  ::=  <PREFIX>  (EVENT ID>  <SUBSCRIPT>
       DO;
    MOST_IDS:
          l.H1=PTR(MP);
          PSEUDO_TYPE(l.H1)=SYT_TYPE(FIXL(MPP1));
          PSEUDO_LENGTH(l.H1)=VAR_LENGTH(FIXL(MPP1));
          if FIXV(MP)=0: DO;
             STACK_PTR(MP)=STACK_PTR(MPP1);
             VAR(MP)=VAR(MPP1);
             if FIXV(MPP1)=0: LOC_P(l.H1)=FIXL(MPP1);
             ELSE FIXV(MP),LOC_P(l.H1)=FIXV(MPP1);
             PSEUDO_FORM(l.H1)=XSYT;
          END;
          ELSE DO;
             VAR(MP)=VAR(MP)+PERIOD+VAR(MPP1);
             TOKEN_FLAGS(EXT_P(l.H1))=TOKEN_FLAGS(EXT_P(l.H1))|"20";
             I = FIXL(MPP1);
    UNQ_TEST1:
             DO WHILE I > 0;
                I = SYT_LINK2(I);
             END;
             I = -I;
             if I = 0: DO;
                ERROR (d.CLASS_IS, 2, VAR(MPP1));
                GO TO UNQ_TEST2;
             END;
             if I != FIXL(MP): GO TO UNQ_TEST1;
    UNQ_TEST2:
          END;
          FIXL(MP)=FIXL(MPP1);
          EXT_P(l.H1)=STACK_PTR(MPP1);
    STRUC_IDS:
          NAME_BIT=SHR(VAL_P(l.H1),1)&"80";
          TEMP_SYN=INX(l.H1);
          TEMP3=LOC_P(l.H1);
          if ATTACH_SUBSCRIPT: DO;
             HALMAT_TUPLE(XTSUB,0,MP,0,MAJ_STRUC|NAME_BIT);
             INX(l.H1)=NEXT_ATOMp-1;
             HALMAT_FIX_PIP#(LAST_POP#,EMIT_SUBSCRIPT("8"));
             SETUP_VAC(MP,PSEUDO_TYPE(l.H1));
             VAL_P(l.H1)=VAL_P(l.H1)|"20";
          END;
          PTR_TOP=l.H1;  # BASH DOWN STACKS
          if FIXV(MP)>0: DO;
             HALMAT_TUPLE(XEXTN,0,MP,0,0);
             TEMP=l.H1;
             if (SYT_FLAGS(TEMP3) & NAME_FLAG) != 0:
                VAL_P(l.H1) = VAL_P(l.H1) | "4000";
             l.H2 = FALSE;
    
             l.PRl.PREV_LIVES_REMOTESYT_FLAGS(TEMP3)&REMOTE_FLAG)!=0;
             l.PREV_POINTS=(SYT_FLAGS(TEMP3)&NAME_FLAG)!= 0;
             l.PREV_REMOTE=l.PREV_LIVES_REMOTE;
    
             DO WHILE TEMP_SYN!=0;
                TEMP=TEMP+1;
                TEMP3=LOC_P(TEMP);
                HALMAT_PIP(TEMP3,XSYT,0,0);
                l.H2=l.H2|(SYT_FLAGS(TEMP3)&NAME_FLAG)!=0;
    
                # KEEP TRACK OF THE REMOTENESS -----------------
                # OF THE NODE BEING PROCESSED
                l.PREV_REMOTE = ((SYT_FLAGS(TEMP3)&NAME_FLAG) > 0);
                l.REMOTE_SET=((SYT_FLAGS(TEMP3)&REMOTE_FLAG)>0);
                if (l.REMOTE_SET & ^l.PREV_REMOTE)
                   | (l.PREV_POINTS & l.PREV_REMOTE)
                   | (l.PREV_LIVES_REMOTE & ^l.PREV_POINTS):
                   l.CURRENT_LIVES_REMOTE = TRUE;
                ELSE
                   l.CURRENT_LIVES_REMOTE = FALSE;
                l.PREV_LIVES_REMOTE = l.CURRENT_LIVES_REMOTE;
                l.PREV_POINTS = l.PREV_REMOTE;
                l.PREV_REMOTE = l.REMOTE_SET;
    
                TEMP_SYN=INX(TEMP);
             END;
             if l.H2: VAL_P(l.H1) = VAL_P(l.H1) | "4000";
    
             # SET FLAG IN VAL_P TO INDICATE
             # THAT TERMINAL LIVES REMOTE
             if (l.PREV_POINTS & l.PREV_REMOTE)
                | (PREV_LIVES_REMOTE & ^ l.PREV_POINTS)
            :
                VAL_P(l.H1) = VAL_P(l.H1) | "8000";
    
             PTR_TOP=TEMP;  # WAIT - DONT LOSE EXTN TILL XREF DONE
             if VAR_LENGTH(TEMP3)=FIXL(MP): DO;
                if TEMP=l.H1: VAL_P(l.H1)=VAL_P(l.H1)|"4";
                VAL_P(l.H1)=VAL_P(l.H1)|"1000";
                HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,0,1);
                if (SYT_FLAGS(TEMP3)&NAME_FLAG) !=0:
                   VAL_P(l.H1)=VAL_P(l.H1)|"200";
             END;
             HALMAT_PIP(FIXL(MP),XSYT,0,1);
             l.H2 = l.H2 | (SYT_FLAGS(FIXL(MP)) & NAME_FLAG) != 0;
             HALMAT_FIX_PIP#(LAST_POP#, TEMP - l.H1 + 2);
             HALMAT_FIX_POPTAG(LAST_POP#, l.H2);
             LOC_P(l.H1),l.H2=LAST_POP#;
             PSEUDO_FORM(l.H1)=XXPT;
          END;
          ELSE l.H2=-1;
          if PSEUDO_FORM(INX)>0: DO;
             if FIXL(SP)>=2: DO;
                if DELAY_CONTEXT_CHECK: DO;
                   ERROR(d.CLASS_EN,14);
                   PSEUDO_FORM(INX)=0;
                END;
                ELSE TEMP_SYN=SP;
    # THIS ASSUMES THAT PTR(SP) AND THE INDIRECT STACKS
    # ARE NOT OVERWRITTEN UNTIL AFTER REACHING THE
    # <PRIMARY>::=<MODIFIED ARITH FUNC> PRODUCTION,
    # WHEN THAT PARSING ROUTE IS TAKEN
             END;
             ELSE PREC_SCALE(SP,PSEUDO_TYPE(l.H1));
             if PSEUDO_FORM(INX)>0: VAL_P(l.H1)=VAL_P(l.H1)|"40";
          END;
          ELSE if IND_LINK>0: DO;
             HALMAT_TUPLE(XDSUB,0,MP,0,PSEUDO_TYPE(l.H1)|NAME_BIT);
             INX(l.H1)=NEXT_ATOM#-1;
             VAL_P(l.H1)=VAL_P(l.H1)|"20";
             HALMAT_FIX_PIP#(LAST_POP#,EMIT_SUBSCRIPT("0"));
             SETUP_VAC(MP,PSEUDO_TYPE(l.H1));
          END;
          FIXF(MP)=PTR_TOP;  # RECORD WHERE TOP IS IN CASE CHANGED
          ASSOCIATE()(l.H2);
       END;
    #  <QUAL STRUCT>  ::=  <STRUCTURE ID>
       DO;
          PTR(MP)=PUSH_INDIRECT(1);
          PSEUDO_TYPE(PTR_TOP)=MAJ_STRUC;
          EXT_P(PTR_TOP)=STACK_PTR(SP);
          if FIXV(MP)=0: DO;
             FIXV(MP)=FIXL(MP);
             FIXL(MP)=VAR_LENGTH(FIXL(MP));
             SET_XREF(FIXL(MP), XREF_REF);
          END;
          LOC_P(PTR_TOP)=FIXV(MP);
          INX(PTR_TOP)=0;
          VAL_P(PTR_TOP)=SHL(NAMING,8);
          PSEUDO_FORM(PTR_TOP)=XSYT;
       END;
    #  <QUAL STRUCT>  ::=  <QUAL STRUCT>  .  <STRUCTURE ID>
       DO;
          TEMP=VAR_LENGTH(FIXL(SP));
          if TEMP>0: DO;
             PUSH_INDIRECT(1);
             LOC_P(PTR_TOP)=FIXL(SP);
             INX(PTR_TOP-1)=1;
             INX(PTR_TOP)=0;
             SET_XREF(TEMP, XREF_REF);
             FIXL(MP)=TEMP;
          END;
          ELSE FIXL(MP)=FIXL(SP);
          VAR(MP)=VAR(MP)+PERIOD+VAR(SP);
          TOKEN_FLAGS(STACK_PTR(MPP1)) = TOKEN_FLAGS(STACK_PTR(MPP1)) | "20";
          TOKEN_FLAGS(EXT_P(PTR(MP)))=TOKEN_FLAGS(EXT_P(PTR(MP)))|"20";
          EXT_P(PTR(MP))=STACK_PTR(SP);
       END;
    #  <PREFIX>  ::=  <EMPTY>
       DO;
          PTR(MP)=PUSH_INDIRECT(1);
          VAL_P(PTR_TOP)=SHL(NAMING,8);
          INX(PTR_TOP)=0;
          FIXL(MP),FIXV(MP)=0;
       END;
    #  <PREFIX>  ::=  <QUAL STRUCT>  .
       DO;
          TOKEN_FLAGS(STACK_PTR(SP))=TOKEN_FLAGS(STACK_PTR(SP))|"20";
       END;
    # <SUBBIT HEAD>::= <SUBBIT KEY> <SUBSCRIPT>(
       DO;
          PTR(MP),TEMP=PTR(MPP1);
          LOC_P(TEMP)=0;
          if INX(TEMP)>0: DO;
        if PSEUDO_LENGTH(TEMP)>=0|VAL_P(TEMP)>=0: ERROR(d.CLASS_QS,12);
             if PSEUDO_FORM(TEMP)!=0: ERROR(d.CLASS_QS,13);
             if INX(TEMP)!=1: DO;
                INX(TEMP)=1;
                ERROR(d.CLASS_QS,11);
             END;
          END;
       END;
    # <SUBBIT KEY> ::= SUBBIT
       DO;
          NAMING=FALSE;
          VAR(MP)='SUBBIT PSEUDO-VARIABLE';
       END;
    #  <SUBSCRIPT> ::= <SUB HEAD> )
       DO;
          SUB_END_PTR = STMT_PTR;
          if SUB_SEEN=0: ERROR(d.CLASS_SP,6);
          GO TO SS_CHEX;
       END;
    #  <SUBSCRIPT>  ::=  <QUALIFIER>
       DO;
          SUB_END_PTR = STMT_PTR;
          SUB_COUNT=0;
          FIXL(MP)=0;
          STRUCTURE_SUB_COUNT=0;
          ARRAY_SUB_COUNT=0;
       END;
    # <SUBSCRIPT> ::= <$> <NUMBER>
       DO;
          SUB_END_PTR = STMT_PTR;
          PTR(SP)=PUSH_INDIRECT(1);
          LOC_P(PTR(SP))=FIXV(SP);
          PSEUDO_FORM(PTR(SP))=XIMD;
          PSEUDO_TYPE(PTR(SP))=INT_TYPE;
    SIMPLE_SUBS:
          INX(PTR(SP))=1;
          VAL_P(PTR(SP))=0;
          SUB_COUNT=1;
          ARRAY_SUB_COUNT=-1;
          STRUCTURE_SUB_COUNT=-1;
          GO TO SS_CHEX;
       END;
    # <SUBSCRIPT> ::= <$> <ARITH VAR>
       DO;
          SUB_END_PTR = STMT_PTR;
          IORS(SP);
          SET_XREF_RORS(MPP1);
          GO TO SIMPLE_SUBS;
       END;
    #  <SUBSCRIPT>  ::=  <EMPTY>
       DO;
          FIXL(MP)=0;
          GO TO SS_FIXUP;
       END;
    #  <SUB START>  ::=  <$> (
       DO;
    SUB_START:
          SUB_COUNT=0;
          STRUCTURE_SUB_COUNT=-1;
          ARRAY_SUB_COUNT=-1;
          SUB_SEEN=0;
       END;
    #  <SUB START>  ::=  <$>  (  @  <PREC SPEC>  ,
       DO;
          PSEUDO_FORM(PTR(MP))=PTR(MP+3);
          GO TO SUB_START;
       END;
    #  <SUB START> ::= <SUB HEAD> ;
       DO;
          if STRUCTURE_SUB_COUNT>=0: ERROR(d.CLASS_SP,1);
          if SUB_SEEN: STRUCTURE_SUB_COUNT=SUB_COUNT;
          ELSE ERROR(d.CLASS_SP,4);
          SUB_SEEN=1;
       END;
    #  <SUB START> ::= <SUB HEAD> :
       DO;
          if STRUCTURE_SUB_COUNT=-1: STRUCTURE_SUB_COUNT=0;
          if ARRAY_SUB_COUNT>=0: ERROR(d.CLASS_SP,2);
          if SUB_SEEN: ARRAY_SUB_COUNT=SUB_COUNT-STRUCTURE_SUB_COUNT;
          ELSE ERROR(d.CLASS_SP,3);
          SUB_SEEN=1;
       END;
    #  <SUB START> ::= <SUB HEAD> ,
       DO ;
          if SUB_SEEN: ;
          ELSE ERROR(d.CLASS_SP,5);
          SUB_SEEN=0;
       END ;
    #  <SUB HEAD> ::= <SUB START>
       if SUB_SEEN: SUB_SEEN=2;
    #  <SUB HEAD> ::= <SUB START> <SUB>
       DO ;
          SUB_SEEN=1;
          SUB_COUNT = SUB_COUNT + 1 ;
       END ;
    
    #  <SUB> ::= <SUB EXP>
       INX(PTR(MP))=1;
    # <SUB> ::= *
       DO;
          PTR(MP)=PUSH_INDIRECT(1);
          INX(PTR(MP))=0;
          PSEUDO_FORM(PTR(MP))=XAST;
          PSEUDO_TYPE(PTR(MP))=0;
          VAL_P(PTR(MP))=0;
          LOC_P(PTR(MP))=0;
       END;
    # <SUB> ::= <SUB RUN HEAD><SYB EXP>
       DO;
          INX(PTR(MP))=2;
          INX(PTR(SP))=2;
       END;
    # <SUB> ::= <ARITH EXP> AT <SUB EXP>
       DO;
          IORS(MP);
          INX(PTR(MP))=3;
          INX(PTR(SP))=3;
          VAL_P(PTR(MP))=0;
          PTR(MPP1)=PTR(SP);
       END;
    # <SUB RUN HEAD> ::= <SUB EXP> TO
       ;
    # <SUB EXP> ::= <ARITH EXP>
       DO;
          IORS(MP);
          VAL_P(PTR(MP))=0;
       END;
    # <SUB EXP> ::= <# EXPRESSION>
       DO;
          if FIXL(MP)=1: DO;
             PTR(MP)=PUSH_INDIRECT(1);
             PSEUDO_FORM(PTR(MP))=0; #  MUSNT FALL IN LIT OR VAC
             PSEUDO_TYPE(PTR(MP))=INT_TYPE;
          END;
          VAL_P(PTR(MP))=FIXL(MP);
       END;
    #  <# EXPRESSION>  ::=  #
       FIXL(MP)=1;
    # <# EXPRESSION> ::= <# EXPRESSION> + <TERM>
       DO;
          TEMP=0;
    SHARP_EXP:
          IORS(SP);
          if FIXL(MP)=1: DO;
             FIXL(MP)=TEMP+2;
             PTR(MP)=PTR(SP);
          END;
          ELSE DO;
             if FIXL(MP)=3: TEMP=1-TEMP;
             ADD_AND_SUBTRACT(TEMP);
          END;
       END;
    # <# EXPRESSION> ::= <# EXPRESSION> -1 <TERM>
       DO;
          TEMP=1;
          GO TO SHARP_EXP;
       END;
    
    # <=1> ::= =
       DO;
          if ARRAYNESS_FLAG: SAVE_ARRAYNESS();
          ARRAYNESS_FLAG=0;
       END;
    
    # <$> ::= $
       DO;
          FIXL(MP)=1;
    SS_FIXUP:
          TEMP=FIXF(MP-1);
          if TEMP>0: DO;
             HALMAT_POP(XXXST,1,XCO_N,TEMP+FCN_LV-1);
             HALMAT_PIP(FIXL(MP-1),XSYT,0,0);
          END;
          NAMING=FALSE;
          if SUBSCRIPT_LEVEL=0: DO;
             if ARRAYNESS_FLAG: SAVE_ARRAYNESS();
             SAVE_ARRAYNESS_FLAG=ARRAYNESS_FLAG;
             ARRAYNESS_FLAG=0;
          END;
          SUBSCRIPT_LEVEL=SUBSCRIPT_LEVEL+FIXL(MP);
          PTR(MP)=PUSH_INDIRECT(1);
          PSEUDO_FORM(PTR_TOP)=0;
          LOC_P(PTR_TOP),INX(PTR_TOP)=0;
       END;
    # <AND> ::= &
    # <AND> ::= AND
    # <OR> ::= |
    # <OR> ::= OR
       ;;;;
    # <NOT> ::= ^
    # <NOT> ::= NOT
          ;;
    
    # <CAT> ::= +
    # <CAT> ::= CAT
          ; ;
    
    #  <QUALIFIER>  ::=  <$>  (  @  <PREC SPEC>  )
          DO;
          PSEUDO_FORM(PTR(MP))=PTR(MP+3);
          GO TO SS_CHEX;
       END;
    #  <QUALIFIER> ::= <$> ( <SCALE HEAD> <ARITH EXP> )
       DO;
          PSEUDO_FORM(PTR(MP))="F0";
          INX(PTR(SP-1))=PTR(SP-2);
          GO TO SS_CHEX;
       END;
    #<QUALIFIER>::=<$>(@<PREC SPEC>,<SCALE HEAD><ARITH EXP>)
       DO;
          PSEUDO_FORM(PTR(MP))="F0"|PTR(MP+3);
          INX(PTR(SP-1))=PTR(SP-2);
          GO TO SS_CHEX;
       END;
    #  <SCALE HEAD>  ::=  @
       PTR(MP)=0;
    #  <SCALE HEAD> ::=  @ @
       PTR(MP)=1;
    # <BIT QUALIFIER> ::= <$(> @ <RADIX> )
       DO;
          if TEMP3=0: TEMP3=2;
          PSEUDO_FORM(PTR(MP))=TEMP3;
    SS_CHEX:
          if SUBSCRIPT_LEVEL > 0:
             SUBSCRIPT_LEVEL=SUBSCRIPT_LEVEL-1;
       END;
    
    #  <RADIX> ::= HEX
       TEMP3=4;
    #  <RADIX> ::= OCT
       TEMP3=3;
    #  <RADIX> ::= BIN
       TEMP3=1;
    # <RADIX> ::= DEC
       TEMP3=0;
    #  <BIT CONST HEAD> ::= <RADIX>
       FIXL(MP)=1;
    #  <BIT CONST HEAD>  ::=  <RADIX>  (  <NUMBER>  )
       DO;
          TOKEN_FLAGS(STACK_PTR(SP)) = TOKEN_FLAGS(STACK_PTR(SP)) | "20";
          if FIXV(MP+2)=0: DO;
             ERROR(d.CLASS_LB,8);
             FIXL(MP)=1;
          END;
          ELSE FIXL(MP)=FIXV(MP+2);
       END;
    #  <BIT CONST> ::= <BIT CONST HEAD> <CHAR STRING>
       DO;
          S = VAR(SP);
          I = 1;
          K = LENGTH(S);
          L=FIXL(MP);
          TEMP_SYN = 0;  #  START WITH VALUE CALC. = O
          DO CASE TEMP3;
             DO;
                C = 'D';
                if L != 1:
                   DO;
                   ERROR(d.CLASS_LB,2);
                   L = 1;
                END;
                TEMP2 = 0;  #  INDICATE START FROM 1ST CHAR
                if SUBSTR(S, TEMP2) > '2147483647': DO;
                   ERROR(d.CLASS_LB,1);
                   GO TO DO_BIT_CONSTANT_END;
                END;
              DO TEMP = TEMP2 TO LENGTH(S) - 1;  #  CHECK FOR CHAR 1 TO 9
                   l.H1=BYTE(S,TEMP);
                   if ^((l.H1>=BYTE('0'))&(l.H1<=BYTE('9'))): DO;
                      ERROR(d.CLASS_LB,4);
                      TEMP_SYN = 0;
                      GO TO DO_BIT_CONSTANT_END;
                   END;
                   ELSE DO;
                      TEMP_SYN = TEMP_SYN * 10;  #  ADD IN NEXT DIGIT
                      TEMP_SYN=TEMP_SYN+(l.H1&"0F");
                   END;
                END;  #  END OF DO FOR
                I = 1;
                DO WHILE SHR(TEMP_SYN, I) != 0;
                   I = I + 1;
                END;
                GO TO DO_BIT_CONSTANT_END;
             END;  #  END OF CASE 0
    # CASE 1, BIN
             DO;
                C = 'B';
                DO TEMP = 0 TO LENGTH(S)-1;  #  CHECK FOR '0' OR '1'
                   l.H1=BYTE(S,TEMP);
                   if ^((l.H1=BYTE('0'))|(l.H1=BYTE('1'))): DO;
                      ERROR(d.CLASS_LB,5);
                      TEMP_SYN = 0;
                      GO TO DO_BIT_CONSTANT_END;
                   END;
                   ELSE DO;
                      TEMP_SYN = SHL(TEMP_SYN,1);  #  ADDIN NEXT VALUE
                      TEMP_SYN=TEMP_SYN|(l.H1&"0F");
                   END;
                END;
             END;  #  END OF CASE 1
    # CASE 2, NO RADIX BASE 2 AT MOMENT
             ;
    # CASE 3, OCT
             DO;
                C = 'O';
               DO TEMP = 0 TO LENGTH(S)-1;  #  CHECK FOR OCTAL CHARACTERS
                   l.H1=BYTE(S,TEMP);
                   if ^((l.H1>=BYTE('0'))&(l.H1<=BYTE('7'))): DO;
                      ERROR(d.CLASS_LB,6);
                      TEMP_SYN = 0;
                      GO TO DO_BIT_CONSTANT_END;
                   END;
                   ELSE DO;
                      TEMP_SYN = SHL(TEMP_SYN,3);  #  ADD IN NEXT VALUE
                      TEMP_SYN=TEMP_SYN|(l.H1&"0F");
                   END;
                END;
             END;  #  END OF CASE 3
    # CASE 4, HEX
             DO;
                C = 'H';
         DO TEMP = 0 TO LENGTH(S)-1;  #  CHECK FOR HEXADECIMAL CHARACTERS
                   l.H1=BYTE(S,TEMP);
                   if ^((l.H1>=BYTE('0'))&(l.H1<=BYTE('9'))): DO;
                      if ^((l.H1>=BYTE('A'))&(l.H1<=BYTE('F'))): DO;
                         ERROR(d.CLASS_LB,7);
                         TEMP_SYN = 0;
                         GO TO DO_BIT_CONSTANT_END;
                      END;
                      ELSE DO;
                 TEMP_SYN = SHL(TEMP_SYN,4);  #  GET NEW VAL WITH NUM.DIG.
                         TEMP_SYN=TEMP_SYN+9+(l.H1&"0F");
                      END;
                   END;
                   ELSE DO;
                      TEMP_SYN = SHL(TEMP_SYN,4);  #  ADD IN NUM. VALUE
                      TEMP_SYN=TEMP_SYN+(l.H1&"0F");
                   END;
                END;
             END;  # OF CASE 4
          END;  #  END OF DO CASE
    #  INCORPORATE REPETITION FACTOR
          TEMP2=TEMP_SYN;
          J=TEMP3*K;
          DO TEMP=2 TO L;
             TEMP_SYN=SHL(TEMP_SYN,J)|TEMP2;
          END;
          I=J*L;
          if I>BIT_LENGTH_LIM: DO;
             if I-TEMP3 < BIT_LENGTH_LIM: DO;
                l.H1 = BYTE(S);
                if l.H1 >= BYTE('A') & l.H1 <= BYTE('F'): l.H1 = l.H1 + 9;
                l.H1 = l.H1 & "0F";
                if SHR(l.H1,BIT_LENGTH_LIM+TEMP3-I) != 0:
                   ERROR(d.CLASS_LB,1);
             END;
             ELSE ERROR(d.CLASS_LB,1);
             I=BIT_LENGTH_LIM;
          END;
    DO_BIT_CONSTANT_END :
          PTR(MP)=PUSH_INDIRECT(1);
          PSEUDO_TYPE(PTR(MP)) = BIT_TYPE;
          PSEUDO_FORM(PTR(MP)) = XLIT;
          PSEUDO_LENGTH(PTR(MP)) = I;
          LOC_P(PTR(MP))=SAVE_LITERAL(2,TEMP_SYN,I);
       END;
    
    # <BIT CONST> ::= TRUE
       DO;
          TEMP_SYN=1;
    DO_BIT_CONST:
          I=1;
          GO TO DO_BIT_CONSTANT_END;
       END;
    # <BIT CONST> ::= FALSE
       DO;
          TEMP_SYN=0;
          GO TO DO_BIT_CONST;
       END;
    # <BIT CONST> ::= ON
       DO;
          TEMP_SYN=1;
          GO TO DO_BIT_CONST;
       END;
    # <BIT CONST> ::= OFF
       DO;
          TEMP_SYN=0;
          GO TO DO_BIT_CONST;
       END;
    #  <CHAR CONST>  ::=  <CHAR STRING>
       DO;
    CHAR_LITS:
          PTR(MP)=PUSH_INDIRECT(1);
          LOC_P(PTR(MP))=SAVE_LITERAL(0,VAR(MP));
          PSEUDO_FORM(PTR(MP))=XLIT;
          PSEUDO_TYPE(PTR(MP))=CHAR_TYPE;
          PSEUDO_LENGTH(PTR(MP))=LENGTH(VAR(MP));
       END;
    #  <CHAR CONST>  ::=  CHAR  (  <NUMBER>  )  <CHAR STRING>
       DO;
       TOKEN_FLAGS(STACK_PTR(SP - 1)) = TOKEN_FLAGS(STACK_PTR(SP - 1)) | "20";
          VAR(MP)=VAR(SP);
          TEMP=FIXV(MP+2);
          if TEMP<1: ERROR(d.CLASS_LS,2);
          ELSE DO WHILE TEMP>1;
             TEMP=TEMP-1;
             TEMP2=CHAR_LENGTH_LIM-LENGTH(VAR(MP));
             if TEMP2<FIXV(SP): DO;
                TEMP=0;
                ERROR(d.CLASS_LS,1);
                S=SUBSTR(VAR(SP),0,TEMP2);
                VAR(MP)=VAR(MP)+S;
             END;
             ELSE VAR(MP)=VAR(MP)+VAR(SP);
          END;
          GO TO CHAR_LITS;
       END;
    #  <IO CONTROL>  ::=  SKIP  (  <ARITH EXP>  )
       DO;
          TEMP=3;
    IO_CONTROL:
          if UNARRAYED_INTEGER(SP-1): ERROR(d.CLASS_TC,1);
          VAL_P(PTR(MP))=0;
          PTR(MP)=PTR(SP-1);
       END;
    #  <IO CONTROL>  ::=  TAB  (  <ARITH EXP>  )
       DO;
          TEMP=1;
          GO TO IO_CONTROL;
       END;
    #  <IO CONTROL>  ::=  COLUMN  (  <ARITH EXP>  )
       DO;
          TEMP=2;
          GO TO IO_CONTROL;
       END;
    #  <IO CONTROL>  ::=  LINE  (  <ARITH EXP>  )
       DO;
          TEMP=4;
          GO TO IO_CONTROL;
       END;
    #  <IO CONTROL>  ::=  PAGE  (  <ARITH EXP>  )
       DO;
          TEMP=5;
          GO TO IO_CONTROL;
       END;
    #  <READ PHRASE>  ::=  <READ KEY>  <READ ARG>
       DO;
    CHECK_READ:
          if INX(PTR(MP))=0: DO;
             if SHR(VAL_P(PTR(SP)),7): ERROR(d.CLASS_T,3);
             if PSEUDO_TYPE(PTR(SP))=EVENT_TYPE: ERROR(d.CLASS_T,2);
          END;
          ELSE if TEMP>0: ;
          ELSE if READ_ALL_TYPE(SP): ERROR(d.CLASS_T,1);
       END;
    #  <READ PHRASE>  ::=  <READ PHRASE>  ,  <READ ARG>
       GO TO CHECK_READ;
    #  <WRITE PHRASE>  ::=  <WRITE KEY>  <WRITE ARG>
       ;
    #  <WRITE PHRASE>  ::=  <WRITE PHRASE>  ,  <WRITE ARG>
       ;
    #  <READ ARG>  ::=  <VARIABLE>
       DO;
          TEMP=0;
    EMIT_IO_ARG:
          if KILL_NAME(MP): ERROR(d.CLASS_T,5);
          if INLINE_LEVEL>0: ERROR(d.CLASS_PP,5);
          HALMAT_TUPLE(XXXAR,XCO_N,MP,0,0);
          HALMAT_FIX_PIPTAGS(NEXT_ATOM#-1,PSEUDO_TYPE(PTR(MP)),TEMP);
          if PSEUDO_TYPE(PTR(MP))=MAJ_STRUC:
             if (SYT_FLAGS(VAR_LENGTH(FIXV(MP)))&MISC_NAME_FLAG)!=0:
             ERROR(d.CLASS_T,6);
          EMIT_ARRAYNESS();
          PTR_TOP=PTR(MP)-1;
       END;
    #  <READ ARG>  ::=  <IO CONTROL>
       GO TO EMIT_IO_ARG;
    #  <WRITE ARG>  ::=  <EXPRESSION>
       DO;
          TEMP=0;
          GO TO EMIT_IO_ARG;
       END;
    #  <WRITE ARG>  ::=  <IO CONTROL>
       GO TO EMIT_IO_ARG;
    #  <READ KEY>  ::=  READ  (  <NUMBER>  )
       DO;
          TEMP=0;
    EMIT_IO_HEAD:
          XSET SHL(TEMP,11);
          HALMAT_POP(XXXST,1,XCO_N,0);
          HALMAT_PIP(TEMP,XIMD,0,0);
          PTR(MP)=PUSH_INDIRECT(1);
          if FIXV(MP+2)> DEVICE_LIMIT: DO;
             ERROR(d.CLASS_TD,1,''+DEVICE_LIMIT);
             LOC_P(PTR(MP))=0;
          END;
          ELSE DO;
             LOC_P(PTR(MP))=FIXV(MP+2);
             I=IODEV(FIXV(MP+2));
             if (I&"28")=0: DO;
                if TEMP=2: DO;
                   if (I&"01")=0: I=I|"04";
                   ELSE I=I|"02";
                END;
                ELSE DO;
                   I=I|"01";
                   if (I&"04")!=0: if (I&"40")!=0: I=I|"80";
                   ELSE I=(I&"FB")|"02";
                END;
             END;
             IODEV(FIXV(MP+2))=I;
          END;
          PSEUDO_FORM(PTR(MP))=XIMD;
          INX(PTR(MP))=TEMP;
          if UPDATE_BLOCK_LEVEL>0: ERROR(d.CLASS_UT,1);
       END;
    #  <READ KEY>  ::=  READALL  (  <NUMBER>  )
       DO;
          TEMP=1;
          GO TO EMIT_IO_HEAD;
       END;
    #  <WRITE KEY>  ::=  WRITE  (  <NUMBER>  )
       DO;
          TEMP=2;
          GO TO EMIT_IO_HEAD;
       END;
    #  <BLOCK DEFINITION> ::= <BLOCK STMT> <BLOCK BODY> <CLOSING> ;
       DO;
          TEMP=XCLOS;
          TEMP2=0;
    CLOSE_SCOPE:
          HALMAT_POP(TEMP,1,0,TEMP2);
          HALMAT_PIP(BLOCK_SYTREF(NEST),XSYT,0,0);
          DO I = 0 TO NDECSY - REGULAR_PROCMARK;
             J = NDECSY - I;
             if (SYT_FLAGS(J) & INACTIVE_FLAG) = 0:
                DO;
                CLOSE_BCD = SYT_NAME(J);
                if SYT_CLASS(J) = FUNC_CLASS:
                   DO;
                   if (SYT_FLAGS(J) & DEFINED_LABEL) = 0:
                      ERROR(d.CLASS_PL, 1, CLOSE_BCD);
                   DISCONNECT(J);
                END;
                ELSE if SYT_CLASS(J) = LABEL_CLASS:
                   DO;
                   if (SYT_FLAGS(J) & DEFINED_LABEL) = 0:
                      DO;  # UNDEFINED CALLABLE LABEL
                      if SYT_TYPE(J) = STMT_LABEL:
                         DO;
                         DISCONNECT(J);
                         ERROR(d.CLASS_PL, 5, CLOSE_BCD);
    # UNDEFINED OBJECT OF GO TO
                      END;
                      ELSE
                         DO;  # CALLED/SCHED BUT UNDEFINED
                                       PROCS/TASKS
                         if NEST=1:
                            DO;  # CLOSING PROGRAM -
                                             MAKE UNDEFINED CALLS/SCHEDS
                                             INTO ERRORS
                            ERROR(d.CLASS_PL, 6, CLOSE_BCD);
                            DISCONNECT(J);
                         END;
                         ELSE DO;
                            SET_OUTER_REF(J,"6000");
                            SYT_NEST(J)=NEST-1;
                         END;
                      END;  # OF CALLED LABELS
                   END;  # OF UNDEFINED CALLABLE LABELS
                   ELSE if SYT_TYPE(J) = IND_CALL_LAB:
                      DO;
                      SYT_NEST(J) = NEST - 1;
                      K = SYT_PTR(J);
                      DO WHILE SYT_TYPE(K) = IND_CALL_LAB;
                         K = SYT_PTR(K);
                      END;
                      if SYT_NEST(K) >= SYT_NEST(J):
                         DO; # IND CALL HAS REACHED SAME SCOPE AS
                                        DEFINITION OF LABEL. SO LEAVE
                                        AS IND CALL AND DISCONNECT FROM SYT
                         if SYT_PTR(J) = K:
                            if SYT_LINK1(K) < 0:
                            if DO_LEVEL < (-SYT_LINK1(K)):
                            ERROR(d.CLASS_PL, 11, CLOSE_BCD);
                         DISCONNECT(J);
                         TIE_XREF(J);
                      END;
                   END;  # OF TYPE = IND_CALL_LAB
                   ELSE DISCONNECT(J); # NONE OF THE ABOVE
                END;  # OF LABEL CLASS
                ELSE DISCONNECT(J);  # ALL OTHER CLASSES
             END;
          END;
          if BLOCK_MODE(NEST)=UPDATE_MODE:
             UPDATE_BLOCK_LEVEL = UPDATE_BLOCK_LEVEL - 1;
          if LENGTH(VAR(SP-1)) > 0:
             if VAR(SP-1) != CURRENT_SCOPE:
             ERROR(d.CLASS_PL,3,CURRENT_SCOPE);
          if REGULAR_PROCMARK > NDECSY:    # NO LOCAL NAMES
             SYT_PTR(FIXL(MP)) = 0;
          if (SYT_FLAGS(FIXL(MP)) & ACCESS_FLAG) != 0:
             if BLOCK_MODE(NEST) = CMPL_MODE:
             DO I = FIXL(MP) TO NDECSY;
             SYT_FLAGS(I) = SYT_FLAGS(I) | READ_ACCESS_FLAG;
          END;
    # IF THIS IS THE CLOSE OF A COMPOOL INCLUDED REMOTE
   : MAKE SURE THAT ALL OF THE ITEMS IN THE COMPOOL
    ARE ALSO FLAGED AS REMOTE - EXCEPT FOR NAME TYPES AND
    STRUCTURE TEMPLATE VARIABLES.
          if ((SYT_FLAGS(FIXL(MP)) & EXTERNAL_FLAG) != 0)
             & ((SYT_FLAGS(FIXL(MP)) & REMOTE_FLAG) != 0):
             if BLOCK_MODE(NEST) = CMPL_MODE:
             DO I = FIXL(MP) TO NDECSY;
    # IF 16-BIT NAME VARIABLE WAS INITIALIZED TO NON-REMOTE VARIABLE IN
    # A REMOTELY INCLUDED COMPOOL, IT IS NOW INVALID.
    TEMPL_INITIAL_CHECK:PROCEDURE;
    # IS POINTED TO BY A NAME VARIABLE
                if (SYT_FLAGS(I) & MISC_NAME_FLAG) != 0
                  : if SYT_TYPE(I) != TEMPL_NAME # NOT A TEMPLATE
    # NON-REMOTE
                  : if (SYT_FLAGS(I) & REMOTE_FLAG) = 0
                  : ERROR(d.CLASS_DI,21);
             END TEMPL_INITIAL_CHECK;
             TEMPL_INITIAL_CHECK();
    #          INCLUDED_REMOTE MEANS VARIABLE LIVES REMOTE ONLY BECAUSE
    #          IT WAS INCLUDED REMOTE (IT RESIDES IN #P, NOT IN #R)
             if (SYT_CLASS(I) != TEMPLATE_CLASS): DO;
    # NOT A NAME VARIABLE AND NOT INITIALLY DECLARED REMOTE
                if ((SYT_FLAGS(I) & NAME_FLAG) = 0) &
                   ((SYT_FLAGS(I) & REMOTE_FLAG) = 0):
                   SYT_FLAGS(I) = SYT_FLAGS(I) | REMOTE_FLAG |
                   INCLUDED_REMOTE;
    # FOR NAME VARIABLES, SET THAT THEY NOW LIVE REMOTE
                if ((SYT_FLAGS(I) & NAME_FLAG) != 0):
                   SYT_FLAGS(I) = SYT_FLAGS(I) |
                   INCLUDED_REMOTE;
             END;
          END;
          SYT_FLAGS(NDECSY) = SYT_FLAGS(NDECSY) | ENDSCOPE_FLAG;
          CURRENT_SCOPE = VAR(MP);
          if PTR(MPP1): DO CASE EXTERNAL_MODE;
    #  NOT EXTERNAL
             if BLOCK_MODE(NEST)=CMPL_MODE: ERROR(d.CLASS_PC,1);
    #  PROC MODE
             ERROR(d.CLASS_PS,1);
    #  FUNC MODE
             ERROR(d.CLASS_PS,1);
    #  COMPOOL MODE
             ERROR(d.CLASS_PC,2);
    # PROGRAM MODE
             ERROR(d.CLASS_PS,1);
          END;
          OUTPUT_WRITER;
          EMIT_SMRK();
          if BLOCK_MODE(NEST)=INLINE_MODE: DO;
             INLINE_INDENT_RESET=EXT_P(PTR(MP));
             INDENT_LEVEL=INLINE_INDENT+INDENT_INCR;
             INLINE_STMT_RESET=STMT_NUM;
             STMT_NUM=INX(PTR(MP));
             INX(PTR(MP)) = 0;
             if PSEUDO_TYPE(PTR(MP))=MAJ_STRUC: FIXL(MP)=
                PSEUDO_LENGTH(PTR(MP));
             RESET_ARRAYNESS();
             INLINE_LEVEL=INLINE_LEVEL-1;
             NEST_LEVEL = NEST_LEVEL - 1;
             if INLINE_LEVEL=0: DO;
                STAB_MARK,STAB2_MARK = 0;
                XSET STAB_STACK;
                SRN_FLAG=FALSE;
                SRN(2)=SRN_MARK;
                INCL_SRN(2) = INCL_SRN_MARK;
                SRN_COUNT(2)=SRN_COUNT_MARK;
             END;
             FIXF(MP)=0;
          END;
          ELSE DO;
             BLOCK_SUMMARY();
             OUTER_REF_INDEX=(OUTER_REF_PTR(NEST)&"7FFF")-1;
             INDENT_LEVEL = INDENT_STACK(NEST);
             NEST_LEVEL = NEST_STACK(NEST);
          END;
          PROCMARK,REGULAR_PROCMARK=PROCMARK_STACK(NEST);
          SCOPE# = SCOPE#_STACK(NEST);
          I=0;
          DO WHILE ON_ERROR_PTR<-SYT_ARRAY(BLOCK_SYTREF(NEST));
             if EXT_ARRAY(ON_ERROR_PTR)="3FFF": I=I+"1001";
             ELSE I=I+1;
             ON_ERROR_PTR=ON_ERROR_PTR+1;
          END;
          SYT_ARRAY(BLOCK_SYTREF(NEST))=I|"E000";
          NEST = NEST - 1;
          DO_INX(DO_LEVEL)=DO_INX(DO_LEVEL)&"7F";
          if NEST=0: DO;
             if EXTERNAL_MODE>0: DO;
                if SIMULATING=2: DO;
                   STMT_TYPE=0;
                   SIMULATING=1;
                END;
                EXTERNAL_MODE=0;
                TPL_VERSION=BLOCK_SYTREF(NEST+1);
                SYT_LOCK#(TPL_VERSION)=0;
             END;
             ELSE if BLOCK_MODE>0: DO;
                if EXTERNALIZE=4: EXTERNALIZE=2;
                EMIT_EXTERNAL();
             END;
          END;
       END;
    #  <BLOCK BODY>  ::= <EMPTY>
       DO;
          HALMAT_POP(XEDCL,0,XCO_N,0);
          GO TO CHECK_DECLS;
       END;
    
    #  <BLOCK BODY>  ::=  <DECLARE GROUP>
       DO;
          HALMAT_POP(XEDCL, 0, XCO_N, 1);
    CHECK_DECLS:
          I = BLOCK_MODE(NEST);
          if (I = FUNC_MODE) | (I = PROC_MODE): DO;
             J=BLOCK_SYTREF(NEST);  # PROC FUNC NAME
             if SYT_PTR(J) != 0: DO;
                J = SYT_PTR(J);  # POINT TO FIRST ARG
                DO WHILE (SYT_FLAGS(J) & PARM_FLAGS) != 0;
                   if (SYT_FLAGS(J) & IMP_DECL) != 0:
                      DO;  # UNDECLARED PARAMETER
                      ERROR(d.CLASS_DU, 2, SYT_NAME(J));
                      PARMS_PRESENT=0;
                      SYT_TYPE(J) = DEFAULT_TYPE;
                      SYT_FLAGS(J) = SYT_FLAGS(J) | DEFAULT_ATTR;
                   END;
                   J = J + 1;  # NEXT PARAMETER
                END;
                if (EXTERNAL_MODE > 0) & (EXTERNAL_MODE < CMPL_MODE):
                   DO WHILE J <= NDECSY;
                   if SYT_CLASS(J)<REPL_ARG_CLASS: DO;
                      ERROR(d.CLASS_DU, 3, SYT_NAME(J));
                      SYT_FLAGS(J) = SYT_FLAGS(J) | DUMMY_FLAG;
                   END;
                   J = J + 1;
                END;
             END;
          END;
          if EXTERNALIZE: EXTERNALIZE=4;
          PTR(MP)=0;
       END;
    
    #  <BLOCK BODY>  ::=  <BLOCK BODY>  <ANY STATEMENT>
       PTR(MP)=1;
    #  <ARITH INLINE DEF>  ::=  FUNCTION <ARITH SPEC>  ;
       DO;
          if TYPE=0: TYPE=DEFAULT_TYPE;
          if (ATTRIBUTES&SD_FLAGS)=0: ATTRIBUTES=ATTRIBUTES|
             (DEFAULT_ATTR&SD_FLAGS);
          if TYPE<SCALAR_TYPE: TEMP=TYPE(TYPE);
          ELSE TEMP=0;
    INLINE_DEFS:
          if CONTEXT=EXPRESSION_CONTEXT: ERROR(d.CLASS_PP,11);
          CONTEXT=0;
        GRAMMAR_FLAGS(STACK_PTR(MP))=GRAMMAR_FLAGS(STACK_PTR(MP))|INLINE_FLAG;
          PTR(MP)=PUSH_INDIRECT(1);
          INLINE_LEVEL=INLINE_LEVEL+1;
          if INLINE_LEVEL>1: ERROR(d.CLASS_PP,10);
          ELSE  DO;
             STAB_MARK=STAB_STACKTOP;
             STAB2_MARK = STAB2_STACKTOP;
             STAB_STACK=STMT_TYPE;
             SRN_MARK=SRN(2);
             INCL_SRN_MARK = INCL_SRN(2);
             SRN_COUNT_MARK=SRN_COUNT(2);
             STMT_TYPE=0;
          END;
          INLINE_LABEL=INLINE_LABEL+1;
          VAR(MP)=l.INLINE_NAME+INLINE_LABEL;
          NAME_HASH=HASH(VAR(MP),SYT_HASHSIZE);
          I,FIXL(MP)=ENTER(VAR(MP),FUNC_CLASS);
          if SIMULATING: STAB_LAB(I);
          SET_XREF(I,XREF_REF);
          SYT_TYPE(I)=TYPE;
          SYT_FLAGS(I)=SYT_FLAGS(I)|DEFINED_LABEL|ATTRIBUTES;
          VAR_LENGTH(I)=TEMP;
          HALMAT_POP(XIDEF,1,0,INLINE_LEVEL);
          HALMAT_PIP(I,XSYT,0,0);
          SETUP_VAC(MP,TYPE,TEMP);
          TEMP2=INLINE_MODE;
          DO I=0 TO FACTOR_LIM;
             TYPE(I)=0;
          END;
          SAVE_ARRAYNESS();
        if (SUBSCRIPT_LEVEL|EXPONENT_LEVEL)!=0: ERROR(d.CLASS_B,2);
          GO TO INLINE_ENTRY;
       END;
    #  <ARITH INLINE DEF>  ::=  FUNCTION  ;
       DO;
          TYPE=DEFAULT_TYPE;
          ATTRIBUTES=DEFAULT_ATTR&SD_FLAGS;
          TEMP=0;
          GO TO INLINE_DEFS;
       END;
    #  <BIT INLINE DEF>  ::=  FUNCTION <BIT SPEC>  ;
       DO;
          TEMP=BIT_LENGTH;
          GO TO INLINE_DEFS;
       END;
    #  <CHAR INLINE DEF>  ::=  FUNCTION <CHAR SPEC>  ;
       DO;
          if CHAR_LENGTH<0: DO;
             ERROR(d.CLASS_DS,3);
             TEMP=DEF_CHAR_LENGTH;
          END;
          ELSE TEMP=CHAR_LENGTH;
          GO TO INLINE_DEFS;
       END;
    #  <STRUC INLINE DEF>  ::=  FUNCTION <STRUCT SPEC>  ;
       DO;
          if STRUC_DIM!=0: DO;
             ERROR(d.CLASS_DD,12);
             STRUC_DIM=0;
          END;
          TEMP=STRUC_PTR;
          TYPE=MAJ_STRUC;
          GO TO INLINE_DEFS;
       END;
    #  <BLOCK STMT>  ::=  <BLOCK STMT TOP>  ;
       DO;
          OUTPUT_WRITER;
          if PARMS_PRESENT<=0: if EXTERNALIZE: EXTERNALIZE=4;
          INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
          if TPL_REMOTE:
             if EXTERNAL_MODE>0 & NEST=1 & BLOCK_MODE(NEST)=CMPL_MODE:
             SYT_FLAGS(FIXL(MP)) = SYT_FLAGS(FIXL(MP)) | REMOTE_FLAG;
          ELSE ERROR(d.CLASS_PS,13);
          TPL_REMOTE = FALSE;
          EMIT_SMRK();
       END;
    #  <BLOCK STMT TOP> ::= <BLOCK STMT TOP> ACCESS
       DO;
          if BLOCK_MODE(NEST)>PROG_MODE:
             ERROR(d.CLASS_PS,3);
          ELSE if NEST != 1: ERROR(d.CLASS_PS, 4);
    ELSE if (SYT_FLAGS(FIXL(MP))&ACCESS_FLAG)!=0: ERROR(d.CLASS_PS,10);
          ELSE DO;
             SYT_FLAGS(FIXL(MP)) = SYT_FLAGS(FIXL(MP)) | ACCESS_FLAG;
             ACCESS_FOUND = TRUE;
          END;
       END;
    #  <BLOCK STMT TOP>  ::= <BLOCK STMT TOP> RIGID
       DO;
          if BLOCK_MODE(NEST)!=CMPL_MODE: ERROR(d.CLASS_PS,12);
     ELSE if (SYT_FLAGS(FIXL(MP))&RIGID_FLAG)!=0: ERROR(d.CLASS_PS,11);
          ELSE SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|RIGID_FLAG;
       END;
    #  <BLOCK STMT TOP>  ::=  <BLOCK STMT HEAD>
       ;
    #  <BLOCK STMT TOP>  ::=  <BLOCK STMT HEAD>  EXCLUSIVE
       DO;
        if BLOCK_MODE(NEST)>FUNC_MODE: ERROR(d.CLASS_PS,2,'EXCLUSIVE');
          SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|EXCLUSIVE_FLAG;
       END;
    #  <BLOCK STMT TOP>  ::=  <BLOCK STMT HEAD>  REENTRANT
       DO;
        if BLOCK_MODE(NEST)>FUNC_MODE: ERROR(d.CLASS_PS,2,'REENTRANT');
          SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|REENTRANT_FLAG;
       END;
    #  <LABEL DEFINITION>  ::=  <LABEL>  :
       DO;
          if NEST=0: EXTERNAL_MODE=0;
          HALMAT_POP(XLBL,1,XCO_N,0);
          HALMAT_PIP(FIXL(MP),XSYT,0,0);
          TEMP=FIXL(MP);
          if SYT_TYPE(TEMP) != IND_CALL_LAB: DO;
             if SYT_LINK1(TEMP)>0: if DO_LEVEL>0:
                if DO_STMTp(DO_LEVEL) > SYT_LINK1(TEMP): DO;
                if SYT_TYPE(TEMP) = STMT_LABEL: ERROR(d.CLASS_GL, 2);
                ELSE ERROR(d.CLASS_PL, 10);
             END;
             if SYT_LINK1(TEMP) >= 0: DO;
                SYT_LINK1(TEMP) = -DO_LEVEL;
                SYT_LINK2(TEMP) = SYT_LINK2(0);
                SYT_LINK2(0) = TEMP;
             END;
          END;
          LABEL_COUNT=LABEL_COUNT+1;
          if SIMULATING: STAB_LAB(FIXL(MP));
         GRAMMAR_FLAGS(STACK_PTR(MP))=GRAMMAR_FLAGS(STACK_PTR(MP))|LABEL_FLAG;
          # IF THE XREF ENTRY IS FOR THE LABEL'S DEFINITION (FLAG=0),
          # THEN CHECK THE STATEMENT NUMBER.  IF IT IS NOT EQUAL TO CURRENT
          # STATEMENT NUMBER, CHANGE IT TO THE CURRENT STATEMENT NUMBER.
           if (SHR(XREF(SYT_XREF(FIXL(MP))),13) & 7) = 0:
              if (XREF(SYT_XREF(FIXL(MP))) & XREF_MASK) != STMT_NUM:
               XREF(SYT_XREF(FIXL(MP))) =
                 (XREF(SYT_XREF(FIXL(MP))) & "FFFFE000") | STMT_NUM;
          if SYT_TYPE(FIXL(MP))=STMT_LABEL: DO;
            NO_NEW_XREF = TRUE;
            SET_XREF(FIXL(MP),0);
          END;
       END;
    #  <LABEL EXTERNAL>  ::=  <LABEL DEFINITION>
       ;
    #  <LABEL EXTERNAL>  ::=  <LABEL DEFINITION>  EXTERNAL
       DO;
          if NEST>0: ERROR(d.CLASS_PE,1);
          ELSE DO;
             SYT_FLAGS(FIXL(MP)) = SYT_FLAGS(FIXL(MP)) | EXTERNAL_FLAG;
             EXTERNAL_MODE=1;   # JUST A FLAG FOR NOW
             if BLOCK_MODE>0: ERROR(d.CLASS_PE,2);
             if SIMULATING: DO;
                STAB2_STACKTOP = STAB2_STACKTOP - 1;
                SIMULATING=2;
             END;
          END;
       END;
    #  <BLOCK STMT HEAD>  ::=  <LABEL EXTERNAL>  PROGRAM
       DO;
          TEMP=XMDEF;
          PARMS_PRESENT=0;
          TEMP2=PROG_MODE;
          SET_LABEL_TYPE(FIXL(MP),PROG_LABEL);
          SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|LATCHED_FLAG;
          if EXTERNAL_MODE>0: DO;
             if NEST=0: EXTERNAL_MODE=TEMP2;
             GO TO NEW_SCOPE;
          END;
    OUTERMOST_BLOCK:
          if NEST>0: ERROR(d.CLASS_PP,1,VAR(MPP1));
          ELSE DO;
    DUPLICATE_BLOCK:
             if BLOCK_MODE=0: DO;
                MAIN_SCOPE=MAX_SCOPE#+1;  # WHAT SYT_SCOPE WILL BECOME
                FIRST_STMT = STMT_NUM;
                BLOCK_MODE=TEMP2;
                if BLOCK_MODE<TASK_MODE: if TPL_FLAG<3: EXTERNALIZE=3;
                MONITOR(17,DESCORE(VAR(MP)));
                EMIT_EXTERNAL();
             END;
             ELSE ERROR(d.CLASS_PP,2);
          END;
          GO TO NEW_SCOPE;
       END;
    #  <BLOCK STMT HEAD>  ::=  <LABEL EXTERNAL>  COMPOOL
       DO;
          TEMP=XCDEF;
          TEMP2=CMPL_MODE;
          PARMS_PRESENT=1;#  FIX SO ALL DECLARES EMITTED IN CMPL TEMPLATE
          SET_LABEL_TYPE(FIXL(MP),COMPOOL_LABEL);
          #THIS IS A COMPOOL COMPILATION
          #CHECK IF #D OPTION IS ON.   EMIT FATAL ERROR IF ITS.
          #TURN OFF DATA REMOTE TO ALLOW FOR FUTURE DOWNGRADE OF
          #THE ERROR
          # PART 1. ALSO CHECK IF COMPOOL IS NOT
          #         EXTERNAL BEFORE EMITTING THE XR2 ERROR.
          if DATA_REMOTE & (EXTERNAL_MODE = 0): DO;
             ERROR(d.CLASS_XR,2);
             DATA_REMOTE=FALSE;
          END;
          if EXTERNAL_MODE>0: DO;
             if NEST=0: EXTERNAL_MODE=TEMP2;
             GO TO NEW_SCOPE;
          END;
          ELSE GO TO OUTERMOST_BLOCK;
       END;
    #  <BLOCK STMT HEAD>  ::=  <LABEL DEFINITION>  TASK
       DO;
          TEMP=XTDEF;
          TEMP2=TASK_MODE;
          SET_LABEL_TYPE(FIXL(MP),TASK_LABEL);
          SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|LATCHED_FLAG;
          if NEST=1: DO;
             if BLOCK_MODE(1) = PROG_MODE: DO;
                if DO_LEVEL > 1: ERROR(d.CLASS_PT, 2);
                GO TO NEW_SCOPE;
             END;
          END;
          ERROR(d.CLASS_PT,1);
          if NEST=0: GO TO DUPLICATE_BLOCK;
          ELSE GO TO NEW_SCOPE;
       END;
    #  <BLOCK STMT HEAD>  ::=  <LABEL DEFINITION>  UPDATE
       DO;
          VAR_LENGTH(FIXL(MP))=1;
          HALMAT_BACKUP(LAST_POP#);
    UPDATE_HEAD:
          if UPDATE_BLOCK_LEVEL>0: ERROR(d.CLASS_UI,2);
          UPDATE_BLOCK_LEVEL=UPDATE_BLOCK_LEVEL+1;
          TEMP2=UPDATE_MODE;
          TEMP=XUDEF;
          SET_LABEL_TYPE(FIXL(MP),STMT_LABEL);
          if NEST=0: DO;
             ERROR(d.CLASS_PP,3,VAR(MPP1));
             GO TO DUPLICATE_BLOCK;
          END;
          ELSE GO TO NEW_SCOPE;
       END;
    #  <BLOCK STMT HEAD>  ::=  UPDATE
       DO;
          VAR(MPP1)=VAR(MP);
          IMPLIED_UPDATE_LABEL=IMPLIED_UPDATE_LABEL+1;
          VAR(MP)=l.UPDATE_NAME+IMPLIED_UPDATE_LABEL;
          NAME_HASH=HASH(VAR(MP),SYT_HASHSIZE);
          I,FIXL(MP)=ENTER(VAR(MP),LABEL_CLASS);
          SYT_TYPE(I)=UNSPEC_LABEL;
          SYT_FLAGS(I)=SYT_FLAGS(I)|DEFINED_LABEL;
          VAR_LENGTH(I)=2;
          if SIMULATING: STAB_LAB(FIXL(MP));
          GO TO UPDATE_HEAD;
       END;
    #  <BLOCK STMT HEAD>  ::=  <FUNCTION NAME>
       DO;
    FUNC_HEADER:
          if PARMS_PRESENT = 0: DO;
             PARMS_WATCH = FALSE;
             if MAIN_SCOPE = SCOPEp: COMSUB_END = FIXL(MP);
          END;
          FACTORING=TRUE;
          DO_INIT = FALSE;
          if TYPE = 0:
             TYPE = DEFAULT_TYPE;
          ELSE if TYPE = EVENT_TYPE:
             DO;
             ERROR(d.CLASS_FT, 3, SYT_NAME(ID_LOC));
             TYPE = DEFAULT_TYPE;
          END;
          if (ATTRIBUTES & SD_FLAGS) = 0:
             if (TYPE >= MAT_TYPE) & (TYPE <= INT_TYPE):
             ATTRIBUTES = ATTRIBUTES | (DEFAULT_ATTR & SD_FLAGS);
          if TYPE=MAJ_STRUC: CHECK_STRUC_CONFLICTS();
          if SYT_TYPE(ID_LOC) = 0: DO;
             SET_SYT_ENTRIES();
          END;
          ELSE DO;
             if SYT_TYPE(ID_LOC) != TYPE:
                ERROR(d.CLASS_DT, 1, SYT_NAME(ID_LOC));
             ELSE DO;  # TYPES MATCH, WHAT ABOUT SIZES
                if TYPE <= VEC_TYPE: DO;
                   if TYPE(TYPE) != VAR_LENGTH(ID_LOC):
                      ERROR(d.CLASS_FT, 4, SYT_NAME(ID_LOC));
                END;
                ELSE if TYPE = MAJ_STRUC: DO;
                   if STRUC_PTR!=VAR_LENGTH(ID_LOC):
                      ERROR(d.CLASS_FT, 6, SYT_NAME(ID_LOC));
                END;
                if (ATTRIBUTES & SD_FLAGS) != 0:
                   if ((SYT_FLAGS(ID_LOC) & ATTRIBUTES) & SD_FLAGS) = 0:
                   ERROR(d.CLASS_FT, 7, SYT_NAME(ID_LOC));
             END;  # OF TYPES MATCH
             DO I = 0 TO FACTOR_LIM;
                TYPE(I) = 0;
             END;
          END;
       END;
    #  <BLOCK STMT HEAD>  ::=  <FUNCTION NAME>  <FUNC STMT BODY>
       GO TO FUNC_HEADER;
    #  <BLOCK STMT HEAD>  ::=  <PROCEDURE NAME>
       DO;
          PARMS_WATCH = FALSE;
          if MAIN_SCOPE = SCOPEp: COMSUB_END = FIXL(MP);
       END;
    #  <BLOCK STMT HEAD>  ::=  <PROCEDURE NAME>  <PROC STMT BODY>
       ;
    #  <FUNCTION NAME>  ::=  <LABEL EXTERNAL>  FUNCTION
       DO;
          ID_LOC=FIXL(MP);
          FACTORING=FALSE;
          if SYT_CLASS(ID_LOC)!=FUNC_CLASS:
         if SYT_CLASS(ID_LOC)!=LABEL_CLASS|SYT_TYPE(ID_LOC)!=UNSPEC_LABEL:
             ERROR(d.CLASS_PL,4);
          ELSE DO;
             SYT_CLASS(ID_LOC)=FUNC_CLASS;
             SYT_TYPE(ID_LOC)=0;
          END;
          TEMP=XFDEF;
          TEMP2=FUNC_MODE;
          GO TO PROC_FUNC_HEAD;
       END;
    #  <PROCEDURE NAME>  ::=  <LABEL EXTERNAL>  PROCEDURE
       DO;
          TEMP2=PROC_MODE;
          TEMP=XPDEF;
          SET_LABEL_TYPE(FIXL(MP),PROC_LABEL);
    PROC_FUNC_HEAD:
          PARMS_PRESENT=0;
          if INLINE_LEVEL>0: ERROR(d.CLASS_PP,9);
          if EXTERNAL_MODE>0: DO;
             if NEST=0: EXTERNAL_MODE=TEMP2;
          END;
          ELSE if NEST=0: DO;
             PARMS_WATCH=TRUE;
             GO TO DUPLICATE_BLOCK;
          END;
    #  ALL BLOCKS AND TEMPLATES COME HERE
    NEW_SCOPE:
          SET_BLOCK_SRN(FIXL(MP));
          if ^PAGE_THROWN:
             if (SYT_FLAGS(FIXL(MP)) & EXTERNAL_FLAG) = 0:
             LINE_MAX = 0;
          if TEMP2!=UPDATE_MODE: DO;
             HALMAT_BACKUP(LAST_POP#);
          END;
          if ^HALMAT_CRAP: HALMAT_OK=EXTERNAL_MODE=0;
          HALMAT_POP(TEMP,1,0,0);
          HALMAT_PIP(FIXL(MP),XSYT,0,0);
    INLINE_ENTRY:
          XSET"16";
          NEST=NEST+1;
          DO_INX(DO_LEVEL)=DO_INX(DO_LEVEL)|"80";
          BLOCK_MODE(NEST)=TEMP2;
          BLOCK_SYTREF(NEST)=FIXL(MP);
          SYT_ARRAY(BLOCK_SYTREF(NEST))=-ON_ERROR_PTR;
          if NEST > MAXNEST:
             DO;
             MAXNEST = NEST;
             if NEST >= NEST_LIM:
                ERROR(d.CLASS_BN,1);
          END;
          SCOPE#_STACK(NEST) = SCOPE#;
          MAX_SCOPE#, SCOPE# = MAX_SCOPE# + 1;
          if (SYT_FLAGS(FIXL(MP))&EXTERNAL_FLAG) != 0: DO;
             NEXT_ELEMENT(CSECT_LENGTHS);
             CSECT_LENGTHS(SCOPEp).PRIMARY = "7FFF";# SET LENGTH TO MAX
             CSECT_LENGTHS(SCOPEp).REMOTE = "7FFF"; # TO TURN OFF PHASE2
    # %COPY CHECKING
          END;
          SYT_SCOPE(FIXL(MP)) = SCOPE#; # UPDATE BLOCK NAME TO SAME SCOPE
    # AS CONTENTS
          PROCMARK_STACK(NEST) = PROCMARK;
          REGULAR_PROCMARK, PROCMARK = NDECSY + 1;
          SYT_PTR(FIXL(MP)) = PROCMARK;
          if BLOCK_MODE(NEST) = CMPL_MODE:
             PROCMARK = 1;  # ALL COMPOOLS IN SAME SCOPE
          S = CURRENT_SCOPE;
          SAVE_SCOPE, CURRENT_SCOPE = VAR(MP);
          VAR(MP) = S;
          NEST = NEST - 1;
          COMPRESS_OUTER_REF();
          NEST = NEST + 1;
          OUTER_REF_PTR(NEST)=OUTER_REF_INDEX+1;
          ENTER_LAYOUT(FIXL(MP));
          if BLOCK_MODE(NEST)=INLINE_MODE: DO;
             if STACK_PTR(MP)>0: OUTPUT_WRITER(0,STACK_PTR(MP)-1);
             EXT_P(PTR(MP))=INDENT_LEVEL;
             INX(PTR(MP))=STMT_NUM;
             EMIT_SMRK()(5);
             INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
             OUTPUT_WRITER(STACK_PTR(MP),STACK_PTR(SP));
             INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
             NEST_LEVEL = NEST_LEVEL + 1;
             EMIT_SMRK();
          END;
          ELSE DO;
             INDENT_STACK(NEST) = INDENT_LEVEL;
             NEST_STACK(NEST) = NEST_LEVEL;
             INDENT_LEVEL, NEST_LEVEL = 0;
          END;
       END;
    #  <FUNC STMT BODY>  ::=  <PARAMETER LIST>
       ;
    #  <FUNC STMT BODY>  ::=  <TYPE SPEC>
       ;
    #  <FUNC STMT BODY>  ::=  <PARAMETER LIST>  <TYPE SPEC>
       ;
    #  <PROC STMT BODY>  ::=  <PARAMETER LIST>
       ;
    #  <PROC STMT BODY>  ::=  <ASSIGN LIST>
       ;
    #  <PROC STMT BODY>  ::=  <PARAMETER LIST>  < ASSIGN LIST>
       ;
    #  <PARAMETER LIST>  ::=  <PARAMETER HEAD>  <IDENTIFIER>  )
       PARMS_PRESENT=PARMS_PRESENT+1;
    #  <PARAMETER HEAD>  ::=  (
       ;
    #  <PARAMETER HEAD>  ::=  <PARAMETER HEAD>  <IDENTIFIER>  ,
       PARMS_PRESENT=PARMS_PRESENT+1;
    #  <ASSIGN LIST>  ::=  <ASSIGN>  <PARAMETER LIST>
       ;
    #  <ASSIGN>  ::=  ASSIGN
       if CONTEXT=PARM_CONTEXT: CONTEXT=ASSIGN_CONTEXT;
       ELSE ASSIGN_ARG_LIST=TRUE;
    
    #  <DECLARE ELEMENT>  ::=  <DECLARE STATEMENT>
       DO;
          STMT_TYPE = DECL_STMT_TYPE;
          if SIMULATING: STAB_HDR();
          EMIT_SMRK()(1);
       END;
    
    #  <DECLARE ELEMENT>  ::=  <REPLACE STMT>  ;
       DO;
          STMT_TYPE = REPLACE_STMT_TYPE;
          if SIMULATING: STAB_HDR();
    EMIT_NULL:
          OUTPUT_WRITER;
          EMIT_SMRK()(1);
       END;
    #  <DECLARE ELEMENT>  ::=  <STRUCTURE STMT>
       DO;
          SYT_ADDR(REF_ID_LOC)=STRUC_SIZE;
          REF_ID_LOC=0;
          STMT_TYPE = STRUC_STMT_TYPE;
          if SIMULATING: STAB_HDR();
          GO TO EMIT_NULL;
       END;
    #  <DECLARE ELEMENT>  ::=  EQUATE  EXTERNAL  <IDENTIFIER>  TO
                           <VARIABLE>  ;
       DO;
          I = FIXL(MP + 2);  # EQUATE NAME
          J = SP - 1;
          if SYT_CLASS(FIXL(J)) = TEMPLATE_CLASS:
             J = FIXV(J);  # ROOT PTR SAVED IN FIXV FOR STRUCS
          ELSE J = FIXL(J);  # SYT PTR IN FIXL FOR OTHERS
          SYT_PTR(I) = J;  # POINT AT REFERENCED ITEM
          if (SYT_FLAGS(BLOCK_SYTREF(NEST)) & EXTERNAL_FLAG) != 0:
          SYT_FLAGS(I) = SYT_FLAGS(I) | DUMMY_FLAG;  # IGNORE IN TEMPLATES
          if SYT_SCOPE(I) != SYT_SCOPE(J):
             ERROR(d.CLASS_DU, 7, VAR(SP - 1));
          if SYT_TYPE(J) > MAJ_STRUC:
             ERROR(d.CLASS_DU, 8, VAR(SP - 1));
          if (SYT_FLAGS(J) & ILL_EQUATE_ATTR) != 0:
             ERROR(d.CLASS_DU, 9, VAR(SP - 1));
          if (SYT_FLAGS(J) & AUTO_FLAG) != 0:
             if (SYT_FLAGS(BLOCK_SYTREF(NEST)) & REENTRANT_FLAG) != 0:
             ERROR(d.CLASS_DU, 13, VAR(SP - 1));
          TEMP = PTR(SP - 1);
          if (VAL_P(TEMP) & "40") != 0:
             ERROR(d.CLASS_DU, 10, VAR(SP - 1));  # PREC MODIFIER
          if (VAL_P(TEMP) & "80") != 0:
             ERROR(d.CLASS_DU, 11, VAR(MP + 2));  # SUBBIT
          if KILL_NAME(SP - 1):
             ERROR(d.CLASS_DU, 14, VAR(MP + 2));  # NAME(.)
          ELSE RESET_ARRAYNESS();
          if (VAL_P(TEMP) & "20") != 0:
             HALMAT_FIX_PIPTAGS(INX(TEMP), 0, 1);
          DELAY_CONTEXT_CHECK, NAMING = FALSE;
          if SYT_PTR(J) < 0:
             ERROR(d.CLASS_DU, 12, VAR(SP - 1));
          HALMAT_POP(XEINT, 2, 0, PSEUDO_TYPE(TEMP));
          HALMAT_PIP(FIXL(MP + 2), XSYT, 0, 0);
          HALMAT_PIP(LOC_P(TEMP), PSEUDO_FORM(TEMP), 0, 0);
          CHECK_ARRAYNESS();
          PTR_TOP = PTR(SP - 1) - 1;
          STMT_TYPE = EQUATE_TYPE;
          if SIMULATING: STAB_HDR();
          GO TO EMIT_NULL;
       END;
    #  <REPLACE STMT>  ::=  REPLACE  <REPLACE HEAD>  BY  <TEXT>
       DO;
          CONTEXT = 0;
          MAC_NUM = FIXL(MPP1);
          SYT_ADDR(MAC_NUM) = START_POINT;
          VAR_LENGTH(MAC_NUM) = MACRO_ARG_COUNT;
          EXTENT(MAC_NUM) = REPLACE_TEXT_PTR;
          MACRO_ARG_COUNT = 0;
       END;
    #  <REPLACE HEAD>  ::=  <IDENTIFIER>
       DO;
    INIT_MACRO:
          CONTEXT = 0;
          MACRO_TEXT(FIRST_FREE) = "EF";  # INITIALIZE TO NULL
       END;
    #  <REPLACE HEAD>  ::=  <IDENTIFIER>  (  <ARG LIST>  )
       DO;
          NOSPACE;
          GO TO INIT_MACRO;
    
       END;
    #  <ARG LIST>  ::=  <IDENTIFIER>
    NEXT_ARG:DO;
          MACRO_ARG_COUNT = MACRO_ARG_COUNT + 1 ;
          if MACRO_ARG_COUNT > MAX_PARAMETER: DO;
             ERROR(d.CLASS_IR,10);
          END;
       END;
    #  <ARG LIST>  ::=  <ARG LIST>  ,  <IDENTIFIER>
       GO TO NEXT_ARG;
    #  <TEMPORARY STMT>  ::=  TEMPORARY  <DECLARE BODY>  ;
       DO;
          if SIMULATING: STMT_TYPE = TEMP_TYPE;
          STAB_HDR();
          GO TO DECL_STAT;
       END;
    #  <DECLARE STATEMENT>  ::=  DECLARE  <DECLARE BODY>  ;
       DO;
          if PARMS_PRESENT<=0: DO;
             PARMS_WATCH=FALSE;
             if EXTERNALIZE: EXTERNALIZE=4;
          END;
    DECL_STAT:
          FACTORING=TRUE;
          if IC_FOUND>0: DO;
             IC_LINE=INX(IC_PTR1);
             PTR_TOP=IC_PTR1-1;
          END;
          IC_FOUND=0;
          if ATTR_LOC>1: DO;
             OUTPUT_WRITER(LAST_WRITE,ATTR_LOC-1);
             if ^ATTR_FOUND: DO;
                if (GRAMMAR_FLAGS(1)&ATTR_BEGIN_FLAG)!=0:
                   INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT+INDENT_INCR;
             END;
             ELSE if INDENT_LEVEL=SAVE_INDENT_LEVEL:
                INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT;
             OUTPUT_WRITER(ATTR_LOC,STMT_PTR);
          END;
          ELSE OUTPUT_WRITER(LAST_WRITE,STMT_PTR);
          INDENT_LEVEL=SAVE_INDENT_LEVEL;
          LAST_WRITE,SAVE_INDENT_LEVEL=0;
       END;
    #  <DECLARE BODY>  ::=  <DECLARATION LIST>
       ;
    
    #  <DECLARE BODY>  ::=  <ATTRIBUTES> , <DECLARATION LIST>
       DO;
          DO I = 0 TO FACTOR_LIM;
             FACTORED_TYPE(I) = 0;
          END;
          FACTOR_FOUND = FALSE;
       END;
    
    #  <DECLARATION LIST>  ::=  <DECLARATION>
       DO;
          SAVE_INDENT_LEVEL = INDENT_LEVEL;
          ATTR_FOUND = FALSE;
          LAST_WRITE = 0;
       END;
    
    #  <DECLARATION LIST>  ::=  <DCL LIST ,>   <DECLARATION>
       ;
    
    #  <DCL LIST ,>  ::=  <DECLARATION LIST>  ,
       DO;
          if ATTR_FOUND:
             DO;
             if ATTR_LOC >= 0:
                DO;
                if ATTR_LOC != 0:
                   DO;
                   OUTPUT_WRITER(LAST_WRITE, ATTR_LOC - 1);
                   if INDENT_LEVEL = SAVE_INDENT_LEVEL:
                      INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT;
                END;
                OUTPUT_WRITER(ATTR_LOC, STMT_PTR);
                LAST_WRITE = 0;
             END;
          END;
          ELSE
             DO;
             ATTR_FOUND = TRUE;
             if (GRAMMAR_FLAGS(1) & ATTR_BEGIN_FLAG) != 0:
                DO;  # <ARRAY, TYPE, & ATTR> FACTORED
                OUTPUT_WRITER(0, STACK_PTR(MP) - 1);
                LAST_WRITE = STACK_PTR(MP);
                INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT+INDENT_INCR;
                if ATTR_LOC >= 0:
                   DO;
                   OUTPUT_WRITER(STACK_PTR(MP), STMT_PTR);
                   LAST_WRITE = 0;
                END;
             END;
             ELSE
                DO;
                if ATTR_LOC >= 0:
                   DO;
                   OUTPUT_WRITER;
                   LAST_WRITE = 0;
                   INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT;
                END;
             END;
          END;
          if INIT_EMISSION: DO;
             INIT_EMISSION=FALSE;
             EMIT_SMRK()(0);
          END;
       END;
    
    #  <DECLARE GROUP>  ::=  <DECLARE ELEMENT>
       ;
    #  <DECLARE GROUP>  ::=  <DECLARE GROUP>  <DECLARE ELEMENT>
       ;
    #  <STRUCTURE STMT>  ::=  STRUCTURE <STRUCT STMT HEAD> <STRUCT STMT TAIL>
       DO;
          FIXV(SP)=0;
          FIXL(MP)=FIXL(MPP1);
          FIXV(MP)=FIXV(MPP1);
          FIXL(MPP1)=FIXL(SP);
          FACTORING = TRUE;
          GO TO STRUCT_GOING_UP;
       END;
    #  <STRUCT STMT HEAD>  ::=  <IDENTIFIER>  :  <LEVEL>
       DO;
    NO_ATTR_STRUCT:
          BUILDING_TEMPLATE = TRUE;
          ID_LOC,FIXL(MPP1)=FIXL(MP);
          STRUC_SIZE=0;
          REF_ID_LOC=ID_LOC;
          if FIXV(SP)>1: ERROR(d.CLASS_DQ,1);
          FIXV(MP)=1;
          SYT_CLASS(ID_LOC) = TEMPLATE_CLASS;
          SYT_TYPE(ID_LOC) = TEMPL_NAME;
          if (ATTRIBUTES & ILL_TEMPL_ATTR) != 0 |
             (ATTRIBUTES2 & NONHAL_FLAG) != 0: DO;
             ERROR(d.CLASS_DA,22,SYT_NAME(ID_LOC));
             ATTRIBUTES = ATTRIBUTES & ^ILL_TEMPL_ATTR;
             ATTRIBUTES2 = ATTRIBUTES2 & ^NONHAL_FLAG;
             DO_INIT=FALSE;
          END;
          if (ATTRIBUTES & ALDENSE_FLAGS) = 0:
             ATTRIBUTES = ATTRIBUTES | (DEFAULT_ATTR & ALDENSE_FLAGS);
          SYT_FLAGS(ID_LOC)=SYT_FLAGS(ID_LOC)|ATTRIBUTES;
          HALMAT_INIT_CONST();
          DO I=0 TO FACTOR_LIM;
             TYPE(I)=0;
          END;
          SAVE_INDENT_LEVEL = INDENT_LEVEL;
          if STACK_PTR(SP) > 0:
             OUTPUT_WRITER(0, STACK_PTR(SP) - 1);
          LAST_WRITE = STACK_PTR(SP);
        INDENT_LEVEL = SAVE_INDENT_LEVEL + INDENT_INCR;  # IN BY ONE LEVEL
          GO TO STRUCT_GOING_DOWN;
       END;
    #  <STRUCT STMT HEAD>  ::=  <IDENTIFIER> <MINOR ATTR LIST> : <LEVEL>
       GO TO NO_ATTR_STRUCT;
    #  <STRUCT STMT HEAD> ::= <STRUCT STMT HEAD> <DECLARATION> , <LEVEL>
       DO;
    STRUCT_GOING_UP:
          if (SYT_FLAGS(ID_LOC)&DUPL_FLAG)!=0:  DO;
             SYT_FLAGS(ID_LOC)=SYT_FLAGS(ID_LOC)&(^DUPL_FLAG);
             S=SYT_NAME(ID_LOC);
             TEMP_SYN=SYT_LINK1(FIXL(MP));
             DO WHILE TEMP_SYN!=ID_LOC;
                if S=SYT_NAME(TEMP_SYN): DO;
                   ERROR(d.CLASS_DQ,9,S);
                   S='';
                END;
                TEMP_SYN=SYT_LINK2(TEMP_SYN);
             END;
          END;
          if FIXV(SP)>FIXV(MP): DO;
             if FIXV(SP)>FIXV(MP)+1: ERROR(d.CLASS_DQ,2);
             FIXV(MP)=FIXV(MP)+1;
             if (TYPE|CLASS)!=0:
              ERROR(d.CLASS_DT, 5, SYT_NAME(ID_LOC));  # TYPE NOT LEGAL
             if (ATTRIBUTES&ILL_MINOR_STRUC)!=0 | NAME_IMPLIED |
                (ATTRIBUTES2 & NONHAL_FLAG)!=0: DO;
                ERROR(d.CLASS_DA, 20, SYT_NAME(ID_LOC));
                ATTRIBUTES = ATTRIBUTES & (^ILL_MINOR_STRUC);
                ATTRIBUTES2 = ATTRIBUTES2 & (^NONHAL_FLAG);
                NAME_IMPLIED=FALSE;
                DO_INIT = 0;
             END;
             if N_DIM != 0: DO;  # DR 145
                ERROR(d.CLASS_DA, 21, SYT_NAME(ID_LOC));
                N_DIM = 0;
                ATTRIBUTES = ATTRIBUTES & (^ARRAY_FLAG);
             END;
             SYT_CLASS(ID_LOC) = TEMPLATE_CLASS;
             TYPE = MAJ_STRUC;
             if (ATTRIBUTES & ALDENSE_FLAGS) = 0:
              ATTRIBUTES = ATTRIBUTES | (SYT_FLAGS(FIXL(MP)) & ALDENSE_FLAGS);
    # GIVE ALIGNED/DENSE OF PARENT IF NOT LOCALLY SPECIFIED
             if (ATTRIBUTES&RIGID_FLAG)=0:
                ATTRIBUTES=ATTRIBUTES|(SYT_FLAGS(FIXL(MP))&RIGID_FLAG);
             SET_SYT_ENTRIES();
             if STACK_PTR(SP) > 0:
                OUTPUT_WRITER(LAST_WRITE, STACK_PTR(SP) - 1);
             LAST_WRITE = STACK_PTR(SP);
             INDENT_LEVEL = SAVE_INDENT_LEVEL + (FIXV(MP) * INDENT_INCR);
    STRUCT_GOING_DOWN:
             PUSH_INDIRECT(1);
             LOC_P(PTR_TOP)=FIXL(MP);
             SYT_LINK1(FIXL(MPP1))=FIXL(MPP1)+1;
             FIXL(MP)=FIXL(MPP1);
          END;
          ELSE DO;
             TEMP_SYN=FIXL(MPP1);
             FIXL(SP)=FIXL(MP);
             DO WHILE FIXV(SP)<FIXV(MP);
                SYT_LINK2(FIXL(MPP1))=-FIXL(MP);
                FIXL(MPP1)=FIXL(MP);
                FIXL(MP)=LOC_P(PTR_TOP);
                PTR_TOP=PTR_TOP-1;
                FIXV(MP)=FIXV(MP)-1;
             END;
             if TYPE=0: TYPE=DEFAULT_TYPE;
             ELSE if TYPE=MAJ_STRUC: if ^NAME_IMPLIED:
                if STRUC_PTR=REF_ID_LOC: DO;
                ERROR(d.CLASS_DT,6);
                SYT_FLAGS(REF_ID_LOC)=SYT_FLAGS(REF_ID_LOC)|EVIL_FLAG;
             END;
             if CLASS!=0: DO;
                if NAME_IMPLIED: DO;
                   ATTRIBUTES=ATTRIBUTES|DEFINED_LABEL;
             if TYPE=PROC_LABEL: ERROR(d.CLASS_DA,14,SYT_NAME(ID_LOC));
                ELSE if CLASS=2: ERROR(d.CLASS_DA,13,SYT_NAME(ID_LOC));
                END;
                ELSE DO;
                   ERROR(d.CLASS_DT,7,SYT_NAME(ID_LOC));
                   CLASS=0;
                   if TYPE>ANY_TYPE: TYPE=DEFAULT_TYPE;
                END;
             END;
             CHECK_CONSISTENCY();
             if (ATTRIBUTES&ILL_TERM_ATTR(NAME_IMPLIED))!=0 |
                (ATTRIBUTES2&NONHAL_FLAG)!=0: DO;
                ERROR(d.CLASS_DA, 23, SYT_NAME(ID_LOC));
    #  ILL_NAME_ATTR MUST BE SUBSET OF ILL_TERM_ATTR
                ATTRIBUTES=(^ILL_TERM_ATTR(NAME_IMPLIED))&ATTRIBUTES;
                ATTRIBUTES2=(^NONHAL_FLAG)&ATTRIBUTES2;
                DO_INIT=FALSE;
             END;
             SYT_CLASS(ID_LOC)=TEMPLATE_CLASS+CLASS;
             if TYPE=MAJ_STRUC: CHECK_STRUC_CONFLICTS();
             ELSE if TYPE=EVENT_TYPE: CHECK_EVENT_CONFLICTS();
             if (ATTRIBUTES&SD_FLAGS)=0:
                if (TYPE>=MAT_TYPE)&(TYPE<=INT_TYPE):
                ATTRIBUTES=ATTRIBUTES|(DEFAULT_ATTR&SD_FLAGS);
             if (ATTRIBUTES & ALDENSE_FLAGS) = 0:
                if (^NAME_IMPLIED) & ((ATTRIBUTES&ARRAY_FLAG)=0) &
                   (TYPE=BIT_TYPE):
                   ATTRIBUTES=ATTRIBUTES|(SYT_FLAGS(FIXL(SP))&ALDENSE_FLAGS);
                ELSE
                  ATTRIBUTES=ATTRIBUTES|ALIGNED_FLAG;
             if (ATTRIBUTES&RIGID_FLAG)=0:
                ATTRIBUTES=ATTRIBUTES|(SYT_FLAGS(FIXL(SP))&RIGID_FLAG);
             if NAME_IMPLIED: SYT_FLAGS(REF_ID_LOC)=SYT_FLAGS(REF_ID_LOC)
                |MISC_NAME_FLAG;
             SET_SYT_ENTRIES();
             STRUC_SIZE=ICQ_TERM#(ID_LOC)*ICQ_ARRAY#(ID_LOC)+STRUC_SIZE;
             NAME_IMPLIED=FALSE;
             if FIXV(SP)>0: DO;
                SYT_LINK2(FIXL(MPP1))=TEMP_SYN+1;
                if STACK_PTR(SP) > 0:
                   OUTPUT_WRITER(LAST_WRITE, STACK_PTR(SP) - 1);
                LAST_WRITE = STACK_PTR(SP);
                INDENT_LEVEL = SAVE_INDENT_LEVEL + (FIXV(MP) * INDENT_INCR);
             END;
             ELSE DO;
                BUILDING_TEMPLATE=FALSE;
                OUTPUT_WRITER(LAST_WRITE, STMT_PTR);
                INDENT_LEVEL = SAVE_INDENT_LEVEL;
                LAST_WRITE, SAVE_INDENT_LEVEL = 0;
             END;
          END;
       END;
    #  <STRUCT STMT TAIL>  ::=  <DECLARATION>  ;
       ;
    # <STRUCT SPEC> ::= <STRUCT TEMPLATE> <STRUCT SPEC BODY>
       DO;
          STRUC_PTR = FIXL(MP);
          if SYT_TYPE(STRUC_PTR) != TEMPL_NAME:
             SYT_FLAGS(STRUC_PTR) = SYT_FLAGS(STRUC_PTR) | EVIL_FLAG;
          SET_XREF(STRUC_PTR,XREF_REF);
          NOSPACE;
       END;
    # <STRUCT SPEC BODY> ::= - STRUCTURE
       NOSPACE;
    # <STRUCT SPEC BODY> ::= <STRUCT SPEC HEAD> <LITERAL EXP OR*> )
       DO;
          CONTEXT = DECLARE_CONTEXT;
          I = FIXV(MPP1);
          if ^((I > 1) & (I <= ARRAY_DIM_LIM) | (I = -1)): DO;
             ERROR(d.CLASS_DD, 11);
             STRUC_DIM = 2;  # A DEFAULT
          END;
          ELSE STRUC_DIM = I;
       END;
    # <STRUCT SPEC HEAD> ::= - STRUCTURE (
       DO;
          NOSPACE;
          TOKEN_FLAGS(STACK_PTR(MPP1))=TOKEN_FLAGS(STACK_PTR(MPP1))|"20";
       END;
    #  <DECLARATION>  ::=  <NAME ID>
       if ^BUILDING_TEMPLATE: DO;
          if NAME_IMPLIED: ATTR_LOC=STACK_PTR(MP);
          ELSE ATTR_LOC=-1;
          GO TO SPEC_VAR;
       END;
    #  <DECLARATION>  ::=  <NAME ID>  <ATTRIBUTES>
       if ^BUILDING_TEMPLATE: DO;
          if (TOKEN_FLAGS(0)&7)= 7: ATTR_LOC=0;
          ELSE if (TOKEN_FLAGS(1)&7)= 7: ATTR_LOC=1;
               ELSE ATTR_LOC=MAX(0,STACK_PTR(MP));
    SPEC_VAR:
          DO_INIT=TRUE;
          CHECK_CONFLICTS();
          I=SYT_FLAGS(ID_LOC);
          if (I&PARM_FLAGS)!=0: DO;
             PARMS_PRESENT=PARMS_PRESENT-1;
             if PARMS_PRESENT=0 & PARMS_WATCH: COMSUB_END = NDECSY;
             if (ATTRIBUTES&ILL_INIT_ATTR)!=0: DO;
                ERROR(d.CLASS_DI,12,VAR(MP));
                DO_INIT=FALSE;
                ATTRIBUTES=ATTRIBUTES&(^ILL_INIT_ATTR);
             END;
             if CLASS>0&(^NAME_IMPLIED): DO;
                ERROR(d.CLASS_D,1,VAR(MP));
                NONHAL,CLASS=0;
                if TYPE>ANY_TYPE: TYPE=DEFAULT_TYPE;
             END;
    #  REMOTE NOW OK FOR ASSIGN PARMS & IGNORED FOR INPUT PARMS
    #  SO REMOVE D14 ERROR MESSAGE.
          END;
          ELSE if PARMS_WATCH: ERROR(d.CLASS_D,15);
          if TYPE=EVENT_TYPE: CHECK_EVENT_CONFLICTS();
          if ^NAME_IMPLIED: DO;
             if NONHAL>0: DO;
                if TYPE=PROC_LABEL|CLASS=2: DO;
                   ATTRIBUTES=ATTRIBUTES|EXTERNAL_FLAG|DEFINED_LABEL;
                   SYT_ARRAY(ID_LOC)=NONHAL|"FF00";
                   GO TO MODE_CHECK;
                END;
                ELSE DO;
                   ERROR(d.CLASS_D,11,VAR(MP));
                   #   DISCONNECT SYT_FLAGS WITH NONHAL
                   #   THIS ALSO DISCONNECTS ATTRIBUTES WITH NONHAL
                   SYT_FLAGS2(ID_LOC) = SYT_FLAGS2(ID_LOC) &
                      (^NONHAL_FLAG);
                END;
             END;
             ELSE if CLASS=2: DO;
    MODE_CHECK:
             if BLOCK_MODE(NEST)=CMPL_MODE: ERROR(d.CLASS_D,2,VAR(MP));
             END;
             ELSE if CLASS=1: DO;
                if TYPE=TASK_LABEL: DO;
                   if NEST>1|BLOCK_MODE(1)!=PROG_MODE:
                      ERROR(d.CLASS_PT,1);
                END;
                ELSE DO;
                   ERROR(d.CLASS_DN,1,VAR(MP));
                   CLASS=0;
                   TYPE=DEFAULT_TYPE;
                END;
             END;
             if CLASS!=0: DO;
                if (ATTRIBUTES&ILL_INIT_ATTR)!=0: DO;
                   ERROR(d.CLASS_DI,13,VAR(MP));
                   ATTRIBUTES=ATTRIBUTES&(^ILL_INIT_ATTR);
                   DO_INIT=FALSE;
                END;
                if TEMPORARY_IMPLIED: DO;
                   ERROR(d.CLASS_D,8,VAR(MP));
                   CLASS=0;
                   if TYPE>ANY_TYPE: TYPE=DEFAULT_TYPE;
                END;
             END;
             ELSE DO;
                if TEMPORARY_IMPLIED: DO;
                   if (ATTRIBUTES&ILL_TEMPORARY_ATTR)!=0 |
                      (ATTRIBUTES2&NONHAL_FLAG)!=0: DO;
                      ERROR(d.CLASS_D,8,VAR(MP));
                      ATTRIBUTES=ATTRIBUTES&(^ILL_TEMPORARY_ATTR);
                      ATTRIBUTES2=ATTRIBUTES2&(^NONHAL_FLAG);
                      DO_INIT=FALSE;
                   END;
                END;
                ELSE DO;
    FIX_AUTSTAT:
                   if (ATTRIBUTES&ALDENSE_FLAGS)=0:
                      ATTRIBUTES=ATTRIBUTES|(DEFAULT_ATTR&ALDENSE_FLAGS);
                   if BLOCK_MODE(NEST)!=CMPL_MODE:
                      if (I&PARM_FLAGS)=0:
                      if (ATTRIBUTES&AUTSTAT_FLAGS)=0:
                      ATTRIBUTES=ATTRIBUTES|(DEFAULT_ATTR&AUTSTAT_FLAGS);
                END;
             END;
          END;
          ELSE DO;
         # ADD ILLEGAL TEMP ATTRIBUTE CHECKING FROM ABOVE FOR NAME TEMPS TOO
             if TEMPORARY_IMPLIED: DO;
                if CLASS!=0: DO;
                   ERROR(d.CLASS_D,8,VAR(MP));
                   CLASS=0;
                   if TYPE>ANY_TYPE: TYPE=DEFAULT_TYPE;
                END;
         # ONLY DIFFERENCE FOR NAME TEMPS IS THAT REMOTE IS LEGAL
                ELSE if (((ATTRIBUTES&ILL_TEMPORARY_ATTR)!=0) &
                         ((ATTRIBUTES&ILL_TEMPORARY_ATTR)!=REMOTE_FLAG)) |
                   (ATTRIBUTES2&NONHAL_FLAG)!=0: DO;
                   ERROR(d.CLASS_D,8,VAR(MP));
                   ATTRIBUTES=ATTRIBUTES&(^ILL_TEMPORARY_ATTR);
                   ATTRIBUTES2=ATTRIBUTES2&(^NONHAL_FLAG);
                   DO_INIT=FALSE;
                END;
             END;
             if (ATTRIBUTES&ILL_NAME_ATTR)!=0 |
                (ATTRIBUTES2&NONHAL_FLAG)!=0: DO;
                ERROR(d.CLASS_D,12,VAR(MP));
                ATTRIBUTES=ATTRIBUTES&(^ILL_NAME_ATTR);
                ATTRIBUTES2=ATTRIBUTES2&(^NONHAL_FLAG);
             END;
             if TYPE=PROC_LABEL: ERROR(d.CLASS_DA,14,VAR(MP));
             ELSE if CLASS=2: ERROR(d.CLASS_DA,13,VAR(MP));
             if CLASS>0: ATTRIBUTES=ATTRIBUTES|DEFINED_LABEL;
             GO TO FIX_AUTSTAT;
          END;
          SYT_CLASS(ID_LOC)=VAR_CLASS(CLASS);
          if TYPE=MAJ_STRUC: CHECK_STRUC_CONFLICTS();
         if (ATTRIBUTES&SD_FLAGS)=0: if TYPE>=MAT_TYPE&TYPE<=INT_TYPE:
             ATTRIBUTES=ATTRIBUTES|(DEFAULT_ATTR&SD_FLAGS);
          SET_SYT_ENTRIES();
          NAME_IMPLIED=FALSE;
          if TEMPORARY_IMPLIED: DO;
             ATTR_INDENT=10;
             if DO_CHAIN(DO_LEVEL)=0: DO;
                DO_CHAIN(DO_LEVEL)=ID_LOC;
                HALMAT_POP(XTDCL,1,0,0);
                HALMAT_PIP(ID_LOC,XSYT,0,0);
             END;
             ELSE SYT_LINK1(DO_CHAIN)=ID_LOC;
             DO_CHAIN=ID_LOC;
          END;
          ELSE ATTR_INDENT=8;
    #SET REMOTE ATTRIBUTE FOR ALL NON-NAME #D DATA WHEN THE
    #DATA_REMOTE DIRECTIVE IS IN EFFECT
    #(MUST NOT BE AUTOMATIC OR A PARAMETER TO BE #D DATA.)
          if DATA_REMOTE: DO;
             if ((SYT_FLAGS(ID_LOC) & NAME_FLAG) = 0) &
                ((SYT_FLAGS(ID_LOC) & TEMPORARY_FLAG) = 0) &
               # DON'T SET REMOTE FLAG FOR TASKS, FUNCTIONS,
               # OR PROCEDURES
               (SYT_TYPE(ID_LOC) != TASK_LABEL) &
               (SYT_TYPE(ID_LOC) != PROC_LABEL) &
               (SYT_CLASS(ID_LOC) != FUNC_CLASS) &
                # PART 1. SET THE REMOTE FLAG IF DATA
                # IS DECLARED IN A NON "EXTERNAL" BLOCK.
               ((SYT_FLAGS(BLOCK_SYTREF(NEST)) & EXTERNAL_FLAG)=0) &
               ^(((SYT_FLAGS(ID_LOC) & AUTO_FLAG) != 0) &
                 ((SYT_FLAGS(BLOCK_SYTREF(NEST)) & REENTRANT_FLAG) != 0)) &
                ((SYT_FLAGS(ID_LOC) & PARM_FLAGS) = 0): DO;
                 if (SYT_FLAGS(ID_LOC) & REMOTE_FLAG) != 0:
                    ERROR(d.CLASS_XR,3);
                 if SYT_TYPE(ID_LOC) = EVENT_TYPE:
                    ERROR(d.CLASS_DA,9);
                 SYT_FLAGS(ID_LOC) = SYT_FLAGS(ID_LOC) | REMOTE_FLAG;
             END;
          END;
          ELSE if SDL_OPTION &
                  ((SYT_FLAGS(ID_LOC) & NAME_FLAG)=0) &
                  ((SYT_FLAGS(ID_LOC) & PARM_FLAGS)=0) &
                  ((SYT_FLAGS(ID_LOC) & REMOTE_FLAG)!=0)
              : ERROR(d.CLASS_XR, 5);
          if ((SYT_FLAGS(ID_LOC) & NAME_FLAG)=0) &
             ((SYT_FLAGS(ID_LOC) & INPUT_PARM)!=0) &
             ((SYT_FLAGS(ID_LOC) & REMOTE_FLAG)!=0): DO;
               SYT_FLAGS(ID_LOC)=SYT_FLAGS(ID_LOC) & ^REMOTE_FLAG;
               ERROR(d.CLASS_YD, 100);
          END;
       END;
    #  <NAME ID>   ::=  <IDENTIFIER>
       ID_LOC=FIXL(MP);
    #  <NAME ID>  ::=  <IDENTIFIER> NAME
       DO;
         # REMOVED DN2 ERROR
          NAME_IMPLIED=TRUE;
          ID_LOC=FIXL(MP);
       END;
    # <ATTRIBUTES> ::= <ARRAY SPEC> <TYPE & MINOR ATTR>
       GO TO CHECK_ARRAY_SPEC;
    
    #  <ATTRIBUTES> ::= <ARRAY SPEC>
    CHECK_ARRAY_SPEC:
       DO;
          if N_DIM > 1:
             if STARRED_DIMS > 0: DO;
             ERROR(d.CLASS_DD, 6);
             DO I = 0 TO N_DIM - 1;
                if S_ARRAY(I) = -1:
                   S_ARRAY(I) = 2;  # DEFAULT
             END;
          END;
          GO TO MAKE_ATTRIBUTES;
       END;
    
    #  <ATTRIBUTES> ::= <TYPE & MINOR ATTR>
       DO;
    MAKE_ATTRIBUTES:
          GRAMMAR_FLAGS(STACK_PTR(MP)) =
             GRAMMAR_FLAGS(STACK_PTR(MP)) | ATTR_BEGIN_FLAG;
          CHECK_CONSISTENCY();
          if FACTORING:
             DO;
             DO I = 0 TO FACTOR_LIM;
                FACTORED_TYPE(I) = TYPE(I);
                TYPE(I) = 0;
             END;
             FACTOR_FOUND = TRUE;
             if FACTORED_IC_FND:
                DO;
                IC_FOUND = 1;  # FOR HALMAT_INIT_CONST
                IC_PTR1 = FACTORED_IC_PTR;
             END;
          END;
       END;
    
    #  <ARRAY SPEC> ::= <ARRAY HEAD> <LITERAL EXP OR *> )
       DO;
          CONTEXT = DECLARE_CONTEXT;
          GO TO ARRAY_SPEC;
       END;
    #  <ARRAY SPEC>  ::=  FUNCTION
       CLASS=2;
    #  <ARRAY SPEC>  ::=  PROCEDURE
       DO;
          TYPE=PROC_LABEL;
          CLASS=1;
       END;
    #  <ARRAY SPEC>  ::= PROGRAM
       DO;
          TYPE=PROG_LABEL;
          CLASS=1;
       END;
    #  <ARRAY SPEC>  ::=  TASK
       DO;
          TYPE=TASK_LABEL;
          CLASS=1;
       END;
    #  <ARRAY HEAD> ::= ARRAY (
       DO;
          STARRED_DIMS, N_DIM = 0;
          DO I = 0 TO N_DIM_LIM;
             S_ARRAY(I) = 0;
          END;
          FIXL(SP),FIXV(SP)=ARRAY_FLAG;
          GO TO INCORPORATE_ATTR;
       END;
    
    #  <ARRAY HEAD> ::= <ARRAY HEAD> <LITERAL_EXP OR *> ,
    ARRAY_SPEC:
       DO;
          if N_DIM >= N_DIM_LIM:
             ERROR(d.CLASS_DD, 3);
          ELSE DO;
             K = 2;  # A DEFAULT
             I = FIXV(MPP1);
             if ^(I > 1 & I <= ARRAY_DIM_LIM | I = -1):
                ERROR(d.CLASS_DD, 1);
             ELSE K = I;
             if K = -1: STARRED_DIMS = STARRED_DIMS + 1;
             S_ARRAY(N_DIM) = K;
             N_DIM = N_DIM + 1;
          END;
       END;
    
    #  <TYPE & MINOR ATTR> ::= <TYPE SPEC>
       GO TO SPEC_TYPE;
    
    #  <TYPE & MINOR ATTR> ::= <TYPE SPEC> <MINOR ATTR LIST>
       DO;
    SPEC_TYPE:
          if CLASS: DO;
             ERROR(d.CLASS_DC,1);
             CLASS=0;
          END;
       END;
    #  <TYPE & MINOR ATTR> ::= <MINOR ATTR LIST>
       ;
    
    #  <TYPE SPEC> ::= <STRUCT SPEC>
       TYPE = MAJ_STRUC;
    
    #  <TYPE SPEC>  ::=  <BIT SPEC>
       ;
    #  <TYPE SPEC>  ::=  <CHAR SPEC>
       ;
    #  <TYPE SPEC>  ::=  <ARITH SPEC>
       ;
    #  <TYPE SPEC>  ::=  EVENT
       TYPE=EVENT_TYPE;
    
    #  <BIT SPEC>  ::=  BOOLEAN
       DO;
          TYPE = BIT_TYPE;
          BIT_LENGTH = 1;  # BOOLEAN
       END;
    
    
    #  <BIT SPEC>  ::=  BIT  (  <LITERAL EXP OR *>  )
       DO;
          NOSPACE;
          CONTEXT = DECLARE_CONTEXT;
          J=FIXV(MP+2);
          K = DEF_BIT_LENGTH;
          if J = -1: ERROR(d.CLASS_DS, 4);  # "*" ILLEGAL
          ELSE if (J ^> 0) | (J > BIT_LENGTH_LIM):
             ERROR(d.CLASS_DS, 1);
          ELSE K = J;
          TYPE = BIT_TYPE;
          BIT_LENGTH = K;
       END;
    
    
    #  <CHAR SPEC>  ::=  CHARACTER  (  <LITERAL EXP OR *>  )
       DO;
          NOSPACE;
          CONTEXT = DECLARE_CONTEXT;
          J=FIXV(MP+2);
          K = DEF_CHAR_LENGTH;
          if J=-1: K=J;
          ELSE if (J ^> 0) | (J > CHAR_LENGTH_LIM):
             ERROR(d.CLASS_DS, 2);
          ELSE K = J;
          CHAR_LENGTH = K;
          TYPE = CHAR_TYPE;
       END;
    
    #  <ARITH SPEC>  ::=  <PREC SPEC>
       DO;
          ATTR_MASK = ATTR_MASK | FIXL(MP);
          ATTRIBUTES = ATTRIBUTES | FIXV(MP);
       END;
    
    #  <ARITH SPEC>  ::=  <SQ DQ NAME>
       ;
    
    #  <ARITH SPEC>  ::=  <SQ DQ NAME>  <PREC SPEC>
       DO;
          ATTR_MASK = ATTR_MASK | FIXL(SP);
          ATTRIBUTES = ATTRIBUTES | FIXV(SP);
       END;
    
    #  <SQ DQ NAME> ::= <DOUBLY QUAL NAME HEAD> <LITERAL EXP OR *> )
       DO;
          CONTEXT = DECLARE_CONTEXT;
          I = FIXV(MPP1);  # VALUE
          TYPE = FIXL(MP);
          if TYPE = VEC_TYPE:
             DO;
             if I = -1:
                DO;
                ERROR(d.CLASS_DD, 7);
                I = 3;
             END;
             ELSE if (I ^> 1) | (I > VEC_LENGTH_LIM):
                DO;
                ERROR(d.CLASS_DD, 5);
                I = 3;
             END;
             VEC_LENGTH = I;
          END;
          ELSE  # MATRIX
             DO;
             if I = -1:
                DO;
                ERROR(d.CLASS_DD,9);
                I = 3;
             END;
             ELSE if (I ^> 1) | (I > MAT_DIM_LIM):
                DO;
                ERROR(d.CLASS_DD, 4);
                I = 3;
             END;
             MAT_LENGTH = SHL(FIXV(MP), 8) + (I & "FF");
          END;
       END;
    
    #  <SQ DQ NAME> ::= INTEGER
       TYPE = INT_TYPE;
    
    #  <SQ DQ NAME> ::= SCALAR
       TYPE = SCALAR_TYPE;
    
    #  <SQ DQ NAME> ::= VECTOR
       DO;
          TYPE = VEC_TYPE;
          VEC_LENGTH = DEF_VEC_LENGTH;
       END;
    
    #  <SQ DQ NAME> ::= MATRIX
       DO;
          TYPE = MAT_TYPE;
          MAT_LENGTH = DEF_MAT_LENGTH;
       END;
    
    #  <DOUBLY QUAL NAME HEAD> ::= VECTOR (
       DO;
          NOSPACE;
          FIXL(MP) = VEC_TYPE;
       END;
    
    #  <DOUBLY QUAL NAME HEAD>  ::=  MATRIX  (  <LITERAL EXP OR *>  ,
       DO;
          NOSPACE;
          FIXL(MP) = MAT_TYPE;
          I=FIXV(MP+2);
          FIXV(MP) = 3;  # DEFAULT IF BAD SPEC FOLLOWS
          if I = -1: ERROR(d.CLASS_DD, 9);
          ELSE if (I ^> 1) | (I > MAT_DIM_LIM):
             ERROR(d.CLASS_DD, 4);
          ELSE FIXV(MP) = I;
       END;
    
    #  <LITERAL EXP OR *> ::= <ARITH EXP>
       DO;
          PTR_TOP = PTR(MP) - 1;
          CHECK_ARRAYNESS();
          CHECK_IMPLICIT_T();
          if PSEUDO_FORM(PTR(SP)) != XLIT:
             DO;
             ERROR(d.CLASS_VE,1);
             TEMP = 0;
          END;
          ELSE
             DO;
             TEMP = MAKE_FIXED_LIT(LOC_P(PTR(SP)));
             if TEMP = -1:
                TEMP = 0;
          END;
          FIXV(SP) = TEMP;
       END;
    
    #  <LITERAL EXP OR *> ::= *
       FIXV(SP) = -1;
    
    #  <PREC_SPEC> ::= SINGLE
       DO;
          FIXL(MP) = SD_FLAGS;
          FIXV(MP) = SINGLE_FLAG;
          PTR(MP)=1;
       END;
    
    #  <PREC SPEC> ::= DOUBLE
       DO;
          FIXL(MP) = SD_FLAGS;
          FIXV(MP) = DOUBLE_FLAG;
          PTR(MP)=2;
       END;
    
    #  <MINOR ATTR LIST> ::= <MINOR ATTRIBUTE>
       GO TO INCORPORATE_ATTR;
    
    #  <MINOR ATTR LIST> ::= <MINOR ATTR LIST> <MINOR ATTRIBUTE>
       DO;
    INCORPORATE_ATTR:
          if (ATTR_MASK & FIXL(SP)) != 0:
             ERROR(d.CLASS_DA,25);
          ELSE DO;
             ATTR_MASK = ATTR_MASK | FIXL(SP);
             ATTRIBUTES = ATTRIBUTES | FIXV(SP);
          END;
       END;
    
    #  <MINOR ATTRIBUTE> ::= STATIC
       DO;
          I = STATIC_FLAG;
    SET_AUTSTAT:
          if BLOCK_MODE(NEST) = CMPL_MODE:
             ERROR(d.CLASS_DC, 2);
          ELSE DO;
             FIXL(MP) = AUTSTAT_FLAGS;
             FIXV(MP) = I;
          END;
       END;
    
    #  <MINOR ATTRIBUTE> ::= AUTOMATIC
       DO;
          I = AUTO_FLAG;
          GO TO SET_AUTSTAT;
       END;
    
    #  <MINOR ATTRIBUTE> ::= DENSE
       DO;
          if (TYPE=0) | (BUILDING_TEMPLATE & (TYPE=BIT_TYPE) &
             ((ATTRIBUTES&ARRAY_FLAG)=0) &
             (^NAME_IMPLIED)): DO;
             FIXL(MP) = ALDENSE_FLAGS;
             FIXV(MP) = DENSE_FLAG;
          END;
       END;
    
    #  <MINOR ATTRIBUTE> ::= ALIGNED
       DO;
          FIXL(MP) = ALDENSE_FLAGS;
          FIXV(MP) = ALIGNED_FLAG;
       END;
    
    #  <MINOR ATTRIBUTE> ::= ACCESS
       DO;
          if BLOCK_MODE(NEST) = CMPL_MODE:
             DO;
             FIXL(MP) = ACCESS_FLAG;
             FIXV(MP) = ACCESS_FLAG;
             ACCESS_FOUND = TRUE;
          END;
          ELSE ERROR(d.CLASS_DC,5);
       END;
    
    #  <MINOR ATTRIBUTE>  ::=  LOCK ( <LITERAL EXP OR *> )
       DO;
          CONTEXT=DECLARE_CONTEXT;
          LOCKp=FIXV(MP+2);
          if LOCKp<0: LOCKp="FF";
          ELSE if LOCKp<1|LOCKp>LOCK_LIM THEN DO;
             ERROR(d.CLASS_DL,3);
             LOCKp="FF";
          END;
          FIXL(MP),FIXV(MP)=LOCK_FLAG;
       END;
    #  <MINOR ATTRIBUTE>  ::=  REMOTE
       DO;
          FIXL(MP),FIXV(MP)=REMOTE_FLAG;
       END;
    #  <MINOR ATTRIBUTE> ::= RIGID
       DO;
          FIXL(MP),FIXV(MP)=RIGID_FLAG;
       END;
    
    #  <MINOR ATTRIBUTE> ::= <INIT/CONST HEAD> <REPEATED CONSTANT> )
       DO;
          PSEUDO_TYPE(PTR(MP)) = 0;   # NO "*"
    DO_QUALIFIED_ATTRIBUTE:
          BI_FUNC_FLAG=FALSE;
          CHECK_IMPLICIT_T();
          CONTEXT = DECLARE_CONTEXT;
         if (NUM_ELEMENTS >= NUM_EL_MAX) | (NUM_ELEMENTS < 1):
            ERROR(d.CLASS_DI,2);
          LOC_P(PTR(MP)) = NUM_ELEMENTS;  # SAVE NUMBER OF ELEMENTS TO SET
          VAL_P(PTR(MP)) = NUM_FL_NO;  # SAVE NUMBER OF GVR'S USED
          PSEUDO_LENGTH(PTR(MP)) = NUM_STACKS;  # INDICATE LENGTH OF LIST
          IC_PTR = PTR(MP);  # SAVE PTR TO THIS I/C LIST
          IC_FND = TRUE;
          if BUILDING_TEMPLATE: PTR_TOP=PTR(MP)-1;
    # KILL STACKS IF STRUCTURE TEMPLATE
       END;
    
    #  <MINOR ATTRIBUTE> ::= <INIT/CONST HEAD> * )
       DO;
          PSEUDO_TYPE(PTR(MP)) = 1;  # INDICATE "*" PRESENT
          GO TO DO_QUALIFIED_ATTRIBUTE;
       END;
    
    #  <MINOR ATTRIBUTE> ::= LATCHED
       DO;
          FIXL(MP) = LATCHED_FLAG;
          FIXV(MP) = LATCHED_FLAG;
       END;
    
    #  <MINOR ATTRIBUTE>  ::=  NONHAL  (  <LEVEL>  )
       DO;
          NONHAL=FIXV(MP+2);
          #   DISCONNECT SYT_FLAGS FROM NONHAL; SET
          #   NONHAL IN SYT_FLAGS2 ARRAY.
          FIXL(MP)=NONHAL_FLAG;
          SYT_FLAGS2(ID_LOC) = SYT_FLAGS2(ID_LOC) | NONHAL_FLAG;
          ATTRIBUTES2 = ATTRIBUTES2 | NONHAL_FLAG;
       END;
    
    #  <INIT/CONST HEAD> ::= INITIAL (
       DO;
          FIXL(MP) = INIT_CONST;
          FIXV(MP) = INIT_FLAG;
    DO_INIT_CONST_HEAD :
          BI_FUNC_FLAG=TRUE;
          PTR(MP)=PUSH_INDIRECT(1);
          NUM_ELEMENTS,NUM_FL_NO=0;
          NUM_STACKS = 1;  #  THIS IS FIRST INDIRECT LOC NEEDED
          PSEUDO_FORM(PTR(MP)) = 0;  #  INDICATE I/C LIST TOP, IE., STRI
          INX(PTR(MP)) = IC_LINE;
       END;
    
    #  <INIT/CONST HEAD> ::= CONSTANT (
       DO;
          FIXL(MP) = INIT_CONST;
          FIXV(MP) = CONSTANT_FLAG;
          GO TO DO_INIT_CONST_HEAD;
       END;
    
    #  <INIT/CONST HEAD>  ::=  <INIT/CONST HEAD>  <REPEATED CONSTANT>  ,
       ;
    #  <REPEATED CONSTANT>  ::=  <EXPRESSION>
       DO;
          TEMP_SYN=0;
          GO TO INIT_ELEMENT;
       END;
    #  <REPEATED CONSTANT>  ::=  <REPEAT HEAD>  <VARIABLE>
       DO;
          TEMP_SYN=1;
          GO TO INIT_ELEMENT;
       END;
    #  <REPEATED CONSTANT>  ::=  <REPEAT HEAD>  <CONSTANT>
       DO;
          TEMP_SYN=1;
    INIT_ELEMENT:
          TEMP=PTR(SP);
          if NAME_PSEUDOS: DO;
             NAME_PSEUDOS=FALSE;
             PSEUDO_TYPE(TEMP)=PSEUDO_TYPE(TEMP)|"80";
             if (VAL_P(TEMP)&"40")!=0: ERROR(d.CLASS_DI,14);
             if (VAL_P(TEMP)&"200")!=0: ERROR(d.CLASS_DI,16);
             # LOOK FOR THE "4000" VAL_P BIT AND EMIT DI16 ERROR.
             # THE VAL_P "4000" BIT INDICATES THE PRESENCE OF A
             # NAME VARIABLE SOMEWHERE INSIDE THE STRUCTURE REFER-
             # ENCE LIST. THE PRESENCE OF A NAME VARIABLE INSIDE
             # A NAME() INITIALIZATION IS A DI16 ERROR CONDITION.
             if (VAL_P(TEMP)&"4000")!=0:
                ERROR(d.CLASS_DI,16);
             if EXT_P(TEMP)!=0: ERROR(d.CLASS_DI,15);
             if (VAL_P(TEMP) & "400") = 0: RESET_ARRAYNESS();
             if SYT_CLASS(FIXL(MP)) = TEMPLATE_CLASS: DO;
                if (((SYT_FLAGS(FIXV(MP)) & ASSIGN_PARM) > 0) |
                   (((SYT_FLAGS(FIXV(MP)) & AUTO_FLAG) != 0) &
                   ((SYT_FLAGS(BLOCK_SYTREF(NEST)) &
                     REENTRANT_FLAG)!=0)))
               :
                     ERROR(d.CLASS_DI,3);
             END;
             ELSE DO;
                if (((SYT_FLAGS(FIXL(MP)) & ASSIGN_PARM) > 0) |
                   (((SYT_FLAGS(FIXL(MP)) & AUTO_FLAG) != 0) &
                   ((SYT_FLAGS(BLOCK_SYTREF(NEST)) &
                     REENTRANT_FLAG)!=0)))
               :
                     ERROR(d.CLASS_DI,3);
             END;
          END;
          ELSE if PSEUDO_FORM(TEMP)!=XLIT: ERROR(d.CLASS_DI,3);
          CHECK_ARRAYNESS();
          SET_INIT(LOC_P(TEMP),2,PSEUDO_FORM(TEMP),PSEUDO_TYPE(TEMP),
             NUM_ELEMENTS);
          NUM_ELEMENTS=NUM_ELEMENTS+1;
          NUM_STACKS=NUM_STACKS+1;
          if TEMP_SYN: DO;
    END_REPEAT_INIT:
             SET_INIT(0,3,0,0,NUM_FL_NO);
             NUM_FL_NO=NUM_FL_NO-1;
             NUM_STACKS=NUM_STACKS+1;
             TEMP_SYN=NUM_ELEMENTS-FIXV(MP);
             IC_LEN(GET_ICQ(FIXL(MP)))=TEMP_SYN;
             NUM_ELEMENTS=INX(PTR(MP))*TEMP_SYN+FIXV(MP);
          END;
          PTR_TOP=PTR(MP)-1;
       END;
    # <REPEATED CONSTANT>  ::=  <NESTED REPEAT HEAD>  <REPEATED CONSTANT>  )
       GO TO END_REPEAT_INIT;
    #  <REPEATED CONSTANT>  ::=  <REPEAT HEAD>
       DO;
          IC_LINE=IC_LINE-1;
          NUM_STACKS=NUM_STACKS-1;
          NUM_FL_NO=NUM_FL_NO-1;
          NUM_ELEMENTS=NUM_ELEMENTS+INX(PTR(MP));
          PTR_TOP=PTR(MP)-1;
       END;
    #  <REPEAT HEAD>  ::=  <ARITH EXP>  #
       DO;
          CHECK_ARRAYNESS();
          if PSEUDO_FORM(PTR(MP))!=XLIT: TEMP_SYN=0;
          ELSE TEMP_SYN=MAKE_FIXED_LIT(LOC_P(PTR(MP)));
          if TEMP_SYN<1: DO;
             ERROR(d.CLASS_DI,1);
             TEMP_SYN=0;
          END;
          if TEMP_SYN>NUM_EL_MAX: TEMP_SYN=NUM_EL_MAX;
          INX(PTR(MP))=TEMP_SYN;
          FIXV(MP)=NUM_ELEMENTS;
          NUM_FL_NO=NUM_FL_NO+1;
          SET_INIT(TEMP_SYN,1,0,0,NUM_FL_NO);
          FIXL(MP)=IC_LINE;
          NUM_STACKS=NUM_STACKS+1;
       END;
    #  <NESTED REPEAT HEAD>  ::=  <REPEAT HEAD>  (
       ;
    #  <NESTED REPEAT HEAD>  ::=  <NESTED REPEAT HEAD>  <REPEATED CONSTANT>  ,
       ;
    #  <CONSTANT>  ::=  <NUMBER>
       DO;
          TEMP_SYN=INT_TYPE;
    DO_CONSTANT:
          PTR(MP)=PUSH_INDIRECT(1);
          PSEUDO_TYPE(PTR(MP))=TEMP_SYN;
          PSEUDO_FORM(PTR(MP))=XLIT;
          LOC_P(PTR(MP))=FIXL(MP);
       END;
    #  <CONSTANT>  ::=  <COMPOUND NUMBER>
       DO;
          TEMP_SYN=SCALAR_TYPE;
          GO TO DO_CONSTANT;
       END;
    #  <CONSTANT>  ::=  <BIT CONST>
       ;
    #  <CONSTANT>  ::=  <CHAR CONST>
       ;
    #  <NUMBER> ::= <SIMPLE NUMBER>
    #  <NUMBER> ::= <LEVEL>
       ; ;
    
    #  <CLOSING> ::= CLOSE
          DO;
          VAR(MP) = '';
    CLOSE_IT:
          INDENT_LEVEL=INDENT_LEVEL-INDENT_INCR;
          XSET"6";
       END;
    
    #  <CLOSING> ::= CLOSE <LABEL>
       DO;
          VAR(MP) = VAR(SP);
          GO TO CLOSE_IT;
       END;
    
    #  <CLOSING> ::= <LABEL DEFINITION> <CLOSING>
       DO;
          SET_LABEL_TYPE(FIXL(MP), STMT_LABEL);
          VAR(MP) = VAR(SP);
       END;
    # <TERMINATOR>::= TERMINATE
       DO;
          FIXL(MP)=XTERM;
          FIXV(MP)="E000";
       END;
    # <TERMINATOR>::= CANCEL
       DO;
          FIXL(MP)=XCANC;
          FIXV(MP)="A000";
       END;
    #  <TERMINATE LIST>  ::=  <LABEL VAR>
       DO;
          EXT_P(PTR(MP))=1;
          GO TO TERM_LIST;
       END;
    #  <TERMINATE LIST>  ::=  <TERMINATE LIST>  ,  <LABEL VAR>
       DO;
          EXT_P(PTR(MP))=EXT_P(PTR(MP))+1;
    TERM_LIST:
          SET_XREF_RORS(SP,FIXV(MP-1));
          PROCESS_CHECK(SP);
       END;
    # <WAIT KEY>::= WAIT
       REFER_LOC=1;
    #  <SCHEDULE HEAD>  ::=  SCHEDULE  <LABEL VAR>
       DO;
          PROCESS_CHECK(MPP1);
          if (SYT_FLAGS(FIXL(MPP1)) & ACCESS_FLAG) != 0:
             ERROR(d.CLASS_PS, 5, VAR(MPP1));
          SET_XREF_RORS(MPP1,"6000");
          REFER_LOC,PTR(MP)=PTR(MPP1);
          INX(REFER_LOC)=0;
       END;
    # <SCHEDULE HEAD>::= <SCHEDULE HEAD> AT <ARITH EXP>
       DO;
          TEMP="1";
          if UNARRAYED_SCALAR(SP): ERROR(d.CLASS_RT,1,'AT');
    SCHEDULE_AT:
          if INX(REFER_LOC)=0: INX(REFER_LOC)=TEMP;
          ELSE DO;
             ERROR(d.CLASS_RT,5);
             PTR_TOP=PTR_TOP-1;
          END;
       END;
    # <SCHEDULE HEAD>::= <SCHEDULE HEAD> IN <ARITH EXP>
       DO;
          TEMP="2";
          if UNARRAYED_SCALAR(SP): ERROR(d.CLASS_RT,1,'IN');
          GO TO SCHEDULE_AT;
       END;
    # <SCHEDULE HEAD>::=<SCHEDULE HEAD> ON <BIT EXP>
       DO;
          TEMP="3";
          if CHECK_EVENT_EXP(SP): ERROR(d.CLASS_RT,3,'ON');
          GO TO SCHEDULE_AT;
       END;
    # <SCHEDULE PHRASE>::=<SCHEDULE HEAD>
    SCHED_PRIO:ERROR(d.CLASS_RT,4,'SCHEDULE');
    # <SCHEDULE PHRASE>::=<SCHEDULE HEAD> PRIORITY (<ARITH EXP>)
       DO;
          if UNARRAYED_INTEGER(SP-1): GO TO SCHED_PRIO;
          INX(REFER_LOC)=INX(REFER_LOC)|"4";
       END;
    #  <SCHEDULE PHRASE>  ::=  <SCHEDULE PHRASE>  DEPENDENT
       INX(REFER_LOC)=INX(REFER_LOC)|"8";
    # <SCHEDULE CONTROL>::= <STOPPING>
       ;
    # <SCHEDULE CONTROL>::= <TIMING>
       ;
    # <SCHEDULE CONTROL>::= <TIMING><STOPPING>
       ;
    #  <TIMING>  ::=  <REPEAT> EVERY <ARITH EXP>
       DO;
          TEMP="20";
    SCHEDULE_EVERY:
          if UNARRAYED_SCALAR(SP): ERROR(d.CLASS_RT,1,'EVERY/AFTER');
          INX(REFER_LOC)=INX(REFER_LOC)|TEMP;
       END;
    #  <TIMING>  ::=  <REPEAT> AFTER <ARITH EXP>
       DO;
          TEMP="30";
          GO TO SCHEDULE_EVERY;
       END;
    #  <TIMING>  ::=  <REPEAT>
       INX(REFER_LOC)=INX(REFER_LOC)|"10";
    #  <REPEAT>  ::=  , REPEAT
       CONTEXT=0;
    # <STOPPING>::=<WHILE KEY><ARITH EXP>
       DO;
          if FIXL(MP)=0: ERROR(d.CLASS_RT,2);
          ELSE if UNARRAYED_SCALAR(SP): ERROR(d.CLASS_RT,1,'UNTIL');
          INX(REFER_LOC)=INX(REFER_LOC)|"40";
       END;
    # <STOPPING>::=<WHILE KEY><BIT EXP>
       DO;
          if CHECK_EVENT_EXP(SP): ERROR(d.CLASS_RT,3,'WHILE/UNTIL');
          TEMP=SHL(FIXL(MP)+2,6);
          INX(REFER_LOC)=INX(REFER_LOC)|TEMP;
       END;
    
       ;  ;  ;  ;  ;          #  INSURANCE
    
       END;     #  OF PART_2
    if (PREV_STMT_NUM != STMT_NUM):
       INCREMENT_DOWN_STMT = FALSE;
    PREV_STMT_NUM = STMT_NUM;
    

