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

import json
import p_Functions
substate = p_Functions.substate
from palmatAux import *
from executePALMAT import hround
from expressionSM import expressionSM
from doForSM import doForSM

def traceIt(state, lbnfLabel, beforeAfter="before", trace=True, depth=0):
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
                   trace=False, endLabels=[], depth=-1):
    depth += 1
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
            makeDoEnd(PALMAT, currentScope, scopeType)
    
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
    expressionComponents = ["expression", "ifClauseBitExp", "relational_exp", 
                         "bitExpFactor", "write_arg", "read_arg", "char_spec",
                         "arithExpTerm", "arithExpArithExpPlusTerm",
                         "arithExpArithExpMinusTerm", "arithMinusTerm"]
    doForComponents = ["doGroupHeadFor", "doGroupHeadForWhile", 
                          "doGroupHeadForUntil"]
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
        stateMachine["function"](0, lbnfLabel, PALMAT, state, trace, depth)

    #--------------------------------------------------------------------------
    # Main generation of PALMAT for the statement, sans setup and cleanup.
    traceIt(state, lbnfLabel, "before", trace, depth)
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
        traceIt(state, lbnfLabel, "after", trace, depth)
        if not success:
            endLabels.pop()
            return False, PALMAT
    for component in ast["components"]:
        if isinstance(component, str):
            if component[:1] == "^":
                traceIt(newState, lbnfLabel, "before", trace, depth)
                if "stateMachine" in newState:
                    state["stateMachine"]["function"](1, component, PALMAT, \
                                                      newState, trace, depth)
                success = p_Functions.stringLiteral(PALMAT, newState, component)
                if "stateMachine" in state and "stateMachine" not in newState:
                    state.pop("stateMachine")
                traceIt(newState, lbnfLabel, "after", trace, depth)
            else:
                success, PALMAT = generatePALMAT( \
                    { "lbnfLabel": component, "components" : [] }, \
                    PALMAT, newState, trace, endLabels, depth )
                if "stateMachine" in state and "stateMachine" not in newState:
                    traceIt(newState, lbnfLabel, \
                            "ending state machine \"%s\"" % \
                              state["stateMachine"]["owner"], trace, depth)
                    state.pop("stateMachine")
            if not success:
                endLabels.pop()
                return False, PALMAT
        else:
            success, PALMAT = generatePALMAT(component, PALMAT, \
                                             newState, trace, endLabels, depth)
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
        state["stateMachine"]["function"](2, lbnfLabel, PALMAT, \
                                          state, trace, depth)
        if "stateMachine" not in state:
            debug(PALMAT, state, "ending SM \"%s\"" % lbnfLabel)
            traceIt(state, lbnfLabel, "ending SM \"%s\"" % lbnfLabel, \
                    trace, depth)
            if parentStateMachine != None:
                debug(PALMAT, state, "Restoring SM %s, %s" % \
                      (parentStateMachine["owner"], 
                       parentStateMachine["internalState"]))
                parentStateMachine["completed"] = lbnfLabel
                state["stateMachine"] = parentStateMachine

    lbnfLabelPatterns = {
            "relational_exp": ["ifThenElseStatement", "ifStatement"], 
            "ifClauseBitExp": ["ifThenElseStatement", "ifStatement"], 
            "while_clause": ["basicStatementDo"]
        }
    currentIndex = currentScope["self"]
    if lbnfLabel in lbnfLabelPatterns:
        ancestorLabels = lbnfLabelPatterns[lbnfLabel]
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
                        jumpToTarget(PALMAT, currentIndex, currentIndex, \
                                     "uf", "iffalse")
                    elif not isUntil:
                        jumpToTarget(PALMAT, currentIndex, currentIndex, \
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
    elif lbnfLabel == "declare_group" and \
            currentScope["type"] in ["function", "procedure"]:
        if currentScope["type"] == "procedure":
            allDeclaredAssigns(currentScope)
        declared = allDeclaredParameters(currentScope)
        parameters = currentScope["attributes"]["parameters"]
        if len(declared) == len(parameters) and \
                "alreadyPopped" not in currentScope:
            currentScope["alreadyPopped"] = True
            instructions = currentScope["instructions"]
            for parameter in parameters:
                identifier = declared[parameter][1:-1]
                instructions.append({'storeupop': identifier})
    elif lbnfLabel == "basicStatementCall":
        if "callAssignments" in substate["commonAttributes"]:
            assignments = substate["commonAttributes"]["callAssignments"]
            currentScope["instructions"]\
                        .append({'call': substate["currentIdentifier"][1:-1],
                                 'assignments': assignments})
        else:
            currentScope["instructions"]\
                        .append({'call': substate["currentIdentifier"][1:-1]})
    elif lbnfLabel == "basicStatementReturn":
        # We need to find the most-narrow context that's a FUNCTION or 
        # PROCEDURE.
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
            i = dummy["parent"]
        if stackPos == 0:
            print("RETURN without parent FUNCTION or PROCEDURE")
            endLabels.pop()
            return False, PALMAT
        currentScope["instructions"].append({'return': stackPos})
    elif lbnfLabel == "closing":
        instructions = currentScope["instructions"]
        if currentScope["type"] == "procedure" and \
                (len(instructions) == 0 or 'return' not in instructions[-1]):
            instructions.append({'return': 1})
        parentIndex = currentScope["parent"]
        state["scopeIndex"] = parentIndex
        currentScope = PALMAT["scopes"][parentIndex]
    elif lbnfLabel == "blockHeadFunction":
        identifierDict = \
          currentScope["identifiers"][substate["currentIdentifier"]]
        if isUnmarkedScalar(identifierDict):
            identifierDict["scalar"] = True
        childIndex = addScope(PALMAT, currentScope["self"], "function")
        state["scopeIndex"] = childIndex
        currentScope = PALMAT["scopes"][childIndex]
        currentScope["name"] = substate["currentIdentifier"]
        currentScope["attributes"] = identifierDict
    elif lbnfLabel == "blockHeadProcedure":
        identifierDict = \
          currentScope["identifiers"][substate["currentIdentifier"]]
        childIndex = addScope(PALMAT, currentScope["self"], "procedure")
        state["scopeIndex"] = childIndex
        currentScope = PALMAT["scopes"][childIndex]
        currentScope["name"] = substate["currentIdentifier"]
        currentScope["attributes"] = identifierDict
    elif lbnfLabel == "true_part":
        p_Functions.expressionToInstructions( \
            substate["expression"], currentScope["instructions"])
        endLabels[-2]["used"] = True
        jumpToTarget(PALMAT, currentIndex, currentIndex, "ux", "goto")
        if createTarget(PALMAT, currentIndex, currentIndex, "uf") == None:
            return False, PALMAT
    elif lbnfLabel == "assignment":
        instructions = currentScope["instructions"]
        p_Functions.expressionToInstructions( \
            substate["expression"], instructions)
        base = "store"
        identifier = substate["lhs"][-1]
        attributes = findIdentifier("^"+identifier+"^", PALMAT, currentIndex)
        if attributes == None:
            print("Assignment variable %s not accessible." % identifier[1:-1])
            endLabels.pop()
            return False, PALMAT
        #print("*", identifier, currentIndex, attributes)
        #if "assignment" in attributes:
        base += "u"
        if len(substate["lhs"]) == 1:
            instructions.append({ base + "pop": substate["lhs"][-1] })
        else:
            instructions.append({ base: substate["lhs"][-1] })
    elif lbnfLabel == "basicStatementWritePhrase":
        instructions = currentScope["instructions"]
        p_Functions.expressionToInstructions( \
            substate["expression"], instructions)
        instructions.append({ "write": substate["LUN"] })
    elif lbnfLabel == "declare_statement":
        markUnmarkedScalars(currentScope["identifiers"])
    elif lbnfLabel == "repeated_constant":
        '''
        We get to here after an INITIAL(...) or CONSTANT(...)
        has been fully processed to the extent of preparing
        substate["expression"] for computing the value in 
        parenthesis, but without having performed that computation
        yet, leaving a bogus "initial" or "constant" attribute.
        We now have to perform the actual computation, if possible,
        and correct the bogus constant.  Since DECLARE statements
        always come at the beginnings of blocks, prior to any 
        executable code, we don't have to worry about preserving
        any existing PALMAT for the scope.
        '''
        identifiers = currentScope["identifiers"]
        instructions = currentScope["instructions"]
        currentIdentifier = substate["currentIdentifier"]
        '''
        Note that the expression state machine should have left
        a single value on the instruction queue if the expression
        was computable at compile time.
        '''
        value = popInstruction(instructions)
        if value == None or lenInstructions(instructions) != 0:
            print("Computation of INITIAL(...) or CONSTANT(...) failed:", 
                  value, instructions)
            if currentIdentifier in identifiers:
                identifiers.pop(currentIdentifier)
            endLabels.pop()
            return False, PALMAT
        instructions.clear()
        if "number" in value:
            try:
                value = float(value["number"]);
            except:
                print("In INITIAL or CONSTANT, couldn't convert to SCALAR:", \
                      value)
                return False, PALMAT
        elif "boolean" in value:
            value = value["boolean"]
        elif "string" in value:
            value = value["string"]
        
        if currentIdentifier != "":
            identifierDict = identifiers[currentIdentifier]
        else:
            identifierDict = substate["commonAttributes"]
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
        elif "constant" in identifierDict and \
                identifierDict["constant"] == "^?^":
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
            print("Datatype mismatch in INITIAL or CONSTANT:", value, \
                  currentIdentifier)
            identifiers.pop(currentIdentifier)
            endLabels.pop()
            return False, PALMAT
        identifierDict[key] = value
        if key == "initial":
            identifierDict["value"] = value
    elif lbnfLabel == "char_spec":
        # For DECLARE C CHARACTER(...);
        identifiers = currentScope["identifiers"]
        instructions = currentScope["instructions"]
        currentIdentifier = substate["currentIdentifier"]
        # Note that the expression state machine should have left
        # a single number on the instruction queue if the expression
        # was computable at compile time.
        value = popInstruction(instructions)
        try:
            maxLen = round(float(value["number"]));
            if currentIdentifier != "":
                identifierDict = identifiers[currentIdentifier]
            else:
                identifierDict = substate["commonAttributes"]
            identifierDict["character"] = maxLen
        except:
            print("Computation of CHARACTER(...) failed:", value, instructions)
            #print(instructions)
            identifiers.pop(currentIdentifier)
            endLabels.pop()
            return False, PALMAT
    elif lbnfLabel in ["basicStatementExit", "basicStatementRepeat"]:
        loopScope = findEnclosingLoop(PALMAT, currentScope)
        if 'labelExitRepeat' in substate:
            currentScope["instructions"].append({
                'goto': substate['labelExitRepeat']})
            substate.pop('labelExitRepeat')
        else:
            if loopScope == None:
                print("No enclosing loop found for EXIT.")
                endLabels.pop()
                return False, PALMAT
            elif lbnfLabel == "basicStatementExit":
                xx = "ux"
            elif loopScope['type'] == "do for":
                xx = "up"
            else:
                xx = "ue"
            jumpToTarget(PALMAT, currentScope["self"], \
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
            # This is a buffered set of PALMAT instructions for a an UNTIL
            # conditional expression
            instructions.extend(expressionFlush)
            jumpToTarget(PALMAT, currentIndex, currentIndex, "ux", "iftrue")
        if currentScope["type"] == "do for":
            jumpToTarget(PALMAT, currentIndex, currentIndex, "up", "goto")
        else:
            jumpToTarget(PALMAT, currentIndex, currentIndex, "ue", "goto")
    if endLabels[-1]["used"]:
        if lbnfLabel == "true_part":
            if createTarget(PALMAT, currentIndex, currentIndex, "ub") == None:
                return False, PALMAT
        else:
            if createTarget(PALMAT, currentIndex, currentIndex, "ux") == None:
                return False, PALMAT
    endLabels.pop()
    
    # If this is this a DO ... END block, we need to insert a PALMAT
    # goto instruction at the end of the block back to the original 
    # position in the parent scope.
    if isDo:
        exitDo(PALMAT, currentScope["self"], preservedScopeIndex)
        state["scopeIndex"] = preservedScopeIndex
        
    return True, PALMAT
