#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       PALMAT.py
Reference:      PALMAT.md
Purpose:        Part of the code-generation system for the "modern" HAL/S
                compiler yaHAL-S-FC.py+modernHAL-S-FC.c.
History:        2022-12-19 RSB  Created. 
"""

import json
import p_Functions
from executePALMAT import executePALMAT, hround

#-----------------------------------------------------------------------------
# File operations.

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
def constructScope(selfIndex=0, parentIndex=None):
    return  {
                "parent"        : parentIndex,
                "self"          : selfIndex,
                "children"      : [ ],
                "identifiers"   : { },
                "instructions"  : [ ]
            }

# Create a new, empty PALMAT object.
def constructPALMAT():
    return  {
                "scopes" : [ constructScope() ]
            }

# Add a memory scope to existing PALMAT.  Returns the index of the new scope.
# (There's really no need for it to return even that, since the new scope's
# index will always be len(PALMAT["scopes"])-1, but it may save the calling 
# program from having to do that minimal arithmetic.)
def addScope(PALMAT, parentIndex):
    newIndex = len(PALMAT["scopes"])
    newScope = constructScope(newIndex, parentIndex)
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
# The code generator (ast -> PALMAT).

def isUnmarkedScalar(identifierDict):
    if "scalar" in identifierDict:
        return False
    if "integer" in identifierDict:
        return False
    if "vector" in identifierDict:
        return False
    if "matrix" in identifierDict:
        return False
    if "bit" in identifierDict:
        return False
    if "character" in identifierDict:
        return False
    if "template" in identifierDict:
        return False
    if "structure" in identifierDict:
        return False
    return True

'''
Here's the idea:  generatePALMAT() is a recursive function that works its
way through the given AST to generate PALMAT for it.

Potentially we have (in the p_Functions module) a Python function associated
with each unique LBNF label, and what that function does is to perform whatever
PALMAT generation is needed for that rul. The function names and LBNF labels 
are the identical.  (Actually, the labels all begin with two alphabetic capital 
letters that can be discared, so the leading two upper-case characters are 
removed from the function names.)

As generatePALMAT() descends through the AST, it simply calls the functions
associated with the labels, *if* they exist in the p_Functions module.  For 
example, when the label "AAdeclareBody_declarationList" is encountered in the 
AST structure, the function named "declareBody_declarationList" exists (and is
called), whereas when the label "AAdeclarationList" is encountered, there is
no function named "declarationList which can be called and thus no PALMAT
generation occurs.

As far as the details of how to call a function when we are given its name as
a string, the basic notion is that the function can be found by looking up the
string in the globals() dictionary.  In our case, we need to do the lookup in 
globals() of the p_Functions module, and not of this PALMAT module.  But 
p_Functions's globals() is provided to us as p_Functions.objects.  Here's what 
the whole thing looks like:
    import p_Functions
    ...
    func = p_Functions.objects["declareBody_declarationList"]
    ret = func()
(The arguments and return value of func mightn't be what's shown; I'm just 
talking about the principle of how to look up the function and call it.)  

The generatePALMAT() function is basically a (pretty-complex) state machine,
and therefore must track the state in order to figure out how to interpret some
of the stuff it finds in the AST.  That's tricky, because the state generally
depends not just on the current LBNF label being processed, but on some 
(abridged) sequence of LBNF labels.  For example, in processing
    DECLARE A INTEGER DOUBLE;
            vs
    DECLARE INTEGER, A DOUBLE;
the INTEGER keyword has to be handle somewhat differently.  The solution I use
to track the states is that the "state" includes (among other things} a list 
of the form
    [LBNFlabel1, ..., LBNFlabelN]
where (as I said) these LBNF labels are some abridged sequence of the LBNF
labels encountered.  I call this list the "history".  The entry state in 
which no statement is yet being processed is state={ "history" : [] }.
'''

uniqueCount = 0
def generatePALMAT(ast, PALMAT, state={ "history":[], "scopeIndex":0 }, trace=False, endLabels=[]):
    global uniqueCount
    newState = state
    lbnfLabelFull = ast["lbnfLabel"]
    lbnfLabel = lbnfLabelFull[2:]
    scopes = PALMAT["scopes"]
    currentScope = scopes[state["scopeIndex"]]
    
    # Create a label for the end of this grammar component.  If none of the
    # subcomponents end up using it, we won't bother to use it, and it won't
    # take up any resources.  For example, a basic assignment statement will
    # never need to jump to the end of the statement, but an IF ... THEN ...
    # statement may need to if the conditional is false.
    endLabel = "^ue_%d^" % uniqueCount
    uniqueCount += 1
    endLabels.append({ "lbnfLabel": lbnfLabel, "endLabel": endLabel, "used": False})
    
    # Main generation of PALMAT for the statement, sans setup and cleanup.
    # HAL/S built-in functions
    if lbnfLabel in ["abs", "ceiling", "div", "floor", "midval", "mod",
                     "odd", "remainder", "round", "sign", "signum", "truncate",
                     "arccos", "arccosh", "arcsin", "arcsinh", "arctan2", 
                     "arctan", "arctanh", "cos", "cosh", "exp", "log", "sin",
                     "sinh", "sqrt", "tan", "tanh", "abval", "det", "inverse",
                     "trace", "transpose", "unit",
                     "max", "min", "prod", "sum",
                     "xor", "index", "length", "ljust", "rjust", "trim",
                     "clocktime", "date", "errgrp", "errnum", "nextime", "prio", "random",
                     "randomg", "runtime", "shl", "shr", "size"]:
        p_Functions.halBuiltIn(lbnfLabel)
    
    elif lbnfLabel in p_Functions.objects:
        if trace:
            print("TRACE:", lbnfLabel)
            print("      ", state)
            print("      ", p_Functions.substate)
        func = p_Functions.objects[lbnfLabel]
        success, newState = func(PALMAT, state)
        if trace:
            print("      ", p_Functions.substate)
        if not success:
            endLabels.pop()
            return False, PALMAT
        #print(newState)    
    for component in ast["components"]:
        #if lbnfLabel == "ifStatement":
        #    print("*", component)
        if isinstance(component, str):
            if component[:1] == "^":
                if trace:
                    print("TRACE:", component)
                    print("      ", newState)
                    print("      ", p_Functions.substate)
                success = p_Functions.stringLiteral(PALMAT, newState, component)
                if trace:
                    print("      ", p_Functions.substate)
            else:
                success, PALMAT = generatePALMAT( \
                    { "lbnfLabel": component, "components" : [] }, \
                    PALMAT, newState, trace, endLabels )
            if not success:
                endLabels.pop()
                return False, PALMAT
        else:
            success, PALMAT = generatePALMAT(component, PALMAT, newState, trace, endLabels)
            if not success:
                endLabels.pop()
                return False, PALMAT

    # ------------------------------------------------------------------    
    # Cleanups after generation of the almost-complete PALMAT for this
    # statement.  Includes stuff like actual assignments to variables
    # after computation of expressions has all been done, placement of 
    # compiler-generated labels for the ends of IF statements, and so on.
    if lbnfLabel in ["comparison", "ifClauseBitExp"]:
        p_Functions.expressionToInstructions(p_Functions.substate["expression"], currentScope["instructions"])
        for entry in reversed(endLabels):
            if entry["lbnfLabel"] in ["ifStatement", "true_part"]:
                entry["used"] = True
                currentScope["instructions"].append({"iffalse": entry["endLabel"]})
                break
        '''
        elif lbnfLabel == "ifClauseBitExp":
            #print("*", endLabels)
            if endLabels[-2]["lbnfLabel"] in ["ifStatement", "true_part"]:
                p_Functions.expressionToInstructions(p_Functions.substate["expression"], currentScope["instructions"])
                endLabels[-2]["used"] = True
                currentScope["instructions"].append({"iffalse": endLabels[-2]["endLabel"]})
        '''
    elif lbnfLabel == "true_part":
        p_Functions.expressionToInstructions(p_Functions.substate["expression"], currentScope["instructions"])
        endLabels[-2]["used"] = True
        currentScope["instructions"].append({"goto": endLabels[-2]["endLabel"]})
    elif lbnfLabel == "assignment":
        instructions = currentScope["instructions"]
        p_Functions.expressionToInstructions(p_Functions.substate["expression"], instructions)
        instructions.append({ "store": p_Functions.substate["lhs"][-1] })
        p_Functions.substate["lhs"].pop()
        if len(p_Functions.substate["lhs"]) == 0:
            instructions.append({ "pop": 1 })
    elif lbnfLabel == "basicStatementWritePhrase":
        instructions = currentScope["instructions"]
        p_Functions.expressionToInstructions(p_Functions.substate["expression"], instructions)
        instructions.append({ "write": p_Functions.substate["LUN"] })
    elif lbnfLabel == "declare_statement":
        identifiers = currentScope["identifiers"]
        for i in identifiers:
            identifier = identifiers[i]
            if isUnmarkedScalar(identifier):
                identifier["scalar"] = True
    elif lbnfLabel == "repeated_constant":
        # We get to here after an INITIAL(...) or CONSTANT(...)
        # has been fully processed to the extent of preparing
        # substate["expression"] for computing the value in 
        # parenthesis, but without having performed that computation
        # yet, leaving a bogus "initial" or "constant" attribute.
        # We now have to perform the actual computation, if possible,
        # and correct the bogus constant.  Since DECLARE statements
        # always come at the beginnings of blocks, prior to any 
        # executable code, we don't have to worry about preserving
        # any existing PALMAT for the scope.
        identifiers = currentScope["identifiers"]
        instructions = currentScope["instructions"]
        currentIdentifier = p_Functions.substate["currentIdentifier"]
        instructions.clear()
        expression = p_Functions.substate["expression"]
        for entry in reversed(expression):
            if "fetch" in entry:
                identifier = "^" + entry["fetch"] + "^"
                attributes = findIdentifier(identifier, PALMAT, scopeIndex)
                if attributes != None:
                    if "constant" not in attributes:
                        print("Can only use constants in computing INITIAL or CONSTANT.")
                        identifiers.pop(currentIdentifier)
                        endLabels.pop()
                        return False, PALMAT
                    break
            instructions.append(entry)
        expression.clear()
        computationStack = executePALMAT(PALMAT)
        instructions.clear()
        #print("*A", instructions)
        #print("*B", computationStack)
        if computationStack == None or len(computationStack) != 1:
            print("Computation of INITIAL or CONSTANT failed:")
            if len(computationStack) == 0:
                print("       (empty)")
            else:
                for entry in computationStack:
                    print("       ", entry)
            identifiers.pop(currentIdentifier)
            endLabels.pop()
            return False, PALMAT
        value = computationStack.pop()
        if currentIdentifier != "":
            identifierDict = identifiers[currentIdentifier]
        else:
            identifierDict = p_Functions.substate["commonAttributes"]
        if isUnmarkedScalar(identifierDict):
            identifierDict["scalar"] = True
        if "initial" in identifierDict and "constant" in identifierDict:
            print("Identifier", currentIdentifier[1:-1], \
                    "cannot have both INITIAL and CONSTANT.")
            identifiers.pop(currentIdentifier)
            endLabels.pop()
            return False, PALMAT
        key = None
        if "initial" in identifierDict and identifierDict["initial"] == "^?^":
            key = "initial"
        elif "constant" in identifierDict and identifierDict["constant"] == "^?^":
            key = "constant"
        else:
            print("Discrepancy between INITIAL and CONSTANT.")
            identifiers.pop(currentIdentifier)
            endLabels.pop()
            return False, PALMAT
        if isinstance(value, (int, float)) and "integer" in identifierDict:
            value = hround(value)
        elif isinstance(value, (int, float)) and "scalar" in identifierDict:
            value = float(value)
        elif isinstance(value, bool) and "bit" in identifierDict:
            pass
        elif isinstance(value, str) and "character" in identifierDict:
            pass
        else:
            print("Datatype mismatch in INITIAL or CONSTANT.")
            identifiers.pop(currentIdentifier)
            endLabels.pop()
            return False, PALMAT
        identifierDict[key] = value
        if key == "initial":
            identifierDict["value"] = value
    
    #----------------------------------------------------------------------
    # Decide if we need to stick an automatically-generated label at the
    # end of this grammar component or not.
    if endLabels[-1]["used"]:
        instructions = currentScope["instructions"]
        identifiers = currentScope["identifiers"]
        identifiers[endLabel] = { "label": [state["scopeIndex"], len(instructions)] }
        instructions.append({"noop": True, "label": endLabel})
    endLabels.pop()
    return True, PALMAT
