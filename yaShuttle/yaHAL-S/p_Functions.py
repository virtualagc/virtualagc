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
currentIdentifier = ""
def updateCurrentIdentifierAttribute(PALMAT, attribute=None, value=True):
    if currentIdentifier == "":
        return
    scope = PALMAT["scopes"][-1]
    identifiers = scope["identifiers"]
    if currentIdentifier not in identifiers:
        identifiers[currentIdentifier] = { }
    if attribute != None:
        identifiers[currentIdentifier][attribute] = value

def removeCurrentIdentifierAttribute(PALMAT, attribute):
    scope = PALMAT["scopes"][-1]
    identifiers = scope["identifiers"]
    if currentIdentifier in identifiers:
        identifierDict = identifiers[currentIdentifier]
        if attribute in identifierDict:
            identifierDict.pop(attribute)

def checkCurrentIdentifierAttribute(PALMAT, attribute):    
    scope = PALMAT["scopes"][-1]
    identifiers = scope["identifiers"]
    if currentIdentifier in identifiers:
        identifierDict = identifiers[currentIdentifier]
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
    global currentIdentifier
    if s[:1] != "^" and s[:2].isupper():
        s = s[2:]
    if debug:
        print("p_Function stringLiteral", s)
    if state == "declaration_list":
        scope = PALMAT["scopes"][-1]
        identifiers = scope["identifiers"]
        currentIdentifier = s
        if s in identifiers:
            print("Already declared:", s[1:-1])
            return False, state
        identifiers[s] = { }
        return True, state
    return True

#-----------------------------------------------------------------------------

def declare_statement(PALMAT, state):
    global currentIdentifier
    currentIdentifier = ""
    return True, state
    
def declareBody_declarationList(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, ourName
    
def declareBody_attributes_declarationList(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, ourName

def declaration_list(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, ourName

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
   
def attributes_typeAndMinorAttr(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, ourName
    
def typeAndMinorAttr_typeSpec(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, ourName
    
def typeAndMinorAttr(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, ourName

def sQdQName_arithConv(PALMAT, state):
    return True, state
    
def arithConv(PALMAT, state):
    ourName = getOurName(sys._getframe())
    return True, ourName

def arithConv_scalar(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "scalar")
    return True, state
    
def arithConv_integer(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "integer")
    return True, state
    
def bitSpecBoolean(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "bit")
    return True, state
    
def typeSpecChar(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "character", "^?^")
    return True, state
    
def arithSpecDouble(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "double")
    return True, state

def init_or_const_headInitial(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "initial", "^?^")
    return True, state
    
def init_or_const_headConstant(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "constant", "^?^")
    return True, state

def minorAttributeDense(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "dense")
    return True, state

def minorAttributeStatic(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "static")
    return True, state

def minorAttributeAutomatic(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "automatic")
    return True, state

def minorAttributeAligned(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "aligned")
    return True, state

def minorAttributeAccess(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "access")
    return True, state

def minorAttributeLock(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "lock", "^?^")
    return True, state

def minorAttributeRemote(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "remote")
    return True, state

def minorAttributeRigid(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "rigid")
    return True, state

def minorAttributeLatched(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "latched")
    return True, state

def minorAttributeNonHal(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "nonhal", "^?^")
    return True, state

def doublyQualNameHead_vector(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "vector", "^?^")
    return True, state

def doublyQualNameHead_matrix(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "matrix", "^?^")
    return True, state

def array_head(PALMAT, state):
    updateCurrentIdentifierAttribute(PALMAT, "array", "^?^")
    return True, state

#-----------------------------------------------------------------------------
# I think this has to go at the end of the module.

objects = globals()

