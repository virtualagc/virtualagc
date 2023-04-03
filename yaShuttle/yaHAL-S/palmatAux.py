#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       palmatAux.py
Purpose:        Part of the code-generation system for the "modern" HAL/S
                compiler yaHAL-S-FC.py+modernHAL-S-FC.c. Some auxliary functions
                used in several modules.
History:        2023-01-10 RSB  Split off from PALMAT.py.
                2023-02-13 RSB  Refactored all bit arrays from the old format
                                [(value, length)] to the new format of
                                [value, length, "b"].  Introduced the new 
                                functions formBitArray() and parseBitArray(),
                                so that if other modules use these functions,
                                they'll be insulated from future changes to the
                                format (of which I don't expect any).
"""

import json
import re
import copy
import math
from math import nan as NaN
from decimal import Decimal, ROUND_HALF_UP

# The following patterns are used the same way as "\\b" would be used in a 
# regex at the start and end of a pattern to indicate a word boundary.  The 
# difference is that (effectively) they add "." to the list of "word
# characters", so that a match cannot be immediately preceded or followed by a
# "." (perhaps surrounded by spaces.  This extension is necessary for mangling 
# of structure fields, in which the field separator is ".".  For example, if 
# we have a fully-qualified field expression like a.b.c.d, we want our mangling
# to match the full "a.b.c.d" and not match (for example) "a" or "a.b", or 
# "a.b.c".  The techniques used are, respectively, "negative lookbehind" and 
# "negative lookahead", if you want to look them up in the Python regex docs.
# The technique isn't perfect, unfortunately, because look-behind requires a 
# fixed-length pattern, so all I can really check for is that there's no leading
# "."; I can't check for a leading dot and some unknown number of spaces.
# Fortunately, lookahed isn't restricted like that.
fqStart = "(?<!\\.)\\b"
fqEnd = "\\b(?!\\s*\\.)"

# math.isnan() doesn't work on lists, tuples, dictionaries, or sets, as I found
# out the hard way since it's not documented in the Python docs, which implies
# that it works on anything.  So it must be modified as follows.
def isNaN(object):
    if object == None or isinstance(object, (list, tuple, dict, set, str)):
        return False
    return math.isnan(object)

# Add a `debug` PALMAT instruction.
def debug(PALMAT, state, message):
    return
    PALMAT["scopes"][state["scopeIndex"]]["instructions"].append({
            'debug': message
        })

# Workaround for the fact that separators I'd like to use with Python's .split() 
# method may sometimes occur within parethesized argument lists where I don't
# actually want a split to occur.  Tailored for HAL/S.  In other words, 
# splitOutsideParentheses(string) or splitOutside Parentheses(string, separator)
# works just like string.split() or string.split(separater), except that the 
# splits won't occur anywhere between parentheses.  For the default case
# (splitting on whitspace), a split also won't occur immediately preceding a
# leading parenthesis (for cases like an attribute "VECTOR (5)".  Note that
# maxsplit isn't supported.
def splitOutsideParentheses(string, separator=None):
    fullTrim = False
    if separator == None:
        # Collapse multiple whitespace characters to a single actual space.
        string = " ".join(string.strip().split())
        # And eliminate whitespace preceding a leading parenthesis.
        string = string.replace(" (", "(")
        separator = " "
        fullTrim = True # Gets rid of whitespace within parentheses.
    start = 0
    parenCount = 0
    fields = []
    for i in range(len(string)):
        c = string[i]
        if c == "(":
            parenCount += 1
        elif c == ")":
            parenCount -= 1
        elif parenCount == 0 and c == separator:
            if fullTrim:
                fields.append(string[start:i].replace(" ", ""))
            else:
                fields.append(string[start:i])
            start = i + 1
    if fullTrim:
        fields.append(string[start:].replace(" ", ""))
    else:
        fields.append(string[start:])
    return fields

# Append a PALMAT instruction, with line/column reference if possible.
def appendInstruction(instructions, instruction, source, insert=-1):
    if source[1:] != [-1, -1]:
        instruction = copy.deepcopy(instruction)
        instruction["source"] = copy.deepcopy(source)
    if insert >= 0:
        instructions[insert:insert] = [instruction]
    else:
        instructions.append(instruction)

# Configures HAL/S source-file name for astToLbnf() (see below).
astSourceIndex = -1
def astSourceFile(PALMAT, filename):
    global astSourceIndex
    if filename not in PALMAT["sourceFiles"]:
        PALMAT["sourceFiles"].append(filename)
    astSourceIndex = PALMAT["sourceFiles"].index(filename)

# Using some state machines (expressionSM, doForSM) which are passed an ast
# object, it's necessary to construct an lbnfLabel and a source list (which
# gives the reference to the original HAL/S source code).  This function does
# that.
def astToLbnf(ast):
    source = [astSourceIndex, -1, -1]
    if isinstance(ast, dict):
        lbnfLabel = ast["lbnfLabel"]
        if "lineNumber" in ast:
            source[1] = ast["lineNumber"]
            if "columnNumber" in ast:
                source[2] = ast["columnNumber"]
        if lbnfLabel[:2].isupper():
            lbnfLabel = lbnfLabel[2:]
    else:
        lbnfLabel = ast
    return lbnfLabel, source

'''
This is a replacement for Python's round() function, which I'd like to use
for a direct implementation of the HAL/S ROUND() function, but can't due to 
incompatibility.  Python's round() function uses a method apparently called 
"banker's rounding", in which everything rounds just as you'd expect except 
that numbers which are *exactly* integer+1/2 round (from my and HAL'S's 
perspective) very oddly: they round to the nearest *even* integer.  For 
example, 1.5 and 2.5 both round to 2, 3.5 and 4.5 both round to 4, and so on. 
As far as HAL/S is concerned, the documentation isn't 100% explicit in this
regard since they apparently don't know there are daft alternatives, but the 
explanations on p. 3-4 (PDF p. 42) of [PIH] make it pretty 
clear that banker's rounding is *not* what was envisaged; 0.5 is supposed to 
round to 1, 3.5 is supposed to round to 4.  (What's left undiscussed are cases 
like -1.5 or -2.5.  Oh well!)  Therefore, the following function is provided to 
account for rounding that's closer to what's needed.  I think!
'''
def hround(x):
    return int(Decimal(x).to_integral_value(rounding=ROUND_HALF_UP))

'''
The following code is intended to determine the precision (number of 
significant digits allowable to the right of the decimal point)
of floating-point values.  The precision may actually be slightly
higher than what I compute, because I subtract 1 decimal place, but 
subtracting the 1 gets rid of a lot of nasty-looking printouts.
'''
precision = len(str(math.pi).split(".")[1]) - 1
fpFormat = "%+2." + ("%d" % precision) + "e"

'''
The POUND constant replaces the # symbol in subscripts during code 
generation.  During emulation, any subscript greater than MAXDIMWIDTH
is adjusted downward by MAXDIMWIDTH and incremented by the width of the
corresponding dimension.  This trick allows # to be used in expressions
in subscripts without introducing any tricky machinery to allow it.
Of course, it means no VECTOR of length greater than MAXDIMWIDTH, and so on,
but that doesn't seem like much of a drawback.  (I'm not aware of any other
use of MAXDIMWIDTH; I don't do any tests vs it in declarations.
'''
MAXDIMWIDTH = 1000000000
POUND = 2 * MAXDIMWIDTH
def unpound(subscript, width):
    if subscript > MAXDIMWIDTH:
        return subscript - POUND + width
    return subscript

# Format a number (INTEGER, SCALAR) as a string, as in WRITE statements, and
# return it.  Or else None on failure.
def formatNumberAsString(value):
    if isinstance(value, int):
        return "%d" % value
    elif value == 0.0:
        return " 0.0"
    elif isinstance(value, float):
        value = fpFormat % value
        if value[:1] == "+":
            value = " " + value[1:]
        value = value.replace("e", "E")
        return value
    return None

'''
Convert a stringified HAL/S number (i.e., an INTEGER or SCALAR presented
as a string, possibly with B, H, or E type exponents) into a Python
float.

Recall that HAL/S literal numbers can include modifiers like "B-12" or "H7" in 
addition to the usual "E23".  Python of course has no knowledge of these 
additional funky modifiers, so we have to handle them explicitly.  
Unfortunately this can make the numerical version inexact compared to the 
stringified version, and not inexact in the same way as the original IBM 360 or 
AP-101S representations were. At some point I'll probably make the compiler do 
this work for the sake of efficiency, but as for now I keep the accuracy for
as long as possible, so the compiler provides us with "stringified" numbers
and thus the emulator has to do this unpacking at runtime.
'''
def stringifiedToFloat(stringifiedNumber):
    multiplier = 1.0
    while True:
        match = re.search("[EBH][-]?[0-9]+$", stringifiedNumber)
        if match == None:
            break
        modifier = match.group()
        stringifiedNumber = stringifiedNumber[:match.span()[0]]
        if modifier[0] == "E":
            multiplier *= 10 ** (int(modifier[1:]))
        elif modifier[0] == "B":
            multiplier *= 2 ** (int(modifier[1:]))
        else: # modifier[0] == "H":
            multiplier *= 16 ** (int(modifier[1:]))
    return float(stringifiedNumber) * multiplier

# Test if data is completely initialized.
def isCompletelyInitialized(object):
    if object == None:
        return False
    elif isinstance(object, dict):
        for key in object:
            if not isCompletelyInitialized(object[key]):
                return False
    elif isinstance(object, (list, tuple)):
        for element in object:
            if not isCompletelyInitialized(element):
                return False
    return True

# Quick check if value is array.  Fuller test is isArrayGeometry() in
# executePALMAT.
def isArrayQuick(value):
    if not isinstance(value, list) or len(value) < 2 or value[-1] != "a":
        return False
    return True

# Get dimensions of an Array.  Doesn't check that it *is* and ARRAY, but just
# gets the dimensions assuming that it is.  The return value is the list of
# dimensions and a representative value of the array's entries.  If this
# is not an uninitialized value, we can use it very quickly to determine some
# gross aspects of the datatype.  If it is uninitialized ... well, too bad.
def getArrayDimensions(value):
    dimensions = []
    while isArrayQuick(value):
        dimensions.append(len(value) - 1)
        value = value[0]
    if value == None: # This particular value uninitialized?
        unraveled = []
        flatten(value, unraveled)
        for value in unraveled:
            if value != None:
                break
    return dimensions, value

# Test if a value on the computation stack is a boolean.
def isBitArray(value):
    return isinstance(value, list) and len(value) == 3 and value[2] == "b" \
            and isinstance(value[0], int) and isinstance(value[1], int)

'''
Apply a unary function to each element of an array, returning an array of the
same geometry, or NaN on failure.  (The unary function must also return NaN
on error.  Python None is a proper return, because it signifies an uninitialized
value rather than an illegal operation.)
'''
def unaryOperation(PALMAT, function, array):
    if isArrayQuick(array):
        dimensions, dummy = getArrayDimensions(array)
    else:
        dimensions = []
    if len(dimensions) > 0:
        result = []
        for a in array[:-1]:
            r = unaryOperation(PALMAT, function, a)
            if isNaN(r):
                return NaN
            result.append(r)
        result.append("a")
    else:
        # We're at a leaf element, apply the function to it.
        if array == None:
            return None
        return function(PALMAT, array)
    return result

'''
Apply a binary function to two objects, either or both of which being arrays
(of the same geometry if both are arrays), but otherwise of compatible datatypes
when the arrayness is ignored.  Returns the result of the operation, either
as an array (if one or both operands were arrays) or a non-array (if neither
operand was an array). Or else returns NaN on failure.
(The binary function must also return NaN on error.
Python None is a proper return, because it signifies an uninitialized
value rather than an illegal operation.) 
'''
def binaryOperation(PALMAT, function, array1, array2):
    if isArrayQuick(array1):
        dimensions1, dummy = getArrayDimensions(array1)
    else:
        dimensions1 = []
    if isArrayQuick(array2):
        dimensions2, dummy = getArrayDimensions(array2)
    else:
        dimensions2 = []
    # The list called "dimensions" will be the array dimensions if either 
    # operand (and thus the output result) are to be arrays.  If dimensions==[],
    # then neither the operands nor the output is an array.
    if dimensions1 == []:
        dimensions = dimensions2
    elif dimensions2 == []:
        dimensions = dimensions1
    elif dimensions1 != dimensions2:
        return NaN
    else:
        dimensions = dimensions1
    if len(dimensions) > 0:
        result = []
        for i in range(dimensions[0]):
            if dimensions1 == []:
                child1 = array1
            else:
                child1 = array1[i]
            if dimensions2 == []:
                child2 = array2
            else:
                child2 = array2[i]
            r = binaryOperation(PALMAT, function, child1, child2)
            if isNaN(r):
                return NaN
            result.append(r)
        result.append("a")
    else:
        # We're at a leaf element, so apply the function right now and 
        # stop recursing.
        if array1 == None or array2 == None:
            return None
        result = function(PALMAT, array1, array2)
    return result

'''
Apply a trinary function to three objects, any of which can be arrays
(of identical geometries), but otherwise of compatible datatypes
when the arrayness is ignored.  Returns the result of the operation, either
as an array (if some operands were arrays) or a non-array (if no
operand was an array). Or else returns NaN on failure.
(The trinary function must also return NaN on error.
Python None is a proper return, because it signifies an uninitialized
value rather than an illegal operation.) 
As far as I know, the only use-case for trinaryOperation() is the RTL
function MIDVAL().
'''
def trinaryOperation(PALMAT, function, array1, array2, array3):
    if isArrayQuick(array1):
        dimensions1, dummy = getArrayDimensions(array1)
    else:
        dimensions1 = []
    if isArrayQuick(array2):
        dimensions2, dummy = getArrayDimensions(array2)
    else:
        dimensions2 = []
    if isArrayQuick(array3):
        dimensions3, dummy = getArrayDimensions(array3)
    else:
        dimensions3 = []
    # The list called "dimensions" will be the array dimensions if any 
    # operand (and thus the output result) are to be arrays.  If dimensions==[],
    # then neither the operands nor the output are arrays.
    if dimensions1 != []:
        dimensions = dimensions1
        if (dimensions2 != [] and dimensions2 != dimensions1) or \
                (dimensions3 != [] and dimensions3 != dimensions1):
            return NaN
    elif dimensions2 != []:
        dimensions = dimensions2
        if dimensions3 != [] and dimensions3 != dimensions2:
            return NaN
    else:
        dimensions = dimensions3
        
    if len(dimensions) > 0:
        result = []
        for i in range(dimensions[0]):
            if dimensions1 == []:
                child1 = array1
            else:
                child1 = array1[i]
            if dimensions2 == []:
                child2 = array2
            else:
                child2 = array2[i]
            if dimensions3 == []:
                child3 = array3
            else:
                child3 = array3[i]
            r = trinaryOperation(PALMAT, function, child1, child2, child3)
            if isNaN(r):
                return NaN
            result.append(r)
        result.append("a")
    else:
        # We're at a leaf element, so apply the function right now and 
        # stop recursing.
        if array1 == None or array2 == None or array3 == None:
            return None
        result = function(PALMAT, array1, array2, array3)
    return result

def formBitArray(value, length):
    if isinstance(value, int):
        pass
    elif isinstance(value, float):
        value = hround(value)
    elif isinstance(value, str):
        value = int(value)
    elif isBitArray(value):
        value = value[0]
    return [value & ((1 << length) - 1), length, "b"]
hTRUE = formBitArray(1, 1)
hFALSE = formBitArray(0, 1)

def parseBitArray(bitArray):
    return bitArray[0], bitArray[1]

# "Flatten" a composite object (VECTOR, MATRIX, ARRAY) onto the end of a list.
# Not sure what to do about STRUCTURE yet.
def flatten(object, onto):
    if isBitArray(object):
        onto.append(object)
    elif isArrayQuick(object):
        for e in object[:-1]:
            flatten(e, onto)
    elif isinstance(object, list):
        for e in object:
            flatten(e, onto)
    else:
        onto.append(object)

# This is used when a problem with a block is sufficiently severe that 
# it has to be removed.  That necessitates removing its parent, grandparent,
# and so on that have already been allocated, up to but not including the root.  
# It suffices to just unlink at the root.
def removeAncestors(PALMAT, scopeIndex):
    lastScopeIndex = None
    while scopeIndex not in [None, 0]:
        lastScopeIndex = scopeIndex
        scopeIndex = PALMAT["scopes"][scopeIndex]["parent"]
    if scopeIndex != None and lastScopeIndex != None:
        PALMAT["scopes"][scopeIndex]["children"].remove(lastScopeIndex)
        PALMAT["scopes"][lastScopeIndex]["parent"] = None

# Adds/modifies an attribute for an identifier in an identifier list.
# The identifier should include its carat quotes.
def addAttribute(identifiers, identifier, attribute, \
                 value, overwrite=False):
    if identifier not in identifiers:
        identifiers[identifier] = {}
    if attribute not in identifiers[identifier] or overwrite:
        identifiers[identifier][attribute] = value
    
# HAL/S has no dynamic memory allocation, so there's no "garbage" in that 
# sense.  However, when operating this program (yaHAL-S-FC.py) as an 
# interpreter, there is an assumulation of PALMAT scopes which can no longer
# accessed, as well as an accumulation of compiler-created identifiers used
# with those inaccessible scopes.  This subroutine eliminates those.
autocreatedLabelPattern = "\\^[a-z][a-z]_[0-9]+\\^"
def isAutocreatedLabel(identifier):
    return None != re.fullmatch(autocreatedLabelPattern, identifier)

def collectGarbage(PALMAT):
    
    # Recursive function that marks scopes as unreachable.  Scope 0 is always
    # reachable, as are any PROGRAM, FUNCTION, PROCEDURE, COMPOOL, etc. blocks
    # with identifiers in scope 0.  However, DO, DO FOR, DO WHILE, DO UNTIL,
    # and IF blocks that are children of scope 0 are not.  And all the children
    # of all blocks unreachable from block 0 are unreachable as well.
    def findUnreachableScopes(scopeIndex=0, level=0):
        scope = PALMAT["scopes"][scopeIndex]
        if level == 0:
            # This scope (the root, scopeIndex=0) is a keeper, but its
            # descendents may not be.
            pass
        elif level == 1 and scope["type"] not in \
                ["do", "do for", "do for discrete", "do until", "do while", "if"]:
            # This scope and all of its descendents are keepers.
            return
        else:
            # This scope and all of its descendents are doomed. 
            # DOOMED, I tell you!
            scope["unreachable"] = True
        for child in scope["children"]:
            findUnreachableScopes(child, level+1)
    
    def findObsoleted(scopeIndex):
        scope = PALMAT["scopes"][scopeIndex]
        scope["unreachable"] = True
        for i in scope["children"]:
            findObsoleted(i)
    
    # Scopes disconnected from the root of the tree are unreachable.
    for i in range(1, len(PALMAT["scopes"])):
        if PALMAT["scopes"][i]["parent"] == None:
            findObsoleted(i)
    
    # Now look at the still-connected scopes.
    findUnreachableScopes()
    children0 = PALMAT["scopes"][0]["children"]
    for i in range(len(PALMAT["scopes"])-1, 0, -1):
        if "unreachable" not in PALMAT["scopes"][i]:
            break
        PALMAT["scopes"].pop()
        if i in children0:
            children0.remove(i)
    
    # Get rid of all PALMAT instructions in scope 0.
    PALMAT["scopes"][0]["instructions"].clear()
    
    # Eliminate all identifiers that are compiler-generated 
    # identifiers, since every single one of them refers to unreachable blocks,
    # or no-longer-existent PALMAT instructions.
    identifiers = PALMAT["scopes"][0]["identifiers"]
    for identifier in list(identifiers.keys()):
        if isAutocreatedLabel(identifier):
            identifiers.pop(identifier)
    
# Compute the length of the instructions array, sans 'debug' instructions.
def lenInstructions(instructions):
    i = 0
    for instruction in instructions:
        if 'debug' not in instruction:
            i += 1
    return i

# Pop the topmost instruction that isn't a 'debug'.
def popInstruction(instructions):
    while len(instructions) > 0:
        instruction = instructions.pop()
        if 'debug' not in instruction:
            return instruction
    return None

# Save an internal PALMAT object to a file. (Actually, it's just a conversion
# of *any* Python object to JSON for writing it to a file, but our use for it
# just happens to be for Python objects representing PALMAT datasets.)
# Returns True for success, False for failure.
def writePALMAT(PALMAT, filename):
    try:
        f = open(filename, "w")
        print(json.dumps(PALMAT), file=f)
        f.close()
        return True
    except:
        return False

# Load a PALMAT object from a file into internal storage.  Returns either the
# PALMAT object on success, or None on failure.
def readPALMAT(filename):
    try:
        f = open(filename, "r")
        PALMAT = json.loads(f.readline())
        f.close()
        return PALMAT
    except:
        return None

#-----------------------------------------------------------------------------
# PALMAT-object operations.

# Create a new, empty scope.
def constructScope(selfIndex=0, parentIndex=None, scopeType="root"):
    scope = {
                "parent"            : parentIndex,
                "self"              : selfIndex,
                "children"          : [ ],
                "identifiers"       : { },
                "instructions"      : [ ],
                "type"              : scopeType,
                "structureTemplates": {}
            }
    return scope

# Create a new, empty PALMAT object.
def constructPALMAT(instantiation=0):
    return  {
                "scopes" : [ constructScope() ],
                "instantiation": 0,
                "sourceFiles": []
            }

# Search upward through the scope hierarchy, trying to find the first enclosing
# loop. Returns the scope dictionary for the loop, or else None.
def findEnclosingLoop(PALMAT, scope):
    while scope != None:
        if scope["type"] in ["do while", "do until", "do for", "do for discrete"]:
            return scope
        parent = scope["parent"]
        if parent == None:
            break
        scope = PALMAT["scopes"][parent]
    return None

# Add a memory scope to existing PALMAT.  Returns the index of the new scope.
# (There's really no need for it to return even that, since the new scope's
# index will always be len(PALMAT["scopes"])-1, but it may save the calling 
# program from having to do that minimal arithmetic.)
def addScope(PALMAT, parentIndex, scopeType="unknown"):
    newIndex = len(PALMAT["scopes"])
    newScope = constructScope(newIndex, parentIndex, scopeType)
    parentScope = PALMAT["scopes"][parentIndex]
    parentScope["children"].append(newIndex)
    PALMAT["scopes"].append(newScope)
    return newIndex

# Print a PALMAT object in a reasonably-human-friendly way, for debugging 
# purposes.
def printPALMAT(PALMAT, showInstructions=False):
    
    def printSingleScope(scope, showInstructions):
        print("Scope:  Parent:       ", scope["parent"])
        print("        Self:         ", scope["self"])
        print("        Children:     ", scope["children"])
        first = True
        for identifier in sorted(scope["identifiers"]):
            if first:
                first = False
                print("        Identifiers:  ", end="")
            else:
                print("                      ", end="")
            print(" %s" % identifier, end="")
            metadata = scope["identifiers"][identifier]
            for key in metadata:
                print(" %s=%r" % (key, metadata[key]), end="")
            print()
            if len(scope["instructions"]) == 0:
                print("        Instructions: [ ]")
        if showInstructions:
            print("        Instructions: ", end="")
            indent = 0
            instructions = scope["instructions"]
            for instruction in instructions:
                print("%*s" % (indent, ""), instruction)
                indent = 8
        else:
            print("        Instructions: [ ... ]")

    for scope in PALMAT["scopes"]:
        printSingleScope(scope, showInstructions)
        
# Search for an identifier in the scope hierarchy, starting at the
# current scope and working upward through the parent scope, grandparent scope,
# and so on.  Returns None if not found, or an ordered pair consisting of the
# index of the found scope and the attributes of the identifier.
# The search works differently when the variable is for writing rather than 
# reading.  For reading, all variables in ancestor scopes are allowed.
# Whereas for writing, we cannot look outside of the enclosing FUNCTION or 
# PROCEDURE.  And indeed, even there, we cannot write to FUNCTION or PROCEDURE
# parameters.  On the other hand, for variables defined in a PROCEDURE ASSIGN,
# the restriction is lifted and for those variables alone we can search the
# ancestors.
def findIdentifier(identifier, PALMAT, scopeIndex=None, write=False):
    while scopeIndex != None:
        scope = PALMAT["scopes"][scopeIndex]
        inUnit = \
            (scope["type"] in ["function", "procedure", "program"])
        assignment = False
        if identifier in scope["identifiers"]:
            attributes = scope["identifiers"][identifier]
            assignment = ("assignment" in attributes)
            if not assignment:
                if write and inUnit and \
                        "parameter" in attributes:
                    return -1, None     # Attempt to write parameter, no good!
                return scopeIndex, attributes
            else:
                return -1, attributes   # An ASSIGN, good!
        if write and inUnit and not assignment:
            if scope["type"] == "program":
                # Better check COMPOOLs.
                break
            return -1, None # Didn't find writable in FUNCION or PROCEDURE.
        scopeIndex = scope["parent"]
    # Haven't found it, and haven't eliminated it.  Check all of the COMPOOLs.
    topChildren = PALMAT["scopes"][0]["children"]
    for i in range(len(topChildren)):
        if PALMAT["scopes"][i]["type"] == "compool" and \
                identifier in PALMAT["scopes"][i]["identifiers"]:
            return i, PALMAT["scopes"][i]["identifiers"][identifier]
    return -1, None

# "Expands" all of the structure-TEMPLATE references within a structure TEMPLATE,
# returning a new template.  Or returns None on error.
def expandStructureTemplate(PALMAT, scopeIndex, template):
    if "structure" in template:
        s = template["structure"]
        identifier = "^s_" + s[:-10] + "^"
        si, attributes = findIdentifier(identifier, PALMAT, scopeIndex)
        if attributes == None or "template" not in attributes:
            return None
        template = attributes
    newTemplate = copy.deepcopy(template)
    if "template" in newTemplate:
        fieldAttributes = newTemplate["template"][1]
        for i in range(len(fieldAttributes)):
            fieldAttributes[i] = expandStructureTemplate(PALMAT, scopeIndex, \
                                                         fieldAttributes[i])
    return newTemplate

# This is for searching for identifiers when the proper name-mangling prefix
# isn't known.  All it does is to return a tuple consisting of the scope index
# and the mangled identifier, or else -1 if not found.
def flexFindIdentifier(identifier, PALMAT, scopeIndex):
    prefixes = ["", "l_", "b_", "c_", "s_", "e_", "a_", "bf_", "cf_", "sf_"]
    while scopeIndex != None:
        scope = PALMAT["scopes"][scopeIndex]
        identifiers = scope["identifiers"]
        for p in prefixes:
            mangled = "^" + p + identifier + "^"
            if mangled in identifiers:
                return scopeIndex, mangled
        scopeIndex = scope["parent"]
    return -1, identifier

#-----------------------------------------------------------------------------
'''
These auxiliary functions are used to create child (DO ... END) blocks and
to provide the various label identifiers for PALMAT instructions like 'goto',
'iffalse', and 'iftrue' that are used to jump in, out, and within these
blocks.  We use a kind of trick to help us with this
'''

def constructLabel(scopeIndex, xx):
    return "%s_%d" % (xx, scopeIndex)

# This function creates a label for an internal jump within a DO...END,
# and inserts a noop instruction with that label. Returns the new label. 
def createTarget(PALMAT, source, fromIndex, toIndex, xx, nameFromFrom=False):
    scopes = PALMAT["scopes"]
    namespaceIndex = min(fromIndex, toIndex)
    fromScope = scopes[fromIndex]
    toScope = scopes[toIndex]
    namespaceScope = scopes[namespaceIndex]
    if nameFromFrom:
        identifier = "^" + constructLabel(fromIndex, xx) + "^"
    else:
        identifier = "^" + constructLabel(toIndex, xx) + "^"
    instructions = toScope["instructions"]
    toOffset = len(instructions)
    appendInstruction(instructions, {'noop': True, 'label': identifier}, source)
    identifiers = namespaceScope['identifiers']
    identifiers[identifier] = {'label': [toIndex, toOffset] }
    return identifier

# This function inserts a PALMAT instruction that jumps to an target
# created (previously or later on) by createTarget().  The palmatOpcode 
# is one of the jumpInstructions list.  jumpToTarget() 
# can be used multiple times for the same label, and can either precede
# or follow createTarget(). 
jumpInstructions = ['goto', 'iffalse', 'iftrue']
def jumpToTarget(PALMAT, source, fromIndex, toIndex, xx, palmatOpcode, \
                 nameFromFrom=False, parentIndex=None):

    instructions = PALMAT["scopes"][fromIndex]["instructions"]
    if nameFromFrom:
        si = fromIndex
    else:
        si = toIndex
    if parentIndex != None:
        li = parentIndex
    elif fromIndex <= toIndex:
        li = fromIndex
    else:
        li = toIndex
    label = constructLabel(si, xx)
    appendInstruction(instructions, \
                      {palmatOpcode: (li, "^" + label + "^")}, source)

uniqueVariableCounter = 0
def createVariable(scope, xx, attributes):
    global uniqueVariableCounter
    identifier = "%s_%d" % (xx, uniqueVariableCounter)
    uniqueVariableCounter += 1
    scope["identifiers"]["^" + identifier + "^"] = attributes
    return identifier

# This function is used by a parent scope to create a child scope that's
# a DO ... END, and to goto it.  (Also for IF statements.)  The new child 
# scope is returned. Note that makeDoEnd() creates labels with xx = ue and ur,
# so those do not need to be created separately by createTargetLabel().
# The parameter dummyTargets is an optional array of additional 
# targets to add after the initial ue_ target. 
def makeDoEnd(PALMAT, source, parentScope, scopeType="unknown"):
    parentIndex = parentScope["self"]
    childIndex = addScope(PALMAT, parentIndex, scopeType)
    createTarget(PALMAT, source, parentIndex, childIndex, "ue")
    PALMAT["scopes"][childIndex]["instructions"].append({"automatics": True})
    createTarget(PALMAT, source, parentIndex, childIndex, "ug")
    jumpToTarget(PALMAT, source, parentIndex, childIndex, "ue", "goto")
    createTarget(PALMAT, source, childIndex, parentIndex, "ur", True)
    return childIndex, PALMAT["scopes"][childIndex]

# This function is used to exit from a DO loop back to the parent context,
# assuming it was all set up by makeDoEnd().
def exitDo(PALMAT, source, fromIndex, toIndex):
    jumpToTarget(PALMAT, source, fromIndex, toIndex, "ur", "goto", True)

#-----------------------------------------------------------------------------
# The code generator (ast -> PALMAT).

# Variables DECLARE'd without a type are by default SCALAR, though they
# can be explicitly DECLARE'd as SCALAR as well.  This irks me, because
# it means that some SCALAR variables have the attribut "scalar" in
# PALMAT["identifiers"] and some do not.  Declarations of all other 
# datatypes are, on the other hand, explicit.  The point of the following
# function is to clean that up by adding the "scalar" attribute to any
# identifiers not explicitly declared as some other type.
notUnmarkedScalars = ("scalar", "integer", "vector", "matrix", "bit",
                      "character", "template", "structure", "label", 
                      "procedure", "program", "compool")
def isUnmarkedScalar(identifierDict):
    for s in notUnmarkedScalars:
        if s in identifierDict:
            return False
    return True

def markUnmarkedScalars(identifiers):
    for i in identifiers:
        identifier = identifiers[i]
        if isUnmarkedScalar(identifier):
            identifier["scalar"] = True

# Returns an uninitialized VECTOR, MATRIX, ARRAY, ARRAY VECTOR, or ARRAY MATRIX.
def uninitializedComposite(arrayDimensions, dimensions):
    composite = []
    if len(arrayDimensions) > 0:
        for i in range(arrayDimensions[0]):
            composite.append(uninitializedComposite(arrayDimensions[1:], \
                                                    dimensions))
        composite.append("a")
        return composite
    if len(dimensions) > 0:
        for i in range(dimensions[0]):
            composite.append(uninitializedComposite([], \
                                                    dimensions[1:]))
        return composite
    return None

# Returns an uninitialized STRUCTURE, given the attributes of the associated
# structure template, or NaN on error.
def uninitializedStructure(PALMAT, currentScope, templateName, templateAttributes):
    currentIndex = currentScope["self"]
    if "template" in templateAttributes:
        fieldNames = templateAttributes["template"][0]
        fieldAttributes = templateAttributes["template"][1]
    elif "structure" in templateAttributes:
        subTemplateName = templateAttributes["structure"][:-10]
        subTemplateScope, subTemplateAttribute = \
            findIdentifier("^s_" + subTemplateName + "^", \
                           PALMAT, currentIndex)
        fieldNames = subTemplateAttribute["template"][0]
        fieldAttributes = subTemplateAttribute["template"][1]
    else:
        return NaN
    structure = []
    for i in range(len(fieldNames)):
        fieldName = fieldNames[i]
        fieldAttribute = fieldAttributes[i]
        if "structure" in fieldAttribute:
            sub = uninitializedStructure(PALMAT, currentScope, \
                                         fieldAttribute["structure"][:-10], \
                                         fieldAttribute)
            if sub == NaN:
                return NaN
            structure.append(sub)
        elif "template" in fieldAttribute:
            sub = uninitializedStructure(PALMAT, currentScope, "", \
                                         fieldAttribute)
            if sub == NaN:
                return NaN
            structure.append(sub)
        elif "array" in fieldAttribute or "vector" in fieldAttribute \
                or "matrix" in fieldAttribute:
            arrayDimensions = []
            if "array" in fieldAttribute:
                arrayDimensions = fieldAttribute["array"]
            dimensions = []
            if "vector" in fieldAttribute:
                dimensions = [fieldAttribute["vector"]]
            elif "matrix" in fieldAttribute:
                dimensions = fieldAttribute["matrix"]
            structure.append(uninitializedComposite(arrayDimensions, dimensions))
        else:
            structure.append(None)
    if templateName[:2] == "s_":
        structure.append(templateName[2:] + "-STRUCTURE")
    else:
        structure.append(templateName + "-STRUCTURE")
    return structure

# Find the next uninitialized value in a STRUCTURE, and initialize it with 
# a value.  Returns True upon completion.
def insertNextElement(struct, value):
    # We should be performing data conversions here.  Initially, though, I'm
    # just assuming the datatypes are right.  We *should* be fed the structure
    # template attributes as a paramter, and should be using it.
    # **FIXME**
    for i in range(len(struct)):
        if isinstance(struct[i], list):
            if insertNextElement(struct[i], value):
                return True
        elif struct[i] == None:
            struct[i] = value
            return True
    return False

# Complete the initialization of a VECTOR, MATRIX, or ARRAY by making sure that
# INITIALs or CONSTANTs are filled out to the proper geometry with appropriate
# values.  Returns [] on success, or a list of identifiers which failed.
def completeInitialConstants(currentScope):
    identifiers = currentScope["identifiers"]
    parameters = []
    if "attributes" in currentScope and \
            "parameters" in currentScope["attributes"]:
        parameters = currentScope["attributes"]["parameters"]
    messages = []
    for identifier in identifiers:
        identifierDict = identifiers[identifier]
        if identifier[1:-1] in parameters:
            # A parameter for a FUNCTION or PROCEDURE.  There's no 
            # INITAL or CONSTANT clause (or if there is, it shouldn't be there),
            # and nothing is needed for a value, since it's just going to be
            # popped from the computation stack upon entry to the subroutine
            # anyway.
            continue
        if "vector" not in identifierDict and "matrix" not in identifierDict \
                and "array" not in identifierDict:
            continue
        if "array" in identifierDict:
            arrayDimensions = identifierDict["array"]
        else:
            arrayDimensions = []
        if "vector" in identifierDict:
            secondaryDimensions = [identifierDict["vector"]]
        elif "matrix" in identifierDict:
            secondaryDimensions = identifierDict["matrix"]
        else:
            secondaryDimensions = []
        if "value" in identifierDict:
            oldValue = identifierDict["value"]
        else:
            oldValue = None
        if "initial" in identifierDict:
            value = identifierDict["initial"]
            if not isinstance(value, list):
                value = []
                identifierDict["initial"] = value
            isInitial = True
        elif "constant" in identifierDict:
            value = identifierDict["constant"]
            if not isinstance(value, list):
                value = []
                identifierDict["constant"] = value
            isInitial = False
        elif "array" in identifierDict or "vector" in identifierDict \
                or "matrix" in identifierDict:
            if not isinstance(oldValue, list):
                identifierDict["value"] = \
                    uninitializedComposite(arrayDimensions, \
                                           secondaryDimensions)
            continue
        fillValue = None
        if "vector" in identifierDict and arrayDimensions == []:
            numCols = identifierDict["vector"]
            if "fill" not in identifierDict:
                if len(value) == 1:
                    fillValue = value[0]
                elif len(value) != numCols:
                    messages.append(identifier)
                    continue
            elif len(value) > numCols:
                messages.append(identifier)
                continue
            while len(value) < numCols:
                value.append(fillValue)
            if "fill" in identifierDict:
                identifierDict.pop("fill")
        elif "matrix" in identifierDict and arrayDimensions == []:
            numRows, numCols = identifierDict["matrix"]
            if "fill" not in identifierDict:
                if len(value) == 1 and len(value[0]) == 1:
                    fillValue = value[0][0]
                elif len(value) != numRows or len(value[-1]) != numCols:
                    messages.append(identifier)
                    continue
            elif len(value) > numCols:
                messages.append(identifier)
                continue
            row = value[-1]
            while len(row) < numCols:
                row.append(fillValue)
            while len(value) < numRows:
                value.append([fillValue]*numCols)
            if "fill" in identifierDict:
                identifierDict.pop("fill")
        else:
            continue
        if isInitial:
            identifierDict["value"] = copy.deepcopy(value)
    for identifier in messages:
        identifiers.pop(identifier)
    return messages
    
# Make sure every variable in the scope has a "value", even if it's 
# uninitialized.
def setUninitialized(PALMAT, currentScope):
    
    identifiers = currentScope["identifiers"]
    parameters = []
    if "attributes" in currentScope and \
            "parameters" in currentScope["attributes"]:
        parameters = currentScope["attributes"]["parameters"]
    
    def uninitializeLevel(arrayDimensions, dimensions):
        level = []
        if len(arrayDimensions) > 0:
            for i in range(arrayDimensions[0]):
                level.append(uninitializeLevel(arrayDimensions[1:], \
                                               dimensions[1:]))
            level.append("a")
        elif len(dimensions) > 0:
            for i in range(dimensions[0]):
                level.append(uninitializeLevel([], dimensions[1:]))
        else:
            level = None
        return level

    for identifier in identifiers:
        if identifier[1:-1] in parameters:
            # Don't need to "uninitialize" a formal parameter.
            continue
        attributes = identifiers[identifier]
        if "value" not in attributes and "constant" not in attributes and \
                ("integer" in attributes or "scalar" in attributes or \
                 "vector" in attributes or "matrix" in attributes or \
                 "bit" in attributes or "character" in attributes or \
                 "structure" in attributes):
            if "structure" in attributes:
                templateName = attributes["structure"]
                dummy, templateAttributes = \
                    findIdentifier("^" + templateName + "^", \
                                   PALMAT, currentScope["self"])
                attributes["value"] = uninitializedStructure(PALMAT, \
                                                             currentScope, \
                                                             templateName, \
                                                             templateAttributes)
                continue
            dimensions = []
            arrayDimensions = []
            if "array" in attributes:
                isArray = True
                arrayDimensions = attributes["array"]
                dimensions.extend(arrayDimensions)
            if "vector" in attributes:
                dimensions.append(attributes["vector"])
            elif "matrix" in attributes:
                dimensions.extend(attributes["matrix"])
            if len(dimensions) == 0:
                value = None
            else:
                value = uninitializeLevel(arrayDimensions, dimensions)
            attributes["value"] = value

# Test if an object is a vector, and (optionally) if all its elements are 
# initialized.
def isVector(object, initialization=True):
    if not isinstance(object, list):
        return False
    if len(object) < 1:
        return False
    if isinstance(object[-1], str):
        return False # Is bitstring, pointer, array, etc.
    for e in object:
        if isinstance(e, (int, float)):
            continue
        if e == None and not initialization:
            continue
        return False
    return True

# Test if an object is a matrix, and (optionally if all its elements are 
# initialized.
def isMatrix(object, initialization=True):
    if not isinstance(object, list):
        return False
    numRows = len(object)
    if numRows < 1 or not isinstance(object[0], list):
        return False
    if isinstance(object[-1], str):
        return False # Is bitstring, pointer, array, etc.
    numCols = len(object[0])
    for row in object:
        if not isinstance(row, list) or len(row) != numCols:
            return False
        for e in row:
            if isinstance(e, (int, float)):
                continue
            if e == None and not initialization:
                continue
            return False
    return True

def isArrayGeometry(object, dimensions):
    if len(dimensions) == 0:
        # Object is an atomic element.  If we want to check that all of the 
        # types of the array elements are the same and/or initialized, this
        # is where we do it.
        return True
    if object == None:
        return False
    if not isinstance(object, list):
        return False
    if object[-1] != 'a':
        return False
    if len(object)-1 != dimensions[0]:
        return False
    # This level of the array is okay.  Now go on to the sub-levels.
    subDimensions = dimensions[1:]
    for subObject in object[:-1]:
        if isArrayGeometry(subObject, subDimensions):
            continue
        return False
    return True

# Converts True or False to a bit-array representation for the computation 
# stack.
def convertToBitArray(b):
    if b:
        return hTRUE
    else:
        return hFALSE

# Check operand type for INTEGER vs SCALAR vs VECTOR vs MATRIX.
def checkArithmeticalDatatype(operand):
    if isinstance(operand, int):
        return True, True, False, False
    if isinstance(operand, float):
        return False, True, False, False
    if isVector(operand):
        return False, False, True, False
    if isMatrix(operand):
        return False, False, False, True
    return False, False, False, False

def printError(PALMAT, source, instruction, msg):
    if msg == "":
        msg = "n/a"
    if instruction == None:
        print("\t%s, line %d, column %d: %s" % \
            (PALMAT["sourceFiles"][source[0]], source[1], source[2], msg))
    else:
        print("\t%s, line %d, column %d (%s): %s" % \
            (PALMAT["sourceFiles"][source[0]], source[1], source[2], \
             str(instruction), msg))

