#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   g.py
Purpose:    Part of the HAL/S-FC compiler's HALMAT optimization
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-11-18 RSB  Ported from ##DRIVER XPL.
'''

# The version of the compiler port: (Y, M, D, H, M, S).
version = (2023, 11, 18, 9, 0, 0)

import sys
import HALINCL.COMMON as h
import HALINCL.COMDEC19 as c19

SANITY_CHECK = False
pfs = True
for parm in sys.argv[1:]:
    if  parm == '--bfs':
        pfs = False
    elif parm == "--pfs":
        pfs = True
    elif parm == '--sanity':
        SANITY_CHECK = True
    elif parm == '--help':
        print('This is FLO pass of HAL/S-FC as ported to Python 3.')
        print('It is not generally used in a standalone fashion, but')
        print('is instead automatically run after PASS 1.  But if it')
        print('were to be run separately, do it as follows:')
        print('Usage:')
        print('\tHAL-S-FC_FLO.py [OPTIONS]')
        print('The allowed "modern" OPTIONS are:')
        print('--pfs            Compile for PFS (PASS).')
        print('--bfs            Compile for BFS. (Default is --pfs.)')
        print('--sanity         Perform a sanity check on the Python port.')
        print('--help           Show this explanation.')
    elif parm == "--fix":
        pass  # An option used when included from indentXPL.
    else:
        print("Unrecognized command-line options:", parm)
        print("Use --help for more information.")
        sys.exit(1)

#------------------------------------------------------------------------------
# Here's some stuff intended to functionally replace some of XPL's 'implicitly
# declared' functions and variables while retaining roughly the same syntax.

# Creation data/time of this port of the compiler.  They'll have to be manually 
# maintained.  They correspond to the supposed implicit variables DATE and 
# TIME when the compiler itself was compiled, and of course it never was 
# compiled!  I suppose I could fetch the file timestamp, but then there's more
# than one file comprising the compiler, so which one would I choose?
# Not to mention the fact that once these files have passed through Git,
# all of their timestamps change anyway.


# A "day of the year" function I adapted from here:
# https://www.tutorialspoint.com/day-of-the-year-in-python.
# The input parameter is a tuple (Y, M, D, ...).
def dayOfYear(version):
    d = list(version)
    days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if d[0] % 400 == 0:
        d[2] += 1
    elif d[0] % 4 == 0 and d[0] % 100 != 0:
        days[2] += 1
    for i in range(1, len(days)):
        days[i] += days[i - 1]
    return days[d[1] - 1] + d[2]


# The input parameter is a tuple (x, x, x, H, M, S)
def secondsSinceMidnight(version):
    s = 3600 * version[3] + 60 * version[4] + version[5]
    return s


DATE_OF_GENERATION = 1000 * (version[0] - 1900) + dayOfYear(version)
TIME_OF_GENERATION = 100 * secondsSinceMidnight(version)

# $HH A L / S   S Y S T E M   --    P H A S E   1.3    --   I N T E R M E T R I C S ,   I N C .

# AREA FOR ZAPS

# GLOBAL FLAGS

FORMATTED_DUMP = 0 
DONT_LINK = 0
VMEM_DUMP = 0
INITIALIZING = 0
PROC_TRACE = 0 
WALK_TRACE = 0
HALMAT_DUMP = 0
HMAT_OPT = 0
NAME_TERM_TRACE = 0

# USEFUL LITERALLYS

TRUE = 1
FALSE = 0

#  SYMBOL TABLE DEPENDENT DECLARATIONS


def TOGGLE(value=None):
    global COMM
    index = 6
    if value == None:
        return COMM[index]
    COMM[index] = value


def OPTION_CODE(value=None):
    global COMM
    index = 7
    if value == None:
        return COMM[index]
    COMM[index] = value


def ACTUAL_SYMBOLS(value=None):
    global COMM
    index = 10
    if value == None:
        return COMM[index]
    COMM[index] = value


def STMT_DATA_HEAD(value=None):
    global COMM
    index = 16
    if value == None:
        return COMM[index]
    COMM[index] = value


def TOTAL_HMAT_BYTES(value=None):
    global COMM
    index = 31
    if value == None:
        return COMM[index]
    COMM[index] = value


VAR_CLASS = 1
FUNC_CLASS = 3
ASSIGN_FLAG = 0x00000020
INPUT_FLAG = 0x00000400
ENDSCOPE_FLAG = 0x00004000
EVIL_FLAGS = 0x80200000
NAME_FLAG = 0x10000000
MISC_NAME_FLAG = 0x40000000
MATRIX = 3
VECTOR = 4
STRUCTURE = 10
TEMPL_NAME = 62
IND_CALL_LAB = 0x45
PROC_LABEL = 0x47
EQUATE_LABEL = 0x4B

MAX_SEVERITY = 0
SEVERITY = 0


 # INCLUDE NILL AND XREC_WORD $%COMDEC19
 # REPLACE MACROS USED IN HALMAT SAVING ROUTINES
def INIT_SMRK_LINK():
    return SMRK_LIST


def SMRK_NODE_SZ(arg1, arg2):
    return 4 * (arg2 - arg1 + 3 + INITIAL_CASE)


def VMEM_LIM():
    return (VMEM_PAGE_SIZE // 4) - 3 - INITIAL_CASE


def SAVE_OP(arg1):
    return OPR(arg1) or not (POPCODE(arg1) == EDCL or POPCODE(arg1) == NOP)


def VAC_OPERAND(arg1):
    return OPR(arg1) and (TYPE_BITS(arg1) == VAC)


# GLOBAL VARS FOR HALMAT LIST
START_NODE = 0
END_NODE = 0
STMTp = 0
OLD_STMTp = 0
SMRK_LINK = 0
pCELLS = 0
VAC_START = 0
FINAL_OP = 0
INITIAL_CASE = TRUE
SMRK_LIST = c19.NILL
OLD_SMRK_NODE = c19.NILL

# DECLARATIONS FOR HALMAT DECODING

BLOCKp = 0
CURCBLK = 0 
CODEFILE = 1

#  OPERAND TYPES

SYT = 1
INL = 2
VAC = 3
XPT = 4
LIT = 5
IMD = 6

# HALMAT OPCODES

NOP = 0x000
EXTN = 0x001
XREC = 0x002
IMRK = 0x003
SMRK = 0x004
PXRC = 0x005
LBL = 0x008
BRA = 0x009
FBRA = 0x00A
DCAS = 0x00B
CLBL = 0x00D
DFOR = 0x010
CFOR = 0x012
AFOR = 0x015
CTST = 0x016
ADLP = 0x017
DLPE = 0x018
DSUB = 0x019
IDLP = 0x01A
TSUB = 0x01B
PCAL = 0x01D
FCAL = 0x01E
READ = 0x01F
RDAL = 0x020
WRIT = 0x021
XFIL = 0x022
XXST = 0x025
XXND = 0x026
XXAR = 0x027
EDCL = 0x031
RTRN = 0x032
TDCL = 0x033
WAIT = 0x034
SCHD = 0x039
ERON = 0x03C
MSHP = 0x040
ISHP = 0x043
SFST = 0x045
SFAR = 0x047
LFNC = 0x04B
TASN = 0x04F
IDEF = 0x051
NASN = 0x057
PMAR = 0x05A
PMIN = 0x05B
STRI = 0x801
SLRI = 0x802
ELRI = 0x803
ETRI = 0x804
TINT = 0x8E2
EINT = 0x8E3

OPCODE = 0
CLASS = 0
SUBCODE = 0
NUMOP = 0
CTR = 0

 # CLASS 0 TABLE FOR PROCESS_HALMAT

CLASS0 = (
    0,  # 0 = NOP
    3,  # 1 = EXTN
    14,  # 2 = XREC
    15,  # 3 = IMRK
    15,  # 4 = SMRK
    0,  # 5 = PXRC
    0,
    0,  # 7 = IFHD
    0,  # 8 = LBL
    0,  # 9 = BRA
    0,  # A = FBRA
    0,  # B = DCAS
    12,  # C = ECAS
    0,  # D = CLBL
    0,  # E = DTST
    12,  # F = ETST
    13,  # 10 = DFOR
    12,  # 11 = EFOR
    0,  # 12 = CFOR
    12,  # 13 = DSMP
    12,  # 14 = ESMP
    0,  # 15 = AFOR
    0,  # 16 = CTST
    0,  # 17 = ADLP
    0,  # 18 = DLPE
    4,  # 19 = DSUB
    0,  # 1A = IDLP
    2,  # 1B = TSUB
    0,
    8,  # 1D = PCAL
    8,  # 1E = FCAL
    9,  # 1F = READ
    9,  # 20 = RDAL
    9,  # 21 = WRIT
    0,
    0,
    0,
    7,  # 25 = XXST
    0,  # 26 = XXND
    0,  # 27 = XXAR
    0,
    0,
    1,  # 2A - 2F BLOCK OPENINGS
    1,
    1,
    1,
    1,
    1,
    12,  # 30 = CLOS
    0,  # 31 = EDCL
    0,  # 32 = RTRN
    0,  # 33 = TDCL
    0,  # 34 = WAIT
    0,  # 35 = SGNL
    0,  # 36 = CANC
    0,  # 37 = TERM
    0,  # 38 = PRIO
    0,  # 39 = SCHD
    0,
    0,
    0,
    12,  # 3D = ERSE
    0,
    0,
    6,  # 40 = MSHP
    6,  # 41 = VSHP
    6,  # 42 = SSHP
    6,  # 43 = ISHP
    0,
    5,  # 45 = SFST
    0,  # 46 = SFND
    0,  # 47 = SFAR
    0,
    0,
    0,  # 4A = BFNC
    6,  # 4B = LFNC
    0,
    0,  # 4D = TNEQ
    0,  # 4E = TEQU
    0,  # 4F = TASN
    0,
    1,  # 51 = IDEF
    12,  # 52 = ICLS
    0,
    0,
    0,  # 55 = NNEQ
    0,  # 56 = NEQU
    0,  # 57 = NASN
    0,
    10,  # 59 = PMHD
    0,  # 5A = PMAR
    11,  # 5B = PMIN
    0, 0, 0, 0, 0)
if SANITY_CHECK and len(CLASS0) != 96 + 1:
    print('Bad CLASS0', file=sys.stderr)
    sys.exit(1)

# HALMAT ARRAYS

HALMAT_BLOCK_SIZE = 1800
OPR = [0] * (1 + HALMAT_BLOCK_SIZE)
HALMAT_PTR = [0] * (1 + HALMAT_BLOCK_SIZE)

# DECLARES FOR TEMPLATE PROCESSNG FOR NAME TERMINALS

INIT_LIST_HEAD = 0
TERM_LIST_HEAD = 0
SAVE_ADDR = 0
SINGLE_COPY = 1
LOOP_START_OP = 0x00010000
LOOP_END_OP = 0x00020000
END_OF_LIST_OP = 0x00030000
INIT_WORD_START = 0
STRUCT_REF = 0
STRUCT_TEMPL = 0
STRUCT_COPYp = 0
TEMPL_WIDTH = 0
TEMPL_INX = 0
KIN = 0
STRUCT_COPIES = 0
MAJ_STRUCT = 0
NAME_INITIAL = 7 
IN_IDLP = 0
TEMPL_LIST = [0] * (1 + 20)

# VARIOUS STACKS FOR BUILDING VMEM CELLS

VAR_INX = 0
PTR_INX = 0
WORD_INX = 0
EXP_VARS = [0] * (1 + 400)
EXP_PTRS = [0] * (1 + 400)
WORD_STACK_SIZE = 500
WORD_STACK = [0] * (1 + WORD_STACK_SIZE)

X1 = ' '
X3 = ' ' * 3
X4 = ' ' * 4
X10 = ' ' * 10
X13 = ' ' * 13
X70 = ' ' * 70

# MISCELLANEOUS
CELLSIZE = 0
LEVEL = 0
NEST_LEVEL = 0
DFOR_LOC = 0
DSUB_LOC = 0
EXTN_LOC = 0
TSUB_LOC = 0
LINELENGTH = 131
MAXLINES = 20 
S = [''] * (1 + MAXLINES) 
MSG = [''] * (1 + 5)
ERROR_COUNT = 0 
STMT_DATA_CELL = 0

VPTR_INX = 0 
SYT_VPTRS = 2


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


# Note: Differs from PASS1, where this is VAR_LENGTHS().
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


def SYT_PTR(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return extendSign16(h.SYM_TAB[n].SYM_PTR)
    h.SYM_TAB[n].SYM_PTR = value & 0xFFFF


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


def SYT_LOCKp(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return h.SYM_TAB[n].SYM_LOCKp
    h.SYM_TAB[n].SYM_LOCKp = value


def SYT_TYPE(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return h.SYM_TAB[n].SYM_TYPE
    h.SYM_TAB[n].SYM_TYPE = value


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


def DW(n, value=None):
    while len(h.FOR_DW) <= n:
        h.FOR_DW.append(h.for_dw())
    if value == None:
        return h.FOR_DW[n].CONST_DW
    h.FOR_DW[n].CONST_DW = value


def SYT_NUM(n, value=None):
    while len(h.SYM_ADD) <= n:
        h.SYM_ADD.append(h.sym_add())
    if value == None:
        return h.SYM_ADD[n].SYM_NUM
    h.SYM_ADD[n].SYM_NUM = value


def SYT_VPTR(n, value=None):
    while len(h.SYM_ADD) <= n:
        h.SYM_ADD.append(h.sym_add())
    if value == None:
        return h.SYM_ADD[n].SYM_VPTR
    h.SYM_ADD[n].SYM_VPTR = value


MAX_NAME_INITIALS = 400
''' SINCE THERE IS NO PROVISION FOR THE VARIABLE PART OF AN EXPRESSION
VARIABLE NODE TO EXTEND ACROSS A PAGE, MAX_NAME_INITIALS IS THE MAXIMUM
NUMBER OF INITIALIZED NAMES THAT MAY BE ACCOMODATED FOR A SINGLE DECLARE
STATEMENT. '''
INIT_NAME_HOLDER = 0
NAME_INITIALS = [0] * (1 + MAX_NAME_INITIALS)


def DWN_STMT(n, value=None):
    while len(h.DOWN_INFO) <= n:
        h.DOWN_INFO.append(h.down_info())
    if value == None:
        return h.DOWN_INFO[n].DOWN_STMT
    h.DOWN_INFO[n].DOWN_STMT = value


def DWN_ERR(n, value=None):
    while len(h.DOWN_INFO) <= n:
        h.DOWN_INFO.append(h.down_info())
    if value == None:
        return h.DOWN_INFO[n].DOWN_ERR
    h.DOWN_INFO[n].DOWN_ERR = value


def DWN_CLS(n, value=None):
    while len(h.DOWN_INFO) <= n:
        h.DOWN_INFO.append(h.down_info())
    if value == None:
        return h.DOWN_INFO[n].DOWN_CLS
    h.DOWN_INFO[n].DOWN_CLS = value


def DWN_UNKN(n, value=None):
    while len(h.DOWN_INFO) <= n:
        h.DOWN_INFO.append(h.down_info())
    if value == None:
        return h.DOWN_INFO[n].DOWN_UNKN
    h.DOWN_INFO[n].DOWN_UNKN = value


def DWN_VER(n, value=None):
    while len(h.DOWN_INFO) <= n:
        h.DOWN_INFO.append(h.down_info())
    if value == None:
        return h.DOWN_INFO[n].DOWN_VER
    h.DOWN_INFO[n].DOWN_VER = value

'''
The following 3 variables are a curious case.  In XPL, they are 
DECLARE'd (actually, BASED) not in ##DRIVER but rather in NEWHALMA.
They are not declared in any other XPL or BAL source-code file either,
though they are referenced in a number of other source-code modules.
Nor does NEWHALMA seem like a natural place to declare them: NEWHALMA's 
purpose is to provide the NEW_HALMAT_BLOCK() function, and it doesn't 
even reference these variables at all.  Besides which, their indenting
in NEWHALMA is peculiar, as if they were inserted as an afterthought.
In PASS4 source, on the other hand, they do indeed appear in ##DRIVER.
Curious indeed!  For our purposes, I've moved their declaration here,
to the global variables, and removed them from the Python port of 
NEWHALMA.
'''
vmem_b = []  # BIT(8)
def VMEM_B(n, value = None):
    global vmem_b
    while len(vmem_b) <= n:
        vmem_b.append(0)
    if value == None:
        return vmem_b[n]
    vmem_b[n] = value & 0xFF
    
vmem_h = []  # BIT(16)
def VMEM_H(n, value = None):
    global vmem_h
    while len(vmem_h) <= n:
        vmem_h.append(0)
    if value == None:
        return vmem_h[n]
    vmem_h[n] = value & 0xFFFF
    
vmem_f = []  # FIXED
def VMEM_F(n, value = None):
    global vmem_f
    while len(vmem_f) <= n:
        vmem_f.append(0)
    if value == None:
        return vmem_f[n]
    vmem_f[n] = value & 0xFFFFFFFF
    
