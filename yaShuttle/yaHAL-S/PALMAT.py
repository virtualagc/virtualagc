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
uniqueCount = 0

# This function creates a label for an internal jump within a DO...END,
# and inserts a noop instruction with that label. Returns the new label, 
# or None on error.  The prefixes "ue", "ur", and "up" are already used
# by makeDoEnd(), and so are not candidates for createTarget(), though
# they can be used with jumpToTarget().
jumpInstructions = ['goto', 'iffalse', 'iftrue']
def createTarget(currentScope, xx):
    global uniqueCount
    identifiers = currentScope["identifiers"]
    instructions = currentScope["instructions"]
    prefix = xx + "_"
    lenxx = len(prefix)
    for identifier in identifiers:
        if prefix == identifier[:lenxx]:
            print("Implementation error, duplicate target anchors:", prefix)
            return None
    label = "^%s%d^" % (prefix, uniqueCount)
    uniqueCount += 1
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
    if len(incompletes) == 0:
        currentScope.pop("incomplete")
    return label

# This function inserts a PALMAT instruction that jumps to an target
# created (previously or later on) by insertTarget().  The palmatOpcode 
# is one of the jumpInstructions list defined earlier.  jumpToTarget() 
# can be used multiple times for the same label, and can either precede
# or follow createTarget(). If preceding createTarget(),
# however, the label it needs to find doesn't exist, so it uses a
# placeholder label (xx) which is fixed up later by createTarget().
def jumpToTarget(currentScope, xx, palmatOpcode):

    # This function finds a label for an internal jump within a DO...END
    # previously created by createTargetLabel(). Returns the label or None.
    # It can be taken outside of jumpToTarget() if necessary, but I didn't
    # find that necessary.
    def findTargetLabel(currentScope, xx):
        identifiers = currentScope["identifiers"]
        instructions = currentScope["instructions"]
        prefix = "^" + xx + "_"
        lenxx = len(prefix)
        for identifier in identifiers:
            if prefix == identifier[:lenxx]:
                return identifier
        return None
    
    instructions = currentScope["instructions"]
    label = findTargetLabel(currentScope, xx)
    if label == None:
        currentScope["incomplete"].append(len(instructions))
        label = xx
    instructions.append({palmatOpcode: label})

# This function is used by a parent scope to create a child scope that's
# a DO ... END, and to goto it.  The new child scope is returned.
# Note that makeDoEnd() creates labels with xx = ue, ur, and up, so 
# those do not need to be created separately by createTargetLabel().
def makeDoEnd(PALMAT, currentScope):
    global uniqueCount
    indexOfCurrentScope = currentScope["self"]
    indexOfNewScope = addScope(PALMAT, indexOfCurrentScope)
    newScope = PALMAT["scopes"][indexOfNewScope]
    entryLabel = "^ue_%d^" % uniqueCount
    uniqueCount += 1
    returnLabel = "^ur_%d^" % uniqueCount
    uniqueCount += 1
    currentIdentifiers = currentScope["identifiers"]
    currentInstructions = currentScope["instructions"]
    currentIdentifiers[entryLabel] = {"label": [indexOfNewScope, 0]}
    currentInstructions.append({"goto": entryLabel})
    currentIdentifiers[returnLabel] = {"label": [indexOfCurrentScope, len(currentInstructions)]}
    currentInstructions.append({"noop": True, "label": returnLabel})
    newIdentifiers = newScope["identifiers"]
    newInstructions = newScope["instructions"]
    newInstructions.append({'noop': True, "label": entryLabel})
    recycleLabel = "^up_%d^" % uniqueCount
    uniqueCount += 1
    newIdentifiers[recycleLabel] = {'label': [indexOfNewScope, 1]}
    newInstructions.append({'noop': True, "label": recycleLabel})
    # The "incomplete" key is temporarily added to the scope.
    # It's for tracking jumpToTarget() calls that 
    # occur prior to the label being added to the identifiers.
    # These references are supposed to be resolved later when 
    # the label is actually created.  The entire "incomplete" 
    # key is (hopefully!) removed automatically once all of the
    # references are fixed.
    newScope["incomplete"] = []
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

def generatePALMAT(ast, PALMAT, state={ "history":[], "scopeIndex":0 }, 
                   trace=False, endLabels=[]):
    global uniqueCount
    newState = state
    lbnfLabelFull = ast["lbnfLabel"]
    lbnfLabel = lbnfLabelFull[2:]
    scopes = PALMAT["scopes"]
    preservedScopeIndex = state["scopeIndex"]
    currentScope = scopes[preservedScopeIndex]
    
    # Create a label for the end of this grammar component.  If none of the
    # subcomponents end up using it, we won't bother to use it, and it won't
    # take up any resources.  For example, a basic assignment statement will
    # never need to jump to the end of the statement, but an IF ... THEN ...
    # statement may need to if the conditional is false.
    beginningLabel = "^ue_%d^" % uniqueCount
    uniqueCount += 1
    beginningLabel2 = "^ue_%d^" % uniqueCount
    uniqueCount += 1
    entryLabel = "^ue_%d^" % uniqueCount
    uniqueCount += 1
    endLabel = "^ue_%d^" % uniqueCount
    uniqueCount += 1
    endLabels.append({"lbnfLabel": lbnfLabel, 
                      "endLabel": endLabel, 
                      "used": False})

    # Is this a DO ... END block?  If it is, then we have to do several things:
    # create a new child scope and make it current, and add a goto PALMAT 
    # instruction from the existing current scope to the new scope.
    isDo = lbnfLabel in ["basicStatementDo"]
    if isDo:
        state["scopeIndex"], currentScope = makeDoEnd(PALMAT, currentScope)
    
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
    innerComparisons = ["comparison", "ifClauseBitExp", "while_clause"]
    outerBlocks = ["ifStatement", "true_part", "basicStatementDo"]
    if lbnfLabel in innerComparisons:
        i = innerComparisons.index(lbnfLabel)
        p_Functions.expressionToInstructions(p_Functions.substate["expression"], currentScope["instructions"])
        for entry in reversed(endLabels):
            if entry["lbnfLabel"] == outerBlocks[i]:
                isUntil = "isUntil" in p_Functions.substate
                entry["used"] = True
                if isUntil:
                    palmatOpcode = "iftrue"
                else:
                    palmatOpcode = "iffalse"
                #currentScope["instructions"].append({palmatOpcode: entry["endLabel"]})
                jumpToTarget(currentScope, "ux", palmatOpcode)
                if lbnfLabel == "while_clause":
                    parent = currentScope["parent"]
                    parentScope = PALMAT["scopes"][parent]
                    '''
                    parentScope["identifiers"][beginningLabel] = { 
                        "label": [currentScope["self"], 0]}
                    if isUntil:
                        parentScope["instructions"][-1]["goto"] = beginningLabel
                        currentScope["identifiers"][beginningLabel2] = { "label": [currentScope["self"], 1] }
                        currentScope["instructions"][1]["label"] = beginningLabel2
                        currentScope["identifiers"][entryLabel] = { "label": [currentScope["self"], len(currentScope["instructions"])]}
                        currentScope["instructions"].append({"noop": True, "label": entryLabel})
                        currentScope["instructions"][0].pop('noop')
                        currentScope["instructions"][0]['goto'] = entryLabel
                        p_Functions.substate.pop("isUntil")
                        entry["recycle"] = beginningLabel2
                    else:
                        entry["recycle"] = beginningLabel
                    '''
                    if isUntil:
                        newLabel = createTarget(currentScope, "ub")
                        currentScope["instructions"][0].pop('noop')
                        currentScope["instructions"][0]['goto'] = newLabel
                        p_Functions.substate.pop("isUntil")
                    entry["recycle"] = "up"
                break
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
                attributes = findIdentifier(identifier, PALMAT, state["scopeIndex"])
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
    instructions = currentScope["instructions"]
    identifiers = currentScope["identifiers"]
    if "recycle" in endLabels[-1]:
        '''
        identifiers[beginningLabel] = { "label": [state["scopeIndex"], 0]}
        instructions.append({"goto": endLabels[-1]["recycle"]})
        '''
        jumpToTarget(currentScope, "up", "goto")
    if endLabels[-1]["used"]:
        '''
        identifiers[endLabel] = { "label": [state["scopeIndex"], len(instructions)] }
        instructions.append({"noop": True, "label": endLabel})
        '''
        createTarget(currentScope, "ux")
    endLabels.pop()
    
    # If this is this a DO ... END block, we need to insert a PALMAT
    # goto instruction at the end of the block back to the original 
    # position in the parent scope.
    if isDo:
        '''
        returnLabel = "^ue_%d^" % uniqueCount
        uniqueCount += 1
        parentScope = PALMAT["scopes"][preservedScopeIndex]
        currentScope["identifiers"][returnLabel] = { "label": [preservedScopeIndex, len(parentScope["instructions"])]}
        currentScope["instructions"].append({'goto': returnLabel})
        parentScope["instructions"].append({'noop': True, "label": returnLabel})
        '''
        exitDo(PALMAT, currentScope)
        state["scopeIndex"] = preservedScopeIndex
        # I originally added the following instruction to make sure that the 
        # *final* goto added above would have a target to land on, since 
        # otherwise it could be at an unfilled position one past the end
        # of the final PALMAT instruction in scope 0.  However, the e
        # execution loop ends gracefully on that condition, so there's no
        # point in peppering the code with pointless noop instructions.
        # That's why the following instruction is now commented out.
        #PALMAT["scopes"][preservedScopeIndex]["instructions"].append({'noop': True})
    
    return True, PALMAT
