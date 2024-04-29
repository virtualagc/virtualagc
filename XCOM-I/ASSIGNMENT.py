#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   ASSIGNMENT.py
Purpose:    This is the module of XCOM-I.py which processes XPL
            assignment statements.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-03-21 RSB  Began.
'''

import sys
from parseCommandLine import debugSink
from auxiliary import error
from parseExpression import parseExpression, printTree

# Returns False on success, True on fatal error.  Parameters:
#    tokenized           Tokenized form of pseudo-statement being processed.
#    scope               The `scope` dictionary for the scope in which
#                        the `string` was found.
def ASSIGNMENT(tokenized, scope):
    
    # Identify the LHS and RHS of the assignment by the positions of the 
    # '=' token.
    LHS = None
    RHS = None
    for i in range(1, len(tokenized)):
        token = tokenized[i]
        if "operator" in token and token["operator"] == '=':
            if LHS == None:
                LHS = tokenized[:i]
            else:
                error("Multiple equal signs in assignment", scope)
                return True
            RHS = tokenized[i + 1:]
            if len(RHS) < 2 or RHS[-1] != ';':
                error("Missing or malformed RHS", scope)
                return True
            #del RHS[-1]
            treeLHS = []
            start = 0
            while True:
                tree = parseExpression(LHS, start)
                if tree == None:
                    error("Unexpected LHS termination", scope)
                    return True
                treeLHS.append(tree)
                start = tree["end"]
                if start >= len(LHS):
                    break
                if LHS[start] != ",":
                    error("Missing comma in LHS", scope)
                    True
                start += 1
                    
            treeRHS = parseExpression(RHS, 0)
            if RHS[treeRHS["end"]] != ";":
                error("Missing semi-colon at end of assignment", scope)
                return True
            if debugSink != None:
                print("LHS = %s, RHS = %s" % (str(LHS), str(RHS)), file=debugSink)
                for tree in treeLHS:
                    printTree(tree, indent="\t", file=debugSink)
                print("\t=", file=debugSink)
                printTree(treeRHS, indent="\t", file=debugSink)
            scope["code"].append({
                "ASSIGN": True,
                "LHS": treeLHS,
                "RHS": treeRHS})
            return False
    
    error("Unrecognized line", scope)
    return True
