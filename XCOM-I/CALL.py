#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   CALL.py
Purpose:    This is the module of XCOM-I.py which parses CALL statements.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-04-02 RSB  Began.
'''

import sys
from auxiliary import error
from parseCommandLine import debugSink
from parseExpression import parseExpression, printTree

# Returns False on success, True on fatal error.  Parameters:
#    tokenized           The tokenized form of the pseudo-statement in process.
#    scope               The dictionary for the scope in which
#                        the `string` was found.
def CALL(tokenized, scope, inRecord = False):
    if debugSink:
        print(tokenized, file=debugSink)
    
    parameters = []
    state = "start"
    i = 1
    while i < len(tokenized):
        token = tokenized[i]
        isI = i
        i += 1
        if state == "start":
            if "identifier" in token:
                state = "parmstart"
                identifier = token["identifier"]
            elif "builtin" in token:
                state = "parmstart"
                identifier = token["builtin"]
            else:
                error("No procedure name in CALL statement", scope)
                return True
        elif state == "parmstart":
            if token == ";":
                state = "semicolon"
                i -= 1
            elif token == "(":
                state = "parm"
            else:
                error("Expected parameter list in CALL statement", scope)
                return True
        elif state == "parm":
            if token == ")":
                state = "parmend"
                i -= 1
            elif isinstance(token, dict) or token == "(":
                expression = parseExpression(tokenized, isI)
                if expression == None:
                    error("Cannot parse parameter expression in CALL", scope)
                    return True
                parameters.append(expression)
                state = "comma"
                i = expression["end"]
            else:
                error("Cannot parse parameter expression in CALL", scope)
                return True
        elif state == "comma":
            if token == ")":
                state = "parmend"
                i -= 1
            elif token == ",":
                state = "parm"
            else:
                error("Expected a comma in CALL parameter list", scope)
                return True
        elif state == "parmend":
            state = "semicolon"
        elif state == "semicolon":
            if token == ";":
                if i < len(tokenized):
                    error("Premature end of CALL statement", scope)
                    return True
                if debugSink:
                    for parameter in parameters:
                        printTree(parameter, indent="\t", file=debugSink)
                scope["code"].append({"CALL": identifier,
                                      "parameters": parameters})
                return False
            else:
                error("No semicolon in CALL statement", scope)
                return True
    
    error("Cannot parse CALL statement", scope)
    return True
    
