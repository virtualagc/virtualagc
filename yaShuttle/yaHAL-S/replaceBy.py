#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       replaceBy.py
Purpose:        This is a module for the yaHAL-preprocessor.py program
                that handles REPLACE ... BY "...".
History:        2022-11-18 RSB  Created. 

I've implemented a very imperfect, heuristic method.  If it
turns out to be inadequate, it can be replaced.

I attempt to handle both parsing of the REPLACE ... BY "..." command
and the macro expansions themselves using relatively-simple regex pattern
matching.  That's nowhere as rigorous as what the original language spec
requires, but I *hope* it will be good enough. For example, it assumes
that there won't be multiple statements on a single line.  Still, even 
if it works adequately, there are still drawbacks.

Specifically, note that only the *expanded* macros will be visible to 
the compiler, so the output listings (which are supposed to have the 
*unexpanded* macros, underlined) won't be as expected by the original 
developers, leaving me open to their criticism.  I pass the unexpanded
macros could be passed along in a new kind of comment ("//M") that 
could perhaps be reformatted as desired when the output listing is 
created.
        
Regarding the scope of macros, I believe they're good only until the ends 
of the blocks in which they're defined.  The end of a block can be detected 
by the reserved word CLOSE.  However, it's possible that a block can have 
inline block of the form FUNCTION ... CLOSE, so it's necessary to watch out 
for those as well.  Plus PROCEDURE ... CLOSE.

"""

import sys
import re
import copy

bareIdentifierPattern = '[A-Za-z]([A-Za-z0-9_]*[A-Za-z0-9])?'
identifierPattern = "\\b" + bareIdentifierPattern
endblockPattern = '(\\bCLOSE\\s*;)|(\\bCLOSE\\s+' + identifierPattern + '\\s*;)'
startblockPattern = '(\\bPROGRAM\\s*;)|(\\bFUNCTION\\b)|(\\bPROCEDURE\\b)'
replacePattern = '\\bREPLACE\\s+' + identifierPattern
argListPattern = '(\\s*\\([^)]+\\))?'
byPattern = '\\s+BY\\s+"[^"]*"\\s*;'
replaceByPattern = replacePattern + argListPattern + byPattern

def oneReplacement(string, target, replacement):
    match = re.search("\\b" + target + "\\b", string)
    if match == None:
        return string
    return string[:match.span()[0]] + replacement + string[match.span()[1]:]
    
def allReplacement(string, target, replacement):
    while True:
        newString = oneReplacement(string, target, replacement)
        if string == newString:
            return string
        string = newString

def replaceBy(halsSource, metadata):

    blockDepth = 0
    macros = [] # By depth.
    
    for i in range(len(halsSource)):
        # Ignore lines which shouldn't have macro expansions.
        meta = metadata[i]
        if "comment" in meta:
            continue
        if "modern" in meta:
            continue
        if "directive" in meta:
            continue
        line = halsSource[i]
        # At end of a block?
        match = re.search(endblockPattern, line)
        if match != None and blockDepth > 0:
            # At end of block, so discard all macro definitions specific
            # to this block.
            blockDepth -= 1
            macros = macros[:-1]
            # print(i+1, "end block", file=sys.stderr)
        # At beginning of a block?
        match = re.search(startblockPattern, line)
        if match != None:
            blockDepth += 1
            macros.append({})
            # print(i+1, "start block", file=sys.stderr)
        # A new macro definition?
        match = re.search(replaceByPattern, line)
        if match != None:
            # A new macro is defined here.  We need to parse it enough so 
            # that we can easily use it later.  We add it to the 
            macroDefinition = match.group()
            # print(i+1, blockDepth, match.span(), macroDefinition, file=sys.stderr)
            match = re.search(replacePattern, macroDefinition) # Get just "REPLACE identifier(...)".
            match = re.search(identifierPattern, match.group()[8:]) # Get just "identifier".
            macroName = match.group().strip()
            match = re.search(replacePattern + argListPattern, macroDefinition)
            fields = match.group().split("(")
            argumentString = ""
            if len(fields) > 1:
                argumentString = fields[1].strip()[:-1]
            if len(argumentString) == 0:
                argumentList = []
            else:
                argumentList = argumentString.replace(" ", "").split(",")
            # Create a pattern for which to look for locations in a target line
            # at which to expand this macro.
            pattern = "\\b" + macroName
            if len(argumentList) == 0:
                pattern += "\\b"
            else:
                pattern += "\\s*\\("
                for j in range(len(argumentList)):
                    if j < len(argumentList) - 1:
                        pattern += "\\s*[^,]+\\s*,"
                    else:
                        pattern += "\\s*[^)]+\\s*\\)"
            match = re.search(byPattern, macroDefinition)
            replacementString = match.group()[:-1].strip()[3:].strip().strip('"')
            macros[-1][macroName] = {   "arguments" : argumentList, 
                                        "replacement" : replacementString, 
                                        "pattern" : pattern }
            # print('\t', macroName, macros[-1][macroName], file=sys.stderr)
            continue
        # If we've gotten here, then we have a line which is eligible for macro
        # expansions.  The string called "line" is modified in place as macros
        # are expanded.
        changed = False
        changedLastLoop = True
        while changedLastLoop:
            changedLastLoop = False
            macroNamesChecked = []
            # Loop on block depths, from innermost to outermost, trying all
            # of the defined macros at each level.
            for depth in range(blockDepth-1, -1, -1):
                for macroName in macros[depth]:
                    macro = macros[depth][macroName]
                    if macroName in macroNamesChecked:
                        # If a macro name of an inner block is the same as
                        # one in an outer block, ignore the outer block.
                        continue
                    macroNamesChecked.append(macroName)
                    # Find all occurrences of the macro name in the line.
                    # Notice that the occurrence *could* be within a string
                    # (i.e., '...'), and I don't check for that.  May fix it
                    # up later if that turns out to be a problem.
                    while True:
                        match = re.search(macro["pattern"], line)
                 
                        if match == None: # No match.
                            break
                        changed = True
                        changedLastLoop = True
                        # Prepare the replacement string.
                        newArgs = match.group()[len(macroName):].strip()
                        if len(newArgs) == 0:
                            newArgs = []
                        else:
                            newArgs = newArgs.lstrip("(").rstrip(")")
                            # The following will fail if any of the replacement
                            # strings are themselves expressions containing 
                            # commas, such as function calls having their
                            # own argument lists.  Worry about that later if
                            # it turns out to be a problem.
                            newArgs = newArgs.split(",")
                        if len(newArgs) != len(macro["arguments"]):
                            print("Implementation error parsing macro expansion", file=sys.stderr)
                            sys.exit(1)
                        for j in range(len(newArgs)):
                            newArgs[j] = newArgs[j].strip()
                        replacement = copy.deepcopy(macro["replacement"])
                        for j in range(len(newArgs)):
                            replacement = allReplacement(replacement, macro["arguments"][j], newArgs[j])
                        line = line[:match.span()[0]] + replacement + line[match.span()[1]:]
        if changed:
            halsSource[i] = line + " //M Changed"


