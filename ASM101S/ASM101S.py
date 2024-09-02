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
libraries = []
def readSourceFile(filename, copy=False, printable=True):
    global source
    lineNumber = 0
    inMacroProto = False
    inMacro = False
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
            "inMacro": inMacro,
            "copy": copy,
            "printable": printable
            })
        line = line[:71]
        fields = line.split()
        if line.startswith(" ") and not inMacro:
            if len(fields) > 0 and fields[0] == "MACRO":
                inMacroProto = True
                inMacro = True
                source[-1]["inMacro"] = True
        elif inMacroProto:
            if line.startswith("*") or line.startswith(".*"):
                continue
            inMacroProto = False
            # This line gives us the "prototype" of the macro.
            # We need to determine the name, the number of mandatory parameters,
            # and the number of optional parameters.
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
        elif inMacro and not line.startswith("*") and not line.startswith(".*"):
            if len(fields) > 1 and line[0] != " " and fields[1] == "MEND":
                inMacro = False
            elif len(fields) > 0 and line[0] == " " and fields[0] == "MEND":
                inMacro = False
        elif not inMacro and line.startswith(" ") and len(fields) > 1 and \
                fields[0] == "COPY":
            found = False
            for library in libraries:
                filename = os.path.join(library, fields[1] + ".asm")
                if os.path.exists(filename) and os.path.isfile(filename):
                    found = True
                    readSourceFile(filename, True)
                    break
            if not found:
                print("File %s.asm for COPY not found" % fields[1], file=sys.stderr)
                sys.exit(1)
    f.close()

'''
# Read the entire macro library.
for dir in os.environ["PATH"].split(":"):
    runmac = os.path.join(dir, "RUNMAC")
    if os.path.exists(runmac) and os.path.isdir(runmac):
        for file in os.listdir(runmac):
            path = os.path.join(runmac, file)
            if os.path.isfile(path) and file.endswith(".asm"):
                readSourceFile(path)
        break
'''

# Read an entire macro library.
def readMacroLibrary(dir):
    global libraries
    path = os.path.join(dir, "MACROFILES.txt")
    try:
        f = open(path, "rt")
    except:
        print("Cannot open %s" % path, file=sys.stderr)
        sys.exit(1)
    libraries.append(dir)
    macroFiles = set()
    for line in f:
        line = line.strip()
        if line == "" or line[0] == ";": # Is it a comment or whitespace?
            continue
        macroFiles.add(line.strip())
    f.close()
    for file in os.listdir(dir):
        if file not in macroFiles:
            continue
        path = os.path.join(dir, file)
        readSourceFile(path, printable=False)

if False:
    for macro in sorted(macros):
        print(macro, macros[macro])
    sys.exit(1)

#=============================================================================
# Parse the command-line options.
errorCount = 0
objectFileName = None
sourceFileCount = 0

for parm in sys.argv[1:]:
    if parm.startswith("--library="):
        readMacroLibrary(parm[10:])
    elif parm.startswith("--object="):
        if not parm.endswith(".obj"):
            print("Object-code filenames must end in .obj", file=sys.stderr)
            sys.exit(1)
        objectFileName = parm[8:]
    elif not parm.startswith("--"):
        if not parm.endswith(".asm"):
            print("Source-code filenames must end with .asm", file=sys.stderr)
            sys.exit(1)
        if objectFileName == None:
            objectFileName == parm[:-4] + ".obj"
        readSourceFile(parm)
        sourceFileCount += 1
    elif parm == "--help":
        print("Usage:")
        print("     ASM101S.py [OPTIONS] SOURCE1.asm ...")
        print()
        print("The defined OPTIONS are:")
        print()
        print("--help              Display this message.")
        print("--object=F.obj      Specify the name of the output object-code")
        print("                    file.  The default is SOURCEn.obj, where")
        print("                    SOURCEn.asm is the *last* source-code file")
        print("                    specified on the command line.")
        print("--library=L         L specifies a path to a macro library.")
        print("                    This option can appear multiple times.")
        print()
        sys.exit(1)
    else:
        print("Unrecognized parameter '%s'" % parm, file=sys.stderr)
        sys.exit(1)
if sourceFileCount == 0:
    print("No source-code files were specified", file=sys.stderr)
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
    "SPOFF": [0,0],
    "SPON": [0,0],
    "START": [0,1],
    "TITLE": [1,1],
    "USING": [2,17]
    }

# AP-101S instruction set.

# First, the CPU instructions, categorized by RR, RS, SRS, SI, and RI.
# 2 operands
argsRR = { "AR", "CR", "CBL", "DR", "XUL", "LR", "LCR", "LFXI", "MR", "SR", 
           "BALR", "BCR", "BCRE", "BCTR", "BVCR", "NCT", "NR", "XR", "OR",
           "SUM", "AEDR", "AER", "CER", "CEDR", "CVFX", "CVFL", "DEDR", "DER",
           "LER", "LECR", "LFXR", "LFLI", "LFLR", "MEDR", "MER", "SEDR", "SER",
           "STXA", "MVH", "SPM", "SRET", "LXA", "ICR", "PC",
           "BR", "NOPR" }
# 3 operands
argsRS = { "A", "AH", "AST", 
           "C", "CH", "D", 
           "IAL", "IHL", 
           "L", "LA", "LH",
           "LM", "M", "MH", 
           "MIH", "ST", "STH", 
           "STM", "S", "SST", 
           "SH", "TD", "BAL",
           "BIX", "BC", "BCT", 
           "BCV", "N", "NST", 
           "X", "XST", "O",
           "OST", "SHW", "TH", 
           "ZH", "AED", "AE", "CE", "CED", "DED", "DE", "LED", "LE", "MVS", 
           "MED", "ME", "SED", "SE", "STED", "STE", "DIAG", "STXA", "STDM",
           "ISPB", "LPS", "SSM", "SCAL", "LDM", "LXA", "SVC", "TS",
           "B", "NOP", "BH", "BL", "BE", "BNH", "BNL", "BNE", "BO", "BP",
           "BM", "BZ", "BNP", "BNM", "BNZ", "BNO", "BLE", "BN" }
for m in sorted(argsRS):
    argsRS.add(m + "@")
    argsRS.add(m + "@#")
    argsRS.add(m + "#")
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
argsRI = { "AHI", "CHI", "MHI", "NHI", "XHI", "OHI", "TRB", "ZRB", "LHI" }

# Now, the MSC instructions.  All have operands.
argsMSC = { "@A", "@B", "@BN", "@BNN", "@BNP", "@BNZ", "@BU", "@BU@", "@BXN",
         "@BXNN", "@BXNP", "@BXNZ", "@BXP",
         "@BXZ", "@BZ", "@C", "@CI", "@CNOP", "@DLY", "@INT", "@L", "@LAR", 
         "@LF", "@LH", "@LI", "@LMS", "@LXI", "@N", "@NIX", "@RAI", "@RAW",
         "@RBI", "@REC", "@RFD", "@RNI", "@RNW", "@SAI", "@SEC", "@SFD", "@SIO",
         "@ST", "@STF", "@STH", "@STP", "@TAX", "@TI", "@TM", "@TMI", "@TSZ", 
         "@TXA", "@TXI", "@WAT", "@X", "@XAX",
         "@BC", "@BXC" "@CALL", "@CALL@", "@LBB", "@LBB@", "@LBP", "@LBP@" }

# And BCE instructions.  None have operands.
argsBCE = { "#@#DEC", "#@#HEX", "#@#SCN", "#BU", "#BU@", "#CMD", "#CMDI", "#CNOP",
         "#DLY", "#DLYI", "#LBR", "#LBR@", "#LTO", "#LTOI", "#MIN", "#MIN@",
         "#MINC", "#MOUT", "#MOUT@", "#MOUTC", "#ORG", "#RDL", "#RDLI", "#RDS",
         "#RIB", "#SIB", "#SPLIT", "#SSC", "#SST", "#STP", "#TDL", "#TDLI",
         "#TDS", "#WAT", "#WIX"
       }

knownInstruction = set.union(argsRR, argsRS, argsSRS, argsSI, argsRI, argsMSC, argsBCE)

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
        if not inMacro and \
                operation not in pseudoOps and \
                operation not in macros and \
                operation not in knownInstruction:
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
                operation in argsSI or operation in argsRI or \
                operation in argsMSC:
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
        if line["printable"]:
            if line["fullComment"] or line["dotComment"]:
                print("%5d:  %s" % (i, line["text"]))
            else:
                print("%5d:  %-8s %-5s %-15s%s" % (
                    i,
                    line["name"], 
                    line["operation"],
                    line["operand"],
                    line["endComment"]))
    if False:
        for n in sorted(macros):
            print("%-20s" % n, macros[n])