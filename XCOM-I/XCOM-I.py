#!/usr/bin/env python3
# -*- coding: utf-8 -*-
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   XCOM-I.py
Purpose:    This is an attempt to create a program that can translate
            programs written in Intermetrics's extension of the XPL
            language (which is specialized for executing on the
            IBM System/360 computer) into code for some modern high-level
            language. 
Requires:   Python 3.6 or later.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-03-07 RSB  Began experimenting with this concept.

This particular file is just the top level of the program, tasked with
reading in the XPL source code and gently massaging it to remove 
formatting quirks such as punch-card numbers and run-on lines.
Importable modules are called upon for any substantial processing.
'''

import sys
import re
import os
import shutil
from parseCommandLine import *
from auxiliary import error, setErrorRef, expandAllMacrosInString, printModel, \
                      getAttributes, walkModel, scopeDelimiter
from xtokenize import xtokenize, digits
from DECLARE import DECLARE
from LABEL import LABEL
from PROCEDURE import PROCEDURE
from ASSIGNMENT import ASSIGNMENT
from DO import DO
from IF import IF
from RETURN import RETURN
from CALL import CALL
from ESCAPEorREPEAT import ESCAPEorREPEAT
from generateC import generateC, ppFiles, reservedMemory, physicalMemoryLimit

logicalNot = '¬'
usCent = '¢'

# Create the global scope (symbol,parent=None,None) or a new child scope of an 
# existing parent scope (symbol,parent not None,None).
def createNewScope(symbol = '', parent = None):
    '''
    The global scope and the scope of each defined PROCEDURE (however deeply 
    nested) are separately described by their own "scope dictionary".  All such 
    scope dictionaries have the same basic structure.
    
    Note: You'll see in how the `parent` and `children` fields are 
    defined that there will be lots of circular references.  Googling
    whether this is a problem or not, the discussion at
    https://stackoverflow.com/questions/2428301/should-i-worry-about-circular-references-in-python
    says that it's not a problem, except conceivably for garbage-collection
    speed if deletions occur.  Regardless of whether or not there would be
    a speed loss in that case, my dictionaries are only created and linked
    to each other, but never destroyed, so that doesn't seem to be an issue.
    
    Note: Note that as of Python 3.7, dictionaries retain the ordering of 
    keys.  This feature is critical to our implementation because we need 
    it to track the order of memory allocations of variables and the order
    in which macro expansions are performed.  Prior to Python 3.6, this 
    would instead have entailed using an OrderedDict structure instead of a 
    dictionary for the `declarations` field.
    '''
    scope = { 
        # The symbolic name of the current scope, or '' for the global scope.
        "symbol" : symbol,
        # `ancestors` is a name list of the parent hierarchy of the current 
        # scope dictionary.  For the global scope, there is no parent, and the 
        # list is empty.  Otherwise, each entry is an ancestor scope
        # dictionary.  The final entry (except for the global scope) is 
        # always the name of the current PROCEDURE.
        "ancestors" : [],
        # `parent` points to the parent scope's scope dictionary, or None for
        # the global scope.
        "parent" : None,
        # `children` is a list of all the child scope dictionaries of the
        # current scope dictionary; i.e., all immediately-nested
        # PROCEDURE definitions.
        "children" : [],
        # `literals` comprises all symbols defined in DECLARE statements
        # with the "LITERALLY" attribute.
        "literals" : {},
        # `variables` comprises all variables that are DECLARE'd in the 
        # current scope.  (More accurately, any symbol that's DECLARE'd
        # without the "LITERALLY attribute or other declaration-type
        # statements like ARRAY or BASED, or any PROCEDURE definition
        # appearing in the current scope.)
        "variables" : {},
        # `labels` is a Python set object giving all of the labels appearing
        # within the scope, not including child scopes.
        "labels" : set(),
        # `allLabels` is a list, for scopes which are procedures, including
        # all labels within the scope or child scopes.
        "allLabels" : [],
        # `code` contains a representation as a list of dictionaries of the 
        # executable source code of the current scope.  Note that in 
        # contrast to HAL/S, XPL/I does allow executable source code in the 
        # global scope.  Each entry of `code` represents an entry (other
        # than a declaration of one sort or another) of an entry in the
        # global `pseudoStatements` list relevant to the current scope.
        "code": [],
        # `pseudoStatements` is a dictionary in which the keys are indices
        # of `code`, and the values are the text of pseudoStatements.  Not
        # all indices are present.  The idea is to be able to optionally
        # print out the original XPL/I pseudo-statements embedded in the
        # generated out source code.  `psRefs` is a dictionary for tracking
        # the indext numbers (in `lines`) of those pseudoStatements.
        "pseudoStatements" : {},
        "lineRefs" : {},
        #---------------------------------------------------------------------
        # Below this line are state variables specific to the scope.  They're
        # here because the calling code isn't recursive and needs some way
        # to track the processing of the current scope in a way that doesn't
        # mess up the processing of the parent scope (if any).  
        #
        # `blockCount`, which auto-increments after each DO is found, is used
        # for assigning symbolic names to DO...END blocks, since they wouldn't
        # otherwise have any symbolic names.
        "blockCount" : 0,
        # Current pseudo-statement number (i.e., index into pseudoStatements).
        "lineNumber" : 0,
        # Current pseudo-statement text.
        "lineText" : '',
        # Current psuedo-statement text as expanded by macros.
        "lineExpanded" : ''
        }
    if symbol != '':
        scope["parent"] = parent
        scope["ancestors"] = parent["ancestors"] + [parent["symbol"]]
        parent["children"].append(scope)
    return scope
globalScope = createNewScope() # The top-level scope
scope = globalScope # The current scope

# A fictitious declaration for some dope vectors I want to store in `memory`
# that's not declared in either the library or the user XPL.
globalScope["variables"]["userMemory"] = { "BASED": True, "BIT": 8, "dirWidth": 28 }
globalScope["variables"]["privateMemory"] = { "BASED": True, "BIT": 8, "dirWidth": 28 }

for adhoc in adhocs:   
    globalScope["literals"][adhoc] = { "LITERALLY": adhocs[adhoc] }

# Now let's turn the massaged lines[] array into one gigantic string
# representing the entire source.
sourceLibraryCutoff = 0 # Index in `source` of change from library to main.
source = "".join(lines)
sourcePos = 0
sourceRefs = { }
for i in range(len(lines)):
    if sourceLibraryCutoff == 0 and i >= libraryCutoff:
        sourceLibraryCutoff = sourcePos
    sourceRefs[sourcePos] = i
    sourcePos += len(lines[i])

lastC = ''
lastLastC = ''
inQuote = False
inComment = False
inHex = False
inBase = False
inStartedRef = None
baseRadix = ''
baseStart = 0
#inPfs = False
#inBfs = False
inConditional = ''
conditionalTrue = False
pseudoStatement = ''
skipQuote = 0
inRecord = False # Tracks whether continuation of "BASED RECORD:".
psLibraryCutoff = 0 # Pseudo-statement index of change from library to main source.
    
i = -1 # Position in the source.
lineRef = None
while True:
    i += 1
    if i in sourceRefs:
        lineRef = sourceRefs[i]
        setErrorRef(lineRef)
    if i >= len(source):
        break
    if skipQuote > 0:
        skipQuote -= 1
        continue
    c = source[i]
    
    if not inQuote:
        # Take care of /?c conditionals.  Note that embedded conditionals
        # aren't supported or detected.  However, because I've found some
        # of these inside of quoted strings, I do evaluate them within such
        # strings.
        if inConditional == '' and len(c) == 1 and c.isupper() \
                and lastC == '?' and lastLastC == '/':
            inConditional = c
            conditionalTrue = (c in ifdefs)
            inStartedRef = lineRef
            pseudoStatement = pseudoStatement[:-2]
            lastLastC = lastC
            lastC = c
            continue
        elif inConditional != '' and c == '/' and lastC == '?':
            if conditionalTrue: # Remove the ?
                pseudoStatement = pseudoStatement[:-1]
            inConditional = ''
            conditionalTrue = False
            lastLastC = lastC
            lastC = c
            continue
        elif inConditional != "" and not conditionalTrue:
            lastLastC = lastC
            lastC = c
            continue
        
    # Just count the number of single-quotes in succession.  
    quoteCount = 0
    if c == "'":
        for j in range(i, len(source)):
            if source[j] != "'":
                endOfQuotes = True
                break
            quoteCount += 1
    endOfStatement = False
    if inComment:
        if c == "/" and lastC == "*":
            inComment = False
            c = ' '
    elif inQuote:
        if c == usCent:
            c = '`'
        if quoteCount > 0:
            skipQuote = quoteCount - 1
            if 1 == (quoteCount & 1):
                inQuote = False
                quoteCount -= 1
            for j in range(0, quoteCount, 2):
                pseudoStatement = pseudoStatement + replacementQuote
            if not inQuote:
                pseudoStatement = pseudoStatement + "'"
            lastLastC = lastC
            lastC = c
            continue
    elif inHex:
        if c == ' ':
            continue
        if c == '(':
            inBase = True
            baseRadix = ''
            baseStart = len(pseudoStatement) - 1
            cBase = ''
            inHex = False
            continue
        if c == '"':
            inHex = False
            for ih in hexAccumulator:
                if ih not in digits["x"]:
                    error("Non-digit (%s) in double-quoted string" % \
                          ih, None)
                    if winKeep:
                        input()
                    sys.exit(1)
            # The leading space before the %d below relates to the fact
            # that " cannot be a character in an identifier, but digits
            # can be.  Thus if you have a construct like XSET"..." (which
            # actually appears in HAL/S-FC source code), it's the difference
            # between the number being appended to XSET vs being a separate
            # token.  Neither choice is guaranteed to be safe, however, and
            # the one I've made is the one that preserves the purpose of
            # XSET.  Other XPL code might expect something different, and it
            # *is* possible to process it such that both choices are ok.  My
            # problem is that XCOM-I currently processes the hex strings 
            # prior to processing the macros, whereas Intermetrics's XCOM
            # must have done it in the reverse order; and I'm too far down  
            # the development path to want to try fixing that.
            pseudoStatement = pseudoStatement + " %d" % int(hexAccumulator, 16)
            c = ''
    elif inBase:
        if c == ")":
            if baseRadix == "1":
                cBase = 'b'
                baseRadix = 2
            elif baseRadix == "2":
                cBase = 'q'
                baseRadix = 4
            elif baseRadix == "8":
                cBase = 'o'
                baseRadix = 8
            elif baseRadix == "16":
                cBase = 'x'
                baseRadix = 16
            else:
                error("%s-bit not supported in literals" % baseRadix, \
                      None)
            continue
        if cBase == '':
            baseRadix = baseRadix + c
            continue
        if c == " ":
            continue
        if c == '"':
            inBase = False
            pseudoStatement = pseudoStatement + \
                                    " %d" % int(hexAccumulator, baseRadix)
            c = ''
    elif c == '"':
        inHex = True
        inStartedRef = lineRef
        hexAccumulator = ''
        hexStart = len(pseudoStatement)
        c = ''
    elif c == "'":
        skipQuote = quoteCount - 1
        if 1 == (quoteCount & 1):
            inQuote = True
            inStartedRef = lineRef
            quoteCount -= 1
        else:
            quoteCount -= 2
        pseudoStatement = pseudoStatement + "'"
        for j in range(0, quoteCount, 2):
            pseudoStatement = pseudoStatement + replacementQuote
        if not inQuote:
            pseudoStatement = pseudoStatement + "'"
        lastLastC = lastC
        lastC = c
        continue
    elif c == "*" and lastC == "/":
        inComment = True
        inStartedRef = lineRef
        c = ' '
        pseudoStatement = pseudoStatement[:-1]
    elif c in [";", ":"]:
        endOfStatement = True
    elif c == "/" and lastC == "%":
        endOfStatement = True
    elif c in ["N", "n"] and source[max(0,i-3):i+1].upper() == "THEN" and \
            None != re.search("\\bTHEN\\b", source[max(0,i-4):i+2], \
                              flags = re.IGNORECASE):
        endOfStatement = True
    elif c in ["E", "e"] and source[max(0,i-3):i+1].upper() == "ELSE" and \
            None != re.search("\\bELSE\\b", source[max(0,i-4):i+2], \
                              flags = re.IGNORECASE):
        endOfStatement = True
    elif c in ["F", "f"] and source[max(0,i-2):i+1].upper() == "EOF" and \
            None != re.search("\\bEOF\\b", source[max(0,i-3):i+2], \
                              flags = re.IGNORECASE):
        endOfStatement = True
    elif c == "^" or c == logicalNot:
        c = '~'
    if inHex or inBase:
        hexAccumulator = hexAccumulator + c
    elif not inComment:
        if not (c == ' ' and lastC == ' ') or inQuote:
            pseudoStatement = pseudoStatement + c
    if endOfStatement:
        if psLibraryCutoff == 0 and i >= sourceLibraryCutoff:
            psLibraryCutoff = len(pseudoStatements)
        pseudoStatements.append(pseudoStatement.lstrip())
        psRefs.append(lineRef)
        pseudoStatement = ''
    lastLastC = lastC
    lastC = c

setErrorRef(inStartedRef)
if inQuote:
    error("Unterminated quoted string", None)
if inComment:
    error("Unterminated inline comment", None)
if inHex:
    error("Unterminated hexadecimal number", None)
if inBase:
    error("Unterminated base %s number" % baseRadix, None)
if inConditional:
    error("Unterminated conditional directive", None)
if inRecord:
    error("Unterminated BASED RECORD", None)

# Tokenize and parse, on a pseudo-statement by pseudo-statement basis.
# Note that because of macro expansion, the number of pseudo-statments
# can increase during the loop.
lineNumber = -1
while True:
    lineNumber += 1
    if lineNumber >= len(pseudoStatements):
        break
    setErrorRef(psRefs[lineNumber])
    #code = {} # The dictionary generated for a parsed pseudo-statement.
    #print(lineNumber, pseudoStatements[lineNumber], scope)
    #scope["code"].append(code)
    pseudoStatement = pseudoStatements[lineNumber]
    scope["lineNumber"] = lineNumber
    scope["lineText"] = pseudoStatement
    originalPseudoStatement = pseudoStatement
    if "XVERSION" in pseudoStatement:
        pass
    pseudoStatement = expandAllMacrosInString(scope, \
                                              pseudoStatement)
    # It's entirely possible that the macro expansions above could have
    # turned our nice pseudoStatement into several pseudoStatements 
    # concatenated.  There are some macros in the virtual memory system code,
    # for example, that do that.  But it will mess up subsequent processing,
    # so let's detect it and fix it.
    ps = ''
    inQuote = False
    retry = False
    for i in range(len(pseudoStatement)):
        c = pseudoStatement[i]
        ps = ps + c
        if ps == pseudoStatement:
            break
        if c == "'":
            inQuote = not inQuote
        if inQuote:
            continue
        if c in [";", ":"] or pseudoStatement[max(0,i-4):i+2] in [" THEN ", 
                                                                  " ELSE "]:
            pseudoStatements.insert(lineNumber, ps)
            psRefs.insert(lineNumber, psRefs[lineNumber])
            pseudoStatement = pseudoStatement[i+1:].lstrip()
            pseudoStatements[lineNumber + 1] = pseudoStatement
            if lineNumber <= psLibraryCutoff:
                psLibraryCutoff += 1;
            ps = ''
            retry = True
            lineNumber -= 1
            break
    if retry:
        continue
    library = lineNumber < psLibraryCutoff
    scope["pseudoStatements"][len(scope["code"])] = originalPseudoStatement
    scope["lineRefs"][len(scope["code"])] = psRefs[lineNumber]
    scope["lineExpandedText"] = pseudoStatement
    tokenized = xtokenize(scope, pseudoStatement)
    scope["tokenized"] = tokenized
    if len(tokenized) == 0:
        continue
    reserved0 = ""
    reserved1 = ""
    if "reserved" in tokenized[0]:
        reserved0 = tokenized[0]["reserved"]
    if len(tokenized) > 1:
        if "reserved" in tokenized[1]:
            reserved1 = tokenized[1]["reserved"]
        elif reserved0 == "RETURN" and "builtin" in tokenized[1] and \
                tokenized[1]["builtin"] == "INLINE":
            # Manipulate the extraordinarily-rare "RETURN INLINE(...)" so that
            # it's internally treated as a "CALL INLINE(...)".
            tokenized[0]["reserved"] = "CALL"
            reserved0 = "CALL"
    if "go to" in pseudoStatement:
        pass
    if reserved0 == "GO" and reserved1 == "TO":
        tokenized[1]["reserved"] = "GOTO"
        del tokenized[0]
        reserved0 = "GOTO"
        reserved1 = ""
    
    fields = pseudoStatement.split()
    
    # Note that the DECLARE() function applies its own cut-rate form of 
    # tokenization directly to the pseudo-statement rather than using 
    # `tokenized` (as created by the xtokenize() function). Mostly that's 
    # because I wrote DECLARE() before writing xtokenize(), but also because
    # if DECLARE() finds a new macro definition then it needs to apply that
    # new macro to the current pseudo-statement, as well as retokenizing it.
    # I find that a bit to daunting to deal with if there's no real need
    # to do so.  Perhaps I'll rethink that later.
    if inRecord: # Declaration inside a BASED RECORD?
        if DECLARE(pseudoStatement, scope, library, True):
            error("Problem in DECLARE in BASED RECORD", scope)
        inRecord = False
    elif reserved0 == "EOF":
        # Once all INCLUDE constructs are implemented, EOF should probably
        # end compilation rather than just being ignored, but it's 
        # probably harmless to do either.  Without the INCLUDE constructs,
        # the source files need to be specified on the command line, and
        # ending compilation would mess that up.
        pass
    elif reserved0 in ["DECLARE", "COMMON", "ARRAY", "BASED"]:
        if DECLARE(pseudoStatement, scope, library, False):
            error("Problem in DECLARE, COMMON, ARRAY, or BASED", scope)
        # Was the declaration a "BASED ... RECORD ...:" ?
        # If so, we'll use it (via inRecord) when processing
        # the next pseudo-statement.
        variables = scope["variables"]
        if len(variables) > 0:
            lastDeclaration = variables[list(variables)[-1]]
            inRecord = ("RECORD" in lastDeclaration and \
                        lastDeclaration["RECORD"] == {})
        else:
            inRecord = False
    elif fields[-1][-1:] == ":": # Label?
        if LABEL(tokenized, scope):
            error("Problem in LABEL", scope)
    elif reserved0 == "PROCEDURE":
        # The procedure name will already have been added to the code array
        # as a target label for goto.  Retrieve the name and delete the code.
        if len(scope["code"]) == 0 or "TARGET" not in scope["code"][-1]:
            error("No name specified for PROCEDURE", scope)
        symbol = scope["code"][-1]["TARGET"]
        del scope["code"][-1]
        if PROCEDURE(tokenized, scope):
            error("Problem in PROCEDURE", scope)
        # We must now create a new scope and descend into it.
        parent = scope
        scope = createNewScope(symbol, scope)
        parent["variables"][symbol]["PROCEDURE"] = scope
    elif reserved0 == "END":
        # End of a PROCEDURE definition or DO...END block.
        #for label in scope["labels"]:
        #    scope["variables"].pop(label)
        scope = scope["parent"]
    elif "identifier" in tokenized[0] or ("builtin" in tokenized[0] and \
            tokenized[0]["builtin"] in ["OUTPUT", "COREWORD", "COREBYTE", 
                                        "FILE", "BYTE", "FREELIMIT", 
                                        "FREEPOINT", "FREEBASE",
                                        "COREHALFWORD", "DESCRIPTOR"]):
        # Other than a label (already processed above), the only thing
        # that begins with an identifier appears to be an assignment
        # statement.
        if ASSIGNMENT(tokenized, scope):
            error("Problem in ASSIGNMENT", scope)
    elif reserved0 == "DO":
        # We must now create a new scope and descend into it.
        scope["blockCount"] += 1
        if scope["symbol"][:1] != scopeDelimiter:
            symbol = ''
        else:
            symbol = scope["symbol"]
        symbol = symbol + scopeDelimiter + "%d" % scope["blockCount"]
        label = None
        if len(scope["code"]) > 0 and "TARGET" in scope["code"][-1]:
            label = scope["code"][-1]["TARGET"]
        scope = createNewScope(symbol, scope)
        if label != None:
            scope["label"] = label
        if DO(tokenized, scope):
            error("Problem in DO", scope)
    elif reserved0 == "IF":
        if IF(tokenized, scope):
            error("Problem in IF", scope)
    elif reserved0 == "GOTO":
        if len(tokenized) != 3 or "identifier" not in tokenized[1] or \
                tokenized[2] != ";":
            error("Bad GOTO statement.", scope)
        symbol = tokenized[1]["identifier"]
        attributes = getAttributes(scope, symbol)
        # Note that I don't attempt to check that the target label is
        # legitimate.  If it's a forward reference, it won't be 
        # detectable yet.  If it's in a parent context, it might be
        # detectable, but it's still possible that a forward reference
        # in the current scope could override the name.
        #if attributes != None and "LABEL" not in attributes:
        #    error("Target symbol %s in GOTO is not a LABEL" % symbol, scope)
        scope["code"].append({"GOTO": symbol})
    elif reserved0 == "ELSE":
        scope["code"].append({"ELSE": True})
    elif reserved0 == "RETURN":
        if RETURN(tokenized, scope):
            error("Problem in RETURN", scope)
    elif reserved0 == "CALL":
        if CALL(tokenized, scope):
            error("Problem in CALL", scope)
    elif tokenized[0] == ";":
        scope["code"].append({"EMPTY": True})
    elif reserved0 in ["ESCAPE", "REPEAT"]:
        if ESCAPEorREPEAT(tokenized, scope):
            error ("Problem with ESCAPE or REPEAT", scope)
    else:
        #print(tokenized)
        error("Unimplemented", scope)
        #print(pseudoStatement)

# There's an adjustment that must now be made occasionally.  Embedded PROCEDUREs
# should be immediate child scopes of the PROCEDUREs in which they're embedded.
# However, it occasionally happens that they've instead been defined in the
# XPL source code within a DO...END block.  In those cases, they must be
# promoted upward into the correct scopes.  This is a bit tricky to do 
# correctly right now, but easier (I think) than having done it above.
# The same comment is true for LABELs within a PROCEDURE, except of course that
# it actually *makes sense* for to be within DO...END blocks.
ORIGINAL_PROMOTION = False
def fixProcedureScopes(scope, extra=None):
    # If this scope is not itself a PROCEDURE, we
    # have to find the enclosing PROCEDURE, or failing that the global
    # procedure.
    nscope = scope
    while nscope["symbol"] == "" or nscope["symbol"][:1] == scopeDelimiter:
        if nscope["parent"] == None:
            break
        nscope = nscope["parent"]
    if nscope == scope:
        for symbol in scope["labels"]:
            scope["allLabels"].append(symbol)
        return
    allLabels = nscope["allLabels"]
    if ORIGINAL_PROMOTION:
        # Now promote all PROCEDURE definitions and LABELs from the current scope
        # to the enclosing PROCEDURE's scope.
        remove = []
        for symbol in scope["variables"]:
            attributes = scope["variables"][symbol]
            if "PROCEDURE" not in attributes and "LABEL" not in attributes:
                continue
            remove.append(symbol)
            nscope["variables"][symbol] = attributes
        for symbol in remove:
            scope["variables"].pop(symbol)
    else:
        # It turns out that the same darned thing happens with variables as well. 
        # Promote *all* identifiers from the current scope to the enclosing
        # PROCEDURE's scope.  If duplicate definition, print a message, except
        # for LABELs, since the duplicates would be expected forward declarations.
        for symbol in scope["variables"]:
            if symbol in nscope["variables"]:
                if not ("LABEL" in scope["variables"][symbol] and \
                        "LABEL" in nscope["variables"][symbol]):
                    error("%s multiply-defined in %s" % (symbol, nscope["symbol"]),
                          scope)
            nscope["variables"][symbol] = scope["variables"][symbol]
            if symbol not in allLabels and symbol in scope["labels"]:
                allLabels.append(symbol)
        scope["variables"] = {}
walkModel(globalScope, fixProcedureScopes)

if False: # Print out a hierarchical tree of procedures.
    def printProcedures(scope, extra=None):
        variables = scope["variables"]
        for v in variables:
            variable = variables[v]
            if "PROCEDURE" not in variable:
                continue
            print(v, variable["parameters"], variable["return"], \
                  variable["PROCEDURE"]["symbol"], \
                  variable["PROCEDURE"]["ancestors"])
    walkModel(globalScope, printProcedures)
    if winKeep:
        input()
    sys.exit(1)

# At this point, we have generated a model of the program,
# in the form of a abstract models of the scope hierarchy,
# the memory space, and pseudocode, all contained in a 
# tree of dictionaries whose root is the `globalScope`
# dictionary.  We are thus in a position to generate object
# code.
if targetLanguage == "C":
    try:
        try:
            shutil.rmtree(outputFolder, True)
        except:
            pass
        try:
            os.mkdir(outputFolder)
        except:
            pass
        for name in ["runtimeC.c", "runtimeC.h", "inline360.c", "inline360.h",
                  "debuggingAid.c", "Makefile.template"]:
            shutil.copy(basePath + name, outputFolder + os.sep + \
                        name.replace(".template", ""))
    except:
        error("Failed to copy framework from %s into %s" % \
              (basePath, outputFolder), scope)
        if winKeep:
            input()
        sys.exit(1)
    generateC(globalScope)
    if prettyPrint:
        #print("Pretty-printing " + ppFiles["filenames"], file=sys.stderr)
        os.system("cd " + outputFolder + " && clang-format --style=gnu -i " + \
                  ppFiles["filenames"])

if not quiet and reservedMemory["numReserved"] > 0:
    print("Reserved count: %d" % reservedMemory["numReserved"])
    print("Reserved space: %d" % (0x1000000 - reservedMemory["nextReserved"]))

