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
from p_Functions import removeIdentifier, removeAllIdentifiers

maxRecent = 25
def interpreterLoop(libraryFilename, structureTemplates):
    xeq = False
    lbnf = False
    bnf = False
    trace = False
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
                line = input("[HELP] > ")
            else:
                line = input("   ... > ")
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
                elif firstWord == "TRACE":
                    print("TRACE on.")
                    trace = True
                    continue
                elif firstWord == "NOTRACE":
                    print("TRACE off.")
                    trace = False
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
                    scopes = PALMAT["scopes"]
                    for i in range(len(scopes)):
                        scope = scopes[i]
                        print("Scope %d:" % (i+1))
                        identifiers = scope["identifiers"]
                        if len(identifiers) == 0:
                            print("\t(Empty)")
                        else:
                            for identifier in sorted(identifiers):
                                print("\t%s:" % identifier[1:-1], \
                                        identifiers[identifier])
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
                    print("    HELP     Show this menu.")
                    print("    QUIT     Quit this interpreter program.")
                    print("    WINE     Run Windows compiler in Linux.")
                    print("    NOWINE   Run native compiler version (default).")
                    print("    TRACE    Turn on parser tracing.")
                    print("    NOTRACE  Turn off parser tracing.")
                    print("    LBNF     Show abstract syntax trees in LBNF.")
                    print("    BNF      Show abstract syntax trees in BNF.")
                    print("    NOAST    Don't show abstract syntax trees.")
                    print("    EXEC     Execute the HAL/S code.")
                    print("    NOEXEC   Don't execute the HAL/S code.")
                    print("    STATUS   Show the current VM state.")
                    print("    REMOVE D Remove identifier D (current scope).")
                    print("    REMOVE * Remove all identifiers (current scope).")
                    print("    RESET    Reset entire STATUS.")
                    print("    RECENT   Show recent lines of code, numbered.")
                    print("    RERUN    Re-run last line of code.")
                    print("    RERUN D  Re-run numbered line D (from RECENT).")
                    continue
            if len(fields) > 3 and fields[0] == "D" and fields[1] == "INCLUDE" \
                    and fields[2] == "TEMPLATE":
                if fields[3] in structureTemplates:
                    halsSource.append(" " + structureTemplates[fields[3]] )
                else:
                    print("Template", fields[3], "not found.")
                    continue
                metadata.append( { "directive" : True } )
            elif line[:1] == "C":
                halsSource.append(line)
                metadata.append({ "comment" : True })
            else:
                halsSource.append( " " + line )
                metadata.append( {} )
        if quitting:
            break 
        PALMAT["scopes"][-1]["instructions"] = []
        success, ast = processSource(PALMAT, halsSource, metadata, \
                         libraryFilename, structureTemplates, noCompile, xeq, \
                         lbnf, bnf, trace, wine)
        
