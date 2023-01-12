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

from palmatAux import createTarget, jumpToTarget, createVariable, debug
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
def doForSM(stage, lbnfLabel, PALMAT, state, trace):
    
    #debug(PALMAT, state, "SM doFor      %d %s" % (stage, lbnfLabel))
    
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
            instructions.append({
                'noop': True, 
                'label': label
            })
            instructions[1].pop('label')
            currentScope["identifiers"][label]["label"][1] = offset
        else:
            createTarget(PALMAT, currentScope["self"], \
                         currentScope["self"], "up")
        # Update the loop variable.
        '''
        instructions.append({'fetch': stateMachine['forKey']})
        instructions.append({'fetch': stateMachine['forBY']})
        instructions.append({'operator': "+"})
        instructions.append({'store': stateMachine['forKey']})
        # Past the limit?
        # TBD: We have to condition this test on whether BY is positive or
        # negative.  Temporarily I'll just assume it's positive
        instructions.append({'fetch': stateMachine['forEnd']})
        instructions.append({'operator': '<'})
        '''
        instructions.append({'fetch': stateMachine['forEnd']})
        instructions.append({'fetch': stateMachine['forBY']})
        instructions.append({'+><': stateMachine['forKey']})

        jumpToTarget(PALMAT, currentScope["self"], currentScope["self"], 
                     "ux", 'iftrue')
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
        if "completed" in stateMachine:
            stateMachine.pop("completed")
            if internalState == "waitForEndExpression":
                '''
                There are two cases here.  It may be that the expression 
                state machine has been used either once or twice since our 
                last doFor state-machine processing.  That's because the 
                grammar has no components intermediat between the two 
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
                    instructions.append({"store": id1})
                    instructions.append({"pop": 1})
                    instructions.extend(finalExpression)
                    id2 = createVariable(currentScope, "ud", {
                        "scalar": True,
                        "double": True 
                        })
                    instructions.append({"store": id2})
                else: 
                    # This is the FOR TO (no BY) case.
                    id1 = createVariable(currentScope, "ud", {
                        "scalar": True,
                        "double": True 
                        })
                    instructions.append({"store": id1})
                    instructions.append({"pop": 1})
                    id2 = createVariable(currentScope, "ud", {
                        "integer": True, "constant": 1
                        })
                    instructions.append({"fetch": id2 })
                instructions.append({"fetch": stateMachine["forKey"]})
                instructions.append({"operator": "-" })
                instructions.append({"store": stateMachine["forKey"]})
                instructions.append({"pop": 1})
                stateMachine["forEnd"] = id1
                #debug(PALMAT, state, "Ending key stored at " + id1)
                stateMachine["forBY"] = id2
                #debug(PALMAT, state, "Key increment stored as constant at "\
                #                         + id2)
                closeout()
    elif stage == 0:
        if internalState == "start":
            # Waiting for the action to begin!
            if lbnfLabel == "for_list":
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
                instructions.append({"store": forKey})
                instructions.append({"pop": 1})
                internalState = "waitForEndExpression"
                stateMachine["pauses"] = []
    stateMachine["internalState"] = internalState

    return True
        
    
         