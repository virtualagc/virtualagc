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
import re
from pathlib import Path
from fieldParser import *

# Specifics for the type of assembly language.
if "--390" in sys.argv[1:]:
    print("System/390 support not presently available.", file=sys.stderr)
    sys.exit(1)
    from model360 import *
else:  # --101
    from model101 import *

#=============================================================================
# Some useful data for syntax analysis.

# All pseudo-ops ("assembler instructions"). See Appendix E of the 
# "IBM System/360 Operating System Assembler Language" manual.  Gives the 
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
#    index of the prototype line.
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
    return isSymbol(fields[0], inMacroDefinition) and \
        isSymbol(fields[1], inMacroDefinition)

# `macros` allows quick lookup of macro definitions, which are stored in the 
# `source` list just like all other lines of code, except not fully parsed.
# Each entry in `macros` is a list of numbers:
#    The number of positional parameters for invocation.
#    The total number of parameters for invocation (positional or not).
#    The starting index (i.e., of `MACRO`) in `source`.
#    The index of the macro's prototype line in `source`.
#    The ending index (i.e., of `MEND`) in `source`.
macros = { }
# Global symbolic variables for the macro language.
svGlobals = { }

symVarPatt = re.compile(r'(?<!&)(&A|&B)(?![#@$A-Z0-9])')

# This function replaces all symbolic variables (e.g., &A) given by 
# `svGlobals` and `svNonGlobals` in a string.
def replaceMacroVariables(text, svNonGlobals):
    
    if "=" not in text:
        return text
    
    # The search pattern is any already-defined symbolic variable not preceded
    # by an extra & and not followed by an extra "letter" or digit.
    symbolicVariables = svGlobals | svNonGlobals
    pattern = "(?<!&)("
    for sv in symbolicVariables:
        pattern = pattern + sv + "|"
    pattern = pattern[:-1] + ")(?![#@_$A-Z0-9])"
    
    # We want to do the replacements in reverse order, so as to keep the
    # indexes to the strings not yet replaced from changing.
    matches = []
    for match in re.finditer(pattern, text):
        matches.append(match)
    for match in reversed(matches):
        replacement = symbolicVariables[match.match]
        start = match.span[0]
        end = match.span[1]
        if end < len(text) and text[end] == ".":
            end += 1
        text = text[:start] + replacement + text[end:]
    
    return text

# The `parseLine` function parses an input card (namely `lines[lineNumber]`) 
# into `name`, `operation`, an array of operands, and possibly a comment.
# It does not try to determine validity (except to the extent necessary for 
# parsing) nor to evaluate any expressions.  It takes into account continuation
# cards, macro definitions (without expanding them), and the alternate 
# continuation format sometimes used for macro arguments 
# and macro formal parameters.  It takes into account parenthesization and 
# quoted strings (and their attendant spaces) within sub-operands.  The return 
# is the triple
#    skipCount, inMacroDefinition, inMacroProto
# Lines in macro definitions are not parsed beyond their prototypes; that's 
# done only during expansion.
# Concerning the `mlocal` argument:  To the extent we know them (but our 
# knowledge isn't perfect), we replace preprocessor symbolic variables, which
# are of two types:  global and local, the latter of which are provided by 
# `mlocal`.
def parseLine(lines, lineNumber, inMacroDefinition, inMacroProto, svLocals={}):
    global source
    alternate = inMacroProto
    skipped = 0
    properties = source[-1]
    subOperands = []
    properties["operand"] = subOperands
    if properties["empty"] or properties["fullComment"] or \
            properties["dotComment"]:
        return 0, inMacroDefinition, inMacroProto
    text = properties["text"]
    # Parse all fields prior to the operand, at least enough to determine the
    # contents if not the validity.
    j = 0
    while j < len(text) and text[j] != " ":  # Scan past the label, if any.
        j += 1
    name = text[:j]
    if not inMacroDefinition:
        name = replaceMacroVariables(name, svLocals)
    properties["name"] = name
    while j < len(text) and text[j] == " ":  # Scan up to operation
        j += 1
    k = j
    while j < len(text) and text[j] != " ":  # Scan past the operation.
        j += 1
    operation = text[k:j]
    if not inMacroDefinition:
        operation = replaceMacroVariables(operation, svLocals)
    properties["operation"] = operation
    if operation in macros:
        alternate = True
    if operation == "MACRO":
        if inMacroDefinition:
            error(properties, "Nested MACRO definitions")
        inMacroDefinition = True
        inMacroProto = True
        return 0, inMacroDefinition, inMacroProto
    if operation == "MEND":
        if not inMacroDefinition:
            error(properties, "MEND without preceding MACRO")
        inMacroDefinition = False
        inMacroProto = False
        return 0, inMacroDefinition, inMacroProto
    if inMacroDefinition and not inMacroProto:
        return 0, inMacroDefinition, inMacroProto
    while j < len(text) and text[j] == " ":  # Scan up to operand/comment
        j += 1
    properties["operandAndComment"] = text[j:]
    # What we do to parse the operand field depends on whether it's even 
    # possible for this operation ot have operands.  Otherwise, we would parse
    # the first word of an end-of-line comment (if any) as the operand field.
    noOperands = False
    if not inMacroProto:
        if operation in macros:
            # There's a possibility that *all* replacement arguments are 
            # omitted but that a comment field is present anyway.  That means
            # there's can be an ambiguity as to whether the first word of the
            # comment is perhaps a replacement argument.  Sigh!  We have to
            # maneuver a little bit to work through the special cases.
            macrostats = macros[operation]
            positional = macrostats[0]
            nonpositional = macrostats[1] - positional
            if positional > 0:
                # In this case, there is supposedly at least something (namely
                # a comma) in the operand field, so the comment won't be
                # considered.   See "Comment Entries" (p. 9) in assembler
                # manual.
                pass
            elif nonpositional == 0:
                pass
            else:
                # This is the tricky case, because if there are no positional
                # parameters but potentially some nonpositional ones, then 
                # omitting all of the parameters doesn't require the naked
                # comma mentioned above.  Instead, we have to check that first
                # word of the comment to see if it corresponds to any of the
                # legal nonpositional parameters.
                fields = properties["operandAndComment"].split(None, 1)
                if len(fields) == 0:
                    noOperands = True
                else:
                    formal = source[macrostats[3]]["operand"]
                    found = False
                    for parm in formal:
                        if "=" not in parm:
                            continue
                        n = parm[1:].split("=", 1)[0]
                        if fields[0].startswith(n):
                            found = True
                            break
                    if not found:
                        noOperands = True
        elif operation in instructionsWithoutOperands:
            noOperands = True
        elif operation in pseudoOps:
            if pseudoOps[operation][0] == 0:
                noOperands = True
        elif operation not in instructionsWithOperands:
            error(properties, \
                  "Unknown operation (%s), assuming it has no operands" % \
                  operation)
            noOperands = True
        if noOperands:
            properties["endComment"] = text[j:]
            return 0, inMacroDefinition, inMacroProto
    # Now we're ready to start parsing the operand field into subfields.
    # If the "alternate" format is used and we're actually at the end of the
    # card, and there's a continuation card, then the operand field begins on
    # the next card.
    currentNumber = lineNumber
    currentProperties = properties
    currentText = text
    inQuote = False
    parenthesisDepth = 0
    currentSubParm = ""
    lastWasInternalQuote = False
    ampStart = -1  # Position in `currentText` to start of a symbolic variable.
    while True:  # Loop character by character, loading new cards as needed.
        if j >= len(text) and not currentProperties["continues"]:
            break
        if j >= len(text) and currentProperties["continues"]:
            if currentLineNumber + 1 >= len(lines):
                error(properties, "Continuation card is missing")
                return skipped
            skipped += 1
            currentNumber += 1
            currentProperties = lines[currentNumber]
            currentText = currentProperties["text"]
            j = 15
        c = currentText[j]
        currentSubParm = currentSubParm + c
        j += 1
        
        # Process ampersands and symbolic-variable replacements
        if ampStart >= 0:
            if ampStart == j - 2: # First character after &
                if c == '&':  # &&
                    ampStart = -1
                    continue
                if c in letters:
                    continue
            if c in letters or c in digits:
                continue
            # If we've gotten here, we've found a non-empty substring starting
            # at `ampString` that's of an appropriate format to be a symbolic
            # variable.  If it really is one, we need to replace it and to 
            # resume processing back where it starts.
            sv = currentText[ampStart: j]
            replacement = None
            if sv in svLocals:
                replacement = svLocals[sv]
            elif sv in svGlobals:
                replacement = svGlobals
            if replacement == None:
                ampStart = -1
                # Fall through to normal processing of c.
            else:
                # If we're here, it's because we've found a symbolic variable
                # (`sv`) in `currentText` and need to replace it (with
                # `replacement`).  As usual, there are some weird cases we need
                # to consider.  
                #   1.   It's possible that `replacement` is of the form 
                #            ( ... )
                #        in which case it's a *list* of comma-delimited 
                #        parameters that have been grouped together, but
                #        which now need to be ungrouped.
                #   2.   It could be something of the form
                #            ( ... )(n)
                #        where n is a number.  This means to use just the n-th
                #        item in the list ( ... )
                pass
        if c == '&':
            ampStart = j
            continue
        
        if inQuote:
            if c != "'":
                if lastWasInternalQuote:
                    inQuote = False
                    lastWasInternalQuote = False
                    # *no* continue!  Want to fall through.
                else:
                    continue
            else:
                lastWasInternalQuote = not lastWasInternalQuote
                continue
        # To get here, we're definitely not inside of a quote.
        if c == "'":
            inQuote = True
            lastWasInternalQuote = False
            continue
        if c == '(':
            parenthesisDepth += 1
            continue
        if c == ')':
            parenthesisDepth -= 1
            if parenthesisDepth < 0:
                error(properties, "Mismatched parentheses")
                return skipped
            continue
        if parenthesisDepth > 0:
            continue
        if c == ',':
            subOperands.append(currentSubParm[:-1])
            currentSubParm = ""
            continue
        if c != " ":
            continue
        # If We've gotten here, we've encountered a space.  What to do about
        # it depends on whether the alternate format is a possibility or not.
        if currentSubParm == "":
            # We could only get to here if the last sub-operand added had 
            # ended in a comma:
            if alternate and currentProperties["continues"]:
                # discard the rest of the card and go to the next one
                j = len(text)
                continue
            subOperands.append(currentSubParm[:-1])
            currentSubParm = ""
            break
        break
    if currentSubParm != "":
        subOperands.append(currentSubParm[:-1])
    '''
    if not inMacroDefinition:
        for i in range(len(subOperands)):
            subOperands[i] = replaceMacroVariables(subOperands[i], svLocals)
    '''
    return skipped, inMacroDefinition, inMacroProto

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
#    depth       The depth into the macro expansion(s).  0 is for not an 
#                expansion.
source = []
libraries = []
def readSourceFile(fromWhere, expansion, copy=False, printable=True, depth=0):
    global source, macros, svGlobals
    svLocals = { }
    lineNumber = -1
    inMacroProto = False
    inMacroDefinition = False
    continuation = False
    name = ""
    operation = ""
    prototypeIndex = -1
    
    if fromWhere in macros:
        # Load the macro definition into the list of source-code lines.
        thisSource = []
        prototypeIndex = macros[fromWhere][3] - macros[fromWhere][2]
        for i in range(macros[fromWhere][2], macros[fromWhere][4] + 1):
            thisSource.append(source[i]["text"])
        if False:
            print("***DEBUG*** A", fromWhere, expansion, copy, printable)
            for line in thisSource:
                print("***DEBUG*** B", line)
            sys.exit(1)
    else:
        try:
            f = open(fromWhere, "rt")
            thisSource = f.readlines()
            f.close()
            filename = fromWhere
        except:
            print("Source file '%s' does not exist" % fromWhere, \
                  file=sys.stderr)
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
            "continues": (line[71] != " "),
            "identification": line[72:],
            "empty": (text.strip() == ""),
            "fullComment": line.startswith("*"),
            "dotComment": line.startswith(".*"),
            "name": "",
            "operation": "",
            "operandAndComment": "",  # Really worthless, I think.
            "operand": [],
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
        if properties["empty"] or properties["fullComment"] or \
                properties["dotComment"]:
            continue
        if len(source) >1 and source[-2]["continues"]:
            continue
        
        # Note that while `parseSubOperations` determines how 
        # `inMacroDefinition` and `inMacroProto` will change, and returns
        # new values as dummy1 and dummy1, we ignore those return values here
        # and make our own determination, because we want to do some things
        # with macro definitions that `parseLine` doesn't do for us.
        skipCount, dummy1, dummy2 = parseLine(thisSource, lineNumber, \
                                              inMacroDefinition, \
                                              inMacroProto, svLocals)
        name = properties["name"]
        operation = properties["operation"]
        operand = properties["operand"]
        
        if operation == "MACRO":
            
            inMacroProto = True
            inMacroDefinition = True
            macroStart = len(source) - 1
            properties["inMacroDefinition"] = True
        elif inMacroProto:
            inMacroProto = False
            # This line gives us the "prototype" of the macro.
            # We need to determine the name, the number of positional parameters,
            # and the number of nonpositional parameters.
            positional = 0
            nonpositional = 0
            for sub in operand:
                if "=" in sub:
                    nonpositional += 1
                else:
                    positional += 1
            macroName = operation
            macros[macroName] = [positional, positional + nonpositional, 
                                 macroStart, len(source)-1]
        elif operation == "MEND":
                macros[macroName].append(len(source)-1)
                inMacroDefinition = False
                continue
        elif operation == "COPY":
            found = False
            for library in libraries:
                fcopy = os.path.join(library, fields[1] + ".asm")
                if os.path.exists(fcopy) and os.path.isfile(fcopy):
                    found = True
                    readSourceFile(fcopy, expansion, True)
                    break
            if not found:
                print("File %s.asm for COPY not found" % fields[1], \
                      file=sys.stderr)
                sys.exit(1)
            continue
        
        if inMacroDefinition:
            continue
        
        # Is this a macro invocation that we must expand?
        if operation in macros:
            macrostats = macros[operation]
            # The replacement parameters are in properties["operand"]
            # But we need to track down the formal parameters.
            formal = source[macrostats[3]]["operand"]
            replacements = properties["operand"]
            if False:
                print("***DEBUG*** Expand " + operation)
                print(operand)
                print(formal)
            # Relate the formal parameters to their replacments.  That'll be
            # the dictionary `newExpansion`.
            # First take care of the positional parameters.  Put the 
            # non-positional ones in nonPositonalF,R for later.
            newExpansion = {}
            nonPositionalF = {}
            nonPositionalR = {}
            iRep = 0 # Next replacement parameter
            for parm in formal:
                if "=" in parm:
                    fields = parm.split("=", 1)
                    nonPositionalF[fields[0]] = fields[1]
                    continue
                newExpansion[parm] = "" # Default
                while iRep < len(replacements) and "=" in replacements[iRep]:
                    fields = replacements[iRep].split("=", 1)
                    nonPositionalR["&" + fields[0]] = fields[1]
                    iRep += 1
                if iRep < len(replacements):
                    newExpansion[parm] = replacements[iRep]
                    iRep += 1
            while iRep < len(replacements) and "=" in replacements[iRep]:
                fields = replacements[iRep].split("=", 1)
                nonPositionalR["&" + fields[0]] = fields[1]
                iRep += 1
            # Now the non-positional parameters.
            for parm in nonPositionalF:
                if parm in nonPositionalR:
                    newExpansion[parm] = nonPositionalR[parm]
                else:
                    newExpansion[parm] = nonPositionalF[parm]
            for parm in nonPositionalR:
                if parm not in nonPositionalF:
                    error(properties, "Unknown non-positional parameter %s" % parm)
            readSourceFile(operation, newExpansion, copy, printable, depth+1)
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
    elif parm in ["--101", "--390"]:
        pass  # Already processed with the imports.
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
        print("--101               (Default.) Source code is IBM AP-101B or")
        print("                    AP-101S.")
        print("--390               Source code is IBM System/390. (This is not")
        print("                    supported at the present time.)")
        print()
        sys.exit(1)
    else:
        print("Unrecognized parameter '%s'" % parm, file=sys.stderr)
        sys.exit(1)
if sourceFileCount == 0:
    print("No source-code files were specified", file=sys.stderr)
    sys.exit(1)

#=============================================================================
# Code generation.

# At this point, all of the lines of source code have been read in, and macros
# expanded.  All of the source-code lines so-obtained have been parsed into 
# their appropriate fields:  name, operation, and operand, and operand has been 
# further parsed into a list of sub-operands.  However, none of these things 
# have been parsed or evaluated beyond whatever was needed for the macro 
# expansions or splitting the operand field into sub-operands.  For example,
# while we know what's in the name field, we don't know if it's a valid symbol
# name or not.
if len(source) > 0 and source[-1]["inMacroDefinition"]:
    errorCount += 1
if errorCount > 0:
    print("%d error(s) detected.  Assembly aborted.  Fix the syntax errors" % \
          errorCount)
    print("marked below and retry.  Search for =========.")
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
    print("%d error(s) detected.  Assembly aborted.  Fix the syntax errors" % \
          errorCount)
    print("marked above and retry.  Search for =========.")
    sys.exit(1)

if True: #***DEBUG***
    inCopy = False
    memberName = ""
    # I don't really know how to get rvl/concat/nest, so it's just 0/0/0 for now
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
            if property["dotComment"]:
                pass
            elif property["empty"] or property["fullComment"] or property["inMacroDefinition"]:
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
    
    if False:
        a = macros["AMAIN"]
        print("***DEBUG***", a)
        print(source[a[2]])
        print(source[a[3]])
        print(source[a[4]])
