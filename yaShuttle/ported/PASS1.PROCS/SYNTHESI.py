#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   RECOVER.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-12 RSB  Began porting from XPL
            2023-10-15 RSB  Changed the spaghetti-code workaround mechanism.

I realized belatedly that the method I use for handling spaghetti code in all
of the modules so far -- namely, the use of goto_XXXX variables, one for each
distinct target label of GO TO commands -- is actually inadequate for this 
module.  That's because it potentially allows productions to be made 
erroneously on the basis of some GO TO's.

So I'm replacing it with a different technique that I may also migrate
(painfully!) to all modules at some point.  The technique is pretty simple:
There's just a variable called goto that is normally assigned a value of None,
but which is assigned a string identical to the target value when a GO TO is
requested.  For example, here's a GO TO MYLABEL:
    ...
    goto = None                        # Initial condition.
    ...
    goto = "MYLABEL"                   # Where GO TO MYLABEL was located.
    ...
    if goto == "MYLABEL": goto = None  # Where MYLABEL: is located.
    ...
Of course, these things by themselves don't perform the GO TO, so there have
to be appropriate conditionals in the form of IF ... THEN or WHILE added also.

Alas, this change, though theoretically much better, didn't change the errors
in my test compilations one iota.
'''

import sys
noSyn = ("--no-syn" in sys.argv[1:])

from xplBuiltins import *
import g
import HALINCL.COMMON as h
import HALINCL.CERRDECL as d
import HALINCL.COMDEC19 as c19
import HALINCL.SPACELIB as sl
from ADDANDSU import ADD_AND_SUBTRACT
from ARITHTOC import ARITH_TO_CHAR
from ARITHLIT import ARITH_LITERAL
from ARITHSHA import ARITH_SHAPER_SUB
from ASSOCIAT import ASSOCIATE
from ATTACHS4 import ATTACH_SUBSCRIPT
from BITLITER import BIT_LITERAL
from BLOCKSUM import BLOCK_SUMMARY
from CALLSCAN import CALL_SCAN
from CHARLITE import CHAR_LITERAL
from CHECKARR import CHECK_ARRAYNESS
from CHECKASS import CHECK_ASSIGN_CONTEXT
from CHECKCO2 import CHECK_CONFLICTS
from CHECKCON import CHECK_CONSISTENCY
from CHECKEV2 import CHECK_EVENT_CONFLICTS
from CHECKEVE import CHECK_EVENT_EXP
from CHECKIMP import CHECK_IMPLICIT_T
from CHECKNAM import CHECK_NAMING
from COMPRESS import COMPRESS_OUTER_REF
from COPINESS import COPINESS
from DESCORE  import DESCORE
from EMITARRA import EMIT_ARRAYNESS
from EMITEXTE import EMIT_EXTERNAL
from EMITPUSH import EMIT_PUSH_DO
from EMITSMRK import EMIT_SMRK
from EMITSUBS import EMIT_SUBSCRIPT
from ENDANYFC import END_ANY_FCN
from ERROR    import ERROR
from ERRORSUB import ERROR_SUB
from GETICQ   import GET_ICQ
from GETLITER import GET_LITERAL
from HALMATBA import HALMAT_BACKUP
from HALMATF2 import HALMAT_FIX_POPTAG
from HALMATF3 import HALMAT_FIX_PIPTAGS
from HALMATFI import HALMAT_FIX_PIPp
from HALMATIN import HALMAT_INIT_CONST
from HALMATOU import HALMAT_OUT
from HALMATPI import HALMAT_PIP
from HALMATPO import HALMAT_POP
from HALMATTU import HALMAT_TUPLE
from HASH     import HASH
from IORS     import IORS
from KILLNAME import KILL_NAME
from LABELMAT import LABEL_MATCH
from LITRESUL import LIT_RESULT_TYPE
from MAKEFIXE import MAKE_FIXED_LIT
from MATCHARI import MATCH_ARITH
from MATCHSIM import MATCH_SIMPLES
from MATRIXCO import MATRIX_COMPARE
from MULTIPLY import MULTIPLY_SYNTHESIZE
from NAMEARRA import NAME_ARRAYNESS
from NAMECOMP import NAME_COMPARE
from OUTPUTWR import OUTPUT_WRITER
from PROCESS2 import PROCESS_CHECK
from PUSHFCNS import PUSH_FCN_STACK
from PUSHINDI import PUSH_INDIRECT
from READALLT import READ_ALL_TYPE
from RESETARR import RESET_ARRAYNESS
from SAVEARRA import SAVE_ARRAYNESS
from SETBLOCK import SET_BLOCK_SRN
from SETLABEL import SET_LABEL_TYPE
from SETOUTER import SET_OUTER_REF
from SETSYTEN import SET_SYT_ENTRIES
from SETUPCAL import SETUP_CALL_ARG
from SETUPNOA import SETUP_NO_ARG_FCN
from SETUPVAC import SETUP_VAC
from SETBIXRE import SET_BI_XREF
from SETXREF  import SET_XREF
from SETXREFR import SET_XREF_RORS
from SRNUPDAT import SRN_UPDATE
from STABHDR  import STAB_HDR
from STACKDUM import STACK_DUMP
from STARTNOR import START_NORMAL_FCN
from STRUCTUR import STRUCTURE_COMPARE
from TIEXREF  import TIE_XREF
from UNARRAY2 import UNARRAYED_SCALAR
from UNARRAY3 import UNARRAYED_SIMPLE
from UNARRAYE import UNARRAYED_INTEGER
from UNBRANCH import UNBRANCHABLE
from VECTORCO import VECTOR_COMPARE
from HALINCL.CHECKSTR import CHECK_STRUC_CONFLICTS
from HALINCL.DISCONNE import DISCONNECT
from HALINCL.ENTER    import ENTER
from HALINCL.ENTERLAY import ENTER_LAYOUT
from HALINCL.ICQARRAY import ICQ_ARRAYp
from HALINCL.ICQTERMp import ICQ_TERMp
from HALINCL.SAVELITE import SAVE_LITERAL

# I've created a file listing the rules associated with specific production
# numbers, and read it into memory so that those names can be printed for
# documentation purposes (via the --extra CLI switch).  Alas, that info wasn't
# present in the original XPL source, except as program comments (from which
# I've extracted it); the best that was present there was the left-hand sides
# of the rules, which obviously are less human-friendly.  The file has lines 
# consisting of the rule number (starting from 1), a tab, and the text of the 
# rule, so this needs a little massaging to put it into useful form.
PRODUCTION_NUMBERS = [None] # First entry (PRODUCTION_NUMBER == 0) is a dummy.
try:
    f = open("PRODUCTION_NUMBERS.txt", "r")
except:
    f = open(scriptFolder + "/PRODUCTION_NUMBERS.txt", "r")
for line in f:
    PRODUCTION_NUMBERS.append(line.rstrip().split('\t')[1])
f.close()

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

# Fakes up a loop that clears TYPE[] when pretending that TYPE is an array
# of memory locations.
def clearListTYPE():
    g.TYPE = 0
    g.BIT_LENGTH = 0
    g.CHAR_LENGTH = 0
    g.MAT_LENGTH = 0
    g.VEC_LENGTH = 0
    g.ATTRIBUTES = 0
    g.ATTRIBUTES2 = 0
    g.ATTR_MASK = 0
    g.STRUC_PTR = 0
    g.STRUC_DIM = 0
    g.CLASS = 0
    g.NONHAL = 0
    g.LOCKp = 0
    g.IC_PTR = 0
    g.IC_FND = 0
    g.N_DIM = 0
    g.S_ARRAY = [0] * (g.N_DIM_LIM + 1)


#                  THE SYNTHESIS ALGORITHM FOR HAL


class cSYNTHESIZE:

    def __init__(self):
        self.INLINE_NAME = '$FUNCTION'
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
    l = lSYNTHESIZE  # Local variables.
        
    def SET_INIT(A, B, C, D, E):
        # Local Q doesn't need to be persistent
        g.IC_LINE = g.IC_LINE + 1;
        if g.IC_LINE > g.NUM_EL_MAX:
            ERROR(d.CLASS_BT, 7);
        Q = GET_ICQ(g.IC_LINE);
        g.IC_VAL[Q] = E;
        g.IC_LOC[Q] = A;
        g.IC_LEN[Q] = C;
        g.IC_FORM[Q] = B;
        g.IC_TYPE[Q] = D;
    
    '''
    THIS PROCEDURE IS RESPONSIBLE FOR THE SEMANTICS (CODE SYNTHESIS), IF
    ANY, OF THE SKELETON COMPILER.  ITS ARGUMENT IS THE NUMBER OF THE
    PRODUCTION WHICH WILL BE APPLIED IN THE PENDING REDUCTION.  THE GLOBAL
    VARIABLES g.MP AND g.SP POINT TO THE BOUNDS IN THE STACKS OF THE RIGHT PART
    OF THIS PRODUCTION.
    '''
    
    if g.CONTROL[8]:
        OUTPUT(0, '->->->->->->PRODUCTION NUMBER ' + str(PRODUCTION_NUMBER))
        if g.extraTrace:
            #print("   { \"%s\" }" % \
            #      g.VOCAB_INDEX[g.pPRODUCE_NAME[PRODUCTION_NUMBER]], end="")
            print("   { \"%s\" }" % PRODUCTION_NUMBERS[PRODUCTION_NUMBER], \
                  end="")
        
    if noSyn:
        # This is just to simplify debugging of SCAN. Bypass in production.
        if PRODUCTION_NUMBER == 1: 
            # <COMPILATION>::= <COMPILE LIST> _|_
            if g.MP > 0:
                ERROR(d.CLASS_P, 1);
                STACK_DUMP();
            g.COMPILING = 0x80;
            g.STMT_PTR = g.STMT_PTR - 1;
        return
    
    if SHR(g.pPRODUCE_NAME[PRODUCTION_NUMBER], 12) & 1:
        ERROR(d.CLASS_XS, 2, '#' + PRODUCTION_NUMBER);
    
    # THIS CODE CHECKS TO SEE IF THE PREVIOUS STATEMENT WAS AN
    # IF-THEN OR ELSE AND IF THE CURRENT STATEMENT IS NOT A SIMPLE DO.
    # IF TRUE, THE PREVIOUS STATEMENT IS PRINTED AND EXEUCTION CONTINUES.
    if (g.IF_FLAG or g.ELSE_FLAG) and (PRODUCTION_NUMBER != 144):
        g.SQUEEZING = g.FALSE;
        l.CHANGED_STMT_NUM = g.FALSE;
        if g.IF_FLAG:
            g.STMT_NUM(g.STMT_NUM() - 1);
            l.CHANGED_STMT_NUM = g.TRUE;
        g.SAVE_SRN2 = g.SRN[2][:];
        g.SRN[2] = g.SAVE_SRN1[:];
        g.SAVE_SRN_COUNT2 = g.SRN_COUNT[2];
        g.SRN_COUNT[2] = g.SAVE_SRN_COUNT1;
        g.IF_FLAG = g.FALSE
        g.ELSE_FLAG = g.FALSE;  # MUST BE BEFORE OUTPUTWR CALL
        OUTPUT_WRITER(g.SAVE1, g.SAVE2);
        g.INDENT_LEVEL = g.INDENT_LEVEL + g.INDENT_INCR;
        if l.CHANGED_STMT_NUM:
            g.STMT_NUM(g.STMT_NUM() + 1);
        if g.STMT_PTR > -1:
            g.LAST_WRITE = g.SAVE2 + 1;
        g.SRN[2] = g.SAVE_SRN2[:];
        g.SRN_COUNT[2] = g.SAVE_SRN_COUNT2;
    
    # THIS CODE IS USED TO ALIGN THE ELSE STATEMENTS CORRECTLY.
    # IF THE CURRENT STATEMENT IS NOT AN ELSE OR A DO, MOVE_ELSE=TRUE.
    if (PRODUCTION_NUMBER != 140) and (PRODUCTION_NUMBER != 54) and \
            (PRODUCTION_NUMBER != 40):
        g.MOVE_ELSE = g.TRUE;
    if (g.SAVE_DO_LEVEL != -1) and (PRODUCTION_NUMBER != 167):
        g.IFDO_FLAG[g.SAVE_DO_LEVEL] = g.FALSE;
        g.SAVE_DO_LEVEL = -1;
    
    '''
    The case statement below, which comprises essentially the remainder of the
    procedure, contains large amounts of spaghetti code in which there are 
    GO TO's within cases that jump inside of other cases.  For the most part,
    with only a few exceptions, that's handled by rearranging the cases so
    that cases with internal target labels are positioned somewhere below
    the cases that have GO TO's targeting them.  That makes it relatively 
    easy to cause those GO TO's to essentially fall into their targets.
    
    Each of the cases for the DO CASE is specified by a condition like
    PRODUCTION_NUMBER == x, however, manual entry and maintenance of those
    PRODUCTION_NUMBERs (at least originally) was error prone and nightmarish.
    I hope they're all correct now.  However, I've accompanied them by comments
    of the form 
        # reference 10*PRODUCTION_NUMBER
    and those reference numbers will remain constant (at their initial values)
    even if the underlying PRODUCTION_NUMBERs need to be corrected somehow;
    thus the reference numbers potentially provide more-stable ways of 
    referring to the cases than the actual PRODUCTION_NUMBERs do.  I've made
    the reference numbers initially 10*PRODUCTION_NUMBER to provide room to
    insert new numbers in between in case missing cases are discovered, without
    having to change the existing reference numbers any.  Again, I think that's
    unlikely, because I eventually automated creation of the
    PRODUCTION_NUMBERS in this code (see productionNumbers.py) to eliminate
    the human error I was introducing when I input or corrected them manually.
    Given that there are ~460 cases, there was a lot of potential for error
    before I automated it.
    
    The general layout of the DO CASE, after rearrangement of the cases, 
    is that we have 3 basic groupings of cases:
    
        1. Cases with *no* labels that are targets of GO TO's (or for which the
           GO TO's to the label are within the case itself), and with no 
           GO TO's targeting any cases *above* them.  This group also contains
           reference 110, which is contained within its own while-loop because
           of the large number of internal GO TO's it has.
        2. Cases with labels that are targets of GO TO's of *above* them but 
           with no GO TO's targeting any cases *above* them.
        3. The cases (references 3110 and 3210) that have GO TO's targeting
           each other are enclosed together in their only mini while-loop.
    
    Within each of the groupings, I've tried to keep the cases sorted 
    more-or-less by PRODUCTION_NUMBER (or reference number), but in the 
    second grouping, that wasn't always possible.
    '''
    
    goto = None # Initialize spaghetti code.
    
    # DO CASE PRODUCTION_NUMBER;
    if PRODUCTION_NUMBER == 0:  # reference 0
        pass
    elif PRODUCTION_NUMBER == 1:  # reference 10
        # <COMPILATION>::= <COMPILE LIST> _|_
        if g.MP > 0:
            ERROR(d.CLASS_P, 1);
            STACK_DUMP();
        elif g.BLOCK_MODE[0] == 0: 
            ERROR(d.CLASS_PP, 4);
        HALMAT_POP(g.XXREC, 0, 0, 1);
        g.ATOMp_FAULT = -1;
        HALMAT_OUT();
        # Must form a bytearray from h.LIT_PG[0] for the call to FILE().
        b = bytearray([])
        lit_pg = h.LIT_PG[0]
        for lit in [lit_pg.LITERAL1, lit_pg.LITERAL2, lit_pg.LITERAL3]:
            for j in range(g.LIT_BUF_SIZE):
                v = lit[j]
                b.append((v >> 24) & 0xFF)
                b.append((v >> 16) & 0xFF)
                b.append((v >> 8) & 0xFF)
                b.append(v & 0xFF)
        FILE(g.LITFILE, g.CURLBLK, b);
        g.COMPILING = 0x80;
        g.STMT_PTR = g.STMT_PTR - 1;
    elif PRODUCTION_NUMBER == 2:  # reference 20
        # <COMPILE LIST>::=<BLOCK DEFINITION>
        pass;
    elif PRODUCTION_NUMBER == 3:  # reference 30
        # <COMPILE LIST>::= <COMPILE LIST> <BLOCK DEFINITION>
        pass;
    elif PRODUCTION_NUMBER == 4:  # reference 40
        #  <ARITH EXP> ::= <TERM>
        pass;
    elif PRODUCTION_NUMBER == 5:  # reference 50
        #  <ARITH EXP> ::= + <TERM>
        # JUST ABSORB '+' SIGN, IE, RESET INDIRECT STACK
        g.PTR[g.MP] = g.PTR[g.SP] ;
        g.NOSPACE();
    elif PRODUCTION_NUMBER == 6:  # reference 60
        #  <ARITH EXP> ::= -1 <TERM>
        if ARITH_LITERAL(g.SP, 0):
            # My guess is that INLINE code is being used here, unnecessarily,
            # as an optimization for quickly negating a numeric literal
            # previously stored as an IBM DP float in DW[0] and DW[1].  
            negatedValue = -fromFloatIBM(g.DW[0], g.DW[1])
            g.LOC_P[g.PTR[g.SP]] = SAVE_LITERAL(1, negatedValue);
        else:
            g.TEMP = g.PSEUDO_TYPE[g.PTR[g.SP]];
            HALMAT_TUPLE(g.XMNEG[g.TEMP - g.MAT_TYPE], 0, g.SP, 0, 0);
            SETUP_VAC(g.SP, g.TEMP, g.PSEUDO_LENGTH[g.PTR[g.SP]]);
        g.NOSPACE();
        g.PTR[g.MP] = g.PTR[g.SP];
    elif PRODUCTION_NUMBER == 7:  # reference 70
        #  <ARITH EXP> ::= <ARITH EXP> + <TERM>
        ADD_AND_SUBTRACT(0);
    elif PRODUCTION_NUMBER == 8:  # reference 80
        #  <ARITH EXP> ::= <ARITH EXP> -1 <TERM>
        ADD_AND_SUBTRACT(1);
    elif PRODUCTION_NUMBER == 9:  # reference 90
        #  <TERM> ::= <PRODUCT>
        pass;
    elif PRODUCTION_NUMBER == 10:  # reference 100
        #  <TERM> ::= <PRODUCT> / <TERM>
        al = ARITH_LITERAL(g.MP, g.SP)
        if al:
            if MONITOR(9, 4):
                ERROR(d.CLASS_VA, 4);
                goto = "DIV_FAIL";
            else:
                g.LOC_P[g.PTR[g.MP]] = \
                    SAVE_LITERAL(1, g.DW_AD());
                g.PSEUDO_TYPE[g.PTR[g.MP]] = g.SCALAR_TYPE;
        if goto == "DIV_FAIL" or (goto == None and not al):
            if goto == "DIV_FAIL": goto = None
            if g.PSEUDO_TYPE[g.PTR[g.SP]] < g.SCALAR_TYPE:
                ERROR(d.CLASS_E, 1);
            g.PTR[0] = 0;
            g.PSEUDO_TYPE[0] = g.SCALAR_TYPE;
            MATCH_SIMPLES(0, g.SP);
            if g.PSEUDO_TYPE[g.PTR[g.MP]] >= g.SCALAR_TYPE: 
                MATCH_SIMPLES(0, g.MP);
            g.TEMP = g.PSEUDO_TYPE[g.PTR[g.MP]];
            HALMAT_TUPLE(g.XMSDV[g.TEMP - g.MAT_TYPE], 0, g.MP, g.SP, 0);
            SETUP_VAC(g.MP, g.TEMP);
        g.PTR_TOP = g.PTR[g.MP];
    # Reference 110 has been relocated.
    elif PRODUCTION_NUMBER == 12:  # reference 120
        #  <PRODUCT> ::= <FACTOR> * <PRODUCT>
        pass
    elif PRODUCTION_NUMBER == 13:  # reference 130
        #  <PRODUCT> ::= <FACTOR> . <PRODUCT>
        pass
    elif PRODUCTION_NUMBER == 14:  # reference 140
        #  <PRODUCT> ::= <FACTOR> <PRODUCT>
        pass
    elif PRODUCTION_NUMBER == 15:  # reference 150
        # <FACTOR> ::= <PRIMARY>
        if g.PARSE_STACK[g.MP - 1] != g.EXPONENT: 
            if g.FIXF[g.MP] > 0:
                SET_XREF_RORS(g.MP);
    elif PRODUCTION_NUMBER == 16:  # reference 160
        #  <FACTOR>  ::=  <PRIMARY>  <**>  <FACTOR>
        g.I = g.PTR[g.SP];
        if g.FIXF[g.MP] > 0: 
            SET_XREF_RORS(g.MP);
        g.EXPONENT_LEVEL = g.EXPONENT_LEVEL - 1;
        g.TEMP = g.PSEUDO_TYPE[g.PTR[g.MP]];
        # DO CASE TEMP-MAT_TYPE;
        tmt = g.TEMP - g.MAT_TYPE
        if tmt == 0:
            #  MATRIX
            g.TEMP2 = g.PSEUDO_LENGTH[g.PTR[g.MP]];
            if (g.PSEUDO_FORM[g.I] == g.XSYT)or(g.PSEUDO_FORM[g.I] == g.XXPT):
                if g.VAR[g.SP] == 'T': 
                    HALMAT_TUPLE(g.XMTRA, 0, g.MP, 0, 0);
                    SETUP_VAC(g.MP, g.TEMP, SHL(g.TEMP2, 8) | SHR(g.TEMP2, 8));
                    if g.IMPLICIT_T:
                        g.SYT_FLAGS(g.LOC_P[g.I], g.SYT_FLAGS(g.LOC_P[g.I]) | g.IMPL_T_FLAG);
                        g.IMPLICIT_T = g.FALSE;
                    goto = "T_FOUND";
            if goto == None:
                if g.PSEUDO_TYPE[g.I] != g.INT_TYPE or g.PSEUDO_FORM[g.I] != g.XLIT:
                    ERROR(d.CLASS_E, 2);
                if (g.TEMP2 & 0xFF) != SHR(g.TEMP2, 8): 
                    ERROR(d.CLASS_EM, 4);
                HALMAT_TUPLE(g.XMINV, 0, g.MP, g.SP, 0);
                SETUP_VAC(g.MP, g.TEMP);
        elif tmt == 1:
            #  VECTOR
            ERROR(d.CLASS_EV, 4);
            g.TEMP2 = g.XSEXP;
            # Rather than implement the GO TO FINISH_EXP, I've just duplicated
            # the code that's at FINISH_EXP.
            # GO TO FINISH_EXP;
            HALMAT_TUPLE(g.TEMP2, 0, g.MP, g.SP, 0);
            SETUP_VAC(g.MP, g.PSEUDO_TYPE[g.PTR[g.MP]]);
        elif tmt in (2, 3):
            #  2 - SCALAR
            #  3 - INTEGER
            # SIMPLE_EXP:
            al = ARITH_LITERAL(g.MP, g.SP, g.TRUE)
            if al:
                if MONITOR(9, 5):
                    ERROR(d.CLASS_VA, 5);
                    goto = "POWER_FAIL"
                else:
                    g.LOC_P[g.PTR[g.MP]] = SAVE_LITERAL(1, g.DW_AD());
                    g.TEMP = LIT_RESULT_TYPE(g.MP, g.SP);
                    if g.TEMP == g.INT_TYPE: 
                        if MAKE_FIXED_LIT(g.LOC_P[g.I]) < 0:
                            g.TEMP = g.SCALAR_TYPE;
                    g.PSEUDO_TYPE[g.PTR[g.MP]] = g.TEMP;
            if goto == "POWER_FAIL" or (goto == None and not al):  # was else: 
                if goto == "POWER_FAIL": goto = None
                g.TEMP2 = g.XSPEX[g.TEMP - g.SCALAR_TYPE];
                if g.PSEUDO_TYPE[g.I] < g.SCALAR_TYPE: 
                    ERROR(d.CLASS_E, 3);
                firstTry = True
                while firstTry or goto == "REGULAR_EXP":
                    firstTry = False
                    if g.PSEUDO_TYPE[g.I] != g.INT_TYPE or goto == "REGULAR_EXP":
                        if not goto == "REGULAR_EXP":
                            g.TEMP2 = g.XSEXP;
                        if goto == "REGULAR_EXP": goto = None
                        g.PTR[0] = 0;
                        g.PSEUDO_TYPE[0] = g.SCALAR_TYPE;
                        MATCH_SIMPLES(g.MP, 0);
                    elif g.PSEUDO_FORM[g.I] != g.XLIT:
                       g.TEMP2 = g.XSIEX;
                       goto = "REGULAR_EXP"
                       continue
                    else:
                       g.TEMP = MAKE_FIXED_LIT(g.LOC_P[g.I]);
                       if g.TEMP < 0: 
                           g.TEMP2 = g.XSIEX;
                           goto = "REGULAR_EXP"
                           continue
                # FINISH_EXP:
                HALMAT_TUPLE(g.TEMP2, 0, g.MP, g.SP, 0);
                SETUP_VAC(g.MP, g.PSEUDO_TYPE[g.PTR[g.MP]]);
        # End of CASE TEMP-MAT_TYPE
        if goto == None:
            if g.FIXF[g.SP] > 0: 
                SET_XREF_RORS(g.SP);
        if goto == "T_FOUND": goto = None
        g.PTR_TOP = g.PTR[g.MP];
    elif PRODUCTION_NUMBER == 17:  # reference 170
        #  <**>  ::=  **
        g.EXPONENT_LEVEL = g.EXPONENT_LEVEL + 1;
    elif PRODUCTION_NUMBER == 18:  # reference 180
        #  <PRE PRIMARY>  ::=  (  <ARITH EXP>  )
        g.VAR[g.MP] = g.VAR[g.MPP1];
        g.PTR[g.MP] = g.PTR[g.MPP1];
    # reference 190 has been relocated.
    elif PRODUCTION_NUMBER == 20:  # reference 200
        #  <PRE PRIMARY> ::= <COMPOUND NUMBER>
        g.TEMP = g.SCALAR_TYPE;
        goto = "ARITH_LITS"
    elif PRODUCTION_NUMBER == 21:  # reference 210
        #  <ARITH FUNC HEAD>  ::=  <ARITH FUNC>
        START_NORMAL_FCN();
    elif PRODUCTION_NUMBER == 22:  # reference 220
        #  <ARITH FUNC HEAD>  ::=  <ARITH CONV> <SUBSCRIPT>
        g.NOSPACE();
        g.NEXT_SUB = g.PTR[g.SP];
        g.TEMP = g.NEXT_SUB
        g.PTR_TOP = g.TEMP
        g.PTR[g.MP] = g.TEMP;
        if g.INX[g.TEMP] == 0: 
            goto = "DEFAULT_SHAPER"
        else:
            if (g.PSEUDO_LENGTH[g.TEMP] >= 0) or (g.VAL_P[g.TEMP] >= 0): 
                ERROR(d.CLASS_QS, 1);
            # DO CASE FIXL[MP];
            fm = g.FIXL[g.MP]
            if fm == 0:
                #  MATRIX
                if g.INX[g.TEMP] != 2: 
                    ERROR(d.CLASS_QS, 2);
                    goto = "DEFAULT_SHAPER"
                else:
                    g.TEMP_SYN = ARITH_SHAPER_SUB(g.MAT_DIM_LIM);
                    g.TEMP1 = ARITH_SHAPER_SUB(g.MAT_DIM_LIM);
                    g.PSEUDO_LENGTH[g.TEMP] = SHL(g.TEMP_SYN, 8) | g.TEMP1;
                    g.INX[g.TEMP] = g.TEMP_SYN * g.TEMP1;
            elif fm == 1:
                #  VECTOR
                if g.INX[g.TEMP] != 1: 
                    ERROR(d.CLASS_QS, 3);
                    goto = "DEFAULT_SHAPER"
                else:
                    g.TEMP_SYN = ARITH_SHAPER_SUB(g.VEC_LENGTH_LIM);
                    g.PSEUDO_LENGTH[g.TEMP] = g.TEMP_SYN
                    g.INX[g.TEMP] = g.TEMP_SYN;
            elif fm in (2, 3):
                #  2 - SCALAR
                #  3 - INTEGER
                # SCALAR_SHAPER:
                if (g.INX[g.TEMP] < 1) or (g.INX[g.TEMP] > g.N_DIM_LIM):
                    ERROR(d.CLASS_QS, 4);
                    goto = "DEFAULT_SHAPER"
                else:
                    g.TEMP_SYN = 1;
                    for g.TEMP1 in range(1, 1 + g.INX[g.TEMP]):
                        g.PTR_TOP = g.PTR_TOP + 1;  # OLD STACKS BEING REINSTATED
                        g.LOC_P[g.PTR_TOP] = ARITH_SHAPER_SUB(g.ARRAY_DIM_LIM);
                        g.TEMP_SYN = g.LOC_P[g.PTR_TOP] * g.TEMP_SYN;
                    # IF THE TOTAL NUMBER OF ELEMENTS BEING CREATED
                    # WITH A SHAPING FUNCTION IS GREATER THAN 32767
                    # OR LESS THAN 1 THEN GENERATE A QS8 ERROR
                    if (g.TEMP_SYN > g.ARRAY_DIM_LIM) or (g.TEMP_SYN < 1):  # ""
                        ERROR(d.CLASS_QS, 8);
                    g.PSEUDO_LENGTH[g.TEMP] = g.TEMP_SYN;
        if goto == None:
            goto = "SET_ARITH_SHAPERS"
        else:
            if goto == "DEFAULT_SHAPER": goto = None
            # DO CASE FIXL[MP];
            fm = g.FIXL[g.MP]
            if fm == 0:
                #  MATRIX
                g.PSEUDO_LENGTH[g.PTR_TOP] = g.DEF_MAT_LENGTH;
                g.TEMP = g.DEF_MAT_LENGTH & 0xFF;
                g.INX[g.PTR_TOP] = g.TEMP * g.TEMP;
            elif fm == 1:
                #  VECTOR
                g.PSEUDO_LENGTH[g.PTR_TOP] = g.DEF_VEC_LENGTH
                g.INX[g.PTR_TOP] = g.DEF_VEC_LENGTH;
            elif fm == 2:
                #  SCALAR
                g.INX[g.PTR_TOP] = 0;
            elif fm == 3:
                #  INTEGER
                g.INX[g.PTR_TOP] = 0;
        if goto == "SET_ARITH_SHAPERS": goto = None;
        g.PSEUDO_TYPE[g.PTR[g.MP]] = g.FIXL[g.MP] + g.MAT_TYPE;
        if PUSH_FCN_STACK(2): 
            g.FCN_LOC[g.FCN_LV] = g.FIXL[g.MP];
            SAVE_ARRAYNESS();
            HALMAT_POP(g.XSFST, 0, g.XCO_N, g.FCN_LV);
            g.VAL_P[g.PTR_TOP] = g.LAST_POPp;
    elif PRODUCTION_NUMBER == 23:  # reference 230
        #  <ARITH CONV>  ::=  INTEGER
        g.FIXL[g.MP] = 3;
        SET_BI_XREF(g.INT_NDX);
    elif PRODUCTION_NUMBER == 24:  # reference 240
        #  <ARITH CONV>  ::=  SCALAR
        g.FIXL[g.MP] = 2;
        SET_BI_XREF(g.SCLR_NDX);
    elif PRODUCTION_NUMBER == 25:  # reference 250
        #  <ARITH CONV>  ::=  VECTOR
        g.FIXL[g.MP] = 1;
        SET_BI_XREF(g.VEC_NDX);
    elif PRODUCTION_NUMBER == 26:  # reference 260
        #  <ARITH CONV>  ::=  MATRIX
        g.FIXL[g.MP] = 0;
        SET_BI_XREF(g.MTX_NDX);
    elif PRODUCTION_NUMBER == 27:  # reference 270
        #  <PRIMARY> ::= <ARITH VAR>
        pass;
    elif PRODUCTION_NUMBER == 28:  # reference 280
        # <PRE PRIMARY>  ::=  <ARITH FUNC HEAD> ( <CALL LIST> )
        END_ANY_FCN();
    elif PRODUCTION_NUMBER == 29:  # reference 290
        #  <PRIMARY>  ::=  <MODIFIED ARITH FUNC>
        SETUP_NO_ARG_FCN(g.TEMP_SYN);
    # reference 300 has been relocated.
    elif PRODUCTION_NUMBER == 31:  # reference 310
        #  <PRIMARY> ::= <PRE PRIMARY>
        g.FIXF[g.MP] = 0;
    elif PRODUCTION_NUMBER == 32:  # reference 320
        #  <PRIMARY> ::= <PRE PRIMARY> <QUALIFIER>
        PREC_SCALE(g.SP, g.PSEUDO_TYPE[g.PTR[g.MP]]);
        g.PTR_TOP = g.PTR[g.MP];
        g.FIXF[g.MP] = 0;
    elif PRODUCTION_NUMBER == 33:  # reference 330
        #  <OTHER STATEMENT>  ::=  <ON PHRASE> <STATEMENT>
        HALMAT_POP(g.XLBL, 1, g.XCO_N, 0);
        HALMAT_PIP(g.FIXL[g.MP], g.XINL, 0, 0);
        g.INDENT_LEVEL = g.INDENT_LEVEL - g.INDENT_INCR;
        UNBRANCHABLE(g.SP, 7);
        g.FIXF[g.MP] = 0;
    elif PRODUCTION_NUMBER == 34:  # reference 340
        #  <OTHER STATEMENT> ::= <IF STATEMENT>
        g.FIXF[g.MP] = 0;
    # reference 350 has been relocated.
    elif PRODUCTION_NUMBER == 36:  # reference 360
        #  <STATEMENT> ::= <BASIC STATEMENT>
        CHECK_IMPLICIT_T();
        OUTPUT_WRITER(g.LAST_WRITE, g.STMT_END_PTR);
        # ONLY SET LAST_WRITE TO 0 WHEN STATEMENT STACK
        # COMPLETELY PRINTED.
        if g.STMT_END_PTR > -1:
            g.LAST_WRITE = g.STMT_END_PTR + 1;
        else:
            g.LAST_WRITE = 0;
        EMIT_SMRK();
    elif PRODUCTION_NUMBER == 37:  # reference 370
        #  <STATEMENT>  ::=  <OTHER STATEMENT>
        pass;
    elif PRODUCTION_NUMBER == 38:  # reference 380
        #  <ANY STATEMENT>  ::= <STATEMENT>
        g.PTR[g.MP] = 1;
    elif PRODUCTION_NUMBER == 39:  # reference 390
        # <ANY STATEMENT>::= <BLOCK DEFINITION>
        g.PTR[g.MP] = g.BLOCK_MODE[g.NEST + 1] = g.UPDATE_MODE;  # WHAT BLOCK WAS
    elif PRODUCTION_NUMBER == 40:  # reference 400
        #  <BASIC STATEMENT>  ::= <LABEL DEFINITION> <BASIC STATEMENT>
        goto = "LABEL_INCORP"
    elif PRODUCTION_NUMBER == 41:  # reference 410
        # <BASIC STATEMENT>::=<ASSIGNMENT>
        g.XSET(0x4);
        g.PTR_TOP = g.PTR_TOP - g.INX[g.PTR[g.MP]];
        if g.NAME_PSEUDOS: NAME_ARRAYNESS(g.MP);
        HALMAT_FIX_PIPp(g.LAST_POPp, g.INX[g.PTR[g.MP]]);
        EMIT_ARRAYNESS();
        goto = "FIX_NOLAB"
    # reference 420 has been relocated.
    elif PRODUCTION_NUMBER == 43:  # reference 430
        #  <BASIC STATEMENT>  ::=  EXIT  <LABEL>  ;
        SET_XREF(g.FIXL[g.MPP1], g.XREF_REF);
        goto = "EXITTING"
    # reference 440 has been relocated.
    elif PRODUCTION_NUMBER == 45:  # reference 450
        #  <BASIC STATEMENT>  ::=  REPEAT  <LABEL>  ;
        SET_XREF(g.FIXL[g.MPP1], g.XREF_REF);
        goto = "REPEATING"
    elif PRODUCTION_NUMBER == 46:  # reference 460
        #  <BASIC STATEMENT>  ::=  GO TO  <LABEL>  ;
        g.I = g.FIXL[g.MP + 2];
        SET_XREF(g.I, g.XREF_REF);
        if g.SYT_LINK1(g.I) < 0: 
            if g.DO_LEVEL < (-g.SYT_LINK1(g.I)): 
                ERROR(d.CLASS_GL, 3);
        elif g.SYT_LINK1(g.I) == 0: 
            g.SYT_LINK1(g.I, g.STMT_NUM());
        g.XSET(0x1001);
        if g.VAR_LENGTH(g.I) > 3: 
            ERROR(d.CLASS_GL, g.VAR_LENGTH(g.I));
        elif g.VAR_LENGTH(g.I) == 0: 
            g.VAR_LENGTH(g.I, 3);
        HALMAT_POP(g.XBRA, 1, 0, 0);
        HALMAT_PIP(g.I, g.XSYT, 0, 0);
        goto = "FIX_NOLAB"
    # reference 470 has been relocated.
    elif PRODUCTION_NUMBER == 48:  # reference 480
        # <BASIC STATEMENT>::= <CALL KEY> ;
        END_ANY_FCN();
    elif PRODUCTION_NUMBER == 49:  # reference 490
        # <BASIC STATEMENT>::= <CALL KEY> (<CALL LIST>) ;
        END_ANY_FCN();
    elif PRODUCTION_NUMBER == 50:  # reference 500
        # <BASIC STATEMENT>::=<CALL KEY><ASSIGN>(<CALL ASSIGN LIST>);
        END_ANY_FCN();
    elif PRODUCTION_NUMBER == 51:  # reference 510
        # <BASIC STATEMENT>::=<CALL KEY>(<CALL LIST>)<ASSIGN>(<CALL ASSIGN LIST>);
        END_ANY_FCN();
    elif PRODUCTION_NUMBER == 52:  # reference 520
        # <BASIC STATEMENT>::= RETURN ;
        if g.SYT_CLASS(g.BLOCK_SYTREF[g.NEST]) == g.FUNC_CLASS: 
            ERROR(d.CLASS_PF, 1);
        elif g.BLOCK_MODE[g.NEST] == g.UPDATE_MODE: 
            ERROR(d.CLASS_UP, 2);
        HALMAT_POP(g.XRTRN, 0, 0, 0);
        g.XSET(0x7);
        goto = "FIX_NOLAB"
    elif PRODUCTION_NUMBER == 53:  # reference 530
        # <BASIC STATEMENT>::= RETURN <EXPRESSION> ;
        g.XSET(0x7);
        g.TEMP = 0;
        if KILL_NAME(g.MPP1): 
            ERROR(d.CLASS_PF, 9);
        if CHECK_ARRAYNESS(): 
            ERROR(d.CLASS_PF, 3);
        if g.BLOCK_MODE[g.NEST] == g.UPDATE_MODE: 
            ERROR(d.CLASS_UP, 2);
        elif g.SYT_CLASS(g.BLOCK_SYTREF[g.NEST]) != g.FUNC_CLASS:
            ERROR(d.CLASS_PF, 2);
        else:
            g.PTR[0] = 0;
            g.LOC_P[0] = g.BLOCK_SYTREF[g.NEST];
            g.PSEUDO_LENGTH[0] = g.VAR_LENGTH(g.LOC_P[0]);
            g.TEMP = g.SYT_TYPE(g.BLOCK_SYTREF[g.NEST]);
            if (SHL(1, g.PSEUDO_TYPE[g.PTR[g.MPP1]]) & g.ASSIGN_TYPE[g.TEMP]) == 0:
                ERROR(d.CLASS_PF, 4);
        # DO CASE TEMP;
        if g.TEMP in (0, 1, 2):
            pass
        elif g.TEMP == 3:
            MATRIX_COMPARE(0, g.MPP1, d.CLASS_PF, 5);
        elif g.TEMP == 4:
            VECTOR_COMPARE(0, g.MPP1, d.CLASS_PF, 6);
        elif g.TEMP in (5, 6, 7, 8, 9):
            pass
        elif g.TEMP == 10:
            STRUCTURE_COMPARE(g.VAR_LENGTH(g.LOC_P[0]), g.FIXL[g.MPP1], d.CLASS_PF, 7);
        elif g.TEMP == 11:
            pass;
        HALMAT_TUPLE(g.XRTRN, 0, g.MPP1, 0, 0);
        HALMAT_FIX_PIPTAGS(g.NEXT_ATOMp - 1, g.PSEUDO_TYPE[g.PTR[g.MPP1]], 0);
        g.PTR_TOP = g.PTR[g.MPP1] - 1;
        goto = "FIX_NOLAB"
    elif PRODUCTION_NUMBER == 54:  # reference 540
        # <BASIC STATEMENT>::= <DO GROUP HEAD> <ENDING> ;
        g.XSET(0x8);
        g.INDENT_LEVEL = g.INDENT_LEVEL - g.INDENT_INCR;
        g.NEST_LEVEL = g.NEST_LEVEL - 1;
        # DO CASE DO_INX[DO_LEVEL]&0x7F;
        didl = g.DO_INX[g.DO_LEVEL] & 0x7F
        if didl == 0:
            # SIMPLE DO
            g.TEMP = g.QUALIFICATION;
        elif didl == 1:
            # DO FOR
            g.TEMP = g.QUALIFICATION;
        elif didl == 2:
            # DO CASE
            HALMAT_FIX_POPTAG(g.FIXV[g.MP], 1);
            g.TEMP = g.QUALIFICATION;
            g.INFORMATION = '';
            g.CASE_LEVEL = g.CASE_LEVEL - 1;
        elif didl == 3:
            # DO WHILE
            g.TEMP = g.XETST;
        # End of CASE DO_INX...
        HALMAT_POP(g.TEMP, 1, 0, 0);
        HALMAT_PIP(g.DO_LOC[g.DO_LEVEL], g.XINL, 0, 0);
        g.I = 0;
        while g.SYT_LINK2(g.I) > 0:
            g.J = g.SYT_LINK2(g.I);
            if g.SYT_LINK1(g.J) < 0: 
                if g.DO_LEVEL == (-g.SYT_LINK1(g.J)): 
                    g.SYT_LINK1(g.J, -(g.DO_LEVEL_LIM + 1));
                    g.SYT_LINK2(g.I, g.SYT_LINK2(g.J));
            g.I = g.J;
        if g.DO_LOC[0] == 0: 
            g.I = g.DO_CHAIN[g.DO_LEVEL];
            while g.I > 0:
                g.CLOSE_BCD = g.SYT_NAME(g.I);
                DISCONNECT(g.I);
                g.I = g.SYT_LINK1(g.I);
            g.DO_LEVEL = g.DO_LEVEL - 1;
        else:
            g.DO_LOC[0] = g.DO_LOC[0] - 1;
        goto = "FIX_NOLAB"
    # reference 550 has been relocated.
    elif PRODUCTION_NUMBER == 56:  # reference 560
        # <BASIC STATEMENT>::= <READ PHRASE> ;
        goto = "IO_EMIT"
    elif PRODUCTION_NUMBER == 57:  # reference 570
        # <BASIC STATEMENT>::= <WRITE KEY> ;
        goto = "IO_EMIT"
    elif PRODUCTION_NUMBER == 58:  # reference 580
    # <BASIC STATEMENT>::= <WRITE PHRASE> ;
        goto = "IO_EMIT"
    elif PRODUCTION_NUMBER == 59:  # reference 590
        # <BASIC STATEMENT>::= <FILE EXP> = <EXPRESSION> ;
        HALMAT_TUPLE(g.XFILE, 0, g.MP, g.SP - 1, g.FIXV[g.MP]);
        HALMAT_FIX_PIPTAGS(g.NEXT_ATOMp - 1, g.PSEUDO_TYPE[g.PTR[g.SP - 1]], 1);
        if KILL_NAME(g.SP - 1): 
            ERROR(d.CLASS_T, 5);
        EMIT_ARRAYNESS();
        g.PTR_TOP = g.PTR[g.MP] - 1;
        g.XSET(0x800);
        goto = "FIX_NOLAB"
    elif PRODUCTION_NUMBER == 60:  # reference 600
        # <BASIC STATEMENT>::= <VARIABLE> = <FILE EXP> ;
        HALMAT_TUPLE(g.XFILE, 0, g.SP - 1, g.MP, g.FIXV[g.SP - 1]);
        l.H1 = g.VAL_P[g.PTR[g.MP]];
        if SHR(l.H1, 7) & 1: 
            ERROR(d.CLASS_T, 4);
        if SHR(l.H1, 4) & 1: 
            ERROR(d.CLASS_T, 7);
        if (l.H1 & 0x6) == 0x2: 
            ERROR(d.CLASS_T, 8);
        HALMAT_FIX_PIPTAGS(g.NEXT_ATOMp - 1, g.PSEUDO_TYPE[g.PTR[g.MP]], 0);
        if KILL_NAME(g.MP): 
            ERROR(d.CLASS_T, 5);
        CHECK_ARRAYNESS();  # DR 173
        g.PTR_TOP = g.PTR[g.MP] - 1;
        goto = "FIX_NOLAB"
    # reference 610 has been relocated.
    # reference 620 has been relocated.
    elif PRODUCTION_NUMBER == 63:  # reference 630
        #  <BASIC STATEMENT> ::=  <WAIT KEY> UNTIL <ARITH EXP> ;
        g.TEMP = 2;
        if UNARRAYED_SCALAR(g.SP - 1): 
            ERROR(d.CLASS_RT, 6, 'WAIT UNTIL');
        goto = "WAIT_TIME";
    elif PRODUCTION_NUMBER == 64:  # reference 640
        # <BASIC STATEMENT>::= <WAIT KEY> FOR <BIT EXP> ;
        g.TEMP = 3;
        if CHECK_EVENT_EXP(g.SP - 1): ERROR(d.CLASS_RT, 6, 'WAIT FOR');
        goto = "WAIT_TIME"
    elif PRODUCTION_NUMBER == 65:  # reference 650
        # <BASIC STATEMENT>::= <TERMINATOR> ;
        g.XSET(0xA);
        HALMAT_POP(g.FIXL[g.MP], 0, 0, 0);
        goto = "UPDATE_CHECK"
    elif PRODUCTION_NUMBER == 66:  # reference 660
        # <BASIC STATEMENT>::= <TERMINATOR> <TERMINATE LIST>;
        g.XSET(0xA);
        HALMAT_POP(g.FIXL[g.MP], g.EXT_P[g.PTR[g.MPP1]], 0, 1);
        for l.H1 in range(g.PTR[g.MPP1], 1 + g.EXT_P[g.PTR[g.MPP1]] + g.PTR[g.MPP1] - 1):
            HALMAT_PIP(g.LOC_P[l.H1], g.PSEUDO_FORM[l.H1], 0, 0);
        g.PTR_TOP = g.PTR[g.MPP1] - 1;
        goto = "UPDATE_CHECK"
    # "reference 670" has been relocated.
    elif PRODUCTION_NUMBER == 68:  # reference 680
        #  <BASIC STATEMENT>  ::=  UPDATE PRIORITY  <LABEL VAR>  TO  <ARITH EXP>;
        SET_XREF_RORS(g.MP + 2, 0xC000);
        PROCESS_CHECK(g.MP + 2);
        g.TEMP = g.MP + 2;
        g.PTR_TOP = g.PTR[g.TEMP] - 1;
        goto = "UP_PRIO"
    # reference 690 has been relocated.
    elif PRODUCTION_NUMBER == 70:  # reference 700
        # <BASIC STATEMENT>::=<SCHEDULE PHRASE><SCHEDULE CONTROL>;
        goto = "SCHEDULE_EMIT";
    elif PRODUCTION_NUMBER == 71:  # reference 710
        #  <BASIC  STATEMENT>  ::=  <SIGNAL CLAUSE>  ;
        g.XSET(0xD);
        HALMAT_TUPLE(g.XSGNL, 0, g.MP, 0, g.INX[g.PTR[g.MP]]);
        g.PTR_TOP = g.PTR[g.MP] - 1;
        goto = "FIX_NOLAB"
    elif PRODUCTION_NUMBER == 72:  # reference 720
        #  <BASIC STATEMENT>  ::=  SEND ERROR <SUBSCRIPT>  ;
        ERROR_SUB(2);
        HALMAT_TUPLE(g.XERSE, 0, g.MP + 2, 0, 0, g.FIXV[g.MP] & 0x3F);
        SET_OUTER_REF(g.FIXV[g.MP], 0x0000);
        g.PTR_TOP = g.PTR[g.MP + 2] - 1;
        goto = "FIX_NOLAB"
    elif PRODUCTION_NUMBER == 73:  # reference 730
        #  <BASIC STATEMENT>  ::=  <ON CLAUSE>  ;
        HALMAT_TUPLE(g.XERON, 0, g.MP, 0, g.FIXL[g.MP], g.FIXV[g.MP] & 0x3F);
        g.PTR_TOP = g.PTR[g.MP] - 1;
        goto = "FIX_NOLAB"
    elif PRODUCTION_NUMBER == 74:  # reference 740
        #  <BASIC STATEMENT>  ::=  <ON CLAUSE> AND <SIGNAL CLAUSE> ;
        HALMAT_TUPLE(g.XERON, 0, g.MP, g.MP + 2, g.FIXL[g.MP], g.FIXV[g.MP] & 0x3F, 0, 0, g.INX[g.PTR[g.MP + 2]]);
        g.PTR_TOP = g.PTR[g.MP] - 1;
        goto = "FIX_NOLAB"
    elif PRODUCTION_NUMBER == 75:  # reference 750
        #  <BASIC STATEMENT>  ::=  OFF ERROR <SUBSCRIPT>  ;
        ERROR_SUB(0);
        HALMAT_TUPLE(g.XERON, 0, g.MP + 2, 0, 3, g.FIXV[g.MP] & 0x3F);
        g.PTR_TOP = g.PTR[g.MP + 2] - 1;
        goto = "FIX_NOLAB"
    elif PRODUCTION_NUMBER == 76:  # reference 760
        #  <BASIC STATEMENT>  ::=  <% MACRO NAME> ;
        HALMAT_POP(g.XPMHD, 0, 0, g.FIXL[g.MP]);
        HALMAT_POP(g.XPMIN, 0, 0, g.FIXL[g.MP]);
        g.XSET (g.PC_STMT_TYPE_BASE + g.FIXL[g.MP]);
        if g.PCARGp[g.FIXL[g.MP]] != 0:
            if g.ALT_PCARGp[g.FIXL[g.MP]] != 0:
                ERROR(d.CLASS_XM, 2, g.VAR[g.MP]);
        goto = "FIX_NOLAB"
    elif PRODUCTION_NUMBER == 77:  # reference 770
        #  <BASIC STATEMENT>  ::=  <% MACRO HEAD> <% MACRO ARG> ) ;
        if g.PCARGp[0] != 0:
            if g.ALT_PCARGp[0] != 0:
                ERROR(d.CLASS_XM, 2, g.VAR[g.MP]);
        HALMAT_TUPLE(g.XPMAR, 0, g.MPP1, 0, 0, g.PSEUDO_TYPE[g.PTR[g.MPP1]]);
        g.PTR_TOP = g.PTR[g.MPP1] - 1;
        g.DELAY_CONTEXT_CHECK = g.FALSE;
        HALMAT_POP(g.XPMIN, 0, 0, g.FIXL[g.MP]);
        g.ASSIGN_ARG_LIST = g.FALSE;  # RESTORE LOCK GROUP CHECKING
        
        # RESET PCARGOFF HERE SO THAT IT CAN BE USED
        # TO DETERMINE WHETHER PERCENT MACRO ARGUMENT
        # PROCESSING IS HAPPENING.
        g.PCARGOFF[0] = 0;
        goto = "FIX_NOLAB"
    elif PRODUCTION_NUMBER == 78:  # reference 780
        #  <% MACRO HEAD>  ::=  <% MACRO NAME> (
        if g.FIXL[g.MP] == 0: 
            g.ALT_PCARGp[0] = 0
            g.PCARGp[0] = 0
            g.PCARGOFF[0] = 0;
        else:
            g.PCARGp[0] = g.PCARGp[g.FIXL[g.MP]];
            g.PCARGOFF[0] = g.PCARGOFF[g.FIXL[g.MP]];
            
            # CHECK PCARGBITS OF THE %MACRO ARGUMENT TO
            # SEE IF IT REQUIRES NAME CONTEXT CHECKING.
            # IF SO, SET NAMING FLAG.
            if ((g.PCARGBITS[g.PCARGOFF[0]] & 0x80) != 0):
                g.NAMING = g.TRUE;
            
            g.ALT_PCARGp[0] = g.ALT_PCARGp[g.FIXL[g.MP]];
        g.XSET (g.PC_STMT_TYPE_BASE + g.FIXL[g.MP]);
        HALMAT_POP(g.XPMHD, 0, 0, g.FIXL[g.MP]);
        g.DELAY_CONTEXT_CHECK = g.TRUE;
        if g.FIXL[g.MP] == g.PCCOPY_INDEX:
            g.ASSIGN_ARG_LIST = g.TRUE;  # INHIBIT LOCK CHECK IN ASSOCIATE
    elif PRODUCTION_NUMBER == 79:  # reference 790
        #  <% MACRO HEAD>  ::=  <% MACRO HEAD> <% MACRO ARG> ,
        HALMAT_TUPLE(g.XPMAR, 0, g.MPP1, 0, 0, g.PSEUDO_TYPE[g.PTR[g.MPP1]]);
        g.PTR_TOP = g.PTR[g.MPP1] - 1;
    elif PRODUCTION_NUMBER == 80:  # reference 800
        #  <% MACRO ARG>  ::=  <NAME VAR>
        if g.PCARGOFF[0] > 0:
            if g.PCARGp[0] == 0: 
                g.PCARGOFF[0] = 0;
            else:
                g.TEMP = g.PCARGBITS[g.PCARGOFF[0]];
                if (g.TEMP & 0x1) == 0: 
                    ERROR(d.CLASS_XM, 5);
                else:
                    l.H1 = g.PSEUDO_TYPE[g.PTR[g.MP]];
                    if l.H1 > 0x40: 
                        l.H1 = (l.H1 & 0xF) + 10;
                    elif g.TEMP_SYN == 0: 
                        l.H1 = l.H1 + 20;
                    if (SHL(1, l.H1) & g.PCARGTYPE[g.PCARGOFF[0]]) == 0:
                        ERROR(d.CLASS_XM, 4);  # ILLEGAL TYPE
                    if g.EXT_P[g.PTR[g.MP]] > 0: 
                        if SHR(g.TEMP, 6) & 1:
                            ERROR(d.CLASS_XM, 10);  # NO NAME COPINESS
                    RESET_ARRAYNESS();
                    if CHECK_ARRAYNESS(): 
                        if SHR(g.TEMP, 5) & 1:
                            ERROR(d.CLASS_XM, 7);  # NO ARRAYNESS
                    if SHR(g.TEMP, 4) & 1: 
                        if g.TEMP_SYN != 2: 
                            g.TEMP_SYN = 3;
                    if SHR(g.TEMP, 7) & 1: 
                        CHECK_NAMING(g.TEMP_SYN, g.MP);
                    else:
                        if SHR(g.TEMP, 4) & 1: 
                            CHECK_ASSIGN_CONTEXT(g.MP);
                        else:
                            SET_XREF_RORS(g.MP);
                        if g.FIXV[g.MP] > 0: 
                            l.H2 = g.FIXV[g.MP];
                        else:
                            l.H2 = g.FIXL[g.MP];
                        if (g.SYT_FLAGS(l.H2) & (g.TEMPORARY_FLAG)) != 0:
                            if SHR(g.TEMP, 8) & 1: 
                                ERROR(d.CLASS_XM, 8);
                        l.H2 = g.VAL_P[g.PTR[g.MP]];
                        # NO SUBSCRIPTS ARE ALLOWED ON THE SOURCE OF %NAMEBIAS
                        if g.PCARGOFF[0] == 2:
                            if SHR(g.TEMP, 2) & 1:
                                if SHR(l.H2, 5) & 1: 
                                    ERROR(d.CLASS_XM, 9);
                        elif SHR(g.TEMP, 2) & 1:
                            if SHR(l.H2, 4) & 1: 
                                ERROR(d.CLASS_XM, 9);
                g.PCARGOFF[0] = g.PCARGOFF[0] + 1;
                
                # CHECK PCARGBITS OF THE %MACRO ARGUMENT TO
                # SEE IF IT REQUIRES NAME CONTEXT CHECKING.
                # IF SO, SET NAMING FLAG.
                if ((g.PCARGBITS[g.PCARGOFF[0]] & 0x80) != 0):
                   g.NAMING = g.TRUE;
                
            g.PCARGp[0] = g.PCARGp[0] - 1;
            g.ALT_PCARGp[0] = g.ALT_PCARGp[0] - 1;
    elif PRODUCTION_NUMBER == 81:  # reference 810
        #  <% MACRO ARG>  ::=  <CONSTANT>
        if g.PCARGOFF[0] > 0: 
            if g.PCARGp[0] == 0: 
                g.PCARGOFF[0] = 0;
            elif (g.PCARGBITS[g.PCARGOFF[0]] & 0x8) == 0: 
                ERROR(d.CLASS_XM, 3);
            # LITERALS ILLEGAL
            elif (SHL(1, g.PSEUDO_TYPE[g.PTR[g.MP]]) & g.PCARGTYPE[g.PCARGOFF[0]]) == 0:
                ERROR(d.CLASS_XM, 4);  #  TYPE ILLEGAL
            g.PCARGOFF[0] = g.PCARGOFF[0] + 1;
        g.PCARGp[0] = g.PCARGp[0] - 1;
        g.ALT_PCARGp[0] = g.ALT_PCARGp[0] - 1;
    # reference 820 has been relocated.
    # reference 830 has been relocated.
    elif PRODUCTION_NUMBER == 84:  # reference 840
        #  <BIT PRIM>  ::=  <EVENT VAR>
        SET_XREF_RORS(g.MP);
        g.INX[g.PTR[g.MP]] = g.REFER_LOC > 0;
        goto = "YES_EVENT"
    elif PRODUCTION_NUMBER == 85:  # reference 850
        #  <BIT PRIM>  ::=  <BIT CONST>
        goto = "NON_EVENT"
    elif PRODUCTION_NUMBER == 86:  # reference 860
        #  <BIT PRIM>  ::=  (  <BIT EXP>  )
        g.PTR[g.MP] = g.PTR[g.MPP1];
    elif PRODUCTION_NUMBER == 87:  # reference 870
        #  <BIT PRIM>  ::=  <MODIFIED BIT FUNC>
        SETUP_NO_ARG_FCN();
        goto = "NON_EVENT"
    elif PRODUCTION_NUMBER == 88:  # reference 880
        #  <BIT PRIM>  ::=  <BIT INLINE DEF> <BLOCK BODY> <CLOSING>  ;
        goto = "INLINE_SCOPE"
    elif PRODUCTION_NUMBER == 89:  # reference 890
        #  <BIT PRIM>  ::=  <SUBBIT HEAD>  <EXPRESSION>  )
        END_SUBBIT_FCN;
        SET_BI_XREF(SBIT_NDX);
        goto = "NON_EVENT"
    elif PRODUCTION_NUMBER == 90:  # reference 900
        #  <BIT PRIM>  ::=  <BIT FUNC HEAD>  (  <CALL LIST>  )
        END_ANY_FCN();
        goto = "NON_EVENT"
    elif PRODUCTION_NUMBER == 91:  # reference 910
        #  <BIT FUNC HEAD>  ::= <BIT FUNC>
        if START_NORMAL_FCN(): 
            ASSOCIATE();
    elif PRODUCTION_NUMBER == 92:  # reference 920
        #  <BIT FUNC HEAD>  ::=  BIT  <SUB OR QUALIFIER>
        g.NOSPACE();
        g.PTR[g.MP] = g.PTR[g.SP];
        g.PSEUDO_TYPE[g.PTR[g.MP]] = g.BIT_TYPE;
        g.VAR[g.MP] = 'BIT CONVERSION FUNCTION';
        if PUSH_FCN_STACK(3): 
            g.FCN_LOC[g.FCN_LV] = 1;
        SET_BI_XREF(g.BIT_NDX);
    elif PRODUCTION_NUMBER == 93:  # reference 930
        #  <BIT CAT> ::= <BIT PRIM>
        pass;
    # reference 940 relocated.
    elif PRODUCTION_NUMBER == 95:  # reference 950
        # <BIT CAT> ::= <NOT> <BIT PRIM>
        if BIT_LITERAL(g.SP, 0): 
            g.TEMP = g.PSEUDO_LENGTH[g.PTR[g.SP]];
            g.TEMP2 = SHL(g.FIXV[g.SP], HOST_BIT_LENGTH_LIM - g.TEMP);
            g.TEMP2 = not g.TEMP2;
            g.TEMP2 = SHR(g.TEMP2, HOST_BIT_LENGTH_LIM - g.TEMP);
            g.LOC_P[g.PTR[g.SP]] = SAVE_LITERAL(2, g.TEMP2, g.TEMP);
        else:
            HALMAT_TUPLE(g.XBNOT, 0, g.SP, 0, g.INX[g.PTR[g.SP]]);
            SETUP_VAC(g.SP, g.BIT_TYPE);
        g.INX[g.PTR[g.SP]] = g.INX[g.PTR[g.SP]] & 1;
        g.PTR[g.MP] = g.PTR[g.SP];
    elif PRODUCTION_NUMBER == 96:  # reference 960
        # <BIT CAT> ::= <BIT CAT> <CAT> <NOT> <BIT PRIM>
        HALMAT_TUPLE(g.XBNOT, 0, g.SP, 0, 0);
        SETUP_VAC(g.SP, g.BIT_TYPE);
        goto = "DO_BIT_CAT";
    elif PRODUCTION_NUMBER == 97:  # reference 970
        #  <BIT FACTOR> ::= <BIT CAT>
        pass;
    # reference 980 has been relocated.
    elif PRODUCTION_NUMBER == 99:  # reference 990
        #  <BIT EXP> ::= <BIT FACTOR>
        pass;
    elif PRODUCTION_NUMBER == 100:  # reference 1000
        #   <BIT EXP> ::= <BIT EXP> <OR> <BIT FACTOR>
        if BIT_LITERAL(g.MP, g.SP): 
            g.TEMP = g.FIXV[g.MP] | g.FIXV[g.SP];
            goto = "DO_LIT_BIT_FACTOR"
        else:
            g.TEMP = XBOR;
            goto = "DO_BIT_FACTOR"
    elif PRODUCTION_NUMBER == 101:  # reference 1010
        #  <RELATIONAL OP> ::= =
        g.REL_OP = 0 ;
    elif PRODUCTION_NUMBER == 102:  # reference 1020
        # <RELATIONAL OP> ::= <NOT> =
        g.REL_OP = 1 ;
    elif PRODUCTION_NUMBER == 103:  # reference 1030
        #  <RELATIONAL OP> ::= <
        g.REL_OP = 2 ;
    elif PRODUCTION_NUMBER == 104:  # reference 1040
        #  <RELATIONAL OP> ::= >
        g.REL_OP = 3 ;
    elif PRODUCTION_NUMBER == 105:  # reference 1050
        # <RELATIONAL OP> ::= <  =
        g.NOSPACE();
        g.REL_OP = 4 ;
    elif PRODUCTION_NUMBER == 106:  # reference 1060
        # <RELATIONAL OP> ::= >  =
        g.NOSPACE();
        g.REL_OP = 5 ;
    elif PRODUCTION_NUMBER == 107:  # reference 1070
        # <RELATIONAL OP> ::= <NOT> <
        g.REL_OP = 5 ;
    elif PRODUCTION_NUMBER == 108:  # reference 1080
        # <RELATIONAL OP> ::= <NOT> >
        g.REL_OP = 4 ;
    # reference 1090 relocated.
    elif PRODUCTION_NUMBER == 110:  # reference 1100
        # <COMPARISON> ::= <CHAR EXP> <RELATIONAL OP> <CHAR EXP>
        g.TEMP = g.XCEQU[g.REL_OP];
        g.VAR[g.MP] = '';
        goto = "EMIT_REL";
    elif PRODUCTION_NUMBER == 111:  # reference 1110
        # <COMAPRISON> ::= <BIT CAT> <RELATIONAL OP> <BIT CAT>
        g.TEMP = g.XBEQU[g.REL_OP];
        g.VAR[g.MP] = 'BIT';
        goto = "EMIT_REL";
    elif PRODUCTION_NUMBER == 112:  # reference 1120
        #  <COMPARISON>  ::=  <STRUCTURE EXP> <RELATIONAL OP> <STRUCTURE EXP>
        g.TEMP = g.XTEQU[g.REL_OP];
        g.VAR[g.MP] = 'STRUCTURE';
        STRUCTURE_COMPARE(g.FIXL[g.MP], g.FIXL[g.SP], d.CLASS_C, 3);
        goto = "EMIT_REL";
    elif PRODUCTION_NUMBER == 113:  # reference 1130
        #  <COMPARISON>  ::=  <NAME EXP>  <RELATIONAL OP>  <NAME EXP>
        NAME_COMPARE(g.MP, g.SP, d.CLASS_C, 4);
        g.TEMP = g.XNEQU[g.REL_OP];
        g.VAR[g.MP] = 'NAME';
        if COPINESS(g.MP, g.SP): 
            ERROR(d.CLASS_EA, 1, g.VAR[g.SP]);
        NAME_ARRAYNESS(g.SP);
        goto = "EMIT_REL";
    elif PRODUCTION_NUMBER == 114:  # reference 1140
        #  <RELATIONAL FACTOR>  ::=  <REL PRIM>
        pass;
    elif PRODUCTION_NUMBER == 115:  # reference 1150
        # <RELATIONAL FACTOR> ::= <RELATIONAL FACTOR> <AND> <REL PRIM>
        HALMAT_TUPLE(g.XCAND, g.XCO_N, g.MP, g.SP, 0);
        SETUP_VAC(g.MP, 0);
        g.PTR_TOP = g.PTR[g.MP];
    elif PRODUCTION_NUMBER == 116:  # reference 1160
        # <RELATIONAL EXP> ::= <RELATIONAL FACTOR>
        pass;
    elif PRODUCTION_NUMBER == 117:  # reference 1170
        # <RELATIONAL EXP> ::= < RELATIONAL EXP> <OR> < RELATIONAL FACTOR>
        HALMAT_TUPLE(g.XCOR, g.XCO_N, g.MP, g.SP, 0);
        SETUP_VAC(g.MP, 0);
        g.PTR_TOP = g.PTR[g.MP];
    elif PRODUCTION_NUMBER == 118:  # reference 1180
        # <REL PRIM> ::= (1 <RELATIONAL EXP> )
        g.PTR[g.MP] = g.PTR[g.MPP1] ;  # MOVE INDIRECT STACKS
    elif PRODUCTION_NUMBER == 119:  # reference 1190
        # <REL PRIM> ::= <NOT> (1 <RELATIONAL EXP> )
        HALMAT_TUPLE(g.XCNOT, g.XCO_N, g.MP + 2, 0, 0);
        g.PTR[g.MP] = g.PTR[g.MP + 2];
        SETUP_VAC(g.MP, 0);
    elif PRODUCTION_NUMBER == 120:  # reference 1200
        # <REL PRIM> ::=  <COMPARISON>
        if g.REL_OP > 1:
            if LENGTH(g.VAR[g.MP]) > 0: 
                ERROR(d.CLASS_C, 1, g.VAR[g.MP]);
            elif CHECK_ARRAYNESS(): 
                ERROR(d.CLASS_C, 2);
            CHECK_ARRAYNESS();
        SETUP_VAC(g.MP, 0);
        g.PTR_TOP = g.PTR[g.MP];
        EMIT_ARRAYNESS();
    elif PRODUCTION_NUMBER == 121:  # reference 1210
        #  <CHAR PRIM> ::= <CHAR VAR>
        SET_XREF_RORS(g.MP);  # SET XREF FLAG TO SUBSCR OR REF
    elif PRODUCTION_NUMBER == 122:  # reference 1220
        #  <CHAR PRIM>  ::=  <CHAR CONST>
        pass;
    elif PRODUCTION_NUMBER == 123:  # reference 1230
        #  <CHAR PRIM>  ::=  <MODIFIED CHAR FUNC>
        SETUP_NO_ARG_FCN();
    elif PRODUCTION_NUMBER == 124:  # reference 1240
        #  <CHAR PRIM>  ::=  <CHAR INLINE DEF> <BLOCK BODY> <CLOSING>  ;
        goto = "INLINE_SCOPE"
    elif PRODUCTION_NUMBER == 125:  # reference 1250
        #  <CHAR PRIM>  ::=  <CHAR FUNC HEAD>  (  <CALL LIST>  )
        END_ANY_FCN();
    elif PRODUCTION_NUMBER == 126:  # reference 1260
        #  <CHAR PRIM>  ::=  (  <CHAR EXP>  )
        g.PTR[g.MP] = g.PTR[g.MPP1];
    elif PRODUCTION_NUMBER == 127:  # reference 1270
        #  <CHAR FUNC HEAD>  ::=  <CHAR FUNC>
        if START_NORMAL_FCN(): 
            ASSOCIATE();
    elif PRODUCTION_NUMBER == 128:  # reference 1280
        #  <CHAR FUNC HEAD>  ::=  CHARACTER  <SUB OR QUALIFIER>
        g.NOSPACE();
        g.PTR[g.MP] = g.PTR[g.SP];
        g.PSEUDO_TYPE[g.PTR[g.MP]] = g.CHAR_TYPE;
        g.VAR[g.MP] = 'CHARACTER CONVERSION FUNCTION';
        if PUSH_FCN_STACK(3): 
            g.FCN_LOC[g.FCN_LV] = 0;
        SET_BI_XREF(g.CHAR_NDX);
    elif PRODUCTION_NUMBER == 129:  # reference 1290
        #  <SUB OR QUALIFIER>  ::=  <SUBSCRIPT>
        g.TEMP = g.PTR[g.MP];
        g.LOC_P[g.TEMP] = 0;
        if g.PSEUDO_FORM[g.TEMP] != 0: 
            g.PSEUDO_FORM[g.TEMP] = 0;
            ERROR(d.CLASS_QS, 9);
        if g.INX[g.TEMP] > 0: 
           if (g.PSEUDO_LENGTH[g.TEMP] >= 0) or (g.VAL_P[g.TEMP] >= 0):
               ERROR(d.CLASS_QS, 1);
           if g.INX[g.TEMP] != 1:
               g.INX[g.TEMP] = 1;
               ERROR(d.CLASS_QS, 10);
    elif PRODUCTION_NUMBER == 130:  # reference 1300
        #  <SUB OR QUALIFIER>  ::=  <BIT QUALIFIER>
        g.INX[g.PTR[g.MP]] = 0;
    elif PRODUCTION_NUMBER == 131:  # reference 1310
        #  <CHAR EXP> ::= <CHAR PRIM>
        pass;
    # reference 1320 relocated.
    elif PRODUCTION_NUMBER == 133:  # reference 1330
        # <CHAR EXP> ::= <CHAR EXP> <CAT> <ARITH EXP>
        ARITH_TO_CHAR(g.SP) ;
        goto = "DO_CHAR_CAT" ;
    elif PRODUCTION_NUMBER == 134:  # reference 1340
        #  <CHAR EXP>  ::=  <ARITH EXP>  <CAT>  <ARITH EXP>
        ARITH_TO_CHAR(g.SP);
        ARITH_TO_CHAR(g.MP);
        goto = "DO_CHAR_CAT";
    elif PRODUCTION_NUMBER == 135:  # reference 1350
        # <CHAR EXP> ::= <ARITH EXP> <CAT> <CHAR PRIM>
        ARITH_TO_CHAR(g.MP) ;
        goto = "DO_CHAR_CAT" ;
    # reference 1360 has been relocated.
    elif PRODUCTION_NUMBER == 137:  # reference 1370
        # <ASSIGNMENT>::=<VARIABLE>,<ASSIGNMENT>
        HALMAT_PIP(g.LOC_P[g.PTR[g.MP]], g.PSEUDO_FORM[g.PTR[g.MP]], 0, 0);
        g.INX[g.PTR[g.SP]] = g.INX[g.PTR[g.SP]] + 1;
        if g.NAME_PSEUDOS: 
            NAME_COMPARE(g.MP, g.SP, d.CLASS_AV, 5, 0);
            if COPINESS(g.MP, g.SP) > 0: 
                ERROR(d.CLASS_AA, 2, g.VAR[g.MP]);
            goto = "END_ASSIGN"
        else:
            goto = "ASSIGNING"
    # reference 1380 relocated.
    elif PRODUCTION_NUMBER == 139:  # reference 1390
        # <IF STATEMENT>::=<TRUE PART> <STATEMENT>
        UNBRANCHABLE(g.SP, 5);
        goto = "CLOSE_IF"
    elif PRODUCTION_NUMBER == 140:  # reference 1400
        # <TRUE PART>::=<IF CLAUSE><BASIC STATEMENT> ELSE
        UNBRANCHABLE(g.MPP1, 4);
        CHECK_IMPLICIT_T();
        g.ELSEIF_PTR = g.STACK_PTR[g.SP];
        # MOVE ELSEIF_PTR TO FIRST PRINTABLE REPLACE MACRO TOKEN
        g.I = g.ELSEIF_PTR;
        while (g.I > 0) and ((g.GRAMMAR_FLAGS(g.I - 1) & g.MACRO_ARG_FLAG) != 0):
           g.I = g.I - 1;
           if ((g.GRAMMAR_FLAGS(g.I) & g.PRINT_FLAG) != 0):
                g.ELSEIF_PTR = g.I;
        if g.ELSEIF_PTR > 0:
            if g.STMT_END_PTR > -1:
                g.SQUEEZING = g.FALSE;
                OUTPUT_WRITER(g.LAST_WRITE, g.ELSEIF_PTR - 1);
                g.LAST_WRITE = g.ELSEIF_PTR;
        # ALIGN ELSE CORRECTLY.
        if g.MOVE_ELSE:
            g.INDENT_LEVEL = g.INDENT_LEVEL - g.INDENT_INCR;
        g.MOVE_ELSE = g.TRUE;
        EMIT_SMRK();
        SRN_UPDATE();
        # PUT THE ELSE ON THE SAME LINE AS THE DO.
        g.ELSE_FLAG = g.TRUE;
        # DETERMINES IF ELSE WAS ALREADY PRINTED IN REPLACE MACRO-11342
        if (g.GRAMMAR_FLAGS(g.ELSEIF_PTR) & g.PRINT_FLAG) == 0:
            g.ELSE_FLAG = g.FALSE;
        if g.NO_LOOK_AHEAD_DONE: 
            CALL_SCAN();
        if g.TOKEN != g.IF_TOKEN: 
            #  PRINT ELSE STATEMENTS ON SAME LINE AS A
            # SIMPLE DO.  IF ELSE_FLAG IS FALSE, THEN THE ELSE STATEMENT
            # WAS ALREADY PRINTED.
            if not g.ELSE_FLAG:
                g.INDENT_LEVEL = g.INDENT_LEVEL + g.INDENT_INCR;
            else:
                # DO NOT OUTPUT_WRITER.  SAVE VALUES
                # THAT ARE NEEDED WHEN OUTPUT_WRITER WILL BE CALLED.
                g.SAVE_SRN1 = g.SRN[2][:];
                g.SAVE_SRN_COUNT1 = g.SRN_COUNT[2];
                g.SAVE1 = g.ELSEIF_PTR;
                g.SAVE2 = g.STACK_PTR[g.SP];
        else:
            # IF ELSE_FLAG IS FALSE, THEN THE ELSE STATEMENT
            # WAS ALREADY PRINTED FROM PRINT_COMMENT AND INDENT_LEVEL
            # SHOULD BE SET TO INDENT THE LINE FOLLOWING THE COMMENT
            # OR DIRECTIVE.
            if not g.ELSE_FLAG:
                g.INDENT_LEVEL = g.INDENT_LEVEL + g.INDENT_INCR;
            g.ELSE_FLAG = g.FALSE;
            g.LAST_WRITE = g.ELSEIF_PTR;
        HALMAT_POP(g.XBRA, 1, 0, 1);
        HALMAT_PIP(g.FL_NO(), g.XINL, 0, 0);
        HALMAT_POP(g.XLBL, 1, g.XCO_N, 0);
        HALMAT_PIP(g.FIXV[g.MP], g.XINL, 0, 0);
        g.FIXV[g.MP] = g.FL_NO();
        g.XSET(0x100);
        g.FL_NO(g.FL_NO() + 1);
    # reference 1410 relocated.
    elif PRODUCTION_NUMBER == 142:  # reference 1420
        #  <IF CLAUSE>  ::=  <IF> <BIT EXP> THEN
        HALMAT_TUPLE(g.XBTRU, 0, g.MPP1, 0, 0);
        if g.PSEUDO_LENGTH[g.PTR[g.MPP1]] > 1: 
            ERROR(d.CLASS_GB, 1, 'IF');
        g.TEMP = g.LAST_POPp;
        EMIT_ARRAYNESS();
        goto = "EMIT_IF"
    elif PRODUCTION_NUMBER == 143:  # reference 1430
        #  <IF>  ::=  IF
        g.XSET(0x5);
        g.FIXL[g.MP] = g.INDENT_LEVEL;
        HALMAT_POP(g.XIFHD, 0, g.XCO_N, 0);
    # reference 1440 relocated
    elif PRODUCTION_NUMBER == 145:  # reference 1450
        # <DO GROUP HEAD>::= DO <FOR LIST> ;
        g.XSET(0x13);
        HALMAT_FIX_POPTAG(g.FIXV[g.MPP1], g.PTR[g.MPP1]);
        goto = "DO_DONE"
    # reference 1460 relocated
    elif PRODUCTION_NUMBER == 147:  # reference 1470
        # <DO GROUP HEAD>::= DO <WHILE CLAUSE> ;
        g.XSET(0x12);
        g.FIXL[g.MPP1] = 0;
        g.TEMP = g.PTR[g.MPP1];
        HALMAT_POP(g.XCTST, 1, 0, g.INX[g.TEMP]);
        goto = "EMIT_WHILE"
    # reference 1480 relocated
    # reference 1490 relocated
    # reference 1500 relocated
    elif PRODUCTION_NUMBER == 151:  # reference 1510
        #  <DO GROUP HEAD>  ::=  <DO GROUP HEAD>  <TEMPORARY STMT>
        if (g.DO_INX[g.DO_LEVEL] & 0x7F) == 2: 
            ERROR(d.CLASS_D, 10);
        elif g.FIXV[g.MP]:
            ERROR(d.CLASS_D, 7);
            g.FIXV[g.MP] = 0;
        goto = "EMIT_NULL";
    elif PRODUCTION_NUMBER == 152:  # reference 1520
        #  <CASE ELSE>  ::=  DO CASE <ARITH EXP> ; ELSE
        g.FIXL[g.MP] = 1;
        goto = "CASE_HEAD"
    # reference 1530 relocated.
    elif PRODUCTION_NUMBER == 154:  # reference 1540
        # <WHILE KEY>::= UNTIL
        g.TEMP = 1;
        goto = "WHILE_KEY"
    # reference 1550 relocated.
    elif PRODUCTION_NUMBER == 156:  # reference 1560
        # <WHILE CLAUSE>::= <WHILE KEY> <RELATIONAL EXP>
        goto = "DO_FLOWSET"
    elif PRODUCTION_NUMBER == 157:  # reference 1570
        # <FOR LIST>::= <FOR KEY>  <ARITH EXP><ITERATION CONTROL>
        if UNARRAYED_SIMPLE(g.SP - 1): 
            ERROR(d.CLASS_GC, 3);
        HALMAT_POP(g.XDFOR, g.TEMP2 + 3, g.XCO_N, 0);
        EMIT_PUSH_DO(1, 5, g.PSEUDO_TYPE[g.PTR[g.SP]] == g.INT_TYPE, g.MP - 2, g.FIXL[g.MP]);
        g.TEMP = g.PTR[g.MP];
        while g.TEMP <= g.PTR_TOP:
            HALMAT_PIP(g.LOC_P[g.TEMP], g.PSEUDO_FORM[g.TEMP], 0, 0);
            g.TEMP = g.TEMP + 1;
        g.FIXV[g.MP] = g.LAST_POPp;
        g.PTR_TOP = g.PTR[g.MP] - 1;
        g.PTR[g.MP] = g.TEMP2 | g.FIXF[g.MP];   ''' RECORD DO TYPE AND WHETHER
                                                    LOOP VAR IS TEMPORARY '''
    elif PRODUCTION_NUMBER == 158:  # reference 1580
        # <FOR LIST> = <FOR KEY>  <ITERATION BODY>
        HALMAT_FIX_POPTAG(g.FIXV[g.SP], 1);
        g.PTR_TOP = g.PTR[g.MP] - 1;
        g.PTR[g.MP] = g.FIXF[g.MP];  # RECORD WHETHER LOOP VAR IS TEMPORARY
    elif PRODUCTION_NUMBER == 159:  # reference 1590
        # <ITERATION BODY>::= <ARITH EXP>
        g.TEMP = g.PTR[g.MP - 1];  # <FOR KEY> PTR
        HALMAT_POP(g.XDFOR, 2, g.XCO_N, 0);
        EMIT_PUSH_DO(1, 5, 0, g.MP - 3, g.FIXL[g.MP - 1]);
        HALMAT_PIP(g.LOC_P[g.TEMP], g.PSEUDO_FORM[g.TEMP], 0, 0);
        g.FIXV[g.MP - 1] = g.LAST_POPp;  # IN <FOR KEY> STACK ENTRY
        goto = "DO_DISCRETE"
    # reference 1600 relocated.
    elif PRODUCTION_NUMBER == 161:  # reference 1610
        # <ITERATION CONTROL>::= TO <ARITH EXP>
        if UNARRAYED_SIMPLE(g.MPP1): ERROR(d.CLASS_GC, 3);
        g.PTR[g.MP] = g.PTR[g.MPP1];
        g.TEMP2 = 1;
    elif PRODUCTION_NUMBER == 162:  # reference 1620
        # <ITERATION CONTROL>::= TO <ARITH EXP> BY <ARITH EXP>
        g.TEMP2 = UNARRAYED_SIMPLE(g.SP);
        if UNARRAYED_SIMPLE(g.MPP1) or g.TEMP2:
            ERROR(d.CLASS_GC, 3);
        g.PTR[g.MP] = g.PTR[g.MPP1];
        g.TEMP2 = 2;
    elif PRODUCTION_NUMBER == 163:  # reference 1630
        # <FOR KEY>::= FOR <ARITH VAR> =
        CHECK_ASSIGN_CONTEXT(g.MPP1);
        if UNARRAYED_SIMPLE(g.MPP1): 
            ERROR(d.CLASS_GV, 1);
        g.PTR[g.MP] = g.PTR[g.MPP1];
        g.FIXL[g.MP] = 0
        g.FIXF[g.MP] = 0;  # NO DO CHAIN EXISTS
    elif PRODUCTION_NUMBER == 164:  # reference 1640
        #  <FOR KEY>  ::=  FOR TEMPORARY  <IDENTIFIER>  =
        g.ID_LOC = g.FIXL[g.MP + 2];
        g.PTR[g.MP] = PUSH_INDIRECT(1);
        g.LOC_P[g.PTR_TOP] = g.ID_LOC;
        g.PSEUDO_FORM[g.PTR_TOP] = g.XSYT;
        g.PSEUDO_TYPE[g.PTR_TOP] = g.INT_TYPE
        g.SYT_TYPE(g.ID_LOC, g.INT_TYPE);
        g.TEMP = g.DEFAULT_ATTR & g.SD_FLAGS;
        g.SYT_FLAGS(g.ID_LOC, g.SYT_FLAGS(g.ID_LOC) | g.TEMP);
        g.FIXL[g.MP] = g.ID_LOC
        g.DO_CHAIN[0] = g.ID_LOC;
        g.FIXF[g.MP] = 8;  # DO CHAIN EXISTS FOR CURRENT DO
        g.CONTEXT = 0;
        g.FACTORING = g.TRUE;
        if g.SIMULATING: 
            STAB_VAR(g.MP);
        SET_XREF(g.ID_LOC, g.XREF_ASSIGN);
    elif PRODUCTION_NUMBER == 165:  # reference 1650
        # <ENDING>::= END
        # ON END STATEMENT, REPLACE THE CURRENT SCOPE WITH
        # THE STATEMENT NUMBER OF THE DO.  SET A FLAG HERE TO BE USED
        # IN OUTPUT_WRITER IF THE END ISN'T IN A NON-EXPANDED
        # REPLACE MACRO.
        if ((g.GRAMMAR_FLAGS(g.STACK_PTR[g.SP]) & g.PRINT_FLAG) != 0):
            g.END_FLAG = g.TRUE;
        # USED TO ALIGN ELSE CORRECTLY
        if (g.DO_INX[g.DO_LEVEL] == 0) and g.IFDO_FLAG[g.DO_LEVEL]:
            g.MOVE_ELSE = g.FALSE;
        g.SAVE_DO_LEVEL = g.DO_LEVEL;
    elif PRODUCTION_NUMBER == 166:  # reference 1660
        # <ENDING>::= END <LABEL>
        # ON END STATEMENT, REPLACE THE CURRENT SCOPE WITH
        # THE STATEMENT NUMBER OF THE DO.  SET A FLAG HERE TO BE USED
        # IN OUTPUT_WRITER IF THE END ISN'T IN A NON-EXPANDED
        # REPLACE MACRO.
        if ((g.GRAMMAR_FLAGS(g.STACK_PTR[g.SP]) & g.PRINT_FLAG) != 0):
            g.END_FLAG = g.TRUE;
        # USED TO ALIGN ELSE CORRECTLY
        if (g.DO_INX[g.DO_LEVEL] == 0) and g.IFDO_FLAG[g.DO_LEVEL]:
            g.MOVE_ELSE = g.FALSE;
        g.SAVE_DO_LEVEL = g.DO_LEVEL;
        g.TEMP = g.MP - 1;
        while g.PARSE_STACK[g.TEMP] == g.LABEL_DEFINITION:
            g.TEMP = g.TEMP - 1;
        g.TEMP = g.TEMP - 1;
        # Note that ENDING_DONE is entirely local to this case.
        while g.PARSE_STACK[g.TEMP] == g.LABEL_DEFINITION:
            if g.FIXL[g.TEMP] == g.FIXL[g.SP]:
                # CREATE AN ASSIGN XREF ENTRY FOR A LABEL THAT
                # IS USED ON AN END STATEMENT SO THE "NOT
                # REFERENCED" MESSAGE WILL NOT BE PRINTED IN
                # THE CROSS REFERENCE TABLE. THIS XREF ENTRY
                # WILL BE REMOVED IN SYT_DUMP SO IT DOES NOT
                # SHOW UP IN THE SDF.
                SET_XREF(g.FIXL[g.SP], g.XREF_ASSIGN);
                goto = "ENDING_DONE"
                break
            g.TEMP = g.TEMP - 1;
        if goto == None:
            ERROR(d.CLASS_GL, 1);
        if goto == "ENDING_DONE": goto = None
    elif PRODUCTION_NUMBER == 167:  # reference 1670
        # <ENDING>::= <LABEL DEFINITION> <ENDING>
        # USED TO ALIGN ELSE CORRECTLY
        if (g.DO_INX[g.DO_LEVEL] == 0) and g.IFDO_FLAG[g.DO_LEVEL]:
            g.MOVE_ELSE = g.FALSE;
        g.SAVE_DO_LEVEL = g.DO_LEVEL;
        SET_LABEL_TYPE(g.FIXL[g.MP], g.STMT_LABEL);
    elif PRODUCTION_NUMBER == 168:  # reference 1680
        #    <ON PHRASE>  ::= ON ERROR  <SUBSCRIPT>
        ERROR_SUB(1);
        HALMAT_POP(g.XERON, 2, 0, 0);
        HALMAT_PIP(g.LOC_P[g.PTR[g.MP + 2]], g.XIMD, g.FIXV[g.MP] & 0x3F, 0);
        HALMAT_PIP(g.FL_NO(), g.XINL, 0, 0);
        g.FIXL[g.MP] = g.FL_NO();
        g.FL_NO(g.FL_NO() + 1);
        g.PTR_TOP = g.PTR[g.SP] - 1;
        if g.INX[g.PTR[g.SP]] == 0:
            g.SUB_END_PTR = g.STACK_PTR[g.MP] + 1;  # NULL SUBSCRIPT
        OUTPUT_WRITER(g.LAST_WRITE, g.SUB_END_PTR);
        g.INDENT_LEVEL = g.INDENT_LEVEL + g.INDENT_INCR;
        EMIT_SMRK();
        g.XSET(0x400);
    # reference 1690 relocated.
    elif PRODUCTION_NUMBER == 170:  # reference 1700
        #  <ON CLAUSE>  ::=  ON ERROR <SUBSCRIPT> IGNORE
        g.FIXL[g.MP] = 2;
        goto = "ON_ERROR_ACTION"
    # reference 1710 relocated.
    elif PRODUCTION_NUMBER == 172:  # reference 1720
        #  <SIGNAL CLAUSE>  ::=  RESET <EVENT VAR>
        g.TEMP = 2;
        goto = "SIGNAL_EMIT"
    elif PRODUCTION_NUMBER == 173:  # reference 1730
        #  <SIGNAL CLAUSE>  ::= SIGNAL <EVENT VAR>
        g.TEMP = 0;
        goto = "SIGNAL_EMIT"
    elif PRODUCTION_NUMBER == 174:  # reference 1740
        #  <FILE EXP>  ::=  <FILE HEAD>  ,  <ARITH EXP>  )
        if g.FIXV[g.MP] > g.DEVICE_LIMIT:
            ERROR(d.CLASS_TD, 1, '' + g.DEVICE_LIMIT);
            g.FIXV[g.MP] = 0;
        if UNARRAYED_INTEGER(g.SP - 1): 
            ERROR(d.CLASS_TD, 2);
        RESET_ARRAYNESS();
        g.PTR[g.MP] = g.PTR[g.SP - 1];
        if g.UPDATE_BLOCK_LEVEL > 0: 
            ERROR(d.CLASS_UT, 1);
        g.XSET(0x10);
    elif PRODUCTION_NUMBER == 175:  # reference 1750
        #  <FILE HEAD>  ::=  FILE  (  <NUMBER>
        g.FIXV[g.MP] = g.FIXV[g.MP + 2];
        if g.INLINE_LEVEL > 0: 
            ERROR(d.CLASS_PP, 5);
        SAVE_ARRAYNESS();
    elif PRODUCTION_NUMBER == 176:  # reference 1760
        #  <CALL KEY>  ::=  CALL  <LABEL VAR>
        g.I = g.FIXL[g.MPP1];
        if g.SYT_TYPE(g.I) == g.PROC_LABEL: 
            if g.SYT_LINK1(g.I) < 0:
                if g.DO_LEVEL < (-g.SYT_LINK1(g.I)): 
                    ERROR(d.CLASS_PL, 8, g.VAR[g.MPP1]);
        if g.SYT_LINK1(g.I) == 0: 
            g.SYT_LINK1(g.I, g.STMT_NUM());
        while g.SYT_TYPE(g.I) == g.IND_CALL_LAB:
            g.I = g.SYT_PTR(g.I);
        if g.SYT_TYPE(g.I) != g.PROC_LABEL: 
            ERROR(d.CLASS_DT, 3, g.VAR[g.MPP1]);
        if CHECK_ARRAYNESS(): 
            ERROR(d.CLASS_PL, 7, g.VAR[g.MPP1]);
        if (g.SYT_FLAGS(g.I) & g.ACCESS_FLAG) != 0:
            ERROR(d.CLASS_PS, 6, g.VAR[g.MPP1]);
        g.XSET(0x2);
        g.FCN_ARG[0] = 0;
        g.PTR[g.MP] = g.PTR[g.MPP1];
        SET_XREF_RORS(g.SP, 0x6000);
        if g.INLINE_LEVEL > 0: 
            ERROR(d.CLASS_PP, 7);
    elif PRODUCTION_NUMBER == 177:  # reference 1770
        #  <CALL LIST> ::= <LIST EXP>
        SETUP_CALL_ARG();
    elif PRODUCTION_NUMBER == 178:  # reference 1780
        #  <CALL LIST> ::= <CALL LIST> , <LIST EXP>
        SETUP_CALL_ARG();
    # reference 1790 relocated.
    elif PRODUCTION_NUMBER == 180:  # reference 1800
        #  <CALL ASSIGN LIST> ::= <CALL ASSIGN LIST> , <VARIABLE>
        goto = "ASSIGN_ARG"
    elif PRODUCTION_NUMBER == 181:  # reference 1810
        #  <EXPRESSION> ::= <ARITH EXP>
        g.EXT_P[g.PTR[g.MP]] = 0;
        # if THE DECLARED VALUE IS A DOUBLE CONSTANT SCALAR OR
        # INTEGER,: SET LIT1 EQUAL TO 5.
        if (g.TYPE == g.SCALAR_TYPE) or (g.FACTORED_TYPE == g.SCALAR_TYPE) or \
                (g.TYPE == g.INT_TYPE) or (g.FACTORED_TYPE == g.INT_TYPE) or \
                ((g.TYPE == 0) and (g.FACTORED_TYPE == 0)):
            if ((g.ATTRIBUTES & g.DOUBLE_FLAG) != 0) and \
                    ((g.FIXV[g.MP - 1] & g.CONSTANT_FLAG) != 0):
                g.LIT1(GET_LITERAL(g.LOC_P[g.PTR[g.MP]]), 5);
    elif PRODUCTION_NUMBER == 182:  # reference 1820
        #  <EXPRESSION> ::= <BIT EXP>
        g.EXT_P[g.PTR[g.MP]] = 0;
    elif PRODUCTION_NUMBER == 183:  # reference 1830
        #  <EXPRESSION> ::= <CHAR EXP>
        g.EXT_P[g.PTR[g.MP]] = 0;
    elif PRODUCTION_NUMBER == 184:  # reference 1840
        #  <EXPRESSION>  ::=  <STRUCTURE EXP>
        g.EXT_P[g.PTR[g.MP]] = 0;
    elif PRODUCTION_NUMBER == 185:  # reference 1850
        #  <EXPRESSION>  ::=  <NAME EXP>
        pass;
    elif PRODUCTION_NUMBER == 186:  # reference 1860
        #  <STRUCTURE EXP>  ::=  <STRUCTURE VAR>
        SET_XREF_RORS(g.MP);
    elif PRODUCTION_NUMBER == 187:  # reference 1870
        #  <STRUCTURE EXP>  ::=  <MODIFIED STRUCT FUNC>
        SETUP_NO_ARG_FCN();
    elif PRODUCTION_NUMBER == 188:  # reference 1880
        #  <STRUCTURE EXP>  ::=  <STRUC INLINE DEF> <BLOCK BODY> <CLOSING> ;
        goto = "INLINE_SCOPE"
    elif PRODUCTION_NUMBER == 189:  # reference 1890
        #  <STRUCTURE EXP>  ::=  <STRUCT FUNC HEAD>  (  <CALL LIST>  )
        END_ANY_FCN();
    elif PRODUCTION_NUMBER == 190:  # reference 1900
        #  <STRUCT FUNC HEAD>  ::=  <STRUCT FUNC>
        if START_NORMAL_FCN(): 
            ASSOCIATE();
    elif PRODUCTION_NUMBER == 191:  # reference 1910
        # <LIST EXP> ::= <EXPRESSION>
        if g.FCN_MODE[g.FCN_LV] != 1: 
            g.INX[g.PTR[g.MP]] = 0;
    elif PRODUCTION_NUMBER == 192:  # reference 1920
        #  <LIST EXP>  ::=  <ARITH EXP>  #  <EXPRESSION>
        if g.FCN_MODE[g.FCN_LV] == 2: 
            if g.PSEUDO_FORM[g.PTR[g.MP]] != g.XLIT: 
                g.TEMP = 0;
            else:
                g.TEMP = MAKE_FIXED_LIT(g.LOC_P[g.PTR[g.MP]]);
            if (g.TEMP < 1) or (g.TEMP > LIST_EXP_LIM): 
                g.TEMP = 1;
                ERROR(d.CLASS_EL, 2);
            g.INX[g.PTR[g.MP]] = g.TEMP;
        else:
            ERROR(d.CLASS_EL, 1);
            if g.FCN_MODE[g.FCN_LV] != 1: 
                g.INX[g.PTR[g.MP]] = 1;
            else:
                g.INX[g.PTR[g.MP]] = g.INX[g.PTR[g.SP]];
        g.TEMP = g.PTR[g.SP];
        g.PTR_TOP = g.PTR[g.MP];
        g.LOC_P[g.PTR_TOP] = g.LOC_P[g.TEMP];
        g.PSEUDO_FORM[g.PTR_TOP] = g.PSEUDO_FORM[g.TEMP];
        g.PSEUDO_TYPE[g.PTR_TOP] = g.PSEUDO_TYPE[g.TEMP];
        g.PSEUDO_LENGTH[g.PTR_TOP] = g.PSEUDO_LENGTH[g.TEMP];
    elif PRODUCTION_NUMBER == 193:  # reference 1930
        #  <VARIABLE> ::= <ARITH VAR>
        if not g.DELAY_CONTEXT_CHECK: 
            CHECK_ASSIGN_CONTEXT(g.MP);
    elif PRODUCTION_NUMBER == 194:  # reference 1940
        #  <VARIABLE> ::= <STRUCTURE VAR>
        if not g.DELAY_CONTEXT_CHECK: 
            CHECK_ASSIGN_CONTEXT(g.MP);
    elif PRODUCTION_NUMBER == 195:  # reference 1950
        #  <VARIABLE> ::= <BIT VAR>
        if not g.DELAY_CONTEXT_CHECK: 
            CHECK_ASSIGN_CONTEXT(g.MP);
    elif PRODUCTION_NUMBER == 196:  # reference 1960
        #  <VARIABLE  ::=  <EVENT VAR>
        if g.CONTEXT > 0: 
            if not g.NAME_PSEUDOS: 
                g.PSEUDO_TYPE[g.PTR[g.MP]] = g.BIT_TYPE;
        if not g.DELAY_CONTEXT_CHECK: 
            CHECK_ASSIGN_CONTEXT(g.MP);
        g.PSEUDO_LENGTH[g.PTR[g.MP]] = 1;
    elif PRODUCTION_NUMBER == 197:  # reference 1970
        #  <VARIABLE>  ::=  <SUBBIT HEAD>  <VARIABLE>  )
        if g.CONTEXT == 0:
            if SHR(g.VAL_P[g.PTR[g.MPP1]], 7) & 1: 
                ERROR(d.CLASS_QX, 7);
            g.TEMP = 1;
        else:
            g.TEMP = 0;
        END_SUBBIT_FCN(g.TEMP);
        SET_BI_XREF(SBIT_NDX);
        g.VAL_P[g.PTR[g.MP]] = g.VAL_P[g.PTR[g.MPP1]] | 0x80;
    elif PRODUCTION_NUMBER == 198:  # reference 1980
        #  <VARIABLE> ::= <CHAR VAR>
        if not g.DELAY_CONTEXT_CHECK: 
            CHECK_ASSIGN_CONTEXT(g.MP);
    elif PRODUCTION_NUMBER == 199:  # reference 1990
        #  <VARIABLE>  ::=  <NAME KEY>  (  <NAME VAR>  )
        if g.TEMP_SYN != 2: 
            if g.CONTEXT == 0: 
                g.TEMP_SYN = 3;
        CHECK_NAMING(g.TEMP_SYN, g.MP + 2);
        g.DELAY_CONTEXT_CHECK = g.FALSE;
    elif PRODUCTION_NUMBER == 200:  # reference 2000
        #  <NAME VAR>  ::=  <VARIABLE>
        l.H1 = g.VAL_P[g.PTR[g.MP]];
        g.ARRAYNESS_FLAG = 0;
        if SHR(l.H1, 11) & 1: 
            ERROR(d.CLASS_EN, 1);
        g.VAL_P[g.PTR[g.MP]] = l.H1 | 0x800;
        if SHR(l.H1, 7) & 1: 
            ERROR(d.CLASS_EN, 2);
        if (l.H1 & 0x880) != 0: 
            g.TEMP_SYN = 2;
        else:
            g.TEMP_SYN = 1;
    elif PRODUCTION_NUMBER == 201:  # reference 2010
        #  <NAME VAR>  ::=  <LABEL VAR>
        l.H1 = g.SYT_TYPE(g.FIXL[g.MP]);
        if l.H1 == g.TASK_LABEL or l.H1 == g.PROG_LABEL: 
            pass  # GO TO OK_LABELS;
        elif g.VAR[g.MP - 2] == 'NAME':
            ERROR(d.CLASS_EN, 4, g.VAR[g.MP]);
        # OK_LABELS:
        g.TEMP_SYN = 0;
    elif PRODUCTION_NUMBER == 202:  # reference 2020
        #  <NAME VAR>  ::=  <MODIFIED ARITH FUNC>
        g.TEMP_SYN = 0;
    elif PRODUCTION_NUMBER == 203:  # reference 2030
        #  <NAME VAR>  ::=  <MODIFIED BIT FUNC>
        g.TEMP_SYN = 0;
    elif PRODUCTION_NUMBER == 204:  # reference 2040
        #  <NAME VAR>  ::=  <MODIFIED CHAR FUNC>
        g.TEMP_SYN = 0;
    elif PRODUCTION_NUMBER == 205:  # reference 2050
        #  <NAME VAR>  ::=  <MODIFIED STRUCT FUNC>
        g.TEMP_SYN = 0;
    elif PRODUCTION_NUMBER == 206:  # reference 2060
        #  <NAME EXP>  ::=  <NAME KEY>  (  <NAME VAR>  )
        CHECK_NAMING(g.TEMP_SYN, g.MP + 2);
        g.DELAY_CONTEXT_CHECK = g.FALSE;
    # reference 2070 relocated
    elif PRODUCTION_NUMBER == 208:  # reference 2080
        #  <NAME EXP>  ::=  <NAME KEY> ( NULL )
        g.NAMING = g.FALSE;
        g.DELAY_CONTEXT_CHECK = g.FALSE;
        goto = "FIX_NULL"
    elif PRODUCTION_NUMBER == 209:  # reference 2090
        #  <NAME KEY>  ::=  NAME
        g.NAMING = g.TRUE
        g.NAME_PSEUDOS = g.TRUE;
        g.DELAY_CONTEXT_CHECK = g.TRUE;
        g.ARRAYNESS_FLAG = 0;
    elif PRODUCTION_NUMBER == 210:  # reference 2100
        #  <LABEL VAR>  ::=  <PREFIX>  <LABEL>  <SUBSCRIPT>
        goto = "FUNC_IDS";
    elif PRODUCTION_NUMBER == 211:  # reference 2110
        #  <MODIFIED ARITH FUNC>  ::=  <PREFIX>  <NO ARG ARITH FUNC> <SUBSCRIPT>
        goto = "FUNC_IDS";
    elif PRODUCTION_NUMBER == 212:  # reference 2120
        #  <MODIFIED BIT FUNC>  ::=  <PREFIX>  <NO ARG BIT FUNC>  <SUBSCRIPT>
        goto = "FUNC_IDS";
    elif PRODUCTION_NUMBER == 213:  # reference 2130
        #  <MODIFIED CHAR FUNC>  ::=  <PREFIX> <NO ARG CHAR FUNC>  <SUBSCRIPT>
        goto = "FUNC_IDS";
    # reference 2140 relocated
    elif PRODUCTION_NUMBER == 215:  # reference 2150
        #  <STRUCTURE VAR>  ::=  <QUAL STRUCT>  <SUBSCRIPT>
        l.H1 = g.PTR[g.MP];
        goto = "STRUC_IDS"
    elif PRODUCTION_NUMBER == 216:  # reference 2160
        #  <ARITH VAR>  ::=  <PREFIX>  <ARITH ID>  <SUBSCRIPT>
        goto = "MOST_IDS"
    elif PRODUCTION_NUMBER == 217:  # reference 2170
        #  <CHAR VAR>  ::=  <PREFIX>  <CHAR ID>  <SUBSCRIPT>
        goto = "MOST_IDS"
    elif PRODUCTION_NUMBER == 218:  # reference 2180
        #  <BIT VAR>  ::=  <PREFIX>  <BIT ID>  <SUBSCRIPT>
        goto = "MOST_IDS"
    # reference 2190 relocated.
    elif PRODUCTION_NUMBER == 220:  # reference 2200
        #  <QUAL STRUCT>  ::=  <STRUCTURE ID>
        g.PTR[g.MP] = PUSH_INDIRECT(1);
        g.PSEUDO_TYPE[g.PTR_TOP] = g.MAJ_STRUC;
        g.EXT_P[g.PTR_TOP] = g.STACK_PTR[g.SP];
        if g.FIXV[g.MP] == 0: 
            g.FIXV[g.MP] = g.FIXL[g.MP];
            g.FIXL[g.MP] = g.VAR_LENGTH(g.FIXL[g.MP]);
            SET_XREF(g.FIXL[g.MP], g.XREF_REF);
        g.LOC_P[g.PTR_TOP] = g.FIXV[g.MP];
        g.INX[g.PTR_TOP] = 0;
        g.VAL_P[g.PTR_TOP] = SHL(g.NAMING, 8);
        g.PSEUDO_FORM[g.PTR_TOP] = g.XSYT;
    elif PRODUCTION_NUMBER == 221:  # reference 2210
        #  <QUAL STRUCT>  ::=  <QUAL STRUCT>  .  <STRUCTURE ID>
        g.TEMP = g.VAR_LENGTH(g.FIXL[g.SP]);
        if g.TEMP > 0: 
            PUSH_INDIRECT(1);
            g.LOC_P[g.PTR_TOP] = g.FIXL[g.SP];
            g.INX[g.PTR_TOP - 1] = 1;
            g.INX[g.PTR_TOP] = 0;
            SET_XREF(g.TEMP, g.XREF_REF);
            g.FIXL[g.MP] = g.TEMP;
        else:
            g.FIXL[g.MP] = g.FIXL[g.SP];
        g.VAR[g.MP] = g.VAR[g.MP] + g.PERIOD + g.VAR[g.SP];
        g.TOKEN_FLAGS(g.STACK_PTR[g.MPP1], \
                      g.TOKEN_FLAGS(g.STACK_PTR[g.MPP1]) | 0x20);
        g.TOKEN_FLAGS(g.EXT_P[g.PTR[g.MP]], \
                      g.TOKEN_FLAGS(g.EXT_P[g.PTR[g.MP]]) | 0x20);
        g.EXT_P[g.PTR[g.MP]] = g.STACK_PTR[g.SP];
    elif PRODUCTION_NUMBER == 222:  # reference 2220
        #  <PREFIX>  ::=  <EMPTY>
        g.PTR[g.MP] = PUSH_INDIRECT(1);
        g.VAL_P[g.PTR_TOP] = SHL(g.NAMING, 8);
        g.INX[g.PTR_TOP] = 0;
        g.FIXL[g.MP] = 0
        g.FIXV[g.MP] = 0;
    elif PRODUCTION_NUMBER == 223:  # reference 2230
        #  <PREFIX>  ::=  <QUAL STRUCT>  .
        g.TOKEN_FLAGS(g.STACK_PTR[g.SP], \
                      g.TOKEN_FLAGS(g.STACK_PTR[g.SP]) | 0x20);
    elif PRODUCTION_NUMBER == 224:  # reference 2240
        # <SUBBIT HEAD>::= <SUBBIT KEY> <SUBSCRIPT>(
        g.PTR[g.MP], g.TEMP = g.PTR[g.MPP1];
        g.LOC_P[g.TEMP] = 0;
        if g.INX[g.TEMP] > 0: 
            if g.PSEUDO_LENGTH[g.TEMP] >= 0 | g.VAL_P[g.TEMP] >= 0: 
                ERROR(d.CLASS_QS, 12);
            if g.PSEUDO_FORM[g.TEMP] != 0: 
                ERROR(d.CLASS_QS, 13);
            if g.INX[g.TEMP] != 1: 
                g.INX[g.TEMP] = 1;
                ERROR(d.CLASS_QS, 11);
    elif PRODUCTION_NUMBER == 225:  # reference 2250
        # <SUBBIT KEY> ::= SUBBIT
        g.NAMING = g.FALSE;
        g.VAR[g.MP] = 'SUBBIT PSEUDO-VARIABLE';
    elif PRODUCTION_NUMBER == 226:  # reference 2260
        #  <SUBSCRIPT> ::= <SUB HEAD> )
        g.SUB_END_PTR = g.STMT_PTR;
        if g.SUB_SEEN == 0: 
            ERROR(d.CLASS_SP, 6);
        goto = "SS_CHEX"
    elif PRODUCTION_NUMBER == 227:  # reference 2270
        #  <SUBSCRIPT>  ::=  <QUALIFIER>
        g.SUB_END_PTR = g.STMT_PTR;
        g.SUB_COUNT(0);
        g.FIXL[g.MP] = 0;
        g.STRUCTURE_SUB_COUNT(0);
        g.ARRAY_SUB_COUNT(0);
    # reference 2280 relocated.
    elif PRODUCTION_NUMBER == 229:  # reference 2290
        # <SUBSCRIPT> ::= <$> <ARITH VAR>
        g.SUB_END_PTR = g.STMT_PTR;
        IORS(g.SP);
        SET_XREF_RORS(g.MPP1);
        goto = "SIMPLE_SUBS";
    elif PRODUCTION_NUMBER == 230:  # reference 2300
        #  <SUBSCRIPT>  ::=  <EMPTY>
        g.FIXL[g.MP] = 0;
        goto = "SS_FIXUP"
    # reference 2310 relocated
    elif PRODUCTION_NUMBER == 232:  # reference 2320
        #  <SUB START>  ::=  <$>  (  @  <PREC SPEC>  ,
        g.PSEUDO_FORM[g.PTR[g.MP]] = g.PTR[g.MP + 3];
        goto = "SUB_START"
    elif PRODUCTION_NUMBER == 233:  # reference 2330
        #  <SUB START> ::= <SUB HEAD> ;
        if g.STRUCTURE_SUB_COUNT() >= 0: 
            ERROR(d.CLASS_SP, 1);
        if g.SUB_SEEN: 
            g.STRUCTURE_SUB_COUNT(g.SUB_COUNT());
        else:
            ERROR(d.CLASS_SP, 4);
        g.SUB_SEEN = 1;
    elif PRODUCTION_NUMBER == 234:  # reference 2340
        #  <SUB START> ::= <SUB HEAD> :
        if g.STRUCTURE_SUB_COUNT() == -1: 
            g.STRUCTURE_SUB_COUNT(0);
        if g.ARRAY_SUB_COUNT() >= 0: 
            ERROR(d.CLASS_SP, 2);
        if g.SUB_SEEN: 
            g.ARRAY_SUB_COUNT(g.SUB_COUNT() - g.STRUCTURE_SUB_COUNT());
        else:
            ERROR(d.CLASS_SP, 3);
        g.SUB_SEEN = 1;
    elif PRODUCTION_NUMBER == 235:  # reference 2350
        #  <SUB START> ::= <SUB HEAD> ,
        if g.SUB_SEEN: 
            pass;
        else:
            ERROR(d.CLASS_SP, 5);
        g.SUB_SEEN = 0;
    elif PRODUCTION_NUMBER == 236:  # reference 2360
        #  <SUB HEAD> ::= <SUB START>
        if g.SUB_SEEN: 
            g.SUB_SEEN = 2;
    elif PRODUCTION_NUMBER == 237:  # reference 2370
        #  <SUB HEAD> ::= <SUB START> <SUB>
        g.SUB_SEEN = 1;
        g.SUB_COUNT(g.SUB_COUNT() + 1 );
    elif PRODUCTION_NUMBER == 238:  # reference 2380
        #  <SUB> ::= <SUB EXP>
        g.INX[g.PTR[g.MP]] = 1;
    elif PRODUCTION_NUMBER == 239:  # reference 2390
        # <SUB> ::= *
        g.PTR[g.MP] = PUSH_INDIRECT(1);
        g.INX[g.PTR[g.MP]] = 0;
        g.PSEUDO_FORM[g.PTR[g.MP]] = g.XAST;
        g.PSEUDO_TYPE[g.PTR[g.MP]] = 0;
        g.VAL_P[g.PTR[g.MP]] = 0;
        g.LOC_P[g.PTR[g.MP]] = 0;
    elif PRODUCTION_NUMBER == 240:  # reference 2400
        # <SUB> ::= <SUB RUN HEAD><SYB EXP>
        g.INX[g.PTR[g.MP]] = 2;
        g.INX[g.PTR[g.SP]] = 2;
    elif PRODUCTION_NUMBER == 241:  # reference 2410
        # <SUB> ::= <ARITH EXP> AT <SUB EXP>
        IORS(g.MP);
        g.INX[g.PTR[g.MP]] = 3;
        g.INX[g.PTR[g.SP]] = 3;
        g.VAL_P[g.PTR[g.MP]] = 0;
        g.PTR[g.MPP1] = g.PTR[g.SP];
    elif PRODUCTION_NUMBER == 242:  # reference 2420
        # <SUB RUN HEAD> ::= <SUB EXP> TO
        pass;
    elif PRODUCTION_NUMBER == 243:  # reference 2430
        # <SUB EXP> ::= <ARITH EXP>
        IORS(g.MP);
        g.VAL_P[g.PTR[g.MP]] = 0;
    elif PRODUCTION_NUMBER == 244:  # reference 2440
        # <SUB EXP> ::= <# EXPRESSION>
        if g.FIXL[g.MP] == 1: 
            g.PTR[g.MP] = PUSH_INDIRECT(1);
            g.PSEUDO_FORM[g.PTR[g.MP]] = 0;  #  MUSNT FALL IN LIT OR VAC
            g.PSEUDO_TYPE[g.PTR[g.MP]] = g.INT_TYPE;
        g.VAL_P[g.PTR[g.MP]] = g.FIXL[g.MP];
    elif PRODUCTION_NUMBER == 245:  # reference 2450
        #  <# EXPRESSION>  ::=  #
        g.FIXL[g.MP] = 1;
    # reference 2460 relocated
    elif PRODUCTION_NUMBER == 247:  # reference 2470
        # <# EXPRESSION> ::= <# EXPRESSION> -1 <TERM>
        g.TEMP = 1;
        goto = "SHARP_EXP"
    elif PRODUCTION_NUMBER == 248:  # reference 2480
        # <=1> ::= =
        if g.ARRAYNESS_FLAG: 
            SAVE_ARRAYNESS();
        g.ARRAYNESS_FLAG = 0;
    # reference 2490 relocated.
    elif PRODUCTION_NUMBER == 250:  # reference 2500
        # <AND> ::= &
        pass
    elif PRODUCTION_NUMBER == 251:  # reference 2510
        # <AND> ::= AND
        pass
    elif PRODUCTION_NUMBER == 252:  # reference 2520
        # <OR> ::= |
        pass
    elif PRODUCTION_NUMBER == 253:  # reference 2530
        # <OR> ::= OR
        pass
    elif PRODUCTION_NUMBER == 254:  # reference 2540
        # <NOT> ::= not 
        pass
    elif PRODUCTION_NUMBER == 255:  # reference 2550
        # <NOT> ::= NOT
        pass
    elif PRODUCTION_NUMBER == 256:  # reference 2560
        # <CAT> ::= +
        pass
    elif PRODUCTION_NUMBER == 257:  # reference 2570
        # <CAT> ::= CAT
        pass
    elif PRODUCTION_NUMBER == 258:  # reference 2580
        #  <QUALIFIER>  ::=  <$>  (  @  <PREC SPEC>  )
        g.PSEUDO_FORM[g.PTR[g.MP]] = g.PTR[g.MP + 3];
        goto = "SS_CHEX";
    elif PRODUCTION_NUMBER == 259:  # reference 2590
        #  <QUALIFIER> ::= <$> ( <SCALE HEAD> <ARITH EXP> )
        g.PSEUDO_FORM[g.PTR[g.MP]] = 0xF0;
        g.INX[g.PTR[g.SP - 1]] = g.PTR[g.SP - 2];
        goto = "SS_CHEX";
    elif PRODUCTION_NUMBER == 260:  # reference 2600
        # <QUALIFIER>::=<$>(@<PREC SPEC>,<SCALE HEAD><ARITH EXP>)
        g.PSEUDO_FORM[g.PTR[g.MP]] = 0xF0 | g.PTR[g.MP + 3];
        g.INX[g.PTR[g.SP - 1]] = g.PTR[g.SP - 2];
        goto = "SS_CHEX";
    elif PRODUCTION_NUMBER == 261:  # reference 2610
        #  <SCALE HEAD>  ::=  @
        g.PTR[g.MP] = 0;
    elif PRODUCTION_NUMBER == 262:  # reference 2620
        #  <SCALE HEAD> ::=  @ @
        g.PTR[g.MP] = 1;
    # reference 2630 relocated.
    elif PRODUCTION_NUMBER == 264:  # reference 2640
        #  <RADIX> ::= HEX
        g.TEMP3 = 4;
    elif PRODUCTION_NUMBER == 265:  # reference 2650
        #  <RADIX> ::= OCT
        g.TEMP3 = 3;
    elif PRODUCTION_NUMBER == 266:  # reference 2660
        #  <RADIX> ::= BIN
        g.TEMP3 = 1;
    elif PRODUCTION_NUMBER == 267:  # reference 2670
        # <RADIX> ::= DEC
        g.TEMP3 = 0;
    elif PRODUCTION_NUMBER == 268:  # reference 2680
        #  <BIT CONST HEAD> ::= <RADIX>
        g.FIXL[g.MP] = 1;
    elif PRODUCTION_NUMBER == 269:  # reference 2690
        #  <BIT CONST HEAD>  ::=  <RADIX>  (  <NUMBER>  )
        g.TOKEN_FLAGS(g.STACK_PTR[g.SP], \
                      g.TOKEN_FLAGS(g.STACK_PTR[g.SP]) | 0x20);
        if g.FIXV[g.MP + 2] == 0:
            ERROR(d.CLASS_LB, 8);
            g.FIXL[g.MP] = 1;
        else:
            g.FIXL[g.MP] = g.FIXV[g.MP + 2];
    # reference 2700 relocated.
    # reference 2170 relocated.
    elif PRODUCTION_NUMBER == 272:  # reference 2720
        # <BIT CONST> ::= FALSE
        g.TEMP_SYN = 0;
        goto = "DO_BIT_CONST"
    elif PRODUCTION_NUMBER == 273:  # reference 2730
        # <BIT CONST> ::= ON
        g.TEMP_SYN = 1;
        goto = "DO_BIT_CONST"
    elif PRODUCTION_NUMBER == 274:  # reference 2740
        # <BIT CONST> ::= OFF
        g.TEMP_SYN = 0;
        goto = "DO_BIT_CONST"
    # reference 2750 relocated
    elif PRODUCTION_NUMBER == 276:  # reference 2760
        #  <CHAR CONST>  ::=  CHAR  (  <NUMBER>  )  <CHAR STRING>
        g.TOKEN_FLAGS(g.STACK_PTR[g.SP - 1], 
                      g.TOKEN_FLAGS(g.STACK_PTR[g.SP - 1]) | 0x20);
        g.VAR[g.MP] = g.VAR[g.SP];
        g.TEMP = g.FIXV[g.MP + 2];
        if g.TEMP < 1: 
            ERROR(d.CLASS_LS, 2);
        else:
            while g.TEMP > 1:
                g.TEMP = g.TEMP - 1;
                g.TEMP2 = g.CHAR_LENGTH_LIM - LENGTH(g.VAR[g.MP]);
                if g.TEMP2 < g.FIXV[g.SP]: 
                    g.TEMP = 0;
                    ERROR(d.CLASS_LS, 1);
                    g.S = SUBSTR(g.VAR[g.SP], 0, g.TEMP2);
                    g.VAR[g.MP] = g.VAR[g.MP] + g.S;
                else:
                    g.VAR[g.MP] = g.VAR[g.MP] + g.VAR[g.SP];
        goto = "CHAR_LITS"
    # reference 2770 relocated
    elif PRODUCTION_NUMBER == 278:  # reference 2780
        #  <IO CONTROL>  ::=  TAB  (  <ARITH EXP>  )
        g.TEMP = 1;
        goto = "IO_CONTROL"
    elif PRODUCTION_NUMBER == 279:  # reference 2790
        #  <IO CONTROL>  ::=  COLUMN  (  <ARITH EXP>  )
        g.TEMP = 2;
        goto = "IO_CONTROL"
    elif PRODUCTION_NUMBER == 280:  # reference 2800
        #  <IO CONTROL>  ::=  LINE  (  <ARITH EXP>  )
        g.TEMP = 4;
        goto = "IO_CONTROL"
    elif PRODUCTION_NUMBER == 281:  # reference 2810
        #  <IO CONTROL>  ::=  PAGE  (  <ARITH EXP>  )
        g.TEMP = 5;
        goto = "IO_CONTROL"
    # reference 2820 relocated
    elif PRODUCTION_NUMBER == 283:  # reference 2830
        #  <READ PHRASE>  ::=  <READ PHRASE>  ,  <READ ARG>
        goto = "CHECK_READ"
    elif PRODUCTION_NUMBER == 284:  # reference 2840
        #  <WRITE PHRASE>  ::=  <WRITE KEY>  <WRITE ARG>
        pass;
    elif PRODUCTION_NUMBER == 285:  # reference 2850
        #  <WRITE PHRASE>  ::=  <WRITE PHRASE>  ,  <WRITE ARG>
        pass;
    # reference 2860 relocated
    elif PRODUCTION_NUMBER == 287:  # reference 2870
        #  <READ ARG>  ::=  <IO CONTROL>
        goto = "EMIT_IO_ARG"
    elif PRODUCTION_NUMBER == 288:  # reference 2880
        #  <WRITE ARG>  ::=  <EXPRESSION>
        g.TEMP = 0;
        goto = "EMIT_IO_ARG"
    elif PRODUCTION_NUMBER == 289:  # reference 2890
        #  <WRITE ARG>  ::=  <IO CONTROL>
        goto = "EMIT_IO_ARG"
    # reference 2900 relocated
    elif PRODUCTION_NUMBER == 291:  # reference 2910
        #  <READ KEY>  ::=  READALL  (  <NUMBER>  )
        g.TEMP = 1;
        goto = "EMIT_IO_HEAD"
    elif PRODUCTION_NUMBER == 292:  # reference 2920
        #  <WRITE KEY>  ::=  WRITE  (  <NUMBER>  )
        g.TEMP = 2;
        goto = "EMIT_IO_HEAD"
    # reference 2930 has been relocated.
    elif PRODUCTION_NUMBER == 294:  # reference 2940
        #  <BLOCK BODY>  ::= <EMPTY>
        HALMAT_POP(g.XEDCL, 0, g.XCO_N, 0);
        goto = "CHECK_DECLS"
    # reference 2950 has been relocated.
    elif PRODUCTION_NUMBER == 296:  # reference 2960
        #  <BLOCK BODY>  ::=  <BLOCK BODY>  <ANY STATEMENT>
        g.PTR[g.MP] = 1;
    # reference 2970 relocated
    elif PRODUCTION_NUMBER == 298:  # reference 2980
        #  <ARITH INLINE DEF>  ::=  FUNCTION  ;
        g.TYPE = g.DEFAULT_TYPE;
        g.ATTRIBUTES = g.DEFAULT_ATTR & g.SD_FLAGS;
        g.TEMP = 0;
        g.INLINE_DEFS = True
    elif PRODUCTION_NUMBER == 299:  # reference 2990
        #  <BIT INLINE DEF>  ::=  FUNCTION <BIT SPEC>  ;
        g.TEMP = g.BIT_LENGTH;
        goto = "INLINE_DEFS"
    elif PRODUCTION_NUMBER == 300:  # reference 3000
        #  <CHAR INLINE DEF>  ::=  FUNCTION <CHAR SPEC>  ;
        if g.CHAR_LENGTH < 0:
            ERROR(d.CLASS_DS, 3);
            g.TEMP = g.DEF_CHAR_LENGTH;
        else:
            g.TEMP = g.CHAR_LENGTH;
        goto = "INLINE_DEFS"
    elif PRODUCTION_NUMBER == 301:  # reference 3010
        #  <STRUC INLINE DEF>  ::=  FUNCTION <STRUCT SPEC>  ;
        if STRUC_DIM != 0: 
            ERROR(d.CLASS_DD, 12);
            g.STRUC_DIM = 0;
        g.TEMP = g.STRUC_PTR;
        g.TYPE = g.MAJ_STRUC;
        goto = "INLINE_DEFS"
    elif PRODUCTION_NUMBER == 302:  # reference 3020
        #  <BLOCK STMT>  ::=  <BLOCK STMT TOP>  ;
        OUTPUT_WRITER();
        if g.PARMS_PRESENT <= 0: 
            if g.EXTERNALIZE & 1: 
                g.EXTERNALIZE = 4;
        g.INDENT_LEVEL = g.INDENT_LEVEL + g.INDENT_INCR;
        if g.TPL_REMOTE:
            if g.EXTERNAL_MODE > 0 and g.NEST == 1 and g.BLOCK_MODE[g.NEST] == g.CMPL_MODE:
                g.SYT_FLAGS(g.FIXL[g.MP], g.SYT_FLAGS(g.FIXL[g.MP]) | g.REMOTE_FLAG);
            else:
                ERROR(d.CLASS_PS, 13);
        g.TPL_REMOTE = g.FALSE;
        EMIT_SMRK();
    elif PRODUCTION_NUMBER == 303:  # reference 3030
        #  <BLOCK STMT TOP> ::= <BLOCK STMT TOP> ACCESS
        if g.BLOCK_MODE[g.NEST] > g.PROG_MODE:
            ERROR(d.CLASS_PS, 3);
        elif g.NEST != 1: 
            ERROR(d.CLASS_PS, 4);
        elif (g.SYT_FLAGS(g.FIXL[g.MP]) & g.ACCESS_FLAG) != 0: 
            ERROR(d.CLASS_PS, 10);
        else:
            g.SYT_FLAGS(g.FIXL[g.MP], g.SYT_FLAGS(g.FIXL[g.MP]) | g.ACCESS_FLAG);
            g.ACCESS_FOUND = g.TRUE;
    elif PRODUCTION_NUMBER == 304:  # reference 3040
        #  <BLOCK STMT TOP>  ::= <BLOCK STMT TOP> RIGID
        if g.BLOCK_MODE[g.NEST] != g.CMPL_MODE: 
            ERROR(d.CLASS_PS, 12);
        elif (g.SYT_FLAGS(g.FIXL[g.MP]) & g.RIGID_FLAG) != 0: 
            ERROR(d.CLASS_PS, 11);
        else:
            g.SYT_FLAGS(g.FIXL[g.MP], g.SYT_FLAGS(g.FIXL[g.MP]) | g.RIGID_FLAG);
    elif PRODUCTION_NUMBER == 305:  # reference 3050
        #  <BLOCK STMT TOP>  ::=  <BLOCK STMT HEAD>
        pass;
    elif PRODUCTION_NUMBER == 306:  # reference 3060
        #  <BLOCK STMT TOP>  ::=  <BLOCK STMT HEAD>  EXCLUSIVE
        if g.BLOCK_MODE[g.NEST] > g.FUNC_MODE: 
            ERROR(d.CLASS_PS, 2, 'EXCLUSIVE');
        g.SYT_FLAGS(g.FIXL[g.MP], g.SYT_FLAGS(g.FIXL[g.MP]) | g.EXCLUSIVE_FLAG);
    elif PRODUCTION_NUMBER == 307:  # reference 3070
        #  <BLOCK STMT TOP>  ::=  <BLOCK STMT HEAD>  REENTRANT
        if g.BLOCK_MODE[g.NEST] > g.FUNC_MODE: 
            ERROR(d.CLASS_PS, 2, 'REENTRANT');
        g.SYT_FLAGS(g.FIXL[g.MP], g.SYT_FLAGS(g.FIXL[g.MP]) | g.REENTRANT_FLAG);
    elif PRODUCTION_NUMBER == 308:  # reference 3080
        #  <LABEL DEFINITION>  ::=  <LABEL>  :
        if g.NEST == 0: 
            g.EXTERNAL_MODE = 0;
        HALMAT_POP(g.XLBL, 1, g.XCO_N, 0);
        HALMAT_PIP(g.FIXL[g.MP], g.XSYT, 0, 0);
        g.TEMP = g.FIXL[g.MP];
        if g.SYT_TYPE(g.TEMP) != g.IND_CALL_LAB: 
            if g.SYT_LINK1(g.TEMP) > 0: 
                if g.DO_LEVEL > 0:
                    if g.DO_STMTp[g.DO_LEVEL] > g.SYT_LINK1(g.TEMP):
                        if g.SYT_TYPE(g.TEMP) == g.STMT_LABEL: 
                            ERROR(d.CLASS_GL, 2);
                        else:
                            ERROR(d.CLASS_PL, 10);
            if g.SYT_LINK1(g.TEMP) >= 0: 
                g.SYT_LINK1(g.TEMP, -g.DO_LEVEL);
                g.SYT_LINK2(g.TEMP, g.SYT_LINK2(0));
                g.SYT_LINK2(0, g.TEMP);
        g.LABEL_COUNT = g.LABEL_COUNT + 1;
        if g.SIMULATING: 
            STAB_LAB(g.FIXL[g.MP]);
        g.GRAMMAR_FLAGS(g.STACK_PTR[g.MP], \
                        g.GRAMMAR_FLAGS(g.STACK_PTR[g.MP]) | g.LABEL_FLAG);
        # IF THE XREF ENTRY IS FOR THE LABEL'S DEFINITION (FLAG=0),
        # THEN CHECK THE STATEMENT NUMBER.  IF IT IS NOT EQUAL TO CURRENT
        # STATEMENT NUMBER, CHANGE IT TO THE CURRENT STATEMENT NUMBER.
        if (SHR(g.XREF(g.SYT_XREF(g.FIXL[g.MP])), 13) & 7) == 0:
            if (g.XREF(g.SYT_XREF(g.FIXL[g.MP])) & g.XREF_MASK) != g.STMT_NUM():
                g.XREF(g.SYT_XREF(g.FIXL[g.MP]), \
                    (g.XREF(g.SYT_XREF(g.FIXL[g.MP])) & 0xFFFFE000) | g.STMT_NUM());
        if g.SYT_TYPE(g.FIXL[g.MP]) == g.STMT_LABEL:
            g.NO_NEW_XREF = g.TRUE;
            SET_XREF(g.FIXL[g.MP], 0);
    elif PRODUCTION_NUMBER == 309:  # reference 3090
        #  <LABEL EXTERNAL>  ::=  <LABEL DEFINITION>
        pass;
    elif PRODUCTION_NUMBER == 310:  # reference 3100
        #  <LABEL EXTERNAL>  ::=  <LABEL DEFINITION>  EXTERNAL
        if g.NEST > 0: 
            ERROR(d.CLASS_PE, 1);
        else:
            g.SYT_FLAGS(g.FIXL[g.MP], g.SYT_FLAGS(g.FIXL[g.MP]) | g.EXTERNAL_FLAG);
            g.EXTERNAL_MODE = 1;  # JUST A FLAG FOR NOW
            if g.BLOCK_MODE[0] > 0: 
                ERROR(d.CLASS_PE, 2);
            if g.SIMULATING:
                g.STAB2_STACKTOP = g.STAB2_STACKTOP - 1;
                g.SIMULATING = 2;
    # reference 3110 relocated
    elif PRODUCTION_NUMBER == 312:  # reference 3120
        #  <BLOCK STMT HEAD>  ::=  <LABEL EXTERNAL>  COMPOOL
        g.TEMP = g.XCDEF;
        g.TEMP2 = g.CMPL_MODE;
        g.PARMS_PRESENT = 1;  #  FIX SO ALL DECLARES EMITTED IN CMPL TEMPLATE
        SET_LABEL_TYPE(g.FIXL[g.MP], g.COMPOOL_LABEL);
        # THIS IS A COMPOOL COMPILATION
        # CHECK IF #D OPTION IS ON.   EMIT FATAL ERROR IF ITS.
        # TURN OFF DATA REMOTE TO ALLOW FOR FUTURE DOWNGRADE OF
        # THE ERROR
        # PART 1. ALSO CHECK IF COMPOOL IS NOT
        #         EXTERNAL BEFORE EMITTING THE XR2 ERROR.
        if g.DATA_REMOTE and (g.EXTERNAL_MODE == 0):
            ERROR(d.CLASS_XR, 2);
            g.DATA_REMOTE = g.FALSE;
        if g.EXTERNAL_MODE > 0: 
            if g.NEST == 0: 
                g.EXTERNAL_MODE = g.TEMP2;
            goto = "NEW_SCOPE"
        else:
            goto = "OUTERMOST_BLOCK"
    elif PRODUCTION_NUMBER == 313:  # reference 3130
        #  <BLOCK STMT HEAD>  ::=  <LABEL DEFINITION>  TASK
        g.TEMP = g.XTDEF;
        g.TEMP2 = g.TASK_MODE;
        SET_LABEL_TYPE(g.FIXL[g.MP], g.TASK_LABEL);
        g.SYT_FLAGS(g.FIXL[g.MP], g.SYT_FLAGS(g.FIXL[g.MP]) | g.LATCHED_FLAG);
        if g.NEST == 1:
            if g.BLOCK_MODE[1] == g.PROG_MODE: 
                if g.DO_LEVEL > 1: 
                    ERROR(d.CLASS_PT, 2);
                goto = "NEW_SCOPE"
        if goto == None:
            ERROR(d.CLASS_PT, 1);
            if g.NEST == 0: 
                goto = "DUPLICATE_BLOCK"
            else:
                goto = "NEW_SCOPE"
    # reference 3140 relocated
    elif PRODUCTION_NUMBER == 315:  # reference 3150
        #  <BLOCK STMT HEAD>  ::=  UPDATE
        g.VAR[g.MPP1] = g.VAR[g.MP];
        g.IMPLIED_UPDATE_LABEL = g.IMPLIED_UPDATE_LABEL + 1;
        g.VAR[g.MP] = l.UPDATE_NAME + str(g.IMPLIED_UPDATE_LABEL);
        g.NAME_HASH = HASH(g.VAR[g.MP], g.SYT_HASHSIZE);
        g.I = ENTER(g.VAR[g.MP], g.LABEL_CLASS);
        g.FIXL[g.MP] = g.I;
        g.SYT_TYPE(g.I, g.UNSPEC_LABEL);
        g.SYT_FLAGS(g.I, g.SYT_FLAGS(g.I) | g.DEFINED_LABEL);
        g.VAR_LENGTH(g.I, 2);
        if g.SIMULATING: 
            STAB_LAB(g.FIXL[g.MP]);
        goto = "UPDATE_HEAD"
    # reference 3160 relocated
    elif PRODUCTION_NUMBER == 317:  # reference 3170
        #  <BLOCK STMT HEAD>  ::=  <FUNCTION NAME>  <FUNC STMT BODY>
        goto = "FUNC_HEADER"
    elif PRODUCTION_NUMBER == 318:  # reference 3180
        #  <BLOCK STMT HEAD>  ::=  <PROCEDURE NAME>
        g.PARMS_WATCH = g.FALSE;
        if g.MAIN_SCOPE == g.SCOPEp: 
            g.COMSUB_END(g.FIXL[g.MP]);
    elif PRODUCTION_NUMBER == 319:  # reference 3190
        #  <BLOCK STMT HEAD>  ::=  <PROCEDURE NAME>  <PROC STMT BODY>
        pass;
    elif PRODUCTION_NUMBER == 320:  # reference 3200
        #  <FUNCTION NAME>  ::=  <LABEL EXTERNAL>  FUNCTION
        g.ID_LOC = g.FIXL[g.MP];
        g.FACTORING = g.FALSE;
        if g.SYT_CLASS(g.ID_LOC) != g.FUNC_CLASS:
            if g.SYT_CLASS(g.ID_LOC) != g.LABEL_CLASS or g.SYT_TYPE(g.ID_LOC) != g.UNSPEC_LABEL:
                ERROR(d.CLASS_PL, 4);
            else:
                g.SYT_CLASS(g.ID_LOC, g.FUNC_CLASS);
                g.SYT_TYPE(g.ID_LOC, 0);
        g.TEMP = g.XFDEF;
        g.TEMP2 = g.FUNC_MODE;
        goto = "PROC_FUNC_HEAD"
    # reference 3210 relocated
    elif PRODUCTION_NUMBER == 322:  # reference 3220
        #  <FUNC STMT BODY>  ::=  <PARAMETER LIST>
        pass;
    elif PRODUCTION_NUMBER == 323:  # reference 3230
        #  <FUNC STMT BODY>  ::=  <TYPE SPEC>
        pass;
    elif PRODUCTION_NUMBER == 324:  # reference 3240
        #  <FUNC STMT BODY>  ::=  <PARAMETER LIST>  <TYPE SPEC>
        pass;
    elif PRODUCTION_NUMBER == 325:  # reference 3250
        #  <PROC STMT BODY>  ::=  <PARAMETER LIST>
        pass;
    elif PRODUCTION_NUMBER == 326:  # reference 3260
        #  <PROC STMT BODY>  ::=  <ASSIGN LIST>
        pass;
    elif PRODUCTION_NUMBER == 327:  # reference 3270
        #  <PROC STMT BODY>  ::=  <PARAMETER LIST>  < ASSIGN LIST>
        pass;
    elif PRODUCTION_NUMBER == 328:  # reference 3280
        #  <PARAMETER LIST>  ::=  <PARAMETER HEAD>  <IDENTIFIER>  )
        g.PARMS_PRESENT = g.PARMS_PRESENT + 1;
    elif PRODUCTION_NUMBER == 329:  # reference 3290
        #  <PARAMETER HEAD>  ::=  (
        pass;
    elif PRODUCTION_NUMBER == 330:  # reference 3300
        #  <PARAMETER HEAD>  ::=  <PARAMETER HEAD>  <IDENTIFIER>  ,
        g.PARMS_PRESENT = g.PARMS_PRESENT + 1;
    elif PRODUCTION_NUMBER == 331:  # reference 3310
        #  <ASSIGN LIST>  ::=  <ASSIGN>  <PARAMETER LIST>
        pass;
    elif PRODUCTION_NUMBER == 332:  # reference 3320
        #  <ASSIGN>  ::=  ASSIGN
        if g.CONTEXT == g.PARM_CONTEXT: 
            g.CONTEXT = g.ASSIGN_CONTEXT;
        else:
            g.ASSIGN_ARG_LIST = g.TRUE;
    elif PRODUCTION_NUMBER == 333:  # reference 3330
        #  <DECLARE ELEMENT>  ::=  <DECLARE STATEMENT>
        g.STMT_TYPE = c19.DECL_STMT_TYPE;
        if g.SIMULATING: 
            STAB_HDR();
        EMIT_SMRK(1);
    # reference 3340 relocated.
    elif PRODUCTION_NUMBER == 335:  # reference 3350
        #  <DECLARE ELEMENT>  ::=  <STRUCTURE STMT>
        g.SYT_ADDR(g.REF_ID_LOC, g.STRUC_SIZE);
        g.REF_ID_LOC = 0;
        g.STMT_TYPE = c19.STRUC_STMT_TYPE;
        if g.SIMULATING: 
            STAB_HDR();
        goto = "EMIT_NULL";
    elif PRODUCTION_NUMBER == 336:  # reference 3360
        #  <DECLARE ELEMENT>  ::=  EQUATE  EXTERNAL  <IDENTIFIER>  TO <VARIABLE>  ;
        g.I = g.FIXL[g.MP + 2];  # EQUATE NAME
        g.J = g.SP - 1;
        if g.SYT_CLASS(g.FIXL[g.J]) == g.TEMPLATE_CLASS:
            g.J = g.FIXV[g.J];  # ROOT PTR SAVED IN FIXV FOR STRUCS
        else:
            g.J = g.FIXL[g.J];  # SYT PTR IN FIXL FOR OTHERS
        g.SYT_PTR(g.I, g.J);  # POINT AT REFERENCED ITEM
        if (g.SYT_FLAGS(g.BLOCK_SYTREF[g.NEST]) & g.EXTERNAL_FLAG) != 0:
            g.SYT_FLAGS(g.I, g.SYT_FLAGS(g.I) | g.DUMMY_FLAG);  # IGNORE IN TEMPLATES
        if g.SYT_SCOPE(g.I) != g.SYT_SCOPE(g.J):
            ERROR(d.CLASS_DU, 7, g.VAR[g.SP - 1]);
        if g.SYT_TYPE(g.J) > g.MAJ_STRUC:
            ERROR(d.CLASS_DU, 8, g.VAR[g.SP - 1]);
        if (g.SYT_FLAGS(g.J) & g.ILL_EQUATE_ATTR) != 0:
            ERROR(d.CLASS_DU, 9, g.VAR[g.SP - 1]);
        if (g.SYT_FLAGS(g.J) & g.AUTO_FLAG) != 0:
            if (g.SYT_FLAGS(g.BLOCK_SYTREF[g.NEST]) & g.REENTRANT_FLAG) != 0:
                ERROR(d.CLASS_DU, 13, g.VAR[g.SP - 1]);
        g.TEMP = g.PTR[g.SP - 1];
        if (g.VAL_P[g.TEMP] & 0x40) != 0:
            ERROR(d.CLASS_DU, 10, g.VAR[g.SP - 1]);  # PREC MODIFIER
        if (g.VAL_P[g.TEMP] & 0x80) != 0:
            ERROR(d.CLASS_DU, 11, g.VAR[g.MP + 2]);  # SUBBIT
        if KILL_NAME(g.SP - 1):
            ERROR(d.CLASS_DU, 14, g.VAR[g.MP + 2]);  # NAME(.)
        else:
            RESET_ARRAYNESS();
        if (g.VAL_P[g.TEMP] & 0x20) != 0:
            HALMAT_FIX_PIPTAGS(g.INX[g.TEMP], 0, 1);
        g.DELAY_CONTEXT_CHECK = g.FALSE
        g.NAMING = g.FALSE;
        if g.SYT_PTR(g.J) < 0:
            ERROR(d.CLASS_DU, 12, g.VAR[g.SP - 1]);
        HALMAT_POP(g.XEINT, 2, 0, g.PSEUDO_TYPE[g.TEMP]);
        HALMAT_PIP(g.FIXL[g.MP + 2], g.XSYT, 0, 0);
        HALMAT_PIP(g.LOC_P[g.TEMP], g.PSEUDO_FORM[g.TEMP], 0, 0);
        CHECK_ARRAYNESS();
        g.PTR_TOP = g.PTR[g.SP - 1] - 1;
        g.STMT_TYPE = c19.EQUATE_TYPE;
        if g.SIMULATING: 
            STAB_HDR();
        goto = "EMIT_NULL";
    elif PRODUCTION_NUMBER == 337:  # reference 3370
        #  <REPLACE STMT>  ::=  REPLACE  <REPLACE HEAD>  BY  <TEXT>
        g.CONTEXT = 0;
        g.MAC_NUM = g.FIXL[g.MPP1];
        g.SYT_ADDR(g.MAC_NUM, g.START_POINT);
        g.VAR_LENGTH(g.MAC_NUM, g.MACRO_ARG_COUNT);
        g.EXTENT(g.MAC_NUM, g.REPLACE_TEXT_PTR);
        g.MACRO_ARG_COUNT = 0;
    # reference 3380 relocated.
    elif PRODUCTION_NUMBER == 339:  # reference 3390
        #  <REPLACE HEAD>  ::=  <IDENTIFIER>  (  <ARG LIST>  )
        g.NOSPACE();
        goto = "INIT_MACRO"
    # reference 3400 relocated
    elif PRODUCTION_NUMBER == 341:  # reference 3410
        #  <ARG LIST>  ::=  <ARG LIST>  ,  <IDENTIFIER>
        goto = "NEXT_ARG"
    elif PRODUCTION_NUMBER == 342:  # reference 3420
        #  <TEMPORARY STMT>  ::=  TEMPORARY  <DECLARE BODY>  ;
        if g.SIMULATING: 
            g.STMT_TYPE = TEMP_TYPE;
        STAB_HDR();
        goto = "DECL_STAT"
    # reference 3430 relocated
    elif PRODUCTION_NUMBER == 344:  # reference 3440
        #  <DECLARE BODY>  ::=  <DECLARATION LIST>
        pass;
    elif PRODUCTION_NUMBER == 345:  # reference 3450
        #  <DECLARE BODY>  ::=  <ATTRIBUTES> , <DECLARATION LIST>
        # Regarding this implementation of the , see the comments in g.py for the 
        # TYPE variable et al.
        g.FACTORED_TYPE = 0
        g.FACTORED_BIT_LENGTH = 0
        g.FACTORED_CHAR_LENGTH = 0
        g.FACTORED_MAT_LENGTH = 0
        g.FACTORED_VEC_LENGTH = 0
        g.FACTORED_ATTRIBUTES = 0
        g.FACTORED_ATTRIBUTES2 = 0
        g.FACTORED_ATTR_MASK = 0
        g.FACTORED_STRUC_PTR = 0
        g.FACTORED_STRUC_DIM = 0
        g.FACTORED_CLASS = 0
        g.FACTORED_NONHAL = 0
        g.FACTORED_LOCKp = 0
        g.FACTORED_IC_PTR = 0
        g.FACTORED_IC_FND = 0
        g.FACTORED_N_DIM = 0
        g.FACTORED_S_ARRAY = [0] * (g.N_DIM_LIM + 1)
        g.FACTOR_FOUND = g.FALSE;
    elif PRODUCTION_NUMBER == 346:  # reference 3460
        #  <DECLARATION LIST>  ::=  <DECLARATION>
        g.SAVE_INDENT_LEVEL = g.INDENT_LEVEL;
        g.ATTR_FOUND = g.FALSE;
        g.LAST_WRITE = 0;
    elif PRODUCTION_NUMBER == 347:  # reference 3470
        #  <DECLARATION LIST>  ::=  <DCL LIST ,>   <DECLARATION>
        pass;
    elif PRODUCTION_NUMBER == 348:  # reference 3480
        #  <DCL LIST ,>  ::=  <DECLARATION LIST>  ,
        if g.ATTR_FOUND:
            if g.ATTR_LOC >= 0:
                if g.ATTR_LOC != 0:
                    OUTPUT_WRITER(g.LAST_WRITE, g.ATTR_LOC - 1);
                    if g.INDENT_LEVEL == g.SAVE_INDENT_LEVEL:
                        g.INDENT_LEVEL = g.INDENT_LEVEL + g.ATTR_INDENT;
                OUTPUT_WRITER(g.ATTR_LOC, g.STMT_PTR);
                g.LAST_WRITE = 0;
        else:
            g.ATTR_FOUND = g.TRUE;
            if (g.GRAMMAR_FLAGS(1) & g.ATTR_BEGIN_FLAG) != 0:
                # <ARRAY, TYPE, & ATTR> FACTORED
                OUTPUT_WRITER(0, g.STACK_PTR[g.MP] - 1);
                g.LAST_WRITE = g.STACK_PTR[g.MP];
                g.INDENT_LEVEL = g.INDENT_LEVEL + g.ATTR_INDENT + g.INDENT_INCR;
                if g.ATTR_LOC >= 0:
                    OUTPUT_WRITER(g.STACK_PTR[g.MP], g.STMT_PTR);
                    g.LAST_WRITE = 0;
            else:
                if g.ATTR_LOC >= 0:
                    OUTPUT_WRITER();
                    g.LAST_WRITE = 0;
                    g.INDENT_LEVEL = g.INDENT_LEVEL + g.ATTR_INDENT;
        if g.INIT_EMISSION: 
            g.INIT_EMISSION = g.FALSE;
            EMIT_SMRK(0);
    elif PRODUCTION_NUMBER == 349:  # reference 3490
        #  <DECLARE GROUP>  ::=  <DECLARE ELEMENT>
        pass;
    elif PRODUCTION_NUMBER == 350:  # reference 3500
        #  <DECLARE GROUP>  ::=  <DECLARE GROUP>  <DECLARE ELEMENT>
        pass;
    elif PRODUCTION_NUMBER == 351:  # reference 3510
        #  <STRUCTURE STMT>  ::=  STRUCTURE <STRUCT STMT HEAD> <STRUCT STMT TAIL>
        g.FIXV[g.SP] = 0;
        g.FIXL[g.MP] = g.FIXL[g.MPP1];
        g.FIXV[g.MP] = g.FIXV[g.MPP1];
        g.FIXL[g.MPP1] = g.FIXL[g.SP];
        g.FACTORING = g.TRUE;
        goto = "STRUCT_GOING_UP"
    # reference 3520 relocated
    elif PRODUCTION_NUMBER == 353:  # reference 3530
        #  <STRUCT STMT HEAD>  ::=  <IDENTIFIER> <MINOR ATTR LIST> : <LEVEL>
        goto = "NO_ATTR_STRUCT"
    # reference 3540 was relocated
    elif PRODUCTION_NUMBER == 355:  # reference 3550
        #  <STRUCT STMT TAIL>  ::=  <DECLARATION>  ;
        pass;
    elif PRODUCTION_NUMBER == 356:  # reference 3560
        # <STRUCT SPEC> ::= <STRUCT TEMPLATE> <STRUCT SPEC BODY>
        g.STRUC_PTR = g.FIXL[g.MP];
        if g.SYT_TYPE(g.STRUC_PTR) != g.TEMPL_NAME:
            g.SYT_FLAGS(g.STRUC_PTR, g.SYT_FLAGS(g.STRUC_PTR) | g.EVIL_FLAG);
        SET_XREF(g.STRUC_PTR, g.XREF_REF);
        g.NOSPACE();
    elif PRODUCTION_NUMBER == 357:  # reference 3570
        # <STRUCT SPEC BODY> ::= - STRUCTURE
        g.NOSPACE();
    elif PRODUCTION_NUMBER == 358:  # reference 3580
        # <STRUCT SPEC BODY> ::= <STRUCT SPEC HEAD> <LITERAL EXP OR*> )
        g.CONTEXT = g.DECLARE_CONTEXT;
        g.I = g.FIXV[g.MPP1];
        if not ((g.I > 1) and (g.I <= g.ARRAY_DIM_LIM) or (g.I == -1)):
            ERROR(d.CLASS_DD, 11);
            g.STRUC_DIM = 2;  # A DEFAULT
        else:
            g.STRUC_DIM = g.I;
    elif PRODUCTION_NUMBER == 359:  # reference 3590
        # <STRUCT SPEC HEAD> ::= - STRUCTURE (
        g.NOSPACE();
        g.TOKEN_FLAGS(g.STACK_PTR[g.MPP1], \
                      g.TOKEN_FLAGS(g.STACK_PTR[g.MPP1]) | 0x20);
    elif PRODUCTION_NUMBER == 360:  # reference 3600
        #  <DECLARATION>  ::=  <NAME ID>
        if not g.BUILDING_TEMPLATE:
            if g.NAME_IMPLIED: 
                g.ATTR_LOC = g.STACK_PTR[g.MP];
            else:
                g.ATTR_LOC = -1;
            goto = "SPEC_VAR"
    # reference 3610 relocated.
    elif PRODUCTION_NUMBER == 362:  # reference 3620
        #  <NAME ID>   ::=  <IDENTIFIER>
        g.ID_LOC = g.FIXL[g.MP];
    elif PRODUCTION_NUMBER == 363:  # reference 3630
        #  <NAME ID>  ::=  <IDENTIFIER> NAME
        # REMOVED DN2 ERROR
        g.NAME_IMPLIED = g.TRUE;
        g.ID_LOC = g.FIXL[g.MP];
    elif PRODUCTION_NUMBER == 364:  # reference 3640
        # <ATTRIBUTES> ::= <ARRAY SPEC> <TYPE & MINOR ATTR>
        goto = "CHECK_ARRAY_SPEC"
    # reference 3650 relocated
    # reference 3660 relocated
    elif PRODUCTION_NUMBER == 367:  # reference 3670
        #  <ARRAY SPEC> ::= <ARRAY HEAD> <LITERAL EXP OR *> )
        g.CONTEXT = g.DECLARE_CONTEXT;
        goto = "ARRAY_SPEC"
    elif PRODUCTION_NUMBER == 368:  # reference 3680
        #  <ARRAY SPEC>  ::=  FUNCTION
        g.CLASS = 2;
    elif PRODUCTION_NUMBER == 369:  # reference 3690
        #  <ARRAY SPEC>  ::=  PROCEDURE
        g.TYPE = g.PROC_LABEL;
        g.CLASS = 1;
    elif PRODUCTION_NUMBER == 370:  # reference 3700
        #  <ARRAY SPEC>  ::= PROGRAM
        g.TYPE = g.PROG_LABEL;
        g.CLASS = 1;
    elif PRODUCTION_NUMBER == 371:  # reference 3710
        #  <ARRAY SPEC>  ::=  TASK
        g.TYPE = g.TASK_LABEL;
        g.CLASS = 1;
    elif PRODUCTION_NUMBER == 372:  # reference 3720
        #  <ARRAY HEAD> ::= ARRAY (
        g.STARRED_DIMS = 0
        g.N_DIM = 0;
        for g.I in range(0, 1 + g.N_DIM_LIM):
            g.S_ARRAY[g.I] = 0;
        g.FIXV[g.SP] = g.ARRAY_FLAG;
        g.FIXL[g.SP] = g.ARRAY_FLAG;
        goto = "INCORPORATE_ATTR";
    # reference 3730 relocated
    elif PRODUCTION_NUMBER == 374:  # reference 3740
        #  <TYPE & MINOR ATTR> ::= <TYPE SPEC>
        goto = "SPEC_TYPE"
    # reference 3750 relocated
    elif PRODUCTION_NUMBER == 376:  # reference 3760
        #  <TYPE & MINOR ATTR> ::= <MINOR ATTR LIST>
        pass;
    elif PRODUCTION_NUMBER == 377:  # reference 3770
        #  <TYPE SPEC> ::= <STRUCT SPEC>
        g.TYPE = g.MAJ_STRUC;
    elif PRODUCTION_NUMBER == 378:  # reference 3780
        #  <TYPE SPEC>  ::=  <BIT SPEC>
        pass;
    elif PRODUCTION_NUMBER == 379:  # reference 3790
        #  <TYPE SPEC>  ::=  <CHAR SPEC>
        pass;
    elif PRODUCTION_NUMBER == 380:  # reference 3800
        #  <TYPE SPEC>  ::=  <ARITH SPEC>
        pass;
    elif PRODUCTION_NUMBER == 381:  # reference 3810
        #  <TYPE SPEC>  ::=  EVENT
        g.TYPE = g.EVENT_TYPE;
    elif PRODUCTION_NUMBER == 382:  # reference 3820
        #  <BIT SPEC>  ::=  BOOLEAN
        g.TYPE = g.BIT_TYPE;
        g.BIT_LENGTH = 1;  # BOOLEAN
    elif PRODUCTION_NUMBER == 383:  # reference 3830
        #  <BIT SPEC>  ::=  BIT  (  <LITERAL EXP OR *>  )
        g.NOSPACE();
        g.CONTEXT = g.DECLARE_CONTEXT;
        g.J = g.FIXV[g.MP + 2];
        g.K = g.DEF_BIT_LENGTH;
        if g.J == -1: 
            ERROR(d.CLASS_DS, 4);  # "*" ILLEGAL
        elif (g.J <= 0) or (g.J > g.BIT_LENGTH_LIM):
            ERROR(d.CLASS_DS, 1);
        else:
            g.K = g.J;
        g.TYPE = g.BIT_TYPE;
        g.BIT_LENGTH = g.K;
    elif PRODUCTION_NUMBER == 384:  # reference 3840
        #  <CHAR SPEC>  ::=  CHARACTER  (  <LITERAL EXP OR *>  )
        g.NOSPACE();
        g.CONTEXT = g.DECLARE_CONTEXT;
        g.J = g.FIXV[g.MP + 2];
        g.K = g.DEF_CHAR_LENGTH;
        if g.J == -1: 
            g.K = g.J;
        elif (g.J <= 0) or (g.J > g.CHAR_LENGTH_LIM):
            ERROR(d.CLASS_DS, 2);
        else:
            g.K = g.J;
        g.CHAR_LENGTH = g.K;
        g.TYPE = g.CHAR_TYPE;
    elif PRODUCTION_NUMBER == 385:  # reference 3850
        #  <ARITH SPEC>  ::=  <PREC SPEC>
        g.ATTR_MASK = g.ATTR_MASK | g.FIXL[g.MP];
        g.ATTRIBUTES = g.ATTRIBUTES | g.FIXV[g.MP];
    elif PRODUCTION_NUMBER == 386:  # reference 3860
        #  <ARITH SPEC>  ::=  <SQ DQ NAME>
        pass;
    elif PRODUCTION_NUMBER == 387:  # reference 3870
        #  <ARITH SPEC>  ::=  <SQ DQ NAME>  <PREC SPEC>
        g.ATTR_MASK = g.ATTR_MASK | g.FIXL[g.SP];
        g.ATTRIBUTES = g.ATTRIBUTES | g.FIXV[g.SP];
    elif PRODUCTION_NUMBER == 388:  # reference 3880
        #  <SQ DQ NAME> ::= <DOUBLY QUAL NAME HEAD> <LITERAL EXP OR *> )
        g.CONTEXT = g.DECLARE_CONTEXT;
        g.I = g.FIXV[g.MPP1];  # VALUE
        g.TYPE = g.FIXL[g.MP];
        if g.TYPE == g.VEC_TYPE:
            if g.I == -1:
                ERROR(d.CLASS_DD, 7);
                g.I = 3;
            elif (g.I <= 1) or (g.I > g.VEC_LENGTH_LIM):
                ERROR(d.CLASS_DD, 5);
                g.I = 3;
            g.VEC_LENGTH = g.I;
        else:  # MATRIX
           if g.I == -1:
               ERROR(d.CLASS_DD, 9);
               g.I = 3;
           elif (g.I <= 1) or (g.I > g.MAT_DIM_LIM):
               ERROR(d.CLASS_DD, 4);
               g.I = 3;
           g.MAT_LENGTH = SHL(g.FIXV[g.MP], 8) + (g.I & 0xFF);
    elif PRODUCTION_NUMBER == 389:  # reference 3890
        #  <SQ DQ NAME> ::= INTEGER
        g.TYPE = g.INT_TYPE;
    elif PRODUCTION_NUMBER == 390:  # reference 3900
        #  <SQ DQ NAME> ::= SCALAR
        g.TYPE = g.SCALAR_TYPE;
    elif PRODUCTION_NUMBER == 391:  # reference 3910
        #  <SQ DQ NAME> ::= VECTOR
        g.TYPE = g.VEC_TYPE;
        g.VEC_LENGTH = g.DEF_VEC_LENGTH;
    elif PRODUCTION_NUMBER == 392:  # reference 3920
        #  <SQ DQ NAME> ::= MATRIX
        g.TYPE = g.MAT_TYPE;
        g.MAT_LENGTH = g.DEF_MAT_LENGTH;
    elif PRODUCTION_NUMBER == 393:  # reference 3930
        #  <DOUBLY QUAL NAME HEAD> ::= VECTOR (
        g.NOSPACE();
        g.FIXL[g.MP] = g.VEC_TYPE;
    elif PRODUCTION_NUMBER == 394:  # reference 3940
        #  <DOUBLY QUAL NAME HEAD>  ::=  MATRIX  (  <LITERAL EXP OR *>  ,
        g.NOSPACE();
        g.FIXL[g.MP] = g.MAT_TYPE;
        g.I = g.FIXV[g.MP + 2];
        g.FIXV[g.MP] = 3;  # DEFAULT IF BAD SPEC FOLLOWS
        if g.I == -1: 
            ERROR(d.CLASS_DD, 9);
        elif (g.I <= 1) or (g.I > g.MAT_DIM_LIM):
            ERROR(d.CLASS_DD, 4);
        else:
            g.FIXV[g.MP] = g.I;
    elif PRODUCTION_NUMBER == 395:  # reference 3950
        #  <LITERAL EXP OR *> ::= <ARITH EXP>
        g.PTR_TOP = g.PTR[g.MP] - 1;
        CHECK_ARRAYNESS();
        CHECK_IMPLICIT_T();
        if g.PSEUDO_FORM[g.PTR[g.SP]] != g.XLIT:
            ERROR(d.CLASS_VE, 1);
            g.TEMP = 0;
        else:
            g.TEMP = MAKE_FIXED_LIT(g.LOC_P[g.PTR[g.SP]]);
            if g.TEMP == -1:
                g.TEMP = 0;
        g.FIXV[g.SP] = g.TEMP;
    elif PRODUCTION_NUMBER == 396:  # reference 3960
        #  <LITERAL EXP OR *> ::= *
        g.FIXV[g.SP] = -1;
    elif PRODUCTION_NUMBER == 397:  # reference 3970
        #  <PREC_SPEC> ::= SINGLE
        g.FIXL[g.MP] = g.SD_FLAGS;
        g.FIXV[g.MP] = g.SINGLE_FLAG;
        g.PTR[g.MP] = 1;
    elif PRODUCTION_NUMBER == 398:  # reference 3980
        #  <PREC SPEC> ::= DOUBLE
        g.FIXL[g.MP] = g.SD_FLAGS;
        g.FIXV[g.MP] = g.DOUBLE_FLAG;
        g.PTR[g.MP] = 2;
    elif PRODUCTION_NUMBER == 399:  # reference 3990
        #  <MINOR ATTR LIST> ::= <MINOR ATTRIBUTE>
        goto = "INCORPORATE_ATTR"
    # reference 4000 relocated
    # reference 4010 relocated
    elif PRODUCTION_NUMBER == 402:  # reference 4020
        #  <MINOR ATTRIBUTE> ::= AUTOMATIC
        g.I = g.AUTO_FLAG;
        goto = "SET_AUTSTAT"
    elif PRODUCTION_NUMBER == 403:  # reference 4030
        #  <MINOR ATTRIBUTE> ::= DENSE
        if (g.TYPE == 0) and (g.BUILDING_TEMPLATE and (g.TYPE == g.BIT_TYPE) and \
                          ((g.ATTRIBUTES & g.ARRAY_FLAG) == 0) and \
                          (not g.NAME_IMPLIED)):
            g.FIXL[g.MP] = g.ALDENSE_FLAGS;
            g.FIXV[g.MP] = g.DENSE_FLAG;
    elif PRODUCTION_NUMBER == 404:  # reference 4040
        #  <MINOR ATTRIBUTE> ::= ALIGNED
        g.FIXL[g.MP] = g.ALDENSE_FLAGS;
        g.FIXV[g.MP] = g.ALIGNED_FLAG;
    elif PRODUCTION_NUMBER == 405:  # reference 4050
        #  <MINOR ATTRIBUTE> ::= ACCESS
        if g.BLOCK_MODE[g.NEST] == g.CMPL_MODE:
            g.FIXL[g.MP] = g.ACCESS_FLAG;
            g.FIXV[g.MP] = g.ACCESS_FLAG;
            g.ACCESS_FOUND = g.TRUE;
        else:
            ERROR(d.CLASS_DC, 5);
    elif PRODUCTION_NUMBER == 406:  # reference 4060
        #  <MINOR ATTRIBUTE>  ::=  LOCK ( <LITERAL EXP OR *> )
        g.CONTEXT = g.DECLARE_CONTEXT;
        g.LOCKp = g.FIXV[g.MP + 2];
        if g.LOCKp < 0: 
            g.LOCKp = 0xFF;
        elif g.LOCKp < 1 or g.LOCKp > g.LOCK_LIM:
            ERROR(d.CLASS_DL, 3);
            g.LOCKp = 0xFF;
        g.FIXL[g.MP] = g.LOCK_FLAG
        g.FIXV[g.MP] = g.LOCK_FLAG;
    elif PRODUCTION_NUMBER == 407:  # reference 4070
        #  <MINOR ATTRIBUTE>  ::=  REMOTE
        g.FIXL[g.MP], g.FIXV[g.MP] = g.REMOTE_FLAG;
    elif PRODUCTION_NUMBER == 408:  # reference 4080
        #  <MINOR ATTRIBUTE> ::= RIGID
        g.FIXL[g.MP] = g.RIGID_FLAG
        g.FIXV[g.MP] = g.RIGID_FLAG;
    # reference 4090 relocated
    elif PRODUCTION_NUMBER == 410:  # reference 4100
        #  <MINOR ATTRIBUTE> ::= <INIT/CONST HEAD> * )
        g.PSEUDO_TYPE[g.PTR[g.MP]] = 1;  # INDICATE "*" PRESENT
        goto = "DO_QUALIFIED_ATTRIBUTE"
    elif PRODUCTION_NUMBER == 411:  # reference 4110
        #  <MINOR ATTRIBUTE> ::= LATCHED
        g.FIXL[g.MP] = g.LATCHED_FLAG;
        g.FIXV[g.MP] = g.LATCHED_FLAG;
    elif PRODUCTION_NUMBER == 412:  # reference 4120
        #  <MINOR ATTRIBUTE>  ::=  NONHAL  (  <LEVEL>  )
        g.NONHAL = g.FIXV[g.MP + 2];
        #   DISCONNECT SYT_FLAGS FROM NONHAL; SET
        #   NONHAL IN SYT_FLAGS2 ARRAY.
        g.FIXL[g.MP] = g.NONHAL_FLAG;
        g.SYT_FLAGS2(g.ID_LOC, g.SYT_FLAGS2(g.ID_LOC) | g.NONHAL_FLAG);
        g.ATTRIBUTES2 = g.ATTRIBUTES2 | g.NONHAL_FLAG;
    # reference 4130 relocated
    elif PRODUCTION_NUMBER == 414:  # reference 4140
        #  <INIT/CONST HEAD> ::= CONSTANT (
        g.FIXL[g.MP] = g.INIT_CONST;
        g.FIXV[g.MP] = g.CONSTANT_FLAG;
        goto = "DO_INIT_CONST_HEAD"
    elif PRODUCTION_NUMBER == 415:  # reference 4150
        #  <INIT/CONST HEAD>  ::=  <INIT/CONST HEAD>  <REPEATED CONSTANT>  ,
        pass;
    elif PRODUCTION_NUMBER == 416:  # reference 4160
        #  <REPEATED CONSTANT>  ::=  <EXPRESSION>
        g.TEMP_SYN = 0;
        goto = "INIT_ELEMENT"
    elif PRODUCTION_NUMBER == 417:  # reference 4170
        #  <REPEATED CONSTANT>  ::=  <REPEAT HEAD>  <VARIABLE>
        g.TEMP_SYN = 1;
        goto = "INIT_ELEMENT"
    # reference 4180 relocated
    elif PRODUCTION_NUMBER == 419:  # reference 4190
        # <REPEATED CONSTANT>  ::=  <NESTED REPEAT HEAD>  <REPEATED CONSTANT>  )
        goto = "END_REPEAT_INIT"
    elif PRODUCTION_NUMBER == 420:  # reference 4200
        #  <REPEATED CONSTANT>  ::=  <REPEAT HEAD>
        g.IC_LINE = g.IC_LINE - 1;
        g.NUM_STACKS = g.NUM_STACKS - 1;
        g.NUM_FL_NO = g.NUM_FL_NO - 1;
        g.NUM_ELEMENTS = g.NUM_ELEMENTS + g.INX[g.PTR[g.MP]];
        g.PTR_TOP = g.PTR[g.MP] - 1;
    elif PRODUCTION_NUMBER == 421:  # reference 4210
        #  <REPEAT HEAD>  ::=  <ARITH EXP>  #
        CHECK_ARRAYNESS();
        if g.PSEUDO_FORM[g.PTR[g.MP]] != g.XLIT: 
            g.TEMP_SYN = 0;
        else:
            g.TEMP_SYN = MAKE_FIXED_LIT(g.LOC_P[g.PTR[g.MP]]);
        if g.TEMP_SYN < 1: 
            ERROR(d.CLASS_DI, 1);
            g.TEMP_SYN = 0;
        if g.TEMP_SYN > g.NUM_EL_MAX: 
            g.TEMP_SYN = g.NUM_EL_MAX;
        g.INX[g.PTR[g.MP]] = g.TEMP_SYN;
        g.FIXV[g.MP] = g.NUM_ELEMENTS;
        g.NUM_FL_NO = g.NUM_FL_NO + 1;
        SET_INIT(g.TEMP_SYN, 1, 0, 0, g.NUM_FL_NO);
        g.FIXL[g.MP] = g.IC_LINE;
        g.NUM_STACKS = g.NUM_STACKS + 1;
    elif PRODUCTION_NUMBER == 422:  # reference 4220
        #  <NESTED REPEAT HEAD>  ::=  <REPEAT HEAD>  (
        pass;
    elif PRODUCTION_NUMBER == 423:  # reference 4230
        #  <NESTED REPEAT HEAD>  ::=  <NESTED REPEAT HEAD>  <REPEATED CONSTANT>  ,
        pass;
    # reference 4240 relocated
    elif PRODUCTION_NUMBER == 425:  # reference 4250
        #  <CONSTANT>  ::=  <COMPOUND NUMBER>
        g.TEMP_SYN = g.SCALAR_TYPE;
        goto = "DO_CONSTANT"
    elif PRODUCTION_NUMBER == 426:  # reference 4260
        #  <CONSTANT>  ::=  <BIT CONST>
        pass;
    elif PRODUCTION_NUMBER == 427:  # reference 4270
        #  <CONSTANT>  ::=  <CHAR CONST>
        pass;
    elif PRODUCTION_NUMBER == 428:  # reference 4280
        #  <NUMBER> ::= <SIMPLE NUMBER>
        pass
    elif PRODUCTION_NUMBER == 429:  # reference 4290
        #  <NUMBER> ::= <LEVEL>
        pass
    # reference 4300 relocated
    elif PRODUCTION_NUMBER == 431:  # reference 4310
        #  <CLOSING> ::= CLOSE <LABEL>
        g.VAR[g.MP] = g.VAR[g.SP];
        goto = "CLOSE_IT"
    elif PRODUCTION_NUMBER == 432:  # reference 4320
        #  <CLOSING> ::= <LABEL DEFINITION> <CLOSING>
        SET_LABEL_TYPE(g.FIXL[g.MP], g.STMT_LABEL);
        g.VAR[g.MP] = g.VAR[g.SP];
    elif PRODUCTION_NUMBER == 433:  # reference 4330
        # <TERMINATOR>::= TERMINATE
        g.FIXL[g.MP] = XTERM;
        g.FIXV[g.MP] = 0xE000;
    elif PRODUCTION_NUMBER == 434:  # reference 4340
        # <TERMINATOR>::= CANCEL
        g.FIXL[g.MP] = XCANC;
        g.FIXV[g.MP] = 0xA000;
    elif PRODUCTION_NUMBER == 435:  # reference 4350
        #  <TERMINATE LIST>  ::=  <LABEL VAR>
        g.EXT_P[g.PTR[g.MP]] = 1;
        goto = "TERM_LIST"
    # reference 4360 relocated
    elif PRODUCTION_NUMBER == 437:  # reference 4370
        # <WAIT KEY>::= WAIT
        g.REFER_LOC = 1;
    elif PRODUCTION_NUMBER == 438:  # reference 4380
        #  <SCHEDULE HEAD>  ::=  SCHEDULE  <LABEL VAR>
        PROCESS_CHECK(g.MPP1);
        if (g.SYT_FLAGS(g.FIXL[g.MPP1]) & g.ACCESS_FLAG) != 0:
            ERROR(d.CLASS_PS, 5, g.VAR[g.MPP1]);
        SET_XREF_RORS(g.MPP1, 0x6000);
        g.PTR[g.MP] = g.PTR[g.MPP1];
        g.REFER_LOC = g.PTR[g.MPP1]
        g.INX[g.REFER_LOC] = 0;
    # reference 4390 relocated
    elif PRODUCTION_NUMBER == 440:  # reference 4400
        # <SCHEDULE HEAD>::= <SCHEDULE HEAD> IN <ARITH EXP>
        g.TEMP = 0x2;
        if UNARRAYED_SCALAR(g.SP): 
            ERROR(d.CLASS_RT, 1, 'IN');
        goto = "SCHEDULE_AT"
    elif PRODUCTION_NUMBER == 441:  # reference 4410
        # <SCHEDULE HEAD>::=<SCHEDULE HEAD> ON <BIT EXP>
        g.TEMP = 0x3;
        if CHECK_EVENT_EXP(g.SP): 
            ERROR(d.CLASS_RT, 3, 'ON');
        goto = "SCHEDULE_AT"
    # reference 4420 relocated
    elif PRODUCTION_NUMBER == 443:  # reference 4430
        # <SCHEDULE PHRASE>::=<SCHEDULE HEAD> PRIORITY (<ARITH EXP>)
        if UNARRAYED_INTEGER(g.SP - 1): 
            goto = "SCHED_PRIO"
        g.INX[g.REFER_LOC] = g.INX[g.REFER_LOC] | 0x4;
    elif PRODUCTION_NUMBER == 444:  # reference 4440
        #  <SCHEDULE PHRASE>  ::=  <SCHEDULE PHRASE>  DEPENDENT
        g.INX[g.REFER_LOC] = g.INX[g.REFER_LOC] | 0x8;
    elif PRODUCTION_NUMBER == 445:  # reference 4450
        # <SCHEDULE CONTROL>::= <STOPPING>
        pass;
    elif PRODUCTION_NUMBER == 446:  # reference 4460
        # <SCHEDULE CONTROL>::= <TIMING>
        pass;
    elif PRODUCTION_NUMBER == 447:  # reference 4470
        # <SCHEDULE CONTROL>::= <TIMING><STOPPING>
        pass;
    # reference 4480 relocated
    elif PRODUCTION_NUMBER == 449:  # reference 4490
        #  <TIMING>  ::=  <REPEAT> AFTER <ARITH EXP>
        g.TEMP = 0x30;
        goto = "SCHEDULE_EVERY"
    elif PRODUCTION_NUMBER == 450:  # reference 4500
        #  <TIMING>  ::=  <REPEAT>
        g.INX[g.REFER_LOC] = g.INX[g.REFER_LOC] | 0x10;
    elif PRODUCTION_NUMBER == 451:  # reference 4510
        #  <REPEAT>  ::=  , REPEAT
        g.CONTEXT = 0;
    elif PRODUCTION_NUMBER == 452:  # reference 4520
        # <STOPPING>::=<WHILE KEY><ARITH EXP>
        if g.FIXL[g.MP] == 0: 
            ERROR(d.CLASS_RT, 2);
        elif UNARRAYED_SCALAR(g.SP): 
            ERROR(d.CLASS_RT, 1, 'UNTIL');
        g.INX[g.REFER_LOC] = g.INX[g.REFER_LOC] | 0x40;
    elif PRODUCTION_NUMBER == 453:  # reference 4530
        # <STOPPING>::=<WHILE KEY><BIT EXP>
        # DO;
        if CHECK_EVENT_EXP(g.SP): ERROR(d.CLASS_RT, 3, 'WHILE/UNTIL');
        g.TEMP = SHL(g.FIXL[g.MP] + 2, 6);
        g.INX[g.REFER_LOC] = g.INX[g.REFER_LOC] | g.TEMP;
        # END;
    elif PRODUCTION_NUMBER == 454:  # reference 4540
        pass  #  INSURANCE
    elif PRODUCTION_NUMBER == 455:  # reference 4550
        pass  #  INSURANCE
    elif PRODUCTION_NUMBER == 456:  # reference 4560
        pass  #  INSURANCE
    elif PRODUCTION_NUMBER == 457:  # reference 4570
        pass  #  INSURANCE
    elif PRODUCTION_NUMBER == 458:  # reference 4580
        pass  #  INSURANCE
    
    #----------------------------------------------------------------------
    # The following cases have all been relocated from their original 
    # positions to facilitate fallthrough from GO TO statements with
    # minimal rearrangement of the cases.  These are all cases containing
    # labels which are jump targets.
    
    # Reference 110 is treated specially, since it has several GO TO's
    # to internal labels.
    while goto in ["COMBINE_SCALARS_AND_VECTORS", "CROSS_PRODUCTS", 
                   "DOT_PRODUCTS_LOOP"] or \
                   (goto == None and PRODUCTION_NUMBER == 11):  # reference 110
        #  <PRODUCT> ::= <FACTOR>
        
        if goto == None:
            PRODUCTION_NUMBER = -1
            g.CROSS_COUNT = 0
            g.DOT_COUNT = 0
            g.SCALAR_COUNT = 0
            g.VECTOR_COUNT = 0
            g.MATRIX_COUNT = 0;
            g.TERMP = g.SP + 1;
            while g.TERMP > 0:
                g.TERMP = g.TERMP - 1;
                if g.PARSE_STACK[g.TERMP] == g.CROSS_TOKEN:
                    g.CROSS_COUNT = g.CROSS_COUNT + 1;
                    g.FIXV[g.TERMP] = g.CROSS;
                elif g.PARSE_STACK[g.TERMP] == g.DOT_TOKEN:
                    g.DOT_COUNT = g.DOT_COUNT + 1;
                    g.FIXV[g.TERMP] = g.DOT;
                elif g.PARSE_STACK[g.TERMP] == g.FACTOR:
                    c = 0x0F & g.PSEUDO_TYPE[g.PTR[g.TERMP]]
                    # DO CASE 0x0F & PSEUDO_TYPE[PTR[TERMP]];
                    if c == 0:  # 0 IS DUMMY
                        pass
                    elif c == 1:  # 1 IS BIT
                        pass
                    elif c == 2:  # 2 IS CHAR
                        pass
                    elif c == 3:
                        g.MATRIX_COUNT = g.MATRIX_COUNT + 1;
                        g.FIXV[g.TERMP] = g.MAT_TYPE;
                    elif c == 4:
                        g.VECTOR_COUNT = g.VECTOR_COUNT + 1;
                        g.FIXV[g.TERMP] = g.VEC_TYPE;
                    elif c in (5, 6):  # TYPE 6 IS INTEGER
                        g.SCALAR_COUNT = g.SCALAR_COUNT + 1;
                        g.FIXV[g.TERMP] = g.SCALAR_TYPE;
                else:
                    g.MP = g.TERMP + 1;  # IT WAS DECREMENTED AT START OF LOOP
                    g.TERMP = 0;  # GET OUT OF LOOP
            g.TERMP = g.MP;
            #print("\n!@", g.SCALAR_COUNT, 
            #       g.FIXV[g.MP], g.FIXV[g.SP], g.MP, g.SP, 
            #       g.PTR[g.MP], g.PTR[g.SP],
            #       file=sys.stderr)
        
            if g.TERMP == g.SP: 
                return;
            
            #  MULTIPLY ALL SCALARS, PLACE RESULT AT SCALARP
            g.SCALARP = 0;
            g.PP = g.TERMP - 1;
            while g.SCALAR_COUNT > 0:
                g.PP = g.PP + 1;
                if g.FIXV[g.PP] == g.SCALAR_TYPE:
                    g.SCALAR_COUNT = g.SCALAR_COUNT - 1;
                    if g.SCALARP == 0: 
                        g.SCALARP = g.PP;
                    else:
                        MULTIPLY_SYNTHESIZE(g.SCALARP, g.PP, g.SCALARP, 0);
            
            # PRODUCTS WITHOUT VECTORS HANDLED HERE
            if g.VECTOR_COUNT == 0:
                if g.CROSS_COUNT + g.DOT_COUNT > 0:
                    ERROR(d.CLASS_E, 4);
                    g.PTR_TOP = g.PTR[g.MP];
                    return;
                if g.MATRIX_COUNT == 0:
                    g.PTR_TOP = g.PTR[g.MP];
                    return;
                #  MULTIPLY MATRIX PRODUCTS
                g.MATRIXP = 0;
                g.PP = g.TERMP - 1;
                while g.MATRIX_COUNT > 0:
                    g.PP = g.PP + 1;
                    if g.FIXV[g.PP] == g.MAT_TYPE:
                        g.MATRIX_COUNT = g.MATRIX_COUNT - 1;
                        if g.MATRIXP == 0: 
                            g.MATRIXP = g.PP;
                        else: 
                            MULTIPLY_SYNTHESIZE(g.MATRIXP, g.PP, g.MATRIXP, 8);
                if g.SCALARP != 0: 
                    MULTIPLY_SYNTHESIZE(g.MATRIXP, g.SCALARP, g.TERMP, 2);
                g.PTR_TOP = g.PTR[g.MP];
                return;
        
            # PRODUCTS WITH VECTORS TAKE UP THE REST OF THIS REDUCTION
            
            #  FIRST MATRICES ARE PULLED INTO VECTORS
            if g.MATRIX_COUNT == 0: 
                goto = "MATRICES_TAKEN_CARE_OF"
            else:
                g.BEGINP = g.TERMP;
                goto = "MATRICES_MAY_GO_RIGHT"
                while goto == "MATRICES_MAY_GO_RIGHT":
                    if goto == "MATRICES_MAY_GO_RIGHT": goto = None
                    g.MATRIX_PASSED = 0;
                    g.PP = g.BEGINP
                    for g.PP in range(g.BEGINP, g.SP + 1):
                        if g.FIXV[g.PP] == g.MAT_TYPE: 
                            g.MATRIX_PASSED = g.MATRIX_PASSED + 1; 
                        elif g.FIXV[g.PP] == g.DOT or g.FIXV[g.PP] == g.CROSS: 
                            g.MATRIX_PASSED = 0; 
                        elif g.FIXV[g.PP] == g.VEC_TYPE:
                            #  THIS ILLEGAL SYNTAX WILL BE CAUGHT ELSEWHERE
                            g.PPTEMP = g.PP;
                            while g.MATRIX_PASSED > 0:
                                g.PPTEMP = g.PPTEMP - 1;
                                if g.FIXV[g.PPTEMP] == g.MAT_TYPE:
                                    g.MATRIX_PASSED = g.MATRIX_PASSED - 1;
                                    MULTIPLY_SYNTHESIZE(g.PPTEMP, g.PP, g.PP, 7);
                            for g.PPTEMP in range(g.PP + 1, g.SP + 1):
                                if g.FIXV[g.PPTEMP] == g.MAT_TYPE:
                                    MULTIPLY_SYNTHESIZE(g.PP, g.PPTEMP, g.PP, 6); 
                                if g.FIXV[g.PPTEMP] == g.VEC_TYPE: 
                                    g.PP = g.PPTEMP;  
                                elif g.FIXV[g.PPTEMP] == g.DOT or g.FIXV[g.PPTEMP] == g.CROSS:
                                    g.BEGINP = g.PPTEMP + 1;
                                    goto = "MATRICES_MAY_GO_RIGHT"
                                    break
                            if goto != None:
                                break
                    if goto != None:
                        continue
        
        if goto in [None, "MATRICES_TAKEN_CARE_OF", "COMBINE_SCALARS_AND_VECTORS"]:
            if goto == "MATRICES_TAKEN_CARE_OF": goto = None
            # PRODUCTS WITHOUT DOT OR CROSS COME NEXT
            if (g.DOT_COUNT + g.CROSS_COUNT) > 0 and goto == None: 
                goto = "CROSS_PRODUCTS"
                # Just falls through.
            else:
                if goto == None:
                    if g.VECTOR_COUNT > 2:
                        ERROR(d.CLASS_EO, 1);
                        g.PTR_TOP = g.PTR[g.MP];
                        return;
                    for g.PP in range(g.MP, g.SP + 1):
                       if g.FIXV[g.PP] == g.VEC_TYPE:
                            g.VECTORP = g.PP;
                            g.PP = g.SP + 1;
                            break
                if goto == "COMBINE_SCALARS_AND_VECTORS": goto = None
                if g.SCALARP != 0:
                    MULTIPLY_SYNTHESIZE(g.VECTORP, g.SCALARP, g.TERMP, 1);  
                elif g.VECTORP != g.MP:
                    #   THIS BLOCK OF CODE PUTS THE INDIRECT STACK INFORMATION FOR THE
                    #   ENTIRE PRODUCT IN THE FIRST OF THE INDIRECT STACK ENTRIES ALOTTED
                    #   TO THE ENTIRE PRODUCT, IN CASE THE FINAL MULTIPLY DOESN'T DO SO
                    g.PTR_TOP = g.PTR[g.MP];
                    g.INX[g.PTR_TOP] = g.INX[g.PTR[g.VECTORP]];
                    g.LOC_P[g.PTR_TOP] = g.LOC_P[g.PTR[g.VECTORP]];
                    g.VAL_P[g.PTR_TOP] = g.VAL_P[g.PTR[g.VECTORP]];
                    g.PSEUDO_TYPE[g.PTR_TOP] = g.PSEUDO_TYPE[g.PTR[g.VECTORP]];
                    g.PSEUDO_FORM[g.PTR_TOP] = g.PSEUDO_FORM[g.PTR[g.VECTORP]];
                    g.PSEUDO_LENGTH[g.PTR_TOP] = g.PSEUDO_LENGTH[g.PTR[g.VECTORP]];
                if g.VECTOR_COUNT == 1:
                    g.PTR_TOP = g.PTR[g.MP];
                    return;
                #  VECTOR_COUNT SHOULD BE 2 HERE
                for g.PP in range(g.VECTORP + 1, g.SP + 1):
                    if g.FIXV[g.PP] == g.VEC_TYPE:
                        MULTIPLY_SYNTHESIZE(g.TERMP, g.PP, g.TERMP, 5);
                        g.PTR_TOP = g.PTR[g.MP];
                        return;
        
        if goto in [None, "CROSS_PRODUCTS"]:
            if goto == "CROSS_PRODUCTS": goto = None
            while g.CROSS_COUNT > 0:
                g.VECTORP = 0;
                g.PP = g.MP
                for g.PP in range(g.MP, 1 + g.SP):
                    if g.FIXV[g.PP] == g.VEC_TYPE: 
                        g.VECTORP = g.PP;
                    elif g.FIXV[g.PP] == g.DOT: 
                        g.VECTORP = 0;
                    elif g.FIXV[g.PP] == g.CROSS:
                        if g.VECTORP == 0:
                            ERROR(d.CLASS_EC, 3);
                            g.PTR_TOP = g.PTR[g.MP];
                            return;
                        else:
                            for PPTEMP in range(g.PP + 1, 1 + g.SP):
                                if g.FIXV[PPTEMP] == g.VEC_TYPE:
                                    MULTIPLY_SYNTHESIZE(g.VECTORP, PPTEMP, g.VECTORP, 4);
                                    g.FIXV[g.PP] = 0;
                                    g.CROSS_COUNT = g.CROSS_COUNT - 1;
                                    g.FIXV[PPTEMP] = 0;
                                    g.VECTOR_COUNT = g.VECTOR_COUNT - 1;
                                    goto = "CROSS_PRODUCTS";
                                    break
                            if goto == "CROSS_PRODUCTS":
                                break
                        ERROR(d.CLASS_EC, 2);
                        g.PTR_TOP = g.PTR[g.MP];
                        return;
                if goto == "CROSS_PRODUCTS":
                    break;
            if goto == "CROSS_PRODUCTS":
                continue
            
            if g.DOT_COUNT > 0: 
                # GO TO DOT_PRODUCTS;
                # Fortunately, we need no goto == "XXXX"; it can just fall through.
                pass
            else:
                if g.VECTOR_COUNT > 1:
                    ERROR(d.CLASS_EO, 2);
                    g.PTR_TOP = g.PTR[g.MP];
                    return;
                # IF YOU GET TO THIS GOTO, VECTOR_COUNT HAD BETTER BE 1
                goto = "COMBINE_SCALARS_AND_VECTORS"
                continue
            
            # DOT_PRODUCTS:
            g.BEGINP = g.TERMP;
        if goto == "DOT_PRODUCTS_LOOP": goto = None
        while g.DOT_COUNT > 0:
            g.VECTORP = 0;
            g.PP = g.BEGINP
            for g.PP in range(g.BEGINP, 1 + g.SP):
                if g.FIXV[g.PP] == g.VEC_TYPE: 
                    g.VECTORP = g.PP;
                if g.FIXV[g.PP] == g.DOT:
                    if g.VECTORP == 0:
                        ERROR(d.CLASS_ED, 2);
                        g.PTR_TOP = g.PTR[g.MP];
                        return;
                    else:
                        for PPTEMP in range(g.PP + 1, 1 + g.SP):
                            if g.FIXV[PPTEMP] == g.VEC_TYPE:
                                MULTIPLY_SYNTHESIZE(g.VECTORP, PPTEMP, g.VECTORP, 3);
                                if g.SCALARP == 0: 
                                    g.SCALARP = g.VECTORP; 
                                else:
                                    MULTIPLY_SYNTHESIZE(g.SCALARP, g.VECTORP, g.SCALARP, 0);
                                g.BEGINP = PPTEMP + 1;
                                g.DOT_COUNT = g.DOT_COUNT - 1;
                                g.FIXV[g.VECTORP] = 0;
                                g.FIXV[PPTEMP] = 0;
                                g.VECTOR_COUNT = g.VECTOR_COUNT - 2;
                                goto = "DOT_PRODUCTS_LOOP"
                                break
                        if goto == "DOT_PRODUCTS_LOOP":
                            break
                        # If we got to here, the for-loop terminated normally.
                        # But that will mean that the loop index is one too 
                        # small (because of differences in XPL vs Python loop
                        # handling).
                        g.PP += 1
                    ERROR(d.CLASS_ED, 1);
                    g.PTR_TOP = g.PTR[g.MP];
                    return;
            if goto == "DOT_PRODUCTS_LOOP":
                break
        if goto == "DOT_PRODUCTS_LOOP":
            continue
        if g.VECTOR_COUNT > 0:
            ERROR(d.CLASS_EO, 3);
            g.PTR_TOP = g.PTR[g.MP];
            return;
        # VECTOR_COUNT MUST BE 0 HERE
        if g.SCALARP == g.MP:
            g.PTR_TOP = g.PTR[g.MP];
            return;
        #   KLUDGE TO USE CODE IN ANOTHER SECTION OF THIS CASE
        g.VECTORP = g.SCALARP;
        g.VECTOR_COUNT = 1;
        g.SCALARP = 0;
        goto = "COMBINE_SCALARS_AND_VECTORS"
        continue
        
    if goto == "INLINE_SCOPE" or \
            (goto == None and PRODUCTION_NUMBER == 30):  # reference 300
        #  <PRIMARY>  ::=  <ARITH INLINE DEF>  <BLOCK BODY>  <CLOSING>  ;
        if goto == "INLINE_SCOPE": goto = None
        g.TEMP2 = g.INLINE_LEVEL;
        g.TEMP = XICLS;
        g.GRAMMAR_FLAGS(g.STACK_PTR[g.SP], \
                        g.GRAMMAR_FLAGS(g.STACK_PTR[g.SP]) | g.INLINE_FLAG);
        goto = "CLOSE_SCOPE"
    if goto == "WAIT_TIME" or \
            (goto == None and PRODUCTION_NUMBER == 62):  # reference 620
        # <BASIC STATEMENT>::= <WAIT KEY><ARITH EXP>;
        if not goto == "WAIT_TIME":
            g.TEMP = 1;
            if UNARRAYED_SCALAR(g.SP - 1): 
                ERROR(d.CLASS_RT, 6, 'WAIT');
        if goto == "WAIT_TIME": goto = None
        g.XSET(0xB);
        HALMAT_TUPLE(g.XWAIT, 0, g.SP - 1, 0, g.TEMP);
        g.PTR_TOP = g.PTR[g.SP - 1] - 1;
        goto = "UPDATE_CHECK"
    if goto == "UP_PRIO" or \
            (goto == None and PRODUCTION_NUMBER == 67):  # reference 670
        # <BASIC STATEMENT>::= UPDATE PRIORITY TO <ARITH EXP>;
        if not goto == "UP_PRIO":
            g.PTR_TOP = g.PTR[g.SP - 1] - 1;
            g.TEMP = 0;
        if goto == "UP_PRIO": goto = None
        g.XSET(0xC);
        if UNARRAYED_INTEGER(g.SP - 1):
            ERROR(d.CLASS_RT, 4, 'UPDATE PRIORITY');
        HALMAT_TUPLE(g.XPRIO, 0, g.SP - 1, g.TEMP, g.TEMP > 0);
        goto = "UPDATE_CHECK"
    if goto == "SCHEDULE_EMIT" or \
            (goto == None and PRODUCTION_NUMBER == 69):  # reference 690
        # <BASIC STATEMENT>::= <SCHEDULE PHRASE>;
        if goto == "SCHEDULE_EMIT": goto = None
        g.XSET(0x9);
        HALMAT_POP(g.XSCHD, g.PTR_TOP - g.REFER_LOC + 1, 0, g.INX[g.REFER_LOC]);
        while g.REFER_LOC <= g.PTR_TOP:
            HALMAT_PIP(g.LOC_P[g.REFER_LOC], g.PSEUDO_FORM[g.REFER_LOC], 0, 0);
            g.REFER_LOC = g.REFER_LOC + 1;
        g.PTR_TOP = g.PTR[g.MP] - 1;
        goto = "UPDATE_CHECK"
    if goto == "UPDATE_CHECK" or \
            (goto == None and PRODUCTION_NUMBER == 61):  # reference 610
        # <BASIC STATEMENT>  ::=  <WAIT KEY>  FOR DEPENDENT ;
        if not goto == "UPDATE_CHECK":
            HALMAT_POP(g.XWAIT, 0, 0, 0);
            g.XSET(0xB);
        if goto == "UPDATE_CHECK": goto = None
        if g.UPDATE_BLOCK_LEVEL > 0: 
            ERROR(d.CLASS_RU, 1);
        if g.INLINE_LEVEL > 0: 
            ERROR(d.CLASS_PP, 6);
        g.REFER_LOC = 0;
        goto = "FIX_NOLAB"
    if goto == "EXITTING" or \
            (goto == None and PRODUCTION_NUMBER == 42):  # reference 420
        # <BASIC STATEMENT>::= EXIT ;
        if goto == "EXITTING": goto = None
        g.TEMP = g.DO_LEVEL;
        while g.TEMP > 1:
            if SHR(g.DO_INX[g.TEMP], 7) & 1: 
                ERROR(d.CLASS_GE, 3);
            if LABEL_MATCH(): 
                HALMAT_POP(g.XBRA, 1, 0, 0);
                HALMAT_PIP(g.DO_LOC[g.TEMP], g.XINL, 0, 0);
                g.TEMP = 1;
            g.TEMP = g.TEMP - 1;
        if g.TEMP == 1: 
            ERROR(d.CLASS_GE, 1);
        g.XSET(0x01);
        goto = "FIX_NOLAB"
    if goto == "REPEATING" or \
            (goto == None and PRODUCTION_NUMBER == 44):  # reference 440
        # <BASIC STATEMENT>::= REPEAT ;
        if goto == "REPEATING": goto = None
        g.TEMP = g.DO_LEVEL;
        while g.TEMP > 1:
            if SHR(g.DO_INX[g.TEMP], 7) & 1: 
                ERROR(d.CLASS_GE, 4);
            if g.DO_INX[g.TEMP]: 
                if LABEL_MATCH():
                    HALMAT_POP(g.XBRA, 1, 0, 0);
                    HALMAT_PIP(g.DO_LOC[g.TEMP] + 1, g.XINL, 0, 0);
                    g.TEMP = 1;
            g.TEMP = g.TEMP - 1;
        if g.TEMP == 1: 
            ERROR(d.CLASS_GE, 2);
        g.XSET(0x801);
        goto = "FIX_NOLAB"
    if goto == "IO_EMIT" or \
            (goto == None and PRODUCTION_NUMBER == 55):  # reference 550
        # <BASIC STATEMENT>::= <READ KEY>;
        if goto == "IO_EMIT": goto = None
        g.XSET(0x3);
        HALMAT_TUPLE(g.XREAD[g.INX[g.PTR[g.MP]]], 0, g.MP, 0, 0);
        g.PTR_TOP = g.PTR[g.MP] - 1;
        HALMAT_POP(g.XXXND, 0, 0, 0);
        goto = "FIX_NOLAB"
    if goto == "FIX_NOLAB" or \
            (goto == None and PRODUCTION_NUMBER == 47):  # reference 470
        # <BASIC STATEMENT>::= ;
        if goto == "FIX_NOLAB": goto = None
        g.FIXF[g.MP] = 0;
    if goto == "ARITH_LITS" or \
            (goto == None and PRODUCTION_NUMBER == 19):  # reference 190
        #  <PRE PRIMARY> ::= <NUMBER>
        if goto == None:
            g.TEMP = g.INT_TYPE;
        if goto == "ARITH_LITS": goto = None
        g.PTR[g.MP] = PUSH_INDIRECT(1);
        g.LOC_P[g.PTR[g.MP]] = g.FIXL[g.MP];
        g.PSEUDO_FORM[g.PTR[g.MP]] = g.XLIT ;
        g.PSEUDO_TYPE[g.PTR[g.MP]] = g.TEMP;
    if goto == "LABEL_INCORP" or \
            (goto == None and PRODUCTION_NUMBER == 35):  # reference 350
        #  <OTHER STATEMENT>  ::= <LABEL DEFINITION> <OTHER STATEMENT>
        if goto == "LABEL_INCORP": goto = None
        if g.FIXL[g.MP] != g.FIXF[g.SP]: 
            g.SYT_PTR(g.FIXL[g.MP], g.FIXF[g.SP]);
        g.FIXF[g.MP] = g.FIXL[g.MP];
        g.PTR[g.MP] = g.PTR[g.MPP1];
        SET_LABEL_TYPE(g.FIXL[g.MP], g.STMT_LABEL);
    if goto == "NON_EVENT" or \
            (goto == None and PRODUCTION_NUMBER == 82):  # reference 820
        #  <BIT PRIM>  ::=  <BIT VAR>
        if not goto == "NON_EVENT":
            SET_XREF_RORS(g.MP);
        if goto == "NON_EVENT": goto = None
        g.INX[g.PTR[g.MP]] = g.FALSE;
    if goto == "YES_EVENT" or \
            (goto == None and PRODUCTION_NUMBER == 83):  # reference 830
        #  <BIT PRIM>  ::=  <LABEL VAR>
        if goto == None:
            SET_XREF_RORS(g.MP, 0x2000);
            g.TEMP = g.PSEUDO_TYPE[g.PTR[g.MP]];
            if (g.TEMP == g.TASK_LABEL) or (g.TEMP == g.PROG_LABEL):
                pass;
            else:
                ERROR(d.CLASS_RT, 14, g.VAR[g.MP]);
            if g.REFER_LOC > 0: 
                g.INX[g.PTR[g.MP]] = 1;
            else:
                g.INX[g.PTR[g.MP]] = 2;
        if goto == "YES_EVENT": goto = None
        g.PSEUDO_TYPE[g.PTR[g.MP]] = g.BIT_TYPE;
        g.PSEUDO_LENGTH[g.PTR[g.MP]] = 1;
    if goto == "DO_BIT_CAT" or \
            (goto == None and PRODUCTION_NUMBER == 94):  # reference 940
        #  <BIT CAT>  ::=  <BIT CAT>  <CAT>  <BIT PRIM>
        if goto == "DO_BIT_CAT": goto = None
        g.INX[g.PTR[g.MP]] = g.FALSE;
        g.TEMP = g.PSEUDO_LENGTH[g.PTR[g.MP]] + g.PSEUDO_LENGTH[g.PTR[g.SP]];
        if g.TEMP > g.BIT_LENGTH_LIM:
            g.TEMP = g.BIT_LENGTH_LIM;
            ERROR(d.CLASS_EB, 1);
        HALMAT_TUPLE(g.XBCAT, 0, g.MP, g.SP, 0);
        SETUP_VAC(g.MP, g.BIT_TYPE, g.TEMP);
        g.PTR_TOP = g.PTR[g.MP];
    if goto in ["DO_LIT_BIT_FACTOR", "DO_BIT_FACTOR"] or \
            (goto == None and PRODUCTION_NUMBER == 98):  # reference 980
        #   <BIT FACTOR> ::= <BIT FACTOR> <AND> <BIT CAT>
        if goto == "DO_LIT_BIT_FACTOR" or \
                (BIT_LITERAL(g.MP, g.SP) and goto == None): 
            if not goto == "DO_LIT_BIT_FACTOR":
                g.TEMP = g.FIXV[g.MP] & g.FIXV[g.SP];
            if goto == "DO_LIT_BIT_FACTOR": goto = None
            if g.PSEUDO_LENGTH[g.PTR[g.MP]] != g.PSEUDO_LENGTH[g.PTR[g.SP]]:
                ERROR(d.CLASS_YE, 100);
            g.TEMP2 = g.PSEUDO_LENGTH[g.PTR[g.MP]];
            if g.TEMP2 < g.PSEUDO_LENGTH[g.PTR[g.SP]]: 
                g.TEMP2 = g.PSEUDO_LENGTH[g.PTR[g.SP]];
            g.LOC_P[g.PTR[g.MP]] = SAVE_LITERAL(2, g.TEMP, g.TEMP2);
        else:
            if not goto == "DO_BIT_FACTOR":
                g.TEMP = g.XBAND ;
            if goto == "DO_BIT_FACTOR": goto = None
            g.TEMP2 = g.INX[g.PTR[g.MP]] & g.INX[g.PTR[g.SP]] & 1;
            HALMAT_TUPLE(g.TEMP, 0, g.MP, g.SP, g.TEMP2);
            g.INX[g.PTR[g.MP]] = g.TEMP2;
            g.TEMP = g.PSEUDO_LENGTH[g.PTR[g.MP]];
            if g.TEMP < g.PSEUDO_LENGTH[g.PTR[g.SP]]:
                g.TEMP = g.PSEUDO_LENGTH[g.PTR[g.SP]];
            SETUP_VAC(g.MP, g.BIT_TYPE, g.TEMP);
        g.PTR_TOP = g.PTR[g.MP];
    if goto == "EMIT_REL" or \
            (goto == None and PRODUCTION_NUMBER == 109):  # reference 1090
        #  <COMPARISON> ::= <ARITH EXP> <RELATIONAL OP> <ARITH EXP>
        if goto == None:
            MATCH_ARITH(g.MP, g.SP);
            # DO CASE PSEUDO_TYPE[PTR[MP]]-MAT_TYPE;
            pt = g.PSEUDO_TYPE[g.PTR[g.MP]] - g.MAT_TYPE
            if pt == 0:
                g.TEMP = g.XMEQU[g.REL_OP];
                g.VAR[g.MP] = 'MATRIX';
            elif pt == 1:
                g.TEMP = g.XVEQU[g.REL_OP];
                g.VAR[g.MP] = 'VECTOR';
            elif pt == 2:
                g.TEMP = g.XSEQU[g.REL_OP];
                g.VAR[g.MP] = '';
            elif pt == 3:
                g.TEMP = g.XIEQU[g.REL_OP];
                g.VAR[g.MP] = '';
        if goto == "EMIT_REL": goto = None
        HALMAT_TUPLE(g.TEMP, g.XCO_N, g.MP, g.SP, 0);
    if goto == "DO_CHAR_CAT" or \
            (goto == None and PRODUCTION_NUMBER == 132):  # reference 1320
        # <CHAR EXP> ::= <CHAR EXP> <CAT> <CHAR PRIM>
        if CHAR_LITERAL(g.MP, g.SP) and goto == None:
            g.TEMP = g.CHAR_LENGTH_LIM - LENGTH(g.VAR[g.MP]);
            if g.TEMP < LENGTH(g.VAR[g.SP]):
                g.VAR[g.SP] = SUBSTR(g.VAR[g.SP], 0, g.TEMP);
                ERROR(d.CLASS_VC, 1);
            g.VAR[g.MP] = g.VAR[g.MP] + g.VAR[g.SP];
            g.LOC_P[g.PTR[g.MP]] = SAVE_LITERAL(0, g.VAR[g.MP]);
            g.PSEUDO_LENGTH[g.PTR[g.MP]] = LENGTH(g.VAR[g.MP]);
        else:
            if goto == "DO_CHAR_CAT": goto = None
            HALMAT_TUPLE(g.XCCAT, 0, g.MP, g.SP, 0);
            SETUP_VAC(g.MP, g.CHAR_TYPE);
        g.PTR_TOP = g.PTR[g.MP];
    if goto in ["ASSIGNING", "END_ASSIGN"] or \
            (goto == None and PRODUCTION_NUMBER == 136):  # reference 1360
        # <ASSIGNMENT>::=<VARIABLE><=1><EXPRESSION>
        if goto == None:
            g.INX[g.PTR[g.SP]] = 2;
            if g.NAME_PSEUDOS: 
                NAME_COMPARE(g.MP, g.SP, d.CLASS_AV, 5);
                HALMAT_TUPLE(g.XNASN, 0, g.SP, g.MP, 0);
                if COPINESS(g.MP, g.SP) > 2: 
                    ERROR(d.CLASS_AA, 1);
                goto = "END_ASSIGN"
            else:
                if RESET_ARRAYNESS() > 2: 
                    ERROR(d.CLASS_AA, 1);
                HALMAT_TUPLE(g.XXASN[g.PSEUDO_TYPE[g.PTR[g.SP]]], \
                             0, g.SP, g.MP, 0);
        if goto in [None, "ASSIGNING"]:
            if goto == "ASSIGNING": goto = None
            g.TEMP = g.PSEUDO_TYPE[g.PTR[g.SP]];
            if g.TEMP == g.INT_TYPE: 
                if g.PSEUDO_FORM[g.PTR[g.SP]] == g.XLIT: 
                    g.TEMP2 = GET_LITERAL(g.LOC_P[g.PTR[g.SP]]);
                    if g.LIT2(g.TEMP2) == 0: g.TEMP = 0;
            if (SHL(1, g.TEMP) & g.ASSIGN_TYPE[g.PSEUDO_TYPE[g.PTR[g.MP]]]) == 0:
                ERROR(d.CLASS_AV, 1, g.VAR[g.MP]);
            elif g.TEMP > 0: 
                # DO CASE PSEUDO_TYPE[PTR[MP]];
                pt = g.PSEUDO_TYPE[g.PTR[g.MP]]
                if pt == 0:
                    pass;
                elif pt == 1:
                    pass;  # BIT
                elif pt == 2:
                    # CHAR*/
                    # CHECK IF THE EXPRESSION BEING ASSIGNED TO A
                    # CHARACTER IS SCALAR AND SHOULD BE IN DOUBLE
                    # PRECISION (DOUBLELIT=TRUE).  IF TRUE, THEN SET
                    # LIT1 EQUAL TO 5.
                    if (g.PSEUDO_TYPE[g.PTR[g.SP]] == g.SCALAR_TYPE) and g.DOUBLELIT:  # "
                        g.LIT1(GET_LITERAL(g.LOC_P[g.PTR[g.SP]]), 5);
                elif pt == 3:
                    MATRIX_COMPARE(g.MP, g.SP, d.CLASS_AV, 2);  # MATRIX
                elif pt == 4:
                    VECTOR_COMPARE(g.MP, g.SP, d.CLASS_AV, 3);  # VECTOR
                elif pt == 5:
                    pass;  # SCALAR
                elif pt == 6:
                    pass;  # INTEGER
                elif pt in (7, 8):
                    pass
                elif pt == 9:
                    pass;  # EVENT
                elif pt == 10:
                    STRUCTURE_COMPARE(g.FIXL[g.MP], g.FIXL[g.SP], d.CLASS_AV, 4);  # STRUC
                elif pt == 11:
                    pass;
        if goto == "END_ASSIGN": goto = None
        g.DOUBLELIT = g.FALSE;
        g.FIXV[g.MP] = g.FIXV[g.SP];
        g.PTR[g.MP] = g.PTR[g.SP];
    if goto == "CLOSE_IF" or \
            (goto == None and PRODUCTION_NUMBER == 138):  # reference 1380
        # <IF STATEMENT>::= <IF CLAUSE> <STATEMENT>
        if goto == None:
            UNBRANCHABLE(g.SP, 4);
        if goto == "CLOSE_IF": goto = None
        g.INDENT_LEVEL = g.FIXL[g.MP];
        HALMAT_POP(g.XLBL, 1, g.XCO_N, 1);
        HALMAT_PIP(g.FIXV[g.MP], g.XINL, 0, 0);
    if goto == "EMIT_IF" or \
            (goto == None and PRODUCTION_NUMBER == 141):  # reference 1410
        # <IF CLAUSE>  ::=  <IF> <RELATIONAL EXP> THEN
        if goto == None:
            g.TEMP = g.LOC_P[g.PTR[g.MPP1]];
        if goto == "EMIT_IF": goto = None
        HALMAT_POP(g.XFBRA, 2, g.XCO_N, 0);
        HALMAT_PIP(g.FL_NO(), g.XINL, 0, 0);
        HALMAT_PIP(g.TEMP, g.XVAC, 0, 0);
        g.PTR_TOP = g.PTR[g.MPP1] - 1;
        g.FIXV[g.MP] = g.FL_NO();
        g.FL_NO(g.FL_NO() + 1);
        # PRINT IF-THEN STATEMENTS ON SAME LINE AS A
        # SIMPLE DO.  DO NOT OUTPUT_WRITER.  SAVE VALUES THAT
        # ARE NEEDED WHEN OUTPUT_WRITER WILL BE CALLED.
        g.IF_FLAG = g.TRUE;
        # DETERMINES IF IF-THEN WAS ALREADY PRINTED IN REPLACE MACRO-11342
        if (g.GRAMMAR_FLAGS(g.LAST_WRITE) & g.PRINT_FLAG) == 0:
            g.IF_FLAG = g.FALSE;
            for g.I in range((g.LAST_WRITE + 1), 1 + g.STACK_PTR[g.SP]):
                if (g.GRAMMAR_FLAGS(g.I) & g.PRINT_FLAG) != 0:
                    g.IF_FLAG = g.TRUE;
        if not g.IF_FLAG and (g.STMT_STACK[g.LAST_WRITE] != l.ELSE_TOKEN):
            g.INDENT_LEVEL = g.INDENT_LEVEL + g.INDENT_INCR;
        else:
            g.SAVE_SRN1 = g.SRN[2][:];
            g.SAVE_SRN_COUNT1 = g.SRN_COUNT[2];
            g.SAVE1 = g.LAST_WRITE;
            g.SAVE2 = g.STACK_PTR[g.SP];
        EMIT_SMRK();
        g.XSET(0x200);
    if goto == "EMIT_WHILE" or \
            (goto == None and PRODUCTION_NUMBER == 146):  # reference 1460
        # <DO GROUP HEAD>::= DO <FOR LIST> <WHILE CLAUSE> ;
        if goto == None:
            g.XSET(0x13);
            g.TEMP = g.PTR[g.SP - 1];
            HALMAT_FIX_POPTAG(g.FIXV[g.MPP1], SHL(g.INX[g.TEMP], 4) | g.PTR[g.MPP1]);
            HALMAT_POP(g.XCFOR, 1, 0, g.INX[g.TEMP]);
        if goto == "EMIT_WHILE": goto = None
        HALMAT_PIP(g.LOC_P[g.TEMP], g.PSEUDO_FORM[g.TEMP], 0, 0);
        g.PTR_TOP = g.TEMP - 1;
        goto = "DO_DONE"
    if goto == "DO_DONE" or \
            (goto == None and PRODUCTION_NUMBER == 144):  # reference 1440
        # <DO GROUP HEAD>::= DO ;
        if goto == None:
            g.XSET(0x11);
            g.FIXL[g.MPP1] = 0;
            HALMAT_POP(g.QUALIFICATION, 1, 0, 0);
            EMIT_PUSH_DO(0, 1, 0, g.MP - 1);
        if goto == "DO_DONE": goto = None
        g.FIXV[g.MP] = 0;
        CHECK_IMPLICIT_T();
        # PRINT IF-THEN/ELSE STATEMENTS ON SAME LINE AS A
        # SIMPLE DO.  IF AN IF-THEN OR ELSE WAS THE PREVIOUS STATEMENT
        # PRINT THE DO ON THE SAME LINE USING SRN & STATEMENT NUMBER
        # FROM IF-THEN OR ELSE.
        if (g.IF_FLAG or g.ELSE_FLAG) and (PRODUCTION_NUMBER == 144):
            g.SQUEEZING = g.FALSE;
            g.SAVE_SRN2 = g.SRN[2][:];
            g.SRN[2] = g.SAVE_SRN1[:];
            g.SAVE_SRN_COUNT2 = g.SRN_COUNT[2];
            g.SRN_COUNT[2] = g.SAVE_SRN_COUNT1;
            if g.IF_FLAG:
                g.STMT_NUM(g.STMT_NUM() - 1);
            OUTPUT_WRITER(g.SAVE1, g.STMT_PTR);
            if g.IF_FLAG:
                g.STMT_NUM(g.STMT_NUM() + 1);
            g.IF_FLAG = g.FALSE
            g.ELSE_FLAG = g.FALSE;
            g.IFDO_FLAG[g.DO_LEVEL] = g.TRUE;
            g.SRN[2] = g.SAVE_SRN2[:];
            g.SRN_COUNT[2] = g.SAVE_SRN_COUNT2;
        else:
            g.IF_FLAG = g.FALSE
            g.ELSE_FLAG = g.FALSE;
            OUTPUT_WRITER(g.LAST_WRITE, g.STMT_PTR);
        if g.FIXL[g.MPP1] > 0:
            HALMAT_POP(g.XTDCL, 1, 0, 0);
            HALMAT_PIP(g.FIXL[g.MPP1], g.XSYT, 0, 0);
        EMIT_SMRK();
        g.INDENT_LEVEL = g.INDENT_LEVEL + g.INDENT_INCR;
        g.NEST_LEVEL = g.NEST_LEVEL + 1;
    if goto == "CASE_HEAD" or \
            (goto == None and PRODUCTION_NUMBER == 148):  # reference 1480
        # <DO GROUP HEAD>::= DO CASE  <ARITH EXP> ;
        if goto == None:
            g.FIXV[g.MP] = 0
            g.FIXL[g.MP] = 0;
        if goto == "CASE_HEAD": goto = None
        g.XSET(0x14);
        g.TEMP2 = g.PTR[g.MP + 2];
        if UNARRAYED_INTEGER(g.MP + 2): 
            ERROR(d.CLASS_GC, 1);
        HALMAT_POP(g.XDCAS, 2, 0, g.FIXL[g.MP]);
        EMIT_PUSH_DO(2, 4, 0, g.MP - 1);
        HALMAT_PIP(g.LOC_P[g.TEMP2], g.PSEUDO_FORM[g.TEMP2], 0, 0);
        g.PTR_TOP = g.TEMP2 - 1;
        CHECK_IMPLICIT_T();
        if g.FIXL[g.MP]: 
            OUTPUT_WRITER(g.LAST_WRITE, g.STACK_PTR[g.SP] - 1);
            g.LAST_WRITE = g.STACK_PTR[g.SP];
            g.INDENT_LEVEL = g.INDENT_LEVEL + g.INDENT_INCR;
            EMIT_SMRK();
            SRN_UPDATE();
            g.XSET(0x100);
            OUTPUT_WRITER(g.LAST_WRITE, g.LAST_WRITE);
            g.INDENT_LEVEL = g.INDENT_LEVEL + g.INDENT_INCR;
        else:
            if g.STMT_END_PTR > -1:
                OUTPUT_WRITER(g.LAST_WRITE, g.STACK_PTR[g.SP]);
            EMIT_SMRK();
            g.INDENT_LEVEL = g.INDENT_LEVEL + g.INDENT_INCR;
            goto = "SET_CASE";
    if goto == "SET_CASE" or \
            (goto == None and PRODUCTION_NUMBER == 149):  # reference 1490
        #  <DO GROUP HEAD>  ::=  <CASE ELSE>  <STATEMENT>
        if goto == None:
            UNBRANCHABLE(g.SP, 6);
            g.FIXV[g.MP] = 0;
            g.INDENT_LEVEL = g.INDENT_LEVEL - g.INDENT_INCR;
        if goto == "SET_CASE": goto = None
        g.CASE_LEVEL = g.CASE_LEVEL + 1;
        if g.CASE_LEVEL <= g.CASE_LEVEL_LIM:
            g.CASE_STACK[g.CASE_LEVEL] = 0;
        g.NEST_LEVEL = g.NEST_LEVEL + 1;
        goto = "EMIT_CASE"
    if goto == "EMIT_CASE" or \
            (goto == None and PRODUCTION_NUMBER == 150):  # reference 1500
        # <DO GROUP HEAD>::= <DO GROUP HEAD> <ANY STATEMENT>
        if goto == None:
            g.FIXV[g.MP] = 1;
        if goto == "EMIT_CASE" or \
                (goto == None and (g.DO_INX[g.DO_LEVEL] & 0x7F) == 2): 
            if goto == "EMIT_CASE" or (goto == None and g.PTR[g.SP]):
                if goto == "EMIT_CASE": goto = None
                g.INFORMATION = g.INFORMATION + 'CASE ';
                if g.CASE_LEVEL <= g.CASE_LEVEL_LIM:
                    g.CASE_STACK[g.CASE_LEVEL] = g.CASE_STACK[g.CASE_LEVEL] + 1;
                g.TEMP = 0;
                while (g.TEMP < g.CASE_LEVEL) and (g.TEMP < g.CASE_LEVEL_LIM):
                    g.INFORMATION = g.INFORMATION + g.CASE_STACK[g.TEMP] + g.PERIOD;
                    g.TEMP = g.TEMP + 1;
                g.INFORMATION = g.INFORMATION + str(g.CASE_STACK[g.TEMP]);
                HALMAT_POP(g.XCLBL, 2, g.XCO_N, 0);
                HALMAT_PIP(g.DO_LOC[g.DO_LEVEL], g.XINL, 0, 0);
                HALMAT_PIP(g.FL_NO(), g.XINL, 0, 0);
                g.FL_NO(g.FL_NO() + 2);
                g.FIXV[g.MP] = g.LAST_POPp;
    if goto == "WHILE_KEY" or \
            (goto == None and PRODUCTION_NUMBER == 153):  # reference 1530
        # <WHILE KEY>::= WHILE
        if goto == None:
            g.TEMP = 0;
        if goto == "WHILE_KEY": goto = None
        if g.PARSE_STACK[g.MP - 1] == g.DO_TOKEN:
            HALMAT_POP(g.XDTST, 1, g.XCO_N, g.TEMP);
            EMIT_PUSH_DO(3, 3, 0, g.MP - 2);
        g.FIXL[g.MP] = g.TEMP;
    if goto == "DO_FLOWSET" or \
            (goto == None and PRODUCTION_NUMBER == 155):  # reference 1550
        # <WHILE CLAUSE>::=<WHILE KEY> <BIT EXP>
        if goto == None:
            if CHECK_ARRAYNESS(): 
                ERROR(d.CLASS_GC, 2);
            if g.PSEUDO_LENGTH[g.PTR[g.SP]] > 1: 
                ERROR(d.CLASS_GB, 1, 'WHILE/UNTIL');
            HALMAT_TUPLE(g.XBTRU, 0, g.SP, 0, 0);
            SETUP_VAC(g.SP, g.BIT_TYPE);
        if goto == "DO_FLOWSET": goto = None
        g.INX[g.PTR[g.SP]] = g.FIXL[g.MP];
        g.PTR[g.MP] = g.PTR[g.SP];
    if goto == "DO_DISCRETE" or \
            (goto == None and PRODUCTION_NUMBER == 160):  # reference 1600
        # <ITERATION BODY>::= <ITERATION BODY>,<ARITH EXP>
        if goto == "DO_DISCRETE": goto = None
        if UNARRAYED_SIMPLE(g.SP): 
            ERROR(d.CLASS_GC, 3);
        g.PTR_TOP = g.PTR[g.SP] - 1;
        HALMAT_TUPLE(g.XAFOR, g.XCO_N, g.SP, 0, 0);
        g.FL_NO(g.FL_NO() + 1);
        g.FIXV[g.MP] = g.LAST_POPp;
    if goto == "ON_ERROR_ACTION" or \
            (goto == None and PRODUCTION_NUMBER == 169):  # reference 1690
        #  <ON CLAUSE>  ::=  ON ERROR <SUBSCRIPT>  SYSTEM
        if goto == None:
            g.FIXL[g.MP] = 1;
        if goto == "ON_ERROR_ACTION": goto = None
        ERROR_SUB(1);
        g.PTR_TOP = g.PTR[g.MP + 2];
        g.PTR[g.MP] = g.PTR_TOP
    if goto == "SIGNAL_EMIT" or \
            (goto == None and PRODUCTION_NUMBER == 171):  # reference 1710
        #  <SIGNAL CLAUSE>  ::=  SET <EVENT VAR>
        if goto == None:
            g.TEMP = 1;
        if goto == "SIGNAL_EMIT": goto = None
        if g.INLINE_LEVEL > 0: 
            ERROR(d.CLASS_PP, 6);
        if g.TEMP > 0: 
            if (g.SYT_FLAGS(g.FIXL[g.MPP1]) & g.LATCHED_FLAG) == 0:
                ERROR(d.CLASS_RT, 10);
        SET_XREF_RORS(g.MPP1, 0, g.XREF_ASSIGN);
        if CHECK_ARRAYNESS(): 
            ERROR(d.CLASS_RT, 8);
        if g.SIMULATING: 
            STAB_VAR(g.MPP1);
        g.PTR[g.MP] = g.PTR[g.MPP1];
        g.INX[g.PTR[g.MP]] = g.TEMP;
    if goto == "ASSIGN_ARG" or \
            (goto == None and PRODUCTION_NUMBER == 179):  # reference 1790
        #  <CALL ASSIGN LIST> ::= <VARIABLE>
        if g.INLINE_LEVEL == 0 or goto == "ASSIGN_ARG":
            if goto == "ASSIGN_ARG": goto = None
            g.FCN_ARG[0] = g.FCN_ARG[0] + 1;
            HALMAT_TUPLE(g.XXXAR, g.XCO_N, g.SP, 0, 0);
            HALMAT_FIX_PIPTAGS(g.NEXT_ATOMp - 1, g.PSEUDO_TYPE[g.PTR[g.SP]] | \
                               SHL(g.NAME_PSEUDOS, 7), 1);
            if g.NAME_PSEUDOS: 
                KILL_NAME(g.SP);
                if g.EXT_P[g.PTR[g.SP]] != 0: 
                    ERROR(d.CLASS_FD, 7);
            CHECK_ARRAYNESS();
            l.H1 = g.VAL_P[g.PTR[g.SP]];
            if SHR(l.H1, 7) & 1: 
                ERROR(d.CLASS_FS, 1);
            if SHR(l.H1, 4) & 1: 
                ERROR(d.CLASS_SV, 1, g.VAR[g.SP]);
            if (l.H1 & 0x6) == 0x2: 
                ERROR(d.CLASS_FS, 2, g.VAR[g.SP]);
            g.PTR_TOP = g.PTR[g.SP] - 1;
    if goto == "FIX_NULL" or \
            (goto == None and PRODUCTION_NUMBER == 207):  # reference 2070
        #  <NAME EXP>  ::=  NULL
        if goto == "FIX_NULL": goto = None
        g.PTR[g.MP] = PUSH_INDIRECT(1);
        g.LOC_P[g.PTR_TOP] = 0;
        g.PSEUDO_FORM[g.PTR_TOP] = g.XIMD;
        g.NAME_PSEUDOS = g.TRUE;
        g.EXT_P[g.PTR_TOP] = 0;
        g.VAL_P[g.PTR_TOP] = 0x500;
    if goto == "FUNC_IDS" or \
            (goto == None and PRODUCTION_NUMBER == 214):  # reference 2140
        #  <MODIFIED STRUCT FUNC> ::= <PREFIX> <NO ARG STRUCT FUNC> <SUBSCRIPT>
        if goto == "FUNC_IDS": goto = None
        if g.FIXL[g.MPP1] > g.SYT_MAX: 
            if g.FIXL[g.SP]: 
                ERROR(d.CLASS_FT, 8, g.VAR[g.MPP1]);
            g.TEMP_SYN = g.PSEUDO_FORM[g.PTR[g.SP]];
            g.PTR_TOP = g.PTR[g.MP];
            g.FIXL[g.MP] = g.FIXL[g.MPP1];
            g.VAR[g.MP] = g.VAR[g.MPP1];
        else:
            g.FIXL[g.SP] = g.FIXL[g.SP] | 2;
            goto = "MOST_IDS"
    if goto in ["MOST_IDS", "STRUC_IDS"] or \
            (goto == None and PRODUCTION_NUMBER == 219):  # reference 2190
        #  <EVENT VAR>  ::=  <PREFIX>  (EVENT ID>  <SUBSCRIPT>
        if goto in [None, "MOST_IDS"]:
            if goto == "MOST_IDS": goto = None
            l.H1 = g.PTR[g.MP];
            g.PSEUDO_TYPE[l.H1] = g.SYT_TYPE(g.FIXL[g.MPP1]);
            g.PSEUDO_LENGTH[l.H1] = g.VAR_LENGTH(g.FIXL[g.MPP1]);
            if g.FIXV[g.MP] == 0: 
                g.STACK_PTR[g.MP] = g.STACK_PTR[g.MPP1];
                g.VAR[g.MP] = g.VAR[g.MPP1];
                if g.FIXV[g.MPP1] == 0: 
                    g.LOC_P[l.H1] = g.FIXL[g.MPP1];
                else:
                    g.FIXV[g.MP] = g.FIXV[g.MPP1];
                    g.LOC_P[l.H1] = g.FIXV[g.MPP1];
                g.PSEUDO_FORM[l.H1] = g.XSYT;
            else:
                g.VAR[g.MP] = g.VAR[g.MP] + g.PERIOD + g.VAR[g.MPP1];
                g.TOKEN_FLAGS(g.EXT_P[l.H1], \
                              g.TOKEN_FLAGS(g.EXT_P[l.H1]) | 0x20);
                g.I = g.FIXL[g.MPP1];
                goto = "UNQ_TEST1"
                while goto == "UNQ_TEST1":
                    if goto == "UNQ_TEST1": goto = None
                    while g.I > 0:
                        g.I = g.SYT_LINK2(g.I);
                    g.I = -g.I;
                    if g.I == 0: 
                        ERROR (d.CLASS_IS, 2, g.VAR[g.MPP1]);
                        break  # GO TO UNQ_TEST2;
                    if g.I != g.FIXL[g.MP]: 
                        goto = "UNQ_TEST1"
                        continue
                # UNQ_TEST2:
            g.FIXL[g.MP] = g.FIXL[g.MPP1];
            g.EXT_P[l.H1] = g.STACK_PTR[g.MPP1];
        if goto == "STRUC_IDS": goto = None
        g.NAME_BIT = SHR(g.VAL_P[l.H1], 1) & 0x80;
        g.TEMP_SYN = g.INX[l.H1];
        g.TEMP3 = g.LOC_P[l.H1];
        if ATTACH_SUBSCRIPT(): 
            HALMAT_TUPLE(g.XTSUB, 0, g.MP, 0, g.MAJ_STRUC | g.NAME_BIT);
            g.INX[l.H1] = g.NEXT_ATOMp - 1;
            HALMAT_FIX_PIPp(g.LAST_POPp, EMIT_SUBSCRIPT(0x8));
            SETUP_VAC(g.MP, g.PSEUDO_TYPE[l.H1]);
            g.VAL_P[l.H1] = g.VAL_P[l.H1] | 0x20;
        g.PTR_TOP = l.H1;  # BASH DOWN STACKS
        if g.FIXV[g.MP] > 0:
            HALMAT_TUPLE(g.XEXTN, 0, g.MP, 0, 0);
            g.TEMP = l.H1;
            if (g.SYT_FLAGS(g.TEMP3) & g.NAME_FLAG) != 0:
                g.VAL_P[l.H1] = g.VAL_P[l.H1] | 0x4000;
            l.H2 = g.FALSE;
            
            l.PREV_LIVES_REMOTE = (g.SYT_FLAGS(g.TEMP3) & g.REMOTE_FLAG) != 0;
            l.PREV_POINTS = (g.SYT_FLAGS(g.TEMP3) & g.NAME_FLAG) != 0;
            l.PREV_REMOTE = l.PREV_LIVES_REMOTE;
            
            while g.TEMP_SYN != 0:
                g.TEMP = g.TEMP + 1;
                g.TEMP3 = g.LOC_P[g.TEMP];
                HALMAT_PIP(g.TEMP3, g.XSYT, 0, 0);
                l.H2 = l.H2 | (g.SYT_FLAGS(g.TEMP3) & g.NAME_FLAG) != 0;
                
                # KEEP TRACK OF THE REMOTENESS -----------------
                # OF THE NODE BEING PROCESSED
                l.PREV_REMOTE = ((g.SYT_FLAGS(g.TEMP3) & g.NAME_FLAG) > 0);
                l.REMOTE_SET = ((g.SYT_FLAGS(g.TEMP3) & g.REMOTE_FLAG) > 0);
                if (l.REMOTE_SET and not l.PREV_REMOTE) \
                        or (l.PREV_POINTS and l.PREV_REMOTE) \
                        or (l.PREV_LIVES_REMOTE and not l.PREV_POINTS):
                    l.CURRENT_LIVES_REMOTE = g.TRUE;
                else:
                    l.CURRENT_LIVES_REMOTE = g.FALSE;
                l.PREV_LIVES_REMOTE = l.CURRENT_LIVES_REMOTE;
                l.PREV_POINTS = l.PREV_REMOTE;
                l.PREV_REMOTE = l.REMOTE_SET;
                
                g.TEMP_SYN = g.INX[g.TEMP];
            if l.H2: 
                g.VAL_P[l.H1] = g.VAL_P[l.H1] | 0x4000;
            
            # SET FLAG IN VAL_P TO INDICATE
            # THAT TERMINAL LIVES REMOTE
            if (l.PREV_POINTS and l.PREV_REMOTE) \
                    or (l.PREV_LIVES_REMOTE and not  l.PREV_POINTS):
                g.VAL_P[l.H1] = g.VAL_P[l.H1] | 0x8000;
            
            g.PTR_TOP = g.TEMP;  # WAIT - DONT LOSE EXTN TILL XREF DONE
            if g.VAR_LENGTH(g.TEMP3) == g.FIXL[g.MP]:
                if g.TEMP == l.H1: 
                    g.VAL_P[l.H1] = g.VAL_P[l.H1] | 0x4;
                g.VAL_P[l.H1] = g.VAL_P[l.H1] | 0x1000;
                HALMAT_FIX_PIPTAGS(g.NEXT_ATOMp - 1, 0, 1);
                if (g.SYT_FLAGS(g.TEMP3) & g.NAME_FLAG) != 0:
                    g.VAL_P[l.H1] = g.VAL_P[l.H1] | 0x200;
            HALMAT_PIP(g.FIXL[g.MP], g.XSYT, 0, 1);
            l.H2 = (l.H2 or (g.SYT_FLAGS(g.FIXL[g.MP]) & g.NAME_FLAG) != 0);
            HALMAT_FIX_PIPp(g.LAST_POPp, g.TEMP - l.H1 + 2);
            HALMAT_FIX_POPTAG(g.LAST_POPp, l.H2);
            g.LOC_P[l.H1] = g.LAST_POPp
            l.H2 = g.LAST_POPp;
            g.PSEUDO_FORM[l.H1] = g.XXPT;
        else:
            l.H2 = -1;
        if g.PSEUDO_FORM[g.INX[0]] > 0: 
            if g.FIXL[g.SP] >= 2:
                if g.DELAY_CONTEXT_CHECK: 
                    ERROR(d.CLASS_EN, 14);
                    g.PSEUDO_FORM[g.INX[0]] = 0;
                else:
                    g.TEMP_SYN = g.SP;
                # THIS ASSUMES THAT PTR[SP] AND THE INDIRECT STACKS
                # ARE NOT OVERWRITTEN UNTIL AFTER REACHING THE
                # <PRIMARY>::=<MODIFIED ARITH FUNC> PRODUCTION,
                # WHEN THAT PARSING ROUTE IS TAKEN
            else:
                PREC_SCALE(g.SP, g.PSEUDO_TYPE[l.H1]);
            if g.PSEUDO_FORM[g.INX[0]] > 0: 
                g.VAL_P[l.H1] = g.VAL_P[l.H1] | 0x40;
        elif g.IND_LINK > 0: 
            HALMAT_TUPLE(g.XDSUB, 0, g.MP, 0, g.PSEUDO_TYPE[l.H1] | g.NAME_BIT);
            g.INX[l.H1] = g.NEXT_ATOMp - 1;
            g.VAL_P[l.H1] = g.VAL_P[l.H1] | 0x20;
            HALMAT_FIX_PIPp(g.LAST_POPp, EMIT_SUBSCRIPT(0x0));
            SETUP_VAC(g.MP, g.PSEUDO_TYPE[l.H1]);
        g.FIXF[g.MP] = g.PTR_TOP;  # RECORD WHERE TOP IS IN CASE CHANGED
        ASSOCIATE(l.H2);
    if goto == "SIMPLE_SUBS" or \
            (goto == None and PRODUCTION_NUMBER == 228):  # reference 2280
        # <SUBSCRIPT> ::= <$> <NUMBER>
        if goto == None:
            g.SUB_END_PTR = g.STMT_PTR;
            g.PTR[g.SP] = PUSH_INDIRECT(1);
            g.LOC_P[g.PTR[g.SP]] = g.FIXV[g.SP];
            g.PSEUDO_FORM[g.PTR[g.SP]] = g.XIMD;
            g.PSEUDO_TYPE[g.PTR[g.SP]] = g.INT_TYPE;
        if goto == "SIMPLE_SUBS": goto = None
        g.INX[g.PTR[g.SP]] = 1;
        g.VAL_P[g.PTR[g.SP]] = 0;
        g.SUB_COUNT(1);
        g.ARRAY_SUB_COUNT(-1);
        g.STRUCTURE_SUB_COUNT(-1);
        goto = "SS_CHEX"
    if goto == "SUB_START" or \
            (goto == None and PRODUCTION_NUMBER == 231):  # reference 2310
        #  <SUB START>  ::=  <$> (
        if goto == "SUB_START": goto = None
        g.SUB_COUNT(0);
        g.STRUCTURE_SUB_COUNT(-1);
        g.ARRAY_SUB_COUNT(-1);
        g.SUB_SEEN = 0;
    if goto == "SHARP_EXP" or \
            (goto == None and PRODUCTION_NUMBER == 246):  # reference 2460
        # <# EXPRESSION> ::= <# EXPRESSION> + <TERM>
        if goto == None:
            g.TEMP = 0;
        if goto == "SHARP_EXP": goto = None
        IORS(g.SP);
        if g.FIXL[g.MP] == 1: 
            g.FIXL[g.MP] = g.TEMP + 2;
            g.PTR[g.MP] = g.PTR[g.SP];
        else:
            if g.FIXL[g.MP] == 3: 
                g.TEMP = 1 - g.TEMP;
            ADD_AND_SUBTRACT(g.TEMP);
    if goto == "SS_FIXUP" or \
            (goto == None and PRODUCTION_NUMBER == 249):  # reference 2490
        # <$> ::= $
        if goto == None:
            g.FIXL[g.MP] = 1;
        if goto == "SS_FIXUP": goto = None
        g.TEMP = g.FIXF[g.MP - 1];
        if g.TEMP > 0:
            HALMAT_POP(g.XXXST, 1, g.XCO_N, g.TEMP + g.FCN_LV - 1);
            HALMAT_PIP(g.FIXL[g.MP - 1], g.XSYT, 0, 0);
        g.NAMING = g.FALSE;
        if g.SUBSCRIPT_LEVEL == 0:
            if g.ARRAYNESS_FLAG: 
                SAVE_ARRAYNESS();
            g.SAVE_ARRAYNESS_FLAG = g.ARRAYNESS_FLAG;
            g.ARRAYNESS_FLAG = 0;
        g.SUBSCRIPT_LEVEL = g.SUBSCRIPT_LEVEL + g.FIXL[g.MP];
        g.PTR[g.MP] = PUSH_INDIRECT(1);
        g.PSEUDO_FORM[g.PTR_TOP] = 0;
        g.LOC_P[g.PTR_TOP] = 0
        g.INX[g.PTR_TOP] = 0;
    if goto == "SS_CHEX" or \
            (goto == None and PRODUCTION_NUMBER == 263):  # reference 2630
        # <BIT QUALIFIER> ::= <$(> @ <RADIX> )
        if goto == None:
            if g.TEMP3 == 0: 
                g.TEMP3 = 2;
            g.PSEUDO_FORM[g.PTR[g.MP]] = g.TEMP3;
        if goto == "SS_CHEX": goto = None
        if g.SUBSCRIPT_LEVEL > 0:
            g.SUBSCRIPT_LEVEL = g.SUBSCRIPT_LEVEL - 1;
    if goto == "DO_BIT_CONST" or \
            (goto == None and PRODUCTION_NUMBER == 271):  # reference 2710
        # <BIT CONST> ::= TRUE
        if goto == None:
            g.TEMP_SYN = 1;
        if goto == "DO_BIT_CONST": goto = None
        g.I = 1;
        goto = "DO_BIT_CONSTANT_END";
    if goto == "DO_BIT_CONSTANT_END" or \
            (goto == None and PRODUCTION_NUMBER == 270):  # reference 2700
        #  <BIT CONST> ::= <BIT CONST HEAD> <CHAR STRING>
        if goto == None:
            g.S = g.VAR[g.SP];
            g.I = 1;
            g.K = LENGTH(g.S);
            g.L = g.FIXL[g.MP];
            g.TEMP_SYN = 0;  #  START WITH VALUE CALC. = O
            # DO CASE TEMP3;
            if g.TEMP3 == 0:
                g.C[0] = 'D';
                if g.L != 1:
                    ERROR(d.CLASS_LB, 2);
                    g.L = 1;
                g.TEMP2 = 0;  #  INDICATE START FROM 1ST CHAR
                if SUBSTR(g.S, g.TEMP2) > '2147483647':
                    ERROR(d.CLASS_LB, 1);
                    goto = "DO_BIT_CONSTANT_END"
                else:
                    for g.TEMP in range(g.TEMP2, 1 + LENGTH(g.S) - 1):  #  CHECK FOR CHAR 1 TO 9
                        l.H1 = BYTE(g.S, g.TEMP);
                        if not (l.H1 >= BYTE('0') and l.H1 <= BYTE('9')): 
                            ERROR(d.CLASS_LB, 4);
                            g.TEMP_SYN = 0;
                            goto = "DO_BIT_CONSTANT_END"
                            break
                        else:
                            g.TEMP_SYN = g.TEMP_SYN * 10;  #  ADD IN NEXT DIGIT
                            g.TEMP_SYN = g.TEMP_SYN + (l.H1 & 0x0F);
                    #  END OF DO FOR
                    if not goto == "DO_BIT_CONSTANT_END":
                        g.I = 1;
                        while SHR(g.TEMP_SYN, g.I) != 0:
                            g.I = g.I + 1;
                        goto = "DO_BIT_CONSTANT_END"
                #  END OF CASE 0
            elif g.TEMP3 == 1:
                # CASE 1, BIN
                g.C[0] = 'B';
                for g.TEMP in range(0, 1 + LENGTH(g.S) - 1):  #  CHECK FOR '0' OR '1'
                   l.H1 = BYTE(g.S, g.TEMP);
                   if not ((l.H1 == BYTE('0')) or (l.H1 == BYTE('1'))):
                       ERROR(d.CLASS_LB, 5);
                       g.TEMP_SYN = 0;
                       goto = "DO_BIT_CONSTANT_END"
                       break
                   else:
                       g.TEMP_SYN = SHL(g.TEMP_SYN, 1);  #  ADDIN NEXT VALUE
                       g.TEMP_SYN = g.TEMP_SYN | (l.H1 & 0x0F);
                #  END OF CASE 1
            elif g.TEMP3 == 2:
                # CASE 2, NO RADIX BASE 2 AT MOMENT
                pass;
            elif g.TEMP3 == 3:
                # CASE 3, OCT
                g.C[0] = 'O';
                for g.TEMP in range(0, 1 + LENGTH(g.S) - 1):  #  CHECK FOR OCTAL CHARACTERS
                    l.H1 = BYTE(g.S, g.TEMP);
                    if not ((l.H1 >= BYTE('0')) and (l.H1 <= BYTE('7'))):
                        ERROR(d.CLASS_LB, 6);
                        g.TEMP_SYN = 0;
                        goto = "DO_BIT_CONSTANT_END"
                        break
                    else:
                        g.TEMP_SYN = SHL(g.TEMP_SYN, 3);  #  ADD IN NEXT VALUE
                        g.TEMP_SYN = g.TEMP_SYN | (l.H1 & 0x0F);
                #  END OF CASE 3
            elif g.TEMP3 == 4:
                # CASE 4, HEX
                g.C[0] = 'H';
                for g.TEMP in range(0, 1 + LENGTH(g.S) - 1):  #  CHECK FOR HEXADECIMAL CHARACTERS
                    l.H1 = BYTE(g.S, g.TEMP);
                    if not ((l.H1 >= BYTE('0')) and (l.H1 <= BYTE('9'))):
                        if not ((l.H1 >= BYTE('A')) and (l.H1 <= BYTE('F'))):
                            ERROR(d.CLASS_LB, 7);
                            g.TEMP_SYN = 0;
                            goto = "DO_BIT_CONSTANT_END"
                            break
                        else:
                            g.TEMP_SYN = SHL(g.TEMP_SYN, 4);  #  GET NEW VAL WITH NUM.DIG.
                            g.TEMP_SYN = g.TEMP_SYN + 9 + (l.H1 & 0x0F);
                    else:
                       g.TEMP_SYN = SHL(g.TEMP_SYN, 4);  #  ADD IN NUM. VALUE
                       g.TEMP_SYN = g.TEMP_SYN + (l.H1 & 0x0F);
                # END OF CASE 4
            #  END OF DO CASE
            #  INCORPORATE REPETITION FACTOR
            if not goto == "DO_BIT_CONSTANT_END":
                g.TEMP2 = g.TEMP_SYN;
                g.J = g.TEMP3 * g.K;
                for g.TEMP in range(2, 1 + g.L):
                    g.TEMP_SYN = SHL(g.TEMP_SYN, g.J) | g.TEMP2;
                g.I = g.J * g.L;
                if g.I > g.BIT_LENGTH_LIM: 
                    if g.I - g.TEMP3 < g.BIT_LENGTH_LIM:
                        l.H1 = BYTE(g.S);
                        if l.H1 >= BYTE('A') and l.H1 <= BYTE('F'): 
                            l.H1 = l.H1 + 9;
                        l.H1 = l.H1 & 0x0F;
                        if SHR(l.H1, g.BIT_LENGTH_LIM + g.TEMP3 - g.I) != 0:
                            ERROR(d.CLASS_LB, 1);
                    else:
                        ERROR(d.CLASS_LB, 1);
                    g.I = g.BIT_LENGTH_LIM;
        if goto == "DO_BIT_CONSTANT_END": goto = None
        g.PTR[g.MP] = PUSH_INDIRECT(1);
        g.PSEUDO_TYPE[g.PTR[g.MP]] = g.BIT_TYPE;
        g.PSEUDO_FORM[g.PTR[g.MP]] = g.XLIT;
        g.PSEUDO_LENGTH[g.PTR[g.MP]] = g.I;
        g.LOC_P[g.PTR[g.MP]] = SAVE_LITERAL(2, g.TEMP_SYN, g.I);
    if goto == "CHAR_LITS" or \
            (goto == None and PRODUCTION_NUMBER == 275):  # reference 2750
        #  <CHAR CONST>  ::=  <CHAR STRING>
        if goto == "CHAR_LITS": goto = None
        g.PTR[g.MP] = PUSH_INDIRECT(1);
        g.LOC_P[g.PTR[g.MP]] = SAVE_LITERAL(0, g.VAR[g.MP]);
        g.PSEUDO_FORM[g.PTR[g.MP]] = g.XLIT;
        g.PSEUDO_TYPE[g.PTR[g.MP]] = g.CHAR_TYPE;
        g.PSEUDO_LENGTH[g.PTR[g.MP]] = LENGTH(g.VAR[g.MP]);
    if goto == "IO_CONTROL" or \
            (goto == None and PRODUCTION_NUMBER == 277):  # reference 2770
        #  <IO CONTROL>  ::=  SKIP  (  <ARITH EXP>  )
        if goto == None:
            g.TEMP = 3;
        if goto == "IO_CONTROL": goto = None
        if UNARRAYED_INTEGER(g.SP - 1): 
            ERROR(d.CLASS_TC, 1);
        g.VAL_P[g.PTR[g.MP]] = 0;
        g.PTR[g.MP] = g.PTR[g.SP - 1];
    if goto == "CHECK_READ" or \
            (goto == None and PRODUCTION_NUMBER == 282):  # reference 2820
        #  <READ PHRASE>  ::=  <READ KEY>  <READ ARG>
        if goto == "CHECK_READ": goto = None
        if g.INX[g.PTR[g.MP]] == 0: 
            if SHR(g.VAL_P[g.PTR[g.SP]], 7) & 1: ERROR(d.CLASS_T, 3);
            if g.PSEUDO_TYPE[g.PTR[g.SP]] == g.EVENT_TYPE: 
                ERROR(d.CLASS_T, 2);
        elif g.TEMP > 0: 
            pass;
        elif READ_ALL_TYPE(g.SP): 
            ERROR(d.CLASS_T, 1);
    if goto == "EMIT_IO_ARG" or \
            (goto == None and PRODUCTION_NUMBER == 286):  # reference 2860
        #  <READ ARG>  ::=  <VARIABLE>
        if goto == None:
            g.TEMP = 0;
        if goto == "EMIT_IO_ARG": goto = None
        if KILL_NAME(g.MP): 
            ERROR(d.CLASS_T, 5);
        if g.INLINE_LEVEL > 0: 
            ERROR(d.CLASS_PP, 5);
        HALMAT_TUPLE(g.XXXAR, g.XCO_N, g.MP, 0, 0);
        HALMAT_FIX_PIPTAGS(g.NEXT_ATOMp - 1, g.PSEUDO_TYPE[g.PTR[g.MP]], g.TEMP);
        if g.PSEUDO_TYPE[g.PTR[g.MP]] == g.MAJ_STRUC:
            if (g.SYT_FLAGS(g.VAR_LENGTH(g.FIXV[g.MP])) & g.MISC_NAME_FLAG) != 0:
                ERROR(d.CLASS_T, 6);
        EMIT_ARRAYNESS();
        g.PTR_TOP = g.PTR[g.MP] - 1;
    if goto == "EMIT_IO_HEAD" or \
            (goto == None and PRODUCTION_NUMBER == 290):  # reference 2900
        #  <READ KEY>  ::=  READ  (  <NUMBER>  )
        if goto == None:
            g.TEMP = 0;
        if goto == "EMIT_IO_HEAD": goto = None
        g.XSET(SHL(g.TEMP, 11));
        HALMAT_POP(g.XXXST, 1, g.XCO_N, 0);
        HALMAT_PIP(g.TEMP, g.XIMD, 0, 0);
        g.PTR[g.MP] = PUSH_INDIRECT(1);
        if g.FIXV[g.MP + 2] > g.DEVICE_LIMIT: 
            ERROR(d.CLASS_TD, 1, '' + g.DEVICE_LIMIT);
            g.LOC_P[g.PTR[g.MP]] = 0;
        else:
            g.LOC_P[g.PTR[g.MP]] = g.FIXV[g.MP + 2];
            if not isinstance(g.FIXV[g.MP + 2], int):
                pass
            g.I = h.IODEV[g.FIXV[g.MP + 2]];
            if (g.I & 0x28) == 0: 
                if g.TEMP == 2: 
                    if (g.I & 0x01) == 0: 
                        g.I = g.I | 0x04;
                    else:
                        g.I = g.I | 0x02;
                else:
                    g.I = g.I | 0x01;
                    if (g.I & 0x04) != 0: 
                        if (g.I & 0x40) != 0: 
                            g.I = g.I | 0x80;
                        else:
                            g.I = (g.I & 0xFB) | 0x02;
            h.IODEV[g.FIXV[g.MP + 2]] = g.I;
        g.PSEUDO_FORM[g.PTR[g.MP]] = g.XIMD;
        g.INX[g.PTR[g.MP]] = g.TEMP;
        if g.UPDATE_BLOCK_LEVEL > 0: 
            ERROR(d.CLASS_UT, 1);
    if goto == "CLOSE_SCOPE" or \
            (goto == None and PRODUCTION_NUMBER == 293):  # reference 2930
        #  <BLOCK DEFINITION> ::= <BLOCK STMT> <BLOCK BODY> <CLOSING> ;
        if goto == None:
            g.TEMP = g.XCLOS;
            g.TEMP2 = 0;
        if goto == "CLOSE_SCOPE": goto = None
        HALMAT_POP(g.TEMP, 1, 0, g.TEMP2);
        HALMAT_PIP(g.BLOCK_SYTREF[g.NEST], g.XSYT, 0, 0);
        for g.I in range(0, 1 + g.NDECSY() - g.REGULAR_PROCMARK):
            g.J = g.NDECSY() - g.I;
            if (g.SYT_FLAGS(g.J) & g.INACTIVE_FLAG) == 0:
                g.CLOSE_BCD = g.SYT_NAME(g.J);
                if g.SYT_CLASS(g.J) == g.FUNC_CLASS:
                    if (g.SYT_FLAGS(g.J) & g.DEFINED_LABEL) == 0:
                       ERROR(d.CLASS_PL, 1, g.CLOSE_BCD);
                    DISCONNECT(g.J);
                elif g.SYT_CLASS(g.J) == g.LABEL_CLASS:
                    if (g.SYT_FLAGS(g.J) & g.DEFINED_LABEL) == 0:
                        # UNDEFINED CALLABLE LABEL
                        if g.SYT_TYPE(g.J) == g.STMT_LABEL:
                            DISCONNECT(g.J);
                            ERROR(d.CLASS_PL, 5, g.CLOSE_BCD);
                        # UNDEFINED OBJECT OF GO TO
                        else:
                            # CALLED/SCHED BUT UNDEFINED PROCS/TASKS
                            if g.NEST == 1:
                                ''' CLOSING PROGRAM -
                                    MAKE UNDEFINED CALLS/SCHEDS
                                    INTO ERRORS '''
                                ERROR(d.CLASS_PL, 6, g.CLOSE_BCD);
                                DISCONNECT(g.J);
                            else:
                                SET_OUTER_REF(g.J, 0x6000);
                                g.SYT_NEST(g.J, g.NEST - 1);
                        # END OF CALLED LABELS
                    # END OF UNDEFINED CALLABLE LABELS
                    elif g.SYT_TYPE(g.J) == g.IND_CALL_LAB:
                        g.SYT_NEST(g.J, g.NEST - 1);
                        g.K = g.SYT_PTR(g.J);
                        while g.SYT_TYPE(g.K) == g.IND_CALL_LAB:
                            g.K = g.SYT_PTR(g.K);
                        if g.SYT_NEST(g.K) >= g.SYT_NEST(g.J):
                            ''' IND CALL HAS REACHED SAME SCOPE AS
                                DEFINITION OF LABEL. SO LEAVE
                                AS IND CALL AND DISCONNECT FROM SYT '''
                            if g.SYT_PTR(g.J) == g.K:
                                if g.SYT_LINK1(g.K) < 0:
                                    if g.DO_LEVEL < (-g.SYT_LINK1(g.K)):
                                        ERROR(d.CLASS_PL, 11, g.CLOSE_BCD);
                            DISCONNECT(g.J);
                            TIE_XREF(g.J);
                    # END OF TYPE = IND_CALL_LAB
                    else:
                        DISCONNECT(g.J);  # NONE OF THE ABOVE
                # END OF LABEL CLASS
                else:
                    DISCONNECT(g.J);  # ALL OTHER CLASSES
        if g.BLOCK_MODE[g.NEST] == g.UPDATE_MODE:
            g.UPDATE_BLOCK_LEVEL = g.UPDATE_BLOCK_LEVEL - 1;
        if LENGTH(g.VAR[g.SP - 1]) > 0:
            if g.VAR[g.SP - 1] != g.CURRENT_SCOPE:
                ERROR(d.CLASS_PL, 3, g.CURRENT_SCOPE);
        if g.REGULAR_PROCMARK > g.NDECSY():  # NO LOCAL NAMES
            g.SYT_PTR(g.FIXL[g.MP], 0);
        if (g.SYT_FLAGS(g.FIXL[g.MP]) & g.ACCESS_FLAG) != 0:
            if g.BLOCK_MODE[g.NEST] == g.CMPL_MODE:
                for g.I in range(g.FIXL[g.MP], 1 + g.NDECSY()):
                    g.SYT_FLAGS(g.I, g.SYT_FLAGS(g.I) | READ_ACCESS_FLAG);
        ''' IF THIS IS THE CLOSE OF A COMPOOL INCLUDED REMOTE
            THEN MAKE SURE THAT ALL OF THE ITEMS IN THE COMPOOL
            ARE ALSO FLAGED AS REMOTE - EXCEPT FOR NAME TYPES AND
            STRUCTURE TEMPLATE VARIABLES. '''
        if ((g.SYT_FLAGS(g.FIXL[g.MP]) & g.EXTERNAL_FLAG) != 0) \
                and ((g.SYT_FLAGS(g.FIXL[g.MP]) & g.REMOTE_FLAG) != 0):
            if g.BLOCK_MODE[g.NEST] == g.CMPL_MODE:
                for g.I in range(g.FIXL[g.MP], 1 + g.NDECSY()):
                    # IF 16-BIT NAME VARIABLE WAS INITIALIZED TO NON-REMOTE VARIABLE IN
                    # A REMOTELY INCLUDED COMPOOL, IT IS NOW INVALID.
                    
                    def TEMPL_INITIAL_CHECK():
                        # IS POINTED TO BY A NAME VARIABLE
                        if (g.SYT_FLAGS(g.I) & g.MISC_NAME_FLAG) != 0:
                            if g.SYT_TYPE(g.I) != g.TEMPL_NAME:  # NOT A TEMPLATE
                                                          # NON-REMOTE
                                if (g.SYT_FLAGS(g.I) & g.REMOTE_FLAG) == 0:
                                    ERROR(d.CLASS_DI, 21);
           
                    TEMPL_INITIAL_CHECK();
                    # INCLUDED_REMOTE MEANS VARIABLE LIVES REMOTE ONLY BECAUSE
                    # IT WAS INCLUDED REMOTE (IT RESIDES IN #P, NOT IN #R)
                    if (g.SYT_CLASS(g.I) != g.TEMPLATE_CLASS): 
                            # NOT A NAME VARIABLE AND NOT INITIALLY DECLARED REMOTE
                            if ((g.SYT_FLAGS(g.I) & g.NAME_FLAG) == 0) and \
                                    ((g.SYT_FLAGS(g.I) & g.REMOTE_FLAG) == 0):
                                g.SYT_FLAGS(g.I, g.SYT_FLAGS(g.I) | g.REMOTE_FLAG | \
                                                g.INCLUDED_REMOTE);
                                # FOR NAME VARIABLES, SET THAT THEY NOW LIVE REMOTE
                                if ((g.SYT_FLAGS(g.I) & g.NAME_FLAG) != 0):
                                    g.SYT_FLAGS(g.I, g.SYT_FLAGS(g.I) | \
                                                    g.INCLUDED_REMOTE);

        g.SYT_FLAGS(g.NDECSY(), g.SYT_FLAGS(g.NDECSY()) | g.ENDSCOPE_FLAG);
        g.CURRENT_SCOPE = g.VAR[g.MP];
        if g.PTR[g.MPP1]: 
            # DO CASE g.EXTERNAL_MODE;
            if g.EXTERNAL_MODE == 0:
                #  NOT EXTERNAL
                if g.BLOCK_MODE[g.NEST] == g.CMPL_MODE: 
                    ERROR(d.CLASS_PC, 1);
            elif g.EXTERNAL_MODE == 1:
                #  PROC MODE
                ERROR(d.CLASS_PS, 1);
            elif g.EXTERNAL_MODE == 2:
                #  FUNC MODE
                ERROR(d.CLASS_PS, 1);
            elif g.EXTERNAL_MODE == 3:
                #  COMPOOL MODE
                ERROR(d.CLASS_PC, 2);
            elif g.EXTERNAL_MODE == 4:
                # PROGRAM MODE
                ERROR(d.CLASS_PS, 1);
        OUTPUT_WRITER();
        EMIT_SMRK();
        if g.BLOCK_MODE[g.NEST] == g.INLINE_MODE: 
            g.INLINE_INDENT_RESET = g.EXT_P[g.PTR[g.MP]];
            g.INDENT_LEVEL = INLINE_INDENT + g.INDENT_INCR;
            g.INLINE_STMT_RESET = g.STMT_NUM();
            g.STMT_NUM(g.INX[g.PTR[g.MP]]);
            g.INX[g.PTR[g.MP]] = 0;
            if g.PSEUDO_TYPE[g.PTR[g.MP]] == g.MAJ_STRUC: 
                g.FIXL[g.MP] = g.PSEUDO_LENGTH[g.PTR[g.MP]];
            RESET_ARRAYNESS();
            g.INLINE_LEVEL = g.INLINE_LEVEL - 1;
            g.NEST_LEVEL = g.NEST_LEVEL - 1;
            if g.INLINE_LEVEL == 0: 
                g.STAB_MARK = 0
                g.STAB2_MARK = 0;
                g.XSET(g.STAB_STACK[0]);
                g.SRN_FLAG = g.FALSE;
                g.SRN[2] = SRN_MARK[:];
                g.INCL_SRN[2] = INCL_SRN_MARK[:];
                g.SRN_COUNT[2] = SRN_COUNT_MARK;
            g.FIXF[g.MP] = 0;
        else:
            BLOCK_SUMMARY();
            g.OUTER_REF_INDEX = (g.OUTER_REF_PTR[g.NEST] & 0x7FFF) - 1;
            g.INDENT_LEVEL = g.INDENT_STACK[g.NEST];
            g.NEST_LEVEL = g.NEST_STACK[g.NEST];
        g.REGULAR_PROCMARK = g.PROCMARK_STACK[g.NEST];
        g.PROCMARK = g.REGULAR_PROCMARK
        g.SCOPEp = g.SCOPEp_STACK[g.NEST];
        g.I = 0;
        while g.ON_ERROR_PTR < -g.SYT_ARRAY(g.BLOCK_SYTREF[g.NEST]):
            if h.EXT_ARRAY[g.ON_ERROR_PTR] == 0x3FFF: 
                g.I = g.I + 0x1001;
            else:
                g.I = g.I + 1;
            g.ON_ERROR_PTR = g.ON_ERROR_PTR + 1;
        g.SYT_ARRAY(g.BLOCK_SYTREF[g.NEST], g.I | 0xE000);
        g.NEST = g.NEST - 1;
        g.DO_INX[g.DO_LEVEL] = g.DO_INX[g.DO_LEVEL] & 0x7F;
        if g.NEST == 0:
            if g.EXTERNAL_MODE > 0: 
                if g.SIMULATING == 2:
                    g.STMT_TYPE = 0;
                    g.SIMULATING = 1;
                g.EXTERNAL_MODE = 0;
                g.TPL_VERSION = g.BLOCK_SYTREF[g.NEST + 1];
                g.SYT_LOCKp(g.TPL_VERSION, 0);
            elif g.BLOCK_MODE[0] > 0:
                if g.EXTERNALIZE == 4: 
                    g.EXTERNALIZE = 2;
                EMIT_EXTERNAL();
    if goto == "CHECK_DECLS" or \
            (goto == None and PRODUCTION_NUMBER == 295):  # reference 2950
        #  <BLOCK BODY>  ::=  <DECLARE GROUP>
        if goto == None:
            HALMAT_POP(g.XEDCL, 0, g.XCO_N, 1);
        if goto == "CHECK_DECLS": goto = None
        g.I = g.BLOCK_MODE[g.NEST];
        if (g.I == g.FUNC_MODE) or (g.I == g.PROC_MODE): 
            g.J = g.BLOCK_SYTREF[g.NEST];  # PROC FUNC NAME
            if g.SYT_PTR(g.J) != 0: 
                g.J = g.SYT_PTR(g.J);  # POINT TO FIRST ARG
                while (g.SYT_FLAGS(g.J) & g.PARM_FLAGS) != 0:
                    if (g.SYT_FLAGS(g.J) & g.IMP_DECL) != 0:
                        # UNDECLARED PARAMETER
                        ERROR(d.CLASS_DU, 2, g.SYT_NAME(g.J));
                        g.PARMS_PRESENT = 0;
                        g.SYT_TYPE(g.J, g.DEFAULT_TYPE);
                        g.SYT_FLAGS(g.J, g.SYT_FLAGS(g.J) | g.DEFAULT_ATTR);
                    g.J = g.J + 1;  # NEXT PARAMETER
                if (g.EXTERNAL_MODE > 0) and (g.EXTERNAL_MODE < g.CMPL_MODE):
                    while g.J <= g.NDECSY():
                        if g.SYT_CLASS(g.J) < g.REPL_ARG_CLASS:
                            ERROR(d.CLASS_DU, 3, g.SYT_NAME(g.J));
                            g.SYT_FLAGS(g.J, g.SYT_FLAGS(g.J) | g.DUMMY_FLAG);
                    g.J = g.J + 1;
        if g.EXTERNALIZE & 1: 
            g.EXTERNALIZE = 4;
        g.PTR[g.MP] = 0;
    if goto == "INLINE_DEFS" or \
            (goto == None and PRODUCTION_NUMBER == 297):  # reference 2970
        #  <ARITH INLINE DEF>  ::=  FUNCTION <ARITH SPEC>  ;
        if goto == None:
            if g.TYPE == 0: 
                g.TYPE = g.DEFAULT_TYPE;
            if (g.ATTRIBUTES & g.SD_FLAGS) == 0: 
                g.ATTRIBUTES = g.ATTRIBUTES | (g.DEFAULT_ATTR & g.SD_FLAGS);
            if g.TYPE < g.SCALAR_TYPE: 
                g.TEMP = g.TYPEf(g.TYPE);
            else:
                g.TEMP = 0;
        if goto == "INLINE_DEFS": goto = None
        if g.CONTEXT == g.EXPRESSION_CONTEXT: 
            ERROR(d.CLASS_PP, 11);
        g.CONTEXT = 0;
        g.GRAMMAR_FLAGS(g.STACK_PTR[g.MP], \
                        g.GRAMMAR_FLAGS(g.STACK_PTR[g.MP]) | g.INLINE_FLAG);
        g.PTR[g.MP] = PUSH_INDIRECT(1);
        g.INLINE_LEVEL = g.INLINE_LEVEL + 1;
        if g.INLINE_LEVEL > 1: 
            ERROR(d.CLASS_PP, 10);
        else:
            g.STAB_MARK = g.STAB_STACKTOP;
            g.STAB2_MARK = g.STAB2_STACKTOP;
            g.STAB_STACK[0] = g.STMT_TYPE;
            g.SRN_MARK = g.SRN[2][:];
            g.INCL_SRN_MARK = g.INCL_SRN[2][:];
            g.SRN_COUNT_MARK = g.SRN_COUNT[2];
            g.STMT_TYPE = 0;
        g.INLINE_LABEL = g.INLINE_LABEL + 1;
        g.VAR[g.MP] = l.INLINE_NAME + g.INLINE_LABEL;
        g.NAME_HASH = HASH(g.VAR[g.MP], g.SYT_HASHSIZE);
        g.FIXL[g.MP] = ENTER(g.VAR[g.MP], g.FUNC_CLASS);
        g.FIXL[g.MP] = g.I
        if g.SIMULATING: 
            STAB_LAB(g.I);
        SET_XREF(g.I, g.XREF_REF);
        g.SYT_TYPE(g.I, g.TYPE);
        g.SYT_FLAGS(g.I, g.SYT_FLAGS(g.I) | g.DEFINED_LABEL | g.ATTRIBUTES);
        g.VAR_LENGTH(g.I, g.TEMP);
        HALMAT_POP(g.XIDEF, 1, 0, g.INLINE_LEVEL);
        HALMAT_PIP(g.I, g.XSYT, 0, 0);
        SETUP_VAC(g.MP, g.TYPE, g.TEMP);
        g.TEMP2 = g.INLINE_MODE;
        # See the comments in g.py for TYPE to understand the next few lines
        clearListTYPE()
        SAVE_ARRAYNESS();
        if (g.SUBSCRIPT_LEVEL | g.EXPONENT_LEVEL) != 0: 
            ERROR(d.CLASS_B, 2);
        goto = "INLINE_ENTRY"
    if goto == "UPDATE_HEAD" or \
            (goto == None and PRODUCTION_NUMBER == 314):  # reference 3140
        #  <BLOCK STMT HEAD>  ::=  <LABEL DEFINITION>  UPDATE
        if goto == None:
            g.VAR_LENGTH(g.FIXL[g.MP], 1);
            HALMAT_BACKUP(g.LAST_POPp);
        if goto == "UPDATE_HEAD": goto = None
        if g.UPDATE_BLOCK_LEVEL > 0: 
            ERROR(d.CLASS_UI, 2);
        g.UPDATE_BLOCK_LEVEL = g.UPDATE_BLOCK_LEVEL + 1;
        g.TEMP2 = g.UPDATE_MODE;
        g.TEMP = g.XUDEF;
        SET_LABEL_TYPE(g.FIXL[g.MP], g.STMT_LABEL);
        if g.NEST == 0: 
            ERROR(d.CLASS_PP, 3, g.VAR[g.MPP1]);
            goto = "DUPLICATE_BLOCK"
        else:
            goto = "NEW_SCOPE"
    if goto == "FUNC_HEADER" or \
            (goto == None and PRODUCTION_NUMBER == 316):  # reference 3160
        #  <BLOCK STMT HEAD>  ::=  <FUNCTION NAME>
        if goto == "FUNC_HEADER": goto = None
        if g.PARMS_PRESENT == 0:
            g.PARMS_WATCH = g.FALSE;
            if g.MAIN_SCOPE == g.SCOPEp: 
                g.COMSUB_END(g.FIXL[g.MP]);
        g.FACTORING = g.TRUE;
        g.DO_INIT = g.FALSE;
        if g.TYPE == 0:
            g.TYPE = g.DEFAULT_TYPE;
        elif g.TYPE == g.EVENT_TYPE:
            ERROR(d.CLASS_FT, 3, g.SYT_NAME(g.ID_LOC));
            g.TYPE = g.DEFAULT_TYPE;
        if (g.ATTRIBUTES & g.SD_FLAGS) == 0:
            if (g.TYPE >= g.MAT_TYPE) and (g.TYPE <= g.INT_TYPE):
                g.ATTRIBUTES = g.ATTRIBUTES | (g.DEFAULT_ATTR & g.SD_FLAGS);
        if g.TYPE == g.MAJ_STRUC: 
            CHECK_STRUC_CONFLICTS();
        if g.SYT_TYPE(g.ID_LOC) == 0: 
            SET_SYT_ENTRIES();
        else:
            if g.SYT_TYPE(g.ID_LOC) != g.TYPE:
                ERROR(d.CLASS_DT, 1, g.SYT_NAME(g.ID_LOC));
            else:  # TYPES MATCH, WHAT ABOUT SIZES
               if g.TYPE <= g.VEC_TYPE:
                    if g.TYPEf(g.TYPE) != g.VAR_LENGTH(g.ID_LOC):
                        ERROR(d.CLASS_FT, 4, g.SYT_NAME(g.ID_LOC));
               elif g.TYPE == g.MAJ_STRUC: 
                    if g.STRUC_PTR != g.VAR_LENGTH(g.ID_LOC):
                        ERROR(d.CLASS_FT, 6, g.SYT_NAME(g.ID_LOC));
               if (g.ATTRIBUTES & g.SD_FLAGS) != 0:
                    if ((g.SYT_FLAGS(g.ID_LOC) & g.ATTRIBUTES) & g.SD_FLAGS) == 0:
                        ERROR(d.CLASS_FT, 7, g.SYT_NAME(g.ID_LOC));
            # END OF TYPES MATCH
            # See the comments in g.py for TYPE to understand the next few lines
            clearListTYPE()
    if goto == "EMIT_NULL" or \
            (goto == None and PRODUCTION_NUMBER == 334):  # reference 3340
        #  <DECLARE ELEMENT>  ::=  <REPLACE STMT>  ;
        if goto == None:
            g.STMT_TYPE = c19.REPLACE_STMT_TYPE;
            if g.SIMULATING: 
                STAB_HDR();
        if goto == "EMIT_NULL": goto = None
        OUTPUT_WRITER();
        EMIT_SMRK(1);
    if goto == "INIT_MACRO" or \
            (goto == None and PRODUCTION_NUMBER == 338):  # reference 3380
        #  <REPLACE HEAD>  ::=  <IDENTIFIER>
        if goto == "INIT_MACRO": goto = None
        g.CONTEXT = 0;
        g.MACRO_TEXT(g.FIRST_FREE(), 0xEF);  # INITIALIZE TO NULL
    if goto == "NEXT_ARG" or \
            (goto == None and PRODUCTION_NUMBER == 340):  # reference 3400
        #  <ARG LIST>  ::=  <IDENTIFIER>
        if goto == "NEXT_ARG": goto = None
        g.MACRO_ARG_COUNT = g.MACRO_ARG_COUNT + 1 ;
        if g.MACRO_ARG_COUNT > g.MAX_PARAMETER:
            ERROR(d.CLASS_IR, 10);
    if goto == "DECL_STAT" or \
            (goto == None and PRODUCTION_NUMBER == 343):  # reference 3430
        #  <DECLARE STATEMENT>  ::=  DECLARE  <DECLARE BODY>  ;
        if goto == None:
            if g.PARMS_PRESENT <= 0: 
                g.PARMS_WATCH = g.FALSE;
                if g.EXTERNALIZE & 1: 
                    g.EXTERNALIZE = 4;
        if goto == "DECL_STAT": goto = None
        g.FACTORING = g.TRUE;
        if g.IC_FOUND > 0: 
            g.IC_LINE = g.INX[g.IC_PTR1];
            g.PTR_TOP = g.IC_PTR1 - 1;
        g.IC_FOUND = 0;
        if g.ATTR_LOC > 1: 
            OUTPUT_WRITER(g.LAST_WRITE, g.ATTR_LOC - 1);
            if not g.ATTR_FOUND: 
                if (g.GRAMMAR_FLAGS(1) & g.ATTR_BEGIN_FLAG) != 0:
                    g.INDENT_LEVEL = g.INDENT_LEVEL + g.ATTR_INDENT + g.INDENT_INCR;
            elif g.INDENT_LEVEL == g.SAVE_INDENT_LEVEL:
                g.INDENT_LEVEL = g.INDENT_LEVEL + g.ATTR_INDENT;
            OUTPUT_WRITER(g.ATTR_LOC, g.STMT_PTR);
        else:
            OUTPUT_WRITER(g.LAST_WRITE, g.STMT_PTR);
        g.INDENT_LEVEL = g.SAVE_INDENT_LEVEL;
        g.LAST_WRITE = 0
        g.SAVE_INDENT_LEVEL = 0;
    if goto == "NO_ATTR_STRUCT" or \
            (goto == None and PRODUCTION_NUMBER == 352):  # reference 3520
        #  <STRUCT STMT HEAD>  ::=  <IDENTIFIER>  :  <LEVEL>
        if goto == "NO_ATTR_STRUCT": goto = None
        g.BUILDING_TEMPLATE = g.TRUE;
        g.FIXL[g.MPP1] = g.FIXL[g.MP];
        g.ID_LOC = g.FIXL[g.MPP1]
        g.STRUC_SIZE = 0;
        g.REF_ID_LOC = g.ID_LOC;
        if g.FIXV[g.SP] > 1: 
            ERROR(d.CLASS_DQ, 1);
        g.FIXV[g.MP] = 1;
        g.SYT_CLASS(g.ID_LOC, g.TEMPLATE_CLASS);
        g.SYT_TYPE(g.ID_LOC, g.TEMPL_NAME);
        if (g.ATTRIBUTES & g.ILL_TEMPL_ATTR) != 0 or \
                (g.ATTRIBUTES2 & g.NONHAL_FLAG) != 0: 
            ERROR(d.CLASS_DA, 22, g.SYT_NAME(g.ID_LOC));
            g.ATTRIBUTES = g.ATTRIBUTES & ~g.ILL_TEMPL_ATTR;
            g.ATTRIBUTES2 = g.ATTRIBUTES2 & ~g.NONHAL_FLAG;
            g.DO_INIT = g.FALSE;
        if (g.ATTRIBUTES & g.ALDENSE_FLAGS) == 0:
            g.ATTRIBUTES = g.ATTRIBUTES | (g.DEFAULT_ATTR & g.ALDENSE_FLAGS);
        g.SYT_FLAGS(g.ID_LOC, g.SYT_FLAGS(g.ID_LOC) | g.ATTRIBUTES);
        HALMAT_INIT_CONST();
        # See the comments in g.py for TYPE to understand the next few lines
        clearListTYPE()
        g.SAVE_INDENT_LEVEL = g.INDENT_LEVEL;
        if g.STACK_PTR[g.SP] > 0:
            OUTPUT_WRITER(0, g.STACK_PTR[g.SP] - 1);
        g.LAST_WRITE = g.STACK_PTR[g.SP];
        g.INDENT_LEVEL = g.SAVE_INDENT_LEVEL + g.INDENT_INCR;  # IN BY ONE LEVEL
        goto = "STRUCT_GOING_DOWN"
    if goto in ["STRUCT_GOING_UP", "STRUCT_GOING_DOWN"] or \
            (goto == None and PRODUCTION_NUMBER == 354):  # reference 3540
        #  <STRUCT STMT HEAD> ::= <STRUCT STMT HEAD> <DECLARATION> , <LEVEL>
        if goto in [None, "STRUCT_GOING_UP"]:
            if goto == "STRUCT_GOING_UP": goto = None
            if (g.SYT_FLAGS(g.ID_LOC) & g.DUPL_FLAG) != 0:
                g.SYT_FLAGS(g.ID_LOC, g.SYT_FLAGS(g.ID_LOC) & (~g.DUPL_FLAG));
                g.S = g.SYT_NAME(g.ID_LOC);
                g.TEMP_SYN = g.SYT_LINK1(g.FIXL[g.MP]);
                while g.TEMP_SYN != g.ID_LOC:
                    if g.S == g.SYT_NAME(g.TEMP_SYN):
                        ERROR(d.CLASS_DQ, 9, g.S);
                        g.S = '';
                    g.TEMP_SYN = g.SYT_LINK2(g.TEMP_SYN);
        if goto == "STRUCT_GOING_DOWN" or \
                (goto == None and g.FIXV[g.SP] > g.FIXV[g.MP]):
            if goto == None: 
                if g.FIXV[g.SP] > g.FIXV[g.MP] + 1: 
                    ERROR(d.CLASS_DQ, 2);
                g.FIXV[g.MP] = g.FIXV[g.MP] + 1;
                if (g.TYPE | g.CLASS) != 0:
                    ERROR(d.CLASS_DT, 5, g.SYT_NAME(g.ID_LOC));  # TYPE NOT LEGAL
                if (g.ATTRIBUTES & g.ILL_MINOR_STRUC) != 0 or g.NAME_IMPLIED or \
                        (g.ATTRIBUTES2 & g.NONHAL_FLAG) != 0: 
                    ERROR(d.CLASS_DA, 20, g.SYT_NAME(g.ID_LOC));
                    g.ATTRIBUTES = g.ATTRIBUTES & (~g.ILL_MINOR_STRUC);
                    g.ATTRIBUTES2 = g.ATTRIBUTES2 & (~g.NONHAL_FLAG);
                    g.NAME_IMPLIED = g.FALSE;
                    g.DO_INIT = 0;
                if g.N_DIM != 0: 
                    ERROR(d.CLASS_DA, 21, g.SYT_NAME(g.ID_LOC));
                    g.N_DIM = 0;
                    g.ATTRIBUTES = g.ATTRIBUTES & (~g.ARRAY_FLAG);
                g.SYT_CLASS(g.ID_LOC, g.TEMPLATE_CLASS);
                g.TYPE = g.MAJ_STRUC;
                if (g.ATTRIBUTES & g.ALDENSE_FLAGS) == 0:
                    g.ATTRIBUTES = g.ATTRIBUTES | (g.SYT_FLAGS(g.FIXL[g.MP]) & g.ALDENSE_FLAGS);
                # GIVE ALIGNED/DENSE OF PARENT IF NOT LOCALLY SPECIFIED
                if (g.ATTRIBUTES & g.RIGID_FLAG) == 0:
                    g.ATTRIBUTES = g.ATTRIBUTES | (g.SYT_FLAGS(g.FIXL[g.MP]) & g.RIGID_FLAG);
                SET_SYT_ENTRIES();
                if g.STACK_PTR[g.SP] > 0:
                    OUTPUT_WRITER(g.LAST_WRITE, g.STACK_PTR[g.SP] - 1);
                g.LAST_WRITE = g.STACK_PTR[g.SP];
                g.INDENT_LEVEL = g.SAVE_INDENT_LEVEL + (g.FIXV[g.MP] * g.INDENT_INCR);
            if goto == "STRUCT_GOING_DOWN": goto = None
            PUSH_INDIRECT(1);
            g.LOC_P[g.PTR_TOP] = g.FIXL[g.MP];
            g.SYT_LINK1(g.FIXL[g.MPP1], g.FIXL[g.MPP1] + 1);
            g.FIXL[g.MP] = g.FIXL[g.MPP1];
        else:
            g.TEMP_SYN = g.FIXL[g.MPP1];
            g.FIXL[g.SP] = g.FIXL[g.MP];
            while g.FIXV[g.SP] < g.FIXV[g.MP]:
                g.SYT_LINK2(g.FIXL[g.MPP1], -g.FIXL[g.MP]);
                g.FIXL[g.MPP1] = g.FIXL[g.MP];
                g.FIXL[g.MP] = g.LOC_P[g.PTR_TOP];
                g.PTR_TOP = g.PTR_TOP - 1;
                g.FIXV[g.MP] = g.FIXV[g.MP] - 1;
            if g.TYPE == 0: 
                g.TYPE = g.DEFAULT_TYPE;
            elif g.TYPE == g.MAJ_STRUC: 
                if not g.NAME_IMPLIED:
                    if g.STRUC_PTR == g.REF_ID_LOC:
                        ERROR(d.CLASS_DT, 6);
                        g.SYT_FLAGS(g.REF_ID_LOC, g.SYT_FLAGS(g.REF_ID_LOC) | g.EVIL_FLAG);
            if g.CLASS != 0: 
                if g.NAME_IMPLIED:
                    g.ATTRIBUTES = g.ATTRIBUTES | g.DEFINED_LABEL;
                    if g.TYPE == g.PROC_LABEL: 
                        ERROR(d.CLASS_DA, 14, g.SYT_NAME(g.ID_LOC));
                    elif g.CLASS == 2: 
                        ERROR(d.CLASS_DA, 13, g.SYT_NAME(g.ID_LOC));
                else:
                    ERROR(d.CLASS_DT, 7, g.SYT_NAME(g.ID_LOC));
                    g.CLASS = 0;
                    if g.TYPE > g.ANY_TYPE: 
                        g.TYPE = g.DEFAULT_TYPE;
            CHECK_CONSISTENCY();
            if (g.ATTRIBUTES & g.ILL_TERM_ATTR[g.NAME_IMPLIED]) != 0 or \
                    (g.ATTRIBUTES2 & g.NONHAL_FLAG) != 0:
                ERROR(d.CLASS_DA, 23, g.SYT_NAME(g.ID_LOC));
                #  ILL_NAME_ATTR MUST BE SUBSET OF ILL_TERM_ATTR
                g.ATTRIBUTES = (~g.ILL_TERM_ATTR[g.NAME_IMPLIED]) & g.ATTRIBUTES;
                g.ATTRIBUTES2 = (~g.NONHAL_FLAG) & g.ATTRIBUTES2;
                g.DO_INIT = g.FALSE;
            g.SYT_CLASS(g.ID_LOC, g.TEMPLATE_CLASS + g.CLASS);
            if g.TYPE == g.MAJ_STRUC: 
                CHECK_STRUC_CONFLICTS();
            elif g.TYPE == g.EVENT_TYPE: 
                CHECK_EVENT_CONFLICTS();
            if (g.ATTRIBUTES & g.SD_FLAGS) == 0:
                if (g.TYPE >= g.MAT_TYPE) and (g.TYPE <= g.INT_TYPE):
                    g.ATTRIBUTES = g.ATTRIBUTES | (g.DEFAULT_ATTR & g.SD_FLAGS);
            if (g.ATTRIBUTES & g.ALDENSE_FLAGS) == 0:
                if (not g.NAME_IMPLIED) and ((g.ATTRIBUTES & g.ARRAY_FLAG) == 0) and \
                        (g.TYPE == g.BIT_TYPE):
                    g.ATTRIBUTES = g.ATTRIBUTES | (g.SYT_FLAGS(g.FIXL[g.SP]) & g.ALDENSE_FLAGS);
                else:
                    g.ATTRIBUTES = g.ATTRIBUTES | g.ALIGNED_FLAG;
            if (g.ATTRIBUTES & g.RIGID_FLAG) == 0:
                g.ATTRIBUTES = g.ATTRIBUTES | (g.SYT_FLAGS(g.FIXL[g.SP]) & g.RIGID_FLAG);
            if g.NAME_IMPLIED: 
                g.SYT_FLAGS(g.REF_ID_LOC, g.SYT_FLAGS(g.REF_ID_LOC) | g.MISC_NAME_FLAG);
            SET_SYT_ENTRIES();
            g.STRUC_SIZE = ICQ_TERMp(g.ID_LOC) * ICQ_ARRAYp(g.ID_LOC) + g.STRUC_SIZE;
            g.NAME_IMPLIED = g.FALSE;
            if g.FIXV[g.SP] > 0: 
                g.SYT_LINK2(g.FIXL[g.MPP1], g.TEMP_SYN + 1);
                if g.STACK_PTR[g.SP] > 0:
                    OUTPUT_WRITER(g.LAST_WRITE, g.STACK_PTR[g.SP] - 1);
                g.LAST_WRITE = g.STACK_PTR[g.SP];
                g.INDENT_LEVEL = g.SAVE_INDENT_LEVEL + (g.FIXV[g.MP] * g.INDENT_INCR);
            else:
                g.BUILDING_TEMPLATE = g.FALSE;
                OUTPUT_WRITER(g.LAST_WRITE, g.STMT_PTR);
                g.INDENT_LEVEL = g.SAVE_INDENT_LEVEL;
                g.LAST_WRITE = 0
                g.SAVE_INDENT_LEVEL = 0;
    if goto == "SPEC_VAR" or \
            (goto == None and PRODUCTION_NUMBER == 361):  # reference 3610
        #  <DECLARATION>  ::=  <NAME ID>  <ATTRIBUTES>
        if (goto == None and not g.BUILDING_TEMPLATE) or goto == "SPEC_VAR":
            if goto == None:
                if (g.TOKEN_FLAGS(0) & 7) == 7: 
                    g.ATTR_LOC = 0;
                elif (g.TOKEN_FLAGS(1) & 7) == 7: 
                    g.ATTR_LOC = 1;
                else:
                    g.ATTR_LOC = MAX(0, g.STACK_PTR[g.MP]);
            if goto == "SPEC_VAR": goto = None
            g.DO_INIT = g.TRUE;
            CHECK_CONFLICTS();
            g.I = g.SYT_FLAGS(g.ID_LOC);
            if (g.I & g.PARM_FLAGS) != 0:
                g.PARMS_PRESENT = g.PARMS_PRESENT - 1;
                if g.PARMS_PRESENT == 0 and g.PARMS_WATCH: 
                    g.COMSUB_END(g.NDECSY());
                if (g.ATTRIBUTES & g.ILL_INIT_ATTR) != 0: 
                    ERROR(d.CLASS_DI, 12, g.VAR[g.MP]);
                    g.DO_INIT = g.FALSE;
                    g.ATTRIBUTES = g.ATTRIBUTES & (~g.ILL_INIT_ATTR);
                if g.CLASS > 0 & (not g.NAME_IMPLIED): 
                    ERROR(d.CLASS_D, 1, g.VAR[g.MP]);
                    g.NONHAL = 0
                    g.CLASS = 0;
                    if g.TYPE > g.ANY_TYPE: 
                        g.TYPE = g.DEFAULT_TYPE;
                #  REMOTE NOW OK FOR ASSIGN PARMS & IGNORED FOR INPUT PARMS
                #  SO REMOVE D14 ERROR MESSAGE.
            elif g.PARMS_WATCH: 
                ERROR(d.CLASS_D, 15);
            if g.TYPE == g.EVENT_TYPE: 
                CHECK_EVENT_CONFLICTS();
            nonHAL = False
            firstTry = True
            while firstTry or goto == "FIX_AUTSTAT":
                firstTry = False
                if (goto == None and not g.NAME_IMPLIED) \
                        or goto  == "FIX_AUTSTAT":
                    if goto == None:
                        if g.NONHAL > 0:
                            if g.TYPE == g.PROC_LABEL or g.CLASS == 2:
                                g.ATTRIBUTES = g.ATTRIBUTES | g.EXTERNAL_FLAG | g.DEFINED_LABEL;
                                g.SYT_ARRAY(g.ID_LOC, g.NONHAL | 0xFF00);
                                goto = "MODE_CHECK"
                            else:
                                ERROR(d.CLASS_D, 11, g.VAR[g.MP]);
                                #   DISCONNECT SYT_FLAGS WITH NONHAL
                                #   THIS ALSO DISCONNECTS ATTRIBUTES WITH NONHAL
                                g.SYT_FLAGS2(g.ID_LOC, g.SYT_FLAGS2(g.ID_LOC) & (~g.NONHAL_FLAG));
                                nonHAL = True
                        if nonHAL and goto == None:
                            pass
                        elif goto == "MODE_CHECK" or \
                                (goto == None and g.CLASS == 2):
                            if goto == "MODE_CHECK": goto = None
                            if g.BLOCK_MODE[g.NEST] == g.CMPL_MODE: 
                                ERROR(d.CLASS_D, 2, g.VAR[g.MP]);
                        elif g.CLASS == 1:
                            if g.TYPE == g.TASK_LABEL:
                                if g.NEST > 1 | g.BLOCK_MODE[1] != g.PROG_MODE:
                                    ERROR(d.CLASS_PT, 1);
                            else:
                                ERROR(d.CLASS_DN, 1, g.VAR[g.MP]);
                                g.CLASS = 0;
                                g.TYPE = g.DEFAULT_TYPE;
                    if goto == None and g.CLASS != 0:
                        if (g.ATTRIBUTES & g.ILL_INIT_ATTR) != 0:
                            ERROR(d.CLASS_DI, 13, g.VAR[g.MP]);
                            g.ATTRIBUTES = g.ATTRIBUTES & (~g.ILL_INIT_ATTR);
                            g.DO_INIT = g.FALSE;
                        if g.TEMPORARY_IMPLIED: 
                            ERROR(d.CLASS_D, 8, g.VAR[g.MP]);
                            g.CLASS = 0;
                            if g.TYPE > g.ANY_TYPE: 
                                g.TYPE = g.DEFAULT_TYPE;
                    elif goto == None and g.TEMPORARY_IMPLIED: 
                        if (g.ATTRIBUTES & g.ILL_TEMPORARY_ATTR) != 0 or \
                                (g.ATTRIBUTES2 & g.NONHAL_FLAG) != 0:
                            ERROR(d.CLASS_D, 8, g.VAR[g.MP]);
                            g.ATTRIBUTES = g.ATTRIBUTES & (~g.ILL_TEMPORARY_ATTR);
                            g.ATTRIBUTES2 = g.ATTRIBUTES2 & (~g.NONHAL_FLAG);
                            g.DO_INIT = g.FALSE;
                    else:
                        if goto == "FIX_AUTSTAT": goto = None
                        if (g.ATTRIBUTES & g.ALDENSE_FLAGS) == 0:
                            g.ATTRIBUTES = g.ATTRIBUTES | (g.DEFAULT_ATTR & g.ALDENSE_FLAGS);
                        if g.BLOCK_MODE[g.NEST] != g.CMPL_MODE:
                            if (g.I & g.PARM_FLAGS) == 0:
                                if (g.ATTRIBUTES & g.AUTSTAT_FLAGS) == 0:
                                        g.ATTRIBUTES = g.ATTRIBUTES | (g.DEFAULT_ATTR & g.AUTSTAT_FLAGS);
                else: 
                    # ADD ILLEGAL TEMP ATTRIBUTE CHECKING FROM ABOVE FOR NAME TEMPS TOO
                    if g.TEMPORARY_IMPLIED: 
                        if g.CLASS != 0:
                            ERROR(d.CLASS_D, 8, g.VAR[g.MP]);
                            g.CLASS = 0;
                            if g.TYPE > g.ANY_TYPE: 
                                g.TYPE = g.DEFAULT_TYPE;
                        # ONLY DIFFERENCE FOR NAME TEMPS IS THAT REMOTE IS LEGAL
                        elif (((g.ATTRIBUTES & g.ILL_TEMPORARY_ATTR) != 0) and \
                                ((g.ATTRIBUTES & g.ILL_TEMPORARY_ATTR) != g.REMOTE_FLAG)) or \
                                (g.ATTRIBUTES2 & g.NONHAL_FLAG) != 0:
                            ERROR(d.CLASS_D, 8, g.VAR[g.MP]);
                            g.ATTRIBUTES = g.ATTRIBUTES & (~g.ILL_TEMPORARY_ATTR);
                            g.ATTRIBUTES2 = g.ATTRIBUTES2 & (~g.NONHAL_FLAG);
                            g.DO_INIT = g.FALSE;
                    if (g.ATTRIBUTES & g.ILL_NAME_ATTR) != 0 or \
                            (g.ATTRIBUTES2 & g.NONHAL_FLAG) != 0:
                        ERROR(d.CLASS_D, 12, g.VAR[g.MP]);
                        g.ATTRIBUTES = g.ATTRIBUTES & (~g.ILL_NAME_ATTR);
                        g.ATTRIBUTES2 = g.ATTRIBUTES2 & (~g.NONHAL_FLAG);
                    if g.TYPE == g.PROC_LABEL: 
                        ERROR(d.CLASS_DA, 14, g.VAR[g.MP]);
                    elif g.CLASS == 2: 
                        ERROR(d.CLASS_DA, 13, g.VAR[g.MP]);
                    if g.CLASS > 0: 
                        g.ATTRIBUTES = g.ATTRIBUTES | g.DEFINED_LABEL;
                    goto = "FIX_AUTSTAT"
                    continue
            g.SYT_CLASS(g.ID_LOC, g.VAR_CLASSf(g.CLASS));
            if g.TYPE == g.MAJ_STRUC: 
                CHECK_STRUC_CONFLICTS();
            if (g.ATTRIBUTES & g.SD_FLAGS) == 0: 
                if g.TYPE >= g.MAT_TYPE and g.TYPE <= g.INT_TYPE:
                    g.ATTRIBUTES = g.ATTRIBUTES | (g.DEFAULT_ATTR & g.SD_FLAGS);
            SET_SYT_ENTRIES();
            g.NAME_IMPLIED = g.FALSE;
            if g.TEMPORARY_IMPLIED:
                g.ATTR_INDENT = 10;
                if g.DO_CHAIN[g.DO_LEVEL] == 0:
                    g.DO_CHAIN[g.DO_LEVEL] = g.ID_LOC;
                    HALMAT_POP(g.XTDCL, 1, 0, 0);
                    HALMAT_PIP(g.ID_LOC, g.XSYT, 0, 0);
                else: 
                    g.SYT_LINK1(g.DO_CHAIN[0], g.ID_LOC);
                g.DO_CHAIN[0] = g.ID_LOC;
            else:
                g.ATTR_INDENT = 8;
            # SET REMOTE ATTRIBUTE FOR ALL NON-NAME #D DATA WHEN THE
            # DATA_REMOTE DIRECTIVE IS IN EFFECT
            # (MUST NOT BE AUTOMATIC OR A PARAMETER TO BE #D DATA.)
            if g.DATA_REMOTE: 
                if ((g.SYT_FLAGS(g.ID_LOC) & g.NAME_FLAG) == 0) and \
                        ((g.SYT_FLAGS(g.ID_LOC) & g.TEMPORARY_FLAG) == 0) and \
                        (g.SYT_TYPE(g.ID_LOC) != g.TASK_LABEL) and \
                        (g.SYT_TYPE(g.ID_LOC) != g.PROC_LABEL) and \
                        (g.SYT_CLASS(g.ID_LOC) != g.FUNC_CLASS) and \
                        ((g.SYT_FLAGS(g.BLOCK_SYTREF[g.NEST]) & g.EXTERNAL_FLAG) == 0) and \
                        not (((g.SYT_FLAGS(g.ID_LOC) & g.AUTO_FLAG) != 0) and \
                        ((g.SYT_FLAGS(g.BLOCK_SYTREF[g.NEST]) & g.REENTRANT_FLAG) != 0)) and \
                        ((g.SYT_FLAGS(g.ID_LOC) & g.PARM_FLAGS) == 0):
                    if (g.SYT_FLAGS(g.ID_LOC) & g.REMOTE_FLAG) != 0:
                        ERROR(d.CLASS_XR, 3);
                    if g.SYT_TYPE(g.ID_LOC) == g.EVENT_TYPE:
                        ERROR(d.CLASS_DA, 9);
                    g.SYT_FLAGS(g.ID_LOC, g.SYT_FLAGS(g.ID_LOC) | g.REMOTE_FLAG);
                elif SDL_OPTION and \
                        ((g.SYT_FLAGS(g.ID_LOC) & g.NAME_FLAG) == 0) and \
                        ((g.SYT_FLAGS(g.ID_LOC) & g.PARM_FLAGS) == 0) and \
                        ((g.SYT_FLAGS(g.ID_LOC) & g.REMOTE_FLAG) != 0):
                    ERROR(d.CLASS_XR, 5);
            if ((g.SYT_FLAGS(g.ID_LOC) & g.NAME_FLAG) == 0) and \
                    ((g.SYT_FLAGS(g.ID_LOC) & g.INPUT_PARM) != 0) and \
                    ((g.SYT_FLAGS(g.ID_LOC) & g.REMOTE_FLAG) != 0):
                g.SYT_FLAGS(g.ID_LOC, g.SYT_FLAGS(g.ID_LOC) & ~g.REMOTE_FLAG);
                ERROR(d.CLASS_YD, 100);
    if goto == "CHECK_ARRAY_SPEC" or \
            (goto == None and PRODUCTION_NUMBER == 365):  # reference 3650
        #  <ATTRIBUTES> ::= <ARRAY SPEC>
        if goto == "CHECK_ARRAY_SPEC": goto = None
        if g.N_DIM > 1:
            if g.STARRED_DIMS > 0:
                ERROR(d.CLASS_DD, 6);
                for g.I in range(0, 1 + g.N_DIM - 1):
                    if g.S_ARRAY[g.I] == -1:
                        g.S_ARRAY[g.I] = 2;  # DEFAULT
        goto = "MAKE_ATTRIBUTES"
    if goto == "MAKE_ATTRIBUTES" or \
            (goto == None and PRODUCTION_NUMBER == 366):  # reference 3660
        #  <ATTRIBUTES> ::= <TYPE & MINOR ATTR>
        if goto == "MAKE_ATTRIBUTES": goto = None
        g.GRAMMAR_FLAGS(g.STACK_PTR[g.MP], \
                        g.GRAMMAR_FLAGS(g.STACK_PTR[g.MP]) | g.ATTR_BEGIN_FLAG);
        CHECK_CONSISTENCY();
        if g.FACTORING:
            # See the comments in g.py for TYPE to understand the next few lines
            g.FACTORED_TYPE = g.TYPE
            g.FACTORED_BIT_LENGTH = g.BIT_LENGTH
            g.FACTORED_CHAR_LENGTH = g.CHAR_LENGTH
            g.FACTORED_MAT_LENGTH = g.MAT_LENGTH
            g.FACTORED_VEC_LENGTH = g.VEC_LENGTH
            g.FACTORED_ATTRIBUTES = g.ATTRIBUTES
            g.FACTORED_ATTRIBUTES2 = g.ATTRIBUTES2
            g.FACTORED_ATTR_MASK = g.ATTR_MASK
            g.FACTORED_STRUC_PTR = g.STRUC_PTR
            g.FACTORED_STRUC_DIM = g.STRUC_DIM
            g.FACTORED_CLASS = g.CLASS
            g.FACTORED_NONHAL = g.NONHAL
            g.FACTORED_LOCKp = g.LOCKp
            g.FACTORED_IC_PTR = g.IC_PTR
            g.FACTORED_IC_FND = g.IC_FND
            g.FACTORED_N_DIM = g.N_DIM
            g.FACTORED_S_ARRAY = g.S_ARRAY
            clearListTYPE()
            # (End of TYPE/FACTORED_TYPE loop)----------------------------------
            g.FACTOR_FOUND = g.TRUE;
            if g.FACTORED_IC_FND:
                g.IC_FOUND = 1;  # FOR HALMAT_INIT_CONST
                g.IC_PTR1 = g.FACTORED_IC_PTR;
    if goto == "ARRAY_SPEC" or \
            (goto == None and PRODUCTION_NUMBER == 373):  # reference 3730
        #  <ARRAY HEAD> ::= <ARRAY HEAD> <LITERAL_EXP OR *> ,
        if goto == "ARRAY_SPEC": goto = None
        if g.N_DIM >= g.N_DIM_LIM:
            ERROR(d.CLASS_DD, 3);
        else:
            g.K = 2;  # A DEFAULT
            g.I = g.FIXV[g.MPP1];
            if not ((g.I > 1 and g.I <= g.ARRAY_DIM_LIM) or g.I == -1):
                ERROR(d.CLASS_DD, 1);
            else:
                g.K = g.I;
            if g.K == -1: 
                g.STARRED_DIMS = g.STARRED_DIMS + 1;
            g.S_ARRAY[g.N_DIM] = g.K;
            g.N_DIM = g.N_DIM + 1;
    if goto == "SPEC_TYPE" or \
            (goto == None and PRODUCTION_NUMBER == 375):  # reference 3750
        #  <TYPE & MINOR ATTR> ::= <TYPE SPEC> <MINOR ATTR LIST>
        if goto == "SPEC_TYPE": goto = None
        if g.CLASS & 1:
            ERROR(d.CLASS_DC, 1);
            g.CLASS = 0;
    if goto == "INCORPORATE_ATTR" or \
            (goto == None and PRODUCTION_NUMBER == 400):  # reference 4000
        #  <MINOR ATTR LIST> ::= <MINOR ATTR LIST> <MINOR ATTRIBUTE>
        if goto == "INCORPORATE_ATTR": goto = None
        if (g.ATTR_MASK & g.FIXL[g.SP]) != 0:
            ERROR(d.CLASS_DA, 25);
        else:
            g.ATTR_MASK = g.ATTR_MASK | g.FIXL[g.SP];
            g.ATTRIBUTES = g.ATTRIBUTES | g.FIXV[g.SP];
    if goto == "SET_AUTSTAT" or \
            (goto == None and PRODUCTION_NUMBER == 401):  # reference 4010
        #  <MINOR ATTRIBUTE> ::= STATIC
        if not goto == "SET_AUTSTAT":
            g.I = g.STATIC_FLAG;
        if goto == "SET_AUTSTAT": goto = None
        if g.BLOCK_MODE[g.NEST] == g.CMPL_MODE:
            ERROR(d.CLASS_DC, 2);
        else:
            g.FIXL[g.MP] = g.AUTSTAT_FLAGS;
            g.FIXV[g.MP] = g.I;
    if goto == "DO_QUALIFIED_ATTRIBUTE" or \
            (goto == None and PRODUCTION_NUMBER == 409):  # reference 4090
        #  <MINOR ATTRIBUTE> ::= <INIT/CONST HEAD> <REPEATED CONSTANT> )
        if goto == None:
            g.PSEUDO_TYPE[g.PTR[g.MP]] = 0;  # NO "*"
        if goto == "DO_QUALIFIED_ATTRIBUTE": goto = None
        g.BI_FUNC_FLAG = g.FALSE;
        CHECK_IMPLICIT_T();
        g.CONTEXT = g.DECLARE_CONTEXT;
        if (g.NUM_ELEMENTS >= g.NUM_EL_MAX) or (g.NUM_ELEMENTS < 1):
            ERROR(d.CLASS_DI, 2);
        g.LOC_P[g.PTR[g.MP]] = g.NUM_ELEMENTS;  # SAVE NUMBER OF ELEMENTS TO SET
        g.VAL_P[g.PTR[g.MP]] = g.NUM_FL_NO;  # SAVE NUMBER OF GVR'S USED
        g.PSEUDO_LENGTH[g.PTR[g.MP]] = g.NUM_STACKS;  # INDICATE LENGTH OF LIST
        g.IC_PTR = g.PTR[g.MP];  # SAVE PTR TO THIS g.I/C LIST
        g.IC_FND = g.TRUE;
        if g.BUILDING_TEMPLATE: 
            g.PTR_TOP = g.PTR[g.MP] - 1;
        # KILL STACKS IF STRUCTURE TEMPLATE
    if goto == "DO_INIT_CONST_HEAD" or \
            (goto == None and PRODUCTION_NUMBER == 413):  # reference 4130
        #  <INIT/CONST HEAD> ::= INITIAL (
        if goto == None:
            g.FIXL[g.MP] = g.INIT_CONST;
            g.FIXV[g.MP] = g.INIT_FLAG;
        if goto == "DO_INIT_CONST_HEAD": goto = None
        g.BI_FUNC_FLAG = g.TRUE;
        g.PTR[g.MP] = PUSH_INDIRECT(1);
        g.NUM_ELEMENTS = 0
        g.NUM_FL_NO = 0;
        g.NUM_STACKS = 1;  #  THIS IS FIRST INDIRECT LOC NEEDED
        g.PSEUDO_FORM[g.PTR[g.MP]] = 0;  #  INDICATE g.I/C LIST TOP, IE., STRI
        g.INX[g.PTR[g.MP]] = g.IC_LINE;
    if goto in ["INIT_ELEMENT", "END_REPEAT_INIT"] or \
            (goto == None and PRODUCTION_NUMBER == 418):  # reference 4180
        #  <REPEATED CONSTANT>  ::=  <REPEAT HEAD>  <CONSTANT>
        if goto == None:
            g.TEMP_SYN = 1;
        if goto in [None, "INIT_ELEMENT"]:
            if goto == "INIT_ELEMENT": goto = None
            g.TEMP = g.PTR[g.SP];
            if g.NAME_PSEUDOS:
                g.NAME_PSEUDOS = g.FALSE;
                g.PSEUDO_TYPE[g.TEMP] = g.PSEUDO_TYPE[g.TEMP] | 0x80;
                if (g.VAL_P[g.TEMP] & 0x40) != 0: 
                    ERROR(d.CLASS_DI, 14);
                if (g.VAL_P[g.TEMP] & 0x200) != 0: 
                    ERROR(d.CLASS_DI, 16);
                # LOOK FOR THE 0x4000 VAL_P BIT AND EMIT DI16 ERROR.
                # THE VAL_P 0x4000 BIT INDICATES THE PRESENCE OF A
                # NAME VARIABLE SOMEWHERE INSIDE THE STRUCTURE REFER-
                # ENCE LIST. THE PRESENCE OF A NAME VARIABLE INSIDE
                # A NAME() INITIALIZATION IS A DI16 ERROR CONDITION.
                if (g.VAL_P[g.TEMP] & 0x4000) != 0:
                    ERROR(d.CLASS_DI, 16);
                if g.EXT_P[g.TEMP] != 0: 
                    ERROR(d.CLASS_DI, 15);
                if (g.VAL_P[g.TEMP] & 0x400) == 0: 
                    RESET_ARRAYNESS();
                if g.SYT_CLASS(g.FIXL[g.MP]) == g.TEMPLATE_CLASS:
                    if (((g.SYT_FLAGS(g.FIXV[g.MP]) & g.ASSIGN_PARM) > 0) or \
                            (((g.SYT_FLAGS(g.FIXV[g.MP]) & g.AUTO_FLAG) != 0) and \
                             ((g.SYT_FLAGS(g.BLOCK_SYTREF[g.NEST]) & \
                               g.REENTRANT_FLAG) != 0))):
                        ERROR(d.CLASS_DI, 3);
                elif (((g.SYT_FLAGS(g.FIXL[g.MP]) & g.ASSIGN_PARM) > 0) or \
                        (((g.SYT_FLAGS(g.FIXL[g.MP]) & g.AUTO_FLAG) != 0) and \
                         ((g.SYT_FLAGS(g.BLOCK_SYTREF[g.NEST]) & \
                           g.REENTRANT_FLAG) != 0))):
                    ERROR(d.CLASS_DI, 3);
            elif g.PSEUDO_FORM[g.TEMP] != g.XLIT: 
                ERROR(d.CLASS_DI, 3);
            CHECK_ARRAYNESS();
            SET_INIT(g.LOC_P[g.TEMP], 2, g.PSEUDO_FORM[g.TEMP], g.PSEUDO_TYPE[g.TEMP], g.NUM_ELEMENTS);
            g.NUM_ELEMENTS = g.NUM_ELEMENTS + 1;
            g.NUM_STACKS = g.NUM_STACKS + 1;
        if (goto == None and g.TEMP_SYN) or goto == "END_REPEAT_INIT":
            if goto == "END_REPEAT_INIT": goto = None
            SET_INIT(0, 3, 0, 0, g.NUM_FL_NO);
            g.NUM_FL_NO = g.NUM_FL_NO - 1;
            g.NUM_STACKS = g.NUM_STACKS + 1;
            g.TEMP_SYN = g.NUM_ELEMENTS - g.FIXV[g.MP];
            g.IC_LEN[GET_ICQ(g.FIXL[g.MP])] = g.TEMP_SYN;
            g.NUM_ELEMENTS = g.INX[g.PTR[g.MP]] * g.TEMP_SYN + g.FIXV[g.MP];
        g.PTR_TOP = g.PTR[g.MP] - 1;
    if goto == "DO_CONSTANT" or \
            (goto == None and PRODUCTION_NUMBER == 424):  # reference 4240
        #  <CONSTANT>  ::=  <NUMBER>
        if goto == None:
            g.TEMP_SYN = g.INT_TYPE;
        if goto == "DO_CONSTANT": goto = None
        g.PTR[g.MP] = PUSH_INDIRECT(1);
        g.PSEUDO_TYPE[g.PTR[g.MP]] = g.TEMP_SYN;
        g.PSEUDO_FORM[g.PTR[g.MP]] = g.XLIT;
        g.LOC_P[g.PTR[g.MP]] = g.FIXL[g.MP];
    if goto == "CLOSE_IT" or \
            (goto == None and PRODUCTION_NUMBER == 430):  # reference 4300
        #  <CLOSING> ::= CLOSE
        if goto == None:
            g.VAR[g.MP] = '';
        if goto == "CLOSE_IT": goto = None
        g.INDENT_LEVEL = g.INDENT_LEVEL - g.INDENT_INCR;
        g.XSET(0x6);
    if goto == "TERM_LIST" or \
            (goto == None and PRODUCTION_NUMBER == 436):  # reference 4360
        #  <TERMINATE LIST>  ::=  <TERMINATE LIST>  ,  <LABEL VAR>
        if goto == None:
            g.EXT_P[g.PTR[g.MP]] = g.EXT_P[g.PTR[g.MP]] + 1;
        if goto == "TERM_LIST": goto = None
        SET_XREF_RORS(g.SP, g.FIXV[g.MP - 1]);
        PROCESS_CHECK(g.SP);
    if goto == "SCHEDULE_AT" or \
            (goto == None and PRODUCTION_NUMBER == 439):  # reference 4390
        # <SCHEDULE HEAD>::= <SCHEDULE HEAD> AT <ARITH EXP>
        if goto == None:
            g.TEMP = 0x1;
            if UNARRAYED_SCALAR(g.SP): 
                ERROR(d.CLASS_RT, 1, 'AT');
        if goto == "SCHEDULE_AT": goto = None
        if g.INX[g.REFER_LOC] == 0: 
            g.INX[g.REFER_LOC] = g.TEMP;
        else:
            ERROR(d.CLASS_RT, 5);
            g.PTR_TOP = g.PTR_TOP - 1;
    if goto == "SCHED_PRIO" or \
            (goto == None and PRODUCTION_NUMBER == 442):  # reference 4420
        # <SCHEDULE PHRASE>::=<SCHEDULE HEAD>
        if goto == "SCHED_PRIO": goto = None
        ERROR(d.CLASS_RT, 4, 'SCHEDULE');
    if goto == "SCHEDULE_EVERY" or \
            (goto == None and PRODUCTION_NUMBER == 448):  # reference 4480
        #  <TIMING>  ::=  <REPEAT> EVERY <ARITH EXP>
        if goto == None:
            g.TEMP = 0x20;
        if goto == "SCHEDULE_EVERY": goto = None
        if UNARRAYED_SCALAR(g.SP): 
            ERROR(d.CLASS_RT, 1, 'EVERY/AFTER');
        g.INX[g.REFER_LOC] = g.INX[g.REFER_LOC] | g.TEMP;
    
    # references 3110 and 3210 have GOTO's to each other, so we enclose them
    # together in a mini-loop to let them reach each other easily.
    while goto in ["OUTERMOST_BLOCK", "DUPLICATE_BLOCK", "PROC_FUNC_HEAD",
                   "NEW_SCOPE", "INLINE_ENTRY"] or \
            (goto == None and PRODUCTION_NUMBER in [311, 321]):
        if goto in ["OUTERMOST_BLOCK", "DUPLICATE_BLOCK"] \
                or (goto == None and PRODUCTION_NUMBER == 311):  # reference 3110
            #  <BLOCK STMT HEAD>  ::=  <LABEL EXTERNAL>  PROGRAM
            PRODUCTION_NUMBER = -1
            if goto == None:
                g.TEMP = g.XMDEF;
                g.PARMS_PRESENT = 0;
                g.TEMP2 = g.PROG_MODE;
                SET_LABEL_TYPE(g.FIXL[g.MP], g.PROG_LABEL);
                g.SYT_FLAGS(g.FIXL[g.MP], g.SYT_FLAGS(g.FIXL[g.MP]) | g.LATCHED_FLAG);
                if g.EXTERNAL_MODE > 0:
                    if g.NEST == 0: 
                        g.EXTERNAL_MODE = g.TEMP2;
                    goto = "NEW_SCOPE"
                    continue
            if goto == "OUTERMOST_BLOCK": goto = None
            if g.NEST > 0 and not goto == "DUPLICATE_BLOCK": 
                ERROR(d.CLASS_PP, 1, g.VAR[g.MPP1]);
            else:
                if goto == "DUPLICATE_BLOCK": goto = None
                if g.BLOCK_MODE[0] == 0: 
                    g.MAIN_SCOPE = g.MAX_SCOPEp() + 1;  # WHAT SYT_SCOPE WILL BECOME
                    g.FIRST_STMT(g.STMT_NUM());
                    g.BLOCK_MODE[0] = g.TEMP2;
                    if g.BLOCK_MODE[0] < g.TASK_MODE: 
                        if g.TPL_FLAG < 3: 
                            g.EXTERNALIZE = 3;
                    MONITOR(17, DESCORE(g.VAR[g.MP]));
                    EMIT_EXTERNAL();
                else:
                    ERROR(d.CLASS_PP, 2);
            goto = "NEW_SCOPE"
            continue
        if goto in ["PROC_FUNC_HEAD", "NEW_SCOPE", "INLINE_ENTRY"] or \
                (goto == None and PRODUCTION_NUMBER == 321):  # reference 3210
            #  <PROCEDURE NAME>  ::=  <LABEL EXTERNAL>  PROCEDURE
            PRODUCTION_NUMBER = -1
            if goto == None:
                g.TEMP2 = g.PROC_MODE;
                g.TEMP = g.XPDEF;
                SET_LABEL_TYPE(g.FIXL[g.MP], g.PROC_LABEL);
            if goto in [None, "PROC_FUNC_HEAD"]:
                if goto == "PROC_FUNC_HEAD": goto = None
                g.PARMS_PRESENT = 0;
                if g.INLINE_LEVEL > 0: 
                    ERROR(d.CLASS_PP, 9);
                if g.EXTERNAL_MODE > 0: 
                    if g.NEST == 0: g.EXTERNAL_MODE = g.TEMP2;
                elif g.NEST == 0:
                    g.PARMS_WATCH = g.TRUE;
                    goto = "DUPLICATE_BLOCK"
                    continue
            if goto in [None, "NEW_SCOPE"]:
                #  ALL BLOCKS AND TEMPLATES COME HERE
                if goto == "NEW_SCOPE": goto = None
                SET_BLOCK_SRN(g.FIXL[g.MP]);
                if not g.PAGE_THROWN:
                    if (g.SYT_FLAGS(g.FIXL[g.MP]) & g.EXTERNAL_FLAG) == 0:
                        g.LINE_MAX = 0;
                if g.TEMP2 != g.UPDATE_MODE:
                    HALMAT_BACKUP(g.LAST_POPp);
                if not g.HALMAT_CRAP: 
                    g.HALMAT_OK = (g.EXTERNAL_MODE == 0);
                HALMAT_POP(g.TEMP, 1, 0, 0);
                HALMAT_PIP(g.FIXL[g.MP], g.XSYT, 0, 0);
            if goto == "INLINE_ENTRY": goto = None
            g.XSET(0x16);
            g.NEST = g.NEST + 1;
            g.DO_INX[g.DO_LEVEL] = g.DO_INX[g.DO_LEVEL] | 0x80;
            g.BLOCK_MODE[g.NEST] = g.TEMP2;
            g.BLOCK_SYTREF[g.NEST] = g.FIXL[g.MP];
            g.SYT_ARRAY(g.BLOCK_SYTREF[g.NEST], -g.ON_ERROR_PTR);
            if g.NEST > g.MAXNEST:
                g.MAXNEST = g.NEST;
                if g.NEST >= g.NEST_LIM:
                    ERROR(d.CLASS_BN, 1);
            g.SCOPEp_STACK[g.NEST] = g.SCOPEp;
            g.SCOPEp = g.MAX_SCOPEp() + 1;
            g.MAX_SCOPEp(g.SCOPEp)
            if (g.SYT_FLAGS(g.FIXL[g.MP]) & g.EXTERNAL_FLAG) != 0: 
                sl.NEXT_ELEMENT(h.CSECT_LENGTHS);
                h.CSECT_LENGTHS[g.SCOPEp].PRIMARY = 0x7FFF;  # SET LENGTH TO MAX
                h.CSECT_LENGTHS[g.SCOPEp].REMOTE = 0x7FFF;  # TO TURN OFF PHASE2
                # %COPY CHECKING
            g.SYT_SCOPE(g.FIXL[g.MP], g.SCOPEp);  # UPDATE BLOCK NAME TO SAME SCOPE
            # AS CONTENTS
            g.PROCMARK_STACK[g.NEST] = g.PROCMARK;
            g.PROCMARK = g.NDECSY() + 1;
            g.REGULAR_PROCMARK = g.PROCMARK
            g.SYT_PTR(g.FIXL[g.MP], g.PROCMARK);
            if g.BLOCK_MODE[g.NEST] == g.CMPL_MODE:
                g.PROCMARK = 1;  # ALL COMPOOLS IN SAME SCOPE
            g.S = g.CURRENT_SCOPE[:];
            g.CURRENT_SCOPE = g.VAR[g.MP];
            g.SAVE_SCOPE = g.CURRENT_SCOPE[:]
            g.VAR[g.MP] = g.S;
            g.NEST = g.NEST - 1;
            COMPRESS_OUTER_REF();
            g.NEST = g.NEST + 1;
            g.OUTER_REF_PTR[g.NEST] = g.OUTER_REF_INDEX + 1;
            ENTER_LAYOUT(g.FIXL[g.MP]);
            if g.BLOCK_MODE[g.NEST] == g.INLINE_MODE: 
                if g.STACK_PTR[g.MP] > 0: 
                    OUTPUT_WRITER(0, g.STACK_PTR[g.MP] - 1);
                g.EXT_P[g.PTR[g.MP]] = g.INDENT_LEVEL;
                g.INX[g.PTR[g.MP]] = g.STMT_NUM();
                EMIT_SMRK(5);
                g.INDENT_LEVEL = g.INDENT_LEVEL + g.INDENT_INCR;
                OUTPUT_WRITER(g.STACK_PTR[g.MP], g.STACK_PTR[g.SP]);
                g.INDENT_LEVEL = g.INDENT_LEVEL + g.INDENT_INCR;
                g.NEST_LEVEL = g.NEST_LEVEL + 1;
                EMIT_SMRK();
            else:
                g.INDENT_STACK[g.NEST] = g.INDENT_LEVEL;
                g.NEST_STACK[g.NEST] = g.NEST_LEVEL;
                g.INDENT_LEVEL = 0
                g.NEST_LEVEL = 0;
    
    # END OF PART_2
    if (g.PREV_STMT_NUM != g.STMT_NUM()):
        g.INCREMENT_DOWN_STMT = g.FALSE;
    g.PREV_STMT_NUM = g.STMT_NUM();

