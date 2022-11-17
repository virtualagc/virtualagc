#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       tokenize.py
Purpose:        This is a tokenizer for the HAL/S compiler yaHAL-S.py. 
History:        2022-11-08 RSB  Created.       
"""

"""
Having gotten to this point, halsSource is a list of all the soure-code lines
in all the input files.  We expect certain massaging to have been done, 
namely:

    1.  Newlines have been stripped from the ends of source lines.
    2.  Tabs have been converted to spaces per the tabsize CLI option.
    3.  Full-line comments (either original or "modern") will have been
        identified and marked in the metadata, as will the lines at which
        one source file has changed to the next.

The shuttle-era full-line comments have 'C' in column 1, whereas the Virtual
AGC comments have "#" in column 1. The latter, of course, is not covered by
any of the shuttle-era documentation.  The other possible characters in 
column 1 are "E" (exponent), "M" (main), "S" (subscript), "D" (???),
and blank (which is just a normal line).
"""

import sys

INFO = 0
WARNING = 1
FATAL = 2
warningCount = 0
fatalCount = 0

#=============================================================================
# Add an error/warning to the metadata.
def addError(errorType, msg, metadata, lineNumber):
    global warningCount, fatalCount
    if "errors" not in metadata[lineNumber]:
        metadata[lineNumber]["errors"] = []
    metadata[lineNumber]["errors"].append((errorType, msg))
    if errorType == WARNING:
        warningCount +=1 
    elif errorType == FATAL:
        fatalCount += 1

#=============================================================================
# Combine E/M/S multiline inputs into a single line each.  Nothing is lost
# in doing this, since the compiler (just like the original HAL/S-360 or
# HAL/S-FC compiler) completely ignores all formatting provided by the user
# and pretty-prints the output as it desires anyway.  There are exactly 3
# situations we need to watch for: 3 lines of type E / M / S or 2 lines
# of type E / M or 2 lines of type M / S.  When one of these several cases
# is processed, the topmost of the lines becomes a combination of the 
# other(s), and then the others are turned into blank lines.  I do that to
# preserve the original line numbering for error messages in the output.
def unEMS(halsSource, metadata):
    i = 0
    while i < len(halsSource) - 1:
        combine = 1
        exponent = ""
        main = halsSource[i]
        if len(main) < 1:
            i += 1
            continue
        subscript = halsSource[i + 1]
        if main[0] == "E": # E/M or E/M/S
            exponent = main
            main = subscript
            if len(main) > 0 and main[0] == "M":
                if i + 2 < len(halsSource):
                    subscript = halsSource[i + 2]
                else:
                    subscript = ""
                if len(subscript) > 0 and subscript[0] == "S":
                    combine = 3
                    halsSource[i + 1] = ""
                    halsSource[i + 2] = ""
                else:
                    subscript = ""
                    combine = 2
                    halsSource[i + 1] = ""
            else:
                addError(FATAL, "Dangling exponent line", metadata, i)
                i += 1
                continue
        elif main[0] == "M" and subscript[:1] == "S": # M / S
            combine = 2
            halsSource[i + 1] = ""
        elif main[0] == "S": # A dangling S.  How untidy!
            addError(FATAL, "Dangling subscript line", metadata, i)
            i += 1
            continue
        else:
            i += 1
            continue

        # At this point, the strings exponent, main, and subscript have
        # been defined, if combine != 1, and need to be combined.
        # First pad the strings to be the same length.
        n = max(len(exponent), len(main), len(subscript))
        fmt = "%-" + ("%d" % n) + "s"
        exponent = fmt % exponent
        main = fmt % main
        subscript = fmt % subscript
        replacement = " "
        j = 1
        while j < n:
            if main[j] != " ": # Ignore decorations like '*', '_', etc.
                replacement += main[j]
                j += 1
                continue
            if exponent[j] != " ":
                if j < 1 or main[j - 1] == " ":
                   addError(FATAL, "Unattached exponent", metadata, i)
                   break
                if subscript[j] != " ":
                    addError(FATAL, "Colliding exponent and subscript", metadata, i)
                    break
                replacement += "**("
                while j < n and main[j] == " ":
                    replacement += exponent[j]
                    j += 1
                replacement += ")"
            elif subscript[j] != " ":
                if j < 1 or main[j - 1] == " ":
                    addError(FATAL, "Unattached exponent", metadata, i)
                    break
                replacement += "$("
                while j < n and main[j] == " ":
                    replacement += subscript[j]
                    j += 1
                replacement += ")"
            else:
                replacement += " "
                j += 1
        halsSource[i] = replacement  
        
        i += combine

#=============================================================================
# Tokenize a line of source code.  The list of tokens is added to the 
# metadata for the line.  The line input is unchanged.  The tokens are of the
# form of 3-list
#       [tokenType, data, position]
# The position is the index into the line of source.  It may prove useful for
# error messages.  Inline comments are also include as tokens for the purpose
# of formatting output, though of no meaning to the compiler.
def tokenizeLine(line, meta):
    if "tokens" not in meta:
        meta["tokens"] = []
    if len(line) < 1 or line[0] in ["C", "#"]: # Full-line comment.
        return
    status = "seek token"
    tokenStart = 0
    tokenLength = 0
    for i in range(len(line)):
        # Look for next token.
        char = line[i]
        if status == "seek word end":
            if char.isalnum() or char == "_":
                meta["tokens"][-1][1] = meta["tokens"][-1][1] + char
                continue
            
        if status == "seek token":
            if char == " ":
                continue
            tokenStart = i
            tokenLength = 1
            if char.isalpha():
                # We'll correct the token type later (identifier vs reserved
                # word) after reaching the end of the word.
                meta["tokens"].append(["word", char, tokenStart])
                status = "seek word end"
                continue
            if (char == "." and i + 1 < len(line) and line[i + 1].isdigit()) \
                    or char.isdigit():
                meta["tokens"].append(["numeric literal", char, tokenStart])
                status = "seek number end"
                continue
            if char in ["+", "-", "*", ".", "/", "|", "¬", "&", "=", "<", ">", 
                        "#", "@", "$"]:
                meta["tokens"].append(["operator", char, tokenStart])
                status = "seek token"
                continue
            if char in [",", ";", "\""]:
                meta["tokens"].append(["separator", char, tokenStart])
                status = "seek token"
                continue
            if char == "'":
                meta["tokens"].append(["string literal", "", tokenStart])
                status = "seek literal string end"
                continue
                   

#=============================================================================
# Tokenize the source code.  Since no token can span multiple lines, we 
# tokenize line by line, by adding a metadata[lineNumber]["tokens"] field.
# Returns a tuple of the number of warnings and fatal errors encountered.
# Note that the halsSource (source lines) input list and the metadata
# input list are the same length.
def tokenize(halsSource, metadata):
    unEMS(halsSource, metadata)   # Collapse E/M/S multiline constructs.
    
    for i in range(len(halsSource)):
        tokenizeLine(halsSource[i], metadata[i])
    
    return warningCount, fatalCount
    
