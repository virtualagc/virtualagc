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
    "commonAttributes" : {}
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
    if s[:1] != "^" and s[:2].isupper():
        s = s[2:]
    scope = PALMAT["scopes"][-1]
    identifiers = scope["identifiers"]
    if state[-1:] == ["declaration_list"]:
        codeGenerationSubstate["currentIdentifier"] = s
        if s in identifiers:
            print("Already declared:", s[1:-1])
            return False, state
        identifiers[s] = { }
        identifiers[s].update(codeGenerationSubstate["commonAttributes"])
        return True, state
    elif state[-2:] == ["bitSpecBoolean", "number"]:
        updateCurrentIdentifierAttribute(PALMAT, state, "bit", int(s[1:-1]))
    elif state[-2:] == ["typeSpecChar", "number"]:
        updateCurrentIdentifierAttribute(PALMAT, state, "character", int(s[1:-1]))
    elif state[-2:] == ["sQdQName_doublyQualNameHead_literalExpOrStar", "number"] \
            or state[-1] in ["doublyQualNameHead_matrix_literalExpOrStar",
                            "arraySpec_arrayHead_literalExpOrStar"]:
        if codeGenerationSubstate["currentIdentifier"] == "":
            identifierDict = codeGenerationSubstate["commonAttributes"]
        else:
            identifierDict = identifiers[codeGenerationSubstate["currentIdentifier"]]
        if "vector" in identifierDict:
            identifierDict["vector"] = int(s[1:-1])
        elif "matrix" in identifierDict:
            identifierDict["matrix"].append(int(s[1:-1]))
        elif "array" in identifierDict:
            identifierDict["array"].append(int(s[1:-1]))
    return True

#-----------------------------------------------------------------------------

def declare_statement(PALMAT, state):
    global codeGenerationSubstate
    #print("***", state)
    codeGenerationSubstate["currentIdentifier"] = ""
    for key in list(codeGenerationSubstate["commonAttributes"].keys()):
        codeGenerationSubstate["commonAttributes"].pop(key)
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
    ourName = getOurName(sys._getframe())
    return True, ourName
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
    if state[-1] in ["bitSpecBoolean", "typeSpecChar", 
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

#-----------------------------------------------------------------------------
# I think this has to go at the end of the module.

objects = globals()

