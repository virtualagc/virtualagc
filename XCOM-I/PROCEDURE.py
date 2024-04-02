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

from auxiliary import error

# Returns False on success, True on fatal error.  Parameters:
#    tokenized           Tokenized form of the pseudo-statement being 
#                        processed.
#    scope               The `scope` dictionary for the scope in which
#                        the `string` was found.
def PROCEDURE(tokenized, scope, inRecord = False):
    returnValue = False
    
    # The name of the procedure was indistinguishable from a statement label
    # before reaching this point, and so will have been added to the list of
    # variables as a label.  Remove it.
    symbol = list(scope["variables"])[-1]
    scope["variables"][symbol].pop("LABEL")
    scope["labels"].remove(symbol)
    
    return returnValue
