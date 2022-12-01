#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       replaceBy.py
Purpose:        This is a module for the yaHAL-preprocessor.py program
                that handles REPLACE ... BY "...".
History:        2022-11-18 RSB  Created. 
                2022-11-21 RSB  Added identifier mangling based on DECLARE.

I've implemented a very imperfect, heuristic method.  If it
turns out to be inadequate, it can be replaced.  It probably should be almost
completely redone.  It's crummy in many ways.  It may need a full parser.
For example, it will perform macro replacements within quoted character strings,
which it shouldn't do at all.

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

Additionally, while the original BNF distinguished between identifiers 
for different datatypes (<ARITH ID>, <BIT ID>, <CHAR ID>, ...), the same
patterns for tokens were used for all ... or rather, there's nothing in
the documentation to suggest that all of these were anything other than
<IDENTIFIER>, but the BNF left them completely undefined.  The point, 
however, is that the parser can't consistently tell them apart under
those circumstances.  The <DECLARE> statements give you this information,
but since the parser is context-free, it can't use that information.
My solution is to introduce a new naming convention, and having the 
preprocessor use the DECLAREs to gather info to alter the identifiers
appropriately according to type.  The naming scheme used in my current
LBNF HAL/S language definition is that the following prefixes are added
to identifiers of various types:

    BOOLEAN             b_
    BOOLEAN FUNCTION    bf_
    CHARACTER           c_
    CHARACTER FUNCTION  cf_
    STRUCT              s_
    LABEL               l_
    EVENT               e_
    others              (none)      (Includes INTEGER and SCALAR.)

This name mangling is handled essentially the same way as REPLACE/BY
macros, except that the macros are created from DECLARE statements
or the block head rather than REPLACE statement.  But the scopes 
are the same.
"""

import sys
import re
import copy

bareIdentifierPattern = '[A-Za-z]([A-Za-z0-9_]*[A-Za-z0-9])?'
identifierPattern = "\\b" + bareIdentifierPattern
endblockPattern = '(\\b(END|CLOSE)\\s*;)|(\\b(END|CLOSE)\\s+' + \
                    bareIdentifierPattern + '\\s*;)'
startSpecialBlockPattern = \
    ':\\s*PROGRAM\\s*;|:\\s*FUNCTION\\b|:\\s*PROCEDURE\\b|\\bUPDATE\\s*;|:\\s*TASK\\s*;|\\bCOMPOOL\\s*;'
startblockPattern = startSpecialBlockPattern + '|\\bDO\\b'
replacePattern = '\\bREPLACE\\s+' + identifierPattern
argListPattern = '(\\s*\\([^)]+\\))?'
byPattern = '\\s+BY\\s+"[^"]*"\\s*;'
replaceByPattern = replacePattern + argListPattern + byPattern
declarePattern = '\\bDECLARE\\s'

mangling = { "BOOLEAN" : "b_", "CHARACTER" : "c_", "INTEGER" : "", 
            "SCALAR" : "", "VECTOR" : "", "MATRIX" : "" }

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

debugIndentation = False
def replaceBy(halsSource, metadata, full):

    def removeComments(string):
        while True:
            match = re.search("/[*].*[*]/", string)
            if match == None:
                return string
            string = string[:match.span()[0]] + string[match.span()[1]+1:]

    blockDepth = 0
    macros = [{}] # By depth.
    
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
        if line.strip() == "":
            continue
        fullLine = removeComments(line).strip()
        '''
        j = i + 1
        while fullLine[-1:] != ";" and j < len(halsSource):
            fullLine += " " + removeComments(halsSource[j]).strip()
            metadata[j]["child"] = True
            j += 1
        '''
        #print("->", fullLine, file=sys.stderr)
        # At beginning of a block?
        if "child" not in metadata[i]:
            match = re.search(startblockPattern, fullLine)
            if match != None:
                if debugIndentation:
                    print(blockDepth, "->", blockDepth+1, fullLine, file=sys.stderr)
                blockDepth += 1
                macros.append({})
            # A new macro definition via REPLACE ... BY "..."?  
            match = re.search(replaceByPattern, fullLine)
            if match != None:
                # A new macro is defined here.  We need to parse it enough so 
                # that we can easily use it later.  We add it to the list of 
                # macros for this block depth.
                macroDefinition = match.group()
                match = re.search(replacePattern, macroDefinition) 
                match = re.search(identifierPattern, match.group()[8:])
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
            # Type-distinguishing macros like "l_", "b_", ....
            if full:
                # A new macro via "name:" (avoiding subscripts)?
                hasType = "l_"
                identifier = ""
                isProcedureOrFunction = False
                match = re.search("^" + identifierPattern + "\\s*:", fullLine)
                if match != None:
                    head = match.group()
                    identifier = re.search("^" + bareIdentifierPattern \
                                            + "\\b", head).group()
                    # For a function definition, need also to check out its
                    # datatype.
                    tail = fullLine[match.span()[1]+1:]
                    for datatype in ["BOOLEAN", "CHARACTER"]:
                        if re.search("\\b" + datatype + "\\b", tail) != None:
                            if datatype == "BOOLEAN":
                                hasType = "bf_"
                            elif datatype == "CHARACTER":
                                hasType = "cf_"
                    if re.search("\\b(FUNCTION|PROCEDURE)\\b", tail) != None:
                        isProcedureOrFunction = True
                else:
                    match = re.search("(GO\\s+TO|REPEAT|EXIT)\\s+" + \
                            bareIdentifierPattern + "\\s*;", fullLine);
                    if match != None:
                        identifier = re.search("\\b" + bareIdentifierPattern + \
                            "\\s*;", match.group()).group()[:-1].strip()
                if identifier != "":
                    if identifier[:2] != hasType:
                        macros[-1][identifier] = { "arguments": [], 
                                                "replacement": hasType + identifier, 
                                                "pattern": "\\b" + identifier + "\\b" }
                        if isProcedureOrFunction:
                            macros[-2][identifier] = { "arguments": [], 
                                "replacement": hasType + identifier, 
                                "pattern": "\\b" + identifier + "\\b" }
                # A new macro via DECLARE?
                match = re.search(declarePattern, fullLine)
                if match != None:
                    declarations = fullLine[match.span()[0]:].strip()
                    declarations = re.search("DECLARE[^;]*", declarations).group()
                    declarations = declarations[7:].strip()
                    # At this point, the declarations string contains the entire 
                    # DECLARE statement, in which the leading "DECLARE" and 
                    # trailing ";" have been removed.  There are (say) N fields
                    # delimited by commas.  But we can't just split the statement
                    # at commas, because there could be MATRIX, ARRAY, or INITIAL
                    # qualifiers that also have comms in their parameter lists.
                    # So we have to engage in some heavy-fancy parsing.  :-(
                    # Either N identifiers are declared by the statement (for a 
                    # "simple declare" or "compound declare") or N-1 identifiers
                    # (for a "factored declare").  A macro is created for each
                    # declared identifier of BOOLEAN or CHARACTER type.
                    # Get rid of all matching (possibly nested) parentheses.
                    depth = 0
                    start = -1
                    end = -1
                    for n in range(len(declarations) - 1, -1, -1): 
                        if declarations[n] == ")":
                            if depth == 0:
                                end = n
                            depth += 1
                        elif declarations[n] == "(":
                            depth -= 1
                            if depth == 0:
                                start = n
                        if depth == 0 and start != -1 and end != -1:
                            declarations = declarations[:start] + declarations[end+1:]
                            start = -1
                            end = -1
                    # Get rid of a lot of other stuff that doesn't assist us in 
                    # parsing the datatypes for our particular needs (which are just 
                    # find identifiers that are BOOLEAN or CHARACTER).         
                    for pattern in ["\\bARRAY\\b", "\\bINITIAL\\b", 
                                    "\\bSINGLE\\b", "\\bDOUBLE\\b", "\\bSCALAR\\b",
                                    "\\bVECTOR\\b", "\\bMATRIX\\b", "\\bINTEGER\\b",
                                    "\\bCONSTANT\\b", "\\bPROCEDURE\\b"]:
                        while True:
                            match = re.search(pattern, declarations)
                            if match == None:
                                break
                            declarations = declarations[:match.span()[0]] + \
                                            declarations[match.span()[1] :]
                    declarations = declarations.split(",")
                    if debugIndentation:
                        print("\t" + str(declarations), file=sys.stderr)
                    for n in range(len(declarations)):
                        declarations[n] = declarations[n].split()
                    overallType = ""
                    start = 0
                    if len(declarations[0]) > 0:
                        if declarations[0][0] in mangling:
                            overallType = mangling[declarations[0][0]]
                            start += 1
                    for n in range(start, len(declarations)):
                        declaration = declarations[n]
                        if len(declaration) == 1 and overallType != "":
                            identifier = declaration[0]
                            if identifier[:2] != overallType:
                                macros[-1][identifier] = { "arguments": [], 
                                                "replacement": overallType + identifier, 
                                                "pattern": "\\b" + identifier + "\\b" }
                        elif len(declaration) == 2 and declaration[1] in mangling:
                            thisType = mangling[declaration[1]]
                            identifier = declaration[0]
                            if identifier[:2] != thisType:
                                macros[-1][identifier] = { "arguments": [], 
                                                "replacement": thisType + identifier, 
                                                "pattern": "\\b" + identifier + "\\b" }
                    
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
            for depth in range(blockDepth, -1, -1):
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
                            print("Implementation error parsing macro expansion", \
                                    file=sys.stderr)
                            sys.exit(1)
                        for j in range(len(newArgs)):
                            newArgs[j] = newArgs[j].strip()
                        replacement = copy.deepcopy(macro["replacement"])
                        for j in range(len(newArgs)):
                            replacement = allReplacement(replacement, \
                                        macro["arguments"][j], newArgs[j])
                        line = line[:match.span()[0]] + replacement \
                                        + line[match.span()[1]:]
        # At end of a block?
        if "child" not in metadata[i]:
            match = re.search(endblockPattern, fullLine)
            if match != None:
                # At end of block, so discard all macro definitions specific
                # to this block.
                if debugIndentation:
                    print(blockDepth-1, "<-", blockDepth, fullLine, file=sys.stderr)
                blockDepth -= 1
                if blockDepth < 0:
                    print("Negative block depth implementation error.", \
                            file=sys.stderr)
                macros = macros[:-1]
        if changed:
            halsSource[i] = line # + " //M Changed"

    if blockDepth != 0:
        print("Block depth implementation error.", blockDepth, file=sys.stderr)
