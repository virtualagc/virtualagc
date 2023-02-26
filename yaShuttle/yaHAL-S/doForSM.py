#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       doForSM.py
Purpose:        Part of the code-generation system for the "modern" HAL/S
                compiler yaHAL-S-FC.py+modernHAL-S-FC.c.  Specifically, this
                is a state machine for generation code for DO FOR blocks.
History:        2023-01-10 RSB  Adapted from expressionSM.py
"""

from palmatAux import createTarget, jumpToTarget, createVariable, \
    debug, findIdentifier, astToLbnf, appendInstruction
import p_Functions

'''
Note that the first call to doForSM() is *after* its generic
DO ... END block has been created and made current.
Return True on success, False on failure.  The stage argument is 0 when
called upon starting processing of an lbnfLabel, 2 after otherwise finishing
the processing of an lbnfLabel, or 1 when called with the lbnfLabel being 
a string literal. The output is a compilation of DO FOR ... END to PALMAT 
instructions.  Those instructions are appended for the PALMAT
instruction list for the current scope.
'''
def doForSM(stage, ast, PALMAT, state, trace, depth, trace4=False):
    
    lbnfLabel, source = astToLbnf(ast)
    
    def closeout():
        '''
        Note that the DO FOR block was created, by makeDoEnd() in 
        generatePALMAT(), by a `noop` instruction with a label "up_%d",
        intended to be used as the recycling point for looping.  This happens
        to be the 2nd instruction in the current block.  So we can just
        pull that label off of the 2nd instruction and create another `noop`
        with that label right here.  Well, and we also have to adjust the
        identifier table.  Note also that since closeout() may
        be called several times in succession as the BNF component tree
        collapses at the end, we only have to do that closeout processing
        once.
        '''
        if 'label' in instructions[1]:
            label = instructions[1]['label']
            offset = len(instructions)
            appendInstruction(instructions, {
                'noop': True, 
                'label': label
            }, source)
            instructions[1].pop('label')
            currentScope["identifiers"][label]["label"][1] = offset
        else:
            createTarget(PALMAT, source, scopeNumber, scopeNumber, "up")
        # Update the loop variable.
        si, attributes = \
            findIdentifier("^"+stateMachine['forEnd']+"^", PALMAT, scopeNumber)
        appendInstruction(instructions, \
                          {'fetch': (si, stateMachine['forEnd'])}, source)
        si, attributes = \
            findIdentifier("^"+stateMachine['forBY']+"^", PALMAT, scopeNumber)
        appendInstruction(instructions, \
                          {'fetch': (si, stateMachine['forBY'])}, source)
        si, attributes = findIdentifier("^"+stateMachine['forKey']+"^", \
                                        PALMAT, scopeNumber, True)
        appendInstruction(instructions, \
                          {'+><': (si, stateMachine['forKey'])}, source)

        jumpToTarget(PALMAT, source, scopeNumber, scopeNumber, "ux", 'iftrue')
        #debug(PALMAT, state, "Pauses: %s" % str(stateMachine['pauses']))
        state.pop("stateMachine")
    
    stateMachine = state["stateMachine"]
    scopeNumber = state["scopeIndex"]
    currentScope = PALMAT["scopes"][scopeNumber]
    instructions = currentScope["instructions"]
    
    if lbnfLabel == "iteration_controlToBy":
        stateMachine["hasBY"] = True
        #debug(PALMAT, state, "hasBY")
    elif lbnfLabel == "doGroupHeadForWhile":
        stateMachine["hasWHILE"] = True
        #debug(PALMAT, state, "hasWHILE")
    elif lbnfLabel == "doGroupHeadForUntil":
        stateMachine["hasUNTIL"] = True
        #debug(PALMAT, state, "hasUNTIL")
    
    try:
        forKey = stateMachine["forKey"]
    except:
        forKey = None
    try:
        internalState = stateMachine["internalState"]
    except:
        internalState = "start"
    owningLabel = stateMachine["owner"]
    if stage == 0 and lbnfLabel == owningLabel:
        # First time called, must initialize the state machine.
        internalState = "start"
        p_Functions.substate["isFOR"] = True
        return True
    elif stage == 1 and lbnfLabel[:1] == "^" and lbnfLabel[-1:] == "^":
        # Receiving strings (literals or identifier names)
        sp = lbnfLabel[1:-1] # Get rid of carat quotes.
        
        if internalState == "waitForKey":
            stateMachine["forKey"] = sp
            #debug(PALMAT, state, "Loop index is " + sp)
            internalState = "waitForStartExpression"
            
    elif stage == 2:
        if lbnfLabel == "for_listDiscrete":
            currentScope["type"] = "do for discrete"
            appendInstruction(instructions, \
                              {'goto': (currentScope["parent"], 
                                        "^ur_%d^" % scopeNumber)}, source)
            currentScope["identifiers"]["^df_b^"] = \
                {'label': [scopeNumber, len(instructions)] }
            appendInstruction(instructions, \
                              {'noop': True, 'label': "^df_b^"}, source)
        elif lbnfLabel == "iteration_body":
            # Come here after each iteration of a discrete FOR-LOOP completes.
            si, attributes = \
                findIdentifier("^" + forKey + "^", PALMAT, scopeNumber)
            appendInstruction(instructions, {"storepop": (si, forKey)}, \
                              source)
            appendInstruction(instructions, {"calloffset": "^df_b^"}, source)
        if "completed" in stateMachine:
            stateMachine.pop("completed")
            if internalState == "waitForEndExpression" and \
                    currentScope["type"] == "do for":
                '''
                There are two cases here.  It may be that the expression 
                state machine has been used either once or twice since our 
                last doFor state-machine processing.  That's because the 
                grammar has no components intermediate between the two 
                expressions Z and T in 
                                DO FOR X=Y TO Z BY T.
                However, our stateMachine object has a key in it called 
                'pauses' that's a list of the lengths of the PALMAT 
                instruction queue at the points when the expression state
                machine was started.  Thus if stateMachine['key'] has only one
                entry then this is a DO FOR X=Y TO Z;, while if it has two
                entries then it's a DO FOR X=Y TO Z BY T.  Moreover,
                stateMachine['pauses'][1] tells us exactly where T appears in
                the instruction queue, so that we can insert extra
                instructions between Z and T.  
                '''
                pauses = stateMachine["pauses"]
                if len(pauses) == 2:
                    '''
                    This is the FOR TO BY case.
                    We have to insert the instructions for saving the 
                    ending value in between Z and T.  The trick is to do
                    it without creating a new list, to avoid the bookkeeping
                    effort of syncing changes in instructions to 
                    currentScope["instructions"].
                    '''
                    finalExpression = instructions[pauses[1]:]
                    del instructions[pauses[1]:]
                    id1 = createVariable(currentScope, "ud", {
                        "scalar": True,
                        "double": True 
                        })
                    appendInstruction(instructions, \
                                      {"storepop": (scopeNumber, id1)}, source)
                    instructions.extend(finalExpression)
                    id2 = createVariable(currentScope, "ud", {
                        "scalar": True,
                        "double": True 
                        })
                    appendInstruction(instructions, \
                                      {"store": (scopeNumber, id2)}, source)
                else: 
                    # This is the FOR TO (no BY) case.
                    id1 = createVariable(currentScope, "ud", {
                        "scalar": True,
                        "double": True 
                        })
                    appendInstruction(instructions, \
                                      {"storepop": (scopeNumber, id1)}, source)
                    id2 = createVariable(currentScope, "ud", {
                        "integer": True, "constant": 1
                        })
                    appendInstruction(instructions, \
                        {"fetch": (scopeNumber, id2) }, source)
                siForKey, attributesForKey = \
                    findIdentifier("^" + stateMachine["forKey"] + "^", 
                                   PALMAT, scopeNumber, True)
                appendInstruction(instructions, \
                                {"fetch": (siForKey, stateMachine["forKey"])},\
                                source)
                appendInstruction(instructions, {"operator": "-" }, source)
                appendInstruction(instructions, \
                            {"storepop": (siForKey, stateMachine["forKey"])}, \
                            source)
                stateMachine["forEnd"] = id1
                #debug(PALMAT, state, "Ending key stored at " + id1)
                stateMachine["forBY"] = id2
                #debug(PALMAT, state, "Key increment stored as constant at "\
                #                         + id2)
                closeout()
    elif stage == 0:
        if internalState == "start":
            # Waiting for the action to begin!
            if lbnfLabel in  ["for_list", "for_listDiscrete"]:
                internalState = "waitForKey"
        elif internalState == "waitForStartExpression":
            if "completed" in stateMachine:
                stateMachine.pop("completed")
                '''
                At this point, the name of the iteration key (such as I) should
                be safely in stateMachine["forKey"] and expression that must be
                evaluated for the initial setting of the key should have been
                stuck onto the PALMAT instruction queue.  We can thus perform
                the initial assignment of the value to the key, and jump to 
                the guts of the DO FOR block.
                '''
                if currentScope["type"] == "do for":
                    si, attributes = \
                        findIdentifier("^" + forKey + "^", PALMAT, scopeNumber)
                    appendInstruction(instructions, {"storepop": (si, forKey)}, \
                                      source)
                internalState = "waitForEndExpression"
                stateMachine["pauses"] = []
    stateMachine["internalState"] = internalState

    return True
        
    
         