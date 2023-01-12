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
from palmatAux import *
from executePALMAT import executePALMAT, hround
from expressionSM import expressionSM
from doForSM import doForSM

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
    endLabel = "^ue_%d^" % getUniqueCount()
    endLabels.append({"lbnfLabel": lbnfLabel, 
                      "endLabel": endLabel, 
                      "used": False})

    # Is this a DO ... END block?  If it is, then we have to do several things:
    # create a new child scope and make it current, and add a goto PALMAT 
    # instruction from the existing current scope to the new scope.  
    # IF statements are treated like DO statements in this regard, because
    # they cause me lots of trouble (with nesting them) otherwise.
    isDo = lbnfLabel in ["basicStatementDo", "otherStatementIf"]
    if isDo:
        dummyTargets = []
        if lbnfLabel == "basicStatementDo":
            # Alas, the "up" target is needed only for DO FOR and DO UNTIL,
            # but we don't know yet which flavor of DO we have, so we have to 
            # make do with what we know.  (Yes, the pun was intended.)
            dummyTargets = ["up"]
        state["scopeIndex"], currentScope = \
            makeDoEnd(PALMAT, currentScope, dummyTargets)
    
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
                                     "pauses": [] }
            if "lbnfLabel" in ["char_spec"]:
                state["stateMachine"]["compiledExpression"] = []
        elif lbnfLabel in doForComponents:
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
        stateMachine["function"](0, lbnfLabel, PALMAT, state, trace)
             
    # Main generation of PALMAT for the statement, sans setup and cleanup.
    if trace:
        print("TRACE: component =", lbnfLabel)
        print("       state (before) =", state)
        print("       substate =", p_Functions.substate)
    if lbnfLabel in p_Functions.objects:
        func = p_Functions.objects[lbnfLabel]
        success, newState = func(PALMAT, state)
        if "stateMachine" in state:
            # We want to make sure that newState's state machine
            # is the same object as state's, and not merely
            # a clone of it.
            newState["stateMachine"] = state["stateMachine"]
        if trace:
            if "stateMachine" in state:
                print("       state (after) =", state["stateMachine"])
            print("       substate (after) =", p_Functions.substate)
        if not success:
            endLabels.pop()
            return False, PALMAT
    for component in ast["components"]:
        #if lbnfLabel == "ifStatement":
        #    print("*", component)
        if isinstance(component, str):
            if component[:1] == "^":
                if trace:
                    print("TRACE: component =", component)
                    print("       state (before) =", newState)
                    print("       substate =", p_Functions.substate)
                if "stateMachine" in newState:
                    state["stateMachine"]["function"](1, component, PALMAT, \
                                                      newState, trace)
                success = p_Functions.stringLiteral(PALMAT, newState, component)
                if "stateMachine" in state and "stateMachine" not in newState:
                    state.pop("stateMachine")
                if trace:
                    if "stateMachine" in state:
                        print("       state (after) =", state["stateMachine"])
                    print("      ", p_Functions.substate)
            else:
                success, PALMAT = generatePALMAT( \
                    { "lbnfLabel": component, "components" : [] }, \
                    PALMAT, newState, trace, endLabels )
                if "stateMachine" in state and "stateMachine" not in newState:
                    state.pop("stateMachine")
            if not success:
                endLabels.pop()
                return False, PALMAT
        else:
            success, PALMAT = generatePALMAT(component, PALMAT, \
                                             newState, trace, endLabels)
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
        state["stateMachine"]["function"](2, lbnfLabel, PALMAT, state, trace)
        if "stateMachine" not in state:
            debug(PALMAT, state, "Ending SM %s" % lbnfLabel)
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
    if lbnfLabel in lbnfLabelPatterns:
        ancestorLabels = lbnfLabelPatterns[lbnfLabel]
        for ancestor in ancestorLabels:
            if ancestor not in state["history"]:
                continue
            p_Functions.expressionToInstructions( \
                p_Functions.substate["expression"], \
                currentScope["instructions"])
            for entry in reversed(endLabels):
                if entry["lbnfLabel"] == ancestor:
                    isUntil = "isUntil" in p_Functions.substate
                    entry["used"] = True
                    if isUntil:
                        palmatOpcode = "iftrue"
                    else:
                        palmatOpcode = "iffalse"
                    #if lbnfLabel == "ifClauseBitExp":
                    #    jumpToTarget(currentScope, "ub", palmatOpcode)
                    #el
                    if ancestor == "ifThenElseStatement":
                        jumpToTarget(currentScope, "uf", palmatOpcode)
                    else:
                        jumpToTarget(currentScope, "ux", palmatOpcode)
                    if lbnfLabel == "while_clause":
                        parent = currentScope["parent"]
                        parentScope = PALMAT["scopes"][parent]
                        if isUntil and 'isFOR' not in p_Functions.substate:
                            newLabel = createTarget(currentScope, "ub")
                            if newLabel == None:
                                return False, PALMAT
                            currentScope["instructions"][0].pop('noop')
                            currentScope["instructions"][0]['goto'] = newLabel
                            p_Functions.substate.pop("isUntil")
                    break
            break
    # Below are various other patterns not covered by lbnfLabelPatterns above.
    # The lbnfLabel of the relevant component must not be the same as any key 
    # in lbnfLabelPatterns.
    elif lbnfLabel == "true_part":
        p_Functions.expressionToInstructions( \
            p_Functions.substate["expression"], currentScope["instructions"])
        endLabels[-2]["used"] = True
        jumpToTarget(currentScope, "ux", "goto")
        if createTarget(currentScope, "uf") == None:
            return False, PALMAT
    elif lbnfLabel == "assignment":
        instructions = currentScope["instructions"]
        p_Functions.expressionToInstructions( \
            p_Functions.substate["expression"], instructions)
        instructions.append({ "store": p_Functions.substate["lhs"][-1] })
        p_Functions.substate["lhs"].pop()
        if len(p_Functions.substate["lhs"]) == 0:
            instructions.append({ "pop": 1 })
    elif lbnfLabel == "basicStatementWritePhrase":
        instructions = currentScope["instructions"]
        p_Functions.expressionToInstructions( \
            p_Functions.substate["expression"], instructions)
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
        # Note that the expression state machine should have left
        # a single value on the instruction queue if the expression
        # was computable at compile time.
        queueSize = 0
        for ii in instructions:
            if 'debug' not in ii:
                queueSize += 1
                value = ii
        if queueSize != 1:
            print("Computation of INITIAL or CONSTANT failed:")
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
        currentIdentifier = p_Functions.substate["currentIdentifier"]
        # Note that the expression state machine should have left
        # a single number on the instruction queue if the expression
        # was computable at compile time.
        try:
            value = instructions.pop()
            maxLen = round(float(value["number"]));
            if currentIdentifier != "":
                identifierDict = identifiers[currentIdentifier]
            else:
                identifierDict = p_Functions.substate["commonAttributes"]
            identifierDict["character"] = maxLen
        except:
            print("Computation of INITIAL or CONSTANT failed:")
            print(instructions)
            identifiers.pop(currentIdentifier)
            endLabels.pop()
            return False, PALMAT
    
    #----------------------------------------------------------------------
    # Decide if we need to stick an automatically-generated label at the
    # end of this grammar component or not.
    instructions = currentScope["instructions"]
    identifiers = currentScope["identifiers"]
    if "recycle" in endLabels[-1]:
        jumpToTarget(currentScope, "up", "goto")
    if endLabels[-1]["used"]:
        if lbnfLabel == "true_part":
            if createTarget(currentScope, "ub") == None:
                return False, PALMAT
        else:
            if createTarget(currentScope, "ux") == None:
                return False, PALMAT
    endLabels.pop()
    
    # If this is this a DO ... END block, we need to insert a PALMAT
    # goto instruction at the end of the block back to the original 
    # position in the parent scope.
    if isDo:
        exitDo(PALMAT, currentScope)
        state["scopeIndex"] = preservedScopeIndex
        
    return True, PALMAT
