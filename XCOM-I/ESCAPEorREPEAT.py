#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   ESCAPEorREPEAT.py
Purpose:    This is the module of XCOM-I.py which parses CALL statements.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-04-30 RSB  Began.
'''

import sys
from auxiliary import error
from parseCommandLine import debugSink

# Returns False on success, True on fatal error.  Parameters:
#    tokenized           The tokenized form of the pseudo-statement in process.
#    scope               The dictionary for the scope in which
#                        the `string` was found.
def ESCAPEorREPEAT(tokenized, scope, inRecord = False):
    if debugSink:
        print(tokenized, file=debugSink)
    keyword = tokenized[0]["reserved"] # ESCAPE or REPEAT
    if len(tokenized) == 2:
        code = { keyword: None }
    elif len(tokenized) == 3:
        code = { keyword: tokenized[1]["identifier"] }
    else:
        error("Wrong number of tokens for %s" % keyword, scope)
    scope["code"].append(code)
    return False
    
