#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       templateSM.py
Purpose:        A template that can be used as a starting point for building
                state-machine modules (like expressionSM.py or doForSM.py) 
                for the generatePALMAT() function of PALMAT.py.
History:        2023-01-10 RSB  Adapted from expressionSM.py
"""

# Return True on success, False on failure.  The stage argument is 0 when
# called upon starting processing of an lbnfLabel, 2 after otherwise finishing
# the processing of an lbnfLabel, or 1 when called with the lbnfLabel being 
# a string literal. The output is a compilation of PALMAT instructions for 
# this component  Those instructions are appended for the PALMAT
# instruction list for the current scope.
def doForSM(stage, lbnfLabel, PALMAT, state, trace):
    stateMachine = state["stateMachine"]
    try:
        internalState = stateMachine["internalState"]
    except:
        internalState = "start"
    owningLabel = stateMachine["owner"]
    if stage == 0 and lbnfLabel == owningLabel:
        # First time called, must initialize the state machine.
        internalState = "start"
        
        # TBD
        
        return True
    elif stage == 1 and lbnfLabel[:1] == "^" and lbnfLabel[-1:] == "^":
        # Receiving strings (literals or identifier names)
        sp = lbnfLabel[1:-1] # Get rid of carat quotes.
        
        # TBD
        pass
    elif stage == 2 and lbnfLabel == owningLabel:
        # Last time through.  Perform any cleanup. And pop the state machine
        # from the state.
        
        # TBD
        
        state.pop("stateMachine")
    elif stage == 0 and internalState == "start":
        # Waiting for the action to begin!
        
        # TBD
        
        pass
    stateMachine["internalState"] = internalState
    return True
        
    
         