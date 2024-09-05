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
from pathlib import Path

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
           "BR", "NOPR", "LACR" }
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
argsRI = { "AHI", "CHI", "MHI", "NHI", "XHI", "OHI", "TRB", "ZRB", "LHI",
           "SHI" }

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
# For reading source files.  The idea is that the entire macro library is 
# read into the `source` array, and then all of the files listed on the 
# command line are read.  All `COPY` operations are performed and all macro
# invocations expanded.  All of the lines are parsed, except that macro
# definitions are only barely parsed, and are fully parsed upon expansion.
# The entries of the `macros` array are lists with the elements:
#    minimum number of parameters
#    maximum number of parameters
#    index into `source` at which the macro definition starts.
#    index into `source` at which the macro definition ends.
macros = {  }

# Mark an error in the array of source code.
errorCount = 0
def error(line, msg):
    global errorCount
    errorCount += 1
    line["errors"].append(msg)

letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ$#@"
digits = "0123456789"
specialCharacters = "+-,=*()'/& "
def isSymbol(name, inMacroDefinition = False):
    goodName = True
    if inMacroDefinition and name[0] in [".", "&"]:
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
def isSymbolExpression(name, inMacroDefinition = False):
    if name[-1] != ")":
        return isSymbol(name, inMacroDefinition)
    fields = name[:-1].split("(")
    if len(fields) != 2:
        errors("Incorrect symbol expression")
        return False
    return isSymbol(fields[0], inMacroDefinition) and isSymbol(fields[1], inMacroDefinition)

# `macros` allows quick lookup of macro definitions, which are stored in the 
# `source` list just like all other lines of code, except not fully parsed.
# Each entry in `macros` is a list of numbers:
#    The minimum number of parameters for invocation.
#    The maximum   "    "      "       "       "
#    The starting index (i.e., of `MACRO`) in `source`.
#    The ending index (i.e., of `MEND`) in `source`.
macros = { }
# Global symbolic variables for the macro language.
macroGlobals = { }

# Recursively read a batch of lines of source code, expanding if necessary for 
# `COPY` pseudo-op or invocation of a macro.  The parameters:
#    fromWhere   Either a filename or the name of a macro.  The latter lets 
#                us read in all of the macro definitions at startup, and then 
#                reuse the definitionas as many times as we like without 
#                rereading the file that contained them.
#    expansion   If the value is None, then it means that we're *not* in the
#                process of expanding a macro.  If the value is a dict (even
#                an empty dict), when we are in the process of expanding a
#                macro, and the dict gives is the replacement value for each
#                formal parameter.
#    copy        Indicates that the file is being read as the target of a 
#                `COPY` pseudo-op.
#    printable   Indicates that the file will be listed in the output assembly
#                listing.  Would be False for anything read from the macro
#                library.
source = []
libraries = []
def readSourceFile(fromWhere, expansion, copy=False, printable=True):
    global source, macros, macroGlobals
    macroLocals = { }
    lineNumber = -1
    inMacroProto = False
    inMacroDefinition = False
    continuation = False
    name = ""
    operation = ""
    
    if fromWhere in macros:
        thisSource = []
        for i in range(macros[fromWhere][2], macros[fromWhere][3] + 1):
            thisSource.append(source[i]["text"])
            
        print("***DEBUG*** hello", fromWhere, expansion, copy, printable)
        for line in thisSource:
            print(line)
        sys.exit(1)
    else:
        try:
            f = open(fromWhere, "rt")
            thisSource = f.readlines()
            f.close()
            filename = fromWhere
        except:
            print("Source file '%s' does not exist" % fromWhere, file=sys.stderr)
            sys.exit(1)
    
    skipCount = 0
    for line in thisSource:
        
        lineNumber += 1
        line = "%-80s" % line.rstrip()[:80]
        text = line[:71]
        properties = {
            "file": filename,
            "lineNumber": lineNumber + 1,
            "text": text,
            "longText": "",
            "continues": (line[71] != " "),
            "identification": line[72:],
            "empty": (text.strip() == ""),
            "fullComment": line.startswith("*"),
            "dotComment": line.startswith(".*"),
            "name": "",
            "operation": "",
            "operandAndComment": "",
            "operand": "",
            "endComment": "",
            "errors": [],
            "inMacroDefinition": inMacroDefinition,
            "copy": copy,
            "printable": printable,
            "macroExpansionLevel": 0
            }
        source.append(properties)
        if skipCount > 0:
            skipCount -= 1
            continue
        if properties["empty"] or properties["fullComment"] or properties["dotComment"]:
            continue
        
        # Join continuation lines as the longText field.
        if properties["continues"]:
            if inMacroProto:
                # Line continuations in macro prototype lines work differently from
                # all others.  There's no real way to get the endComment field
                # right, but that's frankly not used for anything anyway (even
                # for the assembly listing!), so it doesn't really matter.  We
                # just strip the end comments away.
                j = 0
                while j < 71 and text[j] != " ":  # Scan past the label, if any.
                    j += 1
                while j < 71 and text[j] == " ":  # Scan past the space between label and operation
                    j += 1
                while j < 71 and text[j] != " ":  # Scan past the operation.
                    j += 1
                while j < 71 and text[j] == " ":  # Scan past the space following the operation
                    j += 1
                if j < 71:
                    while j < 71 and text[j] != " ":  # Scan past the operand field
                        j += 1
                # There are 3 cases now:
                #   1. If we've reached the end of the card, then the 
                #      next line (sans its first 15 characters) is simply
                #      joined to this one.
                #   2. If the final character had been ',', then the 
                #      remainder of this line is discarded and the next
                #      line (sans first 15 characters) is joined to this
                #      one.
                #   3. Otherwise, we're done, and the remaining cards
                #      have only comments.
                i = lineNumber
                completed = False
                while i + 1 < len(thisSource) and thisSource[i][71] != " ":
                    skipCount += 1
                    i += 1
                    if not completed:
                        newLine = ("%-80s" % thisSource[i])[:71]
                        j = 15
                        while j < 71 and newLine[j] != " ":  # Scan past the operand field
                            j += 1
                        completed = ( j < 71 and newLine[j-1] != "," )
                        text = text + newLine[15:j]
            else:
                # This is how "normal" line-continuations work.
                i = lineNumber
                while i + 1 < len(thisSource) and thisSource[i][71] != " ":
                    skipCount += 1
                    i += 1
                    text = text + thisSource[i][15:71]
        properties["longText"] = text
        
        fields = text.split()
        if text.startswith(" ") and not inMacroDefinition and len(fields) > 0 and \
                fields[0] == "MACRO":
            inMacroProto = True
            inMacroDefinition = True
            macroStart = len(source) - 1
            properties["inMacroDefinition"] = True
        elif inMacroProto:
            inMacroProto = False
            # This line gives us the "prototype" of the macro.
            # We need to determine the name, the number of mandatory parameters,
            # and the number of optional parameters.
            fieldNum = 0
            parms = []
            if not text.startswith(" "):
                if False:
                    parms.append(fields[0])
                fieldNum = 1
            macroName = fields[fieldNum]
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
            macros[macroName] = [mandatory, mandatory + optional, macroStart]
            macroName = macroName
        elif inMacroDefinition and not text.startswith("*") and not text.startswith(".*"):
            if (len(fields) > 1 and text[0] != " " and fields[1] == "MEND" ) or \
                    (len(fields) > 0 and text[0] == " " and fields[0] == "MEND"):
                macros[macroName].append(len(source)-1)
                inMacroDefinition = False
                continue
        elif not inMacroDefinition and text.startswith(" ") and len(fields) > 1 and \
                fields[0] == "COPY":
            found = False
            for library in libraries:
                fcopy = os.path.join(library, fields[1] + ".asm")
                if os.path.exists(fcopy) and os.path.isfile(fcopy):
                    found = True
                    readSourceFile(fcopy, expansion, True)
                    break
            if not found:
                print("File %s.asm for COPY not found" % fields[1], file=sys.stderr)
                sys.exit(1)
            continue
        
        if inMacroDefinition:
            continue
        
        if len(source) > 1 and source[-2]["continues"]:
            continuation = True
            if text[:15] != " "*15:
                error(properties, "Continuation line doesn't begin with enough blanks")
        else:
            continuation = False
        
        if not continuation:
            if properties["empty"]:
                continue
            if text[0] != " ":
                fields = text.split(None, 1)
                name = fields[0]
                text = fields[1]
                properties["name"] = name
                if not isSymbolExpression(name):
                    error(properties, "Illegal name field %s" % name)
                    continue
            fields = text.split(None, 1)
            operation = fields[0]
            if operation not in pseudoOps and \
                    operation not in macros and \
                    operation not in knownInstruction:
                error(properties, "Unknown operation %s" % operation)
                continue
            properties["operation"] = operation
            if len(fields) > 1:
                text = fields[1]
            else:
                text = ""
        else:
            text = text.lstrip()
        properties["operandAndComment"] = text
        operandAndComment = text
        
        # We cannot distinguish at this point between an operand field and the
        # first word of a comment, until we analyze the operation field to 
        # find out if it has an operand or not.
        if not continuation:
            hasOperand = False
            if operation in argsBCE:
                pass
            elif operation in knownInstruction:
                hasOperand = True
            elif operation in pseudoOps:
                if pseudoOps[operation][0] > 0:
                    hasOperand = True
                elif pseudoOps[operation][1] != 0 and len(operandAndComment.strip()) > 0:
                    hasOperand = True
            elif operation in macros:
                if macros[operation][0] > 0:
                    hasOperand = True
                elif macros[operation][1] != 0 and len(operandAndComment.strip()) > 0:
                    hasOperand = True
                # We need to expand the macro.  Here are the basic steps:
                #    1.  Determine the values of all of the pararameters of the
                #        invocation.
                #    2.  Determine all of the formal parameters.
                #    3.  Make a dictionary with keys that are the formal 
                #        parameters and values which are the replacements.
                #    4.  Call readSourceFile with the macro name and the 
                #        parameter-replacement dictionary as its parameters.
                
                print("***DEBUG***", operation, macros[operation])
                for n in range(macros[operation][2], macros[operation][3] + 1):
                    print(source[n])
                    if source[n]["operation"] == "MEND":
                        break
                    n += 1
                sys.exit(1)
                
                newExpansion = {}  # ***FIXME***
                readSourceFile(operation, newExpansion, copy, printable)
            else:
                print("Implementation error, operation=%s" % operation, file=sys.stderr)
                sys.exit(1)
        else:
            hasOperand = source[lineNumber - 1]["operand"].endswith(",")
        
        if hasOperand:
            # We cannot use the strategy of just using the .split() method here,
            # because it's possible that the operand does contain blanks, if
            # inside of a quoted string.  So we have to parse for
            # that case.  The entire thing could contain spaces if enclosed in
            # parentheses.
            assigned = False
            inQuote = False
            skip = False
            for i in range(len(operandAndComment)):
                if skip:
                    skip = False
                    continue
                skip = False
                c = operandAndComment[i]
                if inQuote:
                    if c == "'":
                        if i + 1 < len(operandAndComment) and operandAndComment[i+1] == "'":
                            skip = True
                            continue
                        inQuote = False
                elif c == " ":
                    assigned = True
                    properties["operand"] = operandAndComment[:i]
                    properties["endComment"] = operandAndComment[i+1:].strip()
                    break
                elif c == "'":
                    inQuote = True
            if inQuote:
                error(properties, "Unterminated quote")
                continue
            if not assigned:
                properties["operand"] = operandAndComment
            if len(properties["operand"]) == 0:
                error(properties, "Missing operand field")
                continue
            

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
        readSourceFile(path, None, False, False)

if False:
    for macro in sorted(macros):
        print(macro, macros[macro])
    sys.exit(1)

#=============================================================================
# Parse the command-line options.
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
        readSourceFile(parm, None)
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

#=============================================================================
# Syntactical analysis of the source code.

# At this point, all of the lines of source have been parsed into their
# appropriate fields, and marked with syntactical errors, with errorCount
# telling us how many total errors there are.  Im sure the original 
# assembler would continue with the assembly at this point, but I don't
# see any reason to.  Let the coder fix the syntactical errors before 
# forcing me to figure out fallbacks for them!
if len(source) > 0 and source[-1]["inMacroDefinition"]:
    errorCount += 1
if errorCount > 0:
    print("Assembly aborted.  Fix the syntax errors marked below and retry.")
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
    if len(source) > 0 and source[-1]["inMacroDefinition"]:
        print("No closing MEND for MACRO")
    sys.exit(1)

if True: #***DEBUG***
    inCopy = False
    memberName = ""
    rvl = 0
    concat = 0
    nest = 0
    for i in range(len(source)):
        property = source[i]
        if property["copy"]:
            if not inCopy:
                memberName = Path(property["file"]).stem
                print("         START OF COPY MEMBER %-8s RVL %02d CONCATENATION NO. %03d  NEST %03d" \
                      % (memberName, rvl, concat, nest))
                inCopy = True
        else:
            if inCopy:
                print("           END OF COPY MEMBER %-8s RVL %02d CONCATENATION NO. %03d  NEST %03d" \
                      % (memberName, rvl, concat, nest))
                inCopy = False
        if property["printable"]:
            if property["fullComment"] or property["dotComment"]:
                print("%5d:  %s" % (i, property["text"]))
            else:
                print("%5d:  %-8s %-5s %-14s %s" % (
                    i,
                    property["name"], 
                    property["operation"],
                    property["operand"],
                    property["endComment"]))
    if False:
        for n in sorted(macros):
            print("%-20s" % n, macros[n])