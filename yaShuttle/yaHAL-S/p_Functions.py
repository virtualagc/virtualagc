#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       p_Functions.py
Purpose:        Contains all low-level PALMAT-generation functions associated
                with LBNF labels in the grammar for the "modern" HAL/S compiler 
                modernHAL-S-FC.c.
History:        2022-12-21 RSB  Created.

Refer to PALMAT.py for a higher-level explanation.

The idea here is that most of these functions perform some action based on
an LBNF "label" in the grammar, and are named identically to those labels,
except that the labels each have a 2-letter all-cap prefixed which is 
insignificant and is discarded in the function names.  I've had to take
some care to avoid LBNF labels that coincided with Python reserved words or
built-in functionality; in those cases, the LBNF label has simply been
all-cap'd in the grammar.

The functions (which are called by PALMAT.py's generatePALMAT function)
all accept the current PALMAT and state as input and return a pair consisting 
of a boolean (True for success, False for failure) and the new state.  
"""

import sys
import copy
from executePALMAT import findIdentifier

# This is persistent statelike information, unlike the "state" parameter
# used for functions that propagates only *into* the recursive descent and
# is lost when ascending later.
substate = {
    # Used globally.
    "errors" : [],
    "warnings" : [],
    # Used for DECLARE statements, and cleared when the processing of those
    # statements begins.
    "currentIdentifier" : "",
    "commonAttributes" : {},
    # Used while generating code for expressions, prior to generating code.
    "lhs" : [],
    "expression" : []
}

#-----------------------------------------------------------------------------

# This function clones a state (as in the parameters of the various functions
# below named according to labels from the LBNF grammar) and updates its 
# "history" in one of several ways, depending on the value of fsType.
fsSet = 1
fsAugment = 2
def fixupState(state, fsType, name=None):
    if name != None:
        ourName = name
    else:
        # This code gets the name of the calling function as a string.
        frame = sys._getframe(1)
        ourName = frame.f_code.co_name
    newState = copy.deepcopy(state)
    if fsType == fsSet:
        newState["history"] = [ourName]
    elif fsType == fsAugment:
        newState["history"] += [ourName]
    return newState

# Update attribute for identifier.
def updateCurrentIdentifierAttribute(PALMAT, state, attribute=None, value=True):
    global substate
    history = state["history"]
    if substate["currentIdentifier"] == "":
        if history == ['declareBody_attributes_declarationList',
                     'attributes_typeAndMinorAttr'] or \
                     attribute in ["vector", "matrix", "array"]:
            if attribute != None:
                substate["commonAttributes"][attribute] = value
        return
    scope = PALMAT["scopes"][state["scopeIndex"]]
    identifiers = scope["identifiers"]
    if substate["currentIdentifier"] not in identifiers:
        identifiers[substate["currentIdentifier"]] = { }
        identifiers[substate["currentIdentifier"]].update(substate["commonAttributes"])
    if attribute != None:
        identifiers[substate["currentIdentifier"]][attribute] = value

# Remove identifiers.  This is not something you can
# do in HAL/S, but there are interpreter commands for it.
def removeIdentifier(PALMAT, scopeIndex, identifier):
    scope = PALMAT["scopes"][scopeIndex]
    identifiers = scope["identifiers"]
    if identifier in identifiers:
        identifiers.pop(identifier)

def removeAllIdentifiers(PALMAT, scopeIndex):
    PALMAT["scopes"][scopeIndex]["identifiers"] = {}

def testIfExpression(history):
    return ("expression" in history) \
            or ("ifClauseBitExp" in history) \
            or ("relational_exp" in history) \
            or ("while_clause" in history)
    
# This function is called from generatePALMAT() for a string literal.
# Returns only True/False for Success/Failure.
def stringLiteral(PALMAT, state, s):
    global substate
    history = state["history"]
    #-------------------------------------------------------------------------
    # First extract various state info and variations on the string that we'll
    # often use no matter what.
    
    # Recall that string literals will show up in various forms.  All are 
    # surrounded by carats (a la ^...^).  In one form, the literal is an 
    # LBNF label.  Those are prefixed by two capital letters that we'd like
    # removed.  An another, they are identifiers, which we want to use as-is.
    # In another, they are stringified numbers that we want to actually convert
    # to numbers.
    sp = s
    isp = None
    fsp = None
    if s[:1] != "^" and s[:2].isupper():
        s = s[2:]
    elif s[:1] == "^" and s[-1:] == "^":
        sp = s[1:-1]
        try:
            isp = int(sp)
            fsp = isp
        except:
            try:
                fsp = float(sp)
            except:
                pass
    scopeIndex = state["scopeIndex"]
    scope = PALMAT["scopes"][scopeIndex]
    identifiers = scope["identifiers"]
    instructions = scope["instructions"]
    if len(history) == 0:
        state1 = None
    else:
        state1 = history[-1]
    state2 = history[-2:]
    isExpression = testIfExpression(history)
    
    #-------------------------------------------------------------------------
    # Now do various state-machine-dependent stuff with the string (s) or its
    # variations (sp, isp, fsp). 
    
    if "declaration_list" in history and "expression" not in history:
        substate["currentIdentifier"] = s
        if s in identifiers:
            print("Already declared:", sp)
            return False, state
        identifiers[s] = { }
        identifiers[s].update(substate["commonAttributes"])
        if s[1:3] == "s_":
            identifiers[s]["structure"] = True
        return True, state
    elif state1 == "label_definition":
        '''
        if s in identifiers:
            print("Multiple definitions for", sp)
            return False, state
        '''
        identifiers[s] = { "label" : [scopeIndex, len(instructions)] }
    elif state1 == "basicStatementGoTo":
        instructions.append({'goto': s})
    elif state1 == "number" and isExpression:
        substate["expression"].append({ "number": sp })
    elif state1 == "string" and isExpression:
        substate["expression"].append({ "string": sp[1:-1] })
    elif state1 == "number" and "write_key" in history:
        substate["LUN"] = sp
        #instructions.append({"wstart": sp})
    elif state1 == "string" and 'write_arg' in history:
        substate["expression"].append({ "string": sp[1:-1] })
    elif state1 in ["identifier", "char_id", "bit_id"] and isExpression:
        substate["expression"].append({ "fetch": sp })
    elif state2 == ["bitSpecBoolean", "number"]:
        updateCurrentIdentifierAttribute(PALMAT, state, "bit", isp)
    elif state2 == ["typeSpecChar", "number"]:
        if "declareBody_attributes_declarationList" in history:
            substate["commonAttributes"]["character"] = isp
        else:
            updateCurrentIdentifierAttribute(PALMAT, state, "character", isp)
    elif state2 == ["sQdQName_doublyQualNameHead_literalExpOrStar", "number"] \
            or state1 in ["doublyQualNameHead_matrix_literalExpOrStar",
                            "arraySpec_arrayHead_literalExpOrStar"]:
        if substate["currentIdentifier"] == "":
            identifierDict = substate["commonAttributes"]
        else:
            identifierDict = \
                identifiers[substate["currentIdentifier"]]
        if "vector" in identifierDict:
            identifierDict["vector"] = isp
        elif "matrix" in identifierDict:
            identifierDict["matrix"].append(isp)
        elif "array" in identifierDict:
            identifierDict["array"].append(isp)
    elif state2 == ["assignment", "variable"] or history[-3:-1] == ["assignment", "variable"]:
        # Identifier on LHS of an assignment.
        identDict = findIdentifier(PALMAT["scopes"], s, scope)
        if identDict == None: 
            substate["errors"].append("LHS identifier " + sp + " of assignment undeclared.")
        substate["lhs"].append(sp)
    return True

# Reset the portion of the AST state-machine that handles individual statements.
def resetStatement():
    global substate
    substate["currentIdentifier"] = ""
    substate["commonAttributes"] = {}
    substate["lhs"] = []
    substate["expression"] = []

# A built-in HAL/S function.
def halBuiltIn(function):
    substate["expression"].append({ "function": function.upper()})

# Transfer the expression stack to end of the PALMAT instruction list, 
# in reverse order, and clear the expression stack.
def expressionToInstructions(expression, instructions):
    while len(expression) > 0:
        instructions.append(expression.pop())
                    
#-----------------------------------------------------------------------------

def expression(PALMAT, state):
    return True, fixupState(state, fsAugment)

def declare_statement(PALMAT, state):
    resetStatement()
    return True, state
    
def structure_stmt(PALMAT, state):
    resetStatement()
    return True, fixupState(state, fsAugment)

def any_statement(PALMAT, state):
    resetStatement()
    return True, state
    
def declareBody_declarationList(PALMAT, state):
    return True, fixupState(state, fsSet)
    
def declareBody_attributes_declarationList(PALMAT, state):
    return True, fixupState(state, fsSet)

def declaration_list(PALMAT, state):
    return True, fixupState(state, fsAugment)

def identifier(PALMAT, state):
    if testIfExpression(state["history"]):
        return True, fixupState(state, fsAugment)
    return True, state
 
def char_id(PALMAT, state):
    if testIfExpression(state["history"]):
        return True, fixupState(state, fsAugment)
    return True, state
 
def attributes_typeAndMinorAttr(PALMAT, state):
    return True, fixupState(state, fsAugment)

def sQdQName_arithConv(PALMAT, state):
    return True, state
    
def arithConv(PALMAT, state):
    return True, fixupState(state, fsAugment)

def arithConv_scalar(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "scalar")
    return True, state
    
def arithConv_integer(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "integer")
    return True, state
    
def arithConv_vector(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "vector", 3)
    return True, state
    
def arithConv_matrix(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "matrix", [3, 3])
    return True, state
    
def bitSpecBoolean(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "bit", 1)
    if state["history"][-1] == "attributes_typeAndMinorAttr":
        return True, fixupState(state, fsAugment)
    return True, state
    
def typeSpecChar(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "character", "^?^")
    if state["history"][-1] == "attributes_typeAndMinorAttr":
        return True, fixupState(state, fsAugment)
    return True, state
    
def precSpecDouble(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "double")
    return True, state

def init_or_const_headInitial(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "initial", "^?^")
    return True, state
    
def init_or_const_headConstant(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "constant", "^?^")
    return True, state

def minorAttributeDense(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "dense")
    return True, state

def minorAttributeStatic(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "static")
    return True, state

def minorAttributeAutomatic(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "automatic")
    return True, state

def minorAttributeAligned(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "aligned")
    return True, state

def minorAttributeAccess(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "access")
    return True, state

def minorAttributeLock(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "lock", "^?^")
    return True, state

def minorAttributeRemote(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "remote")
    return True, state

def minorAttributeRigid(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "rigid")
    return True, state

def minorAttributeLatched(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "latched")
    return True, state

def minorAttributeNonHal(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "nonhal", "^?^")
    return True, state

def doublyQualNameHead_vector(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "vector", "^?^")
    return True, fixupState(state, fsAugment)

def doublyQualNameHead_matrix(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "matrix", [])
    return True, state

def doublyQualNameHead_matrix_literalExpOrStar(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "matrix", [])
    return True, fixupState(state, fsAugment)

def sQdQName_doublyQualNameHead_literalExpOrStar(PALMAT, state):
    return True, fixupState(state, fsAugment)

def arraySpec_arrayHead_literalExpOrStar(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, state, "array", [])
    return True, fixupState(state, fsAugment)

def level(PALMAT, state):
    if len(state["history"]) > 0 and \
            state["history"][-1] in ["bitSpecBoolean", "typeSpecChar", 
                    "sQdQName_doublyQualNameHead_literalExpOrStar"]:
        return True, fixupState(state, fsAugment, "number")
    
    return True, state

def simple_number(PALMAT, state):
    if state["history"][-1] in ["bitSpecBoolean", "typeSpecChar", 
                    "sQdQName_doublyQualNameHead_literalExpOrStar"]:
        return True, fixupState(state, fsAugment, "number")
    return True, state

def literalStar(PALMAT, state):
    last = state["history"][-1]
    if last == "bitSpecBoolean":
        updateCurrentIdentifierAttribute(PALMAT, state, "bit", "*")
    elif last == "typeSpecChar":
        updateCurrentIdentifierAttribute(PALMAT, state, "character", "*")
    elif last in ["sQdQName_doublyQualNameHead_literalExpOrStar",
                       "doublyQualNameHead_matrix_literalExpOrStar",
                       "arraySpec_arrayHead_literalExpOrStar"]:
        scope = PALMAT["scopes"][state["scopeIndex"]]
        identifiers = scope["identifiers"]
        if substate["currentIdentifier"] == "":
            identifierDict = substate["commonAttributes"]
        elif substate["currentIdentifier"] in identifiers:
            identifierDict = identifiers[substate["currentIdentifier"]]
        else:
            return True, state
        if "vector" in identifierDict:
            identifierDict["vector"] = "*"
        elif "matrix" in identifierDict:
            identifierDict["matrix"].append("*")
        elif "array" in identifierDict:
            identifierDict["array"].append("*")
    return True, state

def assignment(PALMAT, state):
    '''
    Here's the basic theory of how assignments work.  (I'm not quite
    sure just yet how to handle indexed or structure expressions on
    the left of an assignment, so this just covers simple variables
    on the left right now.)
    
    All of the identifiers we encounter on the LHS of the equals
    sign are stored temporarily in substate["LHS"], which is a list
    holding just the names of those identifiers and nothing else.  If
    any of those variables have no declaration, they're dutifully
    recorded in substate["errors"] instead.
    
    On the RHS of the equals should be an expression.  As we 
    recursively-descend through this expression, the significant items
    (like operators, variables, and constants) are appended to 
    substate["expression"].  When the end of the expression is finally
    reached -- which is detected by generatePALMAT() in the PALMAT
    module -- everything in substate["expression"] is popped and 
    stored in PALMAT["instructions"] in reverse order, as a reverse-polish
    style program; i.e., at runtime those RPN instructions will form
    a program that operates on an execution stack in the emulator, 
    in the end resulting in a single computed value remaining on that 
    runtime execution stack.  Finally, everything in substate["LHS"] is 
    then popped and store in PALMAT["instructions"] as well, again in 
    RPN style.  In the case of these LHS items, the RPN instructions 
    they're stored as are not computational in nature, but instead
    are instructions to take the top of the stack (without removing it
    from the stack) and storing it in a variable.  Finally, 
    PALMAT["instructions"] is topped off with a final RPN instruciton
    to pop the final value from the runtime execution stack.
    '''
    return True, fixupState(state, fsAugment)

def arithExpArithExpPlusTerm(PALMAT, state):
    substate["expression"].append({ "operator": "+" })
    return True, state

def arithExpArithExpMinusTerm(PALMAT, state):
    substate["expression"].append({ "operator": "-" })
    return True, state

def arithMinusTerm(PALMAT, state):
    substate["expression"].append({ "operator": "U-" })
    return True, state

def termDivide(PALMAT, state):
    substate["expression"].append({ "operator": "/" })
    return True, state

def productMultiplication(PALMAT, state):
    substate["expression"].append({ "operator": "" })
    return True, state

def factorExponentiation(PALMAT, state):
    substate["expression"].append({ "operator": "**" })
    return True, state

def productDot(PALMAT, state):
    substate["expression"].append({ "operator": "." })
    return True, state

def productCross(PALMAT, state):
    substate["expression"].append({ "operator": "*" })
    return True, state

def charExpCat(PALMAT, state):
    substate["expression"].append({ "operator": "C||" })
    return True, state

def variable(PALMAT, state):
    return True, fixupState(state, fsAugment)

def number(PALMAT, state):
    return True, fixupState(state, fsAugment, "number")

def compound_number(PALMAT, state):
    return True, fixupState(state, fsAugment, "number")

def char_string(PALMAT, state):
    return True, fixupState(state, fsAugment, "string")

def variable(PALMAT, state):
    return True, fixupState(state, fsAugment)

def basicStatementWritePhrase(PALMAT, state):
    return True, fixupState(state, fsAugment)

def write_key(PALMAT, state):
    return True, fixupState(state, fsAugment)

def write_arg(PALMAT, state):
    return True, fixupState(state, fsAugment)

def label_definition(PALMAT, state):
    return True, fixupState(state, fsAugment)

def basicStatementGoTo(PALMAT, state):
    return True, fixupState(state, fsAugment)


def ifClauseBitExp(PALMAT, state):
    return True, fixupState(state, fsAugment)

def ifClauseRelExp(PALMAT, state):
    return True, fixupState(state, fsAugment)

def ifThenElseStatement(PALMAT, state):
    return True, fixupState(state, fsAugment)

def true_part(PALMAT, state):
    return True, fixupState(state, fsAugment)

def bit_exp(PALMAT, state):
    return True, fixupState(state, fsAugment)

def relational_exp(PALMAT, state):
    return True, fixupState(state, fsAugment)

def then(PALMAT, state):
    return True, fixupState(state, fsAugment)

def bit_id(PALMAT, state):
    return True, fixupState(state, fsAugment)

def bitConstTrue(PALMAT, state):
    substate["expression"].append({ "boolean": True })
    return True, state

def bitConstFalse(PALMAT, state):
    substate["expression"].append({ "boolean": False })
    return True, state

def NOT(PALMAT, state):
    substate["expression"].append({ "operator": "NOT" })
    return True, state

def bitFactorAnd(PALMAT, state):
    substate["expression"].append({ "operator": "AND"})  
    return True, state

def bitExpOR(PALMAT, state):
    substate["expression"].append({ "operator": "OR"})  
    return True, state

# Used by various LBNF labels for relational operators, 
# but not itself corresponding to any specific LBNF label.
def relationalOpCommon(PALMAT, state, operatorName):
    instructions = PALMAT["scopes"][state["scopeIndex"]]["instructions"]
    expression = substate["expression"]
    expressionToInstructions(expression, instructions)
    substate["expression"].append({ "operator": operatorName})  
    return True, state

def relationalOpEQ(PALMAT, state):
    return relationalOpCommon(PALMAT, state, "==")

def relationalOpNEQ(PALMAT, state):
    return relationalOpCommon(PALMAT, state, "!=")

def relationalOpLT(PALMAT, state):
    return relationalOpCommon(PALMAT, state, "<")

def relationalOpGT(PALMAT, state):
    return relationalOpCommon(PALMAT, state, ">")

def relationalOpLE(PALMAT, state):
    return relationalOpCommon(PALMAT, state, "<=")

def relationalOpGE(PALMAT, state):
    return relationalOpCommon(PALMAT, state, ">=")

def while_clause(PALMAT, state):
    return True, fixupState(state, fsAugment)

#-----------------------------------------------------------------------------
# I think this has to go at the end of the module.

objects = globals()

