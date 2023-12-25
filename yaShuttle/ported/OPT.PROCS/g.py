#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   g.py
Purpose:    This is part of optimizer of the HAL/S-FC compiler program.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-12-05 RSB  Adapted from OPT.PROCS/##DRIVER.XPL
'''

# The version of the compiler port: (Y, M, D, H, M, S).
version = (2023, 12, 5, 12, 0, 0)

import sys

SANITY_CHECK = False
for parm in sys.argv[1:]:
    if parm == '--sanity':
        SANITY_CHECK = True
    elif parm == '--fix':
        pass
    elif parm == '--help':
        print('This is the OPT of HAL/S-FC as ported to Python 3.')
        print('Usage:')
        print('\tHAL_S_FC_OPT.py [OPTIONS]')
        print('The allowed OPTIONS are:')
        print('--sanity         Perform a sanity check on the Python port.')
        print('--help           Show this explanation.')
        sys.exit(0)
    else:
        print("Unrecognized command-line options:", parm)
        print("Use --help for more information.")
        sys.exit(1)

# $Z MAKES THE CODE GO ON ERRORS
# $HH A L / S   C O M P I L E R   --   O P T I M I Z E R
# UPDATE U8     BEGIN LONG TERM OPTIMIZATION
#    SUBSCRIPT COMMON EXPRESSIONS
# VECTOR MATRIX INLINE

#   LIMITING PHASE 2 SIZES AND LENGTHS
CALL_LEVELp = 20  # MAX FUNC NESTING DEPTH
DOSIZE = 30  # MAX SIMPLE DO LEVEL
MAX_STACK_LEVEL = 32  # YOU GUESSED IT
BLOCK_END = 1799
BLOCK_PLUS_1 = 1800
DOUBLEBLOCK_SIZE = 3599  # 2 HALMAT BLOCKS
LOOP_STACKSIZE = 5  # SIZE OF STACK FOR LOOP COMBINING
TEMPLATE_STACK_SIZE = 2000

'''
The following 3 lines, in Intermetrics XPL, originally read:
    DECLARE SINCOS FIXED   INITIAL( "39 01 04A 8"),
            TWIN#  FIXED   INITIAL(" 2 00 000 0"),   /* # OF TWIN OPS*/
            SINOP  BIT(16) INITIAL("0F0D");          /* = "0F 'SIN'" */
Which is, of course, meaningless in standard XPL, insofar as it's 
possible at this remove to determine what "standard" XPL may have been.
My best interpretation at present (having looked at lots of somewhat-
similar cases appearning below)  is that a sequence of N+1 spaces is
treated as N digits of '0'.  In other words, single spaces are ignored,
and are inserted for readability, but in a multispace sequence, any
additional spaces are leading 0's of the next field.
'''
SINCOS = 0x39014A08
TWINp = 0x02000000  # # OF TWIN OPS
SINOP = 0x0F0D  # = "0F 'SIN'"

CLOCK = [0] * (1 + 2)

CSE_TAB_SIZE = 2500
CATALOG_ENTRY_SIZE = 3
NODE_ENTRY_SIZE = 3
MAX_NODE_SIZE = 2000
SPACE_TAB_SIZE = 5

TRUE = 1
FALSE = 0
OR = '|'
AND = '&'
NOT = '^'

'''
Originally:
    DECLARE
        EVIL_FLAGS FIXED           INITIAL("0020 0000"),
        SM_FLAGS FIXED             INITIAL("14C2 008C")
See comments for SINCOS et al. above.
'''
EVIL_FLAGS = 0x00200000
SM_FLAGS = 0x14C2008C

ACROSS_BLOCK_TAG = 0x4


def PRTYEXP():
    return A_PARITY + (PARITY & (I + 1)) & 0x1


# PRIMARY CODE TABLES AND POINTERS
OP1 = 0
OP2 = 0
SUBCODE = 0
OPCODE = 0
CLASS = 0
NUMOP = 0
TAG1 = 0
TAG = 0
SUBCODE2 = 0
TAG2 = [0] * (1 + 2)
TAG3 = [0] * (1 + 2)
READCTR = 0
SMRK_CTR = 0
CTR = 0
RESET = 0


def SIZE(value=None):
    global ROW
    if value == None:
        return ROW
    ROW = value


DO_LIST = [0] * (1 + DOSIZE)
DO_INX = 0
XREC_PTR = 0

# DECLARATIONS FOR GROW_TREE
BFNC_OK = 0
NONCOMMUTATIVE = 0
TRANSPARENT = 0
LITCHANGE = 0
BIT_TYPE = 0
INDEX2_SIZE = 600
A_PARITY = [0] * (1 + INDEX2_SIZE)
D_N_INX = 0
A_INX = 0
N_INX = 0
EON_PTR = 0
LAST_SMRK = 0
INDEX_SIZE = 360
DIFF_NODE = [0] * (1 + INDEX_SIZE)
DIFF_PTR = [0] * (1 + INDEX_SIZE)
NODE = [0] * (1 + MAX_NODE_SIZE)
NODE2 = [0] * (1 + MAX_NODE_SIZE)

TEMPLATE_STACK = [0] * (1 + TEMPLATE_STACK_SIZE)
# STACK TO REMEMBER TEMPLATES ALREADY ENCOUNTERED IN TSUB'S

# CSE TABLE
CSE_TAB = [0] * (1 + CSE_TAB_SIZE)
ADD = [0] * (1 + INDEX2_SIZE)
FREE_SPACE = [CSE_TAB_SIZE] * (1 + SPACE_TAB_SIZE)
FREE_BLOCK_BEGIN = [1] * (1 + SPACE_TAB_SIZE)
LAST_SPACE_BLOCK = 0
CSE_INX = 0

# WORD FORMATS FOR CSE TABLES AND GROW_TREE

 #        CONTROL TYPE PTR
LITERAL = 0x20E00000  # LAST IN SORT ORDER
TERMINAL_VAC = 0x00300000
OUTER_TERMINAL_VAC = 0x00C00000  # POINTS TO VAC_PTR WORD
VALUE_NO = 0x00B00000
DUMMY_NODE = 0x00D00000
END_OF_NODE = 0xF0000000
VAC_PTR = 0xF0100000
END_OF_LIST = 0xF0F00000

TYPE_MASK = 0x00F00000

CONTROL_MASK = 0xF0000000

# FOR DSUB, CONTROL = SHL(ALPHA,1) | BETA

PARITY_MASK = 0x002F0000

# FOR TSUB, CONTROL = SHL(ALPHA - 7,1) | BETA

#  OPERAND FIELD QUALIFIERS
SYM = 1
VAC = 3
XPT = 4
LIT = 5
IMD = 6
FUNC_CLASS = 3
LABEL_CLASS = 2
PROC_LABEL = 71

# BUILT-IN FUNCTION TABLE

OK = (
    # FORMAT IS |REVERSE_OP|BFNC_OK|
    #                                     7        1
    0,  # 0
    
    1,  # ABS
    27,  # COS      = SHL(SIN,1) | 1
    1,  # DET
    1,  # DIV
    1,  # EXP
    1,  # LOG
    0,  # MAX
    0,  # MIN
    1,  # MOD

    # 10 = ODD

    1,  # ODD
    1,  # SHL
    1,  # SHR
    5,  # SIN      = SHL(COS,1) | 1
    0,  # SUM
    1,  # TAN
    1,  # XOR
    1,  # COSH
    0,  # DATE
    0,  # PRIO

    # 20 = PROD

    0,  # PROD
    1,  # SIGN
    1,  # SINH
    0,  # SIZE
    1,  # SQRT
    1,  # TANH
    0,  # TRIM
    1,  # UNIT
    1,  # ABVAL
    1,  # FLOOR

    # 30 = INDEX

    1,  # INDEX
    0,  # LJUST
    0,  # RJUST
    1,  # ROUND
    1,  # TRACE
    1,  # ARCCOS
    1,  # ARCSIN
    1,  # ARCTAN
    0,  # ERRGRP
    0,  # ERRNUM

    # 40 = LENGTH

    1,  # LENGTH
    1,  # MIDVAL
    0,  # RANDOM
    1,  # SIGNUM
    1,  # ARCCOSH
    1,  # ARCSINH
    1,  # ARCTANH
    1,  # ARCTAN2
    1,  # CEILING
    1,  # INVERSE

    # 50 = NEXTIME

    0,  # NEXTIME
    0,  # RANDOMG
    0,  # RUNTIME
    1,  # TRUNCATE
    0,  # CLOCKTIME
    1,  # REMAINDER
    1,  # TRANSPOSE
    0, 0, 0,
    
    # 60
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

    # 70
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

    # 80
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

    # 90
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    
    # 100
    0

    ) 
if SANITY_CHECK and len(OK) != 100 + 1:
    print('Bad OK (%d)' % len(OK), file=sys.stderr)
    sys.exit(1)

# IF LENGTH IS CHANGED, THEN CHANGE SINCOS AND SINOP VALUES

# CLASS 0 TABLE FOR CHICKEN_OUT AND PRESCAN.

CLASS0 = (

    0x173,  # 0 = NOP
    0x183,  # 1 = EXTN
    0x153,  # 2 = XREC
    1,  # 3 = IMRK
    0x163,  # 4 = SMRK
    0xA3,  # 5 = PXRC
    0,
    3,  # 7 = IFHD
    0x13,  # 8 = LBL
    0x23,  # 9 = BRA
    0xB3,  # A = FBRA
    0xF3,  # B = DCAS
    0x113,  # C = ECAS
    0x103,  # D = CLBL
    0x123,  # E = DTST
    0x133,  # F = ETST
    0x123,  # 10 = DFOR
    0x133,  # 11 = EFOR
    0xC1,  # 12 = CFOR
    0x33,  # 13 = DSMP
    0x43,  # 14 = ESMP
    0x141,  # 15 = AFOR
    0xC1,  # 16 = CTST
    0xE3,  # 17 = ADLP
    3,  # 18 = DLPE
    0xD3,  # 19 = DSUB
    1,  # 1A = IDLP
    0xD3,  # 1B = TSUB
    0, 0, 0, 0,
    # IF PCAL OR FCAL IS CHANGED TO 3, MAKE STATEMENT ARRAYNESS MORE PRECISE

    0,
    1,  # 21 = WRIT
    0, 0, 0,
    0x71,  # 25 = XXST
    1,  # 26 = XXND
    1,  # 27 = XXAR  BEWARE:  TAG FIELD OF OPERANDS NOT ZEROED IN PREPARE HALMAT
    0, 0,
    0x83,  # 2A - 2F BLOCK OPENINGS
    0x83,
    0x83,
    0x83,
    0x83,
    0x83,
    
    0x93,  # 30 = CLOS
    3,  # 31 = EDCL
    0x63,  # 32 = RTRN
    3,  # 33 = TDCL
    0,  # 34 = WAIT
    1,  # 35 = SGNL
    1,  # 36 = CANC
    1,  # 37 = TERM
    1,  # 38 = PRIO
    1,  # 39 = SCHD
    0, 0, 0, 0, 0, 0,

    3,  # 40 = MSHP
    3,  # 41 = VSHP
    3,  # 42 = SSHP
    3,  # 43 = ISHP
    0,
    3,  # 45 = SFST
    3,  # 46 = SFND
    3,  # 47 = SFAR
    0, 0,
    3,  # 4A = BFNC
    1,  # 4B = LFNC
    0,
    1,  # 4D = TNEQ
    1,  # 4E = TEQU    SKIP STRUCTURE COMPARES SINCE TERMAINAL NODE MIGHT HAVE BEEN ASSIGNED
    0x53,  # 4F = TASN

    0,
    0x80,  # 51 = IDEF
    0x93,  # 52 = ICLS
    0,
    
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
if SANITY_CHECK and len(CLASS0) != 96 + 1:
    print('Bad CLASS0 (%d)' % len(CLASS0), file=sys.stderr)
    sys.exit(1)

# DECLARATIONS FOR SUBSCRIPT COMMON EXPRESSIONS
LAST_DSUB_HALMAT = 0
COMPONENT_SIZE = [0] * (1 + 5)
PRESENT_DIMENSION = 0
ARRAY_DIMENSIONS = 0
DIMENSIONS = 0
PREVIOUS_COMPUTATION = 0
VAR = 0
VAR_TYPE = 0
OPERAND_TYPE = 0
DSUB_INX = 0
DSUB_HOLE = 0
DSUB_LOC = 0
TSUB_SUB = 0  # TRUE IF TSUB
TEMPLATE_STACK_END = TEMPLATE_STACK_SIZE
TEMPLATE_STACK_START = TEMPLATE_STACK_SIZE + 1

# CONSTANTS FOR SUBSCRIPT COMMON EXPRESSIONS

SAV_BITS = 0x502
SAV_VAC_BITS = 0x532
SAV_XPT_BITS = 0x542
ALPHA_BETA_QUAL_MASK = 0x772
IMD_0 = 0x61
ALPHA_BETA_MASK = 0xF02


def ALPHA():
    return SHR(OPR[DSUB_INX], 8) & 0x3


def BETA():
    return SHR(OPR[DSUB_INX], 1)

# VAR_TYPE CODES


BIT_VAR = 1
CHAR_VAR = 2
MAT_VAR = 3
VEC_VAR = 4
INT_VAR = 6

# DECLARATIONS FOR VECTOR MATRIX INLINE
LOOP_DIMENSION = 0  # NO OF ITERATIONS IN VM LOOP
LOOP_START = 0  # PTR TO FIRST OPERATOR IN LOOP
LOOP_LAST = 0  # PTR TO LAST OPERATOR IN LOOP
DSUB_REF = 0  # TRUE IF LOOP OPERAND REFERS TO DSUB
LOOPLESS_ASSIGN = 0  # TRUE IF ASSIGN INTO PARTITION
ASSIGN_TOP = 0  # TRUE IF LAST OP ASSIGNMENT
LOOPY_ASSIGN_ONLY = 0  # TRUE IF ASSIGN ONLY POSSIBLE LOOPY
VDLPp = 0  # NUMBER OF VECTOR LOOPS GENERATED
TAG_BIT = 0x40000000

# DECLARATIONS FOR LOOP SMERSHING
AR_DIMS = 0  # # OF DIMENSIONS IN PRESENT ARRAY LOOP
NESTED_VM = 0  # TRUE IF NESTED VM IN ARRAY NOT DISALLOWED
STRUCTURE_COPIES = 0  # TRUE IF STRUCTURE COPIES
IN_VM = 0  # TRUE IF IN VECT/MAT LOOP
IN_AR = 0  # TRUE IF IN ARRAY LOOP
AR_DENESTABLE = 0  # TRUE IF ARRAY POSSIBLY DENESTABLE
PHASE1_ERROR = 0  # TRUE IF ERROR DISCOVERED IN STATEMENT
CROSS_STATEMENTS = 1  # TRUE IF ALLOWED TO CROSS STMT BOUNDARIES

STACKED_VDLPS = 0  # # OF VDLPS ON STACK
V_STACK_INX = 0  # # OF VDLPS ON END OF STACK(POSITIONS 4,5)
ST = 0
ST1 = 0  # LOOP STACK PTRS
DENEST_TAG = 0x400
OUTSIDE_REF_TAG = 0x200
VDLP_TAG = 0x100
VM_LOOP_TAG = 4
OUT_OF_ARRAY_TAG = 2
AR_ALPHA_MASK = 0xFFFF00FF
LAST_ZAP = 0
ASSIGN_OP = 0
C_TRACE = 0
DENESTp = 0
COMBINEp = 0
CONF_ASSIGNS = [0] * (1 + INDEX_SIZE)  # POINTS TO NON-ARRAYED V/M RECEIVERS
CONF_REFERENCES = [0] * (1 + INDEX_SIZE)  # TO NON-ARRAYED VM RHS QUANTITIES
CA_INX = 0
CR_INX = 0  # INDICES TO ABOVE
ARRAYNESS_CONFLICT = 0  # TRUE IF INHIBITED COMBINING DUE TO
                       # ARRAYNESS OVERLAP CONFLICT
# LOOP STACKS
LOOP_HEAD = [0] * (1 + LOOP_STACKSIZE)  # START OF LOOP
LOOP_END = [0] * (1 + LOOP_STACKSIZE)  # END OF LOOP
AR_SIZE = [0] * (1 + LOOP_STACKSIZE)  # # OF ELTS IN LOOP
ADJACENT = [0] * (1 + LOOP_STACKSIZE)  # ADJ(K) TRUE IF LOOP K,K+1 ADJ
REF_TO_DSUB = [0] * (1 + LOOP_STACKSIZE)  # TRUE IF OPRND REFERS TO DSUB
ASSIGN = [0] * (1 + LOOP_STACKSIZE)  # TRUE IF ASSIGN IN LOOP
STRUC_TEMPL = 0
REF_TO_STRUC = 0

# DECLARATIONS FOR GET_NODE
SYT_POINT = 0
GET_INX = 0
NODE_BEGINNING = 0
NODE_SIZE = 0
SEARCH_INX = 0
STTp = 0
ASSIGN_CTR = 0
ARRAYED_TSUB = 0
TWIN_OP = 0
PREVIOUS_TWIN = 0
TWIN_MATCH = 0
LAST_END_OF_LIST = 0  # PTR TO E O L

MAX_NODE = 351
SEARCH = [0] * (1 + MAX_NODE)
SEARCH_REV = [0] * (1 + MAX_NODE)
SEARCH2_REV = [0] * (1 + MAX_NODE)
SEARCH2 = [0] * (1 + MAX_NODE)
CSE = [0] * (1 + MAX_NODE)
CSE2 = [0] * (1 + MAX_NODE)

 # DECLARATIONS FOR CSE_MATCH_FOUND, REARRANGE_HALMAT
CSE_FOUND_INX = 0
PREVIOUS_NODE_PTR = 0
PRESENT_NODE_PTR = 0
OP = 0
REVERSE_OP = 0
LAST_INX = 0
POINT1 = 0
TOPTAG = 0
REVERSE = 0
FORWARD = 0
INVERSE = 0
PARITY = 0
NEW_NODE_PTR = 0
PREVIOUS_NODE_OPERAND = 0
NEW_NODE_OP = 0
MPARITY0p = 0
MPARITY1p = 0
FNPARITY0p = 0
FNPARITY1p = 0
PNPARITY0p = 0
PNPARITY1p = 0

'''
**************************************************************************

PREVIOUS_NODE_OPERAND  POINTS TO FIRST OPERAND OF NODE IN NODE LIST
PREVIOUS_NODE_PTR      POINTS TO "PTR_TO_VAC" NODE WORD OF PREVIOUS MATCH
PREVIOUS_HALMAT        POINTS TO HALMAT OPERATOR OF PREVIOUS MATCH
MPARITY0p              # OF PARITY 0 OPERANDS IN MATCH OF PREVIOUS NODE
MPARITY1p              "  "   "    1     "     "   "
FNPARITY0p             "  "   "    0     "     " FORWARD NODE
FNPARITY1p             "  "   "    1     "     "   "      "
PNPARITY0p             "  "    "   0     "     " PREVIOUS "
PNPARITY1p             "  "    "   1     "     "    "     "
NEW_NODE_PTR           POINTS TO NODE LIST WHERE "PTR_TO_VAC" FOR MATCHED PART
                       OF NODES WILL BE
NODE_BEGINNING         POINTS TO LATTER OPERATOR WORD IN NODE LIST
PREVIOUS_NODE          POINTS TO OPERATOR WORD IN NODE LIST
PRESENT_NODE_PTR       POINTS TO "PTR_TO_VAC" NODE WORD OF PRESENT MATCH
***************************************************************************
'''

# DECLARATIONS FOR REARRANGE_HALMAT
HP = 0
CSE_TAG = 0x8
PREVIOUS_NODE = 0
PREVIOUS_HALMAT = 0
PRESENT_HALMAT = 0
HALMAT_NODE_START = 0
HALMAT_NODE_END = 0
NUMOP_FOR_REARRANGE = 0
HALMAT_PTR = 0
H_INX = 0
MULTIPLE_MATCH = 0
TOTAL_MATCH_PREV = 0
TOTAL_MATCH_PRES = 0

 # STATISTICS
MAXNODE = 0
MAX_CSE_TAB = 0
CSEp = 0
TRANSPOSE_ELIMINATIONS = 0
DIVISION_ELIMINATIONS = 0
SCANS = 0
STATISTICS = 0
COMPARE_CALLS = 0
COMPLEX_MATCHES = 0
LITERAL_FOLDS = 0
COMPLEX_MATCH = 0
EXTN_CSES = 0
TSUB_CSES = 0

# DECLARATIONS FOR RELOCATE_HALMAT
CSE_L_INX = 0


class commonse_list:

    def __init__(self):
        self.LIST_CSE = 0  # BIT(16)


COMMONSE_LIST = []  # Elements are class commonse_list.

#  OPERATION FIELD OR SUBFIELD CODES
XSMRK = 0x0040  # 16-BIT  OPERATORS
XPXRC = 0x0050
XBFNC = 0x04A0
XEXTN = 0x0010
XXREC = 0x0020
XFBRA = 0x00A0
XCNOT = 0x7E40
XCAND = 0x7E20
XCOR = 0x7E30
XCFOR = 0x0120
XCTST = 0x0160
XBNEQ = 0x7250
XILT = 0x7CA0
XDLPE = 0x0180
XSFST = 0x0450
XSFND = 0x0460
XXXST = 0x0250
XXXND = 0x0260
XXXAR = 0x0270
XREAD = 0x01F0
XWRIT = 0x0210
XIDEF = 0x0510
XICLS = 0x0520
XINL = 0x0021
XXPT = 0x0041
XIMD = 0x0061
XAST = 0x0071
XVAC = 0x0031
XSYT = 0x0011
XLIT = 0x0051
XNOP = 0x0000
NOP = 0x000
SADD = 0x5AB
SSUB = 0x5AC
SSPR = 0x5AD
SSDV = 0x5AE
ISUB = 0x6CC
IADD = 0x6CB
IIPR = 0x6CD
ISHP = 0x043
MSHP = 0x040
SFST = 0x045
BFNC = 0x04A
DFOR = 0x010
MSUB = 0x363
MADD = 0x362
VSUB = 0x483
VADD = 0x482
RTRN = 0x032
MTRA = 0x329
MVPR = 0x46C
DSUB = 0x019
MTOM = 0x341
VTOV = 0x441
TSUB = 0x01B
EXTN = 0x001
TASN = 0x04F
XREC = 0x002
ADLP = 0x017
DLPE = 0x018
XXAR = 0x027
SFAR = 0x047
CAND = 0x7E2
SMRK = 0x004
IASN = 0x601
VDOT = 0x58E
BTOI = 0x621
BTOS = 0x521
MNEQ = 0x765
VEQU = 0x786

# FULL OPERATORS

VDLP = 0x10178
VDLE = 0x00188
ADLP_WORD = 0x00170
DLPE_WORD = 0x00180

# CSE TAG SET IF PURE VECTOR DO LOOP START OR END

# CODE OPTIMIZER BITS
XD = 2
XN = 1

# CODE RETRIEVAL DECLARATIONS
CODEFILE = 1
CURCBLK = 0
CODE_OUTFILE = 4
OUTBLK = 0
NOT_XREC = 0
TEST = 0
TOTAL = 0
POST_STATEMENT_ZAP = 0
WATCH = 0
HIGHOPT = 0
OPTIMIZER_OFF = 0
TRACE = 0
SUB_TRACE = 0
HALMAT_REQUESTED = 0
HALMAT_BLAB = 0
MOVE_TRACE = 0
FOLLOW_REARRANGE = 0
FUNC_LEVEL = 0
NESTFUNC = 0

# DECLARATIONS FOR LITERAL FOLDING
LIT_TOP_MAX = 32767
MSG1 = ''
MSG2 = ''
LITORG = 0
LITMAX = 0
CURLBLK = 0
PREVIOUS_CALL = 0

# USEFUL CHARACTER LITERALS
COLON = ':'
COMMA = ','
BLANK = ' '
LEFTBRACKET = '('
HEXCODES = '0123456789ABCDEF'
X72 = ' ' * 72

#  SYMBOL TABLE DEPENDENT DECLARATIONS
SYT_USED = 0  # LAST POSSIBLY VALID SYMBOL


def SYT_WORDS():
    return SHR(SYT_USED, 5)  #****INDEX****OF LAST POSSIBLY VALID WORD


LITSIZ = 130
LITFILE = 2
LITLIM = LITSIZ

# /%INCLUDE COMMON %/

MAX_SEVERITY = 0
SEVERITY = 0

   
def fixup_DOWN_INFO(n):
    while len(h.DOWN_INFO) <= n:
        h.DOWN_INFO.append(h.down_info())


def DWN_STMT(n, value=None):
    if n < 0:
        n = 0
    fixup_DOWN_INFO(n)
    if value == None:
        return h.DOWN_INFO[n].DOWN_STMT[:]
    else:
        h.DOWN_INFO[n].DOWN_STMT = value[:]


def DWN_ERR(n, value=None):
    if n < 0:
        n = 0
    fixup_DOWN_INFO(n)
    if value == None:
        return h.DOWN_INFO[n].DOWN_ERR[:]
    else:
        h.DOWN_INFO[n].DOWN_ERR = value[:]


def DWN_CLS(n, value=None):
    if n < 0:
        n = 0
    fixup_DOWN_INFO(n)
    if value == None:
        return h.DOWN_INFO[n].DOWN_CLS[:]
    else:
        h.DOWN_INFO[n].DOWN_CLS = value[:]


def DWN_UNKN(n, value=None):
    if n < 0:
        n = 0
    fixup_DOWN_INFO(n)
    if value == None:
        return h.DOWN_INFO[n].DOWN_UNKN[:]
    else:
        h.DOWN_INFO[n].DOWN_UNKN = value[:]


def DWN_VER(n, value=None):
    if n < 0:
        n = 0
    fixup_DOWN_INFO(n)
    if value == None:
        return h.DOWN_INFO[n].DOWN_VER[:]
    else:
        h.DOWN_INFO[n].DOWN_VER = value[:]


class sym_shrink:

    def __init__(self):
        self.SYM_REL = 0  # BIT(16)


SYM_SHRINK = []  # Elements are class sym_shink.
   
#*****************************************************************
# THE FOLLOWING VARIABLES MUST BE INDEXED VIA REL
#*****************************************************************


class par_sym:

    def __init__(self):
        self.CAT_ARRAY = 0  # BIT(16)


PAR_SYM = []  # Elements are class par_sym.

   
class structp:

    def __init__(self):
        self.TMPLT = 0  # BIT(16)


STRUCTp = []  # Elements are class structp.

   
class val_table:

    def __init__(self):
        self.VAL_ARRAY = 0  # FIXED


VAL_TABLE = []  # Elements are class val_table.

   
class obps:

    def __init__(self):
        self.TSAPS = 0  # FIXED


OBPS = []  # Elements are class obps.

   
class zapit:

    def __init__(self):
        self.TYPE_ZAP = 0  # FIXED


ZAPIT = []  # Elements are class zapit.
   
pZAP_BY_TYPE_ARRAYS = 6  # THERE ARE 6 OF THEM, NOT 7


def WIPEOUTp(value=None):
    global VALIDITY
    if value == None:
        return VALIDITY
    VALIDITY = value


# VARIABLES FOR STACKING
ZAP_LEVEL = 0  # ZAP_STACK_LEVEL
LOOP_ZAPS_LEVEL = 0
LEVEL = 0  # STACK LEVEL
BLOCKp = 0  # # ASSOCIATED WITH A BLOCK
OLD_LEVEL = 0  # LEVEL FOR CSE
OLD_BLOCKp = 0  # BLOCK# FOR CSE
POST_STATEMENT_PUSH = 0  # TO PUSH STACKS AT END OF STMT
INLp = 0  # PRESENT INL#
STACK_TRACE = 0
NODE_DUMP = 1
CSE_TAB_DUMP2 = 0  # LISTS CATALOG & NODE ENTRIES IN CSE_TAB
VAL_SIZE = 0  # WIDTH OF ZAP ARRAY FOR ONE LEVEL
BLOCK_TOP = 0  # RUNNING BLOCK #'S IN A BLOCK


class level_stack_vars:

    def __init__(self):
        self.XZAP_BASE = 0  # BASE FOR ASSOCIATED ZAPS
        self.XPULL_LOOP_HEAD = 0
        # START OF INNERMOST LOOP CONTAINING THIS LEVEL
        self.XSTACK_INLp = 0  # INL# FOR EACH BLOCK
        self.XSTACKED_BLOCKp = 0  # BLOCK# FOR EACH LEVEL
        self.XSTACK_TAGS = 0  # TAGS FOR EACH BLOCK


LEVEL_STACK_VARS = []  # Elements are level_stack_vars.

 # VARIABLES FOR LOOP INVARIANT COMPUTATIONS

AR_LIST = [0] * (1 + 33)
AR_INX = 0  # INDEX FOR AR_LIST
DA_MASK = 0x60000000  # DUMMY,ARRAY MASK FOR NODE LIST
AR_TAG = 0x20000000  # NODE LIST TAG FOR ARRAYED NODES
INVARIANT_COMPUTATION = 0
# TRUE IF NODE HAS INVARIANT COMPUTATION
INVARIANT_PULLED = 0  # TRUE IF ACTUALLY PULLED FROM LOOP
INVARp = 0  # # OF INVAR COMPS PULLED
AR_PTR = 0  # POINTS TO ADLP
LOOPY_OPS = 0  # TRUE IF INVAR COMP IS LOOPY
ARRAYED_OPS = 0  # TRUE IF INVAR COMP HAS ARRAYED OPS
STATEMENT_ARRAYNESS = 0  # TRUE IF ARRAYED STMT
EXTNS_PRESENT = 0  # TRUE IF EXTN'S IN STATEMENT
ARRAYED_CONDITIONAL = 0  # IF CONDITIONAL IS ARRAYED
PUSHp = 0  # # OF CALLS TO PUSH_HALMAT
PUSH_SIZE = 0  # # OF WORDS PUSHED


def I_TRACE(value=None):
    global STACK_TRACE
    if value == None:
        return STACK_TRACE
    STACK_TRACE = value


CROSS_BLOCK_OPERATORS = [0] * (1 + 1)  # MAX # OF OPERATORS PASSED ACROSS A BLOCK
ROOM = 0  # SPACE FOR HALMAT PUSHING IN A STATEMENT
LEV = 0  # LEVEL FOR PULLING INVAR COMPS
FBRA_FLAG = FALSE

WORK3 = 0


def LIT_TOP(value=None):
    n = 2
    if value == None:
        return h.COMM(n)
    h.COMM[n] = value

    
def TOGGLE(value=None):
    n = 6
    if value == None:
        return h.COMM(n)
    h.COMM[n] = value

    
def OPTION_BITS(value=None):
    n = 7
    if value == None:
        return h.COMM(n)
    h.COMM[n] = value

    
SYT_SIZE = 0

XNEST_MASK = 0xFF000000
PM_FLAGS = 0x00C20080
MAJ_STRUCT = 10
STUB_FLAG = 0x00002000
REGISTER_TAG = 0x2000000
ELEGANT_BUGOUT = 0
NAME_OR_PARM_FLAG = 0x10000020

OPTYPE = 0
TEMP = 0
TMP = 0

MOVEABLE = 1


def enlargeSYM_TAB(n):
    try:
        while len(h.SYM_TAB) <= n:
            h.SYM_TAB.append(h.sym_tab())
    except:
        pass


def SYT_NAME(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return h.SYM_TAB[n].SYM_NAME[:]
    h.SYM_TAB[n].SYM_NAME = value[:]


def SYT_XREF(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return extendSign16(h.SYM_TAB[n].SYM_XREF)
    h.SYM_TAB[n].SYM_XREF = value & 0xFFFF


def SYT_DIMS(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return h.SYM_TAB[n].SYM_LENGTH
    h.SYM_TAB[n].SYM_LENGTH = value


def SYT_ARRAY(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return extendSign16(h.SYM_TAB[n].SYM_ARRAY)
    h.SYM_TAB[n].SYM_ARRAY = value & 0xFFFF


def SYT_LINK1(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return extendSign16(h.SYM_TAB[n].SYM_LINK1)
    h.SYM_TAB[n].SYM_LINK1 = value & 0xFFFF


def SYT_LINK2(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return extendSign16(h.SYM_TAB[n].SYM_LINK2)
    h.SYM_TAB[n].SYM_LINK2 = value & 0xFFFF


def SYT_CLASS(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return h.SYM_TAB[n].SYM_CLASS
    h.SYM_TAB[n].SYM_CLASS = value


def SYT_FLAGS(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return h.SYM_TAB[n].SYM_FLAGS
    h.SYM_TAB[n].SYM_FLAGS = value


def SYT_TYPE(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return h.SYM_TAB[n].SYM_TYPE
    h.SYM_TAB[n].SYM_TYPE = value


def REL(n, value=None):
    global SYM_SHRINK
    while len(SYM_SHRINK) <= n:
        SYM_SHRINK.append(sym_shrink)
    if value == None:
        return SYM_SHRINK[n].SYM_REL
    SYM_SHRINK[n].SYM_REL = value

      
def TEMPLp(n, value=None):
    global STRUCTp
    while len(STRUCTp) <= n:
        STRUCTp.append(structp)
    if value == None:
        return STRUCTp[n].TMPLT
    STRUCTp[n].TMPLT = value

'''
This is nasty.  Originally:

   BASED VAL_TABLE RECORD DYNAMIC:
         VAL_ARRAY              FIXED,
      END;
   ...
   DECLARE VALIDITY_ARRAY(1) LITERALLY 'VAL_TABLE(LEVEL).VAL_ARRAY(%1%)'

Logically, what this is achieving is instead

   DECLARE VALIDITY_ARRAY(1) LITERALLY 'VAL_TABLE(LEVEL+%1%).VAL_ARRAY'

I presume it was written in the obtuse manner of the original is to 
avoid the addition LEVEL+%1%, which they instead got for free by relying
on the (undocumented) treatment of the scalar VAL_ARRAY as an array.
I suppose it must have seemed like a clever hack at the time, but 
yuck!
'''


def VALIDITY_ARRAY(n, value=None):
    global VAL_TABLE
    n += LEVEL
    while len(VAL_TABLE) <= n:
        VAL_TABLE.append(val_table)
    if value == None:
        return VAL_TABLE[n].VAL_ARRAY
    VAL_TABLE[n].VAL_ARRAY = value


# See the comments for VALIDITY_ARRAY above.
def CATALOG_ARRAY(n, value=None):
    global PAR_SYM
    n += LEVEL
    while len(PAR_SYM) <= n:
        PAR_SYM.append(par_sym)
    if value == None:
        return PAR_SYM[n].CAT_ARRAY
    PAR_SYM[n].CAT_ARRAY = value

      
def ZAP_BASE(n, value=None):
    global LEVEL_STACK_VARS
    while len(LEVEL_STACK_VARS) <= n:
        LEVEL_STACK_VARS.append(structp)
    if value == None:
        return LEVEL_STACK_VARS[n].XZAP_BASE
    LEVEL_STACK_VARS[n].XZAP_BASE = value


def PULL_LOOP_HEAD(n, value=None):
    global LEVEL_STACK_VARS
    while len(LEVEL_STACK_VARS) <= n:
        LEVEL_STACK_VARS.append(structp)
    if value == None:
        return LEVEL_STACK_VARS[n].XPULL_LOOP_HEAD
    LEVEL_STACK_VARS[n].XPULL_LOOP_HEAD = value


def STACK_INLp(n, value=None):
    global LEVEL_STACK_VARS
    while len(LEVEL_STACK_VARS) <= n:
        LEVEL_STACK_VARS.append(structp)
    if value == None:
        return LEVEL_STACK_VARS[n].XSTACK_INLp
    LEVEL_STACK_VARS[n].XSTACK_INLp = value


def STACKED_BLOCKp(n, value=None):
    global LEVEL_STACK_VARS
    while len(LEVEL_STACK_VARS) <= n:
        LEVEL_STACK_VARS.append(structp)
    if value == None:
        return LEVEL_STACK_VARS[n].XSTACKED_BLOCKp
    LEVEL_STACK_VARS[n].XSTACKED_BLOCKp = value


def STACK_TAGS(n, value=None):
    global LEVEL_STACK_VARS
    while len(LEVEL_STACK_VARS) <= n:
        LEVEL_STACK_VARS.append(structp)
    if value == None:
        return LEVEL_STACK_VARS[n].XSTACK_TAGS
    LEVEL_STACK_VARS[n].XSTACK_TAGS = value


# See the comments for VALIDITY_ARRAY above.
def LOOP_ZAPS(n, value=None):
    global OBPS
    n += LOOPS_ZAPS_LEVEL
    while len(OBPS) <= n:
        OBPS.append(obps)
    if value == None:
        return OBPS(n).TSAPS
    OBPS(n).TSAPS = value

      
# See the comments for VALIDITY_ARRAY above.
def ZAPS(n, value=None):
    global OBPS
    n += ZAPLOOP_ZAPS_LEVEL
    while len(OBPS) <= n:
        OBPS.append(obps)
    if value == None:
        return OBPS[n].TSAPS
    OBPS[n].TSAPS = value

      
def XREF(n, value=None):
    while len(h.CROSS_REF) <= n:
        h.CROSS_REF.append(h.cross_ref())
    if value == None:
        return h.CROSS_REF[n].CR_REF
    h.CROSS_REF[n].CR_REF = value


# In principle, DW[] has 14 32-bit entries, and thus would occupy 56 bytes.
DW = [0] * 14


def LIT1(n, value=None):
    if value == None:
        return h.LIT_PG[0].LITERAL1[n]
    h.LIT_PG[0].LITERAL1[n] = value


def LIT2(n, value=None):
    if value == None:
        return h.LIT_PG[0].LITERAL2[n]
    h.LIT_PG[0].LITERAL2[n] = value


def LIT3(n, value=None):
    if value == None:
        return h.LIT_PG[0].LITERAL3[n]
    h.LIT_PG[0].LITERAL3[n] = value


def CSE_LIST(n, value=None):
    while len(COMMONSE_LIST) <= n:
        COMMONSE_LIST.append(commonse_list())
    if value == None:
        return COMMONSE_LIST[n].LIST_CSE
    COMMONSE_LIST[n].LIST_CSE = value

# INCLUDE VMEM DECLARES:  $%VMEM1
# AND:  $%VMEM2

# TAGS FOR OPERATOR WORD IN NODE LIST


MATCHED_TAG = 0x80000000

NEGMAX = 0x80000000 
POSMAX = 0x7FFFFFFF

# MISCELLANEOUS DECLARATIONS
OPTIMISING = 1
PUSH_TEST = 0
DEBUG = 0
MESSAGE = ''
STILL_NODES = 0
SEARCHABLE = 0

# ARRAY PARALLEL TO HALMAT
FLAG = [0] * (1 + DOUBLEBLOCK_SIZE)
OPR = [0] * (1 + DOUBLEBLOCK_SIZE)  # HALMAT

