#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   DO.py
Purpose:    This is the module of XCOM-I.py which processes entries into DO.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-03-26 RSB  Began.
'''

import sys
from auxiliary import error
from parseCommandLine import debugSink
from parseExpression import parseExpression, isVariable, printTree

# Returns False on success, True on fatal error.  Parameters:
#    tokenized           The tokenized form of the pseudo-statement in process.
#    scope               The dictionary for the scope in which
#                        the `string` was found.
def DO(tokenized, scope, inRecord = False):
    
    if debugSink != None:
        print(tokenized, file=debugSink)

    if len(tokenized) <= 1: # Just "DO"
        error("Unexpected termination of DO", scope)
        return True
    
    if len(tokenized) == 2: # Just "DO;".  Okay as is.
        scope["parent"]["code"].append({"BLOCK": True, "scope": scope})
        scope["blockType"] = "DO block"
        return False
    
    if "reserved" in tokenized[1]: # DO WHILE or CASE or UNTIL
        reserved = tokenized[1]["reserved"]
        expression = parseExpression(tokenized, 2)
        if expression == None:
            error("DO WHILE, CASE, or UNTIL expected an expression", scope)
            return True
        end = expression["end"]
        if tokenized[end] != ";":
            error("Missing semicolon in DO WHILE, UNTIL, or CASE", scope)
            return True
        if debugSink != None:
            printTree(expression, indent="\t", file=debugSink)
        if reserved == "WHILE":
            scope["parent"]["code"].append({"WHILE": expression, "scope": scope})
            scope["blockType"] = "DO WHILE block"
            return False
        elif reserved == "UNTIL":
            scope["parent"]["code"].append({"UNTIL": expression, "scope": scope})
            scope["blockType"] = "DO UNTIL block"
            return False
        elif reserved == "CASE":
            scope["parent"]["code"].append({"CASE": expression, "scope": scope})
            scope["blockType"] = "DO CASE block"
            return False
        else:
            error("Unexpected token in DO", scope)
            return True
    
    # If we've gotten to here, the only possibility left is DO i = j to k [by n]
    scope["blockType"] = "DO for-loop block"
    counter = isVariable(tokenized, 1)
    if len(counter) == 1:
        counter = counter[0]
        end = counter["end"]
        token = tokenized[end]
        if "operator" in token and token["operator"] == "=":
            end += 1
            fromCounter = parseExpression(tokenized, end)
            if fromCounter != None:
                end = fromCounter["end"]
                token = tokenized[end]
                if "reserved" in token and token["reserved"] == "TO":
                    end += 1
                    toCounter = parseExpression(tokenized, end)
                    if toCounter != None:
                        end = toCounter["end"]
                        byCounter = {
                            "token": {"number": 1},
                            "parent": None,
                            "children": [],
                            "end": end
                            }
                        if end < len(tokenized):
                            token = tokenized[end]
                            if "reserved" in token and token["reserved"] == "BY":
                                byCounter = parseExpression(tokenized, end + 1)
                                if byCounter != None:
                                    end = byCounter["end"]
                        if end < len(tokenized):
                            token = tokenized[end]
                            if token == ";":
                                end += 1
                                # Success!
                                if debugSink != None:
                                    printTree(counter, indent="\t", file=debugSink)
                                    printTree(fromCounter, indent="\t", file=debugSink)
                                    printTree(toCounter, indent="\t", file=debugSink)
                                    printTree(byCounter, indent="\t", file=debugSink)
                                scope["parent"]["code"].append({
                                    "FOR": True,
                                    "index": counter,
                                    "from": fromCounter,
                                    "to": toCounter,
                                    "by": byCounter,
                                    "scope": scope})
                                return False
    
    error("Cannot parse DO for-loop", scope)
    return True
