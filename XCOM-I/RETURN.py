#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   RETURN.py
Purpose:    This is the module of XCOM-I.py which processes RETURN statements.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-04-02 RSB  Adapted from IF.py.
'''

import sys
from auxiliary import error
from parseCommandLine import debugSink
from parseExpression import parseExpression, printTree

# Returns False on success, True on fatal error.  Parameters:
#    tokenized           The tokenized form of the pseudo-statement in process.
#    scope               The dictionary for the scope in which
#                        the `string` was found.
def RETURN(tokenized, scope, inRecord = False):
    if debugSink:
        print(tokenized, file=debugSink)

    if len(tokenized) > 1 and tokenized[1] == ";":
        scope["code"].append({"RETURN": None})
        return False
    else:
        expression = parseExpression(tokenized, 1)
        if expression != None:
            end = expression["end"]
            if end == len(tokenized) - 1:
                token = tokenized[end]
                if token == ";":
                    if debugSink:
                        printTree(expression, indent="\t", file=debugSink)
                    scope["code"].append({"RETURN": expression})
                    return False

    error("Cannot parse RETURN statement", scope)
    return True
