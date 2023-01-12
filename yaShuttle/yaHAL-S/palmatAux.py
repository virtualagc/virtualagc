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
"""

import json
import re

# Add a `debug` PALMAT instruction.
def debug(PALMAT, state, message):
    PALMAT["scopes"][state["scopeIndex"]]["instructions"].append({
            'debug': message
        })

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
                "incomplete"    : [ ],
                "type"          : scopeType
            }
    return scope

# Create a new, empty PALMAT object.
def constructPALMAT():
    return  {
                "scopes" : [ constructScope() ]
            }

# Search upward through the scope hierarchy, trying to find the first enclosing
# loop. Returns the scope dictionary for the loop, or else None.
def findEnclosingLoop(PALMAT, scope):
    while scope != None:
        if scope["type"] in ["do while", "do until", "do for"]:
            return scope
        scope = PALMAT["scopes"][scope["parent"]]
    return None

# Find an identifier in a scope that matches a pattern.
def findIdentifierWithPrefix(scope, xx):
    prog = re.compile("\\^" + xx + "_[0-9]+\\^")
    for identifier in scope["identifiers"]:
        if prog.fullmatch(identifier) != None:
            return identifier
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
# and so on.  Returns either the dictionary for the identifier or else None if 
# not found. 
# Note: There's also a findIdentifier() in the executePALMAT
# module which provides the same service but is incompatible
# API-wise.
def findIdentifier(identifier, PALMAT, scopeIndex=None):
    while scopeIndex != None:
        scope = PALMAT["scopes"][scopeIndex]
        if identifier in scope["identifiers"]:
            return scope["identifiers"][identifier]
        scopeIndex = scope["parent"]
    return None

#-----------------------------------------------------------------------------
'''
These auxiliary functions are used to create child (DO ... END) blocks and
to provide the various label identifiers for PALMAT instructions like 'goto',
'iffalse', and 'iftrue' that are used to jump in, out, and within these
blocks.  We use a kind of trick to help us with this

For jumping *within* a given DO...END block (as opposed to entering or leaving
the block) we use a kind of trick.  For each such jump there's a *target* 
instruction (a 'noop') and one or more jumps to it (using 'goto', 'iftrue',
or 'iffalse'), associated by a unique label in the scope's identifiers.
These identifiers are all of the form xx_N, where xx is supposed to unique
to the purpose, and N is a unique number chosen by the code-generator to 
insure that the same xx can be used in different scopes without conflict.
Functions are provided to insert the target instructions and the instructions
that jump to them.  By convention xx is always lower-case alphabetic characters.
'''
uniqueCount = -1
def getUniqueCount():
    global uniqueCount
    uniqueCount += 1
    return uniqueCount

def createUniqueIdentifier(currentScope, xx, identDict):
    identifiers = currentScope["identifiers"]
    s = "%s_%d" % (xx, getUniqueCount())
    identifiers["^" + s + "^"] = identDict
    return s

# This function creates a label for an internal jump within a DO...END,
# and inserts a noop instruction with that label. Returns the new label, 
# or None on error.  The prefixes "ue", "ur", and "up" are already used
# by makeDoEnd(), and so are not candidates for createTarget(), though
# they can be used with jumpToTarget().
jumpInstructions = ['goto', 'iffalse', 'iftrue']
def createTarget(currentScope, xx):
    identifiers = currentScope["identifiers"]
    instructions = currentScope["instructions"]
    prefix = "^" + xx + "_"
    lenxx = len(prefix)
    for identifier in identifiers:
        if prefix == identifier[:lenxx]:
            print("Implementation error, duplicate target anchors:", xx)
            return None
    label = "%s%d^" % (prefix, getUniqueCount())
    identifiers[label] = {'label': [currentScope['self'], len(instructions)]}
    instructions.append({'noop': True, 'label': label})
    # Correct any jumps already added before the label was created.
    poppable = []
    incompletes = currentScope["incomplete"] # A list of instruction offsets.
    for i in incompletes:
        instruction = instructions[i]
        for jumpInstruction in jumpInstructions:
            if jumpInstruction in instruction:
                if xx == instruction[jumpInstruction]:
                    instruction[jumpInstruction] = label
                    poppable.append(i)
                    break
    for popit in poppable:
        incompletes.remove(popit)
    #if len(incompletes) == 0:
    #    currentScope.pop("incomplete")
    return label

# This function inserts a PALMAT instruction that jumps to an target
# created (previously or later on) by insertTarget().  The palmatOpcode 
# is one of the jumpInstructions list defined earlier.  jumpToTarget() 
# can be used multiple times for the same label, and can either precede
# or follow createTarget(). If preceding createTarget(),
# however, the label it needs to find doesn't exist, so it uses a
# placeholder label (xx) which is fixed up later by createTarget().
# Note: Don't try using targetScope for now.
def jumpToTarget(currentScope, xx, palmatOpcode, targetScope=None):

    if targetScope == None:
        targetScope = currentScope

    # This function finds a label for an internal jump within a DO...END
    # previously created by createTargetLabel(). Returns the label or None.
    # It can be taken outside of jumpToTarget() if necessary, but I didn't
    # find that necessary.
    def findTargetLabel(scope, xx):
        identifiers = scope["identifiers"]
        instructions = scope["instructions"]
        prefix = "^" + xx + "_"
        lenxx = len(prefix)
        for identifier in identifiers:
            if prefix == identifier[:lenxx]:
                return identifier
        return None
    
    instructions = currentScope["instructions"]
    label = findTargetLabel(targetScope, xx)
    if label == None:
        currentScope["incomplete"].append(len(instructions))
        label = xx
    instructions.append({palmatOpcode: label})

# This function is used by a parent scope to create a child scope that's
# a DO ... END, and to goto it.  (Also for IF statements.)  The new child 
# scope is returned. Note that makeDoEnd() creates labels with xx = ue and ur,
# so those do not need to be created separately by createTargetLabel().
# The parameter dummyTargets is an optional array of additional 
# targets to add after the initial ue_ target. 
def makeDoEnd(PALMAT, currentScope, dummyTargets=[], scopeType="unknown"):
    indexOfCurrentScope = currentScope["self"]
    indexOfNewScope = addScope(PALMAT, indexOfCurrentScope, scopeType)
    newScope = PALMAT["scopes"][indexOfNewScope]
    entryLabel = "^ue_%d^" % getUniqueCount()
    returnLabel = "^ur_%d^" % getUniqueCount()
    currentIdentifiers = currentScope["identifiers"]
    currentInstructions = currentScope["instructions"]
    currentIdentifiers[entryLabel] = {"label": [indexOfNewScope, 0]}
    currentInstructions.append({"goto": entryLabel})
    currentIdentifiers[returnLabel] = {"label": [indexOfCurrentScope, 
                                                 len(currentInstructions)]}
    currentInstructions.append({"noop": True, "label": returnLabel})
    newIdentifiers = newScope["identifiers"]
    newInstructions = newScope["instructions"]
    newInstructions.append({'noop': True, "label": entryLabel})
    for xx in dummyTargets:
        recycleLabel = "^%s_%d^" % (xx, getUniqueCount())
        newIdentifiers[recycleLabel] = {'label': [indexOfNewScope, 1]}
        newInstructions.append({'noop': True, "label": recycleLabel})
    return indexOfNewScope, newScope

# This function is used to exit from a DO loop back to the parent context,
# assuming it was all set up by makeDoEnd().
def exitDo(PALMAT, currentScope):
    parentScope = PALMAT["scopes"][currentScope["parent"]]
    #print("*A", PALMAT["scopes"])
    #print("*B", parentScope["instructions"])
    targetInstruction = parentScope["instructions"][-1]
    targetLabel = targetInstruction["label"]
    currentScope["instructions"].append({'goto': targetLabel})

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
                      "character", "template", "structure", "label")
def isUnmarkedScalar(identifierDict):
    for s in notUnmarkedScalars:
        if s in identifierDict:
            return False
    return True

