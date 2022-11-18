#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       tokenize.py
Purpose:        Gets rid of E/M/S multilines by combining them into
                single-line statements.
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
            if main[:1] == "M":
                halsSource[i][0] = " "
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

