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

program = "ASM101S"
version = "0.00"

import sys
import os
from pathlib import Path
from datetime import datetime
from fieldParser import *
from expressions import *
from readListing import *

currentDate = datetime.today().strftime('%m/%d/%y')
svGlobals["_passCount"] = -1

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
        error("Incorrect symbol expression")
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
#    The index of the first line of the macro-definition file in `source`.
macros = { }
# Sequence symbols for the global-local scope.
sequenceGlobalLocals = { }

# The `parseLine` function parses an input card (namely `lines[lineNumber]`) 
# into `name`, `operation`, and `operation`.
# It does not try to determine validity (except to the extent necessary for 
# parsing) nor to evaluate any expressions.  It takes into account continuation
# cards, macro definitions (without expanding them), and the alternate 
# continuation format sometimes used for macro arguments 
# and macro formal parameters.  It takes into account parenthesization and 
# quoted strings (and their attendant spaces) within sub-operands.  The return 
# is the number of contiuation lines processed.
# Lines in macro definitions are not parsed beyond their prototypes; that's 
# done only during expansion.
def parseLine(lines, lineNumber, inMacroDefinition, inMacroProto):
    global source
    alternate = inMacroProto
    skipped = 0
    properties = source[-1]
    properties["operand"] = None
    if properties["empty"] or properties["fullComment"] or \
            properties["dotComment"]:
        return 0
    text = properties["text"]
    # Parse all fields prior to the operand, at least enough to determine the
    # contents if not the validity.
    j = 0
    while j < len(text) and text[j] != " ":  # Scan past the label, if any.
        j += 1
    name = text[:j]
    properties["name"] = name
    while j < len(text) and text[j] == " ":  # Scan up to operation
        j += 1
    k = j
    while j < len(text) and text[j] != " ":  # Scan past the operation.
        j += 1
    operation = text[k:j]
    properties["operation"] = operation
    if operation in macros:
        alternate = True
    if operation == "MACRO":
        if inMacroDefinition:
            error(properties, "Nested MACRO definitions")
        return 0
    if operation == "MEND":
        if not inMacroDefinition:
            error(properties, "MEND without preceding MACRO")
        return 0
    if inMacroDefinition and not inMacroProto:
        return 0
    while j < len(text) and text[j] == " ":  # Scan up to operand/comment
        j += 1
    
    # At this point, we determine the full operand field, after accounting for
    # continuation lines, end-of-line comments, and the "alternate" format
    # for continuations which can optionally be used for macro-prototype and
    # macro-invocation lines.  No replacements of symbolice variables, nor
    # expansion of macros, has yet been performed or will be performed here.
    operand = ""
    if operation == "QCED": ###DEBUG###
        pass
        pass
    if inMacroProto:
        inMacroProto = False
        success, field, skipped = joinOperand(lines, lineNumber, j, proto=True)
        if success:
            operand = field
        else:
            error(properties, "Cannot parse macro-prototype cards")
    elif operation in macros:
        success, field, skipped = joinOperand(lines, lineNumber, j, invoke=True)
        if success:
            operand = field
        else:
            error(properties, "Cannot parse macro-invocation operands")
    elif operation in instructionsWithoutOperands:
        pass
    elif operation in pseudoOps and pseudoOps[operation][0] == 0:
        pass
    else:
        # Operation has operands, subject to continuation lines and end-of-line
        # comments, but not to the "alternate" form of continuation lines.
        success, field, skipped = joinOperand(lines, lineNumber, j)
        if success:
            operand = field
        else:
            error(properties, "Cannot parse macro-invocation operands")
    properties["operand"] = operand
    
    return skipped

# Tries to evaluate suboperand in a macro invocation, as returned by
# `parserASM(...,"operandInvocation")`.  I don't have any full theory as to
# what the parser should return for these, so I'm just adding cases into the
# code as I encounter them.  What's returned is an ordered pair,
#    key, value
# where `key` is the formal parameter (such as "&A") in the case of 
# non-positional parameters (such as `A=53`) and `None` in case of positional
# parameters.  The `value` is a tuple of replacement strings, generally of
# consisting of only a single element.  However, if the replacement is a 
# list, then the tuple with have as many element (all of them strings).
def evalMacroArgument(properties, suboperand):
    # This is the case of a positional parameter that's just a bare, 
    # unquoted string.
    if isinstance(suboperand, str): 
        return None,suboperand
    # This is the case of a non-positional parameter that's just a bare,
    # unquoted string.
    elif isinstance(suboperand, (list,tuple)) and len(suboperand) == 3  \
            and suboperand[1] == "=" and \
            isinstance(suboperand[2], str):
        return ("&" + suboperand[0]),suboperand[2]
    # Non-positional parameter that's a list.
    elif isinstance(suboperand, (list, tuple)) and len(suboperand) == 5 and \
            suboperand[1] == "=" and suboperand[2] == "(" and \
            isinstance(suboperand[3], tuple) and suboperand[4] == ")":
        parmName = "&" + suboperand[0]
        replacementList = []
        if len(suboperand[3]) > 0:
            replacementList.append(suboperand[3][0])
            if len(suboperand[3]) > 1:
                for e in suboperand[3][1]:
                    replacementList.append(e[1])
            return parmName,tuple(replacementList)
    # This is the case of a positional parameter that's a quoted string.
    elif isinstance(suboperand, tuple) and \
            len(suboperand) == 4 and \
            suboperand[0] == "'" and suboperand[3] == "'" and \
            suboperand[2] == [] and \
            isinstance(suboperand[1], str):
        return None,("'" + suboperand[1] + "'")
    # This is the case of a positional parameter being a list, such as
    #    (1,2,A).
    elif isinstance(suboperand, tuple) and len(suboperand) == 3 and \
            suboperand[0] == '(' and suboperand[2] == ')' and \
            isinstance(suboperand[1], tuple):
        replacementList = []
        if len(suboperand[1]) > 0:
            replacementList.append(suboperand[1][0])
            if len(suboperand[1]) > 1:
                for e in suboperand[1][1]:
                    replacementList.append(e[1])
            return None,tuple(replacementList)
    else:
        # There are some replacements, like "4(R3)" that will parses as a
        # tuple of strings, such as (for the example just given)
        # ( '4', '(', 'R3', ')' ).
        try:
            s = "".join(suboperand)
            return None,s
        except:
            pass
        # Don't know what this is.  Could be a coding error, but probably just
        # something I haven't implemented yet.
        error(properties, \
               "Implementation error in replacement argument " + \
               str(suboperand))
        return None,None

# See also the comments about `svGlobals` in the module expressions.py.
# Recursively read a batch of lines of source code, expanding if necessary for 
# `COPY` pseudo-op or invocation of a macro.  The parameters:
#    fromWhere   Either a filename or the name of a macro.  The latter lets 
#                us read in all of the macro definitions at startup, and then 
#                reuse the definitionas as many times as we like without 
#                rereading the file that contained them.
#    svLocals    See below.
#    sequence    A dictionary of sequence symbols encountered, and the 
#                line number at which they start.
#    copy        Indicates that the file is being read as the target of a 
#                `COPY` pseudo-op.
#    printable   Indicates that the file will be listed in the output assembly
#                listing.  Would be False for anything read from the macro
#                library.
#    depth       The depth into the macro expansion(s).  0 is for not an 
#                expansion.
# `svLocals` is similar to the global dictionary `svGlobals` in that it gives
# the symbolic variables that are "local" to a macro invocation rather than the
# symbolic variables accessible globally.  Initially, the only local variables
# are the replacement values for the macro's formal parameters, but LCLx and
# SETx instructions within the macro itself can alter that throughout the 
# macro expansion.  
source = []
libraries = []
metadata = {} # Metadata for the assembly, such as the TTILE.
sysndx = -1
def readSourceFile(fromWhere, svLocals, sequence, \
                   copy=False, printable=True, depth=0):
    global source, macros, svGlobals, metadata, sysndx
    lineNumber = -1
    firstIndexOfFile = len(source)
    inMacroProto = False
    inMacroDefinition = False
    continuation = False
    name = ""
    operation = ""
    prototypeIndex = -1
    continuePrototype = False
    lineCorrespondence = [] # How `thisSource` line numbers match to files.
    
    if fromWhere in macros:
        # Load the macro definition into the list of source-code lines.
        filename = None
        macroname = fromWhere
        macroWhere = macros[macroname]
        thisSource = []
        sequence = {}
        prototypeIndex = macroWhere[3] - macroWhere[2]
        for i in range(macroWhere[2], macroWhere[4] + 1):
            if i == macroWhere[2]:
                continue
            if i == macroWhere[3]:
                if source[i]["continues"]:
                    continuePrototype = True
                continue
            if i == macroWhere[4]:
                continue
            if continuePrototype:
                if not source[i]["continues"]:
                    continuePrototype = False
                continue
            
            if source[i]["continues"]:
                suffix = "X"
            else:
                suffix = " "
            thisSource.append(source[i]["text"] + suffix)
            lineCorrespondence.append(i - macroWhere[5])
    else:
        try:
            f = open(fromWhere, "rt")
            thisSource = f.readlines()
            f.close()
            for i in range(len(thisSource)):
                lineCorrespondence.append(i)
            filename = fromWhere
            macroname = None
        except:
            print("Source file '%s' does not exist" % fromWhere, \
                  file=sys.stderr)
            sys.exit(1)
    
    skipCount = 0
    lineNumber = -1
    skipToSeq = None
    while lineNumber + 1 < len(thisSource):
        lineNumber += 1
        line = thisSource[lineNumber]
        if skipToSeq != None and not line.startswith(skipToSeq + " "):
            continue
        skipToSeq = None
        
        line = "%-80s" % line.rstrip()[:80]
        text = line[:71]
        properties = {
            "section": None,
            "pos1": None,
            "length": None,
            "alignment": 2,
            "text": text,
            "name": "",
            "operation": "",
            "operand": "",
            "file": filename,
            "macro": macroname,
            "lineNumber": lineNumber + 1,
            "continues": (line[71] != " "),
            "identification": line[72:],
            "empty": (text.strip() == ""),
            "fullComment": line.startswith("*"),
            "dotComment": line.startswith(".*"),
            "endComment": "",
            "errors": [],
            "inMacroDefinition": inMacroDefinition,
            "copy": copy,
            "printable": printable,
            "depth": depth,
            "n": len(source)
            }
        source.append(properties)
        if skipCount > 0:
            skipCount -= 1
            properties["skip"] = True
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
        skipCount = parseLine(thisSource, lineNumber, \
                              inMacroDefinition, inMacroProto)
        name = properties["name"]
        if name[:1] == ".":
            # Note that the `fromWhere` stored in the symbol *should* be 
            # completely irrelevant to anything and shouldn't be used.  I think.
            sequence[name] = (fromWhere, lineNumber)
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
                macros[macroName].append(firstIndexOfFile)
                inMacroDefinition = False
                continue
        elif operation == "COPY":
            found = False
            for library in libraries:
                if line[0] == " ":
                    fname = line.split()[1]
                else:
                    fname = line.split()[2]
                fcopy = os.path.join(library, fname + ".asm")
                if os.path.exists(fcopy) and os.path.isfile(fcopy):
                    found = True
                    readSourceFile(fcopy, svLocals, sequence, copy=True, \
                                   printable=printable, depth=depth)
                    break
            if not found:
                print("File %s.asm for COPY not found" % fields[1], \
                      file=sys.stderr)
                sys.exit(1)
            continue
        
        if inMacroDefinition:
            continue
        
        # Take care of various macro-language related pseudo-ops.
        if operation == "MEXIT":
            break
        if operation in { "GBLA", "GBLB", "GBLC", "LCLA", "LCLB", "LCLC"}:
            svDeclare(operation, operand, svLocals, properties)
            continue
        # Take care of pseudo-ops like `SETA`, `SETB`, `SETC`
        if operation in { "SETA", "SETB", "SETC" }:
            svSet(operation, name, operand, svLocals, properties)
            continue
        if  operation == "AGO":
            target = operand.rstrip()
            if target in sequence:
                if fromWhere != sequence[target][0]:
                    error(properties, "Target out of this macro")
                    continue
                lineNumber = sequence[target][1] - 1
            else:
                skipToSeq = target
            continue
        if operation == "AIF":
            operand = operand.rstrip()
            ast = parserASM(operand, "aifAll")
            if isinstance(ast, tuple) and len(ast) == 4 and \
                    ast[0] == '(' and ast[2] == ')':
                target = ast[3]
                expression = ast[1]
                passFail = evalBooleanExpression(expression, svLocals, properties)
                if passFail == None:
                    error(properties, "Cannot evaluate %s" % str(expression))
                    continue
                if not passFail:
                    continue
                # The conditional test has passed.  We must now "go to" the
                # selected sequence symbol
                #print("***DEBUG***")
                if target in sequence:
                    if fromWhere != sequence[target][0]:
                        error(properties, "Target out of this macro")
                        continue
                    lineNumber = sequence[target][1] - 1
                else:
                    skipToSeq = target
                continue
            else:
                error(properties, "Unrecognized AIF operand: " + operand)
            continue
        if operation == "ANOP":
            continue
        if operation == "MNOTE":
            ast = parserASM(operand, "mnote")
            if ast == None:
                error(properties, "Cannot parse MNOTE: " + operand)
            else:
                msg = unroll(ast["msg"])[1]
                msg = svReplace(properties, msg, svLocals)
                if "com" in ast:
                    pass
                elif "sev" in ast:
                    error(properties, msg, severity = int(ast["sev"][0]))
                else: 
                    error(properties, msg, severity = 1)
                properties["fullComment"] = True
                properties["text"] = msg
                properties["name"] = ""
                properties["operation"] = ""
                properties["operand"] = ""
                properties["mnote"] = True
            continue
        
        # Symbolic-variable replacement
        if "&" in line:
            properties["rawName"] = name
            properties["rawOperation"] = operation
            properties["rawOperand"] = operand
            name = svReplace(properties, name, svLocals)
            operation = svReplace(properties, operation, svLocals)
            operand = svReplace(properties, operand, svLocals)
            properties["name"] = name
            properties["operation"] = operation
            properties["operand"] = operand
        
        if name != "" and name[:1] not in [".", "&"] and \
                operation not in ["TITLE", "CSECT", "DSECT"] \
                and operation not in macros:
            if name not in definedNormalSymbols:
                definedNormalSymbols[name] = { "label": True,
                                               "fromWhere": fromWhere,
                                               "lineNumber": lineNumber,
                                               "fromLine": lineCorrespondence[lineNumber]
                                             }
            else:
                error(properties, "Already defined: " + name)
        elif operation == "EXTRN":
            #print("I am here")
            symbols = operand.split(",")
            for symbol in symbols:
                if symbol not in definedNormalSymbols:
                    definedNormalSymbols[symbol] = { "label": True,
                                                   "fromWhere": fromWhere,
                                                   "lineNumber": lineNumber,
                                                   "fromLine": lineCorrespondence[lineNumber]
                                                 }
        
        if operation in macros:
            sysndx += 1
            macrostats = macros[operation]
            # The replacement parameters are in properties["operand"]
            # But we need to track down the formal parameters.
            formals = source[macrostats[3]]["operand"]
            pformals = parserASM(formals, "operandPrototype")
            if operand.strip() == "":
                poperands = []
            else:
                poperands = parserASM(operand, "operandInvocation")
            if isinstance(poperands, dict) and "pi" in poperands:
                poperands = poperands["pi"]
            else:
                poperands = []
            if isinstance(pformals, dict) and "pi" in pformals:
                pformals = pformals["pi"]
            else:
                pformals = []
            #print(("***DEBUG*** Expand(%d) " % depth) + operation)
            #print(poperands)
            #print(pformals)
            # Relate the formal parameters to their replacements.  That'll be
            # the dictionary `newLocals`.
            newLocals = { 
                "parent": [fromWhere, lineNumber, lineCorrespondence[lineNumber], svLocals] 
                }
            fname = source[macrostats[3]]["name"]
            if fname != "":
                newLocals[fname] = name
            # First fill in all default values.
            syslist0 = name
            syslist = []
            for i in range(len(pformals) - 1, -1, -1):
                pformal = pformals[i]
                if isinstance(pformal, str):
                    newLocals[pformal] = ''
                    newLocals["_" + pformal] = { "omitted": True }
                elif isinstance(pformal, (list,tuple)):
                    if len(pformal) != 3 or pformal[1] != "=" or \
                            pformal[0][:1] != "&" or \
                            not isinstance(pformal[2], str):
                        error(properties, \
                               "Unrecognized format for formal parameter " + \
                               str(pformal))
                        continue
                    newLocals[pformal[0]] = pformal[2]
                    newLocals["_" + pformal[0]] = { "omitted": True }
                    del pformals[i]
                else:
                    error(properties, \
                           "Implementation error in formal parameter " + \
                           str(pformal))
                    continue
            # Now do the replacements:
            i = 0
            for suboperand in poperands:
                key, value = evalMacroArgument(properties, suboperand)
                if key == None:
                    syslist.append(value)
                    if i >= len(pformals):
                        # This can happen when there's a comment but no 
                        # positional replacement arguments in a macro invocation
                        # and the first word of the comment has been parsed
                        # as the operand field; ignore it, it's harmless.
                        # I think.
                        continue
                    newLocals[pformals[i]] = value
                    newLocals["_" + pformals[i]]["omitted"] = False
                    i += 1
                else:
                    newLocals[key] = value
                    newLocals["_" + key]["omitted"] = False
            newLocals["&SYSLIST"] = syslist
            newLocals["&SYSLIST0"] = syslist0
            newLocals["&SYSNDX"] = sysndx
            readSourceFile(operation, newLocals, sequence, copy=copy, \
                           printable=printable, depth=depth+1)
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
        readSourceFile(path, svGlobalLocals, sequenceGlobalLocals, \
                       copy=False, printable=False, depth=0)

if False:
    for macro in sorted(macros):
        print(macro, macros[macro])
    sys.exit(1)

#=============================================================================
# Parse the command-line options.
objectFileName = None
sourceFileCount = 0
tolerableSeverity = 1
svGlobals["&SYSPARM"] = "PASS"
endLibraries = 0 # First line in `source` following macro-library definitions.
comparisonSects = None
comparisonFile = None
sourceFileNames = []

for parm in sys.argv[1:]:
    if parm.startswith("--library="):
        readMacroLibrary(parm[10:])
        endLibraries = len(source)
    elif parm.startswith("--object="):
        if not parm.endswith(".obj"):
            print("Object-code filenames must end in .obj", file=sys.stderr)
            sys.exit(1)
        objectFileName = parm[8:]
    elif parm.startswith("--sysparm="):
        svGlobals["&SYSPARM"] = parm[10:]
    elif parm.startswith("--tolerable="):
        tolerableSeverity = int(parm[12:])
    elif parm.startswith("--compare="):
        comparisonFile = parm[10:]
        comparisonSects = readListing(comparisonFile)
        if comparisonSects == None:
            print("Could not load comparison file %s" % parm[10:], file=sys.stderr)
            sys.exit(1)
    elif not parm.startswith("--"):
        if not parm.endswith(".asm"):
            print("Source-code filenames must end with .asm", file=sys.stderr)
            sys.exit(1)
        sourceFileNames.append(parm[:-4])
        if objectFileName == None:
            objectFileName == parm[:-4] + ".obj"
        readSourceFile(parm, svGlobalLocals, sequenceGlobalLocals, \
                       copy=False, printable=True, depth=0)
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
        print("--sysparm=T         (Default PASS.) Sets the global SET symbol")
        print("                    &SYSPARM. For Space Shuttle flight software,")
        print("                    the allowed choices are BFS and PASS.")
        print("--tolerable=N       (Default 1.) Sets the maximumn tolerable")
        print("                    error severity.  All errors detected by")
        print("                    ASM101S itself are severity 255. Errors")
        print("                    reported by MNOTE instructions have a")
        print("                    severity determined by the MNOTE instruction")
        print("                    (i.e., by the source code itself), but")
        print("                    level 1 seems to be used for info messages.")
        print("--compare=F         (Default none.) Specifies the name of an")
        print("                    assembly-listing file whose generated code")
        print("                    is compared to the current assembly.")
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
metadata = generateObjectCode(source, macros)

#=============================================================================
# Print an alternate form of the assembly listing when severe-enough errors have
# been detected.  this form is more helpful in terms of tracking how macros
# are expanded and how the values of symbolic variables evolve.

# At this point, all of the lines of source code have been read in, and macros
# expanded.  All of the source-code lines so-obtained have been parsed into 
# their appropriate fields:  name, operation, and operand, and operand has been 
# further parsed into a list of sub-operands.  However, none of these things 
# have been parsed or evaluated beyond whatever was needed for the macro 
# expansions or splitting the operand field into sub-operands.  For example,
# while we know what's in the name field, we don't know if it's a valid symbol
# name or not.
errorCount, maxSeverity = getErrorCount()
if len(source) > 0 and source[-1]["inMacroDefinition"]:
    errorCount += 1
    maxSeverity = 255
if maxSeverity > tolerableSeverity:
    print("Assembly aborted due to intolerable errors. %d total error(s) detected." % errorCount)
    print("Fix any intolerable errors marked below and retry.  Search for 'Severity'.")
    print()
    lastError = False
    intolerables = 0
    for i in range(len(source)):
        line = source[i]
        if line["depth"] > 0:
            depthStar = "+"
        else:
            depthStar = ' '
        if len(line["errors"]) == 0:
            print("%5d: %s   %s" % (i, depthStar, line["text"]))
            lastError = False
        else:
            if not lastError:
                print("=====================================================")
            anyIntolerable = False
            for msg in line["errors"]:
                fields = msg.split(")")[0].split()
                if int(fields[-1]) > tolerableSeverity:
                    anyIntolerable = True
                print(msg)
            if anyIntolerable:
                intolerables += 1
            print("%5d: %s   %s" % (i, depthStar, line["text"]))
            print("=====================================================")
            lastError = True
    if len(source) > 0 and source[-1]["inMacroDefinition"]:
        print("No closing MEND for MACRO")
    print("Assembly aborted. Fix the errors or use --tolerable=N to adjust tolerance.")
    print("Search for 'Severity' to find the marked errors, tolerated or otherwise.")
    print("%s: %d intolerable line(s) detected, %d < severity < %d." % \
          (",".join(sourceFileNames), intolerables, tolerableSeverity, 1 + maxSeverity))
    sys.exit(1)

#==============================================================================
# Print the regular form of the assembly listing.

# "Instructions" in the macro language by default  aren't printed in the 
# assembly report.
macroLanguageInstructions = { "GBLA", "GBLB", "GBLC", "LCLA", "LCLB",
                              "LCLC", "SETA", "SETB", "SETC", "AIF",
                              "AGO", "ANOP", "SPACE", "MEXIT", "MNOTE" }
inCopy = False
memberName = ""
# I don't really know how to get rvl/concat/nest, so it's just 0/0/0 for now
rvl = 0
concat = 0
nest = 0
printedLineNumber = 0
firstLineOnPage = 1
pageNumber = 0
linesPerPage = 80
linesThisPage = 1000
mismatchCount = 0
pageSeparator = "\f%s" % ('-'*120)

title = "EXTERNAL SYMBOL DICTIONARY".center(100)
subtitle = "%-95s" % "SYMBOL   TYPE  ID  ADDR  LENGTH  LD ID" \
           + "%16s %s" % (program + " " + version, currentDate)
id = 0
ids = {}
for symbol in symtab:
    if symbol.startswith("_"):
        continue
    entry = symtab[symbol]
    ldId = "    "
    if entry["type"] == "CSECT" and not entry["dsect"]:
        moduleType = "SD"
        id += 1
        ids[symbol] = id
        pid = "%04d" % id
    elif "entry" in entry:
        moduleType = "LD"
        pid = "    "
        ldId = "%04X" % ids[entry["section"]]
    elif entry["type"] == "EXTERNAL":
        moduleType = "ER"
        id += 1
        ids[symbol] = id
        pid = "%04d" % id
        
    else:
        continue
    address = "      "
    if "address" in entry:
        address = entry["address"]
        if "preliminaryOffset" in entry:
            address += entry["preliminaryOffset"]
        address = "%06X" % address
    length = "      "
    if symbol in sects:
        length = "%06X" % ((sects[symbol]["used"] + 1) // 2)
    if linesThisPage >= linesPerPage:
        pageNumber += 1
        if pageNumber > 1:
            print(pageSeparator)
        print("         %-100s  PAGE %4d" % (title, pageNumber))
        print(subtitle)
        linesThisPage = 0
    print(("%-10s%-3s%-5s%-7s%-7s%s" % (symbol, moduleType, pid, address, length, ldId)).rstrip())
    linesThisPage += 1

title = ""
subtitle = ""
literalPoolNumber = 0
continuation = False
for i in range(endLibraries, len(source)):
    properties = source[i]
    skip = False
    if properties["empty"]:
        continue
    if continuation:
        continuation = properties["continues"]
        linesThisPage += 1
        continue
    continuation = properties["continues"]
    if properties["operation"] == "SPACE":
        space = 1 # Actually depends on the operand.
        printedLineNumber += space
        properties["printedLineNumber"] = printedLineNumber
        linesThisPage += space
    elif properties["operation"] == "TITLE":
        title = properties["operand"].rstrip()[1:-1]
        subtitle = "%-95s" % "  LOC  OBJECT CODE   ADR1 ADR2      SOURCE STATEMENT" \
                   + "%16s %s" % (program + " " + version, currentDate)
        printedLineNumber += 1
        properties["printedLineNumber"] = printedLineNumber
        linesThisPage = 1000
        skip = True
    if linesThisPage >= linesPerPage:
        pageNumber += 1
        if pageNumber > 1:
            print(pageSeparator)
        print("         %-100s  PAGE %4d" % (title, pageNumber))
        print(subtitle)
        linesThisPage = 0
        if skip:
            continue
    if properties["depth"] > 0:
        depthStar = "+"
    else:
        depthStar = ' '
    if properties["operation"] in macroLanguageInstructions:
        continue
    if properties["fullComment"] and properties["text"].startswith("*/"):
        continue # "Modern" comment
    if properties["copy"]:
        if not inCopy:
            memberName = Path(properties["file"]).stem
            if properties["printable"]:
                linesThisPage += 1
                print("         START OF COPY MEMBER %-8s RVL %02d CONCATENATION NO. %03d  NEST %03d" \
                      % (memberName, rvl, concat, nest))
            inCopy = True
    else:
        if inCopy:
            if properties["printable"]:
                linesThisPage += 1
                print("           END OF COPY MEMBER %-8s RVL %02d CONCATENATION NO. %03d  NEST %03d" \
                      % (memberName, rvl, concat, nest))
            inCopy = False
    if properties["printable"]:
        address = None
        section = None
        comparisonMemory = None
        prefix = ""
        if "section" in properties and properties["section"] in sects \
                and "offset" in sects[properties["section"]]:
            offset = sects[properties["section"]]["offset"]
        else:
            offset = 0
        if properties["operation"] == "EQU":
            prefix = "%07X" % (symtab[properties["name"]]["value"] & 0xFFFFFFF)
        elif properties["operation"] == "USING":
            prefix = "%07X" % properties["using"]
        elif properties["operation"] == "LTORG":
            pass
        elif "pos1" in properties and properties["pos1"] != None:
            address = properties["pos1"]
            section = properties["section"]
            if comparisonSects != None and section in comparisonSects:
                comparisonMemory = comparisonSects[section]["memory"]
            paddress = address // 2
            if section == None: ###DEBUG###
                pass
            if "offset" in sects[section]:
                paddress += offset
            prefix = "%05X" % paddress
        if "assembled" in properties:
            for i in range(min(8, len(properties["assembled"]))):
                b = properties["assembled"][i]
                if comparisonMemory != None:
                    oaddress = address + offset * 2
                    if b != comparisonMemory[oaddress]:
                        mismatchCount += 1
                        try:
                            print("Comparison mismatch: %02X vs %02X" % \
                                  (b, comparisonMemory[oaddress]))
                        except:
                            print("Comparison mismatch: %02X vs unassigned" % b)
                    comparisonMemory[oaddress] = None
                    address += 1
                if i == 0 or ((i & 1) == 0 and properties["operation"] != "DC"):
                    prefix += " "
                prefix += "%02X" % b
        if "adr1" in properties:
            prefix = "%-21s%04X" % (prefix, properties["adr1"])
        if "adr2" in properties:
            prefix = "%-26s%04X" % (prefix, properties["adr2"])
        # For whatever reason, a macro-invocation line is printed only under
        # some circumstances, and is omitted in others.
        if properties["operation"] == "INPUT": ###DEBUG###TRAP###
            pass
        if properties["operation"] in macros and not properties["inMacroDefinition"]:
            macroWhere = macros[properties["operation"]]
            if macroWhere[2] > endLibraries:
                continue
        if properties["operation"] in macros and properties["depth"] > 0:
            continue
        if properties["depth"] == 0:
            identification = properties["identification"][:8]
        else:
            identification = "%02d-" % properties["depth"]
            suffix = ""
            if properties["macro"] != None:
                suffix = properties["macro"]
            identification = identification + suffix[:5]
        if properties["dotComment"]:
            pass
        elif properties["fullComment"] or properties["inMacroDefinition"]:
            printedLineNumber += 1
            properties["printedLineNumber"] = printedLineNumber
            linesThisPage += 1
            if identification.strip() == "" or \
                    (properties["fullComment"] and depthStar != " " and \
                     "mnote" not in properties):
                print("%-30s%5d%s%s" % (prefix, printedLineNumber, 
                                              depthStar, properties["text"].rstrip()))
            else:
                print("%-30s%5d%s%-71s %s" % (prefix, printedLineNumber, 
                                              depthStar, properties["text"], 
                                              identification))
        elif properties["operation"] == "":
            continue
        else:
            name = properties["name"]
            if name.startswith("."):
                name = ""
            printedLineNumber += 1
            properties["printedLineNumber"] = printedLineNumber
            linesThisPage += 1
            mid = "%-30s%5d%s%-8s %-5s %s" % (
                prefix,
                printedLineNumber,
                depthStar,
                name, 
                properties["operation"],
                str(properties["operand"]).rstrip())
            print("%-108s%s" % (mid, identification))
        if properties["operation"] == "LTORG":
            pool = literalPools[literalPoolNumber]
            reordered = {}
            for i in range(len(emptyPool), len(pool)):
                offset = pool[1] + pool[3][i]
                reordered[offset // 2] = pool[i]
            for i in sorted(reordered):
                prefix = "%05X " % i
                attributes = reordered[i]
                bytes = attributes["assembled"]
                for j in range(attributes["L"]):
                    prefix += "%02X" % bytes[j]
                prefix = "%-50s" % prefix[:30]
                print(prefix, attributes["operand"])
            literalPoolNumber += 1

def toEbcdic(s):
    converted = ""
    for c in s:
        converted += "%02X" % asciiToEbcdic[ord(c)]
    return converted

# A peculiar collation for sorting the symbol table on the printout.  It's
# not EBCDIC, nor ASCII.  The alphanumeric ordering seems normal, but the
# other "letters" (#, @, $) follow the alphanumerics (or at least the alpha).
# Actually, I have no examples whatever with @, so I just let it remain in the
# ASCII order.
def sortOrder(s):
    converted = ""
    for c in s:
        if c == "$":
            converted += 'a'
        elif c == "#":
            converted += 'b'
        #elif c == "@":
        #    converted += 'c'
        else:
            converted += c
    return converted

linesThisPage = 1000
for symbol in sorted(symtab, key = sortOrder):
    symProps = symtab[symbol]
    if symbol.startswith("_") or symbol.startswith("."):
        continue
    if linesThisPage >= linesPerPage:
        pageNumber += 1
        print(pageSeparator)
        print("%45s%-66sPAGE %4d" % ("", "CROSS REFERENCE", pageNumber))
        print("%-95s%16s %s" % ("SYMBOL    LEN    VALUE   DEFN   REFERENCES", program + " " + version, currentDate))
        linesThisPage = 0
    if symProps["type"] in ["EQU", "CSECT", "EXTERNAL"]: ###FIXME###
        length = 1
    elif "properties" in symProps and "scratch" in symProps["properties"]:
        if symProps["properties"]["scratch"]["length"] < 2:
            length = 1
        else:
            length = symProps["properties"]["scratch"]["length"] // 2
    else:
        length = 2
    value = symProps["value"]
    defn = "     "
    if "properties" in symProps and "printedLineNumber" in symProps["properties"]:
        defn = "%5d" % symProps["properties"]["printedLineNumber"]
    if "section" in symProps and "offset" in sects[symProps["section"]]:
        value += sects[symProps["section"]]["offset"]
    if symProps["type"] in ["INSTRUCTION", "DATA"]:
        line = "%-8s %5d   %06X %s" % (symbol, length, value & 0xFFFFFF, defn)
    else:
        line = "%-8s %5d %08X %s" % (symbol, length, value & 0xFFFFFFFF, defn)
    numRefs = 0
    if "references" in symProps and len(symProps["references"]) > 0:
        line += " "
        for n in sorted(symProps["references"]):
            if "printedLineNumber" in source[n]:
                if numRefs == 15:
                    print(line)
                    linesThisPage += 1
                    line = " "*30
                    numRefs = 0
                line += " %5d" % source[n]["printedLineNumber"]
                numRefs += 1
    print(line)
    linesThisPage += 1

if comparisonSects != None:
    print("\f")
    
    print("Generated code was compared to file %s" % \
          os.path.basename(comparisonFile))
    mismatchCount1 = 0
    for sect in comparisonSects:
        headerShown = False
        amemory = sects[sect]["memory"]
        memory = comparisonSects[sect]["memory"]
        for address in range(len(memory)):
            if memory[address] == None:
                continue
            if 0 == (address & 1):
                c = "H"
                if memory[address] == 0xC9:
                    continue
                if address < len(amemory) and memory[address] == amemory[address]:
                    continue
            else:
                c = "L"
                if memory[address] == 0xFB:
                    continue
                if address < len(amemory) and memory[address] == amemory[address]:
                    continue
            if not headerShown:
                print('Missing object code from section "%s":' % sect)
                headerShown = True
            print("\t%05X(%c): %02X" % (address // 2, c, memory[address]))
            mismatchCount1 += 1
    print("%s: %d bytes mismatched and %d bytes missing in generated code" % \
          (",".join(sourceFileNames), mismatchCount, mismatchCount1))
    
if False:
    import pprint
    for key in metadata["sects"]:
        metadata["sects"][key]["memory"] = \
            metadata["sects"][key]["memory"][:metadata["sects"][key]["used"]]
    pprint.pp(metadata)
    
if False:
    for symbol in symtab:
        if "hash" in symtab[symbol]:
            sect, address = unhash(symtab[symbol]["hash"])
            if (sect, address) == (None, None):
                print(symbol, "Cannot unhash")
            elif sect == None:
                print(symbol, "Not address")
            elif symtab[symbol]["type"] == "EXTERNAL":
                print(symbol, "Address is EXTRN")
            elif "section" not in symtab[symbol] or "address" not in symtab[symbol]:
                print(symbol, "Unhashes incorrectly as address")
            else:
                print(symbol, "Address", sect,"%05X"%address)
        