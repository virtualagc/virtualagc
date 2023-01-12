#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       expressionSM.py
Purpose:        Part of the code-generation system for the "modern" HAL/S
                compiler yaHAL-S-FC.py+modernHAL-S-FC.c.  Specifically, this
                is a state machine for generation code for BNF <EXPRESSION>
                components.
History:        2023-01-08 RSB  Created, hopefully for eventually replacing
                                the older, more-chaotic method. 
"""

from executePALMAT import executePALMAT
from palmatAux import findIdentifier, debug

# Return True on success, False on failure.  The stage argument is 0 when
# called upon starting processing of an lbnfLabel, 2 after otherwise finishing
# the processing of an lbnfLabel, or 1 when called with the lbnfLabel being 
# a string literal. The output is the expression as compiled to PALMAT 
# instructions.  By default, those instructions are appended for the PALMAT
# instruction list for the current scope; however, if the stateMachine has a
# key called "compiledExpression", then it goes there instead.  Note that
# since the stateMachine key is automatically popped from the state when the
# expression has finished compiling, the calling routine, PALMAT() from the
# PALMAT.py module, must have some provision for saving either the stateMachine
# or at least the "compiledExpression" field of the stateMachine before that
# final call to expressionSM is made.
def expressionSM(stage, lbnfLabel, PALMAT, state, trace):
    
    #debug(PALMAT, state, "SM expression %d %s" % (stage, lbnfLabel)) 
    
    stateMachine = state["stateMachine"]
    owningLabel = stateMachine["owner"]
    if stage == 0 and lbnfLabel == owningLabel:
        # First time called.
        stateMachine["internalState"] = "normal"
        stateMachine["expression"] = []
        # Don't return here.  Fall through, because sometimes we start the
        # machine with a component that's a subcomponent of an expression
        # rather than an expression component per se, and the lbnfLabel needs
        # more processing than ignoring it like I do right here.
    expression = stateMachine["expression"]
    internalState = stateMachine["internalState"]
    if stage == 1 and lbnfLabel[:1] == "^" and lbnfLabel[-1:] == "^":
        sp = lbnfLabel[1:-1]
        if internalState == "waitIdentifier":
            expression.append({ "fetch": sp })
            internalState = "normal"
        elif internalState == "waitNumber":
            expression.append({ "number": sp })
            internalState = "normal"
        elif internalState == "waitCharString":
            expression.append({ "string": sp[1:-1] })
            internalState = "normal"
    if stage == 2 and lbnfLabel == owningLabel:
        # Transfer the expression stack to the PALMAT instruction queue.
        # But if it's computable at compile-time, then we compute it down
        # to a single number.
        temporaryInstructions = []
        compileTimeComputable = True
        while len(expression) != 0:
            instruction = expression.pop()
            temporaryInstructions.append(instruction)
            if compileTimeComputable:
                if "fetch" in instruction:
                    identifier = instruction["fetch"]
                    attributes = findIdentifier("^" + identifier + "^", \
                                                PALMAT, state["scopeIndex"])
                    #print("*", attributes)
                    if attributes == None or "constant" not in attributes:
                        compileTimeComputable = False
                elif "function" in instruction and \
                        instruction["function"] in \
                            ["RANDOM", "RANDOMG", "DATE", "RUNTIME", 
                             "CLOCKTIME"]:
                    compileTimeComputable = False
        #state[expressions].append(temporaryInstructions)
        if compileTimeComputable:
            # Is computable at compile-time, so let's compute it and just
            # add the single computed element to the existing instructions.
            # We need to construct an entirely new PALMAT to hold the 
            # identifiers and instructions for that calculation.  It will
            # have just one scope.
            temporaryIdentifiers = {}
            for scope in PALMAT["scopes"]:
                temporaryIdentifiers.update(scope["identifiers"])
            temporaryScope = {
                "parent"        : None,
                "self"          : 0,
                "children"      : [ ],
                "identifiers"   : temporaryIdentifiers,
                "instructions"  : temporaryInstructions,
                "incomplete"    : [ ]
            }
            temporaryPALMAT = { "scopes": [temporaryScope] }
            computationStack = executePALMAT(temporaryPALMAT)
            if len(computationStack) == 1:
                value = computationStack[0]
                if isinstance(value, bool): # must come before (int,float).
                    temporaryInstructions.clear()
                    temporaryInstructions.append({"boolean": value})
                elif isinstance(value, (int, float)):
                    temporaryInstructions.clear()
                    temporaryInstructions.append({"number": str(value)})
                elif isinstance(value, str):
                    temporaryInstructions.clear()
                    temporaryInstructions.append({"string": value })
        if "compiledExpression" in stateMachine:
            instructions = stateMachine["compiledExpression"]
        else:
            instructions = PALMAT["scopes"][state["scopeIndex"]]["instructions"]
        instructions.extend(temporaryInstructions)
        state.pop("stateMachine")
    if stage == 0 and internalState == "normal":
        if lbnfLabel in ["abs", "ceiling", "div", "floor", "midval", "mod",
                         "odd", "remainder", "round", "sign", "signum", 
                         "truncate", "arccos", "arccosh", "arcsin", 
                         "arcsinh", "arctan2", "arctan", "arctanh", "cos", 
                         "cosh", "exp", "log", "sin", "sinh", "sqrt", "tan", 
                         "tanh", "abval", "det", "inverse", "trace", 
                         "transpose", "unit", "max", "min", "prod", "sum",
                         "xor", "index", "length", "ljust", "rjust", "trim",
                         "clocktime", "date", "errgrp", "errnum", "nextime", 
                         "prio", "random", "randomg", "runtime", "shl", 
                         "shr", "size"]:
            expression.append({ "function": lbnfLabel.upper()})
        if lbnfLabel in ["identifier", "char_id", "bit_id"]:
            internalState = "waitIdentifier"
        elif lbnfLabel in ["level", "number", "compound_number", "simple_number"]:
            internalState = "waitNumber"
        elif lbnfLabel == "char_string":
            internalState = "waitCharString"
        elif lbnfLabel == "arithExpArithExpPlusTerm":
            expression.append({ "operator": "+" })
        elif lbnfLabel == "arithExpArithExpMinusTerm":
            expression.append({ "operator": "-" })
        elif lbnfLabel == "arithMinusTerm":
            expression.append({ "operator": "U-" })
        elif lbnfLabel == "termDivide":
            expression.append({ "operator": "/" })
        elif lbnfLabel == "productMultiplication":
            expression.append({ "operator": "" })
        elif lbnfLabel == "factorExponentiation":
            expression.append({ "operator": "**" })
        elif lbnfLabel == "productDot":
            expression.append({ "operator": "." })
        elif lbnfLabel == "productCross":
            expression.append({ "operator": "*" })
        elif lbnfLabel == "charExpCat":
            expression.append({ "operator": "C||" })
        elif lbnfLabel == "bitConstTrue":
            expression.append({ "boolean": True })
        elif lbnfLabel == "bitConstFalse":
            expression.append({ "boolean": False })
        elif lbnfLabel == "NOT":
            expression.append({ "operator": "NOT" })
        elif lbnfLabel == "bitFactorAnd":
            expression.append({ "operator": "AND" })
        elif lbnfLabel == "bitExpOR":
            expression.append({ "operator": "OR" })
    stateMachine["internalState"] = internalState
    return True
        
    
         