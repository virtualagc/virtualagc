#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   LABEL.py
Purpose:    This is the module of XCOM-I.py which processes XPL/I
            statement labels.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-03-17 RSB  Began.
'''

from auxiliary import error

# Returns False on success, True on fatal error.  Parameters:
#    tokenized           The tokenized form of the pseudo-statement in process.
#    scope               The dictionary for the scope in which
#                        the `string` was found.
def LABEL(tokenized, scope, inRecord = False):
    returnValue = False
    token = tokenized[0]
    if "identifier" not in token:
        error("Label is not an identifier", scope)
        return True
    symbol = token["identifier"]
    scope["variables"][symbol] = { "LABEL" : True}
    scope["labels"].add(symbol)
    scope["code"].append({"TARGET": symbol})
    return returnValue
