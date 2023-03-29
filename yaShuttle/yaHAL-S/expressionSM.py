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
from palmatAux import debug, findIdentifier, hTRUE, hFALSE, isArrayQuick, \
    astToLbnf, appendInstruction, POUND
from p_Functions import substate

MAXBITSTRING = 256

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
def expressionSM(stage, ast, PALMAT, state, trace, depth, \
                 traceCompileTime=False):
    
    lbnfLabel, source = astToLbnf(ast)
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
            if len(substate["qual"]) > 0:
                si = substate["qualScope"]
                appendInstruction(expression, { "operator": "dotted"}, source, substate["qualInsert"])
            if "readStatement" in stateMachine:
                appendInstruction(expression, { "fetchp": (si, sp)}, source, substate["qualInsert"])
            else:
                appendInstruction(expression, { "fetch": (si, sp) }, source, substate["qualInsert"])
            substate["qual"] = []
            substate["qualInsert"] = -1
            internalState = "normal"
        elif internalState == "waitNumber":
            appendInstruction(expression, \
                              { "number": sp }, source)
            internalState = "normal"
        elif internalState == "waitCharString":
            if stateMachine["radix"] != 0:
                #appendInstruction(expression, \
                #    {"bitarray": "%d" % int(sp[1:-1], stateMachine["radix"])}, \
                #    source)
                appendInstruction(expression, \
                    {"boolean": [int(sp[1:-1], stateMachine["radix"]), 
                                 MAXBITSTRING, 'b']}, \
                    source)
                stateMachine["radix"] = 0
            else:
                appendInstruction(expression, { "string": sp[1:-1] }, source)
            internalState = "normal"
        elif internalState == "waitFunctionName":
            si, attributes = \
                    findIdentifier(lbnfLabel, PALMAT, state["scopeIndex"])
            appendInstruction(expression, { "call": (si, sp) }, source)
            internalState = "normal"
    if stage == 2:
        if lbnfLabel == "subscript":
            appendInstruction(expression, { 'sentinel': 'subscripts' }, source)
        elif lbnfLabel == "basicStatementReadPhrase":
            if "readStatement" in stateMachine:
                stateMachine.pop("readStatement")
        elif lbnfLabel == "repeated_constantMark":
            appendInstruction(expression, { "sentinel": "repeat"}, source)
        elif lbnfLabel in ["prePrimaryRtlShaping"]:
            appendInstruction(expression, { "sentinel": "shaping"}, source)
        elif lbnfLabel in ["prePrimaryRtlShapingStar"]:
            appendInstruction(expression, { "fill": True }, source)
            appendInstruction(expression, { "sentinel": "shaping"}, source)
        elif lbnfLabel == "subStartSemicolon":
            appendInstruction(expression, { "partition": True }, source)
        elif lbnfLabel == "minorAttributeStar":
            appendInstruction(expression, { "fill": True }, source)
        elif lbnfLabel == "structure_id":
            if len(substate["qual"]) == 1:
                substate["qualInsert"] = len(expression)
                appendInstruction(expression, {'sentinel': 'dotted'}, source)
            appendInstruction(expression, {'string': substate["qual"][-1]}, source, substate["qualInsert"])
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
            appendInstruction(temporaryInstructions, instruction, source)
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
                appendInstruction(doctoredInstructions, instruction, source)
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
                    appendInstruction(temporaryInstructions, \
                                      {"empty": True}, source)
                elif value == { "fill" }:
                    appendInstruction(temporaryInstructions, \
                                       {"fill": True}, source)
                elif isBitArray(value):
                    appendInstruction(temporaryInstructions, \
                                      {"boolean": value}, source)
                elif isinstance(value, (int, float)):
                    appendInstruction(temporaryInstructions, \
                                      {"number": str(value)}, source)
                elif isinstance(value, str):
                    appendInstruction(temporaryInstructions, \
                                      {"string": value }, source)
                elif isArrayQuick(value):
                    appendInstruction(temporaryInstructions, \
                                      {"array": value }, source)               
                elif isinstance(value, list) and len(value) > 0:
                    if isinstance(value[0], list):
                        appendInstruction(temporaryInstructions, \
                                          {"matrix": value }, source)
                    else:
                        appendInstruction(temporaryInstructions, \
                                          {"vector": value }, source) 
        if "compiledExpression" in stateMachine:
            instructions = stateMachine["compiledExpression"]
        else:
            instructions = PALMAT["scopes"][state["scopeIndex"]]["instructions"]
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
            appendInstruction(expression, { "function": lbnfLabel.upper()}, \
                              source)
        elif lbnfLabel == "prePrimaryTypeof":
            appendInstruction(expression, { "modern": "TYPEOF"}, source)
        elif lbnfLabel == "prePrimaryTypeofv":
            appendInstruction(expression, { "modern": "TYPEOFV"}, source)
        elif lbnfLabel == "bitPrimInitialized":
            appendInstruction(expression, { "modern": "INITIALIZED"}, source)
        elif lbnfLabel in ["prePrimaryRtlShapingHeadInteger", 
                           "prePrimaryRtlShapingHeadIntegerSubscript"]:
            appendInstruction(expression, { "shaping": "integer"}, source)
        elif lbnfLabel in ["prePrimaryRtlShapingHeadScalar",
                           "prePrimaryRtlShapingHeadScalarSubscript"]:
            appendInstruction(expression, { "shaping": "scalar"}, source)
        elif lbnfLabel in ["prePrimaryRtlShapingHeadVector",
                           "prePrimaryRtlShapingHeadVectorSubscript"]:
            appendInstruction(expression, { "shaping": "vector"}, source)
        elif lbnfLabel in ["prePrimaryRtlShapingHeadMatrix",
                           "prePrimaryRtlShapingHeadMatrixSubscript"]:
            appendInstruction(expression, { "shaping": "matrix"}, source)
        elif lbnfLabel == "subAt":
            appendInstruction(expression, { "shaping": "sliceAT"}, source)
        elif lbnfLabel == "subRunHeadTo":
            appendInstruction(expression, { "shaping": "sliceTO"}, source)
        elif lbnfLabel == "subStar":
            appendInstruction(expression, { "fill": True}, source)
        elif lbnfLabel == "read_arg":
            stateMachine["readStatement"] = True
        elif lbnfLabel[:9] == "ioControl":
            appendInstruction(expression, { "iocontrol": lbnfLabel[9:].upper()},\
                               source)
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
            appendInstruction(expression, { "operator": "+" }, source)
        elif lbnfLabel == "arithExpArithExpMinusTerm":
            appendInstruction(expression, { "operator": "-" }, source)
        elif lbnfLabel == "arithMinusTerm":
            appendInstruction(expression, { "operator": "U-" }, source)
        elif lbnfLabel == "termDivide":
            appendInstruction(expression, { "operator": "/" }, source)
        elif lbnfLabel == "productMultiplication":
            appendInstruction(expression, { "operator": "" }, source)
        elif lbnfLabel == "factorExponentiation":
            appendInstruction(expression, { "operator": "**" }, source)
        elif lbnfLabel == "productDot":
            appendInstruction(expression, { "operator": "." }, source)
        elif lbnfLabel == "productCross":
            appendInstruction(expression, { "operator": "*" }, source)
        elif lbnfLabel == "charExpCat":
            appendInstruction(expression, { "operator": "C||" }, source)
        elif lbnfLabel == "bitConstTrue":
            appendInstruction(expression, { "boolean": hTRUE }, source)
        elif lbnfLabel == "bitConstFalse":
            appendInstruction(expression, { "boolean": hFALSE }, source)
        elif lbnfLabel == "NOT":
            appendInstruction(expression, { "operator": "NOT" }, source)
        elif lbnfLabel == "bitFactorAnd":
            appendInstruction(expression, { "operator": "AND" }, source)
        elif lbnfLabel == "bitExpOR":
            appendInstruction(expression, { "operator": "OR" }, source)
        elif lbnfLabel == "repeat_head":
            appendInstruction(expression, { "operator": "#"}, source)
            stateMachine["foundPound"] = True
        #elif lbnfLabel == "minorAttributeStar":
        #    appendInstruction(expression, { "fill": True }, source)
        elif lbnfLabel == "subscript":
            appendInstruction(expression, { "operator": "subscripts"}, source)
        elif lbnfLabel == "pound_expression":
            appendInstruction(expression, { "number": POUND}, source)
        elif lbnfLabel == "pound_expressionPlusTerm":
            appendInstruction(expression, { "operator": "+"}, source)
        elif lbnfLabel == "pound_expressionMinusTerm":
            appendInstruction(expression, { "operator": "-"}, source)
        #elif lbnfLabel == "relationalOpEQ":
        #    stateMachine["relationalOperator"] = { "operator": "==" }
        #elif lbnfLabel == "relationalOpNEQ":
        #    stateMachine["relationalOperator"] = { "operator": "!=" }
        #elif lbnfLabel == "relationalOpLT":
        #    stateMachine["relationalOperator"] = { "operator": "<" }
        #elif lbnfLabel == "relationalOpGT":
        #    stateMachine["relationalOperator"] = { "operator": ">" }
        #elif lbnfLabel == "relationalOpLE":
        #    stateMachine["relationalOperator"] = { "operator": "<=" }
        #elif lbnfLabel == "relationalOpGE":
        #    stateMachine["relationalOperator"] = { "operator": ">=" }
        elif lbnfLabel == "comparisonEQ":
            appendInstruction(expression, { "operator": "==" }, source)
        elif lbnfLabel == "comparisonNEQ":
            appendInstruction(expression, { "operator": "!=" }, source)
        elif lbnfLabel == "comparisonLT":
            appendInstruction(expression, { "operator": "<" }, source)
        elif lbnfLabel == "comparisonGT":
            appendInstruction(expression, { "operator": ">" }, source)
        elif lbnfLabel == "comparisonLE":
            appendInstruction(expression, { "operator": "<=" }, source)
        elif lbnfLabel == "comparisonGE":
            appendInstruction(expression, { "operator": ">=" }, source)
        elif lbnfLabel == "relational_factorAND":
            appendInstruction(expression, { "operator": "AND" }, source)
        elif lbnfLabel == "relational_expOR":
            appendInstruction(expression, { "operator": "OR" }, source)
        elif lbnfLabel in ["prePrimaryFunction", "userBitFunction", 
                           "userCharFunction", "userStructFunc",
                           "noArgumentUserFunction"]:
            internalState = "waitFunctionName"
        elif lbnfLabel == "factorTranspose":
            appendInstruction(expression, {"function": "TRANSPOSE"}, source)
            
    stateMachine["internalState"] = internalState
    return True
        
    
         