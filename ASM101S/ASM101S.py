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
            2026-05-20 RSB  Added --library (vs --library=F).
            2026-05-23 RSB  Allowed for --force-d and --no-force-d.  Allowed
                            printing error messages even when --tolerable is
                            used.
            2026-05-26 RSB  Added --trace.  Was counting the number of 
                            parameters (positional and non-positional) within
                            MACRO/MEND completely wrong.  Other fixes related 
                            to issue #1331.
            2026-05-28 RSB  Repair for `MNOTE` severity.  Possible fixes for
                            issue #1332.
            2026-05-29 RSB  Implemented `ORG` for issue #1333.
            2026-05-31 RSB  Added `PRINT OFF`, `PRINT ON`.
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
from objectWriter import writeObjectModule

currentDate = datetime.today().strftime('%m/%d/%y')
svGlobals["_passCount"] = -1
trace = "--trace" in sys.argv
listOn = True

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
    # One operand, not two.  IBM's CNOP takes `b,w`; the AP-101S sources
    # write only `b`, counted in halfwords, with `w` fixed at a fullword.
    "CNOP": [1,1],
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
    "MNOTE": [1,2],
    "ORG": [1,1],
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
# Does this card continue onto the next one?  Column 72 says so, except that a
# typed card is never continued by a macro-generated card; see the note at the
# call site.
def _continuesOnto(line, lines, lineNumber):
    if line[71] == " ":
        return False
    if lineNumber + 1 < len(lines):
        nextCard = "%-80s" % lines[lineNumber + 1].rstrip()[:80]
        if macroStamped(nextCard) and not macroStamped(line):
            return False
    return True

def parseLine(lines, lineNumber, inMacroDefinition, inMacroProto):
    global source
    if "IFPROC" in lines[lineNumber] and not inMacroDefinition and not inMacroProto:
        pass
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

# The diagnostic for an exhausted ACTR.  It names where the loop was, because
# the alternative -- an assembly that simply never returns -- gives no clue at
# all, and because the count is very often correct and the loop's exit
# condition is what is wrong.
def actrMessage(fromWhere):
    where = fromWhere if isinstance(fromWhere, str) else str(fromWhere)
    return "ACTR exhausted: too many AIF/AGO branches in %s.  This is a " \
           "conditional-assembly loop that never terminates; the assembler " \
           "has abandoned the expansion." % where

# The EXTENDED, or computed, AGO of GC28-6514:
#
#       AGO   (arithmetic-expression)seq1,seq2,...,seqN
#
# the expression selecting which of the N sequence symbols to branch to, 1 for
# the first.  A value OUTSIDE 1..N branches nowhere and falls through to the
# next statement.  That is not an error condition and the sources depend on
# it: in CHAR and CHAR0 the card after the computed AGO is `AGO .INVCMSG`,
# reached only when the operand's length is something other than 1 through 6.
#
# Returns the chosen sequence symbol, or None when nothing is to be branched
# to -- either because the value was out of range, which is normal, or because
# the operand could not be made sense of, in which case it has already
# complained.
def computedAgoTarget(operandField, svLocals, properties):
    # Find the parenthesis matching the one the field opens with.  Counting
    # rather than searching for the first `)` because the expression may
    # itself be parenthesised or subscripted -- `(&N+1)`, `(&CCODE1(&I))`.
    depthParen = 0
    closeAt = -1
    for i, c in enumerate(operandField):
        if c == "(":
            depthParen += 1
        elif c == ")":
            depthParen -= 1
            if depthParen == 0:
                closeAt = i
                break
    if closeAt < 0:
        error(properties, "Unbalanced parentheses in computed AGO: %s" \
                          % operandField)
        return None
    expression = operandField[1:closeAt]
    targets = [t for t in operandField[closeAt+1:].split(",") if t != ""]
    if not targets:
        error(properties, "Computed AGO has no sequence symbols: %s" \
                          % operandField)
        return None
    ast = parserASM(expression, "setaOperand")
    if ast == None:
        error(properties, "Cannot parse computed AGO expression: %s" \
                          % expression)
        return None
    n = evalArithmeticExpression(ast["v"], svLocals, properties)
    if n == None:
        error(properties, "Cannot evaluate computed AGO expression: %s" \
                          % expression)
        return None
    if n < 1 or n > len(targets):
        return None
    return targets[n - 1]

def printTraceMessage(depth, name, operation, operand, extra=""):
    if trace:
        msg = f"Trace: {'%04d'%sysndx} {'%02d'%depth}    {'%-16s'%name} {'%-8s'%operation} {operand}"
        if len(extra) > 0:
            print(msg + " " + extra)
        else:
            print(msg)
        sys.stdout.flush()

# Convert the parsed form of a sublist into a `Sublist` of strings, nested to
# whatever depth the source text was.  The parser hands a sublist over as
#    ( '(', ( first, [ [',', item], ... ] ), ')' )
# in which any item may itself be a sublist of the same shape.  Failing to
# recurse here is what turned `(10,(100,200,300),30)` into the unusable
# `(10,((,(100,((,,200),(,,300))),)),30)`.
def evalSublist(properties, ast):
    inner = ast[1]
    entries = [ evalSublistEntry(properties, inner[0]) ]
    for e in inner[1]:
        entries.append(evalSublistEntry(properties, e[1]))
    return Sublist(entries)

def evalSublistEntry(properties, entry):
    if isinstance(entry, str):
        return entry
    if isinstance(entry, (list,tuple)) and len(entry) == 3 and \
            entry[0] == '(' and entry[2] == ')':
        return evalSublist(properties, entry)
    try:
        # Something like `4(R3)`, which parses as a tuple of strings.
        return "".join(entry)
    except:
        error(properties, \
              "Implementation error in sublist entry " + str(entry))
        return ""

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
    # This is the case of a non-positional parameter that's a quoted string.
    elif isinstance(suboperand, tuple) and \
            len(suboperand) == 6 and \
            suboperand[1] == "=" and \
            suboperand[2] == "'" and suboperand[5] == "'" and \
            suboperand[4] == [] and \
            isinstance(suboperand[3], str):
        return ("&" + suboperand[0]),("'" + suboperand[3] + "'")
    # Non-positional parameter that's a sublist.
    elif isinstance(suboperand, (list, tuple)) and len(suboperand) == 5 and \
            suboperand[1] == "=" and suboperand[2] == "(" and \
            isinstance(suboperand[3], tuple) and suboperand[4] == ")":
        return ("&" + suboperand[0]),evalSublist(properties, suboperand[2:5])
    # This is the case of a positional parameter that's a quoted string.
    elif isinstance(suboperand, tuple) and \
            len(suboperand) == 4 and \
            suboperand[0] == "'" and suboperand[3] == "'" and \
            suboperand[2] == [] and \
            isinstance(suboperand[1], str):
        return None,("'" + suboperand[1] + "'")
    # This is the case of a positional parameter being a sublist, such as
    #    (1,2,A).
    elif isinstance(suboperand, tuple) and len(suboperand) == 3 and \
            suboperand[0] == '(' and suboperand[2] == ')' and \
            isinstance(suboperand[1], tuple):
        return None,evalSublist(properties, suboperand)
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
#                reuse the definitions as many times as we like without 
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
# Which members of each library define macros, from its MACROFILES.txt.
libraryMembers = {}
# Read every listed member ahead of the module, as this always used to.
# Off: members are fetched by name when invoked.  See `loadLibraryMacro`.
preReadLibraries = False
metadata = {} # Metadata for the assembly, such as the TTILE.
sysndx = -1
def readSourceFile(fromWhere, svLocals, sequence, \
                   copy=False, printable=True, depth=0):
    global source, macros, svGlobals, metadata, sysndx, listOn
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
    mendLabel = None        # A sequence symbol on this macro's MEND, if any.
    
    if fromWhere in macros:
        # Load the macro definition into the list of source-code lines.
        filename = None
        macroname = fromWhere
        macroWhere = macros[macroname]
        thisSource = []
        sequence = {}
        # The MEND line is excluded from the body below, but a sequence symbol
        # written ON it -- `.MEND    MEND` -- is the ordinary way to jump to
        # the end of a macro, so remember it.  Branching there is not an error;
        # running off the end of the body IS the branch.
        mendLabel = source[macroWhere[4]]["name"].strip()
        if mendLabel[:1] != ".":
            mendLabel = None
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
    # The conditional-assembly loop counter.  It is decremented every time an
    # AIF or AGO branch is actually taken, and when it goes negative this
    # expansion is abandoned with a diagnostic.  That is the assembler's own
    # guard against a runaway AIF/AGO loop, and the AP-101S sources rely on it
    # -- five files in MLIB80 set it explicitly, ENDCASE with `ACTR 30000`.
    # Because `readSourceFile` recurses once per macro expansion, a plain local
    # gives each expansion its own counter, which is the required scope.
    # 4096 is the default when no ACTR appears (SC26-4940).
    actr = 4096
    while lineNumber + 1 < len(thisSource):
        lineNumber += 1
        line = thisSource[lineNumber]
        if skipToSeq != None and not line.startswith(skipToSeq + " "):
            # RECORD ANY SEQUENCE SYMBOL WE SKIP PAST.  A skipped line is never
            # parsed, so its symbol never reached `sequence`; a later branch
            # BACK to it then found nothing there, set `skipToSeq`, scanned
            # FORWARD to the end of the file, and silently discarded everything
            # after it -- no diagnostic, no generated code, no clue.  In
            # FIOCMPLT that swallowed the last thousand lines, including the
            # `GENERATE COPY=` statements that define the control-block DSECTs,
            # which is why seven modules reported TFIOQ and its neighbours as
            # undefined symbols.
            symbol = line.split()[0] if line.split() else ""
            if len(symbol) > 1 and symbol[0] == "." and symbol[1] != "*" \
                    and symbol not in sequence:
                sequence[symbol] = (fromWhere, lineNumber)
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
            # A CARD DOES NOT CONTINUE ONTO AN EXPANSION.  Columns 73-80
            # read `nn-NAME` on a card the expander produced and a sequence
            # number on one somebody typed, so a typed card cannot be
            # continued by a generated card -- that card was not in the deck
            # when this column 72 was punched.
            #
            # OI301700 IS PRE-EXPANDED and the expansions were spliced in,
            # displacing what the continuation actually pointed at.  FIOCGR's
            # `LR R2,R7` carries an X in column 72 and the `CHI R6,2` now
            # standing after it was eaten as its continuation and never
            # assembled: the original has 00009 B5E6 0002 and we generated
            # nothing, putting every later address four bytes low.
            #
            # Corrected HERE rather than at the three places that consume it,
            # which is what makes one edit do the work: `joinOperand` still
            # reads column 72 off the card itself and needs its own guard, but
            # the two gates that DISCARD the card both read this flag.
            "continues": _continuesOnto(line, thisSource, lineNumber),
            "identification": line[72:],
            "empty": (text.strip() == ""),
            "fullComment": line.startswith("*"),
            "dotComment": line.startswith(".*"),
            "endComment": "",
            # The parsed operand field, filled in by `generateObjectCode`.  It
            # is created here, as None, so that the key always exists:  the
            # code generator tests it for None in a dozen places, and a line
            # that never reached the parsing step used to raise KeyError there
            # instead.
            "ast": None,
            "errors": [],
            "inMacroDefinition": inMacroDefinition,
            "copy": copy,
            "printable": printable,
            "listOn": listOn,
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
        # Skip a card that is the continuation of the one before it.  "The one
        # before it" means the previous line of THIS source -- this file, or
        # this macro body -- and it used to be read as `source[-2]`, the
        # previous entry of the GLOBAL line list, which is a different thing
        # at the boundary between them.  When a macro body began expanding,
        # `source[-2]` was the caller's invocation line, so a CONTINUED
        # INVOCATION made the assembler discard the FIRST STATEMENT OF THE
        # MACRO BODY.
        #
        # In FCMSFAIL that lost the `PUSHNEST IF` from all seven of the IF
        # invocations written across two cards, while the thirty-one written
        # on one card kept it; the nesting stack then went negative, and
        # EXIT's search loop -- which starts at the nesting depth and tests
        # only for zero -- ran until ACTR stopped it 4096 iterations later.
        # That one line accounted for over sixteen thousand diagnostics.
        if lineNumber > 0:
            # Normalised exactly as the current line is a few lines above, so
            # that this decides continuation the same way `continues` does and
            # the ONLY change is that it no longer looks across the boundary
            # between a caller and the macro body it is expanding.
            previous = "%-80s" % thisSource[lineNumber - 1].rstrip()[:80]
            # Asked of the PREVIOUS card the same way the flag above is
            # computed, so that a card the expander spliced in is not
            # discarded here after `continues` has already said it is nobody's
            # continuation.  Reading column 72 raw is what left FIOCGR's
            # `CHI R6,2` dropped even once the flag was right.
            if _continuesOnto(previous, thisSource, lineNumber - 1):
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
        
        if operation == "PRINT":
            if not inMacroDefinition:
                if operand == "ON":
                    listOn = True
                    properties["listOn"] = False
                elif operand == "OFF":
                    listOn = False
                    properties["listOn"] = False
                continue
        
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
            pformals = parserASM(operand, "operandPrototype")
            if pformals != None and "pi" in pformals:
                for sub in pformals["pi"]:
                    if "=" in sub:
                        nonpositional += 1
                    else:
                        positional += 1
            else:
                pass
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
            printTraceMessage(depth, name, operation, operand)
            svSet(operation, name, operand, svLocals, properties)
            continue
        if operation == "ACTR":
            printTraceMessage(depth, name, operation, operand)
            ast = parserASM(operand.rstrip(), "setaOperand")
            if ast == None:
                error(properties, "Cannot parse ACTR operand %s" % operand)
                continue
            n = evalArithmeticExpression(ast["v"], svLocals, properties)
            if n == None:
                error(properties, "Cannot evaluate ACTR operand %s" % operand)
                continue
            actr = n
            continue
        if  operation == "AGO":
            printTraceMessage(depth, name, operation, operand)
            # The operand field ends at the first blank; what follows is a
            # comment.  `rstrip()` alone left the comment attached to the
            # target, so `AGO .LOOP    *** LABEL ...` looked for a sequence
            # symbol whose name included the comment, never found it, and
            # silently skipped the rest of the macro or file.  Same family as
            # the trailing comment that used to defeat SETA.
            target = operand.split()[0] if operand.split() else ""
            if target.startswith("("):
                target = computedAgoTarget(target, svLocals, properties)
                if target == None:
                    # Out of range, so no branch is taken at all.  Fall through
                    # to the next statement WITHOUT charging ACTR: a branch not
                    # taken is not a branch, the same rule AIF already follows.
                    continue
            actr -= 1
            if actr < 0:
                error(properties, actrMessage(fromWhere))
                break
            if target in sequence:
                if fromWhere != sequence[target][0]:
                    error(properties, "Target out of this macro")
                    continue
                lineNumber = sequence[target][1] - 1
            else:
                skipToSeq = target
            continue
        if operation == "AIF":
            printTraceMessage(depth, name, operation, operand)
            operand = operand.rstrip()
            ast = parserASM(operand, "aifAll")
            if isinstance(ast, dict) and "exp" in ast and "seq" in ast:
                target = ast["seq"][0]
                expression = ast["exp"]
                passFail = evalBooleanExpression(expression, svLocals, properties)
                if passFail == None:
                    error(properties, "Cannot evaluate %s" % str(expression))
                    continue
                if not passFail:
                    continue
                # The conditional test has passed.  We must now "go to" the
                # selected sequence symbol.  Only a branch actually taken is
                # counted against ACTR; an AIF whose condition is false is not
                # a branch.
                actr -= 1
                if actr < 0:
                    error(properties, actrMessage(fromWhere))
                    break
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
            printTraceMessage(depth, name, operation, operand)
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
                    pass
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
        
        # FETCH THE MACRO BEFORE ANYTHING ASKS WHETHER THIS IS ONE.  The
        # block just below declines to register the name field of a macro
        # invocation, leaving that to the expansion, and it decides by asking
        # whether the operation is a known macro.  Loading at the point of
        # expansion instead is too late by exactly those few lines:
        # `ASIN AENTRY ...` registered ASIN as an ordinary label AND then
        # expanded a macro that defines it, so every RUNASM module carrying a
        # secondary entry point died with "Already defined".
        if operation not in macros and operation not in pseudoOps:
            loadLibraryMacro(operation)
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
                if operation == "IFPROC":
                    pass
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
            removals = []
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
                    removals.append(i)
                else:
                    error(properties, \
                           "Implementation error in formal parameter " + \
                           str(pformal))
                    continue
            for i in removals:
                del pformals[i]
            # Now do the replacements:
            i = 0
            keyFormals = []
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
                    keyFormals.append(key)
                    newLocals[key] = value
                    newLocals["_" + key]["omitted"] = False
            newLocals["&SYSLIST"] = Sublist(syslist)
            newLocals["&SYSLIST0"] = syslist0
            newLocals["&SYSNDX"] = sysndx
            if trace:
                extra = ""
                for key in keyFormals:
                    extra = f"{extra} {key}={newLocals[key]}"
                printTraceMessage(depth, name, operation, syslist, extra)
            readSourceFile(operation, newLocals, sequence, copy=copy, \
                           printable=printable, depth=depth+1)
        continue

    # Falling off the end still looking for a sequence symbol means everything
    # from the branch onwards was discarded.  Say so.  Silently swallowing the
    # rest of a file or a macro is the worst way for this to fail, and it is
    # how it used to fail.
    if skipToSeq != None and skipToSeq != mendLabel:
        error(properties, \
              "Branch to %s in %s: the sequence symbol was never found, so " \
              "the rest of it was skipped" % (skipToSeq, fromWhere))

# A member that was looked for and is not there, so the library is not
# re-scanned for it once per invocation.
noLibraryMember = set()

# FETCH A LIBRARY MACRO ON DEMAND, by name, the way OS/360 fetches a SYSLIB
# member: the member's name IS the macro's name.  Returns True if `name` is
# defined as a macro afterwards.
#
# WHY NOT SIMPLY READ THE WHOLE LIBRARY UP FRONT, which is what this did.  Every
# member read that way puts its cards into `source` AHEAD of the module, and
# OI340600's library is 26,566 of them.  That is not merely slow:
#
#   - Sequence symbols are file-level, so a library member's `.END` becomes
#     visible to the module's own open code.  FIOPDISP's `AGO .FIOMTU`, whose
#     target is the very next card, started failing with "Target out of this
#     macro" the moment the library was pre-read, and it has no COPY statement
#     and invokes no library macro at all.
#   - A member's OPEN code runs.  MACROS.asm is fifty-one open-code PDEF
#     invocations behind a TITLE, and pre-reading it defined P1-P51 ahead of
#     every module in the corpus.
#
# Reading a member only when something asks for it by name avoids both: a
# member nobody invokes is never opened.  Don Schmidt reached the same
# conclusion independently in asm101, which is where the SYSLIB model here
# comes from.
#
# The member is read with its OWN sequence-symbol namespace rather than the
# shared one, for the first reason above.
def loadLibraryMacro(name):
    global macros, noLibraryMember
    if name in macros:
        return True
    if name in noLibraryMember or name == "" or name[:1] in [".", "&", "="]:
        return False
    for library in libraries:
        if name not in libraryMembers.get(library, set()):
            # Not a macro member of this library.  The index says which of its
            # members define macros and which are COPY fragments, and a COPY
            # fragment read as open code is what puts a DS outside any control
            # section.
            continue
        for candidate in [name, name + ".asm"]:
            path = os.path.join(library, candidate)
            if os.path.isfile(path):
                readSourceFile(path, svGlobalLocals, {}, \
                               copy=False, printable=False, depth=0)
                if name in macros:
                    return True
    noLibraryMember.add(name)
    return False

# Read an entire macro library.
def readMacroLibrary(dir):
    global libraries, libraryMembers
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
    # WHAT THE INDEX NOW DRIVES.  It used to be the list of members read ahead
    # of the module; it is now the list of members ELIGIBLE to be fetched when
    # something invokes them.  Same file, same meaning -- which members define
    # macros and which are for COPY -- but consulted at the moment of use.
    # `makeMACROFILES.py` is what maintains it and must be re-run whenever the
    # library gains members.
    libraryMembers[dir] = { m[:-4] if m.endswith(".asm") else m \
                            for m in macroFiles }
    if not preReadLibraries:
        return
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
# 7, so that severities up to and including 7 are tolerated and 8 upwards are
# not.  That is the System/360 convention:  MNOTE severities become the
# assembly's return code, and 0/4 are informational and warning while 8 is an
# error, 12 severe and 16 terminal.  A return code of 8 or more is a failed
# assembly.
#
# The AP-101S sources are written to it.  Across MLIB80 and RUNMAC the MNOTE
# severities are 1 (50 of them), 2, 3, 4 (54), 5 and 6 -- and then jump
# straight to 8 (73), 9, 10, 12 and 16, with nothing in between.  The gap
# between 6 and 8 is where the boundary belongs.
tolerableSeverity = 7
svGlobals["&SYSPARM"] = "PASS"
# Always-true (by default) global SETB, undeclared by default (no GBLB
# here) so that any source file can reference &ASM101S directly without
# ASM101S.py forcing a declaration on it. A source file that wants to
# detect "am I being assembled by ASM101S specifically, as opposed to a
# genuine historical assembler" declares `GBLB &ASM101S` itself; since
# svDeclare() no-ops on a global that already exists, that self-declaration
# harmlessly preserves this True value here, while the identical
# `GBLB &ASM101S` line assembled by any other, real assembler (which never
# pre-populates this symbol) freshly declares it defaulting to binary
# false. This lets a file carry a deliberate, reversible divergence from
# historical fidelity -- gated by `AIF (&ASM101S)...` -- that is
# completely inert/invisible to any other assembler, with no build-
# invocation flag needed anywhere.
#
# --no-rtl-fixes overrides this to False, i.e., reproduces a genuine
# historical assembler's own lack of any RTL-fix knowledge. The RTL fixes
# gated this way are real bug fixes, but they also change the object-code
# size of whatever module they're in, which cascades into the linker's
# memory-image layout for everything after it. Reproducing a memory image
# exactly as it existed years ago -- even at the cost of the underlying
# bugs those fixes correct -- sometimes matters more than having the
# fixes, hence this override. Checked here, before any source file is
# read, rather than in the command-line-parsing loop below, so that
# --no-rtl-fixes takes effect regardless of where it appears relative to
# the source-file arguments (the parsing loop reads each source file
# in-place as it encounters it, so setting this too late would silently
# fail to affect files already read).
svGlobals["&ASM101S"] = "--no-rtl-fixes" not in sys.argv[1:]
endLibraries = 0 # First line in `source` following macro-library definitions.
comparisonSects = None
comparisonAssigned = {}
comparisonFile = None
sourceFileNames = []

for parm in sys.argv[1:]:
    if parm == "--library":
        scriptDir = Path(__file__).resolve().parent
        runmacDir = f"{scriptDir}{os.sep}..{os.sep}yaShuttle{os.sep}Source Code{os.sep}PASS.REL32V0{os.sep}RUNMAC"
        #print(f"Reading macros from {runmacDir}")
        readMacroLibrary(runmacDir)
        endLibraries = len(source)
    elif parm.startswith("--library="):
        readMacroLibrary(parm.partition("=")[2])
        endLibraries = len(source)
    elif parm.startswith("--object="):
        if not parm.endswith(".obj"):
            print("Object-code filenames must end in .obj", file=sys.stderr)
            sys.exit(1)
        objectFileName = parm.partition("=")[2]
    elif parm.startswith("--sysparm="):
        svGlobals["&SYSPARM"] = parm.partition("=")[2]
    elif parm.startswith("--tolerable="):
        tolerableSeverity = int(parm.partition("=")[2])
    elif parm.startswith("--fill="):
        val = int(parm.partition("=")[2], 16)
        fillPattern[:] = [(val >> 8) & 0xFF, val & 0xFF]
    elif parm.startswith("--compare="):
        comparisonFile = parm.partition("=")[2]
        comparisonSects = readListing(comparisonFile)
        # Snapshot which addresses the listing actually assigns, BEFORE the
        # comparison starts blanking them as it consumes them.  It is what
        # lets an uncovered byte be checked against the gap it sits in.
        if comparisonSects != None:
            comparisonAssigned = { s: [b != None for b in v["memory"]]
                                   for s, v in comparisonSects.items() }
        if comparisonSects == None:
            print("Could not load comparison file %s" % parm.partition("=")[2], file=sys.stderr)
            sys.exit(1)
    elif not parm.startswith("--"):
        if not parm.endswith(".asm"):
            print("Source-code filenames must end with .asm", file=sys.stderr)
            sys.exit(1)
        sourceFileNames.append(parm[:-4])
        if objectFileName == None:
            basename = Path(parm).stem
            objectFileName = basename + ".obj"
        readSourceFile(parm, svGlobalLocals, sequenceGlobalLocals, \
                       copy=False, printable=True, depth=0)
        sourceFileCount += 1
    elif parm in ["--force-d", "--no-force-d"]:
        pass
    elif parm == "--no-rtl-fixes":
        pass # Already accounted for, above, before this loop even starts.
    elif parm in ["--trace"]:
        pass
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
        print("--library           Load the default macro library.  Without")
        print("                    --library or --library=L (see below), no")
        print("                    macro library at all is loaded.")
        print("--library=L         Load a macro library by name, L.  This")
        print("                    option can appear multiple times.")
        print("--sysparm=T         (Default PASS.) Sets the global SET symbol")
        print("                    &SYSPARM. For Space Shuttle flight software,")
        print("                    the allowed choices are BFS and PASS.")
        print("                    Note that while accepted, the BFS option")
        print("                    is presently ignored and produces identical")
        print("                    results to PASS.")
        print("--tolerable=N       (Default 7.) Sets the maximum tolerable")
        print("                    error severity.  All errors detected by")
        print("                    ASM101S itself are severity 255. Errors")
        print("                    reported by MNOTE instructions have a")
        print("                    severity determined by the MNOTE instruction")
        print("                    (i.e., by the source code itself), but")
        print("                    level 1 seems to be used for info messages.")
        print("--compare=F         (Default none.) Specifies the name of an")
        print("                    assembly-listing file whose generated code")
        print("                    is compared to the current assembly.")
        print("--fill=XXXX         Set the fill pattern for uninitialized")
        print("                    locations, in hexadecimal. 0000 by default,")
        print("                    with the common alternatives being C6C6 and")
        print("                    C9FB.")
        print("--force-d           (Default) An option that forces a")
        print("                    particular use of displacements in")
        print("                    RS-type instructions.")
        print("--no-force-d        Opposite of --force-d.")
        print("--trace             Enable tracing mode for debugging assembler")
        print("                    operation.")
        print("--no-rtl-fixes      Reproduce the RTL library's original, historical")
        print("                    behavior -- including its known bugs -- by making")
        print("                    &ASM101S false instead of true. Some RTL source")
        print("                    files use &ASM101S to gate a reversible, otherwise-")
        print("                    invisible bug fix; those fixes change object-code")
        print("                    size, which cascades into the linker's memory-image")
        print("                    layout. Use this switch when reproducing an exact,")
        print("                    historical memory image matters more than having")
        print("                    the fixes.")
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
# Write object file.
if objectFileName != None:
    writeObjectModule(objectFileName, metadata, symtab, sects, entries, extrns)
    print("Output obj: %s" % objectFileName, file=sys.stderr)

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
beyondCount = 0
uncoveredCount = 0
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
previousContext = None
for i in range(endLibraries, len(source)):
    properties = source[i]
    # A continuation only continues the line before it IN THE SAME FILE OR
    # MACRO BODY.  `source` is one flat list spanning both, so at the boundary
    # the previous entry is the macro INVOCATION -- and if that was written
    # across two cards, its `continues` swallowed the first line of the body
    # from the listing.  Same shape as the execution-side defect fixed
    # alongside this, which lost the statement itself rather than its listing.
    context = (properties["depth"], properties["macro"], properties["file"])
    if context != previousContext:
        continuation = False
    previousContext = context
    anyErrors = False
    if "errors" in properties and len(properties["errors"]) > 0:
        print("=====================================================")
        for msg in properties["errors"]:
            print(msg)
        print("=====================================================")
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
        # A TITLE MAY HAVE NO OPERAND, in which case it merely ejects and the
        # heading is left as it was.  The operand arrives as None then, and
        # `.rstrip()` on it is an AttributeError that kills the assembly
        # outright rather than diagnosing anything -- the listing simply stops.
        # It is reachable from ordinary source: FPMIHPC2 hits it once its
        # truncated tail is restored.
        operandText = properties["operand"]
        title = operandText.rstrip()[1:-1] if operandText != None else ""
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
            # A COPIED LINE NEED NOT NAME A FILE.  `Path(None)` raised a
            # TypeError out of the LISTING, so a module that assembled
            # perfectly well died on the way to being printed -- MENU12, once
            # its `COPY MACROS` card was restored.
            memberName = Path(properties["file"]).stem \
                         if properties["file"] else "?"
            if properties["printable"] and properties["listOn"]:
                linesThisPage += 1
                print("         START OF COPY MEMBER %-8s RVL %02d CONCATENATION NO. %03d  NEST %03d" \
                      % (memberName, rvl, concat, nest))
            inCopy = True
    else:
        if inCopy:
            if properties["printable"] and properties["listOn"]:
                linesThisPage += 1
                print("           END OF COPY MEMBER %-8s RVL %02d CONCATENATION NO. %03d  NEST %03d" \
                      % (memberName, rvl, concat, nest))
            inCopy = False
    if properties["printable"] and properties["listOn"]:
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
            # A USING whose base could not be established has no value to
            # print.  It is set only when the first operand evaluates, so
            # every diagnosed USING -- unparsable operand, no value, bad
            # location -- reached this with the key absent and took the whole
            # assembly down with a KeyError, AFTER the diagnostic that
            # explained the real problem had already been printed.
            using = properties.get("using")
            prefix = "" if using is None else "%07X" % using
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
            # EIGHT BYTES, and the cap is not arbitrary: a listing line shows
            # FOUR HALFWORDS and never more, so eight is all the evidence
            # there is.  It is a fixed field width rather than elision of
            # repeats -- FAZ2's `DC X'A92F0A3C,A2DFA000,0000A35...'` generates
            # sixteen bytes of entirely different data and the listing prints
            # A92F0A3CA2DFA000 and stops, with consecutive such statements at
            # 00000, 00008, 00010 and 00018.
            #
            # Comparing beyond it was tried and produced 1180 bytes of "past
            # the end of the listing" for one patch-space module: noise, not
            # verification.
            for i in range(min(8, len(properties["assembled"]))):
                b = properties["assembled"][i]
                if comparisonMemory != None:
                    oaddress = address + offset * 2
                    if oaddress >= len(comparisonMemory):
                        # Generated code running past the end of the listing
                        # used to be an IndexError, which killed the run and
                        # took the whole comparison with it -- and it is
                        # exactly the shape of failure --compare exists to
                        # report, since a build that emits MORE than the
                        # listing did has a real discrepancy.  Count it and
                        # carry on.
                        beyondCount += 1
                        address += 1
                        if i == 0 or ((i & 1) == 0 and \
                                      properties["operation"] != "DC"):
                            prefix += " "
                        prefix += "%02X" % b
                        continue
                    if comparisonMemory[oaddress] == None:
                        # THE LISTING SAYS NOTHING ABOUT THIS ADDRESS, so it
                        # cannot contradict us.  It happens where the original
                        # listing prints a statement with neither location nor
                        # object code while the location counter still
                        # advances over it -- FIOMS4DT's
                        # `DC Y((&HPLIIC+792+15)/16)` is one, sitting between
                        # constants at 00000 and 00002 with 00001 plainly
                        # consumed and nothing shown for it.
                        #
                        # Counting those as mismatches made 32 bytes across
                        # two modules look wrong when the listing simply had
                        # no opinion.  They are reported separately: not
                        # verified, but not contradicted either.
                        uncoveredCount += 1
                    elif b != comparisonMemory[oaddress]:
                        mismatchCount += 1
                        print("Comparison mismatch: %02X vs %02X" % \
                              (b, comparisonMemory[oaddress]))
                    comparisonMemory[oaddress] = None
                    address += 1
                if i == 0 or ((i & 1) == 0 and \
                              properties["operation"] != "DC"):
                    prefix += " "
                prefix += "%02X" % b
        if "adr1" in properties:
            prefix = "%-21s%04X" % (prefix, properties["adr1"]&0xFFFF)
        if "adr2" in properties:
            prefix = "%-26s%04X" % (prefix, properties["adr2"]&0xFFFF)
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
            mid = "%-30s%5d%s%-8s %-7s %s" % (
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
                if address < len(amemory) and memory[address] == amemory[address]:
                    continue
            else:
                c = "L"
                if address < len(amemory) and memory[address] == amemory[address]:
                    continue
            if not headerShown:
                print('Missing object code from section "%s":' % sect)
                headerShown = True
            print("\t%05X(%c): %02X" % (address // 2, c, memory[address]))
            mismatchCount1 += 1
    if uncoveredCount > 0:
        # An uncovered byte is safe to disregard when it lies in an INTERIOR
        # GAP -- a run the listing leaves blank with assigned bytes on BOTH
        # sides.  The gap then pins how many bytes belong there even though it
        # says nothing about their values, and our filling it exactly is why
        # everything after it still lines up.  An uncovered byte NOT in such a
        # gap is a different matter and is called out separately, because
        # nothing bounds it.
        bounded = 0
        gaps = 0
        for s, assigned in comparisonAssigned.items():
            i = 0
            while i < len(assigned):
                if not assigned[i]:
                    j = i
                    while j < len(assigned) and not assigned[j]:
                        j += 1
                    if i > 0 and assigned[i-1] and j < len(assigned) and assigned[j]:
                        bounded += j - i
                        gaps += 1
                    i = j
                else:
                    i += 1
        print("%d byte(s) lie at addresses the comparison listing shows no "
              "object code for, of which %d fall in %d interior gap(s) the "
              "listing brackets on both sides -- their COUNT is pinned by the "
              "gap, their VALUES are not shown and stay unverified"
              % (uncoveredCount, min(uncoveredCount, bounded), gaps))
        if uncoveredCount > bounded:
            print("%d of them are NOT bounded by a gap and nothing constrains "
                  "them at all" % (uncoveredCount - bounded))
    if beyondCount > 0:
        print("%d byte(s) of generated code lie past the end of the "
              "comparison listing and could not be compared" % beyondCount)
    print("%s: %d bytes mismatched and %d bytes missing in generated code%s" % \
          (",".join(sourceFileNames), mismatchCount, mismatchCount1,
           "" if beyondCount == 0 else \
           ", and %d bytes past the end of the listing" % beyondCount))
    
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
        