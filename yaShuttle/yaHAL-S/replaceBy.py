#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       replaceBy.py
Purpose:        This is a module for the yaHAL-preprocessor.py program
                that handles REPLACE ... BY "..." and other macro-type
                expansions.
History:        2022-11-18 RSB  Created. 
                2022-11-21 RSB  Added identifier mangling based on DECLARE.
                                Account for non-mangled declarations in 
                                child-scope vs parent-scope.
                2022-12-06 RSB  (Looks like I forgot to note any of my recent
                                changes, of which there were a lot.  Oops!)
                                Began adding hashing for mangling of structure
                                field names.
                2022-12-09 RSB  Added structure-template library.
                2023-03-06 RSB  nf_.

I've implemented a very imperfect, heuristic method.  If it
turns out to be inadequate, it can be replaced.  It probably should be almost
completely redone.  It's crummy in many ways.  It may need a full parser.
For example, it will perform macro replacements within quoted character strings,
which it shouldn't do at all.  (Later:  I think that I now obfuscate quoted
character strings, so in fact macro replacement can no longer match any patterns
in them.)

I attempt to handle both parsing of the REPLACE ... BY "..." command
and the macro expansions themselves using relatively-simple regex pattern
matching.  That's nowhere as rigorous as what the original language spec
requires, but I *hope* it will be good enough. For example, it assumes
that there won't be multiple statements on a single line.  Still, even 
if it works adequately, there are still drawbacks.  (Later:  The preprocessor
will have rearranged the source code so that lines only contain individual
statements ... defined as things ending in semicolons.  So this paragraph
may not actually be a real concern any longer.)

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
for those as well.  Plus PROCEDURE ... CLOSE.  (Later:  This ignores the fact
that some macros can be established by TEMPORARY declarations within DO ... END
blocks, rather than just by DECLARE declarations in PROGRAM/FUNCTION/PROCEDURE
blocks.  Therefore, the proper scopes for macros must include DO ... END blocks
as well.  Though it looks as though I coded it that way anyway.)

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

    BOOLEAN variable                    b_
    BOOLEAN FUNCTION                    bf_
    CHARACTER variable                  c_
    CHARACTER FUNCTION                  cf_
    STRUCT variable                     s_
    STRUCTURE FUNCTION                  sf_
    No-argument arithmetical FUNCTION   nf_
    LABEL                               l_  
        Includes all of the following:
         * Arithmetical FUNCTION with arguments
         * PROCEDURE
         * PROGRAM
         * COMPOOL
         * Explicit labels ("LABEL:")
         * ... and possibly others ...
    EVENT                               e_
    others                              (none)  
        Includes all variables of types:
         * INTEGER
         * SCALAR
         * VECTOR
         * MATRIX

This name mangling is handled essentially the same way as REPLACE/BY
macros, except that the macros are created from DECLARE statements
or the block head rather than REPLACE statement.  But the scopes 
are the same.
"""

import sys
import re
import copy
import unEMS
from palmatAux import splitOutsideParentheses, fqStart, fqEnd

bareIdentifierPattern = '[A-Za-z]([A-Za-z0-9_]*[A-Za-z0-9])?'
identifierPattern = "\\b" + bareIdentifierPattern
endblockPattern = '(\\b(END|CLOSE)\\s*;)|(\\b(END|CLOSE)\\s+' + \
                    bareIdentifierPattern + '\\s*;)'
startSpecialBlockPattern = \
    ':\\s*PROGRAM\\s*;|:\\s*FUNCTION\\b|:\\s*PROCEDURE\\b|\\bUPDATE\\s*;' + \
    '|:\\s*TASK\\s*;|\\bCOMPOOL\\s*;'
startBlockPattern = startSpecialBlockPattern + '|\\bDO\\b'
replacePattern = '\\bREPLACE\\s+' + identifierPattern
argListPattern = '(\\s*\\([^)]+\\))?'
byPattern = '\\s+BY\\s+"[^"]*"\\s*;'
replaceByPattern = replacePattern + argListPattern + byPattern
declarePattern = '\\bDECLARE\\s'

fqPattern = bareIdentifierPattern + "(\\s*[.]\\s*" + bareIdentifierPattern + ")*"
lastWordPattern = fqStart + bareIdentifierPattern + "\\s*$"
firstWordPattern = "^\\s*" + bareIdentifierPattern + fqEnd

# Note that the mangling prefix for FUNCTION is actually "l_" only for 
# arithmetical functions; for boolean functions it's "bf_", for character
# functions it's "cf_", for structure functions "sf_", and for arithmetical
# functions with *no* arguments it's "nf_".
mangling = { "BOOLEAN" : "b_", "CHARACTER" : "c_", "INTEGER" : "", 
            "SCALAR" : "", "VECTOR" : "", "MATRIX" : "",
            "PROCEDURE" : "l_", "FUNCTION": "l_", "STRUCTURE": "s_",
            "EVENT" : "e_", "BIT" : "b_" }

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

# Expand macros in input string rawline, returning pair line, changed,
# where line is the expanded string and changed is a boolean saying if
# there were actually any changes or not.  The maxScopes parameter tells how
# many levels of scope we're taking the macros from (from innermost scope to
# outermost).  In particular, if maxScopes==1, then only the ones from the 
# innermost scope are used.
def expandMacros(rawline, macros, maxScopes=1000000):
    # Perahaps should not expand macros in a STRUCTURE statement.
    if re.search("^\\s*STRUCTURE\\s", rawline) != None:
        return rawline, False
    line = copy.deepcopy(rawline)
    changed = False
    changedLastLoop = True
    blockDepth = len(macros) - 1
    while changedLastLoop:
        changedLastLoop = False
        macroNamesChecked = []
        numScopes = maxScopes + 1
        # Loop on block depths, from innermost to outermost, trying all
        # of the defined macros at each level.
        for depth in range(blockDepth, -1, -1):
            numScopes -= 1
            if numScopes <= 0:
                break
            for macroName in macros[depth]:
                if macroName == "@":
                    continue
                if "-STRUCTURE" in macroName:
                    continue
                macro = macros[depth][macroName]
                if macroName in macroNamesChecked:
                    # If a macro name of an inner block is the same as
                    # one in an outer block, ignore the outer block.
                    continue
                macroNamesChecked.append(macroName)
                if "ignore" in macro:
                    continue
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
    '''
    There's one thing the loop above wasn't able to do, and that's to
    deal with the dreaded dot product of two vectors, say A.B, in which
    one or both of A or B is a call to a no-argument VECTOR function.
    Such replacements do appear in the macros[] table, but only in a 
    form in which they cannot be found by the check above if they are
    preceded or followed by a ".".  And the patterns in the macros[] 
    table can't be changed to allow the ".", because the name of the 
    function *could* coincide with a structure-field name.  But this
    pathological dot-product case can be detected by more-complex 
    processing (which we'll do right now), since if A.B were a qualified
    structure-field identifier A would have to be mangled to s_A (which
    it can't for a dot product).
    '''
    changedNow = False
    partitions = line.split(".")
    for i in range(len(partitions) - 1):
        # Now, we check the last word in partitions[i] and the first word
        # in partitions[i+1] to see if they may represent a dot-product.
        match1 = re.search(lastWordPattern, partitions[i])
        if match1 == None:
            continue
        leftWord = match1.group().strip()
        if leftWord[:2] == "s_":
            continue
        leftStart = match1.span()[0]
        match2 = re.search(firstWordPattern, partitions[i+1])
        if match2 == None:
            continue
        rightWord = match2.group().strip()
        rightEnd = match2.span()[1]
        for depth in range(blockDepth, -1, -1):
            if match1 == None and match2 == None:
                break
            if match1 != None and leftWord in macros[depth] and \
                    "replacement" in macros[depth][leftWord]:
                partitions[i] = partitions[i][:leftStart] + \
                                macros[depth][leftWord]["replacement"]
                changedNow = True
                match1 = None
            if match2 != None and rightWord in macros[depth] and \
                    "replacement" in macros[depth][rightWord]:
                partitions[i+1] = macros[depth][rightWord]["replacement"] + \
                                  partitions[i+1][rightEnd:]
                changedNow = True
                match2 = None
    if changedNow:
        line = ".".join(partitions)
        changed = True
    return line, changed

# This performs the complete processing for a STRUCTURE statement.  I.e., it
# parses the statement, in so far as it is able, and updates whatever global
# data objects are used to store info about structure templates.

# Returns the modified line (or the same line if unmodified, and a boolean
# success indicator.
def processStructureStatement(fullLine, macros):
    remainder = re.sub("^\\s*STRUCTURE\\s+", "", fullLine.replace(";", ""), 1)
    topFields = remainder.split(":", 1)
    subfields = topFields[0].split()
    # Note that if len(subfields)>1, then the remaining subfields (after 
    # the identifier) are the so-called minor attributes such as RIGID
    # and DENSE, all of which I think we can simply ignore in the PALMAT 
    # implementation.  An exception might be LOCK, though I don't 
    # immediately see why it would be appropriate in a structure template
    # as opposed to a specific structure.  At any rate, if I'm wrong, this
    # is the place to grab such attributes in future maintenance.
    identifier = subfields[0]
    subfields[0] = "s_" + identifier
    minorAttributes = subfields[1:]
    macros[-1][identifier] = { "arguments": [], 
                "replacement": "s_" + identifier, 
                "pattern": fqStart + identifier + fqEnd }
    # fields[1] now remains to be parsed.  It consists of comma-separated
    # subfields, each of which is of the form
    #    LEVEL FIELDNAME ...ATRIBUTES...
    # Unfortunately, the ATTRIBUTES may have commas in them too (within
    # matching parentheses), so we can't just use regular expressions to 
    # make these splits.  Remember ... replaceBy() is part of the preprocessor
    # and not the compiler's code generator, so we have no way to use any of 
    # the stuff we're parsing to create a PALMAT identifier or its attributes;
    # the code generator will have to work all that out for itself later.
    # However, we need to create macros for proper manggline of fieldnames.
    # Unfortunately, the full mangling isn't known until the structure using
    # this structure template is declared.  For example, if we are working with
    # STRUCTURE S: ... and later have a DECLARE T S-STRUCTURE, the mangling
    # occurs for identifiers like T.something and not identifiers like 
    # S.something (of which there presumably aren't any).  However, what we 
    # can do is to create macros for the names (say) S-STRUCTURE.something, 
    # and use them when the DECLARE T S-STRUCTURE is encounted by the 
    # preprocessor; they won't match any identifier, so this is perfectly safe.
    structureFieldsSpecs = splitOutsideParentheses(topFields[1], ",")
    level = 0
    unmangled = []
    mangled = []
    for j in range(len(structureFieldsSpecs)):
        structureFieldsSpec = structureFieldsSpecs[j]
        fields = splitOutsideParentheses(structureFieldsSpec)
        try:
            level = int(fields[0])
        except:
            return fullLine, False
        while len(unmangled) >= level:
            unmangled.pop()
            mangled.pop()
        fieldname = fields[1]
        unmangled.append(fieldname)
        mangledAlready = False
        for k in range(2, len(fields)):
            attribute = fields[k]
            if "CHARACTER" in attribute:
                fieldname = "c_" + fieldname
                mangledAlready = True
            elif "BIT" in attribute or "BOOLEAN" in attribute:
                fieldname = "b_" + fieldname
                mangledAlready = True
            elif "-STRUCTURE" in attribute:
                fieldname = "s_" + fieldname
                otherStructureTemplate = copy.deepcopy(fields[k])
                fields[k] = "s_" + otherStructureTemplate
                mangledAlready = True
                # Since this field of our current structure template is itself 
                # defined in terms of another structure template, we have to
                # pull in all of the manglings of the other structure template
                # and append them one by one to our current field.  but first,
                # we have to go upward through the scopes (or what the 
                # preprocessor things of as scopes) until finding the one in 
                # which this other structure template appears.
                found = False
                macrosAnnex = {}
                for scopeMacro in reversed(macros):
                    if found:
                        break
                    for key in scopeMacro:
                        if otherStructureTemplate in key:
                            found = True
                            uName = key.replace(otherStructureTemplate, \
                                        identifier + "-STRUCTURE." + \
                                            ".".join(unmangled))
                            mName = ".".join(mangled) + "." + \
                                fieldname + scopeMacro[key]["replacement"]
                            if mName[0] != ".":
                                mName = "." + mName
                            macrosAnnex[uName] = {
                                "arguments": [],
                                "replacement": mName
                                }
                macros[-1].update(macrosAnnex)
        if not mangledAlready and j+1 < len(structureFieldsSpecs):
            '''
            There's another way that a fieldname may need to be mangled (with 
            "s_") that we haven't accounted for yet:  If there's another level
            below it in the template.  To find out, we unfortunately have to do 
            this lookahead, because (trust me!) it's too hard to fix up 
            afterward if we get it wrong now
            '''
            next = structureFieldsSpecs[j+1]
            nfields = next.split(None, 1)
            nlevel = int(nfields[0])
            if nlevel > level:
                fieldname = "s_" + fieldname
                mangledAlready = True
        mangled.append(fieldname)
        fields[1] = fieldname
        uName = identifier + "-STRUCTURE." + ".".join(unmangled)
        mName = "." + ".".join(mangled)
        macros[-1][uName] = { "arguments": [], 
                    "replacement": mName }
        structureFieldsSpecs[j] = " ".join(fields)
    topFields[0] = " ".join(subfields)
    topFields[1] = ", ".join(structureFieldsSpecs)
    remainder = ": ".join(topFields)
    fullLine = " STRUCTURE " + remainder + ";"
    return fullLine, True

def fixStructureMacros(macros, structureTemplateName, identifier):
    found = False
    macrosAnnex = {}
    for scopeMacros in reversed(macros):
        if found:
            break
        for key in scopeMacros:
            if structureTemplateName in key:
                found = True
                keySplit = key.split(".", 1)
                qualified = identifier + "." + keySplit[1]
                mangled = "s_" + identifier + scopeMacros[key]["replacement"]
                macrosAnnex[qualified] = {
                    "arguments": [],
                    "replacement": mangled,
                    "pattern": fqStart + qualified.replace(".", "\\s*[.]\\s*") \
                                + fqEnd}
    macros[-1].update(macrosAnnex)

def replaceBy(halsSource, metadata, macros=[{"@": 0}], trace=False):
    debugIndentation = False
    blockDepth = 0
    
    def removeComments(string):
        while True:
            match = re.search("/[*].*[*]/", string)
            if match == None:
                return string
            string = string[:match.span()[0]] + string[match.span()[1]+1:]

    lastFunctionProcedure = -1
    
    for i in range(len(halsSource)):
        # Ignore lines which shouldn't have macro expansions.
        meta = metadata[i]
        if halsSource[i][:1] != " ":
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
        #print("->", fullLine, file=sys.stderr)
        # At beginning of a block?
        if "child" not in metadata[i]:
            match = re.search(startBlockPattern, fullLine)
            if match != None:
                if debugIndentation:
                    print(blockDepth, "->", blockDepth+1, \
                            fullLine, file=sys.stderr)
                blockDepth += 1
                # Upon entry to a new block, we append its list of macros
                # to the full list of blocks, and pop it from the end of the
                # when we eventually leave the block.  At first, this block's
                # list of macros is empty, except that we add one entry ("@")
                # to tell us the source line the block starts at.
                macros.append({"@": i})
                if trace:
                    print("\tMacro block %d start: %s" % (i+1, fullLine))
                lastFunctionProcedure = -1
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
                match = re.search(replacePattern + argListPattern, \
                                macroDefinition)
                fields = match.group().split("(")
                argumentString = ""
                if len(fields) > 1:
                    argumentString = fields[1].strip()[:-1]
                if len(argumentString) == 0:
                    argumentList = []
                else:
                    argumentList = argumentString.replace(" ", "").split(",")
                # Create a pattern for which to look for locations in a target
                # line at which to expand this macro.
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
                replacementString = match.group()[:-1].strip()[3:]\
                                                    .strip().strip('"')
                macros[-1][macroName] = {   "arguments" : argumentList, 
                                            "replacement" : replacementString, 
                                            "pattern" : pattern }
                # print('\t', macroName, macros[-1][macroName], file=sys.stderr)
                continue
            # Type-distinguishing macros like "l_", "b_", ....
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
                for datatype in ["BOOLEAN", "CHARACTER", "STRUCTURE"]:
                    if re.search("\\b" + datatype + "\\b", tail) != None:
                        if datatype == "BOOLEAN":
                            hasType = "bf_"
                        elif datatype == "CHARACTER":
                            hasType = "cf_"
                        elif datatype == "STRUCTURE":
                            hasType = "sf_"
                pfMatch = re.search(\
                    "\\b(FUNCTION|PROCEDURE|PROGRAM|CLOSE|COMPOOL|TASK|UPDATE)\\b",\
                    tail)
                if pfMatch != None:
                    isProcedureOrFunction = True
                    blockType = pfMatch.group(0)
                    if blockType in ["FUNCTION", "PROCEDURE"]:
                        lastFunctionProcedure = i
                        if blockType == "FUNCTION" and \
                                None == re.search("\\bFUNCTION\\(", \
                                                 tail.replace(" ", "")):
                            if trace:
                                print("\t%s is no-argument function" % identifier)
                            if hasType == "l_":
                                hasType = "nf_"    
                # Note that these macros have to be defined in the parent
                # context rather than in the block's context, since the names
                # of the PROGRAM/FUNCTION/PROCEDURE/... will be referenced from
                # the parent and thus needs to be accessible to it.
                if len(macros) < 2:
                    print("\tBlock-nesting error in preprocessor, line", i+1)
                    return
                if identifier not in macros[-2]:
                    macros[-2][identifier] = { "arguments": [], 
                                "replacement": hasType + identifier, 
                                "pattern": fqStart + identifier + fqEnd }
                elif hasType == "nf_":
                    # The identifier is already in the macro table, which can
                    # only mean it was previously-defined by a forward
                    # declaration, which can only mean that it was incorrectly
                    # mangled as "l_".  We must both correct that in the macro
                    # table, and must also backtrack to fix any incorrect
                    # replacements already done.  Note that the present line
                    # hasn't yet had any replacements made in it.
                    macro = macros[-2][identifier]
                    macro["pattern"] = "\\b" + identifier + "\\b"
                    oldReplacement = macro["replacement"]
                    newReplacement = hasType + identifier
                    if oldReplacement != newReplacement:
                        macro["replacement"] = newReplacement
                        start = macros[-2]["@"]
                        fixupPattern = "\\b" + oldReplacement + "\\b"
                        for j in range(start, i):
                            if None != re.search(fixupPattern, halsSource[j]):
                                if trace:
                                    print("\tFixup needed at %d" % (j+1))
                                halsSource[j] = re.sub(fixupPattern, \
                                                       newReplacement, \
                                                       halsSource[j])
            else:
                match = re.search("(GO\\s+TO|REPEAT|EXIT)\\s+" + \
                        bareIdentifierPattern + "\\s*;", fullLine);
                if match != None:
                    identifier = re.search("\\b" + bareIdentifierPattern + \
                        "\\s*;", match.group()).group()[:-1].strip()
                else:
                    # Structure template?  If you wonder why "[^:]*" appears
                    # between the bareIdentifierPattern and the ":" (rather
                    # than simply "\\s*"), it's because a "minor attribute list"
                    # can appear between the identifier and the colon.  See rule
                    # ABstruct_stmt_head in HAL_S.cf.
                    match = re.search("^\\s*STRUCTURE\\s+" + \
                                        bareIdentifierPattern + "[^:]*:", \
                                        fullLine)
                    if match != None:
                        line, success = \
                            processStructureStatement(fullLine, macros)
                        if not success:
                            print("Ill-formed STRUCTURE statement.", \
                                  file=sys.stderr)
                        halsSource[i] = line
                    else:
                        # SCHEDULE statement?
                        match = re.search("^\\s*SCHEDULE\\s+" + \
                                            bareIdentifierPattern + "\\b", \
                                            fullLine)
                        if match != None:
                            fields = match.group().strip().split()
                            identifier = fields[1]
                            macros[-1][identifier] = { "arguments": [], 
                                        "replacement": "l_" + identifier, 
                                        "pattern": fqStart + identifier + fqEnd }
                if identifier != "":
                    if identifier[:2] != hasType:
                        macros[-1][identifier] = { "arguments": [], 
                                        "replacement": hasType + identifier, 
                                        "pattern": fqStart + identifier + fqEnd }
                        if isProcedureOrFunction:
                            macros[-2][identifier] = { "arguments": [], 
                                "replacement": hasType + identifier, 
                                "pattern": fqStart + identifier + fqEnd }
                # A new macro via DECLARE or TEMPORARY?
                declarations = None
                if fullLine[:8] == "DECLARE ":
                    declarations = fullLine[8:-1].strip()
                elif fullLine[:10] == "TEMPORARY ":
                    declarations = fullLine[10:-1].strip()
                if declarations != None:
                    '''
                    At this point, the declarations string contains the entire 
                    DECLARE statement, in which the leading "DECLARE" and 
                    trailing ";" have been removed.  There are (say) N fields
                    delimited by commas.  But we can't just split the statement
                    at commas, because there could be MATRIX, ARRAY, or INITIAL
                    qualifiers that also have comms in their parameter lists.
                    So we simply remove all parenthesized material (with 
                    matching parentheses).  Having done that,
                    either N identifiers are declared by the statement (for a 
                    "simple declare" or "compound declare") or N-1 identifiers
                    (for a "factored declare").  A macro is created for each
                    declared identifier of BOOLEAN or CHARACTER type.
                    Get rid of all matching (possibly nested) parentheses.
                    '''
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
                            declarations = declarations[:start] + \
                                            declarations[end+1:]
                            start = -1
                            end = -1
                    # Get rid of a lot of other stuff that doesn't assist us in 
                    # parsing the datatypes for our particular needs (which are
                    # just find identifiers that are BOOLEAN, CHARACTER, 
                    # STRUCTURE, PROCEDURE, and FUNCTION, I think).         
                    for pattern in ["\\bARRAY\\b", "\\bINITIAL\\b", 
                                "\\bSINGLE\\b", "\\bDOUBLE\\b", "\\bSCALAR\\b",
                                "\\bVECTOR\\b", "\\bMATRIX\\b", "\\bINTEGER\\b",
                                "\\bCONSTANT\\b", "\\bNONHAL\\b", 
                                "\\bLATCHED\\b"]:
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
                    overallFunction = False
                    overallStructureTemplate = ""
                    start = 0
                    if len(declarations[0]) > 0:
                        if declarations[0][0] in mangling:
                            overallType = mangling[declarations[0][0]]
                            if declarations[0][0] == "FUNCTION":
                                overallFunction = True
                                if "BOOLEAN" in declarations[0]:
                                    overallType = "bf_"
                                elif "CHARACTER" in declarations[0]:
                                    overallType = "cf_"
                                elif len(declarations[0]) > 2 and \
                                        "STRUCTURE" in declarations[0][2]:
                                    overallType = "sf_"
                                else:
                                    overallType = "l_"
                            start += 1
                        elif "-STRUCTURE" == declarations[0][0][-10:]:
                            overallType = "s_"
                            overallStructureTemplate = declarations[0][0]
                            start += 1
                    for n in range(start, len(declarations)):
                        declaration = declarations[n]
                        if len(declaration) == 1 and overallType != "":
                            identifier = declaration[0]
                            if identifier[:2] != overallType:
                                macros[-1][identifier] = { "arguments": [], 
                                        "replacement": overallType + identifier, 
                                        "pattern": fqStart + identifier + fqEnd }
                                if overallStructureTemplate:
                                    fixStructureMacros(macros,
                                                       overallStructureTemplate, \
                                                       identifier)
                        elif len(declaration) >= 2 and \
                                declaration[1] in mangling:
                            thisType = mangling[declaration[1]]
                            if overallFunction and thisType == "b_":
                                thisType = "bf_"
                            elif overallFunction and thisType == "c_":
                                thisType = "cf_"
                            elif overallFunction and thisType == "s_":
                                thisType = "sf_"
                            elif overallFunction:
                                thisType = "l_"
                            elif declaration[1] == "FUNCTION":
                                if "BOOLEAN" in declaration[1:]:
                                    thisType = "bf_"
                                elif "CHARACTER" in declaration[1:]:
                                    thisType = "cf_"
                                elif len(declaration) > 2 and \
                                        "STRUCTURE" in declaration[2]:
                                    thisType = "sf_"
                                else:
                                    thisType = "l_"
                            identifier = declaration[0]
                            if identifier[:2] != thisType:
                                macros[-1][identifier] = { "arguments": [], 
                                        "replacement": thisType + identifier, 
                                        "pattern": fqStart + identifier + fqEnd }
                        elif len(declaration) >= 2 and \
                                "-STRUCTURE" == declaration[1][-10:]:
                            thisType = "s_"
                            identifier = declaration[0]
                            if identifier[:2] != thisType:
                                macros[-1][identifier] = { "arguments": [], 
                                        "replacement": thisType + identifier, 
                                        "pattern": fqStart + identifier + fqEnd }
                            fixStructureMacros(macros, declaration[1], identifier)
                        elif len(declaration) > 0:
                            # If we've gotten here, the identifier isn't 
                            # supposed to be mangled.  However, we still have
                            # to account for it in case it's a redeclaration
                            # of an identifier that a parent context wants to
                            # be mangled.
                            identifier = declaration[0]
                            macros[-1][identifier] = { "ignore" : True }
                    # We have to apply name mangling to the parameter list
                    # if we're within a FUNCTION or PROCEDURE definition.
                    if lastFunctionProcedure >= 0:
                        halsSource[lastFunctionProcedure], dummy = \
                            expandMacros(halsSource[lastFunctionProcedure],
                                         macros, 1)
        # At end of a block?  I used to have this *after* the macro expansions
        # below, but it needs to be before so that the label (if any) for
        # statements like "CLOSE LABEL;" or "END LABEL;" is at the correct
        # level.
        if "child" not in metadata[i]:
            match = re.search(endblockPattern, fullLine)
            if match != None:
                # At end of block, so discard all macro definitions specific
                # to this block.
                lastFunctionProcedure = -1
                if debugIndentation:
                    print(blockDepth-1, "<-", blockDepth, \
                            fullLine, file=sys.stderr)
                blockDepth -= 1
                if blockDepth < 0:
                    print("Negative block depth implementation error.", \
                            file=sys.stderr)
                macroLine = macros.pop()
                if trace:
                    macroStart = macroLine.pop("@") + 1
                    for key in list(macroLine.keys()):
                        if "ignore" in macroLine[key]:
                            macroLine.pop(key)
                    print("\tMacro block %d ends at %d:" % (macroStart, i+1), \
                          fullLine)
                    if macroLine == {}:
                        print("\t\t(no macros defined in block)")
                    else:
                        for key in sorted(macroLine):
                            print("\t\t%s: %s" % (key, macroLine[key]))
                
        # If we've gotten here, then we have a line which is eligible for macro
        # expansions.  
        line, changed = expandMacros(line, macros)
        
        if changed:
            halsSource[i] = line # + " //M Changed"

    if blockDepth != 0:
        print("Block depth implementation error.", blockDepth, file=sys.stderr)
