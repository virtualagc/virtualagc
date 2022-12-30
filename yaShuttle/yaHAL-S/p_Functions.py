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

The functions (which are called by PALMAT.py's generatePALMAT function)
all accept the current PALMAT and state as input and return a pair consisting 
of a boolean (True for success, False for failure) and the new state.  
"""
import sys

#-----------------------------------------------------------------------------

# An auxiliary function used only internally in this module.  Not normally
# called directly from outside this module.
debug = False
def getOurName(frame):
    ourName = frame.f_code.co_name
    if debug:
        print("p_Function", ourName)
    return ourName

# Update attribute for identifier.
codeGenerationSubstate = {
    "currentIdentifier" : "",
    "commonAttributes" : {},
    "expressionStack" : []
}
def updateCurrentIdentifierAttribute(PALMAT, state, attribute=None, value=True):
    global codeGenerationSubstate
    if codeGenerationSubstate["currentIdentifier"] == "":
        if state == ['declareBody_attributes_declarationList',
                     'attributes_typeAndMinorAttr'] or \
                     attribute in ["vector", "matrix", "array"]:
            if attribute != None:
                codeGenerationSubstate["commonAttributes"][attribute] = value
        return
    scope = PALMAT["scopes"][-1]
    identifiers = scope["identifiers"]
    if codeGenerationSubstate["currentIdentifier"] not in identifiers:
        identifiers[codeGenerationSubstate["currentIdentifier"]] = { }
        identifiers[codeGenerationSubstate["currentIdentifier"]].update(codeGenerationSubstate["commonAttributes"])
    if attribute != None:
        identifiers[codeGenerationSubstate["currentIdentifier"]][attribute] = value

def removeCurrentIdentifierAttribute(PALMAT, attribute):
    scope = PALMAT["scopes"][-1]
    identifiers = scope["identifiers"]
    if codeGenerationSubstate["currentIdentifier"] in identifiers:
        identifierDict = identifiers[codeGenerationSubstate["currentIdentifier"]]
        if attribute in identifierDict:
            identifierDict.pop(attribute)

def checkCurrentIdentifierAttribute(PALMAT, attribute):    
    scope = PALMAT["scopes"][-1]
    identifiers = scope["identifiers"]
    if codeGenerationSubstate["currentIdentifier"] in identifiers:
        identifierDict = identifiers[codeGenerationSubstate["currentIdentifier"]]
        if attribute in identifierDict:
            return True
    return False

# Remove identifiers.  This is not something you can
# do in HAL/S, but there are interpreter commands for it.
def removeIdentifier(PALMAT, identifier):
    scope = PALMAT["scopes"][-1]
    identifiers = scope["identifiers"]
    if identifier in identifiers:
        identifiers.pop(identifier)

def removeAllIdentifiers(PALMAT):
    PALMAT["scopes"][-1]["identifiers"] = {}
    
# This function is called from generatePALMAT() for a string literal.
# Returns only True/False for Success/Failure.
def stringLiteral(PALMAT, state, s):
    global codeGenerationSubstate
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
    scope = PALMAT["scopes"][-1]
    identifiers = scope["identifiers"]
    if len(state) == 0:
        state1 = None
    else:
        state1 = state[-1]
    state2 = state[-2:]
    
    #-------------------------------------------------------------------------
    # Now do various state-machine-dependent stuff with the string (s) or its
    # variations (sp, isp, fsp). 
    
    if state1 in ["declaration_list", "structure_stmt"]:
        codeGenerationSubstate["currentIdentifier"] = s
        if s in identifiers:
            print("Already declared:", sp)
            return False, state
        identifiers[s] = { }
        if state1 == "structure_stmt":
            codeGenerationSubstate["commonAttributes"]["template"] = []
        identifiers[s].update(codeGenerationSubstate["commonAttributes"])
        return True, state
    elif state2 == ["bitSpecBoolean", "number"]:
        updateCurrentIdentifierAttribute(PALMAT, state, "bit", isp)
    elif state2 == ["typeSpecChar", "number"]:
        updateCurrentIdentifierAttribute(PALMAT, state, "character", isp)
    elif state2 == ["sQdQName_doublyQualNameHead_literalExpOrStar", "number"] \
            or state1 in ["doublyQualNameHead_matrix_literalExpOrStar",
                            "arraySpec_arrayHead_literalExpOrStar"]:
        if codeGenerationSubstate["currentIdentifier"] == "":
            identifierDict = codeGenerationSubstate["commonAttributes"]
        else:
            identifierDict = \
                identifiers[codeGenerationSubstate["currentIdentifier"]]
        if "vector" in identifierDict:
            identifierDict["vector"] = isp
        elif "matrix" in identifierDict:
            identifierDict["matrix"].append(isp)
        elif "array" in identifierDict:
            identifierDict["array"].append(isp)
    
    return True

# Reset the portion of the AST state-machine that handles individual statements.
def resetStatement():
    global codeGenerationSubstate
    codeGenerationSubstate["currentIdentifier"] = ""
    codeGenerationSubstate["commonAttributes"] = {}
    codeGenerationSubstate["expressionStack"] = []

#-----------------------------------------------------------------------------

def declare_statement(PALMAT, state):
    resetStatement()
    return True, state
    
def structure_stmt(PALMAT, state):
    resetStatement()
    ourName = getOurName(sys._getframe())
    return True, state + [ourName]

def any_statement(PALMAT, state):
    resetStatement()
    return True, state
    
def declareBody_declarationList(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, [ourName]
    
def declareBody_attributes_declarationList(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, [ourName]

def declaration_list(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, state + [ourName]

'''   
def declaration_nameId(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, ourName
'''

'''
def declaration_nameId_attributes(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, ourName
'''

'''
def identifier(PALMAT, state):
    if state[-1:] == ["structure_stmt"]:
        ourName = getOurName(sys._getframe())
        return True, ourName
    returen True, state
'''
 
'''
def attributes_typeAndMinorAttr(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, state + [ourName]
'''
    
def attributes_typeAndMinorAttr(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, state + [ourName]

'''   
def typeAndMinorAttr(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, state + [ourName]
'''

def sQdQName_arithConv(PALMAT, state):
    return True, state
    
def arithConv(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, state + [ourName]

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
    ourName = getOurName(sys._getframe())
    updateCurrentIdentifierAttribute(PALMAT, state, "bit")
    if state[-1] == "attributes_typeAndMinorAttr":
        state += [ourName]
    return True, state
    
def typeSpecChar(PALMAT, state):
    ourName = getOurName(sys._getframe())
    updateCurrentIdentifierAttribute(PALMAT, state, "character", "^?^")
    if state[-1] == "attributes_typeAndMinorAttr":
        state += [ourName]
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
    ourName = getOurName(sys._getframe())
    updateCurrentIdentifierAttribute(PALMAT, state, "vector", "^?^")
    return True, state + [ourName]

def doublyQualNameHead_matrix(PALMAT, state):
    ourName = getOurName(sys._getframe())
    updateCurrentIdentifierAttribute(PALMAT, state, "matrix", [])
    return True, state

def doublyQualNameHead_matrix_literalExpOrStar(PALMAT, state):
    ourName = getOurName(sys._getframe())
    updateCurrentIdentifierAttribute(PALMAT, state, "matrix", [])
    return True, state + [ourName]

def sQdQName_doublyQualNameHead_literalExpOrStar(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, state + [ourName]

def arraySpec_arrayHead_literalExpOrStar(PALMAT, state):
    ourName = getOurName(sys._getframe())
    updateCurrentIdentifierAttribute(PALMAT, state, "array", [])
    return True, state + [ourName]

def level(PALMAT, state):
    ourName = getOurName(sys._getframe())
    if len(state) > 0 and \
            state[-1] in ["bitSpecBoolean", "typeSpecChar", 
                    "sQdQName_doublyQualNameHead_literalExpOrStar"]:
        state += ["number"]
    
    return True, state

def simple_number(PALMAT, state):
    ourName = getOurName(sys._getframe())
    if state[-1] in ["bitSpecBoolean", "typeSpecChar", 
                    "sQdQName_doublyQualNameHead_literalExpOrStar"]:
        state += ["number"]
    return True, state

def literalStar(PALMAT, state):
    ourName = getOurName(sys._getframe())
    if state[-1] == "bitSpecBoolean":
        updateCurrentIdentifierAttribute(PALMAT, state, "bit", "*")
    elif state[-1] == "typeSpecChar":
        updateCurrentIdentifierAttribute(PALMAT, state, "character", "*")
    elif state[-1] in ["sQdQName_doublyQualNameHead_literalExpOrStar",
                       "doublyQualNameHead_matrix_literalExpOrStar",
                       "arraySpec_arrayHead_literalExpOrStar"]:
        scope = PALMAT["scopes"][-1]
        identifiers = scope["identifiers"]
        if codeGenerationSubstate["currentIdentifier"] == "":
            identifierDict = codeGenerationSubstate["commonAttributes"]
        elif codeGenerationSubstate["currentIdentifier"] in identifiers:
            identifierDict = identifiers[codeGenerationSubstate["currentIdentifier"]]
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
    ourName = getOurName(sys._getframe())
    return True, state + [ourName]

def variable(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, state + [ourName]

#-----------------------------------------------------------------------------
# I think this has to go at the end of the module.

objects = globals()

