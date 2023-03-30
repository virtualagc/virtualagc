#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       generatePALMAT.py
Reference:      PALMAT.md
Purpose:        Part of the code-generation system for the "modern" HAL/S
                compiler yaHAL-S-FC.py+modernHAL-S-FC.c.
History:        2022-12-19 RSB  Created. 
"""

import copy
import json
import p_Functions
substate = p_Functions.substate
from palmatAux import *
from executePALMAT import isBitArray
from expressionSM import expressionSM
from doForSM import doForSM
from p_Functions import expressionComponents, doForComponents
from saveValueToVariable import convertSimpleAttributes

def traceIt(state, endLabels, lbnfLabel, beforeAfter="before", trace=True, depth=0):
    if not trace:
        return
    print("TRACE:  %s, depth=%d" % (beforeAfter, depth))
    print("\tcomponent     = %s" % lbnfLabel)
    if "stateMachine" in state:
        stateMachine = state.pop("stateMachine")
        print("\tstate sans SM =", state)
        function = stateMachine.pop("function")
        print("\tstate machine =", stateMachine)
        stateMachine["function"] = function
        state["stateMachine"] = stateMachine
    else:
        print("\tstate         =", state)
    print("\tsubstate      =", substate)
    if len(endLabels) <= 3:
        print("\tendLabels     =", endLabels)
    else:
        print("\tendLabels     =", ["..."] + endLabels[-3:])

# For FUNCTION or PROCEDURE blocks.  Gets a list of all subroutine parameters
# declared in the subroutine's scope.
def allDeclaredParameters(currentScope):
    declared = {}
    identifiers = currentScope["identifiers"]
    for parameter in currentScope["attributes"]["parameters"]:
        identifier = "^" + parameter + "^"
        if identifier not in identifiers:
            identifier = "^c_" + parameter + "^"
            if identifier not in identifiers:
                identifier = "^b_" + parameter + "^"
                if identifier not in identifiers:
                    identifier = "^s_" + parameter + "^"
                    if identifier not in identifiers:
                        identifier = "^e_" + parameter + "^"
                        if identifier not in identifiers:
                            continue
        declared[parameter] = identifier
        if "parameter" not in identifiers[identifier]:
            identifiers[identifier]["parameter"] = True
    return declared

# Same as allDeclaredParemters, except for a PROCEDURE's ASSIGNs.
def allDeclaredAssigns(currentScope):
    #declared = {}
    identifiers = currentScope["identifiers"]
    for assignment in currentScope["attributes"]["assignments"]:
        identifier = "^" + assignment + "^"
        if identifier not in identifiers:
            identifier = "^c_" + assignment + "^"
            if identifier not in identifiers:
                identifier = "^b_" + assignment + "^"
                if identifier not in identifiers:
                    identifier = "^s_" + assignment + "^"
                    if identifier not in identifiers:
                        identifier = "^e_" + assignment + "^"
                        if identifier not in identifiers:
                            continue
        #declared[assignment] = identifier
        if "assignment" not in identifiers[identifier]:
            identifiers[identifier]["assignment"] = True
    #return declared

# This function takes a flattened list of values for a declaration with 
# ARRAY(...) ... INITIAL(...) or ARRAY(...) ... CONSTANT(...) and lengthens
# it consistently with the dimensions of the array.  The arrayList is 
# manipulated in-place.  Returns True on success, False on failure (input
# arrayList already longer than compatible with the dimensions, or shorter
# but without a *).
def embiggenArrayList(arrayList, attributes):
    numElements = 1
    dimensions = copy.deepcopy(attributes["array"])
    if "vector" in attributes:
        dimensions.append(attributes["vector"])
    elif "matrix" in attributes:
        dimensions.extend(attributes["matrix"])
    for d in dimensions:
        numElements *= d
    filling = False
    if arrayList[-1:] == [{'fill'}]:
        filling = True
        arrayList.pop()
    if len(arrayList) > numElements:
        return False
    if len(arrayList) != 1 and len(arrayList) < numElements and not filling:
        return False
    if len(arrayList) == 1:
        e = arrayList[0]
        while len(arrayList) < numElements:
            arrayList.append(e)
    else:
        while len(arrayList) < numElements:
            arrayList.append(None)
    return True

# "Inflates" an unraveled list of data values into a properly-dimensioned
# array, in-place. It is known prior to entry that the number of values and 
# their datatypes are correct, so no error checking or conversion is done.  This 
# function is *not* recursive.  It works from the bottom up rather than the 
# topp down.
def inflateArray(arrayList, attributes):
    dimensions = []
    if "vector" in attributes:
        dimensions.append(attributes["vector"])
    elif "matrix" in attributes:
        dimensions.extend(attributes["matrix"])
    for width in reversed(dimensions):
        numElements = len(arrayList)
        for i in range(numElements // width):
            vector = arrayList[i:i+width]
            arrayList[i:i+width] = [vector]
    for width in reversed(attributes["array"][1:]):
        numElements = len(arrayList)
        for i in range(numElements // width):
            vector = arrayList[i:i+width] + ["a"]
            arrayList[i:i+width] = [vector]
    arrayList.append("a")

'''
# This is a recursive function used for fixing CALL instructions targeting
# forward-declared FUNCTIONs and PROCEDUREs.  Such CALLs will have the wrong
# scope (but correct identifer) for the CALLs, because the scopes in which the
# subroutines reside aren't known  when the forward declaration is encountered.
# The topIndex is supposed to indicate the topmost scope in which the call can
# occur (namely, the one in which the identifier appears in the identifier
# list), while oldValue is the current value of the "call" key in the 
# instruction, and newValue is the desired new value.  The function must
# recurse through all descendents of the topIndex scope.
def fixForwardCalls(PALMAT, topIndex, oldValue, newValue, trace=False):
    scope = PALMAT["scopes"][topIndex]
    instructions = scope["instructions"]
    for i in range(len(instructions)):
        instruction = instructions[i]
        if "call" in instruction and instruction["call"] == oldValue:
            instruction["call"] = newValue
            if trace:
                print("\tFixup for CALL at (%d, %d)" % (topIndex, i+1))
    for index in scope["children"]:
        fixForwardCalls(PALMAT, index, oldValue, newValue, trace)
'''
    
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

lastExpressionSM = None
def generatePALMAT(ast, PALMAT, state={ "history":[], "scopeIndex":0 }, 
                   trace=False, endLabels=[], depth=-1, trace4=False):
    global lastExpressionSM
    depth += 1
    newState = state
    lbnfLabel, source = astToLbnf(ast)
    scopes = PALMAT["scopes"]
    preservedScopeIndex = state["scopeIndex"]
    currentScope = scopes[preservedScopeIndex]
    
    # Create a label for the end of this grammar component.  If none of the
    # subcomponents end up using it, we won't bother to use it, and it won't
    # take up any resources.  For example, a basic assignment statement will
    # never need to jump to the end of the statement, but an IF ... THEN ...
    # statement may need to if the conditional is false.
    expressionFlush = []
    endLabels.append({"lbnfLabel": lbnfLabel, 
                      "used": False,
                      "expressionFlush": expressionFlush})

    # Is this a DO ... END block?  If it is, then we have to do several things:
    # create a new child scope and make it current, and add a goto PALMAT 
    # instruction from the existing current scope to the new scope.  
    # IF statements are treated like DO statements in this regard, because
    # they cause me lots of trouble (with nesting them) otherwise.
    isDo = lbnfLabel in ["basicStatementDo", "otherStatementIf"]
    if isDo:
        scopeType = "unknown"
        if lbnfLabel == "basicStatementDo":
            scopeType = "do"
        elif lbnfLabel == "otherStatementIf":
            scopeType = "if"
        state["scopeIndex"], currentScope = \
            makeDoEnd(PALMAT, source, currentScope, scopeType)
    
    '''
    The use of a "state machine" object in the state will hopefully be
    a more-systematic framework for code-generation than the relatively
    inconsistent melange of methods that preceded it.  Right now, though,
    it's in early stages and some grammar components are processed using the
    older (chaotic) method, while others are processed using the new 
    state-machine framework instead.  The state-machine function 
    associated with the specific type of lbnfLabel is called both upon 
    beginning the processing of the component (with an argument of 0),
    for strings (with an argument of 1) and upon finishing it (with an 
    argument of 2).  The state-machine function itself is what removes 
    the stateMachine object from state, when that is appropriate.
    '''
    allComponentsSM = expressionComponents + doForComponents
    stateMachine = None
    parentStateMachine = None
    if "stateMachine" in state \
            and state["stateMachine"]["owner"] in doForComponents \
            and lbnfLabel in allComponentsSM:
        # We want to start a new state machine, but an existing one hasn't
        # completed yet.  This would occur, for example, for evaluating 
        # expressions within a DO FOR or nested DO FORs.  We must therefore
        # pop the existing state machine from the state, while preserving it
        # for later restoration when this component completes processing,
        # and insert a newly-created state-machine instead.
        parentStateMachine = state["stateMachine"]
        parentStateMachine["pauses"].append(len(currentScope["instructions"]))
        state.pop("stateMachine")
        debug(PALMAT, state, "Pausing SM %s, %s" % \
              (parentStateMachine["owner"], 
               parentStateMachine["internalState"]))
    if "stateMachine" not in state:
        if lbnfLabel in expressionComponents:
            debug(PALMAT, state, "Starting SM %s" % lbnfLabel)
            state["stateMachine"] = {"function": expressionSM, 
                                     "owner": lbnfLabel,
                                     "pauses": [],
                                     "depth": depth }
            # Note that "isUntil" persists in substate only during processing
            # of a "while_clause", which does nothing other than to compute
            # an expression (including relational expressions).
            for e in reversed(endLabels):
                if e["lbnfLabel"] == "basicStatementDo":
                    if "isUntil" in substate:
                        state["stateMachine"]["expressionFlush"] = \
                                                        e["expressionFlush"]
                        break
            if "lbnfLabel" in ["char_spec"]:
                state["stateMachine"]["compiledExpression"] = []
        elif lbnfLabel in doForComponents:
            debug(PALMAT, state, "Starting SM %s" % lbnfLabel)
            currentScope["type"] = "do for"
            state["stateMachine"] = {"function": doForSM, 
                                     "owner": lbnfLabel,
                                     "pauses": [] }
            for e in reversed(endLabels):
                if e["lbnfLabel"] == "basicStatementDo":
                    e["recycle"] = True
                    e["used"] = True
                    break
    if "stateMachine" in state:
        stateMachine = state["stateMachine"]
        stateMachine["function"](0, ast, PALMAT, state, trace, depth, \
                                 trace4)

    #--------------------------------------------------------------------------
    # Main generation of PALMAT for the statement, sans setup and cleanup.
    traceIt(state, endLabels, lbnfLabel, "before", trace, depth)
    newState = p_Functions.augmentHistory(state, lbnfLabel)
    if newState != state:
        if "stateMachine" in state:
            newState["stateMachine"] = state["stateMachine"]
    elif lbnfLabel in p_Functions.objects:
        func = p_Functions.objects[lbnfLabel]
        success, newState = func(PALMAT, state)
        if "stateMachine" in state:
            # We want to make sure that newState's state machine
            # is the same object as state's, and not merely
            # a clone of it.
            newState["stateMachine"] = state["stateMachine"]
        traceIt(state, endLabels, lbnfLabel, "after", trace, depth)
        if not success:
            endLabels.pop()
            return False, PALMAT
    if lbnfLabel == "any_statement" and currentScope["type"] == "do case":
        identifier = "^dc_%d^" % currentScope["caseCounter"];
        currentScope["caseCounter"] += 1;
        currentScope["identifiers"][identifier] = {
            "label": [currentScope["self"], len(currentScope["instructions"])]}
        appendInstruction(currentScope["instructions"], \
                          {'noop': True, 'label': identifier}, source)
    for component in ast["components"]:
        if isinstance(component, str):
            if component[:1] == "^":
                traceIt(newState, endLabels, component, "before", trace, depth)
                if "stateMachine" in newState:
                    state["stateMachine"]["function"](1, component, PALMAT, \
                                                      newState, trace, depth, \
                                                      trace4)
                success = p_Functions.stringLiteral(PALMAT, newState, component)
                if "stateMachine" in state and "stateMachine" not in newState:
                    state.pop("stateMachine")
                traceIt(newState, endLabels, component, "after", trace, depth)
            else:
                success, PALMAT = generatePALMAT( \
                    { "lbnfLabel": component, "components" : [] }, \
                    PALMAT, newState, trace, endLabels, depth, trace4 )
                if "stateMachine" in state and "stateMachine" not in newState:
                    traceIt(newState, endLabels, component, \
                            "ending state machine \"%s\"" % \
                              state["stateMachine"]["owner"], trace, depth)
                    state.pop("stateMachine")
            if not success:
                endLabels.pop()
                return False, PALMAT
        else:
            success, PALMAT = generatePALMAT(component, PALMAT, \
                                    newState, trace, endLabels, depth, trace4)
            if "stateMachine" in state and "stateMachine" not in newState:
                state.pop("stateMachine")
            if not success:
                endLabels.pop()
                return False, PALMAT

    # ------------------------------------------------------------------    
    # Cleanups after generation of the almost-complete PALMAT for this
    # statement.  Includes stuff like actual assignments to variables
    # after computation of expressions has all been done, placement of 
    # compiler-generated labels for the ends of IF statements, and so on.
    
    # The patterns dictionary is a way of identifying some components that
    # require post-processing here.  The keys are lbnfLabels for the 
    # component; the value modifies that by giving a list of relevant 
    # ancestor (though not necessarily immediate-parent) components.
    
    stateMachine = None
    if "stateMachine" in state:
        stateMachine = state["stateMachine"]
        state["stateMachine"]["function"](2, ast, PALMAT, \
                                          state, trace, depth, trace4)
        if "stateMachine" not in state:
            debug(PALMAT, state, "ending SM \"%s\"" % lbnfLabel)
            traceIt(state, endLabels, lbnfLabel, "ending SM \"%s\"" % lbnfLabel, \
                    trace, depth)
            if stateMachine["function"] == expressionSM:
                lastExpressionSM = stateMachine
            if parentStateMachine != None:
                debug(PALMAT, state, "Restoring SM %s, %s" % \
                      (parentStateMachine["owner"], 
                       parentStateMachine["internalState"]))
                parentStateMachine["completed"] = lbnfLabel
                state["stateMachine"] = parentStateMachine

    lbnfLabelPatterns = {
            #"relational_exp": ["ifThenElseStatement", "ifStatement"], 
            "ifClauseRelationalExp": ["ifThenElseStatement", "ifStatement"], 
            "ifClauseBitExp": ["ifThenElseStatement", "ifStatement"], 
            "while_clause": ["basicStatementDo"]
        }
    currentIndex = currentScope["self"]
    if lbnfLabel in lbnfLabelPatterns:
        aLabels = lbnfLabelPatterns[lbnfLabel]
        # Since ifThenElseStatement is processed differently than ifStatement,
        # and since these may be nested, we need to determine which of them,
        # if either, is the inner.
        ancestorLabels = []
        for ancestor in reversed(state["history"]):
            if ancestor in aLabels:
                ancestorLabels = [ancestor]
                break        
        # The following is a loop because I originally thought that 
        # ancestorLabels might be longer than 1.  It's not, so this could be
        # rewritten as an if, but there's no advantage in doing so, and possibly
        # lots of hassle, so I'm just letting it this way.
        for ancestor in ancestorLabels:
            if ancestor not in state["history"]:
                continue
            p_Functions.expressionToInstructions( \
                substate["expression"], \
                currentScope["instructions"])
            for entry in reversed(endLabels):
                if entry["lbnfLabel"] == ancestor:
                    isUntil = "isUntil" in substate
                    entry["used"] = True
                    if ancestor == "ifThenElseStatement":
                        jumpToTarget(PALMAT, source, currentIndex, \
                                     currentIndex, \
                                     "uf", "iffalse")
                    elif not isUntil:
                        jumpToTarget(PALMAT, source, currentIndex, \
                                     currentIndex, \
                                     "ux", "iffalse")
                    if lbnfLabel == "while_clause":
                        for e in reversed(endLabels):
                            if e["lbnfLabel"] == "basicStatementDo":
                                e["recycle"] = True
                                break;
                        if isUntil:
                            substate.pop("isUntil")
                    break
            break
    # Below are various other patterns not covered by lbnfLabelPatterns above.
    # The lbnfLabel of the relevant component must not be the same as any key 
    # in lbnfLabelPatterns.
    elif lbnfLabel in ["any_statement", "doGroupHeadCaseElse"] and \
            currentScope["type"] == "do case":
        appendInstruction(currentScope["instructions"], \
                          {'goto': (currentIndex, "^dc_exit^")}, source)
    elif lbnfLabel == "declare_group" and \
            currentScope["type"] in ["function", "procedure"]:
        isProcedure = False
        if currentScope["type"] == "procedure":
            allDeclaredAssigns(currentScope)
            isProcedure = True
        declared = allDeclaredParameters(currentScope)
        parameters = currentScope["attributes"]["parameters"]
        if len(declared) == len(parameters) and \
                "alreadyPopped" not in currentScope:
            currentScope["alreadyPopped"] = True
            instructions = currentScope["instructions"]
            if isProcedure:
                r = reversed(parameters)
            else:
                r = parameters
            for parameter in r:
                identifier = declared[parameter][1:-1]
                appendInstruction(instructions, \
                    {'storepop': (currentScope["self"], identifier)}, source)
    elif lbnfLabel == "basicStatementCall":
        currentIdentifier = substate["currentIdentifier"]
        si, attributes = findIdentifier(currentIdentifier, PALMAT, currentIndex)
        if "callAssignments" not in substate["commonAttributes"]:
            assignments = []
        else:
            assignments = substate["commonAttributes"]["callAssignments"]
        if "assignments" not in attributes:
            attributes["assignments"] = []
        if len(attributes["assignments"]) != len(assignments):
            print("\tASSIGN-list length disagreement in %s, %s vs %s." % \
              (currentIdentifier[1:-1], assignments, attributes["assignments"]))
            endLabels.pop()
            return False, PALMAT
        assDict = {}
        for i in range(len(assignments)):
            assDict[attributes["assignments"][i]] = assignments[i]
        appendInstruction(currentScope["instructions"], \
                          {'call': (si, currentIdentifier[1:-1]),
                            'assignments': assDict}, source)
    elif lbnfLabel == "basicStatementReturn":
        # We need to find the most-narrow context that's a FUNCTION, 
        # PROCEDURE or PROGRAM.
        i = currentIndex
        stackPos = 0
        while i != None:
            dummy = PALMAT["scopes"][i]
            if dummy["type"] == 'function':
                stackPos = 2
                break
            elif dummy["type"] == 'procedure':
                stackPos = 1
                break
            elif dummy["type"] == 'program':
                stackPos = -1
                break
            i = dummy["parent"]
        if stackPos == 0:
            print("\tRETURN without parent FUNCTION or PROCEDURE")
            endLabels.pop()
            return False, PALMAT
        elif stackPos == -1:
            # Return from a PROGRAM. 
            appendInstruction(currentScope["instructions"], \
                {'halt': True}, source)
        else:
            # Return from a FUNCTION or PROCEDURE.
            appendInstruction(currentScope["instructions"], \
                              {'return': stackPos}, source)
    elif lbnfLabel in ["case_else", "doGroupHeadCase"]:
        currentScope["type"] = "do case"
        currentScope["caseCounter"] = 1
        instructions = currentScope["instructions"]
        appendInstruction(instructions, {'case': "dc_"}, source)
        if lbnfLabel == "case_else":
            currentScope["identifiers"]["^dc_else^"] = { 
                "label": [currentIndex, len(instructions)]}
            appendInstruction(instructions, \
                              {"noop": True, "label": "^dc_else^"}, source)
    elif lbnfLabel == "closing":
        instructions = currentScope["instructions"]
        if currentScope["type"] == "procedure" and \
                (len(instructions) == 0 or 'return' not in instructions[-1]):
            appendInstruction(instructions, {'return': 1}, source)
        parentIndex = currentScope["parent"]
        state["scopeIndex"] = parentIndex
        currentScope = PALMAT["scopes"][parentIndex]
    elif lbnfLabel in ["blockHeadFunction", "blockHeadProcedure", 
                       "blockHeadProgram", "blockHeadCompool"]:
        blockTypes = {
                "blockHeadFunction": "function",
                "blockHeadProcedure": "procedure",
                "blockHeadProgram": "program",
                "blockHeadCompool": "compool"
            }
        blockIdentifier = substate["currentIdentifier"]
        identifierDict = currentScope["identifiers"][blockIdentifier]
        if lbnfLabel == "blockHeadFunction" and \
                isUnmarkedScalar(identifierDict):
            identifierDict["scalar"] = True
        blockType = blockTypes[lbnfLabel]
        childIndex = addScope(PALMAT, currentScope["self"], blockType)
        PALMAT["scopes"][childIndex]["instructions"].append({"automatics": True})
        if blockType in ["function", "procedure"] and \
                "forward" in identifierDict:
            #fixForwardCalls(PALMAT, currentIndex, \
            #                (identifierDict["scope"], blockIdentifier[1:-1]),
            #                (childIndex, blockIdentifier[1:-1]), trace)
            identifierDict["scope"] = childIndex
            identifierDict.pop("forward")
        state["scopeIndex"] = childIndex
        currentScope = PALMAT["scopes"][childIndex]
        currentScope["name"] = substate["currentIdentifier"]
        currentScope["attributes"] = identifierDict
    elif lbnfLabel == "true_part":
        p_Functions.expressionToInstructions( \
            substate["expression"], currentScope["instructions"])
        endLabels[-2]["used"] = True
        jumpToTarget(PALMAT, source, currentIndex, currentIndex, "ux", "goto")
        if createTarget(PALMAT, source, currentIndex, currentIndex, "uf") \
                == None:
            return False, PALMAT
    elif lbnfLabel == "subscript" and \
            state["history"][-2:] == ["assignment", "variable"] and \
            "finalExpression" in state:
        substate["lhsSubscripts"][len(substate["lhs"])-1] = \
                                                    state["finalExpression"]
        if lastExpressionSM["whereTo"] == "instructions" and \
                not lastExpressionSM["compileTimeComputable"]:
            count = lastExpressionSM["instructionCount"]
            currentScope["instructions"][-count:] = []
    elif lbnfLabel == "assignment":
        instructions = currentScope["instructions"]
        p_Functions.expressionToInstructions( \
            substate["expression"], instructions)
        lhsIdentifiers = substate["lhs"]
        lhsSubscripts = substate["lhsSubscripts"]
        count = len(substate["lhs"])
        while count > 0:
            count -= 1
            si, identifier = lhsIdentifiers.pop()
            if count in lhsSubscripts:
                base = "substore"
                subscript = lhsSubscripts[count]
                lhsSubscripts.pop(count)
            else:
                base = "store"
                subscript = None
            if si == -1:
                dummy, attributes = findIdentifier("^"+identifier+"^", PALMAT, currentIndex, True)
            else:
                attributes = \
                    PALMAT["scopes"][si]["identifiers"]["^"+identifier+"^"]
            if attributes == None:
                print("\tAssignment variable %s not accessible." % identifier[1:-1])
                endLabels.pop()
                return False, PALMAT
            if subscript != None:
                instructions.extend(subscript[:-1])
            if count == 0:
                base = base + "pop"
            appendInstruction(instructions, { base: (si, identifier) }, source)
    elif lbnfLabel in ["basicStatementWritePhrase", "basicStatementWriteKey"]:
        instructions = currentScope["instructions"]
        p_Functions.expressionToInstructions( \
            substate["expression"], instructions)
        appendInstruction(instructions, { "write": substate["LUN"] }, source)
    elif lbnfLabel in ["basicStatementReadPhrase"]:
        instructions = currentScope["instructions"]
        p_Functions.expressionToInstructions( \
            substate["expression"], instructions)
        appendInstruction(instructions, { "read": substate["LUN"] }, source)
    elif lbnfLabel in ["declare_statement", "temporary_stmt"]:
        markUnmarkedScalars(currentScope["identifiers"])
        messages = completeInitialConstants(currentScope)
        setUninitialized(PALMAT, currentScope)
        if messages != []:
            print("\tGeometry mismatch for INITIAL or CONSTANT data,", messages)
            return False, PALMAT
    elif lbnfLabel in ["minorAttributeRepeatedConstant", "minorAttributeStar"]:
        '''
        We get to here after an INITIAL(...) or CONSTANT(...)
        has been fully processed to the extent of preparing
        substate["expression"] for computing the value in 
        parenthesis, but without having performed that computation
        yet, leaving a bogus "initial" or "constant" attribute.
        We now have to perform the actual computation, if possible,
        and correct the bogus constant.  Since DECLARE or TEMPORARY
        statements always come at the beginnings of blocks, prior to any 
        executable code, we don't have to worry about preserving
        any existing PALMAT for the scope.
        Later ... sez you!  In the interpreter, we do indeed allow DECLARE
        statements practically anywhere.
        '''
        identifiers = currentScope["identifiers"]
        instructions = currentScope["instructions"]
        currentIdentifier = substate["currentIdentifier"]
        '''
        What's going to happen now depends on what the most-recently-completed
        expression state machine left on the instruction stack.  That 
        most-recently-completed expression state machine is memorialized in
        lastExpressionSM.  There are 3 key/value pairs in it of relevance:
            "whereTo"                   Indicates where it sent its output, with 
                                        the choices being either 
                                        "expressionFlush" or "instructions".
            "instructionCount"          Tells how many instructions were sent 
                                        to that destination.
            "compileTimeComputable"     Tells whether or not the expression
                                        was completely resolved at compile
                                        time.
        '''
        if      lastExpressionSM == None or \
                lastExpressionSM["whereTo"] != "instructions" or \
                lastExpressionSM["instructionCount"] == 0:
            print("\tINITIAL or CONSTANT not computable, for unknown reason.")
            return False, PALMAT
        elif    not lastExpressionSM["compileTimeComputable"]:
            print("\tINITIAL or CONSTANT cannot be computed at compile time.")
            return False, PALMAT
        else:
            counter = lastExpressionSM["instructionCount"]
            arrayList = []
            while counter > 0:
                if len(instructions) < counter:
                    print("\tImplementation error, cannot pop instruction.")
                    return False, PALMAT
                value = instructions.pop(-counter)
                counter -= 1
                if "vector" in value or "matrix" in value:
                    valueList = []
                    if "vector" in value:
                        flatten(value["vector"], valueList)
                    else:
                        flatten(value["matrix"], valueList)
                    for i in range(len(valueList)):
                        if valueList[i] == None:
                            valueList[i] = { "empty"}
                        else:
                            valueList[i] = {"number": valueList[i] }
                elif "array" in value:
                    # I don't know quite what to do about this as of yet.
                    # I need to know what the type (INTEGER, ...) of the ARRAY
                    # is, in order to know how to set the individual values.
                    # The following is just a temporary bandaid.
                    valueList = []
                    flatten(value["array"], valueList)
                    for i in range(len(valueList)):
                        if valueList[i] == None:
                            valueList[i] = { "empty"}
                        elif isinstance(valueList[i], (int, float)):
                            valueList[i] = {"number": valueList[i] }
                        elif isinstance(valueList[i], str):
                            valueList[i] = {"string": valueList[i] }
                        else:
                            valueList[i] = 0
                else:
                    valueList = [value]
                    
                # Now insert the values in the data object, one-by-one.  In
                # retrospect, this is pretty inefficient for objects like
                # STRUCTUREs, and I'm not quite sure I did it this way.
                for value in valueList:
                    if False:
                        pass
                    elif "empty" in value:
                        value = None
                    elif "number" in value:
                        try:
                            value = int(value["number"])
                        except:
                            try:
                                value = float(value["number"]);
                            except:
                                print("\tINITIAL or CONSTANT not SCALAR or INTEGER:", \
                                      value)
                                return False, PALMAT
                    elif "boolean" in value:
                        value = value["boolean"]
                    elif "string" in value:
                        value = value["string"]
                    elif "vector" in value:
                        # This will be a list of values rather than a single value.
                        # It won't be a HAL/S VECTOR type, in the sense that the 
                        # values in the list may not be SCALAR.
                        value = list(value["vector"])
                    if currentIdentifier != "":
                        identifierDict = identifiers[currentIdentifier]
                    else:
                        identifierDict = substate["commonAttributes"]
                    if isUnmarkedScalar(identifierDict):
                        identifierDict["scalar"] = True
                    if "initial" in identifierDict and "constant" in identifierDict:
                        print("\tIdentifier", currentIdentifier[1:-1], \
                                "cannot have both INITIAL and CONSTANT.")
                        identifiers.pop(currentIdentifier)
                        endLabels.pop()
                        return False, PALMAT
                    key = None
                    if "initial" in identifierDict:
                        key = "initial"
                    elif "constant" in identifierDict:
                        key = "constant"
                    if False:
                        pass
                    elif "array" in identifierDict:
                        if isinstance(value, dict) and "fill" in value:
                            arrayList.append({'fill'})
                        else: 
                            arrayList.append(convertSimpleAttributes(value, identifierDict))
                        continue
                    elif isinstance(value, (int, float)) and \
                            "integer" in identifierDict:
                        value = hround(value)
                    elif isinstance(value, (int, float)) and \
                            "scalar" in identifierDict:
                        value = float(value)
                    elif isinstance(value, (int, float)) and \
                            "bit" in identifierDict:
                        length = identifierDict["bit"]
                        value = [hround(value) & ((1 << length) - 1), length, "b"]
                    elif isBitArray(value) and "bit" in identifierDict:
                        pass
                    elif isinstance(value, str) and "character" in identifierDict:
                        pass
                    elif (value == None or isinstance(value, (int, float))) and \
                            "vector" in identifierDict:
                        numCols = identifierDict["vector"]
                        if key not in identifierDict or \
                                isinstance(identifierDict[key], str):
                            if value != None:
                                value = float(value)
                            value = [value]
                        else:
                            if len(identifierDict[key]) >= numCols:
                                print("\tData for INITIAL or CONSTANT of " + \
                                      currentIdentifier + " exceeds dimensions.")
                                value = identifierDict[key]
                            else:
                                if value != None:
                                    value = float(value)
                                value = identifierDict[key] + [value]
                    elif (value == None or isinstance(value, (int, float))) and \
                            "matrix" in identifierDict:
                        numRows, numCols = identifierDict["matrix"]
                        if key not in identifierDict or \
                                isinstance(identifierDict[key], str):
                            if value != None:
                                value = float(value)
                            value = [[value]]
                        else:
                            matrix = identifierDict[key]
                            row = len(matrix)-1
                            col = len(matrix[row])
                            if col >= numCols:
                                matrix.append([])
                                row += 1
                                col = 0
                            if row >= numRows:
                                print("\tData for INITIAL or CONSTANT of " + \
                                      currentIdentifier + " exceeds dimensions.")
                            else:
                                if value != None:
                                    value = float(value)
                                matrix[row].append(value)
                            value = matrix
                    elif "structure" in identifierDict:
                        if identifierDict[key] == "^?^":
                            # We have to create an uninitialized structure,
                            # so that we can fill it with data.
                            templateName = identifierDict["structure"]
                            templateScopeIndex, templateAttributes = \
                                findIdentifier("^" + templateName + "^", \
                                               PALMAT, currentIndex)
                            struct = uninitializedStructure(PALMAT, currentScope, \
                                                            templateName, \
                                                            templateAttributes)
                            identifierDict[key] = struct
                        else:
                            struct = identifierDict[key]
                        # We now have to find the next uninitialized location
                        # in the structure and fill it with value.
                        if not insertNextElement(struct, value):
                            print("\tCannot insert INITIAL or CONSTANT data:", \
                                  currentIdentifier, value)
                        value = struct
                    elif isinstance(value, dict) and "fill" in value:
                        identifierDict["fill"] = key
                        continue
                    else:
                        print("\tDatatype mismatch in INITIAL or CONSTANT:", \
                              value, currentIdentifier, identifierDict)
                        identifiers.pop(currentIdentifier)
                        endLabels.pop()
                        return False, PALMAT
                    identifierDict[key] = value
                    if key == "initial":
                        identifierDict["value"] = copy.deepcopy(value)
            if "array" in identifierDict:
                embiggened = embiggenArrayList(arrayList, identifierDict)
                if not embiggened:
                    print("\tINITIAL or CONSTANT clause for ARRAY %s wrong length." \
                          % currentIdentifier[1:-1])
                    identifiers.pop(currentIdentifier)
                    endLabels.pop()
                    return False, PALMAT
                inflateArray(arrayList, identifierDict)
                identifierDict[key] = arrayList
                if key == "initial":
                    identifierDict["value"] = copy.deepcopy(arrayList)
    elif lbnfLabel in ["char_spec", "bitSpecBoolean",  
                       "sQdQName_doublyQualNameHead_literalExpOrStar",
                       "arraySpec_arrayHead_literalExpOrStar"] and \
            "currentStructureTemplateIdentifier" not in substate:
        # I wish I had commented this when I first wrote it!  What I think
        # is going on here is that in a DECLARE for a BIT, CHARACTER, VECTOR,
        # MATRIX, or ARRAY, list of dimensions will have been computed by the
        # time we've reached this point and (unfortunately!) left on the list
        # of instructions.  This was fine (I thought), because declarations are
        # always at the beginnings of blocks, and hence there are never any
        # instructions to confuse the process of retrieving those dimensions.
        # However, if you're running the interpreter, in which DECLARE 
        # statements can appear anywhere, and if you've `spool'd a bunch of
        # HAL/S code, then the list of instructions may *not* be empty when
        # you encounter a DECLARE.  So I've had to add a bit of code to the 
        # following in order to work around that.
        identifiers = currentScope["identifiers"]
        instructions = currentScope["instructions"]
        currentIdentifier = substate["currentIdentifier"]
        # Note that the expression state machine should have left
        # a number on the instruction queue if the expression
        # was computable at compile time.
        try:
            maxLens = []
            # This shouldn't collide with any actual instructions previously
            # present, because a {"number":...} couldn't have been the last
            # PALMAT instruction generated for a statement.
            while len(instructions) > 0 and "number" in instructions[-1]:
                value = instructions.pop()
                maxLens[0:0] = [ round(float(value["number"])) ]
            if currentIdentifier != "":
                identifierDict = identifiers[currentIdentifier]
            else:
                identifierDict = substate["commonAttributes"]
            if lbnfLabel == "char_spec":
                datatype = "character"
                if len(maxLens) not in [0, 1]:
                    raise Exception("CHARACTER(...) wrong dimension")
            elif lbnfLabel == "sQdQName_doublyQualNameHead_literalExpOrStar":
                if "vector" in identifierDict:
                    if len(maxLens) not in [0, 1]:
                        raise Exception(\
                            "VECTOR(...) wrong dimension: '%s' %s %s %s" \
                            % (currentIdentifier, 
                               str(identifierDict), 
                               str(maxLens),
                               str(substate["commonAttributes"])) )
                    datatype = "vector"
                elif "matrix" in identifierDict:
                    datatype = "matrix"
                    if len(maxLens) not in [1, 2]:
                        raise Exception("MATRIX(...) wrong dimension")
                else:
                    raise Exception(\
                        "Unimplemented datatype attributes: %s %s" \
                          % (str(identifierDict), str(maxLens)) )
            elif lbnfLabel == "arraySpec_arrayHead_literalExpOrStar":
                datatype = "array"
            elif lbnfLabel == "bitSpecBoolean":
                datatype = "bit"
            if datatype in ["matrix", "array"]:
                identifierDict[datatype].extend(maxLens)
            elif datatype == "bit" and len(maxLens) == 0:
                identifierDict[datatype] = 1
            else:
                identifierDict[datatype] = maxLens[0]
            #instructions.clear()
        except Exception as error:
            print("\tComputation of datatype length failed: '%s' '%s': %s" % \
                  (lbnfLabel, currentIdentifier, error) )
            #instructions.clear()
            if currentIdentifier in identifiers:
                identifiers.pop(currentIdentifier)
            endLabels.pop()
            return False, PALMAT
    elif lbnfLabel in ["basicStatementExit", "basicStatementRepeat"]:
        loopScope = findEnclosingLoop(PALMAT, currentScope)
        if 'labelExitRepeat' in substate:
            label = substate.pop('labelExitRepeat')
            # We have to find the ancestor scope in which this label is
            # defined.
            i = currentScope["self"]
            while i != None and label not in PALMAT["scopes"][i]["identifiers"]:
                if PALMAT["scopes"][i]["type"] in \
                        ["program", "function", "procedure"]:
                    i = None
                    break
                i = PALMAT["scopes"][i]["parent"]
            if i == None:
                print("\tLabel %s not found.")
                endLabels.pop()
                return False, PALMAT
            labelScope = PALMAT["scopes"][i]
            # Now we've found the scope containing the label, but that's not
            # the scope we need.  We need the DO-loop to which the label refers,
            # which is a child of  labelScope.  In fact, to find it, we need
            # to find the instruction in labelScope at which the label is 
            # defined, and the goto to the DO-loop should follow essentially
            # thereafter.
            labelAttributes = labelScope["identifiers"][label]["label"]
            jumpDoInstruction = PALMAT["scopes"][labelAttributes[0]]\
                                            ["instructions"][labelAttributes[1]]
            # This is the instruction that jumps to the scope containing the
            # DO-loop associated with the label.  It should be of the form
            # {'goto': (index, entryLabel), ...}, and we can use that to find
            # the scope actually containing the DO-loop.
            dummy = jumpDoInstruction["goto"]
            doScopeIndex = \
                PALMAT["scopes"][dummy[0]]["identifiers"][dummy[1]]["label"][0]
            doScope = PALMAT["scopes"][doScopeIndex]
            # At last we have the scope in which the enclosing DO-loop resides.
            # What we have to do now depends on what type of loop it is.
            if lbnfLabel == "basicStatementExit":
                jumpToTarget(PALMAT, source, currentScope["self"], \
                             doScopeIndex, "ux", "goto", False, doScopeIndex)
            elif doScope["type"] == "do for discrete":
                appendInstruction(currentScope["instructions"], \
                                  {'returnoffset': doScopeIndex}, source)
            elif doScope["type"] == "do for":
                jumpToTarget(PALMAT, source, currentScope["self"], \
                             doScopeIndex, "up", "goto")
            elif doScope["type"] in ["do while", "do until"]:
                jumpToTarget(PALMAT, source, currentScope["self"], \
                             doScopeIndex, "ue", "goto", False, dummy[0])
            else:
                print("\tLabel for REPEAT/EXIT not attched to a loop.")
                endLabels.pop()
                return False, PALMAT
        else:
            xx = None
            if loopScope == None:
                print("\tNo enclosing loop found for EXIT.")
                endLabels.pop()
                return False, PALMAT
            if lbnfLabel == "basicStatementExit":
                xx = "ux"
            # Below here is REPEAT
            elif loopScope['type'] == "do for discrete":
                appendInstruction(currentScope["instructions"], \
                                  {"returnoffset": -1}, source)
            elif loopScope['type'] == "do for":
                xx = "up"
            else:
                xx = "ue"
            if xx != None:
                jumpToTarget(PALMAT, source, currentScope["self"], \
                    loopScope["self"], xx, "goto")

    #----------------------------------------------------------------------
    # Decide if we need to stick an automatically-generated label at the
    # end of this grammar component or not.
    #if lbnfLabel == "basicStatementDo":
    #    debug(PALMAT, state, "Flush = %s" % str(expressionFlush))
    instructions = currentScope["instructions"]
    identifiers = currentScope["identifiers"]
    if "recycle" in endLabels[-1]:
        if len(expressionFlush) > 0:
            # This is a buffered set of PALMAT instructions for an UNTIL
            # conditional expression
            instructions.extend(expressionFlush)
            jumpToTarget(PALMAT, source, currentIndex, currentIndex, \
                         "ux", "iftrue")
        if currentScope["type"] == "do for":
            jumpToTarget(PALMAT, source, currentIndex, currentIndex, \
                         "up", "goto")
        elif currentScope["type"] == "do for discrete":
            appendInstruction(currentScope["instructions"], \
                              {'returnoffset': -1}, source)
        else:
            # We've got a little problem here, in that the label we want to
            # recycle to at the end of a DO WHILE or DO UNTIL is the same
            # label at which the block is entered from elsewhere.  Hence
            # the label doesn't appear in the identifier list of the current
            # block.  We have to find it.
            identifier = "^ug_%d^" % currentIndex
            si, attributes = findIdentifier(identifier, PALMAT, currentIndex)
            jumpToTarget(PALMAT, source, currentIndex, currentIndex, \
                         "ug", "goto", False, si)
    if endLabels[-1]["used"]:
        if lbnfLabel == "true_part":
            if createTarget(PALMAT, source, currentIndex, currentIndex, "ub") \
                    == None:
                return False, PALMAT
        else:
            if createTarget(PALMAT, source, currentIndex, currentIndex, "ux") \
                    == None:
                return False, PALMAT
    endLabels.pop()
    
    # If this is this a DO ... END block, we need to insert a PALMAT
    # goto instruction at the end of the block back to the original 
    # position in the parent scope.
    if isDo:
        if currentScope["type"] == "do case":
            currentScope["identifiers"]["^dc_exit^"] = {
                "label": [currentScope["self"], len(currentScope["instructions"])]}
            appendInstruction(currentScope["instructions"], \
                              {'noop': True, 'label': '^dc_exit^'}, source)
        exitDo(PALMAT, source, currentScope["self"], preservedScopeIndex)
        state["scopeIndex"] = preservedScopeIndex
        
    return True, PALMAT
