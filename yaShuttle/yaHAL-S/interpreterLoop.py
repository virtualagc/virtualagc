#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       interpreterLoop.py
Purpose:        This is a top-level intepreter loop for HAL/S code.
Requirements:   READLINE module
History:        2022-12-16 RSB  Split off the nascent form from 
                                yaHAL-S-FC.py.
                2023-02-18 RSB  Added the optimizePALMAT() pass.
"""

#-------------------------------------------------------------------------
# The following module is present to make keyboard entry more palatable.
# for example, on my (Linux) system it enables use of the up- and down-
# arrows to cycle through the history, as well as the right- and left-
# arrows to move horizontally in a line of code for editing.  Unfortunately,
# this kind of functionality apparently has different names on different
# systems, and the alternatives may not always be 100% comparable; or you
# may have to explicitly install one of the alternatives using pip3.
readlinePresent = True
try:
    import gnureadline
    print("Note: Using 'gnureadline' module for line-editing facility.")
    rlModule = gnureadline
except ModuleNotFoundError:
    try:
        import readline
        print("Note: Using 'readline' module for line-editing facility.")
        rlModule = readline
    except ModuleNotFoundError:
        try:
            import editline
            print("Note: Using 'editline' module for line-editing facility.")
            rlModule = editline
        except ModuleNotFoundError:
            try:
                import pyreadline
                print("Note: Using 'pyreadline' module for line-editing facility.")
                rlModule = pyreadline
            except ModuleNotFoundError:
                print("Only primitive line-editing facilities are available.")
                rlModule = None
                readlinePresent = False
if readlinePresent:
    rlModule.set_history_length(100) # Default, -1, means infinite.
'''
if readlinePresent:
    print("Note: Input-line prompts may temporarily disappear when using " + \
          "editing keys ↑, ↓, or BACKSPACE.")
'''

#-------------------------------------------------------------------------

import re
import atexit
from processSource import processSource
from palmatAux import constructPALMAT, writePALMAT, readPALMAT, \
        collectGarbage, findIdentifier, astSourceFile, expandStructureTemplate
from p_Functions import removeIdentifier, removeAllIdentifiers, substate, \
        resetStatement, printTemplate
from executePALMAT import executePALMAT
from replaceBy import bareIdentifierPattern
from optimizePALMAT import optimizePALMAT

# The following makes the buffer for user input persistent, or at least tries
# to.  It works for me anyway.
if rlModule != None:
    historyFile = "yaHAL-S-FC.history"
    try:
        atexit.register(rlModule.write_history_file, historyFile)
        rlModule.read_history_file(historyFile)
        rlModule.set_history_length(1000)
    except FileNotFoundError:
        pass

def printScopeHeading(PALMAT, i):
    scope = PALMAT["scopes"][i]
    if scope["type"] in ["function", "procedure", "program"]:
        if scope["parent"] == None:
            print("Scope %d, %s %s (deleted):" % \
                  (i, scope["type"].upper(), 
                   scope["name"][1:-1]))
        else:
            print("Scope %d, %s %s, parent scope %d:" % \
                  (i, scope["type"].upper(), scope["name"][1:-1],
                   scope["parent"]))
    elif i > 0:
        print("Scope %d, %s, parent scope %d:" % \
              (i, scope["type"].upper(), scope["parent"]))
    else:
        print("Scope %d, %s:" % (i, scope["type"].upper()))
    return scope

helpMenu = \
'''\tNote: Interpreter commands are case-insensitive, while
\tHAL/S source code is case-sensitive.  Any input line
\tbeginning with a back-tick (`) is an interpreter command.
\tThe available interpreter commands are listed below:
\t`HELP            Show this menu.
\t`QUIT            Quit this interpreter program.
\t`CANCEL *        Cancel any uncompleted multi-line source-
\t                 code input.
\t`CANCEL          Cancel just the preceding line of a 
\t                 multi-line source-code input.
\t`NOSTRICT        This is the default, for convenience in
\t                 using the interpreter.  In this mode, column
\t                 1 is not special, and thus full-line comments
\t                 (C in column 1), compiler directives (D), and
\t                 multiline math input (E/M/S) are not 
\t                 available.
\t`STRICT          Enables the special the special treatment of
\t                 column 1 specified by HAL/S documentation.
\t`OPTIMIZE        (Default.)  Enable optimization of PALMAT code.
\t`NOOPTIMIZE      Disable optimization of PALMAT code.
\t`RUN P [*]       Run PROGRAM P. By default, runs as the 
\t                 "primary", which affects the DATA (see
\t                 below).  If the optional 3rd field is
\t                 present, runs as a "secondary" with 
\t                 cloned DATA structures that persist only
\t                 while PROGRAM P runs, and vanish afterward.
\t`SPOOL           Begin spooling all HAL/S source lines for
\t                 later processing.  (The default is to
\t                 process lines one-by-one upon input, and
\t                 to spool only lines not ending in ';'.)
\t                 Note that all interpreter commands are
\t                 acted upon immediately rather than being
\t                 added to the spool.
\t`UNSPOOL          process all spooled lines.
\t`REVIEW          Redisplay spooled HAL/S source lines.
\t`COLORIZE C      Enable colorizing (ANSI terminals only).
\t                 C is one of the following words: black,
\t                 red, green, yellow, blue, magenta, cyan,
\t                 white, gray, brightred, brightgreen,
\t                 brightyellow, brightblue, brightmagenta,
\t                 brightcyan, or brightwhite.
\t`NOCOLORIZE      Disable colorized output.
\t`WRITE F         Write current PALMAT to a file named F.
\t`READ F          Read PALMAT from a file named F.
\t`DATA            Inspect identifiers in root scope.
\t`DATA N          Inspect identifiers in scope N (integer).
\t`DATA *          Inspect identifiers in all scopes.
\t`LABELS          Enables display of program labels in `DATA.
\t`NOLABELS        Disables display of labels in `DATA.
\t`PALMAT          Inspect PALMAT code in root scope.
\t`PALMAT N        Inspect PALMAT code in scope N (integer).
\t`PALMAT *        Inspect PALMAT code in all scopes.
\t`EXECUTE         (Re)execute already-compiled PALMAT.
\t`CLONE           Same as EXECUTE, but clone instantiation.
\t`SCOPES          Inspect scope hierarchy.
\t`GARBAGE         Perform "garbage collection".  This is
\t                 done automatically prior to processing
\t                 any newly-input HAL/S, but it may be
\t                 useful sometimes to do it explictly if
\t                 you want to inspect the environment 
\t                 under which the next HAL/S will run.
\t`REMOVE D        Remove identifier D.
\t`REMOVE *        Remove all identifiers.
\t`RESET           Reset all PALMAT.
\t`STATUS          Show current settings and other info.
\t`WINE            Enable Windows compiler (Linux only).
\t`NOWINE          Disable Windows compiler (Linux only).
\t`TRACE0          Enable preprocessor tracing.
\t`NOTRACE0        Disable preprocessor tracing.
\t`TRACE1          Enable parser tracing.
\t`NOTRACE1        Disable parser tracing.
\t`TRACE2          Enable code-generator tracing.
\t`NOTRACE2        Disable code-generator tracing.
\t`TRACE3          Enable execution tracing.
\t`NOTRACE3        Disable execution tracing.
\t`TRACE4          Enable tracing of compile-time calculations.
\t`NOTRACE4        Disable compile-time calculation tracing.
\t`LBNF            Show abstract syntax trees in LBNF.
\t`BNF             Show abstract syntax trees in BNF.
\t`NOAST           Don't show abstract syntax trees.
\t`EXPAND          Expand structure-template references in `DATA.
\t`NOEXPAND        Don't expand structure-template references.
\t`EXEC            Execute the HAL/S code.
\t`NOEXEC          Don't execute the HAL/S code.
\t`MANGLING [*]    Display mangling macros in the global scope, 
\t                 as understood by the preprocessor.  (These are
\t                 the only macros affecting new interpreter
\t                 input.)  If the optional * is added, additional
\t                 macros having to do with structure-template 
\t                 mangling are displayed, which are normally hidden
\t                 because the cannot be directly accessed from
\t                 the interpreter's input prompt.'''

def interpreterLoop(shouldColorize=False, \
                    xeq=True, lbnf=False, bnf=False, ansiWrapper=True):

    macros = [{"@": 0}]
    spooling = False
    strict = False
    colors = ["black", "red", "green", "yellow", "blue", "magenta", "cyan",
              "white", "gray", "brightred", "brightgreen", "brightyellow",
              "brightblue", "brightmagenta", "brightcyan", "brightwhite"]
    trace0 = False
    trace1 = False
    trace2 = False
    trace3 = False
    trace4 = False
    expand = False
    halCode = False
    quitting = False
    halsSource = []
    metadata = []
    noCompile = False
    showLabels = True
    wine = False
    optimize = True
    if shouldColorize:
        # Regarding the wrappers of \001 ... \002 around all of the ANSI 
        # control sequences, these are apparently helpful for preventing
        # READLINE from becoming confuses about that's visible and not visible,
        # and thus keep it from losing track of the beginning of the line.
        # On a different note, the colorization of the prompt may be 
        # temporarily lost while scrolling up and down through the history,
        # and I have no cure for that.
        if ansiWrapper:
            ansiPrefix = "\001"
            ansiSuffix = "\002"
        else:
            ansiPrefix = ""
            ansiSuffix = ""
        colorize = ansiPrefix + "\033[35m" + ansiSuffix
        colorName = "magenta"
        debugColor = ansiPrefix + "\033[33m" + ansiSuffix
    else:
        colorize = ""
        colorName = ""
        debugColor = ""
    PALMAT = constructPALMAT()
    astSourceFile(PALMAT, "Interpreter")
    print(colorize)
    print("Input HAL/S or else interpreter commands. Use `HELP for more info.")
    while not quitting:
        halCode = False
        line = " "
        while (spooling or line[-1:] != ";") and not quitting:
            if not spooling and line == "":
                break
            if not halCode:
                halsSource = []
                metadata = []
            print(colorize, end="")
            if strict:
                promptChar = "!"
            else:
                promptChar = ">"
            if len(halsSource) == 0:
                prompt = "HAL/S " + promptChar + " "
            else:
                prompt = "  ... " + promptChar + " "
            if colorize != "":
                prompt = prompt + ansiPrefix + "\033[0m" + ansiSuffix
            line = input(prompt)
            print(colorize, end="")
            fields = line.strip().split()
            numWords = len(fields)
            if numWords == 0:
                fileIndex = astSourceFile(PALMAT, "Interpreter")
                halsSource.append(" ")
                metadata.append({"file": fileIndex, "lineNumber": len(halsSource)})
                continue
            if fields[0][:1] == "`":
                fields[0] = fields[0][1:]
                if fields[0] == "":
                    fields.pop(0)
                    if len(fields) == 0:
                        continue
                firstWord = fields[0].upper()
                if firstWord == "SPOOL":
                    print("\tNow spooling input for later processing.")
                    spooling = True
                    continue
                elif firstWord == "UNSPOOL":
                    print("\tHalting spooling of input. Processing " + \
                          "already-spooled input ...")
                    spooling = False
                    line = ""
                    break;
                elif firstWord == "CANCEL":
                    if numWords > 1 and fields[1] == "*":
                        halsSource = []
                        metadata = []
                    elif len(halsSource) > 0:
                        halsSource.pop()
                        metadata.pop()
                    continue
                elif firstWord == "RUN" and len(fields) >= 2:
                    si, attributes = \
                        findIdentifier("^l_" + fields[1] + "^", PALMAT, 0)
                    secondary = len(fields) > 2
                    if attributes != None:
                        if secondary:
                            print("\tRunning as a secondary thread.")
                        else:
                            print("\tRunning as the primary thread.")
                        executePALMAT(PALMAT, attributes["scope"], 0, \
                                      secondary, trace3, 8)
                    else:
                        print("\tCannot find program", fields[1])
                    continue
                elif firstWord == "REVIEW":
                    print("\tReview of spooled input:")
                    if len(halsSource) == 0:
                        print("\t(no spooled source code)")
                        continue
                    for line in halsSource:
                        print("\t%s" % line)
                    continue
                elif firstWord == "COLORIZE" and numWords == 2 \
                        and fields[1].lower() in colors:
                    colorName = fields[1].lower()
                    index = colors.index(colorName)
                    if index < 8:
                        index += 30
                    else:
                        index += 90 - 8
                    colorize = ansiPrefix + ("\033[%dm" % index) + ansiSuffix
                    print(colorize, end="")
                    print("\tEnabled colorized output (%s)." % colorName.upper())
                    continue
                elif firstWord == "REMOVE" and len(fields) > 1:
                    identifier = fields[1]
                    if identifier == "*":
                        removeAllIdentifiers(PALMAT, macros, 0)
                        print("Removed all identifiers from topmost scope.")
                    else: 
                        removeIdentifier(PALMAT, macros, 0, identifier)
                    continue
                elif firstWord == "WRITE" and len(fields) > 1:
                    if writePALMAT(PALMAT, fields[1]):
                        print("\tSuccess!")
                    else:
                        print("\tFailure!")
                    continue
                elif firstWord == "READ" and len(fields) > 1:
                    newPALMAT = readPALMAT(fields[1])
                    if newPALMAT == None:
                        print("\tFailure!")
                    else:
                        PALMAT = newPALMAT
                        print("\tSuccess!")
                    continue
                elif firstWord == "DATA":
                    if len(fields) == 1:
                        r = [0]
                    elif fields[1] == "*":
                        r = range(len(PALMAT["scopes"]))
                    elif fields[1].isdigit():
                        r = [int(fields[1])]
                        if r[0] < 0 or r[0] >= len(PALMAT["scopes"]):
                            continue
                    else:
                        continue
                    for i in r:
                        scope = printScopeHeading(PALMAT, i)
                        identifiers = scope["identifiers"]
                        if len(identifiers) == 0:
                            print("\t(No identifiers declared)")
                        else:
                            for identifier in sorted(identifiers):
                                if showLabels or \
                                        "label" not in identifiers[identifier]:
                                    if "template" in identifiers[identifier]:
                                        attributes = identifiers[identifier]
                                        if expand:
                                            attributes = \
                                                expandStructureTemplate( \
                                                                PALMAT,
                                                                i,
                                                                attributes)
                                        printTemplate(identifier, \
                                                      attributes, \
                                                      8)
                                    else:
                                        print("\t%s:" % identifier[1:-1], \
                                                identifiers[identifier])
                    continue
                elif firstWord == "PALMAT":
                    if len(fields) == 1:
                        r = [0]
                    elif fields[1] == "*":
                        r = range(len(PALMAT["scopes"]))
                    elif fields[1].isdigit():
                        r = [int(fields[1])]
                        if r[0] < 0 or r[0] >= len(PALMAT["scopes"]):
                            continue
                    else:
                        continue
                    for i in r:
                        scope = printScopeHeading(PALMAT, i)
                        instructions = scope["instructions"]
                        if len(instructions) == 0:
                            print("\t(No generated code)")
                        else:
                            count = 0
                            for instruction in instructions:
                                if 'debug' in instruction:
                                    print("\t%s%d: %s%s" % \
                                          (debugColor, count, 
                                           str(instruction), colorize))
                                else:
                                    print("\t%d: %s" % (count, str(instruction)))
                                count += 1
                    continue
                elif firstWord == "QUIT":
                    print("\tQuitting ...")
                    quitting = True
                    break
                elif firstWord == "OPTIMIZE":
                    print("\tOptimization enabled.")
                    optimize = True
                    break
                elif firstWord == "NOOPTIMIZE":
                    print("\tOptimization disabled.")
                    optimize = False
                    break
                elif firstWord == "LABELS":
                    print("\tDisplaying program labels in `DATA.")
                    showLabels = True
                    break
                elif firstWord == "NOLABELS":
                    print("\tNot displaying program labels in `DATA.")
                    showLabels = False
                    break
                elif firstWord == "STRICT":
                    print("\tSTRICT on.")
                    strict = True
                    continue
                elif firstWord == "NOSTRICT":
                    print("\tSTRICT off.")
                    strict = False
                    continue
                elif firstWord == "TRACE0":
                    print("\tTRACE0 on.")
                    trace0 = True
                    continue
                elif firstWord == "NOTRACE0":
                    print("\tTRACE0 off.")
                    trace0 = False
                    continue
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
                elif firstWord == "TRACE4":
                    print("\tTRACE4 on.")
                    trace4 = True
                    continue
                elif firstWord == "NOTRACE4":
                    print("\tTRACE4 off.")
                    trace4 = False
                    continue
                elif firstWord == "EXPAND":
                    print("\tEXPAND on.")
                    expand = True
                    continue
                elif firstWord == "NOEXPAND":
                    print("\tEXPAND off.")
                    expand = False
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
                        print("\tCOLORIZE %-14s  (vs NOCOLORIZE)" \
                              % colorName.upper())
                    else:
                        print("\tNOCOLORIZE               (vs COLORIZE)")
                    if spooling:
                        print("\tSPOOL                    (vs UNSPOOL)")
                    else:
                        print("\tUNSPOOL                  (vs SPOOL)")
                    if strict:
                        print("\tSTRICT                   (vs NOSTRICT)")
                    else:
                        print("\tNOSTRICT                 (vs STRICT)")
                    if showLabels:
                        print("\tLABELS                   (vs. NOLABELS)")
                    else:
                        print("\tNOLABELS                 (vs. LABELS)")
                    if trace0:
                        print("\tTRACE0                   (vs NOTRACE0)")
                    else:
                        print("\tNOTRACE0                 (vs TRACE0)")
                    if trace1:
                        print("\tTRACE1                   (vs NOTRACE1)")
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
                    if trace4:
                        print("\tTRACE4                   (vs NOTRACE4)")
                    else:
                        print("\tNOTRACE4                 (vs TRACE4)")
                    if expand:
                        print("\tEXPAND                   (vs NOEXPAND)")
                    else:
                        print("\tNOEXPAND                 (vs EXPAND)")
                    if xeq:
                        print("\tEXEC                     (vs NOEXEC)")
                    else:
                        print("\tNOEXEC                   (vs EXEC)")
                    if optimize:
                        print("\tOPTIMIZE                 (vs NOOPTIMIZE)")
                    else:
                        print("\tNOOPTIMIZE               (vs OPTIMIZE)")
                    if bnf:
                        print("\tBNF                      (vs LBNF or NOAST)")
                    elif lbnf:
                        print("\tLBNF                     (vs BNF or NOAST)")
                    else:
                        print("\tNOAST                    (vs BNF or LBNF)")
                    continue
                elif firstWord == "EXECUTE":
                    executePALMAT(PALMAT, 0, 0, False, trace3, 8)
                    continue
                elif firstWord == "CLONE":
                    executePALMAT(PALMAT, 0, 0, True, trace3, 8)
                    continue
                elif firstWord == "SCOPES":
                    used = set()
                    for i in range(len(PALMAT["scopes"])):
                        scope = PALMAT["scopes"][i]
                        print("Scope %d:" % i)
                        print("\ttype:      ", scope["type"])
                        print("\tparent:    ", scope["parent"])
                        print("\tchildren:  ", scope["children"])
                        if scope["type"] in ["function", "procedure"]:
                            fields = scope["name"][1:-1].split("_")
                            print("\tname:       %s (%s)" % \
                                    (fields[1], scope["name"][1:-1]))
                            print("\tattributes:", scope["attributes"])
                            if "return" in scope:
                                print("\treturn:    ", scope["return"])
                    continue
                elif firstWord == "GARBAGE":
                    collectGarbage(PALMAT)
                    continue
                elif firstWord == "RESET":
                    PALMAT = constructPALMAT()
                    continue
                elif firstWord == "WINE":
                    print("\tEnabled Windows version of compiler in Linux.")
                    wine = True
                    continue
                elif firstWord == "NOWINE":
                    print("\tDisabled Windows version of compiler in Linux.")
                    wine = False
                    continue
                elif firstWord == "NOCOLORIZE":
                    if colorize != "":
                        print(ansiPrefix + "\033[0m" + ansiSuffix, end="")
                    print("\tDisabled colorized output.")
                    colorize = ""
                    continue
                elif firstWord == "MANGLING":
                    if len(macros[0]) == 0:
                        print("\t(None)")
                    else:
                        for macro in sorted(macros[0]):
                            if macro == "@":
                                continue
                            if (len(fields) > 1 or "-STRUCTURE" not in macro) \
                                     and "replacement" in macros[0][macro] and \
                                    "ignore" not in macros[0][macro]:
                                if "pattern" in macros[0][macro]:
                                    print("\t%s  ->  %s  (%s)" % \
                                          (macro, 
                                           macros[0][macro]["replacement"],
                                           macros[0][macro]["pattern"]))
                                else:
                                    print("\t%s  ->  %s" % \
                                          (macro, 
                                           macros[0][macro]["replacement"]))
                    continue
                elif firstWord == "HELP":
                    print(helpMenu)
                    continue
            halCode = True
            if strict:
                halsSource.append(line)
            else:
                halsSource.append(" " + line)
            fileIndex = astSourceFile(PALMAT, "Interpreter")
            metadata.append({"file": fileIndex, "lineNumber": len(halsSource)})
        if quitting:
            break 
        
        # Sanity check.
        illegals = set()
        for line in halsSource:
            if len(line) > 0 and line[0] not in ["M", "E", "S", "C", 
                                                 "D", " ", "\t"] \
                    and strict:
                illegals.add(line[0])
        if len(illegals) != 0:
            print("\tThere are illegal characters in column one:", illegals)
            print("\tPerhaps you should use the `NOSTRICT command.")
            continue
    
        # For whatever reason, just feeding nothing but blanks into the compiler
        # returns an error, which is not something I want, so detect that case
        # separately and avoid it.
        allEmpty = True
        for line in halsSource:
            if line.strip() != "":
                allEmpty = False
                break
        if allEmpty:
            continue
        
        PALMAT["scopes"][0]["instructions"] = []
        substate["errors"] = []
        substate["warnings"] = []
        identifiers = PALMAT["scopes"][0]["identifiers"]
        
        # Get rid of all scopes and identifiers that will definitely be unusable
        # after the next tranche of HAL/S code is processed, leaving only those
        # which might still be useful.
        collectGarbage(PALMAT)
        resetStatement()
        
        # We want to get rid of all macros, except those for scope 0 which
        # directly relate to the identifiers now present in scope 0.  There
        # are two cases I know of in which the macro needs to be retained:
        #    1.  The replacement (or the first field of the replacement if
        #        split at periods) is an existing identifier.
        #    2.  The key is of the form XXX-STRUCTURE[.something], where XXX is 
        #        a structure template that exists among the identifiers.
        while len(macros) > 1:
            macros.pop()
        macros0 = macros[0]
        macrosToDrop = []
        for macro in macros0:
            if macro == "@":
                continue
            if "ignore" in macros0[macro]:
                macrosToDrop.append(macro)
                continue
            replacement = macros0[macro]["replacement"]
            fields = replacement.split(".")
            if "^" + fields[0] + "^" in identifiers:
                continue
            if "-STRUCTURE" in macro:
                fields = macro.split("-STRUCTURE")
                if "^s_" + fields[0] + "^" in identifiers:
                    continue
            macrosToDrop.append(macro)
        for macro in macrosToDrop:
            macros0.pop(macro)
        
        success, ast = processSource(PALMAT, halsSource, metadata, noCompile, \
                         lbnf, bnf, trace1, wine, trace2, 8, macros, trace4, \
                         strict, trace0)
        if optimize:
            optimizePALMAT(PALMAT)
        if len(substate["warnings"]):
            for warning in substate["warnings"]:
                print("\tWarning:", warning)
        if len(substate["errors"]):
            for warning in substate["errors"]:
                print("\tError:", warning)
        if len(substate["errors"]) == 0 and xeq:
            executePALMAT(PALMAT, 0, 0, False, trace3, 8)
