#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   g.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
               Basically, this provides most of the global variables 
               for PASS2 of the compiler.
   Language:   XPL.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-15 RSB  Began adapting PASS2.PROCS/##DRIVER.xpl.
"""

# The version of the compiler port: (Y, M, D, H, M, S).
version = (2023, 11, 17, 13, 0, 0)

import sys
import HALINCL.COMMON as h

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
        print('This is PASS 2 of HAL/S-FC as ported to Python 3.')
        print('It is not generally used in a standalone fashion, but')
        print('is instead automatically run after PASS 1.  But if it')
        print('were to be run separately, do it as follows:')
        print('Usage:')
        print('\tHAL-S-FC_PASS2.py [OPTIONS]')
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
#----------------------------------------------------------------------

# LIMITING PHASE 2 SIZES AND LENGTHS   
LABELSIZE = 0
STACK_SIZE = 100  # NUMBER OF INDIRECT STACK ENTRIES
PROCp = 255  # NUMBER OF PROCS/FUNCS/TASKS/ETC. 
CALL_LEVELp = 20  # MAX FUNC NESTING DEPTH          
ARG_STACKp = 100  # MAX ARGUMENT NESTING DEPTH      
HASHSIZE = 49  # SIZE FOR HASHING EXTERNAL NAMES 
BIGNUMBER = 200000  # MAX BYTES OF COMMON STORAGE     
LASTEMP = 100  # MAX # OF ACTIVE TEMPORARIES     
STATNOLIMIT = 0  # MAX # OF STATEMENT NUMBERS      

TRUE = 1
FALSE = 0
# FOR = ''

BY_NAME_TRUE = 1
BY_NAME_FALSE = 0
FOR_NAME_TRUE = 1
FOR_NAME_FALSE = 0

# PRIMARY CODE TABLES AND POINTERS 
OP1 = 0
OP2 = 0
SUBCODE = 0
OPCODE = 0
CLASS = 0
NUMOP = 0
TAG1 = 0
TAG = 0
TAG2 = [0] * 3
TAG3 = [0] * 3
LEFTOP = 0
RIGHTOP = 0
RESULT = 0
LASTRESULT = 0
TAGS = 0
READCTR = 0
SMRK_CTR = 0
CTR = 0
RESET = 0
STACK_MAX = 0
STACK_PTR = [0] * (STACK_SIZE + 1)
COPT = [0] * (STACK_SIZE + 1)
STRUCT_START = 0
STRUCT_LINK = 0
#   OPERAND TYPES AFTER INITIALISE TIME ...  FLAG OF
#                 0x8 INDICATES DOUBLE PRECISION                   
VECMAT = 0
INTSCA = 3
BITS = 1
CHAR = 2
MATRIX = 3
VECTOR = 4
SCALAR = 5
DSCALAR = 13
INTEGER = 6
DINTEGER = 14
APOINTER = 7
RPOINTER = 19
FULLBIT = 9
BOOLEAN = 1
EXTRABIT = 15
CHARSUBBIT = 18
STRUCTURE = 16
EVENT = 17
LOGICAL = 20
RELATIONAL = 21
if not pfs:  # BFS/PASS INTERFACE; SET UP INITIAL ENTRY TYPE 
    INITIAL_ENTRY = 22
FULLWORD = 'DINTEGER'
# HALFWORD = 'BITS' 
# ONEBYTE = 'CHAR' 
WORDSIZE = 32
HALFWORDSIZE = 16
BITESIZE = 16
NAMETYPE = 6
NAMESTORE = 0x40

# OPERAND FIELD QUALIFIERS   
SYM = 1
INL = 2
VAC = 3
XPT = 4
LIT = 5
IMD = 6
AIDX = 28
CSIZ = 8
ASIZ = 9
OFFSET = 10
WORK = 31
AIDX2 = 30
SYM2 = 29
CLBL = 15
# FIXLIT = 10
CHARLIT = 8
CSYM = 7
ADCON = 16
LOCREL = 17
LBL = 18
FLNO = 19
STNO = 20
# SYSINT = 21
EXTSYM = 22
SHCOUNT = 23

# OPERATION FIELD OR SUBFIELD CODES  
XMVPR = 0x0C  #  5-BIT OPCODES 
XMTRA = 0x09
XMINV = 0x0A
XMDET = 0x11
XMEXP = 0x19
XMASN = 0x15
XPASN = 0x18
XSASN = 0x14
XVMIO = 0x16
XMIDN = 0x13
XCSIO = 0x07
XCSLD = 0x09
XCSST = 0x0A
XNOT = 0x04
XOR = 0x03
XXASN = 0x01
XADD = 0x0B
XDIV = 0x0E
XEXP = 0x0F
XPEX = 0x12
XEQU = 0x06
XTASN = 0x4F
XSMRK = 0x0040  # 16-BIT  OPERATORS 
XEXTN = 0x0010
XXREC = 0x0020
# XFBRA = 0x00A0
XBTRU = 0x7200
# XCFOR = 0x0120
# XCTST = 0x0160
# XBNEQ = 0x7250
# XILT = 0x7CA0
XDLPE = 0x0180
# XSFST = 0x0450
# XSFND = 0x0460
XSFAR = 0x0470
# XXXST = 0x0250
# XXXND = 0x0260
XXXAR = 0x0270
XREAD = 0x01F0
# XRDAL = 0x0200
XWRIT = 0x0210
XFILE = 0x0220
XIDEF = 0x0510
# XICLS = 0x0520
XIMRK = 0x0030
XADLP = 0x0170
XVDLP = 0x0178
XVDLE = 0x0188

# CODE OPTIMIZER BITS  
# XD= 2
# XN= 1

# DECLARATIONS USED BY THE CODE GENERATORS  

RRTYPE = 32
RXTYPE = 33
SSTYPE = 34
DELTA = 35
ULBL = 36
# ILBL = 37
PLBL = 48
CSECT = 38
DATABLK = 39
DADDR = 40
PADDR = 41
RLD = 43
STMTNO = 44
PDELTA = 45
CSTRING = 46
CODE_END = 47
DATA_LIST = 49
SRSTYPE = 50
CNOP = 51
NOP = 52
HADDR = 53
PROLOG = 54
ZADDR = 55
SMADDR = 56
STADDR = 57
BR_ARND = 58
if not pfs:  #  BFS/PASS INTERFACE; ADD NEW INTERMEDIATE OPCODES 
    SPSET = 63
    LPUSH = 64
    LPOP = 65
# LADDR = 42

NRTEMP = 'WORK'  # FORM USED FOR RNR ON STACK

A = 0x5A
# AD = 0x6A
# ADR = 0x2A
# AE = 0x7A
# AER = 0x3A
AH = 0x4A
AHI = 0xAA
AR = 0x1A
# AST = 0xCA
BAL = 0x45
BALR = 0x05
BC = 0x47
BCF = 0x87
BCR = 0x07
BCRE = 0x0F
BCT = 0x46
BCTB = 0x86
# BCTR = 0x06
BIX = 0x44
if not pfs:  # BFS/PASS INTERFACE 
    BVC = 0x42
# C = 0x59
# CD = 0x69
# CDR = 0x29
# CE = 0x79
# CER = 0x39
CH = 0x49
CHI = 0xA9
# CIST = 0xB9
# CR = 0x19
CVFL = 0x3F
CVFX = 0x1F
# D = 0x5D
# DD = 0x6D
# DDR = 0x2D
# DE = 0x7D
# DER = 0x3D
# DR = 0x1D
IAL = 0x4F
IHL = 0x43
L = 0x58
LA = 0x41
LCR = 0x13
# LD = 0x68
# LE = 0x78
# LECR = 0x33
LER = 0x38
LFLI = 0x03
LFXI = 0x02
LH = 0x48
LHI = 0xA8
LM = 0x98
LR = 0x18
# M = 0x5C
# MD = 0x6C
# MDR = 0x2C
# ME = 0x7C
# MER = 0x3C
MH = 0x4C
MHI = 0xAC
MIH = 0x4E
MR = 0x1C
MSTH = 0xBA
MVH = 0x0E
# MVS = 0x7E
# N = 0x54
NHI = 0xA4
NIST = 0xB4
NR = 0x14  # USED IN NAME COMPARE 
# NST = 0xC4
# O = 0x56
OHI = 0xA6  # #DNAME - THIS NOW USED FOR 
# OR = 0x16
# OST = 0xC6
# S = 0x5B
SB = 0xB6
SCAL = 0x4D
# SD = 0x6B
SDR = 0x2B
# SE = 0x7B
SER = 0x3B
# SH = 0x4B
SHW = 0x96
SLDL = 0x8D
SLL = 0x89
SPM = 0x04
# SR = 0x1B
SRA = 0x8A
SRDA = 0x8E
# SRDL = 0x8C
SRET = 0x0D
SRL = 0x88
#-------------------------------------------------------
# NEW INSTRUCTION USED IN YCON_TO_ZCON: SRR.            
SRR = 0xCD
# ADDED 1 TO OPMAX CONSTANT FOR THE NEW SRR INSTRUCTION 
# ADDED AN ENTRY ON THE END OF EACH OF THESE ARRAYS:    
#    OPERATOR   :  0                                    
#    OPCC       :  0                                    
#    OPER       :  28                                   
#    OPNAMES    :  SRR                                  
#    AP101INST  :  0xF003                               
#-------------------------------------------------------
# SST = 0xCB
ST = 0x50
STD = 0x60
STE = 0x70
STH = 0x40
STM = 0x90
SVC = 0x9A
TB = 0xB1
TD = 0x9B
TH = 0x91
TRB = 0xA1
TS = 0x93
# TSB = 0xB3
# X = 0x57
# XDR = 0x27
# XER = 0x37
# XHI = 0xA7
# XIST = 0xB7
XR = 0x17
# XST = 0xC7
# ZB = 0xBE
ZH = 0x9E
#---------------------- #DDSE -----------------------
# NEW DSE MANIPULATING INSTRUCTION LDM.              
LDM = 0xCC
# ADDED 1 TO OPMAX CONSTANT FOR THE NEW LDM INSTRUCTION.     
# ADDED AN ENTRY ON THE END OF EACH OF THESE ARRAYS:         
#    OPERATOR   :  0      
#    OPCC       :  0      
#    OPER       :  24     
#    OPNAMES    :  LDM    
#    AP101INST  :  0x68F8 
#----------------------------------------------------
ZRB = 0xAE  # #DMVH: THIS NOW USED 
'''
The following is quite a puzzle.  In XPL it read as follows:
    ARRAY OPMAX LITERALLY '205', 
      OPERATOR(OPMAX) BIT(1) INITIAL( 0, 0, 0, 0, 0, ... ;
Which makes no sense whatever, since it says that OPMAX is a macro 
that's replaced by 205 at compile-time, yet also indicates that it's an
array without (for some reason) any defined size.  I can only suppose
that the way it *should* have read was
    DECLARE OPMAX LITERALLY '205';
    ARRAY OPERATOR(OPMAX) BIT(1) INITIAL( 0, 0, 0, 0, 0, ... ;
but that the "enhanced" XPL compiler was flexible enough to accept the
garbled garbage.  It wouldn't actually be too surprising, since my 
experience in porting PASS1 basically led me to believe that ARRAY was
synonymous with DECLARE anyway, since the compiler treated arrays as
single values and vice-versa, simply depending on whether they had an
attached index or not.
'''
OPMAX = 205
OPERATOR = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0,
    1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1,
    0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0]
if SANITY_CHECK and len(OPERATOR) != OPMAX + 1:
    print('Bad SANITY_CHECK', file=sys.stderr)
    sys.exit(1)

OPCC = [ 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 2, 2,
0, 0, 0, 0, 1, 3, 0, 3, 3, 1, 2, 1, 1, 2, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0,
1, 0, 2, 1, 1, 2, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 2, 1, 1, 2, 2, 0,
1, 0, 2, 0, 2, 2, 2, 2, 0, 1, 2, 1, 1, 2, 2, 2, 2, 0, 0, 0, 0, 3, 0, 3,
3, 1, 2, 1, 1, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 1, 1, 2, 2, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 1, 1, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 2,
0, 2, 2, 2, 0, 2, 2, 2, 0, 0, 1, 0, 1, 0, 0, 0, 0, 2, 0, 2, 2, 0, 0, 0,
0, 0, 3, 0, 0, 3, 0, 3, 3, 2, 2, 1, 0, 2, 0, 3, 0, 0, 1, 0, 1, 1, 0, 1,
1, 0, 2, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 2, 2, 0, 0, 2, 2, 0, 0]
if SANITY_CHECK and len(OPCC) != OPMAX + 1:
    print('Bad OPCC', file=sys.stderr)
    sys.exit(1)

if pfs:  # BFS/PASS INTERFACE 
    OPER = [ 0, 0, 80, 76, 120, 16, 28, 20, 0, 0, 0, 0, 0,
    128, 100, 24, 0, 0, 0, 64, 104, 0, 108, 140, 84, 40, 12, 124, 96, 60, 0,
    48, 0, 0, 0, 0, 0, 0, 0, 132, 0, 32, 4, 112, 88, 52, 0, 0, 0, 0, 0, 68,
    0, 0, 0, 136, 72, 36, 8, 116, 92, 56, 0, 44, 156, 76, 0, 68, 32, 20, 28,
    24, 88, 48, 16, 140, 104, 128, 108, 64, 144, 0, 0, 0, 116, 0, 120, 160,
    72, 36, 4, 124, 92, 52, 0, 0, 148, 0, 0, 0, 0, 0, 0, 0, 80, 40, 8, 132,
    96, 56, 0, 0, 152, 0, 0, 0, 0, 0, 0, 0, 84, 44, 12, 136, 100, 60, 112,
    0, 0, 0, 0, 0, 0, 0, 12, 8, 80, 64, 68, 0, 76, 60, 72, 0, 84, 100, 0,
    108, 0, 0, 56, 0, 28, 0, 88, 96, 0, 0, 128, 0, 0, 104, 0, 0, 40, 0, 48,
    116, 24, 16, 4, 0, 32, 0, 132, 0, 0, 92, 0, 112, 44, 0, 52, 120, 0, 20,
    36, 0, 0, 0, 124, 0, 0, 0, 0, 0, 8, 0, 12, 20, 0, 0, 4, 16, 24, 28]
else:  # bfs
    OPER = [ 0, 0, 80, 76, 120, 16, 28, 20, 0, 0, 0, 0, 0,
    128, 100, 24, 0, 0, 0, 64, 104, 0, 108, 140, 84, 40, 12, 124, 96, 60, 0,
    48, 0, 0, 0, 0, 0, 0, 0, 132, 0, 32, 4, 112, 88, 52, 0, 0, 0, 0, 0, 68,
    0, 0, 0, 136, 72, 36, 8, 116, 92, 56, 0, 44, 160, 80, 36, 72, 32  , 20,
    28, 24, 92, 52, 16, 144, 108, 132, 112, 68, 148, 0, 0, 0, 120, 0  , 124,
    164, 76, 40, 4, 128, 96, 56, 0, 0, 152, 0, 0, 0, 0, 0, 0, 0, 84, 44, 8,
    136, 100, 60, 0, 0, 156, 0, 0, 0, 0, 0, 0, 0, 88, 48, 12, 140, 104, 64,
    116, 0, 0, 0, 16, 0, 0, 0, 12, 8, 84, 68, 72, 0, 80, 64, 76, 0, 88, 104,
    0, 112, 0, 0, 60, 0, 32, 0, 92, 100, 0, 0, 132, 0, 0, 108, 0, 0, 44, 0,
    52, 120, 28, 20, 4, 0, 36, 0, 136, 0, 0, 96, 0, 116, 48, 0, 56, 124, 0,
    24, 40, 0, 0, 0, 128, 0, 0, 0, 0, 0, 8, 0, 12, 20, 0, 0, 4, 16, 24, 28]
if SANITY_CHECK and len(OPER) != OPMAX + 1:
    print('Bad OPER', file=sys.stderr)
    sys.exit(1)

BCB_COUNT = 0
OPCOUNT = [0] * (OPMAX + 1)
if pfs:  # BFS/PASS INTERFACE; BVC DIFFERENCE IN BFS
    OPNAMES = (
        '*   AEDRAER AR  BALRBCR BCREBCTRCEDRCER CR  CVFLCVFXDEDRDER DR  LACRLECRLER LFL'
       'ILFXILR  MEDRMER MR  MVH NR  OR  SEDRSER SPM SR  SRETSEDRSER XR  ',
        '*   A   AED AE  AH  BAL BC  BCT BIX C   CED CE  CH  D   DED DE  IAL IHL L   LA '
       ' LED LE  LH  M   MED ME  MH  MIH MVS N   O   S   SCALSED SE  SH  ST  STEDSTE STH'
       ' X   ',
        '*   AHI BCF BCTBCHI CISTLHI LM  MHI MSTHNHI NISTOHI SB  SHW SLDLSLL SRA SRDASRD'
       'LSRL STM SVC TB  TD  TH  TRB TS  TSB XHI XISTZB  ZH  ZRB ',
        '*   AST NST OST SST XST LDM SRR ')
else:
   OPNAMES = (
        '*   AEDRAER AR  BALRBCR BCREBCTRCEDRCER CR  CVFLCVFXDEDRDER DR  LACRLECRLER LFL'
       'ILFXILR  MEDRMER MR  MVH NR  OR  SEDRSER SPM SR  SRETSEDRSER XR  ',
        '*   A   AED AE  AH  BAL BC  BCT BIX BVC C   CED CE  CH  D   DED DE  IAL IHL L  '
       ' LA  LED LE  LH  M   MED ME  MH  MIH MVS N   O   S   SCALSED SE  SH  ST  STEDSTE'
       ' STH X   ',
        '*   AHI BCF BCTBBVCFCHI CISTLHI LM  MHI MSTHNHI NISTOHI SB  SHW SLDLSLL SRA SRD'
       'ASRDLSRL STM SVC TB  TD  TH  TRB TS  TSB XHI XISTZB  ZH  ZRB ',
        '*   AST NST OST SST XST LDM SRR ')
if SANITY_CHECK and len(OPNAMES) != 3 + 1:
    print('Bad OPNAMES', file=sys.stderr)
    sys.exit(1)

if pfs:  # BFS/PASS INTERFACE 
    AP101INST = [      0, 0, 0xB8E0, 0x88E0,
        0xC8E8, 0xE0E0, 0xD0E0, 0xC0E0, 0, 0, 0, 0, 0,
        0x90E8, 0x68E8, 0xC0E8, 0, 0, 0, 0xE8E8, 0x20E0, 0,
        0x28E0, 0x70E0, 0x18E0, 0x10E0, 0x00E0, 0x08E0, 0x40E0, 0x48E0, 0,
        0x38E0, 0, 0, 0, 0, 0, 0, 0, 0x58E8,
        0, 0x48E8, 0x50E8, 0x58E8, 0x30E8, 0x10E8, 0, 0, 0,
        0, 0, 0x78E8, 0, 0, 0, 0x58E0, 0x78E0, 0x48E8,
        0x50E0, 0x58E0, 0x60E0, 0x68E0, 0, 0x38E8, 0xB800, 0xE800, 0,
        0x80F8, 0xD8F0, 0xE0F0, 0xD0F0, 0xC0F0, 0x9800, 0x9000, 0x8000, 0x8800,
        0xA800, 0xD0F8, 0x98F8, 0xE0FB, 0x3000, 0, 0, 0, 0x2000,
        0, 0x2800, 0x7000, 0x1800, 0x1000, 0, 0x0800, 0x4000, 0x4800,
        0, 0, 0x38F8, 0, 0, 0, 0, 0, 0,
        0, 0x78F8, 0x48F8, 0x50F8, 0x58F8, 0x30F8, 0x10F8, 0, 0,
        0x3800, 0, 0, 0, 0, 0, 0, 0, 0x7800,
        0x48F8, 0x5000, 0x5800, 0x6000, 0x6800, 0x60F8, 0, 0, 0,
        0, 0, 0, 0, 0xD803, 0xD802, 0xF002, 0xF000, 0xF001,
        0, 0xF802, 0xF800, 0xF801, 0, 0xC8F8, 0xA300, 0, 0xB8F8,
        0, 0, 0xA200, 0, 0xCCF8, 0, 0xC9F8, 0xA000, 0,
        0, 0xA100, 0, 0, 0xB3E0, 0, 0, 0xB6E0, 0,
        0xB2E0, 0xB4E0, 0xE8F3, 0xB5E0, 0xB0E0, 0, 0xB7E0, 0, 0xB1E0,
        0, 0, 0xB300, 0, 0xB700, 0xB600, 0, 0xB200, 0xB400,
        0, 0xB500, 0xB000, 0, 0, 0, 0xB100, 0, 0,
        0, 0, 0, 0x20F8, 0, 0x28F8, 0x70F8, 0, 0,
        0x00F8, 0x08F8, 0x68F8, 0xF003]
else:  # bfs
    AP101INST = [      0, 0, 0xB8E0, 0x88E0,
        0xC8E8, 0xE0E0, 0xD0E0, 0xC0E0, 0, 0, 0, 0, 0,
        0x90E8, 0x68E8, 0xC0E8, 0, 0, 0, 0xE8E8, 0x20E0, 0,
        0x28E0, 0x70E0, 0x18E0, 0x10E0, 0x00E0, 0x08E0, 0x40E0, 0x48E0, 0,
        0x38E0, 0, 0, 0, 0, 0, 0, 0, 0x58E8,
        0, 0x48E8, 0x50E8, 0x58E8, 0x30E8, 0x10E8, 0, 0, 0,
        0, 0, 0x78E8, 0, 0, 0, 0x58E0, 0x78E0, 0x48E8,
        0x50E0, 0x58E0, 0x60E0, 0x68E0, 0, 0x38E8, 0xB800, 0xE800, 0xC8F0,
        0x80F8, 0xD8F0, 0xE0F0, 0xD0F0, 0xC0F0, 0x9800, 0x9000, 0x8000, 0x8800,
        0xA800, 0xD0F8, 0x98F8, 0xE0FB, 0x3000, 0, 0, 0, 0x2000,
        0, 0x2800, 0x7000, 0x1800, 0x1000, 0, 0x0800, 0x4000, 0x4800,
        0, 0, 0x38F8, 0, 0, 0, 0, 0, 0,
        0, 0x78F8, 0x48F8, 0x50F8, 0x58F8, 0x30F8, 0x10F8, 0, 0,
        0x3800, 0, 0, 0, 0, 0, 0, 0, 0x7800,
        0x48F8, 0x5000, 0x5800, 0x6000, 0x6800, 0x60F8, 0, 0, 0,
        0xD803, 0, 0, 0, 0xD803, 0xD802, 0xF002, 0xF000, 0xF001,
        0, 0xF802, 0xF800, 0xF801, 0, 0xC8F8, 0xA300, 0, 0xB8F8,
        0, 0, 0xA200, 0, 0xCCF8, 0, 0xC9F8, 0xA000, 0,
        0, 0xA100, 0, 0, 0xB3E0, 0, 0, 0xB6E0, 0,
        0xB2E0, 0xB4E0, 0xE8F3, 0xB5E0, 0xB0E0, 0, 0xB7E0, 0, 0xB1E0,
        0, 0, 0xB300, 0, 0xB700, 0xB600, 0, 0xB200, 0xB400,
        0, 0xB500, 0xB000, 0, 0, 0, 0xB100, 0, 0,
        0, 0, 0, 0x20F8, 0, 0x28F8, 0x70F8, 0, 0,
        0x00F8, 0x08F8, 0x68F8, 0xF003]
if SANITY_CHECK and len(AP101INST) != OPMAX + 1:
    print('Bad AP101INST', file=sys.stderr)
    sys.exit(1)
   
INDIRECTION = (' ', '@', '#', '@#')
CCREG = 0

# DECLARATIONS TO DESCRIBE REGISTER CONTENTS  
REG_NUM = 15
REG_NUM_2 = 63 
ENV_NUM = 2
ENV_PTR = ENV_NUM
ENV_BASE = [REG_NUM + 1, 2 * (REG_NUM + 1), 3 * (REG_NUM + 1)]
ENV_LBL = [0] * (ENV_NUM + 1)
BASE_NUM = 79
USAGE = [0] * (REG_NUM_2 + 1)
if not pfs:  # BASE REG ALLOCATION (ADCON) 
    R_BASE = [0] * (BASE_NUM + 1)
    R_SECTION = [0] * (BASE_NUM + 1)
    R_BASE_USED = [0] * (BASE_NUM + 1)
USAGE_LINE = [0] * (REG_NUM + 1)
R_VAR = [0] * (REG_NUM_2 + 1)
R_INX = [0] * (REG_NUM_2 + 1)
R_INX_SHIFT = [0] * (REG_NUM_2 + 1)
R_INX_CON = [0] * (REG_NUM_2 + 1)

# I bet these two form a single array ...
R_CON = [0] * (REG_NUM_2 + 1)
R_XCON = [0] * (REG_NUM_2 + 1)

R_CONTENTS = [0] * (REG_NUM_2 + 1)
R_TYPE = [0] * (REG_NUM_2 + 1)
DOUBLE_TYPE = [0] * (REG_NUM_2 + 1)

# I bet these two form a single array ...
R_VAR2 = [0] * (REG_NUM_2 + 1)
R_MULT = [0] * (REG_NUM_2 + 1)
R_PARM = [0] * (REG_NUM_2 + 1)

if pfs:  # BASE REG ALLOCATION (ADCON) 
    ''' IN THE RECORD BASE_REGS, FIELD 'ADDR' IS SET IN
        'GENERATE_CONSTANTS' AND USED IN 'OBJECT_GENERATOR'.  FIELDS
        'BASE', 'BASE_USED', AND 'SECTION' ARE SET IN 'INITIALIZE' AND
        'GENERATE' AND USED IN 'GENERATE_CONSTANTS' '''

    class base_regs:

        def __init__(self):
            self.OFFSET = 0  # OFFSET IN CSECT TO WHICH BASE REG POINTS
            self.BASE_USED = 0  # NUMBER OF TIMES THE BASE REG IS LOADED 
            self.ADDR = 0  # ADDRESS WHERE ADCON IS EMITTED
            self.SECTION = 0  # CSECT THAT BASE REG POINTS TO 
            self.SORT = 0  # USED FOR SORTING REGS BY NUMBER OF LOADS 

    BASE_REGS = []  # Elements are class base_regs.
    
    def R_BASE(n, value=None):
        global BASE_REGS
        while len(BASE_REGS) <= n:
            BASE_REGS.append(base_regs())
        if value == None:
            return BASE_REGS[n].OFFSET
        else:
            BASE_REGS[n].OFFSET = value
            
    def R_SECTION(n, value=None):
        global BASE_REGS
        while len(BASE_REGS) <= n:
            BASE_REGS.append(base_regs())
        if value == None:
            return BASE_REGS[n].SECTION
        else:
            BASE_REGS[n].SECTION = value
            
    def R_BASE_USED(n, value=None):
        global BASE_REGS
        while len(BASE_REGS) <= n:
            BASE_REGS.append(base_regs())
        if value == None:
            return BASE_REGS[n].BASE_USED
        else:
            BASE_REGS[n].BASE_USED = value

    def R_ADDR(n, value=None):
        global BASE_REGS
        while len(BASE_REGS) <= n:
            BASE_REGS.append(base_regs())
        if value == None:
            return BASE_REGS[n].ADDR
        else:
            BASE_REGS[n].ADDR = value
            
    def R_SORT(n, value=None):
        global BASE_REGS
        while len(BASE_REGS) <= n:
            BASE_REGS.append(base_regs())
        if value == None:
            return BASE_REGS[n].SORT
        else:
            BASE_REGS[n].SORT = value

INDEXING = [0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0]
if SANITY_CHECK and len(INDEXING) != REG_NUM + 1:
    print('Bad INDEXING', file=sys.stderr)
    sys.exit(1)

RCLASS_START = [0, 4, 12, 0, 0, 0, 0]
REGISTERS = [8, 10, 12, 14, 8, 10, 12, 14, 11, 13, 15, 9] + ([0] * (64 - 12))
RM = 0x7
LINKREG = 4
PROGBASE = 1
PRELBASE = 9
TEMPBASE = 0
PROCBASE = 3
REMOTE_BASE = 9
NEXTDECLREG = 0
TARGET_REGISTER = -1
NOT_THIS_REGISTER = -1
NOT_THIS_REGISTER2 = -1
TARGET_R = -1
SYSARG0 = [2, 1, 2, 1]
SYSARG1 = [2, 2, 4, 2]
SYSARG2 = [4, 3, 7, 3]
FR0 = 8
# FR1 = 9
FR2 = 10
FR4 = 12
# FR6 = 14
FR7 = 15
R0 = 0
R1 = 1
R3 = 3
FIXARG1 = 5
FIXARG2 = 6
FIXARG3 = 7
PTRARG1 = 2

ALWAYS = 7
EQ = 4
NEQ = 3
GT = 1
# LT = 2
GQ = 5
LQ = 6
EZ = 4

# ERROR_POINT = 1
REGISTER_SAVE_AREA = [2, 0]
STACK_LINK = [2, 0]  # 2 * TEMPBASE + R_S_A 
STACK_FREEPOINT = [18, 16]
NEW_STACK_LOC = [0, 3]
NEW_LOCAL_BASE = [9, 1]
NEW_GLOBAL_BASE = [5, 2]

FLOATING_ACC = 1
DOUBLE_FACC = 0
FIXED_ACC = 3
DOUBLE_ACC = 2
INDEX_REG = 4
ODD_REG = 5

# CODE RETRIEVAL DECLARATIONS 
CODEFILE = 4
CURCBLK = 0

# CHARACTER AND LABEL BUFFERS AND POINTERS 
INSMOD = 0
AREASAVE = 0
CHARSTRING = ''
MESSAGE = ''
INFO = ''
FIRSTLABEL = 0
SECONDLABEL = 0
LHSPTR = 0


class lab_loc:

    def __init__(self):
        self.LOCAT = 0
        self.LOCAT_STp = 0
        self.LINK_LOCATION = 0


LAB_LOC = []  # Entries are class lab_loc


class stmtnum:

    def __init__(self):
        self.ARRAY_LABEL = 0


STMTNUM = []  # Entries are class stmtnum

# CONSTANT VALUES OR DESCRIPTORS FOR CODE GENERATION  
CONST_LIM = 2000
CONSTANT_CTR = 0
CONSTANT_REFS = [0] * (7 + 1)
MAX_SRS_DISP = [0] * (1 + 1)
SRS_REFS = [0] * (1 + 1)
CONSTANT_HEAD = [0] * (7 + 1)
CONSTANTS = [0] * (CONST_LIM + 1)
CONSTANT_PTR = [0] * (CONST_LIM + 1)

CURRENT_ESDID = 0
NO_SRS = 0
DOCOPY = [0] * (5 + 1)
STACKp = 0
VDLP_DETECTED = 0
VDLP_ACTIVE = 0
VDLP_IN_EFFECT = 0
STRI_ACTIVE = 0
ARRAY_FLAG = 0

# DO LOOP DESCRIPTOR DECLARATIONS  
DOSIZE = 25
DOLEVEL = 0
DOTYPE = [0] * (DOSIZE + 1)

CODE_LISTING_REQUESTED = 0
DECK_REQUESTED = 0
TRACING = 0
NO_VM_OPT = 0
MARKER_ISSUED = 0
HALMAT_REQUESTED = 0
ASSEMBLER_CODE = 0
BINARY_CODE = 0
DIAGNOSTICS = 0
REGISTER_TRACE = 0
SUBSCRIPT_TRACE = 0
HIGHOPT = 0
SELFNAMELOC = 0

#  ERROR CLASSES DECLARATION 
CLASS_B = 4
CLASS_BI = 6
CLASS_BS = 8
CLASS_BX = 10
CLASS_D = 12
CLASS_DI = 17
CLASS_DQ = 20
# CLASS_DS = 21
CLASS_DU = 23
CLASS_E = 24
CLASS_EA = 25
CLASS_F = 34
CLASS_FD = 35
CLASS_FN = 36
CLASS_FT = 38
# CLASS_GC = 41
CLASS_PE = 63
CLASS_PF = 64
CLASS_PR = 68
CLASS_QD = 74
# CLASS_RT = 79
CLASS_SR = 86
CLASS_XQ = 107
CLASS_XR = 108  # #DFLAG - ADD CLASS, RENUM REST 
CLASS_XS = 109
# CLASS_Z = 112
CLASS_ZB = 113
CLASS_ZC = 114
# CLASS_ZI = 115
# CLASS_ZN = 116
CLASS_ZO = 117
CLASS_ZP = 118
# CLASS_ZR = 119
CLASS_ZS = 120
CLASS_YA = 121
CLASS_YC = 122
CLASS_YE = 123
CLASS_YF = 124
ERROR_CLASSES = 'A AAAVB BBBIBNBSBTBXC D DADCDDDFDIDL' \
    'DNDQDSDTDUE EAEBECEDELEMENEOEVF FDFNFSFTG GBGCGEGLGVI ILIRISL LBLCLFLSM MCMEMOMS' \
    'P PAPCPDPEPFPLPMPPPRPSPTPUQ QAQDQSQXR RERTRUS SASCSPSQSRSSSTSVT TCTDU UIUPUTV VA' \
    'VCVEVFX XAXDXIXMXQXRXSXUXVZ ZBZCZIZNZOZPZRZSYAYCYEYF'

#   SUBPROGRAM CONTROL DECLARATIONS  
CALLp = [0] * (1 + PROCp)
NARGS = [0] * (1 + PROCp)
PROC_LEVEL = [0] * (1 + PROCp)
PROC_LINK = [0] * (1 + PROCp),
LASTLABEL = [0] * (1 + PROCp)
MAXTEMP = [0] * (1 + PROCp)
ORIGIN = [0] * (1 + PROCp)
if pfs:  #  BFS/PASS INTERFACE 
    LOCCTR = [0] * (1 + PROCp)
    STACKSPACE = [0] * (1 + PROCp)
    MAXERR = [0] * (1 + PROCp)
CSECT_BOUND = [0] * (1 + PROCp)
LASTBASE = [0] * (1 + PROCp)
if not pfs:  # BFS/PASS INTERFACE 
   LOCCTR = [0] * (1 + PROCp)
   STACKSPACE = [0] * (1 + PROCp)
   MAXERR = [0] * (1 + PROCp)
WORKSEG = [0] * (1 + PROCp)
ERRSEG = [0] * (1 + PROCp)
NOT_LEAF = [0] * (1 + PROCp)
OVERFLOW_LEVEL = [0] * (1 + PROCp)
REMOTE_LEVEL = [0] * (1 + PROCp)
ERRALLGRP = [0] * (1 + PROCp)
INDEXNEST = [0] * (1 + PROCp)
if not pfs:  # BFS/PASS INTERFACE; SVC 
    FIRST_TIME = [0] * (1 + PROCp) 
    LAST_SVCI = [0] * (1 + PROCp)
    LAST_LOGICAL_STMT = [0] * (1 + PROCp) 
    PUSHED_LOCCTR = [0] * (1 + PROCp)
CALL_LEVEL = 0
ARG_STACK_PTR = 0
ARGp = 0
SF_RANGE_PTR = 0
SF_DISP = 0
PROCPOINT = 0
PROCLIMIT = 0
PROGPOINT = 0
TASKp = 0
TASKPOINT = 0
ENTRYPOINT = 0
XPROGLINK = 0
STACKPOINT = 0
PROGCODE = 0
PROGDATA = [0] * (1 + 1) 
FSIMBASE = 0
DATALIMIT = 0
FIRSTREMOTE = 0
LASTREMOTE = 0
PCEBASE = 0
EXCLBASE = 0
EXCLUSIVEp = 0
SYMBREAK = 0
NARGINDEX = 0
SDELTA = 0
ARGPOINT = 0
ARGTYPE = 0
ARGNO = 0
R_PARMp = -1
INLINE_RESULT = 0
CMPUNIT_ID = 0
STACK_DUMP = 0
LAST_STACK_HEADER = 0
DSR = 0
DUMMY = ''
PMINDEX = 0
UPDATING = 0
LIB_POINTER = 0
TEMPLATE_CLASS = 7
UPDATE_FLAGS = 'SYT_CONST(UPDATING)'
DOUBLEFLAG = 0

# USEFUL CHARACTER LITERALS 
COLON = ':'
COMMA = ','
BLANK = ' '
LEFTBRACKET = '('
RIGHTBRACKET = ')'
PLUS = '+'
QUOTE = "'"
HEXCODES = '0123456789ABCDEF'
if not pfs:  # BFS/PASS INTERFACE; #Z OBJECT MODULE 
    POUND_Z = '#Z'
X2 = ' ' * 2
X3 = ' ' * 3
X4 = ' ' * 4
X72 = ' ' * 72

#  SYMBOL TABLE DEPENDENT DECLARATIONS  
SYT_SIZE = 0
ERRLIM = 100
LITSIZ = 130
LITFILE = 2

# /%INCLUDE COMMON %/


class p2syms:

    def __init__(self):
        self.SYM_CONST = 0
        self.SYM_BASE = 0
        self.SYM_DISP = 0
        self.SYM_PARM = 0
        self.SYM_LEVEL = 0


P2SYMS = []  # Entries are class p2syms

SYT_LABEL = 'SYT_LINK2'


class dosort:

    def __init__(self):
        self.SYM_SORT = 0


DOSORT = []  # Entries are class dosort

VALS = []  # Entries are FIXED;

   
def LIT_CHAR_SIZE(value=None):
    global VALS
    if value == None:
        return VALS[5]
    VALS[5] = value


NDECSY = 0


class page_fix:

    def __init__(self):
        self.TAB_OFF_PAGE = 0
        self.LINE_OFF_PAGE = 0


PAGE_FIX = []  # Entries are class page_fix.

      
def OFF_PAGE_MAX(value=None):
    global COMM
    index = 19
    if value == None:
        return COMM[index]
    COMM[index] = value


OFF_PAGE_NEXT = 0
OFF_PAGE_LAST = 0
DATABASE = [0] * (1 + PROCp)
OFF_PAGE_BASE = [0] * (1 + 1)
OFF_PAGE_CTR = [0] * (1 + 1)


class dns:

    def __init__(self):
        self.DNSADDR = 0
        self.DNSVAL = 0


DNS = []  # Entries are class dns


def LIT_CHAR_ADDR(value=None):
    global COMM
    index = 0
    if value == None:
        return COMM[index]
    COMM[index] = value


def LIT_CHAR_USED(value=None):
    global COMM
    index = 1
    if value == None:
        return COMM[index]
    COMM[index] = value


def LIT_TOP(value=None):
    global COMM
    index = 2
    if value == None:
        return COMM[index]
    COMM[index] = value

'''
def STMT_NUM(value = None):
    global COMM
    index = 3
    if value == None:
        return COMM[index]
    COMM[index] = value
'''


def FL_NO_MAX(value=None):
    global COMM
    index = 4
    if value == None:
        return COMM[index]
    COMM[index] = value


def MAX_SCOPEp(value=None):
    global COMM
    index = 5
    if value == None:
        return COMM[index]
    COMM[index] = value


def TOGGLE(value=None):
    global COMM
    index = 6
    if value == None:
        return COMM[index]
    COMM[index] = value


def OPTION_BITS(value=None):
    global COMM
    index = 7
    if value == None:
        return COMM[index]
    COMM[index] = value


def SYT_MAX(value=None):
    global COMM
    index = 10
    if value == None:
        return COMM[index]
    COMM[index] = value


def FIRSTSTMTp(value=None):
    global COMM
    index = 11
    if value == None:
        return COMM[index]
    COMM[index] = value

'''
def BLOCK_SRN_DATA(value = None):
    global COMM
    index = 18
    if value == None:
        return COMM[index]
    COMM[index] = value
'''


def CODEHWM(value=None):
    global COMM
    index = 30
    if value == None:
        return COMM[index]
    COMM[index] = value

'''
def LASTSTMTp(value = None):
    global COMM
    index = 3
    if value == None:
        return COMM[index]
    COMM[index] = value
'''


def DATA_HWM(value=None):
    global COMM
    index = 23
    if value == None:
        return COMM[index]
    COMM[index] = value


def REMOTE_HWM(value=None):
    global COMM
    index = 24
    if value == None:
        return COMM[index]
    COMM[index] = value


def PRIMARY_LIT_START(value=None):
    global COMM
    index = 27
    if value == None:
        return COMM[index]
    COMM[index] = value


def PRIMARY_LIT_END(value=None):
    global COMM
    index = 28
    if value == None:
        return COMM[index]
    COMM[index] = value


def TIME_OF_COMPILATION(value=None):
    global COMM
    index = 12
    if value == None:
        return COMM[index]
    COMM[index] = value


def DATE_OF_COMPILATION(value=None):
    global COMM
    index = 13
    if value == None:
        return COMM[index]
    COMM[index] = value


def STMT_DATA_HEAD(value=None):
    global COMM
    index = 16
    if value == None:
        return COMM[index]
    COMM[index] = value


def OBJECT_MACHINE(value=None):
    global COMM
    index = 20
    if value == None:
        return COMM[index]
    COMM[index] = value


def OBJECT_INSTRUCTIONS(value=None):
    global COMM
    index = 21
    if value == None:
        return COMM[index]
    COMM[index] = value


LITORG = 0
LITLIM = 0
CURLBLK = 0
COUNTpGETL = 0

CODE_BASE = 0
CODE_LIM = 0
CODE_BLK = 0
CODE_MAX = 0
CODE_LINE = 0
MAX_CODE_LINE = 0
SPLIT_DELTA = 0
CODE_FILE = 3
CODE_SIZE = 400 
CODE_SIZ = 399
CODE = [0] * (1 + CODE_SIZ)
NOT_MODIFIER = [0] * (1 + 64)

AUX_BASE = 0
AUX_LIM = 0
AUX_BLK = 0
AUX_CTR = 0
AUX_FILE = 1
AUXMAT_REQUESTED = 'HALMAT_REQUESTED'
AUX_SIZ = 1799
AUX_SIZE = '(AUX_SIZ+1)'
AUX = [0] * (1 + AUX_SIZ)

LHS = [0] * (1 + 3)
RHS = [0] * (1 + 3)
TEMP2 = 0
PASS1_ADCONS = 0
ERRORp = 0
SDINDEX = 0
LITTRACE = 0
LITTRACE2 = 0
SDBASE = 2


class ind_stack:

    def __init__(self):
        self.I_CONST = 0
        self.I_INX_CON = 0
        self.I_STRUCT_CON = 0
        self.I_VAL = 0
        self.I_XVAL = 0
        self.I_BACKUP_REG = 0
        self.I_BASE = 0
        self.I_COLUMN = 0
        self.I_COPY = 0
        self.I_DEL = 0
        self.I_DISP = 0
        self.I_FORM = 0
        self.I_INX = 0
        self.I_INX_MUL = 0
        self.I_INX_NEXT_USE = 0
        self.I_LOC = 0
        self.I_LOC2 = 0
        self.I_NEXT_USE = 0
        self.I_REG = 0
        self.I_ROW = 0
        self.I_TYPE = 0
        self.I_CSE_USE = 0
        self.I_DSUBBED = 0
        # NEW VARIABLES FOR NAME REMOTE DEREFERENCING: 
        # NRSTACK SAVES LOC WHEN A REMOTE NR IS PUT ON STACK 
        # NRDELTA SAVES INDEX TO BE ADDED TO NR'S DISP 
        # NRDEREF INDICATES A NR DEREFERENCE IS TAKING PLACE 
        self.I_NRSTACK = 0
        self.I_NRDELTA = 0
        self.I_NRDEREF = 0
        self.I_NRDEREFTMP = 0
        self.I_NRBASE = 0
        self.I_INX_SHIFT = 0
        self.I_STRUCT = 0
        self.I_STRUCT_INX = 0
        self.I_VMCOPY = 0
        self.I_PNTREMT = 0
        self.I_LIVREMT = 0
        self.I_NAMEVAR = 0
        self.I_STRUCT_WALK = 0
        self.I_AIADONE = 0


IND_STACK = []
for i in range(STACK_SIZE + 1):
    IND_STACK.append(ind_stack())

# VAR_CLASS = 1
# LABEL_CLASS = 2
# FUNC_CLASS = 3
MAJ_STRUC = 0x0A
TEMPL_NAME = 0x3E
# IND_PTR = 0x3F
LOCK_BITS = 0x00000001
REENTRANT_FLAG = 0x00000002
DENSE_FLAG = 0x00000004
PARM_FLAGS = 0x00000420
ASSIGN_FLAG = 0x00000020
DEFINED_LABEL = 0x00000040
REMOTE_FLAG = 0x00000080
AUTO_FLAG = 0x00000100
CONSTANT_FLAG = 0x00001000
NOTLEAF_FLAG = 0x00002000
ENDSCOPE_FLAG = 0x00004000
BITMASK_FLAG = 0x00008000
LATCH_FLAG = 0x00020000
# IMPL_T_FLAG = 0x00040000
EXCLUSIVE_FLAG = 0x00080000
EXTERNAL_FLAG = 0x00100000
EVIL_FLAGS = 0x00200000
DOUBLE_FLAG = 0x00400000
IGNORE_FLAG = 0x01040000
SM_FLAGS = 0x14C2008C
PM_FLAGS = 0x00C20080
NPM_FLAGS = 0x00C20080
NI_FLAGS = 0x00C20000
INCLUDED_REMOTE = 0x02000000
RIGID_FLAG = 0x04000000
TEMPORARY_FLAG = 0x08000000
NAME_FLAG = 0x10000000
ASSIGN_OR_NAME = 0x10000020
NAME_OR_REMOTE = 0x10000080
DEFINED_BLOCK = 0x10100000
POINTER_FLAG = 0x80000000
POINTER_OR_NAME = 0x90000000
SDF_INCL_FLAG = 0x00000800
SDF_INCL_LIST = 0x00001000
NONHAL_FLAG = 0x01
ANY_LABEL = 0x40
# IND_STMT_LAB = 0x41
STMT_LABEL = 0x42
IND_CALL_LAB = 0x45
# PROC_LABEL = 0x47
TASK_LABEL = 0x48
PROG_LABEL = 0x49
COMPOOL_LABEL = 0x4A

if pfs:  # BRANCH CONDENSING  

    # TO KEEP A TABLE OF ALL THE BRANCH INSTRUCTIONS, FOR POSSIBLE
    #   CONDENSING.  USED IN PROCEDURE OBJECT_CONDENSER
    class branch_tbl:

        def __init__(self):
            self.INT_CODELINE = 0  # LINE IN INTERMEDIATE CODE FILE 
            self.B_ADDR = 0  # AP101 ADDRESS OF BRANCH 
            self.TARGET = 0  # POINTER TO LABEL TABLE 'LAB_LOC' 
            self.B_FLINK = 0  # POINTER TO NEXT BRANCH 
            self.B_BLINK = 0  # POINTER TO PREVIOUS BRANCH 

    BRANCH_TBL = []  # Entries are class branch_tbl
    
    LASTBRANCH = [0] * (1 + PROCp)
    FIRSTBRANCH = [0] * (1 + PROCp)

#   VARIABLE TABLES AND POINTERS  
TYP_SIZE = 20
FULLTEMP = 0
SAVEPOINT = [0] * (1 + LASTEMP)
ARRAYPOINT = [0] * (1 + LASTEMP)

# Regarding these items:  In XPL, UPPER had only two init values
# and LOWER had only one.  (And there's no documention that tells us
# what that means.)  But if these are upper and lower bounds of 
# unsigned numbers, the following initialization makes sense.
UPPER = [-1] * (1 + LASTEMP)
LOWER = [BIGNUMBER] * (1 + LASTEMP)

SAVED_LINE = [0] * (1 + LASTEMP)
POINT = [0] * (1 + LASTEMP)
WORK_USAGE = [0] * (1 + LASTEMP)
WORK_BLK = [0] * (1 + LASTEMP)
WORK_CTR = [0] * (1 + LASTEMP)
TEMPSPACE = 0
SAVEPTR = 0
IX1 = 0
IX2 = 0
KIN = 0
OPTYPE = 0
AREA = 0
ARRCONST = 0
INDEX = 0
STATNO = 0
TMP = 0
LITTYPE = 0
WORK1 = 0
WORK2 = 0
PACKFORM = [0] * (1 + 31)
SYMFORM = [0] * (1 + 31)
BLOCK_CLASS = [0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0]
PACKFUNC_CLASS = [0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0]
# In XPL, all of the following were initialized with one less element
# than the declared size.  I've added an extra element to each.
PACKTYPE = [1, 1, 2, 0, 0, 3, 3, 3, 0, 1, 1, 0, 0, 3, 3, 1, 4, 1, 1, 3, 0]
SELECTYPE = [5, 0, 4, 5, 5, 2, 0, 0, 5, 1, 4, 5, 5, 3, 1, 5, 0, 0, 5, 0, 0]
CHARTYPE = [5, 4, 4, 5, 5, 2, 0, 0, 5, 4, 4, 5, 5, 3, 1, 4, 0, 4, 4, 0, 0]
DATATYPE = [0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 1, 3, 4, 5, 6, 1, 0, 1, 1, 7, 0]
CVTTYPE = [0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0]
BIGHTS = [2, 1, 1, 2, 2, 2, 1, 2, 4, 2, 1, 4, 4, 4, 2, 2, 1, 1, 1, 2, 0]
OPMODE = [3, 1, 0, 3, 3, 3, 1, 1, 4, 2, 0, 4, 4, 4, 2, 2, 5, 1, 0, 2, 0]
RCLASS = [2, 3, 3, 1, 1, 1, 3, 3, 0, 3, 3, 0, 0, 0, 3, 3, 0, 3, 3, 3, 0]
SHIFT = [1, 0, 0, 1, 1, 1, 0, 0, 2, 1, 0, 2, 2, 2, 1, 1, 0, 0, 0, 1, 0]
if SANITY_CHECK and len(SHIFT) != TYP_SIZE + 1:
    print('Bad SHIFT et al', file=sys.stderr)
    sys.exit(1)

#  LIBRARY CALL DECLARATIONS  
IOMODE = 0
if not pfs:  #  BFS/PASS INTERFACE; OBJECT MODULE 
    OBJECT_MODULE_STATUS = 0
    OBJECT_MODULE_NAME = ''
ESD_LIMIT = 400 
ESD_CHAR_LIMIT = 12
ESD_MAX = 1 
ESD_NAME = [''] * (1 + ESD_CHAR_LIMIT)
if not pfs:  # BFS/PASS INTERFACE; OBJECT MODULE 
    LEC = 3
    ZCON_CSECT_TYPE = 0x60
    LIBRARY_CSECT_TYPE = 0xA0
    CODE_CSECT_TYPE = 0x80
    DATA_CSECT_TYPE = 0x40
ESD_TYPE = [0] * (1 + ESD_LIMIT)
ESD_NAME_LENGTH = [0] * (1 + ESD_LIMIT)
ESD_LINK = [0] * (1 + ESD_LIMIT)
if not pfs:  # BFS/PASS INTERFACE; OBJECT MODULE 
    ESD_CSECT_TYPE = [0] * (1 + ESD_LIMIT)
ESD_START = [0] * (1 + HASHSIZE)
LIB_NUM = 282
LIB_NAMES = (
    'ACOSACOSHASINASINHATANATANHBINBOUTBTOCCASCASPCASPVCASRCASRPCASRPVCASRVCASVCATCA'
    'TVCEILCINCINDEXCINPCLJSTVCOLUMNCOSCOSHCOUTCOUTPCPASCPASPCPASRCPASRPCPRCPRACPRCCP'
    'SLDCPSLDPCPSSTCPSSTPCRJSTVCSHAPQCSLDCSLDPCSSTCSSTPCSTRCSTRUCCTOBCTODCTOECTOHCTOI'
    'CTOKCTOOCTOX',
    'CTRIMVDACOSDACOSHDASINDASINHDATANDATANHDATAN2DCEILDCOSDCOSHDEXPDFLOORDINDLOGDMA'
    'XDMDVALDMINDMODDOUTDPRODDPWRDDPWRHDPWRIDROUNDDSINDSINHDSLDDSNCSDSQRTDSSTDSUMDTAN'
    'DTANHDTOCDTOHDTOIDTRUNCEATAN2EINEMAXEMINEMODEOUTEPRODEPWREEPWRHEPWRIESUMETOCETOH'
    'ETOIEXPFLOOR',
    'GTBYTEHINHMAXHMINHMODHOUTHPRODHPWRHHREMHSUMHTOCIINIMAXIMINIMODIOINITIOUTIPRODIP'
    'WRHIPWRIIREMISUMITOCITODITOEKTOCLINELOGMMRDNPMMRSNPMMWDNPMMWSNPMM0DNPMM0SNPMM1DN'
    'PMM1SNPMM1TNPMM1WNPMM11DNMM11D3MM11SNMM11S3MM12DNMM12D3MM12SNMM12S3MM13DNMM13D3M'
    'M13SNMM13S3',
    'MM14DNMM14D3MM14SNMM14S3MM15DNMM15SNMM17DNMM17D3MM17SNMM17S3MM6DNMM6D3MM6SNMM6S'
    '3MR0DNPMR0SNPMR1DNPMR1SNPMR1TNPMR1WNPMSTRMSTRUCMV6DNMV6D3MV6SNMV6S3OTOCOUTER1PAG'
    'EQSHAPQRANDGRANDOMROUNDSINSINHSKIPSNCSSQRTSTBYTETABTANTANHTRUNCVM6DNVM6D3VM6SNVM'
    '6S3VO6DNVO6D3',
    'VO6SNVO6S3VR0DNVR0DNPVR0SNVR0SNPVR1DNVR1DNPVR1SNVR1SNPVR1TNVR1TNPVR1WNVR1WNPVV'
    'DNVV0DNPVV0SNVV0SNPVV1DNVV1DNPVV1D3VV1D3PVV1SNVV1SNPVV1S3VV1S3PVV1TNVV1TNPVV1T3V'
    'V1T3PVV1WNVV1WNPVV1W3VV1W3PVV10DNVV10D3VV10SNVV10S3VV2DNVV2D3VV2SNVV2S3VV3DNVV3D'
    '3VV3SNVV3S3',
    'VV4DNVV4D3VV4SNVV4S3VV5DNVV5D3VV5SNVV5S3VV6DNVV6D3VV6SNVV6S3VV7DNVV7D3VV7SNVV7S'
    '3VV8DNVV8D3VV8SNVV8S3VV9DNVV9D3VV9SNVV9S3VX6D3VX6S3XTOC');
LIB_NAME_INDEX = [ 0, 67108864, 83887104, 67111168,
    83889408, 67113472, 83891712, 50338560, 67116544, 67117568, 50341376,
    67119360, 83897600, 67121664, 83899904, 100678400, 83902720, 67126784,
    50350592, 67128576, 67129600, 50353408, 100685824, 67132928, 100688384,
    100689920, 50359808, 67137792, 67138816, 83917056, 67141120, 83919360,
    83920640, 100699136, 50369024, 67147008, 67148032, 83926272, 100704768,
    83929088, 100707584, 100709120, 100710656, 67157760, 83936000, 67160064,
    83938304, 67162368, 100717824, 67164928, 67165952, 67166976, 67168000,
    67169024, 67170048, 67171072, 67172096, 100663297, 83887617, 100666113,
    83890433, 100668929, 83893249, 100671745, 100673281, 83897601, 67121665,
    83899905, 67123969, 100679425, 50349313, 67127297, 67128321, 100683777,
    67130881, 67131905, 67132929, 83911169, 83912449, 83913729, 83915009,
    100693505, 67140609, 83918849, 67142913, 83921153, 83922433, 67146497,
    67147521, 67148545, 83926785, 67150849, 67151873, 67152897, 100708353,
    100709889, 50379777, 67157761, 67158785, 67159809, 67160833, 83939073,
    83940353, 83941633, 83942913, 67166977, 67168001, 67169025, 67170049,
    50393857, 83949057, 100663298, 50333186, 67111170, 67112194, 67113218,
    67114242, 83892482, 83893762, 67117826, 67118850, 67119874, 50343682,
    67121666, 67122690, 67123714, 100679170, 67126274, 83904514, 83905794,
    83907074, 67131138, 67132162, 67133186, 67134210, 67135234, 67136258,
    67137282, 50361090, 100693506, 100695042, 100696578, 100698114,
    100699650, 100701186, 100702722, 100704258, 100705794, 100707330,
    100708866, 100710402, 100711938, 100713474, 100715010, 100716546,
    100718082, 100719618, 100721154, 100722690, 100724226, 100725762,
    100663299, 100664835, 100666371, 100667907, 100669443, 100670979,
    100672515, 100674051, 100675587, 100677123, 83901443, 83902723,
    83904003, 83905283, 100683779, 100685315, 100686851, 100688387,
    100689923, 100691459, 67138563, 100694019, 83918339, 83919619, 83920899,
    83922179, 67146243, 100701699, 67148803, 100704259, 83928579, 100707075,
    83931395, 50378243, 67156227, 67157251, 67158275, 67159299, 100714755,
    50384643, 50385411, 67163395, 83941635, 83942915, 83944195, 83945475,
    83946755, 83948035, 83949315, 83886084, 83887364, 83888644, 100667140,
    83891460, 100669956, 83894276, 100672772, 83897092, 100675588, 83899908,
    100678404, 83902724, 100681220, 83905540, 100684036, 83908356,
    100686852, 83911172, 100689668, 83913988, 100692484, 83916804,
    100695300, 83919620, 100698116, 83922436, 100700932, 83925252,
    100703748, 83928068, 100706564, 83930884, 100709380, 100710916,
    100712452, 100713988, 100715524, 83939844, 83941124, 83942404, 83943684,
    83944964, 83946244, 83947524, 83948804, 83886085, 83887365, 83888645,
    83889925, 83891205, 83892485, 83893765, 83895045, 83896325, 83897605,
    83898885, 83900165, 83901445, 83902725, 83904005, 83905285, 83906565,
    83907845, 83909125, 83910405, 83911685, 83912965, 83914245, 83915525,
    83916805, 83918085, 67142149]
if SANITY_CHECK and len(LIB_NAME_INDEX) != LIB_NUM + 1:
    print('Bad LIB_NAME_INDEX', file=sys.stderr)
    sys.exit(1)

# THE LIB_POINTERS (AS STORED IN LIB_START AND LIB_LINK) FOR EACH  
# UNVERIFIED RTL ROUTINE ARE NOW NEGATIVE -- CHECKED IN EMIT_CALL. 
LIB_START = [ 194, 234, 257, 278, -195, 251, 261,
    -212, -104, 255, 265, 245, -105, 259, 269, -182, 226, 263, -273, -144, 232,
    267, 277, -130, -250, 271, 280, -146, -254, 275, -244, -196, -258, 279, 115,
    -123, -262, 281, 58, 230, 266, -276, 197, 249, -270, -9, 143, -282, -274, 0]
if SANITY_CHECK and len(LIB_START) != HASHSIZE + 1:
    print('Bad LIB_START', file=sys.stderr)
    sys.exit(1)

LIB_LINK = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    -8, 0, 0, 0, 0, 0, -15, 0, -18, 0, 3, 0, 0, 0, 5, -6, 13, -14, -29, 0, 0, -24,
    0, -32, 0, 0, 0, 12, 0, 0, 0, 0, -35, 31, 0, 0, -11, -38, -4, 34, -44, 48, -7,
    -21, 0, -2, 1, -57, -22, -50, 26, -27, -55, 20, 62, -63, -43, -42, -40, 0, 68, -61,
    0, 0, 10, -70, 69, -56, -37, 73, 0, -39, -49, -74, 71, 0, -83, -33, 0, -28, 0, 0,
    -80, -51, -59, -84, 86, -53, 0, 30, -88, -45, -16, -91, -76, 60, 19, -72, 78, -47,
    -101, -77, 107, 0, 97, 85, 95, -110, 119, 109, 0, -41, -46, -117, -52, -36, -126,
    0, 64, 121, 131, -116, 102, 81, 108, -100, 98, -128, -96, -87, 89, 0, -54,
    135, 113, -140, -112, 75, 0, 66, -148, -118, 120, 92, -122, 99, 79, 65, 149,
    -25, -132, 114, -153, 93, -90, -136, 103, -142, 165, -151, 152, 17, 145, -137,
    138, 154, -139, 171, -163, -169, -141, 160, 150, -179, 172, -178, -164, 82,
    -129, -158, -175, 174, -189, 134, -147, 125, -176, -67, -170, 181, -166, 94, -191,
    -159, 183, 184, -168, 201, -200, 111, 208, -124, -210, -188, -127, 203, -190,
    -161, -173, -214, 199, -222, 193, -202, -23, -206, -187, 209, 0, 211, -106, -157,
    198, 205, 218, -219, -133, -180, -192, -167, 228, 229, -223, -216, -217, 236,
    -185, 186, -220, 224, -155, -156, 240, 242, 235, -227, 207, -248, 239, -215,
    -177, 252, 225, -233, 204, 256, -213, -237, 162, -260, -243, -221, 231, 264,
    -246, 247, 238, -268, -241, -272, 253]
if SANITY_CHECK and len(LIB_LINK) != LIB_NUM + 1:
    print('Bad LIB_LINK', file=sys.stderr)
    sys.exit(1)
    
LIB_REGS = [0,
    0x3F00, 0x3F00, 0x3F00, 0x3F00, 0x3F00, 0x3F00, 0x0300, 0x0300, 0x00FE, 0x003E,  #  1
    0x007E, 0x007E, 0x0000, 0x0000, 0x0000, 0x0000, 0x003E, 0x03FE, 0x03FE, 0x0330,  # 11
    0x0000, 0x3F20, 0x0300, 0x0300, 0x0300, 0x3F1C, 0x3F00, 0x0000, 0x0000, 0x0300,  # 21
    0x0300, 0x0300, 0x0300, 0x007C, 0x0000, 0x007C, 0x0320, 0x0320, 0x0320, 0x0320,  # 31
    0x0300, 0x3F00, 0x0320, 0x0320, 0x0320, 0x0320, 0x0000, 0x007C, 0x0320, 0x3F00,  # 41
    0x3F00, 0x0320, 0x0320, 0x0320, 0x0320, 0x0320, 0x0300, 0x3F00, 0x3F00, 0x3F00,  # 51
    0x3F00, 0x3F00, 0x3F00, 0x3F00, 0x0330, 0x3F00, 0x3F00, 0x0F00, 0x0330, 0x0300,  # 61
    0x3F00, 0x0334, 0x3F00, 0x0334, 0xFF10, 0x0300, 0x0334, 0x3F00, 0x0F00, 0x0F00,  # 71
    0x0330, 0x3F00, 0x3F00, 0x0020, 0x3F00, 0x3F00, 0x0000, 0x0334, 0x3F00, 0x3F00,  # 81
    0x3F00, 0x0330, 0x0330, 0x0330, 0x3F00, 0x0300, 0x0334, 0x0334, 0x3F10, 0x0300,  # 91
    0x0334, 0x3F00, 0x0F00, 0x0F00, 0x0334, 0x3F00, 0x0330, 0x0330, 0x0F00, 0x0330,  # 101
    0x0334, 0x0300, 0x0074, 0x0074, 0x00F4, 0x0300, 0x0074, 0x0020, 0x00F4, 0x0074,  # 111
    0x0000, 0x0300, 0x0074, 0x0074, 0x00F4, 0x0300, 0x0300, 0x00F4, 0x0020, 0x0020,  # 121
    0x00F4, 0x0074, 0x0000, 0x0330, 0x0330, 0x03FE, 0x0300, 0x3F00, 0x0000, 0x0000,  # 131
    0x0300, 0x0300, 0x03FA, 0x03FA, 0x0FFE, 0x03FE, 0x0FFE, 0x0FFE, 0x0FFE, 0x3F36,  # 141
    0x03FE, 0x0F36, 0x3F00, 0x3F00, 0x3F00, 0x3F00, 0x0374, 0x0314, 0x0374, 0x0314,  # 151
    0x3F00, 0x3F00, 0x3F00, 0x3F00, 0x0FF2, 0x0FF2, 0x3F00, 0x3F00, 0x3F00, 0x3F00,  # 161
    0x3FFE, 0x3FFE, 0x3FFE, 0x3FFE, 0x0300, 0x0300, 0x0300, 0x0300, 0x0300, 0x0300,  # 171
    0x0000, 0x0076, 0x3FFE, 0x0F5E, 0x3FFE, 0x0F1E, 0x03FE, 0x0300, 0x0300, 0x0300,  # 181
    0x0F00, 0x0F00, 0x0330, 0x3F1C, 0x3F00, 0x0300, 0x3F1C, 0x0FF2, 0x0332, 0x0300,  # 191
    0x3F00, 0x3F00, 0x0330, 0x3FFE, 0x3F3E, 0x3FFE, 0x0F3E, 0x33FE, 0x037E, 0x33FE,  # 201
    0x037E, 0x0300, 0x0300, 0x0300, 0x0300, 0x0300, 0x0300, 0x0300, 0x0300, 0x0300,  # 211
    0x0300, 0x0300, 0x0300, 0x0332, 0x03B2, 0x0332, 0x03B2, 0x0336, 0x03F6, 0x3F16,  # 221
    0x03F6, 0x0336, 0x03F6, 0x3F16, 0x03F6, 0x0336, 0x03F6, 0x3F16, 0x03F6, 0x0336,  # 231
    0x03F6, 0x0316, 0x03F6, 0x3F00, 0x3F00, 0x3F00, 0x3F00, 0x033E, 0x3F1E, 0x033E,  # 241
    0x3F1E, 0x033E, 0x031E, 0x033E, 0x3F1E, 0x0F36, 0x0F16, 0x0F36, 0x0F16, 0xFF36,  # 251
    0xFF16, 0x0F36, 0x0F16, 0x0F3E, 0x0F1C, 0x0F3E, 0x0F1C, 0x0336, 0x3F16, 0x0336,  # 261
    0x3F16, 0x033E, 0x033E, 0x033E, 0x033E, 0x3F00, 0x3F00, 0x3F00, 0x0F00, 0x3F1E,  # 271
    0x0F1E, 0x03FE]  # 281
if SANITY_CHECK and len(LIB_REGS) != LIB_NUM + 1:
    print('Bad LIB_REGS', file=sys.stderr)
    sys.exit(1)
    
LIB_CALLTYPE = [0,
    0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 3, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1,  #  1
    0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0,  # 35
    3, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 3, 3, 3, 0, 0, 1, 1, 1, 0, 1, 0,  # 69
    0, 0, 1, 0, 3, 3, 0, 3, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 3, 3, 1,  # 103
    0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0,  # 137
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 3, 1, 0, 0, 1, 1, 1, 0, 0, 0, 3, 1,  # 171
    1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,  # 205
    1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,  # 239
    1, 1, 1, 0, 0, 0, 0, 1, 1, 1]  # 273
if SANITY_CHECK and len(LIB_CALLTYPE) != LIB_NUM + 1:
    print('Bad LIB_CALLTYPE', file=sys.stderr)
    sys.exit(1)


def POW_OF_2(n):
    return 1 << n

      
EMIT_LDM_TABLE = [1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0,  # 10
    1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,  # 33
    0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  # 56
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,  # 79
    0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,  # 101
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1,  # 124
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1,  # 144
    1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1,  # 167
    0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,  # 191
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,  # 214
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,  # 237
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]  # 260
if SANITY_CHECK and len(EMIT_LDM_TABLE) != LIB_NUM + 1:
    print('Bad EMIT_LDM_TABLE', file=sys.stderr)
    sys.exit(1)
      
EMIT_LDM = TRUE
NEGMAX = 0x80000000
POSMAX = 0x7FFFFFFF
NULL_ADDR = 0
HALFMAX = 0x7FFF
HALFMIN = 0xFFFF8000
if not pfs:  # BFS/PASS INTERFACE 
    NUMSEQ = '0123456789'

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


def SYT_ADDR(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return h.SYM_TAB[n].SYM_ADDR
    h.SYM_TAB[n].SYM_ADDR = value


def SYT_XREF(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return extendSign16(h.SYM_TAB[n].SYM_XREF)
    h.SYM_TAB[n].SYM_XREF = value & 0xFFFF


def SYT_NEST(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return h.SYM_TAB[n].SYM_NEST
    h.SYM_TAB[n].SYM_NEST = value


def SYT_SCOPE(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return h.SYM_TAB[n].SYM_SCOPE
    h.SYM_TAB[n].SYM_SCOPE = value


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


def SYT_FLAGS2(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return h.SYM_TAB[n].SYM_FLAGS2
    h.SYM_TAB[n].SYM_FLAGS2 = value


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


def EXTENT(n, value=None):
    enlargeSYM_TAB(n)
    if value == None:
        return h.SYM_TAB[n].XTNT
    h.SYM_TAB[n].XTNT = value


def XREF(n, value=None):
    while len(h.CROSS_REF) <= n:
        h.CROSS_REF.append(h.cross_ref())
    if value == None:
        return h.CROSS_REF[n].CR_REF
    h.CROSS_REF[n].CR_REF = value


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


def LABEL_ARRAY(n, value=None):
    global STMTNUM
    while n >= len(STMTNUM):
        STMTNUM.append(stmtnum())
    if value == None:
        return STMTNUM[n].ARRAY_LABEL
    STMTNUM[n].ARRAY_LABEL = value

    
def LOCATION(n, value=None):
    global LAB_LOC
    while n >= len(LAB_LOC):
        LAB_LOC.append(lab_loc())
    if value == None:
        return LAB_LOC[n].LOCAT
    LAB_LOC[n].LOCAT = value

    
def LOCATION_STp(n, value=None):
    global LAB_LOC
    while n >= len(LAB_LOC):
        LAB_LOC.append(lab_loc())
    if value == None:
        return LAB_LOC[n].LOCAT_STp
    LAB_LOC[n].LOCAT_STp = value

    
def LOCATION_LINK(n, value=None):
    global LAB_LOC
    while n >= len(LAB_LOC):
        LAB_LOC.append(lab_loc())
    if value == None:
        return LAB_LOC[n].LINK_LOCATION
    LAB_LOC[n].LINK_LOCATION = value

    
def SYT_BASE(n, value=None):
    global P2SYMS
    while n >= len(P2SYMS):
        P2SYMS.append(p2syms())
    if value == None:
        return P2SYMS[n].SYM_BASE
    P2SYMS[n].SYM_BASE = value

    
def SYT_DISP(n, value=None):
    global P2SYMS
    while n >= len(P2SYMS):
        P2SYMS.append(p2syms())
    if value == None:
        return P2SYMS[n].SYM_DISP
    P2SYMS[n].SYM_DISP = value

    
def SYT_PARM(n, value=None):
    global P2SYMS
    while n >= len(P2SYMS):
        P2SYMS.append(p2syms())
    if value == None:
        return P2SYMS[n].SYM_PARM
    P2SYMS[n].SYM_PARM = value

    
def SYT_CONST(n, value=None):
    global P2SYMS
    while n >= len(P2SYMS):
        P2SYMS.append(p2syms())
    if value == None:
        return P2SYMS[n].SYM_CONST
    P2SYMS[n].SYM_CONST = value

    
def SYT_LEVEL(n, value=None):
    global P2SYMS
    while n >= len(P2SYMS):
        P2SYMS.append(p2syms())
    if value == None:
        return P2SYMS[n].SYM_LEVEL
    P2SYMS[n].SYM_LEVEL = value

    
def SYT_SORT(n, value=None):
    global DOSORT
    while len(DOSORT) <= n:
        DOSORT.append(dosort())
    if value == None:
        return DOSORT[n].SYM_SORT
    DOSORT[n].SYM_SORT = value

    
def OFF_PAGE_TAB(n, value=None):
    global PAGE_FIX
    while len(PAGE_FIX) <= n:
        PAGE_FIX.append(page_fix())
    if value == None:
        return PAGE_FIX[n].TAB_OFF_PAGE
    PAGE_FIX[n].TAB_OFF_PAGE = value

    
def OFF_PAGE_LINE(n, value=None):
    global PAGE_FIX
    while len(PAGE_FIX) <= n:
        PAGE_FIX.append(page_fix())
    if value == None:
        return PAGE_FIX[n].LINE_OFF_PAGE
    PAGE_FIX[n].LINE_OFF_PAGE = value

    
def DENSEADDR(n, value=None):
    global DNS
    while len(DNS) <= n:
        DNS.append(dns())
    if value == None:
        return DNS[n].DNSADDR
    DNS[n].DNSADDR = value

    
def DENSEVAL(n, value=None):
    global DNS
    while len(DNS) <= n:
        DNS.append(dns())
    if value == None:
        return DNS[n].DNSVAL
    DNS[n].DNSVAL = value

    
def DW(n, value=None):
    while len(h.FOR_DW) <= n:
        h.FOR_DW.append(h.for_dw())
    if value == None:
        return h.FOR_DW[n].CONST_DW
    h.FOR_DW[n].CONST_DW = value

    
def OPR(n, value=None):
    while len(h.FOR_ATOMS) <= n:
        h.FOR_ATOMS.append(h.for_atoms())
    if value == None:
        return h.FOR_ATOMS[n].CONST_ATOMS
    h.FOR_ATOMS[n].CONST_ATOMS = value
    

# MISCELLANEOUS DECLARATIONS 
LINEp = 0
CLOCK = [0] * (1 + 2)
SAVE_LOCCTR = 0
SAVE_CODE_LINE = 0
MAX_SEVERITY = 0
NEXTCTR = 0
ASNCTR = 0
LAST_FLOW_BLK = 0
LAST_FLOW_CTR = 0
BOOL_COUNT = 0
LAST_TAG = 0
STOPPERFLAG = 0
DECLMODE = 0
EXTRA_LISTING = 0
if not pfs:  # BFS/PASS INTERFACE; MAKE 'AB' AND 'L' INDEPENDENT 
    CODE_LISTING = 0
SELF_ALIGNING = 0
COMPACT_CODE = 0
SDL = 0
REGOPT = 0
SREF = 0
FIRST_INST = 0
ADDRS_ISSUED = 0
Z_LINKAGE = 0
OLD_LINKAGE = 0
NEW_INSTRUCTIONS = 0
GENERATING = 0
REMOTE_ADDRS = 0
BNOT_FLAG = 0
if not pfs:  # BFS/PASS INTERFACE; ADD CONSTANT PROTECTION 
    CURR_STORE_PROTECT = FALSE
    GENED_LIT_START = 0
THISPROGRAM = 'ESD_TABLE(PROGPOINT)'
PP = 0

# LABELS 
# DECLARE (SUBMONITOR,RESTART,SRCERR) LABEL;
# DECLARE UNIMPLEMENTED LABEL;
DESC = 'STRING'
HALMAT_OPCODE = 0
#------------- #D ------------------------------------------------
# VALUES RETURNED BY CSECT_TYPE ROUTINE 
STACKVAL = 0  # VALUE ON THE STACK 
STACKADDR = 1  # ADDRESS ON THE STACK 
INCREMpP = 2  # COMPOOL INCLUDED REMOTE 
COMPOOLpR = 3  # COMPOOL DECLARED REMOTE 
COMPOOLpP = 4  # COMPOOL DECLARED 
REMOTEpR = 5  # PROGRAM/PROC DECLARED REMOTE 
LOCALpD = 6  # PROGRAM/PROC DECLARED 
PDENTRYpE = 7  # PROCESS DIRECTORY ENTRY 
STRUCT_NAME32 = 8  # STRUCTURE WALK THRU 32BIT NAME
STRUCT_NAME16 = 9  # STRUCTURE WALK THRU 16BIT NAME
#------------- #DREG ---------------------------------------------
# VALUES USED IN REG_STAT ROUTINE IN RESTRICTION LOGIC 
LOADBASE = 0  # VIRTUAL BASE VALUE LOAD 
LOADNAME = 1  # NAME VARIABLE LOAD 
LOADPARM = 2  # FORMAL PASS-BY-REF PARAMETER LOAD 
LOADADDR = 3  # ADDRESS LOAD (LA) 
LOADLABEL = 4  # DO-CASE LABEL LOAD 
#------------- #DDSE ---------------------------------------------
DSESET = 0  # ESDS OF THE LDM      
DSECLR = 0  # CONSTANTS STORED HERE.
#------------- #DREG ---------------------------------------------
D_RTL_SETUP = 0  # TRUE WHEN LOADING REGISTERS
# BOOLEAN, IN PREPERATION FOR RTL CALL
D_R1_CHANGE = 0  # TRUE WHEN R1 LOADED WITH   
# BOOLEAN, SOME NEW BASE VALUE.       
D_R3_CHANGE = 0  # TRUE WHEN R3 LOADED WITH   
# BOOLEAN, SOME NEW BASE VALUE.       
# THE PREVIOUS VALUE OF D_RX_CHANGE IS KEPT IN NEXT-TO-LAST BIT 
# SO THAT IF A RESTORE OF RX IS TAKING PLACE BEFORE INSTRUCTION 
# THAT ALSO CHANGES RX, THAT INFORMATION WILL NOT BE LOST.      
#------------- #DMVH ---------------------------------------------
D_MVH_SOURCE = 0  # TRUE WHEN SETTING UP SOURCE
# BOOLEAN, #REG FOR MVH--NO REGISTER   
# RESTRICTION NEEDED FOR THIS
ATOMp_LIM = 1799
VAC_VAL = [0] * (1 + ATOMp_LIM)
OPR_VAL = [0] * (1 + ATOMp_LIM)
SAVE_STACK = [0] * (1 + STACK_SIZE)


def ADV_STMTp(n, value=None):
    if value == None:
        return h.ADVISE[n].STMTp
    h.ADVISE[n].STMTp = value


def ADV_ERRORp(n, value=None):
    if value == None:
        return h.ADVISE[n].ERRORp[:]
    h.ADVISE[n].ERRORp = value[:]


def INIT_VAL(n, value=None):
    while n >= len(h.INIT_TAB):
        h.INIT_TAB.append(h.init_tab())
    if value == None:
        return h.INIT_TAB[n].VALUE[:]
    h.INIT_TAB[n].VALUE = value[:]

