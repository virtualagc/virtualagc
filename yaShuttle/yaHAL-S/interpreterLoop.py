#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       interpreterLoop.py
Purpose:        This is a top-level intepreter loop for HAL/S code.
History:        2022-12-16 RSB  Split off the nascent form from 
                                yaHAL-S-FC.py.
"""

from processSource import processSource
from PALMAT import constructPALMAT
from p_Functions import removeIdentifier, removeAllIdentifiers, substate
from executePALMAT import executePALMAT

maxRecent = 25
def interpreterLoop(libraryFilename, structureTemplates):
    xeq = True
    lbnf = False
    bnf = False
    trace1 = False
    trace2 = False
    trace3 = False
    recentHal = []
    recentMeta = []
    halCode = False
    quitting = False
    halsSource = []
    metadata = []
    noCompile = False
    wine = False
    PALMAT = constructPALMAT()
    while not quitting:
        if halCode:
            recentHal.append(halsSource)
            recentMeta.append(metadata)
        if len(recentHal) >= maxRecent:
            recentHal = recentHal[-maxLastLines:]
            recentMeta = recentMeta[-maxLastLines:]
        halsSource = []
        metadata = []
        halCode = False
        line = ""
        while line[-1:] != ";" and not quitting:
            if len(halsSource) == 0:
                line = input("HAL/S > ")
            else:
                line = input("  ... > ")
            fields = line.strip().split()
            numWords = len(fields)
            if numWords == 0:
                fields = ["HELP"]
                numWords = 1
            firstWord = fields[0].upper()
            if firstWord == "RERUN":
                if len(recentHal) == 0:
                    continue
                if numWords <= 2:
                    N = 1
                    if numWords == 2:
                        if fields[1].isdigit():
                            N = int(fields[1])
                        else:
                            continue
                    if N < 1 or N > len(recentHal):
                        continue
                    halsSource = recentHal[-N]
                    metadata = recentMeta[-N]
                    continue
            elif firstWord == "REMOVE" and len(fields) > 1:
                identifier = fields[1]
                if identifier == "*":
                    removeAllIdentifiers(PALMAT)
                else: 
                    removeIdentifier(PALMAT, "^" + identifier + "^")
                continue
            elif numWords == 1:
                # Handle interpreter commands vs HAL/S source code.
                if firstWord == "QUIT":
                    print("Quitting ...")
                    quitting = True
                    break
                elif firstWord == "TRACE1":
                    print("TRACE1 on.")
                    trace1 = True
                    continue
                elif firstWord == "NOTRACE1":
                    print("TRACE1 off.")
                    trace1 = False
                    continue
                elif firstWord == "TRACE2":
                    print("TRACE2 on.")
                    trace2 = True
                    continue
                elif firstWord == "NOTRACE2":
                    print("TRACE2 off.")
                    trace2 = False
                    continue
                elif firstWord == "TRACE3":
                    print("TRACE3 on.")
                    trace3 = True
                    continue
                elif firstWord == "NOTRACE3":
                    print("TRACE3 off.")
                    trace3 = False
                    continue
                elif firstWord == "LBNF":
                    print("Display abstract syntax trees (AST) in LBNF.")
                    lbnf = True
                    bnf = False
                    continue
                elif firstWord == "BNF":
                    print("Display abstract syntax trees (AST) in BNF.")
                    bnf = True
                    lbnf = False
                    continue
                elif firstWord == "NOAST":
                    print("Don't abstract syntax trees (AST).")
                    bnf = False
                    lbnf = False
                    continue
                elif firstWord == "EXEC":
                    print("Execute code after compilation.")
                    xeq = True
                    continue
                elif firstWord == "NOEXEC":
                    print("Don't execute code after compilation.")
                    xeq = False
                    continue
                elif firstWord == "STATUS":
                    if trace1:
                        print("\tTRACE1     (vs (NOTRACE1)")
                    else:
                        print("\tNOTRACE1   (vs TRACE1)")
                    if trace2:
                        print("\tTRACE2     (vs NOTRACE2)")
                    else:
                        print("\tNOTRACE2   (vs TRACE2)")
                    if trace3:
                        print("\tTRACE3     (vs NOTRACE3)")
                    else:
                        print("\tNOTRACE3   (vs TRACE3)")
                    if xeq:
                        print("\tEXEC       (vs NOEXEC)")
                    else:
                        print("\tNOEXEC     (vs EXEC)")
                    if bnf:
                        print("\tBNF        (vs LBNF or NOAST)")
                    elif lbnf:
                        print("\tLBNF       (vs BNF or NOAST)")
                    else:
                        print("\tNOAST      (vs BNF or LBNF)")
                    print("\t%d execution scope(s) found." % len(PALMAT["scopes"]))
                    print("\t%d identifier(s) in current scope." % len(PALMAT["scopes"][-1]["identifiers"]))
                    continue
                elif firstWord == "DATA":
                    scopes = PALMAT["scopes"]
                    for i in range(len(scopes)):
                        scope = scopes[i]
                        print("Scope %d:" % (i+1))
                        identifiers = scope["identifiers"]
                        if len(identifiers) == 0:
                            print("\t(No identifiers declared)")
                        else:
                            for identifier in sorted(identifiers):
                                print("\t%s:" % identifier[1:-1], \
                                        identifiers[identifier])
                    continue
                elif firstWord == "PALMAT":
                    scopes = PALMAT["scopes"]
                    for i in range(len(scopes)):
                        scope = scopes[i]
                        print("Scope %d:" % (i+1))
                        instructions = scope["instructions"]
                        if len(instructions) == 0:
                            print("\t(No generated code)")
                        else:
                            for instruction in instructions:
                                print("\t%s" % str(instruction))
                    continue
                elif firstWord == "RESET":
                    PALMAT = constructPALMAT()
                    continue
                elif firstWord == "RECENT":
                    for i in range(len(recentHal)):
                        print("%2d: %s" % (len(recentHal)-i, recentHal[i]))
                    continue
                elif firstWord == "WINE":
                    print("Will try running Windows version of compiler using WINE.")
                    wine = True
                    continue
                elif firstWord == "NOWINE":
                    print("Will run native version of the compiler.")
                    wine = False
                    continue
                elif firstWord == "HELP":
                    print("\nHere are the interpreter commands you can use:")
                    print("    HELP         Show this menu.")
                    print("    QUIT         Quit this interpreter program.")
                    print("    DATA         Inspect all variable and constants.")
                    print("    PALMAT       Inspect recently-generated PALMAT code.")
                    print("    REMOVE D     Remove identifier D (current scope).")
                    print("    REMOVE *     Remove all identifiers (current scope).")
                    print("    RESET        Remove all identifiers (all scopes).")
                    print("    STATUS       Show current settings and other info.")
                    print("    WINE         Run Windows compiler in Linux.")
                    print("    NOWINE       Run native compiler version (default).")
                    print("    TRACE1       Turn on parser tracing.")
                    print("    NOTRACE1     Turn off parser tracing.")
                    print("    TRACE2       Turn on code-generator tracing.")
                    print("    NOTRACE2     Turn off code-generator tracing.")
                    print("    TRACE3       Turn on execution tracing.")
                    print("    NOTRACE3     Turn off execution tracing.")
                    print("    LBNF         Show abstract syntax trees in LBNF.")
                    print("    BNF          Show abstract syntax trees in BNF.")
                    print("    NOAST        Don't show abstract syntax trees.")
                    print("    EXEC         Execute the HAL/S code.")
                    print("    NOEXEC       Don't execute the HAL/S code.")
                    print("    RECENT       Show recent lines of code, numbered.")
                    print("    RERUN        Re-run last line of code.")
                    print("    RERUN D      Re-run numbered line D (from RECENT).")
                    continue
            if len(fields) > 3 and fields[0] == "D" and fields[1] == "INCLUDE" \
                    and fields[2] == "TEMPLATE":
                if fields[3] in structureTemplates:
                    halsSource.append(" " + structureTemplates[fields[3]] )
                else:
                    print("Template", fields[3], "not found.")
                    continue
                metadata.append( { "directive" : True } )
            else:
                halsSource.append( " " + line )
                metadata.append( {} )
        if quitting:
            break 
        PALMAT["scopes"][-1]["instructions"] = []
        substate["errors"] = []
        substate["warnings"] = []
        success, ast = processSource(PALMAT, halsSource, metadata, \
                         libraryFilename, structureTemplates, noCompile, \
                         lbnf, bnf, trace1, wine, trace2)
        if len(substate["warnings"]):
            for warning in substate["warnings"]:
                print("Warning:", warning)
        if len(substate["errors"]):
            for warning in substate["errors"]:
                print("Error:", warning)
        if len(substate["errors"]) == 0 and xeq:
            executePALMAT(PALMAT, trace3)