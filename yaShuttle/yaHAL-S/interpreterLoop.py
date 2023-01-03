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
from executePALMAT import executePALMAT, setupExecutePALMAT

setupExecutePALMAT()

maxRecent = 25
def interpreterLoop(libraryFilename, structureTemplates, shouldColorize=False):
    colors = ["black", "red", "green", "yellow", "blue", "magenta", "cyan",
              "white", "gray", "brightred", "brightgreen", "brightyellow", 
              "brightblue", "brightmagenta", "brightcyan", "brightwhite"]
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
    if shouldColorize:
        colorize = "\033[35m"
        colorName = "magenta"
    else:
        colorize = ""
        colorName = ""
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
            print(colorize, end="")
            if len(halsSource) == 0:
                print("HAL/S > ", end="")
            else:
                print("  ... > ", end="")
            if colorize != "":
                print("\033[0m", end="")
            line = input()
            print(colorize, end="")
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
            elif firstWord == "COLORIZE" and numWords == 2 \
                    and fields[1].lower() in colors:
                colorName = fields[1].lower()
                index = colors.index(colorName)
                if index < 8:
                    index += 30
                else:
                    index += 90 - 8
                colorize = "\033[%dm" % index
                print(colorize, end="")
                print("\tEnabled colorized output (%s)." % colorName.upper())
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
                    print("\tQuitting ...")
                    quitting = True
                    break
                elif firstWord == "TRACE1":
                    print("\tTRACE1 on.")
                    trace1 = True
                    continue
                elif firstWord == "NOTRACE1":
                    print("\tTRACE1 off.")
                    trace1 = False
                    continue
                elif firstWord == "TRACE2":
                    print("\tTRACE2 on.")
                    trace2 = True
                    continue
                elif firstWord == "NOTRACE2":
                    print("\tTRACE2 off.")
                    trace2 = False
                    continue
                elif firstWord == "TRACE3":
                    print("\tTRACE3 on.")
                    trace3 = True
                    continue
                elif firstWord == "NOTRACE3":
                    print("\tTRACE3 off.")
                    trace3 = False
                    continue
                elif firstWord == "LBNF":
                    print("\tDisplaying abstract syntax trees (AST) in LBNF.")
                    lbnf = True
                    bnf = False
                    continue
                elif firstWord == "BNF":
                    print("\tDisplaying abstract syntax trees (AST) in BNF.")
                    bnf = True
                    lbnf = False
                    continue
                elif firstWord == "NOAST":
                    print("\tWon't display abstract syntax trees (AST).")
                    bnf = False
                    lbnf = False
                    continue
                elif firstWord == "EXEC":
                    print("\tWill execute compiled code.")
                    xeq = True
                    continue
                elif firstWord == "NOEXEC":
                    print("\tWon't execute compiled code.")
                    xeq = False
                    continue
                elif firstWord == "STATUS":
                    if colorize != "":
                        print("\tCOLORIZE %-14s  (vs NOCOLORIZE)" % colorName.upper())
                    else:
                        print("\tNOCOLORIZE               (vs COLORIZE)")
                    if trace1:
                        print("\tTRACE1                   (vs (NOTRACE1)")
                    else:
                        print("\tNOTRACE1                 (vs TRACE1)")
                    if trace2:
                        print("\tTRACE2                   (vs NOTRACE2)")
                    else:
                        print("\tNOTRACE2                 (vs TRACE2)")
                    if trace3:
                        print("\tTRACE3                   (vs NOTRACE3)")
                    else:
                        print("\tNOTRACE3                 (vs TRACE3)")
                    if xeq:
                        print("\tEXEC                     (vs NOEXEC)")
                    else:
                        print("\tNOEXEC                   (vs EXEC)")
                    if bnf:
                        print("\tBNF                      (vs LBNF or NOAST)")
                    elif lbnf:
                        print("\tLBNF                     (vs BNF or NOAST)")
                    else:
                        print("\tNOAST                    (vs BNF or LBNF)")
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
                    print("\tIf Linux, will try running Windows version of compiler.")
                    wine = True
                    continue
                elif firstWord == "NOWINE":
                    print("\tWill run native version of the compiler.")
                    wine = False
                    continue
                elif firstWord == "NOCOLORIZE":
                    if colorize != "":
                        print("\033[0m", end="")
                    print("\tDisabled colorized output.")
                    colorize = ""
                    continue
                elif firstWord == "HELP":
                    print()
                    print("\tHELP         Show this menu.")
                    print("\tQUIT         Quit this interpreter program.")
                    print("\tCOLORIZE C   Enable colorized output (ANSI terminals).")
                    print("\t             C is one of the following words: black,")
                    print("\t             red, green, yellow, blue, magenta, cyan,")
                    print("\t             white, gray, brightred, brightgreen,")
                    print("\t             brightyellow, brightblue, brightmagenta,")
                    print("\t             brightcyan, or brightwhite.")
                    print("\tNOCOLORIZE   Disable colorized output.")
                    print("\tDATA         Inspect all variable and constants.")
                    print("\tPALMAT       Inspect recently-generated PALMAT code.")
                    print("\tREMOVE D     Remove identifier D (current scope).")
                    print("\tREMOVE *     Remove all identifiers (current scope).")
                    print("\tRESET        Remove all identifiers (all scopes).")
                    print("\tSTATUS       Show current settings and other info.")
                    print("\tWINE         Run Windows compiler in Linux.")
                    print("\tNOWINE       Run native compiler version (default).")
                    print("\tTRACE1       Turn on parser tracing.")
                    print("\tNOTRACE1     Turn off parser tracing.")
                    print("\tTRACE2       Turn on code-generator tracing.")
                    print("\tNOTRACE2     Turn off code-generator tracing.")
                    print("\tTRACE3       Turn on execution tracing.")
                    print("\tNOTRACE3     Turn off execution tracing.")
                    print("\tLBNF         Show abstract syntax trees in LBNF.")
                    print("\tBNF          Show abstract syntax trees in BNF.")
                    print("\tNOAST        Don't show abstract syntax trees.")
                    print("\tEXEC         Execute the HAL/S code.")
                    print("\tNOEXEC       Don't execute the HAL/S code.")
                    print("\tRECENT       Show recent lines of code, numbered.")
                    print("\tRERUN        Re-run last line of code.")
                    print("\tRERUN D      Re-run numbered line D (from RECENT).")
                    print()
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
            executePALMAT(PALMAT, trace3, 8)