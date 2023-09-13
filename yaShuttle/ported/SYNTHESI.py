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

# Inserts inline BAL instructions.  Obviously less than useless to us.  
# I'm not sure what to do with it.
def INLINE(arg1=None, arg2=None, arg3=None, arg4=None, arg5=None):
    return

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
 /*       LAST_POPp                            XSYT                         */
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
 /*       HALMAT_FIX_PIPp                      START_NORMAL_FCN             */
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
    if (IF_FLAG or ELSE_FLAG) and (PRODUCTION_NUMBER!=144):
        SQUEEZING = FALSE;
        l.CHANGED_STMT_NUM = FALSE;
        if IF_FLAG:
            STMT_NUM = STMT_NUM - 1;
            l.CHANGED_STMT_NUM = TRUE;
        SAVE_SRN2 = SRN(2);
        SRN(2) = SAVE_SRN1;
        SAVE_SRN_COUNT2 = SRN_COUNT(2);
        SRN_COUNT(2) = SAVE_SRN_COUNT1;
        IF_FLAG = FALSE
        ELSE_FLAG = FALSE;#MUST BE BEFORE OUTPUTWR CALL
        OUTPUT_WRITER(SAVE1,SAVE2);
        INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
        if l.CHANGED_STMT_NUM:
            STMT_NUM = STMT_NUM + 1;
        if STMT_PTR > -1:
            LAST_WRITE = SAVE2 + 1;
        SRN(2) = SAVE_SRN2;
        SRN_COUNT(2) = SAVE_SRN_COUNT2;
    
    # THIS CODE IS USED TO ALIGN THE ELSE STATEMENTS CORRECTLY.
    # IF THE CURRENT STATEMENT IS NOT AN ELSE OR A DO, MOVE_ELSE=TRUE.
    if (PRODUCTION_NUMBER != 140) and (PRODUCTION_NUMBER != 54) and \
            (PRODUCTION_NUMBER != 40):
        MOVE_ELSE = TRUE;
    if (SAVE_DO_LEVEL != -1) and (PRODUCTION_NUMBER != 167):
        IFDO_FLAG(SAVE_DO_LEVEL) = FALSE;
        SAVE_DO_LEVEL = -1;
    
    # DO CASE PRODUCTION_NUMBER;
    if PRODUCTION_NUMBER == 0:
        pass
    elif PRODUCTION_NUMBER == 1:
        # <COMPILATION>::= <COMPILE LIST> _|_
        if MP>0:
            ERROR(d.CLASS_P,1);
            STACK_DUMP();
        elif BLOCK_MODE==0: 
            ERROR(d.CLASS_PP,4);
        HALMAT_POP(XXREC,0,0,1);
        ATOMp_FAULT=-1;
        HALMAT_OUT();
        FILE(LITFILE,CURLBLK)=LIT1(0);
        COMPILING=0x80;
        STMT_PTR=STMT_PTR-1;
    elif PRODUCTION_NUMBER == 2:
        # <COMPILE LIST>::=<BLOCK DEFINITION>
        pass;
    elif PRODUCTION_NUMBER == 3:
        # <COMPILE LIST>::= <COMPILE LIST> <BLOCK DEFINITION>
        pass;
    elif PRODUCTION_NUMBER == 4:
        #  <ARITH EXP> ::= <TERM>
        pass;
    elif PRODUCTION_NUMBER == 5:
        #  <ARITH EXP> ::= + <TERM>
        # JUST ABSORB '+' SIGN, IE, RESET INDIRECT STACK
            PTR(MP) = PTR(SP) ;
            NOSPACE();
    elif PRODUCTION_NUMBER == 6:
        #  <ARITH EXP> ::= -1 <TERM>
        if ARITH_LITERAL(SP,0):
            INLINE(0x58,1,0,DW_AD);                   # L   1,DW_AD
            INLINE(0x97,8,0,1,0);                     # XI  0(1),X'80'
            LOC_P(PTR(SP))=SAVE_LITERAL(1,DW_AD);
        else:
            TEMP=PSEUDO_TYPE(PTR(SP));
            HALMAT_TUPLE(XMNEG(TEMP-MAT_TYPE),0,SP,0,0);
            SETUP_VAC(SP,TEMP,PSEUDO_LENGTH(PTR(SP)));
        NOSPACE();
        PTR(MP)=PTR(SP);
    elif PRODUCTION_NUMBER == 7:
        #  <ARITH EXP> ::= <ARITH EXP> + <TERM>
        ADD_AND_SUBTRACT(0);
    elif PRODUCTION_NUMBER == 8:
        #  <ARITH EXP> ::= <ARITH EXP> -1 <TERM>
        ADD_AND_SUBTRACT(1);
    elif PRODUCTION_NUMBER == 9:
        #  <TERM> ::= <PRODUCT>
        pass;
    elif PRODUCTION_NUMBER == 10:
        #  <TERM> ::= <PRODUCT> / <TERM>
        al = ARITH_LITERAL(MP,SP)
        goto_DIV_FAIL = False
        if al:
            if MONITOR(9,4):
                ERROR(d.CLASS_VA,4);
                goto_DIV_FAIL = True;
            else:
                LOC_P(PTR(MP))=SAVE_LITERAL(1,DW_AD);
                PSEUDO_TYPE(PTR(MP))=SCALAR_TYPE;
        if goto_DIV_FAIL or not al:
            goto_DIV_FAIL = False
            if PSEUDO_TYPE(PTR(SP))<SCALAR_TYPE:
                ERROR(d.CLASS_E,1);
            PTR=0;
            PSEUDO_TYPE=SCALAR_TYPE;
            MATCH_SIMPLES(0,SP);
            if PSEUDO_TYPE(PTR(MP))>=SCALAR_TYPE: 
                MATCH_SIMPLES(0,MP);
            TEMP=PSEUDO_TYPE(PTR(MP));
            HALMAT_TUPLE(XMSDV(TEMP-MAT_TYPE),0,MP,SP,0);
            SETUP_VAC(MP,TEMP);
        PTR_TOP=PTR(MP);
    elif PRODUCTION_NUMBER == 11:
        #  <PRODUCT> ::= <FACTOR>
        CROSS_COUNT = 0
        DOT_COUNT = 0
        SCALAR_COUNT = 0
        VECTOR_COUNT = 0
        MATRIX_COUNT = 0;
        TERMP = SP + 1;
        while TERMP > 0:
            TERMP = TERMP - 1;
            if PARSE_STACK(TERMP) == CROSS_TOKEN:
                CROSS_COUNT = CROSS_COUNT + 1;
                FIXV(TERMP) = CROSS;
            elif PARSE_STACK(TERMP) == DOT_TOKEN:
                DOT_COUNT = DOT_COUNT + 1;
                FIXV(TERMP) = DOT;
            elif PARSE_STACK(TERMP) == FACTOR:
                c = 0x0F & PSEUDO_TYPE(PTR(TERMP))
                # DO CASE 0x0F & PSEUDO_TYPE(PTR(TERMP));
                if c == 0: # 0 IS DUMMY
                    pass
                elif c == 1: # 1 IS BIT
                    pass
                elif c == 2: # 2 IS CHAR
                    pass
                elif c == 3:
                    MATRIX_COUNT = MATRIX_COUNT + 1;
                    FIXV(TERMP) = MAT_TYPE;
                elif c == 4:
                    VECTOR_COUNT = VECTOR_COUNT + 1;
                    FIXV(TERMP) = VEC_TYPE;
                elif c in (5, 6):  # TYPE 6 IS INTEGER
                    SCALAR_COUNT = SCALAR_COUNT + 1;
                    FIXV(TERMP) = SCALAR_TYPE;
            else:
                MP    = TERMP + 1;  # IT WAS DECREMENTED AT START OF LOOP
                TERMP = 0;  # GET OUT OF LOOP
        TERMP = MP;
        
        if TERMP == SP: 
            return;
        
        #  MULTIPLY ALL SCALARS, PLACE RESULT AT SCALARP
        SCALARP = 0;
        PP = TERMP - 1;
        while SCALAR_COUNT > 0:
            PP = PP + 1;
            if FIXV(PP) == SCALAR_TYPE:
                SCALAR_COUNT = SCALAR_COUNT - 1;
                if SCALARP == 0: 
                    SCALARP = PP;
                else:
                    MULTIPLY_SYNTHESIZE(SCALARP,PP,SCALARP,0);
        
        # PRODUCTS WITHOUT VECTORS HANDLED HERE
        if VECTOR_COUNT == 0:
            if CROSS_COUNT + DOT_COUNT > 0:
                ERROR(d.CLASS_E,4);
                PTR_TOP = PTR(MP);
                return;
            if MATRIX_COUNT == 0:
                PTR_TOP = PTR(MP);
                return;
            #  MULTIPLY MATRIX PRODUCTS
            MATRIXP = 0;
            PP = TERMP - 1;
            while MATRIX_COUNT > 0:
                PP = PP + 1;
                if FIXV(PP) == MAT_TYPE:
                    MATRIX_COUNT = MATRIX_COUNT - 1;
                    if MATRIXP == 0: 
                        MATRIXP = PP;
                    else: 
                        MULTIPLY_SYNTHESIZE(MATRIXP,PP,MATRIXP,8);
            if SCALARP != 0: 
                MULTIPLY_SYNTHESIZE(MATRIXP,SCALARP,TERMP,2);
            PTR_TOP = PTR(MP);
            return;
        
        # PRODUCTS WITH VECTORS TAKE UP THE REST OF THIS REDUCTION
        
        #  FIRST MATRICES ARE PULLED INTO VECTORS
        if MATRIX_COUNT == 0: 
            goto_MATRICES_TAKEN_CARE_OF = True
        else:
            BEGINP = TERMP;
            goto_MATRICES_MAY_GO_RIGHT = True
            while MATRICES_MAY_GO_RIGHT:
                goto_MATRICES_MAY_GO_RIGHT = False
                MATRIX_PASSED = 0;
                for PP in range(BEGINP, SP+1):
                    if FIXV(PP) == MAT_TYPE: 
                        MATRIX_PASSED = MATRIX_PASSED + 1; 
                    elif FIXV(PP) == DOT or FIXV(PP) == CROSS: 
                        MATRIX_PASSED = 0; 
                    elif FIXV(PP) == VEC_TYPE:
                        #  THIS ILLEGAL SYNTAX WILL BE CAUGHT ELSEWHERE
                        DO;
                        PPTEMP = PP;
                        while MATRIX_PASSED > 0:
                            PPTEMP = PPTEMP - 1;
                            if FIXV(PPTEMP) == MAT_TYPE:
                                MATRIX_PASSED = MATRIX_PASSED - 1;
                                MULTIPLY_SYNTHESIZE(PPTEMP,PP,PP,7);
                        for PPTEMP in range(PP + 1, SP + 1):
                            if FIXV(PPTEMP) == MAT_TYPE:
                                MULTIPLY_SYNTHESIZE(PP,PPTEMP,PP,6); 
                            if FIXV(PPTEMP) == VEC_TYPE: 
                                PP = PPTEMP;  
                            elif FIXV(PPTEMP) == DOT or FIXV(PPTEMP) == CROSS:
                                BEGINP = PPTEMP + 1;
                                goto_MATRICES_MAY_GO_RIGHT = True
                                continue
        
        goto_MATRICES_TAKEN_CARE_OF = False
        # PRODUCTS WITHOUT DOT OR CROSS COME NEXT
        if (DOT_COUNT + CROSS_COUNT) > 0: 
            goto_CROSS_PRODUCTS = True
        else:
            if VECTOR_COUNT > 2:
                ERROR(d.CLASS_EO,1);
                PTR_TOP = PTR(MP);
                return;
            for PP in range(MP, SP+1):
               if FIXV(PP) == VEC_TYPE:
                    VECTORP = PP;
                    PP= SP + 1;
            COMBINE_SCALARS_AND_VECTORS:
            if SCALARP != 0:
                MULTIPLY_SYNTHESIZE(VECTORP,SCALARP,TERMP,1);  
            elif VECTORP != MP:
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
            if VECTOR_COUNT == 1:
                PTR_TOP = PTR(MP);
                return;
            #  VECTOR_COUNT SHOULD BE 2 HERE
            for PP in range(VECTORP + 1, SP + 1):
                if FIXV(PP) == VEC_TYPE:
                    MULTIPLY_SYNTHESIZE(TERMP,PP,TERMP,5);
                    PTR_TOP = PTR(MP);
                    return;
        
        goto_CROSS_PRODUCTS = False
        while CROSS_COUNT > 0:
            VECTORP = 0;
            for PP in range(MP, 1 + SP):
                if FIXV(PP) == VEC_TYPE: 
                    VECTORP = PP;
                elif FIXV(PP) == DOT: 
                    VECTORP = 0;
                elif FIXV(PP) == CROSS:
                    if VECTORP == 0:
                        ERROR(d.CLASS_EC,3);
                        PTR_TOP = PTR(MP);
                        return;
                    else:
                        for PPTEMP in range(PP + 1, 1 + SP):
                            if FIXV(PPTEMP) == VEC_TYPE:
                                MULTIPLY_SYNTHESIZE(VECTORP,PPTEMP,VECTORP,4);
                                FIXV(PP) = 0;
                                CROSS_COUNT = CROSS_COUNT - 1;
                                FIXV(PPTEMP) = 0;
                                VECTOR_COUNT = VECTOR_COUNT - 1;
                                GO TO CROSS_PRODUCTS;
                    ERROR(d.CLASS_EC,2);
                    PTR_TOP = PTR(MP);
                    return;
        
        if DOT_COUNT > 0: 
            GO TO DOT_PRODUCTS;
        if VECTOR_COUNT > 1:
            ERROR(d.CLASS_EO,2);
            PTR_TOP = PTR(MP);
            return;
        # IF YOU GET TO THIS GOTO, VECTOR_COUNT HAD BETTER BE 1
        GO TO COMBINE_SCALARS_AND_VECTORS;
        
        DOT_PRODUCTS:
        BEGINP = TERMP;
        DOT_PRODUCTS_LOOP:
        while DOT_COUNT > 0:
            VECTORP = 0;
            for PP in range(BEGINP, 1 + SP):
                if FIXV(PP) == VEC_TYPE: 
                    VECTORP = PP;
                if FIXV(PP) == DOT:
                    if VECTORP == 0:
                        ERROR(d.CLASS_ED,2);
                        PTR_TOP = PTR(MP);
                        return;
                    else:
                        for PPTEMP in range(PP + 1, 1 + SP):
                            if FIXV(PPTEMP) == VEC_TYPE:
                                MULTIPLY_SYNTHESIZE(VECTORP,PPTEMP,VECTORP,3);
                                if SCALARP == 0: 
                                    SCALARP = VECTORP; 
                                else:
                                    MULTIPLY_SYNTHESIZE(SCALARP,VECTORP,SCALARP,0);
                                BEGINP = PPTEMP + 1;
                                DOT_COUNT = DOT_COUNT - 1;
                                FIXV(VECTORP) = 0;
                                FIXV(PPTEMP) = 0;
                                VECTOR_COUNT = VECTOR_COUNT - 2;
                                GO TO DOT_PRODUCTS_LOOP;
                    ERROR(d.CLASS_ED,1);
                    PTR_TOP = PTR(MP);
                    return;
        if VECTOR_COUNT>0:
            ERROR(d.CLASS_EO,3);
            PTR_TOP = PTR(MP);
            return;
        # VECTOR_COUNT MUST BE 0 HERE
        if SCALARP == MP:
            PTR_TOP = PTR(MP);
            return;
        #   KLUDGE TO USE CODE IN ANOTHER SECTION OF THIS CASE
        VECTORP = SCALARP;
        VECTOR_COUNT = 1;
        SCALARP = 0;
        GO TO COMBINE_SCALARS_AND_VECTORS;
        
    elif PRODUCTION_NUMBER == 12:
        #  <PRODUCT> ::= <FACTOR> * <PRODUCT>
        pass
    elif PRODUCTION_NUMBER == 13:
        #  <PRODUCT> ::= <FACTOR> . <PRODUCT>
        pass
    elif PRODUCTION_NUMBER == 14:
        #  <PRODUCT> ::= <FACTOR> <PRODUCT>
        pass
    elif PRODUCTION_NUMBER == 15:
        # <FACTOR> ::= <PRIMARY>
        if PARSE_STACK(MP-1)!=EXPONENT: 
            if FIXF(MP)>0:
                SET_XREF_RORS(MP);
    elif PRODUCTION_NUMBER == 16:
        #  <FACTOR>  ::=  <PRIMARY>  <**>  <FACTOR>
        I=PTR(SP);
        if FIXF(MP)>0: 
            SET_XREF_RORS(MP);
        EXPONENT_LEVEL=EXPONENT_LEVEL-1;
        TEMP=PSEUDO_TYPE(PTR(MP));
        # DO CASE TEMP-MAT_TYPE;
        tmt = TEMP-MAT_TYPE
        if tmt == 0:
            #  MATRIX
            TEMP2=PSEUDO_LENGTH(PTR(MP));
            if (PSEUDO_FORM(I)==XSYT)or(PSEUDO_FORM(I)==XXPT):
                if VAR(SP)=='T': 
                    HALMAT_TUPLE(XMTRA,0,MP,0,0);
                    SETUP_VAC(MP,TEMP,SHL(TEMP2,8)|SHR(TEMP2,8));
                    if IMPLICIT_T:
                        SYT_FLAGS(LOC_P(I))=SYT_FLAGS(LOC_P(I))|IMPL_T_FLAG;
                        IMPLICIT_T=FALSE;
                    GO TO T_FOUND;
            if PSEUDO_TYPE(I)!=INT_TYPE|PSEUDO_FORM(I)!=XLIT:
                ERROR(d.CLASS_E,2);
            if (TEMP2&0xFF)!=SHR(TEMP2,8): 
                ERROR(d.CLASS_EM,4);
            HALMAT_TUPLE(XMINV,0,MP,SP,0);
            SETUP_VAC(MP,TEMP);
        elif tmt == 1:
            #  VECTOR
            ERROR(d.CLASS_EV,4);
            TEMP2=XSEXP;
            # Rather than implement the GO TO FINISH_EXP, I've just duplicated
            # the code that's at FINISH_EXP.
            # GO TO FINISH_EXP;
            HALMAT_TUPLE(TEMP2,0,MP,SP,0);
            SETUP_VAC(MP,PSEUDO_TYPE(PTR(MP)));
        elif tmt == 2:
            #  SCALAR
            SIMPLE_EXP:
            if ARITH_LITERAL(MP,SP,TRUE):
                if MONITOR(9,5):
                    ERROR(d.CLASS_VA,5);
                    GO TO POWER_FAIL;
                LOC_P(PTR(MP))=SAVE_LITERAL(1,DW_AD);
                TEMP=LIT_RESULT_TYPE(MP,SP);
                if TEMP==INT_TYPE: 
                    if MAKE_FIXED_LIT(LOC_P(I))<0:
                        TEMP=SCALAR_TYPE;
                PSEUDO_TYPE(PTR(MP))=TEMP;
            else: 
                POWER_FAIL:
                TEMP2=XSPEX(TEMP-SCALAR_TYPE);
                if PSEUDO_TYPE(I)<SCALAR_TYPE: 
                    ERROR(d.CLASS_E,3);
                if PSEUDO_TYPE(I)!=INT_TYPE:
                    TEMP2=XSEXP;
                    REGULAR_EXP:
                    PTR=0;
                    PSEUDO_TYPE=SCALAR_TYPE;
                    MATCH_SIMPLES(MP,0);
                elif PSEUDO_FORM(I)!=XLIT: DO;
                   TEMP2=XSIEX;
                   GO TO REGULAR_EXP;
                else:
                   TEMP=MAKE_FIXED_LIT(LOC_P(I));
                   if TEMP<0: 
                       TEMP2=XSIEX;
                       GO TO REGULAR_EXP;
                # FINISH_EXP:
                HALMAT_TUPLE(TEMP2,0,MP,SP,0);
                SETUP_VAC(MP,PSEUDO_TYPE(PTR(MP)));
        elif tmt == 3:
            #  INTEGER
            GO TO SIMPLE_EXP;
        # End of CASE TEMP-MAT_TYPE
        if FIXF(SP)>0: 
            SET_XREF_RORS(SP);
        T_FOUND:
        PTR_TOP=PTR(MP);
    elif PRODUCTION_NUMBER == 17:
        #  <**>  ::=  **
        EXPONENT_LEVEL=EXPONENT_LEVEL+1;
    elif PRODUCTION_NUMBER == 18:
        #  <PRE PRIMARY>  ::=  (  <ARITH EXP>  )
        VAR(MP)=VAR(MPP1);
        PTR(MP)=PTR(MPP1);
    elif PRODUCTION_NUMBER == 19:
        #  <PRE PRIMARY> ::= <NUMBER>
        TEMP=INT_TYPE;
        ARITH_LITS:
        PTR(MP)=PUSH_INDIRECT(1);
        LOC_P(PTR(MP))=FIXL(MP);
        PSEUDO_FORM(PTR(MP)) = XLIT ;
        PSEUDO_TYPE(PTR(MP))=TEMP;
    elif PRODUCTION_NUMBER == 20:
        #  <PRE PRIMARY> ::= <COMPOUND NUMBER>
        TEMP=SCALAR_TYPE;
        GO TO ARITH_LITS;
    elif PRODUCTION_NUMBER == 21:
        #  <ARITH FUNC HEAD>  ::=  <ARITH FUNC>
        START_NORMAL_FCN;
    elif PRODUCTION_NUMBER == 22:
        #  <ARITH FUNC HEAD>  ::=  <ARITH CONV> <SUBSCRIPT>
        NOSPACE();
        TEMP,NEXT_SUB=PTR(SP);
        PTR_TOP,PTR(MP)=TEMP;
        if INX(TEMP)==0: 
            GO TO DEFAULT_SHAPER;
        if (PSEUDO_LENGTH(TEMP)>=0) or (VAL_P(TEMP)>=0): 
            ERROR(d.CLASS_QS,1);
        # DO CASE FIXL(MP);
        fm = FIXL(MP)
        if fm == 0:
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
        elif fm == 1:
            #  VECTOR
            if INX(TEMP)!=1: DO;
               ERROR(d.CLASS_QS,3);
               GO TO DEFAULT_SHAPER;
            END;
            ELSE DO;
               TEMP_SYN=ARITH_SHAPER_SUB(VEC_LENGTH_LIM);
               PSEUDO_LENGTH(TEMP),INX(TEMP)=TEMP_SYN;
            END;
        elif fm == 2:
            #  SCALAR
            SCALAR_SHAPER:
            if (INX(TEMP)<1)|(INX(TEMP)>N_DIM_LIM): DO;
               ERROR(d.CLASS_QS,4);
               GO TO DEFAULT_SHAPER;
            END;
            ELSE DO;
               TEMP_SYN=1;
               DO TEMP1=1, 1 + INX(TEMP);
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
        elif fm == 3:
            #  INTEGER
            GO TO SCALAR_SHAPER;
            END;
            GO TO SET_ARITH_SHAPERS;
            DEFAULT_SHAPER:
            DO CASE FIXL(MP);
        elif fm == 4:
            #  MATRIX
            DO;
               PSEUDO_LENGTH(PTR_TOP)=DEF_MAT_LENGTH;
               TEMP=DEF_MAT_LENGTH&0xFF;
               INX(PTR_TOP)=TEMP*TEMP;
            END;
        elif fm == 5:
            #  VECTOR
            PSEUDO_LENGTH(PTR_TOP),INX(PTR_TOP)=DEF_VEC_LENGTH;
        elif fm == 6:
            #  SCALAR
            INX(PTR_TOP)=0;
        elif fm == 7:
            #  INTEGER
            INX(PTR_TOP)=0;
        SET_ARITH_SHAPERS:
        PSEUDO_TYPE(PTR(MP))=FIXL(MP)+MAT_TYPE;
        if PUSH_FCN_STACK(2): 
            FCN_LOC(FCN_LV)=FIXL(MP);
            SAVE_ARRAYNESS();
            HALMAT_POP(XSFST,0,XCO_N,FCN_LV);
            VAL_P(PTR_TOP)=LAST_POPp;
    elif PRODUCTION_NUMBER == 23:
        #  <ARITH CONV>  ::=  INTEGER
        FIXL(MP) = 3;
        SET_BI_XREF(INT_NDX);
    elif PRODUCTION_NUMBER == 24:
        #  <ARITH CONV>  ::=  SCALAR
        FIXL(MP) = 2;
        SET_BI_XREF(SCLR_NDX);
    elif PRODUCTION_NUMBER == 25:
        #  <ARITH CONV>  ::=  VECTOR
        FIXL(MP) = 1;
        SET_BI_XREF(VEC_NDX);
    elif PRODUCTION_NUMBER == 26:
        #  <ARITH CONV>  ::=  MATRIX
        FIXL(MP) = 0;
        SET_BI_XREF(MTX_NDX);
    elif PRODUCTION_NUMBER == 27:
        #  <PRIMARY> ::= <ARITH VAR>
        pass;
    elif PRODUCTION_NUMBER == 28:
        # <PRE PRIMARY>  ::=  <ARITH FUNC HEAD> ( <CALL LIST> )
        END_ANY_FCN();
    elif PRODUCTION_NUMBER == 29:
        #  <PRIMARY>  ::=  <MODIFIED ARITH FUNC>
        SETUP_NO_ARG_FCN(TEMP_SYN);
    elif PRODUCTION_NUMBER == 30:
        #  <PRIMARY>  ::=  <ARITH INLINE DEF>  <BLOCK BODY>  <CLOSING>  ;
        INLINE_SCOPE:
        TEMP2=INLINE_LEVEL;
        TEMP=XICLS;
        GRAMMAR_FLAGS(STACK_PTR(SP))=GRAMMAR_FLAGS(STACK_PTR(SP))|INLINE_FLAG;
        GO TO CLOSE_SCOPE;
    elif PRODUCTION_NUMBER == 31:
        #  <PRIMARY> ::= <PRE PRIMARY>
        FIXF(MP)=0;
    elif PRODUCTION_NUMBER == 32:
        #  <PRIMARY> ::= <PRE PRIMARY> <QUALIFIER>
        PREC_SCALE(SP,PSEUDO_TYPE(PTR(MP)));
        PTR_TOP=PTR(MP);
        FIXF(MP)=0;
    elif PRODUCTION_NUMBER == 33:    
        #  <OTHER STATEMENT>  ::=  <ON PHRASE> <STATEMENT>
        HALMAT_POP(XLBL,1,XCO_N,0);
        HALMAT_PIP(FIXL(MP),XINL,0,0);
        INDENT_LEVEL=INDENT_LEVEL-INDENT_INCR;
        UNBRANCHABLE(SP,7);
        FIXF(MP)=0;
    elif PRODUCTION_NUMBER == 34:
        #  <OTHER STATEMENT> ::= <IF STATEMENT>
        FIXF(MP)=0;
    elif PRODUCTION_NUMBER == 35:
        #  <OTHER STATEMENT>  ::= <LABEL DEFINITION> <OTHER STATEMENT>
        LABEL_INCORP:
        if FIXL(MP)!=FIXF(SP): 
            SYT_PTR(FIXL(MP)) = FIXF(SP);
        FIXF(MP)=FIXL(MP);
        PTR(MP)=PTR(MPP1);
        SET_LABEL_TYPE(FIXL(MP),STMT_LABEL);
    elif PRODUCTION_NUMBER == 36:
        #  <STATEMENT> ::= <BASIC STATEMENT>
        CHECK_IMPLICIT_T();
        OUTPUT_WRITER(LAST_WRITE, STMT_END_PTR);
        #ONLY SET LAST_WRITE TO 0 WHEN STATEMENT STACK
        #COMPLETELY PRINTED.
        if STMT_END_PTR > -1:
            LAST_WRITE = STMT_END_PTR + 1;
        ELSE LAST_WRITE = 0;
        EMIT_SMRK();
    elif PRODUCTION_NUMBER == 37:
        #  <STATEMENT>  ::=  <OTHER STATEMENT>
        pass;
    elif PRODUCTION_NUMBER == 38:
        #  <ANY STATEMENT>  ::= <STATEMENT>
        PTR(MP)=1;
    elif PRODUCTION_NUMBER == 39:
        # <ANY STATEMENT>::= <BLOCK DEFINITION>
        PTR(MP)=BLOCK_MODE(NEST+1)=UPDATE_MODE; # WHAT BLOCK WAS
    elif PRODUCTION_NUMBER == 40:
        #  <BASIC STATEMENT>  ::= <LABEL DEFINITION> <BASIC STATEMENT>
        GO TO LABEL_INCORP;
    elif PRODUCTION_NUMBER == 41:
        # <BASIC STATEMENT>::=<ASSIGNMENT>
        g.XSET(0x4);
        PTR_TOP=PTR_TOP-INX(PTR(MP));
        if NAME_PSEUDOS: NAME_ARRAYNESS(MP);
        HALMAT_FIX_PIPp(LAST_POPp,INX(PTR(MP)));
        EMIT_ARRAYNESS();
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 42:
        # <BASIC STATEMENT>::= EXIT ;
        EXITTING:
        TEMP=DO_LEVEL;
        while TEMP>1:
            if SHR(DO_INX(TEMP),7): 
                ERROR(d.CLASS_GE,3);
            if LABEL_MATCH: 
                HALMAT_POP(XBRA,1,0,0);
                HALMAT_PIP(DO_LOC(TEMP),XINL,0,0);
                TEMP=1;
            TEMP=TEMP-1;
        if TEMP==1: 
            ERROR(d.CLASS_GE,1);
        g.XSET(0x01);
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 43:
        #  <BASIC STATEMENT>  ::=  EXIT  <LABEL>  ;
        SET_XREF(FIXL(MPP1),XREF_REF);
        GO TO EXITTING;
    elif PRODUCTION_NUMBER == 44:
        # <BASIC STATEMENT>::= REPEAT ;
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
        if TEMP==1: ERROR(d.CLASS_GE,2);
        g.XSET(0x801);
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 44:
    #  <BASIC STATEMENT>  ::=  REPEAT  <LABEL>  ;
        SET_XREF(FIXL(MPP1),XREF_REF);
        GO TO REPEATING;
    elif PRODUCTION_NUMBER == 45:
        #  <BASIC STATEMENT>  ::=  GO TO  <LABEL>  ;
        I=FIXL(MP+2);
        SET_XREF(I,XREF_REF);
        if SYT_LINK1(I)<0: 
            if DO_LEVEL<(-SYT_LINK1(I)): 
                ERROR(d.CLASS_GL,3);
        elif SYT_LINK1(I) == 0: 
            SYT_LINK1(I) = STMT_NUM;
        g.XSET(0x1001);
        if VAR_LENGTH(I)>3: 
            ERROR(d.CLASS_GL,VAR_LENGTH(I));
        elif VAR_LENGTH(I)==0: 
            VAR_LENGTH(I)=3;
        HALMAT_POP(XBRA,1,0,0);
        HALMAT_PIP(I,XSYT,0,0);
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 46:
        # <BASIC STATEMENT>::= ;
        FIX_NOLAB:FIXF(MP)=0;
    elif PRODUCTION_NUMBER == 47:
        # <BASIC STATEMENT>::= <CALL KEY> ;
        END_ANY_FCN();
    elif PRODUCTION_NUMBER == 48:
        # <BASIC STATEMENT>::= <CALL KEY> (<CALL LIST>) ;
        END_ANY_FCN();
    elif PRODUCTION_NUMBER == 49:
        # <BASIC STATEMENT>::=<CALL KEY><ASSIGN>(<CALL ASSIGN LIST>);
        END_ANY_FCN();
    elif PRODUCTION_NUMBER == 50:
        # <BASIC STATEMENT>::=<CALL KEY>(<CALL LIST>)<ASSIGN>(<CALL ASSIGN LIST>);
        END_ANY_FCN();
    elif PRODUCTION_NUMBER == 51:
        # <BASIC STATEMENT>::= RETURN ;
        if SYT_CLASS(BLOCK_SYTREF(NEST))==FUNC_CLASS: 
            ERROR(d.CLASS_PF,1);
        elif BLOCK_MODE(NEST)==UPDATE_MODE: 
            ERROR(d.CLASS_UP,2);
        HALMAT_POP(XRTRN,0,0,0);
        g.XSET(0x7);
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 52:
        # <BASIC STATEMENT>::= RETURN <EXPRESSION> ;
        g.XSET(0x7);
        TEMP=0;
        if KILL_NAME(MPP1): 
            ERROR(d.CLASS_PF,9);
        if CHECK_ARRAYNESS: 
            ERROR(d.CLASS_PF,3);
        if BLOCK_MODE(NEST)==UPDATE_MODE: 
            ERROR(d.CLASS_UP,2);
        elif SYT_CLASS(BLOCK_SYTREF(NEST))!=FUNC_CLASS:
            ERROR(d.CLASS_PF,2);
        else:
            PTR=0;
            LOC_P=BLOCK_SYTREF(NEST);
            PSEUDO_LENGTH= VAR_LENGTH(LOC_P);
            TEMP=SYT_TYPE(BLOCK_SYTREF(NEST));
            if (SHL(1,PSEUDO_TYPE(PTR(MPP1)))&ASSIGN_TYPE(TEMP))==0:
                ERROR(d.CLASS_PF,4);
        # DO CASE TEMP;
        if TEMP in (0, 1, 2):
            pass
        elif TEMP == 3:
            MATRIX_COMPARE(0,MPP1,d.CLASS_PF,5);
        elif TEMP == 4:
            VECTOR_COMPARE(0,MPP1,d.CLASS_PF,6);
        elif TEMP in (5, 6, 7, 8, 9):
            pass
        elif TEMP == 10:
            STRUCTURE_COMPARE(VAR_LENGTH(LOC_P),FIXL(MPP1),d.CLASS_PF,7);
        elif TEMP == 11:
            pass;
        HALMAT_TUPLE(XRTRN,0,MPP1,0,0);
        HALMAT_FIX_PIPTAGS(NEXT_ATOMp-1, PSEUDO_TYPE(PTR(MPP1)),0);
        PTR_TOP=PTR(MPP1)-1;
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 53:
        # <BASIC STATEMENT>::= <DO GROUP HEAD> <ENDING> ;
        g.XSET(0x8);
        INDENT_LEVEL=INDENT_LEVEL - INDENT_INCR;
        NEST_LEVEL = NEST_LEVEL - 1;
        #DO CASE DO_INX(DO_LEVEL)&0x7F;
        didl = DO_INX(DO_LEVEL)&0x7F
        if didl == 0:
            # SIMPLE DO
            TEMP=XESMP;
        elif didl == 1:
            # DO FOR
            TEMP=XEFOR;
        elif didl == 2:
            # DO CASE
            HALMAT_FIX_POPTAG(FIXV(MP),1);
            TEMP=XECAS;
            INFORMATION= '';
            CASE_LEVEL=CASE_LEVEL-1;
        elif didl == 3:
            # DO WHILE
            TEMP=XETST;
        # End of CASE DO_INX...
        HALMAT_POP(TEMP,1,0,0);
        HALMAT_PIP(DO_LOC(DO_LEVEL),XINL,0,0);
        I=0;
        while SYT_LINK2(I)>0:
            J=SYT_LINK2(I);
            if SYT_LINK1(J)<0: 
                if DO_LEVEL==(-SYT_LINK1(J)): 
                    SYT_LINK1(J)=-(DO_LEVEL_LIM+1);
                    SYT_LINK2(I)=SYT_LINK2(J);
            I=J;
        if DO_LOC==0: 
            I=DO_CHAIN(DO_LEVEL);
            while I>0:
                CLOSE_BCD=SYT_NAME(I);
                DISCONNECT(I);
                I=SYT_LINK1(I);
            DO_LEVEL=DO_LEVEL-1;
        else:
            DO_LOC=DO_LOC-1;
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 54:
        # <BASIC STATEMENT>::= <READ KEY>;
        IO_EMIT:
        g.XSET(0x3);
        HALMAT_TUPLE(XREAD(INX(PTR(MP))),0,MP,0,0);
        PTR_TOP=PTR(MP)-1;
        HALMAT_POP(XXXND,0,0,0);
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 55:
        # <BASIC STATEMENT>::= <READ PHRASE> ;
        GO TO IO_EMIT;
    elif PRODUCTION_NUMBER == 56:
        # <BASIC STATEMENT>::= <WRITE KEY> ;
        GO TO IO_EMIT;
    elif PRODUCTION_NUMBER == 57:
    # <BASIC STATEMENT>::= <WRITE PHRASE> ;
       GO TO IO_EMIT;
    elif PRODUCTION_NUMBER == 58:
        # <BASIC STATEMENT>::= <FILE EXP> = <EXPRESSION> ;
        HALMAT_TUPLE(XFILE,0,MP,SP-1,FIXV(MP));
        HALMAT_FIX_PIPTAGS(NEXT_ATOMp-1,PSEUDO_TYPE(PTR(SP-1)),1);
        if KILL_NAME(SP-1): 
            ERROR(d.CLASS_T,5);
        EMIT_ARRAYNESS();
        PTR_TOP=PTR(MP)-1;
        g.XSET(0x800);
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 59:
        # <BASIC STATEMENT>::= <VARIABLE> = <FILE EXP> ;
        HALMAT_TUPLE(XFILE,0,SP-1,MP,FIXV(SP-1));
        l.H1=VAL_P(PTR(MP));
        if SHR(l.H1,7): 
            ERROR(d.CLASS_T,4);
        if SHR(l.H1,4): 
            ERROR(d.CLASS_T,7);
        if (l.H1&0x6)==0x2: 
            ERROR(d.CLASS_T,8);
        HALMAT_FIX_PIPTAGS(NEXT_ATOMp-1,PSEUDO_TYPE(PTR(MP)),0);
        if KILL_NAME(MP): 
            ERROR(d.CLASS_T,5);
        CHECK_ARRAYNESS();  # DR 173
        PTR_TOP=PTR(MP)-1;
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 60:
    # <BASIC STATEMENT>  ::=  <WAIT KEY>  FOR DEPENDENT ;
        HALMAT_POP(XWAIT,0,0,0);
        g.XSET(0xB);
        UPDATE_CHECK:
        if UPDATE_BLOCK_LEVEL>0: 
            ERROR(d.CLASS_RU,1);
        if INLINE_LEVEL>0: 
            ERROR(d.CLASS_PP,6);
        REFER_LOC=0;
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 61:
    # <BASIC STATEMENT>::= <WAIT KEY><ARITH EXP>;
        TEMP=1;
        if UNARRAYED_SCALAR(SP-1): 
            ERROR(d.CLASS_RT,6,'WAIT');
        WAIT_TIME:
        g.XSET(0xB);
        HALMAT_TUPLE(XWAIT,0,SP-1,0,TEMP);
        PTR_TOP=PTR(SP-1)-1;
        GO TO UPDATE_CHECK;
    elif PRODUCTION_NUMBER == 62:
        #  <BASIC STATEMENT> ::=  <WAIT KEY> UNTIL <ARITH EXP> ;
        TEMP=2;
        if UNARRAYED_SCALAR(SP-1): 
            ERROR(d.CLASS_RT,6,'WAIT UNTIL');
        GO TO WAIT_TIME;
    elif PRODUCTION_NUMBER == 63:
        # <BASIC STATEMENT>::= <WAIT KEY> FOR <BIT EXP> ;
        TEMP=3;
        if CHECK_EVENT_EXP(SP-1): ERROR(d.CLASS_RT,6,'WAIT FOR');
        GO TO WAIT_TIME;
    elif PRODUCTION_NUMBER == 64:
        # <BASIC STATEMENT>::= <TERMINATOR> ;
        g.XSET(0xA);
        HALMAT_POP(FIXL(MP),0,0,0);
        GO TO UPDATE_CHECK;
    elif PRODUCTION_NUMBER == 65:
        # <BASIC STATEMENT>::= <TERMINATOR> <TERMINATE LIST>;
        g.XSET(0xA);
        HALMAT_POP(FIXL(MP),EXT_P(PTR(MPP1)),0,1);
        for l.H1 in range(PTR(MPP1), 1 + EXT_P(PTR(MPP1))+PTR(MPP1)-1):
            HALMAT_PIP(LOC_P(l.H1),PSEUDO_FORM(l.H1),0,0);
        PTR_TOP=PTR(MPP1)-1;
        GO TO UPDATE_CHECK;
    elif PRODUCTION_NUMBER == 66:
        # <BASIC STATEMENT>::= UPDATE PRIORITY TO <ARITH EXP>;
        PTR_TOP=PTR(SP-1)-1;
        TEMP=0;
        UP_PRIO:
        g.XSET(0xC);
        if UNARRAYED_INTEGER(SP-1):
            ERROR(d.CLASS_RT,4,'UPDATE PRIORITY');
        HALMAT_TUPLE(XPRIO,0,SP-1,TEMP,TEMP>0);
        GO TO UPDATE_CHECK;
    elif PRODUCTION_NUMBER == 67:
        #  <BASIC STATEMENT>  ::=  UPDATE PRIORITY  <LABEL VAR>  TO  <ARITH EXP>;
        SET_XREF_RORS(MP+2,0xC000);
        PROCESS_CHECK(MP+2);
        TEMP=MP+2;
        PTR_TOP=PTR(TEMP)-1;
        GO TO UP_PRIO;
    elif PRODUCTION_NUMBER == 68:
        # <BASIC STATEMENT>::= <SCHEDULE PHRASE>;
        SCHEDULE_EMIT:
        g.XSET(0x9);
        HALMAT_POP(XSCHD,PTR_TOP-REFER_LOC+1,0,INX(REFER_LOC));
        while REFER_LOC<=PTR_TOP:
            HALMAT_PIP(LOC_P(REFER_LOC),PSEUDO_FORM(REFER_LOC),0,0);
            REFER_LOC=REFER_LOC+1;
        PTR_TOP=PTR(MP)-1;
        GO TO UPDATE_CHECK;
    elif PRODUCTION_NUMBER == 69:
        # <BASIC STATEMENT>::=<SCHEDULE PHRASE><SCHEDULE CONTROL>;
        GO TO SCHEDULE_EMIT;
    elif PRODUCTION_NUMBER == 70:
        #  <BASIC  STATEMENT>  ::=  <SIGNAL CLAUSE>  ;
        g.XSET(0xD);
        HALMAT_TUPLE(XSGNL,0,MP,0,INX(PTR(MP)));
        PTR_TOP=PTR(MP)-1;
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 71:
        #  <BASIC STATEMENT>  ::=  SEND ERROR <SUBSCRIPT>  ;
        ERROR_SUB(2);
        HALMAT_TUPLE(XERSE,0,MP+2,0,0,FIXV(MP)&0x3F);
        SET_OUTER_REF(FIXV(MP),0x0000);
        PTR_TOP=PTR(MP+2)-1;
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 72:
        #  <BASIC STATEMENT>  ::=  <ON CLAUSE>  ;
        HALMAT_TUPLE(XERON,0,MP,0,FIXL(MP),FIXV(MP)&0x3F);
        PTR_TOP=PTR(MP)-1;
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 73:
        #  <BASIC STATEMENT>  ::=  <ON CLAUSE> AND <SIGNAL CLAUSE> ;
        HALMAT_TUPLE(XERON,0,MP,MP+2,FIXL(MP),FIXV(MP)&0x3F,0,0, INX(PTR(MP+2)));
        PTR_TOP=PTR(MP)-1;
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 74:
        #  <BASIC STATEMENT>  ::=  OFF ERROR <SUBSCRIPT>  ;
        ERROR_SUB(0);
        HALMAT_TUPLE(XERON,0,MP+2,0,3,FIXV(MP)&0x3F);
        PTR_TOP=PTR(MP+2)-1;
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 75:
        #  <BASIC STATEMENT>  ::=  <% MACRO NAME> ;
        HALMAT_POP(XPMHD,0,0,FIXL(MP));
        HALMAT_POP(XPMIN,0,0,FIXL(MP));
        XSET (PC_STMT_TYPE_BASE + FIXL(MP));
        if PCARGp(FIXL(MP)) != 0:
            if ALT_PCARGp(FIXL(MP)) != 0:
                ERROR(d.CLASS_XM, 2, VAR(MP));
        GO TO FIX_NOLAB;
    elif PRODUCTION_NUMBER == 76:
        #  <BASIC STATEMENT>  ::=  <% MACRO HEAD> <% MACRO ARG> ) ;
        if PCARGp != 0:
            if ALT_PCARGp != 0:
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
    elif PRODUCTION_NUMBER == 77:
        #  <% MACRO HEAD>  ::=  <% MACRO NAME> (
        if FIXL(MP) == 0: 
            ALT_PCARGp, PCARGp, PCARGOFF = 0;
        else:
            PCARGp=PCARGp(FIXL(MP));
            PCARGOFF=PCARGOFF(FIXL(MP));
            
            # CHECK PCARGBITS OF THE %MACRO ARGUMENT TO
            # SEE IF IT REQUIRES NAME CONTEXT CHECKING.
            # IF SO, SET NAMING FLAG.
            if ((PCARGBITS(PCARGOFF)&0x80)!=0):
                NAMING = TRUE;
            
            ALT_PCARGp = ALT_PCARGp(FIXL(MP));
        XSET (PC_STMT_TYPE_BASE + FIXL(MP));
        HALMAT_POP(XPMHD,0,0,FIXL(MP));
        DELAY_CONTEXT_CHECK=TRUE;
        if FIXL(MP) == PCCOPY_INDEX:
            ASSIGN_ARG_LIST = TRUE;  # INHIBIT LOCK CHECK IN ASSOCIATE
    elif PRODUCTION_NUMBER == 78:
        #  <% MACRO HEAD>  ::=  <% MACRO HEAD> <% MACRO ARG> ,
        HALMAT_TUPLE(XPMAR, 0, MPP1, 0, 0, PSEUDO_TYPE(PTR(MPP1)));
        PTR_TOP=PTR(MPP1)-1;
    elif PRODUCTION_NUMBER == 79:
        #  <% MACRO ARG>  ::=  <NAME VAR>
        if PCARGOFF>0:
            if PCARGp==0: 
                PCARGOFF=0;
            else:
                TEMP=PCARGBITS(PCARGOFF);
                if (TEMP&0x1)==0: 
                    ERROR(d.CLASS_XM,5);
                else:
                    l.H1=PSEUDO_TYPE(PTR(MP));
                    if l.H1 > 0x40: 
                        l.H1 = (l.H1 & 0xF) + 10;
                    elif TEMP_SYN == 0: 
                        l.H1 = l.H1 + 20;
                    if (SHL(1,l.H1)&PCARGTYPE(PCARGOFF))==0:
                        ERROR(d.CLASS_XM,4);   # ILLEGAL TYPE
                    if EXT_P(PTR(MP))>0: 
                        if SHR(TEMP,6):
                            ERROR(d.CLASS_XM,10);   # NO NAME COPINESS
                    RESET_ARRAYNESS();
                    if CHECK_ARRAYNESS: 
                        if SHR(TEMP,5):
                            ERROR(d.CLASS_XM,7);  # NO ARRAYNESS
                    if SHR(TEMP,4): 
                        if TEMP_SYN!=2: 
                            TEMP_SYN=3;
                    if SHR(TEMP,7): 
                        CHECK_NAMING(TEMP_SYN,MP);
                    else:
                        if SHR(TEMP,4): 
                            CHECK_ASSIGN_CONTEXT(MP);
                        else:
                            SET_XREF_RORS(MP);
                        if FIXV(MP)>0: 
                            l.H2=FIXV(MP);
                        else:
                            l.H2=FIXL(MP);
                        if (SYT_FLAGS(l.H2)&(TEMPORARY_FLAG))!=0:
                            if SHR(TEMP,8): 
                                ERROR(d.CLASS_XM,8);
                        l.H2=VAL_P(PTR(MP));
                        # NO SUBSCRIPTS ARE ALLOWED ON THE SOURCE OF %NAMEBIAS
                        if PCARGOFF==2:
                            if SHR(TEMP,2):
                                if SHR(l.H2,5): 
                                    ERROR(d.CLASS_XM,9);
                        elif SHR(TEMP,2):
                            if SHR(l.H2,4): 
                                ERROR(d.CLASS_XM,9);
                PCARGOFF=PCARGOFF+1;
                
                # CHECK PCARGBITS OF THE %MACRO ARGUMENT TO
                # SEE IF IT REQUIRES NAME CONTEXT CHECKING.
                # IF SO, SET NAMING FLAG.
                if ((PCARGBITS(PCARGOFF)&0x80)!=0):
                   NAMING = TRUE;
                
            PCARGp=PCARGp-1;
            ALT_PCARGp = ALT_PCARGp - 1;
    elif PRODUCTION_NUMBER == 80:
        #  <% MACRO ARG>  ::=  <CONSTANT>
        if PCARGOFF>0: 
            if PCARGp==0: 
                PCARGOFF=0;
            elif (PCARGBITS(PCARGOFF)&0x8)==0: 
                ERROR(d.CLASS_XM,3);
            # LITERALS ILLEGAL
            elif (SHL(1,PSEUDO_TYPE(PTR(MP)))&PCARGTYPE(PCARGOFF))==0:
                ERROR(d.CLASS_XM,4);    #  TYPE ILLEGAL
            PCARGOFF=PCARGOFF+1;
        PCARGp=PCARGp-1;
        ALT_PCARGp = ALT_PCARGp - 1;
    elif PRODUCTION_NUMBER == 81:
        #  <BIT PRIM>  ::=  <BIT VAR>
        SET_XREF_RORS(MP);
        NON_EVENT:
        INX(PTR(MP))=FALSE;
    elif PRODUCTION_NUMBER == 82:
        #  <BIT PRIM>  ::=  <LABEL VAR>
        SET_XREF_RORS(MP,0x2000);
        TEMP=PSEUDO_TYPE(PTR(MP));
        if (TEMP==TASK_LABEL) or (TEMP=PROG_LABEL):
            pass;
        else:
            ERROR(d.CLASS_RT,14,VAR(MP));
        if REFER_LOC>0: 
            INX(PTR(MP))=1;
        else:
            INX(PTR(MP))=2;
        YES_EVENT:
        PSEUDO_TYPE(PTR(MP))=BIT_TYPE;
        PSEUDO_LENGTH(PTR(MP))=1;
    elif PRODUCTION_NUMBER == 83:
        #  <BIT PRIM>  ::=  <EVENT VAR>
        SET_XREF_RORS(MP);
        INX(PTR(MP))=REFER_LOC>0;
        GO TO YES_EVENT;
    elif PRODUCTION_NUMBER == 84:
        #  <BIT PRIM>  ::=  <BIT CONST>
        GO TO NON_EVENT;
    elif PRODUCTION_NUMBER == 85:
        #  <BIT PRIM>  ::=  (  <BIT EXP>  )
        PTR(MP)=PTR(MPP1);
    elif PRODUCTION_NUMBER == 86:
        #  <BIT PRIM>  ::=  <MODIFIED BIT FUNC>
        SETUP_NO_ARG_FCN();
        GO TO NON_EVENT;
    elif PRODUCTION_NUMBER == 87:
        #  <BIT PRIM>  ::=  <BIT INLINE DEF> <BLOCK BODY> <CLOSING>  ;
        GO TO INLINE_SCOPE;
    elif PRODUCTION_NUMBER == 88:
        #  <BIT PRIM>  ::=  <SUBBIT HEAD>  <EXPRESSION>  )
        END_SUBBIT_FCN;
        SET_BI_XREF(SBIT_NDX);
        GO TO NON_EVENT;
    elif PRODUCTION_NUMBER == 89:
        #  <BIT PRIM>  ::=  <BIT FUNC HEAD>  (  <CALL LIST>  )
        END_ANY_FCN();
        GO TO NON_EVENT;
    elif PRODUCTION_NUMBER == 90:
        #  <BIT FUNC HEAD>  ::= <BIT FUNC>
        if START_NORMAL_FCN: 
            ASSOCIATE();
    elif PRODUCTION_NUMBER == 91:
        #  <BIT FUNC HEAD>  ::=  BIT  <SUB OR QUALIFIER>
        NOSPACE();
        PTR(MP)=PTR(SP);
        PSEUDO_TYPE(PTR(MP))=BIT_TYPE;
        VAR(MP)='BIT CONVERSION FUNCTION';
        if PUSH_FCN_STACK(3): 
            FCN_LOC(FCN_LV)=1;
        SET_BI_XREF(BIT_NDX);
    elif PRODUCTION_NUMBER == 92:
        #  <BIT CAT> ::= <BIT PRIM>
        pass;
    elif PRODUCTION_NUMBER == 93:
        #  <BIT CAT>  ::=  <BIT CAT>  <CAT>  <BIT PRIM>
        DO_BIT_CAT :
        INX(PTR(MP))=FALSE;
        TEMP=PSEUDO_LENGTH(PTR(MP))+PSEUDO_LENGTH(PTR(SP));
        if TEMP>BIT_LENGTH_LIM:
            TEMP=BIT_LENGTH_LIM;
            ERROR(d.CLASS_EB,1);
        HALMAT_TUPLE(XBCAT,0,MP,SP,0);
        SETUP_VAC(MP,BIT_TYPE,TEMP);
        PTR_TOP=PTR(MP);
    elif PRODUCTION_NUMBER == 94:
        # <BIT CAT> ::= <NOT> <BIT PRIM>
        if BIT_LITERAL(SP,0): 
            TEMP=PSEUDO_LENGTH(PTR(SP));
            TEMP2=SHL(FIXV(SP),HOST_BIT_LENGTH_LIM-TEMP);
            TEMP2=not TEMP2;
            TEMP2=SHR(TEMP2,HOST_BIT_LENGTH_LIM-TEMP);
            LOC_P(PTR(SP))=SAVE_LITERAL(2,TEMP2,TEMP);
        else:
            HALMAT_TUPLE(XBNOT,0,SP,0,INX(PTR(SP)));
            SETUP_VAC(SP,BIT_TYPE);
        INX(PTR(SP))=INX(PTR(SP))&1;
        PTR(MP)=PTR(SP);
    elif PRODUCTION_NUMBER == 95:
        # <BIT CAT> ::= <BIT CAT> <CAT> <NOT> <BIT PRIM>
        HALMAT_TUPLE(XBNOT,0,SP,0,0);
        SETUP_VAC(SP,BIT_TYPE);
        GO TO DO_BIT_CAT;
    elif PRODUCTION_NUMBER == 96:
        #  <BIT FACTOR> ::= <BIT CAT>
        pass;
    elif PRODUCTION_NUMBER == 97:
        #   <BIT FACTOR> ::= <BIT FACTOR> <AND> <BIT CAT>
        if BIT_LITERAL(MP,SP): 
            TEMP=FIXV(MP)&FIXV(SP);
            DO_LIT_BIT_FACTOR:
            if PSEUDO_LENGTH(PTR(MP)) != PSEUDO_LENGTH(PTR(SP)):
                ERROR(d.CLASS_YE,100);
            TEMP2=PSEUDO_LENGTH(PTR(MP));
            if TEMP2<PSEUDO_LENGTH(PTR(SP)): 
                TEMP2=PSEUDO_LENGTH(PTR(SP));
            LOC_P(PTR(MP))=SAVE_LITERAL(2,TEMP,TEMP2);
        else:
            TEMP = XBAND ;
            DO_BIT_FACTOR:
            TEMP2=INX(PTR(MP))&INX(PTR(SP))&1;
            HALMAT_TUPLE(TEMP,0,MP,SP,TEMP2);
            INX(PTR(MP))=TEMP2;
            TEMP=PSEUDO_LENGTH(PTR(MP));
            if TEMP<PSEUDO_LENGTH(PTR(SP)):
                TEMP=PSEUDO_LENGTH(PTR(SP));
            SETUP_VAC(MP,BIT_TYPE,TEMP);
        PTR_TOP=PTR(MP);
    elif PRODUCTION_NUMBER == 98:
        #  <BIT EXP> ::= <BIT FACTOR>
        pass;
    elif PRODUCTION_NUMBER == 99:
        #   <BIT EXP> ::= <BIT EXP> <OR> <BIT FACTOR>
        if BIT_LITERAL(MP,SP): 
            TEMP=FIXV(MP)|FIXV(SP);
            GO TO DO_LIT_BIT_FACTOR;
        else:
            TEMP=XBOR;
            GO TO DO_BIT_FACTOR;
    elif PRODUCTION_NUMBER == 100:
        #  <RELATIONAL OP> ::= =
        REL_OP = 0 ;
    elif PRODUCTION_NUMBER == 101:
        # <RELATIONAL OP> ::= <NOT> =
        REL_OP = 1 ;
    elif PRODUCTION_NUMBER == 102:
        #  <RELATIONAL OP> ::= <
        REL_OP = 2 ;
    elif PRODUCTION_NUMBER == 102:
        #  <RELATIONAL OP> ::= >
        REL_OP = 3 ;
    elif PRODUCTION_NUMBER == 103:
        # <RELATIONAL OP> ::= <  =
        NOSPACE();
        REL_OP = 4 ;
    elif PRODUCTION_NUMBER == 104:
        # <RELATIONAL OP> ::= >  =
        NOSPACE();
        REL_OP = 5 ;
    elif PRODUCTION_NUMBER == 105:
        # <RELATIONAL OP> ::= <NOT> <
        REL_OP = 5 ;
    elif PRODUCTION_NUMBER == 106:
        # <RELATIONAL OP> ::= <NOT> >
        REL_OP = 4 ;
    elif PRODUCTION_NUMBER == 107:
        #  <COMPARISON> ::= <ARITH EXP> <RELATIONAL OP> <ARITH EXP>
        MATCH_ARITH(MP,SP);
        # DO CASE PSEUDO_TYPE(PTR(MP))-MAT_TYPE;
        pt = PSEUDO_TYPE(PTR(MP))-MAT_TYPE
        if pt == 0:
            TEMP=XMEQU(REL_OP);
            VAR(MP)='MATRIX';
        elif pt == 1:
            TEMP=XVEQU(REL_OP);
            VAR(MP)='VECTOR';
        elif pt == 2:
            TEMP=XSEQU(REL_OP);
            VAR(MP)='';
        elif pt == 3:
            TEMP=XIEQU(REL_OP);
            VAR(MP)='';
        EMIT_REL:
        HALMAT_TUPLE(TEMP,XCO_N,MP,SP,0);
    elif PRODUCTION_NUMBER == 108:
        # <COMPARISON> ::= <CHAR EXP> <RELATIONAL OP> <CHAR EXP>
        TEMP=XCEQU(REL_OP);
        VAR(MP)='';
        GO TO EMIT_REL;
    elif PRODUCTION_NUMBER == 109:
        # <COMAPRISON> ::= <BIT CAT> <RELATIONAL OP> <BIT CAT>
        TEMP=XBEQU(REL_OP);
        VAR(MP)='BIT';
        GO TO EMIT_REL;
    elif PRODUCTION_NUMBER == 110:
        #  <COMPARISON>  ::=  <STRUCTURE EXP> <RELATIONAL OP> <STRUCTURE EXP>
        TEMP=XTEQU(REL_OP);
        VAR(MP)='STRUCTURE';
        STRUCTURE_COMPARE(FIXL(MP),FIXL(SP),d.CLASS_C,3);
        GO TO EMIT_REL;
    elif PRODUCTION_NUMBER == 111:
        #  <COMPARISON>  ::=  <NAME EXP>  <RELATIONAL OP>  <NAME EXP>
        NAME_COMPARE(MP,SP,d.CLASS_C,4);
        TEMP=XNEQU(REL_OP);
        VAR(MP)='NAME';
        if COPINESS(MP,SP): 
            ERROR(d.CLASS_EA,1,VAR(SP));
        NAME_ARRAYNESS(SP);
        GO TO EMIT_REL;
    elif PRODUCTION_NUMBER == 112:
        #  <RELATIONAL FACTOR>  ::=  <REL PRIM>
        pass;
    elif PRODUCTION_NUMBER == 113:
        # <RELATIONAL FACTOR> ::= <RELATIONAL FACTOR> <AND> <REL PRIM>
        HALMAT_TUPLE(XCAND,XCO_N,MP,SP,0);
        SETUP_VAC(MP,0);
        PTR_TOP=PTR(MP);
    elif PRODUCTION_NUMBER == 114:
        # <RELATIONAL EXP> ::= <RELATIONAL FACTOR>
        pass;
    elif PRODUCTION_NUMBER == 115:
        # <RELATIONAL EXP> ::= < RELATIONAL EXP> <OR> < RELATIONAL FACTOR>
        HALMAT_TUPLE(XCOR,XCO_N,MP,SP,0);
        SETUP_VAC(MP,0);
        PTR_TOP=PTR(MP);
    elif PRODUCTION_NUMBER == 116:
        # <REL PRIM> ::= (1 <RELATIONAL EXP> )
        PTR(MP) = PTR(MPP1) ; # MOVE INDIRECT STACKS
    elif PRODUCTION_NUMBER == 117:
        # <REL PRIM> ::= <NOT> (1 <RELATIONAL EXP> )
        HALMAT_TUPLE(XCNOT,XCO_N,MP+2,0,0);
        PTR(MP)=PTR(MP+2);
        SETUP_VAC(MP,0);
    elif PRODUCTION_NUMBER == 118:
        # <REL PRIM> ::=  <COMPARISON>
        if REL_OP>1:
            if LENGTH(VAR(MP))>0: 
                ERROR(d.CLASS_C,1,VAR(MP));
            elif CHECK_ARRAYNESS: 
                ERROR(d.CLASS_C,2);
            CHECK_ARRAYNESS();
        SETUP_VAC(MP,0);
        PTR_TOP=PTR(MP);
        EMIT_ARRAYNESS();
    elif PRODUCTION_NUMBER == 119:
        #  <CHAR PRIM> ::= <CHAR VAR>
        SET_XREF_RORS(MP);  # SET XREF FLAG TO SUBSCR OR REF
    elif PRODUCTION_NUMBER == 120:
        #  <CHAR PRIM>  ::=  <CHAR CONST>
        pass;
    elif PRODUCTION_NUMBER == 121:
        #  <CHAR PRIM>  ::=  <MODIFIED CHAR FUNC>
        SETUP_NO_ARG_FCN();
    elif PRODUCTION_NUMBER == 122:
        #  <CHAR PRIM>  ::=  <CHAR INLINE DEF> <BLOCK BODY> <CLOSING>  ;
        GO TO INLINE_SCOPE;
    elif PRODUCTION_NUMBER == 123:
        #  <CHAR PRIM>  ::=  <CHAR FUNC HEAD>  (  <CALL LIST>  )
        END_ANY_FCN();
    elif PRODUCTION_NUMBER == 124:
        #  <CHAR PRIM>  ::=  (  <CHAR EXP>  )
        PTR(MP)=PTR(MPP1);
    elif PRODUCTION_NUMBER == 125:
        #  <CHAR FUNC HEAD>  ::=  <CHAR FUNC>
        if START_NORMAL_FCN: 
            ASSOCIATE();
    elif PRODUCTION_NUMBER == 126:
        #  <CHAR FUNC HEAD>  ::=  CHARACTER  <SUB OR QUALIFIER>
        NOSPACE();
        PTR(MP)=PTR(SP);
        PSEUDO_TYPE(PTR(MP))=CHAR_TYPE;
        VAR(MP)='CHARACTER CONVERSION FUNCTION';
        if PUSH_FCN_STACK(3): 
            FCN_LOC(FCN_LV)=0;
        SET_BI_XREF(CHAR_NDX);
    elif PRODUCTION_NUMBER == 127:
        #  <SUB OR QUALIFIER>  ::=  <SUBSCRIPT>
        TEMP=PTR(MP);
        LOC_P(TEMP)=0;
        if PSEUDO_FORM(TEMP)!=0: 
            PSEUDO_FORM(TEMP)=0;
            ERROR(d.CLASS_QS,9);
        if INX(TEMP)>0: 
           if (PSEUDO_LENGTH(TEMP)>=0) or (VAL_P(TEMP)>=0):
               ERROR(d.CLASS_QS,1);
           if INX(TEMP)!=1:
               INX(TEMP)=1;
               ERROR(d.CLASS_QS,10);
    elif PRODUCTION_NUMBER == 128:
        #  <SUB OR QUALIFIER>  ::=  <BIT QUALIFIER>
        INX(PTR(MP))=0;
    elif PRODUCTION_NUMBER == 129:
        #  <CHAR EXP> ::= <CHAR PRIM>
        pass;
    elif PRODUCTION_NUMBER == 130:
        # <CHAR EXP> ::= <CHAR EXP> <CAT> <CHAR PRIM>
        if CHAR_LITERAL(MP,SP):
            TEMP=CHAR_LENGTH_LIM - LENGTH(VAR(MP));
            if TEMP<LENGTH(VAR(SP)):
                VAR(SP)=SUBSTR(VAR(SP),0,TEMP);
                ERROR(d.CLASS_VC,1);
            VAR(MP)=VAR(MP)+VAR(SP);
            LOC_P(PTR(MP))=SAVE_LITERAL(0,VAR(MP));
            PSEUDO_LENGTH(PTR(MP)) = LENGTH(VAR(MP));
        else:
            DO_CHAR_CAT:
            HALMAT_TUPLE(XCCAT,0,MP,SP,0);
            SETUP_VAC(MP,CHAR_TYPE);
        PTR_TOP=PTR(MP);
    elif PRODUCTION_NUMBER == 131:
        # <CHAR EXP> ::= <CHAR EXP> <CAT> <ARITH EXP>
        ARITH_TO_CHAR(SP) ;
        GO TO DO_CHAR_CAT ;
    elif PRODUCTION_NUMBER == 132:
        #  <CHAR EXP>  ::=  <ARITH EXP>  <CAT>  <ARITH EXP>
        ARITH_TO_CHAR(SP);
        ARITH_TO_CHAR(MP);
        GO TO DO_CHAR_CAT;
    elif PRODUCTION_NUMBER == 133:
        # <CHAR EXP> ::= <ARITH EXP> <CAT> <CHAR PRIM>
        ARITH_TO_CHAR(MP) ;
        GO TO DO_CHAR_CAT ;
    elif PRODUCTION_NUMBER == 134:
        # <ASSIGNMENT>::=<VARIABLE><=1><EXPRESSION>
        INX(PTR(SP))=2;
        if NAME_PSEUDOS: 
            NAME_COMPARE(MP,SP,d.CLASS_AV,5);
            HALMAT_TUPLE(XNASN,0,SP,MP,0);
            if COPINESS(MP,SP)>2: 
                ERROR(d.CLASS_AA,1);
            GO TO END_ASSIGN;
        if RESET_ARRAYNESS>2: 
            ERROR(d.CLASS_AA,1);
        HALMAT_TUPLE(XXASN(PSEUDO_TYPE(PTR(SP))),0,SP,MP,0);
        ASSIGNING:
        TEMP=PSEUDO_TYPE(PTR(SP));
        if TEMP==INT_TYPE: 
            if PSEUDO_FORM(PTR(SP))==XLIT: 
                TEMP2=GET_LITERAL(LOC_P(PTR(SP)));
                if LIT2(TEMP2)==0: 
                    TEMP=0;
        if (SHL(1,TEMP)&ASSIGN_TYPE(PSEUDO_TYPE(PTR(MP))))==0:
            ERROR(d.CLASS_AV,1,VAR(MP));
        elif TEMP>0: 
            # DO CASE PSEUDO_TYPE(PTR(MP));
            pt = PSEUDO_TYPE(PTR(MP))
            if pt == 0:
                pass;
            elif pt == 1:
                pass; #BIT
            elif pt == 2:
                #CHAR*/
                # CHECK IF THE EXPRESSION BEING ASSIGNED TO A
                # CHARACTER IS SCALAR AND SHOULD BE IN DOUBLE
                # PRECISION (DOUBLELIT=TRUE).  IF TRUE, THEN SET
                # LIT1 EQUAL TO 5.
                if (PSEUDO_TYPE(PTR(SP))==SCALAR_TYPE) & DOUBLELIT: # "
                    LIT1(GET_LITERAL(LOC_P(PTR(SP)))) = 5;
            elif pt == 3:
                MATRIX_COMPARE(MP,SP,d.CLASS_AV,2); #MATRIX
            elif pt == 4:
                VECTOR_COMPARE(MP,SP,d.CLASS_AV,3); #VECTOR
            elif pt == 5:
                pass; #SCALAR
            elif pt == 6:
                pass; #INTEGER
            elif pt in (7, 8)
                pass
            elif pt == 9:
                pass; #EVENT
            elif pt == 10:
                STRUCTURE_COMPARE(FIXL(MP),FIXL(SP),d.CLASS_AV,4); # STRUC
            elif pt == 11:
                pass;
        END_ASSIGN:
        DOUBLELIT = FALSE;
        FIXV(MP)=FIXV(SP);
        PTR(MP)=PTR(SP);
    elif PRODUCTION_NUMBER == 135:
        # <ASSIGNMENT>::=<VARIABLE>,<ASSIGNMENT>
        HALMAT_PIP(LOC_P(PTR(MP)),PSEUDO_FORM(PTR(MP)),0,0);
        INX(PTR(SP))=INX(PTR(SP))+1;
        if NAME_PSEUDOS: 
            NAME_COMPARE(MP,SP,d.CLASS_AV,5,0);
            if COPINESS(MP,SP)>0: 
                ERROR(d.CLASS_AA,2,VAR(MP));
            GO TO END_ASSIGN;
        else:
            GO TO ASSIGNING;
    elif PRODUCTION_NUMBER == 136:
        # <IF STATEMENT>::= <IF CLAUSE> <STATEMENT>
        UNBRANCHABLE(SP,4);
        CLOSE_IF:
        INDENT_LEVEL=FIXL(MP);
        HALMAT_POP(XLBL,1,XCO_N,1);
        HALMAT_PIP(FIXV(MP),XINL,0,0);
    elif PRODUCTION_NUMBER == 137:
        # <IF STATEMENT>::=<TRUE PART> <STATEMENT>
        UNBRANCHABLE(SP,5);
        GO TO CLOSE_IF;
    elif PRODUCTION_NUMBER == 137:
        # <TRUE PART>::=<IF CLAUSE><BASIC STATEMENT> ELSE
        UNBRANCHABLE(MPP1,4);
        CHECK_IMPLICIT_T();
        ELSEIF_PTR = STACK_PTR(SP);
        #MOVE ELSEIF_PTR TO FIRST PRINTABLE REPLACE MACRO TOKEN-111342
        I = ELSEIF_PTR;
        DO WHILE (I > 0) and ((GRAMMAR_FLAGS(I-1) & MACRO_ARG_FLAG)!=0):
           I = I - 1;
           if ((GRAMMAR_FLAGS(I) & PRINT_FLAG)!=0):
                ELSEIF_PTR = I;
        if ELSEIF_PTR > 0:
            if STMT_END_PTR > -1:
                SQUEEZING = FALSE;
                OUTPUT_WRITER(LAST_WRITE, ELSEIF_PTR - 1);
                LAST_WRITE = ELSEIF_PTR;
        # ALIGN ELSE CORRECTLY.
        if MOVE_ELSE:
            INDENT_LEVEL=INDENT_LEVEL-INDENT_INCR;
        MOVE_ELSE = TRUE;
        EMIT_SMRK();
        SRN_UPDATE();
        # PUT THE ELSE ON THE SAME LINE AS THE DO.
        ELSE_FLAG = TRUE;
        #DETERMINES IF ELSE WAS ALREADY PRINTED IN REPLACE MACRO-11342
        if (GRAMMAR_FLAGS(ELSEIF_PTR) & PRINT_FLAG)==0:
            ELSE_FLAG = FALSE;
        if NO_LOOK_AHEAD_DONE: 
            CALL_SCAN();
        if TOKEN != IF_TOKEN: 
            #  PRINT ELSE STATEMENTS ON SAME LINE AS A
            # SIMPLE DO.  IF ELSE_FLAG IS FALSE, THEN THE ELSE STATEMENT
            # WAS ALREADY PRINTED.
            if not ELSE_FLAG:
                INDENT_LEVEL = INDENT_LEVEL + INDENT_INCR;
            else:
                # DO NOT OUTPUT_WRITER.  SAVE VALUES
                # THAT ARE NEEDED WHEN OUTPUT_WRITER WILL BE CALLED.
                SAVE_SRN1 = SRN(2);
                SAVE_SRN_COUNT1 = SRN_COUNT(2);
                SAVE1 = ELSEIF_PTR;
                SAVE2 = STACK_PTR(SP);
        else:
            # IF ELSE_FLAG IS FALSE, THEN THE ELSE STATEMENT
            # WAS ALREADY PRINTED FROM PRINT_COMMENT AND INDENT_LEVEL
            # SHOULD BE SET TO INDENT THE LINE FOLLOWING THE COMMENT
            # OR DIRECTIVE.
            if not ELSE_FLAG:
                INDENT_LEVEL = INDENT_LEVEL + INDENT_INCR;
            ELSE_FLAG = FALSE;
            LAST_WRITE = ELSEIF_PTR;
        HALMAT_POP(XBRA,1,0,1);
        HALMAT_PIP(FL_NO,XINL,0,0);
        HALMAT_POP(XLBL,1,XCO_N,0);
        HALMAT_PIP(FIXV(MP),XINL,0,0);
        FIXV(MP)=FL_NO;
        g.XSET(0x100);
        FL_NO=FL_NO+1;
    elif PRODUCTION_NUMBER == 138:
        # <IF CLAUSE>  ::=  <IF> <RELATIONAL EXP> THEN
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
        if (GRAMMAR_FLAGS(LAST_WRITE) & PRINT_FLAG)==0:
            IF_FLAG = FALSE;
            for I in range((LAST_WRITE+1), 1 + STACK_PTR(SP)):
                if (GRAMMAR_FLAGS(I) & PRINT_FLAG)!=0:
                    IF_FLAG = TRUE;
        if not IF_FLAG and (STMT_STACK(LAST_WRITE)!=l.ELSE_TOKEN):
            INDENT_LEVEL = INDENT_LEVEL + INDENT_INCR;
        else:
            SAVE_SRN1 = SRN(2);
            SAVE_SRN_COUNT1 = SRN_COUNT(2);
            SAVE1 = LAST_WRITE;
            SAVE2 = STACK_PTR(SP);
        EMIT_SMRK();
        g.XSET(0x200);
    elif PRODUCTION_NUMBER == 139:
        #  <IF CLAUSE>  ::=  <IF> <BIT EXP> THEN
        HALMAT_TUPLE(XBTRU,0,MPP1,0,0);
        if PSEUDO_LENGTH(PTR(MPP1))>1: 
            ERROR(d.CLASS_GB,1,'IF');
        TEMP=LAST_POPp;
        EMIT_ARRAYNESS();
        GO TO EMIT_IF;
    elif PRODUCTION_NUMBER == 140:
        #  <IF>  ::=  IF
        g.XSET(0x5);
        FIXL(MP)=INDENT_LEVEL;
        HALMAT_POP(XIFHD,0,XCO_N,0);
    elif PRODUCTION_NUMBER == 141:
        # <DO GROUP HEAD>::= DO ;
        g.XSET(0x11);
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
        if (IF_FLAG|ELSE_FLAG) and (PRODUCTION_NUMBER==144):
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
        else:
            IF_FLAG,ELSE_FLAG = FALSE;
            OUTPUT_WRITER(LAST_WRITE, STMT_PTR);
        if FIXL(MPP1)>0:
            HALMAT_POP(XTDCL,1,0,0);
            HALMAT_PIP(FIXL(MPP1),XSYT,0,0);
        EMIT_SMRK();
        INDENT_LEVEL=INDENT_LEVEL + INDENT_INCR;
        NEST_LEVEL = NEST_LEVEL + 1;
    elif PRODUCTION_NUMBER == 142:
        # <DO GROUP HEAD>::= DO <FOR LIST> ;
        g.XSET(0x13);
        HALMAT_FIX_POPTAG(FIXV(MPP1),PTR(MPP1));
        GO TO DO_DONE;
    elif PRODUCTION_NUMBER == 143:
        # <DO GROUP HEAD>::= DO <FOR LIST> <WHILE CLAUSE> ;
        g.XSET(0x13);
        TEMP=PTR(SP-1);
        HALMAT_FIX_POPTAG(FIXV(MPP1),SHL(INX(TEMP),4)|PTR(MPP1));
        HALMAT_POP(XCFOR,1,0,INX(TEMP));
        EMIT_WHILE:
        HALMAT_PIP(LOC_P(TEMP),PSEUDO_FORM(TEMP),0,0);
        PTR_TOP=TEMP-1;
        GO TO DO_DONE;
    elif PRODUCTION_NUMBER == 144:
        # <DO GROUP HEAD>::= DO <WHILE CLAUSE> ;
        g.XSET(0x12);
        FIXL(MPP1)=0;
        TEMP=PTR(MPP1);
        HALMAT_POP(XCTST,1,0,INX(TEMP));
        GO TO EMIT_WHILE;
    elif PRODUCTION_NUMBER == 145:
        # <DO GROUP HEAD>::= DO CASE  <ARITH EXP> ;
        FIXV(MP),FIXL(MP)=0;
        CASE_HEAD:
        g.XSET(0x14);
        TEMP2=PTR(MP+2);
        if UNARRAYED_INTEGER(MP+2): 
            ERROR(d.CLASS_GC,1);
        HALMAT_POP(XDCAS,2,0,FIXL(MP));
        EMIT_PUSH_DO(2,4,0,MP-1);
        HALMAT_PIP(LOC_P(TEMP2),PSEUDO_FORM(TEMP2),0,0);
        PTR_TOP=TEMP2-1;
        CHECK_IMPLICIT_T();
        if FIXL(MP): 
            OUTPUT_WRITER(LAST_WRITE,STACK_PTR(SP)-1);
            LAST_WRITE=STACK_PTR(SP);
            INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
            EMIT_SMRK();
            SRN_UPDATE();
            g.XSET(0x100);
            OUTPUT_WRITER(LAST_WRITE,LAST_WRITE);
            INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
        else:
            if STMT_END_PTR > -1:
                OUTPUT_WRITER(LAST_WRITE, STACK_PTR(SP));
            EMIT_SMRK();
            INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
            GO TO SET_CASE;
    elif PRODUCTION_NUMBER == 146:
        #  <DO GROUP HEAD>  ::=  <CASE ELSE>  <STATEMENT>
        UNBRANCHABLE(SP,6);
        FIXV(MP)=0;
        INDENT_LEVEL=INDENT_LEVEL-INDENT_INCR;
        SET_CASE:
        CASE_LEVEL = CASE_LEVEL +1;
        if CASE_LEVEL <= CASE_LEVEL_LIM:
            CASE_STACK(CASE_LEVEL)=0;
        NEST_LEVEL = NEST_LEVEL + 1;
        GO TO EMIT_CASE;
    elif PRODUCTION_NUMBER == 147:
        # <DO GROUP HEAD>::= <DO GROUP HEAD> <ANY STATEMENT>
        FIXV(MP)=1;
        if (DO_INX(DO_LEVEL)&0x7F)==2: 
            if PTR(SP):
                EMIT_CASE:
                INFORMATION=INFORMATION+'CASE ';
                if CASE_LEVEL <= CASE_LEVEL_LIM:
                    CASE_STACK(CASE_LEVEL)=CASE_STACK(CASE_LEVEL)+1;
                TEMP = 0;
                while (TEMP<CASE_LEVEL)&(TEMP<CASE_LEVEL_LIM):
                    INFORMATION=INFORMATION+CASE_STACK(TEMP)+PERIOD;
                    TEMP = TEMP + 1;
                INFORMATION=INFORMATION+CASE_STACK(TEMP);
                HALMAT_POP(XCLBL,2,XCO_N,0);
                HALMAT_PIP(DO_LOC(DO_LEVEL),XINL,0,0);
                HALMAT_PIP(FL_NO,XINL,0,0);
                FL_NO=FL_NO+2;
                FIXV(MP)=LAST_POPp;
    elif PRODUCTION_NUMBER == 148:
        #  <DO GROUP HEAD>  ::=  <DO GROUP HEAD>  <TEMPORARY STMT>
        if (DO_INX(DO_LEVEL)&0x7F)==2: 
            ERROR(d.CLASS_D,10);
        elif FIXV(MP):
            ERROR(d.CLASS_D,7);
            FIXV(MP)=0;
        GO TO EMIT_NULL;
    elif PRODUCTION_NUMBER == 149:
        #  <CASE ELSE>  ::=  DO CASE <ARITH EXP> ; ELSE
        FIXL(MP)=1;
        GO TO CASE_HEAD;
    elif PRODUCTION_NUMBER == 150:
        # <WHILE KEY>::= WHILE
        TEMP=0;
        WHILE_KEY:
        if PARSE_STACK(MP-1)==DO_TOKEN:
            HALMAT_POP(XDTST,1,XCO_N,TEMP);
            EMIT_PUSH_DO(3,3,0,MP-2);
        FIXL(MP)=TEMP;
    elif PRODUCTION_NUMBER == 151:
        # <WHILE KEY>::= UNTIL
        TEMP=1;
        GO TO WHILE_KEY;
    elif PRODUCTION_NUMBER == 152:
        # <WHILE CLAUSE>::=<WHILE KEY> <BIT EXP>
        if CHECK_ARRAYNESS: 
            ERROR(d.CLASS_GC,2);
        if PSEUDO_LENGTH(PTR(SP))>1: 
            ERROR(d.CLASS_GB,1,'WHILE/UNTIL');
        HALMAT_TUPLE(XBTRU,0,SP,0,0);
        SETUP_VAC(SP,BIT_TYPE);
        DO_FLOWSET:
        INX(PTR(SP))=FIXL(MP);
        PTR(MP)=PTR(SP);
    elif PRODUCTION_NUMBER == 153:
        # <WHILE CLAUSE>::= <WHILE KEY> <RELATIONAL EXP>
        GO TO DO_FLOWSET;
    elif PRODUCTION_NUMBER == 154:
        # <FOR LIST>::= <FOR KEY>  <ARITH EXP><ITERATION CONTROL>
        if UNARRAYED_SIMPLE(SP-1): 
            ERROR(d.CLASS_GC,3);
        HALMAT_POP(XDFOR,TEMP2+3,XCO_N,0);
        EMIT_PUSH_DO(1,5,PSEUDO_TYPE(PTR(SP))=INT_TYPE,MP-2,FIXL(MP));
        TEMP=PTR(MP);
        while TEMP <= PTR_TOP:
            HALMAT_PIP(LOC_P(TEMP),PSEUDO_FORM(TEMP),0,0);
            TEMP=TEMP+1;
        FIXV(MP)=LAST_POPp;
        PTR_TOP=PTR(MP)-1;
        PTR(MP) = TEMP2 | FIXF(MP);  ''' RECORD DO TYPE AND WHETHER
                                         LOOP VAR IS TEMPORARY '''
    elif PRODUCTION_NUMBER == 155:
        # <FOR LIST> = <FOR KEY>  <ITERATION BODY>
        HALMAT_FIX_POPTAG(FIXV(SP),1);
        PTR_TOP=PTR(MP)-1;
        PTR(MP) = FIXF(MP);  # RECORD WHETHER LOOP VAR IS TEMPORARY
    elif PRODUCTION_NUMBER == 156:
        # <ITERATION BODY>::= <ARITH EXP>
        TEMP=PTR(MP-1);   #<FOR KEY> PTR
        HALMAT_POP(XDFOR,2,XCO_N,0);
        EMIT_PUSH_DO(1,5,0,MP-3,FIXL(MP-1));
        HALMAT_PIP(LOC_P(TEMP),PSEUDO_FORM(TEMP),0,0);
        FIXV(MP-1)=LAST_POPp; # IN <FOR KEY> STACK ENTRY
        GO TO DO_DISCRETE;
    elif PRODUCTION_NUMBER == 157:
        # <ITERATION BODY>::= <ITERATION BODY>,<ARITH EXP>
        DO_DISCRETE:
        if UNARRAYED_SIMPLE(SP): 
            ERROR(d.CLASS_GC,3);
        PTR_TOP=PTR(SP)-1;
        HALMAT_TUPLE(XAFOR,XCO_N,SP,0,0);
        FL_NO=FL_NO+1;
        FIXV(MP)=LAST_POPp;
    elif PRODUCTION_NUMBER == 158:
        # <ITERATION CONTROL>::= TO <ARITH EXP>
        if UNARRAYED_SIMPLE(MPP1): ERROR(d.CLASS_GC,3);
        PTR(MP)=PTR(MPP1);
        TEMP2=1;
    elif PRODUCTION_NUMBER == 159:
        # <ITERATION CONTROL>::= TO <ARITH EXP> BY <ARITH EXP>
        TEMP2=UNARRAYED_SIMPLE(SP);
        if UNARRAYED_SIMPLE(MPP1) or TEMP2:
            ERROR(d.CLASS_GC,3);
        PTR(MP)=PTR(MPP1);
        TEMP2=2;
    elif PRODUCTION_NUMBER == 160:
        # <FOR KEY>::= FOR <ARITH VAR> =
        CHECK_ASSIGN_CONTEXT(MPP1);
        if UNARRAYED_SIMPLE(MPP1): 
            ERROR(d.CLASS_GV,1);
        PTR(MP)=PTR(MPP1);
        FIXL(MP), FIXF(MP) = 0;  # NO DO CHAIN EXISTS
    elif PRODUCTION_NUMBER == 161:
        #  <FOR KEY>  ::=  FOR TEMPORARY  <IDENTIFIER>  =
        ID_LOC=FIXL(MP+2);
        PTR(MP)=PUSH_INDIRECT(1);
        LOC_P(PTR_TOP)=ID_LOC;
        PSEUDO_FORM(PTR_TOP)=XSYT;
        PSEUDO_TYPE(PTR_TOP) = INT_TYPE
        SYT_TYPE(ID_LOC)=INT_TYPE;
        TEMP=DEFAULT_ATTR&SD_FLAGS;
        SYT_FLAGS(ID_LOC)=SYT_FLAGS(ID_LOC)|TEMP;
        FIXL(MP) = ID_LOC
        DO_CHAIN=ID_LOC;
        FIXF(MP) = 8;  # DO CHAIN EXISTS FOR CURRENT DO
        CONTEXT=0;
        FACTORING = TRUE;
        if SIMULATING: 
            STAB_VAR(MP);
        SET_XREF(ID_LOC,XREF_ASSIGN);
    elif PRODUCTION_NUMBER == 162:
        # <ENDING>::= END
        # ON END STATEMENT, REPLACE THE CURRENT SCOPE WITH
        # THE STATEMENT NUMBER OF THE DO.  SET A FLAG HERE TO BE USED
        # IN OUTPUT_WRITER IF THE END ISN'T IN A NON-EXPANDED
        # REPLACE MACRO.
        if ((GRAMMAR_FLAGS(STACK_PTR(SP))&PRINT_FLAG)!=0):
            END_FLAG = TRUE;
        # USED TO ALIGN ELSE CORRECTLY
        if (DO_INX(DO_LEVEL) == 0) and IFDO_FLAG(DO_LEVEL):
            MOVE_ELSE = FALSE;
        SAVE_DO_LEVEL = DO_LEVEL;
    elif PRODUCTION_NUMBER == 163:
        # <ENDING>::= END <LABEL>
        # ON END STATEMENT, REPLACE THE CURRENT SCOPE WITH
        # THE STATEMENT NUMBER OF THE DO.  SET A FLAG HERE TO BE USED
        # IN OUTPUT_WRITER IF THE END ISN'T IN A NON-EXPANDED
        # REPLACE MACRO.
        if ((GRAMMAR_FLAGS(STACK_PTR(SP)) and PRINT_FLAG)!=0):
            END_FLAG = TRUE;
        # USED TO ALIGN ELSE CORRECTLY
        if (DO_INX(DO_LEVEL) == 0) and IFDO_FLAG(DO_LEVEL):
            MOVE_ELSE = FALSE;
        SAVE_DO_LEVEL = DO_LEVEL;
        TEMP=MP-1;
        while PARSE_STACK(TEMP)==LABEL_DEFINITION:
            TEMP=TEMP-1;
        TEMP=TEMP-1;
        while PARSE_STACK(TEMP)==LABEL_DEFINITION:
            if FIXL(TEMP)==FIXL(SP):
                # CREATE AN ASSIGN XREF ENTRY FOR A LABEL THAT
                # IS USED ON AN END STATEMENT SO THE "NOT
                # REFERENCED" MESSAGE WILL NOT BE PRINTED IN
                # THE CROSS REFERENCE TABLE. THIS XREF ENTRY
                # WILL BE REMOVED IN SYT_DUMP SO IT DOES NOT
                # SHOW UP IN THE SDF.
                SET_XREF(FIXL(SP),XREF_ASSIGN);
                GO TO ENDING_DONE;
           TEMP=TEMP-1;
        ERROR(d.CLASS_GL,1);
        ENDING_DONE:
    elif PRODUCTION_NUMBER == 164:
        # <ENDING>::= <LABEL DEFINITION> <ENDING>
        # USED TO ALIGN ELSE CORRECTLY
        if (DO_INX(DO_LEVEL) == 0) and IFDO_FLAG(DO_LEVEL):
            MOVE_ELSE = FALSE;
        SAVE_DO_LEVEL = DO_LEVEL;
        SET_LABEL_TYPE(FIXL(MP),STMT_LABEL);
    elif PRODUCTION_NUMBER == 165:
        #    <ON PHRASE>  ::= ON ERROR  <SUBSCRIPT>
        ERROR_SUB(1);
        HALMAT_POP(XERON,2,0,0);
        HALMAT_PIP(LOC_P(PTR(MP+2)),XIMD,FIXV(MP)&0x3F,0);
        HALMAT_PIP(FL_NO,XINL,0,0);
        FIXL(MP)=FL_NO;
        FL_NO=FL_NO+1;
        PTR_TOP=PTR(SP)-1;
        if INX(PTR(SP)) == 0:
            SUB_END_PTR = STACK_PTR(MP) + 1;  # NULL SUBSCRIPT
        OUTPUT_WRITER(LAST_WRITE, SUB_END_PTR);
        INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
        EMIT_SMRK();
        g.XSET(0x400);
    elif PRODUCTION_NUMBER == 166:
        #  <ON CLAUSE>  ::=  ON ERROR <SUBSCRIPT>  SYSTEM
        FIXL(MP)=1;
        ON_ERROR_ACTION:
        ERROR_SUB(1);
        PTR(MP),PTR_TOP=PTR(MP+2);
    elif PRODUCTION_NUMBER == 167:
        #  <ON CLAUSE>  ::=  ON ERROR <SUBSCRIPT> IGNORE
        FIXL(MP)=2;
        GO TO ON_ERROR_ACTION;
    elif PRODUCTION_NUMBER == 168:
        #  <SIGNAL CLAUSE>  ::=  SET <EVENT VAR>
        TEMP=1;
        SIGNAL_EMIT:
        if INLINE_LEVEL>0: 
            ERROR(d.CLASS_PP,6);
        if TEMP>0: 
            if (SYT_FLAGS(FIXL(MPP1))&LATCHED_FLAG)==0:
                ERROR(d.CLASS_RT,10);
        SET_XREF_RORS(MPP1,0,XREF_ASSIGN);
        if CHECK_ARRAYNESS: 
            ERROR(d.CLASS_RT,8);
        if SIMULATING: 
            STAB_VAR(MPP1);
        PTR(MP)=PTR(MPP1);
        INX(PTR(MP))=TEMP;
    elif PRODUCTION_NUMBER == 169:
        #  <SIGNAL CLAUSE>  ::=  RESET <EVENT VAR>
        TEMP=2;
        GO TO SIGNAL_EMIT;
    elif PRODUCTION_NUMBER == 170:
        #  <SIGNAL CLAUSE>  ::= SIGNAL <EVENT VAR>
        TEMP=0;
        GO TO SIGNAL_EMIT;
    elif PRODUCTION_NUMBER == 171:
        #  <FILE EXP>  ::=  <FILE HEAD>  ,  <ARITH EXP>  )
        if FIXV(MP)>DEVICE_LIMIT:
            ERROR(d.CLASS_TD,1,''+DEVICE_LIMIT);
            FIXV(MP)=0;
        if UNARRAYED_INTEGER(SP-1): 
            ERROR(d.CLASS_TD,2);
        RESET_ARRAYNESS();
        PTR(MP)=PTR(SP-1);
        if UPDATE_BLOCK_LEVEL>0: 
            ERROR(d.CLASS_UT,1);
        g.XSET(0x10);
    elif PRODUCTION_NUMBER == 172:
        #  <FILE HEAD>  ::=  FILE  (  <NUMBER>
        FIXV(MP)=FIXV(MP+2);
        if INLINE_LEVEL>0: 
            ERROR(d.CLASS_PP,5);
        SAVE_ARRAYNESS();
    elif PRODUCTION_NUMBER == 173:
        #  <CALL KEY>  ::=  CALL  <LABEL VAR>
        I = FIXL(MPP1);
        if SYT_TYPE(I) == PROC_LABEL: 
            if SYT_LINK1(I) < 0:
                if DO_LEVEL<(-SYT_LINK1(I)): 
                    ERROR(d.CLASS_PL,8,VAR(MPP1));
        if SYT_LINK1(I) == 0: 
            SYT_LINK1(I) = STMT_NUM;
        while SYT_TYPE(I) == IND_CALL_LAB:
            I = SYT_PTR(I);
        if SYT_TYPE(I)!=PROC_LABEL: 
            ERROR(d.CLASS_DT,3,VAR(MPP1));
        if CHECK_ARRAYNESS: 
            ERROR(d.CLASS_PL,7,VAR(MPP1));
        if (SYT_FLAGS(I) & ACCESS_FLAG) != 0:
            ERROR(d.CLASS_PS, 6, VAR(MPP1));
        g.XSET(0x2);
        FCN_ARG=0;
        PTR(MP)=PTR(MPP1);
        SET_XREF_RORS(SP,0x6000);
        if INLINE_LEVEL>0: 
            ERROR(d.CLASS_PP,7);
    elif PRODUCTION_NUMBER == 174:
        #  <CALL LIST> ::= <LIST EXP>
        SETUP_CALL_ARG();
    elif PRODUCTION_NUMBER == 175:
        #  <CALL LIST> ::= <CALL LIST> , <LIST EXP>
        SETUP_CALL_ARG();
    elif PRODUCTION_NUMBER == 176:
        #  <CALL ASSIGN LIST> ::= <VARIABLE>
        if INLINE_LEVEL==0:
            ASSIGN_ARG:
            FCN_ARG=FCN_ARG+1;
            HALMAT_TUPLE(XXXAR,XCO_N,SP,0,0);
            HALMAT_FIX_PIPTAGS(NEXT_ATOMp-1,PSEUDO_TYPE(PTR(SP))| \
                               SHL(NAME_PSEUDOS,7),1);
            if NAME_PSEUDOS: 
                KILL_NAME(SP);
                if EXT_P(PTR(SP))!=0: 
                    ERROR(d.CLASS_FD,7);
            CHECK_ARRAYNESS();
            l.H1=VAL_P(PTR(SP));
            if SHR(l.H1,7): 
                ERROR(d.CLASS_FS,1);
            if SHR(l.H1,4): 
                ERROR(d.CLASS_SV,1,VAR(SP));
            if (l.H1&0x6)==0x2: 
                ERROR(d.CLASS_FS,2,VAR(SP));
            PTR_TOP=PTR(SP)-1;
    elif PRODUCTION_NUMBER == 177:
        #  <CALL ASSIGN LIST> ::= <CALL ASSIGN LIST> , <VARIABLE>
        GO TO ASSIGN_ARG;
    elif PRODUCTION_NUMBER == 178:
        #  <EXPRESSION> ::= <ARITH EXP>
        EXT_P(PTR(MP))=0;
        # if THE DECLARED VALUE IS A DOUBLE CONSTANT SCALAR OR
        # INTEGER,: SET LIT1 EQUAL TO 5.
        if (TYPE==SCALAR_TYPE) or (FACTORED_TYPE=SCALAR_TYPE) or \
                (TYPE=INT_TYPE) or (FACTORED_TYPE=INT_TYPE) or \
                ((TYPE==0) and (FACTORED_TYPE==0)):
            if ((ATTRIBUTES & DOUBLE_FLAG) != 0) and \
                    ((FIXV(MP-1) & CONSTANT_FLAG) != 0):
                LIT1(GET_LITERAL(LOC_P(PTR(MP)))) = 5;
    elif PRODUCTION_NUMBER == 179:
        #  <EXPRESSION> ::= <BIT EXP>
        EXT_P(PTR(MP))=0;
    elif PRODUCTION_NUMBER == 180:
        #  <EXPRESSION> ::= <CHAR EXP>
        EXT_P(PTR(MP))=0;
    elif PRODUCTION_NUMBER == 181:
        #  <EXPRESSION>  ::=  <STRUCTURE EXP>
        EXT_P(PTR(MP))=0;
    elif PRODUCTION_NUMBER == 182:
        #  <EXPRESSION>  ::=  <NAME EXP>
        pass;
    elif PRODUCTION_NUMBER == 183:
        #  <STRUCTURE EXP>  ::=  <STRUCTURE VAR>
        SET_XREF_RORS(MP);
    elif PRODUCTION_NUMBER == 184:
        #  <STRUCTURE EXP>  ::=  <MODIFIED STRUCT FUNC>
        SETUP_NO_ARG_FCN();
    elif PRODUCTION_NUMBER == 185:
        #  <STRUCTURE EXP>  ::=  <STRUC INLINE DEF> <BLOCK BODY> <CLOSING> ;
        GO TO INLINE_SCOPE;
    elif PRODUCTION_NUMBER == 186:
        #  <STRUCTURE EXP>  ::=  <STRUCT FUNC HEAD>  (  <CALL LIST>  )
        END_ANY_FCN();
    elif PRODUCTION_NUMBER == 187:
        #  <STRUCT FUNC HEAD>  ::=  <STRUCT FUNC>
        if START_NORMAL_FCN: 
            ASSOCIATE();
    elif PRODUCTION_NUMBER == 188:
        # <LIST EXP> ::= <EXPRESSION>
        if FCN_MODE(FCN_LV)!=1: 
            INX(PTR(MP))=0;
    elif PRODUCTION_NUMBER == 189:
        #  <LIST EXP>  ::=  <ARITH EXP>  #  <EXPRESSION>
        if FCN_MODE(FCN_LV)==2: 
            if PSEUDO_FORM(PTR(MP))!=XLIT: 
                TEMP=0;
            else:
                TEMP=MAKE_FIXED_LIT(LOC_P(PTR(MP)));
            if (TEMP<1) or (TEMP>LIST_EXP_LIM): 
                TEMP=1;
                ERROR(d.CLASS_EL,2);
            INX(PTR(MP))=TEMP;
        else:
            ERROR(d.CLASS_EL,1);
            if FCN_MODE(FCN_LV)!=1: 
                INX(PTR(MP))=1;
            ELSE INX(PTR(MP))=INX(PTR(SP));
        TEMP=PTR(SP);
        PTR_TOP=PTR(MP);
        LOC_P(PTR_TOP)=LOC_P(TEMP);
        PSEUDO_FORM(PTR_TOP)=PSEUDO_FORM(TEMP);
        PSEUDO_TYPE(PTR_TOP)=PSEUDO_TYPE(TEMP);
        PSEUDO_LENGTH(PTR_TOP)=PSEUDO_LENGTH(TEMP);
    elif PRODUCTION_NUMBER == 190:
        #  <VARIABLE> ::= <ARITH VAR>
        if not DELAY_CONTEXT_CHECK: 
            CHECK_ASSIGN_CONTEXT(MP);
    elif PRODUCTION_NUMBER == 191:
        #  <VARIABLE> ::= <STRUCTURE VAR>
        if not DELAY_CONTEXT_CHECK: 
            CHECK_ASSIGN_CONTEXT(MP);
    elif PRODUCTION_NUMBER == 192:
        #  <VARIABLE> ::= <BIT VAR>
        if not DELAY_CONTEXT_CHECK: 
            CHECK_ASSIGN_CONTEXT(MP);
    elif PRODUCTION_NUMBER == 193:
        #  <VARIABLE  ::=  <EVENT VAR>
        if CONTEXT>0: 
            if not NAME_PSEUDOS: PSEUDO_TYPE(PTR(MP))=BIT_TYPE;
        if not DELAY_CONTEXT_CHECK: 
            CHECK_ASSIGN_CONTEXT(MP);
        PSEUDO_LENGTH(PTR(MP))=1;
    elif PRODUCTION_NUMBER == 194:
        #  <VARIABLE>  ::=  <SUBBIT HEAD>  <VARIABLE>  )
        if CONTEXT==0:
            if SHR(VAL_P(PTR(MPP1)),7): 
                ERROR(d.CLASS_QX,7);
            TEMP=1;
        else:
            TEMP=0;
        END_SUBBIT_FCN(TEMP);
        SET_BI_XREF(SBIT_NDX);
        VAL_P(PTR(MP))=VAL_P(PTR(MPP1))|0x80;
    elif PRODUCTION_NUMBER == 195:
        #  <VARIABLE> ::= <CHAR VAR>
        if not DELAY_CONTEXT_CHECK: CHECK_ASSIGN_CONTEXT(MP);
    elif PRODUCTION_NUMBER == 196:
        #  <VARIABLE>  ::=  <NAME KEY>  (  <NAME VAR>  )
        if TEMP_SYN!=2: 
            if CONTEXT==0: 
                TEMP_SYN=3;
        CHECK_NAMING(TEMP_SYN,MP+2);
        DELAY_CONTEXT_CHECK=FALSE;
    elif PRODUCTION_NUMBER == 197:
        #  <NAME VAR>  ::=  <VARIABLE>
        l.H1=VAL_P(PTR(MP));
        ARRAYNESS_FLAG=0;
        if SHR(l.H1,11): 
            ERROR(d.CLASS_EN,1);
        VAL_P(PTR(MP))=l.H1|0x800;
        if SHR(l.H1,7): 
            ERROR(d.CLASS_EN,2);
        if (l.H1&0x880)!=0: 
            TEMP_SYN=2;
        else:
            TEMP_SYN=1;
    elif PRODUCTION_NUMBER == 198:
        #  <NAME VAR>  ::=  <LABEL VAR>
        l.H1=SYT_TYPE(FIXL(MP));
        if l.H1==TASK_LABEL or l.H1==PROG_LABEL: 
            GO TO OK_LABELS;
        elif VAR(MP-2) == 'NAME':
            ERROR(d.CLASS_EN,4,VAR(MP));
        OK_LABELS:
        TEMP_SYN=0;
    elif PRODUCTION_NUMBER == 199:
        #  <NAME VAR>  ::=  <MODIFIED ARITH FUNC>
        TEMP_SYN=0;
    elif PRODUCTION_NUMBER == 200:
        #  <NAME VAR>  ::=  <MODIFIED BIT FUNC>
        TEMP_SYN=0;
    elif PRODUCTION_NUMBER == 201:
        #  <NAME VAR>  ::=  <MODIFIED CHAR FUNC>
        TEMP_SYN=0;
    elif PRODUCTION_NUMBER == 202:
        #  <NAME VAR>  ::=  <MODIFIED STRUCT FUNC>
        TEMP_SYN=0;
    elif PRODUCTION_NUMBER == 203:
        #  <NAME EXP>  ::=  <NAME KEY>  (  <NAME VAR>  )
        CHECK_NAMING(TEMP_SYN,MP+2);
        DELAY_CONTEXT_CHECK=FALSE;
    elif PRODUCTION_NUMBER == 204:
        #  <NAME EXP>  ::=  NULL
        FIX_NULL:
        PTR(MP)=PUSH_INDIRECT(1);
        LOC_P(PTR_TOP)=0;
        PSEUDO_FORM(PTR_TOP)=XIMD;
        NAME_PSEUDOS=TRUE;
        EXT_P(PTR_TOP)=0;
        VAL_P(PTR_TOP)=0x500;
    elif PRODUCTION_NUMBER == 205:
        #  <NAME EXP>  ::=  <NAME KEY> ( NULL )
        NAMING=FALSE;
        DELAY_CONTEXT_CHECK=FALSE;
        GO TO FIX_NULL;
    elif PRODUCTION_NUMBER == 206:
        #  <NAME KEY>  ::=  NAME
        NAMING,NAME_PSEUDOS=TRUE;
        DELAY_CONTEXT_CHECK=TRUE;
        ARRAYNESS_FLAG=0;
    elif PRODUCTION_NUMBER == 207:
        #  <LABEL VAR>  ::=  <PREFIX>  <LABEL>  <SUBSCRIPT>
        GO TO FUNC_IDS;
    elif PRODUCTION_NUMBER == 208:
        #  <MODIFIED ARITH FUNC>  ::=  <PREFIX>  <NO ARG ARITH FUNC> <SUBSCRIPT>
        GO TO FUNC_IDS;
    elif PRODUCTION_NUMBER == 209:
        #  <MODIFIED BIT FUNC>  ::=  <PREFIX>  <NO ARG BIT FUNC>  <SUBSCRIPT>
        GO TO FUNC_IDS;
    elif PRODUCTION_NUMBER == 210:
        #  <MODIFIED CHAR FUNC>  ::=  <PREFIX> <NO ARG CHAR FUNC>  <SUBSCRIPT>
        GO TO FUNC_IDS;
    elif PRODUCTION_NUMBER == 211:
        #  <MODIFIED STRUCT FUNC> ::= <PREFIX> <NO ARG STRUCT FUNC> <SUBSCRIPT>
        FUNC_IDS:
        if FIXL(MPP1)>SYT_MAX: 
            if FIXL(SP): 
                ERROR(d.CLASS_FT,8,VAR(MPP1));
            TEMP_SYN=PSEUDO_FORM(PTR(SP));
            PTR_TOP=PTR(MP);
            FIXL(MP)=FIXL(MPP1);
           VAR(MP)=VAR(MPP1);
        else:
            FIXL(SP)=FIXL(SP)|2;
            GO TO MOST_IDS;
    elif PRODUCTION_NUMBER == 212:
        #  <STRUCTURE VAR>  ::=  <QUAL STRUCT>  <SUBSCRIPT>
        l.H1=PTR(MP);
        GO TO STRUC_IDS;
    elif PRODUCTION_NUMBER == 213:
        #  <ARITH VAR>  ::=  <PREFIX>  <ARITH ID>  <SUBSCRIPT>
        GO TO MOST_IDS;
    elif PRODUCTION_NUMBER == 214:
        #  <CHAR VAR>  ::=  <PREFIX>  <CHAR ID>  <SUBSCRIPT>
        GO TO MOST_IDS;
    elif PRODUCTION_NUMBER == 215:
        #  <BIT VAR>  ::=  <PREFIX>  <BIT ID>  <SUBSCRIPT>
        GO TO MOST_IDS;
    elif PRODUCTION_NUMBER == 216:
        #  <EVENT VAR>  ::=  <PREFIX>  (EVENT ID>  <SUBSCRIPT>
        MOST_IDS:
        l.H1=PTR(MP);
        PSEUDO_TYPE(l.H1)=SYT_TYPE(FIXL(MPP1));
        PSEUDO_LENGTH(l.H1)=VAR_LENGTH(FIXL(MPP1));
        if FIXV(MP)==0: 
            STACK_PTR(MP)=STACK_PTR(MPP1);
            VAR(MP)=VAR(MPP1);
            if FIXV(MPP1)==0: 
                LOC_P(l.H1)=FIXL(MPP1);
            else:
                FIXV(MP),LOC_P(l.H1)=FIXV(MPP1);
            PSEUDO_FORM(l.H1)=XSYT;
        else:
            VAR(MP)=VAR(MP)+PERIOD+VAR(MPP1);
            TOKEN_FLAGS(EXT_P(l.H1))=TOKEN_FLAGS(EXT_P(l.H1))|0x20;
            I = FIXL(MPP1);
            UNQ_TEST1:
            while I > 0:
                I = SYT_LINK2(I);
            I = -I;
            if I == 0: 
                ERROR (d.CLASS_IS, 2, VAR(MPP1));
                GO TO UNQ_TEST2;
            if I != FIXL(MP): 
                GO TO UNQ_TEST1;
        UNQ_TEST2:
        FIXL(MP)=FIXL(MPP1);
        EXT_P(l.H1)=STACK_PTR(MPP1);
        STRUC_IDS:
        NAME_BIT=SHR(VAL_P(l.H1),1)&0x80;
        TEMP_SYN=INX(l.H1);
        TEMP3=LOC_P(l.H1);
        if ATTACH_SUBSCRIPT: 
            HALMAT_TUPLE(XTSUB,0,MP,0,MAJ_STRUC|NAME_BIT);
            INX(l.H1)=NEXT_ATOMp-1;
            HALMAT_FIX_PIPp(LAST_POPp,EMIT_SUBSCRIPT(0x8));
            SETUP_VAC(MP,PSEUDO_TYPE(l.H1));
            VAL_P(l.H1)=VAL_P(l.H1)|0x20;
        PTR_TOP=l.H1;  # BASH DOWN STACKS
        if FIXV(MP)>0:
            HALMAT_TUPLE(XEXTN,0,MP,0,0);
            TEMP=l.H1;
            if (SYT_FLAGS(TEMP3) & NAME_FLAG) != 0:
                VAL_P(l.H1) = VAL_P(l.H1) | 0x4000;
            l.H2 = FALSE;
            
            l.PRl.PREV_LIVES_REMOTESYT_FLAGS(TEMP3)&REMOTE_FLAG)!=0;
            l.PREV_POINTS=(SYT_FLAGS(TEMP3)&NAME_FLAG)!= 0;
            l.PREV_REMOTE=l.PREV_LIVES_REMOTE;
            
            while TEMP_SYN!=0:
                TEMP=TEMP+1;
                TEMP3=LOC_P(TEMP);
                HALMAT_PIP(TEMP3,XSYT,0,0);
                l.H2=l.H2|(SYT_FLAGS(TEMP3)&NAME_FLAG)!=0;
                
                # KEEP TRACK OF THE REMOTENESS -----------------
                # OF THE NODE BEING PROCESSED
                l.PREV_REMOTE = ((SYT_FLAGS(TEMP3)&NAME_FLAG) > 0);
                l.REMOTE_SET=((SYT_FLAGS(TEMP3)&REMOTE_FLAG)>0);
                if (l.REMOTE_SET & not l.PREV_REMOTE) \
                        or (l.PREV_POINTS and l.PREV_REMOTE) \
                        or (l.PREV_LIVES_REMOTE and not l.PREV_POINTS):
                    l.CURRENT_LIVES_REMOTE = TRUE;
                else:
                    l.CURRENT_LIVES_REMOTE = FALSE;
                l.PREV_LIVES_REMOTE = l.CURRENT_LIVES_REMOTE;
                l.PREV_POINTS = l.PREV_REMOTE;
                l.PREV_REMOTE = l.REMOTE_SET;
                
                TEMP_SYN=INX(TEMP);
            if l.H2: 
                VAL_P(l.H1) = VAL_P(l.H1) | 0x4000;
            
            # SET FLAG IN VAL_P TO INDICATE
            # THAT TERMINAL LIVES REMOTE
            if (l.PREV_POINTS and l.PREV_REMOTE) \
                    or (PREV_LIVES_REMOTE and not  l.PREV_POINTS):
                VAL_P(l.H1) = VAL_P(l.H1) | 0x8000;
            
            PTR_TOP=TEMP;  # WAIT - DONT LOSE EXTN TILL XREF DONE
            if VAR_LENGTH(TEMP3)==FIXL(MP):
                if TEMP==l.H1: 
                    VAL_P(l.H1)=VAL_P(l.H1)|0x4;
                VAL_P(l.H1)=VAL_P(l.H1)|0x1000;
                HALMAT_FIX_PIPTAGS(NEXT_ATOMp-1,0,1);
                if (SYT_FLAGS(TEMP3)&NAME_FLAG) !=0:
                    VAL_P(l.H1)=VAL_P(l.H1)|0x200;
            HALMAT_PIP(FIXL(MP),XSYT,0,1);
            l.H2 = (l.H2 or (SYT_FLAGS(FIXL(MP)) & NAME_FLAG) != 0);
            HALMAT_FIX_PIPp(LAST_POPp, TEMP - l.H1 + 2);
            HALMAT_FIX_POPTAG(LAST_POPp, l.H2);
            LOC_P(l.H1),l.H2=LAST_POPp;
            PSEUDO_FORM(l.H1)=XXPT;
        else:
            l.H2=-1;
        if PSEUDO_FORM(INX)>0: 
            if FIXL(SP)>=2:
                if DELAY_CONTEXT_CHECK: 
                    ERROR(d.CLASS_EN,14);
                    PSEUDO_FORM(INX)=0;
                else:
                    TEMP_SYN=SP;
                # THIS ASSUMES THAT PTR(SP) AND THE INDIRECT STACKS
                # ARE NOT OVERWRITTEN UNTIL AFTER REACHING THE
                # <PRIMARY>::=<MODIFIED ARITH FUNC> PRODUCTION,
                # WHEN THAT PARSING ROUTE IS TAKEN
            else:
                PREC_SCALE(SP,PSEUDO_TYPE(l.H1));
            if PSEUDO_FORM(INX)>0: 
                VAL_P(l.H1)=VAL_P(l.H1)|0x40;
        elif IND_LINK>0: 
            HALMAT_TUPLE(XDSUB,0,MP,0,PSEUDO_TYPE(l.H1)|NAME_BIT);
            INX(l.H1)=NEXT_ATOMp-1;
            VAL_P(l.H1)=VAL_P(l.H1)|0x20;
            HALMAT_FIX_PIPp(LAST_POPp,EMIT_SUBSCRIPT(0x0));
            SETUP_VAC(MP,PSEUDO_TYPE(l.H1));
        FIXF(MP)=PTR_TOP;  # RECORD WHERE TOP IS IN CASE CHANGED
        ASSOCIATE()(l.H2);
    elif PRODUCTION_NUMBER == 217:
        #  <QUAL STRUCT>  ::=  <STRUCTURE ID>
        PTR(MP)=PUSH_INDIRECT(1);
        PSEUDO_TYPE(PTR_TOP)=MAJ_STRUC;
        EXT_P(PTR_TOP)=STACK_PTR(SP);
        if FIXV(MP)==0: 
            FIXV(MP)=FIXL(MP);
            FIXL(MP)=VAR_LENGTH(FIXL(MP));
            SET_XREF(FIXL(MP), XREF_REF);
        LOC_P(PTR_TOP)=FIXV(MP);
        INX(PTR_TOP)=0;
        VAL_P(PTR_TOP)=SHL(NAMING,8);
        PSEUDO_FORM(PTR_TOP)=XSYT;
    elif PRODUCTION_NUMBER == 218:
        #  <QUAL STRUCT>  ::=  <QUAL STRUCT>  .  <STRUCTURE ID>
        TEMP=VAR_LENGTH(FIXL(SP));
        if TEMP>0: 
            PUSH_INDIRECT(1);
            LOC_P(PTR_TOP)=FIXL(SP);
            INX(PTR_TOP-1)=1;
            INX(PTR_TOP)=0;
            SET_XREF(TEMP, XREF_REF);
            FIXL(MP)=TEMP;
        else:
            FIXL(MP)=FIXL(SP);
        VAR(MP)=VAR(MP)+PERIOD+VAR(SP);
        TOKEN_FLAGS(STACK_PTR(MPP1)) = TOKEN_FLAGS(STACK_PTR(MPP1)) | 0x20;
        TOKEN_FLAGS(EXT_P(PTR(MP)))=TOKEN_FLAGS(EXT_P(PTR(MP)))|0x20;
        EXT_P(PTR(MP))=STACK_PTR(SP);
    elif PRODUCTION_NUMBER == 219:
        #  <PREFIX>  ::=  <EMPTY>
        DO;
        PTR(MP)=PUSH_INDIRECT(1);
        VAL_P(PTR_TOP)=SHL(NAMING,8);
        INX(PTR_TOP)=0;
        FIXL(MP),FIXV(MP)=0;
        END;
    elif PRODUCTION_NUMBER == 220:
        #  <PREFIX>  ::=  <QUAL STRUCT>  .
        TOKEN_FLAGS(STACK_PTR(SP))=TOKEN_FLAGS(STACK_PTR(SP))|0x20;
    elif PRODUCTION_NUMBER == 221:
        # <SUBBIT HEAD>::= <SUBBIT KEY> <SUBSCRIPT>(
        PTR(MP),TEMP=PTR(MPP1);
        LOC_P(TEMP)=0;
        if INX(TEMP)>0: 
            if PSEUDO_LENGTH(TEMP)>=0|VAL_P(TEMP)>=0: 
                ERROR(d.CLASS_QS,12);
            if PSEUDO_FORM(TEMP)!=0: 
                ERROR(d.CLASS_QS,13);
            if INX(TEMP)!=1: 
                INX(TEMP)=1;
                ERROR(d.CLASS_QS,11);
    elif PRODUCTION_NUMBER == 222:
        # <SUBBIT KEY> ::= SUBBIT
        NAMING=FALSE;
        VAR(MP)='SUBBIT PSEUDO-VARIABLE';
    elif PRODUCTION_NUMBER == 223:
        #  <SUBSCRIPT> ::= <SUB HEAD> )
        SUB_END_PTR = STMT_PTR;
        if SUB_SEEN==0: 
            ERROR(d.CLASS_SP,6);
        GO TO SS_CHEX;
    elif PRODUCTION_NUMBER == 224:
        #  <SUBSCRIPT>  ::=  <QUALIFIER>
        SUB_END_PTR = STMT_PTR;
        SUB_COUNT=0;
        FIXL(MP)=0;
        STRUCTURE_SUB_COUNT=0;
        ARRAY_SUB_COUNT=0;
    elif PRODUCTION_NUMBER == 225:
        # <SUBSCRIPT> ::= <$> <NUMBER>
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
    elif PRODUCTION_NUMBER == 226:
        # <SUBSCRIPT> ::= <$> <ARITH VAR>
        SUB_END_PTR = STMT_PTR;
        IORS(SP);
        SET_XREF_RORS(MPP1);
        GO TO SIMPLE_SUBS;
    elif PRODUCTION_NUMBER == 227:
        #  <SUBSCRIPT>  ::=  <EMPTY>
        FIXL(MP)=0;
        GO TO SS_FIXUP;
    elif PRODUCTION_NUMBER == 228:
        #  <SUB START>  ::=  <$> (
        SUB_START:
        SUB_COUNT=0;
        STRUCTURE_SUB_COUNT=-1;
        ARRAY_SUB_COUNT=-1;
        SUB_SEEN=0;
    elif PRODUCTION_NUMBER == 229:
        #  <SUB START>  ::=  <$>  (  @  <PREC SPEC>  ,
        PSEUDO_FORM(PTR(MP))=PTR(MP+3);
        GO TO SUB_START;
    elif PRODUCTION_NUMBER == 230:
        #  <SUB START> ::= <SUB HEAD> ;
        if STRUCTURE_SUB_COUNT>=0: 
            ERROR(d.CLASS_SP,1);
        if SUB_SEEN: 
            STRUCTURE_SUB_COUNT=SUB_COUNT;
        ELSE ERROR(d.CLASS_SP,4);
        SUB_SEEN=1;
    elif PRODUCTION_NUMBER == 231:
        #  <SUB START> ::= <SUB HEAD> :
        if STRUCTURE_SUB_COUNT==-1: 
            STRUCTURE_SUB_COUNT=0;
        if ARRAY_SUB_COUNT>=0: 
            ERROR(d.CLASS_SP,2);
        if SUB_SEEN: 
            ARRAY_SUB_COUNT=SUB_COUNT-STRUCTURE_SUB_COUNT;
        else:
            ERROR(d.CLASS_SP,3);
        SUB_SEEN=1;
    elif PRODUCTION_NUMBER == 232:
        #  <SUB START> ::= <SUB HEAD> ,
        if SUB_SEEN: 
            pass;
        else:
            ERROR(d.CLASS_SP,5);
        SUB_SEEN=0;
    elif PRODUCTION_NUMBER == 233:
        #  <SUB HEAD> ::= <SUB START>
        if SUB_SEEN: SUB_SEEN=2;
    elif PRODUCTION_NUMBER == 234:
        #  <SUB HEAD> ::= <SUB START> <SUB>
        SUB_SEEN=1;
        SUB_COUNT = SUB_COUNT + 1 ;
    elif PRODUCTION_NUMBER == 235:
        #  <SUB> ::= <SUB EXP>
        INX(PTR(MP))=1;
    elif PRODUCTION_NUMBER == 236:
        # <SUB> ::= *
        PTR(MP)=PUSH_INDIRECT(1);
        INX(PTR(MP))=0;
        PSEUDO_FORM(PTR(MP))=XAST;
        PSEUDO_TYPE(PTR(MP))=0;
        VAL_P(PTR(MP))=0;
        LOC_P(PTR(MP))=0;
    elif PRODUCTION_NUMBER == 237:
        # <SUB> ::= <SUB RUN HEAD><SYB EXP>
        INX(PTR(MP))=2;
        INX(PTR(SP))=2;
    elif PRODUCTION_NUMBER == 238:
        # <SUB> ::= <ARITH EXP> AT <SUB EXP>
        IORS(MP);
        INX(PTR(MP))=3;
        INX(PTR(SP))=3;
        VAL_P(PTR(MP))=0;
        PTR(MPP1)=PTR(SP);
    elif PRODUCTION_NUMBER == 239:
        # <SUB RUN HEAD> ::= <SUB EXP> TO
        pass;
    elif PRODUCTION_NUMBER == 240:
        # <SUB EXP> ::= <ARITH EXP>
        IORS(MP);
        VAL_P(PTR(MP))=0;
    elif PRODUCTION_NUMBER == 241:
        # <SUB EXP> ::= <# EXPRESSION>
        if FIXL(MP)==1: 
            PTR(MP)=PUSH_INDIRECT(1);
            PSEUDO_FORM(PTR(MP))=0; #  MUSNT FALL IN LIT OR VAC
            PSEUDO_TYPE(PTR(MP))=INT_TYPE;
        VAL_P(PTR(MP))=FIXL(MP);
    elif PRODUCTION_NUMBER == 242:
        #  <# EXPRESSION>  ::=  #
        FIXL(MP)=1;
    elif PRODUCTION_NUMBER == 243:
        # <# EXPRESSION> ::= <# EXPRESSION> + <TERM>
        TEMP=0;
        SHARP_EXP:
        IORS(SP);
        if FIXL(MP)==1: 
            FIXL(MP)=TEMP+2;
            PTR(MP)=PTR(SP);
        else:
            if FIXL(MP)==3: 
                TEMP=1-TEMP;
            ADD_AND_SUBTRACT(TEMP);
    elif PRODUCTION_NUMBER == 244:
        # <# EXPRESSION> ::= <# EXPRESSION> -1 <TERM>
        TEMP=1;
        GO TO SHARP_EXP;
    elif PRODUCTION_NUMBER == 245:
        # <=1> ::= =
        if ARRAYNESS_FLAG: SAVE_ARRAYNESS();
        ARRAYNESS_FLAG=0;
    elif PRODUCTION_NUMBER == 246:
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
        if SUBSCRIPT_LEVEL==0: DO;
           if ARRAYNESS_FLAG: SAVE_ARRAYNESS();
           SAVE_ARRAYNESS_FLAG=ARRAYNESS_FLAG;
           ARRAYNESS_FLAG=0;
        END;
        SUBSCRIPT_LEVEL=SUBSCRIPT_LEVEL+FIXL(MP);
        PTR(MP)=PUSH_INDIRECT(1);
        PSEUDO_FORM(PTR_TOP)=0;
        LOC_P(PTR_TOP),INX(PTR_TOP)=0;
        END;
    elif PRODUCTION_NUMBER in (247, 248, 249, 250, 251, 252, 253, 254):
        # <AND> ::= &
        # <AND> ::= AND
        # <OR> ::= |
        # <OR> ::= OR
        # <NOT> ::= not 
        # <NOT> ::= NOT
        # <CAT> ::= +
        # <CAT> ::= CAT
        pass
    elif PRODUCTION_NUMBER == 255:
        #  <QUALIFIER>  ::=  <$>  (  @  <PREC SPEC>  )
        PSEUDO_FORM(PTR(MP))=PTR(MP+3);
        GO TO SS_CHEX;
    elif PRODUCTION_NUMBER == 256:
        #  <QUALIFIER> ::= <$> ( <SCALE HEAD> <ARITH EXP> )
        PSEUDO_FORM(PTR(MP))=0xF0;
        INX(PTR(SP-1))=PTR(SP-2);
        GO TO SS_CHEX;
    elif PRODUCTION_NUMBER == 257:
        #<QUALIFIER>::=<$>(@<PREC SPEC>,<SCALE HEAD><ARITH EXP>)
        PSEUDO_FORM(PTR(MP))=0xF0|PTR(MP+3);
        INX(PTR(SP-1))=PTR(SP-2);
        GO TO SS_CHEX;
    elif PRODUCTION_NUMBER == 258:
        #  <SCALE HEAD>  ::=  @
        PTR(MP)=0;
    elif PRODUCTION_NUMBER == 259:
        #  <SCALE HEAD> ::=  @ @
        PTR(MP)=1;
    elif PRODUCTION_NUMBER == 260:
        # <BIT QUALIFIER> ::= <$(> @ <RADIX> )
        if TEMP3==0: 
            TEMP3=2;
        PSEUDO_FORM(PTR(MP))=TEMP3;
        SS_CHEX:
        if SUBSCRIPT_LEVEL > 0:
            SUBSCRIPT_LEVEL=SUBSCRIPT_LEVEL-1;
    elif PRODUCTION_NUMBER == 261:
        #  <RADIX> ::= HEX
        TEMP3=4;
    elif PRODUCTION_NUMBER == 262:
        #  <RADIX> ::= OCT
        TEMP3=3;
    elif PRODUCTION_NUMBER == 263:
        #  <RADIX> ::= BIN
        TEMP3=1;
    elif PRODUCTION_NUMBER == 264:
        # <RADIX> ::= DEC
        TEMP3=0;
    elif PRODUCTION_NUMBER == 265:
        #  <BIT CONST HEAD> ::= <RADIX>
        FIXL(MP)=1;
    elif PRODUCTION_NUMBER == 266:
        #  <BIT CONST HEAD>  ::=  <RADIX>  (  <NUMBER>  )
        TOKEN_FLAGS(STACK_PTR(SP)) = TOKEN_FLAGS(STACK_PTR(SP)) | 0x20;
        if FIXV(MP+2)==0:
            ERROR(d.CLASS_LB,8);
            FIXL(MP)=1;
        else:
            FIXL(MP)=FIXV(MP+2);
    elif PRODUCTION_NUMBER == 267:
        #  <BIT CONST> ::= <BIT CONST HEAD> <CHAR STRING>
        S = VAR(SP);
        I = 1;
        K = LENGTH(S);
        L=FIXL(MP);
        TEMP_SYN = 0;  #  START WITH VALUE CALC. = O
        # DO CASE TEMP3;
        if TEMP3 == 0:
            C = 'D';
            if L != 1:
                ERROR(d.CLASS_LB,2);
                L = 1;
            TEMP2 = 0;  #  INDICATE START FROM 1ST CHAR
            if SUBSTR(S, TEMP2) > '2147483647': DO;
                ERROR(d.CLASS_LB,1);
                GO TO DO_BIT_CONSTANT_END;
            for TEMP in range(TEMP2, 1 + LENGTH(S) - 1):  #  CHECK FOR CHAR 1 TO 9
                l.H1=BYTE(S,TEMP);
                if not ((l.H1>=BYTE('0'))&(l.H1<=BYTE('9'))): 
                    ERROR(d.CLASS_LB,4);
                    TEMP_SYN = 0;
                    GO TO DO_BIT_CONSTANT_END;
                else:
                    TEMP_SYN = TEMP_SYN * 10;  #  ADD IN NEXT DIGIT
                    TEMP_SYN=TEMP_SYN+(l.H1&0x0F);
            #  END OF DO FOR
            I = 1;
            while SHR(TEMP_SYN, I) != 0:
                I = I + 1;
            GO TO DO_BIT_CONSTANT_END;
            #  END OF CASE 0
        elif TEMP3 == 1:
            # CASE 1, BIN
            DO;
            C = 'B';
            DO TEMP = 0, 1 + LENGTH(S)-1;  #  CHECK FOR '0' OR '1'
               l.H1=BYTE(S,TEMP);
               if not ((l.H1==BYTE('0')) or (l.H1==BYTE('1'))): DO;
                  ERROR(d.CLASS_LB,5);
                  TEMP_SYN = 0;
                  GO TO DO_BIT_CONSTANT_END;
               END;
               ELSE DO;
                  TEMP_SYN = SHL(TEMP_SYN,1);  #  ADDIN NEXT VALUE
                  TEMP_SYN=TEMP_SYN|(l.H1&0x0F);
               END;
            END;
            END;  #  END OF CASE 1
        elif TEMP3 == 2:
            # CASE 2, NO RADIX BASE 2 AT MOMENT
            pass;
        elif TEMP3 == 3:
            # CASE 3, OCT
            C = 'O';
            for TEMP in range(0, 1 + LENGTH(S)-1):  #  CHECK FOR OCTAL CHARACTERS
                l.H1=BYTE(S,TEMP);
                if not ((l.H1>=BYTE('0')) and (l.H1<=BYTE('7'))):
                    ERROR(d.CLASS_LB,6);
                    TEMP_SYN = 0;
                    GO TO DO_BIT_CONSTANT_END;
                else:
                    TEMP_SYN = SHL(TEMP_SYN,3);  #  ADD IN NEXT VALUE
                    TEMP_SYN=TEMP_SYN|(l.H1&0x0F);
            #  END OF CASE 3
        elif TEMP3 == 4:
            # CASE 4, HEX
            C = 'H';
            DO TEMP = 0, 1 + LENGTH(S)-1;  #  CHECK FOR HEXADECIMAL CHARACTERS
                l.H1=BYTE(S,TEMP);
                if not ((l.H1>=BYTE('0')) and (l.H1<=BYTE('9'))):
                    if not ((l.H1>=BYTE('A')) and (l.H1<=BYTE('F'))):
                        ERROR(d.CLASS_LB,7);
                        TEMP_SYN = 0;
                        GO TO DO_BIT_CONSTANT_END;
                    else:
                        TEMP_SYN = SHL(TEMP_SYN,4);  #  GET NEW VAL WITH NUM.DIG.
                        TEMP_SYN=TEMP_SYN+9+(l.H1&0x0F);
                else:
                   TEMP_SYN = SHL(TEMP_SYN,4);  #  ADD IN NUM. VALUE
                   TEMP_SYN=TEMP_SYN+(l.H1&0x0F);
            # END OF CASE 4
        #  END OF DO CASE
        #  INCORPORATE REPETITION FACTOR
        TEMP2=TEMP_SYN;
        J=TEMP3*K;
        for TEMP in range(2, 1 + L):
            TEMP_SYN=SHL(TEMP_SYN,J)|TEMP2;
        I=J*L;
        if I>BIT_LENGTH_LIM: 
            if I-TEMP3 < BIT_LENGTH_LIM:
                l.H1 = BYTE(S);
                if l.H1 >= BYTE('A') and l.H1 <= BYTE('F'): 
                    l.H1 = l.H1 + 9;
                l.H1 = l.H1 & 0x0F;
                if SHR(l.H1,BIT_LENGTH_LIM+TEMP3-I) != 0:
                    ERROR(d.CLASS_LB,1);
            else:
                ERROR(d.CLASS_LB,1);
            I=BIT_LENGTH_LIM;
        DO_BIT_CONSTANT_END:
        PTR(MP)=PUSH_INDIRECT(1);
        PSEUDO_TYPE(PTR(MP)) = BIT_TYPE;
        PSEUDO_FORM(PTR(MP)) = XLIT;
        PSEUDO_LENGTH(PTR(MP)) = I;
        LOC_P(PTR(MP))=SAVE_LITERAL(2,TEMP_SYN,I);
    elif PRODUCTION_NUMBER == 268:
        # <BIT CONST> ::= TRUE
        TEMP_SYN=1;
        DO_BIT_CONST:
        I=1;
        GO TO DO_BIT_CONSTANT_END;
    elif PRODUCTION_NUMBER == 269:
        # <BIT CONST> ::= FALSE
        TEMP_SYN=0;
        GO TO DO_BIT_CONST;
    elif PRODUCTION_NUMBER == 270:
        # <BIT CONST> ::= ON
        TEMP_SYN=1;
        GO TO DO_BIT_CONST;
    elif PRODUCTION_NUMBER == 271:
        # <BIT CONST> ::= OFF
        TEMP_SYN=0;
        GO TO DO_BIT_CONST;
    elif PRODUCTION_NUMBER == 272:
        #  <CHAR CONST>  ::=  <CHAR STRING>
        CHAR_LITS:
        PTR(MP)=PUSH_INDIRECT(1);
        LOC_P(PTR(MP))=SAVE_LITERAL(0,VAR(MP));
        PSEUDO_FORM(PTR(MP))=XLIT;
        PSEUDO_TYPE(PTR(MP))=CHAR_TYPE;
        PSEUDO_LENGTH(PTR(MP))=LENGTH(VAR(MP));
    elif PRODUCTION_NUMBER == 273:
        #  <CHAR CONST>  ::=  CHAR  (  <NUMBER>  )  <CHAR STRING>
        TOKEN_FLAGS(STACK_PTR(SP - 1)) = TOKEN_FLAGS(STACK_PTR(SP - 1)) | 0x20;
        VAR(MP)=VAR(SP);
        TEMP=FIXV(MP+2);
        if TEMP<1: 
            ERROR(d.CLASS_LS,2);
        else:
            while TEMP>1:
                TEMP=TEMP-1;
                TEMP2=CHAR_LENGTH_LIM-LENGTH(VAR(MP));
                if TEMP2<FIXV(SP): 
                    TEMP=0;
                    ERROR(d.CLASS_LS,1);
                    S=SUBSTR(VAR(SP),0,TEMP2);
                    VAR(MP)=VAR(MP)+S;
                else:
                    VAR(MP)=VAR(MP)+VAR(SP);
        GO TO CHAR_LITS;
    elif PRODUCTION_NUMBER == 274:
        #  <IO CONTROL>  ::=  SKIP  (  <ARITH EXP>  )
        TEMP=3;
        IO_CONTROL:
        if UNARRAYED_INTEGER(SP-1): 
            ERROR(d.CLASS_TC,1);
        VAL_P(PTR(MP))=0;
        PTR(MP)=PTR(SP-1);
    elif PRODUCTION_NUMBER == 275:
        #  <IO CONTROL>  ::=  TAB  (  <ARITH EXP>  )
        TEMP=1;
        GO TO IO_CONTROL;
    elif PRODUCTION_NUMBER == 276:
        #  <IO CONTROL>  ::=  COLUMN  (  <ARITH EXP>  )
        TEMP=2;
        GO TO IO_CONTROL;
    elif PRODUCTION_NUMBER == 277:
        #  <IO CONTROL>  ::=  LINE  (  <ARITH EXP>  )
        TEMP=4;
        GO TO IO_CONTROL;
    elif PRODUCTION_NUMBER == 278:
        #  <IO CONTROL>  ::=  PAGE  (  <ARITH EXP>  )
        TEMP=5;
        GO TO IO_CONTROL;
    elif PRODUCTION_NUMBER == 279:
        #  <READ PHRASE>  ::=  <READ KEY>  <READ ARG>
        CHECK_READ:
        if INX(PTR(MP))==0: 
            if SHR(VAL_P(PTR(SP)),7): ERROR(d.CLASS_T,3);
            if PSEUDO_TYPE(PTR(SP))==EVENT_TYPE: ERROR(d.CLASS_T,2);
        elif TEMP>0: 
            pass;
        elif READ_ALL_TYPE(SP): 
            ERROR(d.CLASS_T,1);
    elif PRODUCTION_NUMBER == 280:
        #  <READ PHRASE>  ::=  <READ PHRASE>  ,  <READ ARG>
        GO TO CHECK_READ;
    elif PRODUCTION_NUMBER == 281:
        #  <WRITE PHRASE>  ::=  <WRITE KEY>  <WRITE ARG>
        pass;
    elif PRODUCTION_NUMBER == 282:
        #  <WRITE PHRASE>  ::=  <WRITE PHRASE>  ,  <WRITE ARG>
        pass;
    elif PRODUCTION_NUMBER == 283:
        #  <READ ARG>  ::=  <VARIABLE>
        TEMP=0;
        EMIT_IO_ARG:
        if KILL_NAME(MP): 
            ERROR(d.CLASS_T,5);
        if INLINE_LEVEL>0: 
            ERROR(d.CLASS_PP,5);
        HALMAT_TUPLE(XXXAR,XCO_N,MP,0,0);
        HALMAT_FIX_PIPTAGS(NEXT_ATOMp-1,PSEUDO_TYPE(PTR(MP)),TEMP);
        if PSEUDO_TYPE(PTR(MP))==MAJ_STRUC:
            if (SYT_FLAGS(VAR_LENGTH(FIXV(MP)))&MISC_NAME_FLAG)!=0:
                ERROR(d.CLASS_T,6);
        EMIT_ARRAYNESS();
        PTR_TOP=PTR(MP)-1;
    elif PRODUCTION_NUMBER == 284:
        #  <READ ARG>  ::=  <IO CONTROL>
        GO TO EMIT_IO_ARG;
    elif PRODUCTION_NUMBER == 285:
        #  <WRITE ARG>  ::=  <EXPRESSION>
        TEMP=0;
        GO TO EMIT_IO_ARG;
    elif PRODUCTION_NUMBER == 286:
        #  <WRITE ARG>  ::=  <IO CONTROL>
        GO TO EMIT_IO_ARG;
    elif PRODUCTION_NUMBER == 287:
        #  <READ KEY>  ::=  READ  (  <NUMBER>  )
        TEMP=0;
        EMIT_IO_HEAD:
        XSET SHL(TEMP,11);
        HALMAT_POP(XXXST,1,XCO_N,0);
        HALMAT_PIP(TEMP,XIMD,0,0);
        PTR(MP)=PUSH_INDIRECT(1);
        if FIXV(MP+2)> DEVICE_LIMIT: 
            ERROR(d.CLASS_TD,1,''+DEVICE_LIMIT);
            LOC_P(PTR(MP))=0;
        else:
            LOC_P(PTR(MP))=FIXV(MP+2);
            I=IODEV(FIXV(MP+2));
            if (I&0x28)==0: 
                if TEMP==2: 
                    if (I&0x01)==0: 
                        I=I|0x04;
                    else:
                        I=I|0x02;
                else:
                    I=I|0x01;
                    if (I&0x04)!=0: 
                        if (I&0x40)!=0: 
                            I=I|0x80;
                        else:
                            I=(I&0xFB)|0x02;
            IODEV(FIXV(MP+2))=I;
        PSEUDO_FORM(PTR(MP))=XIMD;
        INX(PTR(MP))=TEMP;
        if UPDATE_BLOCK_LEVEL>0: 
            ERROR(d.CLASS_UT,1);
    elif PRODUCTION_NUMBER == 288:
        #  <READ KEY>  ::=  READALL  (  <NUMBER>  )
        TEMP=1;
        GO TO EMIT_IO_HEAD;
    elif PRODUCTION_NUMBER == 289:
        #  <WRITE KEY>  ::=  WRITE  (  <NUMBER>  )
        TEMP=2;
        GO TO EMIT_IO_HEAD;
    elif PRODUCTION_NUMBER == 290:
        #  <BLOCK DEFINITION> ::= <BLOCK STMT> <BLOCK BODY> <CLOSING> ;
        TEMP=XCLOS;
        TEMP2=0;
        CLOSE_SCOPE:
        HALMAT_POP(TEMP,1,0,TEMP2);
        HALMAT_PIP(BLOCK_SYTREF(NEST),XSYT,0,0);
        for I in range(0, 1 + NDECSY - REGULAR_PROCMARK):
            J = NDECSY - I;
            if (SYT_FLAGS(J) & INACTIVE_FLAG) == 0:
                CLOSE_BCD = SYT_NAME(J);
                if SYT_CLASS(J) == FUNC_CLASS:
                    if (SYT_FLAGS(J) & DEFINED_LABEL) == 0:
                       ERROR(d.CLASS_PL, 1, CLOSE_BCD);
                    DISCONNECT(J);
                elif SYT_CLASS(J) == LABEL_CLASS:
                    if (SYT_FLAGS(J) & DEFINED_LABEL) == 0:
                        # UNDEFINED CALLABLE LABEL
                        if SYT_TYPE(J) == STMT_LABEL:
                            DISCONNECT(J);
                            ERROR(d.CLASS_PL, 5, CLOSE_BCD);
                        # UNDEFINED OBJECT OF GO TO
                        else:
                            # CALLED/SCHED BUT UNDEFINED PROCS/TASKS
                            if NEST==1:
                                ''' CLOSING PROGRAM -
                                    MAKE UNDEFINED CALLS/SCHEDS
                                    INTO ERRORS '''
                                 ERROR(d.CLASS_PL, 6, CLOSE_BCD);
                                 DISCONNECT(J);
                            else:
                                SET_OUTER_REF(J,0x6000);
                                SYT_NEST(J)=NEST-1;
                        # END OF CALLED LABELS
                    # END OF UNDEFINED CALLABLE LABELS
                    elif SYT_TYPE(J) == IND_CALL_LAB:
                        SYT_NEST(J) = NEST - 1;
                        K = SYT_PTR(J);
                        while SYT_TYPE(K) = IND_CALL_LAB:
                            K = SYT_PTR(K);
                        if SYT_NEST(K) >= SYT_NEST(J):
                            ''' IND CALL HAS REACHED SAME SCOPE AS
                                DEFINITION OF LABEL. SO LEAVE
                                AS IND CALL AND DISCONNECT FROM SYT '''
                            if SYT_PTR(J) == K:
                                if SYT_LINK1(K) < 0:
                                    if DO_LEVEL < (-SYT_LINK1(K)):
                                        ERROR(d.CLASS_PL, 11, CLOSE_BCD);
                            DISCONNECT(J);
                            TIE_XREF(J);
                    # END OF TYPE = IND_CALL_LAB
                    else:
                        DISCONNECT(J); # NONE OF THE ABOVE
                # END OF LABEL CLASS
                else:
                    DISCONNECT(J);  # ALL OTHER CLASSES
        if BLOCK_MODE(NEST)==UPDATE_MODE:
            UPDATE_BLOCK_LEVEL = UPDATE_BLOCK_LEVEL - 1;
        if LENGTH(VAR(SP-1)) > 0:
            if VAR(SP-1) != CURRENT_SCOPE:
                ERROR(d.CLASS_PL,3,CURRENT_SCOPE);
        if REGULAR_PROCMARK > NDECSY:    # NO LOCAL NAMES
            SYT_PTR(FIXL(MP)) = 0;
        if (SYT_FLAGS(FIXL(MP)) & ACCESS_FLAG) != 0:
            if BLOCK_MODE(NEST) == CMPL_MODE:
                for I in range(FIXL(MP), 1 + NDECSY):
                    SYT_FLAGS(I) = SYT_FLAGS(I) | READ_ACCESS_FLAG;
        ''' IF THIS IS THE CLOSE OF A COMPOOL INCLUDED REMOTE
            THEN MAKE SURE THAT ALL OF THE ITEMS IN THE COMPOOL
            ARE ALSO FLAGED AS REMOTE - EXCEPT FOR NAME TYPES AND
            STRUCTURE TEMPLATE VARIABLES. '''
        if ((SYT_FLAGS(FIXL(MP)) & EXTERNAL_FLAG) != 0) \
                and ((SYT_FLAGS(FIXL(MP)) & REMOTE_FLAG) != 0):
            if BLOCK_MODE(NEST) == CMPL_MODE:
                for I in range(FIXL(MP), 1 + NDECSY):
                    # IF 16-BIT NAME VARIABLE WAS INITIALIZED TO NON-REMOTE VARIABLE IN
                    # A REMOTELY INCLUDED COMPOOL, IT IS NOW INVALID.
                    
                    def TEMPL_INITIAL_CHECK():
                        # IS POINTED TO BY A NAME VARIABLE
                        if (SYT_FLAGS(I) & MISC_NAME_FLAG) != 0:
                            if SYT_TYPE(I) != TEMPL_NAME: # NOT A TEMPLATE
                                                          # NON-REMOTE
                                if (SYT_FLAGS(I) & REMOTE_FLAG) == 0:
                                    ERROR(d.CLASS_DI,21);
           
                    TEMPL_INITIAL_CHECK();
                    # INCLUDED_REMOTE MEANS VARIABLE LIVES REMOTE ONLY BECAUSE
                    # IT WAS INCLUDED REMOTE (IT RESIDES IN #P, NOT IN #R)
                    if (SYT_CLASS(I) != TEMPLATE_CLASS): 
                            # NOT A NAME VARIABLE AND NOT INITIALLY DECLARED REMOTE
                            if ((SYT_FLAGS(I) & NAME_FLAG) == 0) and \
                                    ((SYT_FLAGS(I) & REMOTE_FLAG) = 0):
                                SYT_FLAGS(I) = SYT_FLAGS(I) | REMOTE_FLAG | \
                                                INCLUDED_REMOTE;
                                # FOR NAME VARIABLES, SET THAT THEY NOW LIVE REMOTE
                                if ((SYT_FLAGS(I) & NAME_FLAG) != 0):
                                    SYT_FLAGS(I) = SYT_FLAGS(I) | \
                                                    INCLUDED_REMOTE;

        SYT_FLAGS(NDECSY) = SYT_FLAGS(NDECSY) | ENDSCOPE_FLAG;
        CURRENT_SCOPE = VAR(MP);
        if PTR(MPP1): 
            # DO CASE EXTERNAL_MODE;
            if EXTERNAL_MODE == 0:
                #  NOT EXTERNAL
                if BLOCK_MODE(NEST)==CMPL_MODE: ERROR(d.CLASS_PC,1);
            elif EXTERNAL_MODE == 1:
                #  PROC MODE
                ERROR(d.CLASS_PS,1);
            elif EXTERNAL_MODE == 2:
                #  FUNC MODE
                ERROR(d.CLASS_PS,1);
            elif EXTERNAL_MODE == 3:
                #  COMPOOL MODE
                ERROR(d.CLASS_PC,2);
            elif EXTERNAL_MODE == 4:
                # PROGRAM MODE
                ERROR(d.CLASS_PS,1);
        OUTPUT_WRITER();
        EMIT_SMRK();
        if BLOCK_MODE(NEST)==INLINE_MODE: 
            INLINE_INDENT_RESET=EXT_P(PTR(MP));
            INDENT_LEVEL=INLINE_INDENT+INDENT_INCR;
            INLINE_STMT_RESET=STMT_NUM;
            STMT_NUM=INX(PTR(MP));
            INX(PTR(MP)) = 0;
            if PSEUDO_TYPE(PTR(MP))==MAJ_STRUC: 
                FIXL(MP)= PSEUDO_LENGTH(PTR(MP));
            RESET_ARRAYNESS();
            INLINE_LEVEL=INLINE_LEVEL-1;
            NEST_LEVEL = NEST_LEVEL - 1;
            if INLINE_LEVEL==0: 
                STAB_MARK = 0
                STAB2_MARK = 0;
                XSET STAB_STACK;
                SRN_FLAG=FALSE;
                SRN(2)=SRN_MARK;
                INCL_SRN(2) = INCL_SRN_MARK;
                SRN_COUNT(2)=SRN_COUNT_MARK;
            FIXF(MP)=0;
        else:
            BLOCK_SUMMARY();
            OUTER_REF_INDEX=(OUTER_REF_PTR(NEST)&0x7FFF)-1;
            INDENT_LEVEL = INDENT_STACK(NEST);
            NEST_LEVEL = NEST_STACK(NEST);
        REGULAR_PROCMARK=PROCMARK_STACK(NEST);
        PROCMARK = REGULAR_PROCMARK
        SCOPEp = SCOPEp_STACK(NEST);
        I=0;
        while ON_ERROR_PTR<-SYT_ARRAY(BLOCK_SYTREF(NEST)):
            if EXT_ARRAY(ON_ERROR_PTR)==0x3FFF: 
                I=I+0x1001;
            else:
                I=I+1;
            ON_ERROR_PTR=ON_ERROR_PTR+1;
        SYT_ARRAY(BLOCK_SYTREF(NEST))=I|0xE000;
        NEST = NEST - 1;
        DO_INX(DO_LEVEL)=DO_INX(DO_LEVEL)&0x7F;
        if NEST==0:
            if EXTERNAL_MODE>0: 
                if SIMULATING==2:
                    STMT_TYPE=0;
                    SIMULATING=1;
                EXTERNAL_MODE=0;
                TPL_VERSION=BLOCK_SYTREF(NEST+1);
                SYT_LOCKp(TPL_VERSION)=0;
            elif BLOCK_MODE>0:
                if EXTERNALIZE==4: 
                    EXTERNALIZE=2;
                EMIT_EXTERNAL();
    elif PRODUCTION_NUMBER == 291:
        #  <BLOCK BODY>  ::= <EMPTY>
        HALMAT_POP(XEDCL,0,XCO_N,0);
        GO TO CHECK_DECLS;
    elif PRODUCTION_NUMBER == 292:
        #  <BLOCK BODY>  ::=  <DECLARE GROUP>
        HALMAT_POP(XEDCL, 0, XCO_N, 1);
        CHECK_DECLS:
        I = BLOCK_MODE(NEST);
        if (I == FUNC_MODE) or (I == PROC_MODE): 
            J=BLOCK_SYTREF(NEST);  # PROC FUNC NAME
            if SYT_PTR(J) != 0: 
                J = SYT_PTR(J);  # POINT TO FIRST ARG
                while (SYT_FLAGS(J) & PARM_FLAGS) != 0:
                    if (SYT_FLAGS(J) & IMP_DECL) != 0:
                        # UNDECLARED PARAMETER
                        ERROR(d.CLASS_DU, 2, SYT_NAME(J));
                        PARMS_PRESENT=0;
                        SYT_TYPE(J) = DEFAULT_TYPE;
                        SYT_FLAGS(J) = SYT_FLAGS(J) | DEFAULT_ATTR;
                    J = J + 1;  # NEXT PARAMETER
                if (EXTERNAL_MODE > 0) and (EXTERNAL_MODE < CMPL_MODE):
                    while J <= NDECSY:
                        if SYT_CLASS(J)<REPL_ARG_CLASS:
                            ERROR(d.CLASS_DU, 3, SYT_NAME(J));
                            SYT_FLAGS(J) = SYT_FLAGS(J) | DUMMY_FLAG;
                    J = J + 1;
                END;
        if EXTERNALIZE: 
            EXTERNALIZE=4;
        PTR(MP)=0;
    elif PRODUCTION_NUMBER == 293:
        #  <BLOCK BODY>  ::=  <BLOCK BODY>  <ANY STATEMENT>
        PTR(MP)=1;
    elif PRODUCTION_NUMBER == 294:
        #  <ARITH INLINE DEF>  ::=  FUNCTION <ARITH SPEC>  ;
        if TYPE==0: 
            TYPE=DEFAULT_TYPE;
        if (ATTRIBUTES&SD_FLAGS)==0: 
            ATTRIBUTES=ATTRIBUTES|(DEFAULT_ATTR&SD_FLAGS);
        if TYPE<SCALAR_TYPE: 
            TEMP=TYPE(TYPE);
        else:
            TEMP=0;
        INLINE_DEFS:
        if CONTEXT==EXPRESSION_CONTEXT: 
            ERROR(d.CLASS_PP,11);
        CONTEXT=0;
        GRAMMAR_FLAGS(STACK_PTR(MP))=GRAMMAR_FLAGS(STACK_PTR(MP))|INLINE_FLAG;
        PTR(MP)=PUSH_INDIRECT(1);
        INLINE_LEVEL=INLINE_LEVEL+1;
        if INLINE_LEVEL>1: 
            ERROR(d.CLASS_PP,10);
        else:
            STAB_MARK=STAB_STACKTOP;
            STAB2_MARK = STAB2_STACKTOP;
            STAB_STACK=STMT_TYPE;
            SRN_MARK=SRN(2);
            INCL_SRN_MARK = INCL_SRN(2);
            SRN_COUNT_MARK=SRN_COUNT(2);
            STMT_TYPE=0;
        INLINE_LABEL=INLINE_LABEL+1;
        VAR(MP)=l.INLINE_NAME+INLINE_LABEL;
        NAME_HASH=HASH(VAR(MP),SYT_HASHSIZE);
        FIXL(MP)=ENTER(VAR(MP),FUNC_CLASS);
        FIXL(MP) = I
        if SIMULATING: 
            STAB_LAB(I);
        SET_XREF(I,XREF_REF);
        SYT_TYPE(I)=TYPE;
        SYT_FLAGS(I)=SYT_FLAGS(I)|DEFINED_LABEL|ATTRIBUTES;
        VAR_LENGTH(I)=TEMP;
        HALMAT_POP(XIDEF,1,0,INLINE_LEVEL);
        HALMAT_PIP(I,XSYT,0,0);
        SETUP_VAC(MP,TYPE,TEMP);
        TEMP2=INLINE_MODE;
        for I in range(0, 1 + FACTOR_LIM):
            TYPE(I)=0;
        SAVE_ARRAYNESS();
        if (SUBSCRIPT_LEVEL|EXPONENT_LEVEL)!=0: 
            ERROR(d.CLASS_B,2);
        GO TO INLINE_ENTRY;
    elif PRODUCTION_NUMBER == 295:
        #  <ARITH INLINE DEF>  ::=  FUNCTION  ;
        TYPE=DEFAULT_TYPE;
        ATTRIBUTES=DEFAULT_ATTR&SD_FLAGS;
        TEMP=0;
        GO TO INLINE_DEFS;
    elif PRODUCTION_NUMBER == 296:
        #  <BIT INLINE DEF>  ::=  FUNCTION <BIT SPEC>  ;
        TEMP=BIT_LENGTH;
        GO TO INLINE_DEFS;
    elif PRODUCTION_NUMBER == 297:
        #  <CHAR INLINE DEF>  ::=  FUNCTION <CHAR SPEC>  ;
        if CHAR_LENGTH<0:
            ERROR(d.CLASS_DS,3);
            TEMP=DEF_CHAR_LENGTH;
        else:
            TEMP=CHAR_LENGTH;
        GO TO INLINE_DEFS;
    elif PRODUCTION_NUMBER == 298:
        #  <STRUC INLINE DEF>  ::=  FUNCTION <STRUCT SPEC>  ;
        if STRUC_DIM!=0: 
            ERROR(d.CLASS_DD,12);
            STRUC_DIM=0;
        TEMP=STRUC_PTR;
        TYPE=MAJ_STRUC;
        GO TO INLINE_DEFS;
    elif PRODUCTION_NUMBER == 299:
        #  <BLOCK STMT>  ::=  <BLOCK STMT TOP>  ;
        OUTPUT_WRITER();
        if PARMS_PRESENT<=0: 
            if EXTERNALIZE: EXTERNALIZE=4;
        INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
        if TPL_REMOTE:
            if EXTERNAL_MODE>0 and NEST==1 and BLOCK_MODE(NEST)==CMPL_MODE:
                SYT_FLAGS(FIXL(MP)) = SYT_FLAGS(FIXL(MP)) | REMOTE_FLAG;
            else:
                ERROR(d.CLASS_PS,13);
        TPL_REMOTE = FALSE;
        EMIT_SMRK();
    elif PRODUCTION_NUMBER == 300:
        #  <BLOCK STMT TOP> ::= <BLOCK STMT TOP> ACCESS
        if BLOCK_MODE(NEST)>PROG_MODE:
            ERROR(d.CLASS_PS,3);
        elif NEST != 1: 
            ERROR(d.CLASS_PS, 4);
        elif (SYT_FLAGS(FIXL(MP))&ACCESS_FLAG)!=0: 
            ERROR(d.CLASS_PS,10);
        else:
            SYT_FLAGS(FIXL(MP)) = SYT_FLAGS(FIXL(MP)) | ACCESS_FLAG;
            ACCESS_FOUND = TRUE;
    elif PRODUCTION_NUMBER == 301:
        #  <BLOCK STMT TOP>  ::= <BLOCK STMT TOP> RIGID
        if BLOCK_MODE(NEST)!=CMPL_MODE: 
            ERROR(d.CLASS_PS,12);
        elif (SYT_FLAGS(FIXL(MP)) and RIGID_FLAG)!=0: 
            ERROR(d.CLASS_PS,11);
        else:
            SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|RIGID_FLAG;
    elif PRODUCTION_NUMBER == 302:
        #  <BLOCK STMT TOP>  ::=  <BLOCK STMT HEAD>
        pass;
    elif PRODUCTION_NUMBER == 303:
        #  <BLOCK STMT TOP>  ::=  <BLOCK STMT HEAD>  EXCLUSIVE
        if BLOCK_MODE(NEST)>FUNC_MODE: 
            ERROR(d.CLASS_PS,2,'EXCLUSIVE');
        SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|EXCLUSIVE_FLAG;
    elif PRODUCTION_NUMBER == 304:
        #  <BLOCK STMT TOP>  ::=  <BLOCK STMT HEAD>  REENTRANT
        if BLOCK_MODE(NEST)>FUNC_MODE: 
            ERROR(d.CLASS_PS,2,'REENTRANT');
        SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|REENTRANT_FLAG;
    elif PRODUCTION_NUMBER == 305:
        #  <LABEL DEFINITION>  ::=  <LABEL>  :
        if NEST==0: 
            EXTERNAL_MODE=0;
        HALMAT_POP(XLBL,1,XCO_N,0);
        HALMAT_PIP(FIXL(MP),XSYT,0,0);
        TEMP=FIXL(MP);
        if SYT_TYPE(TEMP) != IND_CALL_LAB: 
            if SYT_LINK1(TEMP)>0: 
                if DO_LEVEL>0:
                    if DO_STMTp(DO_LEVEL) > SYT_LINK1(TEMP):
                        if SYT_TYPE(TEMP) == STMT_LABEL: 
                            ERROR(d.CLASS_GL, 2);
                        else:
                            ERROR(d.CLASS_PL, 10);
            if SYT_LINK1(TEMP) >= 0: 
                SYT_LINK1(TEMP) = -DO_LEVEL;
                SYT_LINK2(TEMP) = SYT_LINK2(0);
                SYT_LINK2(0) = TEMP;
        LABEL_COUNT=LABEL_COUNT+1;
        if SIMULATING: 
            STAB_LAB(FIXL(MP));
        GRAMMAR_FLAGS(STACK_PTR(MP))=GRAMMAR_FLAGS(STACK_PTR(MP))|LABEL_FLAG;
        # IF THE XREF ENTRY IS FOR THE LABEL'S DEFINITION (FLAG=0),
        # THEN CHECK THE STATEMENT NUMBER.  IF IT IS NOT EQUAL TO CURRENT
        # STATEMENT NUMBER, CHANGE IT TO THE CURRENT STATEMENT NUMBER.
         if (SHR(XREF(SYT_XREF(FIXL(MP))),13) & 7) == 0:
            if (XREF(SYT_XREF(FIXL(MP))) & XREF_MASK) != STMT_NUM:
                XREF(SYT_XREF(FIXL(MP))) = \
                    (XREF(SYT_XREF(FIXL(MP))) & 0xFFFFE000) | STMT_NUM;
        if SYT_TYPE(FIXL(MP))==STMT_LABEL:
            NO_NEW_XREF = TRUE;
            SET_XREF(FIXL(MP),0);
    elif PRODUCTION_NUMBER == 306:
        #  <LABEL EXTERNAL>  ::=  <LABEL DEFINITION>
        pass;
    elif PRODUCTION_NUMBER == 307:
        #  <LABEL EXTERNAL>  ::=  <LABEL DEFINITION>  EXTERNAL
        if NEST>0: 
            ERROR(d.CLASS_PE,1);
        else:
            SYT_FLAGS(FIXL(MP)) = SYT_FLAGS(FIXL(MP)) | EXTERNAL_FLAG;
            EXTERNAL_MODE=1;   # JUST A FLAG FOR NOW
            if BLOCK_MODE>0: 
                ERROR(d.CLASS_PE,2);
            if SIMULATING:
                STAB2_STACKTOP = STAB2_STACKTOP - 1;
                SIMULATING=2;
    elif PRODUCTION_NUMBER == 308:
        #  <BLOCK STMT HEAD>  ::=  <LABEL EXTERNAL>  PROGRAM
        TEMP=XMDEF;
        PARMS_PRESENT=0;
        TEMP2=PROG_MODE;
        SET_LABEL_TYPE(FIXL(MP),PROG_LABEL);
        SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|LATCHED_FLAG;
        if EXTERNAL_MODE>0:
            if NEST==0: 
                EXTERNAL_MODE=TEMP2;
            GO TO NEW_SCOPE;
        OUTERMOST_BLOCK:
        if NEST>0: 
            ERROR(d.CLASS_PP,1,VAR(MPP1));
        else:
            DUPLICATE_BLOCK:
            if BLOCK_MODE==0: 
                MAIN_SCOPE=MAX_SCOPEp+1;  # WHAT SYT_SCOPE WILL BECOME
                FIRST_STMT = STMT_NUM;
                BLOCK_MODE=TEMP2;
                if BLOCK_MODE<TASK_MODE: 
                    if TPL_FLAG<3: 
                        EXTERNALIZE=3;
                MONITOR(17,DESCORE(VAR(MP)));
                EMIT_EXTERNAL();
           else:
               ERROR(d.CLASS_PP,2);
        GO TO NEW_SCOPE;
    elif PRODUCTION_NUMBER == 309:
        #  <BLOCK STMT HEAD>  ::=  <LABEL EXTERNAL>  COMPOOL
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
        if DATA_REMOTE and (EXTERNAL_MODE == 0):
            ERROR(d.CLASS_XR,2);
            DATA_REMOTE=FALSE;
        if EXTERNAL_MODE>0: 
            if NEST==0: 
                EXTERNAL_MODE=TEMP2;
            GO TO NEW_SCOPE;
        else:
            GO TO OUTERMOST_BLOCK;
    elif PRODUCTION_NUMBER == 310:
        #  <BLOCK STMT HEAD>  ::=  <LABEL DEFINITION>  TASK
        TEMP=XTDEF;
        TEMP2=TASK_MODE;
        SET_LABEL_TYPE(FIXL(MP),TASK_LABEL);
        SYT_FLAGS(FIXL(MP))=SYT_FLAGS(FIXL(MP))|LATCHED_FLAG;
        if NEST==1:
            if BLOCK_MODE(1) == PROG_MODE: 
                if DO_LEVEL > 1: 
                    ERROR(d.CLASS_PT, 2);
                GO TO NEW_SCOPE;
        ERROR(d.CLASS_PT,1);
        if NEST==0: 
            GO TO DUPLICATE_BLOCK;
        ELSE GO TO NEW_SCOPE;
    elif PRODUCTION_NUMBER == 311:
        #  <BLOCK STMT HEAD>  ::=  <LABEL DEFINITION>  UPDATE
        VAR_LENGTH(FIXL(MP))=1;
        HALMAT_BACKUP(LAST_POPp);
        UPDATE_HEAD:
        if UPDATE_BLOCK_LEVEL>0: 
            ERROR(d.CLASS_UI,2);
        UPDATE_BLOCK_LEVEL=UPDATE_BLOCK_LEVEL+1;
        TEMP2=UPDATE_MODE;
        TEMP=XUDEF;
        SET_LABEL_TYPE(FIXL(MP),STMT_LABEL);
        if NEST==0: 
            ERROR(d.CLASS_PP,3,VAR(MPP1));
            GO TO DUPLICATE_BLOCK;
        else:
            GO TO NEW_SCOPE;
    elif PRODUCTION_NUMBER == 312:
        #  <BLOCK STMT HEAD>  ::=  UPDATE
        VAR(MPP1)=VAR(MP);
        IMPLIED_UPDATE_LABEL=IMPLIED_UPDATE_LABEL+1;
        VAR(MP)=l.UPDATE_NAME+IMPLIED_UPDATE_LABEL;
        NAME_HASH=HASH(VAR(MP),SYT_HASHSIZE);
        I=ENTER(VAR(MP),LABEL_CLASS);
        FIXL(MP) = I)
        SYT_TYPE(I)=UNSPEC_LABEL;
        SYT_FLAGS(I)=SYT_FLAGS(I)|DEFINED_LABEL;
        VAR_LENGTH(I)=2;
        if SIMULATING: 
            STAB_LAB(FIXL(MP));
        GO TO UPDATE_HEAD;
    elif PRODUCTION_NUMBER == 313:
        #  <BLOCK STMT HEAD>  ::=  <FUNCTION NAME>
        FUNC_HEADER:
        if PARMS_PRESENT == 0:
            PARMS_WATCH = FALSE;
            if MAIN_SCOPE == SCOPEp: 
                COMSUB_END = FIXL(MP);
        FACTORING=TRUE;
        DO_INIT = FALSE;
        if TYPE == 0:
            TYPE = DEFAULT_TYPE;
        elif TYPE == EVENT_TYPE:
            ERROR(d.CLASS_FT, 3, SYT_NAME(ID_LOC));
            TYPE = DEFAULT_TYPE;
        if (ATTRIBUTES & SD_FLAGS) == 0:
            if (TYPE >= MAT_TYPE) and (TYPE <= INT_TYPE):
                ATTRIBUTES = ATTRIBUTES | (DEFAULT_ATTR & SD_FLAGS);
        if TYPE==MAJ_STRUC: 
            CHECK_STRUC_CONFLICTS();
        if SYT_TYPE(ID_LOC) == 0: 
            SET_SYT_ENTRIES();
        else:
            if SYT_TYPE(ID_LOC) != TYPE:
                ERROR(d.CLASS_DT, 1, SYT_NAME(ID_LOC));
            else:  # TYPES MATCH, WHAT ABOUT SIZES
               if TYPE <= VEC_TYPE:
                    if TYPE(TYPE) != VAR_LENGTH(ID_LOC):
                        ERROR(d.CLASS_FT, 4, SYT_NAME(ID_LOC));
               elif TYPE == MAJ_STRUC: 
                    if STRUC_PTR!=VAR_LENGTH(ID_LOC):
                        ERROR(d.CLASS_FT, 6, SYT_NAME(ID_LOC));
               if (ATTRIBUTES & SD_FLAGS) != 0:
                    if ((SYT_FLAGS(ID_LOC) & ATTRIBUTES) & SD_FLAGS) == 0:
                        ERROR(d.CLASS_FT, 7, SYT_NAME(ID_LOC));
            # END OF TYPES MATCH
            for I if range(0, 1 + FACTOR_LIM):
                TYPE(I) = 0;
    elif PRODUCTION_NUMBER == 314:
        #  <BLOCK STMT HEAD>  ::=  <FUNCTION NAME>  <FUNC STMT BODY>
        GO TO FUNC_HEADER;
    elif PRODUCTION_NUMBER == 315:
        #  <BLOCK STMT HEAD>  ::=  <PROCEDURE NAME>
        PARMS_WATCH = FALSE;
        if MAIN_SCOPE == SCOPEp: 
            COMSUB_END = FIXL(MP);
    elif PRODUCTION_NUMBER == 316:
        #  <BLOCK STMT HEAD>  ::=  <PROCEDURE NAME>  <PROC STMT BODY>
        pass;
    elif PRODUCTION_NUMBER == 317:
        #  <FUNCTION NAME>  ::=  <LABEL EXTERNAL>  FUNCTION
        ID_LOC=FIXL(MP);
        FACTORING=FALSE;
        if SYT_CLASS(ID_LOC)!=FUNC_CLASS:
            if SYT_CLASS(ID_LOC)!=LABEL_CLASS or SYT_TYPE(ID_LOC)!=UNSPEC_LABEL:
                ERROR(d.CLASS_PL,4);
            else:
                SYT_CLASS(ID_LOC)=FUNC_CLASS;
                SYT_TYPE(ID_LOC)=0;
        TEMP=XFDEF;
        TEMP2=FUNC_MODE;
        GO TO PROC_FUNC_HEAD;
    elif PRODUCTION_NUMBER == 318:
        #  <PROCEDURE NAME>  ::=  <LABEL EXTERNAL>  PROCEDURE
        TEMP2=PROC_MODE;
        TEMP=XPDEF;
        SET_LABEL_TYPE(FIXL(MP),PROC_LABEL);
        PROC_FUNC_HEAD:
        PARMS_PRESENT=0;
        if INLINE_LEVEL>0: 
            ERROR(d.CLASS_PP,9);
        if EXTERNAL_MODE>0: 
            if NEST==0: EXTERNAL_MODE=TEMP2;
        elif NEST==0:
            PARMS_WATCH=TRUE;
            GO TO DUPLICATE_BLOCK;
        #  ALL BLOCKS AND TEMPLATES COME HERE
        NEW_SCOPE:
        SET_BLOCK_SRN(FIXL(MP));
        if not PAGE_THROWN:
            if (SYT_FLAGS(FIXL(MP)) & EXTERNAL_FLAG) == 0:
                LINE_MAX = 0;
        if TEMP2!=UPDATE_MODE:
            HALMAT_BACKUP(LAST_POPp);
        if not HALMAT_CRAP: 
            HALMAT_OK=EXTERNAL_MODE=0;
        HALMAT_POP(TEMP,1,0,0);
        HALMAT_PIP(FIXL(MP),XSYT,0,0);
        INLINE_ENTRY:
        g.XSET(0x16);
        NEST=NEST+1;
        DO_INX(DO_LEVEL)=DO_INX(DO_LEVEL)|0x80;
        BLOCK_MODE(NEST)=TEMP2;
        BLOCK_SYTREF(NEST)=FIXL(MP);
        SYT_ARRAY(BLOCK_SYTREF(NEST))=-ON_ERROR_PTR;
        if NEST > MAXNEST:
            MAXNEST = NEST;
            if NEST >= NEST_LIM:
                ERROR(d.CLASS_BN,1);
        SCOPEp_STACK(NEST) = SCOPEp;
        SCOPEp = MAX_SCOPEp + 1;
        MAX_SCOPEp = SCOPEp
        if (SYT_FLAGS(FIXL(MP))&EXTERNAL_FLAG) != 0: 
            NEXT_ELEMENT(CSECT_LENGTHS);
            CSECT_LENGTHS(SCOPEp).PRIMARY = 0x7FFF;# SET LENGTH TO MAX
            CSECT_LENGTHS(SCOPEp).REMOTE = 0x7FFF; # TO TURN OFF PHASE2
            # %COPY CHECKING
        SYT_SCOPE(FIXL(MP)) = SCOPEp; # UPDATE BLOCK NAME TO SAME SCOPE
        # AS CONTENTS
        PROCMARK_STACK(NEST) = PROCMARK;
        REGULAR_PROCMARK, PROCMARK = NDECSY + 1;
        SYT_PTR(FIXL(MP)) = PROCMARK;
        if BLOCK_MODE(NEST) == CMPL_MODE:
            PROCMARK = 1;  # ALL COMPOOLS IN SAME SCOPE
        S = CURRENT_SCOPE;
        SAVE_SCOPE, CURRENT_SCOPE = VAR(MP);
        VAR(MP) = S;
        NEST = NEST - 1;
        COMPRESS_OUTER_REF();
        NEST = NEST + 1;
        OUTER_REF_PTR(NEST)=OUTER_REF_INDEX+1;
        ENTER_LAYOUT(FIXL(MP));
        if BLOCK_MODE(NEST)==INLINE_MODE: 
            if STACK_PTR(MP)>0: 
                OUTPUT_WRITER(0,STACK_PTR(MP)-1);
            EXT_P(PTR(MP))=INDENT_LEVEL;
            INX(PTR(MP))=STMT_NUM;
            EMIT_SMRK()(5);
            INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
            OUTPUT_WRITER(STACK_PTR(MP),STACK_PTR(SP));
            INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
            NEST_LEVEL = NEST_LEVEL + 1;
            EMIT_SMRK();
        else:
            INDENT_STACK(NEST) = INDENT_LEVEL;
            NEST_STACK(NEST) = NEST_LEVEL;
            INDENT_LEVEL, NEST_LEVEL = 0;
    elif PRODUCTION_NUMBER == 319:
        #  <FUNC STMT BODY>  ::=  <PARAMETER LIST>
        pass;
    elif PRODUCTION_NUMBER == 320:
        #  <FUNC STMT BODY>  ::=  <TYPE SPEC>
        pass;
    elif PRODUCTION_NUMBER == 321:
        #  <FUNC STMT BODY>  ::=  <PARAMETER LIST>  <TYPE SPEC>
        pass;
    elif PRODUCTION_NUMBER == 322:
        #  <PROC STMT BODY>  ::=  <PARAMETER LIST>
        pass;
    elif PRODUCTION_NUMBER == 323:
        #  <PROC STMT BODY>  ::=  <ASSIGN LIST>
        pass;
    elif PRODUCTION_NUMBER == 324:
        #  <PROC STMT BODY>  ::=  <PARAMETER LIST>  < ASSIGN LIST>
        pass;
    elif PRODUCTION_NUMBER == 325:
        #  <PARAMETER LIST>  ::=  <PARAMETER HEAD>  <IDENTIFIER>  )
        PARMS_PRESENT=PARMS_PRESENT+1;
    elif PRODUCTION_NUMBER == 326:
        #  <PARAMETER HEAD>  ::=  (
        pass;
    elif PRODUCTION_NUMBER == 327:
        #  <PARAMETER HEAD>  ::=  <PARAMETER HEAD>  <IDENTIFIER>  ,
        PARMS_PRESENT=PARMS_PRESENT+1;
    elif PRODUCTION_NUMBER == 328:
        #  <ASSIGN LIST>  ::=  <ASSIGN>  <PARAMETER LIST>
        pase;
    elif PRODUCTION_NUMBER == 329:
        #  <ASSIGN>  ::=  ASSIGN
        if CONTEXT==PARM_CONTEXT: CONTEXT=ASSIGN_CONTEXT;
        ELSE ASSIGN_ARG_LIST=TRUE;
    elif PRODUCTION_NUMBER == 330:
        #  <DECLARE ELEMENT>  ::=  <DECLARE STATEMENT>
        STMT_TYPE = DECL_STMT_TYPE;
        if SIMULATING: 
            STAB_HDR();
        EMIT_SMRK()(1);
    elif PRODUCTION_NUMBER == 331:
        #  <DECLARE ELEMENT>  ::=  <REPLACE STMT>  ;
        STMT_TYPE = REPLACE_STMT_TYPE;
        if SIMULATING: 
            STAB_HDR();
        EMIT_NULL:
        OUTPUT_WRITER();
        EMIT_SMRK()(1);
    elif PRODUCTION_NUMBER == 332:
        #  <DECLARE ELEMENT>  ::=  <STRUCTURE STMT>
        SYT_ADDR(REF_ID_LOC)=STRUC_SIZE;
        REF_ID_LOC=0;
        STMT_TYPE = STRUC_STMT_TYPE;
        if SIMULATING: 
            STAB_HDR();
        GO TO EMIT_NULL;
    elif PRODUCTION_NUMBER == 333:
        #  <DECLARE ELEMENT>  ::=  EQUATE  EXTERNAL  <IDENTIFIER>  TO <VARIABLE>  ;
        I = FIXL(MP + 2);  # EQUATE NAME
        J = SP - 1;
        if SYT_CLASS(FIXL(J)) == TEMPLATE_CLASS:
            J = FIXV(J);  # ROOT PTR SAVED IN FIXV FOR STRUCS
        else:
            J = FIXL(J);  # SYT PTR IN FIXL FOR OTHERS
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
        if (VAL_P(TEMP) & 0x40) != 0:
            ERROR(d.CLASS_DU, 10, VAR(SP - 1));  # PREC MODIFIER
        if (VAL_P(TEMP) & 0x80) != 0:
            ERROR(d.CLASS_DU, 11, VAR(MP + 2));  # SUBBIT
        if KILL_NAME(SP - 1):
            ERROR(d.CLASS_DU, 14, VAR(MP + 2));  # NAME(.)
        else:
            RESET_ARRAYNESS();
        if (VAL_P(TEMP) & 0x20) != 0:
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
        if SIMULATING: 
            STAB_HDR();
        GO TO EMIT_NULL;
    elif PRODUCTION_NUMBER == 334:
        #  <REPLACE STMT>  ::=  REPLACE  <REPLACE HEAD>  BY  <TEXT>
        CONTEXT = 0;
        MAC_NUM = FIXL(MPP1);
        SYT_ADDR(MAC_NUM) = START_POINT;
        VAR_LENGTH(MAC_NUM) = MACRO_ARG_COUNT;
        EXTENT(MAC_NUM) = REPLACE_TEXT_PTR;
        MACRO_ARG_COUNT = 0;
    elif PRODUCTION_NUMBER == 335:
        #  <REPLACE HEAD>  ::=  <IDENTIFIER>
        INIT_MACRO:
        CONTEXT = 0;
        MACRO_TEXT(FIRST_FREE) = 0xEF;  # INITIALIZE TO NULL
    elif PRODUCTION_NUMBER == 336:
        #  <REPLACE HEAD>  ::=  <IDENTIFIER>  (  <ARG LIST>  )
        NOSPACE();
        GO TO INIT_MACRO;
    elif PRODUCTION_NUMBER == 337:
        #  <ARG LIST>  ::=  <IDENTIFIER>
        NEXT_ARG:
        MACRO_ARG_COUNT = MACRO_ARG_COUNT + 1 ;
        if MACRO_ARG_COUNT > MAX_PARAMETER:
            ERROR(d.CLASS_IR,10);
    elif PRODUCTION_NUMBER == 338:
        #  <ARG LIST>  ::=  <ARG LIST>  ,  <IDENTIFIER>
        GO TO NEXT_ARG;
    elif PRODUCTION_NUMBER == 339:
        #  <TEMPORARY STMT>  ::=  TEMPORARY  <DECLARE BODY>  ;
        if SIMULATING: 
            STMT_TYPE = TEMP_TYPE;
        STAB_HDR();
        GO TO DECL_STAT;
    elif PRODUCTION_NUMBER == 340:
        #  <DECLARE STATEMENT>  ::=  DECLARE  <DECLARE BODY>  ;
        if PARMS_PRESENT<=0: 
            PARMS_WATCH=FALSE;
            if EXTERNALIZE: 
                EXTERNALIZE=4;
        DECL_STAT:
        FACTORING=TRUE;
        if IC_FOUND>0: 
            IC_LINE=INX(IC_PTR1);
            PTR_TOP=IC_PTR1-1;
        IC_FOUND=0;
        if ATTR_LOC>1: 
            OUTPUT_WRITER(LAST_WRITE,ATTR_LOC-1);
            if not ATTR_FOUND: 
                if (GRAMMAR_FLAGS(1)&ATTR_BEGIN_FLAG)!=0:
                    INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT+INDENT_INCR;
            elif INDENT_LEVEL==SAVE_INDENT_LEVEL:
                INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT;
            OUTPUT_WRITER(ATTR_LOC,STMT_PTR);
        else:
            OUTPUT_WRITER(LAST_WRITE,STMT_PTR);
        INDENT_LEVEL=SAVE_INDENT_LEVEL;
        LAST_WRITE,SAVE_INDENT_LEVEL=0;
    elif PRODUCTION_NUMBER == 341:
        #  <DECLARE BODY>  ::=  <DECLARATION LIST>
        ;
    elif PRODUCTION_NUMBER == 342:
        #  <DECLARE BODY>  ::=  <ATTRIBUTES> , <DECLARATION LIST>
        for I in range(0, 1 + FACTOR_LIM):
            FACTORED_TYPE(I) = 0;
        FACTOR_FOUND = FALSE;
    elif PRODUCTION_NUMBER == 343:
        #  <DECLARATION LIST>  ::=  <DECLARATION>
        SAVE_INDENT_LEVEL = INDENT_LEVEL;
        ATTR_FOUND = FALSE;
        LAST_WRITE = 0;
    elif PRODUCTION_NUMBER == 344:
        #  <DECLARATION LIST>  ::=  <DCL LIST ,>   <DECLARATION>
        pass;
    elif PRODUCTION_NUMBER == 345:
        #  <DCL LIST ,>  ::=  <DECLARATION LIST>  ,
        if ATTR_FOUND:
            if ATTR_LOC >= 0:
                if ATTR_LOC != 0:
                    OUTPUT_WRITER(LAST_WRITE, ATTR_LOC - 1);
                    if INDENT_LEVEL == SAVE_INDENT_LEVEL:
                        INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT;
                OUTPUT_WRITER(ATTR_LOC, STMT_PTR);
                LAST_WRITE = 0;
        else:
            ATTR_FOUND = TRUE;
            if (GRAMMAR_FLAGS(1) & ATTR_BEGIN_FLAG) != 0:
                # <ARRAY, TYPE, & ATTR> FACTORED
                OUTPUT_WRITER(0, STACK_PTR(MP) - 1);
                LAST_WRITE = STACK_PTR(MP);
                INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT+INDENT_INCR;
                if ATTR_LOC >= 0:
                    OUTPUT_WRITER(STACK_PTR(MP), STMT_PTR);
                    LAST_WRITE = 0;
            else:
                if ATTR_LOC >= 0:
                    OUTPUT_WRITER();
                    LAST_WRITE = 0;
                    INDENT_LEVEL=INDENT_LEVEL+ATTR_INDENT;
        if INIT_EMISSION: 
            INIT_EMISSION=FALSE;
            EMIT_SMRK()(0);
    elif PRODUCTION_NUMBER == 346:
        #  <DECLARE GROUP>  ::=  <DECLARE ELEMENT>
        pass;
    elif PRODUCTION_NUMBER == 347:
        #  <DECLARE GROUP>  ::=  <DECLARE GROUP>  <DECLARE ELEMENT>
        pass;
    elif PRODUCTION_NUMBER == 348:
        #  <STRUCTURE STMT>  ::=  STRUCTURE <STRUCT STMT HEAD> <STRUCT STMT TAIL>
        FIXV(SP)=0;
        FIXL(MP)=FIXL(MPP1);
        FIXV(MP)=FIXV(MPP1);
        FIXL(MPP1)=FIXL(SP);
        FACTORING = TRUE;
        GO TO STRUCT_GOING_UP;
    elif PRODUCTION_NUMBER == 349:
        #  <STRUCT STMT HEAD>  ::=  <IDENTIFIER>  :  <LEVEL>
        NO_ATTR_STRUCT:
        BUILDING_TEMPLATE = TRUE;
        ID_LOC,FIXL(MPP1)=FIXL(MP);
        STRUC_SIZE=0;
        REF_ID_LOC=ID_LOC;
        if FIXV(SP)>1: 
            ERROR(d.CLASS_DQ,1);
        FIXV(MP)=1;
        SYT_CLASS(ID_LOC) = TEMPLATE_CLASS;
        SYT_TYPE(ID_LOC) = TEMPL_NAME;
        if (ATTRIBUTES & ILL_TEMPL_ATTR) != 0 or \
                (ATTRIBUTES2 & NONHAL_FLAG) != 0: 
            ERROR(d.CLASS_DA,22,SYT_NAME(ID_LOC));
            ATTRIBUTES = ATTRIBUTES & not ILL_TEMPL_ATTR;
            ATTRIBUTES2 = ATTRIBUTES2 & not NONHAL_FLAG;
            DO_INIT=FALSE;
        if (ATTRIBUTES & ALDENSE_FLAGS) == 0:
            ATTRIBUTES = ATTRIBUTES | (DEFAULT_ATTR & ALDENSE_FLAGS);
        SYT_FLAGS(ID_LOC)=SYT_FLAGS(ID_LOC)|ATTRIBUTES;
        HALMAT_INIT_CONST();
        for I in range(0, 1 + FACTOR_LIM):
            TYPE(I)=0;
        SAVE_INDENT_LEVEL = INDENT_LEVEL;
        if STACK_PTR(SP) > 0:
            OUTPUT_WRITER(0, STACK_PTR(SP) - 1);
        LAST_WRITE = STACK_PTR(SP);
        INDENT_LEVEL = SAVE_INDENT_LEVEL + INDENT_INCR;  # IN BY ONE LEVEL
        GO TO STRUCT_GOING_DOWN;
    elif PRODUCTION_NUMBER == 350:
        #  <STRUCT STMT HEAD>  ::=  <IDENTIFIER> <MINOR ATTR LIST> : <LEVEL>
        GO TO NO_ATTR_STRUCT;
    elif PRODUCTION_NUMBER == 351:
        #  <STRUCT STMT HEAD> ::= <STRUCT STMT HEAD> <DECLARATION> , <LEVEL>
        STRUCT_GOING_UP:
        if (SYT_FLAGS(ID_LOC)&DUPL_FLAG)!=0:
            SYT_FLAGS(ID_LOC)=SYT_FLAGS(ID_LOC)&(not DUPL_FLAG);
            S=SYT_NAME(ID_LOC);
            TEMP_SYN=SYT_LINK1(FIXL(MP));
            while TEMP_SYN!=ID_LOC:
                if S==SYT_NAME(TEMP_SYN):
                    ERROR(d.CLASS_DQ,9,S);
                    S='';
                TEMP_SYN=SYT_LINK2(TEMP_SYN);
        if FIXV(SP)>FIXV(MP): 
            if FIXV(SP)>FIXV(MP)+1: 
                ERROR(d.CLASS_DQ,2);
            FIXV(MP)=FIXV(MP)+1;
            if (TYPE|CLASS)!=0:
                ERROR(d.CLASS_DT, 5, SYT_NAME(ID_LOC));  # TYPE NOT LEGAL
            if (ATTRIBUTES&ILL_MINOR_STRUC)!=0 or NAME_IMPLIED or \
                    (ATTRIBUTES2 & NONHAL_FLAG)!=0: 
                ERROR(d.CLASS_DA, 20, SYT_NAME(ID_LOC));
                ATTRIBUTES = ATTRIBUTES & (not ILL_MINOR_STRUC);
                ATTRIBUTES2 = ATTRIBUTES2 & (not NONHAL_FLAG);
                NAME_IMPLIED=FALSE;
                DO_INIT = 0;
            if N_DIM != 0: 
                ERROR(d.CLASS_DA, 21, SYT_NAME(ID_LOC));
                N_DIM = 0;
                ATTRIBUTES = ATTRIBUTES & (not ARRAY_FLAG);
            SYT_CLASS(ID_LOC) = TEMPLATE_CLASS;
            TYPE = MAJ_STRUC;
            if (ATTRIBUTES & ALDENSE_FLAGS) == 0:
                ATTRIBUTES = ATTRIBUTES | (SYT_FLAGS(FIXL(MP)) & ALDENSE_FLAGS);
            # GIVE ALIGNED/DENSE OF PARENT IF NOT LOCALLY SPECIFIED
            if (ATTRIBUTES&RIGID_FLAG)==0:
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
        else:
            TEMP_SYN=FIXL(MPP1);
            FIXL(SP)=FIXL(MP);
            while FIXV(SP)<FIXV(MP):
                SYT_LINK2(FIXL(MPP1))=-FIXL(MP);
                FIXL(MPP1)=FIXL(MP);
                FIXL(MP)=LOC_P(PTR_TOP);
                PTR_TOP=PTR_TOP-1;
                FIXV(MP)=FIXV(MP)-1;
            if TYPE==0: 
                TYPE=DEFAULT_TYPE;
            elif TYPE==MAJ_STRUC: 
                if not NAME_IMPLIED:
                    if STRUC_PTR==REF_ID_LOC: DO;
                        ERROR(d.CLASS_DT,6);
                        SYT_FLAGS(REF_ID_LOC)=SYT_FLAGS(REF_ID_LOC)|EVIL_FLAG;
            if CLASS!=0: 
                if NAME_IMPLIED:
                    ATTRIBUTES=ATTRIBUTES|DEFINED_LABEL;
                    if TYPE==PROC_LABEL: 
                        ERROR(d.CLASS_DA,14,SYT_NAME(ID_LOC));
                        elif CLASS==2: 
                            ERROR(d.CLASS_DA,13,SYT_NAME(ID_LOC));
                else:
                    ERROR(d.CLASS_DT,7,SYT_NAME(ID_LOC));
                    CLASS=0;
                    if TYPE>ANY_TYPE: 
                        TYPE=DEFAULT_TYPE;
            CHECK_CONSISTENCY();
            if (ATTRIBUTES&ILL_TERM_ATTR(NAME_IMPLIED))!=0 or \
                    (ATTRIBUTES2&NONHAL_FLAG)!=0:
                ERROR(d.CLASS_DA, 23, SYT_NAME(ID_LOC));
                #  ILL_NAME_ATTR MUST BE SUBSET OF ILL_TERM_ATTR
                ATTRIBUTES=(~ILL_TERM_ATTR(NAME_IMPLIED))&ATTRIBUTES;
                ATTRIBUTES2=(~NONHAL_FLAG)&ATTRIBUTES2;
                DO_INIT=FALSE;
            SYT_CLASS(ID_LOC)=TEMPLATE_CLASS+CLASS;
            if TYPE==MAJ_STRUC: 
                CHECK_STRUC_CONFLICTS();
            elif TYPE==EVENT_TYPE: 
                CHECK_EVENT_CONFLICTS();
            if (ATTRIBUTES&SD_FLAGS)==0:
                if (TYPE>=MAT_TYPE)&(TYPE<=INT_TYPE):
                    ATTRIBUTES=ATTRIBUTES|(DEFAULT_ATTR&SD_FLAGS);
            if (ATTRIBUTES & ALDENSE_FLAGS) == 0:
                if (not NAME_IMPLIED) and ((ATTRIBUTES&ARRAY_FLAG)==0) and \
                        (TYPE==BIT_TYPE):
                    ATTRIBUTES=ATTRIBUTES|(SYT_FLAGS(FIXL(SP))&ALDENSE_FLAGS);
                else:
                    ATTRIBUTES=ATTRIBUTES|ALIGNED_FLAG;
            if (ATTRIBUTES&RIGID_FLAG)==0:
                ATTRIBUTES=ATTRIBUTES|(SYT_FLAGS(FIXL(SP))&RIGID_FLAG);
            if NAME_IMPLIED: 
                SYT_FLAGS(REF_ID_LOC)=SYT_FLAGS(REF_ID_LOC) | MISC_NAME_FLAG;
            SET_SYT_ENTRIES();
            STRUC_SIZE=ICQ_TERMp(ID_LOC)*ICQ_ARRAYp(ID_LOC)+STRUC_SIZE;
            NAME_IMPLIED=FALSE;
            if FIXV(SP)>0: 
                SYT_LINK2(FIXL(MPP1))=TEMP_SYN+1;
                if STACK_PTR(SP) > 0:
                    OUTPUT_WRITER(LAST_WRITE, STACK_PTR(SP) - 1);
                LAST_WRITE = STACK_PTR(SP);
                INDENT_LEVEL = SAVE_INDENT_LEVEL + (FIXV(MP) * INDENT_INCR);
            else:
                BUILDING_TEMPLATE=FALSE;
                OUTPUT_WRITER(LAST_WRITE, STMT_PTR);
                INDENT_LEVEL = SAVE_INDENT_LEVEL;
                LAST_WRITE, SAVE_INDENT_LEVEL = 0;
    elif PRODUCTION_NUMBER == 352:
        #  <STRUCT STMT TAIL>  ::=  <DECLARATION>  ;
        ;
    elif PRODUCTION_NUMBER == 353:
        # <STRUCT SPEC> ::= <STRUCT TEMPLATE> <STRUCT SPEC BODY>
        STRUC_PTR = FIXL(MP);
        if SYT_TYPE(STRUC_PTR) != TEMPL_NAME:
            SYT_FLAGS(STRUC_PTR) = SYT_FLAGS(STRUC_PTR) | EVIL_FLAG;
        SET_XREF(STRUC_PTR,XREF_REF);
        NOSPACE();
    elif PRODUCTION_NUMBER == 354:
        # <STRUCT SPEC BODY> ::= - STRUCTURE
        NOSPACE();
    elif PRODUCTION_NUMBER == 355:
        # <STRUCT SPEC BODY> ::= <STRUCT SPEC HEAD> <LITERAL EXP OR*> )
        CONTEXT = DECLARE_CONTEXT;
        I = FIXV(MPP1);
        if not ((I > 1) and (I <= ARRAY_DIM_LIM) or (I == -1)):
            ERROR(d.CLASS_DD, 11);
            STRUC_DIM = 2;  # A DEFAULT
        else:
            STRUC_DIM = I;
    elif PRODUCTION_NUMBER == 356:
        # <STRUCT SPEC HEAD> ::= - STRUCTURE (
        NOSPACE();
        TOKEN_FLAGS(STACK_PTR(MPP1))=TOKEN_FLAGS(STACK_PTR(MPP1))|0x20;
    elif PRODUCTION_NUMBER == 357:
        #  <DECLARATION>  ::=  <NAME ID>
        if not BUILDING_TEMPLATE:
            if NAME_IMPLIED: 
                ATTR_LOC=STACK_PTR(MP);
            else:
                ATTR_LOC=-1;
            GO TO SPEC_VAR;
    elif PRODUCTION_NUMBER == 358:
        #  <DECLARATION>  ::=  <NAME ID>  <ATTRIBUTES>
        if not BUILDING_TEMPLATE:
            if (TOKEN_FLAGS(0)&7)== 7: 
                ATTR_LOC=0;
            elif (TOKEN_FLAGS(1)&7)== 7: 
                ATTR_LOC=1;
            else:
                ATTR_LOC=MAX(0,STACK_PTR(MP));
        SPEC_VAR:
        DO_INIT=TRUE;
        CHECK_CONFLICTS();
        I=SYT_FLAGS(ID_LOC);
        if (I&PARM_FLAGS)!=0:
            PARMS_PRESENT=PARMS_PRESENT-1;
            if PARMS_PRESENT==0 and PARMS_WATCH: 
                COMSUB_END = NDECSY;
            if (ATTRIBUTES&ILL_INIT_ATTR)!=0: 
                ERROR(d.CLASS_DI,12,VAR(MP));
                DO_INIT=FALSE;
                ATTRIBUTES=ATTRIBUTES&(not ILL_INIT_ATTR);
            if CLASS>0&(not NAME_IMPLIED): 
                ERROR(d.CLASS_D,1,VAR(MP));
                NONHAL,CLASS=0;
                if TYPE>ANY_TYPE: 
                    TYPE=DEFAULT_TYPE;
            #  REMOTE NOW OK FOR ASSIGN PARMS & IGNORED FOR INPUT PARMS
            #  SO REMOVE D14 ERROR MESSAGE.
        elif PARMS_WATCH: 
            ERROR(d.CLASS_D,15);
        if TYPE==EVENT_TYPE: 
            CHECK_EVENT_CONFLICTS();
        if not NAME_IMPLIED:
            if NONHAL>0:
                if TYPE==PROC_LABEL|CLASS=2:
                    ATTRIBUTES=ATTRIBUTES|EXTERNAL_FLAG|DEFINED_LABEL;
                    SYT_ARRAY(ID_LOC)=NONHAL|0xFF00;
                    GO TO MODE_CHECK;
                else:
                   ERROR(d.CLASS_D,11,VAR(MP));
                   #   DISCONNECT SYT_FLAGS WITH NONHAL
                   #   THIS ALSO DISCONNECTS ATTRIBUTES WITH NONHAL
                   SYT_FLAGS2(ID_LOC) = SYT_FLAGS2(ID_LOC) & (~NONHAL_FLAG);
            elif CLASS==2:
                MODE_CHECK:
                if BLOCK_MODE(NEST)==CMPL_MODE: 
                    ERROR(d.CLASS_D,2,VAR(MP));
            elif CLASS==1:
                if TYPE==TASK_LABEL:
                    if NEST>1|BLOCK_MODE(1)!=PROG_MODE:
                        ERROR(d.CLASS_PT,1);
                else:
                    ERROR(d.CLASS_DN,1,VAR(MP));
                    CLASS=0;
                    TYPE=DEFAULT_TYPE;
            if CLASS!=0:
                if (ATTRIBUTES&ILL_INIT_ATTR)!=0:
                    ERROR(d.CLASS_DI,13,VAR(MP));
                    ATTRIBUTES=ATTRIBUTES&(~ILL_INIT_ATTR);
                    DO_INIT=FALSE;
                if TEMPORARY_IMPLIED: 
                    ERROR(d.CLASS_D,8,VAR(MP));
                    CLASS=0;
                    if TYPE>ANY_TYPE: 
                        TYPE=DEFAULT_TYPE;
            elif TEMPORARY_IMPLIED: 
                if (ATTRIBUTES&ILL_TEMPORARY_ATTR)!=0 or \
                        (ATTRIBUTES2&NONHAL_FLAG)!=0:
                    ERROR(d.CLASS_D,8,VAR(MP));
                    ATTRIBUTES=ATTRIBUTES&(not ILL_TEMPORARY_ATTR);
                    ATTRIBUTES2=ATTRIBUTES2&(not NONHAL_FLAG);
                    DO_INIT=FALSE;
            else:
                FIX_AUTSTAT:
                if (ATTRIBUTES&ALDENSE_FLAGS)==0:
                    ATTRIBUTES=ATTRIBUTES|(DEFAULT_ATTR&ALDENSE_FLAGS);
                if BLOCK_MODE(NEST)!=CMPL_MODE:
                    if (I&PARM_FLAGS)==0:
                        if (ATTRIBUTES&AUTSTAT_FLAGS)==0:
                                ATTRIBUTES=ATTRIBUTES|(DEFAULT_ATTR&AUTSTAT_FLAGS);
        else: 
            # ADD ILLEGAL TEMP ATTRIBUTE CHECKING FROM ABOVE FOR NAME TEMPS TOO
            if TEMPORARY_IMPLIED: 
                if CLASS!=0:
                    ERROR(d.CLASS_D,8,VAR(MP));
                    CLASS=0;
                    if TYPE>ANY_TYPE: 
                        TYPE=DEFAULT_TYPE;
                # ONLY DIFFERENCE FOR NAME TEMPS IS THAT REMOTE IS LEGAL
                elif (((ATTRIBUTES&ILL_TEMPORARY_ATTR)!=0) and \
                        ((ATTRIBUTES&ILL_TEMPORARY_ATTR)!=REMOTE_FLAG)) or
                        (ATTRIBUTES2&NONHAL_FLAG)!=0:
                    ERROR(d.CLASS_D,8,VAR(MP));
                    ATTRIBUTES=ATTRIBUTES&(not ILL_TEMPORARY_ATTR);
                    ATTRIBUTES2=ATTRIBUTES2&(not NONHAL_FLAG);
                    DO_INIT=FALSE;
            if (ATTRIBUTES&ILL_NAME_ATTR)!=0 or \
                    (ATTRIBUTES2&NONHAL_FLAG)!=0:
                ERROR(d.CLASS_D,12,VAR(MP));
                ATTRIBUTES=ATTRIBUTES&(not ILL_NAME_ATTR);
                ATTRIBUTES2=ATTRIBUTES2&(not NONHAL_FLAG);
            if TYPE==PROC_LABEL: 
                ERROR(d.CLASS_DA,14,VAR(MP));
            elif CLASS==2: 
                ERROR(d.CLASS_DA,13,VAR(MP));
            if CLASS>0: 
                ATTRIBUTES=ATTRIBUTES|DEFINED_LABEL;
            GO TO FIX_AUTSTAT;
        SYT_CLASS(ID_LOC)=VAR_CLASS(CLASS);
        if TYPE==MAJ_STRUC: 
            CHECK_STRUC_CONFLICTS();
        if (ATTRIBUTES&SD_FLAGS)==0: 
            if TYPE>=MAT_TYPE&TYPE<=INT_TYPE:
                ATTRIBUTES=ATTRIBUTES|(DEFAULT_ATTR&SD_FLAGS);
        SET_SYT_ENTRIES();
        NAME_IMPLIED=FALSE;
        if TEMPORARY_IMPLIED:
            ATTR_INDENT=10;
            if DO_CHAIN(DO_LEVEL)==0:
                DO_CHAIN(DO_LEVEL)=ID_LOC;
                HALMAT_POP(XTDCL,1,0,0);
                HALMAT_PIP(ID_LOC,XSYT,0,0);
            else: 
                SYT_LINK1(DO_CHAIN)=ID_LOC;
            DO_CHAIN=ID_LOC;
        else:
            ATTR_INDENT=8;
        #SET REMOTE ATTRIBUTE FOR ALL NON-NAME #D DATA WHEN THE
        #DATA_REMOTE DIRECTIVE IS IN EFFECT
        #(MUST NOT BE AUTOMATIC OR A PARAMETER TO BE #D DATA.)
        if DATA_REMOTE: 
            if ((SYT_FLAGS(ID_LOC) & NAME_FLAG) == 0) and \
                    ((SYT_FLAGS(ID_LOC) & TEMPORARY_FLAG) == 0) and \
                    # DON'T SET REMOTE FLAG FOR TASKS, FUNCTIONS,
                    # OR PROCEDURES
                    (SYT_TYPE(ID_LOC) != TASK_LABEL) and \
                    (SYT_TYPE(ID_LOC) != PROC_LABEL) and \
                    (SYT_CLASS(ID_LOC) != FUNC_CLASS) and \
                    # PART 1. SET THE REMOTE FLAG IF DATA
                    # IS DECLARED IN A NON "EXTERNAL" BLOCK.
                    ((SYT_FLAGS(BLOCK_SYTREF(NEST)) & EXTERNAL_FLAG)==0) and \
                    not (((SYT_FLAGS(ID_LOC) & AUTO_FLAG) != 0) and \
                    ((SYT_FLAGS(BLOCK_SYTREF(NEST)) & REENTRANT_FLAG) != 0)) and \
                    ((SYT_FLAGS(ID_LOC) & PARM_FLAGS) == 0): DO;
                if (SYT_FLAGS(ID_LOC) & REMOTE_FLAG) != 0:
                    ERROR(d.CLASS_XR,3);
                if SYT_TYPE(ID_LOC) == EVENT_TYPE:
                    ERROR(d.CLASS_DA,9);
                SYT_FLAGS(ID_LOC) = SYT_FLAGS(ID_LOC) | REMOTE_FLAG;
            elif SDL_OPTION and \
                    ((SYT_FLAGS(ID_LOC) & NAME_FLAG)==0) and \
                    ((SYT_FLAGS(ID_LOC) & PARM_FLAGS)==0) and \
                    ((SYT_FLAGS(ID_LOC) & REMOTE_FLAG)!=0):
                ERROR(d.CLASS_XR, 5);
        if ((SYT_FLAGS(ID_LOC) & NAME_FLAG)==0) and \
                ((SYT_FLAGS(ID_LOC) & INPUT_PARM)!=0) and \
                ((SYT_FLAGS(ID_LOC) & REMOTE_FLAG)!=0):
            SYT_FLAGS(ID_LOC)=SYT_FLAGS(ID_LOC) & not REMOTE_FLAG;
            ERROR(d.CLASS_YD, 100);
    elif PRODUCTION_NUMBER == 359:
        #  <NAME ID>   ::=  <IDENTIFIER>
        ID_LOC=FIXL(MP);
    elif PRODUCTION_NUMBER == 360:
        #  <NAME ID>  ::=  <IDENTIFIER> NAME
        # REMOVED DN2 ERROR
        NAME_IMPLIED=TRUE;
        ID_LOC=FIXL(MP);
    elif PRODUCTION_NUMBER == 361:
        # <ATTRIBUTES> ::= <ARRAY SPEC> <TYPE & MINOR ATTR>
        GO TO CHECK_ARRAY_SPEC;
    elif PRODUCTION_NUMBER == 363:
        #  <ATTRIBUTES> ::= <ARRAY SPEC>
        CHECK_ARRAY_SPEC:
        if N_DIM > 1:
            if STARRED_DIMS > 0:
                ERROR(d.CLASS_DD, 6);
                for I in range(0, 1 + N_DIM - 1):
                    if S_ARRAY(I) == -1:
                        S_ARRAY(I) = 2;  # DEFAULT
        GO TO MAKE_ATTRIBUTES;
    elif PRODUCTION_NUMBER == 364:
        #  <ATTRIBUTES> ::= <TYPE & MINOR ATTR>
        MAKE_ATTRIBUTES:
        GRAMMAR_FLAGS(STACK_PTR(MP)) =
            GRAMMAR_FLAGS(STACK_PTR(MP)) | ATTR_BEGIN_FLAG;
        CHECK_CONSISTENCY();
        if FACTORING:
            for I in range(0, 1 + FACTOR_LIM):
                FACTORED_TYPE(I) = TYPE(I);
                TYPE(I) = 0;
            FACTOR_FOUND = TRUE;
            if FACTORED_IC_FND:
                IC_FOUND = 1;  # FOR HALMAT_INIT_CONST
                IC_PTR1 = FACTORED_IC_PTR;
    elif PRODUCTION_NUMBER == 365:
        #  <ARRAY SPEC> ::= <ARRAY HEAD> <LITERAL EXP OR *> )
        CONTEXT = DECLARE_CONTEXT;
        GO TO ARRAY_SPEC;
    elif PRODUCTION_NUMBER == 366:
        #  <ARRAY SPEC>  ::=  FUNCTION
        CLASS=2;
    elif PRODUCTION_NUMBER == 367:
        #  <ARRAY SPEC>  ::=  PROCEDURE
        TYPE=PROC_LABEL;
        CLASS=1;
    elif PRODUCTION_NUMBER == 368:
        #  <ARRAY SPEC>  ::= PROGRAM
        TYPE=PROG_LABEL;
        CLASS=1;
    elif PRODUCTION_NUMBER == 369:
        #  <ARRAY SPEC>  ::=  TASK
        TYPE=TASK_LABEL;
        CLASS=1;
    elif PRODUCTION_NUMBER == 370:
        #  <ARRAY HEAD> ::= ARRAY (
        STARRED_DIMS = 0
        N_DIM = 0;
        for I in range(0, 1 + N_DIM_LIM):
            S_ARRAY(I) = 0;
        FIXL(SP),FIXV(SP)=ARRAY_FLAG;
        GO TO INCORPORATE_ATTR;
    elif PRODUCTION_NUMBER == 371:
        #  <ARRAY HEAD> ::= <ARRAY HEAD> <LITERAL_EXP OR *> ,
        ARRAY_SPEC:
        if N_DIM >= N_DIM_LIM:
            ERROR(d.CLASS_DD, 3);
        else:
            K = 2;  # A DEFAULT
            I = FIXV(MPP1);
            if not (I > 1 & I <= ARRAY_DIM_LIM | I = -1):
                ERROR(d.CLASS_DD, 1);
            else:
                K = I;
            if K == -1: 
                STARRED_DIMS = STARRED_DIMS + 1;
            S_ARRAY(N_DIM) = K;
            N_DIM = N_DIM + 1;
    elif PRODUCTION_NUMBER == 372:
        #  <TYPE & MINOR ATTR> ::= <TYPE SPEC>
        GO TO SPEC_TYPE;
    elif PRODUCTION_NUMBER == 373:
        #  <TYPE & MINOR ATTR> ::= <TYPE SPEC> <MINOR ATTR LIST>
        SPEC_TYPE:
        if CLASS:
            ERROR(d.CLASS_DC,1);
            CLASS=0;
    elif PRODUCTION_NUMBER == 374:
        #  <TYPE & MINOR ATTR> ::= <MINOR ATTR LIST>
        pass;
    elif PRODUCTION_NUMBER == 375:
        #  <TYPE SPEC> ::= <STRUCT SPEC>
        TYPE = MAJ_STRUC;
    elif PRODUCTION_NUMBER == 376:
        #  <TYPE SPEC>  ::=  <BIT SPEC>
        pass;
    elif PRODUCTION_NUMBER == 377:
        #  <TYPE SPEC>  ::=  <CHAR SPEC>
        pass;
    elif PRODUCTION_NUMBER == 378:
        #  <TYPE SPEC>  ::=  <ARITH SPEC>
        pass;
    elif PRODUCTION_NUMBER == 379:
        #  <TYPE SPEC>  ::=  EVENT
        TYPE=EVENT_TYPE;
    elif PRODUCTION_NUMBER == 380:
        #  <BIT SPEC>  ::=  BOOLEAN
        TYPE = BIT_TYPE;
        BIT_LENGTH = 1;  # BOOLEAN
    elif PRODUCTION_NUMBER == 381:
        #  <BIT SPEC>  ::=  BIT  (  <LITERAL EXP OR *>  )
        NOSPACE();
        CONTEXT = DECLARE_CONTEXT;
        J=FIXV(MP+2);
        K = DEF_BIT_LENGTH;
        if J == -1: 
            ERROR(d.CLASS_DS, 4);  # "*" ILLEGAL
        elif (J <= 0) | (J > BIT_LENGTH_LIM):
            ERROR(d.CLASS_DS, 1);
        else:
            K = J;
        TYPE = BIT_TYPE;
        BIT_LENGTH = K;
    elif PRODUCTION_NUMBER == 382:
        #  <CHAR SPEC>  ::=  CHARACTER  (  <LITERAL EXP OR *>  )
        NOSPACE();
        CONTEXT = DECLARE_CONTEXT;
        J=FIXV(MP+2);
        K = DEF_CHAR_LENGTH;
        if J==-1: 
            K=J;
        elif (J <= 0) or (J > CHAR_LENGTH_LIM):
            ERROR(d.CLASS_DS, 2);
        else:
            K = J;
        CHAR_LENGTH = K;
        TYPE = CHAR_TYPE;
    elif PRODUCTION_NUMBER == 383:
        #  <ARITH SPEC>  ::=  <PREC SPEC>
        ATTR_MASK = ATTR_MASK | FIXL(MP);
        ATTRIBUTES = ATTRIBUTES | FIXV(MP);
    elif PRODUCTION_NUMBER == 384:
        #  <ARITH SPEC>  ::=  <SQ DQ NAME>
        pass;
    elif PRODUCTION_NUMBER == 385:
        #  <ARITH SPEC>  ::=  <SQ DQ NAME>  <PREC SPEC>
        ATTR_MASK = ATTR_MASK | FIXL(SP);
        ATTRIBUTES = ATTRIBUTES | FIXV(SP);
    elif PRODUCTION_NUMBER == 386:
        #  <SQ DQ NAME> ::= <DOUBLY QUAL NAME HEAD> <LITERAL EXP OR *> )
        CONTEXT = DECLARE_CONTEXT;
        I = FIXV(MPP1);  # VALUE
        TYPE = FIXL(MP);
        if TYPE == VEC_TYPE:
            if I == -1:
                ERROR(d.CLASS_DD, 7);
                I = 3;
            elif (I <= 1) or (I > VEC_LENGTH_LIM):
                ERROR(d.CLASS_DD, 5);
                I = 3;
            VEC_LENGTH = I;
        else:  # MATRIX
           if I == -1:
               ERROR(d.CLASS_DD,9);
               I = 3;
           elif (I <= 1) or (I > MAT_DIM_LIM):
               ERROR(d.CLASS_DD, 4);
               I = 3;
           MAT_LENGTH = SHL(FIXV(MP), 8) + (I & 0xFF);
    elif PRODUCTION_NUMBER == 387:
        #  <SQ DQ NAME> ::= INTEGER
        TYPE = INT_TYPE;
    elif PRODUCTION_NUMBER == 388:
        #  <SQ DQ NAME> ::= SCALAR
        TYPE = SCALAR_TYPE;
    elif PRODUCTION_NUMBER == 389:
        #  <SQ DQ NAME> ::= VECTOR
        TYPE = VEC_TYPE;
        VEC_LENGTH = DEF_VEC_LENGTH;
    elif PRODUCTION_NUMBER == 390:
        #  <SQ DQ NAME> ::= MATRIX
        TYPE = MAT_TYPE;
        MAT_LENGTH = DEF_MAT_LENGTH;
    elif PRODUCTION_NUMBER == 391:
        #  <DOUBLY QUAL NAME HEAD> ::= VECTOR (
        NOSPACE();
        FIXL(MP) = VEC_TYPE;
    elif PRODUCTION_NUMBER == 392:
        #  <DOUBLY QUAL NAME HEAD>  ::=  MATRIX  (  <LITERAL EXP OR *>  ,
        NOSPACE();
        FIXL(MP) = MAT_TYPE;
        I=FIXV(MP+2);
        FIXV(MP) = 3;  # DEFAULT IF BAD SPEC FOLLOWS
        if I == -1: 
            ERROR(d.CLASS_DD, 9);
        elif (I <= 1) or (I > MAT_DIM_LIM):
            ERROR(d.CLASS_DD, 4);
        else:
            FIXV(MP) = I;
    elif PRODUCTION_NUMBER == 393:
        #  <LITERAL EXP OR *> ::= <ARITH EXP>
        PTR_TOP = PTR(MP) - 1;
        CHECK_ARRAYNESS();
        CHECK_IMPLICIT_T();
        if PSEUDO_FORM(PTR(SP)) != XLIT:
            ERROR(d.CLASS_VE,1);
            TEMP = 0;
        else:
            TEMP = MAKE_FIXED_LIT(LOC_P(PTR(SP)));
            if TEMP == -1:
                TEMP = 0;
        FIXV(SP) = TEMP;
    elif PRODUCTION_NUMBER == 394:
        #  <LITERAL EXP OR *> ::= *
        FIXV(SP) = -1;
    elif PRODUCTION_NUMBER == 395:
        #  <PREC_SPEC> ::= SINGLE
        FIXL(MP) = SD_FLAGS;
        FIXV(MP) = SINGLE_FLAG;
        PTR(MP)=1;
    elif PRODUCTION_NUMBER == 396:
        #  <PREC SPEC> ::= DOUBLE
        FIXL(MP) = SD_FLAGS;
        FIXV(MP) = DOUBLE_FLAG;
        PTR(MP)=2;
    elif PRODUCTION_NUMBER == 397:
        #  <MINOR ATTR LIST> ::= <MINOR ATTRIBUTE>
        GO TO INCORPORATE_ATTR;
    elif PRODUCTION_NUMBER == 398:
        #  <MINOR ATTR LIST> ::= <MINOR ATTR LIST> <MINOR ATTRIBUTE>
        INCORPORATE_ATTR:
        if (ATTR_MASK & FIXL(SP)) != 0:
            ERROR(d.CLASS_DA,25);
        else:
            ATTR_MASK = ATTR_MASK | FIXL(SP);
            ATTRIBUTES = ATTRIBUTES | FIXV(SP);
    elif PRODUCTION_NUMBER == 399:
        #  <MINOR ATTRIBUTE> ::= STATIC
        I = STATIC_FLAG;
        SET_AUTSTAT:
        if BLOCK_MODE(NEST) == CMPL_MODE:
            ERROR(d.CLASS_DC, 2);
        else:
            FIXL(MP) = AUTSTAT_FLAGS;
            FIXV(MP) = I;
    elif PRODUCTION_NUMBER == 400:
        #  <MINOR ATTRIBUTE> ::= AUTOMATIC
        I = AUTO_FLAG;
        GO TO SET_AUTSTAT;
    elif PRODUCTION_NUMBER == 401:
        #  <MINOR ATTRIBUTE> ::= DENSE
        if (TYPE==0) and (BUILDING_TEMPLATE and (TYPE==BIT_TYPE) and \
                          ((ATTRIBUTES&ARRAY_FLAG)==0) and \
                          (not NAME_IMPLIED)):
            FIXL(MP) = ALDENSE_FLAGS;
            FIXV(MP) = DENSE_FLAG;
    elif PRODUCTION_NUMBER == 402:
        #  <MINOR ATTRIBUTE> ::= ALIGNED
        FIXL(MP) = ALDENSE_FLAGS;
        FIXV(MP) = ALIGNED_FLAG;
    elif PRODUCTION_NUMBER == 403:
        #  <MINOR ATTRIBUTE> ::= ACCESS
        if BLOCK_MODE(NEST) == CMPL_MODE:
            FIXL(MP) = ACCESS_FLAG;
            FIXV(MP) = ACCESS_FLAG;
            ACCESS_FOUND = TRUE;
        else:
            ERROR(d.CLASS_DC,5);
    elif PRODUCTION_NUMBER == 404:
        #  <MINOR ATTRIBUTE>  ::=  LOCK ( <LITERAL EXP OR *> )
        CONTEXT=DECLARE_CONTEXT;
        LOCKp=FIXV(MP+2);
        if LOCKp<0: 
            LOCKp=0xFF;
        elif LOCKp<1 or LOCKp>LOCK_LIM:
            ERROR(d.CLASS_DL,3);
            LOCKp=0xFF;
        FIXL(MP),FIXV(MP)=LOCK_FLAG;
    elif PRODUCTION_NUMBER == 405:
        #  <MINOR ATTRIBUTE>  ::=  REMOTE
        FIXL(MP),FIXV(MP)=REMOTE_FLAG;
    elif PRODUCTION_NUMBER == 406:
        #  <MINOR ATTRIBUTE> ::= RIGID
        FIXL(MP),FIXV(MP)=RIGID_FLAG;
    elif PRODUCTION_NUMBER == 407:
        #  <MINOR ATTRIBUTE> ::= <INIT/CONST HEAD> <REPEATED CONSTANT> )
        PSEUDO_TYPE(PTR(MP)) = 0;   # NO "*"
        DO_QUALIFIED_ATTRIBUTE:
        BI_FUNC_FLAG=FALSE;
        CHECK_IMPLICIT_T();
        CONTEXT = DECLARE_CONTEXT;
        if (NUM_ELEMENTS >= NUM_EL_MAX) or (NUM_ELEMENTS < 1):
            ERROR(d.CLASS_DI,2);
        LOC_P(PTR(MP)) = NUM_ELEMENTS;  # SAVE NUMBER OF ELEMENTS TO SET
        VAL_P(PTR(MP)) = NUM_FL_NO;  # SAVE NUMBER OF GVR'S USED
        PSEUDO_LENGTH(PTR(MP)) = NUM_STACKS;  # INDICATE LENGTH OF LIST
        IC_PTR = PTR(MP);  # SAVE PTR TO THIS I/C LIST
        IC_FND = TRUE;
        if BUILDING_TEMPLATE: PTR_TOP=PTR(MP)-1;
        # KILL STACKS IF STRUCTURE TEMPLATE
    elif PRODUCTION_NUMBER == 408:
        #  <MINOR ATTRIBUTE> ::= <INIT/CONST HEAD> * )
        PSEUDO_TYPE(PTR(MP)) = 1;  # INDICATE "*" PRESENT
        GO TO DO_QUALIFIED_ATTRIBUTE;
    elif PRODUCTION_NUMBER == 409:
        #  <MINOR ATTRIBUTE> ::= LATCHED
        FIXL(MP) = LATCHED_FLAG;
        FIXV(MP) = LATCHED_FLAG;
    elif PRODUCTION_NUMBER == 410:
        #  <MINOR ATTRIBUTE>  ::=  NONHAL  (  <LEVEL>  )
        NONHAL=FIXV(MP+2);
        #   DISCONNECT SYT_FLAGS FROM NONHAL; SET
        #   NONHAL IN SYT_FLAGS2 ARRAY.
        FIXL(MP)=NONHAL_FLAG;
        SYT_FLAGS2(ID_LOC) = SYT_FLAGS2(ID_LOC) | NONHAL_FLAG;
        ATTRIBUTES2 = ATTRIBUTES2 | NONHAL_FLAG;
    elif PRODUCTION_NUMBER == 411:
        #  <INIT/CONST HEAD> ::= INITIAL (
        FIXL(MP) = INIT_CONST;
        FIXV(MP) = INIT_FLAG;
        DO_INIT_CONST_HEAD :
        BI_FUNC_FLAG=TRUE;
        PTR(MP)=PUSH_INDIRECT(1);
        NUM_ELEMENTS,NUM_FL_NO=0;
        NUM_STACKS = 1;  #  THIS IS FIRST INDIRECT LOC NEEDED
        PSEUDO_FORM(PTR(MP)) = 0;  #  INDICATE I/C LIST TOP, IE., STRI
        INX(PTR(MP)) = IC_LINE;
    elif PRODUCTION_NUMBER == 412:
        #  <INIT/CONST HEAD> ::= CONSTANT (
        FIXL(MP) = INIT_CONST;
        FIXV(MP) = CONSTANT_FLAG;
        GO TO DO_INIT_CONST_HEAD;
    elif PRODUCTION_NUMBER == 413:
        #  <INIT/CONST HEAD>  ::=  <INIT/CONST HEAD>  <REPEATED CONSTANT>  ,
        pass;
    elif PRODUCTION_NUMBER == 414:
        #  <REPEATED CONSTANT>  ::=  <EXPRESSION>
        TEMP_SYN=0;
        GO TO INIT_ELEMENT;
    elif PRODUCTION_NUMBER == 415:
        #  <REPEATED CONSTANT>  ::=  <REPEAT HEAD>  <VARIABLE>
        TEMP_SYN=1;
        GO TO INIT_ELEMENT;
    elif PRODUCTION_NUMBER == 416:
        #  <REPEATED CONSTANT>  ::=  <REPEAT HEAD>  <CONSTANT>
        TEMP_SYN=1;
        INIT_ELEMENT:
        TEMP=PTR(SP);
        if NAME_PSEUDOS:
            NAME_PSEUDOS=FALSE;
            PSEUDO_TYPE(TEMP)=PSEUDO_TYPE(TEMP)|0x80;
            if (VAL_P(TEMP)&0x40)!=0: 
                ERROR(d.CLASS_DI,14);
            if (VAL_P(TEMP)&0x200)!=0: 
                ERROR(d.CLASS_DI,16);
            # LOOK FOR THE 0x4000 VAL_P BIT AND EMIT DI16 ERROR.
            # THE VAL_P 0x4000 BIT INDICATES THE PRESENCE OF A
            # NAME VARIABLE SOMEWHERE INSIDE THE STRUCTURE REFER-
            # ENCE LIST. THE PRESENCE OF A NAME VARIABLE INSIDE
            # A NAME() INITIALIZATION IS A DI16 ERROR CONDITION.
            if (VAL_P(TEMP)&0x4000)!=0:
                ERROR(d.CLASS_DI,16);
            if EXT_P(TEMP)!=0: 
                ERROR(d.CLASS_DI,15);
            if (VAL_P(TEMP) & 0x400) == 0: 
                RESET_ARRAYNESS();
            if SYT_CLASS(FIXL(MP)) == TEMPLATE_CLASS:
                if (((SYT_FLAGS(FIXV(MP)) & ASSIGN_PARM) > 0) or \
                        (((SYT_FLAGS(FIXV(MP)) & AUTO_FLAG) != 0) and \
                         ((SYT_FLAGS(BLOCK_SYTREF(NEST)) and \
                           REENTRANT_FLAG)!=0))):
                ERROR(d.CLASS_DI,3);
            elif (((SYT_FLAGS(FIXL(MP)) & ASSIGN_PARM) > 0) or \
                    (((SYT_FLAGS(FIXL(MP)) & AUTO_FLAG) != 0) and \
                     ((SYT_FLAGS(BLOCK_SYTREF(NEST)) and \
                       REENTRANT_FLAG)!=0))):
                ERROR(d.CLASS_DI,3);
        elif PSEUDO_FORM(TEMP)!=XLIT: 
            ERROR(d.CLASS_DI,3);
        CHECK_ARRAYNESS();
        SET_INIT(LOC_P(TEMP),2,PSEUDO_FORM(TEMP),PSEUDO_TYPE(TEMP),NUM_ELEMENTS);
        NUM_ELEMENTS=NUM_ELEMENTS+1;
        NUM_STACKS=NUM_STACKS+1;
        if TEMP_SYN:
            END_REPEAT_INIT:
            SET_INIT(0,3,0,0,NUM_FL_NO);
            NUM_FL_NO=NUM_FL_NO-1;
            NUM_STACKS=NUM_STACKS+1;
            TEMP_SYN=NUM_ELEMENTS-FIXV(MP);
            IC_LEN(GET_ICQ(FIXL(MP)))=TEMP_SYN;
            NUM_ELEMENTS=INX(PTR(MP))*TEMP_SYN+FIXV(MP);
        PTR_TOP=PTR(MP)-1;
    elif PRODUCTION_NUMBER == 417:
        # <REPEATED CONSTANT>  ::=  <NESTED REPEAT HEAD>  <REPEATED CONSTANT>  )
        GO TO END_REPEAT_INIT;
    elif PRODUCTION_NUMBER == 418:
        #  <REPEATED CONSTANT>  ::=  <REPEAT HEAD>
        IC_LINE=IC_LINE-1;
        NUM_STACKS=NUM_STACKS-1;
        NUM_FL_NO=NUM_FL_NO-1;
        NUM_ELEMENTS=NUM_ELEMENTS+INX(PTR(MP));
        PTR_TOP=PTR(MP)-1;
    elif PRODUCTION_NUMBER == 419:
        #  <REPEAT HEAD>  ::=  <ARITH EXP>  #
        CHECK_ARRAYNESS();
        if PSEUDO_FORM(PTR(MP))!=XLIT: 
            TEMP_SYN=0;
        else:
            TEMP_SYN=MAKE_FIXED_LIT(LOC_P(PTR(MP)));
        if TEMP_SYN<1: 
            ERROR(d.CLASS_DI,1);
            TEMP_SYN=0;
        if TEMP_SYN>NUM_EL_MAX: 
            TEMP_SYN=NUM_EL_MAX;
        INX(PTR(MP))=TEMP_SYN;
        FIXV(MP)=NUM_ELEMENTS;
        NUM_FL_NO=NUM_FL_NO+1;
        SET_INIT(TEMP_SYN,1,0,0,NUM_FL_NO);
        FIXL(MP)=IC_LINE;
        NUM_STACKS=NUM_STACKS+1;
    elif PRODUCTION_NUMBER == 420:
        #  <NESTED REPEAT HEAD>  ::=  <REPEAT HEAD>  (
        pass;
    elif PRODUCTION_NUMBER == 421:
        #  <NESTED REPEAT HEAD>  ::=  <NESTED REPEAT HEAD>  <REPEATED CONSTANT>  ,
        pass;
    elif PRODUCTION_NUMBER == 422:
        #  <CONSTANT>  ::=  <NUMBER>
        TEMP_SYN=INT_TYPE;
        DO_CONSTANT:
        PTR(MP)=PUSH_INDIRECT(1);
        PSEUDO_TYPE(PTR(MP))=TEMP_SYN;
        PSEUDO_FORM(PTR(MP))=XLIT;
        LOC_P(PTR(MP))=FIXL(MP);
    elif PRODUCTION_NUMBER == 423:
        #  <CONSTANT>  ::=  <COMPOUND NUMBER>
        TEMP_SYN=SCALAR_TYPE;
        GO TO DO_CONSTANT;
    elif PRODUCTION_NUMBER == 424:
        #  <CONSTANT>  ::=  <BIT CONST>
        pass;
    elif PRODUCTION_NUMBER == 425:
        #  <CONSTANT>  ::=  <CHAR CONST>
        pass;
    elif PRODUCTION_NUMBER in (426, 427):
        #  <NUMBER> ::= <SIMPLE NUMBER>
        #  <NUMBER> ::= <LEVEL>
        pass
    elif PRODUCTION_NUMBER == 428:
        #  <CLOSING> ::= CLOSE
        VAR(MP) = '';
        CLOSE_IT:
        INDENT_LEVEL=INDENT_LEVEL-INDENT_INCR;
        g.XSET(0x6);
    elif PRODUCTION_NUMBER == 429:
        #  <CLOSING> ::= CLOSE <LABEL>
        VAR(MP) = VAR(SP);
        GO TO CLOSE_IT;
    elif PRODUCTION_NUMBER == 430:
        #  <CLOSING> ::= <LABEL DEFINITION> <CLOSING>
        SET_LABEL_TYPE(FIXL(MP), STMT_LABEL);
        VAR(MP) = VAR(SP);
    elif PRODUCTION_NUMBER == 431:
        # <TERMINATOR>::= TERMINATE
        FIXL(MP)=XTERM;
        FIXV(MP)=0xE000;
    elif PRODUCTION_NUMBER == 432:
        # <TERMINATOR>::= CANCEL
        FIXL(MP)=XCANC;
        FIXV(MP)=0xA000;
    elif PRODUCTION_NUMBER == 433:
        #  <TERMINATE LIST>  ::=  <LABEL VAR>
        EXT_P(PTR(MP))=1;
        GO TO TERM_LIST;
    elif PRODUCTION_NUMBER == 434:
        #  <TERMINATE LIST>  ::=  <TERMINATE LIST>  ,  <LABEL VAR>
        EXT_P(PTR(MP))=EXT_P(PTR(MP))+1;
        TERM_LIST:
        SET_XREF_RORS(SP,FIXV(MP-1));
        PROCESS_CHECK(SP);
    elif PRODUCTION_NUMBER == 435:
        # <WAIT KEY>::= WAIT
        REFER_LOC=1;
    elif PRODUCTION_NUMBER == 436:
        #  <SCHEDULE HEAD>  ::=  SCHEDULE  <LABEL VAR>
        PROCESS_CHECK(MPP1);
        if (SYT_FLAGS(FIXL(MPP1)) & ACCESS_FLAG) != 0:
            ERROR(d.CLASS_PS, 5, VAR(MPP1));
        SET_XREF_RORS(MPP1,0x6000);
        REFER_LOC,PTR(MP)=PTR(MPP1);
        INX(REFER_LOC)=0;
    elif PRODUCTION_NUMBER == 437:
        # <SCHEDULE HEAD>::= <SCHEDULE HEAD> AT <ARITH EXP>
        TEMP=0x1;
        if UNARRAYED_SCALAR(SP): 
            ERROR(d.CLASS_RT,1,'AT');
        SCHEDULE_AT:
        if INX(REFER_LOC)==0: 
            INX(REFER_LOC)=TEMP;
        else:
            ERROR(d.CLASS_RT,5);
            PTR_TOP=PTR_TOP-1;
    elif PRODUCTION_NUMBER == 438:
        # <SCHEDULE HEAD>::= <SCHEDULE HEAD> IN <ARITH EXP>
        TEMP=0x2;
        if UNARRAYED_SCALAR(SP): 
            ERROR(d.CLASS_RT,1,'IN');
        GO TO SCHEDULE_AT;
    elif PRODUCTION_NUMBER == 439:
        # <SCHEDULE HEAD>::=<SCHEDULE HEAD> ON <BIT EXP>
        TEMP=0x3;
        if CHECK_EVENT_EXP(SP): 
            ERROR(d.CLASS_RT,3,'ON');
        GO TO SCHEDULE_AT;
    elif PRODUCTION_NUMBER == 440:
        # <SCHEDULE PHRASE>::=<SCHEDULE HEAD>
        SCHED_PRIO:
        ERROR(d.CLASS_RT,4,'SCHEDULE');
    elif PRODUCTION_NUMBER == 441:
        # <SCHEDULE PHRASE>::=<SCHEDULE HEAD> PRIORITY (<ARITH EXP>)
        if UNARRAYED_INTEGER(SP-1): 
            GO TO SCHED_PRIO;
        INX(REFER_LOC)=INX(REFER_LOC)|0x4;
    elif PRODUCTION_NUMBER == 442:
        #  <SCHEDULE PHRASE>  ::=  <SCHEDULE PHRASE>  DEPENDENT
        INX(REFER_LOC)=INX(REFER_LOC)|0x8;
    elif PRODUCTION_NUMBER == 443:
        # <SCHEDULE CONTROL>::= <STOPPING>
        pass;
    elif PRODUCTION_NUMBER == 444:
        # <SCHEDULE CONTROL>::= <TIMING>
        pass;
    elif PRODUCTION_NUMBER == 445:
        # <SCHEDULE CONTROL>::= <TIMING><STOPPING>
        pass;
    elif PRODUCTION_NUMBER == 446:
        #  <TIMING>  ::=  <REPEAT> EVERY <ARITH EXP>
        TEMP=0x20;
        SCHEDULE_EVERY:
        if UNARRAYED_SCALAR(SP): 
            ERROR(d.CLASS_RT,1,'EVERY/AFTER');
        INX(REFER_LOC)=INX(REFER_LOC)|TEMP;
    elif PRODUCTION_NUMBER == 447:
        #  <TIMING>  ::=  <REPEAT> AFTER <ARITH EXP>
        TEMP=0x30;
        GO TO SCHEDULE_EVERY;
    elif PRODUCTION_NUMBER == 448:
        #  <TIMING>  ::=  <REPEAT>
        INX(REFER_LOC)=INX(REFER_LOC)|0x10;
    elif PRODUCTION_NUMBER == 449:
        #  <REPEAT>  ::=  , REPEAT
        CONTEXT=0;
    elif PRODUCTION_NUMBER == 450:
        # <STOPPING>::=<WHILE KEY><ARITH EXP>
        if FIXL(MP)==0: 
            ERROR(d.CLASS_RT,2);
        elif UNARRAYED_SCALAR(SP): 
            ERROR(d.CLASS_RT,1,'UNTIL');
        INX(REFER_LOC)=INX(REFER_LOC)|0x40;
    elif PRODUCTION_NUMBER == 451:
        # <STOPPING>::=<WHILE KEY><BIT EXP>
        DO;
        if CHECK_EVENT_EXP(SP): ERROR(d.CLASS_RT,3,'WHILE/UNTIL');
        TEMP=SHL(FIXL(MP)+2,6);
        INX(REFER_LOC)=INX(REFER_LOC)|TEMP;
        END;
    elif PRODUCTION_NUMBER in (452, 453, 454, 456, 456):
        pass          #  INSURANCE
        
    # END OF PART_2
    if (PREV_STMT_NUM != STMT_NUM):
        INCREMENT_DOWN_STMT = FALSE;
    PREV_STMT_NUM = STMT_NUM;
    

