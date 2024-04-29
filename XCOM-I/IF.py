#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   IF.py
Purpose:    This is the module of XCOM-I.py which processes IF statements.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-03-26 RSB  Began.
'''

import sys
from auxiliary import error
from parseCommandLine import debugSink
from parseExpression import parseExpression, printTree

# Returns False on success, True on fatal error.  Parameters:
#    tokenized           The tokenized form of the pseudo-statement in process.
#    scope               The dictionary for the scope in which
#                        the `string` was found.
def IF(tokenized, scope, inRecord = False):
    if debugSink:
        print(tokenized, file=debugSink)

    expression = parseExpression(tokenized, 1)
    if expression != None:
        end = expression["end"]
        if end < len(tokenized):
            token = tokenized[end]
            if "reserved" in token and token["reserved"] == "THEN":
                end += 1
                if end == len(tokenized): # Success!
                    if debugSink:
                        printTree(expression, indent="\t", file=debugSink)
                    scope["code"].append({"IF": expression})
                    return False

    error("Cannot parse IF statement", scope)
    return True
