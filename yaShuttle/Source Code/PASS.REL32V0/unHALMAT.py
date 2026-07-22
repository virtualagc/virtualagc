#!/usr/bin/env python3
'''
License:    This program is declared by its author, Ron Burkey, to be
            in the Public Domain in the U.S., and can be used or
            modified in any way desired.
Filename:   unHALMAT.py
Purpose:    To parse a binary HALMAT file output by HAL_S_FC.py.
History:    2023-11-13 RSB  Began.
            2026-04-10 RSB  Some cleanups.
            2026-07-22 RSB  Fixed a misleading aspect of how a LIT
                             operand's run of coalesced initial values
                             was reported (see dumbPrintOperands below):
                             previously only the *first* literal of a
                             run was shown, with no indication that the
                             operand's own TAG1 field (visible in the
                             raw byte dump, but never interpreted) means
                             "this one instruction actually represents
                             TAG1 *consecutive* literals, not one" for
                             the class-8 xINT family's OFFSET-addressed
                             form -- the compiler's ICQ_OUTPUT coalescing
                             of a run of initial values into a single
                             instruction (see yaHALMAT2's reengineered-
                             documentation/class-8/SINT.md and TINT.md
                             for the full mechanism, empirically
                             confirmed against real compiled HALMAT).
                             Reading the old report's single truncated
                             literal as "one instruction, one value" is
                             a natural but incorrect inference, and that
                             misreading contributed to a real yaHALMAT2
                             interpreter bug: it silently dropped every
                             literal after the first in such a run (see
                             source-documentation/BAD_INITIAL.md in the
                             yaHALMAT2 project for the bug report, now
                             fixed). Also added an annotation for OFFSET
                             operands, which were previously unannotated
                             entirely. (Fixes actually made by Claude
                             Sonnet 5.)

It is unclear to the extent that the goal of this program can be
achieved.  Only 3 sources of documentation about the inner structure of
HALMAT are known at this writing:
    REF1: "HALMAT - An Intermediate Language of the First HAL Compiler",
        (1971).  Nominally complete, but is preliminary and contains
        obsoleted ("wrong") data.
    REF2: "HAL/S-360 Compiler System Specification" (1977).  Nominally
        correct and up-to-date, but less than 20% complete due to
        retaining only changed page vs the previous revision.
    REF3: HAL/S-FC compiler source code.  Generates and parses HALMAT
        code, but almost completely without any semantics.
In other words, there is no known surviving satisfactory documentation
of HALMAT.  This parsing program will be taken as far as I can feasibly
take it under the circumstances.
'''

import sys
import os
from unLitfile import getLiteralsFromFile

helpMsg = '''
Usage:
     unHALMAT.py [OPTIONS] HALMAT_FILE

The available OPTIONs are:
    --help          Displays this message.
    --listing2=F    F is the name of a listing file as produced by the HAL/S
                    compiler (HALSFC) when the HALMAT file was
                    generated, and if present, is used to display HAL/S source
                    code corresponding to HALMAT SMRK instructions.  It is
                    acceptable for F to be either the PASS 1 report or the
                    LISTING2 report.
    --litfile=F     Specify a literal file for displaying values of literals.
                    Requires --memory (see below).
    --memory=F      Specify a memory file for use with --litfile (see above).
                    The two files for --litfile and --memory are the same as
                    for the unLitfile.py program.
    --common=F      Sepecify a COMMON-memory file, in order to print info about
                    symbols in the symbol table.
    --colorize      Colorize all supplemental information not derived directly
                    from the HALMAT file being analyzed.  (I.e., all information
                    taken from --listing2, --litfile, --memory, or --common.)

Note that if HALMAT_FILE is one of "halmat.bin", "optmat.bin", or "FILE1.bin",
then defaults appropriate for the file-naming conventions of the HAL/S compiler
(HALSFC or HAL_S_FC.py) will be supplied for any missing --listing2, --litfile,
--memory, or --common options.  If HALMAT_FILE is none of these, then there are
no supplied defaults.
'''

# Create some sensible defaults.
argvSkeleton = []
for parm in sys.argv[1:]:
    argvSkeleton.append(parm.split("=")[0])
if "halmat.bin" in argvSkeleton:
    if "--listing2" not in argvSkeleton:
        sys.argv.append("--listing2=pass1.rpt")
    if "--litfile" not in argvSkeleton:
        sys.argv.append("--litfile=litfile0.bin")
    if "--memory" not in argvSkeleton:
        sys.argv.append("--memory=COMMON0.out.bin.gz")
    if "--common" not in argvSkeleton:
        sys.argv.append("--common=COMMON0.out")
elif "optmat.bin" in argvSkeleton:
    if "--listing2" not in argvSkeleton:
        sys.argv.append("--listing2=pass1.rpt")
    if "--litfile" not in argvSkeleton:
        sys.argv.append("--litfile=litfile2.bin")
    if "--memory" not in argvSkeleton:
        sys.argv.append("--memory=COMMON2.out.bin.gz")
    if "--common" not in argvSkeleton:
        sys.argv.append("--common=COMMON3.out")
elif "FILE1.bin" in argvSkeleton:
    if "--listing2" not in argvSkeleton:
        sys.argv.append("--listing2=pass1.rpt")
    if "--litfile" not in argvSkeleton:
        sys.argv.append("--litfile=FILE2.bin")
    if "--memory" not in argvSkeleton:
        sys.argv.append("--memory=LIT_CHAR.bin")
    # HAL_S_FC.py produces no file appropriate for --common.

colorize = ""
uncolorize = ""
listing2 = {}
data = None
litfile = None
memory = None
symbolTable = []
for parm in sys.argv[1:]:
    if parm == "--colorize":
        colorize = "\033[31m"
        uncolorize = "\033[30m"
    elif parm.startswith("--litfile="):
        litfile = parm[10:]
    elif parm.startswith("--memory="):
        memory = parm[9:]
    elif parm.startswith("--listing2="):
        n = parm[11:]
        f = open(n, "r")
        for line in f:
            try:
                if line[10] == '|' and line[91] == '|':
                    first = 1
                    numLeft = 1
                    numRight = 8
                    final = 92
                elif line[13] == '|' and line[115] == '|':
                    first = 0
                    numLeft = 6
                    numRight = 11
                    final = 116
                else:
                    continue
                lineNumber = int(line[numLeft:numRight].lstrip())
                line = line[first:final]
                if lineNumber in listing2:
                    listing2[lineNumber].append(line)
                else:
                    listing2[lineNumber] = [line]
            except:
                continue
        f.close()
    elif parm.startswith("--common="):
        n = parm[9:]
        f = open(n, "r")
        inSymtab = False
        for line in f:
            if not inSymtab:
                if not line.startswith("/"):
                    continue
                inSymtab = True
            fields = line.rstrip().split("\t")
            if len(fields) < 5:
                break
            if fields[0] == "/":
                if fields[1] != "SYMuTAB" or fields[3] != "BASED":
                    break
                i = int(fields[2])
                if i != len(symbolTable):
                    break
                symbolTable.append({})
            elif fields[0] == ".":
                if fields[1] == "SYM_NAME":
                    symbolTable[-1][fields[1]] = fields[4]
                elif fields[1] == "SYM_FLAGS":
                    symbolTable[-1][fields[1]] = int(fields[4], 16)
                elif fields[1] == "SYM_TYPE":
                    symbolTable[-1][fields[1]] = int(fields[4], 16)
            else:
                break
        f.close()
    elif parm == "--help":
        print(helpMsg)
        sys.exit(0)
    elif parm.startswith("-"):
        print("Unrecognized parameter", parm)
        sys.exit(1)
    else:
        try:
            fileName = parm
            f = open(fileName, "rb")
            data = bytearray(f.read())
            f.close()
            fileLength = len(data)
        except:
            print("Cannot read the specified HALMAT file.")
            os._exit(1)
        print("%d bytes read from %s" % (fileLength, fileName))
if data == None:
    print("No HALMAT filename was specified")
    sys.exit(1)

literals = []
if litfile != None and memory != None:
    literals = getLiteralsFromFile(litfile, memory)

# Formats a single literal-table entry for display, by index.  Factored
# out of dumbPrintOperands() so it can be called once per literal in a
# multi-literal LIT-operand run (see dumbPrintOperands' LIT case below),
# not just for a single literal.
def formatLiteral(index):
    if index >= len(literals):
        return ("?", "(literal index %d out of range)" % index)
    literal = literals[index]
    type = literal["type"]
    value = literal["value"]
    if type == 0:
        return ("CHARACTER", "'" + value + "'")
    elif type == 1:
        return ("FIXED", value)
    elif type == 2:
        return ("BIT", "%08X" % value)
    else:
        return (f"{type}", "%08X,%08X" % (0xFFFFFFFF&(value>>32)|(0xFFFFFFFF&value)))

if False:
    qMnemonicsA = ["  0", "SYT", "GLI", "VAC", "XPT", "LIT", "IMD",
                  "AST", "CSZ", "ASZ", "OFF", " 11", " 12", " 13", " 14", " 15"]
    qMnemonicsB = ["  0", "SYL", "INL", "VAC", "XPT", "LIT", "IMD",
                  "AST", "CSZ", "ASZ", "OFF", " 11", " 12", " 13", " 14", " 15"]
else:
    qMnemonics = ["  0", "SYT", "INL", "VAC", "XPT", "LIT", "IMD",
                  "AST", "CSZ", "ASZ", "OFF", " 11", " 12", " 13", " 14", " 15"]
# REF2 has a table of the following, beginning on p. A-103, but it's
# truncated due to page omissions.  PASS1.PROCS/##DRIVER has a bigger
# list, perhaps complete.
operatorMnemonics = {
    0x00: "NOP",
    0x01: "EXTN",
    0x02: "XREC",
    0x03: "IMRK",
    0x04: "SMRK",
    0x05: "PXRC",
    0x07: "IFHD",
    0x08: "LBL",
    0x09: "BRA",
    0x0A: "FBRA",
    0x0B: "DCAS",
    0x0C: "ECAS",
    0x0D: "CLBL",
    0x0E: "DTST",
    0x0F: "ETST",
    0x10: "DFOR",
    0x11: "EFOR",
    0x12: "CFOR",
    0x13: "DSMP",
    0x14: "ESMP",
    0x15: "AFOR",
    0x16: "CTST",
    0x17: "ADLP",
    0x18: "DLPE",
    0x19: "DSUB",
    0x1A: "IDLP",
    0x1B: "TSUB",
    0x1D: "PCAL",
    0x1E: "FCAL",
    0x1F: "READ",
    0x20: "RDAL",
    0x21: "WRIT",
    0x22: "FILE",
    0x25: "XXST",
    0x26: "XXND",
    0x27: "XXAR",
    0x2A: "TDEF",
    0x2B: "MDEF",
    0x2C: "FDEF",
    0x2D: "PDEF",
    0x2E: "UDEF",
    0x2F: "CDEF",
    0x30: "CLOS",
    0x31: "EDCL",
    0x32: "RTRN",
    0x33: "TDCL",
    0x34: "WAIT",
    0x35: "SGNL",
    0x36: "CANC",
    0x37: "TERM",
    0x38: "PRIO",
    0x39: "SCHD",
    0x3C: "ERON",
    0x3D: "ERSE",
    0x40: "MSHP",
    0x41: "VSHP",
    0x42: "SSHP",
    0x43: "ISHP",
    0x45: "SFST",
    0x46: "SFND",
    0x47: "SFAR",
    0x4A: "BFNC",
    0x4B: "LFNC",
    0x4D: "TNEQ",
    0x4E: "TEQU",
    0x4F: "TASN",
    0x51: "IDEF",
    0x52: "ICLS",
    0x55: "NNEQ",
    0x56: "NEQU",
    0x57: "NASN",
    0x59: "PMHD",
    0x5A: "PMAR",
    0x5B: "PMIN",
    0x101: "BASN",
    0x102: "BAND",
    0x103: "BOR",
    0x104: "BNOT",
    0x105: "BCAT",
    0x121: "BTOB",
    0x122: "BTOQ",
    0x141: "CTOB",
    0x142: "CTOQ",
    0x1A1: "STOB",
    0x1A2: "STOQ",
    0x1C1: "ITOB",
    0x1C2: "ITOQ",
    0x201: "CASN",
    0x202: "CCAT",
    0x221: "BTOC",
    0x241: "CTOC",
    0x2A1: "STOC",
    0x2C1: "ITOC",
    0x301: "MASN",
    0x329: "MTRA",
    0x341: "MTOM",
    0x344: "MNEG",
    0x362: "MADD",
    0x363: "MSUB",
    0x368: "MMPR",
    0x387: "VVPR",
    0x3A5: "MSPR",
    0x3A6: "MSDV",
    0x3CA: "MINV",
    0x401: "VASN",
    0x441: "VTOV",
    0x444: "VNEG",
    0x46C: "MVPR",
    0x46D: "VMPR",
    0x482: "VADD",
    0x483: "VSUB",
    0x48B: "VCRS",
    0x4A5: "VSPR",
    0x4A6: "VSDV",
    0x501: "SASN",
    0x521: "BTOS",
    0x541: "CTOS",
    0x571: "SIEX",
    0x572: "SPEX",
    0x58E: "VDOT",
    0x5A1: "STOS",
    0x5AB: "SADD",
    0x5AC: "SSUB",
    0x5AD: "SSPR",
    0x5AE: "SSDV",
    0x5AF: "SEXP",
    0x5B0: "SNEG",
    0x5C1: "ITOS",
    0x601: "IASN",
    0x621: "BTOI",
    0x641: "CTOI",
    0x6A1: "STOI",
    0x6C1: "ITOI",
    0x6CB: "IADD",
    0x6CD: "IIPR",
    0x6D2: "IPEX",
    0x6CC: "ISUB",
    0x6D0: "INEG",
    0x720: "BTRU",
    0x725: "BNEQ",
    0x726: "BEQU",
    0x745: "CNEQ",
    0x746: "CEQU",
    0x747: "CNGT",
    0x748: "CGT",
    0x749: "CNLT",
    0x74A: "CLT",
    0x765: "MNEQ",
    0x766: "MEQU",
    0x785: "VNEQ",
    0x786: "VEQU",
    0x7A5: "SNEQ",
    0x7A6: "SEQU",
    0x7A7: "SNGT",
    0x7A8: "SGT",
    0x7A9: "SNLT",
    0x7AA: "SLT",
    0x7C5: "INEQ",
    0x7C6: "IEQU",
    0x7C7: "INGT",
    0x7C8: "IGT",
    0x7C9: "INLT",
    0x7CA: "ILT",
    0x7E2: "CAND",
    0x7E3: "COR",
    0x7E4: "CNOT",
    0x801: "STRI",
    0x802: "SLRI",
    0x803: "ELRI",
    0x804: "ETRI",
    0x821: "BINT",
    0x841: "CINT",
    0x861: "MINT",
    0x881: "VINT",
    0x8A1: "SINT",
    0x8C1: "IINT",
    0x8E1: "NINT",
    0x8E2: "TINT",
    0x8E3: "EINT"
    }

operatorDescriptions = {
    "NOP": "No operation",
    "EXTN": "Structure extended pointer",
    "XREC": "End of HALMAT block",
    "IMRK": "Inline function statement marker",
    "SMRK": "HAL/S statement marker",
    "PXRC": "Start of HALMAT block",
    "IFHD": "Start of IF-statement",
    "LBL": "Label definition",
    "BRA": "Unconditional branch",
    "FBRA": "Branch on false",
    "DCAS": "Start of DO CASE block",
    "ECAS": "End of DO CASE",
    "CLBL": "Branch to end of DO CASE",
    "DTST": "Start of DO WHILE/UNTIL block",
    "ETST": "End of DO WHILE/UNTIL block",
    "DFOR": "Start of DO FOR block",
    "EFOR": "End of DO FOR block",
    "CFOR": "WHILE/FOR clause for DO FOR",
    "DSMP": "Start of bare DO block",
    "ESMP": "End of bare DO block",
    "AFOR": "Next FOR iteration or exit",
    "CTST": "Next WHILE/UNTIL iteration or exit",
    "ADLP": "Start of arrayed DO-loop",
    "DLPE": "End of arrayed DO-loop",
    "DSUB": "Regular subscript specifier",
    "IDLP": "Start of indexed DO-loop",
    "TSUB": "Subscript for # operator",
    "PCAL": "Call PROCEDURE",
    "FCAL": "Call FUNCTION",
    "READ": "READ statement",
    "RDAL": "READALL statement",
    "WRIT": "WRITE statement",
    "FILE": "Random-access FILE operation",
    "XXST": "Start of argument list",
    "XXND": "End of argument list",
    "XXAR": "Argument",
    "TDEF": "Start of TASK definition",
    "MDEF": "Start of PROGRAM definition",
    "FDEF": "Start of FUNCTION definition",
    "PDEF": "Start of PROCEDURE definition",
    "UDEF": "Start of UPDATE definition",
    "CDEF": "Start of COMPOOL definition",
    "CLOSE": "End of PROGRAM/PROCEDURE/... definition",
    "EDCL": "End of DECLAREs",
    "RTRN": "RETURN statement",
    "TDCL": "TEMPORARY DECLARE",
    "WAIT": "WAIT statement",
    "SGNL": "SIGNAL statement",
    "CANC": "CANCEL statement",
    "TERM": "TERMINATE statement",
    "PRIO": "PRIORITY statement",
    "SCHD": "SCHEDULE statement",
    "ERON": "ON ERROR statement",
    "ERSE": "SEND ERROR statement",
    "MSHP": "MATRIX shaping function",
    "VSHP": "VECTOR shaping function",
    "SSHP": "SCALAR shaping function",
    "ISHP": "INTEGER shaping function",
    "SFST": "Start of subscript range",
    "SFND": "End of subscript range",
    "SFAR": "Subscript range",
    "BFNC": "Built-in function call",
    "LFNC": "Library function call",
    "TNEQ": "Test TASK/EVENT NAME not equal",
    "TEQU": "Test TASK/EVENT NAME equal",
    "TASN": "TASK/EVENT NAME assignment",
    "IDEF": "Start of inline function definition",
    "ICLS": "End of inline function definition",
    "NNEQ": "Test NAME not equal",
    "NEQU": "Test NAME equal",
    "NASM": "NAME assignment",
    "PMHD": "Start of percent macro",
    "PMAR": "Percent macro argument",
    "PMIN": "Percent macro invocation",
    "BASN": "BIT assignment",
    "BAND": "Bitwise AND",
    "BOR": "Bitwise OR",
    "BNOT": "Bitwise complement",
    "BCAT": "BIT concatenation",
    "BTOB": "BIT-to-BIT conversion",
    "BTOQ": "Qualified BIT-to-BIT conversion",
    "CTOB": "CHARACTER-to-BIT conversion",
    "CTOQ": "Qualified CHARACTER-to_BIT conversion",
    "STOB": "SCALAR-to-BIT conversion",
    "STOQ": "Qualified SCALAR-to-BIT conversion",
    "ITOB": "INTEGER-to-BIT conversion",
    "ITOQ": "Qualified INTEGER-to-BIT conversion",
    "CASN": "CHARACTER assignment",
    "CCAT": "CHARACTER concatenation",
    "BTOC": "BIT-to-CHARACTER conversion",
    "CTOC": "CHARACTER-to-CHARACTER conversion",
    "STOC": "SCALAR-to-CHARACTER conversion",
    "ITOC": "INTEGER-to-CHARACTER conversion",
    "MASN": "MATRIX assignment",
    "MTRA": "MATRIX transpose",
    "MTOM": "MATRIX-to-MATRIX conversion",
    "MNEG": "MATRIX negation",
    "MADD": "MATRIX addition",
    "MSUB": "MATRIX subtraction",
    "MMPR": "MATRIX multiplication",
    "MDET": "MATRIX determinant",
    "MIDN": "MATRIX identity",
    "VVPR": "VECTOR outer product",
    "MSPR": "Multiply MATRIX by SCALAR",
    "MSDV": "Divide MATRIX by SCALAR",
    "MINV": "MATRIX inverse",
    "VASN": "VECTOR assignment",
    "VTOV": "VECTOR-to-VECTOR conversion",
    "VNEG": "VECTOR negation",
    "MVPR": "MATRIX VECTOR product",
    "VMPR": "VECTOR MATRIX product",
    "VADD": "VECTOR addition",
    "VSUB": "VECTOR subtraction",
    "VCRS": "VECTOR cross product",
    "VSPR": "Multiply VECTOR by SCALAR",
    "SASN": "SCALAR assignment",
    "BTOS": "BIT to SCALAR conversion",
    "CTOS": "CHARACTER to SCALAR conversion",
    "SIEX": "Raise SCALAR to INTEGER power",
    "SPEX": "Raise SCALAR to SCALAR power",
    "VDOT": "VECTOR dot product",
    "STOS": "SCALAR-to-SCALAR conversion",
    "SADD": "SCALAR addition",
    "SSUB": "SCALAR subtraction",
    "SSPR": "SCALAR multiplication",
    "SSDV": "SCALAR division",
    "SEXP": "SCALAR exponentiation (?)",
    "SNEG": "SCALAR negation",
    "ITOS": "INTEGER-to-SCALAR conversion",
    "IASN": "INTEGER assignment",
    "BTOI": "BIT-to-INTEGER conversion",
    "CTOI": "CHARACTER-to-INTEGER conversion",
    "STOI": "SCALAR-to-INTEGER conversion",
    "ITOI": "INTEGER-to-INTEGER conversion",
    "IADD": "INTEGER addition",
    "ISUB": "INTEGER subtraction",
    "IIPR": "INTEGER multiplication",
    "INEG": "INTEGER negation",
    "IPEX": "Raise INTEGER to INTEGER power",
    "BTRU": "Test BIT true",
    "BNEQ": "Test BIT not equal",
    "BEQU": "Test BIT equal",
    "CNEQ": "Test CHARACTER not equal",
    "CEQU": "Test CHARACTER equal",
    "CNGT": "Test CHARACTER not greater than",
    "CGT": "Test CHARACTER greater than",
    "CNLT": "Test CHARACTER not less than",
    "CLT": "Test CHARACTER less than",
    "MNEQ": "Test MATRIX not equal",
    "MEQU": "Test MATRIX equal",
    "VNEQ": "Test VECTOR not equal",
    "VEQU": "Test VECTOR equal",
    "SNEQ": "Test SCALAR not equal",
    "SEQU": "Test SCALAR equal",
    "SNGT": "Test SCALAR not greater than",
    "SGT": "Test SCALAR greater than",
    "SNLT": "Test SCALAR not less than",
    "SLT": "Test SCALAR less than",
    "INEQ": "Test INTEGER not equal",
    "IEQU": "Test INTEGER equal",
    "INGT": "Test INTEGER not greater than",
    "IGT": "Test INTEGER greater than",
    "INLT": "Test INTEGER not less than",
    "ILT": "Test INTEGER less than",
    "CAND": "Logical AND",
    "COR": "Logical OR",
    "CNOT": "Logical NOT",
    "STRI": "Start of repeated INITIAL list",
    "SLRI": "Start of literal repeated INITIAL list",
    "ELRI": "End of literal repeated INITIAL list",
    "ETRI": "End of repeated INITIAL list",
    "BINT": "BIT INITIAL value",
    "CINT": "CHARACTER INITIAL value",
    "MINT": "MATRIX INITIAL value",
    "VINT": "VECTOR INITIAL value",
    "SINT": "SCALAR INITIAL value",
    "IINT": "INTEGER INITIAL value",
    "NINT": "NAME INITIAL value",
    "TINT": "STRUCTURE INITIAL value",
    "EINT": "End of INITIAL"
    }

bfncTypes = ["(unused)", "ABS", "COS", "DET", "DIV", "EXP", "LOG", "MAX",
             "MIN", "MOD", "ODD", "SHL", "SHR", "SIN", "SUM", "TAN", "XOR",
             "COSH", "DATE", "PRIO", "PROD", "SIGN", "SINH", "SIZE", "SQRT",
             "TANH", "TRIM", "UNIT", "ABVAL", "FLOOR", "INDEX", "LJUST",
             "RJUST", "ROUND", "TRACE", "ARCCOS", "ARCSIN", "ARCTAN", "ERRGRP",
             "ERRNUM", "LENGTH", "MIDVAL", "RANDOM", "SIGNUM", "ARCCOSH",
             "ARCSINH", "ARCTANH", "ARCTAN2", "CEILING", "INVERSE", "NEXTIME",
             "RANDOMG", "RUNTIME", "TRUNCATE", "CLOCKTIME", "REMAINDER",
             "TRANSPOSE"]

dataTypes = {
    0x01: "BIT",
    0x02: "CHARACTER",
    0x03: "MATRIX",
    0x04: "VECTOR",
    0x05: "SCALAR",
    0x06: "INTEGER",
    0x08: "IORS",
    0x09: "EVENT",
    0x0A: "STRUCTURE",
    0x0B: "ANY",
    0x3E: "TEMPLATE NAME",
    0x42: "STATEMENT LABEL",
    0x43: "UNSPEC LABEL",
    0x45: "IND CALL LABEL",
    0x46: "CALLED LABEL",
    0x47: "PROCEDURE LABEL",
    0x48: "TASK LABEL",
    0x49: "PROGRAM LABEL",
    0x4A: "COMPOOL LABEL",
    0x4B: "EQUATE LABEL"
    }

symbolFlags = {
    0x00800000: "SINGLE",
    0x00400000: "DOUBLE",
    0x08000000: "TEMPORARY",
    0x04000000: "RIGID",
    0x00000004: "DENSE",
    0x00000008: "ALIGNED",
    0x00000020: "ASSIGN",
    0x00000400: "INPUT",
    0x00000100: "AUTOMATIC",
    0x00000200: "STATIC",
    0x00000800: "INITIAL",
    0x00001000: "CONSTANT",
    0x00010000: "ACCESS",
    0x00000002: "REENTRANT",
    0x00080000: "EXCLUSIVE",
    0x00100000: "EXTERNAL",
    0x00000080: "REMOTE",
    0x02000000: "INCLUDED_REMOTE"
    }

# According to REF1, the HALMAT file is partitioned into 7200-byte PAGEs.
# This, unfortunately, is almost the last information in REF1 which is
# useful; in fact, REF2 refers to these pages as RECORDs instead.  From
# REF2, it further appears that each RECORD contains up to 1800
# PARAGRAPHs.  Each PARAGRAPH consists of some number of OPERATOR and
# OPERAND WORDS (each 32-bits in size).  PARAGRAPHs therefore have sizes
# that are multiples of 4 bytes, but since 7200 bytes will not
# necessarily hold an integral number of PARAGRAPHs, there may be
# some unused multiple of 4 bytes at the end of a RECORD.  These unused
# words, in my observation, are all 00.
if fileLength % 7200 != 0:
    print("File length is not a multiple of 7200")
    sys.exit(1)
numRecords = fileLength // 7200

# The class-8 static-initialization opcodes (the "xINT family": SINT/
# BINT/CINT/IINT/TINT/NINT -- see yaHALMAT2's reengineered-documentation/
# class-8/SINT.md and TINT.md, and its own source code's OP_TINT comment
# citing PASS1.PROCS/ICQCHECK.xpl's ICQ_CHECK_TYPE dispatch, which is what
# ties this whole family together as one mechanism). IMPORTANT: TAG1 is
# *not* uniformly a run-length across every opcode that has a LIT operand
# -- e.g. WRIT/XXAR's own LIT operand uses TAG1 for a completely different
# purpose (a HAL/S type-class tag, confirmed against yaHALMAT2's own
# interp.c: `ins->operands[0].tag1 == 6` there means INTEGER, nothing to
# do with a run length). Applying the run-length reading everywhere would
# just trade one misleading report for a different one. The run-length
# interpretation below is therefore gated on both (a) the parent opcode
# being one of these, *and* (b) this instruction's own first operand
# being OFFSET-qualified -- exactly the shape confirmed (empirically,
# against real compiled HALMAT) to carry it; every other LIT operand,
# including this same family's own direct-symbol-table form, is reported
# exactly as before.
xIntFamily = ("SINT", "BINT", "CINT", "IINT", "TINT", "NINT")

def dumbPrintOperands(operands, operandValues, halmatNumber, parentMnemonic):
    isOffsetAddressedInitRun = (parentMnemonic in xIntFamily and len(operands) > 0
                                 and qMnemonics[operands[0][2]] == "OFF")
    for i in range(len(operands)):
        operand = operands[i]
        operandValue = operandValues[i]
        operandMnemonic = ""
        halmatNumber += 1
        #print(f"  HALMAT #{halmatNumber}\t  | 0x{'%08X' % operandValue}, ", end = "")
        print(f"  HALMAT #{halmatNumber}\t  | ", end = "")
        for i in range(len(operand)):
            o = operand[i]
            if i == 0:
                print("%03X " % o, end="")
            elif i == 2:
                operandMnemonic = qMnemonics[o]
                print("%02X(%s) " % (o, operandMnemonic), end = "")
            else:
                print("%02X " % o, end = "")
        if operandMnemonic == "  0":
            if parentMnemonic == "PXRC":
                print(f"  (Matching XREC is at HALMAT #{operand[0]})", end="")
            elif parentMnemonic == "SMRK":
                print(f"  (HAL/S statement #{operand[0]})", end="")
        elif operandMnemonic == "LIT" and operand[0] < len(literals) and isOffsetAddressedInitRun:
            # operand[1] is the operand word's TAG1 field, here confirmed
            # (see isOffsetAddressedInitRun above) to be a *run length*:
            # this one instruction represents TAG1 *consecutive*
            # literal-table entries starting at operand[0], not just
            # operand[0] alone -- the compiler's ICQ_OUTPUT coalescing of
            # a run of initial values into a single instruction. The run
            # length is always stated explicitly below (never silently
            # omitted, even when it's 1), and every literal in a
            # multi-literal run is listed, not just the first -- see this
            # file's header comment for why that distinction matters.
            runLength = operand[1] if operand[1] > 0 else 1
            if runLength == 1:
                typeName, valueStr = formatLiteral(operand[0])
                print(f"  {colorize}(Literal #{operand[0]}, run-length 1: Type {typeName}, {valueStr}){uncolorize}", end="")
            else:
                print(f"  {colorize}(Literals #{operand[0]}-#{operand[0]+runLength-1}, "
                      f"run-length {runLength} -- TAG1={operand[1]} CONSECUTIVE LITERALS "
                      f"CONSUMED BY THIS ONE INSTRUCTION:{uncolorize}")
                for k in range(runLength):
                    typeName, valueStr = formatLiteral(operand[0] + k)
                    print(f"  {colorize}      #{operand[0]+k}: Type {typeName}, {valueStr}{uncolorize}")
                print(f"  {colorize}  ){uncolorize}", end="")
        elif operandMnemonic == "LIT" and operand[0] < len(literals):
            # Not the confirmed run-length shape (see above) -- reported
            # as a single literal, no run-length claim made one way or
            # the other.
            typeName, valueStr = formatLiteral(operand[0])
            print(f"  {colorize}(Literal #{operand[0]}: Type {typeName}, {valueStr}){uncolorize}", end="")
        elif operandMnemonic == "SYT" and operand[0] < len(symbolTable):
            symbol = symbolTable[operand[0]]
            name = symbol["SYM_NAME"].strip("'")
            dataType = symbol["SYM_TYPE"]
            flags = symbol["SYM_FLAGS"]
            flagString = dataTypes[dataType]
            for flag in symbolFlags:
                if flag == (flag & flags):
                    flags = flags & ~flag
                    flagString += " " + symbolFlags[flag]
            if False and flags != 0:
                if flagString == "":
                    flagString = "0x%08X" % flags
                else:
                    flagString += " 0x%08X" % flags
            print(f"  {colorize}(Symbol #{operand[0]}: {name}, {flagString})", end="")
        elif operandMnemonic == "VAC":
            print(f"  (Result from operation at HALMAT #{operand[0]})", end="")
        elif operandMnemonic == "INL":
            print(f"  (Bookkeeping label #{operand[0]})", end="")
        elif operandMnemonic == "IMD":
            print(f"  (Immediate integer data {operand[0]} 0x{'%X'%operand[0]})", end="")
        elif operandMnemonic == "OFF":
            # Not annotated at all previously. Every use of OFF that
            # yaHALMAT2's own interp.c implements is in the class-8
            # STRI-bracketed static-initialization family (SINT/BINT/
            # CINT/TINT/etc.), where it's the absolute/cumulative element
            # or terminal index -- within the container most recently
            # named by STRI -- that this instruction's (run of) value(s)
            # initialize, starting here (class-8/STRI.md, class-8/
            # SINT.md). That's yaHALMAT2's own implementation coverage,
            # not a claim that no other opcode could ever use OFF for
            # something else -- if this annotation looks wrong for some
            # other opcode, trust the raw byte dump above it instead.
            print(f"  (OFFSET {operand[0]}: target element/terminal index, "
                  f"within the container most recently named by STRI)", end="")
        print()

# I don't know if this works for all operands, but ...
operandRawValue = None
def parseOperand(operand):
    global operandRawValue
    operandRawValue = (operand[0] << 24) | (operand[1] << 16) | (operand[2] << 8) + operand[3]
    field1 = (operand[0] << 8) | operand[1]
    field2 = operand[2];
    field3 = (operand[3] >> 4) & 0xF
    field4 = (operand[3] >> 3) & 0x1
    field5 = (operand[3] >> 2) & 0x1
    field6 = (operand[3] >> 1) & 0x1
    field7 = operand[3] & 1
    field45 = (operand[3] >> 2) & 0x3
    field46 = (operand[3] >> 1) & 0x7
    return field1, field2, field3, field4, field5, field6, field7, \
           field45, field46

# Process by looping on RECORDS:
for recordNum in range(numRecords):
    print("RECORD %d" % recordNum)
    recordOffset = recordNum * 7200
    # Process RECORD by looping on 32-bit words:
    wordNumber = 0
    while wordNumber < 1800:
        wordOffset = recordOffset + wordNumber * 4
        word = data[wordOffset : wordOffset + 4]
        originalWordNumber = wordNumber
        wordNumber += 1
        field1 = word[0]
        numberOfOperands = word[1]
        w2 = word[2]
        w3 = word[3]
        operatorType = (w2 << 4) | ((w3 >> 4) & 0xFF)
        field4 = (w3 >> 1) & 0x07
        field5 = w3 & 1
        operands = []
        operandValues = []
        for i in range(numberOfOperands):
            wordOffset += 4
            operands.append(parseOperand(data[wordOffset : wordOffset + 4]))
            operandValues.append(operandRawValue)
            wordNumber += 1
        mnemonic = "?"
        if operatorType in operatorMnemonics:
            mnemonic = operatorMnemonics[operatorType]
        # Interpret these by operator type.
        #print("  %4d (%02X%02X%02X%02X): " % (originalWordNumber, field1,
        #                                      numberOfOperands, w2, w3), end = "")
        description = ""
        if mnemonic in operatorDescriptions:
            description = ", " + operatorDescriptions[mnemonic]
        print(f"  HALMAT #%d (0x%03X{description}): " % (originalWordNumber,
                                                   operatorType), end = "")
        if mnemonic == "NOP":
            print(f"NOP({numberOfOperands})")
            dumbPrintOperands(operands, operandValues, originalWordNumber, mnemonic)
        elif mnemonic == "XREC":
            tag = field1
            if tag:
                print("XREC final")
            else:
                print("XREC not final")
            break # End of RECORD
        elif mnemonic in ["SMRK", "IMRK"]:
            print(f"%s({numberOfOperands}) %02X %d %d" % (mnemonic,
                                          field1, field4, field5))
            dumbPrintOperands(operands, operandValues, originalWordNumber, mnemonic)
            operand = operands[0]
            statementNumber = operand[0]
            if mnemonic == "SMRK" and statementNumber in listing2:
                print()
                for line in listing2[statementNumber]:
                    print(colorize + line + uncolorize)
                print() #print('-'*90)
        elif False and mnemonic == "PXRC":
            operand = operands[0]
            ptr = operand[0]
            print("PXRC xrec=%d" % ptr)
        elif False and mnemonic in ["MDEF", "TDEF", "PDEF", "FDEF"]:
            operand = operands[0]
            o = operand[0]
            print(f"%s({numberOfOperands}) operand=%d" % (mnemonic, o))
        elif False and mnemonic == "DSUB":
            operand = operands[0]
            reference = operand[0]
            delta = operand[8]
            print(f"DSUB({numberOfOperands}) reference=%d" % reference)
            print("\t\toperand=0001 ESV delta=%d" % delta)
            for operand in operands[1:]:
                o = operand[0]
                alpha = operand[1]
                qual = qMnemonics[operand[2]]  # or B, not sure.
                beta = operand[8]
                print("\t\toperand=%04X alpha=%d qual=%s beta=%d" % \
                      (o, alpha, qual, beta))
        elif mnemonic == "BFNC":
            print(f"%s({numberOfOperands}) %02X=\"%s\" %d %d" % (mnemonic,
                                          field1, bfncTypes[field1], field4, field5))
            dumbPrintOperands(operands, operandValues, originalWordNumber, mnemonic)
        elif False and mnemonic == "?":
            cl = (operatorType >> 8) & 0xFF
            print("Unknown Class %d operator type %02X" % \
                  (cl, operatorType & 0xFF))
            dumbPrintOperands(operands, operandValues, originalWordNumber, mnemonic)
        else:
            print(f"%s({numberOfOperands}) %02X %d %d" % (mnemonic,
                                          field1, field4, field5))
            dumbPrintOperands(operands, operandValues, originalWordNumber, mnemonic)
