#!/usr/bin/env python3
'''
License:    This program is declared by its author, Ron Burkey, to be
            in the Public Domain in the U.S., and can be used or 
            modified in any way desired.
Filename:   unHALMAT.py
Purpose:    To parse a binary HALMAT file output by HAL_S_FC.py.
History:    2023-11-13 RSB  Began.

It is unclear to the extent that the goal of this program can be 
achieved.  Only 2 sources of documentation about the inner structure of
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

# Read the entire file.
if len(sys.argv) != 2:
    print("Need to specify the name of the HALMAT file.")
    sys.exit(1)
try:
    fileName = sys.argv[1]
    f = open(fileName, "rb")
    data = bytearray(f.read())
    f.close()
    fileLength = len(data)
except:
    print("Cannot read the specified HALMAT file.")
    sys.exit(1)
print("%d bytes read from %s" % (fileLength, fileName))

qMnemonicsA = ["-", "SYT", "GLI", "VAC", "XPT", "LIT", "IMD",
              "AST", "CSZ", "ASZ", "OFF", "?", "?", "?", "?", "?"]
qMnemonicsB = ["-", "SYL", "INL", "VAC", "XPT", "LIT", "IMD",
              "AST", "CSZ", "ASZ", "OFF", "?", "?", "?", "?", "?"]
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
    0x101: "BASN", # Confused about XASN ... is that a real type?
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

def dumbPrintOperands(operands):
    for operand in operands:
        print("\t\t", end = "")
        for i in range(len(operand)):
            o = operand[i]
            if i == 2:
                print("%02X(%s?) " % (o, qMnemonicsA[o]), end = "")
            else:
                print("%02X " % o, end = "")
        print()

# I don't know if this works for all operands, but ...
def parseOperand(operand):
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
        # From the incomplete info in REF2, it appears to me that
        # the first word of each PARAGRAPH, presumably the OPERATOR
        # WORD, is partitioned into fields as follows:
        #    8 bits:    Interpretation TBD
        #    8 bits:    Number of operands
        #    12 bits:   Operator type
        #    3 bits:    Interpretation TBD
        #    1 bit:     Interpretation TBD.
        # Section A2 gives mnemonic symbolic interpretations of the
        # numerical operator types.  Unfortunately, there appears to be
        # no field which indicates whether (or how many) OPERAND WORDS
        # follow the operator word, so the only way to determine that
        # is to simply know (for each operator type) how many operand
        # words there will be.
        field1 = word[0]
        numberOfOperands = word[1]
        operatorType = (word[2] << 4) | ((word[3] >> 4) & 0xFF)
        field4 = (word[3] >> 1) & 0x07
        field5 = word[3] & 1
        operands = []
        for i in range(numberOfOperands):
            wordOffset += 4
            operands.append(parseOperand(data[wordOffset : wordOffset + 4]))
            wordNumber += 1
        mnemonic = "?"
        if operatorType in operatorMnemonics:
            mnemonic = operatorMnemonics[operatorType]
        # Interpret these by operator type.
        print("  %4d: " % originalWordNumber, end = "")
        if mnemonic == "NOP":
            print("NOP")
            dumbPrintOperands(operands)
        elif mnemonic == "XREC":
            tag = field1
            if tag:
                print("XREC (final)")
            else:
                print("XREC")
            break # End of RECORD
        elif mnemonic in ["SMRK", "IMRK"]:
            errorTag = field1
            operand = operands[0]
            statementNumber = operand[0]
            debug = operand[1]
            c = operand[6]
            print("%s statement=%d severity=%d debug=%d halmat=%d" \
                  % (mnemonic, statementNumber, errorTag, debug, c))
        elif mnemonic == "PXRC":
            operand = operands[0]
            ptr = operand[0]
            print("PXRC xrec=%d" % ptr)
        elif mnemonic in ["MDEF", "TDEF", "PDEF", "FDEF"]:
            operand = operands[0]
            o = operand[0]
            print("%s operand=%d" % (mnemonic, o))
        elif mnemonic == "DSUB":
            operand = operands[0]
            reference = operand[0]
            delta = operand[8]
            print("\t\tESV delta=%d" % delta)
            for operand in operands[1:]:
                o = operand[0]
                alpha = operand[1]
                qual = qMnemonicsA[operand[2]]  # or B, not sure.
                beta = operand[8]
                print("\t\toperand=%04X alpha=%d qual=%s beta=%d" % \
                      (o, alpha, qual, beta))
        elif mnemonic == "?":
            cl = (operatorType >> 8) & 0xFF
            print("Unknown Class %d operator type %02X" % \
                  (cl, operatorType & 0xFF))
            dumbPrintOperands(operands)
        else:
            print("%s %02X %d %d" % (mnemonic,
                                          field1, field4, field5))
            dumbPrintOperands(operands)
        