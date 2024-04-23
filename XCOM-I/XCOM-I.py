#!/usr/bin/env python3
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
from auxiliary import error, expandAllMacrosInString, printModel, \
                      getAttributes
from xtokenize import xtokenize, digits
from DECLARE import DECLARE
from LABEL import LABEL
from PROCEDURE import PROCEDURE
from ASSIGNMENT import ASSIGNMENT
from DO import DO
from IF import IF
from RETURN import RETURN
from CALL import CALL
from generateC import generateC

logicalNot = '¬'
usCent = '¢'

pseudoStatements = [] # One pseudo-statement per entry. See the 
# README.md's section titled "Pseudo-Statements" for an explanation of 
# that concept.

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
        # within the scope.
        "labels" : set(),
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
        # generated out source code.
        "pseudoStatements" : {},
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

for adhoc in adhocs:   
    globalScope["literals"][adhoc] = { "LITERALLY": adhocs[adhoc] }

# Now let's turn the massaged lines[] array into one gigantic string
# representing the entire source.
source = "".join(lines)

lastC = ''
lastLastC = ''
inQuote = False
inComment = False
inHex = False
inBase = False
baseRadix = ''
baseStart = 0
#inPfs = False
#inBfs = False
inConditional = ''
pseudoStatement = ''
skipQuote = 0
inRecord = False # Tracks whether continuation of "BASED RECORD:".
    
i = -1 # Position in the source.
while True:
    i += 1
    if i >= len(source):
        break
    if skipQuote > 0:
        skipQuote -= 1
        continue
    c = source[i]
    
    if False and not inComment and not inQuote:
        # Take care of /?P and /?B conditionals.
        if c == 'P' and lastC == '?' and lastLastC == '/':
            inPfs = True
            inBfs = False
            pseudoStatement = pseudoStatement[:-2]
            lastLastC = lastC
            lastC = c
            continue
        elif c == 'B' and lastC == '?' and lastLastC == '/':
            inBfs = True
            inPfs = False
            pseudoStatement = pseudoStatement[:-2]
            lastLastC = lastC
            lastC = c
            continue
        elif c == '/' and lastC == '?':
            pseudoStatement = pseudoStatement[:-1]
            inPfs = False
            inBfs = False
            lastLastC = lastC
            lastC = c
            continue
        elif (inPfs and not pfs) or (inBfs and pfs):
            lastLastC = lastC
            lastC = c
            continue
        
    if not inComment and not inQuote:
        # Take care of /?c conditionals.  Note that embedded conditionals
        # aren't supported or detected.
        if c in ["A", "B", "C", "P"] and lastC == '?' and lastLastC == '/':
            inConditional = c
            pseudoStatement = pseudoStatement[:-2]
            lastLastC = lastC
            lastC = c
            continue
        elif c == '/' and lastC == '?':
            pseudoStatement = pseudoStatement[:-1]
            inConditional = ''
            lastLastC = lastC
            lastC = c
            continue
        elif (inConditional == "P" and not pfs) or \
                (inConditional == "B" and pfs) or \
                (inConditional == "A" and not condA) or \
                (inConditional == "C" and not condC):
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
        if c == '(':
            inBase = True
            baseRadix = ''
            baseStart = len(pseudoStatement) - 1
            cBase = ''
            inHex = False
            continue
        if c == '"':
            inHex = False
            for ih in range(hexStart, len(pseudoStatement)):
                if pseudoStatement[ih] not in digits["x"]:
                    print("Non-hex digit(s) in \"%s\"" % \
                          pseudoStatement[hexStart:], file=sys.stderr)
                    sys.exit(1)
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
                print("%s-bit not supported in literals" % baseRadix, \
                      file=sys.stderr)
                sys.exit(1)
            pseudoStatement = pseudoStatement[:baseStart] + cBase + \
                pseudoStatement[baseStart+1:]
            continue
        if cBase == '':
            baseRadix = baseRadix + c
            continue
        if c == " ":
            continue
        if c == '"':
            inBase = False
            c = ''
    elif c == '"':
        inHex = True
        pseudoStatement = pseudoStatement + "0x"
        hexStart = len(pseudoStatement)
        c = ''
    elif c == "'":
        skipQuote = quoteCount - 1
        if 1 == (quoteCount & 1):
            inQuote = True
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
    if not inComment:
        if not (c == ' ' and lastC == ' ') or inQuote:
            pseudoStatement = pseudoStatement + c
    if endOfStatement:
        pseudoStatements.append(pseudoStatement.lstrip())
        pseudoStatement = ''
    lastLastC = lastC
    lastC = c

if inQuote:
    print("Unterminated quoted string", file=sys.stderr)
if inComment:
    print("Unterminated inline comment", file=sys.stderr)
if inHex:
    print("Unterminated hexadecimal number", file=sys.stderr)
if inBase:
    print("Unterminated base %s number" % baseRadix, file=sys.stderr)
if inConditional:
    print("Unterminated conditional directive", file=sys.stderr)
if inRecord:
    print("Unterminated BASED RECORD", file=sys.stderr)
if inQuote or inComment or inHex or inBase or inConditional or inRecord:
    sys.exit(1)


if False:
    # See what we have so far.
    for i in range(len(pseudoStatements)):
        print("%06d: %s" % (i, pseudoStatements[i]))
    sys.exit(1)
    
if False:
    # Let's tokenize the whole thing.  (Can't really do this right now,
    # except as a test of the tokenizer, since macros haven't been 
    # expanded, and the tokenization might change when macros are 
    # expanded later.)
    tokenized = []
    for pseudoStatement in pseudoStatements:
        tokenized.append(xtokenize(pseudoStatement))
        print(pseudoStatement)
        print(tokenized[-1])
    sys.exit(1)

# Tokenize and parse, on a pseudo-statement by pseudo-statement basis.
# Note that because of macro expansion, the number of pseudo-statments
# can increase during the loop.
lineNumber = -1
while True:
    lineNumber += 1
    if lineNumber >= len(pseudoStatements):
        break
    #code = {} # The dictionary generated for a parsed pseudo-statement.
    #print(lineNumber, pseudoStatements[lineNumber], scope)
    #scope["code"].append(code)
    pseudoStatement = pseudoStatements[lineNumber]
    scope["lineNumber"] = lineNumber
    scope["lineText"] = pseudoStatement
    originalPseudoStatement = pseudoStatement
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
            pseudoStatement = pseudoStatement[i+1:].lstrip()
            pseudoStatements[lineNumber + 1] = pseudoStatement
            ps = ''
            retry = True
            lineNumber -= 1
            break
    if retry:
        continue
    scope["pseudoStatements"][len(scope["code"])] = originalPseudoStatement
    scope["lineExpandedText"] = pseudoStatement
    tokenized = xtokenize(pseudoStatement)
    scope["tokenized"] = tokenized
    if len(tokenized) == 0:
        continue
    reserved0 = ""
    reserved1 = ""
    if "reserved" in tokenized[0]:
        reserved0 = tokenized[0]["reserved"]
    if len(tokenized) > 1 and "reserved" in tokenized[1]:
        reserved1 = tokenized[1]["reserved"]
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
        if DECLARE(pseudoStatement, scope, True):
            sys.exit(1)
        inRecord = False
    elif reserved0 == "EOF":
        # Once all INCLUDE constructs are implemented, EOF should probably
        # end compilation rather than just being ignored, but it's 
        # probably harmless to do either.  Without the INCLUDE constructs,
        # the source files need to be specified on the command line, and
        # ending compilation would mess that up.
        pass
    elif reserved0 in ["DECLARE", "COMMON", "ARRAY", "BASED"]:
        if DECLARE(pseudoStatement, scope, False):
            sys.exit(1)
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
            sys.exit(1) 
    elif reserved0 == "PROCEDURE":
        # The procedure name will already have been added to the code array
        # as a target label for goto.  Retrieve the name and delete the code.
        if len(scope["code"]) == 0 or "TARGET" not in scope["code"][-1]:
            error("No name specified for PROCEDURE", scope)
        symbol = scope["code"][-1]["TARGET"]
        del scope["code"][-1]
        if PROCEDURE(tokenized, scope):
            sys.exit(1)
        # We must now create a new scope and descend into it.
        parent = scope
        scope = createNewScope(symbol, scope)
        parent["variables"][symbol]["PROCEDURE"] = scope
    elif reserved0 == "END":
        # End of a PROCEDURE definition or DO...END block.
        for label in scope["labels"]:
            scope["variables"].pop(label)
        scope = scope["parent"]
    elif "identifier" in tokenized[0] or ("builtin" in tokenized[0] and \
        tokenized[0]["builtin"] in ["OUTPUT", "COREWORD", "COREBYTE", "FILE",
                                    "BYTE", "FREELIMIT"]):
        # Other than a label (already processed above), the only thing
        # that begins with an identifier appears to be an assignment
        # statement.
        if ASSIGNMENT(tokenized, scope):
            sys.exit(1)
    elif reserved0 == "DO":
        # We must now create a new scope and descend into it.
        scope["blockCount"] += 1
        if scope["symbol"][:1] != "_":
            symbol = ''
        else:
            symbol = scope["symbol"]
        symbol = symbol + "_%d" % scope["blockCount"]
        scope = createNewScope(symbol, scope)
        if DO(tokenized, scope):
            sys.exit(1)
    elif reserved0 == "IF":
        if IF(tokenized, scope):
            sys.exit(1)
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
            sys.exit(1)
    elif reserved0 == "CALL":
        if CALL(tokenized, scope):
            sys.exit(1)
    elif tokenized[0] == ";":
        scope["code"].append({"EMPTY": True})
    else:
        #print(tokenized)
        error("Unimplemented", scope)
        #print(pseudoStatement)
        
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
        os.mkdir(outputFolder)
        shutil.copy2(basePath + "runtimeC.c", outputFolder)
        shutil.copy2(basePath + "runtimeC.h", outputFolder)
        shutil.copy2(basePath + "Makefile", outputFolder)
    except:
        error("Failed to create files runtimeC.c etc. in %s/" % outputFolder, \
              scope)
    generateC(globalScope)
