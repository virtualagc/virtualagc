#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   PROCEDURE.py
Purpose:    This is the module of XCOM-I.py which processes XPL
            PROCEDURE lines.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-03-18 RSB  Began.
'''

import sys
from auxiliary import error

# Returns False on success, True on fatal error.  Parameters:
#    tokenized           Tokenized form of the pseudo-statement being 
#                        processed.
#    scope               The `scope` dictionary for the scope in which
#                        the `string` was found.
def PROCEDURE(tokenized, scope, inRecord = False):
    returnValue = False
    parameters = []
    msg = "Cannot parse PROCEDURE definition, state '%s'"
    
    # The name of the procedure was indistinguishable from a statement label
    # before reaching this point, and so will have been added to the list of
    # variables as a label.  Remove it.
    symbol = list(scope["variables"])[-1]
    scope["labels"].remove(symbol)
    attributes = scope["variables"][symbol]
    attributes.pop("LABEL")
    attributes["parameters"] = parameters
    
    # Now parse the remainder of the definition to get the return type and
    # the parameter list.
    state = "start"
    i = 1 # Position 0 is the "PROCEDURE" token itself.
    while i < len(tokenized):
        token = tokenized[i]
        i += 1
        if state == "start":
            if token == "(":
                state = "parm"
            elif token == ";":
                state = "semicolon"
                i -= 1 # Retry this token position.
            elif isinstance(token, dict) and "reserved" in token and \
                    token["reserved"] in ["FIXED", "CHARACTER", "BIT"]:
                state = "type"
                i -= 1 # Retry this token with different state.
            else:
                error(msg % state, scope)
        elif state == "type":
            if token == ";":
                state = "semicolon"
                i -= 1
            elif isinstance(token, dict) and "reserved" in token and \
                    token["reserved"] in ["FIXED", "CHARACTER", "BIT"]:
                attributes["return"] = token["reserved"]
                if token["reserved"] == "BIT":
                    state = "bitstart"
                else:
                    state = "semicolon"
            else:
                error(msg % state, scope)
        elif state == "parm":
            if token == ")":
                state == "type"
            elif "identifier" in token:
                parameters.append(token["identifier"])
                state = "comma"
            else:
                error(msg % state, scope)
        elif state == "bitstart":
            if token == "(":
                state = "bitsize"
            elif token == ";":
                state = "semicolon"
                i -= 1
            else:
                error(msg % state, scope)
        elif state == "bitsize":
            if isinstance(token, dict) and "number" in token:
                attributes["bitsize"] = token["number"]
                state = "bitend"
            else:
                error(msg % state, scope)
        elif state == "bitend":
            if token == ")":
                state = "semicolon"
            else:
                error(msg % state, scope)
        elif state == "comma":
            if token == ",":
                state = "parm"
            elif token == ")":
                state = "type"
            else:
                error(msg % state, scope)
        elif state == "semicolon":
            if token == ";":
                if i == len(tokenized) - 1:
                    break
            else:
                error(msg % state, scope)
    
    if "return" not in attributes:
        attributes["return"] = "FIXED"
    return returnValue
