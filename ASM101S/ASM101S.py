#!/usr/bin/env python3
'''
License:    This program is declared by its author, Ronald Burkey, to be the 
            U.S. Public Domain, and may be freely used, modifified, or 
            distributed for any purpose whatever.
Filename:   ASM101S.py
Purpose:    This is an assembler for the assembly language of the IBM AP-101S
            computer.
Contact:    info@sandroid.org
Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
History:    2024-08-21 RSB  Began.

On the basis of inspection of actual source-code files of AP-101S assembly 
language, I have decided to use the IBM document S360-21, 
"IBM System/360 Operating System Assembler Language" as a guide to the
syntax and coding conventions associated with this language.  The main 
differences I envisage are these:

    1.  The AP-101S instruction set differs from that of the IBM 360.
    2.  String data is encoded (in generated object files) using DEU coding 
        rather than EBCDIC.
    3.  Source code is assumed to be 7-bit ASCII rather than EBCDIC.
    4.  In concatenating strings within macros, the System/360 documentation
        indicates than period ('.', transparently removed) separates them, but
        that the period is optional if the suffix string begins with '&' or 
        a special character not allowed in "symbols".  For AP-101S, there are
        a few instances of the period, but it is far more common for the suffix 
        string to be enclosed in optional parentheses.  For example, what could 
        be &A&B in either assembler but is optionally &A.&B for System/360,
        would more-likely be an optional &A(&B) in AP-101S.

As far as changes to the instruction set, I rely on the IBM document "Space
Shuttle Model AP-101S Principles of Operation with Shuttle Instruction Set".
Besides the instructions listed there, various other insructions not listed
there are used, such as BP, BLE, BNM, and so on.  I assume that those are
translated to BC and BCR instructions in the manner described in the Figure
4-1 ("Extended Mnemonic Codes") of the System/360 assembly-language document
mentioned in the preceding paragraph. Besides those, there the following 
branches which don't have documentation I can find, but which I could match with
known instructions by binary comparison of their assembled forms:
    BLE        = BNP
    BN         = BM

That document doesn't mention a number of macros which are apparently always
available.  Refer to section 6.2.7 of the "HAL/S Compiler System Specification".
The macros include:  AMAIN, AENTRY, AEXIT, I2DEDR, IBMCEDR, INPUT, OUTPUT, WORK,
ABAL, ACALL, AERROR, ADATA, ACLOSE, ERRPARMS, WORKAREA.  The source code for
these macros, and a few others, is found in PASS.REL32V0/RUNMAC/.  Since 
PASS.REL32V0 is always in the PATH (assuming HALSFC installation instructions
have been followed), we locate the RUNMAC directory by searching the PATH,
and then automatically always read in all of the source-code files in that
directory.
'''

import sys
import os

#=============================================================================
# For reading source files.  The idea is that the entire macro library is 
# read into the `source` array, and then all of the files listed on the 
# command line.  The only processing, per se, is that macros are recognized in
# order to identify the number of parameters they take.  The entries of the 
# `macros` array are lists with the elements:
#    minimum number of parameters
#    maximum number of parameters
#    index into `source` at which the macro definition starts.

macros = { }

# Read a single source-code file.
source = []
def readSourceFile(filename):
    global source
    lineNumber = 0
    inMacroProto = False
    try:
        f = open(filename, "rt")
    except:
        print("Source file '%s' does not exist" % parm, file=sys.stderr)
        sys.exit(1)
    for line in f:
        lineNumber += 1
        line = "%-80s" % line.rstrip()[:80]
        source.append({
            "file": filename,
            "lineNumber": lineNumber,
            "text": line[:71],
            "continues": (line[71] != " "),
            "identification": line[72:],
            "fullComment": False,
            "dotComment": False,
            "name": "",
            "operation": "",
            "operandAndComment": "",
            "operand": "",
            "endComment": "",
            "errors": [],
            "inMacro": False
            })
        line = line[:71]
        if line.startswith(" ") and not inMacroProto:
            fields = line.split()
            if len(fields) > 0 and fields[0] == "MACRO":
                inMacroProto = True
        elif inMacroProto:
            inMacroProto = False
            # This line gives us the "prototype" of the macro.
            # We need to determine the name, the number of mandatory parameters,
            # and the number of optional parameters.
            fields = line.split()
            fieldNum = 0
            parms = []
            if not line.startswith(" "):
                if False:
                    parms.append(fields[0])
                fieldNum = 1
            name = fields[fieldNum]
            fieldNum += 1
            if fieldNum < len(fields):
                parms = parms + fields[fieldNum].split(",")
            mandatory = 0
            optional = 0
            for parm in parms:
                if parm.startswith("&"):
                    if "=" in parm:
                        optional += 1
                    else:
                        mandatory += 1
            macros[name] = [mandatory, mandatory + optional, len(source) - 2]
    f.close()

# Read the entire macro library.
for dir in os.environ["PATH"].split(":"):
    runmac = os.path.join(dir, "RUNMAC")
    if os.path.exists(runmac) and os.path.isdir(runmac):
        for file in os.listdir(runmac):
            path = os.path.join(runmac, file)
            if os.path.isfile(path) and file.endswith(".asm"):
                readSourceFile(path)
        break

if False:
    for macro in sorted(macros):
        print(macro, macros[macro])
    sys.exit(1)

#=============================================================================
# Parse the command-line options.
errorCount = 0

for parm in sys.argv[1:]:
    if not parm.startswith("--"):
        readSourceFile(parm)
    elif parm == "--help":
        print("Usage:")
        print("     ASM101S.py [OPTIONS] SOURCE1.asm ...")
        print("No OPTIONS are presently available")
        sys.exit(1)
    else:
        print("Unrecognized parameter '%s'" % parm, file=sys.stderr)
        sys.exit(1)

# Mark an error in the array of source code.
line = {}
def error(msg):
    global errorCount, line
    errorCount += 1
    line["errors"].append(msg)

#=============================================================================
# Some useful data for syntax analysis.

# All pseudo-ops ("assembler instructions"). See Appendix E.  Gives the 
# minimum and maximum number of comma-delimited operands in the operand field.
# -1 for the maximum means "no limit".  I don't guarantee that all of these
# are necessarily used in AP-101S.
pseudoOps = {
    "ACTR": [1,1],
    "AGO": [1,1],
    "AIF": [1,1],
    "ANOP": [0,0],
    "CCW": [4,4],
    "CNOP": [2,2],
    "COM": [0,0],
    "COPY": [1,1],
    "CSECT": [0,0],
    "CXD": [0,0],
    "DC": [1,-1],
    "DROP": [1,16],
    "DS": [1,-1],
    "DSECT": [0,0],
    "DXD": [1,-1],
    "EJECT": [0,0],
    "END": [0,1],
    "ENTRY": [1,-1],
    "EQU": [1,1],
    "EXTRN": [1,-1],
    "GBLA": [1,-1],
    "GBLB": [1,-1],
    "GBLC": [1,-1],
    "ICTL": [1,3],
    "ISEQ": [2,2],
    "LCLA": [1,-1],
    "LCLB": [1,-1],
    "LCLC": [1,-1],
    "LTORG": [0,0],
    "MACRO": [0,0],
    "MEND": [0,0],
    "MEXIT": [0,0],
    "MNOTE": [2,2],
    "ORG": [0,1],
    "PRINT": [1,3],
    "PUNCH": [1,1],
    "REPRO": [0,0],
    "SETA": [1,1],
    "SETB": [1,1],
    "SETC": [1,1],
    "SPACE": [0,1],
    "START": [0,1],
    "TITLE": [1,1],
    "USING": [2,17]
    }

# AP-101S instruction set.
# 2 operands
argsRR = { "AR", "CR", "CBL", "DR", "XUL", "LR", "LCR", "LFXI", "MR", "SR", 
           "BALR", "BCR", "BCRE", "BCTR", "BVCR", "NCT", "NR", "XR", "OR",
           "SUM", "AEDR", "AER", "CER", "CEDR", "CVFX", "CVFL", "DEDR", "DER",
           "LER", "LECR", "LFXR", "LFLI", "LFLR", "MEDR", "MER", "SEDR", "SER",
           "STXA", "MVH", "SPM", "SRET", "LXA", "ICR", "PC",
           "BR", "NOPR" }
# 3 operands
argsRS = { "A", "AH", "AST", "C", "CH", "D", "IAL", "IHL", "L", "LA", "LH",
           "LM", "M", "MH", "MIH", "ST", "STH", "STM", "S", "SST", "SH", "TD",
           "BAL", "BIX", "BC", "BCT", "BCV", "N", "NST", "X", "XST", "O", 
           "OST", "SHW", "TH", "ZH", "AED", "AE", "CE", "CED", "DED", "DE", "LED", 
           "LE", "MVS", "MED", "ME", "SED", "SE", "STED", "STE", "STXA", "STDM",
           "ISPB", "LPS", "SSM", "SCAL", "LDM", "LXA", "SVC", "TS",
           "B", "NOP", "BH", "BL", "BE", "BNH", "BNL", "BNE", "BO", "BP",
           "BM", "BZ", "BNP", "BNM", "BNZ", "BNO", "BLE", "BN" }
# 3 operands
argsSRS = { "BCB", "BCF", "BCTB", "BVCF", "SLL", "SLDL", "SRA", "SRDA", "SRL",
            "SRDL", "SRR", "SRDR",
            "A", "AH", "C", "CH", "D", "IAL", "L", "LA", "LH",
            "M", "MH", "ST", "STH", "S", "SH", "TD",
            "BC", "N", "X", "O", 
            "SHW", "TH", "ZH", "AE", "DE", "LE", "ME", "SE" }
# 3 operands
argsSI = { "CIST", "MSTH", "NIST", "XIST", "SB", "TB", "ZB", "TSB" }
# 2 operands
argsRI = { "AHI", "CHI", "MHI", "NHI", "XHI", "OHI", "TRB", "ZRB" }

#=============================================================================
# Syntactical analysis of the source code.

letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ$#@"
digits = "0123456789"
specialCharacters = "+-,=*()'/& "
def isSymbol(name, inMacro):
    goodName = True
    if inMacro and name[0] in [".", "&"]:
        newName = name[1:]
        maxLen = 7
    else:
        newName = name
        maxLen = 8
    if len(newName) > maxLen or newName[0] not in letters:
        goodName = False
    else:
        for n in newName[1:]:
            if n not in letters and n not in digits:
                goodName = False
                break
    return goodName

# A symbol expression is a concatenation of strings.
def isSymbolExpression(name, inMacro):
    if name[-1] != ")":
        return isSymbol(name, inMacro)
    fields = name[:-1].split("(")
    if len(fields) != 2:
        errors("Incorrect symbol expression")
        return False
    return isSymbol(fields[0], inMacro) and isSymbol(fields[1], inMacro)

# At this point, the entire source-code file has been read in, and the lines
# have been parsed into 3 fields each:  source, continuation, and identification.
# The source field must now be additionally broken down into name, operation,
# operand, and comment, taking into account continuation lines.
startOfContinued = 0
inMacro = False
for lineNumber in range(len(source)):
    line = source[lineNumber]
    text = line["text"]
    #print("***DEBUG***", text)
    if lineNumber > 0 and source[lineNumber - 1]["continues"]:
        continuation = True
        if text[:15] != " "*15:
            error("Continuation line doesn't begin with enough blanks")
        text = text.strip()
    else:
        continuation = False
    
    if not continuation:
        if len(text.strip()) == 0:
            continue
        if not continuation and text[:2] == ".*":
            line["dotComment"] = True
            continue
        if not continuation and text[0] == "*":
            line["fullComment"] = True
            continue
        if text[0] != " ":
            fields = text.split(None, 1)
            name = fields[0]
            text = fields[1]
            line["name"] = name
            if not inMacro and not isSymbolExpression(name, inMacro):
                error("Illegal name field %s" % name)
                continue
        fields = text.split(None, 1)
        operation = fields[0]
        if operation not in pseudoOps and operation not in macros and \
                operation not in argsRR and \
                operation not in argsRS and operation not in argsSRS and \
                operation not in argsSI and operation not in argsRI:
            error("Unknown operation %s" % operation)
            continue
        line["operation"] = operation
        line["inMacro"] = inMacro
        if operation == "MACRO":
            if inMacro:
                error("New MACRO before closing MEND")
            inMacro = True
            line["inMacro"] = True
        elif operation == "MEND":
            if not inMacro:
                error("MEND without preceeding MACRO")
            inMacro = False
        if inMacro:  # Don't process macro definitions further at this point
            hasOperand = False
            continue
        if len(fields) > 1:
            text = fields[1]
        else:
            text = ""

    # We cannot distinguish at this point between an operand field and the
    # first word of a comment, until we analyze the operation field to 
    # find out if it has an operand or not.
    line["operandAndComment"] = text
    if not continuation:
        hasOperand = False
        if operation in argsRR or operation in argsRS or operation in argsSRS or \
                operation in argsSI or operation in argsRI:
            hasOperand = True
        elif operation in pseudoOps:
            if pseudoOps[operation][0] > 0:
                hasOperand = True
            elif pseudoOps[operation][1] != 0 and len(text.strip()) > 0:
                hasOperand = True
        else:
            if macros[operation][0] > 0:
                hasOperand = True
            elif macros[operation][1] != 0 and len(text.strip()) > 0:
                hasOperand = True
    
    if hasOperand:
        # We cannot use the strategy of just using the .split() method here,
        # because it's possible that the operand does contain blanks, if
        # they're inside of a quoted string.  So we have to parse for
        # that case.  The entire thing could contain spaces if enclosed in
        # parentheses.
        assigned = False
        inQuote = False
        skip = False
        for i in range(len(text)):
            if skip:
                skip = False
                continue
            skip = False
            c = text[i]
            if inQuote:
                if c == "'":
                    if i + 1 < len(text) and text[i+1] == "'":
                        skip = True
                        continue
                    inQuote = False
            elif c == " ":
                assigned = True
                line["operand"] = text[:i]
                line["endComment"] = text[i+1:].strip()
                break
            elif c == "'":
                inQuote = True
        if inQuote:
            error("Unterminated quote")
            continue
        if not assigned:
            line["operand"] = text
        if len(line["operand"]) == 0:
            error("Missing operand field")
            continue
    
# At this point, all of the lines of source have been parsed into their
# appropriate fields, and marked with syntactical errors, with errorCount
# telling us how many total errors there are.  Im sure the original 
# assembler would continue with the assembly at this point, but I don't
# see any reason to.  Let the coder fix the syntactical errors before 
# forcing me to figure out fallbacks for them!
if inMacro:
    errorCount += 1
if errorCount > 0:
    print("Assembly aborted.  Fix the syntax errors marked below and retry.")
    print()
    if inMacro:
        print("No closing MEND for MACRO")
        print()
    lastError = False
    for i in range(len(source)):
        line = source[i]
        if len(line["errors"]) == 0:
            print("%5d:  %s" % (i, line["text"]))
            lastError = False
        else:
            if not lastError:
                print("=====================================================")
            for msg in line["errors"]:
                print(msg)
            print("%5d:  %s" % (i, line["text"]))
            print("=====================================================")
            lastError = True
    sys.exit(1)

if True: #***DEBUG***
    for i in range(len(source)):
        line = source[i]
        if line["fullComment"] or line["dotComment"]:
            print("%5d:  %s" % (i, line["text"]))
        else:
            print("%5d:  %-8s %-5s %-15s%s" % (
                i,
                line["name"], 
                line["operation"],
                line["operand"],
                line["endComment"]))
    for n in sorted(macros):
        print("%-20s" % n, macros[n])