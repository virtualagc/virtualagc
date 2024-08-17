#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   callTree.py
Purpose:    This is used to eliminate PROCEDURE definitions for PROCEDUREs 
            that are never CALL'ed.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-05-02 RSB  Began.
'''

from parseCommandLine import keepUnused, quiet
from auxiliary import walkModel

# For each PROCEDURE defined at the global level (versus being an embedded
# PROCEDURE), determines how many places it's called from, other than its own
# embedded procedures.  In order to do this, it must walk the entire scope
# hierarchy.  Having done that, it proceeds to eliminate all PROCEDUREs which
# are not called from anywhere.  
def callTree(globalScope):
    
    procedureNames = {}
    
    def checkScope(scope, extra):
        
        def checkLine(line):
            
            def checkExpression(expression):
                if expression == None:
                    return
                if "token" in expression:
                    token = expression["token"]
                    if "identifier" in token:
                        identifier = token["identifier"]
                        if identifier in procedureNames:
                            procedureNames[identifier]["anyCalls"] += 1
                if "children" in expression:
                    for child in expression["children"]:
                        checkExpression(child)
            
            if "ASSIGN" in line:
                checkExpression(line["RHS"])
                for LHS in line["LHS"]:
                    checkExpression(LHS)
            elif "FOR" in line:
                checkExpression(line["from"])
                checkExpression(line["to"])
                checkExpression(line["by"])
            elif "WHILE" in line:
                checkExpression(line["WHILE"])
            elif "UNTIL" in line:
                checkExpression(line["UNTIL"])
            elif "IF" in line:
                checkExpression(line["IF"])
            elif "RETURN" in line:
                checkExpression(line["RETURN"])
            elif "CALL" in line:
                name = line["CALL"]
                if name in procedureNames:
                    procedureNames[name]["anyCalls"] += 1
                for parameter in line["parameters"]:
                    checkExpression(parameter)
            elif "CASE" in line:
                checkExpression(line["CASE"])
                
        for line in scope["code"]:
            checkLine(line)
        return None
    
    # Setup.
    for identifier in globalScope["variables"]:
        attributes = globalScope["variables"][identifier]
        if "PROCEDURE" in attributes:
            procedureNames[identifier] = attributes
            attributes["anyCalls"] = 0
    #print(list(procedureNames))
    # Walk the scope hierarchy.
    walkModel(globalScope, checkScope)
    
    if not keepUnused:
        overrides = []
        junkProcs = [] + overrides;
        for procedure in procedureNames:
            if procedure not in ["COMPACTIFY", "RECORDuLINK", "RECORD_LINK"]:
                if procedureNames[procedure]["anyCalls"] == 0:
                    junkProcs.append(procedure)
        if len(junkProcs) != 0:
            if not quiet:
                print("No code is generated for the following PROCEDURE(s):")
            for j in junkProcs:
                if not quiet:
                    if j in overrides:
                        reason = "Overridden:  "
                    else:
                        reason = "Not called:  "
                    print("\t" + reason + j)
                if j in globalScope["variables"]:
                    globalScope["variables"].pop(j)
            children = globalScope["children"]
            for j in range(len(children)-1, -1, -1):
                if children[j]["symbol"] in junkProcs:
                    del children[j]
        
        # We we need to iterate if any procedures were removed, because it
        # may be that procedures were retained above only because they were
        # called by procedures we've now eliminated, and thus it may not be
        # possible to eliminate them also.
        if len(junkProcs) > 0:
            callTree(globalScope)
            