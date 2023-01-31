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

from executePALMAT import executePALMAT, isBitArray
from palmatAux import debug, findIdentifier
from p_Functions import substate

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
def expressionSM(stage, lbnfLabel, PALMAT, state, trace, depth, \
                 traceCompileTime=False):
    
    #debug(PALMAT, state, "SM expression %d %s" % (stage, lbnfLabel)) 
    
    stateMachine = state["stateMachine"]
    if "radix" not in stateMachine:
        stateMachine["radix"] = 0
    # "foundPound" is just for debugging repetition factors.
    if "foundPound" not in stateMachine:
        stateMachine["foundPound"] = False
    if lbnfLabel == "repeated_constant":
        stateMachine["repeatedConstant"] = True
    #owningLabel = stateMachine["owner"]
    owningDepth = stateMachine["depth"]
    if stage == 0 and depth == owningDepth: #lbnfLabel == owningLabel:
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
            si, attributes = \
                    findIdentifier(lbnfLabel, PALMAT, state["scopeIndex"])
            if "readStatement" in stateMachine:
                expression.append({ "fetchp": (si, sp)})
            else:
                expression.append({ "fetch": (si, sp) })
            internalState = "normal"
        elif internalState == "waitNumber":
            expression.append({ "number": sp })
            internalState = "normal"
        elif internalState == "waitCharString":
            if stateMachine["radix"] != 0:
                expression.append({ 
                    "bitarray": "%d" % int(sp[1:-1], stateMachine["radix"])})
                stateMachine["radix"] = 0
            else:
                expression.append({ "string": sp[1:-1] })
            internalState = "normal"
        elif internalState == "waitFunctionName":
            si, attributes = \
                    findIdentifier(lbnfLabel, PALMAT, state["scopeIndex"])
            expression.append({ "call": (si, sp) })
            internalState = "normal"
    if stage == 2:
        if lbnfLabel == "subscript":
            expression.append({ 'sentinel': 'subscripts' })
        elif lbnfLabel == "basicStatementReadPhrase":
            if "readStatement" in stateMachine:
                stateMachine.pop("readStatement")
        elif lbnfLabel == "repeated_constantMark":
            expression.append({ "sentinel": "repeat"})
        elif lbnfLabel in ["prePrimaryRtlShaping"]:
            expression.append({ "sentinel": "shaping"})
        elif lbnfLabel in ["prePrimaryRtlShapingStar"]:
            expression.append({ "fill": True })
            expression.append({ "sentinel": "shaping"})
        elif lbnfLabel == "arithConv_integer":
            expression.append({ "shaping": "integer" })
        elif lbnfLabel == "arithConv_scalar":
            expression.append({ "shaping": "scalar" })
    #if stage == 2 and lbnfLabel == "repeated_constant":
    #    expression.append({ "condense": "end" })
    if stage == 2 and depth == owningDepth:
        # Transfer the expression stack to the PALMAT instruction queue.
        # But if it's computable at compile-time, then we compute it down
        # to a single number.
        temporaryInstructions = []
        compileTimeComputable = True
        state["finalExpression"] = list(reversed(expression))
        while len(expression) != 0:
            # Do NOT add breaks to exit this loop once compileTimeExecutable
            # is known!  It has to run to completion to set up 
            # temporaryInstructions properly.
            instruction = expression.pop()
            temporaryInstructions.append(instruction)
            if compileTimeComputable:
                if "fetchp" in instruction:
                    compileTimeComputable = False
                elif "fetch" in instruction or "unravel" in instruction:
                    if "fetch" in instruction:
                        si, identifier = instruction["fetch"]
                    else:
                        si, identifier = instruction["unravel"]
                    try:
                        attributes = PALMAT["scopes"][si]["identifiers"]\
                                                        ["^" + identifier + "^"]
                    except:
                        # I don't think this can happen, but if it does, then
                        # it's defitely not computable. 
                        attributes = None
                    if attributes == None or "constant" not in attributes:
                        compileTimeComputable = False
                elif "function" in instruction and \
                        instruction["function"] in \
                            ["RANDOM", "RANDOMG", "DATE", "RUNTIME", 
                             "CLOCKTIME"]:
                    compileTimeComputable = False
                elif "call" in instruction:
                    compileTimeComputable = False
        #state[expressions].append(temporaryInstructions)
        if compileTimeComputable:
            # Is computable at compile-time, so let's compute it and just
            # add the single computed element to the existing instructions.
            # We need to construct an entirely new PALMAT to hold the 
            # identifiers and instructions for that calculation.  It will
            # have just one scope, which is a flattened form of the existing
            # hierarchy of scopes.  Similarly, the temporary instructions for
            # computing the expression remain the same, except the PALMAT
            # `fetch` instructions used to fetch the values of constants have
            # to be fixed to reflect the flattened scopes.
            parentage = [state["scopeIndex"]]
            while True:
                dummyScope = PALMAT["scopes"][parentage[-1]]
                dummyParent = dummyScope["parent"]
                if dummyParent == None:
                    break
                parentage.append(dummyParent)
            temporaryIdentifiers = {}
            for i in reversed(parentage):
                temporaryIdentifiers.update(PALMAT["scopes"][i]["identifiers"])
            doctoredInstructions = []
            for instruction in temporaryInstructions:
                if "fetch" in instruction:
                    instruction["fetch"] = (0, instruction["fetch"][1])
                doctoredInstructions.append(instruction)
            #if True or stateMachine["foundPound"]:
            #    print("foundPound:", doctoredInstructions)
            temporaryScope = {
                "parent"        : None,
                "self"          : 0,
                "children"      : [ ],
                "identifiers"   : temporaryIdentifiers,
                "instructions"  : doctoredInstructions,
                "type"          : "compiler"
            }
            temporaryPALMAT = { "scopes": [temporaryScope] }
            computationStack = \
                executePALMAT(temporaryPALMAT, 0, 0, False, traceCompileTime, 8)
            if computationStack == None:
                print("\tAborting compile-time computation.")
                return False
            # We assume the computation has been successful, so now we replace
            # the contents of temporaryInstructions with newly-constructed
            # instructions based on the computation stack.
            temporaryInstructions.clear()
            for value in reversed(computationStack):
                if value == None:
                    temporaryInstructions.append({"empty": True})
                elif value == { "fill" }:
                    temporaryInstructions.append({"fill": True})
                elif isBitArray(value):
                    temporaryInstructions.append({"boolean": value})
                elif isinstance(value, (int, float)):
                    temporaryInstructions.append({"number": str(value)})
                elif isinstance(value, str):
                    temporaryInstructions.append({"string": value })
                elif isinstance(value, list) and len(value) > 0:
                    if isinstance(value[0], list):
                        temporaryInstructions.append({"matrix": value })
                    else:
                        temporaryInstructions.append({"vector": value }) 
                elif isinstance(value, tuple):
                    temporaryInstructions.append({"array": value })               
        if "compiledExpression" in stateMachine:
            instructions = stateMachine["compiledExpression"]
        else:
            instructions = PALMAT["scopes"][state["scopeIndex"]]["instructions"]
        if "relationalOperator" in stateMachine:
            temporaryInstructions.append(stateMachine["relationalOperator"])
        if "expressionFlush" in stateMachine:
            stateMachine["expressionFlush"].extend(temporaryInstructions)
            stateMachine["whereTo"] = "expressionFlush"
        else:
            stateMachine["whereTo"] = "instructions"
            instructions.extend(temporaryInstructions)
        stateMachine["instructionCount"] = len(temporaryInstructions)
        stateMachine["compileTimeComputable"] = compileTimeComputable
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
        #elif lbnfLabel == "repeated_constant":
        #    expression.append({ "condense": "start"})
        elif lbnfLabel == "read_arg":
            stateMachine["readStatement"] = True
        elif lbnfLabel[:9] == "ioControl":
            expression.append({ "iocontrol": lbnfLabel[9:].upper()})
        elif lbnfLabel in ["identifier", "char_id", "bit_id"]:
            internalState = "waitIdentifier"
        elif lbnfLabel in ["level", "number", "compound_number", 
                           "simple_number"]:
            internalState = "waitNumber"
        elif lbnfLabel == "radixBIN":
            stateMachine["radix"] = 2
        elif lbnfLabel == "radixDEC":
            stateMachine["radix"] = 10
        elif lbnfLabel == "radixHEX":
            stateMachine["radix"] = 16
        elif lbnfLabel == "radixOCT":
            stateMachine["radix"] = 8
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
            expression.append({ "boolean": [(1,1)] })
        elif lbnfLabel == "bitConstFalse":
            expression.append({ "boolean": [(0,1)] })
        elif lbnfLabel == "NOT":
            expression.append({ "operator": "NOT" })
        elif lbnfLabel == "bitFactorAnd":
            expression.append({ "operator": "AND" })
        elif lbnfLabel == "bitExpOR":
            expression.append({ "operator": "OR" })
        elif lbnfLabel == "repeat_head":
            expression.append({ "operator": "#"})
            stateMachine["foundPound"] = True
        elif lbnfLabel == "minorAttributeStar":
            expression.append({ "fill": True })
        elif lbnfLabel == "subscript":
            expression.append({ "operator": "subscripts"})
        elif lbnfLabel == "relationalOpEQ":
            stateMachine["relationalOperator"] = { "operator": "==" }
        elif lbnfLabel == "relationalOpNEQ":
            stateMachine["relationalOperator"] = { "operator": "!=" }
        elif lbnfLabel == "relationalOpLT":
            stateMachine["relationalOperator"] = { "operator": "<" }
        elif lbnfLabel == "relationalOpGT":
            stateMachine["relationalOperator"] = { "operator": ">" }
        elif lbnfLabel == "relationalOpLE":
            stateMachine["relationalOperator"] = { "operator": "<=" }
        elif lbnfLabel == "relationalOpGE":
            stateMachine["relationalOperator"] = { "operator": ">=" }
        elif lbnfLabel == "prePrimaryFunction":
            internalState = "waitFunctionName"
        elif lbnfLabel == "factorTranspose":
            expression.append({"function": "TRANSPOSE"})
            
    stateMachine["internalState"] = internalState
    return True
        
    
         