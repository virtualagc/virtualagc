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

# Add a `debug` PALMAT instruction.
def debug(PALMAT, state, message):
    return
    PALMAT["scopes"][state["scopeIndex"]]["instructions"].append({
            'debug': message
        })

# Quick check if value is array.  Fuller test is isArrayGeometry() in
# executePALMAT.
def isArrayQuick(value):
    if not isinstance(value, list) or len(value) < 2 or value[-1] != "a":
        return False
    return True

# Test if a value on the computation stack is a boolean.
def isBitArray(value):
    return isinstance(value, list) and len(value) == 3 and value[2] == "b" \
            and isinstance(value[0], int) and isinstance(value[1], int)

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
                ["do", "do for", "do until", "do while", "if"]:
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
            findObsoleted(scopeIndex)
    
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
    
    # Finally, eliminate all identifiers that are compiler-generated 
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
                "parent"        : parentIndex,
                "self"          : selfIndex,
                "children"      : [ ],
                "identifiers"   : { },
                "instructions"  : [ ],
                "type"          : scopeType
            }
    return scope

# Create a new, empty PALMAT object.
def constructPALMAT(instantiation=0):
    return  {
                "scopes" : [ constructScope() ],
                "instantiation": 0
            }

# Search upward through the scope hierarchy, trying to find the first enclosing
# loop. Returns the scope dictionary for the loop, or else None.
def findEnclosingLoop(PALMAT, scope):
    while scope != None:
        if scope["type"] in ["do while", "do until", "do for"]:
            return scope
        scope = PALMAT["scopes"][scope["parent"]]
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
def createTarget(PALMAT, fromIndex, toIndex, xx, nameFromFrom=False):
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
    instructions.append({'noop': True, 'label': identifier})
    identifiers = namespaceScope['identifiers']
    identifiers[identifier] = {'label': [toIndex, toOffset] }
    return identifier

# This function inserts a PALMAT instruction that jumps to an target
# created (previously or later on) by createTarget().  The palmatOpcode 
# is one of the jumpInstructions list.  jumpToTarget() 
# can be used multiple times for the same label, and can either precede
# or follow createTarget(). 
jumpInstructions = ['goto', 'iffalse', 'iftrue']
def jumpToTarget(PALMAT, fromIndex, toIndex, xx, palmatOpcode, \
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
    instructions.append({palmatOpcode: (li, "^" + label + "^")})

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
def makeDoEnd(PALMAT, parentScope, scopeType="unknown"):
    parentIndex = parentScope["self"]
    childIndex = addScope(PALMAT, parentIndex, scopeType)
    createTarget(PALMAT, parentIndex, childIndex, "ue")
    jumpToTarget(PALMAT, parentIndex, childIndex, "ue", "goto")
    createTarget(PALMAT, childIndex, parentIndex, "ur", True)
    return childIndex, PALMAT["scopes"][childIndex]

# This function is used to exit from a DO loop back to the parent context,
# assuming it was all set up by makeDoEnd().
def exitDo(PALMAT, fromIndex, toIndex):
    #createTarget(PALMAT, fromIndex, fromIndex, "ux")
    jumpToTarget(PALMAT, fromIndex, toIndex, "ur", "goto", True)

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

# Complete the initialization of a VECTOR, MATRIX, or ARRAY by making sure that
# INITIALs or CONSTANTs are filled out to the proper geometry with appropriate
# values.  Returns [] on success, or a list of identifiers which failed.
def completeInitialConstants(identifiers):
    messages = []
    for identifier in identifiers:
        identifierDict = identifiers[identifier]
        if "vector" not in identifierDict and "matrix" not in identifierDict:
            continue
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
        elif "vector" in identifierDict:
            numCols = identifierDict["vector"]
            value = [None]*numCols
            identifierDict["value"] = value
            continue
        elif "matrix" in identifierDict:
            numRows, numCols = identifierDict["matrix"]
            value = []
            for i in range(numRows):
                value.append([None]*numCols)
            identifierDict["value"] = value
            continue
        fillValue = None
        if "vector" in identifierDict:
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
        elif "matrix" in identifierDict:
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
def setUninitialized(identifiers):
    
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
        attributes = identifiers[identifier]
        if "value" not in attributes and "constant" not in attributes and \
                ("integer" in attributes or "scalar" in attributes or \
                 "vector" in attributes or "matrix" in attributes or \
                 "bit" in attributes or "character" in attributes):
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